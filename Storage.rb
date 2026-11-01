class PokemonBox
  attr_reader :pokemon
  attr_accessor :name
  attr_accessor :background

  def initialize(name, maxPokemon = 30)
    @pokemon = []
    @name = name
    @background = nil
    for i in 0...maxPokemon
      @pokemon[i] = nil
    end
  end

  def full?
    return @pokemon.nitems == self.length
  end

  def empty?
    return @pokemon.nitems == 0
  end

  def nitems
    return @pokemon.nitems
  end

  def length
    return @pokemon.length
  end

  def each
    @pokemon.each { |item| yield item }
  end

  def []=(i, value)
    @pokemon[i] = value
  end

  def [](i)
    return @pokemon[i]
  end

  def getAllPokemon
    return @pokemon.select { |p| p && !p.isEgg? }
  end
end

class PokemonStorage
  attr_reader :boxes
  attr_reader :party
  attr_accessor :currentBox
  attr_accessor :defaultBox

  def maxBoxes
    return @boxes.length
  end

  def party
    $Trainer.party
  end

  def party=(value)
    raise ArgumentError.new("Not supported")
  end

  MARKINGCHARS = ["O", "■", "Δ", "◊"]

  def initialize(maxBoxes = STORAGEBOXES, maxPokemon = 30)
    @boxes = []
    for i in 0...maxBoxes
      ip1 = i + 1
      @boxes[i] = PokemonBox.new(_ISPRINTF("Box {1:d}", ip1), maxPokemon)
      backid = i % 24
      @boxes[i].background = "box#{backid}"
    end
    @currentBox = 0
    @boxmode = -1
  end

  def upTotalBoxes(newtotal)
    while @boxes.length < newtotal
      boxnum = @boxes.length + 1
      @boxes[boxnum - 1] = PokemonBox.new(_ISPRINTF("Box {1:d}", boxnum), 30)
      backid = (boxnum - 1) % 24
      @boxes[boxnum - 1].background = "box#{backid}"
    end
  end

  def maxPokemon(box)
    return 0 if box >= self.maxBoxes

    return box < 0 ? 6 : self[box].length
  end

  def [](x, y = nil)
    if y == nil
      return x == -1 ? self.party : @boxes[x]
    else
      for i in @boxes
        raise "Box is a Pokémon, not a box" if i.is_a?(PokeBattle_Pokemon)
      end
      return x == -1 ? self.party[y] : @boxes[x][y]
    end
  end

  def []=(x, y, value)
    if x == -1
      self.party[y] = value
    else
      @boxes[x][y] = value
    end
  end

  def full?
    for i in 0...self.maxBoxes
      return false if !@boxes[i].full?
    end
    return true
  end

  def pbFirstFreePos(box)
    if box == -1
      ret = self.party.nitems
      return ret == 6 ? -1 : ret
    else
      for i in 0...maxPokemon(box)
        return i if !self[box, i]
      end
      return -1
    end
  end

  def pbCopy(boxDst, indexDst, boxSrc, indexSrc)
    if indexDst < 0 && boxDst < self.maxBoxes
      found = false
      for i in 0...maxPokemon(boxDst)
        if !self[boxDst, i]
          found = true
          indexDst = i
          break
        end
      end
      return false if !found
    end
    if boxDst == -1
      if self.party.nitems >= 6
        return false
      end

      self.party[self.party.length] = self[boxSrc, indexSrc]
      self.party.compact!
    else
      if !self[boxSrc, indexSrc]
        raise "Trying to copy nil to storage" # not localized
      end

      self[boxSrc, indexSrc].heal
      self[boxDst, indexDst] = self[boxSrc, indexSrc]
    end
    return true
  end

  def pbMove(boxDst, indexDst, boxSrc, indexSrc)
    return false if !pbCopy(boxDst, indexDst, boxSrc, indexSrc)

    pbDelete(boxSrc, indexSrc)
    return true
  end

  def pbMoveCaughtToParty(pkmn)
    if self.party.nitems >= 6
      return false
    end

    self.party[self.party.length] = pkmn
  end

  def pbMoveCaughtToBox(pkmn, box)
    for i in 0...maxPokemon(box)
      if self[box, i] == nil
        pkmn.heal if box >= 0
        self[box, i] = pkmn
        return true
      end
    end
    return false
  end

  def pbDefaultBox
    return @defaultBox unless @defaultBox.nil?
    return @currentBox
  end

  def pbStoreCaught(pkmn)
    pkmn.heal
    box = pbDefaultBox
    stored = pbStoreToBox(pkmn, box)
    if stored != -1
      return stored
    end
    for j in (box+1)...self.maxBoxes
      stored = pbStoreToBox(pkmn, j)
      if stored != -1
        return stored
      end
    end
    for j in 0...(box-1)
      stored = pbStoreToBox(pkmn, j)
      if stored != -1
        return stored
      end
    end
    return -1
  end

  def pbStoreToBox(pkmn, box)
    for i in 0...maxPokemon(box)
      if self[box, i] == nil
        self[box, i] = pkmn
        return box
      end
    end
    return -1
  end

  def pbDelete(box, index)
    if self[box, index]
      self[box, index] = nil
      if box == -1
        self.party.compact!
      end
    end
  end

  def contains?(pkmn)
    for j in 0...self.maxBoxes
      for i in 0...maxPokemon(j)
        return true if self[j, i] == pkmn
      end
    end
    return false
  end
end

class PokemonStorageWithParty < PokemonStorage
  def party
    return @party
  end

  def party=(value)
    @party = party
  end

  def initialize(maxBoxes = 24, maxPokemon = 30, party = nil)
    super(maxBoxes, maxPokemon)
    if party
      @party = party
    else
      @party = []
    end
  end
end

class PokemonStorageScreen
  attr_reader :scene
  attr_reader :storage

  def initialize(scene, storage)
    @scene = scene
    @storage = storage
    @pbHeldPokemon = nil
  end

  def pbConfirm(str)
    return pbShowCommands(str, [_INTL("Yes"), _INTL("No")]) == 0
  end

  def pbRelease(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    pokemon = heldpoke ? heldpoke : @storage[box, index]
    return if !pokemon

    # if pokemon.isEgg?
    #   pbDisplay(_INTL("You can't release an Egg."))
    #   return false
    if pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return false
    end
    if box == -1 && pbAbleCount <= 1 && pbAble?(pokemon) && !heldpoke
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    command = pbShowCommands(_INTL("Release this Pokémon?"), [_INTL("No"), _INTL("Yes")])
    if command == 1
      if pokemon.item && !pbIsZCrystal?(pokemon.item)
        itemcmd = pbShowCommands(_INTL("This Pokémon is holding {1}. Do you want to remove it?", getItemName(pokemon.item, :a)), [_INTL("Yes"), _INTL("No")])
        if itemcmd == 0
          $PokemonBag.pbStoreItem(pokemon.item)
          pokemon.item = nil
          @scene.pbUpdateOverlay(selected[1])
        end
      end
      pkmnname = pokemon.name
      @scene.pbRelease(selected, heldpoke)
      if heldpoke
        @heldpkmn = nil
      else
        @storage.pbDelete(box, index)
      end
      @scene.pbRefresh
      pbDisplay(_INTL("{1} was released.", pkmnname))
      pbDisplay(_INTL("Bye-bye, {1}!", pkmnname))
      $game_variables[37] += 1 if Reborn # she's watching.
      @scene.pbUpdateOverlay(selected[1])
    end
    return
  end

  def pbMark(selected, heldpoke)
    @scene.pbMark(selected, heldpoke)
  end

  def pbAble?(pokemon)
    return pokemon && !pokemon.isEgg? && pokemon.hp > 0
  end

  def pbAbleCount
    return @storage.party.count { |mon| pbAble?(mon) }
  end

  def pbStore(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if box != -1
      raise _INTL("Can't deposit from box...")
    end

    if pbAbleCount <= 1 && pbAble?(@storage[box, index]) && !heldpoke
      pbDisplay(_INTL("That's your last Pokémon!"))
    elsif !heldpoke && @storage[box, index].mail
      pbDisplay(_INTL("Please remove the Mail."))
    elsif !@storage[box, index] && heldpoke.mail
      pbDisplay(_INTL("Please remove the Mail."))
    else
      destbox = @storage.currentBox
      loop do
        firstfree = @storage.pbFirstFreePos(destbox)
        break if firstfree >= 0

        destbox = @scene.pbChooseBox(_INTL("Box \"{1}\" is full. Choose a different Box to deposit.", @storage[destbox].name), destbox)
        return if destbox < 0
      end
      @scene.pbStore(selected, heldpoke, destbox, @storage.pbFirstFreePos(destbox))
      if heldpoke
        @storage.pbMoveCaughtToBox(heldpoke, destbox)
        @heldpkmn = nil
      else
        @storage.pbMove(destbox, -1, -1, index)
      end
      @scene.pbRefresh
    end
  end

  def pbWithdraw(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if box == -1
      raise _INTL("Can't withdraw from party...");
    end

    if @storage.party.nitems >= 6
      pbDisplay(_INTL("Your party's full!"))
      return false
    end
    @scene.pbWithdraw(selected, heldpoke, @storage.party.length)
    if heldpoke
      @storage.pbMoveCaughtToParty(heldpoke)
      @heldpkmn = nil
    else
      @storage.pbMove(-1, -1, box, index)
    end
    @scene.pbRefresh
    @scene.pbUpdateOverlay(selected[1])
    return true
  end

  def pbStoreOrWithdraw(selected, heldpoke)
    if selected[0] == -1
      pbStore(selected, heldpoke)
    else
      pbWithdraw(selected, heldpoke)
    end
  end

  def pbDisplay(message)
    @scene.pbDisplay(message)
  end

  def pbSummary(selected, heldpoke)
    @scene.pbSummary(selected, heldpoke)
  end

  def pbHold(selected, multimove = false)
    if selected[0] >= 0 && multimove
      ## Multi Select start ##
      aMultiSelectedMons = @scene.aGetMultiSelArray
      bShouldAdd = true
      aTemp = []
      for aEntry in aMultiSelectedMons
        bNotFound = true

        if aEntry[0] == selected[0] # Box
          if aEntry[1] == selected[1] # Index
            bNotFound = false
            bShouldAdd = false
          end
        end

        aTemp.push(aEntry) if bNotFound
      end

      aTemp.push(selected) if bShouldAdd

      @scene.aUpdateMultiSelArray(aTemp)

      @scene.aUpdateMultiSelectOverlay()
      ## Multi Select end ##
    else
      box = selected[0]
      index = selected[1]
      if box == -1 && pbAble?(@storage[box, index]) && pbAbleCount <= 1
        pbDisplay(_INTL("That's your last Pokémon!"))
        return
      end
      @scene.pbHold(selected) unless selected[0] == -2
      @heldpkmn = @storage[box, index]
      @storage.pbDelete(box, index)
      @scene.pbRefresh
    end
  end

  def pbSwap(selected)
    box = selected[0]
    index = selected[1]
    if !@storage[box, index]
      raise _INTL("Position {1},{2} is empty...", box, index)
    end

    if box == -1 && pbAble?(@storage[box, index]) && pbAbleCount <= 1 && !pbAble?(@heldpkmn)
      pbDisplay(_INTL("That's your last Pokémon!"))
      return false
    end
    if box != -1 && @heldpkmn.mail
      pbDisplay(_INTL("Please remove the mail."))
      return false
    end
    @heldpkmn.heal if box >= 0 && !$game_switches[:Nuzlocke_Mode]
    tmp = @storage[box, index]
    @storage[box, index] = @heldpkmn
    @heldpkmn = tmp
    @scene.pbSwap(selected, @heldpkmn)
    @scene.pbRefresh
    return true
  end

  def pbPlace(selected)
    box = selected[0]
    index = selected[1]
    if @storage[box, index]
      raise _INTL("Position {1},{2} is not empty...", box, index)
    end

    if box != -1 && index >= @storage.maxPokemon(box)
      pbDisplay(_INTL("Can't place that there."))
      return
    end
    if box != -1 && @heldpkmn.mail
      pbDisplay(_INTL("Please remove the mail."))
      return
    end
    @heldpkmn.heal if box >= 0 && !$game_switches[:Nuzlocke_Mode]
    @scene.pbPlace(selected, @heldpkmn)
    @storage[box, index] = @heldpkmn
    if box == -1
      @storage.party.compact!
    end
    @scene.pbRefresh
    @heldpkmn = nil
  end

  def pbItem(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    pkmn = heldpoke ? heldpoke : @storage[box, index]
    return if pkmn.isEgg?
    if !pkmn.item.nil? # Take
      pbTakeItem(pkmn, self)
      @scene.pbHardRefresh
    else # Give
      item = @scene.pbChooseItem($PokemonBag)
      if !item.nil?
        pbGiveItem(item, pkmn, self, @scene, zcrystal: pbIsZCrystal?(item))
        @scene.pbHardRefresh
      end
    end
  end

  def pbHeldPokemon
    return @heldpkmn
  end

=begin
  commands=[
     _INTL("WITHDRAW POKéMON"),
     _INTL("DEPOSIT POKéMON"),
     _INTL("MOVE POKéMON"),
     _INTL("MOVE ITEMS"),
     _INTL("SEE YA!")
  ]
  helptext=[
     _INTL("Move Pokémon stored in boxes to your party."),
     _INTL("Store Pokémon in your party in Boxes."),
     _INTL("Organize the Pokémon in Boxes and in your party."),
     _INTL("Move items held by any Pokémon in a Box and your party."),
     _INTL("Return to the previous menu."),
  ]
  command=pbShowCommandsAndHelp(commands,helptext)
=end

  def pbShowCommands(msg, commands)
    return @scene.pbShowCommands(msg, commands)
  end

  def pbBoxCommands(mode)
    commands, _helptexts, actions = MenuHandlers.build(:box_commands_menu, self, mode)

    command = pbShowCommands(_INTL("What do you want to do?"), commands)

    if command >= 0 && command < actions.length
      actions[command].call(self, mode)
    end
  end

  def currentBoxFullySelected?()
    curboxindex = $PokemonStorage.currentBox
    curbox = $PokemonStorage[curboxindex]
    return false if curbox.empty?

    selected = @scene.aGetMultiSelArray
    curbox.pokemon.each_with_index do |item, i|
      return false if !item.nil? && !selected.include?([curboxindex, i])
    end
    return true
  end

  def selectAll()
    selecting = !currentBoxFullySelected?()
    $PokemonStorage[$PokemonStorage.currentBox].pokemon.each_with_index do |item, i|
      next if item.nil?
      next if selecting && @scene.aGetMultiSelArray.include?([$PokemonStorage.currentBox, i])

      pbHold([$PokemonStorage.currentBox, i], true)
    end
  end

  def pbChoosePokemon(party = nil)
    @heldpkmn = nil
    @scene.pbStartBox(self, 2)
    retval = nil
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected && selected[0] == -3 # Close box
        if pbConfirm(_INTL("Exit from the Box?"))
          break
        else
          next
        end
      end
      if selected == nil
        if pbConfirm(_INTL("Continue Box operations?"))
          next
        else
          break
        end
      elsif selected[0] == -4 # Box name
        pbBoxCommands(-1)
      else
        pokemon = @storage[selected[0], selected[1]]
        next if !pokemon

        helptext = _INTL("{1} is selected.", pokemon.name)

        commands, _helptexts, actions = MenuHandlers.build(:storage_mon_menu, self, -1, selected, pokemon, nil)

        command = pbShowCommands(helptext, commands)
        if command >= 0 && command < actions.length
          res = actions[command].call(self, -1, selected, pokemon, nil)
          if res == :break_with_selected
            retval = selected
            break
          end
        end
      end
    end
    @scene.pbCloseBox
    return retval
  end

  def pbNameContains(aFoundName, aNewName)
    iMax = aFoundName.length - aNewName.length
    for i in 0..iMax
      bMatches = true
      for i2 in 0...aNewName.length
        if aFoundName[i + i2] != aNewName[i2]
          bMatches = false
          break
        end
      end
      return true if bMatches
    end
    return false
  end

  def pbFindPokemon
    commands, searchtypes = BoxSearchHandler.commands(self)

    searchtype = pbShowCommands(_INTL("What do you want to find?"), commands)

    return if searchtype == -1 # Cancel

    searchtype = searchtypes[searchtype]

    if searchtype == nil
      BoxSearchHandler.clearSearch
      @scene.pbUpdateColor
    else

      params = searchtype.gatherParameters

      return unless params # nil params means don't search

      commandsFound = []
      boxesFound = []
      boxesCount = []
      # Boxes
      for box in 0...$PokemonStorage.maxBoxes
        foundAny = false
        for i in 0...$PokemonStorage[box].length
          poke = $PokemonStorage[box, i]
          next unless poke && searchtype.filter(self, poke, params)
          if foundAny
            boxesCount[-1] += 1
          else
            commandsFound.push($PokemonStorage[box].name)
            boxesFound.push(box)
            boxesCount.push(1)
            foundAny = true
          end
        end
      end
      # Party
      foundAny = false
      for poke in $PokemonStorage.party
        next unless poke && searchtype.filter(self, poke, params)
        if foundAny
          boxesCount[-1] += 1
        else
          commandsFound.push(_INTL("Party"))
          boxesFound.push(:Party)
          boxesCount.push(1)
          foundAny = true
        end
      end

      if !commandsFound.empty?
        totalMatches = boxesCount.sum
        if totalMatches == 1
          resultStr = _INTL("1 match found in {1}.", commandsFound[0])
        elsif commandsFound.length == 1
          resultStr = _INTL("{1} matches found in {2}.", totalMatches, commandsFound[0])
        else
          partyStr = !boxesFound.include?(:Party) ? nil : _INTL("Party")
          onlyBoxes = boxesFound - [:Party]
          boxStr = onlyBoxes.empty? ? nil : (onlyBoxes.length == 1 ? _INTL("1 Box") : _INTL("{1} Boxes", onlyBoxes.length))
          joinedStr = joinStrings([partyStr, boxStr].compact)
          resultStr = _INTL("{1} matches found in {2}.", totalMatches, joinedStr)
        end

        BoxSearchHandler.setSearch { |p| searchtype.filter(self, p, params) }
        @scene.pbUpdateColor

        for i in 0...commandsFound.length
          commandsFound[i] = "#{commandsFound[i]} (#{boxesCount[i]})"
        end
        cmd = pbShowCommands(resultStr, commandsFound)
        if cmd >= 0
          box = boxesFound[cmd]
          box == :Party ? @scene.pbPartyMenu(@storage.party) : @scene.pbJumpToBox(box)
        end
      else
        pbDisplay(_INTL("No match was found."))
      end
    end
  end

  # Sorting derived from VeryBasic's sorting mod
  def pbSortPokemon(minbox = $PokemonStorage.currentBox, maxbox = $PokemonStorage.currentBox)
    pcempty = true

    boxes = minbox <= maxbox ? (minbox..maxbox).to_a : (minbox...STORAGEBOXES).to_a + (0..maxbox).to_a

    for box in boxes
      for slot in 0...$PokemonStorage[box].length
        if $PokemonStorage[box, slot]
          pcempty = false
          break
        end
      end
    end
    return -2 if pcempty

    commands, _helptexts, actions = MenuHandlers.build(:storage_sort_menu)

    if minbox == maxbox
      message = _INTL("How would you like to sort\n{1}?", $PokemonStorage[minbox].name)
    else
      message = _INTL("How would you like to sort\n{1} to {2}?", $PokemonStorage[minbox].name, $PokemonStorage[maxbox].name)
    end
    command = pbShowCommands(message, commands)
    return -1 if command < 0 || command >= actions.length

    pokemon = []
    eggs = []
    for box in boxes
      for slot in 0...$PokemonStorage[box].length
        poke = $PokemonStorage[box, slot]
        if poke
          poke.isEgg? ? eggs.push(poke) : pokemon.push(poke)
          $PokemonStorage[box, slot] = nil
        end
      end
    end

    default = ->(x, y) { 2 * (x.dexnum <=> y.dexnum) + (x.form <=> y.form) }

    # Retrieve the sorting block from the registry and execute the sort
    sort_proc = actions[command].call(default)
    pokes = pokemon.sort(&sort_proc)

    eggs = eggs.sort { |x, y| default.call(x, y) }
    pokes += eggs

    for box in boxes
      for slot in 0...$PokemonStorage[box].length
        $PokemonStorage[box, slot] = pokes.shift
        break if pokes.empty?
      end
    end
  end

  def pbStartScreen(mode)
    @heldpkmn = nil
    if mode == 2
      ### WITHDRAW ###################################################################
      @scene.pbStartBox(self, mode)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected && selected[0] == -3 # Close box
          if pbConfirm(_INTL("Exit from the Box?"))
            break
          else
            next
          end
        end
        if selected && selected[0] == -2 # Party Pokémon
          pbDisplay(_INTL("Which one will you take?"))
          next
        end
        if selected && selected[0] == -4 # Box name
          pbBoxCommands(mode)
          next
        end
        if selected == nil
          if pbConfirm(_INTL("Continue Box operations?"))
            next
          else
            break
          end
        else
          pokemon = @storage[selected[0], selected[1]]
          next if !pokemon

          helptext = _INTL("{1} is selected.", pokemon.name)

          commands, _helptexts, actions = MenuHandlers.build(:storage_mon_menu, self, mode, selected, pokemon, nil)

          command = pbShowCommands(helptext, commands)
          if command >= 0 && command < actions.length
            actions[command].call(self, mode, selected, pokemon, nil)
          end
        end
      end
      @scene.pbCloseBox
    elsif mode == 1
      ### DEPOSIT ####################################################################
      @scene.pbStartBox(self, mode)
      loop do
        selected = @scene.pbSelectParty(@storage.party)
        if selected == -3 # Close box
          if pbConfirm(_INTL("Exit from the Box?"))
            break
          else
            next
          end
        end
        if selected < 0
          if pbConfirm(_INTL("Continue Box operations?"))
            next
          else
            break
          end
        else
          pokemon = @storage[-1, selected]
          next if !pokemon

          # Wrap the integer in an array to match the expected format
          selected_array = [-1, selected]
          helptext = _INTL("{1} is selected.", pokemon.name)

          commands, _helptexts, actions = MenuHandlers.build(:storage_mon_menu, self, mode, selected_array, pokemon, nil)

          command = pbShowCommands(helptext, commands)
          if command >= 0 && command < actions.length
            actions[command].call(self, mode, selected_array, pokemon, nil)
          end
        end
      end
      @scene.pbCloseBox
    elsif mode == 0
      ### MOVE #######################################################################
      @scene.pbStartBox(self, mode)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected && selected[0] == -3 # Close box
          if pbHeldPokemon
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          if pbConfirm(_INTL("Exit from the Box?"))
            break
          else
            next
          end
        end
        if selected == nil
          if pbHeldPokemon
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          if pbConfirm(_INTL("Continue Box operations?"))
            next
          else
            break
          end
        elsif selected[0] == -4 # Box name
          if selected[1] == -1
            pbBoxCommands(mode)
          elsif selected[1] == 6
            # Multi-Select entire box
            selectAll()
          end
        elsif selected[0] == -2 && selected[1] == -1
          next
        elsif selected.length > 2
          # Shortcut keys
          pokemon = @storage[selected[0], selected[1]]
          case selected.pop
            when 1 # Move
              if @heldpkmn && pokemon
                pbSwap(selected)
              elsif @heldpkmn
                pbPlace(selected)
              elsif pokemon
                pbHold(selected)
              end
            when 2 # Item
              heldpoke = pbHeldPokemon
              next if !pokemon && !heldpoke

              pbItem(selected, @heldpkmn)
            when 3 # Summary
              heldpoke = pbHeldPokemon
              next if !pokemon && !heldpoke

              pbSummary(selected, @heldpkmn)
            when 4 # Deposit / Withdraw
              heldpoke = pbHeldPokemon
              next if !pokemon && !heldpoke

              if selected[0] == -1
                pbStore(selected, @heldpkmn)
              else
                pbWithdraw(selected, @heldpkmn)
              end
            when 5 # Open party
              @scene.pbPartyMenu(@storage.party)
            when 6 # Multi-Select
              next if !pokemon

              pbHold(selected, true)
          end
          next
        else
          pokemon = @storage[selected[0], selected[1]]
          heldpoke = pbHeldPokemon
          next if !pokemon && !heldpoke

          if @scene.quickswap
            if @heldpkmn
              pokemon ? pbSwap(selected) : pbPlace(selected)
            else
              pbHold(selected)
            end
          else
            helptext = heldpoke ? _INTL("{1} is selected.", heldpoke.name) : _INTL("{1} is selected.", pokemon.name)

            commands, _helptexts, actions = MenuHandlers.build(:storage_mon_menu, self, mode, selected, pokemon, heldpoke)

            command = pbShowCommands(helptext, commands)
            if command >= 0 && command < actions.length
              actions[command].call(self, mode, selected, pokemon, heldpoke)
            end
          end
        end
      end
      @scene.pbCloseBox
    elsif mode == 3
      @scene.pbStartBox(self, mode)
      @scene.pbCloseBox
    end
  end

  def pbChooseMove(pokemon, helptext)
    movenames = []
    for i in pokemon.moves
      break if i.move.nil?

      if i.totalpp == 0
        movenames.push(_INTL("{1} (PP: ---)", getMoveName(i.move), i.pp, i.totalpp))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})", getMoveName(i.move), i.pp, i.totalpp))
      end
    end
    return @scene.pbShowCommands(helptext, movenames)
  end

  def duplicatePokemon(pkmn, selected)
    if pbConfirm(_INTL("Are you sure you want to copy this Pokémon?"))
      clonedpkmn = deep_copy(pkmn)
      if @storage.pbMoveCaughtToParty(clonedpkmn)
        if selected[0] != -1
          pbDisplay(_INTL("The duplicated Pokémon was moved to your party."))
        end
      else
        oldbox = @storage.currentBox
        newbox = @storage.pbStoreCaught(clonedpkmn)
        if newbox < 0
          pbDisplay(_INTL("All boxes are full."))
        elsif newbox != oldbox
          pbDisplay(_INTL("The duplicated Pokémon was moved to box \"{1}.\"", @storage[newbox].name))
          @storage.currentBox = oldbox
        end
      end
      @scene.pbHardRefresh
      return
    end
  end

  def deletePokemon(pkmnid, selected, heldpoke)
    if pbConfirm(_INTL("Are you sure you want to delete this Pokémon?"))
      @scene.pbRelease(selected, heldpoke)
      if heldpoke
        @heldpkmn = nil
      else
        @storage.pbDelete(selected[0], selected[1])
      end
      @scene.pbRefresh
      pbDisplay(_INTL("The Pokémon was deleted."))
      @scene.pbUpdateOverlay(selected[1])
      return
    end
  end

  def selectPokemon(index)
    pokemon = @storage[@currentbox, index]
    if !pokemon
      return nil
    end
  end
end

class Interpolator
  ZOOM_X = 1
  ZOOM_Y = 2
  X = 3
  Y = 4
  OPACITY = 5
  COLOR = 6
  WAIT = 7

  def initialize
    @tweening = false
    @tweensteps = []
    @sprite = nil
    @frames = 0
    @step = 0
  end

  def tweening?
    return @tweening
  end

  def tween(sprite, items, frames)
    @tweensteps = []
    if sprite && !sprite.disposed? && frames > 0
      @frames = frames
      @step = 0
      @sprite = sprite
      for item in items
        case item[0]
          when ZOOM_X
            @tweensteps[item[0]] = [sprite.zoom_x, item[1] - sprite.zoom_x]
          when ZOOM_Y
            @tweensteps[item[0]] = [sprite.zoom_y, item[1] - sprite.zoom_y]
          when X
            @tweensteps[item[0]] = [sprite.x, item[1] - sprite.x]
          when Y
            @tweensteps[item[0]] = [sprite.y, item[1] - sprite.y]
          when OPACITY
            @tweensteps[item[0]] = [sprite.opacity, item[1] - sprite.opacity]
          when COLOR
            @tweensteps[item[0]] = [sprite.color.clone, Color.new(
              item[1].red - sprite.color.red,
              item[1].green - sprite.color.green,
              item[1].blue - sprite.color.blue,
              item[1].alpha - sprite.color.alpha
            )]
        end
      end
      @tweening = true
    end
  end

  def update
    if @tweening
      t = (@step * 1.0) / @frames
      for i in 0...@tweensteps.length
        item = @tweensteps[i]
        next if !item

        case i
          when ZOOM_X
            @sprite.zoom_x = item[0] + item[1] * t
          when ZOOM_Y
            @sprite.zoom_y = item[0] + item[1] * t
          when X
            @sprite.x = item[0] + item[1] * t
          when Y
            @sprite.y = item[0] + item[1] * t
          when OPACITY
            @sprite.opacity = item[0] + item[1] * t
          when COLOR
            @sprite.color = Color.new(
              item[0].red + item[1].red * t,
              item[0].green + item[1].green * t,
              item[0].blue + item[1].blue * t,
              item[0].alpha + item[1].alpha * t
            )
        end
      end
      @step += 1
      if @step == @frames
        @step = 0
        @frames = 0
        @tweening = false
      end
    end
  end
end

class PokemonBoxIcon < IconSprite
  def initialize(pokemon, viewport = nil)
    @adjusted_x = -(AURA_SPRITE_OFFSET / 2)
    @adjusted_y = -(AURA_SPRITE_OFFSET / 2)
    @logical_x = 0
    @logical_y = 0
    super(0, 0, viewport)
    @release = Interpolator.new
    @startRelease = false
    @pokemon = pokemon
    if pokemon
      self.bitmap = pbPokemonIconBitmap(pokemon)
    end
    self.src_rect = Rect.new(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
  end

  def x
    @logical_x
  end

  def y
    @logical_y
  end

  def x=(value)
    @logical_x = value
    super(@logical_x + @adjusted_x)
  end

  def y=(value)
    @logical_y = value
    super(@logical_y + @adjusted_y)
  end

  def release
    self.ox = 32
    self.oy = 32
    self.x += 32
    self.y += 32
    @release.tween(
      self,
      [
        [Interpolator::ZOOM_X, 0],
        [Interpolator::ZOOM_Y, 0],
        [Interpolator::OPACITY, 0]
      ],
      100
    )
    @startRelease = true
  end

  def releasing?
    return @release.tweening?
  end

  def update
    super
    @release.update
    self.color = Color.new(0, 0, 0, 0)
    dispose if @startRelease && !releasing?
  end
end

class PokemonBoxArrow < SpriteWrapper
  attr_accessor :quickswap

  def initialize(viewport = nil)
    super(viewport)
    @frame = 0
    @holding = false
    @updating = false
    @quickswap = false
    @grabbingState = 0
    @placingState = 0
    @heldpkmn = nil
    @handsprite = ChangelingSprite.new(0, 0, viewport)
    @handsprite.addBitmap("point1", "Graphics/Pictures/Storage/boxpoint1")
    @handsprite.addBitmap("point2", "Graphics/Pictures/Storage/boxpoint2")
    @handsprite.addBitmap("grab", "Graphics/Pictures/Storage/boxgrab")
    @handsprite.addBitmap("fist", "Graphics/Pictures/Storage/boxfist")
    @handsprite.addBitmap("point1q", "Graphics/Pictures/Storage/boxpoint1_q")
    @handsprite.addBitmap("point2q", "Graphics/Pictures/Storage/boxpoint2_q")
    @handsprite.addBitmap("grabq", "Graphics/Pictures/Storage/boxgrab_q")
    @handsprite.addBitmap("fistq", "Graphics/Pictures/Storage/boxfist_q")
    @handsprite.changeBitmap("fist")
    @spriteX = self.x
    @spriteY = self.y
  end

  def dispose
    @handsprite.dispose
    @heldpkmn.dispose if @heldpkmn
    super
  end

  def heldPokemon
    @heldpkmn = nil if @heldpkmn && @heldpkmn.disposed?
    @holding = false if !@heldpkmn
    return @heldpkmn
  end

  def visible=(value)
    super
    @handsprite.visible = value
    sprite = heldPokemon
    sprite.visible = value if sprite
  end

  def color=(value)
    super
    @handsprite.color = value
    sprite = heldPokemon
    sprite.color = value if sprite
  end

  def holding?
    return self.heldPokemon && @holding
  end

  def grabbing?
    return @grabbingState > 0
  end

  def placing?
    return @placingState > 0
  end

  def x=(value)
    super
    @handsprite.x = self.x
    @spriteX = x if !@updating
    heldPokemon.x = self.x if holding?
  end

  def y=(value)
    super
    @handsprite.y = self.y
    @spriteY = y if !@updating
    heldPokemon.y = self.y + 16 if holding?
  end

  def z=(value)
    super
    @handsprite.z = value
  end

  def setSprite(sprite)
    if holding?
      @heldpkmn = sprite
      @heldpkmn.viewport = self.viewport if @heldpkmn
      @heldpkmn.z = 1 if @heldpkmn
      @holding = false if !@heldpkmn
      self.z = 2
    end
  end

  def deleteSprite
    @holding = false
    if @heldpkmn
      @heldpkmn.dispose
      @heldpkmn = nil
    end
  end

  def grab(sprite)
    @grabbingState = 1
    @heldpkmn = sprite
    @heldpkmn.viewport = self.viewport
    @heldpkmn.z = 1
    self.z = 2
  end

  def place
    @placingState = 1
  end

  def release
    @heldpkmn.release if @heldpkmn
  end

  def update
    @updating = true
    super
    heldpkmn = heldPokemon
    heldpkmn.update if heldpkmn
    @handsprite.update
    @holding = false if !heldpkmn
    if @grabbingState > 0
      if @grabbingState <= 8
        @handsprite.changeBitmap(@quickswap ? "grabq" : "grab")
        self.y = @spriteY + (@grabbingState) * 2
        @grabbingState += 1
      elsif @grabbingState <= 16
        @holding = true
        @handsprite.changeBitmap(@quickswap ? "fistq" : "fist")
        self.y = @spriteY + (16 - @grabbingState) * 2
        @grabbingState += 1
      else
        @grabbingState = 0
      end
    elsif @placingState > 0
      if @placingState <= 8
        @handsprite.changeBitmap(@quickswap ? "fistq" : "fist")
        self.y = @spriteY + @placingState * 2
        @placingState += 1
      elsif @placingState <= 16
        @holding = false
        @heldpkmn = nil
        @handsprite.changeBitmap(@quickswap ? "grabq" : "grab")
        self.y = @spriteY + (16 - @placingState) * 2
        @placingState += 1
      else
        @placingState = 0
      end
    elsif holding?
      @handsprite.changeBitmap(@quickswap ? "fistq" : "fist")
    else
      self.x = @spriteX
      self.y = @spriteY
      if (@frame / 20) == 0
        @handsprite.changeBitmap(@quickswap ? "point1q" : "point1")
      else
        @handsprite.changeBitmap(@quickswap ? "point2q" : "point2")
      end
    end
    @frame += 1
    @frame = 0 if @frame == 40
    @updating = false
  end
end

class PokemonBoxPartySprite < SpriteWrapper
  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    @pokemonsprites.compact!
    refresh
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index, sprite)
    @pokemonsprites[index] = sprite
    @pokemonsprites.compact!
    refresh
  end

  def grabPokemon(index, arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      @pokemonsprites.compact!
      refresh
    end
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].color = pbSrcOver(@pokemonsprites[i].color, value)
      end
    end
    refresh
  end

  def visible=(value)
    super
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
    refresh
  end

  def pbSpriteTone(pkmn)
    return Tone.new(0, 0, 0)
  end

  def pbSpriteColor(pkmn)
    if pkmn && BoxSearchHandler.hasSearch? && !BoxSearchHandler.matchesSearch?(pkmn)
      return Color.new(100, 100, 100, 224)
    else
      return Color.new(0, 0, 0, 0)
    end
  end

  def pbUpdateColor
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        pokemon = @party[i]
        if pokemon
          @pokemonsprites[i].tone = pbSpriteTone(pokemon)
          @pokemonsprites[i].color = pbSpriteColor(pokemon)
        end
      end
    end
  end

  def initialize(party, viewport = nil)
    super(viewport)
    @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/boxpartytab")
    @pokemonsprites = []
    @party = party
    for i in 0...6
      @pokemonsprites[i] = nil
      pokemon = @party[i]
      if pokemon
        @pokemonsprites[i] = PokemonBoxIcon.new(pokemon, viewport)
      end
    end
    @contents = BitmapWrapper.new(172, 352)
    self.bitmap = @contents
    self.x = 182
    self.y = Graphics.height - 352
    pbUpdateColor
    refresh
  end

  def dispose
    for i in 0...6
      @pokemonsprites[i].dispose if @pokemonsprites[i]
    end
    @contents.dispose
    @boxbitmap.dispose
    super
  end

  def refresh
    @contents.blt(0, 0, @boxbitmap.bitmap, Rect.new(0, 0, 172, 352))
    xvalues = [16, 92, 16, 92, 16, 92]
    yvalues = [0, 16, 64, 80, 128, 144]
    for j in 0...6
      @pokemonsprites[j] = nil if @pokemonsprites[j] && @pokemonsprites[j].disposed?
    end
    @pokemonsprites.compact!
    for j in 0...6
      sprite = @pokemonsprites[j]
      if sprite && !sprite.disposed?
        sprite.viewport = self.viewport
        sprite.z = 0
        sprite.x = self.x + xvalues[j]
        sprite.y = self.y + yvalues[j]
      end
    end
  end

  def update
    super
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].update
      end
    end
    pbUpdateColor
  end
end

class MosaicPokemonSprite < PokemonSprite
  def initialize(*args)
    super(*args)
    @mosaic = 0
    @inrefresh = false
    @mosaicbitmap = nil
    @mosaicbitmap2 = nil
    @oldbitmap = self.bitmap
  end

  attr_reader :mosaic

  def mosaic=(value)
    @mosaic = value
    @mosaic = 0 if @mosaic < 0
    mosaicRefresh(@oldbitmap)
  end

  def dispose
    super
    @mosaicbitmap.dispose if @mosaicbitmap
    @mosaicbitmap = nil
    @mosaicbitmap2.dispose if @mosaicbitmap2
    @mosaicbitmap2 = nil
  end

  def bitmap=(value)
    super
    mosaicRefresh(value)
  end

  def mosaicRefresh(bitmap)
    return if @inrefresh

    @inrefresh = true
    @oldbitmap = bitmap
    if @mosaic <= 0 || !@oldbitmap
      @mosaicbitmap.dispose if @mosaicbitmap
      @mosaicbitmap = nil
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap2 = nil
      self.bitmap = @oldbitmap
    else
      newWidth = [(@oldbitmap.width / @mosaic), 1].max
      newHeight = [(@oldbitmap.height / @mosaic), 1].max
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap = pbDoEnsureBitmap(@mosaicbitmap, newWidth, newHeight)
      @mosaicbitmap.clear
      @mosaicbitmap2 = pbDoEnsureBitmap(@mosaicbitmap2, @oldbitmap.width, @oldbitmap.height)
      @mosaicbitmap2.clear
      @mosaicbitmap.stretch_blt(Rect.new(0, 0, newWidth, newHeight), @oldbitmap, @oldbitmap.rect)
      @mosaicbitmap2.stretch_blt(
        Rect.new(
          -@mosaic / 2 + 1, -@mosaic / 2 + 1,
          @mosaicbitmap2.width, @mosaicbitmap2.height
        ),
        @mosaicbitmap, Rect.new(0, 0, newWidth, newHeight)
      )
      self.bitmap = @mosaicbitmap2
    end
    @inrefresh = false
  end
end

class AutoMosaicPokemonSprite < MosaicPokemonSprite
  def update
    super
    self.mosaic -= 1
  end
end

class PokemonBoxSprite < SpriteWrapper
  attr_accessor :refreshBox
  attr_accessor :refreshSprites

  BOXNAME_OFFSET = 8

  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    refresh
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index, sprite)
    @pokemonsprites[index] = sprite
    refresh
  end

  def grabPokemon(index, arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      refresh
    end
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    if @refreshSprites
      for i in 0...30
        if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
          @pokemonsprites[i].color = value
        end
      end
    end
    refresh
  end

  def visible=(value)
    super
    for i in 0...30
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
    refresh
  end

  def getBoxBitmap
    if !@bg || @bg != @storage[@boxnumber].background
      curbg = @storage[@boxnumber].background
      if !curbg || curbg.length == 0
        boxid = @boxnumber % 24
        @bg = "box#{boxid}"
      else
        @bg = "#{curbg}"
      end
      @boxbitmap.dispose if @boxbitmap
      @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/#{@bg}")
    end
  end

  def aDoBlt(aBitmap, iIndex)
    aSprite = getPokemon(iIndex)
    @contents.blt(aSprite.x + (aSprite.bitmap.width / 16) - self.x, aSprite.y + (aSprite.bitmap.height / 3) - self.y, aBitmap.bitmap, aBitmap.bitmap.rect)
  end

  def pbSpriteTone(pkmn)
    return Tone.new(0, 0, 0)
  end

  def pbSpriteColor(pkmn)
    if pkmn && BoxSearchHandler.hasSearch? && !BoxSearchHandler.matchesSearch?(pkmn)
      return Color.new(100, 100, 100, 224)
    else
      return Color.new(0, 0, 0, 0)
    end
  end

  def pbUpdateColor
    for i in 0...30
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        pokemon = @storage[@boxnumber, i]
        @pokemonsprites[i].tone = pbSpriteTone(pokemon)
        @pokemonsprites[i].color = pbSpriteColor(pokemon)
      end
    end
  end

  def initialize(storage, boxnumber, viewport = nil)
    super(viewport)
    @storage = storage
    @boxnumber = boxnumber
    @refreshBox = true
    @refreshSprites = true
    @bg = nil
    @boxbitmap = nil
    getBoxBitmap
    @pokemonsprites = []
    for i in 0...30
      @pokemonsprites[i] = nil
      pokemon = @storage[boxnumber, i]
      if pokemon
        @pokemonsprites[i] = PokemonBoxIcon.new(pokemon, viewport)
      else
        @pokemonsprites[i] = PokemonBoxIcon.new(nil, viewport)
      end
    end
    @contents = BitmapWrapper.new(324, 296)
    self.bitmap = @contents
    self.x = 184
    self.y = 18
    pbUpdateColor
    refresh
  end

  def dispose
    if !disposed?
      for i in 0...30
        @pokemonsprites[i].dispose if @pokemonsprites[i]
        @pokemonsprites[i] = nil
      end
      @contents.dispose
      @boxbitmap.dispose
      super
    end
  end

  def refresh
    if @refreshBox
      boxname = @storage[@boxnumber].name
      getBoxBitmap
      @contents.blt(0, 0, @boxbitmap.bitmap, Rect.new(0, 0, 324, 296))
      pbSetSystemFont(@contents)
      widthval = @contents.text_size(boxname).width
      xval = 162 - (widthval / 2)
      pbDrawShadowText(
        @contents, xval, BOXNAME_OFFSET , widthval, 32, boxname,
        Color.new(248, 248, 248), Color.new(40, 48, 48)
      )
      @refreshBox = false
    end
    yval = self.y + 30
    for j in 0...5
      xval = self.x + 10
      for k in 0...6
        sprite = @pokemonsprites[j * 6 + k]
        if sprite && !sprite.disposed?
          sprite.viewport = self.viewport
          sprite.z = 0
          sprite.x = xval
          sprite.y = yval
        end
        xval += 48
      end
      yval += 48
    end
  end

  def update
    super
    for i in 0...30
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].update
      end
    end
    pbUpdateColor
  end
end

class PokemonStorageScene
  BASECOLOR = [Color.new(88, 88, 88), Color.new(168, 184, 184)] # color, shadow
  BLUECOLOR = [Color.new(24, 112, 216), Color.new(136, 168, 208)]
  REDCOLOR = [Color.new(248, 56, 32), Color.new(224, 152, 144)]

  POKENAME_OFFSET = [10, 8, :left] # x, y, text alignment
  POKELV_OFFSET = [36, 234]
  POKEGENDER_OFFSET = [148, 8]
  POKETYPE_OFFSET = [18, 272, 88, 52] # x, y, x type2, x singletype
  POKEAB_OFFSET = [84, 306]
  POKEITEM_OFFSET = [84, 342]
  POKESHINY_OFFSET = [156, 198]

  MARKING_CONSTS = [98, 250]

  BOX_SWITCH_SPEED = 56 # Boxes move by a total of 336 so this number should divide 336
  PARTY_TOGGLE_SPEED = 32 # Party tab moves by a total of 352 so this number should divide 352

  attr_reader :quickswap

  def initialize
    @command = 0
  end

  def pbStartBox(screen, command)
    @screen = screen
    @storage = screen.storage
    @bgviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @bgviewport.z = 99999
    @boxviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @boxviewport.z = 99999
    @boxsidesviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @boxsidesviewport.z = 99999
    @arrowviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @arrowviewport.z = 99999
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @selection = 0
    @quickswap = false
    @sprites = {}
    @choseFromParty = false
    @command = command
    addBackgroundPlane(@sprites, "background", "Storage/boxbg", @bgviewport)
    @sprites["box"] = PokemonBoxSprite.new(@storage, @storage.currentBox, @boxviewport)
    @sprites["boxsides"] = IconSprite.new(0, 0, @boxsidesviewport)
    @sprites["boxsides"].setBitmap("Graphics/Pictures/Storage/boxsides")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @boxsidesviewport)
    @sprites["pokemon"] = AutoMosaicPokemonSprite.new(@boxsidesviewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party, @boxsidesviewport)
    if command != 1 # Drop down tab only on Deposit
      @sprites["boxparty"].x = 182
      @sprites["boxparty"].y = Graphics.height
    end
    @sprites["arrow"] = PokemonBoxArrow.new(@arrowviewport)
    @sprites["arrow"].z += 1
    if command != 1
      pbSetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection)
      pbSetMosaic(@selection)
    else
      pbPartySetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection, @storage.party)
      pbSetMosaic(@selection)
    end
    pbFadeInAndShow(@sprites)
  end

  def update
    Graphics.update
  end

  def pbCloseBox
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @boxviewport.dispose
    @boxsidesviewport.dispose
    @arrowviewport.dispose
    BoxSearchHandler.clearSearch
  end

  def pbSetArrow(arrow, selection)
    case selection
      when -1, -4, -5 # Box name, move left, move right
        arrow.y = -16
        arrow.x = 157 * 2
      when -2 # Party Pokémon
        arrow.y = 143 * 2
        arrow.x = 119 * 2
      when -3 # Close Box
        arrow.y = 143 * 2
        arrow.x = 207 * 2
      else
        arrow.x = (97 + 24 * (selection % 6)) * 2
        arrow.y = (8 + 24 * (selection / 6)) * 2
    end
  end

  def pbChangeSelection(key, selection)
    case key
      when Input::UP
        if selection == -1 # Box name
          selection = -2
        elsif selection == -2 # Party
          selection = 25
        elsif selection == -3 # Close Box
          selection = 28
        else
          selection -= 6
          selection = -1 if selection < 0
        end
      when Input::DOWN
        if selection == -1 # Box name
          selection = 2
        elsif selection == -2 # Party
          selection = -1
        elsif selection == -3 # Close Box
          selection = -1
        else
          selection += 6
          selection = -2 if selection == 30 || selection == 31 || selection == 32
          selection = -3 if selection == 33 || selection == 34 || selection == 35
        end
      when Input::RIGHT
        if selection == -1 # Box name
          selection = -5 # Move to next box
        elsif selection == -2
          selection = -3
        elsif selection == -3
          selection = -2
        else
          selection += 1
          selection -= 6 if selection % 6 == 0
        end
      when Input::LEFT
        if selection == -1 # Box name
          selection = -4 # Move to previous box
        elsif selection == -2
          selection = -3
        elsif selection == -3
          selection = -2
        else
          selection -= 1
          selection += 6 if selection == -1 || selection % 6 == 5
        end
    end
    return selection
  end

  def pbPartySetArrow(arrow, selection)
    if selection >= 0
      xvalues = [99, 137, 99, 137, 99, 137, 118]
      yvalues = [0, 8, 32, 40, 64, 72, 114]
      arrow.angle = 0
      arrow.mirror = false
      arrow.ox = 0
      arrow.oy = 0
      arrow.x = xvalues[selection] * 2
      arrow.y = yvalues[selection] * 2
    end
  end

  def pbPartyChangeSelection(key, selection)
    case key
      when Input::LEFT
        selection -= 1
        selection = 6 if selection < 0
      when Input::RIGHT
        selection += 1
        selection = 0 if selection > 6
      when Input::UP
        if selection == 6
          selection = 5
        else
          selection -= 2
          selection = 6 if selection < 0
        end
      when Input::DOWN
        if selection == 6
          selection = 0
        else
          selection += 2
          selection = 6 if selection > 6
        end
    end
    return selection
  end

  def pbSelectPartyInternal(party, depositing)
    selection = @selection
    pbPartySetArrow(@sprites["arrow"], selection)
    pbUpdateOverlay(selection, party)
    pbSetMosaic(selection)
    lastsel = 1
    lastread = nil
    newInputXPress = true
    newInputYPress = false
    newInputAPress = false # Without this, holding Z could deposit multiple members from the party at once
    loop do
      Graphics.update
      Input.update
      key = -1
      if lastread != selection
        if selection == 6 # Return
          tts(_INTL("Return"), true)
        else
          pokemon = @storage.party[selection]
          tts(pbPokemonString(pokemon), true) if pokemon
        end
        lastread = selection
      end
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key >= 0
        pbPlayCursorSE()
        newselection = pbPartyChangeSelection(key, selection)
        if newselection == -1
          return -1 if !depositing
        elsif newselection == -2
          selection = lastsel
        else
          selection = newselection
        end
        pbPartySetArrow(@sprites["arrow"], selection)
        lastsel = selection if selection > 0
        pbUpdateOverlay(selection, party)
        pbSetMosaic(selection)
      end
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::X)
        newInputXPress = true
      elsif Input.trigger?(Input::Y)
        newInputYPress = true
      elsif Input.trigger?(Input::A)
        newInputAPress = true
      elsif Input.time?(Input::X) >= 0.5 && @command == 0 && newInputXPress # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
        newInputXPress = false
      elsif Input.trigger?(Input::C)
        if selection >= 0 && selection < 6
          @selection = selection
          return selection
        elsif selection == 6 # Close Box
          @selection = selection
          return depositing ? -3 : -1
        end
      elsif Input.trigger?(Input::B)
        @selection = selection
        return -1
      elsif Input.triggerex?(Input::F2)
        scene = DefaultControlsScene.new(4)
        pbFadeOutIn(99999) { scene.pbRender }
      end

      if @command == 0 && !depositing && selection < 6
        # Shortcut keys
        if Input.time?(Input::A) >= 0.5 && newInputAPress
          # Deposit / Withdraw
          newInputAPress = false
          return [selection, 4]
        elsif Input.time?(Input::Y) >= 0.5 && newInputYPress
          # Close party
          newInputYPress = false
          @selection = selection
          return -1
        elsif Input.release?(Input::X) && !Input.press?(Input::X) && newInputXPress
          # Move
          return [selection, 1]
        elsif Input.release?(Input::Y) && !Input.press?(Input::Y) && newInputYPress
          # Item
          return [selection, 2]
        elsif Input.trigger?(Input::Z)
          # Summary
          return [selection, 3]
        end
      end
    end
  end

  def pbSelectParty(party)
    return pbSelectPartyInternal(party, true)
  end

  def pbChangeBackground(wp)
    @sprites["box"].refreshSprites = false
    alpha = 0
    Graphics.update
    pbUpdateSpriteHash(@sprites)
    16.times do
      alpha += 16
      Graphics.update
      Input.update
      @sprites["box"].color = Color.new(248, 248, 248, alpha)
      pbUpdateSpriteHash(@sprites)
    end
    @sprites["box"].refreshBox = true
    @storage[@storage.currentBox].background = "box#{wp}"
    4.times do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
    end
    16.times do
      alpha -= 16
      Graphics.update
      Input.update
      @sprites["box"].color = Color.new(248, 248, 248, alpha)
      pbUpdateSpriteHash(@sprites)
    end
    @sprites["box"].refreshSprites = true
  end

  def pbSwitchBoxToRight(newbox)
    iNewBox = newbox # Multi-Select

    newbox = PokemonBoxSprite.new(@storage, newbox, @boxviewport)
    newbox.x = 520
    Graphics.frame_reset
    begin
      Graphics.update
      Input.update
      @sprites["box"].x -= BOX_SWITCH_SPEED
      newbox.x -= BOX_SWITCH_SPEED
      pbUpdateSpriteHash(@sprites)
    end until newbox.x <= 184
    diff = newbox.x - 184
    newbox.x = 184; @sprites["box"].x -= diff
    @sprites["box"].dispose
    @sprites["box"] = newbox

    aUpdateMultiSelectOverlay(iNewBox) # Multi-Select
  end

  def pbSwitchBoxToLeft(newbox)
    iNewBox = newbox # Multi-Select

    newbox = PokemonBoxSprite.new(@storage, newbox, @boxviewport)
    newbox.x = -152
    Graphics.frame_reset
    begin
      Graphics.update
      Input.update
      @sprites["box"].x += BOX_SWITCH_SPEED
      newbox.x += BOX_SWITCH_SPEED
      pbUpdateSpriteHash(@sprites)
    end until newbox.x >= 184
    diff = newbox.x - 184
    newbox.x = 184; @sprites["box"].x -= diff
    @sprites["box"].dispose
    @sprites["box"] = newbox

    aUpdateMultiSelectOverlay(iNewBox) # Multi-Select
  end

  def pbJumpToBox(newbox)
    if @storage.currentBox != newbox
      if newbox > @storage.currentBox
        pbSwitchBoxToRight(newbox)
      else
        pbSwitchBoxToLeft(newbox)
      end
      @storage.currentBox = newbox
    end
  end

  def pbSetQuickSwap(value)
    @quickswap = value
    @sprites["arrow"].quickswap = value
  end

  def pbBoxName
    oldsprites = pbFadeOutAndHide(@sprites)
    ret = pbEnterBoxName(_INTL("Box name?"), 0, 15)
    if ret.length > 0
      @storage[@storage.currentBox].name = ret
    end
    @sprites["box"].refreshBox = true
    pbRefresh
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def pbUpdateOverlay(selection, party = nil)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    pokemon = nil
    if @screen.pbHeldPokemon
      pokemon = @screen.pbHeldPokemon
    elsif selection >= 0
      pokemon = party ? party[selection] : @storage[@storage.currentBox, selection]
    end
    if !pokemon
      @sprites["pokemon"].visible = false
      return
    end
    @sprites["pokemon"].visible = true
    itemname = _INTL("No item")
    if !pokemon.item.nil?
      itemname = getItemName(pokemon.item)
    end
    abilityname = _INTL("No Ability")
    if !pokemon.ability.nil?
      abilityname = getAbilityName(pokemon.ability)
    end
    pokename = pokemon.name
    textstrings = [
      [pokename, POKENAME_OFFSET[0], POKENAME_OFFSET[1], POKENAME_OFFSET[2], BASECOLOR[0], BASECOLOR[1]]
    ]
    if !pokemon.isEgg?
      if Reborn
        textstrings.push([_INTL("Lv.{1}", pokemon.level), POKELV_OFFSET[0], POKELV_OFFSET[1], false, BLUECOLOR[0], BLUECOLOR[1]])
      else
        textstrings.push([_INTL("Lv.{1}", pokemon.level), POKELV_OFFSET[0], POKELV_OFFSET[1], false, BASECOLOR[0], BASECOLOR[1]])
      end
      unless pokemon.isGenderless?
        colors = pokemon.isMale? ? [BLUECOLOR[0], BLUECOLOR[1]] : [REDCOLOR[0], REDCOLOR[1]]
        textstrings.push([genderSign(pokemon.gender), POKEGENDER_OFFSET[0], POKEGENDER_OFFSET[1], false, *colors])
      end
      textstrings.push([abilityname, POKEAB_OFFSET[0], POKEAB_OFFSET[1], 2, BASECOLOR[0], BASECOLOR[1]])
      textstrings.push([itemname, POKEITEM_OFFSET[0], POKEITEM_OFFSET[1], 2, BASECOLOR[0], BASECOLOR[1]])
    end
    pbSetSystemFont(overlay)
    pbDrawTextPositions(overlay, textstrings)
    textstrings.clear
    if !pokemon.isEgg?
      if pokemon.isShiny?
        imagepos = [(["Graphics/Pictures/shiny", POKESHINY_OFFSET[0], POKESHINY_OFFSET[1], 0, 0, -1, -1])]
        pbDrawImagePositions(overlay, imagepos)
      end
      imagepos = []
      if pokemon.type2.nil?
        imagepos.push([sprintf("Graphics/Icons/type%s", pokemon.type1), POKETYPE_OFFSET[3], POKETYPE_OFFSET[1], 0, 0, 64, 28])
      else
        imagepos.push([sprintf("Graphics/Icons/type%s", pokemon.type1), POKETYPE_OFFSET[0], POKETYPE_OFFSET[1], 0, 0, 64, 28])
        imagepos.push([sprintf("Graphics/Icons/type%s", pokemon.type2), POKETYPE_OFFSET[2], POKETYPE_OFFSET[1], 0, 0, 64, 28])
      end
      pbDrawImagePositions(overlay, imagepos)
    end
    if !Desolation
      drawMarkingsSprite(overlay, MARKING_CONSTS[0], MARKING_CONSTS[1], 14, 14, pokemon.markings, 4, 4)
    else
      drawMarkings(overlay, 66, 240, 128, 20, pokemon.markings)
    end
    @sprites["pokemon"].setPokemonBitmap(pokemon)
    pbPositionPokemonSprite(@sprites["pokemon"], 26, 64)
    @sprites["pokemon"].y -= 100 if pokemon.species == :EXEGGUTOR && pokemon.form == 1
  end

  def pbDropDownPartyTab
    begin
      Graphics.update
      Input.update
      @sprites["boxparty"].y -= PARTY_TOGGLE_SPEED
      pbUpdateSpriteHash(@sprites)
    end until @sprites["boxparty"].y <= Graphics.height - 352
  end

  def pbHidePartyTab
    begin
      Graphics.update
      Input.update
      @sprites["boxparty"].y += PARTY_TOGGLE_SPEED
      pbUpdateSpriteHash(@sprites)
    end until @sprites["boxparty"].y >= Graphics.height
  end

  def pbSetMosaic(selection, force: false)
    if !@screen.pbHeldPokemon || force
      if @boxForMosaic != @storage.currentBox || @selectionForMosaic != selection || force
        @sprites["pokemon"].mosaic = 10
        @boxForMosaic = @storage.currentBox
        @selectionForMosaic = selection
      end
    end
  end

  def pbSelectBoxInternal(party)
    selection = @selection
    pbSetArrow(@sprites["arrow"], selection)
    pbUpdateOverlay(selection)
    pbSetMosaic(selection)
    lastread = nil
    newInputXPress = false
    newInputYPress = false
    loop do
      Graphics.update
      Input.update
      if lastread != selection
        if selection == -1 # Box name
          tts(@storage[@storage.currentBox].name, true)
        elsif selection == -2 # Party Pokémon
          tts(_INTL("Party Pokémon"), true)
        elsif selection == -3 # Exit
          tts(_INTL("Exit"), true)
        else
          pokemon = @storage[@storage.currentBox, selection]
          tts(pbPokemonString(pokemon), true) if pokemon
        end
        lastread = selection
      end
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      key = Input::L if Input.repeat?(Input::L)
      key = Input::R if Input.repeat?(Input::R)
      if key >= 0
        pbPlayCursorSE()
        selection = pbChangeSelection(key, selection)
        pbSetArrow(@sprites["arrow"], selection)
        if Input.repeat?(Input::L) || selection == -4
          nextbox = @storage.currentBox == 0 ? @storage.maxBoxes - 1 : @storage.currentBox - 1
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox = nextbox
          tts(@storage[@storage.currentBox].name, true)
        elsif Input.repeat?(Input::R) || selection == -5
          nextbox = @storage.currentBox == @storage.maxBoxes - 1 ? 0 : @storage.currentBox + 1
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox = nextbox
          tts(@storage[@storage.currentBox].name, true)
        end
        selection = -1 if selection == -4 || selection == -5
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      end
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::X)
        newInputXPress = true
      elsif Input.trigger?(Input::Y)
        newInputYPress = true
      elsif Input.time?(Input::X) >= 0.5 && @command == 0 && newInputXPress # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
        newInputXPress = false
      elsif Input.trigger?(Input::C)
        if selection >= 0
          @selection = selection
          return [@storage.currentBox, selection]
        elsif selection == -1 # Box name
          @selection = selection
          return [-4, -1]
        elsif selection == -2 # Party Pokémon
          @selection = selection
          return [-2, -1]
        elsif selection == -3 # Close Box
          @selection = selection
          return [-3, -1]
        end
      elsif Input.trigger?(Input::B)
        @selection = selection
        return nil
      elsif Input.triggerex?(Input::F2)
        scene = DefaultControlsScene.new(4)
        pbFadeOutIn(99999) { scene.pbRender }
      elsif selection == -1 && Input.release?(Input::A) && !Input.press?(Input::A)
        @selection = selection
        # Multi-Select entire box
        return [-4, 6]
      end

      if @command == 0 && selection >= 0
        # Shortcut keys
        if !aGetMultiSelArray.include?([@storage.currentBox, selection])
          if Input.time?(Input::A) >= 0.5
            # Deposit / Withdraw
            return [@storage.currentBox, selection, 4]
          elsif Input.time?(Input::Y) >= 0.5 && newInputYPress
            # Open party
            newInputYPress = false
            return [@storage.currentBox, selection, 5]
          elsif Input.release?(Input::X) && !Input.press?(Input::X) && newInputXPress
            # Move
            return [@storage.currentBox, selection, 1]
          elsif Input.release?(Input::Y) && !Input.press?(Input::Y) && newInputYPress
            # Item
            return [@storage.currentBox, selection, 2]
          elsif Input.trigger?(Input::Z)
            # Summary
            return [@storage.currentBox, selection, 3]
          end
        end
        if Input.release?(Input::A) && !Input.press?(Input::A)
          # Multi-Select
          return [@storage.currentBox, selection, 6]
        end
      end
    end
  end

  def aUpdateMultiSelectOverlay(iBox = @storage.currentBox)
    if defined?(@aMultiSelectedMons)
      @sprites["box"].refreshBox = true
      @sprites["box"].color = Color.new(248, 248, 248, 0)

      if @aMultiSelectedMons.length > 0
        aBitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/MultiBox")

        for aEntry in @aMultiSelectedMons
          if aEntry[0] == iBox
            @sprites["box"].aDoBlt(aBitmap, aEntry[1])
          end
        end
      end
    end
  end

  def aUpdateMultiSelArray(aNewArr)
    @aMultiSelectedMons = aNewArr
  end

  def aGetMultiSelArray
    @aMultiSelectedMons = [] if !defined?(@aMultiSelectedMons)
    return @aMultiSelectedMons
  end

  def pbUpdateColor
    @sprites["box"].pbUpdateColor
  end

  def pbSelectBox(party)
    if @command == 2 # Withdraw
      return pbSelectBoxInternal(party)
    else
      ret = nil
      loop do
        if !@choseFromParty
          ret = pbSelectBoxInternal(party)
          if ret.is_a?(Array) && ret.length > 2
            # Shortcut keys
            @selection = ret[1]
            return ret
          end
        end
        if @choseFromParty || (ret && ret[0] == -2) # Party Pokémon
          if !@choseFromParty
            pbDropDownPartyTab
            @selection = 0
          end
          ret = pbSelectPartyInternal(party, false)
          if ret.is_a?(Array)
            # Shortcut keys
            @selection = ret[0]
            @choseFromParty = true
            return [-1, *ret]
          end
          if ret < 0
            pbHidePartyTab
            @selection = 0
            @choseFromParty = false
            pbUpdateOverlay(@selection)
            pbSetMosaic(@selection, force: true)
          else
            @choseFromParty = true
            return [-1, ret]
          end
        else
          @choseFromParty = false
          ## Multi Select start ##
          if ret != nil && defined?(@aMultiSelectedMons)
            if ret[0] >= 0 && !@storage[ret[0], ret[1]] && @aMultiSelectedMons.length > 0 && !@sprites["arrow"].heldPokemon
              iCh = Kernel.pbMessage(_INTL("What do you want to do?"), [_INTL("Move multiselection"), _INTL("Clear multiselection"), _INTL("Cancel")], 3)

              if iCh != 2
                if iCh == 0
                  iBox = ret[0]
                  iIndex = ret[1]

                  for aEntry in @aMultiSelectedMons
                    bFound = true
                    while @storage[iBox, iIndex]
                      iIndex = iIndex + 1
                      if iIndex >= $PokemonStorage[iBox].length
                        iBox = iBox + 1
                        iIndex = 0

                        if iBox >= $PokemonStorage.maxBoxes
                          Kernel.pbMessage(_INTL("There is not enough space here."))
                          bFound = false
                          break
                        end
                      end
                    end

                    if bFound
                      $PokemonStorage[iBox][iIndex] = $PokemonStorage[aEntry[0]][aEntry[1]]
                      $PokemonStorage[aEntry[0]][aEntry[1]] = nil
                    else
                      break
                    end
                  end

                  @sprites["box"].dispose
                  @sprites["box"] = PokemonBoxSprite.new(@storage, ret[0], @boxviewport)
                end

                @aMultiSelectedMons = []
                @sprites["box"].refreshBox = true
                @sprites["box"].color = Color.new(248, 248, 248, 0)

                ret = [-2, -1] if !@sprites["arrow"].heldPokemon
              end
            end
            if @aMultiSelectedMons.include?(ret)
              numSelected = @aMultiSelectedMons.length
              iCh = Kernel.pbMessage(_INTL("What do you want to do?"), [_INTL("Deselect"), _INTL("Mass Release"), _INTL("Cancel")], 3)
              if iCh == 0
                @screen.pbHold(ret, true)
              elsif iCh == 1
                iCh = Kernel.pbMessage(_INTL("Are you sure you want to mass release {1} Pokémon?", numSelected), [_INTL("Yes"), _INTL("No")], 2)
                if iCh == 0
                  # Mass Release
                  for aEntry in @aMultiSelectedMons
                    @storage.pbDelete(aEntry[0], aEntry[1])
                  end
                  @aMultiSelectedMons = []
                  pbFadeOutIn(99999) {
                    pbHardRefresh
                  }
                  pbDisplay(_INTL("Released {1} Pokémon.", numSelected))
                  $game_variables[37] += numSelected if Reborn # she's watching.
                end
              end
              return [-2, -1]
            end
          end
          ## Multi Select end ##
          return ret
        end
      end
    end
  end

  def pbPartyMenu(party)
    pbDropDownPartyTab
    @choseFromParty = true
    @selection = 0
  end

  def pbHold(selected)
    if selected[0] == -1
      @sprites["boxparty"].grabPokemon(selected[1], @sprites["arrow"])
    else
      @sprites["box"].grabPokemon(selected[1], @sprites["arrow"])
    end
    while @sprites["arrow"].grabbing?
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
    end
    pbSEPlay("storageUp")
  end

  def pbSwap(selected, heldpoke)
    heldpokesprite = @sprites["arrow"].heldPokemon
    boxpokesprite = nil
    if selected[0] == -1
      boxpokesprite = @sprites["boxparty"].getPokemon(selected[1])
    else
      boxpokesprite = @sprites["box"].getPokemon(selected[1])
    end
    if selected[0] == -1
      @sprites["boxparty"].setPokemon(selected[1], heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1], heldpokesprite)
    end
    @sprites["arrow"].setSprite(boxpokesprite)
    pbUpdateOverlay(selected[1])
    pbSetMosaic(selected[1], force: true)
    pbSEPlay("storageUp")
    pbSEPlay("storageDown")
  end

  def pbPlace(selected, heldpoke)
    heldpokesprite = @sprites["arrow"].heldPokemon
    @sprites["arrow"].place
    while @sprites["arrow"].placing?
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
    end
    if selected[0] == -1
      @sprites["boxparty"].setPokemon(selected[1], heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1], heldpokesprite)
    end
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = selected[1]
    pbSEPlay("storageDown")
  end

  def pbChooseItem(bag)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene, bag)
    ret = screen.pbGiveItemScreen
    pbFadeInAndShow(@sprites, oldsprites)
    return ret
  end

  def pbWithdraw(selected, heldpoke, partyindex)
    if !heldpoke
      pbHold(selected)
    end
    pbDropDownPartyTab
    pbPartySetArrow(@sprites["arrow"], partyindex)
    pbPlace([-1, partyindex], heldpoke)
    pbHidePartyTab
  end

  def pbSummary(selected, heldpoke)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummaryScene.new
    screen = PokemonSummary.new(scene)
    if heldpoke
      screen.pbStartScreen([heldpoke], 0)
    elsif selected[0] == -1
      @selection = screen.pbStartScreen(@storage.party, selected[1])
      pbPartySetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection, @storage.party)
    else
      @selection = screen.pbStartScreen(@storage.boxes[selected[0]], selected[1])
      pbSetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection)
    end
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def pbStore(selected, heldpoke, destbox, firstfree)
    if heldpoke
      if destbox == @storage.currentBox
        heldpokesprite = @sprites["arrow"].heldPokemon
        @sprites["box"].setPokemon(firstfree, heldpokesprite)
        @sprites["arrow"].setSprite(nil)
      else
        @sprites["arrow"].deleteSprite
      end
    else
      sprite = @sprites["boxparty"].getPokemon(selected[1])
      if destbox == @storage.currentBox
        @sprites["box"].setPokemon(firstfree, sprite)
        @sprites["boxparty"].setPokemon(selected[1], nil)
      else
        @sprites["boxparty"].deletePokemon(selected[1])
      end
    end
  end

  def drawMarkings(bitmap, x, y, width, height, markings)
    totaltext = ""
    oldfontname = bitmap.font.name
    oldfontsize = bitmap.font.size
    oldfontcolor = bitmap.font.color
    bitmap.font.size = 24
    bitmap.font.name = "Arial"
    PokemonStorage::MARKINGCHARS.each { |item| totaltext += item }
    totalsize = bitmap.text_size(totaltext)
    realX = x + (width / 2) - (totalsize.width / 2)
    realY = y + (height / 2) - (totalsize.height / 2)
    i = 0
    PokemonStorage::MARKINGCHARS.each { |item|
      marked = (markings & (1 << i)) != 0
      bitmap.font.color = (marked) ? Color.new(80, 80, 80) : Color.new(208, 200, 184)
      itemwidth = bitmap.text_size(item).width
      bitmap.draw_text(realX, realY, itemwidth + 2, totalsize.height, item)
      realX += itemwidth
      i += 1
    }
    bitmap.font.name = oldfontname
    bitmap.font.size = oldfontsize
    bitmap.font.color = oldfontcolor
  end

  def drawMarkingsSprite(overlay, x, y, width, height, markings, count, spacing)
    marks = []
    new_x = 0

    for i in 0..count-1
      if (markings & (1 << i)) != 0
        sheet = sprintf("Graphics/Pictures/Storage/mark%d_on", i+1)
      else
        sheet = sprintf("Graphics/Pictures/Storage/mark%d_off", i+1)
      end
      new_x += i==0 ? x : width+spacing
      marks.push([sheet, new_x, y, 0, 0, width, height])
    end

    pbDrawImagePositions(overlay, marks)
  end

  def getMarkingCommands(markings)
    commands = []
    for i in 0...PokemonStorage::MARKINGCHARS.length
      # markname = "<ac><fn=Arial>" + PokemonStorage::MARKINGCHARS[i]
      markname = getMarkingNames[i]
      commands.push((markings & (1 << i) == 0 ? "<o=64>" : "") + markname)
    end
    return commands
  end

  def pbMark(selected, heldpoke)
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.resizeHeightToFit(_INTL("Mark your Pokémon."), Graphics.width - 180)
    msgwindow.text = _INTL("Mark your Pokémon.")
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    pbBottomRight(msgwindow)
    commands = getMarkingCommands(pokemon.markings)
    cmdwindow = Window_AdvancedCommandPokemon.new(commands)
    cmdwindow.viewport = @viewport
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.width = 152
    cmdwindow.height = Graphics.height - msgwindow.height if cmdwindow.height > Graphics.height - msgwindow.height
    cmdwindow.update
    pbBottomRight(cmdwindow)
    cmdwindow.y -= msgwindow.height
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        break # cancel
      end

      if Input.trigger?(Input::C)
        mask = (1 << cmdwindow.index)
        if (pokemon.markings & mask) == 0
          pokemon.markings |= mask
        else
          pokemon.markings &= ~mask
        end
        commands = getMarkingCommands(pokemon.markings)
        cmdwindow.commands = commands
        pbHardRefresh
      end
      pbUpdateSpriteHash(@sprites)
      msgwindow.update
      cmdwindow.update
    end
    msgwindow.dispose
    cmdwindow.dispose
    Input.update
  end

  def pbRefresh
    @sprites["box"].refresh
    @sprites["boxparty"].refresh
  end

  def pbHardRefresh
    oldPartyY = @sprites["boxparty"].y
    @sprites["box"].dispose
    @sprites["boxparty"].dispose
    @sprites["box"] = PokemonBoxSprite.new(@storage, @storage.currentBox, @boxviewport)
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party, @boxsidesviewport)
    @sprites["boxparty"].y = oldPartyY
    pbUpdateOverlay(@selection, @choseFromParty ? @storage.party : nil)
    aUpdateMultiSelectOverlay()
  end

  def pbRelease(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if heldpoke
      sprite = @sprites["arrow"].heldPokemon
    elsif box == -1
      sprite = @sprites["boxparty"].getPokemon(index)
    else
      sprite = @sprites["box"].getPokemon(index)
    end
    if sprite
      sprite.release
      while sprite.releasing?
        Graphics.update
        sprite.update
        pbUpdateSpriteHash(@sprites)
      end
    end
  end

  def pbChooseBox(msg, selected = @storage.currentBox)
    commands = []
    for i in 0...@storage.maxBoxes
      box = @storage[i]
      if box
        commands.push(_ISPRINTF("{1:s} ({2:d}/{3:d})", box.name, box.nitems, box.length))
      end
    end
    return pbShowCommands(msg, commands, selected)
  end

  def pbShowCommands(message, commands, index = 0)
    tts(message)
    ret = 0
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.resizeHeightToFit(message, Graphics.width - 180)
    msgwindow.text = message
    pbBottomRight(msgwindow)
    cmdwindow = Window_CommandPokemon.new(commands)
    cmdwindow.viewport = @viewport
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height = Graphics.height - msgwindow.height if cmdwindow.height > Graphics.height - msgwindow.height
    cmdwindow.update
    cmdwindow.index = index
    pbBottomRight(cmdwindow)
    cmdwindow.y -= msgwindow.height
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        ret = -1
        break
      end
      if Input.trigger?(Input::C)
        ret = cmdwindow.index
        break
      end
      pbUpdateSpriteHash(@sprites)
      msgwindow.update
      cmdwindow.update
    end
    msgwindow.dispose
    cmdwindow.dispose
    Input.update
    return ret
  end

  def pbDisplay(message)
    tts(message)
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.resizeHeightToFit(message, Graphics.width - 180)
    msgwindow.text = message
    pbBottomRight(msgwindow)
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::B) || Input.trigger?(Input::C)
      pbUpdateSpriteHash(@sprites)
      msgwindow.update
    end
    msgwindow.dispose
    Input.update
  end
end

################################################################################
# Regional Storage scripts
################################################################################
class RegionalStorage
  def initialize
    @storages = []
    @lastmap = -1
    @rgnmap = -1
  end

  def getCurrentStorage
    if !$game_map
      raise _INTL("The player is not on a map, so the region could not be determined.")
    end

    if @lastmap != $game_map.map_id
      @rgnmap = pbGetCurrentRegion # may access file IO, so caching result
      @lastmap = $game_map.map_id
    end
    if @rgnmap < 0
      raise _INTL("The current map has no region set.  Please set the MapPosition metadata setting for this map.")
    end

    if !@storages[@rgnmap]
      @storages[@rgnmap] = PokemonStorage.new
    end
    return @storages[@rgnmap]
  end

  def boxes
    return getCurrentStorage.boxes
  end

  def party
    return getCurrentStorage.party
  end

  def currentBox
    return getCurrentStorage.currentBox
  end

  def currentBox=(value)
    getCurrentStorage.currentBox = value
  end

  def maxBoxes
    return getCurrentStorage.maxBoxes
  end

  def maxPokemon(box)
    return getCurrentStorage.maxPokemon(box)
  end

  def [](x, y = nil)
    getCurrentStorage[x, y]
  end

  def []=(x, y, value)
    getCurrentStorage[x, y] = value
  end

  def full?
    getCurrentStorage.full?
  end

  def pbFirstFreePos(box)
    getCurrentStorage.pbFirstFreePos(box)
  end

  def pbCopy(boxDst, indexDst, boxSrc, indexSrc)
    getCurrentStorage.pbCopy(boxDst, indexDst, boxSrc, indexSrc)
  end

  def pbMove(boxDst, indexDst, boxSrc, indexSrc)
    getCurrentStorage.pbCopy(boxDst, indexDst, boxSrc, indexSrc)
  end

  def pbMoveCaughtToParty(pkmn)
    getCurrentStorage.pbMoveCaughtToParty(pkmn)
  end

  def pbMoveCaughtToBox(pkmn, box)
    getCurrentStorage.pbMoveCaughtToBox(pkmn, box)
  end

  def pbStoreCaught(pkmn)
    getCurrentStorage.pbStoreCaught(pkmn)
  end

  def pbDelete(box, index)
    getCurrentStorage.pbDelete(pkmn)
  end
end

################################################################################
# Search handling
################################################################################
module BoxSearchHandler
  @@currentsearch = nil
  @@searchtypes = []

  def self.clearSearch
    @@currentsearch = nil
  end

  def self.setSearch(&block)
    @@currentsearch = block
  end

  def self.hasSearch?
    !@@currentsearch.nil?
  end

  def self.matchesSearch?(pkmn)
    @@currentsearch.call(pkmn)
  end

  def self.gather(&mapper)
    allpoke = []
    for box in 0...$PokemonStorage.maxBoxes
      for i in 0...$PokemonStorage[box].length
        poke = $PokemonStorage[box, i]
        allpoke.push(poke) if poke
      end
    end
    for poke in $PokemonStorage.party
      allpoke.push(poke) if poke
    end

    allfound = []
    for poke in allpoke
      mapped = mapper.call(poke)
      mapped = Array(mapped)
      for found in mapped
        allfound.push(found) if found && !allfound.include?(found)
      end
    end
    return allfound
  end

  def self.registerTopSearchType(search)
    @@searchtypes.unshift(search)
  end

  def self.registerSearchType(search)
    @@searchtypes.push(search)
  end

  def self.commands(screen)
    commands = []
    types = []

    if self.hasSearch?
      commands.push(_INTL("Clear Search"))
      types.push(nil)
    end

    for st in @@searchtypes
      if st.shouldShow(screen)
        commands.push(st.name)
        types.push(st)
      end
    end
    return [commands, types]
  end

  class NameSearchType
    def name
      _INTL("Nickname")
    end

    def shouldShow(screen)
      true
    end

    def gatherParameters
      input = pbEnterText(_INTL("Nickname of the Pokémon?"), 0, 12).downcase
      return input == "" ? nil : input
    end

    def filter(screen, pkmn, params)
      return !pkmn.isEgg? && screen.pbNameContains(pkmn.name.downcase, params)
    end
  end

  class SpeciesSearchType
    def name
      _INTL("Species")
    end

    def shouldShow(screen)
      true
    end

    def gatherParameters
      unless $Settings.useKeyboard?
        input = pbEnterText(_INTL("Name of the species?"), 0, 12).downcase
        return input == "" ? nil : input
      end
      return pbEnterBoundedText(_INTL("Name of the species?"), BoxSearchHandler.gather(&:species), _INTL("No Pokémon found."), &method(:getMonName))
    end

    def filter(screen, pkmn, params)
      unless $Settings.useKeyboard?
        return screen.pbNameContains(getMonName(pkmn.species, pkmn.form).downcase, params)
      end
      return pkmn.species == params
    end
  end

  class ItemSearchType
    def name
      _INTL("Item")
    end

    def shouldShow(screen)
      true
    end

    def gatherParameters
      unless $Settings.useKeyboard?
        input = pbEnterText(_INTL("Name of the item?"), 0, 15).downcase
        return input # input == "" allows searching for all pokemon that have a held item
      end
      return pbEnterBoundedText(_INTL("Name of the item?"), BoxSearchHandler.gather(&:item), _INTL("No items found."), &method(:getItemName))
    end

    def filter(screen, pkmn, params)
      unless $Settings.useKeyboard?
        return !pkmn.isEgg? && !pkmn.item.nil? && screen.pbNameContains(getItemName(pkmn.item).downcase, params)
      end
      return !pkmn.isEgg? && pkmn.item == params
    end
  end

  class RelearnerSearchType
    def name
      _INTL("Can Relearn")
    end

    def shouldShow(screen)
      true
    end

    def gatherParameters
      return ""
    end

    def filter(screen, pkmn, params)
      return !pkmn.isEgg? && pkmn.canRelearnAll?
    end
  end

  class AbilitySearchType
    def name
      _INTL("Gets Ability")
    end

    def shouldShow(screen)
      true
    end

    def gatherParameters
      unless $Settings.useKeyboard?
        input = pbEnterText(_INTL("Name of the ability?"), 0, 15).downcase
        return input == "" ? nil : input
      end
      keys = BoxSearchHandler.gather(&:getAbilityList).uniq{ |i| getAbilityName(i) }
      return pbEnterBoundedText(_INTL("Name of the ability?"), keys, _INTL("No Pokémon found."), &method(:getAbilityName))
    end

    def filter(screen, pkmn, params)
      unless $Settings.useKeyboard?
        return !pkmn.isEgg? && pkmn.getAbilityList.any? { |ab| screen.pbNameContains(getAbilityName(ab), params) }
      end
      return !pkmn.isEgg? && pkmn.getAbilityList.any? { |ab| getAbilityName(ab) == getAbilityName(params) }
      # There are abilities that are internally different but share names such as As One
      # Thus for abilities we match names rather than internal symbols
    end
  end

  class TypeSearchType
    def name
      _INTL("Type")
    end

    def shouldShow(screen)
      true
    end

    def gatherParameters
      return pbEnterTypes(_INTL("Which types?"))
    end

    def filter(screen, pkmn, params)
      onlyshadow = params.include?(:SHADOW)
      noshadowparams = params.select { |it| it != :SHADOW }

      return false if onlyshadow && !(pkmn.isShadow? rescue false)

      if noshadowparams.length == 2
        return pkmn.type1 == noshadowparams[0] && pkmn.type2.nil? if noshadowparams[0] == noshadowparams[1]
        return (pkmn.type1 == noshadowparams[0] && pkmn.type2 == noshadowparams[1]) ||
               (pkmn.type2 == noshadowparams[0] && pkmn.type1 == noshadowparams[1])
      end
      return pkmn.type1 == noshadowparams[0] || pkmn.type2 == noshadowparams[0] if noshadowparams.length == 1
      return noshadowparams.empty?
    end
  end

  class KnownMoveSearchType
    def name
      _INTL("Knows Move")
    end

    def shouldShow(screen)
      true
    end

    def gatherParameters
      unless $Settings.useKeyboard?
        input = pbEnterText(_INTL("Name of the move?"), 0, 15).downcase
        return input == "" ? nil : input
      end
      return pbEnterBoundedText(_INTL("Name of the move?"), BoxSearchHandler.gather { |p| p.moves.map(&:move) }, _INTL("No Pokémon found."), &method(:getMoveName))
    end

    def filter(screen, pkmn, params)
      unless $Settings.useKeyboard?
        return !pkmn.isEgg? && pkmn.moves.any? { |mv| screen.pbNameContains(getMoveName(mv.move), params) }
      end
      return !pkmn.isEgg? && pkmn.moves.any? { |mv| mv.move == params }
    end
  end

  class LearnableMoveSearchType
    def name
      _INTL("Learns Move")
    end

    def shouldShow(screen)
      true
    end

    def gatherParameters
      unless $Settings.useKeyboard?
        input = pbEnterText(_INTL("Name of the move?"), 0, 15).downcase
        return input == "" ? nil : input
      end
      return pbEnterBoundedText(_INTL("Name of the move?"), BoxSearchHandler.gather(&:getAllLearnableMoves), _INTL("No Pokémon found."), &method(:getMoveName))
    end

    def filter(screen, pkmn, params)
      unless $Settings.useKeyboard?
        return !pkmn.isEgg? && pkmn.getAllLearnableMoves.any? { |mv| screen.pbNameContains(getMoveName(mv), params) }
      end
      return !pkmn.isEgg? && pkmn.getAllLearnableMoves.include?(params)
    end
  end
end

BoxSearchHandler.registerSearchType(BoxSearchHandler::NameSearchType.new)
BoxSearchHandler.registerSearchType(BoxSearchHandler::SpeciesSearchType.new)
BoxSearchHandler.registerSearchType(BoxSearchHandler::TypeSearchType.new)
BoxSearchHandler.registerSearchType(BoxSearchHandler::ItemSearchType.new)
BoxSearchHandler.registerSearchType(BoxSearchHandler::RelearnerSearchType.new)
BoxSearchHandler.registerSearchType(BoxSearchHandler::AbilitySearchType.new)
BoxSearchHandler.registerSearchType(BoxSearchHandler::KnownMoveSearchType.new)
BoxSearchHandler.registerSearchType(BoxSearchHandler::LearnableMoveSearchType.new)

################################################################################
# PC menus
################################################################################
def pbGetStorageCreator(lowercase = false)
  if $PokemonGlobal.seenStorageCreator
    creator = pbStorageCreator
    creator = _INTL("Bill") if !creator || creator == ""
    return creator
  else
    return lowercase ? _INTL("someone") : _INTL("Someone")
  end
end

def pbPCItemStorage
  loop do
    command = Kernel.pbShowCommandsWithHelp(
      nil,
      [
        _INTL("Withdraw Item"),
        _INTL("Deposit Item"),
        _INTL("Toss Item"),
        _INTL("Exit")
      ],
      [
        _INTL("Take out items from the PC."),
        _INTL("Store items in the PC."),
        _INTL("Throw away items stored in the PC."),
        _INTL("Go back to the previous menu.")
      ],
      -1
    )
    if command == 0 # Withdraw Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        Kernel.pbMessage(_INTL("There are no items."))
      else
        pbFadeOutIn(99999) {
          scene = WithdrawItemScene.new
          screen = PokemonBagScreen.new(scene, $PokemonBag)
          ret = screen.pbWithdrawItemScreen
        }
      end
    elsif command == 1 # Deposit Item
      pbFadeOutIn(99999) {
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $PokemonBag)
        ret = screen.pbDepositItemScreen
      }
    elsif command == 2 # Toss Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        Kernel.pbMessage(_INTL("There are no items."))
      else
        pbFadeOutIn(99999) {
          scene = TossItemScene.new
          screen = PokemonBagScreen.new(scene, $PokemonBag)
          ret = screen.pbTossItemScreen
        }
      end
    else
      break
    end
  end
end

def pbPCMailbox
  if !$PokemonGlobal.mailbox || $PokemonGlobal.mailbox.length == 0
    Kernel.pbMessage(_INTL("There's no Mail here."))
  else
    loop do
      commands = []
      for mail in $PokemonGlobal.mailbox
        commands.push(mail.sender)
      end
      commands.push(_INTL("Cancel"))
      command = Kernel.pbShowCommands(nil, commands, -1)
      if command >= 0 && command < $PokemonGlobal.mailbox.length
        mailIndex = command
        command = Kernel.pbMessage(
          _INTL("What do you want to do with {1}'s Mail?", $PokemonGlobal.mailbox[mailIndex].sender),
          [
            _INTL("Read"),
            _INTL("Move to Bag"),
            _INTL("Give"),
            _INTL("Cancel")
          ],
          -1
        )
        if command == 0 # Read
          pbFadeOutIn(99999) {
            pbDisplayMail($PokemonGlobal.mailbox[mailIndex])
          }
        elsif command == 1 # Move to Bag
          if Kernel.pbConfirmMessage(_INTL("The message will be lost.  Is that OK?"))
            if $PokemonBag.pbStoreItem($PokemonGlobal.mailbox[mailIndex].item)
              Kernel.pbMessage(_INTL("The Mail was returned to the Bag with its message erased."))
              $PokemonGlobal.mailbox.delete_at(mailIndex)
            else
              Kernel.pbMessage(_INTL("The Bag is full."))
            end
          end
        elsif command == 2 # Give
          pbFadeOutIn(99999) {
            sscene = PokemonScreen_Scene.new
            sscreen = PokemonScreen.new(sscene, $Trainer.party)
            sscreen.pbPokemonGiveMailScreen(mailIndex)
          }
        end
      else
        break
      end
    end
  end
end

def pbTrainerPCMenu
  #  loop do
  #    command=Kernel.pbMessage(
  #      _INTL("What do you want to do?"),
  #      [
  #       _INTL("Item Storage"),
  #       _INTL("Mailbox"),
  #       _INTL("Turn Off")
  #      ],
  #      -1
  #    )
  #    if command==0
  pbPCItemStorage
  #    elsif command==1
  #      pbPCMailbox
  #    else
  #      break
  #    end
  #  end
end

def pbTrainerPC
  Kernel.pbMessage(_INTL("\\se[computeropen]{1} booted up the PC.", $Trainer.name))
  pbTrainerPCMenu
  pbSEPlay("computerclose")
end

def pbPokeCenterPC(entrymsg = true)
  Kernel.pbMessage(_INTL("\\se[computeropen]{1} booted up the PC.", $Trainer.name)) if entrymsg
  loop do
    commands, _helptexts, actions = MenuHandlers.build(:pc_menu)

    command = Kernel.pbMessage(_INTL("Which PC should be accessed?"), commands, commands.length)
    break if command < 0 || command >= actions.length

    should_break = actions[command].call
    break if should_break == :break
  end
  pbSEPlay("computerclose")
  favPokeTracker(:train)
end

def pbCountReleasableStoragePokemon
  total_pokemon = 0
  for box in $PokemonStorage.boxes
    total_pokemon += box.pokemon.count { |entry| entry && entry.class == PokeBattle_Pokemon && !entry.isEgg? && !entry.mail }
  end
  return total_pokemon
end

def getMarkingNames
  return [_INTL("Circle"), _INTL("Square"), _INTL("Triangle"), _INTL("Diamond")]
end

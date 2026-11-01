class PokemonDataCopy
  attr_accessor :dataOldHash
  attr_accessor :dataNewHash
  attr_accessor :dataTime
  attr_accessor :data

  def crc32(x)
    return Zlib::crc32(x)
  end

  def readfile(filename)
    File.open(filename, "rb") { |f|
      f.read
    }
  end

  def writefile(str, filename)
    File.open(filename, "wb") { |f|
      f.write(str)
    }
  end

  def filetime(filename)
    File.open(filename, "r") { |f|
      f.mtime
    }
  end

  def initialize(data, datasave)
    @datafile = data
    @datasave = datasave
    @data = readfile(@datafile)
    @dataOldHash = crc32(@data)
    @dataTime = filetime(@datafile)
  end

  def changed?
    ts = readfile(@datafile)
    tsDate = filetime(@datafile)
    tsHash = crc32(ts)
    return tsHash != @dataNewHash && tsHash != @dataOldHash && tsDate > @dataTime
  end

  def save(newtilesets)
    newdata = Marshal.dump(newtilesets)
    if !changed?
      @data = newdata
      @dataNewHash = crc32(newdata)
      writefile(newdata, @datafile)
    else
      @dataOldHash = crc32(@data)
      @dataNewHash = crc32(newdata)
      @dataTime = filetime(@datafile)
      @data = newdata
      writefile(newdata, @datafile)
    end
    save_data(self, @datasave)
  end
end

class PokemonDataWrapper
  attr_reader :data

  def initialize(file, savefile, prompt)
    @savefile = savefile
    @file = file
    if pbRgssExists?(@savefile)
      @ts = load_data(@savefile)
      if !@ts.changed? || prompt.call == true
        @data = Marshal.load(@ts.data)
      else
        @ts = PokemonDataCopy.new(@file, @savefile)
        @data = load_data(@file)
      end
    else
      @ts = PokemonDataCopy.new(@file, @savefile)
      @data = load_data(@file)
    end
  end

  def save
    @ts.save(@data)
  end
end

def pbMapTree
  maplevels = []
  retarray = []
  for i in $cache.mapinfos.keys
    info = $cache.mapinfos[i]
    level = -1
    while info
      info = $cache.mapinfos[info.parent_id]
      level += 1
    end
    if level >= 0
      info = $cache.mapinfos[i]
      maplevels.push([i, level, info.parent_id, info.order])
    end
  end
  maplevels.sort! { |a, b|
    next a[1] <=> b[1] if a[1] != b[1] # level
    next a[2] <=> b[2] if a[2] != b[2] # parent ID

    next a[3] <=> b[3] # order
  }
  stack = []
  stack.push(0, 0)
  while stack.length > 0
    parent = stack[stack.length - 1]
    index = stack[stack.length - 2]
    if index >= maplevels.length
      stack.pop
      stack.pop
      next
    end
    maplevel = maplevels[index]
    stack[stack.length - 2] += 1
    if maplevel[2] != parent
      stack.pop
      stack.pop
      next
    end
    retarray.push([maplevel[0], $cache.mapinfos[maplevel[0]].name, maplevel[1]])
    for i in index + 1...maplevels.length
      if maplevels[i][2] == maplevel[0]
        stack.push(i)
        stack.push(maplevel[0])
        break
      end
    end
  end
  return retarray
end

def pbExtractText # I don't know what to do with this.
  msgwindow = Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(msgwindow, _INTL("Please wait.\\wtnp[0]"))
  MessageTypes.extract("intl.txt")
  Kernel.pbMessageDisplay(msgwindow, _INTL("All text in the game was extracted and saved to intl.txt.\1"))
  Kernel.pbMessageDisplay(msgwindow, _INTL("To localize the text for a particular language, translate every second line in the file.\1"))
  Kernel.pbMessageDisplay(msgwindow, _INTL("After translating, choose \"Compile Text.\""))
  Kernel.pbDisposeMessageWindow(msgwindow)
end

def pbCompileTextUI
  msgwindow = Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(msgwindow, _INTL("Please wait.\\wtnp[0]"))
  begin
    pbCompileText
    Kernel.pbMessageDisplay(msgwindow, _INTL("Successfully compiled text and saved it to intl.dat."))
    Kernel.pbMessageDisplay(msgwindow, _INTL("To use the file in a game, place the file in the Data folder under a different name, and edit the LANGUAGES array in the Settings script."))
  rescue RuntimeError
    Kernel.pbMessageDisplay(msgwindow, _INTL("Failed to compile text:  {1}", $!.message))
  end
  Kernel.pbDisposeMessageWindow(msgwindow)
end

class CommandList
  def initialize
    @commandHash = {}
    @callbacks = {}
    @commands = []
  end

  def getCommand(index)
    for key in @commandHash.keys
      return key if @commandHash[key] == index
    end
    return nil
  end

  def add(key, value, callback = nil)
    @commandHash[key] = @commands.length
    @callbacks[key] = callback
    @commands.push(value)
  end

  def executeCommand(index)
    command = getCommand(index)
    return if command.nil?
    callback = @callbacks[command]
    return if callback.nil?
    callback.call
  end

  def list
    @commands.clone
  end
end

def pbDefaultMap()
  return $game_map.map_id if $game_map
  return $cache.RXsystem.edit_map_id if $cache.RXsystem

  return 0
end

def pbHandleWarpToMap()
  if Input.pressex?(:A)
    params = ChooseNumberParams.new
    params.setRange(1, 999)
    params.setInitialValue(0)
    params.setCancelValue(0)
    mapid = Kernel.pbMessageChooseNumber('To which map id do you want to warp to?', params)
  else
    mapid = pbListScreen(_INTL("WARP TO MAP"), MapLister.new(pbDefaultMap()))
  end
  return pbWarpToMap(mapid)
end

# x and y arguments aren't used in the scripts currently but can be used in the F6 console
def pbWarpToMap(mapid, x = nil, y = nil)
  return false if mapid <= 0 || mapid >= $cache.mapdata.length

  map = Game_Map.new
  map.setup(mapid)

  unless x && y
    success = false
    100.times do
      x = rand(map.width)
      y = rand(map.height)
      next if !map.passableStrict?(x, y, 0, $game_player)
      next if map.events.values.any? { |event| event.x == x && event.y == y && !event.through && (self != $game_player || event.character_name != "") }

      success = true
      break
    end
    if !success
      x = rand(map.width)
      y = rand(map.height)
    end
  end

  if $scene.is_a?(Scene_Map)
    $game_temp.player_new_map_id = mapid
    $game_temp.player_new_x = x
    $game_temp.player_new_y = y
    $game_temp.player_new_direction = 2
    $scene.transfer_player
    $game_map.refresh
  else
    Kernel.pbCancelVehicles
    $MapFactory.setup(mapid)
    $game_player.moveto(x, y)
    $game_player.turn_down
    $game_map.update
    $game_map.autoplay
    $game_map.refresh
  end
  return true
end

def pbDebugMenu
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  sprites = {}
  commands = CommandList.new
  if $DEBUG
    commands.add("switches", _INTL("Switches"))
    commands.add("variables", _INTL("Variables"))
    commands.add("unidata", _INTL("Unidata") + (GAME_VERSION == "dev" ? " " + _INTL("(hold A to save edit)") : ""))
    commands.add("refreshmap", _INTL("Refresh Map"))
    commands.add("warp", _INTL("Warp to Map (hold A for map id)"))
    commands.add("healparty", _INTL("Heal Party"))
    commands.add("additem", _INTL("Add Item"))
    commands.add("clearbag", _INTL("Empty Bag"))
    commands.add("addpokemon", _INTL("Add Pokémon"))
    commands.add("exporttotext", _INTL("Export Pokémon to Text"))
    commands.add("playeroptions", _INTL("Player Character Options"))
    commands.add("usepc", _INTL("Use PC"))
    commands.add("setmoney", _INTL("Set Money"))
    commands.add("setcoins", _INTL("Set Coins"))
    commands.add("setbadges", _INTL("Set Badges"))
    commands.add("toggleshoes", _INTL("Toggle Running Shoes Ownership"))
    commands.add("togglepokegear", _INTL("Toggle Pokégear Ownership"))
    commands.add("togglepokedex", _INTL("Toggle Pokédex Ownership"))
    commands.add("dexlists", _INTL("Dex List Accessibility"))
    commands.add("daycare", _INTL("Day Care Options..."))
    commands.add("quickhatch", _INTL("Quick Hatch"))
    commands.add("roamerstatus", _INTL("Roaming Pokémon Status"))
    commands.add("roam", _INTL("Advance Roaming"))
    commands.add("terraintags", _INTL("Tileset Editor"))
    commands.add("testwildbattle", _INTL("Test Wild Battle"))
    commands.add("testdoublewildbattle", _INTL("Test Double Wild Battle"))
    commands.add("testtrainerbattle", _INTL("Test Trainer Battle"))
    commands.add("testdoubletrainerbattle", _INTL("Test Double Trainer Battle"))
    commands.add("relicstone", _INTL("Relic Stone"))
    commands.add("purifychamber", _INTL("Purify Chamber"))
    commands.add("extracttext", _INTL("Extract Text"))
    commands.add("compiletext", _INTL("Compile Text"))
    commands.add("compiletrainers", _INTL("Compile Trainers"))
    commands.add("compiledata", _INTL("Compile All Data"))
    commands.add("mapconnections", _INTL("Map Connections"))
    commands.add("animeditor", _INTL("Animation Editor"))
    commands.add("togglelogging", _INTL("Toggle Battle Logging"))
    commands.add("dexEditor", _INTL("Edit Pokedexes"))
    commands.add("positionEditor", _INTL("Edit Battler Positions"))
    commands.add("debugTrainer", _INTL("Test Debug Trainer")) # keep at bottom when adding options
  else
    commands.add("healparty", _INTL("Heal Party"))
    commands.add("additem", _INTL("Add Item"))
    commands.add("addpokemon", _INTL("Add Pokémon"))
    commands.add("usepc", _INTL("Use PC"))
    commands.add("setmoney", _INTL("Set Money"))
    commands.add("setcoins", _INTL("Set Coins"))
    commands.add("quickhatch", _INTL("Quick Hatch"))
    commands.add("exporttotext", _INTL("Export Pokémon"))
  end
  sprites["cmdwindow"] = Window_CommandPokemon.new(commands.list)
  cmdwindow = sprites["cmdwindow"]
  cmdwindow.viewport = viewport
  cmdwindow.resizeToFit(cmdwindow.commands)
  cmdwindow.height = Graphics.height if cmdwindow.height > Graphics.height
  cmdwindow.x = 0
  cmdwindow.y = 0
  cmdwindow.visible = true
  pbFadeInAndShow(sprites)
  ret = -1
  loop do
    loop do
      cmdwindow.update
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
    end
    break if ret == -1

    cmd = commands.getCommand(ret)
    if cmd == "switches"
      pbFadeOutIn(99999) { pbDebugScreen(0) }
    elsif cmd == "variables"
      pbFadeOutIn(99999) { pbDebugScreen(1) }
    elsif cmd == "unidata"
      pbFadeOutIn(99999) { pbDebugScreen(2, Input.pressex?(:A)) }
    elsif cmd == "refreshmap"
      $game_map.need_refresh = true
      Kernel.pbMessage(_INTL("The map will refresh."))
    elsif cmd == "warp"
      if GAME_VERSION == "dev" || Kernel.pbConfirmMessageSerious(_INTL("\\c[2]Warning: This debugging tool can easily break your save file. Continue?"))
        warped = pbHandleWarpToMap()
        if warped
          pbFadeOutAndHide(sprites)
          pbDisposeSpriteHash(sprites)
          viewport.dispose
          return
        end
      end
    elsif cmd == "healparty"
      for i in $Trainer.party
        i.heal
      end
      Kernel.pbMessage(_INTL("Your Pokémon were healed."))
    elsif cmd == "additem"
      item = pbListScreen(_INTL("ADD ITEM"), ItemLister.new(0))
      if item
        params = ChooseNumberParams.new
        params.setRange(1, BAGMAXPERSLOT)
        params.setInitialValue(1)
        params.setCancelValue(0)
        qty = Kernel.pbMessageChooseNumber(_INTL("Choose the number of items."), params)
        if qty > 0
          Kernel.pbReceiveItem(item, qty)
        end
      end
    elsif cmd == "clearbag"
      $PokemonBag.clear
      Kernel.pbMessage(_INTL("The Bag was cleared."))
    elsif cmd == "addpokemon"
      species = pbChooseSpeciesOrdered(1)
      if species
        params = ChooseNumberParams.new
        params.setRange(1, MAXIMUMLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level = Kernel.pbMessageChooseNumber(_INTL("Set the Pokémon's level."), params)
        if level > 0
          forms = Reborn ? getLegalForms(species) : $cache.pkmn[species].forms # getLegalForms does not exist for the other games since they don't use online
          if forms.empty?
            form = 0
          elsif forms.length == 1
            form = forms.keys.first
          else
            cmd = Kernel.pbMessage(_INTL("Select the Pokémon's form."), forms.values, forms.length)
            form = cmd == -1 ? nil : forms.keys[cmd]
          end
          if form
            pbAddPokemon(species, level, true, form)
          end
        end
      end
    elsif cmd == "usepc"
      pbSEPlay("computeropen")
      pbPokeCenterPC(false)
    elsif cmd == "exporttotext"
      exporttotext
    elsif cmd == "playeroptions"
      playeroption = Kernel.pbMessage(_INTL("What would you like to do?"), [
        _INTL("Set Player Character"),
        _INTL("Rename Player"),
        _INTL("Randomise Player's ID"),
        _INTL("Change Player Outfit"),
      ], -1)
      case playeroption
      when 0 # Set Player Character
        players = {}
        $cache.metadata[:Players].each_with_index do |player, id|
          next if player[:name].nil?
          players[id] = player[:name]
        end
        if players.length <= 1
          Kernel.pbMessage(_INTL("There is only one player defined."))
        else
          choice = Kernel.pbChoice(_INTL("Choose the new player character (currently {1}).", players[$PokemonGlobal.playerID]), players)
          unless choice.nil?
            if choice != $PokemonGlobal.playerID
              pbChangePlayer(choice)
              Kernel.pbMessage(_INTL("The player character was changed to {1}.", players[$PokemonGlobal.playerID]))
            end
          end
        end
      when 1 # Rename Player
        trname = pbEnterPlayerName("Your name?", 0, 12, $Trainer.name)
        if trname == ""
          trainertype = pbGetPlayerTrainerType
          gender = pbGetTrainerTypeGender(trainertype)
          trname = pbSuggestTrainerName(gender, trainertype)
        end
        $Trainer.name = trname
        Kernel.pbMessage(_INTL("The player's name was changed to {1}.", $Trainer.name))
      when 2 # Randomise Player's ID
        $Trainer.id = rand(256)
        $Trainer.id |= rand(256) << 8
        $Trainer.id |= rand(256) << 16
        $Trainer.id |= rand(256) << 24
        Kernel.pbMessage(_INTL("The player's ID was changed to {1} (2).", $Trainer.publicID, $Trainer.id))
      when 3 # Change Player Outfit
        oldoutfit = $Trainer.outfit
        params = ChooseNumberParams.new
        params.setRange(0, 99)
        params.setDefaultValue(oldoutfit)
        $Trainer.outfit = Kernel.pbMessageChooseNumber(_INTL("Set the player's outfit."), params)
        Kernel.pbMessage(_INTL("The player's outfit was changed.")) if $Trainer.outfit != oldoutfit
      end
    elsif cmd == "setmoney"
      params = ChooseNumberParams.new
      params.setMaxDigits(6)
      params.setDefaultValue($Trainer.money)
      $Trainer.money = Kernel.pbMessageChooseNumber(
        _INTL("Set the player's money."), params
      )
      Kernel.pbMessage(_INTL("You now have {1}.", getPurchaseDisplay($Trainer.money)))
    elsif cmd == "setcoins"
      params = ChooseNumberParams.new
      params.setRange(0, MAXCOINS)
      params.setDefaultValue($PokemonGlobal.coins)
      $PokemonGlobal.coins = Kernel.pbMessageChooseNumber(_INTL("Set the player's Coin amount."), params)
      Kernel.pbMessage(_INTL("You now have {1}.", getPurchaseDisplay($PokemonGlobal.coins, shorthand: false, currency: :Coins)))
    elsif cmd == "setbadges"
      badgecmd = 0
      loop do
        badgecmds = []
        for i in 0...BADGECOUNT
          badgecmds.push(_INTL("{1} Badge {2}", $Trainer.badges[i] ? "[Y]" : "[N]", i + 1))
        end
        badgecmd = Kernel.pbShowCommands(nil, badgecmds, -1, badgecmd)
        break if badgecmd < 0

        $Trainer.badges[badgecmd] = !$Trainer.badges[badgecmd]
      end
    elsif cmd == "toggleshoes"
      $PokemonGlobal.runningShoes = !$PokemonGlobal.runningShoes
      Kernel.pbMessage(_INTL("Gave Running Shoes.")) if $PokemonGlobal.runningShoes
      Kernel.pbMessage(_INTL("Lost Running Shoes.")) if !$PokemonGlobal.runningShoes
    elsif cmd == "togglepokegear"
      $Trainer.pokegear = !$Trainer.pokegear
      Kernel.pbMessage(_INTL("Gave Pokégear.")) if $Trainer.pokegear
      Kernel.pbMessage(_INTL("Lost Pokégear.")) if !$Trainer.pokegear
    elsif cmd == "togglepokedex"
      $Trainer.pokedex.canViewDex = !$Trainer.pokedex.canViewDex
      Kernel.pbMessage(_INTL("Gave Pokédex.")) if $Trainer.pokedex.canViewDex
      Kernel.pbMessage(_INTL("Lost Pokédex.")) if !$Trainer.pokedex.canViewDex
    elsif cmd == "dexlists"
      choice = Kernel.pbShowCommands(nil, pbDexNames, -1)
      break if choice == -1

      if $PokemonGlobal.pokedexData[choice][:unlocked]
        pbLockDex(choice)
      else
        pbUnlockDex(choice)
      end
    elsif cmd == "daycare"
      daycarecmd = 0
      loop do
        daycarecmds = [
          _INTL("Summary"),
          _INTL("Deposit Pokémon"),
          _INTL("Withdraw Pokémon"),
          _INTL("Generate egg"),
          _INTL("Collect egg"),
          _INTL("Dispose egg")
        ]
        daycarecmd = Kernel.pbShowCommands(nil, daycarecmds, -1, daycarecmd)
        break if daycarecmd < 0

        case daycarecmd
          when 0 # Summary
            if $PokemonGlobal.daycare
              num = pbDayCareDeposited
              Kernel.pbMessage(_INTL("{1} Pokémon are in the Day Care.", num))
              if num > 0
                txt = ""
                for i in 0...num
                  next if !$PokemonGlobal.daycare[i][0]

                  pkmn = $PokemonGlobal.daycare[i][0]
                  initlevel = $PokemonGlobal.daycare[i][1]
                  gender = pkmn.isGenderless? ? _INTL("genderless") : genderSign(pkmn.gender)
                  txt += _INTL("{1}) {2} ({3}), Lv.{4} (deposited at Lv.{5})", i, pkmn.name, gender, pkmn.level, initlevel)
                  txt += "\n" if i < num - 1
                end
                Kernel.pbMessage(txt)
              end
              if $PokemonGlobal.daycareEgg == 1
                Kernel.pbMessage(_INTL("An egg is waiting to be picked up."))
              elsif pbDayCareDeposited == 2
                if pbDayCareGetCompat == 0
                  Kernel.pbMessage(_INTL("The deposited Pokémon can't breed."))
                else
                  Kernel.pbMessage(_INTL("The deposited Pokémon can breed."))
                end
              end
            end
          when 1 # Deposit Pokémon
            if pbEggGenerated?
              Kernel.pbMessage(_INTL("Egg is available, can't deposit Pokémon."))
            elsif pbDayCareDeposited == 2
              Kernel.pbMessage(_INTL("Two Pokémon are deposited already."))
            elsif $Trainer.party.length == 0
              Kernel.pbMessage(_INTL("Party is empty, can't desposit Pokémon."))
            else
              pbChooseNonEggPokemon(1, 3)
              if pbGet(1) >= 0
                pbDayCareDeposit(pbGet(1))
                Kernel.pbMessage(_INTL("Deposited {1}.", pbGet(3)))
              end
            end
          when 2 # Withdraw Pokémon
            if pbEggGenerated?
              Kernel.pbMessage(_INTL("Egg is available, can't withdraw Pokémon."))
            elsif pbDayCareDeposited == 0
              Kernel.pbMessage(_INTL("No Pokémon are in the Day Care."))
            elsif $Trainer.party.length >= 6
              Kernel.pbMessage(_INTL("Party is full, can't withdraw Pokémon."))
            else
              pbDayCareChoose(_INTL("Which one do you want back?"), 1)
              if pbGet(1) >= 0
                pbDayCareGetDeposited(pbGet(1), 3, 4)
                pbDayCareWithdraw(pbGet(1))
                Kernel.pbMessage(_INTL("Withdrew {1}.", pbGet(3)))
              end
            end
          when 3 # Generate egg
            if $PokemonGlobal.daycareEgg == 1
              Kernel.pbMessage(_INTL("An egg is already waiting."))
            elsif pbDayCareDeposited != 2
              Kernel.pbMessage(_INTL("There aren't 2 Pokémon in the Day Care."))
            elsif pbDayCareGetCompat == 0
              Kernel.pbMessage(_INTL("The Pokémon in the Day Care can't breed."))
            else
              $PokemonGlobal.daycareEgg = 1
              Kernel.pbMessage(_INTL("An egg is now waiting in the Day Care."))
            end
          when 4 # Collect egg
            if $PokemonGlobal.daycareEgg != 1
              Kernel.pbMessage(_INTL("There is no egg available."))
            elsif $Trainer.party.length >= 6
              Kernel.pbMessage(_INTL("Party is full, can't collect the egg."))
            else
              pbDayCareGenerateEgg
              $PokemonGlobal.daycareEgg = 0
              $PokemonGlobal.daycareEggSteps = 0
              Kernel.pbMessage(
                _INTL(
                  "Collected the {1} egg.",
                  getMonName($Trainer.party[$Trainer.party.length - 1].species, $Trainer.party[$Trainer.party.length - 1].form)
                )
              )
            end
          when 5 # Dispose egg
            if $PokemonGlobal.daycareEgg != 1
              Kernel.pbMessage(_INTL("There is no egg available."))
            else
              $PokemonGlobal.daycareEgg = 0
              $PokemonGlobal.daycareEggSteps = 0
              Kernel.pbMessage(_INTL("Disposed of the egg."))
            end
        end
      end
    elsif cmd == "quickhatch"
      for pokemon in $Trainer.party
        pokemon.eggsteps = 1 if pokemon.isEgg?
      end
      Kernel.pbMessage(_INTL("All eggs on your party now require one step to hatch."))
    elsif cmd == "roamerstatus"
      if RoamingSpecies.length == 0
        Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
      else
        text = "\\l[8]"
        for i in 0...RoamingSpecies.length
          poke = RoamingSpecies[i]
          if $game_switches[poke[:switch]]
            status = $PokemonGlobal.roamPokemon[i]
            if status == true
              if $PokemonGlobal.roamPokemonCaught[i]
                text += _INTL("{1} (Lv.{2}) caught.", getMonName(poke[:species], poke[:form] || 0), poke[:level])
              else
                text += _INTL("{1} (Lv.{2}) defeated.", getMonName(poke[:species], poke[:form] || 0), poke[:level])
              end
            else
              curmap = $PokemonGlobal.roamPosition[i]
              if curmap
                $cache.mapinfos
                text += _INTL(
                  "{1} (Lv.{2}) roaming on map {3} ({4}){5}",
                  getMonName(poke[:species], poke[:form] || 0), poke[:level], curmap,
                  $cache.mapinfos[curmap].name, (curmap == $game_map.map_id) ? _INTL("(this map)") : ""
                )
              else
                text += _INTL("{1} (Lv.{2}) roaming (map not set).", getMonName(poke[:species], poke[:form] || 0), poke[:level])
              end
            end
          else
            text += _INTL("{1} (Lv.{2}) not roaming (switch {3} is off).", getMonName(poke[:species], poke[:form] || 0), poke[:level], poke[:switch])
          end
          text += "\n" if i < RoamingSpecies.length - 1
        end
        Kernel.pbMessage(text)
      end
    elsif cmd == "roam"
      if RoamingSpecies.length == 0
        Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
      else
        pbRoamPokemon(true)
        # $PokemonGlobal.roamedAlready=false
        Kernel.pbMessage(_INTL("Pokémon have roamed."))
      end
    elsif cmd == "terraintags"
      pbFadeOutIn(99999) { pbTilesetScreen }
    elsif cmd == "testwildbattle"
      species = pbChooseSpeciesOrdered(1)
      if species
        params = ChooseNumberParams.new
        params.setRange(1, MAXIMUMLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level = Kernel.pbMessageChooseNumber(_INTL("Set the Pokémon's level."), params)
        if level > 0
          pbWildBattle(species, level)
        end
      end
    elsif cmd == "testdoublewildbattle"
      Kernel.pbMessage(_INTL("Choose the first Pokémon."))
      species1 = pbChooseSpeciesOrdered(1)
      if species1
        params = ChooseNumberParams.new
        params.setRange(1, MAXIMUMLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level1 = Kernel.pbMessageChooseNumber(_INTL("Set the first Pokémon's level."), params)
        if level1 > 0
          Kernel.pbMessage(_INTL("Choose the second Pokémon."))
          species2 = pbChooseSpeciesOrdered(1)
          if species2
            params = ChooseNumberParams.new
            params.setRange(1, MAXIMUMLEVEL)
            params.setInitialValue(5)
            params.setCancelValue(0)
            level2 = Kernel.pbMessageChooseNumber(_INTL("Set the second Pokémon's level."), params)
            if level2 > 0
              pbDoubleWildBattle(species1, level1, species2, level2)
            end
          end
        end
      end
    elsif cmd == "testtrainerbattle"
      battle = pbListScreen(_INTL("SINGLE TRAINER"), TrainerBattleLister.new(0, false))
      if battle
        trainercmds = [
          _INTL("Single Battle"),
          _INTL("Double Battle"),
          _INTL("Cancel"),
        ]
        trainercmd = Kernel.pbShowCommands(nil, trainercmds, 3, 0)
        unless trainercmd == 2
          trainerdata = battle[1]
          doublebattle = trainercmd == 1
          pbTrainerBattle(trainerdata[0], trainerdata[1], "", doublebattle, trainerdata[4], true)
        end
      end
    elsif cmd == "testdoubletrainerbattle"
      battle1 = pbListScreen(_INTL("DOUBLE TRAINER 1"), TrainerBattleLister.new(0, false))
      if battle1
        battle2 = pbListScreen(_INTL("DOUBLE TRAINER 2"), TrainerBattleLister.new(0, false))
        if battle2
          trainerdata1 = battle1[1]
          trainerdata2 = battle2[1]
          pbDoubleTrainerBattle(
            trainerdata1[0], trainerdata1[1], trainerdata1[4], "",
            trainerdata2[0], trainerdata2[1], trainerdata2[4], "",
            true
          )
        end
      end
    elsif cmd == "relicstone"
      pbRelicStone()
    elsif cmd == "purifychamber"
      pbPurifyChamber()
    elsif cmd == "extracttext"
      pbExtractText
    elsif cmd == "compiletext"
      pbCompileTextUI
    elsif cmd == "compiletrainers"
      begin
        compileTrainers
        # $cache.trainers=load_data("Data/trainers.dat")
        Kernel.pbMessage(_INTL("Trainers have been compiled."))
      rescue
        logError($!, display: true)
      end
    elsif cmd == "compiledata"
      compileAll
      Kernel.pbMessage(_INTL("All data has been compiled."))
    elsif cmd == "mapconnections"
      pbFadeOutIn(99999) { pbEditorScreen }
    elsif cmd == "animeditor"
      pbFadeOutIn(99999) { pbAnimationEditor }
    elsif cmd == "togglelogging"
      $INTERNAL = !$INTERNAL
      Kernel.pbMessage(_INTL("Debug logs for battles will be made in the Save Data folder.")) if $INTERNAL
      Kernel.pbMessage(_INTL("Debug logs for battles will not be made.")) if !$INTERNAL
    elsif cmd == "dexEditor"
      pbFadeOutIn(99999) { editDexes }
    elsif cmd == "positionEditor"
      pbFadeOutIn(99999) { pbPositionScene }
    elsif cmd == "debugTrainer"
      pbFightDebugTrainer()
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end

class SpriteWindow_DebugRight < Window_DrawableCommand
  attr_reader :mode

  def initialize
    super(0, 0, Graphics.width, Graphics.height)
  end

  def shadowtext(x, y, w, h, t, align = 0)
    width = self.contents.text_size(t).width
    if align == 2
      x += (w - width)
    elsif align == 1
      x += (w / 2) - (width / 2)
    end
    pbDrawShadowText(self.contents, x, y, [width, w].max, h, t, *getDefaultTextColors(self.windowskin))
  end

  def drawItem(index, count, rect)
    return unless @mode
    pbSetNarrowFont(self.contents)
    if @mode == 0
      name = $cache.RXsystem.switches[index + 1]
      status = $game_switches[index + 1] ? "[ON]" : "[OFF]"
    elsif @mode == 1
      name = $cache.RXsystem.variables[index + 1]
      value = $game_variables[index + 1]
      if [TrueClass, FalseClass, String, Symbol].include?(value.class) || value.is_a?(Numeric)
        status = value.inspect
      else
        status = "[#{value.class} Object]"
      end
    elsif @mode == 2
      key = $Unidata.keys[index]
      name = key.inspect
      value = $Unidata[key]
      if [TrueClass, FalseClass].include?(value.class)
        status = value == true ? "[ON]" : "[OFF]"
      elsif [String, Symbol].include?(value.class) || value.is_a?(Numeric)
        status = value.inspect
      else
        status = "[#{value.class} Object]"
      end
    end
    name = '' if name == nil
    id_text = sprintf("%04d:", index + 1)
    # width = self.contents.text_size(id_text).width
    rect = drawCursor(index, rect)
    totalWidth = rect.width
    idWidth = totalWidth * 15 / 100
    nameWidth = totalWidth * 65 / 100
    statusWidth = totalWidth * 20 / 100
    self.shadowtext(rect.x, rect.y, idWidth, rect.height, id_text)
    self.shadowtext(rect.x + idWidth, rect.y, nameWidth, rect.height, name)
    self.shadowtext(rect.x + idWidth + nameWidth, rect.y, statusWidth, rect.height, status, 2)
  end

  def itemCount
    return $cache.RXsystem.switches.size - 1 if @mode == 0
    return $cache.RXsystem.variables.size - 1 if @mode == 1
    return $Unidata.length if @mode == 2
    return 1
  end

  def mode=(mode)
    @mode = mode
    refresh
  end
end

def pbDebugSetVariable(id, diff)
  pbPlayCursorSE()
  $game_variables[id] = 0 if $game_variables[id] == nil
  if $game_variables[id].is_a?(Numeric) && !$game_variables[id].is_a?(Array)
    $game_variables[id] = [$game_variables[id] + diff, 99999999].min
    $game_variables[id] = [$game_variables[id], -99999999].max
  end
end

def pbDebugVariableScreen(id)
  value = 0
  if $game_variables[id].is_a?(Numeric) && !$game_variables[id].is_a?(Array)
    value = $game_variables[id]
  end
  params = ChooseNumberParams.new
  params.setDefaultValue(value)
  params.setMaxDigits(8)
  params.setNegativesAllowed(true)
  value = Kernel.pbMessageChooseNumber(_INTL("Set variable {1}.", id), params)
  $game_variables[id] = [value, 99999999].min
  $game_variables[id] = [$game_variables[id], -99999999].max
end

def setUnidataValue(index)
  name = $Unidata.keys[index]
  value = $Unidata[name]
  begin
    Input.text_input = true
    $past_texts = [] if !$past_texts
    code = Kernel.pbMessageFreeText(_INTL("What would you like to set {1} to?", name), "", 999, Graphics.width, $past_texts)
    $past_texts.unshift(code) unless code == ""
    $past_texts.uniq!
    editUnidata(name, eval(code))
    Input.text_input = false
  rescue
    logError($!, display: true)
    Input.text_input = false
  end
end

def editUnidata(key, value)
  value = true if key == :debugUnidata
  $Unidata[key] = value
end

def pbDebugScreen(mode, saveUnidata = false)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["right_window"] = SpriteWindow_DebugRight.new
  right_window = sprites["right_window"]
  right_window.mode = mode
  right_window.viewport = viewport
  right_window.active = true
  right_window.index = 0
  pbFadeInAndShow(sprites)
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      break
    elsif Input.trigger?(Input::X)
      Input.text_input = true
      message = case mode
        when 0 then _INTL("Jump to switch?")
        when 1 then _INTL("Jump to variable?")
        when 2 then _INTL("Jump to Unidata?")
      end
      switch = Kernel.pbMessageFreeText(message, "", 999, Graphics.width)
      next if switch == ""
      if switch.to_i.to_s == switch
        switch = switch.to_i
        right_window.index = switch - 1 unless switch < 1 || switch > right_window.itemCount
      else
        results = []
        if mode == 0
          for i in 1...$cache.RXsystem.switches.length
            results.push(i) if $cache.RXsystem.switches[i].downcase.include?(switch.downcase)
          end
        elsif mode == 1
          for i in 1...$cache.RXsystem.variables.length
            results.push(i) if $cache.RXsystem.variables[i].downcase.include?(switch.downcase)
          end
        elsif mode == 2
          for i in 0...$Unidata.length
            results.push(i + 1) if $Unidata.keys[i].downcase.inspect.include?(switch.downcase)
          end
        end
        if results.empty?
          Kernel.pbMessage(_INTL("No matches found."))
        else
          right_window.index = results.first - 1
          Kernel.pbMessage(_INTL("{1} matches found.", results.length)) if results.length > 1
          puts results.inspect
        end
      end
      Input.text_input = false
    end
    current_id = right_window.index + 1
    if mode == 0
      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        $game_switches[current_id] = !$game_switches[current_id]
        right_window.refresh
      end
    elsif mode == 1
      if $game_variables[current_id].is_a?(Integer)
        if Input.repeat?(Input::RIGHT)
          pbDebugSetVariable(current_id, 1)
          right_window.refresh
        elsif Input.repeat?(Input::LEFT)
          pbDebugSetVariable(current_id, -1)
          right_window.refresh
        end
      end
      if Input.trigger?(Input::C)
        pbDebugVariableScreen(current_id)
        right_window.refresh
      end
    elsif mode == 2
      current_id -= 1
      key = $Unidata.keys[current_id]
      value = $Unidata[key]
      if Input.trigger?(Input::C)
        case value
          when TrueClass, FalseClass then editUnidata(key, !value)
          else setUnidataValue(current_id)
        end
        right_window.refresh
      elsif Input.repeat?(Input::RIGHT)
        case value
          when TrueClass, FalseClass then editUnidata(key, !value)
          when Numeric then editUnidata(key, value + 1)
        end
        right_window.refresh
      elsif Input.repeat?(Input::LEFT)
        case value
          when TrueClass, FalseClass then editUnidata(key, !value)
          when Numeric then editUnidata(key, value - 1)
        end
        right_window.refresh
      end
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose

  $Unidata[:debugUnidata] = true if mode == 2 && GAME_VERSION == "dev" && !saveUnidata
end

def pbPokemonDebug(origin, pkmn, pkmnid = nil, selected = nil, heldpoke = nil)
  command = 0
  loop do
    menuoptions = [
      _INTL("HP/Status"),
      _INTL("Level"),
      _INTL("Species"),
      _INTL("Moves"),
      _INTL("Gender"),
      _INTL("Ability"),
      _INTL("Nature"),
      _INTL("Shininess"),
      _INTL("Form"),
      _INTL("Happiness"),
      _INTL("EV/IV/pID"),
      _INTL("Hidden Power"),
      _INTL("Pokérus"),
      _INTL("Ownership"),
      _INTL("Nickname"),
      _INTL("Poké Ball"),
      _INTL("Egg"),
      _INTL("Shadow Pokémon"),
      # Duplication copies the pokemon's personal ID as well, which causes the original and the clone to be considered the same pokemon in some cases
      (!Reborn || $DEBUG || GAME_VERSION == "dev") ? _INTL("Duplicate") : nil,
      _INTL("Delete"),
      _INTL("Cancel"),
    ].compact
    command = @scene.pbShowCommands(_INTL("Do what with {1}?", pkmn.name), menuoptions, command)
    case menuoptions[command]
      ### Cancel ###
      when _INTL("Cancel")
        break

      ### HP/Status ###
      when _INTL("HP/Status")
        cmd = 0
        loop do
          arr = [
            _INTL("Set HP"),
            _INTL("Status: Sleep"),
            _INTL("Status: Poison"),
            _INTL("Status: Burn"),
            _INTL("Status: Paralysis"),
            _INTL("Status: Frozen"),
          ]
          arr.push(_INTL("Status: Petrified")) if Rejuv
          arr += [
            _INTL("Fainted"),
            _INTL("Heal"),
          ]
          cmd = @scene.pbShowCommands(_INTL("Do what with {1}?", pkmn.name), arr, cmd)
          # Break
          if cmd == -1
            break
          # Set HP
          elsif cmd == 0
            params = ChooseNumberParams.new
            params.setRange(0, pkmn.totalhp)
            params.setDefaultValue(pkmn.hp)
            newhp = Kernel.pbMessageChooseNumber(
              _INTL("Set the Pokémon's HP (max. {1}).", pkmn.totalhp),
              params,
            ) { @scene.update }
            if newhp != pkmn.hp
              pkmn.hp = newhp
              pbDisplay(_INTL("{1}'s HP was set to {2}.", pkmn.name, pkmn.hp))
              @scene.pbHardRefresh
            end
          # Set status
          elsif cmd >= 1 && cmd < arr.length - 2
            if pkmn.hp > 0
              statuses = [:SLEEP, :POISON, :BURN, :PARALYSIS, :FROZEN]
              statuses.push(:PETRIFIED) if Rejuv
              pkmn.status = statuses[cmd - 1]
              pkmn.statusCount = 0
              if pkmn.status == :SLEEP
                params = ChooseNumberParams.new
                params.setRange(0, 9)
                params.setDefaultValue(0)
                sleep = Kernel.pbMessageChooseNumber(
                  _INTL("Set the Pokémon's sleep count."),
                  params,
                ) { @scene.update }
                pkmn.statusCount = sleep
              end
              pbDisplay(_INTL("{1}'s status was changed.", pkmn.name))
              @scene.pbHardRefresh
            else
              pbDisplay(_INTL("{1}'s status could not be changed.", pkmn.name))
            end
          # Faint
          elsif cmd == arr.length - 2
            pkmn.hp = 0
            pbDisplay(_INTL("{1}'s HP was set to 0.", pkmn.name))
            @scene.pbHardRefresh
          # Heal
          elsif cmd == arr.length - 1
            pkmn.heal
            pbDisplay(_INTL("{1} was fully healed.", pkmn.name))
            @scene.pbHardRefresh
          end
        end

      ### Level ###
      when _INTL("Level")
        params = ChooseNumberParams.new
        params.setRange(1, MAXIMUMLEVEL)
        params.setDefaultValue(pkmn.level)
        level = Kernel.pbMessageChooseNumber(
          _INTL("Set the Pokémon's level (max. {1}).", MAXIMUMLEVEL), params
        ) { @scene.update }
        if level != pkmn.level
          pkmn.level = level
          pkmn.calcStats
          pkmn.exp = PBExp.startExperience(level, pkmn.growthrate)
          pbDisplay(_INTL("{1}'s level was set to {2}.", pkmn.name, pkmn.level))
          @scene.pbHardRefresh
        end

      ### Species ###
      when _INTL("Species")
        species = pbChooseSpecies(pkmn.dexnum)
        if species
          oldspeciesname = getMonName(pkmn.species, pkmn.form)
          # pkmn.species=species
          pkmn.species = $cache.pkmn.fetch($cache.pkmn.keys[species - 1]).mon
          pkmn.calcStats
          pkmn.initAbility
          pkmn.exp = PBExp.startExperience(pkmn.level, pkmn.growthrate)
          oldname = pkmn.name
          pkmn.name = getMonName(pkmn.species, pkmn.form) if pkmn.name == oldspeciesname
          pbDisplay(_INTL("{1}'s species was changed to {2}.", oldname, getMonName(pkmn.species, pkmn.form)))
          $Trainer.pokedex.setSeen(pkmn)
          @scene.pbHardRefresh
        end

      ### Moves ###
      when _INTL("Moves")
        cmd = 0
        loop do
          commands = [
            _INTL("Teach move (legal)"),
            _INTL("Teach move (all)"),
            _INTL("Reset movelist"),
            _INTL("Reset initial moves"),
            _INTL("Activate relearner"),
            _INTL("Edit PP"),
            _INTL("Forget move"),
          ]
          cmd = @scene.pbShowCommands(_INTL("Do what with {1}?", pkmn.name), commands, cmd)
          break if cmd == -1

          # Teach move (Legal or All)
          if cmd == 0 || cmd == 1
            moves = cmd == 0 ? pkmn.getAllLegalMoves(true) : getAllMoves()
            move = pbChooseMoveList(moves)
            next unless move
            pbTryLearnMove(pkmn, move, debug: true)
          # Reset movelist
          elsif cmd == 2
            pkmn.resetMoves
            pbDisplay(_INTL("{1}'s moves were reset.", pkmn.name))
          # Reset initial moves
          elsif cmd == 3
            pkmn.pbRecordFirstMoves
            pbDisplay(_INTL("{1}'s current moves were set as its first-known moves.", pkmn.name))
          # Relearn all
          elsif cmd == 4
            pkmn.activateRelearner()
            pbDisplay(_INTL("{1} can now relearn all its moves on its own.", pkmn.name))
          # Edit PP
          elsif cmd == 5
            next unless pkmn.moves.length > 0
            moveindex = origin.pbChooseMove(pkmn, _INTL("Choose move to forget."))
            next unless moveindex >= 0
            move = pkmn.moves[moveindex]
            next unless move.totalpp > 0
            params = ChooseNumberParams.new
            params.setRange(0, move.maxpp * 8 / 5)
            params.setInitialValue(move.pp)
            pp = Kernel.pbMessageChooseNumber(_INTL("Set the move's PP."), params)
            totalppbefore = move.totalpp
            move.ppup += 1 while pp > move.totalpp
            move.pp = pp
            msg = _INTL("{1}'s PP was set to {2}.", getMoveName(move.move), pp)
            msg += "\n" + _INTL("The total PP was increased to {1}.", move.totalpp) if move.totalpp != totalppbefore
            pbDisplay(msg)
          # Forget move
          elsif cmd == 6
            next unless pkmn.moves.length > 0
            moveindex = origin.pbChooseMove(pkmn, _INTL("Choose a move to forget."))
            next unless moveindex >= 0
            movename = getMoveName(pkmn.moves[moveindex].move)
            pbDeleteMove(pkmn, moveindex)
            pbDisplay(_INTL("{1} forgot {2}.", pkmn.name, movename))
          end
        end

      ### Gender ###
      when _INTL("Gender")
        if pkmn.isGenderless?
          pbDisplay(_INTL("{1} is genderless.", pkmn.name))
        else
          cmd = 0
          loop do
            oldgender = genderName(pkmn.gender)
            msg = [
              _INTL("Gender {1} is natural.", oldgender),
              _INTL("Gender {1} is being forced.", oldgender)
            ][pkmn.genderflag ? 1 : 0]
            cmd = @scene.pbShowCommands(
              msg,
              [
                _INTL("Make male"),
                _INTL("Make female"),
                _INTL("Remove override"),
              ],
              cmd,
            )
            # Break
            if cmd == -1
              break
            # Make male
            elsif cmd == 0
              pkmn.makeMale
              if pkmn.isMale?
                pbDisplay(_INTL("{1} is now male.", pkmn.name))
              else
                pbDisplay(_INTL("{1}'s gender couldn't be changed.", pkmn.name))
              end
            # Make female
            elsif cmd == 1
              pkmn.makeFemale
              if pkmn.isFemale?
                pbDisplay(_INTL("{1} is now female.", pkmn.name))
              else
                pbDisplay(_INTL("{1}'s gender couldn't be changed.", pkmn.name))
              end
            # Remove override
            elsif cmd == 2
              pkmn.genderflag = nil
              pbDisplay(_INTL("Gender override removed."))
            end

            $Trainer.pokedex.setSeen(pkmn)
            @scene.pbHardRefresh
          end
        end

      ### Ability ###
      when _INTL("Ability")
        loop do
          abils = pkmn.getAbilityList
          cmd = abils.find_index { |abil| abil == pkmn.ability }
          cmd = 0 if cmd.nil?
          commands = abils.map { |element|
            isHidden = (element == pkmn.getCacheData.HiddenAbility && abils.length > 1)
            (element == isHidden ? "(H) " : "") + getAbilityName(element)
          }
          commands.push(_INTL("[All Abilities]"))
          msg = [
            _INTL("Ability {1} is natural.", getAbilityNameUnique(pkmn.ability)),
            _INTL("Ability {1} is being forced.", getAbilityNameUnique(pkmn.ability)),
          ][pkmn.ability == pkmn.abilityIndex ? 0 : 1]
          cmd = @scene.pbShowCommands(msg, commands, cmd)
          # Break
          if cmd == -1
            break
          # Set ability override
          elsif cmd >= 0 && cmd < commands.length - 1
            pkmn.setAbility(abils[cmd])
          elsif cmd == commands.length - 1
            abil = pbChooseAbilityList()
            pkmn.setAbility(abil) if abil
          end

          @scene.pbHardRefresh
        end

      ### Nature ###
      when _INTL("Nature")
        pbDebugSetNature(pkmn, @scene)

      ### Shininess ###
      when _INTL("Shininess")
        cmd = 0
        loop do
          oldshiny = pkmn.isShiny? ? _INTL("shiny") : _INTL("normal")
          msg = [
            _INTL("Shininess ({1}) is natural.", oldshiny),
            _INTL("Shininess ({1}) is being forced.", oldshiny)
          ][pkmn.shinyflag != nil ? 1 : 0]
          cmd = @scene.pbShowCommands(
            msg,
            [
              _INTL("Make shiny"),
              _INTL("Make normal"),
              _INTL("Remove override"),
            ],
            cmd,
          )
          # Break
          if cmd == -1
            break
          # Make shiny
          elsif cmd == 0
            pkmn.makeShiny
          # Make normal
          elsif cmd == 1
            pkmn.makeNotShiny
          # Remove override
          elsif cmd == 2
            pkmn.shinyflag = nil
          end

          @scene.pbHardRefresh
        end

      ### Form ###
      when _INTL("Form")
        params = ChooseNumberParams.new
        params.setRange(0, 100)
        params.setDefaultValue(pkmn.form)
        f = Kernel.pbMessageChooseNumber(_INTL("Set the Pokémon's form."), params) { @scene.update }
        if f != pkmn.form
          pkmn.changeForm(f)
          pkmn.initAbility
          pbDisplay(_INTL("{1}'s form was set to {2}.", pkmn.name, pkmn.form))
          @scene.pbHardRefresh
        end

      ### Happiness ###
      when _INTL("Happiness")
        params = ChooseNumberParams.new
        params.setRange(0, 255)
        params.setAutoClamp(true)
        params.setDefaultValue(pkmn.happiness)
        h = Kernel.pbMessageChooseNumber(
          _INTL("Set the Pokémon's happiness (max. 255)."),
          params,
        ) { @scene.update }
        if h != pkmn.happiness
          pkmn.happiness = h
          pbDisplay(_INTL("{1}'s happiness was set to {2}.", pkmn.name, pkmn.happiness))
          @scene.pbHardRefresh
        end

      ### EV/IV/pID ###
      when _INTL("EV/IV/pID")
        cmd = 0
        loop do
          persid = sprintf("0x%08X", pkmn.personalID)
          cmd = @scene.pbShowCommands(
            _INTL("Personal ID is {1}.", persid),
            [
              _INTL("Set EVs"),
              _INTL("Set IVs"),
              _INTL("Randomise pID"),
            ],
            cmd,
          )
          case cmd
            # Break
            when -1
              break
            # Set EVs
            when 0
              pbDebugSetEVs(pkmn, @scene)
            # Set IVs
            when 1
              pbDebugSetIVs(pkmn, @scene)
            # Randomise pID
            when 2
              pkmn.personalID = rand(256)
              pkmn.personalID |= rand(256) << 8
              pkmn.personalID |= rand(256) << 16
              pkmn.personalID |= rand(256) << 24
              pkmn.calcStats
              @scene.pbHardRefresh
          end
        end

      ### Pokérus ###
      when _INTL("Pokérus")
        cmd = 0
        loop do
          pokerus = (pkmn.pokerus) ? pkmn.pokerus : 0
          msg = [
            _INTL("{1} doesn't have Pokérus.", pkmn.name),
            _INTL("Has strain {1}, infectious for {2} more days.", pokerus / 16, pokerus % 16),
            _INTL("Has strain {1}, not infectious.", pokerus / 16),
          ][pkmn.pokerusStage]
          cmd = @scene.pbShowCommands(
            msg,
            [
              _INTL("Give random strain"),
              _INTL("Make not infectious"),
              _INTL("Clear Pokérus"),
            ],
            cmd,
          )
          # Break
          if cmd == -1
            break
          # Give random strain
          elsif cmd == 0
            pkmn.givePokerus
          # Make not infectious
          elsif cmd == 1
            strain = pokerus / 16
            p = strain << 4
            pkmn.pokerus = p
          # Clear Pokérus
          elsif cmd == 2
            pkmn.pokerus = 0
          end
        end

      ### Hidden Power ###
      when _INTL("Hidden Power")
        cmd = 0
        loop do
          oldhptype = pbHiddenPower(pkmn)
          commands = []
          types = {}
          i = 0
          $cache.types.each do |type, data|
            next if [:NORMAL, :QMARKS, :SHADOW, :STELLAR].include?(type)
            commands.push(getTypeName(type))
            types[i] = type
            i += 1
          end
          cmd = @scene.pbShowCommands(_INTL("Hidden Power {1}.", getTypeName(oldhptype)), commands, cmd)
          # Break
          if cmd == -1
            break
          # Set nature override
          elsif cmd >= 0 && cmd < types.length
            pkmn.hptype = types[cmd]
          end

          @scene.pbHardRefresh
        end

      ### Ownership ###
      when _INTL("Ownership")
        cmd = 0
        loop do
          msg = [
            _INTL("Player's Pokémon\n{1}\n{2} ({3})", pkmn.ot, pkmn.publicID, pkmn.trainerID),
            _INTL("Foreign Pokémon\n{1}\n{2} ({3})", pkmn.ot, pkmn.publicID, pkmn.trainerID),
          ][pkmn.isForeign?($Trainer) ? 1 : 0]
          cmd = @scene.pbShowCommands(
            msg,
            [
              _INTL("Make player's"),
              _INTL("Set OT's name"),
              _INTL("Random foreign ID"),
              _INTL("Set foreign ID"),
            ],
            cmd,
          )
          # Break
          if cmd == -1
            break
          # Make player's
          elsif cmd == 0
            pkmn.trainerID = $Trainer.id
            pkmn.ot = $Trainer.name
          # Set OT's name
          elsif cmd == 1
            newot = pbEnterPlayerName(_INTL("{1}'s OT's name?", pkmn.name), 1, 12)
            pkmn.ot = newot
          # Set OT's gender
          elsif cmd == 2
            pkmn.trainerID = $Trainer.getForeignID
          # Set foreign ID
          elsif cmd == 3
            params = ChooseNumberParams.new
            params.setRange(0, 65535)
            params.setDefaultValue(pkmn.publicID)
            val = Kernel.pbMessageChooseNumber(
              _INTL("Set the new ID (max. 65535)."),
              params,
            ) { @scene.update }
            pkmn.trainerID = val
            pkmn.trainerID |= val << 16
          end
        end

      ### Nickname ###
      when _INTL("Nickname")
        cmd = 0
        loop do
          speciesname = getMonName(pkmn.species, pkmn.form)
          msg = [_INTL("{1} has the nickname {2}.", speciesname, pkmn.name),
                 _INTL("{1} has no nickname.", speciesname)][pkmn.name == speciesname ? 1 : 0]
          cmd = @scene.pbShowCommands(
            msg,
            [
              _INTL("Rename"),
              _INTL("Erase name"),
            ],
            cmd,
          )
          # Break
          if cmd == -1
            break
          # Rename
          elsif cmd == 0
            newname = pbEnterPokemonName(_INTL("{1}'s nickname?", speciesname), 0, 12, "", pkmn)
            pkmn.name = (newname == "") ? speciesname : newname
            @scene.pbHardRefresh
          # Erase name
          elsif cmd == 1
            pkmn.name = speciesname
            @scene.pbHardRefresh
          end
        end

      ### Poké Ball ###
      when _INTL("Poké Ball")
        cmd = 0
        loop do
          oldball = getItemName(pkmn.ballused)
          commands = []; balls = []
          for item in $cache.items.keys
            if $cache.items[item].checkFlag?(:ball)
              balls.push([item, getItemName(item)])
            end
          end
          balls.sort! { |a, b| a[1] <=> b[1] }
          for i in 0...commands.length
            cmd = i if pkmn.ballused == balls[i][0]
          end
          for i in balls
            commands.push(i[1])
          end
          cmd = @scene.pbShowCommands(_INTL("{1} used.", oldball), commands, cmd)
          if cmd == -1
            break
          else
            pkmn.ballused = balls[cmd][0]
          end
        end

      ### Egg ###
      when _INTL("Egg")
        cmd = 0
        loop do
          msg = [_INTL("Not an egg"), _INTL("Egg with eggsteps: {1}.", pkmn.eggsteps)][pkmn.isEgg? ? 1 : 0]
          cmd = @scene.pbShowCommands(
            msg,
            [
              _INTL("Make egg"),
              _INTL("Make Pokémon"),
              _INTL("Set eggsteps to 1"),
            ],
            cmd,
          )
          # Break
          if cmd == -1
            break
          # Make egg
          elsif cmd == 0
            if pbCanBeEgg?(pkmn.species, pkmn.form) ||
               pbConfirm(_INTL("{1} cannot be an egg. Make egg anyway?", getMonName(pkmn.species, pkmn.form)))
              pkmn.level = EGGINITIALLEVEL
              pkmn.calcStats
              pkmn.name = _INTL("Egg")
              pkmn.eggsteps = pkmn.getCacheData.EggSteps
              pkmn.hatchedMap = 0
              pkmn.obtainMode = 1
              @scene.pbHardRefresh
            end
          # Make Pokémon
          elsif cmd == 1
            pkmn.name = getMonName(pkmn.species, pkmn.form)
            pkmn.eggsteps = 0
            pkmn.hatchedMap = 0
            pkmn.obtainMode = 0
            @scene.pbHardRefresh
          # Set eggsteps to 1
          elsif cmd == 2
            pkmn.eggsteps = 1 if pkmn.eggsteps > 0
          end
        end

      ### Shadow Pokémon ###
      when _INTL("Shadow Pokémon")
        cmd = 0
        loop do
          msg = [
            _INTL("Not a Shadow Pokémon."),
            _INTL("Heart gauge is {1}.", pkmn.heartgauge),
          ][(pkmn.isShadow? rescue false) ? 1 : 0]
          cmd = @scene.pbShowCommands(
            msg,
            [
              _INTL("Make Shadow"),
              _INTL("Lower heart gauge"),
              _INTL("Purify"),
            ],
            cmd,
          )
          # Break
          if cmd == -1
            break
          # Make Shadow
          elsif cmd == 0
            if !(pkmn.isShadow? rescue false) && pkmn.respond_to?("makeShadow")
              pkmn.makeShadow
              pbDisplay(_INTL("{1} is now a Shadow Pokémon.", pkmn.name))
              @scene.pbHardRefresh
            else
              pbDisplay(_INTL("{1} is already a Shadow Pokémon.", pkmn.name))
            end
          # Lower heart gauge
          elsif cmd == 1
            if (pkmn.isShadow? rescue false)
              prev = pkmn.heartgauge
              pkmn.adjustHeart(-768)
              Kernel.pbMessage(_INTL("{1}'s heart gauge was lowered from {2} to {3} (now stage {4}).", pkmn.name, prev, pkmn.heartgauge, pkmn.heartStage))
              pbReadyToPurify(pkmn)
            else
              Kernel.pbMessage(_INTL("{1} is not a Shadow Pokémon.", pkmn.name))
            end
          # Purify
          elsif cmd == 2
            if !pkmn.isShadow?
              Kernel.pbMessage(_INTL("{1} is already purified!", pkmn.name))
            else
              pkmn.heartgauge = 0
              # pkmn.pbUpdateShadowMoves()
              pbPurify(pkmn, @scene)
              Kernel.pbMessage(_INTL("{1} has been purified!", pkmn.name))
            end
          end
        end

      ### Duplicate ###
      when _INTL("Duplicate")
        origin.duplicatePokemon(pkmn, selected)

      ### Delete ###
      when _INTL("Delete")
        origin.deletePokemon($Trainer.party.index(pkmn) ? $Trainer.party.index(pkmn) : 0, selected, heldpoke)
        break
      else
        break
    end
  end
end

def pbMakeDebugCornerWindow(text = "", viewport = nil, z = 99999, windowAbove: nil)
  window = Window_AdvancedTextPokemon.new(text)
  yield window if block_given?
  window.resizeToFit(window.text, Graphics.width)
  window.width = 160 if window.width <= 160
  window.y = windowAbove ? windowAbove.y + windowAbove.height : 0
  window.viewport = viewport
  window.visible = true
  window.z = z
  return window
end

def pbMakeDebugStatOptions(stats, maxValue, colortags)
  return (0...6).map { |i|
    value = stats[i]
    color = case true
      when value >= maxValue then colortags[:Red]
      when value == 0 then colortags[:Blue]
      else ""
    end
    next _INTL("{1}<r>    {3}({2})", getStatName(i), value, color)
  }
end

def pbDebugStatText(pkmn, origstats, window)
  statvals = [pkmn.hp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed]
  nature = $cache.natures[pkmn.nature]
  natup = nature.incStat
  natdn = nature.decStat

  statNames = (0...6).map { |i| getStatName(i) }

  longest = statNames.map { |statname| window.contents.text_size(statname).width }.max
  spaceWidth = window.contents.text_size(" ").width
  offsets = statNames.map { |statname| " " * ((longest - window.contents.text_size(statname).width) / spaceWidth) }
  colortags = isDarkWindowskin(window.windowskin) ? ColorTags : LightColorTags

  return statNames.each_with_index.map { |statname, i|
    color = nil
    if natup != natdn
      color = colortags[:NatBoosted] if natup == i
      color = colortags[:NatLowered] if natdn == i
    end
    statcolor = nil
    statcolor = colortags[:Red] if statvals[i] > origstats[i]
    statcolor = colortags[:Blue] if statvals[i] < origstats[i]

    statname = statname
    statname = color + statname + "</c3>" if color
    if statcolor
      next _INTL("{1}{2}<r>  {3} {4}-> {5}</c3>", statname, offsets[i], origstats[i], statcolor, statvals[i])
    else
      next _INTL("{1}{2}<r>  {3}", statname, offsets[i], statvals[i])
    end
  }.join("\n")
end

def pbDebugSetIVs(pkmn, scene = nil)
  pkmn.calcStats
  origstats = [pkmn.hp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed]
  command = 0
  colortags = isCurrentWindowskinDark ? ColorTags : LightColorTags

  while command >= 0
    commands = pbMakeDebugStatOptions(pkmn.iv, 31, colortags)
    commands.push(colortags[:Gray] + _INTL("Randomize all"))
    if pkmn.iv != [31, 31, 31, 31, 31, 31]
      commands.push(colortags[:Red] + _INTL("Maximize all"))
    end

    summarywindow = pbMakeDebugCornerWindow { |window|
      window.text = pbDebugStatText(pkmn, origstats, window)
    }
    command = Kernel.pbMessageAdvanced(_INTL("Change which IV?"), commands, -1, nil, 0) { scene&.update }
    summarywindow.dispose

    if command == 7 # Maximize all
      (0...6).each { |i| pkmn.iv[i] = 31 }
      pkmn.calcStats
      scene&.pbHardRefresh
      command = 0
    elsif command == 6 # Randomize all
      (0...6).each { |i| pkmn.iv[i] = rand(32) }
      pkmn.calcStats
      scene&.pbHardRefresh
    elsif command >= 0
      params = ChooseNumberParams.new
      params.setRange(0, 31)
      params.setAutoClamp(true)
      params.setDefaultValue(pkmn.iv[command])
      params.setCancelValue(pkmn.iv[command])
      pkmn.iv[command] = Kernel.pbMessageChooseNumber(_INTL("Set the IV for {1} (max. 31).", getStatName(command)), params)
      pkmn.calcStats
      scene&.pbHardRefresh
    end
  end
end

def pbDebugSetEVs(pkmn, scene = nil)
  pkmn.calcStats
  origstats = [pkmn.hp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed]
  command = 0
  evMax = 252
  evTotalMax = getPlayerMaxEVs()
  colortags = isCurrentWindowskinDark ? ColorTags : LightColorTags

  while command >= 0
    commands = pbMakeDebugStatOptions(pkmn.ev, evMax, colortags)
    currentTotal = pkmn.ev.sum
    commands.push(colortags[:Gray] + _INTL("Distribute all"))
    if currentTotal != 0
      commands.push(colortags[:Blue] + _INTL("Reset all"))
    end

    summarywindow = pbMakeDebugCornerWindow { |window|
      window.text = pbDebugStatText(pkmn, origstats, window)
    }
    command = Kernel.pbMessageAdvanced(_INTL("Change which EV?\nCurrent total: {1}, Max: {2}", currentTotal, evTotalMax), commands, -1, nil, command) { scene&.update }
    summarywindow.dispose

    if command == 7 # Reset all
      (0...6).each { |i| pkmn.ev[i] = 0 }
      pkmn.calcStats
      scene&.pbHardRefresh
      command = 0
    elsif command == 6 # Distribute all
      (0...6).each { |i| pkmn.ev[i] = evTotalMax / 6 }
      pkmn.calcStats
      scene&.pbHardRefresh
    elsif command >= 0
      currentMax = [evMax, evTotalMax - currentTotal + pkmn.ev[command]].min

      if currentMax == 0
        Kernel.pbMessage(_INTL("No EVs to allocate."))
        next
      end

      params = ChooseNumberParams.new
      params.setRange(0, currentMax)
      params.setAutoClamp(true)
      params.setDefaultValue(pkmn.ev[command])
      params.setCancelValue(pkmn.ev[command])
      pkmn.ev[command] = Kernel.pbMessageChooseNumber(_INTL("Set the EV for {1} (max. {2}).", getStatName(command), currentMax), params)
      pkmn.calcStats
      scene&.pbHardRefresh
    end
  end
end

def pbDebugSetNature(pkmn, scene = nil)
  pkmn.calcStats
  origstats = [pkmn.hp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed]
  baseCommands = []
  natures = []
  command = 0
  colortags = isCurrentWindowskinDark ? ColorTags : LightColorTags

  $cache.natures.each_with_index { |(natureKey, nature), idx|
    if !nature.incStat && !nature.decStat
      baseCommands.push(_INTL("{1}<r><o=128>---</o>", getNatureName(natureKey))) # Opacity, looks nice as a gray without shadow
    else
      boost = colortags[:NatBoosted]
      lower = colortags[:NatLowered]
      baseCommands.push(_INTL("{1}<r>{4}+{2}</c3> {5}-{3}</c3>", getNatureName(natureKey), getStatName(nature.incStat, :supershort), getStatName(nature.decStat, :supershort),
        boost, lower))
    end
    natures.push(natureKey)
    command = idx if natureKey == pkmn.nature
  }

  while command >= 0
    oldnature = pkmn.nature
    command = natures.index(oldnature) || 0

    commands = baseCommands
    commands = [*commands, colortags[:Gray] + _INTL("Remove override")] if pkmn.natureflag

    msg = [
      _INTL("Nature {1} is natural.", getNatureName(oldnature)),
      _INTL("Nature {1} is being forced.", getNatureName(oldnature)),
    ][pkmn.natureflag ? 1 : 0]

    summarywindow = pbMakeDebugCornerWindow { |window|
      window.text = pbDebugStatText(pkmn, origstats, window)
    }
    command = Kernel.pbMessageAdvanced(msg, commands, -1, nil, command) { scene&.update }
    summarywindow.dispose

    if command == natures.length # Remove override
      pkmn.setNature(nil)
      scene&.pbHardRefresh
    elsif command >= 0
      pkmn.setNature(natures[command])
      scene&.pbHardRefresh
    end
  end
end

def pbFightDebugTrainer()
  File.open(definition_file_path("trainertext.rb")) { |f| eval(f.read) }
  File.open(definition_file_path("bosstext.rb")) { |f| eval(f.read) }

  trainer = TEAMARRAY[0]
  trainerTeam = TeamData.new(0, trainer[:teamid], trainer)

  name, type, id = *trainer[:teamid]
  opponent = PokeBattle_Trainer.new(name, type)
  opponent.setForeignID($Trainer) if $Trainer
  opponent.trainereffect = trainerTeam.effects
  opponent.teamAttributes = trainerTeam.teamAttributes

  items = trainerTeam.items

  team = trainerTeam.party
  partySize = trainerTeam.partySize
  setParty = trainerTeam.setParty
  team = buildTeamFromParameters(team, partySize, setParty)
  party = getTrainerPartyFromTrainerHash(team, opponent, type, bossdata: BOSSINFOHASH)

  double_battle = !Kernel.pbConfirmMessage("Singles battle?")
  pbTrainerBattle(type, name, nil, double_battle, 0, true, opponent_overwrite: [opponent, items, party])
end

class Scene_Debug
  def main
    Graphics.transition(0)
    pbDebugMenu
    $scene = Scene_Map.new
    $game_map.refresh
    Graphics.freeze
  end
end

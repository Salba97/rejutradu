def editDexes
  pbCriticalCode {
    $mapscreen = DexEditorScene.new
    $mapscreen.dexScreen
    $mapscreen.dexLoop
    $mapscreen.close
  }
end

class DexEditorScene
  # Initializes the user created Pokedexes for later use.
  def initialize
    @createdDexes = {}
  end

  # Creates the sprites for the Pokedex editor.
  def dexScreen
    @sprites = {}
    @dexlist = []
    @selected = []
    @saved = true
    @regionChanged = false
    @dexChanged = false
    @newDex = false
    @evolutions = false
    @dexIndex = 0
    @dexOffset = 0
    @mode = 0
    @dexName = nil
    @dexSymbol = nil
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    changeDex
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/pokedexbg")
    @sprites["pokedex"] = Debug_Window_Pokedex.new(214, 18, 268, 332, @viewport)
    @sprites["pokedex"].height = Graphics.height - 76
    @sprites["help"] = Window_UnformattedTextPokemon.new(_INTL("View Mode | F5: Help"))
    @sprites["help"].x = 0
    @sprites["help"].y = Graphics.height - 64
    @sprites["help"].width = Graphics.width
    @sprites["help"].height = 64
    @sprites["help"].viewport = @viewport
    @sprites["help"].z = 2
    @sprites["dexname"] = Window_AdvancedTextPokemon.newWithSize("", 2, -18, Graphics.width, 64, @viewport)
    @sprites["dexname"].windowskin = nil
    @sprites["dexname"].baseColor = Color.new(248, 248, 248)
    @sprites["dexname"].shadowColor = Color.new(0, 0, 0)
    @sprites["species"] = Window_AdvancedTextPokemon.newWithSize("", 38, 22, 160, 64, @viewport)
    @sprites["species"].windowskin = nil
    @sprites["species"].baseColor = Color.new(88, 88, 80)
    @sprites["species"].shadowColor = Color.new(168, 184, 184)
    @sprites["total"] = Window_AdvancedTextPokemon.newWithSize("", 38, 242, 164, 64, @viewport)
    @sprites["total"].windowskin = nil
    @sprites["total"].baseColor = Color.new(88, 88, 80)
    @sprites["total"].shadowColor = Color.new(168, 184, 184)
    @sprites["slider"] = IconSprite.new(Graphics.width - 44, 62, @viewport)
    @sprites["slider"].setBitmap(sprintf("Graphics/Pictures/Pokedex/pokedexSlider"))
    @sprites["icon"] = IconSprite.new(116, 164, @viewport)
  end

  # Changes the mode for selections vs moving
  # 0 - Main, 1 - Edit, 2- Move
  def changeMode(mode)
    @mode = mode
    @sprites["pokedex"].mode = mode
    @selected = @dexlist[@sprites["pokedex"].index] + [@sprites["pokedex"].index] if mode == 2
  end

  # Changes the selected Pokedex for editing.
  def changeDex
    commands = pbDexNames[1..]
    @createdDexes.each { |dex, data|
      commands.push(data[:name])
    }
    commands.push(_INTL("Create new Pokedex"))
    commands.push(_INTL("Exit"))
    choice = Kernel.pbMessage(_INTL("Select a Pokedex."), commands, -1)
    if choice == commands.length - 1
      if @dexChanged || !@saved
        if Kernel.pbConfirmMessageSerious(_INTL("Are you sure you wish to exit? You have not saved your recent changes!"))
          close
          return
        end
      else
        close
        return
      end
    elsif choice == commands.length - 2
      if Kernel.pbConfirmMessage(_INTL("Import from a file?"))
        if importDex
          @createdDexes.store(@dexSymbol, DEX)
        else
          changeDex
        end
      else
        @dexName = Kernel.pbMessageFreeText(_INTL("What should the Pokedex be named?"), "", 999, Graphics.width)
        if @dexName == ""
          Kernel.pbMessage(_INTL("Pokedex name cannot be empty."))
          changeDex
        end
        @dexSymbol = Kernel.pbMessageFreeText(_INTL("What should the internal symbol be?"), "", 999, Graphics.width)
        if @dexSymbol == ""
          Kernel.pbMessage(_INTL("Pokedex symbol cannot be empty."))
          changeDex
        end
        @dexSymbol = @dexSymbol[1..] if @dexSymbol.start_with?(":")
        @dexSymbol = @dexSymbol.to_sym
        @createdDexes.store(
          @dexSymbol, {
            :name => @dexName,
            :default => false,
            :dexEntries => {}
          }
        )
      end
      @newDex = true
    else
      @dexSymbol = $cache.pokedexes.keys[choice + 1]
      if @dexSymbol != nil
        @dexName = $cache.pokedexes[@dexSymbol].name
        @dexIndex = choice + 1
        @newDex = false
      else
        @dexIndex = choice - (pbDexNames.length - 1)
        @dexSymbol = @createdDexes.keys[@dexIndex]
        @dexName = @createdDexes[@dexSymbol][:name]
        @dexlist = @createdDexes[@dexSymbol][:dexEntries].dup
        @newDex = true
      end
    end
    @regionChanged = true
  end

  # Main loop for editing the selected Pokedex.
  def dexLoop
    loop do
      Graphics.update
      Input.update
      if @regionChanged
        @regionChanged = false
        refreshDexList(!@newDex)
        if !@dexlist.empty?
          @dexOffset = -(1 - @dexlist[0][3])
          updateIndex
        end
      end

      oldindex = @sprites["pokedex"].index

      if @dexChanged
        refreshDexList(false)
        @saved = false
        @dexChanged = false
      end

      pbUpdateSpriteHash(@sprites)

      if @mode == 1
        if Input.triggerex?(:X)
          changeMode(0)
          @sprites["help"].text = _INTL("View Mode | F5: Help")
        end
        if Input.triggerex?(:C)
          choice = Kernel.pbMessage(_INTL("Select an option."), [_INTL("Edit species (Press A for search)"), _INTL("Edit form"), _INTL("Move"), _INTL("Delete"), _INTL("Cancel")], -1)
          case choice
            when 0
              species = choosePokemon
              if species
                form = chooseForm(species)
                if form
                  find = @dexlist.find { |entry| entry[0] == species && entry[2] == form }
                  if find
                    @dexlist.delete(find)
                  end
                  index = @sprites["pokedex"].index
                  @dexlist[index] = [species, getMonName(species), form, index + 1]
                  @dexChanged = true
                end
              end
            when 1
              index = @sprites["pokedex"].index
              species = @dexlist[index][0]
              form = chooseForm(species)
              if form
                @dexlist[index][2] = form
                @dexChanged = true
              end
            when 2
              changeMode(2)
              @sprites["help"].text = _INTL("C: Move Pokemon | X: Go back")
            when 3
              deleteEntry
          end
        end
        if Input.triggerex?(:Z)
          addPokemon(@sprites["pokedex"].index)
        end
        if Input.triggerex?(:V)
          addPokemon(@dexlist.length)
        end
        if Input.triggerex?(:E)
          changeMode(2)
          @sprites["help"].text = _INTL("C: Move Pokemon | X: Go back")
        end
        if Input.triggerex?(:D)
          deleteEntry
        end
        if Input.triggerex?(:S)
          params = ChooseNumberParams.new
          params.setRange(-9999, 9999)
          params.setInitialValue(0)
          params.setCancelValue(0)
          params.setNegativesAllowed(true)
          offset = Kernel.pbMessageChooseNumber(_INTL("Set the offset amount."), params)
          if offset
            @dexOffset = offset
            updateIndex
          end
        end
        if Input.triggerex?(:F)
          @evolutions = !@evolutions
          Kernel.pbMessage(_INTL("Adding evolutions set to {1}.", @evolutions))
        end
        if Input.triggerex?(:F5)
          helpWindowEdit
        end
      elsif @mode == 2
        if Input.triggerex?(:X)
          changeMode(1)
          @sprites["help"].text = _INTL("Edit Mode | F5: Help")
          oldindex = -1
        end
        if Input.triggerex?(:C)
          entry = @dexlist.delete_at(@selected[-1])
          @dexlist.insert(@sprites["pokedex"].index, entry)
          updateIndex
          changeMode(1)
          @sprites["help"].text = _INTL("Edit Mode | F5: Help")
          oldindex = -1
        end
      else
        if Input.triggerex?(:X)
          if @newDex
            @createdDexes[@dexSymbol][:dexEntries] = @dexlist.dup
          end
          if !@saved
            if Kernel.pbConfirmMessage(_INTL("Save changes?"))
              saveChanges
            end
          end
          if Kernel.pbConfirmMessage(_INTL("Exit from the editor?"))
            break
          end
          pbDisposeSpriteHash(@sprites)
          @viewport.dispose
          dexScreen
        end
        if Input.triggerex?(:C)
          changeMode(1)
          @sprites["help"].text = _INTL("Edit Mode | F5: Help")
        end
        if Input.triggerex?(:F)
          @saved = false
          visibility = nil
          if @newDex
            @createdDexes[@dexSymbol][:default] = !@createdDexes[@dexSymbol][:default]
            visibility = @createdDexes[@dexSymbol][:default]
          else
            $cache.pokedexes[@dexSymbol].instance_variable_set(:default, !$cache.pokedexes[@dexSymbol].default)
            visibility = $cache.pokedexes[@dexSymbol].default
          end
          Kernel.pbMessage(_INTL("Default visibility set to {1}.", visibility))
        end
        if Input.triggerex?(:V)
          choice = Kernel.pbMessage(_INTL("Select an option."), [_INTL("Import"), _INTL("Export"), _INTL("Cancel")], -1)
          case choice
            when 0
              if importDex
                @createdDexes.store(@dexSymbol, DEX)
              end
            when 1
              exportDex
          end
        end
        if Input.triggerex?(:S)
          if Kernel.pbConfirmMessage(_INTL("Save changes?"))
            saveChanges
          end
        end
        if Input.triggerex?(:E)
          dexName = Kernel.pbMessageFreeText(_INTL("What should the Pokedex be named?"), "", 999, Graphics.width)
          dexSymbol = Kernel.pbMessageFreeText(_INTL("What should the internal symbol be?"), "", 999, Graphics.width)
          if dexName != "" && dexSymbol != ""
            @dexName = dexName
            @dexSymbol = dexSymbol
            @dexSymbol = @dexSymbol[1..] if @dexSymbol.start_with?(":")
            @dexSymbol = @dexSymbol.to_sym
            saveChanges
          end
        end
        if Input.triggerex?(:D)
          if Kernel.pbConfirmMessageSerious(_INTL("Are you sure you wish to delete this Pokedex? This action cannot be undone."))
            if $cache.pokedexes.keys.include?(@dexSymbol)
              $cache.pokedexes.delete(@dexSymbol)
              save_data($cache.pokedexes, "Data/pokedexes.dat")
              cprint "Saved pokedexes.dat\n"
              dumpPokedexes
              $cache.pkmn.each { |sym, wrapper|
                wrapper.pokemonData.each { |form, data|
                  next if !form.is_a?(String)
                  next if !data.checkFlag?(:regionalDex)
                  data.flags[:regionalDex].delete(@dexSymbol)
                }
              }
              save_data($cache.pkmn, "Data/mons.dat")
              cprint "Saved mons.dat\n\n"
              monDump
            else

            end
            pbDisposeSpriteHash(@sprites)
            @viewport.dispose
            dexScreen
          end
        end
        if Input.triggerex?(:F5)
          helpWindowMain
        end
      end

      if oldindex != @sprites["pokedex"].index && @mode != 2
        iconspecies = @sprites["pokedex"].species
        lastForm = @dexlist[@sprites["pokedex"].index][2]
        monbitmap = pbPokemonBitmap(iconspecies, false, false, nil, lastForm)
        formnum = $cache.pkmn[iconspecies].forms.invert[lastForm]
        monbitmap = croppedBitmap(iconspecies, formnum, monbitmap)
        if monbitmap
          @sprites["icon"].bitmap = monbitmap
          @sprites["icon"].ox = @sprites["icon"].bitmap.width / 2
          @sprites["icon"].oy = @sprites["icon"].bitmap.height / 2
        else
          @sprites["icon"].bitmap = nil
        end
        if iconspecies != nil
          @sprites["species"].text = _ISPRINTF("<ac>{1:s}</ac>", getMonName(iconspecies, lastForm))
        else
          @sprites["species"].text = _ISPRINTF("")
        end
        # Update the slider
        ycoord = 62
        if @sprites["pokedex"].itemCount > 1
          ycoord += 188.0 * @sprites["pokedex"].index / (@sprites["pokedex"].itemCount - 1)
        end
        @sprites["slider"].y = ycoord

      end
    end
  end

  def saveChanges
    @saved = true
    $cache.cacheDex if $cache
    @createdDexes.each { |dex, data|
      dexObj = PokedexData.new(dex, data.reject { |k, v| k == :dexEntries || v == dex })
      $cache.pokedexes.store(dex, dexObj)
    }
    save_data($cache.pokedexes, "Data/pokedexes.dat")
    cprint "Saved pokedexes.dat\n"
    dumpPokedexes

    speciesList = @dexlist.map { |e| [[e[0], e[2]], e[3]] }.to_h
    spacetoclear = 0
    $cache.pkmn.each { |species, wrapper|
      wrapper.forms.keys.each { |form|
        $cache.pkmn[species, form].flags[:regionalDex]&.delete(@dexSymbol)
        $cache.pkmn[species, form].flags.delete(:regionalDex) if $cache.pkmn[species, form].flags[:regionalDex]&.empty?
        next unless speciesList[[species, form]]
        $cache.pkmn[species, form].flags[:regionalDex] ||= {}
        $cache.pkmn[species, form].flags[:regionalDex].store(@dexSymbol, speciesList[[species, form]])
      }
    }
    save_data($cache.pkmn, "Data/mons.dat")
    cprint "Saved mons.dat\n\n"
    monDump
  end

  def addPokemon(index)
    species = choosePokemon
    if species
      form = chooseForm(species)
      if form && !@dexlist.any? { |entry| entry[0] == species && entry[2] == form }
        if @evolutions
          dummyindex = index
          evos = gatherEvolutions(species, form)
          evos.each { |evo|
            species = evo[0]
            form = evo[1]
            form = $cache.pkmn[species].forms[form] if form.is_a?(Numeric)
            @dexlist.insert(dummyindex, [species, getMonName(species, form), form, dummyindex])
            dummyindex += 1
          }
        else
          @dexlist.insert(index, [species, getMonName(species, form), form, index])
        end

        updateIndex
        @sprites["pokedex"].refresh
        if index != @sprites["pokedex"].index
          @sprites["pokedex"].index = index
        end
      end
    end
  end

  # Pokemon selection. Holding A lets the user search a string.
  def choosePokemon
    commands = []
    list = {}
    $cache.pkmn.keys.each { |key|
      label = _ISPRINTF("{1:s} {2:s}", getSpeciesNumWithZeroes($cache.pkmn[key, 0].dexnum), getMonName(key))
      commands.push(label)
      list.store(commands[-2], key)
    }
    if Input.pressex?(:A)
      search = Kernel.pbMessageFreeText(_INTL("Enter species."), "", 999, Graphics.width).upcase
      commands.delete_if { |spec|
        delete = false
        if !spec.upcase.include?(search)
          sym = list[spec]
          if !sym.to_s.include?(search)
            list.delete(sym)
            delete = true
          end
        end
        delete
      }
    end
    cmdwin = pbListWindow([], 200)
    ret = pbCommands2(cmdwin, commands, -1)
    cmdwin.dispose
    return ret == -1 ? nil : list[commands[ret]]
  end

  def chooseForm(species)
    commands = $cache.pkmn[species].forms.values
    cmdwin = pbListWindow([], 200)
    ret = pbCommands2(cmdwin, commands, -1)
    cmdwin.dispose
    return ret == -1 ? nil : commands[ret]
  end

  def deleteEntry
    @dexlist.delete_at(@sprites["pokedex"].index)
    while @sprites["pokedex"].index >= @dexlist.length
      @sprites["pokedex"].index -= 1
    end
    updateIndex
  end

  def updateIndex
    @dexChanged = true
    for i in 0...@dexlist.length
      @dexlist[i][3] = i + 1 + @dexOffset
    end
  end

  # Creates an editable Pokedex in the `PokedexExport` folder in the root.
  def exportDex
    Dir.mkdir("PokedexExport") unless File.exist?("PokedexExport")

    export = "DEX = {\n"
    export += "  :symbol => #{@dexSymbol.inspect},\n"
    export += "  :name => #{@dexName.inspect},\n"
    export += "  :dexEntries => {\n"
    @dexlist.each { |entry|
      species = entry[0]
      form = entry[2]
      idx = entry[3]
      export += "    #{idx} => [:#{species}, #{form.inspect}],\n"
    }
    export += "  }\n"
    export += "}\n"

    filename = @dexSymbol.to_s.gsub(/\W+/, "")
    File.open("PokedexExport/#{filename}.rb", "w") { |f|
      f.write(export)
    }
    Kernel.pbMessage(_INTL("Saved file to PokedexExport/#{filename}.rb."))
  end

  def importDex
    import = Kernel.pbMessageFreeText(_INTL("Enter a file path."), "", 999, Graphics.width)
    if import.start_with?("\"") && import.end_with?("\"")
      import = import[1..import.length - 2]
    end
    if File.exist?(import)
      File.open(import, "rb") { |f|
        eval(f.read)
      }

      @dexSymbol = DEX[:symbol]
      @dexName = DEX[:name]
      dexlist = []
      DEX[:dexEntries].each { |index, mon|
        dexlist.push([mon[0], getMonName(mon[0], mon[1]), mon[1], index])
      }
      @dexlist = dexlist
      if @sprites["pokedex"]
        @sprites["pokedex"].index = 0
        refreshDexList(false)
      end
      @saved = false
      return true
    else
      Kernel.pbMessage(_INTL("File not found."))
      return false
    end
  end

  # Refreshes the current Pokedex list.
  # updateDexlist is true only on first load given existing dex
  def refreshDexList(updateDexlist = true)
    if updateDexlist
      dexlist = pbGetDexList(@dexIndex, editor: true)
      dexlist.compact!
      @dexlist = dexlist
    end
    # Sort species in ascending order by index number, not national species
    @dexlist.sort! { |a, b| a[3] <=> b[3] }

    @sprites["total"].text = _ISPRINTF("Total:<r>{1:d}", @dexlist.length)
    @sprites["dexname"].text = _ISPRINTF("<ac>{1:s}</ac>", @dexName)

    @sprites["pokedex"].commands = @dexlist
    @sprites["pokedex"].index = 0 if updateDexlist
    @sprites["pokedex"].refresh
    # Draw the slider
    ycoord = 62
    if @sprites["pokedex"].itemCount > 1
      ycoord += 188.0 * @sprites["pokedex"].index / (@sprites["pokedex"].itemCount - 1)
    end
    @sprites["slider"].y = ycoord
    return if @dexlist.empty?
    iconspecies = @sprites["pokedex"].species
    lastForm = @dexlist[@sprites["pokedex"].index][2]
    monbitmap = pbPokemonBitmap(iconspecies, false, false, nil, lastForm)
    formnum = $cache.pkmn[iconspecies].forms.invert[lastForm]
    monbitmap = croppedBitmap(iconspecies, formnum, monbitmap)
    if monbitmap
      @sprites["icon"].bitmap = monbitmap
      @sprites["icon"].ox = @sprites["icon"].bitmap.width / 2
      @sprites["icon"].oy = @sprites["icon"].bitmap.height / 2
    end
    if iconspecies != nil
      @sprites["species"].text = _ISPRINTF("<ac>{1:s}</ac>", getMonName(iconspecies, lastForm))
    else
      @sprites["species"].text = _ISPRINTF("")
    end
  end

  # Displays controls for the main menu.
  def helpWindowMain
    helptext = _INTL("C: Edit Pokedex\n")
    helptext += _INTL("X: Return to Pokedex selection\n")
    helptext += _INTL("V: Import/Export Pokedex file\n")
    helptext += _INTL("E: Edit Pokedex name/symbol\n")
    helptext += _INTL("F: Toggle default visibility\n")
    helptext += _INTL("S: Save Pokedex\n")
    helptext += _INTL("D: Delete Pokedex\n")
    helptext += _INTL("Up/Down: Move around Pokedex page")
    title = Window_UnformattedTextPokemon.new(helptext)
    title.x = 0
    title.y = 0
    title.width = Graphics.width * 8 / 10
    title.height = Graphics.height
    title.viewport = @viewport
    title.z = 99999
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::C)
      break if Input.trigger?(Input::B)
    end
    Input.update
    title.dispose
  end

  # Displays controls for the editor menu.
  def helpWindowEdit
    helptext = _INTL("C: Edit Pokemon\n")
    helptext += _INTL("X: Return\n")
    helptext += _INTL("Z: Insert Pokemon\n")
    helptext += _INTL("V: Append Pokemon\n")
    helptext += _INTL("      Hold A to search\n")
    helptext += _INTL("E: Move Pokemon\n")
    helptext += _INTL("S: Edit offset\n")
    helptext += _INTL("F: Toggle Evolutions\n")
    helptext += _INTL("D: Delete Pokemon\n")
    helptext += _INTL("Up/Down: Move around Pokedex page")
    title = Window_UnformattedTextPokemon.new(helptext)
    title.x = 0
    title.y = 0
    title.width = Graphics.width * 8 / 10
    title.height = Graphics.height
    title.viewport = @viewport
    title.z = 99999
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::C)
      break if Input.trigger?(Input::B)
    end
    Input.update
    title.dispose
  end

  def close
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

# Copies `Window_Pokedex` and strips some Owned/Seen functionality.
class Debug_Window_Pokedex < Window_Pokedex
  def initialize(x, y, height, width, viewport = nil)
    @mode = 0
    @selected = []
    @commands = []
    super(x, y, width, height, nil)
    self.windowskin = nil
    self.baseColor = Color.new(88, 88, 80)
    self.shadowColor = Color.new(168, 184, 184)
    self.viewport = viewport if viewport
  end

  # Changes the mode for selections vs moving
  # 0 - Main, 1 - Edit, 2- Move
  def mode=(mode)
    @mode = mode
    @selected = @commands[self.index] + [self.index] if @mode == 2
    refresh
  end

  def drawItem(index, count, rect)
    return if index >= self.top_row + self.page_item_max
    rect = drawCursor(index, rect)
    indexNumber = @commands[index][3]
    species = @commands[index][0]
    if species
      pbCopyBitmap(self.contents, @pokeballOwned.bitmap, rect.x - 6, rect.y + 8)
      text = _ISPRINTF("{1:s}{2:s} {3:s}", getSpeciesNumWithZeroes(indexNumber), " ", @commands[index][1])
    else
      pbCopyBitmap(self.contents, @pokeballSeen.bitmap, rect.x - 6, rect.y + 8)
      text = _ISPRINTF("{1:s}  ----------", getSpeciesNumWithZeroes(indexNumber))
    end
    if @mode == 2 && species
      if index == @selected[-2]
        pbCopyBitmap(self.contents, @pokeballSeen.bitmap, rect.x - 6, rect.y + 8)
        text = _ISPRINTF("{1:s}  ----------", getSpeciesNumWithZeroes(indexNumber))
      end
      if index == self.index
        pbCopyBitmap(self.contents, @pokeballOwned.bitmap, rect.x - 6, rect.y + 8)
        text = _ISPRINTF("{1:s}{2:s} {3:s}", getSpeciesNumWithZeroes(indexNumber), " ", @selected[1])
      end
    end
    pbDrawShadowText(self.contents, rect.x + 34, rect.y + 6, rect.width, rect.height, text, self.baseColor, self.shadowColor)
    drawCursor(index - 1, itemRect(index - 1))
  end
end

class PokemonLoadPanel < SpriteWrapper
  TRAINERNAME_COLOR = [Color.new(240, 72, 88), Color.new(100, 40, 40)]
  LOADINFO_COLOR = [Color.new(232, 232, 232), Color.new(136, 136, 136)]
  LOADINFO_COLOR_ALT = [Color.new(219, 203, 236), Color.new(142, 126, 159)]
  PATCH_COLOR = ColorArrays[:Green2]
  MAJOR_COLOR = ColorArrays[:Red2]

  TITLE_OFFSET = [32, 8]
  MAPNAME_OFFSET = [386, 8, 18] # third value : y for mapname2
  TRAINERNAME_OFFSET = [112, 64]
  LOADLABEL_OFFSET = [32, 8]
  LOADINFO_OFFSET = [240, 112, 32]

  attr_reader :selected
  attr_reader :ttsText

  def initialize(index, title, id, trainer, framecount, mapid, viewport = nil)
    super(viewport)
    @index = index
    @title = title
    @id = id
    @trainer = trainer
    @totalsec = (framecount || 0) / 40 # Graphics.frame_rate #Because Turbo exists
    @mapid = mapid
    @selected = (index == 0)
    @bgbitmap = AnimatedBitmap.new("Graphics/Pictures/loadPanels")
    @refreshBitmap = true
    @refreshing = false
    refresh
  end

  def dispose
    @bgbitmap.dispose
    self.bitmap.dispose
    super
  end

  def selected=(value)
    if @selected != value
      @selected = value
      @refreshBitmap = true
      refresh
    end
  end

  def pbRefresh
    # Draw contents
    @refreshBitmap = true
    refresh
  end

  def refresh
    return if @refreshing
    return if disposed?

    @refreshing = true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap = BitmapWrapper.new(@bgbitmap.width, 111 * 2)
      pbSetSystemFont(self.bitmap)
    end
    if !@refreshBitmap
      @refreshing = false
      return
    end

    @refreshBitmap = false
    self.bitmap.clear if self.bitmap
    if @id == :Continue
      self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, (@selected ? 111 * 2 : 0), @bgbitmap.width, 111 * 2))
    else
      self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, 111 * 2 * 2 + (@selected ? 23 * 2 : 0), @bgbitmap.width, 23 * 2))
    end
    textpos = []
    if @id == :Continue
      # Map name and title
      mapname = pbGetMapNameFromId(@mapid)
      mapname.gsub!(/\\PN/, @trainer.name)
      addTitleAndMapName(mapname, textpos)
      # Trainer name
      textpos.push([@trainer.name, TRAINERNAME_OFFSET[0], TRAINERNAME_OFFSET[1], 0, *TRAINERNAME_COLOR])
      # Badges/Legendaries
      if !@trainer.postgame
        textpos.push([getLabels[0], LOADLABEL_OFFSET[0], LOADINFO_OFFSET[1], 0, *LOADINFO_COLOR])
        textpos.push([@trainer.numbadges.to_s, LOADINFO_OFFSET[0], LOADINFO_OFFSET[1], 1, *LOADINFO_COLOR])
      else
        textpos.push([getLabels[1], LOADLABEL_OFFSET[0], LOADINFO_OFFSET[1], 0, *LOADINFO_COLOR])
        textpos.push([@trainer.postgame.to_s, LOADINFO_OFFSET[0], LOADINFO_OFFSET[1], 1, *LOADINFO_COLOR])
      end
      # Pokedex
      textpos.push([getLabels[2], LOADLABEL_OFFSET[0], LOADINFO_OFFSET[1] + LOADINFO_OFFSET[2], 0, *LOADINFO_COLOR])
      if @trainer.pokedex && ([true, false].include?(@trainer.pokedex) || !@trainer.pokedex.instance_variable_defined?(:@dexList) ||
          !@trainer.pokedex.instance_variable_get(:@dexList).values[0].is_a?(PokedexListEntry))
        textpos.push([0.to_s, LOADINFO_OFFSET[0], LOADINFO_OFFSET[1] + LOADINFO_OFFSET[2], 1, *LOADINFO_COLOR])
      else
        textpos.push([getPokedexCount(), LOADINFO_OFFSET[0], LOADINFO_OFFSET[1] + LOADINFO_OFFSET[2], 1, *LOADINFO_COLOR])
      end
      # Time
      textpos.push([getLabels[3], LOADLABEL_OFFSET[0], LOADINFO_OFFSET[1] + LOADINFO_OFFSET[2] * 2, 0, *LOADINFO_COLOR])
      hour = @totalsec / 60 / 60
      min = @totalsec / 60 % 60
      if hour > 0
        textpos.push([_INTL("{1}h {2}m", hour, min), LOADINFO_OFFSET[0], LOADINFO_OFFSET[1] + LOADINFO_OFFSET[2] * 2, 1, *LOADINFO_COLOR])
      else
        textpos.push([_INTL("{1}m", min), LOADINFO_OFFSET[0], LOADINFO_OFFSET[1] + LOADINFO_OFFSET[2] * 2, 1, *LOADINFO_COLOR])
      end
    else
      colors = @colors || LOADINFO_COLOR
      colors = LOADINFO_COLOR_ALT if @id == :OtherSaves && $game_switches && $game_switches[:A_Fervent_Wish]
      textpos.push([@title, LOADLABEL_OFFSET[0], LOADLABEL_OFFSET[1], 0, *colors])
    end
    pbDrawTextPositions(self.bitmap, textpos)
    @ttsText = textpos.map{ |i| i[0] }.join("\n")
    @ttsText += "\n" + _INTL("Current version: {1}", GAME_VERSION) if @id == :CheckingForUpdates
    @refreshing = false
  end

  def update
    super
    # Update button title when the updater thread is done
    if @id == :CheckingForUpdates && !@updated
      versionStatus = Updater.getVersionStatus
      if versionStatus == :UpdaterError
        @title = _INTL("Updates: Error")
      elsif versionStatus == :InvalidVersion
        @title = _INTL("Updates: Invalid version number")
      elsif versionStatus == :UnreleasedVersion
        @title = _INTL("Updates: Unreleased version")
      elsif versionStatus == :PatchUpdate
        @title = _INTL("Updates: New patch {1}", Updater.getAvailableVersion)
        @colors = PATCH_COLOR
      elsif versionStatus == :MajorUpdate
        @title = _INTL("Updates: Major update {1}", Updater.getAvailableLatest)
        @colors = MAJOR_COLOR
      elsif versionStatus == :EngineUpdate
        @title = _INTL("Updates: Engine update")
        @colors = PATCH_COLOR
      elsif versionStatus == :UpToDate
        @title = _INTL("Updates: Up to date")
      elsif versionStatus == :CheckingForUpdates
        # Early return to prevent pbRefresh
        return
      else
        @title = _INTL("Updates: Unexpected status")
      end
      @updated = true
      pbRefresh
    end
  end

  def addTitleAndMapName(mapname, textpos)
    textpos.push([@title, TITLE_OFFSET[0], TITLE_OFFSET[1], 0, *LOADINFO_COLOR])
    mapname2 = ""
    if mapname.length > 24
      splits = mapname.split(/ /, mapname[0, 24].split(/ /).length)
      mapname2 = splits.delete_at(-1)
      mapname = splits.join(" ")
    end
    textpos.push([mapname, MAPNAME_OFFSET[0], MAPNAME_OFFSET[1], 1, *LOADINFO_COLOR])
    textpos.push([mapname2, MAPNAME_OFFSET[0], MAPNAME_OFFSET[2], 1, *LOADINFO_COLOR]) if mapname2 != ""
  end

  def getLabels
    return [_INTL("Badges"), _INTL("Legendaries"), _INTL("Pokédex"), _INTL("Time")]
  end

  def getPokedexCount
    return @trainer.pokedex.getOwnedCount.to_s + "/" + @trainer.pokedex.getSeenCount.to_s
  end
end

class PokemonLoadScene
  LOADPANELS_X = 54

  CHAR_X_BASE = 114
  CHAR_Y_BASE = 108
  PARTY_X_BASE = 308
  PARTY_X_OFFSET = 64
  PARTY_Y_BASE = 72
  PARTY_Y_OFFSET = 50

  SaveNameColors = [Color.new(255, 255, 255), Color.new(125, 125, 125)]
  SaveNameColorsAlt = [Color.new(218, 182, 214), Color.new(139, 131, 148)]
  VersionColor = Color.new(55, 55, 55)

  def pbUpdate
    oldi = @sprites["cmdwindow"].index rescue 0
    pbUpdateSpriteHash(@sprites)
    newi = @sprites["cmdwindow"].index rescue 0
    if oldi != newi
      @sprites["panel#{oldi}"].selected = false
      @sprites["panel#{oldi}"].pbRefresh
      @sprites["panel#{newi}"].selected = true
      @sprites["panel#{newi}"].pbRefresh
      while @sprites["panel#{newi}"].y > Graphics.height - 80
        for i in 0...@commands.length
          @sprites["panel#{i}"].y -= 48
        end
        for i in 0...6
          break if !@sprites["party#{i}"]

          @sprites["party#{i}"].y -= 48
        end
        @sprites["player"].y -= 48 if @sprites["player"]
      end
      while @sprites["panel#{newi}"].y < 32
        for i in 0...@commands.length
          @sprites["panel#{i}"].y += 48
        end
        for i in 0...6
          break if !@sprites["party#{i}"]

          @sprites["party#{i}"].y += 48
        end
        @sprites["player"].y += 48 if @sprites["player"]
      end
    end
  end

  def pbStartScene(commands, ids, trainer, framecount, mapid)
    @commands = commands
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    @textviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @textviewport.z = @viewport.z + 1
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @textviewport)
    @sprites["overlay2"] = BitmapSprite.new(Graphics.width, Graphics.height, @textviewport)

    if GAME_VERSION != 'dev'
      version = GAME_VERSION
      # Breaks on 1.5x screen size but we don't have a better option currently.
      @sprites["overlay2"].bitmap.font.name = "PokemonEmerald"
      @sprites["overlay2"].bitmap.font.size = $kirin ? 19 : 15
      @sprites["overlay2"].bitmap.font.bold = true
      textpos = []
      if version.index("-") != nil
        prerelease = version[version.index("-") + 1..]
        version = version[0...version.index("-")]
        textpos.push [version, Graphics.width - 6, Graphics.height - 30, :right, VersionColor]
        textpos.push [prerelease, Graphics.width - 6, Graphics.height - 18, :right, VersionColor]
      else
        textpos.push [version, Graphics.width - 6, Graphics.height - 26, :right, VersionColor]
      end
      pbDrawTextPositions(@sprites["overlay2"].bitmap, textpos)
    end

    addBackgroundOrColoredPlane(@sprites, "background", "loadbg", Color.new(248, 248, 248), @viewport)
    y = 32
    for i in 0...commands.length
      @sprites["panel#{i}"] = PokemonLoadPanel.new(i, commands[i], ids[i], trainer, framecount, mapid, @viewport)
      @sprites["panel#{i}"].pbRefresh
      @sprites["panel#{i}"].x = LOADPANELS_X
      @sprites["panel#{i}"].y = y
      y += ids[i] == :Continue ? 224 : 48
    end
    @sprites["cmdwindow"] = Window_CommandPokemon.new([], tts: false)
    @sprites["cmdwindow"].x = Graphics.width
    @sprites["cmdwindow"].y = 0
    @sprites["cmdwindow"].viewport = @viewport
    @sprites["cmdwindow"].visible = false
  end

  def pbStartScene2
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbMoveSprites(xoffset)
    @sprites["cmdwindow"].x -= xoffset
    @sprites["player"].x -= xoffset if @sprites["player"]
    for i in 0...6
      @sprites["party#{i}"].x -= xoffset if @sprites["party#{i}"]
    end
    for i in 0...@commands.length
      @sprites["panel#{i}"].x -= xoffset if @sprites["panel#{i}"]
    end
  end

  def pbDrawSaveCommands(savefiles)
    @savefiles = savefiles
    textpos = []
    numsavebuttons = [savefiles.length, 9].min
    for i in 0...numsavebuttons
      @sprites["savefile#{i}"] = IconSprite.new(Graphics.width / 2 - 384 / 2, i * 45, @viewport)
      @sprites["savefile#{i}"].setBitmap("Graphics/Pictures/loadsavepanel")
      @sprites["savefile#{i}"].zoom_x = 0.5
      @sprites["savefile#{i}"].zoom_y = 0.5
      Graphics.update
      loop do
        @sprites["savefile#{i}"].zoom_x += 0.5
        @sprites["savefile#{i}"].zoom_y += 0.5
        Graphics.update
        break if @sprites["savefile#{i}"].zoom_x == 1
      end
    end
    pbDrawSaveText(savefiles)
    @sprites["saveselect"] = IconSprite.new(Graphics.width / 2 - 384 / 2, 0, @viewport)
    @sprites["saveselect"].setBitmap("Graphics/Pictures/loadsavepanel_1")
    Graphics.update
    pbToggleSelecting
    tts(@savefiles[0][1])
  end

  def pbRemoveSaveCommands
    @sprites["overlay"].bitmap.clear
    @index = 0 if !@index
    Graphics.update

    pbDisposeSprite(@sprites, "saveselect")
    Graphics.update
    for i in 0...@savefiles.length
      pbDisposeSprite(@sprites, "savefile#{i}")
      Graphics.update
    end
  end

  def pbChooseAutoSubFile(index, arrayindex)
    if !@sprites["autosavefile"]
      @sprites["overlay"].bitmap.clear
      @sprites["newsavefile1"] = IconSprite.new(20, Graphics.height / 3, @viewport)
      @sprites["newsavefile1"].setBitmap("Graphics/Pictures/loadsavepanel")
      @sprites["autosavefile"] = IconSprite.new(300, Graphics.height / 3, @viewport)
      @sprites["autosavefile"].setBitmap("Graphics/Pictures/loadsavepanel")
      @sprites["saveselect"] = IconSprite.new(20, Graphics.height / 3, @viewport)
      @sprites["saveselect"].setBitmap("Graphics/Pictures/loadsavepanel_1")
      @sprites["autosavefile"].zoom_x = 0.5
      @sprites["newsavefile1"].zoom_x = 0.5
      @sprites["newsavefile1"].zoom_y = 1.5
      @sprites["autosavefile"].zoom_y = 1.5
      @sprites["saveselect"].zoom_x = 0.5
      @sprites["saveselect"].zoom_y = 1.5
      @sprites["overlay2"].bitmap.font.size = 22
      textpos = []
      textpos.push([@savefiles[arrayindex][1], Graphics.width / 2 - @savefiles[arrayindex][1].length / 2 * 10, 30, 0, Color.new(0, 0, 0), Color.new(125, 125, 125)])
      textpos.push(["Normal Save", 55, Graphics.height / 3 + 12, 0, Color.new(255, 255, 255), Color.new(125, 125, 125)])
      textpos.push(["Autosave", 350, Graphics.height / 3 + 12, 0, Color.new(255, 255, 255), Color.new(125, 125, 125)])
      textpos.push([@savefiles[arrayindex][4], 30, Graphics.height / 3 + 35, 0, Color.new(255, 255, 255), Color.new(125, 125, 125)])
      textpos.push([@savefiles[arrayindex][5], 315, Graphics.height / 3 + 35, 0, Color.new(255, 255, 255), Color.new(125, 125, 125)])
      pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    end
    if index == 0
      @sprites["saveselect"].x = 20
    else
      @sprites["saveselect"].x = 300
    end
  end

  def pbClearOverlay2
    @sprites["overlay2"].bitmap.clear
  end

  def pbDrawCurrentSaveFile(savename = "", auto = nil)
    @sprites["overlay2"].bitmap.clear
    textpos = []
    if auto == nil
      textpos.push([savename, 0, 0, 0, Color.new(255, 255, 255), Color.new(125, 125, 125)])
    else
      textpos.push([savename + " Auto Save", 0, 0, 0, Color.new(255, 255, 255), Color.new(125, 125, 125)])
    end
    pbDrawTextPositions(@sprites["overlay2"].bitmap, textpos)
  end

  def pbDrawSaveText(savefiles, xoffset = 0, yoffset = 0)
    @sprites["overlay"].bitmap.clear
    pbSetSystemFont(@sprites["overlay"].bitmap)
    textpos = []
    # @savefiles=savefiles
    for i in 0...savefiles.length
      y = i * 45 + 8 - yoffset
      next if y < 0 || y + 4 > 9 * 45

      x = Graphics.width / 2
      colors = savefiles[i][1].start_with?("Anna's Wish") ? SaveNameColorsAlt : SaveNameColors
      textpos.push([savefiles[i][1], x, y, 2, *colors])
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
  end

  def pbToggleSelecting
    if @saveselecting
      @saveselecting = !@saveselecting
    else
      @saveselecting = true
    end
  end

  def pbMoveSaveSel(index)
    tts(@savefiles[index][1], true) if @savefiles[index]
    @index = index
    if index <= 7
      @sprites["saveselect"].y = index * 45
      pbDrawSaveText(@savefiles)
    else
      @sprites["saveselect"].y = 7 * 45
      pbDrawSaveText(@savefiles, 0, 45 * (index - 7))
    end
    if index == (@savefiles.length - 1) && @savefiles.length - 1 >= 8
      @sprites["savefile8"].visible = false if @sprites["savefile8"]
    else
      @sprites["savefile8"].visible = true if @sprites["savefile8"]
    end
    Graphics.update
  end

  def pbStartDeleteScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    addBackgroundOrColoredPlane(@sprites, "background", "loadbg", Color.new(248, 248, 248), @viewport)
  end

  def pbSetParty(trainer, mapid, switches)
    return if !trainer

    filename = pbGetPlayerCharset(:walk, trainer)
    @sprites["player"] = TrainerWalkingCharSprite.new(filename, @viewport)
    charwidth = @sprites["player"].bitmap.width
    charheight = @sprites["player"].bitmap.height
    @sprites["player"].x = CHAR_X_BASE - charwidth / 8
    @sprites["player"].y = CHAR_Y_BASE - charheight / 4 + 20
    @sprites["player"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)

    return if !trainer.party
    return if hidePlayerPossessions?(switches, mapid)

    for i in 0...trainer.party.length
      @sprites["party#{i}"] = PokemonIconSprite.new(trainer.party[i], @viewport)
      @sprites["party#{i}"].z = 99999
      @sprites["party#{i}"].x = PARTY_X_BASE + PARTY_X_OFFSET * (i & 1)
      @sprites["party#{i}"].y = PARTY_Y_BASE + PARTY_Y_OFFSET * (i / 2)
    end
  end

  def pbChoose(commands)
    @sprites["cmdwindow"].commands = commands
    lastread = nil
    loop do
      Graphics.update
      Input.update
      index = @sprites["cmdwindow"].index
      if index != lastread
        ttsText = @sprites["panel#{index}"].ttsText
        tts(ttsText || commands[index], true)
      end
      lastread = index
      pbUpdate
      if Input.trigger?(Input::C) && (!@saveselecting || @saveselecting == false)
        return index
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) # { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @commands = nil
    @textviewport.dispose
  end

  def pbCloseScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class PokemonLoad
  attr_accessor :currentsave

  def initialize(scene)
    @scene = scene
  end

  def pbTryLoadFile(savefile)
    begin
      File.open(savefile, "rb") { |f|
        @currentsave = Marshal.load(f)
      }
      if !@currentsave.is_a?(Hash)
        convertSaveFolder
        File.open(savefile, "rb") { |f|
          @currentsave = Marshal.load(f)
        }
      end
      return
    rescue => e
      @currentsave = nil
      raise sprintf("Corrupted save file:\n%s\n%s: %s", File.realpath(savefile), e.class, e.message)
    end
  end

  def pbStartDeleteScreen
    savefile = RTP.getSaveFileName("Game.rxdata")
    @scene.pbStartDeleteScene
    @scene.pbStartScene2
    if safeExists?(savefile)
      if Kernel.pbConfirmMessageSerious(_INTL("Delete all saved data?"))
        Kernel.pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
        if Kernel.pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
          Kernel.pbMessage(_INTL("Deleting all data.\nDon't turn off the power.\\wtnp[0]"))
          begin; File.delete(savefile); rescue; end
          begin; File.delete(savefile + ".bak"); rescue; end
          Kernel.pbMessage(_INTL("The save file was deleted."))
        end
      end
    else
      Kernel.pbMessage(_INTL("No save file was found."))
    end
    @scene.pbEndScene
    $scene = pbCallTitle
  end

  def pbStartLoadScreen
    $PokemonTemp   = PokemonTemp.new
    $game_temp     = Game_Temp.new
    $game_map      = nil
    Input.text_input = false
    commands      = []
    ids           = []
    trainer        = nil
    savefile       = RTP.getSaveSlotPath($Unidata[:saveslot])

    addCommand = Proc.new { |id, name|
      ids.push(id)
      commands.push(name)
    }

    if safeExists?(savefile)
      begin
        pbTryLoadFile(savefile)
      rescue => e
        dp e.message
      end
      if @currentsave.is_a?(Hash)
        trainer = @currentsave[:Trainer]
        framecount = @currentsave[:playtime]
        $game_system = @currentsave[:system]
        mapid = @currentsave[:map_id]
        switches = @currentsave[:switches]

        addCommand.call(:Continue, _INTL("Save File {1}", $Unidata[:saveslot]))
      end
    end

    versionStatus = nil
    if Updater.shouldUseBuiltInUpdater?
      addCommand.call(:CheckingForUpdates, _INTL("Updates: Checking..."))
    end

    addCommand.call(:NewGame, _INTL("New Game"))
    addCommand.call(:OtherSaves, _INTL("Other Save Files"))
    if safeExists?(savefile)
      addCommand.call(:DeleteSave, _INTL("Delete This Save File"))
    end
    addCommand.call(:Options, _INTL("Options"))
    addCommand.call(:SaveDir, _INTL("Save Directory"))
    addCommand.call(:Controls, _INTL("Controls"))
    if LANGUAGES.length >= 2
      addCommand.call(:Language, _INTL("Language"))
    end
    # addCommand.call(:Quit, _INTL("Quit Game"))

    ThreadLoader.awaitMainMenuData

    @scene.pbStartScene(commands, ids, trainer, framecount, mapid)
    @scene.pbSetParty(trainer, mapid, switches)
    @scene.pbStartScene2

    # Let's delay this wasning until Empo is on app store.
    # if $rpgplayer
    #   Kernel.pbMessage(_INTL("RPGPlayer is not supported. We recommend Empo instead."))
    # end

    if Rejuv && GAME_VERSION != 'dev' && File.exist?("Field_Effect_Manual.txt")
      Kernel.pbMessage(_INTL("Install Rejuvenation 14.0 separately, not in the same directory as an older version."))
      Kernel.pbMessage(_INTL("Using the same directory as the previous version causes performance issues and other errors."))
      if RTP.isPortable
        Kernel.pbMessage(_INTL("Make sure to back up your Save Data directory!"))
      end
      exit
    end

    if $Settings.updatePrompts == 0
      if versionStatus == :PatchUpdate
        unless Updater.handlePatchUpdate(true)
          Kernel.pbMessage(_INTL("Update prompts may be disabled in Options."))
        end
      elsif versionStatus == :MajorUpdate
        unless Updater.handleMajorUpdate
          Kernel.pbMessage(_INTL("Update prompts may be disabled in Options."))
        end
      elsif versionStatus == :EngineUpdate
        unless Updater.handleEngineUpdate(true)
          Kernel.pbMessage(_INTL("Update prompts may be disabled in Options."))
        end
      end
    end

    loop do
      cmd = @scene.pbChoose(commands)
      command = ids[cmd]
      deleting = false
      if command == :DeleteSave
        if Kernel.pbConfirmMessageSerious(_INTL("Are you sure you want to delete this save file?"))
          if Kernel.pbConfirmMessageSerious(_INTL("All data will be lost.  Confirm once more to proceed."))
            begin; File.delete(savefile); rescue; end
            deleting = true
            @scene.pbClearOverlay2
            @scene.pbEndScene
            return
            pbSetUpSystem
            scene = PokemonLoadScene.new
            screen = PokemonLoad.new(scene)
            screen.pbStartLoadScreen
          end
        end
        redo if deleting == false
      elsif command == :Continue
        next if !startPlayingSaveFile(savefile)

        return
      elsif command == :NewGame
        @scene.pbEndScene
        if $game_map && $game_map.events
          for event in $game_map.events.values
            event.clear_starting
          end
        end
        ThreadLoader.awaitRuntimeData
        $game_temp.common_event_id = 0 if $game_temp
        $scene               = Scene_Map.new
        Graphics.frame_count = 0
        Graphics.time_passed = 0
        Graphics.start_playing = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        $game_system         = Game_System.new
        $game_switches       = Game_Switches.new
        $game_variables      = Game_Variables.new
        $game_self_switches  = Game_SelfSwitches.new
        $game_screen         = Game_Screen.new
        $game_player         = Game_Player.new
        $PokemonMap          = PokemonMapMetadata.new
        $PokemonGlobal       = PokemonGlobalMetadata.new
        $PokemonStorage      = PokemonStorage.new
        $PokemonEncounters   = PokemonEncounters.new
        $PokemonTemp.begunNewGame = true
        getNGPData
        $MapFactory = PokemonMapFactory.new()
        $MapFactory.setup($cache.RXsystem.start_map_id) # calls setMapChanged
        $game_player.moveto($cache.RXsystem.start_x, $cache.RXsystem.start_y)
        $game_player.refresh
        $game_map.autoplay
        $game_map.update

        $Unidata[:TextLogIntro] ||= true # consider done if new game started since game intros should mention it (Unidata gets saved by createSaveSlot)
        createSaveSlot # find next available slot
        return
      elsif command == :OtherSaves
        # convertSaveFolder
        saveslots = []
        # Finding Other Save Files
        d = Dir.new(RTP.getSaveFolder)
        begin
          d.children.each do |file|
            next if !/^Game_[0-9]+.rxdata$/.match(file) && !/^Game.rxdata$/.match(file)
            next if !safeExists?(d.path + "/" + file)

            t = File.mtime(d.path + "/" + file) rescue pbGetTimeNow
            savetime = t.strftime("%c")
            info = saveinfo(d.path + file)
            savenumber = file.scan(/\d+/)[0].to_i
            savenumber = 1 if savenumber == 0
            slotname = (Reborn ? "" : _INTL("Save File") + " ") + savenumber.to_s + info
            saveslots.push([savenumber, slotname, false, true, savetime, file])
          end
        rescue
          logError($!, display: true)
        ensure
          d.close
        end

        # Specific Anna Smiles code
        anna_saves = []
        if Reborn
          d = Dir.new(RTP.getSaveFolder)
          begin
            d.children.each do |file|
              next if !file.start_with?("Anna's Wish")
              next if !safeExists?(d.path + "/" + file)

              info = saveinfo(d.path + file)
              savenumber = file.scan(/\d+/)[0].to_i
              slotname = "Anna's Wish" + info
              anna_saves.push([savenumber, slotname, false, true, nil, file])
            end
          rescue
            logError($!, display: true)
          ensure
            d.close
          end
          anna_saves.sort_by! { |arr| arr[0] }
          saveslots += anna_saves
        end

        if saveslots.length == 0
          Kernel.pbMessage(_INTL("You don't have any other save files."))
          next
        end
        saveslots.sort_by! { |arr| arr[0] }
        for i in 1..21 # move the commands and other graphics
          @scene.pbMoveSprites(i * 2)
          Graphics.update
        end
        @scene.pbDrawSaveCommands(saveslots)
        # @scene.pbDrawSaveText(saveslots)
        @selected = 0
        loop do
          Input.update
          Graphics.update
          if Input.repeat?(Input::DOWN)
            @selected = (@selected + 1) % saveslots.length
            @scene.pbMoveSaveSel(@selected)
          elsif Input.repeat?(Input::UP)
            @selected = (@selected - 1) % saveslots.length
            @scene.pbMoveSaveSel(@selected)
          elsif Input.repeat?(Input::L)
            @selected = [@selected - 7, 0].max
            @scene.pbMoveSaveSel(@selected)
          elsif Input.repeat?(Input::R)
            @selected = [@selected + 7, saveslots.length - 1].min
            @scene.pbMoveSaveSel(@selected)
          elsif Input.trigger?(Input::B)
            @scene.pbRemoveSaveCommands
            Graphics.update
            for i in 1..21 # move the commands and other graphics
              @scene.pbMoveSprites(i * -2)
              Graphics.update
            end
            @scene.pbToggleSelecting
            break
          elsif Input.trigger?(Input::X)
            message = _INTL("Enter the search string.")
            text = Kernel.pbMessageFreeText(message, "", 999, Graphics.width)
            next if text == ""

            index = nil
            results = []
            valarray = []
            for i in 0...saveslots.length
              if saveslots[i][1].downcase.include?(text.downcase)
                results.push(saveslots[i][1])
                valarray.push(i)
              end
            end
            if results.empty?
              Kernel.pbMessage(_INTL("No matches found."))
            elsif results.one?
              index = valarray[0]
            else
              message = _INTL("{1} matches found.", results.length)
              cmd = Kernel.pbMessage(message, results, -1)
              unless cmd == -1
                index = valarray[cmd]
              end
            end
            if index
              @selected = index
              @scene.pbMoveSaveSel(@selected)
            end
          elsif Input.trigger?(Input::C)
            @scene.pbRemoveSaveCommands
            tempsave = saveslots[@selected][0]
            savefile = saveslots[@selected][5]
            if savefile.start_with?("Anna's Wish")
              createSaveSlot
              return startPlayingSaveFile(RTP.getSaveFileName(savefile))
            end

            $Unidata[:saveslot] = tempsave
            @scene.pbEndScene
            pbSetUpSystem
            scene = PokemonLoadScene.new
            screen = PokemonLoad.new(scene)
            screen.pbStartLoadScreen
            return
          end
        end
      elsif command == :Options
        scene = PokemonOptionScene.new
        screen = PokemonOption.new(scene)
        pbFadeOutIn(99999) { screen.pbStartScreen }

      elsif command == :Controls
        controlsDialogue
      elsif command == :SaveDir
        folderpath = RTP.getSaveFolder
        if mobile?
          Kernel.pbMessage(wrap_path(folderpath))
        elsif System.platform[/Windows/]
          folderpath.gsub!('\\', '\\\\')
          folderpath.gsub!('/', '\\\\')
          system("explorer #{folderpath}")
        elsif System.platform[/macOS/]
          # pathstr = "~\\Library\\Application Support\\#{GAME_TITLE}\\"
          system("open '#{folderpath}'")
        elsif System.platform[/Linux/]
          # System.open(folderpath)
          system("xdg-open '#{folderpath}'")
        end
      elsif command == :Language
        @scene.pbEndScene
        $Settings.language = pbChooseLanguage
        saveSettings
        pbLoadLanguage
        $scene = pbCallTitle
        return
      elsif command == :CheckingForUpdates
        Updater.updateDetails
      end
    end
    @scene.pbEndScene
    return
  end

  def startPlayingSaveFile(savefile)
    unless safeExists?(savefile)
      pbPlayBuzzerSE()
      return false
    end
    pbTryLoadFile(savefile) # Needed for Anna's Wish
    startTimer
    @scene.pbEndScene
    $Trainer = @currentsave[:Trainer]
    playtime = @currentsave[:playtime]
    if playtime.bit_length < 31
      Graphics.frame_count  = playtime
      playtime              = 0
    end
    $game_system            = @currentsave[:system]
    $game_switches          = @currentsave[:switches]
    $game_variables         = @currentsave[:variable]
    $game_self_switches     = @currentsave[:self_switches]
    $game_screen            = @currentsave[:game_screen]
    $game_player            = @currentsave[:game_player]
    $PokemonGlobal          = @currentsave[:PokemonGlobal]
    $PokemonMap             = @currentsave[:PokemonMap]
    $PokemonBag             = @currentsave[:PokemonBag]
    $PokemonStorage         = @currentsave[:PokemonStorage]

    ThreadLoader.awaitRuntimeData

    # TODO: Move to Reborn `gameSetup`, check hierarchy in map setup
    if Reborn && $game_screen.regionalWeather.nil?
      $game_screen.regionalWeather = RegionalWeather.new
    end

    $MapFactory = PokemonMapFactory.new()
    $MapFactory.setup(@currentsave[:map_id], true)
    if loadSavedMap.nil?
      $MapFactory.loadMap(@currentsave[:Map]) # actual saved map data
    end
    $game_map = $MapFactory.map

    Graphics.time_passed = Graphics.frame_count.clone + playtime
    Graphics.start_playing = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    checkConversions
    $Trainer.pokedex.refreshDex # Ensures Pokedex matches loaded Pokemon data
    introduceNewStuff
    getNGPData

    $PokemonBag.initTrackerData if !$PokemonBag.itemtracker
    if $PokemonGlobal.safesave
      if pbMapInterpreterRunning?
        pbMapInterpreter.setup(nil, 0)
      end
      $MapFactory.setup($game_map.map_id) # calls setMapChanged
      # $game_player.center($game_player.x, $game_player.y)
    else
      $MapFactory.setMapChanged($game_map.map_id)
    end
    if !$game_map.events # Map wasn't set up
      $game_map = nil
      $scene = nil
      Kernel.pbMessage(_INTL("The map is corrupt. The game cannot continue."))
      return true
    end
    $PokemonMap.updateMap
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    pbAutoplayOnSave
    $game_map.update
    # TODO: Move to Reborn `gameSetup`
    # some bullshit, don't worry about it
    if $game_variables[:Some_Bullshit] > 0
      $game_variables[:Some_Bullshit] += 1
      $game_map.need_refresh = true
    end
    if Reborn && $game_switches[:Postgame]
      $Trainer.postgame = $game_variables[569]
    end
    if !$game_screen.shakeX || !$game_screen.shakeY
      $game_screen.initAddedVars
    end
    # end bullshit
    for event in $game_map.events.values
      event.unlock
    end
    $game_switches[:Mid_quicksave] = false
    $game_switches[:Stop_Icycle_Falling] = false
    $game_switches[:Enable_Event_Save] = false
    stopTimer
    $scene = Scene_Map.new
    $game_player.center($game_player.x, $game_player.y)
    Kernel.pbUpdateVehicle
    gameSetup()
    if $cache.mapdata[$game_map.map_id].Outdoor
      $game_screen.setWeather
    end
    return true
  end

  def loadSavedMap
    # If using force load, leave method.
    if ($DEBUG && (Input.press?(Input::CTRL) || Input.pressex?(:L))) || forceLoadMapConditions?(@currentsave[:map_id]) ||
      (Input.press?(Input::A) && Input.press?(Input::X))
      return :forceload
    end

    # If battle frontier exit
    if pbBattleChallenge.pbInChallenge?
      $game_system.newInterp
      $MapFactory.setup(@currentsave[:map_id], true)
      return :frontier
    end

    return nil
  end
end

def saveinfo(savefile)
  begin
    data = nil
    File.open(savefile, "rb") { |f|
      data = Marshal.load(f)
    }
    if data.is_a?(Hash)
      trainer = data[:Trainer]
      if trainer.postgame != nil
        info = _INTL(" - {1} - {2} legendaries", trainer.name, trainer.postgame)
      else
        info = _INTL(" - {1} - {2} badges", trainer.name, trainer.numbadges)
      end
      return info
    else
      info = _INTL(" - legacy save file")
    end
  rescue
    if data.is_a?(Hash)
      info = _INTL(" - save corrupted")
    else
      info = _INTL(" - legacy save file")
    end
  end
  return info
end

# To be defined per game.
def gameSetup(); end

def createSaveSlot
  j = 0
  loop do
    j += 1
    checksave = RTP.getSaveSlotPath(j)
    if !safeExists?(checksave)
      changeCurrentSaveSlot(j)
      break
    end
  end
end

def changeCurrentSaveSlot(savenum)
  $Unidata[:saveslot] = savenum
  saveClientData
end

def restrictOnlineFeatures
  pws = pbActivePasswords
  $game_switches[:No_Online_Randbats] = true if pws.any? { |pw| pw.disablesOnlineRandBats }
  $game_switches[:No_Online_Trades] = true if pws.any? { |pw| pw.disablesOnlineTrading }
end

def checkConversions
  # This method is used for system changes that require saved data to be altered in some way,
  # regardless of whether or not it's game breaking.
  pbUpdateRegionalDexes

  if !$Trainer.pokedex.instance_variable_get(:@dexList).values[0].is_a?(PokedexListEntry)
    convertDexToEntries
  end

  if $Trainer.trainertype.is_a?(Integer)
    enforceTrainerType
  end

  # following bit should be only hit by older files
  if $game_switches[:NotPlayerCharacter] && !$game_switches[:InterceptorsWish]
    if $game_variables[:PlayerDataBackup][8] == nil
      $game_variables[:PlayerDataBackup][8] = $PokemonStorage
    end
  end

  # Last check through for old temp conversions, most of these methods should be able to be
  # safely removed after a while.
  if !$game_system.game_version || (Reborn && $game_system.game_version == "e19.16")
    # updating storage boxes, can be removed after a while
    if $PokemonStorage && $PokemonStorage.boxes.length < STORAGEBOXES
      $PokemonStorage.upTotalBoxes(STORAGEBOXES)
    end
    tempConvertNatures
    if Rejuv
      $Trainer.achievements = Achievements.new() if !$Trainer.achievements
    end
    $Trainer.pokedex.updateGenderFormEntries # ensure things are updated, remove after a bit ig

    if $game_switches[:Randomized_Challenge]
      Kernel.pbMessage(_INTL("Note: The game has detected you were previously playing a randomizer. Your old randomizer data will no longer function."))
      if Kernel.pbConfirmMessage(_INTL("Would you like to re-randomize your game?"))
        pbFadeOutIn(99999) {
          RandomizerScene.new(RandomizerSettings.new)
          $Randomizer.randomize if $game_switches[:Randomized_Challenge]
        }
      else
        if Kernel.pbConfirmMessageSerious(_INTL("You will still be unable to access any online features. Are you sure you wish to continue without randomizing?"))
          $game_switches[:Disabled_Randomizer] = true
          $game_switches[:Randomized_Challenge] = false
        else
          pbFadeOutIn(99999) {
            RandomizerScene.new(RandomizerSettings.new)
            $Randomizer.randomize if $game_switches[:Randomized_Challenge]
          }
        end
      end
    end
  end

  if !$game_switches[:Disabled_Randomizer] && $game_switches[:Randomized_Challenge]
    $rndcache = nil
    if File.exist?("Randomizer Data/settings.txt")
      str = File.read("Randomizer Data/settings.txt")
      settings = RandomizerSettings.new()
      settings.load(str)
      regenerate = (settings.to_s != $game_variables[:Randomizer_Settings] || settings.random.seed != $game_variables[:Randomizer_Seed])
      $Randomizer = Randomizer.new(settings)
      if regenerate
        settings.load($game_variables[:Randomizer_Settings] + "\n" + $game_variables[:Randomizer_Seed].to_s + "\n" + $game_variables[:Randomizer_Items].to_s)
        Kernel.pbMessage(_INTL("The game will now generate your randomizer files."))
        $Randomizer.randomize
      end
    else
      settings = RandomizerSettings.new()
      str = "#{$game_variables[:Randomizer_Settings]}\n#{$game_variables[:Randomizer_Seed]}\n#{$game_variables[:Randomizer_Items]}"
      settings.load(str)
      $Randomizer = Randomizer.new(settings)
      Kernel.pbMessage(_INTL("The game will now generate your randomizer files."))
      $Randomizer.randomize
    end
    if !$rndcache&.loaded
      $rndcache.load()
    end
  end

  # Restrict online play
  restrictOnlineFeatures

  allpokemon = findAllPokemon

  # Apply pokemon object attribute changes
  allpokemon.each { |pokemon|
    pokemon.removeDeprecatedAttributes
    pokemon.genderflag = [:M, :F, :N][pokemon.genderflag] if pokemon.genderflag.is_a?(Numeric)
    # Fix missing `pbRecordFirstMoves` call for cases where `pbAddPokemon` was not used
    pokemon.firstmoves ||= []
  }

  # Change EXPALLOFF back to EXPALL (added Rejuv 13.5, removed Reborn 19.6)
  $PokemonBag.pbChangeItem(:EXPALLOFF, :EXPALL) if $PokemonBag.pbHasItem?(:EXPALLOFF)

  # Resort items to their correct pockets (needed in particular to relocate red/blue orbs from items pocket to crystals pocket in reborn)
  $PokemonBag.rearrange

  # Convert berries to use BerryPlantData
  $PokemonGlobal.eventvars.each do |k, v|
    if v.is_a?(BerryPlantData)
      # Fix half-conversions where it was given an empty value and properly reset it.
      v.reset if v.berry_id.is_a?(Numeric)
      # Fix half-conversions where it was given the correct berry but no data
      v.data = $cache.items[v.berry_id].berry if v.berry_id && !v.data
    end
    # Look for berry data structures
    next unless v.is_a?(Array) && [6, 7].include?(v.length)

    # Old berry data conversion
    if v[1] != 0 && v[1].is_a?(Integer)
      for i in $cache.items.keys
        if $cache.items[i].checkFlag?(:ID) == v[1]
          v[1] = i
          break
        end
      end
    end

    berryData = BerryPlantData.new
    berryData.growth_stage = v[0]
    unless v[1] == 0
      berryData.berry_id = v[1]
      berryData.data = $cache.items[v[1]].berry
    end
    berryData.watered_this_stage = v[2]
    berryData.time_alive = (v[3].to_i / 60) * 60 # accurate to the minute
    berryData.time_last_updated = berryData.time_alive
    berryData.watering_count = v[4]

    $PokemonGlobal.eventvars[k] = berryData
  end

  # Change pokedex sorting mode to be a hash containing values for each pokedex rather than a single value for all pokedexes
  $PokemonGlobal.pokedexMode = {} if $PokemonGlobal.pokedexMode.is_a?(Integer)

  # run method overrides from individual games' scripts to handle any game-specific conversions
  gameSpecificConversion(allpokemon)

  $Trainer.pokedex.refreshDex(true) if $Trainer.pokedex.storedGen != Gen || $Trainer.pokedex[:BULBASAUR][0][:gender].is_a?(Array)
end

# New stuff to tell to returning players
def introduceNewStuff
  return if Desolation && checkVersionOlderThan("7.0.0-alpha.0") # Can be removed once the version has been released

  # Text log / Battle log
  version = case true # The version that this message was added in
    when Reborn then "19.6.0-beta.88"
    when Rejuv then "14.0.21"
    when Desolation then "7.0.0-alpha.0"
  end
  if !$Unidata[:TextLogIntro] && version && checkVersionOlderThan(version)
    Kernel.pbMessage(_INTL("{1} now features a logging feature for dialogue as well as in-battle messages!", GAME_TITLE.gsub("Pokemon", "Pokémon")))
    Kernel.pbMessage(_INTL("To access the log, press S during any dialogue or in battle, or hold S anywhere in the overworld."))
    $Unidata[:TextLogIntro] = true
    saveClientData
  end
end

def checkVersionOlderThan(version)
  require 'rubygems'

  return false if GAME_VERSION == "dev"
  return false if $game_system.game_version == "dev"
  # If you're running an ancient version that isn't dev, aka Reborn e19 or other
  return true if $game_system.game_version.is_a?(String) && $game_system.game_version.downcase.match?(/[^0-9\.]/)
  # currentVersion = Gem::Version.new(GAME_VERSION)
  checkVersion = Gem::Version.new(version)
  saveVersion = Gem::Version.new($game_system.game_version)

  return saveVersion < checkVersion
end

def wrap_path(path, max_length = 40)
  wrapped = ""

  while path.length > max_length
    last_slash = path.rindex('/', max_length)
    break if last_slash.nil?

    wrapped += path[0..last_slash] + "\n"
    path = path[(last_slash + 1)..]
  end

  wrapped + path
end

def convert(*speciesList)
  for species in speciesList
    entry = $Trainer.pokedex.dexList[species]
    next unless entry # Species not in dexList (Reborn Gen8+ Pokemon in Gen 7)
    yield(entry)
  end
end

def convertGenderFormMons(mons)
  mons.each { |pokemon|
    if [:MEOWSTIC, :INDEEDEE, :BASCULEGION, :OINKOLOGNE].include?(pokemon.species)
      form = pokemon.form
      pokemon.form = 0
      pokemon.genderflag = [:M, :F][form % 2] # modulo to ensure form is bound to gender index
      pokemon.calcStats
    end
  }
end

class PokeBattle_Pokemon
  def removeDeprecatedAttributes
    # Remove attributes that are no longer used, to cut down on unnecessary save file size
    attrs = []
    version = case true
      when Reborn then "19.6.0-beta.91"
      when Rejuv then "14.0.25"
      when Desolation then "7.0.0-alpha.0"
    end
    if version && checkVersionOlderThan(version)
      attrs += [
        :@itemRecycle, :@itemInitial, :@itemReallyInitialHonestlyIMeanItThisTime,
        :@obedient, :@belch, :@piece, :@landCritical, :@corrosiveGas, :@rampCrestUsed,
        :@megaEvo,
        :@cool, :@beauty, :@cute, :@smart, :@tough, :@sheen,
        :@ribbons, :@poklevel, :@otgender, :@abilityflag,
        # abilityflag is used in convertMon but that happens before this
      ]
    end
    attrs.each { |a| self.remove_instance_variable(a) if self.instance_variable_defined?(a) }
  end
end

class PokeBattle_Trainer
  def convertOldCharacterSwitch
    @money = @tempmoney
    @badges = @tempbadges
    @id = @tempid
  end

  def removeDeprecatedAttributes
    # Remove attributes that are no longer used, to cut down on unnecessary save file size
    attrs = []
    version = case true
      when Reborn then "19.6.0-beta.91"
      when Rejuv then "14.0.25"
      when Desolation then "7.0.0-alpha.0"
    end
    if version && checkVersionOlderThan(version)
      attrs += [
        # Used to be used for character switching in Reborn
        :@tempmoney, :@tempbadges, :@tempid,
        # Opponent trainer stuff, used to be initialized as empty strings on all trainers
        :@openingLine, :@aceline, :@defeatline,
      ]
    end
    attrs.each { |a| self.remove_instance_variable(a) if self.instance_variable_defined?(a) }
  end
end

def forceLoadMapConditions?(mapid = nil); false; end
def forceAuraBreakZygarde; false; end

class PokemonSaveScene
  TXT_COLOR = :Blue3
  TXT_COLOR_MAP = :Green2

  def pbStartScreen
    colors = isCurrentWindowskinDark ? ColorTags : LightColorTags
    txt_color, txt_color_map = colors[TXT_COLOR], colors[TXT_COLOR_MAP]
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    totalsec = Graphics.time_passed / 40 + (Process.clock_gettime(Process::CLOCK_MONOTONIC) - Graphics.start_playing).to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    mapname = pbGetMapNameFromId($game_map.map_id)
    mapstr = "<ac>{1}{2}</c3></ac>"
    loctext = _INTL(mapstr, txt_color_map, mapname)
    tts(mapname)
    loctext += _INTL("Player<r>{1}{2}</c3><br>", txt_color, $Trainer.name)
    tts($Trainer.name)
    postgameCounter = Reborn ? $game_variables[569] : 0
    if postgameCounter > 0
      loctext += _INTL("Legendaries<r>{1}{2}</c3><br>", txt_color, postgameCounter)
      tts("#{postgameCounter} legendaries")
    else
      loctext += _INTL("Badges<r>{1}{2}</c3><br>", txt_color, $Trainer.numbadges)
      tts("#{$Trainer.numbadges} badges")
    end
    if $Trainer.pokedex.canViewDex
      loctext += _INTL("Pokédex<r>{1}{2}/{3}</c3><br>", txt_color, $Trainer.pokedex.getOwnedCount, $Trainer.pokedex.getSeenCount)
      tts("Pokédex: owned #{$Trainer.pokedex.getOwnedCount} / seen #{$Trainer.pokedex.getSeenCount}")
    end
    if hour > 0
      loctext += _ISPRINTF("Time<r>{1:s}{2:02d}h {3:02d}m</c3><br>", txt_color, hour, min)
      tts("Time: #{hour} hours, #{min} minutes")
    else
      loctext += _ISPRINTF("Time<r>{1:s}{2:02d}m</c3><br>", txt_color, min)
      tts("Time: #{min} minutes")
    end
    if $Unidata[:saveslot] > 1
      loctext += _INTL("Save File<r>{1}{2}</c3><br>", txt_color, $Unidata[:saveslot])
      tts("Save File: #{$Unidata[:saveslot]}")
    else
      loctext += _INTL("Save File<r>{1}1</c3><br>", txt_color)
      tts("Save File: 1")
    end
    @sprites["locwindow"] = Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport = @viewport
    @sprites["locwindow"].x = 0
    @sprites["locwindow"].y = 0
    @sprites["locwindow"].width = 228 if @sprites["locwindow"].width < 228
    @sprites["locwindow"].visible = true
  end

  def pbEndScreen
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

def pbEmergencySave
  oldscene = $scene
  $scene = nil
  Kernel.pbMessage(_INTL("The script is taking too long.  The game will restart."))
  return if !$Trainer

  if safeExists?(RTP.getSaveSlotPath(data[:saveslot]))
    File.open(RTP.getSaveSlotPath(data[:saveslot]), 'rb') { |r|
      File.open(RTP.getSaveSlotPath(data[:saveslot] + ".bak"), 'wb') { |w|
        while s = r.read(4096)
          w.write s
        end
      }
    }
  end
  pbHandleSave(confirm: false)
  $scene = oldscene
end

# Returns :Success (game was saved successfully), :Failure (save failed for some reason, should never happen), or :Cancelled (player chose not to save)
def pbHandleSave(quick: false, confirm: true, cancancel: true)
  createnew = false
  if confirm
    choice = Kernel.pbMessage(_INTL("Would you like to save the game?"), [_INTL("Save"), _INTL("New File"), _INTL("Don't Save")], cancancel ? -1 : 0)
    return :Cancelled if choice == 2 || choice == -1

    createnew = choice == 1
  end

  oldslot = $Unidata[:saveslot]
  createSaveSlot if createnew

  if pbSave
    $PokemonTemp.begunNewGame = false
    if createnew
      message = _INTL("{1} saved the game to a new file,\n\\c[1]Save File {2}\\c[1].", $Trainer.name, $Unidata[:saveslot])
    else
      message = confirm ? _INTL("{1} saved the game.", $Trainer.name) : _INTL("The game was saved.")
    end
    message = "\\se[]" + message + "\\se[save]"
    ret = :Success
  else
    changeCurrentSaveSlot(oldslot)
    message = "\\se[]" + _INTL("Save failed.") + "\\se[buzzer]"
    ret = :Failure
  end

  message += "\\wtnp[30]" unless quick
  Kernel.pbMessage(message)
  return ret
end

def pbSave
  # Handling backups
  backupsave = nil
  if $Settings.backup == 0
    counter = 0
    trainer    = nil
    mapid      = nil
    framecount = 0
    system     = nil

    # Loading current save
    if safeExists?(RTP.getSaveSlotPath($Unidata[:saveslot]))
      File.open(RTP.getSaveSlotPath($Unidata[:saveslot]), 'rb') { |save|
        data = Marshal.load(save)
        trainer    = data[:Trainer]
        framecount = data[:playtime]
        system     = data[:system]
        mapid      = data[:map_id]
      }

      # Figuring out which save number this is
      number = 1
      if trainer.saveNumber
        number += trainer.saveNumber
      end
      if !trainer.backupNames
        trainer.backupNames = []
        $Trainer.backupNames = []
        number = 1
      end

      # Delete oldest saves and fix the `backupNames` queue
      while $Trainer.backupNames.length > $Settings.maxBackup
        savename = $Trainer.backupNames.delete_at(0)
        next if savename.nil?
        next if !safeExists?(RTP.getSaveFileName(savename))

        begin; File.delete(RTP.getSaveFileName(savename)); rescue; end
      end

      # Giving the current save a different name
      totalsec = framecount / 40 # Graphics.frame_rate  #Because Turbo exists
      hour = totalsec / 60 / 60
      min = totalsec / 60 % 60
      mapname = pbGetMapNameFromId(mapid)
      mapname = mapname.gsub("é", "e").gsub(/[^0-9A-Za-z ]/, '')
      trainername = trainer.name
      trainername = trainername.gsub(/[^0-9A-Za-z ]/, '')
      savename = "Game" + ($Unidata[:saveslot] == 1 ? "" : "_" + $Unidata[:saveslot].to_s)
      if $Trainer.postgame != nil
        savename += " - #{number} - #{trainername} - #{hour}h #{min}m - #{trainer.postgame} legendaries - #{mapname}.rxdata"
      else
        savename += " - #{number} - #{trainername} - #{hour}h #{min}m - #{trainer.numbadges} badges - #{mapname}.rxdata"
      end
      $Trainer.lastSave   = savename
      $Trainer.saveNumber = number
      $Trainer.backupNames.push(savename)
      backupsave = RTP.getSaveFileName(savename)
    end
  end

  # The actual saving handling
  tmpsave = RTP.getSaveFileName("tmp.rxdata")
  save = RTP.getSaveSlotPath($Unidata[:saveslot])
  saved = saveNew(tmpsave)

  if saved
    unless backupsave.nil?
      File.rename(save, backupsave)
    else
      begin File.delete(save); rescue; end
    end
    File.rename(tmpsave, save)
  end

  return saved
end

def saveNew(path)
  $Trainer.metaID = $PokemonGlobal.playerID
  getNGPData # calls saveClientData
  if $cache.RXsystem.respond_to?("magic_number")
    $game_system.magic_number = $cache.RXsystem.magic_number
  else
    $game_system.magic_number = $cache.RXsystem.version_id
  end
  if $game_switches[:Randomized_Challenge] # TODO: Move to `makeSaveHash` override in Randomizer directory
    $game_variables[:Randomizer_Items] = $Randomizer.randomItemCount
    $game_variables[:Randomizer_Seed] = $Randomizer.settings.random.seed
    $game_variables[:Randomizer_Settings] = $Randomizer.settings.to_s
  end
  if Reborn && $game_switches[:Postgame] # TODO: Move to `makeSaveHash` override in Reborn directory
    $Trainer.postgame = $game_variables[569]
  end
  $game_system.game_version = GAME_VERSION
  $game_system.save_count += 1
  savehash = makeSaveHash
  begin
    File.open(path, "wb") { |f|
      Marshal.dump(savehash, f)
    }

    Graphics.frame_reset
  rescue
    return false
  end
  return true
end

def makeSaveHash
  playtime = Graphics.time_passed + 40 * (Process.clock_gettime(Process::CLOCK_MONOTONIC) - Graphics.start_playing).to_i # turn into frames
  savehash = {}
  savehash[:Trainer]        = $Trainer
  savehash[:playtime]       = playtime
  savehash[:system]         = $game_system
  savehash[:map_id]         = $game_map.map_id
  savehash[:switches]       = $game_switches
  savehash[:variable]       = $game_variables
  savehash[:self_switches]  = $game_self_switches
  savehash[:game_screen]    = $game_screen
  savehash[:Map]            = $MapFactory.map
  savehash[:position]       = [$game_player.x, $game_player.y]
  savehash[:game_player]    = $game_player
  savehash[:PokemonGlobal]  = $PokemonGlobal
  savehash[:PokemonMap]     = $PokemonMap
  savehash[:PokemonBag]     = $PokemonBag
  savehash[:PokemonStorage] = $PokemonStorage
  # savehash[:Interpreter]    = pbMapInterpreter

  return savehash
end

def makeSaveFromHash(hash, name = "Anna's Wish Game")
  # Making the save file name
  if $Unidata[:saveslot] > 1
    savename = name + "_" + $Unidata[:saveslot].to_s + ".rxdata"
  else
    savename = name + ".rxdata"
  end

  # Saving the hash in a file
  File.open(RTP.getSaveFileName(savename), "wb") { |f|
    f.write(hash)
  }
end

class PokemonSave
  def initialize(scene)
    @scene = scene
  end

  def pbDisplay(text, brief = false)
    @scene.pbDisplay(text, brief)
  end

  def pbDisplayPaused(text)
    @scene.pbDisplayPaused(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end
end

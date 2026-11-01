def getNGPData
  cprint "Checking for WLL save..."
  findWLLSave()
  $Unidata[:WLL] ||= false
  cprint "done.\n"
  cprint "Checking for Reborn save..."
  findRebornSave()
  $Unidata[:Reborn] ||= false
  $Unidata[:RebornPlayerName] ||= ["Alice", "Lucia", "Kuro", "Vero", "Ari", "Decibel"].sample
  $Unidata[:RebornBlakeRoute] ||= 0
  cprint "done.\n"
  cprint "Checking for Deso save..."
  findDesoSave()
  $Unidata[:Deso] ||= false
  $Unidata[:DesoPlayerName] ||= ["Chad", "Sienna", "Diego", "Daniella", "Robin", "Avery"].sample
  cprint "done.\n"
  if $Trainer
    $Unidata[:ViewedPrologue] = $game_variables[16] > 4 || $Trainer.numbadges > 1 if !$Unidata[:ViewedPrologue]
    $Unidata[:NewGamePlus] = $game_variables[659] > 20 || $Trainer.numbadges > 1 if !$Unidata[:NewGamePlus]
    $Unidata[:BadgeCount] = $Trainer.numbadges if !$Unidata[:BadgeCount] || $Trainer.numbadges > $Unidata[:BadgeCount]
  end
  $Unidata[:ViewedPrologue] ||= false
  $Unidata[:NewGamePlus] ||= false
  $Unidata[:BadgeCount] ||= 0
  $Unidata[:FinishedV14Story] = $game_variables[812] >= 154 if !$Unidata[:FinishedV14Story]
  $Unidata[:FinishedV14StoryRene] = $game_variables[912] >= 120 if !$Unidata[:FinishedV14StoryRene]
  $Unidata[:EizenTowerSkip] = $game_variables[920] >= 7 if !$Unidata[:EizenTowerSkip]
  $Unidata[:AquariumQuestSkip] = $game_variables[691] == 4 if !$Unidata[:AquariumQuestSkip]
  $Unidata[:NecrozmaSkip] = $game_variables[474] == 999 if !$Unidata[:NecrozmaSkip]
  $Unidata[:NarcyQuestComplete] = $game_variables[274] >= 42 if !$Unidata[:NarcyQuestComplete]
  $Unidata[:SpiritShogunBeaten] = $game_switches[2205] if !$Unidata[:SpiritShogunBeaten]
  $Unidata[:NullQuestComplete] = $game_variables[431] >= 16 if !$Unidata[:NullQuestComplete]
  $Unidata[:RaiCrest] = ($game_switches[1933] && $game_switches[1662]) if !$Unidata[:RaiCrest]
  $Unidata[:SuiCrest] = ($game_switches[1934] && $game_switches[1661]) if !$Unidata[:SuiCrest]
  $Unidata[:EntCrest] = ($game_switches[1932] && $game_switches[1663]) if !$Unidata[:EntCrest]
  $Unidata[:CeleCrest] = $game_switches[1936] if !$Unidata[:CeleCrest]
  $Unidata[:GlimmoraniteA] = $game_switches[2211] if !$Unidata[:GlimmoraniteA]
  $Unidata[:EspurrSkip] = $game_variables[533] >= 3 if !$Unidata[:EspurrSkip]
  $Unidata[:ChasmSkip] = $game_variables[525] >= 5 if !$Unidata[:ChasmSkip]
  $Unidata[:ZoruaSkip] = $game_switches[1028] if !$Unidata[:ZoruaSkip]
  $Unidata[:ExcellusSkip] = $game_variables[514] >= 5 if !$Unidata[:ExcellusSkip]
  $Unidata[:GrowlitheSkip] = $game_variables[539] >= 3 if !$Unidata[:GrowlitheSkip]
  $Unidata[:HeracrossSkip] = $game_variables[694] >= 7 if !$Unidata[:HeracrossSkip]
  $Unidata[:QuizMirrorSkip] = $game_variables[96] >= 137 if !$Unidata[:QuizMirrorSkip]
  $Unidata[:HiddenLibrarySkip] = $game_variables[265] >= 11 if !$Unidata[:HiddenLibrarySkip]
  $Unidata[:ShaydaCharm] = $game_variables[951] >= 13 if !$Unidata[:ShaydaCharm]
  $Unidata[:OpenedPrologueSafe] = $game_switches[2076] if !$Unidata[:OpenedPrologueSafe]

  saveClientData
end

def findWLLSave(path = getSavedGamesFolder)
  return true if $Unidata[:WLL]

  Dir.each_child(path) { |file|
    next if !File.directory?(path + file)
    next if !file.include?("Where Love Lies")

    newpath = path + file + "/"
    Dir.each_child(newpath) { |save|
      if /^Game(_[0-9]+)?.rxdata$/.match(save)
        return true if checkForCompletion(newpath + save, :WLL)
      end
    }
  }
  return false
end

def findRebornSave(path = getSavedGamesFolder)
  return true if $Unidata[:Reborn] && $Unidata[:RebornPlayerName] && $Unidata[:RebornBlakeRoute]

  Dir.each_child(path) { |file|
    next if !File.directory?(path + file)
    next if !file.include?("Reborn")

    newpath = path + file + "/"
    Dir.each_child(newpath) { |save|
      if /^Game(_[0-9]+)?.rxdata$/.match(save)
        return true if checkForCompletion(newpath + save, :Reborn)
      end
    }
  }
  return false
end

def findDesoSave(path = getSavedGamesFolder)
  return true if $Unidata[:Deso] && $Unidata[:DesoPlayerName]

  Dir.each_child(path) { |file|
    next if !File.directory?(path + file)
    next if !file.include?("Desolation")

    newpath = path + file + "/"
    Dir.each_child(newpath) { |save|
      if /^Game(_[0-9]+)?.rxdata$/.match(save)
        return true if checkForCompletion(newpath + save, :Deso)
      end
    }
  }
  return false
end

def getSavedGamesFolder
  if RTP.isPortable
    savefolder = "Save Data/"
    Dir.mkdir(savefolder) unless File.exist?(savefolder)
    return savefolder
  end

  savefolder = RTP.getSaveFolder()
  require 'pathname'
  return Pathname.new(savefolder).parent.to_s + "/"
end

def checkForCompletion(file, game)
  return false if !game

  File.open("Scripts/ConversionClasses.rb") { |f| eval(f.read) }
  # file needed to check old classes
  trainer = nil
  framecount = nil
  game_system = nil
  pokemonSystem = nil
  mapid = nil
  switches = []
  variables = []
  oldSaveFormat = false
  begin
    File.open(file) { |f|
      t = Marshal.load(f)
      if !t.is_a?(Hash)
        return false if game == :Deso
        trainer = t
        oldSaveFormat = true
        framecount = Marshal.load(f)
        game_system = Marshal.load(f)
        pokemonSystem = Marshal.load(f)
        mapid = Marshal.load(f)
        switches = Marshal.load(f)
        variables = Marshal.load(f)
      else
        save = t
        trainer = save[:Trainer]
        framecount = save[:playtime]
        game_system = save[:system]
        mapid = save[:map_id]
        switches = save[:switches]
        variables = save[:variables]
      end
    }
    return false if !trainer.is_a?(PokeBattle_Trainer)
    return false if !framecount.is_a?(Numeric)
    return false if !game_system.is_a?(Game_System)
    return false if !mapid.is_a?(Numeric)
  rescue => e
    puts e.message
    return false
  end
  case game
    when :WLL
      if switches[88] || variables[7] >= 139
        $Unidata[:WLL] = true
        return true
      end
    when :Reborn
      if switches[1305] # Has the player become the Champion?
        $Unidata[:Reborn] = true
        $Unidata[:RebornPlayerName] = trainer.name
        # If switch 506 is set, the player has refused to give Blake the ring => Lin has Samson's Conkeldurr (value 1)
        # Otherwise, the player has given Blake the ring => Lin has Ciel's Togekiss (value 0)
        $Unidata[:RebornBlakeRoute] = switches[506] ? 1 : 0
        return true
      end
    when :Deso
      if switches[796] # Has the player become John Desolation Episode 6 (Defeated Reeve)
        $Unidata[:Deso] = true
        $Unidata[:DesoPlayerName] = trainer.name
        return true
      end
  end
  return false
end

#class Battle_Data; end # required to load deso save
class RegionalWeather; end # required to load reborn save
class ControlConfig; end # required to load WLL saves

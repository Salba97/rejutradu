def buildClientData
  $Unidata = {}
  $Unidata[:saveslot] = 1
  lastsavefile = RTP.getSaveFileName("LastSave.dat")
  if File.exist?(lastsavefile)
    $Unidata[:saveslot] = File.open(lastsavefile).first.to_i
  end
  File.delete(RTP.getSaveFileName("latest_save.txt")) if File.exist?(RTP.getSaveFileName("latest_save.txt"))
  $Unidata[:saveslot] = 1 if $Unidata[:saveslot] == 0
  $Settings = PokemonOptions.new
  saveSettings
  saveClientData
end

def loadClientData
  begin
    File.open(RTP.getSaveFileName("Game.dat")) { |f|
      $Unidata = Marshal.load(f)
      $Unidata.delete(:debugUnidata)
    }
  rescue
    dp("Client data is corrupted and will be deleted. Save files will not be affected.")
    File.delete(RTP.getSaveFileName("Game.dat")) if File.exist?(RTP.getSaveFileName("Game.dat"))
    buildClientData
  end
end

def saveClientData(data = $Unidata)
  return if data[:debugUnidata]
  save_data(data, RTP.getSaveFileName("Game.dat"))
end

def saveSettings(set = $Settings)
  save_data(set, RTP.getSaveFileName("Settings.dat"))
end

def loadSettings
  begin
    File.open(RTP.getSaveFileName("Settings.dat")) { |f|
      $Settings = Marshal.load(f)
      $Settings.fixMissingValues
    }
  rescue
    dp("Client settings are corrupted and will be deleted. Save files will not be affected.")
    File.delete(RTP.getSaveFileName("Settings.dat")) if File.exist?(RTP.getSaveFileName("Settings.dat"))
    buildClientData
  end
end

def startup
  # convertSaveFolder
  System.set_window_title(GAME_TITLE)
  buildClientData unless File.exist?(RTP.getSaveFileName("Game.dat"))
  saveSettings(PokemonOptions.new) unless File.exist?(RTP.getSaveFileName("Settings.dat"))
  loadClientData
  loadSettings
  Graphics.frameskip = $Settings.frameskip == 1 unless $joiplay
  pbSetUpSystem
end

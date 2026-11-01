module RTP
  @rtpPaths = nil

  def self.exists?(filename, extensions = [])
    return false if !filename || filename == ""

    eachPathFor(filename) { |path|
      return true if fileExists?(path)

      for ext in extensions
        return true if fileExists?(path + ext)
      end
    }
    return false
  end

  def self.getImagePath(filename)
    return self.getPath(filename, ["", ".png", ".jpg", ".gif", ".bmp", ".jpeg"])
  end

  def self.getAudioPath(filename)
    return self.getPath(filename, ["", ".mp3", ".wav", ".wma", ".mid", ".ogg", ".midi"])
  end

  def self.getPath(filename, extensions = [])
    return filename if !filename || filename == ""

    eachPathFor(filename) { |path|
      return path if fileExists?(path)

      for ext in extensions
        file = path + ext
        return file if fileExists?(file)
      end
    }
    return filename
  end

  # Gets the absolute RGSS paths for the given file name
  def self.eachPathFor(filename)
    return if !filename

    if filename[/^[A-Za-z]\:[\/\\]/] || filename[/^[\/\\]/]
      # filename is already absolute
      yield filename
    else
      # relative path
      RTP.eachPath { |path|
        if path == "./"
          yield filename
        else
          yield path + filename
        end
      }
    end
  end

  # Gets all RGSS search paths
  def self.eachPath
    # XXX: Use "." instead of Dir.pwd because of problems retrieving files if
    # the current directory contains an accent mark
    yield ".".gsub(/[\/\\]/, "/").gsub(/[\/\\]$/, "") + "/"
  end

  private

  def self.isPortable
    return self.isAlwaysPortable || File.exist?("Save Data/.portable")
  end

  def self.isAlwaysPortable
    return true if $joiplay
    # Backwards compatibility for Rejuvenation 14.0 where Kirin and Empo are always in Portable mode.
    if Rejuv && GAME_VERSION != "dev"
      require 'rubygems'
      if Gem::Version.new(GAME_VERSION) < Gem::Version.new("14.1.0-alpha.0")
        return mobile?
      end
    end
    return false
  end

  def self.makePortable
    Dir.mkdir("Save Data") unless File.exist?("Save Data")
    File.open("Save Data/.portable", "w").close unless File.exist?("Save Data/.portable")
  end

  def self.makeNonPortable
    File.delete("Save Data/.portable") if File.exist?("Save Data/.portable")
  end

  def self.getSaveFileName(filename)
    return getSaveFolder().gsub(/[\/\\]$/, "") + "/" + filename
  end

  def self.getSaveSlotPath(slot = 1)
    number = (slot == 1 ? "" : "_" + slot.to_s)
    filename = "Game" + number + ".rxdata"
    return self.getSaveFileName(filename)
  end

  def self.getSaveFolder
    if self.isPortable
      savefolder = "Save Data/"
      Dir.mkdir(savefolder) unless File.exist?(savefolder)
      return File.expand_path('.') + "/" + savefolder
    elsif System.platform[/Windows/]
      # On Windows, we want to use %USERPROFILE%/Saved Games instead of %APPDATA%.
      savefolder = System.data_directory.gsub(ENV['APPDATA']) { ENV['USERPROFILE'] + "/Saved Games" }.gsub("\\") { "/" }
      # Rejuvenation is historically using incorrect directory on Windows.
      savefolder.gsub!("/Pokemon Rejuvenation") { "/Rejuv" } if Rejuv
      require 'fileutils'
      FileUtils.mkdir_p(savefolder)
      return savefolder
    else
      # MKXP makes sure that this folder has been created
      # once it starts. The location differs depending on
      # the operating system:
      # Windows: %APPDATA%/<dataPathApp>
      # Linux: $HOME/.local/share/<dataPathApp>
      # macOS (unsandboxed): $HOME/Library/Application Support/<dataPathApp>
      return System.data_directory + "/"
    end
  end
end

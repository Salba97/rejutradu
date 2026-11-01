module PBDebug
  def PBDebug.logonerr
    begin
      yield
    rescue
      PBDebug.close(false) # close log file before crashing (also transfers any leftover logs from buffer to file)
      logError($!, display: true)
    end
  end

  @@foldername = RTP.getSaveFolder + "Battle Debug Logs/" # debug logs
  @@foldername2 = RTP.getSaveFolder + "Battle Logs/" # non-debug logs
  @@logfile = nil # debug logs
  @@logfile2 = nil # non-debug logs
  @@filename = ""
  @@logstring = "" # stores text for non-debug log till it's written in the file, unless the option is set to 'All' (in that case text is written immediately without any storage, same as debug log)

  @@maxlogs = 5 # for debug logs only

  def PBDebug.foldername
    return @@foldername
  end

  def PBDebug.filename
    return @@filename
  end

  def PBDebug.setup(filename, battleseed)
    PBDebug.reset
    return if !$INTERNAL || filename.nil? # Wild battles pass filename as nil

    PBDebug.open(filename) # opens log file, which is left open till end of battle (this is to avoid inefficiency with opening and closing the file again and again)

    PBDebug.log("#{GAME_TITLE} #{GAME_VERSION} #{platform} - #{filename}")
    PBDebug.log(_INTL("Battle seed: {1}", battleseed) + "\n")
  end

  def PBDebug.open(filename)
    @@filename = "#{filename}.txt"

    Dir.mkdir(@@foldername) unless File.exist?(@@foldername)
    i = 1
    Dir.glob("#{@@foldername.gsub('\\', '/')}*.txt").grep(/\/\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2} - /).sort { |a, b|
      File.mtime(b) <=> File.mtime(a)
    }.each do |file|
      i += 1
      next unless i > @@maxlogs
      # The file may still be opened by another instance of the game.
      begin
        File.delete(file)
      rescue Errno::EACCES => e
        puts "Permission denied: #{e.message}"
      end
    end
    @@logfile = File.open(@@foldername + @@filename, "a+b")

    # Open file for non-debug log to constantly write text to, when the option is set to 'All'
    if $Settings.exportBattleLogs == 2
      Dir.mkdir(@@foldername2) unless File.exist?(@@foldername2)
      @@logfile2 = File.open(@@foldername2 + @@filename, "a+b")
    end
  end

  def PBDebug.log(msg, debugonly: false)
    return unless @@logfile

    msg += "\n"
    @@logfile.write(msg)
    unless debugonly
      @@logfile2 ? @@logfile2.write(msg) : @@logstring += msg
    end
  end

  def PBDebug.dblog(msg)
    PBDebug.log(msg, debugonly: true)
  end

  def PBDebug.flush
    return unless @@logfile

    @@logfile.flush
    @@logfile2.flush if @@logfile2
  end

  # Note: Not called on game exit and F12
  def PBDebug.close(endofbattle)
    return unless @@logfile

    PBDebug.flush

    # Write non-debug logs only at battle end, when the option is set to 'Finished'
    # Also write them if an error occurs while the option is not set to 'All'
    if (endofbattle && $Settings.exportBattleLogs == 1) ||
       (!endofbattle && $Settings.exportBattleLogs != 2)
      Dir.mkdir(@@foldername2) unless File.exist?(@@foldername2)
      File.open(@@foldername2 + @@filename, "w") { |f| f.write(@@logstring) }
    end

    PBDebug.reset
  end

  def PBDebug.reset
    @@logfile.close if @@logfile
    @@logfile2.close if @@logfile2
    @@logfile = nil
    @@logfile2 = nil
    @@filename = ""
    @@logstring = ""
  end
end

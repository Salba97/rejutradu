# The INIT and SCRIPTS constants are initialized in game's respective Bootstrap.rb file which is loaded before this one.
# Note that ScriptLoader needs to be loaded using Scripts.rxdata. Loading it using preloadScript in mkxp.json breaks F12 reset.

# macOS version of mkxp-z has the standard libraries located elsewhere but they're in load path by default.
$:.push('stdlib') if !System.platform[/macOS/] && !$kirin
# Fix loading of rbconfig gem.
$:.push('stdlib/x64-mingw32') if System.platform[/Windows/]
$:.push('stdlib/x86_64-linux') if System.platform[/Linux/] && !$kirin
$:.push('../Resources/Ruby/3.1.0/x86_64-darwin') if System.platform[/macOS/]
# Add external gems to load path.
$:.push('gems')

# Let Net::HTTP know where to look for cacert file
ENV['SSL_CERT_FILE'] = 'cacert.pem'

def mobile?
  return $joiplay || $kirin || $empo || $rpgplayer
end

if $joiplay
  # JoiPlay RPG Maker Plugin 1.20.51 completely broke require. Fortunately gfy came up with this override that fixes it.
  module Kernel
    def require(f)
      path = $:.lazy.flat_map { (x = File.expand_path(f, _1); [x, "#{x}.rb"]) }.find { File.file?(_1) }
      return false unless path && !$LOADED_FEATURES.any? { File.expand_path(_1) == path }
      # TOPLEVEL_BINDING.eval(MKXP.apply_overrides(File.read(path)), path)
      TOPLEVEL_BINDING.eval(File.read(path), path)
      $LOADED_FEATURES << path
      true
    end
  end
end

# https://joiplay.net/forum/d/25-printp-act-as-msgbox-in-vx-ace-games/2
def dp(message)
  msgbox(message) if $joiplay
  print(message) if !$joiplay
end

def fileExists?(file)
  # System.file_exist? respects paths defined in "patches" directive in mkxp.json, unlike File.exist?.
  return System.file_exist?(file) if defined?(System.file_exist?)

  # JoiPlay however doesn't use mkxp.json, nor does it have a System.file_exist? so we need to use ugly workaround.
  return File.exist?(file) || File.exist?("patch/" + file)
end

def platform
  return "Empo" if $empo
  return "Kirin" if $kirin
  return "RPGPlayer" if $rpgplayer
  return "JoiPlay" if $joiplay
  return "Windows" if System.platform[/Windows/]
  return "macOS" if System.platform[/macOS/]
  return "Linux" if System.platform[/Linux/]
  return System.platform
end

def logError(e, display: false, extramessage: nil)
  emessage = pbGetExceptionMessage(e)
  btrace = ""
  if e.backtrace
    maxlength = true ? 25 : 10
    e.backtrace[0, maxlength].each { |i| btrace += "#{i}\n" }
  end
  message = "[#{GAME_TITLE} #{GAME_VERSION} #{platform} #{Time.now}]"
  message += "\n" + extramessage if extramessage
  message += "\nException: #{e.class}\nMessage: #{emessage}\n#{btrace}\n"

  errorlog = (RTP.getSaveFileName("errorlog.txt") rescue "errorlog.txt")

  File.open(errorlog, "ab") { |f| f.write(message) }

  if display
    message += errorlog == "errorlog.txt" ?
      _INTL("This exception was logged in 'errorlog.txt' in your Game Directory.") :
      _INTL("This exception was logged in 'errorlog.txt' in your Save Directory.")
    message += "\n" + _INTL("Press Ctrl+C to copy this message to the clipboard.")
    dp(message)
  end
end

class Hangup < Exception; end

def pbGetExceptionMessage(e)
  emessage = e.message
  if e.is_a?(Hangup)
    emessage = "The script is taking too long. The game will restart."
  elsif e.is_a?(Errno::ENOENT)
    filename = emessage.sub("No such file or directory - ", "")
    emessage = "File #{filename} not found."
  end
  emessage = emessage[0, 500] if emessage.length > 500
  return emessage
end

# To be modified per game
def cleanUpRuntimeData
end

if $joiplay
  if !File.exist?("Game.exe") || File.size("Game.exe") > 0
    print "Please download the JoiPlay version of the game instead of the Windows version."
    exit
  end

  plugin = MKXP.plugin_version.to_i rescue 0
  if GAME_PATCH_USER != '' && plugin < 12100
    print "Upgrade JoiPlay RPG Maker Plugin to version 1.21.00 or newer."
    exit
  elsif plugin < 12053
    print "Upgrade JoiPlay RPG Maker Plugin to version 1.20.53 or newer."
    exit
  end
end

if $kirin || $empo
  if File.exist?("manifest.json")
    print "Please download the Kirin/Empo version of the game instead of the JoiPlay version."
    exit
  end
  if File.exist?("zlib1.dll")
    print "Please download the Kirin/Empo version of the game instead of the Windows version."
    exit
  end
end

if Dir.pwd.downcase.include?("/temp/")
  print "Please extract the game before playing it.\n- RebornVerse Team"
  exit
end

def loadScript(file)
  begin
    code = File.open(file, 'r') { |f| f.read }
    # We don't want these JoiPlay hacks anymore.
    # MKXP.run_postload(code)
    # code = MKXP.apply_overrides(code)
    eval(code, nil, file)
  rescue
    logError($!, display: true)
  end
end

module ThreadLoader
  # Thread.join doesn't seem to work well on Kirin (0.1.6-alpha) so we need to avoid threads.
  # Rejuvenation: Threads don't work nicely here at all so we will bypass it for now.
  ENABLE_THREADS = !$kirin && !Rejuv

  @@scriptLoadThread = nil
  @@mainMenuDataThread = nil
  @@runtimeDataThread = nil

  def self.startLoadingScripts
    unless ENABLE_THREADS
      self.loadInitScripts
      return
    end
    @@scriptLoadThread = Thread.new{
      self.loadInitScripts
    }
  end

  def self.loadInitScripts
    if $DEBUG
      begin
        require 'pp'
      rescue LoadError
      end
    end

    SCRIPTS.each do |path|
      next if path.nil?
      loadScript('Scripts/' + path + '.rb')
    end

    # Load script mods
    Dir["./patch/Mods/*.rb"].each do |file|
      loadScript(file)
    end

    loadScript('Scripts/Validator.rb') if GAME_VERSION == 'dev'
    loadScript('Scripts/UpdateMovesets.rb') if GAME_VERSION == 'dev'

    loadScript('Scripts/DiscordRichPresence.rb') if !Desolation && !mobile? && File.exist?("gems/discord.so")
  end

  def self.startLoadingMainMenuData
    unless ENABLE_THREADS
      $cache.loadMainMenuData
      $cache.loadRuntimeData
      return
    end
    @@mainMenuDataThread = Thread.new {
      $cache.loadMainMenuData
      @@scriptLoadThread&.join
      self.startLoadingRuntimeData
    }
  end

  def self.startLoadingRuntimeData
    @@runtimeDataThread = Thread.new {
      $cache.loadRuntimeData
    }
  end

  def self.awaitScripts
    @@scriptLoadThread&.join
    @@scriptLoadThread = nil
    puts (Time.now - $boottime)
  end

  def self.awaitMainMenuData
    @@mainMenuDataThread&.join
    @@mainMenuDataThread = nil
  end

  def self.awaitRuntimeData
    @@runtimeDataThread&.join
    @@runtimeDataThread = nil
  end
end

# Load base game scripts
INIT.each do |path|
  next if path.nil?
  loadScript('Scripts/' + path + '.rb')
end

# Load priority mods
Dir["./patch/Init/*.rb"].each do |file|
  loadScript(file)
end

ThreadLoader.startLoadingScripts
unless $cache
  $cache = Cache_Game.new
  ThreadLoader.startLoadingMainMenuData
end

cleanUpRuntimeData

$softReset = false
begin
  # Main game loop
  loop do
    retval = mainFunction
    if retval == 0 # failed
      loop do
        Graphics.update
      end
    elsif retval == 1 # ended successfully
      break
    end
  end

  # Prevents game from forcibly closing after an error so you can restart using F12.
  loop do
    Graphics.update
    Input.update
  end
rescue Reset => e
  $softReset = true
  raise e
ensure
  # This code runs when the main loop is done, for instance when you try to close the game.
  # $softReset is used to detect whether this is F12 or not.
  if $updaterThread&.alive?
    # Updater thread is known to potentially hang the game if the server is slow.
    $updaterThread.kill
    $updaterThread.join(0.01)
    # Simply killing it doesn't help either because it still isn't killed immediately if it's waiting for network.
    # If the thread is still alive and we're not soft-resetting, force an os-level exit.
    exit! if !$softReset && $updaterThread.alive?
  end
end

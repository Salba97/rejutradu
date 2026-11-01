# Note: The libraries I'm using here aren't available in the dev version but are included in the release version.
# However it's not recommended to use these libraries for other purposes because JoiPlay doesn't fully support them.
# The libraries had to be tweaked to have the basic use cases work. See enumag/joiplay-assets repository for details.

class Updater
  @@available_version = nil
  @@available_latest = nil
  @@available_engine_version = nil
  @@engine_up_to_date = nil
  @@message_window = nil
  @@progress = nil
  @@error = nil
  @@log = ""
  @@server = UPDATER_SERVERS.reject { |_, v| v == "" }.keys.sample

  def self.shouldUseBuiltInUpdater?
    return GAME_VERSION != 'dev' && @@server
  end

  def self.shouldInstallOptimizedTilesets?
    return $joiplay
  end

  def self.error
    return @@error
  end

  def self.log(message)
    @@log += message + "\n"
  end

  def self.logError(error)
    self.log error.full_message unless error.nil?
    puts @@log
    File.open(self.logFile, "wb") do |f|
      f.write(@@log)
      f.flush
      begin
        f.fsync # Forces writing to disk
      rescue NotImplementedError
      end
    end
  end

  def self.logFile
    return RTP.getSaveFolder + "/updater.log"
  end

  def self.url(path)
    url = UPDATER_SERVERS[@@server] + '/' + UPDATER_PATHS[path]
    # Kirin doesn't have openssl available.
    url = url.sub(/^https:\/\//, 'http://') if $kirin
    return url
  end

  def self.initializeAvailableVersion(timeout: true)
    self.log 'GAME_TITLE = ' + GAME_TITLE.inspect
    self.log 'GAME_VERSION = ' + GAME_VERSION.inspect
    self.log 'MKXP_Z_VERSION = ' + MKXP_Z_VERSION.inspect
    self.log 'JOIPLAY_ASSETS_VERSION = ' + JOIPLAY_ASSETS_VERSION.inspect
    self.log 'KIRIN_ASSETS_VERSION = ' + KIRIN_ASSETS_VERSION.inspect
    self.log 'GAME_PATCH_USER = ' + GAME_PATCH_USER.inspect
    self.log 'UPDATER_SERVERS = {'
    UPDATER_SERVERS.each do |key, value|
      self.log "  #{key}: #{value.inspect},"
    end
    self.log '}'
    self.log 'UPDATER_PATHS = {'
    UPDATER_PATHS.each do |key, value|
      next if value == ""
      self.log "  #{key}: #{value.inspect},"
    end
    self.log '}'

    self.log 'Server: ' + @@server.inspect
    self.log 'Platform: ' + System.platform
    self.log 'Joiplay: ' + ($joiplay ? 'yes' : 'no')
    self.log 'Kirin: ' + ($kirin ? 'yes' : 'no')
    self.log 'Empo: ' + ($empo ? 'yes' : 'no')

    return unless self.shouldUseBuiltInUpdater?

    self.log 'Initializing available version'
    self.getRemoteVersions(self.url(:game_versions), timeout: timeout)

    self.log 'Available game version: ' + @@available_version.inspect
    self.log 'Available game latest: ' + @@available_latest.inspect
    self.log 'Available engine version: ' + @@available_engine_version.inspect
    self.log 'Engine up to date: ' + @@engine_up_to_date.inspect
  end

  # pp Updater.getRemoteVersions(Updater.url(:game_versions))
  def self.getRemoteVersions(url, timeout: true)
    begin
      if $joiplay
        # On JoiPlay we don't have net/http available so we have to use HTTPLite.
        response = HTTPLite.get(url)
        if response[:status] == 200
          return self.parseVersions(response[:body])
        else
          raise 'Unable to get latest game version (http code ' + response[:status].to_s + ')'
        end
      end

      require 'net/http'
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        if timeout
          http.open_timeout = 5
          http.read_timeout = 5
        end
        http.request(Net::HTTP::Get.new(uri)) do |response|
          if response.code == '200'
            return self.parseVersions(response.body)
          else
            raise 'Unable to get latest game version (http code ' + response.code + ')'
          end
          # Can't get latest version.
          return nil
        end
      end
    rescue Exception => error
      self.log 'Error when getting latest version'
      self.logError error
      @@error = error
    end

    return nil
  end

  def self.parseVersions(body)
    require 'rubygems'

    # Regex Breakdown:
    # ([^#:\s]+) - yaml key
    # \s*:\s*    - colon
    # (["']?)    - optional starting quote
    # (.*?)      - yaml value
    # \2         - optional ending quote
    regex = /^([^#:\s]+)\s*:\s*(["']?)(.*?)\2$/

    versions = {}
    body.scan(regex) do |key, quote, value|
      versions[key] = value
    end

    keys = ["version", "latest", "mkxp-z", "joiplay-assets", "kirin-assets"]
    keys.each do |key|
      if versions[key].nil?
        self.log 'Missing version key: ' + key
        return
      end
      unless Gem::Version.correct?(versions[key])
        self.log 'Invalid remote version string for ' + key + ': ' + versions[key]
        return
      end
    end

    @@available_version = versions["version"]
    @@available_latest = versions["latest"]
    engine_key = "mkxp-z"
    engine_key = "joiplay-assets" if $joiplay
    engine_key = "kirin-assets" if $kirin || $empo
    @@available_engine_version = versions[engine_key]
    @@engine_up_to_date = self.fileContains("mkxp.json", "fontHeightReporting") if !$joiplay
    @@engine_up_to_date = self.fileContains("configuration.json", '"fontScale": "1.0"') if $joiplay
  end

  def self.getAvailableVersion
    return @@available_version
  end

  def self.getAvailableLatest
    return @@available_latest
  end

  def self.getAvailableEngineVersion
    return @@available_engine_version
  end

  # Returns a number indicating the status of the current version vs the remote version
  # :InvalidVersion - One of the versions is invalid so we can't compare them
  # :UnreleasedVersion - Local version is somehow newer than remote version, normally this should not happen
  # :UpdaterError - Checking for updates failed
  # :CheckingForUpdates - Checking for updates
  # :UpToDate - Local version is up to date
  # :PatchUpdate - New patch update is available
  # :MajorUpdate - New major update is available
  # :EngineUpdate - New engine update is available
  def self.getVersionStatus
    status = self.getVersionStatusInternal
    self.log 'Detected version status ' + status.inspect
    self.log 'One of the versions is invalid so we can\'t compare them' if status == 0
    self.log 'Local version is somehow newer than remote version, normally this should not happen' if status == 1
    self.log 'Local version is up to date' if status == :UpToDate
    self.log 'New patch update is available' if status == :PatchUpdate
    self.log 'New major update is available' if status == :MajorUpdate
    self.log 'New engine update is available' if status == :EngineUpdate
    return status
  end

  def self.getVersionStatusInternal
    return :UpdaterError if @@error != nil
    return :CheckingForUpdates if @@available_version.nil? || @@available_latest.nil? || @@available_engine_version.nil? || @@engine_up_to_date.nil?
    return :InvalidVersion unless Gem::Version.correct?(GAME_VERSION) && Gem::Version.correct?(@@available_version)

    version = Gem::Version.new(GAME_VERSION)
    available = Gem::Version.new(@@available_version)

    return :UnreleasedVersion if version > available

    if version == available
      if self.getEngineUrl != nil
        return :EngineUpdate if self.isEngineUpdateAvailable
        return :EngineUpdate if !@@engine_up_to_date
      end

      segments = version.segments
      major = segments[0].to_s + "." + segments[1].to_s
      major += "-" + segments[4].to_s if segments[3] == "pre"

      return :MajorUpdate if @@available_latest != major
      return :UpToDate
    end

    return :PatchUpdate if getBaseVersion(GAME_VERSION) == getBaseVersion(@@available_version)
    return :MajorUpdate
  end

  def self.isEngineUpdateAvailable
    # TODO: delete_prefix can be deleted in 19.6 rc
    engineVersionValue = MKXP_Z_VERSION.delete_prefix("reborn-")
    engineVersionValue = JOIPLAY_ASSETS_VERSION if $joiplay
    engineVersionValue = KIRIN_ASSETS_VERSION if $kirin || $empo
    engineVersion = Gem::Version.new(engineVersionValue)
    engineLatest = Gem::Version.new(@@available_engine_version)
    return !engineVersion.eql?(engineLatest)
  end

  def self.fileContains(filename, string)
    content = ""
    begin
      content = File.read(filename)
    rescue Exception => error
      self.logError error
      return true
    end
    contains = content.include?(string)
    self.log sprintf("%s %s %s", filename, contains ? "contains" : "does not contain", string)
    return contains
  end

  def self.getBaseVersion(version)
    return Gem::Version.new(version.gsub(/([0-9]+)$/, '0'))
  end

  def self.downloadPatch(authorization, url, filename, progressCallback)
    self.log 'Attempting update...'
    begin; File.delete(filename); rescue; end

    msgwindow = Kernel.pbCreateMessageWindow
    @@message_window = msgwindow
    @@progress = 0
    Kernel.pbMessageDisplay(msgwindow, _INTL("Downloading {1}... {2}%\\wtnp[0]", filename, "0"))
    msgwindow.textspeed = -999

    begin
      if $joiplay
        headers = {}
        if authorization != ''
          headers['Authorization'] = 'Basic ' + authorization
          self.log 'authorization = Basic ' + authorization
        end

        self.log 'Patch url ' + url.inspect
        response = HTTPLite.download(url, filename, progressCallback, headers)
        self.log 'Patch http code ' + response[:status].inspect
        if response[:status] == 401
          self.log 'Incorrect password'
          return false
        end
        if response[:status] != 200
          self.log 'Unexpected http code'
          raise 'Unexpected response code ' + response[:status].to_s
        end

        self.log 'Successfully downloaded ' + filename
        return true
      end

      require 'net/http'

      self.log 'Patch url ' + url.inspect
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        if authorization != ''
          request['Authorization'] = 'Basic ' + authorization
          self.log 'authorization = Basic ' + authorization
        end

        http.request(request) do |response|
          self.log 'Patch http code ' + response.code.inspect
          if response.code == '401'
            self.log 'Incorrect password'
            return false
          end
          if response.code != '200'
            self.log 'Unexpected http code'
            raise 'Unexpected response code ' + response.code
          end

          self.log "Downloading #{filename}..."
          total = response['content-length'].to_i
          progress = 0
          File.open(filename, 'wb') do |file|
            response.read_body do |chunk|
              file.write(chunk)
              progress += chunk.length
              downloadProgress(progress, total, filename)
            end
          end
          if progress != total
            self.log 'Downloaded ' + progress + ' but the expected total is ' + total
            raise 'Downloaded ' + progress + ' but the expected total is ' + total
          end
          self.log 'Patch successfully downloaded'
        end
      end
      return true
    rescue Exception => error
      self.log "Download failed #{filename}"
      self.logError error

      Kernel.pbMessageDisplay(msgwindow, _INTL("The download has failed."))
      raise error
    ensure
      Kernel.pbDisposeMessageWindow(msgwindow)
    end
  end

  def self.downloadProgress(progress, total, filename)
    percent = progress * 100 / total
    if @@progress <= percent - 10
      Kernel.pbMessageDisplay(@@message_window, _INTL("\\se[]Downloading {1}... {2}%\\wtnp[0]", filename, percent.to_s), tts: percent == 100)
      @@progress += 10
    end
  end

  def self.applyPatch(patch, directory)
    self.log 'Applying patch ' + patch
    self.log 'Directory ' + directory

    begin
      require 'zip'
      require 'fileutils'

      report = Zip::File.respond_to?(:count_entries)
      if report
        msgwindow = Kernel.pbCreateMessageWindow
        @@message_window = msgwindow
        @@progress = 0
        Kernel.pbMessageDisplay(msgwindow, _INTL("Unpacking {1}... {2}%\\wtnp[0]", patch, "0"))
        msgwindow.textspeed = -999
      else
        Kernel.pbMessage(_INTL("Unpacking {1}...\\wtnp[10]", patch))
      end

      total = report ? Zip::File.count_entries(patch) : 0
      progress = 0
      dir_cache = {}
      Zip::File.open(patch) do |zip_file|
        zip_file.each do |file|
          path = directory + '/' + file.name
          FileUtils.mkdir_p(File.dirname(path))
          File.unlink(path) rescue nil if File.exist?(path) && !self.fileExistsCaseSensitive(path, dir_cache)
          zip_file.extract(file, file.name, destination_directory: directory) { true }
          progress += 1
          unpackProgress(progress, total, patch) if report
        end
      end
      self.deleteLegacyFiles(".deletions.txt")
    rescue Exception => error
      self.log 'Unable to apply patch'
      self.logError error

      Kernel.pbMessage(_INTL("Unable to apply the patch."))
      Kernel.logError(error, display: true)
    ensure
      Kernel.pbDisposeMessageWindow(msgwindow) if report
      begin; File.delete(patch); rescue; end
    end
  end

  def self.unpackProgress(progress, total, filename)
    percent = progress * 100 / total
    if @@progress <= percent - 10
      Kernel.pbMessageDisplay(@@message_window, _INTL("\\se[]Unpacking {1}... {2}%\\wtnp[0]", filename, percent.to_s), tts: percent == 100)
      @@progress += 10
    end
  end

  def self.deleteLegacyFiles(deletions)
    return unless File.exist?(deletions)

    dir_cache = {}
    File.foreach(deletions) do |line|
      path = line.strip
      next if path.empty?
      File.unlink(path) if self.fileExistsCaseSensitive(path, dir_cache)
    end

    File.unlink(deletions)
  end

  def self.fileExistsCaseSensitive(path, dir_cache = {})
    parts = path.split(/[\\\/]/)
    current_dir = Dir.pwd

    parts.each do |part|
      dir_cache[current_dir] = (Dir.entries(current_dir) - [".", ".."]) unless dir_cache[current_dir]
      entries = dir_cache[current_dir]
      return false unless entries.include?(part)
      current_dir = File.join(current_dir, part)
    end

    return true
  end

  def self.handleError
    Kernel.pbMessage(_INTL("An error occurred while checking for updates."))
    choices = {
      ManualPatch: _INTL("Patch manually"),
      ShowError: _INTL("Show error details"),
      Nothing: _INTL("Nothing"),
    }
    choice = Kernel.pbChoice(_INTL("What do you want to do?"), choices, :Nothing)
    return if choice.nil?

    case choice
      when :ManualPatch
        loadSite(self.url(:game_patch))
      when :ShowError
        Kernel.logError(@@error, display: true)
    end
  end

  def self.handleAuthorization
    authorization = ''
    if GAME_PATCH_USER != ''
      self.log 'Asking for password'

      require 'base64'

      password = pbEnterText(_INTL("Password?"), 0, 12)
      authorization = Base64.encode64(GAME_PATCH_USER + ':' + password).strip
      self.log 'Trying to authorize using password ' + password.inspect
    else
      self.log 'No authorization needed'
    end

    return authorization
  end

  def self.handlePatchUpdate(prompt = false)
    Kernel.pbMessage(_INTL("A new patch is available.")) if prompt
    return false unless Kernel.pbConfirmMessage(_INTL("Update to version {1}?", self.getAvailableVersion))

    authorization = self.handleAuthorization
    engineVersion = self.getAvailableEngineVersion
    engineUpdate = self.isEngineUpdateAvailable ? self.getEngineUrl : nil

    # Optimized tilesets are only used on JoiPlay.
    if self.downloadPatch(authorization, self.url(:game_patch), 'patch.zip', 'patchDownloadProgress') &&
       (engineUpdate.nil? || self.downloadPatch('', engineUpdate, 'engine.zip', 'joiplayDownloadProgress')) &&
       (!self.shouldInstallOptimizedTilesets? || self.downloadPatch(authorization, self.url(:game_tilesets), 'tilesets.zip', 'tilesetsDownloadProgress'))
      if self.shouldInstallOptimizedTilesets?
        self.applyPatch('tilesets.zip', '.')
      end

      self.applyPatch('patch.zip', '.')

      self.clearCache
      self.replaceEngineVersion
      self.updateGameEngine(engineUpdate, engineVersion)

      Kernel.pbMessage(_INTL("Your game has been updated!\nExiting to apply the changes."))
      exit!
    else
      Kernel.pbMessage(_INTL("Incorrect password."))
    end
    return true
  end

  def self.handleEngineUpdate(prompt = false)
    Kernel.pbMessage(_INTL("An engine update is available.")) if prompt
    return false unless Kernel.pbConfirmMessage(_INTL("Update game engine?"))

    engineVersion = self.getAvailableEngineVersion
    engineUpdate = self.getEngineUrl

    if self.downloadPatch('', engineUpdate, 'engine.zip', 'joiplayDownloadProgress')
      self.clearCache
      self.replaceEngineVersion
      self.updateGameEngine(engineUpdate, engineVersion)

      Kernel.pbMessage(_INTL("Your game has been updated!\nExiting to apply the changes."))
      exit!
    end
    return true
  end

  def self.handleMajorUpdate
    Kernel.pbMessage(_INTL("You are currently playing on version {1} which is an older version.", GAME_VERSION))
    Kernel.pbMessage(_INTL("New major release {1} is available and needs to be installed manually.", self.getAvailableLatest))
    return false
  end

  def self.getEngineUrl
    return self.url(:joiplay_assets) if $joiplay
    return self.url(:kirin_assets) if $kirin || $empo
    return self.url(:mkxp_z_windows) if System.platform[/Windows/]
    return self.url(:mkxp_z_linux) if System.platform[/Linux/] && RUBY_PLATFORM == "x86_64-linux"
    return self.url(:mkxp_z_macos) if System.platform[/macOS/]
  end

  def self.clearCache
    if $joiplay
      begin; File.delete('.file_list'); rescue; end
      begin; File.delete('.path_cache'); rescue; end
      begin; File.delete('.online_path_cache'); rescue; end
    end
    if $kirin
      Dir.glob("path-cache-*.bin").each do |file|
        begin; File.delete(file); rescue; end
      end
      # Invalidate optimized maps from the previous version.
      System.invalidate_optimized_maps() if System.respond_to?(:invalidate_optimized_maps)
    end
    # Empo only holds path cache in memory and doesn't create a file.
  end

  def self.engineFile
    # Backwards compatibility for Rejuvenation 14.0
    if Rejuv && GAME_VERSION != "dev"
      require 'rubygems'
      if Gem::Version.new(GAME_VERSION) < Gem::Version.new("14.1.0-alpha.0")
        return "Scripts/#{GAMEFOLDER}/Bootstrap.rb"
      end
    end

    return "Scripts/#{GAMEFOLDER}/Engine.rb"
  end

  def self.replaceEngineVersion
    file = self.engineFile

    if $joiplay
      self.changeConstant(file, 'JOIPLAY_ASSETS_VERSION', JOIPLAY_ASSETS_VERSION)
    elsif $kirin || $empo
      self.changeConstant(file, 'KIRIN_ASSETS_VERSION', KIRIN_ASSETS_VERSION)
    else
      self.changeConstant(file, 'MKXP_Z_VERSION', MKXP_Z_VERSION)
    end
  end

  def self.updateGameEngine(engineUpdate, engineVersion)
    return if engineUpdate.nil?

    file = self.engineFile

    if $joiplay
      self.applyPatch('engine.zip', '.')
      self.changeConstant(file, 'JOIPLAY_ASSETS_VERSION', engineVersion)
    elsif $kirin || $empo
      self.applyPatch('engine.zip', '.')
      self.changeConstant(file, 'KIRIN_ASSETS_VERSION', engineVersion)
    elsif System.platform[/Windows/]
      self.applyPatch('engine.zip', '.mkxp-z')
      Kernel.pbMessage(_INTL("Game engine update will be applied!\nExiting to apply the changes."))
      Kernel.pbMessage(_INTL("\\c[1]Please wait a few seconds before starting the game again to let the engine finish updating in the background."))
      self.spawnDetachedScript("./Scripts/Updater/move.bat", "./.mkxp-z", "./", file, 'MKXP_Z_VERSION', engineVersion)
      exit
    elsif System.platform[/Linux/]
      self.applyPatch('engine.zip', '.mkxp-z')
      Kernel.pbMessage(_INTL("Game engine update will be applied!\nExiting to apply the changes."))
      Kernel.pbMessage(_INTL("\\c[1]Please wait a few seconds before starting the game again to let the engine finish updating in the background."))
      FileUtils.chmod("+x", "./Scripts/Updater/move.sh")
      self.spawnDetachedScript("./Scripts/Updater/move.sh", "./.mkxp-z", "./", file, 'MKXP_Z_VERSION', engineVersion)
      exit
    elsif System.platform[/macOS/]
      self.applyPatch('engine.zip', '../..')
      self.changeConstant(file, 'MKXP_Z_VERSION', engineVersion)
    end
  end

  def self.updateDetails
    case self.getVersionStatus
      when :UpdaterError
        self.handleError
      when :PatchUpdate
        self.handlePatchUpdate
      when :MajorUpdate
        self.handleMajorUpdate
      when :EngineUpdate
        self.handleEngineUpdate
      when :UpToDate
        Kernel.pbMessage(_INTL("Your game is up to date."))
      else
        Kernel.pbMessage(_INTL("Checking for updates..."))
    end
  end

  def self.spawnDetachedScript(*params)
    self.log params.inspect
    self.logError nil # always dump the log when spawning a console script
    # Can't update Windows or Linux binaries while the game is running so we need to spawn a detached script instead.
    begin
      pid = spawn(*params, out: [self.logFile, "a"], err: [:child, :out])
    rescue Exception => error
      self.logError error
    end
    Process.detach(pid)
  end

  def self.changeConstant(file, constant, value)
    pattern = /^#{constant} = '.*'$/
    content = File.read(file)
    replaced = content.gsub(pattern, "#{constant} = '#{value}'")
    unless replaced.include?("#{constant} = '#{value}'")
      raise "Constant #{constant} not found in file #{file}."
    end
    File.write(file, replaced)
  end
end

def patchDownloadProgress(progress, total)
  Updater.downloadProgress(progress, total, "patch.zip")
end

def joiplayDownloadProgress(progress, total)
  Updater.downloadProgress(progress, total, "joiplay.zip")
end

def tilesetsDownloadProgress(progress, total)
  Updater.downloadProgress(progress, total, "tilesets.zip")
end

if Dir.exist?(".mkxp-z")
  dp "An unexpected error happened during the last update.\n" +
     "Please report a bug and attach \"updater.log\" from your save directory.\n"
  require 'fileutils'
  FileUtils.rm_rf(".mkxp-z")
end

# Check updater in separate thread so that website issues don't delay game start.
$updaterStart = Time.now
if $joiplay || $kirin
  # Calling HTTPLite.get in a thread while not connected to internet causes an unrecoverable JoiPlay crash.
  # Kirin also has some issue with threads, it seems .join doesn't work correctly.
  Updater.initializeAvailableVersion
else
  $updaterThread = Thread.new do
    Updater.initializeAvailableVersion(timeout: false)
  end
end

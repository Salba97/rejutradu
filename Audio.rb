def beginDynamicMusic(name)
  $game_system.playing_bgm.name = name + ".ogg"
  $game_system.playing_bgm.volume = $Settings.volume
  $game_system.playing_bgm.pitch = 100
  $game_system.bgm_play_internal($game_system.playing_bgm, Audio.bgm_pos)
  $PokemonGlobal.nextBattleBGM = $game_system.playing_bgm
end

def finishDynamicMusic(name)
  $game_system.playing_bgm.name = name + ".ogg"
  $game_system.playing_bgm.volume = $Settings.volume
  $game_system.playing_bgm.pitch = 100
  $game_system.bgm_play_internal($game_system.playing_bgm, $position)
end

class Thread
  def Thread.exclusive
    _old = Thread.critical
    begin
      Thread.critical = true
      return yield
    ensure
      Thread.critical = _old
    end
  end
end

#####################################
# Needed because RGSS doesn't call at_exit procs on exit
# Exit is not called when game is reset (using F12)
$AtExitProcs = [] if !$AtExitProcs

def exit(code = 0)
  for p in $AtExitProcs
    p.call
  end
  raise SystemExit.new(code)
end

def at_exit(&block)
  $AtExitProcs.push(Proc.new(&block))
end

#####################################
# Works around a problem with FileTest.exist
# if directory contains accent marks
def safeExists?(f)
  ret = false
  File.open(f, "rb") { ret = true } rescue nil
  return ret
end

def Audio_bgm_playing?
  AudioState.channel != nil
end

def Audio_bgm_name
  AudioState.name
end

def Audio_bgm_pitch
  AudioState.pitch
end

def Audio_bgm_play(name, volume, pitch, position = 0)
  volume = 0 if !getPlayMusic()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    if AudioState.meActive?
      AudioState.setWaitingBGM(filename, volume, pitch, position)
      return
    end
    AudioState::AudioContextPlay.call(AudioState.context, filename, volume, pitch, position, 1)
    AudioState.name = filename
    AudioState.volume = volume
    AudioState.pitch = pitch
  rescue Hangup
  rescue
    dp($!.message + "\n" + $!.backtrace)
  end
end

def Audio_me_play(name, volume, pitch, position = 0)
  volume = 0 if !getPlayMusic()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    if AudioState.bgmActive?
      bgmPosition = Kernel.Audio_bgm_get_position
      AudioState.setWaitingBGM(
        AudioState.name,
        AudioState.volume,
        AudioState.pitch,
        bgmPosition
      )
      AudioState::AudioContextStop.call(AudioState.context)
    end
    AudioState::AudioContextPlay.call(AudioState.meContext, filename, volume, pitch, position, 0)
  rescue
    dp($!.message + "\n" + $!.backtrace)
  end
end

def Audio_me_fade(ms)
  AudioState::AudioContextFadeOut.call(AudioState.meContext, ms)
end

def Audio_me_stop()
  AudioState::AudioContextStop.call(AudioState.meContext)
end

def Audio_bgm_stop()
  begin
    AudioState::AudioContextStop.call(AudioState.context)
    AudioState.waitingBGM = nil
    AudioState.name = ""
  rescue
    dp($!.message + "\n" + $!.backtrace)
  end
end

def Audio_bgm_get_position
  return AudioState::AudioContextGetPosition.call(AudioState.context)
end

def Audio_bgm_fade(ms)
  AudioState::AudioContextFadeOut.call(AudioState.context, ms.to_i)
end

def Audio_bgm_fadein(ms)
  AudioState::AudioContextFadeIn.call(AudioState.context, ms.to_i)
end

def Audio_bgm_get_volume
  return 0 if !AudioState.bgmActive?

  return AudioState.volume
end

def Audio_bgm_set_volume(volume)
  return if !AudioState.bgmActive?

  AudioState.volume = volume * 1.0
  AudioState::AudioContextSetVolume.call(AudioState.context, volume.to_i)
end

def Audio_bgs_play(name, volume, pitch, position = 0)
  volume = 0 if !getPlaySound()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    AudioState::AudioContextPlay.call(AudioState.bgsContext, filename, volume, pitch, position, 0)
  rescue
    dp($!.message + "\n" + $!.backtrace)
  end
end

def Audio_bgs_fade(ms)
  AudioState::AudioContextFadeOut.call(AudioState.bgsContext, ms)
end

def Audio_bgs_stop()
  AudioState::AudioContextStop.call(AudioState.bgsContext)
end

def Audio_se_play(name, volume, pitch, position = 0)
  volume = 0 if !getPlaySound()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    AudioState::AudioContextSEPlay.call(AudioState.seContext, filename, volume, pitch, position)
  rescue
    dp($!.message + "\n" + $!.backtrace)
  end
end

def Audio_se_stop()
  AudioState::AudioContextStop.call(AudioState.seContext)
end

def pbStringToAudioFile(str)
  if str[/^(.*)\:\s*(\d+)\s*\:\s*(\d+)\s*$/]
    file = $1
    volume = $2.to_i
    pitch = $3.to_i
    return RPG::AudioFile.new(file, volume, pitch)
  elsif str[/^(.*)\:\s*(\d+)\s*$/]
    file = $1
    volume = $2.to_i
    return RPG::AudioFile.new(file, volume, 100)
  else
    return RPG::AudioFile.new(str, 100, 100)
  end
end

def pbDataToAudioFile(data)
  return pbStringToAudioFile(data) if data.is_a?(String)

  name = data[:name]
  volume = data[:volume] || 100
  pitch = data[:pitch] || 100
  return RPG::AudioFile.new(name, volume, pitch)
end

# Converts an object to an audio file.
# str -- Either a string showing the filename or an RPG::AudioFile object.
# Possible formats for _str_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbResolveAudioFile(str, volume = nil, pitch = nil)
  if str.is_a?(String)
    str = pbStringToAudioFile(str)
    str.volume = 100
    str.pitch = 100
  end
  str.volume = volume if volume
  str.pitch = pitch if pitch
  return str
end

# Plays a BGM file.
# param -- Either a string showing the filename
# (relative to Audio/BGM/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
# position -- Position in seconds of where to start playing the file
# fadeIn -- Whether or not the music should fade in when given a `position`.
def pbBGMPlay(param, volume = nil, pitch = nil, reset_volume: false, position: 0, fadeIn: true)
  return if !param

  if !reset_volume && $Settings.volume
    if volume && $Settings.volume
      volume *= ($Settings.volume / 100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $Settings.volume
      volume = param.volume * ($Settings.volume / 100.00)
    elsif !volume && $Settings.volume
      volume = $Settings.volume
    elsif !reset_volume
      volume = 100
    end
  end
  param = pbResolveAudioFile(param.clone, volume, pitch)
  if param.name && param.name != ""
    unspoilerTrack(param.name) if Rejuv
    if $game_system && $game_system.respond_to?("bgm_play")
      $game_system.bgm_play(param, position, fadeIn)
      return
    end
    Audio.bgm_play(canonicalize("Audio/BGM/" + param.name), param.volume, param.pitch, position, fadeIn)
  end
end

# Plays an ME file.
# param -- Either a string showing the filename
# (relative to Audio/ME/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbMEPlay(param, volume = nil, pitch = nil)
  return if !param

  if $Settings.volume
    if volume && $Settings.volume
      volume *= ($Settings.volume / 100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $Settings.volume
      volume = param.volume * ($Settings.volume / 100.00)
    elsif !volume && $Settings.volume
      volume = $Settings.volume
    end
  else
    volume = 100
  end
  param = pbResolveAudioFile(param.clone, volume, pitch)
  if param.name && param.name != ""
    if $game_system && $game_system.respond_to?("me_play")
      $game_system.me_play(param)
      return
    end
    Audio.me_play(canonicalize("Audio/ME/" + param.name), param.volume, param.pitch)
  end
end

# Plays a BGS file.
# param -- Either a string showing the filename
# (relative to Audio/BGS/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGSPlay(param, volume = nil, pitch = nil)
  return if !param

  if $Settings.bgsvolume
    if volume && $Settings.bgsvolume
      volume *= ($Settings.bgsvolume / 100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $Settings.bgsvolume
      volume = param.volume * ($Settings.bgsvolume / 100.00)
    elsif !volume && $Settings.bgsvolume
      volume = $Settings.bgsvolume
    end
  else
    volume = 100
  end
  param = pbResolveAudioFile(param.clone, volume, pitch)
  if param.name && param.name != ""
    if $game_system && $game_system.respond_to?("bgs_play")
      $game_system.bgs_play(param)
      return
    end
    Audio.bgs_play(canonicalize("Audio/BGS/" + param.name), param.volume, param.pitch)
  end
end

# Plays an SE file.
# param -- Either a string showing the filename
# (relative to Audio/SE/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
# x, y, z -- Change the position of the sound. THIS ONLY WORKS ON MONO SOUNDS!
# Use x: -1 for full left or x: 1 for full right.
def pbSEPlay(param, volume = nil, pitch = nil, x: 0, y: 0, z: 0)
  return if !param

  if $Settings.sevolume
    if volume && $Settings.sevolume
      volume *= ($Settings.sevolume / 100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $Settings.sevolume
      volume = param.volume * ($Settings.sevolume / 100.00)
    elsif !volume && $Settings.sevolume
      volume = $Settings.sevolume
    end
  else
    volume = 100
  end
  param = pbResolveAudioFile(param.clone, volume, pitch)
  if param.name && param.name != ""
    if $game_system && $game_system.respond_to?("se_play")
      $game_system.se_play(param, x: x, y: y, z: z)
      return
    end
    internal_se_play(canonicalize("Audio/SE/" + param.name), param.volume, param.pitch, x, y, z)
  end
end

def pbAccessibilitySEPlay(param, volume = nil, pitch = nil, x: 0, y: 0, z: 0)
  return if !param

  if $Settings.accessibilityVolume
    if volume && $Settings.accessibilityVolume
      volume *= ($Settings.accessibilityVolume / 100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $Settings.accessibilityVolume
      volume = param.volume * ($Settings.accessibilityVolume / 100.00)
    elsif !volume && $Settings.accessibilityVolume
      volume = $Settings.accessibilityVolume
    end
  else
    volume = 100
  end
  param = pbResolveAudioFile(param.clone, volume, pitch)
  if param.name && param.name != ""
    if $game_system && $game_system.respond_to?("se_play")
      $game_system.se_play(param, x: x, y: y, z: z)
      return
    end
    internal_se_play(canonicalize("Audio/SE/" + param.name), param.volume, param.pitch, x, y, z)
  end
end

# Stops SE playback.
def pbSEFade(x = 0.0); pbSEStop(x); end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEFade(x = 0.0); pbMEStop(x); end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMFade(x = 0.0); pbBGMStop(x); end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSFade(x = 0.0); pbBGSStop(x); end

# Stops SE playback.
def pbSEStop(timeInSeconds = 0.0)
  if $game_system
    $game_system.se_stop
  else
    Audio.se_stop
  end
end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEStop(timeInSeconds = 0.0)
  if $game_system && timeInSeconds > 0.0 && $game_system.respond_to?("me_fade")
    $game_system.me_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("me_stop")
    $game_system.me_stop(nil)
    return
  end
  (timeInSeconds > 0.0) ? Audio.me_fade((timeInSeconds * 1000).floor) : Audio.me_stop
end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMStop(timeInSeconds = 0.0)
  if $game_system && timeInSeconds > 0.0 && $game_system.respond_to?("bgm_fade")
    $game_system.bgm_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("bgm_stop")
    $game_system.bgm_stop
    return
  end
  (timeInSeconds > 0.0) ? Audio.bgm_fade((timeInSeconds * 1000).floor) : Audio.bgm_stop
end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSStop(timeInSeconds = 0.0)
  if $game_system && timeInSeconds > 0.0 && $game_system.respond_to?("bgs_fade")
    $game_system.bgs_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("bgs_play")
    $game_system.bgs_play(nil)
    return
  end
  (timeInSeconds > 0.0) ? Audio.bgs_fade((timeInSeconds * 1000).floor) : Audio.bgs_stop
end

# Plays a sound effect that plays when a decision is confirmed or a choice is made.
def pbPlayDecisionSE()
  if $cache.RXsystem.respond_to?("decision_se") && $cache.RXsystem.decision_se && $cache.RXsystem.decision_se.name != ""
    pbSEPlay($cache.RXsystem.decision_se)
  elsif FileTest.audio_exist?("Audio/SE/Choose")
    pbSEPlay("Choose", 80)
  end
end

# Plays a sound effect that plays when the player moves the cursor.
def pbPlayCursorSE()
  if $cache.RXsystem.respond_to?("cursor_se") && $cache.RXsystem.cursor_se && $cache.RXsystem.cursor_se.name != ""
    pbSEPlay($cache.RXsystem.cursor_se)
  elsif FileTest.audio_exist?("Audio/SE/Choose")
    pbSEPlay("Choose", 80)
  end
end

# Plays a sound effect that plays when a choice is canceled.
def pbPlayCancelSE()
  if $cache.RXsystem.respond_to?("cancel_se") && $cache.RXsystem.cancel_se && $cache.RXsystem.cancel_se.name != ""
    pbSEPlay($cache.RXsystem.cancel_se)
  elsif FileTest.audio_exist?("Audio/SE/Choose")
    pbSEPlay("Choose", 80)
  end
end

# Plays a buzzer sound effect.
def pbPlayBuzzerSE()
  if $cache.RXsystem.respond_to?("buzzer_se") && $cache.RXsystem.buzzer_se && $cache.RXsystem.buzzer_se.name != ""
    pbSEPlay($cache.RXsystem.buzzer_se)
  elsif FileTest.audio_exist?("Audio/SE/buzzer")
    pbSEPlay("buzzer", 80)
  end
end

def internal_se_play(name, volume, pitch, x, y, z)
  defined?(Audio.se_play_position) ? Audio.se_play_position(name, volume, pitch, x, y, z) : Audio.se_play(name, volume, pitch)
end

module Audio
  class << self
    alias mkxp_bgm_play bgm_play unless method_defined?(:mkxp_bgm_play)
  end

  @fadeInSupport = true
  if mobile?
    @fadeInSupport = false
  else
    begin
      # Don't pass an empty string here, it causes an unrecoverable error on macOS.
      # Note that passing a space crashes JoiPlay after F12 and loading a save which is why the check is skipped.
      Audio.mkxp_bgm_play(" ", 100, 100, 0, true, 0)
    rescue TypeError
      @fadeInSupport = false
    rescue Errno::ENOENT
      # Missing file - no-op
    end
  end

  def self.bgm_play(filename, volume = 100, pitch = 100, position = 0, fadeIn = true, track = -127)
    begin
      puts "fadeIn nil" if fadeIn.nil?
      # JoiPlay uses its own MKXP and therefore will not accept `fadeIn`.
      if !@fadeInSupport
        mkxp_bgm_play(filename, volume, pitch, position, track)
      else
        mkxp_bgm_play(filename, volume, pitch, position, fadeIn, track)
      end
    rescue Errno::ENOENT
      dp("Could not resolve Audio file #{filename.inspect}.\nPlease report <3")
    end
  end
end

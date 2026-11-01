class WindowsTextToSpeech
  def encode(message)
    # The utf-16le encoding is what NVDA expects.
    return message.encode("utf-16le")
  end
end

class TolkTextToSpeech < WindowsTextToSpeech
  def self.isSupported?
    return false unless System.platform[/Windows/]
    return false unless File.exist?('libTolk.dll')
    # Windows Speech API needs to be enabled explicitly. Uncomment this line to do so.
    # Win32API.new('libTolk.dll', 'Tolk_TrySAPI', 'b', 'v').call(true)
    Win32API.new('libTolk.dll', 'Tolk_Load', '', 'v').call()
    return Win32API.new('libTolk.dll', 'Tolk_HasSpeech', '', 'b').call()
  end

  def initialize
    @speak = Win32API.new('libTolk.dll', 'Tolk_Speak', ['p', 'b'], 'v')
    @cancel = Win32API.new('libTolk.dll', 'Tolk_Silence', '', 'v')
  end

  def speak(message, interrupt)
    @speak.call(self.encode(message), interrupt)
  end

  def clear
    @cancel.call
  end
end

class NVDATextToSpeech < WindowsTextToSpeech
  def self.isSupported?
    return false unless System.platform[/Windows/]
    return false unless File.exist?('nvdaControllerClient.dll')
    return !Win32API.new('nvdaControllerClient.dll', 'nvdaController_testIfRunning', '', 'b').call()
  end

  def initialize
    @speak = Win32API.new('nvdaControllerClient.dll', 'nvdaController_speakText', 'p', 'v')
    @cancel = Win32API.new('nvdaControllerClient.dll', 'nvdaController_cancelSpeech', '', 'v')
  end

  def speak(message, interrupt)
    @cancel.call if interrupt
    @speak.call(self.encode(message))
  end

  def clear
    @cancel.call
  end
end

class CommandTextToSpeech
  def initialize(command)
    @queue = []
    @command = command
    @process = nil
    @thread = nil
    createThread
  end

  def createThread
    @thread = Thread.new { # TODO: Integrate non-Thread support
      loop do
        if @queue.empty?
          sleep
        else
          message = @queue.shift
          @process = spawn(*@command, message)
          Process.wait(@process)
          @process = nil
        end
      end
    }
  end

  def speak(message, interrupt)
    clear if interrupt
    @queue.push(message)
    self.createThread unless @thread.status
    @thread.run
  end

  def clear
    @queue.clear
    begin
      Process.kill(:INT, @process) unless @process.nil?
    rescue Errno::ESRCH
    end
  end
end

class OrcaTextToSpeech < CommandTextToSpeech
  def self.isSupported?
    return false unless System.platform[/Linux/]
    return false if mobile?
    return false unless system("which spd-say > /dev/null 2>&1")
    # Check if Orca is running
    return system("pgrep --exact orca > /dev/null 2>&1")
  end

  def initialize
    super(["spd-say", "--wait"])
  end
end

class MacOSTextToSpeech < CommandTextToSpeech
  def self.isSupported?
    return false unless System.platform[/macOS/]
    return `defaults read com.apple.Accessibility VoiceOverTouchEnabled`.rstrip == '1'
  end

  def initialize
    super(["say", "--quality", "0"])
  end
end

def createTextToSpeech
  implementations = [
    TolkTextToSpeech,
    NVDATextToSpeech,
    OrcaTextToSpeech,
    MacOSTextToSpeech,
  ]
  for implementation in implementations
    return implementation.new if implementation.isSupported?
  end
  return nil
end

DEV_TTS_TESTING = false # Flip to true to print TTS strings to console (for dev testing purposes)
AUTO_LOWERCASE_TTS = true

def tts(text, interrupt = false, lowercase: nil)
  return if $tts.nil? && !DEV_TTS_TESTING

  if text == ""
    $tts.clear if interrupt && !$tts.nil?
    return
  end

  text = text.to_s if text.instance_of?(Integer)
  unless text.instance_of?(String)
    dp('Incorrect tts call: ' + text.class.to_s)
    return
  end

  text = TextPlaceholders.removeFrom(text)
  lowercase = AUTO_LOWERCASE_TTS if lowercase.nil?
  text = text.downcase if lowercase

  $tts.speak(text, interrupt) unless $tts.nil?
  puts text if DEV_TTS_TESTING
end

if $tts.nil?
  $tts = createTextToSpeech
else
  $tts.clear
end

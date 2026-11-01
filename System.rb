def pbSetUpSystem
  if defined?($game_system)
    offsetX = [0, BORDERWIDTH][mobile? ? 0 : $Settings.border]
    offsetY = [0, BORDERHEIGHT][mobile? ? 0 : $Settings.border]
    setScreenBorderName("border")
    if Graphics.width != DEFAULTSCREENWIDTH || Graphics.height != DEFAULTSCREENHEIGHT || offsetX != $ResizeOffsetX || offsetY != $ResizeOffsetY
      $ResizeOffsetX = offsetX
      $ResizeOffsetY = offsetY
      $game_system = Game_System
      pbSetResizeFactor($Settings.screensize)
    end
    $random_dex = nil
    $random_items = nil
    $random_moveset = nil
    $random_typeChart = nil
    $random_movedata = nil
  else
    $game_system = Game_System
    $ResizeOffsetX = 0
    $ResizeOffsetY = 0
    pbSetResizeFactor($Settings.screensize)
  end
  MessageConfig.pbSetSystemFontName("PokemonEmerald")
  pbLoadLanguage
end

def pbScreenCapture
  capturefile = nil
  5000.times { |i|
    Dir.mkdir(RTP.getSaveFolder + "Screenshots") if !File.exist?(RTP.getSaveFolder + "Screenshots")
    filename = RTP.getSaveFileName(sprintf("Screenshots/capture%03d.png", i))
    if !safeExists?(filename)
      capturefile = filename
      break
    end
  }
  begin
    Graphics.snap_to_bitmap.to_file(capturefile)
    pbSEPlay("expfull") if FileTest.audio_exist?("Audio/SE/expfull")
  rescue
    nil
  end
end

module Input
  # JoiPlay doesn't support symbols so we need to use constants
  KEY_RETURN = $joiplay ? 0x42 : 0x0D
  KEY_ESCAPE = $joiplay ? 0x6f : 0x1B
  KEY_BACKSPACE = $joiplay ? 0x04 : 0x08

  LeftMouseKey  = 1
  RightMouseKey = 2
  F3    = 23
  F4    = 24
  F5    = 25
  PAGEUP = L
  PAGEDOWN = R

  ITEMKEYS      = [Input::F5, Input::F4, Input::F3]
  ITEMKEYSNAMES = [_INTL("F5"), _INTL("F4"), _INTL("F3")]

  # List of current default keybinds
  # Primarily for bookkeeping rather than functional use.
  # DEFAULTKEYBINDS = [
  #   Input::Left  => [:LEFT],
  #   Input::Right => [:RIGHT],
  #   Input::Up    => [:UP],
  #   Input::Down  => [:DOWN],
  #   Input::C     => [:C, :RETURN, :SPACE],
  #   Input::B     => [:X, :ESCAPE, :KP_0],
  #   Input::A     => [:Z],
  #   Input::Z     => [:D],
  #   Input::L     => [:Q, :PAGEUP],
  #   Input::R     => [:W, :PAGEDOWN],
  #   Input::X     => [:A],
  #   Input::Y     => [:S],
  #   Input::D     => [:LSHIFT, :RSHIFT],
  #   Input::E     => [:M, :TAB],
  #   Input::F     => [:F7],
  # ]

  F2 = mobile? ? :F11 : :F2
  # F2 is used by mkxp-z for toggling FPS display by default, but we switched F2 and F11 in our
  # mkxp-z build as we wanted to use F2 for the Controls screen (as F1 is the key for changing
  # controls). However we can't do this for JoiPlay, so F2 can't be freed up, so we just use F11

  class << Input
    alias update_KGC_ScreenCapture update unless method_defined?(:update_KGC_ScreenCapture)
  end

  def self.getstate(button)
    self.pressex?(button)
  end

  # On Mac, basic keyboard shortcuts are typically bound to Command (⌘) instead of Control. Command + C for copy, etc.
  # LGUI is the Left Command key, and RGUI is the Right Command key. On Windows, the Windows key would be the equivalent.
  def self.modifierKeyPressed?
    if System.platform[/macOS/]
      return pressex?(:LGUI) || pressex?(:RGUI)
    end
    return press?(Input::CTRL)
  end

  def self.isComboKeyPressed?
    return self.pressex?(:LGUI) || self.pressex?(:RGUI) || self.pressex?(:LCTRL) || self.pressex?(:RCTRL) || self.pressex?(:LALT) || self.pressex?(:RALT)
  end

  # Shift key is mapped to Input::A on joiplay mkxp, so we use H key instead (key code 72)
  def self.shiftKeyTriggered?
    return self.triggerex?(72) if mobile?
    return (defined?(Input::D) && self.trigger?(Input::D)) || Input::Controller.axes_trigger[1] >= 0.1
  end

  def self.shiftKeyPressed?
    return self.pressex?(72) if mobile?
    return (defined?(Input::D) && self.press?(Input::D)) || Input::Controller.axes_trigger[1] >= 0.1
  end

  def self.triggerexAny?(keys)
    keys.each do |key|
      return true if triggerex?(key)
    end
    return false
  end

  def self.repeatexAny?(keys)
    keys.each do |key|
      return true if repeatex?(key)
    end
    return false
  end

  def self.update
    update_KGC_ScreenCapture

    if triggerex?(:F3)
      pbScreenCapture
    end

    mobile = $joiplay || (($kirin || $empo) && !Input.text_input)

    # JoiPlay doesn't accept literals but only key codes. 84 is the key code for T which I use for turbo on JoiPlay.
    # Alt is force-disabled from triggering turbo if blindstep is active since they use Alt+Tab often and can't unbind it.
    if (!mobile? && !Input.text_input && defined?(Input::E) && trigger?(Input::E) && (!$game_switches || !$game_switches[:Blindstep] || !triggerex?(:LALT))) || (mobile && triggerex?(84))
      Graphics.toggleTurbo
      Graphics.turboIcon
    end

    # JoiPlay doesn't accept literals but only key codes. 77 is the key code for M which I use for mute on JoiPlay.
    if (!mobile? && !Input.text_input && defined?(Input::F) && trigger?(Input::F)) || (mobile && triggerex?(77))
      $game_system.toggle_mute if $game_system
    end

    # Use turbo while Gamepad L2 button is pressed (speed dependent on press intensity)
    pbDynamicTurbo(Input::Controller.axes_trigger[0]) unless mobile?
    # On JoiPlay we map L2 to L key and use that (fixed speed) (76 = key code for L)
    pbDynamicTurbo(Input.pressex?(76) ? 1.0 : 0.0) if mobile

    if $tts
      # Start with the core list that is guaranteed to exist on all platforms
      interrupt_keys = [
        Input::C, Input::B,
        Input::DOWN, Input::UP, Input::LEFT, Input::RIGHT,
        Input::A, Input::X, Input::Y, Input::Z,
        Input::L, Input::R,
        Input::CTRL, Input::ALT,
      ]

      # Add more keys if they're defined.
      interrupt_keys.push Input::D if defined?(Input::D) # Shift
      interrupt_keys.push Input::E if defined?(Input::E) # Tab
      interrupt_keys.push Input::F if defined?(Input::F) # F7

      # Clear TTS if any key is pressed
      if triggerexAny?(interrupt_keys)
        $tts.clear
      end
    end

    if $DEBUG
      if triggerex?(:F10)
        if $profiling
          CP_Profiler.print
          Kernel.pbMessage("Results printed to Profiler.txt.")
          $profiling = false
        else
          Kernel.pbMessage("Begin profiling")
          $profiling = true
          CP_Profiler.begin
        end
      end
      if triggerex?(:F6)
        begin
          Input.text_input = true
          $past_texts = [] if !$past_texts
          code = Kernel.pbMessageFreeText(_INTL("What code would you like to run?"), "", 999, Graphics.width, $past_texts)
          $past_texts.unshift(code) unless code == ""
          $past_texts.uniq!
          eval(code)
          Input.text_input = false
        rescue
          logError($!, display: true)
          Input.text_input = false
        end
      end
    end
  end

  def self.triggerGamepad?(key)
    return false if defined?(self.last_device) && self.last_device == :KBM
    return true if trigger?(key)
    return false
  end
end

module Mouse
  module_function

  # Returns the position of the mouse relative to the game window.
  def getMousePos(catch_anywhere = false)
    return nil unless mobile? || Input.mouse_in_window? || catch_anywhere

    return Input.mouse_x, Input.mouse_y
  end
end

# for a soft-reset, let the speed-up persist
Graphics.frame_rate = 40 * $Settings.turboSpeedMultiplier if $speed_up

def pbDynamicTurbo(value)
  value = 1.0 - value if $speed_up
  Graphics.frame_rate = 40 * (1 + (value * ($Settings.turboSpeedMultiplier - 1)))
end

module Graphics
  @@turboIcon = Sprite.new(nil)
  @@turboIcon.ox = 0
  @@turboIcon.oy = 0
  @@turboIcon.x = 450
  @@turboIcon.y = 320
  @@turboIcon.z = 100001

  if defined?(@@opacity)
    self.autoToggleTurbo(@@overworldTurbo) if $speed_up != @@overworldTurbo
  else
    $speed_up = false
    @@opacity = 0
    @@battleTurbo = false
    @@overworldTurbo = false
  end

  class << self
    alias __turbo_update update unless method_defined?(:__turbo_update)
  end

  def self.toggleTurbo
    # Enabling turbo in battle only affects battles.
    # Disabling turbo in battle or toggling it in overworld affects both.
    if $game_temp&.in_battle
      @@battleTurbo = !@@battleTurbo
      @@overworldTurbo = false if !@@battleTurbo
      self.autoToggleTurbo(@@battleTurbo)
    else
      @@overworldTurbo = !@@overworldTurbo
      @@battleTurbo = @@overworldTurbo
      self.autoToggleTurbo(@@overworldTurbo)
    end
  end

  def self.turboIcon
    icon = $speed_up ? "Graphics/Icons/turbo_on.png" : "Graphics/Icons/turbo_off.png"
    @@turboIcon.bitmap = RPG::Cache.load_bitmap(icon) if fileExists?(icon)
    @@turboIcon.opacity = 255
    @@opacity = 255
    pbSEPlay($speed_up ? "turbo_on" : "turbo_off", 80)
  end

  def self.autoToggleTurbo(turbo)
    if turbo
      Graphics.frame_rate = 40 * $Settings.turboSpeedMultiplier
      $speed_up = true
    else
      Graphics.frame_rate = 40
      $speed_up = false
    end
  end

  def self.update
    adjustment = $speed_up ? 1.0 / $Settings.turboSpeedMultiplier : 1
    adjustment *= 3.5
    @@opacity = [0, @@opacity - adjustment].max
    @@turboIcon.opacity = @@opacity
    __turbo_update
  end

  def self.onStartBattle
    if $speed_up != @@battleTurbo
      Graphics.autoToggleTurbo(@@battleTurbo)
      Graphics.turboIcon
    end
  end

  def self.onEndBattle
    if $speed_up != @@overworldTurbo
      Graphics.autoToggleTurbo(@@overworldTurbo)
      Graphics.turboIcon
    end
  end
end

def pbSetWindowText(string = System.game_title)
  System.set_window_title(string)
end

# I don't think this does anything, but the game doesn't load if I don't add it
# 2025: game loads just fine even if I remove it ~enu
# class ControlConfig
#   attr_reader :controlAction
#   attr_accessor :keyCode
#
#   def initialize(controlAction, defaultKey)
#     @controlAction = controlAction
#     @keyCode = Keys.getKeyCode(defaultKey)
#   end
#
#   def keyName
#     return Keys.getKeyName(@keyCode)
#   end
# end

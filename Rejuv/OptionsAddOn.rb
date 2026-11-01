class PokemonOptions
  attr_accessor :camerastyle
  attr_accessor :cameraAccessibility
  attr_accessor :choiceDelay
  attr_accessor :ignoreMouse
  attr_accessor :alwaysShowOverlay
  attr_accessor :alwaysExtendBlessings

  alias __rejuv_fixValues fixMissingValues unless method_defined?(:__rejuv_fixValues)
  def fixMissingValues
    __rejuv_fixValues
    @camerastyle = 0 if @camerastyle.nil?
    @cameraAccessibility = 0 if @cameraAccessibility.nil?
    @choiceDelay = 0 if @choiceDelay.nil?
    @ignoreMouse = $joiplay || $kirin ? 1 : 0 if @ignoreMouse.nil?
    @alwaysShowOverlay = 0 if @alwaysShowOverlay.nil?
  end
end

class PokemonOptionScene
  alias __rejuv_initOptions initOptions unless method_defined?(:__rejuv_initOptions)
  def initOptions
    ret = __rejuv_initOptions

    ret.insert(1, EnumOption.new(
      _INTL("Difficulty Selection"), [_INTL("Classic"), _INTL("Story")],
      proc { $game_variables[:DifficultyModes] },
      proc { |value|
        valuebefore = $game_variables[:DifficultyModes]
        $game_variables[:DifficultyModes] = value
        if value != valuebefore && value == 1
          Kernel.pbMessage(_INTL("Story Mode selected. Teams will be less optimized, and the effects of Field Effects will be halved."))
        end
        if value != valuebefore && value == 0
          Kernel.pbMessage(_INTL("Classic Mode selected. Enemies and Field Effects will operate at full power."))
        end
      },
      _INTL("Changes the selected difficulty.")
    )) if $game_switches

    ret.insert((ret.index { |f| !f.is_a?(String) && f.name == _INTL("Photosensitivity") } || 8) + 1, EnumOption.new(
      _INTL("Camera Sensitivity"), [_INTL("Off"), _INTL("On")],
      proc { $Settings.cameraAccessibility },
      proc { |value|
        valuebefore = $Settings.cameraAccessibility
        $Settings.cameraAccessibility = value
        if value != valuebefore && value == 1
          Kernel.pbMessage(_INTL("Please note that this option may not disable all modified movement in some cutscenes, but instead may largely reduce the issue."))
        end
      },
      _INTL("Disables smooth camera movement in various sections.")
    ))

    ret.insert((ret.index { |f| !f.is_a?(String) && f.name == _INTL("Choice Delay") } || 8) + 1, EnumOption.new(
      _INTL("Choice Delay"), [_INTL("On"), _INTL("Off")],
      proc { $Settings.choiceDelay },
      proc { |value|
        valuebefore = $Settings.choiceDelay
        $Settings.choiceDelay = value
      },
      _INTL("Adds an initial delay on being able to input choices in the overworld.")
    ))

    # Blessings
    if xenTowerInProgress
      optionList = []
      optionList.push(_INTL("Blessings Options"))
      optionList.push(EnumOption.new(
        _INTL("Ignore Mouse"), [_INTL("On"), _INTL("Off")],
        proc { $Settings.ignoreMouse },
        proc { |value| $Settings.ignoreMouse = value },
        _INTL("Choose to disable mouse-over info on Blessings.")
      )) unless mobile?
      optionList.push(EnumOption.new(
        _INTL("Always Show Overlay"), [_INTL("Off"), _INTL("On")],
        proc { $Settings.alwaysShowOverlay },
        proc { |value| $Settings.alwaysShowOverlay = value },
        _INTL("Always show Blessings overlay outside of battle.")
      ))
      ret = optionList + ret
    end

    return ret
  end
end

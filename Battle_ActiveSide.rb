class Battle_Side
  attr_accessor :index
  attr_accessor :effects

  # turn durations, layers, or other counters
  CountEff = [:Reflect, :LightScreen, :AuroraVeil, :AreniteWall, :AntiMatterShield, :Mist, :Safeguard, :LuckyChant, :Tailwind, :Spikes, :ToxicSpikes, :AlliesFainted]

  # either active or isn't
  SwitchEff = [:WideGuard, :QuickGuard, :CraftyShield, :MatBlock, :StealthRock, :PokemonFaintedThisTurn, :Retaliate, :PsyBlades]

  # other things (for sticky web, value indicates the setter of the effect)
  OtherEff = [:StickyWeb]

  def initialize(battle, index)
    @battle = battle
    @index = index # 0 for player, 1 for opponent
    @effects = {}
    CountEff.each { |eff| @effects[eff] = 0 }
    SwitchEff.each { |eff| @effects[eff] = false }
    OtherEff.each { |eff| @effects[eff] = nil }
    @effects[:SpecialMoves] = {
      :LONELYMOON => 1,
      :ORBITALRING => 1,
      :VENGEFULNUKE => 1,
      :REJUVENATION => 1,
      :PROMISEDALAIN => 1,
      :PROMISEDAXEL => 1,
      :PROMISEDAEVIA => 1,
      :PROMISEDAERO => 1,
      :PROMISEDAEVIS => 1,
      :PROMISEDARIANA => 1,
      :PROMISEDANA => 1,
    }
  end

  def defaultValue(effect)
    return 0 if CountEff.include?(effect)
    return false if SwitchEff.include?(effect)
    return nil
  end

  def atDefaultValue?(effect)
    return @effects[effect] == defaultValue(effect)
  end

  def screenActive?(category = nil)
    return false if category == :status
    return true if @effects[:AuroraVeil] > 0
    return true if @effects[:LightScreen] > 0 && (category == :special || category.nil?)
    return true if @effects[:Reflect] > 0 && (category == :physical || category.nil?)
    return false
  end

  def anyScreenActive?
    return PBStuff::SCREENEFFECTS.values.any? { |effect| @effects[effect] != 0 }
  end

  def anyHazardActive?
    return @effects[:StealthRock] || @effects[:Spikes] > 0 || @effects[:ToxicSpikes] > 0 || @effects[:StickyWeb]
  end

  def protectActive?
    return @effects[:WideGuard] || @effects[:QuickGuard] || @effects[:CraftyShield] || @effects[:MatBlock]
  end

  def resetProtect
    @effects[:WideGuard] = false
    @effects[:QuickGuard] = false
    @effects[:CraftyShield] = false
    @effects[:MatBlock] = false
  end

  def endEffect(effect)
    defaultValue = defaultValue(effect)
    return if @effects[effect] == defaultValue

    @effects[effect] = defaultValue
    @battle.pbDisplay(self.endEffectMessage(effect))
  end

  def spinAwayHazards
    oppside = @battle.sides[@index ^ 1]
    if @effects[:StealthRock]
      if !oppside.effects[:StealthRock] && !Rejuv && @battle.FE == :CAVE
        oppside.effects[:StealthRock] = true
        msg = _INTL("The pointed stones were sent towards the opposing team!") if @index == 0
        msg = _INTL("The pointed stones were sent towards your team!") if @index == 1
      else
        msg = self.endEffectMessage(:StealthRock)
      end
      @effects[:StealthRock] = false
      @battle.pbDisplay(msg)
    end
    if @effects[:Spikes] > 0
      if oppside.effects[:Spikes] < 3 && !Rejuv && @battle.FE == :CAVE
        temptotal = oppside.effects[:Spikes] + @effects[:Spikes]
        oppside.effects[:Spikes] = [temptotal, 3].max
        msg = _INTL("The spikes were sent towards the opposing team!") if @index == 0
        msg = _INTL("The spikes were sent towards your team!") if @index == 1
      else
        msg = self.endEffectMessage(:Spikes)
      end
      @effects[:Spikes] = 0
      @battle.pbDisplay(msg)
    end
    if @effects[:ToxicSpikes] > 0
      if oppside.effects[:ToxicSpikes] < 2 && !Rejuv && @battle.FE == :CAVE
        temptotal = oppside.effects[:ToxicSpikes] + @effects[:ToxicSpikes]
        oppside.effects[:ToxicSpikes] = [temptotal, 2].max
        msg = _INTL("The poison spikes were sent towards the opposing team!") if @index == 0
        msg = _INTL("The poison spikes were sent towards your team!") if @index == 1
      else
        msg = self.endEffectMessage(:ToxicSpikes)
      end
      @effects[:ToxicSpikes] = 0
      @battle.pbDisplay(msg)
    end
    if @effects[:StickyWeb]
      if !oppside.effects[:StickyWeb] && !Rejuv && @battle.FE == :CAVE
        oppside.effects[:StickyWeb] = @effects[:StickyWeb]
        msg = _INTL("The sticky web was sent towards the opposing team!") if @index == 0
        msg = _INTL("The sticky web was sent towards your team!") if @index == 1
      else
        msg = self.endEffectMessage(:StickyWeb)
      end
      @effects[:StickyWeb] = nil
      @battle.pbDisplay(msg)
    end
  end

  def endEffectMessage(effect)
    case effect
      when *PBStuff::SCREENEFFECTS.values
        name = getMoveName(PBStuff::SCREENEFFECTS.invert[effect])
        return _INTL("Your team's {1} wore off!", name) if @index == 0
        return _INTL("The opposing team's {1} wore off!", name) if @index == 1
      when :Mist
        return _INTL("Your team is no longer protected by mist!") if @index == 0
        return _INTL("The opposing team is no longer protected by mist!") if @index == 1
      when :Safeguard
        name = getMoveName(:SAFEGUARD)
        return _INTL("Your team is no longer protected by {1}!", name) if @index == 0
        return _INTL("The opposing team is no longer protected by {1}!", name) if @index == 1
      when :LuckyChant
        name = getMoveName(:LUCKYCHANT)
        return _INTL("Your team's {1} wore off!", name) if @index == 0
        return _INTL("The opposing team's {1} wore off!", name) if @index == 1
      when :Tailwind
        name = getMoveName(:TAILWIND)
        return _INTL("Your team's {1} petered out!", name) if @index == 0
        return _INTL("The opposing team's {1} petered out!", name) if @index == 1
      when :Spikes
        return _INTL("The spikes disappeared from the ground around your team!") if @index == 0
        return _INTL("The spikes disappeared from the ground around the opposing team!") if @index == 1
      when :ToxicSpikes
        return _INTL("The poison spikes disappeared from the ground around your team!") if @index == 0
        return _INTL("The poison spikes disappeared from the ground around the opposing team!") if @index == 1
      when :StealthRock
        return _INTL("The pointed stones disappeared from around your team!") if @index == 0
        return _INTL("The pointed stones disappeared from around the opposing team!") if @index == 1
      when :StickyWeb
        return _INTL("The sticky web has disappeared from the ground around your team!") if @index == 0
        return _INTL("The sticky web has disappeared from the ground around the opposing team!") if @index == 1
    end
  end
end


  CounterEff = [:Gravity, :TrickRoom, :MagicRoom, :FairyLock, :WonderRoom, :MudSport, :WaterSport, :sosBuffer]
  BoolEff = [:IonDeluge, :HeavyRain, :HarshSunlight, :DeltaStream, :NeverMeltIce, :Round, :RaikouStorm]
class Battle_Global
  attr_accessor :effects

  def initialize
    # Global effects
    @effects = {}
    # turn durations
    # @effects[:Splintered]         = 0
    @effects[:Gravity]            = 0
    @effects[:TrickRoom]          = 0
    @effects[:MagicRoom]          = 0
    @effects[:FairyLock]          = 0
    @effects[:WonderRoom]         = 0
    @effects[:MudSport]           = 0
    @effects[:WaterSport]         = 0
    @effects[:sosBuffer]          = 0
    # either active or isn't
    @effects[:IonDeluge]          = false
    @effects[:HeavyRain]          = false
    @effects[:HarshSunlight]      = false
    @effects[:DeltaStream]        = false
    @effects[:NeverMeltIce]       = false
    @effects[:Round]              = false
    @effects[:RaikouStorm]          = false
  end

  def defaultValue(effect)

    return 0 if CounterEff.include?(effect)
    return false if BoolEff.include?(effect)
    return nil
  end

  def atDefaultValue?(effect)
    return @effects[effect] == defaultValue(effect)
  end
end

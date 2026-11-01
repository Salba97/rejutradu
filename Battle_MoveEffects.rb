################################################################################
# Superclass that handles moves using a non-existent function code.
# Damaging moves just do damage with no additional effect.
# Non-damaging moves always fail.
################################################################################
class PokeBattle_UnimplementedMove < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if @basedamage > 0
      super
    else
      @battle.pbDisplay(_INTL("But it failed!"))
    end
  end
end

################################################################################
# Pseudomove for confusion damage
################################################################################
class PokeBattle_Confusion < PokeBattle_Move
  def initialize(battle, move)
    @battle      = battle
    @basemove    = move
    @pp          = -1

    @type        = -1 # no type (different from QMARKS)
    @basedamage  = 40
    @accuracy    = 100
    @target      = 0
    @priority    = 0
    @effect      = 0
    @recoil      = 0
  end

  def pbIsPhysical?(attacker, type = @type)
    return true
  end

  def pbIsSpecial?(attacker, type = @type)
    return false
  end

  def isSoundBased?
    return false
  end
end

################################################################################
# Implements the move Struggle.
# For cases where the real move named Struggle is not defined.
################################################################################
class PokeBattle_Struggle < PokeBattle_Move
  def initialize(battle, move, user, zbase = nil)
    if user.is_a?(PokeBattle_Battler)
      # Move instance is serialized and sent over network for Online battles.
      # As such it can't contain Battler because it contains Battle which is not serializable.
      raise "move user needs to be PokeBattle_Pokemon"
    end

    @battle     = battle
    @move       = :STRUGGLE
    @data       = $cache.moves[@move]
    @name       = getMoveShortName(@move)
    @basemove   = nil # not associated with a move
    @pp         = -1
    @zmove      = false
    @immediate  = false
    @user       = user
    @type       = -1 # no type (different from QMARKS)

    if @data
      @function   = @data.function
      @category   = @data.category
      @basedamage = @data.basedamage
      @accuracy   = @data.accuracy
      @maxpp      = @data.maxpp
      @target     = @data.target
      @priority   = @data.priority ? @data.priority : 0
      @effect     = @data.checkFlag?(:effect, 0)
      @moreeffect = @data.checkFlag?(:moreeffect, 0)
      @recoil     = @data.checkFlag?(:recoil, 0)
    end
  end

  def pbIsPhysical?(attacker, type = @type)
    return true
  end

  def pbIsSpecial?(attacker, type = @type)
    return false
  end

  def getRecoil(attacker, damage, recoilmult, hitflags)
    return 0 unless hitflags.include?(:Success)
    recoilmult = 0.25 # the recoil multiplier cannot be given to this move as a move attribute as the attribute is also used to check for Reckless
    return (attacker.totalhp * recoilmult).round
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    opponent = nil # Setting opponent to nil makes the struggle animation play correctly on the attacker rather than the opponent
    super
  end
end

################################################################################
# No additional effect.
################################################################################
class PokeBattle_Move_000 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if Rejuv && @battle.FE == :SWAMP && @move == :ATTACKORDER
      stat = @battle.sample(PBStats::Omni)
      opponent.pbChangeStats(stat, -1, attacker, self, abilitycheck: :hide)
    end
    if @battle.FE == :CHESS && @move == :FALSESURRENDER
      unless @battle.pbCheckSideAbility(:AROMAVEIL, opponent, checkMoldBroken: true).any? || (opponent.ability == :OBLIVIOUS && !opponent.moldbroken) || opponent.effects[:Taunt] > 0
        opponent.effects[:Taunt] = 4
        @battle.pbDisplay(_INTL("{1} fell for the taunt!", opponent.pbThis))
        opponent.pbBerryHerbCheck(true)
      end
    end
  end

  def getRecoil(attacker, damage, recoilmult, hitflags)
    recoilmult = 0 if @move == :WILDCHARGE && @battle.FE == :ELECTERRAIN
    recoilmult = 0.16 if @move == :BRAVEBIRD && @battle.FE == :CLOUDS
    recoilmult = 0.25 if @move == :WAVECRASH && [:WATERSURFACE, :UNDERWATER].include?(@battle.FE)
    return super
  end
end

################################################################################
# Does absolutely nothing (Splash).
################################################################################
class PokeBattle_Move_001 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    accdrop = false
    if @battle.FE == :WATERSURFACE
      for i in [attacker.pbOpposing1, attacker.pbOpposing2, attacker.pbPartner]
        if i.pbChangeStats(PBStats::ACCURACY, -1, attacker, self, abilitycheck: :hide)
          accdrop = true
        end
      end
    end

    @battle.pbDisplay(_INTL("But nothing happened!")) unless accdrop
  end
end

################################################################################
# Struggle.  Overrides the default Struggle effect above.
################################################################################
class PokeBattle_Move_002 < PokeBattle_Struggle
end

################################################################################
# Puts the target to sleep. (Dark Void / Grass Whistle / Spore / Sleep Powder /
# Relic Song / Lovely Kiss / Sing / Hypnosis)
################################################################################
class PokeBattle_Move_003 < PokeBattle_Move
  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if @move == :DARKVOID && [:DARKNESS2, :DARKNESS3].include?(@battle.FE)
      @battle.pbDisplay(_INTL("We fall..."))
      @battle.pbDisplay(_INTL("We fall... unto the end..."))
    end
    super
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanSleep?(attacker, self, showMessage: showMessage)
  end

  def pbOnStartUse(attacker, targets)
    if @move == :DARKVOID && !Rejuv && !(attacker.species == :DARKRAI || (Reborn && attacker.species == :HYPNO && attacker.form == 1))
      # Any non-Darkrai non-P-Hypno Pokemon outside Rejuv
      @battle.pbDisplay(_INTL("But {1} can't use the move!", attacker.pbThis(true)))
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @basedamage > 0

    opponent.pbSleep
  end

  def pbAdditionalEffect(attacker, opponent)
    return unless opponent.pbCanSleep?(attacker, self)

    opponent.pbSleep
  end
end

################################################################################
# Makes the target drowsy.  It will fall asleep at the end of the next turn. (Yawn)
################################################################################
class PokeBattle_Move_004 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.effects[:Yawn] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return false unless opponent.pbCanStatus?(attacker, self, showMessage: showMessage)
    sweetVeil = @battle.pbCheckSideAbility(:SWEETVEIL, opponent, checkMoldBroken: true)
    if sweetVeil.any?
      @battle.pbAbilityBoxAndDisplay(sweetVeil.first, _INTL("{1} is protected by an aromatic veil!", opponent.pbThis)) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Yawn] = 2
    @battle.pbDisplay(_INTL("{1} grew drowsy!", opponent.pbThis))
  end
end

################################################################################
# Poisons the target. (Gunk Shot / Sludge Wave / Sludge Bomb / Poison Jab / Cross Poison
# / Sludge / Poison Tail / Smog / Poison Sting / Poison Gas / Poison Powder)
################################################################################
class PokeBattle_Move_005 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanPoison?(attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @basedamage > 0

    if [:VOLCANICTOP, :BACKALLEY, :CITY].include?(@battle.FE) && @move == :POISONGAS
      opponent.pbPoison(attacker, true)
    else
      opponent.pbPoison(attacker)
    end
  end

  def pbAdditionalEffect(attacker, opponent)
    if @battle.FE == :WASTELAND && [:GUNKSHOT, :SLUDGEBOMB, :SLUDGEWAVE, :SLUDGE].include?(@move)
      rnd = @battle.pbRandom(4)
      # Poison Heal, Toxic Boost and Crested Zangoose ignore the random status and instead get poisoned.
      rnd = 3 if [:POISONHEAL, :TOXICBOOST].include?(opponent.ability) || opponent.crested == :ZANGOOSE ||
        ((opponent.hasType?(:POISON) || opponent.hasType?(:STEEL)) && attacker.ability != :CORROSION) ||
        (opponent.ability == :IMMUNITY && !opponent.moldbroken)
      case rnd
        when 0 then opponent.pbBurn(attacker) if opponent.pbCanBurn?(attacker, self)
        when 1 then opponent.pbFreeze if opponent.pbCanFreeze?(attacker, self)
        when 2 then opponent.pbParalyze(attacker) if opponent.pbCanParalyze?(attacker, self)
        when 3 then opponent.pbPoison(attacker) if opponent.pbCanPoison?(attacker, self)
      end
    else
      return if !opponent.pbCanPoison?(attacker, self)

      if [:BACKALLEY, :CITY].include?(@battle.FE) && @move == :SMOG
        opponent.pbPoison(attacker, true)
      else
        opponent.pbPoison(attacker)
      end
    end
  end
end

################################################################################
# Badly poisons the target. (Poison Fang / Malignant Chain / Toxic)
################################################################################
class PokeBattle_Move_006 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanPoison?(attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @basedamage > 0

    opponent.pbPoison(attacker, true)
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanPoison?(attacker, self)

    opponent.pbPoison(attacker, true)
  end

  def pbBaseAccuracy(baseacc, attacker, opponent)
    baseacc = 0 if attacker.hasType?(:POISON) && @move == :TOXIC
    return super
  end
end

################################################################################
# Paralyzes the target. (Nuzzle / Dragon Breath / Bolt Strike / Zap Cannon / Thunderbolt
# / Discharge / Thunder Punch / Spark / Thunder Shock / Thunder Wave / Force Palm
# / Lick / Stun Spore / Body Slam / Glare / Wildbolt Storm / Volt Tackle)
################################################################################
class PokeBattle_Move_007 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanPetrify?(attacker, self, showMessage: showMessage) if @move == :GLARE && @battle.FE == :DEUXFINALIS
    return opponent.pbCanParalyze?(attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @basedamage > 0
    if @move == :GLARE && @battle.FE == :DEUXFINALIS
      opponent.pbPetrify(attacker)
    else
      opponent.pbParalyze(attacker)
    end
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanParalyze?(attacker, self)

    opponent.pbParalyze(attacker)
  end
end

################################################################################
# Paralyzes the target. Accuracy perfect in rain, 50% in sunshine. (Thunder)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_008 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanParalyze?(attacker, self)

    opponent.pbParalyze(attacker)
  end

  def pbBaseAccuracy(baseacc, attacker, opponent)
    baseacc = 0 if @battle.pbWeather(attacker) == :RAINDANCE && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
    baseacc = 50 if @battle.pbWeather(attacker) == :SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
    return super
  end
end

################################################################################
# Paralyzes the target.  May cause the target to flinch. (Thunder Fang)
################################################################################
class PokeBattle_Move_009 < PokeBattle_Move
  def canFlinch?
    return true
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanParalyze?(attacker, self)

    opponent.pbParalyze(attacker)
  end

  def pbSecondAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
    end
  end
end

################################################################################
# Burns the target. (Blue Flare / Fire Blast / Heat Wave / Inferno / Searing Shot
# / Flamethrower / Blaze Kick / Lava Plume / Fire Punch / Flame Wheel / Ember
# / Will-O-Wisp / Scald / Steam Eruption / Sandsear Storm / Flare Blitz / Scorching Sands)
################################################################################
class PokeBattle_Move_00A < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanBurn?(attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @basedamage > 0

    opponent.pbBurn(attacker)
  end

  def pbAdditionalEffect(attacker, opponent)
    return false if !opponent.pbCanBurn?(attacker, self)

    opponent.pbBurn(attacker)
  end
end

################################################################################
# Burns the target.  May cause the target to flinch. (Fire Fang)
################################################################################
class PokeBattle_Move_00B < PokeBattle_Move
  def canFlinch?
    return true
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanBurn?(attacker, self)

    opponent.pbBurn(attacker)
  end

  def pbSecondAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
    end
  end
end

################################################################################
# Freezes the target. (Ice Beam / Ice Punch / Powder Snow / pre-Champions Freeze-Dry / Freezing Glare)
################################################################################
class PokeBattle_Move_00C < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanFreeze?(attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @basedamage > 0

    opponent.pbFreeze
  end

  def pbAdditionalEffect(attacker, opponent)
    if @battle.FE == :DEUXFINALIS && @move == :FREEZINGGLARE
      return if !opponent.pbCanPetrify?(attacker, self)
      opponent.pbPetrify(attacker)
      return
    end
    return if !opponent.pbCanFreeze?(attacker, self)

    opponent.pbFreeze
  end
end

################################################################################
# Freezes the target. Accuracy perfect in hail. (Blizzard)
################################################################################
class PokeBattle_Move_00D < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanFreeze?(attacker, self)

    opponent.pbFreeze
  end

  def pbBaseAccuracy(baseacc, attacker, opponent)
    baseacc = 0 if [:HAIL, :SNOW].include?(@battle.pbWeather(attacker))
    return super
  end
end

################################################################################
# Freezes the target.  May cause the target to flinch. (Ice Fang)
################################################################################
class PokeBattle_Move_00E < PokeBattle_Move
  def canFlinch?
    return true
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanFreeze?(attacker, self)

    opponent.pbFreeze
  end

  def pbSecondAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
    end
  end
end

################################################################################
# Causes the target to flinch. (Flinch / Dark Pulse / Bite / Rolling Kick / Air Slash
# / Astonish / Needle Arm / Hyper Fang / Headbutt / Extrasensory / Zen Headbutt
# / Heart Stamp / Rock Slide / Iron Head / Waterfall / Zing Zap / Mountain Gale)
################################################################################
class PokeBattle_Move_00F < PokeBattle_Move
  def canFlinch?
    return true
  end

  def pbAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
    end
  end
end

################################################################################
# Causes the target to flinch.  Does double damage if the target is Minimized.
# (Stomp, Steamroller, Dragon Rush)
################################################################################
class PokeBattle_Move_010 < PokeBattle_Move
  def canFlinch?
    return true
  end

  def pbAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
    end
  end
end

################################################################################
# Causes the target to flinch.  Fails if the user is not asleep. (Snore)
################################################################################
class PokeBattle_Move_011 < PokeBattle_Move
  def pbCanUseWhileAsleep?
    return true
  end

  def canFlinch?
    return true
  end

  def pbAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
    end
  end

  def pbOnStartUse(attacker, targets)
    unless attacker.isSleeping?
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end
end

################################################################################
# Causes the target to flinch.  Fails if this isn't the user's first turn. (Fake Out)
################################################################################
class PokeBattle_Move_012 < PokeBattle_Move
  def canFlinch?
    return true
  end

  def pbOnStartUse(attacker, targets)
    if attacker.turncount != 1 || !attacker.isFirstMoveOfRound
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
    end
  end
end

################################################################################
# Confuses the target. (Confusion, Signal Beam, Dynamic Punch, Chatter, Confuse Ray,
# Rock Climb, Dizzy Punch, Supersonic, Sweet Kiss, Teeter Dance, Psybeam, Water Pulse,
# Strange Steam)
################################################################################
class PokeBattle_Move_013 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanConfuse?(attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @basedamage > 0

    if @battle.FE == :FAIRYTALE && @move == :SWEETKISS
      if !opponent.damagestate.substitute && opponent.status == :SLEEP
        opponent.pbCureStatus
      end
    end
    opponent.pbConfuse
    if [:BIGTOP, :DANCEFLOOR].include?(@battle.FE) && @move == :TEETERDANCE
      opponent.pbChangeStats(PBStats::DEFENSE, -1, attacker, self, abilitycheck: :hide)
    end
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanConfuse?(attacker, self)
    opponent.pbConfuse
  end
end

################################################################################
# Confuses the target. Accuracy perfect in rain, 50% in sunshine. (Hurricane)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_015 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanConfuse?(attacker, self)
    opponent.pbConfuse
  end

  def pbBaseAccuracy(baseacc, attacker, opponent)
    baseacc = 0 if @battle.pbWeather(attacker) == :RAINDANCE && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
    baseacc = 50 if @battle.pbWeather(attacker) == :SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
    return super
  end
end

################################################################################
# Attracts the target. (Attract)
################################################################################
class PokeBattle_Move_016 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return opponent.pbCanAttract?(attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbAttract(attacker)
  end
end

################################################################################
# Burns, freezes or paralyzes the target. (Tri Attack)
################################################################################
class PokeBattle_Move_017 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    rnd = @battle.pbRandom(3)
    case rnd
      when 0
        return if !opponent.pbCanBurn?(attacker, self)

        opponent.pbBurn(attacker)
      when 1
        return if !opponent.pbCanFreeze?(attacker, self)

        opponent.pbFreeze
      when 2
        return if !opponent.pbCanParalyze?(attacker, self)

        opponent.pbParalyze(attacker)
    end
  end
end

################################################################################
# Cures user of burn, poison and paralysis. (Refresh)
################################################################################
class PokeBattle_Move_018 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if ![:BURN, :POISON, :PARALYSIS].include?(attacker.status)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbCureStatus
  end
end

################################################################################
# Cures all party Pokémon of permanent status problems. (Aromatherapy, Heal Bell)
################################################################################
class PokeBattle_Move_019 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    # Supposed to go before Protean activation
    @battle.pbDisplay(_INTL("A soothing aroma wafted through the area!")) if @move == :AROMATHERAPY
    @battle.pbDisplay(_INTL("A bell chimed!")) if @move == :HEALBELL
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    targets = [attacker.pbPartner, attacker].select { |i| !i.isFainted? }
    hitflags = [:Success] * targets.length
    @battlersSuccess = []

    # These moves are known to make specifically type immunity (inc. Soundproof) success checks against affected battlers
    pbTypeImmunities(attacker, targets, hitflags)
    targets.each_with_index { |target, i|
      @battlersSuccess.push(target.index) if hitflags[i] == :Success
      attacker.moveFailureEffects(attacker, self, target, hitflags[i]) if hitflags[i] != :Success
    }

    return true if @battlersSuccess.any?
    return true if @battle.pbCombinedParty(attacker.index).any? { |i| !i.status.nil? }
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    for i in @battlersSuccess
      @battle.battlers[i].pbCureStatus if !@battle.battlers[i].status.nil?
    end

    for pkmn in @battle.pbCombinedParty(attacker.index) # Applies to both parties in a multi battle
      next if !pkmn || pkmn.isEgg?
      next if [attacker.pbPartner, attacker].any? { |i| i.pokemon == pkmn }

      case pkmn.status
        when :PARALYSIS then @battle.pbDisplay(_INTL("{1} was cured of paralysis!", pkmn.name))
        when :SLEEP     then @battle.pbDisplay(_INTL("{1} woke up!", pkmn.name))
        when :POISON    then @battle.pbDisplay(_INTL("{1} was cured of its poisoning!", pkmn.name))
        when :BURN      then @battle.pbDisplay(_INTL("{1}'s burn was cured!", pkmn.name))
        when :FROZEN    then @battle.pbDisplay(_INTL("{1} was thawed out!", pkmn.name))
        when :PETRIFIED then @battle.pbDisplay(_INTL("{1} was released from the stone.", pkmn.name))
      end
      pkmn.healStatus
    end
  end
end

################################################################################
# Safeguards the user's side from being inflicted with status problems. (Safeguard)
################################################################################
class PokeBattle_Move_01A < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.pbOwnSide.effects[:Safeguard] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:Safeguard] = 5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team cloaked itself in a mystical veil!"))
    else
      @battle.pbDisplay(_INTL("The opposing team cloaked itself in a mystical veil!"))
    end
  end
end

################################################################################
# User passes its status problem to the target. (Psycho Shift)
################################################################################
class PokeBattle_Move_01B < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.status.nil? || !opponent.pbCanApplySelectStatus?(attacker.status, attacker, self)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    appliedStatus = attacker.status == :POISON && attacker.statusCount != 0 ? :TOXIC : attacker.status
    opponent.pbApplySelectStatus(appliedStatus, attacker, volatile: false)
    attacker.pbCureStatus
  end
end

################################################################################
# Increases the user's Attack by 1 stage. (Gen 7 Howl, Sharpen, Meditate, Meteor Mash, Metal Claw, Power-Up Punch)
################################################################################
class PokeBattle_Move_01C < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    if @battle.FE == :PSYTERRAIN && @move == :MEDITATE
      return attacker.pbCanIncreaseAnyStat?(PBStats::Offensive, attacker, self, showMessage: showMessage)
    end
    return attacker.pbCanIncreaseStatStage?(PBStats::ATTACK, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @basedamage > 0
    stats = PBStats::ATTACK
    amount = 1
    amount = 2 if (@battle.FE == :COLOSSEUM || @battle.ProgressiveFieldCheck(PBFields::CONCERT)) && @move == :HOWL
    amount = 3 if [:RAINBOW, :ASHENBEACH].include?(@battle.FE) && @move == :MEDITATE
    if @battle.FE == :PSYTERRAIN && @move == :MEDITATE
      stats, amount = PBStats::Offensive, 2
    end
    abilitycheck = stats == PBStats::ATTACK ? :skip : :show
    attacker.pbChangeStats(stats, amount, attacker, self, abilitycheck: abilitycheck)
  end

  def pbAdditionalEffectSelf(attacker)
    attacker.pbChangeStats(PBStats::ATTACK, 1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Increases the user's Defense by 1 stage. (Harden, Steel Wing, Withdraw, Psyshield Bash)
################################################################################
class PokeBattle_Move_01D < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @basedamage > 0
    attacker.pbChangeStats(PBStats::DEFENSE, 1, attacker, self, abilitycheck: :skip)
  end

  def pbAdditionalEffectSelf(attacker)
    stats = PBStats::DEFENSE
    stats = PBStats::Defensive if @battle.FE == :PSYTERRAIN && @move == :PSYSHIELDBASH
    attacker.pbChangeStats(stats, 1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Increases the user's Defense by 1 stage.  User curls up. (Defense Curl)
################################################################################
class PokeBattle_Move_01E < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @basedamage > 0
    if attacker.pbChangeStats(PBStats::DEFENSE, 1, attacker, self, abilitycheck: :skip)
      attacker.effects[:DefenseCurl] = true
    end
  end
end

################################################################################
# Increases the user's Speed by 1 stage. (Flame Charge / Esper Wing / Aqua Step /
# Trailblaze)
################################################################################
class PokeBattle_Move_01F < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return attacker.pbCanIncreaseStatStage?(PBStats::SPEED, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @basedamage > 0
    attacker.pbChangeStats(PBStats::SPEED, 1, attacker, self, abilitycheck: :skip)
  end

  def pbAdditionalEffectSelf(attacker)
    amount = 1
    amount = 2 if @move == :ESPERWING && @battle.FE == :PSYTERRAIN
    attacker.pbChangeStats(PBStats::SPEED, amount, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Increases the user's Special Attack by 1 stage. (Charge Beam, Fiery Dance, Mystical Power,
# Torch Song)
################################################################################
class PokeBattle_Move_020 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return attacker.pbCanIncreaseStatStage?(PBStats::SPATK, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @basedamage > 0
    attacker.pbChangeStats(PBStats::SPATK, 1, attacker, self, abilitycheck: :skip)
  end

  def pbAdditionalEffectSelf(attacker)
    amount = 1
    amount = 2 if @battle.FE == :PSYTERRAIN && @move == :MYSTICALPOWER
    attacker.pbChangeStats(PBStats::SPATK, amount, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Increases the user's Special Defense by 1 stage.  Charges up Electric attacks. (Charge)
################################################################################
class PokeBattle_Move_021 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Charge] = 2
    @battle.pbDisplay(_INTL("{1} began charging power!", attacker.pbThis))
    statchange = @battle.FE == :ELECTERRAIN ? 2 : 1
    attacker.pbChangeStats(PBStats::SPDEF, statchange, attacker, self)
  end
end

################################################################################
# Increases the user's evasion by 1 stage. (Double Team)
################################################################################
class PokeBattle_Move_022 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseStatStage?(PBStats::EVASION, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = @battle.FE == :MIRROR ? 2 : 1
    attacker.pbChangeStats(PBStats::EVASION, statchange, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Increases the user's critical hit rate. (Focus Energy)
################################################################################
class PokeBattle_Move_023 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if attacker.effects[:FocusEnergy] < 1
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:FocusEnergy] = 2
    attacker.effects[:FocusEnergy] = 3 if @battle.FE == :ASHENBEACH
    @battle.pbDisplay(_INTL("{1} is getting pumped!", attacker.pbThis))
  end
end

################################################################################
# Increases the user's Attack and Defense by 1 stage each. (Bulk Up)
################################################################################
class PokeBattle_Move_024 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?(PBStats::Physical, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = @battle.FE == :CROWD ? 2 : 1
    attacker.pbChangeStats(PBStats::Physical, statchange, attacker, self)
  end
end

################################################################################
# Increases the user's Attack, Defense and Accuracy by 1 stage each. (Coil)
################################################################################
class PokeBattle_Move_025 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::DEFENSE, PBStats::ACCURACY], attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = 1
    statchange = 2 if @battle.FE == :GRASSY || (Rejuv && @battle.FE == :DRAGONSDEN)
    attacker.pbChangeStats([PBStats::ATTACK, PBStats::DEFENSE, PBStats::ACCURACY], statchange, attacker, self)
  end
end

################################################################################
# Increases the user's Attack and Speed by 1 stage each. (Dragon Dance)
################################################################################
class PokeBattle_Move_026 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::SPEED], attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = 1
    statchange = 2 if [:BIGTOP, :DRAGONSDEN, :DANCEFLOOR].include?(@battle.FE) && @move == :DRAGONDANCE
    attacker.pbChangeStats([PBStats::ATTACK, PBStats::SPEED], statchange, attacker, self)
  end
end

################################################################################
# Increases the user's Attack and Special Attack by 1 stage each. (Work Up)
################################################################################
class PokeBattle_Move_027 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?(PBStats::Offensive, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = 1
    statchange = 2 if @battle.ProgressiveFieldCheck(PBFields::CONCERT) || [:CROWD, :CITY].include?(@battle.FE)
    attacker.pbChangeStats(PBStats::Offensive, statchange, attacker, self)
  end
end

################################################################################
# Increases the user's Attack and Sp. Attack by 1 stage each (2 each in sunshine).
# (Growth)
################################################################################
class PokeBattle_Move_028 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?(PBStats::Offensive, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = 1
    statchange = 2 if @battle.pbWeather(attacker) == :SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
    statchange = 2 if [:GRASSY, :FOREST].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 1, 2)
    statchange = 3 if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5)
    attacker.pbChangeStats(PBStats::Offensive, statchange, attacker, self)
  end
end

################################################################################
# Increases the user's Attack and accuracy by 1 stage each. (Hone Claws)
################################################################################
class PokeBattle_Move_029 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::ACCURACY], attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats([PBStats::ATTACK, PBStats::ACCURACY], 1, attacker, self)
  end
end

################################################################################
# Increases the user's Defense and Special Defense by 1 stage each. (Cosmic Power, Defend Order)
################################################################################
class PokeBattle_Move_02A < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?(PBStats::Defensive, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = 1
    statchange = 2 if [:MISTY, :RAINBOW, :HOLY, :STARLIGHT, :NEWWORLD, :PSYTERRAIN].include?(@battle.FE) && @move == :COSMICPOWER
    statchange = 2 if @battle.FE == :FOREST && @move == :DEFENDORDER
    attacker.pbChangeStats(PBStats::Defensive, statchange, attacker, self)
  end
end

################################################################################
# Increases the user's Special Attack, Special Defense and Speed  by 1 stage each. (Quiver Dance)
################################################################################
class PokeBattle_Move_02B < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?([PBStats::SPATK, PBStats::SPDEF, PBStats::SPEED], attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    amount = 1
    amount = 2 if [:BIGTOP, :DANCEFLOOR].include?(@battle.FE) && @move == :QUIVERDANCE
    attacker.pbChangeStats([PBStats::SPATK, PBStats::SPDEF, PBStats::SPEED], amount, attacker, self)
  end
end

################################################################################
# Increases the user's Special Attack and Special Defense by 1 stage each. (Calm Mind)
################################################################################
class PokeBattle_Move_02C < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?(PBStats::Special, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = 1
    statchange = 2 if [:CHESS, :ASHENBEACH, :PSYTERRAIN].include?(@battle.FE)
    attacker.pbChangeStats(PBStats::Special, statchange, attacker, self)
  end
end

################################################################################
# Increases the user's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 stage each. (Ancient Power, Silver Wind, Ominous Wind)
################################################################################
class PokeBattle_Move_02D < PokeBattle_Move
  def pbAdditionalEffectSelf(attacker)
    stats = PBStats::Omni
    attacker.pbChangeStats(stats, 1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Increases the user's Attack by 2 stages. (Swords Dance)
################################################################################
class PokeBattle_Move_02E < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseStatStage?(PBStats::ATTACK, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = 2
    statchange = 3 if @move == :SWORDSDANCE && [:BIGTOP, :FAIRYTALE, :COLOSSEUM, :DANCEFLOOR].include?(@battle.FE)
    attacker.pbChangeStats(PBStats::ATTACK, statchange, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Increases the user's Defense by 2 stages. (Iron Defense, Acid Armor, Barrier, Diamond Storm, Shelter)
################################################################################
class PokeBattle_Move_02F < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @basedamage > 0
    statchange = 2
    statchange = 3 if @move == :IRONDEFENSE && @battle.FE == :FACTORY
    statchange = 3 if @move == :SHELTER && @battle.FE == :SWAMP
    statchange = 3 if @move == :ACIDARMOR && ([:CORROSIVE, :CORROSIVEMIST, :MURKWATERSURFACE, :FAIRYTALE].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::CONCERT))
    attacker.pbChangeStats(PBStats::DEFENSE, statchange, attacker, self, abilitycheck: :skip)
    if Rejuv && @move == :SHELTER && attacker.effects[:Shelter] == false
      attacker.effects[:Shelter] = true
      @battle.pbDisplay(_INTL("{1} is sheltering itself from the surroundings!", attacker.pbThis))
    end
  end

  def pbAdditionalEffectSelf(attacker)
    attacker.pbChangeStats(PBStats::DEFENSE, 2, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Increases the user's Speed by 2 stages. (Agility, Rock Polish)
################################################################################
class PokeBattle_Move_030 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if @move == :ROCKPOLISH && @battle.FE == :CRYSTALCAVERN
      return attacker.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED], attacker, self, showMessage: showMessage)
    end
    return attacker.pbCanIncreaseStatStage?(PBStats::SPEED, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    stats = PBStats::SPEED
    amounts = 2
    amounts = 3 if @battle.FE == :ROCKY && @move == :ROCKPOLISH
    if @battle.FE == :CRYSTALCAVERN && @move == :ROCKPOLISH
      stats, amounts = [PBStats::SPEED, PBStats::ATTACK, PBStats::SPATK], [2, 1, 1]
    end
    abilitycheck = stats == PBStats::SPEED ? :skip : :show
    attacker.pbChangeStats(stats, amounts, attacker, self, abilitycheck: abilitycheck)
  end
end

################################################################################
# Increases the user's Speed by 2 stages.  Reduces the user's weight. (Autotomize)
################################################################################
class PokeBattle_Move_031 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseStatStage?(PBStats::SPEED, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = [:FACTORY, :DEEPEARTH, :CITY].include?(@battle.FE) ? 3 : 2
    if attacker.pbChangeStats(PBStats::SPEED, statchange, attacker, self, abilitycheck: :skip)
      attacker.effects[:WeightModifier] -= 1000
      @battle.pbDisplay(_INTL("{1} became nimble!", attacker.pbThis))
    end
  end
end

################################################################################
# Increases the user's Special Attack by 2 stages. (Nasty Plot)
################################################################################
class PokeBattle_Move_032 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseStatStage?(PBStats::SPATK, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = [:CHESS, :PSYTERRAIN, :INFERNAL, :BACKALLEY].include?(@battle.FE) ? 3 : 2
    attacker.pbChangeStats(PBStats::SPATK, statchange, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Increases the user's Special Defense by 2 stages. (Amnesia)
################################################################################
class PokeBattle_Move_033 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseStatStage?(PBStats::SPDEF, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::SPDEF, 2, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Increases the user's evasion by 2 stages.  Minimizes the user. (Minimize)
################################################################################
class PokeBattle_Move_034 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseStatStage?(PBStats::EVASION, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if attacker.pbChangeStats(PBStats::EVASION, 2, attacker, self, abilitycheck: :skip)
      attacker.effects[:Minimize] = true
    end
  end
end

################################################################################
# Decreases the user's Defense and Special Defense by 1 stage each.
# Increases the user's Attack, Speed and Special Attack by 2 stages each. (Shell Smash)
################################################################################
class PokeBattle_Move_035 < PokeBattle_Move
  # Cat 3 failure just for QoL, Shell Smash actually doesn't fail in canon even if at +6 and -6 for all the respective stats
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED], attacker, self) || attacker.pbCanReduceAnyStat?(PBStats::Defensive, attacker, self)
      return true
    end
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    stats = [PBStats::DEFENSE, PBStats::SPDEF, PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED]
    amounts = [-1, -1, 2, 2, 2]
    attacker.pbChangeStats(stats, amounts, attacker, self)
  end
end

################################################################################
# Increases the user's Speed by 2 stages, and its Attack by 1 stage. (Shift Gear)
################################################################################
class PokeBattle_Move_036 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::SPEED], attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    atkchange = [:FACTORY, :CITY].include?(@battle.FE) ? 2 : 1
    attacker.pbChangeStats([PBStats::ATTACK, PBStats::SPEED], [atkchange, 2], attacker, self)
  end
end

################################################################################
# Increases one random stat of the target by 2 stages (except HP). (Acupressure)
################################################################################
class PokeBattle_Move_037 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if attacker.index != opponent.index && blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return opponent.pbCanIncreaseAnyStat?(PBStats::All, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    stats = PBStats::All.select { |stat| opponent.pbCanIncreaseStatStage?(stat, attacker, self) }
    opponent.pbChangeStats(@battle.sample(stats), 2, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Increases the user's Defense by 3 stages. (Cotton Guard)
################################################################################
class PokeBattle_Move_038 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::DEFENSE, 3, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Increases the user's Special Attack by 3 stages. (Tail Glow)
################################################################################
class PokeBattle_Move_039 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseStatStage?(PBStats::SPATK, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::SPATK, 3, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Reduces the user's HP by half of max, and sets its Attack to maximum. (Belly Drum)
################################################################################
class PokeBattle_Move_03A < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.hp <= [(attacker.totalhp / 2.0).floor, 1].max || !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK, attacker, self)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbReduceHP([(attacker.totalhp / 2.0).floor, 1].max, false, false) # late message
    # Calling pbChangeStats will apply Contrary correctly.
    attacker.pbChangeStats(PBStats::ATTACK, 12, attacker, self, abilitycheck: :skip, statmessage: :none)
    @battle.pbDisplay(_INTL("{1} cut its own HP and maximized its {2}!", attacker.pbThis, getStatName(PBStats::ATTACK)))
    if @battle.FE == :BIGTOP
      attacker.pbChangeStats(PBStats::Defensive, 1, attacker, self, abilitycheck: :hide)
    end
    attacker.pbBerryHerbCheck
  end
end

################################################################################
# Decreases the user's Attack and Defense by 1 stage each. (Superpower)
################################################################################
class PokeBattle_Move_03B < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::Physical, -1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Decreases the user's Defense and Special Defense by 1 stage each.
# (Close Combat, Dragon Ascent, Headlong Rush, Armor Cannon)
################################################################################
class PokeBattle_Move_03C < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::Defensive, -1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Decreases the user's Defense, Special Defense and Speed by 1 stage each. (V-Create)
################################################################################
class PokeBattle_Move_03D < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats([PBStats::DEFENSE, PBStats::SPDEF, PBStats::SPEED], -1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Decreases the user's Speed by 1 stage. (Hammer Arm, Ice Hammer)
################################################################################
class PokeBattle_Move_03E < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::SPEED, -1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Decreases the user's Special Attack by 2 stages. (Overheat, Draco Meteor, Leaf Storm, Psycho Boost, Fleur Cannon)
################################################################################
class PokeBattle_Move_03F < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::SPATK, -2, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Increases the target's Special Attack by 1 stage.  Confuses the target. (Flatter)
################################################################################
class PokeBattle_Move_040 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if !blockedBySubstitute?(attacker, opponent) && (opponent.pbCanConfuse?(attacker, self) || opponent.pbCanIncreaseStatStage?(PBStats::SPATK, attacker, self))
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    amount = @battle.FE == :COLOSSEUM ? 2 : 1
    opponent.pbChangeStats(PBStats::SPATK, amount, attacker, self, abilitycheck: :hide)
    if opponent.pbCanConfuse?(attacker, self)
      opponent.pbConfuse
    end
  end
end

################################################################################
# Increases the target's Attack by 2 stages.  Confuses the target. (Swagger)
################################################################################
class PokeBattle_Move_041 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if !blockedBySubstitute?(attacker, opponent) && (opponent.pbCanConfuse?(attacker, self) || opponent.pbCanIncreaseStatStage?(PBStats::ATTACK, attacker, self))
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    amount = @battle.FE == :COLOSSEUM ? 3 : 2
    opponent.pbChangeStats(PBStats::ATTACK, amount, attacker, self, abilitycheck: :hide)
    if opponent.pbCanConfuse?(attacker, self)
      opponent.pbConfuse
    end
  end
end

################################################################################
# Decreases the target's Attack by 1 stage.
# (Growl, Aurora Beam, Baby-Doll Eyes, Play Nice, Play Rough, Lunge, Trop Kick,
# Breaking Swipe, Bitter Malice, Springtide Storm, Chilling Water)
################################################################################
class PokeBattle_Move_042 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanReduceStatStage?(PBStats::ATTACK, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @basedamage > 0

    amount = -1
    amount = -2 if @battle.ProgressiveFieldCheck(PBFields::CONCERT) && @move == :GROWL
    opponent.pbChangeStats(PBStats::ATTACK, amount, attacker, self, abilitycheck: :skip)
  end

  def pbAdditionalEffect(attacker, opponent)
    stats = PBStats::ATTACK
    stats = PBStats::Offensive if @battle.FE == :HAUNTED && @move == :BITTERMALICE
    opponent.pbChangeStats(stats, -1, attacker, self, abilitycheck: :hide)
    if @move == :BITTERMALICE && [:ICY, :SNOWYMOUNTAIN].include?(@battle.FE)
      if @battle.pbRandom(10) == 0
        if opponent.pbCanFreeze?(attacker, self)
          opponent.pbFreeze
        end
      end
    end
    if @move == :BITTERMALICE && [:DEUXFINALIS].include?(@battle.FE)
      if opponent.pbCanPetrify?(attacker, self)
        opponent.pbPetrify(attacker)
      end
    end
  end
end

################################################################################
# Decreases the target's Defense by 1 stage.
# (Tail Whip, Crunch, Rock Smash, Crush Claw, Leer, Iron Tail, Razor Shell,
# Fire Lash, Liquidation, Shadow Bone)
################################################################################
class PokeBattle_Move_043 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanReduceStatStage?(PBStats::DEFENSE, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return true if @basedamage > 0
    opponent.pbChangeStats(PBStats::DEFENSE, -1, attacker, self, abilitycheck: :skip)
  end

  def pbAdditionalEffect(attacker, opponent)
    opponent.pbChangeStats(PBStats::DEFENSE, -1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Decreases the target's Speed by 1 stage.
# (Rock Tomb, Electroweb, Low Sweep, Bulldoze, Mud Shot, Glaciate, Icy Wind,
# Constrict, Bubble Beam, Bubble, Bleakwind Storm, Pounce)
################################################################################
class PokeBattle_Move_044 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanReduceStatStage?(PBStats::SPEED, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return true if @basedamage > 0
    opponent.pbChangeStats(PBStats::SPEED, -1, attacker, self, abilitycheck: :skip)
  end

  def pbAdditionalEffect(attacker, opponent)
    statchange = -1
    statchange = -2 if Rejuv && @battle.FE == :ELECTERRAIN && @move == :ELECTROWEB
    statchange = -2 if Rejuv && @battle.FE == :SWAMP && @move == :MUDSHOT
    opponent.pbChangeStats(PBStats::SPEED, statchange, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Decreases the target's Special Attack by 1 stage. (Snarl / Confide / Moonblast /
# Mystical Fire / Struggle Bug / Mist Ball)
################################################################################
class PokeBattle_Move_045 < PokeBattle_Move
  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if @move == :CONFIDE && @battle.FE == :PSYTERRAIN
      @battle.pbDisplay(_INTL("Psst... This field is pretty weird, huh?"))
    end
    super
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanReduceStatStage?(PBStats::SPATK, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return true if @basedamage > 0
    opponent.pbChangeStats(PBStats::SPATK, -1, attacker, self, abilitycheck: :skip)
  end

  def pbAdditionalEffect(attacker, opponent)
    statchange = -1
    statchange = -2 if Rejuv && @battle.FE == :SWAMP && @move == :STRUGGLEBUG
    statchange = -2 if [:FROZENDIMENSION, :BACKALLEY].include?(@battle.FE) && @move == :SNARL
    opponent.pbChangeStats(PBStats::SPATK, statchange, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Decreases the target's Special Defense by 1 stage. (Bug Buzz / Focus Blast /
# Shadow Ball / Energy Ball / Earth Power / Acid / Psychic / Luster Purge / Flash Cannon)
################################################################################
class PokeBattle_Move_046 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanReduceStatStage?(PBStats::SPDEF, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return true if @basedamage > 0
    opponent.pbChangeStats(PBStats::SPDEF, -1, attacker, self, abilitycheck: :skip)
  end

  def pbAdditionalEffect(attacker, opponent)
    opponent.pbChangeStats(PBStats::SPDEF, -1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Decreases the target's accuracy by 1 stage.
# (Sand Attack, Night Daze, Leaf Tornado, Mod Bomb, Mud-Slap, Flash,
# Smokescreen, Kinesis, Mirror Shot, Muddy Water, Octazooka)
################################################################################
class PokeBattle_Move_047 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanReduceStatStage?(PBStats::ACCURACY, attacker, self, showMessage: showMessage) || attacker.pbCanIncreaseAnyStat?(PBStats::Offensive, attacker, self, showMessage: showMessage) if @battle.FE == :PSYTERRAIN && @move == :KINESIS
    return opponent.pbCanReduceAnyStat?([PBStats::ACCURACY, PBStats::SPDEF], attacker, self, showMessage: showMessage) if @battle.FE == :DANCEFLOOR && @move == :KINESIS
    return opponent.pbCanReduceStatStage?(PBStats::ACCURACY, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return true if @basedamage > 0
    stats = PBStats::ACCURACY
    amounts = -1
    amounts = -2 if [:BURNING, :CORROSIVEMIST, :VOLCANIC, :VOLCANICTOP, :BACKALLEY, :CITY].include?(@battle.FE) && @move == :SMOKESCREEN
    amounts = -2 if [:DESERT, :ASHENBEACH].include?(@battle.FE) && @move == :SANDATTACK
    amounts = -2 if [:SHORTCIRCUIT, :DARKCRYSTALCAVERN, :MIRROR, :STARLIGHT, :NEWWORLD, :DARKNESS1].include?(@battle.FE) && @move == :FLASH
    amounts = -2 if [:ASHENBEACH, :PSYTERRAIN].include?(@battle.FE) && @move == :KINESIS
    if @battle.FE == :DANCEFLOOR && @move == :KINESIS
      stats, amounts = [PBStats::ACCURACY, PBStats::SPDEF], [-2, -1]
    end
    abilitycheck = stats == PBStats::ACCURACY && !(@battle.FE == :PSYTERRAIN && @move == :KINESIS) ? :skip : :show
    opponent.pbChangeStats(stats, amounts, attacker, self, abilitycheck: abilitycheck)
    if @battle.FE == :PSYTERRAIN && @move == :KINESIS
      attacker.pbChangeStats(PBStats::Offensive, 2, attacker, self)
    end
  end

  def pbAdditionalEffect(attacker, opponent)
    if @battle.FE == :WASTELAND && @move == :OCTAZOOKA
      rnd = @battle.pbRandom(4)
      # Poison Heal, Toxic Boost and Crested Zangoose ignore the random status and instead get poisoned.
      rnd = 3 if [:POISONHEAL, :TOXICBOOST].include?(opponent.ability) || opponent.crested == :ZANGOOSE ||
        ((opponent.hasType?(:POISON) || opponent.hasType?(:STEEL)) && attacker.ability != :CORROSION) ||
        (opponent.ability == :IMMUNITY && !opponent.moldbroken)
      case rnd
        when 0 then opponent.pbBurn(attacker) if opponent.pbCanBurn?(attacker, self)
        when 1 then opponent.pbFreeze if opponent.pbCanFreeze?(attacker, self)
        when 2 then opponent.pbParalyze(attacker) if opponent.pbCanParalyze?(attacker, self)
        when 3 then opponent.pbPoison(attacker) if opponent.pbCanPoison?(attacker, self)
      end
    else
      opponent.pbChangeStats(PBStats::ACCURACY, -1, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# Decreases the target's evasion by 2 stage. (Sweet Scent)
################################################################################
class PokeBattle_Move_048 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return opponent.pbCanReduceAnyStat?([PBStats::EVASION, PBStats::DEFENSE, PBStats::SPDEF], attacker, self, showMessage: showMessage) if @battle.FE == :MISTY || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5)
    return opponent.pbCanReduceStatStage?(PBStats::EVASION, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    stats = PBStats::EVASION
    amounts = -2
    if @battle.FE == :MISTY || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5)
      stats = [PBStats::EVASION, PBStats::DEFENSE, PBStats::SPDEF]
      case @battle.FE
        when :MISTY, :FLOWERGARDEN3 then defamount = 1
        when :FLOWERGARDEN4 then defamount = 2
        when :FLOWERGARDEN5 then defamount = 3
      end
      amounts = [-2, -defamount, -defamount]
    end
    abilitycheck = stats == PBStats::EVASION ? :skip : :show
    opponent.pbChangeStats(stats, amounts, attacker, self, abilitycheck: abilitycheck)
  end
end

################################################################################
# Decreases the target's evasion by 1 stage. Ends all barriers for the target's
# side. Ends entry hazards for both sides. (Gen 8 onwards) Ends terrains. (Defog)
################################################################################
class PokeBattle_Move_049 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    statchange = @battle.FE == :CLOUDS ? -2 : -1
    opponent.pbChangeStats(PBStats::EVASION, statchange, attacker, self)

    @battle.pbEndSideEffects(opponent.pbOwnSide, [*PBStuff::SCREENEFFECTS.values, :Mist, :Safeguard])
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.pbEndSideEffects(@battle.sides, [:Spikes, :ToxicSpikes, :StealthRock, :StickyWeb])
    @battle.endTempFieldOrOverlay if Gen > 7
  end
end

################################################################################
# Decreases the target's Attack and Defense by 1 stage each. (Tickle)
################################################################################
class PokeBattle_Move_04A < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return opponent.pbCanReduceAnyStat?(PBStats::Physical, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbChangeStats(PBStats::Physical, -1, attacker, self)
  end
end

################################################################################
# Decreases the target's Attack by 2 stages. (Charm / Feather Dance)
################################################################################
class PokeBattle_Move_04B < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return opponent.pbCanReduceAnyStat?(PBStats::Offensive, attacker, self, showMessage: showMessage) if @battle.FE == :DANCEFLOOR && @move == :FEATHERDANCE
    return opponent.pbCanReduceStatStage?(PBStats::ATTACK, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    stats = PBStats::ATTACK
    stats = PBStats::Offensive if @battle.FE == :DANCEFLOOR && @move == :FEATHERDANCE
    amount = -2
    amount = -3 if @battle.FE == :BIGTOP && @move == :FEATHERDANCE
    abilitycheck = stats == PBStats::ATTACK ? :skip : :show
    opponent.pbChangeStats(stats, amount, attacker, self, abilitycheck: abilitycheck)
  end
end

################################################################################
# Decreases the target's Defense by 2 stages. (Screech / Shadow Down)
################################################################################
class PokeBattle_Move_04C < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return opponent.pbCanReduceStatStage?(PBStats::DEFENSE, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    amount = @battle.ProgressiveFieldCheck(PBFields::CONCERT) ? -3 : -2
    opponent.pbChangeStats(PBStats::DEFENSE, amount, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Decreases the target's Speed by 2 stages. (String Shot / Cotton Spore / Scary Face)
################################################################################
class PokeBattle_Move_04D < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return opponent.pbCanReduceStatStage?(PBStats::SPEED, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if Rejuv && @battle.FE == :SWAMP && @move == :STRINGSHOT
      stat = @battle.sample(PBStats::Omni)
      if stat == PBStats::SPEED
        opponent.pbChangeStats(PBStats::SPEED, -3, attacker, self, abilitycheck: :skip)
      else
        opponent.pbChangeStats([PBStats::SPEED, stat], [-2, -1], attacker, self)
      end
    else
      amount = -2
      amount = -3 if @battle.FE == :HAUNTED && @move == :SCARYFACE
      amount = -3 if Rejuv && @battle.FE == :GRASSY && @move == :COTTONSPORE
      opponent.pbChangeStats(PBStats::SPEED, amount, attacker, self, abilitycheck: :skip)
    end
  end
end

################################################################################
# Decreases the target's Special Attack by 2 stages.  Only works on the opposite
# gender. (Captivate)
################################################################################
class PokeBattle_Move_04E < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if attacker.isGenderless? || opponent.isGenderless? || attacker.gender == opponent.gender
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if opponent.ability == :OBLIVIOUS && !opponent.moldbroken
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    return opponent.pbCanReduceStatStage?(PBStats::SPATK, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbChangeStats(PBStats::SPATK, -2, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Decreases the target's Special Defense by 2 stages. (Fake Tears / Seed Flare
# Acid Spray / Metal Sound / Uproot / Lumina Crash)
################################################################################
class PokeBattle_Move_04F < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return opponent.pbCanReduceStatStage?(PBStats::SPDEF, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return true if @basedamage > 0
    amount = -2
    amount = -3 if @move == :METALSOUND && ([:FACTORY, :SHORTCIRCUIT].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::CONCERT))
    amount = -3 if @move == :FAKETEARS && @battle.FE == :BACKALLEY
    opponent.pbChangeStats(PBStats::SPDEF, amount, attacker, self, abilitycheck: :skip)
  end

  def pbAdditionalEffect(attacker, opponent)
    opponent.pbChangeStats(PBStats::SPDEF, -2, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Resets all target's stat stages to 0. (Clear Smog)
################################################################################
class PokeBattle_Move_050 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if !opponent.damagestate.substitute
      opponent.stages[PBStats::ATTACK]   = 0
      opponent.stages[PBStats::DEFENSE]  = 0
      opponent.stages[PBStats::SPEED]    = 0
      opponent.stages[PBStats::SPATK]    = 0
      opponent.stages[PBStats::SPDEF]    = 0
      opponent.stages[PBStats::ACCURACY] = 0
      opponent.stages[PBStats::EVASION]  = 0
      @battle.pbDisplay(_INTL("{1}'s stat changes were removed!", opponent.pbThis))
    end
  end
end

################################################################################
# Resets all stat stages for all battlers to 0. (Haze)
################################################################################
class PokeBattle_Move_051 < PokeBattle_Move
  # Known fact, Haze acts like a field-targeting move (and not an :AllBattlers move)
  def pbEffect(attacker, alltargets, hitnum = 0)
    for i in 0...4
      @battle.battlers[i].stages[PBStats::ATTACK]   = 0
      @battle.battlers[i].stages[PBStats::DEFENSE]  = 0
      @battle.battlers[i].stages[PBStats::SPEED]    = 0
      @battle.battlers[i].stages[PBStats::SPATK]    = 0
      @battle.battlers[i].stages[PBStats::SPDEF]    = 0
      @battle.battlers[i].stages[PBStats::ACCURACY] = 0
      @battle.battlers[i].stages[PBStats::EVASION]  = 0
    end
    @battle.pbDisplay(_INTL("All stat changes were eliminated!"))
  end
end

################################################################################
# User and target swap their Attack and Special Attack stat stages. (Power Swap)
################################################################################
class PokeBattle_Move_052 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    astage = attacker.stages
    ostage = opponent.stages
    astage[PBStats::ATTACK], ostage[PBStats::ATTACK] = ostage[PBStats::ATTACK], astage[PBStats::ATTACK]
    astage[PBStats::SPATK], ostage[PBStats::SPATK] = ostage[PBStats::SPATK], astage[PBStats::SPATK]
    @battle.pbDisplay(_INTL("{1} switched all changes to its {2} and {3} with its target!", attacker.pbThis, getStatName(PBStats::ATTACK), getStatName(PBStats::SPATK)))
  end
end

################################################################################
# User and target swap their Defense and Special Defense stat stages. (Guard Swap)
################################################################################
class PokeBattle_Move_053 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    astage = attacker.stages
    ostage = opponent.stages
    astage[PBStats::DEFENSE], ostage[PBStats::DEFENSE] = ostage[PBStats::DEFENSE], astage[PBStats::DEFENSE]
    astage[PBStats::SPDEF], ostage[PBStats::SPDEF] = ostage[PBStats::SPDEF], astage[PBStats::SPDEF]
    @battle.pbDisplay(_INTL("{1} switched all changes to its {2} and {3} with its target!", attacker.pbThis, getStatName(PBStats::DEFENSE), getStatName(PBStats::SPDEF)))
  end
end

################################################################################
# User and target swap all their stat stages. (Heart Swap)
################################################################################
class PokeBattle_Move_054 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    for i in PBStats::All
      attacker.stages[i], opponent.stages[i] = opponent.stages[i], attacker.stages[i]
    end
    @battle.pbDisplay(_INTL("{1} switched stat changes with its target!", attacker.pbThis))

    if @battle.FE == :NEWWORLD && !blockedBySubstitute?(attacker, opponent)
      olda = attacker.hp
      oldo = opponent.hp
      avhp = ((attacker.hp + opponent.hp) / 2.0).floor
      attacker.hp = [avhp, attacker.totalhp].min
      opponent.hp = [avhp, opponent.totalhp].min
      @battle.scene.pbHPChanged([attacker, opponent], [olda, oldo])
      @battle.pbDisplay(_INTL("The battlers shared their pain!"))
    end
  end
end

################################################################################
# User copies the target's stat stages. (Psych Up)
################################################################################
class PokeBattle_Move_055 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    for i in PBStats::All
      attacker.stages[i] = opponent.stages[i]
    end
    attacker.effects[:FocusEnergy] = opponent.effects[:FocusEnergy]
    @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!", attacker.pbThis, opponent.pbThis(true)))
    if @battle.FE == :ASHENBEACH
      attacker.pbCureStatus
    end
    if @battle.FE == :PSYTERRAIN
      attacker.pbChangeStats(PBStats::SPATK, 2, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# For 5 rounds, user's and ally's stat stages cannot be lowered by foes. (Mist)
################################################################################
class PokeBattle_Move_056 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if attacker.pbOwnSide.effects[:Mist] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:Mist] = 5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team became shrouded in mist!"))
    else
      @battle.pbDisplay(_INTL("The opposing team became shrouded in mist!"))
    end

    if !attacker.hasWorkingItem(:EVERSTONE) && @battle.canChangeFE?(:MISTY)
      duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 6 : 3
      @battle.setField(:MISTY, duration, nil)
    end
  end
end

################################################################################
# Swaps the user's Attack and Defense. (Power Trick, Power Shift)
################################################################################
class PokeBattle_Move_057 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.attack, attacker.defense = attacker.defense, attacker.attack
    if attacker.effects[:Illusion]
      attacker.effects[:Illusion].attack, attacker.effects[:Illusion].defense = attacker.effects[:Illusion].defense, attacker.effects[:Illusion].attack
    end
    attacker.effects[:PowerTrick] = !attacker.effects[:PowerTrick]
    @battle.pbDisplay(_INTL("{1} switched its {2} and {3}!", attacker.pbThis, getStatName(PBStats::ATTACK), getStatName(PBStats::DEFENSE)))
  end
end

################################################################################
# Averages the user's and target's Attack and Special Attack (separately). (Power Split)
################################################################################
class PokeBattle_Move_058 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    avatk = ((attacker.attack + opponent.attack) / 2.0).floor
    avspatk = ((attacker.spatk + opponent.spatk) / 2.0).floor
    attacker.attack = avatk
    opponent.attack = avatk
    attacker.spatk = avspatk
    opponent.spatk = avspatk
    # User and target of Power Split both know the stat values they end up with
    # as such the AI wouldn't be fooled by Illusion in this regard
    if attacker.effects[:Illusion]
      attacker.effects[:Illusion].attack = avatk
      attacker.effects[:Illusion].spatk = avspatk
    end
    if opponent.effects[:Illusion]
      opponent.effects[:Illusion].attack = avatk
      opponent.effects[:Illusion].spatk = avspatk
    end
    @battle.pbDisplay(_INTL("{1} shared its power with {2}!", attacker.pbThis, opponent.pbThis(true)))
  end
end

################################################################################
# Averages the user's and target's Defense and Special Defense (separately). (Guard Split)
################################################################################
class PokeBattle_Move_059 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    avdef = ((attacker.defense + opponent.defense) / 2.0).floor
    avspdef = ((attacker.spdef + opponent.spdef) / 2.0).floor
    attacker.defense = avdef
    opponent.defense = avdef
    attacker.spdef = avspdef
    opponent.spdef = avspdef
    # User and target of Guard Split both know the stat values they end up with
    # as such the AI wouldn't be fooled by Illusion in this regard
    if attacker.effects[:Illusion]
      attacker.effects[:Illusion].defense = avdef
      attacker.effects[:Illusion].spdef = avspdef
    end
    if opponent.effects[:Illusion]
      opponent.effects[:Illusion].defense = avdef
      opponent.effects[:Illusion].spdef = avspdef
    end
    @battle.pbDisplay(_INTL("{1} shared its guard with {2}!", attacker.pbThis, opponent.pbThis(true)))
  end
end

################################################################################
# Averages the user's and target's current HP. (Pain Split)
################################################################################
class PokeBattle_Move_05A < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    olda = attacker.hp
    oldo = opponent.hp
    avhp = ((attacker.hp + opponent.hp) / 2.0).floor
    attacker.hp = [avhp, attacker.totalhp].min
    opponent.hp = [avhp, opponent.totalhp].min
    @battle.scene.pbHPChanged([attacker, opponent], [olda, oldo])
    @battle.pbDisplay(_INTL("The battlers shared their pain!"))
  end
end

################################################################################
# For 4 more rounds, doubles the Speed of all battlers on the user's side. (Tailwind)
################################################################################
class PokeBattle_Move_05B < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.pbOwnSide.effects[:Tailwind] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = 4
    duration = 6 if [:MOUNTAIN, :SNOWYMOUNTAIN, :VOLCANICTOP, :CLOUDS].include?(@battle.FE)
    duration = 8 if @battle.FE == :SKY
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("The tailwind blew from behind your team!"))
    else
      @battle.pbDisplay(_INTL("The tailwind blew from behind the opposing team!"))
    end
    @battle.pbSetTailwind(duration, attacker.pbOwnSide)
  end
end

################################################################################
# This move turns into the last move used by the target, until user switches out. (Mimic)
################################################################################
class PokeBattle_Move_05C < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    lastMove = opponent.lastMoveUsed
    if attacker.effects[:Transform] ||
       !lastMove.is_a?(Symbol) ||
       PBStuff::BLACKLISTS[:MIMIC].include?(lastMove) ||
       $cache.moves[lastMove].type == :SHADOW
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    for i in attacker.moves
      if i.move == lastMove
        @battle.pbDisplay(_INTL("But it failed!")) if showMessage
        return false
      end
    end
    for i in 0...attacker.moves.length
      if attacker.moves[i].move == @move
        return true
      end
    end
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    for i in 0...attacker.moves.length
      if attacker.moves[i].move == @move
        @battle.pbLearnMoveBattler(attacker, opponent.lastMoveUsed, i)
        movename = getMoveName(opponent.lastMoveUsed)
        @battle.pbDisplay(_INTL("{1} learned {2}!", attacker.pbThis, movename))
        return
      end
    end
  end
end

################################################################################
# This move permanently turns into the last move used by the target. (Sketch)
################################################################################
class PokeBattle_Move_05D < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.effects[:Transform] ||
       !opponent.lastRegularMoveUsed.is_a?(Symbol) ||
       PBStuff::BLACKLISTS[:SKETCH].include?(opponent.lastRegularMoveUsed) ||
       attacker.moves.any? {|i| i.move == opponent.lastRegularMoveUsed} ||
       attacker.moves.none? {|i| i.move == @move}
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    for i in 0...attacker.moves.length
      if attacker.moves[i].move == @move
        @battle.pbLearnMovePokemon(attacker.pokemon, opponent.lastRegularMoveUsed, i)
        movename = getMoveName(opponent.lastRegularMoveUsed)
        @battle.pbDisplay(_INTL("{1} sketched {2}!", attacker.pbThis, movename))
        return
      end
    end
  end
end

################################################################################
# Changes user's type to that of a random move of the user, ignoring this one. (Conversion)
################################################################################
class PokeBattle_Move_05E < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !attacker.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end

    foundmove = attacker.moves.find { |move| move.move != @move && ![:QMARKS, :SHADOW, :STELLAR].include?(move.type) }
    if !foundmove
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end

    @foundtype = foundmove.type
    if attacker.hasType?(@foundtype)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end

    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    newtype = @foundtype
    attacker.changeType(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", attacker.pbThis, getTypeName(newtype)))

    if !attacker.hasWorkingItem(:EVERSTONE) && @battle.canChangeFE? && !(@battle.FE == :GLITCH && @battle.field.duration <= 0)
      duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 8 : 5
      @battle.setConversion(@move, duration)
    end
  end
end

################################################################################
# Changes user's type to a random one that resists the last attack used by target. (Conversion2)
################################################################################
class PokeBattle_Move_05F < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !attacker.canChangeType? || !opponent.lastMoveUsed.is_a?(Symbol)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    lastmove = opponent.moves.find { |move| move.move == opponent.lastMoveUsed }
    if !lastmove
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    atype = lastmove.pbType(attacker)
    types = PBTypes.typeResists(atype)
    types.delete_if { |type| type == attacker.type1 && attacker.type2.nil? }
    if types.length == 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    atype = nil
    for i in opponent.moves
      if i.move == opponent.lastMoveUsed
        atype = i.pbType(attacker)
        break
      end
    end
    types = PBTypes.typeResists(atype)
    types.delete_if { |type| type == attacker.type1 && attacker.type2.nil? }
    newtype = types[@battle.pbRandom(types.length)]
    attacker.changeType(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", attacker.pbThis, getTypeName(newtype)))

    if !attacker.hasWorkingItem(:EVERSTONE) && @battle.canChangeFE? && !(@battle.FE == :GLITCH && @battle.field.duration <= 0)
      duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 8 : 5
      @battle.setConversion(@move, duration)
    end
  end
end

################################################################################
# Changes user's type depending on the environment. (Camouflage)
################################################################################
class PokeBattle_Move_060 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !attacker.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    mtype = @battle.getMimicryType
    if mtype.nil? || attacker.types(excludeReflector: true) == [mtype]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    mtype = @battle.getMimicryType(update_roll: true)
    attacker.changeType(mtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", attacker.pbThis, getTypeName(mtype)))
  end
end

################################################################################
# Target becomes Water type. (Soak)
################################################################################
class PokeBattle_Move_061 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if !opponent.canChangeType? || opponent.types(excludeReflector: true) == [:WATER]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.changeType(:WATER)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", opponent.pbThis, getTypeName(:WATER)))
  end
end

################################################################################
# User copies target's types. (Reflect Type)
################################################################################
class PokeBattle_Move_062 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !attacker.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    elsif attacker.ability == :REFLECTOR
      return attacker.getReflectorTypes(opponent, false)
    elsif [attacker.type1, attacker.type2] == [opponent.type1, opponent.type2] && attacker.effects[:TemporaryType] == opponent.effects[:TemporaryType]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if attacker.ability == :REFLECTOR
      attacker.getReflectorTypes(opponent)
      @battle.pbAbilityBoxAndDisplay(attacker, _INTL("{1} gained {2}'s types!", attacker.pbThis, opponent.pbThis(true)))
    else
      attacker.type1 = opponent.type1
      attacker.type2 = opponent.type2
      attacker.effects[:TemporaryType] = opponent.effects[:TemporaryType]
      @battle.pbDisplay(_INTL("{1} became the same type as {2}!", attacker.pbThis, opponent.pbThis(true)))
    end
  end
end

################################################################################
# Target's ability becomes Simple. (Simple Beam)
################################################################################
class PokeBattle_Move_063 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if (PBStuff::FIXEDABILITIES + [:TRUANT, :SIMPLE] - [:COMMANDER, :ORICHALCUMPULSE, :HADRONENGINE]).include?(opponent.ability)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    elsif opponent.hasWorkingItem(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!", opponent.pbThis, getItemName(opponent.item))) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    message = _INTL("{1} acquired {2}!", opponent.pbThis, getAbilityName(:SIMPLE))
    opponent.changeAbilityWithEffects(:SIMPLE, message: message)
  end
end

################################################################################
# Target's ability becomes Insomnia. (Worry Seed)
################################################################################
class PokeBattle_Move_064 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    elsif [:TRUANT, :INSOMNIA].include?(opponent.ability)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if PBStuff::FIXEDABILITIES.include?(opponent.ability)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    elsif opponent.hasWorkingItem(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!", opponent.pbThis, getItemName(opponent.item))) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    message = _INTL("{1} acquired {2}!", opponent.pbThis, getAbilityName(:INSOMNIA))
    opponent.changeAbilityWithEffects(:INSOMNIA, message: message)
    if Rejuv && @battle.FE == :GRASSY
      opponent.pbChangeStats(PBStats::ATTACK, -1, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# User copies target's ability. (Role Play)
################################################################################
class PokeBattle_Move_065 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    attability = attacker.ability || attacker.backupability
    oppability = opponent.ability || opponent.backupability
    if attability == oppability || PBStuff::ABILITYBLACKLIST.include?(oppability) || PBStuff::FIXEDABILITIES.include?(attability) || oppability.nil?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    elsif attacker.hasWorkingItem(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!", attacker.pbThis, getItemName(attacker.item))) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    oppability = opponent.ability || opponent.backupability
    message = _INTL("{1} copied {2}'s {3} Ability!", attacker.pbThis, opponent.pbThis(true), getAbilityName(oppability))
    attacker.changeAbilityWithEffects(oppability, message: message)
  end
end

################################################################################
# Target copies user's ability. (Entrainment)
################################################################################
class PokeBattle_Move_066 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    attability = attacker.ability || attacker.backupability
    oppability = opponent.ability || opponent.backupability
    if attability == oppability || (PBStuff::FIXEDABILITIES + [:TRUANT]).include?(opponent.ability) || (PBStuff::ABILITYBLACKLIST - [:WONDERGUARD]).include?(attacker.ability) || attability.nil?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    elsif opponent.hasWorkingItem(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!", opponent.pbThis, getItemName(opponent.item))) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    attability = attacker.ability || attacker.backupability
    message = _INTL("{1} acquired {2}!", opponent.pbThis, getAbilityName(attability))
    opponent.changeAbilityWithEffects(attability, message: message)
  end
end

################################################################################
# User and target swap abilities. (Skill Swap)
################################################################################
class PokeBattle_Move_067 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    attability = attacker.ability || attacker.backupability
    oppability = opponent.ability || opponent.backupability
    if PBStuff::ABILITYBLACKLIST.include?(attability) || PBStuff::ABILITYBLACKLIST.include?(oppability) || attability.nil? || oppability.nil?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    elsif attacker.hasWorkingItem(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!", attacker.pbThis, getItemName(attacker.item))) if showMessage
      return false
    elsif opponent.hasWorkingItem(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!", opponent.pbThis, getItemName(opponent.item))) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    attacker.swapAbilities(opponent)
  end
end

################################################################################
# Target's ability is negated. (Gastro Acid)
################################################################################
class PokeBattle_Move_068 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.hasWorkingItem(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!", opponent.pbThis, getItemName(opponent.item))) if showMessage
      return false
    elsif PBStuff::FIXEDABILITIES.include?(opponent.ability)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    elsif opponent.effects[:GastroAcid]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    message = _INTL("{1}'s Ability was suppressed!", opponent.pbThis)
    opponent.changeAbilityWithEffects(:suppress, message: message)
    opponent.effects[:GastroAcid] = true
  end
end

################################################################################
# User transforms into the target. (Transform)
################################################################################
class PokeBattle_Move_069 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !attacker.pbCanTransform?(opponent, self)
      if showMessage
        @battle.pbDisplay(_INTL("But it failed!"))
        @battle.ai.discloseIllusion(opponent, :noTransform) if opponent.effects[:Illusion]
      end
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    attacker.pbTransform(opponent)
    attacker.pbAbilitiesOnSwitchIn
  end
end

################################################################################
# Inflicts a fixed 20HP damage. (Sonic Boom)
################################################################################
class PokeBattle_Move_06A < PokeBattle_Move
  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    if @battle.FE == :RAINBOW
      feedbackMessages[opponent.index].push(:RainbowBoom)
      dmg = 140
    else
      dmg = 20
    end
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end
end

################################################################################
# Inflicts a fixed 40HP damage. (Dragon Rage)
################################################################################
class PokeBattle_Move_06B < PokeBattle_Move
  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    if [:DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE)
      feedbackMessages[opponent.index].push(:DimensionalRage)
      dmg = 140
    else
      dmg = 40
    end
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end
end

################################################################################
# Halves the target's current HP. (Super Fang / Nature's Madness / Ruination)
################################################################################
class PokeBattle_Move_06C < PokeBattle_Move
  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    if @move == :NATURESMADNESS && [:GRASSY, :FOREST].include?(@battle.FE)
      dmg = (opponent.hp * 0.75).floor
    elsif @move == :NATURESMADNESS && @battle.FE == :HOLY
      dmg = (opponent.hp * 0.66).floor
    elsif [:RUINATION, :NATURESMADNESS].include?(@move) && @battle.FE == :NEWWORLD
      dmg = (opponent.totalhp * 0.5).floor
    else
      dmg = (opponent.hp / 2.0).floor
    end
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end


  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if @move == :RUINATION && [:DEUXFINALIS, :DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE)
      if opponent.pbCanPetrify?(attacker, self)
        opponent.pbPetrify(attacker)
      end
    end
  end
end

################################################################################
# Inflicts damage equal to the user's level. (Seismic Toss / Night Shade)
################################################################################
class PokeBattle_Move_06D < PokeBattle_Move
  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    if (@move == :NIGHTSHADE && [:HAUNTED, :BEWITCHED].include?(@battle.FE)) || (@move == :SEISMICTOSS && @battle.FE == :DEEPEARTH)
      if @move == :SEISMICTOSS && @battle.FE == :DEEPEARTH
        feedbackMessages[opponent.index].push(:DeepEarthSeismicToss)
      end
      if @move == :NIGHTSHADE && @battle.FE == :HAUNTED
        feedbackMessages[opponent.index].push(:HauntedNightSHade)
      end
      if @move == :NIGHTSHADE && @battle.FE == :BEWITCHED
        feedbackMessages[opponent.index].push(:BewitchedNightShade)
      end
      dmg = (attacker.level * 1.5).floor
    else
      dmg = attacker.level
    end
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end
end

################################################################################
# Inflicts damage to bring the target's HP down to equal the user's HP. (Endeavor)
################################################################################
class PokeBattle_Move_06E < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if attacker.hp >= opponent.hp
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    dmg = opponent.hp - attacker.hp
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end
end

################################################################################
# Inflicts damage between 0.5 and 1.5 times the user's level. (Psywave)
################################################################################
class PokeBattle_Move_06F < PokeBattle_Move
  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    if @battle.FE == :DEEPEARTH
      feedbackMessages[opponent.index].push(:DeepEarthPsywave)
      dmg = (attacker.level * (@battle.pbRandom(101) + 100) / 100.0).floor
    else
      dmg = (attacker.level * (@battle.pbRandom(101) + 50) / 100.0).floor
    end
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end
end

################################################################################
# OHKO.  Accuracy increases by difference between levels of user and target. (Fissure/
# Sheer Cold / Guillotine / Horn Drill)
################################################################################
class PokeBattle_Move_070 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.level > attacker.level
      @battle.pbDisplay(_INTL("{1} is unaffected!", opponent.pbThis)) if showMessage
      return false
    end
    if (@move == :SHEERCOLD && opponent.hasType?(:ICE)) || (@battle.FE == :CHESS && opponent.piece == :PAWN)
      @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    if (opponent.ability == :STURDY || (@battle.FE == :COLOSSEUM && opponent.ability == :STALWART)) && !opponent.moldbroken
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    return true
  end

  def pbBaseAccuracy(baseacc, attacker, opponent)
    baseacc = 20 if @move == :SHEERCOLD && !attacker.hasType?(:ICE)
    baseacc += attacker.level - opponent.level
    return super
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    dmg = blockedBySubstitute?(attacker, opponent) ? opponent.effects[:Substitute] : opponent.hp
    # applyTradePowerForAcc not applied intentionally, in order to preserve the identity of OHKO moves even with the steadyhand password
    return dmg
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if opponent.hp <= 0
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
  end
end

################################################################################
# Counters a physical move used against the user this round, with 2x the power. (Counter)
################################################################################
class PokeBattle_Move_071 < PokeBattle_Move
  def pbAddTarget(targets, target, attacker)
    if attacker.effects[:CounterTarget] >= 0 && attacker.pbIsOpposing?(attacker.effects[:CounterTarget]) &&
       !super(targets, @battle.battlers[attacker.effects[:CounterTarget]], attacker)
      attacker.pbRandomTarget(targets, self)
    end
  end

  def pbOnStartUse(attacker, targets)
    if attacker.effects[:Counter] <= 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    dmg = attacker.effects[:Counter] * 2
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end
end

################################################################################
# Counters a specical move used against the user this round, with 2x the power. (Mirror Coat)
################################################################################
class PokeBattle_Move_072 < PokeBattle_Move
  def pbAddTarget(targets, target, attacker)
    if attacker.effects[:MirrorCoatTarget] >= 0 && attacker.pbIsOpposing?(attacker.effects[:MirrorCoatTarget]) &&
       !super(targets, @battle.battlers[attacker.effects[:MirrorCoatTarget]], attacker)
      attacker.pbRandomTarget(targets, self)
    end
  end

  def pbOnStartUse(attacker, targets)
    if attacker.effects[:MirrorCoat] <= 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    dmg = attacker.effects[:MirrorCoat] * 2
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.FE == :MIRROR
      attacker.pbChangeStats([PBStats::EVASION, PBStats::DEFENSE, PBStats::SPDEF], 1, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# Counters the last damaging move used against the user this round, with 1.5x
# the power. (Metal Burst / Comeuppance)
################################################################################
class PokeBattle_Move_073 < PokeBattle_Move
  def pbAddTarget(targets, target, attacker)
    if attacker.lastAttacker >= 0 && attacker.pbIsOpposing?(attacker.lastAttacker) &&
       !super(targets, @battle.battlers[attacker.lastAttacker], attacker)
      attacker.pbRandomTarget(targets, self)
    end
  end

  def pbOnStartUse(attacker, targets)
    if attacker.lastHPLost == 0 || attacker.damagestate.substitute
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    dmg = (attacker.lastHPLost * 1.5).floor
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end
end

################################################################################
# Damages user's partner 1/16 Max HP (Flame Burst)
################################################################################
class PokeBattle_Move_074 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if opponent.pbPartner && !opponent.pbPartner.isFainted?
      opponent.pbPartner.pbReduceHP((opponent.pbPartner.totalhp / 16.0).floor, message: _INTL("The bursting flame hit {1}!", opponent.pbPartner.pbThis(true)))
      opponent.pbPartner.pbFaint if opponent.pbPartner.isFainted?
    end
  end
end

################################################################################
# Power is doubled if the target is using Dive. (Surf)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_075 < PokeBattle_Move
  def pbModifyDamage(damagemult, attacker, opponent)
    damagemult *= 2.0 if $cache.moves[opponent.effects[:TwoTurnAttack]]&.function == 0xCB # Dive
    return damagemult
  end
end

################################################################################
# Power is doubled if the target is using Dig. (Earthquake)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_076 < PokeBattle_Move
  def pbModifyDamage(damagemult, attacker, opponent)
    damagemult *= 2.0 if $cache.moves[opponent.effects[:TwoTurnAttack]]&.function == 0xCA # Dig
    return damagemult
  end
end

################################################################################
# Power is doubled if the target is using Bounce, Fly or Sky Drop. (Gust)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_077 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg * 2 if [0xC9, 0xCC, 0xCE].include?($cache.moves[opponent.effects[:TwoTurnAttack]]&.function) # Fly, Bounce, Sky Drop
    return basedmg
  end
end

################################################################################
# Power is doubled if the target is using Bounce, Fly or Sky Drop.
# May make the target flinch. (Twister)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_078 < PokeBattle_Move
  def canFlinch?
    return true
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg * 2 if [0xC9, 0xCC, 0xCE].include?($cache.moves[opponent.effects[:TwoTurnAttack]]&.function) # Fly, Bounce, Sky Drop
    return basedmg
  end

  def pbAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
      return true
    end
    return false
  end
end

################################################################################
# Power is doubled if Fusion Flare was used this round. (Fusion Bolt)
################################################################################
class PokeBattle_Move_079 < PokeBattle_Move
  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    id = :FUSIONBOLT2 if @battle.lastMoveUsed == :FUSIONFLARE && @battle.fusionMove == :FUSIONFLARE
    super
  end

  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 2.0 if @battle.lastMoveUsed == :FUSIONFLARE && @battle.fusionMove == :FUSIONFLARE
    return damagemult
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.fusionMove = :FUSIONBOLT
  end
end

################################################################################
# Power is doubled if Fusion Bolt was used this round. (Fusion Flare)
################################################################################
class PokeBattle_Move_07A < PokeBattle_Move
  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    id = :FUSIONFLARE2 if @battle.lastMoveUsed == :FUSIONBOLT && @battle.fusionMove == :FUSIONBOLT
    super
  end

  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 2.0 if @battle.lastMoveUsed == :FUSIONBOLT && @battle.fusionMove == :FUSIONBOLT
    return damagemult
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.fusionMove = :FUSIONFLARE
  end
end

################################################################################
# Power is doubled if the target is poisoned. (Venoshock)
################################################################################
class PokeBattle_Move_07B < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 2.0 if [:CORROSIVE, :CORROSIVEMIST, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE) ||
                         (opponent.status == :POISON && !blockedBySubstitute?(attacker, opponent))
    return damagemult
  end
end

################################################################################
# Power is doubled if the target is paralyzed.  Cures the target of paralysis. (Smelling Salts)
################################################################################
class PokeBattle_Move_07C < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    if (opponent.status == :PARALYSIS && !opponent.damagestate.substitute) || [:DEUXFINALIS].include?(@battle.FE)
      return basedmg * 2
    end
    return basedmg
  end

  def pbEffectTargetAfterMove(attacker, opponent, alltargets = nil)
    return if opponent.isFaintedAndNoShields?
    if opponent.status == :PARALYSIS && !opponent.damagestate.substitute
      opponent.pbCureStatus
    end
  end
end

################################################################################
# Power is doubled if the target is asleep.  Wakes the target up. (Wake-up Slap)
################################################################################
class PokeBattle_Move_07D < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    if opponent.isSleeping? && !opponent.damagestate.substitute
      return basedmg * 2
    end

    return basedmg
  end

  def pbEffectTargetAfterMove(attacker, opponent, alltargets = nil)
    return if opponent.isFaintedAndNoShields?
    if opponent.status == :SLEEP && !opponent.damagestate.substitute
      opponent.pbCureStatus
    end
  end
end

################################################################################
# Power is doubled if the user is burned, poisoned or paralyzed. (Facade)
################################################################################
class PokeBattle_Move_07E < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 2.0 if attacker.status == :POISON || attacker.status == :BURN || attacker.status == :PARALYSIS
    return damagemult
  end
end

################################################################################
# Power is doubled if the target has a status problem. (Hex)
################################################################################
class PokeBattle_Move_07F < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    if [:INFERNAL].include?(@battle.FE) ||
       ((!opponent.status.nil? || opponent.isSleeping?) && !blockedBySubstitute?(attacker, opponent))
      return basedmg * 2
    end

    return basedmg
  end
end

################################################################################
# Power is doubled if the target's HP is down to 1/2 or less. (Brine)
################################################################################
class PokeBattle_Move_080 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 2.0 if opponent.hp <= (opponent.totalhp / 2.0).floor || ([:DEUXFINALIS].include?(@battle.FE))
    return damagemult
  end
end

################################################################################
# Power is doubled if the user has lost HP due to the target's move this round.
# (Revenge / Avalanche)
################################################################################
class PokeBattle_Move_081 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg * 2 if attacker.lastHPLost > 0 && !attacker.damagestate.substitute && attacker.lastAttacker == opponent.index

    return basedmg
  end
end

################################################################################
# Power is doubled if the target has already lost HP this round. (Assurance)
################################################################################
class PokeBattle_Move_082 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg * 2 if opponent.lastHPLost > 0

    return basedmg
  end
end

################################################################################
# Power is doubled if the move has already been used this turn. (Round)
################################################################################
class PokeBattle_Move_083 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    if @battle.state.effects[:Round]
      return basedmg * 2
    end

    @battle.state.effects[:Round] = true
    return basedmg
  end
end

################################################################################
# Power is doubled if the target has already moved this round. (Payback)
################################################################################
class PokeBattle_Move_084 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg * 2 if opponent.hasMovedThisRound? && !@battle.switchedOut[opponent.index]

    return basedmg
  end
end

################################################################################
# Power is doubled if a user's teammate fainted last round. (Retaliate)
################################################################################
class PokeBattle_Move_085 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 2.0 if attacker.pbOwnSide.effects[:Retaliate]
    return damagemult
  end
end

################################################################################
# Power is doubled if the user has no held item. (Acrobatics)
################################################################################
class PokeBattle_Move_086 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg * 2 if @battle.FE == :BIGTOP
    return basedmg * 2 if attacker.item.nil?
    return basedmg * 2 if attacker.itemWorks? && $cache.items[attacker.item].checkFlag?(:gem) && $cache.items[attacker.item].checkFlag?(:typeboost) == pbType(attacker)

    return basedmg
  end
end

################################################################################
# Power is doubled in weather.  Type changes depending on the weather. (Weather Ball)
################################################################################
class PokeBattle_Move_087 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    weather = @battle.pbWeather(attacker)
    if @battle.FE == :RAINBOW || [:SANDSTORM, :HAIL, :SNOW].include?(weather) || ([:SUNNYDAY, :RAINDANCE].include?(weather) && !attacker.hasWorkingItem(:UTILITYUMBRELLA)) || (weather == :STRONGWINDS && @battle.FE == :SKY) || (weather == :SHADOWSKY && Rejuv)
      return basedmg * 2
    end

    return basedmg
  end

  def pbType(attacker, type = @type)
    case @battle.pbWeather(attacker)
      when :SUNNYDAY then type = :FIRE unless attacker.hasWorkingItem(:UTILITYUMBRELLA)
      when :RAINDANCE then type = :WATER unless attacker.hasWorkingItem(:UTILITYUMBRELLA)
      when :SANDSTORM then type = :ROCK
      when :HAIL, :SNOW then type = :ICE
      when :STRONGWINDS then type = :FLYING if @battle.FE == :SKY
      when :SHADOWSKY then type = :SHADOW
    end
    return super
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    case pbType(attacker)
      when :WATER then id = :WEATHERBALLRAIN
      when :FIRE then id = :WEATHERBALLSUN
      when :ICE then id = :WEATHERBALLHAIL
      when :ROCK then id = :WEATHERBALLSAND
    end
    super
  end
end

################################################################################
# Power is doubled if a foe tries to switch out. (Pursuit)
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
################################################################################
class PokeBattle_Move_088 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg * 2 if opponent.effects[:Pursuitee]

    return basedmg
  end
end

################################################################################
# Power increases with the user's happiness. (Return)
################################################################################
class PokeBattle_Move_089 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
    return 102 if @battle.FE == :CONCERT4

    return [(attacker.happiness * 2 / 5.0).floor, 1].max
  end
end

################################################################################
# Power decreases with the user's happiness. (Frustration)
################################################################################
class PokeBattle_Move_08A < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [250 - attacker.happiness, 1].max if attacker.crested == :LUVDISC
    return 102 if @battle.FE == :CONCERT4

    return [((255 - attacker.happiness) * 2 / 5.0).floor, 1].max
  end
end

################################################################################
# Power increases with the user's HP. (Eruption / Water Spout / Dragon Energy)
################################################################################
class PokeBattle_Move_08B < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
    return 150 if @battle.FE == :CONCERT4

    return [(150 * attacker.hp.to_f / attacker.totalhp).floor, 1].max
  end
end

################################################################################
# Power increases with the target's HP. (Wring Out / Crush Grip / Hard Press)
################################################################################
class PokeBattle_Move_08C < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC

    max = @move == :HARDPRESS ? 100 : 120
    return max if [:DEEPEARTH, :CONCERT4].include?(@battle.FE)

    return [(max * opponent.hp.to_f / opponent.totalhp).floor, 1].max
  end
end

################################################################################
# Power increases the quicker the target is than the user. (Gyro Ball)
################################################################################
class PokeBattle_Move_08D < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
    return 150 if [:DEEPEARTH, :CONCERT4].include?(@battle.FE)

    return [[(25.0 * opponent.pbSpeed / attacker.pbSpeed).floor, 150].min, 1].max
  end
end

################################################################################
# Power increases with the user's positive stat changes (ignores negative ones).
# (Stored Power / Power Trip)
################################################################################
class PokeBattle_Move_08E < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    mult = 0
    for i in PBStats::All
      mult += attacker.stages[i] if attacker.stages[i] > 0
    end
    bp = 20
    bp = 40 if @battle.FE == :FROZENDIMENSION && @move == :POWERTRIP
    return [attacker.happiness, 250].min + (bp * mult) if attacker.crested == :LUVDISC

    return bp * (mult + 1)
  end
end

################################################################################
# Power increases with the target's positive stat changes (ignores negative ones).
# (Punishment)
################################################################################
class PokeBattle_Move_08F < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    mult = 0
    for i in 1...7
      mult += opponent.stages[i] if opponent.stages[i] > 0
    end
    return [[attacker.happiness, 250].min + (20 * mult), 500].min if attacker.crested == :LUVDISC

    return [20 * (mult + 3), 200].min
  end
end

################################################################################
# Power and type depends on the user's IVs. (Hidden Power)
################################################################################
class PokeBattle_Move_090 < PokeBattle_Move
  def pbType(attacker, type = @type)
    type = pbHiddenPower(attacker.pokemon)
    return super
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    movetype = pbType(attacker)
    animmovename = (@move.to_s + movetype.to_s[0..2]).to_sym
    id = animmovename if $cache.moves[animmovename]
    super
  end
end

def pbHiddenPower(user)
  return :NORMAL if user == nil
  return user.hptype if user.hptype != nil

  types = []
  for i in $cache.types.keys
    types.push(i) if ![:NORMAL, :QMARKS, :SHADOW, :STELLAR].include?(i)
  end
  selected_index = user.personalID % types.length
  user.hptype = types[selected_index]
  return user.hptype
end

################################################################################
# Power doubles for each consecutive use. (Fury Cutter)
################################################################################
class PokeBattle_Move_091 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    basedmg = basedmg << attacker.effects[:FuryCutter] # can be 0 to 2
    return basedmg
  end
end

################################################################################
# Power doubles for each consecutive use. (Echoed Voice)
################################################################################
class PokeBattle_Move_092 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    basedmg *= @battle.echoedVoice + 1 # can be 0 to 4
    return basedmg
  end
end

################################################################################
# User rages until the start of a round in which they don't use this move. (Rage)
# Handled in Battler class: Ups rager's Attack by 1 stage each time it loses HP due to a move.
################################################################################
class PokeBattle_Move_093 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC

    if [:DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE)
      basedmg = 60
    end
    return basedmg
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if [:DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE)
      attacker.pbChangeStats(PBStats::ATTACK, 1, attacker, self)
    else
      attacker.effects[:Rage] = true
    end
  end
end

################################################################################
# Randomly damages or heals the target. (Present)
################################################################################
class PokeBattle_Move_094 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    presents = [
      0, 0,
      40, 40, 40, 40,
      80, 80, 80,
      120,
    ]
    @calcbasedmg = @battle.sample(presents)
    @calcbasedmg = [attacker.happiness, 250].min if @calcbasedmg > 0 && attacker.crested == :LUVDISC
    return true
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if @calcbasedmg == 0
    return super
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return @calcbasedmg
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @calcbasedmg != 0

    if opponent.effects[:HealBlock] > 0 || (opponent.status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, opponent).none? && opponent.crested != :SUICUNE)
      @battle.pbDisplay(_INTL("{1} was prevented from healing!", opponent.pbThis))
      return
    end
    if opponent.hp == opponent.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", opponent.pbThis))
      return
    end
    opponent.pbRecoverHP((opponent.totalhp / 4.0).floor, true, message: _INTL("{1} had its HP restored.", opponent.pbThis))
  end
end

################################################################################
# Power is chosen at random.  Power is doubled if the target is using Dig. (Magnitude)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_095 < PokeBattle_Move
  @calcbasedmg = 0

  def pbOnStartUse(attacker, targets)
    basedmg = [10, 30, 50, 70, 90, 110, 150]
    magnitudes = [
      4,
      5, 5,
      6, 6, 6, 6,
      7, 7, 7, 7, 7, 7,
      8, 8, 8, 8,
      9, 9,
      10
    ]
    magni = magnitudes[@battle.pbRandom(magnitudes.length)]
    magni = magnitudes[0] if @battle.FE == :CONCERT1
    magni = magnitudes[19] if @battle.FE == :CONCERT4
    @calcbasedmg = basedmg[magni - 4]
    if attacker.crested == :LUVDISC
      @calcbasedmg = [attacker.happiness, 250].min
      magni = 11
    end
    @battle.pbDisplay(_INTL("Magnitude {1}!", magni))
    return true
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return @calcbasedmg
  end

  def pbModifyDamage(damagemult, attacker, opponent)
    damagemult *= 2.0 if $cache.moves[opponent.effects[:TwoTurnAttack]]&.function == 0xCA # Dig
    return damagemult
  end
end

################################################################################
# Power and type depend on the user's held berry.  Destroys the berry. (Natural Gift)
################################################################################
class PokeBattle_Move_096 < PokeBattle_Move
  def initialize(battle, move, user, zbase = nil)
    super
    @berry = 0
  end

  def pbOnStartUse(attacker, targets)
    if attacker.item.nil? || !pbIsBerry?(attacker.item) || !attacker.itemWorks?
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    @berry = attacker.item
    return true
  end

  def pbEffectAfterMove(attacker, alltargets, hitflags)
    # No return conditions because berry should be removed even if move misses, target protects, etc
    attacker.pbDisposeItem(burp: false, duringattack: true)
    @berry = 0
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
    return 100 if @battle.FE == :CONCERT4
    berry = @berry != 0 ? @berry : attacker.item
    return pbNaturalGiftDamage(berry)
  end

  def pbType(attacker, type = @type)
    berry = @berry != 0 ? @berry : attacker.item
    type = pbNaturalGiftType(berry)
    return super
  end
end

################################################################################
# Power increases the less PP this move has. (Trump Card)
################################################################################
class PokeBattle_Move_097 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC

    dmgs = [200, 80, 60, 50, 40]
    ppleft = [@pp, 4].min # PP is reduced before the move is used
    basedmg = dmgs[ppleft]
    basedmg = 200 if @battle.FE == :CONCERT4
    return basedmg
  end
end

################################################################################
# Power increases the less HP the user has. (Flail / Reversal)
################################################################################
class PokeBattle_Move_098 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC

    n = ((48 * attacker.hp.to_f) / attacker.totalhp).floor
    ret = 20
    ret = 40 if n < 33
    ret = 80 if n < 17
    ret = 100 if n < 10
    ret = 150 if n < 5
    ret = 200 if n < 2 || @battle.FE == :CONCERT4
    return ret
  end
end

################################################################################
# Power increases the quicker the user is than the target. (Electro Ball)
################################################################################
class PokeBattle_Move_099 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC

    n = (attacker.pbSpeed.to_f / opponent.pbSpeed).floor
    ret = 40
    ret = 60 if n >= 1
    ret = 80 if n >= 2
    ret = 120 if n >= 3
    ret = 150 if n >= 4 || @battle.FE == :CONCERT4
    return ret
  end
end

################################################################################
# Power increases the heavier the target is. (Low Kick / Grass Knot)
################################################################################
class PokeBattle_Move_09A < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
    return 120 if @battle.FE == :CONCERT4

    weight = opponent.weight
    return 120 if weight >= 2000
    return 100 if weight >= 1000
    return 80 if weight >= 500
    return 60 if weight >= 250
    return 40 if weight >= 100
    return 20
  end
end

################################################################################
# Power increases the heavier the user is than the target. (Heavy Slam / Heat Crash)
################################################################################
class PokeBattle_Move_09B < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
    return 120 if @battle.FE == :CONCERT4

    n = attacker.weight / opponent.weight # uses floor division
    n *= 2 if @battle.FE == :DEEPEARTH # indirectly doubles attacker's weight
    return 120 if n >= 5
    return 100 if n >= 4
    return 80 if n >= 3
    return 60 if n >= 2
    return 40
  end
end

################################################################################
# Powers up the ally's attack this round by 1.5. (Helping Hand)
################################################################################
class PokeBattle_Move_09C < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.isFainted? ||
       opponent.acted?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:HelpingHand] += 1
    @battle.pbDisplay(_INTL("{1} is ready to help {2}!", attacker.pbThis, opponent.pbThis(true)))
  end
end

################################################################################
# Weakens Electric attacks. (Mud Sport)
################################################################################
class PokeBattle_Move_09D < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if @battle.state.effects[:MudSport] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.state.effects[:MudSport] = 5
    @battle.pbDisplay(_INTL("Electricity's power was weakened!"))
    if Rejuv && @battle.FE == :ELECTERRAIN
      message = _INTL("The hyper-charged terrain shorted out!")
      @battle.setField(:INDOOR, 5, message, ignoreOverlays: true) # temporary field transition, never should be an overlay, failsafe implementation
      @battle.field.duration_condition = proc { |battle| battle.state.effects[:MudSport] != 0 }
    end
  end
end

################################################################################
# Weakens Fire attacks. (Water Sport)
################################################################################
class PokeBattle_Move_09E < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if @battle.state.effects[:WaterSport] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.state.effects[:WaterSport] = 5
    @battle.pbDisplay(_INTL("Fire's power was weakened!"))
  end
end

################################################################################
# Type depends on the user's held item. (Judgment / Techno Blast / Multi-Attack / Multipulse)
################################################################################
class PokeBattle_Move_09F < PokeBattle_Move
  def pbType(attacker, type = @type)
    type = pbJudgmentLikeMoveType(@move, attacker.species, attacker.form, attacker.itemWorks? ? attacker.item : nil, type)
    return super
  end

  def pbOnStartUse(attacker, targets)
    if (attacker.crested == :SILVALLY && @move == :MULTIATTACK) || (@battle.FE == :DEUXFINALIS)
      moldBrokenArray = [0, 1, 2, 3].map { |index| @battle.battlers[index].moldbroken }
      @category = @battle.FE == :DEUXFINALIS ? self.smartDamageCategory(attacker, targets[0], moldBrokenArray: moldBrokenArray) : self.smartDamageCategory(attacker, nil, moldBrokenArray: moldBrokenArray)
    end
    return true
  end


  # smartdamage category overrule glitch only on silvally + multiattack, otherwise glitch is handled the same as the pbIsPhysical? and pbIsSpecial? methods
  def pbIsPhysical?(attacker, type = @type)
    return !PBTypes.isSpecialType?(type) && @category != :status if @battle.FE == :GLITCH && !(attacker.crested == :SILVALLY && @move == :MULTIATTACK)

    return @category == :physical
  end

  def pbIsSpecial?(attacker, type = @type)
    return PBTypes.isSpecialType?(type) && @category != :status if @battle.FE == :GLITCH && !(attacker.crested == :SILVALLY && @move == :MULTIATTACK)

    return @category == :special
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    unless @move == :MULTIPULSE
      movetype = pbType(attacker)
      movetype = :GLITCH if movetype == :QMARKS && @move == :MULTIATTACK
      animmovename = (@move.to_s + movetype.to_s).to_sym
      id = animmovename if $cache.moves[animmovename]
    end
    super
  end
end

################################################################################
# This attack is always a critical hit, if successful. (Storm Throw / Frost Breath / Wicked Blow / Flower Trick)
################################################################################
class PokeBattle_Move_0A0 < PokeBattle_Move
  # Handled in superclass, do not edit!
end

################################################################################
# For 5 rounds, foes' attacks cannot become critical hits. (Lucky Chant)
################################################################################
class PokeBattle_Move_0A1 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.pbOwnSide.effects[:LuckyChant] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:LuckyChant] = 5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("{1} shielded your team from critical hits!", @name))
    else
      @battle.pbDisplay(_INTL("{1} shielded the opposing team from critical hits!", @name))
    end
    if @battle.FE == :DEUXFINALIS
      attacker.pbOwnSide.effects[:Mist] = 5
      @battle.pbDisplay(_INTL("{1}'s team became shrouded in mist!", @name))
    end
  end
end

################################################################################
# For 5 rounds, lowers power of physical attacks against the user's side. (Reflect)
################################################################################
class PokeBattle_Move_0A2 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.pbOwnSide.effects[:Reflect] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:Reflect] = 5
    attacker.pbOwnSide.effects[:Reflect] = 8 if attacker.hasWorkingItem(:LIGHTCLAY)
    attacker.pbOwnSide.effects[:Reflect] = 8 if [:MIRROR, :DANCEFLOOR].include?(@battle.FE)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("{1} made your team stronger against physical moves!", @name))
    else
      @battle.pbDisplay(_INTL("{1} made the opposing team stronger against physical moves!", @name))
    end
    if @battle.FE == :MIRROR
      attacker.pbChangeStats(PBStats::EVASION, 1, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# For 5 rounds, lowers power of special attacks against the user's side. (Light Screen)
################################################################################
class PokeBattle_Move_0A3 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.pbOwnSide.effects[:LightScreen] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:LightScreen] = 5
    attacker.pbOwnSide.effects[:LightScreen] = 8 if attacker.hasWorkingItem(:LIGHTCLAY)
    attacker.pbOwnSide.effects[:LightScreen] = 8 if [:MIRROR, :DANCEFLOOR].include?(@battle.FE)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("{1} made your team stronger against special moves!", @name))
    else
      @battle.pbDisplay(_INTL("{1} made the opposing team stronger against special moves!", @name))
    end
    if @battle.FE == :MIRROR
      attacker.pbChangeStats(PBStats::EVASION, 1, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# Effect depends on the environment. (Secret power)
################################################################################
class PokeBattle_Move_0A4 < PokeBattle_Move
  def canFlinch?
    effect = @battle.getMimicryField
    return [:ROCKY, :CAVE, :MOUNTAIN, :DIMENSIONAL, :DEEPEARTH, *PBFields::CONCERT].include?(effect)
  end

  def pbAdditionalEffect(attacker, opponent)
    effect = @battle.getMimicryField
    case effect
      when :ELECTERRAIN, :SHORTCIRCUIT
        return if !opponent.pbCanParalyze?(attacker, self)

        opponent.pbParalyze(attacker)
      when :GRASSY, :FOREST, :FAIRYTALE
        return if !opponent.pbCanSleep?(attacker, self)

        opponent.pbSleep
      when :MISTY, :HOLY
        opponent.pbChangeStats(PBStats::SPATK, -1, attacker, self, abilitycheck: :hide)
      when :DARKCRYSTALCAVERN, :DESERT, :ASHENBEACH, :CLOUDS
        opponent.pbChangeStats(PBStats::ACCURACY, -1, attacker, self, abilitycheck: :hide)
      when :CHESS, *PBFields::DARKNESS
        opponent.pbChangeStats(PBStats::DEFENSE, -1, attacker, self, abilitycheck: :hide)
      when :BIGTOP, :STARLIGHT
        opponent.pbChangeStats(PBStats::SPDEF, -1, attacker, self, abilitycheck: :hide)
      when :BURNING, :SUPERHEATED, :DRAGONSDEN, :VOLCANIC, :VOLCANICTOP, :INFERNAL, :DANCEFLOOR
        return if !opponent.pbCanBurn?(attacker, self)

        opponent.pbBurn(attacker)
      when :SWAMP, :WATERSURFACE, :GLITCH
        opponent.pbChangeStats(PBStats::SPEED, -1, attacker, self, abilitycheck: :hide)
      when :RAINBOW, :WASTELAND, :CRYSTALCAVERN, :BEWITCHED
        rnd = 0
        loop do
          rnd = @battle.pbRandom(6)
          break if (@battle.FE == :RAINBOW && rnd != 5) || (@battle.OV == :RAINBOW && rnd != 5) || (@battle.FE == :WASTELAND && rnd < 4) || (@battle.FE == :CRYSTALCAVERN && rnd > 1) || (@battle.FE == :BEWITCHED && (rnd < 2 || rnd == 4))
        end
        case rnd
          when 0
            return if !opponent.pbCanParalyze?(attacker, self)

            opponent.pbParalyze(attacker)
          when 1
            return if !opponent.pbCanPoison?(attacker, self)

            opponent.pbPoison(attacker)
          when 2
            return if !opponent.pbCanBurn?(attacker, self)

            opponent.pbBurn(attacker)
          when 3
            return if !opponent.pbCanFreeze?(attacker, self)

            opponent.pbFreeze
          when 4
            return if !opponent.pbCanSleep?(attacker, self)

            opponent.pbSleep
          when 5
            return if !opponent.pbCanConfuse?(attacker, self)

            opponent.pbConfuse
        end
      when :CORROSIVE, :CORROSIVEMIST, :MURKWATERSURFACE, :CORRUPTED, :BACKALLEY, :CITY
        return if !opponent.pbCanPoison?(attacker, self)

        opponent.pbPoison(attacker)
      when :ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION
        return if !opponent.pbCanFreeze?(attacker, self)

        opponent.pbFreeze
      when :DEUXFINALIS
        return if !opponent.pbCanPetrify?(attacker, self)

        opponent.pbPetrify(attacker)
      when :ROCKY, :CAVE, :MOUNTAIN,:DIMENSIONAL, :DEEPEARTH, *PBFields::CONCERT
        return if opponent.ability == :INNERFOCUS || opponent.damagestate.substitute

        opponent.effects[:Flinch] = true
      when :FACTORY, :UNDERWATER
        opponent.pbChangeStats(PBStats::ATTACK, -1, attacker, self, abilitycheck: :hide)
      when :MIRROR
        opponent.pbChangeStats(PBStats::EVASION, -1, attacker, self, abilitycheck: :hide)
      when *PBFields::FLOWERGARDEN
        stats = @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5) ? [PBStats::DEFENSE, PBStats::SPDEF, PBStats::EVASION] : PBStats::EVASION
        amount = @battle.FE == :FLOWERGARDEN5 ? 2 : 1
        opponent.pbChangeStats(stats, amount, attacker, self, abilitycheck: :hide)
      when :NEWWORLD
        stats = PBStats::Omni
        opponent.pbChangeStats(stats, -1, attacker, self, abilitycheck: :hide)
      when :INVERSE, :PSYTERRAIN, :SKY
        return if !opponent.pbCanConfuse?(attacker, self)

        opponent.pbConfuse
      when :HAUNTED
        if !opponent.effects[:Curse]
          opponent.effects[:Curse] = true
          @battle.pbDisplay(_INTL("{1} put a curse on {2}!", attacker.pbThis, opponent.pbThis(true)))
        end
      when :COLOSSEUM
        # do nothing here, will be covered in pbAdditionalEffectSelf
      else
        return if !opponent.pbCanParalyze?(attacker, self)

        opponent.pbParalyze(attacker)
    end
  end

  def pbAdditionalEffectSelf(attacker)
    if @battle.FE == :COLOSSEUM
      attacker.pbChangeStats(PBStats::ATTACK, 1, attacker, self, abilitycheck: :hide)
    end
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    id = @battle.getSecretPowerAnim
    super
  end
end

################################################################################
# User's attack next round against the target will definitely hit. (Lock-On / Mind Reader)
################################################################################
class PokeBattle_Move_0A6 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.effects[:LockOnTarget] == opponent.index
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    attacker.effects[:LockOn] = 2
    attacker.effects[:LockOnTarget] = opponent.index
    @battle.pbDisplay(_INTL("{1} took aim at {2}!", attacker.pbThis, opponent.pbThis(true)))
    if @battle.FE == :PSYTERRAIN && @move == :MINDREADER
      attacker.pbChangeStats(PBStats::SPATK, 2, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# Target's evasion stat changes are ignored from now on. (Foresight / Odor Sleuth)
# Normal and Fighting moves have normal effectiveness against the Ghost-type target.
################################################################################
class PokeBattle_Move_0A7 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.effects[:Foresight]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Foresight] = true
    @battle.pbDisplay(_INTL("{1} was identified!", opponent.pbThis))
  end
end

################################################################################
# Target's evasion stat changes are ignored from now on. (Miracle Eye)
# Psychic moves have normal effectiveness against the Dark-type target.
################################################################################
class PokeBattle_Move_0A8 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.effects[:MiracleEye]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:MiracleEye] = true
    @battle.pbDisplay(_INTL("{1} was identified!", opponent.pbThis))
    if [:HOLY, :FAIRYTALE, :PSYTERRAIN].include?(@battle.FE)
      attacker.pbChangeStats(PBStats::SPATK, 2, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# This move ignores target's Defense, Special Defense and evasion stat changes.
# (SacredSword / Chip Away / Darkest Lariat)
################################################################################
class PokeBattle_Move_0A9 < PokeBattle_Move
  # Handled in superclass, do not edit!
end

################################################################################
# User is protected against moves with the "B" flag this round. (Detect / Protect)
################################################################################
class PokeBattle_Move_0AA < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !PBStuff::RATESHARERS.include?(attacker.lastRegularMoveUsed)
      attacker.effects[:ProtectRate] = 0
    end
    if attacker.movingLast?
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if @battle.pbRandom(3 ** attacker.effects[:ProtectRate]) != 0
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Protect] = :Protect
    attacker.effects[:ProtectRate] += 1
    @battle.pbDisplay(_INTL("{1} protected itself!", attacker.pbThis))
  end
end

################################################################################
# User's side is protected against moves with priority greater than 0 this round. (Quick Guard)
################################################################################
class PokeBattle_Move_0AB < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !PBStuff::RATESHARERS.include?(attacker.lastRegularMoveUsed)
      attacker.effects[:ProtectRate] = 0
    end
    if attacker.movingLast?
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:QuickGuard] = true
    attacker.effects[:ProtectRate] += 1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("{1} protected your team!", @name))
    else
      @battle.pbDisplay(_INTL("{1} protected the opposing team!", @name))
    end
  end
end

################################################################################
# User's side is protected against moves that target multiple battlers this round. (Wide Guard)
################################################################################
class PokeBattle_Move_0AC < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !PBStuff::RATESHARERS.include?(attacker.lastRegularMoveUsed)
      attacker.effects[:ProtectRate] = 0
    end
    if attacker.movingLast?
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:WideGuard] = true
    attacker.effects[:ProtectRate] += 1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("{1} protected your team!", @name))
    else
      @battle.pbDisplay(_INTL("{1} protected the opposing team!", @name))
    end
  end
end

################################################################################
# Ignores target's protections.  If successful, all other moves this round
# ignore them too. (Feint / Hyperspace Hole)
################################################################################
class PokeBattle_Move_0AD < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Protect] = nil
    opponent.pbOwnSide.resetProtect
  end
end

################################################################################
# Uses the last move that the target used. (Mirror Move)
################################################################################
class PokeBattle_Move_0AE < PokeBattle_Move
  # Warning: Don't trust Bulbapedia's claims on how this move is supposed to work.
  # Fal tested it on both showdown and cartridge, Bulbapedia is completely wrong.
  # It also directly contradicts itself by claiming that Mirror Move doesn't work with shadow moves
  # while at the same time having the "Affected by Mirror Move" tag on all attacking shadow moves.
  def pbShortUseMove(attacker, opponent)
    return :FailedMove if !pbEffectValid(attacker, opponent, true)
    return :CallerMove
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.nil? || opponent.lastMoveUsed.nil? || !opponent.lastMoveUsed.is_a?(Symbol)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    movedata = $cache.moves[opponent.lastMoveUsed]
    if movedata.checkFlag?(:nonmirror) ||  movedata.checkFlag?(:specialmove)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if @battle.FE == :MIRROR
      attacker.pbChangeStats([PBStats::ACCURACY, PBStats::ATTACK, PBStats::SPATK], 1, attacker, self, abilitycheck: :hide)
    end
    if @battle.FE == :SKY
      attacker.pbChangeStats([PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED], 1, attacker, self, abilitycheck: :hide)
    end
    move = opponent.lastMoveUsed
    attacker.pbUseMoveSimple(move, -1, opponent.index, callermove: self)
  end
end

################################################################################
# Uses the last move that was used. (Copycat)
################################################################################
class PokeBattle_Move_0AF < PokeBattle_Move
  def pbShortUseMove(attacker, opponent)
    return :FailedMove if !pbEffectValid(attacker, opponent, true)
    return :CallerMove
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    move = @battle.lastMoveUsed
    if !move || !move.is_a?(Symbol) || PBStuff::BLACKLISTS[:COPYCAT].include?(move)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = nil, alltargets = nil, showanimation = nil)
    opponent = @battle.battlers[@battle.lastMoveUser]
    super
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    move = @battle.lastMoveUsed
    attacker.pbUseMoveSimple(move, -1, -1, callermove: self)
  end
end

################################################################################
# Uses the move the target was about to use this round, with 1.5x power. (Me First)
################################################################################
class PokeBattle_Move_0B0 < PokeBattle_Move
  def pbShortUseMove(attacker, opponent)
    return :FailedMove if !pbEffectValid(attacker, opponent, true)
    return :CallerMove
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.nil? || opponent.acted? || @battle.zMove.any? { |t1| t1.any? { |t2| t2 == opponent.index } }
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    selectedmove = @battle.choices[opponent.index][2]
    if [nil, 0, -1].include?(selectedmove) || PBStuff::BLACKLISTS[:MEFIRST].include?(selectedmove.move) || selectedmove.pbIsStatus?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    attacker.effects[:MeFirst] = true
    move = @battle.choices[opponent.index][2].move
    attacker.pbUseMoveSimple(move, -1, opponent.index, callermove: self)
  end
end

################################################################################
# This round, reflects all moves with the "C" flag targeting the user back at
# their origin. (Magic Coat)
################################################################################
class PokeBattle_Move_0B1 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:MagicCoat] = true
    @battle.pbDisplay(_INTL("{1} shrouded itself with {2}!", attacker.pbThis, @name))
  end
end

################################################################################
# This round, snatches all used moves with the "D" flag. (Snatch)
################################################################################
class PokeBattle_Move_0B2 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.movingLast?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Snatch] = true
    @battle.pbDisplay(_INTL("{1} waits for a target to make a move!", attacker.pbThis))
  end
end

################################################################################
# Uses a different move depending on the environment. (Nature Power)
################################################################################
class PokeBattle_Move_0B3 < PokeBattle_Move
  def pbShortUseMove(attacker, opponent)
    return :FailedMove if !pbEffectValid(attacker, opponent, true)
    return :CallerMove
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.nil?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    move = @battle.getNaturePowerMove
    attacker.pbUseMoveSimple(move, -1, opponent.index, callermove: self)
  end
end

################################################################################
# Uses a random move the user knows.  Fails if user is not asleep. (Sleep Talk)
################################################################################
class PokeBattle_Move_0B4 < PokeBattle_Move
  def pbCanUseWhileAsleep?
    return true
  end

  def pbShortUseMove(attacker, opponent)
    return :FailedMove if !pbOnStartUse(attacker, [opponent])
    return :CallerMove
  end

  def pbOnStartUse(attacker, targets)
    unless attacker.isSleeping?
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if self.sleepTalkChoices(attacker).length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    choices = sleepTalkChoices(attacker)
    choice = @battle.sample(choices)
    move = attacker.moves[choice]
    target = attacker.pbTarget(move) == :UserOrPartner ? attacker.index : attacker.pbOppositeOpposing.index
    attacker.sleeptalkUsed = true
    attacker.pbUseMoveSimple(move.move, choice, target, callermove: self)
    attacker.sleeptalkUsed = false
  end

  def sleepTalkChoices(attacker)
    choices = (0...4).to_a.select { |i|
      attacker.moves[i] != nil && attacker.moves[i].move.is_a?(Symbol) && !PBStuff::BLACKLISTS[:SLEEPTALK].include?(attacker.moves[i].move) && @battle.pbCanChooseMove?(attacker.index, i, sleeptalk: true)
    }
    return choices
  end
end

################################################################################
# Uses a random move known by any non-user Pokémon in the user's party. (Assist)
################################################################################
class PokeBattle_Move_0B5 < PokeBattle_Move
  def pbShortUseMove(attacker, opponent)
    return :FailedMove if !pbOnStartUse(attacker, [opponent])
    return :CallerMove
  end

  def pbOnStartUse(attacker, targets)
    choices = assistChoices(attacker, true)
    return true unless choices.empty?

    @battle.pbDisplay(_INTL("But it failed!"))
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    choices = assistChoices(attacker)
    move = @battle.sample(choices)
    attacker.pbUseMoveSimple(move, -1, -1, callermove: self)
  end

  def assistChoices(attacker, needOnlyOne = false)
    choices = []
    party = @battle.pbPartySingleOwner(attacker.index)
    for i in 0...party.length
      next if i == attacker.pokemonIndex || !party[i] || party[i].isEgg?

      for move in party[i].moves
        moveid = move.move
        next if moveid == nil || PBStuff::BLACKLISTS[:ASSIST].include?(moveid)

        choices.push(moveid)
        return choices if needOnlyOne
      end
    end
    return choices
  end
end

################################################################################
# Uses a random move that exists. (Metronome)
################################################################################
class PokeBattle_Move_0B6 < PokeBattle_Move
  def pbShortUseMove(attacker, opponent)
    return :FailedMove if !pbOnStartUse(attacker, [opponent])
    return :CallerMove
  end

  def pbOnStartUse(attacker, targets)
    choices = metronomeChoices(true)
    return true unless choices.empty?

    @battle.pbDisplay(_INTL("But it failed!"))
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    choices = metronomeChoices
    move = @battle.sample(choices)
    attacker.pbUseMoveSimple(move, -1, -1, callermove: self)
  end

  def metronomeChoices(needOnlyOne = false)
    choices = []
    $cache.moves.each do |symbol, move|
      next if PBStuff::BLACKLISTS[:METRONOME].include?(symbol)
      next if move.type == :SHADOW
      next if @battle.FE == :GLITCH && move.basedamage < 70

      choices.push(symbol)
      return choices if needOnlyOne
    end
    return choices
  end
end

################################################################################
# The target can no longer use the same move twice in a row. (Torment)
################################################################################
class PokeBattle_Move_0B7 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    if opponent.effects[:Torment]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    aromaVeil = @battle.pbCheckSideAbility(:AROMAVEIL, opponent, checkMoldBroken: true)
    if aromaVeil.any?
      @battle.pbAbilityBoxAndDisplay(aromaVeil.first, _INTL("{1} is protected by an aromatic veil!", opponent.pbThis)) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @basedamage > 0
    opponent.effects[:Torment] = true
    @battle.pbDisplay(_INTL("{1} was subjected to torment!", opponent.pbThis))
    opponent.pbBerryHerbCheck(true)
  end

  def pbAdditionalEffect(attacker, opponent)
    if !opponent.isFaintedAndNoShields? && !opponent.effects[:Torment] && @battle.pbCheckSideAbility(:AROMAVEIL, opponent, checkMoldBroken: true).none?
      opponent.effects[:Torment] = true
      @battle.pbDisplay(_INTL("{1} was subjected to torment!", opponent.pbThis))
      opponent.pbBerryHerbCheck(true)
    end
  end
end

################################################################################
# Disables all target's moves that the user also knows. (Imprison)
################################################################################
class PokeBattle_Move_0B8 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.effects[:Imprison]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Imprison] = true
    @battle.pbDisplay(_INTL("{1} sealed any moves its target shares with it!", attacker.pbThis))
  end
end

################################################################################
# For 5 rounds, disables the last move the target used. (Disable)
################################################################################
class PokeBattle_Move_0B9 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.effects[:Disable] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    aromaVeil = @battle.pbCheckSideAbility(:AROMAVEIL, opponent, checkMoldBroken: true)
    if aromaVeil.any?
      @battle.pbAbilityBoxAndDisplay(aromaVeil.first, _INTL("{1} is protected by an aromatic veil!", opponent.pbThis)) if showMessage
      return false
    end
    if opponent.moves.none? { |i| i && i.move == opponent.lastMoveUsed && i.usable? }
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    lastMoveIndex = opponent.moves.find_index { |i| i && i.move == opponent.lastMoveUsed && i.usable? }
    opponent.effects[:Disable] = 4
    opponent.effects[:DisableMove] = opponent.lastMoveUsed
    @battle.pbDisplay(_INTL("{1}'s {2} was disabled!", opponent.pbThis, opponent.moves[lastMoveIndex].name))
    opponent.pbBerryHerbCheck(true)
  end
end

################################################################################
# For 4 rounds, disables the target's non-damaging moves. (Taunt)
################################################################################
class PokeBattle_Move_0BA < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.ability == :OBLIVIOUS && !opponent.moldbroken
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.effects[:Taunt] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    aromaVeil = @battle.pbCheckSideAbility(:AROMAVEIL, opponent, checkMoldBroken: true)
    if aromaVeil.any?
      @battle.pbAbilityBoxAndDisplay(aromaVeil.first, _INTL("{1} is protected by an aromatic veil!", opponent.pbThis)) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Taunt] = 4
    @battle.pbDisplay(_INTL("{1} fell for the taunt!", opponent.pbThis))
    opponent.pbBerryHerbCheck(true)
  end
end

################################################################################
# For 5 rounds, disables the target's healing moves. (Heal Block / Psychic Noise)
################################################################################
class PokeBattle_Move_0BB < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    if opponent.effects[:HealBlock] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    aromaVeil = @battle.pbCheckSideAbility(:AROMAVEIL, opponent, checkMoldBroken: true)
    if aromaVeil.any?
      @battle.pbAbilityBoxAndDisplay(aromaVeil.first, _INTL("{1} is protected by an aromatic veil!", opponent.pbThis)) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if @basedamage > 0
    opponent.effects[:HealBlock] = 5
    @battle.pbDisplay(_INTL("{1} was prevented from healing!", opponent.pbThis))
    opponent.pbBerryHerbCheck(true)
  end

  def pbAdditionalEffect(attacker, opponent)
    if opponent.effects[:HealBlock] <= 0 && @battle.pbCheckSideAbility(:AROMAVEIL, opponent, checkMoldBroken: true).none?
      opponent.effects[:HealBlock] = 2
      @battle.pbDisplay(_INTL("{1} was prevented from healing!", opponent.pbThis))
    end
  end
end

################################################################################
# For 4 rounds, the target must use the same move each round. (Encore)
################################################################################
class PokeBattle_Move_0BC < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    move = opponent.lastMoveUsed
    if opponent.effects[:Encore] > 0 ||
       !move.is_a?(Symbol) ||
       PBStuff::BLACKLISTS[:ENCORE].include?(move) ||
       opponent.effects[:ShellTrap]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    aromaVeil = @battle.pbCheckSideAbility(:AROMAVEIL, opponent, checkMoldBroken: true)
    if aromaVeil.any?
      @battle.pbAbilityBoxAndDisplay(aromaVeil.first, _INTL("{1} is protected by an aromatic veil!", opponent.pbThis)) if showMessage
      return false
    end
    # First check if their last choice matches the encore'd move.
    moveIndex = opponent.lastMoveChoice[1]
    # Just to be safe, if it doesn't match, find it manually.
    if opponent.moves[moveIndex].move != move
      found = false
      for i in 0...opponent.moves.length
        if move == opponent.moves[i]
          found = true
          moveIndex = i
          break
        end
      end
      if !found
        @battle.pbDisplay(_INTL("But it failed!")) if showMessage
        return false
      end
    end
    # Once it's found, make sure it has PP.
    unless opponent.moves[moveIndex].usable?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    move = opponent.lastMoveUsed
    moveIndex = opponent.lastMoveChoice[1]
    # Search for choice manually. pbEffectValid guarantees our success.
    if opponent.moves[moveIndex].move != move
      for i in 0...opponent.moves.length
        if move == opponent.moves[i]
          moveIndex = i
          break
        end
      end
    end

    opponent.effects[:Encore] = 3
    opponent.effects[:Encore] += 1 if opponent.hasMovedThisRound?
    opponent.effects[:Encore] += 3 if @battle.FE == :BIGTOP || @battle.ProgressiveFieldCheck(PBFields::CONCERT)
    opponent.effects[:EncoreIndex] = moveIndex
    opponent.effects[:EncoreMove] = move
    if Gen >= Champs
      # Since Champions, the forced move uses its own priority rather than the priority of the chosen move.
      @battle.speedData[opponent.index][:movePriority] = opponent.moves[moveIndex].priorityCheck(opponent)
    end
    @battle.pbDisplay(_INTL("{1} must do an encore!", opponent.pbThis))
    opponent.pbBerryHerbCheck(true)
  end
end

################################################################################
# Hits twice. (Gear Grind / Double Hit / Double Kick / Dual Chop / Bonemerang / Twin Beam / Tachyon Cutter)
################################################################################
class PokeBattle_Move_0BD < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end
end

################################################################################
# Hits twice.  May poison the target on each hit. (Twineedle)
################################################################################
class PokeBattle_Move_0BE < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanPoison?(attacker, self)

    opponent.pbPoison(attacker)
  end
end

################################################################################
# Hits 3 times.  Power is multiplied by the hit number.
# (Triple Kick, Triple Axel, Thunder Raid)
################################################################################
class PokeBattle_Move_0BF < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def checkAccuracyEachHit(attacker)
    return attacker.ability != :SKILLLINK && !attacker.hasWorkingItem(:LOADEDDICE)
  end

  def pbNumHits(attacker)
    return 3
  end

  def pbOnStartUse(attacker, targets)
    @calcbasedmg = @basedamage
    @calcbasedmg = [attacker.happiness, 250].min if attacker.crested == :LUVDISC
    return true
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    ret = @calcbasedmg
    @calcbasedmg += basedmg
    return ret
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if @move == :THUNDERRAID
      id = :THUNDERRAID2 if hitnum == 1
      id = :THUNDERRAID3 if hitnum == 2
    end
    super
  end
end

################################################################################
# Hits 2-5 times. (Pin Missile / Arm Thrust / Bullet Seed / Bone Rush / Icicle Spear /
# Tail Slap / Spike Cannon / Fury Swipes / Barrage / Double Slap / Fury Attack /
# Rock Blast / Water Shuriken / Comet Punch)
################################################################################
class PokeBattle_Move_0C0 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min / 5 if attacker.crested == :LUVDISC
    return basedmg
  end

  def pbNumHits(attacker)
    return 5 if attacker.ability == :SKILLLINK || attacker.crested == :LUVDISC || (attacker.crested == :FEAROW && @move == :FURYATTACK)

    hitchances = [2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5]
    hitchances = [4, 5] if attacker.hasWorkingItem(:LOADEDDICE)
    return @battle.sample(hitchances)
  end
end

################################################################################
# Hits X times, where X is the number of unfainted status-free Pokémon in the
# user's party (the participants).  Fails if X is 0.
# Base power of each hit depends on the base Attack stat for the species of that
# hit's participant. (Beat Up)
################################################################################
class PokeBattle_Move_0C1 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    if @participants.nil?
      @participants = attacker.pbBeatUpParty
    end
    return @participants.length
  end

  def pbOnStartUse(attacker, targets)
    @participants = attacker.pbBeatUpParty
    if @participants.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    mon = @participants.shift
    atk = mon.baseStats[1]
    return 5 + (atk / 10)
  end
end

################################################################################
# Two turn attack.  Attacks first turn, skips second turn (if successful).
# (Roar of Time / Blast Burn / Frenzy Plant / Giga Impact / Hyper Beam / Rock Wrecker /
# Hydro Cannon / Prismatic Laser / Meteor Assault / Eternabeam)
################################################################################
class PokeBattle_Move_0C2 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if !(@battle.FE == :STARLIGHT && @move == :METEORASSAULT) && !(attacker.crested == :CLAYDOL && [:HYPERBEAM, :PRISMATICLASER, :ETERNABEAM].include?(@move))
      attacker.effects[:HyperBeam] = 2
      attacker.currentMove = @move
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn. (Razor Wind)
################################################################################
class PokeBattle_Move_0C3 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      @immediate = true if [:CLOUDS, :SKY].include?(@battle.FE) || (Rejuv && (@battle.FE == :GRASSY || @battle.OV == :GRASSY))
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} whipped up a whirlwind!", attacker.pbThis))
      @battle.pbCommonAnimation("Razor Wind charging", attacker, nil)
    else
      super
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn. (Solar Beam / Solar Blade)
# Power halved in all weather except sunshine.  In sunshine, takes 1 turn instead.
################################################################################
class PokeBattle_Move_0C4 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if @battle.FE == :DARKCRYSTALCAVERN && @battle.pbWeather(attacker) != :SUNNYDAY
      @battle.pbDisplay(_INTL("But it failed!"))
      attacker.effects[:TwoTurnAttack] = 0
      return false
    end
    return true
  end

  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      if @battle.FE == :RAINBOW || @battle.OV == :RAINBOW
        @immediate = true
      elsif @battle.pbWeather(attacker) == :SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
        @immediate = true
        if @battle.weather != :SUNNYDAY # Mega Sol
          if attacker.ability == :MEGASOL
            attacker.effects[:PowerHerb] = :Ability
          elsif attacker.crested == :SUNFLORA
            attacker.effects[:PowerHerb] = :Crest
          end
        end
      elsif attacker.crested == :CLAYDOL && @move == :SOLARBEAM
        @immediate = true
        attacker.effects[:PowerHerb] = :Crest
      elsif attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    weather = @battle.pbWeather(attacker)
    if weather != 0 && ![:SUNNYDAY, :STRONGWINDS].include?(weather) && !(weather == :RAINDANCE && attacker.hasWorkingItem(:UTILITYUMBRELLA))
      damagemult *= 0.5
    end
    return damagemult
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} absorbed sunlight!", attacker.pbThis))
      @battle.pbCommonAnimation("Solar Beam charging", attacker, nil)
    else
      super
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May paralyze the target. (Freeze Shock)
################################################################################
class PokeBattle_Move_0C5 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      @immediate = true if @battle.FE == :FROZENDIMENSION
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanParalyze?(attacker, self)

    opponent.pbParalyze(attacker)
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} became cloaked in a freezing light!", attacker.pbThis))
      @battle.pbCommonAnimation("Freeze Shock charging", attacker, nil)
    else
      super
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May burn the target. (Ice Burn)
################################################################################
class PokeBattle_Move_0C6 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      @immediate = true if @battle.FE == :FROZENDIMENSION
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanBurn?(attacker, self)

    opponent.pbBurn(attacker)
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} became cloaked in freezing air!", attacker.pbThis))
      @battle.pbCommonAnimation("Ice Burn charging", attacker, nil)
    else
      super
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May make the target flinch. (Sky Attack)
################################################################################
class PokeBattle_Move_0C7 < PokeBattle_Move
  def canFlinch?
    return true
  end

  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      @immediate = true if [:CLOUDS, :SKY].include?(@battle.FE)
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
    end
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} became cloaked in a harsh light!", attacker.pbThis))
      @battle.pbCommonAnimation("Sky Attack charging", attacker, nil)
    else
      super
    end
  end
end

################################################################################
# Two turn attack.  Ups user's Defence by 1 stage first turn, attacks second turn. (Skull Bash)
################################################################################
class PokeBattle_Move_0C8 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if attacker.effects[:TwoTurnAttack] != 0
      attacker.pbChangeStats(PBStats::DEFENSE, 1, attacker, self, abilitycheck: :hide)
    end
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} tucked in its head!", attacker.pbThis))
      @battle.pbCommonAnimation("Skull Bash charging", attacker, nil)
    else
      super
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Fly)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0C9 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      @immediate = true if [:CLOUDS, :CAVE, :SKY].include?(@battle.FE) || (Rejuv && @battle.FE == :DRAGONSDEN)
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} flew up high!", attacker.pbThis))
      @battle.pbCommonAnimation("Fly charging", attacker, nil)
      @battle.scene.pbVanishSprite(attacker)
    else
      super
      @battle.scene.pbUnVanishSprite(attacker, false)
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Dig)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CA < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      @immediate = true if Rejuv && @battle.FE == :DESERT
      @immediate = true if [:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE) && self.pbType(attacker, self.type) == :GROUND # for move failure on these fields
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} burrowed its way under the ground!", attacker.pbThis))
      @battle.pbCommonAnimation("Dig charging", attacker, nil)
      @battle.scene.pbVanishSprite(attacker)
      @battle.scene.pbDisableShadowTemp(attacker)
    else
      super
      @battle.scene.pbUnVanishSprite(attacker, false)
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Dive)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CB < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      @immediate = true if [:WATERSURFACE, :UNDERWATER].include?(@battle.FE)
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if attacker.effects[:TwoTurnAttack] == 0
      @battle.field.counter = 3 if Rejuv && @battle.FE == :ICY && [:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.field.backup)
    end
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      if Rejuv && @battle.FE == :ICY && [:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.field.backup)
        @battle.pbAnimation(:SPLASH, attacker, opponent, hitnum)
        if attacker == @battle.battlers[0] || attacker == @battle.battlers[2]
          @battle.pbApplySceneBG("playerbase", "Graphics/Battlebacks/playerbaseWater.png")
        elsif attacker == @battle.battlers[1] || attacker == @battle.battlers[3]
          @battle.pbApplySceneBG("enemybase", "Graphics/Battlebacks/enemybaseWater.png")
        end
        @battle.pbDisplay(_INTL("{1} made a hole in the ice!", attacker.pbThis))
      end
      @battle.pbDisplay(_INTL("{1} hid underwater!", attacker.pbThis))
      @battle.pbCommonAnimation("Dive charging", attacker, nil)
      @battle.scene.pbVanishSprite(attacker)
      @battle.scene.pbDisableShadowTemp(attacker)
    else
      super
      @battle.scene.pbUnVanishSprite(attacker, false)
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Bounce)
# May paralyze the target.
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CC < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      @immediate = true if [:CLOUDS, :CAVE, :SKY].include?(@battle.FE) || (Rejuv && @battle.FE == :DRAGONSDEN)
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanParalyze?(attacker, self)

    opponent.pbParalyze(attacker)
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} sprang up!", attacker.pbThis))
      @battle.pbCommonAnimation("Bounce charging", attacker, nil)
      @battle.scene.pbVanishSprite(attacker)
    else
      super
      @battle.scene.pbUnVanishSprite(attacker, false)
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Shadow Force / Phantom Force)
# Is invulnerable during use.
# If successful, negates target's Detect and Protect this round.
################################################################################
class PokeBattle_Move_0CD < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      @immediate = true if (Rejuv && [:DIMENSIONAL, :FROZENDIMENSION, :HAUNTED, :SHORTCIRCUIT, :DEUXFINALIS].include?(@battle.FE)) || @battle.ProgressiveFieldCheck(PBFields::DARKNESS, 2, 3)
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if attacker.effects[:TwoTurnAttack] == 0
      opponent.effects[:Protect] = nil
      opponent.pbOwnSide.resetProtect
    end
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} vanished instantly!", attacker.pbThis))
      @battle.pbCommonAnimation("Shadow Force charging", attacker, nil)
      @battle.scene.pbVanishSprite(attacker)
      @battle.scene.pbDisableShadowTemp(attacker)
    else
      super
      @battle.scene.pbUnVanishSprite(attacker, false)
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Sky Drop)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
# Target is also semi-invulnerable during use, and can't take any action.
# Doesn't damage airborne Pokémon (but still makes them unable to move during).
################################################################################
class PokeBattle_Move_0CE < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbAccuracyCheck(attacker, opponent)
    return true if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if attacker.effects[:TwoTurnAttack] != 0
      if opponent.weight >= 2000
        if showMessage
          @battle.pbDisplay(_INTL("{1} is too heavy to be lifted!", opponent.pbThis))
          attacker.effects[:TwoTurnAttack] = 0
          attacker.effects[:SkyDroppee] = nil
        end
        return false
      end
      if blockedBySubstitute?(attacker, opponent)
        if showMessage
          @battle.pbDisplay(_INTL("But it failed!"))
          attacker.effects[:TwoTurnAttack] = 0
          attacker.effects[:SkyDroppee] = nil
        end
        return false
      end
    else
      if opponent.hasType?(:FLYING)
        if showMessage
          @battle.scene.pbUnVanishSprite(attacker)
          @battle.scene.pbUnVanishSprite(opponent)
          attacker.effects[:SkyDroppee]    = nil
          opponent.effects[:TwoTurnAttack] = 0
          opponent.effects[:SkyDrop]       = false
          @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", opponent.pbThis(true)))
        end
        return false
      end
    end
    return true
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbClearChoices(opponent.index)
      attacker.effects[:SkyDroppee] = opponent
      opponent.effects[:FollowMe] = false
      opponent.effects[:RagePowder] = false
      opponent.effects[:SkyDrop] = true
    else
      @battle.pbDisplay(_INTL("{1} was freed from the {2}!", opponent.pbThis, @name))
      opponent.effects[:SkyDrop] = false
      attacker.effects[:SkyDroppee] = nil
    end
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} took {2} into the sky!", attacker.pbThis, opponent.pbThis(true)))
      @battle.pbCommonAnimation("Sky Drop charging", attacker, opponent)
      @battle.scene.pbVanishSprite(attacker)
      @battle.scene.pbVanishSprite(opponent)
    else
      super
      @battle.scene.pbUnVanishSprite(attacker, false)
      @battle.scene.pbUnVanishSprite(opponent, false)
    end
  end
end

################################################################################
# Trapping move.  Traps for 4 or 5 rounds.  Trapped Pokémon lose 1/8 of max HP
# at end of each round. (Magma Storm / Fire Spin / Sand Tomb / Bind / Wrap / Clamp /
# Infestation / Snap Trap / Thunder Cage)
################################################################################
class PokeBattle_Move_0CF < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if opponent.isFaintedAndNoShields? || opponent.damagestate.substitute || opponent.effects[:MultiTurn] != 0
    # Note: The amount of turns is intentionally 1 higher, otherwise it ends sooner than intended.
    opponent.effects[:MultiTurn] = 5 + @battle.pbRandom(2)
    opponent.effects[:MultiTurn] = 8 if attacker.hasWorkingItem(:GRIPCLAW)
    opponent.effects[:MultiTurnAttack] = @move
    opponent.effects[:MultiTurnUser] = attacker.index
    opponent.effects[:BindingBand] = attacker.hasWorkingItem(:BINDINGBAND)
    case @move
      when :BIND then @battle.pbDisplay(_INTL("{1} was squeezed by {2}!", opponent.pbThis, attacker.pbThis(true)))
      when :CLAMP then @battle.pbDisplay(_INTL("{1} clamped down on {2}!", attacker.pbThis, opponent.pbThis(true)))
      when :FIRESPIN then @battle.pbDisplay(_INTL("{1} became trapped in the fiery vortex!", opponent.pbThis))
      when :MAGMASTORM then @battle.pbDisplay(_INTL("{1} was trapped by swirling magma!", opponent.pbThis))
      when :WRAP then @battle.pbDisplay(_INTL("{1} was wrapped by {2}!", opponent.pbThis, attacker.pbThis(true)))
      when :INFESTATION then @battle.pbDisplay(_INTL("{1} has been afflicted with an infestation by {2}!", opponent.pbThis, attacker.pbThis(true)))
      when :SANDTOMB then @battle.pbDisplay(_INTL("{1} was trapped by the quicksand!", opponent.pbThis))
      when :SNAPTRAP then @battle.pbDisplay(_INTL("{1} got trapped by a snap trap!", opponent.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} trapped {2}!", attacker.pbThis, opponent.pbThis(true)))
    end
  end
end

################################################################################
# Trapping move- Whirlpool specific.  Traps for 4 or 5 rounds.  Trapped Pokémon lose 1/8 of max HP
# at end of each round. (Whirlpool)
# Power is doubled if target is using Dive.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_0D0 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if opponent.isFaintedAndNoShields? || opponent.damagestate.substitute || opponent.effects[:MultiTurn] != 0
    # Note: The amount of turns is intentionally 1 higher, otherwise it ends sooner than intended.
    opponent.effects[:MultiTurn] = 5 + @battle.pbRandom(2)
    opponent.effects[:MultiTurn] = 8 if attacker.hasWorkingItem(:GRIPCLAW)
    opponent.effects[:MultiTurnAttack] = @move
    opponent.effects[:MultiTurnUser] = attacker.index
    opponent.effects[:BindingBand] = attacker.hasWorkingItem(:BINDINGBAND)
    @battle.pbDisplay(_INTL("{1} became trapped in the vortex!", opponent.pbThis))
    if (!Rejuv && @battle.FE == :WATERSURFACE) || @battle.FE == :UNDERWATER
      if opponent.pbCanConfuse?(attacker, self)
        opponent.pbConfuse
      end
    end
  end

  def pbModifyDamage(damagemult, attacker, opponent)
    damagemult *= 2.0 if $cache.moves[opponent.effects[:TwoTurnAttack]]&.function == 0xCB # Dive
    return damagemult
  end
end

################################################################################
# User must use this move for 2 more rounds.  No battlers can sleep. (Uproar)
################################################################################
class PokeBattle_Move_0D1 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if attacker.effects[:Uproar] == 0
      attacker.effects[:Uproar] = 3
      @battle.pbDisplay(_INTL("{1} caused an uproar!", attacker.pbThis))
      @battle.eachBattler do |i| # correct
        if !i.isFaintedAndNoShields? && i.status == :SLEEP
          i.pbCureStatus(false)
          @battle.pbDisplay(_INTL("The uproar woke {1}!", i.pbThis(true)))
        end
      end
      attacker.currentMove = @move
    end
  end
end

################################################################################
# User must use this move for 1 or 2 more rounds.  At end, user becomes confused.
# (Outrage / Petal Dance / Thrash / Raging Fury)
################################################################################
class PokeBattle_Move_0D2 < PokeBattle_Move
  def pbEffectAfterMove(attacker, alltargets, hitflags)
    return if attacker.isFaintedAndNoShields? || ![:Success, :StatusSuccess].intersect?(hitflags)

    if attacker.effects[:Outrage] == 0 && !attacker.sleeptalkUsed # Outrage isn't locked in if it is called via sleep talk
      attacker.effects[:Outrage] = 2 + @battle.pbRandom(2)
      attacker.effects[:Outrage] = 1 if [:SUPERHEATED, :VOLCANICTOP].include?(@battle.FE)
      attacker.currentMove = @move
    end
    if attacker.effects[:Outrage] > 0
      attacker.effects[:Outrage] -= 1
      if attacker.effects[:Outrage] == 0 && attacker.pbCanConfuse?(attacker, nil) && !([:VOLCANIC, :VOLCANICTOP, :BURNING, :SUPERHEATED].include?(@battle.FE) && @move == :RAGINGFURY)
        attacker.pbConfuse(message: _INTL("{1} became confused due to fatigue!", attacker.pbThis))
      end
    end
  end
end

################################################################################
# User must use this move for 4 more rounds.  Power doubles each round.
# Power is also doubled if user has curled up. (Rollout / Ice Ball)
################################################################################
class PokeBattle_Move_0D3 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    shift = attacker.effects[:Rollout] # from 0 through 4, 4 is most powerful
    shift += 1 if attacker.effects[:DefenseCurl]
    basedmg = basedmg << shift
    return basedmg
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if attacker.sleeptalkUsed # Rollout isn't locked in if it is called via sleep talk
    attacker.effects[:Rollout] += 1
    attacker.effects[:Rollout] = 0 if attacker.effects[:Rollout] == 5
    attacker.currentMove = basemove.move
  end
end

################################################################################
# User bides its time this round and next round.  The round after, deals 2x the
# total damage it took while biding to the last battler that damaged it. (Bide)
################################################################################
class PokeBattle_Move_0D4 < PokeBattle_Move
  def pbDisplayUseMessage(attacker, choice)
    if attacker.effects[:Bide] > 0
      if attacker.effects[:Bide] > 1
        @battle.pbDisplayBrief(_INTL("{1} is storing energy!", attacker.pbThis))
      else
        @battle.pbDisplayBrief(_INTL("{1} unleashed energy!", attacker.pbThis))
      end
    else
      super
    end
  end

  def pbShortUseMove(attacker, targets)
    if attacker.effects[:Bide] == 0
      attacker.effects[:Bide] = 2
      attacker.effects[:BideDamage] = 0
      attacker.effects[:BideTarget] = -1
      attacker.currentMove = @move
      @battle.pbCommonAnimation("Bide", attacker, nil)
      return :Bide
    else
      attacker.effects[:Bide] -= 1
      if attacker.effects[:Bide] == 0
        return :ContinueMove
      else
        @battle.pbCommonAnimation("Bide", attacker, nil)
        return :Bide
      end
    end
  end

  def pbAddTarget(targets, target, attacker)
    if attacker.effects[:Bide] > 0
      if attacker.effects[:BideTarget] >= 0 &&
         !super(targets, @battle.battlers[attacker.effects[:BideTarget]], attacker)
        attacker.pbRandomTarget(targets, self)
      end
    else
      super
    end
  end

  def pbOnStartUse(attacker, targets)
    if attacker.effects[:BideDamage] == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    dmg = attacker.effects[:BideDamage] * 2
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:BideDamage] = 0
  end
end

################################################################################
# Heals user by 1/2 of its max HP. (Heal Order / pre-Champions Milk Drink / Recover / Slack Off / Soft-Boiled)
################################################################################
class PokeBattle_Move_0D5 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return true unless attacker.hp == attacker.totalhp

    @battle.pbDisplay(_INTL("{1}'s HP is full!", attacker.pbThis)) if showMessage
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    hpgain = (attacker.totalhp / 2.0).round
    hpgain = (attacker.totalhp * 0.66).round if @battle.FE == :FOREST && @move == :HEALORDER
    attacker.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", attacker.pbThis))
  end
end

################################################################################
# Heals user by 1/2 of its max HP. (Roost)
# User roosts, and its Flying type is ignored for attacks used against it.
################################################################################
class PokeBattle_Move_0D6 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return true unless attacker.hp == attacker.totalhp

    @battle.pbDisplay(_INTL("{1}'s HP is full!", attacker.pbThis)) if showMessage
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    hpgain = (attacker.totalhp / 2.0).round
    attacker.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", attacker.pbThis))
    attacker.effects[:Roost] = true unless @battle.FE == :CLOUDS
  end
end

################################################################################
# Battler in user's position is healed by 1/2 of its max HP, at the end of the
# next round. (Wish)
################################################################################
class PokeBattle_Move_0D7 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if @battle.FE == :DARKNESS1
      return true unless attacker.hp == attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", attacker.pbThis)) if showMessage
    else
      return true unless attacker.effects[:Wish] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    end
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.FE == :DARKNESS1
      attacker.pbRecoverHP((attacker.totalhp / 2.0).floor, true, message: _INTL("{1}'s wish came true!", attacker.pbThis))
    else
      attacker.effects[:Wish] = 2
      if [:MISTY, :RAINBOW, :HOLY, :FAIRYTALE, :STARLIGHT].include?(@battle.FE)
        attacker.effects[:WishAmount] = [(attacker.totalhp * 0.75).floor, 1].max
      else
        attacker.effects[:WishAmount] = [(attacker.totalhp / 2.0).floor, 1].max
      end
      attacker.effects[:WishMaker] = attacker.pokemonIndex
    end
  end
end

################################################################################
# Heals user by an amount depending on the weather. (Synthesis / Moonlight / Morning Sun)
################################################################################
class PokeBattle_Move_0D8 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return true unless attacker.hp == attacker.totalhp

    @battle.pbDisplay(_INTL("{1}'s HP is full!", attacker.pbThis)) if showMessage
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    hpgain = 0
    if ([:DARKCRYSTALCAVERN, :STARLIGHT, :NEWWORLD, :BEWITCHED].include?(@battle.FE) && @move == :MOONLIGHT) || (Rejuv && @battle.FE == :GRASSY && @move == :SYNTHESIS)
      hpgain = (attacker.totalhp * 0.75).pokeRound
    elsif @battle.FE == :DARKNESS1 && @move == :MOONLIGHT
      hpgain = (attacker.totalhp * 0.4).pokeRound
    elsif [:DARKCRYSTALCAVERN, :DARKNESS2].include?(@battle.FE) && @move != :MOONLIGHT
      hpgain = (attacker.totalhp * 0.25).pokeRound
    elsif (@battle.FE == :DARKNESS3 || @battle.OV == :DARKNESS2) && @move != :MOONLIGHT
      hpgain = (attacker.totalhp * 0.125).pokeRound
    else
      weather = @battle.pbWeather(attacker)
      if weather == :SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
        hpgain = (attacker.totalhp * 0.667).pokeRound
        @battle.pbAbilityBoxAndWait(attacker) if @battle.weather != :SUNNYDAY # Mega Sol
      elsif weather == 0 || ([:SUNNYDAY, :RAINDANCE].include?(weather) && attacker.hasWorkingItem(:UTILITYUMBRELLA))
        hpgain = (attacker.totalhp / 2.0).pokeRound
      else
        hpgain = (attacker.totalhp * 0.25).pokeRound
      end
    end
    attacker.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", attacker.pbThis))
  end
end

################################################################################
# Heals user to full HP.  User falls asleep for 2 more rounds. (Rest)
################################################################################
class PokeBattle_Move_0D9 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.status == :SLEEP && attacker.sleeptalkUsed && Rejuv && @battle.FE == :GLITCH
      # @battle.pbDisplay(_INTL("Stall is pure!"))
      # Bypass sleep failure condition when using Sleep Talk on Glitch in Rejuv
    elsif attacker.isSleeping?
      @battle.pbDisplay(_INTL("{1} is already asleep!", attacker.pbThis))
      return false
    end
    if attacker.hp == attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", attacker.pbThis))
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    return attacker.pbCanSleep?(attacker, self, ignorestatus: true, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbSleep(rest: true, message: _INTL("{1} slept and restored its HP!", attacker.pbThis))
    hp = attacker.totalhp - attacker.hp
    attacker.pbRecoverHP(hp, true, fullrecover: true) # early message
  end
end

################################################################################
# Rings the user.  Ringed Pokémon gain 1/16 of max HP at the end of each round. (Aqua Ring)
################################################################################
class PokeBattle_Move_0DA < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.effects[:AquaRing]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:AquaRing] = true
    @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!", attacker.pbThis))
  end
end

################################################################################
# Ingrains the user.  Ingrained Pokémon gain 1/16 of max HP at the end of each
# round, and cannot flee or switch out. (Ingrain)
################################################################################
class PokeBattle_Move_0DB < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if attacker.effects[:Ingrain]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Ingrain] = true
    @battle.pbDisplay(_INTL("{1} planted its roots!", attacker.pbThis))
  end
end

################################################################################
# Seeds the target.  Seeded Pokémon lose 1/8 of max HP at the end of each
# round, and the Pokémon in the user's position gains the same amount. (Leech Seed)
################################################################################
class PokeBattle_Move_0DC < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.effects[:LeechSeed] >= 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if opponent.hasType?(:GRASS)
      @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:LeechSeed] = attacker.index
    @battle.pbDisplay(_INTL("{1} was seeded!", opponent.pbThis))
  end
end

################################################################################
# User gains half the HP it inflicts as damage. (Leech Life / Drain Punch / Giga Drain /
# Horn Leech / Mega Drain / Absorb / Parabolic Charge / Bitter Blade)
################################################################################
class PokeBattle_Move_0DD < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    damage = opponent.lastHPLost
    if damage > 0 && !opponent.damagestate.disguise
      hpgain = (damage * 0.5).round
      hpgain = (damage * 0.75).round if Rejuv && @battle.FE == :ELECTERRAIN && @move == :PARABOLICCHARGE
      hpgain = (damage * 0.75).round if Rejuv && @battle.FE == :GRASSY && [:ABSORB, :MEGADRAIN, :GIGADRAIN, :HORNLEECH].include?(@move)
      attacker.absorbHP(hpgain, opponent, :HPDrainingMove, self)
    end
  end


  def pbAdditionalEffect(attacker, opponent)
    if @move == :BITTERBLADE && [:DEUXFINALIS].include?(@battle.FE)
      if opponent.pbCanPetrify?(attacker, self)
        opponent.pbPetrify(attacker)
      end
    end
  end

end

################################################################################
# User gains half the HP it inflicts as damage. (Dream Eater)
# (Handled in Battler's pbSuccessCheck): Fails if target is not asleep.
################################################################################
class PokeBattle_Move_0DE < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    unless opponent.isSleeping? || attacker.ability == :WORLDOFNIGHTMARES
      @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    damage = opponent.lastHPLost
    if damage > 0 && !opponent.damagestate.disguise
      hpgain = (damage * 0.5).round
      attacker.absorbHP(hpgain, opponent, :HPDrainingMove, self)
    end
  end
end

################################################################################
# Heals target by 1/2 of its max HP. (Heal Pulse, post-Champions Milk Drink)
################################################################################
class PokeBattle_Move_0DF < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.effects[:HealBlock] > 0 || (opponent.status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, opponent).none? && opponent.crested != :SUICUNE)
      @battle.pbDisplay(_INTL("{1} was prevented from healing!", opponent.pbThis)) if showMessage
      return false
    end
    if opponent.hp == opponent.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", opponent.pbThis)) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    hpgain = (opponent.totalhp * 0.5).round
    if pulseMove? && attacker.ability == :MEGALAUNCHER
      hpgain = (opponent.totalhp * 0.75).round
    end
    opponent.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", opponent.pbThis))
  end
end

################################################################################
# User faints. (Explosion / Self-Destruct / Misty Explosion)
################################################################################
class PokeBattle_Move_0E0 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 1.5 if @move == :MISTYEXPLOSION && ([:MISTY, :CORROSIVEMIST].include?(@battle.FE) || @battle.OV == :MISTY) && !attacker.isAirborne?
    return damagemult
  end

  def getRecoil(attacker, damage, recoilmult, hitflags)
    return attacker.hp
  end

  def inflictRecoil(attacker, recoil, hitflags)
    @battle.pbAnimation(@move, attacker, nil, 0) if hitflags.empty?
    recoil = attacker.pbReduceHP(recoil)
    return recoil
  end
end

################################################################################
# Inflicts fixed damage equal to user's current HP.
# User faints (if successful). (Final Gambit)
################################################################################
class PokeBattle_Move_0E1 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbReduceHP(attacker.hp)
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.typemod = Typemod.normal
    dmg = attacker.hp
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end
end

################################################################################
# Decreases the target's Attack and Special Attack by 2 stages each.
# User faints (even if effect does nothing). (Memento)
################################################################################
class PokeBattle_Move_0E2 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if opponent.pbCanReduceAnyStat?(PBStats::Offensive, attacker, self, showMessage: true)
      amount = -2
      opponent.pbChangeStats(PBStats::Offensive, amount, attacker, self)
    end
    # User still faints even if the stat reduction is prevented by Mist or an ability.
    attacker.pbReduceHP(attacker.hp)
  end
end

################################################################################
# User faints.  The Pokémon that replaces the user is fully healed (HP and
# status).  Fails if user won't be replaced. (Healing Wish)
################################################################################
class PokeBattle_Move_0E3 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !@battle.pbCanChooseNonActive?(attacker.index)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbReduceHP(attacker.hp)
    attacker.effects[:HealingWish] = true
    attacker.pbFaint if attacker.isFainted?
  end
end

################################################################################
# User faints.  The Pokémon that replaces the user is fully healed (HP, PP and
# status).  Fails if user won't be replaced. (Lunar Dance)
################################################################################
class PokeBattle_Move_0E4 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !@battle.pbCanChooseNonActive?(attacker.index)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbReduceHP(attacker.hp)
    attacker.effects[:LunarDance] = true
    attacker.pbFaint if attacker.isFainted?
  end
end

################################################################################
# All current battlers will perish after 3 more rounds. (Perish Song)
################################################################################
class PokeBattle_Move_0E5 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    successproc = proc { |attacker, opponent| opponent.effects[:PerishSong] < 1 }
    return pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.pbDisplay(_INTL("All Pokémon that heard the song will faint in three turns!"))
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:PerishSong] = 4
    opponent.effects[:PerishSongUser] = attacker.index
  end
end

################################################################################
# If user is KO'd before it next moves, the attack that caused it loses all PP. (Grudge)
################################################################################
class PokeBattle_Move_0E6 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Grudge] = true
    @battle.pbDisplay(_INTL("{1} wants its target to bear a grudge!", attacker.pbThis))
  end
end

################################################################################
# If user is KO'd before it next moves, the battler that caused it also faints. (Destiny Bond)
################################################################################
class PokeBattle_Move_0E7 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.lastRegularMoveUsed == :DESTINYBOND && attacker.effects[:DestinyRate] == true && @battle.FE != :HAUNTED
      attacker.effects[:DestinyRate] = false
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    else
      attacker.effects[:DestinyRate] = true
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:DestinyBond] = true
    @battle.pbDisplay(_INTL("{1} is hoping to take its attacker down with it!", attacker.pbThis))
  end
end

################################################################################
# If user would be KO'd this round, it survives with 1HP instead. (Endure)
################################################################################
class PokeBattle_Move_0E8 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !PBStuff::RATESHARERS.include?(attacker.lastRegularMoveUsed)
      attacker.effects[:ProtectRate] = 0
    end
    if attacker.movingLast?
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if @battle.pbRandom(3 ** attacker.effects[:ProtectRate]) != 0
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Endure] = true
    attacker.effects[:ProtectRate] += 1
    @battle.pbDisplay(_INTL("{1} braced itself!", attacker.pbThis))
  end
end

################################################################################
# If target would be KO'd by this attack, it survives with 1HP instead. (False Swipe)
################################################################################
class PokeBattle_Move_0E9 < PokeBattle_Move
  # Handled in superclass, do not edit!
end

################################################################################
# User flees from battle.  Fails in trainer battles. (Gen 7 Teleport)
################################################################################
class PokeBattle_Move_0EA < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if @battle.opponent || !@battle.pbCanRun?(attacker.index)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    pbSEPlay("escape", 100)
    @battle.pbDisplay(_INTL("{1} fled from battle!", attacker.pbThis))
    @battle.decision = 3
  end
end

################################################################################
# Target flees from battle. In trainer battles, target switches out instead.
# Fails if target is a higher level than the user. For status moves. (Roar / Whirlwind)
################################################################################
class PokeBattle_Move_0EB < PokeBattle_Move
  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if @move == :ROAR && @battle.FE == :SWAMP
      @battle.pbDisplay(_INTL("What are ya doin' in my swamp?!"))
    end
    super
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if @move == :ROAR
      if @battle.FE == :COLOSSEUM
        return attacker.pbCanIncreaseStatStage?(PBStats::ATTACK, attacker, self, showMessage: showMessage)
      end
      if @battle.ProgressiveFieldCheck(PBFields::CONCERT)
        # Roar on Concert field succeeds if either the attack increase can happen or the opponent can be switched out
        return true if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK, attacker, self, showMessage: showMessage)
      end
    end
    return attacker.canForceSwitchOpponent?(opponent, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if @move == :ROAR && (@battle.FE == :COLOSSEUM || @battle.ProgressiveFieldCheck(PBFields::CONCERT))
      attacker.pbChangeStats(PBStats::ATTACK, 2, attacker, self, abilitycheck: :hide)
    end
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if @move == :ROAR
      if @battle.FE == :COLOSSEUM
        @battle.pbDisplay(_INTL("{1} stands their ground in the arena!!", opponent.pbThis))
        return
      end
      if @battle.ProgressiveFieldCheck(PBFields::CONCERT)
        return unless attacker.canForceSwitchOpponent?(opponent, showMessage: true)
      end
    end
    if !@battle.opponent && !@battle.battlers.any? { |battler| battler.isbossmon || battler.issosmon}
      @battle.decision = 3 # Set decision to escaped
    else
      opponent.vanished = true
      if attacker.isbossmon && (Rejuv && attacker.pokemon.bossID == :M31YVELTAL) && @move == :WHIRLWIND
        opponent.userSwitch = :BossEffect
      else
        opponent.forcedSwitch = true
      end
    end
  end
end

################################################################################
# Target flees from battle.  In trainer battles, target switches out instead.
# Fails if target is a higher level than the user.  For damaging moves. (Dragon Tail / Circle Throw)
################################################################################
class PokeBattle_Move_0EC < PokeBattle_Move
  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    @battle.pbCommonAnimation("Fade in", opponent, nil) if hitnum > 0
    super
    opponent.vanished = true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if !attacker.isFainted? && !opponent.isFainted? &&
       !opponent.damagestate.substitute &&
       attacker.canForceSwitchOpponent?(opponent) &&
       @battle.FE != :COLOSSEUM
      if !@battle.opponent && !@battle.battlers.any? { |battler| battler.isbossmon || battler.issosmon}
        @battle.decision = 3
      else
        opponent.forcedSwitch = true
      end
    else
      opponent.vanished = false
      @battle.pbCommonAnimation("Fade in", opponent, nil)
    end
  end
end

################################################################################
# User switches out.  Various effects affecting the user are passed to the
# replacement. (Baton Pass)
################################################################################
class PokeBattle_Move_0ED < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !attacker.canTriggerUserSwitch?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.vanished = true
    attacker.carryOutUserSwitch(:BatonPass)
  end
end

################################################################################
# After inflicting damage, user switches out. Ignores trapping moves.
# (U-turn, Volt Switch, Flip Turn)
################################################################################
class PokeBattle_Move_0EE < PokeBattle_Move
  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    @battle.pbCommonAnimation("Fade in", attacker, nil) if hitnum > 0
    attacker.vanished = true
    @battle.scene.pbDisableShadowTemp(attacker)
    super
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if !attacker.isFainted? && attacker.canTriggerUserSwitch?
      attacker.userSwitch = :Move
    else
      attacker.vanished = false
      @battle.pbCommonAnimation("Fade in", attacker, nil)
    end
  end
end

################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
# (Spider Web / Block / Mean Look)
################################################################################
class PokeBattle_Move_0EF < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.hasType?(:GHOST)
      @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.effects[:MeanLook] >= 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:MeanLook] = attacker.index
    @battle.pbDisplay(_INTL("{1} can no longer escape!", opponent.pbThis))
    if @move == :BLOCK && @battle.FE == :CROWD
      if opponent.pbChangeStats(PBStats::SPEED, -1, attacker, self, abilitycheck: :hide)
        @battle.pbDisplay(_INTL("{1} got caught in a lock!", opponent.pbThis))
      end
    end
    if Rejuv && @move == :SPIDERWEB && @battle.FE == :SWAMP
      opponent.effects[:SwampWeb] = attacker.index
    end
  end
end

################################################################################
# Target drops its item.  It regains the item at the end of the battle. (Knock Off)
################################################################################
class PokeBattle_Move_0F0 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    return damagemult if opponent.item.nil?
    return damagemult if @battle.pbIsUnlosableItem(opponent, opponent.item)
    return damagemult if attacker.isWildPokemon? && !attacker.isbossmon && !attacker.issosmon
    # Damage boost applies against Substitute and Sticky Hold anyway

    return damagemult * 1.5
  end

  def pbEffectTargetAfterMove(attacker, opponent, alltargets = nil)
    return if opponent.item.nil?
    return if @battle.pbIsUnlosableItem(opponent, opponent.item)
    return if attacker.isWildPokemon? && !attacker.isbossmon && !attacker.issosmon
    return if opponent.damagestate.substitute
    if opponent.ability == :STICKYHOLD && !opponent.moldbroken
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("{1}'s item cannot be removed!", opponent.pbThis))
      return
    end

    @battle.pbDisplay(_INTL("{1} knocked off {2}'s {3}!", attacker.pbThis, opponent.pbThis(true), getItemName(opponent.item)))
    opponent.removeItem
  end
end

################################################################################
# User steals the target's item, if the user has none itself. (Thief / Covet)
# Items stolen from wild Pokémon are kept after the battle.
################################################################################
class PokeBattle_Move_0F1 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg if @battle.FE != :BACKALLEY
    return basedmg if opponent.item.nil? || !attacker.item.nil?
    return basedmg if @battle.pbIsUnlosableItem(opponent, opponent.item)
    return basedmg if @battle.pbIsUnlosableItem(attacker, opponent.item)
    return basedmg if blockedBySubstitute?(attacker, opponent)
    return basedmg if attacker.isWildPokemon? && ((!attacker.isbossmon && !attacker.issosmon) || attacker.pokemon.bossID == :SHADOWDEN)
    return basedmg if opponent.ability == :STICKYHOLD && !opponent.moldbroken

    return basedmg * 2
  end

  def pbEffectTargetAfterMove(attacker, opponent, alltargets = nil)
    return if opponent.item.nil? || !attacker.item.nil?
    return if @battle.pbIsUnlosableItem(opponent, opponent.item)
    return if @battle.pbIsUnlosableItem(attacker, opponent.item)
    return if opponent.damagestate.substitute
    return if attacker.isWildPokemon? && ((!attacker.isbossmon && !attacker.issosmon) || attacker.pokemon.bossID == :SHADOWDEN)
    if opponent.ability == :STICKYHOLD && !opponent.moldbroken
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("{1}'s item cannot be removed!", opponent.pbThis))
      return
    end

    @battle.pbCommonAnimation("Covet", attacker, opponent)
    @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!", attacker.pbThis, opponent.pbThis(true), getItemName(opponent.item)))
    opponent.transferItem(attacker)
  end
end

################################################################################
# User and target swap items.  They remain swapped after the battle. (Trick / Switcheroo)
################################################################################
class PokeBattle_Move_0F2 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.isWildPokemon? && !attacker.isbossmon && !attacker.issosmon
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if attacker.item.nil? && opponent.item.nil?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if @battle.pbIsUnlosableItem(opponent, opponent.item) ||
       @battle.pbIsUnlosableItem(attacker, opponent.item) ||
       @battle.pbIsUnlosableItem(opponent, attacker.item) ||
       @battle.pbIsUnlosableItem(attacker, attacker.item)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if opponent.ability == :STICKYHOLD && !opponent.moldbroken
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("{1}'s item cannot be removed!", opponent.pbThis)) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    @battle.pbDisplay(_INTL("{1} switched items with its target!", attacker.pbThis))
    @battle.pbDisplay(_INTL("{1} obtained {2}.", attacker.pbThis, getItemName(opponent.item))) if opponent.item
    @battle.pbDisplay(_INTL("{1} obtained {2}.", opponent.pbThis, getItemName(attacker.item))) if attacker.item
    attacker.swapItems(opponent)

    if @battle.FE == :BACKALLEY
      if @move == :TRICK
        attacker.pbChangeStats(PBStats::SPATK, 1, attacker, self, abilitycheck: :hide) if opponent.pbChangeStats(PBStats::SPATK, -1, attacker, self, abilitycheck: :hide)
      elsif @move == :SWITCHEROO
        attacker.pbChangeStats(PBStats::ATTACK, 1, attacker, self, abilitycheck: :hide) if opponent.pbChangeStats(PBStats::ATTACK, -1, attacker, self, abilitycheck: :hide)
      end
    end
  end
end

################################################################################
# User gives its item to the target.  The item remains given after the battle. (Bestow)
################################################################################
class PokeBattle_Move_0F3 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if attacker.item.nil? || !opponent.item.nil?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if @battle.pbIsUnlosableItem(attacker, attacker.item) ||
       @battle.pbIsUnlosableItem(opponent, attacker.item)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    @battle.pbDisplay(_INTL("{1} gave {2} its {3}!", attacker.pbThis, opponent.pbThis(true), getItemName(attacker.item)))
    attacker.transferItem(opponent)
  end
end

################################################################################
# User consumes target's berry and gains its effect. (Bug Bite / Pluck)
################################################################################
class PokeBattle_Move_0F4 < PokeBattle_Move
  def pbEffectTargetAfterMove(attacker, opponent, alltargets = nil)
    return if opponent.item.nil?
    return if !pbIsBerry?(opponent.item)
    return if opponent.damagestate.substitute
    if opponent.ability == :STICKYHOLD && !opponent.moldbroken
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("{1}'s item cannot be removed!", opponent.pbThis))
      return
    end

    @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!", attacker.pbThis, getItemName(opponent.item)))
    item = opponent.removeItem(permanent: true)
    attacker.pbEatBerry(item)
    # Berry consumption is not affected by Magic Room, tested on canon games
  end
end

################################################################################
# Target's berry or gem is destroyed. (Incinerate)
################################################################################
class PokeBattle_Move_0F5 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if opponent.item.nil?
    return if !pbIsBerry?(opponent.item) && !pbIsTypeGem?(opponent.item)
    return if opponent.damagestate.substitute
    if opponent.ability == :STICKYHOLD && !opponent.moldbroken
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("{1}'s item cannot be removed!", opponent.pbThis))
      return
    end

    @battle.pbDisplay(_INTL("{1}'s {2} was burned up!", opponent.pbThis, getItemName(opponent.item)))
    opponent.removeItem(permanent: true)
  end
end

################################################################################
# User recovers the last item it held and consumed. (Recycle)
################################################################################
class PokeBattle_Move_0F6 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !attacker.item.nil? || attacker.permeffs[:ItemRecycle].nil?
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    item = attacker.permeffs[:ItemRecycle]
    attacker.permeffs[:ItemRecycle] = nil
    @battle.pbDisplay(_INTL("{1} found {2}!", attacker.pbThis, getItemName(item, :a)))
    attacker.obtainItem(item, recycled: true)

    if @battle.FE == :CITY
      stat = @battle.sample(PBStats::Omni)
      if attacker.pbChangeStats(stat, 1, attacker, self, abilitycheck: :hide)
        @battle.pbDisplay(_INTL("Reduce, reuse, recycle!"))
      end
    end
  end
end

################################################################################
# User flings its item at the target.  Power and effect depend on the item. (Fling)
################################################################################
class PokeBattle_Move_0F7 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.item.nil? || !attacker.itemWorks? || @battle.pbIsUnlosableItem(attacker, attacker.item) ||
        pbIsPokeBall?(attacker.item) || pbIsTypeGem?(attacker.item) || pbIsMail?(attacker.item) || pbIsApricorn?(attacker.item) ||
        pbFlingDamage(attacker.item) == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
    return 130 if @battle.FE == :CONCERT4
    return pbFlingDamage(attacker.item)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if !opponent.damagestate.substitute && (opponent.ability != :SHIELDDUST || opponent.moldbroken) && !opponent.hasWorkingItem(:COVERTCLOAK)
      if pbIsBerry?(attacker.item)
        opponent.pbEatBerry(attacker.item)
      end
      if attacker.hasWorkingItem(:FLAMEORB)
        if opponent.pbCanBurn?(attacker, self)
          opponent.pbBurn(attacker)
        end
      elsif attacker.hasWorkingItem(:KINGSROCK) ||
            attacker.hasWorkingItem(:RAZORFANG)
        if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
          opponent.effects[:Flinch] = true
        end
      elsif attacker.hasWorkingItem(:LIGHTBALL)
        if opponent.pbCanParalyze?(attacker, self)
          opponent.pbParalyze(attacker)
        end
      elsif attacker.hasWorkingItem(:POISONBARB)
        if opponent.pbCanPoison?(attacker, self)
          opponent.pbPoison(attacker)
        end
      elsif attacker.hasWorkingItem(:TOXICORB)
        if opponent.pbCanPoison?(attacker, self)
          opponent.pbPoison(attacker, true)
        end
      elsif attacker.hasWorkingItem(:MENTALHERB)
        opponent.triggerMentalHerb(true)
      elsif attacker.hasWorkingItem(:WHITEHERB)
        opponent.triggerWhiteHerb(true)
      elsif attacker.hasWorkingItem(:GIMMIGHOULCOIN)
        if @battle.pbOwnedByPlayer?(attacker.index)
          @battle.extramoney += 5 * attacker.level
          if [:BIGTOP, :DRAGONSDEN].include?(@battle.FE)
            @battle.extramoney += 495 * attacker.level
          end
          @battle.extramoney = MAXMONEY if @battle.extramoney > MAXMONEY
        end
        if @battle.FE == :DRAGONSDEN
          @battle.pbDisplay(_INTL("Treasure scattered everywhere!"))
        else
          @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
        end
      end
    end
  end

  def pbEffectAfterMove(attacker, alltargets, hitflags)
    # No early return because item should be flung away even if target protects, move misses, etc
    attacker.pbDisposeItem(burp: false, duringattack: true)
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = nil, alltargets = nil, showanimation = nil)
    @battle.pbDisplay(_INTL("{1} flung its {2}!", attacker.pbThis, getItemName(attacker.item)))
    super
  end
end

################################################################################
# For 5 rounds, the target can't use its held item, its held item has no
# effect, and no items can be used on it. (Embargo)
################################################################################
class PokeBattle_Move_0F8 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.effects[:Embargo] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Embargo] = 5
    @battle.pbDisplay(_INTL("{1} can't use items anymore!", opponent.pbThis))
  end
end

################################################################################
# For 5 rounds, all held items cannot be used in any way and have no effect.
# Held items can still change hands, but can't be thrown. (Magic Room)
################################################################################
class PokeBattle_Move_0F9 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.state.effects[:MagicRoom] > 0
      @battle.pbDisplay(_INTL("{1} wore off, and held items' effects returned to normal!", @name))
      @battle.state.effects[:MagicRoom] = 0
    else
      @battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
      duration = 5
      duration = 8 if [:NEWWORLD, :PSYTERRAIN].include?(@battle.FE) || attacker.hasWorkingItem(:AMPLIFIELDROCK) || (Rejuv && @battle.FE == :STARLIGHT)
      duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
      @battle.state.effects[:MagicRoom] = duration
    end
  end
end

################################################################################
# User switches places with its ally. (Ally Switch)
################################################################################
class PokeBattle_Move_0FC < PokeBattle_Move
  def pbOnStartUse(user, targets)
    if user.lastRegularMoveUsed != :ALLYSWITCH
      user.effects[:AllySwitchRate] = 0
    end

    fail = false
    if Gen >= 9
      # In Gen 9 Ally Switch automatically fails if used twice in the same round and also has an increasing chance to fail if used consecutively.
      fail = user.pbOwnSide.effects[:AllySwitch] || @battle.pbRandom(3 ** user.effects[:AllySwitchRate]) != 0
    end

    if !@battle.doublebattle || user.pbPartner.isFainted? || fail ||
       user.pbPartner.effects[:SkyDrop] || user.pbPartner.effects[:SkyDroppee] ||
       @battle.pbGetOwner(user.index) != @battle.pbGetOwner(user.pbPartner.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      user.effects[:AllySwitchRate] = 0
      return false
    end

    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.swapBattlers(attacker.index, attacker.pbPartner.index) # Handles animation too

    if @battle.FE == :CHESS && !attacker.pbOwnSide.effects[:Castled]
      @battle.pbDisplay(_INTL("O-O-O!")) if [0, 3].include?(attacker.index)
      @battle.pbDisplay(_INTL("O-O!")) if [1, 2].include?(attacker.index)
      attacker.pbChangeStats(PBStats::Defensive, 1, attacker, self, abilitycheck: :hide)
      attacker.pbPartner.pbChangeStats(PBStats::Offensive, 1, attacker, self, abilitycheck: :hide)
      attacker.pbOwnSide.effects[:Castled] = true
      @battle.pbDisplay(_INTL("{1} castled with {2}!", attacker.pbThis, attacker.pbPartner.name))
    else
      @battle.pbDisplay(_INTL("{1} and {2} switched places!", attacker.pbThis, attacker.pbPartner.name))
    end

    attacker.pbOwnSide.effects[:AllySwitch] = !attacker.pbOwnSide.effects[:AllySwitch]
    attacker.effects[:AllySwitchRate] += 1
  end
end

################################################################################
# Starts snow. (Snowscape)
################################################################################
class PokeBattle_Move_0FE < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return @battle.canSetWeather?(:SNOW, showMessage: showMessage)
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    id = :HAIL # Use Hail animation
    super
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = attacker.hasWorkingItem(:ICYROCK) || [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION, :SKY, :CLOUDS].include?(@battle.FE) ? 8 : 5
    duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
    @battle.pbSetWeather(:SNOW, duration)
  end
end

################################################################################
# Starts sunny weather. (Sunny Day)
################################################################################
class PokeBattle_Move_0FF < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return @battle.canSetWeather?(:SUNNYDAY, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = attacker.hasWorkingItem(:HEATROCK) || [:DESERT, :MOUNTAIN, :SNOWYMOUNTAIN, :SKY].include?(@battle.FE) ? 8 : 5
    duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
    @battle.pbSetWeather(:SUNNYDAY, duration)
  end
end

################################################################################
# Starts rainy weather. (Rain Dance)
################################################################################
class PokeBattle_Move_100 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return @battle.canSetWeather?(:RAINDANCE, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = attacker.hasWorkingItem(:DAMPROCK) || [:CLOUDS, :SKY].include?(@battle.FE) ? 8 : 5
    duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
    @battle.pbSetWeather(:RAINDANCE, duration)
  end
end

################################################################################
# Starts sandstorm weather. (Sandstorm)
################################################################################
class PokeBattle_Move_101 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return @battle.canSetWeather?(:SANDSTORM, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = attacker.hasWorkingItem(:SMOOTHROCK) || [:DESERT, :ASHENBEACH, :SKY].include?(@battle.FE) ? 8 : 5
    duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
    @battle.pbSetWeather(:SANDSTORM, duration)
  end
end

################################################################################
# Starts hail weather. (Hail)
################################################################################
class PokeBattle_Move_102 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return @battle.canSetWeather?(:HAIL, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = attacker.hasWorkingItem(:ICYROCK) || [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION, :SKY, :CLOUDS].include?(@battle.FE) ? 8 : 5
    @battle.pbSetWeather(:HAIL, duration)
  end
end

################################################################################
# Entry hazard.  Lays spikes on the opposing side (max. 3 layers). (Spikes / Ceaseless Edge)
################################################################################
class PokeBattle_Move_103 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    if attacker.pbOpposingSide.effects[:Spikes] >= 3
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @basedamage > 0
    attacker.pbOpposingSide.effects[:Spikes] += 1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Spikes were scattered on the ground all around the opposing team!"))
    else
      @battle.pbDisplay(_INTL("Spikes were scattered on the ground all around your team!"))
    end
  end

  def pbAdditionalEffect(attacker, opponent)
    return unless attacker.pbOpposingSide.effects[:Spikes] < 3
    return if [:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE)
    attacker.pbOpposingSide.effects[:Spikes] += 1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Spikes were scattered on the ground all around the opposing team!"))
    else
      @battle.pbDisplay(_INTL("Spikes were scattered on the ground all around your team!"))
    end
  end
end

################################################################################
# Entry hazard.  Lays poison spikes on the opposing side (max. 2 layers). (Toxic Spikes)
################################################################################
class PokeBattle_Move_104 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    if attacker.pbOpposingSide.effects[:ToxicSpikes] >= 2
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @basedamage > 0
    attacker.pbOpposingSide.effects[:ToxicSpikes] += 1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Poison spikes were scattered on the ground all around the opposing team!"))
    else
      @battle.pbDisplay(_INTL("Poison spikes were scattered on the ground all around your team!"))
    end
  end
end

################################################################################
# Entry hazard.  Lays stealth rocks on the opposing side. (Stealth Rock / Stone Axe)
################################################################################
class PokeBattle_Move_105 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    return true if attacker.effects[:MagicBounced]
    return true if @battle.FE != :CLOUDS
    if showMessage
      if !attacker.pbOwnSide.effects[:StealthRock]
        @battle.pbDisplay(_INTL("...But the clouds bounced the pointed stones back!"))
        attacker.pbOwnSide.effects[:StealthRock] = true
        if @battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("Pointed stones float in the air around the opposing team!"))
        else
          @battle.pbDisplay(_INTL("Pointed stones float in the air around your team!"))
        end
      else
        @battle.pbDisplay(_INTL("But it failed!"))
      end
    end
    return false
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    if attacker.pbOpposingSide.effects[:StealthRock]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @basedamage > 0
    attacker.pbOpposingSide.effects[:StealthRock] = true
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Pointed stones float in the air around the opposing team!"))
    else
      @battle.pbDisplay(_INTL("Pointed stones float in the air around your team!"))
    end
  end

  def pbAdditionalEffect(attacker, opponent)
    return if attacker.pbOpposingSide.effects[:StealthRock]
    attacker.pbOpposingSide.effects[:StealthRock] = true
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Pointed stones float in the air around the opposing team!"))
    else
      @battle.pbDisplay(_INTL("Pointed stones float in the air around your team!"))
    end
  end
end

################################################################################
# If used after ally's Fire Pledge, makes a sea of fire on the opposing side. (Grass Pledge)
################################################################################
class PokeBattle_Move_106 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    return unless @battle.canChangeFE?
    duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 7 : 4
    @battle.setPledge(@move, duration)
  end
end

################################################################################
# If used after ally's Water Pledge, makes a rainbow appear on the user's side. (Fire Pledge)
################################################################################
class PokeBattle_Move_107 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    return unless @battle.canChangeFE?
    duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 7 : 4
    @battle.setPledge(@move, duration)
  end
end

################################################################################
# If used after ally's Grass Pledge, makes a swamp appear on the opposing side. (Water Pledge)
################################################################################
class PokeBattle_Move_108 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    return unless @battle.canChangeFE?
    duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 7 : 4
    @battle.setPledge(@move, duration)
  end
end

################################################################################
# Scatters coins that the player picks up after winning the battle. (Pay Day)
################################################################################
class PokeBattle_Move_109 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    return if hitnum != 0
    if @battle.pbOwnedByPlayer?(attacker.index)
      @battle.extramoney += 5 * attacker.level
      if [:BIGTOP, :DRAGONSDEN].include?(@battle.FE)
        @battle.extramoney += 495 * attacker.level
      end
      @battle.extramoney = MAXMONEY if @battle.extramoney > MAXMONEY
    end
    if @battle.FE == :DRAGONSDEN
      @battle.pbDisplay(_INTL("Treasure scattered everywhere!"))
    else
      @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
    end
  end
end

################################################################################
# Ends the opposing side's Light Screen and Reflect. (Brick Break / Psychic Fangs)
################################################################################
class PokeBattle_Move_10A < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    @battle.pbEndSideEffects(opponent.pbOwnSide, PBStuff::SCREENEFFECTS.values)
  end
end

################################################################################
# If attack misses, user takes crash damage of 1/2 of max HP. (High Jump Kick / Jump Kick / Supercell Slam)
################################################################################
class PokeBattle_Move_10B < PokeBattle_Move
end

################################################################################
# User turns 1/4 of max HP into a substitute. (Substitute)
################################################################################
class PokeBattle_Move_10C < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.effects[:Substitute] > 0
      @battle.pbDisplay(_INTL("{1} already has a substitute!", attacker.pbThis)) if showMessage
      return false
    end
    sublife = [(attacker.totalhp / 4.0).floor, 1].max
    if attacker.hp <= sublife
      @battle.pbDisplay(_INTL("But it does not have enough HP left to make a substitute!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    sublife = [(attacker.totalhp / 4.0).floor, 1].max
    attacker.pbReduceHP(sublife, false, false) # late message
    attacker.pbBerryHerbCheck
    attacker.effects[:MultiTurn] = 0
    attacker.effects[:MultiTurnAttack] = 0
    attacker.effects[:Substitute] = sublife
    @battle.pbDisplay(_INTL("{1} put in a substitute!", attacker.pbThis))
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    @battle.pbPlaySubstituteAnimation(attacker) if showanimation
  end
end

################################################################################
# User is not Ghost: Decreases user's Speed, increases user's Attack & Defense by
# 1 stage each. (Curse)
# User is Ghost: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
################################################################################
class PokeBattle_Move_10D < PokeBattle_Move
  # Bulbapedia's claim that non-Ghost Curse fails if there are no opponents on the field
  # is either completely wrong or really outdated. Has been tested on Gen 7/8 cartridges
  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.hasType?(:GHOST)
      super
    else
      @battle.pbCommonAnimation("CurseNoGhost", attacker, nil)
    end
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if attacker.hasType?(:GHOST)
    lowerspeed = attacker.pbCanReduceStatStage?(PBStats::SPEED, attacker, self)
    raiseatk = attacker.pbCanIncreaseStatStage?(PBStats::ATTACK, attacker, self)
    raisedef = attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE, attacker, self)
    if !lowerspeed && !raiseatk && !raisedef
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    return true if !attacker.hasType?(:GHOST)
    if opponent.effects[:Curse]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if attacker.hasType?(:GHOST)
    stats = [PBStats::SPEED, PBStats::ATTACK, PBStats::DEFENSE]
    amounts = [-1, 1, 1]
    attacker.pbChangeStats(stats, amounts, attacker, self)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if !attacker.hasType?(:GHOST)
    hplost = (attacker.totalhp / 2.0).floor
    hplost = (attacker.totalhp / 4.0).floor if @battle.FE == :HAUNTED

    @battle.pbDisplay(_INTL("{1} cut its own HP and put a curse on {2}!", attacker.pbThis, opponent.pbThis(true)))
    attacker.pbReduceHP(hplost, false, false) # early message
    opponent.effects[:Curse] = true
    attacker.pbBerryHerbCheck
  end
end

################################################################################
# Target's last move used loses 4 PP. (Spite)
################################################################################
class PokeBattle_Move_10E < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.moves.none? {|i| i && i.move == opponent.lastMoveUsed && i.pp > 0}
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    for i in opponent.moves
      if i && i.move == opponent.lastMoveUsed && i.pp > 0
        drop = 4
        drop = 6 if @battle.FE == :HAUNTED
        reduction = [drop, i.pp].min
        opponent.pbSetPP(i, i.pp - reduction)
        @battle.pbDisplay(_INTL("{1} lost {2} PP from {3}!", opponent.pbThis, reduction, i.name))
        return
      end
    end
  end
end

################################################################################
# Target will lose 1/4 of max HP at end of each round, while asleep. (Nightmare)
################################################################################
class PokeBattle_Move_10F < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if (!opponent.isSleeping? && @battle.FE != :INFERNAL &&
       @battle.pbCheckSideAbility(:WORLDOFNIGHTMARES, opponent.pbOpposing1).none?) ||
       opponent.effects[:Nightmare] || blockedBySubstitute?(attacker, opponent)
     @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
     return false
   end
   return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Nightmare] = true
    opponent.effects[:MeanLook] = attacker.index if attacker.ability == :WORLDOFNIGHTMARES
    @battle.pbDisplay(_INTL("{1} began having a nightmare!", opponent.pbThis))
  end
end

################################################################################
# Removes trapping moves, entry hazards and Leech Seed on user/user's side. (Rapid Spin)
################################################################################
class PokeBattle_Move_110 < PokeBattle_Move
  # Till Gen 7 the move has no "additional effects", wrap/leech/hazard removal is just considered a normal effect
  # Both speed raise and wrap/leech/hazard removal are "additional effects" since Gen 8
  def pbAdditionalEffectSelf(attacker)
    attacker.pbChangeStats(PBStats::SPEED, 1, attacker, self, abilitycheck: :hide)
  end

  def pbEffectAfterMove(attacker, alltargets, hitflags)
    return if (attacker.isFaintedAndNoShields? && Gen < Champs) || ![:Success, :StatusSuccess].intersect?(hitflags)
    return if attacker.ability == :SHEERFORCE && Gen > 7

    attacker.spinAwayEffects
  end
end

################################################################################
# Attacks 2 rounds in the future. (Future Sight / Doom Desire)
################################################################################
class PokeBattle_Move_111 < PokeBattle_Move
  def pbShortUseMove(attacker, opponent)
    return :FailedMove if !pbOnStartUse(attacker, [opponent])
    revanish = false
    if opponent.vanished && opponent.effects[:TwoTurnAttack] != 0
      @battle.scene.pbUnVanishSprite(opponent)
      revanish = true
    end
    pbShowAnimation(@move, attacker, opponent, 0, [opponent], true)
    pbEffectTarget(attacker, opponent, 0, [opponent])
    if revanish
      @battle.pbCommonAnimation("Fade out", opponent, nil)
      @battle.scene.pbVanishSprite(opponent)
    end
    return :FutureSight
  end

  def pbOnStartUse(attacker, targets)
    targets.each do |opponent|
      next if opponent.effects[:FutureSight] > 0
      return true
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return false
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:FutureSight] = 3
    opponent.effects[:FutureSightMove] = @move
    opponent.effects[:FutureSightUserIndex] = attacker.index
    opponent.effects[:FutureSightPokemon] = attacker.pokemon
    if @move == :FUTURESIGHT
      @battle.pbDisplay(_INTL("{1} foresaw an attack!", attacker.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} chose {2} as its destiny!", attacker.pbThis, @name))
    end
  end
end

################################################################################
# Increases user's Defense and Special Defense by 1 stage each.  Ups user's
# stockpile by 1 (max. 3).
################################################################################
class PokeBattle_Move_112 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.effects[:Stockpile] >= 3
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbAddStockpile(self)
  end
end

################################################################################
# Power is multiplied by the user's stockpile (X).  Reduces the stockpile to 0.
# Decreases user's Defense and Special Defense by X stages each. (Spit Up)
################################################################################
class PokeBattle_Move_113 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.effects[:Stockpile] == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
    return 300 if @battle.FE == :CONCERT4

    return 100 * attacker.effects[:Stockpile]
  end

  def pbEffectAfterMove(attacker, alltargets, hitflags)
    return if attacker.isFaintedAndNoShields? # No success condition because stockpile effect should wear off even if move misses, target protects, etc

    attacker.pbRemoveStockpile(self)
  end
end

################################################################################
# Heals user depending on the user's stockpile (X).  Reduces the stockpile to 0.
# Decreases user's Defense and Special Defense by X stages each. (Swallow)
################################################################################
class PokeBattle_Move_114 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.effects[:Stockpile] == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    hpgain = 0
    case attacker.effects[:Stockpile]
      when 1
        hpgain = (attacker.totalhp * 0.25).round
        hpgain = (attacker.totalhp * 0.5).round if @battle.FE == :WASTELAND
      when 2
        hpgain = (attacker.totalhp * 0.5).round
        hpgain = attacker.totalhp if @battle.FE == :WASTELAND
      when 3
        hpgain = attacker.totalhp
    end

    if @battle.FE == :WASTELAND && attacker.effects[:Stockpile] == 3
      attacker.pbCureStatus
    end
    attacker.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", attacker.pbThis), fullrecover: hpgain == attacker.totalhp)
    attacker.pbRemoveStockpile(self)
  end
end

#################################################################################
# Fails if user was hit by a damaging move this round. (Focus Punch)
################################################################################
class PokeBattle_Move_115 < PokeBattle_Move
  # handled in pbTryUseMove
  # do not remove this function code
end

################################################################################
# Fails if the target didn't chose a damaging move to use this round, or has
# already moved. (Sucker Punch / Thunderclap)
################################################################################
class PokeBattle_Move_116 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    targets.each do |opponent|
      next if opponent.hasMovedThisRound?
      next if opponent.effects[:HyperBeam] > 0
      next if @battle.switchedOut[opponent.index]
      next if opponent.itemUsed
      next if [nil, 0, -1].include?(@battle.choices[opponent.index][2])
      next if @battle.choices[opponent.index][2].pbIsStatus?
      return true
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return false
  end
end

################################################################################
# This round, user becomes the target of attacks that have single targets.
# (Follow Me, Rage Powder)
################################################################################
class PokeBattle_Move_117 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !@battle.doublebattle
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if @move == :RAGEPOWDER
      attacker.effects[:RagePowder] = true
      if !attacker.pbPartner.isFainted?
        attacker.pbPartner.effects[:FollowMe] = false
        attacker.pbPartner.effects[:RagePowder] = false
      end
    else
      attacker.effects[:FollowMe] = true
      if !attacker.pbPartner.isFainted?
        attacker.pbPartner.effects[:FollowMe] = false
        attacker.pbPartner.effects[:RagePowder] = false
      end
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!", attacker.pbThis))
    return 0
  end
end

################################################################################
# For 5 rounds, increases gravity on the field.  Pokémon cannot become airborne. (Gravity)
################################################################################
class PokeBattle_Move_118 < PokeBattle_Move
  def pbIsPhysical?(attacker, type = @type)
    return @battle.FE == :DEEPEARTH
  end

  def pbIsStatus?
    return @battle.FE != :DEEPEARTH
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    return true if @battle.FE == :DEEPEARTH
    if @battle.state.effects[:Gravity] != 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return super unless @battle.FE == :DEEPEARTH
    opponent.damagestate.typemod = Typemod.normal
    dmg = (opponent.hp / 2.0).floor
    dmg = applyTradePowerForAcc(dmg, attacker, opponent)
    return dmg
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @battle.FE == :DEEPEARTH
    @battle.pbDisplay(_INTL("Gravity intensified!"))
    duration = 5
    duration = 8 if attacker.hasWorkingItem(:AMPLIFIELDROCK) || @battle.FE == :PSYTERRAIN
    duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
    @battle.pbSetGravity(duration)
  end
end

################################################################################
# For 5 rounds, user becomes airborne. (Magnet Rise)
################################################################################
class PokeBattle_Move_119 < PokeBattle_Move
  def unusableInGravity?
    return @battle.FE != :DEEPEARTH
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if @battle.FE == :DEEPEARTH
      return attacker.pbCanIncreaseStatStage?(PBStats::SPEED, attacker, self, showMessage: showMessage)
    end
    if opponent.effects[:Ingrain] || opponent.effects[:SmackDown] || opponent.effects[:MagnetRise] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if @battle.FE != :DEEPEARTH
      duration = [:ELECTERRAIN, :FACTORY, :SHORTCIRCUIT].include?(@battle.FE) || @battle.OV == :ELECTERRAIN ? 8 : 5
      attacker.effects[:MagnetRise] = duration
      @battle.pbDisplay(_INTL("{1} levitated with electromagnetism!", attacker.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} uses electromagnetism to move faster!", attacker.pbThis))
      attacker.pbChangeStats(PBStats::SPEED, 2, attacker, self, abilitycheck: :skip)
    end
  end
end

################################################################################
# For 3 rounds, target becomes airborne and can always be hit. (Telekinesis)
################################################################################
class PokeBattle_Move_11A < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.effects[:Ingrain] || opponent.effects[:SmackDown] || opponent.effects[:Telekinesis] > 0 ||
       [:DIGLETT, :DUGTRIO, :SANDYGAST, :PALOSSAND, :WIGLETT].include?(opponent.species) || (opponent.species == :GENGAR && opponent.form == 1)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Telekinesis] = 3
    @battle.pbDisplay(_INTL("{1} was hurled into the air!", opponent.pbThis))
    if @battle.FE == :PSYTERRAIN
      opponent.pbChangeStats(PBStats::Defensive, -2, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# Hits airborne semi-invulnerable targets.
################################################################################
class PokeBattle_Move_11B < PokeBattle_Move
  # Handled in Battler class, do not edit!
end

################################################################################
# Grounds the target while it remains active. (Smack Down, Thousand Arrows)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_11C < PokeBattle_Move
  def pbEffectTargetAfterMove(attacker, opponent, alltargets = nil)
    return if opponent.isFaintedAndNoShields?
    return if opponent.damagestate.substitute
    return unless opponent.isAirborne? || PBStuff::TWOTURNAIRMOVE.include?(opponent.effects[:TwoTurnAttack])
    return if opponent.effects[:SkyDrop] || opponent.effects[:SkyDroppee] # smack down specifically doesn't ground targets locked in sky drop

    opponent.effects[:SmackDown] = true
    opponent.effects[:TwoTurnAttack] = 0 if PBStuff::TWOTURNAIRMOVE.include?(opponent.effects[:TwoTurnAttack]) # Fly, Bounce
    opponent.effects[:MagnetRise] = 0 if opponent.effects[:MagnetRise] > 0
    opponent.effects[:Telekinesis] = 0 if opponent.effects[:Telekinesis] > 0
    @battle.pbDisplay(_INTL("{1} fell straight down!", opponent.pbThis))
  end
end

################################################################################
# Target moves immediately after the user, ignoring priority/speed. (After You)
################################################################################
class PokeBattle_Move_11D < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.acted?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:AfterYou] = true
    @battle.setActPrioData
    @battle.pbDisplay(_INTL("{1} took the kind offer!", opponent.pbThis))
  end
end

################################################################################
# Target moves last this round, ignoring priority/speed. (Quash)
################################################################################
class PokeBattle_Move_11E < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.acted?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Quash] = true
    @battle.setActPrioData
    @battle.pbDisplay(_INTL("{1}'s move was postponed!", opponent.pbThis))
  end
end

################################################################################
# For 5 rounds, for each priority bracket, slow Pokémon move before fast ones. (Trick Room)
################################################################################
class PokeBattle_Move_11F < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.state.effects[:TrickRoom] == 0
      @battle.pbDisplay(_INTL("{1} twisted the dimensions!", attacker.pbThis))
      duration = 5
      duration = 8 if [:CHESS, :NEWWORLD, :PSYTERRAIN].include?(@battle.FE) || attacker.hasWorkingItem(:AMPLIFIELDROCK) || (Rejuv && @battle.FE == :STARLIGHT)
      duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
      @battle.pbSetTrickRoom(duration)
    else
      @battle.pbDisplay(_INTL("The twisted dimensions returned to normal!", attacker.pbThis))
      @battle.state.effects[:TrickRoom] = 0
    end
  end
end

################################################################################
# User switches places with its ally in party. (Gen 8 Teleport)
################################################################################
class PokeBattle_Move_120 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !attacker.canTriggerUserSwitch?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.userSwitch = :Move
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    attacker.vanished = true
    @battle.scene.pbDisableShadowTemp(attacker)
    super
  end
end

################################################################################
# Target's attacking stat is used instead of user's for this move's calculations.
# (Foul Play)
################################################################################
class PokeBattle_Move_121 < PokeBattle_Move
  # Handled in superclass, do not edit!
end

################################################################################
# Target's defense stat opposite to the move's category is used for this move's
# calculations. (Psyshock / Psystrike / Secret Sword)
################################################################################
class PokeBattle_Move_122 < PokeBattle_Move
  # Handled in superclass, do not edit!
end

################################################################################
# Only damages Pokémon that share a type with the user. (Synchronoise)
################################################################################
class PokeBattle_Move_123 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    unless opponent.types.intersect?(attacker.types)
      @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    return true
  end
end

################################################################################
# For 5 rounds, swaps all battlers' base Defense with base Special Defense. (Wonder Room)
################################################################################
class PokeBattle_Move_124 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.state.effects[:WonderRoom] == 0
      @battle.pbDisplay(_INTL("It created a bizarre area in which {1} and {2} stats are swapped!", getStatName(PBStats::DEFENSE), getStatName(PBStats::SPDEF)))
      duration = 5
      duration = 8 if [:NEWWORLD, :PSYTERRAIN].include?(@battle.FE) || attacker.hasWorkingItem(:AMPLIFIELDROCK) || (Rejuv && @battle.FE == :STARLIGHT)
      duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
      @battle.pbSetWonderRoom(duration)
    else
      @battle.pbDisplay(_INTL("{1} wore off, and the {2} and {3} stats returned to normal!", @name, getStatName(PBStats::DEFENSE), getStatName(PBStats::SPDEF)))
      @battle.pbEndWonderRoom
    end
  end
end

################################################################################
# Fails unless user has already used all other moves it knows. (Last Resort)
################################################################################
class PokeBattle_Move_125 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !attacker.canLastResort?
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end
end

#===============================================================================
# NOTE: Shadow moves use function codes 126-132 inclusive.  If you're inventing
#       new move effects, use function code 133 and onwards.
#===============================================================================

################################################################################
# 133- King's Shield
################################################################################
class PokeBattle_Move_133 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !PBStuff::RATESHARERS.include?(attacker.lastRegularMoveUsed)
      attacker.effects[:ProtectRate] = 0
    end
    if attacker.movingLast?
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if @battle.pbRandom(3 ** attacker.effects[:ProtectRate]) != 0
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Protect] = :KingsShield
    attacker.effects[:ProtectRate] += 1
    @battle.pbDisplay(_INTL("{1} protected itself!", attacker.pbThis))
  end
end

################################################################################
# 134- Electric Terrain
################################################################################
class PokeBattle_Move_134 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return @battle.canChangeFE?(:ELECTERRAIN, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 8 : 5
    @battle.setField(:ELECTERRAIN, duration, nil)
  end
end

################################################################################
# 135- Grassy Terrain
################################################################################
class PokeBattle_Move_135 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return @battle.canChangeFE?(:GRASSY, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 8 : 5
    duration = 8 if Overlays && [:FOREST, :BEWITCHED].include?(@battle.FE)
    @battle.setField(:GRASSY, duration, nil)
  end
end

################################################################################
# 136- Misty Terrain
################################################################################
class PokeBattle_Move_136 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return @battle.canChangeFE?(:MISTY, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 8 : 5
    @battle.setField(:MISTY, duration, nil)
  end
end

################################################################################
# Decreases the target's Attack and Special Attack by 1 stage each. (Noble Roar/Tearful Look)
################################################################################
class PokeBattle_Move_138 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return opponent.pbCanReduceAnyStat?(PBStats::Offensive, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    amount = [:FAIRYTALE, :DRAGONSDEN].include?(@battle.FE) && @move == :NOBLEROAR ? -2 : -1
    opponent.pbChangeStats(PBStats::Offensive, amount, attacker, self)
  end
end

################################################################################
# User gains 75% of the HP it inflicts as damage. (Draining Kiss/Oblivion Wing)
################################################################################
class PokeBattle_Move_139 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    damage = opponent.lastHPLost
    if damage > 0 && !opponent.damagestate.disguise
      hpgain = (damage * 0.75).round
      attacker.absorbHP(hpgain, opponent, :HPDrainingMove, self)
    end
    if @battle.FE == :FAIRYTALE && @move == :DRAININGKISS
      if !opponent.damagestate.substitute && opponent.status == :SLEEP
        opponent.pbCureStatus
      end
    end
    if @move == :OBLIVIONWING && [:DEUXFINALIS, :DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE)
      if opponent.pbCanPetrify?(attacker, self)
        opponent.pbPetrify(attacker)
      end
    end
  end
end

################################################################################
# Spiky Shield
################################################################################
class PokeBattle_Move_140 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !PBStuff::RATESHARERS.include?(attacker.lastRegularMoveUsed)
      attacker.effects[:ProtectRate] = 0
    end
    if attacker.movingLast?
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if @battle.pbRandom(3 ** attacker.effects[:ProtectRate]) != 0
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Protect] = :SpikyShield
    attacker.effects[:ProtectRate] += 1
    @battle.pbDisplay(_INTL("{1} protected itself!", attacker.pbThis))
  end
end

################################################################################
# Increases the target's Special Defense by 1 stage. (Aromatic Mist)
################################################################################
class PokeBattle_Move_13A < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    return true if @battle.doublebattle
    @battle.pbDisplay(_INTL("But it failed!"))
    return false
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return opponent.pbCanIncreaseStatStage?(PBStats::SPDEF, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    statchange = @battle.FE == :MISTY ? 2 : 1
    opponent.pbChangeStats(PBStats::SPDEF, statchange, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Decreases the target's Special Attack by 2 stages. (Eerie Impulse)
################################################################################
class PokeBattle_Move_13B < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return opponent.pbCanReduceStatStage?(PBStats::SPATK, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    amount = [:ELECTERRAIN, :DEEPEARTH].include?(@battle.FE) ? -3 : -2
    opponent.pbChangeStats(PBStats::SPATK, amount, attacker, self, abilitycheck: :skip)
  end
end

################################################################################
# Belch
################################################################################
class PokeBattle_Move_13C < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    return true if attacker.permeffs[:Belch] || attacker.crested == :SWALOT
    @battle.pbDisplay(_INTL("{1} hasn't eaten any held Berries, so it can't possibly belch!", attacker.pbThis))
    return false
  end
end

##################################################################
# After lowering stats, user switches out. (Parting Shot)
##################################################################
class PokeBattle_Move_13D < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    stats = PBStats::Offensive
    stats += [PBStats::SPEED] if @battle.FE == :FROZENDIMENSION
    return opponent.pbCanReduceAnyStat?(stats, attacker, self, showMessage: showMessage)
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    attacker.vanished = true
    @battle.scene.pbDisableShadowTemp(attacker)
    super
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    stats = PBStats::Offensive
    stats += [PBStats::SPEED] if @battle.FE == :FROZENDIMENSION
    amount = -1
    amount = -2 if @battle.ProgressiveFieldCheck(PBFields::CONCERT) || @battle.FE == :BACKALLEY
    opponent.pbChangeStats(stats, amount, attacker, self)
    if attacker.canTriggerUserSwitch?
      attacker.userSwitch = :Move
    else
      attacker.vanished = false
      @battle.pbCommonAnimation("Fade in", attacker, nil)
    end
  end
end

##################################################################
# Skips first turn, boosts Sp.Atk, Sp.Def and Speed on the second. (Geomancy)
##################################################################
class PokeBattle_Move_13E < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      if [:STARLIGHT, :DEEPEARTH].include?(@battle.FE)
        @immediate = true
      end
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if attacker.effects[:TwoTurnAttack] == 0
      attacker.pbChangeStats([PBStats::SPATK, PBStats::SPDEF, PBStats::SPEED], 2, attacker, self)
    end
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} is absorbing power!", attacker.pbThis))
      @battle.pbCommonAnimation("Geomancy", attacker)
    else
      super
    end
  end
end

##################################################################
# Decreases a poisoned target's Attack, Sp.Atk and Speed by 1 stage. (Venom Drench)
##################################################################
class PokeBattle_Move_13F < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if opponent.status != :POISON && ![:CORROSIVE, :CORROSIVEMIST, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE)
      @battle.pbDisplay(_INTL("But it failed!", opponent.pbThis)) if showMessage
      return false
    end
    return opponent.pbCanReduceAnyStat?([PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED], attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbChangeStats([PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED], -1, attacker, self)
  end
end

################################################################################
# Entry hazard.  Puts down a sticky web that lowers speed. (Sticky Web)
################################################################################
class PokeBattle_Move_141 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return true if @basedamage > 0
    if attacker.pbOpposingSide.effects[:StickyWeb]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if @basedamage > 0
    attacker.pbOpposingSide.effects[:StickyWeb] = attacker.pokemon
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("A sticky web has been laid out on the ground around the opposing team!"))
    else
      @battle.pbDisplay(_INTL("A sticky web has been laid out on the ground around your team!"))
    end
  end
end

################################################################################
# User inverts the target's stat stages. (Topsy-Turvy)
################################################################################
class PokeBattle_Move_142 < PokeBattle_Move
  def pbIsPhysical?(attacker, type = @type)
    return @battle.FE == :DEEPEARTH
  end

  def pbIsStatus?
    return @battle.FE != :DEEPEARTH
  end

  def antiMinimize?
    return @battle.FE == :DEEPEARTH
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return super unless @battle.FE == :DEEPEARTH
    return [attacker.happiness, 250].min if attacker.crested == :LUVDISC

    weight = opponent.weight
    return 120 if weight >= 2000
    return 100 if weight >= 1000
    return 80 if weight >= 500
    return 60 if weight >= 250
    return 40 if weight >= 100
    return 20
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    PBStats::All.each { |i| opponent.stages[i] = -opponent.stages[i] }
    @battle.pbDisplay(_INTL("All stat changes on {1} were inverted!", opponent.pbThis(true)))
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if !Rejuv && !attacker.hasWorkingItem(:EVERSTONE) && @battle.canChangeFE?
      duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 6 : 3
      message = _INTL("The terrain was inverted!")
      @battle.setField(:INVERSE, duration, message)
    end
  end
end

################################################################################
# Makes the target Grass Type (Forest's Curse)
################################################################################
class PokeBattle_Move_143 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if !opponent.canChangeType? || opponent.hasType?(:GRASS)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:TemporaryType] = :GRASS
    @battle.pbDisplay(_INTL("{1} type was added to {2}!", getTypeName(:GRASS), opponent.pbThis(true)))
    if [:FOREST, :FAIRYTALE, :BEWITCHED].include?(@battle.FE)
      if !opponent.effects[:Curse]
        opponent.effects[:Curse] = true
        @battle.pbDisplay(_INTL("{1} put a curse on {2}!", attacker.pbThis, opponent.pbThis(true)))
      end
    end
  end
end

################################################################################
# Makes the target Ghost Type- (Trick Or Treat)
################################################################################
class PokeBattle_Move_144 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if !opponent.canChangeType? || opponent.hasType?(:GHOST)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:TemporaryType] = :GHOST
    @battle.pbDisplay(_INTL("{1} type was added to {2}!", getTypeName(:GHOST), opponent.pbThis(true)))
  end
end

################################################################################
# All active Pokemon can no longer switch out or flee during the next turn. (Fairy Lock)
################################################################################
class PokeBattle_Move_145 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if @battle.state.effects[:FairyLock] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.state.effects[:FairyLock] = 2
    @battle.pbDisplay(_INTL("No one will be able to run away during the next turn!"))
  end
end

################################################################################
# If the user or any allies have Plus or Minus as their ability, raise their
#   Defense and Special Defense by one stage. (Magnetic Flux)
################################################################################
class PokeBattle_Move_146 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    successproc = proc { |attacker, opponent|
      ([:PLUS, :MINUS].include?(opponent.ability) || [:PLUSLE, :MINUN].include?(opponent.crested) || (Rejuv && @battle.FE == :ELECTERRAIN)) &&
      opponent.pbCanIncreaseAnyStat?(PBStats::Defensive, attacker, self)
    }
    return pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    amount = 1
    amount = 2 if @battle.FE == :DEEPEARTH || (Rejuv && @battle.FE == :ELECTERRAIN && [:PLUS, :MINUS].include?(opponent.ability))
    opponent.pbChangeStats(PBStats::Defensive, amount, attacker, self)
  end
end

################################################################################
# If the opponent dies, increase attack by 3 stages (Fell Stinger)
################################################################################
class PokeBattle_Move_147 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if opponent.isFainted?
      attacker.pbChangeStats(PBStats::ATTACK, 3, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# Ion Deluge
################################################################################
class PokeBattle_Move_148 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if @battle.state.effects[:IonDeluge] == true
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
    @battle.state.effects[:IonDeluge] = true
    if !attacker.hasWorkingItem(:EVERSTONE) && @battle.canChangeFE?(:ELECTERRAIN)
      duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 6 : 3
      @battle.setField(:ELECTERRAIN, duration, nil)
    end
  end
end

################################################################################
# Crafty Shield
################################################################################
class PokeBattle_Move_149 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !PBStuff::RATESHARERS.include?(attacker.lastRegularMoveUsed)
      attacker.effects[:ProtectRate] = 0
    end
    if attacker.movingLast?
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:CraftyShield] = true
    attacker.effects[:ProtectRate] += 1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("{1} protected your team!", @name))
    else
      @battle.pbDisplay(_INTL("{1} protected the opposing team!", @name))
    end
    if @battle.FE == :FAIRYTALE
      if attacker.pbCanIncreaseAnyStat?(PBStats::Defensive, attacker, self)
        @battle.pbDisplay(_INTL("{1} boosted its defenses with the shield!", attacker.pbThis))
        attacker.pbChangeStats(PBStats::Defensive, 1, attacker, self, abilitycheck: :hide)
      end
    end
  end
end

################################################################################
# Flower Shield
################################################################################
class PokeBattle_Move_150 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    successproc = proc { |attacker, opponent|
      next false unless opponent.hasType?(:GRASS) || (opponent == attacker && (@battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5) || @battle.FE == :FAIRYTALE))
      if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5) || (opponent == attacker && @battle.FE == :FAIRYTALE)
        next opponent.pbCanIncreaseAnyStat?(PBStats::Defensive, attacker, self)
      else
        next opponent.pbCanIncreaseStatStage?(PBStats::DEFENSE, attacker, self)
      end
    }
    return pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    stats = PBStats::DEFENSE
    stats = PBStats::Defensive if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5) || (opponent == attacker && @battle.FE == :FAIRYTALE)
    amount = @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5) ? 2 : 1
    abilitycheck = stats == PBStats::DEFENSE ? :skip : :show
    opponent.pbChangeStats(stats, amount, attacker, self, abilitycheck: abilitycheck)
  end
end

################################################################################
# Boosts Attack and Sp. Atk of all Grass-types Pokémon in the field (Rototiller)
################################################################################
class PokeBattle_Move_151 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    successproc = proc { |attacker, opponent|
      next false unless (opponent.hasType?(:GRASS) && !opponent.isAirborne?) || (opponent == attacker && @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN))
      next opponent.pbCanIncreaseAnyStat?(PBStats::Offensive, attacker, self)
    }
    return pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    amount = 1
    amount = 2 if @battle.FE == :DEEPEARTH || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN)
    opponent.pbChangeStats(PBStats::Offensive, amount, attacker, self)
  end
end

################################################################################
# Powder
################################################################################
class PokeBattle_Move_152 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.effects[:Powder]
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    @battle.pbDisplay(_INTL("{1} is covered in powder!", opponent.pbThis))
    opponent.effects[:Powder] = true
  end
end

################################################################################
# Next move used by the target becomes Electric-type (Electrify)
################################################################################
class PokeBattle_Move_153 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.effects[:Electrify] || opponent.acted?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Electrify] = true
    @battle.pbDisplay(_INTL("{1}'s moves have been electrified!", opponent.pbThis))
    if Rejuv && @battle.FE == :ELECTERRAIN && opponent.canChangeType?
      opponent.type1 = :ELECTRIC
      opponent.type2 = nil
      typename = getTypeName(:ELECTRIC)
      @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", opponent.pbThis, typename))
    end
  end
end

################################################################################
# Mat Block
################################################################################
class PokeBattle_Move_154 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.turncount != 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if attacker.pbOwnSide.effects[:MatBlock]
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:MatBlock] = true
    @battle.pbDisplay(_INTL("{1} intends to flip up a mat and block incoming attacks!", attacker.pbThis))
  end
end

################################################################################
# Traps the target but isn't affected by Sheer Force. (Thousand Waves)
################################################################################
class PokeBattle_Move_155 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return if opponent.hp <= 0 || opponent.effects[:MeanLook] != -1 || blockedBySubstitute?(attacker, opponent) || opponent.hasType?(:GHOST)
    opponent.effects[:MeanLook] = attacker.index
    @battle.pbDisplay(_INTL("{1} can no longer escape!", opponent.pbThis))
  end
end

################################################################################
# Traps the target, affected by Sheer Force. (Spirit Shackle, Anchor Shot)
################################################################################
class PokeBattle_Move_156 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    return if opponent.hp <= 0 || opponent.effects[:MeanLook] != -1 || blockedBySubstitute?(attacker, opponent) || opponent.hasType?(:GHOST)
    opponent.effects[:MeanLook] = attacker.index
    @battle.pbDisplay(_INTL("{1} can no longer escape!", opponent.pbThis))
  end
end

###############################################################################
# Always hits, ignores protection, and lowers defense. Cannot be used by
# any Pokemon other than Hoopa-Unbound. (Hyperspace Fury)
###############################################################################
class PokeBattle_Move_159 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    return true if Rejuv && attacker.species == :GARDEVOIR && attacker.form == 3 # Angel of Death
    return true if attacker.species == :HOOPA && attacker.form == 1 # Hoopa Unbound

    if attacker.species == :HOOPA # hoopa not in unbound form
      @battle.pbDisplay(_INTL("{1} can't use it the way it is now!", attacker.pbThis))
    else # any other pokemon
      @battle.pbDisplay(_INTL("But {1} can't use the move!", attacker.pbThis(true)))
    end
    return false
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Protect] = nil
    opponent.pbOwnSide.resetProtect
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::DEFENSE, -1, attacker, self, abilitycheck: :hide)
  end
end

############################################################################################################
# For 5 rounds if hailing, lowers power of physical & special attacks against the user's side. (Aurora Veil)
############################################################################################################
class PokeBattle_Move_15B < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    return true if [:DARKCRYSTALCAVERN, :RAINBOW, :ICY, :CRYSTALCAVERN, :SNOWYMOUNTAIN, :MIRROR, :STARLIGHT, :FROZENDIMENSION].include?(@battle.FE)
    return true if [:HAIL, :SNOW].include?(@battle.pbWeather(attacker))
    @battle.pbDisplay(_INTL("But it failed!"))
    return false
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.pbOwnSide.effects[:AuroraVeil] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:AuroraVeil] = 5
    attacker.pbOwnSide.effects[:AuroraVeil] = 8 if attacker.hasWorkingItem(:LIGHTCLAY)
    attacker.pbOwnSide.effects[:AuroraVeil] = 8 if @battle.FE == :MIRROR
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("{1} made your team stronger against physical and special moves!", getMoveName(:AURORAVEIL)))
    else
      @battle.pbDisplay(_INTL("{1} made the opposing team stronger against physical and special moves!", getMoveName(:AURORAVEIL)))
    end
    if @battle.FE == :MIRROR
      attacker.pbChangeStats(PBStats::EVASION, 1, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# Baneful Bunker
################################################################################
class PokeBattle_Move_15C < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !PBStuff::RATESHARERS.include?(attacker.lastRegularMoveUsed)
      attacker.effects[:ProtectRate] = 0
    end
    if attacker.movingLast?
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if @battle.pbRandom(3 ** attacker.effects[:ProtectRate]) != 0
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Protect] = :BanefulBunker
    attacker.effects[:ProtectRate] += 1
    @battle.pbDisplay(_INTL("{1} shielded itself against damage!", attacker.pbThis))
  end
end

################################################################################
# Beak Blast
################################################################################
class PokeBattle_Move_15D < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:BeakBlast] = false
  end
end

################################################################################
# Burn Up
################################################################################
class PokeBattle_Move_15E < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !attacker.hasType?(:FIRE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffectAfterMove(attacker, alltargets, hitflags)
    return if attacker.isFaintedAndNoShields? || ![:Success, :StatusSuccess].intersect?(hitflags)
    return if !attacker.canChangeType?

    attacker.effects[:BurnUp] = true
    if attacker.type1 == :FIRE
      if attacker.type2.nil?
        attacker.type1 = :QMARKS
      else
        attacker.type1 = attacker.type2
      end
    end
    if attacker.type2 == :FIRE
      attacker.type2 = nil
    end
    @battle.pbDisplay(_INTL("{1} burned itself out!", attacker.pbThis))
  end
end

################################################################################
# Decreases the user's Defense by 1 stage. (Clanging Scales)
################################################################################
class PokeBattle_Move_15F < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if ![:DEUXFINALIS].include?(@battle.FE)
      attacker.pbChangeStats(PBStats::DEFENSE, -1, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# Core Enforcer
################################################################################
class PokeBattle_Move_160 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if opponent.hasMovedThisRound? && !@battle.switchedOut[opponent.index]
      if !PBStuff::FIXEDABILITIES.include?(opponent.ability) && !opponent.hasWorkingItem(:ABILITYSHIELD) && !opponent.effects[:GastroAcid]
        message = _INTL("{1}'s Ability was suppressed!", opponent.pbThis)
        opponent.changeAbilityWithEffects(:suppress, message: message)
        opponent.effects[:GastroAcid] = true
      end
    end
  end
end

################################################################################
# Fails if this isn't the user's first turn. (First Impression)
################################################################################
class PokeBattle_Move_161 < PokeBattle_Move
  def canProtect?
    return false if @battle.FE == :COLOSSEUM
    return super
  end

  def pbOnStartUse(attacker, targets)
    if attacker.turncount != 1 || !attacker.isFirstMoveOfRound
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end
end

################################################################################
# Heals target by an amount depending on the terrain. (Floral Healing)
################################################################################
class PokeBattle_Move_162 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.effects[:HealBlock] > 0 || (opponent.status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, opponent).none? && opponent.crested != :SUICUNE)
      @battle.pbDisplay(_INTL("{1} was prevented from healing!", opponent.pbThis)) if showMessage
      return false
    end
    if opponent.hp == opponent.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", opponent.pbThis)) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if [:GRASSY, :FAIRYTALE].include?(@battle.FE) ||
       @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5) # Grassy Terrain, Fairytale Field, Flower Garden Field
      hpgain = opponent.totalhp
    else
      hpgain = (opponent.totalhp * 0.5).round
    end
    opponent.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", opponent.pbThis))
    if [:CORROSIVE, :CORROSIVEMIST].include?(@battle.FE) # Corrosive/Corrosive Mist Field
      if opponent.pbCanPoison?(attacker, self)
        opponent.pbPoison(attacker)
      end
    end
  end
end

################################################################################
# If the any allies have Plus or Minus as their ability, raise their
#   Attack and Special Attack by one stage. (Gear Up)
################################################################################
class PokeBattle_Move_163 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    successproc = proc { |attacker, opponent|
      [:PLUS, :MINUS].include?(opponent.ability) &&
      opponent.pbCanIncreaseAnyStat?(PBStats::Offensive, attacker, self)
    }
    return pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    amount = @battle.FE == :FACTORY ? 2 : 1
    opponent.pbChangeStats(PBStats::Offensive, amount, attacker, self)
  end
end

################################################################################
# Instruct
################################################################################
class PokeBattle_Move_164 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    otherid = opponent.lastMoveUsed
    choice = opponent.lastMoveChoice # This is needed because it should target the same opponent as before, and use the same moveslot.
    begin
      if !choice || choice[1] < 0 || !choice[2] || opponent.moves[choice[1]].move != choice[2].move || choice[2].move != otherid ||
         PBStuff::BLACKLISTS[:INSTRUCT].include?(otherid) || choice[2].zmove || PBStuff::DELAYEDMOVE.include?(@battle.choices[opponent.index][2].move)
        @battle.pbDisplay(_INTL("But it failed!")) if showMessage
        return false
      end
    rescue
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    choice = opponent.lastMoveChoice # This is needed because it should target the same opponent as before, and use the same moveslot.
    @battle.pbDisplay(_INTL("{1} followed {2}'s instructions!", opponent.pbThis, attacker.pbThis(true)))
    opponent.pbUseMove(choice, { instructed: true, specialusage: false }) # TODO: test whether specialusage should be true or false.
  end
end

################################################################################
# Ensures the next hit is critical. (Laser Focus)
################################################################################
class PokeBattle_Move_165 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:LaserFocus] = 2
    @battle.pbDisplay(_INTL("{1} concentrated intensely!", attacker.pbThis))
  end
end

################################################################################
# Moldbreaking moves (Sunsteel Strike/Moongeist Beam)
################################################################################
class PokeBattle_Move_166 < PokeBattle_Move
  # handled elsewhere
end

################################################################################
# Pollen Puff
################################################################################
class PokeBattle_Move_167 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return true if opponent != attacker.pbPartner

    if opponent.effects[:HealBlock] > 0 || (opponent.status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, opponent).none? && opponent.crested != :SUICUNE)
      @battle.pbDisplay(_INTL("{1} was prevented from healing!", opponent.pbThis)) if showMessage
      return false
    end
    if opponent.hp == opponent.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", opponent.pbThis)) if showMessage
      return false
    end

    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    return unless attacker.pbPartner == opponent

    hpgain = (opponent.totalhp * 0.5).round
    opponent.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", opponent.pbThis))
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if opponent == attacker.pbPartner
    return super
  end
end

################################################################################
# Psychic Terrain
################################################################################
class PokeBattle_Move_168 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return @battle.canChangeFE?(:PSYTERRAIN, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 8 : 5
    @battle.setField(:PSYTERRAIN, duration, nil)
  end
end

################################################################################
# Heals target by 1/2 of its max HP & removes status conditions. (Purify)
################################################################################
class PokeBattle_Move_169 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if @battle.FE == :DEUXFINALIS
      if opponent.status.nil? && attacker.hp == attacker.totalhp
        @battle.pbDisplay(_INTL("But it failed!")) if showMessage
        return false
      end
    else
      if blockedBySubstitute?(attacker, opponent)
        @battle.pbDisplay(_INTL("But it failed!")) if showMessage
        return false
      end
      if opponent.status.nil?
        @battle.pbDisplay(_INTL("But it failed!")) if showMessage
        return false
      end
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if !opponent.status.nil?
      opponent.pbCureStatus
      if attacker.pbCanIncreaseAnyStat?([PBStats::DEFENSE, PBStats::SPDEF], attacker, self)
        stats, amounts = [PBStats::DEFENSE, PBStats::SPDEF], [1, 1]
        attacker.pbChangeStats(stats, amounts, attacker, self)
      end
    end
    if attacker.hp != attacker.totalhp
      hpgain = (attacker.totalhp / 2.0).floor
      attacker.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", attacker.pbThis))
    end
  end
end

################################################################################
# Type depends on the user's. (Revelation Dance)
################################################################################
class PokeBattle_Move_16A < PokeBattle_Move
  def pbType(attacker, type = @type)
    type = attacker.type1
    return super
  end
end

#################################################################################
# Shell Trap
################################################################################
class PokeBattle_Move_16B < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    # if the shell trap effect is still on the user when the move should be used then no one triggered the trap, the move fails
    if !attacker.effects[:ShellTrapAttacked]
      attacker.effects[:ShellTrap] = false
      @battle.pbDisplay(_INTL("{1}'s shell trap didn't work!", attacker.pbThis))
      return false
    end
    return true
  end
end

################################################################################
# Heals user by an amount depending on the weather. (Shore Up)
################################################################################
class PokeBattle_Move_16C < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return true unless attacker.hp == attacker.totalhp

    @battle.pbDisplay(_INTL("{1}'s HP is full!", attacker.pbThis)) if showMessage
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.FE == :ASHENBEACH
      hpgain = attacker.totalhp
    elsif @battle.pbWeather(attacker) == :SANDSTORM || @battle.FE == :DESERT
      hpgain = (attacker.totalhp * 0.667).pokeRound
    else
      hpgain = (attacker.totalhp / 2.0).pokeRound
    end
    attacker.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", attacker.pbThis))
    if [:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE) && attacker.ability == :WATERCOMPACTION
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE, attacker, nil)
        @battle.pbShowAbilityBox(attacker)
        attacker.pbChangeStats(PBStats::DEFENSE, 2, attacker, nil, abilitycheck: :skip)
        @battle.pbHideAbilityBox(attacker)
      end
    end
  end
end

################################################################################
# Cures the target's burn (Sparkling Aria)
################################################################################
class PokeBattle_Move_16D < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    opponent.pbCureStatus if opponent.status == :BURN
  end
end

################################################################################
# Spectral Thief.
################################################################################
class PokeBattle_Move_16E < PokeBattle_Move
  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    stolen = false
    totalboost = 0
    for i in PBStats::All
      if opponent.stages[i] > 0
        oppboost = opponent.stages[i]
        oppboost *= 2 if attacker.ability == :SIMPLE
        oppboost *= -1 if attacker.ability == :CONTRARY
        initial = attacker.stages[i]
        attacker.stages[i] += oppboost
        attacker.stages[i] = attacker.stages[i].clamp(-6, 6)
        totalboost += attacker.stages[i] - initial
        opponent.stages[i] = 0
        stolen = true
      end
    end
    @battle.pbDisplay(_INTL("{1} stole the target's boosted stats!", attacker.pbThis)) if stolen
    if totalboost > 0
      @battle.pbCommonAnimation("StatUp", attacker, nil)
    elsif totalboost < 0
      @battle.pbCommonAnimation("StatDown", attacker, nil)
    end
    return super
  end
end

################################################################################
# Swaps the user's & target's speeds (Speed Swap)
################################################################################
class PokeBattle_Move_16F < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    aSwap = attacker.effects[:SpeedSwap]
    oSwap = opponent.effects[:SpeedSwap]
    if oSwap == 0
      attacker.effects[:SpeedSwap] = opponent.speed
    else
      attacker.effects[:SpeedSwap] = oSwap
    end
    if aSwap == 0
      opponent.effects[:SpeedSwap] = attacker.speed
    else
      opponent.effects[:SpeedSwap] = aSwap
    end
    @battle.pbDisplay(_INTL("{1} switched {2} with its target!", attacker.pbThis, getStatName(PBStats::SPEED)))
  end
end

################################################################################
# This round, target becomes the target of attacks that have single targets. (Spotlight)
################################################################################
class PokeBattle_Move_170 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !@battle.doublebattle
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:FollowMe] = true
    if !opponent.pbPartner.isFainted?
      opponent.pbPartner.effects[:FollowMe] = false
      opponent.pbPartner.effects[:RagePowder] = false
    end
    if @battle.FE == :BIGTOP
      attacker.pbChangeStats(PBStats::Offensive, 1, attacker, self, abilitycheck: :hide)
      opponent.pbChangeStats(PBStats::Offensive, 1, attacker, self, abilitycheck: :hide)
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!", opponent.pbThis))
  end
end

################################################################################
# Power is doubled if the user's previous move failed (Stomping Tantrum / Temper Flare)
################################################################################
class PokeBattle_Move_171 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    if attacker.effects[:Tantrum]
      return basedmg * 2
    end

    return basedmg
  end
end

################################################################################
# Strength Sap
################################################################################
class PokeBattle_Move_172 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.pbTooLow?(PBStats::ATTACK)
    # Strength Sap fails only if opponent is at -6 Attack, not if at +6 with Contrary or protected by Mist
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    statstage = opponent.stages[PBStats::ATTACK]
    hpgain = opponent.attack * PBStats::StageMul[statstage + 6]

    stats = @battle.FE == :BEWITCHED ? PBStats::Offensive : PBStats::ATTACK
    opponent.pbChangeStats(stats, -1, attacker, self)

    attacker.absorbHP(hpgain, opponent, :StrengthSap, self)
  end
end

################################################################################
# Throat Chop
################################################################################
class PokeBattle_Move_173 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    opponent.effects[:ThroatChop] = 2 if !opponent.damagestate.substitute
  end
end

################################################################################
# Toxic Thread
################################################################################
class PokeBattle_Move_174 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if opponent.pbCanReduceStatStage?(PBStats::SPEED, attacker, self) || opponent.pbCanPoison?(attacker, self)
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    amount = Gen >= Champs ? -2 : -1
    opponent.pbChangeStats(PBStats::SPEED, amount, attacker, self, abilitycheck: :hide)
    return if !opponent.pbCanPoison?(attacker, self)
    opponent.pbPoison(attacker, @battle.FE == :CORRUPTED)
  end
end

################################################################################
# User loses half their max HP after attacking (Mind Blown/Steel Beam)
################################################################################
class PokeBattle_Move_175 < PokeBattle_Move
  def getRecoil(attacker, damage, recoilmult, hitflags)
    return 0 unless hitflags.any?
    return 0 if @battle.magicGuardAbilities.include?(attacker.ability)
    recoilmult = 0.5 # the recoil multiplier cannot be given to this move as a move attribute as the attribute is also used to check for Reckless
    recoilmult = 0.25 if @battle.FE == :FACTORY && @move == :STEELBEAM
    recoilmult = 1.0 if @battle.FE == :SHORTCIRCUIT && @move == :STEELBEAM
    return (attacker.totalhp * recoilmult).round
  end

  def inflictRecoil(attacker, recoil, hitflags)
    recoil = attacker.pbReduceHP(recoil)
    return recoil
  end
end

################################################################################
# Photon Geyser
################################################################################
class PokeBattle_Move_176 < PokeBattle_Move
  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if @move == :LIGHTTHATBURNSTHESKY && @battle.ProgressiveFieldCheck(PBFields::DARKNESS, 2, 3)
      @battle.pbDisplay(_INTL("One brings Shadow, One brings the Light!"))
    end
    super
  end

  # smartdamage category overrule glitch
  def pbIsPhysical?(attacker, type = @type)
    return @category == :physical
  end

  def pbIsSpecial?(attacker, type = @type)
    return @category == :special
  end

  def pbOnStartUse(attacker, targets)
    moldBrokenArray = [0, 1, 2, 3].map { |index| @battle.battlers[index].moldbroken }
    @category = self.smartDamageCategory(attacker, nil, moldBrokenArray: moldBrokenArray)
    return true
  end
end

################################################################################
# Plasma Fists
################################################################################
class PokeBattle_Move_177 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.state.effects[:IonDeluge] != true
      @battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
      @battle.state.effects[:IonDeluge] = true
    end
    if !attacker.hasWorkingItem(:EVERSTONE) && @battle.canChangeFE?(:ELECTERRAIN)
      duration = attacker.hasWorkingItem(:AMPLIFIELDROCK) ? 6 : 3
      @battle.setField(:ELECTERRAIN, duration, nil)
    end
  end
end

# New Gen 8 effects starting below here

################################################################################
# Extra Damage against Dynamax (Dynamax Cannon, Behemoth Blade, Behemoth Bash)
################################################################################
class PokeBattle_Move_178 < PokeBattle_Move
  # no extra effect because we don't have dynamax
end

################################################################################
# Ignores any redirection attempts (Snipe Shot)
################################################################################
class PokeBattle_Move_179 < PokeBattle_Move
  # handled in pbChangeTarget
end

################################################################################
# Eats Berry and then Sharply Raises Defense (Stuff Cheeks)
################################################################################
class PokeBattle_Move_17A < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.item.nil? || !pbIsBerry?(attacker.item)
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::DEFENSE, 2, attacker, self)
    attacker.pbEatBerry(animation: false)
    # Berry consumption is not affected by Magic Room, tested on canon games
  end
end

################################################################################
# Boosts all stats and prevents switching out (No Retreat)
################################################################################
class PokeBattle_Move_17B < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.effects[:NoRetreat]
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if [:BIGTOP, :CHESS].include?(@battle.FE)
    return attacker.pbCanIncreaseAnyStat?(PBStats::Omni, attacker, self, showMessage: showMessage)
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    return true unless [:BIGTOP, :CHESS].include?(@battle.FE)
    if attacker.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED], attacker, self) || attacker.pbCanReduceAnyStat?(PBStats::Defensive, attacker, self)
      return true
    end
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if [:BIGTOP, :CHESS].include?(@battle.FE)
      stats = [PBStats::DEFENSE, PBStats::SPDEF, PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED]
      amounts = [-1, -1, 2, 2, 2]
      attacker.pbChangeStats(stats, amounts, attacker, self)
    else
      stats = PBStats::Omni
      amount = @battle.FE == :COLOSSEUM ? 2 : 1
      attacker.pbChangeStats(stats, amount, attacker, self)
    end
    if attacker.effects[:MeanLook] == -1
      # This flag is intentionally always set even if the user is a ghost type. It becomes unable to switch when Soaked.
      attacker.effects[:MeanLook] = attacker.index
      @battle.pbDisplay(_INTL("{1} can no longer escape because it used {2}!", attacker.pbThis, @name))
      attacker.effects[:NoRetreat] = true
    end
  end
end

################################################################################
# Lowers Speed and Forces Fire Weakness (Tar Shot)
################################################################################
class PokeBattle_Move_17C < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.effects[:TarShot] == true && !opponent.pbCanReduceStatStage?(PBStats::SPEED, attacker, self)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbChangeStats(PBStats::SPEED, -1, attacker, self)
    if opponent.effects[:TarShot] == false
      opponent.effects[:TarShot] = true
      @battle.pbDisplay(_INTL("{1} became weaker to fire!", opponent.pbThis))
    end
    if [:MURKWATERSURFACE, :CORRUPTED].include?(@battle.FE)
      if opponent.pbCanPoison?(attacker, self)
        opponent.pbPoison(attacker)
      end
    end
  end
end

################################################################################
# Target becomes Psychic type. (Magic Powder)
################################################################################
class PokeBattle_Move_17D < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if !opponent.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if opponent.types(excludeReflector: true) == [:PSYCHIC] && !(@battle.FE == :FAIRYTALE)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if opponent.types(excludeReflector: true).sort == [:FAIRY, :PSYCHIC] && @battle.FE == :FAIRYTALE
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if @battle.FE == :FAIRYTALE
      opponent.changeType(:PSYCHIC, :FAIRY)
      @battle.pbDisplay(_INTL("{1} became {2}/{3} type!", opponent.pbThis, getTypeName(:PSYCHIC), getTypeName(:FAIRY)))
    else
      opponent.changeType(:PSYCHIC)
      @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", opponent.pbThis, getTypeName(:PSYCHIC)))
    end
    if [:HAUNTED, :BEWITCHED].include?(@battle.FE) && opponent.pbCanSleep?(attacker, self)
      opponent.pbSleep(message: _INTL("{1} was put to sleep!", opponent.pbThis))
    end
  end
end

################################################################################
# Dragon Darts (Dragon Darts)
################################################################################
class PokeBattle_Move_17E < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    # Dragon Darts always acts like a 2 hit move, even when targeting multiple targes, it just spreads those moves onto different targets
    return 2
  end
end

################################################################################
# All pokemon eat their berries (Teatime)
################################################################################
class PokeBattle_Move_17F < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    successproc = proc { |attacker, opponent| opponent.item && pbIsBerry?(opponent.item) }
    return pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbEatBerry
    # Berry consumption is not affected by Magic Room, tested on canon games
  end
end

################################################################################
# Traps target and lowers defenses every turn (Octolock)
################################################################################
class PokeBattle_Move_180 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if opponent.hasType?(:GHOST)
      @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if opponent.effects[:Octolock] >= 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Octolock] = attacker.index
    @battle.pbDisplay(_INTL("{1} can no longer escape because of the {2}!", opponent.pbThis, @name))
  end
end

################################################################################
# Double Damage if this pokemon moves before target (Fishious Rend, Bolt Beak)
################################################################################
class PokeBattle_Move_181 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    if !opponent.hasMovedThisRound? || @battle.switchedOut[opponent.index]
      return basedmg * 2
    end

    return basedmg
  end
end

################################################################################
# Swaps effects between the sides of the field (Court Change)
################################################################################
class PokeBattle_Move_182 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    for i in [:LightScreen, :Reflect, :AuroraVeil, :AreniteWall, :Mist, :Safeguard, :Tailwind, :StickyWeb, :StealthRock, :Spikes, :ToxicSpikes, :LuckyChant, :AntiMatterShield]
      attSideEff = attacker.pbOwnSide.effects[i]
      oppSideEff = attacker.pbOpposingSide.effects[i]
      attacker.pbOwnSide.effects[i] = oppSideEff
      attacker.pbOpposingSide.effects[i] = attSideEff
    end
    @battle.pbDisplay(_INTL("{1} swapped the battle effects affecting each side of the field!", attacker.pbThis))
  end
end

################################################################################
# Cuts HP to boost every stat (Clangorous Soul)
################################################################################
class PokeBattle_Move_183 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    clanglife = [(attacker.totalhp / 3.0).floor, 1].max
    clanglife = [(attacker.totalhp / 2.0).floor, 1].max if [:BIGTOP, :DRAGONSDEN].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::CONCERT)
    clanglife = [(attacker.totalhp / 4.0).floor, 1].max if @battle.FE == :DEUXFINALIS
    if attacker.hp <= clanglife
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?(PBStats::Omni, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    stats = PBStats::Omni
    amount = 1
    amount = 2 if [:BIGTOP, :DRAGONSDEN].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::CONCERT)
    attacker.pbChangeStats(stats, amount, attacker, self)
    clanglife = [(attacker.totalhp / 3.0).floor, 1].max
    clanglife = [(attacker.totalhp / 4.0).floor, 1].max if @battle.FE == :DEUXFINALIS
    clanglife = [(attacker.totalhp / 2.0).floor, 1].max if [:BIGTOP, :DRAGONSDEN].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::CONCERT)
    attacker.pbReduceHP(clanglife)
  end
end

################################################################################
# Damages based off of defense rather than attack (Body Press)
################################################################################
class PokeBattle_Move_184 < PokeBattle_Move
  # Handled Elsewhere.
end

################################################################################
# Sharply Boosts target's offenses (Decorate)
################################################################################
class PokeBattle_Move_185 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if !opponent.pbCanIncreaseAnyStat?(PBStats::Offensive, attacker, self, showMessage: showMessage)
      return false
    end
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbChangeStats(PBStats::Offensive, 2, attacker, self)
  end
end

################################################################################
# Boosts Speed and Changes type based on forme (Aura Wheel)
################################################################################
class PokeBattle_Move_186 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.species != :MORPEKO
      @battle.pbDisplay(_INTL("But {1} can't use the move!", attacker.pbThis(true)))
      return false
    end
    return true
  end

  def pbType(attacker, type = @type)
    type = :DARK if attacker.form == 1 && attacker.species == :MORPEKO
    return super
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    id = :AURAWHEELMINUS if attacker.form == 1 && attacker.species == :MORPEKO # dark type
    super
  end

  def pbAdditionalEffectSelf(attacker)
    attacker.pbChangeStats(PBStats::SPEED, 1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Heals self and partner 1/4 of max hp (Life Dew)
################################################################################
class PokeBattle_Move_187 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    successproc = proc { |attacker, opponent| opponent.canHeal? }
    return pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    noHeal = false
    if opponent.effects[:HealBlock] > 0 || (opponent.status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, opponent).none? && opponent.crested != :SUICUNE)
      @battle.pbDisplay(_INTL("{1} was prevented from healing!", opponent.pbThis))
      noHeal = true
    end
    if opponent.hp == opponent.totalhp && !noHeal
      @battle.pbDisplay(_INTL("{1}'s HP is full!", opponent.pbThis))
      noHeal = true
    end
    if !noHeal
      hpgain = (opponent.totalhp * 0.25).round
      hpgain = (opponent.totalhp * 0.5).round if @battle.FE == :HOLY || (@battle.FE == :RAINBOW && opponent == attacker)
      opponent.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", opponent.pbThis))
    end
    if [:CORROSIVEMIST, :MURKWATERSURFACE].include?(@battle.FE)
      if opponent.pbCanPoison?(attacker, self)
        opponent.pbPoison(attacker)
      end
    end
    if @battle.FE == :WATERSURFACE && opponent == attacker && !opponent.effects[:AquaRing] && @move == :LIFEDEW
      @battle.pbAnimation(:AQUARING, attacker, nil, hitnum)
      opponent.effects[:AquaRing] = true
      @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!", opponent.pbThis))
    end
  end
end

################################################################################
# Protects and sharply lowers def if contact is made (Obstruct)
################################################################################
class PokeBattle_Move_188 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !PBStuff::RATESHARERS.include?(attacker.lastRegularMoveUsed)
      attacker.effects[:ProtectRate] = 0
    end
    if attacker.movingLast?
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if @battle.pbRandom(3 ** attacker.effects[:ProtectRate]) != 0
      attacker.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Protect] = :Obstruct
    attacker.effects[:ProtectRate] += 1
    @battle.pbDisplay(_INTL("{1} protected itself!", attacker.pbThis))
  end
end

################################################################################
# Traps the user and the target. (Jaw Lock)
################################################################################
class PokeBattle_Move_189 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if [attacker, opponent].all? { |i| i.effects[:MeanLook] < 0 && i.effects[:Substitute] == 0 }
      opponent.effects[:MeanLook] = attacker.index
      attacker.effects[:MeanLook] = opponent.index
      @battle.pbDisplay(_INTL("Neither Pokémon can run away!"))
    end
  end
end

################################################################################
# Doubles the prize money received after battle (Happy Hour)
################################################################################
class PokeBattle_Move_18A < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.happyhour = true
    @battle.pbDisplay(_INTL("Everyone is caught up in the happy atmosphere!"))
  end
end

################################################################################
# Decreases the target's Defense by 1 stage. 1.5x power in Gravity (Grav Apple)
################################################################################
class PokeBattle_Move_18B < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    opponent.pbChangeStats(PBStats::DEFENSE, -1, attacker, self, abilitycheck: :hide)
  end

  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 1.5 if @battle.state.effects[:Gravity] != 0
    return damagemult
  end
end

################################################################################
# Hits twice, may cause flinch. (Double Iron Bash)
################################################################################
class PokeBattle_Move_778 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end

  def canFlinch?
    return true
  end

  def pbAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS &&
       !opponent.damagestate.substitute &&
       opponent.status != :SLEEP && opponent.status != :FROZEN
      opponent.effects[:Flinch] = true
      return true
    end
    return false
  end
end

################################################################################
# Destroys the terrain (Steel Roller / Ice Spinner)
################################################################################
class PokeBattle_Move_306 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if @move == :STEELROLLER && !@battle.canEndTempFieldOrOverlay?
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffectAfterMove(attacker, alltargets, hitflags)
    return if (attacker.isFaintedAndNoShields? && Gen < Champs) || ![:Success, :StatusSuccess].intersect?(hitflags)

    @battle.endTempFieldOrOverlay
  end
end

################################################################################
# Hits 2-5 times, boosts Speed and drops Defense (Scale Shot)
################################################################################
class PokeBattle_Move_307 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return [attacker.happiness, 250].min / 5 if attacker.crested == :LUVDISC
    return basedmg
  end

  def pbNumHits(attacker)
    return 5 if attacker.ability == :SKILLLINK || attacker.crested == :LUVDISC

    hitchances = [2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5]
    hitchances = [4, 5] if attacker.hasWorkingItem(:LOADEDDICE)
    return @battle.sample(hitchances)
  end

  def pbEffectAfterMove(attacker, alltargets, hitflags)
    return if attacker.isFaintedAndNoShields? || ![:Success, :StatusSuccess].intersect?(hitflags)
    if Rejuv && [:DEUXFINALIS, :DRAGONSDEN].include?(@battle.FE)
      attacker.pbChangeStats([PBStats::SPEED], [1], attacker, self, abilitycheck: :hide)
    else
      attacker.pbChangeStats([PBStats::SPEED, PBStats::DEFENSE], [1, -1], attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# Two turn attack. Ups user's Special Attack by 1 stage first turn, attacks second
# turn. (Meteor Beam)
################################################################################
class PokeBattle_Move_308 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      if [:STARLIGHT, :NEWWORLD].include?(@battle.FE)
        @immediate = true
      elsif attacker.crested == :CLAYDOL
        @immediate = true
        attacker.effects[:PowerHerb] = :Crest
      elsif attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::SPATK, 1, attacker, self, abilitycheck: :hide) if attacker.effects[:TwoTurnAttack] != 0
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} is overflowing with space power!", attacker.pbThis))
      @battle.pbCommonAnimation("Meteor Beam charging", attacker, nil)
    else
      super
    end
  end
end

################################################################################
# Becomes physical if Atk does more than Sp. Atk. May poison target (Shell Side Arm)
################################################################################
class PokeBattle_Move_309 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    moldBrokenArray = [0, 1, 2, 3].map { |index| @battle.battlers[index].moldbroken }
    @category = self.smartDamageCategory(attacker, targets[0], moldBrokenArray: moldBrokenArray)
    return true
  end

  # smartdamage category overrule glitch
  def pbIsPhysical?(attacker, type = @type)
    return @category == :physical
  end

  def pbIsSpecial?(attacker, type = @type)
    return @category == :special
  end

  def contactMove?
    return true if @category == :physical

    return super
  end

  def contactMoveWhenPhysical?
    return true
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanPoison?(attacker, self)

    opponent.pbPoison(attacker)
  end
end

################################################################################
# Adds 1 to priority on Grassy Terrain (Grassy Glide)
################################################################################
class PokeBattle_Move_310 < PokeBattle_Move
  # Handled in Battle -> def setSpeedOrder
end

################################################################################
# Power doubles on Electric Terrain (Rising Voltage)
################################################################################
class PokeBattle_Move_311 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    basedmg *= 2 if (@battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN) && !opponent.isAirborne?
    return basedmg
  end
end

################################################################################
# Power is doubled in terrain. Type changes depending on the terrain.
# (Terrain Pulse)
################################################################################
class PokeBattle_Move_312 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg * 2 if !@battle.getMimicryType.nil?
    return basedmg
  end

  def pbType(attacker, type = @type)
    mtype = @battle.getMimicryType(update_roll: @battle.phase == :attackPhase)
    type = mtype unless mtype.nil?
    return super
  end
end

################################################################################
# Burns opposing Pokemon that have increased their stats in that turn before the
# execution of this move (Burning Jealousy)
################################################################################
class PokeBattle_Move_313 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    if !opponent.damagestate.substitute && opponent.effects[:Jealousy] && opponent.pbCanBurn?(attacker, self)
      opponent.pbBurn(attacker)
    end
  end
end

################################################################################
# Power is doubled if user's stats were reduced in the turn the move would be
# executed (Lash Out)
################################################################################
class PokeBattle_Move_314 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 2.0 if attacker.effects[:LashOut]
    return damagemult
  end
end

################################################################################
# Fails when the target isn't holding an item (Poltergeist)
################################################################################
class PokeBattle_Move_315 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    targets.each do |opponent|
      next unless opponent.itemWorks? || (@battle.FE == :CHESS && Rejuv)
      if (@battle.FE != :CHESS && Rejuv)
        @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!", opponent.pbThis, getItemName(opponent.item)))
        @battle.ai.discloseItem(opponent)
      end
      return true
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return false
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    if (@battle.FE == :CHESS && Rejuv)
      feedbackMessages[opponent.index].push(:ChessPoltergeist)
    end
    return super
  end
end

################################################################################
# The targets' held items are rendered useless for the rest of the battle
# (Corrosive Gas)
################################################################################
class PokeBattle_Move_316 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if (attacker.isWildPokemon? && !attacker.isbossmon && !attacker.issosmon) ||
       blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    if opponent.ability == :STICKYHOLD
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("It doesn't affect\n{1}...", opponent.pbThis(true))) if showMessage
      return false
    end
    if @battle.pbIsUnlosableItem(opponent, opponent.item) || opponent.item.nil?
      @battle.pbDisplay(_INTL("But it failed to affect\n{1}!", opponent.pbThis(true))) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    @battle.pbDisplay(_INTL("{1} corroded {2}'s {3}!", attacker.pbThis, opponent.pbThis(true), getItemName(opponent.item)))
    opponent.removeItem

    if [:BACKALLEY, :CITY, :CORROSIVEMIST].include?(@battle.FE)
      stats = PBStats::Omni
      opponent.pbChangeStats(stats, -1, attacker, self, abilitycheck: :hide)
    end
  end
end

################################################################################
# Increases the ally's Attack and Defense by 1 stage each (Coaching)
################################################################################
class PokeBattle_Move_317 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if !@battle.doublebattle || !opponent
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return opponent.pbCanIncreaseAnyStat?(PBStats::Physical, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbChangeStats(PBStats::Physical, 1, attacker, self)
  end
end

################################################################################
# The user restores 1/4 of its maximum HP. If there is an adjacent ally, the
# user restores 1/4 of both its and its ally's maximum HP.
# Also heals status conditions. (Jungle Healing / Lunar Blessing)
################################################################################
class PokeBattle_Move_318 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    successproc = proc { |attacker, opponent| opponent.canHeal? || !opponent.status.nil? }
    return pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    healBlock = false
    if opponent.effects[:HealBlock] > 0 || (opponent.status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, opponent).none? && opponent.crested != :SUICUNE)
      @battle.pbDisplay(_INTL("{1} was prevented from healing!", opponent.pbThis))
      healBlock = true
    end

    fullHP = false
    if opponent.hp == opponent.totalhp && !healBlock
      @battle.pbDisplay(_INTL("{1}'s HP is full!", opponent.pbThis))
      fullHP = true
    end

    canHeal = !healBlock && !fullHP
    if canHeal
      hpgain = (opponent.totalhp * 0.25).round
      hpgain = (opponent.totalhp * 0.33).round if (@move == :LUNARBLESSING && [:STARLIGHT, :NEWWORLD, :HOLY].include?(@battle.FE)) || (@move == :JUNGLEHEALING && [:FOREST, :HOLY, :NEWWORLD].include?(@battle.FE))
      opponent.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", opponent.pbThis))
    end

    opponent.pbCureStatus
  end
end

################################################################################
# Hits 3 times. This attack is always a critical hit. (Surging Strikes)
################################################################################
class PokeBattle_Move_319 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 3
  end
end

################################################################################
# Deals damage and decreases the PP of the last move the target used by 3.
# (Eerie Spell)
################################################################################
class PokeBattle_Move_320 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    for i in opponent.moves
      if i && i.move == opponent.lastMoveUsed && i.pp > 0
        reduction = [3, i.pp].min
        opponent.pbSetPP(i, i.pp - reduction)
        @battle.pbDisplay(_INTL("{1} lost {2} PP from {3}!", opponent.pbThis, reduction, i.name))
        return
      end
    end
  end
end

################################################################################
# Power boosted and becomes a spread move on Psychic Terrain (Expanding Force)
################################################################################
# targeting change handled in pbTarget
class PokeBattle_Move_321 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 1.5 if (@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN) && !attacker.isAirborne?
    return damagemult
  end
end

################################################################################
# Deals damage and may inflict poison, paralysis or sleep.
# PLA Pokemon Legends: Arceus (Dire Claw)
################################################################################
class PokeBattle_Move_500 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    rnd = @battle.pbRandom(3)
    case rnd
      when 0
        return if !opponent.pbCanSleep?(attacker, self)

        opponent.pbSleep
      when 1
        return if !opponent.pbCanPoison?(attacker, self)

        opponent.pbPoison(attacker)
      when 2
        return if !opponent.pbCanParalyze?(attacker, self)

        opponent.pbParalyze(attacker)
    end
  end
end

################################################################################
# Increases the user's Attack, Defense and Speed  by 1 stage each.
# PLA Pokemon Legends: Arceus (Victory Dance)
################################################################################
class PokeBattle_Move_501 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::DEFENSE, PBStats::SPEED], attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    statchange = [:BIGTOP, :DANCEFLOOR].include?(@battle.FE) ? 2 : 1
    attacker.pbChangeStats([PBStats::ATTACK, PBStats::DEFENSE, PBStats::SPEED], statchange, attacker, self)
  end
end

################################################################################
# This may also poison the target. This move's power is doubled if the target
# has a status condition.
# PLA Pokemon Legends: Arceus (Barb Barrage)
################################################################################
class PokeBattle_Move_502 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    if [:CORROSIVE, :CORROSIVEMIST, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE) ||
       ((!opponent.status.nil? || opponent.isSleeping?) && !blockedBySubstitute?(attacker, opponent))
      return basedmg * 2
    end

    return basedmg
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanPoison?(attacker, self)

    opponent.pbPoison(attacker)
  end
end

################################################################################
# Deals damage, decreases target's Defense stat and may flinch.
# PLA Pokemon Legends: Arceus (Triple Arrows)
################################################################################
class PokeBattle_Move_503 < PokeBattle_Move
  def canFlinch?
    return true
  end

  def pbAdditionalEffect(attacker, opponent)
    opponent.pbChangeStats(PBStats::DEFENSE, -1, attacker, self, abilitycheck: :hide)
  end

  def pbSecondAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
    end
  end
end

################################################################################
# This may also burn the target. This move's power is doubled if the target
# has a status condition.
# PLA Pokemon Legends: Arceus (Infernal Parade)
################################################################################
class PokeBattle_Move_504 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    if [:INFERNAL, :HAUNTED].include?(@battle.FE) ||
       ((!opponent.status.nil? || opponent.isSleeping?) && !blockedBySubstitute?(attacker, opponent))
      return basedmg * 2
    end

    return basedmg
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanBurn?(attacker, self)

    opponent.pbBurn(attacker)
  end
end

################################################################################
# Heals user's status, and raises user's Special Attack and Special Defense.
# PLA Pokemon Legends: Arceus (Take Heart)
################################################################################
class PokeBattle_Move_505 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !attacker.pbCanIncreaseAnyStat?(PBStats::Special, attacker, self) && attacker.status.nil?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbCureStatus
    amount = [:WATERSURFACE, :UNDERWATER, :HOLY, :NEWWORLD].include?(@battle.FE) ? 2 : 1
    attacker.pbChangeStats(PBStats::Special, amount, attacker, self)
  end
end

################################################################################
# If attack misses, user takes crash damage of 1/2 of max HP.
# May cause confusion. (Axe Kick)
################################################################################
class PokeBattle_Move_506 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    if opponent.pbCanConfuse?(attacker, self)
      opponent.pbConfuse
    end
  end
end

################################################################################
# Confuses opposing Pokemon that have increased their stats in that turn before the
# execution of this move (Alluring Voice)
################################################################################
class PokeBattle_Move_507 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    if !opponent.damagestate.substitute && opponent.effects[:Jealousy] && opponent.pbCanConfuse?(attacker, self)
      opponent.pbConfuse
    end
  end
end

################################################################################
# Increases in power in Sun, irrespective of type (Hydro Steam)
################################################################################
class PokeBattle_Move_508 < PokeBattle_Move
  # Handled in superclass, do not edit!
end

################################################################################
# (Triple Dive)
################################################################################
class PokeBattle_Move_509 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 3
  end
end

################################################################################
# (Population Bomb)
################################################################################
class PokeBattle_Move_50A < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def checkAccuracyEachHit(attacker)
    return attacker.ability != :SKILLLINK && !attacker.hasWorkingItem(:LOADEDDICE)
  end

  def pbNumHits(attacker)
    if attacker.hasWorkingItem(:LOADEDDICE)
      hitchances = [4, 5, 6, 7, 8, 9, 10]
      return @battle.sample(hitchances)
    end
    return 10
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    id = :POPULATIONBOMBNEXTHIT if hitnum > 0
    super
  end
end

################################################################################
# (Hyper Drill / Mighty Cleave)
################################################################################
class PokeBattle_Move_50B < PokeBattle_Move
  # Handled in superclass, do not edit!
end

################################################################################
# (Silk Trap)
################################################################################
class PokeBattle_Move_50C < PokeBattle_Move
  def pbOnStartUse(user, targets)
    if !PBStuff::RATESHARERS.include?(user.lastRegularMoveUsed)
      user.effects[:ProtectRate] = 0
    end
    if user.movingLast?
      user.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if @battle.pbRandom(3 ** user.effects[:ProtectRate]) != 0
      user.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Protect] = :SilkTrap
    attacker.effects[:ProtectRate] += 1
    @battle.pbDisplay(_INTL("{1} protected itself!", attacker.pbThis))
  end
end

################################################################################
# (Spicy Extract)
################################################################################
class PokeBattle_Move_50D < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return opponent.pbCanIncreaseStatStage?(PBStats::ATTACK, attacker, self, showMessage: showMessage) || opponent.pbCanReduceStatStage?(PBStats::DEFENSE, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbChangeStats(PBStats::Physical, [2, -2], attacker, self)
  end
end

################################################################################
# (Spin Out)
################################################################################
class PokeBattle_Move_50E < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::SPEED, -2, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# (Mortal Spin)
################################################################################
class PokeBattle_Move_50F < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanPoison?(attacker, self)

    opponent.pbPoison(attacker)
  end

  def pbEffectAfterMove(attacker, alltargets, hitflags)
    return if (attacker.isFaintedAndNoShields? && Gen < Champs) || ![:Success, :StatusSuccess].intersect?(hitflags)
    return if attacker.ability == :SHEERFORCE

    attacker.spinAwayEffects
  end
end

################################################################################
# User copies target's ability for itself and ally. (Doodle)
################################################################################
class PokeBattle_Move_510 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    oppability = opponent.ability || opponent.backupability
    if oppability.nil? || PBStuff::ABILITYBLACKLIST.include?(oppability)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end

    battlers = [attacker, attacker.pbPartner].select { |i| i && !i.isFainted? }
    for i in battlers
      battlerability = i.ability || i.backupability
      next if (PBStuff::FIXEDABILITIES - [:COMMANDER, :ORICHALCUMPULSE, :HADRONENGINE]).include?(battlerability)
      next if oppability == battlerability
      next if i.hasWorkingItem(:ABILITYSHIELD)

      return true
    end

    if showMessage
      shields = battlers.select { |i| i.hasWorkingItem(:ABILITYSHIELD) }
      shields.each { |i| @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!", i.pbThis, getItemName(i.item))) }
      @battle.pbDisplay(_INTL("But it failed!")) if shields.empty?
    end
    return false
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    oppability = opponent.ability || opponent.backupability

    for i in [attacker, attacker.pbPartner]
      next if !i || i.isFainted?

      if i.hasWorkingItem(:ABILITYSHIELD)
        @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!", i.pbThis, getItemName(i.item)))
        next
      end

      battlerability = i.ability || i.backupability
      next if (PBStuff::FIXEDABILITIES - [:COMMANDER, :ORICHALCUMPULSE, :HADRONENGINE]).include?(battlerability)
      next if oppability == battlerability

      message = _INTL("{1} copied {2}'s {3} Ability!", i.pbThis, opponent.pbThis(true), getAbilityName(oppability))
      i.changeAbilityWithEffects(oppability, message: message)
    end
  end
end

################################################################################
# (Fillet Away)
################################################################################
class PokeBattle_Move_511 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    filletlife = [(attacker.totalhp / 2.0).floor, 1].max
    if attacker.hp <= filletlife
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED], attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats([PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED], 2, attacker, self)
    filletlife = [(attacker.totalhp / 2.0).floor, 1].max
    attacker.pbReduceHP(filletlife)
  end
end

################################################################################
# Type based on form of Tauros. Removes screens from target's side of the field (Raging Bull)
################################################################################
class PokeBattle_Move_512 < PokeBattle_Move
  def pbType(attacker, type = @type)
    if attacker.species == :TAUROS
      case attacker.form
        when 1 then type = :FIGHTING
        when 2 then type = :FIRE
        when 3 then type = :WATER
      end
    end
    return super
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    @battle.pbEndSideEffects(opponent.pbOwnSide, PBStuff::SCREENEFFECTS.values)
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.species == :TAUROS
      case attacker.form
        when 1 then id = :RAGINGBULLFIGHTING
        when 2 then id = :RAGINGBULLFIRE
        when 3 then id = :RAGINGBULLWATER
      end
    end
    super
  end
end

################################################################################
# (Make it Rain)
################################################################################
class PokeBattle_Move_513 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    drop = Gen >= Champs ? -2 : -1
    attacker.pbChangeStats(PBStats::SPATK, drop, attacker, self, abilitycheck: :hide)
    if @battle.FE == :DRAGONSDEN
      @battle.pbDisplay(_INTL("Treasure scattered everywhere!"))
    else
      @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
    end
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if @battle.pbOwnedByPlayer?(attacker.index)
      @battle.extramoney += 5 * attacker.level
      if [:BIGTOP, :DRAGONSDEN].include?(@battle.FE)
        @battle.extramoney += 495 * attacker.level
      end
      @battle.extramoney = MAXMONEY if @battle.extramoney > MAXMONEY
    end
  end
end

################################################################################
# Boosts user's Attack and Speed, and removes all substitutes and hazards from the field (Tidy Up)
################################################################################
class PokeBattle_Move_514 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return true if attacker.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::SPEED], attacker, self)
    return true if @battle.battlers.any? { |battler| battler.effects[:Substitute] > 0 }
    return true if @battle.sides.any? { |side| side.anyHazardActive? }
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    tidy = @battle.battlers.any? { |battler| battler.effects[:Substitute] > 0 } || @battle.sides.any? { |side| side.anyHazardActive? }
    @battle.eachBattler do |battler| # correct
      if battler.effects[:Substitute] > 0
        battler.effects[:Substitute] = 0
        @battle.scene.pbUnSubstituteSprite(battler)
        @battle.pbDisplay(_INTL("{1}'s substitute faded!", battler.pbThis))
      end
    end
    @battle.pbEndSideEffects(@battle.sides, [:Spikes, :ToxicSpikes, :StealthRock, :StickyWeb])
    @battle.pbDisplay(_INTL("Tidying up complete!")) if tidy
    attacker.pbChangeStats([PBStats::ATTACK, PBStats::SPEED], 1, attacker, self)
  end
end

################################################################################
# (Collision Course / Electro Drift)
################################################################################
class PokeBattle_Move_515 < PokeBattle_Move
  # Handled in superclass, do not edit!
end

################################################################################
# (Chilly Reception)
################################################################################
class PokeBattle_Move_516 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return true if @battle.canSetWeather?(:SNOW)
    return true if attacker.canTriggerUserSwitch?
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    attacker.vanished = true
    @battle.scene.pbDisableShadowTemp(attacker)
    super
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.canSetWeather?(:SNOW)
      duration = attacker.hasWorkingItem(:ICYROCK) || [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION, :SKY, :CLOUDS, :BIGTOP].include?(@battle.FE) ? 8 : 5
      @battle.pbSetWeather(:SNOW, duration)
    end
    if attacker.canTriggerUserSwitch?
      attacker.userSwitch = :Move
    else
      attacker.vanished = false
      @battle.pbCommonAnimation("Fade in", attacker, nil)
    end
  end
end

################################################################################
# (Double Shock)
################################################################################
class PokeBattle_Move_517 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !attacker.hasType?(:ELECTRIC)
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffectAfterMove(attacker, alltargets, hitflags)
    return if attacker.isFaintedAndNoShields? || ![:Success, :StatusSuccess].intersect?(hitflags)
    return if !attacker.canChangeType?

    attacker.effects[:DoubleShock] = true
    if attacker.type1 == :ELECTRIC
      if attacker.type2.nil?
        attacker.type1 = :QMARKS
      else
        attacker.type1 = attacker.type2
      end
    end
    if attacker.type2 == :ELECTRIC
      attacker.type2 = nil
    end
    @battle.pbDisplay(_INTL("{1} used up all its electricity!", attacker.pbThis))
  end
end

################################################################################
# (Shed Tail)
################################################################################
class PokeBattle_Move_518 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if !attacker.canTriggerUserSwitch?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    elsif attacker.effects[:Substitute] > 0
      @battle.pbDisplay(_INTL("{1} already has a substitute!", attacker.pbThis)) if showMessage
      return false
    elsif attacker.hp <= (attacker.totalhp / 2.0).ceil
      @battle.pbDisplay(_INTL("But it does not have enough HP left to make a substitute!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    sublife = [(attacker.totalhp / 4.0).floor, 1].max
    attacker.pbReduceHP((attacker.totalhp / 2.0).ceil, false, false) # late message
    @battle.pbPlaySubstituteAnimation(attacker)
    attacker.effects[:MultiTurn] = 0
    attacker.effects[:MultiTurnAttack] = 0
    @battle.pbDisplay(_INTL("{1} shed its tail to create a decoy!", attacker.pbThis))
    attacker.pbBerryHerbCheck
    attacker.carryOutUserSwitch(:ShedTail) # updates attacker object
    return if attacker.isFainted? # new attacker might have fainted to hazards

    @battle.pbPlaySubstituteAnimation(attacker)
    attacker.effects[:Substitute] = sublife
  end
end

################################################################################
# (Last Respects)
################################################################################
class PokeBattle_Move_519 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg + (50 * attacker.pbOwnSide.effects[:AlliesFainted])
  end
end

################################################################################
# (Glaive Rush)
################################################################################
class PokeBattle_Move_51A < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:GlaiveRush] = true
  end
end

################################################################################
# (Rage Fist)
################################################################################
class PokeBattle_Move_51B < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg + (50 * attacker.getHitsTaken)
  end
end

################################################################################
# (Salt Cure)
################################################################################
class PokeBattle_Move_51C < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    return if opponent.damagestate.substitute || opponent.effects[:SaltCure]

    opponent.effects[:SaltCure] = true
    @battle.pbDisplay(_INTL("{1} is being salt cured!", opponent.pbThis))
  end
end

################################################################################
# Boosts Attack, Defense or Speed depending on Tatsugiri's form. (Order Up)
################################################################################
class PokeBattle_Move_51D < PokeBattle_Move
  def pbAdditionalEffectSelf(attacker)
    return if !attacker.effects[:Commandee] || !attacker.pbPartner.effects[:Commander]
    return if ![0, 1, 2].include?(attacker.pbPartner.form)
    case attacker.pbPartner.form
      when 0 then stat = PBStats::ATTACK
      when 1 then stat = PBStats::DEFENSE
      when 2 then stat = PBStats::SPEED
    end
    attacker.pbChangeStats(stat, 1, attacker, self, abilitycheck: :hide)
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:Commandee] && attacker.pbPartner.effects[:Commander]
      case attacker.pbPartner.form
        when 0 then id = :ORDERUPCURLY
        when 1 then id = :ORDERUPDROOPY
        when 2 then id = :ORDERUPSTRETCHY
      end
    end
    super
  end
end

################################################################################
# (Matcha Gotcha)
################################################################################
class PokeBattle_Move_51E < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    damage = opponent.lastHPLost
    if damage > 0 && !opponent.damagestate.disguise
      hpgain = (damage * 0.5).round
      @healed = true if attacker.absorbHP(hpgain, opponent, :MatchaGotcha, self)
    end
  end

  def pbAdditionalEffect(attacker, opponent)
    return false if !opponent.pbCanBurn?(attacker, self)

    opponent.pbBurn(attacker)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.pbDisplay(_INTL("Warm tea tastes best in the cold!")) if @healed && [:SNOWYMOUNTAIN, :ICY].include?(@battle.FE)
  end
end

################################################################################
# (Syrup Bomb)
################################################################################
class PokeBattle_Move_51F < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    return if opponent.effects[:SyrupBombTurns] > 0

    opponent.effects[:SyrupBombTurns] = 3
    opponent.effects[:SyrupBombUser] = attacker.index
    @battle.pbDisplay(_INTL("{1} got covered in sticky candy syrup!", opponent.pbThis))
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    id = :SYRUPBOMBSHINY if attacker.pokemon.isShiny?
    super
  end
end

################################################################################
# (Ivy Cudgel)
################################################################################
class PokeBattle_Move_520 < PokeBattle_Move
  def pbType(attacker, type = @type)
    if attacker.species == :OGERPON
      case attacker.form
        when 1, 5 then type = :WATER
        when 2, 6 then type = :FIRE
        when 3, 7 then type = :ROCK
      end
    end
    return super
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.species == :OGERPON
      case attacker.form
        when 1, 5 then id = :IVYCUDGELWATER
        when 2, 6 then id = :IVYCUDGELFIRE
        when 3, 7 then id = :IVYCUDGELROCK
      end
    end
    super
  end
end

################################################################################
# (Electro Shot)
################################################################################
class PokeBattle_Move_521 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate = false
    if attacker.effects[:TwoTurnAttack] == 0
      @immediate = true if @battle.pbWeather(attacker) == :RAINDANCE && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
      @immediate = true if @battle.FE == :ELECTERRAIN
      if !@immediate && attacker.hasWorkingItem(:POWERHERB)
        @immediate = true
        attacker.effects[:PowerHerb] = :Item
      end
    end

    return attacker.effects[:TwoTurnAttack] == 0
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    return 0 if attacker.effects[:TwoTurnAttack] != 0
    return super
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbChangeStats(PBStats::SPATK, 1, attacker, self, abilitycheck: :hide) if attacker.effects[:TwoTurnAttack] != 0
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if attacker.effects[:TwoTurnAttack] != 0
      @battle.pbDisplay(_INTL("{1} absorbed electricity!", attacker.pbThis))
      @battle.pbCommonAnimation("Electro Shot charging", attacker, nil)
    else
      super
    end
  end
end

################################################################################
# (Tera Starstorm)
################################################################################
class PokeBattle_Move_522 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if attacker.isStellarTerapagos?
      moldBrokenArray = [0, 1, 2, 3].map { |index| @battle.battlers[index].moldbroken }
      @category = self.smartDamageCategory(attacker, nil, moldBrokenArray: moldBrokenArray)
    end
    return true
  end

  # smartdamage category overrule glitch
  def pbIsPhysical?(attacker, type = @type)
    if attacker.isStellarTerapagos?
      return @category == :physical
    else
      super
    end
  end

  def pbIsSpecial?(attacker, type = @type)
    if attacker.isStellarTerapagos?
      return @category == :special
    else
      super
    end
  end

  def pbType(attacker, type = @type)
    type = :STELLAR if attacker.isStellarTerapagos?
    return super
  end
end

################################################################################
# (Fickle Beam)
################################################################################
class PokeBattle_Move_523 < PokeBattle_Move
  def pbOnStartUse(user, targets)
    ficklechance = @battle.FE == :DRAGONSDEN ? 5 : 7
    @fickle = @battle.pbRandom(10) >= ficklechance ? true : false
    return true
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    basedmg *= 2 if @fickle
    return basedmg
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    if @fickle
      @battle.pbDisplay(_INTL("{1} is going all out for this attack!", attacker.pbThis))
      id = :FICKLEBEAMMAX
    end
    super
  end
end

################################################################################
# (Burning Bulwark)
################################################################################
class PokeBattle_Move_524 < PokeBattle_Move
  def pbOnStartUse(user, targets)
    if !PBStuff::RATESHARERS.include?(user.lastRegularMoveUsed)
      user.effects[:ProtectRate] = 0
    end
    if user.movingLast?
      user.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if @battle.pbRandom(3 ** user.effects[:ProtectRate]) != 0
      user.effects[:ProtectRate] = 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:Protect] = :BurningBulwark
    attacker.effects[:ProtectRate] += 1
    @battle.pbDisplay(_INTL("{1} protected itself!", attacker.pbThis))
  end
end

################################################################################
# (Dragon Cheer)
################################################################################
class PokeBattle_Move_525 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return true if opponent.effects[:FocusEnergy] < 1
    @battle.pbDisplay(_INTL("But it failed!")) if showMessage
    return false
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if Rejuv && ([:DRAGONSDEN, :DEUXFINALIS].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::CONCERT))
      boost = opponent.hasType?(:DRAGON) ? 3 : 2
    else
      boost = opponent.hasType?(:DRAGON) || @battle.FE == :DRAGONSDEN ? 2 : 1
    end
    opponent.effects[:FocusEnergy] = boost
    @battle.pbDisplay(_INTL("{1} is getting pumped!", opponent.pbThis))
    opponent.copyableStatBoosts[:crit] = boost
  end
end

################################################################################
# (Upper Hand)
################################################################################
class PokeBattle_Move_526 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    targets.each do |opponent|
      next if opponent.hasMovedThisRound?
      next if opponent.effects[:HyperBeam] > 0
      next if @battle.switchedOut[opponent.index]
      next if opponent.itemUsed
      next if [nil, 0, -1].include?(@battle.choices[opponent.index][2])
      next if @battle.choices[opponent.index][2].pbIsStatus?
      next if @battle.choices[opponent.index][2].priorityCheck(opponent) <= 0
      return true
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return false
  end

  def pbAdditionalEffect(attacker, opponent)
    if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[:Flinch] = true
    end
  end
end

################################################################################
# (Revival Blessing)
################################################################################
class PokeBattle_Move_527 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if @battle.pbOwnedByPlayer?(attacker.index) && $game_switches[:Nuzlocke_Mode] && !@battle.isOnline?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end

    canRevive = false
    for pkmn in @battle.pbPartySingleOwner(attacker.index)
      canRevive = true if pkmn && pkmn.hp == 0 && !pkmn.isEgg?
    end
    if !canRevive || @battle.pbGetOwner(attacker.index).nil?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    party = @battle.pbPartySingleOwner(attacker.index)
    index = @battle.pbRevive(attacker.index, @move)
    revivepoke = party[index]
    @battle.pbDisplay(_INTL("{1} was revived and is ready to fight again!", revivepoke.name))
    @battle.pbSendOutRevivedBattler(attacker, index)
  end
end

################################################################################
# Power increases by 50% on Electric Terrain (Psyblade)
################################################################################
class PokeBattle_Move_528 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    damagemult *= 1.5 if @battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN
    return damagemult
  end
end

################################################################################
# User takes half their max HP as recoil (Chloroblast)
################################################################################
class PokeBattle_Move_529 < PokeBattle_Move
  def getRecoil(attacker, damage, recoilmult, hitflags)
    return 0 unless hitflags.include?(:Success)
    return 0 if attacker.ability == :ROCKHEAD
    return 0 if attacker.crested == :RAMPARDOS
    return 0 if @battle.magicGuardAbilities.include?(attacker.ability)
    recoilmult = 0.5 # the recoil multiplier cannot be given to this move as a move attribute as the attribute is also used to check for Reckless
    recoilmult = 0.25 if @battle.FE == :FOREST && @move == :CHLOROBLAST
    return (attacker.totalhp * recoilmult).round
  end
end

################################################################################
# Does absolutely nothing (Celebrate).
################################################################################
class PokeBattle_Move_18C < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    trainer = @battle.pbGetOwner(attacker.index) || $Trainer
    @battle.pbDisplay(_INTL("Congratulations, {1}!", trainer.name))
  end
end

################################################################################
# Does absolutely nothing to an ally (Hold Hands).
################################################################################
class PokeBattle_Move_18D < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    if !@battle.doublebattle
      @battle.pbDisplay(_INTL("But it failed!"))
    end
    return true
  end
end

################################################################################
# Increases user and ally's Attack by 1 stage. (Gen 8 Howl)
################################################################################
class PokeBattle_Move_18E < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    successproc = proc { |attacker, opponent| opponent.pbCanIncreaseStatStage?(PBStats::ATTACK, attacker, self) }
    return pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    amount = 1
    amount = 2 if @battle.FE == :COLOSSEUM || @battle.ProgressiveFieldCheck(PBFields::CONCERT)
    opponent.pbChangeStats(PBStats::ATTACK, amount, attacker, self)
  end
end

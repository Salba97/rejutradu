################################################################################
# Rejuvenation custom move functions
# Venam's Kiss is handled in 005 (causes Poison) and pbTypeModifiers
# Multipulse is handled in 09F (Judgment/Multiattack)
# Barbed Web is handled in 005 (cauese Poison)
# Cold Truth is handled in 0B7 (Torment)
# Uproot is handled in 04F (drops Spdef by 2)
# Heavenly Wing is handled in 050 (Clear Smog)
# Slash and Burn & Pyrokinesis are handled in 00A (causes burn)
# Poison Sweep is handled in 044 (lowers speed)
# Stacking Shot is handled in 091 (Fury Cutter)
# Irritation is handled in  07F (Hex)
# Magma drift is handled in 075 (Surf)
# Deluge is handled in 081 (Revenge/Avalanche)
# Mud Barrage is handled in 0C0 (2-5 Multihit)
# Solar Flare is handled in 01C (raises attack)
# Hoarfrost Moon is handled in 020 (raises special attack)
# Wake-Up Shock is handled in 07D (Wake-up Slap)
# Injection is handled in 0DD (heals by half of damage dealt)
# Matrix Shot is handled in 122 (Psyshock)
# Cauterize is handled in 167 (Pollen Puff)
# everything else is below
################################################################################

################################################################################
# Power is doubled if a foe tries to switch out. (Pursuit / Vile Assault)
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
################################################################################
class PokeBattle_Move_088 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg * 2 if opponent.effects[:Pursuitee] && @move != :VILEASSAULT

    return basedmg
  end
end

################################################################################
# Effect depends on the environment. (Secret power)
################################################################################
class PokeBattle_Move_0A4
  def initialize(*args)
    super(*args)
    if user.is_a?(PokeBattle_Battler)
      if @move == :VORPALBLADE && !@battle.pbOwnedByPlayer?(user.index)
        @name = @battle.FE == :GLITCH ? _INTL("Destructor de Unown") : getMoveName(:VORPALBLADE)
      end
    end
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return 110 if @move == :VORPALBLADE && @battle.FE == :GLITCH && !@battle.pbOwnedByPlayer?(attacker.index)

    return basedmg
  end
end

################################################################################
# Petrifies the target. (Decimation)
################################################################################
class PokeBattle_Move_200 < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanPetrify?(attacker, self)

    opponent.pbPetrify(attacker)
  end
end

################################################################################
# Gale Strike
################################################################################
class PokeBattle_Move_201 < PokeBattle_Move
  # Handled in superclass def pbCritRate?, do not edit!
end

################################################################################
# Power is chosen at random.
# Can be used while asleep and wakes user up. (Fever Pitch)
################################################################################
class PokeBattle_Move_202 < PokeBattle_Move
  @calcbasedmg = 0

  def pbOnStartUse(attacker, targets)
    basedmg = [40, 50, 65, 70, 85, 100, 130]
    partyhype = [
      5,
      6, 6,
      7, 7, 7, 7,
      8, 8, 8, 8, 8, 8,
      9, 9, 9, 9,
      10, 10,
      11
    ]
    hype = partyhype[@battle.pbRandom(partyhype.length)]
    hype = partyhype[0] if @battle.FE == :CONCERT1
    hype = partyhype[19] if @battle.FE == :CONCERT4
    @calcbasedmg = basedmg[hype - 5]
    if attacker.crested == :LUVDISC
      @calcbasedmg = [attacker.happiness, 250].min
      hype = 12
    end
    @battle.pbDisplay(_INTL("¡Nivel de volumen: {1}!", hype))
    return true
  end

  def pbCanUseWhileAsleep?
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if attacker.status == :SLEEP
      attacker.pbCureStatus(false)
      @battle.pbDisplay(_INTL("¡{1} se ha emocionado demasiado como para dormir!", attacker.pbThis))
    end
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return @calcbasedmg
  end
end

################################################################################
# For 5 rounds, if Sandstorm,
# lowers power of super effective attacks against the user's side. (Arenite Wall)
################################################################################
class PokeBattle_Move_203 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    return true if [:DESERT, :ROCKY, :ASHENBEACH, :DEUXFINALIS].include?(@battle.FE)
    return true if @battle.pbWeather(attacker) == :SANDSTORM
    @battle.pbDisplay(_INTL("¡Pero ha fallado!"))
    return false
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.pbOwnSide.effects[:AreniteWall] > 0
      @battle.pbDisplay(_INTL("¡Pero ha fallado!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.pbOwnSide.effects[:AreniteWall] = 5
    attacker.pbOwnSide.effects[:AreniteWall] = 8 if attacker.hasWorkingItem(:LIGHTCLAY)
    attacker.pbOwnSide.effects[:AreniteWall] = 8 if [:DESERT, :ROCKY, :ASHENBEACH].include?(@battle.FE)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("¡{1} ha fortalecido a tu equipo contra los ataques supereficaces!", @name))
    else
      @battle.pbDisplay(_INTL("¡{1} ha fortalecido al equipo rival contra los ataques supereficaces!", @name))
    end
  end
end

###############################################################################
# Target becomes Ground type and inflicts Sand Tomb. (Desert's Mark)
##############################################################################
class PokeBattle_Move_205 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if blockedBySubstitute?(attacker, opponent)
      @battle.pbDisplay(_INTL("¡Pero ha fallado!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    if (!opponent.canChangeType? || opponent.types == [:GROUND]) &&
       opponent.effects[:MultiTurn] != 0 && opponent.effects[:DesertsMark] == true
      @battle.pbDisplay(_INTL("¡Pero ha fallado!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if opponent.canChangeType? && opponent.types(excludeReflector: true) != [:GROUND]
      opponent.changeType(:GROUND)
      @battle.pbDisplay(_INTL("¡{1} se ha convertido en un Pokémon de tipo {2}!", opponent.pbThis, getTypeName(:GROUND)))
    end
    opponent.effects[:DesertsMark] = true
    if !opponent.isFaintedAndNoShields? && !opponent.damagestate.substitute
      if opponent.effects[:MultiTurn] == 0
        opponent.effects[:MultiTurn] = 50
        opponent.effects[:MultiTurnAttack] = @move
        opponent.effects[:MultiTurnUser] = attacker.index
        opponent.effects[:BindingBand] = attacker.hasWorkingItem(:BINDINGBAND)
        @battle.pbDisplay(_INTL("¡{1} ha quedado atrapado en las arenas movedizas!", opponent.pbThis))
      end
    end
  end
end

################################################################################
# Hits three times and changes types depending on current hit (Probopog)
################################################################################
class PokeBattle_Move_206 < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    @type = self.smartDamageType(attacker, targets[0], [:STEEL, :ROCK, :ELECTRIC])
    return true
  end

  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 3
  end
end

################################################################################
# Increases the user's Special Attack and Speed by 1 stage each. (Aquabatics)
################################################################################
class PokeBattle_Move_207 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?([PBStats::SPATK, PBStats::SPEED], attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    amount = @battle.FE == :BIGTOP ? 2 : 1
    attacker.pbChangeStats([PBStats::SPATK, PBStats::SPEED], amount, attacker, self)
  end
end

################################################################################
# Poisons the target. User gains half the HP it inflicts as damage. (Hexing Slash)
################################################################################
class PokeBattle_Move_208 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    damage = opponent.lastHPLost
    if damage > 0 && !opponent.damagestate.disguise
      hpgain = (damage * 0.5).round
      attacker.absorbHP(hpgain, opponent, :HPDrainingMove, self)
    end
  end

  def pbAdditionalEffect(attacker, opponent)
    return if !opponent.pbCanPoison?(attacker, self, showMessage: false)

    opponent.pbPoison(attacker)
  end
end

################################################################################
# Bunraku Beatdown
# Base Power increases by increments for every party member that is KO'd.
################################################################################
class PokeBattle_Move_209 < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    if attacker.ability == :WORLDOFNIGHTMARES
      basedmg += (15 * opponent.pbFaintedPokemonCount)
      return basedmg
    else
      fainted = attacker.pbFaintedPokemonCount
      fainted = 6 if attacker.pbFaintedPokemonCount > 5
      basedmg += (10 * fainted)
      return basedmg
    end
  end
end

################################################################################
# Quicksilver Spear
# Deals incremental damage at the end of the turn
# equal to 1/16th (1/8th against Bosses) of their HP while lowering their speed on impact.
################################################################################
class PokeBattle_Move_20A < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.effects[:Quicksilver] = true if !opponent.isFaintedAndNoShields? && !opponent.damagestate.substitute
  end

  def pbAdditionalEffect(attacker, opponent)
    opponent.pbChangeStats(PBStats::SPEED, -1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Randomly increases Defense or Special Defense by a stage (Spectral Scream)
################################################################################
class PokeBattle_Move_20B < PokeBattle_Move
  def pbAdditionalEffect(attacker, opponent)
    stat = @battle.sample(PBStats::Defensive)
    attacker.pbChangeStats(stat, 1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Gilded Arrow/Gilded Helix
################################################################################
class PokeBattle_Move_20C < PokeBattle_Move
  def pbType(attacker, type = @type)
    return attacker.type2 if attacker.type2 && attacker.type2 != :FAIRY && attacker.type2 != :DARK
    return attacker.type1
  end

  def pbIsMultiHit
    return @move == :GILDEDHELIX
  end

  def pbNumHits(attacker)
    return @move == :GILDEDHELIX ? 2 : 1
  end
end

################################################################################
# Becomes physical if Atk does more than Sp. Atk. May reduce defense/spdef respectively
# (Super UMD Move)
################################################################################
class PokeBattle_Move_20D < PokeBattle_Move
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

  def pbType(attacker, type = @type)
    type = attacker.types.include?(:QMARKS) ? :QMARKS : :STEEL
    return super
  end

  def pbAdditionalEffect(attacker, opponent)
    stat = @category == :physical ? PBStats::DEFENSE : PBStats::SPDEF
    opponent.pbChangeStats(stat, -1, attacker, self, abilitycheck: :hide)
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    # the animation for the special version is just way more fun tbh
    # id = @category == :physical ? :ULTRAMEGAHAMMER : :ULTRAMEGADEATH
    super
  end
end

################################################################################
# Mirror Beam (Uses the most effective reflected type.)
################################################################################
class PokeBattle_Move_20E < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    @type = self.smartDamageType(attacker, targets[0], attacker.effects[:ReflectorTypes] + [$cache.moves[@move].type])
    return true
  end
end

################################################################################
# Intercept Z Unleashed Power
################################################################################
class PokeBattle_Move_80A < PokeBattle_Move
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

  def pbType(attacker, type = @type)
    type = pbHiddenPower(attacker.pokemon)
    type = super(attacker, type)
    return type
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if opponent.pbOwnSide.effects[:Reflect] > 0
      opponent.pbOwnSide.effects[:Reflect] = 0
      if @battle.pbIsOpposing?(opponent.index)
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha roto {1} del equipo rival!", getMoveName(:REFLECT)))
      else
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha roto {1} de tu equipo!", getMoveName(:REFLECT)))
      end
    end
    if opponent.pbOwnSide.effects[:LightScreen] > 0
      opponent.pbOwnSide.effects[:LightScreen] = 0
      if @battle.pbIsOpposing?(opponent.index)
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha roto {1} del equipo rival!", getMoveName(:LIGHTSCREEN)))
      else
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha roto {1} de tu equipo!", getMoveName(:LIGHTSCREEN)))
      end
    end
    if opponent.pbOwnSide.effects[:AuroraVeil] > 0
      opponent.pbOwnSide.effects[:AuroraVeil] = 0
      if @battle.pbIsOpposing?(opponent.index)
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha disipado {1} del equipo rival!", getMoveName(:AURORAVEIL)))
      else
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha disipado {1} de tu equipo!", getMoveName(:AURORAVEIL)))
      end
    end
    if opponent.pbOwnSide.effects[:AreniteWall] > 0
      opponent.pbOwnSide.effects[:AreniteWall] = 0
      if @battle.pbIsOpposing?(opponent.index)
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha roto {1} del equipo rival!", getMoveName(:ARENITEWALL)))
      else
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha roto {1} de tu equipo!", getMoveName(:ARENITEWALL)))
      end
    end
    if opponent.pbOwnSide.effects[:AntiMatterShield] != 0
      opponent.pbOwnSide.effects[:AntiMatterShield] = 0
      if @battle.pbIsOpposing?(opponent.index)
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha roto el Escudo de Antimateria del equipo rival!"))
      else
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha roto el Escudo de Antimateria de tu equipo!"))
      end
    end
    if opponent.pbOwnSide.effects[:LuckyChant] != 0
      opponent.pbOwnSide.effects[:LuckyChant] = 0
      if @battle.pbIsOpposing?(opponent.index)
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha roto el Canto de la Suerte del equipo rival!"))
      else
        @battle.pbDisplay(_INTL("¡El poder del Interceptor ha roto el Canto de la Suerte de tu equipo!"))
      end
    end
  end
end

################################################################################
# Intercept Z Blinding Speed
################################################################################
class PokeBattle_Move_80B < PokeBattle_Move
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

  def pbType(attacker, type = @type)
    return super(attacker, attacker.type1)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    return if attacker.pbPartner.isFainted?
    return if attacker.pbPartner.acted?
    @battle.pbAnimation(:AFTERYOU, attacker, attacker.pbPartner, hitnum)
    attacker.pbPartner.effects[:AfterYou] = true
    @battle.setActPrioData
    @battle.pbDisplay(_INTL("¡{1} sigue los pasos de {2}!", attacker.pbPartner.pbThis, attacker.pbThis(true)))
  end
end

################################################################################
# Intercept Z Elysian Shield
################################################################################
class PokeBattle_Move_80C < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if attacker.pbOwnSide.effects[:AuroraVeil] > (@battle.FE == :MIRROR ? 8 : 5) &&
       !attacker.pbCanIncreaseAnyStat?(PBStats::Defensive, attacker, self)
      @battle.pbDisplay(_INTL("¡Pero ha fallado!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    veilduration = @battle.FE == :MIRROR ? 8 : 5
    attacker.pbOwnSide.effects[:AuroraVeil] = veilduration if attacker.pbOwnSide.effects[:AuroraVeil] < veilduration
    attacker.pbChangeStats(PBStats::Defensive, 1, attacker, self)
    @battle.pbDisplay(_INTL("¡Las defensas de {1} se han vuelto casi impenetrables!", attacker.pbThis))
  end
end

################################################################################
# Intercept Z Domain Shift
################################################################################
class PokeBattle_Move_80D < PokeBattle_Move
  def pbType(attacker, type = @type)
    type = !@battle.isOnline? && $game_switches[:RenegadeRoute] && @battle.pbOwnedByPlayer?(attacker.index) ? :SHADOW : :FAIRY
    return type
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.state.effects[:NeverMeltIce]
      @battle.state.effects[:NeverMeltIce] = false
      @battle.weather = 0
      message = _INTL("¡El hielo eterno se ha desvanecido!")
      return
    end
    fieldlist = [:ELECTERRAIN, :GRASSY, :MISTY, :SWAMP, :DESERT, :ICY, :ROCKY, :CAVE, :MOUNTAIN, :DEEPEARTH, :PSYTERRAIN, :HAUNTED, :CITY]
    if !@battle.pbOwnedByPlayer?(attacker.index)
      owner = @battle.pbGetOwner(attacker.index)
      if owner.name == $game_variables[:PlayerNameBackup] && owner.trainertype == :INTERCEPTORARMOR
        fieldlist += [:DARKCRYSTALCAVERN, :VOLCANIC, :CORROSIVE, :CORROSIVEMIST, :VOLCANICTOP, :SHORTCIRCUIT, :MURKWATERSURFACE, :DRAGONSDEN, :DIMENSIONAL, :FROZENDIMENSION, :INFERNAL, :BACKALLEY]
      end
    else
      if !@battle.isOnline? && $game_switches[:RenegadeRoute] && @battle.pbOwnedByPlayer?(attacker.index)
        fieldlist += [:DARKCRYSTALCAVERN, :VOLCANIC, :CORROSIVE, :CORROSIVEMIST, :VOLCANICTOP, :SHORTCIRCUIT, :MURKWATERSURFACE, :DRAGONSDEN, :DIMENSIONAL, :FROZENDIMENSION, :INFERNAL, :BACKALLEY]
      else
        fieldlist += [:RAINBOW, :FOREST, :FACTORY, :WATERSURFACE, :CRYSTALCAVERN, :SNOWYMOUNTAIN, :HOLY, :FAIRYTALE, :STARLIGHT, :BEWITCHED, :SKY]
      end
    end
    fieldlist = fieldlist - [@battle.FE] # filter out current field
    field = !@battle.isOnline? && $game_variables[:DomainShift] != 0 ? $game_variables[:DomainShift] : @battle.sample(fieldlist)
    message = _INTL("¡El Núcleo dicta un nuevo entorno!")
    @battle.setField(field, 6, message, ignoreOverlays: true)
  end
end

################################################################################
# Intercept Z Chthonic Malady
################################################################################
class PokeBattle_Move_80E < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if !opponent.pbCanPetrify?(attacker, self) &&
       (opponent.effects[:Torment] || @battle.pbCheckSideAbility(:AROMAVEIL, opponent, checkMoldBroken: true).any?) &&
       !opponent.pbCanReduceAnyStat?(PBStats::Offensive, attacker, self)
      @battle.pbDisplay(_INTL("¡Pero ha fallado!")) if showMessage
      return false
    end
    return true
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if opponent.pbCanPetrify?(attacker, self)
      opponent.pbPetrify(attacker)
    end
    if !(opponent.effects[:Torment] || @battle.pbCheckSideAbility(:AROMAVEIL, opponent, checkMoldBroken: true).any?)
      opponent.effects[:Torment] = true
      opponent.effects[:ChthonicMalady] = 5
      @battle.pbDisplay(_INTL("¡{1} ha sido sometido a tormento!", opponent.pbThis))
      opponent.pbBerryHerbCheck
    end
    opponent.pbChangeStats(PBStats::Offensive, -2, attacker, self)
    @battle.pbDisplay(_INTL("¡El fin de {1} se acerca!", opponent.pbThis))
  end
end

################################################################################
# Vengeful Nuke
################################################################################

class PokeBattle_Move_80F < PokeBattle_Move
  def pbBaseDamage(basedmg, attacker, opponent)
    mult = 0
    for i in 1...7
      mult += opponent.stages[i] if opponent.stages[i] > 0
    end

    return [basedmg + (20  * mult), 200].min
  end

  def pbAdditionalEffect(attacker, opponent)
    opponent.pbChangeStats(PBStats::SPEED, -1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Orbital Ring
################################################################################
class PokeBattle_Move_81A < PokeBattle_Move


  def pbShortUseMove(attacker, targets)
    if !@battle.battlers[attacker.index].pbPartner.isFainted?
      @battle.battlers[attacker.index].pbPartner.effects[:FollowMe] = false
      @battle.battlers[attacker.index].pbPartner.effects[:RagePowder] = false
    end
    @battle.pbAnimation(:FOLLOWME, @battle.battlers[attacker.index], attacker.pbOppositeOpposing)
    @battle.battlers[attacker.index].effects[:FollowMe] = true
    @battle.pbDisplay(_INTL("¡{1} ha acaparado toda la atención!", attacker.pbThis, @battle.battlers[attacker.index].pbThis))
    @battle.battlers[attacker.index].effects[:Endure] = true
    @battle.pbDisplay(_INTL("¡{1} se ha preparado para resistir!", @battle.battlers[attacker.index].pbThis))
    @battle.battlers[attacker.index].pbOwnSide.effects[:Safeguard] = 1
    @battle.pbDisplay(_INTL("¡Tu equipo se ha protegido con un velo místico!"))
    @battle.pbAnimation(:ENDURE, @battle.battlers[attacker.index], attacker.pbOppositeOpposing)
    @battle.battlers[attacker.index].effects[:ProtectRate] += 1
  end

end


################################################################################
# A-Gang Moves
################################################################################
class PokeBattle_Move_81B < PokeBattle_Move
  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    damage = opponent.totalhp if opponent.isbossmon && opponent.shieldCount > 0
    return opponent.totalhp
  end
end

################################################################################
# Vengeful Hex Blessing
################################################################################
class PokeBattle_Move_81C < PokeBattle_Move
  def initialize(*args)
    super(*args)
    @type = $cache.blessings[:VENGEFULHEX].values[:type]
    @basedamage = $cache.blessings[:VENGEFULHEX].values[:basedamage]
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
# Heals self and partner 1/2 of max hp (Lonely Moon (Rejuv))
################################################################################
class PokeBattle_Move_81D < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    noHeal = false
    noPartnerHeal = false
    fairyaura = @battle.pbCheckSideAbility(:FAIRYAURA, attacker).any?
    if opponent.effects[:MiracleEye] == false
      opponent.effects[:MiracleEye] = true
      @battle.pbDisplay(_INTL("¡Se ha identificado a {1}!", opponent.pbThis))
    end
    if @battle.battlers[attacker.index].effects[:HealBlock] > 0 || (@battle.battlers[attacker.index].status == :PETRIFIED && !fairyaura) || @battle.battlers[attacker.index].isFainted?
      @battle.pbDisplay(_INTL("¡Se ha impedido que {1} se cure!", @battle.battlers[attacker.index].pbThis))
      noHeal = true
    end
    if (@battle.battlers[attacker.index].hp == @battle.battlers[attacker.index].totalhp) && !noHeal
      @battle.pbDisplay(_INTL("¡Los PS de {1} están al máximo!", @battle.battlers[attacker.index].pbThis))
      noHeal = true
    end
    if !noHeal
      hpgain = (@battle.battlers[attacker.index].totalhp * 0.5).round
      @battle.battlers[attacker.index].pbRecoverHP(hpgain, true, message: _INTL("¡Los PS de {1} se han restaurado!", @battle.battlers[attacker.index].pbThis))
    end
    if attacker.pbPartner.effects[:HealBlock] > 0 || (attacker.pbPartner.status == :PETRIFIED && !fairyaura)
      @battle.pbDisplay(_INTL("¡Se ha impedido que {1} se cure!", attacker.pbPartner.pbThis))
      noPartnerHeal = true
    end
    noPartnerHeal = true if attacker.pbPartner.isFainted?
    if attacker.pbPartner.hp == attacker.pbPartner.totalhp && !noPartnerHeal
      @battle.pbDisplay(_INTL("¡Los PS de {1} están al máximo!", attacker.pbPartner.pbThis))
      noPartnerHeal = true
    end
    if !noPartnerHeal
      hpgain = (attacker.pbPartner.totalhp * 0.5).round
      attacker.pbPartner.pbRecoverHP(hpgain, true, message: _INTL("¡Los PS de {1} se han restaurado!", attacker.pbPartner.pbThis))
    end
  end
end

################################################################################
# (Tera Blast)
################################################################################
class PokeBattle_Move_81E < PokeBattle_Move
  def pbOnStartUse(attacker, targets)
    moldBrokenArray = [0, 1, 2, 3].map { |index| @battle.battlers[index].moldbroken }
    @category = self.smartDamageCategory(attacker, nil, moldBrokenArray: moldBrokenArray)
    return true
  end

  def pbIsPhysical?(attacker, type = @type)
    return @category == :physical
  end

  def pbIsSpecial?(attacker, type = @type)
    return @category == :special
  end

  def pbType(attacker, type = @type)
    type = attacker.teraTypeEffect ? attacker.teraTypeEffect.first : attacker.type1
    return super
  end

  # Replacement animation till a proper one is made
  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    id = :HIDDENPOWER
    movetype = pbType(attacker)
    animmovename = (id.to_s + movetype.to_s[0..2]).to_sym
    id = animmovename if $cache.moves[animmovename]
    super
  end
end

################################################################################
# (Rejuvenation)
################################################################################
class PokeBattle_Move_81F < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if @battle.pbOwnedByPlayer?(attacker.index) && $game_switches[:Nuzlocke_Mode] && !@battle.isOnline?
      @battle.pbDisplay(_INTL("¡Pero ha fallado!")) if showMessage
      return false
    end

    canRevive = false
    for pkmn in @battle.pbCombinedParty(attacker.index)
      canRevive = true if pkmn && pkmn.hp == 0 && !pkmn.isEgg?
    end
    if !canRevive || @battle.pbGetOwner(attacker.index).nil?
      @battle.pbDisplay(_INTL("¡Pero ha fallado!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    revive = @battle.pbShowCommands(_INTL("¿A quién quieres revivir?"), [_INTL("A ti mismo"), _INTL("A Melia")], 0)
    if revive == 0
      reviveindex = 0
    else
      reviveindex = 2
    end
    party = @battle.pbPartySingleOwner(reviveindex)
    index = @battle.pbRevive(reviveindex, @move, true)
    revivepoke = party[index]
    @battle.pbDisplay(_INTL("¡{1} ha revivido y está listo para volver a combatir!", revivepoke.name))

    if reviveindex == 0
      @battle.pbSendOutRevivedBattler(attacker, index)
    else
      @battle.pbSendOutRevivedBattler(attacker, index, reviveindex, true)
    end
  end
end


################################################################################
# Beast Hunter
################################################################################
class PokeBattle_Move_82A < PokeBattle_Move
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

ReplacementAnimations = {
  :BARBEDWEB => :TOXICTHREAD,
  :ETHEREALTEMPEST => :HURRICANE,
  :SLASHANDBURN => :POWERWHIP,
  :PYROKINESIS => :MYSTICALFIRE,
  :SOLARFLARE => :FIERYDANCE,
  :HOARFROSTMOON => :GLACIATE,
  :UPROOT => :FRENZYPLANT,
  :HEAVENLYWING => :WINGATTACK,
  :WAKEUPSHOCK => :ZINGZAP,
  :IRRITATION => :INFESTATION,
  :DELUGE => :BRINE,
  :COLDTRUTH => :BLIZZARD,
  :MUDBARRAGE => :MUDSLAP,
  :MATRIXSHOT => :POWERGEM,
  :VILEASSAULT => :POISONJAB,
  :FEVERPITCH => :BOOMBURST,
  :PROBOPOG => :BULLETSEED,
  :AQUABATICS => :DRAGONDANCE,
  :HEXINGSLASH => :SHADOWCLAW,
  :BUNRAKUBEATDOWN => :BEATUP,
  :QUICKSILVERSPEAR => :SACREDSWORD,
  :SPECTRALSCREAM => :OMINOUSWIND,
  :GILDEDARROW => :SACREDSWORD,
  :GILDEDHELIX => :SACREDSWORD,
  :MIRRORBEAM => :MIRRORSHOT,
  :UNLEASHEDPOWER => :GIGAIMPACT,
  :BLINDINGSPEED => :EXTREMESPEED,
  :DOMAINSHIFT => :MAGICROOM,
  :REJUVENATION => :MAGICROOM,
  :CHTHONICMALADY => :DARKVOID,
  :RADIANTCLAW => :PSYBLADE,
  :BEASTHUNTER => :BREAKINGSWIPE,
  :ELYSIANSHIELD => :AURORAVEIL,
  :CAUTERIZE => :SACREDFIRE,
  :LONELYMOON => :BLOODMOON,
  :INJECTION => :GIGADRAIN,
  :VORPALBLADE => :SACREDSWORD,
  :VENGEFULNUKE => :SINISTERARROWRAID,
}
################################################################################
# Z-Move damage
################################################################################
def ZMoveBaseDamage(basemove)
  return AtypicalZMoveBasePowers[basemove.move] if AtypicalZMoveBasePowers[basemove.move]

  base = basemove.basedamage
  case true
    when base < 56 then return 100
    when base < 66 then return 120
    when base < 76 then return 140
    when base < 86 then return 160
    when base < 96 then return 175
    when base < 101 then return 180
    when base < 111 then return 185
    when base < 126 then return 190
    when base < 131 then return 195
    else return 200
  end
end

AtypicalZMoveBasePowers = {
  :MEGADRAIN => 120,
  :WEATHERBALL => 160,
  :TERRAINPULSE => 160,
  :HEX => 160,
  :BARBBARRAGE => 160,
  :INFERNALPARADE => 160,
  :VCREATE => 220,
  :FLYINGPRESS => 170,
  :COREENFORCER => 140,
  :LANDSWRATH => 185,
  :THOUSANDARROWS => 180,
  # Variable Power Moves from now
  :ENDEAVOR => 160,
  :CRUSHGRIP => 190,
  :WRINGOUT => 190,
  :HARDPRESS => 180,
  :FLAIL => 160,
  :FRUSTRATION => 160,
  :NATURALGIFT => 160,
  :RETURN => 160,
  :TRUMPCARD => 160,
  :POWERTRIP => 160,
  :PUNISHMENT => 160,
  :ELECTROBALL => 160,
  :ERUPTION => 200,
  :HEATCRASH => 160,
  :GRASSKNOT => 160,
  :GYROBALL => 160,
  :HEAVYSLAM => 160,
  :LOWKICK => 160,
  :REVERSAL => 160,
  :MAGNITUDE => 140,
  :STOREDPOWER => 160,
  :WATERSPOUT => 200,
  :DRAGONENERGY => 200,
  # Multi-hit moves with base Z power above 100
  :TRIPLEKICK => 120,
  :DOUBLEHIT => 140,
  :BONERUSH => 140,
  :BULLETSEED => 140,
  :ICICLESPEAR => 140,
  :PINMISSILE => 140,
  :ROCKBLAST => 140,
  :TAILSLAP => 140,
  :SCALESHOT => 140,
  :SURGINGSTRIKES => 140,
  :DUALWINGBEAT => 160,
  :TWINBEAM => 160,
  :TRIPLEDIVE => 175,
  :GEARGRIND => 180,
  :TRIPLEAXEL => 190,
  :DOUBLEIRONBASH => 190,
  :DRAGONDARTS => 180,
  :TACHYONCUTTER => 180,
  :POPULATIONBOMB => 200,
  # OHKO moves
  :FISSURE => 180,
  :GUILLOTINE => 180,
  :HORNDRILL => 180,
  :SHEERCOLD => 180,
  # Rejuv-exclusive moves
  :FEVERPITCH => 140,
  :THUNDERRAID => 190,
  :MUDBARRAGE => 140,
  :IRRITATION => 160,
  # Desolation-exclusive moves
  :STARFALL => 140,
}

################################################################################
# Status Move Z-Power effects
################################################################################
def pbZStatus(battle, move, attacker)
  z_effect = ZSTATUSEFFECTS[move]

  # Curse normally boosts attack, but if ghost type it heals instead.
  if move == :CURSE && attacker.hasType?(:GHOST)
    z_effect = [:heal]
  end

  # Single stat boosting z-move
  if z_effect.length == 2
    attacker.pbChangeStats(z_effect[0], z_effect[1], attacker, nil, statmessage: :zpower, ignoreContrary: true)
    return
  end

  # Special effect
  case z_effect[0]
    when :allstat1
      increment = 1
      increment = 2 if battle.FE == :CITY && [:CONVERSION, :HAPPYHOUR, :CELEBRATE].include?(move)
      increment = 2 if battle.FE == :BACKALLEY && move == :CONVERSION
      stats = PBStats::Omni
      attacker.pbChangeStats(stats, increment, attacker, nil, statmessage: :zpower, ignoreContrary: true)
    when :crit1
      if attacker.effects[:FocusEnergy] < 3
        attacker.effects[:FocusEnergy] += 2
        attacker.effects[:FocusEnergy] = 3 if attacker.effects[:FocusEnergy] > 3
        battle.pbDisplay(_INTL("{1} boosted its critical-hit ratio using its Z-Power!", attacker.pbThis))
      end
    when :reset
      for i in PBStats::All
        if attacker.stages[i] < 0
          attacker.stages[i] = 0
        end
      end
      battle.pbDisplay(_INTL("{1} returned its decreased stats to normal using its Z-Power!", attacker.pbThis))
    when :heal
      attacker.pbRecoverHP(attacker.totalhp, false, message: _INTL("{1} restored its HP using its Z-Power!", attacker.pbThis), fullrecover: true)
    when :heal2
      attacker.effects[:ZHeal] = true
      battle.pbDisplay(_INTL("{1} will restore its replacement's HP using its Z-Power!", attacker.pbThis))
    when :centre
      attacker.effects[:FollowMe] = true
      if !attacker.pbPartner.isFainted?
        attacker.pbPartner.effects[:FollowMe] = false
        attacker.pbPartner.effects[:RagePowder] = false
        battle.pbDisplay(_INTL("{1} became the center of attention using its Z-Power!", attacker.pbThis))
      end
  end
end

def getStatusZMoveDesc(move)
  effect = ZSTATUSEFFECTS[move]
  if effect.length == 2
    stat = getStatName(effect[0], :desc)
    stages = effect[1]
    if stages == 1
      desc = _INTL("Z-Power additionally raises the user's {1} stat.", stat)
    else
      desc = _INTL("Z-Power additionally raises the user's {1} by {2} stages.", stat, stages)
    end
  elsif effect[0] == :allstat1
    desc = _INTL("Z-Power additionally raises all of the user's stats.")
  elsif effect[0] == :crit1
    desc = _INTL("Z-Power additionally raises the user's critical-hit rate.")
  elsif effect[0] == :reset
    desc = _INTL("Z-Power additionally eliminates any stat drops applied to the user.")
  elsif effect[0] == :heal
    desc = _INTL("Z-Power additionally fully restores the user's HP.")
  elsif effect[0] == :heal2
    desc = _INTL("Z-Power additionally fully restores the HP of the ally the user switches into.")
  elsif effect[0] == :centre
    desc = _INTL("Z-Power additionally causes the user to become the centre of attention.")
  else
    desc = _INTL("Z-Power does not grant any additional effects.")
  end
  if move == :CURSE
    desc += " " + _INTL("A Ghost-type user is fully healed instead.")
  elsif [:COPYCAT, :MEFIRST, :MIRRORMOVE].include?(move)
    desc += " " + _INTL("A copied damaging move becomes a Z-Move.")
  elsif PBStuff::CALLERMOVE.include?(move)
    desc += " " + _INTL("A called damaging move becomes a Z-Move.")
  end
  return desc
end

ZSTATUSEFFECTS = pbHashForwardizer({
  [PBStats::ATTACK, 1] => [
    :BULKUP, :CURSE, :HONECLAWS, :HOWL, :LASERFOCUS, :LEER, :MEDITATE, :ODORSLEUTH, :POWERTRICK, :ROTOTILLER, :SCREECH,
    :SHARPEN, :TAILWHIP, :TAUNT, :TOPSYTURVY, :WILLOWISP, :WORKUP, :COACHING, :POWERSHIFT, :DESERTSMARK, :SPICYEXTRACT,
  ],
  [PBStats::ATTACK, 2] => [:MIRRORMOVE, :OCTOLOCK],
  [PBStats::ATTACK, 3] => [:SPLASH],
  [PBStats::DEFENSE, 1] => [
    :AQUARING, :BABYDOLLEYES, :BANEFULBUNKER, :BLOCK, :CHARM, :DEFENDORDER, :FAIRYLOCK, :FEATHERDANCE,
    :FLOWERSHIELD, :GRASSYTERRAIN, :GROWL, :HARDEN, :MATBLOCK, :NOBLEROAR, :PAINSPLIT, :PLAYNICE, :POISONGAS,
    :POISONPOWDER, :QUICKGUARD, :REFLECT, :ROAR, :SPIDERWEB, :SPIKES, :SPIKYSHIELD, :STEALTHROCK, :STRENGTHSAP,
    :TEARFULLOOK, :TICKLE, :TORMENT, :TOXIC, :TOXICSPIKES, :VENOMDRENCH, :WIDEGUARD, :WITHDRAW, :ARENITEWALL,
    :BURNINGBULWARK, :SILKTRAP,
  ],
  [PBStats::SPATK, 1] => [
    :CONFUSERAY, :ELECTRIFY, :EMBARGO, :FAKETEARS, :GEARUP, :GRAVITY, :GROWTH, :INSTRUCT, :IONDELUGE,
    :METALSOUND, :MINDREADER, :MIRACLEEYE, :NIGHTMARE, :PSYCHICTERRAIN, :REFLECTTYPE, :SIMPLEBEAM, :SOAK, :SWEETKISS,
    :TEETERDANCE, :TELEKINESIS, :MAGICPOWDER,
  ],
  [PBStats::SPATK, 2] => [:HEALBLOCK, :PSYCHOSHIFT, :TARSHOT],
  [PBStats::SPATK, 3] => [],
  [PBStats::SPDEF, 1] => [
    :CHARGE, :CONFIDE, :COSMICPOWER, :CRAFTYSHIELD, :EERIEIMPULSE, :ENTRAINMENT, :FLATTER, :GLARE, :INGRAIN,
    :LIGHTSCREEN, :MAGICROOM, :MAGNETICFLUX, :MEANLOOK, :MISTYTERRAIN, :MUDSPORT, :SPOTLIGHT, :STUNSPORE, :THUNDERWAVE,
    :WATERSPORT, :WHIRLWIND, :WISH, :WONDERROOM, :CORROSIVEGAS, :SHELTER,
  ],
  [PBStats::SPDEF, 2] => [:AROMATICMIST, :CAPTIVATE, :IMPRISON, :MAGICCOAT, :POWDER],
  [PBStats::SPEED, 1] => [
    :AFTERYOU, :AURORAVEIL, :ELECTRICTERRAIN, :ENCORE, :GASTROACID, :GRASSWHISTLE, :GUARDSPLIT, :GUARDSWAP,
    :HAIL, :HYPNOSIS, :LOCKON, :LOVELYKISS, :POWERSPLIT, :POWERSWAP, :QUASH, :RAINDANCE, :ROLEPLAY, :SAFEGUARD,
    :SANDSTORM, :SCARYFACE, :SING, :SKILLSWAP, :SLEEPPOWDER, :SPEEDSWAP, :STICKYWEB, :STRINGSHOT, :SUNNYDAY,
    :SUPERSONIC, :TOXICTHREAD, :WORRYSEED, :YAWN, :SNOWSCAPE,
  ],
  [PBStats::SPEED, 2] => [:ALLYSWITCH, :BESTOW, :MEFIRST, :RECYCLE, :SNATCH, :SWITCHEROO, :TRICK],
  [PBStats::ACCURACY, 1] => [:COPYCAT, :DEFENSECURL, :DEFOG, :FOCUSENERGY, :MIMIC, :SWEETSCENT, :TRICKROOM, :DRAGONCHEER],
  [PBStats::EVASION, 1] => [:CAMOUFLAGE, :DETECT, :FLASH, :KINESIS, :LUCKYCHANT, :MAGNETRISE, :SANDATTACK, :SMOKESCREEN],
  [:allstat1] => [
    :CONVERSION, :FORESTSCURSE, :GEOMANCY, :PURIFY, :SKETCH, :TRICKORTREAT, :CELEBRATE, :TEATIME, :STUFFCHEEKS,
    :HAPPYHOUR, :HOLDHANDS,
  ],
  [:crit1] => [:ACUPRESSURE, :FORESIGHT, :HEARTSWAP, :SLEEPTALK, :TAILWIND],
  [:reset] => [
    :ACIDARMOR, :AGILITY, :AMNESIA, :ATTRACT, :AUTOTOMIZE, :BARRIER, :BATONPASS, :CALMMIND, :COIL, :COTTONGUARD,
    :COTTONSPORE, :DARKVOID, :DISABLE, :DOUBLETEAM, :DRAGONDANCE, :ENDURE, :FLORALHEALING, :FOLLOWME, :HEALORDER,
    :HEALPULSE, :HELPINGHAND, :IRONDEFENSE, :KINGSSHIELD, :LEECHSEED, :MILKDRINK, :MINIMIZE, :MOONLIGHT, :MORNINGSUN,
    :NASTYPLOT, :PERISHSONG, :PROTECT, :QUIVERDANCE, :RAGEPOWDER, :RECOVER, :REST, :ROCKPOLISH, :ROOST, :SHELLSMASH,
    :SHIFTGEAR, :SHOREUP, :SHELLSMASH, :SHIFTGEAR, :SHOREUP, :SLACKOFF, :SOFTBOILED, :SPORE, :SUBSTITUTE, :SWAGGER,
    :SWALLOW, :SWORDSDANCE, :SYNTHESIS, :TAILGLOW, :CLANGOROUSSOUL, :NORETREAT, :OBSTRUCT, :COURTCHANGE, :JUNGLEHEALING,
    :VICTORYDANCE, :AQUABATICS, :DOODLE, :TIDYUP,
  ],
  [:heal] => [
    :AROMATHERAPY, :BELLYDRUM, :CONVERSION2, :HAZE, :HEALBELL, :MIST, :PSYCHUP, :REFRESH, :SPITE, :STOCKPILE,
    :TELEPORT, :TRANSFORM, :DECORATE, :LIFEDEW, :LUNARBLESSING, :FILLETAWAY, :SHEDTAIL, :REVIVALBLESSING,
  ],
  [:heal2] => [:MEMENTO, :PARTINGSHOT, :CHILLYRECEPTION],
  [:centre] => [:DESTINYBOND, :GRUDGE],
})
ZSTATUSEFFECTS.default = []

################################################################################
# Acid Downpour
################################################################################
class PokeBattle_Move_800 < PokeBattle_Move
  # This wasteland interaction uses pbEffectTarget as opposed to pbAdditionalEffect to prevent acid downpour from being sheer force boosted
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if @battle.FE == :WASTELAND &&
       !opponent.isFainted? && !opponent.damagestate.substitute &&
       (opponent.ability != :SHIELDDUST || opponent.moldbroken) &&
       !opponent.hasWorkingItem(:COVERTCLOAK)
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
    end
  end
end

################################################################################
# Bloom Doom
################################################################################
class PokeBattle_Move_801 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.canChangeFE?([:GRASSY, :FOREST, *PBFields::FLOWERGARDEN])
      @battle.pbAnimation(:GRASSYTERRAIN, attacker, nil)
      @battle.setField(:GRASSY, 3, nil)
    end
  end
end

################################################################################
# Shattered Psyche
################################################################################
class PokeBattle_Move_802 < PokeBattle_Move
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    if @battle.FE == :PSYTERRAIN
      if opponent.pbCanConfuse?(attacker, self)
        opponent.pbConfuse(message: _INTL("The field got too weird for {1}!", opponent.pbThis(true)))
      end
    end
  end
end

################################################################################
# Stoked Sparksurfer
################################################################################
class PokeBattle_Move_803 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.canChangeFE?(:ELECTERRAIN)
      @battle.pbAnimation(:ELECTRICTERRAIN, attacker, nil)
      @battle.setField(:ELECTERRAIN, 3, nil)
    end
  end

  def pbAdditionalEffect(attacker, opponent)
    if opponent.pbCanParalyze?(attacker, self)
      opponent.pbParalyze(attacker)
    end
  end
end

################################################################################
# Extreme Evoboost
################################################################################
class PokeBattle_Move_804 < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return attacker.pbCanIncreaseAnyStat?(PBStats::Omni, attacker, self, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    stats = PBStats::Omni
    attacker.pbChangeStats(stats, 2, attacker, self)
  end
end

################################################################################
# Genesis Supernova
################################################################################
class PokeBattle_Move_805 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    if @battle.canChangeFE?(:PSYTERRAIN)
      @battle.pbAnimation(:PSYCHICTERRAIN, attacker, nil)
      @battle.setField(:PSYTERRAIN, 5, nil)
    end
  end
end

################################################################################
# Splintered Stormshards
################################################################################
class PokeBattle_Move_807 < PokeBattle_Move
  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.endTempFieldOrOverlay
  end
end

################################################################################
# Clangorous Soulblaze
################################################################################
class PokeBattle_Move_808 < PokeBattle_Move
  def pbAdditionalEffectSelf(attacker)
    stats = PBStats::Omni
    attacker.pbChangeStats(stats, 1, attacker, self, abilitycheck: :hide)
  end
end

################################################################################
# Guardian of Alola
################################################################################
class PokeBattle_Move_809 < PokeBattle_Move
  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] })
    opponent.damagestate.typemod = Typemod.normal
    hploss = (opponent.hp * 0.75).floor
    hploss = (opponent.totalhp * 0.75).floor if @battle.FE == :NEWWORLD
    if opponent.pbOwnSide.effects[:MatBlock] || opponent.effects[:Protect] ||
      (opponent.pbOwnSide.effects[:WideGuard] && [:AllOpposing, :AllNonUsers].include?(attacker.pbTarget(self)))
      feedbackMessages[opponent.index].push(:ProtectBreakZMove)
      hploss = (hploss / 4.0).floor
    end
    hploss = applyTradePowerForAcc(hploss, attacker, opponent)
    return hploss
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    id = case attacker.species
      when :TAPULELE then :GUARDIANOFALOLALELE
      when :TAPUBULU then :GUARDIANOFALOLABULU
      when :TAPUFINI then :GUARDIANOFALOLAFINI
      else id # Tapu Koko
    end
    super
  end
end

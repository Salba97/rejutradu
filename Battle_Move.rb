class PokeBattle_Move
  attr_accessor   :move
  attr_reader     :battle
  attr_accessor   :name
  attr_reader     :shortname
  attr_accessor   :data
  attr_accessor   :basemove
  attr_accessor   :pp
  attr_accessor   :totalpp
  attr_accessor   :zmove
  attr_reader     :user
  attr_reader     :function
  attr_accessor   :type
  attr_reader     :category
  attr_accessor   :basedamage
  attr_reader     :accuracy
  attr_reader     :maxpp
  attr_reader     :target
  attr_reader     :desc
  attr_accessor   :priority
  attr_reader     :effect
  attr_reader     :moreeffect
  attr_reader     :recoil
  attr_reader     :immediate
  attr_accessor   :category
  attr_accessor   :callermove

  attr_accessor   :specialmove
  attr_accessor   :chargetime

  ################################################################################
  # Creating a move
  ################################################################################
  def initialize(battle, move, user, zbase = nil)
    if user.is_a?(PokeBattle_Battler)
      # Move instance is serialized and sent over network for Online battles.
      # As such it can't contain Battler because it contains Battle which is not serializable.
      raise "move user needs to be PokeBattle_Pokemon"
    end

    @battle     = battle
    @move       = move.move
    @data       = $cache.moves[@move]
    @name       = getMoveName(@move) # Used in battle messages etc
    @shortname  = getMoveShortName(@move) # Used by fight menu buttons and move details display
    @desc       = getMoveDesc(@move)
    @basemove   = move
    @pp         = move.pp # Can be changed with Mimic/Transform
    @zmove      = false
    @immediate  = false
    @user       = user

    if @data
      @function   = @data.function
      @type       = @data.type
      @secondtype = @data.checkFlag?(:secondtype, nil)
      @category   = @data.category
      @basedamage = @data.basedamage
      @accuracy   = @data.accuracy
      @maxpp      = @data.maxpp
      @target     = @data.target
      @priority   = @data.priority ? @data.priority : 0
      @effect     = @data.checkFlag?(:effect, 0)
      @moreeffect = @data.checkFlag?(:moreeffect, 0)
      @recoil     = @data.checkFlag?(:recoil, 0)
      @specialmove = @data.checkFlag?(:specialmove)
      @chargetime = @data.checkFlag?(:chargetime, 0)
    end

    if !zbase.nil? ||  (PBStuff::INTERCEPTMOVES.include?(move.move) && user.item == :INTERCEPTZ)
      @zmove = true
      @zbasemove = zbase&.move # needed for z caller move messages
      if PBStuff::INTERCEPTMOVES.include?(move.move) && user.item != :INTERCEPTZ
        @maxpp = 1
        return
      end
      zmove = $cache.items[user.item].zmove
      unless PBStuff::INTERCEPTMOVES.include?(move.move) || $cache.moves[zmove].zmovedata.basemove # skip unique z moves
        @category   = zbase.category
        @name       = "Z-" + @name if zbase.basedamage == 0
        @shortname  = "Z-" + @shortname if zbase.basedamage == 0
        @basedamage = ZMoveBaseDamage(zbase) if zbase.basedamage > 0
        @maxpp      = 0
      end
    end
  end

  def contactMove?
    return hasFlag?(:contact)
  end

  def contactMoveWhenPhysical?
    return false
  end

  def canProtect?
    return !hasFlag?(:bypassprotect)
  end

  def canMagicCoat?
    return hasFlag?(:magiccoat)
  end

  def canSnatch?
    return hasFlag?(:snatchable)
  end

  def canMirror?
    return !hasFlag?(:nonmirror)
  end

  def canFlinch?
    return false
  end

  def canThawUser?
    return hasFlag?(:defrost)
  end

  def highCritRate?
    return hasFlag?(:highcrit)
  end

  def isHealingMove?
    return hasFlag?(:healingmove)
  end

  def isDrainingMove?
    return hasFlag?(:drainingmove)
  end

  def punchMove?
    return hasFlag?(:punchmove)
  end

  def isSoundBased?
    return hasFlag?(:soundmove)
  end

  def unusableInGravity?
    return hasFlag?(:gravityblocked)
  end

  def antiMinimize?
    return hasFlag?(:antiminimize)
  end

  def isBeamMove?
    return hasFlag?(:beammove)
  end

  def sharpMove?
    return hasFlag?(:sharpmove)
  end

  def windMove?
    return hasFlag?(:windmove)
  end

  def powderMove?
    return hasFlag?(:powdermove)
  end

  def danceMove?
    return hasFlag?(:dancemove)
  end

  def bulletMove?
    return hasFlag?(:ballmove) || hasFlag?(:bombmove)
  end

  def shotMove?
    return hasFlag?(:ballmove) || hasFlag?(:shotmove) || hasFlag?(:kickmove)
  end

  def bitingMove?
    return hasFlag?(:bitingmove)
  end

  def pulseMove?
    return hasFlag?(:pulsemove)
  end

  def explosiveMove?
    return hasFlag?(:explosivemove)
  end

  def mentalMove?
    return hasFlag?(:mentalmove)
  end

  def hasFlag?(flag)
    return @data.nil? ? false : @data.checkFlag?(flag)
  end

  # This is the code actually used to generate a PokeBattle_Move object.  The
  # object generated is a subclass of this one which depends on the move's
  # function code (found in the script section PokeBattle_MoveEffect).
  def PokeBattle_Move.pbFromPBMove(battle, move, user, zbase = nil)
    className = nil if !move
    className = sprintf("PokeBattle_Move_%03X", $cache.moves[move.move].function) if move
    if !className.nil?
      if Object.const_defined?(className)
        return Kernel.const_get(className).new(battle, move, user, zbase)
      else
        return PokeBattle_UnimplementedMove.new(battle, move, user, zbase)
      end
    else
      return nil
    end
  end

  ################################################################################
  # About the move
  ################################################################################
  def totalpp
    return @totalpp if @totalpp && @totalpp > 0
    return @basemove.totalpp if @basemove
  end

  def summaryType(attacker, type = @type) # Unused because we have pbType
    type = @basemove.summaryType(attacker.pokemon, type) if @basemove
    return type
  end

  def summaryPower(attacker, basedamage = @basedamage)
    basedamage = @basemove.summaryPower(attacker.pokemon, basedamage) if @basemove
    return basedamage
  end

  def usable?
    return @pp > 0 || self.totalpp == 0
  end

  def checkSoundMove?(attacker) # Use this method to check if the move is a sound move, rather than isSoundBased?
    return false if attacker.nil?
    return true if attacker.ability == :JUNGLEBEAT && self.pbType(attacker, @type) == :GRASS
    return true if isSoundBased?
    return false
  end

  def blockedBySubstitute?(attacker, opponent)
    return false if opponent.effects[:Substitute] == 0
    return false if hitsThroughSubstitute?(attacker)
    return true
  end

  def hitsThroughSubstitute?(attacker)
    return true if attacker.ability == :INFILTRATOR && ![:TRANSFORM, :SKYDROP].include?(@move)
    return true if checkSoundMove?(attacker)
    return true if Gen >= Champs && [:ACUPRESSURE, :MILKDRINK].include?(@move)
    return true if [:PLAYNICE, :SPECTRALTHIEF, :HYPERSPACEHOLE, :HYPERSPACEFURY].include?(@move)
    return false
  end

  def unseenFistCheck(attacker)
    return false if ![:UNSEENFIST, :PIERCINGDRILL].include?(attacker.ability) && @move != :BEASTHUNTER
    return attacker.makesContact?(self)
  end

  def pbType(attacker, type = @type)
    case @battle.FE
      when :ASHENBEACH        then type = :FIGHTING   if @move == :STRENGTH
      when :GLITCH            then type = Rejuv ? :QMARKS : :NORMAL if PBFields::GlitchTypes.include?(type)
      when :WATERSURFACE      then type = :WATER      if @move == :SHOREUP
      when :MURKWATERSURFACE  then type = :WATER      if [:MUDSLAP, :MUDBOMB, :MUDBARRAGE, :MUDSHOT, :THOUSANDWAVES, :SHOREUP].include?(@move)
      when :FAIRYTALE         then type = :STEEL      if [:SACREDSWORD, :CUT, :SLASH, :SECRETSWORD].include?(@move)
      when :STARLIGHT         then type = :FAIRY      if !Rejuv && [:SOLARBEAM, :SOLARBLADE].include?(@move)
      when :DIMENSIONAL       then type = :DARK       if @move == :RAGE
      when :FROZENDIMENSION   then type = :DARK       if @move == :RAGE
      when :DRAGONSDEN        then type = :ROCK       if Rejuv && [:ROCKCLIMB, :STRENGTH].include?(@move)
      when :DEEPEARTH         then type = :GROUND     if @move == :TOPSYTURVY
    end
    type = pbAbilityMoveTypeChange(@move, attacker.ability, type, @battle.FE)
    type = pbCrestMoveTypeChange(attacker.species, attacker.form, attacker.item, type)
    if attacker.effects[:Electrify] || (type == :NORMAL && @battle.state.effects[:IonDeluge])
      type = :ELECTRIC
    end
    return type
  end

  def pbIsPhysical?(attacker, type = @type)
    return !PBTypes.isSpecialType?(type) && @category != :status if @battle.FE == :GLITCH

    return @category == :physical
  end

  def pbIsSpecial?(attacker, type = @type)
    return PBTypes.isSpecialType?(type) && @category != :status if @battle.FE == :GLITCH

    return @category == :special
  end

  # Subclassed by Gravity and Topsy-Turvy for Deep Earth
  # Checking if a move is damaging or not should always be done via pbIsStatus?/pbIsDamaging? and not via basedamage checks (except when changing moves to z-moves because that complicates things too much)
  def pbIsStatus?
    return @category == :status
  end

  def pbIsDamaging?
    return !pbIsStatus?
  end

  def betterCategory(attacker, type = @type)
    return :physical if pbIsPhysical?(attacker, type)
    return :special if pbIsSpecial?(attacker, type)
    return :status if pbIsStatus?
    raise "move isn't physical, special or status"
  end

  def pbHitsSpecialStat?(attacker, type = @type)
    return !pbIsSpecial?(attacker, type) if @function == 0x122 # Psyshock/ Psystrike/ Secret Sword/ Matrix Shot

    return pbIsSpecial?(attacker, type)
  end

  def pbHitsPhysicalStat?(attacker, type = @type)
    return !pbIsPhysical?(attacker, type) if @function == 0x122 # Psyshock/ Psystrike/ Secret Sword/ Matrix Shot

    return pbIsPhysical?(attacker, type)
  end

  def pbTargetsAll?(attacker)
    if attacker.pbTarget(self) == :AllOpposing
      numtargets = 0
      numtargets += 1 if !attacker.pbOpposing1.isFainted?
      numtargets += 1 if !attacker.pbOpposing2.isFainted?
      return numtargets > 1
    elsif attacker.pbTarget(self) == :AllNonUsers
      numtargets = 0
      numtargets += 1 if !attacker.pbOpposing1.isFainted?
      numtargets += 1 if !attacker.pbOpposing2.isFainted?
      numtargets += 1 if !attacker.pbPartner.isFainted?
      return numtargets > 1
    end
    return false
  end

  def smartDamageType(attacker, opponent, types)
    return @type if types.length == 0 || !opponent

    types = types.uniq
    return types[0] if types.length == 1

    besttype = nil
    maxmod = 0
    types.each do |type|
      hitflags = [:Success]
      pbTypeImmunities(attacker, [opponent], hitflags, movetype: type)
      if hitflags.first == :Success
        @preEmptiveCalc = true
        tempmod = pbCalcDamage(attacker, opponent, movetype: type)
        @preEmptiveCalc = false
        if tempmod > maxmod
          maxmod = tempmod
          besttype = type
        end
      end
    end
    besttype = @type unless besttype
    return besttype
  end

  def smartDamageCategory(attacker, opponent, moldBrokenArray: nil)
    # if photon geyser gets to be more accurate in calculation than normal, then shell side arm also gets to as well
    oppUnaware = opponent&.ability == :UNAWARE
    makesContactWhenPhysical = attacker.makesContact?(self, assumePhysical: true) # Super UMD Move, Shell Side Arm

    # Calculates how much Attack and SpAtk attacker has
    calcattack = attacker.pbAttack(unaware: oppUnaware, moldBrokenArray: moldBrokenArray)
    if makesContactWhenPhysical
      calcattack *= 1.3 if attacker.ability == :TOUGHCLAWS
    end

    calcspatk = @battle.FE == :GLITCH && attacker.changeSpecialStat(unaware: oppUnaware, attacker: true, moldBrokenArray: moldBrokenArray) ?
      attacker.pbSpecialDefense(unaware: oppUnaware, attacker: true, moldBrokenArray: moldBrokenArray) :
      attacker.pbSpecialAttack(unaware: oppUnaware, attacker: true, moldBrokenArray: moldBrokenArray)
    # special attack boosts that apply regardless of the stat used
    for partner in @battle.pbCheckSideAbility(:BATTERY, attacker, excludeSelf: true)
      calcspatk *= Rejuv && @battle.FE == :ELECTERRAIN ? 1.5 : 1.3
    end
    calcspatk *= 1.5 if attacker.ability == :FLAREBOOST && (attacker.status == :BURN || [:BURNING, :VOLCANIC, :INFERNAL].include?(@battle.FE)) && @battle.FE != :FROZENDIMENSION

    # Photon Geyser/Light that burns the sky
    unless opponent
      return calcattack > calcspatk ? :physical : :special
    end

    # Calculates how much Defense and SpDef opponent has
    attUnaware = attacker&.ability == :UNAWARE
    calcdefense = opponent.pbDefense(unaware: attUnaware, moldBrokenArray: moldBrokenArray)
    if makesContactWhenPhysical
      calcdefense *= @battle.FE == :CLOUDS ? 4.0 : 2.0 if opponent.ability == :FLUFFY
      calcdefense *= 2.0 if opponent.ability == :AURAGUARD
    end

    calcspdef = @battle.FE == :GLITCH && opponent.changeSpecialStat(unaware: attUnaware, attacker: false, moldBrokenArray: moldBrokenArray) ?
      opponent.pbSpecialAttack(unaware: attUnaware, attacker: false, moldBrokenArray: moldBrokenArray) :
      opponent.pbSpecialDefense(unaware: attUnaware, attacker: false, moldBrokenArray: moldBrokenArray)
    calcspdef *= 2.0 if opponent.ability == :ICESCALES

    return (calcattack - calcdefense > calcspatk - calcspdef) ? :physical : :special
  end

  # These functions are intended to be subclassed
  def pbNumHits(attacker)
    return 1
  end

  def pbIsMultiHit # not the same as pbNumHits>1
    return false
  end

  def checkAccuracyEachHit(attacker)
    return false
  end

  def pbTwoTurnAttack(attacker)
    return false
  end

  def pbAdditionalEffect(attacker, opponent)
  end

  def pbAdditionalEffectSelf(attacker)
  end

  def pbSecondAdditionalEffect(attacker, opponent)
  end

  def pbCanUseWhileAsleep?
    return false
  end

  ################################################################################
  # This move's type effectiveness
  ################################################################################
  def pbTypeModifier(atype, attacker, opponent)
    typemod = Typemod.normal
    opptypes = opponent.types
    opptypes.delete(:FLYING) if opponent.effects[:Roost]
    opptypes.delete(:FIRE) if opponent.effects[:BurnUp]
    opptypes.delete(:ELECTRIC) if opponent.effects[:DoubleShock]
    opptypes = [:QMARKS] if opptypes.empty?
    # The method is used by the AI as well, so mold breaker checks have to be complete
    oppability = opponent.shouldBeMoldBroken?(attacker, self) ? nil : opponent.ability
    opppartnerability = opponent.pbPartner.shouldBeMoldBroken?(attacker, self) ? nil : opponent.pbPartner.ability

    opptypes.each do |opptype|
      mod = PBTypes.oneTypeEff(atype, opptype)
      if [:SCRAPPY, :MINDSEYE].include?(attacker.ability) || opponent.effects[:Foresight]
        mod = Typemod.normal if opptype == :GHOST && [:NORMAL, :FIGHTING].include?(atype)
      end
      if opponent.effects[:Ingrain] || opponent.effects[:SmackDown] || @battle.state.effects[:Gravity] != 0 || @battle.FE == :CAVE
        mod = Typemod.normal if opptype == :FLYING && atype == :GROUND
      else
        return Typemod.normal if atype == :GROUND && opptype == :FLYING && (opponent.hasWorkingItem(:IRONBALL) || [0x11C, 0x205].include?(@function)) # Smack Down / Thousand Arrows & Desert's Mark
      end
      if @battle.FE == :HOLY
        mod = Typemod.double if [:DARK, :GHOST].include?(opptype) && atype == :NORMAL
        mod = Typemod.double if opptype == :GHOST && @move == :SPIRITBREAK
      end
      if @battle.FE == :UNDERWATER
        mod = Typemod.normal if opptype == :WATER && atype == :WATER
      end
      if @battle.FE == :FAIRYTALE
        mod = Typemod.double if opptype == :DRAGON && atype == :STEEL
      end
      if @battle.FE == :GLITCH
        mod = Typemod.normal if atype == :DRAGON
        mod = Typemod.zero if atype == :GHOST && opptype == :PSYCHIC
        mod = Typemod.double if atype == :BUG && opptype == :POISON
        mod = Typemod.double if atype == :POISON && opptype == :BUG
        mod = Typemod.normal if atype == :ICE && opptype == :FIRE
        mod = Typemod.half if Rejuv && atype == :DARK && opptype == :STEEL
        mod = Typemod.half if Rejuv && atype == :GHOST && opptype == :STEEL
      end
      if @battle.FE == :HAUNTED
        mod = Typemod.normal if opptype == :NORMAL && atype == :GHOST
        mod = Typemod.double if opptype == :GHOST && @move == :SPIRITBREAK
      end
      if @battle.FE == :BEWITCHED
        mod = Typemod.normal if opptype == :GRASS && atype == :POISON
        mod = Typemod.double if opptype == :STEEL && atype == :FAIRY
        mod = Typemod.normal if opptype == :DARK && atype == :FAIRY
        mod = Typemod.normal if opptype == :FAIRY && atype == :DARK
      end
      if @battle.FE == :SKY
        mod = Typemod.double if opptype == :FLYING && @move == :BONEMERANG
        mod = Typemod.double if opptype == :FLYING && attacker.ability == :LONGREACH
      end
      if (!Rejuv && @battle.FE == :FOREST) || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5)
        mod = Typemod.double if opptype == :GRASS && @move == :CUT
      end
      if @battle.FE == :INFERNAL
        mod = Typemod.double if opptype == :GHOST && atype == :FIRE
      end
      if @battle.FE == :DEEPEARTH
        mod = Typemod.half if atype == :GROUND && opptype == :GROUND
      end
      if @battle.FE == :DEUXFINALIS
        mod = Typemod.half if opptype == :ROCK && atype == :GHOST
        mod = Typemod.normal if atype == :FAIRY
      end
      if Rejuv && @battle.FE == :ELECTERRAIN
        mod = Typemod.normal if opptype == :GROUND && atype == :ELECTRIC && attacker.ability == :TERAVOLT
      end
      if opponent.effects[:MiracleEye]
        mod = Typemod.normal if opptype == :DARK && atype == :PSYCHIC
      end
      if opponent.hasWorkingItem(:RINGTARGET)
        mod = Typemod.normal if mod.immune?
      end

      # Inversemode password/field
      if @battle.inverse?
        mod = mod.inverse
      end
      if opponent.crested == :TORTERRA
        mod = mod.inverse unless mod.immune?
      end
      # effects that remove type weaknesses, what is a type weakness changes if inverse battle applies or not so needs to be checked after
      if @battle.pbWeather(attacker) == :STRONGWINDS
        mod = Typemod.normal if opptype == :FLYING && mod.superEffective?
      end
      if @battle.FE == :DARKNESS3
        mod = Typemod.normal if [:DARK, :GHOST].include?(opptype) && mod.superEffective?
      end
      if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 4, 5)
        mod = Typemod.normal if opptype == :GRASS && mod.superEffective?
      end
      if @battle.FE == :SNOWYMOUNTAIN || @battle.FE == :ICY
        mod = Typemod.normal if opptype == :ICE && oppability == :ICESCALES && mod.superEffective?
      end
      if @battle.FE == :DRAGONSDEN
        mod = Typemod.normal if opptype == :DRAGON && oppability == :MULTISCALE && mod.superEffective?
        mod = Typemod.normal if opptype == :STEEL && oppability == :GOODASGOLD && mod.superEffective?
      end
      if @battle.FE == :BEWITCHED
        mod = Typemod.normal if opptype == :FAIRY && (oppability == :PASTELVEIL || opppartnerability == :PASTELVEIL) && mod.superEffective?
      end
      # effects that ignore Inverse battles entirely
      if @move == :VENAMSKISS
        mod = Typemod.double if opptype == :STEEL
      end

      # Unown Buster
      if @battle.FE == :GLITCH
        mod = Typemod.double if opptype == :QMARKS && @move == :VORPALBLADE
      end
      if @move == :FREEZEDRY
        mod = Typemod.double if opptype == :WATER
      end
      if @move == :LONELYMOON
        mod = Typemod.double if opptype == :DARK
      end
      if oppability == :REFLECTOR
        mod = Typemod.half if !mod.immune? && opptype == atype && opponent.effects[:ReflectorTypes]&.include?(atype)
      end

      typemod *= mod
    end

    shadowtarget = (opponent.isShadow? rescue false)
    if shadowtarget
      typemod *= Typemod.double if atype == :FAIRY
      typemod *= Typemod.half if atype == :SHADOW
    else
      typemod *= Typemod.double if atype == :SHADOW && !opptypes.include?(:FAIRY) && opponent.crested != :TORTERRA
      typemod *= Typemod.half if atype == :SHADOW && opponent.crested == :TORTERRA
    end

    if opponent.isTerastallized?
      typemod *= Typemod.double if atype == :STELLAR
    end

    return typemod
  end

  def pbTypeImmunities(attacker, targets, hitflags, movetype: nil)
    primaryType = movetype ? movetype : pbType(attacker)
    types = [primaryType, *getSecondaryType(attacker, primaryType)]
    # type negated, target gains +1 Attack
    targets.each_with_index do |opponent, i|
      next if hitflags[i] != :Success
      next unless pbShouldApplyTypeImmunity?(attacker, opponent)
      if types.include?(:GROUND)
        hitflags[i] = :SapSipperItem if opponent.crested == :SKUNTANK
      end
      if types.include?(:GRASS)
        hitflags[i] = :SapSipperItem if opponent.crested == :WHISCASH
        hitflags[i] = :SapSipperAbility if opponent.ability == :SAPSIPPER && !opponent.moldbroken
      end
    end
    return if attacker.successCheckFinished?(targets, hitflags, self)
    # type negated; target gains +1 Special attack
    targets.each_with_index do |opponent, i|
      next if hitflags[i] != :Success
      next unless pbShouldApplyTypeImmunity?(attacker, opponent)
      next if opponent.moldbroken
      if types.include?(:WATER)
        hitflags[i] = :DrainRod if opponent.ability == :STORMDRAIN
      end
      if types.include?(:ELECTRIC)
        hitflags[i] = :DrainRod if opponent.ability == :LIGHTNINGROD
      end
    end
    return if attacker.successCheckFinished?(targets, hitflags, self)
    # type negated, target gains +1 Speed
    targets.each_with_index do |opponent, i|
      next if hitflags[i] != :Success
      next unless pbShouldApplyTypeImmunity?(attacker, opponent)
      if types.include?(:ELECTRIC)
        hitflags[i] = :MotorDriveItem if Rejuv && @battle.FE == :GLITCH && opponent.species == :GENESECT && opponent.hasWorkingItem(:SHOCKDRIVE)
        hitflags[i] = :MotorDriveAbility if opponent.ability == :MOTORDRIVE && !opponent.moldbroken
      end
    end
    return if attacker.successCheckFinished?(targets, hitflags, self)
    # type negated, defense is raied by 2
    targets.each_with_index do |opponent, i|
      next if hitflags[i] != :Success
      next unless pbShouldApplyTypeImmunity?(attacker, opponent)
      if types.include?(:FIRE)
        next if opponent.moldbroken
        hitflags[i] = :WellBakedBody if opponent.ability == :WELLBAKEDBODY
      end
    end
    return if attacker.successCheckFinished?(targets, hitflags, self)
    # type negated; target recovers HP
    targets.each_with_index do |opponent, i|
      next if hitflags[i] != :Success
      next unless pbShouldApplyTypeImmunity?(attacker, opponent)
      if types.include?(:WATER)
        if Rejuv
          hitflags[i] = :HpAbsorbField if @battle.FE == :DESERT && (opponent.hasType?(:GRASS) || opponent.hasType?(:WATER)) && @battle.pbWeather(attacker) == :SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
          hitflags[i] = :HpAbsorbItem if @battle.FE == :GLITCH && opponent.species == :GENESECT && opponent.hasWorkingItem(:DOUSEDRIVE)
        end
        hitflags[i] = :HpAbsorbAbility if [:DRYSKIN, :WATERABSORB].include?(opponent.ability) && !opponent.moldbroken
      end
      if types.include?(:ICE)
        hitflags[i] = :HpAbsorbItem if Rejuv && @battle.FE == :GLITCH && opponent.species == :GENESECT && opponent.hasWorkingItem(:CHILLDRIVE)
      end
      if types.include?(:ELECTRIC)
        hitflags[i] = :HpAbsorbAbility if opponent.ability == :VOLTABSORB && !opponent.moldbroken
      end
      if types.include?(:FIRE)
        hitflags[i] = :HpAbsorbItem if opponent.crested == :DRUDDIGON
      end
      if types.include?(:GROUND)
        hitflags[i] = :HpAbsorbAbility if opponent.ability == :EARTHEATER && !opponent.moldbroken
      end
      if types.include?(:GHOST) || ([:DIMENSIONAL, :INFERNAL].include?(@battle.FE) && types.include?(:DARK))
        hitflags[i] = :HpAbsorbAbility if opponent.ability == :SOULEATER && !opponent.moldbroken
      end
    end
    return if attacker.successCheckFinished?(targets, hitflags, self)
    # type negated; fire moves are boosted
    if @battle.FE != :FROZENDIMENSION
      targets.each_with_index do |opponent, i|
        next if hitflags[i] != :Success
        next unless pbShouldApplyTypeImmunity?(attacker, opponent)
        if types.include?(:FIRE)
          hitflags[i] = :FlashFireItem if Rejuv && @battle.FE == :GLITCH && opponent.species == :GENESECT && opponent.hasWorkingItem(:BURNDRIVE)
          hitflags[i] = :FlashFireAbility if opponent.ability == :FLASHFIRE && !opponent.moldbroken
        end
      end
      return if attacker.successCheckFinished?(targets, hitflags, self)
    end
    # rock type move negated; fire moves are boosted
    targets.each_with_index do |opponent, i|
      next if hitflags[i] != :Success
      if types.include?(:ROCK)
        hitflags[i] = :CoalFurnace if opponent.ability == :COALFURNACE && !opponent.moldbroken
      end
    end
    return if attacker.successCheckFinished?(targets, hitflags, self)
    # type negated, no effect
    targets.each_with_index do |opponent, i|
      next if hitflags[i] != :Success
      next unless pbShouldApplyTypeImmunity?(attacker, opponent)
      if types.include?(:FIRE) && [:VOLCANICTOP, :DRAGONSDEN, :INFERNAL].include?(@battle.FE)
        hitflags[i] = :MagmaArmor if opponent.ability == :MAGMAARMOR && !opponent.moldbroken
      end
    end
    return if attacker.successCheckFinished?(targets, hitflags, self)
    # Soundproof (not really a type immunity, but the timing works out)
    if checkSoundMove?(attacker)
      targets.each_with_index do |opponent, i|
        next if hitflags[i] != :Success
        # Should not use pbShouldApplyTypeImmunity?
        next if Gen >= 8 && opponent == attacker # Soundproof doesn't block user's own moves since Gen 8
        next if opponent.moldbroken
        hitflags[i] = :Soundproof if opponent.ability == :SOUNDPROOF
        hitflags[i] = :ProtectiveRime if opponent == attacker.pbPartner && attacker.ability == :PROTECTIVERIME
        hitflags[i] = :SoundproofCrest if opponent == attacker.pbPartner && @battle.pbCheckSideCrest(:FLYGON, opponent, excludeSelf: false).any?
      end
      return if attacker.successCheckFinished?(targets, hitflags, self)
    end
    # Wonder Guard, type chart immunity, and various Ground immunities
    # Since these apply only to damaging moves, there's no reason to use pbShouldApplyTypeImmunity?
    if @function != 0x02 # Struggle
      typemods = targets.map { |target | pbCalcTypeMod(types[0], attacker, target)}
      if pbIsDamaging?
        targets.each_with_index do |opponent, i|
          next if hitflags[i] != :Success
          next if opponent.moldbroken
          next if typemods[i].superEffective?
          hitflags[i] = :WonderGuard if opponent.ability == :WONDERGUARD
        end
        return if attacker.successCheckFinished?(targets, hitflags, self)
      end
      if @move == :THUNDERWAVE || pbIsDamaging?
        targets.each_with_index do |opponent, i|
          next if hitflags[i] != :Success
          hitflags[i] = :TypeImmunity if typemods[i].immune?
        end
        return if attacker.successCheckFinished?(targets, hitflags, self)
      end
      if pbIsDamaging?
        if @battle.FE != :CAVE && types.include?(:GROUND) && ![0x11C, 0x205].include?(@function) # Smack Down / Thousand Arrows & Desert's Mark
          targets.each_with_index do |opponent, i|
            next if hitflags[i] != :Success
            next if opponent.hasWorkingItem(:RINGTARGET)
            next if !opponent.isAirborne?
            hitflags[i] = :Telekinesis if opponent.effects[:Telekinesis] > 0
            hitflags[i] = :MagnetRise if opponent.effects[:MagnetRise] > 0
            hitflags[i] = :AirBalloon if opponent.hasWorkingItem(:AIRBALLOON)
            next if opponent.moldbroken
            levitationAbilities = @battle.FE == :DEEPEARTH ? [:UNAWARE, :OBLIVIOUS, :MAGNETPULL, :CONTRARY, :GRAVITYCONTROL] : PBStuff::LevitateAbilities
            hitflags[i] = :Levitate if levitationAbilities.include?(opponent.ability)
          end
          return if attacker.successCheckFinished?(targets, hitflags, self)
        end
      end
    end
  end

  def pbShouldApplyTypeImmunity?(attacker, opponent)
    return false if opponent == attacker
    return false if attacker.pbTarget(self) == :AllyBattlers && opponent == attacker.pbPartner
    return false if self.type == :FIRE && attacker.ability == :WILDFIRE && @battle.FE == :INFERNAL
    return true
  end

  def irregularTypeMods(attacker, opponent, typemod, type)
    case opponent.crested
      when :GLACEON
        typemod = Typemod.half if [:FIGHTING, :ROCK].include?(type)
      when :LEAFEON
        typemod = Typemod.half if [:FIRE, :FLYING].include?(type)
      when :LUXRAY
        typemod *= Typemod.half if PBTypes.oneTypeEff(type, :DARK, inverse: @battle.inverse?).resisted?
        typemod = Typemod.zero if PBTypes.oneTypeEff(type, :DARK, inverse: @battle.inverse?).immune?
      when :SAMUROTT
        typemod *= Typemod.half if PBTypes.oneTypeEff(type, :FIGHTING, inverse: @battle.inverse?).resisted?
        typemod = Typemod.zero if PBTypes.oneTypeEff(type, :FIGHTING, inverse: @battle.inverse?).immune?
      when :SIMISEAR
        unless type == :WATER && @battle.FE == :UNDERWATER && !@battle.inverse?
          typemod *= Typemod.half if PBTypes.oneTypeEff(type, :WATER, inverse: @battle.inverse?).resisted?
        end
        typemod = Typemod.zero if PBTypes.oneTypeEff(type, :WATER, inverse: @battle.inverse?).immune?
      when :SIMIPOUR
        typemod *= Typemod.half if PBTypes.oneTypeEff(type, :GRASS, inverse: @battle.inverse?).resisted?
        typemod = Typemod.zero if PBTypes.oneTypeEff(type, :GRASS, inverse: @battle.inverse?).immune?
      when :SIMISAGE
        unless type == :ICE && @battle.FE == :GLITCH && !@battle.inverse?
          typemod *= Typemod.half if PBTypes.oneTypeEff(type, :FIRE, inverse: @battle.inverse?).resisted?
        end
        typemod = Typemod.zero if PBTypes.oneTypeEff(type, :FIRE, inverse: @battle.inverse?).immune?
    end
    case opponent.item
      when :SOULDEW
        typemod = Typemod.half if [:DARK, :GHOST].include?(type) && PBStuff::DimensionalFields.include?(@battle.FE) && [:LATIAS, :LATIOS].include?(opponent.species)
    end
    if opponent.teraTypeEffect

      opponent.teraTypeEffect.each do |teratype|
        typemod *= Typemod.half if PBTypes.oneTypeEff(type, teratype, inverse: @battle.inverse?).resisted?
        typemod = Typemod.zero if PBTypes.oneTypeEff(type, teratype, inverse: @battle.inverse?).immune?
        if opponent.effects[:Ingrain] || opponent.effects[:SmackDown] || @battle.state.effects[:Gravity] != 0 || @battle.FE == :CAVE
          typemod = Typemod.normal if teratype == :FLYING && type == :GROUND
        else
          typemod = Typemod.normal if type == :GROUND && teratype == :FLYING && (opponent.hasWorkingItem(:IRONBALL) || [0x11C, 0x205].include?(@function)) # Smack Down / Thousand Arrows & Desert's Mark
        end
      end
    end
    typemod *= Typemod.double if type == :FIRE && opponent.effects[:TarShot]
    return typemod
  end

  def pbCalcTypeMod(type, attacker, opponent)
    typemod = pbTypeModifier(type, attacker, opponent)
    # Resistance-changing Crests
    typemod = irregularTypeMods(attacker, opponent, typemod, type)
    if @secondtype
      if @secondtype == :FLYING && @battle.FE == :SKY
        typemod *= Typemod.double if @battle.inverse? ? PBTypes.oneTypeEff(@secondtype, opponent.type1).resistedOrImmune? : PBTypes.oneTypeEff(@secondtype, opponent.type1).superEffective?
        typemod *= Typemod.double if @battle.inverse? ? PBTypes.oneTypeEff(@secondtype, opponent.type1).resistedOrImmune? : PBTypes.oneTypeEff(@secondtype, opponent.type1).superEffective?
      else
        typemod2 = pbTypeModifier(@secondtype, attacker, opponent)
        typemod2 = irregularTypeMods(attacker, opponent, typemod2, @secondtype)
        typemod *= typemod2
      end
    end
    # Field Effect second type changes
    typemod = fieldTypeChangeModifier(attacker, opponent, type, typemod)
    typemod = overlayTypeChangeModifier(attacker, opponent, type, typemod)

    return typemod
  end

  def fieldTypeChange(attacker, type, placeholders: false)
    case @battle.FE
      when :RAINBOW # Rainbow Field
        if type == :NORMAL && pbIsSpecial?(attacker, type)
          moddedtype = placeholders ? :RAINBOW : @battle.field.getRoll(update_roll: @battle.phase == :attackPhase && !@preEmptiveCalc)
        end
      when :CORROSIVEMIST # Corrosive Mist Field
        if type == :FLYING && !pbIsPhysical?(attacker, type)
          moddedtype = :POISON
        end
      when :SHORTCIRCUIT # Shortcircuit Field
        if type == :STEEL && attacker.ability == :STEELWORKER
          moddedtype = :ELECTRIC
        end
      when :CRYSTALCAVERN # Crystal Cavern
        if type == :ROCK || [:JUDGMENT, :ROCKCLIMB, :STRENGTH, :MULTIATTACK, :PRISMATICLASER, :TERABLAST, :TERASTARSTORM].include?(@move)
          moddedtype = placeholders ? :CRYSTAL : @battle.field.getRoll(update_roll: @battle.phase == :attackPhase && !@preEmptiveCalc)
        end
    end
    if !moddedtype
      fieldmove = @battle.field.moveData(@move)
      moddedtype = fieldmove[:typemod] if fieldmove
    end
    if !moddedtype # if moddedtype is STILL nil
      fieldtype = @battle.field.typeData(type)
      moddedtype = fieldtype[:typemod] if fieldtype
    end
    return moddedtype
  end

  def fieldTypeChangeModifier(attacker, opponent, type, typemod)
    moddedtype = fieldTypeChange(attacker, type)
    return typemod if !moddedtype

    newtypemod = pbTypeModifier(moddedtype, attacker, opponent)
    newtypemod = irregularTypeMods(attacker, opponent, newtypemod, moddedtype)
    return typemod * newtypemod
  end

  def overlayTypeChange(attacker, type, placeholders: false)
    return if !Overlays
    return if @battle.OV.nil?
    if @battle.OV == :RAINBOW && type == :NORMAL && pbIsSpecial?(attacker, type)
      return placeholders ? :RAINBOW : @battle.field.getOVRoll(update_roll: @battle.phase == :attackPhase && !@preEmptiveCalc)
    end
    return nil if $cache.FEData[@battle.OV].overlaymovedata.empty?
    overlaymove = $cache.FEData[@battle.OV].overlaymovedata[@move]
    moddedtype = overlaymove ? overlaymove[:typemod] : nil
    return moddedtype
  end

  def overlayTypeChangeModifier(attacker, opponent, type, typemod)
    return typemod if !Overlays
    moddedtype = overlayTypeChange(attacker, type)
    return typemod if !moddedtype

    newtypemod = pbTypeModifier(moddedtype, attacker, opponent)
    newtypemod = irregularTypeMods(attacker, opponent, newtypemod, moddedtype)
    return typemod * newtypemod
  end

  def getSecondaryType(attacker, type, placeholders: false)
    secondtypes = []
    secondtypes.push(@secondtype) if @secondtype
    fieldtype = fieldTypeChange(attacker, type, placeholders: placeholders)
    secondtypes.push(fieldtype) if fieldtype
    overlaytype = overlayTypeChange(attacker, type, placeholders: placeholders)
    secondtypes.push(overlaytype) if overlaytype
    secondtypes = [secondtypes[0], secondtypes[1]] if secondtypes.length > 2
    return secondtypes
  end

  ################################################################################
  # This move's accuracy check
  ################################################################################
  def pbBaseAccuracy(baseacc, attacker, opponent)
    return baseacc
  end

  def pbCalcAccuracy(attacker, opponent)
    # Perfect accuracy conditions
    return -1 if [:NOGUARD, :HOTSHOT, :DEFRAGMENT].include?(attacker.ability) || [:NOGUARD, :HOTSHOT].include?(opponent.ability) || (attacker.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE) || (attacker.ability == :DARKAURA && @battle.FE == :DEUXFINALIS)
    return -1 if attacker.effects[:LockOnTarget] == opponent.index
    return -1 if opponent.effects[:GlaiveRush]

    if @function != 0x70
      # OHKO moves get perfect acc only from No Guard, Lock On and Glaive Rush in canon (not Telekinesis)
      return -1 if opponent.effects[:Telekinesis] > 0
      return -1 if opponent.effects[:Minimize] && antiMinimize?
      return -1 if @battle.FE == :UNDERWATER && pbType(attacker) == :ELECTRIC
    end

    # Base accuracy + Move-specific modifications
    baseaccuracy = pbBaseAccuracy(self.accuracy, attacker, opponent)
    # If an effect makes the move perfectly accurate, no need to apply field mods
    # Examples: Blizzard on Glitch + Snow, Toxic on Corromist by poison type.
    return -1 if baseaccuracy == 0

    # Field modifications
    fieldmovedata = @battle.field.moveData(@move)
    baseaccuracy = fieldmovedata[:accmod] if fieldmovedata && fieldmovedata[:accmod]
    return -1 if baseaccuracy == 0

    # Wonder Skin
    if pbIsStatus? && (opponent.ability == :WONDERSKIN || (Rejuv && @battle.FE == :PSYTERRAIN && opponent.ability == :MAGICIAN)) && !opponent.moldbroken
      return 0 if opponent.ability == :WONDERSKIN && @battle.FE == :RAINBOW
      baseaccuracy = 50 if baseaccuracy > 50
    end

    return baseaccuracy if @function == 0x70 # OHKO moves skip all the checks below

    accmult, stagemult, miclemult = [], 1.0, []

    # Ashen Beach acc/eva bypass
    if @battle.FE == :ASHENBEACH && [:OWNTEMPO, :INNERFOCUS, :PUREPOWER, :SANDVEIL, :STALWART, :STEADFAST].include?(attacker.ability) && !PBStuff::UnnerveAbilities.include?(opponent.ability)
      return pbCalcFinalAccuracy(baseaccuracy, accmult, stagemult, miclemult)
    end

    # Accuracy modifiers
    accmult.append(1.67) if @battle.state.effects[:Gravity] != 0
    accmult.append(0.5) if opponent.ability == :TANGLEDFEET && opponent.effects[:Confusion] > 0 && !opponent.moldbroken
    accmult.append([:BACKALLEY, :CITY].include?(@battle.FE) ? 0.67 : 0.8) if attacker.ability == :HUSTLE && pbIsPhysical?(attacker, pbType(attacker))
    accmult.append(0.8) if opponent.ability == :SANDVEIL && (@battle.pbWeather(attacker) == :SANDSTORM || [:DESERT, :ASHENBEACH].include?(@battle.FE)) && !opponent.moldbroken
    accmult.append(0.8) if opponent.ability == :SNOWCLOAK && ([:HAIL, :SNOW].include?(@battle.pbWeather(attacker)) || [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION].include?(@battle.FE) || opponent.crested == :GLACEON) && !opponent.moldbroken
    for abilityholder in @battle.pbCheckSideAbility(:VICTORYSTAR, attacker)
      accmult.append(1.1)
    end
    accmult.append(1.3) if attacker.ability == :COMPOUNDEYES
    accmult.append(0.9) if attacker.ability == :LONGREACH && (@battle.FE == :ROCKY || (!Rejuv && @battle.FE == :FOREST))
    accmult.append(0.9) if opponent.hasWorkingItem(:BRIGHTPOWDER)
    accmult.append(0.9) if opponent.hasWorkingItem(:LAXINCENSE)
    accmult.append(1.1) if attacker.hasWorkingItem(:WIDELENS)
    accmult.append(1.2) if attacker.hasWorkingItem(:ZOOMLENS) && opponent.hasMovedThisRound? && !@battle.switchedOut[opponent.index]
    accmult.append(1.5) if [:HYPNO, :STANTLER, :WYRDEER].include?(attacker.crested)

    # Accuracy/Evasion stages
    accstage = attacker.stages[PBStats::ACCURACY]
    accstage = 0 if opponent.ability == :UNAWARE && !opponent.moldbroken
    evastage = opponent.stages[PBStats::EVASION]
    evastage = 0 if opponent.effects[:Foresight] || opponent.effects[:MiracleEye] ||
                    @function == 0xA9 || # Chip Away
                    [:UNAWARE, :KEENEYE, :MINDSEYE].include?(attacker.ability) ||
                    (attacker.ability == :ILLUMINATE && Gen >= 9)
    accstage -= evastage
    accstage = accstage.clamp(-6, 6)
    stagemult = accstage >= 0 ? (accstage + 3) / 3.0 : 3.0 / (3 - accstage)

    # Micle Berry
    miclemult.append(1.2) if attacker.effects[:MicleBerry]

    return pbCalcFinalAccuracy(baseaccuracy, accmult, stagemult, miclemult)
  end

  def pbAccuracyCheck(attacker, opponent)
    return true if self.tradePowerForAcc?
    accuracy = pbCalcAccuracy(attacker, opponent)
    return false if accuracy == 0
    return accuracy < 0 || accuracy >= 100 || @battle.pbRandom(100) < accuracy
  end

  def invulMisses?(attacker, opponent)
    return false unless opponent.isSemiInvul?

    return false if @move == :TOXIC && attacker.hasType?(:POISON)
    return false if [:NOGUARD, :HOTSHOT].include?(attacker.ability) || [:NOGUARD, :HOTSHOT].include?(opponent.ability) || (attacker.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE) || (attacker.ability == :DARKAURA && @battle.FE == :DEUXFINALIS)
    return false if attacker.effects[:LockOnTarget] == opponent.index

    invulmove = opponent.effects[:TwoTurnAttack]
    case invulmove
      when *PBStuff::TWOTURNAIRMOVE then return false if PBStuff::AIRHITMOVES.include?(@move)
      when :DIG then return false if [:EARTHQUAKE, :MAGNITUDE, :FISSURE].include?(@move)
      when :DIVE then return false if [:SURF, :WHIRLPOOL].include?(@move)
      when :PHANTOMFORCE, :SHADOWFORCE # no moves that bypass
    end
    if opponent.effects[:SkyDrop] # pokemon being sky dropped
      return false if PBStuff::AIRHITMOVES.include?(@move) || attacker.effects[:SkyDroppee] == opponent
    end
    return true
  end

  ################################################################################
  # Damage calculation and modifiers
  ################################################################################
  def pbCritRate?(attacker, opponent, moldbroken = opponent.moldbroken)
    return -1 if self.pbIsStatus? # for AI
    return -1 if self.is_a?(PokeBattle_Confusion)
    return -1 if [:BATTLEARMOR, :SHELLARMOR].include?(opponent.ability) && !moldbroken
    return -1 if opponent.pbOwnSide.effects[:LuckyChant] > 0
    return 3 if attacker.effects[:LaserFocus] > 0 || [0xA0, 0x319].include?(@function) # Frost Breath, Surging Strikes
    return 3 if @function == 0x201 && attacker.hp <= (attacker.totalhp * 0.5).floor # Gale Strike
    return 3 if attacker.ability == :MERCILESS && (opponent.status == :POISON || [:CORROSIVEMIST].include?(@battle.FE) || ([:CORROSIVE, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE) && !attacker.isAirborne?))
    return 3 if [:RATTLED, :WIMPOUT].include?(opponent.ability) && @battle.FE == :COLOSSEUM
    return 3 if @battle.pbCheckSideAbility(:CHIFOCUS, attacker, checkMoldBroken: true).any? && @battle.FE == :ASHENBEACH
    return 3 if attacker.crested == :ARIADOS && (opponent.status == :POISON || opponent.stages[PBStats::SPEED] < 0) # ariados crest
    return 3 if attacker.ability == :QUICKDRAW && attacker.effects[:QuickDrawSnipe]

    c = 0
    c += attacker.effects[:FocusEnergy]
    c += 1 if !@data.nil? && highCritRate?
    shadowmove = self.is_a?(PokeBattle_BossMove) ? self.type == :SHADOW : getMoveType(@move) == :SHADOW
    c += 2 if attacker.inHyperMode? && shadowmove
    c += 1 if [:DEADEYE,:SUPERLUCK].include?(attacker.ability)
    c += 2 if @battle.pbCheckSideAbility(:CHIFOCUS, attacker, checkMoldBroken: true).any?
    c += 2 if attacker.hasWorkingItem(:STICK) && [:FARFETCHD, :SIRFETCHD].include?(attacker.pokemon.species)
    c += 2 if attacker.hasWorkingItem(:LUCKYPUNCH) && attacker.pokemon.species == :CHANSEY
    if @battle.FE == :MIRROR
      buffs = 0
      buffs = attacker.stages[PBStats::EVASION] if attacker.stages[PBStats::EVASION] > 0
      buffs = buffs.to_i + attacker.stages[PBStats::ACCURACY] if attacker.stages[PBStats::ACCURACY] > 0
      buffs = buffs.to_i - opponent.stages[PBStats::EVASION] if opponent.stages[PBStats::EVASION] < 0
      buffs = buffs.to_i - opponent.stages[PBStats::ACCURACY] if opponent.stages[PBStats::ACCURACY] < 0
      buffs = buffs.to_i
      c += buffs if buffs > 0
    end
    c += 1 if attacker.hasWorkingItem(:RAZORCLAW)
    c += 1 if attacker.hasWorkingItem(:SCOPELENS)
    c += 3 if sharpMove? && attacker.crested == :SAMUROTT
    c += 1 if attacker.crested == :FEAROW # Fearow Crest
    c += 1 if attacker.speed > opponent.speed && @battle.FE == :GLITCH
    if Rejuv && @battle.FE == :CHESS
      c += 1 if [:RECKLESS, :GORILLATACTICS].include?(opponent.ability)
      c += 1 if [:STOMPINGTANTRUM, :THRASH, :OUTRAGE, :RAGINGFURY].include?(opponent.lastMoveUsed)
      if attacker.ability == :MERCILESS
        frac = (1.0 * opponent.hp) / (1.0 * opponent.totalhp)
        if frac < 0.8
          c += 1
        elsif frac < 0.6
          c += 2
        elsif frac < 0.4
          c += 3
        end
      end
    end
    c = 3 if c > 3
    return c
  end

  def pbBaseDamage(basedmg, attacker, opponent)
    return basedmg
  end

  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    return damagemult
  end

  def pbModifyDamage(damagemult, attacker, opponent)
    return damagemult
  end

  def pbModifySTAB(stabmult, type, attacker, opponent)
    return stabmult
  end

  def pbCalcDamage(attacker, opponent, hitnum = 0, feedbackMessages = { opponent.index => [] }, movetype: nil)
    opponent.damagestate.critical = false
    opponent.damagestate.typemod = Typemod.zero

    basedmg = @basedamage # From PBS file
    basedmg = [attacker.happiness, 250].min if attacker.crested == :LUVDISC && basedmg != 0
    basedmg = pbBaseDamage(basedmg, attacker, opponent) # Some function codes alter base power
    basedmg = (basedmg * 0.4).pokeRound if attacker.crested == :CINCCINO && attacker.effects[:CincCrest]
    return 0 if basedmg == 0

    ##### Unique Modifiers #####
    # Type effectiveness
    type = movetype.nil? ? pbType(attacker) : movetype
    typemod = pbCalcTypeMod(type, attacker, opponent)
    if opponent.ability == :TERASHELL && opponent.species == :TERAPAGOS && typemod.effective? && (opponent.hp == opponent.totalhp || opponent.effects[:TeraShell]) && !opponent.moldbroken
      typemod = Typemod.half
      if opponent.hp == opponent.totalhp
        opponent.effects[:TeraShell] = true unless @preEmptiveCalc
        feedbackMessages[opponent.index].push(:TeraShell)
      end
    end
    opponent.damagestate.typemod = typemod
    typemult = typemod.multiplier
    return 0 if typemod.immune? # failsafe condition type mod 0 shouldn't actually make it to this point

    # Weather
    weather = @battle.pbWeather(attacker)
    weathermult = 1.0
    case weather
      when :SUNNYDAY
        if @function == 0x508 && !attacker.hasWorkingItem(:UTILITYUMBRELLA) # Hydro Steam
          weathermult = 1.5
        elsif !opponent.hasWorkingItem(:UTILITYUMBRELLA)
          weathermult = 1.5 if type == :FIRE
          weathermult = 0.5 if type == :WATER
        end
      when :RAINDANCE
        unless opponent.hasWorkingItem(:UTILITYUMBRELLA)
          weathermult = 1.5 if type == :WATER
          weathermult = 0.5 if type == :FIRE
          if type == :ELECTRIC && @battle.FE == :CLOUDS
            weathermult = 1.2
            feedbackMessages[opponent.index].push(:RainLightning)
          end
        end
      when :SNOW
        if @battle.state.effects[:NeverMeltIce]
          weathermult = 1.5 if type == :ICE && pbIsSpecial?(attacker, type)
        end
    end

    # Multi-targeting attacks
    spreadmult = 1.0
    if pbTargetsAll?(attacker)
      if attacker.piece == :KNIGHT && @battle.FE == :CHESS && attacker.pbTarget(self) == :AllOpposing
        feedbackMessages[opponent.index].push(:ChessKnightFork)
        spreadmult = 1.25
      else
        if !(attacker.crested == :ENTEI && type == :FIRE)
          spreadmult = 0.75
        end
      end
    end

    # Parental Bond / Typhlosion Crest
    bondmult = 1.0
    bondmult = 0.25 if hitnum == 1 && attacker.effects[:ParentalBond] && pbNumHits(attacker) == 1
    bondmult = 0.3 if hitnum == 1 && attacker.effects[:TyphBond] && pbNumHits(attacker) == 1
    if Rejuv && attacker.hasBlessings?
      if attacker.effects[:SurgingBlessing] > 0 && hitnum >= attacker.effects[:SurgingBlessing]
        rank = attacker.checkBlessing(:SURGINGSTRIKES)
        mod = $cache.blessings[:SURGINGSTRIKES].getValue(:damageReduction, rank)
        bondmult = bondmult == 1.0 ? mod : bondmult + mod
      end
    end

    # Critical hit
    critmult = 1.0
    critchance = pbCritRate?(attacker, opponent)
    if critchance >= 0
      ratios = [24, 8, 2, 1]
      if @preEmptiveCalc
        critmult = (((ratios[critchance] - 1)) + 1.5) / ratios[critchance] # average
      else
        opponent.damagestate.critical = @battle.pbRandom(ratios[critchance]) == 0
        if opponent.damagestate.critical
          critmult = 1.5
        end
      end
    end

    # Random Variance
    if (!$game_switches[:No_Damage_Rolls] || @battle.isOnline?) && !@preEmptiveCalc
      random = 85 + @battle.pbRandom(16)
    else
      random = 93
    end
    random = 85 if @battle.FE == :CONCERT1
    random = 100 if @battle.FE == :CONCERT4
    randommult = random / 100.0

    # STAB-addition from Crests
    stabmult = 1.0
    typecrest = false
    case attacker.crested
      when :EMPOLEON then typecrest = true if type == :ICE
      when :LUXRAY then typecrest = true if type == :DARK
      when :SAMUROTT then typecrest = true if type == :FIGHTING
      when :SIMISEAR then typecrest = true if type == :WATER
      when :SIMIPOUR then typecrest = true if type == :GRASS
      when :SIMISAGE then typecrest = true if type == :FIRE
      when :ZOROARK
        if !attacker.effects[:ZoroCrest].nil?
          typecrest = true if attacker.effects[:ZoroCrest].hasType?(type)
        end
    end
    hasType = attacker.hasType?(type) && !(attacker.effects[:DesertsMark] && type == :GROUND)
    # grass isn't really a tera type of ogerpon's (except teal mask) but for our implementation this works the same
    # terapagos' tera type is stellar but for STAB determination that works the same as being the same type as the mon's base type
    hasTeraType = attacker.isTerastallized? && (attacker.hasType?(type) || (attacker.species == :OGERPON && type == :GRASS))
    # STAB
    if hasType || hasTeraType || typecrest || attacker.teraTypeEffect == type
      stabmod = [hasType, hasTeraType, typecrest, attacker.teraTypeEffect == type, attacker.ability == :ADAPTABILITY].count(true)
      stabmult = PBMults::STAB[stabmod]
    elsif attacker.isStellarTerapagos?
      stabmult = 1.2
    end
    stabmult = pbModifySTAB(stabmult, type, attacker, opponent)

    # Burn
    burnmult = 1.0
    burnmult = 0.5 if attacker.status == :BURN && pbIsPhysical?(attacker, type) && attacker.ability != :GUTS && @move != :FACADE && attacker.crested != :SUICUNE
    burnmult = 0.5 if attacker.status == :FROZEN && pbIsSpecial?(attacker, type) && @battle.state.effects[:NeverMeltIce] && attacker.crested != :SUICUNE



    # Partially bypassing Protect
    protectmult = 1.0
    if @zmove || (Gen >= Champs && unseenFistCheck(attacker)) || (Rejuv && @move == :KOWTOWCLEAVE && @battle.FE == :CHESS)
      if opponent.pbOwnSide.effects[:MatBlock] || opponent.effects[:Protect] ||
         (opponent.pbOwnSide.effects[:WideGuard] && [:AllOpposing, :AllNonUsers].include?(attacker.pbTarget(self))) ||
         (opponent.pbOwnSide.effects[:QuickGuard] && priorityCheck(attacker) > 0) || (Rejuv && @move == :KOWTOWCLEAVE && @battle.FE == :CHESS && @battle.priorityBlockingAbilities.include?(opponent.ability))
        if @move == :UNLEASHEDPOWER
          feedbackMessages[opponent.index].push(:ProtectBreakInterceptium)
        else
          feedbackMessages[opponent.index].push(@zmove ? :ProtectBreakZMove : :ProtectBreakAbility)
          protectmult = 0.25
        end
      end
    end

    # Glaive Rush
    glaivemult = 1.0
    glaivemult = 2.0 if opponent.effects[:GlaiveRush]

    oppitemworks = opponent.itemWorks?(ignorefainted: true)
    attitemworks = attacker.itemWorks?(ignorefainted: true)

    ##### Base Power Modifiers #####
    basemult = []
    aurabroken = @battle.pbFindGlobalAbilityUser(:AURABREAK, checkMoldBroken: true)
    fieldmodifier = [*PBFields::DARKNESS, :DEUXFINALIS].include?(@battle.FE) || @battle.OV == :DARKNESS2
    if type == :DARK && (@battle.pbCheckGlobalAbility(:DARKAURA) || @battle.pbCheckSideCrest(:PANGORO, attacker).any?)
      if fieldmodifier
        case @battle.FE
          when :DARKNESS1 then auramult = 1.4
          when :DARKNESS2 then auramult = 1.5
          when :DARKNESS3 then auramult = 1.66
          when :DEUXFINALIS then auramult = (@battle.pbCheckSideAbility(:DARKAURA, attacker).any? || @battle.pbCheckSideCrest(:PANGORO, attacker).any?) ? 1.33 : 1
          else auramult = 1.33
        end
        auramult = 1.5 if @battle.OV == :DARKNESS2 && auramult < 1.5
        basemult.append(aurabroken ? 1 / auramult : auramult)
      else
        basemult.append(aurabroken ? 0.75 : 1.33)
      end
    end
    if type == :FAIRY && @battle.pbCheckGlobalAbility(:FAIRYAURA)
      if fieldmodifier
        case @battle.FE
          when :DARKNESS1 then auramult = 1.3
          when :DARKNESS2 then auramult = 1.2
          when :DARKNESS3 then auramult = 1.1
          when :DEUXFINALIS then auramult = @battle.pbCheckSideAbility(:FAIRYAURA, attacker).any? ? 1.33 : 1
          else auramult = 1.33
        end
        basemult.append(aurabroken ? 1 / auramult : auramult)
      else
        basemult.append(aurabroken ? 0.75 : 1.33)
      end
    end
    case attacker.ability
      when :RIVALRY       then basemult.append(attacker.gender == opponent.gender ? 1.25 : 0.75) if !attacker.isGenderless? && !opponent.isGenderless?
      when :AERILATE
        if @type == :NORMAL && type == :FLYING
          boost = 1.2
          boost = 1.5 if [:MOUNTAIN, :SNOWYMOUNTAIN, :SKY].include?(@battle.FE)
          basemult.append(boost)
        end
      when :GALVANIZE
        if @type == :NORMAL && type == :ELECTRIC
          boost = 1.2
          boost = 1.5 if [:ELECTERRAIN, :FACTORY].include?(@battle.FE) || @battle.OV == :ELECTERRAIN
          boost = 2.0 if @battle.FE == :SHORTCIRCUIT
          basemult.append(boost)
        end
      when :REFRIGERATE
        if @type == :NORMAL && type == :ICE
          boost = 1.2
          boost = 1.5 if [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION].include?(@battle.FE)
          basemult.append(boost)
        end
      when :PIXILATE
        if @type == :NORMAL && (type == :FAIRY || (type == :NORMAL && @battle.FE == :GLITCH))
          boost = 1.2
          boost = 1.5 if @battle.FE == :MISTY || @battle.OV == :MISTY
          basemult.append(boost)
        end
      when :DRAGONIZE
        if @type == :NORMAL && type == :DRAGON
          boost = 1.2
          boost = 1.5 if @battle.FE == :DRAGONSDEN
          basemult.append(boost)
        end
      when :DUSKILATE     then basemult.append(1.2) if @type == :NORMAL && (type == :DARK || (!Rejuv && type == :NORMAL && @battle.FE == :GLITCH))
      when :NORMALIZE     then basemult.append(1.2) if !@zmove
      when :IRONFIST      then basemult.append(1.2) if punchMove?
      when :RECKLESS      then basemult.append(1.2) if @recoil > 0 || [0x10B, 0x506].include?(@function) # High Jump Kick, Axe Kick
      when :SHEERFORCE    then basemult.append(1.3) if @effect > 0
      when :SANDFORCE     then basemult.append(1.3) if (weather == :SANDSTORM || [:DESERT, :ASHENBEACH].include?(@battle.FE)) && (type == :ROCK || type == :GROUND || type == :STEEL)
      when :ANALYTIC      then basemult.append(1.3) if attacker.movingLast?(analytic: true)
      when :TOUGHCLAWS    then basemult.append(1.3) if attacker.makesContact?(self)
      when :TECHNICIAN
        if basedmg <= 60
          basemult.append(1.5)
        elsif (@battle.FE == :FACTORY || @battle.ProgressiveFieldCheck(PBFields::CONCERT)) && basedmg <= 80
          basemult.append(1.5)
        end
      when :BEADSOFRUIN   then basemult.append(1.3) if opponent.status == :PETRIFIED && @battle.FE == :DEUXFINALIS
      when :FLAREBOOST    then basemult.append(1.5) if (attacker.status == :BURN || [:BURNING, :VOLCANIC, :INFERNAL].include?(@battle.FE)) && pbIsSpecial?(attacker, type) && @battle.FE != :FROZENDIMENSION
      when :TOXICBOOST
        if (attacker.status == :POISON || [:CORROSIVEMIST].include?(@battle.FE) || ([:CORROSIVE, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE) && !attacker.isAirborne?)) && pbIsPhysical?(attacker, type)
          basemult.append(@battle.FE == :CORRUPTED ? 2.0 : 1.5)
        end
      when :STRONGJAW     then basemult.append(1.5) if bitingMove?
      when :MEGALAUNCHER  then basemult.append(1.5) if pulseMove?
      when :SHARPNESS     then basemult.append(1.5) if sharpMove?
      when :TRUESHOT      then basemult.append(1.3) if bulletMove?
      when :HOTSHOT       then basemult.append(1.3) if shotMove?
      when :SOLARIDOL     then basemult.append(1.5) if type == :FIRE
      when :LUNARIDOL     then basemult.append(1.5) if type == :ICE
      when :INEXORABLE    then basemult.append(1.3) if (!opponent.hasMovedThisRound? || @battle.switchedOut[opponent.index])
      when :SUPREMEOVERLORD then basemult.append(1 + 0.1 * attacker.effects[:SupremeOverlord])
    end
    for partner in @battle.pbCheckSideAbility(:BATTERY, attacker, excludeSelf: true)
      Rejuv && @battle.FE == :ELECTERRAIN ? basemult.append(1.5) : basemult.append(1.3) if pbIsSpecial?(attacker, type)
    end
    unless opponent.moldbroken
      case opponent.ability
        when :HEATPROOF   then basemult.append(0.5) if type == :FIRE && Gen < 9
        when :DRYSKIN     then basemult.append(1.25) if type == :FIRE
      end
    end
    if attitemworks
      if $cache.items[attacker.item].checkFlag?(:typeboost) == type
        if $cache.items[attacker.item].checkFlag?(:gem)
          basemult.append(1.3)
          feedbackMessages[opponent.index].push(:TypeGem)
          attacker.effects[:TypeGemActivated] = true unless @preEmptiveCalc
        else
          basemult.append(1.2)
        end
      else
        case attacker.item
          when :MUSCLEBAND then basemult.append(PBMults::TenPercentItem) if pbIsPhysical?(attacker, type) # approx. 1.1x
          when :WISEGLASSES then basemult.append(PBMults::TenPercentItem) if pbIsSpecial?(attacker, type) # approx. 1.1x
          when :LUSTROUSORB, :LUSTROUSGLOBE then basemult.append(1.2) if attacker.pokemon.species == :PALKIA && [:DRAGON, :WATER].include?(type)
          when :ADAMANTORB, :ADAMANTCRYSTAL then basemult.append(1.2) if attacker.pokemon.species == :DIALGA && [:DRAGON, :STEEL].include?(type)
          when :GRISEOUSORB, :GRISEOUSCORE then basemult.append(1.2) if attacker.pokemon.species == :GIRATINA && [:DRAGON, :GHOST].include?(type)
          when :SOULDEW then basemult.append(1.2) if [:LATIAS, :LATIOS].include?(attacker.pokemon.species) && [:DRAGON, :PSYCHIC].include?(type)
          when :SOULSTONEHELD then basemult.append(1.2) if [:YVELTAL].include?(attacker.pokemon.species) && [:FLYING, :DARK].include?(type)
          when :WELLSPRINGMASK then basemult.append(1.2) if attacker.pokemon.species == :OGERPON && attacker.pokemon.form == 1
          when :HEARTHFLAMEMASK then basemult.append(1.2) if attacker.pokemon.species == :OGERPON && attacker.pokemon.form == 2
          when :CORNERSTONEMASK then basemult.append(1.2) if attacker.pokemon.species == :OGERPON && attacker.pokemon.form == 3
        end
      end
    end
    basemult.append(1.5) if attacker.effects[:MeFirst]
    attacker.effects[:HelpingHand].times { basemult.append(1.5) }
    basemult.append(1.5) if [:PIERCINGDRILL, :UNSEENFIST].include?(attacker.ability) && opponent.isbossmon
    case type
      when :FIRE then basemult.append(0.33) if @battle.state.effects[:WaterSport] > 0
      when :ELECTRIC
        basemult.append(0.33) if @battle.state.effects[:MudSport] > 0
        basemult.append(2.0) if attacker.effects[:UseCharge]
    end

    # Frenzy
    basemult.append(1.33) if attacker.permeffs[:Frenzy]
    if @battle.field.isFieldEffect?
      fieldmult = moveFieldBoost(attacker)
      if fieldmult != 1
        basemult.append(fieldmult)
        feedbackMessages[opponent.index].push(:MoveFieldMessage)
      end
    end
    fieldBoost = typeFieldBoost(type, attacker, opponent)
    overlayBoost = typeOverlayBoost(type, attacker, opponent)
    if fieldBoost != 1 || overlayBoost != 1
      if fieldBoost > 1 && overlayBoost > 1
        boost = [fieldBoost, overlayBoost].max
        comboboost = calculateFieldMultiplier(1.5)
        boost = comboboost if boost < comboboost
      else
        boost = fieldBoost * overlayBoost
      end
      basemult.append(boost)
      if fieldBoost != 1
        feedbackMessages[opponent.index].push(:TypeFieldMessage)
      else
        feedbackMessages[opponent.index].push(:TypeOverlayMessage)
      end
    end
    basemult.append(pbBaseDamageMultiplier(1.0, attacker, opponent))
    # standard crest damage multipliers
    case attacker.crested
      when :FERALIGATR    then basemult.append(1.5) if bitingMove?
      when :CLAYDOL       then basemult.append(1.5) if isBeamMove?
      when :DRUDDIGON     then basemult.append(1.3) if type == :DRAGON || type == :FIRE
      when :BOLTUND       then basemult.append(1.5) if bitingMove? && (!opponent.hasMovedThisRound? || @battle.switchedOut[opponent.index])
      when :FEAROW        then basemult.append(1.5) if PBStuff::STABBINGMOVE.include?(@move)
      when :DUSKNOIR      then basemult.append(1.5) if basedmg <= 60 || ((@battle.FE == :FACTORY || @battle.ProgressiveFieldCheck(PBFields::CONCERT)) && basedmg <= 80)
      when :CRABOMINABLE  then basemult.append(1.5) if attacker.lastHPLost > 0
      when :AMPHAROS      then basemult.append(attacker.hasType?(type) ? 1.2 : 1.5) if attacker.moves[0] == self
      when :LUXRAY        then basemult.append(1.2) if @type == :NORMAL && type == :ELECTRIC
      when :SAWSBUCK
        case attacker.form
          when 0 then basemult.append(1.2) if @type == :NORMAL && type == :WATER
          when 1 then basemult.append(1.2) if @type == :NORMAL && type == :FIRE
          when 2 then basemult.append(1.2) if @type == :NORMAL && type == :GROUND
          when 3 then basemult.append(1.2) if @type == :NORMAL && type == :ICE
        end
    end
    case @battle.FE
      when :CHESS
        if PBFields::CHESSMOVES.include?(@move)
          basemult.append(0.5) if [:ADAPTABILITY, :ANTICIPATION, :SYNCHRONIZE, :TELEPATHY].include?(opponent.ability)
          basemult.append(2.0) if [:OBLIVIOUS, :KLUTZ, :UNAWARE, :SIMPLE].include?(opponent.ability) || opponent.effects[:Confusion] > 0 || (Rejuv && opponent.ability == :DEFEATIST)
        end
        # Queen piece boost
        if attacker.piece == :QUEEN || attacker.ability == :QUEENLYMAJESTY
          basemult.append(1.5)
          feedbackMessages[opponent.index].push(:ChessQueen)
        end
        # Knight piece boost
        if attacker.piece == :KNIGHT && opponent.piece == :QUEEN
          basemult.append(3.0)
          feedbackMessages[opponent.index].push(:ChessKnightQueen)
        end
      when :BIGTOP
        if (type == :FIGHTING && pbIsPhysical?(attacker, type)) || PBFields::STRIKERMOVES.include?(@move)
          provimult = @battle.field.getRoll(update_roll: !@preEmptiveCalc, maximize_roll: [:HUGEPOWER, :GUTS, :PUREPOWER, :SHEERFORCE].include?(attacker.ability), rollmodifier: attacker.stages[PBStats::ATTACK])
          feedbackMessages[opponent.index].push(:HighStriker)
          provimult = calculateFieldMultiplier(provimult)
          basemult.append(provimult)
        end
      when :SHORTCIRCUIT
        if type == :ELECTRIC
          damageroll = @battle.field.getRoll(update_roll: !@preEmptiveCalc, maximize_roll: @battle.OV == :ELECTERRAIN)
          feedbackMessages[opponent.index].push(:ShortCircuit)
          damageroll = calculateFieldMultiplier(damageroll)
          basemult.append(damageroll)
        end
      when :MOUNTAIN, :SNOWYMOUNTAIN, :VOLCANICTOP
        if weather == :STRONGWINDS && (windMove? || (type == :FLYING && !pbIsPhysical?(attacker, type)))
          provimult = calculateFieldMultiplier(1.5)
          basemult.append(provimult)
          if windMove?
            feedbackMessages[opponent.index].push(:MountainWind)
          end
        end
      when :MIRROR
        if PBFields::MIRRORMOVES.include?(@move) && opponent.stages[PBStats::EVASION] > 0
          provimult = calculateFieldMultiplier(2.0)
          basemult.append(provimult)
          feedbackMessages[opponent.index].push(:MirrorArenaBeam)
        end
      when :DEEPEARTH
        if priorityCheck(attacker) > 0
          provimult = calculateFieldMultiplier(0.7)
          basemult.append(provimult)
          feedbackMessages[opponent.index].push(:DeepEarthPriorityNerf)
        end
        if priorityCheck(attacker) < 0
          provimult = calculateFieldMultiplier(1.3)
          basemult.append(provimult)
          feedbackMessages[opponent.index].push(:DeepEarthNegPriorityBoost)
        end
    end
    if Overlays
      if @battle.OV
        overlaymult = moveOverlayBoost
        if overlaymult != 1
          basemult.append(overlaymult)
          feedbackMessages[opponent.index].push(:OverlayMoveMessage)
        end
      end
    end

    ##### Apply Base Power modifiers to the move's Base Power #####
    basedmg = basedmg.chainMods(basemult).pokeRound.pokeClamp
    basedmg = 60 if attacker.isTerastallized? && basedmg < 60 && type == attacker.types.first && !pbIsMultiHit && self.priority <= 0

    ##### Determine used stats for glitch field special stat #####
    moldBrokenArray = [0, 1, 2, 3].map { |index| @battle.battlers[index].moldbroken }
    oppUnaware = opponent.ability == :UNAWARE && !opponent.moldbroken
    onlyModifiers = self.function == 0x121 # Foul Play
    attUnaware = attacker.ability == :UNAWARE
    attackerUseSpDef = @battle.FE == :GLITCH && attacker.changeSpecialStat(unaware: oppUnaware, crit: opponent.damagestate.critical, attacker: true, moldBrokenArray: moldBrokenArray, onlyModifiers: onlyModifiers)
    defenderUseSpAtk = @battle.FE == :GLITCH && opponent.changeSpecialStat(unaware: attUnaware, crit: opponent.damagestate.critical, attacker: false, moldBrokenArray: moldBrokenArray)

    ##### Attack Modifiers #####
    atkmult = []
    ruinmod = 0.75
    ruinmod = 0.667 if @battle.FE == :NEWWORLD
    ruinmod = 0.875 if @battle.FE == :HOLY
    if pbIsSpecial?(attacker, type) && attackerUseSpDef
      for abilityholder in @battle.pbCheckSideAbility(:FLOWERGIFT, attacker)
        atkmult.append(1.5) if abilityholder.flowerGiftActive?
      end
      atkmult.append(1.1) if @battle.FE == :CLOUDS && attacker.hasWorkingItem(:CLEVERWING)
      atkmult.append(1.3) if attacker.ability == :QUARKDRIVE && attacker.effects[:Quarkdrive][0] == PBStats::SPDEF
      atkmult.append(1.3) if attacker.ability == :PROTOSYNTHESIS && attacker.effects[:Protosynthesis][0] == PBStats::SPDEF
      atkmult.append(ruinmod) if !attacker.wonderroom && @battle.pbCheckGlobalAbility(:BEADSOFRUIN) && attacker.ability != :BEADSOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && attacker.pbPartner.ability == :BEADSOFRUIN)
      atkmult.append(ruinmod) if attacker.wonderroom && @battle.pbCheckGlobalAbility(:SWORDOFRUIN) && attacker.ability != :SWORDOFRUIN  && !(PBStuff::DimensionalFields.include?(@battle.FE) && attacker.pbPartner.ability == :SWORDOFRUIN)
      # Sandstorm is applied directly to the attacking stat further down
      atkmult.append(1.5) if attacker.hasWorkingItem(:ASSAULTVEST)
      atkmult.append(1.5) if attacker.evioliteActive?
      atkmult.append(2.0) if attacker.hasWorkingItem(:DEEPSEASCALE) && attacker.pokemon.species == :CLAMPERL
    elsif pbIsSpecial?(attacker, type) && !attackerUseSpDef
      atkmult.append(0.5) if attacker.ability == :DEFEATIST && attacker.hp <= (attacker.totalhp / 2.0).floor
      atkmult.append(1.1) if @battle.FE == :CLOUDS && attacker.hasWorkingItem(:GENIUSWING)
      for abilityholder in @battle.pbCheckSideAbility(:FLOWERGIFT, attacker)
        atkmult.append(1.5) if abilityholder.crested == :CHERRIM
      end
      atkmult.append(1.5) if (attacker.ability == :SOLARPOWER || (attacker.crested == :CASTFORM && attacker.form == 1)) && weather == :SUNNYDAY && !(attacker.hasWorkingItem(:UTILITYUMBRELLA) || @battle.FE == :FROZENDIMENSION)
      atkmult.append(1.5) if attacker.ability == :LUNARIDOL && [:HAIL, :SNOW].include?(weather)
      atkmult.append(2.0) if attacker.ability == :PUREPOWER && (@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN)
      if [:PLUS, :MINUS].include?(attacker.ability) || [:PLUSLE, :MINUN].include?(attacker.crested)
        if [:PLUS, :MINUS].include?(attacker.pbPartner.ability) || @battle.FE == :SHORTCIRCUIT || (Rejuv && (@battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN)) || (attacker.crested == :MINUN && attacker.ability == :MINUS) ||
          (attacker.crested == :PLUSLE && attacker.ability == :PLUS)
          atkmult.append(1.5)
        end
      end
      atkmult.append(1.3) if attacker.ability == :QUARKDRIVE && attacker.effects[:Quarkdrive][0] == PBStats::SPATK
      atkmult.append(1.3) if attacker.ability == :PROTOSYNTHESIS && attacker.effects[:Protosynthesis][0] == PBStats::SPATK
      atkmult.append(PBMults::ParadoxLeads) if attacker.ability == :HADRONENGINE && (@battle.FE == :NEWWORLD || @battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN)
      atkmult.append(ruinmod) if @battle.pbCheckGlobalAbility(:VESSELOFRUIN) && attacker.ability != :VESSELOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && attacker.pbPartner.ability == :VESSELOFRUIN)
      atkmult.append(1.5) if attacker.hasWorkingItem(:CHOICESPECS)
      atkmult.append(2.0) if attacker.hasWorkingItem(:DEEPSEATOOTH) && attacker.pokemon.species == :CLAMPERL
      atkmult.append(2.0) if attacker.hasWorkingItem(:LIGHTBALL) && attacker.pokemon.species == :PIKACHU
    elsif pbIsPhysical?(attacker, type)
      for abilityholder in @battle.pbCheckSideAbility(:FLOWERGIFT, attacker)
        atkmult.append(1.5) if abilityholder.flowerGiftActive?
      end
      atkmult.append(1.1) if @battle.FE == :CLOUDS && attacker.hasWorkingItem(:MUSCLEWING)
      atkmult.append(0.5) if attacker.ability == :SLOWSTART && attacker.effects[:SlowStart] < 5 && @battle.FE != :DEEPEARTH
      atkmult.append(0.5) if attacker.ability == :DEFEATIST && attacker.hp <= (attacker.totalhp / 2.0).floor
      atkmult.append(1.5) if attacker.ability == :GUTS && !attacker.status.nil?
      atkmult.append(2.0) if attacker.ability == :HUGEPOWER
      atkmult.append(2.0) if attacker.ability == :PUREPOWER && !(@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN)
      atkmult.append(1.5) if attacker.ability == :GORILLATACTICS
      atkmult.append(1.33) if @battle.pbCheckSideCrest(:PLUSLE, attacker).any?
      atkmult.append(1.5) if attacker.ability == :SOLARIDOL && weather == :SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
      atkmult.append(1.3) if attacker.ability == :QUARKDRIVE && attacker.effects[:Quarkdrive][0] == PBStats::ATTACK
      atkmult.append(1.3) if attacker.ability == :PROTOSYNTHESIS && attacker.effects[:Protosynthesis][0] == PBStats::ATTACK
      atkmult.append(PBMults::ParadoxLeads) if attacker.ability == :ORICHALCUMPULSE && (weather == :SUNNYDAY || @battle.FE == :NEWWORLD)
      atkmult.append(ruinmod) if @battle.pbCheckGlobalAbility(:TABLETSOFRUIN) && attacker.ability != :TABLETSOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && attacker.pbPartner.ability == :TABLETSOFRUIN)
      atkmult.append(1.5) if attacker.hasWorkingItem(:CHOICEBAND)
      atkmult.append(2.0) if attacker.hasWorkingItem(:THICKCLUB) && [:CUBONE, :MAROWAK].include?(attacker.pokemon.species)
      atkmult.append(2.0) if attacker.hasWorkingItem(:LIGHTBALL) && attacker.pokemon.species == :PIKACHU
      atkmult.append(0.5) if @battle.FE == :UNDERWATER && !(Rejuv && attacker.hasType?(:WATER)) && type != :WATER && !(self.getSecondaryType(attacker, type).include?(:WATER)) && ![:EELEVATE, :STEELWORKER, :SWIFTSWIM].include?(attacker.ability)
    end
    atkmult.append(1.1) if attacker.hasWorkingItem(:PUNCHINGGLOVE) && punchMove?
    atkmult.append(@battle.FE == :FACTORY ? 2.0 : 1.5) if attacker.ability == :STEELWORKER && type == :STEEL
    atkmult.append(1.5) if attacker.item == :SOULDEW  && type == :DARK && [:LATIOS,:LATIAS].include?(attacker.pokemon.species) && PBStuff::DimensionalFields.include?(@battle.FE)
    atkmult.append(@battle.FE == :ROCKY ? 2.0 : Rejuv && [:MOUNTAIN, :VOLCANICTOP, :SNOWYMOUNTAIN].include?(@battle.FE) ? 2.0 : 1.5) if attacker.ability == :ROCKYPAYLOAD && type == :ROCK
    atkmult.append([:SUPERHEATED, :BURNING, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@battle.FE) ? 2.0 : 1.5) if attacker.ability == :FIREMANE && type == :FIRE
    atkmult.append(@battle.FE == :ELECTERRAIN ? (Gen >= 9 ? 1.6 : 2.0) : (Gen >= 9 ? 1.3 : 1.5)) if attacker.ability == :TRANSISTOR && type == :ELECTRIC
    atkmult.append(@battle.FE == :DRAGONSDEN ? 2.0 : 1.5) if attacker.ability == :DRAGONSMAW && type == :DRAGON
    # pinch abilities
    if [:BURNING, :VOLCANIC, :INFERNAL].include?(@battle.FE) && attacker.ability == :BLAZE && type == :FIRE
      atkmult.append(1.5)
    elsif @battle.FE == :VOLCANICTOP && attacker.ability == :BLAZE && type == :FIRE && attacker.effects[:Blazed]
      atkmult.append(1.5)
    elsif ([:FOREST].include?(@battle.FE) || (Rejuv && @battle.FE == :GRASSY)) && attacker.ability == :OVERGROW && type == :GRASS
      atkmult.append(1.5)
    elsif @battle.FE == :FOREST && attacker.ability == :SWARM && type == :BUG
      atkmult.append(1.5)
    elsif ((@battle.FE == :WATERSURFACE && !attacker.isAirborne?) || @battle.FE == :UNDERWATER) && attacker.ability == :TORRENT && type == :WATER
      atkmult.append(1.5)
    elsif @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN) && attacker.ability == :SWARM && type == :BUG
      atkmult.append(1.5) if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 1, 2)
      atkmult.append(1.8) if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 4)
      atkmult.append(2.0) if @battle.FE == :FLOWERGARDEN5
    elsif @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5) && attacker.ability == :OVERGROW && type == :GRASS
      case @battle.FE
        when :FLOWERGARDEN2 then atkmult.append(1.5) if attacker.hp <= (attacker.totalhp * 0.67).floor
        when :FLOWERGARDEN3 then atkmult.append(1.5)
        when :FLOWERGARDEN4 then atkmult.append(1.8)
        when :FLOWERGARDEN5 then atkmult.append(2.0)
      end
    elsif attacker.hp <= (attacker.totalhp / 3.0).floor
      if (attacker.ability == :OVERGROW && type == :GRASS) || (attacker.ability == :BLAZE && type == :FIRE && @battle.FE != :FROZENDIMENSION) ||
         (attacker.ability == :TORRENT && type == :WATER) || (attacker.ability == :SWARM && type == :BUG)
        atkmult.append(1.5)
      end
    end
    atkmult.append(1.5) if attacker.effects[:FlashFire] && type == :FIRE && @battle.FE != :FROZENDIMENSION
    atkmult.append(1.5) if attacker.effects[:CoalFurnace] && type == :FIRE
    atkmult.append(1.5) if attacker.ability == :WILDFIRE && (opponent.status == :BURN  || @battle.FE == :INFERNAL)
    atkmult.append(2.0) if attacker.ability == :STAKEOUT && @battle.switchedOut[opponent.index]
    atkmult.append(2.0) if attacker.ability == :WATERBUBBLE && type == :WATER
    if oppitemworks && opponent.item == :NEVERMELTICE && (@battle.state.effects[:NeverMeltIce] || @battle.FE == :FROZENDIMENSION) && type == :FIRE
      feedbackMessages[opponent.index].push(:NeverMeltIce)
      atkmult.append(0.66)
    end
    if !opponent.moldbroken
      atkmult.append(0.5) if opponent.ability == :WATERBUBBLE && type == :FIRE
      atkmult.append(0.5) if opponent.ability == :THICKFAT && [:ICE, :FIRE].include?(type)
      atkmult.append(0.5) if opponent.ability == :HEATPROOF && type == :FIRE && Gen >= 9
      atkmult.append(0.5) if opponent.ability == :PURIFYINGSALT && type == :GHOST
    end
    for partner in @battle.pbCheckSideAbility(:POWERSPOT, attacker, excludeSelf: true)
      [:HAUNTED, :BEWITCHED, :HOLY, :PSYTERRAIN, :DEEPEARTH, :DEUXFINALIS].include?(@battle.FE) ? atkmult.append(1.5) : atkmult.append(1.3)
    end
    # Mid Battle stat multiplying crests; Spiritomb Crest, Castform Crest
    if attacker.crested == :SPIRITOMB
      allyfainted = attacker.pbFaintedPokemonCount
      modifier = (allyfainted * 0.2) + 1.0
      atkmult.append(modifier)
    end
    for abilityholder in @battle.pbCheckSideAbility(:STEELYSPIRIT, attacker)
      @battle.FE == :FAIRYTALE ? atkmult.append(2.0) : atkmult.append(1.5) if type == :STEEL
    end
    if @battle.FE != :INDOOR
      if [:STARLIGHT, :NEWWORLD].include?(@battle.FE)
        for abilityholder in @battle.pbCheckSideAbility(:VICTORYSTAR, attacker)
          atkmult.append(1.5)
        end
      end
      if [:WATERSURFACE, :UNDERWATER].include?(@battle.FE)
        atkmult.append(1.5) if attacker.ability == :PROPELLERTAIL && @priority >= 1
      end
      if Rejuv && @battle.FE == :CHESS
        atkmult.append(1.2) if attacker.ability == :GORILLATACTICS || attacker.ability == :RECKLESS
        atkmult.append(1.2) if attacker.effects[:Illusion] != nil
        if attacker.ability == :COMPETITIVE
          frac = (1.0 * attacker.hp) / (1.0 * attacker.totalhp)
          multiplier = 1.0
          multiplier += ((1.0 - frac) / 0.8)
          if frac < 0.2
            multiplier = 2.0
          end
          atkmult.append(multiplier)
        end
      end
      case attacker.ability
        when :QUEENLYMAJESTY then atkmult.append(1.5) if @battle.FE == :FAIRYTALE
        when :LONGREACH then atkmult.append(1.5) if [:MOUNTAIN, :SNOWYMOUNTAIN, :VOLCANICTOP, :SKY].include?(@battle.FE)
        when :CORROSION then atkmult.append(1.5) if [:CORROSIVE, :CORROSIVEMIST, :CORRUPTED].include?(@battle.FE)
        when :SKILLLINK then atkmult.append(1.2) if @battle.FE == :COLOSSEUM && (@function == 0xC0 || @function == 0x307 || (attacker.crested == :CINCCINO && attacker.effects[:CincCrest])) # 0xC0: 2-5 hits; 0x307: Scale Shot
        when :PURIFYINGSALT then atkmult.append(1.5) if @battle.FE == :HOLY
      end
    end

    ##### Calculate attacker's attack stat #####
    if pbIsSpecial?(attacker, type)
      case @function
        when 0x121 # Foul Play
          atkstage = opponent.crested == :CLAYDOL ? opponent.stages[PBStats::DEFENSE] + 6 : opponent.stages[PBStats::SPATK] + 6
          atkstage = opponent.crested == :CLAYDOL ? opponent.stages[PBStats::SPEED] + 6 : opponent.stages[PBStats::SPATK] + 6
          if @battle.FE == :GLITCH
            targetHighSpdef = opponent.spdef * PBStats::StageMul[opponent.stages[PBStats::SPDEF] + 6] > opponent.spatk * PBStats::StageMul[atkstage]
            atk = targetHighSpdef ? opponent.spdef : opponent.spatk
            atkstage = opponent.stages[PBStats::SPDEF] + 6 if targetHighSpdef
          else
            atk = opponent.spatk
          end
        when 0x184 # Body Press
          if @battle.FE == :GLITCH
            atk = attackerUseSpDef ? attacker.spdef : attacker.spatk
            atkstage = attackerUseSpDef ? attacker.stages[PBStats::SPDEF] + 6 : attacker.stages[PBStats::SPATK] + 6
            atkstage = attacker.stages[PBStats::DEFENSE] + 6 if attacker.crested == :CLAYDOL && !attackerUseSpDef
          else
            atk = attacker.spdef
            atkstage = attacker.stages[PBStats::SPDEF] + 6
          end
        else
          atk = attackerUseSpDef ? attacker.spdef : attacker.spatk
          atkstage = attackerUseSpDef ? attacker.stages[PBStats::SPDEF] + 6 : attacker.stages[PBStats::SPATK] + 6
          atkstage = attacker.stages[PBStats::DEFENSE] + 6 if attacker.crested == :CLAYDOL && !attackerUseSpDef
      end
    else
      case @function
        when 0x121 # Foul Play
          atk = opponent.attack
          atkstage = opponent.crested == :DEDENNE ? opponent.stages[PBStats::SPEED] + 6 : opponent.stages[PBStats::ATTACK] + 6
        when 0x184 # Body Press
          atk = attacker.defense
          atkstage = attacker.stages[PBStats::DEFENSE] + 6
        else
          atk = attacker.attack
          atkstage = attacker.crested == :DEDENNE ? attacker.stages[PBStats::SPEED] + 6 : attacker.stages[PBStats::ATTACK] + 6
      end
    end

    if attacker.crested == :FLYGON && checkSoundMove?(attacker)
      atk = attacker.attack
      atkstage = attacker.stages[PBStats::ATTACK] + 6
    end


    ##### Apply Attack modifiers to the attacker's Attack stat #####
    unless oppUnaware
      atkstage = 6 if opponent.damagestate.critical && atkstage < 6
      atk = (atk * PBStats::StageMul[atkstage]).floor
    end
    if attacker.ability == :HUSTLE && pbIsPhysical?(attacker, type)
      atk = [:BACKALLEY, :CITY].include?(@battle.FE) ? (atk * 1.75).floor : (atk * 1.5).floor
    end
    atk = (atk * 1.5).floor if pbIsSpecial?(attacker, type) && attackerUseSpDef && weather == :SANDSTORM && attacker.hasType?(:ROCK)
    atk = atk.chainMods(atkmult).pokeRound.pokeClamp

    ##### Defense Modifiers #####
    defmult = []
    ruinmod = 0.75
    ruinmod = 0.667 if @battle.FE == :NEWWORLD
    ruinmod = 0.875 if @battle.FE == :HOLY
    if pbHitsSpecialStat?(attacker, type) && defenderUseSpAtk
      defmult.append(0.5) if opponent.ability == :DEFEATIST && opponent.hp <= (opponent.totalhp / 2.0).floor
      defmult.append(1.1) if @battle.FE == :CLOUDS && opponent.hasWorkingItem(:GENIUSWING)
      unless opponent.moldbroken
        defmult.append(1.5) if (opponent.ability == :SOLARPOWER || (opponent.crested == :CASTFORM && opponent.form == 1)) && weather == :SUNNYDAY && !(opponent.hasWorkingItem(:UTILITYUMBRELLA) || @battle.FE == :FROZENDIMENSION)
        defmult.append(1.5) if opponent.ability == :LUNARIDOL && [:HAIL, :SNOW].include?(weather)
        defmult.append(2.0) if opponent.ability == :PUREPOWER && (@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN)
        if [:PLUS, :MINUS].include?(opponent.ability)  || [:PLUSLE,:MINUN].include?(opponent.crested)
          if [:PLUS, :MINUS].include?(opponent.pbPartner.ability) || @battle.FE == :SHORTCIRCUIT || (Rejuv && (@battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN)) || (opponent.crested == :MINUN && opponent.ability == :MINUS) ||
          (opponent.crested == :PLUSLE && opponent.ability == :PLUS)
            defmult.append(1.5)
          end
        end
        defmult.append(PBMults::ParadoxLeads) if opponent.ability == :HADRONENGINE && (@battle.FE == :NEWWORLD || @battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN)
      end
      defmult.append(1.3) if opponent.ability == :QUARKDRIVE && opponent.effects[:Quarkdrive][0] == PBStats::SPATK
      defmult.append(1.3) if opponent.ability == :PROTOSYNTHESIS && opponent.effects[:Protosynthesis][0] == PBStats::SPATK
      defmult.append(ruinmod) if @battle.pbCheckGlobalAbility(:VESSELOFRUIN) && opponent.ability != :VESSELOFRUIN && !(@battle.FE == :DEUXFINALIS && opponent.pbPartner.ability == :VESSELOFRUIN)
      defmult.append(1.5) if opponent.hasWorkingItem(:CHOICESPECS)
      defmult.append(2.0) if opponent.hasWorkingItem(:DEEPSEATOOTH) && opponent.pokemon.species == :CLAMPERL
      defmult.append(2.0) if opponent.hasWorkingItem(:LIGHTBALL) && opponent.pokemon.species == :PIKACHU
    elsif pbHitsSpecialStat?(attacker, type) && !defenderUseSpAtk
      for abilityholder in @battle.pbCheckSideAbility(:FLOWERGIFT, opponent, checkMoldBroken: true)
        defmult.append(1.5) if abilityholder.flowerGiftActive?
      end
      defmult.append(1.1) if @battle.FE == :CLOUDS && opponent.hasWorkingItem(:CLEVERWING)
      defmult.append(1.3) if opponent.ability == :QUARKDRIVE && opponent.effects[:Quarkdrive][0] == PBStats::SPDEF
      defmult.append(1.3) if opponent.ability == :PROTOSYNTHESIS && opponent.effects[:Protosynthesis][0] == PBStats::SPDEF
      defmult.append(1.3) if opponent.ability == :TABLETSOFRUIN && attacker.status == :PETRIFIED && @battle.FE == :DEUXFINALIS
      defmult.append(ruinmod) if !opponent.wonderroom && @battle.pbCheckGlobalAbility(:BEADSOFRUIN) && opponent.ability != :BEADSOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && opponent.pbPartner.ability == :BEADSOFRUIN)
      defmult.append(ruinmod) if opponent.wonderroom && @battle.pbCheckGlobalAbility(:SWORDOFRUIN) && opponent.ability != :SWORDOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && opponent.pbPartner.ability == :SWORDOFRUIN)
      defmult.append(1.5) if opponent.evioliteActive?
      defmult.append(1.5) if opponent.hasWorkingItem(:ASSAULTVEST)
      defmult.append(2.0) if opponent.hasWorkingItem(:DEEPSEASCALE) && opponent.pokemon.species == :CLAMPERL
    elsif pbHitsPhysicalStat?(attacker, type)
      unless opponent.moldbroken
        defmult.append(1.5) if opponent.ability == :MARVELSCALE && (!opponent.status.nil? || [:MISTY, :RAINBOW, :FAIRYTALE, :DRAGONSDEN, :STARLIGHT, :DEUXFINALIS].include?(@battle.FE) || @battle.OV == :MISTY)
        defmult.append(2.0) if opponent.ability == :FURCOAT
        defmult.append(1.5) if opponent.ability == :GRASSPELT && ([:GRASSY, :FOREST].include?(@battle.FE) || @battle.OV == :GRASSY) # Grassy Field
      end
      for abilityholder in @battle.pbCheckSideAbility(:FLOWERGIFT, opponent, checkMoldBroken: true)
        defmult.append(1.5) if abilityholder.crested == :CHERRIM
      end
      defmult.append(1.1) if @battle.FE == :CLOUDS && opponent.hasWorkingItem(:RESISTWING)
      defmult.append(1.3) if opponent.ability == :QUARKDRIVE && opponent.effects[:Quarkdrive][0] == PBStats::DEFENSE
      defmult.append(1.3) if opponent.ability == :VESSELOFRUIN && attacker.status == :PETRIFIED && @battle.FE == :DEUXFINALIS
      defmult.append(1.3) if opponent.ability == :PROTOSYNTHESIS && opponent.effects[:Protosynthesis][0] == PBStats::DEFENSE
      defmult.append(ruinmod) if opponent.wonderroom && @battle.pbCheckGlobalAbility(:BEADSOFRUIN) && opponent.ability != :BEADSOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && opponent.pbPartner.ability == :BEADSOFRUIN)
      defmult.append(ruinmod) if !opponent.wonderroom && @battle.pbCheckGlobalAbility(:SWORDOFRUIN) && opponent.ability != :SWORDOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && opponent.pbPartner.ability == :SWORDOFRUIN)
      defmult.append(1.5) if opponent.evioliteActive?
      defmult.append(2.0) if opponent.hasWorkingItem(:METALPOWDER) && opponent.pokemon.species == :DITTO && !opponent.effects[:Transform]
      defmult.append(0.5) if attacker.crested == :ELECTRODE
    end
    unless opponent.moldbroken
      case opponent.ability
        when :PUNKROCK, :JUNGLEBEAT then defmult.append(2.0) if checkSoundMove?(attacker)
        # unlike fur coat ice scales reduces the damage of special attacks instead of increasing the special defense
        # the difference here is that ice scales applies to psyshock despite it targeting phys def
        when :ICESCALES then defmult.append(2.0) if pbIsSpecial?(attacker, type)
      end
    end
    defmult.append(0.5) if @battle.FE == :GLITCH && @function == 0xE0 # Explosion
    # Field Effect defense boost
    category = pbHitsSpecialStat?(attacker, type) ? :special : (pbHitsPhysicalStat?(attacker, type) ? :physical : nil)
    defmult.append(opponent.fieldDefenseBoost(attacker, category))

    ##### Calculate opponent's defense stat #####
    defense = opponent.defense
    defstage = opponent.stages[PBStats::DEFENSE] + 6

    applysandstorm = false
    applysnow = true
    if pbHitsSpecialStat?(attacker, type)
      defense = opponent.spdef
      defstage = opponent.stages[PBStats::SPDEF] + 6
      applysandstorm = true
      applysnow = false
      if defenderUseSpAtk
        defense = opponent.spatk
        defstage = opponent.stages[PBStats::SPATK] + 6
        applysandstorm = false # Sandstorm modifies special defense directly doesn't apply if special attack is used
      end
    end

    ##### Apply Defense modifiers to the opponent's Defense stat #####
    unless attUnaware
      defstage = 6 if [0xA9,0x80F].include?(@function) # Chip Away (ignore stat stages)
      defstage = 6 if opponent.damagestate.critical && defstage > 6
      defense = (defense * PBStats::StageMul[defstage]).floor
    end
    if weather == :SANDSTORM && opponent.hasType?(:ROCK) && applysandstorm
      defense = (defense * 1.5).floor
    end
    if weather == :SNOW && opponent.hasType?(:ICE) && applysnow
      defense = (defense * 1.5).floor
    end
    defense = defense.chainMods(defmult).pokeRound.pokeClamp

    ##### Damage Modifiers #####
    finalmult = []
    # Screens
    if (!opponent.damagestate.critical) && attacker.ability != :INFILTRATOR
      if ![0x10A, 0x512, 0x80A].include?(@function) # Brick Break, Raging Bull, Unleashed Power
        if opponent.pbOwnSide.screenActive?(betterCategory(attacker, type))
          finalmult.append(@battle.doublebattle ? PBMults::ScreenDoubles : 0.5)
        end
        if opponent.pbOwnSide.effects[:AreniteWall] > 0 && opponent.damagestate.typemod.superEffective?
          finalmult.append(0.5)
        end
      end
      if opponent.pbOwnSide.effects[:AntiMatterShield] != 0 && !attacker.makesContact?(self)
        finalmult.append(@battle.doublebattle ? PBMults::ScreenDoubles : 0.5)
      end
    end
    finalmult.append(1.25) if attacker.ability == :NEUROFORCE && opponent.damagestate.typemod.superEffective?
    finalmult.append(PBMults::ParadoxLeads) if @function == 0x515 && opponent.damagestate.typemod.superEffective? # Collision Course / Electro Drift
    finalmult.append(1.5) if [:DEADEYE, :SNIPER].include?(attacker.ability) && opponent.damagestate.critical
    finalmult.append(2.0) if attacker.ability == :TINTEDLENS && opponent.damagestate.typemod.resisted?
    if opponent.ability == :FLUFFY && !opponent.moldbroken
      finalmult.append(@battle.FE == :CLOUDS ? 0.25 : 0.5) if attacker.makesContact?(self)
      finalmult.append(2.0) if type == :FIRE
    end
    if opponent.ability == :AURAGUARD && !opponent.moldbroken
      finalmult.append(0.5) if attacker.makesContact?(self)
    end
    finalmult.append(0.5) if opponent.ability == :MULTISCALE && !opponent.moldbroken && opponent.hp == opponent.totalhp
    finalmult.append([:DARKNESS2, :DARKNESS3].include?(@battle.FE) ? 0.33 : 0.5) if opponent.ability == :SHADOWSHIELD && (opponent.hp == opponent.totalhp || [:DIMENSIONAL].include?(@battle.FE))
    finalmult.append(0.75) if opponent.ability == :SHADOWSHIELD && [:STARLIGHT, :NEWWORLD, :DARKCRYSTALCAVERN].include?(@battle.FE) && opponent.damagestate.typemod.superEffective?
    finalmult.append(0.75) if (([:SOLIDROCK, :FILTER].include?(opponent.ability) && !opponent.moldbroken) || opponent.ability == :PRISMARMOR) && opponent.damagestate.typemod.superEffective?
    finalmult.append(0.75) if @battle.pbCheckSideAbility(:FRIENDGUARD, opponent, excludeSelf: true, checkMoldBroken: true).any?
    finalmult.append(0.75) if @battle.pbCheckSideCrest(:MINUN, opponent).any? && !pbHitsSpecialStat?(attacker, type)
    finalmult.append(0.5) if @battle.pbCheckSideAbility(:QUAKEPROOF, opponent, checkMoldBroken: true).any? && type == :GROUND
    finalmult.append(0.75) if @battle.pbCheckSideAbility(:EXTRAFLUFFYMANE, opponent, checkMoldBroken: true).any?
    finalmult.append(PBMults::Metronome[[attacker.effects[:Metronome], 5].min]) if attitemworks && attacker.item == :METRONOME && @move == attacker.lastMoveUsed
    finalmult.append(PBMults::Metronome[[attacker.effects[:Metronome], 5].min]) if @battle.FE == :CONCERT4 && @move == attacker.lastMoveUsed
    finalmult.append(0.5) if @battle.pbCheckSideAbility(:PASTELVEIL, opponent).any? && type == :POISON && ([:MISTY, :RAINBOW].include?(@battle.FE) || @battle.OV == :MISTY)
    finalmult.append(0.5) if opponent.ability == :TERASHELL && @battle.FE == :CRYSTALCAVERN && opponent.effects[:TeraShell]
    if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5)
      flowerveil = @battle.pbCheckSideAbility(:FLOWERVEIL, opponent)
      finalmult.append(0.75) if flowerveil.any? { |battler| battler == opponent || opponent.hasType?(:GRASS) }
    end
    soundmoveboostfields = attacker.ability == :JUNGLEBEAT ? [:BIGTOP, :CAVE, :CONCERT, :FOREST] : [:BIGTOP, :CAVE, :CONCERT]
    finalmult.append(soundmoveboostfields.include?(@battle.FE) ? 1.5 : 1.3) if [:PUNKROCK, :JUNGLEBEAT].include?(attacker.ability) && checkSoundMove?(attacker)
    finalmult.append(1.5) if @battle.pbCheckSideCrest(:FLYGON, attacker, excludeSelf: false).any? && checkSoundMove?(attacker)
    finalmult.append(2.0) if attacker.ability == :EXECUTION && opponent.hp <= (opponent.totalhp / 2).floor
    finalmult.append(1.2) if attitemworks && attacker.item == :EXPERTBELT && opponent.damagestate.typemod.superEffective?
    finalmult.append(PBMults::RootOrb) if attitemworks && attacker.item == :LIFEORB # approx. 1.3x
    if opponent.itemWorks? && type == $cache.items[opponent.item].berry&.resisttype &&
       (type == :NORMAL || opponent.damagestate.typemod.superEffective?) &&
       @battle.pbCheckSideAbility(PBStuff::UnnerveAbilities, opponent.pbOpposing1).none? &&
       !blockedBySubstitute?(attacker, opponent)
      finalmult.append(opponent.ability == :RIPEN ? 0.25 : 0.5)
      feedbackMessages[opponent.index].push(:TypeBerry)
      opponent.effects[:TypeBerryActivated] = true unless @preEmptiveCalc
    end
    if @battle.shouldApplyFieldChangeDamageBoost(self, attacker)
      provimult = calculateFieldMultiplier(1.3)
      finalmult.append(provimult)
    end
    finalmult.append(0.67) if opponent.crested == :BEHEEYEM && (!opponent.hasMovedThisRound? || @battle.switchedOut[opponent.index])
    secondtypes = self.getSecondaryType(attacker, type)
    mtype = @battle.getMimicryType(no_random: true)
    finalmult.append(0.5) if opponent.effects[:Shelter] && !mtype.nil? && (type == mtype || secondtypes.include?(mtype))
    finalmult.append(0.70) if opponent.crested == :AMPHAROS && opponent.damagestate.typemod.superEffective?
    finalmult.append(0.8) if opponent.crested == :MEGANIUM || opponent.pbPartner.crested == :MEGANIUM
    if attacker.isbossmon
      shieldbreakmult = $game_variables[:DifficultyModes] == 1 ? 0.25 : 1 # set to 1 for now, will adjust back for future update when time to test has been found
      finalmult.append(shieldbreakmult) if attacker.shieldsBrokenThisTurn.any? { |index| index > 0 }
    end
    if attacker.crested == :SEVIPER
      multiplier = 0.5 * (opponent.pokemon.hp * 1.0) / (opponent.pokemon.totalhp * 1.0)
      multiplier += 1.0
      finalmult.append(multiplier)
    end
    if attacker.crested == :ENTEI
      # entei multiplier = totalhp/1000 + 1, ends up with a multiplier between 1.3 - 1.45
      multiplier = (attacker.pokemon.totalhp * 0.001).floor
      multiplier += 1.0
      multiplier = 1.3 if multiplier < 1.3
      multiplier = 1.5 if multiplier > 1.5
      finalmult.append(multiplier)
    end
    # Trade base power for accuracy
    finalmult.append(getTradePowerForAccMult(attacker, opponent))

    modifydmg = pbModifyDamage(1.0, attacker, opponent)
    modifydmg *= 2.0 if opponent.effects[:Minimize] && antiMinimize?
    finalmult.append(modifydmg)

    opponent.damagestate.typemod = Typemod.zero if @preEmptiveCalc # reset

    ##### Damage Formula #####
    damage = (((2.0 * attacker.level / 5 + 2).floor * basedmg * atk / defense).floor / 50.0).floor + 2
    totaldamage = pbCalcTotalDamage(
      damage, spreadmult, bondmult, weathermult, glaivemult, critmult, randommult,
      stabmult, typemult, burnmult, finalmult, protectmult, opponent,
    )

    return totaldamage
  end

  def getTradePowerForAccMult(attacker, opponent)
    return 1.0 unless self.tradePowerForAcc?

    accuracy = pbCalcAccuracy(attacker, opponent)
    return 1.0 if accuracy == -1 || accuracy >= 100

    return accuracy / 100.0
  end

  def applyTradePowerForAcc(dmg, attacker, opponent)
    multiplier = getTradePowerForAccMult(attacker, opponent)
    return dmg.chainMods([multiplier]).pokeRound.pokeClamp
  end

  def tradePowerForAcc?
    return !@battle.isOnline? && $game_switches[:Trade_Power_For_Accuracy] && !self.pbIsStatus? && @function != 0x70 # OHKO
  end

  def damageCalcMessages(attacker, feedbackMessages, late: false)
    messageHash = {}
    feedbackMessages.each_pair do |index, messages|
      messages.each do |message|
        messageHash[message] = [] unless messageHash.has_key?(message)
        messageHash[message].push(index)
      end
    end
    lateMessages = [:ProtectBreakZMove, :ProtectBreakAbility, :ProtectBreakInterceptium]
    messageHash.each do |message, indexes|
      next if (late && !lateMessages.include?(message)) || (!late && lateMessages.include?(message))

      case message
        when :TeraShell
          indexes.each do |index|
            @battle.pbAbilityBoxAndDisplay(@battle.battlers[index], _INTL("{1} made its shell gleam! It's distorting type matchups!", @battle.battlers[index].pbThis))
          end
        when :ProtectBreakInterceptium
          indexes.each do |index|
            @battle.pbDisplay(_INTL("The Interceptor's power broke through {1}'s Protect!", @battle.battlers[index].pbThis(true)))
          end
        when :ProtectBreakZMove
          indexes.each do |index|
            @battle.pbDisplay(_INTL("{1} couldn't fully protect itself and got hurt!", @battle.battlers[index].pbThis))
          end
        when :ProtectBreakAbility
          indexes.each do |index|
            @battle.pbAbilityBoxAndDisplay(attacker, _INTL("{1} couldn't fully protect itself and got hurt!", @battle.battlers[index].pbThis))
          end
        when :TypeGem
          @battle.pbShowAbilityBox(attacker, item: true)
          @battle.pbCommonAnimation("UseItem", attacker, nil)
          @battle.pbDisplay(_INTL("{1} strengthened {2}'s power!", getItemName(attacker.item, :The), self.name))
          @battle.pbHideAbilityBox(attacker)
        when :NeverMeltIce
          indexes.each do |index|
            @battle.pbShowAbilityBox(@battle.battlers[index], item: true)
            @battle.pbCommonAnimation("UseItem", attacker, nil)
            @battle.pbDisplay(_INTL("{1}'s sheer cold weakened {2}'s power!", getItemName(@battle.battlers[index].item, :The), self.name))
            @battle.pbHideAbilityBox(@battle.battlers[index])
          end
        when :TypeFieldMessage
          fieldMessage = typeFieldMessage(pbType(attacker))
          next if fieldMessage.nil?
          @battle.pbDisplay(pbGetMessageFromHash(:FieldMessages, fieldMessage))
        when :TypeOverlayMessage
          overlayMessage = typeOverlayMessage(pbType(attacker))
          next if overlayMessage.nil?
          @battle.pbDisplay(pbGetMessageFromHash(:FieldMessages, overlayMessage))
        when :ShortCircuit
          damageroll = @battle.field.getRoll(maximize_roll: @battle.OV == :ELECTERRAIN) # roll is locked, will return same roll as damage calc
          messageroll = [_INTL("Bzzt."), _INTL("Bzzapp!"), _INTL("Bzt..."), _INTL("Bzap!"), _INTL("BZZZAPP!")][PBStuff::SHORTCIRCUITROLLS.index(damageroll)]
          @battle.pbDisplay(messageroll)
        when :RainLightning
          @battle.pbDisplay(_INTL("The bad weather amplified the attack!"))
        when :MoveFieldMessage
          fieldmessage = pbGetMessageFromHash(:FieldMessages, self.moveFieldMessage)
          next if fieldmessage.nil?
          opplowercase = !fieldmessage.start_with?("{1}")
          atklowercase = !fieldmessage.start_with?("{2}")
          if fieldmessage.include?("{1}") # includes a reference to the target; display for each target affected individually
            indexes.each do |index|
              @battle.pbDisplay(_INTL(fieldmessage, @battle.battlers[index].pbThis(opplowercase), attacker.pbThis(atklowercase)))
            end
          else
            @battle.pbDisplay(_INTL(fieldmessage, nil, attacker.pbThis(atklowercase)))
          end
        when :OverlayMoveMessage
          overlayMessage = pbGetMessageFromHash(:FieldMessages, self.moveOverlayMessage)
          next if overlayMessage.nil?
          @battle.pbDisplay(overlayMessage)
        when :HighStriker
          @battle.pbDisplay(_INTL("WHAMMO!"))
          abilityBoosted = [:HUGEPOWER, :GUTS, :PUREPOWER, :SHEERFORCE].include?(attacker.ability)
          damageroll = @battle.field.getRoll(update_roll: false, maximize_roll: abilityBoosted, rollmodifier: attacker.stages[PBStats::ATTACK]) # roll is locked, will return same roll as damage calc
          case true
            when damageroll >= 3.0 then strikermessage = _INTL("...OVER 9000!!!")
            when damageroll >= 2.0 then strikermessage = _INTL("...POWERFUL!")
            when damageroll >= 1.5 then strikermessage = _INTL("...NICE!")
            when damageroll >= 1 then strikermessage = _INTL("...OK!")
            else strikermessage = _INTL("...WEAK!")
          end
          abilityBoosted ? @battle.pbAbilityBoxAndDisplay(attacker, strikermessage) : @battle.pbDisplay(strikermessage)
        when :MountainWind
          @battle.pbDisplay(_INTL("The windy weather strengthened the attack!"))
        when :MirrorArenaBeam
          @battle.pbDisplay(_INTL("The beam was focused from the reflection!"))
        when :RainbowBoom
          @battle.pbDisplay(_INTL("It's a Sonic Rainboom!"))
        when :ChessPoltergeist
          @battle.pbDisplay(_INTL("The Chess piece came to life!"))
        when :DimensionalRage
          @battle.pbDisplay(_INTL("Unstoppable Rage!"))
        when :HauntedNightShade
          @battle.pbDisplay(_INTL("The specters became real!"))
        when :BewitchedNightShade
          @battle.pbDisplay(_INTL("Shadowy figures came out of the woods!"))
        when :DeepEarthSeismicToss
          @battle.pbDisplay(_INTL("Slammed into the ground!"))
        when :DeepEarthPsywave
          @battle.pbDisplay(_INTL("The Core's magical forces are immense!"))
        when :DeepEarthPriorityNerf
          @battle.pbDisplay(_INTL("The intense pull slowed the attack..."))
        when :DeepEarthNegPriorityBoost
          @battle.pbDisplay(_INTL("Slow and heavy!"))
        when :ChessQueen
          msg = _INTL("The Queen is dominating the board!")
          attacker.ability == :QUEENLYMAJESTY && attacker.piece != :QUEEN ? @battle.pbAbilityBoxAndDisplay(attacker, msg) : @battle.pbDisplay(msg)
        when :ChessKnightFork
          @battle.pbDisplay(_INTL("The knight forked the opponents!"))
        when :ChessKnightQueen
          @battle.pbDisplay(_INTL("An unblockable attack on the Queen!"))
        when :TypeBerry
          indexes.each do |index|
            battler = @battle.battlers[index]
            @battle.pbShowAbilityBox(battler, item: true)
            @battle.pbCommonAnimation("Nom", battler)
            @battle.pbHideAbilityBox(battler)
          end
      end
    end
  end

  def pbReduceHPDamage(attacker, targets, damages)
    raise "array length mismatch" if targets.length != damages.length
    mons = []
    oldhps = []
    effect = []
    results = []
    bossbreaks = :none
    targets.each_with_index do |opponent, i|
      damage = damages[i]
      next results[i] = damage if damage <= 0 # skip if already taking no damage due to move failure
      if opponent.permeffs[:Stasis]
        oldhp = opponent.hp
        mons.push opponent
        oldhps.push oldhp
        opponent.hp -= opponent.totalhp
        results[i] = opponent.totalhp
        next
      end
      if (!attacker || attacker.index != opponent.index) && blockedBySubstitute?(attacker, opponent)
        damage = opponent.effects[:Substitute] if damage > opponent.effects[:Substitute]
        opponent.effects[:Substitute] -= damage
        opponent.damagestate.substitute = true
        @battle.scene.pbDamageAnimation(opponent, 0)
        @battle.pbDisplay(_INTL("The substitute took damage for {1}!", opponent.pbThis(true)))
        if opponent.effects[:Substitute] == 0
          @battle.scene.pbUnSubstituteSprite(opponent)
          @battle.pbDisplay(_INTL("{1}'s substitute faded!", opponent.pbThis))
        end
        results[i] = damage
      elsif opponent.effects[:Disguise] && (!attacker || attacker.index != opponent.index) && !opponent.moldbroken
        @battle.pbShowAbilityBox(opponent) if !opponent.effects[:clearDisguise]
        opponent.pbBreakDisguise
        opponent.damagestate.disguise = true
        message = _INTL("{1}'s disguise was busted!", opponent.pbThis) if !opponent.effects[:clearDisguise]
        if Gen >= 8
          opponent.pbReduceHP((opponent.totalhp / 8.0).floor, message: message)
        else
          @battle.pbDisplay(message)
        end
        opponent.effects[:Disguise] = false
        @battle.pbHideAbilityBox(opponent) if !opponent.effects[:clearDisguise]
        results[i] = 0
      elsif opponent.effects[:IceFace] && (pbIsPhysical?(attacker, type) || @battle.FE == :FROZENDIMENSION) && (!attacker || attacker.index != opponent.index) && !opponent.moldbroken
        @battle.pbShowAbilityBox(opponent) if !opponent.effects[:clearDisguise]
        opponent.pbBreakDisguise
        opponent.damagestate.disguise = true
        @battle.pbDisplay(_INTL("{1} transformed!", opponent.pbThis)) if !opponent.effects[:clearDisguise]
        opponent.effects[:IceFace] = false
        @battle.pbHideAbilityBox(opponent) if !opponent.effects[:clearDisguise]
        results[i] = 0
      end
    end
    targets.each_with_index do |opponent, i|
      damage = damages[i]
      next if results[i] != nil
      next results[i] = damage if damage <= 0 # skip if already taking no damage due to move failure
      if opponent.permeffs[:Stasis]
        oldhp = opponent.hp
        mons.push opponent
        oldhps.push oldhp
        opponent.hp -= opponent.totalhp
        results[i] = opponent.totalhp
        next
      end
      opponent.damagestate.substitute = false
      opponent.damagestate.disguise = false
      damagelimit = opponent.hp
      hpTotal = opponent.totalhp
      hpthreshold = 0
      if opponent.isbossmon
        if opponent.shieldCount > 0 && opponent.onBreakEffects && opponent.onBreakEffects[opponent.shieldCount]
          onBreakdata = opponent.onBreakEffects[opponent.shieldCount]
          if !@battle.snapshot.nil? && @battle.snapshot[1] && @battle.snapshot[1][:snapshotUses] == 0
            onBreakdata = opponent.onBreakEffects[opponent.shieldCount * -1]
          end
          hpthreshold = onBreakdata && onBreakdata[:threshold] ? onBreakdata[:threshold] : 0
          unless hpthreshold == 1
            damagelimit = opponent.hp - (opponent.totalhp * hpthreshold).round
            hpTotal = opponent.totalhp - (opponent.totalhp * hpthreshold).round
          end
        end
      end
      if damage >= damagelimit
        damage = damagelimit
        if @function == 0xE9 # False Swipe
          damage -= 1
        elsif opponent.effects[:Endure]
          damage -= 1
          opponent.damagestate.endured = true
        elsif damage == hpTotal && @battle.FE == :CHESS && opponent.piece == :PAWN && !opponent.damagestate.pawnsturdyused
          opponent.damagestate.pawnsturdyused = true
          opponent.damagestate.pawnsturdy = true
          damage -= 1
        elsif damage == hpTotal && opponent.ability == :STURDY && !opponent.moldbroken
          opponent.damagestate.sturdy = true
          damage -= 1
        elsif opponent.damagestate.focussash && damage == hpTotal && opponent.item
          opponent.damagestate.focussashused = true
          damage -= 1
        elsif opponent.damagestate.focusband
          opponent.damagestate.focusbandused = true
          damage -= 1
        elsif opponent.damagestate.rampcrest && !opponent.permeffs[:RampCrest]
          opponent.damagestate.rampcrestused = true
          opponent.permeffs[:RampCrest] = true
          damage -= 1
        elsif damage == hpTotal && opponent.ability == :STALWART && @battle.FE == :COLOSSEUM && !opponent.moldbroken
          opponent.damagestate.stalwart = true
          damage -= 1
        end
        if opponent.isbossmon && damage == damagelimit
          if hpthreshold == 1
            damage = opponent.hp - 1
            bossbreaks = :admin
          elsif hpthreshold > 0
            bossbreaks = :normal
          end
        end
        damage = 0 if damage < 0
      end
      oldhp = opponent.hp
      mons.push opponent
      oldhps.push oldhp
      opponent.hp -= damage

      effectiveness = 0
      if opponent.damagestate.typemod.resisted?
        effectiveness = 1   # "Not very effective"
      elsif opponent.damagestate.typemod.superEffective?
        effectiveness = 2   # "Super effective"
      end
      if !opponent.damagestate.typemod.immune?
        effect.push effectiveness
      end
      results[i] = damage
    end
    if effect.length > 0
      targets.each_with_index do |opponent, i|
        if opponent.effects[:clearDisguise]
          typemod2 = pbCalcTypeMod(self.type, attacker, opponent.effects[:clearDisguise])
          effectiveness = 0
          if typemod2.resisted?
            effectiveness = 1   # "Not very effective"
          elsif typemod2.superEffective?
            effectiveness = 2   # "Super effective"
          elsif typemod2.immune?
            effectiveness = 3 # immunity
          end
          @battle.pbCommonAnimation("IllusionDamage", opponent, nil) if effect[i] != effectiveness
        elsif attacker.effects[:clearDisguise]
          typemod2 = pbCalcTypeMod(attacker.effects[:clearDisguise].fakeMove.type, attacker, opponent)
          effectiveness = 0
          if typemod2.resisted?
            effectiveness = 1   # "Not very effective"
          elsif typemod2.superEffective?
            effectiveness = 2   # "Super effective"
          elsif typemod2.immune?
            effectiveness = 3 # immunity
          end
          @battle.pbCommonAnimation("IllusionDamage", opponent, nil) if effect[i] != effectiveness
        end
      end
      @battle.scene.pbDamageAnimation(mons, effect.max)
    end
    if mons.length > 0
      @battle.scene.pbHPChanged(mons, oldhps)
    end
    return results, bossbreaks
  end

  ################################################################################
  # Effects
  ################################################################################
  def pbEffectMessages(attacker, opponent, multipletargets = false)
    if opponent.damagestate.critical
      message = multipletargets ? _INTL("A critical hit on {1}!", opponent.pbThis(true)) : _INTL("A critical hit!")
      @battle.pbDisplay(message, color: :crit)
      attacker.addCritsLanded
      if @battle.ProgressiveFieldCheck(PBFields::CONCERT)
        @battle.growField(_INTL("The critical hit"), attacker)
      end
    end
    if !pbIsMultiHit && !(attacker.effects[:ParentalBond] || attacker.effects[:TyphBond] || attacker.effects[:SurgingBlessing] > 0)
      opponent.pbEffectivenessMessage(multipletargets)
    end
    if opponent.permeffs[:Stasis]
      @battle.pbDisplay(_INTL("{1} was shattered!", opponent.pbThis))
    elsif opponent.damagestate.endured
      @battle.pbDisplay(_INTL("{1} endured the hit!", opponent.pbThis))
    elsif opponent.damagestate.pawnsturdy
      opponent.damagestate.pawnsturdy = false
      @battle.pbDisplay(_INTL("{1} hung on the edge of the board!", opponent.pbThis))
    elsif opponent.damagestate.sturdy
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("{1} endured the hit!", opponent.pbThis))
      opponent.damagestate.sturdy = false
    elsif opponent.damagestate.focussashused
      @battle.pbShowAbilityBox(opponent, item: true)
      @battle.pbCommonAnimation("UseItem", opponent, nil)
      @battle.pbDisplay(_INTL("{1} hung on using its {2}!", opponent.pbThis, getItemName(opponent.item)))
      @battle.pbHideAbilityBox(opponent)
      opponent.pbDisposeItem(symbiosis: :delay, duringattack: true)
      opponent.damagestate.focussashused = false
    elsif opponent.damagestate.focusbandused
      @battle.pbShowAbilityBox(opponent, item: true)
      @battle.pbCommonAnimation("UseItem", opponent, nil)
      @battle.pbDisplay(_INTL("{1} hung on using its {2}!", opponent.pbThis, getItemName(opponent.item)))
      @battle.pbHideAbilityBox(opponent)
    elsif opponent.damagestate.rampcrestused
      msg = _INTL("{1} endured the hit!", opponent.pbThis)
      @battle.pbAbilityBoxAndDisplay(opponent, msg, item: true)
      opponent.damagestate.rampcrestused = false
    elsif opponent.damagestate.stalwart
      @battle.pbAbilityBoxAndDisplay(opponent, _INTL("{1} endured the hit!", opponent.pbThis))
      opponent.damagestate.stalwart = false
    end
  end

  # Used for all AllBattlers and AllyBattlers moves
  def pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
    if opponent == attacker
      targets = attacker.pbTarget(self) == :AllBattlers ? @battle.battlers : @battle.battlers.select { |i| !attacker.pbIsOpposing?(i.index) }
      if targets.none? { |target| !target.isFainted? && successproc.call(attacker, target) }
        if showMessage
          msg = @move == :TEATIME ? _INTL("But nothing happened!") : _INTL("But it failed!")
          @battle.pbDisplay(msg)
        end
        return false
      end
    end
    return successproc.call(attacker, opponent)
  end

  def getRecoil(attacker, damage, recoilmult, hitflags)
    return 0 unless hitflags.include?(:Success) || attacker.permeffs[:Frenzy]
    return 0 if attacker.ability == :ROCKHEAD
    return 0 if attacker.crested == :RAMPARDOS
    return 0 if @battle.magicGuardAbilities.include?(attacker.ability)
    recoilmult = [recoilmult, 0.33].max if attacker.permeffs[:Frenzy]
    return (damage * recoilmult).round
  end

  def inflictRecoil(attacker, recoil, hitflags)
    recoil = attacker.pbReduceHP(recoil, message: _INTL("{1} was damaged by the recoil!", attacker.pbThis))
    return recoil
  end

  # move effect that applies once per hit during move use, typically on the user
  def pbEffect(attacker, alltargets, hitnum = 0)
  end

  # move effect that applies once per target for each hit during move use
  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
  end

  # move effect that applies on the user after resolving all hits of the attack
  def pbEffectAfterMove(attacker, alltargets, hitflags)
  end

  # move effect that applies on the target after resolving all hits of the attack
  def pbEffectTargetAfterMove(attacker, opponent, alltargets = nil)
  end

  def priorityCheck(attacker)
    pri = self.priority

    pri += 1 if @move == :GRASSYGLIDE && (@battle.FE == :GRASSY || @battle.OV == :GRASSY)
    pri += 1 if @move == :QUASH && [:DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE)
    pri += 1 if @battle.FE == :CHESS && attacker.pokemon && attacker.piece == :KING
    pri += 1 if attacker.crested == :FERALIGATR && pbIsDamaging? && attacker.turncount == 1
    pri += 1 if attacker.ability == :PRANKSTER && pbIsStatus? && attacker.effects[:TwoTurnAttack] == 0
    pri += 1 if attacker.galeWingsActive? && pbType(attacker) == :FLYING
    pri += 3 if attacker.ability == :TRIAGE && (isHealingMove? || isDrainingMove?)
    pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER
    return pri
  end

  def pbIsPriorityMoveAI(attacker)
    if [:FAKEOUT, :FIRSTIMPRESSION].include?(@move)
      return false if attacker.turncount != 0
    end
    return priorityCheck(attacker) > 0
  end

  def pbFixedDamageMove?
    return true if @move == :GRAVITY && @battle.FE == :DEEPEARTH
    return true if PBStuff::FIXEDDAMAGEFUNCTIONS.include?(@function)
    return false
  end

  def additionalEffectChance(user, addeffect, hitcount)
    addeffect = 20 if @move == :OMINOUSWIND && @battle.FE == :HAUNTED
    addeffect *= 2 if user.ability == :SERENEGRACE || @battle.FE == :RAINBOW || @battle.OV == :RAINBOW
    addeffect *= 2 if !self.canFlinch? && user.ability == :SERENEGRACE && (@battle.FE == :RAINBOW || @battle.OV == :RAINBOW)
    addeffect = 100 if $DEBUG && Input.press?(Input::CTRL) && !@battle.isOnline?
    addeffect = 100 if @move == :MIRRORSHOT && @battle.FE == :MIRROR
    addeffect = 100 if @move == :STRANGESTEAM && @battle.FE == :FAIRYTALE
    addeffect = 100 if @move == :LICK && @battle.FE == :HAUNTED
    addeffect = 100 if @move == :DIRECLAW && @battle.FE == :WASTELAND
    addeffect = 100 if @move == :INFERNALPARADE && @battle.FE == :INFERNAL
    addeffect = 100 if @move == :FREEZINGGLARE && @battle.FE == :DEUXFINALIS
    addeffect = 100 if @move == :BITTERBLADE && @battle.FE == :DEUXFINALIS
    addeffect = 30 if @move == :SACREDFIRE && user.crested == :ENTEI && pbTargetsAll?(user)
    addeffect = 0 if (user.crested == :LEDIAN && hitcount > 1) || (user.crested == :CINCCINO && hitcount > 1)
    if @battle.pbRandom(100) < addeffect # format for check with the returned value
      return true
    end
    return false
  end

  ################################################################################
  # cass's lazy field effect thingy section (i never said i knew what i was doing)
  ################################################################################
  def ignitecheck
    # Intentionally not using pbWeather so that Cloud Nine doesn't affect field interactions.
    return @battle.state.effects[:WaterSport] <= 0 && @battle.weather != :RAINDANCE
  end

  ################################################################################
  # Using the move
  ################################################################################
  def pbOnStartUse(attacker, targets)
    return true
  end

  def pbShortUseMove(attacker, targets)
    # Early Move execution that ignores most failure checks
    # meant to be subclased
    # return value as symbols
    # :Bide: handling for Bide Charging up
    # :CallerMove: moves that call other moves for execution
    # :FutureSight: sets attack that happens in a future turn
    # :FailedMove: move that has to be checked at this timing but failed
    # :ContinueMove: (technically anything works here) move goes into normal move processing
    return :ContinueMove
  end

  def pbAddTarget(targets, target, attacker)
    unless target.isFainted?
      targets.push(target)
      return true
    end
    return false
  end

  def pbDisplayUseMessage(attacker, choice)
    movename = attacker.effects[:clearDisguise] ? getMoveName(attacker.effects[:clearDisguise].fakeMove.move) : @name
    if choice[2].zmove && choice[2].data.zmovedata&.intercept
      @battle.pbDisplayBrief(_INTL("{1} is changing the flow of Fate!", attacker.pbThis))
      @battle.pbDisplayBrief(_INTL("{1}!", movename))
    elsif choice[2].zmove
      @battle.pbDisplay(_INTL("{1} unleashes its full force Z-Move!", attacker.pbThis)) unless attacker.usingsubmove
      case @callermove&.move
        when :ASSIST, :SLEEPTALK, :METRONOME then @battle.pbDisplay(_INTL("{1} will change the chosen {2} to its Z-Move!", attacker.pbThis, getMoveName(@zbasemove)))
        when :COPYCAT then @battle.pbDisplay(_INTL("{1} will change the copied {2} to its Z-Move!", attacker.pbThis, getMoveName(@zbasemove)))
        when :MEFIRST then @battle.pbDisplay(_INTL("{1} will change the stolen {2} to its Z-Move!", attacker.pbThis, getMoveName(@zbasemove)))
        when :MIRRORMOVE then @battle.pbDisplay(_INTL("{1} will change the mirrored {2} to its Z-Move!", attacker.pbThis, getMoveName(@zbasemove)))
        when :NATUREPOWER then @battle.pbDisplay(_INTL("{1}'s {3} turned into {2}!", attacker.pbThis, movename, getMoveName(@callermove.move)))
      end
      message = pbIsStatus? ? _INTL("{1} used\n{2}!", attacker.pbThis, movename) : _INTL("{1}!", movename)
      @battle.pbDisplayBrief(message)
    elsif attacker.effects[:MagicBounced]
      @battle.pbDisplayBrief(_INTL("{1} bounced the {2} back!", attacker.pbThis, movename))
    else
      case @callermove&.move
        when :METRONOME then @battle.pbDisplayBrief(_INTL("Waggling a finger\nlet it use {1}!", movename))
        when :NATUREPOWER then @battle.pbDisplayBrief(_INTL("{1} turned into\n{2}!", getMoveName(@callermove.move), movename))
        else
          @battle.pbDisplayBrief(_INTL("{1} is preparing to tell a chillingly bad joke!", attacker.pbThis)) if @move == :CHILLYRECEPTION
          @battle.pbDisplayBrief(_INTL("{1} used\n{2}!", attacker.pbThis, movename))
      end
    end
  end

  def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
    return if !showanimation

    id = PBStuff::SHOWCASEMOVES[id] || id
    id = ReplacementAnimations[id] || id if Rejuv

    @battle.pbAnimation(id, attacker, opponent, hitnum)
  end

  def pbOnDamageLost(damage, attacker, opponent, bossbreaks = :none)
    # Used by Counter/Mirror Coat/Revenge/Focus Punch/Bide
    type = pbType(attacker)
    if opponent.effects[:Bide] > 0
      opponent.effects[:BideDamage] += damage
      opponent.effects[:BideTarget] = attacker.index
    end
    if opponent.effects[:ShellTrap] == true && attacker.pbOwnSide != opponent.pbOwnSide && !opponent.damagestate.substitute && pbIsPhysical?(attacker, type) && !(attacker.ability == :SHEERFORCE && self.effect > 0 && Gen < Champs)
      opponent.effects[:ShellTrapAttacked] = true
    end
    if @function == 0x90 # Hidden Power
      type = :NORMAL
    end
    if pbIsPhysical?(attacker, type)
      opponent.effects[:Counter] = damage
      opponent.effects[:CounterTarget] = attacker.index
    end
    if pbIsSpecial?(attacker, type)
      opponent.effects[:MirrorCoat] = damage
      opponent.effects[:MirrorCoatTarget] = attacker.index
    end
    opponent.lastHPLost = damage # for Revenge/Focus Punch/Metal Burst
    opponent.lastAttacker = attacker.index # for Revenge/Metal Burst
    if opponent.isbossmon
      if opponent.shieldCount > 0 && opponent.onBreakEffects
        onBreakdata = opponent.onBreakEffects[opponent.shieldCount]
        party = @battle.pbPartySingleOwner(opponent.index)
        case bossbreaks
        when :normal
          @battle.scene.pbShieldBreakToText(opponent) # TTS + Logging
          opponent.pbRecoverHP(opponent.totalhp, true, fullrecover: true)
          party[opponent.pokemonIndex].status = opponent.status
          @battle.pbShieldEffects(opponent, onBreakdata) if onBreakdata
          shieldCountChange = onBreakdata && onBreakdata[:shieldCountChange] ? onBreakdata[:shieldCountChange] : 1
          if !(onBreakdata && onBreakdata[:userSwitch] && @battle.pbCanChooseNonActive?(opponent.index))
            opponent.shieldCount -= shieldCountChange if opponent.shieldCount > 0
            @battle.scene.pbUpdateShield(opponent.shieldCount, opponent.index)
            @battle.callingSOS = true if opponent.sosDetails
          end
        when :admin
          party[opponent.pokemonIndex].status = opponent.status
          opponent.pbRecoverHP(opponent.totalhp, true, fullrecover: true)
          if onBreakdata
            if onBreakdata[:thresholdmessage] && onBreakdata[:thresholdmessage] != ""
              if onBreakdata[:thresholdmessage].start_with?("{1}")
                @battle.pbDisplay(_INTL(onBreakdata[:thresholdmessage], opponent.pbThis))
              else
              @battle.pbDisplay(_INTL(onBreakdata[:thresholdmessage], opponent.pbThis(true)))
              end
            end
            @battle.pbShieldEffects(opponent, onBreakdata, false, nil, true) if onBreakdata
          end
          opponent.reconstructAdmin
        end
      end
    end
  end

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    # Called to determine whether the move succeeds
    return true
  end

  def pbEffectValid(attacker, opponent, showMessage = false)
    return true
  end

  def to_s
    return "#<#{self.class} @move=#{@move}, @user=#{@user.name}>"
  end
end

# Used in damage calculation (actual as well as AI)
# opponent is used by test suite
def pbCalcTotalDamage(
  damage, spread, bond, weather, glaive, crit, random,
  stab, type, burn, final, protect, opponent
)
  damage = damage.chainMods(spread).pokeRound
  damage = damage.chainMods(bond).pokeRound
  damage = damage.chainMods(weather).pokeRound
  damage = damage.chainMods(glaive).pokeRound
  damage = damage.chainMods(crit).pokeRound
  damage = (damage * random).floor
  damage = damage.chainMods(stab).pokeRound
  damage = (damage * type).floor
  damage = damage.chainMods(burn).pokeRound
  damage = damage.chainMods(final).pokeRound
  damage = damage.chainMods(protect).pokeRound

  damage = damage.pokeClamp
  return damage
end

# Used in accuracy calculation (both actual and AI)
def pbCalcFinalAccuracy(baseaccuracy, accmodifier, stage, micle)
  accuracy = baseaccuracy
  accuracy = accuracy.chainMods(accmodifier).pokeRound
  accuracy = (accuracy * stage).pokeRound
  accuracy = accuracy.chainMods(micle).pokeRound
  return accuracy
end

class Float
  def pokeRound
    return self.round(half: :down)
  end
end

class Integer
  def chainMods(mods)
    mods = Array(mods)
    finalMod = 4096.0
    mods.each { |mod|
      finalMod = (finalMod * 4096.0 * mod / 4096.0).round
    }
    return self * finalMod / 4096.0
  end

  def pokeClamp
    return 1 if self < 1
    return self
  end
end

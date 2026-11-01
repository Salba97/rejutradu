class PokeBattle_Battler
  # Helper methods
  def pbShieldsUp?
    return false if @species != :MINIOR
    return false if @ability != :SHIELDSDOWN || @effects[:Transform]
    return false if self.form != 7

    return true
  end

  def shouldBeMoldBroken?(attacker, move)
    # sanity checks are the attacker and move valid objects for this check?
    # if even one isn't the correct object class the assumption is that moldbreaker does not apply
    # check is being made as in some contexts attacker can be nil and move can be either nil or a marker symbol
    return false unless attacker.is_a?(PokeBattle_Battler)
    return false unless move.is_a?(PokeBattle_Move)
    return false if self.hasWorkingItem(:ABILITYSHIELD)
    return true if attacker.ability == :MYCELIUMMIGHT && move.pbIsStatus?
    return true if [:MOLDBREAKER, :TERAVOLT, :TURBOBLAZE].include?(attacker.ability)
    # Sunsteel Strike, Moongeist Beam, Photon Geyser, Decimation, Menacing Moonraze Maelstrom, Searing Sunraze Smash, Light that Burns the Sky
    return true if [0x166, 0x176, 0x200].include?(move.function)
    return false
  end

  def shouldBeSubIgnored?(attacker, move)
    return true if attacker.nil?
    return true if attacker == self
    return true if move.nil?
    return false if !move.is_a?(PokeBattle_Move)
    return move.hitsThroughSubstitute?(attacker)
  end

  def pbCanApplySelectStatus?(status, attacker, move, ignorestatus: false, showMessage: false)
    case status
      when :SLEEP
        return pbCanSleep?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)
      when :PARALYSIS
        return pbCanParalyze?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)
      when :POISON, :TOXIC
        return pbCanPoison?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)
      when :FREEZE
        return pbCanFreeze?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)
      when :BURN
        return pbCanBurn?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)
      when :CONFUSION
        return pbCanConfuse?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)
      when :PETRIFIED
        return pbCanPetrify?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)
      when :FRENZY
        return pbCanFrenzy?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)
      else
        return true
    end
  end

  def pbApplySelectStatus(status, user, duration: nil, message: nil, volatile: true)
    case status
      when :BURN
        return pbBurn(user, message: message)
      when :FREEZE
        return pbFreeze(message: message)
      when :SLEEP
        return pbSleep(message: message, duration: duration)
      when :PARALYSIS
        return pbParalyze(user, message: message)
      when :POISON
        return pbPoison(user, false, message: message)
      when :TOXIC
        return pbPoison(user, true, message: message)
      when :CONFUSION
        return pbConfuse(message: message) if volatile
      when :FRENZY
        return pbFrenzy(message: message) if volatile
      when :PETRIFIED
        return pbPetrify(user, message: message)
    end
  end

  # Catchall true/false for situations where one can't be statused
  def pbCanStatus?(attacker, move, ignorestatus: false, showMessage: false)
    ignoreSafeguard = attacker == self || attacker&.ability == :INFILTRATOR
    ignoreSub = shouldBeSubIgnored?(attacker, move)
    moldbroken = shouldBeMoldBroken?(attacker, move)
    partnerMoldbroken = pbPartner.shouldBeMoldBroken?(attacker, move)
    flowerVeil = nil
    flowerVeil = self if self.ability == :FLOWERVEIL && !moldbroken
    flowerVeil = pbPartner if pbPartner.ability == :FLOWERVEIL && !partnerMoldbroken

    failure = nil
    case true
      when flowerVeil && (hasType?(:GRASS) || @battle.FE == :BEWITCHED) && attacker != self then failure = :FlowerVeil
      when self.ability == :PURIFYINGSALT && !moldbroken then failure = :PurifyingSalt
      when (@battle.FE == :MISTY || @battle.OV == :MISTY) && !isAirborne? then failure = :Misty
      when Rejuv && @battle.FE == :DRAGONSDEN && hasWorkingItem(:AMULETCOIN) then failure = :AmuletCoin
      when (!ignorestatus && !self.status.nil?) || (self.ability == :COMATOSE && @battle.FE != :ELECTERRAIN) then failure = :Statused
      when @damagestate.substitute || (@effects[:Substitute] > 0 && !ignoreSub) then failure = :Substitute
      when pbShieldsUp? then failure = :Shields
      when pbOwnSide.effects[:Safeguard] > 0 && !ignoreSafeguard then failure = :Safeguard
      when self.leafGuardActive? && !moldbroken then failure = :LeafGuard
    end
    return true unless failure

    if showMessage
      case failure
        when :FlowerVeil then @battle.pbAbilityBoxAndDisplay(flowerVeil, _INTL("{1} surrounded itself with a veil of petals!", pbThis))
        when :PurifyingSalt then @battle.pbAbilityBoxAndDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :Misty then @battle.pbDisplay(_INTL("{1} is protected by the {2}!", pbThis, getMoveName(:MISTYTERRAIN)))
        when :AmuletCoin then @battle.pbDisplay(_INTL("The Amulet Coin prevents {1} from being inflicted with status on Dragon's Den!", pbThis(true)))
        when :LeafGuard then @battle.pbAbilityBoxAndDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :Statused then @battle.pbDisplay(_INTL("But it failed!"))
        when :Substitute then @battle.pbDisplay(_INTL("But it failed!"))
        when :Shields then @battle.pbAbilityBoxAndDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :Safeguard then @battle.pbDisplay(_INTL("{1} is protected by {2}!", pbThis, getMoveName(:SAFEGUARD)))
      end
    end
    return false
  end

  #===============================================================================
  # Sleep
  #===============================================================================
  def pbCanSleep?(attacker, move, ignorestatus: false, showMessage: false)
    return false if isFaintedAndNoShields?

    if (!ignorestatus && self.status == :SLEEP) || (self.ability == :COMATOSE && @battle.FE != :ELECTERRAIN)
      @battle.pbDisplay(_INTL("{1} is already asleep!", pbThis)) if showMessage
      return false
    end
    return false if !pbCanStatus?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)

    moldbroken = shouldBeMoldBroken?(attacker, move)
    partnerMoldbroken = pbPartner.shouldBeMoldBroken?(attacker, move)
    sweetVeil = []
    sweetVeil.push(self) if self.ability == :SWEETVEIL && !moldbroken
    sweetVeil.push(pbPartner) if pbPartner.ability == :SWEETVEIL && !partnerMoldbroken

    failure = nil
    case true
      when [:VITALSPIRIT, :INSOMNIA].include?(self.ability) && !moldbroken then failure = :Ability
      when sweetVeil.any? then failure = :SweetVeil
      when self.ability == :WORLDOFNIGHTMARES then failure = :Nightmares
      when (@battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN) && !isAirborne? then failure = :ElecTerrain
      when @battle.ProgressiveFieldCheck(PBFields::CONCERT, 3, 4) then failure = :Concert
      when self.ability == :EARLYBIRD && !moldbroken && @battle.FE == :SKY then failure = :EarlyBird
      when @effects[:Uproar] > 0 then failure = :UproarSelf
      when @battle.battlers.any? { |i| i.effects[:Uproar] > 0 } then failure = :Uproar
    end
    return true unless failure

    if showMessage
      case failure
        when :Ability then @battle.pbAbilityBoxAndDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :SweetVeil then @battle.pbAbilityBoxAndDisplay(sweetVeil.first, _INTL("{1} can't fall asleep due to a veil of sweetness!", pbThis))
        when :Nightmares then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s dreams jolted them right back up!", pbThis))
        when :ElecTerrain then @battle.pbDisplay(_INTL("{1} is protected by the {2}!", pbThis, getMoveName(:ELECTRICTERRAIN)))
        when :Concert then @battle.pbDisplay(_INTL("The concert is too loud and hype to sleep!"))
        when :EarlyBird then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} can't fall asleep in the open skies!", pbThis))
        when :UproarSelf then @battle.pbDisplay(_INTL("But {1} can't sleep in an uproar!", pbThis(true)))
        when :Uproar then @battle.pbDisplay(_INTL("But the uproar kept {1} awake!", pbThis(true)))
      end
    end
    return false
  end

  def pbSleep(rest: false, duration: nil, message: nil)
    message = _INTL("{1} fell asleep!", pbThis) if message.nil?

    if duration.nil?
      if rest
        duration = @battle.FE == :CROWD ? 1 : 2
      else
        duration = @battle.sample([1, 2, Gen >= Champs ? 2 : 3])
      end
    end
    unless duration == -1 # infinite sleep (antiwoke password)
      duration += 1 if [:DARKNESS2, :DARKNESS3].include?(@battle.FE)
      duration = (duration / 2.0).floor if self.ability == :EARLYBIRD
      duration += 1 # needed for counting down
    end

    self.status = :SLEEP
    self.statusCount = duration
    self.permeffs[:SleptTurns] = 0
    @battle.pbCommonAnimation("Sleep", self, nil)
    @battle.pbDisplay(message) if message
    pbBerryHerbCheck(true)
  end

  #===============================================================================
  # Poison
  #===============================================================================
  def pbCanPoison?(attacker, move, ignorestatus: false, showMessage: false)
    return false if isFaintedAndNoShields?

    if self.status == :POISON
      @battle.pbDisplay(_INTL("{1} is already poisoned!", pbThis)) if showMessage
      return false
    end
    return false if !pbCanStatus?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)

    moldbroken = shouldBeMoldBroken?(attacker, move)
    partnerMoldbroken = pbPartner.shouldBeMoldBroken?(attacker, move)
    pastelVeil = []
    if @battle.FE != :INFERNAL
      pastelVeil.push(self) if self.ability == :PASTELVEIL && !moldbroken
      pastelVeil.push(pbPartner) if pbPartner.ability == :PASTELVEIL && !partnerMoldbroken
    end

    failure = nil
    case true
      when (hasType?(:POISON) || hasType?(:STEEL)) && attacker&.ability != :CORROSION && !([:CORROSIVE, :CORROSIVEMIST].include?(@battle.FE) && attacker&.ability == :TOXICCHAIN) then failure = :Type
      when self.ability == :IMMUNITY && !moldbroken then failure = :Ability
      when pastelVeil.any? then failure = :PastelVeil
    end
    return true unless failure

    if showMessage
      case failure
        when :Type then @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :Ability then @battle.pbAbilityBoxAndDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :PastelVeil then @battle.pbAbilityBoxAndDisplay(pastelVeil.first, _INTL("It doesn't affect\n{1}...", pbThis(true)))
      end
    end
    return false
  end

  def pbPoison(attacker, toxic = false, message: nil)
    message = toxic ? _INTL("{1} was badly poisoned!", pbThis) : _INTL("{1} was poisoned!", pbThis) if message.nil?
    self.status = :POISON
    if toxic
      self.statusCount = 1
      @effects[:Toxic] = 0
    else
      self.statusCount = 0
    end
    @battle.pbCommonAnimation("Poison", self, nil)
    @battle.pbDisplay(message) if message
    if attacker.pokemon.species == :PECHARUNT && attacker.ability == :POISONPUPPETEER && pbCanConfuse?(attacker, nil, showMessage: false)
      @battle.pbShowAbilityBox(attacker)
      pbConfuse
      @battle.pbHideAbilityBox(attacker)
    end
    if self.index != attacker.index
      @battle.synchronize[0] = self.index
      @battle.synchronize[1] = attacker.index
      @battle.synchronize[2] = :POISON
      pbSynchronize
    end
    pbBerryHerbCheck(true)
  end

  #===============================================================================
  # Burn
  #===============================================================================
  def pbCanBurn?(attacker, move, ignorestatus: false, showMessage: false)
    return false if isFaintedAndNoShields?

    if self.status == :BURN
      @battle.pbDisplay(_INTL("{1} is already burned!", pbThis)) if showMessage
      return false
    end
    return false if !pbCanStatus?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)

    moldbroken = shouldBeMoldBroken?(attacker, move)

    failure = nil
    case true
      when self.ability == :WATERBUBBLE && !moldbroken then failure = :WaterBubble
      when hasType?(:FIRE) then failure = :Type
      when self.ability == :WATERVEIL && !moldbroken then failure = :WaterVeil
      when self.ability == :THERMALEXCHANGE && !moldbroken then failure = :ThermalExchange
    end
    return true unless failure

    if showMessage
      case failure
        when :WaterBubble, :ThermalExchange then @battle.pbAbilityBoxAndDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :Type then @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :WaterVeil then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} surrounded itself with a veil of water!", pbThis))
      end
    end
    return false
  end

  def pbBurn(attacker, message: nil)
    message = _INTL("{1} was burned!", pbThis) if message.nil?
    self.status = :BURN
    self.statusCount = 0
    @battle.pbCommonAnimation("Burn", self, nil)
    @battle.pbDisplay(message) if message
    if self.index != attacker.index
      @battle.synchronize[0] = self.index
      @battle.synchronize[1] = attacker.index
      @battle.synchronize[2] = :BURN
      pbSynchronize
    end
    pbBerryHerbCheck(true)
  end

  #===============================================================================
  # Paralyze
  #===============================================================================
  def pbCanParalyze?(attacker, move, ignorestatus: false, showMessage: false)
    return false if isFaintedAndNoShields?

    if self.status == :PARALYSIS
      @battle.pbDisplay(_INTL("{1} is already paralyzed!", pbThis)) if showMessage
      return false
    end
    return false if !pbCanStatus?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)

    moldbroken = shouldBeMoldBroken?(attacker, move)

    failure = nil
    case true
      when self.ability == :LIMBER && !moldbroken then failure = :Limber
      when hasType?(:ELECTRIC) then failure = :Type
    end
    return true unless failure

    if showMessage
      case failure
        when :Limber then @battle.pbAbilityBoxAndDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :Type then @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", pbThis(true)))
      end
    end
    return false
  end

  def pbParalyze(attacker, message: nil)
    message = _INTL("{1} is paralyzed!\nIt may be unable to move!", pbThis) if message.nil?
    self.status = :PARALYSIS
    self.statusCount = 0
    @battle.pbCommonAnimation("Paralysis", self, nil)
    @battle.pbDisplay(message) if message
    if self.index != attacker.index
      @battle.synchronize[0] = self.index
      @battle.synchronize[1] = attacker.index
      @battle.synchronize[2] = :PARALYSIS
      pbSynchronize
    end
    pbBerryHerbCheck(true)
  end

  #===============================================================================
  # Freeze
  #===============================================================================
  def pbCanFreeze?(attacker, move, ignorestatus: false, showMessage: false)
    return false if isFaintedAndNoShields?
    return false if !pbCanStatus?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)
    return false if self.hasType?(:ICE)
    return false if @battle.pbWeather(attacker) == :SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)
    return false if self.ability == :MAGMAARMOR && !shouldBeMoldBroken?(attacker, move) && @battle.FE != :FROZENDIMENSION
    return false if [:VOLCANIC, :BURNING].include?(@battle.FE)

    return true
  end

  def pbFreeze(message: nil)
    message = _INTL("{1} was frozen solid!", pbThis) if message.nil?
    self.status = :FROZEN
    self.statusCount = 0
    @battle.pbCommonAnimation("Frozen", self, nil)
    @battle.pbDisplay(message) if message
    if self.pokemon&.species == :SHAYMIN && self.form == 1
      self.form = 0
      self.pbUpdate(true)
      @battle.scene.pbChangePokemon(self, @pokemon)
      @battle.pbDisplay(_INTL("{1} transformed!", pbThis))
    end
    pbBerryHerbCheck(true)
  end

  #===============================================================================
  # Petrify
  #===============================================================================
  def pbCanPetrify?(attacker, move, ignorestatus: false, showMessage: false)
    return false if isFaintedAndNoShields?

    if self.status == :PETRIFIED
      @battle.pbDisplay(_INTL("{1} is already petrified!", pbThis)) if showMessage
      return false
    end
    return false if !pbCanStatus?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)

    immunitysource = self.ability if [:FAIRYAURA, :DARKAURA, :AURABREAK, :ROUGHSKIN].include?(self.ability)
    if immunitysource
      @battle.pbDisplay(_INTL("{1}'s {2} prevents petrification!", pbThis, getAbilityName(self.ability))) if showMessage
      return false
    end

    if hasType?(:ROCK)
      @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", pbThis(true))) if showMessage
      return false
    end
    return true
  end

  def pbPetrify(attacker, message: nil)
    message = _INTL("{1} was petrified!", pbThis) if message.nil?
    self.status = :PETRIFIED
    if @effects[:Substitute] == 0
      @battle.scene.pbUnSubstituteSprite(self)
    else
      @battle.scene.pbSubstituteSprite(self)
    end
    self.statusCount = 0
    @battle.pbDisplay(message) if message
    @effects[:Petrification] = attacker.index
    pbBerryHerbCheck(true)
  end

  #===============================================================================
  # Generalised status displays
  #===============================================================================
  def pbContinueStatus(showAnim = true)
    case self.status
      when :SLEEP
        @battle.pbCommonAnimation("Sleep", self, nil)
        @battle.pbDisplay(_INTL("{1} is fast asleep.", pbThis))
      when :POISON
        @battle.pbCommonAnimation("Poison", self, nil)
        @battle.pbDisplay(_INTL("{1} was hurt by poison!", pbThis))
      when :BURN
        @battle.pbCommonAnimation("Burn", self, nil)
        @battle.pbDisplay(_INTL("{1} was hurt by its burn!", pbThis))
      when :PARALYSIS
        @battle.pbCommonAnimation("Paralysis", self, nil)
        @battle.pbDisplay(_INTL("{1} is paralyzed!\nIt can't move!", pbThis))
      when :FROZEN
        @battle.pbCommonAnimation("Frozen", self, nil)
        @battle.pbDisplay(_INTL("{1} is frozen solid!", pbThis))
    end
    if self.isbossmon
      if self.chargeAttack

        if self.chargeAttackRequirementMet?
          if [:SLEEP, :PARALYSIS, :FROZEN].include?(self.status)
            self.chargeAttack[:turns] += 1
            self.chargeAttack[:canIntermediateAttack] = false
          end
        end
      end
    end
  end

  def pbCureStatus(showMessage = true, item: false)
    return false if self.status.nil?

    oldstatus = self.status
    self.healStatus
    if showMessage
      itemname = getItemName(self.item) if item
      case oldstatus
        when :SLEEP     then message = item ? _INTL("{1}'s {2} woke it up!", pbThis, itemname) : _INTL("{1} woke up!", pbThis)
        when :POISON    then message = item ? _INTL("{1}'s {2} cured its poison!", pbThis, itemname) : _INTL("{1} was cured of its poisoning!", pbThis)
        when :BURN      then message = item ? _INTL("{1}'s {2} cured its burn!", pbThis, itemname) : _INTL("{1}'s burn was cured!", pbThis)
        when :PARALYSIS then message = item ? _INTL("{1}'s {2} cured its paralysis!", pbThis, itemname) : _INTL("{1} was cured of paralysis!", pbThis)
        when :FROZEN    then message = item ? _INTL("{1}'s {2} defrosted it!", pbThis, itemname) : _INTL("{1} was thawed out!", pbThis)
        when :PETRIFIED then message = item ? _INTL("{1}'s {2} released it from the stone.", pbThis, itemname) : _INTL("{1} was released from the stone.", pbThis)
      end
      @battle.pbDisplay(message)
    end
    if @effects[:Substitute] == 0
      @battle.scene.pbUnSubstituteSprite(self)
    else
      @battle.scene.pbSubstituteSprite(self)
    end
    if [:SLEEP, :FROZEN].include?(oldstatus) && self.isbossmon && self.chargeAttack && self.chargeAttackRequirementMet?
      self.chargeAttack[:canIntermediateAttack] = true
    end
  end

  #===============================================================================
  # Confuse
  #===============================================================================
  def pbCanConfuse?(attacker, move, ignorestatus: false, showMessage: false)
    return false if isFaintedAndNoShields?

    ignoreSafeguard = attacker == self || attacker&.ability == :INFILTRATOR
    ignoreSub = shouldBeSubIgnored?(attacker, move)
    moldbroken = shouldBeMoldBroken?(attacker, move)

    failure = nil
    case true
      when @effects[:Confusion] > 0 then failure = :Confusion
      when @damagestate.substitute || (@effects[:Substitute] > 0 && !ignoreSub) then failure = :Substitute
      when self.ability == :OWNTEMPO && !moldbroken then failure = :OwnTempo
      when @battle.FE == :ASHENBEACH && hasType?(:FIGHTING) then failure = :AshenFight
      when @battle.FE == :ASHENBEACH && self.ability == :INNERFOCUS then failure = :AshenFocus
      when pbOwnSide.effects[:Safeguard] > 0 && !ignoreSafeguard then failure = :Safeguard
      when @battle.FE == :MISTY && !isAirborne? then failure = :Misty
    end
    return true unless failure

    if showMessage
      case failure
        when :Confusion then @battle.pbDisplay(_INTL("But it failed!"))
        when :Substitute then @battle.pbDisplay(_INTL("But it failed!"))
        when :OwnTempo then @battle.pbAbilityBoxAndDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :AshenFight then @battle.pbDisplay(_INTL("{1} broke through the confusion!", pbThis))
        when :AshenFocus then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} broke through the confusion!", pbThis))
        when :Safeguard then @battle.pbDisplay(_INTL("{1} is protected by {2}!", pbThis, getMoveName(:SAFEGUARD)))
        when :Misty then @battle.pbDisplay(_INTL("{1} is protected by the {2}!", pbThis, getMoveName(:MISTYTERRAIN)))
      end
    end
    return false
  end

  def pbConfuse(message: nil)
    message = _INTL("{1} became confused!", pbThis) if message.nil?
    @effects[:Confusion] = 2 + @battle.pbRandom(4)
    @battle.pbCommonAnimation("Confusion", self, nil)
    @battle.pbDisplay(message) if message
    pbBerryHerbCheck(true)
  end

  def pbContinueConfusion
    @battle.pbCommonAnimation("Confusion", self, nil)
    @battle.pbDisplayBrief(_INTL("{1} is confused!", pbThis))
  end

  def pbCureConfusion(showMessage = true, item: false)
    return false if @effects[:Confusion] == 0

    @effects[:Confusion] = 0
    if showMessage
      itemname = getItemName(self.item) if item
      message = item ? _INTL("{1}'s {2} snapped it out of its confusion!", pbThis, itemname) : _INTL("{1} snapped out of its confusion!", pbThis)
      @battle.pbDisplay(message)
    end
  end

  #===============================================================================
  # Frenzy
  #===============================================================================
  def pbCanFrenzy?(attacker, move, ignorestatus: false, showMessage: false)
    return false if isFaintedAndNoShields?

    ignoreSafeguard = attacker == self || attacker&.ability == :INFILTRATOR
    ignoreSub = shouldBeSubIgnored?(attacker, move)
    moldbroken = shouldBeMoldBroken?(attacker, move)

    failure = nil
    case true
      when self.permeffs[:Frenzy] == true then failure = :Frenzy
      when @damagestate.substitute || (@effects[:Substitute] > 0 && !ignoreSub) then failure = :Substitute
      when hasType?(:FIGHTING) then failure = :Type
      when self.ability == :OWNTEMPO && !moldbroken then failure = :OwnTempo
      when self.ability == :INNERFOCUS && !moldbroken then failure = :InnerFocus
      when pbOwnSide.effects[:Safeguard] > 0 && !ignoreSafeguard then failure = :Safeguard
      when @battle.FE == :MISTY && !isAirborne? then failure = :Misty
    end
    return true unless failure

    if showMessage
      case failure
        when :Frenzy then @battle.pbDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :Substitute then @battle.pbDisplay(_INTL("But it failed!"))
        when :Type then @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :OwnTempo, :InnerFocus then @battle.pbAbilityBoxAndDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :Safeguard then @battle.pbDisplay(_INTL("{1} is protected by {2}!", pbThis, getMoveName(:SAFEGUARD)))
        when :Misty then @battle.pbDisplay(_INTL("{1} is protected by the {2}!", pbThis, getMoveName(:MISTYTERRAIN)))
      end
    end
  end

  def pbFrenzy(message: nil)
    message = _INTL("{1} was sent into a frenzy!", pbThis) if message.nil?
    self.permeffs[:Frenzy] = true
    @battle.pbCommonAnimation("Frenzy", self, nil)
    @battle.pbDisplay(message) if message
    pbBerryHerbCheck(true)
  end

  def pbContinueFrenzy
    @battle.pbCommonAnimation("Frenzy", self, nil)
    @battle.pbDisplayBrief(_INTL("{1} is frenzied!", pbThis))
  end

  def pbCureFrenzy(showMessage = true, item: false)
    return false if !self.permeffs[:Frenzy]

    self.permeffs[:Frenzy] = false
    if showMessage
      itemname = getItemName(self.item) if item
      message = item ? _INTL("{1}'s {2} snapped it out of its Frenzy!", pbThis, itemname) : _INTL("{1} snapped out of its Frenzy!", pbThis)
      @battle.pbDisplay(message)
    end
  end
  #===============================================================================
  # Attraction
  #===============================================================================
  def pbCanAttract?(attacker, move, showMessage: false)
    return false if isFaintedAndNoShields?

    if @effects[:Attract] >= 0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    if attacker.isGenderless? || self.isGenderless? || attacker.gender == self.gender
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end

    moldbroken = shouldBeMoldBroken?(attacker, move)
    partnerMoldbroken = pbPartner.shouldBeMoldBroken?(attacker, move)

    aromaVeil = []
    aromaVeil.push(self) if self.ability == :AROMAVEIL && !moldbroken
    aromaVeil.push(pbPartner) if pbPartner.ability == :AROMAVEIL && !partnerMoldbroken
    if aromaVeil.any?
      @battle.pbAbilityBoxAndDisplay(aromaVeil.first, _INTL("{1} is protected by an aromatic veil!", pbThis)) if showMessage
      return false
    end
    if self.ability == :OBLIVIOUS && !moldbroken
      @battle.pbAbilityBoxAndDisplay(self, _INTL("It doesn't affect\n{1}...", pbThis(true))) if showMessage
      return false
    end

    return true
  end

  def pbAttract(attacker)
    @effects[:Attract] = attacker.index
    @battle.pbCommonAnimation("Attract", self, nil)
    @battle.pbDisplay(_INTL("{1} fell in love!", pbThis))
    if hasWorkingItem(:DESTINYKNOT) && attacker.ability != :OBLIVIOUS && attacker.effects[:Attract] < 0
      attacker.effects[:Attract] = self.index
      @battle.pbCommonAnimation("Attract", attacker, nil)
      @battle.pbDisplay(_INTL("{1} fell in love because of {2}!", attacker.pbThis, getItemName(self.item, :the)))
      attacker.pbBerryHerbCheck(true)
    end
    pbBerryHerbCheck(true)
  end

  def pbAnnounceAttract(seducer)
    @battle.pbCommonAnimation("Attract", self, nil)
    @battle.pbDisplayBrief(_INTL("{1} is in love with {2}!", pbThis, seducer.pbThis(true)))
  end

  def pbContinueAttract
    @battle.pbDisplay(_INTL("{1} is immobilized by love!", pbThis))
  end

  #===============================================================================
  # Increase stat stages
  #===============================================================================
  def pbTooHigh?(stat)
    return @stages[stat] >= 6
  end

  def pbCanIncreaseAnyStat?(stats, statinducer, move, showMessage: false, ignoreContrary: false)
    return pbCanIncreaseStatStage?(stats[0], statinducer, move, showMessage: showMessage, ignoreContrary: ignoreContrary) if stats.length == 1

    moldbroken = shouldBeMoldBroken?(statinducer, move)
    return pbCanReduceAnyStat?(stats, statinducer, move, showMessage: showMessage, ignoreContrary: true) if self.ability == :CONTRARY && !moldbroken && !ignoreContrary

    canIncrease = stats.any? { |stat| pbCanIncreaseStatStage?(stat, statinducer, move) }
    @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", pbThis)) if !canIncrease && showMessage
    return canIncrease
  end

  def pbCanIncreaseStatStage?(stat, statinducer, move, showMessage: false, ignoreContrary: false)
    return false if isFaintedAndNoShields?

    moldbroken = shouldBeMoldBroken?(statinducer, move)
    return pbCanReduceStatStage?(stat, statinducer, move, showMessage: showMessage, ignoreContrary: true) if self.ability == :CONTRARY && !moldbroken && !ignoreContrary

    if pbTooHigh?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!", pbThis, getStatName(stat))) if showMessage
      return false
    end
    return true
  end

  def pbIncreaseStatBasic(stat, increment, copyable: true, statinducer: nil)
    initial = @stages[stat]
    @stages[stat] += increment
    @stages[stat] = 6 if @stages[stat] > 6
    @effects[:Jealousy] = true
    diff = @stages[stat] - initial
    @copyableStatBoosts[stat] += diff if copyable && !(self.ability == :MEMORYLEAK && statinducer != self)
    return diff
  end

  #===============================================================================
  # Decrease stat stages
  #===============================================================================
  def pbTooLow?(stat)
    return @stages[stat] <= -1 if self.ability == :EXECUTION && PBStats::Offensive.include?(stat)

    return @stages[stat] <= -6
  end

  def pbTooLowEX?(stat) # only for specific purposes (adrenaline orb)
    return self.ability == :CONTRARY ? pbTooHigh?(stat) : pbTooLow?(stat)
  end

  def pbCanReduceAnyStat?(stats, statinducer, move, showMessage: false, ignoreContrary: false)
    return pbCanReduceStatStage?(stats[0], statinducer, move, showMessage: showMessage, ignoreContrary: ignoreContrary) if stats.length == 1

    moldbroken = shouldBeMoldBroken?(statinducer, move)
    return pbCanIncreaseAnyStat?(stats, statinducer, move, showMessage: showMessage, ignoreContrary: true) if self.ability == :CONTRARY && !moldbroken && !ignoreContrary

    failure = nil
    unless statinducer == self
      partnerMoldbroken = pbPartner.shouldBeMoldBroken?(statinducer, move)
      ignoreSub = shouldBeSubIgnored?(statinducer, move)
      # move not being nil marks substitute not being ignored, intimidate-like abilities pass a symbol so sub works against them
      flowerVeil = nil
      flowerVeil = self if self.ability == :FLOWERVEIL && !moldbroken
      flowerVeil = pbPartner if pbPartner.ability == :FLOWERVEIL && !partnerMoldbroken

      case true
        when flowerVeil && (hasType?(:GRASS) || @battle.FE == :BEWITCHED) then failure = :FlowerVeil
        when @damagestate.substitute || (@effects[:Substitute] > 0 && !ignoreSub) then failure = :Substitute
        when pbOwnSide.effects[:Mist] > 0 && statinducer&.ability != :INFILTRATOR then failure = :Mist
        when ([:CLEARBODY, :WHITESMOKE].include?(self.ability) && !moldbroken) || self.ability == :FULLMETALBODY then failure = :ClearBody
        when @battle.FE == :CLOUDS && self.ability == :EARLYBIRD && !moldbroken then failure = :ClearBody
      end
    end
    failure = :CantReduce if !failure && stats.none? { |stat| pbCanReduceStatStage?(stat, statinducer, move) }
    unless statinducer == self || failure
      case true
        when self.hasWorkingItem(:CLEARAMULET) then failure = :ClearAmulet
        when @battle.FE == :CLOUDS && self.hasWorkingItem(:PRETTYWING) then failure = :ClearAmulet
      end
    end
    return true unless failure

    if showMessage
      case failure
        when :FlowerVeil then @battle.pbAbilityBoxAndDisplay(flowerVeil, _INTL("{1} surrounded itself with a veil of petals!", pbThis))
        when :Substitute then @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :Mist then @battle.pbDisplay(_INTL("{1} is protected by the mist!", pbThis))
        when :ClearBody then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s stats were not lowered!", pbThis))
        when :CantReduce then @battle.pbDisplay(_INTL("{1}'s stats can't be lowered!", pbThis)) # can be due to -6 or abilities like hyper cutter or a combination of both
        when :ClearAmulet then @battle.pbDisplay(_INTL("{1}'s {2} prevents its stats from being lowered!", pbThis, getItemName(self.item)))
      end
    end
    return false
  end

  def pbCanReduceStatStage?(stat, statinducer, move, showMessage: false, ignoreContrary: false)
    return false if isFaintedAndNoShields?

    moldbroken = shouldBeMoldBroken?(statinducer, move)
    return pbCanIncreaseStatStage?(stat, statinducer, move, showMessage: showMessage, ignoreContrary: true) if self.ability == :CONTRARY && !moldbroken && !ignoreContrary

    failure = nil
    unless statinducer == self
      partnerMoldbroken = pbPartner.shouldBeMoldBroken?(statinducer, move)
      ignoreSub = shouldBeSubIgnored?(statinducer, move)
      # move not being nil marks substitute not being ignored, intimidate-like abilities pass a symbol so sub works against them
      flowerVeil = nil
      flowerVeil = self if self.ability == :FLOWERVEIL && !moldbroken
      flowerVeil = pbPartner if pbPartner.ability == :FLOWERVEIL && !partnerMoldbroken

      case true
        when flowerVeil && (hasType?(:GRASS) || @battle.FE == :BEWITCHED) then failure = :FlowerVeil
        when @damagestate.substitute || (@effects[:Substitute] > 0 && !ignoreSub) then failure = :Substitute
        when pbOwnSide.effects[:Mist] > 0 && statinducer&.ability != :INFILTRATOR then failure = :Mist
        when ([:CLEARBODY, :WHITESMOKE].include?(self.ability) && !moldbroken) || self.ability == :FULLMETALBODY then failure = :ClearBody
        when @battle.FE == :CLOUDS && self.ability == :EARLYBIRD && !moldbroken then failure = :ClearBody
        when stat == PBStats::ATTACK && self.ability == :HYPERCUTTER && !moldbroken then failure = :HyperCutter
        when stat == PBStats::DEFENSE && self.ability == :BIGPECKS && !moldbroken then failure = :HyperCutter
        when stat == PBStats::ACCURACY && ([:KEENEYE, :MINDSEYE].include?(self.ability) || (self.ability == :ILLUMINATE && Gen >= 9)) && !moldbroken then failure = :HyperCutter
      end
    end
    failure = :TooLow if !failure && pbTooLow?(stat)
    unless statinducer == self || failure
      case true
        when self.hasWorkingItem(:CLEARAMULET) then failure = :ClearAmulet
        when stat == PBStats::SPEED && self.hasWorkingItem(:ARIACREST) then failure = :CLEARAMULET
        when @battle.FE == :CLOUDS && self.hasWorkingItem(:PRETTYWING) then failure = :ClearAmulet
      end
    end
    return true unless failure

    if showMessage
      case failure
        when :FlowerVeil then @battle.pbAbilityBoxAndDisplay(flowerVeil, _INTL("{1} surrounded itself with a veil of petals!", pbThis))
        when :Substitute then @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", pbThis(true)))
        when :Mist then @battle.pbDisplay(_INTL("{1} is protected by Mist!", pbThis))
        when :ClearBody then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s stats were not lowered!", pbThis))
        when :HyperCutter then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s {2} was not lowered!", pbThis, getStatName(stat)))
        when :TooLow then @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!", pbThis, getStatName(stat)))
        when :ClearAmulet then @battle.pbDisplay(_INTL("{1}'s {2} prevents its stats from being lowered!", pbThis, getItemName(self.item)))
      end
    end
    return false
  end

  def pbReduceStatBasic(stat, increment)
    initial = @stages[stat]
    @stages[stat] -= increment
    @stages[stat] = -6 if @stages[stat] < -6
    diff = @stages[stat] - initial # returns negative result
    @effects[:EjectPack] = true
    @effects[:LashOut] = true
    return diff
  end

  #===============================================================================
  # Stat change helper methods
  #===============================================================================
  def playStatMessage(stats, magnitude, statmessage, statinducer)
    stats = Array(stats)
    statnames = stats.map { |stat| getStatName(stat) }
    statstring = joinStrings(statnames)
    statdrop = magnitude < 0
    magnitude *= -1 if magnitude < 0
    magnitude = 3 if magnitude > 3
    magnitudestrings = statdrop ? ["", _INTL(" harshly"), _INTL(" severely")] : ["", _INTL(" sharply"), _INTL(" drastically")]
    harsh = magnitudestrings[magnitude - 1]
    statdirection = getStatDirectionVerb(statdrop ? _INTL("lowered") : _INTL("raised"), stats.length)

    case statmessage
      when :bossShieldOpp
        messagetext = _INTL("{5}'s fracturing aura{3} {4} {1}'s {2}!", pbThis(true), statstring, harsh, statdirection, statinducer.pbThis)
      when :bossShieldSelf
        messagetext = _INTL("{1}'s fracturing aura{3} {4} its {2}!", pbThis, statstring, harsh, statdirection)
      when :CrowdBoo
        messagetext = _INTL("The Crowd's booing{3} {4} {1}'s {2}!", pbThis(true), statstring, harsh, statdirection)
      when :SyrupBomb
        messagetext = _INTL("The sticky syrup{3} {4} {1}'s {2}!", pbThis(true), statstring, harsh, statdirection)
      when :Octolock
        messagetext = _INTL("The Octolock{3} {4} {1}'s {2}!", pbThis(true), statstring, harsh, statdirection)
      when :IcySpeed
        statdirection = getStatDirectionVerb(statdrop ? _INTL("lost") : _INTL("gained"), stats.length)
        messagetext = _INTL("{1} {2} momentum on the ice!", pbThis, statdirection)
      when :Item, *PBStuff::STATBERRIES
        item = statmessage == :Item ? self.item : statmessage
        messagetext = _INTL("{5}{3} {4} {1}'s {2}!", pbThis(true), statstring, harsh, statdirection, getItemName(item, :The))
      when :FieldAbility
        cause = getFieldAbilityFlavorString
        messagetext = _INTL("{1}'s {5}{3} {4} its {2}!", pbThis, statstring, harsh, statdirection, cause)
      when :BackalleyPursuit
        messagetext = _INTL("{1}'s {5}{3} {4} its {2}!", pbThis, statstring, harsh, statdirection, getMoveName(:PURSUIT))
      when :ColosseumKill
        messagetext = _INTL("The cheering audience{3} {4} {1}'s {2}!", pbThis(true), statstring, harsh, statdirection)
      when :zpower
        messagetext = _INTL("{1} {4} its {2}{3} using its Z-Power!", pbThis, statstring, harsh, statdirection)
      when :TEALMASK, :WELLSPRINGMASK, :HEARTHFLAMEMASK, :CORNERSTONEMASK
        statdirection = getStatDirectionVerb(statdrop ? _INTL("lowering") : _INTL("raising"), stats.length)
        messagetext = _INTL("{1}'s {5} shone brilliantly,{3} {4} its {2}!", pbThis, statstring, harsh, statdirection, getItemName(statmessage))
      else
        statdirection = getStatDirectionVerb(statdrop ? _INTL("fell") : _INTL("rose"), stats.length)
        message = statdrop ? _INTL("{1}'s {2}{4} {3}!") : _INTL("{1}'s {2} {3}{4}!")
        messagetext = _INTL(message, pbThis, statstring, statdirection, harsh)
    end
    @battle.pbDisplay(messagetext)
  end

  # To be overridden by translations that need different verbs for different numbers of stats
  def getStatDirectionVerb(baseverb, statnum)
    return baseverb
  end

  def getFieldAbilityFlavorString
    flavor = {
      :ShiningArmor    => _INTL("shining armor"),
      :RoyalShield     => _INTL("royal shield"),
      :MagicalPower    => _INTL("magical power"),
      :ReflectiveArmor => _INTL("reflective armor"),
      :Anger           => _INTL("anger"),
      :FerociousHeart  => _INTL("ferocious heart"),
    }
    case @battle.FE
      when :FAIRYTALE
        case self.ability
          when :BATTLEARMOR, :SHELLARMOR, :ARMORTAIL then return flavor[:ShiningArmor]
          when :STANCECHANGE then return flavor[:RoyalShield]
          when :MAGICGUARD, :MAGICBOUNCE, :PASTELVEIL, :MAGICIAN, :POWEROFALCHEMY then return flavor[:MagicalPower]
          when :MIRRORARMOR then return flavor[:ReflectiveArmor]
        end
      when :DIMENSIONAL, :FROZENDIMENSION
        return flavor[:Anger] if [:BERSERK, :JUSTIFIED, :ANGERPOINT].include?(self.ability)
      when :COLOSSEUM
        case self.ability
          when :BATTLEARMOR, :SHELLARMOR, :MIRRORARMOR, :DAUNTLESSSHIELD then return flavor[:ShiningArmor]
          when :MAGICGUARD then return flavor[:MagicalPower]
          when :INTREPIDSWORD, :NOGUARD, :JUSTIFIED then return flavor[:FerociousHeart]
        end
    end
    return getAbilityName(self.ability) # shouldn't actually ever get here
  end

  def updateStatGraphic
    @battle.scene.sprites["battlebox#{@index}"].pbShowStatsBoosts if defined?(@battle.scene.sprites["battlebox#{@index}"].pbShowStatsBoosts)
  end

  def pbProcDefiant(times = 1)
    if self.ability == :DEFIANT
      stats, amounts = [], []
      if pbCanIncreaseStatStage?(PBStats::ATTACK, self, nil)
        @battle.pbShowAbilityBox(self)
        stats.push(PBStats::ATTACK)
        amounts.push((@battle.FE == :BACKALLEY ? 3 : 2) * times)
      end
      if @battle.FE == :COLOSSEUM && pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
        @battle.pbShowAbilityBox(self)
        stats.push(PBStats::DEFENSE)
        amounts.push(2 * times)
      end
      pbChangeStats(stats, amounts, self, nil, abilitycheck: :hide)
      @battle.pbHideAbilityBox(self)
    end
    if self.ability == :COMPETITIVE && !(Rejuv && @battle.FE == :CHESS)
      stats, amounts = [], []
      if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
        @battle.pbShowAbilityBox(self)
        stats.push(PBStats::SPATK)
        amounts.push((@battle.FE == :CITY ? 3 : 2) * times)
      end
      if @battle.FE == :COLOSSEUM && pbCanIncreaseStatStage?(PBStats::SPDEF, self, nil)
        @battle.pbShowAbilityBox(self)
        stats.push(PBStats::SPDEF)
        amounts.push(2 * times)
      end
      pbChangeStats(stats, amounts, self, nil, abilitycheck: :hide)
      @battle.pbHideAbilityBox(self)
    end
  end

  def pbProcMirrorArmor(statinducer, stats, amounts)
    if statinducer.nil?
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s {2} blocked the stat drop!", pbThis, getAbilityName(self.ability)))
      return false
    else
      @battle.pbShowAbilityBox(self)
      worked = statinducer.pbChangeStats(stats, amounts, self, nil, ignoreMirror: true)
      @battle.pbHideAbilityBox(self)
      return worked
    end
  end

  def pbOpportunistCopy(hash, memoryleak: false)
    stats, amounts = [], []
    for stat, amount in hash
      if stat == :crit
        self.effects[:FocusEnergy] = amount
      else
        stats.push(stat)
        amounts.push(amount)
      end
    end
    pbChangeStats(stats, amounts, self, nil, abilitycheck: :hide, copyable: false, ignoreContrary: memoryleak)
  end

  def condenseStatArray(array)
    # Change [[Atk, 1], [Def, 1], [Atk, 1], [Def, 1]] to [[Atk, 2], [Def, 2]]
    condensedarray1 = []
    for pair in array
      match = condensedarray1.find { |pair2| pair2[0] == pair[0] }
      match ? match[1] += pair[1] : condensedarray1.push(pair)
    end
    # Change [[Atk, 2], [Def, 2]] to [[[Atk, Def], 2]]
    condensedarray2 = []
    for pair in condensedarray1
      match = condensedarray2.find { |pair2| pair2[1] == pair[1] }
      match ? match[0].push(pair[0]) : condensedarray2.push([[pair[0]], pair[1]])
    end
    return condensedarray2
  end

  def unapplyAbilitiesToStatArray(array, simple, contrary)
    newarray = []
    for pair in array
      stat, amount = pair[0], pair[1]
      if simple # Convert 2 stages to 1, 3 to 2, -2 to -1, -3 to -2, and so on
        amount /= 2.0
        amount = amount > 0 ? amount.ceil : amount.floor
      end
      amount *= -1 if contrary
      newarray.push([stat, amount])
    end
    return newarray
  end

  #===============================================================================
  # Stat change master method
  #===============================================================================
  def pbChangeStats(stats, amounts, statinducer, move, abilitycheck: :show, statmessage: :default, ignoreContrary: false, copyable: true, ignoreMirror: false, counter: nil)
    stats = Array(stats)
    amounts = Array(amounts)
    amounts *= stats.length if amounts.length < stats.length
    raise "Array length mismatch" if amounts.length != stats.length

    # Remove any '0' stat changes
    stats.map!.with_index{ |stat, i| amounts[i] == 0 ? nil : stat }.compact!
    amounts.map!{ |amount| amount == 0 ? nil : amount }.compact!
    return if stats.empty? || amounts.empty?

    moldbroken = shouldBeMoldBroken?(statinducer, move)

    # Contrary handling
    contrary = self.ability == :CONTRARY && !moldbroken && !ignoreContrary
    amounts.map! { |i| -i } if contrary

    positive, negative = [], []
    for i in 0...stats.length
      stat, amount = stats[i], amounts[i]
      # Ability check (change stat only if you can)
      unless abilitycheck == :skip
        next if amount > 0 && !pbCanIncreaseStatStage?(stat, statinducer, move, showMessage: abilitycheck == :show, ignoreContrary: ignoreContrary)
        next if amount < 0 && !pbCanReduceStatStage?(stat, statinducer, move, showMessage: abilitycheck == :show, ignoreContrary: ignoreContrary)
      end
      amount > 0 ? positive.push([stat, amount]) : negative.push([stat, amount])
    end

    # Mirror Armor handling
    if self.ability == :MIRRORARMOR && !ignoreMirror && !moldbroken && statinducer != self && negative.any?
      pbProcMirrorArmor(statinducer, negative.map { |i| i[0] }, negative.map { |i| i[1] })
      negative.clear
    end

    # Simple handling
    simple = self.ability == :SIMPLE && !moldbroken
    (positive + negative).each { |pair| pair[1] = pair[1] * 2 } if simple

    # Negative stat stage handling
    # Actual stat change
    negative.each { |pair| pair[1] = pbReduceStatBasic(pair[0], -pair[1]) }
    negative.delete_if { |pair| pair[1] == 0 }
    # Animation
    @battle.pbCommonAnimation("StatDown", self) if negative.any?
    # Battle message
    unless statmessage == :none
      condensed = condenseStatArray(negative)
      condensed.each { |pair| playStatMessage(pair[0], pair[1], statmessage, statinducer) }
    end

    # Positive stat stage handling
    # Actual stat change
    positive.each { |pair| pair[1] = pbIncreaseStatBasic(pair[0], pair[1], copyable: copyable, statinducer: statinducer) }
    positive.delete_if { |pair| pair[1] == 0 }
    # Animation
    @battle.pbCommonAnimation("StatUp", self) if positive.any?
    # Battle message
    unless statmessage == :none
      condensed = condenseStatArray(positive)
      condensed.each { |pair| playStatMessage(pair[0], pair[1], statmessage, statinducer) }
    end

    # Update certain counters if stat changes actually occur
    pCounters = unapplyAbilitiesToStatArray(positive, simple, contrary)
    nCounters = unapplyAbilitiesToStatArray(negative, simple, contrary)
    case counter
      when :Stockpile
        (pCounters + nCounters).each { |pair|
          self.effects[:StockpileDef] += pair[1] if pair[0] == PBStats::DEFENSE
          self.effects[:StockpileSpDef] += pair[1] if pair[0] == PBStats::SPDEF
        }
      when :Crowd
        (pCounters + nCounters).each { |pair| self.tempBoosts[pair[0]] += pair[1] if self.tempBoosts[pair[0]] }
    end

    # Force stat graphic update when stat change is not followed by a message
    self.updateStatGraphic if statmessage == :none

    # Defiant/Competitive
    pbProcDefiant(negative.length) if negative.length >= 1 && statinducer != self

    # Concert hype down
    concertdropcount = positive.count { |pair| pair[0] == PBStats::EVASION } + negative.count { |pair| [PBStats::EVASION, PBStats::ACCURACY].include?(pair[0]) }
    @battle.reduceField(concertdropcount) if concertdropcount >= 1

    return positive.any? || negative.any?
  end

  #===============================================================================
  # Miscellaneous
  #===============================================================================
  def pbCanTransform?(choice, move = nil)
    return false if self.effects[:Transform] || choice.effects[:Transform]
    if move
      # check if the transform move can bypass substitute
      return false if move.blockedBySubstitute?(self, choice)
      # semi invulnerability is checked much earlier for moves and doesn't need to be confirmed here
    else
      # transform via non-move source check for semi-invulnerability and substitute
      return false if choice.effects[:Substitute] > 0
      return false if choice.isSemiInvul?
    end
    return false if choice.effects[:Illusion]
    return false if choice.isTerastallized?
    return false if choice.isUntransformableForm?
    return true
  end

  def pbTransform(choice)
    @battle.scene.pbVanishSprite(choice) if choice.vanished # Transform animation may make a vanished target unvanish
    oldname = pbThis # Saves the name pre-transformation for the message
    battler = choice
    # Handle ExcludeDex forms
    if choice.getCacheData.checkFlag?(:ExcludeDex)
      battler = @battle.ai.pbMakeFakeBattler(choice.pokemon.clone, choice.pokemonIndex, false, choice.index)
      battler.form = 0
      battler.form = choice.form % pulseArceusTypes if choice.species == :ARCEUS
      battler.pbUpdate(true, fakebattler: true)
      battler.attack, battler.defense = battler.defense, battler.attack if choice.effects[:PowerTrick]
    end
    # Change sprite
    dummymon = battler.pokemon.makeTransformClone(self.pokemon) # Needed so that certain sprite modifications aren't copied
    @battle.scene.pbChangePokemon(self, dummymon)
    @effects[:Transform] = dummymon
    # Update attributes
    @species = battler.species
    @gender = battler.gender
    @weight = battler.weight
    @type1 = battler.type1
    @type2 = battler.type2
    @effects[:TemporaryType] = battler.effects[:TemporaryType]
    @attack = battler.attack
    @defense = battler.defense
    @spatk = battler.spatk
    @spdef = battler.spdef
    @speed = battler.speed
    @effects[:ShownBaseStats] = battler.pokemon.baseStats.clone
    @effects[:ShownBaseStats][PBStats::HP] = self.pokemon.baseStats[PBStats::HP]
    # Since Transform copies stats wholesale, it should show base stats as they were on the pokemon that it copied (relevant for stuff like Castform Crest)
    @form = battler.form
    @effects[:PowerTrick] = false
    for i in PBStats::All
      @stages[i] = choice.stages[i]
    end
    @effects[:FocusEnergy] = choice.effects[:FocusEnergy]
    self.permeffs[:HitsTaken] = choice.permeffs[:HitsTaken]
    @baseExp   = battler.baseExp
    @evYield   = battler.evYield
    # Update moves
    @moves.clear
    for i in 0...4
      next if !choice.moves[i]

      @battle.pbLearnMoveBattler(self, choice.moves[i].move, i)
      @moves[i].totalpp = [5, choice.moves[i].totalpp].min
      @moves[i].pp = @moves[i].totalpp
    end
    @moves.each { |copiedmove| @battle.ai.addMoveToMemory(self, copiedmove) }
    choice.moves.each { |moveloop| @battle.ai.addMoveToMemory(choice, moveloop) }
    @effects[:Disable] = 0
    @effects[:DisableMove] = 0
    # Display message
    @battle.pbDisplay(_INTL("{1} transformed into {2}!", oldname, choice.pbThis(true)))
    # Update ability
    battlerability = battler.ability || battler.backupability
    self.changeAbilityWithEffects(battlerability, box: false, activate: false)
    # Activation via pbAbilitiesOnSwitchIn is done outside of this method
    if self.hasCrest?
      @crested = @species == :ZORUA ? :ZOROARK : @species
    else
      @crested = false
    end
  end

  def pbTrace
    return false unless self.ability == :TRACE
    return false if self.hasWorkingItem(:ABILITYSHIELD)

    choices = (0...4).select { |i|
      next false if !self.pbIsOpposing?(i) || @battle.battlers[i].isFainted?
      battlerability = @battle.battlers[i].ability || @battle.battlers[i].backupability
      next false if battlerability.nil? || (PBStuff::ABILITYBLACKLIST - [:WONDERGUARD, :ORICHALCUMPULSE, :HADRONENGINE]).include?(battlerability)
      next true
    }

    if choices.length == 0
      @effects[:TracePending] = true
      return false
    end

    choice = @battle.sample(choices)
    battler = @battle.battlers[choice]
    battlerability = battler.ability || battler.backupability
    message = _INTL("It traced {1}'s {2}!", battler.pbThis(true), getAbilityName(battlerability))
    self.changeAbilityWithEffects(battlerability, message: message, activate: false)
    # Activation via pbAbilitiesOnSwitchIn is done outside of this method
    @effects[:TracePending] = false
    return true
  end

  def absorbHP(hpgain, opponent, agent, move = nil)
    hpgain = 1 if hpgain <= 0
    bigRootBoost = Rejuv && @battle.FE == :GRASSY ? 1.6 : PBMults::RootOrb
    hpgain = (hpgain * bigRootBoost).round if hasWorkingItem(:BIGROOT)
    hpgain = (hpgain * 1.3).round if self.crested == :SHIINOTIC
    case agent
      when :LeechSeed then hpgain = (hpgain * 1.3).round if Rejuv && @battle.FE == :GRASSY
      when :StrengthSap
        hpgain = (hpgain * 1.3).round if (!Rejuv && @battle.FE == :SWAMP) || @battle.FE == :FOREST
      when :MatchaGotcha then hpgain = (hpgain * 1.3).round if [:SNOWYMOUNTAIN, :ICY].include?(@battle.FE)
      when :AquaRing then hpgain *= 2 if [:MISTY, :SWAMP, :WATERSURFACE, :UNDERWATER].include?(@battle.FE)
      when :Ingrain
        if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 4, 5)
          hpgain *= 4
        elsif @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 3) || @battle.FE == :FOREST || (Rejuv && (@battle.FE == :GRASSY || @battle.OV == :GRASSY))
          hpgain *= 2
        end
    end
    healed = false
    if opponent&.ability == :LIQUIDOOZE
      @battle.pbShowAbilityBox(opponent)
      if !@battle.magicGuardAbilities.include?(self.ability)
        hpgain *= 2 if [:WASTELAND, :MURKWATERSURFACE, :CORRUPTED].include?(@battle.FE)
        pbReduceHP(hpgain, true, message: _INTL("{1} sucked up the liquid ooze!", pbThis))
      end
      @battle.pbHideAbilityBox(opponent)
    elsif self.hp != self.totalhp
      if canHeal?
        message = case agent
          when :StrengthSap then _INTL("{1} had its HP restored.", pbThis)
          when :AquaRing then _INTL("A veil of water restored {1}'s HP!", pbThis(true))
          when :Ingrain then _INTL("{1} absorbed nutrients with its roots!", pbThis)
          when :HPDrainingMove, :MatchaGotcha then _INTL("{1} had its energy drained!", opponent.pbThis)
        end
        pbRecoverHP(hpgain, true, message: message)
        healed = true
      else
        @battle.pbDisplay(_INTL("{1} was prevented from healing!", pbThis))
      end
    end
    if Rejuv && @battle.FE == :SWAMP && [:HPDrainingMove, :MatchaGotcha, :StrengthSap, :LeechSeed].include?(agent) && !opponent.isFainted?
      stat = @battle.sample(PBStats::Omni)
      opponent.pbChangeStats(stat, -1, self, move, abilitycheck: :hide)
    end
    return healed
  end

  def canTriggerUserSwitch? # Used by pivot moves / Emergency Exit / Eject Button / Eject Pack
    return false if self.userSwitch || self.forcedSwitch || self.effects[:Pursuitee]
    return false if !@battle.pbCanChooseNonActive?(self.index)
    return true
  end

  def carryOutUserSwitch(agent = self.userSwitch)
    self.userSwitch, self.forcedSwitch = nil, false

    # Messages and item disposal
    if [:EjectButton, :EjectPack].include?(agent)
      @battle.pbShowAbilityBox(self, item: true)
      @battle.pbCommonAnimation("UseItem", self, nil)
      message = agent == :EjectButton ? _INTL("{1} is switched out with {2}!") : _INTL("{1} is switched out by {2}!")
      @battle.pbDisplay(_INTL(message, self.pbThis, getItemName(self.item, :the)))
      @battle.pbHideAbilityBox(self)
      self.pbDisposeItem(symbiosis: false)
    end

    # Check for Pursuit
    unless [:BatonPass, :ShedTail].include?(agent)
      @battle.pbCheckPursuit(self)
      return if self.isFainted?
    end

    if agent == :BossEffect && self.isbossmon
      self.shieldCount -= 1 if self.shieldCount > 0
      @battle.scene.pbUpdateShield(self.shieldCount, self.index)
    end
    # Switch this battler out
    @battle.pbDisplay(_INTL("{1} went back to {2}!", pbThis, @battle.pbGetOwner(self.index).trainername)) unless [:BatonPass, :ShedTail, :Ability].include?(agent)
    @battle.pbClearChoices(self.index)
    @battle.scene.pbRecall(self.index) unless self.vanished # vanished is set to true for moves whose animations themselves make the battler disappear
    self.vanished = false
    self.leaveField

    # Send another battler in
    switchagent = agent == :BatonPass ? :PivotBaton : :Pivot # For the AI to score switch-ins
    partyindex = @battle.pbSwitchInBetween([self.index], true, false, switchagent)[self.index]
    @battle.pbMessagesOnReplace(self.index, partyindex)
    @battle.pbReplace(self.index, partyindex, agent == :BatonPass)
    @battle.pbApplyEntryEffects(self)
  end

  def carryOutForcedSwitch
    self.userSwitch, self.forcedSwitch = nil, false

    # Switch this battler out
    @battle.pbClearChoices(self.index)
    @battle.scene.pbRecall(self.index) unless self.vanished # vanished is set to true for moves whose animations themselves make the battler disappear
    self.vanished = false
    self.leaveField

    # Send another battler in
    party = @battle.pbPartySingleOwner(self.index)
    choices = []
    for j in 0...party.length
      next if !self.isFainted? && j == self.pokemonIndex
      if @battle.pbGetOwnerIndex(self.index) == @battle.pbGetOwnerIndex(self.pbPartner.index)
        next if !self.pbPartner.isFainted? && j == self.pbPartner.pokemonIndex
      end
      next unless party[j] && !party[j].isEgg? && party[j].hp > 0
      choices.push(j) if @battle.pbCanSwitchLax?(self.index, j)
    end
    newpoke = @battle.sample(choices)
    @battle.pbReplace(self.index, newpoke)
    @battle.pbDisplay(_INTL("{1} was dragged out!", self.pbThis))
    @battle.pbApplyEntryEffects(self)
    self.forcedSwitchEarlier = true
  end

  def canForceSwitchOpponent?(opponent, showMessage: false) # Used by force-out moves / Red Card
    failure = nil
    case true
      when opponent.ability == :SUCTIONCUPS && !opponent.moldbroken then failure = :SuctionCups
      when opponent.ability == :GUARDDOG && !opponent.moldbroken then failure = :GuardDog
      when opponent.effects[:Ingrain] then failure = :Ingrain
      when opponent.isbossmon && opponent.chargeAttack then failure = :BossChargeAttack
      when @battle.FE == :COLOSSEUM then failure = :Colosseum
    end
    unless failure
      if !@battle.opponent
        # Wild battle
        failure = :HighLevel if opponent.level > self.level && !@battle.battlers.any? { |battler| battler.isbossmon } && !@battle.doublebattle
        if @battle.battlers.any? { |battler| battler.isbossmon || battler.issosmon}
          choices = @battle.pbPartySingleOwner(opponent.index).select.with_index { |pkmn, i| @battle.pbCanSwitchLax?(opponent.index, i) }
          failure = :NoPokemon if choices.length == 0
        end
      else
        # Trainer battle
        choices = @battle.pbPartySingleOwner(opponent.index).select.with_index { |pkmn, i| @battle.pbCanSwitchLax?(opponent.index, i) }
        failure = :NoPokemon if choices.length == 0
      end
    end
    return true unless failure

    if showMessage
      case failure
        when :SuctionCups then @battle.pbAbilityBoxAndDisplay(opponent, _INTL("{1} is anchored in place with its suction cups!", opponent.pbThis))
        when :GuardDog then @battle.pbDisplay(_INTL("But it failed!")) # No canon ability pop-up here.
        when :Ingrain then @battle.pbDisplay(_INTL("{1} is anchored in place with its roots!", opponent.pbThis))
        when :BossChargeAttack then @battle.pbDisplay(_INTL("{1} is immovable!", opponent.pbThis))
        when :HighLevel, :NoPokemon then @battle.pbDisplay(_INTL("But it failed!"))
        when :Colosseum then @battle.pbDisplay(_INTL("{1} is standing their ground!", opponent.pbThis))
      end
    end
    return false
  end

  def applyGravity
    if $cache.moves[@effects[:TwoTurnAttack]] && [0xC9, 0xCC, 0xCE].include?($cache.moves[@effects[:TwoTurnAttack]].function) # Fly, Bounce, Sky Drop
      @battle.scene.pbUnVanishSprite(self)
      @effects[:TwoTurnAttack] = 0
      @effects[:SkyDroppee] = nil if @effects[:SkyDroppee]
      @battle.pbDisplay(_INTL("{1} fell from the sky due to the gravity!", pbThis))
    end
    if @effects[:SkyDrop]
      @battle.scene.pbUnVanishSprite(self)
      @effects[:SkyDrop] = false
      @battle.pbDisplay(_INTL("{1} was freed from the {2}!", pbThis, getMoveName(:SKYDROP)))
    end
    @effects[:MagnetRise] = 0 if @effects[:MagnetRise] > 0
    @effects[:Telekinesis] = 0 if @effects[:Telekinesis] > 0
  end

  def takesWeatherDamage?(weather = nil)
    weather = @battle.pbWeather(nil) if weather.nil?
    return false if ![:HAIL, :SANDSTORM, :SHADOWSKY].include?(weather)
    return false if @battle.magicGuardAbilities.include?(self.ability)
    return true if weather == :SANDSTORM && self.effects[:DesertsMark] # Desert's Mark sand immunity negation (Magic Guard is exempted)
    return false if self.hasWorkingItem(:SAFETYGOGGLES)
    return false if self.effects[:WeatherProtection]
    return false if [:OVERCOAT, :TEMPEST].include?(self.ability)
    return false if weather == :HAIL && (self.hasType?(:ICE) || [:ICEBODY, :SNOWCLOAK, :SLUSHRUSH, :LUNARIDOL].include?(self.ability) || self.crested == :EMPOLEON || (self.crested == :CASTFORM && self.form == 3))
    return false if weather == :SANDSTORM && (self.hasType?(:ROCK) || self.hasType?(:GROUND) || self.hasType?(:STEEL) || [:SANDVEIL, :SANDRUSH, :SANDFORCE].include?(self.ability))
    return false if weather == :SHADOWSKY && self.isShadow?
    return true
  end

  def powderImmune?
    return self.hasType?(:GRASS) || self.ability == :OVERCOAT || self.hasWorkingItem(:SAFETYGOGGLES)
  end

  def hydrationActive?
    if self.ability == :HYDRATION
      return true if @battle.FE == :UNDERWATER
      return true if @battle.FE == :WATERSURFACE && !self.isAirborne?
      return true if @battle.pbWeather(nil) == :RAINDANCE && !self.hasWorkingItem(:UTILITYUMBRELLA)
    end
    return true if self.ability == :WATERVEIL && [:WATERSURFACE, :UNDERWATER].include?(@battle.FE)
    return true if self.ability == :NATURALCURE && @battle.FE == :BEWITCHED
    return false
  end

  def leafGuardActive?
    return false if self.ability != :LEAFGUARD
    return true if self.crested == :LEAFEON
    # Opponent's Leaf Guard does in fact not get activated when attacker has Mega Sol
    return true if @battle.pbWeather(nil) == :SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)
    return true if [:FOREST].include?(@battle.FE)
    return true if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5)
    return true if Rejuv && (@battle.FE == :GRASSY || @battle.OV == :GRASSY)
    return false
  end

  def flowerGiftActive?
    return false if self.ability != :FLOWERGIFT
    return true if self.crested == :CHERRIM
    return true if @battle.pbWeather(nil) == :SUNNYDAY && !self.hasWorkingItem(:UTILITYUMBRELLA)
    return true if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN)
    return true if @battle.FE == :BEWITCHED
    return false
  end

  def galeWingsActive?
    return false if self.ability != :GALEWINGS
    return true if self.hp == self.totalhp
    return true if @battle.FE == :SKY
    return true if [:MOUNTAIN, :SNOWYMOUNTAIN, :VOLCANICTOP].include?(@battle.FE) && @battle.pbWeather(nil) == :STRONGWINDS
    return false
  end

  def chlorophyllActive?
    return false if self.ability != :CHLOROPHYLL
    return true if self.crested == :LEAFEON
    return true if self.crested == :SUNFLORA
    return true if @battle.pbWeather(nil) == :SUNNYDAY && !self.hasWorkingItem(:UTILITYUMBRELLA)
    return true if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 4, 5)
    return false
  end

  def swiftSwimActive?
    return false if self.ability != :SWIFTSWIM
    return true if @battle.pbWeather(nil) == :RAINDANCE && !self.hasWorkingItem(:UTILITYUMBRELLA)
    return true if @battle.FE == :UNDERWATER
    return true if [:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE) && !self.isAirborne?
    return false
  end

  def sandRushActive?
    return false if self.ability != :SANDRUSH
    return true if @battle.pbWeather(nil) == :SANDSTORM
    return true if [:DESERT, :ASHENBEACH].include?(@battle.FE)
    return false
  end

  def slushRushActive?
    return false if self.ability != :SLUSHRUSH && self.crested != :EMPOLEON && !(self.crested == :CASTFORM && self.form == 3)
    return true if [:HAIL, :SNOW].include?(@battle.pbWeather(nil))
    return true if [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION].include?(@battle.FE)
    return false
  end

  def surgeSurferActive?
    return false if self.ability != :SURGESURFER
    return true if [:ELECTERRAIN, :SHORTCIRCUIT].include?(@battle.FE)
    return true if [:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE) && !self.isAirborne?
    return true if @battle.OV == :ELECTERRAIN
    return false
  end

  def telepathyActive?
    return false if self.ability != :TELEPATHY
    return true if @battle.FE == :PSYTERRAIN
    #return true if @battle.OV == :PSYTERRAIN
    return false
  end

  def quickFeetActive?
    return false if self.ability != :QUICKFEET
    return true if !self.status.nil?
    return true if Rejuv && @battle.FE == :ELECTERRAIN
    return false
  end

  def evioliteActive?
    return false unless self.itemWorks?
    species, form = self.pokemon.species, self.pokemon.form # Eviolite uses transformed pokemon's original species/form
    return true if self.item == :EVIOLITE && !pbGetEvolvedFormData(species, form).nil?
    return true if self.item == :EVIOLITE && self.getCacheData.checkFlag?(:canUseEviolite)
    return true if species == :PIKACHU && [:LIGHTBALL, :PIKANIUMZ].include?(self.item)
    return false
  end

  def getHighestRawStat
    stats = [@attack, @defense, @spatk, @spdef, @speed]
    # If multiple stats are tied for highest, they are prioritized in this order
    return stats.index(stats.max) + 1
  end

  def getHighestStatWithStages
    attack = (@attack * PBStats::StageMul[@stages[PBStats::ATTACK] + 6]).floor
    defense = (@defense * PBStats::StageMul[@stages[PBStats::DEFENSE] + 6]).floor
    spatk = (@spatk * PBStats::StageMul[@stages[PBStats::SPATK] + 6]).floor
    spdef = (@spdef * PBStats::StageMul[@stages[PBStats::SPDEF] + 6]).floor
    speed = (@speed * PBStats::StageMul[@stages[PBStats::SPEED] + 6]).floor
    stats = [attack, defense, spatk, spdef, speed]
    # If multiple stats are tied for highest, they are prioritized in this order
    return stats.index(stats.max) + 1
  end

  def pbAddStockpile(move)
    self.effects[:Stockpile] += 1
    @battle.pbDisplay(_INTL("{1} stockpiled {2}!", self.pbThis, self.effects[:Stockpile]))
    self.pbChangeStats(PBStats::Defensive, 1, self, move, abilitycheck: :hide, counter: :Stockpile)
  end

  def pbRemoveStockpile(move)
    stats, amounts = [], []
    if self.effects[:StockpileDef] > 0
      stats.push(PBStats::DEFENSE)
      amounts.push(-self.effects[:StockpileDef])
    end
    if self.effects[:StockpileSpDef] > 0
      stats.push(PBStats::SPDEF)
      amounts.push(-self.effects[:StockpileSpDef])
    end
    self.pbChangeStats(stats, amounts, self, move, abilitycheck: :hide)
    self.effects[:Stockpile] = 0
    self.effects[:StockpileDef] = 0
    self.effects[:StockpileSpDef] = 0
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!", self.pbThis))
  end

  def spinAwayEffects
    if self.effects[:MultiTurn] > 0
      mtattack = getMoveName(self.effects[:MultiTurnAttack])
      @battle.pbDisplay(_INTL("{1} was freed from {2}!", self.pbThis, mtattack))
      self.effects[:MultiTurn] = 0
      self.effects[:MultiTurnAttack] = 0
      self.effects[:MultiTurnUser] = -1
    end
    if self.effects[:LeechSeed] >= 0
      self.effects[:LeechSeed] = -1
      @battle.pbDisplay(_INTL("{1} was freed from {2}!", self.pbThis, getMoveName(:LEECHSEED)))
    end
    self.pbOwnSide.spinAwayHazards
  end
end

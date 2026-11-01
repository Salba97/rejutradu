# Blessing handling for Xen Tower
class BlessingTables
  TypeBoost = [
    0.10,
    0.15,
    0.25
  ]
  SwitchBoost = [
    0.35,
    0.60,
    0.85
  ]
  Statuses = {
    :SLEEP => _INTL("Sleep"),
    :FREEZE => _INTL("Freeze"),
    :BURN => _INTL("Burn"),
    :PARALYSIS => _INTL("Paralysis"),
    :POISON => _INTL("Poison"),
    :TOXIC => _INTL("Toxic"),
    :CONFUSION => _INTL("Confusion"),
    :PETRIFIED => _INTL("Petrification"),
    :PERISHSONG => _INTL("Perish Song"),
    :CURSE => _INTL("Curse"),
    :VENGEFULHEX => _INTL("Vengeful Hex")
  }
  DefaultDataValues = {
    amount: 0.10,
    healAmount: 0.05,
    turns: 1,
    boostChance: 0.10,
    bonusChance: 0,
    bonusCrit: 1,
    statusChance: 0.10,
    bonusBoost: 1,
    damage: 0.10,
    hitBonus: 0,
    hitChance: 0.10,
    bonusHits: 1,
    damageReduction: 0.25,
    bonusProcChance: 0,
    bonusProcHits: 1,
  }
end

def getPlayerBlessings
  return {} if !xenTowerInProgress
  return $PokemonGlobal.xenTower.blessings
end

def getBlessingRank(blessing)
  return 0 if !xenTowerInProgress
  return $PokemonGlobal.xenTower.blessings[blessing] || 0
end

def addBlessing(blessing, amount = 1)
  return false if !xenTowerInProgress || getBlessingRank(blessing) >= $cache.blessings[blessing].maxRank
  $PokemonGlobal.xenTower.blessings[blessing] = [getBlessingRank(blessing) + amount, $cache.blessings[blessing].maxRank].min
end

def removeBlessing(blessing, amount = 1)
  return false if !xenTowerInProgress || getBlessingRank(blessing) <= 0
  $PokemonGlobal.xenTower.blessings[blessing] = [getBlessingRank(blessing) - amount, 0].min
end

def getBlessingName(blessing)
  return "" if $cache.blessings[blessing].nil?

  return pbGetMessageFromHash(:BlessingNames, $cache.blessings[blessing].name)
end

def getBlessingDesc(blessing, rank = 1, extended = true)
  return "" if $cache.blessings[blessing].nil?

  return $cache.blessings[blessing].getDesc(rank, extended)
end

def getBlessingRules(blessing)
  return "" if $cache.blessings[blessing].nil?
  return $cache.blessings[blessing].getRules
end

def getBlessingMessage(blessing)
  return "" if $cache.blessings[blessing].nil?

  return pbGetMessageFromHash(:BlessingMessages, $cache.blessings[blessing].message)
end

class PokeBattle_Battle
  attr_accessor :blessings

  unless @blessingAliases
    alias __blessings_battleInit initialize
    alias __blessings_endRound pbEndOfRoundPhase
    @blessingAliases = true
  end

  def initialize(*args)
    __blessings_battleInit(*args)
    blessingsInit()
  end

  def blessingsInit
    @blessings = [
      @player.is_a?(Array) ? [{}] * @player.length : [{}],
      @opponent.is_a?(Array) ? [{}] * @opponent.length : [{}],
    ]
    #return if !xenTowerInProgress
    getPlayerBlessings.each { |blessing, rank|
      @blessings[0][0].store(blessing, rank)
    }
    # INSERT CUSTOM TRAINER BLESSINGS HERE
  end

  def hasBlessings?(index)
    #return false if !xenTowerInProgress
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    return !@blessings[side][owner].empty?
  end

  def getBlessings(index)
    #return false if !xenTowerInProgress
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    return @blessings[side][owner]
  end

  def pbEndOfRoundPhase(skipcelebi = false)

    # Vengeful Hex
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:VengefulHex].nil?

      if !magicGuardAbilities.include?(i.ability)
        pbCommonAnimation("Curse", i, nil)
        i.pbReduceHP((i.totalhp * i.effects[:VengefulHex]).floor, true, message: _INTL("{1} is afflicted by the hex!", i.pbThis))
      end
      i.pbFaint if i.isFainted?
    end
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      if i.turncount > 0
        i.endOfTurnBlessings
      end
    end
    __blessings_endRound(skipcelebi)
  end
end

class PokeBattle_Battler
  unless @blessingAliases
    alias __blessings_resolveMoveEffects pbResolveMoveEffects
    alias __blessings_endTurn pbEndTurn
    alias __blessings_onSwitchIn pbAbilitiesOnSwitchIn
    alias __blessings_tryUseMove pbTryUseMove
    alias __blessings_getHitNum pbGetHitNumber
    alias __blessings_itemHP pbPassiveItemHP
    @blessingAliases = true
  end

  OtherEff = OtherEff + [:VengefulHex]
  BatonEff = BatonEff + [:VengefulHex]

  def checkBlessing(blessing)
    return @battle.getBlessings(@index).dig(blessing)
  end

  def hasBlessings?
    return @battle.hasBlessings?(@index)
  end

  def getBlessings
    return @battle.getBlessings(@index)
  end

  def endOfTurnBlessings
    blessings = self.getBlessings
    blessings.each { |blessing, rank|
      blessingData = $cache.blessings[blessing]
      if blessingData.checkFlag?(:endOfTurnStatBoost)
        chance = blessingData.getValue(:bonusChance, rank)
        if @battle.pbRandom < chance
          stats = blessingData.getValue(:stats, rank)
          amount = 1

          @battle.pbShowAbilityBox(self, attrname: getBlessingName(blessing))
          self.pbChangeStats(stats, amount, self, nil)
          @battle.pbHideAbilityBox(self)
        end
      end
    }
  end

  def pbPassiveItemHP
    __blessings_itemHP
    return if self.isFainted?

    blessings = self.getBlessings
    blessings.each { |blessing, rank|
      blessingData = $cache.blessings[blessing]
      if blessingData.checkFlag?(:passiveHP)
        if blessing == :HERBALBATH && self.hp < self.totalhp
          turns = blessingData.getValue(:turns, rank)
          if self.turncount % turns == 0
            healAmount = blessingData.getValue(:healAmount, rank)
            @battle.pbShowAbilityBox(self, attrname: getBlessingName(blessing))
            pbRecoverHP((self.totalhp * healAmount).floor, true)
            @battle.pbDisplay(_INTL("{1} was rejuvenated by the {2}!", self.pbThis, getBlessingName(blessing)))
            @battle.pbHideAbilityBox(self)
          end
        end
      end
    }
  end

  def pbAbilitiesOnSwitchIn(applySwitchInAbility: false)
    return if self.isFainted?
    if self.hasBlessings? && self.applyingEntryEffects
      blessings = self.getBlessings
      blessings.each { |blessing, rank|
        blessingData = $cache.blessings[blessing]
        if blessingData.checkFlag?(:entryEffect)
          chance = blessingData.getValue(:boostChance, rank)
          if @battle.pbRandom < chance
            stats = blessingData.getValue(:stats, rank)
            amount = 1

            chance = blessingData.getValue(:bonusChance, rank)
            amount = blessingData.getValue(:bonusBoost, rank, amount) if @battle.pbRandom < chance

            @battle.pbShowAbilityBox(self, attrname: getBlessingName(blessing))
            self.pbChangeStats(stats, amount, self, nil)
            @battle.pbHideAbilityBox(self)
          end
        end
      }
    end
    __blessings_onSwitchIn(applySwitchInAbility: applySwitchInAbility)
  end

  def pbResolveMoveEffects(user, basemove, targets, calcdamage, hitflag, hitcount, flags = { totaldamage: 0, UserFaintCause: [] })
    __blessings_resolveMoveEffects(user, basemove, targets, calcdamage, hitflag, hitcount, flags)
    if @battle.hasBlessings?(user.index)
      targetQueue = Hash.new { |h, k| h[k] = [] }
      hpLoss = 0
      blessings = @battle.getBlessings(user.index)
      moveEffectBlessings = []
      blessings.each { |blessing, rank|
        blessingData = $cache.blessings[blessing]
        moveEffectBlessings.push([blessing, rank]) if blessingData.checkFlag?(:moveStatusEffect)
      }

      targets.each_with_index { |target, i|
        next if target.hp <= 0
        if hitflag[i] == :Success
          # if user.checkBlessing(:VENGEFULHEX) && basemove.move != :VENGEFULHEX
          #   blessing = :VENGEFULHEX
          #   blessingData = $cache.blessings[blessing]
          #   rank = user.checkBlessing(blessing)
          #   healthCost = blessingData.getValue(:healthCost, rank)
          #   targets.each { |target|
          #     next if user.hp - hpLoss <= (user.totalhp * healthCost)
          #     next if target.effects[:FutureSight] != 0
          #     next if @battle.pbRandom < blessingData.getValue(:hexChance, rank)

          #     target.effects[:FutureSight] = 3
          #     target.effects[:FutureSightMove] = :FutureVengefulHex
          #     target.effects[:FutureSightUserIndex] = user.index
          #     target.effects[:FutureSightPokemon] = user.pokemon
          #     targetQueue[blessing].push(target.pbThis(true))
          #     hpLoss += (user.totalhp * healthCost)
          #   }
          # end

          moveEffectBlessings.each { |blessing|
            tryMoveEffectBlessing(blessing[0], blessing[1], user, target, basemove)
          }
        end
      }
      # if !targetQueue.empty?
      #   targetQueue.each { |blessing, targets|
      #     @battle.pbShowAbilityBox(user, attrname: getBlessingName(blessing))
      #     pbReduceHP(hpLoss, true)
      #     targets.each { |target|
      #       @battle.pbDisplay(_INTL("{1} casts a hex on {2}!", user.pbThis, target))
      #     }
      #     @battle.pbHideAbilityBox(user)
      #   }
      # end
    end
  end

  def tryMoveEffectBlessing(blessing, rank, user, target, basemove)

    blessingData = $cache.blessings[blessing]
    status = blessingData.getValue(:status, rank)
    status = @battle.sample(status) if status.is_a?(Array)
    return false if !target.pbCanApplySelectStatus?(status, user, basemove)

    moveType = blessingData.getValue(:type, rank)
    moveType = [moveType].compact if !moveType.is_a?(Array)
    return false if !moveType.empty? && !moveType.include?(basemove.type)

    chance = blessingData.getValue(:statusChance, rank)
    return false if @battle.pbRandom < chance

    damage = blessingData.getValue(:damage, rank)
    @battle.pbShowAbilityBox(user, attrname: getBlessingName(blessing))
    target.pbApplySelectStatus(status, user, damage: damage)
    @battle.pbHideAbilityBox(user)
    return true
  end

  alias __core_pbCanApplySelectStatus? pbCanApplySelectStatus? unless method_defined?(:__core_pbCanApplySelectStatus?)
  def pbCanApplySelectStatus?(status, user, basemove, ignorestatus: false, showMessage: false)
    case status
      when :PERISHSONG
        return self.effects[:PerishSong] <= 0
      when :CURSE
        return self.effects[:Curse] != true
      when :VENGEFULHEX
        return self.effects[:VengefulHex].nil?
      else
        return __core_pbCanApplySelectStatus?(status, user, basemove, ignorestatus: ignorestatus, showMessage: showMessage)
    end
  end

  alias __core_pbApplySelectStatus pbApplySelectStatus unless method_defined?(:__core_pbApplySelectStatus)
  def pbApplySelectStatus(status, user, damage: 0, duration: nil, message: nil, volatile: true)
    case status
      when :PERISHSONG
        if volatile
          self.effects[:PerishSong] = 4
          self.effects[:PerishSongUser] = user.index
          if user.effects[:PerishSong] == 0
            user.effects[:PerishSong] = 4
            user.effects[:PerishSongUser] = user.index
          end
        end
      when :CURSE
        if volatile
          self.effects[:Curse] = true
          @battle.pbDisplay(_INTL("{1} put a curse on {2}!", user.pbThis, self.pbThis(true)))
        end
      when :VENGEFULHEX
        if volatile
          self.effects[:VengefulHex] = damage
          @battle.pbDisplay(_INTL("{1} put a hex on {2}!", user.pbThis, self.pbThis(true)))
        end
      else
        __core_pbApplySelectStatus(status, user, duration: duration, message: message, volatile: volatile)
    end
  end

  def pbTryUseMove(choice, basemove, flags = { passedtrying: false, instructed: false })
    isConfused = @effects[:Confusion] > 1
    ret = __blessings_tryUseMove(choice, basemove, flags)

    battlers = []
    differentOwners = @battle.pbGetOwner(self.pbOpposing1.index) != @battle.pbGetOwner(self.pbOpposing2.index)
    battlers.push(self.pbOpposing1) if @battle.hasBlessings?(self.pbOpposing1.index)
    battlers.push(self.pbOpposing2) if differentOwners && @battle.hasBlessings?(self.pbOpposing2.index)
    return ret if battlers.empty?

    battlers.each { |battler|
      blessings = @battle.getBlessings(battler.index)
      if ret == true && blessings[:BEWILDERINGDUO] && isConfused
        blessingData = $cache.blessings[:BEWILDERINGDUO]
        hitBonus = blessingData.getValue(:hitBonus, blessings[:BEWILDERINGDUO])

        if @battle.pbRandom < hitBonus
          @battle.pbDisplay(_INTL("It hurt itself in its confusion!"))
          pbConfusionDamage
          if self.isbossmon && self.chargeAttack
            self.chargeAttack[:canIntermediateAttack] = false
          end
          return false
        end
      end
      if ret == false && blessings[:TWOFORFLINCHING]
        if @effects[:Flinch]
          blessing = :TWOFORFLINCHING
          blessingData = $cache.blessings[blessing]

          rank = battler.checkBlessing(blessing)
          @battle.pbShowAbilityBox(battler, attrname: getBlessingName(blessing))
          @battle.pbDisplay(_INTL("{1} was blind-sided!", pbThis))
          hpMod = blessingData.getValue(:damage, rank)
          damage = [1, (self.totalhp * hpMod).floor].max
          if damage > 0
            self.pbReduceHP(damage, true)
            if self.isFainted?
              self.pbFaint
              return false
            end
          end
          @battle.pbHideAbilityBox(battler)
        end
      end
    }

    return ret
  end

  def pbGetHitNumber(basemove, norandomness: false)
    self.effects[:SurgingBlessing] = 0
    hitnum = __blessings_getHitNum(basemove, norandomness: norandomness)
    surgingFailCases = basemove.pbIsStatus? || basemove.zmove ||
      [0x70, 0x0E1, 0x0E0, 0x0D3, 0x0F7, 0x06E, 0x0C1].include?(basemove.function) ||
      (PBStuff::TWOTURNMOVE).include?(basemove.move) && self.effects[:TwoTurnAttack] != 0 # multi turn moves are allowed to be modified by blessings
    # Surging Strikes is allowed to modify: Uproar, Ledian Crest, Typh Crest, Cinc Crest, Parental Bond, Multihits, Spread Moves.

    if self.hasBlessings?
      surgingStrikes = self.checkBlessing(:SURGINGSTRIKES)
      if surgingStrikes && !surgingFailCases
        self.effects[:SurgingBlessing] = hitnum
        self.effects[:SurgingBlessing] -= 1 if basemove.pbNumHits(self) == 1 && (self.effects[:ParentalBond] || self.effects[:TyphBond])
        blessingData = $cache.blessings[:SURGINGSTRIKES]
        rank = surgingStrikes

        hitChance = blessingData.getValue(:hitChance, rank)
        hitChance = 0 if hitChance < 1 && norandomness
        if @battle.pbRandom < hitChance
          bonusHits = blessingData.getValue(:bonusHits, rank)
          hitnum += bonusHits

          bonusProcChance = blessingData.getValue(:bonusProcChance, rank)
          bonusProcChance = 0 if bonusProcChance < 1 && norandomness
          if @battle.pbRandom < bonusProcChance
            bonusProcHits = blessingData.getValue(:bonusProcHits, rank)
            hitnum += bonusProcHits
          end
        end
      end
    end
    return hitnum
  end
end

class PokeBattle_Move
  unless @blessingAliases
    alias __blessings_modifySTAB pbModifySTAB
    alias __blessings_critRate pbCritRate?
    @blessingAliases = true
  end

  def pbModifySTAB(stabmult, type, attacker, opponent)
    stabmult = __blessings_modifySTAB(stabmult, type, attacker, opponent)
    if attacker.hasBlessings?
      blessings = attacker.getBlessings
      blessings.each { |blessing, rank|
        blessingData = $cache.blessings[blessing]
        if blessingData.checkFlag?(:typeBoost)
          moveType = blessingData.getValue(:type, rank)
          moveType = [moveType].compact if !moveType.is_a?(Array)
          stabmult *= (1 + blessingData.getValue(:amount, rank)) if moveType.include?(type)
        end
      }
    end
    return stabmult
  end

  def pbCritRate?(attacker, opponent, moldbroken = opponent.moldbroken)
    c = __blessings_critRate(attacker, opponent, moldbroken)
    if attacker.hasBlessings?
      blessings = attacker.getBlessings
      blessings.each { |blessing, rank|
        blessingData = $cache.blessings[blessing]
        if blessingData.checkFlag?(:modifyCritRate)
          moveType = blessingData.getValue(:type, rank)
          moveType = [moveType].compact if !moveType.is_a?(Array)
          next if !moveType.empty? && !moveType.include?(self.pbType(attacker))

          bonusCrit = blessingData.getValue(:bonusCrit, rank)
          c += bonusCrit
        end
      }
    end

    c = 3 if c > 3
    return c
  end
end

class PokeBattle_AI
  alias __blessings_modifySTAB pbModifySTAB unless method_defined?(:__blessings_modifySTAB)
  def pbModifySTAB(stabmult, type, attacker, opponent)
    stabmult = __blessings_modifySTAB(stabmult, type, attacker, opponent)
    if attacker.hasBlessings?
      blessings = attacker.getBlessings
      blessings.each { |blessing, rank|
        blessingData = $cache.blessings[blessing]
        if blessingData.checkFlag?(:typeBoost)
          moveType = blessingData.getValue(:type, rank)
          moveType = [moveType].compact if !moveType.is_a?(Array)
          stabmult *= (1 + blessingData.getValue(:amount, rank)) if moveType.include?(type)
        end
      }
    end
    return stabmult
  end
end

class PokeBattle_Pokemon
  attr_accessor :heartgauge
  attr_accessor :shadow
  attr_accessor :hypermode
  attr_accessor :savedev
  attr_accessor :savedexp
  attr_accessor :shadowmoves
  attr_accessor :shadowmovenum

  HEARTGAUGESIZE = 3840

  def hypermode
    return (self.heartgauge == 0 || self.hp == 0) ? false : @hypermode
  end

  def shadow
    @shadow = false if !@shadow
    return @shadow
  end

  def heartgauge
    @heartgauge = 0 if !@heartgauge
    return @heartgauge
  end

  def heartStage()
    return 0 if !@shadow

    hg = HEARTGAUGESIZE / 5.0
    return ([self.heartgauge, HEARTGAUGESIZE].min / hg).ceil
  end

  def adjustHeart(value)
    if @shadow
      @heartgauge = 0 if !@heartgauge
      @heartgauge += value
      @heartgauge = HEARTGAUGESIZE if @heartgauge > HEARTGAUGESIZE
      @heartgauge = 0 if @heartgauge < 0
    end
  end

  def getHeartGaugeBarLevel(maxgauge)
    return self.heartgauge == 0 ? 0 : [self.heartgauge * maxgauge / HEARTGAUGESIZE, 2].max.to_grid
  end

  def getHeartGaugeBarTextTTS
    if self.heartgauge == 0
      return _INTL("Empty, ready to purify")
    else
      return _INTL("{1} bars remaining, {2}% left", self.heartStage, self.heartgauge * 100 / HEARTGAUGESIZE)
    end
  end

  def isShadow?
    return self.heartgauge >= 0 && self.shadow
  end

  def makeFakeShadow
    self.shadow = true
    self.heartgauge = 1
  end

  def unmakeFakeShadow
    self.shadow = false
    self.heartgauge = 0
  end

  def makeShadow
    self.shadow = true
    self.heartgauge = HEARTGAUGESIZE
    self.savedexp = 0
    self.savedev = [0, 0, 0, 0, 0, 0]
    self.shadowmoves = [0, 0, 0, 0, 0, 0, 0, 0]
    # Retrieve shadow moves
    shadowMoveList = self.getCacheData(useOriginalForm: true).shadowmoves
    if shadowMoveList
      for i in 0...4
        self.shadowmoves[i] = 0
        self.shadowmoves[i] = shadowMoveList[i] if shadowMoveList[i]
      end
      self.shadowmovenum = shadowMoveList.length
    else
      # No special shadow moves
      self.shadowmoves[0] = :SHADOWRUSH
      self.shadowmovenum = 1
    end
    for i in 0...4 # Save old moves
      next if self.moves[i].nil?

      self.shadowmoves[4 + i] = self.moves[i].move
    end
    pbUpdateShadowMoves
  end

  def pbUpdateShadowMoves(allmoves = false)
    if @shadowmoves
      m = @shadowmoves
      if !@shadow
        # No shadow moves
        pbReplaceMoves(self, m[4], m[5], m[6], m[7])
        @shadowmoves = nil
      else
        moves = []
        relearning = [3, 3, 2, 1, 1, 0][heartStage]
        relearning = 3 if allmoves
        relearned = 0
        # Add all Shadow moves
        for i in 0...4; moves.push(m[i]) if m[i] != 0; end
        # Add X regular moves
        for i in 0...4
          next if i < @shadowmovenum

          if m[i + 4] != 0 && relearned < relearning
            moves.push(m[i + 4]); relearned += 1
          end
        end
        pbReplaceMoves(self, moves[0] || 0, moves[1] || 0, moves[2] || 0, moves[3] || 0)
      end
    end
  end

  alias :__shadow_expeq :exp= unless method_defined?(:__shadow_expeq)

  def exp=(value)
    if self.isShadow?
      @savedexp += value - self.exp
    else
      __shadow_expeq(value)
    end
  end

  alias :__shadow_hpeq :hp= unless method_defined?(:__shadow_hpeq)

  def hp=(value)
    __shadow_hpeq(value)
    @hypermode = false if value <= 0
  end
end

class PokeBattle_Battle
  alias __shadow_pbUseItemOnPokemon pbUseItemOnPokemon unless method_defined?(:__shadow_pbUseItemOnPokemon)

  def pbUseItemOnPokemon(item, pkmnIndex, userPkmn, scene, *arg)
    pokemon = self.party1[pbGetOwnerIndex(userPkmn.index)][pkmnIndex]
    if pokemon.hypermode && ![:JOYSCENT, :EXCITESCENT, :VIVIDSCENT].include?(item)
      scene.pbDisplay(_INTL("{1} is in Hyper Mode. It won't take an item.", pokemon.name))
      return false
    end
    return __shadow_pbUseItemOnPokemon(item, pkmnIndex, userPkmn, scene, *arg)
  end
end

class PokeBattle_Battler
  alias __shadow_pbInitPokemon pbInitPokemon unless method_defined?(:__shadow_pbInitPokemon)

  def pbInitPokemon(*arg)
    if self.pokemonIndex > 0 && self.inHyperMode? && !isFainted?
      # Called out of hypermode
      self.pokemon.hypermode = false
      self.pokemon.adjustHeart(-50)
    end
    __shadow_pbInitPokemon(*arg)
    # Called into battle
    if self.isShadow?
      self.pokemon.adjustHeart(-30) if @battle.pbOwnedByPlayer?(@index)
    end
  end

  alias __shadow_pbEndTurn pbEndTurn unless method_defined?(:__shadow_pbEndTurn)

  def pbEndTurn(*arg)
    __shadow_pbEndTurn(*arg)
    if self.inHyperMode? && !@battle.pbAnySideAllFainted?
      self.battle.pbDisplay(_INTL("{1} is in Hyper Mode!\nIt attacked itself!", self.pbThis))
      self.battle.scene.pbDamageAnimation(self, 0, quick: true)
      self.battle.pbReduceBattlersHP([self], [self.totalhp / 16.0])
    end
  end

  def isShadow?
    p = self.pokemon
    if p && p.respond_to?("heartgauge") && p.heartgauge > 0
      return true
    end

    return false
  end

  def inHyperMode?
    return false if isFainted?

    p = self.pokemon
    if p && p.respond_to?("hypermode") && p.hypermode
      return true
    end

    return false
  end

  def pbHyperMode
    p = self.pokemon
    if p.isShadow? && !p.hypermode
      if @battle.pbRandom(100) < PBStuff::HYPERMODECHANCES[p.nature][p.heartStage()]
        p.hypermode = true
        @battle.pbDisplay(_INTL("{1}'s emotions rose to a fever pitch!\nIt entered Hyper Mode!", self.pbThis))
      end
    end
  end

  def pbHyperModeObedience?(move)
    return false if !move
    if self.inHyperMode? && move.type != :SHADOW
      return @battle.pbRandom(10) >= 2
    end

    return false
  end
end

################################################################################
# Decreases the target's evasion by 2 stages.
# Shadow Mist
################################################################################
class PokeBattle_Move_12C < PokeBattle_Move
  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return opponent.pbCanReduceStatStage?(PBStats::EVASION, attacker, self, showMessage: showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbChangeStats(PBStats::EVASION, -2, attacker, self)
  end
end

################################################################################
# Two turn attack.  On first turn, halves the HP of all active Pokémon.
# Skips second turn (if successful).
# Shadow Half
################################################################################
class PokeBattle_Move_12E < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    successproc = proc { |attacker, opponent| opponent.hp > 1 }
    return pbCheckFailureAndDisplaySingleMessage(successproc, attacker, opponent, showMessage)
  end

  def pbEffectTarget(attacker, opponent, hitnum = 0, alltargets = nil)
    opponent.pbReduceHP((opponent.hp / 2.0).floor)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    attacker.effects[:HyperBeam] = 2
    attacker.currentMove = @move
  end
end

################################################################################
# User takes recoil damage equal to its current HP multiplied by the recoil
# multiplier move attribute.
# Shadow End
################################################################################
class PokeBattle_Move_130 < PokeBattle_Move
  def getRecoil(attacker, damage, recoilmult, hitflags)
    return 0 unless hitflags.include?(:Success)
    return 0 if @battle.magicGuardAbilities.include?(attacker.ability)
    return (attacker.hp * recoilmult).round
  end
end

################################################################################
# Starts shadow weather.
# Shadow Sky
################################################################################
class PokeBattle_Move_131 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    return @battle.canSetWeather?(:SHADOWSKY, showMessage: showMessage)
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    duration = @battle.FE == :SKY ? 8 : 5
    duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
    @battle.pbSetWeather(:SHADOWSKY, duration)
  end
end

################################################################################
# Ends the effects of Light Screen, Reflect and Safeguard on both sides.
# Shadow Shed
################################################################################
class PokeBattle_Move_132 < PokeBattle_Move
  def pbEffectValid(attacker, opponent, showMessage = false)
    if [:Reflect, :LightScreen, :AuroraVeil, :AreniteWall, :Safeguard].none? { |effect| attacker.pbOpposingSide.effects[effect] > 0 }
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def pbEffect(attacker, alltargets, hitnum = 0)
    @battle.pbEndSideEffects(@battle.sides, [*PBStuff::SCREENEFFECTS.values, :Safeguard])
  end
end

class PBStuff
  HYPERMODECHANCES = pbHashForwardizer({
    [25, 50, 70, 70, 70, 30] => [:ADAMANT, :BASHFUL, :HARDY, :RELAXED],
    [5, 10, 15, 20, 25, 30] => [:CALM, :LONELY, :MODEST, :TIMID],
    [5, 10, 20, 30, 40, 50] => [:BOLD, :BRAVE, :LAX, :QUIRKY, :SASSY],
    [12, 25, 30, 40, 40, 50] => [:HASTY, :IMPISH, :NAUGHTY, :RASH],
    [5, 10, 15, 15, 20, 20] => [:CAREFUL, :DOCILE, :QUIET, :SERIOUS],
    [50, 50, 50, 50, 50, 50] => [:GENTLE, :JOLLY, :MILD, :NAIVE],
  })
end

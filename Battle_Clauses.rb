#===============================================================================
# This script modifies the battle system to implement battle rules.
#===============================================================================

class PokeBattle_Battle
  unless @battleClausesAliases
    alias __clauses__pbDecisionOnDraw pbDecisionOnDraw
    alias __clauses__pbEndOfRoundPhase pbEndOfRoundPhase
    @battleClausesAliases = true
  end

  def pbDecisionOnDraw()
    if @rules["selfkoclause"]
      if self.lastMoveUser < 0
        # in extreme cases there may be no last move user
        return 5 # game is a draw
      elsif pbIsOpposing?(self.lastMoveUser)
        return 2 # loss
      else
        return 1 # win
      end
    end
    return __clauses__pbDecisionOnDraw()
  end

  def pbJudgeCheckpoint(attacker, move = nil)
    if @rules["drawclause"] # Note: Also includes Life Orb (not implemented)
      unless move && move.function == 0xDD # Not a draw if fainting occurred due to Liquid Ooze
        if pbBothSidesAllFainted?
          @decision = pbIsOpposing?(@attacker.index) ? 1 : 2
        end
      end
    elsif @rules["modifiedselfdestructclause"] && move && move.function == 0xE0 # Selfdestruct
      if pbBothSidesAllFainted?
        @decision = pbIsOpposing?(@attacker.index) ? 1 : 2
      end
    end
  end

  def pbEndOfRoundPhase(skipcelebi = false)
    __clauses__pbEndOfRoundPhase(skipcelebi)
    if @rules["suddendeath"] && @decision == 0
      if pbPokemonCountAllParties(@party1) > pbPokemonCountAllParties(@party2)
        @decision = 1 # loss
      elsif pbPokemonCountAllParties(@party1) < pbPokemonCountAllParties(@party2)
        @decision = 2 # win
      end
    end
  end
end

class PokeBattle_Battler
  unless @battleClausesAliases
    alias __clauses__pbCanSleep? pbCanSleep?
    alias __clauses__pbCanFreeze? pbCanFreeze?
    alias __clauses__pbUseMove pbUseMove
    @battleClausesAliases = true
  end

  def pbHasStatusPokemon?(status)
    count = 0
    party = @battle.pbCombinedParty(self.index)
    for i in 0...party.length
      if party[i] && !party[i].isEgg? && party[i].status == status
        count += 1
      end
    end
    return count > 0
  end

  def pbCanFreeze?(*args, **kwargs)
    if @battle.rules["freezeclause"] &&
       pbHasStatusPokemon?(:FROZEN)
      return false
    end

    return __clauses__pbCanFreeze?(*args, **kwargs)
  end

  def pbCanSleep?(attacker, move, ignorestatus: false, showMessage: false)
    selfsleep = attacker == self
    if ((@battle.rules["modifiedsleepclause"]) || (!selfsleep && @battle.rules["sleepclause"])) && pbHasStatusPokemon?(:SLEEP)
      if showMessage
        @battle.pbDisplay(_INTL("But {1} couldn't sleep!", self.pbThis(true)))
      end
      return false
    end
    return __clauses__pbCanSleep?(attacker, move, ignorestatus: ignorestatus, showMessage: showMessage)
  end
end

class PokeBattle_Move_022 # Double Team
  alias __clauses__pbCanAffectTarget pbCanAffectTarget unless method_defined?(:__clauses__pbCanAffectTarget)

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return false if @battle.rules["evasionclause"]

    return __clauses__pbCanAffectTarget(attacker, opponent, showMessage)
  end
end

class PokeBattle_Move_034 # Minimize
  alias __clauses__pbCanAffectTarget pbCanAffectTarget unless method_defined?(:__clauses__pbCanAffectTarget)

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return false if @battle.rules["evasionclause"]

    return __clauses__pbCanAffectTarget(attacker, opponent, showMessage)
  end
end

class PokeBattle_Move_067 # Skill Swap
  alias __clauses__pbCanAffectTarget pbCanAffectTarget unless method_defined?(:__clauses__pbCanAffectTarget)

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return false if @battle.rules["skillswapclause"]

    return __clauses__pbCanAffectTarget(attacker, opponent, showMessage)
  end
end

class PokeBattle_Move_06A # Sonicboom
  alias __clauses__pbCanAffectTarget pbCanAffectTarget unless method_defined?(:__clauses__pbCanAffectTarget)

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return false if @battle.rules["sonicboomclause"]

    return __clauses__pbCanAffectTarget(attacker, opponent, showMessage)
  end
end

class PokeBattle_Move_06B # Dragon Rage
  alias __clauses__pbCanAffectTarget pbCanAffectTarget unless method_defined?(:__clauses__pbCanAffectTarget)

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return false if @battle.rules["sonicboomclause"]

    return __clauses__pbCanAffectTarget(attacker, opponent, showMessage)
  end
end

class PokeBattle_Move_070 # OHKO moves
  alias __clauses__pbCanAffectTarget pbCanAffectTarget unless method_defined?(:__clauses__pbCanAffectTarget)

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    return false if @battle.rules["ohkoclause"]

    return __clauses__pbCanAffectTarget(attacker, opponent, showMessage)
  end
end

class PokeBattle_Move_0E0 # Selfdestruct
  alias __clauses__pbOnStartUse pbOnStartUse unless method_defined?(:__clauses__pbOnStartUse)

  def pbOnStartUse(attacker, targets)
    if @battle.rules["selfkoclause"]
      # Check whether no unfainted Pokemon remain in either party
      count = attacker.pbNonActivePokemonCount()
      count += attacker.pbOppositeOpposing.pbNonActivePokemonCount()
      if count == 0
        @battle.pbDisplay(_INTL("But it failed!"))
        return false
      end
    end
    if @battle.rules["selfdestructclause"]
      # Check whether no unfainted Pokemon remain in either party
      count = attacker.pbNonActivePokemonCount()
      count += attacker.pbOppositeOpposing.pbNonActivePokemonCount()
      if count == 0
        @battle.pbDisplay(_INTL("{1}'s team was disqualified!", attacker.pbThis))
        @battle.decision = @battle.pbIsOpposing?(attacker.index) ? 1 : 2
        return false
      end
    end
    __clauses__pbOnStartUse(attacker, targets)
  end
end

class PokeBattle_Move_0E5 # Perish Song
  alias __clauses__pbCanAffectTarget pbCanAffectTarget unless method_defined?(:__clauses__pbCanAffectTarget)

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if @battle.rules["perishsongclause"] && attacker.pbNonActivePokemonCount() == 0
      return false
    end

    return __clauses__pbCanAffectTarget(attacker, opponent, showMessage)
  end
end

class PokeBattle_Move_0E7 # Destiny Bond
  alias __clauses__pbCanAffectTarget pbCanAffectTarget unless method_defined?(:__clauses__pbCanAffectTarget)

  def pbCanAffectTarget(attacker, opponent, showMessage = false)
    if @battle.rules["perishsongclause"] && attacker.pbNonActivePokemonCount() == 0
      return false
    end

    return __clauses__pbCanAffectTarget(attacker, opponent, showMessage)
  end
end

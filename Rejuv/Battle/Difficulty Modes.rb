module DifficultModes
  # Variable number that control the difficult.
  # To use a different variable, change this. 0 deactivates this script
  VARIABLE = 200

  def self.trainers
    case $game_variables[:DifficultyModes]
      when 1
        return $cache.trainers_story
      when 2
        # intense, etc
      else
    end
    return $cache.trainers
  end

  def self.currentMode
    difficultHash = {}


    easyMode = Difficult.new(:STORY)

    # partyid (six parameter) number for trainer than can have other party.
    # Trainers loaded this way ignores the levelProcedure.
    # IN THIS EXAMPLE: If you start a battle versus YOUNGSTER Ben team 1,
    # the game searches for the YOUNGSTER Ben team 101 (100+1),
    # if the game founds it loads instead of the team 1.
    easyMode.idJump = 100

    # A formula to change all trainers pokémon level.
    # This affects money earned in battle.
    # IN THIS EXAMPLE: Every opponent pokémon that aren't found by idJump value
    # have the level*0.8 (round down). A pokémon level 6 will be level 4.
    easyMode.levelProcedure = proc { |level|
      next level * 0.9
    }

    # A formula to change all trainers pokémon money.
    # This is the last formula to apply.
    # IN THIS EXAMPLE: Multiplier the money given by the opponent by 1.3 (round
    # down), so if the final money earned is 99, the money will be 128.
    easyMode.moneyProcedure = proc { |money|
      next money * 1.3
    }
    # You can delete any of these three attributes if you didn't want them.

    # The Hash index is the value than when are in the VARIABLE number value,
    # the difficult will be ON.
    # IN THIS EXAMPLE: Only when variable 90 value is 1 than this changes
    # will occurs
    difficultHash[1] = easyMode


    hardMode = Difficult.new(:INTENSE)
    hardMode.idJump = 200
    hardMode.levelProcedure = proc { |level|
      next level
    }
    hardMode.moneyProcedure = proc { |money|
      next money * 0.8
    }
    difficultHash[2] = hardMode

    return DifficultModes::VARIABLE > 0 ?
      difficultHash[pbGet(DifficultModes::VARIABLE)] : nil
  end

  def self.applyLevelProcedure(level, procedure)
    return procedure ? [[procedure.call(level).floor, MAXIMUMLEVEL].min, 1].max : level
  end

  def self.applyMoneyProcedure(money)
    difficultSelected = self.currentMode
    return difficultSelected && difficultSelected.moneyProcedure ? [difficultSelected.moneyProcedure.call(money).floor, 0].max : money
  end

  def self.loadTrainer(trainerid, trainername, partyid = 0, noscaling: false, knownID: false, hasLevelCap: false)
    trainer = nil
    procedure = nil
    difficultSelected = self.currentMode
    difficultSelected = nil if noscaling
    if difficultSelected && !self.trainers.dig(trainerid, trainername, partyid)
      puts "Warning: Missing data for #{[trainerid, trainername, partyid].inspect}-#{difficultSelected.name}. Please report this."
      procedure = difficultSelected.levelProcedure
    end
    return pbLoadTrainerDifficult(trainerid, trainername, partyid, procedure, knownID: knownID, hasLevelCap: hasLevelCap, source: noscaling ? :ally : :trainer)
  end

  private

  class Difficult
    attr_accessor :idJump
    attr_accessor :levelProcedure
    attr_accessor :moneyProcedure
    attr_accessor :name

    def initialize(name)
      @name = name
      @idJump = 0
      @levelProcedure = nil
      @moneyProcedure = nil
    end
  end
end

def pbLoadTrainer(trainerid, trainername, partyid = 0, noscaling: false, knownID: false, hasLevelCap: false)
  return DifficultModes.loadTrainer(trainerid, trainername, partyid, noscaling: noscaling, knownID: knownID, hasLevelCap: hasLevelCap)
end

alias __difficult_findParty findParty unless defined?(__difficult_findParty)
def findParty(type, name, id)
  return DifficultModes.trainers.dig(type, name, id) || __difficult_findParty(type, name, id)
end

def pbLoadTrainerDifficult(type, name, id = 0, procedure = nil, knownID: false, hasLevelCap: false, source: :trainer)
  trainerTeam = findParty(type, name, id)
  puts "Team could not be loaded, please report this: #{type}, #{name}, #{id} \n ty <3" if !trainerTeam
  return nil if !trainerTeam

  if knownID
    opponent = knownTrainer(name, type)
  else
    opponent = PokeBattle_Trainer.new(name, type)
    opponent.setForeignID($Trainer) if $Trainer
  end
  opponent.name = $game_variables[:KieranName].capitalize if type == :UNKNOWN_1 && name == "???" && $game_variables[:KieranName] != 0
  opponent.trainereffect = trainerTeam.effects
  opponent.delayRegister = trainerTeam.delayRegister
  opponent.specialmoves = trainerTeam.flags[:specialmoves]
  opponent.teamAttributes = trainerTeam.teamAttributes

  items = trainerTeam.items

  team = trainerTeam.party
  partySize = trainerTeam.partySize
  setParty = trainerTeam.setParty
  team = buildTeamFromParameters(team, partySize, setParty)
  builderteam = team.map { |poke| poke.to_h { |k, v|
    next [k, v] if k != :level
    level = v
    level = DifficultModes.applyLevelProcedure(v, procedure)
    next [k, level]
  }}
  party = getTrainerPartyFromTrainerHash(builderteam, opponent, type, source: source)

  return [opponent, items, party]
end

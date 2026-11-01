class AI_MonData
  attr_accessor :index # To help ensure we keep the right data with the right battler
  attr_accessor :roles # This is for roles that belong to the current battler
  attr_accessor :trainer
  attr_accessor :partyroles # This is for roles that belong to the entire party
  attr_accessor :skill
  attr_accessor :party
  attr_accessor :scorearray
  attr_accessor :roughdamagearray
  attr_accessor :miniscorearray
  attr_accessor :itemscore
  attr_accessor :shouldswitchscore
  attr_accessor :switchscore
  attr_accessor :shouldUseBattleFormChange
  attr_accessor :zmoves
  attr_accessor :attitemworks
  attr_accessor :oppitemworks
  attr_accessor :speedGuess

  def initialize(trainer, index, battle)
    @trainer = trainer
    @index   = index
    @skill   = trainer.nil? ? PokeBattle_AI::MINIMUMSKILL : trainer.skill
    @skill   = PokeBattle_AI::BESTSKILL if $game_switches[:Best_Skill_Password]
    @party   = trainer.nil? ? [] : battle.pbPartySingleOwner(index)
    @roles   = []
    # there are four move arrays, but one of them doesn't get used depending on the index of the aimon
    @scorearray = [[-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1]]
    @roughdamagearray = [[-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1]] # again, for doubles...
    @miniscorearray = [[-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1]]
    @itemscore = {}
    @switchscore = []
    @shouldswitchscore = -10000
    @shouldUseBattleFormChange = false
    @zmoves = []
    @attitemworks = true
    @oppitemworks = true
    @speedGuess = nil
  end
end

class PokeBattle_AI
  attr_accessor :battle # Current battle the AI is pulling from (PokeBattle_Battle)
  attr_accessor :move # Current move being scored (PokeBattle_Move)
  attr_accessor :basemove # Base move of the current move being scored (eg, Nature Power) (PokeBattle_Move)
  attr_accessor :attacker # User of the current move being scored (PokeBattle_Battler)
  attr_accessor :opponent # Opposing pokemon that the move will be used on (PokeBattle_Battler)
  attr_accessor :aimondata # Array of all trainers in the battle (AI_MonData)
  attr_accessor :mondata # Current trainer being processed (AI_MonData)
  attr_accessor :miniscore # holder for the miniscore (Number)
  attr_accessor :score     # holder for the score-score (Number)
  attr_accessor :index     # index of the battler being evaluated (Number)
  attr_accessor :aiMoveMemory # Moves the AI knows about (Array of move numbers)
  attr_accessor :initial_scores # scores of all moves for a target (Array of scores)
  attr_accessor :score_index # index of current move being evaluated

  # We can adjust the thresholds as we work on things
  MINIMUMSKILL = 1
  LOWSKILL = 10
  MEDIUMSKILL = 30
  HIGHSKILL = 60
  BESTSKILL = 100

  # Function codes you might want to use on your partner.
  # Note that Partner targeting moves are not included as they are handled separately
  PARTNERFUNCTIONS = [
    0x40, # Swagger
    0x41, # Flatter
    0x55, # Psych Up
    0x63, # Simple Beam
    0x66, # Entrainment
    0x67, # Skill Swap
    0xA0, # Frost Breath
    0xC1, # Beat Up
    0xDF, # Heal Pulse
    0x142, # Topsy-Turvy
    0x150, # Floral Healing
    0x151, # Gear Up
    0x162, # Flower Shield
    0x163, # Rototiller
    0x164, # Instruct
    0x167, # Pollen Puff
    0x169, # Purify
    0x170, # Spotlight
    0x11d, # After You
    0x185, # Decorate
    0x50D, # Spicy Extract
  ]

  ######################################################
  # Core functions
  ######################################################
  # Do what we can to setup at the start of the battle

  def initialize(battle)
    @battle = battle
    @aimondata = [nil, nil, nil, nil]
    @aiMoveMemory = {}
    player = @battle.player
    opponent = @battle.opponent
    @battle.fakeopponent = []

    if @battle.doublebattle
      if player.is_a?(Array)
        @aimondata[0] = AI_MonData.new(player[0], 0, @battle)
        @aimondata[2] = AI_MonData.new(player[1], 2, @battle)
        @aiMoveMemory[player[0]] = {}
        @aiMoveMemory[player[1]] = {}
      else
        @aimondata[0] = AI_MonData.new(player, 0, @battle)
        @aimondata[2] = AI_MonData.new(player, 2, @battle)
        @aiMoveMemory[player] = {}
      end
      if opponent && opponent.is_a?(Array)
        @aimondata[1] = AI_MonData.new(opponent[0], 1, @battle)
        @aimondata[3] = AI_MonData.new(opponent[1], 3, @battle)
        @aiMoveMemory[opponent[0]] = {}
        @aiMoveMemory[opponent[1]] = {}
      elsif opponent
        @aimondata[1] = AI_MonData.new(opponent, 1, @battle)
        @aimondata[3] = AI_MonData.new(opponent, 3, @battle)
        @aiMoveMemory[opponent] = {}
      else
        @aimondata[1] = AI_MonData.new(nil, 1, @battle)
        @aimondata[3] = AI_MonData.new(nil, 3, @battle)
        bosses = [@battle.party2[0][0],@battle.party2[0][1]].select {|boss| boss&.bossID}
        if bosses.include?(@battle.party2[0][0]) && bosses.include?(@battle.party2[0][1])
          @battle.fakeopponent = pbMakeFakeAITrainer([1,3])
          @aiMoveMemory[@battle.fakeopponent] = {}
        elsif bosses.include?(@battle.party2[0][0])
          @battle.fakeopponent = pbMakeFakeAITrainer(1)
          @aiMoveMemory[@battle.fakeopponent] = {}
        elsif bosses.include?(@battle.party2[0][1])
          @battle.fakeopponent = pbMakeFakeAITrainer(3)
          @aiMoveMemory[@battle.fakeopponent] = {}
        end
      end
    else
      @aimondata[0] = AI_MonData.new(player, 0, @battle)
      @aiMoveMemory[player] = {}
      if @battle.opponent
        @aimondata[1] = AI_MonData.new(opponent, 1, @battle)
        @aiMoveMemory[opponent] = {}
      else
        @aimondata[1] = AI_MonData.new(nil, 1, @battle)
      end
      if $cache.bosses[@battle.party2[0][0]&.bossID]
        @battle.fakeopponent = pbMakeFakeAITrainer(1)
        @aiMoveMemory[@battle.fakeopponent] = {}
        @aimondata[2] = AI_MonData.new(player, 2, @battle) if $cache.bosses[@battle.party2[0][0].bossID].doublebattle
      end
    end
    # Having set up the data objects, get their roles (if applicable)
    for data in @aimondata
      next if data.nil?

      @mondata = data
      @mondata.partyroles = @mondata.skill >= HIGHSKILL ? pbGetMonRoles : Array.new(@mondata.party.length) { Array.new() }
    end
    setUpDebugLog
  end

  def pbMakeFakeAITrainer(index)
    if index.is_a?(Array)
      name = @battle.party2[0][0].name + " and " + @battle.party2[0][1].name
      return PokeBattle_Trainer.new(name, :BOSSPOKEMON)
    else
      if index == 1
        if $cache.bosses[@battle.party2[0][0]&.bossID]
          return PokeBattle_Trainer.new(@battle.party2[0][0].name, :BOSSPOKEMON)
        end
      end
      if index == 3
        if $cache.bosses[@battle.party2[0][1]&.bossID]
          return PokeBattle_Trainer.new(@battle.party2[0][1].name, :BOSSPOKEMON)
        end
      end
    end
  end

  def setUpDebugLog
    filename = @battle.getLogFileName
    PBDebug.setup(filename, @battle.seed)
  end

  def processAIturn
    # Clear old data
    @aimondata.each { |mondata| clearMonDataTurn(mondata) if mondata }
    $ai_log_data.each { |logdata| logdata.reset(nil) }

    # assign roles to mondata
    @aimondata.each { |mondata| mondata.roles = pbGetMonRoles(@battle.battlers[mondata.index]) if mondata }

    # Guess whether a battler will be faster or slower this turn. Must be done for all active pokemon, and before any speed comparisons
    buildspeedGuess()

    # Get the scores for each mon in battle
    for index in 0...@aimondata.length
      next if !@aimondata[index]
      next if !@battle.pbCanShowCommands?(index) || @battle.battlers[index].hp == 0
      # Build scores even for player mons when they have an AI partner, so that the AI can determine what the player might do and use that for coordinateActions.
      pindex = index ^ 2
      next unless @battle.aiControlled?(index) || (@battle.aiControlled?(pindex) && @aimondata[pindex] && @battle.pbCanShowCommands?(pindex) && @battle.battlers[pindex].hp != 0)

      @mondata = @aimondata[index]
      # load up the class variables
      @index = index
      @attacker = pbCloneBattler(@index)
      $ai_log_data[index].reset(@attacker) # AI data collection

      # Check if attacker should use mega/ultra/tera and modify attacker if it should
      v = checkMega(@attacker) || checkUltraBurst(@attacker) || checkTera(@attacker)
      @mondata.shouldUseBattleFormChange = v

      # Actually get the scores
      checkZMoves()
      buildMoveScores()

      # we set @opponent for Itemscore and Switchingscore
      opp = @attacker.pbFirstOpposing
      @opponent = pbCloneBattler(opp.index, illusionDeceived?(opp, @battle.battlers[opp.index]))
      getItemScore()
      getSwitchingScore()
    end

    # Coordination if there are two mons on the same side
    if @battle.doublebattle
      coordinateActions(1, 3, 0, 2)
      coordinateActions(0, 2, 1, 3) if [0, 2].any?{ |i| @battle.aiControlled?(i) }
      extract_adjusted_move_scores()
    end

    # At this point, the processing is done and the AI should register its decisions
    # but i don't know how to do that, and i think we can do it from the battle side anyway
    # so as far as the ai code is concerned, we're done now.
    # We have the scores, now we decide what we want to do with them
    chooseAction()
  end

  # Used during move scoring to apply mega/ultra/tera to AI-controlled partner targets, for coordination (could be extended to all AI-controlled targets)
  def pbCloneAndApplyBattleForm(opp)
    newopp = pbCloneBattler(opp.index, illusionDeceived?(@attacker, opp))
    if opp.index == @attacker.pbPartner.index && @battle.aiControlled?(opp.index)
      checkMega(newopp) || checkUltraBurst(newopp) || checkTera(newopp)
    end
    return newopp
  end

  def pbCloneBattler(index, illusion = false, sourceBattler: nil)
    original = sourceBattler || (illusion ? @battle.battlers[index].effects[:Illusion] : @battle.battlers[index])
    battler = original.clone
    battler.pokemon = original.pokemon.clone
    battler.originalpokemon = original.pokemon # only for accessing permanenteffects
    battler.form = original.form.clone
    battler.pokemon.hp = original.pokemon.hp.clone
    battler.moves = original.moves.clone
    for i in 0...original.moves.length
      battler.moves[i] = original.moves[i].clone
    end
    battler.stages = original.stages.clone
    for i in 0...original.stages.length
      battler.stages[i] = original.stages[i].clone
    end
    battler.effects = original.effects.clone
    battler.effects[:Illusion] = nil # need to make absolutely sure there isn't anything pointing at the "real" illusion copy
    return battler
  end

  def clearMonDataTurn(mondata)
    mondata.shouldUseBattleFormChange = false
    mondata.scorearray = [[-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1]]
    mondata.roughdamagearray = [[-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1]]
    mondata.itemscore = {}
    mondata.switchscore = []
    mondata.shouldswitchscore = -10000
    mondata.zmoves = []
    mondata.speedGuess = nil
  end

  def checkMega(battler)
    return false if !@battle.pbCanMegaEvolve?(battler.index)

    want_to_mega = true
    # Run through conditions to see if you don't want to mega
    return false if !want_to_mega

    # and if you want to mega, change the attacker
    battler.pokemon.makeMega
    battler.form = battler.pokemon.form
    battler.pbUpdate(true, fakebattler: true)

    return true
  end

  def checkUltraBurst(battler)
    return false if !@battle.pbCanUltraBurst?(battler.index)

    # change the attacker to be itself but ultra bursted
    battler.pokemon.makeUltra
    battler.form = battler.pokemon.form
    battler.pbUpdate(true, fakebattler: true)

    return true
  end

  def checkTera(battler)
    return false if !@battle.pbCanTerastallize?(battler.index)

    # TODO: apply conditions regarding whether the AI should tera, particularly in terapago's and cornerstone ogerpon case

    # change the attacker to be itself but tera'd
    battler.pokemon.makeTerastallized
    battler.form = battler.pokemon.form
    battler.pbUpdate(true, fakebattler: true)

    return true
  end

  def checkZMoves
    return if @attacker.zmoves.nil?
    return if !@battle.pbCanZMove?(@index)

    zmoves = []
    for i in 0...@attacker.zmoves.length
      move = @attacker.zmoves[i]
      next if move.nil?
      next if @attacker.moves[i].nil?
      next if @attacker.moves[i].pp == 0

      if !zmoves.any? {|m| m.move == move.move}
        zmoves.push(move)
      else
        dupemove = zmoves.find {|m| m.move == move.move}
        dupemoveindex = @attacker.zmoves.index(dupemove)
        if move.basedamage > dupemove.basedamage || (move.basedamage == dupemove.basedamage && @attacker.moves[i].pp > @attacker.moves[dupemoveindex].pp)
          zmoves.delete(dupemove)
          zmoves.push(move)
        end
      end
    end

    @mondata.zmoves = zmoves
    zmoves.length.times do
      @mondata.roughdamagearray.each { |array| array.push(-1) }
      @mondata.scorearray.each { |array| array.push(-1) }
    end
  end

  def getTypesOnEntry(trainer, pkmn, delay = false)
    return if !trainer&.trainereffect
    return if !@battle.opponent || @battle.opponent.is_a?(Array)
    if trainer.trainereffect[:effectmode]
      if trainer.trainereffect[:effectmode] == :Party
        trainereffect = trainer.trainereffect[pkmn.pokemonIndex]
      elsif trainer.trainereffect[:effectmode] == :Fainted
        trainereffect = trainer.trainereffect[pkmn.pbFaintedPokemonCount]
      end
      if trainereffect
        if trainereffect[:typeChange]
          pkmn.type1 = trainereffect[:typeChange][0]
          pkmn.type2 = trainereffect[:typeChange][1] if trainereffect[:typeChange][1]
        end
        if trainereffect[:addType]
          pkmn.effects[:TemporaryType] = trainereffect[:addType] if !pkmn.types.include?(trainereffect[:addType])
        end
        if trainereffect[:teraType]
          pkmn.teraTypeEffect = trainereffect[:teraType]
        end
      end
    end
  end

  def getTrainerEffects(trainer, pkmnIndex, delay = false)
    return if !trainer&.trainereffect
    return if !@battle.opponent || @battle.opponent.is_a?(Array)
    if trainer.trainereffect[:effectmode]
      if trainer.trainereffect[:effectmode] == :Party
        trainereffect = trainer.trainereffect[pkmnIndex]
      elsif trainer.trainereffect[:effectmode] == :Fainted
        trainereffect = trainer.trainereffect[pkmnIndex]
      end
      return trainereffect if trainereffect
    end
  end

  def getStatBoostsOnEntry(trainer, pkmn, delay = false)
    # code below based on LAWDS' implementation of this, some changes to account for new structures
    statsboost_on_entry = pkmn.stages
    return statsboost_on_entry if !trainer&.trainereffect
    return statsboost_on_entry if !@battle.opponent || @battle.opponent.is_a?(Array)
    if trainer.trainereffect[:effectmode]
      if trainer.trainereffect[:effectmode] == :Party
        trainereffect = trainer.trainereffect[pkmn.pokemonIndex]
      elsif trainer.trainereffect[:effectmode] == :Fainted
        trainereffect = trainer.trainereffect[pkmn.pbFaintedPokemonCount]
      end
      if trainereffect
        if trainereffect[:pokemonStatChanges]
          statsboost_on_entry = trainereffect[:pokemonStatChanges]
          return statsboost_on_entry
        end
      end
    end
    return statsboost_on_entry
  end

  def getFieldOnEntry(trainer, pkmn, delay = false)
    # code below based on LAWDS' implementation of this, some changes to account for new structures
    field_on_entry = @battle.field.effect
    return field_on_entry if !trainer.trainereffect
    return field_on_entry if !@battle.opponent || @battle.opponent.is_a?(Array)
    if trainer.trainereffect[:effectmode]
      if trainer.trainereffect[:effectmode] == :Party
        trainereffect = trainer.trainereffect[pkmn.pokemonIndex]
      elsif trainer.trainereffect[:effectmode] == :Fainted
        trainereffect = trainer.trainereffect[pkmn.pbFaintedPokemonCount]
      end
      if trainereffect
        if trainereffect[:fieldChange]
          field_on_entry = trainereffect[:fieldChange][0]
        end
        if delay && trainereffect[:queueDelays]
          for delayedKey in trainereffect[:queueDelays]
            delayedEffect = trainer.delayRegister[delayedKey]
            if delayedEffect[:delay] == 1 && delayedEffect[:delay][:fieldChange]
              if trainereffect[:delayedaction][:fieldChange][0] != field_on_entry
                field_on_entry = trainereffect[:delayedaction][:fieldChange][0]
              end
            end
          end
        end
      end
    end
    return field_on_entry
  end

  def buildspeedGuess
    # Each battler checks to see if another battler can change their speed during the turn.
    # The speed change saved to @mondata.speedGuess is kept in the following priority:
    #  * afteryou (from partner, makes attacker move immediately)
    #  * quash (from opponent, makes attacker move last)
    #  * faster (from partner, 2x multipliers or +2 speed raises)
    #  * slower (from opponent, 0.5x multipliers or -2 speed lowers)
    #  * fast (from partner, 1.5x multipliers or +1 speed raises)
    #  * slow (from opponent, -1 speed lowers)
    return unless useDynamicSpeed

    # Attacker loop
    for index in 0...@aimondata.length
      next if @aimondata[index].nil?
      next if @battle.battlers[index].isFainted?

      @mondata = @aimondata[index]
      @attacker = pbCloneBattler(index)

      # Get effects related to the attacker
      aStage = @attacker.stages[PBStats::SPEED]
      electricImmune = PBTypes.typesEff(:ELECTRIC, @attacker.types, inverse: @battle.inverse?).immune? || [:VOLTABSORB, :LIGHTNINGROD, :MOTORDRIVE].include?(@attacker.ability) || @attacker.pbPartner.ability == :LIGHTNINGROD
      behindSubstitute = @attacker.effects[:Substitute] > 0
      quarkDriveReady = @attacker.ability == :QUARKDRIVE && @attacker.effects[:Quarkdrive][0] == 0 && @attacker.getHighestStatWithStages == PBStats::SPEED
      protosynthesisReady = @attacker.ability == :PROTOSYNTHESIS && @attacker.effects[:Protosynthesis][0] == 0 && @attacker.getHighestStatWithStages == PBStats::SPEED

      # Opponent loop
      for monindex in 0...@battle.battlers.length
        next if monindex == @attacker.index
        next if @battle.battlers[monindex].isFainted?

        @opponent = pbCloneAndApplyBattleForm(@battle.battlers[monindex])
        speedCanReduce = @attacker.pbCanReduceStatStage?(PBStats::SPEED, @opponent, nil, ignoreContrary: true)
        paralysisWorks = @attacker.pbCanParalyze?(@opponent, nil) && @attacker.ability != :QUICKFEET
        opponentFaster = !pbAIfaster?(dynamic: false)
        opponentGaleWings = @opponent.galeWingsActive?
        opponentPrankster = @opponent.ability == :PRANKSTER
        fasterThanPartner = pbAIfaster?(nil, nil, @attacker, @attacker.pbPartner, dynamic: false)
        partnerFasterThanOpponent = pbAIfaster?(nil, nil, @attacker.pbPartner, @opponent, dynamic: false)
        next unless opponentFaster || opponentGaleWings || opponentPrankster

        memory = getAIMemory()
        next if memory.empty?

        # Get effects related to the opponent
        oStage = @opponent.stages[PBStats::SPEED]
        notTaunted = @opponent.effects[:Taunt] == 0
        notHoldingEverstone = !@opponent.itemWorks? || @opponent.item != :EVERSTONE
        attackerNotContrary = @attacker.ability != :CONTRARY || moldBreakerCheck(@opponent, @attacker, nil)

        # Now we check the AI memory
        if @attacker.pbIsOpposing?(monindex) # Opponent
          if speedCanReduce && attackerNotContrary
            if opponentFaster
              guessSpeed(:slow, true) if checkAImoves([:ROCKTOMB, :GLACIATE, :ICYWIND], memory)
              guessSpeed((Rejuv && @battle.FE == :ELECTERRAIN ? :slower : :slow), true) if checkAImoves([:ELECTROWEB], memory) && !electricImmune
              guessSpeed(:slow, true) if checkAImoves([:LOWSWEEP], memory) && (!PBTypes.typesEff(:FIGHTING, @attacker.types, inverse: @battle.inverse?).immune? || @attacker.effects[:Foresight])
              guessSpeed(:slow, true) if checkAImoves([:CONSTRICT], memory) && (!PBTypes.typesEff(:NORMAL, @attacker.types, inverse: @battle.inverse?).immune? || @attacker.effects[:Foresight])
              guessSpeed(:slow, true) if checkAImoves([:BUBBLE, :BUBBLEBEAM], memory) && !([:WATERABSORB, :STORMDRAIN, :DRYSKIN].include?(@attacker.ability) || @attacker.pbPartner.ability == :STORMDRAIN)
              guessSpeed(:slow, true) if checkAImoves([:DRUMBEATING], memory) && !(@attacker.ability == :SAPSIPPER || @attacker.crested == :WHISCASH)
              if canGroundMoveHit?(@attacker, nil, moldBreakerCheck(@opponent, @attacker, nil))
                guessSpeed(:slow, true) if checkAImoves([:BULLDOZE], memory) && @attacker.crested != :SKUNTANK
                guessSpeed((Rejuv && @battle.FE == :SWAMP ? :slower : :slow), true) if checkAImoves([:MUDSHOT], memory)
              end
            end
            guessSpeed(:slow, true) if (opponentFaster || opponentGaleWings) && checkAImoves([:BLEAKWINDSTORM], memory)
          end
          guessSpeed(aStage > 1 ? :slower : :slow) if checkAImoves([:CLEARSMOG], memory) && aStage > 0 && !PBTypes.typesEff(:POISON, @attacker.types, inverse: @battle.inverse?).immune? && !behindSubstitute
          guessSpeed(:slower) if checkAImoves([:NUZZLE, :ZAPCANNON], memory) && paralysisWorks && !electricImmune
          if (opponentFaster || opponentPrankster) && notTaunted && (!opponentPrankster || !@attacker.hasType?(:DARK) || @battle.FE == :BEWITCHED)
            if speedCanReduce && attackerNotContrary
              guessSpeed(:slow, true) if checkAImoves([:VENOMDRENCH], memory) && !behindSubstitute && (@attacker.status == :POISON || [:CORROSIVE, :CORROSIVEMIST, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE))
              guessSpeed(:slow, true) if checkAImoves([:TOXICTHREAD], memory)
              guessSpeed(:slow, true) if checkAImoves([:TARSHOT], memory)
              guessSpeed(:slow, true) if checkAImoves([:BLOCK], memory) && !behindSubstitute && @attacker.effects[:MeanLook] == -1 && @battle.FE == :CROWD
              guessSpeed(:slow, true) if checkAImoves([:PARTINGSHOT], memory) && @battle.FE == :FROZENDIMENSION
              guessSpeed(:slower, true) if checkAImoves([:SCARYFACE, :STRINGSHOT], memory)
            end
            if paralysisWorks
              guessSpeed(:slower) if checkAImoves([:GLARE], memory)
              guessSpeed(:slower) if checkAImoves([:THUNDERWAVE], memory) && !electricImmune
            end
            guessSpeed(aStage > 1 ? :slower : :slow) if checkAImoves([:HAZE], memory) && aStage > 0
            guessSpeed(aStage - oStage > 1 ? :slower : :slow) if checkAImoves([:HEARTSWAP], memory) && aStage > oStage
            guessSpeed(:quash) if checkAImoves([:QUASH], memory) && !behindSubstitute
            if !@attacker.hasType?(:GRASS) && @attacker.ability != :OVERCOAT && !(@attacker.itemWorks? && @attacker.item == :SAFETYGOGGLES)
              guessSpeed(:slower) if checkAImoves([:STUNSPORE], memory) && paralysisWorks
              guessSpeed(:slower, true) if checkAImoves([:COTTONSPORE], memory) && speedCanReduce && attackerNotContrary
            end
          end
        else # Partner
          if opponentFaster
            if checkAImoves([:PLASMAFISTS], memory) && notHoldingEverstone
              guessSpeed(:fast) if quarkDriveReady || (@attacker.ability == :QUICKFEET && !@attacker.quickFeetActive?)
              guessSpeed(:faster) if @attacker.ability == :SURGESURFER && !@attacker.surgeSurferActive?
            end
            if checkAImoves([:STOKEDSPARKSURFER], memory)
              guessSpeed(:fast) if quarkDriveReady || (@attacker.ability == :QUICKFEET && !@attacker.quickFeetActive?)
              guessSpeed(:faster) if @attacker.ability == :SURGESURFER && !@attacker.surgeSurferActive?
            end
          end
          if notTaunted
            if opponentFaster || opponentPrankster
              if checkAImoves([:ELECTRICTERRAIN], memory)
                guessSpeed(:fast) if quarkDriveReady || (@attacker.ability == :QUICKFEET && !@attacker.quickFeetActive?)
                guessSpeed(:faster) if @attacker.ability == :SURGESURFER && !@attacker.surgeSurferActive?
              end
              if checkAImoves([:IONDELUGE], memory) && notHoldingEverstone
                guessSpeed(:fast) if quarkDriveReady || (@attacker.ability == :QUICKFEET && !@attacker.quickFeetActive?)
                guessSpeed(:faster) if @attacker.ability == :SURGESURFER && !@attacker.surgeSurferActive?
              end
              guessSpeed(:fast, true) if checkAImoves([:DRAGONDANCE, :QUIVERDANCE], memory) && @attacker.ability == :DANCER && @attacker.pbCanIncreaseStatStage?(PBStats::SPEED, @attacker, nil)
              guessSpeed(aStage < -1 ? :faster : :fast) if checkAImoves([:HAZE], memory) && aStage < 0
              guessSpeed(oStage - aStage < 1 ? :faster : :fast) if checkAImoves([:HEARTSWAP], memory) && aStage < oStage
              if checkAImoves([:SUNNYDAY], memory)
                guessSpeed(:fast) if protosynthesisReady
                guessSpeed(:faster) if (@attacker.ability == :CHLOROPHYLL && !@attacker.chlorophyllActive?)
              end
              guessSpeed(:faster) if checkAImoves([:RAINDANCE], memory) && @attacker.ability == :SWIFTSWIM && !@attacker.swiftSwimActive?
              guessSpeed(:faster) if checkAImoves([:SANDSTORM], memory) && @attacker.ability == :SANDRUSH && !@attacker.sandRushActive?
              guessSpeed(:faster) if checkAImoves([:HAIL, :SNOWSCAPE], memory) && @attacker.ability == :SLUSHRUSH && !@attacker.slushRushActive?
              guessSpeed(:faster) if checkAImoves([:PSYCHICTERRAIN], memory) && @attacker.ability == :TELEPATHY && !@attacker.telepathyActive?
              guessSpeed(:afteryou) if checkAImoves([:AFTERYOU], memory)
              if mondata.trainer && [:LEADER_ALLEN2].include?(mondata.trainer.trainertype) && @battle.doublebattle#
                guessSpeed(:afteryou) if partnerFasterThanOpponent && !fasterThanPartner
              end
            end
            guessSpeed(:faster) if checkAImoves([:TAILWIND], memory)
          end
        end
      end
    end
  end

  def guessSpeed(guess, stageChange = false)
    # Store the guess in the battler's mondata
    # Only store the guess if it's more significant than what is already stored

    # Simple will intensify the guess of moves that change the attacker's speed stage
    if stageChange && @attacker.ability == :SIMPLE && !moldBreakerCheck(@opponent, @attacker, nil)
      case guess
        when :slow then guess = :slower
        when :fast then guess = :faster
      end
    end

    significance = { :afteryou => 6, :quash => 5, :faster => 4, :slower => 3, :fast => 2, :slow => 1, nil => 0 }
    @mondata.speedGuess = guess if significance[guess] > significance[@mondata.speedGuess]
  end

  def getAllBattlerMoves(battler, mondata)
    allmoves = Array.new(8)
    allmoves.insert(0, *battler.moves)
    allmoves.insert(4, *mondata.zmoves)
    return allmoves
  end

  def buildMoveScores
    # this is the framework for getting the move scores. minimal calculation should be done here
    # First check if this is a wild battle
    if !@battle.opponent && @battle.pbIsOpposing?(@index) && !(@battle.battlers[@index].isbossmon || @battle.battlers[@index].issosmon)
      preference = @attacker.personalID % 4
      for j in [0, 2]
        next if j == 2 && !@battle.doublebattle

        for i in 0..3
          if @battle.pbCanChooseMove?(@index, i)
            @mondata.scorearray[j][i] = 100
            @mondata.scorearray[j][i] += 5 if preference == i # for personality
          end
        end
      end
      return
    end
    # real code time.
    allmoves = getAllBattlerMoves(@attacker, @mondata)
    opparray = []
    for oppindex in 0...@battle.battlers.length
      next if oppindex == @index # This is you! We don't want to hit ourselves.
      next if @battle.battlers[oppindex].isFainted? # Can't hit 'em if they're dead (also takes care of single battles since the two extra slots are always fainted there)
      opparray.push(oppindex)
    end
    opparray.each { |oppindex| initialScoreMoveAgainstOpponent(oppindex, allmoves) }
    opparray.each { |oppindex| finalScoreMoveAgainstOpponent(oppindex, allmoves) }
    extract_move_scores()
  end

  def initialScoreMoveAgainstOpponent(oppindex, allmoves)
    @opponent = pbCloneAndApplyBattleForm(@battle.battlers[oppindex])

    # Consider opp's substitute as its current HP if none of the AI's moves can go through it
    opphp = @opponent.hp
    hitssub = @opponent.effects[:Substitute] > 0 && allmoves.compact.none? { |move| (move.pbIsDamaging? && !move.blockedBySubstitute?(@attacker, @opponent)) || @attacker.pbGetHitNumber(move, norandomness: true) > 1 }
    opphp = @opponent.effects[:Substitute] if hitssub

    # Save the amount of damage the AI thinks opp can do
    unless scoringAgainstPartner?
      emove, edamage = checkAIMovePlusDamage()
      $ai_log_data[@index].expected_move.push(emove.name.nil? ? "#{emove.basedamage} BP #{emove.type} Move" : emove.name)
      $ai_log_data[@index].expected_damage.push((edamage * 100.0 / @attacker.totalhp).round(1))
      $ai_log_data[@index].expected_damage_name.push(@opponent.logname)
    end

    # Build initial scores for regular moves and z moves
    has_to_struggle = true
    i = -1 # Overall index (0..7) (regular moves + z moves) for scoring
    for move in allmoves
      i += 1
      next if move.nil?

      moveindex = move.zmove ? @attacker.zmoves.index(move) : @attacker.moves.index(move) # Move slot index (0..3) for move selection
      next if !@battle.pbCanChooseMove?(@index, moveindex, zpower: move.zmove) # choice item/encore/taunt/torment

      has_to_struggle = false
      @basemove = move
      @move = pbChangeMove(move, @attacker) # change nature power into what it's going to become

      # if you can't/shouldn't hit your partner with the move, skip scoring the move against it
      # and score moves with Partner targeting -only- against the partner
      next if scoringAgainstPartner? && @attacker.pbTarget(@move) != :AllNonUsers && !PARTNERFUNCTIONS.include?(@move.function) && @move.target != :Partner
      next if !scoringAgainstPartner? && @move.target == :Partner

      @mondata.roughdamagearray[oppindex][i] = calcInitialScore(opphp)
      $ai_log_data[@attacker.index].moves_scored.push([oppindex, i])
      # The old function makes some adjustments for two-turn moves here. I'm leaving that for later.
    end

    # Build initial score for Struggle
    if has_to_struggle && !scoringAgainstPartner?
      @move = @battle.struggle
      @mondata.roughdamagearray[oppindex][0] = calcInitialScore(opphp)
      $ai_log_data[@attacker.index].moves_scored.push([oppindex, 0])
    end
  end

  def calcInitialScore(opphp)
    score = @move.pbIsDamaging? ? [(pbRoughDamage() * 100) / opphp.to_f, 110].min : getStatusDamage()
    score = score < 1 ? score.ceil : score.floor
    # Done so that 0.1% damage still gets a 1 score rather than 0
    # Neither pbRoughDamage nor getStatusDamage return negative values so that is not a concern
    return score
  end

  def finalScoreMoveAgainstOpponent(oppindex, allmoves)
    @opponent = pbCloneAndApplyBattleForm(@battle.battlers[oppindex])
    initialScores = @mondata.roughdamagearray[oppindex]

    # Build final scores
    for i in 0..7
      next if initialScores[i].nil? || initialScores[i] == -1 # skip final scoring if initial scoring wasn't done for any reason

      @basemove = allmoves[i]
      @move = pbChangeMove(allmoves[i], @attacker) # change nature power into what it's going to become

      finalScore, miniscore = getMoveScore(initialScores, i)
      @mondata.scorearray[oppindex][i] = finalScore
      @mondata.miniscorearray[oppindex][i] = miniscore
    end

    # Modify final scores (for cases that can't be handled in getMoveScore for one reason or another)
    for i in 0..7
      next if initialScores[i].nil? || initialScores[i] == -1 # skip final scoring if initial scoring wasn't done for any reason

      @basemove = allmoves[i]
      @move = pbChangeMove(allmoves[i], @attacker) # change nature power into what it's going to become

      modFinalScore = getModifiedMoveScore(@mondata.scorearray[oppindex], i, @opponent)
      @mondata.scorearray[oppindex][i] = modFinalScore
    end
  end

  def chooseAction # chooses the action that the AI pokemon will perform
    # Threat scores, to be used in case of move score ties in double battles
    threatScores1 = threatAssessment(1, 3, 0, 2)
    biggest_threat_player_side = threatScores1.index(threatScores1.max)
    threatScores2 = threatAssessment(0, 2, 1, 3)
    biggest_threat_opponent_side = threatScores2.index(threatScores2.max)

    for index in 0...@aimondata.length # for every battler
      next if @aimondata[index].nil?
      next unless @battle.aiControlled?(index)

      battler = @battle.battlers[index]
      next if battler.hp == 0 || !@battle.pbCanShowCommands?(index)
      next if @battle.choices[battler.index] != [nil]

      @mondata = @aimondata[index]
      # make move-targets coupled list bc that works way easier?
      @mondata.scorearray.map! { |scorelist| scorelist.map! { |score| score < 0 ? -1 : score } }
      # make list of moves, targets, and scores, # structured [moveindex, [target(s)], score, isZmove?]
      chooseablemoves = findChoosableMoves(battler, @mondata)
      # log any cumulative scores from findChoosableMoves for atypical targeting moves in case of double battles
      $ai_log_data[battler.index].cumulative_move_scores = extract_cumulative_move_scores(battler, chooseablemoves) if @battle.doublebattle
      # get the maximum available score
      maxmovescore = chooseablemoves.length == 0 ? 0 : chooseablemoves.max { |a1, a2| a1[:score] <=> a2[:score] }[:score]

      # SWITCH
      indexToSwitchTo = getIndexToHardSwitchTo(battler, @mondata, maxmovescore, true) # returns an index or nil
      if indexToSwitchTo
        switchinmon = @battle.pbPartySingleOwner(battler.index)[indexToSwitchTo]
        PBDebug.dblog(sprintf("Switching to %s", switchinmon.logname))
        $ai_log_data[battler.index].chosen_action = sprintf("Switching to %s", switchinmon.logname)
        @battle.pbRegisterSwitch(battler.index, indexToSwitchTo)
        next
      end

      # USE ITEM
      if !@mondata.itemscore.empty? && @mondata.itemscore.values.max > maxmovescore
        item = @mondata.itemscore.key(@mondata.itemscore.values.max)
        # check if quantity of item the battler has is 1 and if previous battler hasn't also tried to use this item
        pi = battler.index ^ 2 # partner
        if [2, 3].include?(battler.index) && @battle.pbGetOwnerIndex(battler.index) == @battle.pbGetOwnerIndex(pi) &&
           @battle.choices[pi][0] == :item && @battle.choices[pi][1] == item
          items = @battle.pbGetOwnerItems(battler.index)
          if items.count { |element| element == item } > 1
            @battle.pbRegisterItem(battler.index, item, battler.pokemonIndex)
            $ai_log_data[battler.index].chosen_action = sprintf("Using item %s", getItemName(item))
            next
          end
        else
          @battle.pbRegisterItem(battler.index, item, battler.pokemonIndex)
          $ai_log_data[battler.index].chosen_action = sprintf("Using item %s", getItemName(item))
          next
        end
      end

      # dealing with mon that can't even choose fight menu
      if (0..3).none? { |i| @battle.pbCanChooseMove?(battler.index, i) }
        @battle.pbAutoChooseMove(battler.index)
        next
      end

      # MEGA/TERA/BURST
      if @aimondata[index].shouldUseBattleFormChange
        @battle.pbRegisterMegaEvolution(index) if @battle.pbCanMegaEvolve?(index)
        @battle.pbRegisterTerastallization(index) if @battle.pbCanTerastallize?(index)
        @battle.pbRegisterUltraBurst(index) if @battle.pbCanUltraBurst?(index)
      end

      # SELECT MOVE
      # chooseablemoves always has at least one move here since the case of it being empty has already been handled above
      if maxmovescore <= 0
        # prefer 0 scores over negative ones (negative means additional benefit to opponent or harm to attacker)
        preferredMoves = chooseablemoves.any? { |i| i[:score] == 0 } ? chooseablemoves.select { |i| i[:score] == 0 } : chooseablemoves
      else
        # Minmax choices depending on AI
        if @mondata.skill >= MEDIUMSKILL
          threshold = @mondata.skill >= BESTSKILL ? 1.5 : @mondata.skill >= HIGHSKILL ? 2 : 3
          newscore = @mondata.skill >= BESTSKILL ? 5 : @mondata.skill >= HIGHSKILL ? 10 : 15
          for scoreindex in 0...chooseablemoves.length
            chooseablemoves[scoreindex][:score] = newscore if chooseablemoves[scoreindex][:score] > newscore && chooseablemoves[scoreindex][:score] * threshold < maxmovescore
          end
        end
        # Find preferred moves
        preferredMoves = []
        for i in chooseablemoves
          if i[:score] >= maxmovescore * 0.95
            preferredMoves.push(i)
            preferredMoves.push(i) if i[:score] == maxmovescore # Doubly prefer the best move
          end
        end
      end

      # experimental: narrow down the list of possible move choices further by
      # checking preferredmoves for any which target the biggest threat active on the field.
      # that way, in cases of tied scores, the ai tries to focus down what it sees as the biggest issue
      # rather than -just- choosing randomly between the two.
      biggest_threat = index.odd? ? biggest_threat_player_side : biggest_threat_opponent_side
      preferredMoves = preferredMoves.select { |move| move[:target].include?(biggest_threat) } if preferredMoves.any? { |move| move[:target].include?(biggest_threat) }

      chosen = @battle.sample(preferredMoves)

      @battle.pbRegisterZMove(battler.index) if chosen[:zmove] && maxmovescore > 0
      @battle.pbRegisterMove(battler.index, chosen[:moveindex])
      @battle.pbRegisterTarget(battler.index, chosen[:target][0]) if @battle.doublebattle

      if maxmovescore <= 0
        $ai_log_data[battler.index].chosen_action = "Random move bc only bad decisions"
      else
        move = chosen[:zmove] && maxmovescore > 0 ? battler.zmoves[chosen[:moveindex]] : battler.moves[chosen[:moveindex]]
        $ai_log_data[battler.index].chosen_action = "Prefer " + move.name
        $ai_log_data[battler.index].chosen_action += " against " + @battle.battlers[chosen[:target][0]].logname if @battle.doublebattle
        $ai_log_data[battler.index].preferred_moves = extract_preferred_moves(battler, preferredMoves)
      end
    end
  end

  def getIndexToHardSwitchTo(battler, mondata, maxmovescore, log = false)
    PBDebug.dblog("\nConsidering hard switching...") if log
    if mondata.shouldswitchscore <= maxmovescore
      PBDebug.dblog("shouldswitchscore is not greater than maxmovescore. Aborted.") if log
      return nil
    end

    switchscores = []
    mondata.switchscore.each_with_index { |score, i|
      pokemon = @battle.pbPartySingleOwner(battler.index)[i]
      next if pokemon.nil? || pokemon.hp <= 0 || pokemon.isEgg? # Can be nil after yoink

      namestring = getMonName(pokemon.species).ljust(12) + " | " + score.to_s.ljust(10) + " | "

      if !shouldHardSwitch?(battler, i)
        PBDebug.dblog(namestring + "shouldHardSwitch returns false") if log
        next
      end

      threshold = maxmovescore > 0 ? 100 : 0 # arbitrary (much lower threshold to go for a switch if move scores are all <= 0)
      if score <= threshold
        PBDebug.dblog(namestring + "switchscore not higher than threshold") if log
        next
      end

      if [2, 3].include?(battler.index) &&
         @battle.pbGetOwnerIndex(battler.index) == @battle.pbGetOwnerIndex(battler.index % 2) &&
         @battle.choices[battler.index % 2][0] == :switch &&
         @battle.choices[battler.index % 2][1] == i
        PBDebug.dblog(namestring + "Already chosen by partner") if log
        next
      end

      PBDebug.dblog(namestring + "OK") if log
      switchscores.push([i, score])
    }
    return nil if switchscores.empty?

    # switchscores should look like this: [[0, -1000], [1, 100], [2, 400], [4, 50], [5, -10]]
    switchscores = switchscores.sort_by{ |i, score| score }.reverse # Sort by descending order of scores
    return switchscores.first[0]
  end

  def findChoosableMoves(battler, mondata)
    # Proc to be used later in the method for cumulating spread move scores
    addScores = proc { |score1, score2|
      # Do a simple addition if both scores are non-negative or both are negative
      next score1 + score2 if (score1 < 0) == (score2 < 0)
      # Otherwise (one score negative and other not) return the non-negative score but halved
      # A negative score means the target is immune and gets some benefit from it (eg, Fire move + Flash Fire), so this helps account for that better
      next (score1 < 0 ? score2 : score1) / 2.0 # EXPERIMENTAL
    }

    chooseablemoves = []
    allmoves = getAllBattlerMoves(battler, mondata)
    i = -1 # Overall index (0..7) (regular moves + z moves) for scoring
    for move in allmoves
      i += 1
      next if move.nil?

      moveindex = move.zmove ? battler.zmoves.index(move) : battler.moves.index(move) # Move slot index (0..3) for move selection
      next if !@battle.pbCanChooseMove?(battler.index, moveindex, zpower: move.zmove) # choice item/encore/taunt/torment

      # don't use simple damaging z moves if you have any killing regular moves
      next if move.zmove && chooseablemoves.any? { |hash| hash[:zmove] == false && hash[:score] >= 100 } && move.category != :status && !isZMoveWithExtraEffect?(move.move, battler)
      # don't use z move if partner has also selected z move (TODO: handle in coordinateActions)
      next if move.zmove && !@battle.pbCanZMove?(battler.index)

      # Wild pokemon can choose any move and can target either side in doubles.
      if !@battle.opponent && @battle.pbIsOpposing?(battler.index) && !(battler.isbossmon || battler.issosmon) && !move.zmove
        chooseablemoves.push({ moveindex: moveindex, target: [@battle.sample([0, 2])], score: mondata.scorearray[0][i], zmove: false })
        next
      end

      basemove = move
      move = pbChangeMove(move, battler)
      if @battle.doublebattle
        oi = battler.index ^ 3 # directly opposite opponent
        ci = battler.index ^ 1 # diagonally opposite opponent
        pi = battler.index ^ 2 # partner
        case battler.pbTarget(move)
          when :SingleNonUser, :NonUserPosition
            [oi, pi, ci].each do |targetindex|
              chooseablemoves.push({ moveindex: moveindex, target: [targetindex], score: mondata.scorearray[targetindex][i], zmove: move.zmove })
            end
          when :SingleOpposing
            [oi, ci].each do |targetindex|
              chooseablemoves.push({ moveindex: moveindex, target: [targetindex], score: mondata.scorearray[targetindex][i], zmove: move.zmove })
            end
          when :RandomOpposing, :User, :NoTarget, :BothSides, :AllBattlers
            if @battle.battlers[oi].hp > 0 && @battle.battlers[ci].hp > 0
              chooseablemoves.push({ moveindex: moveindex, target: [oi], score: (mondata.scorearray[ci][i] + mondata.scorearray[oi][i]) / 2, zmove: move.zmove })
            elsif @battle.battlers[oi].hp > 0
              chooseablemoves.push({ moveindex: moveindex, target: [oi], score: mondata.scorearray[oi][i], zmove: move.zmove })
            else
              chooseablemoves.push({ moveindex: moveindex, target: [ci], score: mondata.scorearray[ci][i], zmove: move.zmove })
            end
          when :AllOpposing, :OpposingSide
            addScore = addScores.call(mondata.scorearray[ci][i], mondata.scorearray[oi][i])
            chooseablemoves.push({ moveindex: moveindex, target: [oi, ci], score: addScore, zmove: move.zmove })
          when :AllNonUsers
            scoremult = 1.0
            if mondata.trainer && [:UMBTITANIA, :UMBAMARIA].include?(mondata.trainer.trainertype) && @battle.doublebattle && battler.index.odd?
              scoremult *= (1 + 2 * mondata.scorearray[pi][i] / 100.0)
            elsif battler.pbPartner.hp > 0 && pbTypeModNoMessages(move.pbType(battler), battler, battler.pbPartner, move).negative? # this means the partner is not only immune but also gains some advantage, eg, Water move + Water Absorb
              scoremult *= 2
            elsif battler.pbPartner.hp > 0 && (battler.pbPartner.hp.to_f > 0.1 * battler.pbPartner.totalhp || pbAIfaster?(move, nil, battler, battler.pbPartner)) && (!Rejuv || ![:SPACEAGOOD, :SPACEAGOOD_EASY].include?(battler.pokemon.bossID))
              scoremult = [(1 - 2 * mondata.scorearray[pi][i] / 100.0), 0].max # multiplier to control how much to arbitrarily care about hitting partner; lower cares more
              scoremult *= 0.5 if pbAIfaster?(move, nil, battler, battler.pbPartner) && mondata.scorearray[pi][i] > 50 # care more if we're faster and would knock it out before it attacks
            # elsif battler.pbPartner.hp > 0 && (battler.pbPartner.hp.to_f > 0.3 * battler.pbPartner.totalhp || pbAIfaster?(move, nil, battler, battler.pbPartner)) && (!Rejuv || ![:SPACEAGOOD, :SPACEAGOOD_EASY].include?(battler.pokemon.bossID))
            #   partnerDamageScore = [mondata.scorearray[pi][i] / 100.0, 1.0].min # score the damage dealt to partner, 0 means no damage dealt, 1 means the partner will be killed
            #   partnerDamageScore *= battler.pbPartner.hp.to_f / battler.pbPartner.totalhp.to_f # care less if the partner is already on low HP
            #   partnerDamageScore /= 2 unless pbAIfaster?(move, nil, battler, battler.pbPartner) # care less if the partner is faster than us
            #   scoremult = 1 - partnerDamageScore * 0.5 # Reduce move score by up to 50% according to the damage dealt to the partner
            end
            addScore = addScores.call(mondata.scorearray[ci][i], mondata.scorearray[oi][i])
            chooseablemoves.push({ moveindex: moveindex, target: [oi, ci, pi], score: scoremult * addScore, zmove: move.zmove })
          when :UserSide, :AllyBattlers
            chooseablemoves.push({ moveindex: moveindex, target: [oi, ci], score: Math.sqrt(mondata.scorearray[ci][i]**2 + mondata.scorearray[oi][i]**2).round, zmove: move.zmove })
          when :Partner
            chooseablemoves.push({ moveindex: moveindex, target: [pi], score: mondata.scorearray[pi][i], zmove: move.zmove })
          when :OppositeOpposing
            if @battle.battlers[oi].hp > 0
              chooseablemoves.push({ moveindex: moveindex, target: [oi], score: mondata.scorearray[oi][i], zmove: move.zmove })
            else
              chooseablemoves.push({ moveindex: moveindex, target: [ci], score: mondata.scorearray[ci][i], zmove: move.zmove })
            end
          when :UserOrPartner
            if @battle.battlers[oi].hp > 0 && @battle.battlers[ci].hp > 0
              chooseablemoves.push({ moveindex: moveindex, target: [battler.index], score: (mondata.scorearray[ci][i] + mondata.scorearray[oi][i]) / 2, zmove: move.zmove })
            elsif @battle.battlers[oi].hp > 0
              chooseablemoves.push({ moveindex: moveindex, target: [battler.index], score: mondata.scorearray[oi][i], zmove: move.zmove })
            else
              chooseablemoves.push({ moveindex: moveindex, target: [battler.index], score: mondata.scorearray[ci][i], zmove: move.zmove })
            end
          when :DragonDarts # curse whoever made this thing
            if pbDragonDartTargetting(battler, move, basemove).length > 1
              chooseablemoves.push({ moveindex: moveindex, target: [pi], score: [mondata.scorearray[ci][i], mondata.scorearray[oi][i]].max, zmove: move.zmove })
              addScore = addScores.call(mondata.scorearray[ci][i], mondata.scorearray[oi][i])
              chooseablemoves.push({ moveindex: moveindex, target: [oi, ci], score: addScore, zmove: move.zmove })
            else
              [oi, pi, ci].each do |targetindex|
                chooseablemoves.push({ moveindex: moveindex, target: [targetindex], score: mondata.scorearray[targetindex][i], zmove: move.zmove })
              end
            end
        end
      else
        oi = battler.index ^ 1 # only one opponent in single battles
        targetindex = battler.pbTarget(move) == :UserOrPartner ? battler.index : oi
        chooseablemoves.push({ moveindex: moveindex, target: [targetindex], score: mondata.scorearray[oi][i], zmove: move.zmove })
      end
    end
    return chooseablemoves
  end

  def coordinateActions(ai_l, ai_r, op_l, op_r) # changes some scores, doesn't choose
    return if @battle.battlers[ai_l].hp == 0 || @battle.battlers[ai_r].hp == 0 || (@battle.pbIsWild? && !(@battle.checkPartyBosses(@battle.pbPartySingleOwner(1)) || @battle.checkPartyBosses(@battle.pbPartySingleOwner(3))))

    PBDebug.dblog("\nCoordinating Actions")

    aimon1 = @battle.battlers[ai_l]
    aimon2 = @battle.battlers[ai_r]
    moves_1 = findChoosableMoves(aimon1, @aimondata[ai_l])
    moves_2 = findChoosableMoves(aimon2, @aimondata[ai_r])
    return if moves_1.length == 0 || moves_2.length == 0

    threatscore = threatAssessment(ai_l, ai_r, op_l, op_r)
    biggest_threat = threatscore.index(threatscore.max)
    threatStringNoOpp = @battle.battlers[biggest_threat ^ 2].hp == 0 ? "" : "   |    #{@battle.battlers[biggest_threat ^ 2].logname}: #{threatscore[biggest_threat ^ 2]}"
    PBDebug.dblog("Threat Values: #{@battle.battlers[biggest_threat].logname}: #{threatscore[biggest_threat]} #{threatStringNoOpp}")
    PBDebug.dblog("Biggest Threat: #{@battle.battlers[biggest_threat].logname}")

    # find targets of all killing moves
    killing_moves = [[], [], [], []]
    for i in [ai_l, ai_r]
      @aimondata[i].roughdamagearray.each_with_index { |array, monindex|
        next if monindex == ai_l || monindex == ai_r

        array.each_with_index { |obj, moveindex|
          if obj >= 100 && @aimondata[i].scorearray[monindex][moveindex] > 80 # killing move + not awful score
            killing_moves[i].push(monindex)
          end
        }
      }
    end
    # shape the array in something more usable
    killing_moves.map! { |arr| arr.uniq }
    killing_moves.map!.with_index { |arr, index|
      if arr.length == 2
        :both
      elsif arr[0] == op_l
        :left
      elsif arr[0] == op_r
        :right
      elsif index == op_l || index == op_r
        :_
      else
        :none
      end
    }
    ai_killing_moves = [killing_moves[ai_l], killing_moves[ai_r]]
    debuglogkillingmoves = killing_moves.map.with_index { |kills, index|
      case kills
        when :both then "#{@battle.battlers[index].logname} KOs Both Opponents"
        when :left then "#{@battle.battlers[index].logname} KOs #{@battle.battlers[op_l].hp <= 0 ? "No Mon" : @battle.battlers[op_l].logname}"
        when :right then "#{@battle.battlers[index].logname} KOs #{@battle.battlers[op_r].hp <= 0 ? "No Mon" : @battle.battlers[op_r].logname}"
        when :_ then "#{@battle.battlers[index].hp == 0 ? "N/A" : (@battle.battlers[index].logname + " is Opponent")}"
        when :none then "#{@battle.battlers[index].logname} KOs No Opponents"
      end
    }
    PBDebug.dblog("KOs: #{debuglogkillingmoves}")

    # if only one of them has a killing move, make it so the other one doesn't target the same mon
    if (killing_moves[ai_l] != :none && killing_moves[ai_r] == :none) || (killing_moves[ai_r] != :none && killing_moves[ai_l] == :none)
      PBDebug.dblog("Only one mon can KO an opponent.")
      # battlerindexes
      ai_leader = killing_moves[ai_l] != :none ? ai_l : ai_r
      ai_follow = ai_leader ^ 2

      leader_mon = @battle.battlers[ai_leader]
      follow_mon = @battle.battlers[ai_follow]
      opp_left_mon = @battle.battlers[op_l]
      opp_righ_mon = @battle.battlers[op_r]
      PBDebug.dblog("Leader: #{leader_mon.logname}   |   Follower: #{follow_mon.logname}")

      # get the move it will choose
      bestmove, target = findBestMoveAndTarget(leader_mon, ai_leader == ai_l ? moves_1 : moves_2)
      bestmoves = [nil, nil, nil, nil]
      bestmoves[leader_mon.index] = bestmove
      PBDebug.dblog("#{leader_mon.logname} Best Move: #{bestmove.name} targeting #{@battle.battlers[target].logname}")

      if bestmove.pbIsDamaging? && bestmove.priorityCheck(leader_mon) == 0
        decrease_by = 1.0
        speedorder = pbMoveOrderAI(bestmoves)
        debugspeedorder = speedorder.map { |index| @battle.battlers[index].logname }
        PBDebug.dblog("Speed Order: #{debugspeedorder}")
        case speedorder
          # leader fastest and no specific way to save follower before follower attacks
          when [ai_leader, ai_follow, op_l, op_r] then decrease_by = 0.4
          when [ai_leader, op_l, op_r, ai_follow] then decrease_by = 0.4
          when [ai_leader, op_r, op_l, ai_follow] then decrease_by = 0.4
          when [ai_follow, ai_leader, op_l, op_r] then decrease_by = 0.4
          when [ai_follow, ai_leader, op_r, op_l] then decrease_by = 0.4
          when [ai_leader, ai_follow, op_r, op_l] then decrease_by = 0.4

          # leader slowest, but survives both hits of the opponent
          when [op_l, op_r, ai_follow, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
          when [op_r, op_l, ai_follow, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
          when [op_l, ai_follow, op_r, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
          when [op_r, ai_follow, op_l, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
          when [ai_follow, op_l, op_r, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
          when [ai_follow, op_r, op_l, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
          when [op_r, op_l, ai_leader, ai_follow] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
          when [op_l, op_r, ai_leader, ai_follow] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp

          # leader survives a hit from the left opp before targetting their mon, and can't save follower
          when [op_l, ai_leader, ai_follow, op_r] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) < leader_mon.hp
          when [ai_follow, op_l, ai_leader, op_r] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) < leader_mon.hp
          when [op_l, ai_follow, ai_leader, op_r] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) < leader_mon.hp

          # leader survives a hit from the left opp before targetting their mon, and can't save follower
          when [op_r, ai_leader, ai_follow, op_l] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
          when [ai_follow, op_r, ai_leader, op_l] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
          when [op_r, ai_follow, ai_leader, op_l] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp

          # leader is first to move and can save follower from taking a hit before follower moves, so target the other slot unless that slot is unimportant
          when [ai_leader, op_l, ai_follow, op_r] then decrease_by = 0.4
          when [ai_leader, op_r, ai_follow, op_l] then decrease_by = 0.4

          # leader can save follower from taking a hit before follower moves but leader is not first to move so there is uncertainty, hence lesser score decrease
          when [op_l, ai_leader, op_r, ai_follow] then decrease_by = 0.7
          when [op_r, ai_leader, op_l, ai_follow] then decrease_by = 0.7
        end

        # change the targetting of the biggest target if it stops the follower from getting hit
        case speedorder
          # leader moves first, then the mon that can be killed then the follower, then the last
          when [ai_leader, op_l, ai_follow, op_r], [ai_leader, op_r, ai_follow, op_l]
            if killing_moves[ai_leader] == :both && checkAIdamage(follow_mon, @battle.battlers[speedorder[1]]) >= follow_mon.hp
              biggest_threat = speedorder[1] if threatscore[speedorder[3]] <= 2 * threatscore[speedorder[1]]
            end
          # if the leader is gonna survive a hit from the mon moving before it, but the follower isn't from the mon after it, kill the mon that moves aftere the follower
          when [op_l, ai_leader, op_r, ai_follow], [op_r, ai_leader, op_l, ai_follow]
            if killing_moves[ai_leader] == :both && checkAIdamage(leader_mon, @battle.battlers[speedorder[0]]) < leader_mon.hp && checkAIdamage(follow_mon, @battle.battlers[speedorder[2]]) >= follow_mon.hp
              biggest_threat = threatscore[speedorder[0]] >= 2 * threatscore[speedorder[2]] ? speedorder[0] : speedorder[2]
            end
        end

        scoreDecrease(biggest_threat, killing_moves, decrease_by, ai_leader)
      elsif bestmove.priorityCheck(leader_mon) > 0
        # priority moves fuck up just about everything
        scoreDecrease(biggest_threat, killing_moves, 0.2, ai_leader)
      elsif [:AllOpposing, :AllNonUsers].include?(leader_mon.pbTarget(bestmove))
        # fuck it if i know
      end
    end

    # if both of them have killing move determine who should target who, mostly just don't target both the same
    if killing_moves[ai_l] != :none && killing_moves[ai_r] != :none
      # get the moves they will choose
      bestmove1, target1 = findBestMoveAndTarget(aimon1, moves_1)
      bestmove2, target2 = findBestMoveAndTarget(aimon2, moves_2)
      bestmoves = [nil, nil, nil, nil]
      bestmoves[ai_l] = bestmove1
      bestmoves[ai_r] = bestmove2
      PBDebug.dblog("#{aimon1.logname} Best Move: #{bestmove1.name} targeting #{@battle.battlers[target1].logname}")
      PBDebug.dblog("#{aimon2.logname} Best Move: #{bestmove2.name} targeting #{@battle.battlers[target2].logname}")

      # make sure the best move isn't a status move or switching/item
      if bestmove2.pbIsDamaging? && bestmove1.pbIsDamaging?
        speedorder = pbMoveOrderAI(bestmoves)
        debugspeedorder = speedorder.map { |index| @battle.battlers[index].logname }
        PBDebug.dblog("Speed Order: #{debugspeedorder}")
        targetting_done = false
        case speedorder
          when [ai_l, ai_r, op_r, op_l], [ai_r, ai_l, op_r, op_l], [ai_l, ai_r, op_l, op_r], [ai_r, ai_l, op_l, op_r] # ai,ai,player,player

          when [ai_l, op_l, ai_r, op_r], [ai_l, op_r, ai_r, op_l], [ai_r, op_l, ai_l, op_r], [ai_r, op_r, ai_l, op_l] # ai,player,ai,player
            if ai_killing_moves == [:both, :both]
              @aimondata[speedorder[0]].scorearray[speedorder[3]].map! { |score| score * 0.4 }
              @aimondata[speedorder[2]].scorearray[speedorder[1]].map! { |score| score * 0.4 }
              PBDebug.dblog("First mon KOs first opp, second mon KOs second opp")
              PBDebug.dblog("#{debugspeedorder[0]} scores x0.4 against #{debugspeedorder[3]} and #{debugspeedorder[2]} scores x0.4 against #{debugspeedorder[1]}")
              # speedorder[0] targets speedorder[1], speedorder[2] targets speedorder[3]
              targetting_done = true
            elsif (speedorder == [ai_l, op_l, ai_r, op_r] && ai_killing_moves == [:both, :left]) ||
                  (speedorder == [ai_l, op_r, ai_r, op_l] && ai_killing_moves == [:both, :right]) ||
                  (speedorder == [ai_r, op_l, ai_l, op_r] && ai_killing_moves == [:left, :both]) ||
                  (speedorder == [ai_r, op_r, ai_l, op_l] && ai_killing_moves == [:right, :both])
              if checkAIdamage(@battle.battlers[speedorder[2]], @battle.battlers[speedorder[1]]) >= @battle.battlers[speedorder[2]].hp
                @aimondata[speedorder[0]].scorearray[speedorder[3]].map! { |score| score * 0.4 }
                @aimondata[speedorder[2]].scorearray[speedorder[1]].map! { |score| score * 0.7 }
                PBDebug.dblog("First mon KOs first opp, second mon targets second opp but does not KO")
                PBDebug.dblog("#{debugspeedorder[0]} scores x0.4 against #{debugspeedorder[3]} and #{debugspeedorder[2]} scores x0.7 against #{debugspeedorder[1]}")
                # speedorder[0] targets speedorder[1], speedorder[2] gets score decreased for speedorder[1]
                targetting_done = true
              end
            elsif ai_killing_moves == [:left, :left] || ai_killing_moves == [:right, :right]
              if checkAIdamage(@battle.battlers[speedorder[2]], @battle.battlers[speedorder[1]]) >= @battle.battlers[speedorder[2]].hp
                killable = ai_killing_moves == [:left, :left] ? op_l : op_r
                nonkillable = killable == op_l ? op_r : op_l
                @aimondata[speedorder[0]].scorearray[nonkillable].map! { |score| score * 0.4 }
                @aimondata[speedorder[2]].scorearray[killable].map! { |score| score * 0.7 }
                PBDebug.dblog("Both mons KO same opp, but fast opp KO's slow mon. Fast mon targets KO-able opp")
                PBDebug.dblog("#{debugspeedorder[0]} scores x0.4 against #{@battle.battlers[nonkillable].logname} and #{debugspeedorder[2]} scores x0.7 against #{@battle.battlers[killable].logname}")
                # speedorder[0] targets killable, speedorder[2] gets score decreased for killable
                targeting_done = true
              end
            end

          when [ai_l, op_l, op_r, ai_r], [ai_l, op_r, op_l, ai_r], [ai_r, op_l, op_r, ai_l], [ai_r, op_r, op_l, ai_l] # ai,player,player,ai
            case ai_killing_moves
              when [:both, :both]
                @aimondata[speedorder[0]].scorearray[biggest_threat ^ 2].map! { |score| score * 0.7 }
                @aimondata[speedorder[3]].scorearray[biggest_threat].map! { |score| score * 0.7 }
                PBDebug.dblog("Fast mon targets biggest threat, slow mon targets lesser threat")
                PBDebug.dblog("#{debugspeedorder[0]} scores x0.7 against #{@battle.battlers[biggest_threat ^ 2].logname} and #{debugspeedorder[3]} scores x0.7 against #{@battle.battlers[biggest_threat].logname}")
                # speedorder[0] targets biggest threat, speedorder[3] targets other
                targetting_done = true
              when [:left, :left]
                @aimondata[speedorder[0]].scorearray[op_r].map! { |score| score * 0.7 }
                @aimondata[speedorder[3]].scorearray[op_l].map! { |score| score * 0.4 }
                PBDebug.dblog("Fast mon targets KOable opp, slow mon targets other opp")
                PBDebug.dblog("#{debugspeedorder[0]} scores x0.7 against #{@battle.battlers[op_r].logname} and #{debugspeedorder[3]} scores x0.7 against #{@battle.battlers[op_l].logname}")
                # speedorder[0] targets the one they can kill, speedorder[3] targets other
                targetting_done = true
              when [:right, :right]
                @aimondata[speedorder[0]].scorearray[op_l].map! { |score| score * 0.7 }
                @aimondata[speedorder[3]].scorearray[op_r].map! { |score| score * 0.4 }
                PBDebug.dblog("Fast mon targets KOable opp, slow mon targets other opp")
                PBDebug.dblog("#{debugspeedorder[0]} scores x0.7 against #{@battle.battlers[op_l].logname} and #{debugspeedorder[3]} scores x0.7 against #{@battle.battlers[op_r].logname}")
                # speedorder[0] targets the one they can kill, speedorder[3] targets other
                targetting_done = true
            end
          when [op_l, ai_l, ai_r, op_r], [op_l, ai_r, ai_l, op_r], [op_r, ai_l, ai_r, op_l], [op_r, ai_r, ai_l, op_l] # player,ai,ai,player
            case ai_killing_moves
              when [:both, :both], [:left, :left], [:right, :right]
                # don't edit the scores, who knows which mon will live
                targetting_done = true
            end
          when [op_l, ai_l, op_r, ai_r], [op_l, ai_r, op_r, ai_l], [op_r, ai_l, op_l, ai_r], [op_r, ai_r, op_l, ai_l] # player,ai,player,ai
            case ai_killing_moves
              when [:both, :both]
                @aimondata[speedorder[1]].scorearray[speedorder[0]].map! { |score| score * 0.7 }
                @aimondata[speedorder[3]].scorearray[speedorder[2]].map! { |score| score * 0.7 }
                PBDebug.dblog("Try to KO second opp before it moves")
                PBDebug.dblog("#{debugspeedorder[1]} scores x0.7 against #{debugspeedorder[0]} and #{debugspeedorder[3]} scores x0.7 against #{debugspeedorder[2]}")
                # speedorder[1] targets speedorder[2], speedorder[3] targets speedorder[0]
                targetting_done = true
              when [:left, :left], [:right, :right]
                if checkAIdamage(@battle.battlers[speedorder[1]], @battle.battlers[speedorder[0]]) >= @battle.battlers[speedorder[1]].hp
                  chosen_index = ai_killing_moves == [:left, :left] ? op_l : op_r
                  @aimondata[speedorder[3]].scorearray[chosen_index].map! { |score| score * 0.7 }
                  PBDebug.dblog("First mon targets KOable opp, second mon targets other")
                  PBDebug.dblog("#{debugspeedorder[3]} scores x0.7 against #{debugspeedorder[chosen_index]}")
                  targetting_done = true
                else
                  # don't edit the scores, who knows which mon will live
                  targetting_done = true
                end
            end
          when [op_l, op_r, ai_l, ai_r], [op_r, op_l, ai_l, ai_r], [op_l, op_r, ai_r, ai_l], [op_r, op_l, ai_r, ai_l] # player,player,ai,ai
            case ai_killing_moves
              when [:both, :both]
                # don't edit the scores, who knows which mon will live
                targetting_done = true
              when [:left, :left], [:right, :right]
                # don't edit the scores, who knows which mon will live
                targetting_done = true
            end
        end
        if !targetting_done
          case ai_killing_moves
            when [:both, :both]
              # just target differently
              if @battle.pbRandom(2) == 0
                @aimondata[ai_l].scorearray[op_l].map! { |score| score * 0.7 }
                @aimondata[ai_r].scorearray[op_r].map! { |score| score * 0.7 }
                PBDebug.dblog("Both mons KO both opps, target differently")
                PBDebug.dblog("#{@battle.battlers[ai_l].logname} scores x0.7 against #{@battle.battlers[op_l].logname} and #{@battle.battlers[ai_r].logname} scores x0.7 against #{@battle.battlers[op_r].logname}")
              else
                @aimondata[ai_l].scorearray[op_r].map! { |score| score * 0.7 }
                @aimondata[ai_r].scorearray[op_l].map! { |score| score * 0.7 }
                PBDebug.dblog("Both mons KO both opps, target differently")
                PBDebug.dblog("#{@battle.battlers[ai_l].logname} scores x0.7 against #{@battle.battlers[op_r].logname} and #{@battle.battlers[ai_r].logname} scores x0.7 against #{@battle.battlers[op_l].logname}")
              end
            when [:left, :both]
              # only need to change 3 to target 2
              @aimondata[ai_r].scorearray[op_l].map! { |score| score * 0.7 }
              PBDebug.dblog("One mon KOs both opps, target differently")
              PBDebug.dblog("#{@battle.battlers[ai_r].logname} scores x0.7 against #{@battle.battlers[op_l].logname}")
            when [:right, :both]
              # only need to change 3 to target 0
              @aimondata[ai_r].scorearray[op_r].map! { |score| score * 0.7 }
              PBDebug.dblog("One mon KOs both opps, target differently")
              PBDebug.dblog("#{@battle.battlers[ai_r].logname} scores x0.7 against #{@battle.battlers[op_r].logname}")
            when [:both, :left]
              # only need to change 1 to target 2
              @aimondata[ai_l].scorearray[op_l].map! { |score| score * 0.7 }
              PBDebug.dblog("One mon KOs both opps, target differently")
              PBDebug.dblog("#{@battle.battlers[ai_l].logname} scores x0.7 against #{@battle.battlers[op_l].logname}")
            when [:both, :right]
              # only need to change 1 to target 0
              @aimondata[ai_l].scorearray[op_r].map! { |score| score * 0.7 }
              PBDebug.dblog("One mon KOs both opps, target differently")
              PBDebug.dblog("#{@battle.battlers[ai_l].logname} scores x0.7 against #{@battle.battlers[op_r].logname}")
            when [:left, :left], [:right, :right]
              killable = ai_killing_moves == [:left, :left] ? op_l : op_r
              nonkillable = killable == op_l ? op_r : op_l
              # check which has highest score targetting killable
              killer = @aimondata[ai_l].scorearray[killable].max > @aimondata[ai_r].scorearray[killable].max ? ai_l : ai_r
              nonkiller = killer == ai_l ? ai_r : ai_l
              @aimondata[killer].scorearray[nonkillable].map! { |score| score * 0.4 }
              @aimondata[nonkiller].scorearray[killable].map! { |score| score * 0.4 }
              PBDebug.dblog("Both mons KO the same opp, but #{@battle.battlers[nonkiller].logname} has the worse scored move")
              PBDebug.dblog("#{@battle.battlers[killer].logname} scores x0.4 against #{@battle.battlers[nonkillable].logname} and #{@battle.battlers[nonkiller].logname} scores x0.4 against #{@battle.battlers[killable].logname}")
            when [:left, :right], [:right, :left]
              # nothing to do here
          end
        end
      end
    end

    ### Special considerations
    moves_1.sort! { |a, b| b[:score] <=> a[:score] }
    moves_2.sort! { |a, b| b[:score] <=> a[:score] }
    bestindex1 = moves_1[0][:moveindex]
    bestindex2 = moves_2[0][:moveindex]
    besttarget1 = moves_1[0][:target] # array of indices
    besttarget2 = moves_2[0][:target] # array of indices
    bestmove1 = moves_1[0][:zmove] ? aimon1.zmoves[bestindex1] : aimon1.moves[bestindex1]
    bestmove2 = moves_2[0][:zmove] ? aimon2.zmoves[bestindex2] : aimon2.moves[bestindex2]
    # Find the next best moves for both AI (different move or different target than best move)
    nextbest1 = moves_1.find { |movehash| movehash[:moveindex] != bestindex1 || !movehash[:target].intersect?(besttarget1) }
    nextbest2 = moves_2.find { |movehash| movehash[:moveindex] != bestindex2 || !movehash[:target].intersect?(besttarget2) }

    # defense stat dropping moves in coordination (screech, fake tears)
      # check if stat-drop moves functioncodes include either of the bestmoves function codes, then check for which of the two is the faster AI pokemon
      # check if targets match/overlap
      # check if moves match damagecategories
      # if either are wrong, divert from fake tears/screech set up
    if ([0x4C, 0x4F].include?(bestmove1.function) && ai_leader == ai_l) || ([0x4C, 0x4F].include?(bestmove2.function) && ai_leader == ai_r)
      leaderbestmove = ai_leader == ai_l ? bestmove1 : bestmove2
      followerbestmove = ai_leader == ai_l ? bestmove2 : bestmove1
      leaderbestindex = ai_leader == ai_l ? bestindex1 : bestindex2
      followerbestindex = ai_leader == ai_l ? bestindex2 : bestindex1
      leaderbesttarget = ai_leader == ai_l ? besttarget1 : besttarget2
      followerbesttarget = ai_leader == ai_l ? besttarget2 : besttarget1
      if !followerbesttarget.intersect?(leaderbesttarget) || !movesMatchCategories?(leaderbestmove, followerbestmove, ai_leader, ai_follow)
        @aimondata[ai_leader].scorearray.map! { |a| a.map!.with_index { |b, i| i == leaderbestindex ? 0 : b } }
        PBDebug.dblog("Faster mon #{@battle.battlers[ai_leader].logname} won't use #{leaderbestmove.name} because either targets or damage categories don't match with slower mon #{@battle.battlers[ai_follow].logname}'s best move #{followerbestmove.name}.")
      end
    end

    # one wants to use helping hand
    helper = nil
    if :HELPINGHAND == bestmove1.move && (bestmove2.pbIsStatus? || bestmove2.pbFixedDamageMove?)
      helper = @battle.battlers[ai_l]
      @aimondata[ai_l].scorearray.map! { |a| a.map!.with_index { |b, i| i == bestindex1 ? 0 : b } }
    elsif :HELPINGHAND == bestmove2.move && (bestmove1.pbIsStatus? || bestmove1.pbFixedDamageMove?)
      helper = @battle.battlers[ai_r]
      @aimondata[ai_r].scorearray.map! { |a| a.map!.with_index { |b, i| i == bestindex2 ? 0 : b } }
    end
    PBDebug.dblog("#{helper.logname} likes Helping Hand, #{helper.pbPartner.logname} likes a non-damaging/fixed-damage move. Don't use Helping Hand.") if helper

    # both want to use moves that interfere with each other
    unless nextbest1.nil? && nextbest2.nil?
      ### Non-targeted moves, no need to check for target
      if movesInterfereNonTargeted?(bestmove1.move, bestmove2.move, ai_l)
        mon = chooseBetterNextBestMoveUser(ai_l, ai_r, nextbest1, nextbest2)
        bestindex = mon == ai_l ? bestindex1 : bestindex2
        @aimondata[mon].scorearray.map! { |a| a.map!.with_index { |b, moveindex| moveindex == bestindex ? 0 : b } }
        PBDebug.dblog("Both mons like interfering non-targeted moves #{bestmove1.name} and #{bestmove2.name}). #{@battle.battlers[mon].logname} has next-best move and will not use #{(mon == ai_l ? bestmove1 : bestmove2).name}.")
      end

      ### Targeted moves, need to check for target of best move too
      if besttarget1.intersect?(besttarget2) && movesInterfereTargeted?(bestmove1.move, bestmove2.move)
        mon = chooseBetterNextBestMoveUser(ai_l, ai_r, nextbest1, nextbest2)
        bestindex = mon == ai_l ? bestindex1 : bestindex2
        besttarget = mon == ai_l ? besttarget1 : besttarget2
        @aimondata[mon].scorearray.map!.with_index do |a, oppindex|
          a.map!.with_index { |b, moveindex|
            moveindex == bestindex && besttarget.include?(oppindex) ? 0 : b
          }
        end
        PBDebug.dblog("Both mons like interfering targeted moves against the same opp (#{bestmove1.name} and #{bestmove2.name}). #{@battle.battlers[mon].logname} has next-best move and will not use #{(mon == ai_l ? bestmove1 : bestmove2).name}.")
      end
    end

    # one is using eq and other wants to roost
    rooster = nil
    if :EARTHQUAKE == bestmove1.move && :ROOST == bestmove2.move
      if !pbAIfaster?(bestmove1, bestmove2, aimon1, aimon2) && canGroundMoveHit?(aimon2, true, moldBreakerCheck(aimon1, aimon2, bestmove1))
        rooster = @battle.battlers[ai_r]
        @aimondata[ai_r].scorearray.map! { |a| a.map!.with_index { |b, i| i == bestindex2 ? 0 : b } }
      end
    elsif :EARTHQUAKE == bestmove2.move && :ROOST == bestmove1.move
      if !pbAIfaster?(bestmove2, bestmove1, aimon2, aimon1) && canGroundMoveHit?(aimon1, true, moldBreakerCheck(aimon2, aimon1, bestmove2))
        rooster = @battle.battlers[ai_l]
        @aimondata[ai_l].scorearray.map! { |a| a.map!.with_index { |b, i| i == bestindex1 ? 0 : b } }
      end
    end
    PBDebug.dblog("#{rooster.pbPartner.logname} wants to use Earthquake while #{rooster.logname} wants to use Roost. #{rooster.logname} is faster and will not use Roost.") if rooster

    # one is using beat up on the other who has justified, and the beat up user is faster
    for beatup_user_index in [ai_l, ai_r]
      just_user_index = beatup_user_index == ai_l ? ai_r : ai_l
      beatup_user, just_user = @battle.battlers[beatup_user_index], @battle.battlers[just_user_index]
      bestmove = beatup_user_index == ai_l ? bestmove1 : bestmove2
      besttarget = beatup_user_index == ai_l ? besttarget1 : besttarget2
      if bestmove.move == :BEATUP && besttarget.include?(just_user_index) && just_user.ability == :JUSTIFIED && pbAIfaster?(bestmove, nil, beatup_user, just_user)
        finalAtkStage = [just_user.stages[PBStats::ATTACK] + beatup_user.pbBeatUpParty.length, 6].min
        multiplier = PBStats::StageMul[finalAtkStage + 6] / PBStats::StageMul[just_user.stages[PBStats::ATTACK] + 6]
        @aimondata[just_user_index].scorearray.map!.with_index { |array, targetindex|
          array.map!.with_index { |score, moveindex|
            move = just_user.moves[moveindex]
            move && move.pbIsPhysical?(just_user) && !move.pbIsPriorityMoveAI(just_user) ? score * multiplier : score
          }
        }
        PBDebug.dblog("#{beatup_user.logname} wants to use Beat Up on #{just_user.logname} and is faster than it. #{just_user.logname}'s non-priority physical move scores will be adjusted to accomodate for the extra power.")
        break
      end
    end

    # one is using follow me / rage powder / ally switch (idk what to do with spotlight)
    for redirector_index in [ai_l, ai_r]
      other_mon_index = redirector_index == ai_l ? ai_r : ai_l
      redirector, other_mon = @battle.battlers[redirector_index], @battle.battlers[other_mon_index]
      bestmove = redirector_index == ai_l ? bestmove1 : bestmove2
      if [:FOLLOWME, :RAGEPOWDER, :ALLYSWITCH].include?(bestmove.move)
        @aimondata[other_mon_index].scorearray.map!.with_index { |array, targetindex|
          array.map!.with_index { |score, moveindex|
            move = other_mon.moves[moveindex]
            next score if !move
            next score * 1.5 if PBStuff::SETUPMOVE.include?(move.move)
            next score * 0.5 if move.pbIsStatus? || move.pbIsPriorityMoveAI(other_mon)
            next score * 0.1 if [:FOLLOWME, :RAGEPOWDER].include?(bestmove.move) && PBStuff::PROTECTMOVE.include?(move.move)
            next score
          }
        }
        PBDebug.dblog("#{redirector.logname} wants to use #{bestmove.name}. #{other_mon.logname}'s setup move scores increased by x1.5, and non-setup priority and status move scores decreased by x0.5.")
        break
      end
    end

    ### Coordination for when one mon wants to switch
    ### Needs to be at end because move score changes from earlier in the method also affect whether mons want to switch
    ### Ofc, changes from this section will affect the end result too
    moves_1 = findChoosableMoves(aimon1, @aimondata[ai_l])
    moves_2 = findChoosableMoves(aimon2, @aimondata[ai_r])
    for switcher in [ai_l, ai_r]
      switchermoves = switcher == ai_l ? moves_1 : moves_2
      maxmovescore = switchermoves.max { |a1, a2| a1[:score] <=> a2[:score] }[:score]
      if getIndexToHardSwitchTo(@battle.battlers[switcher], @aimondata[switcher], maxmovescore)
        partner = switcher == ai_l ? ai_r : ai_l
        # Decrease score of all of the partner's non-AllNonUsers moves that target the switcher
        @aimondata[partner].scorearray.map!.with_index { |array, targetindex|
          targetindex != switcher ? array : array.map!.with_index { |score, moveindex|
            move = @battle.battlers[partner].moves[moveindex]
            move && @battle.battlers[partner].pbTarget(move) != :AllNonUsers ? score * 0.2 : score
          }
        }
        PBDebug.dblog("#{@battle.battlers[switcher].logname} wants to switch. Scores of all of #{@battle.battlers[partner].logname}'s (non-AllNonUsers) moves targeting it are reduced by x0.2.")
        break
      end
    end
  end

  def movesMatchCategories?(move1, move2, move1user, move2user)
    return false if move2.pbFixedDamageMove?
    return true if move1.function == 0x4C && move2.pbIsPhysical?(move2user) # screech
    return true if move1.function == 0x4F && move2.pbIsSpecial?(move2user) # fake tears
    return false
  end

  def movesInterfereNonTargeted?(move1, move2, ai_l)
    # Redirecting moves
    return true if [move1, move2].all? { |move| [:FOLLOWME, :RAGEPOWDER, :ALLYSWITCH, :SPOTLIGHT].include?(move) }
    # Party healing moves
    return true if [move1, move2].all? { |move| [:HEALBELL, :AROMATHERAPY].include?(move) }
    # Weather moves
    return true if [move1, move2].all? { |move| (PBStuff::WEATHERMOVE - [:CHILLYRECEPTION]).include?(move) }
    # Terrain moves
    return true if [move1, move2].all? { |move| PBStuff::TERRAINMOVE.include?(move) }
    return false unless move1 == move2

    # Opposing Side moves
    oppSide = @battle.battlers[ai_l].pbOpposingSide
    return true if move1 == :SPIKES && oppSide.effects[:Spikes] >= 2
    return true if move1 == :TOXICSPIKES && oppSide.effects[:ToxicSpikes] >= 1
    return true if [:STEALTHROCK, :STICKYWEB, :SHADOWSHED].include?(move1)
    # User Side moves
    return true if [:LIGHTSCREEN, :REFLECT, :AURORAVEIL, :ARENITEWALL, :MIST, :LUCKYCHANT, :SAFEGUARD, :TAILWIND, :QUICKGUARD, :WIDEGUARD, :CRAFTYSHIELD, :MATBLOCK].include?(move1)
    # Both Sides moves
    return true if [:GRAVITY, :TRICKROOM, :WONDERROOM, :MAGICROOM, :MUDSPORT, :WATERSPORT, :HAZE, :FAIRYLOCK, :IONDELUGE, :COURTCHANGE].include?(move1)
    # All Battlers moves
    return true if [:PERISHSONG].include?(move1)
    return false
  end

  def movesInterfereTargeted?(move1, move2)
    return true if [move1, move2].all? { |move| PBStuff::STATUSCONDITIONMOVE.include?(move) }
    return true if [move1, move2].all? { |move| (PBStuff::CONFUMOVE - [:CHATTER, :DYNAMICPUNCH]).include?(move) }
    return true if [move1, move2].all? { |move| [:UPPERHAND, :FAKEOUT].include?(move) }
    return true if [move1, move2].all? { |move| [:KNOCKOFF, :POLTERGEIST].include?(move) }
    return false unless move1 == move2
    return true if [:ENCORE, :TAUNT, :TORMENT, :DISABLE].include?(move1)
    return false
  end

  def findBestMoveAndTarget(mon, moves)
    bestmove = moves.sort{ |a, b| b[:score] <=> a[:score] }.first
    target = bestmove[:target][0]
    bestmoveMoveObject = bestmove[:zmove] ? mon.zmoves[bestmove[:moveindex]] : mon.moves[bestmove[:moveindex]]
    return bestmoveMoveObject, target
  end

  # Used for choosing which AI battler and move to deduct the score from when both AI battlers want to use the same move
  def chooseBetterNextBestMoveUser(ai_l, ai_r, nextbest1, nextbest2)
    return ai_r if nextbest1.nil?
    return ai_l if nextbest2.nil?
    return ai_l if nextbest1[:score] > nextbest2[:score]
    return ai_r
  end

  def threatAssessment(ai_l, ai_r, op_l, op_r)
    # Dont care about it if one of the player mons is dead
    if ai_l.odd?
      return [1, -1, 1, -1] if @battle.battlers[op_l].hp <= 0 && @battle.battlers[op_r].hp <= 0
      return [0, -1, 1, -1] if @battle.battlers[op_l].hp <= 0
      return [1, -1, 0, -1] if @battle.battlers[op_r].hp <= 0
    else
      return [-1, 1, -1, 1] if @battle.battlers[op_l].hp <= 0 && @battle.battlers[op_r].hp <= 0
      return [-1, 0, -1, 1] if @battle.battlers[op_l].hp <= 0
      return [-1, 1, -1, 0] if @battle.battlers[op_r].hp <= 0
    end

    threatscore = [0, 0, 0, 0]
    threatscore[ai_l] = -1
    threatscore[ai_r] = -1
    threatscore[op_l] = 1
    threatscore[op_r] = 1

    # find out which of the AI mons are still Alive
    aimons = [@battle.battlers[ai_l], @battle.battlers[ai_r]].find_all { |mon| mon && mon.hp > 0 }

    @battle.battlers.each_with_index { |opp, i|
      next if i == ai_l || i == ai_r # only opponents need to be assessed

      # Base stat total
      threatscore[i] *= pbBaseStatTotal(opp.species, opp.form) / 200.0
      # Level
      threatscore[i] *= (opp.level.to_f / ((aimons.sum { |mon| mon.level }) / aimons.length))**2
      # Mega
      threatscore[i] *= 1.1 if opp.isMega?
      # Boosts
      threatscore[i] *= 1 + 0.2 * opp.stages[PBStats::ATTACK] if opp.attack > opp.spatk
      threatscore[i] *= 1 + 0.2 * opp.stages[PBStats::SPATK] if opp.spatk > opp.attack
      threatscore[i] *= 1 + 0.05 * opp.stages[PBStats::DEFENSE] if aimons.any? { |mon| mon.attack > mon.spatk }
      threatscore[i] *= 1 + 0.05 * opp.stages[PBStats::SPDEF] if aimons.any? { |mon| mon.spatk > mon.attack }
      threatscore[i] *= 1 + 0.10 * opp.stages[PBStats::SPEED] if (opp.stages[PBStats::SPEED] > 0) ^ @battle.state.effects[:TrickRoom] != 0
      threatscore[i] *= [1 + 0.20 * opp.stages[PBStats::ACCURACY], 0.3].max if opp.stages[PBStats::ACCURACY] < 0
      threatscore[i] *= 1 + 0.20 * opp.stages[PBStats::EVASION] if opp.stages[PBStats::EVASION] > 0
      threatscore[1] *= 2 if [:ASONEGRIM, :ASONECHILLING, :SOULHEART].include?(opp.ability)
      # Opp has revealed spread move
      threatscore[i] *= 1.2 if getAIMemory(opp).any? { |moveloop| moveloop != nil && [:AllOpposing, :AllNonUsers].include?(opp.pbTarget(moveloop)) }
      # Opp has killing move
      threatscore[i] *= 1.5 if aimons.any? { |mon| checkAIdamage(opp, mon) >= mon.hp }
      # Abilities
      threatscore[i] *= aimons.sum { |mon| getAbilityDisruptScore(mon, opp, forThreatScore: true) / aimons.length }
      # Speed
      threatscore[i] *= 1.5 if aimons.any? { |aimon| pbAIfaster?(nil, nil, opp, aimon) }
      threatscore[i] *= 1.1 if aimons.all? { |aimon| pbAIfaster?(nil, nil, opp, aimon) }
      # Status
      threatscore[i] *= 0.6 if (opp.status == :SLEEP || opp.status == :FROZEN) && opp.crested != :SUICUNE
      threatscore[i] *= 0.8 if opp.status == :PARALYSIS && ![:GUTS, :MARVELSCALE, :QUICKFEET].include?(opp.ability) && opp.crested != :SUICUNE
    }
    threatscore.map! { |score| score.round(2) }
    return threatscore
  end

  def getMoveScore(initialscores = [], scoreindex = -1)
    #################### Setup ####################
    score = initialscores[scoreindex]
    @initial_scores = initialscores
    @score_index = scoreindex
    @mondata.oppitemworks = @opponent.itemWorks?
    @mondata.attitemworks = @attacker.itemWorks?
    weather = @battle.pbWeather(@attacker)
    #################### Early Return Conditions ####################
    # Type-nulling fields and abilities
    typemod = pbTypeModNoMessages(@move.pbType(@attacker))
    if typemod.immune?
      return typemod.numerator # 0 or -1
    end
    # Magic Bounce / Magic Coat (from seed)
    if @mondata.skill >= MEDIUMSKILL && @move.canMagicCoat?
      bouncers = @attacker.pbTarget(@move) == :OpposingSide ? [@opponent, @opponent.pbPartner] : [@opponent]
      # hazard moves get bounced if any mon on the opponent side has magic bounce
      # all other magic bounceable moves get bounced individually
      if bouncers.any? { |bouncer| bouncer.effects[:MagicCoat] || (bouncer.ability == :MAGICBOUNCE && !moldBreakerCheck(@attacker, bouncer, @move)) }
        return -1
      end
      score *= 0.2 if bouncers.any? { |bouncer| checkAImoves([:MAGICCOAT], battler: bouncer) }
    end
    # Protect effect (from seed)
    if seedProtection?(@opponent) && protectEffectWorks?(@opponent.effects[:Protect], @move, @attacker)
      harmful = [:KingsShield, :BanefulBunker, :SpikyShield, :Obstruct, :SilkTrap, :BurningBulwark].include?(@opponent.effects[:Protect]) && @attacker.makesContact?(@move) && !(@mondata.attitemworks && @attacker.item == :PROTECTIVEPADS)
      return harmful ? -1 : 0
    end
    # Priority blocking conditions
    if !moveSuccessful?(@basemove, @attacker, @opponent)
      return 0
    end
    # Don't prefer attacking the opponent if they'd be semi-invulnerable
    if moveInvulMisses?() && pbAIfaster?(@move)
      return 0
    end
    # Don't prefer attacking a Tatsugiri inside Dondozo's mouth
    if @opponent.effects[:Commander]
      return 0
    end
    # If user is frozen and has a move that can thaw the user, don't prefer other moves
    if @mondata.skill >= MEDIUMSKILL && @attacker.status == :FROZEN
      if !@move.canThawUser? && @attacker.moves.any? { |move| move&.canThawUser? }
        return 0
      end
    end
    # Check for moves that can be nullified by any mon in doubles
    redirectionSusceptible = @battle.doublebattle && [:SingleNonUser, :NonUserPosition, :RandomOpposing, :SingleOpposing, :OppositeOpposing, :DragonDarts].include?(@attacker.pbTarget(@move)) && ![:PROPELLERTAIL, :STALWART].include?(@attacker.ability) && ![0x179, 0x0CE].include?(@move.function) && !(move.move == :THUNDERRAID && @attacker.pbPartner.ability == :LIGHTNINGROD) # Sky Drop, Snipe Shot
    if redirectionSusceptible
      addedtype = @move.getSecondaryType(@attacker, @move.pbType(@attacker))
      allTypes = [@move.pbType(@attacker), *addedtype]
      if (@opponent.pbPartner.ability == :LIGHTNINGROD && allTypes.include?(:ELECTRIC)) ||
         (@opponent.pbPartner.ability == :STORMDRAIN && allTypes.include?(:WATER))
        return -1
      end
      if (@attacker.pbPartner.ability == :LIGHTNINGROD && allTypes.include?(:ELECTRIC)) ||
        (@attacker.pbPartner.ability == :STORMDRAIN && allTypes.include?(:WATER))
        score *= 0.1
      end
    end
    #################### Misc. Scoring ####################
    # Priority checks
    if @move.pbIsPriorityMoveAI(@attacker) && @attacker != @opponent.pbPartner
      aifaster = pbAIfaster?() || @opponent.effects[:HyperBeam] > 0 || @opponent.effects[:Truant]
      aifaster_partner = @opponent.pbPartner.hp <= 0 || pbAIfaster?(nil, nil, @attacker, @opponent.pbPartner) || @opponent.pbPartner.effects[:HyperBeam] > 0 || @opponent.pbPartner.effects[:Truant]
      # if move.pbIsDamaging?
      PBDebug.dblog("\nPriority check for #{@attacker.logname} using: #{@move.name} against #{@opponent.logname}")
      aifaster ? PBDebug.dblog("AI Pokemon is faster.") : PBDebug.dblog("Opposing Pokemon is faster.")
      unless (@opponent.pbPartner.hp <= 0 && (((@opponent.status == :SLEEP || @opponent.status == :FROZEN) && @opponent.crested != :SUICUNE) || @opponent.effects[:Truant] || @opponent.effects[:HyperBeam] > 0)) || seedProtection?(@attacker) # Skip priority if opponent is incapacitated or attacker is protected
        if score > 100
          score *= @battle.doublebattle ? 1.3 : (aifaster ? 1.3 : 2)
        elsif !aifaster
          score *= 0.7 if (@attacker.ability == :STANCECHANGE && @attacker.form == 0 && @attacker.pokemon.species == :AEGISLASH) || (@attacker.crested == :VESPIQUEN && @attacker.effects[:VespiCrest] == false)
        end
        movedamage = -1
        opppri = false
        pridam = -1
        memory = getAIMemory(@opponent, addfakemoves: @mondata.skill >= MEDIUMSKILL)
        movedamage2 = -1
        opppri2 = false
        pridam2 = -1
        memory2 = getAIMemory(@opponent.pbPartner, addfakemoves: @mondata.skill >= HIGHSKILL)
        # ^ Will be an empty array if opponent partner is fainted (always true in a single battle)
        if !aifaster || !aifaster_partner ||
           memory.any? { |moveloop| moveloop != nil && moveloop.pbIsDamaging? && moveloop.pbIsPriorityMoveAI(@opponent) } ||
           memory2.any? { |moveloop| moveloop != nil && moveloop.pbIsDamaging? && moveloop.pbIsPriorityMoveAI(@opponent.pbPartner) }
          for i in memory
            tempdam = pbRoughDamage(i, @opponent, @attacker)
            movedamage = tempdam if tempdam > movedamage
            if i.pbIsPriorityMoveAI(@opponent) && i.pbIsDamaging?
              opppri = true
              pridam = tempdam if tempdam > pridam
            end
          end
          for i in memory2
            tempdam = pbRoughDamage(i, @opponent.pbPartner, @attacker)
            movedamage2 = tempdam if tempdam > movedamage2
            if i.pbIsPriorityMoveAI(@opponent.pbPartner) && i.pbIsDamaging?
              opppri2 = true
              pridam2 = tempdam if tempdam > pridam2
            end
          end
        end
        movedamage = @attacker.hp - 1 if notOHKO?(@opponent, @attacker, true)
        movedamage2 = @attacker.hp - 1 if @opponent.pbPartner.hp > 0 && notOHKO?(@opponent.pbPartner, @attacker, true)
        PBDebug.dblog(sprintf("Pre-check: %d", score))
        PBDebug.dblog(sprintf("Expected damage taken: %d", [movedamage, movedamage2].max))
        scoreboost = @opponent.pbPartner.hp > 0 || @attacker.pbPartner.hp > 0 ? 40 : 150
        # Protect and Snatch, even though priority, might not end up doing anything when user is likely to be KO'd this turn
        scoreboost = 30 if PBStuff::PROTECTMOVE.include?(@move.move) || @move.move == :SNATCH
        scoreboost = 0 if Rejuv && @opponent.isbossmon && [:SHADOWMEWTWO, :SHADOWMEWTWO_EASY].include?(@opponent.pokemon.bossID)
        if !(@attacker.ability == :RESUSCITATION && @attacker.form == 1) && score > 1
          if (!aifaster && movedamage > @attacker.hp) ||
             (!aifaster_partner && movedamage2 > @attacker.hp) ||
             (!aifaster && !aifaster_partner && movedamage + movedamage2 > @attacker.hp)
            score += scoreboost
          end
        end
        PBDebug.dblog(sprintf("Post-check: %d", score))
        if opppri
          score *= 1.1
          score *= aifaster ? 3 : 0.5 if pridam > attacker.hp
        elsif opppri2
          score *= 1.1
          score *= aifaster_partner ? 3 : 0.5 if pridam2 > attacker.hp
        end
        score *= 4 if @attacker.effects[:GlaiveRush] && (!aifaster || !aifaster_partner)
      end
      if @battle.doublebattle
        score *= 0.2 if checkAImovesAllOpponents([:QUICKGUARD], usedmove: true) && protectEffectWorks?(:QuickGuard, @move, @attacker)
      else
        if checkAImovesAllOpponents([:QUICKGUARD], usedmove: true)
          if hpGainPerTurn(@attacker, true) < 0
            score *= 0.2 if protectEffectWorks?(:QuickGuard, @move, @attacker)
          end
        end
      end
      upperHander = checkAImovesAllOpponents([:UPPERHAND], usedmove: true)
      if upperHander && upperHandWorks?(upperHander, @attacker, @move)
        score *= @attacker.effects[:Substitute] > 0 || @attacker.ability == :INNERFOCUS || secondaryEffectNegated?(nil, upperHander, @attacker) ? 0.6 : 0.2
      end
    elsif @move.priorityCheck(@attacker) < 0 && pbAIfaster?()
      score *= 0.9
      score *= 0.6 if initialscores[scoreindex] >= 100 && initialscores.count { |iniscore| iniscore >= 100 } > 1
      score *= 2 if @move.pbIsDamaging? && moveInvulMisses?()
    end
    # Sound moves against Throat Chop
    score *= 0.6 if @move.checkSoundMove?(@attacker) && !@move.zmove && checkAImoves([:THROATCHOP]) && !pbAIfaster?(@move)
    # Dance moves and Dancer
    if @move.danceMove?
      if @mondata.skill >= BESTSKILL && @battle.FE == :BIGTOP
        score *= selfstatboost([0, 0, 1, 0, 1, 0, 0]) if @attacker.ability == :DANCER
        # Checking Big Top for attacker only since Dancer doesn't boost stats for copied moves
      end
      score *= 1.5 if @attacker.pbPartner.ability == :DANCER
      for opp in [@attacker.pbOpposing1, @attacker.pbOpposing2]
        score *= 0.5 if opp.hp > 0 && opp.ability == :DANCER && !(opp == @opponent && initialscores[scoreindex] >= 110)
      end
    end
    if @mondata.skill >= HIGHSKILL && @opponent.index != @attacker.index
      if @move.pbIsDamaging? && ![:FUTURESIGHT, :DOOMDESIRE].include?(@move.move)
        if @opponent.effects[:DestinyBond]
          score *= 0.2 unless getAIMemory(@opponent).all? { |oppmove| pbAIfaster?(oppmove, @move, @opponent, @attacker) }
        else
          dbond = getAIMemory(@opponent).find { |move| move.move == :DESTINYBOND }
          score *= 0.7 if dbond && pbAIfaster?(dbond, @move, @opponent, @attacker)
        end
      end
      ioncheck = false
      ioncheck = true if checkAImovesAllOpponents([:ELECTRIFY]) && !pbAIfaster?(@move)
      if @move.pbType(@attacker) == :NORMAL
        ioncheck = true if checkAImovesAllOpponents([:PLASMAFISTS]) && !pbAIfaster?(@move)
        if checkAImovesAllOpponents([:IONDELUGE])
          priority = @move.priorityCheck(@attacker)
          ioncheck = true if priority <= 0 || (priority == 1 && !pbAIfaster?(@move))
        end
      end
      if ioncheck
        score *= 0.3 if [:LIGHTNINGROD, :VOLTABSORB, :MOTORDRIVE].include?(@opponent.ability) || (redirectionSusceptible && @opponent.pbPartner.ability == :LIGHTNINGROD)
        score *= 0.6 if redirectionSusceptible && @attacker.pbPartner.ability == :LIGHTNINGROD
      end
      score *= 0.2 if checkAImovesAllOpponents([:WIDEGUARD], usedmove: true) && [:AllOpposing, :AllNonUsers].include?(@attacker.pbTarget(@move))
      score *= 0.2 if checkAImovesAllOpponents([:POWDER]) && @move.pbType(@attacker) == :FIRE
    end
    # If opponent is about to use a recover move before being hit, check damage vs them after the recovery, as long as attacker deals damage
    if @mondata.skill >= BESTSKILL && @move.pbIsDamaging? && @opponent.hp < @opponent.totalhp && score > 0
      hitssub = @opponent.effects[:Substitute] > 0 && !((@move.pbIsDamaging? && !@move.blockedBySubstitute?(@attacker, @opponent)) || @attacker.pbGetHitNumber(@move, norandomness: true) > 1)
      hprestoringmoves = getAIMemory(@opponent).filter { |move| move.isDrainingMove? || move.isHealingMove? }
      if !hitssub && hprestoringmoves.length > 0
        heal = 0
        for healmove in hprestoringmoves
          next if pbAIfaster?(@move, healmove)
          next if healmove.isDrainingMove? && @attacker.ability == :LIQUIDOOZE
          next if [0xd7, 0xdf, 0xe3, 0xe4, 0x162, 0x527].include?(healmove.function) # Ignore Wish, Heal Pulse, Floral Healing, Lunar Dance, Healing Wish, Revival Blessing
          next if healmove.function == 0xd9 && !@opponent.pbCanSleep?(@opponent, healmove, ignorestatus: true) # Rest
          next if healmove.function == 0x169 && @battle.battlers.none? { |b| b.index != @opponent.index && !b.status.nil? } # Purify
          next if healmove.function == 0x172 && @attacker.pbTooLow?(PBStats::ATTACK) # Strength Sap
          next if healmove.function == 0xde && @attacker.status != :SLEEP # Dream Eater

          tempheal = healmove.isDrainingMove? ? getDrainAmount(@opponent, @attacker, healmove) : getHealAmount(@opponent, healmove)
          heal = tempheal if tempheal > heal
        end
        if heal > 0
          newhp = [@opponent.hp + heal, @opponent.totalhp].min
          # Multiply score by ratio of [what the initial score would be at the recovered HP] to [the initial score calculated for the current HP]
          score *= calcInitialScore(newhp) / @initial_scores[@score_index].to_f
        end
      end
    end
    if !@move.zmove && @move.highCritRate?
      unless @opponent.ability == :SHELLARMOR || @opponent.ability == :BATTLEARMOR || @attacker.effects[:LaserFocus] > 0
        boostercount = 0
        if @move.pbIsPhysical?(@attacker)
          boostercount += @opponent.stages[PBStats::DEFENSE] if @opponent.stages[PBStats::DEFENSE] > 0
          boostercount -= @attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK] < 0
        elsif @move.pbIsSpecial?(@attacker)
          boostercount += @opponent.stages[PBStats::SPDEF] if @opponent.stages[PBStats::SPDEF] > 0
          boostercount -= @attacker.stages[PBStats::SPATK] if @attacker.stages[PBStats::SPATK] < 0
        end
        score *= (1.05**boostercount) if hasgreatmoves()
      end
    end
    # If you have two moves that kill, use one that doesn't consume your item (gems only rn)
    if hasgreatmoves() && @attacker.item
      score *= 0.85 if @attacker.item == :POWERHERB && (PBStuff::TWOTURNMOVE).include?(@move.move)
      score *= 0.9 if $cache.items[@attacker.item].checkFlag?(:gem) && $cache.items[@attacker.item].checkFlag?(:typeboost) == @move.pbType(@attacker)
    end
    if Rejuv && @battle.FE == :SWAMP
      if [:ATTACKORDER, :STRINGSHOT].include?(@move.move) || @move.isDrainingMove? || @move.move == :LEECHSEED
        statarray = [1, 1, 1, 1, 1, 1, 1]
        statarray.unshift(0) # this is required to make the next line work correctly
        # Start by eliminating pointless stats
        minidrop = 1.05
        for i in 1...statarray.length
          if @opponent.pbCanReduceStatStage?(i, @attacker, @move)
            minidrop += (@opponent.ability == :COMPETITIVE || @opponent.ability == :DEFIANT || @opponent.ability == :CONTRARY) ? -0.1 : 0.05
          end
        end
        score *= minidrop
      end
    end
    # Contact move checks
    if !@move.zmove && @attacker.makesContact?(@move) && !(@mondata.attitemworks && @attacker.item == :PROTECTIVEPADS)
      contactscore = 1.0
      contactscore *= @attacker.hp < 0.2 * @attacker.totalhp ? 0.5 : 0.85 if @mondata.oppitemworks && @opponent.item == :ROCKYHELMET
      contactscore *= 0.85 if @attacker.item.nil? && @mondata.oppitemworks && @opponent.item == :STICKYBARB
      case @opponent.ability
        when :EFFECTSPORE then contactscore *= 0.75 unless @attacker.powderImmune?
        when :PERISHBODY then contactscore *= [:DIMENSIONAL, :HAUNTED, :INFERNAL, :DEUXFINALIS].include?(@battle.FE) ? 0.5 : 0.75 unless @battle.FE == :HOLY
        when :FLAMEBODY then contactscore *= 0.75 if @attacker.pbCanBurn?(@opponent, nil)
        when :STATIC then contactscore *= 0.75 if @attacker.pbCanParalyze?(@opponent, nil)
        when :POISONPOINT then contactscore *= 0.75 if @attacker.pbCanPoison?(@opponent, nil)
        when :CUTECHARM then contactscore *= 0.8 if @attacker.pbCanAttract?(@opponent, nil) && initialscores.length > 0 && initialscores[scoreindex] < 110
        when :ROUGHSKIN, :IRONBARBS then contactscore *= @attacker.hp < 0.2 * @attacker.totalhp ? 0.5 : 0.85
        when :GOOEY, :TANGLINGHAIR, :COTTONDOWN
          if @attacker.pbCanReduceStatStage?(PBStats::SPEED, @opponent, nil)
            contactscore *= 0.9
            contactscore *= 0.8 if pbAIfaster?()
          end
        when :MUMMY, :LINGERINGAROMA, :WANDERINGSPIRIT
          list = PBStuff::FIXEDABILITIES + [:MUMMY, :LINGERINGAROMA] if [:MUMMY, :LINGERINGAROMA].include?(@opponent.ability)
          list = PBStuff::ABILITYBLACKLIST + [:WANDERINGSPIRIT] if @opponent.ability == :WANDERINGSPIRIT
          if !list.include?(@attacker.ability) && !(@mondata.attitemworks && @attacker.item == :ABILITYSHIELD)
            mummyscore = getAbilityDisruptScore(@opponent, @attacker)
            mummyscore = mummyscore < 2 ? 2 - mummyscore : 0
            contactscore *= mummyscore
          end
      end
      if @opponent.effects[:ProtectRate] < 1
        # we take move being physical as equivalent to attacker being a physical attacker here
        contactscore *= 0.8 if @opponent.species == :AEGISLASH && !checkAImoves([:KINGSSHIELD]) && (@move.pbIsPhysical?(@attacker) || [:FAIRYTALE, :CHESS, :COLOSSEUM].include?(@battle.FE))
        contactscore *= Gen < 8 ? 0.5 : 0.6 if checkAImoves([:KINGSSHIELD]) && (@move.pbIsPhysical?(@attacker) || [:FAIRYTALE, :CHESS, :COLOSSEUM].include?(@battle.FE))
        contactscore *= 0.7 if checkAImoves([:BANEFULBUNKER]) && @attacker.pbCanPoison?(@opponent, nil)
        contactscore *= 0.6 if checkAImoves([:SPIKYSHIELD]) && @attacker.hp < (@battle.FE == :COLOSSEUM ? 0.6 : 0.3) * @attacker.totalhp
        contactscore *= 0.7 if checkAImoves([:SILKTRAP]) && @attacker.pbCanReduceStatStage?(PBStats::SPEED, @opponent, nil) && pbAIfaster?()
        contactscore *= 0.6 if checkAImoves([:OBSTRUCT]) && @attacker.pbCanReduceStatStage?(PBStats::DEFENSE, @opponent, nil)
        if checkAImoves([:BURNINGBULWARK]) && @attacker.pbCanBurn?(@opponent, nil) && @attacker.ability != :GUTS
          contactscore *= @move.pbIsPhysical?(@attacker) ? 0.6 : 0.8
        end
      end
      contactscore *= scoringAgainstPartner? ? 0.9 : 1.1 if @attacker.ability == :POISONTOUCH && @opponent.pbCanPoison?(@attacker, @move)
      contactscore *= 0.6 if @opponent.effects[:ShellTrap] && initialscores[scoreindex] < 100
      contactscore *= 0.9 if @opponent.ability == :PICKPOCKET && @attacker.item && !@battle.pbIsUnlosableItem(@attacker, @attacker.item) && @opponent.item.nil?
      # this could be increased for moves that hit more than twice, but this should be sufficiently strong enough to deter move usage regardless
      contactscore = contactscore**2 if @attacker.pbGetHitNumber(@move, norandomness: true) > 1
      score *= contactscore
    end
    # Toxic Chain
    if @move.pbIsDamaging? && @attacker.ability == :TOXICCHAIN && @opponent.pbCanPoison?(@attacker, @move)
      score *= scoringAgainstPartner? ? 0.9 : 1.1
    end
    # Sword of Ruin - Deux Finalis
    if @move.pbIsDamaging? && @attacker.ability == :SWORDOFRUIN && @battle.FE == :DEUXFINALIS && @opponent.pbCanPetrify?(@attacker, @move)
      score *= scoringAgainstPartner? ? 0.9 : 1.1
    end
    # Physical move checks
    if @move.pbIsPhysical?(@attacker)
      if @opponent.ability == :TOXICDEBRIS && @opponent.pbOpposingSide.effects[:ToxicSpikes] < 2
        if !@mondata.partyroles.any? { |roles| roles.intersect?([:SPINNER, :HAZARDCLEANER]) } && !scoringAgainstPartner?
          score *= 0.9
        end
        if @attacker.pbTarget(@move) == :AllNonUsers && scoringAgainstPartner?
          score *= hazardcode()
        end
      end
    end
    # Don't prefer attacking an Electromorphosis opponent if Electric-type moves are a concern
    if @opponent.ability == :ELECTROMORPHOSIS && @move.pbIsDamaging?
      score *= 0.9 unless pbTypeModNoMessages(:ELECTRIC, @opponent, @attacker).resistedOrImmune?
    end
    # Prefer using an Electric-type move if the attacker has Electromorphosis, anticipating getting hit in the same turn
    if @attacker.ability == :ELECTROMORPHOSIS && @attacker.effects[:Charge] == 0 && !pbAIfaster?(@move)
      score *= 2 if @move.pbIsDamaging? && @move.pbType(@attacker) == :ELECTRIC
    end
    # If the opponent revealed Follow Me / Rage Powder / Ally Switch / Spotlight, prefer spread moves and other moves that can ignore redirection
    unless @opponent.pbPartner.isFainted? || [:PROPELLERTAIL, :STALWART].include?(@attacker.ability)
      for rmove in [:FOLLOWME, :RAGEPOWDER, :ALLYSWTCH, :SPOTLIGHT]
        redirector = rmove == :SPOTLIGHT ? @opponent : @opponent.pbPartner
        case rmove
          when :RAGEPOWDER then next if @attacker.powderImmune?
          when :ALLYSWITCH
            next if @battle.pbGetOwner(redirector.index) != @battle.pbGetOwner(redirector.pbPartner.index)
            next if Gen >= 9 && redirector.effects[:AllySwitchRate] != 0
        end
        score *= 1.2 if checkAImoves([rmove], battler: redirector) && ignoresRedirection?(rmove, @move, @attacker, redirector, @basemove)
      end
    end
    # If you have a move that kills a mon, don't bother doing anything else -against that mon-
    # (ie, don't use status moves, or damaging moves that don't kill if you're gonna take more than 50% in return)
    # ignoreOthers is used so that having a killing move against one mon does not affect moves against other mons, because that causes undesirable results if the partner also has a killing move against the same mon
    if hasgreatmoves(ignoreOthers: true) && @move.move != :SLEEPTALK # Sleep Talk is a different case
      if scoringAgainstPartner?
        maxdam, maxdamopp = *getMaxDamageAndOpponent()
      else
        maxdam, maxdamopp = checkAIdamage(), @opponent
      end
      if @move.pbIsStatus? || (initialscores[scoreindex] < 100 && maxdam > @attacker.hp * 0.5)
        unless maxdam > @attacker.hp && !pbAIfaster?(nil, nil, @attacker, maxdamopp) && @move.pbIsPriorityMoveAI(@attacker)
          if @battle.pbPokemonCount(@battle.pbCombinedParty(@opponent.index)) == 1
            score *= 0.1 ### no reason to use a status move when you can just KO and win
          elsif maxdam > @attacker.hp * 0.3
            score *= 0.2 ### highly controversial, revert to 0.1 if shit sucks
          elsif maxdam > 0
            score *= 0.6
          end
        end
      end
    end
    # Prefer damaging moves if AI has no more Pokémon
    if @attacker.pbNonActivePokemonCount == 0
      if @mondata.skill >= MEDIUMSKILL && !(@mondata.skill >= HIGHSKILL && @opponent.pbNonActivePokemonCount > 0)
        if @move.pbIsStatus?
          score *= 0.9
        elsif @opponent.hp <= @opponent.totalhp / 2.0
          score *= 1.1
        end
      end
    end
    # Don't prefer an attack if the opponent has revealed a mon that would double resist or be immune to it
    unless scoringAgainstPartner?
      fullparty = @battle.pbPartySingleOwner(@opponent.index)
      switchableparty = fullparty.find_all.with_index { |mon, monindex|
        @battle.pbCanSwitch?(@opponent.index, monindex, ai_phase: true)
      }
      knownparty = getAIKnownParty(@opponent)
      oppparty = switchableparty.intersection(knownparty).map{ |mon| pbMakeFakeBattler(mon, fullparty.index(mon)) }
      if oppparty.any? { |oppmon| @move.pbTypeModifier(@move.pbType(@attacker), @attacker, oppmon).doubleResistedOrImmune? }
        score *= 0.9
      end
    end
    # Pick a good move for the Choice items
    if ((@mondata.attitemworks && [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(@attacker.item)) || @attacker.ability == :GORILLATACTICS) && !@move.zmove # zmoves don't cause choice lock
      if @move.pbIsStatus? && ![0xf2, 0x13d, 0xb4].include?(@move.function) # Trick, parting shot, sleep talk
        score *= 0.1
      elsif !scoringAgainstPartner?
        score *= 0.8 if oppparty.any? { |oppmon| @move.pbTypeModifier(@move.pbType(@attacker), @attacker, oppmon).immune? }
      end
      score *= (@move.accuracy / 100.0) if @move.accuracy > 0
      score *= 0.9 if @move.pp <= 5 && @move.totalpp != 0
      score *= 0.1 if [:FIRSTIMPRESSION, :FAKEOUT].include?(@move.move) && (@opponent.pbNonActivePokemonCount > 0 || @initial_scores[@score_index] < 100)
    end
    # Pick a good move for the Protean/Libero immunities
    if [:LIBERO, :PROTEAN].include?(@opponent.ability) # zmoves don't cause choice lock
      score *= 0.6 if getAIMemory(@opponent).any? { |moveloop| moveloop != nil && moveloop.pbTypeModifier(@move.pbType(@attacker), @attacker, @opponent).immune? }
    end
    # If target is frozen, don't prefer moves that could thaw them, unless target is partner
    if @mondata.skill >= MEDIUMSKILL && @opponent.status == :FROZEN
      score *= scoringAgainstPartner? ? 1.5 : 0.1 if @move.pbType(@attacker) == :FIRE || [0x0A, 0x51E].include?(@move.function)
    end
    # If move changes field consider value of changing it
    if @mondata.skill >= BESTSKILL
      sownSeeds = @opponent.ability == :SEEDSOWER && @move.pbIsDamaging? && !@move.blockedBySubstitute?(@attacker, @opponent)
      fieldmove = @battle.field.moveData(@move.move)
      if sownSeeds && @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 1, 4)
        fieldmove = $cache.FEData[PBFields::FLOWERGARDEN[PBFields::FLOWERGARDEN.index(@battle.FE) + 1]].fieldmovedata[@move.move]
      elsif sownSeeds && (!Overlays || @battle.FE == :INDOOR)
        fieldmove = $cache.FEData[:GRASSY].fieldmovedata[@move.move]
      end
      if fieldmove && fieldmove[:fieldchange]
        change_conditions = @battle.field.fieldChangeData
        if change_conditions[fieldmove[:fieldchange]]
          handled = @move.runCondition(change_conditions[fieldmove[:fieldchange]], @attacker)
        else
          handled = true
        end
        if handled # don't continue if conditions to change are not met
          currentfieldscore = getFieldDisruptScore(@attacker, @opponent, @battle.FE) # the higher the better for opp
          newfieldscore = getFieldDisruptScore(@attacker, @opponent, fieldmove[:fieldchange])
          score *= Math.sqrt(currentfieldscore / newfieldscore)
        end
      end
    end
    # Weigh scores against accuracy
    accuracy = pbRoughAccuracy(@move, @attacker, @opponent)
    accuracy = 100 if accuracy > 100
    moddedacc = (accuracy + 100) / 2.0
    score *= moddedacc / 100.0
    # Avoid shiny wild pokemon if you're an AI partner
    if @battle.pbIsWild? && !(@battle.checkPartyBosses(@battle.pbPartySingleOwner(1)) || @battle.checkPartyBosses(@battle.pbPartySingleOwner(3)))
      score *= 0.1 if @attacker.index == 2 && @opponent.pokemon.isShiny?
    end
    if Rejuv && @opponent.pbPartner.isbossmon && [:SHADOWMEWTWO, :SHADOWMEWTWO_EASY].include?(@opponent.pbPartner.pokemon.bossID)
      score *= 0.1
    end
    #################### Function Code Scoring ####################
    miniscore = 1.0
    case @move.function
      when 0x00 # No effect
        if @mondata.skill >= BESTSKILL && @battle.FE != :INDOOR
          case @battle.FE
            when :ICY
              if @move.move == :TECTONICRAGE
                if @battle.field.backup == :WATERSURFACE # Water Surface
                  currentfieldscore = getFieldDisruptScore(@attacker, @opponent, @battle.FE) # the higher the better for opp
                  newfieldscore = getFieldDisruptScore(@attacker, @opponent, :WATERSURFACE)
                  miniscore = currentfieldscore / newfieldscore
                else
                  miniscore *= 1.2 if @opponent.pbNonActivePokemonCount > 2
                  miniscore *= 0.8 if @attacker.pbNonActivePokemonCount > 2
                end
              end
            when :HAUNTED
              if @move.move == :DAZZLINGGLEAM
                if @battle.field.backup == :HOLY
                  currentfieldscore = getFieldDisruptScore(@attacker, @opponent, @battle.FE) # the higher the better for opp
                  newfieldscore = getFieldDisruptScore(@attacker, @opponent, :HOLY)
                  miniscore = currentfieldscore / newfieldscore
                else
                  miniscore *= 1.2 if @opponent.pbNonActivePokemonCount > 2
                  miniscore *= 0.8 if @attacker.pbNonActivePokemonCount > 2
                end
              end
            when :MIRROR
              miniscore *= 2 if @move.move == :DAZZLINGGLEAM && mirrorNeverMiss
              miniscore *= 0.3 if @move.move == :BOOMBURST || @move.move == :HYPERVOICE
            when :FLOWERGARDEN2, :FLOWERGARDEN3, :FLOWERGARDEN4, :FLOWERGARDEN5
              if (@move.move == :CUT || @move.move == :XSCISSOR || @move.move == :BREAKINGSWIPE) && @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5)
                miniscore *= pbPartyHasType?(:GRASS) || pbPartyHasType?(:BUG) ? 0.3 : 2.0
              end
              if @move.move == :PETALBLIZZARD && @battle.FE == :FLOWERGARDEN5
                miniscore *= 1.5 if @battle.doublebattle
              end
            when :VOLCANICTOP
              miniscore *= volcanoeruptioncode() if @move.move == :PRECIPICEBLADES
            when :CHESS
              miniscore *= tauntcode() if @move.move == :FALSESURRENDER
          end
        end
      when 0x01 # Splash
        miniscore = @mondata.skill >= BESTSKILL && @battle.FE == :WATERSURFACE ? oppstatdrop([0, 0, 0, 0, 0, 1, 0]) : 0
      when 0x02 # Struggle
        miniscore *= 0.2
      when 0x03 # Sleep, Dark Void, Grass Whistle, Sleep Powder, Spore, Relic Song, Lovely Kiss, Sing, Hypnosis
        if @move.move == :DARKVOID && !(Rejuv || @attacker.species == :DARKRAI || (Reborn && @attacker.species == :HYPNO && @attacker.form == 1))
          miniscore = 0
        else
          miniscore = sleepcode()
          miniscore *= 1.3 if pbAIfaster?(@move)
          miniscore *= 2 if @move.move == :SLEEPPOWDER && @mondata.skill >= BESTSKILL && @battle.FE == :FLOWERGARDEN5 && @battle.doublebattle
        end
      when 0x04 # Yawn
        miniscore = sleepcode()
      when 0x05 # Poison, Gunk Shot, Sludge Wave, Sludge Bomb, Poison Jab, Sludge, Poison Tail, Smog, Poison Sting, Poison Gas, Poison Powder
        miniscore = poisoncode()
        if @mondata.skill >= BESTSKILL
          if [:WATERSURFACE, :UNDERWATER].include?(@battle.FE) # Water Surface/Underwater
            if @move.move == :SLUDGEWAVE
              miniscore *= 1.75 if pbPartyHasType?(:POISON) && !pbPartyHasType?(:WATER)
              miniscore *= 0 if !@attacker.hasType?(:POISON) && !@attacker.hasType?(:STEEL) && @battle.pbPokemonCount(@battle.pbCombinedParty(@opponent.index)) == 1 && @battle.field.counter == 1
            end
          end
          if @battle.FE == :MISTY # Misty Terrain
            if @move.move == :SMOG || @move.move == :POISONGAS
              miniscore *= 1.75 if pbPartyHasType?(:POISON) && !pbPartyHasType?(:FAIRY)
            end
            if @move.move == :POISONGAS
              if pbPartyHasType?(:POISON) && !pbPartyHasType?(:FAIRY)
                score = 15
                miniscore = 1.0
              end
            end
          end
        end
      when 0x06 # Toxic, Poison Fang, Malignant Chain
        miniscore = poisoncode()
        if @move.move == :TOXIC
          miniscore *= 1.1 if @attacker.hasType?(:POISON)
        end
      when 0x07 # Paralysis, Dragon breath, Bolt Strike, Zap Cannon, Thunderbolt, Discharge, Thunder Punch, Spark, Thunder Shock, Thunder Wave, Force Palm, Lick, Stun Spore, Body Slam, Glare, Nuzzle
        miniscore = paracode()
        miniscore = petrifycode() if @battle.FE == :DEUXFINALIS && @move.move == :GLARE
        miniscore *= 0.7 if @mondata.skill >= BESTSKILL && @battle.FE == :ASHENBEACH && @move.move == :WILDBOLTSTORM
      when 0x08 # Thunder
        miniscore = paracode()
        miniscore *= thunderboostcode()
        miniscore *= nevermisscode(initialscores[scoreindex]) if weather == :RAINDANCE
      when 0x09 # Paralysis + Flinch, Thunder Fang
        miniscore = paracode()
        miniscore *= flinchcode()
      when 0x0A # Burn Blue Flare, Fire Blast, Heat Wave, Inferno, Sacred Fire, Searing Shot, Flamethrower, Blae kick, Lava Plume, Fire Punch, Flame Wheel, Ember, Will-O-Wist, Scald, Steam Eruption
        miniscore = burncode()
        if @mondata.skill >= BESTSKILL
          if @move.move == :SCALD || @move.move == :STEAMERUPTION
            if @battle.FE == :ICY # Icy Field
              currentfieldscore = getFieldDisruptScore(@attacker, @opponent, @battle.FE) # the higher the better for opp
              newfieldscore = getFieldDisruptScore(@attacker, @opponent, :WATERSURFACE)
              miniscore *= Math.sqrt(currentfieldscore / newfieldscore)
            end
          end
          if @move.move == :LAVAPLUME
            if @battle.FE == :VOLCANICTOP
              miniscore *= volcanoeruptioncode()
            end
          end
          miniscore *= 0.7 if @move.move == :SANDSEARSTORM && @battle.FE == :ASHENBEACH
        end
      when 0x0B # Burn + Flinch, Fire Fang
        miniscore = burncode()
        miniscore *= flinchcode()
      when 0x0C # Freeze, Ice Beam, Ice Punch, Powder Snow, Freeze-Dry
        miniscore = freezecode()
      when 0x0D # Blizzard Freeze
        miniscore = freezecode()
        miniscore *= nevermisscode(initialscores[scoreindex]) if [:HAIL, :SNOW].include?(weather)
      when 0x0E # Freeze + Flinch, Ice Fang
        miniscore = freezecode()
        miniscore *= flinchcode()
        if @mondata.skill >= BESTSKILL
          if @battle.FE == :GLITCH # Glitch
            miniscore *= 1.2
          end
        end
      when 0x0F # Flinch, Dark Pulse, Bite, Rolling Kick, Air Slash, Astonish, Needle Arm, Hyper Fang, Headbutt, Extrasensory, Zen Headbutt, Heart Stamp, Rock Slide, Iron Head, Waterfall, Zing Zap
        miniscore = flinchcode()
      when 0x10 # Stomp, Steamroller, Dragon Rush
        miniscore = flinchcode()
      when 0x11 # Snore
        miniscore = @attacker.status == :SLEEP ? flinchcode() : 0
      when 0x12 # Fake Out
        if @attacker.turncount != 0
          miniscore = 0
        elsif ((@mondata.attitemworks && [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(@attacker.item)) || @attacker.ability == :GORILLATACTICS) && !@move.zmove && (@opponent.pbNonActivePokemonCount > 0 || @initial_scores[@score_index] < 100)
          # the conditions below don't really apply in the scenario of "we're choiced and fake out doesn't immediately win the battle", which is handled above in the general section
          miniscore = 1
        elsif !(@opponent.effects[:Substitute] > 0 || @opponent.ability == :INNERFOCUS || secondaryEffectNegated?())
          # usually this would be saved as miniscore, but we directly add to the score
          score += 115 if score > 0
          score *= flinchcode()
          score *= 0.7 if @battle.doublebattle
          score *= 1.5 if (@attacker.pbPartner.pbHasMove?(:TRICKROOM) && @battle.state.effects[:TrickRoom] == 0) || (@attacker.pbPartner.pbHasMove?(:TAILWIND) && @attacker.pbOwnSide.effects[:Tailwind] == 0)
          score *= 1.5 if @mondata.attitemworks && @attacker.item == :NORMALGEM && @attacker.ability == :UNBURDEN
          score *= 0.3 if checkAImoves([:ENCORE])
        end
      when 0x13 # Confusion, Signal Beam, Dynamic Punch, Chatter, Confuse Ray, Rock Climb, Dizzy Punch, Supersonic, Sweet Kiss, Teeter Dance, Psybeam, Water Pulse, Strange Steam
        miniscore = confucode()
        if @mondata.skill >= BESTSKILL
          if @move.move == :SIGNALBEAM
            miniscore *= 2 if @battle.FE == :MIRROR && mirrorNeverMiss # Mirror Arena
          end
          if @move.move == :SWEETKISS && @battle.FE == :FAIRYTALE
            miniscore *= wakeupoppcode()
          end
          if @move.move == :TEETERDANCE && [:BIGTOP, :DANCEFLOOR].include?(@battle.FE)
            miniscore *= oppstatdrop([0, 1, 0, 0, 0, 0, 0])
          end
        end
      when 0x14 # Chatter
      when 0x15 # Hurricane
        miniscore = confucode()
        miniscore *= thunderboostcode()
        miniscore *= nevermisscode(initialscores[scoreindex]) if weather == :RAINDANCE
      when 0x16 # Attract
        miniscore = attractcode()
      when 0x17 # Tri Attack
        miniscore = (burncode() + paracode() + freezecode()) / 3
      when 0x18 # Refresh
        miniscore = refreshcode()
      when 0x19 # Aromatherapy, Heal Bell
        miniscore = partyrefreshcode()
      when 0x1a # Safeguard
        miniscore = safeguardcode()
      when 0x1b # Psycho Shift
        miniscore = psychocode()
      when 0x1c # Gen 7 Howl, Sharpen, Meditate, Meteor Mash, Metal Claw, Power-Up Punch
        statarray = [1, 0, 0, 0, 0, 0, 0]
        statarray = [3, 0, 0, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :MEDITATE && [:RAINBOW, :ASHENBEACH].include?(@battle.FE)
        statarray = [2, 0, 2, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :MEDITATE && @battle.FE == :PSYTERRAIN
        statarray = [2, 0, 0, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :HOWL && (@battle.FE == :COLOSSEUM || @battle.ProgressiveFieldCheck(PBFields::CONCERT))
        miniscore = selfstatboost(statarray)
      when 0x1d # Harden, Steel Wing, Withdraw, Psyshield Bash
        statarray = [0, 1, 0, 0, 0, 0, 0]
        statarray = [0, 1, 0, 1, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :PSYSHIELDBASH && @battle.FE == :PSYTERRAIN
        miniscore = selfstatboost(statarray)
      when 0x1e # Defense Curl
        miniscore = selfstatboost([0, 1, 0, 0, 0, 0, 0])
        score *= 1.3 if @attacker.pbHasMove?(:ROLLOUT, :ICEBALL) && @attacker.effects[:DefenseCurl] == false
      when 0x1f # Flame Charge, Esper Wing, Aqua Step, Trailblaze
        miniscore = selfstatboost([0, 0, 0, 0, 1, 0, 0])
      when 0x20 # Charge Beam, Fiery Dance, Mystical Power, Torch Song
        miniscore = selfstatboost([0, 0, 1, 0, 0, 0, 0])
      when 0x21 # Charge
        miniscore = selfstatboost([0, 0, 0, 1, 0, 0, 0])
        miniscore = selfstatboost([0, 0, 0, 2, 0, 0, 0]) if @mondata.skill >= BESTSKILL && @battle.FE == :ELECTERRAIN
        miniscore *= 1.5 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbType(@attacker) == :ELECTRIC && moveloop.pbIsDamaging? } && @attacker.effects[:Charge] == 0
      when 0x22 # Double Team
        statarray = [0, 0, 0, 0, 0, 0, 1]
        statarray = [0, 0, 0, 0, 0, 0, 2] if @mondata.skill >= BESTSKILL && @move.move == :DOUBLETEAM && @battle.FE == :MIRROR
        miniscore = selfstatboost(statarray)
      when 0x23 # Focus Energy
        miniscore = focusenergycode()
        miniscore *= 1.5 if @mondata.skill >= BESTSKILL && @battle.FE == :ASHENBEACH # Ashen Beach
      when 0x24 # Bulk Up
        miniscore = selfstatboost([1, 1, 0, 0, 0, 0, 0])
        miniscore = selfstatboost([2, 2, 0, 0, 0, 0, 0]) if @mondata.skill >= BESTSKILL && @battle.FE == :CROWD
      when 0x25 # Coil
        statarray = [1, 1, 0, 0, 0, 1, 0]
        statarray = [2, 2, 0, 0, 0, 2, 0] if @mondata.skill >= BESTSKILL && (@battle.FE == :GRASSY || (Rejuv && @battle.FE == :DRAGONSDEN))
        miniscore = selfstatboost(statarray)
      when 0x26 # Dragon Dance
        statarray = [1, 0, 0, 0, 1, 0, 0]
        statarray = [2, 0, 0, 0, 2, 0, 0] if @mondata.skill >= BESTSKILL && [:BIGTOP, :DRAGONSDEN, :DANCEFLOOR].include?(@battle.FE)
        miniscore = selfstatboost(statarray)
        miniscore *= dynamicspeedcode(:partnerstage, statarray[PBStats::SPEED]) if @attacker.pbPartner.ability == :DANCER && ![@opponent.ability, @opponent.pbPartner.ability].include?(:DANCER)
      when 0x27 # Work Up
        statarray = [1, 0, 1, 0, 0, 0, 0]
        statarray = [2, 0, 2, 0, 0, 0, 0] if @battle.ProgressiveFieldCheck(PBFields::CONCERT) || [:CROWD, :CITY].include?(@battle.FE)
        miniscore = selfstatboost(statarray)
      when 0x28 # Growth
        statarray = [1, 0, 1, 0, 0, 0, 0]
        if @mondata.skill >= BESTSKILL
          statarray = [2, 0, 2, 0, 0, 0, 0] if (weather == :SUNNYDAY && !(@mondata.attitemworks && @attacker.item == :UTILITYUMBRELLA)) || [:GRASSY, :FOREST].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 1, 2)
          statarray = [3, 0, 3, 0, 0, 0, 0] if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5)
        end
        miniscore = selfstatboost(statarray)
      when 0x29 # Hone Claws
        miniscore = selfstatboost([1, 0, 0, 0, 0, 1, 0])
      when 0x2a # Cosmic Power, Defend Order
        statarray = [0, 1, 0, 1, 0, 0, 0]
        statarray = [0, 2, 0, 2, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :COSMICPOWER && [:MISTY, :RAINBOW, :HOLY, :STARLIGHT, :NEWWORLD, :PSYTERRAIN].include?(@battle.FE)
        statarray = [0, 2, 0, 2, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :DEFENDORDER && @battle.FE == :FOREST
        miniscore = selfstatboost(statarray)
      when 0x2b # Quiver Dance
        statarray = [0, 0, 1, 1, 1, 0, 0]
        statarray = [0, 0, 2, 2, 2, 0, 0] if @mondata.skill >= BESTSKILL && [:BIGTOP, :DANCEFLOOR].include?(@battle.FE)
        miniscore = selfstatboost(statarray)
        miniscore *= dynamicspeedcode(:partnerstage, statarray[PBStats::SPEED]) if @attacker.pbPartner.ability == :DANCER && [@opponent.ability, @opponent.pbPartner.ability].include?(:DANCER)
      when 0x2c # Calm Mind
        statarray = [0, 0, 1, 1, 0, 0, 0]
        statarray = [0, 0, 2, 2, 0, 0, 0] if @mondata.skill >= BESTSKILL && [:CHESS, :ASHENBEACH, :PSYTERRAIN].include?(@battle.FE)
        miniscore = selfstatboost(statarray)
      when 0x2d # Ancient Power, Silver Wind, Ominous Wind
        miniscore = selfstatboost([1, 1, 1, 1, 1, 0, 0])
      when 0x2e # Swords Dance
        statarray = [2, 0, 0, 0, 0, 0, 0]
        statarray = [3, 0, 0, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :SWORDSDANCE && [:BIGTOP, :FAIRYTALE, :DANCEFLOOR, :COLOSSEUM].include?(@battle.FE)
        miniscore = selfstatboost(statarray)
      when 0x2f # Iron Defense, Acid Armor, Barrier, Diamond Storm
        statarray = [0, 2, 0, 0, 0, 0, 0]
        if @mondata.skill >= BESTSKILL && (@move.move == :IRONDEFENSE && @battle.FE == :FACTORY) ||
           (@move.move == :ACIDARMOR && [:CORROSIVE, :CORROSIVEMIST, :MURKWATERSURFACE, :FAIRYTALE, *PBFields::CONCERT].include?(@battle.FE)) ||
           (@move.move == :SHELTER && @battle.FE == :SWAMP)
          statarray = [0, 3, 0, 0, 0, 0, 0]
        end
        miniscore = selfstatboost(statarray)
      when 0x30 # Agility, Rock Polish
        statarray = [0, 0, 0, 0, 2, 0, 0]
        statarray = [0, 0, 0, 0, 3, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :ROCKPOLISH && @battle.FE == :ROCKY
        statarray = [1, 0, 1, 0, 2, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :ROCKPOLISH && @battle.FE == :CRYSTALCAVERN
        miniscore = selfstatboost(statarray)
      when 0x31 # Autotomize
        statarray = [0, 0, 0, 0, 2, 0, 0]
        statarray = [0, 0, 0, 0, 3, 0, 0] if @mondata.skill >= BESTSKILL && [:FACTORY, :CITY, :DEEPEARTH].include?(@battle.FE)
        miniscore = selfstatboost(statarray)
        miniscore *= 1.5 if checkAImoves([:LOWKICK, :GRASSKNOT])
        miniscore *= 0.5 if checkAImoves([:HEATCRASH, :HEAVYSLAM])
        miniscore *= 0.7 if @attacker.pbHasMove?(:HEATCRASH, :HEAVYSLAM)
      when 0x32 # Nasty Plot
        statarray = [0, 0, 2, 0, 0, 0, 0]
        statarray = [0, 0, 3, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && [:CHESS, :PSYTERRAIN, :INFERNAL, :BACKALLEY].include?(@battle.FE)
        miniscore = selfstatboost(statarray)
      when 0x33 # Amnesia
        statarray = [0, 0, 0, 2, 0, 0, 0]
        miniscore = selfstatboost(statarray)
        miniscore *= 2 if @mondata.skill >= BESTSKILL && @battle.FE == :GLITCH
      when 0x34 # Minimize
        miniscore = selfstatboost([0, 0, 0, 0, 0, 0, 2])
      when 0x35 # Shell Smash
        miniscore = selfstatboost([2, 0, 2, 0, 2, 0, 0])
        miniscore *= selfstatdrop([0, 1, 0, 1, 0, 0, 0], score) if @mondata.attitemworks && @attacker.item != :WHITEHERB
        if @mondata.attitemworks && @attacker.item == :WHITEHERB
          miniscore *= 1.3
        else
          miniscore *= 0.8
        end
      when 0x36 # Shift Gear
        statarray = [1, 0, 0, 0, 2, 0, 0]
        statarray = [2, 0, 0, 0, 2, 0, 0] if @mondata.skill >= BESTSKILL && [:FACTORY, :CITY].include?(@battle.FE)
        miniscore = selfstatboost(statarray)
      when 0x37 # Acupressure
        miniscore = selfstatboost([2, 0, 0, 0, 0, 0, 0]) +
                    selfstatboost([0, 2, 0, 0, 0, 0, 0]) +
                    selfstatboost([0, 0, 2, 0, 0, 0, 0]) +
                    selfstatboost([0, 0, 0, 2, 0, 0, 0]) +
                    selfstatboost([0, 0, 0, 0, 2, 0, 0]) +
                    selfstatboost([0, 0, 0, 0, 0, 2, 0]) +
                    selfstatboost([0, 0, 0, 0, 0, 0, 2])
        miniscore /= 7
      when 0x38 # Cotton Guard
        miniscore = selfstatboost([0, 3, 0, 0, 0, 0, 0])
      when 0x39 # Tail Glow
        miniscore = selfstatboost([0, 0, 3, 0, 0, 0, 0])
      when 0x3a # Belly Drum
        atkraise = 6 - @attacker.stages[PBStats::ATTACK]
        statarray = [atkraise, 0, 0, 0, 0, 0, 0]
        statarray = [atkraise, 1, 0, 1, 0, 0, 0] if @mondata.skill >= BESTSKILL && @battle.FE == :BIGTOP
        hploss = [(@attacker.totalhp / 2.0).floor, 1].max
        miniscore = selfStatBoostHPLoss(statarray, hploss)
      when 0x3b # Superpower
        statarray = [1, 1, 0, 0, 0, 0, 0]
        if @attacker.ability == :CONTRARY
          miniscore = selfstatboost(statarray)
        else
          miniscore = selfstatdrop(statarray, score)
          miniscore *= 1.5 if [:MOXIE, :CHILLINGNEIGH, :ASONECHILLING].include?(@attacker.ability) || ([:BEASTBOOST, :EELEVATE].include?(@attacker.ability) && @attacker.getHighestRawStat == PBStats::ATTACK)
        end
      when 0x3c # Close Combat, Dragon Ascent, Headlong Rush, Armor Cannon
        statarray = [0, 1, 0, 1, 0, 0, 0]
        if @attacker.ability == :CONTRARY
          miniscore = selfstatboost(statarray)
        else
          miniscore = selfstatdrop(statarray, score)
        end
      when 0x3d # V-Create
        statarray = [0, 1, 0, 1, 1, 0, 0]
        if @attacker.ability == :CONTRARY
          miniscore = selfstatboost(statarray)
        else
          miniscore = selfstatdrop(statarray, score)
        end
      when 0x3e # Hammer Arm, Ice Hammer
        statarray = [0, 0, 0, 0, 1, 0, 0]
        if @attacker.ability == :CONTRARY || @battle.state.effects[:TrickRoom] > 2
          miniscore = selfstatboost(statarray)
        else
          miniscore = selfstatdrop(statarray, score)
        end
      when 0x3f # Overheat, Draco Meteor, Leaf Storm, Psycho Boost, Fleur Cannon
        statarray = [0, 0, 2, 0, 0, 0, 0]
        if @attacker.ability == :CONTRARY
          miniscore = selfstatboost(statarray)
        else
          miniscore = selfstatdrop(statarray, score)
          miniscore *= 1.3 if [:SOULHEART, :GRIMNEIGH, :ASONEGRIM].include?(@attacker.ability) || ([:BEASTBOOST, :EELEVATE].include?(@attacker.ability) && @attacker.getHighestRawStat == PBStats::SPATK)
        end
      when 0x40 # Flatter
        if @opponent.ability == :CONTRARY
          miniscore = oppstatdrop(@battle.FE == :COLOSSEUM ? [0, 0, 2, 0, 0, 0, 0] : [0, 0, 1, 0, 0, 0, 0])
        else
          miniscore = oppstatboost(@battle.FE == :COLOSSEUM ? [0, 0, 2, 0, 0] : [0, 0, 1, 0, 0], true)
        end
      when 0x41 # Swagger
        if @opponent.ability == :CONTRARY
          miniscore = oppstatdrop(@battle.FE == :COLOSSEUM ? [3, 0, 0, 0, 0, 0, 0] : [2, 0, 0, 0, 0, 0, 0])
        else
          miniscore = oppstatboost(@battle.FE == :COLOSSEUM ? [3, 0, 0, 0, 0] : [2, 0, 0, 0, 0], true)
        end
      when 0x42 # Growl, Aurora Beam, Baby-Doll Eyes, Play Nice, Play Rough, Lunge, Trop Kick, Chilling Water
        statarray = [1, 0, 0, 0, 0, 0, 0]
        statarray = [1, 0, 1, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @battle.FE == :HAUNTED && @move.move == :BITTERMALICE
        statarray = [2, 0, 0, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @battle.ProgressiveFieldCheck(PBFields::CONCERT)
        miniscore = oppstatdrop(statarray)
        if @mondata.skill >= BESTSKILL
          miniscore *= selfstatboost([0, 0, 0, 0, 1, 0, 0]) if @move.move == :LUNGE && @battle.FE == :ICY
          miniscore *= 2 if @move.move == :AURORABEAM && mirrorNeverMiss && @battle.FE == :MIRROR
          miniscore *= freezecode() if [:ICY, :SNOWYMOUNTAIN].include?(@battle.FE) && @move.move == :BITTERMALICE
          miniscore *= 0.7 if @battle.FE == :ASHENBEACH && @move.move == :SPRINGTIDESTORM
          miniscore *= petrifycode() if @battle.FE == :DEUXFINALIS && @move.move == :BITTERMALICE
        end
      when 0x43 # Tail Whip, Crunch, Rock Smash, Crush Claw, Leer, Iron Tail, Razor Shell, Fire Lash, Liquidation, Shadow Bone
        miniscore = oppstatdrop([0, 1, 0, 0, 0, 0, 0])
      when 0x44 # Rock Tomb, Electroweb, Low Sweep, Bulldoze, Mud Shot, Glaciate, Icy Wind, Constrict, Bubble Beam, Bubble, Pounce
        statarray = [0, 0, 0, 0, 1, 0, 0]
        statarray = [0, 0, 0, 0, 2, 0, 0] if Rejuv && ((@move.move == :STRUGGLEBUG && @battle.FE == :SWAMP) || (@battle.FE == :ELECTERRAIN && @move.move == :ELECTROWEB))
        miniscore = oppstatdrop(statarray)
        if @move.move == :BULLDOZE
          if @mondata.skill >= BESTSKILL
            if @battle.FE == :ICY # Icy Field
              if @battle.field.backup == :WATERSURFACE # Water Surface
                currentfieldscore = getFieldDisruptScore(@attacker, @opponent, @battle.FE) # the higher the better for opp
                newfieldscore = getFieldDisruptScore(@attacker, @opponent, :WATERSURFACE)
                miniscore = currentfieldscore / newfieldscore
              else
                miniscore *= 1.2 if @opponent.pbNonActivePokemonCount > 2
                miniscore *= 0.8 if @attacker.pbNonActivePokemonCount > 2
              end
            end
            if @battle.FE == :CAVE
              if @attacker.ability != :ROCKHEAD && @attacker.ability != :BULLETPROOF && @attacker.ability != :STALWART
                miniscore *= 0.7
                miniscore *= 0.3 if @battle.field.counter >= 1
              end
            end
            if @battle.FE == :VOLCANICTOP
              miniscore *= volcanoeruptioncode()
            end
          end
        end
      when 0x45 # Snarl, Struggle Bug, Mist Ball, Confide, Moonblast, Mystical Fire, Spirit Break
        statarray = [0, 0, 1, 0, 0, 0, 0]
        statarray = [0, 0, 2, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && ((@move.move == :SNARL && [:FROZENDIMENSION, :BACKALLEY].include?(@battle.FE)) || (Rejuv && @move.move == :STRUGGLEBUG && @battle.FE == :SWAMP))
        miniscore = oppstatdrop(statarray)
      when 0x46 # Psychic, Bug Buzz, Focus Blast, Shadow Ball, Energy Ball, Earth Power, Acid, Luster Purge, Flash Cannon
        miniscore = oppstatdrop([0, 0, 0, 1, 0, 0, 0])
        if @mondata.skill >= BESTSKILL
          miniscore *= 2 if (@move.move == :FLASHCANNON || @move.move == :LUSTERPURGE) && mirrorNeverMiss && @battle.FE == :MIRROR
          miniscore *= volcanoeruptioncode() if @battle.FE == :VOLCANICTOP && @move.move == :EARTHPOWER
        end
      when 0x47 # Sand Attack, Night Daze, Leaf Tornado, Mod Bomb, Mud-Slap, Flash, Smokescreen, Kinesis, Mirror Shot, Muddy Water, Octazooka
        statarray = [0, 0, 0, 0, 0, 1, 0]
        if @mondata.skill >= BESTSKILL
          statarray = [0, 0, 0, 0, 0, 2, 0] if @move.move == :SANDATTACK && [:ASHENBEACH, :DESERT].include?(@battle.FE)
          statarray = [0, 0, 0, 0, 0, 2, 0] if @move.move == :FLASH && [:DARKCRYSTALCAVERN, :SHORTCIRCUIT, :MIRROR, :STARLIGHT, :NEWWORLD, :DARKNESS1].include?(@battle.FE)
          statarray = [0, 0, 0, 0, 0, 2, 0] if @move.move == :SMOKESCREEN && [:BURNING, :CORROSIVEMIST, :VOLCANIC, :VOLCANICTOP, :BACKALLEY, :CITY].include?(@battle.FE)
          statarray = [0, 0, 0, 0, 0, 2, 0] if @move.move == :KINESIS && [:PSYTERRAIN, :ASHENBEACH].include?(@battle.FE)
        end
        miniscore = oppstatdrop(statarray)
        if @mondata.skill >= BESTSKILL
          miniscore *= selfstatboost([2, 0, 2, 0, 0, 0, 0]) if @move.move == :KINESIS && @battle.FE == :PSYTERRAIN
          miniscore *= 2 if @move.move == :MIRRORSHOT && mirrorNeverMiss && @battle.FE == :MIRROR
          miniscore *= 0.7 if @move.move == :LEAFTORNADO && @battle.FE == :ASHENBEACH
        end
        if @move.move == :MUDDYWATER
          miniscore *= 0.7 if @battle.FE == :SUPERHEATED # Superheated
          if @battle.FE == :DRAGONSDEN # Dragon's Den
            miniscore *= pbPartyHasType?(:FIRE) || pbPartyHasType?(:DRAGON) ? 0 : 1.5
          end
        end
      when 0x48 # Sweet Scent
        statarray = [0, 0, 0, 0, 0, 0, 2]
        if @mondata.skill >= BESTSKILL
          statarray = [0, 1, 0, 1, 0, 0, 2] if [:MISTY, :FLOWERGARDEN3].include?(@battle.FE)
          statarray = [0, 2, 0, 2, 0, 0, 2] if @battle.FE == :FLOWERGARDEN4
          statarray = [0, 3, 0, 3, 0, 0, 2] if @battle.FE == :FLOWERGARDEN5
        end
        miniscore = oppstatdrop(statarray)
      when 0x49 # Defog
        miniscore = defogcode()
        miniscore *= hazardremovalcode()
        miniscore += oppstatdrop([0, 0, 0, 0, 0, 0, 1])
        miniscore += getFieldDisruptScore(tempOnly: true) if Gen > 7 && @battle.canEndTempFieldOrOverlay?
      when 0x4a # Tickle
        miniscore = oppstatdrop([1, 1, 0, 0, 0, 0, 0])
      when 0x4b # Feather Dance, Charm
        statarray = [2, 0, 0, 0, 0, 0, 0]
        statarray = [3, 0, 0, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :FEATHERDANCE && @battle.FE == :BIGTOP
        statarray = [2, 0, 2, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :FEATHERDANCE && @battle.FE == :DANCEFLOOR
        miniscore = oppstatdrop(statarray)
      when 0x4c # Screech
        statarray = [0, 2, 0, 0, 0, 0, 0]
        statarray = [0, 3, 0, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @battle.ProgressiveFieldCheck(PBFields::CONCERT)
        miniscore = oppstatdrop(statarray)
      when 0x4d # Scary Face, String Shot, Cotton Spore
        statarray = [0, 0, 0, 0, 2, 0, 0]
        statarray = [0, 0, 0, 0, 4, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :SCARYFACE && @battle.FE == :HAUNTED
        miniscore = oppstatdrop(statarray)
      when 0x4e # Captivate
        if @attacker.isGenderless? || @opponent.isGenderless? || @attacker.gender == @opponent.gender || (@opponent.ability == :OBLIVIOUS && !moldBreakerCheck(@attacker, @opponent, @move))
          miniscore = 0
        else
          miniscore = oppstatdrop([0, 0, 2, 0, 0, 0, 0])
        end
      when 0x4f # Acid Spray, Seed Flare, Metal Sound, Fake Tears, Lumina Crash
        statarray = [0, 0, 0, 2, 0, 0, 0]
        statarray = [0, 0, 0, 3, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :METALSOUND && ([:FACTORY, :SHORTCIRCUIT].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::CONCERT))
        statarray = [0, 0, 0, 3, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :FAKETEARS && @battle.FE == :BACKALLEY
        miniscore = oppstatdrop(statarray)
      when 0x50 # Clear Smog
        miniscore = oppstatrestorecode()
      when 0x51 # Haze
        miniscore = hazecode()
      when 0x52 # Power Swap
        miniscore = statswapcode(PBStats::ATTACK, PBStats::SPATK)
      when 0x53 # Guard Swap
        miniscore = statswapcode(PBStats::DEFENSE, PBStats::SPDEF)
      when 0x54 # Heart Swap
        boostarray, droparray = psychupcode()
        buffscore = selfstatboost(boostarray.clone) - selfstatdrop(droparray.clone, score)
        dropscore = oppstatdrop(boostarray.clone) - oppstatboost(droparray.clone)
        miniscore = buffscore + dropscore
        miniscore = 25 if miniscore == 0 && @battle.FE == :NEWWORLD
        miniscore *= splitcode(PBStats::HP) if @battle.FE == :NEWWORLD
      when 0x55 # Psych Up
        boostarray, droparray = psychupcode()
        boostarray[2] += 2 if @mondata.skill >= BESTSKILL && @battle.FE == :PSYTERRAIN
        actualopp = @opponent
        @opponent = getMaxDamageAndOpponent()[1] if scoringAgainstPartner?
        miniscore = selfstatboost(boostarray) - selfstatdrop(droparray.clone, score)
        stagecounter = boostarray.sum - droparray.sum
        miniscore *= 1.3 if stagecounter >= 3
        miniscore *= [1, refreshcode()].max if @mondata.skill >= BESTSKILL && @battle.FE == :ASHENBEACH
        @opponent = actualopp
      when 0x56 # Mist
        miniscore = mistcode()
        fieldscore = 1
        if @attacker.item != :EVERSTONE && @battle.canChangeFE?(:MISTY)
          fieldscore = getFieldDisruptScore(@attacker, @opponent)
          fieldscore *= 1.3 if pbPartyHasType?(:FAIRY)
          fieldscore *= 1.3 if @opponent.hasType?(:DRAGON) && !@attacker.hasType?(:FAIRY)
          fieldscore *= 0.5 if @attacker.hasType?(:DRAGON)
          fieldscore *= 0.5 if @opponent.hasType?(:FAIRY)
          fieldscore *= 1.5 if @attacker.hasType?(:FAIRY) && @opponent.spatk > @opponent.attack
          fieldscore *= 2   if @mondata.attitemworks && @attacker.item == :AMPLIFIELDROCK
        end
        score *= 0 if miniscore <= 1 && fieldscore <= 1
        miniscore *= fieldscore
      when 0x57 # Power Trick
        miniscore = powertrickcode()
      when 0x58 # Power Split
        miniscore = splitcode(PBStats::ATTACK)
      when 0x59 # Guard Split
        miniscore = splitcode(PBStats::DEFENSE)
      when 0x5a # Pain Split
        miniscore = splitcode(PBStats::HP)
      when 0x5b # Tailwind
        miniscore = tailwindcode()
        if @mondata.skill >= BESTSKILL
          if [:MOUNTAIN, :SNOWYMOUNTAIN, :SKY, :VOLCANICTOP].include?(@battle.FE) # Mountain/Snowy Mountain
            miniscore *= 1.5
            miniscore *= 1.5**@battle.pbCombinedParty(@attacker.index).count { |mon| mon && mon.hp > 0 && mon.hasType?(:FLYING) }
          end
        end
      when 0x5c, 0x5d # Mimic, Sketch
        miniscore = mimicsketchcode()
      when 0x5e # Conversion
        miniscore = typechangecode(@attacker.moves[0].type)
        if @attacker.item != :EVERSTONE && @battle.canChangeFE?(:GLITCH)
          otherConversionUsed = @battle.field.conversion && @battle.field.conversion != @move.move
          minimini = getFieldDisruptScore(@attacker, @opponent)
          minimini = 1 + (minimini - 1) / 2 if otherConversionUsed
          miniscore *= minimini
          miniscore *= 0.3 if !otherConversionUsed
        end
      when 0x5f # Conversion2
        miniscore = 0
        lastmove = @opponent.moves.find { |move| move.move == @opponent.lastMoveUsed }
        if lastmove
          atype = lastmove.pbType(@opponent)
          resistedtypes = PBTypes.typeResists(atype)
          resistedtypes.delete_if { |type| type == @attacker.type1 && @attacker.type2.nil? }
          for type in resistedtypes
            miniscore += (typechangecode(type) / resistedtypes.length)
          end
        end
        if @attacker.item != :EVERSTONE && @battle.canChangeFE?(:GLITCH)
          otherConversionUsed = @battle.field.conversion && @battle.field.conversion != @move.move
          minimini = getFieldDisruptScore(@attacker, @opponent)
          minimini = 1 + (minimini - 1) / 2 if otherConversionUsed
          miniscore *= minimini
          miniscore *= 0.3 if !otherConversionUsed
        end
      when 0x60 # Camouflage
        miniscore = typechangecode(@battle.getMimicryType)
      when 0x61 # Soak
        miniscore = opptypechangecode(:WATER)
      when 0x62 # Reflect Type

        miniscores = []
        for type in @opponent.types
          miniscores.push typechangecode(type)
        end
        miniscore = @attacker.types == @opponent.types ? 1 : miniscores.max
      when 0x63 # Simple Beam
        miniscore = abilitychangecode(:SIMPLE)
      when 0x64 # Worry Seed
        miniscore = abilitychangecode(:INSOMNIA)
        miniscore *= oppstatdrop([1, 0, 0, 0, 0, 0, 0]) if Rejuv && @battle.FE == :GRASSY
      when 0x65 # Role Play
        miniscore = roleplaycode()
      when 0x66 # Entrainment
        score = entraincode(score)
      when 0x67 # Skill Swap
        miniscore = skillswapcode()
      when 0x68 # Gastro Acid
        miniscore = gastrocode()
      when 0x69 # Transform
        miniscore = transformcode()
      # when 0x6A # Sonicboom
      # when 0x6B # Dragon Rage
      when 0x6C # Super Fang, Nature's Madness, Ruination
        miniscore = petrifycode() if @battle.FE == :DEUXFINALIS && @move.move == :RUINATION
      # when 0x6D # Seismic Toss, Night Shade
      when 0x6e # Endeavor
        miniscore = endeavorcode()
      when 0x70 # Fissure, Sheer Cold, Guillotine, Horn Drill
        miniscore = ohkode()
        if @mondata.skill >= BESTSKILL
          if @move.move == :FISSURE
            if @battle.FE == :ICY # Icy Field
              if @battle.field.backup == :WATERSURFACE # Water Surface
                currentfieldscore = getFieldDisruptScore(@attacker, @opponent, @battle.FE) # the higher the better for opp
                newfieldscore = getFieldDisruptScore(@attacker, @opponent, :WATERSURFACE)
                miniscore = currentfieldscore / newfieldscore
              else
                miniscore *= 1.2 if @opponent.pbNonActivePokemonCount > 2
                miniscore *= 0.8 if @attacker.pbNonActivePokemonCount > 2
              end
            end
          end
        end
      when 0x71..0x73 # Counter, Mirror Coat, Metal Burst
        miniscore = counterattackcode()
        miniscore *= Math.sqrt(selfstatboost([0, 1, 0, 1, 0, 0, 1])) if @mondata.skill >= BESTSKILL && @battle.FE == :MIRROR && @move.move == :MIRRORCOAT
      when 0x74 # Flame Burst
        miniscore *= 1.1 if @battle.doublebattle
      when 0x75 # Surf
        if @mondata.skill >= BESTSKILL
          miniscore *= 0.7 if @battle.FE == :SUPERHEATED && @move.move == :SURF
          miniscore *= (pbPartyHasType?(:DRAGON) || pbPartyHasType?(:FIRE)) ? 0 : 1.5 if @battle.FE == :DRAGONSDEN && @move.move == :SURF
          miniscore *= volcanoeruptioncode() if @battle.FE == :VOLCANICTOP && @move.move == :MAGMADRIFT
        end
      when 0x76 # Earthquake
        if @mondata.skill >= BESTSKILL
          if @battle.FE == :ICY # Icy Field
            if @battle.field.backup == :WATERSURFACE # Water Surface
              currentfieldscore = getFieldDisruptScore(@attacker, @opponent, @battle.FE) # the higher the better for opp
              newfieldscore = getFieldDisruptScore(@attacker, @opponent, :WATERSURFACE)
              miniscore = currentfieldscore / newfieldscore
            else
              miniscore *= 1.2 if @opponent.pbNonActivePokemonCount > 2
              miniscore *= 0.8 if @attacker.pbNonActivePokemonCount > 2
            end
          end
          if @battle.FE == :CAVE && @move.move == :EARTHQUAKE
            if ![:ROCKHEAD, :BULLETPROOF].include?(@attacker.ability) && !(Rejuv && @attacker.ability == :EARTHEATER)
              miniscore *= 0.7
              miniscore *= 0.3 if @battle.field.counter >= 1
            end
          end
          if @battle.FE == :VOLCANICTOP
            miniscore = volcanoeruptioncode()
          end
        end
      when 0x77 # Gust
      when 0x78 # Twister
        miniscore = flinchcode()
        miniscore *= 0.7 if @mondata.skill >= BESTSKILL && @battle.FE == :ASHENBEACH
      # when 0x79 # Fusion Bolt, Fusion Flare, Venoshock
      when 0x7c # Smelling Salts
        if @opponent.status == :PARALYSIS && @opponent.effects[:Substitute] <= 0
          score *= 0.8
          score *= 0.5 if @opponent.speed > @attacker.speed && @opponent.speed / 2.0 < @attacker.speed
        end
      when 0x7d # Wake-up Slap
        miniscore *= wakeupoppcode()
      # when 0x7E..0x80 # Facade, Hex, Brine
      when 0x81 # Revenge, Avalanche
        miniscore = revengecode()
      when 0x82 # Assurance
        score *= 1.5 if !pbAIfaster?(@move)
      when 0x83 # Round
        score *= 1.5 if @battle.doublebattle && @attacker.pbPartner.pbHasMove?(:ROUND)
      when 0x84 # Payback
        score *= 2 if !pbAIfaster?(@move)
      # when 0x85..0x87 # Retaliate, Acrobatics, Weather Ball
      when 0x88 # Pursuit
        miniscore = pursuitcode()
        if @attacker.stages[PBStats::SPEED] != 6 && score >= 100
          miniscore *= 1.5
          miniscore *= 2 if pbAIfaster?(@move) && @move.move != :VILEASSAULT
        end
      # when 0x89..0x8a # Return, Frustration
      when 0x8B # Water Spout, Eruption, Dragon Energy
        if !pbAIfaster?(@move)
          original_power = [(150 * @attacker.hp.to_f / @attacker.totalhp), 1.0].max
          actual_power = [(150 * (@attacker.hp.to_f - checkAIdamage()) / @attacker.totalhp), 1.0].max
          score *= actual_power / original_power
        end
        if @mondata.skill >= BESTSKILL
          if @move.move == :WATERSPOUT
            score *= 0.7 if @battle.FE == :SUPERHEATED # Superheated
          end
        end
      # when 0x8C..0x90 # Crush Grip, Wring Out, Hard Press, Gyro Ball, Stored Power, Power Trip, Punishment, Hidden Power
      when 0x91 # Fury Cutter
        miniscore = echocode()
        miniscore *= (1 + 0.15 * @attacker.stages[PBStats::ACCURACY])
        miniscore *= (1 - 0.08 * @opponent.stages[PBStats::EVASION])
        miniscore *= 0.8 if checkAImoves(PBStuff::PROTECTMOVE)
      when 0x92 # Echoed Voice
        miniscore = echocode()
      when 0x93 # Rage
        if @battle.FE != :DIMENSIONAL && @battle.FE != :FROZENDIMENSION
          score *= 1.2 if @attacker.attack > @attacker.spatk
          score *= 1.3 if @attacker.hp == @attacker.totalhp
          score *= 1.3 if checkAIdamage() < (@attacker.hp / 4.0)
        else
          statarray = [1, 0, 0, 0, 0, 0, 0]
          miniscore = selfstatboost(statarray)
        end
      when 0x94 # Present
        score *= 1.2 if @opponent.hp == @opponent.totalhp
      when 0x95 # Magnitude
        if @mondata.skill >= BESTSKILL
          if @battle.FE == :ICY # Icy Field
            if @battle.field.backup == :WATERSURFACE # Water Surface
              currentfieldscore = getFieldDisruptScore(@attacker, @opponent, @battle.FE) # the higher the better for opp
              newfieldscore = getFieldDisruptScore(@attacker, @opponent, :WATERSURFACE)
              miniscore = currentfieldscore / newfieldscore
            else
              miniscore *= 1.2 if @opponent.pbNonActivePokemonCount > 2
              miniscore *= 0.8 if @attacker.pbNonActivePokemonCount > 2
            end
          end
          if @battle.FE == :CAVE
            if @attacker.ability != :ROCKHEAD && @attacker.ability != :BULLETPROOF || @attacker.ability != :STALWART
              miniscore *= 0.7
              miniscore *= 0.3 if @battle.field.counter >= 1
            end
          end
          if @battle.FE == :VOLCANICTOP
            miniscore = volcanoeruptioncode()
          end
        end
      when 0x96 # Natural Gift
        score *= 0 if @attacker.item.nil? || !pbIsBerry?(@attacker.item) || !@mondata.attitemworks
      when 0x97 # Trump Card
        score *= 1.2 if @attacker.hp == @attacker.totalhp
        score *= 1.3 if checkAIdamage() < (@attacker.hp / 3.0)
      when 0x98 # Reversal, Flail
        if !pbAIfaster?(@move)
          score *= 1.1
          score *= 1.3 if @attacker.hp < @attacker.totalhp
        end
      # when 0x99..0x9b # Electro Ball, Low Kick, Grass Knot, Heat Crash, Heavy Slam
      when 0x9c # Helping Hand
        miniscore = helpinghandcode()
      when 0x9d # Mud Sport
        miniscore = mudsportcode()
        miniscore *= !pbPartyHasType?(:ELECTRIC) ? 2 : 0.3 if @battle.FE == :ELECTERRAIN
      when 0x9e # Water Sport
        miniscore = watersportcode()
        miniscore *= !pbPartyHasType?(:FIRE) ? 2 : 0 if @battle.FE == :BURNING
        if @battle.FE == :SUPERHEATED
          miniscore *= 0.7
          miniscore *= !pbPartyHasType?(:FIRE) ? 1.8 : 0
        elsif [:GRASSY, :FOREST].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN)
          miniscore *= 3 if !@attacker.hasType?(:FIRE) && @opponent.hasType?(:FIRE)
          miniscore *= 0.5 if pbPartyHasType?(:FIRE)
          if pbPartyHasType?(:GRASS) || pbPartyHasType?(:BUG)
            miniscore *= 2
            miniscore *= 3 if @battle.FE == :FLOWERGARDEN5
          end
        end
      # when 0x9f # Judgement, Techno Blast, Multi-Attack
      when 0xa0 # Frost Breath, Storm Throw, Wicked Blow, Flower Trick
        miniscore = permacritcode(initialscores[scoreindex])
      when 0xa1 # Lucky Chant
        miniscore = luckychantcode()
      when 0xa2 # Reflect
        miniscore = screencode()
        miniscore += [0, selfstatboost([0, 0, 0, 0, 0, 0, 1]) - 1].max if @mondata.skill >= BESTSKILL && @battle.FE == :MIRROR
      when 0xa3 # Light Screen
        miniscore = screencode()
        miniscore += [0, selfstatboost([0, 0, 0, 0, 0, 0, 1]) - 1].max if @mondata.skill >= BESTSKILL && @battle.FE == :MIRROR
      when 0xa4 # Secret Power
        miniscore = secretcode()
      when 0xa6 # Lock On, Mind Reader
        miniscore = lockoncode()
        if @battle.FE == :PSYTERRAIN && @move.move == :MINDREADER
          miniscore *= selfstatboost([0, 0, 2, 0, 0, 0, 0])
          score += 10 if @attacker.stages[PBStats::SPATK] < 6
        end
      when 0xa7 # Foresight, Odor Sleuth
        miniscore = forecode5me()
      when 0xa8 # Miracle Eye
        miniscore = miracode()
        if [:PSYTERRAIN, :HOLY, :FAIRYTALE].include?(@battle.FE)
          score += 10 if @attacker.stages[PBStats::SPATK] < 6
          miniscore *= selfstatboost([0, 0, 2, 0, 0, 0, 0])
        end
      when 0xa9 # Chip Away, Sacred Sword, Darkest Lariat
        miniscore = chipcode()
      when 0xaa # Protect, Detect
        miniscore = protectcode()
      when 0xab # Quick Guard
        miniscore = quickguardcode()
      when 0xac # Wide Guard
        miniscore = wideguardcode()
      when 0xad # Feint, Hyperspace Hole
        miniscore = feintcode()
      when 0xae # Mirror Move
        score = mirrorcode(false) # changes actual score so no miniscore
        score += 10 * selfstatboost([1, 0, 1, 0, 0, 1, 0]) if @mondata.skill >= BESTSKILL && @battle.FE == :MIRROR && score != 0
        score += 10 * selfstatboost([1, 0, 1, 0, 1, 0, 0]) if @mondata.skill >= BESTSKILL && @battle.FE == :SKY && score != 0
      when 0xaf # Copycat
        if @opponent.effects[:Substitute] <= 0
          score = mirrorcode(true) # changes actual score so no miniscore
        else
          score = 0
        end
      when 0xb0 # Me First
        miniscore = yousecondcode()
      when 0xb1 # Magic Coat
        miniscore = coatcode()
      when 0xb2 # Snatch
        miniscore = snatchcode()
      when 0xb3 # Nature Power
      # we should never need this- nature power should be changed in advance
      when 0xb4 # Sleep Talk
        miniscore = sleeptalkcode(initialscores)
      when 0xb5 # Assist
        miniscore = metronomecode(25)
      when 0xb6 # Metronome
        miniscore = metronomecode(20)
        miniscore = metronomecode(40) if @battle.FE == :GLITCH
      when 0xb7 # Torment
        miniscore = tormentcode()
      when 0xb8 # Imprison
        miniscore = imprisoncode()
      when 0xb9 # Disable
        miniscore = disablecode()
      when 0xba # Taunt
        miniscore = tauntcode()
      when 0xbb # Heal Block, Psychic Noise
        miniscore = healblockcode()
      when 0xbc # Encore
        miniscore = encorecode()
      when 0xbd # Double Kick, Dual Chop, Bonemerang, Double Hit, Gear Grind, Twin Beam, Tachyon Cutter
        miniscore = multihitcode()
      when 0xbe # Twinneedle
        miniscore = poisoncode**1.2
        miniscore *= multihitcode()
      when 0xbf # Triple Kick
        miniscore = multihitcode()
      when 0xc0 # Bullet Seed, Pin Missile, Arm Thrust, Bone Rush, Icicle Spear, Tail Slap, Spike Cannon, Comet Punch, Furey Swipes, Barrage, Double Slap, Fury Attack, Rock Blast, Water Shuriken
        miniscore = multihitcode()
      when 0xc1 # Beat Up
        if scoringAgainstPartner?
          score = beatupcode(initialscores[scoreindex])
        else
          miniscore = multihitcode() if @attacker.pbBeatUpParty.length > 1
        end
      when 0xc2 # Hyper Beam, Roar of Time, Blast Burn, Frenzy Plant, Giga Impact, Rock Wrecker, Hydro Cannon, Prismatic Laser, Meteor Assault
        miniscore = hypercode() unless @move.move == :METEORASSAULT && @battle.FE == :STARLIGHT
      when 0xc3 # Weasel Slash
        miniscore = weaselslashcode() unless [:CLOUDS, :SKY].include?(@battle.FE) || (Rejuv && (@battle.FE == :GRASSY || @battle.OV == :GRASSY))
      when 0xc4 # Solar Beam, Solar Blade
        # if we first want to use sunny day for instant move later
        if weather != :SUNNYDAY && @attacker.pbHasMove?(:SUNNYDAY) && !(aiCheckGlobalAbility([:AIRLOCK, :CLOUDNINE, :DELTASTREAM, :DESOLATELAND, :PRIMORDIALSEA]) || @attacker.item == :POWERHERB || [:UNDERWATER, :NEWWORLD, :RAINBOW].include?(@battle.FE) || @battle.OV == :RAINBOW)
          miniscore = 0.3
        else
          miniscore = weaselslashcode() unless @battle.FE == :RAINBOW || @battle.OV == :RAINBOW || (weather == :SUNNYDAY && !(@mondata.attitemworks && @attacker.item == :UTILITYUMBRELLA))
        end
        miniscore = 0 if (@battle.FE == :DARKCRYSTALCAVERN && weather != :SUNNYDAY) || [:DARKNESS2, :DARKNESS3].include?(@battle.FE) || @battle.OV == :DARKNESS2
      when 0xc5 # Freeze Shock
        miniscore = paracode()
        miniscore *= weaselslashcode() unless @battle.FE == :FROZENDIMENSION
      when 0xc6 # Ice Burn
        miniscore = burncode()
        miniscore *= weaselslashcode() unless @battle.FE == :FROZENDIMENSION
      when 0xc7 # Sky Attack
        miniscore = flinchcode()
        miniscore *= weaselslashcode() unless [:CLOUDS, :SKY].include?(@battle.FE)
      when 0xc8 # Skull Bash
        miniscore = selfstatboost([0, 1, 0, 0, 0, 0, 0])
        miniscore *= weaselslashcode()
      when 0xc9 # Fly
        if @battle.FE == :DIMENSIONAL
          miniscore = 0 # Telling the AI that Suicide is bad hmmm kay

        elsif [:NOGUARD, :HOTSHOT].include?(@attacker.ability) || [:NOGUARD, :HOTSHOT].include?(@opponent.ability) || (@opponent.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
          miniscore = weaselslashcode() unless [:CLOUDS, :CAVE, :SKY].include?(@battle.FE) || (Rejuv && battle.FE == :DRAGONSDEN)
        elsif !([:CLOUDS, :CAVE, :SKY].include?(@battle.FE) || (Rejuv && battle.FE == :DRAGONSDEN))
          miniscore = twoturncode() unless [:CLOUDS, :CAVE, :SKY].include?(@battle.FE) || (Rejuv && battle.FE == :DRAGONSDEN)
          miniscore *= 0.3 if checkAImoves([:THUNDER, :HURRICANE])
        end
      when 0xca # Dig
        if @battle.FE == :DIMENSIONAL
          miniscore = 0 # Telling the AI that Suicide is bad hmmm kay
        elsif [:NOGUARD, :HOTSHOT].include?(@attacker.ability) || [:NOGUARD, :HOTSHOT].include?(@opponent.ability) || (@opponent.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
          miniscore = weaselslashcode() unless (Rejuv && @battle.FE == :DESERT)
        elsif !(Rejuv && @battle.FE == :DESERT)
          miniscore = twoturncode()
          miniscore *= 0.3 if checkAImoves([:EARTHQUAKE])
        end
      when 0xcb # Dive
        if @battle.FE == :DIMENSIONAL
          miniscore = 0 # Telling the AI that Suicide is bad hmmm kay
        elsif [:NOGUARD, :HOTSHOT].include?(@attacker.ability) || [:NOGUARD, :HOTSHOT].include?(@opponent.ability) || (@opponent.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
          miniscore = weaselslashcode() unless [:WATERSURFACE, :UNDERWATER].include?(@battle.FE)
        elsif ![:WATERSURFACE, :UNDERWATER].include?(@battle.FE)
          miniscore = twoturncode()
          miniscore *= 0.3 if checkAImoves([:SURF])
        end
        if @battle.FE == :MURKWATERSURFACE # Murkwater Surface
          miniscore *= 0.3 if !@attacker.hasType?(:POISON) && !@attacker.hasType?(:STEEL)
        end
      when 0xcc # Bounce
        if @battle.FE == :DIMENSIONAL
          miniscore = 0 # Telling the AI that Suicide is bad hmmm kay
        elsif [:NOGUARD, :HOTSHOT].include?(@attacker.ability) || [:NOGUARD, :HOTSHOT].include?(@opponent.ability) || (@opponent.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
          miniscore = weaselslashcode() unless [:CLOUDS, :CAVE, :SKY].include?(@battle.FE) || (Rejuv && @battle.FE == :DRAGONSDEN)
        elsif !([:CLOUDS, :CAVE, :SKY].include?(@battle.FE) || (Rejuv && @battle.FE == :DRAGONSDEN))
          miniscore = twoturncode()
          miniscore *= 0.3 if checkAImoves([:THUNDER, :HURRICANE])
        end
        miniscore *= paracode()
      when 0xcd # Phantom Force, Shadow Force
        if [:NOGUARD, :HOTSHOT].include?(@attacker.ability) || [:NOGUARD, :HOTSHOT].include?(@opponent.ability) || (@opponent.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
          miniscore = weaselslashcode() unless [:DIMENSIONAL, :FROZENDIMENSION, :HAUNTED, :SHORTCIRCUIT, :DEUXFINALIS].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::DARKNESS, 2, 3)
        else
          miniscore = twoturncode() unless [:DIMENSIONAL, :FROZENDIMENSION, :HAUNTED, :SHORTCIRCUIT, :DEUXFINALIS].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::DARKNESS, 2, 3)
        end
        miniscore *= 1.1 if checkAImoves(PBStuff::PROTECTMOVE)
      when 0xce # Sky Drop
        if [:NOGUARD, :HOTSHOT].include?(@attacker.ability) || [:NOGUARD, :HOTSHOT].include?(@opponent.ability) || (@opponent.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
          miniscore = weaselslashcode()
        else
          miniscore = twoturncode()
        end
        miniscore = 0 if @opponent.weight >= 2000
      when 0xcf # Fire Spin, Magma Storm, Sand Tomb, Bind, Clamp, Wrap, Infestation, Thunder Cage, Snap Trap
        miniscore = firespincode()
        case @move.move
          when :FIRESPIN
            miniscore *= 0.7 if @battle.FE == :ASHENBEACH
            miniscore *= 1.3 if @battle.FE == :BURNING
          when :SANDTOMB
            miniscore *= 1.3 if @battle.FE == :DESERT
            score += 10 * oppstatdrop([0, 0, 0, 0, 0, 1, 0]) unless opponent.stages[PBStats::ACCURACY] < (-2) if @battle.FE == :ASHENBEACH
          when :INFESTATION
            miniscore *= 1.3 if @battle.FE == :FOREST
            if @battle.FE == @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN)
              miniscore *= 1.3
              miniscore *= 1.3 if @battle.FE == :FLOWERGARDEN4
              miniscore *= 1.5 if @battle.FE == :FLOWERGARDEN5
            end
          when :THUNDERCAGE
            miniscore *= 1.3 if @battle.FE == :ELECTERRAIN
        end
      when 0xd0 # Whirlpool
        miniscore = firespincode()
        miniscore *= 1.3 if @mondata.skill >= BESTSKILL && opponent.effects[:TwoTurnAttack] == :DIVE && pbAIfaster?()
        miniscore *= 0.7 if @battle.FE == :ASHENBEACH
        if [:WATERSURFACE, :UNDERWATER].include?(@battle.FE)
          miniscore *= 1.3
          miniscore *= confucode() if !Rejuv && opponent.effects[:Confusion] <= 0
        end
        if @battle.FE == :MURKWATERSURFACE
          miniscore += 10 if miniscore == 0
          miniscore *= 1.5 if !(@attacker.hasType?(:POISON) || @attacker.hasType?(:STEEL))
          miniscore *= 2 if !pbPartyHasType?(:POISON)
          miniscore *= 2 if pbPartyHasType?(:WATER)
        end

      when 0xd1 # Uproar
        miniscore = uproarcode()
      when 0xd2 # Outrage, Petal Dance, Thrash
        miniscore *= outragecode(score)
        if @mondata.skill >= BESTSKILL
          if [:SUPERHEATED, :VOLCANICTOP].include?(@battle.FE) && @attacker.ability != :OWNTEMPO # Superheated Field
            miniscore *= 0.5
          end
          if @move.move == :PETALDANCE
            miniscore *= 1.5 if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5)
          end
          if @move.move == :OUTRAGE
            miniscore *= 0.8 if @battle.FE != :INVERSE && pbPartyHasType?(:FAIRY, @opponent.index)
            miniscore *= 0.7 if Rejuv && @battle.FE == :CHESS && @attacker.ability != :SHELLARMOR && @attacker.ability != :BATTLEARMOR
          end
          if @move.move == :THRASH
            miniscore *= 0.8 if @battle.FE != :INVERSE && pbPartyHasType?(:GHOST, @opponent.index)
            miniscore *= 0.7 if Rejuv && @battle.FE == :CHESS && @attacker.ability != :SHELLARMOR && @attacker.ability != :BATTLEARMOR
          end
        end
      when 0xd3 # Rollout, Ice Ball
        miniscore = rolloutcode()
        score += 10 * selfstatboost([0, 0, 0, 0, 1, 0, 0]) if @mondata.skill >= BESTSKILL && @battle.FE == :ICY && [:ROLLOUT, :ICEBALL].include?(@move.move)
      when 0xd4 # Bide
        miniscore = bidecode()
      when 0xd5 # Recover, Heal Order, Milk Drink, Slack Off, Soft-Boiled
        recoveramount = getHealAmount(@attacker, @move)
        miniscore = recovercode(recoveramount)
      when 0xd6 # Roost
        recoveramount = getHealAmount(@attacker, @move)
        miniscore = recovercode(recoveramount)
        bestmove = checkAIbestMove()
        if pbAIfaster?(@move) && @attacker.hasType?(:FLYING)
          if [:ROCK, :ICE, :ELECTRIC].include?(bestmove.pbType(@opponent))
            score *= 1.5
          elsif [:GRASS, :BUG, :FIGHTING, :GROUND].include?(bestmove.pbType(@opponent))
            score *= 0.5
          end
        end
      when 0xd7 # Wish
        miniscore = wishcode()
        miniscore *= 1.2 if @mondata.skill >= BESTSKILL && [:MISTY, :RAINBOW, :HOLY, :FAIRYTALE, :STARLIGHT].include?(@battle.FE) # Misty/Rainbow/Holy/Fairytale/Starlight
      when 0xd8 # Synthesis, Moonlight, Morning Sun
        hpgain = getHealAmount(@attacker, @move)
        miniscore = recovercode(hpgain)
      when 0xd9 # Rest
        miniscore = restcode()
        if @mondata.skill >= BESTSKILL
          miniscore *= 1.2 if @battle.FE == :CROWD
        end
      when 0xda # Aqua Ring
        miniscore = aquaringcode()
        if @mondata.skill >= BESTSKILL
          miniscore *= 1.3 if [:MISTY, :SWAMP, :WATERSURFACE, :UNDERWATER].include?(@battle.FE)
          miniscore *= 1.3 if @battle.FE == :BURNING
          miniscore *= 0.3 if @battle.FE == :CORROSIVEMIST
        end
      when 0xdb # Ingrain
        miniscore = aquaringcode()
        if @mondata.skill >= BESTSKILL
          if @battle.FE == :FOREST || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN) || Rejuv && @battle.FE == :GRASSY
            miniscore *= 1.3
            miniscore *= 1.3 if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 4, 5)
          end
          if @battle.FE == :SWAMP
            miniscore *= 0.1 unless @attacker.hasType?(:POISON) || @attacker.hasType?(:STEEL)
          end
          miniscore *= 0.1 if [:CORROSIVE].include?(@battle.FE)
        end
      when 0xdc # Leech Seed
        miniscore = leechcode()
      when 0xdd # Absorb, Leech Life, Drain Punch, Giga Drain, Horn Leech, Mega Drain, Parabolic Charge, Bitter Blade
        miniscore = absorbcode()
      when 0xde # Dream Eater
        miniscore = @opponent.status != :SLEEP ? 0 : absorbcode()
      when 0xdf # Heal Pulse
        miniscore = healpulsecode()
        miniscore *= 1.5 if @attacker.ability == :MEGALAUNCHER
      when 0xe0 # Explosion, Self-Destruct, Misty Explosion
        miniscore = deathcode()
        score *= 1.5 if @battle.FE == :GLITCH
      when 0xe1 # Final Gambit
        miniscore = gambitcode()
      when 0xe2 # Memento
        miniscore = mementcode()
      when 0xe3 # Healing Wish
        miniscore = healwishcode()
        miniscore *= 1.4 if [:FAIRYTALE, :STARLIGHT].include?(@battle.FE)
      when 0xe4 # Lunar Dance
        miniscore = healwishcode()
        miniscore *= 1.4 if @battle.FE == :STARLIGHT
        miniscore *= 2 if [:NEWWORLD, :BIGTOP, :DANCEFLOOR].include?(@battle.FE)
      when 0xe5 # Perish Song
        miniscore = perishcode()
      when 0xe6 # Grudge
        miniscore *= grudgecode()
      when 0xe7 # Destiny Bond
        miniscore = destinycode()
      when 0xe8 # Endure
        miniscore *= endurecode()
        miniscore *= 0 if [:BURNING, :MURKWATERSURFACE].include?(@battle.FE)
      when 0xe9 # False Swipe
        miniscore = 0.1 if score >= 100
      when 0xea # Gen 7 Teleport
        score = 0
      when 0xeb # Roar, Whirlwind
        if @battle.FE == :COLOSSEUM
          miniscore = selfstatboost([2, 0, 0, 0, 0, 0, 0])
        else
          miniscore = phasecode()
        end
      when 0xec # Dragon Tail, Circle Throw
        miniscore = phasecode()
      when 0xed # Baton Pass
        miniscore = pivotcode()
      when 0xee # U-turn, Volt Switch, Flip Turn
        miniscore = pivotcode()
      when 0xef # Mean Look, Block, Spider Web
        miniscore = meanlookcode()
        if @battle.FE == :CROWD && @move.move == :BLOCK
          miniscore *= 1.1
          miniscore *= dynamicspeedcode(:opponentstage, -1)
        end
      when 0xf0 # Knock Off
        miniscore = knockcode()
        miniscore = pbReduceWhenKills(miniscore)
      when 0xf1 # Covet, Thief
        miniscore = covetcode()
      when 0xf2 # Trick, Switcheroo
        miniscore = covetcode()
        miniscore *= bestowcode()
        if @battle.FE == :BACKALLEY
          if @move.move == :TRICK
            miniscore *= selfstatboost([0, 0, 1, 0, 0, 0, 0])
            miniscore *= oppstatdrop([0, 0, 1, 0, 0, 0, 0])
          elsif @move.move == :SWITCHEROO
            miniscore *= selfstatboost([1, 0, 0, 0, 0, 0, 0])
            miniscore *= oppstatdrop([1, 0, 0, 0, 0, 0, 0])
          end
        end
      when 0xf3 # Bestow
        miniscore = bestowcode()
      when 0xf4 # Bug Bite, Pluck
        miniscore = nomcode()
      when 0xf5 # Incinerate
        miniscore = roastcode()
      when 0xf6 # Recycle
        miniscore = recyclecode()
        if @battle.FE == :CITY
          subscore = selfstatboost([1, 0, 0, 0, 0, 0, 0]) +
                     selfstatboost([0, 1, 0, 0, 0, 0, 0]) +
                     selfstatboost([0, 0, 1, 0, 0, 0, 0]) +
                     selfstatboost([0, 0, 0, 1, 0, 0, 0]) +
                     selfstatboost([0, 0, 0, 0, 1, 0, 0])
          subscore /= 5
          miniscore *= subscore
        end
      when 0xf7 # Fling
        miniscore = flingcode()
      when 0xf8 # Embargo
        miniscore = embarcode()
        miniscore *= [meanlookcode(), 1].max if @battle.FE == :DIMENSIONAL
      when 0xf9 # Magic Room
        attitemscore = [embarcode(@attacker), 1].max
        miniscore = embarcode() / attitemscore
        miniscore *= 0 if @battle.state.effects[:MagicRoom] > 0
      when 0xfc # Ally Switch
        miniscore = allyswitchcode()
      when 0xfe # Snowscape
        miniscore = weathercode()
        miniscore *= snowcode()
        if @mondata.skill >= BESTSKILL
          miniscore *= 1.5 if [:RAINBOW, :MOUNTAIN].include?(@battle.FE) # Rainbow/Mountain
          miniscore *= 2   if @battle.FE == :STARLIGHT && !pbPartyHasType?(:DARK) && !pbPartyHasType?(:FAIRY) && !pbPartyHasType?(:PSYCHIC) # Starlight
        end
      when 0xff # Sunny Day
        miniscore = weathercode()
        miniscore *= suncode()
        if @battle.weather == :RAINDANCE # Making Rainbow Field
          miniscore *= getFieldDisruptScore(@attacker, @opponent)
          miniscore *= 1.2 if @attacker.hasType?(:NORMAL)
        end
        if @mondata.skill >= BESTSKILL
          miniscore *= 2 if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN) # Flower Garden
          miniscore *= 2 if @battle.FE == :STARLIGHT && !pbPartyHasType?(:DARK) && !pbPartyHasType?(:FAIRY) && !pbPartyHasType?(:PSYCHIC) # Starlight
        end
      when 0x100 # Rain Dance
        miniscore = weathercode()
        miniscore *= raincode()
        if @battle.weather == :SUNNYDAY # Making Rainbow Field
          miniscore *= getFieldDisruptScore(@attacker, @opponent)
          miniscore *= 1.2 if @attacker.hasType?(:NORMAL)
        end
        if !@battle.opponent.is_a?(Array)
          if Reborn && !@battle.opponent.nil? && @battle.opponent.trainertype == :SHELLY && ([:GRASSY, :FOREST].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN)) && @attacker.index.odd? # Shelly
            miniscore *= 4
            # experimental -- cancels out drop if killing moves
            miniscore *= 6 if initialscores.length > 0 && hasgreatmoves()
            # end experimental
          end
        end
        if @mondata.skill >= BESTSKILL
          miniscore *= 1.5 if [:GRASSY, :FOREST, :SUPERHEATED].include?(@battle.FE) # Grassy/Forest/Superheated
          miniscore *= 2   if @battle.FE == :BURNING || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN) # Burning/Flower Garden
          miniscore *= 2   if @battle.FE == :STARLIGHT && !pbPartyHasType?(:DARK) && !pbPartyHasType?(:FAIRY) && !pbPartyHasType?(:PSYCHIC) # Starlight
        end
      when 0x101 # Sandstorm
        miniscore = weathercode()
        miniscore *= sandcode()
        if @mondata.skill >= BESTSKILL
          miniscore *= 1.5 if @battle.FE == :RAINBOW # Rainbow
          miniscore *= 3   if @battle.FE == :BURNING # Burning
          miniscore *= 2   if @battle.FE == :STARLIGHT && !pbPartyHasType?(:DARK) && !pbPartyHasType?(:FAIRY) && !pbPartyHasType?(:PSYCHIC) # Starlight
        end
      when 0x102 # Hail
        miniscore = weathercode()
        miniscore *= hailcode()
        if @mondata.skill >= BESTSKILL
          miniscore *= 1.5 if [:RAINBOW, :MOUNTAIN].include?(@battle.FE) # Rainbow/Mountain
          miniscore *= 2   if @battle.FE == :STARLIGHT && !pbPartyHasType?(:DARK) && !pbPartyHasType?(:FAIRY) && !pbPartyHasType?(:PSYCHIC) # Starlight
        end
      when 0x103 # Spikes / Ceaseless Edge
        if @attacker.pbOpposingSide.effects[:Spikes] >= 3
          miniscore = 0 if @move.pbIsStatus?
        else
          if @mondata.skill >= BESTSKILL && @battle.FE == :WASTELAND # Wasteland interaction
            score = 0 if @move.pbIsStatus?
            unless @opponent.isAirborne? || @opponent.ability == :MAGICGUARD || @attacker.pbOpposingSide.effects[:Spikes] >= 1
              damage = (@opponent.totalhp / 3.0).floor
              score += wastelandhazardcode(damage)
            end
          else # Normal interaction
            if [:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE)
              miniscore = 0 if @move.pbIsStatus?
            else
              miniscore = hazardcode()
              miniscore *= 0.9 if @attacker.pbOpposingSide.effects[:Spikes] > 0
              miniscore *= 1.3 if Rejuv && @mondata.skill >= BESTSKILL && @battle.FE == :ELECTERRAIN # electric spikes
            end
          end
        end
      when 0x104 # Toxic Spikes
        if @attacker.pbOpposingSide.effects[:ToxicSpikes] >= 2
          miniscore = 0 if @move.pbIsStatus?
        else
          if @mondata.skill >= BESTSKILL && @battle.FE == :WASTELAND # Wasteland interaction
            score = 0 if @move.pbIsStatus?
            unless @opponent.isAirborne? || @opponent.hasType?(:STEEL) || @opponent.hasType?(:POISON) || @opponent.ability == :MAGICGUARD || @attacker.pbOpposingSide.effects[:ToxicSpikes] >= 1
              damage = (@opponent.totalhp / 8.0).floor
              score += wastelandhazardcode(damage)
            end
          else # Normal interaction
            if [:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE)
              miniscore = 0 if @move.pbIsStatus?
            else
              miniscore = hazardcode()
              miniscore *= 0.9 if @attacker.pbOpposingSide.effects[:ToxicSpikes] > 0
              miniscore *= 1.2 if @mondata.skill >= BESTSKILL && @battle.FE == :CORROSIVE # can't be absorbed
            end
          end
        end
      when 0x105 # Stealth Rock / Stone Axe
        if @attacker.pbOpposingSide.effects[:StealthRock]
          miniscore = 0 if @move.pbIsStatus?
        else
          if @mondata.skill >= BESTSKILL && @battle.FE == :WASTELAND # Wasteland interaction
            score = 0 if @move.pbIsStatus?
            unless @opponent.ability == :MAGICGUARD
              eff = PBTypes.typesEff(:ROCK, @opponent.types, inverse: @battle.inverse?)
              damage = (@opponent.totalhp / 4.0 * eff.multiplier).floor
              score += wastelandhazardcode(damage)
            end
          else # Normal interaction
            miniscore = hazardcode()
            miniscore *= 1.05 if @attacker.moves.any? { |moveloop| moveloop != nil && (moveloop.move == :SPIKES || moveloop.move == :TOXICSPIKES) }
            if @mondata.skill >= BESTSKILL
              miniscore *= 2 if [:CAVE, :ROCKY].include?(@battle.FE)
              miniscore *= 1.3 if @battle.FE == :CRYSTALCAVERN # crystal rocks
              miniscore *= 1.3 if Rejuv && @battle.FE == :CORRUPTED # poison rocks
              miniscore *= 1.3 if Rejuv && [:DRAGONSDEN, :VOLCANICTOP, :INFERNAL].include?(@battle.FE) # fire rocks
            end
          end
        end
      when 0x106, 0x107, 0x108 # Grass Pledge, Fire Pledge, Water Pledge
        miniscore = pledgecode()
      when 0x10a # Brick Break, Psychic Fangs
        miniscore = brickbreakcode()
      when 0x10b # High Jump Kick, Jump Kick, Supercell Slam
        miniscore = jumpcode(score)
      when 0x10c # Substitute
        miniscore = subcode()
      when 0x10d # Curse
        if @attacker.hasType?(:GHOST)
          miniscore = spoopycode()
          miniscore = 0 if @battle.FE == :HOLY
        else
          miniscore = selfstatboost([1, 1, 0, 0, 0, 0, 0])
          miniscore *= selfstatdrop([0, 0, 0, 0, 1, 0, 0], score)
        end
      when 0x10e # Spite
        miniscore = spitecode()
      when 0x10f # Nightmare
        miniscore = nightmarecode()
        miniscore *= 0 if @battle.FE == :RAINBOW
      when 0x110 # Rapid Spin
        score += 20 if @attacker.effects[:LeechSeed] >= 0
        score += 10 if @attacker.effects[:MultiTurn] > 0
        if @attacker.pbNonActivePokemonCount > 0
          score += 25 if @attacker.pbOwnSide.effects[:StealthRock]
          score += 25 if @attacker.pbOwnSide.effects[:StickyWeb]
          score += (10 * @attacker.pbOwnSide.effects[:Spikes])
          score += (15 * @attacker.pbOwnSide.effects[:ToxicSpikes])
          miniscore = hazardremovalcode()
        end
        miniscore += selfstatboost([0, 0, 0, 0, 1, 0, 0]) if Gen > 7
      when 0x111 # Future Sight, Doom Desire
        miniscore = futurecode()
      when 0x112 # Stockpile
        if @attacker.effects[:Stockpile] < 3
          miniscore = selfstatboost([0, 1, 0, 1, 0, 0, 0])
        else
          miniscore = 0
        end
      when 0x113 # Spit Up
        if @attacker.effects[:Stockpile] == 0
          miniscore = 0
        else
          miniscore = antistatcode([0, @attacker.effects[:Stockpile], 0, 0, @attacker.effects[:Stockpile], 0, 0], score)
          if @attacker.pbHasMove?(:SWALLOW) && @attacker.hp / (@attacker.totalhp.to_f) < 0.66
            miniscore *= 0.8
            miniscore *= 0.5 if @attacker.hp < 0.4 * @attacker.totalhp
          end
        end
      when 0x114 # Swallow
        if @attacker.effects[:Stockpile] == 0
          miniscore = 0
        else
          recoveramount = getHealAmount(@attacker, @move)
          miniscore = recovercode(recoveramount)
          miniscore *= selfstatdrop([0, @attacker.effects[:Stockpile], 0, 0, @attacker.effects[:Stockpile], 0, 0], score)
        end
      when 0x115 # Focus Punch
        miniscore = focuscode()
      when 0x116 # Sucker Punch, Thunderclap
        miniscore = suckercode()
      when 0x117 # Follow Me, Rage Powder
        miniscore = followcode()
      when 0x118 # Gravity
        if @battle.FE != :DEEPEARTH
          miniscore = gravicode()
          if @battle.state.effects[:Gravity] == 0 && @mondata.skill >= BESTSKILL
            if @battle.FE == :NEWWORLD
              score *= 2 if !@attacker.hasType?(:FLYING) && !PBStuff::LevitateAbilities.include?(@attacker.ability)
              score *= 2 if @opponent.hasType?(:FLYING) || PBStuff::LevitateAbilities.include?(@opponent.ability)
              if pbPartyHasType?(:PSYCHIC) || pbPartyHasType?(:FAIRY) || pbPartyHasType?(:DARK)
                score *= 2
                score *= 2 if @attacker.hasType?(:PSYCHIC) || @attacker.hasType?(:FAIRY) || @attacker.hasType?(:DARK)
              end
            end
          end
        end
      when 0x119 # Magnet Rise
        miniscore = magnocode()
        miniscore *= 1.3 if @mondata.skill >= BESTSKILL && ([:ELECTERRAIN, :FACTORY, :SHORTCIRCUIT].include?(@battle.FE) || @battle.OV == :ELECTERRAIN)
      when 0x11a # Telekinesis
        miniscore = telecode()
      # when 0x11b # Sky Uppercut
      when 0x11c # Smack Down, Thousand Arrows
        miniscore = smackcode()
      when 0x11d # After You
        miniscore = afteryoucode()
      when 0x11e # Quash
        miniscore = quashcode()
      when 0x11f # Trick Room
        miniscore = trcode()
        if @mondata.skill >= BESTSKILL
          miniscore *= 1.5 if [:CHESS, :NEWWORLD, :PSYTERRAIN].include?(@battle.FE) || (Rejuv && @battle.FE == :STARLIGHT) # Chess/New World/Psychic Terrain
        end
      when 0x120 # Gen 8 Teleport
        miniscore = pivotcode()
      # when 0x121 # Foul Play
      # when 0x122 # Secret Sword, Psystrike, Psyshock
      when 0x123 # Synchronoise
        score = 0 if !@opponent.types.intersect?(@attacker.types)
      when 0x124 # Wonder Room
        miniscore = wondercode()
      when 0x125 # Last Resort
        miniscore = !@attacker.canLastResort? ? 0 : 1
      when 0x132 # Shadow Shed (like a hut or a tool shed, i presume.)
        miniscore = brickbreakcode()
      when 0x133 # King's Shield
        miniscore = protecteffectcode()
        if !pbAIfaster?() && @attacker.species == :AEGISLASH && @attacker.form == 1
          score *= 4
          # experimental -- cancels out drop if killing moves
          score *= 6 if initialscores.length > 0 && hasgreatmoves()
        end
      when 0x134 # Electric Terrain
        miniscore = electricterraincode()
      when 0x135 # Grassy Terrain
        miniscore = grassyterraincode()
      when 0x136 # Misty Terrain
        miniscore = mistyterraincode()
      when 0x138 # Noble Roar, Tearful Look
        statarray = [1, 0, 1, 0, 0, 0, 0]
        statarray = [2, 0, 2, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @move.move == :NOBLEROAR && [:FAIRYTALE, :DRAGONSDEN].include?(@battle.FE)
        miniscore = oppstatdrop(statarray)
      when 0x139 # Draining Kiss, Oblivion Wing
        miniscore = absorbcode()
        miniscore *= Math.sqrt(petrifycode()) if @battle.FE == :DEUXFINALIS && @move.move == :OBLIVIONWING
      when 0x13a # Aromatic Mist
        miniscore = arocode(PBStats::SPDEF)
      when 0x13b # Eerie Impulse
        statarray = [0, 0, 2, 0, 0, 0, 0]
        statarray = [0, 0, 3, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && @battle.FE == :ELECTERRAIN
        miniscore = oppstatdrop(statarray)
      when 0x13c # Belch
        miniscore = 0 if !@attacker.permeffs[:Belch] && @attacker.crested != :SWALOT
      when 0x13d # Parting Shot
        miniscore = pivotcode()
        statarray = [1, 0, 1, 0, 0, 0, 0]
        statarray = [1, 0, 1, 0, 1, 0, 0] if @mondata.skill >= BESTSKILL && @battle.FE == :FROZENDIMENSION
        statarray = [2, 0, 2, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && (@battle.ProgressiveFieldCheck(PBFields::CONCERT) || @battle.FE == :BACKALLEY)
        miniscore *= oppstatdrop(statarray)
      when 0x13e # Geomancy
        miniscore = weaselslashcode() unless @mondata.skill >= BESTSKILL && [:DEEPEARTH, :STARLIGHT].include?(@battle.FE)
        miniscore *= selfstatboost([0, 0, 2, 2, 2, 0, 0])
        if @battle.FE == :NEWWORLD
          miniscore *= 2 if !@attacker.isAirborne?
          miniscore *= 2 if @opponent.isAirborne?
          if pbPartyHasType?(:PSYCHIC) || pbPartyHasType?(:FAIRY) || pbPartyHasType?(:DARK)
            miniscore *= 2
            miniscore *= 2 if @attacker.hasType?(:PSYCHIC) || @attacker.hasType?(:FAIRY) || @attacker.hasType?(:DARK)
          end
        end
      when 0x13f # Venom Drench
        if @opponent.status == :POISON || [:CORROSIVE, :CORROSIVEMIST, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE)
          miniscore = oppstatdrop([1, 0, 1, 0, 1, 0, 0])
        else
          miniscore = 0
        end
      when 0x140 # Spiky Shield
        miniscore = protecteffectcode()
      when 0x141 # Sticky Web
        if @attacker.pbOpposingSide.effects[:StickyWeb]
          miniscore = 0
        else
          if @mondata.skill >= BESTSKILL && @battle.FE == :WASTELAND # Wasteland interaction
            miniscore = oppstatdrop([0, 0, 0, 0, 4, 0, 0])
          else # Normal interaction
            miniscore = hazardcode
            miniscore *= 2 if @battle.FE == :FOREST && @mondata.skill >= BESTSKILL
          end
        end
      when 0x142 # Topsy Turvy
        miniscore = turvycode()
        if !Rejuv && @battle.canChangeFE?(:INVERSE)
          for type in @opponent.types
            effcheck = PBTypes.typesEff(type, @attacker.types, inverse: @battle.inverse?)
            score *= 2 if effcheck.superEffective?
            score *= 0.5 if effcheck.resisted?
            score *= 0.1 if effcheck.immune?
          end
          for type in @attacker.types
            effcheck = PBTypes.typesEff(type, @opponent.types, inverse: @battle.inverse?)
            score *= 0.5 if effcheck.superEffective?
            score *= 2 if effcheck.resisted?
            score *= 3 if effcheck.immune?
           end
        end
      when 0x143 # Forest's Curse
        miniscore = opptypeaddcode(:GRASS)
        miniscore *= spoopycode() if [:FOREST, :FAIRYTALE, :BEWITCHED].include?(@battle.FE)
      when 0x144 # Trick or Treat
        miniscore = opptypeaddcode(:GHOST)
      when 0x145 # Fairy Lock
        miniscore = fairylockcode()
      when 0x146 # Magnetic Flux
        if !(@attacker.ability == :PLUS || @attacker.ability == :MINUS || @attacker.pbPartner.ability == :PLUS || @attacker.pbPartner.ability == :MINUS)
          if Rejuv && @battle.FE == :ELECTERRAIN
            miniscore = selfstatboost([0, 1, 0, 1, 0, 0, 0])
          else
            miniscore = 0
          end
        elsif @attacker.ability == :PLUS || @attacker.ability == :MINUS
          miniscore = selfstatboost([0, 1, 0, 1, 0, 0, 0])
          miniscore = selfstatboost([0, 2, 0, 2, 0, 0, 0]) if Rejuv && @battle.FE == :ELECTERRAIN
        elsif @attacker.pbPartner.stages[PBStats::SPDEF] != 6 && @attacker.pbPartner.stages[PBStats::DEFENSE] != 6
          miniscore = 0.7
          miniscore *= 1.3 if initialscores.length > 0 && hasbadmoves(20)
          miniscore *= 1.1 if @attacker.pbPartner.hp > @attacker.pbPartner.totalhp * 0.75
          miniscore *= 0.3 if @attacker.pbPartner.effects[:Yawn] > 0 || @attacker.pbPartner.effects[:LeechSeed] >= 0 || @attacker.pbPartner.effects[:Attract] >= 0 || !@attacker.pbPartner.status.nil?
          miniscore *= 0.3 if checkAImoves(PBStuff::PHASEMOVE)
          miniscore *= 0.5 if @opponent.ability == :UNAWARE
          miniscore *= 1.2 if hpGainPerTurn(@attacker.pbPartner) > 1
        end
      when 0x147 # Fell Stinger
        if @attacker.stages[PBStats::ATTACK] != 6 && score >= 100
          miniscore = 2.0
          miniscore *= 2 if pbAIfaster?(@move)
        end
      when 0x148 # Ion Deluge
        miniscore = electricterraincode()
        miniscore *= moveturnselectriccode(false, false)
      when 0x149 # Crafty Shield
        miniscore = craftyshieldcode()
        miniscore *= selfstatboost([0, 1, 0, 1, 0, 0, 0]) if @mondata.skill >= BESTSKILL && @battle.FE == :FAIRYTALE
      when 0x150 # Flower Shield
        miniscore = arocode(PBStats::DEFENSE)
        score = flowershieldcode(score)
      when 0x151 # Rototiller
        miniscore = arocode(PBStats::ATTACK)
        score = rotocode(score)
      when 0x152 # Powder
        miniscore = powdercode()
      when 0x153 # Electrify
        miniscore = moveturnselectriccode(true, false)
        miniscore *= [opptypechangecode(:ELECTRIC), 1].max if Rejuv && @battle.FE == :ELECTERRAIN
      when 0x154 # Mat Block
        if @attacker.turncount == 0 && (pbAIfaster?() || pbAIfaster?(nil, nil, @attacker, @opponent.pbPartner))
          miniscore = protectcode()
          miniscore *= 2 if @battle.doublebattle
        else
          miniscore = 0
        end
      when 0x155, 0x156 # Thousand Waves, Anchor Shot, Spirit Shackle
        miniscore = meanlookcode()
      when 0x159 # Hyperspace Fury
        if (@attacker.species == :HOOPA && @attacker.form == 1) || (Rejuv && @attacker.species == :GARDEVOIR && @attacker.form == 3)
          miniscore *= feintcode()
          if @attacker.ability == :CONTRARY
            miniscore *= selfstatboost([0, 1, 0, 0, 0, 0, 0])
          else
            miniscore *= selfstatdrop([0, 1, 0, 0, 0], score)
          end
        else
          miniscore = 0
        end
      when 0x15b # Aurora Veil
        miniscore = screencode()
        miniscore *= 1.5 if @mondata.skill >= BESTSKILL && @battle.FE == :MIRROR # Mirror
      when 0x15c # Baneful Bunker
        miniscore = protecteffectcode()
        if !@opponent.status.nil?
          miniscore *= 0.8
        elsif @opponent.pbCanPoison?(@attacker, nil)
          miniscore *= 1.3
          miniscore *= 1.3 if @attacker.ability == :MERCILESS
          miniscore *= 1.3 if @attacker.crested == :ARIADOS
          miniscore *= 0.3 if @opponent.ability == :POISONHEAL
          miniscore *= 0.3 if @opponent.crested == :ZANGOOSE
          miniscore *= 0.7 if @opponent.ability == :TOXICBOOST
        end
      when 0x15d # Beak Blast
        miniscore = beakcode()
      when 0x15e # Burn Up
        miniscore = burnupcode(:FIRE)
      when 0x15f # Clanging Scales
        if @attacker.ability == :CONTRARY
          miniscore = selfstatboost([0, 1, 0, 0, 0, 0, 0])
        else
          miniscore = antistatcode([0, 1, 0, 0, 0], initialscores[scoreindex]) if @battle.FE != :DEUXFINALIS
        end
      when 0x160 # Core Enforcer
        if !PBStuff::FIXEDABILITIES.include?(@opponent.ability) && !(@mondata.oppitemworks && @opponent.item == :ABILITYSHIELD) && !@opponent.effects[:GastroAcid] && @opponent.effects[:Substitute] <= 0 && (!pbAIfaster?(@move) || checkAIpriority())
          miniscore = getAbilityDisruptScore(@attacker, @opponent)
          miniscore = pbReduceWhenKills(miniscore)
        end
      when 0x161 # First Impression
        if @attacker.turncount != 0
          miniscore = 0
        else
          miniscore = score >= 110 ? 1.1 : 1.0
          miniscore *= feintcode() if @battle.FE == :COLOSSEUM
        end
      when 0x162 # Floral Healing
        miniscore = healpulsecode()
        miniscore *= 1.5 if [:GRASSY, :FAIRYTALE].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5)
        miniscore *= 0.2 if @attacker.status != :POISON && [:CORROSIVE, :CORROSIVEMIST].include?(@battle.FE)
      when 0x163 # Gear Up
        if !(@attacker.ability == :PLUS || @attacker.ability == :MINUS || @attacker.pbPartner.ability == :PLUS || @attacker.pbPartner.ability == :MINUS)
          miniscore = 0
        else
          miniscore = 1.0
          increment = @battle.FE == :FACTORY ? 2 : 1
          if @attacker.pbPartner.ability == :PLUS || @attacker.pbPartner.ability == :MINUS
            miniscore *= oppstatboost([increment, 0, increment, 0, 0, 0])
            miniscore *= 1.3 if initialscores.length > 0 && hasbadmoves(20)
            miniscore *= 1.1 if @attacker.pbPartner.hp > @attacker.pbPartner.totalhp * 0.75
            miniscore *= 0.3 if @attacker.pbPartner.effects[:Yawn] > 0 || @attacker.pbPartner.effects[:LeechSeed] >= 0 || @attacker.pbPartner.effects[:Attract] >= 0 || !@attacker.pbPartner.status.nil?
          end
          if @attacker.ability == :PLUS || @attacker.ability == :MINUS
            miniscore *= selfstatboost([increment, 0, increment, 0, 0, 0])
            miniscore *= 1.3 if initialscores.length > 0 && hasbadmoves(20)
            miniscore *= 1.1 if @attacker.hp > @attacker.totalhp * 0.75
            miniscore *= 0.3 if @attacker.effects[:Yawn] > 0 || @attacker.effects[:LeechSeed] >= 0 || @attacker.effects[:Attract] >= 0 || !@attacker.status.nil?
          end
          miniscore *= 0.3 if checkAImoves(PBStuff::PHASEMOVE)
          miniscore *= 0.5 if @opponent.ability == :UNAWARE
        end
      when 0x164 # Instruct
        score *= instructcode()
      when 0x165 # Laser Focus
        miniscore = permacritcode(initialscores[scoreindex])
      when 0x166 # Moongeist Beam, Sun Steel Strike
      when 0x167 # Pollen Puff
        if scoringAgainstPartner?
          score = 15 * healpulsecode()
          score = 0 if @opponent.ability == :BULLETPROOF
        end
      when 0x168 # Psychic Terrain
        miniscore = psychicterraincode()
      when 0x169 # Purify
        miniscore = almostuselessmovecode()
      when 0x16b # Shell Trap
        miniscore = shelltrapcode()
      when 0x16c # Shore Up
        recoveramount = getHealAmount(@attacker, @move)
        miniscore = recovercode(recoveramount)
        miniscore *= selfstatboost([0, 2, 0, 0, 0, 0, 0]) if @attacker.ability == :WATERCOMPACTION && @mondata.skill >= BESTSKILL && [:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE)
      when 0x16d # Sparkling Aria
        miniscore = @opponent.status == :BURN && !secondaryEffectNegated?() ? 0.6 : 1.0
      when 0x16e # Spectral Thief
        miniscore = spectralthiefcode()
      when 0x16f # Speed Swap
        miniscore = stupidmovecode()
      when 0x170 # Spotlight
        miniscore = spotlightcode()
      when 0x171 # Stomping Tantrum, Temper Flare
        miniscore = 1.0
        miniscore *= 0.8 if Rejuv && @move.move == :STOMPINGTANTRUM && @battle.FE == :CHESS && @attacker.ability != :SHELLARMOR && @attacker.ability != :BATTLEARMOR
      when 0x172 # Strength Sap
        if @opponent.pbTooLow?(PBStats::ATTACK)
          miniscore = 0.0
        else
          hpdrained = getDrainAmount(@attacker, @opponent, @move)
          if @opponent.ability == :LIQUIDOOZE
            miniscore = [1 - (hpdrained / @attacker.hp.to_f), 0.01].max
          else
            miniscore = recovercode(hpdrained)
          end
          statarray = [1, 0, 0, 0, 0, 0, 0]
          statarray = [1, 0, 1, 0, 0, 0, 0] if @battle.FE == :BEWITCHED
          statdropscore = oppstatdrop(statarray)
          miniscore *= statdropscore unless statdropscore == 0
        end
      when 0x173 # Throat Chop
        miniscore = chopcode()
      when 0x174 # Toxic Thread
        miniscore = poisoncode()
        amount = Gen >= Champs ? 2 : 1
        miniscore *= oppstatdrop([0, 0, 0, 0, amount, 0, 0])
      when 0x175 # Mind Blown/Steel Beam
        miniscore = pussydeathcode(initialscores[scoreindex])
      when 0x176 # Photon Geyser
      when 0x177 # Plasma Fists
        miniscore = electricterraincode()
        miniscore *= moveturnselectriccode(false, true)
      when 0x179 # Snipe Shot
      when 0x17A # Stuff Cheeks
        if pbIsBerry?(@attacker.item)
          miniscore = selfstatboost([0, 2, 0, 0, 0, 0, 0])
          case @attacker.item
            when :LUMBERRY then miniscore *= 2 if !@attacker.status.nil?
            when :CHERIBERRY then miniscore *= 2 if @attacker.status == :PARALYSIS
            when :RAWSTBERRY then miniscore *= 2 if @attacker.status == :BURN
            when :PECHABERRY then miniscore *= 2 if @attacker.status == :POISON
            when :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY then miniscore *= 1.6 if @attacker.hp * (1.0 / @attacker.totalhp) < 0.66
            when :LIECHIBERRY then miniscore *= 1.5 if @attacker.attack > @attacker.spatk
            when :PETAYABERRY then miniscore *= 1.5 if @attacker.spatk > @attacker.attack
            when :APICOTBERRY, :GANLONBERRY, :STARFBERRY then miniscore *= 1.5
            when :CUSTAPBERRY, :SALACBERRY then miniscore *= pbAIfaster? ? 1.1 : 1.5
          end
        else
          score *= 0
        end
      when 0x17B # No Retreat
        if !@attacker.effects[:NoRetreat]
          statarray = [1, 1, 1, 1, 1, 0, 0]
          statarray = [2, 0, 2, 0, 2, 0, 0]  if [:CHESS, :BIGTOP].include?(@battle.FE)
          statarray = [2, 2, 2, 2, 2, 0, 0]  if @battle.FE == :COLOSSEUM
          miniscore = selfstatboost(statarray)
          if [:CHESS, :BIGTOP].include?(@battle.FE)
            miniscore *= selfstatdrop([0, 1, 0, 1, 0, 0, 0], score) if @mondata.attitemworks && @attacker.item != :WHITEHERB
            if @mondata.attitemworks && @attacker.item == :WHITEHERB
              miniscore *= 1.3
            else
              miniscore *= 0.8
            end
          end
        else
          score *= 0
        end
      when 0x17C # Tar Shot
        miniscore = oppstatdrop([0, 0, 0, 0, 1, 0, 0])
        if !@opponent.effects[:TarShot] && !PBTypes.typesEff(:FIRE, @opponent.types, inverse: @battle.inverse?).immune? && ![:FLASHFIRE, :WELLBAKEDBODY].include?(@opponent.ability)
          if pbPartyHasType?(:FIRE)
            miniscore *= 1.2 unless @battle.FE == :WATERSURFACE
          end
          miniscore *= 1.2 if [:VOLCANIC, :VOLCANICTOP].include?(@battle.FE)
        end
        if [:MURKWATERSURFACE, :CORRUPTED].include?(@battle.FE)
          sidescore = poisoncode()
          miniscore *= sidescore if sidescore > 1
        end
      when 0x17D # Magic Powder
        miniscore = opptypechangecode(:PSYCHIC)
        miniscore *= opptypechangecode(:FAIRY) if @battle.FE == :FAIRYTALE
        miniscore *= [sleepcode(), 1].max if [:HAUNTED, :BEWITCHED].include?(@battle.FE)
      when 0x17E # Dragon Darts
        if pbDragonDartTargetting(@attacker, @move, @basemove).length < 2
          miniscore = multihitcode()
        else
          # in doubles, the intended target has ways to negate the move (protect/ switching into an immunity) increase score
          # because if this is applied dragon darts can still hit the partner anyway, the move is safer to use
          miniscore = 1.2 if checkAImoves(PBStuff::PROTECTMOVE) || $cache.types[@move.pbType(@attacker)].immune.any? { |type| pbPartyHasType?(type, @opponent.index) }
        end
      when 0x17F # teatime
        miniscore = teaslurpcode()
      when 0x180 # Octolock
        miniscore = firespincode()
        miniscore *= @battle.FE == :UNDERWATER ? oppstatdrop([0, 2, 0, 2, 0, 0, 0]) : oppstatdrop([0, 1, 0, 1, 0, 0, 0])
      when 0x182 # Court Change
        miniscore = defogcode()
      when 0x183 # Clangorous Soul
        statarray = [1, 1, 1, 1, 1, 0, 0]
        hploss = [(@attacker.totalhp / 3.0).floor, 1].max
        if @mondata.skill >= BESTSKILL && ([:BIGTOP, :DRAGONSDEN].include?(@battle.FE) || @battle.ProgressiveFieldCheck(PBFields::CONCERT))
          statarray = [2, 2, 2, 2, 2, 0, 0]
          hploss = [(@attacker.totalhp / 2.0).floor, 1].max
        elsif @mondata.skill >= BESTSKILL && @battle.FE == :DEUXFINALIS
          statarray = [1, 1, 1, 1, 1, 0, 0]
          hploss = [(@attacker.totalhp / 4.0).floor, 1].max
        end
        miniscore = selfStatBoostHPLoss(statarray, hploss)
      when 0x185 # Decorate
        opp1 = @attacker.pbOppositeOpposing
        opp2 = opp1.pbPartner
        # if partner would die this turn, move gets redirected to opposite opposing
        opp1dmg = checkAIdamage(@attacker.pbPartner, opp1)
        opp2dmg = checkAIdamage(@attacker.pbPartner, opp2)
        if opp1.ability != :CONTRARY
          score = 1 if opp1dmg >= @attacker.pbPartner.hp
          score = 1 if opp2dmg >= @attacker.pbPartner.hp
        end
        score = 1 if !scoringAgainstPartner? && @opponent.ability != :CONTRARY
        if @opponent.ability == :CONTRARY
          miniscore = oppstatdrop([2, 0, 2, 0, 0, 0, 0])
        else
          miniscore = oppstatboost([2, 0, 2, 0, 0])
        end
        # check if partner is liable to be outsped by an opponent and get KOed
        score = 1 if opp1dmg >= @attacker.pbPartner.hp && !pbAIfaster?(nil, nil, @attacker.pbPartner, opp1)
        score = 1 if opp2dmg >= @attacker.pbPartner.hp && !pbAIfaster?(nil, nil, @attacker.pbPartner, opp2)
      when 0x186 # Aura Wheel
        miniscore = @attacker.species != :MORPEKO ? 0 : selfstatboost([0, 0, 0, 0, 1, 0, 0])
      when 0x187 # Life Dew
        recoveramount = getHealAmount(@attacker, @move)
        miniscore = lifedewcode(recoveramount, false)
        miniscore *= 0.5 if @battle.FE == :CORROSIVEMIST && !@attacker.hasType?(:POISON) && !@attacker.hasType?(:STEEL) # self poisoning (provisonal, kind of a complex topic would like to invert poisoncode)
        miniscore *= aquaringcode() if @battle.FE == :WATERSURFACE
      when 0x188 # Obstruct
        miniscore = protecteffectcode()
      when 0x189 # Jaw Lock
        miniscore = meanlookcode()
      when 0x18e # Gen 8 Howl
        statarray = [1, 0, 0, 0, 0, 0, 0]
        statarray = [2, 0, 0, 0, 0, 0, 0] if @mondata.skill >= BESTSKILL && (@battle.FE == :COLOSSEUM || @battle.ProgressiveFieldCheck(PBFields::CONCERT))
        miniscore = selfstatboost(statarray)
        miniscore *= 1.5 if !@attacker.pbPartner.isFainted? && ![:SOUNDPROOF, :CONTRARY].include?(@attacker.pbPartner.ability) && @attacker.pbPartner.attack > @attacker.pbPartner.spatk && @attacker.pbPartner.stages[PBStats::ATTACK] <= 4
      when 0x306 # Steel Roller / Ice Spinner
        base = @move.move == :STEELROLLER ? 0 : 1
        miniscore = @battle.canEndTempFieldOrOverlay? ? getFieldDisruptScore(tempOnly: true) : base
        miniscore *= 1.3 if @opponent.ability == :SEEDSOWER
      when 0x307 # Scale Shot
        miniscore = multihitcode()
        miniscore *= selfstatboost([0, 0, 0, 0, 1, 0, 0])
        miniscore *= selfstatdrop([0, 1, 0, 0, 0, 0, 0], score) if @battle.FE != :DEUXFINALIS
      when 0x308 # Meteor Beam
        miniscore = selfstatboost([0, 0, 1, 0, 0, 0, 0])
        miniscore *= weaselslashcode() unless [:STARLIGHT, :NEWWORLD].include?(@battle.FE)
      when 0x309 # Shell Side Arm
        miniscore = poisoncode()
      when 0x313 # Burning Jealousy
        miniscore = burncode() if (checkAImoves(PBStuff::SETUPMOVE) && !pbAIfaster?()) || @opponent.effects[:Jealousy]
      when 0x314 # Lash Out
        miniscore = 1.5 if checkAImoves(PBStuff::STATNERFMOVE) && !pbAIfaster?() && !@attacker.effects[:LashOut]
      # score is already higher from damage if lashout condition is fulfilled when turn starts (via intimidate etc)
      when 0x315 # Poltergeist
        miniscore = 0 if @opponent.item.nil?
      when 0x316 # Corrosive Gas
        miniscore = knockcode()
        miniscore *= oppstatdrop([1, 1, 1, 1, 1, 0, 0]) if [:BACKALLEY, :CITY, :CORROSIVEMIST].include?(@battle.FE)
      when 0x317 # Coaching
        if @opponent.ability == :CONTRARY
          miniscore = oppstatdrop([1, 1, 0, 0, 0, 0, 0])
        else
          miniscore = oppstatboost([1, 1, 0, 0, 0])
        end
      when 0x318 # Jungle Healing / Lunar Blessing
        recoveramount = getHealAmount(@attacker, @move)
        miniscore = lifedewcode(recoveramount, true)
      when 0x319 # Surging Strikes
        miniscore = permacritcode(initialscores[scoreindex])
        miniscore *= multihitcode()
      when 0x320 # Eerie Spell
        miniscore = spitecode() unless secondaryEffectNegated?()
      # PLA moves
      when 0x500 # Dire Claw
        miniscore = (sleepcode() + poisoncode() + paracode()) / 3
      when 0x501 # Victory Dance
        statarray = [1, 1, 0, 0, 1, 0, 0]
        statarray = [2, 2, 0, 0, 2, 0, 0] if @mondata.skill >= BESTSKILL && [:BIGTOP, :DANCEFLOOR].include?(@battle.FE)
        miniscore = selfstatboost(statarray)
      when 0x502 # Barb Barrage
        miniscore = poisoncode()
      when 0x503 # Triple Arrows
        miniscore = oppstatdrop([0, 1, 0, 0, 0, 0, 0])
        miniscore *= flinchcode()
      when 0x504 # Infernal Parade
        miniscore = burncode()
      when 0x505 # Take Heart
        statarray = [0, 0, 1, 1, 0, 0, 0]
        statarray = [0, 0, 2, 2, 0, 0, 0] if @mondata.skill >= BESTSKILL && [:WATERSURFACE, :UNDERWATER].include?(@battle.FE)
        miniscore = selfstatboost(statarray)
        miniscore *= [refreshcode(), 1].max
      # Gen 9 Moves
      when 0x506 # Axe Kick
        miniscore = jumpcode(score)
        miniscore *= confucode()
      when 0x507 # Alluring Voice
        miniscore = confucode() if (checkAImoves(PBStuff::SETUPMOVE) && !pbAIfaster?()) || @opponent.effects[:Jealousy]
      when 0x509 # Triple Dive
        miniscore = multihitcode()
      when 0x50A # Population Bomb
        miniscore = multihitcode() * 1.2 # More extreme scoring
      when 0x50B # Hyper Drill / Mighty Cleave
        # They technically don't also break protect for other moves, but
        # just using feintcode is a quick solution which is 99% correct.
        miniscore = feintcode()
      when 0x50C # Silk Trap
        miniscore = protecteffectcode()
      when 0x50D # Spicy Extract
        if @opponent.ability == :CONTRARY
          miniscore = oppstatboost([0, 2, 0, 0, 0], false, true)
          miniscore *= oppstatdrop([2, 0, 0, 0, 0, 0, 0])
        else
          miniscore = oppstatboost([2, 0, 0, 0, 0], false, true)
          miniscore *= oppstatdrop([0, 2, 0, 0, 0, 0, 0])
        end
      when 0x50E # Spin Out
        statarray = [0, 0, 0, 0, 2, 0, 0]
        if @attacker.ability == :CONTRARY || @battle.state.effects[:TrickRoom] > 2
          miniscore = selfstatboost(statarray)
        else
          miniscore = selfstatdrop(statarray, score)
        end
      when 0x50F # Mortal Spin
        score += 20 if @attacker.effects[:LeechSeed] >= 0
        score += 10 if @attacker.effects[:MultiTurn] > 0
        if @attacker.pbNonActivePokemonCount > 0
          score += 25 if @attacker.pbOwnSide.effects[:StealthRock]
          score += 25 if @attacker.pbOwnSide.effects[:StickyWeb]
          score += (10 * @attacker.pbOwnSide.effects[:Spikes])
          score += (15 * @attacker.pbOwnSide.effects[:ToxicSpikes])
          miniscore = hazardremovalcode()
        end
        miniscore *= poisoncode()
      when 0x510 # Doodle
        miniscore = doodlecode()
      when 0x511 # Fillet Away
        statarray = [2, 0, 2, 0, 2, 0, 0]
        hploss = [(@attacker.totalhp / 2.0).floor, 1].max
        miniscore = selfStatBoostHPLoss(statarray, hploss)
      when 0x512 # Raging Bull
        miniscore = brickbreakcode()
      when 0x513 # Make It Rain
        drop = Gen >= Champs ? 2 : 1
        statarray = [0, 0, drop, 0, 0, 0, 0]
        if @attacker.ability == :CONTRARY
          miniscore = selfstatboost(statarray)
        else
          miniscore = selfstatdrop(statarray, score)
          miniscore *= 1.5 if [:SOULHEART, :GRIMNEIGH, :ASONEGRIM].include?(@attacker.ability) || ([:BEASTBOOST, :EELEVATE].include?(@attacker.ability) && @attacker.getHighestRawStat == PBStats::SPATK)
        end
      when 0x514 # Tidy Up
        miniscore = defogcode()
        miniscore *= hazardremovalcode()
        miniscore += selfstatboost([1, 0, 0, 0, 1, 0, 0])
      when 0x516 # Chilly Reception
        miniscore = weathercode()
        miniscore *= snowcode()
        if @mondata.skill >= BESTSKILL
          miniscore *= 1.5 if [:RAINBOW, :MOUNTAIN].include?(@battle.FE) # Rainbow/Mountain
          miniscore *= 2   if @battle.FE == :STARLIGHT && !pbPartyHasType?(:DARK) && !pbPartyHasType?(:FAIRY) && !pbPartyHasType?(:PSYCHIC) # Starlight
        end
        miniscore *= pivotcode()
      when 0x517 # Double Shock
        miniscore = burnupcode(:ELECTRIC)
      when 0x518 # Shed Tail
        miniscore = pivotcode() * subcode()
      # when 0x519 # Last Respects
      when 0x51A # Glaive Rush
        miniscore = glaiverushcode()
      when 0x51C # Salt Cure
        miniscore = saltcurecode
        miniscore *= 1.5 if @opponent.effects[:Substitute] == 0 && !@opponent.effects[:SaltCure] && !secondaryEffectNegated?()
        miniscore = pbReduceWhenKills(miniscore)
      when 0x51D # Order Up
        statarray = [0, 0, 0, 0, 0, 0, 0]
        if @attacker.effects[:Commandee] && @attacker.pbPartner.effects[:Commander]
          case @attacker.pbPartner.form
            when 0 then statarray = [1, 0, 0, 0, 0, 0, 0]
            when 1 then statarray = [0, 1, 0, 0, 0, 0, 0]
            when 2 then statarray = [0, 0, 0, 0, 1, 0, 0]
          end
        end
        miniscore = selfstatboost(statarray)
      when 0x51E # Matcha Gotcha
        miniscore = absorbcode()
        miniscore *= burncode()
      when 0x51F # Syrup Bomb
        miniscore = @opponent.ability == :CONTRARY ? oppstatboost([0, 0, 0, 0, 1]) : oppstatdrop([0, 0, 0, 0, 1, 0, 0])
      when 0x521 # Electro Shot
        miniscore = selfstatboost([0, 0, 1, 0, 0, 0, 0])
        miniscore *= weaselslashcode() if weather != :RAINDANCE && !(@battle.FE == :ELECTERRAIN)
      when 0x524 # Burning Bulwark
        miniscore = protecteffectcode()
        if !@opponent.status.nil?
          miniscore *= 0.8
        elsif @opponent.pbCanBurn?(@attacker, nil)
          miniscore *= 1.3
          miniscore *= 1.3 if pbRoughStat(@opponent, PBStats::ATTACK) > pbRoughStat(@opponent, PBStats::SPATK)
          miniscore *= 0.3 if @opponent.ability == :GUTS || @opponent.ability == :FLAREBOOST
        end
      when 0x525 # Dragon Cheer
        miniscore = dragoncheercode()
      when 0x526 # Upper Hand
        miniscore = upperhandcode()
      when 0x527 # Revival Blessing
        miniscore = revivalcode
      when 0x529 # Chloroblast
        miniscore = pussydeathcode(initialscores[scoreindex])
      # Rejuv Customs
      when 0x200 # Decimation
        miniscore = decimationcode()
      when 0x201 # Gale Strike
        miniscore = permacritcode(initialscores[scoreindex]) if @attacker.hp <= ((@attacker.totalhp) * 0.5).floor
      when 0x202 # Fever Pitch
        miniscore = 1.0
        miniscore *= 1.5 if @attacker.status == :SLEEP
        miniscore *= volcanoeruptioncode() if @battle.FE == :VOLCANICTOP
      when 0x203 # Arenite Wall
        miniscore = screencode()
      when 0x205 # Desert's Mark
        miniscore = opptypechangecode(:GROUND)
        miniscore *= firespincode()
      # addition for the sandstorm chip marker
      # when 0x206 # Probopog # does this *need* AI?? i don't think it does
      when 0x207 # Aquabatics
        statarray = [0, 0, 1, 0, 1, 0, 0]
        statarray = [0, 0, 2, 0, 2, 0, 0] if @mondata.skill >= BESTSKILL && (@battle.FE == :BIGTOP)
        miniscore = selfstatboost(statarray)
      when 0x208 # Hexing Slash
        miniscore = absorbcode()
        miniscore *= poisoncode()
      when 0x20A # Quicksilver Spear
        miniscore = oppstatdrop([0, 0, 0, 0, 1, 0, 0])
      when 0x20B # Spectral Scream
        miniscore = selfstatboost([0, 2, 0, 0, 0, 0, 0]) + selfstatboost([0, 0, 0, 2, 0, 0, 0])
        miniscore /= 2
      when 0x20C # Gilded Arrow / Gilded Helix
        miniscore = multihitcode() if @move.move == :GILDEDHELIX
      when 0x20D # Super Ultra Mega Death Move
        statarray = move.category == :physical ? [0, 1, 0, 0, 0, 0, 0] : [0, 0, 0, 1, 0, 0, 0]
        miniscore = oppstatdrop(statarray)
      # Z-moves
      when 0x800 # Acid Downpour
        miniscore = (burncode() + paracode() + freezecode() + poisoncode()) / 4 if @battle.FE == :WASTELAND
      when 0x801 # Bloom Doom
        miniscore = grassyterraincode() unless @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN)
      when 0x802 # Shattered Psyche
        miniscore = confucode() if @battle.FE == :PSYTERRAIN
      when 0x803 # Stoked Sparksurfer
        miniscore = paracode()
        miniscore *= electricterraincode()
      when 0x804 # Extreme Evoboost
        miniscore = selfstatboost([2, 2, 2, 2, 2, 0, 0])
      when 0x805 # Genesis Supernova
        miniscore = psychicterraincode()
      when 0x807 # Splintered Stormshards
        miniscore = getFieldDisruptScore(tempOnly: true) if @battle.canEndTempFieldOrOverlay?
        miniscore *= 1.3 if @opponent.ability == :SEEDSOWER
      when 0x808 # Clangorous Soulblaze
        miniscore = selfstatboost([1, 1, 1, 1, 1, 0, 0])
      when 0x80A # Unleashed Power
        miniscore = brickbreakcode()
        miniscore *= feintcode()
      when 0x80B # Blinding Speed
        miniscore = afteryoucode()
      when 0x80C # Elysian Shield
        miniscore = screencode()
        miniscore *= selfstatboost([0, 1, 0, 1, 0, 0, 0])
      when 0x80D # Domain Shift
      # help why is AI using this
      when 0x80E # Chthonic Malady
        miniscore = petrifycode()
        miniscore *= tormentcode()
        miniscore *= oppstatdrop([2, 0, 2, 0, 0, 0, 0])
      when 0x82A # Beast Hunter
        if @battle.doublebattle
          legalmoves = @opponent.pokemon.getAllLegalMoves(true)
          legalmoves += @opponent.pbPartner.pokemon.getAllLegalMoves(true) if @opponent.pbPartner && !@opponent.pbPartner.isFainted?
          score *= 1.05 if legalmoves.any? { |m| m && [:FOLLOWME, :RAGEPOWDER].include?(m) }
        end
    end
    #################### More Scoring ####################
    miniscore *= recoilcode(initialscores[scoreindex]) if @move.recoil > 0
    miniscore *= cooldownmovecode() if @move.hasFlag?(:cooldown)
    miniscore *= nevermisscode(initialscores[scoreindex]) if @move.pbIsDamaging? && @move.accuracy == 0
    miniscore *= jumpcode(initialscores[scoreindex]) if @move.pbIsPhysical?(@attacker) && @attacker.makesContact?(@move) && [:ROCKY, :MIRROR].include?(@battle.FE)

    if @move.zmove && @move.category == :status && @basemove.move == @move.move # eg, focus energy when called by z-nature power is not gonna have its z-power effect
      zpowerscore = zPowerScore()
      if zpowerscore > 0
        miniscore = miniscore == 0 ? 1 : 0.5 if miniscore <= 0 # because z power works even when move fails
        miniscore *= zpowerscore
      end

      effect = ZSTATUSEFFECTS[@move.move]
      miniscore = 0 if statchangecounter(@attacker, 2, 7) == 0 && effect[0] == :reset
    end


    #################### Final Score Return ####################
    score *= miniscore
    score = score.ceil
    score = 0 if score < 0
    return score, miniscore
  end

  def getModifiedMoveScore(finalscores, scoreindex, opponent)
    score = finalscores[scoreindex]
    case @move.function
      when 0xe2 # Memento
        # Basically hasbadmoves(10) but using final scores instead of initial scores
        otherscores = finalscores.filter.with_index { |s, i| i != scoreindex }
        score *= 3 if otherscores.none? { |s| s > 10 }
      when 0x10b, 0x506 # High Jump Kick, Axe Kick
        # If the final score is 0 for a crash damage move, it usually means it will hurt the user
        # So we change the 0 to -1 so that other 0-score moves are preferred over such moves
        score = -1 if score == 0
    end
    if @opponent.effects[:Substitute] > 0 && @move.blockedBySubstitute?(@attacker, @opponent)
      score = 95 if score >= 95 && @move.pbIsDamaging?
    end
    if @move.canThawUser?
      # If user is frozen, prefer moves that can thaw the user
      # If the user has a move that can thaw, other moves get a score of 0 anyway, this just ensures thawing moves have a score above 0 (since thawing moves will thaw the user even if they fail)
      score += 10 if @mondata.skill >= MEDIUMSKILL && @attacker.status == :FROZEN
    end
    return score
  end

  def zPowerScore
    effect = ZSTATUSEFFECTS[@move.move]
    effect = [:heal] if @move.move == :CURSE && @attacker.hasType?(:GHOST)
    score = 0
    if effect.length == 2
      stat, boost = effect[0] - 1, effect[1]
      statboostarray = [0, 0, 0, 0, 0, 0, 0]
      statboostarray[stat] = boost
      score = selfstatboost(statboostarray, true)
    elsif effect[0] == :allstat1
      score = selfstatboost([1, 1, 1, 1, 1], true)
    elsif effect[0] == :crit1
      score = focusenergycode(2)
    elsif effect[0] == :reset
      score = -1.1 * statchangecounter(@attacker, 1, 7)
    elsif effect[0] == :heal
      score = recovercode(@attacker.totalhp, true)
    elsif effect[0] == :heal2
      score = healwishcode()
    elsif effect[0] == :centre
      score = followcode()
    end
    score += 1.5 if PBStuff::CALLERMOVE.include?(@move.move)
    return score
  end

  ######################################################
  # Function (code) subfunctions
  ######################################################
  # All functions here return a modifier to the original score, similar to miniscore

  def sleepcode
    return @move.pbIsDamaging? ? 1 : 0 if !(@opponent.pbCanSleep?(@attacker, @move) && @opponent.effects[:Yawn] == 0)
    return @move.pbIsDamaging? ? 1 : 0 if secondaryEffectNegated?()
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.hydrationActive?
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.crested == :SUICUNE

    miniscore = 1.2
    if @attacker.pbHasMove?(:DREAMEATER) || @attacker.pbHasMove?(:NIGHTMARE) || @attacker.ability == :BADDREAMS ||  attacker.ability == :GRAVITYCONTROL
      miniscore *= 1.5
    end
    miniscore *= (1.2 * hpGainPerTurn)
    miniscore *= 2 if attacker.species == :HYPNO && attacker.form == 1 || (attacker.species == :CLEFABLE && attacker.form == 2)
    miniscore *= 1.3 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::SETUPMOVE.include?(moveloop.move) }
    miniscore *= 1.3 if @attacker.pbHasMove?(:LEECHSEED)
    miniscore *= 1.3 if @attacker.pbHasMove?(:SUBSTITUTE)
    miniscore *= 1.2 if @opponent.hp == @opponent.totalhp
    miniscore *= 0.1 if checkAImoves([:SLEEPTALK, :SNORE, :FEVERPITCH])
    miniscore *= 0.1 if @opponent.ability == :NATURALCURE
    miniscore *= 0.8 if @opponent.ability == :MARVELSCALE
    miniscore *= 0.4 if @opponent.effects[:Confusion] > 0
    miniscore *= 0.5 if @opponent.effects[:Attract] >= 0
    ministat = statchangecounter(@opponent, 1, 7)
    miniscore *= 1 + 0.1 * ministat if ministat > 0
    if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL) || @mondata.roles.include?(:CLERIC) || @mondata.roles.include?(:PIVOT)
      miniscore *= 1.2
    end
    if @initial_scores.length > 0
      miniscore *= 1.3 if hasbadmoves(40)
      miniscore *= 1.5 if hasbadmoves(20)
    end
    miniscore = pbSereneGraceCheck(miniscore) if @move.pbIsDamaging?
    miniscore = pbReduceWhenKills(miniscore)
    return miniscore
  end

  def poisoncode
    return @move.pbIsDamaging? ? 1 : 0 if !@opponent.pbCanPoison?(@attacker, @move)
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.hydrationActive?
    return @move.pbIsDamaging? ? 1 : 0 if secondaryEffectNegated?()
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.crested == :SUICUNE

    miniscore = 1.2
    ministat = 0
    ministat += @opponent.stages[PBStats::DEFENSE]
    ministat += @opponent.stages[PBStats::SPDEF]
    ministat += @opponent.stages[PBStats::EVASION]
    miniscore *= 1 + 0.05 * ministat if ministat > 0
    miniscore *= 2 if @move.function == 0x06 && (checkAIhealing() || checkAIdraining())
    miniscore *= 0.3 if @opponent.ability == :NATURALCURE
    miniscore *= 0.7 if @opponent.ability == :MARVELSCALE
    miniscore *= 0.2 if @opponent.ability == :TOXICBOOST || @opponent.ability == :GUTS || @opponent.ability == :QUICKFEET
    miniscore *= 0.1 if @opponent.ability == :POISONHEAL || @opponent.crested == :ZANGOOSE || @battle.magicGuardAbilities.include?(@opponent.ability)
    miniscore *= 0.7 if @opponent.ability == :SHEDSKIN
    miniscore *= 1.1 if @move.pbIsDamaging? && survivesAt1HP?(@opponent)
    miniscore *= 0.5 if @opponent.ability == :SYNCHRONIZE && @attacker.status.nil? && !@attacker.hasType?(:POISON) && !@attacker.hasType?(:STEEL)
    miniscore *= 0.2 if checkAImoves([:FACADE])
    miniscore *= 0.1 if checkAImoves([:REST])
    miniscore *= 1.5 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
    if @initial_scores.length > 0
      miniscore *= 1.2 if hasbadmoves(30)
    end
    if @attacker.pbHasMove?(:VENOSHOCK, :VENOMDRENCH) || @attacker.ability == :MERCILESS || @attacker.crested == :ARIADOS
      miniscore *= 1.6
    end
    miniscore *= 0.4 if @opponent.effects[:Yawn] > 0
    miniscore = pbSereneGraceCheck(miniscore) if @move.pbIsDamaging?
    miniscore = pbReduceWhenKills(miniscore)
    if @attacker.pokemon.species == :PECHARUNT && @attacker.ability == :POISONPUPPETEER
      confuscore = confucode()
      miniscore *= confuscore unless confuscore == 0
    end
    return miniscore
  end

  def paracode
    return @move.pbIsDamaging? ? 1 : 0 if !@opponent.pbCanParalyze?(@attacker, @move)
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.hydrationActive?
    return @move.pbIsDamaging? ? 1 : 0 if secondaryEffectNegated?()
    return @move.pbIsDamaging? ? 1 : 0 if @move.move == :THUNDERWAVE && @move.pbTypeModifier(@move.pbType(@attacker), @attacker, @opponent).immune?
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.crested == :SUICUNE

    miniscore = 1.0
    miniscore *= 1.1 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::SETUPMOVE.include?(moveloop.move) }
    miniscore *= 1.2 if @opponent.hp == @opponent.totalhp
    ministat = @opponent.stages[PBStats::ATTACK] + @opponent.stages[PBStats::SPATK] + @opponent.stages[PBStats::SPEED]
    miniscore *= 1 + 0.05 * ministat if ministat > 0
    miniscore *= 0.3 if @opponent.ability == :NATURALCURE
    miniscore *= 0.5 if @opponent.ability == :MARVELSCALE
    miniscore *= 0.2 if @opponent.ability == :GUTS || @opponent.ability == :QUICKFEET
    miniscore *= 0.7 if @opponent.ability == :SHEDSKIN
    miniscore *= 0.5 if @opponent.ability == :SYNCHRONIZE && @attacker.pbCanParalyze?(@opponent, nil)
    miniscore *= 1.2 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL) || @mondata.roles.include?(:PIVOT)
    miniscore *= 1.3 if @mondata.roles.include?(:TANK)
    if !pbAIfaster?() && (pbRoughStat(@opponent, PBStats::SPEED) / 2.0) < @attacker.pbSpeed && @battle.state.effects[:TrickRoom] == 0
      miniscore *= 1.2
    elsif pbAIfaster?() && (pbRoughStat(@opponent, PBStats::SPEED) / 2.0) < @attacker.pbSpeed && @battle.state.effects[:TrickRoom] > 1
      miniscore *= 0.7
    end
    if pbRoughStat(@opponent, PBStats::SPATK) > pbRoughStat(@opponent, PBStats::ATTACK)
      miniscore *= 1.1
    end
    miniscore *= 1.1 if @mondata.partyroles.any? { |roles| roles.include?(:SWEEPER) }
    miniscore *= 1.1 if @opponent.effects[:Confusion] > 0
    miniscore *= 1.1 if @opponent.effects[:Attract] >= 0
    miniscore *= 0.4 if @opponent.effects[:Yawn] > 0
    miniscore = pbSereneGraceCheck(miniscore) if @move.pbIsDamaging?
    miniscore = pbReduceWhenKills(miniscore)
    miniscore *= dynamicspeedcode(:opponentstatus, 2.0) if @move.pbIsStatus? || @move.effect == 100 # Status moves, Nuzzle, Zap Cannon
    if !pbAIfaster?() && (pbRoughStat(@opponent, PBStats::SPEED) / 2.0) < @attacker.pbSpeed && @battle.state.effects[:TrickRoom] == 0
      if hasbadmoves(40)
        miniscore += 25 if @move.effect == 100 # help nuzzle
      end
    end
    return miniscore
  end

  def burncode
    return @move.pbIsDamaging? ? 1 : 0 if !@opponent.pbCanBurn?(@attacker, @move)
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.hydrationActive?
    return @move.pbIsDamaging? ? 1 : 0 if secondaryEffectNegated?()
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.crested == :SUICUNE

    miniscore = 1.2
    ministat = 0
    ministat += @opponent.stages[PBStats::ATTACK]
    ministat += @opponent.stages[PBStats::SPATK]
    ministat += @opponent.stages[PBStats::SPEED]
    miniscore *= 1 + 0.05 * ministat if ministat > 0
    miniscore *= 0.3 if @opponent.ability == :NATURALCURE
    miniscore *= 0.7 if @opponent.ability == :MARVELSCALE
    miniscore *= 0.1 if @opponent.ability == :GUTS || @opponent.ability == :FLAREBOOST
    miniscore *= 0.7 if @opponent.ability == :SHEDSKIN
    miniscore *= 0.5 if @opponent.ability == :SYNCHRONIZE && @attacker.pbCanBurn?(@opponent, nil)
    miniscore *= 0.5 if @battle.magicGuardAbilities.include?(@opponent.ability)
    miniscore *= 0.3 if @opponent.ability == :QUICKFEET
    miniscore *= 1.1 if @move.pbIsDamaging? && survivesAt1HP?(@opponent)
    miniscore *= 0.1 if checkAImoves([:REST])
    miniscore *= 0.3 if checkAImoves([:FACADE])
    if pbRoughStat(@opponent, PBStats::ATTACK) > pbRoughStat(@opponent, PBStats::SPATK)
      miniscore *= 1.4
    end
    miniscore *= 0.4 if @opponent.effects[:Yawn] > 0
    miniscore = pbSereneGraceCheck(miniscore) if @move.pbIsDamaging?
    miniscore = pbReduceWhenKills(miniscore)
    return miniscore
  end

  def freezecode
    return @move.pbIsDamaging? ? 1 : 0 if !@opponent.pbCanFreeze?(@attacker, @move)
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.hydrationActive?
    return @move.pbIsDamaging? ? 1 : 0 if secondaryEffectNegated?()
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.crested == :SUICUNE

    miniscore = 1.2
    miniscore *= 0 if getAIMemory().any? { |moveloop| moveloop != nil && moveloop.canThawUser? }
    miniscore *= 1.2 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::SETUPMOVE.include?(moveloop.move) }
    miniscore *= 1.2 if checkAIhealing() || checkAIdraining()
    ministat = statchangecounter(@opponent, 1, 7)
    miniscore *= 1 + 0.05 * ministat if ministat > 0
    miniscore *= 0.3 if @opponent.ability == :NATURALCURE
    miniscore *= 0.8 if @opponent.ability == :MARVELSCALE
    miniscore = pbSereneGraceCheck(miniscore) if @move.pbIsDamaging?
    miniscore = pbReduceWhenKills(miniscore)
    return miniscore
  end

  def decimationcode
    miniscore = petrifycode

    # decrease score decimation if we are faster and have other moves that kill

    opp2 = @opponent.pbPartner
    opp1bestmove = checkAIbestMove(@opponent)
    opp2bestmove = checkAIbestMove(@opponent.pbPartner)
    fasterThanBoth = pbAIfaster?(nil, opp1bestmove, @attacker, @opponent) && pbAIfaster?(nil, opp2bestmove, @attacker, opp2)
    if @initial_scores.length > 0
      miniscore *= 0.3 if hasgreatmoves() && fasterThanBoth
    end

    return miniscore
  end

  def petrifycode
    return @move.pbIsDamaging? ? 1 : 0 if !@opponent.pbCanPetrify?(@attacker, @move)
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.hydrationActive?
    return @move.pbIsDamaging? ? 1 : 0 if secondaryEffectNegated?()
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.ability == :LIQUIDOOZE
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.crested == :SUICUNE


    miniscore = 1.3
    return miniscore if hasgreatmoves(ignoreOthers: true) && pbAIfaster?()
    ministat = 0
    ministat += @opponent.stages[PBStats::DEFENSE]
    ministat += @opponent.stages[PBStats::SPDEF]
    ministat += @opponent.stages[PBStats::EVASION]
    ministat += @opponent.stages[PBStats::SPEED] if @battle.FE == :DEUXFINALIS && @opponent.pbCanReduceStatStage?(PBStats::SPEED, @opponent, nil)
    miniscore *= 1 + 0.05 * ministat if ministat > 0
    miniscore *= 1.5 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL) || @mondata.roles.include?(:TANK)
    miniscore *= 1.3 if @attacker.effects[:Substitute] > 0
    miniscore *= 1.2 if hpGainPerTurn(@opponent) > 1 || @attacker.ability == :DARKAURA
    miniscore *= 0.8 if @opponent.ability == :NATURALCURE
    miniscore *= 0.9 if @opponent.ability == :MARVELSCALE
    miniscore *= 0.8 if @opponent.ability == :GUTS
    miniscore *= 0.9 if @opponent.ability == :SHEDSKIN
    miniscore *= 0.7 if @battle.magicGuardAbilities.include?(@opponent.ability)
    miniscore *= 0.8 if @opponent.ability == :QUICKFEET
    miniscore *= 1.2 if @move.pbIsDamaging? && survivesAt1HP?(@opponent)
    if @initial_scores.length > 0
      miniscore *= 1.3 if hasbadmoves(30)
    end
    miniscore *= 0.8 if checkAImoves([:FACADE])
    miniscore = pbReduceWhenKills(miniscore)
    return miniscore
  end

  def flinchcode
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.effects[:Substitute] > 0 || @opponent.ability == :INNERFOCUS || secondaryEffectNegated?()
    return @move.pbIsDamaging? ? 1 : 0 if !pbAIfaster?(@move)

    miniscore = 1.0
    miniscore *= 1.3 if !hasgreatmoves()
    miniscore *= 1.3 if @battle.state.effects[:TrickRoom] > 0 && @attacker.pbSpeed > pbRoughStat(@opponent, PBStats::SPEED)
    miniscore *= 1.3 if @battle.field.duration > 0 && getFieldDisruptScore(@attacker, @opponent) > 1.0
    miniscore *= 1.3 if @attacker.pbOpposingSide.screenActive?
    miniscore *= 1.2 if @attacker.pbOpposingSide.effects[:Tailwind] > 0
    if ((@opponent.status == :POISON || @opponent.status == :BURN) && @opponent.crested != :SUICUNE) || @opponent.takesWeatherDamage? || @opponent.effects[:LeechSeed] > -1 || @opponent.effects[:Curse] || @opponent.effects[:SaltCure]
      miniscore *= 1.1
      miniscore *= 1.2 if @opponent.effects[:Toxic] > 0
    end
    miniscore *= 0.3 if @opponent.ability == :STEADFAST
    if @mondata.skill >= BESTSKILL
      miniscore *= 1.1 if @battle.FE == :ROCKY # Rocky
    end
    miniscore = pbSereneGraceCheck(miniscore) if @move.pbIsDamaging?
    miniscore = pbReduceWhenKills(miniscore)
    return miniscore
  end

  def thunderboostcode
    return 1 if @mondata.skill <= HIGHSKILL

    miniscore = 1.0
    invulmove = @opponent.effects[:TwoTurnAttack]
    if PBStuff::TWOTURNAIRMOVE.include?(invulmove) && pbAIfaster?()
      miniscore *= 2
    elsif @opponent.effects[:SkyDrop] && pbAIfaster?(nil, nil, nil, @battle.battlers.find { |mon| mon.effects[:SkyDroppee] == @opponent })
      miniscore *= 2
    end
    if !pbAIfaster?()
      miniscore *= 1.2 if checkAImoves(PBStuff::TWOTURNAIRMOVE)
    end
    return miniscore
  end

  def confucode
    return @move.pbIsDamaging? ? 1 : 0 if !@opponent.pbCanConfuse?(@attacker, @move)
    return @move.pbIsDamaging? ? 1 : 0 if secondaryEffectNegated?()

    miniscore = 1.0
    miniscore *= 1.2 if !hasgreatmoves()
    miniscore *= 1 + 0.1 * @opponent.stages[PBStats::ATTACK] if @opponent.stages[PBStats::ATTACK] > 0
    if pbRoughStat(@opponent, PBStats::ATTACK) > pbRoughStat(@opponent, PBStats::SPATK)
      miniscore *= 1.2
    end
    miniscore *= 1.3 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
    miniscore *= 1.1 if @opponent.effects[:Attract] >= 0
    miniscore *= 1.1 if @opponent.status == :PARALYSIS
    miniscore *= 0.7 if @opponent.ability == :TANGLEDFEET
    if @attacker.pbHasMove?(:SUBSTITUTE)
      miniscore *= 1.2
      miniscore *= 1.3 if @attacker.effects[:Substitute] > 0
    end
    if @initial_scores.length > 0
      miniscore *= 1.4 if hasbadmoves(40)
    end
    miniscore = pbSereneGraceCheck(miniscore) if @move.pbIsDamaging?
    miniscore = pbReduceWhenKills(miniscore)
    return miniscore
  end

  def attractcode
    return 0 if !@opponent.pbCanAttract?(@attacker, @move)

    miniscore = 1.2
    miniscore *= 0.7 if @attacker.ability == :CUTECHARM
    miniscore *= 1.3 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
    miniscore *= 1.1 if @opponent.effects[:Confusion] > 0
    miniscore *= 1.1 if @opponent.status == :PARALYSIS
    miniscore *= 0.5 if @opponent.effects[:Yawn] > 0 || @opponent.status == :SLEEP
    miniscore *= 0.1 if (@mondata.oppitemworks && @opponent.item == :DESTINYKNOT)
    if @attacker.pbHasMove?(:SUBSTITUTE)
      miniscore *= 1.2
      miniscore *= 1.3 if @attacker.effects[:Substitute] > 0
    end
    return miniscore
  end

  def refreshcode
    miniscore = 1.0
    if @attacker.status == :BURN || @attacker.status == :POISON || @attacker.status == :PARALYSIS
      miniscore *= 3
    else
      return 0
    end
    miniscore *= (@attacker.hp.to_f / @attacker.totalhp > 0.5) ? 1.5 : 0.3
    miniscore *= 0.1 if @opponent.effects[:Yawn] > 0
    miniscore *= 0.1 if checkAIdamage() > @attacker.hp
    miniscore *= 1.3 if @opponent.effects[:Toxic] > 2
    miniscore *= 1.3 if checkAImoves([:HEX])
    return miniscore
  end

  def partyrefreshcode
    party = @battle.pbCombinedParty(@attacker.index) # Applies to both parties in a multi battle
    return 0 if !party.any? { |mon| mon && !mon.status.nil? }

    miniscore = 1.2
    for mon in party
      next if mon.nil? || mon.hp <= 0 || mon.isEgg? || mon.status.nil?
      next if [:SLEEP, :FROZEN].include?(mon.status) && @attacker.pokemon == mon

      miniscore *= 0.5 if mon.status == :POISON && mon.ability == :POISONHEAL
      miniscore *= 0.8 if mon.ability == :GUTS || mon.ability == :QUICKFEET || mon.knowsMove?(:FACADE)
      miniscore *= 1.1 if mon.status == :SLEEP || mon.status == :FROZEN
      monroles = pbGetMonRoles(mon)
      miniscore *= 1.2 if (monroles.include?(:PHYSICALWALL) || monroles.include?(:SPECIALWALL)) && mon.status == :POISON
      miniscore *= 1.2 if monroles.include?(:SWEEPER) && mon.status == :PARALYSIS
      miniscore *= 1.2 if mon.attack > mon.spatk && mon.status == :BURN
    end
    miniscore *= 1.3 if !@attacker.status.nil?
    miniscore *= 1.3 if @attacker.effects[:Toxic] > 2
    miniscore *= 1.1 if checkAIhealing() || checkAIdraining()
    return miniscore
  end

  def psychocode
    return 0 if @attacker.status.nil? || !@opponent.status.nil? || @opponent.effects[:Substitute] > 0 || @opponent.effects[:Yawn] != 0
    return 0 if @attacker.status == :BURN && !@opponent.pbCanBurn?(@attacker, @move)
    return 0 if @attacker.status == :PARALYSIS && !@opponent.pbCanParalyze?(@attacker, @move)
    return 0 if @attacker.status == :POISON && !@opponent.pbCanPoison?(@attacker, @move)

    miniscore = 1.3 * 1.3
    if @attacker.status == :BURN && @opponent.pbCanBurn?(@attacker, @move)
      miniscore *= 1.2 if pbRoughStat(@opponent, PBStats::ATTACK) > pbRoughStat(@opponent, PBStats::SPATK)
      miniscore *= 0.7 if @opponent.ability == :FLAREBOOST
    end
    if @attacker.status == :PARALYSIS && @opponent.pbCanParalyze?(@attacker, @move)
      miniscore *= 1.1 if pbRoughStat(@opponent, PBStats::ATTACK) < pbRoughStat(@opponent, PBStats::SPATK)
      miniscore *= 1.2 if pbAIfaster?(@move)
    end
    if @attacker.status == :POISON && @opponent.pbCanPoison?(@attacker, @move)
      miniscore *= 1.1 if checkAIhealing() || checkAIdraining()
      miniscore *= 1.4 if @attacker.effects[:Toxic] > 0
      miniscore *= 0.3 if @opponent.ability == :POISONHEAL
      miniscore *= 0.7 if @opponent.ability == :TOXICBOOST
    end
    miniscore *= 0.7 if [:SHEDSKIN, :NATURALCURE, :GUTS, :QUICKFEET, :MARVELSCALE].include?(@opponent.ability)
    miniscore *= 0.7 if checkAImoves([:FACADE])
    miniscore *= 1.3 if checkAImoves([:HEX])
    miniscore *= 1.3 if @attacker.pbHasMove?(:HEX)
    return miniscore
  end

  def wakeupoppcode
    miniscore = 1.0
    return miniscore if @opponent.status != :SLEEP
    return miniscore if @opponent.effects[:Substitute] > 0

    miniscore *= 0.8
    miniscore *= 0.3 if @attacker.ability == :BADDREAMS || @attacker.pbHasMove?(:DREAMEATER, :NIGHTMARE)
    miniscore *= 1.3 if checkAImoves([:SLEEPTALK, :SNORE])
    return miniscore
  end

  def selfstatboost(stats, ignoreContrary = false)
    # stats should be an array of the stat boosts like so: [ATK,DEF,SPA,SPD,SPE,ACC,EVA] with 0s in unaffected stats
    # coil, for example, would be [1,1,0,0,0,1,0]
    stats.unshift(0) # this is required to make the next line work correctly
    for i in 1...stats.length
      stats[i] *= 2 if @attacker.ability == :SIMPLE
      # cap boost to the max it can be increased
      stats[i] = [6 - @attacker.stages[i], stats[i]].min
    end
    if stats[PBStats::ATTACK] != 0 || stats[PBStats::SPATK] != 0
      for j in @attacker.moves
        next if j.nil?
        next if j.pbFixedDamageMove?

        specmove = true if j.pbIsSpecial?(@attacker)
        physmove = true if j.pbIsPhysical?(@attacker)
      end
      stats[PBStats::ATTACK] = 0 if !physmove
      stats[PBStats::SPATK] = 0 if !specmove
    end
    return @move.pbIsDamaging? ? 1 : 0 if stats.all? { |a| a.nil? || a == 0 }

    # Function is split into 3 sections- individual stat sections, group stat sections, and collective stat sections.
    # Individual is self explanatory; group stats splits stats into offensive/defensive (sweep/tank) and processese separately
    # Collective checks run on all of the stats.
    miniscore = 1.0
    if @move.pbIsStatus?
      statsboosted = stats.compact.sum
      miniscore = statsboosted
      # weight categories based on combinations of boosted stats
      if (stats[PBStats::ATTACK] > 0 || stats[PBStats::SPATK] > 0) && stats[PBStats::SPEED] > 0 # Speed and offense i.e dragon dance
        miniscore *= 1.8
      elsif stats[PBStats::ATTACK] > 1 || stats[PBStats::SPATK] > 1 # Double offense i.e swords dance, nasty plot
        miniscore *= 1.5
      elsif (stats[PBStats::ATTACK] > 0 || stats[PBStats::SPATK] > 0) && (stats[PBStats::DEFENSE] > 0 || stats[PBStats::SPDEF] > 0) # Defense and offense i.e bulk up
        miniscore *= 1.5
      elsif stats[PBStats::DEFENSE] > 0 && stats[PBStats::SPDEF] > 0 # Both defenses i.e cosmic power
        miniscore *= 1.5
      end
    end
    for i in 1...stats.length
      next if stats[i].nil? || stats[i] == 0

      case i
        when PBStats::ATTACK
          next if !physmove

          sweep = true
          miniscore *= 1.3 if checkAIhealing()
          miniscore *= 1.5 if pbAIfaster?() || @attacker.moves.any? { |moveloop| moveloop.priorityCheck(@attacker) > 0 && moveloop.pbIsPhysical?(@attacker, moveloop.pbType(@attacker)) }
          miniscore *= 0.5 if @attacker.status == :BURN && @attacker.ability != :GUTS && @attacker.crested != :SUICUNE
          miniscore *= 0.3 if checkAImoves([:FOULPLAY])
          miniscore *= 1.4 if notOHKO?(@opponent, @attacker)
          miniscore *= 0.6 if checkAIpriority()
          miniscore *= 0.6 if (
            @opponent.ability == :SPEEDBOOST || (@opponent.ability == :MOTORDRIVE && @battle.FE == :ELECTERRAIN) ||
            (@opponent.ability == :STEAMENGINE && [:UNDERWATER, :WATERSURFACE, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@battle.FE))
          )
        when PBStats::DEFENSE
          tank = true
          if pbRoughStat(@opponent, PBStats::SPATK) < pbRoughStat(@opponent, PBStats::ATTACK)
            if !(@mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL))
              if pbAIfaster?(@move) && @attacker.hp.to_f / @attacker.totalhp > 0.75
                miniscore *= 1.3
              elsif !pbAIfaster?(@move)
                miniscore *= 0.7
              end
            end
            miniscore *= 1.3
          end
        when PBStats::SPATK
          sweep = true
          miniscore *= 1.3 if checkAIhealing()
          miniscore *= 1.5 if pbAIfaster?() || @attacker.moves.any? { |moveloop| moveloop.priorityCheck(@attacker) > 0 && moveloop.pbIsSpecial?(@attacker, moveloop.pbType(@attacker)) }
          miniscore *= 0.5 if @attacker.status == :PARALYSIS && @attacker.crested != :SUICUNE
          if notOHKO?(@opponent, @attacker)
            miniscore *= 1.4
          end
          miniscore *= 0.6 if checkAIpriority()
        when PBStats::SPDEF
          tank = true
          miniscore *= 1.1 if @opponent.status == :BURN && @opponent.crested != :SUICUNE
          if pbRoughStat(@opponent, PBStats::SPATK) > pbRoughStat(@opponent, PBStats::ATTACK)
            if !(@mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL))
              if pbAIfaster?(@move) && @attacker.hp.to_f / @attacker.totalhp > 0.75
                miniscore *= 1.3
              elsif !pbAIfaster?(@move)
                miniscore *= 0.7
              end
            end
            miniscore *= 1.3
          end
        when PBStats::SPEED
          sweep = true
          if pbAIfaster?()
            miniscore *= 0.8
            miniscore *= 0.2 if statsboosted == stats[PBStats::SPEED]
          end
          # Additional check if you're the last mon alive?
          miniscore *= 0.2 if @battle.state.effects[:TrickRoom] > 1 || checkAImoves([:TRICKROOM])
          # Skip speed checks if we only have priority damaging moves anyway
          if @attacker.moves.any? { |moveloop|
               moveloop != nil && moveloop.pbIsDamaging? && moveloop.priorityCheck(@attacker) < 1 && @mondata.roughdamagearray.transpose[@attacker.moves.find_index(moveloop)].max > 10
             } # thank u perry 4 saving me
            # Moxie/Soul Heart
            miniscore *= 1.5 if (physmove && [:MOXIE, :CHILLINGNEIGH, :ASONECHILLING].include?(@attacker.ability)) || (specmove && [:SOULHEART, :GRIMNEIGH, :ASONEGRIM].include?(@attacker.ability))
            if [:BEASTBOOST, :EELEVATE].include?(@attacker.ability)
              stat = @attacker.getHighestRawStat
              miniscore *= 1.5 if (physmove && stat == PBStats::ATTACK) || (specmove && stat == PBStats::SPATK)
            end
            if @attacker.attack < @attacker.spatk
              miniscore *= (1 + 0.05 * @attacker.stages[PBStats::SPATK]) if @attacker.stages[PBStats::SPATK] < 0
            else
              miniscore *= (1 + 0.05 * @attacker.stages[PBStats::ATTACK]) if @attacker.stages[PBStats::ATTACK] < 0
            end
            ministat = 0
            ministat += @opponent.stages[PBStats::DEFENSE]
            ministat += @opponent.stages[PBStats::SPDEF]
            miniscore *= 1 - 0.05 * ministat if ministat > 0
          end
        when PBStats::ACCURACY
          for j in @attacker.moves
            next if j.nil?

            miniscore *= 1.1 if j.accuracy < 95
           end
          miniscore *= (1 + 0.05 * @opponent.stages[PBStats::EVASION]) if @opponent.stages[PBStats::EVASION] > 0
          if (@mondata.oppitemworks && @opponent.item == :BRIGHTPOWDER) || (@mondata.oppitemworks && @opponent.item == :LAXINCENSE) || accuracyWeatherAbilityActive?(@opponent, @attacker)
            miniscore *= 1.1
          end
        when PBStats::EVASION
          tank = true
          miniscore *= 0.2 if @opponent.ability == :NOGUARD || @attacker.ability == :NOGUARD || checkAIaccuracy() || (opponent.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
          if (@mondata.attitemworks && @attacker.item == :BRIGHTPOWDER) || (@mondata.attitemworks && @attacker.item == :LAXINCENSE) || accuracyWeatherAbilityActive?(@attacker, @opponent)
            miniscore *= 1.3
          end
      end
    end
    if seedProtection?(@attacker) || (!@battle.doublebattle && (@attacker.effects[:Substitute] > 0 || ((@attacker.effects[:Disguise] || (@attacker.effects[:IceFace] && (@opponent.attack > @opponent.spatk || @battle.FE == :FROZENDIMENSION))) && !moldBreakerCheck(@opponent, @attacker, nil, true))))
      miniscore *= 1.3
    end
    miniscore *= 0.5 if (@opponent.effects[:Substitute] > 0 || ((@opponent.effects[:Disguise] || (@opponent.effects[:IceFace] && (@attacker.attack > @attacker.spatk || @battle.FE == :FROZENDIMENSION))) && !moldBreakerCheck(@attacker, @opponent, nil, true)))
    miniscore *= 0.5 if @opponent.ability == :OPPORTUNIST || @opponent.pbPartner.ability == :OPPORTUNIST || @opponent.item == :MIRRORHERB || @opponent.pbPartner.item == :MIRRORHERB
    miniscore *= 1.3 if (@opponent.status == :SLEEP || @opponent.status == :FROZEN) && @opponent.crested != :SUICUNE
    miniscore *= 1.3 if hasbadmoves(20)
    attackerHPpercent = @attacker.hp.to_f / @attacker.totalhp
    if attackerHPpercent > 0.5 && attackerHPpercent < 0.75 && (@attacker.ability == :EMERGENCYEXIT || @attacker.ability == :WIMPOUT || (@attacker.itemWorks? && @attacker.item == :EJECTBUTTON))
      miniscore *= 0.3
    elsif attackerHPpercent < 0.33 && @move.pbIsStatus?
      miniscore *= 0.3
    end
    if @mondata.skill >= MEDIUMSKILL
      bestmove, maxdam = checkAIMovePlusDamage()
      if maxdam < (@attacker.hp / 4.0) && stats[PBStats::DEFENSE] != 0 && stats[PBStats::SPDEF] != 0 # cosmic power
        miniscore *= 1.5
      elsif maxdam < (@attacker.hp / 4.0) && sweep
        miniscore *= 1.2
      elsif maxdam < (@attacker.hp / 3.0) && tank
        miniscore *= 1.1
      elsif maxdam < (@attacker.hp / 2.0)
        miniscore *= 1.1
      elsif @move.pbIsStatus?
        miniscore *= 0.8
        miniscore *= 0.3 if !@attacker.moves.any? { |moveloop| moveloop.pbIsDamaging? && pbAIfaster?(moveloop, bestmove) }
        # Don't set up if you're gonna die this turn for sure
        miniscore *= 0.1 if maxdam > @attacker.hp && !(@attacker.effects[:Substitute] > 0 || ((@attacker.effects[:Disguise] || (@attacker.effects[:IceFace] && (@opponent.attack > @opponent.spatk || @battle.FE == :FROZENDIMENSION))) && !moldBreakerCheck(@opponent, @attacker, nil, true)) || seedProtection?(@attacker))
      end

      if maxdam * 2 > @attacker.hp + (hpGainPerTurn(@attacker) - 1) * @attacker.totalhp && (stats[PBStats::ATTACK] == 1 || stats[PBStats::SPATK] == 1) &&
         ((bestmove.pbIsPhysical?(@attacker, bestmove.pbType(@attacker)) && stats[PBStats::DEFENSE] == 0) || (bestmove.pbIsSpecial?(@attacker, bestmove.pbType(@attacker)) && stats[PBStats::SPDEF] == 0)) && @move.pbIsStatus?
        miniscore *= 0.4
      end
    end
    # Don't set up if you're just going to get run over
    if (@opponent.level - 10) > @attacker.level
      miniscore *= 0.6
      if (@opponent.level - 15) > @attacker.level
        miniscore *= 0.2
      end
    end
    # Some stats run similar checks
    miniscore *= 0.1 if checkAImovesAllOpponents([:SNATCH]) && @move.pbIsStatus?
    miniscore *= 0.3 if checkAImovesAllOpponents([:ENCORE]) && @move.pbIsStatus? && aiCheckSideAbility(:AROMAVEIL, @attacker, checkMoldBroken: true).none?
    if sweep
      ministat = @opponent.stages[PBStats::ATTACK] + @opponent.stages[PBStats::SPATK] + @opponent.stages[PBStats::SPEED]
      miniscore *= (1 + 0.05 * ministat)
      if @attacker.stages[PBStats::SPEED] < 0 && stats[PBStats::SPEED] == 0
        miniscore *= (1 + 0.05 * @attacker.stages[PBStats::SPEED])
      end
      miniscore *= 1.2 if attackerHPpercent > 0.75
      miniscore *= 1.2 if @attacker.turncount < 2
      miniscore *= 1.2 if !@opponent.status.nil?
      if @opponent.effects[:Encore] > 0
        miniscore *= 1.5 if @opponent.moves[(@opponent.effects[:EncoreIndex])].pbIsStatus?
      end
      miniscore *= 0.6 if @attacker.effects[:LeechSeed] >= 0 || @attacker.effects[:Attract] >= 0 || @attacker.effects[:SaltCure]
      miniscore *= 0.4 if checkAImoves(PBStuff::PHASEMOVE)
      miniscore *= 1.3 if @mondata.roles.include?(:SWEEPER)
      if @attacker.status == :PARALYSIS && @attacker.crested != :SUICUNE
        miniscore *= 0.5
        miniscore *= 0.5 if stats[PBStats::SPEED] != 0 # stacks
      end
      if @attacker.pbCanParalyze?(@opponent, nil) && checkAImoves(PBStuff::PARAMOVE) && @move.pbIsStatus?
        miniscore *= 0.5
        if hasgreatmoves() && stats[PBStats::SPEED] > 0 && pbAIfaster?()
          miniscore *= 0.3
        end
      end
      miniscore *= 0.7 if @attacker.status == :POISON && @attacker.ability != :POISONHEAL && @attacker.crested != :ZANGOOSE && @attacker.crested != :SUICUNE
      miniscore *= 0.6 if @attacker.effects[:Toxic] > 0 && @attacker.ability != :POISONHEAL && @attacker.crested != :ZANGOOSE && @attacker.crested != :SUICUNE
      miniscore *= 0.6 if checkAIpriority()
      miniscore *= 0.6 if (
        @opponent.ability == :SPEEDBOOST ||
        (((@opponent.ability == :MOTORDRIVE && @battle.FE == :ELECTERRAIN) || (@opponent.ability == :STEAMENGINE && [:UNDERWATER, :WATERSURFACE, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@battle.FE))) && (stats[PBStats::SPEED] < 2))
      )
      miniscore *= 1.4 if notOHKO?(@opponent, @attacker)
    else
      miniscore *= 1.1 if attackerHPpercent > 0.75
      miniscore *= 1.1 if @attacker.turncount < 2
      miniscore *= 1.1 if !@opponent.status.nil?
      if @opponent.effects[:Encore] > 0
        if @opponent.moves[(@opponent.effects[:EncoreIndex])].pbIsStatus?
          miniscore *= 1.3
          miniscore *= 1.2 if (stats[PBStats::DEFENSE] != 0 && stats[PBStats::SPDEF] != 0)
        end
      end
      miniscore *= 0.2 if checkAImoves(PBStuff::PHASEMOVE)
      miniscore *= 0.7 if @attacker.status == :POISON && @attacker.ability != :POISONHEAL && @attacker.crested != :ZANGOOSE && @attacker.crested != :SUICUNE
      miniscore *= 0.2 if @attacker.effects[:Toxic] > 0 && @attacker.ability != :POISONHEAL && @attacker.crested != :ZANGOOSE && @attacker.crested != :SUICUNE
      miniscore *= 0.3 if @attacker.effects[:LeechSeed] >= 0 || @attacker.effects[:Attract] >= 0 || @attacker.effects[:SaltCure]
    end
    if tank
      if @attacker.stages[PBStats::SPDEF] > 0 || @attacker.stages[PBStats::DEFENSE] > 0
        ministat = 0
        ministat += @attacker.stages[PBStats::SPDEF] if stats[PBStats::SPDEF] != 0
        ministat += @attacker.stages[PBStats::DEFENSE] if stats[PBStats::DEFENSE] != 0
        miniscore *= (1 - 0.05 * ministat)
      end
      miniscore *= 1.3 if @attacker.moves.any? { |moveloop| moveloop.nil? && moveloop.isHealingMove? }
      miniscore *= 1.3 if @attacker.pbHasMove?(:LEECHSEED)
      miniscore *= 1.2 if @attacker.pbHasMove?(:PAINSPLIT)
      miniscore *= 1.2 if @attacker.ability == :LIFEBLOOD
      miniscore *= 1.2 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
      miniscore *= (1.2 * hpGainPerTurn)
      if @mondata.skill >= MEDIUMSKILL
        miniscore *= 0.3 if checkAIdamage() < 0.12 * @attacker.hp && (getAIMemory().length > 0)
      end
    end
    if @attacker.effects[:Confusion] > 0
      if stats[PBStats::ATTACK] != 0 # if move boosts attack
        miniscore *= 0.2
        miniscore *= 0.5 if stats[PBStats::ATTACK] > 1 # using swords dance or shell smash while confused is Extra Bad
        miniscore *= 1.5 if stats[PBStats::DEFENSE] != 0 # adds a correction for moves that boost attack and defense
      else
        miniscore *= 0.5
      end
    end
    if @battle.doublebattle
      if !@attacker.pbPartner.pbHasMove?(:PSYCHUP)
        miniscore *= 0.7
      else
        miniscore *= 1.1
      end
      miniscore *= 0.5 if !sweep # drop is doubled
    end
    miniscore *= 0.2 if checkAImoves([:CLEARSMOG, :HAZE, :TOPSYTURVY, :HEARTSWAP])
    miniscore *= 0.1 if checkAImoves([:PSYCHUP])
    miniscore *= 1.3 if @opponent.effects[:HyperBeam] > 0
    miniscore *= 1.7 if @opponent.effects[:Yawn] > 0
    miniscore *= 2 if @attacker.pbHasMove?(:STOREDPOWER, :POWERTRIP)
    miniscore *= 1.2 if @attacker.pbPartner.pbHasMove?(:PSYCHUP, :BATONPASS)

    if @move.pbIsDamaging?
      if @initial_scores[@score_index] >= 100
        miniscore *= 1.2
      elsif hasgreatmoves()
        miniscore *= 0.5
      end
      miniscore = 1 if @opponent.ability == :UNAWARE || miniscore < 1
      miniscore = pbSereneGraceCheck(miniscore)
    else
      miniscore *= 0 if @attacker.ability == :CONTRARY && !ignoreContrary
      miniscore *= 0.01 if @opponent.ability == :UNAWARE
    end
    return miniscore
  end

  def selfstatdrop(stats, score)
    # Works with both 5- and 7- stat arrays
    stats.map!.with_index { |a, ind| @attacker.pbCanReduceStatStage?(ind + 1, @attacker, @move) ? a : 0 }
    return @move.pbIsDamaging? ? 1 : 0 if stats.all? { |a| a == 0 }
    return 1 if Rejuv && @attacker.effects[:PerishSong] > 0

    stats.unshift(0)

    miniscore = 1.0
    if stats[PBStats::ATTACK] != 0 # Basically just to catch superpower
      if score < 100
        miniscore *= 0.9
        if !pbAIfaster?()
          miniscore *= 1.1
        else
          miniscore *= 0.5 if checkAIhealing()
        end
      end
    elsif stats[PBStats::DEFENSE] != 0 || stats[PBStats::SPDEF] != 0
      if score < 100
        miniscore *= 0.9
        miniscore *= 0.9 if stats[PBStats::SPEED] != 0
        if !pbAIfaster?()
          miniscore *= 1.1
        else
          miniscore *= 0.6 if checkAIhealing()
        end
        miniscore *= 0.7 if checkAIpriority()
      end
    elsif stats[PBStats::SPEED] != 0
      miniscore *= 0.9 if score < 100
      miniscore *= 1.1 if @mondata.roles.include?(:TANK)
      if pbAIfaster?()
        miniscore *= 0.8
        if @battle.pbPokemonCount(@battle.pbCombinedParty(@opponent.index)) > 1 && @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index)) == 1
          miniscore *= 0.8
        end
      else
        # miniscore*=1.1
      end
    elsif stats[PBStats::SPATK] != 0
      if @mondata.skill >= BESTSKILL && @battle.FE == :GLITCH && @attacker.changeSpecialStat(attacker: true, moldBrokenArray: getMoldBrokenArray())
        miniscore *= 1.4
      elsif score < 100
        miniscore *= 0.9
        miniscore *= 0.5 if checkAIhealing()
      end
    end
    if @initial_scores.length > 0
      miniscore *= 0.6 if hasgreatmoves()
    end
    minimini = 100
    livecount = @battle.pbPokemonCount(@battle.pbCombinedParty(@opponent.index))
    miniscore *= 1 - 0.05 * (livecount - 3) if livecount > 1

    party = @battle.pbPartySingleOwner(@attacker.index)
    pivotvar = false
    for i in 0...party.length
      next if party[i].nil?

      temproles = pbGetMonRoles(party[i])
      if temproles.include?(:PIVOT)
        pivotvar = true
      end
    end
    miniscore *= 1.2 if pivotvar && !@battle.doublebattle
    livecount2 = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))
    if livecount > 1 && livecount2 == 1
      miniscore *= 0.8
    end
    miniscore = 1 if miniscore < 1 && livecount == 1 && score >= 100
    return miniscore
  end

  def oppstatboost(stats, confusionmove = false, alsodecrease = false)
    # Works with both 5- and 7- stat arrays
    return @move.pbIsDamaging? ? 1 : 0 if @move.blockedBySubstitute?(@attacker, @opponent)

    stats.map!.with_index { |a, ind| @opponent.pbCanIncreaseStatStage?(ind + 1, @attacker, @move) ? a : 0 }
    return @move.pbIsDamaging? ? 1 : 0 if stats.all? { |a| a == 0 }

    stats.unshift(0)
    for i in 1...stats.length
      stats[i] *= 2 if @opponent.ability == :SIMPLE
      # cap boost to the max it can be increased
      stats[i] = [6 - @opponent.stages[i], stats[i]].min
    end

    miniscore = 1.0
    if !scoringAgainstPartner?
      if @opponent.pbCanConfuse?(@attacker, @move) && confusionmove
        if stats[PBStats::SPATK] != 0
          miniscore *= 1 + 0.1 * @opponent.stages[PBStats::ATTACK] if @opponent.stages[PBStats::ATTACK] > 0
          if @opponent.attack > @opponent.spatk
            miniscore *= 1.5
          else
            miniscore *= 0.3
          end
        elsif stats[PBStats::ATTACK] != 0
          if @opponent.attack < @opponent.spatk
            miniscore *= 1.5
          else
            miniscore *= 0.7
          end
        end
        miniscore *= confucode
      else
        # for when a move also decreases a stat avoid 0 for multiplication purposes.
        miniscore = alsodecrease ? 1 : 0
      end
      miniscore *= 1.5 if (@attacker.pbPartner.ability == :OPPORTUNIST || @attacker.pbPartner.hasWorkingItem(:MIRRORHERB)) && @attacker.pbPartner.pbSpeed > @opponent.pbSpeed
    else
      return @move.pbIsDamaging? ? 1 : 0 if !@battle.aiControlled?(@attacker.pbPartner.index)

      if stats[PBStats::ATTACK] != 0 || stats[PBStats::SPATK] != 0
        for j in @opponent.moves
          next if j.nil?
          next if j.pbFixedDamageMove?

          specmove = true if j.pbIsSpecial?(@opponent)
          physmove = true if j.pbIsPhysical?(@opponent)
        end
        stats[PBStats::ATTACK] = 0 if !physmove
        stats[PBStats::SPATK] = 0 if !specmove
      end
      return @move.pbIsDamaging? ? 1 : 0 if stats.all? { |a| a.nil? || a == 0 }

      if @move.pbIsStatus?
        statsboosted = stats.compact.sum
        miniscore = statsboosted
        # weight categories based on combinations of boosted stats
        if (stats[PBStats::ATTACK] > 0 || stats[PBStats::SPATK] > 0) && stats[PBStats::SPEED] > 0 # Speed and offense i.e dragon dance
          miniscore *= 1.5
        elsif stats[PBStats::ATTACK] > 1 || stats[PBStats::SPATK] > 1 # Double offense i.e swords dance, nasty plot
          miniscore *= 1.3
        elsif (stats[PBStats::ATTACK] > 0 || stats[PBStats::SPATK] > 0) && (stats[PBStats::DEFENSE] > 0 || stats[PBStats::SPDEF] > 0) # Defense and offense i.e bulk up
          miniscore *= 1.3
        elsif stats[PBStats::DEFENSE] > 0 && stats[PBStats::SPDEF] > 0 # Both defenses i.e cosmic power
          miniscore *= 1.3
        end
      end

      if confusionmove
        miniscore *= @opponent.pbCanConfuse?(@attacker, @move) ? 0.5 : 1.5
        miniscore *= 1.5 if (@opponent.attack < @opponent.spatk && stats[PBStats::ATTACK] != 0) || (@opponent.attack > @opponent.spatk && stats[PBStats::SPATK] != 0)
        miniscore *= 1.2 if @mondata.oppitemworks && (@opponent.item == :PERSIMBERRY || @opponent.item == :LUMBERRY)
      end
      miniscore *= 0.3 if (1.0 / @opponent.totalhp) * @opponent.hp < 0.6
      if @opponent.effects[:Attract] >= 0 || @opponent.status == :PARALYSIS || @opponent.effects[:Yawn] > 0 || (@opponent.status == :SLEEP && @opponent.crested != :SUICUNE)
        miniscore *= 0.3
      end

      opp1 = @attacker.pbOppositeOpposing
      opp2 = opp1.pbPartner

      fasterThanBoth = pbAIfaster?(@move, nil, @attacker, opp1) && pbAIfaster?(@move, nil, @attacker, opp2)
      partnerFasterThanBoth = pbAIfaster?(nil, nil, @opponent, opp1) && pbAIfaster?(nil, nil, @opponent, opp2)

      partnermondata = @aimondata[@opponent.index]

      for i in 1...stats.length
        next if stats[i].nil? || stats[i] == 0

        case i
        when PBStats::ATTACK
          next if !physmove

          miniscore *= 1.3 if checkAIhealing()
          miniscore *= 1.5 if pbAIfaster?(@move)
          miniscore *= 0.5 if @opponent.status == :BURN && @opponent.ability != :GUTS &&  @opponent.crested != :SUICUNE
          miniscore *= 1.4 if notOHKO?(opp1, @opponent) && notOHKO?(opp2, @opponent)
        when PBStats::DEFENSE
          if pbRoughStat(opp1, PBStats::SPATK) < pbRoughStat(opp1, PBStats::ATTACK)
            if pbAIfaster?(@move) && fasterThanBoth && (@opponent.hp.to_f / @opponent.totalhp > 0.75)
              miniscore *= 1.3
            elsif !pbAIfaster?(@move)
              miniscore *= 0.7
            end
            miniscore *= 1.3
          end
          miniscore *= 1.3 if partnermondata.roles.include?(:PHYSICALWALL) || partnermondata.roles.include?(:SPECIALWALL) || partnermondata.roles.include?(:TANK)
        when PBStats::SPDEF
          miniscore *= 1.1 if opp1.status == :BURN || opp2.status == :BURN
          if pbRoughStat(opp1, PBStats::ATTACK) < pbRoughStat(opp1, PBStats::SPATK)
            if pbAIfaster?(@move) && fasterThanBoth && (@opponent.hp.to_f / @opponent.totalhp > 0.75)
              miniscore *= 1.3
            elsif !pbAIfaster?(@move)
              miniscore *= 0.7
            end
            miniscore *= 1.3
          end
          miniscore *= 1.3 if partnermondata.roles.include?(:PHYSICALWALL) || partnermondata.roles.include?(:SPECIALWALL) || partnermondata.roles.include?(:TANK)
        when PBStats::SPATK
          miniscore *= 1.3 if checkAIhealing()
          miniscore *= 1.5 if pbAIfaster?(@move)
          miniscore *= 1.4 if notOHKO?(opp1, @opponent) && notOHKO?(opp2, @opponent)
        end
      end
      miniscore *= 0.5 if ((opp1.ability == :OPPORTUNIST || opp1.hasWorkingItem(:MIRRORHERB)) && opp1.pbSpeed > @opponent.pbSpeed) || ((opp2.ability == :OPPORTUNIST || opp2.hasWorkingItem(:MIRRORHERB)) && opp2.pbSpeed > @opponent.pbSpeed)
      miniscore *= 1.3 if pbAIfaster?(@move) && partnerFasterThanBoth
    end
    return miniscore
  end

  def oppstatdrop(stats)
    # stats should be an array of the stat boosts like so: [ATK,DEF,SPA,SPD,SPE,ACC,EVA] with 0s in unaffected stats
    # coil, for example, would be [1,1,0,0,0,1,0]
    return 1 if @move.pbIsDamaging? && @initial_scores[@score_index] >= 100
    return @move.pbIsDamaging? ? 1 : 0 if ([:CLEARBODY, :WHITESMOKE].include?(@opponent.ability) && !moldBreakerCheck(@attacker, @opponent, @move)) || @opponent.hasWorkingItem(:CLEARAMULET)
    return 1 if @move.pbIsDamaging? && (@opponent.ability == :SHIELDDUST || @opponent.hasWorkingItem(:COVERTCLOAK))
    return selfstatdrop(stats, @initial_scores[@score_index]) if @opponent.ability == :MIRRORARMOR && !moldBreakerCheck(@attacker, @opponent, @move)

    stats.unshift(0) # this is required to make the next line work correctly
    # Start by eliminating pointless stats
    for i in 1...stats.length
      next if stats[i] == 0

      stats[i] = 0 if !@opponent.pbCanReduceStatStage?(i, @attacker, @move)
      # Don't get into counter-setup wars you can't win - Ame
      # TODO: probably best to refactor conditions for this, maybe check movememory for setup moves - Fal
      stats[i] = 0 if @move.pbIsStatus? && stats[i] && @opponent.stages[i] > stats[i]
    end
    return @move.pbIsDamaging? ? 1 : 0 if stats.all? { |a| a.nil? || a == 0 }

    # setting aside some definitions for later
    user = @attacker.index
    partner = @attacker.pbPartner.index
    opp1 = @opponent.index
    opp2 = @opponent.pbPartner.index

    if stats[PBStats::DEFENSE] > 0 || stats[PBStats::SPDEF] > 0
      specmove = @attacker.moves.any? { |j| !j.nil? && j.pbIsSpecial?(@attacker) }
      physmove = @attacker.moves.any? { |j| !j.nil? && j.pbIsPhysical?(@attacker) }
      partnerspecmove, partnerphysmove = false, false
      if @attacker.pbPartner.hp > 0
        partnerspecmove = true if @attacker.pbPartner.moves.any? { |moveloop| moveloop != nil && moveloop.pbIsSpecial?(@attacker.pbPartner) }
        partnerphysmove = true if @attacker.pbPartner.moves.any? { |moveloop| moveloop != nil && moveloop.pbIsPhysical?(@attacker.pbPartner) }
      end
      stats[PBStats::DEFENSE] = 0 if !physmove && !partnerphysmove
      stats[PBStats::SPDEF] = 0 if !specmove && !partnerspecmove
    end
    if stats[PBStats::ATTACK] > 0 || stats[PBStats::SPATK] > 0
      bestmove = checkAIbestMove()
      stats[PBStats::SPATK] = 0 if (pbRoughStat(@opponent, PBStats::ATTACK) * 0.9 > pbRoughStat(@opponent, PBStats::SPATK)) && bestmove.pbIsPhysical?(@attacker) && @opponent.crested != :TYPHLOSION
      stats[PBStats::ATTACK] = 0 if (pbRoughStat(@opponent, PBStats::SPATK) * 0.9 > pbRoughStat(@opponent, PBStats::ATTACK)) && bestmove.pbIsSpecial?(@attacker) && @opponent.crested != :TYPHLOSION
    end
    if stats[PBStats::SPEED] > 0
      stats[PBStats::SPEED] = 0 if pbAIfaster?() && (@attacker.pbPartner.hp <= 0 || pbAIfaster?(nil, nil, @attacker.pbPartner)) && @battle.state.effects[:TrickRoom] == 0
      stats[PBStats::SPEED] = 0 if @battle.state.effects[:TrickRoom] > 1
    end
    return @move.pbIsDamaging? ? 1 : 0 if stats.all? { |a| a.nil? || a == 0 }

    # This section is split up a little weird to avoid duplicating checks
    miniscore = 1.0
    if @move.pbIsStatus?
      statsboosted = stats.sum
      miniscore = statsboosted
    end
    if stats[PBStats::DEFENSE] > 0 || stats[PBStats::SPDEF] > 0 # defense stuff
      miniscore *= 1.1
      miniscore *= 1.2 if checkAIdamage() < @attacker.hp || (pbAIfaster?(@move, nil, @attacker, @opponent) && pbAIfaster?(@move, nil, @attacker.pbPartner, @opponent))
      if ((partnerspecmove && @move.function == 0x4F) || (partnerphysmove && @move.function == 0x4C)) # Screech, Fake Tears, Acid Spray, Lumina Crash, Metal Sound, Uproot (Rejuv), Seed Flare
        miniscore *= @move.pbIsDamaging? ? 1.2 : 1.5
        if !@move.pbIsDamaging?
          bestmove, maxdam = checkAIMovePlusDamage(@attacker.pbPartner, @opponent)
          bestmoveadd, maxdamadd = checkAIMovePlusDamage(@attacker.pbPartner, @opponent.pbPartner)
          bestmove2, maxdam2 = pbRoughDamageAfterBoostsOrDrops(@attacker.pbPartner, @opponent, oppboosts: stats.map! { |item| -item} )

          likelymoves = [nil, nil, nil, nil]
          likelymoves[@attacker.index] = @move
          likelymoves[@attacker.pbPartner.index] = bestmove2
          speedorder = pbMoveOrderAI(likelymoves)

          idealscenarios = speedorder == [user, partner, opp1, opp2] || speedorder == [user, partner, opp2, opp1] || (speedorder == [opp2, user, partner, opp1] && checkAIdamage(@opponent.pbPartner) < @attacker.hp && checkAIdamage(@opponent.pbPartner, @attacker.pbPartner) < @attacker.pbPartner.hp)
          if idealscenarios
            miniscore *= 1.5 if maxdam < (@opponent.totalhp * 0.75).floor && maxdamadd < (@opponent.pbPartner.totalhp * 0.75) && maxdam2 > (@opponent.totalhp * 0.75).floor
            miniscore *= 1.5 if maxdam < @opponent.totalhp && maxdam2 > @opponent.totalhp
          end
        end
      end
    else # non-defense stuff
      if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
        miniscore *= 1.3 if stats[PBStats::ATTACK] > 0 || stats[PBStats::SPATK] > 0 || stats[PBStats::ACCURACY] > 0
        miniscore *= 1.1 if stats[PBStats::SPEED] > 0
      end
    end
    if stats[PBStats::SPEED] > 0 # speed stuff
      if (pbRoughStat(@opponent, PBStats::SPEED) * 0.66) > @attacker.pbSpeed
        miniscore *= hasgreatmoves() ? 1 : 1.5
      end
      miniscore *= 1 + 0.05 * @opponent.stages[PBStats::SPEED] if @opponent.stages[PBStats::SPEED] < 0 && !secondaryEffectNegated?()
      miniscore *= 0.1 if @opponent.itemWorks? && (@opponent.item == :LAGGINGTAIL || @opponent.item == :IRONBALL)
      miniscore *= 0.2 if (@opponent.ability == :COMPETITIVE && !(Rejuv && @battle.FE == :CHESS)) || @opponent.ability == :DEFIANT || @opponent.ability == :CONTRARY
    else # non-speed stuff
      miniscore *= 0.1 if (@opponent.ability == :COMPETITIVE && !(Rejuv && @battle.FE == :CHESS)) || @opponent.ability == :DEFIANT || @opponent.ability == :CONTRARY
      miniscore *= 1.1 if @mondata.partyroles.any? { |roles| roles.include?(:SWEEPER) }
    end
    # status & moves section
    if stats[PBStats::DEFENSE] > 0 || stats[PBStats::SPATK] > 0 || stats[PBStats::SPDEF] > 0
      miniscore *= 1.2 if (@opponent.status == :POISON || @opponent.status == :BURN) && @opponent.crested != :SUICUNE
    end
    if stats[PBStats::ATTACK] > 0
      miniscore *= 1.2 if @opponent.status == :POISON && @opponent.crested != :SUICUNE
      miniscore *= 0.5 if @opponent.status == :BURN && @opponent.crested != :SUICUNE
      miniscore *= 0.5 if @attacker.pbHasMove?(:FOULPLAY)
    end
    if stats[PBStats::SPEED] > 0
      miniscore *= 0.5 if @attacker.pbHasMove?(:GYROBALL)
      miniscore *= 1.5 if @attacker.pbHasMove?(:ELECTROBALL)
      miniscore *= 1.3 if checkAImoves([:ELECTROBALL])
      miniscore *= 1.5 if @attacker.crested == :ARIADOS && @opponent.stages[PBStats::SPEED] > -1
      miniscore *= 0.5 if checkAImoves([:GYROBALL])
      miniscore *= 0.1 if @battle.state.effects[:TrickRoom] != 0 || checkAImoves([:TRICKROOM])
      miniscore *= dynamicspeedcode(:opponentstage, -stats[PBStats::SPEED])
    end
    if @battle.pbPokemonCount(@battle.pbCombinedParty(@opponent.index)) == 1 || PBStuff::TRAPPINGABILITIESAI.include?(@attacker.ability) || (@attacker.ability == :MAGNETPULL && @opponent.hasType?(:STEEL)) || @opponent.effects[:MeanLook] >= 0
      miniscore *= 1.2
    end
    miniscore *= 0.5 if @mondata.roles.include?(:PHAZER)
    miniscore *= 0.8 if hasgreatmoves() # hoping this doesn't self sabotage
    if @move.pbIsDamaging?
      miniscore = pbSereneGraceCheck(miniscore)
    else
      miniscore *= 0.5 if @battle.pbPokemonCount(@battle.pbCombinedParty(@attacker.index)) == 1
      miniscore *= 0.7 if !@attacker.status.nil?
    end
    return miniscore
  end

  def focusenergycode(critRateLimit = 1)
    return 0 if @attacker.effects[:FocusEnergy] > critRateLimit

    miniscore = 1.0
    attackerHPpercent = @attacker.hp.to_f / @attacker.totalhp
    if attackerHPpercent > 0.75
      miniscore *= 1.2
    elsif attackerHPpercent > 0.5 && attackerHPpercent < 0.75 && (@attacker.ability == :EMERGENCYEXIT || @attacker.ability == :WIMPOUT || (@attacker.itemWorks? && @attacker.item == :EJECTBUTTON))
      miniscore *= 0.3
    elsif attackerHPpercent < 0.33
      miniscore *= 0.3
    end
    miniscore *= 1.3 if @opponent.effects[:HyperBeam] > 0
    miniscore *= 1.7 if @opponent.effects[:Yawn] > 0
    miniscore *= 0.6 if @attacker.effects[:LeechSeed] >= 0 || @attacker.effects[:Attract] >= 0
    miniscore *= 0.5 if checkAImoves(PBStuff::PHASEMOVE)
    miniscore *= 0.2 if @attacker.effects[:Confusion] > 0
    miniscore *= 0.3 if @attacker.pbOpposingSide.effects[:Retaliate]
    miniscore *= 1.2 if (@attacker.hp / 4.0) > checkAIdamage()
    miniscore *= 1.2 if @attacker.turncount < 2
    miniscore *= 1.2 if !@opponent.status.nil?
    miniscore *= 1.3 if (@opponent.status == :SLEEP || @opponent.status == :FROZEN) && @opponent.crested != :SUICUNE
    miniscore *= 1.5 if @opponent.effects[:Encore] > 0 && @opponent.moves[(@opponent.effects[:EncoreIndex])].pbIsStatus?
    miniscore *= 0.5 if @battle.doublebattle
    miniscore *= 2 if @attacker.ability == :SUPERLUCK || @attacker.ability == :SNIPER
    miniscore *= 1.2 if @mondata.attitemworks && (@attacker.item == :SCOPELENS || @attacker.item == :RAZORCLAW || (@attacker.item == :STICK && @attacker.pokemon.species == :FARFETCHD) || (@attacker.item == :LUCKYPUNCH && @attacker.pokemon.species == :CHANSEY))
    miniscore *= 1.3 if (@mondata.attitemworks && @attacker.item == :LANSATBERRY)
    miniscore *= 0.2 if @opponent.ability == :ANGERPOINT || @opponent.ability == :SHELLARMOR || @opponent.ability == :BATTLEARMOR
    miniscore *= 0.5 if @attacker.pbHasMove?(:LASERFOCUS) || @attacker.pbHasMoveFunction?(0x0A0, 0x319) # Frost Breath, Surging Strikes
    miniscore *= 2**(@attacker.moves.count { |moveloop| moveloop != nil && moveloop.highCritRate? })
    return miniscore
  end

  def dragoncheercode # Partner targeting move, @opponent refers to the partner here
    return 0 if @opponent.effects[:FocusEnergy] >= 1

    partner = @opponent
    opp1 = @attacker.pbFirstOpposing
    opp2 = opp1.pbPartner

    miniscore = 0.5
    partnerHPpercent = partner.hp.to_f / partner.totalhp
    if partnerHPpercent > 0.75
      miniscore *= 1.2
    elsif partnerHPpercent > 0.5 && partnerHPpercent < 0.75 && (partner.ability == :EMERGENCYEXIT || partner.ability == :WIMPOUT || (partner.itemWorks? && partner.item == :EJECTBUTTON))
      miniscore *= 0.3
    elsif partnerHPpercent < 0.33
      miniscore *= 0.3
    end
    miniscore *= 1.3 if opp1.effects[:HyperBeam] > 0 || opp2.effects[:HyperBeam] > 0
    miniscore *= 1.7 if opp1.effects[:Yawn] > 0 || opp2.effects[:Yawn] > 0
    miniscore *= 0.6 if partner.effects[:LeechSeed] >= 0 || partner.effects[:Attract] >= 0
    miniscore *= 0.5 if checkAImovesAllOpponents(PBStuff::PHASEMOVE)
    miniscore *= 0.2 if partner.effects[:Confusion] > 0
    miniscore *= 0.3 if @attacker.pbOpposingSide.effects[:Retaliate]
    miniscore *= 1.2 if (partner.hp / 4.0) > checkAIdamage(partner, opp1)
    miniscore *= 1.2 if partner.turncount < 2
    miniscore *= 1.2 if !opp1.status.nil? || !opp2.status.nil?
    miniscore *= 1.3 if [:SLEEP, :FROZEN].intersect?([opp1.status, opp2.status])
    miniscore *= 1.5 if [opp1, opp2].any? { |opp| opp.effects[:Encore] > 0 && opp.moves[opp.effects[:EncoreIndex]].pbIsStatus? }
    miniscore *= 2 if partner.ability == :SUPERLUCK || partner.ability == :SNIPER
    miniscore *= 1.2 if partner.itemWorks? && (partner.item == :SCOPELENS || partner.item == :RAZORCLAW || (partner.item == :STICK && partner.pokemon.species == :FARFETCHD) || (partner.item == :LUCKYPUNCH && partner.pokemon.species == :CHANSEY))
    miniscore *= 1.3 if partner.hasWorkingItem(:LANSATBERRY)
    miniscore *= 0.2 if [:ANGERPOINT, :SHELLARMOR, :BATTLEARMOR].intersect?([opp1.ability, opp2.ability])
    miniscore *= 0.5 if partner.pbHasMove?(:LASERFOCUS) || partner.pbHasMoveFunction?(0x0A0, 0x319) # Frost Breath, Surging Strikes
    miniscore *= 2**(partner.moves.count { |moveloop| moveloop != nil && moveloop.highCritRate? })
    miniscore *= 4 if partner.hasType?(:DRAGON) || @battle.FE == :DRAGONSDEN
    return miniscore
  end

  def selfStatBoostHPLoss(statarray, hploss)
    threat, incoming = nil, 0
    for opp in [@opponent, @opponent.pbPartner]
      damage = checkAIdamage(@attacker, opp)
      if damage > incoming
        threat, incoming = opp, damage
      end
    end
    aifaster = pbAIfaster?(nil, nil, @attacker, threat)
    hp = @attacker.hp

    # If attacker is faster, the move will go off first, otherwise it will take damage from opponent
    hp -= aifaster ? hploss : incoming
    return 0 if hp <= 0 # this means either the attacker doesn't have enough HP to use the move or expects to get KO'd before moving

    # Apply berry recovery at this stage
    unless aiCheckSideAbility(PBStuff::UnnerveAbilities, @opponent).any? || !@mondata.attitemworks
      threshold, recovery = 0, 0
      if @attacker.item == :SITRUSBERRY
        threshold = (@attacker.totalhp / 2.0).floor
        recovery = (@attacker.totalhp / 4.0).floor
      elsif [:FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY].include?(@attacker.item)
        threshold = (@attacker.totalhp / (@attacker.ability == :GLUTTONY ? 2.0 : 4.0)).floor
        recovery = (@attacker.totalhp / (Gen <= 7 ? 2.0 : 3.0)).floor
      end
      recovery *= 2 if @attacker.ability == :RIPEN
      recovery += (@attacker.totalhp / 3.0).floor if @attacker.ability == :CHEEKPOUCH && recovery > 0
      hp += recovery if threshold > 0 && hp <= threshold
      hp = @attacker.totalhp if hp > @attacker.totalhp
    end

    # If attacker was faster, now it will take damage from opponent, otherwise the move will go off
    hp -= aifaster ? incoming : hploss
    return 0 if hp <= 0 # this means either the attacker expects to not have enough HP to use the move after taking damage or expects to get KO'd after using the move

    # Apply Wish recovery at this stage
    hp += @attacker.effects[:WishAmount] if @attacker.effects[:Wish] == 1 && opponent.canHeal?
    hp = @attacker.totalhp if hp > @attacker.totalhp

    miniscore = selfstatboost(statarray)
    miniscore *= 1.2 if @attacker.turncount < 1
    # Decrease score if the attacker is likely to get KO'd next turn before it can do anything
    has_damaging_prio_move = @attacker.moves.any? { |move| move.pbIsDamaging? && move.pbIsPriorityMoveAI(@attacker) && !pbTypeModNoMessages(move.pbType(@attacker), @attacker, @opponent, move).immune? && moveSuccessful?(move, @attacker, @opponent) }
    miniscore *= 0.1 if !aifaster && !has_damaging_prio_move

    return miniscore
  end

  def defogcode
    yourpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))
    theirpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@opponent.index))
    mincount = @battle.doublebattle ? 2 : 1 # Count needs to be higher than this for hazards to do anything
    yourside = @attacker.pbOwnSide.effects
    theirside = @opponent.pbOwnSide.effects
    effcheck = proc { |eff| @move.move != :COURTCHANGE || yourside[eff] != theirside[eff] }

    miniscore = 1.0
    if yourpartycount > mincount
      miniscore *= 2 if yourside[:StealthRock] && effcheck.call(:StealthRock)
      miniscore *= 3 if yourside[:StickyWeb] && effcheck.call(:StickyWeb)
      miniscore *= (1.5**yourside[:Spikes]) if effcheck.call(:Spikes)
      miniscore *= (1.7**yourside[:ToxicSpikes]) if effcheck.call(:ToxicSpikes)
    end
    miniscore -= 1.0
    miniscore *= (yourpartycount - mincount) if yourpartycount > mincount

    minimini = 1.0
    if theirpartycount > mincount
      minimini *= 2 if theirside[:StealthRock] && effcheck.call(:StealthRock)
      minimini *= 3 if theirside[:StickyWeb] && effcheck.call(:StickyWeb)
      minimini *= (1.5**theirside[:Spikes]) if effcheck.call(:Spikes)
      minimini *= (1.7**theirside[:ToxicSpikes]) if effcheck.call(:ToxicSpikes)
    end
    minimini -= 1.0
    minimini *= (theirpartycount - mincount) if theirpartycount > mincount

    miniscore -= minimini
    unless @move.move == :COURTCHANGE
      miniscore += 1.0
      miniscore = 0 if miniscore < 0
    end

    otherscore = 1.0
    if [:DEFOG, :COURTCHANGE].include?(@move.move)
      otherscore *= 2 if theirside[:Reflect] > 0 && effcheck.call(:Reflect)
      otherscore *= 2 if theirside[:LightScreen] > 0 && effcheck.call(:LightScreen)
      otherscore *= 3 if theirside[:AuroraVeil] > 0 && effcheck.call(:AuroraVeil)
      otherscore *= 2 if theirside[:AreniteWall] > 0 && effcheck.call(:AreniteWall)
      otherscore *= 1.3 if theirside[:Safeguard] > 0 && effcheck.call(:Safeguard)
      otherscore *= 1.3 if theirside[:Mist] > 0 && effcheck.call(:Mist)
    end
    if @move.move == :COURTCHANGE
      otherscore *= 3 if theirside[:Tailwind] > 0 && effcheck.call(:Tailwind)
      otherscore *= 1.3 if theirside[:LuckyChant] > 0 && effcheck.call(:LuckyChant)
      otherscore *= 0.5 if yourside[:Reflect] > 0 && effcheck.call(:Reflect)
      otherscore *= 0.5 if yourside[:LightScreen] > 0 && effcheck.call(:LightScreen)
      otherscore *= 0.3 if yourside[:AuroraVeil] > 0 && effcheck.call(:AuroraVeil)
      otherscore *= 0.5 if yourside[:AreniteWall] > 0 && effcheck.call(:AreniteWall)
      otherscore *= 0.7 if yourside[:Safeguard] > 0 && effcheck.call(:Safeguard)
      otherscore *= 0.7 if yourside[:Mist] > 0 && effcheck.call(:Mist)
      otherscore *= 0.2 if yourside[:Tailwind] > 0 && effcheck.call(:Tailwind)
      otherscore *= 0.7 if yourside[:LuckyChant] > 0 && effcheck.call(:LuckyChant)
    end
    if @move.move == :TIDYUP
      otherscore *= 0.8 if @attacker.effects[:Substitute] > 0
      otherscore *= 0.8 if @attacker.pbPartner.effects[:Substitute] > 0
      otherscore *= 1.25 if @opponent.effects[:Substitute] > 0
      otherscore *= 1.25 if @opponent.pbPartner.effects[:Substitute] > 0
    end
    otherscore = 0 if otherscore <= 1

    miniscore += otherscore
    return miniscore
  end

  def hazardremovalcode
    return 0 if @attacker.pbNonActivePokemonCount == 0 && (!@battle.doublebattle || @attacker.pbPartner.pbNonActivePokemonCount == 0)

    miniscore = 0.0
    yourparty = @battle.pbPartySingleOwner(@attacker.index)
    yourparty += @battle.pbPartySingleOwner(@attacker.pbPartner.index) if @battle.doublebattle

    for pkmn in yourparty
      next if !pkmn || pkmn.isEgg? || pkmn.hp == 0 || pkmn.item == :HEAVYDUTYBOOTS

      miniscore += 1 if @attacker.pbOwnSide.effects[:StickyWeb] && !pkmn.isAirborne? && pkmn.ability != :CONTRARY

      next if @battle.magicGuardAbilities.include?(pkmn.ability)

      knowsHPBasedMove = pkmn.moves.any? { |moveloop| moveloop && [0x8b, 0xe1].include?(moveloop.function) } # Eruption / Water Spout / Dragon Energy / Final Gambit
      fullHPAbilities = [:MULTISCALE, :STURDY, :TERASHELL]
      fullHPAbilities.push(:STALWART) if @battle.FE == :COLOSSEUM
      fullHPAbilities.push(:SHADOWSHIELD) unless @battle.FE == :DIMESNIONAL
      fullHPAbilities.push(:GALEWINGS) unless @battle.FE == :SKY
      needsFullHP = fullHPAbilities.include?(pkmn.ability) || pkmn.item == :FOCUSSASH

      steathrocktype = :ROCK
      steathrocktype = :FIRE if [:VOLCANICTOP, :INFERNAL, :DRAGONSDEN].include?(@battle.FE) && Rejuv
      steathrocktype = :POISON if @battle.FE == :CORRUPTED && Rejuv
      stealthrockEffectiveness = PBTypes.typesEff(steathrocktype, pkmn.types, inverse: @battle.inverse?)
      if @attacker.pbOwnSide.effects[:StealthRock] && !stealthrockEffectiveness.immune?
        if stealthrockEffectiveness.doubleSuperEffective?
          miniscore += [:ROCKY, :CAVE].include?(@battle.FE) ? 4.5 : 1.5
        elsif stealthrockEffectiveness.superEffective?
          miniscore += [:ROCKY, :CAVE].include?(@battle.FE) ? 3 : 1
        end
        miniscore += 2.5 if pkmn.hp == pkmn.totalhp && needsFullHP
        miniscore += 1.3 if knowsHPBasedMove
      end

      spikesEffectiveness = Typemod.normal
      spikesEffectiveness = PBTypes.typesEff(:ELECTRIC, pkmn.types, inverse: @battle.inverse?) if @battle.FE == :ELECTERRAIN && Rejuv
      if @attacker.pbOwnSide.effects[:Spikes] > 0 && !pkmn.isAirborne? && !spikesEffectiveness.immune?
        if spikesEffectiveness.doubleSuperEffective?
          miniscore += (1.5**@attacker.pbOwnSide.effects[:Spikes])
        elsif spikesEffectiveness.superEffective?
          miniscore += @attacker.pbOwnSide.effects[:Spikes]
        end
        miniscore += (1.5**@attacker.pbOwnSide.effects[:Spikes]) if pkmn.hp == pkmn.totalhp && needsFullHP
        miniscore += (1.3**@attacker.pbOwnSide.effects[:Spikes]) if knowsHPBasedMove
      end

      if @attacker.pbOwnSide.effects[:ToxicSpikes] > 0 && !pkmn.isAirborne? && pkmn.status.nil?
        if !pkmn.hasType?(:POISON) && !pkmn.hasType?(:STEEL) && ![:IMMUNITY, :POISONHEAL, :TOXICBOOST, :COMATOSE, :PURIFYINGSALT, :GUTS, :QUICKFEET].include?(pkmn.ability) && !(pkmn.ability == :PASTELVEIL && @battle.FE != :INFERNAL)
          if pkmn.moves.any? { |moveloop| moveloop != nil && [0xd5, 0xd6, 0xd7, 0xd8, 0xda, 0xdb, 0xdf, 0x114, 0x162, 0x169, 0x16C, 0x172].include?(moveloop.function) } # Healing move functions except Rest
            miniscore += (1.8**@attacker.pbOwnSide.effects[:ToxicSpikes])
          else
            miniscore += (1.5**@attacker.pbOwnSide.effects[:ToxicSpikes])
          end
        end
      end
    end

    return miniscore
  end

  def volcanoeruptioncode
    return 1 if @battle.eruption

    miniscore = 1.0
    abilities = [:MAGMAARMOR, :FLASHFIRE, :FLAREBOOST, :BLAZE, :FLAMEBODY, :SOLIDROCK, :STURDY, :BATTLEARMOR, :SHELLARMOR, :WATERBUBBLE, :MAGICGUARD, :WONDERGUARD, :PRISMARMOR]

    for ally in [@attacker, @attacker.pbPartner]
      next if ally.isFainted?
      typemod = PBTypes.typesEff(:FIRE, ally.types, inverse: @battle.inverse?)
      unless typemod.immune? || abilities.include?(ally.ability) || ally.effects[:AquaRing]
        miniscore *= 0.9 if typemod.resisted?
        miniscore *= 0.75 if typemod.effective?
      end
      miniscore *= 1.5 if ally.ability == :FLASHFIRE && !ally.effects[:FlashFire]
      miniscore *= 1.5 if ally.ability == :BLAZE && !ally.effects[:Blazed]
      miniscore *= 1.3 if ally.ability == :FLAREBOOST
      miniscore *= 1.75 if ally.ability == :MAGMAARMOR
      miniscore *= 1.3 if ally.effects[:LeechSeed] >= 0
    end

    for opp in [@opponent, @opponent.pbPartner]
      next if opp.isFainted?
      miniscore *= 1.2 if PBTypes.typesEff(:FIRE, opp.types, inverse: @battle.inverse?).effective?
      miniscore *= 0.5 if opp.ability == :FLASHFIRE && !opp.effects[:FlashFire]
      miniscore *= 0.5 if opp.ability == :BLAZE && !opp.effects[:Blazed]
      miniscore *= 0.75 if opp.ability == :FLAREBOOST
      miniscore *= 0.2 if opp.ability == :MAGMAARMOR
      miniscore *= 0.8 if opp.effects[:LeechSeed] >= 0
    end

    yourpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))
    theirpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@opponent.index))
    minimini1 = 1.0
    if yourpartycount > 1
      minimini1 *= 1.5 if @attacker.pbOwnSide.effects[:StealthRock]
      minimini1 *= 2 if @attacker.pbOwnSide.effects[:StickyWeb]
      minimini1 *= 1.3**@attacker.pbOwnSide.effects[:Spikes]
      minimini1 *= 1.5**@attacker.pbOwnSide.effects[:ToxicSpikes]
    end
    minimini1 -= 1.0
    minimini1 *= (yourpartycount - 1) if yourpartycount > 1
    minimini2 = 1.0
    if theirpartycount > 1
      minimini2 *= 0.75 if @opponent.pbOwnSide.effects[:StealthRock]
      minimini2 *= 0.5 if @opponent.pbOwnSide.effects[:StickyWeb]
      minimini2 *= (0.9**@opponent.pbOwnSide.effects[:Spikes])
      minimini2 *= (0.85**@opponent.pbOwnSide.effects[:ToxicSpikes])
    end
    minimini2 -= 1.0
    minimini2 *= (theirpartycount - 1) if theirpartycount > 1
    subscore = (minimini1 + minimini2 + 1.0)
    if subscore < 0.5
      subscore = 0.5
    end
    miniscore *= subscore
    return miniscore
  end

  def oppstatrestorecode
    return 1 if @opponent.effects[:Substitute] > 0

    miniscore = 1 + 0.05 * statchangecounter(@opponent, 1, 7)
    miniscore *= 1.1 if (
      @opponent.ability == :SPEEDBOOST || (@opponent.ability == :MOTORDRIVE && @battle.FE == :ELECTERRAIN) ||
      (@opponent.ability == :STEAMENGINE && [:UNDERWATER, :WATERSURFACE, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@battle.FE))
    )
    miniscore *= dynamicspeedcode(:opponentstage, -@opponent.stages[PBStats::SPEED]) if @opponent.stages[PBStats::SPEED] > 0
    return miniscore
  end

  def hazecode
    oppscore = 1.1 * statchangecounter(@opponent, 1, 7)
    attscore = -1.1 * statchangecounter(@attacker, 1, 7)
    if @battle.doublebattle
      oppscore += 1.1 * statchangecounter(@opponent.pbPartner, 1, 7) if @opponent.pbPartner.hp > 0
      attscore += -1.1 * statchangecounter(@attacker.pbPartner, 1, 7) if @attacker.pbPartner.hp > 0
    end
    oppscore *= dynamicspeedcode(:opponentstage, -@opponent.stages[PBStats::SPEED]) if @opponent.stages[PBStats::SPEED] > 0
    attscore *= dynamicspeedcode(:partnerstage, -@attacker.pbPartner.stages[PBStats::SPEED]) if @attacker.pbPartner.stages[PBStats::SPEED] < 0
    miniscore = oppscore + attscore
    miniscore *= 0.8 if (
      (@opponent.ability == :SPEEDBOOST || (@opponent.ability == :MOTORDRIVE && @battle.FE == :ELECTERRAIN) || (@opponent.ability == :STEAMENGINE && [:UNDERWATER, :WATERSURFACE, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@battle.FE))) ||
      checkAImoves(PBStuff::SETUPMOVE)
    )
    return miniscore
  end

  def statswapcode(stat1, stat2)
    attstages = @attacker.stages[stat1] + @attacker.stages[stat2]
    miniscore = -1.1 * attstages
    if (pbRoughStat(@attacker, stat1) > pbRoughStat(@attacker, stat2))
      miniscore *= 2 if @attacker.stages[stat1] < 0
    else
      miniscore *= 2 if @attacker.stages[stat2] < 0
    end
    oppstages = @opponent.stages[stat1] + @opponent.stages[stat2]
    minimini = -1.1 * attstages
    if (pbRoughStat(@opponent, stat1) > pbRoughStat(@opponent, stat2))
      minimini *= 2 if @opponent.stages[stat1] > 0
    else
      minimini *= 2 if @opponent.stages[stat2] > 0
    end
    miniscore += minimini
    miniscore *= 0.8 if @battle.doublebattle
    return miniscore
  end

  def psychupcode
    statarray = [0, 0, 0, 0, 0, 0, 0]
    boostarray = [0, 0, 0, 0, 0, 0, 0]
    droparray = [0, 0, 0, 0, 0, 0, 0]
    statarray[0] = (@opponent.stages[PBStats::ATTACK] - @attacker.stages[PBStats::ATTACK])
    statarray[1] = (@opponent.stages[PBStats::DEFENSE] - @attacker.stages[PBStats::DEFENSE])
    statarray[2] = (@opponent.stages[PBStats::SPATK] - @attacker.stages[PBStats::SPATK])
    statarray[3] = (@opponent.stages[PBStats::SPDEF] - @attacker.stages[PBStats::SPDEF])
    statarray[4] = (@opponent.stages[PBStats::SPEED] - @attacker.stages[PBStats::SPEED])
    statarray[5] = (@opponent.stages[PBStats::ACCURACY] - @attacker.stages[PBStats::ACCURACY])
    statarray[6] = (@opponent.stages[PBStats::EVASION] - @attacker.stages[PBStats::EVASION])
    for i in 0..6
      boostarray[i] = statarray[i] if statarray[i] > 0
      droparray[i] = statarray[i] * -1 if statarray[i] < 0
    end
    return boostarray, droparray
  end

  def mistcode
    miniscore = 1.0
    if @attacker.pbOwnSide.effects[:Mist] == 0
      miniscore *= 1.1
      # check opponent for stat decreasing moves
      miniscore *= 1.3 if getAIMemory().any? { |j| [0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0xE2, 0x138, 0x13B, 0x13F].include?(j.function) }
    end
    return miniscore
  end

  def powertrickcode
    miniscore = 1.0
    if @attacker.attack - @attacker.defense >= 100
      miniscore *= 1.5 if pbAIfaster?(@move)
      miniscore *= 2 if pbRoughStat(@opponent, PBStats::ATTACK) > pbRoughStat(@opponent, PBStats::SPATK)
      miniscore *= 2 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.isHealingMove? }
    elsif @attacker.defense - @attacker.attack >= 100
      if pbAIfaster?(@move)
        miniscore *= 1.5
        miniscore *= 2 if notOHKO?(@opponent, @attacker)
      else
        miniscore *= 0
      end
    else
      miniscore *= 0.1
    end
    miniscore *= 0.1 if @attacker.effects[:PowerTrick]
    return miniscore
  end

  def splitcode(stat)
    return 0 if @opponent.effects[:Substitute] > 0

    miniscore = 1.0
    case stat
      when PBStats::ATTACK
        if @opponent.attack > @opponent.spatk
          return 0 if @attacker.attack > @opponent.attack

          miniscore = @opponent.attack - @attacker.attack
          miniscore *= @attacker.attack > @attacker.spatk ? 2 : 0.5
        else
          return 0 if @attacker.spatk > @opponent.spatk

          miniscore = @opponent.spatk - @attacker.spatk
          miniscore *= @attacker.spatk > @attacker.attack ? 2 : 0.5
        end
      when PBStats::DEFENSE
        if @opponent.attack > @opponent.spatk
          return 0 if @attacker.defense > @opponent.defense

          miniscore = @opponent.defense - @attacker.defense
          miniscore *= @attacker.attack > @attacker.spatk ? 2 : 0.5
        else
          return 0 if @attacker.spdef > @opponent.spdef

          miniscore = @opponent.spdef - @attacker.spdef
          miniscore *= @attacker.spatk > @attacker.attack ? 2 : 0.5
        end
      when PBStats::HP
        ministat = [(@opponent.hp + @attacker.hp) / 2.0, @attacker.totalhp].min
        return 0 if ministat < @attacker.hp && pbAIfaster?(@move)

        maxdam = checkAIdamage()
        return 0 if @opponent.hp <= (@attacker.hp - maxdam)
        return 0 if maxdam > ministat
        if maxdam > @attacker.hp
          return pbAIfaster?(@move) ? 2 : 0
        else
          miniscore *= 0.3 if checkAImoves(PBStuff::SETUPMOVE)
          miniscore *= @opponent.hp / (@attacker.hp).to_f
          return miniscore
        end
    end
    miniscore = 1 + miniscore / 100.0
    return miniscore
  end

  def tailwindcode
    return 0 if @attacker.pbOwnSide.effects[:Tailwind] > 0

    miniscore = 1.5
    if pbAIfaster?() && !@mondata.roles.include?(:LEAD)
      miniscore *= 0.9
      miniscore *= 0.4 if @attacker.pbNonActivePokemonCount == 0
    end
    miniscore *= 0.5 if (
      @opponent.ability == :SPEEDBOOST || (@opponent.ability == :MOTORDRIVE && @battle.FE == :ELECTERRAIN) ||
      (@opponent.ability == :STEAMENGINE && [:UNDERWATER, :WATERSURFACE, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@battle.FE))
    )
    miniscore *= 0.1 if @battle.state.effects[:TrickRoom] != 0 || checkAImovesAllOpponents([:TRICKROOM])
    miniscore *= 1.4 if @mondata.roles.include?(:LEAD)
    miniscore *= 2.5 if !@battle.opponent.nil? && !@battle.opponent.is_a?(Array) && @battle.opponent.trainertype == :ADRIENN && @attacker.index.odd?
    miniscore *= 0.3 if checkAImovesAllOpponents([:SNATCH, :COURTCHANGE])

    [@attacker, @attacker.pbPartner].each { |mon|
      miniscore *= 1.2 if mon.ability == :WINDRIDER && mon.pbCanIncreaseStatStage?(PBStats::ATTACK, mon, nil)
      miniscore *= 1.2 if mon.ability == :WINDPOWER && mon.effects[:Charge] == 0
    }
    party = @battle.pbCombinedParty(@attacker.index) - [@attacker.pokemon, @attacker.pbPartner.pokemon]
    party.each { |mon| miniscore *= 1.1 if mon && mon.ability == :WINDRIDER }

    miniscore *= dynamicspeedcode(:tailwind, 2.0)
    return miniscore
  end

  def mimicsketchcode
    return 0 if @opponent.effects[:Substitute] > 0
    lastmove = @move.move == :SKETCH ? @opponent.lastRegularMoveUsed : @opponent.lastMoveUsed
    return 0 if !lastmove.is_a?(Symbol)
    blacklist = PBStuff::BLACKLISTS[@move.move]
    return 0 if pbAIfaster?(@move) && blacklist.include?(lastmove)

    lastmove = moveToMoveObject(lastmove, @opponent)
    miniscore = lastmove.pbIsDamaging? && !lastmove.pbFixedDamageMove? ? lastmove.basedamage : 40
    miniscore = 1 + miniscore / 100.0
    miniscore *= 0.5 if miniscore <= 1.5
    miniscore *= 0.5 if !pbAIfaster?(@move)
    return miniscore
  end

  def typechangecode(type)
    return 0 if type.nil?

    type = type.intern if !type.is_a?(Symbol)
    return 0 if @attacker.types == [type]
    return 0 if !@attacker.canChangeType?
    return 0 if [:COLORCHANGE].include?(@attacker.ability)
    return 0 if @attacker.ability == :DOWNLOAD && @battle.FE == :DIMENSIONAL
    return 0 if [:PROTEAN, :LIBERO].include?(@attacker.ability) && (Gen < 9 || !@attacker.effects[:ProteanUsed])

    otypemods = []
    ntypemods = []
    for otype in @opponent.types
      otypemods.push PBTypes.typesEff(otype, @attacker.types, inverse: @battle.inverse?)
      ntypemods.push PBTypes.oneTypeEff(otype, type, inverse: @battle.inverse?)
    end
    miniscore = Typemod.max(*otypemods).multiplier
    minimini = Typemod.max(*ntypemods).multiplier
    return 0 if minimini > miniscore

    miniscore *= 8
    miniscore *= pbAIfaster?(@move) ? 1.2 : 0.7
    stabvar = false
    newstabvar = false
    for i in @attacker.moves
      next if i.nil?

      stabvar = true if @attacker.hasType?(i.pbType(@attacker)) && i.pbIsDamaging?
      newstabvar = true if i.pbType(@attacker) == type && i.pbIsDamaging?
    end
    if stabvar && !newstabvar
      miniscore *= 1.2
    else
      miniscore *= 0.6
    end
    return miniscore
  end

  def opptypechangecode(type)
    return 0 if @opponent.types == [type]
    return 0 if !@opponent.canChangeType?
    return 0 if [:COLORCHANGE].include?(@opponent.ability)
    return 0 if @opponent.ability == :DOWNLOAD && @battle.FE == :DIMENSIONAL
    return 0 if [:PROTEAN, :LIBERO].include?(@opponent.ability) && (Gen < 9 || !@opponent.effects[:ProteanUsed])

    otypemods = []
    ntypemods = []
    for atype in @attacker.types
      otypemods.push PBTypes.typesEff(atype, @opponent.types, inverse: @battle.inverse?)
      ntypemods.push PBTypes.oneTypeEff(atype, type, inverse: @battle.inverse?)
    end
    miniscore = Typemod.max(*otypemods).multiplier
    minimini = Typemod.max(*ntypemods).multiplier
    if @move.function != 0x205
      return 0 if minimini < miniscore

      minimini *= 0.5 if getAIMemory(@opponent).any? { |moveloop| moveloop != nil && moveloop.pbType(@opponent) == type }
    end
    minimini *= 4
    minimini *= 1.5 if @attacker.moves.any? { |moveloop| moveloop != nil && PBTypes.oneTypeEff(moveloop.pbType(@attacker), type, inverse: @battle.inverse?).superEffective? }
    return minimini
  end

  def opptypeaddcode(type)
    return 0 if @opponent.types.include?(type)
    return 0 if !@opponent.canChangeType?
    return 0 if [:COLORCHANGE].include?(@opponent.ability)
    return 0 if @opponent.ability == :DOWNLOAD && @battle.FE == :DIMENSIONAL
    return 0 if [:PROTEAN, :LIBERO].include?(@opponent.ability) && (Gen < 9 || !@opponent.effects[:ProteanUsed])

    ntypes = @opponent.types.clone
    ntypes.push type
    otypemods = []
    ntypemods = []
    for atype in @attacker.types
      otypemods.push PBTypes.typesEff(atype, @opponent.types, inverse: @battle.inverse?)
      ntypemods.push PBTypes.typesEff(atype, ntypes, inverse: @battle.inverse?)
    end
    miniscore = Typemod.max(*otypemods).multiplier
    minimini = Typemod.max(*ntypemods).multiplier
    if @move.function != 0x205
      return 0 if minimini < miniscore

      minimini *= 0.5 if getAIMemory(@opponent).any? { |moveloop| moveloop != nil && moveloop.pbType(@opponent) == type }
    end
    minimini *= 4
    minimini *= 1.5 if @attacker.moves.any? { |moveloop| moveloop != nil && PBTypes.typesEff(moveloop.pbType(@attacker), ntypes, inverse: @battle.inverse?).superEffective? }
    return minimini
  end

  def abilitychangecode(ability)
    return 0 if (PBStuff::FIXEDABILITIES + [ability]).include?(@opponent.ability)
    return 0 if @mondata.oppitemworks && @opponent.item == :ABILITYSHIELD

    miniscore = getAbilityDisruptScore(@attacker, @opponent)
    if scoringAgainstPartner?
      miniscore = miniscore < 2 ? 2 - miniscore : 0
    end
    if ability == :SIMPLE
      miniscore *= 1.3 if scoringAgainstPartner? && getAIMemory().any? { |moveloop| moveloop != nil && PBStuff::SETUPMOVE.include?(moveloop) }
      miniscore *= 0.5 if checkAImoves(PBStuff::SETUPMOVE)
    elsif ability == :INSOMNIA
      miniscore *= 1.3 if checkAImoves([:SLEEPTALK, :SNORE])
      miniscore *= 2 if checkAImoves([:REST])
      miniscore *= 0.3 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::SLEEPMOVE.include?(moveloop) }
    end
    return miniscore
  end

  def roleplaycode # Role Play
    return 0 if PBStuff::ABILITYBLACKLIST.include?(@opponent.ability)
    return 0 if PBStuff::FIXEDABILITIES.include?(@attacker.ability)
    return 0 if @opponent.ability.nil? || @attacker.ability == @opponent.ability
    return 0 if @mondata.attitemworks && @attacker.item == :ABILITYSHIELD

    miniscore = getAbilityDisruptScore(@opponent, @attacker)
    minimini = getAbilityDisruptScore(@attacker, @opponent)
    return 1 + (minimini - miniscore)
  end

  def doodlecode
    return 0 if PBStuff::ABILITYBLACKLIST.include?(@opponent.ability)
    return 0 if @opponent.ability.nil?

    fixedabils = PBStuff::FIXEDABILITIES - [:COMMANDER, :ORICHALCUMPULSE, :HADRONENGINE]
    usernope = fixedabils.include?(@attacker.ability) || @attacker.ability == @opponent.ability || @attacker.hasWorkingItem(:ABILITYSHIELD)
    allynope = fixedabils.include?(@attacker.pbPartner.ability) || @attacker.pbPartner.ability == @opponent.ability || @attacker.pbPartner.hasWorkingItem(:ABILITYSHIELD)
    return 0 if usernope && allynope
    miniscore = usernope ? 0 : getAbilityDisruptScore(@opponent, @attacker)
    miniscorePartner = allynope ? 0 : getAbilityDisruptScore(@opponent, @attacker.pbPartner)
    minimini = getAbilityDisruptScore(@attacker, @opponent)
    return (1 + (minimini - miniscore) + (minimini - miniscorePartner))
  end

  def entraincode(score)
    return 0 if (PBStuff::FIXEDABILITIES + [:TRUANT]).include?(@opponent.ability)
    return 0 if (PBStuff::ABILITYBLACKLIST - [:WONDERGUARD]).include?(@attacker.ability)
    return 0 if @attacker.ability.nil? || @opponent.ability == @attacker.ability
    return 0 if @mondata.oppitemworks && @opponent.item == :ABILITYSHIELD

    miniscore = getAbilityDisruptScore(@opponent, @attacker)
    minimini = getAbilityDisruptScore(@attacker, @opponent)
    if !scoringAgainstPartner?
      score *= 1 + (minimini - miniscore)
      if @attacker.ability == :TRUANT
        score *= 3
      elsif @attacker.ability == :WONDERGUARD
        score = 0
      end
    else
      score *= 1 + (miniscore - minimini)
      case @attacker.ability
        when :WONDERGUARD then score += 85
        when :SPEEDBOOST  then score += 25
      end
      case @opponent.ability
        when :DEFEATIST  then score += 30
        when :SLOWSTART  then score += 50
      end
    end
    return score
  end

  def skillswapcode
    return 0 if PBStuff::ABILITYBLACKLIST.include?(@attacker.ability)
    return 0 if PBStuff::ABILITYBLACKLIST.include?(@opponent.ability)
    return 0 if @opponent.ability.nil? || @attacker.ability.nil? || @attacker.ability == @opponent.ability
    return 0 if (@mondata.oppitemworks && @opponent.item == :ABILITYSHIELD) || (@mondata.attitemworks && @attacker.item == :ABILITYSHIELD)

    miniscore = getAbilityDisruptScore(@opponent, @attacker)
    minimini = getAbilityDisruptScore(@attacker, @opponent)
    miniscore = [2 - miniscore, 0].max if scoringAgainstPartner?
    miniscore *= 1 + (minimini - miniscore) * 2
    miniscore *= 2 if (@attacker.ability == :TRUANT && !scoringAgainstPartner?) || (@opponent.ability == :TRUANT && scoringAgainstPartner?)
    return miniscore
  end

  def gastrocode
    return 0 if @opponent.effects[:GastroAcid] || @opponent.effects[:Substitute] > 0 || PBStuff::FIXEDABILITIES.include?(@opponent.ability) || (@mondata.oppitemworks && @opponent.item == :ABILITYSHIELD)

    return getAbilityDisruptScore(@attacker, @opponent)
  end

  def transformcode
    return 0 if @attacker.effects[:Transform] || @opponent.effects[:Transform] || @move.blockedBySubstitute?(@attacker, @opponent) || (@opponent.effects[:Illusion] && !illusionDeceived?(@attacker, @opponent)) || @opponent.isTerastallized?

    miniscore = 1 + (@opponent.level - @attacker.level) / 20
    miniscore *= 1.1 * (statchangecounter(@opponent, 1, 5) - statchangecounter(@attacker, 1, 5))
    return miniscore
  end

  def endeavorcode
    return 0 if @attacker.hp > @opponent.hp

    miniscore = 1.0
    miniscore *= 1.5 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbIsPriorityMoveAI(@attacker) }
    miniscore *= 1.5 if notOHKO?(@opponent, @attacker, true)
    miniscore *= 2 if @opponent.level - @attacker.level > 9
    return miniscore
  end

  def ohkode
    return 0 if @opponent.level > @attacker.level
    return 0 if @move.move == :SHEERCOLD && @opponent.hasType?(:ICE)
    return 0 if @battle.FE == :CHESS && @opponent.piece == :PAWN
    return 0 if (@opponent.ability == :STURDY || (@battle.FE == :COLOSSEUM && @opponent.ability == :STALWART)) && !moldBreakerCheck(@attacker, @opponent, @move)

    return 3.5 if @attacker.effects[:LockOnTarget] == @opponent.index || @opponent.ability == :NOGUARD || @attacker.ability == :NOGUARD || (@attacker.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
    return 0.7
  end

  def counterattackcode
    miniscore = 1.0
    maxdam = checkAIdamage()
    miniscore *= 0.5 if pbAIfaster?(@move)
    if notOHKO?(@opponent, @attacker, true)
      miniscore *= 1.2
    else
      miniscore *= 0.8
      miniscore *= 0.8 if maxdam > @attacker.hp
    end
    miniscore *= 0.7 if $cache.moves[@attacker.lastMoveUsed]&.function == @move.function
    miniscore *= 0.6 if checkAImoves(PBStuff::SETUPMOVE)
    miniscore *= (@attacker.hp / @attacker.totalhp)
    bestmove = checkAIbestMove()
    if @move.function == 0x71 # Counter
      if pbRoughStat(@opponent, PBStats::ATTACK) > (pbRoughStat(@opponent, PBStats::SPATK) * 1.1) # attack is at least 10% higher than sp.atk
        miniscore *= 1.1
      elsif pbRoughStat(@opponent, PBStats::ATTACK) < (pbRoughStat(@opponent, PBStats::SPATK) * 0.6)
        miniscore *= 0.3
      else
        miniscore *= 0.6
      end
      miniscore *= 0.05 if bestmove.pbIsSpecial?(@attacker)
      miniscore *= 1.1 if $cache.moves[@attacker.lastMoveUsed]&.function == 0x72
    elsif @move.function == 0x72 # Mirror Coat
      if (pbRoughStat(@opponent, PBStats::ATTACK) * 1.1) < pbRoughStat(@opponent, PBStats::SPATK) # attack is at least 10% higher than sp.atk
        miniscore *= 1.1
      elsif (pbRoughStat(@opponent, PBStats::ATTACK) * 0.6) > pbRoughStat(@opponent, PBStats::SPATK)
        miniscore *= 0.3
      else
        miniscore *= 0.6
      end
      miniscore *= 0.3 if @opponent.spatk < @opponent.attack
      miniscore *= 0.05 if bestmove.pbIsPhysical?(@attacker)
      miniscore *= 1.1 if $cache.moves[@attacker.lastMoveUsed]&.function == 0x71
    end
    return miniscore
  end

  def revengecode
    miniscore = 1.0
    miniscore *= pbAIfaster?() ? 0.5 : 1.5
    if @attacker.hp == @attacker.totalhp
      miniscore *= 1.2
      miniscore *= 1.1 if notOHKO?(@opponent, @attacker, true)
    else
      miniscore *= 0.3 if checkAIdamage() > @attacker.hp
    end
    miniscore *= 0.8 if checkAImoves(PBStuff::SETUPMOVE)
    return miniscore
  end

  def pursuitcode
    miniscore = 1 - 0.1 * statchangecounter(@opponent, 1, 7, -1)
    miniscore *= 1.2 if @opponent.effects[:Confusion] > 0
    miniscore *= 1.5 if @opponent.effects[:LeechSeed] >= 0
    miniscore *= 1.3 if @opponent.effects[:Attract] >= 0
    miniscore *= 0.7 if @opponent.effects[:Substitute] > 0
    miniscore *= 1.5 if @opponent.effects[:Yawn] > 0
    miniscore *= 1.5 if pbTypeModNoMessages(@move.pbType(@attacker)).superEffective?
    return miniscore
  end

  def echocode
    miniscore = 1.0
    miniscore *= 0.7 if @attacker.status == :PARALYSIS && @attacker.crested != :SUICUNE
    miniscore *= 0.7 if @attacker.effects[:Confusion] > 0
    miniscore *= 0.7 if @attacker.effects[:Attract] >= 0
    miniscore *= 1.3 if @attacker.hp == @attacker.totalhp
    miniscore *= 1.5 if checkAIdamage() < (@attacker.hp / 3.0)
    return miniscore
  end

  def helpinghandcode # Partner targeting move, @opponent refers to the partner here
    opp1 = @attacker.pbFirstOpposing
    opp2 = opp1.pbPartner

    partnerbestmove = checkAIbestMove(@opponent)
    opp1bestmove = checkAIbestMove(opp1)
    opp2bestmove = checkAIbestMove(opp2)

    miniscore = 1.0
    miniscore *= 2 if hasbadmoves(30)
    if !pbAIfaster?(nil, nil, @attacker, opp1) && !pbAIfaster?(nil, nil, @attacker, opp2)
      miniscore *= 1.2
      miniscore *= 1.5 if @attacker.hp / @attacker.totalhp < 0.33
      miniscore *= 1.5 if pbAIfaster?(partnerbestmove, opp1bestmove, @opponent, opp1) && pbAIfaster?(partnerbestmove, opp2bestmove, @opponent, opp2)
      miniscore *= 0.5 if pbAIfaster?(opp1bestmove, partnerbestmove, opp1, @opponent) && pbAIfaster?(opp2bestmove, partnerbestmove, opp2, @opponent)
    end
    miniscore *= 1 + (([@opponent.attack, @opponent.spatk].max - [@attacker.attack, @attacker.spatk].max) / 100.0)
    miniscore = 0 if @opponent.status == :SLEEP && @opponent.statusCount > 1 && @opponent.crested != :SUICUNE
    return miniscore
  end

  def mudsportcode
    return 0 if @battle.state.effects[:MudSport] != 0

    miniscore = 1.0
    eff1 = PBTypes.typesEff(:ELECTRIC, @attacker.types, inverse: @battle.inverse?)
    eff2 = @attacker.pbPartner.hp > 0 ? PBTypes.typesEff(:ELECTRIC, @attacker.pbPartner.types, inverse: @battle.inverse?) : Typemod.zero
    miniscore *= 1.5 if (eff1.superEffective? || eff2.superEffective?) && @opponent.hasType?(:ELECTRIC)
    miniscore *= 0.7 if pbPartyHasType?(:ELECTRIC)
    return miniscore
  end

  def watersportcode
    return 0 if @battle.state.effects[:WaterSport] != 0

    miniscore = 1.0
    eff1 = PBTypes.typesEff(:FIRE, @attacker.types, inverse: @battle.inverse?)
    eff2 = @attacker.pbPartner.hp > 0 ? PBTypes.typesEff(:FIRE, @attacker.pbPartner.types, inverse: @battle.inverse?) : Typemod.zero
    miniscore *= 1.5 if (eff1.superEffective? || eff2.superEffective?) && @opponent.hasType?(:FIRE)
    miniscore *= 0.7 if pbPartyHasType?(:FIRE)
    return miniscore
  end

  def permacritcode(initialscore)
    return 0 if scoringAgainstPartner? && (@opponent.ability != :ANGERPOINT || @opponent.stages[PBStats::ATTACK] == 6)
    return 0 if @attacker.effects[:LaserFocus] != 0 && @move.function == 0x165
    return 0.7 if [:BATTLEARMOR, :SHELLARMOR].include?(@opponent.ability) || @opponent.pbOwnSide.effects[:LuckyChant]

    miniscore = 1.0
    miniscore += 0.1 * @opponent.stages[PBStats::DEFENSE] if @opponent.stages[PBStats::DEFENSE] > 0
    miniscore += 0.1 * @opponent.stages[PBStats::SPDEF] if @opponent.stages[PBStats::SPDEF] > 0
    miniscore -= 0.1 * @attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK] < 0
    miniscore -= 0.1 * @attacker.stages[PBStats::SPATK] if @attacker.stages[PBStats::SPATK] < 0
    miniscore -= 0.1 * @attacker.effects[:FocusEnergy] if @attacker.effects[:FocusEnergy] > 0
    return miniscore if @opponent.ability != :ANGERPOINT || @opponent.stages[PBStats::ATTACK] == 6

    if scoringAgainstPartner? && @move.function != 0x165
      return 0 if @opponent.attack > @opponent.spatk || initialscore > 80

      miniscore = (100 - initialscore)
      if pbAIfaster?(nil, nil, @opponent, @attacker.pbOpposing2) && pbAIfaster?(nil, nil, @opponent, @attacker.pbOpposing1)
        miniscore *= 1.3
      else
        miniscore *= 0.7
      end
    else
      if initialscore < 100
        miniscore *= 0.7
        miniscore *= 0.2 if @opponent.attack > @opponent.spatk
      end
    end
    return miniscore
  end

  def luckychantcode
    return 0 if @attacker.pbOwnSide.effects[:LuckyChant] != 0 || [:BATTLEARMOR, :SHELLARMOR].include?(@attacker.ability)
    mem = getAIMemory()
    return 0 if mem.empty?
    miniscore = 1.5
    avg = mem.map{ |move| pbCritRateAI?(@opponent, @attacker, move) }.sum / mem.length.to_f
    avg = 0 if avg < 0
    miniscore *= avg
    return miniscore
  end

  def safeguardcode
    return 0 if @attacker.pbOwnSide.effects[:Safeguard] > 0
    miniscore = 1.0
    miniscore *= 10 if pbAIfaster?(@move) && @attacker.status.nil? && !@mondata.roles.include?(:STATUSABSORBER) && checkAImoves([:SPORE])
    # uggggh fine, i guess you are my little guardchamp
    miniscore *= 30 if Reborn && @battle.opponent && !@battle.opponent.is_a?(Array) && @battle.opponent.trainertype == :CAMERUPT && @attacker.index.odd?
    return miniscore
  end

  def screencode
    return 0 if (@attacker.pbOwnSide.effects[:Reflect] > 0 && @move.function == 0xA2) || (@attacker.pbOwnSide.effects[:LightScreen] > 0 && @move.function == 0xA3) || (@attacker.pbOwnSide.effects[:AreniteWall] > 0 && @move.function == 0x203) || (@attacker.pbOwnSide.effects[:AuroraVeil] > 0 && [0x15B, 0x80C].include?(@move.function))
    return 0 if @move.function == 0x15B && !([:HAIL, :SNOW].include?(@battle.pbWeather(@attacker)) || (@mondata.skill >= BESTSKILL && [:SNOWYMOUNTAIN, :MIRROR, :STARLIGHT, :DARKCRYSTALCAVERN, :RAINBOW, :ICY, :CRYSTALCAVERN, :FROZENDIMENSION].include?(@battle.FE)))
    return 0 if @move.function == 0x203 && !(@battle.pbWeather(@attacker) == :SANDSTORM || (@mondata.skill >= BESTSKILL && [:DESERT, :ASHENBEACH, :ROCKY, :DEUXFINALIS].include?(@battle.FE)))
    return 0 if @attacker.pbOwnSide.effects[:AuroraVeil] > 3 && [0xA2, 0xA3].include?(@move.function)

    miniscore = 1.2
    miniscore *= 0.2 if @attacker.pbOwnSide.effects[:AuroraVeil] > 0 && [0xA2, 0xA3].include?(@move.function)
    if @move.function == 0xA2 # Reflect
      if pbRoughStat(@opponent, PBStats::ATTACK) > (pbRoughStat(@opponent, PBStats::SPATK) * 1.1) # attack is at least 10% higher than sp.atk
        miniscore *= 1.3
      elsif pbRoughStat(@opponent, PBStats::ATTACK) < (pbRoughStat(@opponent, PBStats::SPATK) * 0.6)
        miniscore *= 0.5
      else
        miniscore *= 0.9
      end
    elsif @move.function == 0xA3 # Light Screen
      if (pbRoughStat(@opponent, PBStats::ATTACK) * 1.1) < pbRoughStat(@opponent, PBStats::SPATK) # sp.atk is at least 10% higher than attack
        miniscore *= 1.3
      elsif (pbRoughStat(@opponent, PBStats::ATTACK) * 0.6) > pbRoughStat(@opponent, PBStats::SPATK)
        miniscore *= 0.5
      else
        miniscore *= 0.9
      end
    end
    miniscore *= 1.1 if (@mondata.attitemworks && @attacker.item == :LIGHTCLAY) || (@mondata.skill >= BESTSKILL && @battle.FE == :MIRROR)
    if pbAIfaster?(@move)
      miniscore *= 1.1
      if @mondata.skill >= MEDIUMSKILL
        maxdam = 0
        for j in getAIMemory()
          next if @move.function == 0xA2 && !j.pbIsPhysical?(@attacker)
          next if @move.function == 0xA3 && !j.pbIsSpecial?(@attacker)
          next if @move.function == 0x203 && !@move.pbTypeModifier(j.pbType(@opponent), @opponent, @attacker).superEffective?

          tempdam = pbRoughDamage(j, @opponent, @attacker)
          maxdam = tempdam if maxdam < tempdam
        end
        damagereduction = @battle.doublebattle && @move.function != 0x203 ? PBMults::ScreenDoubles : 0.5
        miniscore *= 2 if maxdam > @attacker.hp && (maxdam * damagereduction) < @attacker.hp
      end
    end
    livecount = @battle.pbPokemonCount(@battle.pbCombinedParty(@opponent.index))
    if livecount <= 2
      miniscore *= 0.7
      miniscore *= 0.5 if livecount == 1
    else
      miniscore *= 1.4 if (@mondata.attitemworks && @attacker.item == :LIGHTCLAY)
    end
    miniscore *= 1.3 if notOHKO?(@opponent, @attacker)
    if @attacker.index == 2 # for partners to guess if the player will use a screen move
      miniscore *= 0.3 if @move.function != 0x203 && @attacker.pbPartner.pbHasMove?(:AURORAVEIL)
      miniscore *= 0.3 if @move.function == 0xA2 && @attacker.pbPartner.pbHasMove?(:REFLECT)
      miniscore *= 0.3 if @move.function == 0xA3 && @attacker.pbPartner.pbHasMove?(:LIGHTSCREEN)
      miniscore *= 0.3 if @move.function == 0x203 && @attacker.pbPartner.pbHasMove?(:ARENITEWALL)
    end
    miniscore *= 0.1 if checkAImovesAllOpponents(PBStuff::SCREENBREAKERMOVE)
    miniscore *= 0.3 if checkAImovesAllOpponents([:SNATCH, :COURTCHANGE])
    return miniscore
  end

  def secretcode
    effect = @battle.getMimicryField
    case effect
      when :ELECTERRAIN, :SHORTCIRCUIT then return paracode()
      when :GRASSY, :FOREST, :FAIRYTALE then return sleepcode()
      when :MISTY, :HOLY then return oppstatdrop([0, 0, 1, 0, 0, 0, 0])
      when :DARKCRYSTALCAVERN, :DESERT, :ASHENBEACH, :CLOUDS then return oppstatdrop([0, 0, 0, 0, 0, 1, 0])
      when :CHESS, *PBFields::DARKNESS then return oppstatdrop([0, 1, 0, 0, 0, 0, 0])
      when :BIGTOP, :STARLIGHT then return oppstatdrop([0, 0, 0, 1, 0, 0, 0])
      when :BURNING, :SUPERHEATED, :DRAGONSDEN, :VOLCANIC, :VOLCANICTOP, :INFERNAL, :DANCEFLOOR then return burncode()
      when :SWAMP, :WATERSURFACE, :GLITCH then return oppstatdrop([0, 0, 0, 0, 1, 0, 0])
      when :RAINBOW then return (paracode() + poisoncode() + burncode() + freezecode() + sleepcode()) / 5
      when :CORROSIVE, :CORROSIVEMIST, :MURKWATERSURFACE, :CORRUPTED, :BACKALLEY, :CITY then return poisoncode()
      when :ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION then return freezecode()
      when :ROCKY, :CAVE, :MOUNTAIN, :DEUXFINALIS, :DIMENSIONAL, :DEEPEARTH, *PBFields::CONCERT then return flinchcode()
      when :FACTORY, :UNDERWATER then return oppstatdrop([1, 0, 0, 0, 0, 0, 0])
      when :WASTELAND then return (paracode() + poisoncode() + burncode() + freezecode()) / 4
      when :CRYSTALCAVERN then return (confucode() + poisoncode() + burncode() + sleepcode()) / 4
      when :MIRROR, :FLOWERGARDEN1, :FLOWERGARDEN2 then return oppstatdrop([0, 0, 0, 0, 0, 0, 1])
      when :FLOWERGARDEN3, :FLOWERGARDEN4 then return oppstatdrop([0, 1, 0, 1, 0, 0, 1])
      when :FLOWERGARDEN5 then return oppstatdrop([0, 2, 0, 2, 0, 0, 2])
      when :NEWWORLD then return oppstatdrop([1, 1, 1, 1, 1, 1, 1])
      when :INVERSE, :PSYTERRAIN, :SKY then return confucode()
      when :BEWITCHED then return (paracode() + poisoncode() + sleepcode()) / 3
      when :HAUNTED then return spoopycode()
      when :COLOSSEUM then return selfstatboost([1, 0, 0, 0, 0, 0, 0])
      else return paracode()
    end
  end

  def nevermisscode(score)
    miniscore = 1.0
    miniscore *= 1.05 if score >= 110
    return miniscore if [:NOGUARD, :HOTSHOT].include?(@attacker.ability) || [:NOGUARD, :HOTSHOT].include?(@opponent.ability) || (@attacker.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)

    miniscore *= (1 - 0.05 * @attacker.stages[PBStats::ACCURACY]) if @attacker.stages[PBStats::ACCURACY] < 0
    miniscore *= (1 + 0.05 * @opponent.stages[PBStats::EVASION]) if @opponent.stages[PBStats::EVASION] > 0
    miniscore *= 1.2 if (@mondata.oppitemworks && @opponent.item == :LAXINCENSE) || (@mondata.oppitemworks && @opponent.item == :BRIGHTPOWDER)
    miniscore *= 1.3 if accuracyWeatherAbilityActive?(@opponent, @attacker)
    # miniscore*=3 if opponent.vanished && pbAIfaster?()
    return miniscore
  end

  def lockoncode
    return 0 if @attacker.effects[:LockOnTarget] == @opponent.index || @attacker.ability == :NOGUARD || @opponent.ability == :NOGUARD || (@attacker.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
    return 0 if @opponent.effects[:Substitute] > 0

    miniscore = 1.0
    miniscore *= 3 if @attacker.pbHasMove?(:INFERNO, :ZAPCANNON, :DYNAMICPUNCH)
    miniscore *= 10 if @attacker.pbHasMove?(:GUILLOTINE, :SHEERCOLD, :GUILLOTINE, :FISSURE, :HORNDRILL)
    ministat = (@attacker.stages[PBStats::ACCURACY] < 0) ? @attacker.stages[PBStats::ACCURACY] : 0
    miniscore *= 1 + 0.1 * ministat
    miniscore *= 1 + 0.1 * @opponent.stages[PBStats::EVASION]
    return miniscore
  end

  def forecode5me # after doing hundreds of these this is how i survive
    return 0 if @opponent.effects[:Foresight]

    ministat = (@opponent.stages[PBStats::EVASION] > 0) ? @opponent.stages[PBStats::EVASION] : 0
    miniscore = 1 + 0.1 * ministat
    if @opponent.hasType?(:GHOST)
      miniscore *= 1.5
      miniscore *= 5 if ![:SCRAPPY, :MINDSEYE].include?(@attacker.ability) && @attacker.moves.any? { |moveloop| moveloop && moveloop.pbIsDamaging? && [:NORMAL, :FIGHTING].include?(moveloop.pbType(@attacker)) }
    end
    return miniscore
  end

  def miracode
    return 0 if @opponent.effects[:MiracleEye]

    ministat = @opponent.stages[PBStats::EVASION] > 0 ? @opponent.stages[PBStats::EVASION] : 0
    miniscore = 1 + 0.1 * ministat
    if @opponent.hasType?(:DARK)
      miniscore *= 1.1
      miniscore *= 2 if !@attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbIsDamaging? && moveloop.pbType(@attacker) != :PSYCHIC }
    end
    return miniscore
  end

  def chipcode
    ministat = 0
    ministat += @opponent.stages[PBStats::EVASION] if @opponent.stages[PBStats::EVASION] > 0
    ministat += @opponent.stages[PBStats::DEFENSE] if @opponent.stages[PBStats::DEFENSE] > 0
    ministat += @opponent.stages[PBStats::SPDEF]   if @opponent.stages[PBStats::SPDEF] > 0
    miniscore = 1 + 0.05 * ministat
    return miniscore
  end

  def protectcode
    miniscore = 0.6
    if [:UNSEENFIST, :PIERCINGDRILL].include?(@opponent.ability)
      Gen < Champs ? (return 0) : (miniscore *= @attacker.hp / @attacker.totalhp.to_f)
      # Less value in using Protect at lower HP when the abilities deal 25% of full damage
    end

    miniscore *= 1.3 if @battle.state.effects[:TrickRoom] > 0 && !pbAIfaster?()
    miniscore *= 1.3 if @battle.field.duration > 0 && getFieldDisruptScore(@attacker, @opponent) > 1.0
    miniscore *= 1.3 if @attacker.pbOpposingSide.screenActive?
    miniscore *= 1.2 if @attacker.pbOpposingSide.effects[:Tailwind] > 0
    miniscore *= 0.3 if checkAImoves(PBStuff::SETUPMOVE)
    if ((@attacker.ability == :SPEEDBOOST && @battle.state.effects[:TrickRoom] == 0)  || (@attacker.ability == :GUTS && @attacker.status == nil && @mondata.attitemworks && [:FLAMEORB, :TOXICORB].include?(@attacker.item))) && !pbAIfaster?() && @attacker.effects[:ProtectRate] == 0
      miniscore *= 8
      # experimental -- cancels out drop if killing moves
      if @initial_scores.length > 0
        miniscore *= 6 if hasgreatmoves()
      end
      # end experimental
    end

    miniscore *= 4 if @attacker.ability == :SLOWSTART && @attacker.effects[:SlowStart] < 5 && @battle.FE != :DEEPEARTH
    miniscore *= 6 if @attacker.ability == :LIFEBLOOD && @attacker.effects[:ProtectRate] == 0
    miniscore *= (1.2 * hpGainPerTurn) if hpGainPerTurn > 1
    miniscore *= 0.1 if (hpGainPerTurn - 1) * @attacker.totalhp - @attacker.hp < 0 && (hpGainPerTurn(@opponent) - 1) * @opponent.totalhp - @opponent.hp > 0
    currentJurisdiction = @battle.currentJurisdiction?
    if currentJurisdiction == :NEVED && @attacker.effects[:ProtectRate] == 0 && ![:MAGICGUARD, :BULLETPROOF].include?(@opponent.ability) && @battle.FE != :UNDERWATER
      endofturnhpchanges = [1/128.0 * (1.5 ** @battle.turncount), 1/4.0].min
      miniscore *= 3 if endofturnhpchanges > 1/64.0
      miniscore *= 3 if endofturnhpchanges > 1/16.0
    end


    if @battle.doublebattle && @attacker.effects[:FollowMe] == true && @attacker.effects[:ProtectRate] == 0
      miniscore *= 4
      # experimental -- cancels out drop if killing moves
      if @initial_scores.length > 0
        miniscore *= 6 if hasgreatmoves()
      end
    end

    if (@opponent.status == :POISON || @opponent.status == :BURN) && @opponent.crested != :SUICUNE
      miniscore *= 1.2
      miniscore *= 1.3 if @opponent.effects[:Toxic] > 0
    end
    if (@attacker.status == :POISON || @attacker.status == :BURN) && @attacker.crested != :SUICUNE
      miniscore *= 0.7
      miniscore *= 0.3 if @attacker.effects[:Toxic] > 1
    end
    miniscore *= 1.3 if @opponent.effects[:LeechSeed] >= 0
    miniscore *= 4 if @opponent.effects[:Yawn] > 0

    miniscore *= saltCureGood? ? 1.3 : 1.2 if @opponent.effects[:SaltCure]
    miniscore *= saltCureGood? ? 0.7 : 0.8 if @attacker.effects[:SaltCure]
    miniscore *= 4 if @opponent.effects[:PerishSong] != 0
    if PBStuff::TRAPPINGABILITIESAI.include?(@attacker.ability) || (@attacker.ability == :MAGNETPULL && @opponent.hasType?(:STEEL)) || @opponent.effects[:MeanLook] >= 0 || @opponent.pbNonActivePokemonCount == 0
      miniscore *= 4 if @opponent.effects[:PerishSong] == 3
      miniscore *= 8 if @opponent.effects[:PerishSong] == 1
    end
    if @opponent.effects[:FutureSight] == 1
      miniscore *= 4
      if [:STARLIGHT, :NEWWORLD].include?(@battle.FE)
        miniscore *= 4
      end
    end
    miniscore *= 0.3 if (@opponent.status == :SLEEP || @opponent.status == :FROZEN) && @opponent.crested != :SUICUNE
    if @opponent.vanished
      miniscore *= 12
      miniscore *= 1.5 if !pbAIfaster?()
    end
    protectEffect = PBStuff::PROTECTEFFECTS[@move.move]
    miniscore *= 0.2 if getAIMemory(@opponent, change: true).any? { |move| !protectEffectWorks?(protectEffect, move, @opponent) && (move.pbIsDamaging? || isUsefulStatusMove?(move, @opponent, @attacker)) }
    if @attacker.effects[:Wish] > 0
      miniscore *= checkAIdamage() >= @attacker.hp ? 15 : 2
    end
    miniscore /= (@attacker.effects[:ProtectRate] * 2.0) if @attacker.effects[:ProtectRate] > 0
    miniscore *= 0.7 if @attacker.effects[:ProtectRate] > 0 && @battle.doublebattle
    miniscore *= 8 if @attacker.effects[:GlaiveRush]
    return miniscore
  end

  def protecteffectcode
    return 0 if seedProtection?(@attacker)

    miniscore = protectcode
    miniscore *= 1.5 if @opponent.turncount == 0
    miniscore *= 1.3 if getAIMemory().any? { |moveloop| moveloop != nil && @opponent.makesContact?(moveloop) }
    return miniscore
  end

  def feintcode
    return 1 if !checkAImoves(PBStuff::PROTECTMOVE)

    miniscore = 1.1
    miniscore *= 1.2 if @opponent.effects[:ProtectRate] < 1
    return miniscore
  end

  def mirrorcode(copycat = false)
    lastmove = copycat ? @battle.lastMoveUsed : @opponent.lastMoveUsed
    return 0 if !lastmove.is_a?(Symbol)
    mirrmove = moveToMoveObject(lastmove, @attacker)
    return 0 if !mirrmove.canMirror?

    miniscore = [pbRoughDamage(mirrmove) / @opponent.hp.to_f, 100].min
    # score = pbGetMoveScore(mirrmove,@attacker,@opponent,@mondata.skill,rough)
    miniscore *= 0.5 if !pbAIfaster?() && @attacker.ability != :PRANKSTER
    return miniscore
  end

  def yousecondcode
    return 0 if !pbAIfaster?(@move)

    miniscore = 1.0
    miniscore *= checkAImoves(PBStuff::SETUPMOVE) ? 0.8 : 1.5
    if checkAIpriority()
      miniscore *= 0.6
    else
      miniscore *= 1.5
    end
    miniscore *= (100 * pbRoughDamage(checkAIbestMove()) / @opponent.hp) > @initial_scores.max ? 2.7 : 0.5 if @opponent.hp > 0 && @initial_scores.length > 0
    return miniscore
  end

  def coatcode
    miniscore = 1.0
    if @attacker.lastMoveUsed == :MAGICCOAT
      miniscore *= 0.5
    else
      miniscore *= 1.5 if @attacker.hp == @attacker.totalhp
      miniscore *= 3 if getAIMemory().length > 0 && getAIMemory().none? { |moveloop| moveloop != nil && moveloop.pbIsDamaging? }
    end
    return miniscore
  end

  def snatchcode
    miniscore = 1.0
    if @attacker.lastMoveUsed == :SNATCH
      miniscore *= 0.5
    else
      miniscore *= 1.5 if @opponent.hp == @opponent.totalhp
      miniscore *= 2 if checkAImoves(PBStuff::SETUPMOVE)
      if @opponent.attack > @opponent.spatk
        miniscore *= (@attacker.attack > @attacker.spatk) ? 1.5 : 0.7
      else
        miniscore *= (@attacker.spatk > @attacker.attack) ? 1.5 : 0.7
      end
      if @battle.FE == :BACKALLEY
        subscore = selfstatboost([2, 0, 0, 0, 0, 0, 0]) + selfstatboost([0, 2, 0, 0, 0, 0, 0]) + selfstatboost([0, 0, 2, 0, 0, 0, 0]) + selfstatboost([0, 0, 0, 2, 0, 0, 0]) + selfstatboost([0, 0, 0, 0, 2, 0, 0])
        subscore /= 5
        miniscore *= subscore
      end
    end
    return miniscore
  end

  def quickguardcode
    return 0 if aiCheckSideAbility(@battle.priorityBlockingAbilities, @attacker, @opponent, @attacker, nil, true, checkMoldBroken: true).any?

    count = getAIMemory(@opponent, change: true).count { |move| protectEffectWorks?(:QuickGuard, move, @opponent) && (move.pbIsDamaging? || isUsefulStatusMove?(move, @opponent, @attacker)) }
    specialconditions = (@battle.FE == :CHESS && @opponent.piece == :KING) || @opponent.galeWingsActive? || (@opponent.ability == :PRANKSTER && (!@attacker.hasType?(:DARK) || @battle.FE == :BEWITCHED))
    return 0 if count == 0 && !specialconditions

    miniscore = specialprotectcode()
    miniscore *= specialconditions ? 4 : count
    return miniscore
  end

  def wideguardcode
    count = getAIMemory(@opponent, change: true).count { |move| protectEffectWorks?(:WideGuard, move, @opponent) && (move.pbIsDamaging? || isUsefulStatusMove?(move, @opponent, @attacker)) }
    return 0 if count == 0 && !(@battle.doublebattle && @attacker.pbPartner.hp > 0 && @attacker.effects[:FollowMe]) # rejuv specific scenario
    if (@battle.doublebattle && @attacker.pbPartner.hp > 0 && @attacker.effects[:FollowMe])
      count = 1 if count == 0
    end
    miniscore = specialprotectcode()
    miniscore *= count
    miniscore *= 2 if @battle.FE == :CORROSIVEMIST && checkAImoves([:HEATWAVE, :LAVAPLUME, :ERUPTION, :MINDBLOWN, :SEARINGSHOT, :SELFDESTRUCT, :EXPLOSION])
    miniscore *= 2 if @battle.FE == :CORRUPTED && checkAImoves([:HEATWAVE, :LAVAPLUME, :ERUPTION])
    miniscore *= 2 if @battle.FE == :CAVE && checkAImoves([:MAGNITUDE, :EARTHQUAKE, :BULLDOZE])
    miniscore *= 2 if @battle.FE == :MIRROR && checkAImoves([:MAGNITUDE, :EARTHQUAKE, :BULLDOZE, :HYPERVOICE, :BOOMBURST, :SELFDESTRUCT, :EXPLOSION])
    miniscore *= 5 if @battle.doublebattle && @attacker.pbPartner.hp > 0 && @attacker.effects[:FollowMe]
    return miniscore
  end

  def specialprotectcode
    miniscore = 1.0
    if [:UNSEENFIST, :PIERCINGDRILL].include?(@opponent.ability)
      Gen < Champs ? (return 0) : (miniscore *= @attacker.hp / @attacker.totalhp.to_f)
      # Less value in using Protect at lower HP when the abilities deal 25% of full damage
    end

    miniscore *= 2 if @attacker.pbPartner.hp > 0
    miniscore *= 0.3 if checkAIdamage() > @attacker.hp || checkAImoves(PBStuff::SETUPMOVE)
    if @attacker.effects[:Wish] > 0
      miniscore *= 2 if checkAIdamage() > @attacker.hp || (@attacker.pbPartner.hp * (1.0 / @attacker.pbPartner.totalhp)) < 0.25
    end
    return miniscore
  end

  def sleeptalkcode(initialscores = [])
    return 0 unless @attacker.ability == :COMATOSE || (@attacker.status == :SLEEP && @attacker.statusCount > 1 && @attacker.crested != :SUICUNE)
    # When scoring Sleep Talk, we allow the AI to know exactly when the attacker is going to wake up (even when not using Rest)

    return 5 unless @attacker.pbHasMove?(:SNORE, :FEVERPITCH)

    snorescores, otherscores = [], []
    for i in 0...@attacker.moves.length
      currentid = @attacker.moves[i].move
      next if currentid == :SLEEPTALK

      score = initialscores[i]
      [:SNORE, :FEVERPITCH].include?(currentid) ? snorescores.push(score) : otherscores.push(score)
    end
    maxsnorescore = snorescores.max || 0
    avgotherscore = otherscores.empty? ? 0 : (otherscores.sum.to_f / otherscores.length)
    return maxsnorescore >= avgotherscore ? 0.1 : 5
  end

  def metronomecode(scorethreshold)
    return 0 if @attacker.pbNonActivePokemonCount > 0 && !(@move.move == :METRONOME && @battle.FE == :GLITCH)

    return @initial_scores.any? { |scores| scores > scorethreshold } ? 0.5 : 1.5
  end

  def tormentcode
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.effects[:Torment] || aiCheckSideAbility(:AROMAVEIL, @opponent, checkMoldBroken: true).any?

    lastmove = @opponent.lastMoveUsed.is_a?(Symbol) ? moveToMoveObject(@opponent.lastMoveUsed, @opponent) : nil
    miniscore = 1.0
    miniscore *= pbAIfaster?(@move) ? 1.2 : 0.7
    if lastmove&.pbIsDamaging?
      miniscore *= 1.5
      bestmove, maxdam = checkAIMovePlusDamage()
      if lastmove && bestmove.move == lastmove.move
        miniscore *= 1.3
        miniscore *= 1.5 if maxdam * 3 < @attacker.totalhp
      end
      miniscore *= 1.5 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::PROTECTMOVE.include?(moveloop.move) } && ![:UNSEENFIST, :PIERCINGDRILL].include?(@opponent.ability)
      miniscore *= 1.3 if hpGainPerTurn > 1
    else
      miniscore *= 0.5
    end
    return miniscore
  end

  def imprisoncode
    return 0 if @opponent.effects[:Imprison]

    miniscore = 1.0
    subscore = 1
    ourmoves = Array.new(@attacker.moves.length)
    for i in 0...@attacker.moves.length
      ourmoves[i] = @attacker.moves[i].move
    end
    miniscore *= 1.3 if ourmoves.include?(@opponent.lastMoveUsed)
    for j in getAIMemory()
      if ourmoves.include?(j.move)
        subscore += 1
        miniscore *= 1.5 if j.isHealingMove?
      else
        miniscore *= 0.7
      end
    end
    miniscore *= subscore
    return miniscore
  end

  def disablecode
    return 0 if @opponent.effects[:Disable] > 0 || aiCheckSideAbility(:AROMAVEIL, @opponent, checkMoldBroken: true).any?

    lastmove = @opponent.lastMoveUsed.is_a?(Symbol) ? moveToMoveObject(@opponent.lastMoveUsed, @opponent) : nil
    return 0 if !lastmove && pbAIfaster?(@move, nil)

    miniscore = 1.0
    miniscore *= lastmove && pbAIfaster?(@move, lastmove) ? 1.2 : 0.7
    if lastmove && (lastmove.pbIsDamaging? || lastmove.isHealingMove?)
      miniscore *= 1.5
      bestmove, maxdam = checkAIMovePlusDamage()
      if bestmove.move == lastmove.move
        miniscore *= 1.3
        miniscore *= 1.5 if maxdam * 3 < @attacker.totalhp && opponent.pbPartner.hp <= 0
        miniscore *= 1.5 if maxdam * 3 > @attacker.totalhp && opponent.pbPartner.hp > 0
      end
    else
      miniscore *= 0.5
    end
    return miniscore
  end

  def tauntcode
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.effects[:Taunt] > 0 || (@opponent.ability == :OBLIVIOUS && !moldBreakerCheck(@attacker, @opponent, @move)) || aiCheckSideAbility(:AROMAVEIL, @opponent, checkMoldBroken: true).any?

    lastmove = @opponent.lastMoveUsed.is_a?(Symbol) ? moveToMoveObject(@opponent.lastMoveUsed, @opponent) : nil
    miniscore = 0.8
    miniscore *= lastmove && pbAIfaster?(@move, lastmove) ? 1.5 : 0.7
    if pbGetMonRoles(@opponent).include?(:LEAD)
      miniscore *= 1.2
    else
      miniscore *= 0.8
    end
    miniscore *= @opponent.turncount <= 1 ? 1.1 : 0.9
    miniscore *= 1.3 if lastmove&.isHealingMove?
    miniscore *= 0.6 if @battle.doublebattle
    return miniscore
  end

  def healblockcode
    return @move.pbIsDamaging? ? 1 : 0 if !opponent.canHeal? || aiCheckSideAbility(:AROMAVEIL, @opponent, checkMoldBroken: true).any?

    miniscore = 1.0
    miniscore *= @move.pbIsDamaging? ? 1.2 : 1.5 if pbAIfaster?(@move)
    miniscore *= @move.pbIsDamaging? ? 1.5 : 2.5 if checkAIhealing() || checkAIdraining()
    miniscore *= @move.pbIsDamaging? ? (hpGainPerTurn(@opponent) * 1.3) : (hpGainPerTurn(@opponent) * 4)

    return miniscore
  end

  def encorecode
    return 0 if @opponent.effects[:Encore] > 0 || aiCheckSideAbility(:AROMAVEIL, @opponent, checkMoldBroken: true).any?
    return 0 if !@opponent.lastMoveUsed.is_a?(Symbol) && pbAIfaster?(@move) && @opponent.ability != :PRANKSTER
    return 0 if lockedIntoAMove?(@opponent)
    return 0.2 if !@opponent.lastMoveUsed.is_a?(Symbol)

    lastmove = moveToMoveObject(@opponent.lastMoveUsed, @opponent)
    lastmove2 = @opponent.moves.find { |move| move.move == @opponent.lastMoveUsed }

    return 0 if lastmove2&.pp == 0 && pbAIfaster?(@move) && @opponent.ability != :PRANKSTER

    miniscore = 1.0
    miniscore *= 1.5 if [:BIGTOP, *PBFields::CONCERT].include?(@battle.FE)
    miniscore *= pbAIfaster?(@move, lastmove) || lastmove.pbIsStatus? ? 2.0 : 0.2
    miniscore *= 0.3 if pbRoughDamage(lastmove, @opponent, @attacker) > @attacker.hp
    if pbRoughDamage(lastmove, @opponent, @attacker) * 4 > @attacker.hp
      miniscore *= 0.3
    elsif @opponent.stages[PBStats::SPEED] > 0
      if @opponent.hasType?(:DARK) || @attacker.ability != :PRANKSTER || @opponent.ability == :SPEEDBOOST
        miniscore *= 0.5
      else
        miniscore *= 2
      end
    else
      miniscore *= 2
    end
    return miniscore
  end

  def multihitcode
    miniscore = 1.0
    if @attacker.makesContact?(@move) && !(@mondata.attitemworks && @attacker.item == :PROTECTIVEPADS)
      miniscore *= 0.7 if (@mondata.oppitemworks && @opponent.item == :ROCKYHELMET) || @opponent.ability == :IRONBARBS || @opponent.ability == :ROUGHSKIN
    end
    miniscore *= 1.3 if notOHKO?(@attacker, @opponent, true, ignoreMultiHit: true) # we don't want notOHKO? to return false because of us having multi hit moves here
    miniscore *= 1.3 if @opponent.effects[:Substitute] > 0
    miniscore *= 1.3 if @attacker.itemWorks? && (@attacker.item == :RAZORFANG || @attacker.item == :KINGSROCK)
    return miniscore
  end

  def beatupcode(score) # only partner else multihit is used
    return 0 if @attacker.pbBeatUpParty.empty?
    return 0 if @opponent.ability != :JUSTIFIED || @opponent.stages[PBStats::ATTACK] > 3 || getAIMemory().none? { |moveloop| !moveloop.nil? && moveloop.pbIsPhysical?(@opponent) } || score >= 100

    score = 100 - score
    if pbAIfaster?(nil, nil, @opponent, @attacker.pbOpposing1) && pbAIfaster?(nil, nil, @opponent, @attacker.pbOpposing2)
      score *= 1.3
    else
      score *= 0.7
    end
    score *= 1 + (0.05 * [@attacker.pbBeatUpParty.length, 6 - @opponent.stages[PBStats::ATTACK]].min)
    return score
  end

  def hypercode()
    return 2 if !@battle.doublebattle && (!@battle.opponent.nil? && @battle.opponent.trainertype == :ZEL) && @attacker.index.odd?

    miniscore = 1.0
    miniscore *= 1.3 if @initial_scores[@score_index] >= 110 && @battle.FE == :GLITCH
    if @initial_scores[@score_index] < 100

      miniscore *= 0.5
      miniscore *= 0.5 if checkAIhealing()
    end
    return miniscore if @battle.FE == :GLITCH # Glitch Field

    if @initial_scores.length > 0
      miniscore *= 0.3 if hasgreatmoves()
    end

    yourpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))
    theirpartycount = @battle.pbPokemonCount(@battle.pbCombinedParty(@opponent.index))
    if theirpartycount > 1
      miniscore *= (10 - theirpartycount) * 0.1
    else
      miniscore *= 1.1
    end
    miniscore *= 0.5 if @battle.doublebattle
    miniscore *= 0.7 if theirpartycount > 1 && yourpartycount == 1

    return miniscore
  end

  def weaselslashcode
    miniscore = 1.0
    if @attacker.item == :POWERHERB
      miniscore = 1.2 if !hasgreatmoves() && @move.move != :GEOMANCY
      miniscore = 1.8 if @attacker.ability == :UNBURDEN
      return miniscore
    end
    if checkAIdamage() > @attacker.hp
      miniscore *= 0.1
    elsif (checkAIdamage() * 2) > @attacker.hp
      if !pbAIfaster?(@move)
        miniscore *= 0.1
      else
        miniscore *= 0.7
      end
    end
    miniscore *= 0.6 if @attacker.hp / @attacker.totalhp.to_f < 0.5
    if moveInvulMisses?()
      miniscore *= pbAIfaster?(@move) ? 2 : 0.5
    end
    miniscore *= 0.1 if @initial_scores.any? { |score| score > 100 }
    miniscore *= 0.5 if @battle.doublebattle
    if @move.pbIsDamaging?
      miniscore *= 0.1 if checkAImoves(PBStuff::PROTECTMOVE) && !@move.unseenFistCheck(@attacker)
      miniscore *= 0.7 if @initial_scores[@score_index] < 100
    elsif miniscore *= 0.4 # probably geomancy
    end
    return miniscore
  end

  def twoturncode
    miniscore = 1.0
    if @attacker.item == :POWERHERB
      miniscore = 1.2
      miniscore = 1.8 if @attacker.ability == :UNBURDEN
      return miniscore
    end
    if ((@opponent.status == :POISON || @opponent.status == :BURN) && @opponent.crested != :SUICUNE) || @opponent.effects[:LeechSeed] >= 0 || @opponent.effects[:MultiTurn] > 0 || @opponent.effects[:Curse] || @opponent.effects[:SaltCure]
      miniscore *= 1.2
    else
      miniscore *= 0.8 if @battle.pbPokemonCount(@battle.pbPartySingleOwner(@opponent.index)) > 1
    end
    miniscore *= 0.5 if !@attacker.status.nil? || @attacker.effects[:Curse] || @attacker.effects[:SaltCure] || @attacker.effects[:Attract] > -1 || @attacker.effects[:Confusion] > 0
    miniscore *= hpGainPerTurn()
    miniscore *= 0.7 if @attacker.pbOwnSide.screenActive? || @attacker.pbOwnSide.effects[:Tailwind] > 0
    miniscore *= 1.3 if @opponent.effects[:PerishSong] != 0 && @attacker.effects[:PerishSong] == 0
    if pbAIfaster?()
      miniscore *= 3 if @opponent.vanished
      miniscore *= 1.1
    else
      miniscore *= 0.8
      miniscore *= 0.5 if checkAIhealing()
      miniscore *= 0.7 if checkAIaccuracy()
    end
    return miniscore
  end

  def cooldownmovecode # Blood Moon, Gigaton Hammer
    miniscore = 1.0
    miniscore *= 0.7 if @opponent.effects[:Substitute] > 0
    miniscore *= 0.8 if checkAImoves(PBStuff::PROTECTMOVE) && !@move.unseenFistCheck(@attacker) && @opponent.effects[:ProtectRate] < 1
    miniscore *= 0.9 if checkAImoves([:SUBSTITUTE]) && (!pbAIfaster?(@move) || @opponent.ability == :PRANKSTER)
    miniscore *= 0.8 if checkAImoves(PBStuff::SEMIINVULMOVE) && !pbAIfaster?(@move)
    return miniscore
  end

  def firespincode()
    return @move.pbIsDamaging? ? 1 : 0 if @initial_scores[@score_index] >= 110 || @opponent.effects[:MultiTurn] != 0 || @opponent.effects[:Substitute] > 0

    miniscore = 1.0
    miniscore *= 1.2
    if @initial_scores.length > 0
      miniscore *= 1.2 if hasbadmoves(30)
    end
    if @opponent.totalhp == @opponent.hp
      miniscore *= 1.2
    elsif @opponent.hp * 2 < @opponent.totalhp
      miniscore *= 0.8
    end
    miniscore *= 1 - 0.05 * statchangecounter(@opponent, 1, 7, 1)
    if checkAIdamage() > @attacker.hp
      miniscore *= 0.7
    elsif @attacker.hp * 3 < @attacker.totalhp
      miniscore *= 0.7
    end
    miniscore *= 1.5 if @opponent.effects[:LeechSeed] >= 0
    miniscore *= 1.3 if @opponent.effects[:Attract] > -1
    miniscore *= 1.3 if @opponent.effects[:Confusion] > 0
    miniscore *= 1.2 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
    miniscore *= 1.1 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::PROTECTMOVE.include?(moveloop.move) } && ![:UNSEENFIST, :PIERCINGDRILL].include?(@opponent.ability)
    miniscore *= 1.3 if @mondata.attitemworks && @attacker.item == :BINDINGBAND
    miniscore *= 1.1 if @mondata.attitemworks && @attacker.item == :GRIPCLAW
    return miniscore
  end

  def uproarcode
    miniscore = 1.0
    miniscore *= 0.7 if @opponent.status == :SLEEP && @opponent.crested != :SUICUNE
    miniscore *= 1.8 if checkAImoves([:REST])
    miniscore *= 1.1 if @opponent.pbNonActivePokemonCount == 0 || PBStuff::TRAPPINGABILITIESAI.include?(@attacker.ability) || (@attacker.ability == :MAGNETPULL && @opponent.hasType?(:STEEL)) || @opponent.effects[:MeanLook] >= 0
    miniscore *= 0.7 if @move.pbTypeModifier(@move.pbType(@attacker), @attacker, @opponent).resistedOrImmune?
    miniscore *= 0.75 if @attacker.hp / @attacker.totalhp < 0.75
    miniscore *= 1 + 0.05 * @attacker.stages[PBStats::SPATK] if @attacker.stages[PBStats::SPATK] < 0
    return miniscore
  end

  def recovercode(amount, ignoreHealBlock = false)
    return 0 if @attacker.effects[:HealBlock] > 0 && !ignoreHealBlock
    return 0 if @attacker.effects[:Wish] > 0
    return 0 if @attacker.status == :PETRIFIED && !aiCheckSideAbility(:FAIRYAURA, @attacker, @attacker, @opponent, excludeSelf: true) && @attacker.crested != :SUICUNE

    miniscore = 1.0
    amount *= 0.67 if @mondata.skill >= BESTSKILL && @battle.FE == :BACKALLEY
    recoverhp = [@attacker.hp + amount, @attacker.totalhp].min # the amount of hp we expect to have after recover
    if @mondata.skill >= BESTSKILL
      bestmove, maxdam = checkAIMovePlusDamage()
      miniscore *= 0.2 if maxdam > amount # we take more damage than we heal
      miniscore *= 0.6 if maxdam > 1.4 * amount && [0x1C, 0x20].include?(bestmove.function)
      if maxdam > @attacker.hp
        if maxdam > recoverhp # if we expect to die after healing, don't bother
          return 0
        else # if we're not going to die, we really want to recover
          miniscore *= 5
          if @initial_scores.length > 0 && amount > maxdam
            miniscore *= 6 if hasgreatmoves() # offset killing moves
          end
        end
      else # if we're not going to die
        miniscore *= 2 if maxdam * 1.5 > @attacker.hp # if a second attack would kill us next turn,
        if !pbAIfaster?(@move) # and we're slower,  then heal pre-emptively
          if maxdam * 2 > @attacker.hp
            miniscore *= 5
            if @initial_scores.length > 0 && amount > maxdam
              miniscore *= 6 if hasgreatmoves() # offset killing moves
            end
          end
        end
      end
    elsif @mondata.skill >= MEDIUMSKILL
      miniscore *= 3 if checkAIdamage() > @attacker.hp
    end
    yourpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))
    theirpartycount = @battle.pbPokemonCount(@battle.pbCombinedParty(@opponent.index))
    miniscore *= 1.1 if yourpartycount == 1
    miniscore *= 0.3 if theirpartycount == 1 && hasgreatmoves()
    miniscore *= 0.7 if checkAImoves(PBStuff::SETUPMOVE)
    if @attacker.hp.to_f / @attacker.totalhp < 0.5
      miniscore *= 1.5
      miniscore *= 2 if @attacker.effects[:Curse]
      miniscore *= saltCureGood? ? 2 : 1.5 if @attacker.effects[:SaltCure]
      if @attacker.hp * 4 < @attacker.totalhp
        miniscore *= 1.5 if @attacker.status == :POISON && @attacker.crested != :SUICUNE
        miniscore *= 2 if @attacker.effects[:LeechSeed] >= 0
        if @attacker.hp < @attacker.totalhp * 0.13
          miniscore *= 2 if @attacker.status == :BURN && @attacker.crested != :SUICUNE
          miniscore *= 2 if @attacker.takesWeatherDamage?
        end
      end
    else
      miniscore *= 0.9
    end
    if @attacker.effects[:Toxic] > 0
      miniscore *= 0.5
      miniscore *= 0.5 if @attacker.effects[:Toxic] > 3
    end
    miniscore *= 1.1 if @attacker.status == :PARALYSIS || @attacker.effects[:Attract] >= 0 || @attacker.effects[:Confusion] > 0
    if ((@opponent.status == :POISON || @opponent.status == :BURN) && @opponent.crested != :SUICUNE) || @opponent.effects[:LeechSeed] >= 0 || @opponent.effects[:Curse] || @opponent.effects[:SaltCure]
      miniscore *= 1.3
      miniscore *= 1.3 if @opponent.effects[:Toxic] > 0
    end
    miniscore *= 1.3 if checkAImoves(PBStuff::CONTRARYBAITMOVE)
    miniscore *= 1.2 if @opponent.vanished || @opponent.effects[:HyperBeam] > 0
    return miniscore if move.function == 0xD7 # Wish doesn't do any of the remaining checks

    if (@attacker.hp.to_f / @attacker.totalhp) > 0.8
      miniscore = 0
    elsif (@attacker.hp.to_f / @attacker.totalhp) > 0.6
      miniscore *= 0.6
    elsif (@attacker.hp.to_f / @attacker.totalhp) < 0.25
      miniscore *= 2
    end
    return miniscore
  end

  def wishcode
    hpgain = [(@attacker.totalhp / 2.0).floor, 1].max
    hpgain = [(@attacker.totalhp * 0.75).floor, 1].max if @mondata.skill >= BESTSKILL && [:MISTY, :RAINBOW, :HOLY, :FAIRYTALE, :STARLIGHT].include?(@battle.FE)
    miniscore = recovercode(hpgain)
    maxdam = checkAIdamage()
    recoverhp = [@attacker.hp + hpgain, @attacker.totalhp].min # the amount of hp we expect to have after recover
    if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::PROTECTMOVE.include?(moveloop.move) } && ![:UNSEENFIST, :PIERCINGDRILL].include?(@opponent.ability) # if we have protect
      if maxdam > @attacker.hp && maxdam < recoverhp && !hasgreatmoves() # and we expect to die, and can't kill the opponent, and we can save ourselves
        miniscore *= 4
      else
        miniscore *= 0.6
      end
    else # if we don't have protect, we want to be using wish earlier
      miniscore *= 2 if maxdam * 2 > @attacker.hp && maxdam < @attacker.hp && maxdam * 2 < recoverhp
    end
    if @mondata.roles.include?(:CLERIC)
      miniscore *= 1.1 if @battle.pbPartySingleOwner(@attacker.index).any? { |i| i && i.hp.to_f < 0.6 * i.totalhp && i.hp.to_f > 0.3 * i.totalhp }
    end
    return miniscore
  end

  def restcode
    return 0 if !@attacker.pbCanSleep?(@attacker, @move, ignorestatus: true)
    return 0 if @attacker.hp * (1.0 / @attacker.totalhp) >= 0.8

    miniscore = 1.0
    maxdam = checkAIdamage()
    if maxdam > @attacker.hp && maxdam * 2 < @attacker.totalhp * hpGainPerTurn
      miniscore *= 3
    elsif @mondata.skill >= BESTSKILL && maxdam * 2 < @attacker.totalhp * hpGainPerTurn
      miniscore *= 1.5 if maxdam * 1.5 > @attacker.hp
      miniscore *= 2 if maxdam * 2 > @attacker.hp && !pbAIfaster?()
    end
    miniscore *= @attacker.hp < 0.5 * @attacker.totalhp ? 1.5 : 0.5
    miniscore *= 1.2 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
    if ((@opponent.status == :POISON || @opponent.status == :BURN) && @opponent.crested != :SUICUNE) || @opponent.effects[:LeechSeed] >= 0 || @opponent.effects[:Curse] || @opponent.effects[:SaltCure]
      miniscore *= 1.3
      miniscore *= 1.3 if @opponent.effects[:Toxic] > 0
    end
    if (@attacker.status == :POISON && @attacker.crested != :SUICUNE)
      miniscore *= 1.3
      miniscore *= 1.3 if @opponent.effects[:Toxic] > 0
    end
    if (@attacker.status == :BURN  && @attacker.crested != :SUICUNE)
      miniscore *= 1.3
      miniscore *= 1.5 if @attacker.spatk < @attacker.attack
    end
    miniscore *= 1.3 if @attacker.status == :PARALYSIS && @attacker.crested != :SUICUNE
    miniscore *= 1.3 if checkAImoves(PBStuff::CONTRARYBAITMOVE)
    if !(@attacker.item == :LUMBERRY || @attacker.item == :CHESTOBERRY || @attacker.hydrationActive?)
      miniscore *= 0.8
      if maxdam * 2 > @attacker.totalhp
        miniscore *= 0.4
      elsif maxdam * 3 < @attacker.totalhp
        miniscore *= 1.3
        if @initial_scores.length > 0
          miniscore *= 6 if hasgreatmoves()
        end
      end
      miniscore *= 0.7 if checkAImoves([:WAKEUPSLAP, :NIGHTMARE, :DREAMEATER]) || @opponent.ability == :BADDREAMS
      miniscore *= 1.3 if @attacker.pbHasMove?(:SLEEPTALK)
      miniscore *= 1.2 if @attacker.pbHasMove?(:SNORE, :FEVERPITCH)
      miniscore *= 1.1 if @attacker.ability == :SHEDSKIN || @attacker.ability == :EARLYBIRD
      miniscore *= 0.8 if @battle.doublebattle
    else
      if @attacker.item == :LUMBERRY || @attacker.item == :CHESTOBERRY
        miniscore *= @attacker.ability == :HARVEST ? 1.2 : 0.8
      end
    end
    if @attacker.crested == :BASTIODON
      if @attacker.hp * (1.0 / @attacker.totalhp) >= 0.8
        reflectdamage = maxdam
        reflectdamage = @attacker.hp - 1 if maxdam >= @attacker.hp
        reflectdamage *= 0.5
        if reflectdamage >= @opponent.hp
          miniscore *= 4
          miniscore *= 6 if @initial_scores.length > 0 && hasgreatmoves() # experimental -- cancels out drop if killing moves
        end
      end
    end
    if !@attacker.status.nil?
      miniscore *= 1.4
      miniscore *= 1.2 if @attacker.effects[:Toxic] > 0
    end
    return miniscore
  end

  def aquaringcode
    return 0 if ((@move.function == 0xda || @move.function == 0x187) && @attacker.effects[:AquaRing]) || (@move.function == 0xdb && @attacker.effects[:Ingrain])

    miniscore = 1.0
    attackerHPpercent = @attacker.hp / @attacker.totalhp
    miniscore *= 1.2 if attackerHPpercent > 0.75
    if attackerHPpercent < 0.50
      miniscore *= 0.7
      miniscore *= 0.5 if attackerHPpercent < 0.33
    end
    miniscore *= 1.2 if checkAIhealing() || checkAIdraining()
    miniscore *= 1.2 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::PROTECTMOVE.include?(moveloop.move) } && ![:UNSEENFIST, :PIERCINGDRILL].include?(@opponent.ability)
    miniscore *= 0.8 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::PIVOTMOVE.include?(moveloop.move) }
    if checkAIdamage() * 5 < @attacker.totalhp && (getAIMemory().length > 0)
      miniscore *= 1.2
    elsif checkAIdamage() > @attacker.totalhp * 0.4
      miniscore *= 0.3
    end
    miniscore *= 1.2 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL) || @mondata.roles.include?(:TANK)
    miniscore *= 0.3 if checkAImoves(PBStuff::PHASEMOVE)
    miniscore *= 0.5 if @battle.doublebattle
    return miniscore
  end

  def absorbcode
    return @move.pbIsDamaging? ? 1 : 0 if @attacker.effects[:HealBlock] > 0
    return @move.pbIsDamaging? ? 1 : 0 if @attacker.hp == @attacker.totalhp && pbAIfaster?(@move)
    return @move.pbIsDamaging? ? 1 : 0 if @attacker.status == :PETRIFIED && !aiCheckSideAbility(:FAIRYAURA, @attacker, @attacker, @opponent, excludeSelf: true) && @attacker.crested != :SUICUNE

    hpdrained = getDrainAmount(@attacker, @opponent, @move)
    return [1 - (hpdrained / @attacker.hp.to_f), 0.01].max if @opponent.ability == :LIQUIDOOZE

    if pbAIfaster?(@move)
      hpdrained = @attacker.totalhp - @attacker.hp if hpdrained > (@attacker.totalhp - @attacker.hp)
    else
      maxdam = checkAIdamage()
      hpdrained = @attacker.totalhp - (@attacker.hp - maxdam) if hpdrained > (@attacker.totalhp - (@attacker.hp - maxdam))
    end
    miniscore = hpdrained / @opponent.totalhp.to_f
    miniscore *= 0.5 # arbitrary multiplier to make it value the HP less
    miniscore += 1
    return miniscore
  end

  def healpulsecode(target = @opponent)
    return 0 if target.index != @attacker.pbPartner.index || @attacker.effects[:HealBlock] > 0 || target.effects[:HealBlock] > 0
    return 0 if @attacker.status == :PETRIFIED && !aiCheckSideAbility(:FAIRYAURA, @attacker, @attacker, target, excludeSelf: true) && @attacker.crested != :SUICUNE
    return 0 if target.status == :PETRIFIED && !aiCheckSideAbility(:FAIRYAURA, target, target, @attacker, excludeSelf: true) && target.crested != :SUICUNE

    miniscore = 1.0
    if target.hp > 0.8 * target.totalhp
      if !pbAIfaster?(nil, nil, @attacker, @attacker.pbOpposing1) && !pbAIfaster?(nil, nil, @attacker, @attacker.pbOpposing2)
        miniscore *= 0.5
      else
        return 0
      end
    elsif target.hp < 0.7 * target.totalhp && target.hp > 0.3 * target.totalhp
      miniscore *= 3
    elsif target.hp < 0.3 * target.totalhp
      miniscore *= 1.7
    end
    if ((target.status == :POISON || target.status == :BURN) && target.crested != :SUICUNE) || target.effects[:LeechSeed] >= 0 || target.effects[:Curse] || target.effects[:SaltCure]
      miniscore *= 0.8
      miniscore *= 0.7 if target.effects[:Toxic] > 0
    end
    return miniscore
  end

  def lifedewcode(amount, statusheal)
    miniscore = recovercode(amount)
    miniscore *= [refreshcode(), 1].max if statusheal
    miniscore *= healpulsecode(@attacker.pbPartner) * 0.5
    miniscore *= 1.5 if statusheal && !@attacker.pbPartner.status.nil?
    return miniscore
  end

  def deathcode(recoilOnFail = true)
    miniscore = 1.0
    miniscore *= 0.7
    miniscore *= 0.3 if ((@opponent.effects[:Disguise] || (@opponent.effects[:IceFace] && (@move.pbIsPhysical?(@attacker) || @battle.FE == :FROZENDIMENSION))) && !moldBreakerCheck(@attacker, @opponent, @move)) || @opponent.effects[:Substitute] > 0

    miniscore *= 0.3 if recoilOnFail && checkAImoves(PBStuff::PROTECTMOVE) && !@move.unseenFistCheck(@attacker) && @opponent.effects[:ProtectRate] < 1

    if @attacker.hp == @attacker.totalhp
      miniscore *= 0.2
    else
      miniscore *= 1 - (@attacker.hp.to_f / @attacker.totalhp)
      if @attacker.hp * 4 < @attacker.totalhp
        miniscore *= 1.3
        miniscore *= 1.4 if @mondata.attitemworks && @attacker.item == :CUSTAPBERRY
      end
    end
    miniscore *= 1.2 if @mondata.roles.include?(:LEAD)
    return miniscore
  end

  def gambitcode
    miniscore = 0.7
    miniscore *= pbAIfaster?() ? 1.1 : 0.5
    miniscore *= @attacker.hp > @opponent.hp ? 1.1 : 0.5
    miniscore *= 0.2 if notOHKO?(@attacker, @opponent, true, @move)
    return miniscore
  end

  def mementcode
    miniscore = 1.0
    if @attacker.hp == @attacker.totalhp
      miniscore *= 0.2
    else
      miniscore = 1 - @attacker.hp * (1.0 / @attacker.totalhp)
      miniscore *= 1.3 if @attacker.hp * 4 < @attacker.totalhp
    end
    statarray = [2, 0, 2, 0, 0, 0, 0]
    miniscore *= oppstatdrop(statarray)
    return miniscore
  end

  def grudgecode
    miniscore = 1.0
    damcount = getAIMemory().count { |moveloop| moveloop != nil && moveloop.pbIsDamaging? }
    miniscore *= 3 if getAIMemory().length >= 4 && damcount == 1
    if @attacker.hp == @attacker.totalhp
      miniscore *= 0.2
    else
      miniscore *= 1 - (@attacker.hp / @attacker.totalhp)
      if @attacker.hp * 4 < @attacker.totalhp
        miniscore *= 1.3
        miniscore *= 1.4 if @mondata.attitemworks && @attacker.item == :CUSTAPBERRY
      end
    end
    miniscore *= pbAIfaster?(@move) ? 1.3 : 0.5
    return miniscore
  end

  def healwishcode
    count = 0
    yourpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))
    return 0 if yourpartycount == 1
    for mon in @battle.pbPartySingleOwner(@attacker.index)
      next if mon.nil?

      count += 1 if mon.hp != mon.totalhp
    end
    count -= 1 if @attacker.hp != @attacker.totalhp
    return 0 if count == 0

    maxscore = 0
    for mon in @battle.pbPartySingleOwner(@attacker.index)
      next if mon.nil?

      if mon.hp != mon.totalhp
        miniscore = 1 - mon.hp * (1.0 / mon.totalhp)
        miniscore *= 2 if !mon.status.nil?
        maxscore = miniscore if miniscore > maxscore
      end
    end
    miniscore = maxscore
    if @attacker.hp == @attacker.totalhp
      miniscore *= 0.2
    else
      miniscore *= 1 - (@attacker.hp / @attacker.totalhp)
      if @attacker.hp * 4 < @attacker.totalhp
        miniscore *= 1.3
        miniscore *= 1.4 if @mondata.attitemworks && @attacker.item == :CUSTAPBERRY
      end
    end
    miniscore *= pbAIfaster?(@move) ? 1.1 : 0.5
    return miniscore
  end

  def revivalcode
    miniscore = 1.0
    count = 0
    for mon in @battle.pbPartySingleOwner(@attacker.index)
      next if mon.nil?

      count += 1 if mon.hp == 0
    end
    return 0 if count == 0

    for mon in @battle.pbPartySingleOwner(@attacker.index)
      next if mon.nil?

      if mon.hp <= 0
        miniscore +=  0.1 if mon.speed > @opponent.pbSpeed
      end
    end
    if @attacker.hp == @attacker.totalhp
      miniscore *= 0.9
    else
      miniscore *= 1.5 - (@attacker.hp / @attacker.totalhp)
      if @attacker.hp * 4 < @attacker.totalhp
        miniscore *= 1.5
        miniscore *= (@mondata.attitemworks && @attacker.item == :CUSTAPBERRY && !checkAIpriority()) ? 2 : 1.5
      end
    end
    miniscore *= pbAIfaster?(@move) ? 1.5 : 0.8
    return miniscore
  end

  def endurecode
    return 0 if @attacker.hp == 1
    return 0 if notOHKO?(@opponent, @attacker)
    return 0 if @attacker.takesWeatherDamage?
    return 0 if ((@attacker.status == :POISON || @attacker.status == :BURN) && @attacker.crested != :SUICUNE) || @attacker.effects[:LeechSeed] >= 0 || @attacker.effects[:Curse] || @attacker.effects[:SaltCure]
    return 0 if checkAIdamage() < @attacker.hp

    miniscore = 1.0
    miniscore *= pbAIfaster?(nil, nil, @attacker, @opponent.pbPartner) ? 1.3 : 0.5
    if pbAIfaster?(nil, nil, @attacker, @opponent.pbPartner)
      miniscore *= 3 if @attacker.pbHasMove?(:PAINSPLIT, :FLAIL, :REVERSAL)
      miniscore *= 5 if @attacker.pbHasMove?(:ENDEAVOR)
      miniscore *= 5 if @opponent.effects[:TwoTurnAttack] != 0
    end
    miniscore *= 1.5 if ((@opponent.status == :POISON || @opponent.status == :BURN) && @opponent.crested != :SUICUNE) || @opponent.effects[:LeechSeed] >= 0 || @opponent.effects[:Curse] || @opponent.effects[:SaltCure]
    miniscore /= (@attacker.effects[:ProtectRate] * 2.0) if @attacker.effects[:ProtectRate] > 0
    return miniscore
  end

  def destinycode
    return 0 if @attacker.effects[:DestinyRate] && @battle.FE != :HAUNTED

    miniscore = 1.0
    miniscore *= 3 if getAIMemory().length >= 4 && getAIMemory().all? { |moveloop| moveloop != nil && moveloop.pbIsDamaging? }
    miniscore *= 0.1 if @initial_scores.length > 0 && hasgreatmoves()
    miniscore *= pbAIfaster?(@move) ? 1.5 : 0.5
    if @attacker.hp == @attacker.totalhp
      miniscore *= 0.2
    else
      miniscore *= 1 - @attacker.hp * (1.0 / @attacker.totalhp)
      if @attacker.hp * 4 < @attacker.totalhp
        miniscore *= 1.3
        miniscore *= 1.5 if @mondata.attitemworks && @attacker.item == :CUSTAPBERRY
      end
    end
    return miniscore
  end

  def phasecode
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.effects[:Ingrain] || [:SUCTIONCUPS, :GUARDDOG].include?(@opponent.ability) || @opponent.pbNonActivePokemonCount == 0 || @battle.FE == :COLOSSEUM
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.effects[:PerishSong] > 0 || @opponent.effects[:Yawn] > 0

    miniscore = 1.0
    miniscore *= 0.8 if pbAIfaster?()
    miniscore *= 1 + 0.1 * statchangecounter(@opponent, 1, 7)
    miniscore *= 1.3 if @opponent.status == :SLEEP
    miniscore *= 1.3 if @opponent.ability == :SLOWSTART && @battle.FE != :DEEPEARTH
    miniscore *= 1.5 if @opponent.item.nil? && @opponent.unburdened
    miniscore *= 0.7 if @opponent.ability == :INTIMIDATE
    miniscore *= 0.7 if @battle.FE == :MIRROR && @opponent.ability == :ILLUMINATE
    miniscore *= 0.7 if [:DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE) && [:PRESSURE, *PBStuff::UnnerveAbilities].include?(@opponent.ability)
    miniscore *= 0.7 if @battle.FE == :CITY && @opponent.ability == :FRISK
    miniscore *= 0.7 if @opponent.crested == :THIEVUL
    miniscore *= 0.5 if @opponent.ability == :REGENERATOR || @opponent.ability == :NATURALCURE
    miniscore *= 0.7 if [:HOSPITALITY, :SWORNDUTY].include?(@opponent.ability) && @battle.doublebattle
    miniscore *= 1.1 if @opponent.pbOwnSide.effects[:ToxicSpikes] > 0
    miniscore *= 1.4 if @opponent.effects[:Substitute] > 0
    miniscore *= 1.7 if @attacker.issosmon
    legalmoves = @opponent.pokemon.getAllLegalMoves(true)
    miniscore *= 1.4 if legalmoves.any? { |m| m && [:RAGEFIST].include?(m) } && Gen >= Champs
    if @opponent.pbOwnSide.effects[:StealthRock] || @opponent.pbOwnSide.effects[:Spikes] > 0
      miniscore *= 1.3 if (@opponent.pbOwnSide.effects[:StealthRock])
      miniscore *= (1.2**@opponent.pbOwnSide.effects[:Spikes]) if (@opponent.pbOwnSide.effects[:Spikes])
    else
      miniscore *= 0.8
    end
    return miniscore
  end

  def pivotcode
    return 0 if @attacker.pbNonActivePokemonCount == 1 && mustSendOutAceLast?()

    cantswitch = @attacker.pbNonActivePokemonCount == 0
    return @move.pbIsDamaging? || [:PARTINGSHOT, :CHILLYRECEPTION].include?(@move.move) ? 1 : 0 if cantswitch
    return 0 if move.move == :TELEPORT && checkAIdamage() >= @attacker.hp # extra safety

    aifaster = pbAIfaster?(@move)
    miniscore = 1.0
    miniscore *= 0.7 if @attacker.pbOwnSide.effects[:StealthRock]
    miniscore *= 0.6 if @attacker.pbOwnSide.effects[:StickyWeb]
    miniscore *= 0.9**@attacker.pbOwnSide.effects[:Spikes] if @attacker.pbOwnSide.effects[:Spikes] > 0
    miniscore *= 0.9**@attacker.pbOwnSide.effects[:ToxicSpikes] if @attacker.pbOwnSide.effects[:ToxicSpikes] > 0
    miniscore *= 0.7 if @battle.FE == :CORROSIVE

    miniscore *= 1.1 if @attacker.ability == :INTIMIDATE
    miniscore *= 1.1 if @battle.FE == :MIRROR && @attacker.ability == :ILLUMINATE
    miniscore *= 1.1 if [:DIMENSIONAL, :FROZENDIMENSION, :DEUXFINALIS].include?(@battle.FE) && [:PRESSURE, *PBStuff::UnnerveAbilities].include?(@attacker.ability)
    miniscore *= 1.1 if @battle.FE == :CITY && @attacker.ability == :FRISK
    miniscore *= 1.1 if @attacker.crested == :THIEVUL

    if @attacker.ability == :ZEROTOHERO && @attacker.form == 0
      miniscore *= 3
      miniscore *= 3 if aifaster && !hasgreatmoves()
    end
    if @attacker.ability == :REGENERATOR && @attacker.status != :PETRIFIED && @attacker.crested != :SUICUNE
      miniscore *= 1.2 if (@attacker.hp.to_f / @attacker.totalhp) < 0.75 || @move.move == :SHEDTAIL
      miniscore *= 1.2 if (@attacker.hp.to_f / @attacker.totalhp) < 0.5 || @move.move == :SHEDTAIL
    end
    if @mondata.partyroles.any? { |role| role.include?(:SWEEPER) }
      miniscore *= 1.8 if @move.move == :SHEDTAIL
      miniscore *= 5 if @move.move == :BATONPASS && @attacker.crested == :FURRET && @attacker.effects[:Substitute] > 0 && @attacker.index == 1
      miniscore *= 1.5 if @move.move == :PARTINGSHOT
      miniscore *= 1.2 if [:UTURN, :VOLTSWITCH, :FLIPTURN].include?(@move.move) && !aifaster
    end

    movebackup, attackerbackup, oppbackup = @move, @attacker, @opponent
    agent = @move.move == :BATONPASS ? :PivotBaton : :Pivot
    miniscore *= 0.2 if getSwitchInScoresParty(agent, preEmptiveCalc: true).max < 50
    @move, @attacker, @opponent = movebackup, attackerbackup, oppbackup

    if @move.move == :BATONPASS # Baton Pass
      miniscore *= 1 + 0.3 * statchangecounter(@attacker, 1, 7)
      miniscore *= 0 if @attacker.effects[:PerishSong] > 0
      miniscore *= 1.4 if @attacker.effects[:Substitute] > 0
      miniscore *= 0.5 if @attacker.effects[:Confusion] > 0
      miniscore *= 0.5 if @attacker.effects[:LeechSeed] >= 0
      miniscore *= 0.5 if @attacker.effects[:Curse]
      miniscore *= 0.5 if @attacker.effects[:Yawn] > 0
      miniscore *= 0.5 if @attacker.turncount < 1
      miniscore *= 1.3 if !@attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbIsDamaging? }
      miniscore *= 1.2 if @attacker.effects[:Ingrain] || @attacker.effects[:AquaRing]
      if aifaster
        miniscore *= 1.8 if checkAIdamage() > @attacker.hp && getAIMemory().length > 0
      else
        miniscore *= 2 if checkAIdamage() * 2 > @attacker.hp && getAIMemory().length > 0
      end
    else # U-turn / Volt Switch / Flip Turn / Parting Shot / Shed Tail / Chilly Reception / Gen 8 Teleport
      miniscore *= 1 - 0.15 * statchangecounter(@attacker, 1, 7, -1)
      miniscore *= 1 - 0.25 * statchangecounter(@attacker, 1, 7, 1)
      miniscore *= 1.1 if @mondata.roles.include?(:LEAD)
      miniscore *= 1.1 if @mondata.roles.include?(:PIVOT)
      miniscore *= 1.2 if aifaster
      miniscore *= 1.3 if @attacker.effects[:Toxic] > 0 || @attacker.effects[:Attract] > -1 || @attacker.effects[:Confusion] > 0 || @attacker.effects[:Yawn] > 0
      miniscore *= 1.5 if @attacker.effects[:LeechSeed] > -1
      miniscore *= 0.5 if @attacker.effects[:Substitute] > 0
      miniscore *= 1.5 if @attacker.effects[:PerishSong] > 0 || @attacker.effects[:Curse] || @attacker.effects[:SaltCure]
      if aifaster
        opphpbackup = @opponent.hp
        @opponent.hp -= pbRoughDamage()
        can_hard_switch = false
        stats = @opponent.stages
        @opponent.stages = pbPartingShotStatChange(@attacker, @opponent, @move) if @move.move == :PARTINGSHOT
        @battle.pbPartySingleOwner(@attacker.index).each_with_index { |mon, monindex|
          next if mon.nil? || mon.hp <= 0 || mon.isEgg?
          can_hard_switch = true if shouldHardSwitch?(@attacker, monindex, @opponent)
        }
        miniscore *= 0.2 if !can_hard_switch && @opponent.hp > 0
        @opponent.hp = opphpbackup
        @opponent.stages = stats if @move.move == :PARTINGSHOT
      end
    end
    miniscore *= 0.5 if hasgreatmoves()
    if hasbadmoves(25)
      miniscore *= 2
    elsif hasbadmoves(40)
      miniscore *= 1.2
    end
    return miniscore
  end

  def meanlookcode
    miniscore = 1.0
    if @opponent.effects[:MeanLook] >= 0 || @opponent.effects[:Ingrain] ||
       @opponent.hasType?(:GHOST) || @opponent.effects[:Substitute] > 0 ||
       @battle.pbPokemonCount(@battle.pbPartySingleOwner(@opponent.index)) == 1 ||
       (@move.function == 0x156 && secondaryEffectNegated?()) # Spirit Shackle
      return @move.pbIsDamaging? ? miniscore : 0
    end

    miniscore *= 0.1 if checkAImoves(PBStuff::PIVOTMOVE)
    miniscore *= 1.5 if @attacker.pbHasMove?(:PERISHSONG)
    miniscore *= 4   if @opponent.effects[:PerishSong] > 0
    miniscore *= 0   if PBStuff::TRAPPINGABILITIESAI.include?(@attacker.ability) || (@attacker.ability == :MAGNETPULL && @opponent.hasType?(:STEEL))
    miniscore *= 1.3 if @opponent.effects[:Attract] >= 0
    miniscore *= 1.3 if @opponent.effects[:LeechSeed] >= 0
    miniscore *= 1.5 if @opponent.effects[:Curse]
    miniscore *= saltCureGood? ? 1.5 : 1.3 if @opponent.effects[:SaltCure]
    miniscore *= 1.1 if @opponent.effects[:Confusion] > 0
    miniscore *= 0.7 if @attacker.moves.any? { |moveloop| moveloop != nil && (PBStuff::PHASEMOVE).include?(moveloop.move) }
    miniscore *= 1 - 0.05 * statchangecounter(@opponent, 1, 7)
    miniscore = 1.0 if miniscore < 1.0 && @move.pbIsDamaging?
    return miniscore
  end

  def knockcode
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.effects[:Substitute] > 0
    return @move.pbIsDamaging? ? 1 : 0 unless (@opponent.ability != :STICKYHOLD || moldBreakerCheck(@attacker, @opponent, @move)) && @opponent.item && !@battle.pbIsUnlosableItem(@opponent, @opponent.item)

    miniscore = 1.0
    miniscore *= 1.3 if @opponent.item == :LEFTOVERS || (@opponent.item == :BLACKSLUDGE && @opponent.hasType?(:POISON))
    miniscore *= 1.2 if [:LIFEORB, :CHOICESCARF, :CHOICEBAND, :CHOICESPECS, :ASSAULTVEST].include?(@opponent.item)
    if pbIsBerry?(@opponent.item)
      miniscore *= 1.3 if @opponent.ability == :HARVEST
      miniscore *= 1.2 if [:RIPEN, :CUDCHEW].include?(@opponent.ability)
      miniscore *= 1.1 if @opponent.ability == :CHEEKPOUCH
      miniscore *= @attacker.attack > @attacker.spatk ? 1.5 : 1.3 if checkAImoves([:STUFFCHEEKS])
    end
    miniscore *= itemchangedynamicspeedcode(:knockoff)
    return miniscore
  end

  def covetcode
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.ability == :STICKYHOLD && !moldBreakerCheck(@attacker, @opponent, @move)
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.item.nil? || @battle.pbIsUnlosableItem(@opponent, @opponent.item) || (@attacker.item && !([:TRICK, :SWITCHEROO].include?(@move.move)))
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.effects[:Substitute] > 0

    miniscore = 1.2
    case @opponent.item
      when :LEFTOVERS, :LIFEORB, :LUMBERRY, :SITRUSBERRY
        miniscore *= 1.5
      when :ASSAULTVEST, :ROCKYHELMET, :MAGICALSEED, :SYNTHETICSEED, :TELLURICSEED, :ELEMENTALSEED
        miniscore *= 1.3
      when :FOCUSSASH, :MUSCLEBAND, :WISEGLASSES, :EXPERTBELT, :WIDELENS
        miniscore *= 1.2
      when :CHOICESCARF
        miniscore *= 1.1 if !pbAIfaster?()
      when :CHOICEBAND
        miniscore *= 1.1 if @attacker.attack > @attacker.spatk
      when :CHOICESPECS
        miniscore *= 1.1 if @attacker.spatk > @attacker.attack
      when :BLACKSLUDGE
        miniscore *= @attacker.hasType?(:POISON) ? 1.5 : 0.5
      when :TOXICORB, :FLAMEORB, :LAGGINGTAIL, :IRONBALL, :STICKYBARB
        miniscore *= 0.5
    end
    miniscore *= itemchangedynamicspeedcode(:covet)
    return miniscore
  end

  def bestowcode
    return 0 if @opponent.ability == :STICKYHOLD && !moldBreakerCheck(@attacker, @opponent, @move)
    return 0 if @attacker.item.nil? || @battle.pbIsUnlosableItem(@attacker, @attacker.item) || (@opponent.item && !([:TRICK, :SWITCHEROO].include?(@move.move)))
    return 0 if @opponent.effects[:Substitute] > 0

    miniscore = 1.0
    case @attacker.item
      when :LEFTOVERS, :LIFEORB, :LUMBERRY, :SITRUSBERRY
        miniscore *= 0.5
      when :FOCUSSASH, :MUSCLEBAND, :WISEGLASSES, :EXPERTBELT, :WIDELENS
        miniscore *= 0.8
      when :ASSAULTVEST, :ROCKYHELMET, :MAGICALSEED, :SYNTHETICSEED, :TELLURICSEED, :ELEMENTALSEED
        miniscore *= 0.7
      when :CHOICESPECS
        miniscore *= 1.7 if @opponent.attack > @opponent.spatk
        miniscore *= 0.8 if @attacker.attack < @attacker.spatk
      when :CHOICESCARF
        miniscore *= pbAIfaster?() ? 0.9 : 1.5
      when :CHOICEBAND
        miniscore *= 1.7 if @opponent.attack < @opponent.spatk
        miniscore *= 0.8 if @attacker.attack > @attacker.spatk
      when :BLACKSLUDGE
        miniscore *= @attacker.hasType?(:POISON) ? 0.5 : 1.5
        miniscore *= 1.3 if !@opponent.hasType?(:POISON)
      when :TOXICORB, :FLAMEORB, :LAGGINGTAIL, :IRONBALL, :STICKYBARB
        miniscore *= 1.5
    end
    if [:CHOICESCARF, :CHOICEBAND, :CHOICESPECS].include?(@attacker.item) # choice locking
      if @opponent.lastMoveUsed.is_a?(Symbol) && pbAIfaster?(@move)
        lastmove = moveToMoveObject(@opponent.lastMoveUsed, @opponent)
        miniscore *= 3 if lastmove.pbIsStatus?
      end
      miniscore *= 1.5 if hasbadmoves(40)
      miniscore *= 1.5 if @battle.turncount == 1
      maxdam = checkAIdamage()
      miniscore *= 0.3 if maxdam > 0.5 * @attacker.hp
      miniscore *= 1.3 if maxdam < 0.33 * @attacker.hp
    end
    miniscore *= itemchangedynamicspeedcode(:bestow)
    return miniscore
  end

  def itemchangedynamicspeedcode(function)
    miniscore = 1.0
    # Removing item from opponent
    if [:knockoff, :covet, :embargo].include?(function) && @mondata.oppitemworks
      symbol = function == :embargo ? :embargo : :itemremove
      case @opponent.item
        when :CHOICESCARF then miniscore *= dynamicspeedcode(symbol, 1.5)
        when :FLOATSTONE then miniscore *= dynamicspeedcode(symbol, 1.2) if @battle.FE == :DEEPEARTH
        when :QUICKPOWDER then miniscore *= dynamicspeedcode(symbol, 2.0) if @opponent.pokemon.species == :DITTO && !@opponent.effects[:Transform]
      end
    end
    # Giving attacker's item to opponent
    if function == :bestow && @opponent.itemWorks?(ignorenoitem: true)
      case @attacker.item
        when *PBStuff::TRAININGITEMS then miniscore *= dynamicspeedcode(:itemgive, 2.0)
        when :IRONBALL then miniscore *= dynamicspeedcode(:itemgive, 2.0) if @battle.FE != :DEEPEARTH
      end
    end
    # Attacker's speed changes after using a move are irrelevant for dynamic speed
    # Hence giving opponent's item to attacker and removing item from attacker are not considered
    return miniscore
  end

  def recoilcode(initialscore)
    recoil = getRecoilFromInitialScore(initialscore)
    return @move.pbIsDamaging? ? 1 : 0 unless recoil > 0

    miniscore = 0.9
    miniscore *= 0.7 if notOHKO?(@opponent, @attacker, true)
    miniscore *= 0.8 if @attacker.hp > 0.1 * @attacker.totalhp && @attacker.hp < 0.4 * @attacker.totalhp
    miniscore *= 0.4 if recoil >= @attacker.hp && (@opponent.status == :SLEEP || @opponent.status == :FROZEN) && @opponent.crested != :SUICUNE
    return miniscore
  end

  def weathercode
    if aiCheckGlobalAbility([:AIRLOCK, :CLOUDNINE, :DELTASTREAM, :DESOLATELAND, :PRIMORDIALSEA, :TEMPEST])
      return @move.pbIsDamaging? ? 1 : 0
    end
    return @move.pbIsDamaging? ? 1 : 0 if [:NEWWORLD, :UNDERWATER].include?(@battle.FE)

    miniscore = 1.0
    miniscore *= 1.3 if notOHKO?(@opponent, @attacker, true)
    miniscore *= 1.2 if @mondata.roles.include?(:LEAD)
    miniscore *= 1.4 if @attacker.pbHasMove?(:WEATHERBALL)
    miniscore *= 1.5 if @attacker.ability == :FORECAST
    return miniscore
  end

  def suncode
    return @move.pbIsDamaging? ? 1 : 0 if @battle.weather == :SUNNYDAY
    return @move.pbIsDamaging? ? 1 : 0 if @battle.FE == :DIMENSIONAL

    miniscore = 1.0
    miniscore *= 0.2 if @attacker.ability == :FORECAST && (@opponent.hasType?(:GROUND) || @opponent.hasType?(:ROCK))
    miniscore *= 1.3 if (@mondata.attitemworks && @attacker.item == :HEATROCK) || [:DESERT, :MOUNTAIN, :SNOWYMOUNTAIN, :SKY].include?(@battle.FE)
    miniscore *= 1.5 if ![0, :SUNNYDAY].include?(@battle.pbWeather(@attacker))
    miniscore *= 1.5 if @attacker.pbHasMove?(:MOONLIGHT, :SYNTHESIS, :MORNINGSUN, :GROWTH, :SOLARBEAM, :SOLARBLADE)
    miniscore *= 0.7 if checkAImoves([:SYNTHESIS, :MOONLIGHT, :MORNINGSUN])
    miniscore *= 1.5 if @attacker.hasType?(:FIRE)
    if @attacker.ability == :CHLOROPHYLL || @attacker.ability == :FLOWERGIFT
      miniscore *= 2
      miniscore *= 2 if notOHKO?(@opponent, @attacker, true)
      miniscore *= 3 if seedProtection?(@attacker)
    end
    miniscore *= 1.3 if [:SOLARPOWER, :LEAFGUARD, :SOLARIDOL].include?(@attacker.ability)
    miniscore *= 0.5 if pbPartyHasType?(:WATER)
    miniscore *= 0.7 if @attacker.pbHasMove?(:THUNDER, :HURRICANE)
    miniscore *= 0.5 if @attacker.ability == :DRYSKIN
    miniscore *= 1.5 if @attacker.ability == :HARVEST
    miniscore *= dynamicspeedcode(:SUNNYDAY, 2.0) if @attacker.pbPartner.ability == :CHLOROPHYLL && !@attacker.pbPartner.chlorophyllActive?
    miniscore *= dynamicspeedcode(:ProtoDrivePartner, 1.5) if @attacker.pbPartner.ability == :PROTOSYNTHESIS && @attacker.pbPartner.effects[:Protosynthesis] == 0 && @attacker.pbPartner.getHighestStatWithStages == PBStats::SPEED
    return miniscore
  end

  def raincode
    return 0 if @battle.weather == :RAINDANCE
    return @move.pbIsDamaging? ? 1 : 0 if [:DIMENSIONAL, :INFERNAL].include?(@battle.FE)

    miniscore = 1.0
    miniscore *= 0.2 if @attacker.ability == :FORECAST && (@opponent.hasType?(:GRASS) || @opponent.hasType?(:ELECTRIC))
    miniscore *= 1.3 if (@mondata.attitemworks && @attacker.item == :DAMPROCK) || [:SKY, :CLOUDS].include?(@battle.FE)
    miniscore *= 1.3 if ![0, :RAINDANCE].include?(@battle.pbWeather(@attacker))
    miniscore *= 1.5 if @attacker.pbHasMove?(:THUNDER, :HURRICANE)
    miniscore *= 1.5 if @attacker.hasType?(:WATER)
    if @attacker.ability == :SWIFTSWIM
      miniscore *= 2
      miniscore *= 2 if notOHKO?(@opponent, @attacker, true)
      miniscore *= 3 if seedProtection?(@attacker)
    end
    miniscore *= 1.5 if @attacker.ability == :DRYSKIN
    miniscore *= 0.5 if pbPartyHasType?(:FIRE)
    miniscore *= 0.5 if @attacker.pbHasMove?(:MOONLIGHT, :SYNTHESIS, :MORNINGSUN, :GROWTH, :SOLARBEAM, :SOLARBLADE)
    miniscore *= 1.5 if @attacker.ability == :HYDRATION
    miniscore *= dynamicspeedcode(:RAINDANCE, 2.0) if @attacker.pbPartner.ability == :SWIFTSWIM && !@attacker.pbPartner.swiftSwimActive?
    return miniscore
  end

  def sandcode
    return 0 if @battle.weather == :SANDSTORM
    return @move.pbIsDamaging? ? 1 : 0 if @battle.FE == :DIMENSIONAL

    miniscore = 1.0
    miniscore *= 1.3 if (@mondata.attitemworks && @attacker.item == :SMOOTHROCK) || [:DESERT, :ASHENBEACH, :SKY].include?(@battle.FE)
    miniscore *= 2 if ![0, :SANDSTORM].include?(@battle.pbWeather(@attacker))
    miniscore *= (@attacker.hasType?(:ROCK) || @attacker.hasType?(:GROUND) || @attacker.hasType?(:STEEL)) ? 1.3 : 0.7
    miniscore *= 1.5 if @attacker.hasType?(:ROCK)
    if @attacker.ability == :SANDRUSH
      miniscore *= 2
      miniscore *= 2 if notOHKO?(@opponent, @attacker, true)
      miniscore *= 3 if seedProtection?(@attacker)
    end
    miniscore *= 1.3 if @attacker.ability == :SANDVEIL
    miniscore *= 0.5 if @attacker.pbHasMove?(:MOONLIGHT, :SYNTHESIS, :MORNINGSUN, :GROWTH, :SOLARBEAM, :SOLARBLADE)
    miniscore *= 1.5 if @attacker.pbHasMove?(:SHOREUP)
    miniscore *= 1.5 if @attacker.ability == :SANDFORCE
    miniscore *= dynamicspeedcode(:SANDSTORM, 2.0) if @attacker.pbPartner.ability == :SANDRUSH && !@attacker.pbPartner.sandRushActive?
    return miniscore
  end

  def hailcode
    return 0 if @battle.weather == :HAIL
    return @move.pbIsDamaging? ? 1 : 0 if [:SUPERHEATED, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@battle.FE)
    return @move.pbIsDamaging? ? 1 : 0 if Rejuv && @battle.FE == :DRAGONSDEN

    miniscore = 1.0
    miniscore *= 0.2 if @attacker.ability == :FORECAST && [:ROCK, :FIRE, :STEEL, :FIGHTING].any? { |type| @opponent.hasType?(type) }
    miniscore *= 1.3 if (@mondata.attitemworks && @attacker.item == :ICYROCK) || [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION, :CLOUDS, :SKY].include?(@battle.FE)
    miniscore *= 1.3 if ![0, :SNOW].include?(@battle.pbWeather(@attacker))
    miniscore *= @attacker.hasType?(:ICE) ? 5 : 0.7
    if @attacker.ability == :SLUSHRUSH || @attacker.crested == :EMPOLEON || (@attacker.crested == :CASTFORM && @attacker.form == 3)
      miniscore *= 2
      miniscore *= 2 if notOHKO?(@opponent, @attacker, true)
      miniscore *= 3 if seedProtection?(@attacker)
    end
    miniscore *= 1.3 if [:SNOWCLOAK, :ICEBODY, :LUNARIDOL].include?(@attacker.ability) || (@attacker.ability == :ICEFACE && @attacker.form == 1)
    miniscore *= 0.5 if @attacker.pbHasMove?(:MOONLIGHT, :SYNTHESIS, :MORNINGSUN, :GROWTH, :SOLARBEAM, :SOLARBLADE)
    miniscore *= 2 if @attacker.pbHasMove?(:AURORAVEIL)
    miniscore *= 1.3 if @attacker.pbHasMove?(:BLIZZARD)
    if @attacker.pbPartner.ability == :SLUSHRUSH || @attacker.pbPartner.crested == :EMPOLEON || (@attacker.pbPartner.crested == :CASTFORM && @attacker.pbPartner.form == 3)
      miniscore *= dynamicspeedcode(:HAIL, 2.0) unless @attacker.pbPartner.slushRushActive?
    end
    return miniscore
  end

  def snowcode
    return 0 if @battle.weather == :SNOW
    return @move.pbIsDamaging? ? 1 : 0 if [:SUPERHEATED, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@battle.FE)
    return @move.pbIsDamaging? ? 1 : 0 if Rejuv && @battle.FE == :DRAGONSDEN

    miniscore = 1.0
    miniscore *= 0.2 if @attacker.ability == :FORECAST && [:ROCK, :FIRE, :STEEL, :FIGHTING].any? { |type| @opponent.hasType?(type) }
    miniscore *= 1.3 if (@mondata.attitemworks && @attacker.item == :ICYROCK) || [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION, :CLOUDS, :SKY].include?(@battle.FE)
    miniscore *= 1.3 if ![0, :HAIL].include?(@battle.pbWeather(@attacker))
    if @attacker.ability == :SLUSHRUSH || @attacker.crested == :EMPOLEON || (@attacker.crested == :CASTFORM && @attacker.form == 3)
      miniscore *= 2
      miniscore *= 2 if notOHKO?(@opponent, @attacker, true)
      miniscore *= 3 if seedProtection?(@attacker)
    end
    miniscore *= 1.3 if [:SNOWCLOAK, :ICEBODY, :LUNARIDOL].include?(@attacker.ability) || (@attacker.ability == :ICEFACE && @attacker.form == 1)
    miniscore *= 0.5 if @attacker.pbHasMove?(:MOONLIGHT) || @attacker.pbHasMove?(:SYNTHESIS) || @attacker.pbHasMove?(:MORNINGSUN) || @attacker.pbHasMove?(:GROWTH) || @attacker.pbHasMove?(:SOLARBEAM) || @attacker.pbHasMove?(:SOLARBLADE)
    miniscore *= 2 if @attacker.pbHasMove?(:AURORAVEIL)
    miniscore *= 1.3 if @attacker.pbHasMove?(:BLIZZARD)
    if @attacker.pbPartner.ability == :SLUSHRUSH || @attacker.pbPartner.crested == :EMPOLEON || (@attacker.pbPartner.crested == :CASTFORM && @attacker.pbPartner.form == 3)
      miniscore *= dynamicspeedcode(:SNOW, 2.0) unless @attacker.pbPartner.slushRushActive?
    end
    return miniscore
  end

  def subcode
    return 0 if (@move.move == :SHEDTAIL ? @attacker.hp * 2 <= @attacker.totalhp : @attacker.hp * 4 <= @attacker.totalhp)
    return 0 if @attacker.effects[:Substitute] > 0 && pbAIfaster?(@move)

    miniscore = 1.0
    miniscore *= 1.2 if @opponent.effects[:LeechSeed] >= 0
    miniscore *= 1.2 if checkAImoves([:SPORE, :SLEEPPOWDER])
    miniscore *= 1.5 if @opponent.status == :SLEEP && @opponent.crested != :SUICUNE
    miniscore *= 0.3 if @opponent.ability == :INFILTRATOR
    miniscore *= 0.3 if getAIMemory().any? { |moveloop| moveloop&.pbIsDamaging? && moveloop.checkSoundMove?(@opponent) }
    miniscore *= 2.0 if checkAIdamage() * 4 < @attacker.totalhp && (getAIMemory().length > 0)
    miniscore *= 1.3 if @opponent.effects[:Confusion] > 0
    miniscore *= 1.3 if @opponent.status == :PARALYSIS && @opponent.crested != :SUICUNE
    miniscore *= 1.3 if @opponent.effects[:Attract] >= 0
    miniscore *= 0.5 if @battle.doublebattle
    if @move.move != :SHEDTAIL
      miniscore *= (@attacker.hp == @attacker.totalhp) ? 1.1 : (@attacker.hp * (1.0 / @attacker.totalhp))
      miniscore *= 1.2 if hpGainPerTurn > 1
      miniscore *= 1.2 if @attacker.moves.any? { |moveloop| moveloop&.isHealingMove? }
      miniscore *= 1.5 if @attacker.pbHasMove?(:FOCUSPUNCH)
      miniscore *= 1.2 if @attacker.pbHasMove?(:BATONPASS)
      miniscore *= 1.1 if @attacker.ability == :SPEEDBOOST
    end
    return miniscore
  end

  def futurecode
    return 0 if @opponent.effects[:FutureSight] > 0

    miniscore = 0.6
    miniscore *= 0.7 if @battle.doublebattle
    miniscore *= 0.7 if @attacker.pbNonActivePokemonCount == 0
    miniscore *= 1.2 if @attacker.effects[:Substitute] > 0
    miniscore *= 1.2 if @attacker.moves.any? { |moveloop| moveloop != nil && [:PROTECT, :DETECT, :KINGSSHIELD, :BANEFULBUNKER, :SPIKYSHIELD, :OBSTRUCT, :SILKTRAP, :BURNINGBULWARK].include?(moveloop.move) }
    miniscore *= 1.1 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
    miniscore *= 1.2 if @attacker.ability == :MOODY || @attacker.pbHasMove?(:QUIVERDANCE, :NASTYPLOT, :TAILGLOW)
    return miniscore
  end

  def focuscode
    return 0 if @mondata.skill >= BESTSKILL && @battle.FE == :ELECTERRAIN

    miniscore = 1.0
    if @attacker.effects[:Substitute] > 0
      multicheck = getAIMemory().any? { |moveloop| moveloop != nil && @opponent.pbGetHitNumber(moveloop, norandomness: true) > 1 }
      throughcheck = getAIMemory().any? { |moveloop| moveloop&.pbIsDamaging? && !moveloop.blockedBySubstitute?(@opponent, @attacker) }
      miniscore *= multicheck || throughcheck ? 0.9 : 1.3
    else
      miniscore *= 0.8
    end
    miniscore *= 1.2 if @opponent.status == :SLEEP && @opponent.ability != :EARLYBIRD && @opponent.ability != :SHEDSKIN && @opponent.crested != :SUICUNE
    miniscore *= 0.5 if @battle.doublebattle
    miniscore *= 1.5 if @opponent.effects[:HyperBeam] > 0
    miniscore *= 0.3 if miniscore <= 1.0
    return miniscore
  end

  def suckercode
    return 0 if @opponent.effects[:HyperBeam] > 0
    return 0 if getAIMemory().length >= 4 && !getAIMemory().any? { |moveloop| moveloop&.pbIsDamaging? }

    miniscore = 1.0
    return miniscore * 1.3 if getAIMemory().length >= 4 && getAIMemory().all? { |moveloop| moveloop&.pbIsDamaging? }

    miniscore *= 0.6 if checkAIhealing()
    miniscore *= 0.8 if checkAImoves(PBStuff::SETUPMOVE)
    if $cache.moves[@attacker.lastMoveUsed]&.function == 0x116 # Sucker Punch last turn
      miniscore *= 0.3 if @battle.pbRandom(3) != 1
      miniscore *= 0.5 if checkAImoves(PBStuff::SETUPMOVE)
    end
    if pbAIfaster?()
      miniscore *= 0.8
      miniscore *= 0.6 if @initial_scores.length > 0 && @initial_scores.max != @initial_scores[@score_index]
    else
      miniscore *= 0 if @battle.FE == :CHESS && @opponent.piece == :KING
      miniscore *= checkAIpriority() ? 0.5 : 1.3
    end
    return miniscore
  end

  def redirectioncode
    return 0 if @attacker.pbPartner.isFainted?
    return 0 if [:PROPELLERTAIL, :STALWART].include?(@opponent.ability)
    return 0 if @move.move == :RAGEPOWDER && @opponent.powderImmune?


    miniscore = 1.0
    miniscore *= 1.2 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL) || @mondata.roles.include?(:TANK)
    miniscore *= 1.3 if @attacker.pbPartner.ability == :MOODY
    miniscore *= @attacker.pbPartner.turncount < 1 ? 1.5 : 1.2
    miniscore *= 1.3 if @attacker.pbPartner.moves.any? { |moveloop| moveloop != nil && (PBStuff::SETUPMOVE.include?(moveloop.move)) }
    miniscore *= 1.5 if notOHKO?(@opponent, @attacker, true)
    if @attacker.pbPartner.moves.any? { |moveloop| moveloop != nil && ((PBStuff::FAVOURABLEFIELDCONDITION.include?(moveloop.move) && @battle.state.atDefaultValue?(PBStuff::FAVOURABLEFIELDCONDITION[moveloop.move]))) }
      miniscore *= 4
      miniscore *= 6 if @initial_scores.length > 0 && hasgreatmoves() # experimental -- cancels out drop if killing moves
    end
    if @attacker.hp == @attacker.totalhp || (@attacker.isbossmon && @attacker.shieldCount > 0)
      miniscore *= 1.2
    else
      miniscore *= 0.8 if @attacker.hp * 2 < @attacker.totalhp
    end
    miniscore *= 1.2 if !pbAIfaster?()
    return miniscore
  end

  def followcode
    miniscore = redirectioncode()
    return miniscore if miniscore == 0

    miniscore *= 0.8 if getAIMemory().any? { |move| ignoresRedirection?(@move.move, move, @opponent, @attacker) }

    bestmove, maxdam = checkAIMovePlusDamage(@opponent, @attacker.pbPartner)
    if maxdam >= @attacker.pbPartner.hp &&
       !ignoresRedirection?(@move.move, bestmove, @opponent, @attacker) &&
       pbRoughDamage(bestmove, @opponent, @attacker) < 0.7 * @attacker.hp
      miniscore *= 1.3
    end

    if @attacker.ability == :SPICYSPRAY && @opponent.pbCanBurn?(@attacker, nil)
      miniscore *= survivesAt1HP?(@opponent) ? 1.4 : 1.2 if !@battle.magicGuardAbilities.include?(@opponent.ability)
      miniscore *= @opponent.pbGetHitNumber(bestmove, norandomness: true) > 1 ? 1.4 : 1.2 if @opponent.attack > @opponent.spatk
    end

    return miniscore
  end

  def gravicode
    return 0 if @battle.state.effects[:Gravity] != 0
    return 0 if @attacker.moves.any? { |moveloop| moveloop&.pbIsDamaging? && moveloop.unusableInGravity? }

    miniscore = 1.0
    miniscore *= 2 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.accuracy <= 70 }
    miniscore *= 2 if @attacker.pbPartner.pbHasMove?(:GRAVAPPLE)
    miniscore *= 3 if @attacker.pbHasMove?(:ZAPCANNON, :INFERNO, *PBStuff::SLEEPMOVE)
    miniscore *= 2 if checkAIbestMove().unusableInGravity?
    miniscore *= 1.5 if @mondata.attitemworks && @attacker.item == :AMPLIFIELDROCK
    miniscore *= 2 if @attacker.hasType?(:GROUND) && (@opponent.hasType?(:FLYING) || PBStuff::LevitateAbilities.include?(@opponent.ability) || (@mondata.oppitemworks && @opponent.item == :AIRBALLOON))
    return miniscore
  end

  def magnocode
    return 0 if @attacker.effects[:MagnetRise] > 0 || @attacker.effects[:Ingrain] || @attacker.effects[:SmackDown]

    miniscore = 1.0
    miniscore *= 3 if checkAIbestMove().pbType(@opponent) == :GROUND # Highest expected dam from a ground move
    miniscore *= 3 if @opponent.hasType?(:GROUND)
    return miniscore
  end

  def telecode
    return 0 if @opponent.effects[:Telekinesis] > 0 || @opponent.effects[:Ingrain] || @opponent.effects[:SmackDown] || @battle.state.effects[:Gravity] != 0
    return 0 if @opponent.species == :DIGLETT || @opponent.species == :DUGTRIO || @opponent.species == :SANDYGAST || @opponent.species == :PALOSSAND
    return 0 if (@opponent.species == :GENGAR && @opponent.form == 1) || @opponent.item == :IRONBALL

    miniscore = 1.0
    miniscore *= 2 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.accuracy <= 70 }
    miniscore *= 2 if @attacker.pbHasMove?(:ZAPCANNON, :INFERNO)
    miniscore *= 0.5 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbType(@attacker) == :GROUND && moveloop.pbIsDamaging? }
    miniscore *= oppstatdrop([0, 2, 0, 2, 0, 0, 0]) if @mondata.skill >= BESTSKILL && @battle.FE == :PSYTERRAIN
    return miniscore
  end

  def afteryoucode
    return 0 if !scoringAgainstPartner? && @move.move == :AFTERYOU
    # opponent is partner from here on
    miniscore = 1.0
    for opp in [@attacker.pbOppositeOpposing, @attacker.pbCrossOpposing].select { |opp| opp.hp > 0 }
      if pbAIfaster?(@move, nil, @attacker, opp) && !pbAIfaster?(nil, nil, @opponent, opp) # user is faster than opp but partner isn't
        miniscore *= 1.5
        miniscore *= 1.5 if checkAIdamage(@opponent, opp) >= @opponent.hp
      end
    end
    miniscore *= 10 if Reborn && @battle.opponent.is_a?(Array) && @battle.opponent.any? { |opp| opp.trainertype == :UMBNOEL } && @attacker.index.odd? && @battle.turncount == 1
    return miniscore
  end

  def quashcode
    return 0 if @attacker.pbPartner.isFainted?
    miniscore = 1.0
    if pbAIfaster?(@move, nil, @attacker, @opponent) && !pbAIfaster?(nil, nil, @attacker.pbPartner, @opponent) # user is faster than opponent but partner isn't
      miniscore *= 1.5
      miniscore *= 1.5 if checkAIdamage(@attacker.pbPartner, @opponent) >= @attacker.pbPartner.hp
    end
    return miniscore
  end

  def trcode
    return 0 if pbAIfaster?() && !(@mondata.attitemworks && @attacker.item == :IRONBALL)
    return 0 if @opponent.hp > 0 && @battle.FE == :CHESS && @opponent.piece == :KING
    miniscore = 1.0
    if @battle.state.effects[:TrickRoom] <= 0
      miniscore *= 2
      miniscore *= 1.3 if @mondata.partyroles.any? { |role| role.include?(:TRICKROOMSWEEPER) }
      miniscore *= 1.3 if @mondata.roles.include?(:TANK) || @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
      miniscore *= 1.5 if @mondata.roles.include?(:LEAD)
      miniscore *= 1.3 if @battle.doublebattle
      [@attacker, @attacker.pbPartner].each { |i| miniscore *= 1.5 if i.hasWorkingItem(:ROOMSERVICE) }
      [@opponent, @opponent.pbPartner].each { |i| miniscore *= 0.5 if i.hasWorkingItem(:ROOMSERVICE) }
      miniscore *= 6 if @initial_scores.length > 0 && hasgreatmoves() # experimental -- cancels out drop if killing moves
    else
      miniscore *= 1.3
    end
    miniscore *= 1.5 if notOHKO?(@opponent, @attacker, true)
    if @opponent.pbPartner.hp > 0
      miniscore *= 0.3 if @attacker.pbSpeed < pbRoughStat(@opponent, PBStats::SPEED) && @attacker.pbSpeed > pbRoughStat(@opponent.pbPartner, PBStats::SPEED)
      miniscore *= 0.3 if @attacker.pbSpeed > pbRoughStat(@opponent, PBStats::SPEED) && @attacker.pbSpeed < pbRoughStat(@opponent.pbPartner, PBStats::SPEED)
    end
    return miniscore
  end

  def wondercode
    return 0 if @battle.state.effects[:WonderRoom] != 0
    miniscore = 1.0
    miniscore *= 1.3 if (@mondata.attitemworks && @attacker.item == :AMPLIFIELDROCK) || [:NEWWORLD, :PSYTERRAIN].include?(@battle.FE) || (Rejuv && @battle.FE == :STARLIGHT)
    if pbRoughStat(@opponent, PBStats::ATTACK) > pbRoughStat(@opponent, PBStats::SPATK)
      miniscore *= @attacker.defense > @attacker.spdef ? 0.5 : 2
    else
      miniscore *= @attacker.defense > @attacker.spdef ? 2 : 0.5
    end
    if @attacker.attack > @attacker.spatk
      miniscore *= pbRoughStat(@opponent, PBStats::DEFENSE) > pbRoughStat(@opponent, PBStats::SPDEF) ? 2 : 0.5
    else
      miniscore *= pbRoughStat(@opponent, PBStats::DEFENSE) > pbRoughStat(@opponent, PBStats::SPDEF) ? 0.5 : 2
    end
    return miniscore
  end

  def powdercode
    return 0 if @opponent.hasType?(:GRASS) || @opponent.ability == :OVERCOAT || (@mondata.oppitemworks && @opponent.item == :SAFETYGOGGLES)
    return 0 if getAIMemory().length >= 4 && !getAIMemory().any? { |moveloop| moveloop != nil && moveloop.pbType(@opponent) == :FIRE }

    miniscore = 1.0
    miniscore *= 1.2 if !pbAIfaster?()
    if checkAIbestMove().pbType(@opponent) == :FIRE
      miniscore *= 3
    else
      miniscore *= @opponent.hasType?(:FIRE) ? 2 : 0.2
    end
    miniscore *= PBTypes.typesEff(:FIRE, @attacker.types, inverse: @battle.inverse?).multiplier
    miniscore *= 0.6 if @attacker.lastMoveUsed == :POWDER
    miniscore *= 0.5 if @battle.magicGuardAbilities.include?(@opponent.ability)
    return miniscore
  end

  def burnupcode(type)
    return 0 if !@attacker.hasType?(type)
    # if the attacker cannot change type then the scoring below doesn't apply as the required type for the attack isn't lost
    return 1 if !@attacker.canChangeType?

    miniscore = (1 - @opponent.pbNonActivePokemonCount * 0.05)
    if @initial_scores[@score_index] < 100
      miniscore *= 0.9
      miniscore *= 0.5 if getAIMemory().any? { |moveloop| moveloop != nil && moveloop.isHealingMove? }
    end
    miniscore *= 0.5 if @initial_scores.length > 0 && hasgreatmoves()
    miniscore *= 0.7 if @attacker.pbNonActivePokemonCount == 0 && @opponent.pbNonActivePokemonCount != 0
    for otype in @opponent.types
      effcheck = PBTypes.oneTypeEff(otype, type, inverse: @battle.inverse?)
      miniscore *= 1.5 if effcheck.superEffective?
      miniscore *= 0.5 if effcheck.resistedOrImmune?
    end
    effcheck = PBTypes.oneTypeEff(checkAIbestMove().pbType(@opponent), type, inverse: @battle.inverse?)
    miniscore *= 1.5 if effcheck.superEffective?
    miniscore *= 0.5 if effcheck.resistedOrImmune?
    return miniscore
  end

  def beakcode
    miniscore = burncode
    miniscore *= 0.7 if pbAIfaster?()
    if getAIMemory().any? { |moveloop| moveloop != nil && @opponent.makesContact?(moveloop) }
      miniscore *= 1.5
    elsif @opponent.attack > @opponent.spatk
      miniscore *= 1.3
    else
      miniscore *= 0.3
    end
    return miniscore
  end

  def pussydeathcode(initialscore)
    recoil = getRecoilFromInitialScore(initialscore)
    recoilOnFail = @move.function == 0x175 # Mind Blown (damages user even if move misses/is protected against, unlike Chloroblast)
    if recoil >= @attacker.hp
      return deathcode(recoilOnFail)
    elsif recoil > 0
      miniscore = 0.7
      miniscore *= 0.7 if initialscore < 100
      miniscore *= 0.5 if !pbAIfaster?()
      miniscore *= 1.3 if checkAIdamage() < @attacker.totalhp * 0.2
      miniscore *= 1.2 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.isHealingMove? }
      miniscore *= 1.3 if @initial_scores.length > 0 && hasbadmoves(25)
      if recoilOnFail
        miniscore *= 0.5 if checkAImoves(PBStuff::PROTECTMOVE) && !@move.unseenFistCheck(@attacker) && @opponent.effects[:ProtectRate] < 1
        miniscore *= (1 - 0.1 * @opponent.stages[PBStats::EVASION])
        miniscore *= (1 + 0.1 * @attacker.stages[PBStats::ACCURACY])
        miniscore *= 0.7 if @mondata.oppitemworks && (@opponent.item == :LAXINCENSE || @opponent.item == :BRIGHTPOWDER)
        miniscore *= 0.7 if accuracyWeatherAbilityActive?(@opponent, @attacker)
      end
    else
      miniscore = 1.1
    end
    return miniscore
  end

  def chopcode
    return 1 if secondaryEffectNegated?()

    miniscore = 1.0
    if checkAIbestMove().checkSoundMove?(@opponent)
      miniscore *= 1.5
    elsif getAIMemory().any? { |moveloop| moveloop != nil && moveloop.checkSoundMove?(@opponent) }
      miniscore *= 1.3
    end
    return miniscore
  end

  def shelltrapcode
    miniscore = 1.0
    miniscore *= 0.5 if pbAIfaster?()
    bestmove, maxdam = checkAIMovePlusDamage()
    if notOHKO?(@opponent, @attacker, true)
      miniscore *= 1.2
    else
      miniscore *= 0.8
      miniscore *= 0.8 if maxdam > @attacker.hp
    end
    miniscore *= 0.7 if @attacker.lastMoveUsed == :SHELLTRAP
    miniscore *= 0.6 if checkAImoves(PBStuff::SETUPMOVE)
    miniscore *= @attacker.hp * (1.0 / @attacker.totalhp)
    miniscore *= 0.3 if @opponent.spatk > @opponent.attack
    miniscore *= 0.05 if bestmove.pbIsSpecial?(@attacker)
    return miniscore
  end

  def almostuselessmovecode
    return 0 if !scoringAgainstPartner? || @opponent.status.nil?

    miniscore = 1.5
    if @opponent.hp > @opponent.totalhp * 0.8
      miniscore *= 0.8
    elsif @opponent.hp > @opponent.totalhp * 0.3
      miniscore *= 2
    end
    miniscore *= 1.3 if @opponent.effects[:Toxic] > 3
    miniscore *= 1.3 if checkAImoves([:HEX])
    return miniscore
  end

  def psychicterraincode
    return @move.pbIsDamaging? ? 1 : 0 if !@battle.canChangeFE?(:PSYTERRAIN)

    if Overlays && @battle.FE != :INDOOR
      return @move.pbIsDamaging? ? 1 : 0 if @battle.OV == :PSYTERRAIN || @battle.FE == :FROZENDIMENSION

      miniscore = 1.0
    else
      miniscore = getFieldDisruptScore(@attacker, @opponent)
      miniscore *= 1.5 if @attacker.ability == :TELEPATHY
      miniscore *= 1.3 if checkAIpriority() && !@opponent.isAirborne?
      miniscore *= dynamicspeedcode(:PSYTERRAIN, 2.0) if @attacker.pbPartner.ability == :TELEPATHY
    end
    miniscore *= 1.5 if @attacker.hasType?(:PSYCHIC)
    miniscore *= 2 if pbPartyHasType?(:PSYCHIC)
    miniscore *= 0.5 if @opponent.hasType?(:PSYCHIC)
    miniscore *= 1.5 if @attacker.ability == :ANTICIPATION || (Rejuv && @attacker.ability == :FOREWARN)
    miniscore *= 1.25 if @attacker.ability == :MINDSEYE
    miniscore *= 0.7 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbIsPriorityMoveAI(@attacker) } && @attacker.isAirborne?
    miniscore *= 2 if @mondata.attitemworks && @attacker.item == :AMPLIFIELDROCK
    return miniscore
  end

  def instructcode
    return 0 if !scoringAgainstPartner? || !@opponent.lastMoveUsed.is_a?(Symbol) # @opponent from here on out is the same as @attacker.pbPartner (but cloned)

    lastmoveindex = @opponent.moves.find_index { |move| move.move == @opponent.lastMoveUsed }
    return 0 if lastmoveindex.nil? || !@battle.pbCanChooseMove?(@opponent.index, lastmoveindex, instructed: true)

    miniscore = 3.0
    miniscore *= 0.5 if @opponent.hp < 0.5 * @opponent.totalhp
    miniscore *= 1.2 if @opponent.hp == @opponent.totalhp
    miniscore *= 1.2 if @initial_scores.length > 0 && hasbadmoves(20)

    lastmove = @opponent.moves[lastmoveindex]
    lastmove = pbChangeMove(lastmove, @opponent)
    lastmovetargetindex = @opponent.lastMoveChoice[3]
    lastmovetargetindex = @opponent.pbFirstOpposing.index if lastmovetargetindex == -1
    lastmovetarget = @battle.battlers[lastmovetargetindex]
    if [:AllOpposing, :AllNonUsers, :DragonDarts].include?(@opponent.pbTarget(lastmove)) && !lastmovetarget.pbPartner.isFainted?
      movescore1 = pbRoughDamage(lastmove, @opponent, lastmovetarget)
      movescore2 = pbRoughDamage(lastmove, @opponent, lastmovetarget.pbPartner)
      return 0 if movescore1 + movescore2 <= 0
      miniscore *= 1.5 if movescore1 > lastmovetarget.hp || movescore2 > lastmovetarget.pbPartner.hp
    else
      movescore = pbRoughDamage(lastmove, @opponent, lastmovetarget)
      return 0 if movescore <= 0
      miniscore *= 1.5 if movescore > lastmovetarget.hp
    end
    miniscore *= 0.5 if @opponent.pbTarget(lastmove) == :AllNonUsers && pbRoughDamage(lastmove, @opponent, @attacker) >= @attacker.hp
    miniscore *= 1.4 if !pbAIfaster?(nil, nil, @opponent, @attacker.pbOpposing1) && !pbAIfaster?(nil, nil, @opponent, @attacker.pbOpposing2)
    miniscore *= (1 + ([@opponent.attack, @opponent.spatk].max - [@attacker.attack, @attacker.spatk].max) / 100.0)
    return miniscore
  end

  def antistatcode(stats, beginscore)
    miniscore = 1.0
    miniscore *= (1 - 0.05 * (@opponent.pbNonActivePokemonCount - 2)) if @opponent.pbNonActivePokemonCount > 0
    miniscore *= 1.2 if !@battle.doublebattle && @mondata.partyroles.any? { |role| role.include?(:PIVOT) }
    miniscore *= 0.7 if @initial_scores.length > 0 && hasgreatmoves()
    miniscore *= 0.9 if beginscore < 100
    stats.unshift(0)
    for i in 0...stats.length
      next if stats[i].nil? || stats[i] == 0

      case i
        when PBStats::ATTACK
          miniscore *= 0.5 if beginscore < 100 && checkAIhealing()
          miniscore *= 0.8 if @opponent.pbNonActivePokemonCount > 0 && @attacker.pbNonActivePokemonCount == 0
        when PBStats::DEFENSE
          miniscore /= 0.9 if beginscore < 100 && !pbAIfaster?() || checkAIpriority()
          miniscore /= 0.9 if beginscore < 100 && @opponent.attack < @opponent.spatk
          miniscore *= 0.8 if @mondata.roles.include?(:PHYSICALWALL)
        when PBStats::SPEED
          miniscore *= 1.1 if @mondata.roles.include?(:TANK)
          miniscore *= 0.8 if @attacker.pbSpeed > pbRoughStat(@opponent, PBStats::SPEED)
        when PBStats::SPATK
          miniscore *= 0.5 if beginscore < 100 && checkAIhealing()
          miniscore *= 0.8 if @opponent.pbNonActivePokemonCount > 0 && @attacker.pbNonActivePokemonCount == 0
        when PBStats::SPDEF
          miniscore /= 0.9 if !pbAIfaster?() || checkAIpriority()
          miniscore /= 0.9 if beginscore < 100 && @opponent.attack > @opponent.spatk
          miniscore *= 0.9 if @mondata.roles.include?(:SPECIALWALL)
      end
    end
    return miniscore
  end

  def smackcode
    return 1 if @opponent.effects[:Substitute] > 0
    return 1 unless @opponent.isAirborne? || PBStuff::TWOTURNAIRMOVE.include?(opponent.effects[:TwoTurnAttack]) || checkAImoves(PBStuff::TWOTURNAIRMOVE)

    miniscore = 1.0
    # score boost if you can hit into a semi-invulnerability with this move
    if @mondata.skill >= BESTSKILL && !pbAIfaster?()
      if PBStuff::TWOTURNAIRMOVE.include?(@opponent.effects[:TwoTurnAttack]) || @opponent.effects[:SkyDrop]
        miniscore *= 2
      elsif checkAImoves(PBStuff::TWOTURNAIRMOVE)
        miniscore *= 1.3
      end
    end
    # is the target naturally airborne and do you have a ground move you want to hit them with?
    if @opponent.hasType?(:FLYING) || PBStuff::LevitateAbilities.include?(@opponent.ability) || (@battle.FE == :DEEPEARTH && [:MAGNETPULL, :CONTRARY, :UNAWARE, :OBLIVIOUS].include?(@opponent.ability))
      miniscore *= (@attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbType(@attacker) == :GROUND && moveloop.pbIsDamaging? }) ? 2 : 1.2
    end
    # will grounding them slow them down?
    if @opponent.isAirborne?
      miniscore *= dynamicspeedcode(:grounding, 4.0 / 3) if @battle.FE == :NEWWORLD || ([:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE) && ![:SURGESURFER, :SWIFTSWIM].include?(@opponent.ability) && !@opponent.hasType?(:WATER))
    end
    return miniscore
  end

  def nightmarecode
    return 0 if @opponent.effects[:Nightmare] || (@opponent.status != :SLEEP && @battle.FE != :INFERNAL) || @opponent.effects[:Substitute] > 0

    miniscore = 1.0
    miniscore *= 4 if @opponent.statusCount > 2 || @opponent.statusCount < 0
    miniscore *= 6 if @opponent.ability == :COMATOSE
    miniscore *= 6 if @initial_scores.length > 0 && hasbadmoves(25)
    miniscore *= 0.5 if @opponent.ability == :SHEDSKIN || @opponent.ability == :EARLYBIRD
    if PBStuff::TRAPPINGABILITIESAI.include?(@attacker.ability) || (@attacker.ability == :MAGNETPULL && @opponent.hasType?(:STEEL)) || @opponent.effects[:MeanLook] >= 0 || @opponent.pbNonActivePokemonCount == 0
      miniscore *= 1.3
    else
      miniscore *= 0.8
    end
    miniscore *= 0.5 if @battle.doublebattle
    return miniscore
  end

  def spitecode
    miniscore = 1.0
    lastmove = @opponent.lastMoveUsed.is_a?(Symbol) ? moveToMoveObject(@opponent.lastMoveUsed, @opponent) : nil
    miniscore *= 2 if lastmove&.pbIsDamaging? && (getAIMemory().count { |moveloop| moveloop != nil && moveloop.pbIsDamaging? }) == 1
    miniscore *= 0.5 if !pbAIfaster?(@move)
    if lastmove&.maxpp == 5
      miniscore *= 1.5
    elsif lastmove&.maxpp == 10
      miniscore *= 1.2
    else
      miniscore *= 0.7
    end
    return miniscore
  end

  def spoopycode
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.effects[:Curse] || (((@attacker.hp * 2 < @attacker.totalhp && @battle.FE != :HAUNTED) || (@attacker.hp * 4 < @attacker.totalhp)) && @move.function == 0x10d)

    miniscore = 0.7
    miniscore *= 0.5 if !pbAIfaster?(@move)
    miniscore *= 1.3 if @move.function == 0x10d && getAIMemory().length > 0 && checkAIdamage() * 5 < @attacker.hp
    miniscore *= 1.2 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.isHealingMove? }
    miniscore *= (1 + 0.05 * statchangecounter(@opponent, 1, 7))
    if PBStuff::TRAPPINGABILITIESAI.include?(@attacker.ability) || (@attacker.ability == :MAGNETPULL && @opponent.hasType?(:STEEL)) || @opponent.effects[:MeanLook] >= 0 || @opponent.pbNonActivePokemonCount == 0
      miniscore *= 1.3
    else
      miniscore *= 0.8
    end
    miniscore *= 0.5 if @battle.doublebattle
    miniscore *= 1.3 if @initial_scores.length > 0 && hasbadmoves(25)
    return miniscore
  end

  def saltcurecode
    return 1 if @opponent.effects[:Substitute] > 0 || @opponent.effects[:SaltCure] || secondaryEffectNegated?()

    miniscore = saltCureGood? ? 1.3 : 1.2
    miniscore *= 1.5 if [:DEUXFINALIS, :HOLY].include?(@battle.FE)
    miniscore *= 2 if @opponent.hasType?(:WATER) || @opponent.hasType?(:STEEL)
    miniscore *= 1.2 if @attacker.moves.any? { |moveloop| moveloop != nil && (moveloop.isHealingMove? || PBStuff::PROTECTMOVE.include?(moveloop.move))}
    miniscore *= (1 + 0.05 * statchangecounter(@opponent, 1, 7))
    if PBStuff::TRAPPINGABILITIESAI.include?(@attacker.ability) || (@attacker.ability == :MAGNETPULL && @opponent.hasType?(:STEEL)) || @opponent.effects[:MeanLook] >= 0 || @opponent.pbNonActivePokemonCount == 0
      miniscore *= 1.3
    else
      miniscore *= 0.8
    end
    miniscore *= 1.3 if @initial_scores.length > 0 && hasbadmoves(25)
    return miniscore
  end

  def brickbreakcode
    miniscore = 1.0
    miniscore *= (@move.pbIsPhysical?(@attacker) ? 1.8 : 1.3) if @attacker.pbOpposingSide.effects[:Reflect] > 0
    miniscore *= (@move.pbIsSpecial?(@attacker) ? 1.8 : 1.3) if @attacker.pbOpposingSide.effects[:LightScreen] > 0
    miniscore *= 2.0 if @attacker.pbOpposingSide.effects[:AuroraVeil] > 0
    miniscore *= 1.3 if @attacker.pbOpposingSide.effects[:AreniteWall] > 0
    miniscore *= 1.1 if @move.move == :SHADOWSHED && @attacker.pbOpposingSide.effects[:Safeguard] > 0
    return miniscore
  end

  def jumpcode(score)
    miniscore = 1.0
    miniscore *= 0.8 if score < 100
    miniscore *= 0.5 if checkAImoves(PBStuff::PROTECTMOVE) && !@move.unseenFistCheck(@attacker) && @opponent.effects[:ProtectRate] < 1
    miniscore *= (1 - 0.1 * @opponent.stages[PBStats::EVASION])
    miniscore *= (1 + 0.1 * @attacker.stages[PBStats::ACCURACY])
    miniscore *= 0.7 if accuracyWeatherAbilityActive?(@opponent, @attacker)
    miniscore *= 0.7 if (@mondata.oppitemworks && @opponent.item == :LAXINCENSE) || (@mondata.oppitemworks && @opponent.item == :BRIGHTPOWDER)
    if @attacker.index != 2 && @mondata.skill >= BESTSKILL && !@battle.inverse?
      miniscore *= 0.5 if $cache.types[@move.pbType(@attacker)].immune.any? { |type| pbPartyHasType?(type, @opponent.index) }
    end
    return miniscore
  end

  def hazardcode
    return @move.pbIsDamaging? ? 1 : 0 if @opponent.pbNonActivePokemonCount == 0

    miniscore = 1.0
    miniscore *= 1.1 if @mondata.roles.include?(:LEAD)
    miniscore *= 1.3 if notOHKO?(@opponent, @attacker)
    miniscore *= 1.2 if @attacker.turncount < 2
    miniscore *= 1.3 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::PHASEMOVE.include?(moveloop.move) }  && !(@opponent.effects[:Ingrain] || [:SUCTIONCUPS, :GUARDDOG].include?(@opponent.ability) || @opponent.pbNonActivePokemonCount == 0 || @battle.FE == :COLOSSEUM)
    miniscore *= 0.9 if (@attacker.stages[PBStats::ATTACK] > 0 || @attacker.stages[PBStats::SPATK] > 0) && @move.pbIsStatus?

    miniscore *= 1.5 if Rejuv && @attacker.isbossmon && [:NASTASIASDEOXYS].include?(@attacker.pokemon.bossID)

    if @move.pbIsStatus?
      if @opponent.pbNonActivePokemonCount > 2
        miniscore *= 0.2 * @opponent.pbNonActivePokemonCount
      else
        miniscore *= 0.2
      end
    end
    if @mondata.skill >= BESTSKILL
      if !@battle.pbIsWild?
        oppparty = getAIKnownParty(@opponent)
        movecheck = false
        abilitycheck = false
        for pkmn in oppparty
          movecheck = true if getAIMemoryNonBattler(@opponent, pkmn).any? { |moveloop| moveloop != nil && [:DEFOG, :RAPIDSPIN, :MORTALSPIN, :TIDYUP].include?(moveloop.move) }
          abilitycheck = true if pkmn.ability == :MAGICBOUNCE && pkmn.hp > 0
        end
        miniscore *= 0.3 if (movecheck || abilitycheck || checkAImovesAllOpponents([:DEFOG, :RAPIDSPIN, :MORTALSPIN, :TIDYUP])) && @move.pbIsStatus?
      end
    elsif @mondata.skill >= MEDIUMSKILL
      miniscore *= 0.3 if checkAImovesAllOpponents([:DEFOG, :RAPIDSPIN, :MORTALSPIN, :TIDYUP]) && @move.pbIsStatus?
    end
    return miniscore
  end

  def wastelandhazardcode(damage)
    specialscore = [(damage / @opponent.hp.to_f) * 100, 110].min
    specialscore *= 1.25 if @move.function == 0x104 && @opponent.pbCanPoison?(nil, nil) # Toxic Spikes
    # Wasteland hazard moves only deal damage at the end of the turn. If you can KO the opponent before they can move then you shouldn't use these
    specialscore *= 0.6 if hasgreatmoves() && pbAIfaster?()
    hazardremover = checkAImovesAllOpponents([:DEFOG, :RAPIDSPIN, :MORTALSPIN, :TIDYUP])
    specialscore *= 0.8 if hazardremover && pbAIfaster?(@move, nil, @attacker, hazardremover)
    if @move.pbIsStatus?
      specialscore *= 0.6 if checkAImovesAllOpponents([:MAGICCOAT])
      specialscore *= 0.6 if getAIKnownParty(@opponent).any? { |pkmn| pkmn.hp > 0 && pkmn.ability == :MAGICBOUNCE }
    end
    return specialscore
  end

  def electricterraincode
    return @move.pbIsDamaging? ? 1 : 0 if !@battle.canChangeFE?(:ELECTERRAIN)

    miniscore = 1.0
    if Overlays && @battle.FE != :INDOOR
      return @move.pbIsDamaging? ? 1 : 0 if @battle.OV == :ELECTERRAIN || @battle.FE == :FROZENDIMENSION
    else
      miniscore = getFieldDisruptScore(@attacker, @opponent)
    end
    miniscore *= 1.5 if @attacker.ability == :SURGESURFER
    miniscore *= 1.3 if @attacker.hasType?(:ELECTRIC)
    miniscore *= 1.5 if pbPartyHasType?(:ELECTRIC)
    miniscore *= 0.5 if @opponent.hasType?(:ELECTRIC)
    miniscore *= 0.5 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.function == 0x03 }
    miniscore *= 1.6 if checkAImoves(PBStuff::SLEEPMOVE)
    miniscore *= 2 if @mondata.attitemworks && @attacker.item == :AMPLIFIELDROCK
    case @attacker.pbPartner.ability
      when :SURGESURFER then miniscore *= dynamicspeedcode(:ELECTERRAIN, 2.0) unless @attacker.pbPartner.surgeSurferActive?
      when :QUICKFEET   then miniscore *= dynamicspeedcode(:ELECTERRAIN, 1.5) unless @attacker.pbPartner.quickFeetActive?
      when :QUARKDRIVE  then miniscore *= dynamicspeedcode(:ProtoDrivePartner, 1.5) if @attacker.pbPartner.effects[:Quarkdrive] == 0 && @attacker.pbPartner.getHighestStatWithStages == PBStats::SPEED
    end
    return miniscore
  end

  def grassyterraincode
    return @move.pbIsDamaging? ? 1 : 0 if !@battle.canChangeFE?(:GRASSY)

    if Overlays && @battle.FE != :INDOOR
      return @move.pbIsDamaging? ? 1 : 0 if @battle.OV == :GRASSY || @battle.FE == :FROZENDIMENSION

      miniscore = 1
      miniscore *= 1.5 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
      miniscore *= 1.5 if @attacker.hasType?(:GRASS)
      miniscore *= 2 if pbPartyHasType?(:GRASS)
      miniscore *= 0.5 if checkAIhealing()
      miniscore *= 1.5 if @attacker.ability == :GRASSPELT
      miniscore *= 2 if @mondata.attitemworks && @attacker.item == :AMPLIFIELDROCK
    else
      miniscore = getFieldDisruptScore(@attacker, @opponent)
      miniscore *= 1.5 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
      miniscore *= 1.5 if @attacker.hasType?(:FIRE)
      miniscore *= 1.5 if pbPartyHasType?(:FIRE)
      if @opponent.hasType?(:FIRE)
        miniscore *= 0.5
        miniscore *= 0.5 if @battle.weather != :RAINDANCE
        miniscore *= 0.5 if @attacker.hasType?(:GRASS)
      elsif @attacker.hasType?(:GRASS)
        miniscore *= 1.5
      end
      miniscore *= 2 if pbPartyHasType?(:GRASS)
      miniscore *= 0.5 if checkAIhealing()
      miniscore *= 0.5 if checkAImoves([:SLUDGEWAVE])
      miniscore *= 1.5 if @attacker.ability == :GRASSPELT
      miniscore *= 2 if @mondata.attitemworks && @attacker.item == :AMPLIFIELDROCK
    end
    return miniscore
  end

  def mistyterraincode
    return 0 if @battle.canChangeFE?(:MISTY)

    if Overlays && @battle.FE != :INDOOR
      return @move.pbIsDamaging? ? 1 : 0 if @battle.OV == :MISTY || @battle.FE == :FROZENDIMENSION

      miniscore = 1
      miniscore *= 2 if pbPartyHasType?(:FAIRY)
      miniscore *= 2 if !@attacker.hasType?(:FAIRY) && @opponent.hasType?(:DRAGON)
      miniscore *= 0.5 if @attacker.hasType?(:DRAGON)
      miniscore *= 0.5 if @opponent.hasType?(:FAIRY)
      miniscore *= 2 if @attacker.hasType?(:FAIRY) && @opponent.spatk > @opponent.attack
      miniscore *= 2 if @mondata.attitemworks && @attacker.item == :AMPLIFIELDROCK
    else
      miniscore = getFieldDisruptScore(@attacker, @opponent)
      miniscore *= 2 if pbPartyHasType?(:FAIRY)
      miniscore *= 2 if !@attacker.hasType?(:FAIRY) && @opponent.hasType?(:DRAGON)
      miniscore *= 0.5 if @attacker.hasType?(:DRAGON)
      miniscore *= 0.5 if @opponent.hasType?(:FAIRY)
      miniscore *= 2 if @attacker.hasType?(:FAIRY) && @opponent.spatk > @opponent.attack
      miniscore *= 2 if @mondata.attitemworks && @attacker.item == :AMPLIFIELDROCK
    end
    return miniscore
  end

  def pledgecode
    miniscore = 1.0
    pledge = @move.move
    if @battle.field.pledge && @battle.field.pledge != pledge
      previouspledge = @battle.field.pledge
      pledgepair = [pledge, previouspledge]
      newfield = getPledgeFieldFromPledgePair(pledgepair)
      if @battle.canChangeFE?(newfield)
        miniscore = getFieldDisruptScore(@attacker, @opponent)
        miniscore /= getFieldDisruptScore(@attacker, @opponent, newfield)
        return miniscore
      end
    end
    partnerpledge = [:GRASSPLEDGE, :FIREPLEDGE, :WATERPLEDGE].find { |move| move != pledge && @attacker.pbPartner.pbHasMove?(move) }
    if partnerpledge
      pledgepair = [pledge, partnerpledge]
      newfield = getPledgeFieldFromPledgePair(pledgepair)
      miniscore *= 1.5 if @battle.canChangeFE?(newfield)
    end
    return miniscore
  end

  def arocode(stat) # Used for Aromatic Mist (Partner targeting) + Flower Shield/Rototiller (AllBattlers targeting)
    return 0 unless scoringAgainstPartner? && @opponent.stages[stat] != 6 && @opponent.ability != :CONTRARY

    miniscore = 1.0
    newopp = @attacker.pbFirstOpposing
    miniscore *= newopp.spatk > newopp.attack ? 2 : 0.5 if stat == PBStats::SPDEF
    miniscore *= newopp.attack > newopp.spatk ? 2 : 0.5 if stat == PBStats::DEFENSE
    miniscore *= 1.3 if @initial_scores.length > 0 && hasbadmoves(20)
    miniscore *= 1.1 if @opponent.hp * (1.0 / @opponent.totalhp) > 0.75
    miniscore *= 0.3 if @opponent.effects[:Yawn] > 0 || @opponent.effects[:LeechSeed] >= 0 || @opponent.effects[:Attract] >= 0 || !@opponent.status.nil?
    if !@battle.pbIsWild?
      oppparty = getAIKnownParty(newopp)
      movecheck = false
      for pkmn in oppparty
        movecheck = true if getAIMemoryNonBattler(newopp, pkmn).any? { |moveloop| moveloop != nil && PBStuff::PHASEMOVE.include?(moveloop.move) }
      end
    end
    miniscore *= 0.2 if movecheck
    miniscore *= 2 if @opponent.ability == :SIMPLE
    miniscore *= 0.5 if newopp.ability == :UNAWARE
    miniscore *= 1.2 if hpGainPerTurn(@opponent) > 1
    miniscore *= 2 if @battle.FE == :MISTY && @move.function == 0x13A # Aromatic Mist (Flower Shield and Rototiller boosts are handled in their specific methods)
    return miniscore
  end

  def flowershieldcode(score)
    return 0 unless @battle.doublebattle && @opponent.hasType?(:GRASS) && scoringAgainstPartner? && @opponent.stages[PBStats::DEFENSE] != 6

    opp1 = @attacker.pbOppositeOpposing
    opp2 = opp1.pbPartner
    if !@battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5)
      score *= opp1.attack > opp1.spatk ? 2 : 0.5
      score *= opp2.attack > opp2.spatk ? 2 : 0.5
    else
      score *= 2
    end
    score += 30 if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 1, 4)
    if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5) || @battle.FE == :FAIRYTALE
      score += 20
      miniscore = 100
      miniscore *= 1.3 if @attacker.effects[:Substitute] > 0 || ((@attacker.effects[:Disguise] || (@attacker.effects[:IceFace] && (@opponent.attack > @opponent.spatk || @battle.FE == :FROZENDIMENSION))) && !moldBreakerCheck(@opponent, @attacker, nil, true))
      miniscore *= 1.3 if @initial_scores.length > 0 && hasbadmoves(20)
      miniscore *= 1.1 if @opponent.hp.to_f / @opponent.totalhp > 0.75
      miniscore *= 1.2 if opp1.effects[:HyperBeam] > 0
      miniscore *= 1.3 if opp1.effects[:Yawn] > 0
      miniscore *= 1.1 if [checkAIdamage(@opponent, opp1, getAIMemory(opp1)), checkAIdamage(@opponent, opp2, getAIMemory(opp2))].max < @opponent.hp * 0.3
      miniscore *= 1.1 if @opponent.turncount < 2
      miniscore *= 1.1 if !opp1.status.nil?
      miniscore *= 1.3 if (opp1.status == :SLEEP || opp1.status == :FROZEN) && @opponent.crested != :SUICUNE
      miniscore *= 1.5 if opp1.effects[:Encore] > 0 && opp1.moves[(opp1.effects[:EncoreIndex])].pbIsStatus?
      miniscore *= 0.5 if @opponent.effects[:Confusion] > 0
      miniscore *= 0.3 if @opponent.effects[:LeechSeed] >= 0 || @attacker.effects[:Attract] >= 0
      miniscore *= 0.2 if @opponent.effects[:Toxic] > 0
      miniscore *= 0.2 if checkAImoves(PBStuff::PHASEMOVE, getAIMemory(opp1))
      miniscore *= 2 if @opponent.ability == :SIMPLE
      miniscore *= 0.5 if opp1.ability == :UNAWARE
      miniscore *= 0.5 if opp1.hasType?(:GRASS)
      miniscore /= 100.0
      score *= miniscore
      miniscore = 100
      miniscore *= 1.5 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
      miniscore *= 1.2 if (@mondata.attitemworks && @attacker.item == :LEFTOVERS) || ((@mondata.attitemworks && @attacker.item == :BLACKSLUDGE) && @attacker.hasType?(:POISON))
      miniscore *= 1.7 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.isHealingMove? }
      miniscore *= 1.3 if @attacker.pbHasMove?(:LEECHSEED)
      miniscore *= 1.2 if @attacker.pbHasMove?(:PAINSPLIT)
      miniscore /= 100.0
      score *= miniscore if @attacker.stages[PBStats::SPDEF] != 6 && @attacker.stages[PBStats::DEFENSE] != 6
      score = 0 if @attacker.ability == :CONTRARY
    end
    return score
  end

  def rotocode(score)
    return 0 unless @battle.doublebattle && scoringAgainstPartner?
    return 0 if !(@battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5)) && (!@opponent.hasType?(:GRASS) || @opponent.isAirborne?)

    opp1 = @attacker.pbOppositeOpposing
    opp2 = opp1.pbPartner
    miniscore = 1.0
    if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5) && @attacker.hasType?(:GRASS) && !@attacker.isAirborne?
      score += 30
      miniscore *= selfstatboost([2, 0, 2, 0, 0, 0, 0])
    end
    if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN)
      score += 20
      miniscore *= 1.3 if @attacker.effects[:Substitute] > 0 || ((@attacker.effects[:Disguise] || (@attacker.effects[:IceFace] && (@opponent.attack > @opponent.spatk || @battle.FE == :FROZENDIMENSION))) && !moldBreakerCheck(@opponent, @attacker, nil, true))
      miniscore *= 1.3 if @initial_scores.length > 0 && hasbadmoves(20)
      miniscore *= 1.1 if @opponent.hp.to_f / @opponent.totalhp > 0.75
      miniscore *= 1.2 if opp1.effects[:HyperBeam] > 0
      miniscore *= 1.3 if opp1.effects[:Yawn] > 0
      miniscore *= 1.1 if [checkAIdamage(@opponent, opp1, getAIMemory(opp1)), checkAIdamage(@opponent, opp2, getAIMemory(opp2))].max < @opponent.hp * 0.25
      miniscore *= 1.1 if @opponent.turncount < 2
      miniscore *= 1.1 if !opp1.status.nil?
      miniscore *= 1.3 if (opp1.status == :SLEEP || opp1.status == :FROZEN) && @opponent.crested != :SUICUNE
      miniscore *= 1.5 if opp1.effects[:Encore] > 0 && opp1.moves[(opp1.effects[:EncoreIndex])].pbIsStatus?
      miniscore *= 0.2 if @opponent.effects[:Confusion] > 0
      miniscore *= 0.6 if @opponent.effects[:LeechSeed] >= 0 || @attacker.effects[:Attract] >= 0
      miniscore *= 0.5 if checkAImoves(PBStuff::PHASEMOVE, getAIMemory(opp1))
      miniscore *= 2   if @opponent.ability == :SIMPLE
      miniscore *= 0.5 if opp1.ability == :UNAWARE
      miniscore *= 0.5 if opp1.hasType?(:GRASS) && !opp1.isAirborne?
      miniscore *= 1 + 0.05 * @opponent.stages[PBStats::SPEED] if @opponent.stages[PBStats::SPEED] < 0
      ministat = @opponent.stages[PBStats::ATTACK] + @opponent.stages[PBStats::SPEED] + @opponent.stages[PBStats::SPATK]
      miniscore *= 1 - 0.05 * ministat if ministat > 0
      miniscore *= 1.3 if checkAIhealing()
      miniscore *= 1.5 if @attacker.pbSpeed > pbRoughStat(@opponent, PBStats::SPEED) && @battle.state.effects[:TrickRoom] == 0
      miniscore *= 1.3 if @mondata.roles.include?(:SWEEPER)
      miniscore *= 0.5 if @attacker.status == :PARALYSIS && @attacker.crested != :SUICUNE
      miniscore *= 0.3 if checkAImoves([:FOULPLAY], getAIMemory(opp1))
      miniscore *= 1.4 if @attacker.hp == @attacker.totalhp && (@mondata.attitemworks && @attacker.item == :FOCUSSASH)
      miniscore *= 0.4 if checkAIpriority(getAIMemory(opp1))
      score *= miniscore
    end
    return score
  end

  def craftyshieldcode
    miniscore = 1.0
    if @attacker.lastMoveUsed == :CRAFTYSHIELD
      miniscore *= 0.5
    else
      miniscore *= 2 if getAIMemory().length > 0 && getAIMemory().all? { |moveloop| moveloop != nil && moveloop.pbIsStatus? }
      miniscore *= 1.5 if @attacker.hp == @attacker.totalhp
    end
    return miniscore
  end

  def turvycode
    return @move.pbIsDamaging? ? 1 : 0 if statchangecounter(@opponent, 1, 7) == 0
    miniscore = [(1 + 0.10 * statchangecounter(@opponent, 1, 7)), 0].max
    redirector = nil
    rmove = [:FOLLOWME, :RAGEPOWDER, :ALLYSWTCH, :SPOTLIGHT].find { |rmove| redirector = checkAImovesAllOpponents([rmove]) }
    if !rmove
      baseval = 1.0
      baseval = 1.1 if statchangecounter(@opponent, 1, 7) >= 3
      baseval = 1.2 if statchangecounter(@opponent, 1, 7) >= 2 && @opponent.ability == :CONTRARY
      miniscore *= (baseval * statchangecounter(@opponent, 1, 7)) if statchangecounter(@opponent, 1, 7) >= 3 && [:CONTRARY, :MOXIE, :CHILLINGNEIGH, :ASONECHILLING, :SOULHEART, :GRIMNEIGH, :ASONEGRIM, :BEASTBOOST, :BATTLEBOND, :PRISMPOWER].include?(@opponent.ability)
    end
    miniscore = 2 - miniscore if scoringAgainstPartner?
    miniscore = 0 if (Rejuv && @attacker.species == :NIHILEGO && @attacker.form == 1 && scoringAgainstPartner?)
    return miniscore
  end

  def fairylockcode
    return 0 if @attacker.effects[:PerishSong] == 1 || @attacker.effects[:PerishSong] == 2

    miniscore = 1.0
    miniscore *= 10 if @opponent.effects[:PerishSong] == 2
    miniscore *= 20 if @opponent.effects[:PerishSong] == 1
    miniscore *= 0.8 if @attacker.effects[:LeechSeed] >= 0
    miniscore *= 1.2 if @opponent.effects[:LeechSeed] >= 0
    miniscore *= 1.3 if @opponent.effects[:Curse]
    miniscore *= 0.7 if @attacker.effects[:Curse]
    miniscore *= saltCureGood? ? 1.3 : 1.2 if @opponent.effects[:SaltCure]
    miniscore *= saltCureGood? ? 0.7 : 0.8 if @attacker.effects[:SaltCure]
    miniscore *= 1.1 if @opponent.effects[:Confusion] > 0
    miniscore *= 1.1 if @attacker.effects[:Confusion] > 0
    return miniscore
  end

  def flingcode
    return 0 if @attacker.item.nil? || !@mondata.attitemworks || @battle.pbIsUnlosableItem(@attacker, @attacker.item) || pbIsPokeBall?(@attacker.item) || pbIsTypeGem?(@attacker.item) || pbIsMail?(@attacker.item) || pbIsApricorn?(@attacker.item) || pbFlingDamage(attacker.item) == 0
    return 0 if [:LAXINCENSE, :CHOICESCARF, :CHOICEBAND, :CHOICESPECS, :SYNTHETICSEED, :TELLURICSEED, :ELEMENTALSEED, :MAGICALSEED, :EXPERTBELT, :FOCUSSASH, :LEFTOVERS, :MUSCLEBAND, :WISEGLASSES, :LIFEORB, :EVIOLITE, :ASSAULTVEST, :BLACKSLUDGE, :POWERHERB, :MENTALHERB, :WHITEHERB].include?(@attacker.item)

    miniscore = 1.0
    case @attacker.item
      when :POISONBARB then miniscore *= 1.2 if @opponent.pbCanPoison?(@attacker, @move) && ![:GUTS, :POISONHEAL, :TOXICBOOST, :QUICKFEET, :MARVELSCALE, :MAGICGUARD].include?(@opponent.ability) && @opponent.crested != :ZANGOOSE
      when :TOXICORB
        if @opponent.pbCanPoison?(@attacker, @move) && ![:GUTS, :POISONHEAL, :TOXICBOOST, :QUICKFEET, :MAGICGUARD].include?(@opponent.ability) && @opponent.crested != :ZANGOOSE
          miniscore *= 1.2
          miniscore *= 2 if @attacker.pbCanPoison?(@attacker, nil) && ![:GUTS, :POISONHEAL, :TOXICBOOST, :QUICKFEET, :MAGICGUARD].include?(@attacker.ability)
        end
      when :FLAMEORB
        if @opponent.pbCanBurn?(@attacker, @move) && ![:GUTS, :FLAREBOOST].include?(@opponent.ability)
          if pbRoughStat(@opponent, PBStats::ATTACK) > pbRoughStat(@opponent, PBStats::SPATK) && [:QUICKFEET, :MARVELSCALE, :MAGICGUARD].include?(@opponent.ability)
            miniscore *= 1.1
          elsif ![:QUICKFEET, :MARVELSCALE, :MAGICGUARD].include?(@opponent.ability)
            miniscore *= 1.3
          end
          miniscore *= 2 if @attacker.pbCanBurn?(@attacker, nil) && ![:GUTS, :FLAREBOOST, :QUICKFEET, :MARVELSCALE, :MAGICGUARD].include?(@attacker.ability)
        end
      when :LIGHTBALL
        if @opponent.pbCanParalyze?(@attacker, @move) && @opponent.ability != :QUICKFEET
          miniscore *= 1.3
          miniscore *= dynamicspeedcode(:opponentstatus, 2.0)
        end
      when :KINGSROCK, :RAZORCLAW then miniscore *= 1.3 if @opponent.ability != :INNERFOCUS && pbAIfaster?(@move)
      when :STICKYBARB then miniscore *= 1.2
      when :LAGGINGTAIL then miniscore *= 3
      when :IRONBALL then miniscore *= 1.5 if @battle.FE != :DEEPEARTH
    end
    if pbIsBerry?(@attacker.item)
      if [:FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY].include?(@attacker.item)
        miniscore *= 1.3 if @opponent.pbCanConfuse?(@opponent, nil)
      else
        miniscore *= 0
      end
    end
    return miniscore
  end

  def recyclecode
    return 0 if !@attacker.permeffs[:ItemRecycle]
    return 0 if (@opponent.ability == :MAGICIAN && @opponent.item.nil?) || checkAImoves([:KNOCKOFF, :THIEF, :COVET])
    return 0 if @attacker.ability == :UNBURDEN || @attacker.ability == :HARVEST || @attacker.pbHasMove?(:ACROBATICS)

    miniscore = 2.0
    miniscore *= 2 if @attacker.pbHasMove?(:NATURALGIFT)
    case @attacker.permeffs[:ItemRecycle]
      when :LUMBERRY
        miniscore *= 2 if !@attacker.status.nil?
      when :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY
        miniscore *= 1.6 if @attacker.hp < 0.66 * @attacker.totalhp
        miniscore *= 1.5 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
      when :MAGICALSEED
        case @battle.FE
        when :STARLIGHT
          miniscore *= wishcode()
          miniscore += selfstatboost([0, 0, 1, 0, 0, 0, 0])
        end
    end

    if !@attacker.item.nil? && pbIsBerry?(@attacker.permeffs[:ItemRecycle])
      miniscore *= 0 if aiCheckSideAbility(PBStuff::UnnerveAbilities, @opponent).any?
      miniscore *= 0 if checkAImoves([:INCINERATE, :PLUCK, :BUGBITE])
    end
    return miniscore
  end

  def embarcode(opponent = @opponent)
    return 0 if opponent.effects[:Embargo] > 0 || opponent.item.nil?

    miniscore = 1.1
    miniscore *= 1.1 if !opponent.item.nil? && pbIsBerry?(opponent.item)
    case opponent.item
      when :LAXINCENSE, :SYNTHETICSEED, :TELLURICSEED, :ELEMENTALSEED, :MAGICALSEED, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES, :LIFEORB, :EVIOLITE, :ASSAULTVEST
        miniscore *= 1.2
      when :LEFTOVERS, :BLACKSLUDGE
        miniscore *= 1.3
    end
    miniscore *= 1.4 if opponent.hp * 2 < opponent.totalhp
    miniscore *= itemchangedynamicspeedcode(:embargo) if opponent == @opponent
    return miniscore
  end

  def roastcode
    return 1 if !@opponent.item.nil? && !pbIsBerry?(@opponent.item) && !pbIsTypeGem?(@opponent.item) || @opponent.ability == :STICKYHOLD || @opponent.effects[:Substitute] > 0

    miniscore = 1.0
    miniscore *= 1.2 if !@opponent.item.nil? && pbIsBerry?(@opponent.item) && @opponent.item != :OCCABERRY
    miniscore *= 1.3 if [:LUMBERRY, :SITRUSBERRY, :PETAYABERRY, :LIECHIBERRY, :SALACBERRY, :CUSTAPBERRY].include?(@opponent.item)
    miniscore *= 1.4 if !@opponent.item.nil? && pbIsTypeGem?(@opponent.item)
    return miniscore
  end

  def nomcode
    return 1 if @opponent.effects[:Substitute] > 0 || (!@opponent.item.nil? && !pbIsBerry?(@opponent.item))

    miniscore = 1.0
    case @opponent.item
      when :LUMBERRY then miniscore *= 2 if !@attacker.status.nil?
      when :CHERIBERRY then miniscore *= 2 if @attacker.status == :PARALYSIS
      when :RAWSTBERRY then miniscore *= 2 if @attacker.status == :BURN
      when :PECHABERRY then miniscore *= 2 if @attacker.status == :POISON
      when :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY then miniscore *= 1.6 if @attacker.hp * (1.0 / @attacker.totalhp) < 0.66
      when :LIECHIBERRY then miniscore *= 1.5 if @attacker.attack > @attacker.spatk
      when :PETAYABERRY then miniscore *= 1.5 if @attacker.spatk > @attacker.attack
      when :CUSTAPBERRY, :SALACBERRY then miniscore *= pbAIfaster? ? 1.1 : 1.5
      else
        miniscore *= 1.1
    end
    return miniscore
  end

  def teaslurpcode
    miniscore = 1.0
    if !(@attacker.item.nil? || !pbIsBerry?(@attacker.item))
      case @attacker.item
        when :LUMBERRY then miniscore *= 2 if !@attacker.status.nil?
        when :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY then miniscore *= 1.6 if @attacker.hp * (1.0 / @attacker.totalhp) < 0.66
        when :LIECHIBERRY then miniscore *= 1.5 if @attacker.attack > @attacker.spatk
        when :PETAYABERRY then miniscore *= 1.5 if @attacker.spatk > @attacker.attack
        when :CUSTAPBERRY, :SALACBERRY then miniscore *= pbAIfaster? ? 1.1 : 1.5
        else
          miniscore *= 1.1
      end
    end
    return miniscore if @opponent.item.nil? || !pbIsBerry?(@opponent.item)

    case @opponent.item
      when :LUMBERRY then miniscore *= 0.5 if !@opponent.status.nil?
      when :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY then miniscore *= 0.65 if @opponent.hp * (1.0 / @opponent.totalhp) < 0.66
      when :LIECHIBERRY then miniscore *= 0.7 if @opponent.attack > @opponent.spatk
      when :PETAYABERRY then miniscore *= 0.7 if @opponent.spatk > @opponent.attack
      when :CUSTAPBERRY, :SALACBERRY then miniscore *= !pbAIfaster? ? 0.9 : 0.5
      else
        miniscore *= 0.9
    end
    return miniscore
  end

  def perishcode
    return 0 if @opponent.effects[:PerishSong] > 0
    return 4 if @opponent.pbNonActivePokemonCount == 0
    return 0 if @attacker.pbNonActivePokemonCount == 0

    miniscore = 1.0
    miniscore *= 1.5 if @attacker.pbHasMove?(:UTURN, :VOLTSWITCH, :PARTINGSHOT, :FLIPTURN, :SHEDTAIL)
    miniscore *= 3 if PBStuff::TRAPPINGABILITIESAI.include?(@attacker.ability) || (@attacker.ability == :MAGNETPULL && @opponent.hasType?(:STEEL)) || @opponent.effects[:MeanLook] >= 0
    miniscore *= 1.2 if @mondata.partyroles.any? { |role| role.include?(:SWEEPER) }
    miniscore *= 1.2 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.isHealingMove? }
    miniscore *= 1.2 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::PROTECTMOVE.include?(moveloop.move) } && ![:UNSEENFIST, :PIERCINGDRILL].include?(@opponent.ability)
    miniscore *= 1 - 0.05 * statchangecounter(@attacker, 1, 7)
    miniscore *= 1 + 0.05 * statchangecounter(@opponent, 1, 7)
    miniscore *= 0.5 if checkAImoves(PBStuff::PIVOTMOVE)
    miniscore *= 0.1 if (PBStuff::TRAPPINGABILITIESAI.include?(@opponent.ability) || (@opponent.ability == :MAGNETPULL && @attacker.hasType?(:STEEL)) || @attacker.effects[:MeanLook] >= 0) && !@attacker.pbHasMove?(:UTURN, :VOLTSWITCH, :PARTINGSHOT, :FLIPTURN, :SHEDTAIL)
    miniscore *= 1.5 if @mondata.partyroles.any? { |role| role.include?(:PIVOT) }
    return miniscore
  end

  def noLeechSeed(leechTarget)
    return true if leechTarget.effects[:LeechSeed] > -1
    return true if leechTarget.hasType?(:GRASS)
    return true if leechTarget.effects[:Substitute] > 0
    return true if leechTarget.ability == :LIQUIDOOZE
    return true if leechTarget.ability == :MAGICBOUNCE
    return true if leechTarget.effects[:MagicCoat] == true
    return true if leechTarget.hp == 0

    return false
  end

  def leechcode
    return 0 if noLeechSeed(@opponent)

    miniscore = 1.0
    miniscore *= 1.2 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL) || @mondata.roles.include?(:TANK)
    miniscore *= 1.3 if @attacker.effects[:Substitute] > 0
    miniscore *= 1.2 if hpGainPerTurn(@opponent) > 1 || (@mondata.attitemworks && @attacker.item == :BIGROOT) || @attacker.crested == :SHIINOTIC
    miniscore *= 1.2 if (@opponent.status == :PARALYSIS || @opponent.status == :SLEEP) && @opponent.crested != :SUICUNE
    miniscore *= 1.2 if @opponent.effects[:Confusion] > 0
    miniscore *= 1.2 if @opponent.effects[:Attract] >= 0
    miniscore *= 1.1 if (@opponent.status == :POISON || @opponent.status == :BURN) && @opponent.crested != :SUICUNE
    miniscore *= 0.2 if checkAImoves([:RAPIDSPIN, :MORTALSPIN] | PBStuff::PIVOTMOVE)
    if @opponent.hp == @opponent.totalhp
      miniscore *= 1.1
    else
      miniscore *= @opponent.hp * (1.0 / @opponent.totalhp)
    end
    miniscore *= 0.8 if @opponent.hp * 2 < @opponent.totalhp
    miniscore *= 0.2 if @opponent.hp * 4 < @opponent.totalhp
    if @initial_scores.length > 0
      miniscore *= 1.3 if hasbadmoves(40)
      miniscore *= 1.5 if hasbadmoves(20)
    end
    miniscore *= 1.2 if @attacker.moves.any? { |moveloop| moveloop != nil && PBStuff::PROTECTMOVE.include?(moveloop.move) } && ![:UNSEENFIST, :PIERCINGDRILL].include?(@opponent.ability)
    miniscore *= 1 + 0.05 * statchangecounter(@opponent, 1, 7, 1)
    return miniscore
  end

  def moveturnselectriccode(alltypes, damagemove)
    miniscore = 1.0
    maxnormal = alltypes ? checkAIbestMove().pbType(@attacker) == :NORMAL : true
    if pbAIfaster?(@move)
      miniscore *= 0.9
    elsif @attacker.ability == :MOTORDRIVE && maxnormal
      miniscore *= 1.5
    end
    miniscore *= 1.5 if (@attacker.ability == :LIGHTNINGROD || @attacker.ability == :VOLTABSORB) && @attacker.hp.to_f < 0.6 * @attacker.totalhp && maxnormal
    miniscore *= 1.1 if @attacker.hasType?(:GROUND)
    if @battle.doublebattle
      miniscore *= 1.2 if [:MOTORDRIVE, :LIGHTNINGROD, :VOLTABSORB].include?(@attacker.pbPartner.ability)
      miniscore *= 1.1 if @attacker.pbPartner.hasType?(:GROUND)
    end
    miniscore *= 0.5 if !maxnormal
    return miniscore
  end

  def bidecode
    miniscore = @attacker.hp * (1.0 / @attacker.totalhp)
    miniscore *= 0.5 if hasgreatmoves()
    miniscore *= 1.2 if notOHKO?(@opponent, @attacker, true)
    miniscore *= 0.2 if checkAIdamage() * 2 > @attacker.hp
    miniscore *= 0.7 if @attacker.hp * 3 < @attacker.totalhp
    miniscore *= 1.1 if (@mondata.attitemworks && @attacker.item == :LEFTOVERS) || ((@mondata.attitemworks && @attacker.item == :BLACKSLUDGE) && @attacker.hasType?(:POISON))
    miniscore *= 1.3 if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
    miniscore *= 1.3 if !pbAIfaster?()
    miniscore *= 0.5 if checkAImovesAllOpponents(PBStuff::SETUPMOVE)

    if getAIMemory().any? { |moveloop| moveloop != nil && moveloop.pbIsStatus? }
      miniscore *= 0.8
    elsif getAIMemory().length == 4
      miniscore *= 1.3
    end
    return miniscore
  end

  def rolloutcode
    miniscore = 1.0
    miniscore *= 1.1 if @opponent.pbNonActivePokemonCount == 0 || PBStuff::TRAPPINGABILITIESAI.include?(@attacker.ability) || (@attacker.ability == :MAGNETPULL && @opponent.hasType?(:STEEL)) || @opponent.effects[:MeanLook] >= 0
    miniscore *= 0.75 if @attacker.hp * (1.0 / @attacker.totalhp) < 0.75
    miniscore *= 1 + 0.05 * @attacker.stages[PBStats::ACCURACY] if @attacker.stages[PBStats::ACCURACY] < 0
    miniscore *= 1 + 0.05 * @attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK] < 0
    miniscore *= 1 - 0.05 * @opponent.stages[PBStats::EVASION] if @opponent.stages[PBStats::EVASION] > 0
    miniscore *= 0.8 if (@mondata.oppitemworks && @opponent.item == :LAXINCENSE) || (@mondata.oppitemworks && @opponent.item == :BRIGHTPOWDER)
    miniscore *= 0.8 if accuracyWeatherAbilityActive?(@opponent, @attacker)
    miniscore *= 0.5 if @attacker.status == :PARALYSIS && @attacker.crested != :SUICUNE
    miniscore *= 0.5 if @attacker.effects[:Confusion] > 0
    miniscore *= 0.5 if @attacker.effects[:Attract] >= 0
    miniscore *= 1 - (@opponent.pbNonActivePokemonCount * 0.05) if @opponent.pbNonActivePokemonCount > 1
    miniscore *= 1.2 if @attacker.effects[:DefenseCurl]
    miniscore *= 1.5 if checkAIdamage() * 3 < @attacker.hp && (getAIMemory().length > 0)
    miniscore += 4 if hasbadmoves(15)
    miniscore *= 0.8 if checkAImoves(PBStuff::PROTECTMOVE) && !@move.unseenFistCheck(@attacker)
    return miniscore
  end

  def outragecode(score)
    return 1.3 if @attacker.ability == :OWNTEMPO
    return 1.3 if @move.move == :RAGINGFURY && [:VOLCANIC, :VOLCANICTOP].include?(@battle.FE)

    miniscore = 1.0
    miniscore *= 0.85 if score < 100
    miniscore *= 1.3 if (@mondata.attitemworks && @attacker.item == :LUMBERRY) || (@mondata.attitemworks && @attacker.item == :PERSIMBERRY)
    miniscore *= 1 - 0.05 * @attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK] > 0
    miniscore *= 1 - 0.025 * (@battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))) if (@battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))) > 2
    miniscore *= 0.7 if checkAImoves(PBStuff::PROTECTMOVE) && !@move.unseenFistCheck(@attacker)
    miniscore *= 0.7 if checkAIhealing()
    return miniscore
  end

  def spectralthiefcode
    miniscore = 0.10 * statchangecounter(@opponent, 1, 7)
    miniscore *= (-1) if @attacker.ability == :CONTRARY
    miniscore *= 2 if @attacker.ability == :SIMPLE
    miniscore += 1
    miniscore *= 1.2 if @opponent.effects[:Substitute] > 0
    return miniscore
  end

  def stupidmovecode
    return 0 if pbAIfaster?()
    return 0 if @opponent.stages[PBStats::SPEED] == 0 && @attacker.stages[PBStats::SPEED] == 0

    miniscore = 1 + 0.1 * @opponent.stages[PBStats::SPEED] - 0.1 * @attacker.stages[PBStats::SPEED]
    miniscore *= 0.8 if @battle.doublebattle
    return miniscore
  end

  def spotlightcode
    return 0 if !@battle.doublebattle || !scoringAgainstPartner?

    miniscore = 1.0
    bestmove1 = checkAIbestMove(@attacker.pbOpposing1) # grab moves opposing mons are going to use
    bestmove2 = checkAIbestMove(@attacker.pbOpposing2)
    if [:FLASHFIRE, :WELLBAKEDBODY].include?(@opponent.ability) || @opponent.crested == :DRUDDIGON
      miniscore *= 3 if bestmove1.pbType(@attacker.pbOpposing1) == :FIRE || bestmove2.pbType(@attacker.pbOpposing2) == :FIRE
    elsif [:STORMDRAIN, :DRYSKIN, :WATERABSORB].include?(@opponent.ability)
      miniscore *= 3 if bestmove1.pbType(@attacker.pbOpposing1) == :WATER || bestmove2.pbType(@attacker.pbOpposing2) == :WATER
    elsif [:MOTORDRIVE, :LIGHTNINGROD, :VOLTABSORB].include?(@opponent.ability)
      miniscore *= 3 if bestmove1.pbType(@attacker.pbOpposing1) == :ELECTRIC || bestmove2.pbType(@attacker.pbOpposing2) == :ELECTRIC
    elsif @opponent.ability == :SAPSIPPER || @opponent.crested == :WHISCASH
      miniscore *= 3 if bestmove1.pbType(@attacker.pbOpposing1) == :GRASS || bestmove2.pbType(@attacker.pbOpposing2) == :GRASS
    elsif @opponent.ability == :EARTHEATER || @opponent.crested == :SKUNTANK
      miniscore *= 3 if bestmove1.pbType(@attacker.pbOpposing1) == :GROUND || bestmove2.pbType(@attacker.pbOpposing2) == :GROUND
    end
    if checkAImoves([:SPIKYSHIELD, :KINGSSHIELD, :BANEFULBUNKER, :OBSTRUCT, :SILKTRAP, :BURNINGBULWARK])
      miniscore *= 2 if [@attacker.pbOpposing1, @attacker.pbOpposing2].any? { |opp|
        bestmove = opp == @attacker.pbOpposing1 ? bestmove1 : bestmove2
        next opp.makesContact?(bestmove) && !opp.hasWorkingItem(:PROTECTIVEPADS)
      }
    end
    miniscore *= 2 if checkAImoves([:COUNTER, :MIRRORCOAT, :METALBURST, :COMEUPPANCE])
    miniscore *= 1.5 if !pbAIfaster?(nil, nil, @attacker, @attacker.pbOpposing1)
    miniscore *= 1.5 if !pbAIfaster?(nil, nil, @attacker, @attacker.pbOpposing2)
    return miniscore
  end

  def glaiverushcode
    return 1.0 if @attacker.hp < @attacker.totalhp * 0.25

    miniscore = 1.0
    miniscore *= 0.7 if (pbRoughDamage < @opponent.hp || notOHKO?(@attacker, @opponent, true, @move)) && pbAIfaster?()
    miniscore *= 0.7 if @opponent.pbPartner.hp > 0 && pbAIfaster?(nil, nil, @attacker, @opponent.pbPartner)
    return miniscore
  end

  def upperhandcode
    return 0 if aiCheckSideAbility(@battle.priorityBlockingAbilities, @attacker, @opponent, @attacker, nil, true, checkMoldBroken: true).any?
    unless (@battle.FE == :CHESS && @opponent.piece == :KING) || @opponent.galeWingsActive?
      return 0 if getAIMemory().none? { |move| upperHandWorks?(@attacker, @opponent, move) }
    end

    miniscore = 1.0
    # can have memory of fake out or first impression from previous switch in or omniscience
    miniscore *= 1.5 if @opponent.turncount == 0 && checkAImoves([:FAKEOUT]) && pbAIfaster?()
    miniscore *= 1.5 if @opponent.turncount == 0 && checkAImoves([:FIRSTIMPRESSION])
    oppbestmove = checkAIbestMove()
    miniscore *= 1.5 if upperHandWorks?(@attacker, @opponent, oppbestmove)
    if @battle.FE == :CHESS && @opponent.piece == :KING
      miniscore *= @opponent.pbNonActivePokemonCount == 0 ? 4 : 2
    end

    flinchscore = flinchcode()
    miniscore *= flinchscore
    if flinchscore > 1
      miniscore *= 3
      miniscore *= 0.7 if @battle.doublebattle
      miniscore *= 1.5 if (@attacker.pbPartner.pbHasMove?(:TRICKROOM) && @battle.state.effects[:TrickRoom] == 0) || (@attacker.pbPartner.pbHasMove?(:TAILWIND) && @attacker.pbOwnSide.effects[:Tailwind] == 0)
    end
    return miniscore
  end

  def allyswitchcode
    return 0 if @battle.pbGetOwner(@attacker.index) != @battle.pbGetOwner(@attacker.pbPartner.index)
    return 0 if Gen >= 9 && @attacker.effects[:AllySwitchRate] > 0

    miniscore = redirectioncode()
    return 0 if miniscore == 0

    miniscore *= 0.8 if getAIMemory().any? { |move| ignoresRedirection?(@move.move, move, @opponent, @attacker) }

    for target, fliptarget in [[@attacker, @attacker.pbPartner], [@attacker.pbPartner, @attacker]]
      bestmove, bestdmg = checkAIMovePlusDamage(@opponent, target)
      next if ignoresRedirection?(@move.move, bestmove, @opponent, @attacker)

      bestdmg = bestdmg / target.totalhp.to_f * 100
      flipdmg = pbRoughDamage(bestmove, @opponent, fliptarget)
      flipdmg = flipdmg / fliptarget.totalhp.to_f * 100
      next if flipdmg >= bestdmg

      miniscore *= case true
        when flipdmg == 0 then 2
        when flipdmg < bestdmg * 0.25 then 1.5
        when flipdmg < bestdmg * 0.5 then 1.3
        else 1.1
      end
    end

    if @battle.FE == :CHESS && !@attacker.pbOwnSide.effects[:Castled]
      miniscore *= selfstatboost([0, 1, 0, 1, 0, 0, 0])
      partner = @attacker.pbPartner
      if (partner.pbCanIncreaseStatStage?(PBStats::ATTACK, @attacker, @move) && partner.attack >= partner.spatk) ||
         (partner.pbCanIncreaseStatStage?(PBStats::SPATK, @attacker, @move) && partner.attack <= partner.spatk)
        miniscore *= partner.ability == :CONTRARY ? 0.5 : 1.5
      end
    end
    return miniscore
  end

  def dynamicspeedcode(speedChange, amount, hardSwitch = false)
    # speedChange is a symbol.
    #   :partnerstage represents a stage change for the battler's partner.
    #   :opponentstage represents a stage change for the opponent
    #   :opponentstatus represents a status being applied to the opponent that changes the speed order
    #   :grounding represents the opponent being grounded and now vulnerable to speedlowering effects from fields like new world
    #   :embargo represents embargo being applied to the opponent and removing their items speed raising effects
    #   :PSYTERRAIN, :ELECTERRAIN temporarily set Psychic Terrain/Electric Terrain
    #   :RAINDANCE, :SUNNYDAY, :SNOW, :HAIL, :SANDSTORM temporarily set the according weather
    #   :ProtoDrivePartner sets the partner's quarkdrive/protosynthesis effect to speed
    #   :itemgive gives attacker item to opponent
    #   :itemremove removes opponent's item
    #   :removeability removes opponent's ability
    # amount is a multiplier value or a stage difference, depending on what speedChange is.
    # hardSwitch is a flag used for switch-in score calculations.

    return 1 unless useDynamicSpeed
    # return 1 unless [:ACE, :SECOND, :SWEEPER, :STALLBREAKER, :SCREENER].intersect?(@aimondata[@attacker.pbPartner.index].roles)
    return 1 if @attacker.pbPartner.isFainted?

    miniscore = 1.0

    # also check initial moveorder
    # look into how to update bestmove method to account for priority at some point
    # so this initial likelymoves array among others can become more accurate
    likelymoves = [nil, nil, nil, nil]
    likelymoves[@attacker.index] = @move
    initial_move_order = pbMoveOrderAI(likelymoves) # if opponent partner is fainted, it will be at the end of the order array

    # check initial speeds
    attackerFaster = initial_move_order.index(@attacker.index) < initial_move_order.index(@opponent.index)
    opponentFaster = initial_move_order.index(@opponent.index) < initial_move_order.index(@attacker.pbPartner.index)
    opponentPartnerAlive = !@opponent.pbPartner.isFainted?
    opponentPartnerFaster = opponentPartnerAlive && initial_move_order.index(@opponent.pbPartner.index) < initial_move_order.index(@attacker.pbPartner.index)

    # now create cloned battlers for the new speedchecks
    attackerClone = pbCloneBattler(@attacker.index)
    partnerClone = pbCloneBattler(@attacker.pbPartner.index)
    opponentClone = pbCloneBattler(@opponent.index)
    opponentpartnerClone = opponentPartnerAlive ? pbCloneBattler(@opponent.pbPartner.index) : @opponent.pbPartner.clone # even if fainted, object needed for new move order calc at the end

    # check if the move hits more than just the opponent object, and can also drop their stats
    hitOppPartner, hitAttPartner = false, false
    if opponentPartnerAlive && [:AllOpposing, :DragonDarts, :AllNonUsers].include?(@attacker.pbTarget(@move))
      hitOppPartner = true if !pbTypeModNoMessages(@move.pbType(attackerClone), attackerClone, opponentpartnerClone, @move).immune? && moveSuccessful?(@move, attackerClone, opponentpartnerClone) && !(([:CLEARBODY, :WHITESMOKE].include?(opponentpartnerClone.ability) && !moldBreakerCheck(attackerClone, opponentpartnerClone, @move)) || opponentpartnerClone.hasWorkingItem(:CLEARAMULET))
    end
    if [:AllNonUsers].include?(@attacker.pbTarget(@move))
      hitAttPartner = true if !pbTypeModNoMessages(@move.pbType(attackerClone), attackerClone, partnerClone, @move).immune? && moveSuccessful?(@move, attackerClone, partnerClone) && !(([:CLEARBODY, :WHITESMOKE].include?(partnerClone.ability) && !moldBreakerCheck(attackerClone, partnerClone, @move)) || partnerClone.hasWorkingItem(:CLEARAMULET))
    end

    # effect checks
    tailwindside = @attacker.pbOwnSide.effects[:Tailwind]
    initialweather = @battle.weather
    initialfield = @battle.field.effect
    initialoverlay = @battle.field.overlay

    stagescore = amount
    case speedChange
    when :partnerstage
      stage = partnerClone.stages[PBStats::SPEED] + 6
      stagescore = PBStats::StageMul[stage + amount] / PBStats::StageMul[stage]
      partnerClone.stages[PBStats::SPEED] += amount

    when :opponentstage
      stage = opponentClone.stages[PBStats::SPEED] + 6
      stagescore = PBStats::StageMul[stage] / PBStats::StageMul[stage + amount]
      opponentClone.stages[PBStats::SPEED] += amount
      if hitOppPartner
        opponentpartnerClone.stages[PBStats::SPEED] += opponentpartnerClone.ability == :CONTRARY ? -amount : amount
      end
      if hitAttPartner
        partnerClone.stages[PBStats::SPEED] += partnerClone.ability == :CONTRARY ? -amount : amount
      end

    when :opponentstatus
      opponentClone.status = :PARALYSIS
    when :grounding
      opponentClone.effects[:SmackDown] = true
    when :embargo
      opponentClone.effects[:Embargo] = 5
    when :itemremove
      opponentClone.item = nil
    when :ProtoDrivePartner
      effect = partnerClone.ability == :QUARKDRIVE ? :Quarkdrive : :Protosynthesis
      partnerClone.effects[effect][0] = PBStats::SPEED
    when :itemgive
      opponentClone.item = attackerClone.item
    when :PSYTERRAIN, :ELECTERRAIN
      Overlays ? @battle.field.overlay = speedChange : @battle.field.effect = speedChange
    when :SUNNYDAY, :RAINDANCE, :SANDSTORM, :HAIL, :SNOW
      @battle.weather = speedChange
      if hardSwitch
        oppscore1 = opponentFaster ? amount : 1.0
        oppscore2 = opponentPartnerFaster ? amount : 1.0
        stagescore = Math.sqrt(oppscore1 ** 2 + oppscore2 ** 2)
      end
    when :tailwind
      attackerClone.pbOwnSide.effects[:Tailwind] = 2
    when :removeability
      opponentClone.ability = nil
    end

    clones_by_index_order = [attackerClone, opponentClone, partnerClone, opponentpartnerClone].sort_by { |clone| clone.index }

    new_move_order = pbMoveOrderAI(likelymoves, clones_by_index_order) # if opponent partner is fainted, it will be at the end of the order array
    ideal_move_order = [[attackerClone.index, partnerClone.index, opponentClone.index, opponentpartnerClone.index], [attackerClone.index, partnerClone.index, opponentpartnerClone.index, opponentClone.index]]

    partnerFasterAfter = new_move_order.index(partnerClone.index) < new_move_order.index(opponent.index)
    miniscore = stagescore if attackerFaster && opponentFaster && partnerFasterAfter
    miniscore *= 1.2 if ideal_move_order.include?(new_move_order) && new_move_order != initial_move_order

    # reset conditions
    @attacker.pbOwnSide.effects[:Tailwind] = tailwindside
    @battle.weather = initialweather
    @battle.field.effect = initialfield
    @battle.field.overlay = initialoverlay

    return miniscore
  end

  ######################################################
  # Utility functions
  ######################################################

  # When targetmon is provided, returns an array containing role symbols for it
  # Otherwise returns an array of arrays each containing role symbols, for the whole party (accessed using @mondata.party, which is an array of pokemon objects)
  # targetmon may be a battler object or a pokemon object
  def pbGetMonRoles(targetmon = nil)
    allMonRoles = []
    allMons = targetmon ? [targetmon] : @mondata.party
    for mon in allMons
      monRoles = []
      healingmove = false
      curemove = false
      wishmove = false
      phasemove = false
      pivotmove = false
      spinmove = false
      batonmove = false
      screenmove = false
      tauntmove = false
      restmove = false
      weathermove = false
      hazardmove = false
      fieldmove = false
      movelist = []
      mon.moves.compact.each { |i| movelist.push(i.move) }
      party = @mondata.party
      partyNoAce = party[0..-2]
      partyIndex = mon.is_a?(PokeBattle_Battler) ? mon.pokemonIndex : party.index(mon)
      singleTrainer = @battle.pbParty(@mondata.index).length == 1
      monRoles.push(:LEAD) if partyIndex == 0 || (partyIndex == 1 && @battle.doublebattle && singleTrainer)
      monRoles.push(:ACE) if partyIndex == getAceIndex(@mondata.index)
      monRoles.push(:SECOND) if partyNoAce.compact.all? { |i| mon.level >= i.level }
      for i in movelist
        healingmove = true if $cache.moves[i]&.checkFlag?(:healingmove)
        curemove = true if [:HEALBELL, :AROMATHERAPY].include?(i)
        wishmove = true if i == :WISH
        phasemove = true if PBStuff::PHASEMOVE.include?(i)
        pivotmove = true if PBStuff::PIVOTMOVE.include?(i)
        spinmove = true if [:RAPIDSPIN, :MORTALSPIN].include?(i)
        hazardcleanmove = true if [:DEFOG, :TIDYUP].include?(i)
        batonmove = true if i == :BATONPASS
        screenmove = true if PBStuff::SCREENMOVE.include?(i)
        tauntmove = true if i == :TAUNT
        hazardmove = true if PBStuff::HAZARDMOVEALL.include?(i)
        healblockmove = true if i == :HEALBLOCK
        restmove = true if i == :REST
        weathermove = true if PBStuff::WEATHERMOVE.include?(i)
        fieldmove = true if [*PBStuff::TERRAINMOVE, :MIST, :IONDELUGE, :TOPSYTURVY].include?(i)
      end
      monRoles.push(:SWEEPER) if mon.ev[PBStats::SPEED] > 251 && ([:MODEST, :JOLLY, :TIMID, :ADAMANT].include?(mon.nature) || [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(mon.item) || mon.ability == :GORILLATACTICS)
      monRoles.push(:TRICKROOMSWEEPER) if (mon.ev[PBStats::SPEED] == 0 && mon.iv[PBStats::SPEED] == 0 && [:BRAVE, :QUIET].include?(mon.nature))
      monRoles.push(:PHYSICALWALL) if healingmove && (mon.ev[PBStats::DEFENSE] > 251 && [:BOLD, :RELAXED, :IMPISH, :LAX].include?(mon.nature))
      monRoles.push(:SPECIALWALL) if healingmove && (mon.ev[PBStats::SPDEF] > 251 && [:CALM, :GENTLE, :SASSY, :CAREFUL].include?(mon.nature))
      monRoles.push(:CLERIC) if curemove || (wishmove && mon.ev[PBStats::HP] > 251)
      monRoles.push(:PHAZER) if phasemove
      monRoles.push(:SCREENER) if screenmove && mon.item == :LIGHTCLAY
      monRoles.push(:PIVOT) if (pivotmove && healingmove) || (mon.ability == :REGENERATOR && mon.status != :PETRIFIED)
      monRoles.push(:SPINNER) if spinmove
      monRoles.push(:HAZARDSETTER) if hazardmove
      monRoles.push(:HAZARDCLEANER) if hazardcleanmove
      monRoles.push(:TANK) if (mon.ev[PBStats::HP] > 251 && !healingmove) || mon.item == :ASSAULTVEST
      monRoles.push(:BATONPASSER) if batonmove
      monRoles.push(:STALLBREAKER) if tauntmove || healblockmove || [:CHOICEBAND, :CHOICESPECS].include?(mon.item) || mon.ability == :GORILLATACTICS
      monRoles.push(:STATUSABSORBER) if restmove || [:TOXICORB, :FLAMEORB].include?(mon.item) || [:COMATOSE, :GUTS, :QUICKFEET, :FLAREBOOST, :TOXICBOOST, :NATURALCURE, :MAGICGUARD, :MAGICBOUNCE, :GOODASGOLD].include?(mon.ability) || (mon.species == :ZANGOOSE && mon.item == :ZANGCREST)
      monRoles.push(:TRAPPER) if PBStuff::TRAPPINGABILITIES.include?(mon.ability)
      monRoles.push(:WEATHERSETTER) if weathermove || [:DROUGHT, :SANDSPIT, :SANDSTREAM, :DRIZZLE, :SNOWWARNING, :HAILWARNING, :PRIMORDIALSEA, :DESOLATELAND, :DELTASTREAM].include?(mon.ability)
      monRoles.push(:FIELDSETTER) if fieldmove || [:GRASSYSURGE, :ELECTRICSURGE, :MISTYSURGE, :PSYCHICSURGE, :DARKSURGE, :SEEDSOWER].include?(mon.ability) || mon.item == :AMPLIFIELDROCK
      allMonRoles.push(monRoles)
    end
    return targetmon ? allMonRoles[0] : allMonRoles
  end

  def pbMakeFakeBattler(pokemon, partyindex, batonpass = false, index = @index)
    return nil if pokemon.nil?

    pokemonclone = pokemon.clone
    battler = PokeBattle_Battler.new(@battle, index, true)
    battler.pbInitPokemon(pokemonclone, partyindex)
    battler.pbInitEffects(batonpass: batonpass, fakebattler: true)
    battler.pbInitBoss(pokemonclone, partyindex) if battler.isbossmon
    battler.originalpokemon = pokemon # only for accessing permanenteffects
    return battler
  end

  # AI attempts to predict whether dragon darts hits one or two targets
  def pbDragonDartTargetting(attacker, move, basemove)
    opp1 = attacker.pbOpposing1
    opp2 = attacker.pbOpposing2
    return [opp1] if !@battle.doublebattle
    return [opp1] if opp2.isFainted?
    return [opp2] if opp1.isFainted?
    targets = []
    targets.push(opp1) if isValidDragonDartsTarget(attacker, opp1, move, basemove)
    targets.push(opp2) if isValidDragonDartsTarget(attacker, opp2, move, basemove)

    return targets
  end

  def isValidDragonDartsTarget(attacker, opponent, move, basemove)
    darttype = move.pbType(attacker)
    typemod = move.pbCalcTypeMod(darttype, attacker, opponent)
    types = [darttype, *move.getSecondaryType(attacker, darttype)]
    skill = @mondata.skill

    # remove target from list if partner successfully redirects
    unless [:STALWART, :PROPELLERTAIL].include?(attacker.ability)
      return false if opponent.pbPartner.effects[:RagePowder] && !attacker.powderImmune?
      return false if opponent.pbPartner.effects[:FollowMe]

      unless [:MOLDBREAKER, :TERAVOLT, :TURBOBLAZE].include?(attacker.ability)
        # if the attack is redirected by Lightning Rod or Storm Drain the attack will fail entirely, we can stop checking if either mon has it and the attacker can't ignore it
        return false if types.include?(:WATER) && (opponent.ability == :STORMDRAIN || opponent.pbPartner.ability == :STORMDRAIN)
        return false if types.include?(:ELECTRIC) && (opponent.ability == :LIGHTNINGROD || opponent.pbPartner.ability == :LIGHTNINGROD)
      end
    end

    unless [:NOGUARD, :HOTSHOT, :DEFRAGMENT].include?(attacker.ability) || [:NOGUARD, :HOTSHOT].include?(opponent.ability) || (attacker.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE) || attacker.effects[:LockOnTarget] == opponent.index
      return false if opponent.isSemiInvul?
    end
    return false if opponent.effects[:Commander]
    return false if opponent.effects[:Protect] # no unseen fist check, dragon darts isn't contact and can't be made contact to my knowledge, come back if a move can turn into contact
    return false if typemod.immune?

    if ![:MOLDBREAKER, :TERAVOLT, :TURBOBLAZE].include?(attacker.ability) && skill >= MEDIUMSKILL
      # checking Storm drain and lightning rod as immunity here so that Stalwart and Propeller tail users avoid targeting into these mons directly
      # users without redirection immunity don't reach this point in the check
      return false if opponent.ability == :WONDERGUARD && !typemod.superEffective?
      return false if types.include?(:WATER) && [:DRYSKIN, :WATERABSORB, :STORMDRAIN].include?(opponent.ability)
      return false if types.include?(:ELECTRIC) && [:MOTORDRIVE, :VOLTABSORB, :LIGHTNINGROD].include?(opponent.ability)
      return false if types.include?(:FIRE) && opponent.ability == :WELLBAKEDBODY
      return false if types.include?(:FIRE) && opponent.ability == :FLASHFIRE && @battle.FE != :FROZENDIMENSION
      return false if types.include?(:ROCK) && opponent.ability == :COALFURNACE
      return false if types.include?(:FIRE) && opponent.ability == :MAGMAARMOR && [:VOLCANICTOP, :DRAGONSDEN, :INFERNAL].include?(@battle.FE)
      return false if types.include?(:GRASS) && opponent.ability == :SAPSIPPER
      return false if types.include?(:GROUND) && opponent.ability == :EARTHEATER
      return false if types.include?(:GHOST) && opponent.ability == :SOULEATER
      return false if types.include?(:DARK) && opponent.ability == :SOULEATER && [:DIMENSIONAL, :INFERNAL].include?(@battle.FE)
    end

    if Rejuv && @battle.FE == :GLITCH && opponent.species == :GENESECT && skill >= HIGHSKILL
      return false if types.include?(:WATER) && opponent.hasWorkingItem(:DOUSEDRIVE)
      return false if types.include?(:ELECTRIC) && opponent.hasWorkingItem(:SHOCKDRIVE)
      return false if types.include?(:FIRE) && opponent.hasWorkingItem(:BURNDRIVE)
      return false if types.include?(:ICE) && opponent.hasWorkingItem(:CHILLDRIVE)
    end
    if skill >= HIGHSKILL
      return false if types.include?(:FIRE) && opponent.crested == :DRUDDIGON
      return false if types.include?(:GRASS) && opponent.crested == :WHISCASH
      return false if types.include?(:GROUND) && opponent.crested == :SKUNTANK
    end
    return false if types.include?(:GROUND) && opponent.isAirborne?(moldbreakcheck: true)
    return false if types.include?(:WATER) && Rejuv && @battle.FE == :DESERT && (opponent.hasType?(:GRASS) || opponent.hasType?(:WATER)) && @battle.pbWeather(attacker) == :SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA)

    # If dragon darts is being called by a caller move it will become subject to priority immunity when used with prankster, particularly dark type prankster immunity
    return false if !moveSuccessful?(basemove, attacker, opponent)

    return true
  end

  def pbSereneGraceCheck(miniscore)
    miniscore -= 1
    if @move.effect != 100
      addedeffect = @move.effect.to_f
      addedeffect *= 2 if @attacker.ability == :SERENEGRACE || @battle.FE == :RAINBOW || @battle.OV == :RAINBOW
      addedeffect *= 2 if !@move.canFlinch? && @attacker.ability == :SERENEGRACE && (@battle.FE == :RAINBOW || @battle.OV == :RAINBOW)
      addedeffect = 100 if addedeffect > 100
      miniscore *= addedeffect / 100.0
    end
    miniscore += 1
    return miniscore
  end

  def pbReduceWhenKills(miniscore)
    return miniscore if @initial_scores[@score_index] < 100

    return Math.sqrt(miniscore)
  end

  def statchangecounter(mon, initial, final, limiter = 0)
    count = 0
    case limiter
      when 0 # all stats
        for i in initial..final
          count += mon.stages[i]
         end
      when 1 # increases only
        for i in initial..final
          count += mon.stages[i] if mon.stages[i] > 0
         end
      when -1 # decreases only
        for i in initial..final
          count += mon.stages[i] if mon.stages[i] < 0
         end
    end
    return count
  end

  def hasgreatmoves(ignoreOthers: false)
    # slight variance in precision based on trainer skill
    threshold = 100
    # threshold = 105 if @mondata.skill>=HIGHSKILL
    # threshold = 110 if @mondata.skill>=BESTSKILL
    for monindex in 0...@battle.battlers.length # Check all options
      next unless @attacker.pbIsOpposing?(monindex) # skip scores against partner
      next if ignoreOthers && monindex != @opponent.index

      initialscores = @mondata.roughdamagearray[monindex]
      otherscores = initialscores.filter.with_index { |s, i| i != @score_index } # skip current move being scored
      return true if otherscores.any? { |s| s >= threshold }
    end
    return false
  end

  def hasbadmoves(threshold)
    for monindex in 0...@battle.battlers.length # Check all options
      next unless @attacker.pbIsOpposing?(monindex) # skip scores against partner

      initialscores = @mondata.roughdamagearray[monindex]
      otherscores = initialscores.filter.with_index { |s, i| i != @score_index } # skip current move being scored
      return false if otherscores.any? { |s| s > threshold }
    end
    return true
  end

  def getStatusDamage
    ret = PBStuff::STATUSDAMAGE[@move.move] ? PBStuff::STATUSDAMAGE[@move.move] : 0
    if @battle.state.effects[:Gravity] != 0
      if PBStuff::SLEEPMOVE.include?(@move.move)
        ret = PBStuff::STATUSDAMAGE[:RAGEPOWDER] if ret < PBStuff::STATUSDAMAGE[:RAGEPOWDER]
      end
    else
      case @move.move
      when PBStuff::SLEEPMOVE.include?(@move.move)
      when :GRASSWHISTLE
        ret = PBStuff::STATUSDAMAGE[:RAGEPOWDER] if [:BEWITCHED, :GRASSY].include?(@battle.FE)
      when :SLEEPPOWDER
        ret = PBStuff::STATUSDAMAGE[:RAGEPOWDER] if [:CORROSIVE, :GRASSY].include?(@battle.FE)
      when :SING
        ret = PBStuff::STATUSDAMAGE[:RAGEPOWDER] if [:BIGTOP].include?(@battle.FE)
      end
    end
    if @move.zmove && @basemove.move == @move.move # eg, focus energy when called by z-nature power is not gonna have its z-power effect
      ret *= 2 if PBStuff::CALLERMOVE.include?(@move.move)
      effect = ZSTATUSEFFECTS[@move.move]
      effect = [:heal] if @move.move == :CURSE && @attacker.hasType?(:GHOST)
      if effect.length == 2
        ret += effect[1] * 5
      elsif effect[0] == :allstat1
        ret += PBStuff::STATUSDAMAGE[:NORETREAT] + 5
      elsif effect[0] == :crit1
        ret += PBStuff::STATUSDAMAGE[:FOCUSENERGY]
      elsif effect[0] == :reset
        ret += PBStuff::STATUSDAMAGE[:HAZE] / 2
      elsif effect[0] == :heal
        ret += PBStuff::STATUSDAMAGE[:RECOVER] * 2
      elsif effect[0] == :heal2
        ret += PBStuff::STATUSDAMAGE[:HEALINGWISH]
      elsif effect[0] == :centre
        ret += PBStuff::STATUSDAMAGE[:FOLLOWME]
      end
    end
    return ret
  end

  def pbRoughStat(battler, stat)
    return battler.pbSpeed if @mondata.skill >= HIGHSKILL && stat == PBStats::SPEED

    stage = battler.stages[stat] + 6
    value = 0
    value = battler.attack if stat == PBStats::ATTACK
    value = battler.defense if stat == PBStats::DEFENSE
    value = battler.speed if stat == PBStats::SPEED
    value = battler.spatk if stat == PBStats::SPATK
    value = battler.spdef if stat == PBStats::SPDEF
    return (value * PBStats::StageMul[stage]).floor
  end

  def pbRoughAccuracy(move, attacker, opponent) # Roughly corresponds to pbAccuracyCheck and pbCalcAccuracy from Battle_Move
    # Perfect accuracy conditions
    return 100 if move.tradePowerForAcc?
    return 100 if [:NOGUARD, :HOTSHOT, :DEFRAGMENT].include?(attacker.ability) || [:NOGUARD, :HOTSHOT].include?(opponent.ability) ||
    (attacker.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE && @mondata.skill >= MEDIUMSKILL) ||  (attacker.ability == :DARKAURA && @battle.FE == :DEUXFINALIS && @mondata.skill >= MEDIUMSKILL)
    return 100 if @mondata.skill >= MEDIUMSKILL && attacker.effects[:LockOnTarget] == opponent.index
    return 100 if @mondata.skill >= HIGHSKILL && opponent.effects[:GlaiveRush] && getAIMemory(opponent).all? { |oppmove| pbAIfaster?(move, oppmove, attacker, opponent) }
    if move.function != 0x70 # OHKO moves
      return 100 if @mondata.skill >= MEDIUMSKILL && opponent.effects[:Telekinesis] > 0
      return 100 if @mondata.skill >= HIGHSKILL && opponent.effects[:Minimize] && move.antiMinimize?
      return 100 if @mondata.skill >= MEDIUMSKILL && @battle.FE == :UNDERWATER && move.pbType(attacker) == :ELECTRIC
    end

    # Base accuracy + Move-specific modifications
    baseaccuracy = move.accuracy
    if @mondata.skill >= MEDIUMSKILL
      baseaccuracy = move.pbBaseAccuracy(move.accuracy, attacker, opponent)
    end
    # If an effect makes the move perfectly accurate, no need to apply field mods
    # Examples: Blizzard on Glitch + Snow, Toxic on Corromist by poison type.
    return 100 if baseaccuracy == 0

    # Field modifications
    if @mondata.skill >= BESTSKILL
      fieldmovedata = @battle.field.moveData(move.move)
      baseaccuracy = fieldmovedata[:accmod] if fieldmovedata && fieldmovedata[:accmod]
    end
    baseaccuracy = 100 if move.function == 0x111 # Future Sight/Doom Desire
    # Future Sight/Doom Desire are set to 0 accuracy to bypass accuracy when using the move
    # Their move dummies which are used when executing the move have 100 accuracy as normal
    return 100 if baseaccuracy == 0

    # Wonder Skin
    if @mondata.skill >= BESTSKILL
      if move.pbIsStatus? && (opponent.ability == :WONDERSKIN || (Rejuv && @battle.FE == :PSYTERRAIN && opponent.ability == :MAGICIAN)) && !moldBreakerCheck(attacker, opponent, move)
        return 0 if opponent.ability == :WONDERSKIN && @battle.FE == :RAINBOW
        baseaccuracy = 50 if baseaccuracy > 50
      end
    end

    # Mirror miss reflect
    if @mondata.skill >= HIGHSKILL
      return 100 if @battle.FE == :MIRROR && (attacker.pbTarget(move) == :SingleNonUser || move.move == :MIRRORCOAT) && !attacker.makesContact?(move) && move.pbIsSpecial?(attacker) && opponent.stages[PBStats::EVASION] > 0 && move.function != 0x70 # OHKO moves (Sheer Cold)
    end

    return baseaccuracy if move.function == 0x70 # OHKO moves

    accmult, stagemult, miclemult = [], 1.0, []

    # Ashen Beach acc/eva bypass
    if @mondata.skill >= BESTSKILL
      if @battle.FE == :ASHENBEACH && [:OWNTEMPO, :INNERFOCUS, :PUREPOWER, :SANDVEIL, :STALWART, :STEADFAST].include?(attacker.ability) && !PBStuff::UnnerveAbilities.include?(opponent.ability)
        return pbCalcFinalAccuracy(baseaccuracy, accmult, stagemult, miclemult)
      end
    end

    # Accuracy modifiers
    accmult.append(1.67) if @battle.state.effects[:Gravity] != 0
    if @mondata.skill >= BESTSKILL
      accmult.append(0.5) if opponent.ability == :TANGLEDFEET && opponent.effects[:Confusion] > 0 && !moldBreakerCheck(attacker, opponent, move)
    end
    if @mondata.skill >= HIGHSKILL
      accmult.append([:BACKALLEY, :CITY].include?(@battle.FE) ? 0.67 : 0.8) if attacker.ability == :HUSTLE && move.pbIsPhysical?(attacker, move.pbType(attacker))
    end
    if @mondata.skill >= BESTSKILL
      accmult.append(0.8) if opponent.ability == :SANDVEIL && (@battle.pbWeather(attacker) == :SANDSTORM || [:DESERT, :ASHENBEACH].include?(@battle.FE)) && !moldBreakerCheck(attacker, opponent, move)
      accmult.append(0.8) if opponent.ability == :SNOWCLOAK && ([:HAIL, :SNOW].include?(@battle.pbWeather(attacker)) || [:ICY, :SNOWYMOUNTAIN].include?(@battle.FE)) && !moldBreakerCheck(attacker, opponent, move)
    end
    if @mondata.skill >= HIGHSKILL
      accmult.append(1.1) if attacker.pbPartner.ability == :VICTORYSTAR
    end
    if @mondata.skill >= MEDIUMSKILL
      accmult.append(1.1) if attacker.ability == :VICTORYSTAR
      accmult.append(1.3) if attacker.ability == :COMPOUNDEYES
    end
    if @mondata.skill >= BESTSKILL
      accmult.append(0.9) if attacker.ability == :LONGREACH && (@battle.FE == :ROCKY || (!Rejuv && @battle.FE == :FOREST))
    end
    if @mondata.skill >= HIGHSKILL
      accmult.append(0.9) if opponent.hasWorkingItem(:BRIGHTPOWDER)
      accmult.append(0.9) if opponent.hasWorkingItem(:LAXINCENSE)
    end
    if @mondata.skill >= MEDIUMSKILL
      accmult.append(1.1) if attacker.hasWorkingItem(:WIDELENS)
      accmult.append(1.2) if attacker.hasWorkingItem(:ZOOMLENS) && !pbAIfaster?(move, nil, attacker, opponent)
      accmult.append(1.5) if [:HYPNO, :STANTLER, :WYRDEER].include?(attacker.crested)
    end

    # Accuracy/Evasion stages
    accstage = attacker.stages[PBStats::ACCURACY]
    accstage = 0 if opponent.ability == :UNAWARE && !moldBreakerCheck(attacker, opponent, move)
    evastage = opponent.stages[PBStats::EVASION]
    evastage = 0 if opponent.effects[:Foresight] || opponent.effects[:MiracleEye] ||
                    move.function == 0xA9 || # Chip Away
                    [:UNAWARE, :KEENEYE, :MINDSEYE].include?(attacker.ability) ||
                    (attacker.ability == :ILLUMINATE && Gen >= 9)
    accstage -= evastage
    accstage = accstage.clamp(-6, 6)
    stagemult = accstage >= 0 ? (accstage + 3) / 3.0 : 3.0 / (3 - accstage)

    # Micle Berry
    miclemult.append(1.2) if @mondata.skill >= MEDIUMSKILL && attacker.effects[:MicleBerry]

    return pbCalcFinalAccuracy(baseaccuracy, accmult, stagemult, miclemult)
  end

  def pbAIfaster?(attackermove = nil, opponentmove = nil, attacker = @attacker, opponent = @opponent, dynamic: useDynamicSpeed)
    return true if !opponent || opponent.hp == 0
    return false if !attacker || attacker.hp == 0

    return (pbRoughStat(opponent, PBStats::SPEED) < attacker.pbSpeed) ^ (@battle.state.effects[:TrickRoom] != 0) if @mondata.skill < HIGHSKILL

    if dynamic
      attGuess = @aimondata[attacker.index].speedGuess
      oppGuess = @aimondata[opponent.index].speedGuess
      priority = { :afteryou => 3, :faster => 2, :fast => 1, nil => 0, :slow => -1, :slower => -2, :quash => -3 }
      return true  if priority[attGuess] > priority[oppGuess]
      return false if priority[oppGuess] > priority[attGuess]
    end
    priorityarray = [[0, 0, 0, attacker], [0, 0, 0, opponent]]
    index = -1
    for battler in [attacker, opponent]
      index += 1
      battlermove = battler == attacker ? attackermove : opponentmove
      priorityarray[index][1] = -1 if battler.ability == :STALL || (battler.ability == :MYCELIUMMIGHT && battlermove&.pbIsStatus?)
      priorityarray[index][1] = -1 if battler.itemWorks? && [:LAGGINGTAIL, :FULLINCENSE].include?(battler.item)
      priorityarray[index][1] = 1 if battler.hasWorkingItem(:CUSTAPBERRY) && ((battler.ability == :GLUTTONY && battler.hp <= (battler.totalhp / 2.0).floor) || battler.hp <= (battler.totalhp / 4.0).floor)

      # speed priority
      priorityarray[index][2] = battler.pbSpeed if @battle.state.effects[:TrickRoom] == 0
      priorityarray[index][2] = -battler.pbSpeed if @battle.state.effects[:TrickRoom] > 0
      next if !battlermove

      priorityarray[index][0] = getMovePriority(battlermove, battler)
      priorityarray[index][0] = 0 if battlermove && battlermove.move == :DECIMATION && checkAImoves(PBStuff::PROTECTMOVE + [:QUICKGUARD])
    end
    priorityarray.sort_by! { |a| [a[0], a[1], a[2]] }
    priorityarray.reverse!
    return false if priorityarray[0][0] == priorityarray[1][0] && priorityarray[0][1] == priorityarray[1][1] && priorityarray[0][2] == priorityarray[1][2]
    return priorityarray[0][3] == attacker
  end

  def pbMoveOrderAI(bestmoves = [nil, nil, nil, nil], adjusted_battlers = [nil, nil, nil, nil])
    priorityarray = []
    for i in 0..3
      battler = adjusted_battlers == [nil, nil, nil, nil] ? @battle.battlers[i] : adjusted_battlers[i]
      if adjusted_battlers == [nil, nil, nil, nil]
        # Mega Evolve
        if @battle.pbCanMegaEvolve?(i) && !battler.isFainted?
          battler = pbCloneBattler(i)
          battler.pokemon.makeMega
          battler.form = battler.pokemon.form
          battler.pbUpdate(true, fakebattler: true)
        end
        # Ultra Burst
        if @battle.pbCanUltraBurst?(i) && !battler.isFainted?
          battler = pbCloneBattler(i)
          battler.pokemon.makeUltra
          battler.form = battler.pokemon.form
          battler.pbUpdate(true, fakebattler: true)
        end
        if @battle.pbCanTerastallize?(i) && !battler.isFainted?
          battler = pbCloneBattler(i)
          battler.pokemon.makeTerastallized
          battler.form = battler.pokemon.form
          battler.pbUpdate(true, fakebattler: true)
        end
      end
      priorityarray[i] = [0, 0, 0, 0, i]
      if battler.hp == 0
        priorityarray[i] = [-4, 0, 0, 0, i]
        next
      end
      if useDynamicSpeed
        guess = @aimondata[i].speedGuess
        priority = { :afteryou => 3, :faster => 2, :fast => 1, nil => 0, :slow => -1, :slower => -2, :quash => -3 }
        priorityarray[i][0] = priority[guess]
      end
      priorityarray[i][2] = -1 if battler.ability == :STALL || (battler.ability == :MYCELIUMMIGHT && bestmoves[i]&.pbIsStatus?)
      priorityarray[i][2] = -1 if battler.itemWorks? && [:LAGGINGTAIL, :FULLINCENSE].include?(battler.item)
      priorityarray[i][2] = 1 if battler.hasWorkingItem(:CUSTAPBERRY) && ((battler.ability == :GLUTTONY && battler.hp <= (battler.totalhp / 2.0).floor) || battler.hp <= (battler.totalhp / 4.0).floor)
      # speed priority
      priorityarray[i][3] = pbRoughStat(battler, PBStats::SPEED) if @battle.state.effects[:TrickRoom] == 0
      priorityarray[i][3] = -pbRoughStat(battler, PBStats::SPEED) if @battle.state.effects[:TrickRoom] > 0

      priorityarray[i][1] = getMovePriority(bestmoves[i], battler)
    end
    priorityarray.sort!
    priorityarray.reverse!
    moveorderarray = []
    for i in 0..3
      moveorderarray[i] = priorityarray[i][4]
    end
    return moveorderarray
  end

  def getMovePriority(move, battler)
    pri = 0
    pri += 1 if @battle.FE == :CHESS && battler.piece == :KING
    return pri if move.nil?

    pri += move.priority
    pri += 1 if move.move == :GRASSYGLIDE && (@battle.FE == :GRASSY || @battle.OV == :GRASSY)
    pri += 1 if move.move == :QUASH && [:DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE)
    pri += 1 if battler.crested == :FERALIGATR && move.pbIsDamaging? && battler.turncount == 0
    pri += 1 if battler.ability == :PRANKSTER && move.pbIsStatus?
    pri += 1 if battler.galeWingsActive? && move.pbType(battler) == :FLYING
    pri += 3 if battler.ability == :TRIAGE && (move.isHealingMove? || move.isDrainingMove?)
    pri -= 1 if @battle.FE == :DEEPEARTH && move.move == :COREENFORCER
    return pri
  end

  def getRecoilFromInitialScore(initialscore)
    damage = (initialscore.clamp(0, 100) / 100.0 * @opponent.hp).round
    recoil = @move.getRecoil(@attacker, damage, @move.recoil, [:Success])
    # getRecoil needs a hitflags parameter, passing :Success as we can assume the move will be successful while scoring it
    return recoil
  end

  def getHealAmount(mon, move) # self-healing moves
    hpgain = 0
    case move.function
      when 0xd5, 0xd6, 0x169 # Heal Order / Milk Drink / Recover / Slack Off / Soft-Boiled, Roost, Purify
        hpgain = (mon.totalhp / 2.0).round
        hpgain = (mon.totalhp * 0.66).round if @mondata.skill >= BESTSKILL && @battle.FE == :FOREST && move.move == :HEALORDER
      when 0xd8 # Synthesis / Morning Sun / Moonlight
        if @mondata.skill >= BESTSKILL && (([:DARKCRYSTALCAVERN, :STARLIGHT, :NEWWORLD, :BEWITCHED].include?(@battle.FE) && move.move == :MOONLIGHT) || (Rejuv && @battle.FE == :GRASSY && move.move == :SYNTHESIS))
          hpgain = (mon.totalhp * 0.75).pokeRound
        elsif @mondata.skill >= BESTSKILL && @battle.FE == :DARKNESS1 && move.move == :MOONLIGHT
          hpgain = (mon.totalhp * 0.4).pokeRound
        elsif @mondata.skill >= BESTSKILL && [:DARKCRYSTALCAVERN, :DARKNESS2].include?(@battle.FE) && move.move != :MOONLIGHT
          hpgain = (mon.totalhp * 0.25).pokeRound
        elsif @mondata.skill >= BESTSKILL && (@battle.FE == :DARKNESS3 || @battle.OV == :DARKNESS2) && move.move != :MOONLIGHT
          hpgain = (mon.totalhp * 0.125).pokeRound
        else
          weather = @battle.pbWeather(mon)
          if weather == :SUNNYDAY && !mon.hasWorkingItem(:UTILITYUMBRELLA)
            hpgain = (mon.totalhp * 0.667).pokeRound
          elsif weather == 0 || ([:SUNNYDAY, :RAINDANCE].include?(weather) && mon.hasWorkingItem(:UTILITYUMBRELLA))
            hpgain = (mon.totalhp / 2.0).pokeRound
          else
            hpgain = (mon.totalhp * 0.25).pokeRound
          end
        end
      when 0xd9 # Rest
        hpgain = mon.totalhp - mon.hp
      when 0x114 # Swallow
        case mon.effects[:Stockpile]
          when 1
            hpgain = (mon.totalhp * 0.25).round
            hpgain = (mon.totalhp * 0.5).round if @mondata.skill >= BESTSKILL && @battle.FE == :WASTELAND
          when 2
            hpgain = (mon.totalhp * 0.5).round
            hpgain = mon.totalhp if @mondata.skill >= BESTSKILL && @battle.FE == :WASTELAND
          when 3
            hpgain = mon.totalhp
        end
      when 0x16c # Shore Up
        if @mondata.skill >= BESTSKILL && @battle.FE == :ASHENBEACH
          hpgain = mon.totalhp
        elsif @battle.pbWeather(mon) == :SANDSTORM || (@mondata.skill >= BESTSKILL && @battle.FE == :DESERT)
          hpgain = (mon.totalhp * 0.667).pokeRound
        else
          hpgain = (mon.totalhp / 2.0).pokeRound
        end
      when 0x187 # Life Dew
        hpgain = (mon.totalhp * 0.25).round
        hpgain = (mon.totalhp * 0.5).round if @mondata.skill >= BESTSKILL && [:HOLY, :RAINBOW].include?(@battle.FE)
      when 0x318 # Jungle Healing / Lunar Blessing
        hpgain = (mon.totalhp * 0.25).round
        hpgain = (mon.totalhp * 0.33).round if @mondata.skill >= BESTSKILL && ((move.move == :LUNARBLESSING && [:STARLIGHT, :NEWWORLD, :HOLY].include?(@battle.FE)) || (move.move == :JUNGLEHEALING && [:FOREST, :HOLY, :NEWWORLD].include?(@battle.FE)))
    end
    return hpgain
  end

  def getDrainAmount(attacker, opponent, move) # attacker is drainer, opponent is drainee
    unless move.function == 0x172
      return 0 if (opponent.effects[:Disguise] || (opponent.effects[:IceFace] && (move.pbIsPhysical?(attacker) || (@mondata.skill >= BESTSKILL && @battle.FE == :FROZENDIMENSION)))) && !moldBreakerCheck(attacker, opponent, move)
      damage = pbRoughDamage(move, attacker, opponent)
    end
    drainamount = 0
    case move.function
      when 0x172 # Strength Sap
        drainamount = opponent.attack * PBStats::StageMul[opponent.stages[PBStats::ATTACK] + 6]
        drainamount = (drainamount * 1.3).round if @mondata.skill >= BESTSKILL && ((!Rejuv && @battle.FE == :SWAMP) || @battle.FE == :FOREST)
      when 0xdd, 0xde, 0x208 # Leech Life and ilk, Dream Eater, Hexing Slash
        drainamount = (damage * 0.5).round
        drainamount = (damage * 0.75).round if Rejuv && @mondata.skill >= BESTSKILL && @battle.FE == :ELECTERRAIN && move.move == :PARABOLICCHARGE
        drainamount = (damage * 0.75).round if Rejuv && @mondata.skill >= BESTSKILL && @battle.FE == :GRASSY && [:ABSORB, :MEGADRAIN, :GIGADRAIN, :HORNLEECH].include?(move.move)
      when 0x139 # Draining Kiss / Oblivion Wing
        drainamount = (damage * 0.75).round
      when 0x51e # Matcha Gotcha
        drainamount = (damage * 0.5).round
        drainamount = (drainamount * 1.3).round if @mondata.skill >= BESTSKILL && [:SNOWYMOUNTAIN, :ICY].include?(@battle.FE)
    end
    drainamount = 1 if drainamount <= 0
    bigRootBoost = Rejuv && @battle.FE == :GRASSY ? 1.6 : PBMults::RootOrb
    drainamount = (drainamount * bigRootBoost).round if attacker.hasWorkingItem(:BIGROOT)
    drainamount = (drainamount * 1.3).round if attacker.crested == :SHIINOTIC
    if opponent.ability == :LIQUIDOOZE
      drainamount *= 2 if @mondata.skill >= BESTSKILL && [:WASTELAND, :MURKWATERSURFACE, :CORRUPTED].include?(@battle.FE)
      drainamount = 0 if @battle.magicGuardAbilities.include?(attacker.ability)
    end
    return drainamount
  end

  def hpGainPerTurn(attacker = @attacker, chipdamageCheck = false)
    healing = chipdamageCheck ? 0 : 1
    weather = @battle.pbWeather(nil)
    bothOpponents = [@opponent, @opponent.pbPartner].select { |oppmon| oppmon.hp > 0 }
    # Negative healing effects
    if !@battle.magicGuardAbilities.include?(attacker.ability)
      if [:BURNING, :VOLCANIC].include?(@battle.FE) && attacker.burningFieldPassiveDamage? && attacker.ability != :WELLBAKEDBODY
        subscore = 0
        subscore += PBTypes.typesEff(:FIRE, attacker.types, inverse: @battle.inverse?).multiplier / 8
        subscore *= 2.0 if [:LEAFGUARD, :ICEBODY, :FLUFFY, :GRASSPELT].include?(attacker.ability)
        subscore *= 2.0 if attacker.effects[:TarShot]
        healing -= subscore
      end
      if @battle.FE == :UNDERWATER && attacker.underwaterFieldPassiveDamage?
        subscore = 0
        subscore += PBTypes.typesEff(:WATER, attacker.types, inverse: @battle.inverse?).multiplier / 8
        subscore *= 2.0 if [:FLAMEBODY, :MAGMAARMOR].include?(attacker.ability)
        healing -= subscore
      end
      if @battle.FE == :MURKWATERSURFACE && attacker.murkyWaterSurfacePassiveDamage?
        subscore = 0
        subscore += PBTypes.typesEff(:POISON, attacker.types, inverse: @battle.inverse?).multiplier / 8
        subscore *= 2.0 if [:FLAMEBODY, :MAGMAARMOR, :DRYSKIN, :WATERABSORB].include?(attacker.ability)
        healing -= subscore
      end

      # Field effect induced
      healing -= 0.125 if @battle.FE == :CORROSIVE && [:GRASSPELT, :DRYSKIN].include?(attacker.ability)
      healing -= 0.125 if @battle.FE == :DESERT && attacker.ability == :DRYSKIN
      healing -= 0.125 if @battle.FE == :CORRUPTED && attacker.ability == :DRYSKIN && !attacker.hasType?(:POISON)
      healing -= 0.125 if Rejuv && @battle.FE == :DESERT && weather == :SUNNYDAY && (attacker.hasType?(:GRASS) || attacker.hasType?(:WATER)) && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
      healing -= 0.0625 if attacker.effects[:AquaRing] && @battle.FE == :CORROSIVEMIST && !attacker.hasType?(:STEEL) && !attacker.hasType?(:POISON)
      healing -= 0.0625 if attacker.effects[:Ingrain] && ((!Rejuv && @battle.FE == :SWAMP) || [:CORROSIVE, :CORRUPTED].include?(@battle.FE)) && !attacker.hasType?(:STEEL) && !attacker.hasType?(:POISON)
      healing -= 0.0625 if @battle.FE == :HAUNTED && attacker.status == :SLEEP && !attacker.hasType?(:GHOST) && attacker.crested != :SUICUNE
      healing -= 0.0625 if @battle.FE == :DIMENSIONAL && attacker.effects[:HealBlock]
      healing -= 0.125 if @battle.FE == :CORROSIVE && [:GRASSPELT, :LEAFGUARD, :FLOWERVEIL].include?(attacker.ability)
      healing -= 0.125 if @battle.FE == :INFERNAL && attacker.effects[:Torment]

      # weather induced
      healing -= 0.125 if weather == :SUNNYDAY && ([:SOLARPOWER, :DRYSKIN].include?(attacker.ability) || (attacker.crested == :CASTFORM && attacker.form == 1)) && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
      healing -= Rejuv && @battle.FE == :DESERT ? 0.125 : 0.0625 if weather == :SANDSTORM && attacker.takesWeatherDamage?
      healing -= @battle.FE == :FROZENDIMENSION ? 0.125 : 0.0625 if weather == :HAIL && attacker.takesWeatherDamage?
      healing -= [:DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE) ? 0.125 : 0.0625 if weather == :SHADOWSKY && attacker.takesWeatherDamage?
      # Status induced
      healing -= 0.125 if attacker.status == :POISON && attacker.ability != :POISONHEAL && ![:ZANGOOSE, :SUICUNE].include?(attacker.crested) && attacker.statusCount == 0
      healing -= [15, attacker.effects[:Toxic]].min / 16.0 if attacker.status == :POISON && attacker.ability != :POISONHEAL && ![:ZANGOOSE, :SUICUNE].include?(attacker.crested) && attacker.statusCount > 0
      healing -= attacker.ability == :HEATPROOF || @battle.FE == :ICY ? 0.03125 : 0.0625 if attacker.status == :BURN
      healing -= 0.125 if attacker.status == :FREEZE && @battle.state.effects[:NeverMeltIce]
      if attacker.isSleeping?
        sleepdmg = [:DIMENSIONAL, :BEWITCHED, :SWAMP].include?(@battle.FE) ? 0.0625 : 0.0
        # rejuv specific swamp field mechanic
        if Rejuv && @battle.FE == :SWAMP
          sleepdmg *= 2.0 if attacker.effects[:MultiTurn] > 0
        end
        if (attacker.pbOpposing1.ability == :BADDREAMS || attacker.pbOpposing2.ability == :BADDREAMS) && @battle.FE != :RAINBOW
          if [:INFERNAL, :DARKNESS3].include?(@battle.FE)
            sleepdmg += 0.25
          elsif @battle.FE == :DARKNESS2 || @battle.OV == :DARKNESS2
            sleepdmg += 0.166
          else
            sleepdmg += 0.125
          end
        end
        healing -= sleepdmg
      end
      healing -= 0.0625 if attacker.status == :SLEEP && [:DIMENSIONAL, :BEWITCHED].include?(@battle.FE) && attacker.crested != :SUICUNE

      # Other
      healing -= 0.125 if attacker.effects[:LeechSeed] >= 0 && attacker.ability != :LIQUIDOOZE
      healing -= 0.125 if attacker.status == :PETRIFIED && @attacker.crested != :SUICUNE
      healing -= 0.125 if @battle.FE == :WASTELAND && attacker.effects[:LeechSeed] >= 0 && attacker.ability != :LIQUIDOOZE
      healing -= [:DARKNESS3, :HAUNTED].include?(@battle.FE) ? 0.33 : 0.25 if attacker.effects[:Nightmare] && @battle.FE != :RAINBOW && attacker.status == :SLEEP && attacker.crested != :SUICUNE
      healing -= 0.25 if attacker.effects[:Curse] && @battle.FE != :HOLY

      damageorder = [1/16.0, 2/16.0, 3/16.0]
      healing -= damageorder[attacker.turncount % 3] if aiCheckSideAbility(:WATERBARRAGE, attacker.pbOpposing1).length > 0

      wildfiredam = aiCheckSideAbility(:WILDFIRE, attacker.pbOpposing1).length > 0 ? 1/16.0 : 0
      wildfiredam = 1/8.0 if attacker.status == :BURN || attacker.effects[:MultiTurnAttack] == :FIRESPIN
      wildfiredam = 1/6.0 if [:GRASSY, :FOREST, :FLOWERGARDEN1, :FLOWERGARDEN2, :FLOWERGARDEN3, :FLOWERGARDEN4, :FLOWERGARDEN5].include?(@battle.FE) || @battle.OV == :GRASSY
      healing -= wildfiredam



      if attacker.effects[:SaltCure]
        fraction = Gen >= Champs ? (@battle.FE == :HOLY ? 0.125 : 0.0625) : (@battle.FE == :HOLY ? 0.1667 : 0.125)
        fraction *= 2 if attacker.hasType?(:STEEL) || attacker.hasType?(:WATER)
        healing -= fraction
      end
      if attacker.effects[:MultiTurn] > 0
        if attacker.effects[:BindingBand]
          healing -= 0.1667
        else
          case attacker.effects[:MultiTurnAttack]
            when :FIRESPIN then healing -= [:BURNING, :HAUNTED].include?(@battle.FE) ? 0.1667 : 0.125
            when :MAGMASTORM then healing -= @battle.FE == :DRAGONSDEN ? 0.1667 : 0.125
            when :SANDTOMB then healing -= @battle.FE == :DESERT ? 0.1667 : 0.125
            when :WHIRLPOOL then healing -= [:WATERSURFACE, :UNDERWATER].include?(@battle.FE) ? 0.1667 : 0.125
            when :THUNDERCAGE then healing -= @battle.FE == :ELECTERRAIN ? 0.1667 : 0.125
            when :INFESTATION
              if [:FOREST, :FLOWERGARDEN3].include?(@battle.FE)
                healing -= 0.1667
              elsif @battle.FE == :FLOWERGARDEN4
                healing -= 0.25
              elsif @battle.FE == :FLOWERGARDEN5
                healing -= 0.33
              else
                healing -= 0.125
              end
            else healing -= 0.125
          end
        end
      end
      healing -= 0.125 if attacker.item == :STICKYBARB
      healing -= [:CORRUPTED].include?(@battle.FE) ? 0.25 : 0.125 if attacker.item == :BLACKSLUDGE && !attacker.hasType?(:POISON)
    end

    currentJurisdiction = @battle.currentJurisdiction?
    if currentJurisdiction == :NEVED
      turncount = @battle.turncount
      if @battle.pbBelongsToPlayer?(attacker.index)
        damagecount = [1/256.0 * (1.5 ** turncount), 1/4.0].min
        healing -= damagecount
      end
    end
    healing = 0 if healing < 0 && chipdamageCheck == false

    # Positive healing effects
    return healing if attacker.canHeal? == false

    if attacker.effects[:AquaRing]
      subscore = 0
      subscore = 0.0625 unless @battle.FE == :CORROSIVEMIST && !attacker.hasType?(:STEEL) && !attacker.hasType?(:POISON)
      subscore *= Rejuv && @battle.FE == :GRASSY ? 1.6 : PBMults::RootOrb if attacker.itemWorks? && attacker.item == :BIGROOT
      subscore *= 1.3 if @attacker.crested == :SHIINOTIC
      subscore *= 2.0 if [:MISTY, :SWAMP, :WATERSURFACE, :UNDERWATER].include?(@battle.FE)
      healing += subscore
    end
    if attacker.effects[:Ingrain]
      unless ((!Rejuv && @battle.FE == :SWAMP) || [:CORROSIVE, :CORRUPTED].include?(@battle.FE)) && !attacker.hasType?(:STEEL) && !attacker.hasType?(:POISON)
        subscore = 0.0625
        subscore *= Rejuv && @battle.FE == :GRASSY ? 1.6 : PBMults::RootOrb if attacker.itemWorks? && attacker.item == :BIGROOT
        subscore *= 1.3 if @attacker.crested == :SHIINOTIC
        subscore *= 2.0 if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5) || @battle.FE == :FOREST || (Rejuv && (@battle.FE == :GRASSY || @battle.OV == :GRASSY))
        subscore *= 2.0 if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 4, 5)
        healing += subscore
      end
    end
    if attacker.ability == :DRYSKIN
      healing += 0.0625 if ([:CORROSIVE, :CORRUPTED].include?(@battle.FE) && attacker.hasType?(:POISON) && !attacker.hasType?(:STEEL)) ||
                           (weather == :RAINDANCE && !attacker.hasWorkingItem(:UTILITYUMBRELLA)) || [:MISTY, :SWAMP, :WATERSURFACE, :UNDERWATER].include?(@battle.FE) || @battle.OV == :MISTY
    end
    healing += [:CORRUPTED].include?(@battle.FE) ? 0.125 : 0.0625 if attacker.itemWorks? && (attacker.item == :BLACKSLUDGE && attacker.hasType?(:POISON))
    healing += 0.0625 if attacker.itemWorks? && attacker.item == :LEFTOVERS
    healing += 0.0625 if attacker.crested == :INFERNAPE
    healing += 0.0625 if attacker.crested == :GOTHITELLE && attacker.type1 == :PSYCHIC
    healing += 0.0625 if attacker.crested == :VESPIQUEN && attacker.effects[:VespiCrest] == false
    healing += attacker.pbEnemyFaintedPokemonCount * 0.05 if attacker.crested == :SPIRITOMB
    healing += 0.0625 if attacker.ability == :RAINDISH && weather == :RAINDANCE && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
    healing += 0.0625 if attacker.crested == :CASTFORM && attacker.form == 2 && weather == :RAINDANCE
    healing += 0.0625 if attacker.ability == :ICEBODY && ([:HAIL, :SNOW].include?(weather) || [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION].include?(@battle.FE) || attacker.crested == :GLACEON)
    healing += 0.0625 if attacker.crested == :DRUDDIGON && weather == :SUNNYDAY
    healing += 0.0625 * aiCheckSideAbility(:DESSERTTRAY, attacker).length
    healing += 0.0625 if attacker.crested == :MEGANIUM || attacker.pbPartner.crested == :MEGANIUM
    healing += 0.0625 if attacker.crested == :SUICUNE
    healing += 0.1 if attacker.crested == :SUNFLORA
    for i in bothOpponents
      healing += ((0.125 * i.totalhp) / 100.0).floor if i.effects[:LeechSeed] >= 0 && attacker == @battle.battlers[i.effects[:LeechSeed]]
      healing += ((0.0625 * i.totalhp) / 100.0).floor if attacker.ability == :POLLENFLIGHT && !i.hasType?(:GRASS)
    end

    healing += 0.125 if (attacker.status == :POISON || [:CORROSIVE, :WASTELAND].include?(@battle.FE)) && (attacker.ability == :POISONHEAL || attacker.crested == :ZANGOOSE)
    healing += 0.0625 if Rejuv && (@battle.FE == :GRASSY || @battle.OV == :GRASSY) && attacker.ability == :SAPSIPPER
    healing += 0.0625 if (@battle.FE == :GRASSY || @battle.OV == :GRASSY) && !attacker.isAirborne? && !attacker.isSemiInvul?
    healing += 0.0625 if Rejuv && (@battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN) && attacker.ability == :VOLTABSORB
    if @battle.FE != :INDOOR
      healing += 0.0625 if @battle.FE == :RAINBOW && attacker.status == :SLEEP
      healing += 0.0625 if @battle.FE == :FOREST && attacker.ability == :SAPSIPPER
      healing += 0.0625 if @battle.FE == :SHORTCIRCUIT && attacker.ability == :VOLTABSORB
      healing += 0.0625 if @battle.FE == :DESERT && attacker.ability == :EARTHEATER
      healing += 0.0625 if [:HAUNTED, :DIMENSIONAL, :INFERNAL, :DEUXFINALIS].include?(@battle.FE) && attacker.ability == :SOULEATER
      healing += 0.0625 if @battle.FE == :DEUXFINALIS && [:GLUTTONY, :PURIFYINGSALT].include?(attacker.ability)
      healing += 0.0625 if [:WATERSURFACE, :UNDERWATER].include?(@battle.FE) && attacker.ability == :WATERABSORB
      healing += 0.0625 if @battle.FE == :BEWITCHED && attacker.hasType?(:GRASS) && !attacker.isAirborne?
      healing *= 0.67 if @battle.FE == :BACKALLEY
    end
    return healing
  end

  def pbPartyHasType?(type, index = @index)
    typevar = false
    for mon in @battle.pbCombinedParty(index)
      next if mon.nil? || mon.isEgg?

      typevar = true if mon.hp > 0 && mon.hasType?(type)
    end
    return typevar
  end

  def illusionDeceived?(attacker = @attacker, opponent = @opponent)
    return false unless opponent.pbIsOpposing?(attacker.index) # it's your own zoroark idiot
    return false unless opponent.effects[:Illusion]
    return false if opponent.permeffs[:IllusionDisclosure]
    return true
  end

  # Typemod.negative means that not only is the opponent immune but they also gain some advantage
  def pbTypeModNoMessages(type = @move.type, attacker = @attacker, opponent = @opponent, move = @move, skill = @mondata.skill)
    return Typemod.normal if !type

    # field based move failure
    return Typemod.zero if skill >= HIGHSKILL && !move.isMoveValidOnField?(attacker)
    return Typemod.zero if skill >= BESTSKILL && @battle.FE == :CHESS && Rejuv && attacker.ability == :KLUTZ && PBFields::CHESSMOVES.include?(move.move)
    return Typemod.zero if skill >= HIGHSKILL && @battle.state.effects[:Gravity] != 0 && move.unusableInGravity?

    return Typemod.normal if [:User, :OpposingSide, :BothSides, :UserSide, :AllyBattlers].include?(attacker.pbTarget(move))

    oppCanHeal = opponent.canHeal?
    types = [type, *move.getSecondaryType(attacker, type)]
    if !moldBreakerCheck(attacker, opponent, move) && skill >= MEDIUMSKILL
      case opponent.ability
        when :SAPSIPPER then return opponent.pbCanIncreaseStatStage?(PBStats::ATTACK, opponent, nil) ? Typemod.negative : Typemod.zero if types.include?(:GRASS)
        when :EARTHEATER then return oppCanHeal ? Typemod.negative : Typemod.zero if types.include?(:GROUND)
        when :STORMDRAIN then return opponent.pbCanIncreaseStatStage?(PBStats::SPATK, opponent, nil) ? Typemod.negative : Typemod.zero if types.include?(:WATER)
        when :LIGHTNINGROD then return opponent.pbCanIncreaseStatStage?(PBStats::SPATK, opponent, nil) ? Typemod.negative : Typemod.zero if types.include?(:ELECTRIC)
        when :MOTORDRIVE then return opponent.pbCanIncreaseStatStage?(PBStats::SPEED, opponent, nil) ? Typemod.negative : Typemod.zero if types.include?(:ELECTRIC)
        when :DRYSKIN, :WATERABSORB then return oppCanHeal ? Typemod.negative : Typemod.zero if types.include?(:WATER)
        when :VOLTABSORB then return oppCanHeal ? Typemod.negative : Typemod.zero if types.include?(:ELECTRIC)
        when :SOULEATER then return oppCanHeal ? Typemod.negative : Typemod.zero if types.include?(:GHOST) || ([:INFERNAL, :DIMENSIONAL].include?(@battle.FE) && types.include?(:DARK))
        when :FLASHFIRE then return opponent.effects[:FlashFire] ? Typemod.zero : Typemod.negative if types.include?(:FIRE)
        when :COALFURNACE then return opponent.effects[:CoalFurnace] ? Typemod.zero : Typemod.negative if types.include?(:ROCK)
        when :WELLBAKEDBODY then return opponent.pbCanIncreaseStatStage?(PBStats::DEFENSE, opponent, nil) ? Typemod.negative : Typemod.zero if types.include?(:FIRE)
        when :MAGMAARMOR then return Typemod.zero if types.include?(:FIRE) && [:DRAGONSDEN, :INFERNAL, :VOLCANICTOP].include?(@battle.FE)
        when :BULLETPROOF then return Typemod.zero if move.bulletMove?
        when :PROTECTIVERIME then return Typemod.zero if opponent.index == attacker.pbPartner.index && move.checkSoundMove?(attacker)
        when :SOUNDPROOF then return Typemod.zero if move.checkSoundMove?(attacker)
        when :WINDRIDER then return opponent.pbCanIncreaseStatStage?(PBStats::ATTACK, opponent, nil) ? Typemod.negative : Typemod.zero if move.windMove?
        when :TELEPATHY then return Typemod.zero if move.pbIsDamaging? && !attacker.pbIsOpposing?(opponent.index)
        when :GOODASGOLD then return Typemod.zero if move.pbIsStatus? && attacker != opponent
      end
    end
    if skill >= HIGHSKILL
      case opponent.crested
        when :WHISCASH then return opponent.pbCanIncreaseStatStage?(PBStats::ATTACK, opponent, nil) ? Typemod.negative : Typemod.zero if types.include?(:GRASS)
        when :SKUNTANK then return opponent.pbCanIncreaseStatStage?(PBStats::ATTACK, opponent, nil) ? Typemod.negative : Typemod.zero if types.include?(:GROUND)
        when :DRUDDIGON then return oppCanHeal ? Typemod.negative : Typemod.zero if types.include?(:FIRE)
        when :FLYGON then return Typemod.zero if opponent.index == attacker.pbPartner.index && move.checkSoundMove?(attacker)
      end
      case attacker.crested
        when :FLYGON then return Typemod.zero if opponent.index == attacker.pbPartner.index && move.checkSoundMove?(attacker)
      end
    end
    return Typemod.zero if move.powderMove? && opponent.powderImmune?
    return Typemod.zero if move.explosiveMove? && (aiCheckGlobalAbility(:DAMP, attacker, opponent, checkMoldBroken: true) || ([:MISTY, :SWAMP].include?(@battle.FE) && move.move != :MISTYEXPLOSION))
    # this also accounts for levitate, solar/lunar idol, and deep earth floater abilities
    if types.include?(:GROUND) && move.pbIsDamaging? && ![0x11C, 0x205].include?(move.function) # Smack Down / Thousand Arrows & Desert's Mark
      return Typemod.zero if !canGroundMoveHit?(opponent, nil, moldBreakerCheck(attacker, opponent, move))
    end
    if @battle.FE == :ROCKY && (opponent.effects[:Substitute] > 0 || opponent.stages[PBStats::DEFENSE] > 0)
      return Typemod.zero if move.bulletMove?
    end
    if [:HOLY].include?(@battle.FE) && move.pbIsDamaging? && opponent.index == attacker.pbPartner.index
      return Typemod.zero
    end
    if Rejuv && @battle.FE == :DESERT && @battle.pbWeather(attacker) == :SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA) && types.include?(:WATER) && (opponent.hasType?(:WATER) || opponent.hasType?(:GRASS))
      return opponent.canHeal? ? Typemod.negative : Typemod.zero
    end

    if Rejuv && @battle.FE == :GLITCH && opponent.species == :GENESECT && skill >= HIGHSKILL
      if opponent.item == :BURNDRIVE && types.include?(:FIRE)
        return opponent.effects[:FlashFire] ? Typemod.zero : Typemod.negative
      elsif opponent.item == :DOUSEDRIVE && types.include?(:WATER)
        return oppCanHeal ? Typemod.negative : Typemod.zero
      elsif opponent.item == :CHILLDRIVE && types.include?(:ICE)
        return oppCanHeal ? Typemod.negative : Typemod.zero
      elsif opponent.item == :SHOCKDRIVE && types.include?(:ELECTRIC)
        return opponent.pbCanIncreaseStatStage?(PBStats::SPEED, opponent, nil) ? Typemod.negative : Typemod.zero
      end
    end

    return Typemod.normal if move.pbIsStatus?


    typemod = move.pbCalcTypeMod(type, attacker, opponent)


    typemod = Typemod.zero if opponent.ability == :WONDERGUARD && !moldBreakerCheck(attacker, opponent, move) && !typemod.superEffective?

    typemod = Typemod.half if opponent.ability == :TERASHELL && opponent.species == :TERAPAGOS && opponent.hp == opponent.totalhp && typemod.effective? && !moldBreakerCheck(attacker, opponent, move)

    return Typemod.half * Typemod.half if typemod.immune? && move.function == 0x111

    return typemod
  end

  def pbChangeMove(move, attacker)
    if move.move == :NATUREPOWER
      zmove = move.zmove
      move = moveToMoveObject(@battle.getNaturePowerMove, attacker)
      move.zmove = zmove
      if move.zmove && move.basedamage > 0
        move = moveToMoveObject($cache.items[PBStuff::TYPETOZCRYSTAL[move.type]].zmove, attacker, move)
      end
      move.priority = 1 if attacker.ability == :PRANKSTER
    end
    # Mirror beam, create a copy of the move the AI can work with instead of the real move, for type determination
    if move.function == 0x20E
      move = moveToMoveObject(move.move, attacker)
    end
    return move
  end

  def scoreDecrease(threat_index, killable, decreased_by, ai_leader)
    if killable[ai_leader] == :both
      # leader can kill both mons, so should choose to kill the threat
      # decreasing scores for leader on the non-threat mon, so it will target the threat
      @aimondata[ai_leader].scorearray[threat_index ^ 2].map! { |score| score > 80 ? 80 : score }
      # decreasing scores for follower on the threat, so it will target the non-threat mon
      @aimondata[ai_leader ^ 2].scorearray[threat_index].map! { |score| score * decreased_by }
      PBDebug.dblog("Leader (#{@battle.battlers[ai_leader].logname}) KOs both opponents. Leader targets greater threat (#{@battle.battlers[threat_index].logname}) and caps scores against lesser threat (#{@battle.battlers[threat_index ^ 2].logname}) at 80.") if !decreased_by.nil? && decreased_by != 1.0
      PBDebug.dblog("Decrease follower's (#{@battle.battlers[ai_leader ^ 2].logname}) scores against #{@battle.battlers[threat_index].logname} by x#{decreased_by} to avoid double attacking.") if !decreased_by.nil? && decreased_by != 1.0
      PBDebug.dblog("Leader can KO both opponents but can be KO'd first. No decrease in follower's scores.") if !decreased_by.nil? && decreased_by == 1.0
    elsif killable[ai_leader] == :left || killable[ai_leader] == :right
      # leader can kill one of the mons
      offset = (ai_leader % 2) ^ 1
      montobekilled = killable[ai_leader] == :left ? offset : offset + 2
      # decreasing score for follower on the mon the leader will kill, so it will target the other mon
      @aimondata[ai_leader ^ 2].scorearray[montobekilled].map! { |score| score * decreased_by }
      PBDebug.dblog("Leader (#{@battle.battlers[ai_leader].logname}) KOs #{@battle.battlers[montobekilled].logname}. Decrease follower's (#{@battle.battlers[ai_leader ^ 2].logname}) scores against #{@battle.battlers[montobekilled].logname} by x#{decreased_by} to avoid double attacking.") if !decreased_by.nil? && decreased_by != 1.0
      PBDebug.dblog("Leader can KO #{@battle.battlers[montobekilled].logname} but can be KO'd first. No decrease in follower's scores.") if !decreased_by.nil? && decreased_by == 1.0
    end
  end

  def totalHazardDamage(pkmn)
    damage = 0
    if pkmn.pbOwnSide.effects[:Spikes] > 0 && !pkmn.isAirborne? && !@battle.magicGuardAbilities.include?(pkmn.ability) && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
      spikesdiv = [8, 8, 6, 4][pkmn.pbOwnSide.effects[:Spikes]]
      if Rejuv && @battle.FE == :ELECTERRAIN && @mondata.skill >= BESTSKILL
        eff = PBTypes.typesEff(:ELECTRIC, pkmn.types, inverse: @battle.inverse?)
        unless eff.immune?
          damage += [(pkmn.totalhp * eff.multiplier / spikesdiv).floor, 1].max
        end
      else
        damage += [(pkmn.totalhp.to_f / spikesdiv).floor, 1].max
      end
    end
    if pkmn.pbOwnSide.effects[:StealthRock] && !@battle.magicGuardAbilities.include?(pkmn.ability) && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
      eff = PBTypes.typesEff(:ROCK, pkmn.types, inverse: @battle.inverse?)
      if @mondata.skill >= BESTSKILL && @battle.FE == :CRYSTALCAVERN
        eff1 = PBTypes.typesEff(:WATER, pkmn.types, inverse: @battle.inverse?)
        eff2 = PBTypes.typesEff(:GRASS, pkmn.types, inverse: @battle.inverse?)
        eff3 = PBTypes.typesEff(:FIRE, pkmn.types, inverse: @battle.inverse?)
        eff4 = PBTypes.typesEff(:PSYCHIC, pkmn.types, inverse: @battle.inverse?)
        eff = Typemod.max(eff1, eff2, eff3, eff4)
      elsif @mondata.skill >= BESTSKILL && @battle.FE == :CORRUPTED
        eff = PBTypes.typesEff(:POISON, pkmn.types, inverse: @battle.inverse?)
      elsif @mondata.skill >= BESTSKILL && ([:VOLCANICTOP, :INFERNAL].include?(@battle.FE) || (Rejuv && @battle.FE == :DRAGONSDEN))
        eff = PBTypes.typesEff(:FIRE, pkmn.types, inverse: @battle.inverse?)
      end
      unless eff.immune?
        mult = eff.multiplier
        mult *= 2 if @mondata.skill >= BESTSKILL && [:ROCKY, :CAVE].include?(@battle.FE)
        damage += [(pkmn.totalhp / 8.0 * mult).floor, 1].max
      end
    end
    if @mondata.skill >= BESTSKILL
      # Corrosive Field Entry
      if @battle.FE == :CORROSIVE
        if ![:MAGICGUARD, :POISONHEAL, :IMMUNITY, :WONDERGUARD, :TOXICBOOST, :PASTELVEIL].include?(pkmn.ability) && pkmn.crested != :ZANGOOSE && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
          if !pkmn.isAirborne? && !pkmn.hasType?(:POISON) && !pkmn.hasType?(:STEEL)
            eff = PBTypes.typesEff(:POISON, pkmn.types, inverse: @battle.inverse?)
            damage += [(pkmn.totalhp / 4.0 * eff.multiplier).floor, 1].max
          end
        end
      # Icy field + Seed activation spike damage
      elsif @battle.FE == :ICY
        if pkmn.item == :ELEMENTALSEED && pkmn.ability != :KLUTZ && !pkmn.isAirborne? && pkmn.ability != :MAGICGUARD
          spikesdiv = [8, 8, 6, 4][pkmn.pbOwnSide.effects[:Spikes]]
          damage += [(pkmn.totalhp.to_f / spikesdiv).floor, 1].max
        end
      # Cave field + Seed activation stealth rock damage
      elsif @battle.FE == :CAVE
        if pkmn.item == :TELLURICSEED && pkmn.ability != :KLUTZ && pkmn.ability != :MAGICGUARD
          eff = PBTypes.typesEff(:ROCK, pkmn.types, inverse: @battle.inverse?)
          unless eff.immune?
            damage += [(pkmn.totalhp / 4.0 * eff.multiplier).floor, 1].max
          end
        end
      elsif [:CONCERT3, :CONCERT4].include?(@battle.FE)
        if pkmn.isSleeping?
          damage += pkmn.totalhp / 4
        end
      end
    end
    return damage
  end

  def getAbilityDisruptScore(attacker, opponent, forThreatScore: false)
    abilityscore = 100.0
    return (abilityscore / 100) if opponent.ability.nil? # if the ability doesn't work, then nothing here matters
    return forThreatScore ? 1.0 : 0 if PBStuff::FIXEDABILITIES.include?(opponent.ability) # might want to give fixed abilities actual scores for threat assessment

    applydscode = opponent == @opponent

    case opponent.ability
      when :SPEEDBOOST
        abilityscore *= 1.1
        abilityscore *= 1.3 if opponent.stages[PBStats::SPEED] < 2
      when :SANDVEIL
        abilityscore *= 1.3 if @battle.pbWeather(nil) == :SANDSTORM
      when :VOLTABSORB, :LIGHTNINGROD, :MOTORDRIVE
        for i in attacker.moves
          next if i.nil?

          elecmove = i if i.pbType(attacker) == :ELECTRIC
         end
        if attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :ELECTRIC }
          abilityscore *= 3 if attacker.moves.all? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :ELECTRIC }
          abilityscore *= 2 if pbTypeModNoMessages(elecmove.pbType(attacker), attacker, opponent, elecmove).superEffective?
        end
      when :WATERABSORB, :STORMDRAIN, :DRYSKIN
        for i in attacker.moves
          next if i.nil?

          watermove = i if i.pbType(attacker) == :WATER
         end
        if attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :WATER }
          abilityscore *= 3 if attacker.moves.all? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :WATER }
          abilityscore *= 2 if pbTypeModNoMessages(watermove.pbType(attacker), attacker, opponent, watermove).superEffective?
        end
        abilityscore *= 0.5 if opponent.ability == :DRYSKIN && attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :FIRE }
      when :SAPSIPPER
        for i in attacker.moves
          next if i.nil?

          grassmove = i if i.pbType(attacker) == :GRASS
         end
        if attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :GRASS }
          abilityscore *= 3 if attacker.moves.all? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :GRASS }
          abilityscore *= 2 if pbTypeModNoMessages(grassmove.pbType(attacker), attacker, opponent, grassmove).superEffective?
        end
      when :FLASHFIRE, :WELLBAKEDBODY
        for i in attacker.moves
          next if i.nil?

          firemove = i if i.pbType(attacker) == :FIRE
         end
        if attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :FIRE }
          abilityscore *= 3 if attacker.moves.all? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :FIRE }
          abilityscore *= 2 if pbTypeModNoMessages(firemove.pbType(attacker), attacker, opponent, firemove).superEffective?
        end
      when *PBStuff::LevitateAbilities, :EARTHEATER
        abilityscore *= 1.1 if opponent.ability == :EELEVATE # additional Beast Boost scoring

        return 0 if canGroundMoveHit?(opponent) || !canGroundMoveHit?(opponent, nil, true)
        # No good if already can hit with ground move due to some other effect, or if won't be able to hit with ground move even after bypassing ability

        groundmove = attacker.moves.find { |moveloop| moveloop && moveloop.pbIsDamaging? && moveloop.pbType(attacker) == :GROUND }
        if groundmove
          abilityscore *= 3 if attacker.moves.all? { |moveloop| moveloop && (moveloop.pbIsStatus? || moveloop.pbType(attacker) == :GROUND) }
          abilityscore *= 2 if pbTypeModNoMessages(groundmove.pbType(attacker), attacker, opponent, groundmove).superEffective?
        end
        if opponent.ability != :EARTHEATER && applydscode
          abilityscore *= dynamicspeedcode(:removeability, 4.0 / 3) if @battle.FE == :NEWWORLD || ([:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE) && !opponent.hasType?(:WATER))
        end
      when :SHADOWTAG
        abilityscore *= 1.5 if !attacker.hasType?(:GHOST) || @battle.FE == :DIMENSIONAL
      when :ARENATRAP
        abilityscore *= 1.5 if !attacker.isAirborne?
      when :WONDERGUARD
        abilityscore *= 5 if !attacker.moves.any? { |moveloop| moveloop != nil && pbTypeModNoMessages(moveloop.pbType(attacker), attacker, opponent, moveloop).superEffective? }
      when :SERENEGRACE
        abilityscore *= 1.3
      when :PUREPOWER, :HUGEPOWER
        abilityscore *= 2
      when :SOUNDPROOF
        abilityscore *= 3 if attacker.moves.all? { |moveloop| moveloop != nil && (moveloop.checkSoundMove?(attacker) || moveloop.pbIsStatus?) }
      when :THICKFAT
        abilityscore *= 1.5 if attacker.moves.all? { |moveloop| moveloop != nil && (moveloop.pbType(attacker) == :FIRE || moveloop.pbType(attacker) == :ICE) }
      when :TRUANT
        abilityscore *= 0.1
      when :GUTS, :QUICKFEET, :MARVELSCALE
        if !opponent.status.nil?
          abilityscore *= 1.5
          abilityscore *= dynamicspeedcode(:removeability, 1.5) if opponent.ability == :QUICKFEET && opponent.quickFeetActive? && applydscode
        end
      when :LIQUIDOOZE
        abilityscore *= 2 if opponent.effects[:LeechSeed] >= 0 || attacker.pbHasMove?(:LEECHSEED)
      when :AIRLOCK, :CLOUDNINE
        abilityscore *= 1.1
      when :HYDRATION
        abilityscore *= 1.3 if attacker.hydrationActive?
      when :ADAPTABILITY
        abilityscore *= 1.3
      when :SKILLLINK
        abilityscore *= 1.5
      when :POISONHEAL
        abilityscore *= 2 if opponent.status == :POISON
      when :NORMALIZE
        abilityscore *= 0.6
      when :MAGICGUARD
        abilityscore *= 1.4
      when :STALL
        abilityscore *= 0.5
      when :TECHNICIAN
        abilityscore *= 1.3
      when :MOLDBREAKER, :TERAVOLT, :TURBOBLAZE
        abilityscore *= 1.1
      when :UNAWARE
        abilityscore *= 1.7
      when :SLOWSTART
        abilityscore *= 0.3
      when :SHEERFORCE
        abilityscore *= 1.2
      when :CONTRARY
        abilityscore *= 1.4
        abilityscore *= 2 if opponent.stages[PBStats::ATTACK] > 0 || opponent.stages[PBStats::SPATK] > 0 || opponent.stages[PBStats::DEFENSE] > 0 || opponent.stages[PBStats::SPDEF] > 0 || opponent.stages[PBStats::SPEED] > 0
      when :DEFEATIST
        abilityscore *= 0.5
      when :MULTISCALE, :TERASHELL
        abilityscore *= 1.5 if opponent.hp == opponent.totalhp
      when :HARVEST
        abilityscore *= 1.2
      when :MOODY
        abilityscore *= 1.8
      when :PRANKSTER
        abilityscore *= 1.5 if pbAIfaster?(nil, nil, attacker, opponent)
      when :SNOWCLOAK
        abilityscore *= 1.3 if [:HAIL, :SNOW].include?(@battle.pbWeather(nil))
      when :FURCOAT
        abilityscore *= 1.5 if attacker.attack > attacker.spatk
      when :PARENTALBOND
        abilityscore *= 3
      when :PROTEAN, :LIBERO
        abilityscore *= 3 if (Gen < 9 || !Rejuv)
      when :TOUGHCLAWS
        abilityscore *= 1.2
      when :BEASTBOOST
        abilityscore *= 1.1
      when :COMATOSE
        abilityscore *= 1.3
      when :FLUFFY
        abilityscore *= 1.5
        abilityscore *= 0.5 if attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :FIRE && moveloop.pbIsDamaging? && !attacker.makesContact?(moveloop) }
      when :AURAGUARD
        abilityscore *= 1.5
      when :MERCILESS
        abilityscore *= 1.3
      when :WATERBUBBLE
        abilityscore *= 1.5
        abilityscore *= 1.3 if attacker.moves.any? { |moveloop| moveloop != nil && moveloop.pbType(attacker) == :FIRE && moveloop.pbIsDamaging? }
      when :ICESCALES
        abilityscore *= 1.5 if attacker.spatk > attacker.attack
      when :WINDPOWER
        attacker.moves.each { |move| abilityscore *= 1.1 if move && move.windMove? && move.move != :SANDSTORM }
      when :WINDRIDER
        attacker.moves.each { |move|
          if move && move.windMove? && move.move != :SANDSTORM
            abilityscore *= pbTypeModNoMessages(move.pbType(attacker), attacker, opponent, move).superEffective? ? 1.8 : 1.4
          end
        }
      when :CHLOROPHYLL
        abilityscore *= dynamicspeedcode(:removeability, 2.0) if opponent.chlorophyllActive? && applydscode
      when :SWIFTSWIM
        abilityscore *= dynamicspeedcode(:removeability, 2.0) if opponent.swiftSwimActive? && applydscode
      when :SANDRUSH
        abilityscore *= dynamicspeedcode(:removeability, 2.0) if opponent.sandRushActive? && applydscode
      when :SLUSHRUSH
        abilityscore *= dynamicspeedcode(:removeability, 2.0) if opponent.slushRushActive? && !(opponent.crested == :EMPOLEON || (opponent.crested == :CASTFORM && opponent.form == 3)) && applydscode
      when :SURGESURFER
        abilityscore *= dynamicspeedcode(:removeability, 2.0) if opponent.surgeSurferActive? && applydscode
      when :TELEPATHY
        abilityscore *= dynamicspeedcode(:removeability, 2.0) if opponent.telepathyActive? && applydscode
      when :UNBURDEN
        abilityscore *= dynamicspeedcode(:removeability, 2.0) if opponent.unburdened && applydscode
      when :QUARKDRIVE, :PROTOSYNTHESIS
        effect = opponent.ability == :QUARKDRIVE ? :Quarkdrive : :Protosynthesis
        abilityscore *= dynamicspeedcode(:removeability, 1.5) if opponent.effects[effect][0] == PBStats::SPEED && applydscode
      when :CUDCHEW
        abilityscore *= 1.1 if pbIsBerry?(opponent.item) || opponent.effects[:CudChewBerry] != nil
      when :MYCELIUMMIGHT
        abilityscore *= 0.8
      when :MEGASOL
        abilityscore *= 1.5
      when :FLOWERGIFT
        abilityscore *= 2.0 if opponent.crested == :CHERRIM || @battle.pbWeather(nil) == :SUNNYDAY
      when :SPICYSPRAY
        abilityscore *= 1.3 if attacker.pbCanBurn?(opponent, nil)
      else
        if attacker.pbPartner == opponent && abilityscore != 0
          abilityscore = 200 if abilityscore > 200
          tempscore = abilityscore
          abilityscore = 200 - tempscore
        end
    end
    abilityscore *= 0.01
    return abilityscore
  end

  def getFieldDisruptScore(attacker = @attacker, opponent = @opponent, fieldeffect = @battle.FE, violent = false, tempOnly: false)
    fieldscore = 100.0
    aroles = pbGetMonRoles(attacker)
    oroles = pbGetMonRoles(opponent)
    aimem = getAIMemory(opponent)
    overlay = Overlays && tempOnly
    fieldeffect = @battle.OV if overlay
    case fieldeffect
      when :INDOOR # No field
      when :ELECTERRAIN # Electric Terrain
        fieldscore *= 1.5 if opponent.hasType?(:ELECTRIC) || opponent.pbPartner.hasType?(:ELECTRIC)
        fieldscore *= 0.5 if attacker.hasType?(:ELECTRIC)
        fieldscore *= 0.5 if pbPartyHasType?(:ELECTRIC)
        fieldscore *= 1.3 if opponent.ability == :SURGESURFER
        fieldscore *= 0.7 if attacker.ability == :SURGESURFER
      when :GRASSY # Grassy Terrain
        fieldscore *= 1.5 if opponent.hasType?(:GRASS) || opponent.pbPartner.hasType?(:GRASS)
        fieldscore *= 0.5 if attacker.hasType?(:GRASS)
        fieldscore *= 0.5 if pbPartyHasType?(:GRASS)
        unless overlay
          fieldscore *= 1.8 if opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
          fieldscore *= 0.2 if attacker.hasType?(:FIRE)
          fieldscore *= 0.2 if pbPartyHasType?(:FIRE)
        end
        fieldscore *= 1.3 if attacker.hasType?(:WATER)
        fieldscore *= 1.5 if pbPartyHasType?(:WATER)
        fieldscore *= 0.8 if aroles.include?(:SPECIALWALL) || aroles.include?(:PHYSICALWALL)
        fieldscore *= 1.2 if oroles.include?(:SPECIALWALL) || oroles.include?(:PHYSICALWALL)
      when :MISTY # Misty Terrain
        unless overlay
          fieldscore *= 1.3 if attacker.spatk > attacker.attack && (opponent.hasType?(:FAIRY) || opponent.pbPartner.hasType?(:FAIRY))
          fieldscore *= 0.7 if attacker.hasType?(:FAIRY) && opponent.spatk > opponent.attack
          fieldscore *= 0.5 if opponent.hasType?(:DRAGON) || opponent.pbPartner.hasType?(:DRAGON)
          fieldscore *= 1.5 if attacker.hasType?(:DRAGON)
          fieldscore *= 1.5 if pbPartyHasType?(:DRAGON)
          fieldscore *= 1.8 if @battle.field.counter == 1 && !(attacker.hasType?(:POISON) || attacker.hasType?(:STEEL))
        end
        fieldscore *= 0.7 if pbPartyHasType?(:FAIRY)
      when :DARKCRYSTALCAVERN # Dark Crystal Cavern
        fieldscore *= 1.3 if opponent.hasType?(:DARK) || opponent.pbPartner.hasType?(:DARK) || opponent.hasType?(:GHOST) || opponent.pbPartner.hasType?(:GHOST)
        fieldscore *= 0.7 if attacker.hasType?(:DARK) || attacker.hasType?(:GHOST)
        fieldscore *= 0.7 if pbPartyHasType?(:DARK) || pbPartyHasType?(:GHOST)
      when :CHESS # Chess field
        fieldscore *= 1.3 if opponent.hasType?(:PSYCHIC) || opponent.pbPartner.hasType?(:PSYCHIC)
        fieldscore *= 0.7 if attacker.hasType?(:PSYCHIC)
        fieldscore *= 0.7 if pbPartyHasType?(:PSYCHIC)
        fieldscore *= attacker.pbSpeed > opponent.pbSpeed ? 1.3 : 0.7
      when :BIGTOP # Big Top field
        fieldscore *= 1.5 if opponent.hasType?(:FIGHTING) || opponent.pbPartner.hasType?(:FIGHTING)
        fieldscore *= 0.5 if attacker.hasType?(:FIGHTING)
        fieldscore *= 0.5 if pbPartyHasType?(:FIGHTING)
        fieldscore *= 1.5 if opponent.ability == :DANCER
        fieldscore *= 0.5 if attacker.ability == :DANCER
        fieldscore *= 0.5 if attacker.pbHasMove?(:SING, :DRAGONDANCE, :QUIVERDANCE)
        fieldscore *= 1.5 if checkAImoves([:SING, :DRAGONDANCE, :QUIVERDANCE], aimem)
      when :BURNING # Burning Field
        fieldscore *= 1.8 if opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
        if attacker.hasType?(:FIRE)
          fieldscore *= 0.2
        else
          fieldscore *= 1.5
          fieldscore *= 1.8 if attacker.hasType?(:GRASS) || attacker.hasType?(:ICE) || attacker.hasType?(:BUG) || attacker.hasType?(:STEEL)
        end
        fieldscore *= 0.2 if pbPartyHasType?(:FIRE)
        fieldscore *= 1.5 if pbPartyHasType?(:GRASS) || pbPartyHasType?(:ICE) || pbPartyHasType?(:BUG) || pbPartyHasType?(:STEEL)
      when :SWAMP # Swamp field
        fieldscore *= 0.7 if attacker.pbHasMove?(:SLEEPPOWDER)
        fieldscore *= 1.3 if checkAImoves([:SLEEPPOWDER], aimem)
      when :RAINBOW # Rainbow field
        fieldscore *= 1.5 if opponent.hasType?(:NORMAL) || opponent.pbPartner.hasType?(:NORMAL)
        fieldscore *= 0.5 if attacker.hasType?(:NORMAL)
        fieldscore *= 0.5 if pbPartyHasType?(:NORMAL)
        fieldscore *= 1.4 if opponent.ability == :CLOUDNINE
        fieldscore *= 0.6 if attacker.ability == :CLOUDNINE
        fieldscore *= 0.8 if attacker.pbHasMove?(:SONICBOOM)
        fieldscore *= 1.2 if checkAImoves([:SONICBOOM], aimem)
      when :CORROSIVE # Corrosive field
        fieldscore *= 1.3 if opponent.hasType?(:POISON) || opponent.pbPartner.hasType?(:POISON)
        fieldscore *= 0.7 if attacker.hasType?(:POISON)
        fieldscore *= 0.7 if pbPartyHasType?(:POISON)
        fieldscore *= 1.5 if opponent.ability == :CORROSION
        fieldscore *= 0.5 if attacker.ability == :CORROSION
        fieldscore *= 0.7 if attacker.pbHasMove?(:SLEEPPOWDER)
        fieldscore *= 1.3 if checkAImoves([:SLEEPPOWDER], aimem)
      when :CORROSIVEMIST # Corromist field
        if violent
          if !opponent.effects[:Protect] && !opponent.effects[:SkyDrop] &&
             !(PBStuff::SEMIINVULMOVE.include?(opponent.effects[:TwoTurnAttack]) && pbAIfaster?(nil, nil, attacker, opponent)) &&
             opponent.ability != :FLASHFIRE
            fieldscore *= 2 if attacker.hp.to_f / attacker.totalhp < 0.2
            fieldscore *= 5 if opponent.pbNonActivePokemonCount == 0
          end
        end
        fieldscore *= 1.3 if opponent.hasType?(:POISON) || opponent.pbPartner.hasType?(:POISON)
        if attacker.hasType?(:POISON)
          fieldscore *= 0.7
        elsif !attacker.hasType?(:STEEL)
          fieldscore *= 1.4
        end
        fieldscore *= 1.4 if !pbPartyHasType?(:POISON)
        fieldscore *= 1.5 if opponent.ability == :CORROSION
        fieldscore *= 0.5 if attacker.ability == :CORROSION
        fieldscore *= 1.5 if opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
        fieldscore *= 0.8  if attacker.hasType?(:FIRE)
        fieldscore *= 0.8  if pbPartyHasType?(:FIRE)
      when :DESERT # Desert field
        fieldscore *= 1.3 if attacker.spatk > attacker.attack && (opponent.hasType?(:GROUND) || opponent.pbPartner.hasType?(:GROUND))
        fieldscore *= 0.7 if opponent.spatk > opponent.attack && (attacker.hasType?(:GROUND))
        fieldscore *= 1.5 if attacker.hasType?(:ELECTRIC) || attacker.hasType?(:WATER)
        fieldscore *= 0.5 if opponent.hasType?(:ELECTRIC) || opponent.pbPartner.hasType?(:WATER)
        fieldscore *= 0.7 if pbPartyHasType?(:GROUND)
        fieldscore *= 1.5 if pbPartyHasType?(:WATER) || pbPartyHasType?(:ELECTRIC)
        fieldscore *= 1.3 if opponent.ability == :SANDRUSH && @battle.pbWeather(nil) != :SANDSTORM
        fieldscore *= 0.7 if attacker.ability == :SANDRUSH && @battle.pbWeather(nil) != :SANDSTORM
      when :ICY # Icy field
        fieldscore *= 1.3 if opponent.hasType?(:ICE) || opponent.pbPartner.hasType?(:ICE)
        fieldscore *= 0.5 if attacker.hasType?(:ICE)
        fieldscore *= 0.5 if pbPartyHasType?(:ICE)
        fieldscore *= 0.5 if opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
        fieldscore *= 1.1 if attacker.hasType?(:FIRE)
        fieldscore *= 1.1 if pbPartyHasType?(:FIRE)
        fieldscore *= 1.3 if opponent.ability == :ICESCALES
        fieldscore *= 0.7 if attacker.ability == :ICESCALES
        fieldscore *= 1.3 if (opponent.ability == :SLUSHRUSH || opponent.crested == :EMPOLEON || (opponent.crested == :CASTFORM && opponent.form == 3)) && ![:HAIL, :SNOW].include?(@battle.pbWeather(nil))
        fieldscore *= 0.7 if (attacker.ability == :SLUSHRUSH || attacker.crested == :EMPOLEON || (attacker.crested == :CASTFORM && attacker.form == 3)) && ![:HAIL, :SNOW].include?(@battle.pbWeather(nil))
      when :ROCKY # Rocky field
        fieldscore *= 1.5 if opponent.hasType?(:ROCK) || opponent.pbPartner.hasType?(:ROCK)
        fieldscore *= 0.5 if attacker.hasType?(:ROCK)
        fieldscore *= 0.5 if pbPartyHasType?(:ROCK)
      when :FOREST # Forest field
        fieldscore *= 1.5 if opponent.hasType?(:GRASS) || opponent.hasType?(:BUG) || opponent.pbPartner.hasType?(:GRASS) || opponent.pbPartner.hasType?(:BUG)
        fieldscore *= 0.5 if attacker.hasType?(:GRASS) || attacker.hasType?(:BUG)
        fieldscore *= 0.5 if pbPartyHasType?(:GRASS) || pbPartyHasType?(:BUG)
        fieldscore *= 1.8 if opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
        fieldscore *= 0.2 if attacker.hasType?(:FIRE)
        fieldscore *= 0.2 if pbPartyHasType?(:FIRE)
      when :SUPERHEATED # Superheated field
        fieldscore *= 1.8 if opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
        fieldscore *= 0.2 if attacker.hasType?(:FIRE)
        fieldscore *= 0.2 if pbPartyHasType?(:FIRE)
        fieldscore *= 0.7 if opponent.hasType?(:ICE) || opponent.pbPartner.hasType?(:ICE)
        fieldscore *= 1.5 if attacker.hasType?(:ICE)
        fieldscore *= 1.5 if pbPartyHasType?(:ICE)
        fieldscore *= 0.8 if opponent.hasType?(:WATER) || opponent.pbPartner.hasType?(:WATER)
        fieldscore *= 1.2 if attacker.hasType?(:WATER)
        fieldscore *= 1.2 if pbPartyHasType?(:WATER)
      when :FACTORY # Factory field
        fieldscore *= 1.2 if opponent.hasType?(:ELECTRIC) || opponent.pbPartner.hasType?(:ELECTRIC)
        fieldscore *= 0.8 if attacker.hasType?(:ELECTRIC)
        fieldscore *= 0.8 if pbPartyHasType?(:ELECTRIC)
      when :SHORTCIRCUIT # Short-Circuit field
        fieldscore *= 1.4 if opponent.hasType?(:ELECTRIC) || opponent.pbPartner.hasType?(:ELECTRIC)
        fieldscore *= 0.6 if attacker.hasType?(:ELECTRIC)
        fieldscore *= 0.6 if pbPartyHasType?(:ELECTRIC)
        fieldscore *= 1.3 if opponent.ability == :SURGESURFER
        fieldscore *= 0.7 if attacker.ability == :SURGESURFER
        fieldscore *= 1.3 if opponent.hasType?(:DARK) || opponent.pbPartner.hasType?(:DARK) || opponent.hasType?(:GHOST) || opponent.pbPartner.hasType?(:GHOST)
        fieldscore *= 0.7 if attacker.hasType?(:DARK) || attacker.hasType?(:GHOST)
        fieldscore *= 0.7 if pbPartyHasType?(:DARK) || pbPartyHasType?(:GHOST)
      when :WASTELAND # Wasteland field
        fieldscore *= 1.3 if opponent.hasType?(:POISON) || opponent.pbPartner.hasType?(:POISON)
        fieldscore *= 0.7 if attacker.hasType?(:POISON)
        fieldscore *= 0.7 if pbPartyHasType?(:POISON)
      when :ASHENBEACH # Ashen Beach field
        fieldscore *= 1.3 if opponent.hasType?(:FIGHTING) || opponent.pbPartner.hasType?(:FIGHTING) || opponent.hasType?(:PSYCHIC) || opponent.pbPartner.hasType?(:PSYCHIC)
        fieldscore *= 0.7 if attacker.hasType?(:FIGHTING) || attacker.hasType?(:PSYCHIC)
        fieldscore *= 0.7 if pbPartyHasType?(:FIGHTING) || pbPartyHasType?(:PSYCHIC)
        fieldscore *= 1.3 if opponent.ability == :SANDRUSH && @battle.pbWeather(nil) != :SANDSTORM
        fieldscore *= 0.7 if attacker.ability == :SANDRUSH && @battle.pbWeather(nil) != :SANDSTORM
      when :WATERSURFACE # Water Surface field
        fieldscore *= 1.6 if opponent.hasType?(:WATER) || opponent.pbPartner.hasType?(:WATER)
        if attacker.hasType?(:WATER)
          fieldscore *= 0.4
        elsif !attacker.isAirborne?
          fieldscore *= 1.3
        end
        fieldscore *= 0.4 if pbPartyHasType?(:WATER)
        fieldscore *= 1.3 if opponent.ability == :SWIFTSWIM && @battle.pbWeather(nil) != :RAINDANCE
        fieldscore *= 0.7 if attacker.ability == :SWIFTSWIM && @battle.pbWeather(nil) != :RAINDANCE
        fieldscore *= 1.3 if opponent.ability == :SURGESURFER
        fieldscore *= 0.7 if attacker.ability == :SURGESURFER
        fieldscore *= 1.3 if !attacker.hasType?(:POISON) && @battle.field.counter == 1
      when :UNDERWATER # Underwater field
        fieldscore *= 2.0 if opponent.hasType?(:WATER) || opponent.pbPartner.hasType?(:WATER)
        if attacker.hasType?(:WATER)
          fieldscore *= 0.1
        else
          fieldscore *= 1.5
          fieldscore *= 2 if attacker.hasType?(:ROCK) || attacker.hasType?(:GROUND)
        end
        fieldscore *= 1.2 if attacker.attack > attacker.spatk
        fieldscore *= 0.8 if opponent.attack > opponent.spatk
        fieldscore *= 0.1 if pbPartyHasType?(:WATER)
        fieldscore *= 0.9 if opponent.ability == :SWIFTSWIM
        fieldscore *= 1.1 if attacker.ability == :SWIFTSWIM
        fieldscore *= 1.3 if !attacker.hasType?(:POISON) && @battle.field.counter == 1
      when :CAVE # Cave field
        fieldscore *= 1.5 if opponent.hasType?(:ROCK) || opponent.pbPartner.hasType?(:ROCK)
        fieldscore *= 0.5 if attacker.hasType?(:ROCK)
        fieldscore *= 0.5 if pbPartyHasType?(:ROCK)
        fieldscore *= 1.2 if opponent.hasType?(:GROUND) || opponent.pbPartner.hasType?(:GROUND)
        fieldscore *= 0.8 if attacker.hasType?(:GROUND)
        fieldscore *= 0.8 if pbPartyHasType?(:GROUND)
        fieldscore *= 0.7 if opponent.hasType?(:FLYING) || opponent.pbPartner.hasType?(:FLYING)
        fieldscore *= 1.3 if attacker.hasType?(:FLYING)
        fieldscore *= 1.3 if pbPartyHasType?(:FLYING)
      when :GLITCH # Glitch field
        fieldscore *= 1.3 if attacker.hasType?(:DARK) || attacker.hasType?(:STEEL) || attacker.hasType?(:FAIRY)
        fieldscore *= 1.3 if pbPartyHasType?(:DARK) || pbPartyHasType?(:STEEL) || pbPartyHasType?(:FAIRY)
        ratio1 = attacker.spatk / attacker.spdef.to_f
        ratio2 = attacker.spdef / attacker.spatk.to_f
        if ratio1 < 1
          fieldscore *= ratio1
        elsif ratio2 < 1
          fieldscore *= ratio2
        end
        oratio1 = opponent.spatk / attacker.spdef.to_f
        oratio2 = opponent.spdef / attacker.spatk.to_f
        if oratio1 > 1
          fieldscore *= oratio1
        elsif oratio2 > 1
          fieldscore *= oratio2
        end
      when :CRYSTALCAVERN # Crystal Cavern field
        fieldscore *= 1.5 if opponent.hasType?(:ROCK) || opponent.pbPartner.hasType?(:ROCK) || opponent.hasType?(:DRAGON) || opponent.pbPartner.hasType?(:DRAGON)
        fieldscore *= 0.5 if attacker.hasType?(:ROCK) || attacker.hasType?(:DRAGON)
        fieldscore *= 0.5 if pbPartyHasType?(:ROCK) || pbPartyHasType?(:DRAGON)
      when :MURKWATERSURFACE # Murkwater Surface field
        fieldscore *= 1.6 if opponent.hasType?(:WATER) || opponent.pbPartner.hasType?(:WATER)
        if attacker.hasType?(:WATER)
          fieldscore *= 0.4
        elsif !attacker.isAirborne?
          fieldscore *= 1.3
        end
        fieldscore *= 0.4 if pbPartyHasType?(:WATER)
        fieldscore *= 1.3 if opponent.ability == :SWIFTSWIM && @battle.pbWeather(nil) != :RAINDANCE
        fieldscore *= 0.7 if attacker.ability == :SWIFTSWIM && @battle.pbWeather(nil) != :RAINDANCE
        fieldscore *= 1.3 if opponent.ability == :SURGESURFER
        fieldscore *= 0.7 if attacker.ability == :SURGESURFER
        fieldscore *= 1.3 if opponent.hasType?(:STEEL) || opponent.pbPartner.hasType?(:STEEL) || opponent.hasType?(:POISON) || opponent.pbPartner.hasType?(:POISON)
        if attacker.hasType?(:POISON)
          fieldscore *= 0.7
        elsif !attacker.hasType?(:STEEL)
          fieldscore *= 1.8
        end
        fieldscore *= 0.7 if pbPartyHasType?(:POISON)
      when :MOUNTAIN # Mountain field
        fieldscore *= 1.5 if opponent.hasType?(:ROCK) || opponent.pbPartner.hasType?(:ROCK) || opponent.hasType?(:FLYING) || opponent.pbPartner.hasType?(:FLYING)
        fieldscore *= 0.5 if attacker.hasType?(:ROCK) || attacker.hasType?(:FLYING)
        fieldscore *= 0.5 if pbPartyHasType?(:ROCK) || pbPartyHasType?(:FLYING)
      when :SNOWYMOUNTAIN # Snowy Mountain field
        fieldscore *= 1.5 if opponent.hasType?(:ROCK) || opponent.pbPartner.hasType?(:ROCK) || opponent.hasType?(:FLYING) || opponent.pbPartner.hasType?(:FLYING) || opponent.hasType?(:ICE) || opponent.pbPartner.hasType?(:ICE)
        fieldscore *= 0.5 if attacker.hasType?(:ROCK) || attacker.hasType?(:FLYING) || attacker.hasType?(:ICE)
        fieldscore *= 0.5 if pbPartyHasType?(:ROCK) || pbPartyHasType?(:FLYING) || pbPartyHasType?(:ICE)
        fieldscore *= 0.5 if opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
        fieldscore *= 1.5 if attacker.hasType?(:FIRE)
        fieldscore *= 1.5 if pbPartyHasType?(:FIRE)
        fieldscore *= 1.3 if opponent.ability == :ICESCALES
        fieldscore *= 0.7 if attacker.ability == :ICESCALES
        fieldscore *= 1.3 if (opponent.ability == :SLUSHRUSH || opponent.crested == :EMPOLEON || (opponent.crested == :CASTFORM && opponent.form == 3)) && ![:HAIL, :SNOW].include?(@battle.pbWeather(nil))
        fieldscore *= 0.7 if (attacker.ability == :SLUSHRUSH || attacker.crested == :EMPOLEON || (attacker.crested == :CASTFORM && attacker.form == 3)) && ![:HAIL, :SNOW].include?(@battle.pbWeather(nil))
      when :HOLY # Holy field
        fieldscore *= 1.4 if opponent.hasType?(:NORMAL) || opponent.pbPartner.hasType?(:NORMAL) || opponent.hasType?(:FAIRY) || opponent.pbPartner.hasType?(:FAIRY)
        fieldscore *= 0.6 if attacker.hasType?(:NORMAL) || attacker.hasType?(:FAIRY)
        fieldscore *= 0.6 if pbPartyHasType?(:NORMAL) || pbPartyHasType?(:FAIRY)
        fieldscore *= 0.5 if opponent.hasType?(:DARK) || opponent.pbPartner.hasType?(:DARK) || opponent.hasType?(:GHOST) || opponent.pbPartner.hasType?(:GHOST)
        fieldscore *= 1.5 if attacker.hasType?(:DARK) || attacker.hasType?(:GHOST)
        fieldscore *= 1.5 if pbPartyHasType?(:DARK) || pbPartyHasType?(:GHOST)
        fieldscore *= 1.2 if opponent.hasType?(:DRAGON) || opponent.pbPartner.hasType?(:DRAGON) || opponent.hasType?(:PSYCHIC) || opponent.pbPartner.hasType?(:PSYCHIC)
        fieldscore *= 0.8 if attacker.hasType?(:DRAGON) || attacker.hasType?(:PSYCHIC)
        fieldscore *= 0.8 if pbPartyHasType?(:DRAGON) || pbPartyHasType?(:PSYCHIC)
      when :HAUNTED
        fieldscore *= 1.4 if opponent.hasType?(:GHOST) || opponent.pbPartner.hasType?(:GHOST) || opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
        fieldscore *= 0.6 if attacker.hasType?(:GHOST) || attacker.hasType?(:FIRE)
        fieldscore *= 1.5 if attacker.hasType?(:NORMAL) || attacker.hasType?(:PSYCHIC) || attacker.hasType?(:DRAGON) || attacker.hasType?(:FAIRY)
        fieldscore *= 1.5 if pbPartyHasType?(:NORMAL) || pbPartyHasType?(:PSYCHIC) || pbPartyHasType?(:DRAGON) || pbPartyHasType?(:FAIRY)
      when :MIRROR # Mirror field
        if violent
          if opponent.stages[PBStats::EVASION] > 0 || (@mondata.oppitemworks && opponent.item == :BRIGHTPOWDER) ||
             (@mondata.oppitemworks && opponent.item == :LAXINCENSE) || accuracyWeatherAbilityActive?(opponent, attacker)
            fieldscore *= 1.3
          else
            fieldscore *= 0.5
          end
        end
        fieldscore *= 1 + 0.1 * opponent.stages[PBStats::ACCURACY]
        fieldscore *= 1 + 0.1 * opponent.stages[PBStats::EVASION]
        fieldscore *= 1 - 0.1 * attacker.stages[PBStats::ACCURACY]
        fieldscore *= 1 - 0.1 * attacker.stages[PBStats::EVASION]
      when :FAIRYTALE # Fairytale field
        fieldscore *= 1.5 if opponent.hasType?(:DRAGON) || opponent.pbPartner.hasType?(:DRAGON) || opponent.hasType?(:STEEL) || opponent.pbPartner.hasType?(:STEEL) || opponent.hasType?(:FAIRY) || opponent.pbPartner.hasType?(:FAIRY)
        fieldscore *= 0.5 if attacker.hasType?(:DRAGON) || attacker.hasType?(:STEEL) || attacker.hasType?(:FAIRY)
        fieldscore *= 0.5 if pbPartyHasType?(:DRAGON) || pbPartyHasType?(:STEEL) || pbPartyHasType?(:FAIRY)
        fieldscore *= 1.3 if opponent.ability == :STANCECHANGE
        fieldscore *= 0.7 if attacker.ability == :STANCECHANGE
      when :DRAGONSDEN # Dragon's Den field
        fieldscore *= 1.7 if opponent.hasType?(:DRAGON) || opponent.pbPartner.hasType?(:DRAGON)
        fieldscore *= 0.3 if attacker.hasType?(:DRAGON)
        fieldscore *= 0.3 if pbPartyHasType?(:DRAGON)
        fieldscore *= 1.5 if opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
        fieldscore *= 0.5 if attacker.hasType?(:FIRE)
        fieldscore *= 0.5 if pbPartyHasType?(:FIRE)
        fieldscore *= 1.3 if opponent.ability == :MULTISCALE || opponent.ability == :GOODASGOLD
        fieldscore *= 0.7 if attacker.ability == :MULTISCALE || opponent.ability == :GOODASGOLD
      when :FLOWERGARDEN4 # Flower Garden field
        fieldscore *= 1.5  if opponent.hasType?(:BUG) || opponent.pbPartner.hasType?(:BUG) || opponent.hasType?(:GRASS) || opponent.pbPartner.hasType?(:GRASS)
        fieldscore *= 0.33 if attacker.hasType?(:GRASS) || attacker.hasType?(:BUG)
        fieldscore *= 0.33 if pbPartyHasType?(:BUG) || pbPartyHasType?(:GRASS)
        fieldscore *= 1.2  if opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
        fieldscore *= 0.33 if attacker.hasType?(:FIRE)
        fieldscore *= 0.33 if pbPartyHasType?(:FIRE)
      when :FLOWERGARDEN5 # Flower Garden field
        fieldscore *= 2.0  if opponent.hasType?(:BUG) || opponent.pbPartner.hasType?(:BUG) || opponent.hasType?(:GRASS) || opponent.pbPartner.hasType?(:GRASS)
        fieldscore *= 0.25 if attacker.hasType?(:GRASS) || attacker.hasType?(:BUG)
        fieldscore *= 0.25 if pbPartyHasType?(:BUG) || pbPartyHasType?(:GRASS)
        fieldscore *= 1.6  if opponent.hasType?(:FIRE) || opponent.pbPartner.hasType?(:FIRE)
        fieldscore *= 0.25 if attacker.hasType?(:FIRE)
        fieldscore *= 0.25 if pbPartyHasType?(:FIRE)
      when :STARLIGHT # Starlight Arena field
        fieldscore *= 1.5 if opponent.hasType?(:PSYCHIC) || opponent.pbPartner.hasType?(:PSYCHIC)
        fieldscore *= 0.5 if attacker.hasType?(:PSYCHIC)
        fieldscore *= 0.5 if pbPartyHasType?(:PSYCHIC)
        fieldscore *= 1.3 if opponent.hasType?(:FAIRY) || opponent.pbPartner.hasType?(:FAIRY) || opponent.hasType?(:DARK) || opponent.pbPartner.hasType?(:DARK)
        fieldscore *= 0.7 if attacker.hasType?(:FAIRY) || attacker.hasType?(:DARK)
        fieldscore *= 0.7 if pbPartyHasType?(:FAIRY) || pbPartyHasType?(:DARK)
      when :NEWWORLD # New World field
      # fieldscore = 0
      when :INVERSE # Inverse field
        fieldscore *= 1.7 if opponent.hasType?(:NORMAL) || opponent.pbPartner.hasType?(:NORMAL)
        fieldscore *= 0.3 if attacker.hasType?(:NORMAL)
        fieldscore *= 0.3 if pbPartyHasType?(:NORMAL)
        fieldscore *= 1.5 if opponent.hasType?(:ICE) || opponent.pbPartner.hasType?(:ICE)
        fieldscore *= 0.5 if attacker.hasType?(:ICE)
        fieldscore *= 0.5 if pbPartyHasType?(:ICE)
      when :PSYTERRAIN # Psychic Terrain
        fieldscore *= 1.7 if opponent.hasType?(:PSYCHIC) || opponent.pbPartner.hasType?(:PSYCHIC)
        fieldscore *= 0.3 if attacker.hasType?(:PSYCHIC)
        fieldscore *= 0.3 if pbPartyHasType?(:PSYCHIC)
        unless overlay
          fieldscore *= 1.3 if opponent.ability == :TELEPATHY
          fieldscore *= 0.7 if attacker.ability == :TELEPATHY
        end
    end
    fieldscore *= 0.01
    return fieldscore
  end

  ################################################################################
  # Item score functions
  ################################################################################

  def getItemScore
    # check if we have items
    @mondata.itemscore = {}
    return if !@battle.internalbattle
    return if @attacker.effects[:Embargo] > 0

    items = @battle.pbGetOwnerItems(@index)
    return if !items || items.empty?

    party = @battle.pbPartySingleOwner(@attacker.index)
    opponent1 = @attacker.pbOppositeOpposing
    return if @attacker.isFainted?

    maxplaypri = -1
    partynumber = 0
    aimem = getAIMemory(opponent1)
    for i in party
      next if i.nil?
      next if i.hp == 0

      partynumber += 1
    end
    # highest score
    for i in 0...@attacker.moves.length
      next if @attacker.moves[i].nil?

      if @mondata.roughdamagearray.transpose[i].max >= 100 && @attacker.moves[i] && @attacker.moves[i].priorityCheck(@attacker) > maxplaypri
        maxplaypri = @attacker.moves[i].priorityCheck(@attacker)
      end
    end
    highscore = @mondata.roughdamagearray.max { |a, b| a.max <=> b.max }.max
    highdamage = -1
    maxopppri = -1
    pridam = -1
    bestid = -1
    # expected damage
    for i in aimem
      tempdam = pbRoughDamage(i, opponent1, @attacker)
      if tempdam > highdamage
        highdamage = tempdam
        bestid = i.move
      end
      if i.priorityCheck(opponent1) > maxopppri
        maxopppri = i.priorityCheck(opponent1)
        pridam = tempdam
      end
    end
    highdamage = checkAIdamage()
    # expected damage percentage
    highratio = highdamage * (1.0 / @attacker.hp) if @attacker.hp != 0
    PBDebug.dblog(sprintf("\nBeginning AI item use check for battler: #{@attacker.logname}"))

    for i in items
      next @mondata.itemscore[i] = -100000 if $cache.items[i].checkFlag?(:noUseInBattle)
      next @mondata.itemscore[i] = -8000 if $game_switches[:Stop_Items_Password] || $game_switches[:No_Items_Password] || $game_switches[:AI_Play]
      next if @mondata.itemscore.key?(i)

      itemscore = 100

      if $cache.items[i].medicine&.hp
        PBDebug.dblog("This is an HP-healing item.")
        medicinedata = $cache.items[i].medicine
        restoreamount = getItemHP(medicinedata.hp, @attacker.totalhp)
        restoreamount = (restoreamount * 0.67).floor if @battle.FE == :BACKALLEY && ![:MAXPOTION, :FULLRESTORE].include?(i)
        resratio = restoreamount * (1.0 / @attacker.totalhp)
        itemscore *= (2 - (2.0 * @attacker.hp / @attacker.totalhp))
        if highdamage > (@attacker.totalhp - @attacker.hp) # if we take more damage from full than we currently have, don't bother
          itemscore *= 0
        elsif ([@attacker.hp + restoreamount, @attacker.totalhp].min - highdamage) < ((@attacker.totalhp / 4.0) + attacker.hp) # and if we're not gaining at least 25% hp, don't bother
          itemscore *= 0.3
        end
        if highdamage >= @attacker.hp
          if highdamage > [@attacker.hp + restoreamount, @attacker.totalhp].min
            itemscore *= 0
          else
            itemscore *= 1.2
          end
          if @attacker.moves.any? { |moveloop| !moveloop.zmove && moveloop.isHealingMove? && moveloop.move != :WISH }
            if !pbAIfaster?(nil, nil, @attacker, opponent1)
              if highdamage >= @attacker.hp
                itemscore *= 1.1
              else
                itemscore *= 0.6
                itemscore *= 0.2 if resratio < 0.55
              end
            end
          end
        else
          itemscore *= 0.4
        end
        if highdamage > restoreamount
          itemscore *= 0
        elsif restoreamount - highdamage < 15
          itemscore *= 0.5
        end
        if pbAIfaster?(nil, nil, @attacker, opponent1)
          itemscore *= 0.8
          if highscore >= 110
            if maxopppri > maxplaypri
              itemscore *= 1.3
              if pridam > @attacker.hp
                itemscore *= pridam > (@attacker.hp / 2.0) ? 0 : 2
              end
            elsif !notOHKO?(opponent1, @attacker, true) && hpGainPerTurn >= 1
              itemscore *= 0
            end
          end
          itemscore *= 1.1 if @mondata.roles.include?(:SWEEPER)
        else
          if highdamage * 2 > [@attacker.hp + restoreamount, @attacker.totalhp].min
            itemscore *= 0
          else
            itemscore *= 1.5
            itemscore *= 1.5 if highscore >= 110
          end
        end
        if @attacker.hp == @attacker.totalhp
          itemscore *= 0
        elsif @attacker.hp >= (@attacker.totalhp * 0.8)
          itemscore *= 0.2
        elsif @attacker.hp >= (@attacker.totalhp * 0.6)
          itemscore *= 0.3
        elsif @attacker.hp >= (@attacker.totalhp * 0.5)
          itemscore *= 0.5
        end
        minipot = (partynumber - 1)
        minimini = items.count{ |j| $cache.items[j].medicine&.hp } - 1
        if minipot > minimini
          itemscore *= (0.9**(minipot - minimini))
          minipot = minimini
        elsif minimini > minipot
          itemscore *= (1.1**(minimini - minipot))
          minimini = minipot
        end
        itemscore *= 0.6 if @mondata.roles.include?(:LEAD) || @mondata.roles.include?(:SCREENER)
        itemscore *= 1.1 if @mondata.roles.include?(:TANK)
        itemscore *= 1.1 if @mondata.roles.include?(:SECOND)
        itemscore *= 0.9 if hpGainPerTurn > 1
        itemscore *= 1.3 if hpGainPerTurn < 1
        if !@attacker.status.nil? && i != :FULLRESTORE
          itemscore *= 0.7
          itemscore *= 0.2 if @attacker.effects[:Toxic] > 0 && partynumber > 1
        end
        for type in opponent1.types
          eff = PBTypes.typesEff(type, @attacker.types, inverse: @battle.inverse?)
          itemscore *= 0.7 if eff.superEffective?
          itemscore *= 1.1 if eff.resistedOrImmune?
          itemscore *= 1.2 if eff.neutral?
        end
        itemscore *= 0.7 if @attacker.ability == :REGENERATOR && partynumber > 1
      end

      if $cache.items[i].medicine&.status
        PBDebug.dblog("This is a status-curing item.")
        if i != :FULLRESTORE
          itemscore *= 2 if highdamage < @attacker.hp / 2
          itemscore *= 0 if @attacker.status.nil?
          if highdamage > @attacker.hp
            if (bestid == :WAKEUPSLAP && @attacker.status == :SLEEP) || (bestid == :SMELLINGSALTS && @attacker.status == :PARALYSIS) || bestid == :HEX
              itemscore *= highdamage * 0.5 > @attacker.hp ? 0 : 1.4
            else
              itemscore *= 0
            end
          end
          if @attacker.status == :SLEEP && attacker.crested != :SUICUNE
            itemscore *= 0.6 if @attacker.pbHasMove?(:REST, :SLEEPTALK, :SNORE, :FEVERPITCH)
            itemscore *= 1.3 if checkAImoves([:DREAMEATER, :NIGHTMARE], aimem) || opponent1.ability == :BADDREAMS
            itemscore *= highdamage > 0.2 * @attacker.hp ? 1.3 : 0.7
          end
          if @attacker.status == :PARALYSIS && @attacker.crested != :SUICUNE
            itemscore *= 0.5 if @attacker.ability == :QUICKFEET || @attacker.ability == :GUTS
            itemscore *= 1.3 if @attacker.pbSpeed > opponent1.pbSpeed && (@attacker.pbSpeed * 0.5) < opponent1.pbSpeed
            itemscore *= 1.1
          end
          if @attacker.status == :BURN && @attacker.crested != :SUICUNE
            itemscore *= 1.1
            itemscore *= @attacker.attack > @attacker.spatk ? 1.2 : 0.8
            itemscore *= 0.6 if @attacker.ability == :GUTS
            itemscore *= 0.7 if @battle.magicGuardAbilities.include?(@attacker.ability)
            itemscore *= 0.8 if @attacker.ability == :FLAREBOOST
          end
          if @attacker.status == :POISON && @attacker.crested != :SUICUNE
            itemscore *= 1.1
            itemscore *= 0.5 if @attacker.ability == :GUTS
            itemscore *= 0.5 if @battle.magicGuardAbilities.include?(@attacker.ability)
            itemscore *= 0.5 if @attacker.ability == :TOXICBOOST
            itemscore *= 0.2 if @attacker.ability == :POISONHEAL || @attacker.crested == :ZANGOOSE
            itemscore *= 1.1 if @attacker.effects[:Toxic] > 0
            itemscore *= 1.5 if @attacker.effects[:Toxic] > 3
          end
          if @attacker.status == :FROZEN && attacker.crested != :SUICUNE
            itemscore *= 1.3
            itemscore *= 0.5 if @attacker.moves.any? { |moveloop| moveloop != nil && moveloop.canThawUser? }
            itemscore *= highdamage > 0.15 * @attacker.hp ? 1.1 : 0.9
          end
        end
        itemscore *= 0.5 if @attacker.pbHasMove?(:REFRESH, :REST)
        itemscore *= 0.2 if @attacker.ability == :NATURALCURE && partynumber > 1
        itemscore *= 0.3 if @attacker.ability == :SHEDSKIN
      end

      if $cache.items[i].medicine&.xitem
        PBDebug.dblog("This is a stat-raising item.")
        if @attacker.ability == :CONTRARY
          itemscore = 0
        else
          stat, amount = $cache.items[i].medicine.xitem[:stat], $cache.items[i].medicine.xitem[:amount]
          physmove = @attacker.moves.any? { |m| m.pbIsPhysical?(@attacker) }
          specmove = @attacker.moves.any? { |m| m.pbIsSpecial?(@attacker) }
          if (stat == PBStats::ATTACK && !physmove) || (stat == PBStats::SPATK && !specmove) || !@attacker.pbCanIncreaseStatStage?(stat, @attacker, nil)
            itemscore = 0
          else
            itemscore *= 1 + (0.5 * amount)
          end
        end
      end

      # General "Is it a good idea to use an item at all right now" checks
      if partynumber == 1 || @mondata.roles.include?(:ACE)
        itemscore *= 1.2
      else
        itemscore *= 0.8
        itemscore *= 0.6 if @attacker.itemUsed2
      end
      itemscore *= 2 if @attacker.effects[:Toxic] > 3 && i == :FULLRESTORE
      itemscore *= 0.9 if @attacker.effects[:Confusion] > 0
      itemscore *= 0.6 if @attacker.effects[:Attract] >= 0
      itemscore *= 1.1 if @attacker.effects[:Substitute] > 0
      itemscore *= 0.5 if @attacker.effects[:LeechSeed] >= 0
      itemscore *= 0.5 if @attacker.effects[:Curse]
      itemscore *= saltCureGood? ? 0.5 : 0.7 if @attacker.effects[:SaltCure]
      itemscore *= 0.2 if @attacker.effects[:PerishSong] > 0
      minipot = 0
      for s in PBStats::All
        minipot += @attacker.stages[s]
      end
      if @mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL)
        for s in PBStats::Defensive
          minipot += @attacker.stages[s]
        end
      end
      if @mondata.roles.include?(:SWEEPER)
        minipot += @attacker.stages[PBStats::SPEED]
        minipot += @attacker.attack > @attacker.spatk ? @attacker.stages[PBStats::ATTACK] : @attacker.stages[PBStats::SPATK]
      end

      itemscore *= 0.05 * minipot + 1
      itemscore *= 1.2 if opponent1.effects[:TwoTurnAttack] != 0 || opponent1.effects[:HyperBeam] > 0
      itemscore *= highscore > 70 ? 1.1 : 0.9

      fielddisrupt = getFieldDisruptScore(@attacker, opponent1)
      fielddisrupt = 0.6 if fielddisrupt <= 0
      itemscore *= (1.0 / fielddisrupt)

      itemscore *= 0.9 if @battle.state.effects[:TrickRoom] > 0
      itemscore *= 0.6 if @attacker.pbOwnSide.effects[:Tailwind] > 0
      itemscore *= 0.9 if @attacker.pbOwnSide.effects[:Reflect] > 0
      itemscore *= 0.9 if @attacker.pbOwnSide.effects[:LightScreen] > 0
      itemscore *= 0.8 if @attacker.pbOwnSide.effects[:AuroraVeil] > 0
      itemscore *= 0.8 if @battle.doublebattle
      itemscore *= 0.3 if @attacker.effects[:Rollout] > 0
      itemscore -= 100
      itemscore = itemscore.round(1)
      PBDebug.dblog(sprintf("Score for %s: %d", getItemName(i), itemscore)) && !i.nil?
      $ai_log_data[@attacker.index].items.push(getItemName(i))
      $ai_log_data[@attacker.index].items_scores.push(itemscore)
      @mondata.itemscore[i] = itemscore
    end
    # somehow register that this would be the item that should be used
    PBDebug.dblog(sprintf("Highest item score: %d", (@mondata.itemscore.values.max)))
    # score the item if we have it
  end

  ################################################################################
  # Switching functions
  ################################################################################

  def pbChooseNewEnemy(indices, agent)
    # First get scores for each partyindex switching into each empty slot index
    allscoresarray = []
    for index in indices
      $ai_log_data[index].reset(@battle.battlers[index])
      scores = pbDefaultChooseNewEnemyScores(index, agent, doublereplace: indices.length == 2)
      $ai_log_data[index].logAISwitching() if @aimondata[index].skill >= PokeBattle_AI::MEDIUMSKILL
      scores.each_with_index { |score, partyindex| allscoresarray.push([index, partyindex, score]) }
    end
    # allscoresarray should look like this: [[1, 0, -10], [1, 1, -10], [1, 2, 30], [1, 3, 50], [2, 0, -10], [2, 1, -10], [2, 2, 60], [2, 3, 40]]

    # Then get the highest score among all scores combined and send it out first, then the next
    # This allows the AI to choose the correct slot when it has to send out one pokemon with two empty slots
    switchhash = {}
    while !allscoresarray.empty?
      chosenindex, chosenpartyindex, chosenscore = allscoresarray.max_by { |index, partyindex, score| score }
      switchhash[chosenindex] = chosenpartyindex
      allscoresarray.delete_if { |index, partyindex, score| index == chosenindex || partyindex == chosenpartyindex }
      break if !@battle.pbCanChooseNonActive?(chosenindex, exclude: chosenpartyindex)
      # The party will always have at least one choosable member if this method is being called, so this break condition can only apply for the second selection, hence placed at bottom
    end
    return switchhash
  end

  # function for getting the new switch-in when replacing fainted mons or pivoting
  # index is index of battler
  def pbDefaultChooseNewEnemyScores(index, agent, doublereplace: false)
    @mondata = @aimondata[index]
    @attacker = @battle.battlers[index]
    @index = index
    return getSwitchInScoresParty(agent, doublereplace: doublereplace)
  end

  def getReviveScoresParty(index)
    @mondata = @aimondata[index]
    @attacker = @battle.battlers[index]
    @index = index
    return getSwitchInScoresParty(:Revive)
  end

  def getSwitchingScore
    # Set up some basic checks to prompt the remainder of the switch code
    # upon passing said checks:
    PBDebug.dblog("\nBeginning AI hard switch check for battler: #{@attacker.logname}")
    @mondata.shouldswitchscore = shouldSwitch?()
    $ai_log_data[@attacker.index].should_switch_score = @mondata.shouldswitchscore
    PBDebug.dblog(sprintf("ShouldSwitchScore: %d", @mondata.shouldswitchscore))

    if @mondata.shouldswitchscore > 0
      @mondata.switchscore = getSwitchInScoresParty(:HardSwitch)
    end
  end

  def isPivotSafe?(switchIn, preEmptiveCalc)
    threats = [@attacker.pbOpposing1, @attacker.pbOpposing2].select { |opp| opp && !opp.isFainted? }

    partner = @attacker.pbPartner
    getAIMemory(partner).each_with_index { |basemove, moveindex|
      move = pbChangeMove(basemove, partner)
      if partner.pbTarget(move) == :AllNonUsers &&
         @battle.pbCanChooseMove?(partner, moveindex) &&
         moveSuccessful?(basemove, partner, switchIn) &&
         !pbTypeModNoMessages(move.pbType(partner), partner, switchIn, move).immune?
        threats.push(partner)
        break
      end
    }

    if preEmptiveCalc
      # Calculating switch-in scores in advance while scoring a move
      return threats.all? { |threat| pbAIfaster?(nil, nil, threat, @attacker) }
    else
      # Calculating switch-in scores for sending a mon out right now
      return threats.all? { |threat| threat.hasMovedThisRound? }
    end
  end

  def getSwitchInScoresParty(agent, doublereplace: false, preEmptiveCalc: false)
    hard_switch = agent == :HardSwitch
    revival = agent == :Revive
    batonpass = agent == :PivotBaton
    party = @battle.pbPartySingleOwner(@attacker.index)
    if @mondata.skill < MEDIUMSKILL
      # Bad trainers likely don't know what a pikachu is, and just swap in random mons
      partyScores = Array.new(party.length, -10000000)
      return partyScores if hard_switch

      choices = (0...party.length).select { |i| @battle.pbCanSwitchLax?(@attacker.index, i, revival: revival) }
      return partyScores if choices.empty?

      ranvar = @battle.sample(choices)
      partyScores[ranvar] = 100
      if doublereplace && choices.length > 1
        choices.delete(ranvar)
        ranvar2 = @battle.sample(choices)
        partyScores[ranvar2] = 100
      end
      return partyScores
    end
    partyScores = []
    # For checks at end for all pokemon
    partycheck = []
    survivors = Array.new(party.length, false)
    # Disable logging when using this method for choosing mon to revive with revival blessing
    internalbackup = $INTERNAL
    $INTERNAL = false if revival

    for partyindex in 0...party.length
      mon = party[partyindex]
      monname = mon.nil? ? "nil" : (mon.isEgg? ? "egg" : (partyindex == @attacker.pokemonIndex ? "self" : mon.logname))
      $ai_log_data[@attacker.index].switch_names.push(monname) unless revival

      if mon.nil? || mon.isEgg? || partyindex == @attacker.pokemonIndex
        partyScores.push(-10000000)
        next
      end

      monscore = 0
      PBDebug.dblog(sprintf("\nScoring for %s switching to: %s", @attacker.logname, monname))
      i = pbMakeFakeBattler(mon, partyindex, batonpass)

      if i.hp <= 0
        if revival
          mult = @battle.FE == :HOLY ? 0.75 : 0.5
          i.hp = [(i.totalhp * mult).floor, 1].max
        else
          partyScores.push(-10000000)
          PBDebug.dblog(sprintf("Fainted- Score: -10000000"))
          next
        end
      end
      if (hard_switch && !@battle.pbCanSwitch?(@attacker.index, partyindex)) ||
         (!hard_switch && !@battle.pbCanSwitchLax?(@attacker.index, partyindex, revival: revival))
        partyScores.push(-10000000)
        PBDebug.dblog(sprintf("Can't switch- Score: -10000000"))
        next
      end
      if mustSendOutAceLast?()
        if !i.moves.any? { |moveloop| moveloop && moveloop.move != :LUNARDANCE }
          partyScores.push(-1500)
          PBDebug.dblog(sprintf("Lunar mon sacrifice- Score: -1500"))
          next
        end
        if partyindex == getAceIndex()
          @battle.pbCanChooseNonActiveCount(@attacker.index)
          # Don't skip scoring the ace when it's going to have to come out in a double replacement
          # The score will allow the correct slot to be chosen to send it in
          unless doublereplace && @battle.pbCanChooseNonActiveCount(@attacker.index) <= 2
            partyScores.push(-10000)
            PBDebug.dblog(sprintf("Ace Switch Prevention- Score: -10000"))
            next
          end
        end
      end

      if Rejuv
      # lot of custom ai for one stupid fight
        if !@battle.opponent.is_a?(Array)
          if Rejuv && !@battle.opponent.nil? && @battle.opponent.trainertype == :WITCHOFTHEEND
            if i.species == :DELCATTY
              monscore = 300 - (@attacker.pbFaintedPokemonCount * 60)
            end
          end
        end
      end

      theseRoles = @mondata.partyroles[partyindex] || pbGetMonRoles(i)

      # Opponents have to be created anew for each switch-in option in order to reset the stat changes from pbStatChangingSwitchOpponent
      opp = @attacker.pbFirstOpposing
      opp2 = opp.pbPartner
      @opponent = pbCloneBattler(opp.index, illusionDeceived?(opp, @battle.battlers[opp.index]))
      @opponent2 = opp2.isFainted? ? nil : pbCloneBattler(opp2.index, illusionDeceived?(opp2, @battle.battlers[opp2.index]))
      aimem = getAIMemory(opp)
      aimem2 = getAIMemory(opp2)
      bothOpponents = [@opponent, @opponent2].select { |opp| !opp.nil? && !opp.isFainted? }

      # Apply PermEffs like Healing Wish and Lunar Dance so that they may be accounted for in pbHPChangingSwitch and pbStatChangingSwitch
      PokeBattle_Battler::PermEff.each { |eff| i.effects[eff] = @attacker.effects[eff] }

      hpBeforeHazards = i.hp
      pbHPChangingSwitch(i) # HP changes from pending healing effects, hazards and berries

      if i.hp <= 0
        partyScores.push(-400)
        PBDebug.dblog(sprintf("Faints to hazards- Score: -400\n"))
        next
      end

      # Other effects from Healing Wish and Lunar Dance
      i.healStatus if i.effects[:HealingWish] || i.effects[:LunarDance]
      i.moves.each { |move| move.pp = move.totalpp if move } if i.effects[:LunarDance]

      # Update the mon's form
      pbFormChangeUponSwitchIn(i)

      # Update Field based on Trainer Effects, etc
      initial_field = @battle.field.effect

      initial_weather = @battle.weather
      @battle.field.effect = getFieldOnEntry(@battle.pbGetOwner(i.index), i, delay = false)

      # get trainereffects on entry
      trainereffects = getTrainerEffects(@battle.pbGetOwner(@attacker.index), partyindex, delay = false)
      if trainereffects
        if trainereffects[:weatherChange]
          @battle.weather = trainereffects[:weatherChange][0]
        end
        if trainereffects[:applyCrest]
          i.crested = trainereffects[:applyCrest]
          i.crestStats
        end
      end


      # get types from Trainer Effects
      getTypesOnEntry(@battle.pbGetOwner(i.index), i, delay = false)

      # stat changing considerations before mega
      pbStatChangingSwitch(i)
      bothOpponents.each { |opp| pbStatChangingSwitchOpponent(i, opp) }

      # From here on i is the battler after mega-ing and nonmegaform is the battler before
      nonmegaform = pbCloneBattler(nil, sourceBattler: i)
      # Mega Evolution
      if @battle.pbCanMegaEvolve?(@attacker.index, aiBattler: i)
        i.pokemon.makeMega
        i.form = i.pokemon.form
        i.pbUpdate(true, fakebattler: true)
      end
      # Ultra Burst
      if @battle.pbCanUltraBurst?(@attacker.index, aiBattler: i)
        i.pokemon.makeUltra
        i.form = i.pokemon.form
        i.pbUpdate(true, fakebattler: true)
      end
      # Terastallization
      if @battle.pbCanTerastallize?(@attacker.index, aiBattler: i)
        i.pokemon.makeTerastallized
        i.form = i.pokemon.form
        i.pbUpdate(true, fakebattler: true)
      end

      # stat changing considerations from ability after mega-ing
      if i.form != nonmegaform.form
        pbStatChangingSwitch(i, onlyabilities: true)
        bothOpponents.each { |opp| pbStatChangingSwitchOpponent(i, opp) }
      end

      # Imposter
      transformed = false
      if i.ability == :IMPOSTER
        choice = @attacker.pbOppositeOpposing
        if choice.hp > 0 &&
         !(choice.effects[:Substitute] > 0 ||
         choice.effects[:Transform] ||
         choice.isSemiInvul? ||
         (choice.effects[:Illusion] && !illusionDeceived?(@attacker, choice)) ||
         choice.isTerastallized?)
          transformed = true
          hpbackup, totalhpbackup, itembackup = i.hp, i.totalhp, i.item
          i = pbMakeFakeBattler(choice.pokemon, i.pokemonIndex)
          i.hp, i.totalhp, i.item = hpbackup, totalhpbackup, itembackup
          monscore += 20 * choice.stages[PBStats::ATTACK]
          monscore += 20 * choice.stages[PBStats::SPATK]
          monscore += 20 * choice.stages[PBStats::SPEED]
          monscore -= 200 if choice.effects[:Imprison]
        else
          monscore -= 200
        end
      end

      if i.ability == :MIMICRY
        mtype = @battle.getMimicryType
        unless mtype.nil?
          i.type1 = mtype
          i.type2 = nil
        end
      end
      if Rejuv && @battle.FE == :INVERSE && i.item == :MAGICALSEED
        i.changeType(:NORMAL) if i.canChangeType?
        i.ability = :NORMALIZE
      end
      if Rejuv && @battle.FE == :SWAMP && i.item == :TELLURICSEED
        i.ability = :CLEARBODY
      end
      if @battle.FE == :UNDERWATER && i.item == :ELEMENTALSEED
        i.changeType(:WATER) if i.canChangeType?
      end
      if @battle.FE == :GLITCH && i.item == :SYNTHETICSEED
        i.changeType(:QMARKS) if i.canChangeType?
      end
      if i.ability == :REFLECTOR
        i.getReflectorTypes(@attacker.pbFirstOpposing) unless @attacker.pbFirstOpposing.isFainted?
      end

      partycheck.push(i)

      # Determine whether it's a safe switch or not
      safe_switch = case agent
        when :HardSwitch then false
        when :Revive, :Replacement then true
        when :Pivot, :PivotBaton then isPivotSafe?(nonmegaform, preEmptiveCalc)
      end

      # Information gathering
      roughdamagearray = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]] # Order: First Opp, Second Opp, Partner, Sum if multi-target
      for moveindex in 0...i.moves.length
        @move = i.moves[moveindex]
        next if @move.nil?
        next unless @move.pbIsDamaging?
        # There are no damaging moves with Partner targeting so not considering it here

        roughdamagearray[0][moveindex] = [(pbRoughDamage(@move, i, @opponent, considersub: false) * 100) / @opponent.hp.to_f, 100].min if @opponent.hp > 0
        roughdamagearray[1][moveindex] = [(pbRoughDamage(@move, i, @opponent2, considersub: false) * 100) / @opponent2.hp.to_f, 100].min if @opponent2
        if i.pbTarget(@move) == :AllNonUsers || PARTNERFUNCTIONS.include?(@move.function)
          roughdamagearray[2][moveindex] = [(pbRoughDamage(@move, i, @attacker.pbPartner, considersub: false) * 100) / (@attacker.pbPartner.hp.to_f), 100].min if @attacker.pbPartner.hp > 0
        end
        # roughdamagearray construction requires not considering substitute, as if it does, all offscores return 0, causing wonky AI behavior
        if i.pbTarget(@move) == :AllOpposing
          roughdamagearray[3][moveindex] = roughdamagearray[0][moveindex] + roughdamagearray[1][moveindex]
        elsif i.pbTarget(@move) == :AllNonUsers
          roughdamagearray[3][moveindex] = roughdamagearray[0][moveindex] + roughdamagearray[1][moveindex] - 2 * roughdamagearray[2][moveindex]
        elsif i.pbTarget(@move) == :RandomOpposing && @battle.doublebattle
          roughdamagearray[3][moveindex] = (roughdamagearray[0][moveindex] + roughdamagearray[1][moveindex]) / 2
        end
      end
      bestmoveindex = (roughdamagearray[0] + roughdamagearray[1]).index((roughdamagearray[0] + roughdamagearray[1]).max) % 4
      i_best_move = i.moves[bestmoveindex]

      # Offensive
      offscore = 0
      # check how much damage you can deal to opponents
      offscore += 30 if roughdamagearray[3].max > 180
      offscore += 50 if roughdamagearray[0].max >= 100 || roughdamagearray[1].max >= 100
      offscore += 10 if [roughdamagearray[0].max, roughdamagearray[1].max].max > 90
      offscore += 10 if [roughdamagearray[0].max, roughdamagearray[1].max].max > 80
      offscore += 10 if [roughdamagearray[0].max, roughdamagearray[1].max].max > 70
      offscore += 10 if [roughdamagearray[0].max, roughdamagearray[1].max].max > 60
      offscore += 50 if roughdamagearray[0].max >= 50 || roughdamagearray[1].max >= 50
      offscore += 50 if roughdamagearray[0].max >= 100 && roughdamagearray[1].max >= 100
      # check whether you are faster than opponents
      fastcount = 0
      for opp in bothOpponents
        opp_best_move = checkAIbestMove(opp, i)
        fastcount += pbAIfaster?(i_best_move, opp_best_move, i, opp) ? 1 : -1
      end
      # fastcount > 0 => faster than both opps or faster than one while other is fainted
      # fastcount == 0 => faster than one opp but slower than other, or both are fainted
      # fastcount < 0 => slower than both opps or slower than one while other is fainted
      # second opp is always fainted in singles ofc
      offscore *= fastcount > 0 ? 1.25 : (fastcount == 0 ? 1.0 : 0.75)
      # add to monscore
      monscore += offscore
      PBDebug.dblog(sprintf("Offensive: %d", offscore))

      # Defensive
      defscore = 0
      incomingdamage, incomingdamage2 = 0, 0
      # Don't consider opponent's locked move (Outrage/Rollout/etc) for expected damage if we -know- the switch-in can't KO the opponent in one move (we need to think more long-term for switches)
      incomingdamage = checkAIdamage(i, @opponent, considerlock: roughdamagearray[0].max >= 100)
      incomingdamage2 = checkAIdamage(i, @opponent2, considerlock: roughdamagearray[1].max >= 100) if @opponent2
      incomingpercentage = (incomingdamage + incomingdamage2) / i.hp.to_f
      maxsingulardamage = [incomingdamage2, incomingdamage].max / i.hp.to_f

      if hard_switch
        # include weather chip, etc, when accounting for icnoming damage on hard switches
        incomingpercentage = incomingpercentage - (hpGainPerTurn(i, true))
      end
      PBDebug.dblog("HP after hazards: #{(i.hp / i.totalhp.to_f * 100).round(2)} %") if i.hp != hpBeforeHazards
      PBDebug.dblog(sprintf("incomingpercentage: %f", incomingpercentage))
      PBDebug.dblog(sprintf("maxsingulardamage: %f", maxsingulardamage))
      killedBeforeMoving = false
      if incomingpercentage >= 1.0
        killedBeforeMoving = true if !safe_switch || !canKillBeforeOpponentKills?(i, @opponent)
        killedBeforeMoving = true if @opponent2 && (!safe_switch || !canKillBeforeOpponentKills?(i, @opponent2))
      end
      if killedBeforeMoving
        defscore -= 150
      else
        survivors[partyindex] = true
      end
      defscore += 25 if incomingpercentage < 0.5
      defscore += 10 if maxsingulardamage < 0.45
      defscore += 10 if maxsingulardamage < 0.4
      defscore += 10 if maxsingulardamage < 0.35
      defscore += 20 if maxsingulardamage < 0.3
      defscore += 50 if 2 * incomingpercentage + hpGainPerTurn - 1 < 0.5
      defscore += 20 if maxsingulardamage < 0.2
      defscore += 30 if maxsingulardamage < 0.1
      defscore += 50 if 3 * incomingpercentage + 2 * (hpGainPerTurn - 1) < 0.3
      # check if switch-in lives assumed move in case of non-safe switch
      if !safe_switch && !@battle.doublebattle && (maxsingulardamage < 1.0 || pbAIfaster?(nil, nil, @opponent, i))
        assumed_move = checkAIbestMove()
        assumed_damage = pbRoughDamage(assumed_move, @opponent, nonmegaform)
        assumed_percentage = assumed_damage / nonmegaform.hp.to_f
        defscore += 20 if assumed_percentage < 0.5
        defscore += 30 if assumed_percentage < 0.3
        defscore += 50 if assumed_percentage < 0.1
      end
      monscore += defscore
      PBDebug.dblog(sprintf("Defensive: %d", defscore))

      # Roles
      rolescore = 0

      if @mondata.skill >= HIGHSKILL
        if theseRoles.include?(:SWEEPER)
          rolescore += @attacker.pbNonActivePokemonCount < 2 ? 60 : -50
          rolescore += 30 if i.attack >= i.spatk && bothOpponents.any? { |opp| opp.defense < opp.spdef }
          rolescore += 30 if i.spatk >= i.attack && bothOpponents.any? { |opp| opp.spdef < opp.defense }
          rolescore += (-10) * statchangecounter(@opponent, 1, 7, -1)
          rolescore += (-10) * statchangecounter(@opponent2, 1, 7, -1) if @opponent2
          rolescore += 10 if pbAIfaster?(nil, nil, i, @opponent) && rolescore > 0
          rolescore *= pbAIfaster?(nil, nil, i, @opponent) && rolescore > 0 ? 1.5 : 0.5
          rolescore += 50 if [:SLEEP, :FROZEN].include?(@opponent.status) && @opponent.crested != :SUICUNE
          rolescore += 50 if @opponent2 && [:SLEEP, :FROZEN].include?(@opponent2.status)
          rolescore += 50 * (@attacker.pbOwnSide.effects[:AlliesFainted] - 2) if i.pbHasMove?(:LASTRESPECTS)
          rolescore += 25 * ([@attacker.pbOwnSide.effects[:AlliesFainted], 5].min - 2) if i.ability == :SUPREMEOVERLORD
          rolescore += 25 * (@attacker.pbFaintedPokemonCount - 2) if i.crested == :SPIRITOMB
        end
        if theseRoles.include?(:PHYSICALWALL) || theseRoles.include?(:SPECIALWALL)
          rolescore += 30 if theseRoles.include?(:PHYSICALWALL) && bothOpponents.any? { |opp| opp.spatk > opp.attack }
          rolescore += 30 if theseRoles.include?(:SPECIALWALL) && bothOpponents.any? { |opp| opp.spatk < opp.attack }
          rolescore += 30 if ((@opponent.status == :BURN || @opponent.status == :POISON) && @opponent.crested != :SUICUNE) || @opponent.effects[:LeechSeed] > 0
          rolescore += 30 if @opponent2 && (((@opponent2.status == :BURN || @opponent2.status == :POISON) && @opponent2.crested != :SUICUNE) || @opponent2.effects[:LeechSeed] > 0)
        end
        if theseRoles.include?(:TANK)
          rolescore += 40 if @opponent.status == :PARALYSIS || @opponent.effects[:LeechSeed] > 0
          rolescore += 40 if @opponent2 && (@opponent2.status == :PARALYSIS || @opponent2.effects[:LeechSeed] > 0) && @opponent2.crested != :SUICUNE
          rolescore += 30 if @attacker.pbOwnSide.effects[:Tailwind] > 0
        end
        if theseRoles.include?(:LEAD)
          rolescore += 10
          rolescore += 20 if (party.length - @attacker.pbNonActivePokemonCount) <= (party.length / 2).ceil
        end
        if @attacker.effects[:LunarDance] && [:NEWWORLD, :BIGTOP, :DANCEFLOOR].include?(@battle.FE)
          rolescore -= 100 if @attacker.pbNonActivePokemonCount > 2 # this might still need to be adjusted
          rolescore += 200 if @attacker.pbNonActivePokemonCount == 1
        end
        if theseRoles.include?(:CLERIC)
          partymidhp = false
          for k in party
            next if k.nil? || k == i || k.totalhp == 0

            rolescore += 50 if !k.status.nil?
            partymidhp = true if 0.3 < ((k.hp.to_f) / k.totalhp) && ((k.hp.to_f) / k.totalhp) < 0.6
          end
          rolescore += 50 if partymidhp
        end
        # now only does for lowered stats, but would also be very good for raised stats right?
        # evasion / accuracy doesn't make sense to me
        if theseRoles.include?(:PHAZER)
          for opp in bothOpponents
            rolescore += 10 * opp.stages[PBStats::ATTACK] if opp.stages[PBStats::ATTACK] < 0
            rolescore += 20 * opp.stages[PBStats::DEFENSE] if opp.stages[PBStats::DEFENSE] < 0
            rolescore += 10 * opp.stages[PBStats::SPATK] if opp.stages[PBStats::SPATK] < 0
            rolescore += 20 * opp.stages[PBStats::SPDEF] if opp.stages[PBStats::SPDEF] < 0
            rolescore += 10 * opp.stages[PBStats::SPEED] if opp.stages[PBStats::SPEED] < 0
            rolescore += 20 * opp.stages[PBStats::EVASION] if opp.stages[PBStats::EVASION] < 0
          end
        end
        if theseRoles.include?(:SCREENER)
          unless checkAImovesAllOpponents(PBStuff::SCREENBREAKERMOVE + [:SNATCH, :COURTCHANGE])
            for move in i.moves
              next if move.function == 0xA2 && @attacker.pbOwnSide.screenActive?(:physical)
              next if move.function == 0xA3 && @attacker.pbOwnSide.screenActive?(:special)
              next if [0x15B, 0x80C].include?(move.function) && @attacker.pbOwnSide.screenActive?(:physical) && @attacker.pbOwnSide.screenActive?(:special)
              next if move.function == 0x203 && @attacker.pbOwnSide.effects[:AreniteWall] > 0
              next if move.function == 0x15B && !([:HAIL, :SNOW].include?(@battle.pbWeather(i)) || (@mondata.skill >= BESTSKILL && [:SNOWYMOUNTAIN, :MIRROR, :STARLIGHT, :DARKCRYSTALCAVERN, :RAINBOW, :ICY, :CRYSTALCAVERN, :FROZENDIMENSION].include?(@battle.FE)))
              next if move.function == 0x203 && !(@battle.pbWeather(i) == :SANDSTORM || (@mondata.skill >= BESTSKILL && [:DESERT, :ASHENBEACH, :ROCKY].include?(@battle.FE)))
              rolescore += 60
            end
          end
        end
        # This is role related because it's the replacement for revenge killer
        if hard_switch==false
          for moveindex in 0...i.moves.length
            next if i.moves[moveindex].nil?
            if pbAIfaster?(i.moves[moveindex], nil, i, @opponent) && (!@opponent2 || pbAIfaster?(i.moves[moveindex], nil, i, @opponent2))
              if roughdamagearray[0][moveindex] >= 100 || roughdamagearray[1][moveindex] >= 100
                rolescore += 110 if !killedBeforeMoving
                break
              end
            end
          end
        end
        if theseRoles.include?(:SPINNER)
          if !@opponent.hasType?(:GHOST) && (!@opponent2 || !@opponent2.hasType?(:GHOST))
            rolescore += 20 * @attacker.pbOwnSide.effects[:Spikes]
            rolescore += 20 * @attacker.pbOwnSide.effects[:ToxicSpikes]
            rolescore += 30 if @attacker.pbOwnSide.effects[:StickyWeb]
            rolescore += 30 if @attacker.pbOwnSide.effects[:StealthRock]
          end
        end
        if theseRoles.include?(:PIVOT)
          rolescore += 40
        end
        if theseRoles.include?(:BATONPASSER)
          rolescore += 50
        end
        if theseRoles.include?(:STALLBREAKER) # Given to pokemon with choice items, taunt or heal block
          if checkAIhealing(aimem) || checkAIhealing(aimem2)
            rolescore += 80 if i.pbHasMove?(:TAUNT, :HEALBLOCK) || roughdamagearray[0].max >= 50 || roughdamagearray[1].max >= 50
          end
        end
        if theseRoles.include?(:STATUSABSORBER)
          for specificmemory in [aimem, aimem2]
            next if specificmemory.length == 0

            for j in specificmemory
              statusmove = PBStuff::BURNMOVE.include?(j.move) || PBStuff::PARAMOVE.include?(j.move) || PBStuff::SLEEPMOVE.include?(j.move) || PBStuff::SCREENMOVE.include?(j.move)
            end
          end
          rolescore += 70 if statusmove
        end
        if theseRoles.include?(:TRAPPER)
          rolescore += 30 if pbAIfaster?(nil, nil, i, @opponent) && @opponent.totalhp != 0 && @opponent.hp.to_f / @opponent.totalhp < 0.6
        end
        if theseRoles.include?(:WEATHERSETTER)
          rolescore += 30
          if i.ability == :DROUGHT || nonmegaform.ability == :DROUGHT || i.pbHasMove?(:SUNNYDAY)
            if @battle.weather != :SUNNYDAY
              rolescore += 60
              if !safe_switch && nonmegaform.ability == :DROUGHT
                rolescore += 40 * (dynamicspeedcode(:SUNNYDAY, 2.0, !safe_switch) - 1) if @attacker.pbPartner.ability == :CHLOROPHYLL && !@attacker.pbPartner.chlorophyllActive?
                if @attacker.pbPartner.ability == :PROTOSYNTHESIS && @attacker.pbPartner.effects[:Protosynthesis][0] == 0
                  boostStat = @attacker.pbPartner.getHighestStatWithStages
                  rolescore += 40 * (dynamicspeedcode(:ProtoDrivePartner, 1.5, !safe_switch) - 1) if boostStat == PBStats::SPEED
                end
              end
            end
          elsif i.ability == :DRIZZLE || nonmegaform.ability == :DRIZZLE || i.pbHasMove?(:RAINDANCE)
            if @battle.weather != :RAINDANCE
              rolescore += 60
              if !safe_switch && nonmegaform.ability == :DRIZZLE && @attacker.pbPartner.ability == :SWIFTSWIM
                rolescore += 40 * (dynamicspeedcode(:RAINDANCE, 2.0, !safe_switch) - 1) if !@attacker.pbPartner.swiftSwimActive?
              end
            end
          elsif i.ability == :SANDSTREAM || nonmegaform.ability == :SANDSTREAM || i.ability == :SANDSPIT || nonmegaform.ability == :SANDSPIT || i.pbHasMove?(:SANDSTORM)
            if @battle.weather != :SANDSTORM
              rolescore += 60
              if !safe_switch && nonmegaform.ability == :SANDSTREAM && @attacker.pbPartner.ability == :SANDRUSH
                rolescore += 40 * (dynamicspeedcode(:SANDSTORM, 2.0, !safe_switch) - 1) if !@attacker.pbPartner.sandRushActive?
              end
            end
          elsif i.ability == :HAILWARNING || nonmegaform.ability == :HAILWARNING || i.pbHasMove?(:HAIL)
            if @battle.weather != :HAIL
              rolescore += 60
              if !safe_switch && nonmegaform.ability == :HAILWARNING && (@attacker.pbPartner.ability == :SLUSHRUSH || @attacker.pbPartner.crested == :EMPOLEON || (@attacker.pbPartner.crested == :CASTFORM && @attacker.pbPartner.form == 3))
                rolescore += 40 * (dynamicspeedcode(:HAIL, 2.0, !safe_switch) - 1) if !@attacker.pbPartner.slushRushActive?
              end
            end
          elsif i.ability == :SNOWWARNING || nonmegaform.ability == :SNOWWARNING || i.pbHasMove?(:SNOWSCAPE, :CHILLYRECEPTION)
            if @battle.weather != :SNOW
              rolescore += 60
              if !safe_switch && nonmegaform.ability == :SNOWWARNING && (@attacker.pbPartner.ability == :SLUSHRUSH || @attacker.pbPartner.crested == :EMPOLEON || (@attacker.pbPartner.crested == :CASTFORM && @attacker.pbPartner.form == 3))
                rolescore += 40 * (dynamicspeedcode(:SNOW, 2.0, !safe_switch) - 1) if !@attacker.pbPartner.slushRushActive?
              end
            end
          elsif [:PRIMORDIALSEA, :DESOLATELAND, :DELTASTREAM].intersect?([i.ability, nonmegaform.ability])
            rolescore += 60
            if !safe_switch && nonmegaform.ability == :DESOLATELAND && @attacker.pbPartner.ability == :CHLOROPHYLL
              rolescore += 40 * (dynamicspeedcode(:SUNNYDAY, 2.0, !safe_switch) - 1) if !@attacker.pbPartner.chlorophyllActive?
            end
            if !safe_switch && nonmegaform.ability == :PRIMORDIALSEA && @attacker.pbPartner.ability == :SWIFTSWIM
              rolescore += 40 * (dynamicspeedcode(:RAINDANCE, 2.0, !safe_switch) - 1) if !@attacker.pbPartner.swiftSwimActive?
            end
          end
        end
        if theseRoles.include?(:FIELDSETTER)
          rolescore += 30
          if i.ability == :ELECTRICSURGE || nonmegaform.ability == :ELECTRICSURGE || i.crested == :RAIKOU || i.pbHasMove?(:IONDELUGE, :ELECTRICTERRAIN, :PLASMAFISTS)
            if @battle.canChangeFE?(:ELECTERRAIN)
              rolescore += 60
              if !safe_switch && (nonmegaform.ability == :ELECTRICSURGE || i.crested == :RAIKOU)
                rolescore += 40 * (dynamicspeedcode(:ELECTERRAIN, 2.0, !safe_switch) - 1) if @attacker.pbPartner.ability == :SURGESURFER && !@attacker.pbPartner.surgeSurferActive?
                if @attacker.pbPartner.ability == :QUARKDRIVE && @attacker.pbPartner.effects[:QuarkDrive][0] == 0
                  boostStat = @attacker.pbPartner.getHighestStatWithStages
                  rolescore += 40 * (dynamicspeedcode(:ProtoDrivePartner, 1.5, !safe_switch) - 1) if boostStat == PBStats::SPEED
                end
                rolescore += 40 * (dynamicspeedcode(:ELECTERRAIN, 1.5, !safe_switch) - 1) if @attacker.pbPartner.ability == :QUICKFEET && !@attacker.pbPartner.quickFeetActive?
              end
            end
          elsif i.ability == :GRASSYSURGE || nonmegaform.ability == :GRASSYSURGE || i.pbHasMove?(:GRASSYTERRAIN) || i.ability == :SEEDSOWER
            rolescore += 60 if @battle.canChangeFE?(:GRASSY)
          elsif i.ability == :MISTYSURGE || nonmegaform.ability == :MISTYSURGE || i.pbHasMove?(:MISTYTERRAIN, :MIST)
            rolescore += 60 if @battle.canChangeFE?(:MISTY)
          elsif i.ability == :PSYCHICSURGE || nonmegaform.ability == :PSYCHICSURGE || i.pbHasMove?(:PSYCHICTERRAIN)
            if @battle.canChangeFE?(:PSYTERRAIN)
              rolescore += 60
              if !safe_switch && nonmegaform.ability == :PSYCHICSURGE && @attacker.pbPartner.ability == :TELEPATHY
                rolescore += 40 * (dynamicspeedcode(:PSYTERRAIN, 2.0, !safe_switch) - 1) unless @attacker.pbPartner.telepathyActive?
              end
            end
          elsif i.pbHasMove?(:CONVERSION) && i.pbHasMove?(:CONVERSION2)
            rolescore += 60 if @battle.canChangeFE?(:GLITCH)
          elsif i.pbHasMove?(:TOPSYTURVY)
            rolescore += 60 if @battle.canChangeFE?(:INVERSE)
          end
        end
      end
      monscore += rolescore
      PBDebug.dblog("Mon's Roles: #{theseRoles}")
      PBDebug.dblog(sprintf("Roles: %d", rolescore))

      # Weather
      weatherscore = 0
      case @battle.weather
        when :HAIL, :SNOW
          weatherscore += 25 if (@battle.magicGuardAbilities + [:OVERCOAT]).include?(i.ability) || i.hasType?(:ICE)
          weatherscore += 50 if [:SNOWCLOAK, :ICEBODY, :LUNARIDOL].include?(i.ability)
          weatherscore += 80 if i.ability == :SLUSHRUSH || i.crested == :EMPOLEON && i.species == :EMPOLEON
          weatherscore += 30 if i.ability == :ICEFACE && i.form == 1
        when :RAINDANCE
          weatherscore += 50 if [:DRYSKIN, :HYDRATION, :RAINDISH].include?(i.ability)
          weatherscore += 80 if i.ability == :SWIFTSWIM
        when :SUNNYDAY
          weatherscore -= 40 if i.ability == :DRYSKIN
          weatherscore += 50 if [:SOLARPOWER, :SOLARIDOL].include?(i.ability)
          weatherscore += 80 if i.ability == :CHLOROPHYLL
        when :SANDSTORM
          weatherscore += 25 if (@battle.magicGuardAbilities + [:OVERCOAT]).include?(i.ability) || i.hasType?(:ROCK) || i.hasType?(:GROUND) || i.hasType?(:STEEL)
          weatherscore += 50 if [:SANDVEIL, :SANDFORCE].include?(i.ability)
          weatherscore += 80 if i.ability == :SANDRUSH
      end
      if @battle.state.effects[:TrickRoom] > 0
        weatherscore += i.pbSpeed < @opponent.pbSpeed ? 50 : -50
        weatherscore += i.pbSpeed < @opponent2.pbSpeed ? 50 : -50 if @opponent2
      end
      monscore += weatherscore
      PBDebug.dblog(sprintf("Weather: %d", weatherscore))

      # Moves
      movesscore = 0
      if @mondata.skill >= HIGHSKILL
        if @attacker.pbOwnSide.effects[:ToxicSpikes] > 0
          movesscore += 80 if nonmegaform.hasType?(:POISON) && !nonmegaform.hasType?(:FLYING) && !PBStuff::LevitateAbilities.include?(nonmegaform.ability)
          movesscore += 30 if nonmegaform.hasType?(:FLYING) || nonmegaform.hasType?(:STEEL) || PBStuff::LevitateAbilities.include?(nonmegaform.ability)
        end
        if i.pbHasMove?(:CLEARSMOG) || i.pbHasMove?(:HAZE)
          movesscore += 10 * statchangecounter(@opponent, 1, 7, 1)
          movesscore += 10 * statchangecounter(@opponent2, 1, 7, 1) if @opponent2
        end
        movesscore += 25 if i.pbHasMove?(:FAKEOUT, :FIRSTIMPRESSION)
        if @attacker.pbPartner.totalhp != 0
          movesscore += 70 if i.pbHasMove?(:FUSIONBOLT) && @attacker.pbPartner.pbHasMove?(:FUSIONFLARE)
          movesscore += 70 if i.pbHasMove?(:FUSIONFLARE) && @attacker.pbPartner.pbHasMove?(:FUSIONBOLT)
        end
        movesscore += 30 if i.pbHasMove?(:RETALIATE) && @attacker.pbOwnSide.effects[:Retaliate]
        if i.pbHasMove?(:FELLSTINGER)
          movesscore += 50 if pbAIfaster?(nil, nil, i, @opponent) && @opponent.hp.to_f / @opponent.totalhp < 0.2
          movesscore += 50 if @opponent2 && pbAIfaster?(nil, nil, i, @opponent2) && @opponent2.hp.to_f / @opponent2.totalhp < 0.2
        end
        if i.pbHasMove?(:TAILWIND)
          movesscore += (@attacker.pbOwnSide.effects[:Tailwind] > 0 || checkAImovesAllOpponents([:SNATCH, :COURTCHANGE])) ? -60 : 30
        end
        if i.pbHasMove?(:TOPSYTURVY)
          baseval = 5
          baseval = 20 if statchangecounter(@opponent, 1, 7) > 3 || [:CONTRARY, :MOXIE, :CHILLINGNEIGH, :ASONECHILLING, :SOULHEART, :GRIMNEIGH, :ASONEGRIM, :BEASTBOOST, :BATTLEBOND, :PRISMPOWER].include?(@opponent.ability)
          if @opponent2
            baseval = 20 if statchangecounter(@opponent2, 1, 7) > 3 || [:CONTRARY, :MOXIE, :CHILLINGNEIGH, :ASONECHILLING, :SOULHEART, :GRIMNEIGH, :ASONEGRIM, :BEASTBOOST, :BATTLEBOND, :PRISMPOWER].include?(@opponent2.ability)
          end
          movesscore += baseval * statchangecounter(@opponent, 1, 7, 1)
          movesscore += baseval * statchangecounter(@opponent2, 1, 7, 1) if @opponent2
        end
        # Moves to counter Wonder Guard
        for oppmon in bothOpponents.select { |oppmon| oppmon.ability == :WONDERGUARD }
          movesscore += 150 if i.moves.any? { |move| isUsefulStatusMove?(move, i, oppmon) || (oppmon.hp == 1 && move.move == :PURSUIT && pbTypeModNoMessages(move.pbType(i), i, oppmon, move).superEffective?) }
        end
        # Moves to counter redirection
        redirector = nil
        rmove = [:FOLLOWME, :RAGEPOWDER, :ALLYSWTCH, :SPOTLIGHT].find { |rmove| redirector = checkAImovesAllOpponents([rmove]) }
        movesscore += 25 * i.moves.count { |move| ignoresRedirection?(rmove, move, i, redirector) } if rmove
        # Imprison consideration
        i.moves.each { |move| movesscore -= 40 if bothOpponents.any? { |opp| opp.effects[:Imprison] && getAIMemory(opp).include?(move.move) } }
      end
      monscore += movesscore
      PBDebug.dblog(sprintf("Moves: %d", movesscore))

      # Abilities
      abilityscore = 0
      itemscore = 0
      if @mondata.skill >= HIGHSKILL
        # Abilities for whom hard switching vs safe switching matters
        if !safe_switch # Hard switch/fast pivot
          # When it's a hard switch, we expect the incoming mon to take the best move the opponent has against the current mon (@attacker)
          case i.ability
            when :EFFECTSPORE, :STATIC, :POISONPOINT, :FLAMEBODY, :CUTECHARM, :PERISHBODY, :GOOEY, :TANGLINGHAIR
              for opp in bothOpponents
                next if i.ability == :PERISHBODY && @battle.FE == :HOLY
                next if i.ability == :EFFECTSPORE && opp.powderImmune?
                oppbestmove = checkAIbestMove(opp)
                if opp.makesContact?(oppbestmove)
                  abilityscore += 30
                  abilityscore += 10 * opp.pbGetHitNumber(oppbestmove, norandomness: true)
                end
              end
            when :JUSTIFIED
              for opp in bothOpponents
                oppbestmove = checkAIbestMove(opp)
                if oppbestmove.pbType(opp) == :DARK
                  abilityscore += 30
                  abilityscore += 10 * opp.pbGetHitNumber(oppbestmove, norandomness: true)
                end
              end
            when :RATTLED
              for opp in bothOpponents
                oppbestmove = checkAIbestMove(opp)
                if [:DARK, :GHOST, :BUG].include?(oppbestmove.pbType(opp))
                  abilityscore += 15
                  abilityscore += 5 * opp.pbGetHitNumber(oppbestmove, norandomness: true)
                end
              end
            when :MUMMY, :LINGERINGAROMA, :WANDERINGSPIRIT, :AFTERMATH
              abilityscore += 30 * bothOpponents.count { |opp| opp.makesContact?(checkAIbestMove(opp)) }
            when :WINDPOWER
              abilityscore += 10 * bothOpponents.count { |opp| checkAIbestMove(opp).windMove? }
            when :SPICYSPRAY
              for opp in bothOpponents
                next unless opp.pbCanBurn?(i, nil)
                abilityscore += survivesAt1HP?(opp) ? 45 : 15 if !@battle.magicGuardAbilities.include?(opp.ability)
                abilityscore += opp.pbGetHitNumber(checkAIbestMove(opp), norandomness: true) > 1 ? 30 : 15 if opp.attack > opp.spatk
              end
            when :DEFEATIST
              abilityscore -= 80
          end
          # Also handling Rocky Helmet itemscore here to avoid redundancy
          if [:IRONBARBS, :ROUGHSKIN].include?(i.ability) || i.item == :ROCKYHELMET
            totalscore = 0
            for opp in bothOpponents
              oppbestmove = checkAIbestMove(opp)
              if opp.makesContact?(oppbestmove)
                totalscore += 30
                totalscore += 10 * opp.pbGetHitNumber(oppbestmove, norandomness: true)
              end
            end
            abilityscore += totalscore if [:IRONBARBS, :ROUGHSKIN].include?(i.ability)
            itemscore += totalscore if i.item == :ROCKYHELMET
          end
        else # Safe switch (replace fainted mon/slow pivot)
          # When it's a safe switch, we don't expect to be hit but want to simply counter the opponent, so we check for the opponent's best move against the switch-in (i)
          case i.ability
            when :EFFECTSPORE, :STATIC, :POISONPOINT, :FLAMEBODY, :CUTECHARM, :PERISHBODY, :GOOEY, :TANGLINGHAIR
              for opp in bothOpponents
                next if i.ability == :PERISHBODY && @battle.FE == :HOLY
                next if i.ability == :EFFECTSPORE && opp.powderImmune?
                oppbestmove = checkAIbestMove(opp, i)
                if opp.makesContact?(oppbestmove)
                  abilityscore += 20
                  abilityscore += 7 * opp.pbGetHitNumber(oppbestmove, norandomness: true)
                end
              end
            when :JUSTIFIED
              for opp in bothOpponents
                oppbestmove = checkAIbestMove(opp, i)
                if oppbestmove.pbType(opp) == :DARK
                  abilityscore += 20
                  abilityscore += 7 * opp.pbGetHitNumber(oppbestmove, norandomness: true)
                end
              end
            when :RATTLED
              for opp in bothOpponents
                oppbestmove = checkAIbestMove(opp, i)
                if [:DARK, :GHOST, :BUG].include?(oppbestmove.pbType(opp))
                  abilityscore += 10
                  abilityscore += 3 * opp.pbGetHitNumber(oppbestmove, norandomness: true)
                end
              end
            when :MUMMY, :LINGERINGAROMA, :WANDERINGSPIRIT, :AFTERMATH
              abilityscore += 20 * bothOpponents.count { |opp| opp.makesContact?(checkAIbestMove(opp, i)) }
            when :WINDPOWER
              abilityscore += 7 * bothOpponents.count { |opp| checkAIbestMove(opp, i).windMove? }
            when :SPICYSPRAY
              for opp in bothOpponents
                next unless opp.pbCanBurn?(i, nil)
                abilityscore += survivesAt1HP?(opp) ? 30 : 10 if !@battle.magicGuardAbilities.include?(opp.ability)
                abilityscore += opp.pbGetHitNumber(checkAIbestMove(opp, i), norandomness: true) > 1 ? 20 : 10 if opp.attack > opp.spatk
              end
          end
          # Also handling Rocky Helmet itemscore here to avoid redundancy
          if [:IRONBARBS, :ROUGHSKIN].include?(i.ability) || i.item == :ROCKYHELMET
            totalscore = 0
            for opp in bothOpponents
              oppbestmove = checkAIbestMove(opp, i)
              if opp.makesContact?(oppbestmove)
                totalscore += 20
                totalscore += 7 * opp.pbGetHitNumber(oppbestmove, norandomness: true)
              end
            end
            abilityscore += totalscore if [:IRONBARBS, :ROUGHSKIN].include?(i.ability)
            itemscore += totalscore if i.item == :ROCKYHELMET
          end
        end
        # Abilities for whom hard switching vs safe switching does not matter
        case i.ability
          when :DISGUISE
            if i.effects[:Disguise] && (Gen < 8 || i.hp > (i.totalhp / 8.0).floor)
              bothOpponents.each { |opp|
                next if moldBreakerCheck(opp, i)
                abilityscore += 10 * statchangecounter(opp, 1, 7, 1)
                abilityscore += 50 if roughdamagearray[opp == @opponent ? 0 : 1].max >= 100
              }
            end
          when :ICEFACE
            if i.effects[:IceFace]
              bothOpponents.each { |opp|
                next if moldBreakerCheck(opp, i)
                next unless opp.attack > opp.spatk || @battle.FE == :FROZENDIMENSION
                abilityscore += 10 * statchangecounter(opp, 1, 7, 1)
                abilityscore += 50 if roughdamagearray[opp == @opponent ? 0 : 1].max >= 100
              }
            end
          when :UNAWARE
            # Can't use statchangecounter beacuse mold breaker opponents' Atk/SpA/Acc specifically will be unaffected
            count = 0
            bothOpponents.each { |opp|
              PBStats::All.each { |stat|
                next if stat == PBStats::SPEED
                next if [PBStats::ATTACK, PBStats::SPATK, PBStats::ACCURACY].include?(stat) && moldBreakerCheck(opp, i)
                count += opp.stages[stat] if opp.stages[stat] > 0
              }
            }
            abilityscore += 10 * count
          when :DROUGHT, :DESOLATELAND
            bothOpponents.each { |opp|
              abilityscore += 40 if opp.hasType?(:WATER)
              abilityscore += 15 if (opp == @opponent ? aimem : aimem2).any? { |moveloop| moveloop != nil && moveloop.pbType(opp) == :WATER }
            }
          when :DRIZZLE, :PRIMORDIALSEA
            bothOpponents.each { |opp|
              abilityscore += 40 if opp.hasType?(:FIRE)
              abilityscore += 15 if (opp == @opponent ? aimem : aimem2).any? { |moveloop| moveloop != nil && moveloop.pbType(opp) == :FIRE }
            }
          when :LIMBER
            bothOpponents.each { |opp|
              abilityscore += 15 if checkAImoves(PBStuff::PARAMOVE, opp == @opponent ? aimem : aimem2)
            }

          when :OBLIVIOUS
            bothOpponents.each { |opp|
              abilityscore += 20 if opp.ability == :CUTECHARM
              abilityscore += 20 if checkAImoves([:ATTRACT], opp == @opponent ? aimem : aimem2)
            }
          when :COMPOUNDEYES
            bothOpponents.each { |opp|
              abilityscore += 25 if opp.item == :LAXINCENSE || opp.item == :BRIGHTPOWDER || opp.stages[PBStats::EVASION] > 0 || accuracyWeatherAbilityActive?(opp, i)
            }
          when :COMATOSE
            bothOpponents.each { |opp|
              memory = opp == @opponent ? aimem : aimem2
              abilityscore += 20 if checkAImoves(PBStuff::BURNMOVE, memory)
              abilityscore += 20 if checkAImoves(PBStuff::PARAMOVE, memory)
              abilityscore += 20 if checkAImoves(PBStuff::SLEEPMOVE, memory)
              abilityscore += 20 if checkAImoves(PBStuff::POISONMOVE, memory)
            }
          when :INSOMNIA, :VITALSPIRIT
            bothOpponents.each { |opp|
              abilityscore += 20 if checkAImoves(PBStuff::SLEEPMOVE, opp == @opponent ? aimem : aimem2)
            }
          when :POISONHEAL, :TOXICBOOST, :IMMUNITY, :PASTELVEIL
            bothOpponents.each { |opp|
              abilityscore += ([:IMMUNITY, :PASTELVEIL].include?(i.ability) ? 20 : 30) if checkAImoves(PBStuff::POISONMOVE, opp == @opponent ? aimem : aimem2)
            }
          when :MAGICGUARD
            abilityscore += 20 if checkAImoves([:LEECHSEED], aimem)
            abilityscore += 20 if checkAImoves([:WILLOWISP], aimem)
            abilityscore += 20 if checkAImoves(PBStuff::POISONMOVE, aimem)
          when :FLAREBOOST, :WATERVEIL
            bothOpponents.each { |opp|
              abilityscore += (i.ability == :WATERVEIL ? 10 : 20) if checkAImoves(PBStuff::BURNMOVE, opp == @opponent ? aimem : aimem2)
            }
          when :WATERBUBBLE, :THERMALEXCHANGE
            bothOpponents.each { |opp|
              abilityscore += 10 if checkAImoves(PBStuff::BURNMOVE, opp == @opponent ? aimem : aimem2)
              oppbestmove = checkAIbestMove(opp)
              abilityscore += 30 if oppbestmove.pbType(opp) == :FIRE && !(i.ability == :WATERBUBBLE && moldBreakerCheck(opp, i, oppbestmove))
            }
          when :OWNTEMPO
            bothOpponents.each { |opp|
              abilityscore += 20 if checkAImoves(PBStuff::CONFUMOVE, opp == @opponent ? aimem : aimem2)
            }
          when :SCREENCLEANER
            abilityscore += 10 if @opponent.pbOwnSide.effects[:Reflect] > 0
            abilityscore += 10 if @opponent.pbOwnSide.effects[:LightScreen] > 0
            abilityscore += 5 if @opponent.pbOwnSide.effects[:Safeguard] > 0
            abilityscore += 20 if @opponent.pbOwnSide.effects[:AuroraVeil] > 0
            abilityscore += 20 if @opponent.pbOwnSide.effects[:AreniteWall] > 0

            abilityscore -= 10 if @attacker.pbOwnSide.effects[:Reflect] > 0
            abilityscore -= 10 if @attacker.pbOwnSide.effects[:LightScreen] > 0
            abilityscore -= 5 if @attacker.pbOwnSide.effects[:Safeguard] > 0
            abilityscore -= 20 if @attacker.pbOwnSide.effects[:AuroraVeil] > 0
            abilityscore -= 20 if @attacker.pbOwnSide.effects[:AreniteWall] > 0
            # Mirror Field AI
            if @mondata.skill >= BESTSKILL && @battle.FE == :MIRROR
              if @attacker.pbPartner.hp > 0
                abilityscore -= 10 * statchangecounter(@attacker.pbPartner, 6, 7, 1)
                abilityscore += 10 * statchangecounter(@attacker.pbPartner, 6, 7, -1)
              end
              bothOpponents.each { |opp|
                abilityscore += 10 * statchangecounter(opp, 6, 7, 1)
                abilityscore -= 10 * statchangecounter(opp, 6, 7, -1)
              }
            end
          when :CURIOUSMEDICINE
            if @attacker.pbPartner.hp > 0
              abilityscore -= 10 * statchangecounter(@attacker.pbPartner, 1, 7, 1)
              abilityscore += 10 * statchangecounter(@attacker.pbPartner, 1, 7, -1)
            end
          when :COSTAR
            if @attacker.pbPartner.hp > 0
              abilityscore += 10 * statchangecounter(@attacker.pbPartner, 1, 7, 1)
              abilityscore -= 10 * statchangecounter(@attacker.pbPartner, 1, 7, -1)
            end
          when :STAMINA, :FURCOAT
            bothOpponents.each { |opp|
              next if i.ability == :FURCOAT && moldBreakerCheck(opp, i)
              abilityscore += 40 if opp.attack > opp.spatk
            }
          when :INTIMIDATE
            bothOpponents.each { |opp|
              case opp.ability
                when *PBStuff::NoIntimidateAbilities # no-op
                when :MIRRORARMOR then abilityscore -= 40 if i.attack > i.spatk
                when :CONTRARY, :DEFIANT, :GUARDDOG then abilityscore -= 40
                when :COMPETITIVE then abilityscore -= 80 if opp.spatk > opp.attack
                else abilityscore += (opp.ability == :SIMPLE ? 80 : 40) if opp.attack > opp.spatk
              end
              abilityscore -= 10 if (opp.ability == :RATTLED || opp.hasWorkingItem(:ADRENALINEORB)) && @battle.state.effects[:TrickRoom] == 0
            }
          when :WONDERGUARD
            if i.hp == 1 # this is basically only for shedinja
              dievar = false
              instantdievar = false
              if i.takesWeatherDamage? && @battle.weatherduration != 1
                dievar = true
                instantdievar = true if @attacker.hp != 0 # hard switch/pivot
              end
              if i.status == :BURN || i.status == :POISON
                dievar = true
                instantdievar = true if @attacker.hp != 0 # hard switch/pivot
              end
              if @attacker.pbOwnSide.effects[:ToxicSpikes] > 0 && !i.isAirborne? && i.pbCanPoison?(nil, nil)
                dievar = true
                instantdievar = true if @attacker.hp != 0 # hard switch/pivot
              end
              dievar = true if maxsingulardamage >= 1
              abilityscore += 90 if !dievar
              abilityscore -= 90 if instantdievar
            end
          when :COTTONDOWN
            if incomingpercentage < 0.5
              abilityscore += roughdamagearray[0].max >= 60 ? 50 : 30
            end
          when :TRACE
            if [:WATERABSORB, :VOLTABSORB, :STORMDRAIN, :MOTORDRIVE, :FLASHFIRE, :WELLBAKEDBODY, *PBStuff::LevitateAbilities, :EARTHEATER, :LIGHTNINGROD,
               :SAPSIPPER, :DRYSKIN, :SLUSHRUSH, :SANDRUSH, :SWIFTSWIM, :CHLOROPHYLL, :SPEEDBOOST, :WONDERGUARD, :PRANKSTER, :UNAWARE, :WINDRIDER].include?(@opponent.ability) ||
               (pbAIfaster?() && ([:ADAPTABILITY, :DOWNLOAD].include?(@opponent.ability) || ([:PROTEAN, :LIBERO].include?(@opponent.ability) && (Gen < 9 || !Rejuv)))) ||
               (@opponent.attack > @opponent.spatk && @opponent.ability == :INTIMIDATE) ||
               (i.hp == i.totalhp && [:MULTISCALE, :SHADOWSHIELD].include?(@opponent.ability))
              abilityscore += 60 unless i.item == :ABILITYSHIELD
            end
          when :MAGMAARMOR
            bothOpponents.each { |opp|
              abilityscore += 20 if (opp == @opponent ? aimem : aimem2).any? { |moveloop| moveloop != nil && [0x0C, 0x0D].include?(moveloop.function) } # Ice Beam, Blizzard
            }
          when :SOUNDPROOF
            bothOpponents.each { |opp|
              oppbestmove = checkAIbestMove(opp)
              abilityscore += 60 if oppbestmove.checkSoundMove?(opp) && !moldBreakerCheck(opp, i, oppbestmove)
            }
          when :THICKFAT
            bothOpponents.each { |opp|
              oppbestmove = checkAIbestMove(opp)
              abilityscore += 30 if [:ICE, :FIRE].include?(oppbestmove.pbType(opp)) && !moldBreakerCheck(opp, i, oppbestmove)
            }
          when :LIQUIDOOZE
            bothOpponents.each { |opp|
              (opp == @opponent ? aimem : aimem2).each { |j| abilityscore += 40 if j.move == :LEECHSEED || j.isDrainingMove? }
            }
          when :RIVALRY
            bothOpponents.each { |opp|
              abilityscore += 30 if i.gender == opp.gender && !i.isGenderless? && !opp.isGenderless?
            }
          when :SCRAPPY, :MINDSEYE
            bothOpponents.each { |opp| abilityscore += 30 if opp.hasType?(:GHOST) }
          when :LIGHTMETAL
            bothOpponents.each { |opp|
              abilityscore += 10 if checkAImoves([:GRASSKNOT, :LOWKICK], opp == @opponent ? aimem : aimem2)
            }
          when :ANALYTIC
            abilityscore += 30 if [@opponent, @opponent2, @attacker.pbPartner].none? { |battler| battler && battler.hp > 0 && pbAIfaster?(nil, nil, i, battler) }
          when :ILLUSION
            abilityscore += 40
          when :MOXIE, :CHILLINGNEIGH, :ASONECHILLING, :SOULHEART, :GRIMNEIGH, :ASONEGRIM, :BEASTBOOST, :EELEVATE, :BATTLEBOND, :PRISMPOWER
            unless [:BATTLEBOND, :PRISMPOWER].include?(i.ability) && i.permeffs[:BattleBond]
              bothOpponents.each { |opp|
                abilityscore += 40 if pbAIfaster?(nil, nil, i, opp) && roughdamagearray[opp == @opponent ? 0 : 1].max >= 100
              }
            end
          when :SPEEDBOOST
            bothOpponents.each { |opp|
              abilityscore += 25 if pbAIfaster?(nil, nil, i, opp) && opp.hp.to_f / opp.totalhp < 0.3
            }
          when :PRANKSTER
            bothOpponents.each { |opp|
              abilityscore += 50 if !pbAIfaster?(nil, nil, i, opp) && !opp.hasType?(:DARK)
            }
          when :GALEWINGS
            bothOpponents.each { |opp| abilityscore += 50 if !pbAIfaster?(nil, nil, i, opp) } if i.hp == i.totalhp
            # i.hp has been updated to account for hazards earlier in the method
          when :BULLETPROOF
            bothOpponents.each { |opp|
              oppbestmove = checkAIbestMove(opp)
              abilityscore += 60 if oppbestmove.bulletMove? && !moldBreakerCheck(opp, i, oppbestmove)
            }
          when :AURABREAK
            bothOpponents.each { |opp|
              abilityscore += 50 if opp.ability == :FAIRYAURA || opp.ability == :DARKAURA
            }
          when :PROTEAN, :LIBERO
            abilityscore += 40 if (Gen < 9 || !Rejuv) && (pbAIfaster?(nil, nil, i, @opponent) || (@opponent2 && pbAIfaster?(nil, nil, i, @opponent2)))
          when :DANCER
            bothOpponents.each { |opp|
              abilityscore += 30 if (opp == @opponent ? aimem : aimem2).any? { |move| pbChangeMove(move, opp).danceMove? }
            }
          when :MERCILESS
            abilityscore += 50 if @opponent.status == :POISON || (@opponent2 && @opponent2.status == :POISON)
          when :DAZZLING, :QUEENLYMAJESTY, :ARMORTAIL
            bothOpponents.each { |opp|
              next if moldBreakerCheck(opp, i)
              abilityscore += 20 if checkAIpriority(opp == @opponent ? aimem : aimem2)
            }
          when :MIRRORARMOR
            if @battle.FE == :STARLIGHT && @mondata.skill >= BESTSKILL
              bothOpponents.each { |opp|
                next if moldBreakerCheck(opp, i)
                abilityscore += 20 if checkAIpriority(opp == @opponent ? aimem : aimem2)
              }
            end
          when :SANDSTREAM, :HAILWARNING, :SANDSPIT
            bothOpponents.each { |opp| abilityscore += 70 if opp.ability == :WONDERGUARD }
          when :PROPELLERTAIL, :STALWART
            abilityscore += 40 if checkAImovesAllOpponents([:FOLLOWME, :RAGEPOWDER, :ALLYSWITCH, :SPOTLIGHT])
          when :ICESCALES
            bothOpponents.each { |opp|
              next if moldBreakerCheck(opp, i)
              abilityscore += 40 if opp.spatk > opp.attack
            }
          when :UNSEENFIST, :PIERCINGDRILL
            if i.item != :PUNCHINGGLOVE
              bothOpponents.each { |opp|
                abilityscore += Gen < Champs ? 30 : 20 if checkAImoves(PBStuff::PROTECTMOVE, opp == @opponent ? aimem : aimem2)
              }
            end
          when :PURIFYINGSALT
            bothOpponents.each { |opp|
              next if moldBreakerCheck(opp, i)
              memory = opp == @opponent ? aimem : aimem2
              abilityscore += 20 if checkAImoves(PBStuff::BURNMOVE, memory)
              abilityscore += 20 if checkAImoves(PBStuff::PARAMOVE, memory)
              abilityscore += 20 if checkAImoves(PBStuff::SLEEPMOVE, memory)
              abilityscore += 20 if checkAImoves(PBStuff::POISONMOVE, memory)
              oppbestmove = checkAIbestMove(opp)
              abilityscore += 30 if oppbestmove.pbType(opp) == :GHOST && !moldBreakerCheck(opp, i, oppbestmove)
            }
          when :WINDRIDER
            bothOpponents.each { |opp|
              oppbestmove = checkAIbestMove(opp)
              abilityscore += 60 if oppbestmove.windMove? && !moldBreakerCheck(opp, i, oppbestmove)
            }
          when :HOSPITALITY, :SWORNDUTY
            if @attacker.pbPartner.hp > 0
              partner_percent = @attacker.pbPartner.hp / @attacker.pbPartner.totalhp
              abilityscore += 30 if partner_percent < 0.75
              abilityscore += 30 if !safe_switch && partner_percent > 0.3 && partner_percent < 0.6
            end
          when :SUPERSWEETSYRUP
            if @attacker.pbPartner.hp > 0 && !i.permeffs[:SupersweetSyrup]
              partnerLowAccMoves = @attacker.pbPartner.moves.find_all { |move| move && pbRoughAccuracy(move, @attacker.pbPartner, @opponent).between?(50, 90) }
              abilityscore += 10 * partnerLowAccMoves.length
            end
          when :TERAFORMZERO
            if nonmegaform.ability != :TERAFORMZERO # the ability doesn't activate if terapagos is already terastallized
              abilityscore += getFieldDisruptScore(tempOnly: true) if @battle.canEndTempFieldOrOverlay?
              if @battle.weather != 0
                abilityscore += 50 if pbGetMonRoles(@opponent).include?(:WEATHERSETTER)
                abilityscore += 50 if @opponent2 && pbGetMonRoles(@opponent2).include?(:WEATHERSETTER)
                abilityscore -= 50 if @attacker.pbPartner.hp > 0 && pbGetMonRoles(@attacker.pbPartner).include?(:WEATHERSETTER)
              end
            end
        end
      end
      if transformed # pokemon has imposter ability. i's ability has been updated to be the copied ability earlier
        abilityscore += 50 if [:PUREPOWER, :HUGEPOWER, :SPEEDBOOST, :WONDERGUARD, :MOXIE, :CHILLINGNEIGH, :SOULHEART, :GRIMNEIGH, :ASONECHILLING, :ASONEGRIM, :BEASTBOOST, :EELEVATE].include?(i.ability) || ([:PROTEAN, :LIBERO].include?(i.ability) && (Gen < 9 || Rejuv))
        abilityscore += 30 if i.level > nonmegaform.level || pbGetMonRoles(@opponent).include?(:SWEEPER)
      end
      monscore += abilityscore
      PBDebug.dblog(sprintf("Abilities: %d", abilityscore))

      # Items
      if @mondata.skill >= HIGHSKILL
        if i.item == :AIRBALLOON
          allground = true
          for j in aimem
            allground = false if j.pbType(@opponent) != :GROUND
          end
          if @opponent2
            for j in aimem2
              allground = false if j.pbType(@opponent2) != :GROUND
            end
          end
          itemscore += 60 if :GROUND == checkAIbestMove().pbType(@opponent) || (@opponent2 && :GROUND == checkAIbestMove(@opponent2).pbType(@opponent2))
          itemscore += 100 if allground
        end
        if i.item == :FLOATSTONE
          bothOpponents.each { |opp|
            itemscore += 10 if checkAImoves([:LOWKICK, :GRASSKNOT], opp == @opponent ? aimem : aimem2)
          }
        end
        if i.item == :DESTINYKNOT
          bothOpponents.each { |opp|
            itemscore += 20 if opp.ability == :CUTECHARM
            itemscore += 20 if checkAImoves([:ATTRACT], opp == @opponent ? aimem : aimem2)
          }
        end
        if i.item == :ABSORBBULB
          itemscore += 25 if :WATER == checkAIbestMove().pbType(@opponent) || (@opponent2 && :WATER == checkAIbestMove(@opponent2).pbType(@opponent2))
        end
        if i.item == :CELLBATTERY && (Reborn || @battle.FE != :ELECTERRAIN)
          itemscore += 25 if :ELECTRIC == checkAIbestMove().pbType(@opponent) || (@opponent2 && :ELECTRIC == checkAIbestMove(@opponent2).pbType(@opponent2))
        end
        # Focus Sash, Sturdy and similar
        # Not always item-related but will have to go to itemscore anyway
        if survivesAt1HP?(i)
          tempscore = 0
          if i.takesWeatherDamage? && @battle.weatherduration != 1
            tempscore -= 40
          end
          stealthrock = @attacker.pbOwnSide.effects[:StealthRock]
          corrosive = @battle.FE == :CORROSIVE && !i.isAirborne? && !i.hasType?(:POISON) && !i.hasType?(:STEEL) && ![:POISONHEAL, :IMMUNITY, :WONDERGUARD, :TOXICBOOST, :PASTELVEIL].include?(i.ability) && i.crested != :ZANGOOSE
          spikes = @attacker.pbOwnSide.effects[:Spikes] > 0 && !i.isAirborne?
          toxicspikes = @attacker.pbOwnSide.effects[:ToxicSpikes] > 0 && !i.isAirborne? && i.pbCanPoison?(nil, nil) && !i.hydrationActive? && i.ability != :POISONHEAL
          if !@battle.magicGuardAbilities.include?(i.ability) && !i.hasWorkingItem(:HEAVYDUTYBOOTS) && (stealthrock || corrosive || spikes || toxicspikes)
            tempscore -= 40
          end
          if !safe_switch
            tempscore -= 80
          end
          bothOpponents.each { |opp|
            next if (i.ability == :STURDY || (@battle.FE == :COLOSSEUM && i.ability == :STALWART)) && moldBreakerCheck(opp, i)
            tempscore += 30 * opp.stages[PBStats::ATTACK]
            tempscore += 30 * opp.stages[PBStats::SPATK]
            tempscore += 30 * opp.stages[PBStats::SPEED]
          }
          itemscore += tempscore
        end
        if i.item == :SNOWBALL
          itemscore += 25 if :ICE == checkAIbestMove().pbType(@opponent) || (@opponent2 && :ICE == checkAIbestMove(@opponent2).pbType(@opponent2))
        end
        if i.item == :PROTECTIVEPADS
          bothOpponents.each { |opp|
            itemscore += 25 if [:STATIC, :POISONPOINT, :ROUGHSKIN, :IRONBARBS, :FLAMEBODY, :CUTECHARM, :MUMMY, :LINGERINGAROMA, :WANDERINGSPIRIT, :AFTERMATH, :GOOEY, :TANGLINGHAIR].include?(opp.ability) ||
              (opp.ability == :PERISHBODY && @battle.FE != :HOLY) ||
              (opp.ability == :EFFECTSPORE && !i.powderImmune?) ||
              opp.item == :ROCKYHELMET
          }
        end
        if i.item == :MAGICALSEED
          itemscore += 75 if (@battle.FE == :NEWWORLD || (!Rejuv && @battle.FE == :INVERSE)) && @attacker.hp != 0 # hard switch/pivot
        end
      end
      monscore += itemscore
      PBDebug.dblog(sprintf("Items: %d", itemscore))

      # Fields
      fieldscore = 0
      if @mondata.skill >= BESTSKILL
        case @battle.FE
          when :ELECTERRAIN
            fieldscore += 50 if i.ability == :SURGESURFER
            fieldscore += 50 if Rejuv && i.ability == :TERAVOLT
            fieldscore += 25 if i.ability == :GALVANIZE
            fieldscore += 25 if Rejuv && i.ability == :STEADFAST
            fieldscore += 25 if Rejuv && i.ability == :QUICKFEET
            fieldscore += 25 if Rejuv && i.ability == :LIGHTNINGROD
            fieldscore += 25 if Rejuv && i.ability == :BATTERY
            fieldscore += 25 if i.ability == :TRANSISTOR
            fieldscore += 25 if i.hasType?(:ELECTRIC)
            fieldscore += 25 if i.ability == :ELECTROMORPHOSIS
            fieldscore += 20 if Rejuv && i.ability == :STATIC
            fieldscore += 15 if Rejuv && i.ability == :VOLTABSORB
          when :GRASSY
            fieldscore += 30 if i.ability == :GRASSPELT
            fieldscore += 30 if i.ability == :COTTONDOWN
            fieldscore += 30 if Rejuv && i.ability == :OVERGROW
            fieldscore += 20 if Rejuv && i.ability == :SAPSIPPER
            fieldscore += 25 if Rejuv && i.ability == :HARVEST
            fieldscore += 25 if i.hasType?(:GRASS) || i.hasType?(:FIRE)
          when :MISTY
            fieldscore += 20 if i.hasType?(:FAIRY)
            fieldscore += 20 if i.ability == :MARVELSCALE
            fieldscore += 20 if i.ability == :DRYSKIN
            fieldscore += 20 if i.ability == :WATERCOMPACTION
            fieldscore += 25 if i.ability == :PIXILATE
            fieldscore += 25 if i.ability == :SOULHEART
            fieldscore += 20 if i.ability == :PASTELVEIL
          when :DARKCRYSTALCAVERN
            fieldscore += 30 if i.ability == :PRISMARMOR
            fieldscore += 30 if i.ability == :SHADOWSHIELD
          when :CHESS
            fieldscore += 10 if i.ability == :ADAPTABILITY
            fieldscore += 10 if i.ability == :SYNCHRONIZE
            fieldscore += 10 if i.ability == :ANTICIPATION
            fieldscore += 10 if i.ability == :TELEPATHY
            fieldscore += 30 if Rejuv && i.ability == :STANCECHANGE
            fieldscore += 25 if Rejuv && i.ability == :STALL
          when :BIGTOP
            fieldscore += 30 if i.ability == :SHEERFORCE
            fieldscore += 30 if i.ability == :PUREPOWER
            fieldscore += 30 if i.ability == :HUGEPOWER
            fieldscore += 30 if i.ability == :GUTS
            fieldscore += 10 if i.ability == :DANCER
            fieldscore += 20 if i.hasType?(:FIGHTING)
            fieldscore += 20 if i.ability == :PUNKROCK || i.ability == :JUNGLEBEAT
            fieldscore += 10 if i.ability == :COSTAR && @battle.doublebattle
          when :BURNING
            fieldscore += 25 if i.hasType?(:FIRE)
            fieldscore += 15 if i.ability == :WATERVEIL
            fieldscore += 15 if i.ability == :HEATPROOF
            fieldscore += 15 if i.ability == :WATERBUBBLE
            fieldscore += 25 if i.ability == :STEAMENGINE
            fieldscore += 30 if i.ability == :FLASHFIRE
            fieldscore += 30 if i.ability == :FLAREBOOST
            fieldscore += 30 if i.ability == :BLAZE
            fieldscore += 30 if i.ability == :WELLBAKEDBODY
            fieldscore += 15 if i.ability == :THERMALEXCHANGE
            fieldscore -= 30 if (i.ability == :ICEBODY)
            fieldscore -= 30 if i.ability == :LEAFGUARD
            fieldscore -= 30 if i.ability == :GRASSPELT
            fieldscore -= 30 if i.ability == :FLUFFY
            fieldscore -= 30 if i.ability == :ICEFACE
          when :VOLCANIC
            fieldscore += 25 if i.hasType?(:FIRE)
            fieldscore += 15 if i.ability == :WATERVEIL
            fieldscore += 15 if i.ability == :HEATPROOF
            fieldscore += 15 if i.ability == :WATERBUBBLE
            fieldscore += 20 if i.ability == :MAGMAARMOR || nonmegaform.ability == :MAGMAARMOR
            fieldscore += 25 if i.ability == :STEAMENGINE
            fieldscore += 30 if i.ability == :FLASHFIRE
            fieldscore += 30 if i.ability == :FLAREBOOST
            fieldscore += 30 if i.ability == :BLAZE
            fieldscore -= 30 if (i.ability == :ICEBODY)
            fieldscore -= 30 if i.ability == :LEAFGUARD
            fieldscore -= 30 if i.ability == :GRASSPELT
            fieldscore -= 30 if i.ability == :FLUFFY
            fieldscore -= 30 if i.ability == :ICEFACE
          when :SWAMP
            fieldscore += 15 if i.ability == :GOOEY
            fieldscore += 20 if i.ability == :WATERCOMPACTION
            fieldscore += 15 if i.ability == :PROPELLERTAIL
            fieldscore += 20 if i.ability == :DRYSKIN
            fieldscore += 10 if i.ability == :RATTLED || nonmegaform.ability == :RATTLED
          when :RAINBOW
            fieldscore += 10 if i.ability == :WONDERSKIN
            fieldscore += 20 if i.ability == :MARVELSCALE
            fieldscore += 25 if i.ability == :SOULHEART
            fieldscore += 30 if i.ability == :CLOUDNINE
            fieldscore += 30 if i.ability == :PRISMARMOR
            fieldscore += 20 if i.ability == :PASTELVEIL
          when :CORROSIVE
            fieldscore += 20 if i.ability == :POISONHEAL
            fieldscore += 25 if i.ability == :TOXICBOOST
            fieldscore += 30 if i.ability == :MERCILESS
            fieldscore += 30 if i.ability == :CORROSION
            fieldscore += 20 if i.ability == :TOXICCHAIN
            fieldscore += 15 if i.hasType?(:POISON)
          when :CORROSIVEMIST
            fieldscore += 10 if i.ability == :WATERCOMPACTION
            fieldscore += 20 if i.ability == :POISONHEAL
            fieldscore += 25 if i.ability == :TOXICBOOST
            fieldscore += 30 if i.ability == :MERCILESS
            fieldscore += 30 if i.ability == :CORROSION
            fieldscore += 20 if i.ability == :TOXICCHAIN
            fieldscore += 15 if i.hasType?(:POISON)
          when :DESERT
            fieldscore += 20 if i.ability == :SANDSTREAM || nonmegaform.ability == :SANDSTREAM || i.ability == :SANDSPIT || nonmegaform.ability == :SANDSPIT
            fieldscore += 25 if i.ability == :SANDVEIL
            fieldscore += 30 if i.ability == :SANDFORCE
            fieldscore += 50 if i.ability == :SANDRUSH
            fieldscore += 20 if i.ability == :EARTHEATER
            fieldscore += 20 if i.hasType?(:GROUND)
            fieldscore -= 25 if i.hasType?(:ELECTRIC)
          when :ICY
            fieldscore += 25 if i.hasType?(:ICE)
            fieldscore += 25 if (i.ability == :ICEBODY)
            fieldscore += 25 if i.ability == :SNOWCLOAK
            fieldscore += 25 if i.ability == :REFRIGERATE
            fieldscore += 20 if i.ability == :ICESCALES
            fieldscore += 50 if i.ability == :SLUSHRUSH || i.crested == :EMPOLEON
          when :ROCKY
            fieldscore -= 15 if i.ability == :GORILLATACTICS
          when :FOREST
            fieldscore += 20 if i.ability == :SAPSIPPER
            fieldscore += 25 if i.hasType?(:GRASS) || i.hasType?(:BUG)
            fieldscore += 30 if i.ability == :GRASSPELT
            fieldscore += 30 if i.ability == :OVERGROW
            fieldscore += 30 if i.ability == :SWARM
            fieldscore += 20 if i.ability == :EFFECTSPORE
          when :SUPERHEATED
            fieldscore += 15 if i.hasType?(:FIRE)
          when :VOLCANICTOP
            fieldscore += 15 if i.hasType?(:FIRE)
            fieldscore += 25 if i.ability == :STEAMENGINE
            fieldscore -= 30 if i.ability == :ICEFACE
            fieldscore += 30 if i.ability == :GALEWINGS && @battle.pbWeather(nil) == :STRONGWINDS
          when :FACTORY
            fieldscore += 25 if i.hasType?(:ELECTRIC)
            fieldscore += 20 if i.ability == :MOTORDRIVE
            fieldscore += 20 if i.ability == :STEELWORKER
            fieldscore += 25 if i.ability == :DOWNLOAD
            fieldscore += 25 if i.ability == :TECHNICIAN
            fieldscore += 25 if i.ability == :GALVANIZE
          when :SHORTCIRCUIT
            fieldscore += 20 if i.ability == :VOLTABSORB
            fieldscore += 20 if i.ability == :STATIC
            fieldscore += 25 if i.ability == :GALVANIZE
            fieldscore += 50 if i.ability == :SURGESURFER
            fieldscore += 20 if Rejuv && i.ability == :DOWNLOAD
            fieldscore += 25 if i.hasType?(:ELECTRIC)
          when :WASTELAND
            fieldscore += 10 if i.hasType?(:POISON)
            fieldscore += 10 if i.ability == :CORROSION
            fieldscore += 20 if i.ability == :POISONHEAL
            fieldscore += 20 if i.ability == :EFFECTSPORE
            fieldscore += 20 if i.ability == :POISONPOINT
            fieldscore += 20 if i.ability == :STENCH
            fieldscore += 20 if i.ability == :GOOEY
            fieldscore += 25 if i.ability == :TOXICBOOST
            fieldscore += 30 if i.ability == :MERCILESS
          when :ASHENBEACH
            fieldscore += 10 if i.hasType?(:FIGHTING)
            fieldscore += 15 if i.ability == :INNERFOCUS
            fieldscore += 15 if i.ability == :OWNTEMPO
            fieldscore += 15 if i.ability == :PUREPOWER
            fieldscore += 15 if i.ability == :STEADFAST
            fieldscore += 15 if i.ability == :STALWART
            fieldscore += 20 if i.ability == :SANDSTREAM || nonmegaform.ability == :SANDSTREAM
            fieldscore += 20 if i.ability == :WATERCOMPACTION
            fieldscore += 30 if i.ability == :SANDFORCE
            fieldscore += 35 if i.ability == :SANDVEIL
            fieldscore += 50 if i.ability == :SANDRUSH
          when :WATERSURFACE
            fieldscore += 25 if i.hasType?(:WATER)
            fieldscore += 25 if i.hasType?(:ELECTRIC)
            fieldscore += 25 if i.ability == :WATERVEIL
            fieldscore += 25 if i.ability == :HYDRATION
            fieldscore += 25 if i.ability == :TORRENT
            fieldscore += 25 if i.ability == :SCHOOLING
            fieldscore += 25 if i.ability == :WATERCOMPACTION
            fieldscore += 50 if i.ability == :SWIFTSWIM
            fieldscore += 50 if i.ability == :SURGESURFER
            fieldscore += 25 if i.ability == :STEAMENGINE
            fieldscore -= 50 if PBTypes.typesEff(:WATER, i.types, inverse: @battle.inverse?).superEffective?
          when :UNDERWATER
            fieldscore += 25 if i.hasType?(:WATER)
            fieldscore += 25 if i.hasType?(:ELECTRIC)
            fieldscore += 25 if i.ability == :WATERVEIL
            fieldscore += 25 if i.ability == :HYDRATION
            fieldscore += 25 if i.ability == :TORRENT
            fieldscore += 25 if i.ability == :SCHOOLING
            fieldscore += 25 if i.ability == :WATERCOMPACTION
            fieldscore += 50 if i.ability == :SWIFTSWIM
            fieldscore += 25 if i.ability == :STEAMENGINE
            fieldscore -= 50 if PBTypes.typesEff(:WATER, i.types, inverse: @battle.inverse?).superEffective?
          when :CAVE
            fieldscore += 15 if i.hasType?(:GROUND)
          when :GLITCH
            fieldscore += 20 if Rejuv && i.ability == :DOWNLOAD
          when :CRYSTALCAVERN
            fieldscore += 25 if i.hasType?(:DRAGON)
            fieldscore += 30 if i.ability == :PRISMARMOR
            fieldscore += 20 if i.ability == :TERAFORMZERO
            fieldscore += 10 if i.ability == :TERASHELL
          when :MURKWATERSURFACE
            fieldscore += 25 if i.hasType?(:WATER)
            fieldscore += 25 if i.hasType?(:POISON)
            fieldscore += 25 if i.hasType?(:ELECTRIC)
            fieldscore += 25 if i.ability == :SCHOOLING
            fieldscore += 25 if i.ability == :WATERCOMPACTION
            fieldscore += 25 if i.ability == :TOXICBOOST
            fieldscore += 25 if i.ability == :POISONHEAL
            fieldscore += 25 if i.ability == :MERCILESS
            fieldscore += 50 if i.ability == :SWIFTSWIM
            fieldscore += 50 if i.ability == :SURGESURFER
            fieldscore += 20 if i.ability == :GOOEY
            fieldscore += 20 if i.ability == :STENCH
          when :MOUNTAIN
            fieldscore += 25 if i.hasType?(:ROCK)
            fieldscore += 25 if i.hasType?(:FLYING)
            fieldscore += 20 if [i.ability, nonmegaform.ability].intersect?([:SNOWWARNING, :HAILWARNING])
            fieldscore += 20 if i.ability == :DROUGHT || nonmegaform.ability == :DROUGHT
            fieldscore += 25 if i.ability == :LONGREACH
            fieldscore += 30 if i.ability == :GALEWINGS && @battle.pbWeather(nil) == :STRONGWINDS
            fieldscore += 20 if i.ability == :WINDRIDER && @battle.pbWeather(nil) == :STRONGWINDS
            fieldscore += 20 if i.ability == :WINDPOWER && @battle.pbWeather(nil) == :STRONGWINDS
          when :SNOWYMOUNTAIN
            fieldscore += 25 if i.hasType?(:ROCK)
            fieldscore += 25 if i.hasType?(:FLYING)
            fieldscore += 25 if i.hasType?(:ICE)
            fieldscore += 20 if [i.ability, nonmegaform.ability].intersect?([:SNOWWARNING, :HAILWARNING])
            fieldscore += 20 if i.ability == :DROUGHT || nonmegaform.ability == :DROUGHT
            fieldscore += 20 if (i.ability == :ICEBODY)
            fieldscore += 20 if i.ability == :SNOWCLOAK
            fieldscore += 25 if i.ability == :LONGREACH
            fieldscore += 25 if i.ability == :REFRIGERATE
            fieldscore += 30 if i.ability == :GALEWINGS && @battle.pbWeather(nil) == :STRONGWINDS
            fieldscore += 20 if i.ability == :WINDRIDER && @battle.pbWeather(nil) == :STRONGWINDS
            fieldscore += 20 if i.ability == :WINDPOWER && @battle.pbWeather(nil) == :STRONGWINDS
            fieldscore += 20 if i.ability == :ICESCALES
            fieldscore += 50 if i.ability == :SLUSHRUSH || i.crested == :EMPOLEON
          when :HOLY
            fieldscore += 20 if i.hasType?(:NORMAL)
            fieldscore += 20 if i.ability == :JUSTIFIED
            fieldscore += 25 if i.ability == :POWERSPOT
            fieldscore += 10 if i.ability == :PURIFYINGSALT
          when :MIRROR
            fieldscore += 25 if i.ability == :SANDVEIL
            fieldscore += 25 if i.ability == :SNOWCLOAK
            fieldscore += 25 if i.ability == :ILLUSION
            fieldscore += 25 if i.ability == :TANGLEDFEET
            fieldscore += 25 if i.ability == :MAGICBOUNCE
            fieldscore += 25 if i.ability == :COLORCHANGE
            fieldscore += 25 if i.ability == :MIRRORARMOR
          when :FAIRYTALE
            fieldscore += 25 if i.hasType?(:FAIRY)
            fieldscore += 25 if i.hasType?(:STEEL)
            fieldscore += 40 if i.hasType?(:DRAGON)
            fieldscore += 25 if i.ability == :POWEROFALCHEMY
            fieldscore += 25 if i.ability == :MIRRORARMOR || nonmegaform.ability == :MIRRORARMOR
            fieldscore += 25 if i.ability == :PASTELVEIL
            fieldscore += 25 if i.ability == :MAGICGUARD || nonmegaform.ability == :MAGICGUARD
            fieldscore += 25 if i.ability == :MAGICBOUNCE
            fieldscore += 25 if i.ability == :FAIRYAURA
            fieldscore += 25 if i.ability == :BATTLEARMOR || nonmegaform.ability == :BATTLEARMOR
            fieldscore += 25 if i.ability == :SHELLARMOR || nonmegaform.ability == :SHELLARMOR
            fieldscore += 25 if i.ability == :ARMORTAIL || nonmegaform.ability == :ARMORTAIL
            fieldscore += 25 if i.ability == :MAGICIAN
            fieldscore += 25 if i.ability == :MARVELSCALE
            fieldscore += 30 if i.ability == :STANCECHANGE
            fieldscore += 30 if i.ability == :DAUNTLESSSHIELD
            fieldscore += 30 if i.ability == :INTREPIDSWORD
          when :DRAGONSDEN
            fieldscore += 25 if i.hasType?(:FIRE)
            fieldscore += 50 if i.hasType?(:DRAGON)
            fieldscore += 20 if i.ability == :MARVELSCALE
            fieldscore += 20 if i.ability == :MULTISCALE
            fieldscore += 25 if i.ability == :DRAGONSMAW
            fieldscore += 25 if i.ability == :DRAGONIZE
            fieldscore += 20 if i.ability == :GOODASGOLD
            fieldscore += 20 if i.ability == :MAGMAARMOR || nonmegaform.ability == :MAGMAARMOR
          when *PBFields::FLOWERGARDEN
            fieldscore += 25 if i.hasType?(:GRASS)
            fieldscore += 25 if i.hasType?(:BUG)
            fieldscore += 20 if i.ability == :FLOWERGIFT
            fieldscore += 20 if i.ability == :FLOWERVEIL
            fieldscore += 20 if i.ability == :DROUGHT || nonmegaform.ability == :DROUGHT
            fieldscore += 20 if i.ability == :DRIZZLE || nonmegaform.ability == :DRIZZLE
            fieldscore += 20 if Rejuv && (i.ability == :GRASSYSURGE || nonmegaform.ability == :GRASSYSURGE)
            fieldscore += 15 if i.ability == :SEEDSOWER || nonmegaform.ability == :SEEDSOWER
            fieldscore += 25 if i.ability == :RIPEN
          when :STARLIGHT
            fieldscore += 25 if i.hasType?(:PSYCHIC)
            fieldscore += 25 if i.hasType?(:FAIRY)
            fieldscore += 25 if i.hasType?(:DARK)
            fieldscore += 20 if i.ability == :MARVELSCALE
            fieldscore += 20 if i.ability == :VICTORYSTAR
            fieldscore += 25 if i.ability == :ILLUMINATE || nonmegaform.ability == :ILLUMINATE
            fieldscore += 30 if i.ability == :SHADOWSHIELD
          when :NEWWORLD
            fieldscore += 25 if i.hasType?(:FLYING)
            fieldscore += 25 if i.hasType?(:DARK)
            fieldscore += 20 if i.ability == :VICTORYSTAR
            fieldscore += 25 if PBStuff::LevitateAbilities.include?(i.ability)
            fieldscore += 30 if i.ability == :SHADOWSHIELD
          when :INVERSE
            fieldscore += 10 if i.hasType?(:NORMAL)
            fieldscore += 10 if i.hasType?(:ICE)
            fieldscore -= 10 if i.hasType?(:FIRE)
            fieldscore -= 30 if i.hasType?(:STEEL)
          when :PSYTERRAIN
            fieldscore += 25 if i.hasType?(:PSYCHIC)
            fieldscore += 20 if i.ability == :PUREPOWER
            fieldscore += 20 if i.ability == :ANTICIPATION || nonmegaform.ability == :ANTICIPATION
            fieldscore += 20 if Rejuv && (i.ability == :FOREWARN || nonmegaform.ability == :FOREWARN)
            fieldscore += 50 if i.ability == :TELEPATHY
            fieldscore += 25 if i.ability == :POWERSPOT
            fieldscore += 10 if i.ability == :MINDSEYE
          when :DIMENSIONAL
            fieldscore += 25 if i.hasType?(:DARK)
            fieldscore += 30 if i.ability == :SHADOWSHIELD
            fieldscore += 30 if i.ability == :BEASTBOOST
            fieldscore += 30 if i.ability == :PERSIHBODY
            fieldscore += 20 if i.ability == :RATTLED || nonmegaform.ability == :RATTLED
            fieldscore += 20 if i.ability == :BERSERK || nonmegaform.ability == :BERSERK
            fieldscore += 20 if i.ability == :ANGERPOINT || nonmegaform.ability == :ANGERPOINT
            fieldscore += 20 if i.ability == :JUSTIFIED || nonmegaform.ability == :JUSTIFIED
            fieldscore += 20 if [:PRESSURE, *PBStuff::UnnerveAbilities].intersect?([i.ability, nonmegaform.ability])
          when :FROZENDIMENSION
            fieldscore += 25 if i.hasType?(:ICE)
            fieldscore += 25 if i.hasType?(:DARK)
            fieldscore += 25 if (i.ability == :ICEBODY)
            fieldscore += 25 if i.ability == :SNOWCLOAK
            fieldscore += 25 if i.ability == :REFRIGERATE
            fieldscore += 50 if i.ability == :SLUSHRUSH || i.crested == :EMPOLEON
            fieldscore += 25 if i.ability == :ICEFACE
            fieldscore += 20 if i.ability == :RATTLED || nonmegaform.ability == :RATTLED
            fieldscore += 20 if i.ability == :BERSERK || nonmegaform.ability == :BERSERK
            fieldscore += 20 if i.ability == :ANGERPOINT || nonmegaform.ability == :ANGERPOINT
            fieldscore += 20 if i.ability == :JUSTIFIED || nonmegaform.ability == :JUSTIFIED
            fieldscore += 20 if [:PRESSURE, *PBStuff::UnnerveAbilities].intersect?([i.ability, nonmegaform.ability])
          when :HAUNTED
            fieldscore += 25 if i.hasType?(:GHOST)
            fieldscore += 25 if i.ability == :RATTLED
            fieldscore += 15 if i.ability == :CURSEDBODY
            fieldscore += 25 if i.ability == :PERISHBODY
            fieldscore += 25 if i.ability == :POWERSPOT
          when :CORRUPTED
            fieldscore += 25 if i.hasType?(:POISON)
            fieldscore -= 25 if [:GRASSPELT, :LEAFGUARD, :FLOWERVEIL].include?(i.ability)
            fieldscore += 25 if i.ability == :POISONHEAL
            fieldscore += 15 if [:WONDERSKIN, :IMMUNITY, :PASTELVEIL].include?(i.ability)
            fieldscore += 15 if [:POISONTOUCH, :POISONPOINT].include?(i.ability)
            fieldscore += 15 if i.ability == :LIQUIDOOZE
            fieldscore += 30 if [:TOXICBOOST, :CORROSION].include?(i.ability)
            if i.ability == :DRYSKIN
              fieldscore += 25 if i.hasType?(:POISON)
              fieldscore -= 25 if !i.hasType?(:POISON)
            end
          when :BEWITCHED
            fieldscore += 20 if i.ability == :FLOWERVEIL
            fieldscore += 25 if i.hasType?(:GRASS) || i.hasType?(:FAIRY)
            fieldscore += 25 if i.ability == :NATURALCURE
            fieldscore += 25 if i.ability == :PASTELVEIL
            fieldscore += 25 if i.ability == :PRANKSTER
            fieldscore += 25 if i.ability == :COTTONDOWN
            fieldscore += 25 if i.ability == :POWERSPOT
            fieldscore += 20 if i.ability == :EFFECTSPORE
          when :SKY
            fieldscore += 15 if i.ability == :EARLYBIRD
            fieldscore += 15 if i.ability == :CLOUDNINE
            fieldscore += 25 if i.hasType?(:FLYING)
            fieldscore += 25 if i.ability == :GALEWINGS
            fieldscore += 25 if i.ability == :BIGPECKS || nonmegaform.ability == :BIGPECKS
            fieldscore += 25 if PBStuff::LevitateAbilities.intersect?([i.ability, nonmegaform.ability])
            fieldscore += 25 if i.ability == :AERILATE
            fieldscore += 30 if i.ability == :LONGREACH
          when :INFERNAL
            fieldscore += 25 if i.hasType?(:FIRE)
            fieldscore += 25 if i.hasType?(:DARK)
            fieldscore += 25 if i.ability == :PERSIHBODY
            fieldscore += 30 if i.ability == :MAGMAARMOR || nonmegaform.ability == :MAGMAARMOR
            fieldscore += 20 if i.ability == :FLAMEBODY || nonmegaform.ability == :FLAMEBODY
            fieldscore += 20 if i.ability == :DESOLATELAND || nonmegaform.ability == :DESOLATELAND
            fieldscore += 25 if i.ability == :STEAMENGINE
            fieldscore += 30 if i.ability == :FLASHFIRE
            fieldscore += 30 if i.ability == :FLAREBOOST
            fieldscore += 30 if i.ability == :BLAZE
            fieldscore -= 20 if i.ability == :PASTELVEIL
            fieldscore -= 30 if i.ability == :ICEFACE
          when :COLOSSEUM
            fieldscore += 15 if i.ability == :STALWART
            fieldscore += 20 if i.ability == :DEFIANT
            fieldscore += 20 if i.ability == :COMPETITIVE
            fieldscore -= 30 if i.ability == :RATTLED || i.ability == :WIMPOUT
            fieldscore += 25 if i.ability == :WONDERGUARD
            fieldscore += 25 if i.ability == :QUICKDRAW
            fieldscore += 25 if i.ability == :EMERGENCYEXIT
            fieldscore += 25 if i.ability == :BATTLEARMOR || nonmegaform.ability == :BATTLEARMOR
            fieldscore += 25 if i.ability == :SHELLARMOR || nonmegaform.ability == :SHELLARMOR
            fieldscore += 25 if i.ability == :MIRRORARMOR || nonmegaform.ability == :MIRRORARMOR
            fieldscore += 25 if i.ability == :MAGICGUARD || nonmegaform.ability == :MAGICGUARD
            fieldscore += 25 if i.ability == :SKILLLINK
            fieldscore += 30 if i.ability == :NOGUARD || nonmegaform.ability == :NOGUARD
            fieldscore += 50 if i.ability == :DAUNTLESSSHIELD
            fieldscore += 50 if i.ability == :INTREPIDSWORD
          when *PBFields::CONCERT
            fieldscore += 25 if i.ability == :TECHNICIAN
            fieldscore += 25 if [:HEAVYMETAL, :SOLIDROCK, :PUNKROCK, :ROCKHEAD, :SOUNDPROOF].include?(i.ability)
            fieldscore += 15 if [:HEAVYMETAL, :SOLIDROCK, :PUNKROCK, :GALVANIZE, :PLUS].include?(i.ability) && @battle.ProgressiveFieldCheck(PBFields::CONCERT, 1, 3)
            fieldscore -= 15 if [:KLUTZ, :MINUS].include?(i.ability) && @battle.ProgressiveFieldCheck(PBFields::CONCERT, 2, 4)
            fieldscore += 25 if [:RUNAWAY, :EMERGENCYEXIT].include?(i.ability) && @battle.ProgressiveFieldCheck(PBFields::CONCERT, 2, 4)
            fieldscore += 30 if i.ability == :RATTLED && @battle.ProgressiveFieldCheck(PBFields::CONCERT, 3, 4)
          when :BACKALLEY
            fieldscore += 25 if i.hasType?(:DARK)
            fieldscore += 20 if i.hasType?(:POISON)
            fieldscore += 20 if i.hasType?(:BUG)
            fieldscore += 20 if i.hasType?(:STEEL)
            fieldscore -= 25 if i.hasType?(:FAIRY)
            fieldscore += 20 if i.ability == :STENCH
            fieldscore += 25 if i.ability == :DOWNLOAD
            fieldscore += 25 if i.ability == :PICKPOCKET || nonmegaform.ability == :PICKPOCKET
            fieldscore += 25 if i.ability == :MERCILESS || nonmegaform.ability == :MERCILESS
            fieldscore += 25 if i.ability == :MAGICIAN || nonmegaform.ability == :MAGICIAN
            fieldscore += 25 if i.ability == :ANTICIPATION || nonmegaform.ability == :ANTICIPATION
            fieldscore += 25 if i.ability == :FOREWARN || nonmegaform.ability == :FOREWARN
            fieldscore += 25 if i.ability == :RATTLED || nonmegaform.ability == :RATTLED
            fieldscore += 20 if i.ability == :DEFIANT
          when :CITY
            fieldscore += 25 if i.hasType?(:NORMAL)
            fieldscore += 20 if i.hasType?(:POISON)
            fieldscore += 20 if i.hasType?(:BUG)
            fieldscore += 20 if i.hasType?(:STEEL)
            fieldscore -= 20 if i.hasType?(:FAIRY)
            fieldscore += 20 if i.ability == :STENCH
            fieldscore += 25 if i.ability == :DOWNLOAD
            fieldscore += 25 if i.ability == :BIGPECKS || nonmegaform.ability == :BIGPECKS
            fieldscore += 25 if i.ability == :PICKUP || nonmegaform.ability == :PICKUP
            fieldscore += 25 if i.ability == :EARLYBIRD || nonmegaform.ability == :EARLYBIRD
            fieldscore += 25 if i.ability == :RATTLED || nonmegaform.ability == :RATTLED
            fieldscore += 20 if i.ability == :HUSTLE
            fieldscore += 20 if i.ability == :FRISK || nonmegaform.ability == :FRISK
            fieldscore += 20 if i.ability == :COMPETITIVE
          when :CLOUDS
            fieldscore += 25 if i.hasType?(:FLYING)
            fieldscore += 20 if i.ability == :CLOUDNINE
            fieldscore += 20 if i.ability == :FLUFFY
            fieldscore += 20 if i.ability == :BIGPECKS
            fieldscore += 20 if i.ability == :EARLYBIRD
            fieldscore += 20 if i.ability == :WINDPOWER
            fieldscore += 20 if i.ability == :VOLTABSORB && @battle.weather == :RAINDANCE
            fieldscore += 20 if i.ability == :LIGHTNINGROD && @battle.weather == :RAINDANCE
            fieldscore += 20 if i.ability == :MOTORDRIVE && @battle.weather == :RAINDANCE
            fieldscore += 20 if i.ability == :SNOWCLOAK && @battle.weather == :HAIL
            fieldscore += 20 if i.ability == :ICEBODY && @battle.weather == :HAIL
            fieldscore += 20 if i.ability == :FORECAST
            fieldscore += 20 if i.ability == :OVERCOAT
          when :DARKNESS1
            fieldscore += 10 if i.hasType?(:DARK)
            fieldscore += 10 if i.ability == :DARKAURA
            fieldscore -= 10 if i.ability == :FAIRYAURA
            fieldscore += 20 if i.ability == :RATTLED
          when :DARKNESS2
            fieldscore += 20 if i.hasType?(:DARK)
            fieldscore += 20 if i.ability == :DARKAURA
            fieldscore -= 20 if i.ability == :FAIRYAURA
            fieldscore += 20 if i.ability == :RATTLED
            fieldscore -= 20 if i.ability == :INSOMNIA
            fieldscore += 20 if i.ability == :BADDREAMS
            fieldscore += 20 if i.ability == :SHADOWSHIELD
            fieldscore += 20 if i.ability == :PICKPOCKET
          when :DARKNESS3
            fieldscore += 40 if i.hasType?(:DARK)
            fieldscore += 40 if i.ability == :DARKAURA
            fieldscore -= 40 if i.ability == :FAIRYAURA
            fieldscore += 40 if i.ability == :RATTLED
            fieldscore -= 40 if i.ability == :INSOMNIA
            fieldscore += 40 if i.ability == :BADDREAMS
            fieldscore += 40 if i.ability == :SHADOWSHIELD
            fieldscore += 40 if i.ability == :PICKPOCKET
          when :DANCEFLOOR
            fieldscore += 20 if i.ability == :INSOMNIA
            fieldscore += 20 if i.ability == :MAGICGUARD
            fieldscore += 10 if i.ability == :MAGICIAN
            fieldscore += 40 if i.ability == :DANCER
            fieldscore += 20 if i.ability == :ILLUMINATE
          when :CROWD
            fieldscore += 20 if i.ability == :GUTS
            fieldscore += 10 if i.ability == :INNERFOCUS
            fieldscore += 30 if i.ability == :INTIMIDATE
            fieldscore += 20 if i.ability == :IRONFIST
        end
      end
      monscore += fieldscore
      PBDebug.dblog(sprintf("Fields: %d", fieldscore))

      # Other
      otherscore = 0
      otherscore -= 70 if !safe_switch && @attacker.species == i.species
      otherscore -= 400 if bothOpponentsImmune?(i)
      otherscore -= kingPriorityBlockedScore(i) if @battle.FE == :CHESS && i.piece == :KING
      otherscore += 40 if i.powderImmune? && checkAImovesAllOpponents([:RAGEPOWDER])

      # lot of custom ai for one stupid fight
      if !@battle.opponent.is_a?(Array)
        if Rejuv && !@battle.opponent.nil? && @battle.opponent.name == "Squad 03"
          initboosts = getStatBoostsOnEntry(@battle.pbGetOwner(i.index), i, delay = false)
          if @index == 3
            otherscore -= 500 if initboosts == {PBStats::ATTACK => 1,PBStats::DEFENSE => 1,PBStats::SPEED => 1, PBStats::SPATK => 1, PBStats::SPDEF => 1}
          end
          if batonpass
            if initboosts != {PBStats::ATTACK => 0,PBStats::DEFENSE => 0,PBStats::SPEED => 0, PBStats::SPATK => 0, PBStats::SPDEF => 0} && @attacker.crested == :FURRET && @attacker.effects[:Substitute] > 0
              initboosts.each do |stat, boost|
                next if boost == nil
                otherscore += 30 if boost > 0
              end
            end
          end
        end
      end
      # Good switch for future attack
      if @attacker.effects[:FutureSight] >= 1
        move, moveuser, disabled_items = @attacker.pbFutureSightUserPlusMove
        damage = !safe_switch ? pbRoughDamage(move, moveuser, nonmegaform) : pbRoughDamage(move, moveuser, i)
        if !disabled_items.empty?
          moveuser.item = disabled_items[:item]
          moveuser.ability = disabled_items[:ability]
        end
        otherscore += 50 if damage == 0
        otherscore += 50 if damage < i.hp
        otherscore += 50 if 2 * damage < i.hp
        otherscore -= 100 if damage > i.hp
      end
      # Good switch for two-turn attack
      if !safe_switch
        for oppmon in bothOpponents
          if oppmon.effects[:TwoTurnAttack] != 0 && !pbAIfaster?(nil, nil, @attacker, oppmon)
            bestmove = checkAIbestMove(oppmon)
            twoturnmove = moveToMoveObject(oppmon.effects[:TwoTurnAttack], oppmon)
            if pbTypeModNoMessages(twoturnmove.pbType(oppmon), oppmon, nonmegaform, twoturnmove).resistedOrImmune? && pbAIfaster?(nil, nil, i, oppmon)
              otherscore += 60
              otherscore += 60 if pbTypeModNoMessages(bestmove.pbType(oppmon), oppmon, i, bestmove).resistedOrImmune?
            end
          end
        end
      end
      # Good switch against substitute
      bothOpponents.each { |oppmon|
        next unless oppmon.effects[:Substitute] > 0
        maxdam = roughdamagearray[oppmon == @opponent ? 0 : 1].max * oppmon.totalhp / 100.0
        next if maxdam < oppmon.effects[:Substitute]
        otherscore += 25
        otherscore += 25 if getAIMemory(oppmon).include?(:SUBSTITUTE) && maxdam >= (oppmon.totalhp / 4.0).floor
      }
      monscore += otherscore
      PBDebug.dblog(sprintf("Other Score: %d", otherscore))

      # if takes hazard damage, discourage switching proportional to how low current HP is
      if i.hp < hpBeforeHazards
        monscore *= hpBeforeHazards / i.totalhp.to_f
      end
      # more likely to send out ace the fewer party members are alive
      partyacedrop = 0.9 - 0.1 * party.count { |mon| mon && mon.hp > 0 }
      # ace score drop not applied for aiplay player, partner NPCs and battle tower trainers since they don't usually have teams built around an ace mon and also it serves no cinematic purpose in their case
      considerAceMon = @battle.pbIsOpposing?(@attacker.index) && !$PokemonGlobal.challenge&.pbInProgress?
      yvelscoring = false
      # keep yveltal towards the end for this fight
      if !@battle.opponent.is_a?(Array)
        if Rejuv && !@battle.opponent.nil? && @battle.opponent.trainertype == :KINGANDQUEEN
          yvelscoring = true
        end
      end
      monscore *= partyacedrop if (considerAceMon && theseRoles.include?(:ACE)) || ((i.ability == :SUPREMEOVERLORD || i.crested == :SPIRITOMB || i.species == :YVELTAL && i.form == 1 && yvelscoring) && @mondata.skill >= BESTSKILL)
      # Final score
      monscore = monscore.floor
      PBDebug.dblog(sprintf("Final Pokemon Score: %d", monscore))
      partyScores.push(monscore)
      @battle.field.effect = initial_field
      @battle.weather = initial_weather
    end

    # If the whole party would just die, check specific things
    if survivors.none? { |lives| lives }
      partyScoresBefore = partyScores.clone
      PBDebug.dblog("\nSpecial scores because all AI mons get OHKO'd:")
      opp = @attacker.pbFirstOpposing
      opp2 = opp.pbPartner
      opponent = pbCloneBattler(opp.index, illusionDeceived?(opp, @battle.battlers[opp.index]))
      opponent2 = opp2.isFainted? ? nil : pbCloneBattler(opp2.index, illusionDeceived?(opp2, @battle.battlers[opp2.index]))
      bothOpponents = [opponent, opponent2].select { |opp| !opp.nil? && !opp.isFainted? }

      # Innards Out
      for mon in partycheck.find_all { |mon| mon.ability == :INNARDSOUT }
        for opp in bothOpponents
          if mon.hp >= opp.hp && !@battle.magicGuardAbilities.include?(opp.ability)
            partyScores[mon.pokemonIndex] += 500
            PBDebug.dblog("Innards Out KO's opponent: +500 #{mon.logname}")
          end
        end
      end

      for opp in bothOpponents
        next if !@battle.magicGuardAbilities.include?(opp.ability) || opp.item == :PROTECTIVEPADS || opp.ability == :LONGREACH

        # Aftermath
        aftermathdmg = @battle.FE == :CORROSIVEMIST ? 0.5 : 0.25
        for mon in partycheck.find_all { |mon| mon.ability == :AFTERMATH }
          if aftermathdmg >= opp.hp.to_f / opp.totalhp && opp.makesContact?(checkAIbestMove(opp, mon))
            partyScores[mon.pokemonIndex] += 200
            PBDebug.dblog("Aftermath KO's opponent: +200 #{mon.logname}")
          end
        end
        for mon in partycheck.find_all { |mon| mon.crested == :BASTIODON }
          bastdamage = checkAIdamage(mon, opponent)
          if bastdamage / 2.0 >= opp.hp.to_f
            partyScores[mon.pokemonIndex] += 400
            PBDebug.dblog("Bastiodon Crest KO's opponent: +400 #{mon.logname}")
          end
        end
        # Rocky Helmet
        helmetdmg = 1.0 / 6
        for mon in partycheck.find_all { |mon| mon.item == :ROCKYHELMET }
          if helmetdmg >= opp.hp.to_f / opp.totalhp && opp.makesContact?(checkAIbestMove(opp, mon))
            partyScores[mon.pokemonIndex] += 200
            PBDebug.dblog("Rocky Helmet KO's opponent: +200 #{mon.logname}")
          end
        end
        # Iron Barbs / Rough Skin
        contactdmg = 0.125
        for mon in partycheck.find_all { |mon| [:IRONBARBS, :ROUGHSKIN].include?(mon.ability) }
          if contactdmg >= opp.hp.to_f / opp.totalhp && opp.makesContact?(checkAIbestMove(opp, mon))
            partyScores[mon.pokemonIndex] += 200
            PBDebug.dblog("Iron Barbs/Rough Skin KO's opponent: +200 #{mon.logname}")
          end
        end
      end

      # Speed Boost + Protect
      for opp in bothOpponents
        next if @battle.state.effects[:TrickRoom] != 0
        next if opp.ability == :SPEEDBOOST
        next if Gen < Champs && [:UNSEENFIST, :PIERCINGDRILL].include?(opp.ability)

        for mon in partycheck.find_all { |mon| mon.ability == :SPEEDBOOST && (mon.pbHasMove?(*PBStuff::PROTECTMOVE) || (seedProtection?(mon) && @attacker.hp == 0)) } # seed protection doesn't help if it's a hard switch/pivot
          # does the protect effect even work against the opponent?
          if seedProtection?(mon) && @attacker.hp == 0
            protectEffect = mon.effects[:Protect]
          else
            protectMove = mon.moves.find { |move| PBStuff::PROTECTMOVE.include?(move.move) }
            protectEffect = PBStuff::PROTECTEFFECTS[protectMove.move]
          end
          next if getAIMemory(opp, change: true).any? { |move| !protectEffectWorks?(protectEffect, move, opp) && pbRoughDamage(move, opp, mon) > mon.hp }
          # does speed boost make the mon outspeed the opponent when it couldn't otherwise?
          next unless mon.speed < pbRoughStat(opp, PBStats::SPEED) && mon.speed * 1.5 > pbRoughStat(opp, PBStats::SPEED)
          # can the mon KO the opponent?
          next unless mon.moves.any? { |move| pbRoughDamage(move, mon, opp) > opp.hp }

          partyScores[mon.pokemonIndex] += 200
          PBDebug.dblog("Speed Boost + Protect then KO: +200 #{mon.logname}")
        end
      end

      # Seed Protection
      for opp in bothOpponents
        for mon in partycheck.find_all { |mon| seedProtection?(mon) && @attacker.hp == 0 } # seed protection doesn't help if it's a hard switch/pivot
          # does the protect effect even work against the opponent?
          next if getAIMemory(opp, change: true).any? { |move| !protectEffectWorks?(mon.effects[:Protect], move, opp) && pbRoughDamage(move, opp, mon) > mon.hp }
          # can the mon KO the opponent?
          next unless mon.moves.any? { |move| pbRoughDamage(move, mon, opp) > opp.hp }

          partyScores[mon.pokemonIndex] += 200
          PBDebug.dblog("Seed Protection + KO: +200 #{mon.logname}")
        end
      end

      # Intimidate / Thievul Crest
      for mon in partycheck.find_all { |mon| mon.ability == :INTIMIDATE || mon.crested == :THIEVUL }
        oppbackup = opponent.stages.clone
        opp2backup = opponent2.stages.clone if opponent2
        bothOpponents.each { |opp| pbStatChangingSwitchOpponent(mon, opp) }
        for mon2 in partycheck
          incomingdamage = checkAIdamage(mon2, opponent)
          incomingdamage2 = opponent2 ? checkAIdamage(mon2, opponent2) : 0
          incomingpercentage = (incomingdamage + incomingdamage2) / mon2.hp.to_f
          if incomingpercentage < 1.0
            partyScores[mon.pokemonIndex] += 200
            PBDebug.dblog("Intimidate prevents OHKO: +200 #{mon.logname}")
          end
        end
        opponent.stages = oppbackup
        opponent2.stages = opp2backup if opponent2
      end

      # Spicy Spray
      for mon in partycheck.find_all { |mon| mon.ability == :SPICYSPRAY }
        for opp in bothOpponents
          if opp.pbCanBurn?(mon, nil) && (!@battle.magicGuardAbilities.include?(opp.ability) || opp.attack > opp.spatk)
            partyScores[mon.pokemonIndex] += 200
            PBDebug.dblog("Spicy Spray can burn opponent: +200 #{mon.logname}")
          end
        end
      end

      # Prankster
      for opp in bothOpponents
        next if (opp.hasType?(:DARK) && @battle.FE != :BEWITCHED && !(Rejuv && @battle.FE == :GLITCH)) || (@battle.FE == :PSYTERRAIN && !opp.isAirborne?) || aiCheckSideAbility(@battle.priorityBlockingAbilities, opp, @attacker, opp).any?

        for mon in partycheck.find_all { |mon| mon.ability == :PRANKSTER }
          check = false
          check = true if mon.moves.any? { |moveloop| moveloop != nil && moveloop.pbIsStatus? && PBStuff::SLEEPMOVE.include?(moveloop) && opp.pbCanSleep?(mon, moveloop) }
          check = true if mon.moves.any? { |moveloop| moveloop != nil && moveloop.pbIsStatus? && PBStuff::PARAMOVE.include?(moveloop) && opp.pbCanParalyze?(mon, moveloop) } && pbRoughStat(opp, PBStats::SPEED) / 2.0 < @attacker.pbSpeed && @battle.state.effects[:TrickRoom] == 0 && opp.ability != :QUICKFEET
          check = true if mon.moves.any? { |moveloop| moveloop != nil && moveloop.pbIsStatus? && PBStuff::BURNMOVE.include?(moveloop) && opp.pbCanBurn?(mon, moveloop) } && opp.attack > opp.spatk && opp.ability != :GUTS
          check = true if mon.pbHasMove?(:DISABLE) && opp.lastMoveUsed == checkAIbestMove(mon, opp).move
          check = true if mon.pbHasMove?(:ENCORE) && opp.lastMoveUsed.is_a?(Symbol) && moveToMoveObject(opp.lastMoveUsed, opp).pbIsStatus?
          check = true if mon.pbHasMove?(:HAZE) && PBStats::All.any? { |stat| opp.stages[stat] > 0 }
          if check
            partyScores[mon.pokemonIndex] += 300
            PBDebug.dblog("Prankster + Useful Move: +300 #{mon.logname}")
          end
        end
      end

      # damaging priority moves: do we have the needed priority moves to take the opponent out over time?
      priosum = [0, []]
      for mon in partycheck
        pbStatChangingSwitchOpponent(mon, opponent)
        priodam = 0
        for move in mon.moves
          next if !move.pbIsPriorityMoveAI(mon)
          next if !moveSuccessful?(move, mon, opponent)
          selfPrio = move.priorityCheck(mon)
          oppPrio = checkAIbestMove(opponent, mon).priorityCheck(opponent)
          next if selfPrio < oppPrio
          next if selfPrio == oppPrio && !pbAIfaster?(nil, nil, mon, opponent)

          tempdamage = pbRoughDamage(move, mon, opponent)
          priodam = tempdamage if tempdamage >= priodam
        end
        priosum[0] += priodam if priodam > 0
        priosum[1].push(mon.pokemonIndex) if priodam > 0
      end
      if priosum[0] > opponent.hp
        for i in priosum[1]
          partyScores[i] += 200
          PBDebug.dblog("Priority damage KO's over time: +200 #{party[i].logname}")
        end
      end
      # and see if it does anything useful, even tho not kills
      # then modify scores based on that
      PBDebug.dblog("None") if partyScoresBefore == partyScores
    end
    $INTERNAL = internalbackup
    $ai_log_data[@attacker.index].switch_scores.push(*partyScores) unless revival
    return partyScores
  end

  # should the current @attacker switch out?
  def shouldSwitch?
    return -1000 if !@battle.opponent && @battle.pbIsOpposing?(@attacker.index)
    return -1000 if @attacker.issosmon

    nonActiveCount = @attacker.pbNonActivePokemonCount
    return -1000 if nonActiveCount == 0
    return -1000 if nonActiveCount == 1 && mustSendOutAceLast?()

    return -1000 if @attacker.isbossmon && @attacker.chargeAttack
    return -1000 if (0...@mondata.party.length).none? { |i| @battle.pbCanSwitch?(@attacker.index, i) }

    partyAfterHazards = []
    for mon in @mondata.party
      next if mon.nil? || mon.isEgg? || @mondata.party.index(mon) == @attacker.pokemonIndex
      i = pbMakeFakeBattler(mon, @mondata.party.index(mon))
      next if i.hp <= totalHazardDamage(i)
      partyAfterHazards.push(mon)
    end

    # get trainereffects
    trainereffects = getTrainerEffects(@battle.pbGetOwner(@attacker.index), @attacker.pokemonIndex, delay = false)

    aimem = getAIMemory(@opponent)
    aimem2 = getAIMemory(@opponent.pbPartner)

    specialmove = false
    physmove = false
    for i in @attacker.moves.compact
      specialmove = true if i.pbIsSpecial?(@attacker)
      physmove = true if i.pbIsPhysical?(@attacker)
    end

    attackerUseSpDef = @battle.field == :GLITCH && @attacker.changeSpecialStat(attacker: true)
    spAtkStat = attackerUseSpDef ? PBStats::SPDEF : PBStats::SPATK
    defenderUseSpAtk = @battle.field == :GLITCH && @attacker.changeSpecialStat(attacker: false)
    spDefStat = defenderUseSpAtk ? PBStats::SPATK : PBStats::SPDEF

    # SWITCH SCORE
    # Statuses
    statusscore = 0
    statusscore += 80 if @attacker.effects[:Curse]
    statusscore += saltCureGood? ? 80 : 50 if @attacker.effects[:SaltCure]
    statusscore += 60 if @attacker.effects[:LeechSeed] >= 0
    statusscore += 60 if @attacker.effects[:Attract] >= 0
    statusscore += 80 if @attacker.effects[:Confusion] > 0
    if @attacker.effects[:PerishSong] == 2
      statusscore += 40
      statusscore += 160 if aiCheckGlobalCrest(:CELEBI, @attacker) && !(@battle.FE == :DEUXFINALIS && @attacker.permeffs[:ItemRecycle] == :MAGICALSEED && (@attacker.hp >= (@attacker.totalhp * 0.9).floor))
    elsif @attacker.effects[:PerishSong] == 1
      # accounting for Deux Finalis Seed's perish song
      if @battle.FE == :DEUXFINALIS
        if !@attacker.permeffs[:ItemRecycle]
          statusscore += 200
        else
          statusscore += 200 if @attacker.permeffs[:ItemRecycle] == :MAGICALSEED && (@attacker.hp >= (@attacker.totalhp * 0.9).floor)
        end
      else
        statusscore += 200
      end
    end
    statusscore += (@attacker.effects[:Toxic] * 15) if @attacker.effects[:Toxic] > 0
    statusscore += 50 if @attacker.ability == :NATURALCURE && !@attacker.status.nil?
    statusscore += 60 if @mondata.partyroles.any? { |roles| roles.include?(:CLERIC) } && !@attacker.status.nil?
    if @attacker.status == :SLEEP && @attacker.crested != :SUICUNE
      statusscore += 170 if checkAImoves([:DREAMEATER, :NIGHTMARE], aimem)
    end
    statusscore += 95 if @attacker.effects[:Yawn] > 0 && @attacker.status != :SLEEP
    PBDebug.dblog(sprintf("Initial switchscore building: Statuses (%d)", statusscore))
    # Stat changes
    statscore = 0
    if @mondata.roles.include?(:SWEEPER)
      statscore += (-30) * @attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK] < 0 && physmove
      statscore += (-30) * @attacker.stages[spAtkStat] if @attacker.stages[spAtkStat] < 0 && specialmove
      statscore += (-30) * @attacker.stages[PBStats::SPEED] if @attacker.stages[PBStats::SPEED] < 0
      statscore += (-30) * @attacker.stages[PBStats::ACCURACY] if @attacker.stages[PBStats::ACCURACY] < 0
    else
      statscore += (-15) * @attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK] < 0 && physmove
      statscore += (-15) * @attacker.stages[spAtkStat] if @attacker.stages[spAtkStat] < 0 && specialmove
      statscore += (-15) * @attacker.stages[PBStats::SPEED] if @attacker.stages[PBStats::SPEED] < 0
      statscore += (-15) * @attacker.stages[PBStats::ACCURACY] if @attacker.stages[PBStats::ACCURACY] < 0
    end
    if @mondata.roles.include?(:PHYSICALWALL)
      statscore += (-30) * @attacker.stages[PBStats::DEFENSE] if @attacker.stages[PBStats::DEFENSE] < 0
    else
      statscore += (-15) * @attacker.stages[PBStats::DEFENSE] if @attacker.stages[PBStats::DEFENSE] < 0
    end
    if @mondata.roles.include?(:SPECIALWALL)
      statscore += (-30) * @attacker.stages[spDefStat] if @attacker.stages[spDefStat] < 0
    else
      statscore += (-15) * @attacker.stages[spDefStat] if @attacker.stages[spDefStat] < 0
    end
    PBDebug.dblog(sprintf("Initial switchscore building: Stat Stages (%d)", statscore))
    # Healing potential
    healscore = 0
    healscore += 30 if @attacker.hp.to_f / @attacker.totalhp < 0.67 && @attacker.ability == :REGENERATOR
    if @attacker.effects[:Wish] > 0
      healscore += 40 if partyAfterHazards.any? { |i| i.hp > 0.3 * i.totalhp && i.hp < 0.6 * i.totalhp }
    end
    PBDebug.dblog(sprintf("Initial switchscore building: Healing (%d)", healscore))
    # Force-out conditions
    forcedscore = 0
    forcedscore += 300 if bothOpponentsImmune?(@attacker)
    forcedscore += kingPriorityBlockedScore(@attacker) if @battle.FE == :CHESS && @attacker.piece == :KING

    canchoose = (0..3).any? { |i| @battle.pbCanChooseMove?(@attacker.index, i) }
    forcedscore += 200 if !canchoose

    forcedscore += 30 if @attacker.effects[:Torment]
    if @attacker.effects[:Encore] > 0
      if @opponent.hp > 0
        encoreScore = @mondata.scorearray[@opponent.index][@attacker.effects[:EncoreIndex]]
      elsif @opponent.pbPartner.hp > 0
        encoreScore = @mondata.scorearray[@opponent.pbPartner.index][@attacker.effects[:EncoreIndex]]
      else
        encoreScore = 100
      end
      forcedscore += 200 if encoreScore <= 30
      forcedscore += 110 if @attacker.effects[:Torment]
    end
    choiced = ([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(@attacker.item) && @attacker.itemWorks? && @attacker.effects[:ChoiceBand]) || (@attacker.ability == :GORILLATACTICS && @attacker.effects[:GorillaLock])
    if choiced
      choicemovesym = @attacker.effects[:ChoiceBand] || @attacker.effects[:GorillaLock]
      choicemove = @attacker.moves.find { |move| move.move == choicemovesym }
      if choicemove
        opp = @opponent.hp > 0 ? @opponent : @opponent.pbPartner # one has to be alive
        unless moveInvulMisses?(choicemove, @attacker, opp) && pbAIfaster?(choicemove, nil, @attacker, opp) # don't apply if move is going to miss due to semi-invulnerability
          choiceindex = @attacker.moves.index(choicemove)
          choiceScore = @mondata.scorearray[opp.index][choiceindex]
          forcedscore += 50 if choiceScore <= 50
          forcedscore += 130 if choiceScore <= 30
          forcedscore += 150 if choiceScore <= 10
        end
      end
    end
    PBDebug.dblog(sprintf("Initial switchscore building: Forced Switch from a Bad Matchup (%d)", forcedscore))
    # Type effectiveness
    typescore = 0
    for type in @opponent.types
      effcheck = PBTypes.typesEff(type, @attacker.types, inverse: @battle.inverse?)
      if effcheck.superEffective?
        typescore += 20
      elsif effcheck.resistedOrImmune?
        typescore -= 20
      end
    end
    if @opponent.pbPartner.totalhp != 0
      typescore *= 0.5
      for type in @opponent.pbPartner.types
        effcheck = PBTypes.typesEff(type, @attacker.types, inverse: @battle.inverse?)
        if effcheck.superEffective?
          typescore += 10
        elsif effcheck.resistedOrImmune?
          typescore -= 10
        end
      end
    end
    PBDebug.dblog(sprintf("Initial switchscore building: Typing (%d)", typescore))
    # Special cases
    specialscore = 0
    lastwordeff = false
    if trainereffects
      if trainereffects[:LastWord]
        lastwordeff = true
      end
    end
    # If the opponent just switched in to counter you (not for doubles)
    if !@battle.doublebattle && @opponent.turncount == 0 && checkAIdamage() > @attacker.hp &&
       @attacker.hp > 0.6 * @attacker.totalhp && !notOHKO?(@opponent, @attacker, true)
      specialscore += lastwordeff ? 50 : 100
    end
    # specific abilities that got changed
    abillist = [:HUGEPOWER, :FLOWERGIFT, :PUREPOWER, :WONDERGUARD]

    if (abillist.include?(@attacker.pokemon.ability) || @attacker.ability == :TRUANT) && (@attacker.ability != @attacker.pokemon.ability) && @attacker.ability != :suppress
      specialscore += @attacker.ability == :TRUANT ? 300 : 200
      specialscore += 100 if (@attacker.crested == :CHERRIM && @attacker.pokemon.ability == :FLOWERGIFT) || @attacker.ability == :TRUANT
    end

    # If ability got changed or suppressed by non-Neutralizing Gas means
    if @attacker.ability != @attacker.pokemon.ability &&
       (!@attacker.abilitySuppressed? || @attacker.effects[:GastroAcid]) &&
       !@attacker.effects[:Transform]
      attmonClone = pbCloneBattler(@attacker.index)
      attmonClone.ability = @attacker.pokemon.ability
      changedabilscore = getAbilityDisruptScore(@opponent, @attacker) - getAbilityDisruptScore(@opponent, attmonClone)
      case true
        when changedabilscore <= -1 then specialscore += 150
        when changedabilscore <= -0.5 then specialscore += 100
        when changedabilscore < 0 then specialscore += 50
      end
      specialscore += 100 if (@attacker.ability == :TRUANT && (@attacker.effects[:Truant] || checkAImovesAllOpponents([PBStuff::PROTECTMOVE]))) || @attacker.ability == :SLOWSTART
    end

    # If future sight is about to trigger
    if @attacker.effects[:FutureSight] == 1
      move, moveuser, disabled_items = @attacker.pbFutureSightUserPlusMove
      damage = pbRoughDamage(move, moveuser, @attacker)
      if !disabled_items.empty?
        moveuser.item = disabled_items[:item]
        moveuser.ability = disabled_items[:ability]
      end
      specialscore += 50 if damage > @attacker.hp
      specialscore += 50 if 2 * damage > @attacker.hp
    end
    # If attacker has unburden activated
    specialscore -= 30 if @attacker.unburdened
    # If Glaive Rush effect is active
    if @attacker.effects[:GlaiveRush]
      specialscore += 100 if !pbAIfaster?() || (@opponent.pbPartner.hp > 0 && !pbAIfaster?(nil, nil, @attacker, @opponent.pbPartner))
    end
    # Palafin in Zero Form
    specialscore += 100 if @attacker.ability == :ZEROTOHERO && @attacker.form == 0

    # Special cases that should consider both opponents
    for oppmon in [@opponent, @opponent.pbPartner].select { |oppmon| oppmon.hp > 0 }
      bestmove = checkAIbestMove(oppmon)
      # Good switch for two-turn attack
      if !pbAIfaster?(nil, nil, @attacker, oppmon) && oppmon.effects[:TwoTurnAttack] != 0
        twoturnmove = moveToMoveObject(oppmon.effects[:TwoTurnAttack], oppmon)
        for i in partyAfterHazards
          switchin = pbMakeFakeBattler(i, @mondata.party.index(i))
          if pbTypeModNoMessages(twoturnmove.pbType(oppmon), oppmon, switchin, twoturnmove).resistedOrImmune? && pbAIfaster?(nil, nil, switchin, oppmon)
            specialscore += 60
            specialscore += 60 if pbTypeModNoMessages(bestmove.pbType(oppmon), oppmon, switchin, bestmove).resistedOrImmune?
            break
          end
        end
      end
      # punishing skill-link/loaded dice multi-hit contact moves
      if oppmon.ability == :SKILLLINK || oppmon.hasWorkingItem(:LOADEDDICE)
        if getAIMemory(oppmon).any? { |moveloop| moveloop != nil && moveloop.function == 0xC0 && oppmon.makesContact?(moveloop) }
          specialscore += 70 if partyAfterHazards.any? { |i| i.item == :ROCKYHELMET || [:ROUGHSKIN, :IRONBARBS].include?(i.ability) }
        end
      end
      # Justified switch vs dark attack moves
      if bestmove.pbType(oppmon) == :DARK && @attacker.ability != :JUSTIFIED
        specialscore += 70 if partyAfterHazards.any? { |i| i.ability == :JUSTIFIED }
      end
      # Thermal Exchange switch vs. Fire-type attacks
      if bestmove.pbType(oppmon) == :FIRE && @attacker.ability != :THERMALEXCHANGE
        specialscore += 70 if partyAfterHazards.any? { |i| i.ability == :THERMALEXCHANGE }
      end
    end
    PBDebug.dblog(sprintf("Initial switchscore building: Specific Switches (%d)", specialscore))
    # Total
    switchscore = statusscore + statscore + healscore + forcedscore + typescore + specialscore
    PBDebug.dblog(sprintf("Initial switchscore: %d", switchscore))

    # NO SWITCH SCORE
    # Stat changes
    statantiscore = 0
    if @mondata.roles.include?(:SWEEPER)
      statantiscore += (30) * @attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK] > 0 && physmove
      statantiscore += (30) * @attacker.stages[spAtkStat] if @attacker.stages[spAtkStat] > 0 && specialmove
      statantiscore += (30) * @attacker.stages[PBStats::SPEED] if @attacker.stages[PBStats::SPEED] > 0 unless (@mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL) || @mondata.roles.include?(:TANK))
      statantiscore += (30) * @attacker.effects[:FocusEnergy]
    else
      statantiscore += (15) * @attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK] > 0 && physmove
      statantiscore += (15) * @attacker.stages[spAtkStat] if @attacker.stages[spAtkStat] > 0 && specialmove
      statantiscore += (15) * @attacker.stages[PBStats::SPEED] if @attacker.stages[PBStats::SPEED] > 0 unless (@mondata.roles.include?(:PHYSICALWALL) || @mondata.roles.include?(:SPECIALWALL) || @mondata.roles.include?(:TANK))
      statantiscore += (30) * @attacker.effects[:FocusEnergy]
    end
    if @mondata.roles.include?(:PHYSICALWALL)
      statantiscore += (30) * @attacker.stages[PBStats::DEFENSE] if @attacker.stages[PBStats::DEFENSE] > 0
    else
      statantiscore += (15) * @attacker.stages[PBStats::DEFENSE] if @attacker.stages[PBStats::DEFENSE] > 0
    end
    if @mondata.roles.include?(:SPECIALWALL)
      statantiscore += (30) * @attacker.stages[spDefStat] if @attacker.stages[spDefStat] > 0
    else
      statantiscore += (15) * @attacker.stages[spDefStat] if @attacker.stages[spDefStat] > 0
    end
    statantiscore += (20) * @attacker.stages[PBStats::EVASION] if @attacker.stages[PBStats::EVASION] > 0 && !(checkAIaccuracy(aimem) || checkAIaccuracy(aimem2))
    statantiscore += 100 if @attacker.effects[:Substitute] > 0
    PBDebug.dblog(sprintf("Initial noswitchscore building: Stat Stages (%d)", statantiscore))
    # Hazards
    hazardantiscore = 0
    hazardantiscore += 15 * @attacker.pbOwnSide.effects[:Spikes]
    hazardantiscore += 15 * @attacker.pbOwnSide.effects[:ToxicSpikes]
    hazardantiscore += 15 if @attacker.pbOwnSide.effects[:StealthRock]
    hazardantiscore += 15 if @attacker.pbOwnSide.effects[:StickyWeb]
    hazardantiscore += 15 if @attacker.pbOwnSide.effects[:StickyWeb] && @mondata.roles.include?(:SWEEPER)
    hazardantiscore += 15 if @battle.FE == :CORROSIVE
    airmon = @attacker.isAirborne?
    hazardantiscore += 100 if @attacker.hp < totalHazardDamage(@attacker)
    temppartyko = true
    for i in partyAfterHazards
      next if @mondata.partyroles[@mondata.party.find_index(i)].include?(:ACE) && hazardantiscore > 0
      temppartyko = false if i.hp > 0
    end
    hazardantiscore += 200 if temppartyko
    PBDebug.dblog(sprintf("Initial noswitchscore building: Entry Hazards (%d)", hazardantiscore))
    # Better Switching Options
    betterswitchscore = 0
    opparray = [@opponent, @opponent.pbPartner].select { |opp| opp.hp > 0 }
    if opparray.all? { |opp| pbAIfaster?(nil, nil, @attacker, opp) }
      for move in @attacker.moves
        next unless (PBStuff::PIVOTMOVE - [:TELEPORT] + [:BATONPASS]).include?(move.move)
        next if !@battle.pbCanChooseMove?(@attacker.index, @attacker.moves.index(move))
        next if opparray.all? { |opp| pbTypeModNoMessages(move.pbType(@attacker), @attacker, opp, move).immune? || !moveSuccessful?(move, @attacker, opp) }
        next if move.move == :PARTINGSHOT && opparray.all? { |opp| opp.effects[:MagicCoat] || (opp.ability == :MAGICBOUNCE && !moldBreakerCheck(@attacker, opp, move)) }
        next if move.move == :BATONPASS && (@attacker.effects[:Curse] || @attacker.effects[:PerishSong] != 0)
        betterswitchscore += 90
      end
    end
    betterswitchscore += 100 if @attacker.turncount == 0
    betterswitchscore += 60 if @attacker.ability == :WIMPOUT || @attacker.ability == :EMERGENCYEXIT
    PBDebug.dblog(sprintf("Initial noswitchscore building: Alternate Switching Options (%d)", betterswitchscore))
    # Second wind situations
    secondwindscore = 0
    # Can you kill them before they kill you?
    for oppmon in [@opponent, @opponent.pbPartner].select { |oppmon| oppmon.hp > 0 }
      if !checkAIpriority()
        if pbAIfaster?(nil, nil, @attacker, oppmon)
          secondwindscore += 130 if @mondata.roughdamagearray[oppmon.index].any? { |movescore| movescore > 100 }
        end
      else
        for i in 0...@attacker.moves.length
          next if @attacker.moves[i].nil?
          next if !@attacker.moves[i].pbIsPriorityMoveAI(@attacker)

          secondwindscore += 130 if @mondata.roughdamagearray[oppmon.index][i] > 100 && pbAIfaster?(nil, nil, @attacker, oppmon)
        end
      end
    end
    # Discourage immediate switching
    monturn = (50 - (@attacker.turncount * 25))
    monturn /= 1.5 if @mondata.roles.include?(:LEAD)
    secondwindscore += monturn if monturn > 0
    PBDebug.dblog(sprintf("Initial noswitchscore building: Second Wind Situations (%d)", secondwindscore))
    # Total
    noswitchscore = statantiscore + hazardantiscore + betterswitchscore + secondwindscore
    noswitchscore += 999 if Reborn && !@battle.doublebattle && @battle.opponent.name == "Priscilla"
    noswitchscore += 40 if Rejuv && @battle.doublebattle && @battle.FE == :DEUXFINALIS && @opponent.ability == :SWORDOFRUIN && !@battle.pbOwnedByPlayer?(@attacker.index) # don't hard switch in
    PBDebug.dblog(sprintf("Initial noswitchscore: %d", noswitchscore))

    finalscore = switchscore - noswitchscore
    finalscore /= 2.0 if @mondata.skill < HIGHSKILL
    finalscore -= 100 if @mondata.skill < MEDIUMSKILL
    finalscore = finalscore.round(1)
    return finalscore
  end

  def bothOpponentsImmune?(attacker) # attacker may be a mon considering switching out or a mon considering switching in
    bothOpponents = [@opponent, @opponent.pbPartner].select { |oppmon| oppmon.hp > 0 }
    return false if bothOpponents.empty? # both opponents can be fainted during switch scoring
    return false if attacker.species == :COSMOEM && Reborn # for postgame only

    bouncers = bothOpponents.select { |oppmon| oppmon.effects[:MagicCoat] || (oppmon.ability == :MAGICBOUNCE && !moldBreakerCheck(attacker, oppmon)) }

    attacker.moves.each_with_index { |move, moveindex|
      next if !@battle.pbCanChooseMove?(attacker, moveindex) # accounts for Taunt etc

      return false if [:DESTINYBOND, :HEALINGWISH, :LUNARDANCE, :BATONPASS].include?(move.move)
      return false if move.move == :MEMENTO && bothOpponents.any? { |oppmon| !bouncers.include?(oppmon) && oppmon.pbCanReduceAnyStat?(PBStats::Offensive, attacker, move) }
      if PBStuff::SCREENMOVE.include?(move.move) && attacker.pbOwnSide.atDefaultValue?(PBStuff::SCREENEFFECTS[move.move])
        return false unless attacker.moves.any? { |i| i != move && PBStuff::SCREENMOVE.include?(i.move) && !attacker.pbOwnSide.atDefaultValue?(PBStuff::SCREENEFFECTS[i.move]) }
      end
      if bouncers.empty? && PBStuff::HAZARDMOVENONDAM.include?(move.move) && attacker.pbOpposingSide.atDefaultValue?(PBStuff::HAZARDEFFECTS[move.move])
        return false unless attacker.moves.any? { |i| i != move && PBStuff::HAZARDMOVENONDAM.include?(i.move) && !attacker.pbOpposingSide.atDefaultValue?(PBStuff::HAZARDEFFECTS[i.move]) }
      end
    }

    typeChangingMoves = { :SOAK => :WATER, :MAGICPOWDER => :PSYCHIC, :DESERTSMARK => :GROUND }
    typeChangingMoves[:ELECTRIFY] = :ELECTRIC if Rejuv && @battle.FE == :ELECTERRAIN
    typeChangingMoves[:MAGICPOWDER] = [:PSYCHIC, :FAIRY] if @battle.FE == :FAIRYTALE

    opparray = []
    for oppmon in bothOpponents
      opparray.push(oppmon)
      attacker.moves.each_with_index { |i, moveindex|
        next unless typeChangingMoves.keys.include?(i.move)
        next if pbTypeModNoMessages(i.pbType(attacker), attacker, oppmon, i).immune? || !moveSuccessful?(i, attacker, oppmon)
        next if !@battle.pbCanChooseMove?(attacker, moveindex)

        types = typeChangingMoves[i.move]
        types = Array(types)
        next if oppmon.types(excludeReflector: true).sort == types.sort

        oppmonClone = pbCloneBattler(oppmon.index)
        oppmonClone.changeType(*types)
        opparray.push(oppmonClone)
      }
    end

    attacker.moves.each_with_index { |basemove, moveindex|
      next if !@battle.pbCanChooseMove?(attacker, moveindex)

      move = pbChangeMove(basemove, attacker) # change nature power into what it's going to become
      for oppmon in opparray
        return false if isUsefulStatusMove?(move, attacker, oppmon)
        return false if move.pbIsDamaging? && !pbTypeModNoMessages(move.pbType(attacker), attacker, oppmon, move).immune? && moveSuccessful?(basemove, attacker, oppmon)
      end
    }

    return true
  end

  def kingPriorityBlockedScore(attacker)
    score = 0
    score += 200 if checkAImovesAllOpponents([:QUICKGUARD]) && getAIMemory(attacker, change: true).none? { |move| !protectEffectWorks?(:QuickGuard, move, attacker) && (move.pbIsDamaging? || [@opponent, @opponent.pbPartner].any? { |opp| opp.hp > 0 && isUsefulStatusMove?(move, attacker, opp) }) }
    upperHander = checkAImovesAllOpponents([:UPPERHAND])
    score += 200 if upperHander && attacker.effects[:Substitute] == 0 && attacker.ability != :INNERFOCUS && !secondaryEffectNegated?(nil, upperHander, attacker) && attacker.moves.none? { |move| !upperHandWorks?(upperHander, attacker, move) }
    return score
  end

  def pbHPChangingSwitch(mon)
    # pending healing effects
    mon.hp = mon.totalhp if mon.effects[:HealingWish] || mon.effects[:LunarDance] || mon.effects[:ZHeal]

    # hazards
    mon.hp -= totalHazardDamage(mon)
    return if mon.hp <= 0

    return unless mon.itemWorks? # also checks if mon has an item at all

    # berry healing
    medicinedata = $cache.items[mon.item].medicine
    mon.hp += getItemHP(medicinedata.hp, mon.totalhp) if mon.item == :BERRYJUICE && mon.hp <= (mon.totalhp / 2.0).floor
    unless aiCheckSideAbility(PBStuff::UnnerveAbilities, @opponent, mon, @opponent).any?
      healing = -1
      health_threshold = (mon.totalhp / (mon.ability == :GLUTTONY ? 2.0 : 4.0)).floor
      case mon.item
        when :ORANBERRY, :SITRUSBERRY then healing = getItemHP(medicinedata.hp, mon.totalhp) if mon.hp <= (mon.totalhp / 2.0).floor
        when :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY then healing = getItemHP(medicinedata.hp, mon.totalhp) if mon.hp <= health_threshold
        # these come up only in niche situations and are relevant here only for cheek pouch
        when :LIECHIBERRY, :GANLONBERRY, :SALACBERRY, :PETAYABERRY, :APICOTBERRY, :STARFBERRY, :CUSTAPBERRY, :LANSATBERRY, :MICLEBERRY then healing = 0 if mon.hp <= health_threshold
        when :CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY then healing = 0 if mon.status == medicinedata.status
        when :LUMBERRY then healing = 0 if !mon.status.nil?
        when :LEPPABERRY then healing = 0 if mon.moves.any? { |move| move.move && move.pp == 0 && move.totalpp != 0 }
      end
      healing *= 2 if mon.ability == :RIPEN
      healing += (mon.totalhp / 3.0).floor if mon.ability == :CHEEKPOUCH && healing > -1
      mon.hp += healing if healing > 0
    end
    mon.hp = mon.totalhp if mon.hp > mon.totalhp
  end

  def pbStatChangingSwitchOpponent(mon, opponent)
    if mon.ability == :INTIMIDATE && opponent.hasWorkingItem(:ADRENALINEORB) && opponent.effects[:Substitute] == 0 && (opponent.pbCanReduceStatStage?(PBStats::ATTACK, opponent, nil) || (@battle.FE == :CROWD && opponent.pbCanReduceStatStage?(PBStats::DEFENSE, opponent, nil)))
      opponent.stages[PBStats::SPEED] += opponent.ability == :CONTRARY ? -1 : (opponent.ability == :SIMPLE ? 2 : 1)
    end
    opponent.stages[PBStats::ATTACK] += 1 if mon.ability == :INTIMIDATE && opponent.ability == :GUARDDOG && opponent.effects[:Substitute] == 0
    PBStats::All.each { |stat| opponent.stages[stat] = opponent.stages[stat].clamp(-6, 6) } # in case there's an early return

    if mon.ability == :INTIMIDATE
      stats = [PBStats::ATTACK] + (@battle.FE == :CROWD ? [PBStats::DEFENSE] : [])
    elsif mon.ability == :ILLUMINATE && @battle.FE == :MIRROR
      stats = [PBStats::ACCURACY]
    elsif mon.ability == :PRESSURE && [:DIMENSIONAL, :FROZENDIMENSION, :DEUXFINALIS].include?(@battle.FE)
      stats = PBStats::Defensive
    elsif PBStuff::UnnerveAbilities.include?(mon.ability) && [:DIMENSIONAL, :FROZENDIMENSION, :DEUXFINALIS].include?(@battle.FE)
      stats = [PBStats::SPEED]
    elsif mon.ability == :FRISK && @battle.FE == :CITY
      stats = [PBStats::SPDEF]
    elsif mon.ability == :SUPERSWEETSYRUP && !mon.permeffs[:SupersweetSyrup]
      stats = [PBStats::EVASION]
    elsif mon.crested == :THIEVUL
      stats = [PBStats::SPATK]
    else
      return
    end

    return unless opponent.pbCanReduceAnyStat?(stats, mon, :Intimidate)
    return if mon.ability == :INTIMIDATE && PBStuff::NoIntimidateAbilities.include?(opponent.ability)
    return if opponent.ability == :MIRRORARMOR # special condition for AI

    worked = false
    for stat in stats
      next unless opponent.pbCanReduceStatStage?(stat, mon, :Intimidate)

      worked = true
      case opponent.ability
        when :CONTRARY then opponent.stages[stat] += 1
        when :SIMPLE then opponent.stages[stat] -= 2
        else opponent.stages[stat] -= 1
      end
      case opponent.ability
        when :DEFIANT then opponent.stages[PBStats::ATTACK] += 2
        when :COMPETITIVE then opponent.stages[PBStats::SPATK] += 2
      end
    end

    if worked
      opponent.stages[PBStats::SPEED] += 1 if mon.ability == :INTIMIDATE && opponent.ability == :RATTLED && Gen > 7
      PBStats::All.each { |stat| opponent.stages[stat] = 0 if opponent.stages[stat] < 0 } if opponent.hasWorkingItem(:WHITEHERB)
    end

    PBStats::All.each { |stat| opponent.stages[stat] = opponent.stages[stat].clamp(-6, 6) }
  end

  def pbPartingShotStatChange(mon, opponent, move)

    stats = [PBStats::ATTACK] + [PBStats::SPATK]
    return opponent.stages unless opponent.pbCanReduceAnyStat?(stats, mon, move)
    return opponent.stages if opponent.ability == :MIRRORARMOR # special condition for AI

    worked = false
    for stat in stats
      next unless opponent.pbCanReduceStatStage?(stat, mon, move)

      worked = true
      case opponent.ability
        when :CONTRARY then opponent.stages[stat] += 1
        when :SIMPLE then opponent.stages[stat] -= 2
        else opponent.stages[stat] -= 1
      end
      case opponent.ability
        when :DEFIANT then opponent.stages[PBStats::ATTACK] += 2
        when :COMPETITIVE then opponent.stages[PBStats::SPATK] += 2
      end
    end

    if worked
      (1..7).each { |stat| opponent.stages[stat] = 0 if opponent.stages[stat] < 0 } if opponent.hasWorkingItem(:WHITEHERB)
    end

    (1..7).each { |stat| opponent.stages[stat] = opponent.stages[stat].clamp(-6, 6) }

    return opponent.stages
  end

  def quarkdriveCheck
    priority = setSpeedOrder
    if @field.effect == :ELECTERRAIN || @field.overlay == :ELECTERRAIN || @field.effect == :NEWWORLD
      for i in priority
        next if i.isFainted?
        next if i.ability != :QUARKDRIVE
        next if i.effects[:Quarkdrive][0] != 0
        next if i.effects[:Transform]

        boostStat = i.getHighestStatWithStages
        i.effects[:Quarkdrive] = [boostStat, false]
        cause = @field.effect == :NEWWORLD ? _INTL("ethereal energy") : _INTL("Electric Terrain")
        pbAbilityBoxAndDisplay(i, _INTL("The {1} activated {2}'s {3}, heightening its {4}!", cause, i.pbThis(true), getAbilityName(i.ability), getStatName(boostStat)))
      end
    else
      for i in priority
        next if i.isFainted?
        next if i.effects[:Quarkdrive][0] == 0
        next if i.effects[:Quarkdrive][1] == true

        i.effects[:Quarkdrive][0] = 0
        pbDisplay(_INTL("{1}'s {2} wore off!", i.pbThis, getAbilityName(i.ability)))
        if i.hasWorkingItem(:BOOSTERENERGY) && i.ability == :QUARKDRIVE && !i.effects[:Transform]
          pbCommonAnimation("UseItem", i, nil)
          boostStat = i.getHighestStatWithStages
          i.effects[:Quarkdrive] = [boostStat, true]
          pbAbilityBoxAndDisplay(i, _INTL("{1} used its {2} to activate {3}, heightening its {4}!", i.pbThis, getItemName(i.item), getAbilityName(i.ability), getStatName(boostStat)))
          i.pbDisposeItem
        end
      end
    end
  end

  def pbStatChangingSwitch(mon, onlyabilities: false)
    stages = Array.new(8, 0) # separate array because we have to apply Contrary and Simple to all the changed stats at the end
    unless onlyabilities
      # Sticky Web
      if mon.pbOwnSide.effects[:StickyWeb] && !mon.isAirborne? && ![:WHITESMOKE, :CLEARBODY, :FULLMETALBODY].include?(mon.ability) && ![:HEAVYDUTYBOOTS, :CLEARAMULET].include?(mon.item)
        drop = @battle.FE == :FOREST ? 2 : 1
        stages[PBStats::SPEED] -= drop unless mon.item == :WHITEHERB
        mon.unburdened = true if mon.ability == :UNBURDEN && mon.item == :WHITEHERB
      end
      # Chess Board pieces
      if @battle.FE == :CHESS
        case mon.piece
          when :ROOK, :QUEEN
            stages[PBStats::DEFENSE] += 1
            stages[PBStats::SPDEF] += 1
          when :BISHOP
            stages[PBStats::ATTACK] += 1
            stages[PBStats::SPATK] += 1
        end
      end
      # Healing Wish
      if [:FAIRYTALE, :STARLIGHT].include?(@battle.FE) && mon.effects[:HealingWish]
        stages[PBStats::ATTACK] += 1
        stages[PBStats::SPATK] += 1
      end
      # Lunar Dance
      if mon.effects[:LunarDance]
        if [:STARLIGHT, :NEWWORLD, :BIGTOP, :DANCEFLOOR].include?(@battle.FE)
          stages[PBStats::ATTACK] += 1
          stages[PBStats::SPATK] += 1
        end
        if [:NEWWORLD, :BIGTOP, :DANCEFLOOR].include?(@battle.FE)
          stages[PBStats::DEFENSE] += 1
          stages[PBStats::SPDEF] += 1
          stages[PBStats::SPEED] += 1
        end
      end
      # Iron Ball Deep Earth
      if mon.item == :IRONBALL && @battle.FE == :DEEPEARTH
        stages[PBStats::SPEED] -= 2
      end
      # Magnet Deep Earth
      if mon.item == :MAGNET && @battle.FE == :DEEPEARTH
        stages[PBStats::SPEED] -= 1
        stages[PBStats::SPATK] += 1
      end
      # Seed stat boosts + other effects (including seed protect)
      if mon.item == @battle.field.seeds[:seedtype]
        mon.unburdened = true if mon.ability == :UNBURDEN
        mon.effects[@battle.field.seeds[:effect]] = @battle.field.seeds[:duration] if @battle.field.seeds[:effect]
        @battle.field.seeds[:stats].each_pair { |stat, statval| stages[stat] += statval }
      end
      # Room Service
      if mon.item == :ROOMSERVICE && @battle.state.effects[:TrickRoom] != 0
        stages[PBStats::SPEED] -= 1
      end
      # Electric Terrain instant Cell Battery
      if Rejuv && @battle.FE == :ELECTERRAIN && mon.item == :CELLBATTERY
        mon.unburdened = true if mon.ability == :UNBURDEN
        stages[PBStats::ATTACK] += 1
      end

      # Quark Drive
      if mon.ability == :QUARKDRIVE
        if @battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN || @battle.FE == :NEWWORLD
          if !mon.effects[:Quarkdrive][0] != 0
            boostStat = mon.getHighestStatWithStages
            mon.effects[:Quarkdrive] = [boostStat, false]
          end
        else
          if !(mon.effects[:Quarkdrive][0] == 0) && !(mon.effects[:Quarkdrive][1] == true) && mon.item == :BOOSTERENERGY
            boostStat = mon.getHighestStatWithStages
            mon.effects[:Quarkdrive] = [boostStat, false]
          end
        end
      end

      # Protosynthesis
      if mon.ability == :PROTOSYNTHESIS
        if @battle.pbWeather(nil) == :SUNNYDAY || @battle.FE == :NEWWORLD || Rejuv && [:DESERT].include?(@battle.FE)
          if !mon.effects[:Protosynthesis][0] != 0
            boostStat = mon.getHighestStatWithStages
            mon.effects[:Protosynthesis] = [boostStat, false]
          end
        else
          if !(mon.effects[:Protosynthesis][0] == 0) && !(mon.effects[:Protosynthesis][1] == true) && mon.item == :BOOSTERENERGY
            boostStat = mon.getHighestStatWithStages
            mon.effects[:Protosynthesis] = [boostStat, false]
          end
        end
      end

      # Crests
      case mon.crested
        when :VESPIQUEN
          stages[PBStats::ATTACK] += 1
          stages[PBStats::SPATK] += 1
        when :THIEVUL then stages[PBStats::SPATK] += 1
      end
    end

    # Abilities on Entry
    # Intrepid Sword
    if mon.ability == :INTREPIDSWORD
      stages[PBStats::ATTACK] += 1 if Gen < 9 || !mon.permeffs[:IntrepidSword] || [:FAIRYTALE, :COLOSSEUM].include?(@battle.FE)
      stages[PBStats::SPATK] += 1 if [:FAIRYTALE, :COLOSSEUM].include?(@battle.FE)
    end
    # Dauntless Shield
    if mon.ability == :DAUNTLESSSHIELD
      stages[PBStats::DEFENSE] += 1 if Gen < 9 || !mon.permeffs[:DauntlessShield] || [:FAIRYTALE, :COLOSSEUM].include?(@battle.FE)
      stages[PBStats::SPDEF] += 1 if [:FAIRYTALE, :COLOSSEUM].include?(@battle.FE)
    end
    # Embody Aspect
    stages[PBStats::SPEED] += 1 if mon.ability == :EMBODYASPECTTEAL
    stages[PBStats::SPDEF] += 1 if mon.ability == :EMBODYASPECTWELLSPRING
    stages[PBStats::ATTACK] += 1 if mon.ability == :EMBODYASPECTHEARTHFLAME
    stages[PBStats::DEFENSE] += 1 if mon.ability == :EMBODYASPECTCORNERSTONE
    # Light Metal
    if mon.ability == :LIGHTMETAL && @battle.FE == :DEEPEARTH
      stages[PBStats::SPEED] += 1
    end
    # Heavy Metal
    if mon.ability == :HEAVYMETAL && @battle.FE == :DEEPEARTH
      stages[PBStats::DEFENSE] += 1
      stages[PBStats::SPEED] -= 1
    end
    # Lightning Rod
    if mon.ability == :LIGHTNINGROD && Rejuv && @battle.FE == :ELECTERRAIN
      stages[PBStats::SPATK] += 1
    end
    # Magma Armor
    if mon.ability == :MAGMAARMOR && [:DRAGONSDEN, :VOLCANIC].include?(@battle.FE)
      stages[PBStats::DEFENSE] += 1
      stages[PBStats::SPDEF] += 1 if @battle.FE == :DRAGONSDEN
    end
    if mon.ability == :ELECTROMORPHOSIS && @battle.FE == :ELECTERRAIN
      stages[PBStats::SPATK] += 1
    end
    if mon.ability == :COSTAR && @battle.FE == :BIGTOP && @battle.doublebattle && mon.pbPartner.hp > 0
      stages[PBStats::ATTACK] += 1
      stages[PBStats::SPATK] += 1
    end
    # Shell Armor
    if Rejuv && mon.ability == :SHELLARMOR && @battle.FE == :DRAGONSDEN
      stages[PBStats::DEFENSE] += 1
    end
    # Stance Change and Stall
    if ((@battle.FE == :FAIRYTALE || (Rejuv && @battle.FE == :CHESS)) && mon.ability == :STANCECHANGE) || (Rejuv && @battle.FE == :CHESS && mon.ability == :STALL)
      stages[PBStats::DEFENSE] += 1
    end
    # Fairy Tale Abilities
    if @battle.FE == :FAIRYTALE
      stages[PBStats::SPDEF] += 1 if [:MAGICGUARD, :MAGICBOUNCE, :POWEROFALCHEMY, :MIRRORARMOR, :PASTELVEIL].include?(mon.ability)
      stages[PBStats::DEFENSE] += 1 if [:ARMORTAIL, :BATTLEARMOR, :SHELLARMOR, :POWEROFALCHEMY].include?(mon.ability)
      stages[PBStats::SPATK] += 1 if mon.ability == :MAGICIAN
    end
    # Starlight Illuminate
    if @battle.FE == :STARLIGHT && mon.ability == :ILLUMINATE
      stages[PBStats::SPATK] += 2
    end
    # Water Compaction
    if [:MISTY, :CORROSIVEMIST].include?(@battle.FE) || @battle.OV == :MISTY
      stages[PBStats::DEFENSE] += 2 if mon.ability == :WATERCOMPACTION
    end
    # Mirror Field Evasion & Accuracy
    if @battle.FE == :MIRROR
      stages[PBStats::EVASION] += 1 if [:SANDVEIL, :SNOWCLOAK, :TANGLEDFEET, :MAGICBOUNCE, :COLORCHANGE, :MIRRORARMOR].include?(mon.ability)
      stages[PBStats::EVASION] += 2 if mon.ability == :ILLUSION
      stages[PBStats::ACCURACY] += 1 if [:KEENEYE, :COMPOUNDEYES].include?(mon.ability)
    end
    # Rattled
    if mon.ability == :RATTLED && [:DIMENSIONAL, :FROZENDIMENSION, :HAUNTED].include?(@battle.FE)
      stages[PBStats::SPEED] += 1
    end
    # Psychic Terrain
    if @battle.FE == :PSYTERRAIN
      stages[PBStats::SPATK] += 2 if [:FOREWARN, :ANTICIPATION].include?(mon.ability)
      stages[PBStats::SPATK] += 1 if mon.ability == :MINDSEYE
    end
    if @battle.OV == :PSYTERRAIN
      stages[PBStats::SPATK] += 1 if [:FOREWARN, :ANTICIPATION].include?(mon.ability)
    end
    # Crystal Cavern
    if @battle.FE == :CRYSTALCAVERN
      stages[PBStats::SPATK] += 1 if mon.ability == :TERAFORMZERO
    end
    # Dimensionals
    if [:DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE)
      stages[PBStats::SPATK] += 1 if mon.ability == :BERSERK
      stages[PBStats::ATTACK] += 1 if [:JUSTIFIED, :ANGERPOINT].include?(mon.ability)
      if mon.ability == :ANGERSHELL
        stages[PBStats::SPEED] += 1
        stages[PBStats::ATTACK] += 1
        stages[PBStats::SPATK] += 1
        stages[PBStats::DEFENSE] -= 1
        stages[PBStats::SPDEF] -= 1
      end
    end
    # Sky
    if @battle.FE == :SKY
      stages[PBStats::DEFENSE] += 1 if mon.ability == :BIGPECKS
      stages[PBStats::SPEED] += 1 if PBStuff::LevitateAbilities.include?(mon.ability)
    end
    # Infernal
    if @battle.FE == :INFERNAL
      stages[PBStats::DEFENSE] += 1 if [:MAGMAARMOR, :FLAMEBODY, :DESOLATELAND].include?(mon.ability)
      stages[PBStats::SPDEF] += 1 if [:MAGMAARMOR, :FLAMEBODY, :DESOLATELAND].include?(mon.ability)
    end
    # Colosseum
    if @battle.FE == :COLOSSEUM
      stages[PBStats::DEFENSE] += 1 if [:BATTLEARMOR, :SHELLARMOR].include?(mon.ability)
      stages[PBStats::SPDEF] += 1 if [:MIRRORARMOR, :MAGICGUARD].include?(mon.ability)
      stages[PBStats::ATTACK] += 1 if [:JUSTIFIED, :NOGUARD].include?(mon.ability)
      stages[PBStats::SPATK] += 1 if [:JUSTIFIED, :NOGUARD].include?(mon.ability)
    end
    # Concert
    if @battle.ProgressiveFieldCheck(PBFields::CONCERT)
      stages[PBStats::DEFENSE] += 1 if [:HEAVYMETAL, :SOLIDROCK, :PUNKROCK, :SOUNDPROOF, :ROCKHEAD].include?(mon.ability)
      if @battle.ProgressiveFieldCheck(PBFields::CONCERT, 2, 4)
        stages[PBStats::SPEED] += 1 if [:EMERGENCYEXIT, :RUNAWAY].include?(mon.ability)
        if @battle.ProgressiveFieldCheck(PBFields::CONCERT, 3, 4)
          stages[PBStats::SPEED] += 2 if mon.ability == :RATTLED
        end
      end
    end
    # Back Alley
    if @battle.FE == :BACKALLEY
      stages[PBStats::DEFENSE] += 1 if [:ANTICIPATION, :FOREWARN].include?(mon.ability)
      stages[PBStats::SPDEF] += 1 if [:ANTICIPATION, :FOREWARN].include?(mon.ability)
      stages[PBStats::ATTACK] += 1 if [:PICKPOCKET, :MERCILESS].include?(mon.ability)
      stages[PBStats::SPATK] += 1 if mon.ability == :MAGICIAN
    end
    # City
    if @battle.FE == :CITY
      stages[PBStats::DEFENSE] += 1 if mon.ability == :BIGPECKS
      stages[PBStats::ATTACK] += 1 if mon.ability == :EARLYBIRD
      stages[PBStats::SPEED] += 1 if [:PICKUP, :RATTLED].include?(mon.ability)
    end

    # Deso fields
    # Clouds
    if @battle.FE == :CLOUDS
      stages[PBStats::DEFENSE] += 1 if [:CLOUDNINE, :FORECAST, :OVERCOAT].include?(mon.ability)
      stages[PBStats::SPDEF] += 1 if [:FORECAST, :WINDPOWER].include?(mon.ability)
      stages[PBStats::SPEED] += 1 if [:FORECAST].include?(mon.ability)
      stages[PBStats::ATTACK] += 1 if [:BIGPECKS].include?(mon.ability)
      stages[PBStats::SPATK] += 1 if mon.ability == :LIGHTNINGROD && @battle.pbWeather(nil) == :RAINDANCE
      stages[PBStats::SPEED] += 1 if mon.ability == :MOTORDRIVE && @battle.pbWeather(nil) == :RAINDANCE
      stages[PBStats::SPDEF] += 1 if mon.ability == :SNOWCLOAK && [:HAIL, :SNOW].include?(@battle.pbWeather(nil))
      stages[PBStats::DEFENSE] += 1 if mon.ability == :ICEBODY && [:HAIL, :SNOW].include?(@battle.pbWeather(nil))
    end
    # Crowd
    if @battle.FE == :CROWD
      stages[PBStats::DEFENSE] += 1 if mon.ability == :IRONFIST
    end
    # Darkness / Overlay
    stages[PBStats::SPEED] += 1 if mon.ability == :PICKPOCKET && ([:DARKNESS2].include?(@battle.FE) || @battle.OV == :DARKNESS2)
    stages[PBStats::SPEED] += 2 if mon.ability == :PICKPOCKET && [:DARKNESS3].include?(@battle.FE)
    stages[PBStats::SPEED] += 1 if mon.ability == :RATTLED && (PBFields::DARKNESS.include?(@battle.FE) || @battle.OV == :DARKNESS2)
    # Dancefloor
    if @battle.FE == :DANCEFLOOR
      stages[PBStats::SPATK] += 1 if [:DANCER, :ILLUMINATE].include?(mon.ability)
      stages[PBStats::SPDEF] += 2 if [:MAGICGUARD, :MAGICBOUNCE].include?(mon.ability)
      stages[PBStats::SPDEF] += 1 if [:INSOMNIA, :MAGICIAN, :ILLUMINATE].include?(mon.ability)
      stages[PBStats::DEFENSE] += 1 if mon.ability == :INSOMNIA
    end

    # trainer effect boosts
    if Rejuv && !@battle.opponent.nil?
      initboosts = getStatBoostsOnEntry(@battle.pbGetOwner(mon.index), mon, delay = false)
      initboosts.each {|stat, value|
        next if value == nil
        stages[stat] += value
      }
    end
    # Contrary
    if mon.ability == :CONTRARY
      PBStats::All.each { |stat| stages[stat] *= -1 }
    end
    # Simple
    if mon.ability == :SIMPLE
      PBStats::All.each { |stat| stages[stat] *= 2 }
    end
    PBStats::All.each { |stat| mon.stages[stat] += stages[stat] } # merge changed stages into mon's stages
    PBStats::All.each { |stat| mon.stages[stat] = mon.stages[stat].clamp(-6, 6) }
  end

  def shouldHardSwitch?(attacker, switch_in_index, opponent = nil)
    return true if (0..3).any? { |i| attacker.moves[i] && !@battle.pbCanChooseMove?(attacker.index, i) }
    return true if attacker.effects[:PerishSong] > 0

    opponent = attacker.pbFirstOpposing if !opponent
    return true if opponent.lastMoveUsed.is_a?(Symbol) && moveToMoveObject(opponent.lastMoveUsed, opponent).pbIsStatus?

    switch_in = pbMakeFakeBattler(@battle.pbPartySingleOwner(attacker.index)[switch_in_index], switch_in_index)
    # get types from Trainer Effects
    pbStatChangingSwitch(switch_in)

    # check if the switch_in would just straight up die from assumed move used
    assumed_damage = 0
    assumed_damage += totalHazardDamage(switch_in)
    assumed_move = checkAIbestMove(opponent, attacker)
    assumed_damage += pbRoughDamage(assumed_move, opponent, switch_in)
    return false if assumed_damage > switch_in.hp

    special_conditions = attacker.ability == :ZEROTOHERO && !attacker.permeffs[:ZeroToHero] # Experimental
    return true if special_conditions

    switch_in.hp -= assumed_damage
    return false if !canKillBeforeOpponentKills?(switch_in, opponent)

    return true
  end

  def canKillBeforeOpponentKills?(attacker, opponent)
    # first check what move is fastest for attacker and opponent
    attmovearray, attdamagearray = checkAIMovePlusDamage(attacker, opponent, wholearray: true)
    oppmovearray, oppdamagearray = checkAIMovePlusDamage(opponent, attacker, wholearray: true)
    # cap damage at HP value of target
    attdamagearray.map! { |score| score > opponent.hp ? opponent.hp : score }
    oppdamagearray.map! { |score| score > attacker.hp ? attacker.hp : score }
    # check if move can OHKO the target in such a way that it cannot do an attack
    for i in 0...attdamagearray.length
      attdamagearray[i] = attdamagearray[i] > 0 && notOHKO?(attacker, opponent, true, attmovearray[i]) ? attdamagearray[i] - 1 : attdamagearray[i]
    end
    for i in 0...oppdamagearray.length
      oppdamagearray[i] = oppdamagearray[i] > 0 && notOHKO?(opponent, attacker, true, oppmovearray[i]) ? oppdamagearray[i] - 1 : oppdamagearray[i]
    end

    # filter out all moves that actually kill
    attmovearray.filter!.with_index { |move, index| attdamagearray[index] >= opponent.hp }
    oppmovearray.filter!.with_index { |move, index| oppdamagearray[index] >= attacker.hp }
    attdamagearray.filter! { |score| score >= opponent.hp }
    oppdamagearray.filter! { |score| score >= attacker.hp }
    return true if oppmovearray.length == 0
    return false if attmovearray.length == 0

    # check if there are any moves the attacker has that would move before all moves of opponent
    return attmovearray.any? { |attmove|
             oppmovearray.all? { |oppmove|
               pbAIfaster?(attmove, oppmove, attacker, opponent)
             }
           }
  end


  ################################################################################
  # AI Memory utility functions
  ################################################################################

  def addMoveToMemory(battler, move)
    return if @battle.isOnline?
    return if move.nil?

    trainer = @battle.pbGetOwner(battler.index)
    return if !trainer # wild battle
    return if !battler.pokemon

    if move.zmove
      basemove = move.data&.zmovedata&.basemove
      return unless basemove # not a species specific z move
      move = battler.moves.find { |move| move.move == basemove }
      return unless move
    end

    # check if pokemon is added to trainer array, add if isn't the case
    @aiMoveMemory[trainer][battler.pokemon.personalID] = [] if !@aiMoveMemory[trainer].key?(battler.pokemon.personalID)
    knownmoves = @aiMoveMemory[trainer][battler.pokemon.personalID]
    knownmoves.filter! { |moveloop| moveloop != nil && moveloop.move != move.move } # remove old instance of the same move

    # update the move memory by taking current known move array and add new move in array form to it
    move = move.clone
    @aiMoveMemory[trainer][battler.pokemon.personalID] = knownmoves.push(move)

    if battler.effects[:Illusion]
      legalmoves = battler.effects[:Illusion].pokemon.getAllLegalMoves(true)
      discloseIllusion(battler, :move) if !legalmoves.include?(move.move)
    end
  end

  def addMonToMemory(pkmn, index)
    return if @battle.isOnline?

    trainer = @battle.pbGetOwner(index)
    return if !trainer # wild battle

    @aiMoveMemory[trainer][pkmn.personalID] = [] if !@aiMoveMemory[trainer].key?(pkmn.personalID)
  end

  def discloseItem(battler)
    return if @battle.isOnline?
    battler.permeffs[:ItemDisclosure] = true
  end

  def discloseIllusion(battler, cause)
    return if @battle.isOnline?
    case cause
      when :move, :noTransform then return if @mondata.skill < HIGHSKILL
      when :diffHP, :diffStatus, :passiveTypeEff then return if @mondata.skill < MEDIUMSKILL
      when :immunity, :invalidStatus # everyone can figure out immunities
    end
    battler.permeffs[:IllusionDisclosure] = true
  end

  def getAIMemory(battler = @opponent, inspecting: false, change: false, addfakemoves: false, usedmove: false)
    return [] if !battler || battler.hp == 0

    trainer = @battle.pbGetOwner(battler.index)
    return [] if !trainer

    moves = []
    if @aiMoveMemory[trainer][battler.pokemon.personalID]
      moves = @aiMoveMemory[trainer][battler.pokemon.personalID].clone
    end

    return moves if inspecting
    if @mondata.index == battler.index || @mondata.index == battler.pbPartner.index || (omniscience? && usedmove == false)
      # we're checking our own moves stupid
      moves = battler.moves.clone
    else
      # we're dealing with enemy battler
      if addfakemoves && moves.length < 4
        cresttype = nil
        protypes = nil
        case battler.species
          when :EMPOLEON then cresttype = :ICE
          when :LUXRAY then cresttype = :DARK
          when :SAMUROTT then cresttype = :FIGHTING
          when :SIMISEAR then cresttype = :WATER
          when :SIMIPOUR then cresttype = :GRASS
          when :SIMISAGE then cresttype = :FIRE
          when :ZOROARK
            if !battler.effects[:ZoroCrest].nil? && !illusionDeceived?(@attacker, battler)
              cresttype = battler.effects[:ZoroCrest].types
            end
        end
        if [:LIBERO,:PROTEAN].include?(battler.pokemon.ability)
          protypes = [battler.getCacheData.Type1, battler.getCacheData.Type2]
        end
        typeArray = [battler.type1, battler.type2, cresttype, protypes].flatten.uniq.compact
        for type in typeArray
          moves.push(PokeBattle_Move_FFF.new(@battle, battler, type)) if type && !hasDamagingMoveOfType(battler, moves, type)
          if type == :NORMAL
            if @opponent.ability == :GUTS && (@opponent.status != nil || [:FLAMEORB, :TOXICORB].include?(@opponent.item))
              moves.push(moveToMoveObject(:FACADE, @opponent)) if moves.none? {|move| move.move == :FACADE}
            end
          end
        end
      end

    end

    moves.filter! { |move| move.usable? }
    moves.filter! { |move| @battle.pbCanChooseMove?(battler.index, move) } # Experimental
    moves.map! { |move| pbChangeMove(move, battler) } if change

    return moves
  end

  # Battler only serves for determining the trainer and battle side.
  def getAIMemoryNonBattler(battler, pkmn)
    return [] if pkmn.hp == 0

    trainer = @battle.pbGetOwner(battler.index)
    return [] if !trainer

    if omniscience?
      return pkmn.moves.map { |move| PokeBattle_Move.pbFromPBMove(@battle, move, pkmn) }.filter { |move| move.usable? }
    end

    if @aiMoveMemory[trainer][pkmn.personalID]
      return @aiMoveMemory[trainer][pkmn.personalID].filter { |move| move.usable? }
    end

    return []
  end

  def getAIKnownParty(battler)
    trainer = @battle.pbGetOwner(battler.index)
    return [] if !trainer

    party = @battle.pbPartySingleOwner(battler.index)
    knownparty = party.find_all { |mon|
      !mon.nil? && mon.hp > 0 && !mon.isEgg? && (@aiMoveMemory[trainer].keys.include?(mon.personalID) || omniscience?)
    }
    return knownparty
  end

  def checkAImovesAllOpponents(moveID, usedmove: false)
    return @opponent if checkAImoves(moveID, battler: @opponent, usedmove: usedmove)
    return @opponent.pbPartner if checkAImoves(moveID, battler: @opponent.pbPartner, usedmove: usedmove)
    return nil
  end

  def checkAImoves(moves, memory = nil, battler: @opponent, usedmove: false)
    raise "moves should be an array" unless moves.is_a?(Array)
    memory = getAIMemory(battler, usedmove: usedmove) if memory.nil?
    memory = memory.map { |move| pbChangeMove(move, battler) }
    memory = memory.map { |move| move.move }
    # basic "does the other mon have x"
    return memory.intersect?(moves)
  end

  def checkAIhealing(memory = nil)
    memory = getAIMemory(@opponent) if memory.nil?
    # less basic "can the other mon heal"
    return memory.any? { |move| move.isHealingMove? }
  end

  def checkAIdraining(memory = nil)
    memory = getAIMemory(@opponent) if memory.nil?
    # supplement healing function above
    return memory.any? { |move| move.isDrainingMove? }
  end

  def checkAIpriority(memory = nil)
    opp = memory.nil? ? @opponent : nil
    memory = getAIMemory(@opponent) if memory.nil?
    # "does the other mon have priority"
    return memory.any? { |move| opp ? move.pbIsPriorityMoveAI(opp) : move.priority > 0 }
  end

  def checkAIaccuracy(memory = nil)
    memory = getAIMemory(@opponent) if memory.nil?
    memory = memory.map { |move| pbChangeMove(move, @opponent) }
    # "does the other mon have moves that don't miss"
    return memory.any? { |move| move.accuracy == 0 && move.function != 0x111 } # Exclude Future Sight and Doom Desire
  end

  def checkAIMovePlusDamage(opponent = @opponent, attacker = @attacker, memory = nil, considerlock: true, wholearray: false)
    # Opponent is the one attacking, bit confusing i know
    if !opponent || opponent.hp == 0
      return wholearray ? [[], []] : [@battle.struggle, 0]
    end

    if considerlock && @mondata.skill >= MEDIUMSKILL && lockedIntoAMove?(opponent) && opponent.lastMoveUsed.is_a?(Symbol)
      # Expected damage should account for certain move locks even if getAIMemory itself shouldn't
      memory = [moveToMoveObject(opponent.lastMoveUsed, opponent)]
    else
      memory = getAIMemory(opponent, addfakemoves: @mondata.skill >= MEDIUMSKILL) if memory.nil?
    end
    damagearray = []
    movearray = []
    for j in memory
      next unless j.usable?
      damagearray.push(pbRoughDamage(j, opponent, attacker))
      movearray.push(j)
    end
    return [movearray, damagearray] if wholearray
    return [@battle.struggle, 0] if damagearray.empty?
    return [movearray[damagearray.index(damagearray.max)], damagearray.max]
  end

  def checkAIdamage(attacker = @attacker, opponent = @opponent, memory = nil, considerlock: true)
    bestmove, damage = checkAIMovePlusDamage(opponent, attacker, memory, considerlock: considerlock)
    return damage
  end

  def checkAIbestMove(opponent = @opponent, attacker = @attacker, memory = nil, considerlock: true)
    bestmove, damage = checkAIMovePlusDamage(opponent, attacker, memory, considerlock: considerlock)
    return bestmove
  end

  def pbRoughDamageAfterBoostsOrDrops(attacker = @attacker, opponent = @opponent, wholeoutputarray: false, oppboosts: [], attboosts: [])
    # Set the default value of the arrays, not really necessary
    default = []

    # Clone the stages arrays
    oppstages, attstages = opponent.stages.clone, attacker.stages.clone

    # Apply stat changes to pokemon
    if oppboosts != default
      for stat in PBStats::All
        next if oppboosts[stat] == 0
        opponent.stages[stat] += oppboosts[stat]
        opponent.stages[stat] = opponent.stages[stat].clamp(-6, 6)
      end
    end
    if attboosts != default
      for stat in PBStats::All
        next if attboosts[stat] == 0
        attacker.stages[stat] += attboosts[stat]
        attacker.stages[stat] = attacker.stages[stat].clamp(-6, 6)
      end
    end

    # Recalculate the damage
    bestmove, maxdam = checkAIMovePlusDamage(attacker, opponent, nil, wholearray: wholeoutputarray)

    # Revert the stat changes
    opponent.stages, attacker.stages = oppstages, attstages

    return [bestmove, maxdam]
  end

  ######################################################
  # AI Damage Calc
  ######################################################

  def pbRoughDamage(move = @move, attacker = @attacker, opponent = @opponent, considersub: true)
    # Function Failure Checks
    return 0 if opponent.species == 0 || attacker.species == 0
    return 0 if opponent.hp == 0 || attacker.hp == 0
    return 0 unless move.usable?

    # Real Setup Stuff
    basemove = move
    move = pbChangeMove(move, attacker)

    basedmg = move.basedamage
    if @mondata.skill >= MEDIUMSKILL
      basedmg = pbBetterBaseDamage(move, attacker, opponent)
    end

    return 0 if basedmg == 0

    type = move.type
    if move.function == 0x20E # Mirror Beam
      move.type = move.smartDamageType(attacker, opponent, attacker.effects[:ReflectorTypes] + [$cache.moves[move.move].type]) # uses the actual damage calc method
    end
    # More accurate move type (includes Normalize, most type-changing moves, etc.)
    if @mondata.skill >= MINIMUMSKILL
      type = move.pbType(attacker)
    end
    typemod = pbTypeModNoMessages(type, attacker, opponent, move)
    typemult = typemod.multiplier
    return 0 if typemod.immune?

    weather = @battle.pbWeather(attacker)
    return 0 if weather == :SUNNYDAY && @battle.state.effects[:HarshSunlight] && type == :WATER
    return 0 if weather == :RAINDANCE && @battle.state.effects[:HeavyRain] && type == :FIRE
    return 0 if !moveSuccessful?(basemove, attacker, opponent)
    return 0 if opponent.totalhp == 1 && (opponent.ability == :STURDY || (opponent.ability == :STALWART && @battle.FE == :COLOSSEUM)) && !moldBreakerCheck(attacker, opponent, move)

    smartCategoryFunctions = [0x176, 0x20D, 0x309, 0x80A, 0x80B, 0x81E, 0x82A] # Photon Geyser / Super Ultra Mega Death Move / Shell Side Arm / Unleashed Power / Blinding Speed
    smartCategoryFunctions.push(0x522) if attacker.isStellarTerapagos? # Tera Starstorm
    smartCategoryFunctions.push(0x9F) if attacker.crested == :SILVALLY || @battle.FE == :DEUXFINALIS # Tera Starstorm
    if smartCategoryFunctions.include?(move.function)
      movetarget = ([0x176, 0x522, 0x82A].include?(move.function) || move.function == 0x9F && @battle.FE != :DEUXFINALIS) ? nil : opponent

      moldBrokenArray = getMoldBrokenArray(attacker, opponent, move)
      move.category = move.smartDamageCategory(attacker, movetarget, moldBrokenArray: moldBrokenArray)
    end
    if move.function == 0x206 # Probopass Crest Move
      move.type = move.smartDamageType(attacker, opponent, [:STEEL, :ROCK, :ELECTRIC]) # uses the actual damage calc method
    end
    return 0 if move.zmove && (opponent.effects[:Disguise] || (opponent.effects[:IceFace] && (move.pbIsPhysical?(attacker) || @battle.FE == :FROZENDIMENSION))) && !moldBreakerCheck(attacker, opponent, move)

    if move.pbFixedDamageMove?
      # OHKO moves are not affected by steadyhand password
      return move.function == 0x70 ? basedmg : move.applyTradePowerForAcc(basedmg, attacker, opponent)
    end

    fielddata = @battle.field.moveData(move.move)
    ai_mon_attacking = @battle.aiControlled?(attacker.index)
    oppitemworks = opponent.itemWorks?
    attitemworks = attacker.itemWorks?
    wonderroom = @battle.state.effects[:WonderRoom] > 0 # Using this instead of attacker/opponent.wonderroom, for when pbRoughDamage is called with an attacker/opponent that hasn't switched in yet

    ##### Unique Modifiers #####
    # Weather
    weathermult = 1.0
    if @mondata.skill >= MEDIUMSKILL
      case weather
        when :SUNNYDAY
          if move.function == 0x508 && !attacker.hasWorkingItem(:UTILITYUMBRELLA) # Hydro Steam
            weathermult = 1.5
          elsif !opponent.hasWorkingItem(:UTILITYUMBRELLA)
            weathermult = 1.5 if type == :FIRE
            weathermult = 0.5 if type == :WATER
          end
        when :RAINDANCE
          unless opponent.hasWorkingItem(:UTILITYUMBRELLA)
            weathermult = 0.5 if type == :FIRE
            weathermult = 1.5 if type == :WATER
            weathermult = 1.2 if type == :ELECTRIC && @mondata.skill >= BESTSKILL && @battle.FE == :CLOUDS
          end
        when :SNOW
          if @battle.state.effects[:NeverMeltIce]
            weathermult = 1.5 if type == :ICE && move.pbIsSpecial?(attacker)
          end
      end
    end

    # Multi-targeting attacks
    spreadmult = 1.0
    if @mondata.skill >= MEDIUMSKILL && move.pbTargetsAll?(attacker)
      if @mondata.skill >= BESTSKILL && @battle.FE == :CHESS && attacker.piece == :KNIGHT && attacker.pbTarget(move) == :AllOpposing
        spreadmult = 1.25
      else
        if !(attacker.crested == :ENTEI && type == :FIRE)
          spreadmult = 0.75
        end
      end
    end

    # Parental Bond / Typhlosion Crest
    bondmult = 1.0
    multihitcheck = attacker.pbGetHitNumber(move, norandomness: true) > 1 # don't use this result for an accurate hitcount, it's just to confirm it's more than one hit, and to set parental bond like effect flags
    if @mondata.skill >= MEDIUMSKILL
      bondmult = 1.25 if attacker.effects[:ParentalBond] && multihitcheck
      bondmult = 1.3 if attacker.effects[:TyphBond] && multihitcheck
      if Rejuv && attacker.hasBlessings?
        if attacker.effects[:SurgingBlessing] > 0 && multihitcheck
          rank = attacker.checkBlessing(:SURGINGSTRIKES)
          mod = $cache.blessings[:SURGINGSTRIKES].getValue(:damageReduction, rank)
          bondmult += mod
        end
      end
    end

    # Critical Hits
    # Increased Crit Chance
    critmult = 1.0
    if @mondata.skill >= MEDIUMSKILL
      critrate = pbCritRateAI?(attacker, opponent, move)
      critmult = 1.25 if critrate == 2
      critmult = 1.5 if critrate > 2
    end

    # Random Rolls
    random = 100
    if ai_mon_attacking && opponent.index != attacker.pbPartner.index
      # Assume lower rolls when calcing damage dealt -by- AI mons against non-partners
      # This is something that could be tweaked based on skill
      random = 93 if @mondata.skill >= HIGHSKILL
      random = 85 if @mondata.skill >= BESTSKILL
    end
    random = 93 if $game_switches[:No_Damage_Rolls]
    random = 85 if @mondata.skill >= BESTSKILL && @battle.FE == :CONCERT1
    random = 100 if @mondata.skill >= BESTSKILL && @battle.FE == :CONCERT4
    randommult = random * 0.01

    # STAB
    stabmult = 1.0
    if @mondata.skill >= MEDIUMSKILL
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
      protean = ([:PROTEAN, :LIBERO].include?(attacker.ability) && (Gen < 9 || !attacker.effects[:ProteanUsed])) ||
        (attacker.crested == :GOTHITELLE && [:PSYCHIC, :DARK].include?(type)) ||
        (attacker.crested == :REUNICLUS && ((move.pbIsPhysical?(attacker) && type == :FIGHTING) || (move.pbIsSpecial?(attacker) && type == :PSYCHIC)))
      hasType = (attacker.hasType?(type) || protean) && !(attacker.effects[:DesertsMark] && type == :GROUND)
      # grass isn't really a tera type of ogerpon's (except teal mask) but for our implementation this works the same
      # terapagos' tera type is stellar but for STAB determination that works the same as being the same type as the mon's base type
      hasTeraType = attacker.isTerastallized? && (attacker.hasType?(type) || (attacker.species == :OGERPON && type == :GRASS))
      # STAB Calc
      if hasType || hasTeraType || typecrest || attacker.teraTypeEffect&.include?(type)
        stabmod = [hasType, hasTeraType, typecrest, attacker.teraTypeEffect&.include?(type), attacker.ability == :ADAPTABILITY].count(true)
        stabmult = PBMults::STAB[stabmod]
      elsif attacker.isStellarTerapagos?
        stabmult = 1.2
      end
      stabmult = pbModifySTAB(stabmult, type, attacker, opponent)
    end

    # Burn
    burnmult = 1.0
    if @mondata.skill >= MEDIUMSKILL
      burnmult = 0.5 if attacker.status == :BURN && move.pbIsPhysical?(attacker, type) && (@attacker.crested != :SUICUNE) && attacker.ability != :GUTS && move.move != :FACADE
    end
    if @mondata.skill >= BESTSKILL
      burnmult = 0.66 if attacker.status == :FROZEN && move.pbIsSpecial?(attacker, type) && @battle.state.effects[:NeverMeltIce]
    end

    # Partially bypassing Protect (may be present due to a seed effect)
    protectmult = 1.0
    protectmult = 0.25 if (Rejuv && move.move == :KOWTOWCLEAVE && @battle.FE == :CHESS) && (opponent.effects[:Protect] || @battle.priorityBlockingAbilities.include?(opponent.ability))
    protectmult = 0.25 if (move.zmove || (Gen >= Champs && move.unseenFistCheck(attacker))) && opponent.effects[:Protect] && move.move != :UNLEASHEDPOWER

    # Glaive Rush (High Skill)
    glaivemult = 1.0
    glaivemult = 2.0 if @mondata.skill >= HIGHSKILL && opponent.effects[:GlaiveRush] && getAIMemory(opponent).all? { |oppmove| pbAIfaster?(move, oppmove, attacker, opponent) }

    ##### Base Power Modifiers #####
    basemult = []
    aurabroken = aiCheckGlobalAbility(:AURABREAK, attacker, opponent, move, checkMoldBroken: true)
    fieldmodifier = @mondata.skill >= BESTSKILL && ([*PBFields::DARKNESS, :DEUXFINALIS].include?(@battle.FE) || @battle.OV == :DARKNESS2)
    # Base Power Abilites, Items, and Misc stuff (Medium Skill)
    if @mondata.skill >= MEDIUMSKILL
      if type == :DARK && (aiCheckGlobalAbility(:DARKAURA, attacker, opponent)  || aiCheckSideCrest(:PANGORO, attacker, attacker, opponent, move).any?)
        if fieldmodifier
          case @battle.FE
            when :DARKNESS1 then auramult = 1.4
            when :DARKNESS2 then auramult = 1.5
            when :DARKNESS3 then auramult = 1.66
            when :DEUXFINALIS then auramult = (aiCheckSideAbility(:DARKAURA, attacker).any? || aiCheckSideCrest(:PANGORO, attacker, attacker, opponent, move).any?) ? 1.33 : 1
            else auramult = 1.33
          end
          auramult = 1.5 if @battle.OV == :DARKNESS2 && auramult < 1.5
          basemult.append(aurabroken ? 1 / auramult : auramult)
        else
          basemult.append(aurabroken ? 0.75 : 1.33)
        end
      end
      if type == :FAIRY && aiCheckGlobalAbility(:FAIRYAURA, attacker, opponent)
        if fieldmodifier
          case @battle.FE
            when :DARKNESS1 then auramult = 1.3
            when :DARKNESS2 then auramult = 1.2
            when :DARKNESS3 then auramult = 1.1
            when :DEUXFINALIS then auramult = aiCheckSideAbility(:FAIRYAURA, attacker).any? ? 1.33 : 1
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
          if move.type == :NORMAL && type == :FLYING
            boost = 1.2
            boost = 1.5 if [:MOUNTAIN, :SNOWYMOUNTAIN, :SKY].include?(@battle.FE) && @mondata.skill >= BESTSKILL
            basemult.append(boost)
          end
        when :GALVANIZE
          if move.type == :NORMAL && type == :ELECTRIC
            boost = 1.2
            boost = 1.5 if ([:ELECTERRAIN, :FACTORY].include?(@battle.FE) || @battle.OV == :ELECTERRAIN) && @mondata.skill >= BESTSKILL
            boost = 2.0 if @battle.FE == :SHORTCIRCUIT && @mondata.skill >= BESTSKILL
            basemult.append(boost)
          end
        when :REFRIGERATE
          if move.type == :NORMAL && type == :ICE
            boost = 1.2
            boost = 1.5 if [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION].include?(@battle.FE) && @mondata.skill >= BESTSKILL
            basemult.append(boost)
          end
        when :PIXILATE
          if move.type == :NORMAL && (type == :FAIRY || (type == :NORMAL && @battle.FE == :GLITCH && @mondata.skill >= BESTSKILL))
            boost = 1.2
            boost = 1.5 if (@battle.FE == :MISTY || @battle.OV == :MISTY) && @mondata.skill >= BESTSKILL
            basemult.append(boost)
          end
        when :DRAGONIZE
          if move.type == :NORMAL && type == :DRAGON
            boost = 1.2
            boost = 1.5 if @battle.FE == :DRAGONSDEN && @mondata.skill >= BESTSKILL
            basemult.append(boost)
          end
        when :DUSKILATE     then basemult.append(1.2) if move.type == :NORMAL && (type == :DARK || (!Rejuv && type == :NORMAL && @battle.FE == :GLITCH && @mondata.skill >= BESTSKILL))
        when :NORMALIZE     then basemult.append(1.2) if !move.zmove
        when :IRONFIST      then basemult.append(1.2) if move.punchMove?
        when :RECKLESS      then basemult.append(1.2) if move.recoil > 0 || [0x10B, 0x506].include?(move.function) # High Jump Kick, Axe Kick
        when :SHEERFORCE    then basemult.append(1.3) if move.effect > 0
        when :SANDFORCE     then basemult.append(1.3) if (weather == :SANDSTORM || [:DESERT, :ASHENBEACH].include?(@battle.FE)) && [:ROCK, :GROUND, :STEEL].include?(type)
        when :ANALYTIC      then basemult.append(1.3) if [opponent, opponent.pbPartner, attacker.pbPartner].none? { |battler| battler.hp > 0 && pbAIfaster?(nil, nil, attacker, battler) }
        when :TOUGHCLAWS    then basemult.append(1.3) if attacker.makesContact?(move)
        when :BEADSOFRUIN   then basemult.append(1.3) if opponent.status == :PETRIFIED && @battle.FE == :DEUXFINALIS
        when :TECHNICIAN
          if basedmg <= 60
            basemult.append(1.5)
          elsif @mondata.skill >= BESTSKILL && (@battle.FE == :FACTORY || @battle.ProgressiveFieldCheck(PBFields::CONCERT)) && basedmg <= 80
            basemult.append(1.5)
          end
        when :FLAREBOOST    then basemult.append(1.5) if (attacker.status == :BURN || (@mondata.skill >= BESTSKILL && [:BURNING, :VOLCANIC, :INFERNAL].include?(@battle.FE))) && move.pbIsSpecial?(attacker, type) && (@mondata.skill >= BESTSKILL && @battle.FE != :FROZENDIMENSION)
        when :TOXICBOOST
          if attacker.status == :POISON && move.pbIsPhysical?(attacker, type)
            basemult.append((@mondata.skill >= BESTSKILL && @battle.FE == :CORRUPTED) ? 2.0 : 1.5)
          elsif @mondata.skill >= BESTSKILL && ([:CORROSIVEMIST].include?(@battle.FE) || ([:CORROSIVE, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE) && !attacker.isAirborne?)) && move.pbIsPhysical?(attacker, type)
            basemult.append((@mondata.skill >= BESTSKILL && @battle.FE == :CORRUPTED) ? 2.0 : 1.5)
          end
        when :STRONGJAW     then basemult.append(1.5) if move.bitingMove?
        when :MEGALAUNCHER  then basemult.append(1.5) if move.pulseMove?
        when :SHARPNESS     then basemult.append(1.5) if move.sharpMove?
        when :TRUESHOT      then basemult.append(1.3) if move.bulletMove?
        when :HOTSHOT       then basemult.append(1.3) if move.shotMove?
        when :SOLARIDOL     then basemult.append(1.5) if type == :FIRE
        when :LUNARIDOL     then basemult.append(1.5) if type == :ICE
        when :TERAVOLT      then basemult.append(1.5) if @mondata.skill >= BESTSKILL && Rejuv && @battle.FE == :ELECTERRAIN && type == :ELECTRIC
        when :INEXORABLE    then basemult.append(1.3) if pbAIfaster?(move, nil, attacker, opponent)
        when :SUPREMEOVERLORD then basemult.append(1 + 0.1 * attacker.effects[:SupremeOverlord])
      end
      # Partner Abilities
      for partner in aiCheckSideAbility(:BATTERY, attacker, attacker, opponent, excludeSelf: true)
        @mondata.skill >= BESTSKILL && Rejuv && @battle.FE == :ELECTERRAIN ? basemult.append(1.5) : basemult.append(1.3) if move.pbIsSpecial?(attacker, type)
      end
      # Opponent Abilities
      unless moldBreakerCheck(attacker, opponent, move)
        case opponent.ability
          when :HEATPROOF   then basemult.append(0.5) if type == :FIRE && Gen < 9
          when :DRYSKIN     then basemult.append(1.25) if type == :FIRE
        end
      end
      # Attacker Items
      if attitemworks
        if $cache.items[attacker.item].checkFlag?(:typeboost) == type
          if $cache.items[attacker.item].checkFlag?(:gem)
            basemult.append(1.3)
          else
            basemult.append(1.2)
          end
        else
          case attacker.item
            when :MUSCLEBAND then basemult.append(PBMults::TenPercentItem) if move.pbIsPhysical?(attacker, type) # approx. 1.1x
            when :WISEGLASSES then basemult.append(PBMults::TenPercentItem) if move.pbIsSpecial?(attacker, type) # approx. 1.1x
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
      attacker.effects[:HelpingHand].times { basemult.append(1.5) }
      # Frenzy
      basemult.append(1.33) if attacker.permeffs[:Frenzy]
      case type
        when :FIRE then basemult.append(0.33) if @battle.state.effects[:WaterSport] > 0
        when :ELECTRIC
          basemult.append(0.33) if @battle.state.effects[:MudSport] > 0
          basemult.append(2.0) if attacker.effects[:Charge] > 0
      end
      # Moves that use pbBaseDamageMultplier: Fusion Flare, Fusion Bolt, Venoshock, Facade, Brine, Retaliate, Solar Beam/Blade, Misty Explosion, Knock Off, Grav Apple, Lash Out, Expanding Force, Psyblade
      basemult.append(move.pbBaseDamageMultiplier(1.0, attacker, opponent)) unless [0x79, 0x7A, 0x7B].include?(move.function)
      # Excluding Fusion Flare, Fusion Bolt and Venoshock. Venoshock has field-related damage changes that have skill checks. Fusion move boosts just can't be accounted for like this
    end
    # Stuff that doesn't exist. Future Proofing (High Skill)
    if @mondata.skill >= HIGHSKILL
    end
    # Fields (Best Skill)
    if @mondata.skill >= BESTSKILL
      if @battle.field.isFieldEffect?
        fieldmult = move.moveFieldBoost(attacker)
        if fieldmult != 1
          basemult.append(fieldmult)
        end
      end
      fieldBoost = move.typeFieldBoost(type, attacker, opponent)
      overlayBoost = move.typeOverlayBoost(type, attacker, opponent)
      if fieldBoost != 1 || overlayBoost != 1
        if fieldBoost > 1 && overlayBoost > 1
          boost = [fieldBoost, overlayBoost].max
          comboboost = move.calculateFieldMultiplier(1.5)
          boost = comboboost if boost < comboboost
        else
          boost = fieldBoost * overlayBoost
        end
        basemult.append(boost)
      end
      case @battle.FE
        when :CHESS
          if PBFields::CHESSMOVES.include?(move.move)
            basemult.append(0.5) if [:ADAPTABILITY, :ANTICIPATION, :SYNCHRONIZE, :TELEPATHY].include?(opponent.ability)
            basemult.append(2.0) if [:OBLIVIOUS, :KLUTZ, :UNAWARE, :SIMPLE].include?(opponent.ability) || opponent.effects[:Confusion] > 0 || (Rejuv && opponent.ability == :DEFEATIST)
          end
          # Queen piece boost
          if attacker.piece == :QUEEN || attacker.ability == :QUEENLYMAJESTY
            basemult.append(1.5)
          end
          # Knight piece boost
          if attacker.piece == :KNIGHT && opponent.piece == :QUEEN
            basemult.append(3.0)
          end
        when :BIGTOP
          if (type == :FIGHTING && move.pbIsPhysical?(attacker, type)) || PBFields::STRIKERMOVES.include?(move.move)
            provimult = @battle.field.getRoll(maximize_roll: [:HUGEPOWER, :GUTS, :PUREPOWER, :SHEERFORCE].include?(attacker.ability), rollmodifier: attacker.stages[PBStats::ATTACK])
            provimult = move.calculateFieldMultiplier(provimult)
            basemult.append(provimult)
          end
        when :SHORTCIRCUIT
          if type == :ELECTRIC
            damageroll = @battle.field.getRoll(maximize_roll: @battle.OV == :ELECTERRAIN)
            damageroll = move.calculateFieldMultiplier(damageroll)
            basemult.append(damageroll)
          end
        when :MOUNTAIN, :SNOWYMOUNTAIN
          if weather == :STRONGWINDS && (move.windMove? || (type == :FLYING && move.pbIsSpecial?(attacker, type)))
            provimult = move.calculateFieldMultiplier(1.5)
            basemult.append(provimult)
          end
        when :MIRROR
          if PBFields::MIRRORMOVES.include?(move.move) && opponent.stages[PBStats::EVASION] > 0
            provimult = move.calculateFieldMultiplier(2.0)
            basemult.append(provimult)
          end
        when :DEEPEARTH
          if move.priorityCheck(attacker) > 0
            provimult = move.calculateFieldMultiplier(0.7)
            basemult.append(provimult)
          end
          if move.priorityCheck(attacker) < 0
            provimult = move.calculateFieldMultiplier(1.3)
            basemult.append(provimult)
          end
      end
      if Overlays
        if @battle.OV
          overlaymult = move.moveOverlayBoost
          if overlaymult != 1
            basemult.append(overlaymult)
          end
        end
      end
    end
    basemult.append(1.5) if [:PIERCINGDRILL, :UNSEENFIST].include?(attacker.ability) && opponent.isbossmon
    # Crests (Medium Skill, but special)
    if @mondata.skill >= MEDIUMSKILL
      case attacker.crested
        when :LEDIAN        then basemult.append(4.0) if move.punchMove?
        when :CINCCINO      then basemult.append(attacker.ability == :SKILLLINK ? 2 : 1.24) if attacker.effects[:CincCrest] && multihitcheck # 1.5 from 5 hits at 0.3x power, 0.93 from 3.1 hits at 0.3x (2-5 hit average is 3.1 hits)
        when :FERALIGATR    then basemult.append(1.5) if move.bitingMove?
        when :CLAYDOL       then basemult.append(1.5) if move.isBeamMove?
        when :DRUDDIGON     then basemult.append(1.3) if type == :DRAGON || type == :FIRE
        when :BOLTUND       then basemult.append(1.5) if move.bitingMove? && pbAIfaster?(move, nil, attacker, opponent)
        when :FEAROW        then basemult.append(1.5) if PBStuff::STABBINGMOVE.include?(move.move)
        when :DUSKNOIR      then basemult.append(1.5) if basedmg <= 60 || (@mondata.skill >= BESTSKILL && (@battle.FE == :FACTORY || @battle.ProgressiveFieldCheck(PBFields::CONCERT)) && basedmg <= 80)
        when :CRABOMINABLE  then basemult.append(1.5) if !pbAIfaster?(move, nil, attacker, opponent)
        when :AMPHAROS      then basemult.append(attacker.hasType?(type) ? 1.2 : 1.5) if attacker.moves[0] == move
        when :LUXRAY        then basemult.append(1.2) if move.type == :NORMAL && type == :ELECTRIC
        when :SAWSBUCK
          case attacker.form
            when 0 then basemult.append(1.2) if move.type == :NORMAL && type == :WATER
            when 1 then basemult.append(1.2) if move.type == :NORMAL && type == :FIRE
            when 2 then basemult.append(1.2) if move.type == :NORMAL && type == :GROUND
            when 3 then basemult.append(1.2) if move.type == :NORMAL && type == :ICE
          end
      end
    end

    ##### Apply Base Power modifiers to the move's Base Power #####
    basedmg = basedmg.chainMods(basemult).pokeRound.pokeClamp
    basedmg = 60 if attacker.isTerastallized? && basedmg < 60 && move.pbType(attacker) == attacker.types.first && !move.pbIsMultiHit && move.priority <= 0

    ##### Stat Collection Setup #####
    # check for Aegislash
    if attacker.species == :AEGISLASH
      dummymon = pbAegislashStats(attacker)
      dummymon.pbUpdate(fakebattler: true)
    else
      dummymon = attacker
    end
    # for safety only use the aegislash dummy for getting stats and their stages, any other checks should if possible use the attacker directly
    # the copy in question is shallow and accuracy is only guaranteed for stats and stat stages

    moldBrokenArray = getMoldBrokenArray(attacker, opponent, move)
    oppUnaware = opponent.ability == :UNAWARE && !moldBreakerCheck(attacker, opponent, move)
    onlyModifiers = move.function == 0x121 # Foul Play
    attUnaware = attacker.ability == :UNAWARE
    attackerUseSpDef = @battle.FE == :GLITCH && dummymon.changeSpecialStat(unaware: oppUnaware, crit: critmult == 1.5, attacker: true, moldBrokenArray: moldBrokenArray, onlyModifiers: onlyModifiers)
    defenderUseSpAtk = @battle.FE == :GLITCH && opponent.changeSpecialStat(unaware: attUnaware, crit: critmult == 1.5, attacker: false, moldBrokenArray: moldBrokenArray)

    ##### Attack Modifiers #####
    atkmult = []
    # Attack Abilities, Items, and Misc Stuff (Medium Skill)
    if @mondata.skill >= MEDIUMSKILL
      # Most Abilities
      ruinmod = 0.75
      ruinmod = 0.667 if @battle.FE == :NEWWORLD
      ruinmod = 0.875 if @battle.FE == :HOLY
      if move.pbIsSpecial?(attacker, type) && attackerUseSpDef
        for abilityholder in aiCheckSideAbility(:FLOWERGIFT, attacker, attacker, opponent)
          atkmult.append(1.5) if abilityholder.flowerGiftActive?
        end
        atkmult.append(1.3) if attacker.ability == :QUARKDRIVE && attacker.effects[:Quarkdrive][0] == PBStats::SPDEF
        atkmult.append(1.3) if attacker.ability == :PROTOSYNTHESIS && attacker.effects[:Protosynthesis][0] == PBStats::SPDEF
        atkmult.append(ruinmod) if !attacker.wonderroom && aiCheckGlobalAbility(:BEADSOFRUIN, attacker, opponent) && attacker.ability != :BEADSOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && attacker.pbPartner.ability == :BEADSOFRUIN)
        atkmult.append(ruinmod) if attacker.wonderroom && aiCheckGlobalAbility(:SWORDOFRUIN, attacker, opponent) && attacker.ability != :SWORDOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && attacker.pbPartner.ability == :SWORDOFRUIN)
        # Sandstorm is applied directly to the attacking stat further down
      elsif move.pbIsSpecial?(attacker, type) && !attackerUseSpDef
        atkmult.append(0.5) if attacker.ability == :DEFEATIST && attacker.hp <= (attacker.totalhp / 2.0).floor
        atkmult.append(1.5) if (attacker.ability == :SOLARPOWER || (attacker.crested == :CASTFORM && attacker.form == 1)) && weather == :SUNNYDAY && !(attacker.hasWorkingItem(:UTILITYUMBRELLA) || (@mondata.skill >= BESTSKILL && @battle.FE == :FROZENDIMENSION))
        atkmult.append(1.5) if attacker.ability == :LUNARIDOL && [:HAIL, :SNOW].include?(weather)
        atkmult.append(2.0) if attacker.ability == :PUREPOWER && (@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN) && @mondata.skill >= BESTSKILL
        if [:PLUS, :MINUS].include?(attacker.ability) || [:PLUSLE, :MINUN].include?(attacker.crested)
          if [:PLUS, :MINUS].include?(attacker.pbPartner.ability) || (@mondata.skill >= BESTSKILL && @battle.FE == :SHORTCIRCUIT) || (@mondata.skill >= BESTSKILL && Rejuv && (@battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN)) || (attacker.crested == :MINUN && attacker.ability == :MINUS) ||
          (attacker.crested == :PLUSLE && attacker.ability == :PLUS)
            atkmult.append(1.5)
          end
        end
        for abilityholder in aiCheckSideAbility(:FLOWERGIFT, attacker, attacker, opponent)
          atkmult.append(1.5) if abilityholder.crested == :CHERRIM && abilityholder.flowerGiftActive?
        end
        atkmult.append(1.3) if attacker.ability == :QUARKDRIVE && attacker.effects[:Quarkdrive][0] == PBStats::SPATK
        atkmult.append(1.3) if attacker.ability == :PROTOSYNTHESIS && attacker.effects[:Protosynthesis][0] == PBStats::SPATK
        atkmult.append(PBMults::ParadoxLeads) if attacker.ability == :HADRONENGINE && (@battle.FE == :NEWWORLD || @battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN)
        atkmult.append(ruinmod) if aiCheckGlobalAbility(:VESSELOFRUIN, attacker, opponent) && attacker.ability != :VESSELOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && attacker.pbPartner.ability == :VESSELOFRUIN)
      elsif move.pbIsPhysical?(attacker, type)
        for abilityholder in aiCheckSideAbility(:FLOWERGIFT, attacker, attacker, opponent)
          atkmult.append(1.5) if abilityholder.flowerGiftActive?
        end
        atkmult.append(0.5) if attacker.ability == :SLOWSTART && attacker.effects[:SlowStart] < 5 && !(@mondata.skill >= BESTSKILL && @battle.FE == :DEEPEARTH)
        atkmult.append(0.5) if attacker.ability == :DEFEATIST && attacker.hp <= (attacker.totalhp / 2.0).floor
        atkmult.append(1.5) if attacker.ability == :GUTS && !attacker.status.nil?
        atkmult.append(2.0) if attacker.ability == :HUGEPOWER
        atkmult.append(2.0) if attacker.ability == :PUREPOWER && (@mondata.skill < BESTSKILL || !(@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN))
        atkmult.append(1.5) if attacker.ability == :GORILLATACTICS
        atkmult.append(1.33) if aiCheckSideCrest(:PLUSLE, attacker, attacker, opponent, move, excludeSelf: false).any?
        atkmult.append(1.5) if attacker.ability == :SOLARIDOL && weather == :SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
        atkmult.append(1.3) if attacker.ability == :QUARKDRIVE && attacker.effects[:Quarkdrive][0] == PBStats::ATTACK
        atkmult.append(1.3) if attacker.ability == :PROTOSYNTHESIS && attacker.effects[:Protosynthesis][0] == PBStats::ATTACK
        atkmult.append(PBMults::ParadoxLeads) if attacker.ability == :ORICHALCUMPULSE && (weather == :SUNNYDAY || @battle.FE == :NEWWORLD)
        atkmult.append(ruinmod) if aiCheckGlobalAbility(:TABLETSOFRUIN, attacker, opponent) && attacker.ability != :TABLETSOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && attacker.pbPartner.ability == :TABLETSOFRUIN)
      end
      atkmult.append(2.0) if attacker.ability == :STAKEOUT && @battle.switchedOut[opponent.index]
      atkmult.append((@mondata.skill >= BESTSKILL && @battle.FE == :FACTORY ? 2.0 : 1.5)) if attacker.ability == :STEELWORKER && type == :STEEL
      atkmult.append(1.5) if attacker.item == :SOULDEW  && type == :DARK && [:LATIOS,:LATIAS].include?(attacker.pokemon.species) && PBStuff::DimensionalFields.include?(@battle.FE)
      atkmult.append(@mondata.skill >= BESTSKILL && @battle.FE == :ROCKY ? 2.0 : Rejuv && [:MOUNTAIN, :VOLCANICTOP, :SNOWYMOUNTAIN].include?(@battle.FE) ? 2.0 : 1.5) if attacker.ability == :ROCKYPAYLOAD && type == :ROCK
      atkmult.append(@mondata.skill >= BESTSKILL && [:SUPERHEATED, :BURNING, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@battle.FE) ? 2.0 : 1.5) if attacker.ability == :FIREMANE && type == :FIRE
      atkmult.append(@mondata.skill >= BESTSKILL && @battle.FE == :ELECTERRAIN ? (Gen >= 9 ? 1.6 : 2.0) : (Gen >= 9 ? 1.3 : 1.5)) if attacker.ability == :TRANSISTOR && type == :ELECTRIC
      atkmult.append(@mondata.skill >= BESTSKILL && @battle.FE == :DRAGONSDEN ? 2.0 : 1.5) if attacker.ability == :DRAGONSMAW && type == :DRAGON
      # Pinch Abilities are special
      if @mondata.skill >= BESTSKILL
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
          if (attacker.ability == :OVERGROW && type == :GRASS) || (attacker.ability == :BLAZE && type == :FIRE && @battle.FE != :FROZENDIMENSION) || (attacker.ability == :TORRENT && type == :WATER) || (attacker.ability == :SWARM && type == :BUG)
            atkmult.append(1.5)
          end
        end
      elsif attacker.hp <= (attacker.totalhp / 3.0).floor
        if (attacker.ability == :OVERGROW && type == :GRASS) || (attacker.ability == :BLAZE && type == :FIRE) || (attacker.ability == :TORRENT && type == :WATER) || (attacker.ability == :SWARM && type == :BUG)
          atkmult.append(1.5)
        end
      end
      # Items
      if attitemworks
        if !attackerUseSpDef && move.pbIsSpecial?(attacker, type)
          case attacker.item
            when :GENIUSWING then atkmult.append(1.1) if @mondata.skill >= BESTSKILL && @battle.FE == :CLOUDS
            when :CHOICESPECS then atkmult.append(1.5)
            when :LIGHTBALL then atkmult.append(2.0) if attacker.pokemon.species == :PIKACHU
            when :DEEPSEATOOTH then atkmult.append(2.0) if attacker.pokemon.species == :CLAMPERL
          end
        elsif move.pbIsPhysical?(attacker, type)
          case attacker.item
            when :MUSCLEWING then atkmult.append(1.1) if @mondata.skill >= BESTSKILL && @battle.FE == :CLOUDS
            when :CHOICEBAND then atkmult.append(1.5)
            when :LIGHTBALL then atkmult.append(2.0) if attacker.pokemon.species == :PIKACHU
            when :THICKCLUB then atkmult.append(2.0) if [:CUBONE, :MAROWAK].include?(attacker.pokemon.species)
          end
        end
        atkmult.append(1.1) if attacker.hasWorkingItem(:PUNCHINGGLOVE) && move.punchMove?
      end
      # Misc
      atkmult.append(1.5) if attacker.effects[:FlashFire] && type == :FIRE && !(@mondata.skill >= BESTSKILL && @battle.FE == :FROZENDIMENSION)
      atkmult.append(1.5) if attacker.ability == :WILDFIRE && (opponent.status == :BURN  || @battle.FE == :INFERNAL)
      atkmult.append(1.5) if attacker.effects[:CoalFurnace] && type == :FIRE && !(@mondata.skill >= BESTSKILL && @battle.FE == :FROZENDIMENSION)
      atkmult.append(2.0) if type == :WATER && attacker.ability == :WATERBUBBLE
      if oppitemworks && opponent.item == :NEVERMELTICE && (@battle.state.effects[:NeverMeltIce] || @battle.FE == :FROZENDIMENSION) && type == :FIRE
        atkmult.append(0.66)
      end
      # Opponent Abilities
      if !moldBreakerCheck(attacker, opponent, move)
        atkmult.append(0.5) if type == :FIRE && opponent.ability == :WATERBUBBLE
        atkmult.append(0.5) if opponent.ability == :THICKFAT && [:ICE, :FIRE].include?(type)
        atkmult.append(0.5) if opponent.ability == :HEATPROOF && type == :FIRE && Gen >= 9
        atkmult.append(0.5) if opponent.ability == :PURIFYINGSALT && type == :GHOST
      end
      # Partner Abilities
      for partner in aiCheckSideAbility(:POWERSPOT, attacker, attacker, opponent, excludeSelf: true)
        (@mondata.skill >= BESTSKILL && [:HAUNTED, :BEWITCHED, :HOLY, :PSYTERRAIN, :DEEPEARTH, :DEUXFINALIS].include?(@battle.FE)) ? atkmult.append(1.5) : atkmult.append(1.3)
      end
      for abilityholder in aiCheckSideAbility(:STEELYSPIRIT, attacker, attacker, opponent)
        (@mondata.skill >= BESTSKILL && @battle.FE == :FAIRYTALE) ? atkmult.append(2.0) : atkmult.append(1.5) if type == :STEEL
      end
      # Mid Battle stat multiplying crests; Spiritomb Crest
      if attacker.crested == :SPIRITOMB
        allyfainted = attacker.pbFaintedPokemonCount
        modifier = (allyfainted * 0.2) + 1.0
        atkmult.append(modifier)
      end
    end
    # Items + Glitch Field (High Skill)
    if @mondata.skill >= HIGHSKILL && attitemworks
      if attackerUseSpDef && move.pbIsSpecial?(attacker, type)
        atkmult.append(1.5) if attacker.evioliteActive?
        case attacker.item
          when :CLEVERWING then atkmult.append(1.1) if @mondata.skill >= BESTSKILL && @battle.FE == :CLOUDS
          when :ASSAULTVEST then atkmult.append(1.5)
          when :DEEPSEASCALE then atkmult.append(2.0) if attacker.pokemon.species == :CLAMPERL
        end
      end
    end
    # Field-Excusive Checks (Best Skill)
    if @mondata.skill >= BESTSKILL
      if @battle.FE != :INDOOR
        if [:STARLIGHT, :NEWWORLD].include?(@battle.FE)
          for abilityholder in aiCheckSideAbility(:VICTORYSTAR, attacker, attacker, opponent)
            atkmult.append(1.5)
          end
        end
        if [:WATERSURFACE, :UNDERWATER].include?(@battle.FE)
          atkmult.append(1.5) if attacker.ability == :PROPELLERTAIL && move.priority >= 1
        end
        if Rejuv && @battle.FE == :CHESS
          atkmult.append(1.2) if attacker.ability == :GORILLATACTICS || attacker.ability == :RECKLESS
          atkmult.append(1.2) if Rejuv && attacker.effects[:Illusion] && !illusionDeceived?(@attacker, attacker) # damage boost based on active illusion, illusionDeceived? to see if the AI is aware of the illusion
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
        atkmult.append(0.5) if move.pbIsPhysical?(attacker, type) && @battle.FE == :UNDERWATER && (!Rejuv || !attacker.hasType?(:WATER)) && type != :WATER && !(move.getSecondaryType(attacker, type).include?(:WATER)) && ![:EELEVATE, :STEELWORKER, :SWIFTSWIM].include?(attacker.ability)
      end
      case attacker.ability
        when :QUEENLYMAJESTY then atkmult.append(1.5) if @battle.FE == :FAIRYTALE
        when :LONGREACH then atkmult.append(1.5) if [:MOUNTAIN, :SNOWYMOUNTAIN, :SKY].include?(@battle.FE)
        when :CORROSION then atkmult.append(1.5) if [:CORROSIVE, :CORROSIVEMIST, :CORRUPTED].include?(@battle.FE)
        when :SKILLLINK then atkmult.append(1.2) if @battle.FE == :COLOSSEUM && (move.function == 0xC0 || move.function == 0x307 || (attacker.crested == :CINCCINO && attacker.effects[:CincCrest])) # 0xC0: 2-5 hits; 0x307: Scale Shot
        when :PURIFYINGSALT then atkmult.append(1.5) if @battle.FE == :HOLY
      end
    end

    ##### Calculate attacker's attack stat #####
    if move.pbIsSpecial?(attacker, type)
      case move.function
        when 0x121 # Foul Play
          atkstage = opponent.crested == :CLAYDOL ? opponent.stages[PBStats::DEFENSE] + 6 : opponent.stages[PBStats::SPATK] + 6
          if @battle.FE == :GLITCH
            targetHighSpdef = opponent.spdef * PBStats::StageMul[opponent.stages[PBStats::SPDEF] + 6] > opponent.spatk * PBStats::StageMul[atkstage]
            atk = targetHighSpdef ? opponent.spdef : opponent.spatk
            atkstage = opponent.stages[PBStats::SPDEF] + 6 if targetHighSpdef
          else
            atk = opponent.spatk
          end
        when 0x184 # Body Press
          if @battle.FE == :GLITCH
            atk = attackerUseSpDef ? dummymon.spdef : dummymon.spatk
            atkstage = attackerUseSpDef ? dummymon.stages[PBStats::SPDEF] + 6 : dummymon.stages[PBStats::SPATK] + 6
            atkstage = dummymon.stages[PBStats::DEFENSE] + 6 if attacker.crested == :CLAYDOL && !attackerUseSpDef
          else
            atk = dummymon.spdef
            atkstage = dummymon.stages[PBStats::SPDEF] + 6
          end
        else
          atk = attackerUseSpDef ? dummymon.spdef : dummymon.spatk
          atkstage = attackerUseSpDef ? dummymon.stages[PBStats::SPDEF] + 6 : dummymon.stages[PBStats::SPATK] + 6
          atkstage = dummymon.stages[PBStats::DEFENSE] + 6 if attacker.crested == :CLAYDOL && !attackerUseSpDef
      end
    else
      case move.function
        when 0x121 # Foul Play
          atk = opponent.attack
          atkstage = opponent.crested == :DEDENNE ? opponent.stages[PBStats::SPEED] + 6 : opponent.stages[PBStats::ATTACK] + 6
        when 0x184 # Body Press
          atk = dummymon.defense
          atkstage = dummymon.stages[PBStats::DEFENSE] + 6
        else
          atk = dummymon.attack
          atkstage = attacker.crested == :DEDENNE ? dummymon.stages[PBStats::SPEED] + 6 : dummymon.stages[PBStats::ATTACK] + 6
      end
    end

    if attacker.crested == :FLYGON && move.checkSoundMove?(attacker)
      atk = attacker.attack
      atkstage = attacker.stages[PBStats::ATTACK] + 6
    end

    atk = atk.floor # catchall for crests/items that interact with unaware which wouldn't go through the attUnaware/OppUnaware segments
    ##### Apply Attack modifiers to the attacker's Attack stat #####
    unless oppUnaware
      atkstage = 6 if pbCritRateAI?(attacker, opponent, move) > 2 && atkstage < 6 && @mondata.skill >= MEDIUMSKILL
      atk = (atk * PBStats::StageMul[atkstage]).floor
    end
    if attacker.ability == :HUSTLE && move.pbIsPhysical?(attacker, type) && @mondata.skill >= HIGHSKILL
      atk = [:BACKALLEY, :CITY].include?(@battle.FE) ? (atk * 1.75).floor : (atk * 1.5).floor
    end
    atk = (atk * 1.5).floor if move.pbIsSpecial?(attacker, type) && attackerUseSpDef && weather == :SANDSTORM && attacker.hasType?(:ROCK) && @mondata.skill >= HIGHSKILL
    atk = atk.chainMods(atkmult).pokeRound.pokeClamp

    ##### Defense Modifiers #####
    defmult = []
    # Defense Abilities, Items, and Misc Stuff (Medium Skill)
    if @mondata.skill >= MEDIUMSKILL
      # Most Abilities
      ruinmod = 0.75
      ruinmod = 0.667 if @battle.FE == :NEWWORLD
      ruinmod = 0.875 if @battle.FE == :HOLY
      if move.pbHitsSpecialStat?(attacker, type) && defenderUseSpAtk
        defmult.append(0.5) if opponent.ability == :DEFEATIST && opponent.hp <= (opponent.totalhp / 2.0).floor
        unless moldBreakerCheck(attacker, opponent, move)
          defmult.append(1.5) if (opponent.ability == :SOLARPOWER || (opponent.crested == :CASTFORM && opponent.form == 1)) && weather == :SUNNYDAY && !(opponent.hasWorkingItem(:UTILITYUMBRELLA) || (@mondata.skill >= BESTSKILL && @battle.FE == :FROZENDIMENSION))
          defmult.append(1.5) if opponent.ability == :LUNARIDOL && [:HAIL, :SNOW].include?(weather)
          defmult.append(2.0) if opponent.ability == :PUREPOWER && @mondata.skill >= BESTSKILL && (@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN)
          if [:PLUS, :MINUS].include?(opponent.ability) || [:PLUSLE, :MINUN].include?(opponent.crested)
            if [:PLUS, :MINUS].include?(opponent.pbPartner.ability) || (@mondata.skill >= BESTSKILL && @battle.FE == :SHORTCIRCUIT) || (@mondata.skill >= BESTSKILL && (Rejuv && (@battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN))) || (opponent.crested == :MINUN && opponent.ability == :MINUS) ||
              (opponent.crested == :PLUSLE && opponent.ability == :PLUS)
              defmult.append(1.5)
            end
          end
          defmult.append(PBMults::ParadoxLeads) if opponent.ability == :HADRONENGINE && (@battle.FE == :NEWWORLD || @battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN)
        end
        defmult.append(1.3) if opponent.ability == :QUARKDRIVE && opponent.effects[:Quarkdrive][0] == PBStats::SPATK
        defmult.append(1.3) if opponent.ability == :PROTOSYNTHESIS && opponent.effects[:Protosynthesis][0] == PBStats::SPATK
        defmult.append(ruinmod) if aiCheckGlobalAbility(:VESSELOFRUIN, attacker, opponent) && opponent.ability != :VESSELOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && opponent.pbPartner.ability == :VESSELOFRUIN)
      elsif move.pbHitsSpecialStat?(attacker, type) && !defenderUseSpAtk
        for abilityholder in aiCheckSideAbility(:FLOWERGIFT, opponent, attacker, opponent, move, checkMoldBroken: true)
          defmult.append(1.5) if abilityholder.flowerGiftActive?
        end
        defmult.append(1.3) if opponent.ability == :QUARKDRIVE && opponent.effects[:Quarkdrive][0] == PBStats::SPDEF
        defmult.append(1.3) if opponent.ability == :TABLETSOFRUIN && attacker.status == :PETRIFIED && @battle.FE == :DEUXFINALIS
        defmult.append(1.3) if opponent.ability == :PROTOSYNTHESIS && opponent.effects[:Protosynthesis][0] == PBStats::SPDEF
        defmult.append(ruinmod) if !opponent.wonderroom && aiCheckGlobalAbility(:BEADSOFRUIN, attacker, opponent) && opponent.ability != :BEADSOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && opponent.pbPartner.ability == :BEADSOFRUIN)
        defmult.append(ruinmod) if opponent.wonderroom && aiCheckGlobalAbility(:SWORDOFRUIN, attacker, opponent) && opponent.ability != :SWORDOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && opponent.pbPartner.ability == :SWORDOFRUIN)
      elsif move.pbHitsPhysicalStat?(attacker, type)
        unless moldBreakerCheck(attacker, opponent, move)
          defmult.append(1.5) if opponent.ability == :MARVELSCALE && (!opponent.status.nil? || (@mondata.skill >= BESTSKILL && ([:MISTY, :RAINBOW, :FAIRYTALE, :DRAGONSDEN, :STARLIGHT, :DEUXFINALIS].include?(@battle.FE) || @battle.OV == :MISTY)))
          defmult.append(2.0) if opponent.ability == :FURCOAT
          defmult.append(1.5) if opponent.ability == :GRASSPELT && ((@battle.FE == :GRASSY || @battle.OV == :GRASSY) || (@battle.FE == :FOREST && @mondata.skill >= BESTSKILL)) # Grassy Field
        end
        for abilityholder in aiCheckSideAbility(:FLOWERGIFT, opponent, attacker, opponent, move, checkMoldBroken: true)
          defmult.append(1.5) if abilityholder.crested == :CHERRIM && abilityholder.flowerGiftActive?
        end
        defmult.append(1.3) if opponent.ability == :QUARKDRIVE && opponent.effects[:Quarkdrive][0] == PBStats::DEFENSE
        defmult.append(1.3) if opponent.ability == :VESSELOFRUIN && attacker.status == :PETRIFIED && @battle.FE == :DEUXFINALIS
        defmult.append(1.3) if opponent.ability == :PROTOSYNTHESIS && opponent.effects[:Protosynthesis][0] == PBStats::DEFENSE
        defmult.append(ruinmod) if opponent.wonderroom && aiCheckGlobalAbility(:BEADSOFRUIN, attacker, opponent) && opponent.ability != :BEADSOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && opponent.pbPartner.ability == :BEADSOFRUIN)
        defmult.append(ruinmod) if !opponent.wonderroom && aiCheckGlobalAbility(:SWORDOFRUIN, attacker, opponent) && opponent.ability != :SWORDOFRUIN && !(PBStuff::DimensionalFields.include?(@battle.FE) && opponent.pbPartner.ability == :SWORDOFRUIN)
      end
      unless moldBreakerCheck(attacker, opponent, move)
        case opponent.ability
          when :PUNKROCK, :JUNGLEBEAT then defmult.append(2.0) if move.checkSoundMove?(attacker)
          # unlike fur coat ice scales reduces the damage of special attacks instead of increasing the special defense
          # the difference here is that ice scales applies to psyshock despite it targeting phys def
          when :ICESCALES then defmult.append(2.0) if move.pbIsSpecial?(attacker, type)
        end
      end
      # Simple Items
      if oppitemworks
        if move.pbHitsSpecialStat?(attacker, type) && defenderUseSpAtk
          defmult.append(1.1) if opponent.hasWorkingItem(:GENIUSWING) && @mondata.skill >= BESTSKILL && @battle.FE == :CLOUDS
        elsif move.pbHitsSpecialStat?(attacker, type)
          defmult.append(1.1) if opponent.hasWorkingItem(:CLEVERWING) && @mondata.skill >= BESTSKILL && @battle.FE == :CLOUDS
          defmult.append(1.5) if opponent.evioliteActive?
          defmult.append(1.5) if opponent.hasWorkingItem(:ASSAULTVEST)
          defmult.append(2.0) if opponent.hasWorkingItem(:DEEPSEASCALE) && opponent.pokemon.species == :CLAMPERL
        elsif move.pbHitsPhysicalStat?(attacker, type)
          defmult.append(1.1) if opponent.hasWorkingItem(:RESISTWING) && @mondata.skill >= BESTSKILL && @battle.FE == :CLOUDS
          defmult.append(1.5) if opponent.evioliteActive?
          defmult.append(2.0) if opponent.hasWorkingItem(:METALPOWDER) && opponent.pokemon.species == :DITTO && !opponent.effects[:Transform]
          defmult.append(0.5) if attacker.crested == :ELECTRODE
        end
      end
    end
    # Glitch Field Stuff (High Skill)
    if @mondata.skill >= HIGHSKILL
      defmult.append(0.5) if @battle.FE == :GLITCH && move.function == 0xE0 # Explosion
      if oppitemworks
        if move.pbHitsSpecialStat?(attacker, type) && defenderUseSpAtk
          defmult.append(1.5) if opponent.hasWorkingItem(:CHOICESPECS)
          defmult.append(2.0) if opponent.hasWorkingItem(:DEEPSEATOOTH) && opponent.pokemon.species == :CLAMPERL
          defmult.append(2.0) if opponent.hasWorkingItem(:LIGHTBALL) && opponent.pokemon.species == :PIKACHU
        end
      end
    end


    # Field Effects (Best Skill)
    if @mondata.skill >= BESTSKILL
      category = move.pbHitsSpecialStat?(attacker, type) ? :special : (move.pbHitsPhysicalStat?(attacker, type) ? :physical : nil)
      defmult.append(opponent.fieldDefenseBoost(attacker, category))
    end

    ##### Calculate opponent's defense stat #####
    defense = opponent.defense.floor # catchall for crests/items that interact with unaware which wouldn't go through the attUnaware/OppUnaware segments
    defstage = opponent.stages[PBStats::DEFENSE] + 6

    applysandstorm = false
    applysnow = true
    if move.pbHitsSpecialStat?(attacker, type)
      defense = opponent.spdef
      defstage = opponent.stages[PBStats::SPDEF] + 6
      applysandstorm = true
      applysnow = false
      if defenderUseSpAtk
        defense = opponent.spatk
        defstage = opponent.stages[PBStats::SPATK] + 6
        applysandstorm = false
      end
    end

    ##### Apply Defense modifiers to the opponent's Defense stat #####
    unless attUnaware
      defstage = 6 if [0xA9, 0x80F].include?(move.function) # Chip Away (ignore stat stages)
      defstage = 6 if pbCritRateAI?(attacker, opponent, move) > 2 && defstage > 6 && @mondata.skill >= MEDIUMSKILL
      defense = (defense * PBStats::StageMul[defstage]).floor
    end
    if weather == :SANDSTORM && opponent.hasType?(:ROCK) && applysandstorm && @mondata.skill >= MEDIUMSKILL
      defense = (defense * 1.5).floor
    end
    if weather == :SNOW && opponent.hasType?(:ICE) && applysnow && @mondata.skill >= MEDIUMSKILL
      defense = (defense * 1.5).floor
    end
    defense = defense.chainMods(defmult).pokeRound.pokeClamp

    ##### Damage Modifiers #####
    finalmult = []
    secondtypes = move.getSecondaryType(attacker, type)

    # Screens and Misc (High Skill)
    if @mondata.skill >= HIGHSKILL
      if pbCritRateAI?(attacker, opponent, move) <= 2 && attacker.ability != :INFILTRATOR && ![0x10A, 0x512, 0x80A].include?(move.function) # Brick Break, Raging Bull, Unleashed Power
        # Screens
        finalmult.append(@battle.doublebattle ? PBMults::ScreenDoubles : 0.5) if opponent.pbOwnSide.screenActive?(move.betterCategory(attacker, type))
        finalmult.append(0.5) if opponent.pbOwnSide.effects[:AreniteWall] > 0 && typemod.superEffective?
        finalmult.append(0.5) if opponent.pbOwnSide.effects[:AntiMatterShield] != 0 && attacker.makesContact?(move)
      end
      finalmult.append(PBMults::Metronome[[attacker.effects[:Metronome], 5].min]) if @battle.FE == :CONCERT4 && move.move == attacker.lastMoveUsed # Leaving this as high skill cause it's Rejuv stuff
    end

    # Most Abilities, Items, and Misc (Medium Skill)
    if @mondata.skill >= MEDIUMSKILL
      finalmult.append(PBMults::ParadoxLeads) if move.function == 0x515 && typemod.superEffective? # Collision Course / Electro Drift

      # Abilities
      finalmult.append(1.25) if attacker.ability == :NEUROFORCE && typemod.superEffective?
      finalmult.append(1.5) if attacker.ability == :SNIPER && pbCritRateAI?(attacker, opponent, move) > 2
      finalmult.append(2.0) if attacker.ability == :TINTEDLENS && typemod.resisted?
      if opponent.ability == :FLUFFY && !moldBreakerCheck(attacker, opponent, move)
        finalmult.append((@mondata.skill >= BESTSKILL && @battle.FE == :CLOUDS) ? 0.25 : 0.5) if attacker.makesContact?(move)
        finalmult.append(2.0) if type == :FIRE
      end
      if opponent.ability == :AURAGUARD && !moldBreakerCheck(attacker, opponent, move)
        finalmult.append(0.5) if attacker.makesContact?(move)
      end
      finalmult.append(0.5) if opponent.ability == :MULTISCALE && !moldBreakerCheck(attacker, opponent, move) && opponent.hp == opponent.totalhp
      finalmult.append((@mondata.skill >= BESTSKILL && [:DARKNESS2, :DARKNESS3].include?(@battle.FE)) ? 0.33 : 0.5) if opponent.ability == :SHADOWSHIELD && (opponent.hp == opponent.totalhp || (@mondata.skill >= BESTSKILL && @battle.FE == :DIMENSIONAL))
      finalmult.append(0.75) if opponent.ability == :SHADOWSHIELD && @mondata.skill >= BESTSKILL && [:STARLIGHT, :NEWWORLD, :DARKCRYSTALCAVERN].include?(@battle.FE) && typemod.superEffective?
      finalmult.append(0.75) if (((opponent.ability == :SOLIDROCK || opponent.ability == :FILTER) && !moldBreakerCheck(attacker, opponent, move)) || opponent.ability == :PRISMARMOR) && typemod.superEffective?
      finalmult.append(0.75) if aiCheckSideAbility(:FRIENDGUARD, opponent, attacker, opponent, move, excludeSelf: true, checkMoldBroken: true).any?
      finalmult.append(0.5) if aiCheckSideAbility(:QUAKEPROOF, opponent, attacker, opponent, move, checkMoldBroken: true).any? && type == :GROUND
      finalmult.append(0.75) if aiCheckSideAbility(:EXTRAFLUFFYMANE, opponent, attacker, opponent, move, checkMoldBroken: true).any?
      finalmult.append(0.75) if aiCheckSideCrest(:MINUN, attacker, attacker, opponent, move).any? && !move.pbHitsSpecialStat?(attacker, type)
      finalmult.append(1.5) if aiCheckSideCrest(:FLYGON, attacker, attacker, opponent, move).any? && move.checkSoundMove?(attacker)
      finalmult.append(@mondata.skill >= BESTSKILL && [:BIGTOP, :CAVE].include?(@battle.FE) ? 1.5 : 1.3) if [:PUNKROCK, :JUNGLEBEAT].include?(attacker.ability) && move.checkSoundMove?(attacker)
      finalmult.append(1.5) if aiCheckSideCrest(:FLYGON, attacker, attacker, opponent, move, excludeSelf: false).any? && move.checkSoundMove?(attacker)
      finalmult.append(2.0) if attacker.ability == :EXECUTION && opponent.hp <= (opponent.totalhp / 2).floor

      # Items
      finalmult.append(PBMults::Metronome[[attacker.effects[:Metronome], 5].min]) if attitemworks && attacker.item == :METRONOME && move.move == attacker.lastMoveUsed
      finalmult.append(1.2) if attitemworks && attacker.item == :EXPERTBELT && typemod.superEffective?
      finalmult.append(PBMults::RootOrb) if attitemworks && attacker.item == :LIFEORB # approx. 1.3x
      # The AI is always aware of opponents' items, but we make an exception for type berries
      if !ai_mon_attacking || opponent.permeffs[:ItemDisclosure] || omniscience?
        if oppitemworks && type == $cache.items[opponent.item].berry&.resisttype &&
           (type == :NORMAL || typemod.superEffective?) &&
           aiCheckSideAbility(PBStuff::UnnerveAbilities, opponent.pbOpposing1, attacker, opponent).none? &&
           !move.blockedBySubstitute?(attacker, opponent)
          finalmult.append(opponent.ability == :RIPEN ? 0.25 : 0.5)
        end
      end
    end

    # Field Effects (Best Skill)
    if @mondata.skill >= BESTSKILL
      if @battle.shouldApplyFieldChangeDamageBoost(self, attacker)
        provimult = move.calculateFieldMultiplier(1.3)
        finalmult.append(provimult)
      end
      mtype = @battle.getMimicryType(no_random: true)
      finalmult.append(0.5) if opponent.effects[:Shelter] && !mtype.nil? && (type == mtype || secondtypes.include?(mtype))
      finalmult.append(0.5) if aiCheckSideAbility(:PASTELVEIL, opponent, attacker, opponent).any? && type == :POISON && ([:MISTY, :RAINBOW].include?(@battle.FE) || @battle.OV == :MISTY)
      finalmult.append(0.5) if opponent.ability == :TERASHELL && @battle.FE == :CRYSTALCAVERN && !opponent.moldbroken && opponent.hp == opponent.totalhp
      if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5)
        flowerveil = aiCheckSideAbility(:FLOWERVEIL, opponent, attacker, opponent)
        finalmult.append(0.75) if flowerveil.any? { |battler| battler == opponent || opponent.hasType?(:GRASS) }
      end
    end

    if @mondata.skill >= MEDIUMSKILL # Crests are Special
      finalmult.append(0.67) if opponent.crested == :BEHEEYEM && pbAIfaster?(move, nil, attacker, opponent)
      finalmult.append(0.70) if opponent.crested == :AMPHAROS && typemod.superEffective?
      finalmult.append(0.8) if opponent.crested == :MEGANIUM || opponent.pbPartner.crested == :MEGANIUM
      if attacker.crested == :SEVIPER
        multiplier = 0.5 * opponent.pokemon.hp.to_f / opponent.pokemon.totalhp.to_f
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

    end

    # Trade base power for accuracy (Minimum Skill)
    finalmult.append(move.getTradePowerForAccMult(attacker, opponent))

    if @mondata.skill >= MEDIUMSKILL # For damage boosts like EQ/Surf against targets using Dig/Dive
      modifydmg = move.pbModifyDamage(1.0, attacker, opponent)
      modifydmg *= 2.0 if opponent.effects[:Minimize] && move.antiMinimize?
      finalmult.append(modifydmg)
    end


    # Damage formula
    damage = (((2.0 * attacker.level / 5 + 2).floor * basedmg * atk / defense).floor / 50.0).floor + 2
    totaldamage = pbCalcTotalDamage(
      damage, spreadmult, bondmult, weathermult, glaivemult, critmult, randommult,
      stabmult, typemult, burnmult, finalmult, protectmult, opponent,
    )

    # Substitute damage
    totaldamage = [opponent.effects[:Substitute], totaldamage].min if considersub && move.blockedBySubstitute?(attacker, opponent)

    # Make sure damage is at least 1
    totaldamage = 1 if totaldamage < 1
    return totaldamage
  end

  def pbModifySTAB(stabmult, type = @move.type, attacker = @attacker, opponent = @opponent)
    return stabmult
  end

  def pbBetterBaseDamage(move = @move, attacker = @attacker, opponent = @opponent)
    # Covers all function codes which have their own def pbBaseDamage
    aimem = getAIMemory(opponent)
    basedamage = move.basedamage
    basedamage = [attacker.happiness, 250].min if attacker.crested == :LUVDISC
    case move.function
      when 0x6A # Sonic Boom
        return 140 if @battle.FE == :RAINBOW

        return 20
      when 0x6B # Dragon Rage
        return 140 if [:DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE)

        return 40
      when 0x6C # Super Fang, Nature's Madness, Ruination
        if move.move == :NATURESMADNESS && [:GRASSY, :FOREST].include?(@battle.FE)
          return (opponent.hp * 0.75).floor
        elsif move.move == :NATURESMADNESS && @battle.FE == :HOLY
          return (opponent.hp * 0.66).floor
        elsif [:RUINATION, :NATURESMADNESS].include?(move.move) && @battle.FE == :NEWWORLD
          return (opponent.totalhp * 0.5).floor
        end

        return (opponent.hp / 2.0).floor
      when 0x6D # Night Shade
        return (attacker.level * 1.5).floor if ([:BEWITCHED,:HAUNTED].include?(@battle.FE) && move.move == :NIGHTSHADE) || (@battle.FE == :DEEPEARTH && move.move == :SEISMICTOSS)

        return attacker.level
      when 0x6E # Endeavor
        return 0 if attacker.effects[:Substitute] > 0
        if pbAIfaster?(move, nil, attacker, opponent)
          return attacker.hp < opponent.hp ? opponent.hp - attacker.hp : 0
        end
        maxdam = 20 # Arbitrary base score
        for j in aimem
          next if !j.pbIsDamaging? || PBStuff::COUNTERMOVE.include?(j.move)

          tempdam = opponent.hp - [attacker.hp - pbRoughDamage(j, opponent, attacker), 0].min
          maxdam = tempdam if tempdam > maxdam
        end
        return maxdam
      when 0x6F # Psywave
        return ((attacker.level + attacker.level * 1.5) / 2).floor
      when 0x70 # OHKO
        return move.blockedBySubstitute?(attacker, opponent) ? opponent.effects[:Substitute] : opponent.hp
      when 0x71 # Counter
        return 0 if attacker.effects[:Substitute] > 0
        maxdam = 60 # Arbitrary base score
        for j in aimem
          next if !j.pbIsPhysical?(opponent) || PBStuff::COUNTERMOVE.include?(j.move)

          tempdam = pbRoughDamage(j, opponent, attacker) * 2
          maxdam = tempdam if tempdam > maxdam
        end
        return maxdam
      when 0x72 # Mirror Coat
        return 0 if attacker.effects[:Substitute] > 0
        maxdam = 60 # Arbitrary base score
        for j in aimem
          next if !j.pbIsSpecial?(opponent) || PBStuff::COUNTERMOVE.include?(j.move)

          tempdam = pbRoughDamage(j, opponent, attacker) * 2
          maxdam = tempdam if tempdam > maxdam
        end
        return maxdam
      when 0x73 # Metal Burst, Comeuppance
        return 0 if attacker.effects[:Substitute] > 0
        return 0 if pbAIfaster?(move, nil, attacker, opponent)
        maxdam = 40 # Arbitrary base score
        for j in aimem
          next if !j.pbIsDamaging? || PBStuff::COUNTERMOVE.include?(j.move)

          tempdam = (pbRoughDamage(j, opponent, attacker) * 1.5).floor
          maxdam = tempdam if tempdam > maxdam
        end
        return maxdam
      when 0x77, 0x78 # Gust, Twister
        return basedamage * 2 if @mondata.skill >= BESTSKILL && PBStuff::TWOTURNAIRMOVE.include?(opponent.effects[:TwoTurnAttack])
      when 0x7B # Venoshock
        return basedamage * 2 if (opponent.status == :POISON && opponent.crested != :SUICUNE) || (@mondata.skill >= BESTSKILL && [:CORROSIVE, :CORROSIVEMIST, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE))
      when 0x7C # Smelling Salts
        return basedamage * 2 if (opponent.status == :PARALYSIS && opponent.effects[:Substitute] <= 0 || (@mondata.skill >= BESTSKILL && @battle.FE == :INFERNAL)) && opponent.crested != :SUICUNE
      when 0x7D # Wake-Up Slap
        return basedamage * 2 if opponent.status == :SLEEP && opponent.effects[:Substitute] <= 0 && opponent.crested != :SUICUNE
      when 0x7F # Hex
        return basedamage * 2 if (!opponent.status.nil? || (@mondata.skill >= BESTSKILL && @battle.FE == :INFERNAL)) && opponent.crested != :SUICUNE
      when 0x86 # Acrobatics
        return basedamage * 2 if attacker.item.nil? || attacker.hasWorkingItem(:FLYINGGEM) || @battle.FE == :BIGTOP
      when 0x87 # Weather Ball
        weather = @battle.pbWeather(attacker)
        return basedamage * 2 if @battle.FE == :RAINBOW || [:SANDSTORM, :HAIL, :SNOW].include?(weather) || ([:SUNNYDAY, :RAINDANCE].include?(weather) && !attacker.hasWorkingItem(:UTILITYUMBRELLA)) || (weather == :STRONGWINDS && @battle.FE == :SKY) || (weather == :SHADOWSKY && Rejuv)
      when 0x89 # Return
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 102 if @battle.FE == :CONCERT4

        return [(attacker.happiness * 2 / 5.0).floor, 1].max
      when 0x8A # Frustration
        return 102 if @battle.FE == :CONCERT4

        return [((255 - attacker.happiness) * 2 / 5.0).floor, 1].max
      when 0x8B # Eruption / Water Spout / Dragon Energy
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 150 if @battle.FE == :CONCERT4

        return [(150 * attacker.hp.to_f / attacker.totalhp).floor, 1].max
      when 0x8C # Crush Grip / Wring Out / Hard Press
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC

        max = move.move == :HARDPRESS ? 100 : 120
        return max if [:CONCERT4, :DEEPEARTH].include?(@battle.FE)

        return [(max * opponent.hp.to_f / opponent.totalhp).floor, 1].max
      when 0x8D # Gyro Ball
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 150 if [:CONCERT4, :DEEPEARTH].include?(@battle.FE)

        ospeed = pbRoughStat(opponent, PBStats::SPEED)
        aspeed = pbRoughStat(attacker, PBStats::SPEED)
        return [[(25.0 * ospeed / aspeed).floor, 150].min, 1].max
      when 0x8E # Stored Power
        mult = 0
        for i in PBStats::All
          mult += attacker.stages[i] if attacker.stages[i] > 0
        end
        bp = 20
        bp = 40 if move.move == :POWERTRIP && @battle.FE == :FROZENDIMENSION
        return [attacker.happiness, 250].min + (bp * mult) if attacker.crested == :LUVDISC

        return bp * (mult + 1)
      when 0x8F # Punishment
        mult = 0
        for i in PBStats::All
          mult += opponent.stages[i] if opponent.stages[i] > 0
        end
        return [[attacker.happiness, 250].min + (20 * mult), 500].min if attacker.crested == :LUVDISC

        return [20 * (mult + 3), 200].min
      when 0x91 # Fury Cutter
        return basedamage << attacker.effects[:FuryCutter]
      when 0x92 # Echoed Voice
        return basedamage * (@battle.echoedVoice + 1)
      when 0x94 # Present
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC

        return 50
      when 0x95 # Magnitude
        damage = 71
        damage = 10 if @battle.FE == :CONCERT1
        damage = 150 if @battle.FE == :CONCERT4
        damage = [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return damage
      when 0x96 # Natural Gift
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 100 if @battle.FE == :CONCERT4
        return pbNaturalGiftDamage(attacker.item)
      when 0x97 # Trump Card
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 200 if @battle.FE == :CONCERT4

        dmgs = [200, 80, 60, 50, 40]
        ppleft = [move.pp - 1, 4].min # PP is reduced before the move is used
        return dmgs[ppleft]
      when 0x98 # Flail / Reversal
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 200 if @battle.FE == :CONCERT4

        n = (48 * attacker.hp.to_f / attacker.totalhp).floor
        return 200 if n < 2
        return 150 if n < 5
        return 100 if n < 10
        return 80 if n < 17
        return 40 if n < 33

        return 20
      when 0x99 # Electro Ball
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 150 if @battle.FE == :CONCERT4

        n = (attacker.pbSpeed.to_f / opponent.pbSpeed).floor
        return 150 if n >= 4
        return 120 if n >= 3
        return 80 if n >= 2
        return 60 if n >= 1

        return 40
      when 0x9A # Low Kick / Grass Knot
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 120 if @battle.FE == :CONCERT4

        weight = opponent.weight
        return 120 if weight >= 2000
        return 100 if weight >= 1000
        return 80 if weight >= 500
        return 60 if weight >= 250
        return 40 if weight >= 100
        return 20
      when 0x9B # Heavy Slam / Heat Crash
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 120 if @battle.FE == :CONCERT4

        n = attacker.weight / opponent.weight # uses floor division
        n *= 2 if @battle.FE == :DEEPEARTH # indirectly doubles attacker's weight
        return 120 if n >= 5
        return 100 if n >= 4
        return 80 if n >= 3
        return 60 if n >= 2
        return 40
      when 0xBD, 0xBE # Double Kick, Twineedle
        return basedamage * 2
      when 0xBF # Triple Kick
        return basedamage * 6
      when 0xC0, 0x307 # 2-5 Hit Moves
        if attacker.ability == :SKILLLINK
          return basedamage * 5
        elsif attacker.item == :LOADEDDICE
          return (basedamage * 4.5).round
        else
          return (basedamage * 3.1).round
        end
      when 0xC1 # Beat Up
        party = attacker.pbBeatUpParty
        basedamage = 0
        party.each { |mon| basedamage += 5 + (mon.baseStats[1] / 10) }
        return basedamage
      when 0xD3 # Rollout / Ice Ball
        shift = attacker.effects[:Rollout]
        shift += 1 if attacker.effects[:DefenseCurl]
        return basedamage << shift
      when 0xD4 # Bide
        return 0 if attacker.effects[:Substitute] > 0
        maxdam = 20 # Arbitrary base score
        for j in aimem
          next if !j.pbIsDamaging? || PBStuff::COUNTERMOVE.include?(j.move)

          tempdam = pbRoughDamage(j, opponent, attacker)
          maxdam = tempdam if tempdam > maxdam
        end
        return maxdam
      when 0xE1 # Final Gambit
        return attacker.hp
      when 0xF1 # Covet / Thief
        return basedamage * 2 if @battle.FE == :BACKALLEY && opponent.item && !@battle.pbIsUnlosableItem(opponent, opponent.item)
      when 0xF7 # Fling
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 130 if @battle.FE == :CONCERT4
        return pbFlingDamage(attacker.item)
      when 0x113 # Spit Up
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 300 if @battle.FE == :CONCERT4

        return 100 * attacker.effects[:Stockpile]
      when 0x118 # Gravity
        return (opponent.hp / 2.0).floor if @battle.FE == :DEEPEARTH
      when 0x142 # Topsy Turvy
        if @battle.FE == :DEEPEARTH
          return [attacker.happiness, 250].min if attacker.crested == :LUVDISC

          weight = opponent.weight
          return 120 if weight >= 2000
          return 100 if weight >= 1000
          return 80 if weight >= 500
          return 60 if weight >= 250
          return 40 if weight >= 100
          return 20
        end
      when 0x171 # Stomping Tantrum, Temper Flare
        return basedamage * 2 if attacker.effects[:Tantrum]
      when 0x178 # Dynamax Cannon, Behemoth Blade, Behemoth Bash
        return basedamage
      when 0x17E # Dragon Darts
        basemove = @basemove || move
        return basedamage * 2 if pbDragonDartTargetting(attacker, move, basemove).length < 2
      when 0x181 # Fishious Rend/Bolt beak
        return basedamage * 2 if pbAIfaster?(move, nil, attacker, opponent)
      when 0x311 # Rising Voltage
        return basedamage * 2 if (@battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN) && !opponent.isAirborne?
      when 0x312 # Terrain Pulse
        return basedamage * 2 if !@battle.getMimicryType.nil?
      when 0x319 # Surging Strikes
        return basedamage * 3
      when 0x502 # Barb Barrage
        return basedamage * 2 if opponent.status == :POISON || (@mondata.skill >= BESTSKILL && [:CORROSIVE, :CORROSIVEMIST, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE))
      when 0x504 # Infernal Parade
        return basedamage * 2 if !opponent.status.nil? || (@mondata.skill >= BESTSKILL && @battle.FE == :HAUNTED)
      when 0x50A # Population Bomb
        if attacker.ability == :SKILLLINK
          return basedamage * 10
        elsif attacker.item == :LOADEDDICE
          return basedamage * 7
        elsif attacker.item == :WIDELENS
          # Average number of hits with 99% accuracy ~= 9.47
          return (basedamage * 947 / 100.0).round
        else
          # Average number of hits with no modifiers ~= 5.86
          return (basedamage * 586 / 100.0).round
        end
      when 0x51B # Rage Fist
        return basedamage + (50 * attacker.getHitsTaken)
      when 0x519 # Last Respects
        return basedamage + (50 * attacker.pbOwnSide.effects[:AlliesFainted])
      when 0x523 # Fickle Beam
        return @battle.FE == :DRAGONSDEN ? 120 : 104
      # Rejuv Customs
      when 0x202 # Fever Pitch
        return [attacker.happiness, 250].min if attacker.crested == :LUVDISC
        return 40 if @battle.FE == :CONCERT1
        return 130 if @battle.FE == :CONCERT4

        return 74
      when 0x209 # Bunraku Beatdown
        return basedamage + (15 * opponent.pbFaintedPokemonCount) if attacker.ability == :WORLDOFNIGHTMARES

        return [basedamage + (15 * attacker.pbFaintedPokemonCount), 165].min
      when 0x20C # Gilded Helix
        return basedamage * 2 if move.move == :GILDEDHELIX
      # Z-moves
      when 0x809 # Guardian of Alola
        return (opponent.hp * 0.75).floor
    end
    return basedamage
  end

  def mirrorNeverMiss
    return (@attacker.stages[PBStats::ACCURACY] < 0 || @opponent.stages[PBStats::EVASION] > 0 || @opponent.item == :BRIGHTPOWDER ||
           @opponent.item == :LAXINCENSE || accuracyWeatherAbilityActive?(@opponent, @attacker) || @opponent.vanished) &&
           @opponent.ability != :HOTSHOT && @attacker.ability != :HOTSHOT &&
           @opponent.ability != :NOGUARD && @attacker.ability != :NOGUARD && !(@attacker.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
  end

  def pbAegislashStats(aegi)
    if aegi.form == 1
      return aegi
    else
      bladecheck = pbCloneBattler(aegi.index, sourceBattler: aegi)
      bladecheck.stages = aegi.stages.map(&:clone)
      bladecheck.form = 1
      bladecheck.stages[PBStats::ATTACK] += 1 if @battle.FE == :FAIRYTALE && bladecheck.stages[PBStats::ATTACK] < 6
      return bladecheck
    end
  end

  # 'move' here should be the caller move and not the called move, if those are involved
  def moveSuccessful?(move, attacker, opponent)
    can_be_prio_blocked = [:SingleNonUser, :SingleOpposing, :OppositeOpposing, :RandomOpposing, :AllOpposing, :AllNonUsers, :AllBattlers, :DragonDarts].include?(attacker.pbTarget(move))
    return true unless can_be_prio_blocked
    if move.pbIsPriorityMoveAI(attacker)
      return false if @battle.FE == :PSYTERRAIN && !opponent.isAirborne?
      return false if @battle.OV == :PSYTERRAIN && !opponent.isAirborne? && !(Rejuv && @battle.FE == :CHESS && attacker.piece == :KING)
      return false if aiCheckSideAbility(@battle.priorityBlockingAbilities, opponent, attacker, opponent, move, checkMoldBroken: true).any? && !(Rejuv && move.move == :KOWTOWCLEAVE && @battle.FE == :CHESS)
    end
    return false if @battle.FE != :BEWITCHED && attacker.ability == :PRANKSTER && opponent.hasType?(:DARK) && move.pbIsStatus?
    return true
  end

  def pbFormChangeUponSwitchIn(i)
    pkmn = i.pokemon

    # Castform
    if pkmn.species == :CASTFORM && pkmn.ability == :FORECAST
      i.form = 0
      case @battle.pbWeather(nil)
        when :SUNNYDAY then i.form = 1 unless i.hasWorkingItem(:UTILITYUMBRELLA)
        when :RAINDANCE then i.form = 2 unless i.hasWorkingItem(:UTILITYUMBRELLA)
        when :HAIL, :SNOW then i.form = 3
      end
    end
    # Cherrim
    if pkmn.species == :CHERRIM && i.flowerGiftActive?
      i.form = 1
    end
    # Darmanitan
    if pkmn.species == :DARMANITAN && (pkmn.ability == :ZENMODE || i.crested == :DARMANITAN)
      i.form = 1 if i.hp <= i.totalhp / 2 && i.form == 0
      i.form = 3 if i.hp <= i.totalhp / 2 && i.form == 2
      i.form = 3 if i.form == 2 && [:BURNING, :SUPERHEATED].include?(@battle.FE)
      i.form = 1 if i.form == 0 && (@battle.FE == :ASHENBEACH || Rejuv && @battle.FE == :PSYTERRAIN)
      i.form = 1 if i.crested == :DARMANITAN && i.form == 0
    end
    # Wishiwashi
    if pkmn.species == :WISHIWASHI && pkmn.ability == :SCHOOLING
      if (i.hp > i.totalhp / 4 && i.level >= 20) || [:WATERSURFACE, :UNDERWATER, :MURKWATERSURFACE].include?(@battle.FE)
        i.form = 1
      else
        i.form = 0
      end
    end
    # Minior
    if pkmn.species == :MINIOR && pkmn.ability == :SHIELDSDOWN
      if i.hp >= i.totalhp / 2
        i.form = 7
      end
    end
    # Primal Reversion
    if (pkmn.species == :KYOGRE && pkmn.item == :BLUEORB && pkmn.form == 0) ||
       (pkmn.species == :GROUDON && pkmn.item == :REDORB && pkmn.form == 0)
      pkmn.makePrimal
      i.form = pkmn.form
    end
    # Terapagos
    if pkmn.species == :TERAPAGOS && pkmn.form == 0 && pkmn.ability == :TERASHIFT
      pkmn.form = 1
      pkmn.ability = pkmn.abilityIndex
      i.form = 1
    end
    # Glitch Field seeded Arceus
    if pkmn.species == :ARCEUS && pkmn.ability == :MULTITYPE && @battle.FE == :GLITCH && pkmn.item == :SYNTHETICSEED
      i.form = $game_switches[:Pulse_Arceus] && pkmn.trainerID == 00000 ? (9 + pulseArceusTypes) : 9
    end

    # Update stats, ability, etc
    i.pbUpdate(true, fakebattler: true)
  end

  #####################################################
  ## Utility functions                                #
  #####################################################
  def getAIBattlersArray(attacker, opponent)
    array = []
    for i in @battle.battlers
      thisbattler = i
      # Replace battlers at the indexes of attacker and opponent with the current attacker and opponent being considered (which might be different!)
      thisbattler = attacker if i.index == attacker.index
      thisbattler = opponent if i.index == opponent.index
      array.push(thisbattler)
    end
    return array
  end

  def moldBreakerCheck(user, target, move = nil, memory = false)
    return false if target.hasWorkingItem(:ABILITYSHIELD)
    return true if user.ability == :MYCELIUMMIGHT && move&.pbIsStatus?
    return true if [:MOLDBREAKER, :TERAVOLT, :TURBOBLAZE].include?(user.ability)
    # Sunsteel Strike, Moongeist Beam, Photon Geyser, Decimation, Menacing Moonraze Maelstrom, Searing Sunraze Smash, Light that Burns the Sky
    return true if move && [0x166, 0x176, 0x200].include?(move.function)
    return true if memory && checkAImoves([:SUNSTEELSTRIKE, :MOONGEISTBEAM, :PHOTONGEYSER, :DECIMATION], battler: user)
    return false
  end

  def getMoldBrokenArray(attacker = @attacker, opponent = @opponent, move = @move, memory = false)
    array = []
    for i in getAIBattlersArray(attacker, opponent)
      array.push(moldBreakerCheck(attacker, i, move, memory))
    end
    return array
  end

  # for both of the following methods
  # attacker and opponent are always needed as they're used by getAIBattlersArray
  # move and memory are needed only when checkMoldBroken is true
  def aiCheckSideAbility(abilities, battler, attacker = @attacker, opponent = @opponent, move = @move, memory = false, excludeSelf: false, checkMoldBroken: false)
    abilities = Array(abilities)
    abilityholders = []
    for i in getAIBattlersArray(attacker, opponent)
      next if battler.pbIsOpposing?(i.index)
      next if excludeSelf && i == battler
      next if !abilities.include?(i.ability)
      next if checkMoldBroken && moldBreakerCheck(attacker, i, move, memory)

      abilityholders.push(i)
    end
    return abilityholders
  end

  def aiCheckGlobalAbility(abilities, attacker = @attacker, opponent = @opponent, move = @move, memory = false, checkMoldBroken: false)
    abilities = Array(abilities)
    for i in getAIBattlersArray(attacker, opponent)
      next if !abilities.include?(i.ability)
      next if checkMoldBroken && moldBreakerCheck(attacker, i, move, memory)

      return i
    end
    return nil
  end

  def aiCheckGlobalCrest(crest, battler, attacker = @attacker, opponent = @opponent, move = @move, memory = false, excludeSelf: false)
    crestholders = []
    for i in getAIBattlersArray(attacker, opponent)
      next if excludeSelf && i == battler
      next if i.crested != crest

      crestholders.push(i)
    end
    return crestholders
  end

  def aiCheckSideCrest(crest, battler, attacker = @attacker, opponent = @opponent, move = @move, memory = false, excludeSelf: false)
    crestholders = []
    for i in getAIBattlersArray(attacker, opponent)
      # important to check using indexes here since the 'battler' may not be present on the field, as in the case of a Future Sight user
      next if battler.pbIsOpposing?(i.index)
      next if excludeSelf && i == battler
      next if i.crested != crest

      crestholders.push(i)
    end
    return crestholders
  end

  def aiCheckSideItem(item, battler, attacker = @attacker, opponent = @opponent, move = @move, memory = false, excludeSelf: false)
    itemholders = []
    for i in getAIBattlersArray(attacker, opponent)
      # important to check using indexes here since the 'battler' may not be present on the field, as in the case of a Future Sight user
      next if battler.pbIsOpposing?(i.index)
      next if excludeSelf && i == battler
      next if !i.itemWorks?
      next if i.item != item

      itemholders.push(i)
    end
    return itemholders
  end

  def pbCritRateAI?(attacker, opponent, move)
    moldbroken = moldBreakerCheck(attacker, opponent, move)
    return move.pbCritRate?(attacker, opponent, moldbroken)
  end

  def isUsefulStatusMove?(move, attacker, opponent)
    return false if move.pbIsDamaging?
    return false if pbTypeModNoMessages(move.pbType(attacker), attacker, opponent, move).immune?
    return false if !moveSuccessful?(move, attacker, opponent)

    magicGuard = @battle.magicGuardAbilities.include?(opponent.ability)
    return true if move.move == :PERISHSONG && (opponent.ability != :SOUNDPROOF || moldBreakerCheck(attacker, opponent, move))
    return true if move.move == :LEECHSEED && !noLeechSeed(opponent) && !magicGuard
    return true if move.move == :CURSE && attacker.hasType?(:GHOST) && @battle.FE != :HOLY && !magicGuard
    return true if [0x05, 0x06].include?(move.function) && opponent.pbCanPoison?(attacker, move) && !opponent.hydrationActive? && !magicGuard && opponent.ability != :POISONHEAL && opponent.crested != :ZANGOOSE # Poison Powder, Toxic
    return false unless opponent.hp == 1 # the things below this should be checked only for mons at really low health or for shedinja/Pulse Camel

    return true if move.function == 0x0A && opponent.pbCanBurn?(attacker, move) && !opponent.hydrationActive? && !magicGuard # Will-O-Wisp
    return true if move.function == 0x13 && opponent.pbCanConfuse?(attacker, move) # Confuse Ray
    weatherMoves = { 0x101 => :SANDSTORM, 0x102 => :HAIL, 0x131 => :SHADOWSKY }
    return true if weatherMoves.any? { |function, weather| move.function == function && @battle.canSetWeather?(weather) && opponent.takesWeatherDamage?(weather) }
    return false
  end

  def isZMoveWithExtraEffect?(movesym, attacker)
    condition = case movesym
      when :BLOOMDOOM then @battle.canChangeFE?([:GRASSY, :FOREST, *PBFields::FLOWERGARDEN])
      when :STOKEDSPARKSURFER then @battle.canChangeFE?(:ELECTERRAIN)
      when :GENESISSUPERNOVA then @battle.canChangeFE?(:PSYTERRAIN)
      when :SPLINTEREDSTORMSHARDS then @battle.canEndTempFieldOrOverlay?
      when :CLANGOROUSSOULBLAZE then attacker.pbCanIncreaseAnyStat?(PBStats::Omni, attacker, move)
      when :UNLEASHEDPOWER then PBStuff::SCREENEFFECTS.values.any? { |eff| attacker.pbOpposingSide.effects[eff] != 0 }
      when :BLINDINGSPEED then !attacker.pbPartner.isFainted? && [attacker.pbOpposing1, attacker.pbOpposing2].any? { |opp| !opp.isFainted? && pbAIfaster?(nil, nil, opp, attacker.pbPartner) }
      else false
    end
    return condition
  end

  # Determines whether Upper Hand when used by 'attacker' would work against 'opponent' who is using 'oppmove'
  def upperHandWorks?(attacker, opponent, oppmove)
    return false if oppmove.pbIsStatus?
    return false if [:FAKEOUT, :FIRSTIMPRESSION].include?(oppmove.move) && opponent.turncount != 0 # it would work if they chose it, but they're not gonna choose it
    oppPriority = oppmove.priorityCheck(opponent)
    return false if oppPriority <= 0
    return true if oppPriority < 3
    oppFaster = pbAIfaster?(nil, nil, opponent, attacker)
    return true if oppPriority == 3 && !oppFaster
    # it would work against moves with greater priority too, but what's the point of using upper hand if you're going second anyway
    return false
  end

  def notOHKO?(attacker, opponent, immediate = false, move = nil, ignoreMultiHit: false)
    # in the context of this method: attacker is the battler that deals damage, opponent is the battler we are checking if it can't be OHKO'd
    # immediate flags if we are checking for if the opponent should be OHKO'd RIGHT NOW, so end of turn chip doesn't count
    # move gives over a move object, in case this check is being made in context of a specific move
    # the return value indicates whether the opponent can in fact not be killed in a single attack

    # as any given attack is interrupted with the activation of resuscitation (as the target is fainting but immediately reviving) the opponent cannot be OHKO'd for the purposes of this method
    return true if opponent.ability == :RESUSCITATION && opponent.form == 1
    # arguably not 100% correct as up to 2 HP bars of a boss can be removed in a single attack (if the attack can hit more than once) but that is extreme edge case
    return true if opponent.isbossmon && opponent.shieldCount > 0

    bestmove = move ? move : checkAIbestMove(attacker, opponent)
    if bestmove.function != 0x70 # OHKO moves can't be turned into multihits
      return false if [:PARENTALBOND, :SKILLLINK].include?(attacker.ability) || [:TYPHLOSION, :CINCCINO, :LEDIAN].include?(attacker.crested)
      return false if bestmove.pbIsMultiHit && !ignoreMultiHit
    end
    return true if bestmove.blockedBySubstitute?(attacker, opponent)
    unless moldBreakerCheck(attacker, opponent, move, move.nil?)
      return true if opponent.effects[:Disguise]
      return true if opponent.effects[:IceFace] && (bestmove.pbIsPhysical?(attacker, bestmove.pbType(attacker, bestmove.type)) || @battle.FE == :FROZENDIMENSION)
    end

    return false if !immediate && opponent.takesWeatherDamage?
    return true if opponent.crested == :RAMPARDOS && !opponent.permeffs[:RampCrest]

    return false if opponent.hp != opponent.totalhp
    return true if opponent.hasWorkingItem(:FOCUSSASH)
    if @mondata.skill >= HIGHSKILL
      return true if @battle.FE == :CHESS && opponent.piece == :PAWN && !opponent.damagestate.pawnsturdyused
      return true if @battle.FE == :COLOSSEUM && opponent.ability == :STALWART && !moldBreakerCheck(attacker, opponent, move, move.nil?)
    end
    return true if opponent.ability == :STURDY && !moldBreakerCheck(attacker, opponent, move, move.nil?)

    return false
  end

  def canGroundMoveHit?(battler, roost = nil, moldbroken = false)
    roost = battler.effects[:Roost] if roost.nil?
    return true if battler.item == :IRONBALL && @battle.FE != :DEEPEARTH
    return true if battler.effects[:Ingrain]
    return true if battler.effects[:SmackDown]
    return false if battler.ability == :GRAVITYCONTROL && !moldbroken
    return false if [:MAGNETPULL, :CONTRARY, :UNAWARE, :OBLIVIOUS].include?(battler.ability) && @battle.FE == :DEEPEARTH && !moldbroken
    return true if @battle.state.effects[:Gravity] != 0
    return true if @battle.FE == :CAVE
    return false if battler.hasType?(:FLYING) && !roost && !@battle.inverse?
    return false if PBStuff::LevitateAbilities.include?(battler.ability) && !moldbroken
    return false if battler.item == :AIRBALLOON && battler.itemWorks?
    return false if battler.effects[:MagnetRise] > 0
    return false if battler.effects[:Telekinesis] > 0

    return true
  end

  def secondaryEffectNegated?(move = @move, attacker = @attacker, opponent = @opponent)
    return false if move&.pbIsStatus?
    return false if move && PBStuff::ADDITIONAL_EFFECT_SELF_FUNCTIONS.include?(move.function)
    return true if attacker.ability == :SHEERFORCE
    return opponent.ability == :SHIELDDUST || opponent.hasWorkingItem(:COVERTCLOAK)
  end

  def moveInvulMisses?(move = @move, attacker = @attacker, opponent = @opponent) # Corresponds to invulMisses? from Battle_Move
    return false unless opponent.isSemiInvul?

    if @mondata.skill >= BESTSKILL
      return false if move.move == :TOXIC && attacker.hasType?(:POISON)
    end
    if @mondata.skill >= HIGHSKILL
      return false if [:NOGUARD, :HOTSHOT].include?(attacker.ability) || [:NOGUARD, :HOTSHOT].include?(opponent.ability) || (attacker.ability == :FAIRYAURA && @battle.FE == :FAIRYTALE)
      return false if attacker.effects[:LockOnTarget] == opponent.index
    end

    if @mondata.skill >= BESTSKILL
      invulmove = opponent.effects[:TwoTurnAttack]
      case invulmove
        when *PBStuff::TWOTURNAIRMOVE then return false if PBStuff::AIRHITMOVES.include?(move.move)
        when :DIG then return false if [:EARTHQUAKE, :MAGNITUDE, :FISSURE].include?(move.move)
        when :DIVE then return false if [:SURF, :WHIRLPOOL].include?(move.move)
        when :PHANTOMFORCE, :SHADOWFORCE # no moves that bypass
      end
      if opponent.effects[:SkyDrop] # pokemon being sky dropped
        return false if PBStuff::AIRHITMOVES.include?(move.move) || attacker.effects[:SkyDroppee] == opponent
      end
    end
    return true
  end

  def ignoresRedirection?(agent, move, user, redirector, basemove = nil) # For Follow Me / Rage Powder / Ally Switch / Spotlight
    return true if pbAIfaster?(move, moveToMoveObject(agent, redirector), user, redirector) && !PBStuff::PROTECTMOVE.include?(move.move) # Stuff like faster Extreme Speed, Fake Out, etc.
    case agent
      when :ALLYSWITCH
        return [:AllOpposing, :AllNonUsers, :DragonDarts].include?(user.pbTarget(move)) || move.move == :SNIPESHOT
      when :FOLLOWME, :RAGEPOWDER, :SPOTLIGHT
        return [:AllOpposing, :AllNonUsers].include?(user.pbTarget(move)) || [:SNIPESHOT, :SKYDROP].include?(move.move) || basemove&.move == :NATUREPOWER # Technically also Mirror Move and Me First, but who cares
      else return false
    end
  end

  def saltCureGood?
    return Gen < Champs || ([:DEUXFINALIS, :HOLY].include?(@battle.FE) && @mondata.skill == BESTSKILL)
  end

  def lockedIntoAMove?(battler)
    return @opponent.effects[:TwoTurnAttack] != 0 || @opponent.effects[:Outrage] > 0 || @opponent.effects[:Rollout] > 0 || @opponent.effects[:Uproar] > 0 || @opponent.effects[:Bide] > 0
  end

  def survivesAt1HP?(battler)
    return false unless battler.hp == battler.totalhp
    return true if battler.hasWorkingItem(:FOCUSSASH)
    return true if @battle.FE == :CHESS && battler.piece == :PAWN && !battler.damagestate.pawnsturdyused
    return true if battler.ability == :STURDY || (@battle.FE == :COLOSSEUM && battler.ability == :STALWART)
    return false
  end

  def seedProtection?(battler)
    return !battler.effects[:Protect].nil?
  end

  # Checks if protection effect 'effect' can block 'move' from 'moveuser'
  def protectEffectWorks?(effect, move, moveuser)
    return false if effect.nil?
    return false if !move.canProtect? || move.zmove || move.unseenFistCheck(moveuser) || (Rejuv && move.move == :KOWTOWCLEAVE && @battle.FE == :CHESS)
    return false if ![:SingleNonUser, :SingleOpposing, :OppositeOpposing, :RandomOpposing, :AllOpposing, :AllNonUsers, :AllBattlers, :DragonDarts].include?(moveuser.pbTarget(move))
    case effect
      when :WideGuard then return [:AllOpposing, :AllNonUsers].include?(moveuser.pbTarget(move))
      when :QuickGuard then return move.priorityCheck(moveuser) > 0
      when :CraftyShield then return move.pbIsStatus?
      when :MatBlock then return move.pbIsDamaging?
    end
    return true if move.pbIsDamaging?
    case effect
      when :KingsShield then return false unless [:FAIRYTALE, :CHESS].include?(@battle.FE)
      when :Obstruct then return false unless [:DIMENSIONAL, :CHESS].include?(@battle.FE)
      when :SilkTrap then return false unless [:FOREST].include?(@battle.FE)
      when :BurningBulwark then return false unless [:BURNING, :VOLCANIC, :NEWWORLD].include?(@battle.FE)
    end
    return true
  end

  def accuracyWeatherAbilityActive?(battler, attacker)
    weather = @battle.pbWeather(attacker)
    return true if battler.ability == :SANDVEIL && weather == :SANDSTORM
    return true if battler.ability == :SNOWCLOAK && ([:HAIL, :SNOW].include?(weather) || battler.crested == :GLACEON)
    if @mondata.skill >= BESTSKILL
      return true if battler.ability == :SANDVEIL && [:DESERT, :ASHENBEACH].include?(@battle.FE)
      return true if battler.ability == :SNOWCLOAK && [:ICY, :SNOWYMOUNTAIN].include?(@battle.FE)
    end
    return false
  end

  def getAceIndex(index = @attacker.index)
    ret = @battle.pbPartySingleOwner(index).length - 1
    trainer = @battle.pbGetOwner(index)
    ret = trainer.teamAttributes[:aceIndex] || ret if trainer
    return ret
  end

  def mustSendOutAceLast?(index = @attacker.index)
    # If ace already got sent out because of a forced switch, don't assume we still need to send it out last
    sideindex = @battle.pbIsOpposing?(index) ? 1 : 0
    trainerindex = @battle.pbGetOwnerIndex(index)
    return false if @battle.pbIsRevealedPokemon?(sideindex, trainerindex, getAceIndex(index))

    # Rejuv and Deso
    return true if $game_switches[:Last_Ace_Switch] && @battle.pbIsOpposing?(index)

    # Reborn
    return true if @battle.pbGetOwner(index)&.teamAttributes&.dig(:sendAceLast)

    return false
  end

  def omniscience?
    return $game_switches[:Omniscience]
  end

  def useDynamicSpeed
    return false unless DynamicSpeed
    return false unless @battle.doublebattle
    return false unless @mondata.skill >= BESTSKILL
    return false unless @battle.battlers.count { |battler| !battler.isFainted? } >= 3

    return true
  end

  def hasDamagingMoveOfType(user, memory, type)
    memory.any? { |moveloop| moveloop != nil && moveloop.pbType(user) == type && moveloop.pbIsDamaging? }
  end

  def moveToMoveObject(movesym, battler, zbase = nil)
    return PokeBattle_Move.pbFromPBMove(@battle, PBMove.new(movesym), battler.pokemon, zbase)
  end

  def scoringAgainstPartner?
    return @opponent.index == @attacker.pbPartner.index
  end

  def getMaxDamageAndOpponent
    maxdam, maxdamopp = 0, @attacker.pbFirstOpposing
    for opp in [@attacker.pbOpposing1, @attacker.pbOpposing2]
      tempdam = checkAIdamage(@attacker, opp)
      if tempdam > maxdam
        maxdam, maxdamopp = tempdam, opp
      end
    end
    return [maxdam, maxdamopp]
  end

  #####################################################
  # Logging-related methods
  #####################################################
  def extract_move_scores
    for oppindex in 0...4
      for moveindex in 0...7
        next unless $ai_log_data[@attacker.index].moves_scored.include?([oppindex, moveindex])

        movename = getAllBattlerMoves(@attacker, @mondata)[moveindex].name
        oppstring = @battle.doublebattle ? " vs #{@battle.battlers[oppindex].logname} - #{oppindex}" : ""

        initialScore = @mondata.roughdamagearray[oppindex][moveindex]
        initialString = "#{movename}#{oppstring} - Initial move score: ".ljust(60) + "|#{initialScore}"
        $ai_log_data[@attacker.index].init_move_scores.push(initialString)
        if PokeBattle_AI_Info::LogMiniscores
          miniScore = @mondata.miniscorearray[oppindex][moveindex]
          miniString = "#{movename}#{oppstring} - Move 'miniscore': ".ljust(60) + "|#{miniScore}"
          $ai_log_data[@attacker.index].move_miniscores.push(miniString)
        end
        finalScore = @mondata.scorearray[oppindex][moveindex]
        finalString = "#{movename}#{oppstring} - Final move score: ".ljust(60) + "|#{finalScore}"
        $ai_log_data[@attacker.index].final_move_scores.push(finalString)
      end
    end
  end

  def extract_adjusted_move_scores
    for attindex in 0...4
      for oppindex in 0...4
        for moveindex in 0...7
          next unless $ai_log_data[attindex].moves_scored.include?([oppindex, moveindex])

          attacker, mondata = @battle.battlers[attindex], @aimondata[attindex]
          movename = getAllBattlerMoves(attacker, mondata)[moveindex].name
          oppstring = " vs #{@battle.battlers[oppindex].logname} - #{oppindex}"

          adjustedScore = mondata.scorearray[oppindex][moveindex]
          adjustedString = "#{movename}#{oppstring} - Adjusted move score: ".ljust(60) + "|#{adjustedScore}"
          $ai_log_data[attindex].adjusted_move_scores.push(adjustedString)
        end
      end
    end
  end

  def extract_cumulative_move_scores(battler, chooseablemoves)
    str = ""
    for movehash in chooseablemoves
      next if chooseablemoves.any? { |movehash2| movehash2 != movehash && movehash2[:moveindex] == movehash[:moveindex] && movehash2[:zmove] == movehash[:zmove] }
      # skip if this move is present multiple times in chooseablemoves bc that means its scores don't get cumulated into a single score

      move = movehash[:zmove] ? battler.zmoves[movehash[:moveindex]] : battler.moves[movehash[:moveindex]]
      str += "+ #{move.name}".ljust(60) + "|#{movehash[:score]}\n"
    end
    return str
  end

  def extract_preferred_moves(battler, preferredMoves)
    str = ""
    return str if preferredMoves.length == 1 || (preferredMoves.length == 2 && preferredMoves[0] == preferredMoves[1])

    for i in 0...preferredMoves.length
      movehash = preferredMoves[i]
      previousmovehash = preferredMoves[i - 1]
      if movehash == previousmovehash # "doubly prefer the best move" situation
        str += " (x2)"
      else
        str += ", " unless str.empty?
        move = movehash[:zmove] ? battler.zmoves[movehash[:moveindex]] : battler.moves[movehash[:moveindex]]
        str += "#{move.name} (#{movehash[:score]})"
      end
    end
    return str
  end
end

#####################################################
## Other Classes
#####################################################

class PokeBattle_Move_FFF < PokeBattle_Move # Fake move used by AI to determine damage if no damaging AI memory move
  def initialize(battle, user, type)
    effattack = user.crested == :ELECTRODE ? user.attack * 2 : user.attack
    hash = {
      :name => "Fake Move",
      :function => 0xFFF,
      :type => type || :QMARKS,
      :category => effattack > user.spatk ? :physical : :special,
      :basedamage => (user.level >= 40 ? 80 : [2 * user.level, 40].max),
      :accuracy => 100,
      :maxpp => 15,
      :target => :SingleNonUser,
    }

    @battle     = battle
    @move       = :FAKEMOVE
    @data       = MoveData.new(@move, hash)
    @zmove      = false
    @immediate  = false
    @user       = user.pokemon

    # these attributes do need to be assigned but we also need the data seperately for reasons (idk do we?)
    @function   = @data.function
    @type       = @data.type
    @category   = @data.category
    @basedamage = @data.basedamage
    @accuracy   = @data.accuracy
    @maxpp      = @data.maxpp
    @target     = @data.target
    @priority   = @data.priority ? @data.priority : 0
    @effect     = @data.checkFlag?(:effect, 0)
    @moreeffect = @data.checkFlag?(:moreeffect, 0)
    @recoil     = @data.checkFlag?(:recoil, 0)
    @pp         = @data.maxpp
  end
end

class PokeBattle_AI_Info # info per battler for debuglogging
  attr_accessor :battler_name
  attr_accessor :battler_item
  attr_accessor :battler_ability
  attr_accessor :battler_hp_percentage
  attr_accessor :field_effect
  attr_accessor :items
  attr_accessor :items_scores
  attr_accessor :switch_scores
  attr_accessor :switch_names
  attr_accessor :should_switch_score
  attr_accessor :moves_scored
  attr_accessor :init_move_scores
  attr_accessor :move_miniscores
  attr_accessor :final_move_scores
  attr_accessor :adjusted_move_scores
  attr_accessor :cumulative_move_scores
  attr_accessor :preferred_moves
  attr_accessor :chosen_action
  attr_accessor :expected_damage
  attr_accessor :expected_damage_name
  attr_accessor :expected_move

  LogMiniscores = false # Salix's miniscore logging

  def initialize
    @battler_name = ""
    @battler_item = ""
    @battler_ability = ""
    @battler_hp_percentage = 0
    @field_effect = nil
    @items = []
    @items_scores = []
    @switch_scores = []
    @switch_names = []
    @should_switch_score = 0
    @moves_scored = []
    @init_move_scores = []
    @move_miniscores = []
    @final_move_scores = []
    @adjusted_move_scores = []
    @cumulative_move_scores = ""
    @preferred_moves = ""
    @chosen_action = ""
    @expected_damage = []
    @expected_damage_name = []
    @expected_move = []
  end

  def reset(battler)
    @battler_name = battler.nil? ? "nil" : battler.logname
    @battler_item = battler.nil? || battler.item.nil? ? "nil" : getItemName(battler.item)
    @battler_ability = battler.nil? || battler.ability.nil? ? "nil" : getAbilityName(battler.ability)
    @battler_hp_percentage = battler.nil? ? 0 : (battler.hp * 100.0 / battler.totalhp).round(1)
    @field_effect = battler.nil? ? nil : battler.battle.FE
    @items = []
    @items_scores = []
    @switch_scores = []
    @switch_names = []
    @should_switch_score = 0
    @moves_scored = []
    @init_move_scores = []
    @move_miniscores = []
    @final_move_scores = []
    @adjusted_move_scores = []
    @cumulative_move_scores = ""
    @preferred_moves = ""
    @chosen_action = ""
    @expected_damage = []
    @expected_damage_name = []
    @expected_move = []
  end

  def logAIScorings()
    return if !$INTERNAL

    to_be_printed = "\n" + ("_" * 78) + "\n"
    to_be_printed += "Scoring moves for battler: " + @battler_name + ", Current HP: #{@battler_hp_percentage} %\n"
    to_be_printed += "Held Item: " + @battler_item + ", Ability: " + @battler_ability + ", Field: " + getFieldName(@field_effect).to_s + "\n"
    to_be_printed += "\n"

    # Add scores for current hp and the expected damage it will take
    @expected_damage.each_with_index { |_, i|
      to_be_printed += "Expected damage taken from #{@expected_damage_name[i]} (using #{@expected_move[i]})".ljust(60) + "|#{@expected_damage[i]} % \n"
    }
    to_be_printed += "\n"

    # Add switching score
    to_be_printed += "Scoring for switching to another mon".ljust(60) + "|" + "#{@should_switch_score} \n \n"

    # Add scores for items
    if @items.length != 0
      to_be_printed += "Scoring for items:\n"
      @items.each_with_index { |item_name, index|
        to_be_printed += item_name.ljust(60) + "|" + @items_scores[index].to_s.ljust(20) + "\n"
      }
      to_be_printed += "\n"
    end

    for index in 0...init_move_scores.length
      to_be_printed += @init_move_scores[index] + "\n"
      to_be_printed += @move_miniscores[index] + "\n" if LogMiniscores
      to_be_printed += @final_move_scores[index] + "\n"
      to_be_printed += @adjusted_move_scores[index] + "\n" if @adjusted_move_scores[index]
      to_be_printed += "\n"
    end

    to_be_printed += "Cumulative scores for moves with atypical targeting:\n" + @cumulative_move_scores + "\n" unless @cumulative_move_scores.empty?
    to_be_printed += "Final action chosen:".ljust(60) + "|#{@chosen_action}".ljust(20) + "\n"
    to_be_printed += "\nMove chosen randomly out of " + @preferred_moves + "\n" unless @preferred_moves.empty?
    to_be_printed += ("_" * 78) + "\n"

    $stdout.print(to_be_printed) # put to console
    PBDebug.dblog(to_be_printed) # log in debug battle log
  end

  def logAISwitching()
    return if !$INTERNAL
    return if @switch_names.empty?

    to_be_printed = "\n" + ("_" * 78) + "\n"
    to_be_printed += "Scoring for switching from: " + @battler_name + "\n"
    to_be_printed += "\n"
    @switch_names.each_with_index { |name, index|
      to_be_printed += "Score for switching to #{name}".ljust(60) + "|#{@switch_scores[index]} \n"
    }
    to_be_printed += "\n" + "Switch chosen = ".ljust(60) + "|#{@switch_names[@switch_scores.index(@switch_scores.max)]}" + "\n"
    to_be_printed += ("_" * 78) + "\n"

    $stdout.print(to_be_printed) # put to console
    PBDebug.dblog(to_be_printed) # log in debug battle log
  end
end

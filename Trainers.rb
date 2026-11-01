def pbLoadTrainer(type, name, id, hasLevelCap: false)
  trainerTeam = findParty(type, name, id)
  dp("Team could not be loaded, please report this: #{type}, #{name}, #{id} \n ty <3") if !trainerTeam
  return nil if !trainerTeam

  opponent = PokeBattle_Trainer.new(name, type)
  opponent.setForeignID($Trainer) if $Trainer
  opponent.trainereffect = trainerTeam.effects
  opponent.delayRegister = trainerTeam.delayRegister
  opponent.teamAttributes = trainerTeam.teamAttributes

  items = trainerTeam.items

  team = trainerTeam.party
  partySize = trainerTeam.partySize
  setParty = trainerTeam.setParty
  team = buildTeamFromParameters(team, partySize, setParty)
  party = getTrainerPartyFromTrainerHash(team, opponent, type, hasLevelCap: hasLevelCap)

  return [opponent, items, party]
end

def findParty(type, name, id)
  return $cache.trainers.dig(type, name, id)
end

def buildTeamFromParameters(team, partySize, setParty)
  return team unless partySize

  picked = []
  temp = Array.new(partySize, nil) # Create a new array to return later
  for i in 0...partySize
    if setParty && setParty[i] # If setParty exists and there is a mon to set at that index, set it
      temp[i] = setParty[i]
      next
    end
    pool = team - picked

    # seeded randomization. will use regular rand() when the seed is set to 0
    idx = $game_variables[:PoolPartySeed] == 0 ? rand(pool.length) :
      Random.new($game_variables[:PoolPartySeed]).rand(pool.length)
    mon = pool[idx]
    picked.push(mon)
    temp[i] = mon
  end
  return temp
end

def pbLoadCopiedTrainer(trainerid, trainername, partyid, party)
  opponent = PokeBattle_Trainer.new(trainername, trainerid)
  items = []
  for trainer in $cache.trainers
    next if trainerid != trainer[0] || partyid != trainer[4]

    items = trainer[2].clone
  end
  return [opponent, items, party]
end

def pbMissingTrainer(trainerid, trainername, trainerparty)
  traineridstring = "#{trainerid}"
  if $DEBUG
    if trainerparty != 0
      message = _INTL("Add new trainer ({1}, {2}, ID {3})?", traineridstring, trainername, trainerparty)
    else
      message = _INTL("Add new trainer ({1}, {2})?", traineridstring, trainername)
    end
    cmd = Kernel.pbMessage(message, [_INTL("Yes"), _INTL("No")], 2)
    if cmd == 0
      pbNewTrainer(trainerid, trainername, trainerparty)
    end
    return cmd
  else
    raise _INTL("Can't find trainer ({1}, {2}, ID {3})", traineridstring, trainername, trainerparty)
  end
end

# pbDoubleTrainerBattle(:AsterKnight,"Aster",0,_I("Dammit! Eclipse, are you even trying?!"),:EclipseDame,"Eclipse",0,_I("Not really, no."),switch_sprites: true)
def pbDoubleTrainerBattle(
  trainerid1, trainername1, trainerparty1, endspeech1,
  trainerid2, trainername2, trainerparty2, endspeech2,
  canlose = false, variable = Variables[:BattleResult],
  vsoutfit1: 0, vsoutfit2: 0, switch_sprites: false, recorded: false, noexp: false, levelCap: 0, raiseToLevel: false
)
  $game_temp.in_battle = true
  hasLevelCap = levelCap > 0
  trainer1 = pbLoadTrainer(trainerid1, trainername1, trainerparty1, hasLevelCap: hasLevelCap)
  Events.onTrainerPartyLoad.trigger(nil, trainer1)
  if !trainer1
    pbMissingTrainer(trainerid1, trainername1, trainerparty1)
  end
  trainer2 = pbLoadTrainer(trainerid2, trainername2, trainerparty2, hasLevelCap: hasLevelCap)
  Events.onTrainerPartyLoad.trigger(nil, trainer2)
  if !trainer2
    pbMissingTrainer(trainerid2, trainername2, trainerparty2)
  end
  if !trainer1 || !trainer2
    $game_temp.in_battle = false
    return false
  end
  trainer1[0].outfit = vsoutfit1 if vsoutfit1 > 0
  trainer2[0].outfit = vsoutfit2 if vsoutfit2 > 0
  if $PokemonGlobal.partner
    othertrainer = PokeBattle_Trainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
    othertrainer.id = $PokemonGlobal.partner[2]
    othertrainer.party = $PokemonGlobal.partner[3]
    playerparty = [$Trainer.party, othertrainer.party]
    playertrainer = [$Trainer, othertrainer]
  else
    playerparty = [$Trainer.party]
    playertrainer = $Trainer
  end
  combinedParty = [trainer1[2], trainer2[2]]
  combinedspecialmoves = getCombinedSpecialMoves(trainer1[0], trainer2[0])
  scene = pbNewBattleScene
  battle = PokeBattle_Battle.new(scene, playerparty, combinedParty, playertrainer, [trainer1[0], trainer2[0]], recorded, combinedspecialmoves)
  battle.controlPlayer = $game_switches[:AI_Play] || $game_switches[:Forced_AI_Play]
  trainerbgm = pbGetTrainerBattleBGM([trainer1[0], trainer2[0]])
  battle.doublebattle = true
  battle.endspeech = trainer1[0].teamAttributes[:defeat] || ""
  battle.endspeech2 = trainer2[0].teamAttributes[:defeat] || ""

  # Temporary code to detect bugs
  endspeechOverride(battle, [trainerid1, trainername1], endspeech1, suppress: $game_switches[:Theme_Team_Execution] || $game_switches[:MnM_Execution]) unless endspeech1.to_s.empty?
  endspeech2Override(battle, [trainerid2, trainername2], endspeech2, suppress: $game_switches[:Theme_Team_Execution] || $game_switches[:MnM_Execution]) unless endspeech2.to_s.empty?
  endspeechOverride(battle, [trainerid1, trainername1], $game_variables[:Theme_Team_Defeat_Line]) if $game_switches[:Theme_Team_Execution] && !$game_switches[:Grinding_Trainer_Money_Cut]
  endspeechOverride(battle, [trainerid1, trainername1], $game_variables[:MnM_Defeat_Line]) if $game_switches[:MnM_Execution]
  endspeech2Override(battle, [trainerid2, trainername2], $game_variables[:Theme_Team_Defeat_Line]) if $game_switches[:MnM_Execution]
  battle.endspeech = endspeech1 unless endspeech1.to_s.empty?
  battle.endspeech2 = endspeech2 unless endspeech2.to_s.empty?

  trainer1[1].nil? ? trainer1items = [] : trainer1items = trainer1[1]
  trainer2[1].nil? ? trainer2items = [] : trainer2items = trainer2[1]
  if $PokemonGlobal.partner
    battle.partneritems = $PokemonGlobal.partner[4]
  end
  battle.items = [trainer1items, trainer2items]
  if $DEBUG && Input.press?(Input::CTRL)
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(pbGetMessageFromHash(:EndSpeechLose, battle.endspeech))
    Kernel.pbMessage(pbGetMessageFromHash(:EndSpeechLose, battle.endspeech2)) if battle.endspeech2 && battle.endspeech2 != ""
    $game_temp.in_battle = false
    return true
  end
  if $game_switches[:No_Battles_Pass] && Kernel.pbConfirmMessage(_INTL("Skip battle?"))
    Kernel.pbMessage(_INTL("After losing: "))
    Kernel.pbMessage(pbGetMessageFromHash(:EndSpeechLose, battle.endspeech))
    Kernel.pbMessage(pbGetMessageFromHash(:EndSpeechLose, battle.endspeech2)) if battle.endspeech2 && battle.endspeech2 != ""
    $game_temp.in_battle = false
    return true
  end
  battle.disableExpGain = true if noexp
  battle.setLevelCap(levelCap, raiseToLevel) if hasLevelCap
  Events.onDoubleBattleLoad.trigger("trainer", trainer1, trainer2)
  battle.internalbattle = true
  pbPrepareBattle(battle)
  decision = 0
  pbBattleAnimation(trainerbgm, [trainerid1, trainerid2], [trainer1[0].trainername, trainer2[0].trainername], switch_sprites, [vsoutfit1, vsoutfit2]) {
    pbSceneStandby {
      decision = battle.pbStartBattle(canlose)
    }
    pbHealPartner
    if [2, 5].include?(decision)
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
      end
    end
    Events.onEndBattle.trigger(nil, decision)
    next ![2, 5].include?(decision) || canlose
  }
  Input.update
  pbSet(variable, decision)
  $game_temp.in_battle = false
  return decision == 1
end

def pbTrainerBattle(trainerid, trainername, endspeech = nil, doublebattle = false, trainerparty = 0, canlose = false, variable = Variables[:BattleResult],
  opponent_team: [], recorded: false, items_overwrite: nil, noexp: false, vsoutfit: 0, levelCap: 0, raiseToLevel: false, opponent_overwrite: nil, trainereffect_overwrite: nil, specialmove_overwrite: nil)
  $game_temp.in_battle = true
  hasLevelCap = levelCap > 0
  if $Trainer.pokemonCount == 0
    Kernel.pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    $game_temp.in_battle = false
    return false
  end
  opponent_team = copyTrainerTeam if Reborn && AlterEgos.include?(trainerid)
  if !$PokemonTemp.waitingTrainer && pbMapInterpreterRunning?
    thisEvent = pbMapInterpreter.get_character(0)
    triggeredEvents = $game_player.pbTriggeredTrainerEvents([2], false)
    otherEvent = []
    for i in triggeredEvents
      if i.id != thisEvent.id && !$game_self_switches[[$game_map.map_id, i.id, "A"]]
        otherEvent.push(i)
      end
    end
    if otherEvent.length == 1
      trainer = opponent_overwrite || (opponent_team.length == 0 ? pbLoadTrainer(trainerid, trainername, trainerparty, hasLevelCap: hasLevelCap) : pbLoadCopiedTrainer(trainerid, trainername, trainerparty, opponent_team))
      Events.onTrainerPartyLoad.trigger(nil, trainer)
      if !trainer
        pbMissingTrainer(trainerid, trainername, trainerparty)
        $game_temp.in_battle = false
        return false
      end
      if trainer[2].length <= 6 # 3
        $PokemonTemp.waitingTrainer = [trainer, thisEvent.id, endspeech]
        $game_temp.in_battle = false
        return false
      end
    end
  end
  trainer = opponent_overwrite || (opponent_team.length == 0 ? pbLoadTrainer(trainerid, trainername, trainerparty, hasLevelCap: hasLevelCap) : pbLoadCopiedTrainer(trainerid, trainername, trainerparty, opponent_team))
  Events.onTrainerPartyLoad.trigger(nil, trainer)
  if trainereffect_overwrite
    dummytrainer = pbLoadTrainer(trainereffect_overwrite[1], trainereffect_overwrite[0], trainereffect_overwrite[2])
    trainer[0].trainereffect = dummytrainer[0].trainereffect
  end
  if specialmove_overwrite
    trainer[0].specialmoves = specialmove_overwrite
  end
  if !trainer
    pbMissingTrainer(trainerid, trainername, trainerparty)
    $game_temp.in_battle = false
    return false
  end
  doublebattle = true if Reborn && makeDoubles?(opponent_team.length > 0 ? opponent_team : trainer[2])
  trainer[0].outfit = vsoutfit if vsoutfit > 0
  combinedspecialmoves = getCombinedSpecialMoves(trainer[0], $PokemonTemp.waitingTrainer ? $PokemonTemp.waitingTrainer[0][0] : nil)
  if $PokemonGlobal.partner && ($PokemonTemp.waitingTrainer || doublebattle)
    othertrainer = PokeBattle_Trainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
    othertrainer.id = $PokemonGlobal.partner[2]
    othertrainer.party = $PokemonGlobal.partner[3]
    playerparty = [$Trainer.party, othertrainer.party]
    playertrainer = [$Trainer, othertrainer]
    doublebattle = true
  else
    playerparty = [$Trainer.party]
    playertrainer = $Trainer
  end
  if $PokemonTemp.waitingTrainer
    combinedParty = [$PokemonTemp.waitingTrainer[0][2], trainer[2]]
    scene = pbNewBattleScene
    battle = PokeBattle_Battle.new(scene, playerparty, combinedParty, playertrainer, [$PokemonTemp.waitingTrainer[0][0], trainer[0]], recorded, combinedspecialmoves)
    trainerbgm = pbGetTrainerBattleBGM([$PokemonTemp.waitingTrainer[0][0], trainer[0]])
    battle.controlPlayer = $game_switches[:AI_Play] || $game_switches[:Forced_AI_Play]
    battle.doublebattle = true
    battle.endspeech = $PokemonTemp.waitingTrainer[0][0].teamAttributes[:defeat] || ""
    battle.endspeech2 = trainer[0].teamAttributes[:defeat] || ""

    # Temporary code to detect bugs
    endspeechOverride(battle, [$PokemonTemp.waitingTrainer[0][0].trainertype, $PokemonTemp.waitingTrainer[0][0].name], $PokemonTemp.waitingTrainer[2], suppress: $game_switches[:Theme_Team_Execution] || $game_switches[:MnM_Execution]) unless $PokemonTemp.waitingTrainer[2].to_s.empty?
    endspeech2Override(battle, [trainerid, trainername], endspeech, suppress: $game_switches[:Theme_Team_Execution] || $game_switches[:MnM_Execution]) unless endspeech.to_s.empty?
    endspeech2Override(battle, [trainerid, trainername], $game_variables[:Theme_Team_Defeat_Line]) if $game_switches[:MnM_Execution]
    battle.endspeech = $PokemonTemp.waitingTrainer[2] unless $PokemonTemp.waitingTrainer[2].to_s.empty?
    battle.endspeech2 = endspeech unless endspeech.to_s.empty?

    $PokemonTemp.waitingTrainer[0][1].nil? ? trainer1items = [] : trainer1items = $PokemonTemp.waitingTrainer[0][1]
    trainer[1].nil? ? trainer2items = [] : trainer2items = trainer[1]
    if $PokemonGlobal.partner
      battle.partneritems = $PokemonGlobal.partner[4]
    end
    battle.items = [trainer1items, trainer2items]
  else
    scene = pbNewBattleScene
    if opponent_team.length > 0
      battle = PokeBattle_Battle.new(scene, playerparty, [opponent_team], playertrainer, trainer[0], recorded, combinedspecialmoves)
    else
      battle = PokeBattle_Battle.new(scene, playerparty, [trainer[2]], playertrainer, trainer[0], recorded, combinedspecialmoves)
    end
    battle.controlPlayer = $game_switches[:AI_Play] || $game_switches[:Forced_AI_Play]
    battle.doublebattle = doublebattle ? true : false
    battle.endspeech = trainer[0].teamAttributes[:defeat] || ""

    # Temporary code to detect bugs
    endspeechOverride(battle, [trainerid, trainername], endspeech, suppress: $game_switches[:Theme_Team_Execution] || $game_switches[:MnM_Execution]) unless endspeech.to_s.empty?
    endspeechOverride(battle, [trainerid, trainername], $game_variables[:Theme_Team_Defeat_Line]) if ($game_switches[:Theme_Team_Execution] && !$game_switches[:Grinding_Trainer_Money_Cut]) || $game_switches[:MnM_Execution]
    battle.endspeech = endspeech unless endspeech.to_s.empty?

    battle.items = trainer[1]
    battle.items = items_overwrite if items_overwrite
    if $PokemonGlobal.partner
      battle.partneritems = $PokemonGlobal.partner[4]
    end
    trainerbgm = pbGetTrainerBattleBGM(trainer[0])
  end
  if $DEBUG && Input.press?(Input::CTRL)
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(pbGetMessageFromHash(:EndSpeechLose, battle.endspeech))
    Kernel.pbMessage(pbGetMessageFromHash(:EndSpeechLose, battle.endspeech2)) if battle.endspeech2 && battle.endspeech2 != ""
    if $PokemonTemp.waitingTrainer
      pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1], "A", true)
      $PokemonTemp.waitingTrainer = nil
    end
    $game_temp.in_battle = false
    return true
  end
  if $game_switches[:No_Battles_Pass] && Kernel.pbConfirmMessage(_INTL("Skip battle?"))
    Kernel.pbMessage(_INTL("After losing: "))
    Kernel.pbMessage(pbGetMessageFromHash(:EndSpeechLose, battle.endspeech))
    Kernel.pbMessage(pbGetMessageFromHash(:EndSpeechLose, battle.endspeech2)) if battle.endspeech2 && battle.endspeech2 != ""
    if $PokemonTemp.waitingTrainer
      pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1], "A", true)
      $PokemonTemp.waitingTrainer = nil
    end
    $game_temp.in_battle = false
    return true
  end
  battle.disableExpGain = true if noexp
  battle.setLevelCap(levelCap, raiseToLevel) if hasLevelCap
  battle.internalbattle = true
  # TODO: The condition below is kind of arbitrary, find out if it's actually needed by Rejuv and handle it better if so
  if !$PokemonTemp.waitingTrainer && isTwoVsOneBoss?(trainer[2][0])
    battle.doublebattle = true
  end
  pbPrepareBattle(battle)
  battle.shiftStyle = trainer[0].teamAttributes[:noShiftStyle] ? false : $Settings.battlestyle == 0
  decision = 0
  pbBattleAnimation(trainerbgm, trainer[0].trainertype, trainer[0].trainername, false, vsoutfit) {
    pbSceneStandby {
      decision = battle.pbStartBattle(canlose)
    }
    pbHealPartner
    if [2, 5].include?(decision)
      if canlose
        for i in 0...$Trainer.party.length
          $Trainer.party[i].heal if !$game_switches[:Nuzlocke_Mode] || !battle.fainted_mons[i]
        end
        for i in 0...10
          Graphics.update
        end
      end
    elsif decision == 1 && $PokemonTemp.waitingTrainer
      pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1], "A", true)
      # Activate the D switch on both trainers if the player beats them in a double battle.
      # Used for teasing the colosseum password in Reborn.
      pbMapInterpreter.pbSetSelfSwitch(pbMapInterpreter.get_character(0).id, "D", true)
      pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1], "D", true)
    end
    Events.onEndBattle.trigger(nil, decision)
    next ![2, 5].include?(decision) || canlose
  }
  Input.update
  pbSet(variable, decision)
  $PokemonTemp.waitingTrainer = nil
  $game_temp.in_battle = false
  return decision == 1
end

def pbSetLevelTrainerBattle(*args, levelCap, raiseToLevel, doubleTrainer: false)
  return pbDoubleTrainerBattle(*args, levelCap: levelCap, raiseToLevel: raiseToLevel) if doubleTrainer
  return pbTrainerBattle(*args, levelCap: levelCap, raiseToLevel: raiseToLevel)
end

def pbTrainerBattle100(*args)
  return pbSetLevelTrainerBattle(*args, 100, true)
end

def pbDoubleTrainerBattle100(*args)
  return pbSetLevelTrainerBattle(*args, 100, true, doubleTrainer: true)
end

# endspeech variable overrides don't work well with translations, we need to pass them to battle differently
def endspeechOverride(battle, trainer, endspeech, suppress: false)
  suppress = true if suppressEndspeechError(*trainer)
  if !Desolation && battle.endspeech != endspeech && $Settings.language == 0 && !suppress
    dp(sprintf("Unexpected battle.endspeech override, please report which battle triggered this error.\nnormal: %s\noverride: %s\n\n%s", battle.endspeech, endspeech, caller[0]))
  end
  # If an endspeech is present both in trainertext and map data, trainertext takes priority
  battle.endspeech = endspeech if battle.endspeech.to_s.empty?
end

def endspeech2Override(battle, trainer, endspeech, suppress: false)
  suppress = true if suppressEndspeechError(*trainer)
  if !Desolation && battle.endspeech2 != endspeech && $Settings.language == 0 && !suppress
    dp(sprintf("Unexpected battle.endspeech2 override, please report which battle triggered this error.\nnormal: %s\noverride: %s\n\n%s", battle.endspeech2, endspeech, caller[0]))
  end
  # If an endspeech is present both in trainertext and map data, trainertext takes priority
  battle.endspeech2 = endspeech if battle.endspeech2.to_s.empty?
end

def suppressEndspeechError(type, name)
  return true if Rejuv
  return false
end

def getCombinedSpecialMoves(trainer1, trainer2)
  specialmoves1 = trainer1&.specialmoves || []
  specialmoves2 = trainer2&.specialmoves || []
  combinedspecialmoves = specialmoves1 + specialmoves2
  combinedspecialmoves.compact!
  return combinedspecialmoves
end

def autoMinMaxEVAssignment(pokemon)
  baseStats = pokemon.getCacheData.BaseStats # [HP, Attack, Defense, Special Attack, Special Defense, Speed]
  field = determineFieldLayers[-1]

  # Each priority represents how much it would benefit that Pokemon to have that stat's EV value increased
  hpPriority = 0
  atkPriority = 0
  defPriority = 0
  spatkPriority = 0
  spdefPriority = 0
  speedPriority = 0

  # Nature
  nature = $cache.natures[pokemon.nature]
  case nature.incStat
    when PBStats::ATTACK then atkPriority += 2
    when PBStats::DEFENSE then defPriority += 2
    when PBStats::SPATK then spatkPriority += 2
    when PBStats::SPDEF then spdefPriority += 2
    when PBStats::SPEED then speedPriority += 2
  end
  case nature.decStat
    when PBStats::ATTACK then atkPriority -= 2
    when PBStats::DEFENSE then defPriority -= 2
    when PBStats::SPATK then spatkPriority -= 2
    when PBStats::SPDEF then spdefPriority -= 2
    when PBStats::SPEED then speedPriority -= 2
  end

  # Moves
  moveCategoryCount = [0, 0, 0] # [Physical, Special, Status]
  offensivePriorityMoves = 0 # Count of moves with increased or decreased priority
  evenHPMove = [false, false] # [belly drum or fillet away, substitute]
  for move in pokemon.moves
    evenHPMove[0] = true if move.move == :BELLYDRUM || move.move == :FILLETAWAY
    evenHPMove[1] = true if move.move == :SUBSTITUTE
    unless PBStuff::FIXEDDAMAGEFUNCTIONS.include?(move.function) || (field == :DEEPEARTH && move.move == :GRAVITY)
      category = move.category
      if field == :GLITCH && category != :status
        movetype = move.type
        movetype = :NORMAL if PBFields::GlitchTypes.include?(movetype)
        category = PBTypes.isSpecialType?(movetype) ? :special : :physical
      end
      case category
        when :physical then moveCategoryCount[0] += 1
        when :special then moveCategoryCount[1] += 1
        when :status then moveCategoryCount[2] += 1
      end
      offensivePriorityMoves += 1 if move.priority && move.priority != 0 && category != :status
    end
  end

  # Physical Moves
  atkPriority += 1 if moveCategoryCount[0] > 0
  atkPriority += 1 if moveCategoryCount[0] == moveCategoryCount.sum
  atkPriority -= 10 if moveCategoryCount[0] == 0
  # Special Moves
  spatkPriority += 1 if moveCategoryCount[1] > 0
  spatkPriority += 1 if moveCategoryCount[1] == moveCategoryCount.sum
  spatkPriority -= 10 if moveCategoryCount[1] == 0
  # Status Moves
  if moveCategoryCount[2] + 1 == moveCategoryCount.sum && pokemon.level > 10
    defPriority += 1
    spdefPriority += 1
  end
  if moveCategoryCount[2] == moveCategoryCount.sum
    defPriority += 1
    spdefPriority += 1
  end

  # Priority Moves
  if moveCategoryCount[2] != moveCategoryCount.sum && offensivePriorityMoves < moveCategoryCount[0] + moveCategoryCount[1]
    # Comparing base speed against base defensive stats
    if baseStats[5] > baseStats[0] && baseStats[5] > baseStats[2] && baseStats[5] > baseStats[4]
      speedPriority += 1
    end
    if baseStats[5] > (baseStats[0] + baseStats[2] + baseStats[4])/3
      speedPriority += 1
    end
  end
  # Trick Room
  if pokemon.iv.max > 0 && pokemon.iv[5] == 0
    speedPriority -= 10
  end

  # Defensive Base Stats
  if baseStats[0] < 50 && pokemon.level > 20
    hpPriority -= 1
  elsif baseStats[0] > 75 && baseStats[0] <= 90
    hpPriority += 1
  elsif baseStats[0] > 90
    hpPriority += 2
  end
  if baseStats[0] > (baseStats[2] + baseStats[4])/2
    hpPriority += 1
  else
    defPriority += 1
    spdefPriority += 1
  end
  # If there is a large gap between base Defense and Special Defense, increase the priority of the one that's worse in order to close the gap
  if baseStats[2] + 30 <= baseStats[4]
    defPriority += 1
  elsif baseStats[4] + 30 <= baseStats[2]
    spdefPriority += 1
  end

  # Glitch Field Special Stat Merge
  if field == :GLITCH
    if baseStats[3] >= baseStats[4]
      if nature.incStat == PBStats::SPDEF
        nature = $cache.natures.values.find { |nature| nature.incStat == PBStats::SPATK && nature.decStat == PBStats::SPDEF }
      end
      spatkPriority = [spatkPriority, 0].max + [spdefPriority, 0].max unless [spatkPriority, 0].max + [spdefPriority, 0].max == 0
      spdefPriority -= 10
    else
      if nature.incStat == PBStats::SPATK
        nature = $cache.natures.values.find { |nature| nature.incStat == PBStats::SPDEF && nature.decStat == PBStats::SPATK }
      end
      spdefPriority = [spatkPriority, 0].max + [spdefPriority, 0].max unless [spatkPriority, 0].max + [spdefPriority, 0].max == 0
      spatkPriority -= 10
    end
  end

  # Tie Breaking
  # offensivePriority is for mixed attackers, splitting EVs between Attack and Special Attack
  offensivePriority = -10
  # defensivePriority is for mixed defenders, splitting EVs between Defense and Special Defense
  defensivePriority = -10
  # Offensive Stat Ties
  if atkPriority == spatkPriority
    offensivePriority = atkPriority
    atkPriority -= 10
    spatkPriority -= 10
  end
  if defPriority == spdefPriority
    defensivePriority = defPriority
    defPriority -= 10
    spdefPriority -= 10
  end
  # Defensive Stat Ties
  defPriority -= 1 if hpPriority == defPriority
  spdefPriority -= 1 if hpPriority == spdefPriority
  defensivePriority -= 1 if hpPriority == defensivePriority

  if [hpPriority, atkPriority, defPriority, spatkPriority, spdefPriority, speedPriority, offensivePriority, defensivePriority].max(2).include? [atkPriority, spatkPriority, offensivePriority].max
    speedPriority += 1
  else
    speedPriority -= 1
  end

  if [hpPriority, atkPriority, defPriority, spatkPriority, spdefPriority, speedPriority, offensivePriority, defensivePriority].max == [hpPriority, defPriority, spdefPriority, defensivePriority].max &&
     [hpPriority, atkPriority, defPriority, spatkPriority, spdefPriority, speedPriority, offensivePriority, defensivePriority].max(2)[1] == speedPriority
    speedPriority -= 2
  elsif [hpPriority, atkPriority, defPriority, spatkPriority, spdefPriority, speedPriority, offensivePriority, defensivePriority].max == speedPriority &&
     [hpPriority, atkPriority, defPriority, spatkPriority, spdefPriority, speedPriority, offensivePriority, defensivePriority].max(2)[1] == [hpPriority, defPriority, spdefPriority, defensivePriority].max
    hpPriority -= 2
    defPriority -= 2
    spdefPriority -= 2
    defensivePriority -= 2
  end

  priorityArray = [hpPriority, atkPriority, defPriority, spatkPriority, spdefPriority, speedPriority, offensivePriority, defensivePriority]
  priorityArraySort = priorityArray.sort { |a, b| b <=> a } # Sort in descending order

  # Get the indices of the stats with the highest priority
  primaryIndex = priorityArray.each_index.select{|index| priorityArray[index] == priorityArraySort[0]}[0]
  if priorityArraySort[0] == priorityArraySort[1]
    secondaryIndex = priorityArray.each_index.select{|index| priorityArray[index] == priorityArraySort[1]}[1]
    if priorityArraySort[1] == priorityArraySort[2]
      tertiaryIndex = priorityArray.each_index.select{|index| priorityArray[index] == priorityArraySort[2]}[2]
    else
      tertiaryIndex = priorityArray.each_index.select{|index| priorityArray[index] == priorityArraySort[2]}[0]
    end
  else
    secondaryIndex = priorityArray.each_index.select{|index| priorityArray[index] == priorityArraySort[1]}[0]
    if priorityArraySort[1] == priorityArraySort[2]
      tertiaryIndex = priorityArray.each_index.select{|index| priorityArray[index] == priorityArraySort[2]}[1]
    else
      tertiaryIndex = priorityArray.each_index.select{|index| priorityArray[index] == priorityArraySort[2]}[0]
    end
  end

  # EV Assignment
  evs = Array.new(6, 0)
  # 510 starting at level 57
  totalEVs = [510, pokemon.level * 9].min
  if totalEVs <= 504
    evPool = [totalEVs/2, totalEVs/2, 0]
  else
    evPool = [252, 252, (totalEVs - 504)]
  end
  # No stats have a positive priority, default to splitting EVs evenly between each stat
  if priorityArray[primaryIndex] <= 0
    evs = Array.new(6, [85, pokemon.level * 3 / 2].min)
  # Only one stat has a positive priority, put maximum available EVs into that stat, and split the rest
  elsif priorityArray[secondaryIndex] <= 0
    if totalEVs <= 252
      evs[primaryIndex] = evPool.sum if primaryIndex <= 5
      evs[1], evs[3] = evPool.sum/2, evPool.sum/2 if primaryIndex == 6
      evs[2], evs[4] = evPool.sum/2, evPool.sum/2 if primaryIndex == 7
    else
      primaryEV = [252, totalEVs].min
      evs = Array.new(6, (totalEVs - primaryEV)/5)
      evs[primaryIndex] = primaryEV if primaryIndex <= 5
      evs[1], evs[3] = primaryEV/2, primaryEV/2 if primaryIndex == 6
      evs[2], evs[4] = primaryEV/2, primaryEV/2 if primaryIndex == 7
    end
  else
    evs[primaryIndex] = evPool[0] if primaryIndex <= 5
    evs[1], evs[3] = evPool[0]/2, evPool[0]/2 if primaryIndex == 6
    evs[2], evs[4] = evPool[0]/2, evPool[0]/2 if primaryIndex == 7
    evs[secondaryIndex] = evPool[1] if secondaryIndex <= 5
    evs[1], evs[3] = evPool[1]/2, evPool[1]/2 if secondaryIndex == 6
    evs[2], evs[4] = evPool[1]/2, evPool[1]/2 if secondaryIndex == 7
    evs[tertiaryIndex] = evPool[2] if tertiaryIndex <= 5
    evs[1] = evPool[2] if tertiaryIndex == 6 && !([primaryIndex, secondaryIndex].include? 1)
    evs[2] = evPool[2] if tertiaryIndex == 7 && !([primaryIndex, secondaryIndex].include? 2)
  end

  unless pokemon.species == :SHEDINJA
    if evenHPMove[0] || evenHPMove[1]
      hp = ((2 * baseStats[0] + pokemon.iv[0] + (evs[0] / 4).floor) * pokemon.level / 100).floor + pokemon.level + 10
      leftoverEVs = 0
      # Makes sure it's possible to actually get the desired HP stat
      minHP = ((2 * baseStats[0] + pokemon.iv[0] + (0 / 4).floor) * pokemon.level / 100).floor + pokemon.level + 10
      maxHP = ((2 * baseStats[0] + pokemon.iv[0] + ([252, totalEVs].min / 4).floor) * pokemon.level / 100).floor + pokemon.level + 10
      canEvenHP = false
      closestHPs = [-Float::INFINITY, Float::INFINITY]
      if maxHP - minHP < 4
        for i in minHP..maxHP
          next unless (i % 4 == 0 && evenHPMove[1]) || (i % 2 == 0 && !evenHPMove[1])
          canEvenHP = true
          if i > hp && closestHPs[1] == Float::INFINITY
            closestHPs[1] = i
          elsif i < hp
            closestHPs[0] = i
          end
        end
      else
        canEvenHP = true
      end

      if evenHPMove[1] && canEvenHP == true
        while hp % 4 != 0
          if hp - closestHPs[0] <= closestHPs[1] - hp
            evs[0] -= 4
            leftoverEVs += 4
          else
            evs[evs.find_index(evs[1..5].max)] -= 4
            evs[0] += 4
          end
          hp = ((2 * baseStats[0] + pokemon.iv[0] + (evs[0] / 4).floor) * pokemon.level / 100).floor + pokemon.level + 10
        end
      elsif evenHPMove[0] && canEvenHP == true
        while hp % 2 != 0
          if hp - closestHPs[0] <= closestHPs[1] - hp
            evs[0] -= 4
            leftoverEVs += 4
          else
            evs[evs.find_index(evs[1..5].max)] -= 4
            evs[0] += 4
          end
          hp = ((2 * baseStats[0] + pokemon.iv[0] + (evs[0] / 4).floor) * pokemon.level / 100).floor + pokemon.level + 10
        end
      end
      while leftoverEVs >= 4
        if primaryIndex != 0 && primaryIndex <= 5 && evs[primaryIndex] <= 248
          leftoverEVs -= 4
          evs[primaryIndex] += 4
        elsif secondaryIndex != 0 && secondaryIndex <= 5 && evs[secondaryIndex] <= 248
          leftoverEVs -= 4
          evs[secondaryIndex] += 4
        elsif tertiaryIndex != 0 && tertiaryIndex <= 5 && !evs[tertiaryIndex].nil? && evs[tertiaryIndex] <= 248
          leftoverEVs -= 4
          evs[tertiaryIndex] += 4
        else
          leftoverEVs -= 4
          evs[evs.find_index(evs[1..5].min)] += 4
        end
      end
    end
  end

  # Handling of extra EVs
  leftoverEVs = 0
  for i in 0..5
    leftoverEVs += evs[i] % 4
    evs[i] -= evs[i] % 4
  end
  while leftoverEVs >= 4
    if primaryIndex > 5
      if primaryIndex == 6 && evs[1] <= 248 && evs[1] <= evs[3]
        evs[1] += 4
        leftoverEVs -= 4
      elsif primaryIndex == 6 && evs[3] <= 248 && evs[3] <= evs[1]
        evs[3] += 4
        leftoverEVs -= 4
      elsif primaryIndex == 7 && evs[2] <= 248 && evs[2] <= evs[4]
        evs[2] += 4
        leftoverEVs -= 4
      elsif primaryIndex == 7 && evs[4] <= 248 && evs[4] <= evs[2]
        evs[4] += 4
        leftoverEVs -= 4
      end
    elsif primaryIndex == 0 && secondaryIndex > 5
      if secondaryIndex == 6 && evs[1] <= 248 && evs[1] <= evs[3]
        evs[1] += 4
        leftoverEVs -= 4
      elsif secondaryIndex == 6 && evs[3] <= 248 && evs[3] <= evs[1]
        evs[3] += 4
        leftoverEVs -= 4
      elsif secondaryIndex == 7 && evs[2] <= 248 && evs[2] <= evs[4]
        evs[2] += 4
        leftoverEVs -= 4
      elsif secondaryIndex == 7 && evs[4] <= 248 && evs[4] <= evs[2]
        evs[4] += 4
        leftoverEVs -= 4
      end
    else
      if evs[primaryIndex] <= 248 && primaryIndex != 0
        evs[primaryIndex] += 4
        leftoverEVs -= 4
      elsif secondaryIndex == 6 && evs[1] <= 248
        evs[1] += 4
        leftoverEVs -= 4
      elsif secondaryIndex == 6 && evs[3] <= 248
        evs[3] += 4
        leftoverEVs -= 4
      elsif secondaryIndex == 7 && evs[2] <= 248
        evs[2] += 4
        leftoverEVs -= 4
      elsif secondaryIndex == 7 && evs[4] <= 248
        evs[4] += 4
        leftoverEVs -= 4
      elsif evs[secondaryIndex] <= 248 && secondaryIndex != 0
        evs[secondaryIndex] += 4
        leftoverEVs -= 4
      elsif tertiaryIndex == 6 && evs[1] <= 248
        evs[1] += 4
        leftoverEVs -= 4
      elsif tertiaryIndex == 6 && evs[3] <= 248
        evs[3] += 4
        leftoverEVs -= 4
      elsif tertiaryIndex == 7 && evs[2] <= 248
        evs[2] += 4
        leftoverEVs -= 4
      elsif tertiaryIndex == 7 && evs[4] <= 248
        evs[4] += 4
        leftoverEVs -= 4
      elsif evs[tertiaryIndex] <= 248 && tertiaryIndex != 0
        evs[tertiaryIndex] += 4
        leftoverEVs -= 4
      else
        for i in 1..5
          if evs[i] <= 248
            evs[i] += 4
            leftoverEVs -= 4
            break
          end
        end
      end
    end
  end

  # Setting nature
  if nature.incStat == nature.decStat
    pbStatArray = PBStats::Omni
    # Handling of offensivePriority and defensivePriority so they don't mess with the nature selection
    priorityArray[1] += 10 if [primaryIndex, secondaryIndex, tertiaryIndex].include? 6
    priorityArray[3] += 10 if [primaryIndex, secondaryIndex, tertiaryIndex].include? 6
    priorityArray[2] += 10 if [primaryIndex, secondaryIndex, tertiaryIndex].include? 7
    priorityArray[4] += 10 if [primaryIndex, secondaryIndex, tertiaryIndex].include? 7
    # Increased stat is whichever non-HP stat has the most EVs
    # Decreased stat is whichever non-HP stat has the lowest priority
    nature = $cache.natures.values.find { |nature| nature.incStat == pbStatArray[evs[1..5].find_index(evs[1..5].max)] && nature.decStat == pbStatArray[priorityArray[1..5].find_index(priorityArray[1..5].min)] }
    nature = $cache.natures[:HARDY] if nature.nil?
  end

  return evs, nature.nature
end

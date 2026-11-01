def pbEggGenerated?
  return false if pbDayCareDeposited != 2

  return $PokemonGlobal.daycareEgg == 1
end

def pbDayCareDeposited
  ret = 0
  for i in 0...2
    ret += 1 if $PokemonGlobal.daycare[i][0]
  end
  return ret
end

def pbDayCareDeposit(index)
  for i in 0...2
    if !$PokemonGlobal.daycare[i][0]
      $PokemonGlobal.daycare[i][0] = $Trainer.party[index]
      $PokemonGlobal.daycare[i][1] = $Trainer.party[index].level
      $PokemonGlobal.daycare[i][0].heal if !$game_switches[:Nuzlocke_Mode]
      $Trainer.party[index] = nil
      $Trainer.party.compact!
      $PokemonGlobal.daycareEgg = 0
      $PokemonGlobal.daycareEggSteps = 0
      $PokemonGlobal.daycareTransferSteps = 0
      return
    end
  end
  raise _INTL("No room to deposit a Pokémon")
end

def pbDayCareGetLevelGain(index, nameVariable, levelVariable)
  pkmn = $PokemonGlobal.daycare[index][0]
  return false if !pkmn

  $game_variables[nameVariable] = pkmn.name
  $game_variables[levelVariable] = pkmn.level - $PokemonGlobal.daycare[index][1]
  return true
end

def pbDayCareGetDeposited(index, nameVariable, costVariable)
  for i in 0...2
    if (index < 0 || i == index) && $PokemonGlobal.daycare[i][0]
      cost = $PokemonGlobal.daycare[i][0].level - $PokemonGlobal.daycare[i][1]
      cost += 1
      cost *= 100
      $game_variables[costVariable] = cost if costVariable >= 0
      $game_variables[nameVariable] = $PokemonGlobal.daycare[i][0].name if nameVariable >= 0
      return
    end
  end
  raise _INTL("Can't find deposited Pokémon")
end

def pbIsDitto?(pokemon)
  return pokemon.species == :DITTO
end

def pbDayCareCompatibleGender(pokemon1, pokemon2)
  if (pokemon1.isFemale? && pokemon2.isMale?) ||
     (pokemon1.isMale? && pokemon2.isFemale?)
    return true
  end

  ditto1 = pbIsDitto?(pokemon1)
  ditto2 = pbIsDitto?(pokemon2)
  return true if ditto1 && !ditto2
  return true if ditto2 && !ditto1

  return false
end

def pbDayCareGetCompat
  return 0 if pbDayCareDeposited != 2

  pokemon1 = $PokemonGlobal.daycare[0][0]
  pokemon2 = $PokemonGlobal.daycare[1][0]
  return 0 if (pokemon1.isShadow? rescue false)
  return 0 if (pokemon2.isShadow? rescue false)

  compat1 = pokemon1.eggGroups
  compat2 = pokemon2.eggGroups
  # check array intersection or ditto
  return 0 if compat1.include?(:Undiscovered) || compat2.include?(:Undiscovered)

  if compat1.intersect?(compat2) || pokemon1.species == :DITTO || pokemon2.species == :DITTO
    if pbDayCareCompatibleGender(pokemon1, pokemon2)
      if pokemon1.species == pokemon2.species
        return pokemon1.trainerID == pokemon2.trainerID ? 2 : 3
      else
        return pokemon1.trainerID == pokemon2.trainerID ? 1 : 2
      end
    end
  end
  return 0
end

def pbDayCareGetCompatibility(variable)
  $game_variables[variable] = pbDayCareGetCompat
end

def pbDayCareWithdraw(index)
  if !$PokemonGlobal.daycare[index][0]
    raise _INTL("There's no Pokémon here...")
  else
    addPkmnToPartyOrPC($PokemonGlobal.daycare[index][0])
    lvldiff = $PokemonGlobal.daycare[index][0].level - $PokemonGlobal.daycare[index][1]
    pkmn = $PokemonGlobal.daycare[index][0]
    movelist = pkmn.getMoveList
    for i in 1..lvldiff
      for j in movelist
        pkmn.pbLearnMove(j[1]) if j[0] == ($PokemonGlobal.daycare[index][1] + i) # Learned a new move
      end
    end
    $PokemonGlobal.daycare[index][0] = nil
    $PokemonGlobal.daycare[index][1] = 0
    $PokemonGlobal.daycare[index][2] = []
    $PokemonGlobal.daycareEgg = 0
    $PokemonGlobal.daycare[1], $PokemonGlobal.daycare[0] = $PokemonGlobal.daycare[0], $PokemonGlobal.daycare[1] if index == 0
  end
end

def pbDayCareChoose(text, variable)
  count = pbDayCareDeposited
  if count == 0
    raise _INTL("There's no Pokémon here...")
  elsif count == 1
    $game_variables[variable] = $PokemonGlobal.daycare[0][0] ? 0 : 1
  else
    choices = []
    colors = isCurrentWindowskinDark ? ColorTags : LightColorTags
    for i in [1, 0]
      pokemon = $PokemonGlobal.daycare[i][0]
      genderstr = pokemon.isGenderless? ? "" : colors[genderColor(pokemon.gender)] + genderSign(pokemon.gender) + "</c3>, "
      pokemonstr = _ISPRINTF("{1:s}<r>{2:s}Lv{3:d}", pokemon.name, genderstr, pokemon.level)
      choices.push(pokemonstr)
    end
    choices.push(_INTL("Cancel"))
    command = Kernel.pbMessageAdvanced(text, choices, choices.length)
    $game_variables[variable] = command == 2 ? -1 : [1, 0][command]
  end
end

def pbTransferShadowMoves(gifter, recipient, recIndex, singlemove = false)
  return unless Rejuv
  return unless recipient.moves.length < 4
  return unless gifter.purified == true
  return unless gifter.species == recipient.species
  return unless gifter.form == recipient.form

  $PokemonGlobal.daycare[recIndex][2] ||= []

  # Gen 8 same-species feature does not allow transferral of incense baby egg moves between higher evo stages (eg, Marill and Azumarill can transfer only Marill's egg moves, not Azurill's)
  # However, this is not the case in Gen 9 as the possibility of incense babies having different egg moves was removed
  # Hence, for QoL, we allow transferral of egg moves of all lower evo stages between higher ones
  shadowmoves = gifter.firstmoves.select{ |move| !recipient.getAllLegalMoves(true).include?(move)}
  # Intersection of gifter's known moves and recipient's egg moves, subtracting any already known by recipient
  passmoves = gifter.moves.map(&:move).intersection(shadowmoves) - recipient.moves.map(&:move)

  numslots = [4 - recipient.moves.length, passmoves.length].min
  numslots = 1 if numslots > 1 && singlemove

  numslots.times {
    recipient.moves.append(PBMove.new(passmoves[0]))
    recipient.addLearntEggMove(passmoves[0])
    recipient.firstmoves.push(passmoves[0])
    recipient.item = nil if singlemove # Consume Mirror Sprig
    $PokemonGlobal.daycare[recIndex][2].append(passmoves.shift) # For the Day-Care NPC to mention the moves learnt
  }
end


def pbTransferEggMoves(gifter, recipient, recIndex, singlemove = false)
  return unless recipient.moves.length < 4

  $PokemonGlobal.daycare[recIndex][2] ||= []

  # Gen 8 same-species feature does not allow transferral of incense baby egg moves between higher evo stages (eg, Marill and Azumarill can transfer only Marill's egg moves, not Azurill's)
  # However, this is not the case in Gen 9 as the possibility of incense babies having different egg moves was removed
  # Hence, for QoL, we allow transferral of egg moves of all lower evo stages between higher ones
  eggmoves = recipient.getEggMoveList
  # Intersection of gifter's known moves and recipient's egg moves, subtracting any already known by recipient
  passmoves = gifter.moves.map(&:move).intersection(eggmoves) - recipient.moves.map(&:move)

  numslots = [4 - recipient.moves.length, passmoves.length].min
  numslots = 1 if numslots > 1 && singlemove

  numslots.times {
    recipient.moves.append(PBMove.new(passmoves[0]))
    recipient.addLearntEggMove(passmoves[0])
    recipient.item = nil if singlemove # Consume Mirror Sprig
    $PokemonGlobal.daycare[recIndex][2].append(passmoves.shift) # For the Day-Care NPC to mention the moves learnt
  }
end

def pbDayCareTransferEggMoves
  pkmn1, pkmn2 = $PokemonGlobal.daycare[0][0], $PokemonGlobal.daycare[1][0]

  if [:MIRRORHERB, :MIRRORSPRIG].include?(pkmn1.item)
    pbTransferShadowMoves(pkmn2, pkmn1, 0, pkmn1.item == :MIRRORSPRIG)
  end
  if [:MIRRORHERB, :MIRRORSPRIG].include?(pkmn2.item)
    pbTransferShadowMoves(pkmn1, pkmn2, 1, pkmn2.item == :MIRRORSPRIG)
  end

  # Gen 8 feature
  if pbCanTransferEggMovesWithoutItem?(pkmn1, pkmn2)
    pbTransferEggMoves(pkmn1, pkmn2, 1)
    pbTransferEggMoves(pkmn2, pkmn1, 0)
    return
  end

  # Gen 9 feature + Custom
  if [:MIRRORHERB, :MIRRORSPRIG].include?(pkmn1.item)
    pbTransferEggMoves(pkmn2, pkmn1, 0, pkmn1.item == :MIRRORSPRIG)
  end
  if [:MIRRORHERB, :MIRRORSPRIG].include?(pkmn2.item)
    pbTransferEggMoves(pkmn1, pkmn2, 1, pkmn2.item == :MIRRORSPRIG)
  end
end

def pbCanTransferEggMovesWithoutItem?(pkmn1, pkmn2)
  return false unless pkmn1.getEggMoveList == pkmn2.getEggMoveList # accounts for forms without involving cosmetic forms; form differences barred egg move list should be same for same species and across evo line
  return true if pkmn1.species == pkmn2.species
  return true if pbGetBabySpecies(pkmn1.species, pkmn1.form) == pbGetBabySpecies(pkmn2.species, pkmn2.form) # Additional QoL: Allow transfer across evo family
  return false
end

def pbDayCareGetLearnedMoves(index, nameVariable, moveVariable)
  pkmn = $PokemonGlobal.daycare[index][0]
  return false if !pkmn
  return false if !$PokemonGlobal.daycare[index][2] || $PokemonGlobal.daycare[index][2].empty?

  $game_variables[nameVariable] = pkmn.name
  moves = $PokemonGlobal.daycare[index][2]
  case moves.length
    when 1 then moveString = "#{getMoveName(moves[0])}"
    when 2 then moveString = "#{getMoveName(moves[0])} and #{getMoveName(moves[1])}"
    when 3 then moveString = "#{getMoveName(moves[0])}, #{getMoveName(moves[1])}, and #{getMoveName(moves[2])}"
  end
  $game_variables[moveVariable] = moveString
  return true
end

def pbDayCareGenerateEgg
  if pbDayCareDeposited != 2
    return
    # elsif $Trainer.party.length>=6
    #   raise _INTL("Can't store the egg")
  end

  pokemon0 = $PokemonGlobal.daycare[0][0]
  pokemon1 = $PokemonGlobal.daycare[1][0]
  ditto0 = pbIsDitto?(pokemon0)
  ditto1 = pbIsDitto?(pokemon1)
  if pokemon0.isFemale? || (ditto0 && !pokemon1.isFemale?)
    mother = pokemon0
    father = pokemon1
    mainparent = ditto0 ? father : mother
  else
    mother = pokemon1
    father = pokemon0
    mainparent = ditto1 ? father : mother
  end
  otherparent = mainparent == mother ? father : mother
  babyspecies = pbGetBabySpecies(mainparent.species, mainparent.form, items: [mother.item, father.item])

  if babyspecies[0] == :MANAPHY && !$cache.pkmn[:PHIONE].nil?
    babyspecies[0] = :PHIONE
  elsif babyspecies[0] == :NIDORANfE && !$cache.pkmn[:NIDORANmA].nil?
    babyspecies[0] = [:NIDORANmA, :NIDORANfE][rand(2)]
  elsif babyspecies[0] == :NIDORANmA && !$cache.pkmn[:NIDORANfE].nil?
    babyspecies[0] = [:NIDORANmA, :NIDORANfE][rand(2)]
  elsif babyspecies[0] == :VOLBEAT && !$cache.pkmn[:ILLUMISE].nil?
    babyspecies[0] = [:VOLBEAT, :ILLUMISE][rand(2)]
  elsif babyspecies[0] == :ILLUMISE && !$cache.pkmn[:VOLBEAT].nil?
    babyspecies[0] = [:VOLBEAT, :ILLUMISE][rand(2)]
  elsif [:FURFROU, :ROTOM, *(Rejuv ? [:SOLROCK, :LUNATONE] : [])].include?(babyspecies[0])
    babyspecies[1] = 0
  end

  # Generate egg
  egg = PokeBattle_Pokemon.new(babyspecies[0], EGGINITIALLEVEL, $Trainer, false, babyspecies[1])

  # Inheriting Moves
  moves = []
  othermoves = []
  movefather = father
  movefather = mother if pbIsDitto?(movefather) && !mother.isFemale?
  # Initial Moves
  initialmoves = egg.getMoveList
  for k in initialmoves
    if k[0] <= EGGINITIALLEVEL
      moves.push(k[1])
    else
      othermoves.push(k[1]) if mother.knowsMove?(k[1]) && father.knowsMove?(k[1])
    end
  end
  # Inheriting Natural Moves
  for move in othermoves
    moves.push(move)
  end
  # Inheriting Machine Moves
  # Inheriting Egg Moves
  eggmoves = egg.getEggMoveList(true)
  if eggmoves
    for move in eggmoves
      moves.push(move) if father.knowsMove?(move)
      moves.push(move) if mother.knowsMove?(move)
    end
  end
  # Volt Tackle
  if babyspecies[0] == :PICHU && [mother, father].any? { |parent| parent.item == :LIGHTBALL && [:PIKACHU, :RAICHU].include?(parent.species) }
    moves.push(:VOLTTACKLE)
  end

  moves = moves.reverse
  moves |= [] # remove duplicates
  moves = moves.reverse # This is to ensure deletion of duplicates is from the start, not the end

  # Assembling move list
  finalmoves = []
  listend = moves.length - 4
  listend = 0 if listend < 0
  j = 0
  for i in listend..listend + 3
    moveid = moves[i]
    finalmoves[j] = moveid.nil? ? nil : PBMove.new(moveid)
    j += 1
  end
  # Inheriting Individual Values
  ivs = []
  for i in 0...6
    ivs[i] = rand(32)
  end
  ivinherit = []
  powercount = 0
  for i in 0...2
    parent = [mother, father][i]
    if parent.item == :POWERWEIGHT || parent.item == :CANONPOWERWEIGHT
      ivinherit[i] = PBStats::HP
      powercount += 1
    end
    if parent.item == :POWERBRACER || parent.item == :CANONPOWERBRACER
      ivinherit[i] = PBStats::ATTACK
      powercount += 1
    end
    if parent.item == :POWERBELT || parent.item == :CANONPOWERBELT
      ivinherit[i] = PBStats::DEFENSE
      powercount += 1
    end
    if parent.item == :POWERLENS || parent.item == :CANONPOWERLENS
      ivinherit[i] = PBStats::SPATK
      powercount += 1
    end
    if parent.item == :POWERBAND || parent.item == :CANONPOWERBAND
      ivinherit[i] = PBStats::SPDEF
      powercount += 1
    end
    if parent.item == :POWERANKLET || parent.item == :CANONPOWERANKLET
      ivinherit[i] = PBStats::SPEED
      powercount += 1
    end
  end
  num = 0
  r = rand(2)
  for i in 0...2
    if ivinherit[r] != nil
      parent = [mother, father][r]
      ivs[ivinherit[r]] = parent.iv[ivinherit[r]]
      num += 1
      break if num == powercount
    end
    r = (r + 1) % 2
  end

  destiny = mother.item == :DESTINYKNOT || father.item == :DESTINYKNOT

  i = 0
  stats = [PBStats::HP, PBStats::ATTACK, PBStats::DEFENSE, PBStats::SPATK, PBStats::SPDEF, PBStats::SPEED]
  loop do
    r = stats.sample
    if !ivinherit.include?(r)
      parent = [mother, father].sample
      ivs[r] = parent.iv[r]
      ivinherit.push(r)
      i += 1
    end

    # inheriting conditional
    # d.knot
    if destiny
      break if i == 4 && powercount == 1
      break if i == 5
    # no d.knot; power item(s)
    elsif powercount > 0
      break if i == 2
    # no d.knot; no power item(s)
    else
      break if i == 3
    end
  end

  # Inheriting nature
  newnatures = []
  newnatures.push(mother.nature) if mother.item == :EVERSTONE
  newnatures.push(father.nature) if father.item == :EVERSTONE
  if newnatures.length > 0
    egg.setNature(newnatures[rand(newnatures.length)])
  end
  # Masuda method and Shiny Charm
  shinyretries = 0
  shinyretries += 5 if father.language != mother.language
  if shinyretries > 0
    shinyretries.times do
      break if egg.isShiny?

      egg.personalID = rand(65536) | (rand(65536) << 16)
    end
  end
  egg.ballused = pbDayCareChooseOffspringBall(mainparent, otherparent)
  egg.iv[0] = ivs[0]
  egg.iv[1] = ivs[1]
  egg.iv[2] = ivs[2]
  egg.iv[3] = ivs[3]
  egg.iv[4] = ivs[4]
  egg.iv[5] = ivs[5]
  egg.iv.map! { |_| 31 } if $game_switches[:Full_IVs]
  egg.iv.map! { |_| 0 } if $game_switches[:Empty_IVs_Password]
  egg.moves[0] = finalmoves[0]
  egg.moves[1] = finalmoves[1]
  egg.moves[2] = finalmoves[2]
  egg.moves[3] = finalmoves[3]
  egg.moves.compact!
  egg.calcStats
  egg.obtainText = _INTL("Day-Care Couple")
  egg.name = _INTL("Egg")
  egg.eggsteps = egg.getCacheData.EggSteps
  if rand(65536) < POKERUSCHANCE
    egg.givePokerus
  end
  # $Trainer.party[$Trainer.party.length]=egg
  addPkmnToPartyOrPC(egg)
end

NON_INHERITABLE_BALLS = [:MASTERBALL, :CHERISHBALL]

def pbDayCareChooseOffspringBall(mainparent, otherparent)
  balls = []
  balls.push(mainparent.ballused)
  mainparentbaby = pbGetBabySpecies(mainparent.species)[0]
  otherparentbaby = pbGetBabySpecies(otherparent.species)[0]
  if mainparentbaby == otherparentbaby ||
     mainparentbaby == :NIDORANfE && otherparentbaby == :NIDORANmA ||
     mainparentbaby == :ILLUMISE && otherparentbaby == :VOLBEAT
    balls.push(otherparent.ballused)
  end
  ball = balls.sample
  return :POKEBALL if NON_INHERITABLE_BALLS.include?(ball)

  return ball
end

Events.onStepTaken += proc { |sender, e|
  next if !$Trainer

  # Check for generating an egg
  if pbDayCareDeposited == 2 && $PokemonGlobal.daycareEgg == 0
    $PokemonGlobal.daycareEggSteps = 0 if !$PokemonGlobal.daycareEggSteps
    $PokemonGlobal.daycareEggSteps += 1
    if $PokemonGlobal.daycareEggSteps == 256
      $PokemonGlobal.daycareEggSteps = 0
      chances = $PokemonBag.pbHasItem?(:OVALCHARM) ? [0, 40, 80, 88] : [0, 20, 50, 70]
      if rand(100) < chances[pbDayCareGetCompat]
        $PokemonGlobal.daycareEgg = 1 # Egg is generated
      end
    end
  end

  # Sword and Shield egg move transference qol
  if pbDayCareDeposited == 2
    $PokemonGlobal.daycareTransferSteps = 0 if !$PokemonGlobal.daycareTransferSteps
    $PokemonGlobal.daycareTransferSteps += 1
    if $PokemonGlobal.daycareTransferSteps == 256
      $PokemonGlobal.daycareTransferSteps = 0
      pbDayCareTransferEggMoves
    end
  end

  # Give exp to mons in day-care
  for i in 0...2
    pkmn = $PokemonGlobal.daycare[i][0]
    next if !pkmn

    maxexp = PBExp.maxExperience(pkmn.growthrate)
    if $game_switches[:Hard_Level_Cap] || !Reborn # Rejuv-style Level Cap
      badgenum = $Trainer.numbadges
      if badgenum != 18
        maxexp = PBExp.startExperience(LEVELCAPS[badgenum], pkmn.growthrate)
      end
    end
    if (pkmn.exp < maxexp && posExp?) || (pkmn.exp > 0 && negExp?)
      # Exp Increases
      if $game_switches[:Percent_Exp_Gains]
        $game_variables[:Exp_DayCare] += $game_variables[:Exp_Percent]
        pkmn.exp += ($game_variables[:Exp_DayCare] / 100).floor if (pkmn.exp + ($game_variables[:Exp_DayCare] / 100).floor) > 0
        pkmn.exp = 1 if (pkmn.exp + ($game_variables[:Exp_DayCare] / 100).floor) < 1
        $game_variables[:Exp_DayCare] %= 100
      else
        pkmn.exp += 1
      end
      newlevel = PBExp.levelFromExperience(pkmn.exp, pkmn.growthrate)
      if newlevel != pkmn.level
        pkmn.level = newlevel
        pkmn.calcStats
        # We don't want mons in day care to lose moves by learning new ones
        # movelist = pkmn.getMoveList
        # for i in movelist
        #   pkmn.pbLearnMove(i[1]) if i[0] == pkmn.level # Learned a new move
        # end
      end
    end
  end
}

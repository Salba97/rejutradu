# The functions here can be used to update our data to match https://pokeapi.co/

def updateMovesetsGen(gen)
  if Reborn && Gen != Champs
    unless Kernel.pbConfirmMessage(_INTL("'Gen' is currently set to {1}, rather than the latest {2}. Continue anyway?", Gen, Champs))
      return
    end
  end

  $validator = Validator.new unless $validator
  $validator.updateMovesets(gen)
end

# The following functions are relating to converting data from the Fortelle's github repository and the SV Waza dump into data usable by Reborn
# Fortelle Repository - https://github.com/Fortelle/pokemon-learnsets
# Fortelle SV Level Up Move Data - https://github.com/Fortelle/pokemon-learnsets/blob/master/raw/scarletviolet%403.0.0/levelup.txt
# Fortelle SWSH Level Up Move Data - https://github.com/Fortelle/pokemon-learnsets/blob/master/raw/swordshield%401.3.0/levelup.txt
# Fortelle BDSP Level Up Move Data - https://github.com/Fortelle/pokemon-learnsets/blob/master/raw/brilliantdiamondshiningpearl/levelup.txt
# Fortelle USUM Level Up Move Data - https://github.com/Fortelle/pokemon-learnsets/blob/master/raw/ultrasunultramoon/levelup.txt
# Fortelle SV Relearner Move Data - https://github.com/Fortelle/pokemon-learnsets/blob/master/raw/scarletviolet%403.0.0/reminder.txt
# SV Waza Dump - https://docs.google.com/spreadsheets/d/e/2PACX-1vQ7fyhklDZd0Q_hoAHTrDUSWga28rjdBaWxNJm-bXcuZVM0_r7LDrUKoSpLJeqrLA/pubhtml
# Note: The move ID 0 was removed, as were all the columns except the first two
# projectpokemon champout Repository - https://github.com/projectpokemon/champout
# projectpokemon champout Move Data - https://github.com/projectpokemon/champout/blob/main/masterdata/waza.json
# projectpokemon champout Move Learn Data - https://github.com/projectpokemon/champout/blob/main/masterdata/waza_learn.json
# projectpokemon za-textport Repository - https://github.com/projectpokemon/za-textport
# projectpokemon za-textport Move Learn Data - https://github.com/projectpokemon/za-textport/blob/main/Raw/personal_array.json


# Converts the raw Fortelle level up and relearner moveset data into a Validator method containing a hash, contained within its own script file
def fortelleDataToUsable()
  relearnerToUsable()
  movesetToUsable("USUM")
  movesetToUsable("BDSP")
  movesetToUsable("SWSH")
  movesetToUsable("SV")
end

# Fortelle Relearner Moves

# Reads the raw Fortelle relearner moveset data and maps it into a dictionary, with the key being an array, specifically [dex number, form number]
# The value those keys map to would be the array of move ids that Pokemon can relearn
def relearnerData()
  reminderDict = {}
  File.foreach(scripts_path + "/Datasets/Fortelle/Raw/SV/reminder.txt") { |line|
    # [Dex number, form number] => [relearner move ids]
    reminderDict[[line[0..3].to_i, line[5..6].to_i]] = line[8..-1].split(",").map(&:to_i)
  }
  nonEmptyReminderDict = reminderDict.select { |key, value| value != [0] }
  return nonEmptyReminderDict
end

# Converts csv of move ids and their associated move to a dictionary for mapping move ids to their associated move
def moveIDToName()
  require 'csv'

  moveDict = {}
  CSV.foreach(scripts_path + "/Datasets/moveIDs.csv") do |row|
    # Ensures that the correct type of apostrophe is used
    nameChanges = {
      "`" => "'",
      "’" => "'",
    }
    moveName = row[1].gsub(Regexp.union(nameChanges.keys), nameChanges)
    moveDict[row[0].to_i] = moveName
  end
  return moveDict
end

# Converts the raw Fortelle relearner moveset data into a Validator class method for getting the Fortelle relearner moveset of a Pokemon
def relearnerToUsable()
  relearnerMoveID = relearnerData()
  moveDict = moveIDToName()
  # Maps [dex number, form number] to [relearner move names]
  relearnerMoves = {}
  relearnerMoveID.keys.each do |pkmn|
    relearnerMovepool = relearnerMoveID[pkmn]
    relearnerMoves[pkmn] = []
    relearnerMovepool.each do |moveID|
      relearnerMoves[pkmn].push(moveDict[moveID])
    end
  end
  # Writes the data as a hash within a Validator class method into a ruby script file
  File.open(scripts_path + "/Datasets/Fortelle/Usable/SV/reminder.rb", 'w') do |file|
    file.write("class Validator\n")
    file.write("  def assertUpdatedRelearnerMoves(pkmn, i)\n")
    file.write("    return {\n")
    relearnerMoves.each{ |k, v| file.write("      #{k} => #{v},\n") }
    file.write("    }[[pkmn[0].dexnum, i]]\n")
    file.write("  end\n")
    file.write("end")
  end
  return relearnerMoves
end

# Fortelle Level Up Moves

# Reads the raw Fortelle level up moveset data and maps it into a dictionary, with the key being an array, specifically [dex number, form number]
# The value those keys map to would be an array of arrays containing move ids that Pokemon can learn and the level they are learned, in [level, move id] format
# Takes a string of the acronym of the game the level up move data is from as input, specifically BDSP, SWSH, and SV
def movesetData(game)
  levelUpDict = {}
  # The formatting for SWSH and USUM is slightly different than BDSP and SV, so the handling is split
  if game == "SWSH" || game == "USUM"
    file = scripts_path + "/Datasets/Fortelle/raw/" + game + "/levelup.txt"
    File.foreach(file) { |line|
      levelUpDict[[line[0..2].to_i, line[4..5].to_i]] = line[7..-1].split(",")
    }
  else
    file = scripts_path + "/Datasets/Fortelle/raw/" + game + "/levelup.txt"
    File.foreach(file) { |line|
      levelUpDict[[line[0..3].to_i, line[5..6].to_i]] = line[8..-1].split(",")
    }
  end
  levelUpDictLevelMove = {}
  levelUpDict.each do |key, value|
    levelUpMoveList = []
    value.each do |move|
      levelMovePair = move.split(":")
      levelMovePair[0], levelMovePair[1] = levelMovePair[1].to_i, levelMovePair[0].to_i
      # The Fortelle data has -3 as the indicator for moves learned on evolution, while Reborn has it as 0
      levelMovePair[0] = 0 if levelMovePair[0] == -3
      levelUpMoveList.push(levelMovePair)
    end

    key[1] = $validator.adjustVarietyIndex(key[0], key[1])
    levelUpDictLevelMove[key] = levelUpMoveList
  end
  noInherit = [0, 11, 14, 266, 268, 448, 665] # dummy, metapod, kakuna, silcoon, cascoon, lucario, spewpa
  if game == "BDSP"
    levelUpDict.each do |key, value|
      next if noInherit.include?(key[0])
      key[1] = $validator.adjustVarietyIndex(key[0], key[1])
      species = $cache.pkmn.keys[key[0]-1]
      raise "incorrect species" if $cache.pkmn[species, key[1]].dexnum != key[0]
      preevo = pbGetPreviousForm(species, key[1])
      next if preevo == [species, key[1]]
      moveList = levelUpDictLevelMove[key]
      preEvoMoveList = levelUpDictLevelMove[[$cache.pkmn[*preevo].dexnum, preevo[1]]]
      next if !preEvoMoveList # if the preevo somehow has no movelist at all then we are looking at a faulty formtranslation (i.e Mega gyarados to aevian gyarados)
      firstEvo = pbGetPreviousForm(*preevo)
      insertIndex = moveList.find_index { |value| value[0] > 1}
      insertIndex = -1 if !insertIndex
      moveList = moveList.transpose
      preEvoMoveList = preEvoMoveList.transpose
      movediffs = []
      if firstEvo != preevo && noInherit.include?($cache.pkmn[*preevo].dexnum)
        firstEvoMoveList = levelUpDictLevelMove[[$cache.pkmn[*firstEvo].dexnum, firstEvo[1]]]
        firstEvoMoveList = firstEvoMoveList.transpose
        movediffs += (firstEvoMoveList[1] - moveList[1])
      end
      movediffs += (preEvoMoveList[1] - moveList[1])
      movediffs = movediffs.uniq
      # adjusting weird cases where the order is either not automateable or a move is missing
      case key
        when [15, 0] then movediffs.insert(0, 40) # beedrill misses poison sting due to filtering the method uses that is correct in every other case
        when [192, 0] # sunflora has tackle shuffled to the end
          movediffs -= [33]
          movediffs.push(33)
        when [267, 0], [269, 0] # Beautifly and Dustox have harden earlier in the list than they should
          movediffs -= [106]
          movediffs.insert(2, 106)
        when [289, 0] # slaking has reversal shuffled to the end
          movediffs -= [179]
          movediffs.push(179)
        when [429, 0] # mismagius has confusion shuffled to the end
          movediffs -= [93]
          movediffs.push(93)
        when [430, 0] # honchkrow has peck shuffled to the end
          movediffs -= [64]
          movediffs.push(64)
        when [472, 0] then movediffs.insert(-2, 400) # Gliscor is missing Night Slash somehow
      end
      moveList = moveList.transpose
      next if movediffs.empty?
      for move in movediffs
        moveList.insert(insertIndex,[1, move])
        insertIndex += 1 unless insertIndex == -1
      end
      levelUpDictLevelMove[key] = moveList
    end
  end
  return levelUpDictLevelMove
end

# Converts the raw Fortelle level up moveset data into a Validator class method for getting the Fortelle level up moveset of a Pokemon
def movesetToUsable(game)
  levelUpMovesMoveID = movesetData(game)
  moveDict = moveIDToName()
  # Maps [dex number, form number] to [[level, move name], [level, move name],...]
  levelUpMoves = {}
  levelUpMovesMoveID.keys.each do |pkmn|
    # BDSP and SWSH datasets have a dummy Pokemon at the start, this is to remove that
    next if pkmn == [0, 0]
    levelUpMovepool = levelUpMovesMoveID[pkmn]
    levelUpMoves[pkmn] = []
    levelUpMovepool.each do |level, moveID|
      levelUpMoves[pkmn].push([level, moveDict[moveID]])
    end
  end
  # Writes the data as a hash within a Validator class method into a ruby script file
  File.open(scripts_path + "/Datasets/Fortelle/Usable/" + game + "/levelup.rb", 'w') do |file|
    file.write("class Validator\n")
    file.write("  def compareLevelUpMoves" + game + "(pkmn, i)\n")
    file.write("    return {\n")
    levelUpMoves.each{ |k, v| file.write("      #{k} => #{v},\n") }
    file.write("    }[[pkmn[0].dexnum, i]]\n")
    file.write("  end\n")
    file.write("end")
  end
  return levelUpMoves
end

# ProjectPokemon moves
def projectPokemonDataToUsable()
  movesetZAToUsable()
  champsToUsable()
end

# Pokemon Legends: Z-A
# Right now, we're only interested in the available level-up/reminder moves for each Pokemon in this game
# Separate from movesetData, because we're not handling levels
def movesetZAData()
  require 'json'

  path = scripts_path + "/Datasets/projectpokemon/Raw/Z-A/personal_array.json"
  data = JSON.parse(File.read(path), symbolize_names: true)

  zaDict = {}
  data[:Table].each do |pkmn|
    next unless pkmn[:IsPresentInGame]

    key = [pkmn[:Info][:SpeciesInternal], pkmn[:Info][:Form]]
    value = pkmn[:Learnset].map { |move| move[:Move] }
    zaDict[key] = value
  end
  return zaDict
end

def movesetZAToUsable()
  zaMoveID = movesetZAData()
  moveDict = moveIDToName()
  zaMoves = {}
  zaMoveID.keys.each do |pkmn|
    zaMovepool = zaMoveID[pkmn]
    zaMoves[pkmn] = []
    zaMovepool.each { |moveID| zaMoves[pkmn].push(moveDict[moveID]) }
  end
  File.open(scripts_path + "/Datasets/projectpokemon/Usable/Z-A/levelup.rb", 'w') do |file|
    file.write("class Validator\n")
    file.write("  def compareZAMoves(pkmn, i)\n")
    file.write("    return {\n")
    zaMoves.each{ |k, v| file.write("      #{k} => #{v},\n") }
    file.write("    }[[pkmn[0].dexnum, i]]\n")
    file.write("  end\n")
    file.write("end")
  end
end

# Pokemon Champions
# Special handling for these moves
def champsData()
  require 'json'

  movepath = scripts_path + "/Datasets/projectpokemon/Raw/Champs/waza.json"
  movedata = JSON.parse(File.read(movepath), symbolize_names: true)

  learnpath = scripts_path + "/Datasets/projectpokemon/Raw/Champs/waza_learn.json"
  learndata = JSON.parse(File.read(learnpath), symbolize_names: true)

  champsDict = {}
  learndata.each do |pkmn|
    key = [pkmn[:id][0...4].to_i, pkmn[:id][6...8].to_i]
    value = pkmn[:waza].split(",").map(&:to_i)
    # Filter out unavailable moves
    value.reject! { |id| movedata[id - 1][:available] == "0" }
    champsDict[key] = value
  end
  return champsDict
end

def champsToUsable()
  champsMoveID = champsData()
  moveDict = moveIDToName()
  champsMoves = {}
  champsMoveID.keys.each do |pkmn|
    champsMovepool = champsMoveID[pkmn]
    champsMoves[pkmn] = []
    champsMovepool.each { |moveID| champsMoves[pkmn].push(moveDict[moveID]) }
  end
  File.open(scripts_path + "/Datasets/projectpokemon/Usable/Champs/waza_learn.rb", 'w') do |file|
    file.write("class Validator\n")
    file.write("  def assertChampsMoves(pkmn, i)\n")
    file.write("    return {\n")
    champsMoves.each{ |k, v| file.write("      #{k} => #{v},\n") }
    file.write("    }[[pkmn[0].dexnum, i]]\n")
    file.write("  end\n")
    file.write("end")
  end
end

# The following Pokemon had to have manual edits to their movesets
# Gen 1
# Beedrill - Rearranged level 1 moves so that [1, :HARDEN] is the last of them

# Gen 2
# None

# Gen 3
# Beautifly - Fixed order of level 1 moves
# Dustox - Fixed order of level 1 moves
# Delcatty - Fixed order of level 1 moves
# Huntail - Fixed order of level 1 moves
# Gorebyss - Fixed order of level 1 moves

# Gen 4
# Purugly - Fixed order of level 1 moves

# Gen 5
# Hisuian Zorua - Removed Spite at Level 28, as it was removed from Zorua's level up learnset in Scarlet/Violet v2.0.1
# Larvesta - Removed Bug Bite at Level 24, as it was removed from Larvesta's level up learnset in Scarlet/Violet v2.0.1
# Black and White Kyurem - Swapped level up movesets of Black and White Kyurem, as their unique moves were swapped

# Gen 6
# Aegislash Shield Form - Fixed order of level 1 moves

# Gen 7
# None

# Gen 8
# Silicobra - Added :SLEEPTALK to Silicobra's compatible moves
# Sandaconda - Added :SLEEPTALK to Sandaconda's compatible moves

# Gen 9
# None

# Rules:
# Level up and egg moves from the latest game they are available in, excepting LGPE and Pokemon Legends games. BDSP is considered earlier than SWSH.
# Moves that were removed from their Gen 7 or 8 level up or egg movesets should be added to their relearner or egg move pools unless they're learnable as a TM or a Tutor.
# Certain event moves are added to a pokemon's relearner pool unless they're learnable as a TM or a Tutor.
# Egg moves exclusive to the evolved form of an incense baby are added to the incense baby's egg move pool
# Stone evolutions with lacking level-up and reminder moves get their pre-evo's level-up moveset added to their relearner pool
# TMs + Tutor compatibilities from ORAS + USUM + SWSH + BDSP + SV
# Headbutt and Rock Climb are compatible if they were ever compatible in any game
# Keeping event moves from Gen 3-7 (note: not validated because pokeapi doesn't have event moves info)
# Pokemon can learn moves from Pokemon Champions unless the moves are learnable by any other means.
class Validator

  def updateMovesets(gen = nil)
    require 'poke-api-v2'
    updatedMoveMonHash = {}
    for _, pkmn in $cache.pkmn
      next if gen != nil && !GENS[gen].include?(pkmn[0].dexnum)

      cacheIndex = 0
      i = 0
      updatedMoveMonHash[pkmn.mon] = {}
      for formName, formData in pkmn.pokemonData
        next unless shouldValidate?(formName, formData)

        updatedMoveMonHash[pkmn.mon][cacheIndex] = updateForm(pkmn, i, cacheIndex)
        i += 1
        if formData.genderDifferences.any?
          updatedMoveMonHash[pkmn.mon][cacheIndex][:genderDifferences] = {}
          formData.genderDifferences.each { |gender, _|
            updatedMoveMonHash[pkmn.mon][cacheIndex][:genderDifferences][gender] = updateForm(pkmn, i, cacheIndex)
            i += 1
          }
        end
        cacheIndex += 1
      end
    end
    massUpdateMons(updatedMoveMonHash, gen)
    saveCache
  end

  def massUpdateMons(movesetUpdateHash, gen = nil)
    $gamefolder = GAMEFOLDER
    montext = Reborn ? "montext_modern.rb" : "montext.rb"
    filepath = definition_file_path(montext, game: GAMEFOLDER)
    cprint "Reading #{filepath}..."
    File.open("#{filepath}") { |f|
      eval(f.read)
    }
    cprint "done.\n"
    spacetoclear = 0
    mons = MonDataHash.new()
    MONHASH.each { |key, value|
      spacetoclear = key.to_s.length
      cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
      updatedValue = value
      if gen.nil? || GENS[gen].include?($cache.pkmn[key][0].dexnum)
        value.each_with_index do |form, formNum|
          updatedMoveset = movesetUpdateHash[key][formNum]
          monData = $cache.pkmn[key][formNum]
          if !updatedMoveset.nil?
            updatedValue[form[0]][:EggMoves] = updatedMoveset[:EggMoves] if !updatedMoveset[:EggMoves].empty?
            updatedValue[form[0]][:RelearnerMoves] = updatedMoveset[:RelearnerMoves] if !updatedMoveset[:RelearnerMoves].empty?
            updatedValue[form[0]][:Moveset] = updatedMoveset[:Moveset] if defined?(monData.Moveset)
            updatedValue[form[0]][:compatiblemoves] = updatedMoveset[:compatiblemoves] if defined?(monData.compatiblemoves)
            if !updatedMoveset[:genderDifferences].nil?
              updatedMoveset[:genderDifferences].each { |gender, genderMoveset|
                updatedValue[form[0]][:genderDifferences][gender][:EggMoves] = genderMoveset[:EggMoves] if !genderMoveset[:EggMoves].empty?
                updatedValue[form[0]][:genderDifferences][gender][:RelearnerMoves] = genderMoveset[:RelearnerMoves] if !genderMoveset[:RelearnerMoves].empty?
                updatedValue[form[0]][:genderDifferences][gender][:Moveset] = genderMoveset[:Moveset] if defined?(monData.genderDifferences[gender].Moveset)
                updatedValue[form[0]][:genderDifferences][gender][:compatiblemoves] = genderMoveset[:compatiblemoves] if defined?(monData.genderDifferences[gender].compatiblemoves)
              }
            end
          end
        end
      end

      inheritFormData(updatedValue)
      mons[key] = MonWrapper.new(key, updatedValue)
    }
    cprint "Compiled data for #{filepath}#{" " * spacetoclear}\n"
    monDump(mons, game: $gamefolder)
  end

  def updateForm(pkmn, i, cacheIndex)
    species = fetchSpecies(pkmn[0].dexnum)
    assertName(pkmn[cacheIndex].name, species.names)
    i = adjustVarietyIndex(pkmn[0].name, i)
    return if species.varieties[i].nil?
    return if shouldSkip?(species.varieties[i].pokemon.name)
    return if shouldSkipCache?($cache.pkmn[pkmn.mon], cacheIndex)

    oldLevelUpMoves, updatedLevelUpMoves = assertUpdatedLevelUpMoves(pkmn, i, species, cacheIndex)
    oldEggMoves, updatedEggMoves = assertUpdatedEggMoves(pkmn, i, species, cacheIndex)
    require "./Scripts/Datasets/Fortelle/Usable/SV/reminder.rb"
    relearnerMoves = assertUpdatedRelearnerMoves(pkmn, i) || []
    eventMoves = assertEventMoves(pkmn, i) || []
    extraMoves = assertExtraMoves(pkmn, i) || []

    updatedCompatibleMoves = assertUpdatedCompatibleMoves(pkmn, i, species, cacheIndex)
    # Filter down the compatible moves to TMs/Tutors that currently exist in the game
    availableCompatibleMoves = updatedCompatibleMoves.intersection(@tmtutormoves)

    addRelearnerMoves = oldLevelUpMoves + eventMoves
    addEggMoves = oldEggMoves
    if Reborn
      # Only add otherwise unavailable legacy level-up moves to relearner pool
      addRelearnerMoves -= oldEggMoves + updatedEggMoves + availableCompatibleMoves
      # Only add otherwise unavailable legacy egg moves to egg move pool
      addEggMoves -= updatedLevelUpMoves.map { |learn| learn[1] } + relearnerMoves + availableCompatibleMoves
    end
    addRelearnerMoves += extraMoves
    relearnerMoves += addRelearnerMoves
    updatedEggMoves += addEggMoves

    # In Gen 9 or later, Replace instances of Hail with Snowscape
    if Gen >= 9
      updatedLevelUpMoves.each { |move| move[1] = "Snowscape" if move[1] == "Hail" }
      relearnerMoves.map! { |move| move == "Hail" ? "Snowscape" : move }
      updatedEggMoves.map! { |move| move == "Hail" ? "Snowscape" : move }
      updatedCompatibleMoves.map! { |move| move == "Hail" ? "Snowscape" : move }
    end

    # Pokemon Champions moves
    if Gen >= Champs
      require "./Scripts/Datasets/projectpokemon/Usable/Champs/waza_learn.rb"
      champsMoves = assertChampsMoves(pkmn, i) || []
      unless champsMoves.empty?
        # Trim it down to moves the Pokemon can't already learn
        baby = pbGetBabySpecies(pkmn.mon, cacheIndex)
        babyEggMoves = assertUpdatedEggMoves($cache.pkmn[baby[0]], baby[1], fetchSpecies($cache.pkmn[*baby].dexnum), baby[1]).flatten
        champsMoves -= updatedLevelUpMoves.map { |learn| learn[1] } + relearnerMoves + babyEggMoves + updatedCompatibleMoves + @universaltms
      end
      unless champsMoves.empty?
        # Moves learned by level-up/reminder in Z-A go into :RelearnerMoves
        require "./Scripts/Datasets/projectpokemon/Usable/Z-A/levelup.rb"
        zaMoves = compareZAMoves(pkmn, i) || []
        relearnerMoves += champsMoves.intersection(zaMoves)
        champsMoves -= zaMoves
        # All other compatible moves go into :compatiblemoves
        updatedCompatibleMoves += champsMoves.intersection(@alltmtutormoves)
        champsMoves -= @alltmtutormoves
        # The rest go into :RelearnerMoves
        relearnerMoves += champsMoves
      end
    end

    # Sort the move lists alphabetically
    relearnerMoves.sort!
    updatedEggMoves.sort!
    updatedCompatibleMoves.sort!

    updatedLevelUpMoves = updatedLevelUpMoves.transpose
    while Rejuv && updatedLevelUpMoves[0].count(1) > 4
      index = updatedLevelUpMoves[0].find_index(1)
      relearnerMoves.push(updatedLevelUpMoves[1][index])
      updatedLevelUpMoves[0].delete_at(index)
      updatedLevelUpMoves[1].delete_at(index)
    end
    updatedLevelUpMoves[1] = findMoveSymbols(updatedLevelUpMoves[1])
    updatedLevelUpMoves = updatedLevelUpMoves.transpose rescue print(updatedLevelUpMoves)

    # Don't write egg moves for evolved species. Account for incense babies when doing this.
    key = [pkmn.mon, cacheIndex]
    baby = pbGetBabySpecies(*key)
    nonbaby = pbGetNonIncenseLowestSpecies(*baby)
    updatedEggMoves = [] if key != baby && key != nonbaby

    updatedMoveset = {
      :EggMoves => findMoveSymbols(updatedEggMoves.uniq),
      :RelearnerMoves => findMoveSymbols(relearnerMoves.uniq),
      :Moveset => updatedLevelUpMoves,
      :compatiblemoves => findMoveSymbols(updatedCompatibleMoves.uniq),
    }

    return updatedMoveset
  end

  # Which forms should be excluded
  def shouldSkipCache?(pkmn, i)
    for flag in [:ExcludeDex, :Mega, :Primal, :Ultra, :Terastal, :Pulse, :Rift, :Perfection, :Karma] do
      return true if pkmn[i].checkFlag?(flag)
    end
    return true if pkmn.forms[i].include?("Partner")
    return true if pkmn.forms[i].include?("Aevian")
    return true if pkmn.forms[i].include?("Zombie")
    return true if pkmn.forms[i].include?("Eternamax")
    return false
  end

  def assertUpdatedLevelUpMoves(pkmn, i, species, cacheIndex)
    form = pkmn[cacheIndex]
    return if species.varieties[i].nil?

    name = species.varieties[i].pokemon.name
    return if shouldSkip?(name)

    # For possible game values see https://pokeapi.co/api/v2/version-group/?limit=100
    updated = []
    relearner = []
    game = "USUM"
    updated += findLevelUpMoves(name, "scarlet-violet")
    updated += findLevelUpMoves(name, "the-teal-mask")
    updated += findLevelUpMoves(name, "the-indigo-disk")
    if updated.empty?
      updated += findLevelUpMoves(name, "sword-shield")
      updated += findLevelUpMoves(name, "the-isle-of-armor")
      updated += findLevelUpMoves(name, "the-crown-tundra")
      if updated.empty?
        updated += findLevelUpMoves(name, "brilliant-diamond-shining-pearl")
        game = "BDSP" if !updated.empty?
      else
        game = "SWSH"
        relearner += findLevelUpMoves(name, "brilliant-diamond-shining-pearl")
      end
      if updated.empty?
        updated += findLevelUpMoves(name, "ultra-sun-ultra-moon")
      else
        relearner += findLevelUpMoves(name, "ultra-sun-ultra-moon")
      end
    else
      game = "SV"
      relearner += findLevelUpMoves(name, "sword-shield")
      relearner += findLevelUpMoves(name, "the-isle-of-armor")
      relearner += findLevelUpMoves(name, "the-crown-tundra")
      relearner += findLevelUpMoves(name, "brilliant-diamond-shining-pearl")
      relearner += findLevelUpMoves(name, "ultra-sun-ultra-moon")
    end

    # Moves that are a part of a Pokemon's moveset between USUM and the game they most recently appeared in
    relearnerMoves = (relearner.map { |learn| learn[1] } - updated.map { |learn| learn[1] }).uniq

    # Moves that are a part of a Pokemon's most recent moveset that might be recorded in the wrong order because they're learned at the same level as at least one other move

    fortelleLevelUpMoves = []
    if game == "SV"
      require "./Scripts/Datasets/Fortelle/Usable/SV/levelup.rb"
      fortelleLevelUpMoves += compareLevelUpMovesSV(pkmn, i)
      # Gen 9 Level 1 lists don't have any sensible ordering for relearner lockouts as Gen 9 allows relearning moves anywhere at any time for no cost
      # so we have to check older gen level up lists to get the 4 moves that should be default
      if fortelleLevelUpMoves.count { |pair| pair[0] == 1} > 4
        oldgenlist = []
        require "./Scripts/Datasets/Fortelle/Usable/SWSH/levelup.rb"
        list = compareLevelUpMovesSWSH(pkmn, i)
        oldgenlist += list.nil? ? [] : list
        if oldgenlist.empty?
          require "./Scripts/Datasets/Fortelle/Usable/USUM/levelup.rb"
          list = compareLevelUpMovesUSUM(pkmn, i)
          oldgenlist += list.nil? ? [] : list
        end
        unless oldgenlist.empty?
          oldgenlist.select!{ |pair| pair[0] == 1}
          levelOneDefaults = oldgenlist.last(4)
          filteredDefaults = levelOneDefaults.intersection(fortelleLevelUpMoves)
          newFortelle = []
          for pair in fortelleLevelUpMoves
            break if pair[0] > 1 # these lists are sorted, when we start getting levels higher than 1 we can stop for now
            next if filteredDefaults.any? { |default| default[1] == pair[1]}
            newFortelle.push(pair)
          end
          for pair in filteredDefaults
            newFortelle.push(pair)
          end
          for pair in fortelleLevelUpMoves
            next if pair[0] <= 1
            newFortelle.push(pair)
          end
          fortelleLevelUpMoves = newFortelle
        end
      end
    elsif game == "SWSH"
      require "./Scripts/Datasets/Fortelle/Usable/SWSH/levelup.rb"
      fortelleLevelUpMoves += compareLevelUpMovesSWSH(pkmn, i)
    elsif game == "BDSP"
      require "./Scripts/Datasets/Fortelle/Usable/BDSP/levelup.rb"
      fortelleLevelUpMoves += compareLevelUpMovesBDSP(pkmn, i)
    end
    updatedMoves = []
    moveCountMismatch = false
    mismatchedMovesExtraFortelle = []
    mismatchedMovesExtraUpdated = []
    mismatchedOrderMoves = []
    mismatchedOrderMovesComparison = []
    # If the game isn't USUM and the fortelle data is missing, there is an issue
    if game != "USUM" && fortelleLevelUpMoves.empty?
      log(sprintf(
          "%s form %s - missing fortelle data",
          form.name,
          i,
        ))
    end
    # If the game is USUM, or the two datasets are the same, there is no reason to continue
    if game == "USUM" || fortelleLevelUpMoves == updated
      updatedMoves = updated
    else
      # Update inconsistencies in move names
      for imove in 0...fortelleLevelUpMoves.length do
        fortelleLevelUpMoves[imove][1] = adjustMoveName(fortelleLevelUpMoves[imove][1])
      end
      # Move or move level mismatch
      if !(fortelleLevelUpMoves - updated).empty?
        for imove in (fortelleLevelUpMoves - updated) do
          if imove[0] == 1 && fortelleLevelUpMoves.include?([0, imove[1]])
            fortelleLevelUpMoves.delete(imove)
          end
        end
        mismatchedMovesExtraFortelle += (fortelleLevelUpMoves - updated) if !(fortelleLevelUpMoves - updated).empty?
      end
      if !(updated - fortelleLevelUpMoves).empty?
        mismatchedMovesExtraUpdated += (updated - fortelleLevelUpMoves)
      end
      # Move count mismatch
      if fortelleLevelUpMoves.length != updated.length
        moveCountMismatch = true
        log(sprintf(
          "%s form %s - expected %s moves, got %s moves",
          form.name,
          i,
          fortelleLevelUpMoves.length,
          updated.length,
        ))
      end
      # Move order mismatch
      for imove in 0...fortelleLevelUpMoves.length do
        if imove >= updated.length
          updatedMoves.push(fortelleLevelUpMoves[imove])
          mismatchedOrderMovesComparison.push([fortelleLevelUpMoves[imove], []])
        elsif updated[imove] != fortelleLevelUpMoves[imove]
          mismatchedOrderMoves.push(updated[imove])
          mismatchedOrderMoves.push(fortelleLevelUpMoves[imove])
          updatedMoves.push(fortelleLevelUpMoves[imove])
          mismatchedOrderMovesComparison.push([fortelleLevelUpMoves[imove], updated[imove]])
        else
          updatedMoves.push(fortelleLevelUpMoves[imove])
          mismatchedOrderMovesComparison.push([fortelleLevelUpMoves[imove], updated[imove]])
        end
      end
      if !mismatchedMovesExtraFortelle.empty? || !mismatchedMovesExtraUpdated.empty?
        log(sprintf(
            "%s form %s - Mismatched Moves\nFortelle Extras: %s\nUpdated Extras: %s",
            form.name,
            i,
            mismatchedMovesExtraFortelle.inspect,
            mismatchedMovesExtraUpdated.inspect,
        ))
      end
      if (moveCountMismatch == true || !mismatchedMovesExtraFortelle.empty? || !mismatchedMovesExtraUpdated.empty?) && !mismatchedOrderMoves.empty?
        log(sprintf(
            "%s form %s - Mismatched Move Order: %s",
            form.name,
            i,
            mismatchedOrderMovesComparison.inspect,
        ))
        log(sprintf(
            "%s form %s - Automatic Move Order: %s",
            form.name,
            i,
            updatedMoves.inspect,
        ))
      end

    end

    if updatedMoves.length >= updated.length
      updated = updatedMoves
    end

    # Give pre-evo level-up moves to stone evolutions with practically no moves (At time of writing, just Simisage / Simisear / Simipour)
    if updated.length <= 4 && assertUpdatedRelearnerMoves(pkmn, i).nil?
      updatedLevels = updated.map { |learn| learn[0] }.uniq
      if updatedLevels == [0, 1] || updatedLevels == [1] # Only level 1 or on-evolve level-up moves
        preevo = pbGetPreviousForm(pkmn.mon, cacheIndex)
        if preevo != [pkmn.mon, cacheIndex] && pbGetEvolvedFormData(pkmn.mon, cacheIndex).nil? # Has a pre-evolution, doesn't evolve further
          pspecies = fetchSpecies($cache.pkmn[*preevo].dexnum)
          pname = pspecies.name
          relearnerMoves += findLevelUpMoves(pname, "ultra-sun-ultra-moon").map { |learn| learn[1] }
          relearnerMoves += findLevelUpMoves(pname, "sword-shield").map { |learn| learn[1] }
          relearnerMoves += findLevelUpMoves(pname, "the-isle-of-armor").map { |learn| learn[1] }
          relearnerMoves += findLevelUpMoves(pname, "the-crown-tundra").map { |learn| learn[1] }
          relearnerMoves += findLevelUpMoves(pname, "brilliant-diamond-shining-pearl").map { |learn| learn[1] }
          relearnerMoves += findLevelUpMoves(pname, "scarlet-violet").map { |learn| learn[1] }
          relearnerMoves += findLevelUpMoves(pname, "the-teal-mask").map { |learn| learn[1] }
          relearnerMoves += findLevelUpMoves(pname, "the-indigo-disk").map { |learn| learn[1] }

          relearnerMoves = (relearnerMoves - updated.map { |learn| learn[1] }).uniq
        end
      end
    end

    # Replace Primeape and Annihilape's level up Rage Fist with Fire Punch
    # Add Rage Fist to Annihilape's relearner pool
    if Rejuv
      if ["primeape", "annihilape"].include?(name)
        # Replace Rage Fist with Fire Punch for Primeape and Annihilape
        rmove = updated.find { |learn| learn[1] == "Rage Fist" }
        rmove[1] = "Fire Punch" if rmove
      end
      if name == "annihilape"
        # Add Rage Fist to Annihilape's relearner pool
        relearnerMoves.push("Rage Fist")
      end
      if name == "stantler"
        # Add Psyshield Bash to Stantler's level up pool
        index = updated.index([37, "Zen Headbutt"])
        raise "Unable to insert Psyshield Bash for Stantler." unless index
        updated.insert(index + 1, [43, "Psyshield Bash"])
      end
      if name == "zygarde-50"
        # Remove Thousand Arrows and Thousand Waves from Zygarde's level up pool.
        # They're unavailable for Zygarde 10% and the fusion forms. Zygarde 50% gets them as firstmoves along with Extreme Speed.
        updated.delete([1, "Thousand Arrows"])
        updated.delete([1, "Thousand Waves"])
      end
      # Remove Rock Climb from relearn pools to prevent Aquamarine Cave skip.
      relearnerMoves.delete("Rock Climb")
    end

    return relearnerMoves, updated
  end

  def assertUpdatedEggMoves(pkmn, i, species, cacheIndex)
    form = pkmn[cacheIndex]
    return if species.varieties[i].nil?

    name = species.varieties[i].pokemon.name
    return if shouldSkip?(name)

    # For possible game values see https://pokeapi.co/api/v2/version-group/?limit=100
    updated = []
    relearner = []
    updated += findEggMoves(name, "scarlet-violet")
    updated += findEggMoves(name, "the-teal-mask")
    updated += findEggMoves(name, "the-indigo-disk")
    if updated.empty?
      updated += findEggMoves(name, "sword-shield")
      updated += findEggMoves(name, "the-isle-of-armor")
      updated += findEggMoves(name, "the-crown-tundra")
      if updated.empty?
        updated += findEggMoves(name, "brilliant-diamond-shining-pearl")
      else
        relearner += findEggMoves(name, "brilliant-diamond-shining-pearl")
      end
      if updated.empty?
        updated += findEggMoves(name, "ultra-sun-ultra-moon")
      else
        relearner += findEggMoves(name, "ultra-sun-ultra-moon")
      end
    else
      relearner += findEggMoves(name, "sword-shield")
      relearner += findEggMoves(name, "the-isle-of-armor")
      relearner += findEggMoves(name, "the-crown-tundra")
      relearner += findEggMoves(name, "brilliant-diamond-shining-pearl")
      relearner += findEggMoves(name, "ultra-sun-ultra-moon")
    end

    # Incense babies get their next-stage past egg moves too
    nonIncense = pbGetNonIncenseLowestSpecies(form.species, cacheIndex)
    if nonIncense != [form.species, cacheIndex]
      nonIncenseSpecies = fetchSpecies($cache.pkmn[*nonIncense].dexnum)
      nonIncenseName = nonIncenseSpecies.name
      relearner += findEggMoves(nonIncenseName, "ultra-sun-ultra-moon")
      relearner += findEggMoves(nonIncenseName, "sword-shield")
      relearner += findEggMoves(nonIncenseName, "the-isle-of-armor")
      relearner += findEggMoves(nonIncenseName, "the-crown-tundra")
      relearner += findEggMoves(nonIncenseName, "brilliant-diamond-shining-pearl")
    end

    relearner = (relearner - updated).uniq

    # Custom Rejuvenation egg moves
    if Rejuv
      # Add Hexing Slash for Gastly and Phantump.
      if ["gastly", "phantump"].include?(name)
        updated.push("Hexing Slash")
      end
      # Remove Rock Climb from relearn pools to prevent Aquamarine Cave skip.
      relearner.delete("Rock Climb")
    end

    return relearner, updated
  end

  def assertUpdatedCompatibleMoves(pkmn, i, species, cacheIndex)
    return [] if species.varieties[i].pokemon.name == "mew"

    form = pkmn[cacheIndex]
    return if species.varieties[i].nil?

    name = species.varieties[i].pokemon.name
    return if shouldSkip?(name)

    compatiblegames = [
      "sword-shield",
      "the-isle-of-armor",
      "the-crown-tundra",
      "brilliant-diamond-shining-pearl",
      "scarlet-violet",
      "the-teal-mask",
      "the-indigo-disk",
      "ultra-sun-ultra-moon",
      "omega-ruby-alpha-sapphire"
    ]

    # For possible game values see https://pokeapi.co/api/v2/version-group/?limit=100
    updated = findCompatibleMoves(name, *compatiblegames)

    # Check pre-evolutions if they're from different generation
    preevo = pbGetPreviousForm(pkmn.mon, cacheIndex)
    if preevo != [pkmn.mon, cacheIndex]
      unless isSameGen(preevo, [form.species, cacheIndex])
        if (name == "basculegion-male" || name == "basculegion-female") && species.evolves_from_species.name == "basculin"
          updated += findCompatibleMoves("basculin-white-striped", *compatiblegames)
        else
          updated += findCompatibleMoves(species.evolves_from_species.name, *compatiblegames)
        end
        prepreevo = pbGetPreviousForm(*preevo)
        if prepreevo != [*preevo]
          unless isSameGen(prepreevo, [form.species, cacheIndex])
            pspecies = fetchSpecies($cache.pkmn[*prepreevo].dexnum)
            updated += findCompatibleMoves(pspecies.name, *compatiblegames)
          end
        end
      end
    end

    # Give Primeape Rage Fist by tutor
    if Rejuv && name == "primeape"
      updated.push("Rage Fist")
    end

    return updated
  end

  def assertEventMoves(pkmn, i)
    if Reborn
      return {
        [1, 0] => ["Weather Ball"], # Bulbasaur
        [2, 0] => ["Weather Ball"], # Ivysaur
        [3, 0] => ["Weather Ball"], # Venusaur
        [4, 0] => ["Howl", "Quick Attack"], # Charmander
        [5, 0] => ["Howl", "Quick Attack"], # Charmeleon
        [6, 0] => ["Howl", "Quick Attack"], # Charizard
        [7, 0] => ["Follow Me"], # Squirtle
        [8, 0] => ["Follow Me"], # Wartortle
        [9, 0] => ["Follow Me"], # Blastoise
        [25, 0] => ["Extreme Speed", "Follow Me", "Sing", "Teeter Dance", "Yawn"], # Pikachu
        [26, 0] => ["Extreme Speed", "Follow Me", "Sing", "Teeter Dance", "Yawn"], # Raichu
        [26, 1] => ["Extreme Speed", "Follow Me", "Sing", "Teeter Dance", "Yawn"], # Raichu-Alola (inherits from Pikachu)
        [39, 0] => ["Tickle"], # Jigglypuff
        [40, 0] => ["Tickle"], # Wigglytuff
        [52, 0] => ["Sing"], # Meowth
        [53, 0] => ["Sing"], # Persian
        [83, 0] => ["Wish", "Yawn"], # Farfetch'd
        [96, 0] => ["Belly Drum", "Wish"], # Drowzee
        [97, 0] => ["Belly Drum", "Wish"], # Hypno
        [102, 0] => ["Wish"], # Exeggcute
        [103, 0] => ["Wish"], # Exeggutor
        [103, 1] => ["Wish"], # Exeggutor-Alola (inherits from Exeggcute)
        [108, 0] => ["Heal Bell", "Wish"], # Lickitung
        [113, 0] => ["Wish"], # Chansey
        [115, 0] => ["Wish", "Yawn"], # Kangaskhan
        [133, 0] => ["Sing"], # Eevee
        [134, 0] => ["Sing"], # Vaporeon
        [135, 0] => ["Sing"], # Jolteon
        [136, 0] => ["Sing"], # Flareon
        [149, 0] => ["Barrier"], # Dragonite
        [150, 0] => ["Electro Ball", "Hurricane"], # Mewtwo
        [172, 0] => ["Follow Me", "Teeter Dance"], # Pichu
        [174, 0] => ["Tickle"], # Igglybuff
        [196, 0] => ["Sing"], # Espeon
        [197, 0] => ["Sing"], # Umbreon
        [202, 0] => ["Tickle"], # Wobbuffet
        [242, 0] => ["Wish"], # Blissey
        [243, 0] => ["Aura Sphere", "Extreme Speed", "Weather Ball", "Zap Cannon"], # Raikou
        [244, 0] => ["Crush Claw", "Flare Blitz", "Howl"], # Entei
        [245, 0] => ["Air Slash", "Aqua Ring"], # Suicune
        [249, 0] => ["Defog", "Hurricane", "Skill Swap", "Tailwind"], # Lugia
        [276, 0] => ["Feather Dance"], # Taillow
        [277, 0] => ["Feather Dance"], # Swellow
        [302, 0] => ["Octazooka", "Tickle"], # Sableye
        [327, 0] => ["Sing"], # Spinda
        [331, 0] => ["Encore"], # Cacnea
        [332, 0] => ["Encore"], # Cacturne
        [354, 0] => ["Cotton Guard"], # Banette
        [359, 0] => ["Wish"], # Absol
        [360, 0] => ["Tickle"], # Wynaut
        [371, 0] => ["Wish"], # Bagon
        [372, 0] => ["Wish"], # Shelgon
        [373, 0] => ["Wish"], # Salamence
        [375, 0] => ["Refresh"], # Metang
        [376, 0] => ["Refresh"], # Metagross
        [384, 0] => ["V-create"], # Rayquaza
        [385, 0] => ["Draco Meteor", "Follow Me", "Heart Stamp", "Meteor Mash", "Moonblast"], # Jirachi
        [386, 0] => ["Detect", "Extreme Speed", "Meteor Mash", "Zap Cannon"], # Deoxys-Normal
        [386, 1] => ["Detect", "Extreme Speed", "Meteor Mash", "Zap Cannon"], # Deoxys-Attack
        [386, 2] => ["Detect", "Extreme Speed", "Meteor Mash", "Zap Cannon"], # Deoxys-Defense
        [386, 3] => ["Detect", "Extreme Speed", "Meteor Mash", "Zap Cannon"], # Deoxys-Speed
        [393, 0] => ["Sing"], # Piplup
        [394, 0] => ["Sing"], # Prinplup
        [395, 0] => ["Sing"], # Empoleon
        [463, 0] => ["Heal Bell", "Wish"], # Lickilicky
        [470, 0] => ["Sing"], # Leafeon
        [471, 0] => ["Sing"], # Glaceon
        [485, 0] => ["Eruption"], # Heatran
        [491, 0] => ["Phantom Force", "Roar of Time", "Spacial Rend"], # Darkrai
        [493, 0] => ["Roar of Time", "Shadow Force", "Spacial Rend"], # Arceus
        [494, 0] => ["Blue Flare", "Bolt Strike", "Fusion Bolt", "Fusion Flare", "Glaciate"], # Victini
        [495, 0] => ["Aromatherapy"], # Snivy
        [496, 0] => ["Aromatherapy"], # Servine
        [497, 0] => ["Aromatherapy"], # Serperior
        [643, 0] => ["Mist"], # Reshiram
        [644, 0] => ["Haze"], # Zekrom
        [649, 0] => ["Blaze Kick", "Extreme Speed", "Shift Gear"], # Genesect
        [700, 0] => ["Sing"], # Sylveon
      }[[pkmn[0].dexnum, i]]
    end

    if Rejuv
      return {
        [25, 0] => ["Extreme Speed", "Sing", "Yawn"], # Pikachu
        [26, 0] => ["Extreme Speed", "Sing", "Yawn"], # Raichu
        [26, 1] => ["Extreme Speed", "Sing", "Yawn"], # Raichu-Alola (inherits from Pikachu)
        [243, 0] => ["Aura Sphere", "Weather Ball"], # Raikou
        [244, 0] => ["Crush Claw", "Howl"], # Entei
        [245, 0] => ["Aqua Ring"], # Suicune
        [384, 0] => ["V-create"], # Rayquaza
        [385, 0] => ["Draco Meteor", "Heart Stamp", "Moonblast"], # Jirachi
        [386, 0] => ["Detect", "Meteor Mash", "Nasty Plot", "Zap Cannon"], # Deoxys-Normal
        [386, 1] => ["Detect", "Meteor Mash", "Nasty Plot", "Zap Cannon"], # Deoxys-Attack
        [386, 2] => ["Detect", "Meteor Mash", "Nasty Plot", "Zap Cannon"], # Deoxys-Defense
        [386, 3] => ["Detect", "Meteor Mash", "Nasty Plot", "Zap Cannon"], # Deoxys-Speed
        [491, 0] => ["Phantom Force", "Roar of Time", "Spacial Rend"], # Darkrai
        [493, 0] => ["Roar of Time", "Shadow Force", "Spacial Rend"], # Arceus
        [494, 0] => ["Blue Flare", "Bolt Strike", "Fusion Bolt", "Fusion Flare", "Glaciate"], # Victini
        [649, 0] => ["Blaze Kick", "Extreme Speed", "Shift Gear"], # Genesect
      }[[pkmn[0].dexnum, i]]
    end

    if Desolation
      # return {
      #   [dexnum, form] => ["Move Name 1", "Move Name 2", ...],
      # }[[pkmn[0].dexnum, i]]
    end
  end

  # Moves other than event moves that are available as relearner moves for us but not in canon
  # Guarantees that the moves will appear in the relearner pool, regardless of game rules
  def assertExtraMoves(pkmn, i)
    return {
      # Espeon and Umbreon have Charm as a pre-evo-only move in Gen 7, but because of our Sylveon evo method would never be able to keep it when evolving (not relevant for later Gens but keeping it here for completeness)
      [196, 0] => Gen <= 7 ? ["Charm"] : [], # Espeon
      [197, 0] => Gen <= 7 ? ["Charm"] : [], # Umbreon
      # Moves learnt on form change, for move swapping convenience
      [479, 1] => ["Overheat"], # Rotom-Heat
      [479, 2] => ["Hydro Pump"], # Rotom-Wash
      [479, 3] => ["Blizzard"], # Rotom-Frost
      [479, 4] => ["Air Slash"], # Rotom-Fan
      [479, 5] => ["Leaf Storm"], # Rotom-Mow
      # Zygarde Cube moves
      [718, 0] => Reborn ? ["Dragon Dance", "Extreme Speed", "Thousand Arrows", "Thousand Waves", "Core Enforcer"] : [], # Zygarde-50
      [718, 1] => Reborn ? ["Dragon Dance", "Extreme Speed", "Thousand Arrows", "Thousand Waves", "Core Enforcer"] : [], # Zygarde-10
      # Moves learnt on form change, for move swapping convenience
      [800, 1] => ["Sunsteel Strike"], # Necrozma-Dusk Mane
      [800, 2] => ["Moongeist Beam"], # Necrozma-Dawn Wings
    }[[pkmn[0].dexnum, i]]
  end
end

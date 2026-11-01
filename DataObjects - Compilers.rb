def compileAll(game: nil)
  # Guard against exporting messages.dat from unintended maps.
  # This requires eevee 2.12.0 or newer.
  if Dir.exist?(".git") && File.exist?("DataExport/checksums.csv") && !game
    imported = File.open("DataExport/checksums.csv", 'r').readline.chomp
    current = current_commit()
    if current != imported
      cmd = Kernel.pbMessage("Make sure to run eevee.import.bat first.\nRun compilation anyway?", [_INTL("Yes"), _INTL("No")], -1)
      return if cmd != 0
    end
  end

  MessageTypes.clearMessages

  compileConnections if !game
  compileMons(game: game)
  compilePokedexes(game: game)
  compileItems(game: game)
  compileMoves(game: game)
  compileAbilities(game: game)
  compileMapData if !game
  compileMetadata(game: game)
  compileFields(game: game)
  compileFieldNotes(game: game)
  compileTypes(game: game)
  compileTrainerTypes(game: game)
  compileTrainers(game: game)
  compileNatures(game: game)
  compileBosses(game: game)
  compileTownMap if !game
  compileMartData(game: game)
  compileBTData(game: game) unless Desolation
  compileCurrencies(game: game)
  compilePasswords(game: game)
  compileAnimSheets(game: game) if Rejuv

  if Reborn
    compileMonsGen9(game: game)
    compileMovesGen9(game: game)
    compileAbilitiesGen9(game: game)
    compileItemsGen9(game: game)
  end

  return if game

  if Rejuv
    compileXTPool
    compileBlessings
    compileDenEncounters
    compileDens
    QuestModule.registerMessages
  end

  # This needs to be after compileMovesGen9
  compileAnimations

  # Export messages.dat
  themeTeamMessages if Reborn
  challengerDefenseMessages if Reborn
  pbSetTextMessages
  MessageTypes.saveMessages
  puts "All done!"
end

def compileExportAllGames(directory = nil)
  begin
    originalState = [ Reborn.dup, Rejuv.dup, Desolation.dup, Gen.dup ]

    game = "Reborn"
    Object.const_set(:Gen, 7)
    Object.const_set(:Reborn, true)
    Object.const_set(:Rejuv, false)
    Object.const_set(:Desolation, false)
    compileAll(game: game)
    exportAll(game: game)

    Object.const_set(:Gen, 9)
    compileAll(game: game)
    exportAll(game: game)

    game = "Rejuv"
    Object.const_set(:Reborn, false)
    Object.const_set(:Rejuv, true)
    Object.const_set(:Desolation, false)
    compileAll(game: game)
    exportAll(game: game)

    game = "Desolation"
    Object.const_set(:Reborn, false)
    Object.const_set(:Rejuv, false)
    Object.const_set(:Desolation, true)
    compileAll(game: game)
    exportAll(game: game)
  rescue
    dp("Unable to compile and export data for all games. Aborting.")
    logError($!, display: true)
  ensure
    [:Reborn, :Rejuv, :Desolation, :Gen].each_with_index { |const, i|
      Object.const_set(const, originalState[i])
    }
    compileAll(game: GAMEFOLDER)

    currentState = [ Reborn.dup, Rejuv.dup, Desolation.dup, Gen.dup ]
    if originalState != currentState
      dp("Unable to reset game constants to expected values. Please close the game, relaunch, and compileAll.")
    end
  end
end

def compileMonsGen9(directory = nil, game: nil)
  compileMons(directory, "montext_modern.rb", "mons_modern.dat", game: game)
end

def compileMovesGen9(directory = nil, game: nil)
  compileMoves(directory, "movetext_modern.rb", "moves_modern.dat", game: game)
end

def compileAbilitiesGen9(directory = nil, game: nil)
  compileAbilities(directory, "abiltext_modern.rb", "abil_modern.dat", game: game)
end

def compileItemsGen9(directory = nil, game: nil)
  compileItems(directory, "itemtext_modern.rb", "items_modern.dat", game: game)
end

def compileMons(directory = nil, file = "montext.rb", outfile = "mons.dat", game: nil)
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done.\n"
  spacetoclear = 10
  mons = MonDataHash.new()
  species = []
  kinds = []
  entries = []
  forms = []
  MONHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"

    # Check for missing hidden ability definitions.
    i = 0
    value.each do |name, definition|
      i += 1
      break if i == 1 && definition[:HiddenAbility].nil?
      next if i == 1
      next unless name.instance_of?(String)
      next if definition[:Abilities].nil?
      next if definition[:HiddenAbility].nil?
      next unless definition[:Abilities].include?(definition[:HiddenAbility])

      puts key.to_s + " " + name + " has a HiddenAbility assignment as part of its Abilities."
      puts "Use 'nil' if HiddenAbility should not exist."
    end

    # Check for overriding only one type of dual-type base form
    i = 0
    value.each do |name, definition|
      i += 1
      break if i == 1 && definition[:Type2].nil?
      next if i == 1
      next unless name.instance_of?(String)
      next if definition[:Type1].nil?
      next if definition[:Type2].nil?
      next unless definition[:Type1] == definition[:Type2]

      puts key.to_s + " " + name + " has a Type2 assignment equal to its Type1."
      puts "Use 'nil' if Type2 should not exist."
    end

    value.each do |name, definition|
      next unless name.instance_of?(String)
      next if definition[:evolutions].nil?
      if defined?(EVOLUTION_METHODS)
        definition[:evolutions].each do |evohash|
          next if EVOLUTION_METHODS.include?(evohash[:method])
          puts key.to_s + " " + name + " has an invalid evolution method: #{evohash[:method]}."
        end
      end
    end

    value.each do |name, definition|
      next unless name.instance_of?(String)
      species.push(definition[:name]) unless definition[:name].nil?
      kinds.push(definition[:kind]) unless definition[:kind].nil?
      entries.push(definition[:dexentry]) unless definition[:dexentry].nil?
      checkIfDexEntryFits(key, name, definition[:dexentry]) unless definition[:dexentry].nil?
      forms.push(name)
      forms.push(definition[:formTextOverride]) unless definition[:formTextOverride].nil?
    end

    value.each do |name, definition|
      current = name
      # Decide which form to inherit from
      parent = definition[:baseForm] || value.keys.first
      while parent != current
        parentDefinition = value[parent]

        # Inherit values from parent form
        parentDefinition.each do |defKey, defValue|
          next if EXCLUSIVE_ATTRS.include?(defKey)
          next if EXCLUSIVE_FLAGS.include?(defKey)
          definition[defKey] = defValue unless definition.has_key?(defKey)
        end

        # Chain inheritance for cases like Mega Floette
        current = parent
        parent = parentDefinition[:baseForm] || value.keys.first
      end
    end

    inheritFormData(value)
    mons[key] = MonWrapper.new(key, value)
  }
  MessageTypes.addMessagesAsHash(:Species, species)
  MessageTypes.addMessagesAsHash(:Kinds, kinds)
  MessageTypes.addMessagesAsHash(:Entries, entries)
  MessageTypes.addMessagesAsHash(:FormNames, forms)
  cprint "Compiled data for #{outfile}#{" " * spacetoclear}\n"
  save_data(mons, directory + "/#{outfile}")
  cprint "Saved #{outfile}\n\n"
  $cache.cacheDex if $cache
  $Trainer.pokedex.refreshDex(true) if $Trainer
end

def inheritFormData(mondata)
  mondata.each do |formname, definition|
    current = formname
    # Decide which form to inherit from
    parent = definition[:baseForm] || mondata.keys.first
    while parent != current
      parentDefinition = mondata[parent]

      # Inherit values from parent form
      parentDefinition.each do |defKey, defValue|
        next if EXCLUSIVE_ATTRS.include?(defKey)
        next if EXCLUSIVE_FLAGS.include?(defKey)
        definition[defKey] = defValue unless definition.has_key?(defKey)
      end

      # Chain inheritance for cases like Mega Floette
      current = parent
      parent = parentDefinition[:baseForm] || mondata.keys.first
    end
  end
end

def compileMoves(directory = nil, file = "movetext.rb", outfile = "moves.dat", game: nil)
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  moves = {}
  spacetoclear = 10
  tmmoves = $cache.items.map{ |item, data| data.checkFlag?(:tm) || nil }.compact if $cache&.items

  names = []
  longnames = []
  descriptions = []
  MOVEHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    moves[key] = MoveData.new(key, value)
    names.push(value[:name])
    longnames.push(value[:longname] || value[:name])
    descriptions.push(value[:desc]) if value[:desc]
    checkIfMoveDescFits(key, value[:desc]) if value[:desc]
    checkIfItemDescFits(key, value[:desc], tm: true) if $cache&.items && tmmoves.include?(key)
  }
  MessageTypes.addMessagesAsHash(:Moves, names)
  MessageTypes.addMessagesAsHash(:MovesLong, longnames)
  MessageTypes.addMessagesAsHash(:MoveDescriptions, descriptions)

  cprint "Compiled data for #{outfile}#{" " * spacetoclear}\n"
  save_data(moves, directory + "/#{outfile}")
  cprint "Saved #{outfile}\n\n"
  $cache.cacheMoves if $cache
end

def compileItems(directory = nil, file = "itemtext.rb", outfile = "items.dat", game: nil)
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  items = {}
  spacetoclear = 10
  names = []
  unitnames = []
  pluralnames = []
  descriptions = []
  ITEMHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    items[key] = ItemData.new(key, value)
    names.push(value[:name])
    names.push(value[:shortname]) if value[:shortname]
    unitnames.push(items[key].unit) if items[key].unit
    pluralnames.push(items[key].plural)
    descriptions.push(value[:desc]) if value[:desc]
    checkIfItemDescFits(key, value[:desc]) if value[:desc]
    checkIfItemNameFits(value[:shortname] || value[:name]) unless items[key].checkFlag?(:keyitem)
  }
  MessageTypes.addMessagesAsHash(:Items, names)
  MessageTypes.addMessagesAsHash(:ItemUnits, unitnames)
  MessageTypes.addMessagesAsHash(:ItemPlurals, pluralnames)
  MessageTypes.addMessagesAsHash(:ItemDescriptions, descriptions)
  cprint "Compiled data for #{outfile}#{" " * spacetoclear}\n"
  save_data(items, directory + "/#{outfile}")
  cprint "Saved #{outfile}\n\n"
  $cache.cacheItems if $cache
end

def compileAbilities(directory = nil, file = "abiltext.rb", outfile = "abil.dat", game: nil)
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  abilities = {}
  spacetoclear = 10
  names = []
  longnames = []
  descriptions = []
  longdescs = []
  ABILHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    abilities[key] = AbilityData.new(key, value)
    names.push(value[:name])
    longnames.push(value[:fullName].nil? ? value[:name] : value[:fullName])
    descriptions.push(value[:desc])
    longdescs.push(value[:fullDesc].nil? ? value[:desc] : value[:fullDesc])
  }
  MessageTypes.addMessagesAsHash(:Abilities, names)
  MessageTypes.addMessagesAsHash(:AbilitiesLong, longnames)
  MessageTypes.addMessagesAsHash(:AbilityDescs, descriptions)
  MessageTypes.addMessagesAsHash(:AbilityDescsLong, longdescs)
  cprint "Compiled data for #{outfile}#{" " * spacetoclear}\n"
  save_data(abilities, directory + "/#{outfile}")
  cprint "Saved #{outfile}\n\n"
  $cache.cacheAbilities if $cache
end

def compileMapData(directory = nil)
  file = "enctext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file)) { |f| eval(f.read) }
  cprint "done\n"
  cprint "Reading maptext.rb..."
  File.open(definition_file_path("maptext.rb")) { |f| eval(f.read) }
  cprint "done\n"

  spacetoclear = 10
  mapdata = []
  altmapnames = []
  encounternotes = []
  for i in 1...1000 # rmxp's classic map limit
    encdata = ENCHASH[i]
    metadata = MAPHASH[i]
    next if !metadata && !File.exist?(sprintf("Data/Map%03d.rxdata", i))

    metadata = {} if !metadata
    encdata = {} if !encdata

    # Add SurfaceMap metadata
    for j in 1...1000
      meta = MAPHASH[j]
      if meta&.dig(:DiveMap) == i
        if metadata[:SurfaceMap]
          puts "Warning: Cannot set SurfaceMap to #{j} for Map #{i}. Map #{i} already has SurfaceMap #{metadata[:SurfaceMap]} assigned."
        else
          metadata[:SurfaceMap] = j
        end
      end
    end

    spacetoclear = i.to_s.length
    cprint "Compiling data for #{i}#{" " * spacetoclear}\r"
    mapdata[i] = MapMetadata.new(i, encdata, metadata)
    altmapnames.push(metadata[:AltMapName]) if metadata[:AltMapName]
    if encdata[:Overworld]
      encdata[:Overworld].each { |k, v| encounternotes.push(v[:note]) if v[:note] }
    end

    puts "Missing BattleBack for Map #{i}: " + metadata[:BattleBack] if metadata[:BattleBack].to_s != "" && !assetExists("Graphics/BattleBacks/battlebg" + metadata[:BattleBack], "png", true)
    puts "Missing WildBattleBGM for Map #{i}: " + metadata[:WildBattleBGM] if metadata[:WildBattleBGM].to_s != "" && !assetExists("Audio/BGM/" + metadata[:WildBattleBGM], "ogg", "mp3", true)
    puts "Missing TrainerBattleBGM for Map #{i}: " + metadata[:TrainerBattleBGM] if metadata[:TrainerBattleBGM].to_s != "" && !assetExists("Audio/BGM/" + metadata[:TrainerBattleBGM], "ogg", "mp3", true)

    puts "Map #{i} has unused :Land encounters." if encdata[:Land] && encdata[:LandMorning] && encdata[:LandDay] && encdata[:LandNight]
  end

  MessageTypes.addMessagesAsHash(:MapNames, altmapnames)
  MessageTypes.addMessagesAsHash(:EncounterNotes, encounternotes)
  cprint "Compiled data for maps.dat#{" " * spacetoclear}\n"
  save_data(mapdata, directory + "/maps.dat")
  cprint "Saved maps.dat\n\n"
  $cache.cacheMapData if $cache
  $game_map.need_refresh = true if $game_map
end

def compileTownMap(directory = nil)
  file = "townmap.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  townmap = {}
  spacetoclear = 10
  regions = []
  places = []
  points = []
  for i in 0...TOWNMAP.length
    spacetoclear = TOWNMAP[i][:name].to_s.length
    cprint "Compiling data for #{TOWNMAP[i][:name]}#{" " * spacetoclear}\r"
    region = TOWNMAP[i]
    townmap[i] = {}
    townmap[i][:name] = region[:name]
    townmap[i][:filename] = region[:filename]
    townmap[i][:points] = region[:points] if Desolation
    regions.push(region[:name])
    region[:points].each { |point, data|
      townmap[point] = TownMapData.new(point, data, i)
      places.push(data[:name])
      points.push(data[:poi]) if data[:poi] != ""
      # This block sets healingSpot to the flyPoint as soon as you enter a map which has a flyPoint.
      # Which breaks Teleport in Reborn - healingSpot should be set when you enter Belrose Manse, not when you enter Tanzan Cove.
      if !data[:flyData].empty? && Rejuv
        # puts "#{i}: #{point.inspect}"
        flyData = data[:flyData]
        $cache.mapdata[flyData[0]].syncMapData(i, point, flyData)
      end
    }
  end
  MessageTypes.setMessagesAsHash(:RegionNames, regions)
  MessageTypes.setMessagesAsHash(:PlaceNames, places)
  MessageTypes.setMessagesAsHash(:PlaceDescriptions, points)
  cprint "Compiled data for townmap.dat#{" " * spacetoclear}\n"
  save_data(townmap, directory + "/townmap.dat")
  if Rejuv
    save_data($cache.mapdata, directory + "/maps.dat")
  end
  cprint "Saved townmap.dat\n\n"
  $cache.cacheTownMap if $cache
  $cache.cacheMapData if $cache && Rejuv
end

def compileMetadata(directory = nil, game: nil)
  file = "metatext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  spacetoclear = 10
  players = []
  METAHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    players.push(METAHASH[key]) if key.to_s.include?("player")
  }
  meta = {}
  meta[:home]             = METAHASH[:home]
  meta[:TrainerVictory]   = METAHASH[:TrainerVictory]
  meta[:WildVictory]      = METAHASH[:WildVictory]
  meta[:TrainerBattle]    = METAHASH[:TrainerBattle]
  meta[:WildBattle]       = METAHASH[:WildBattle]
  meta[:Surf]             = METAHASH[:Surf]
  meta[:LavaSurf]         = METAHASH[:LavaSurf]
  meta[:Bicycle]          = METAHASH[:Bicycle]
  meta[:Players]          = players
  cprint "Compiled data for meta.dat#{" " * spacetoclear}\n"
  save_data(meta, directory + "/meta.dat")
  cprint "Saved meta.dat\n\n"
  $cache.cacheMetadata if $cache
end

def compileTypes(directory = nil, game: nil)
  file = "typetext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  types = {}
  spacetoclear = 10
  typenames = []
  TYPEHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    types[key] = TypeData.new(key, value)
    typenames.push(value[:name])
  }
  MessageTypes.setMessagesAsHash(:Types, typenames)
  cprint "Compiled data for types.dat#{" " * spacetoclear}\n"
  save_data(types, directory + "/types.dat")
  cprint "Saved types.dat\n\n"
  $cache.cacheTypes if $cache
end

def compileTrainerTypes(directory = nil, game: nil)
  file = "ttypetext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  ttypes = {}
  spacetoclear = 10
  trainertypes = []
  TTYPEHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    if GAME_VERSION != "test"
      puts "Missing sprite for #{key.inspect}: " + value[:sprite] if value[:sprite].to_s != "" && !assetExists("Graphics/Characters/" + value[:sprite], "png", true)
      validateBGM(value[:battleBGM], :battleBGM, key)
      validateBGM(value[:winBGM], :winBGM, key)
    end
    ttypes[key] = TrainerData.new(key, value)
    trainertypes.push(value[:title])
  }
  MessageTypes.setMessagesAsHash(:TrainerTypes, trainertypes)
  cprint "Compiled data for ttypes.dat#{" " * spacetoclear}\n"
  save_data(ttypes, directory + "/ttypes.dat")
  cprint "Saved ttypes.dat\n\n"
  $cache.cacheTrainerTypes if $cache
end

def compileTrainers(directory = nil, game: nil)
  file = "trainertext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  # it's really more like "assembling" them but w/e
  fulltrainerdata = {}
  spacetoclear = 10
  names = []
  openingspeeches = []
  acespeeches = []
  lossspeeches = []
  otherspeeches = []
  comp = []
  # iterate through, sort teams into hashes
  TEAMARRAY.each_with_index do |trainer, index|
    next if trainer.nil?

    spacetoclear = trainer[:teamid].inspect.length
    cprint "Compiling data for #{trainer[:teamid].inspect}#{" " * spacetoclear}\r"

    if comp.include?(trainer[:teamid])
      puts "Duplicate trainer found for #{trainer[:teamid].inspect}"
    end

    if trainer[:baseTeam]
      baseTeam = TEAMARRAY.find { |t| t[:teamid] == trainer[:baseTeam] }
      if !baseTeam
        puts "Couldn't find baseTeam #{trainer[:baseTeam]} for team #{trainer[:teamid]}. Skipping."
        next
      end
      trainer = baseTeam.merge(trainer) # Inheriting attributes from baseTeam
    end

    for mon in trainer[:mons]
      validateMon(trainer[:teamid], mon)
      otherspeeches.push(mon[:entryLines]) if mon[:entryLines]
      otherspeeches.push(mon[:faintLines]) if mon[:faintLines]
    end
    if GAME_VERSION != "test"
      validateBGM(trainer[:battleBGM], :battleBGM, trainer[:teamid])
      validateBGM(trainer[:acemusic], :acemusic, trainer[:teamid])
      validateBGM(trainer[:winBGM], :winBGM, trainer[:teamid])
    end

    name = trainer[:teamid][0]
    trainertype = trainer[:teamid][1]
    partyid = trainer[:teamid][2]

    team = TeamData.new(index, trainer[:teamid], trainer)
    comp.push(trainer[:teamid])

    fulltrainerdata[trainertype] = {} if !fulltrainerdata[trainertype]
    fulltrainerdata[trainertype][name] = {} if !fulltrainerdata[trainertype][name]
    fulltrainerdata[trainertype][name][partyid] = team if !fulltrainerdata[trainertype][name][partyid]

    names.push(name)
    openingspeeches.push(trainer[:openingLine]) if trainer[:openingLine]
    acespeeches.push(trainer[:ace]) if trainer[:ace]
    lossspeeches.push(trainer[:defeat]) if trainer[:defeat]
  end
  MessageTypes.setMessagesAsHash(:TrainerNames, names)
  MessageTypes.setMessagesAsHash(:OpeningSpeech, openingspeeches)
  MessageTypes.setMessagesAsHash(:AceSpeech, acespeeches)
  MessageTypes.setMessagesAsHash(:EndSpeechLose, lossspeeches)
  MessageTypes.setMessagesAsHash(:OtherTrainerSpeech, otherspeeches)
  cprint "Compiled data for trainers.dat#{" " * spacetoclear}\n"
  save_data(fulltrainerdata, directory + "/trainers.dat")
  cprint "Saved trainers.dat\n\n"
  $cache.cacheTrainers if $cache
end

def compileBosses(directory = nil, game: nil)
  file = "bosstext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  bossdata = {}
  spacetoclear = 10
  BOSSINFOHASH.each { |boss, data|
    spacetoclear = boss.to_s.length
    cprint "Compiling data for #{boss}#{" " * spacetoclear}\r"
    bossdata[boss] = BossData.new(boss, data)
    next if boss == :SHADOWDEN # Dummy object for Den encounters

    validateMon([boss], data[:moninfo])
    if data[:sosDetails]
      data[:sosDetails][:moninfos].each { |sos, mon| validateMon([boss, :sos, sos], mon) }
    end
    if data[:onBreakEffects]
      data[:onBreakEffects].each { |shield, br|
        species = br[:speciesUpdate] || data[:moninfo][:species]
        form = br[:formchange] || data[:moninfo][:form] || 0
        validateMon([boss, :shield, shield], {
          :species => species,
          :form => form,
          :ability => br[:abilitychange],
          :moves => br[:movesetUpdate],
          :nature => br[:nature],
          :item => br[:item],
          :types => br[:typeChange]
        })
      }
    end
  }
  cprint "Compiled data for bossdata.dat#{" " * spacetoclear}\n"
  save_data(bossdata, directory + "/bossdata.dat")
  cprint "Saved bossdata.dat\n\n"
  $cache.cacheBosses if $cache
end

def compileConnections(directory = nil)
  file = "mapconnections.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  connections = {}
  spacetoclear = 10
  MAPCONNECTIONSHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    connections[key] = value
  }
  connections = MapFactoryHelper.processConnections(connections)
  cprint "Compiled data for connections.dat#{" " * spacetoclear}\n"
  save_data(connections, directory + "/connections.dat")
  cprint "Saved connections.dat\n\n"
  $cache.cacheConnections if $cache
end

def compileFields(directory = nil, game: nil)
  file = "fieldtext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  fields = {}
  FIELDEFFECTS[nil] = FIELDEFFECTS[:INDOOR].clone
  FIELDEFFECTS[0] = FIELDEFFECTS[:INDOOR].clone
  spacetoclear = 10
  fieldMessages = []

  FIELDEFFECTS.each { |key, data|
    spacetoclear = key.to_s.length if key != nil && key != 0
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    currentfield = FEData.new
    # Basic data copying
    currentfield.name = data[:name]
    fieldMessages.push data[:name]
    currentfield.fieldAppSwitch = data[:fieldAppSwitch]
    currentfield.message = data[:fieldMessage]
    fieldMessages.push data[:fieldMessage]
    currentfield.secretPower = data[:secretPower]
    currentfield.graphic = data[:graphic]
    currentfield.naturePower = data[:naturePower]
    currentfield.mimicry = data[:mimicry]
    currentfield.burmyCloak = data[:burmyCloak]
    currentfield.statusBuffs = data[:statusBuffs]
    currentfield.statusNerfs = data[:statusNerfs]
    currentfield.overlayStatusBuffs = data[:overlay][:statusBuffs] if data[:overlay]
    currentfield.overlayStatusNerfs = data[:overlay][:statusNerfs] if data[:overlay]
    # now for worse shit
    # invert hashes such that move => mod
    movetypemod = pbHashForwardizer(data[:typeMods]) || {}
    movedamageboost = pbHashForwardizer(data[:damageMods]) || {}
    moveaccuracyboost = pbHashForwardizer(data[:accuracyMods]) || {}
    counterincreases = pbHashForwardizer(data[:fieldCounterIncreases]) || {}
    moveeffects = pbHashForwardizer(data[:moveEffects]) || {}
    typedamageboost = pbHashForwardizer(data[:typeBoosts]) || {}
    typetypemod = pbHashForwardizer(data[:typeAddOns]) || {}
    fieldchange = pbHashForwardizer(data[:fieldChange]) || {}
    changeeffects = pbHashForwardizer(data[:changeEffects]) || {}
    typecondition = data[:typeCondition] ? data[:typeCondition] : {}
    typeeffects = data[:typeEffects] ? data[:typeEffects] : {}
    changecondition = data[:changeCondition] ? data[:changeCondition] : {}
    dontchangebackup = data[:dontChangeBackup] ? data[:dontChangeBackup] : {}
    if data[:overlay]
      overlaydamage = pbHashForwardizer(data[:overlay][:damageMods]) || {}
      overlaytypemod = pbHashForwardizer(data[:overlay][:typeMods]) || {}
      overlaytypeboost = pbHashForwardizer(data[:overlay][:typeBoosts]) || {}
      overlaytypecons = data[:overlay][:typeCondition] ? data[:overlay][:typeCondition] : {}
    end

    # messages get stored separately and are replaced by an index
    movemessages  = data[:moveMessages]  || {}
    typemessages  = data[:typeMessages]  || {}
    changemessage = data[:changeMessage] || {}
    overlaymovemsg = data[:overlay][:moveMessages] || {} if data[:overlay]
    overlaytypemsg = data[:overlay][:typeMessages] || {} if data[:overlay]
    movemessagelist = []
    typemessagelist = []
    changemessagelist = []
    olmovemessagelist = []
    oltypemessagelist = []
    messagearray = [movemessages, typemessages, changemessage]
    messagearray = [movemessages, typemessages, changemessage, overlaymovemsg, overlaytypemsg] if data[:overlay]
    messagearray.each_with_index { |hashdata, index|
      messagelist = hashdata.keys
      fieldMessages.push *messagelist
      newhashdata = {}
      hashdata.each { |key, value|
        newhashdata[messagelist.index(key) + 1] = value
      }
      invhash = pbHashForwardizer(newhashdata)
      case index
        when 0
          movemessagelist = messagelist
          movemessages = invhash
        when 1
          typemessagelist = messagelist
          typemessages = invhash
        when 2
          changemessagelist = messagelist
          changemessage = invhash
        when 3
          olmovemessagelist = messagelist
          overlaymovemsg = invhash
        when 4
          oltypemessagelist = messagelist
          overlaytypemsg = invhash
      end
    }

    # now we have all our hashes de-backwarded, and can fuse them all together.
    # first, moves:
    # get all the keys in one place
    keys = (movedamageboost.keys << movetypemod.keys << moveaccuracyboost.keys << counterincreases.keys << moveeffects.keys << fieldchange.keys).flatten
    # now we take all the old hashes and squish them into one:
    fieldmovedata = {}
    for move in keys
      movedata = {}
      movedata[:mult] = movedamageboost[move] if movedamageboost[move]
      movedata[:typemod] = movetypemod[move] if movetypemod[move]
      movedata[:accmod] = moveaccuracyboost[move] if moveaccuracyboost[move]
      movedata[:multtext] = movemessages[move] if movemessages[move]
      movedata[:counterincrease] = counterincreases[move] if counterincreases[move]
      movedata[:moveeffect] = moveeffects[move] if moveeffects[move]
      movedata[:fieldchange] = fieldchange[move] if fieldchange[move]
      movedata[:changetext] = changemessage[move] if changemessage[move]
      movedata[:changeeffect] = changeeffects[move] if changeeffects[move]
      movedata[:dontchangebackup] = dontchangebackup.include?(move)
      fieldmovedata[move] = movedata
    end
    # now, types!
    fieldtypedata = {}
    keys = (typedamageboost.keys << typetypemod.keys << typeeffects.keys).flatten
    for type in keys
      typedata = {}
      typedata[:mult] = typedamageboost[type] if typedamageboost[type]
      typedata[:typemod] = typetypemod[type] if typetypemod[type]
      typedata[:typeeffect] = typeeffects[type] if typeeffects[type]
      typedata[:multtext] = typemessages[type] if typemessages[type]
      typedata[:condition] = typecondition[type] if typecondition[type]
      fieldtypedata[type] = typedata
    end
    if data[:overlay]
      overlaymovedata = {}
      keys = (overlaydamage.keys << overlaytypemod.keys).flatten
      for move in keys
        movedata = {}
        movedata[:mult] = overlaydamage[move] if overlaydamage[move]
        movedata[:typemod] = overlaytypemod[move] if overlaytypemod[move]
        movedata[:multtext] = overlaymovemsg[move] if overlaymovemsg[move]
        overlaymovedata[move] = movedata
      end
      overlaytypedata = {}
      keys = overlaytypeboost.keys
      for type in keys
        typedata = {}
        typedata[:mult] = overlaytypeboost[type] if overlaytypeboost[type]
        typedata[:multtext] = overlaytypemsg[type] if overlaytypemsg[type]
        typedata[:condition] = overlaytypecons[type] if overlaytypecons[type]
        overlaytypedata[type] = typedata
      end
    end

    # seeds for good measure.
    seeddata = data[:seed]
    fieldMessages.push seeddata[:message] if seeddata[:message]
    currentfield.fieldtypedata = fieldtypedata
    currentfield.fieldmovedata = fieldmovedata
    currentfield.seeddata = seeddata
    currentfield.movemessagelist = movemessagelist
    currentfield.typemessagelist = typemessagelist
    currentfield.changemessagelist = changemessagelist
    currentfield.fieldchangeconditions = changecondition
    currentfield.overlay = true if data[:overlay] && ![0, nil, :INDOOR].include?(key)
    currentfield.overlaytypedata = overlaytypedata if overlaytypedata
    currentfield.overlaymovedata = overlaymovedata if overlaymovedata
    currentfield.overlaymovemessagelist = olmovemessagelist if olmovemessagelist
    currentfield.overlaytypemessagelist = oltypemessagelist if oltypemessagelist
    # all done!
    fields.store(key, currentfield)
  }
  MessageTypes.setMessagesAsHash(:FieldMessages, fieldMessages)
  cprint "Compiled data for fields.dat#{" " * spacetoclear}\n"
  save_data(fields, directory + "/fields.dat")
  cprint "Saved fields.dat\n\n"
  $cache.cacheFields if $cache
end

def compileNatures(directory = nil, game: nil)
  file = "naturetext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  natures = {}
  names = []
  spacetoclear = 10
  NATUREHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    natures[key] = NatureData.new(key, value)
    names.push natures[key].name
  }
  MessageTypes.setMessagesAsHash(:Natures, names)
  cprint "Compiled data for natures.dat#{" " * spacetoclear}\n"
  save_data(natures, directory + "/natures.dat")
  cprint "Saved natures.dat\n\n"
  $cache.cacheNatures if $cache
end

def compileAnimations(directory = "Data")
  if Dir.glob('Animations/Anim*.rb').length == 0
    cprint "No animations found, running convertAnimations\n"
    convertAnimations
    cprint "Animations converted successfully\n"
  end
  cprint "Loading Animations..."
  pbanims = loadAnimations(all: true)
  cprint "done\n"
  move2anim = [{}, {}]
  spacetoclear = 10
  moves = $cache.moves
  # Always load gen 9 moves for Reborn even in Gen 7 mode
  if Reborn && Gen < 9
    moves = load_data($cache.directory + "/moves_modern.dat")
  end
  errors = []
  for i in 0...pbanims.length
    anim = pbanims[i]
    next if !anim

    spacetoclear = anim.name.length
    cprint "Compiling data for #{anim.name}#{" " * spacetoclear}\r"
    if anim.name[/^OppMove\:\s*(.*)$/]
      if moves.key?(anim.name.split(":")[1].intern)
        moveid = anim.name.split(":")[1].intern
        move2anim[1][moveid.intern] = i
      end
    elsif anim.name[/^Move\:\s*(.*)$/]
      if moves.key?(anim.name.split(":")[1].intern)
        moveid = anim.name.split(":")[1].intern
        move2anim[0][moveid.intern] = i
      end
    end

    verifyFile = -> (file, *extensions) {
      return if assetExists(file, *extensions, true)
      if assetExists(file, *extensions, false)
        errors.push sprintf("Anim%04d - %s uses wrong case for %s", i, anim.name, file)
      else
        errors.push sprintf("Anim%04d - %s is missing file %s", i, anim.name, file)
      end
    }

    if anim.graphic != ""
      verifyFile.call("Graphics/Animations/" + anim.graphic, "png")
    end
    anim.timing.each do |timing|
      if timing.name != ""
        if timing.timingType == AnimationFactory::TIMING_TYPE_INVERSE[:play_se]
          verifyFile.call("Audio/SE/" + timing.name, "ogg", "wav")
        else
          verifyFile.call("Graphics/Animations/" + timing.name, "png")
        end
      end
    end
  end

  errors.each do |error|
    puts error
  end

  cprint "Compiled data for battleanims.dat and move2anim.dat#{" " * spacetoclear}\n"
  save_data(move2anim, directory + "/move2anim.dat")
  cprint "Saved move2anim.dat\n\n"
  save_data(pbanims, directory + "/battleanims.dat")
  cprint "Saved battleanims.dat\n\n"
  $cache.cacheAnims if $cache
  # I don't think this is needed?
  # It doesn't make sense to call this only after saving battleanims.dat.
  # animExpander($cache.animations)
end

def assetExists(file, *extensions, sensitive)
  dir = File.dirname(file)
  basename = File.basename(file, File.extname(file))
  for extension in extensions
    return true if sensitive && fileExistsCaseSensitive?("#{dir}/#{basename}.#{extension}")
    return true if !sensitive && fileExists?("#{dir}/#{basename}.#{extension}")
  end
  return false
end

def validateBGM(bgm, field, key)
  bgm = bgm.is_a?(Hash) ? bgm[:name] : bgm
  puts "Missing #{field.inspect} for #{key.inspect}: #{bgm}" if bgm.to_s != "" && bgm != "none" && !assetExists("Audio/BGM/" + bgm, "ogg", "mp3", true)
end

def fileExistsCaseSensitive?(path)
  dir = File.dirname(path)
  base = File.basename(path)
  return Dir.entries(dir).include?(base)
end

def animExpander(animations)
  # animations
  for i in 0...animations.length
    # frames
    for j in 1...animations[i].length
      # cels
      for k in 0...animations[i][j].length
        # if a cel is 0 (normally it's an array)
        if animations[i][j][k] == 0
          # replace it with the same cel of the previous frame
          animations[i][j][k] = animations[i][j - 1][k].clone
        end
      end
    end
  end
end

def compileMartData(directory = nil, game: nil)
  file = "marttext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  marts = {}
  spacetoclear = 10
  martmessages = []
  martnames = ["Buy"]
  martitemnames = []
  martdescriptions = []
  for key, value in MARTHASH
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    marts[key] = MartData.new(key, value)
    for message in marts[key].Messages.values
      martmessages.push(message) if message && !message.empty?
    end

    scanning = [marts[key].Inventory]
    until scanning.empty?
      inventory = scanning.shift
      if inventory.is_a?(Array)
        for item in inventory
          martitemnames.push(item.name) if item.name
          martitemnames.push(item.display_name) if item.display_name
          martitemnames.push(item.currency_shortname) if item.currency_shortname

          martdescriptions.push(item.description) if item.description

          martmessages.push(item.purchase_confirm_single) if item.purchase_confirm_single
          martmessages.push(item.purchase_confirm_multiple) if item.purchase_confirm_multiple
          martmessages.push(item.choose_quantity) if item.choose_quantity
          martmessages.push(item.success_message) if item.success_message&.empty?

          if item.is_a?(PokemonStock)
            validateMon([key], item.pokemon)
          end
        end
      elsif inventory.is_a?(Hash)
        martnames.push(*inventory.keys)
        scanning.push(*inventory.values)
      end
    end
  end
  MessageTypes.setMessagesAsHash(:MartMessages, martmessages)
  MessageTypes.setMessagesAsHash(:MartNames, martnames)
  MessageTypes.setMessagesAsHash(:MartItemNames, martitemnames)
  MessageTypes.setMessagesAsHash(:MartDescriptions, martdescriptions)
  cprint "Compiled data for marts.dat#{" " * spacetoclear}\n"
  save_data(marts, directory + "/marts.dat")
  cprint "Saved marts.dat\n\n"
  $cache.cacheMarts if $cache
end

def compilePasswords(directory = nil, game: nil)
  file = "passwordtext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  passwords = {}
  names = []
  categories = []
  descriptions = []
  misc = []

  for key, value in PASSWORD_HASH[:Bulk]
    spacetoclear = key.to_s.length
    cprint "Compiling data for bulk pw #{key}#{" " * spacetoclear}\r"
    pass = BulkPasswordData.new(key, value, PASSWORD_HASH[:Categories])
    categories.push(pass.category)
    names.push(pass.name)
    descriptions.push(pass.description)
    passwords[key] = pass

    pass.aliases&.each { |pwAlias| passwords[pwAlias] = pass }
  end

  for key, value in PASSWORD_HASH[:Passwords]
    spacetoclear = key.to_s.length
    cprint "Compiling data for pw #{key}#{" " * spacetoclear}\r"

    pass = PasswordData.new(key, value, PASSWORD_HASH[:Categories])
    categories.push(pass.category)
    names.push(pass.name)
    descriptions.push(pass.description)
    passwords[key] = pass

    misc += pass.function.collectStrings

    pass.aliases&.each { |pwAlias| passwords[pwAlias] = pass }
  end

  passwords[:Ordering] = PASSWORD_HASH[:Categories].values

  MessageTypes.setMessagesAsHash(:PasswordNames, names)
  MessageTypes.setMessagesAsHash(:PasswordCategories, categories)
  MessageTypes.setMessagesAsHash(:PasswordDescriptions, descriptions)
  MessageTypes.setMessagesAsHash(:PasswordMisc, misc)
  cprint "Compiled data for passwords.dat#{" " * spacetoclear}\n"
  save_data(passwords, directory + "/passwords.dat")
  cprint "Saved passwords.dat\n\n"
  $cache.cachePasswords if $cache
end

def compileBTData(directory = nil, game: nil)
  return if Desolation

  compileBTMons(directory)
  compileBTTrainers(directory)
end

def compileBTMons(directory = nil, game: nil)
  file = "btpokemon.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  btmons = {}
  spacetoclear = 10
  BTMONS.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    btmons[key] = []
    for set in value
      set[:species] = key
      btmons[key].push(BTPokemon.new(set))
      validateMon([:BTMons, key, value.index(set)], set)
    end
  }
  cprint "Compiled data for btmons.dat#{" " * spacetoclear}\n"
  save_data(btmons, directory + "/btmons.dat")
  cprint "Saved btmons.dat\n\n"
  $cache.cacheBTMons if $cache
end

def compileBTTrainers(directory = nil, game: nil)
  file = "bttrainers.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  bttrainers = []
  spacetoclear = 10
  names = []
  introspeeches = []
  winspeeches = []
  losespeeches = []
  BTTRAINERS.each { |data|
    # spacetoclear = data[:tclass].to_s.length + data[:name].length + 1
    cprint "Compiling data for #{data[:tclass]} #{data[:name]}#{" " * 10}\r"
    if data[:monIndexes].length < 4
      raise "Less than 4 mons on facility trainer #{data[:tclass]} #{data[:name]}"
    end

    for mon in data[:monIndexes]
      if !BTMONS.keys.include?(mon)
        raise "No sets for #{mon} on facility trainer #{data[:tclass]} #{data[:name]}"
        return
      end
    end
    bttrainers.push(BTTrainerData.new(data))
    names.push(data[:name])
    introspeeches.push(data[:introSpeech])
    winspeeches.push(data[:winSpeech])
    losespeeches.push(data[:loseSpeech])
  }
  MessageTypes.setMessagesAsHash(:BattleTowerTrainerNames, names)
  MessageTypes.setMessagesAsHash(:BattleTowerIntroSpeech, introspeeches)
  MessageTypes.setMessagesAsHash(:BattleTowerWinSpeech, winspeeches)
  MessageTypes.setMessagesAsHash(:BattleTowerLoseSpeech, losespeeches)
  cprint "Compiled data for bttrainers.dat#{" " * spacetoclear}\n"
  save_data(bttrainers, directory + "/bttrainers.dat")
  cprint "Saved bttrainers.dat\n\n"
  $cache.cacheBTTrainers if $cache
end

def compilePokedexes(directory = nil, game: nil)
  file = "dextext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  dexes = {}
  dexnames = []
  spacetoclear = -1
  POKEDEXHASH.each { |key, data|
    spacetoclear = data[:name].length + 1
    cprint "Compiling data for Pokedex #{data[:name]}#{" " * spacetoclear}\r"
    dexes.store(key, PokedexData.new(key, data))
    dexnames.push(data[:name])
  }
  MessageTypes.setMessagesAsHash(:RegionalPokedexNames, dexnames)
  cprint "Compiled data for pokedexes.dat#{" " * spacetoclear}\n"
  save_data(dexes, directory + "/pokedexes.dat")
  cprint "Saved pokedexes.dat\n\n"
  $cache.cachePokedexes if $cache
end

def compileFieldNotes(directory = nil, game: nil)
  file = "fieldnotetext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path("fieldtext.rb", game: game)) { |f| eval(f.read) }
  File.open(definition_file_path(file, game: game)) { |f| eval(f.read) }
  cprint "done\n"

  fieldNoteMessages = []
  lastfield = nil
  FIELDNOTES.each do |note|
    fieldNoteMessages.push $cache.FEData[note.fieldeffect].name unless note.fieldeffect == lastfield
    lastfield = note.fieldeffect
    fieldNoteMessages.push note.text
    fieldNoteMessages.push note.elaboration if note.elaboration
  end
  MessageTypes.setMessagesAsHash(:FieldNotes, fieldNoteMessages)
  fieldnotes = FIELDNOTES.compact

  cprint "Compiled data for fieldnotes.dat\n"
  save_data(fieldnotes, directory + "/fieldnotes.dat")
  cprint "Saved fieldnotes.dat\n\n"
  $cache.cacheFieldNotes if $cache
end

def compileCurrencies(directory = nil, game: nil)
  file = "currencytext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  currencies = {}
  currencyNames = []
  currencyPlurals = []
  currencyShorthands = []
  currencyShorthandPlurals = []
  currencyDescriptions = []
  CURRENCYHASH.each { |currency, data|
    currencies.store(currency, CurrencyData.new(currency, data))
    currencyNames.push(data[:name]) if data[:name]
    currencyPlurals.push(data[:plural]) if data[:plural]
    currencyShorthands.push(data[:shorthand]) if data[:shorthand]
    currencyShorthandPlurals.push(data[:shortplural]) if data[:shortplural]
    currencyDescriptions.push(data[:desc]) if data[:desc]
  }
  MessageTypes.setMessagesAsHash(:CurrencyNames, currencyNames)
  MessageTypes.setMessagesAsHash(:CurrencyPlurals, currencyPlurals)
  MessageTypes.setMessagesAsHash(:CurrencyShorthands, currencyShorthands)
  MessageTypes.setMessagesAsHash(:CurrencyShorthandPlurals, currencyShorthandPlurals)
  MessageTypes.setMessagesAsHash(:CurrencyDescriptions, currencyDescriptions)

  cprint "Compiled data for currencies.dat\n"
  save_data(currencies, directory + "/currencies.dat")
  cprint "Saved currencies.dat\n\n"
  $cache.cacheCurrencies if $cache
end

def compileAnimSheets(directory = nil, game: nil)
  file = "animsheettext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"

  save_data(ANIMSHEETS, directory + "/animSheets.dat")
  cprint "Saved animSheets.dat\n\n"
  $cache.cacheAnimSheets if $cache
end

### COMPILER UTILS ###

def scripts_path
  return "./Scripts"
end

def use_patch_definition(filename)
  return File.exist?("patch/Definitions/#{filename}")
end

def definition_file_path(filename, game: nil)
  if game.nil?
    return "patch/Definitions/#{filename}" if use_patch_definition(filename)
    game = GAMEFOLDER
  end
  return scripts_path + "/#{game}/Definitions/#{filename}"
end

def data_directory(filename)
  return use_patch_definition(filename) ? "patch/Data" : "Data"
end

def current_commit
  git_dir = ".git"
  head_file = File.join(git_dir, "HEAD")
  head_content = File.read(head_file).strip

  if head_content.start_with?("ref: ")
    ref = head_content[5..-1]
    ref_file = File.join(git_dir, ref)
    if File.exist?(ref_file)
      return File.read(ref_file).strip
    else
      packed_refs_file = File.join(git_dir, "packed-refs")
      if File.exist?(packed_refs_file)
        regex = /^([0-9a-f]{40})\s#{Regexp.escape(ref)}$/
        File.foreach(packed_refs_file) do |line|
          match = regex.match(line)
          return match[1] if match
        end
      end
      return nil
    end
  end

  return head_content
end

def checkIfMoveDescFits(move, desc)
  return if $GAME # Skip during Test Suite
  return if GAME_VERSION != "dev" # Skip if not on dev

  bitmap = BitmapSprite.new(Graphics.width, Graphics.height, nil).bitmap
  pbSetSystemFont(bitmap)
  for i in 0..1 # 0 = Rejuv/Deso, 1 = Reborn
    width = i == 0 ? 230 : 236 - 8 - 6 # Might need to be updated
    linesavailable = i == 0 ? 5 : 6
    chunks = getLineBrokenChunks(bitmap, desc, width, nil, true)
    lines = chunks.count { |v| v[1] == 0 }
    puts "!!! #{move} description is too long for #{i == 0 ? "Rejuv/Deso" : "Reborn"} (#{lines} lines)" if lines > linesavailable
  end
end

def checkIfDexEntryFits(species, formname, entry)
  return if $GAME # Skip during Test Suite
  return if GAME_VERSION != "dev" # Skip if not on dev
  return if formname.include?("PULSE") # Dex entries for PULSE Pokemon go to PUSLE Dex

  bitmap = BitmapSprite.new(Graphics.width, Graphics.height, nil).bitmap
  pbSetSystemFont(bitmap)
  width = PokemonPokedexScene::DEX_ENTRY_OFFSET[2]
  linesavailable = 4
  chunks = getLineBrokenChunks(bitmap, entry, width, nil, true)
  lines = chunks.count { |v| v[1] == 0 }
  puts "!!! #{species} #{formname} dex entry is too long (#{lines} lines)" if lines > linesavailable
end

def checkIfItemDescFits(item, desc, tm: false) # Item is actually a move symbol for TMs
  return if $GAME # Skip during Test Suite
  return if GAME_VERSION != "dev" # Skip if not on dev

  bitmap = BitmapSprite.new(Graphics.width, Graphics.height, nil).bitmap
  pbSetSystemFont(bitmap)
  width = 404
  linesavailable = 3
  chunks = getLineBrokenChunks(bitmap, desc, width, nil, true)
  lines = chunks.count { |v| v[1] == 0 }
  puts "!!! #{item}#{tm ? " TM" : ""} description is too long (#{lines} lines)" if lines > linesavailable
end

def checkIfItemNameFits(name)
  return if $GAME # Skip during Test Suite
  return if GAME_VERSION != "dev" # Skip if not on dev

  bitmap = BitmapSprite.new(Graphics.width, Graphics.height, nil).bitmap
  pbSetSystemFont(bitmap)
  maxwidth = 188 # Space available for drawing item name in pokemon summary screen
  width = bitmap.text_size(name).width
  puts "!!! '#{name}' name is too long (by #{width - maxwidth} pixels)" if width > maxwidth
end

def validateMon(id, mon)
  return if $GAME # Skip during Test Suite
  return if GAME_VERSION != "dev" # Skip if not on dev

  form = mon.fetch(:form, 0)
  form = form[0] if form.is_a?(Array) # Boss animation
  gender = mon.fetch(:gender, nil)
  source = id.to_s + " " + getMonFormName(mon[:species], form, gender)

  unless $cache.pkmn[mon[:species]].hasForm?(form)
    # Note: It is recommended to add cosmetic-only forms such as Furfrou into montext when used by trainers.
    warnEntry(source, :form, form)
  end

  for key in mon.keys
    warnEntry(source, :attribute, key) if !PokemonBuilderHashKeys.include?(key) &&
      !TeamData::PerPokemonTeamAttributes.include?(key) &&
      ![:types, :BaseStats, :shinyChance, :catchRate].include?(key) # Validator shorthand, boss key, den keys
  end

  if mon[:moves]
    badmoves = PBStuff::ANIMATIONDUMMIES - PBStuff::SHOWCASEMOVES.keys
    mon[:moves].each { |m| warnEntry(source, :moves, m) if m != nil && (!$cache.moves.key?(m) || badmoves.include?(m)) }
  end

  if mon[:types]
    mon[:types].each { |m| warnEntry(source, :types, m) if m != nil && !$cache.types.key?(m) }
  end

  warnEntry(source, :ability, mon[:ability]) if mon[:ability] && !$cache.abil[mon[:ability]]
  warnEntry(source, :nature, mon[:nature]) if mon[:nature] && !$cache.natures[mon[:nature]]
  warnEntry(source, :item, mon[:item]) if mon[:item] && !$cache.items[mon[:item]]
  warnEntry(source, :shiny, mon[:shiny], "unnecessary") if mon[:shiny] == false

  if false # Switch to true to validate legality stuff
    # Gender
    if mon[:gender]
      ratio = $cache.pkmn[mon[:species], form].GenderRatio
      if [:Genderless, :MaleZero, :FemZero].include?(ratio)
        if mon[:gender] == { :Genderless => :N, :MaleZero => :F, :FemZero => :M }[ratio]
          warnEntry(source, :gender, mon[:gender], "unnecessary")
        else
          warnEntry(source, :gender, mon[:gender], "illegal")
        end
      elsif ![:M, :F, :N].include?(mon[:gender])
        warnEntry(source, :gender, mon[:gender], "illegal")
      end
    end
    # Ability
    if mon[:ability]
      warnEntry(source, :ability, mon[:ability], "illegal") if !$cache.pkmn[mon[:species], form, mon[:gender]].getAbilities.include?(mon[:ability])
    end
  end

  if mon[:disguise]
    validateMon(source + "-disguise", mon[:disguise])
  end
end

def warnEntry(source, attribute, err, type = "invalid")
  puts source + " has " + type + " " + attribute.to_s + " declared: " + err.to_s
end

def cprint(value) # i didn't want to type out $stdout.print every time lol
  $stdout.print(value)
  $stdout.flush
end

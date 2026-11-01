class Cache_Game
  attr_reader :xtpool
  attr_reader :wonderpool
  attr_reader :blessings
  attr_reader :denencounters
  attr_reader :dens
  attr_reader :trainers_story
  attr_reader :bosses_normal
  attr_reader :bosses_story

  def cacheXTPool
    compileXTPool unless fileExists?("Data/xtpool.dat")
    @xtpool = load_data("Data/xtpool.dat")
  end

  def cacheWonderPool
    compileWonderPool unless fileExists?("Data/wonderpool.dat")
    @wonderpool = load_data("Data/wonderpool.dat")
  end

  def cacheBlessings
    compileBlessings unless fileExists?("Data/blessings.dat")
    @blessings = load_data("Data/blessings.dat")
  end

  def cacheDenEncounters
    compileDenEncounters unless fileExists?("Data/denencounters.dat")
    @denencounters = load_data("Data/denencounters.dat")
  end

  def cacheDens
    compileDens unless fileExists?("Data/dens.dat")
    @dens = load_data("Data/dens.dat")
  end

  def cacheTrainersStory
    compileTrainersStory unless fileExists?("Data/trainers_story.dat")
    @trainers_story = load_data("Data/trainers_story.dat")
  end

  def cacheBossesStory
    compileBossesStory unless fileExists?("Data/bossdata_story.dat")
    @bosses_story = load_data("Data/bossdata_story.dat")
  end

  alias __core_load loadRuntimeData unless method_defined?(:__core_load)
  def loadRuntimeData
    __core_load
    cacheXTPool
    cacheWonderPool
    cacheBlessings
    cacheDenEncounters
    cacheDens
    cacheTrainersStory
    cacheBossesStory
    bosspatch
  end

  def bosspatch
    @bosses_normal = @bosses.is_a?(BossDifficultyWrapper) ? @bosses.normal : @bosses
    @bosses = BossDifficultyWrapper.new(@bosses_normal, @bosses_story)
  end
end

def compileXTPool(directory = nil)
  file = "xtpool.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  xtpool = PoolEncounterWrapper.new()
  spacetoclear = 10
  XTPOOL.each { |tier, pokemon|
    pokemon.each { |mon, value|
      spacetoclear = mon.to_s.length
      cprint "Compiling data for #{mon}#{" " * spacetoclear}\r"

      xtpool[mon] = [] unless xtpool.keys.include?(mon)
      for set in value
        xtpool[mon].push(XTEncounter.new(mon, tier, set))
        set[:species] ||= mon
        validateMon([:XTPool, mon, value.index(set)], set)
      end
    }
  }
  xtpool.gatherPools
  cprint "Compiled data for xtpool.dat#{" " * spacetoclear}\n"
  save_data(xtpool, directory + "/xtpool.dat")
  cprint "Saved xtpool.dat\n\n"
  $cache.cacheXTPool if $cache
end

def compileWonderPool(directory = nil)
  file = "wonderpool.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  wonderpool = PoolEncounterWrapper.new()
  spacetoclear = 10
  WONDERPOOL.each { |tier, pokemon|
    pokemon.each { |mon, value|
      spacetoclear = mon.to_s.length
      cprint "Compiling data for #{mon}#{" " * spacetoclear}\r"

      wonderpool[mon] = [] unless wonderpool.keys.include?(mon)
      for set in value
        wonderpool[mon].push(PoolEncounter.new(mon, tier, set))
        set[:species] ||= mon
        validateMon([:WonderPool, mon, value.index(set)], set)
      end
    }
  }
  wonderpool.gatherPools
  cprint "Compiled data for wonderpool.dat#{" " * spacetoclear}\n"
  save_data(wonderpool, directory + "/wonderpool.dat")
  cprint "Saved wonderpool.dat\n\n"
  $cache.cacheWonderPool if $cache
end

def compileBlessings(directory = nil)
  file = "blessingtxt.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  names = []
  desc = []
  rules = []
  blessings = {}
  spacetoclear = 10
  BLESSINGS.each { |blessing, data|
    spacetoclear = blessing.to_s.length
    cprint "Compiling data for #{blessing}#{" " * spacetoclear}\r"

    data[:maxRank] ||= 3
    data[:desc] = Array.new(data[:maxRank], data[:desc]) if !data[:desc].is_a?(Array)
    data[:values].transform_values! { |value|
      next value if value.is_a?(Array) && value.length == data[:maxRank]
      next Array.new(data[:maxRank], value)
    }
    blessings[blessing] = BlessingData.new(blessing, data)

    names.push(data[:name])
    if data[:desc]&.is_a?(Array)
      desc += data[:desc]
    else
      desc.push(data[:desc])
    end
    rules += data[:rules] if data[:rules]
  }
  MessageTypes.addMessagesAsHash(:BlessingNames, names)
  MessageTypes.addMessagesAsHash(:BlessingDescriptions, desc)
  MessageTypes.addMessagesAsHash(:BlessingRules, rules)
  cprint "Compiled data for blessings.dat#{" " * spacetoclear}\n"
  save_data(blessings, directory + "/blessings.dat")
  cprint "Saved blessings.dat\n\n"
  $cache.cacheBlessings if $cache
end

def blessingDump(blessings = $cache.blessings, game: nil, file: nil)
  exporttext = "BLESSINGS = {\n"
  cprint "Beginning #{"Blessing".yellow} dump...\n"
  blessings.each { |sym, blessing|
    cprint "Blessing #{sym.to_s.yellow}"
    exporttext += blessing.export
    cprint "             \r"
  }
  exporttext += "}\n"
  cprint "done.                                                \n".green
  file = "blessingtxt.rb" if file.nil?
  File.open(definition_file_path(file, game: game), "w") { |f|
    f.write(exporttext)
  }
end

def compileDenEncounters(directory = nil)
  file = "denenctext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  encs = {}
  spacetoclear = 10
  DENENCHASH.each { |id, set|
    spacetoclear = id.to_s.length
    cprint "Compiling data for #{id}#{" " * spacetoclear}\r"

    encs[id] = DenEncounter.new(id, set)
    set[:species] ||= id
    validateMon([:denEnc, id], set)
  }
  cprint "Compiled data for denencounters.dat#{" " * spacetoclear}\n"
  save_data(encs, directory + "/denencounters.dat")
  cprint "Saved denencounters.dat\n\n"
  $cache.cacheDenEncounters if $cache
end

def compileDens(directory = nil)
  file = "dentext.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file)) { |f|
    eval(f.read)
  }
  messages = []
  DENHASH.each { |den, data|
    messages.push(data.message)
    data.setID(den)
  }
  MessageTypes.addMessagesAsHash(:DenMessages, messages)
  cprint "done\n"
  save_data(DENHASH, directory + "/dens.dat")
  cprint "Saved dens.dat\n\n"
  $cache.dens if $cache
end

def compileTrainersStory(directory = nil, game: nil)
  compileTrainerTypes
  file = "trainertext_story.rb"
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
  acespeeches = []
  openingspeeches = []
  lossspeeches = []
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
      validateMon([trainer[:teamid], :STORY], mon)
    end

    name = trainer[:teamid][0]
    trainertype = trainer[:teamid][1]
    partyid = trainer[:teamid][2]

    if $cache.trainers
      normal = $cache.trainers[trainertype]&.dig(name)&.dig(partyid)
      if normal
        trainer[:trainerID] ||= normal.trainerID
        trainer = trainer.merge(normal.teamAttributes)
        trainer = trainer.merge(normal.flags)
      else
        puts "Could not find trainer #{trainer[:teamid]} for trainertext.rb"
      end
    end

    team = TeamData.new(index, trainer[:teamid], trainer)
    comp.push(trainer[:teamid])

    fulltrainerdata[trainertype] = {} if !fulltrainerdata[trainertype]
    fulltrainerdata[trainertype][name] = {} if !fulltrainerdata[trainertype][name]
    fulltrainerdata[trainertype][name][partyid] = team if !fulltrainerdata[trainertype][name][partyid]

    names.push(name)
    lossspeeches.push(trainer[:defeat]) if trainer[:defeat]
    acespeeches.push(trainer[:ace]) if trainer[:ace]
    openingspeeches.push(trainer[:openingLine]) if trainer[:openingLine]
  end
  MessageTypes.setMessagesAsHash(:TrainerNames, names)
  MessageTypes.setMessagesAsHash(:AceSpeech, acespeeches)
  MessageTypes.setMessagesAsHash(:EndSpeechLose, lossspeeches)
  MessageTypes.setMessagesAsHash(:OpeningSpeech, openingspeeches)
  cprint "Compiled data for trainers_story.dat#{" " * spacetoclear}\n"
  save_data(fulltrainerdata, directory + "/trainers_story.dat")
  cprint "Saved trainers_story.dat\n\n"
  $cache.cacheTrainersStory if $cache
end

def compileBossesStory(directory = nil, game: nil)
  file = "bosstext_story.rb"
  directory = data_directory(file) if directory.nil?
  cprint "Reading #{file}..."
  File.open(definition_file_path(file, game: game)) { |f|
    eval(f.read)
  }
  cprint "done\n"
  bossdata = {}
  comp = []
  spacetoclear = 10
  BOSSINFOHASH.each { |boss, data|
    spacetoclear = boss.to_s.length
    cprint "Compiling data for #{boss}#{" " * spacetoclear}\r"

    if $cache.bosses_normal
      normal = $cache.bosses_normal[boss]
      if normal
        data[:name] ||= normal.name
        data[:barGraphic] ||= normal.barGraphic
        data[:entryText] ||= normal.entryText
        data[:inspectText] ||= normal.inspectText
        data[:capturable] ||= normal.capturable
        data[:canrun] ||= normal.canrun
        data[:doublebattle] ||= normal.doublebattle
        data = data.merge(normal.flags)
      else
        puts "Could not find trainer #{boss} for bosstext.rb"
      end
    end

    if comp.include?(boss)
      puts "Duplicate trainer found for #{trainer[:teamid].inspect}"
    end

    bossdata[boss] = BossData.new(boss, data)
    comp.push(boss)
    next if boss == :SHADOWDEN # Dummy object for Den encounters

    validateMon([boss, :STORY], data[:moninfo])
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
  cprint "Compiled data for bossdata_story.dat#{" " * spacetoclear}\n"
  save_data(bossdata, directory + "/bossdata_story.dat")
  cprint "Saved bossdata_story.dat\n\n"
  if $cache
    $cache.cacheBossesStory
    $cache.bosspatch
  end
end

alias __core_compileTrainers compileTrainers unless defined?(__core_compileTrainers)
def compileTrainers(*args, **kwargs)
  __core_compileTrainers(*args, **kwargs)
  compileTrainersStory(*args, **kwargs)

  testTrainers = [
    ["Dan", :TEST, 0]
  ]
  skipTrainers = [

  ]

  if GAME_VERSION == "dev"
    $cache.trainers.each { |tclass, trainers|
      trainers.each { |name, teams|
        teams.each { |id, team|
          next if team.checkFlag?(:npc) || (testTrainers + skipTrainers).include?([name, tclass, id]) # Trainers that do not need story ver
          if $cache.trainers_story.dig(tclass)&.dig(name)&.dig(id).nil?
            puts "WARNING: Undefined Story trainer #{[name, tclass, id].inspect}"
          end
        }
      }
    }
  end
end

alias __core_compileBosses compileBosses unless defined?(__core_compileBosses)
def compileBosses(*args, **kwargs)
  __core_compileBosses(*args, **kwargs)
  compileBossesStory(*args, **kwargs)

  testBosses = [:GODKILLER, :CELEBITEST]
  skipBosses = [:SHADOWDEN, :NASTASIASDEOXYS, :NASTASIASDEOXYS2, :DAMIENSLATIOS, :DAMIENSLATIOS2, :WITHER]

  if GAME_VERSION == "dev"
    $cache.bosses_normal.each { |boss, _|
      next if (testBosses + skipBosses).include?(boss) # Bosses that do not need story ver
      if $cache.bosses_story[boss].nil?
        puts "WARNING: Undefined Story boss #{boss.inspect}"
      end
    }
  end
end

# function for jukebox spoilerfilter, needs to be loaded in init step of gamestart
def unspoilerTrack(track)
  return unless $Trainer # wait for $Trainer being loaded so that this isn't checked on startup
  return unless SPOILERTRACKS.include?(track)
  return unless $Unidata
  $Unidata[:heardTracks] = [] if !$Unidata[:heardTracks]

  return if $Unidata[:heardTracks].include?(track)

  $Unidata[:heardTracks].push(track)
end

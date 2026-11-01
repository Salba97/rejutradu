# The functions here can be used to validate our data against https://pokeapi.co/

require 'poke-api-v2'

def validateGen(gen = nil)
  validator = Validator.new
  validator.validateMovesets(gen)
end

# Rules:
# Level up and egg moves from USUM
# TMs + Tutor compatibilities from ORAS + USUM
# Headbutt and Rock Climb are compatible if they were ever compatible in any game
# Keeping event moves from Gen 3-7 (note: not validated because pokeapi doesn't have event moves info)
class Validator
  GENS = {
    1 => 1..151,
    2 => 152..251,
    3 => 252..386,
    4 => 387..493,
    5 => 494..649,
    6 => 650..721,
    7 => 722..807, # technically 809 but we consider Meltan line as Gen 8
    8 => 808..898, # technically 905 but we consider Legends Arceus as Gen 9
    9 => 899..1025, # Pecharunt is last at the time of writing
  }

  COMPATIBLE_MOVES = {
    :ORAS => [
      # TMs
      :HONECLAWS, :DRAGONCLAW, :PSYSHOCK, :CALMMIND, :ROAR, :TOXIC, :HAIL, :BULKUP, :VENOSHOCK, :HIDDENPOWER, :SUNNYDAY,
      :TAUNT, :ICEBEAM, :BLIZZARD, :HYPERBEAM, :LIGHTSCREEN, :PROTECT, :RAINDANCE, :ROOST, :SAFEGUARD, :FRUSTRATION,
      :SOLARBEAM, :SMACKDOWN, :THUNDERBOLT, :THUNDER, :EARTHQUAKE, :RETURN, :DIG, :PSYCHIC, :SHADOWBALL, :BRICKBREAK,
      :DOUBLETEAM, :REFLECT, :SLUDGEWAVE, :FLAMETHROWER, :SLUDGEBOMB, :SANDSTORM, :FIREBLAST, :ROCKTOMB, :AERIALACE,
      :TORMENT, :FACADE, :FLAMECHARGE, :REST, :ATTRACT, :THIEF, :LOWSWEEP, :ROUND, :ECHOEDVOICE, :OVERHEAT, :STEELWING,
      :FOCUSBLAST, :ENERGYBALL, :FALSESWIPE, :SCALD, :FLING, :CHARGEBEAM, :SKYDROP, :INCINERATE, :QUASH, :WILLOWISP,
      :ACROBATICS, :EMBARGO, :EXPLOSION, :SHADOWCLAW, :PAYBACK, :RETALIATE, :GIGAIMPACT, :ROCKPOLISH, :FLASH,
      :STONEEDGE, :VOLTSWITCH, :THUNDERWAVE, :GYROBALL, :SWORDSDANCE, :STRUGGLEBUG, :PSYCHUP, :BULLDOZE, :FROSTBREATH,
      :ROCKSLIDE, :XSCISSOR, :DRAGONTAIL, :INFESTATION, :POISONJAB, :DREAMEATER, :GRASSKNOT, :SWAGGER, :SLEEPTALK,
      :UTURN, :SUBSTITUTE, :FLASHCANNON, :TRICKROOM, :WILDCHARGE, :SECRETPOWER, :SNARL, :NATUREPOWER, :DARKPULSE,
      :POWERUPPUNCH, :DAZZLINGGLEAM, :CONFIDE,
      # Tutors
      :GRASSPLEDGE, :FIREPLEDGE, :WATERPLEDGE, :FRENZYPLANT, :BLASTBURN, :HYDROCANNON, :RELICSONG, :SECRETSWORD,
      :DRACOMETEOR, :DRAGONASCENT, :BIND, :SNORE, :WATERPULSE, :SHOCKWAVE, :BUGBITE, :COVET, :LOWKICK, :SIGNALBEAM,
      :GIGADRAIN, :THUNDERPUNCH, :FIREPUNCH, :ICEPUNCH, :DRAINPUNCH, :KNOCKOFF, :SUPERFANG, :DUALCHOP, :ENDEAVOR,
      :UPROAR, :IRONTAIL, :BOUNCE, :DRILLRUN, :IRONHEAD, :ZENHEADBUTT, :AQUATAIL, :DRAGONPULSE, :SEEDBOMB, :HEATWAVE,
      :LASTRESORT, :HYPERVOICE, :FOULPLAY, :EARTHPOWER, :OUTRAGE, :SUPERPOWER, :GUNKSHOT, :SKYATTACK, :FOCUSPUNCH,
      :BLOCK, :SKILLSWAP, :SYNTHESIS, :ROLEPLAY, :PAINSPLIT, :GASTROACID, :WORRYSEED, :SPITE, :AFTERYOU, :HELPINGHAND,
      :TRICK, :RECYCLE, :SNATCH, :MAGICCOAT, :MAGNETRISE, :IRONDEFENSE, :HEALBELL, :TAILWIND, :MAGICROOM, :WONDERROOM,
      :STEALTHROCK, :GRAVITY, :ELECTROWEB, :ICYWIND,
    ],
    :USUM => [
      # TMs
      :WORKUP, :DRAGONCLAW, :PSYSHOCK, :CALMMIND, :ROAR, :TOXIC, :HAIL, :BULKUP, :VENOSHOCK, :HIDDENPOWER, :SUNNYDAY,
      :TAUNT, :ICEBEAM, :BLIZZARD, :HYPERBEAM, :LIGHTSCREEN, :PROTECT, :RAINDANCE, :ROOST, :SAFEGUARD, :FRUSTRATION,
      :SOLARBEAM, :SMACKDOWN, :THUNDERBOLT, :THUNDER, :EARTHQUAKE, :RETURN, :LEECHLIFE, :PSYCHIC, :SHADOWBALL,
      :BRICKBREAK, :DOUBLETEAM, :REFLECT, :SLUDGEWAVE, :FLAMETHROWER, :SLUDGEBOMB, :SANDSTORM, :FIREBLAST, :ROCKTOMB,
      :AERIALACE, :TORMENT, :FACADE, :FLAMECHARGE, :REST, :ATTRACT, :THIEF, :LOWSWEEP, :ROUND, :ECHOEDVOICE, :OVERHEAT,
      :STEELWING, :FOCUSBLAST, :ENERGYBALL, :FALSESWIPE, :SCALD, :FLING, :CHARGEBEAM, :SKYDROP, :BRUTALSWING, :QUASH,
      :WILLOWISP, :ACROBATICS, :EMBARGO, :EXPLOSION, :SHADOWCLAW, :PAYBACK, :SMARTSTRIKE, :GIGAIMPACT, :ROCKPOLISH,
      :AURORAVEIL, :STONEEDGE, :VOLTSWITCH, :THUNDERWAVE, :GYROBALL, :SWORDSDANCE, :FLY, :PSYCHUP, :BULLDOZE,
      :FROSTBREATH, :ROCKSLIDE, :XSCISSOR, :DRAGONTAIL, :INFESTATION, :POISONJAB, :DREAMEATER, :GRASSKNOT, :SWAGGER,
      :SLEEPTALK, :UTURN, :SUBSTITUTE, :FLASHCANNON, :TRICKROOM, :WILDCHARGE, :SURF, :SNARL, :NATUREPOWER, :DARKPULSE,
      :WATERFALL, :DAZZLINGGLEAM, :CONFIDE,
      # Tutors
      :GRASSPLEDGE, :FIREPLEDGE, :WATERPLEDGE, :FRENZYPLANT, :BLASTBURN, :HYDROCANNON, :VOLTTACKLE, :SECRETSWORD,
      :RELICSONG, :DRACOMETEOR, :DRAGONASCENT, :SNORE, :HEALBELL, :ELECTROWEB, :DEFOG, :LOWKICK, :UPROAR, :BIND,
      :HELPINGHAND, :SHOCKWAVE, :BLOCK, :LASTRESORT, :WORRYSEED, :COVET, :BUGBITE, :SNATCH, :RECYCLE, :IRONTAIL,
      :SPITE, :AFTERYOU, :GIGADRAIN, :SYNTHESIS, :ALLYSWITCH, :SIGNALBEAM, :GRAVITY, :STEALTHROCK, :IRONDEFENSE,
      :TELEKINESIS, :MAGNETRISE, :BOUNCE, :ROLEPLAY, :FIREPUNCH, :WATERPULSE, :IRONHEAD, :AQUATAIL, :PAINSPLIT,
      :TAILWIND, :THUNDERPUNCH, :ENDEAVOR, :FOCUSPUNCH, :ICYWIND, :ZENHEADBUTT, :SEEDBOMB, :LASERFOCUS, :TRICK,
      :DRILLRUN, :MAGICCOAT, :ICEPUNCH, :MAGICROOM, :WONDERROOM, :LIQUIDATION, :GASTROACID, :FOULPLAY, :SUPERFANG,
      :OUTRAGE, :SKYATTACK, :THROATCHOP, :STOMPINGTANTRUM, :SKILLSWAP, :EARTHPOWER, :GUNKSHOT, :DUALCHOP, :DRAINPUNCH,
      :HEATWAVE, :HYPERVOICE, :SUPERPOWER, :KNOCKOFF, :DRAGONPULSE,
    ],
    :SwSh => [
      # TMs
      :MEGAPUNCH, :MEGAKICK, :PAYDAY, :FIREPUNCH, :ICEPUNCH, :THUNDERPUNCH, :FLY, :PINMISSILE, :HYPERBEAM, :GIGAIMPACT,
      :MAGICALLEAF, :SOLARBEAM, :SOLARBLADE, :FIRESPIN, :THUNDERWAVE, :DIG, :SCREECH, :LIGHTSCREEN, :REFLECT,
      :SAFEGUARD, :SELFDESTRUCT, :REST, :ROCKSLIDE, :THIEF, :SNORE, :PROTECT, :SCARYFACE, :ICYWIND, :GIGADRAIN, :CHARM,
      :STEELWING, :ATTRACT, :SANDSTORM, :RAINDANCE, :SUNNYDAY, :HAIL, :WHIRLPOOL, :BEATUP, :WILLOWISP, :FACADE, :SWIFT,
      :HELPINGHAND, :REVENGE, :BRICKBREAK, :IMPRISON, :DIVE, :WEATHERBALL, :FAKETEARS, :ROCKTOMB, :SANDTOMB,
      :BULLETSEED, :ICICLESPEAR, :BOUNCE, :MUDSHOT, :ROCKBLAST, :BRINE, :UTURN, :PAYBACK, :ASSURANCE, :FLING,
      :POWERSWAP, :GUARDSWAP, :SPEEDSWAP, :DRAINPUNCH, :AVALANCHE, :SHADOWCLAW, :THUNDERFANG, :ICEFANG, :FIREFANG,
      :PSYCHOCUT, :TRICKROOM, :WONDERROOM, :MAGICROOM, :CROSSPOISON, :VENOSHOCK, :LOWSWEEP, :ROUND, :HEX, :ACROBATICS,
      :RETALIATE, :VOLTSWITCH, :BULLDOZE, :ELECTROWEB, :RAZORSHELL, :TAILSLAP, :SNARL, :PHANTOMFORCE, :DRAININGKISS,
      :GRASSYTERRAIN, :MISTYTERRAIN, :ELECTRICTERRAIN, :PSYCHICTERRAIN, :MYSTICALFIRE, :EERIEIMPULSE, :FALSESWIPE,
      :AIRSLASH, :SMARTSTRIKE, :BRUTALSWING, :STOMPINGTANTRUM, :BREAKINGSWIPE,
      # TRs
      :SWORDSDANCE, :BODYSLAM, :FLAMETHROWER, :HYDROPUMP, :SURF, :ICEBEAM, :BLIZZARD, :LOWKICK, :THUNDERBOLT, :THUNDER,
      :EARTHQUAKE, :PSYCHIC, :AGILITY, :FOCUSENERGY, :METRONOME, :FIREBLAST, :WATERFALL, :AMNESIA, :LEECHLIFE,
      :TRIATTACK, :SUBSTITUTE, :REVERSAL, :SLUDGEBOMB, :SPIKES, :OUTRAGE, :PSYSHOCK, :ENDURE, :SLEEPTALK, :MEGAHORN,
      :BATONPASS, :ENCORE, :IRONTAIL, :CRUNCH, :SHADOWBALL, :FUTURESIGHT, :UPROAR, :HEATWAVE, :TAUNT, :TRICK,
      :SUPERPOWER, :SKILLSWAP, :BLAZEKICK, :HYPERVOICE, :OVERHEAT, :COSMICPOWER, :MUDDYWATER, :IRONDEFENSE,
      :DRAGONCLAW, :BULKUP, :CALMMIND, :LEAFBLADE, :DRAGONDANCE, :GYROBALL, :CLOSECOMBAT, :TOXICSPIKES, :FLAREBLITZ,
      :AURASPHERE, :POISONJAB, :DARKPULSE, :SEEDBOMB, :XSCISSOR, :BUGBUZZ, :DRAGONPULSE, :POWERGEM, :FOCUSBLAST,
      :ENERGYBALL, :BRAVEBIRD, :EARTHPOWER, :NASTYPLOT, :ZENHEADBUTT, :FLASHCANNON, :LEAFSTORM, :POWERWHIP, :GUNKSHOT,
      :IRONHEAD, :STONEEDGE, :STEALTHROCK, :GRASSKNOT, :SLUDGEWAVE, :HEAVYSLAM, :ELECTROBALL, :FOULPLAY, :STOREDPOWER,
      :ALLYSWITCH, :SCALD, :WORKUP, :WILDCHARGE, :DRILLRUN, :HEATCRASH, :HURRICANE, :PLAYROUGH, :VENOMDRENCH,
      :DAZZLINGGLEAM, :DARKESTLARIAT, :HIGHHORSEPOWER, :THROATCHOP, :POLLENPUFF, :PSYCHICFANGS, :LIQUIDATION,
      :BODYPRESS,
      # Tutors
      :TERRAINPULSE, :BURNINGJEALOUSY, :FLIPTURN, :GRASSYGLIDE, :RISINGVOLTAGE, :COACHING, :SCORCHINGSANDS,
      :DUALWINGBEAT, :METEORBEAM, :SKITTERSMACK, :TRIPLEAXEL, :CORROSIVEGAS, :EXPANDINGFORCE, :POLTERGEIST, :SCALESHOT,
      :LASHOUT, :STEELROLLER, :MISTYEXPLOSION,
    ],
    :BDSP => [
      # TMs
      :FOCUSPUNCH, :DRAGONCLAW, :WATERPULSE, :CALMMIND, :ROAR, :TOXIC, :HAIL, :BULKUP, :BULLETSEED, :WORKUP, :SUNNYDAY,
      :TAUNT, :ICEBEAM, :BLIZZARD, :HYPERBEAM, :LIGHTSCREEN, :PROTECT, :RAINDANCE, :GIGADRAIN, :SAFEGUARD,
      :DAZZLINGGLEAM, :SOLARBEAM, :IRONTAIL, :THUNDERBOLT, :THUNDER, :EARTHQUAKE, :LOWSWEEP, :DIG, :PSYCHIC,
      :SHADOWBALL, :BRICKBREAK, :DOUBLETEAM, :REFLECT, :SHOCKWAVE, :FLAMETHROWER, :SLUDGEBOMB, :SANDSTORM, :FIREBLAST,
      :ROCKTOMB, :AERIALACE, :TORMENT, :FACADE, :VOLTSWITCH, :REST, :ATTRACT, :THIEF, :STEELWING, :SKILLSWAP, :SCALD,
      :OVERHEAT, :ROOST, :FOCUSBLAST, :ENERGYBALL, :FALSESWIPE, :BRINE, :FLING, :CHARGEBEAM, :ENDURE, :DRAGONPULSE,
      :DRAINPUNCH, :WILLOWISP, :BUGBUZZ, :NASTYPLOT, :EXPLOSION, :SHADOWCLAW, :PAYBACK, :RECYCLE, :GIGAIMPACT,
      :ROCKPOLISH, :FLASH, :STONEEDGE, :AVALANCHE, :THUNDERWAVE, :GYROBALL, :SWORDSDANCE, :STEALTHROCK, :PSYCHUP,
      :SNARL, :DARKPULSE, :ROCKSLIDE, :XSCISSOR, :SLEEPTALK, :BULLDOZE, :POISONJAB, :DREAMEATER, :GRASSKNOT, :SWAGGER,
      :PLUCK, :UTURN, :SUBSTITUTE, :FLASHCANNON, :TRICKROOM, :CUT, :FLY, :SURF, :STRENGTH, :DEFOG, :ROCKSMASH,
      :WATERFALL, :ROCKCLIMB,
      # Tutors
      :BLASTBURN, :DRACOMETEOR, :FRENZYPLANT, :HYDROCANNON,
    ],
    :SV => [
      # TMs
      :TAKEDOWN, :CHARM, :FAKETEARS, :AGILITY, :MUDSLAP, :SCARYFACE, :PROTECT, :FIREFANG, :THUNDERFANG, :ICEFANG,
      :WATERPULSE, :LOWKICK, :ACIDSPRAY, :ACROBATICS, :STRUGGLEBUG, :PSYBEAM, :CONFUSERAY, :THIEF, :DISARMINGVOICE,
      :TRAILBLAZE, :POUNCE, :CHILLINGWATER, :CHARGEBEAM, :FIRESPIN, :FACADE, :POISONTAIL, :AERIALACE, :BULLDOZE, :HEX,
      :SNARL, :METALCLAW, :SWIFT, :MAGICALLEAF, :ICYWIND, :MUDSHOT, :ROCKTOMB, :DRAININGKISS, :FLAMECHARGE, :LOWSWEEP,
      :AIRCUTTER, :STOREDPOWER, :NIGHTSHADE, :FLING, :DRAGONTAIL, :VENOSHOCK, :AVALANCHE, :ENDURE, :VOLTSWITCH,
      :SUNNYDAY, :RAINDANCE, :SANDSTORM, :SNOWSCAPE, :SMARTSTRIKE, :PSYSHOCK, :DIG, :BULLETSEED, :FALSESWIPE,
      :BRICKBREAK, :ZENHEADBUTT, :UTURN, :SHADOWCLAW, :FOULPLAY, :PSYCHICFANGS, :BULKUP, :AIRSLASH, :BODYSLAM,
      :FIREPUNCH, :THUNDERPUNCH, :ICEPUNCH, :SLEEPTALK, :SEEDBOMB, :ELECTROBALL, :DRAINPUNCH, :REFLECT, :LIGHTSCREEN,
      :ROCKBLAST, :WATERFALL, :DRAGONCLAW, :DAZZLINGGLEAM, :METRONOME, :GRASSKNOT, :THUNDERWAVE, :POISONJAB,
      :STOMPINGTANTRUM, :REST, :ROCKSLIDE, :TAUNT, :SWORDSDANCE, :BODYPRESS, :SPIKES, :TOXICSPIKES, :IMPRISON,
      :FLASHCANNON, :DARKPULSE, :LEECHLIFE, :EERIEIMPULSE, :FLY, :SKILLSWAP, :IRONHEAD, :DRAGONDANCE, :POWERGEM,
      :GUNKSHOT, :SUBSTITUTE, :IRONDEFENSE, :XSCISSOR, :DRILLRUN, :WILLOWISP, :CRUNCH, :TRICK, :LIQUIDATION, :GIGADRAIN,
      :AURASPHERE, :TAILWIND, :SHADOWBALL, :DRAGONPULSE, :STEALTHROCK, :HYPERVOICE, :HEATWAVE, :ENERGYBALL, :PSYCHIC,
      :HEAVYSLAM, :ENCORE, :SURF, :ICESPINNER, :FLAMETHROWER, :THUNDERBOLT, :PLAYROUGH, :AMNESIA, :CALMMIND,
      :HELPINGHAND, :POLLENPUFF, :BATONPASS, :EARTHPOWER, :REVERSAL, :ICEBEAM, :ELECTRICTERRAIN, :GRASSYTERRAIN,
      :PSYCHICTERRAIN, :MISTYTERRAIN, :NASTYPLOT, :FIREBLAST, :HYDROPUMP, :BLIZZARD, :FIREPLEDGE, :WATERPLEDGE,
      :GRASSPLEDGE, :WILDCHARGE, :SLUDGEBOMB, :EARTHQUAKE, :STONEEDGE, :PHANTOMFORCE, :GIGAIMPACT, :BLASTBURN,
      :HYDROCANNON, :FRENZYPLANT, :OUTRAGE, :OVERHEAT, :FOCUSBLAST, :LEAFSTORM, :HURRICANE, :TRICKROOM, :BUGBUZZ,
      :HYPERBEAM, :BRAVEBIRD, :FLAREBLITZ, :THUNDER, :CLOSECOMBAT, :SOLARBEAM, :DRACOMETEOR, :STEELBEAM, :TERABLAST,
      :ROAR, :CHARGE, :HAZE, :TOXIC, :SANDTOMB, :SPITE, :GRAVITY, :SMACKDOWN, :GYROBALL, :KNOCKOFF, :BUGBITE,
      :SUPERFANG, :VACUUMWAVE, :LUNGE, :HIGHHORSEPOWER, :ICICLESPEAR, :SCALD, :HEATCRASH, :SOLARBLADE, :UPROAR,
      :FOCUSPUNCH, :WEATHERBALL, :GRASSYGLIDE, :BURNINGJEALOUSY, :FLIPTURN, :DUALWINGBEAT, :POLTERGEIST, :LASHOUT,
      :SCALESHOT, :MISTYEXPLOSION, :PAINSPLIT, :PSYCHUP, :DOUBLEEDGE, :ENDEAVOR, :PETALBLIZZARD, :TEMPERFLARE,
      :WHIRLPOOL, :MUDDYWATER, :SUPERCELLSLAM, :ELECTROWEB, :TRIPLEAXEL, :COACHING, :SLUDGEWAVE, :SCORCHINGSANDS,
      :FEATHERDANCE, :FUTURESIGHT, :EXPANDINGFORCE, :SKITTERSMACK, :METEORBEAM, :THROATCHOP, :BREAKINGSWIPE,
      :METALSOUND, :CURSE, :HARDPRESS, :DRAGONCHEER, :ALLURINGVOICE, :PSYCHICNOISE, :UPPERHAND,
    ],
  }

  CACHE_PATH = "Data/ValidatorCache.dat"
  CACHE_LIFE = 30 * 24 * 60 * 60 # 30 days

  def initialize()
    loadCache
    @moveHash = {}
    $cache.moves.each do |symbol, move|
      if !PBStuff::ANIMATIONDUMMIES.include? symbol
        @moveHash[move.getFullName] = symbol
      end
    end
    @tmtutormoves = []
    (TUTORMOVES + self.getTMList).each do |move|
      @tmtutormoves.push $cache.moves[move].getFullName
    end
    @universaltms = []
    getUniversalTMs().each do |move|
      @universaltms.push $cache.moves[move].getFullName
    end
    @alltmtutormoves = []
    getCompatibleMoveList().each do |move|
      @alltmtutormoves.push $cache.moves[move].getFullName
    end
  end

  def validateMovesets(gen = nil)
    # File.open("definition_file_path(montext.rb)") { |f|
    #   eval(f.read)
    # }
    # @mons = MONHASH

    for _, pkmn in $cache.pkmn
      next if gen != nil && !GENS[gen].include?(pkmn[0].dexnum)

      # puts "Validating " + pkmn[0].name
      i = 0
      while pkmn.hasForm?(i)
        if shouldValidate?(pkmn, i)
          validateForm(pkmn, i)
        end

        i += 1
      end
    end
    saveCache

    # mons = MonDataHash.new()
    # @mons.each { |key, value|
    #   mons[key] = MonWrapper.new(key, value)
    # }
    # monDump(mons, game: GAMEFOLDER)
  end

  def shouldValidate?(formName, formData)
    return false if formData.checkFlag?(:ExcludeDex)
    return false if formName.include?("Aevian")

    return true
  end

  def validateForm(pkmn, i)
    species = fetchSpecies(pkmn[0].dexnum)
    assertName(pkmn[i].name, species.names)
    assertLevelUpMoves(pkmn, i, species)
    assertEggMoves(pkmn, i, species)
    assertCompatibleMoves(pkmn, i, species)
  end

  def assertLevelUpMoves(pkmn, i, species)
    form = pkmn[i]

    i = adjustVarietyIndex(form.name, i)

    return if species.varieties[i].nil? || shouldSkip?(species.varieties[i].pokemon.name)

    actual = []
    form.Moveset.each do |learn|
      actual.push [learn[0], $cache.moves[learn[1]].name]
    end
    actual.sort! { |a, b| 2 * (a[0] <=> b[0]) + (a[1] <=> b[1]) }

    # For possible game values see https://pokeapi.co/api/v2/version-group/?limit=100
    expected = findLevelUpMoves(species.varieties[i].pokemon.name, "ultra-sun-ultra-moon")

    extraActual = []
    (actual - expected).uniq.each do |learn|
      extraActual.push "#{learn[1]} (#{learn[0]})"
    end
    extraExpected = []
    (expected - actual).uniq.each do |learn|
      extraExpected.push "#{learn[1]} (#{learn[0]})"
    end

    if extraActual.length > 0
      log(sprintf(
            "%s form %s - remove level up moves: %s",
            form.name,
            i,
            extraActual.join(", "),
          ))
    end

    if extraExpected.length > 0
      log(sprintf(
            "%s form %s - add level up moves: %s",
            form.name,
            i,
            extraExpected.join(", "),
          ))
    end
  end

  def assertEggMoves(pkmn, i, species)
    form = pkmn[i]

    i = adjustVarietyIndex(form.name, i)

    return if species.varieties[i].nil? || shouldSkip?(species.varieties[i].pokemon.name)

    actual = []
    form.EggMoves.each do |move|
      actual.push $cache.moves[move].name
    end
    actual.sort! { |a, b| a <=> b }

    # For possible game values see https://pokeapi.co/api/v2/version-group/?limit=100
    expected = findEggMoves(species.varieties[i].pokemon.name, "ultra-sun-ultra-moon")

    extraActual = (actual - expected).uniq
    extraExpected = (expected - actual).uniq

    if extraActual.length > 0
      log(sprintf(
            "%s form %s - remove egg moves: %s",
            form.name,
            i,
            extraActual.join(", "),
          ))
    end

    if extraExpected.length > 0
      log(sprintf(
            "%s form %s - add egg moves: %s",
            form.name,
            i,
            extraExpected.join(", "),
          ))
    end
  end

  def shouldSkip?(name)
    return true if name.include?("-gmax")
    return true if name.include?("-mega")
    return true if name.include?("-primal")
    return true if name.include?("-origin")
    return true if name == "floette-eternal"
    return true if name == "greninja-battle-bond"
    return true if name.include?("zygarde-") && name != "zygarde-50"
    return true if name.include?("castform-") # form 0: "castform"
    return true if name.include?("cramorant-") # form 0: "cramorant"
    return true if name.include?("maushold-") && name != "maushold-family-of-four"
    return true if name.include?("dudunsparce-") && name != "dudunsparce-two-segment"
    return true if name.include?("squawkabilly-") && name != "squawkabilly-green-plumage"
    return true if name.include?("tatsugiri-") && name != "tatsugiri-curly"
    return true if name.include?("morpeko-") && name != "morpeko-full-belly"
    return true if name.include?("terapagos-") # form 0: "terapagos"

    return false
  end

  def assertCompatibleMoves(pkmn, i, species)
    form = pkmn[i]

    i = adjustVarietyIndex(form.name, i)

    return if species.varieties[i].nil? || shouldSkip?(species.varieties[i].pokemon.name)

    actual = []
    form.compatiblemoves.each do |move|
      next if Gen < 8 && PBStuff::Gen8Moves.include?(move)
      next if Gen < 9 && PBStuff::Gen9Moves.include?(move)
      next if form.moveexceptions.include?(move)

      actual.push $cache.moves[move].name
    end
    getUniversalTMs().each do |move|
      next if Gen < 8 && PBStuff::Gen8Moves.include?(move)
      next if Gen < 9 && PBStuff::Gen9Moves.include?(move)
      next if form.moveexceptions.include?(move)

      actual.push $cache.moves[move].name
    end
    actual.sort! { |a, b| a <=> b }

    # pokeapi doesn't seem to have Celebrate compatibilities
    ignoredmoves = []
    # Ignore egg moves repeated among compatible
    form.EggMoves.each do |move|
      ignoredmoves.push $cache.moves[move].name
    end
    # Ignore relearner moves repeated among compatible
    form.RelearnerMoves.each do |move|
      ignoredmoves.push $cache.moves[move].name
    end
    # Ignore level up moves repeated among compatible
    form.Moveset.each do |learn|
      ignoredmoves.push $cache.moves[learn[1]].name
    end
    knownmoves = ignoredmoves.intersection(@tmtutormoves) - @universaltms
    # For possible game values see https://pokeapi.co/api/v2/version-group/?limit=100
    expected = findCompatibleMoves(species.varieties[i].pokemon.name, "ultra-sun-ultra-moon", "omega-ruby-alpha-sapphire")

    # Check pre-evolutions if they're from different generation
    preevo = pbGetPreviousForm(pkmn.mon, i)
    if preevo
      unless isSameGen(preevo, [form.species, i])
        expected += findCompatibleMoves(species.evolves_from_species.name, "ultra-sun-ultra-moon", "omega-ruby-alpha-sapphire")
        preevo = pbGetPreviousForm(preevo[0], preevo[1])
        if preevo
          unless isSameGen(preevo, [form.species, i])
            pspecies = fetchSpecies($cache.pkmn[preevo[0], preevo[1]].dexnum)
            expected += findCompatibleMoves(pspecies.name, "ultra-sun-ultra-moon", "omega-ruby-alpha-sapphire")
          end
        end
      end
    end

    extraActual = (actual - expected - ignoredmoves - knownmoves).intersection(@tmtutormoves).uniq
    extraExpected = (expected + knownmoves - actual).uniq
    extraExpected = [] if species.varieties[i].pokemon.name == "mew"

    formname = $cache.pkmn[form.species].forms[i]

    if extraActual.length > 0
      # if @mons[form.species][formname] && @mons[form.species][formname][:compatiblemoves] != nil
      #   @mons[form.species][formname][:compatiblemoves] -= findMoveSymbols(extraActual)
      #   @mons[form.species][formname][:moveexceptions] = [] if @mons[form.species][formname][:moveexceptions].nil?
      #   @mons[form.species][formname][:moveexceptions] += findMoveSymbols(extraActual.intersection(@universaltms))
      # end
      log(sprintf(
            "%s form %s - remove compatible moves: %s",
            form.name,
            i,
            extraActual.join(", "),
          ))
    end

    if extraExpected.length > 0
      # if @mons[form.species][formname] && @mons[form.species][formname][:compatiblemoves] != nil
      #   @mons[form.species][formname][:compatiblemoves] += findMoveSymbols(extraExpected)
      #   unless @mons[form.species][formname][:moveexceptions].nil?
      #     @mons[form.species][formname][:moveexceptions] -= findMoveSymbols(extraExpected.intersection(@universaltms))
      #   end
      # end
      log(sprintf(
            "%s form %s - add compatible moves: %s",
            form.name,
            i,
            extraExpected.join(", "),
          ))
    end
  end

  def findMoveSymbols(moves)
    consistentApostropheHash = {
      "`" => "'",
      "’" => "'"
    }
    symbols = []
    moves.each do |move|
      next if move == "Tera Blast"
      if @moveHash[move].nil?
        log(sprintf(
          "No symbol found for %s",
          move,
        ))
      else
        symbols.push @moveHash[move.gsub(Regexp.union(consistentApostropheHash.keys), consistentApostropheHash)]
      end
    end
    return symbols
  end

  def getGen(dexnum)
    GENS.each do |gen, range|
      return gen if range.include?(dexnum)
    end
  end

  def isSameGen(preevo, evo)
    return false if getGen($cache.pkmn[preevo[0], preevo[1]].dexnum) != getGen($cache.pkmn[evo[0], evo[1]].dexnum)
    return false if isRegional($cache.pkmn[preevo[0]].forms[preevo[1]]) != isRegional($cache.pkmn[evo[0]].forms[evo[1]])

    return true
  end

  def isRegional(formname)
    ["Alolan", "Galarian", "Hisuian", "Paldean"].each do |region|
      return true if formname.include?(region)
    end
    return false
  end

  def findLevelUpMoves(identifier, game)
    moves = []
    pokemon = fetchPokemon(identifier)
    evolutionMoves = []
    pokemon.moves.each do |learn|
      move = fetchMove(learn.move.name)
      learn.version_group_details.each do |group|
        next if group.version_group.name != game
        next if group.move_learn_method.name != "level-up"

        name = eng(move.names)
        moves.push [group.level_learned_at, adjustMoveName(name)]
        evolutionMoves.push name if group.level_learned_at == 0
      end
    end
    moves.sort! { |a, b| 2 * (a[0] <=> b[0]) + (a[1] <=> b[1]) }
    # Remove evolution moved duplicated as level 1 moves
    moves.filter! { |move| move[0] != 1 || !evolutionMoves.include?(move[1]) }
    return adjustLevelUpMoves(identifier, game, moves)
  end

  def findEggMoves(identifier, game)
    moves = []
    pokemon = fetchPokemon(identifier)
    pokemon.moves.each do |learn|
      move = fetchMove(learn.move.name)
      learn.version_group_details.each do |group|
        next if group.version_group.name != game
        next if group.move_learn_method.name != "egg"

        moves.push adjustMoveName(eng(move.names))
      end
    end
    moves.sort! { |a, b| a <=> b }
    moves = adjustEggMoves(identifier, game, moves)
    moves.sort! { |a, b| a <=> b }
    return moves
  end

  def findCompatibleMoves(identifier, *games)
    moves = []
    pokemon = fetchPokemon(identifier)
    pokemon.moves.each do |learn|
      move = fetchMove(learn.move.name)
      learn.version_group_details.each do |group|
        # Headbutt and Rock Climb compatibility is valid from any source.
        # # Hone Claws, avalanche, zap cannon, metronome, retaliate, dynamic punch and vacuum wave are retro TMs in rejuv that use older gen compatibilities
        next if !games.include?(group.version_group.name) && !["headbutt", "rock-climb"].include?(learn.move.name) && !(Rejuv && ["hone-claws", "avalanche", "zap-cannon", "metronome", "sucker-punch", "retaliate", "dynamic-punch", "vacuum-wave"].include?(learn.move.name))
        # Toxic stopped being a universal move in generation 8, so for gen 8+ compatibility lists gen 7 and earlier sources are invalid
        next if Gen >= 8 && learn.move.name == "toxic" && !["sword-shield", "the-isle-of-armor", "the-crown-tundra", "brilliant-diamond-shining-pearl", "scarlet-violet", "the-teal-mask", "the-indigo-disk"].include?(group.version_group.name)
        next if group.move_learn_method.name != "tutor" && group.move_learn_method.name != "machine"

        moves.push adjustMoveName(eng(move.names))
      end
    end
    moves.sort! { |a, b| a <=> b }
    moves = adjustCompatibleMoves(identifier, moves)
    moves.sort! { |a, b| a <=> b }
    if Rejuv
      require "./Scripts/Rejuv/Definitions/compatibilitytext.rb"
      moves = moves + CUSTOMMOVEHASH[identifier]
    end
    return moves
  end

  def fetchSpecies(identifier)
    if @cache[:species][identifier]
      if @cache[:species][identifier][:expires_at] < Time.now
        writeSpecies(identifier)
      end
      return @cache[:species][identifier][:data]
    end

    writeSpecies(identifier)
    return @cache[:species][identifier][:data]
  end

  def writeSpecies(identifier)
    @cache[:species][identifier] = {
      :data => PokeApi.get(pokemon_species: identifier),
      :expires_at => Time.now + CACHE_LIFE,
    }
    @cache_updated = true
  end

  def fetchPokemon(identifier)
    if @cache[:pokemon][identifier]
      if @cache[:pokemon][identifier][:expires_at] < Time.now
        writePokemon(identifier)
      end
      return @cache[:pokemon][identifier][:data]
    end

    writePokemon(identifier)
    return @cache[:pokemon][identifier][:data]
  end

  def writePokemon(identifier)
    @cache[:pokemon][identifier] = {
      :data => PokeApi.get(pokemon: identifier),
      :expires_at => Time.now + CACHE_LIFE,
    }
    @cache_updated = true
  end

  def fetchMove(identifier)
    if @cache[:move][identifier]
      if @cache[:move][identifier][:expires_at] < Time.now
        writeMove(identifier)
      end
      return @cache[:move][identifier][:data]
    end

    writeMove(identifier)
    return @cache[:move][identifier][:data]
  end

  def writeMove(identifier)
    @cache[:move][identifier] = {
      :data => PokeApi.get(move: identifier),
      :expires_at => Time.now + CACHE_LIFE,
    }
    @cache_updated = true
  end

  def assertName(actualName, names)
    name = eng(names).gsub("’", "'").gsub("♀", "").gsub("♂", "")
    if name != actualName
      # log(sprintf("Unexpected name %s, expected %s", actualName, name))
    end
  end

  def eng(names)
    names.each do |name|
      return name.name if name.language.name == "en"
    end
  end

  def getTMList()
    tms = []
    $cache.items.each do |key, item|
      tm = item.checkFlag?(:tm)
      tms.push tm if tm
    end
    return tms
  end

  def getCompatibleMoveList(games = nil)
    games = Array(games) unless games.nil?
    compatibleMoves = []
    if games
      games.each { |game| compatibleMoves += COMPATIBLE_MOVES[game] } # Moves from the specified games
    else
      COMPATIBLE_MOVES.each { |game, moves| compatibleMoves += moves } # Moves from all games
    end
    compatibleMoves.select! { |move| $cache.moves[move] } # Move exists in-game
    compatibleMoves += getTMList() # Handle custom machines
    compatibleMoves += TUTORMOVES # Handle custom tutors
    compatibleMoves.sort!.uniq!
    return compatibleMoves
  end

  def adjustLevelUpMoves(identifier, game, moves)
    # Camerupt's Ember for USUM is incorrectly set to level 5 instead of 8 in pokeapi
    # pokeapi fixed this, keeping it as a syntax example
    # moves[7][0] = 8 if identifier == "camerupt" && game == "ultra-sun-ultra-moon"

    # Deoxys BDSP move data is missing from PokeAPI
    if identifier.include?("deoxys") && game == "brilliant-diamond-shining-pearl"
      moves.push [1, "Leer"]
      moves.push [1, "Wrap"]
      moves.push [7, "Night Shade"]
      # Level 13: Speed Forme gets Double Team, the rest get Teleport
      case identifier
        when "deoxys-speed" then moves.push [13, "Double Team"]
        else moves.push [13, "Teleport"]
      end
      # Level 19: Attack Forme gets Taunt, the rest get Knock Off
      case identifier
        when "deoxys-attack" then moves.push [19, "Taunt"]
        else moves.push [19, "Knock Off"]
      end
      # Level 25: Defense Forme gets Spikes, the rest get Toxic Spikes
      case identifier
        when "deoxys-defense" then moves.push [25, "Spikes"]
        else moves.push [25, "Toxic Spikes"]
      end
      moves.push [31, "Psychic"]
      # Level 37: Attack Forme gets Superpower, Speed Forme gets Swift, the rest get Switcheroo
      case identifier
        when "deoxys-attack" then moves.push [37, "Superpower"]
        when "deoxys-speed" then moves.push [37, "Swift"]
        else moves.push [37, "Switcheroo"]
      end
      moves.push [43, "Psycho Shift"]
      moves.push [49, "Zen Headbutt"]
      # Level 55: Defense Forme gets Iron Defense and Amnesia, Speed Forme gets Agility, the rest get Cosmic Power
      case identifier
        when "deoxys-defense"
          moves.push [55, "Iron Defense"]
          moves.push [55, "Amnesia"]
        when "deoxys-speed" then moves.push [55, "Agility"]
        else moves.push [55, "Cosmic Power"]
      end
      # Level 61: Attack Forme gets Zap Cannon, the rest get Recover
      case identifier
        when "deoxys-attack" then moves.push [61, "Zap Cannon"]
        else moves.push [61, "Recover"]
      end
      moves.push [67, "Psycho Boost"]
      # Level 73: Defense Forme gets Counter and Mirror Coat, Speed Forme gets Extreme Speed, the rest get Hyper Beam
      case identifier
        when "deoxys-defense"
          moves.push [73, "Counter"]
          moves.push [73, "Mirror Coat"]
        when "deoxys-speed" then moves.push [73, "Extreme Speed"]
        else moves.push [73, "Hyper Beam"]
      end
    end

    return moves
  end

  def adjustEggMoves(identifier, game, moves)
    # Pichu has Volt Tackle as extra egg move
    moves.push "Volt Tackle" if identifier == "pichu"
    # Munchlax got Power-Up Punch as egg move in USUM, this is missing in pokeapi
    moves.push "Power-Up Punch" if identifier == "munchlax" && game == "ultra-sun-ultra-moon"
    # Fomantis got Superpower as egg move in SV, this is missing in pokeapi
    moves.push "Superpower" if identifier == "fomantis" && game == "scarlet-violet"
    # PokeAPI seemingly labeled some pokemon's SV reminder moves as egg moves
    if game == "scarlet-violet"
      case identifier
        when "entei"
          moves.delete "Extreme Speed"
          moves.delete "Sacred Fire"
        when "suicune"
          moves.delete "Extreme Speed"
          moves.delete "Sheer Cold"
        when "lugia"
          moves.delete "Dragon Rush"
        when "virizion"
          moves.delete "Take Down"
        when "scream-tail", "brute-bonnet", "flutter-mane", "slither-wing", "sandy-shocks"
          moves.delete "Sunny Day"
        when "iron-bundle", "iron-hands", "iron-moth", "iron-thorns", "iron-valiant"
          moves.delete "Electric Terrain"
        when "roaring-moon"
          moves.delete "Breaking Swipe"
          moves.delete "Jaw Lock"
          moves.delete "Scale Shot"
          moves.delete "Sunny Day"
        when "ogerpon", "ogerpon-wellspring-mask", "ogerpon-hearthflame-mask", "ogerpon-cornerstone-mask"
          moves.delete "Counter"
          moves.delete "Double Kick"
          moves.delete "Horn Leech"
          moves.delete "Retaliate"
        when "gouging-fire"
          moves.delete "Ancient Power"
          moves.delete "Double Kick"
          moves.delete "Noble Roar"
        when "raging-bolt"
          moves.delete "Ancient Power"
        when "pecharunt"
          moves.delete "Defense Curl"
          moves.delete "Mean Look"
          moves.delete "Rollout"
      end
    end
    return moves
  end

  def adjustCompatibleMoves(identifier, moves)
    # PokeApi mistakenly includes the hisuian form exclusive TM/Tutor Moves for the base form of the hisuian starters
    if ["decidueye"].include?(identifier)
      moves.delete "Scary Face"
      moves.delete "Rock Tomb"
      moves.delete "Brick Break"
      moves.delete "Bulk Up"
      moves.delete "Taunt"
      moves.delete "Aura Sphere"
      moves.delete "Reversal"
      moves.delete "Focus Blast"
      moves.delete "Close Combat"
      moves.delete "Focus Punch"
      moves.delete "Coaching"
      moves.delete "Upper Hand"
    end
    if ["typhlosion"].include?(identifier)
      moves.delete "Confuse Ray"
      moves.delete "Hex"
      moves.delete "Night Shade"
      moves.delete "Calm Mind"
      moves.delete "Spite"
      moves.delete "Poltergeist"
    end
    if ["samurott"].include?(identifier)
      moves.delete "Snarl"
      moves.delete "Dark Pulse"
      moves.delete "Lash Out"
      moves.delete "Throat Chop"
    end
    # Event moves
    if ["pikachu", "raichu", "raichu-alola"].include?(identifier)
      moves.push "Surf"
      moves.push "Fly"
      moves.push "Happy Hour"
      moves.push "Celebrate"
    end
    if ["pichu", "pikachu", "raichu", "raichu-alola"].include?(identifier)
      moves.push "Endeavor"
    end
    if ["charmander", "charmeleon", "charizard"].include?(identifier)
      moves.push "Acrobatics"
      moves.push "Block"
      moves.push "False Swipe"
      moves.push "Celebrate"
    end
    if ["bulbasaur", "ivysaur", "venusaur", "squirtle", "wartortle", "blastoise"].include?(identifier)
      moves.push "Block"
      moves.push "False Swipe"
      moves.push "Celebrate"
    end
    if ["lickitung", "lickylicky"].include?(identifier)
      moves.push "Heal Bell"
    end
    if ["gengar"].include?(identifier)
      moves.push "Sludge Wave"
    end
    if ["zoroark"].include?(identifier)
      moves.push "Sludge Bomb"
    end
    if ["arceus"].include?(identifier)
      moves.push "Blast Burn"
      moves.push "Hydro Cannon"
    end
    if ["meowth", "persian", "magikarp", "gyarados", "delibird", "jirachi", "greninja", "inkay", "malamar", "munchlax", "snorlax",
      "rockruff", "lycanroc-midday", "lycanroc-midnight", "lycanroc-dusk", "zoroark-hisui"].include?(identifier)
      moves.push "Happy Hour"
    end
    if ["magikarp", "gyarados", "eevee", "vaporeon", "jolteon", "flareon", "espeon", "umbreon", "glaceon", "leafeon", "sylveon",
      "ho-oh", "rayquaza", "vulpix-alola", "ninetales-alola", "exeggutor-alola", "chansey", "blissey", "aerodactly", "munchlax", "snorlax",
      "shaymin-land", "shaymin-sky", "victini", "meloetta-aria", "meloetta-pirouette", "comfey", "sinistea", "polteageist", "milcery", "alcremie",
      "flabebe", "floette", "florges", "steenee", "tsareena", "pawmi", "pawmo", "pawmot", "tandemaus", "maushold", "charcadet", "armarouge", "ceruledge",
      "toedscool", "toedscruel", "tatsugiri-stretchy"].include?(identifier)
      moves.push "Celebrate"
    end
    # Thundurus Therian can't learn Smart Strike by TM but apparently it's a bug.
    if ["thundurus-therian"].include?(identifier)
      moves.push "Smart Strike"
    end
    # Deoxys BDSP move data is missing from PokeAPI
    if identifier.include?("deoxys")
      moves.push "Avalanche"
    end

    return moves
  end

  # Adjust form indices that are different in other databases than in our engine
  # 'species' is pokedex number when called by movesetData
  def adjustVarietyIndex(species, index)
    return 2 if ["Kyurem", 646].include?(species) && index == 1 # White
    return 1 if ["Kyurem", 646].include?(species) && index == 2 # Black

    return 2 if ["Slowbro", 80].include?(species) && index == 1 # Mega
    return 1 if ["Slowbro", 80].include?(species) && index == 2 # Galarian

    return 3 if ["Greninja", 658].include?(species) && index == 1 # Mega
    return 1 if ["Greninja", 658].include?(species) && index == 2 # Battle Bond

    return 3 if ["Pumpkaboo", 710].include?(species) && index == 0 # Jumbo
    return 3 if ["Gourgeist", 711].include?(species) && index == 0 # Jumbo

    return index
  end

  def adjustMoveName(move)
    move = move.gsub("’", "'")
    return move
  end

  def log(message)
    puts message + "\n"
    File.write('movesets.txt', message + "\n", mode: 'a+')
  end

  def loadCache
    if File.exist?(CACHE_PATH)
      @cache = File.open(CACHE_PATH, "rb") { |f| Marshal.load(f) }
    else
      @cache = {
        :species => {},
        :pokemon => {},
        :move => {},
      }
    end
    @cache_updated = false
  end

  def saveCache
    if @cache_updated
      File.open(CACHE_PATH, "wb") { |f| Marshal.dump(@cache, f) }
      @cache_updated = false
    end
  end
end

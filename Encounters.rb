module EncounterTypes
  Land         = 0
  Cave         = 1
  Water        = 2
  RockSmash    = 3
  OldRod       = 4
  GoodRod      = 5
  SuperRod     = 6
  Headbutt     = 7
  LandMorning  = 8
  LandDay      = 9
  LandNight    = 10
  BugContest   = 11
  Lava         = 12
  EncTypeOrder = [
    :Land,
    :Cave,
    :Water,
    :RockSmash,
    :OldRod,
    :GoodRod,
    :SuperRod,
    :Headbutt,
    :LandMorning,
    :LandDay,
    :LandNight,
    :BugContest,
    :Lava,
  ]
  EnctypeChances = [
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [50, 25, 15, 7, 3],
    [50, 25, 15, 7, 3],
    [70, 30],
    [60, 20, 20],
    [40, 35, 15, 7, 3],
    [30, 25, 20, 10, 5, 5, 4, 1],
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [50, 25, 15, 7, 3],
  ]
end

class PokemonEncounters
  ENCOUNTER_RAND_MAX = 4000 # 250 * 16
  def initialize
    @enctypes = []
    @density = nil
  end

  def stepcount
    return @stepcount
  end

  def clearStepCount
    @stepcount = 0
  end

  def hasEncounter?(enc)
    return false if @density == nil || enc < 0

    return @enctypes[enc] ? true : false
  end

  def isCave?
    return false if @density == nil

    return @enctypes[EncounterTypes::Cave] ? true : false
  end

  def isGrass?
    return false if @density == nil

    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight] ||
            @enctypes[EncounterTypes::BugContest]) ? true : false
  end

  def isRegularGrass?
    return false if @density == nil

    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight]) ? true : false
  end

  def isWater?
    return false if @density == nil

    return @enctypes[EncounterTypes::Water] ? true : false
  end

  def pbEncounterType
    if $PokemonGlobal&.surfing
      return EncounterTypes::Water
    elsif $PokemonGlobal&.lavasurfing
      return EncounterTypes::Lava
    elsif self.isCave?
      return EncounterTypes::Cave
    elsif self.isGrass?
      time = pbGetTimeNow
      enctype = EncounterTypes::Land
      enctype = EncounterTypes::LandNight if self.hasEncounter?(EncounterTypes::LandNight) && PBDayNight.isNight?(time)
      enctype = EncounterTypes::LandDay if self.hasEncounter?(EncounterTypes::LandDay) && PBDayNight.isDay?(time)
      enctype = EncounterTypes::LandMorning if self.hasEncounter?(EncounterTypes::LandMorning) && PBDayNight.isMorning?(time)
      return enctype
    end

    return -1
  end

  def isEncounterPossibleHere?
    currentTag = pbGetTerrainTag($game_player)
    if currentTag == PBTerrain::Waterfall || currentTag == PBTerrain::WaterfallCrest
      return false
    elsif $PokemonGlobal&.surfing
      return true
    elsif $PokemonGlobal&.lavasurfing
      return true
    elsif currentTag == PBTerrain::Ice
      return false
    elsif self.isCave?
      return true
    elsif self.isGrass?
      return pbIsGrassTag?(currentTag)
    end

    return false
  end

  EncTypeToEncRate = pbHashForwardizer({
    :landrate => [:Land, :Headbutt, :LandMorning, :LandDay, :LandNight, :BugContest],
    :waterrate => [:Water, :OldRod, :GoodRod, :SuperRod],
    :caverate => [:Cave, :RockSmash],
    :lavarate => [:Lava],
  })

  def setup(mapID)
    @stepcount = 0
    @density = nil
    @enctypes = []

    mapdata = $cache.mapdata[mapID]
    return unless mapdata

    @density = []
    for enctype in EncounterTypes::EncTypeOrder
      encrate = EncTypeToEncRate[enctype]
      rate = mapdata.send(encrate) || 0
      rate = 0 if $game_switches[:WildBattles]
      @density.push(rate)

      @enctypes.push(mapdata.send(enctype))
    end
  end

  def pbDetermineForm(form)
    return 0 if form.nil?
    return form if form.is_a?(Integer)

    form = form.to_a if form.is_a?(Range)
    return form.sample if form.is_a?(Array)

    if form == :Time
      return 2 if PBDayNight.isDusk?(pbGetTimeNow)
      return 1 if PBDayNight.isNight?(pbGetTimeNow)
      return 0
    end
    if form == :Season
      return (pbGetTimeNow.month - 1) % 4
    end
    if form == :Cloak
      field = determineFieldLayers[-1]
      return 2 if $cache.FEData[field].burmyCloak == :TRASHCLOAK
      return 0 if $cache.FEData[field].burmyCloak == :PLANTCLOAK
      return 1 if $cache.FEData[field].burmyCloak == :SANDYCLOAK
      return 1 if [:Sand, :Rock, :Cave].include?(pbGetEnvironment) # Sandy Cloak
      return 2 if $cache.mapdata[$game_map.map_id].Outdoor # Trash Cloak
      return 0 # Plant Cloak
    end
    raise "unknown form #{form.inspect}"
  end

  def pbEncounteredPokemon(enctype, tries = 1)
    if enctype < 0 || enctype > EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @enctypes[enctype] == nil

    encounters = []
    chances    = []
    @enctypes[enctype].each do |key, x|
      x.each { |y|
        encounters.push([key, y[1], y[2]])
        chances.push(y[0])
      }
    end

    encounters, chances = pbModifyEncounters(encounters, chances)

    chancetotal = chances.sum
    rnd = 0
    tries.times do
      r = rand(chancetotal)
      rnd = r if rnd < r
    end

    chosenpkmn = 0
    chance = 0
    for i in 0...chances.length
      chance += chances[i]
      if rnd < chance
        chosenpkmn = i
        break
      end
    end
    encounter = encounters[chosenpkmn]
    return nil if !encounter

    level = pbGetEncounterLevel(encounter)
    species = encounter[0]
    if species.is_a?(Array)
      return [species[0], species[1], level]
    end
    return [species, nil, level]
  end

  def pbModifyEncounters(encounters, chances)
    # Check if specific encounters should be forced due to Magnetic Lure/Mirror Lure/certain abilities
    if pbShouldFilterKnownPokemon?
      newencs, newchances = pbFilterKnownPokemon(encounters, chances)
    elsif pbShouldFilterOtherPokemon?
      newencs, newchances = pbFilterOtherPokemon(encounters, chances)
    else
      newencs, newchances = pbFilterTypes(encounters, chances)
    end
    if newencs.length > 0
      encounters, chances = newencs, newchances
    end
    return encounters, chances
  end

  def pbFilterTypes(encounters, chances)
    return [], [] if rand(2) == 0 # 50% chance for activation

    user = fieldAbilityUser
    return [], [] if user.egg?

    type = case user.ability
      when :STATIC, :LIGHTNINGROD then :ELECTRIC
      when :MAGNETPULL then :STEEL
      when :FLASHFIRE then :FIRE
      when :HARVEST then :GRASS
      when :STORMDRAIN then :WATER
      else nil
    end
    return [], [] if type.nil?

    filterproc = proc { |species, forms|
      eligibleforms = Array(forms).filter { |form|
        data = $cache.pkmn[species, form]
        type == data.Type1 || type == data.Type2
      }
      next eligibleforms
    }
    return pbApplyFiltering(encounters, chances, filterproc)
  end

  def pbFilterOtherPokemon(encounters, chances)
    filterproc = proc { |species, forms|
      if species != $Trainer.party[0].species
        eligibleforms = []
      else
        # Try to match form as well, if possible
        eligibleforms = Array(forms).filter { |form| form == $Trainer.party[0].form }
        eligibleforms = Array(forms) if eligibleforms.empty?
      end
      next eligibleforms
    }
    return pbApplyFiltering(encounters, chances, filterproc)
  end

  def pbFilterKnownPokemon(encounters, chances)
    filterproc = proc { |species, forms|
      eligibleforms = Array(forms).filter { |form| !$Trainer.pokedex.meaningful_owned?(species, form) }
      next eligibleforms
    }
    return pbApplyFiltering(encounters, chances, filterproc)
  end

  def pbApplyFiltering(encounters, chances, filterproc)
    newencs, newchances = [], []
    for i in 0...encounters.length
      # First, filter out the mons that have no chance of spawning, just in case...
      enc = encounters[i]
      next if !enc || !chances[i] || chances[i] <= 0

      # Then filter out all mons who don't meet the criteria
      species = encounters[i][0]
      if species.is_a?(Array)
        form = species[1].is_a?(Symbol) ? pbDetermineForm(species[1]) : species[1]
        species = species[0]
      else
        form = 0
      end
      eligibleforms = filterproc.call(species, form) # Conditions for filtering are in the proc
      next if eligibleforms.empty?

      newenc = [[species, eligibleforms], enc[1], enc[2]] # Modify the encounter to generate only the forms we want out of the possible ones
      newencs.push(newenc)
      newchances.push(chances[i])
    end
    return newencs, newchances
  end

  def pbShouldFilterOtherPokemon?
    # Should also check for $Trainer.party[0].hp > 0 by logic, but then
    #  it wouldn't be in line with the other overworld party leader checks
    return false if $Trainer.party[0].egg?
    return true if $Trainer.party[0].item == :MIRRORLURE

    return false
  end

  def pbShouldFilterKnownPokemon?
    # Should also check for $Trainer.party[0].hp > 0 by logic, but then
    #  it wouldn't be in line with the other overworld party leader checks
    return false if $Trainer.party[0].egg?
    return true if $Trainer.party[0].item == :MAGNETICLURE

    return false
  end

  def pbGetEncounterLevel(encounter)
    # UPDATE 11/19/2013
    # pressure, hustle and vital spirit will now have a 150% chance of
    # finding higher leveled pokemon in encounters
    user = fieldAbilityUser
    if !user.egg? && [:PRESSURE, :HUSTLE, :VITALSPIRIT].include?(user.ability) && rand(2) == 0
      # increase the lower bound to half way in-between lower and upper
      encounter[1] += (encounter[2] - encounter[1]) / 2
    end
    # end of update
    level = encounter[1] + rand(1 + encounter[2] - encounter[1])
    return level
  end

  def pbCanEncounter?(encounter)
    return false if $game_system.encounter_disabled
    return false if !encounter || !$Trainer
    return false if $DEBUG && Input.press?(Input::CTRL)
    return true if defined?(pbPokeRadarOnShakingGrass) && pbPokeRadarOnShakingGrass
    return false if $PokemonGlobal.repel > 0 && $Trainer.ablePokemonCount > 0 && encounter[2] < $Trainer.ablePokemonParty[0].level
    return true
  end

  def pbGenerateEncounter(enctype)
    return nil if $game_switches[:No_Encounters]

    if enctype < 0 || enctype > EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @density == nil
    return nil if @density[enctype] == 0 || !@density[enctype]
    return nil if @enctypes[enctype] == nil

    @stepcount += 1

    return nil if isEncounterGenerationBlocked?(enctype)

    encount = $game_switches[:FirstUse] ? $game_variables[:EncounterRateModifier] : 1
    encount *= @density[enctype] * 16

    if $PokemonGlobal.bicycle
      encount *= 0.8
    end
    if $PokemonMap.blackFluteUsed
      encount /= 2
    end
    if $PokemonMap.whiteFluteUsed
      encount *= 1.5
    end
    if $Trainer.party.length > 0
      user = fieldAbilityUser
      unless user.isEgg?
        case user.ability
          when :STENCH, :WHITESMOKE, :QUICKFEET, :INFILTRATOR then encount /= 2
          when :SNOWCLOAK then encount /= 2 if [:Snow, :Hail, :Blizzard].include?($game_screen.weather_type)
          when :SANDVEIL then encount /= 2 if $game_screen.weather_type == :Sandstorm
          when :SWARM then encount *= 1.5 # custom effect
          when :ILLUMINATE, :ARENATRAP, :NOGUARD then encount *= 2
          else
            # Item doesn't stack with ability
            encount *= 2.0 / 3 if [:CLEANSETAG, :PUREINCENSE].include?(user.item)
        end
      end
    end
    encount = modifyEncounterGenerationRate(encount, enctype)
    return nil if rand(ENCOUNTER_RAND_MAX) >= encount

    encpoke = pbEncounteredPokemon(enctype)
    if $Trainer.party.length > 0
      user = fieldAbilityUser
      if !user.isEgg? && encpoke &&
         [:INTIMIDATE, :KEENEYE].include?(user.ability) &&
         encpoke[2] <= user.level - 5 && rand(2) == 0
        encpoke = nil
      end
    end
    return encpoke
  end
end

# To be overwritten where needed
def isEncounterGenerationBlocked?(enctype)
  return true if @stepcount <= 10 && $game_variables[:EncounterRateModifier] <= 1
  return false
end

# To be overwritten where needed
def modifyEncounterGenerationRate(encount, enctype)
  return encount
end

def getRelevantEncounterMaps(regions)
  maps = []
  for mapid in 1...$cache.mapdata.length
    next if $cache.mapinfos[mapid].nil? || $cache.mapdata[mapid].nil?
    next if $cache.mapinfos[mapid].name.start_with?("REMOVED")
    next unless $PokemonGlobal.visitedMaps[mapid]
    next if $cache.mapdata[mapid].Switches&.any? { |switch, value| $game_switches[switch] != value }
    next if $cache.mapdata[mapid].Variables&.any? { |variable, values| !values.include?($game_variables[variable]) }

    mappos = $cache.mapdata[mapid].MapPosition
    mapregion = mappos ? mappos[0] : 0
    next unless regions.include?(mapregion)

    maps.push(mapid)
  end
  return maps
end

class Window_EncounterDetails < Window_CommandPokemonWhiteArrow
  attr_accessor :elaborations # Currently unused

  def update
    # Disables scrolling with Q/W because those are used to change Pokemon in Pokedex
    super(false)

    if Input.trigger?(Input::C)
      elaboration = @elaborations[@index]
      Kernel.pbMessage(elaboration) if elaboration
    end
  end

  def tts_cur_item(*args)
    super
    text = @commands[self.index]
    ttsEncTypeIconsInText(text)
  end
end

def encounterDetailsWindow(encounters, viewport, x, y, width, height, selectedmap: nil)
  # Can't change the 'encounters' array in-place
  commands = encounters.uniq { |mapid, mapname, type, chance, note|
    [mapname, type, chance, note]
  }

  commands.sort_by! { |mapid, mapname, type, chance, note|
    enctypeorder = [:LandMorning, :LandDay, :LandNight, :Land]
    [mapname, enctypeorder.index(type) || -1, chance]
  }

  elaborations = commands.map{ |_a, _b, _c, _d, note| note }
  defaultIndex = selectedmap.nil? ? 0 : (commands.find_index{ |mapid, mapname, type, chance, note| mapid == selectedmap } || 0)

  maxdigits = commands.map{ |_a, _b, _c, chance, _d| chance }.max.to_s.length
  commands.map! { |mapid, mapname, type, chance, note|
    string = encTypeIcon(type, mapid) + "\u2007" + chance.to_s.rjust(maxdigits, "\u2007") + "%" + "\u2007" + mapname
    string += "<r>" + "<icon=commonTabStar>" if note
    next string
  }

  window = Window_EncounterDetails.newWithSize(commands, x, y, width, height, viewport, defaultIndex: defaultIndex)
  window.elaborations = elaborations

  return window
end

def encTypeIcon(enctype, mapid)
  name = enctype.to_s
  name += "Underwater" if $cache.mapdata[mapid].BattleBack == "Underwater" && [:Land, :LandMorning, :LandDay, :LandNight, :Cave].include?(enctype)
  return "<icon=Encounters/#{name}>"
end

def ttsEncTypeIconsInText(text)
  icons = text.scan(/<icon=Encounters\/([^>]+)>/)
  names = icons.flatten.map! { |icon| {
    "Land"           => _INTL("Grass"),
    "LandMorning"    => _INTL("Grass Morning"),
    "LandDay"        => _INTL("Grass Day"),
    "LandNight"      => _INTL("Grass Night"),
    "LandUnderwater" => _INTL("Grass Underwater"),
    "Cave"           => _INTL("Open Area"),
    "CaveUnderwater" => _INTL("Open Area Underwater"),
    "RockSmash"      => _INTL("Rock Smash"),
    "Headbutt"       => _INTL("Headbutt"),
    "OldRod"         => _INTL("Old Rod"),
    "GoodRod"        => _INTL("Good Rod"),
    "SuperRod"       => _INTL("Super Rod"),
    "Water"          => _INTL("Water Surface"),
    "Lava"           => _INTL("Lava Surface"),
    "Overworld"      => _INTL("Visible in Overworld"),
    "Honey"          => _INTL("Attracted to Honey"),
  }[icon] }
  tts(names.join(" "))
end

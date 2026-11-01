class Cache_Game
  attr_reader :pkmn
  attr_reader :moves
  attr_reader :move2anim
  attr_reader :items
  attr_reader :trainers
  attr_reader :trainertypes
  attr_reader :FEData
  attr_reader :FENotes
  attr_reader :types
  attr_reader :abil
  attr_reader :mapinfos
  attr_reader :mapdata
  # attr_reader :regions
  # attr_reader :encounters
  attr_reader :metadata
  attr_reader :bosses
  attr_reader :connections
  attr_reader :town_map
  attr_reader :animations
  attr_reader :animSheets
  attr_reader :RXsystem
  attr_reader :RXevents
  attr_reader :RXtilesets
  attr_reader :RXanimations
  attr_reader :cachedmaps
  attr_reader :natures
  # attr_reader :shadows
  attr_reader :marts
  attr_reader :btmons
  attr_reader :bttrainers
  attr_reader :directory
  attr_reader :pokedexes
  attr_reader :currencies
  attr_reader :passwords

  # Caching functions
  def cacheDex
    if Reborn && Gen >= 9
      compileMonsGen9(@directory) if !fileExists?(@directory + "/mons_modern.dat")
      @pkmn = load_data(@directory + "/mons_modern.dat")
    else
      compileMons(@directory) if !fileExists?(@directory + "/mons.dat")
      @pkmn = load_data(@directory + "/mons.dat")
    end
  end

  def cacheMoves
    if Reborn && Gen >= 9
      compileMovesGen9(@directory) if !fileExists?(@directory + "/moves_modern.dat")
      @moves = load_data(@directory + "/moves_modern.dat")
    else
      compileMoves(@directory) if !fileExists?(@directory + "/moves.dat")
      @moves = load_data(@directory + "/moves.dat")
    end
  end

  def cacheItems
    if Reborn && Gen >= 9
      compileItemsGen9(@directory) if !fileExists?(@directory + "/items_modern.dat")
      @items = load_data(@directory + "/items_modern.dat")
    else
      compileItems(@directory) if !fileExists?(@directory + "/items.dat")
      @items = load_data(@directory + "/items.dat")
    end
  end

  def cacheTrainerTypes
    compileTrainerTypes(@directory) if !fileExists?(@directory + "/ttypes.dat")
    @trainertypes = load_data(@directory + "/ttypes.dat")
  end

  def cacheTrainers
    compileTrainers(@directory) if !fileExists?(@directory + "/trainers.dat")
    @trainers = load_data(@directory + "/trainers.dat")
  end

  def cacheAbilities
    if Reborn && Gen >= 9
      compileAbilitiesGen9(@directory) if !fileExists?(@directory + "/abil_modern.dat")
      @abil = load_data(@directory + "/abil_modern.dat")
    else
      compileAbilities(@directory) if !fileExists?(@directory + "/abil.dat")
      @abil = load_data(@directory + "/abil.dat")
    end
  end

  def cacheTypes
    compileTypes(@directory) if !fileExists?(@directory + "/types.dat")
    @types = load_data(@directory + "/types.dat")
  end

  def cacheFields
    compileFields(@directory) if !fileExists?(@directory + "/fields.dat")
    @FEData = load_data(@directory + "/fields.dat")
    if Reborn && Gen >= 8
      @FEData[:CORROSIVEMIST].naturePower = :CORROSIVEGAS
    end
  end

  def cacheFieldNotes
    compileFieldNotes(@directory) if !fileExists?(@directory + "/fieldnotes.dat")
    @FENotes = load_data(@directory + "/fieldnotes.dat")
  end

  def cacheBosses
    compileBosses(@directory) if !fileExists?(@directory + "/bossdata.dat")
    @bosses = load_data(@directory + "/bossdata.dat")
  end

  def cacheMapInfos
    @mapinfos = load_data(@directory + "/MapInfos.rxdata")
  end

  def cacheMapData
    @mapdata = MapDataCache.new(load_data(@directory + "/maps.dat"))
  end

  def cacheTownMap
    @town_map = load_data(@directory + "/townmap.dat")
  end

  def cacheNatures
    compileNatures(@directory) if !fileExists?(@directory + "/natures.dat")
    @natures = load_data(@directory + "/natures.dat")
  end

  def cacheConnections
    @connections = load_data(@directory + "/connections.dat")
  end

  def cacheMetadata
    @metadata = load_data(@directory + "/meta.dat")
    # @regions            = load_data(@directory + "/regionals.dat") if !@regions
    # MessageTypes.loadMessageFile(@directory + "/Messages.dat")
  end

  def cacheMarts
    compileMartData(@directory) if !fileExists?(@directory + "/marts.dat")
    @marts = load_data(@directory + "/marts.dat")
  end

  def cacheBTMons
    compileBTMons(@directory) if !fileExists?(@directory + "/btmons.dat")
    @btmons = load_data(@directory + "/btmons.dat")
  end

  def cacheBTTrainers
    compileBTTrainers(@directory) if !fileExists?(@directory + "/bttrainers.dat")
    @bttrainers = load_data(@directory + "/bttrainers.dat")
  end

  def cachePokedexes
    compilePokedexes(@directory) if !fileExists?(@directory + "/pokedexes.dat")
    @pokedexes = load_data(@directory + "/pokedexes.dat")
  end

  def cacheCurrencies
    compileCurrencies(@directory) if !fileExists?(@directory + "/currencies.dat")
    @currencies = load_data(@directory + "/currencies.dat")
  end

  def cachePasswords
    compilePasswords(@directory) if !fileExists?(@directory + "/passwords.dat")
    @passwords = load_data(@directory + "/passwords.dat")
  end

  def initialize(directory = "Data")
    @directory = directory
    # Load immediately because IntroEventScene needs $cache.RXsystem.title_bgm
    @RXsystem = load_data(@directory + "/System.rxdata") if !@RXsystem
  end

  # Only data that are necessary to show the main menu
  def loadMainMenuData
    cacheDex
    cacheMetadata
    cacheMapInfos
  end

  def loadRuntimeData
    cacheMoves
    cacheItems
    cacheTrainerTypes
    cacheTrainers
    cacheAbilities
    cacheTypes
    cacheFields
    cacheFieldNotes
    cacheBosses
    cacheMapData
    cacheTownMap
    cacheNatures
    cacheConnections
    cacheAnims
    cacheTilesets
    cacheMarts
    cacheBTMons unless Desolation
    cacheBTTrainers unless Desolation
    cachePokedexes
    cacheCurrencies
    cachePasswords
    cacheAnimSheets if Rejuv
    @RXanimations = load_data(@directory + "/Animations.rxdata") if !@RXanimations
    @RXevents = load_data(@directory + "/CommonEvents.rxdata") if !@RXevents
  end

  def cacheTilesets
    @RXtilesets = load_data(@directory + "/Tilesets.rxdata")
  end

  def cacheAnims
    @move2anim = load_data(@directory + "/move2anim.dat")
    @animations = load_data(@directory + "/battleanims.dat")
  end

  def cacheAnimSheets
    compileAnimSheets(@directory) if !fileExists?(@directory + "/animSheets.dat")
    @animSheets = load_data(@directory + "/animSheets.dat")
  end

  def animations=(value)
    @animations = value
  end

  def map_load(mapid)
    @cachedmaps = [] if !@cachedmaps
    if !@cachedmaps[mapid]
      puts "loading map " + mapid.to_s
      @cachedmaps[mapid] = load_data(sprintf(@directory + "/Map%03d.rxdata", mapid))
    end
    return @cachedmaps[mapid]
  end

  # Exists to simplify trainer cache overrides for modders
  # Returns the trainer team hash corresponding to the given 'teamid' array from trainertext
  def getTrainerTeam(teamid)
    trainername, trainertype, team_id_number = *teamid
    return @trainers[trainertype][trainername].find{ |team| team[0] == team_id_number }[1]
  end
end

# Little override to return blank metadata if the map doesn't have any.
class MapDataCache < Array
  def [](index)
    data = self.fetch(index) if index < self.length
    if data.nil?
      puts "Missing metadata for map " + index.to_s
      self[index] = MapMetadata.new(index, nil, [])
      data = self.fetch(index)
    end
    return data
  end
end

# For modders (you're welcome)
# Can be used either to modify an existing form or to add a new one
# baseform is used only when adding a new form
# If you need to edit a flag, supply the `flags` attribute.
def addFormDataAtRuntime(species, formname, datahash, baseform: 0)
  isnewform = !$cache.pkmn[species].forms.values.include?(formname)

  $cache.pkmn[species].forms.store($cache.pkmn[species].forms.length, formname) if isnewform

  baseformname = isnewform ? $cache.pkmn[species].forms[baseform] : formname
  newdata = deep_copy($cache.pkmn[species].pokemonData[baseformname])
  for key, value in datahash
    if key == :flags
      newdata.instance_variable_get(:@flags).merge!(value)
    else
      key = "@#{key}".to_sym # :BaseStats -> :@BaseStats
      newdata.instance_variable_set(key, value)
    end
  end
  $cache.pkmn[species].pokemonData.store(formname, newdata)
end

def deep_copy(obj)
  return Marshal.load(Marshal.dump(obj))
end

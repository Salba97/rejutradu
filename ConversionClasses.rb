class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :volume
  attr_accessor :sevolume
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :screensize
  attr_accessor :language
  attr_accessor :border
  attr_accessor :backup
  attr_accessor :maxBackup
  attr_accessor :field_effects_highlights
  attr_accessor :remember_commands
  attr_accessor :photosensitive
  attr_accessor :autorunning
  attr_accessor :bike_and_surf_music
  attr_accessor :streamermode
  attr_accessor :audiotype
  attr_accessor :unrealTimeDiverge
  attr_accessor :unrealTimeClock
  attr_accessor :unrealTimeTimeScale

  # Now deprecated and unused
  attr_accessor :bagsorttype
  attr_accessor :font
  attr_accessor :autosave

  def language
    return !@language ? 0 : @language
  end

  def textskin
    return !@textskin ? 0 : @textskin
  end

  def border
    return !@border ? 0 : @border
  end

  def photosensitive
    return !@photosensitive ? 0 : @photosensitive
  end

  def remember_commands
    return !@remember_commands ? 0 : @remember_commands
  end

  def field_effects_highlights
    return !@field_effects_highlights ? 0 : @field_effects_highlights
  end

  def tilemap; return MAPVIEWMODE; end

  def unrealTimeDiverge
    return !@unrealTimeDiverge ? 1 : @unrealTimeDiverge
  end

  def unrealTimeClock
    return !@unrealTimeClock ? 1 : @unrealTimeClock
  end

  def unrealTimeTimeScale
    return !@unrealTimeTimeScale ? 30 : @unrealTimeTimeScale
  end

  def autorunning
    return !@autorunning ? 0 : @autorunning
  end

  def bike_and_surf_music
    return !@bike_and_surf_music ? 0 : @bike_and_surf_music
  end

  def streamermode
    return !@streamermode ? 0 : @streamermode
  end

  def audiotype
    return !@audiotype ? 0 : @audiotype
  end
end

class PBMove
  attr_reader(:id) # just to make sure we can convert the move.
end

class PokeBattle_Trainer
  attr_accessor :seen
  attr_accessor :owned
  attr_accessor :shadowcaught
  attr_accessor :formseen
end

class PBPokemon # keeping for conversion.
  def initialize(species, item, nature, moves, ev, form, ability)
    @species = species
    @item = item
    @nature = nature
    @moves = moves
    @ev = ev
    @form = form
    @ability = ability
  end

  def self.fromInspected(str)
    insp = str.gsub(/^\s+/, "").gsub(/\s+$/, "")
    pieces = insp.split(/\s*;\s*/)
    species = :BULBASAUR
    species = pieces[0].to_sym if pieces[0]
    item = nil
    item = pieces[1].to_sym if pieces[1]
    nature = pieces[2].to_sym
    ev = pieces[3].split(/\s*,\s*/)
    evvalue = 0
    for i in 0...6
      next if !ev[i] || ev[i] == ""

      evupcase = ev[i].upcase
      evvalue |= 0x01 if evupcase == "HP"
      evvalue |= 0x02 if evupcase == "ATK"
      evvalue |= 0x04 if evupcase == "DEF"
      evvalue |= 0x08 if evupcase == "SA"
      evvalue |= 0x10 if evupcase == "SD"
      evvalue |= 0x20 if evupcase == "SPD"
    end
    evcount = 0
    for i in 0...6
      evcount += 1 if ((evvalue & (1 << i)) != 0)
    end
    evperstat = (evcount == 0) ? 0 : 510 / evcount
    evs = []
    for i in 0...6
      evs[i] = ((evvalue & (1 << i)) != 0) ? evperstat : 0
    end
    splmoves = pieces[4].split(/\s*,\s*/)
    moves = []
    splmoves.each { |move|
      if move == ""
        moves.push(nil)
        next
      end
      moves.push(move.to_sym)
    }
    form = pieces[5].to_i

    pkmn = $cache.pkmn[species, form]
    abillist = []
    pkmn.Abilities.each { |abil| abillist.push(abil) }
    abillist.push(pkmn.HiddenAbility) unless pkmn.HiddenAbility.nil?
    ability = abillist[pieces[6].to_i]
    return PBPokemon.new(species, item, nature, moves, evs, form, ability)
  end

  def to_s
    ret = "{ "
    ret += "species: #{@species.inspect}, "
    ret += "item: #{@item.inspect}, "
    ret += "nature: #{@nature.inspect}, " if @nature != nil
    ret += "moves: #{@moves.inspect}, "
    ret += "ev: #{@ev.inspect}, " if !@ev.empty?
    ret += "form: #{@form}, " if @form != 0
    ret += "ability: #{@ability.inspect} "
    ret += "},\n"
    return ret
  end

  def to_s_no_species
    ret = "{ "
    ret += "item: #{@item.inspect}, "
    ret += "nature: #{@nature.inspect}, " if @nature != nil
    ret += "moves: #{@moves.inspect}, "
    ret += "ev: #{@ev.inspect}, " if !@ev.empty?
    ret += "form: #{@form}, " if @form != 0
    ret += "ability: #{@ability.inspect} "
    ret += "},\n"
    return ret
  end

  def species
    return @species
  end

  def speciesinspect
    return "#{@species.inspect}"
  end

  def inspect; self.to_s; end
end

class Game_Screen
  attr_reader :weather_duration
  attr_reader :weather_max_target
end

TPSPECIES   = 0
TPLEVEL     = 1
TPITEM      = 2
TPMOVE1     = 3
TPMOVE2     = 4
TPMOVE3     = 5
TPMOVE4     = 6
TPABILITY   = 7
TPGENDER    = 8
TPFORM      = 9
TPSHINY     = 10
TPNATURE    = 11
TPIV        = 12
TPHAPPINESS = 13
TPNAME      = 14
TPSHADOW    = 15
TPBALL      = 16
TPHIDDENPOWER = 17
TPHPEV        = 18
TPATKEV       = 19
TPDEFEV       = 20
TPSPEEV       = 21
TPSPAEV       = 22
TPSPDEV       = 23
TPDEFAULTS = [0, 10, 0, 0, 0, 0, 0, nil, nil, 0, false, :HARDY, 10, 70, nil, false, 0, 17, 0, 0, 0, 0, 0, 0]

MetadataOutdoor             = 1
MetadataShowArea            = 2
MetadataBicycle             = 3
MetadataBicycleAlways       = 4
MetadataHealingSpot         = 5
MetadataWeather             = 6
MetadataMapPosition         = 7
MetadataDiveMap             = 8
MetadataDarkMap             = 9
MetadataSafariMap           = 10
MetadataSnapEdges           = 11
MetadataDungeon             = 12
MetadataBattleBack          = 13
MetadataMapWildBattleBGM    = 14
MetadataMapTrainerBattleBGM = 15
MetadataMapWildVictoryBGM    = 16
MetadataMapTrainerVictoryBGM = 17
MetadataMapSize             = 18

ITEMID        = 0
ITEMNAME      = 1
ITEMPOCKET    = 2
ITEMPRICE     = 3
ITEMDESC      = 4
ITEMUSE       = 5
ITEMBATTLEUSE = 6
ITEMTYPE      = 7
ITEMMACHINE   = 8

class ControlConfig; end

class DataObject
  attr_reader :flags

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end
end

# List of attributes that are not inherited under any circumstance
EXCLUSIVE_ATTRS = [
  :baseForm, :form, :MegaEvolutions, :genderDifferences, :reward,
]

EXCLUSIVE_FLAGS = [
  :regionalDex, :ExcludeDex,
  :WildItemCommon, :WildItemUncommon, :WildItemRare,
  :Pulse, :Rift, :Karma, :Perfection,
  :PrimalForm, :TerastalForm,
]

class MonWrapper
  attr_reader :flags
  attr_reader :mon
  attr_reader :pokemonData
  attr_reader :forms

  def initialize(monsym, data)
    @flags = {}
    @mon = monsym

    @pokemonData = {}
    @forms = {}
    data.each { |key, value|
      next if key.is_a?(Symbol)

      @pokemonData[key] = MonData.new(monsym, key, value, self)
      @forms[@forms.length] = key
    }
    data.delete_if { |key, value| @forms.values.include?(key) }

    data.each { |key, value| @flags.store(key, value) }
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end

  def hasForm?(form)
    return true if form.nil?

    form = @forms[form] if form.is_a?(Numeric) && @forms.has_key?(form)
    return @pokemonData.has_key?(form)
  end

  def [](form, gender = nil)
    formnum = -1
    if form.is_a?(Numeric)
      formnum = form
      form = @forms[form]
    end
    ret = @pokemonData[form]
    if !ret
      ret = @pokemonData.values[0]
      puts "Form #{@mon} #{formnum > -1 ? "#{formnum}:" : ""}#{form.inspect} does not exist!"
    end
    ret = ret[gender] if gender
    return ret
  end

  def export
    exporttext = "  #{@mon.inspect} => {\n"
    for form in 0...@forms.length
      formname = @forms[form]
      exporttext += "    \"#{@forms[form]}\" => {\n"
      exporttext += @pokemonData[formname].export
      exporttext += "    },\n\n"
    end
    exporttext = exporttext[0...-1]
    @flags.each { |k, v| exporttext += "    #{k.inspect} => #{v.inspect},\n" }
    exporttext += "  },\n\n"
    return exporttext
  end
end

class MonDataHash < Hash
  def [](*args)
    species = args.delete_at(0)
    wrapper = self.fetch(species)
    if args.length == 0
      return wrapper
    end

    gender = args.find { |v| v.is_a?(Symbol) } # Expects :M, :F, :N. Can expand.
    form = (args - [gender])[0]
    return wrapper[form, gender]
  end
end

class MonData < DataObject
  attr_reader :species
  attr_reader :form
  attr_reader :name
  attr_reader :dexnum
  attr_reader :Type1
  attr_reader :Type2
  attr_reader :BaseStats
  attr_reader :EVs
  attr_reader :Abilities
  attr_reader :HiddenAbility
  attr_reader :GrowthRate
  attr_reader :GenderRatio
  attr_reader :BaseEXP
  attr_reader :CatchRate
  attr_reader :Happiness
  attr_reader :EggSteps
  attr_reader :EggMoves
  attr_reader :Moveset
  attr_reader :compatiblemoves
  attr_reader :moveexceptions
  attr_reader :shadowmoves
  attr_reader :Color
  attr_reader :EggGroups
  attr_reader :Height
  attr_reader :Weight
  attr_reader :kind
  attr_reader :dexentry
  attr_reader :BattlerPlayerX
  attr_reader :BattlerPlayerY
  attr_reader :BattlerEnemyX
  attr_reader :BattlerEnemyY
  attr_reader :BattlerShadowSize
  attr_reader :BattlerShadowX
  attr_reader :preevo
  attr_reader :evolutions
  attr_reader :MegaEvolutions
  attr_reader :RelearnerMoves
  attr_reader :baseForm
  attr_reader :reward
  attr_reader :shape
  attr_reader :genderDifferences

  def initialize(species, form, data, wrapper)
    @species = species
    @form = form
    @flags = {}
    @baseForm = 0
    data.each do |key, value|
      case key
        when :name              then @name              = value
        when :dexnum            then @dexnum            = value
        when :Type1             then @Type1             = value
        when :Type2             then @Type2             = value
        when :BaseStats         then @BaseStats         = value
        when :EVs               then @EVs               = value
        when :Abilities         then @Abilities         = value
        when :HiddenAbility     then @HiddenAbility     = value
        when :GrowthRate        then @GrowthRate        = value
        when :GenderRatio       then @GenderRatio       = value
        when :BaseEXP           then @BaseEXP           = value
        when :CatchRate         then @CatchRate         = value
        when :Happiness         then @Happiness         = value
        when :EggSteps          then @EggSteps          = value
        when :EggMoves          then @EggMoves          = value
        when :Moveset           then @Moveset           = value
        when :compatiblemoves   then @compatiblemoves   = value
        when :moveexceptions    then @moveexceptions    = value
        when :shadowmoves       then @shadowmoves       = value
        when :Color             then @Color             = value
        when :EggGroups         then @EggGroups         = value
        when :Height            then @Height            = value
        when :Weight            then @Weight            = value
        when :kind              then @kind              = value
        when :dexentry          then @dexentry          = value
        when :BattlerPlayerX    then @BattlerPlayerX    = value
        when :BattlerPlayerY    then @BattlerPlayerY    = value
        when :BattlerEnemyX     then @BattlerEnemyX     = value
        when :BattlerEnemyY     then @BattlerEnemyY     = value
        when :BattlerShadowSize then @BattlerShadowSize = value
        when :BattlerShadowX    then @BattlerShadowX    = value
        when :preevo            then @preevo            = value
        when :evolutions        then @evolutions        = value
        when :MegaEvolutions    then @MegaEvolutions    = value
        when :RelearnerMoves    then @RelearnerMoves    = value
        when :baseForm          then @baseForm          = value
        when :reward            then @reward            = value
        when :shape             then @shape             = value
        when :genderDifferences then @genderDifferences = value
        else @flags[key] = value
      end
    end
    @wrapper = wrapper

    if @genderDifferences
      data.delete(:genderDifferences)
      @genderDifferences.transform_values! { |v|
        next MonData.new(@species, @form, data.merge(v), @wrapper)
      }
    end
  end

  def [](value)
    return self if !value || self.genderDifferences.empty?
    puts "Unknown gender value #{value}. Expecting :M, :F, :N, or #{self.genderDifferences.keys.inspect}." if !(self.genderDifferences.key?(value) || [:M, :F, :N].include?(value))
    ret = self.genderDifferences.fetch(value, self)
    return ret
  end

  def name
    return @name || @species
  end

  def dexnum
    return @dexnum || -1
  end

  def Type1
    return @Type1 || :QMARKS
  end

  def Type2
    # Fixes secondary type being removed for Galarian Farfetch'd and Mega Aggron
    type = @Type2 || nil
    return nil if type == self.Type1

    return type
  end

  def BaseStats
    return @BaseStats || [48, 72, 48, 72, 48, 48]
  end

  def EVs
    return @EVs || Array.new(6, 0)
  end

  def Abilities
    return @Abilities || [:ILLUMINATE]
  end

  def HiddenAbility
    # Fixes Galarian Articuno, Zapdos, Moltres and Dusk Lycanroc to not inherit hidden ability from the base form
    ability = @HiddenAbility || nil
    return nil if self.Abilities.include?(ability)

    return ability
  end

  def GrowthRate
    return @GrowthRate || :MediumFast
  end

  def GenderRatio
    return @GenderRatio || :FemHalf
  end

  def BaseEXP
    return @BaseEXP || 118
  end

  def CatchRate
    return @CatchRate || 225
  end

  def Happiness
    return @Happiness || 70
  end

  def EggSteps
    return @EggSteps || 10455
  end

  def EggMoves
    return @EggMoves || []
  end

  def Moveset
    return @Moveset || [1, :HIDDENPOWER]
  end

  def compatiblemoves
    return @compatiblemoves || []
  end

  def moveexceptions
    return @moveexceptions || getUniversalTMs()
  end

  def shadowmoves
    return @shadowmoves || nil
  end

  def Color
    return @Color || "Black"
  end

  def EggGroups
    return @EggGroups || :Undiscovered
  end

  def Height
    return @Height || 5
  end

  def Weight
    return @Weight || 50
  end

  def kind
    return @kind || "Unknown"
  end

  def dexentry
    return @dexentry || "Dex entry not defined."
  end

  def BattlerPlayerX
    return @BattlerPlayerX || 0
  end

  def BattlerPlayerY
    return @BattlerPlayerY || 0
  end

  def BattlerEnemyX
    return @BattlerEnemyX || 0
  end

  def BattlerEnemyY
    return @BattlerEnemyY || 0
  end

  def BattlerShadowSize
    return @BattlerShadowSize || 0
  end

  def BattlerShadowX
    return @BattlerShadowX || 0
  end

  def preevo
    return @preevo || nil
  end

  def evolutions
    return @evolutions || nil
  end

  def MegaEvolutions
    return @MegaEvolutions || {}
  end

  def RelearnerMoves
    return @RelearnerMoves || []
  end

  def reward
    return @reward || {}
  end

  def shape
    return @shape || nil
  end

  def genderDifferences
    return @genderDifferences || {}
  end

  def genderDifferenceAttrs
    ret = {}
    return ret if self.genderDifferences.empty?

    self.genderDifferences.each { |gender, genderData|
      (genderData.instance_variables - EXCLUSIVE_ATTRS - [:@wrapper]).each { |atr|
        m = atr.to_s[1..].to_sym
        if self.send(m) != genderData.send(m)
          ret[gender] ||= []
          ret[gender].push(atr)
        end
      }
    }

    return ret
  end

  def checkFlag?(flag, default = false, baseCheck = false)
    v = @flags.fetch(flag, default)
    v = @wrapper[@baseForm].checkFlag?(flag, default, true) if v.nil? && !baseCheck
    v = default if v.nil?
    return v
  end

  def getAbilities
    v = []
    self.Abilities.each { |abil| v.push(abil) }
    v.push(self.HiddenAbility) if self.HiddenAbility
    return v
  end

  def getWildItems
    items = {}
    items[:common] = @flags[:WildItemCommon] if @flags[:WildItemCommon]
    items[:uncommon] = @flags[:WildItemUncommon] if @flags[:WildItemUncommon]
    items[:rare] = @flags[:WildItemRare] if @flags[:WildItemRare]
    if items[:common] && items[:common] == items[:uncommon] && items[:uncommon] == items[:rare]
      item = items[:common]
      items.clear
      items[:always] = item
    end
    return items
  end
end

class MoveData < DataObject
  attr_reader :move
  attr_reader :name
  attr_reader :function
  attr_reader :type
  attr_reader :category
  attr_reader :basedamage
  attr_reader :accuracy
  attr_reader :maxpp
  attr_reader :target
  attr_reader :desc
  attr_reader :priority
  attr_reader :zmovedata

  def initialize(movesym, data)
    @flags = {}
    @move = movesym
    data.each do |key, value|
      case key
        when :name then           @name            = value
        when :function then       @function        = value
        when :type then           @type            = value
        when :category then       @category        = value
        when :basedamage then     @basedamage      = value
        when :accuracy then       @accuracy        = value
        when :maxpp then          @maxpp           = value
        when :target then         @target          = value
        when :desc then           @desc            = value
        when :priority then       @priority        = value ? value : 0
        when :zmovedata then      @zmovedata       = ZMoveData.new(value)
        else @flags[key] = value
      end
    end
  end

  def getFullName
    return self.checkFlag?(:longname, nil) || @name
  end

  def export
    output = "#{@move.inspect} => {\n"
    output += "    :name => #{@name.inspect},\n"
    output += sprintf("    :function => 0x%03X,\n", @function)
    output += "    :type => #{@type.inspect},\n"
    output += "    :category => #{@category.inspect},\n"
    output += "    :basedamage => #{@basedamage},\n"
    output += "    :accuracy => #{@accuracy},\n"
    output += "    :maxpp => #{@maxpp},\n"
    output += "    :target => #{@target.inspect},\n"
    output += "    :priority => #{@priority},\n" if @priority && @priority != 0
    @flags.each { |key, value| output += "    #{key.inspect} => #{value.inspect},\n" }
    output += "},\n"
    return output
  end
end

class ZMoveData < DataObject
  attr_reader :basemove
  attr_reader :type
  attr_reader :species
  attr_reader :intercept

  def initialize(data)
    @flags = {}
    data.each do |key, value|
      case key
      when :basemove then       @basemove        = value
      when :type then           @type            = value
      when :species then        @species         = value
      when :intercept then      @intercept       = value
      else @flags[key] = value
      end
    end
  end

  def isCompatible?(species, form)
    @species.each do |value|
      return true if value == species
      return true if value == [species, form]
    end
    return false
  end
end

class ItemData < DataObject
  attr_reader :item
  attr_reader :name
  attr_reader :shortname
  attr_reader :unit
  attr_reader :plural
  attr_reader :desc
  attr_reader :price
  attr_reader :generatedPlural
  attr_reader :zmove
  attr_reader :berry
  attr_reader :medicine

  def initialize(itemsym, data)
    @flags = {}
    @item = itemsym
    data.each do |key, value|
      case key
        when :name then         @name         = value
        when :shortname then    @shortname    = value
        when :unit then         @unit         = value
        when :plural then       @plural       = value
        when :desc then         @desc         = value
        when :price then        @price        = value
        when :zcrystal then     @zmove        = value
        when :berry then        @berry        = BerryData.new(itemsym, value)
        when :medicine then     @medicine     = MedicineData.new(itemsym, value)
        else @flags[key] = value
      end
    end

    unless @plural
      @generatedPlural = true
      # Plural should always be based on unit if unit exists, otherwise based on name
      # So if it's not defined, we generate it by pluralizing first word of unit if unit exists, otherwise by pluralizing name
      # Eg, pair of Choice Specs becomes pairs of Choice Specs, Choice Band becomes Choice Bands
      phrase = @unit ? @unit.split.first : @name # Phrase to pluralize
      case true
        when phrase[-1] == "y" && !phrase[-2].match(/[aeiou]/) then plural = phrase.chop + "ies"
        when phrase[-1] == "s" then plural = phrase
        else plural = phrase + "s"
      end
      @plural = @unit ? plural + " " + @unit.split.drop(1).join(" ") : plural
      # Because of the values generated here, the text extract for translation will have a plural for each item, regardless of whether it's defined in itemtext or not
    end
  end
end

class BerryData < DataObject
  attr_reader :berry
  attr_reader :naturaltype
  attr_reader :naturalpower
  attr_reader :flavors
  attr_reader :resisttype
  attr_reader :pinch
  attr_reader :time
  attr_reader :yield

  def initialize(itemsym, data)
    @flags = {}
    @berry = itemsym
    data.each do |key, value|
      case key
      when :naturaltype then  @naturaltype  = value
      when :naturalpower then @naturalpower = value
      when :flavors then      @flavors      = value
      when :resist then       @resisttype   = value
      when :pinch then        @pinch        = value
      when :time then         @time         = value
      when :yield then        @yield        = value
      else @flags[key] = value
      end
    end
  end
end

class AbilityData < DataObject
  attr_reader :ability
  attr_reader :name
  attr_reader :desc
  attr_reader :fullName
  attr_reader :fullDesc

  def initialize(abilsym, data)
    @flags = {}
    @ability  = abilsym
    data.each do |key, value|
      case key
        when :name then         @name         = value
        when :desc then         @desc         = value
        when :fullName then     @fullName     = value
        when :fullDesc then     @fullDesc     = value
        else @flags[key] = value
      end
    end
    @fullName = @name if @fullName.nil?
    @fullDesc = @desc if @fullDesc.nil?
  end
end

class MedicineData < DataObject
  attr_reader :item
  attr_reader :hp
  attr_reader :status
  attr_reader :revive
  attr_reader :xitem
  attr_reader :happiness

  def initialize(itemsym, data)
    @flags = {}
    @item = itemsym
    data.each do |key, value|
      case key
        when :hp then        @hp        = value
        when :status then    @status    = value
        when :revive then    @revive    = value
        when :xitem then     @xitem     = value
        when :happiness then @happiness = value
        else @flags[key] = value
      end
    end
  end
end

class MapMetadata < DataObject
  # metadata
  attr_reader :mapid
  attr_reader :HealingSpot
  attr_reader :MapPosition
  attr_reader :Outdoor
  attr_reader :ShowArea
  attr_reader :Bicycle
  attr_reader :NoDigging
  attr_reader :Weather
  attr_reader :DiveMap
  attr_reader :SurfaceMap
  attr_reader :DarkMap
  attr_reader :SafariMap
  attr_reader :SnapEdges
  attr_reader :BattleBack
  attr_reader :WildBattleBGM
  attr_reader :TrainerBattleBGM
  attr_reader :WildVictoryBGM
  attr_reader :TrainerVictoryBGM
  attr_reader :MapSize
  attr_reader :Switches
  attr_reader :Variables
  attr_reader :AltMapName
  # music
  attr_reader :AltAutoBGM
  # encounters
  attr_reader :landrate
  attr_reader :caverate
  attr_reader :waterrate
  attr_reader :lavarate
  attr_reader :OverworldEncs
  attr_reader :EncounterTypes
  attr_reader :Land
  attr_reader :Cave
  attr_reader :Water
  attr_reader :RockSmash
  attr_reader :OldRod
  attr_reader :GoodRod
  attr_reader :SuperRod
  attr_reader :Headbutt
  attr_reader :LandMorning
  attr_reader :LandDay
  attr_reader :LandNight
  attr_reader :BugContest
  attr_reader :Lava

  def initialize(key, encounters, metadata)
    @mapid = key
    @flags = {}
    metadata.each do |key, value|
      case key
        when :Outdoor then            @Outdoor            = value ? true : false
        when :ShowArea then           @ShowArea           = value ? true : false
        when :Bicycle then            @Bicycle            = value ? true : false
        when :NoDigging then          @NoDigging          = value ? true : false
        when :Weather then            @Weather            = value
        when :DiveMap then            @DiveMap            = value
        when :SurfaceMap then         @SurfaceMap         = value
        when :DarkMap then            @DarkMap            = value ? true : false
        when :SafariMap then          @SafariMap          = value ? true : false
        when :SnapEdges then          @SnapEdges          = value ? true : false
        when :BattleBack then         @BattleBack         = value
        when :HealingSpot then        @HealingSpot        = value
        when :MapPosition then        @MapPosition        = value
        when :WildBattleBGM then      @WildBattleBGM      = value
        when :TrainerBattleBGM then   @TrainerBattleBGM   = value
        when :WildVictoryBGM then     @WildVictoryBGM     = value
        when :TrainerVictoryBGM then  @TrainerVictoryBGM  = value
        when :MapSize then            @MapSize            = value ? true : false
        when :Switches then           @Switches           = value
        when :Variables then          @Variables          = value
        when :AltMapName then         @AltMapName         = value
        when :AltAutoBGM then         @AltAutoBGM         = value
        else @flags[key] = value
      end
    end
    encounters = {} if !encounters
    # rates
    @landrate    = encounters.delete(:landrate)
    @caverate    = encounters.delete(:caverate)
    @waterrate   = encounters.delete(:waterrate)
    @lavarate    = encounters.delete(:lavarate)
    # overworld encounter data
    @OverworldEncs = encounters.delete(:Overworld)
    # normal wild encounter data
    @EncounterTypes = encounters.keys
    encounters.each { |type, encounters|
      self.instance_variable_set("@#{type}".to_sym, encounters)
    }
  end

  def syncMapData(region, point, flyData)
    @MapPosition = [region, point[0], point[1]]
    @HealingSpot = flyData
  end

  def getEncounterData
    encdata = []
    # Handle normal wild encounters
    @EncounterTypes.each { |type|
      encounters = self.send(type)
      weightstotal = encounters.map { |encounter, array|
        array.map{ |subarray| subarray[0] }.sum # subarray[1] and subarray[2] = minlevel and maxlevel
      }.sum
      encounters.each { |encounter, array|
        encSpecies, encForm = encounter
        weightsthis = array.map{ |subarray| subarray[0] }.sum # subarray[1] and subarray[2] = minlevel and maxlevel
        chance = weightsthis * 100 / weightstotal
        encdata.push([encSpecies, encForm, type, chance, nil])
      }
    }
    # Handle overworld encounters
    if self.OverworldEncs
      self.OverworldEncs.each { |symbol, hash|
        next if hash[:switches]&.any? { |switch, value| $game_switches[switch] != value }
        next if hash[:variables]&.any? { |variable, values| !values.include?($game_variables[variable]) }

        encSpecies, encForm = hash[:species]
        type = hash[:type] || :Overworld
        chance = hash[:chance] || 100
        note = hash[:note] ? pbGetMessageFromHash(:EncounterNotes, hash[:note]) : nil # Currently unused
        encdata.push([encSpecies, encForm, type, chance, note])
      }
    end
    return encdata
  end

  def getEncounterDataSpecific(species, form)
    form = $cache.pkmn[species].forms.invert[form] if form.is_a?(String)
    encdata = getEncounterData
    encdata.filter! { |encSpecies, encForm, type, chance, note|
      next false unless encSpecies == species
      encForm = 0 if encForm.nil?
      next false unless form.nil? || encForm == form || ((encForm.is_a?(Range) || encForm.is_a?(Array)) && encForm.include?(form)) || encForm.is_a?(Symbol)
      # encForm can be a Symbol like :Cloak (Burmy/Wormadam), :Season (Deerling/Sawsbuck) or :Time (Lycanroc); at least currently this means all forms are available on that map
      next true
    }
    encdata.map! { |encSpecies, encForm, type, chance, note| [type, chance, note] }
    return encdata
  end
end

class PlayerData < DataObject
  attr_reader :id
  attr_reader :tclass
  attr_reader :walk
  attr_reader :run
  attr_reader :bike
  attr_reader :surf
  attr_reader :dive
  attr_reader :fishing
  attr_reader :surffish
  attr_reader :ride

  def initialize(key, data)
    @id = key
    @tclass     = data[:tclass]
    @walk       = data[:walk]
    @run        = data[:run]
    @bike       = data[:bike]
    @surf       = data[:surf]
    @dive       = data[:dive]
    @fishing    = data[:fishing]
    @surffish   = data[:surffish]
    @ride       = data[:ride]
  end
end

class TypeData
  attr_reader :type
  attr_reader :name
  attr_reader :weak
  attr_reader :resist
  attr_reader :immune
  attr_reader :specialtype

  def initialize(typesym, data)
    @type = typesym
    @name = data.fetch(:name, "")
    @weak = data.fetch(:weaknesses, [])
    @resist = data.fetch(:resistances, [])
    @immune = data.fetch(:immunities, [])
    @specialtype = data.fetch(:specialtype, false)
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end

  def weak?(type)
    return @weak.include?(type)
  end

  def specialtype?(type)
    return @specialtype
  end

  def resists?(type)
    return @resist.include?(type)
  end

  def immune?(type)
    return @immune.include?(type)
  end
end

class TrainerData < DataObject
  attr_reader :ttype
  attr_reader :title
  attr_reader :skill
  attr_reader :moneymult
  attr_reader :battleBGM
  attr_reader :winBGM
  attr_reader :sprite
  attr_reader :flags
  attr_reader :ball

  def initialize(ttypesym, data)
    @ttype = ttypesym
    @flags = {}
    data.each do |key, value|
      case key
        when :title     then @title = value
        when :skill     then @skill      = value
        when :moneymult then @moneymult  = value
        when :battleBGM then @battleBGM  = value
        when :winBGM    then @winBGM     = value
        when :sprite    then @sprite = value
        when :ball      then @ball = value
        else @flags[key] = value
      end
    end
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end
end

class FEData
  attr_accessor :name
  attr_accessor :fieldAppSwitch
  attr_accessor :message
  attr_accessor :graphic
  attr_accessor :secretPower
  attr_accessor :naturePower
  attr_accessor :mimicry
  attr_accessor :burmyCloak
  attr_accessor :seeddata
  attr_accessor :fieldtypedata
  attr_accessor :fieldmovedata
  attr_accessor :movemessagelist
  attr_accessor :typemessagelist
  attr_accessor :changemessagelist
  attr_accessor :statusBuffs
  attr_accessor :statusNerfs
  attr_accessor :fieldchangeconditions
  # Overlay stuff
  attr_accessor :overlay # bool if field has overlay data defined
  attr_accessor :overlaymovedata
  attr_accessor :overlaytypedata
  attr_accessor :overlayStatusBuffs
  attr_accessor :overlayStatusNerfs
  attr_accessor :overlaymovemessagelist
  attr_accessor :overlaytypemessagelist

  def initialize
    @name = nil
    @message = nil
    @graphic = "IndoorA"
    @secretPower = "TRIATTACK"
    @naturePower = :TRIATTACK
    @mimicry = :NORMAL
    @burmyCloak = nil
    @fieldmovedata = {}
    @fieldtypedata = {}
    @seeddata = {}
    @movemessagelist = {}
    @typemessagelist = {}
    @changemessagelist = {}
    @statusBuffs = []
    @statusNerfs = []
    # Overlay stuff
    @overlay = false
    @overlaymovedata = {}
    @overlaytypedata = {}
    @overlayStatusBuffs = []
    @overlayStatusNerfs = []
    @overlaymovemessagelist = {}
    @overlaytypemessagelist = {}
  end
end

class BossData < DataObject
  attr_reader :mon
  attr_reader :name
  attr_reader :barGraphic
  attr_reader :entryText
  attr_reader :inspectText
  attr_reader :immunities
  attr_reader :shieldCount
  attr_reader :capturable
  attr_reader :canrun
  attr_reader :onBreakEffects
  attr_reader :delayRegister
  attr_reader :onEntryEffects
  attr_reader :moninfo
  attr_reader :sosDetails
  attr_reader :chargeAttack
  attr_reader :randomSetChanges
  attr_reader :doublebattle

  def initialize(monsym, data)
    @flags = {}
    @mon = monsym
    data.each do |key, value|
      case key
        when :name            then @name            = value
        when :immunities      then @immunities      = value
        when :barGraphic      then @barGraphic      = value
        when :entryText       then @entryText       = value
        when :inspectText     then @inspectText     = value
        when :shieldCount     then @shieldCount     = value
        when :doublebattle    then @doublebattle    = value
        when :capturable      then @capturable      = value
        when :canrun          then @canrun          = value
        when :moninfo         then @moninfo         = value
        when :onBreakEffects  then @onBreakEffects  = value
        when :delayedactions  then @delayRegister   = value
        when :onEntryEffects  then @onEntryEffects  = value
        when :sosDetails      then @sosDetails      = value
        when :chargeAttack      then @chargeAttack = value
        when :randomSetChanges  then @randomSetChanges = value
        else @flags[key] = value
      end
    end
  end
end

class NatureData
  attr_accessor :name
  attr_accessor :nature
  attr_accessor :incStat
  attr_accessor :decStat
  attr_accessor :like
  attr_accessor :dislike

  def initialize(naturesym, data)
    @flags = {}
    @nature = naturesym
    data.each { |key, value|
      case key
        when :name      then  @name     = value
        when :incStat   then  @incStat  = value
        when :decStat   then  @decStat  = value
        when :like      then  @like     = value
        when :dislike   then  @dislike  = value
      end
    }
  end
end

class TownMapData < DataObject
  attr_reader :name
  attr_reader :pos
  attr_reader :poi
  attr_reader :flyData
  attr_reader :region

  def initialize(pos, data, region)
    @flags = {}
    @pos = pos
    @region = region
    data.each { |key, value|
      case key
        when :name    then  @name     = value
        when :poi     then  @poi      = value
        when :flyData then  @flyData  = value
        else @flags[key] = value
      end
    }
  end
end

class BTPokemon < DataObject
  attr_accessor :species
  attr_accessor :item
  attr_accessor :nature
  attr_accessor :moves
  attr_accessor :ev
  attr_accessor :form
  attr_accessor :ability
  attr_accessor :hptype
  attr_accessor :gender

  def initialize(data)
    @species  = data[:species]  ? data[:species] : :BULBASAUR
    @item     = data[:item]     ? data[:item] : nil
    @nature   = data[:nature]   ? data[:nature] : :HARDY
    @moves    = data[:moves]    ? data[:moves] : nil
    @ev       = data[:ev]       ? data[:ev] : nil
    @form     = data[:form]     ? data[:form] : 0
    @ability  = data[:ability]  ? data[:ability] : nil
    @hptype   = data[:hptype]   ? data[:hptype] : nil
    @gender   = data[:gender]   ? data[:gender] : nil
    @flags    = {}
    data.each { |key, value|
      var = "@" + key.to_s
      if !self.instance_variables.include?(var.to_sym)
        @flags.store(key, value)
      end
    }
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end
end

class BTTrainerData < DataObject
  attr_accessor :name
  attr_accessor :tclass
  attr_accessor :introSpeech
  attr_accessor :winSpeech
  attr_accessor :loseSpeech
  attr_accessor :monIndexes

  def initialize(data)
    @name         = data[:name]
    @tclass       = data[:tclass]
    @introSpeech  = data[:introSpeech]
    @winSpeech    = data[:winSpeech]
    @loseSpeech   = data[:loseSpeech]
    @monIndexes   = data[:monIndexes]
    @flags        = {}
    data.each { |key, value|
      var = "@" + key.to_s
      if !self.instance_variables.include?(var.to_sym)
        @flags.store(key, value)
      end
    }
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end
end

class MartData < DataObject
  attr_reader :Messages
  attr_reader :Inventory
  attr_reader :allowSell
  attr_reader :hasPicture
  attr_reader :clampBottom
  attr_reader :background
  attr_reader :mart

  def initialize(mart, data)
    @Messages = {}
    @allowSell = false
    @hasPicture = false
    @clampBottom = false
    @mart = mart
    @flags = {}
    data.each do |key, value|
      case key
        when :Messages  then @Messages  = value
        when :Inventory then @Inventory = value
        when :allowSell then @allowSell = value
        when :hasPicture then @hasPicture = value
        when :clampBottom then @clampBottom = value
        when :background then @background = value
        else @flags[key] = value
      end
    end
    # Default to a single-option shop
    if @Inventory.is_a?(Array)
      @Inventory = { "Buy" => @Inventory }
    end
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end
end

class PokedexData < DataObject
  attr_reader :symbol
  attr_reader :name
  attr_reader :default
  def initialize(dexsym, data)
    @flags = {}
    @symbol = dexsym
    data.each { |key, value|
      case key
        when :name    then @name = value
        when :default then @default = value
        else @flags[key] = value
      end
    }
  end
end

class CurrencyData < DataObject
  attr_reader :symbol
  attr_reader :type
  def initialize(sym, data)
    @flags = {}
    @symbol = sym
    @type = sym
    @display = "@f@ @s@"
    data.each { |key, value|
      case key
        when :name          then @name = value
        when :plural        then @plural = value
        when :display       then @display = value
        when :shorthand     then @shorthand = value
        when :shortplural   then @shortplural = value
        when :shortdisplay  then @shortdisplay = value
        when :desc          then @desc = value
        when :type          then @type = value
        else @flags[key] = value
      end
    }
    if @type == :Item && $cache.items.key?(@symbol)
      @name = getItemName(@symbol) if !@name
      @plural = getItemName(@symbol, plural: true) if !@plural
      @desc = getItemDescription(@symbol) if !@desc
    end
  end

  def getName(plural)
    return pbGetMessageFromHash(:CurrencyPlurals, @plural) if plural && @plural
    return pbGetMessageFromHash(:CurrencyNames, @name)
  end

  def getShorthand(plural)
    return self.getName(plural) if !@shorthand
    return pbGetMessageFromHash(:CurrencyShorthandPlurals, @shortplural) if plural && @shortplural
    return pbGetMessageFromHash(:CurrencyShorthand, @shorthand)
  end

  def getDescription
    return pbGetMessageFromHash(:CurrencyDescriptions, @desc)
  end

  def format(amount, shorthand = true, commas = false)
    plural = amount != 1
    str = shorthand ? self.getShorthand(plural) : self.getName(plural)
    display = shorthand && @shortdisplay ? @shortdisplay : @display
    display = display.gsub("@s@", str)
    display = display.gsub("@f@", commas ? pbCommaNumber(amount) : amount.to_s)
    return display
  end
end

class BulkPasswordData < DataObject
  attr_reader :name
  attr_reader :category
  attr_reader :password
  attr_reader :aliases
  attr_reader :description
  attr_reader :components

  def initialize(pass, data, categories = {})
    @flags = {}
    @password = pass
    @name = pass
    data.each { |key, value|
      case key
        when :name        then @name = value
        when :category    then @category = categories[value] || value.to_s
        when :aliases     then @aliases = value
        when :description then @description = value
        when :components  then @components = value
        else @flags[key] = value
      end
    }
  end
end

class PasswordData < DataObject
  attr_reader :name
  attr_reader :category
  attr_reader :password
  attr_reader :aliases
  attr_reader :description
  attr_reader :disablesOnlineTrading
  attr_reader :disablesOnlineRandBats
  attr_reader :startOnly
  attr_reader :cannotDisable
  attr_reader :function

  def initialize(pass, data, categories = {})
    @flags = {}
    @password = pass
    @name = pass
    data.each { |key, value|
      case key
        when :name                   then @name = value
        when :category               then @category = categories[value] || value.to_s
        when :aliases                then @aliases = value
        when :description            then @description = value
        when :disablesOnlineTrading  then @disablesOnlineTrading = value
        when :disablesOnlineRandBats then @disablesOnlineRandBats = value
        when :startOnly              then @startOnly = value
        when :cannotDisable          then @cannotDisable = value
        when :function               then @function = value
        else @flags[key] = value
      end
    }
  end
end

class TeamData < DataObject
  attr_reader :index
  attr_reader :name
  attr_reader :trainerType
  attr_reader :partyID
  attr_reader :teamAttributes
  attr_reader :trainerID
  attr_reader :items
  attr_reader :effects
  attr_reader :delayRegister
  attr_reader :partySize
  attr_reader :setParty
  attr_reader :party
  attr_reader :baseTeam

  TeamAttributes = [:openingLine, :ace, :defeat, :battleBGM, :acemusic, :winBGM, :aceIndex, :sendAceLast, :noShiftStyle]
  PerPokemonTeamAttributes = [:entryLines, :faintLines]

  def initialize(index, teamID, data)
    @index = index
    @name = teamID[0]
    @trainerType = teamID[1]
    @partyID = teamID[2]
    @teamAttributes = {}
    @flags = {}
    collectPerPokemonTeamAttributes(data[:mons])

    data.each do |key, value|
      case key
      when *TeamAttributes then @teamAttributes[key] = value
      when :trainerID      then @trainerID = value
      when :items          then @items     = value
      when :trainereffect  then @effects   = value
      when :delayedactions then @delayRegister = value
      when :partySize      then @partySize = value
      when :setParty       then @setParty  = value
      when :mons           then @party     = value
      when :baseTeam       then @baseTeam  = value
      else @flags[key] = value
      end
    end
  end

  def collectPerPokemonTeamAttributes(mons)
    PerPokemonTeamAttributes.each { |symbol|
      mons.each_with_index { |mon, monindex|
        next unless mon[symbol]
        @teamAttributes[symbol] = {} if !@teamAttributes[symbol]
        @teamAttributes[symbol][monindex] = mon.delete(symbol)
      }
    }
  end

  def getValue(key)
    return TeamAttributes.include?(key) ? @teamAttributes[key] : self.send(key)
  end

  def shouldWrite?(key, baseTeam)
    value = self.getValue(key)
    return !value.nil? && (!baseTeam || value != baseTeam.getValue(key))
  end
end

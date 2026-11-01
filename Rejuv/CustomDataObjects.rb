class PoolEncounterWrapper
  attr_reader :hash

  def initialize()
    @hash = {}
  end

  def gatherPools
    @hash.each { |mon, sets|
      for set in sets
        monPool = set.pool

        var = "@" + monPool.to_s
        self.instance_variable_set(var, []) if !self.instance_variable_defined?(var)
        pool = self.instance_variable_get(var)
        pool.push(set)
      end
    }
  end

  def pool(pool)
    var = "@" + pool.to_s
    return self.instance_variable_get(var)
  end

  def method_missing(method, *args, &block)
    if @hash.respond_to?(method)
      @hash.send(method, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private = false)
    @hash.respond_to?(method) || super
  end
end

class PoolEncounter < DataObject
  attr_reader :pool
  attr_reader :species
  attr_reader :form
  attr_reader :level
  attr_reader :nature
  attr_reader :ability
  attr_reader :item
  attr_reader :ev
  attr_reader :iv
  attr_reader :hptype
  attr_reader :moves

  def initialize(species, pool, data)
    @species = species
    @pool = pool
    @form = 0
    @flags = {}
    data.each { |key, value|
      case key
        when :form    then @form = value
        when :ability then @ability = value
        when :item    then @item = value
        when :nature  then @nature = value
        when :moves   then @moves = value
        when :ev      then @ev = value
        when :iv      then @iv = value
        when :hptype  then @hptype = value
        when :level   then @level = value
        else
          @flags.store(key, value)
      end
    }
  end

  def createPokemonHash(level = @level)
    poke = {
      species: @species,
      form: @form,
      level: level
    }
    poke.store(:ability, @ability) if @ability
    poke.store(:iv, @iv) if @iv
    poke.store(:ev, @ev) if @ev
    poke.store(:nature, @nature) if @nature
    poke.store(:moves, @moves) if @moves
    poke.store(:happiness, 255) if @moves.include?(:RETURN)
    poke.store(:hptype, @hptype) if @hptype
    poke.store(:item, @item) if @item
    @flags.each { |k, v|
      poke.store(k, v)
    }
    return poke
  end

  def createPokemon(level = @level)
    poke = createPokemonHash(level)
    poke = PokeBattle_Pokemon::PokemonBuilder.new(poke).build
    poke.timeReceived = nil
    return poke
  end
end

class XTEncounter < PoolEncounter
  def createPokemonHash(*args)
    return super(*args).merge({
      originalTrainer: "Mr. Luck",
      catchtext: "Xenpurgis Tower",
      catchlevel: 50,
      catchmap: 999
    })
  end
end

class BlessingData < DataObject
  attr_reader :blessing
  attr_reader :name
  attr_reader :desc
  attr_reader :values
  attr_reader :calcs
  attr_reader :maxRank
  attr_reader :rules
  attr_reader :group
  attr_reader :icon

  def initialize(blessing, data)
    @flags = {}
    @blessing = blessing
    data.each { |key, value|
      case key
        when :name    then @name    = value
        when :desc    then @desc    = value
        when :values  then @values  = value
        when :calcs   then @calcs   = value
        when :pool    then @pool    = value
        when :rules   then @rules   = value
        when :maxRank then @maxRank = value
        when :group   then @group   = value
        when :icon    then @icon    = value
        else @flags.store(key, value)
      end
    }
  end

  def getValue(value, rank, default = nil)
    default ||= BlessingTables::DefaultDataValues[value]
    ret = @values.fetch(value, default)
    ret = ret[rank - 1] if ret.is_a?(Array)
    return ret
  end

  def getDesc(rank, extended = false)
    rank = 1 if rank < 1
    rank = @maxRank if rank > @maxRank
    rank -= 1
    desc = @desc.is_a?(Array) ? @desc[rank] : @desc
    desc = pbGetMessageFromHash(:BlessingDescriptions, desc)
    ret = variableReplace(desc, rank, extended)

    return ret
  end

  def getRules
    return [] if !@rules
    rules = @rules.map { |r| variableReplace(pbGetMessageFromHash(:BlessingRules, r)) }
    return rules
  end

  def variableReplace(string, rank = 0, extended = false)
    darkColor = shadowc3tag(Color.new(167, 167, 167), Color.new(0, 0, 0))
    str = string.gsub(/@([^@]+)@/) { |m|
      expr = m[1..-2]

      mult_match = expr.match(/\A(\w+)\s*\*\s*(\d+(?:\.\d+)?)\z/)

      if mult_match
        var = mult_match[1]
        multiplier = mult_match[2].to_f
        value = @values.fetch(var.to_sym)
        value = value[rank]
        if extended && value.is_a?(Array)
          ret = []
          for i in 0...value.length
            v = value[i] * multiplier
            str = sprintf("%g", v)
            str = darkColor + str + "</c3>" if rank != i
            ret.push(str)
          end
          value = ret.join(darkColor + "/" + "</c3>")
        else
          value = value[rank] if value.is_a?(Array)
          value = value * multiplier
        end
      else
        var = expr.to_sym
        value = @values.fetch(var)
        value = value[rank]
        if value.is_a?(Array)
          if var == :stats
            ret = ""
            value.each { |v|
              ret += getStatName(v, :full)
              ret += "," if v != value[-1] && value.length != 2
              ret += " " if v != value[-1]
              ret += "and " if v == value[-2]
            }
            value = ret
          elsif var == :status
            ret = ""
            value.each { |v|
              ret += BlessingTables::Statuses[v]
              ret += "," if v != value[-1] && value.length != 2
              ret += " " if v != value[-1]
              ret += "or " if v == value[-2]
            }
            value = ret
          elsif var == :type
            ret = ""
            value.each { |v|
              ret += getTypeName(v)
              ret += "," if v != value[-1] && value.length != 2
              ret += " " if v != value[-1]
              ret += "and " if v == value[-2]
              ret += "-type" if v == value[-1]
            }
            value = ret
          else
            ret = []
            for i in 0...value.length
              v = value[i]
              str = sprintf("%g", v)
              str = darkColor + str + "</c3>" if rank != i
              ret.push(str)
            end
            value = ret.join("/")
          end
        else
          case var
            when :stats   then value = getStatName(value, :full)
            when :status  then value = BlessingTables::Statuses[value]
            when :type    then value = getTypeName(value) + "-type"
            else
              # do nothing
          end
        end
      end
      value = sprintf("%g", value) if value.is_a?(Numeric)
      next value
    }
    return str
  end

  def export
    exporttext = ""
    exporttext += "  #{@blessing.inspect} => {\n"
    exporttext += "    :name => #{@name.inspect},\n"
    exporttext += "    :desc => "
    if @desc.uniq.length == 1
      exporttext += @desc[0].inspect
    else
      exporttext += "[\n"
      @desc.each_with_index { |desc, i|
        exporttext += "      #{desc.inspect}"
        exporttext += "," unless i == @values.keys[-1]
        exporttext += "\n"
      }
      exporttext += "    ]"
    end
    exporttext += ",\n"
    exporttext += "    :values => {\n"
    @values.each { |key, value|
      exporttext += "      #{key.inspect} => "
      if value == BlessingTables::TypeBoost
        exporttext += "BlessingTables::TypeBoost"
      elsif value == BlessingTables::SwitchBoost
        exporttext += "BlessingTables::SwitchBoost"
      elsif value.uniq.length == 1
        str = value[0].inspect
        if key == :stats
          str = "[" + value[0].map { |stat| "PBStats::#{["ATTACK", "DEFENSE", "SPATK", "SPDEF", "SPEED", "ACCURACY", "EVASION"][stat - 1]}" }.join(", ") + "]"
        end
        exporttext += str
      else
        exporttext += "[\n"
        value.each_with_index { |v, i|
          exporttext += "        "
          str = v.inspect
          if key == :stats
            str = "[" + v.map { |stat| "PBStats::#{["ATTACK", "DEFENSE", "SPATK", "SPDEF", "SPEED", "ACCURACY", "EVASION"][stat - 1]}" }.join(", ") + "]"
          end
          exporttext += str
          exporttext += "," unless i == value.length - 1
          exporttext += "\n"
        }
        exporttext += "      ]"
      end
      exporttext += "," unless key == @values.keys[-1]
      exporttext += "\n"
    }
    exporttext += "    },\n"
    exporttext += "    :maxRank => #{@maxRank.inspect},\n" if @maxRank != 3
    @flags.each { |key, value|
      exporttext += "    #{key.inspect} => #{value.inspect},\n"
    }
    exporttext += "    :group => #{@group.inspect},\n"
    exporttext += "    :icon => #{@icon.inspect},\n" unless @icon.nil?
    exporttext += "  },\n\n"
    return exporttext
  end
end

class DenEncounter < DataObject
  attr_reader :species
  attr_reader :form
  attr_reader :level
  attr_reader :nature
  attr_reader :ability
  attr_reader :item
  attr_reader :ev
  attr_reader :iv
  attr_reader :hptype
  attr_reader :shinyChance
  attr_reader :moves

  def initialize(sym, data)
    @sym = sym
    @species = sym
    @form = 0
    @shinyChance = 0
    @flags = {}
    data.each { |key, value|
      case key
        when :species     then @species = value
        when :form        then @form = value
        when :ability     then @ability = value
        when :shinyChance then @shinyChance = value
        when :moves       then @moves = value
        when :ev          then @ev = value.is_a?(Array) ? value : Array.new(6, value)
        when :iv          then @iv = value
        when :hptype      then @hptype = value
        when :level       then @level = value
        else
          @flags.store(key, value)
      end
    }
  end

  def createPokemonHash(level = 1)
    poke = { species: @species, form: @form, level: @level || level }
    poke.store(:ability, @ability) if @ability
    poke.store(:iv, @iv) if @iv
    poke.store(:ev, @ev) if @ev
    poke.store(:shiny, true) if rand() < @shinyChance
    poke.store(:moves, @moves) if @moves
    @flags.each { |k, v|
      poke.store(k, v)
    }
    return poke
  end

  def createPokemon(level = 1)
    return PokeBattle_Pokemon::PokemonBuilder.new(createPokemonHash(level), source: :raidDen).build
  end

  def parseIntArray(value)
    return value if value.is_a?(Array)
    return Array.new(6, value)
  end
end

class RaidDen < DataObject
  attr_reader :symbol
  attr_reader :encounters
  attr_reader :levels
  attr_reader :levelRange
  attr_reader :message

  def initialize
    @flags = {}
    @encounters = {}
    @levels = [95, 80, 65, 50, 35]
    @levelRange = -5..5
    @message = nil
  end

  def setID(den)
    @symbol = den
  end

  def setMessage(message)
    @message = message
    return self
  end

  def setLevels(levels)
    @levels = levels
    return self
  end

  def setLevelRange(*args)
    if args.length == 1
      @levelRange = args[0]
    else
      @levelRange = args[0]..args[1]
    end
    return self
  end

  def addTable(*args)
    if args.length == 1
      id = true
      table = args[0]
    else
      id, table = args
    end

    if @encounters.key?(id)
      puts "Error: Duplicate table ID: #{@den}::#{id}"
      return self
    end

    table = table.map { |poke| next poke if poke.is_a?(Hash); next { encounter: poke } }
    @encounters[id] = table
    return self
  end

  def generateEncounter(random = nil)
    index = 0
    table = @encounters.values[0]
    for i in 0...@encounters.length
      key = @encounters.keys[i]
      if keyEval(key)
        index = i
        table = @encounters[key]
        break
      end
    end
    index = -1 if index > @levels.length

    weights = table.map { |v| v.fetch(:weight, 1) }
    wtable = table.zip(weights).to_h

    enc = wtable.max_by { |_, w| rand ** (1.0 / w) }.first

    level = @levels[index] + rand(@levelRange)
    encObj = getDenEncounter(enc[:encounter])
    if !encObj
      dp("Could not find encounter for #{enc}. Please report.")
      return nil
    end

    return encObj.createPokemon(level)
  end

  def keyEval(key)
    return $game_switches[key] if key.is_a?(Symbol)
    return $game_switches[key] if key.is_a?(Integer)
    return eval(key.inspect.to_s) != false
  end

  def getMessage
    return nil if !@message
    return pbGetMessageFromHash(:DenMessages, @message)
  end
end

class CustomMonData < MonData
  attr_accessor :attrs

  def initialize(species, form, data)
    defaultMonData = $cache.pkmn[species, form]
    # Set every default value from the base species
    defaultMonData.instance_variables.each { |ivar|
      value = defaultMonData.instance_variable_get(ivar)
      self.instance_variable_set(ivar, value)
    }

    @attrs = []
    data.each { |key, value|
      ivar = "@#{key}".to_sym
      if defaultMonData.respond_to?(key)
        # If it's a normal attribute, overwrite the variable.
        self.instance_variable_set(ivar, value)
        @attrs.push(ivar)
      else
        @flags.store(key, value)
      end
    }
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end

  def inspect
    return "<CustomMonData::" + getMonFormName(@species, @form) + ">"
  end

  def to_s; self.inspect; end

  def showAttribute?(attribute)
    return @attrs.include?(attribute)
  end
end

class BossDifficultyWrapper
  attr_accessor :normal
  attr_accessor :story

  def initialize(normal, story)
    @normal = normal
    @story = story
  end

  def activeBoss
    return @normal if !$game_variables
    case $game_variables[:DifficultyModes]
      when 1
        return @story
      when 2
        # intense, etc
      else
        # return normal
    end
    return @normal
  end

  def tryBoss(boss = nil)
    return @normal if !$game_variables
    ret = nil
    case $game_variables[:DifficultyModes]
      when 1
        ret = @story if @story[boss]
      when 2
        # intense, etc
    end
    ret ||= @normal
    return ret
  end

  def method_missing(method, *args, &block)
    if tryBoss(*args).respond_to?(method)
      tryBoss(*args).send(method, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private = false)
    activeBoss.respond_to?(method) || super
  end
end

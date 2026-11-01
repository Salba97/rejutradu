=begin
This is a Pokedex Object meant for the Reborn-verse scripts.
Aims to remove the need for old global variables as well as
remove the need for every battler to have their own array of
Pokedex info.

Made by Haru
=end

def printGenderDiff
  text = ""
  Dir.each_child("Graphics/Battlers") { |f|
    if f.include?("f") && !f.include?("Egg")
      id = f[0..2].to_i - 1
      text += ":#{$cache.pkmn.keys[id]},\n"
    end
  }
  puts text
end

class Pokedex
  attr_accessor :dexList
  attr_accessor :canViewDex
  attr_accessor :storedGen

  def initialize(*args)
    # initDexList()
    @canViewDex = false
    @storedGen = Gen
  end

  def [](species, form = nil)
    if form
      return @dexList[species][form]
    else
      return @dexList[species]
    end
  end

  def canViewDex
    return false if hidePlayerPossessions?
    return false if $game_switches[:NotPlayerCharacter]
    return @canViewDex
  end

  def initDexList(debug = false)
    @dexList = {}
    $cache.pkmn.each { |species, wrapper|
      entry = PokedexListEntry.new(species, debug)
      forms = {}
      wrapper.forms.each { |formNumber, formName|
        next if wrapper[formNumber].checkFlag?(:ExcludeDex)
        forms.store(formNumber, formName)
      }
      forms.each { |formNumber, formName|
        formData = {
          :seen => false,
          :owned => 0,
          :shiny => false,
          :shadow => false, # shadow will ONLY be set to true when caught
          :gender => { M: false, F: false },
        }

        entry.forms.store(formName, formData)
      }
      @dexList.store(species, entry)
    }
  end

  def dexList
    if @dexList
      refreshDex if $cache.pkmn.length != @dexList.length
    end
    return @dexList
  end

  def updateGenderFormEntries
    return if !@dexList

    $cache.pkmn.each { |species, wrapper|
      next if !@dexList.keys.include?(species)

      entry = @dexList[species]
      if entry.forms != wrapper.forms.length
        forms = {}
        wrapper.forms.each { |formNumber, formName|
          next if wrapper[formNumber].checkFlag?(:ExcludeDex)
          forms.store(formNumber, formName)
        }
        forms.each { |formNumber, formName|
          next if entry.forms.keys.include?(formName)
          formData = {
            :seen => false,
            :owned => 0,
            :shiny => false,
            :shadow => false, # shadow will ONLY be set to true when caught
            :gender => { M: false, F: false },
          }
          entry.forms.store(formName, formData)
        }
      end
    }
  end

  def updateGenderFormEntriesFromPokemon(pokemon)
    self.dexList[pokemon.species].setLastSeenObj(pokemon)
  end

  def createDummyPokemon(species, form, gender)
    randomgame = $game_switches[:Randomized_Challenge]
    $game_switches[:Randomized_Challenge] = false
    dummymon = PokeBattle_Pokemon.new(species, 1, $Trainer, true, form)
    $game_switches[:Randomized_Challenge] = randomgame

    gender ||= self.dexList[species].lastSeen[:gender]
    dummymon.setGender(gender)

    shiny = self.dexList[species].lastSeen[:shiny]
    dummymon.shinyflag = shiny

    shadow = self.dexList[species].lastSeen[:shadow]
    shadow ? dummymon.makeFakeShadow : dummymon.unmakeFakeShadow

    return dummymon
  end

  def refreshDex(forceRefresh = false)
    @storedGen = Gen if forceRefresh
    $cache.pkmn.each { |species, wrapper|
      next if !forceRefresh && @dexList.has_key?(species) && @dexList[species].forms.keys == wrapper.forms.values
      forms = {}
      wrapper.forms.each { |formNumber, formName|
        next if wrapper[formNumber].checkFlag?(:ExcludeDex)
        forms.store(formNumber, formName)
      }
      debug = @dexList[species] ? @dexList[species].debug : false
      entry = PokedexListEntry.new(species, debug)
      if @dexList.has_key?(species)
        forms.each { |formNumber, formName|
          if @dexList[species].forms.key?(formName)
            formData = {
              :seen => @dexList[species][formName][:seen],
              :owned => @dexList[species][formName][:owned],
              :shiny => @dexList[species][formName][:shiny],
              :shadow => @dexList[species][formName][:shadow],
              :gender => { M: @dexList[species][formName][:seen], F: @dexList[species][formName][:seen] },
            }

            entry.forms.store(formName, formData)
          else
            formData = {
              :seen => false,
              :owned => 0,
              :shiny => false,
              :shadow => false, # shadow will ONLY be set to true when caught
              :gender => { M: false, F: false },
            }
            entry.forms.store(formName, formData)

          end
        }

        lastForm = @dexList[species].lastSeen[:form]
        lastGender = @dexList[species].lastSeen[:gender]
        lastShiny = @dexList[species].lastSeen[:shiny]
        lastShadow = @dexList[species].lastSeen[:shadow]
        lastForm = forms[0] if !forms.any? { |formNumber, formName| formNumber == lastForm || formName == lastForm }
        lastGender = :M if !lastGender.is_a?(Symbol)

        entry.setLastSeen(lastForm, lastGender, lastShiny, lastShadow)
      else
        forms.each { |formNumber, formName|
          formData = {
            :seen => false,
            :owned => 0,
            :shiny => false,
            :shadow => false,
            :gender => [false, false],
          }
          entry.forms.store(formName, formData)
        }
      end
      @dexList[species] = entry
    }
  end

  def getSeenCount(region = 0)
    return 0 if !self.dexList

    ret = 0
    if region == 0
      self.dexList.each { |species, dex|
        ret += 1 if dex.seen?
      }
    else
      dexlist = pbGetDexList(region)
      dexlist.each { |entry|
        species = entry[0]
        form = entry[-1]
        ret += 1 if seen?(species, form)
      }
    end
    return ret
  end

  def getOwnedCount(region = 0)
    return 0 if !self.dexList

    ret = 0
    if region == 0
      self.dexList.each { |species, dex|
        ret += 1 if dex.owned?
      }
    else
      dexlist = pbGetDexList(region)
      dexlist.each { |entry|
        species = entry[0]
        form = entry[-1]
        ret += 1 if owned?(species, form)
      }
    end
    return ret
  end

  def getShadowCount(region = 0)
    ret = 0
    self.dexList.each { |species, entry|
      entry.forms.each { |formName, entryData|
        ret += 1 if entryData[:shadow]
      }
    }
    return ret
  end

  def seen?(species, form = nil, gender = nil, shiny = false, shadow = false)
    return self.dexList[species].seen?(form, gender, shiny, shadow)
  end

  def owned?(species, form = nil, gender = nil, shiny = false, shadow = false)
    return self.dexList[species].owned?(form, gender, shiny, shadow)
  end

  def meaningful_owned?(species, forms)
    forms = Array(forms)
    ownedforms = $cache.pkmn[species].forms.keys.select { |form| owned?(species, form) }
    return forms.all? { |form|
      ownedforms.include?(form) || ownedforms.any? { |ownform| !isMeaningfulForm(species, form, ownform) }
    }
  end

  def shinySeen?(species, form = nil, gender = nil, shadow = false)
    return self.dexList[species].shinySeen?(form, gender, shadow)
  end

  def shadowCaught?(species, form = nil, gender = nil, shiny = false)
    return self.dexList[species].shadowCaught?(form, gender, shiny)
  end

  def setSeen(pokemon)
    return if !pokemon.is_a?(PokeBattle_Pokemon)
    return if $game_switches && $game_switches[:NotPlayerCharacter]
    return if pokemon.getCacheData.checkFlag?(:ExcludeDex)

    self.dexList[pokemon.species].setSeen(pokemon.form, pokemon.gender, pokemon.isShiny?)

    updateGenderFormEntriesFromPokemon(pokemon)
  end

  def setOwned(pokemon)
    return if !pokemon.is_a?(PokeBattle_Pokemon)
    return if $game_switches && $game_switches[:NotPlayerCharacter]
    return if pokemon.getCacheData.checkFlag?(:ExcludeDex)

    self.dexList[pokemon.species].setOwned(pokemon.form, pokemon.gender, pokemon.isShiny?, pokemon.isShadow?)

    self.setSeen(pokemon)
  end

  def clearPokedex
    initDexList()
  end

  def debugDex
    initDexList(true)
  end

  def getLastSeen(species)
    return self.dexList[species].lastSeen
  end
end


class PokedexListEntry
  attr_reader :species
  attr_accessor :forms
  attr_accessor :lastSeen
  attr_reader :debug

  def initialize(species, debug = false)
    @species = species
    @forms = {}
    @lastSeen = {
      :form => 0,
      :gender => :M,
      :shiny => false,
      :shadow => false,
    }
    @debug = debug
  end

  def [](form)
    form = $cache.pkmn[@species].forms[form] if form.is_a?(Numeric)
    form = @forms.keys[0] if !$cache.pkmn[@species].forms.value?(form) || form.nil?
    return @forms[form]
  end

  def setSeen(form = 0, gender = :M, shiny = false)
    form = $cache.pkmn[@species].forms[form] if form.is_a?(Numeric)
    form = @forms.keys[0] if !$cache.pkmn[@species].forms.value?(form) || form.nil?
    gender = :M if ![:M, :F].include?(gender)
    @forms[form][:seen] = true
    @forms[form][:gender] = {} unless @forms[form][:gender]
    @forms[form][:gender][gender] = true
    @forms[form][:shiny] = true if shiny
  end

  def setOwned(form = 0, gender = :M, shiny = false, shadow = false)
    form = $cache.pkmn[@species].forms[form] if form.is_a?(Numeric)
    form = @forms.keys[0] if !$cache.pkmn[@species].forms.value?(form) || form.nil?
    gender = :M if ![:M, :F].include?(gender)
    @forms[form][:owned] += 1
    @forms[form][:gender] = {} unless @forms[form][:gender]
    @forms[form][:gender][gender] = true
    @forms[form][:shiny] = true if shiny
    @forms[form][:shadow] = true if shadow
  end

  def seen?(form = nil, gender = nil, shiny = nil, shadow = nil)
    return check(:seen, form, gender, shiny, shadow)
  end

  def owned?(form = nil, gender = nil, shiny = nil, shadow = nil)
    return check(:owned, form, gender, shiny, shadow)
  end

  def shinySeen?(form = nil, gender = nil, shadow = nil)
    return check(:seen, form, gender, true, shadow)
  end

  def shadowCaught?(form = nil, gender = nil, shiny = nil)
    return check(:owned, form, gender, shiny, true)
  end

  def check(status, form, gender, shiny, shadow)
    return true if @debug
    if form
      return false if $cache.pkmn[species, form].checkFlag?(:ExcludeDex)
      form = $cache.pkmn[@species].forms[form] if form.is_a?(Numeric)
      form = @forms.keys[0] if !$cache.pkmn[@species].forms.value?(form) || form.nil?
    end
    if gender&.is_a?(String)
      gender = [:M, :F][["Male", "Female"].index(gender)]
    end
    found = false
    if form && (!Rejuv || isMeaningfulForm(@species, form, $cache.pkmn[species, form].baseForm))
      found = @forms[form][status]
      found = found > 0 if status == :owned
      if gender
        hasGender = @forms[form][:gender].fetch(gender, true)
        found = found && hasGender
      end
      if shiny
        hasShiny = @forms[form][:shiny]
        found = found && hasShiny
      end
      if shadow
        hasShadow = @forms[form][:shadow]
        found = found && hasShadow
      end

    else
      found = @forms.any? { |form, entry|
        ret = entry[status]
        ret = ret > 0 if status == :owned
        if gender
          hasGender = entry[:gender].fetch(gender, true)
          ret = ret && hasGender
        end
        if shiny
          hasShiny = entry[:shiny]
          ret = ret && hasShiny
        end
        if shadow
          hasShadow = entry[:shadow]
          ret = ret && hasShadow
        end
        ret
      }
    end
    return found
  end

  def setLastSeenObj(pokemon)
    gender = pokemon.isGenderless? ? 0 : pokemon.gender
    setLastSeen(pokemon.form, gender, pokemon.isShiny?, pokemon.isShadow?)
  end

  def setLastSeen(form, gender, shiny, shadow)
    form = $cache.pkmn[@species].forms.invert[form] if form.is_a?(String)
    form = 0 if !$cache.pkmn[@species].forms.key?(form) || form.nil?
    gender = :M if ![:M, :F].include?(gender)
    @lastSeen = {
      :form => form,
      :gender => gender,
      :shiny => shiny,
      :shadow => shadow
    }
  end
end

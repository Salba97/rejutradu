# This class stores data on each Pokemon.  Refer to $Trainer.party for an array
# of each Pokemon in the Trainer's current party.
class PokeBattle_Pokemon
  # stat information
  attr_accessor :totalhp     # Current Total HP (setter needed for the AI)
  attr_accessor :hp          # Current HP
  attr_reader :attack        # Current Attack stat
  attr_reader :defense       # Current Defense stat
  attr_accessor :speed       # Current Speed stat
  attr_reader :spatk         # Current Special Attack stat
  attr_reader :spdef         # Current Special Defense stat
  attr_accessor :iv          # Individual Values
  attr_accessor :ev          # Effort Values
  # basic data
  attr_accessor :species     # Species
  attr_accessor :form        # Form
  attr_accessor :ability     # Ability
  attr_accessor :moves       # Moves (PBMove)
  attr_accessor :zmoves      # Z-Moves (PBMove)
  attr_accessor :item        # Held item
  attr_accessor :name        # Nickname
  attr_accessor :exp         # Current experience points
  attr_accessor :level       # Current level
  attr_accessor :happiness   # Current happiness
  attr_accessor :status      # Status problem
  attr_accessor :statusCount # Sleep countdown / Toxic flag / (Champions) Freeze countup (sleep count persists between battles)
  # other data
  attr_accessor :personalID  # Personal ID
  attr_accessor :trainerID   # 32-bit Trainer ID
  attr_accessor :mail        # Mail
  attr_accessor :fused       # The Pokémon fused into this one
  attr_accessor :eggsteps    # Steps to hatch egg, 0 if Pokémon is not an egg
  attr_accessor :firstmoves  # The moves known when this Pokémon was obtained
  attr_accessor :learntEggMoves # Egg moves the pokemon has learnt at some point
  attr_accessor :ballused    # Ball used
  attr_accessor :markings    # Markings
  attr_accessor :obtainMode  # 0=gift, 1=hatched, 2=traded, 3=caught, 4=mysterygift, 5=snagged
  attr_accessor :obtainMap   # Map where obtained
  attr_accessor :obtainText  # Replaces the obtain map's name if not nil
  attr_accessor :obtainLevel # Level obtained
  attr_accessor :hatchedMap  # Map where an egg was hatched
  attr_accessor :language    # Language
  attr_accessor :ot          # Original Trainer's name
  attr_accessor :pokerus     # Pokérus strain and infection time
  # modification flags
  attr_accessor :genderflag  # Forces male (0) or female (1)
  attr_accessor :natureflag  # Forces a particular nature
  attr_accessor :shinyflag   # Forces shininess (true/false)
  attr_accessor :hptype      # Forces Hidden Power type
  # data for various evo methods
  attr_accessor :recoilTaken
  attr_accessor :walkedSteps
  attr_accessor :timesMoveUsed
  attr_accessor :defeatedEnemies
  # misc
  attr_accessor :originalAbility # stores original ability for semi permanent ability changes (mega evolution etc.)
  attr_accessor :originalForm    # stores original form for semi permanent form changes (needed for power construct, ultra burst, some megas)
  attr_accessor :relearner       # Used for party menu relearn feature
  attr_accessor :aura            # Used to draw auras around the pokemon sprite, currently only for other trainers
  attr_accessor :slidein         # Used for trainer pokemon to make them slide in the first time they appear in battle
  attr_accessor :backupstats     # Used to ensure that IV/EV passwords don't change the Chess Pieces that trainer pokemon are meant to have

  def initialize(species, level, player = $Trainer, withMoves = true, form = nil)
    @form = form || 0
    if $game_switches[:Just_Budew]
      species = :BUDEW
      @form = 0
    elsif $game_switches[:Just_Vulpix]
      species = :VULPIX
      @form = rand(2)
    end
    @species = species
    @moves = []
    @trainerID = player.id
    self.rollPersonalID
    initAbility
    @nature = $cache.natures.keys[@personalID % 25]
    @hp = 1
    @totalhp = 1
    @ev = [0, 0, 0, 0, 0, 0]
    @iv = [rand(32), rand(32), rand(32), rand(32), rand(32), rand(32)]
    if (getCacheData.EggGroups.include?(:Undiscovered) || @species == :MANAPHY) || $game_switches[:Forced3IVs] || ($game_variables[:DrinkIVs] && $game_variables[:DrinkIVs] > 0) # undiscovered group or manaphy
      stat1, stat2, stat3 = [0, 1, 2, 3, 4, 5].sample(3)
      for i in 0..5
        @iv[i] = 31 if [stat1, stat2, stat3].include?(i)
      end
    end
    # IV overrides
    @iv = [31, 31, 31, 31, 31, 31] if $game_switches[:Full_IVs]
    @iv = [0, 0, 0, 0, 0, 0] if $game_switches[:Empty_IVs_Password]
    @level = level
    @exp = PBExp.startExperience(level, self.growthrate)
    self.calcStats
    @hp = @totalhp

    self.resetMoves if withMoves

    # Flavor data
    @ot = player.name
    @language = player.language
    @happiness = getCacheData.Happiness
    @name = getMonName(@species, @form)
    timediverge = $Settings.unrealTimeDiverge
    $Settings.unrealTimeDiverge = 0
    @timeReceived = pbCatchTime
    $Settings.unrealTimeDiverge = timediverge
    @eggsteps = 0
    @status = nil
    @statusCount = 0
    @item = nil
    @mail = nil
    @fused = nil
    @ballused = :POKEBALL
    @obtainMap = $game_map.map_id
    @obtainText = nil
    @obtainLevel = level
    @obtainMode = 0 # Met
    @obtainMode = 4 if $game_switches[:Fateful_Encounter]
    @hatchedMap = 0
    @relearner = [false, 0]
  end

  def setBall(pokeball)
    @ballused = pokeball
  end

  def rollPersonalID
    @personalID = (rand(65536) | (rand(65536) << 16))
    shinyretries = 0
    shinyretries += 2 if $PokemonBag.pbQuantity(:SHINYCHARM) > 0 # 3 tries with shiny charm aka 3 times as likely
    shinyretries += 4 if $game_variables[:LuckShinies] > 0 # 5 tries with Luck contract aka 5 times as likely
    if shinyretries > 0
      shinyretries.times do
        break if self.isShiny?

        @personalID = (rand(65536) | (rand(65536) << 16))
      end
    end
  end

  # more flavor stuff
  def personalID(checkHiddenID = false)
    return @personalID.to_i if @personalID.is_a?(Numeric) || !checkHiddenID

    return @personalID
  end

  def getMegaEvoData
    return getCacheData.MegaEvolutions
  end

  def getCacheData(wrapper = false, useOriginalForm: false)
    ret = $cache.pkmn[@species]
    return ret if wrapper

    return @customForm if @customForm

    form = self.form
    # When getting certain kinds of data, use originalForm for pokemon that have it set
    # This allows Mega Meowstic and Toxtricity to learn the correct level-up moves in battle, for example
    form = self.originalForm if useOriginalForm && self.originalForm

    ret = ret[form]
    if !ret.genderDifferences.empty?
      ret = ret[self.gender]
    end
    return ret
  end

  ################################################################################
  # Stat calculations, Pokémon creation
  ################################################################################
  def baseStats
    if @species == :CASTFORM && @item == :CASTCREST && !@customForm
      case @form
        when 1 then return [70, 70, 70, 90, 70, 100]
        when 2 then return [100, 70, 80, 70, 80, 70]
        when 3 then return [70, 70, 70, 100, 70, 90]
      end
    end
    if @species == :ZORUA && @item == :GOLDENAPPLE && !@customForm
      case @form
        when 0 then return [60, 105, 60, 120, 60, 105]
        when 1 then return [55, 100, 60, 125, 60, 110]
      end
    end
    return getCacheData.BaseStats
  end

  def calcHP(base, level, iv, ev)
    return 1 if base == 1

    return ((base * 2 + iv + (ev >> 2)) * level / 100).floor + level + 10
  end

  def calcStat(base, level, iv, ev, naturemod)
    naturemod = 1 if naturemod == nil
    return ((((base * 2 + iv + (ev >> 2)) * level / 100).floor + 5) * naturemod).floor
  end

  def calcStats
    @nature = $cache.natures.keys[self.personalID % 25] if @nature.nil?
    stats = []
    level = self.level
    bs = self.baseStats
    naturemod = {
      $cache.natures[self.nature].incStat => 1.1,
      $cache.natures[self.nature].decStat => 0.9,
    }
    for i in 0..5
      base = bs[i]
      if i == 0
        stats[i] = calcHP(base, level, @iv[i], @ev[i])
      else
        stats[i] = calcStat(base, level, @iv[i], @ev[i], naturemod.dig(i))
      end
    end
    diff = @totalhp - @hp
    @totalhp = stats[0]
    if @hp > 0
      @hp = @totalhp - diff
      @hp = 1 if @hp <= 0
      @hp = @totalhp if @hp > @totalhp
    end
    @attack = stats[1]
    @defense = stats[2]
    @spatk = stats[3]
    @spdef = stats[4]
    @speed = stats[5]
  end

  def getStats
    return [self.totalhp, self.attack, self.defense, self.spatk, self.spdef, self.speed]
  end

  ################################################################################
  # Level
  ################################################################################
  def level=(value)
    @level = value.to_i
  end

  def isEgg?
    return @eggsteps > 0
  end

  def growthrate
    return getCacheData.GrowthRate
  end

  def baseExp
    return getCacheData.BaseEXP
  end

  def getEXPBarLevel(maxgauge)
    startexp = PBExp.startExperience(self.level, self.growthrate)
    endexp = PBExp.startExperience(self.level + 1, self.growthrate)

    if [endexp, self.exp].include?(startexp)
      explevel = self.level >= PBExp.currentHardCapLevel() ? maxgauge : 0
    else
      explevel = [(self.exp - startexp) * maxgauge / (endexp - startexp), 2].max.to_grid
    end
    return explevel
  end

  def getEXPBarText(tts: false)
    startexp = PBExp.startExperience(self.level, self.growthrate)
    endexp = PBExp.startExperience(self.level + 1, self.growthrate)

    if [endexp, self.exp].include?(startexp) && self.level >= PBExp.currentHardCapLevel()
      exptext = self.level >= PBExp.currentMaxLevel() ? _INTL("Max level reached.") : _INTL("Level cap reached.")
    else
      exptext = tts ? (((self.exp - startexp) * 100 / (endexp - startexp).to_f).floor.to_s + "%, ") : ""
      exptext += Reborn || tts ? _INTL("Next level: {1}", endexp - self.exp) : (endexp - self.exp).to_s
      # "To Next Lv." is always displayed in Rejuv/Deso summary screens
    end
    return exptext
  end

  ################################################################################
  # Ability
  ################################################################################
  def abilityIndex
    abillist = getAbilityList
    abil = abillist[self.personalID % abillist.length]
    abil = 0 if abil.nil?
    return abil
  end

  def initAbility
    abillist = getAbilityList
    @ability = abillist[self.personalID % abillist.length]
  end

  def setAbility(value)
    @ability = value
    @ability = getAbilityList[value] if value.is_a?(Integer)
  end

  def getAbilityList
    return getCacheData.getAbilities
  end

  ################################################################################
  # Types
  ################################################################################
  def hasType?(type)
    return self.type1 == type || self.type2 == type
  end

  def types
    return [type1, type2].filter{ |item| !item.nil? }
  end

  def type1
    return getCacheData.Type1
  end

  def type2
    return getCacheData.Type2
  end

  ################################################################################
  # Moves
  ################################################################################
  def numMoves
    ret = 0
    for i in 0...4
      ret += 1 if !@moves[i].nil?
    end
    return ret
  end

  def knowsMove?(move)
    for i in 0...4
      next if @moves[i].nil?
      return true if @moves[i].move == move
    end
    return false
  end

  def getMoveList
    return getCacheData(useOriginalForm: true).Moveset.dup
  end

  def getRelearnList
    v = getCacheData(useOriginalForm: true).RelearnerMoves.dup if !v || v.nil?
    v = [] if !v || v.nil?
    return v
  end

  def getEggMoveList(onlyself = false)
    return getCacheData(useOriginalForm: true).EggMoves.dup if onlyself || @customForm

    # Get egg moves of both lowest species and lowest non-incense species because they can be different (Marill and Azurill for example)
    babyspecies = pbGetBabySpecies(@species, @form)
    babyspecies2 = pbGetNonIncenseLowestSpecies(*babyspecies)
    movelist = $cache.pkmn[*babyspecies].EggMoves.dup
    movelist += $cache.pkmn[*babyspecies2].EggMoves.dup
    movelist.uniq!
    return movelist
  end

  def resetMoves
    @moves = []
    moves = self.getMoveList
    movelist = []
    for i in moves
      if i[0] <= self.level
        movelist.push(i[1])
      end
    end
    movelist |= [] # Remove duplicates
    listend = movelist.length - 4
    listend = 0 if listend < 0
    for i in listend...listend + 4
      next if i >= movelist.length

      @moves.push(PBMove.new(movelist[i]))
    end
  end

  def pbLearnMove(move)
    return if knowsMove?(move)

    @moves.push(PBMove.new(move))
    @moves.shift if @moves.length > 4
    initZmoves(true)
  end

  def pbLearnMoveAtIndex(move, i, dontrestorePP: false)
    oldmovepp = @moves[i] ? @moves[i].pp : nil
    @moves[i] = PBMove.new(move) # Replaces current/total PP
    @moves[i].pp = [oldmovepp, @moves[i].totalpp].min if oldmovepp && dontrestorePP
    updateZMoveIndex(i) if !@zmoves.nil? && @item != :INTERCEPTZ
  end

  # Deletes all moves from the Pokémon.
  def pbDeleteAllMoves
    for i in 0...4
      @moves[i] = nil
    end
  end

  # Copies currently known moves into a separate array, for Move Relearner.
  def pbRecordFirstMoves
    @firstmoves = []
    for i in 0...4
      @firstmoves.push(@moves[i].move) if @moves[i]
    end
  end

  def addLearntEggMove(move)
    @learntEggMoves = [] if !@learntEggMoves
    @learntEggMoves.push(move) unless @learntEggMoves.include?(move)
  end

  def getAllLearnableMoves
    return getFullMoveset(false, true)
  end

  def getAllLegalMoves(include_firstmoves)
    return getFullMoveset(true, include_firstmoves)
  end

  def getFullMoveset(include_technicalities, include_firstmoves)
    return [] if @species.nil?
    return getAllMoves() if $game_switches[:Randomized_Challenge] && $Randomizer.randomMoves

    allTutorMoves = getAllTutorMoves
    allTMMoves = getAllTMMoves
    tmmovelist = getCacheData(useOriginalForm: true).compatiblemoves.dup
    tmmovelist.filter! { |move| (allTutorMoves + allTMMoves).include?(move) }
    # Reborn gen 7 montext also has gen 8 TMs/tutor moves in compatiblemoves, but we don't want to include those here unless they're actually implemented as TMs/tutors
    tmmovelist += getUniversalTMs()
    # Mew can learn all TMs and Tutor moves. Consequently, so does Rejuv's Zygarde when fused with Mew.
    if @species == :MEW || (@customForm && @fused.species == :MEW)
      tmmovelist += allTutorMoves
      tmmovelist += allTMMoves
    end

    relearnermovelist = getRelearnList
    leveluplist = getMoveList.map { |pair| pair[1] }
    egglist = getEggMoveList

    totallist = tmmovelist + egglist + leveluplist + relearnermovelist

    totallist += @firstmoves if include_firstmoves && @firstmoves

    if include_technicalities
      totallist += self.getSketchableMoves if totallist.include?(:SKETCH)
      totallist += self.getOtherFormMoves(totallist)
      totallist += self.getPreEvoOnlyMoves(totallist)
    end

    totallist.uniq!
    exceptionlist = getCacheData(useOriginalForm: true).moveexceptions
    totallist -= exceptionlist

    return totallist
  end

  def getSketchableMoves
    return $cache.moves.keys.reject { |move| (PBStuff::BLACKLISTS[:SKETCH] + PBStuff::ZMOVES + PBStuff::ANIMATIONDUMMIES).include?(move) }
  end

  def getOtherFormMoves(basemoves)
    # Deoxys, Shaymin and Hoopa have form exclusive moves but don't lose them when they change form
    return [] unless [:DEOXYS, :SHAYMIN, :HOOPA].include?(self.species)
    # Actually Hoopa does in Gen 9
    return [] if Gen >= 9 && self.species == :HOOPA

    otherformmoves = []
    for i in 0...getCacheData(true).forms.length
      otherformpokemon = PokeBattle_Pokemon.new(self.species, 100, $Trainer, false, i)
      otherformmoves += otherformpokemon.getAllLearnableMoves - basemoves
    end
    return otherformmoves
  end

  def getPreEvoOnlyMoves(basemoves)
    preevomoves = []
    species, form = self.species, self.form
    loop do
      previous = pbGetPreviousForm(species, form)
      break if previous == [species, form]

      species, form = *previous
      preevopokemon = PokeBattle_Pokemon.new(species, 1, $Trainer, false, form)
      preevomoves += preevopokemon.getAllLearnableMoves - basemoves
    end
    return preevomoves
  end

  def SpeciesCompatible?(move)
    # Can technically just use getAllLearnableMoves, but it's slightly more efficient this way
    return false if @species.nil?

    exceptionlist = getCacheData(useOriginalForm: true).moveexceptions
    return false if exceptionlist.include?(move)
    return true if (@species == :MEW || (@customForm && @fused.species == :MEW)) && isTutorOrTM?(move)
    return true if getUniversalTMs().include?(move)

    tmmovelist = getCacheData(useOriginalForm: true).compatiblemoves
    return true if tmmovelist.include?(move) && isTutorOrTM?(move)

    relearnermovelist = getCacheData(useOriginalForm: true).RelearnerMoves
    return true if relearnermovelist.include?(move)

    leveluplist = getMoveList.map { |pair| pair[1] }
    if leveluplist.include?(move)
      # puts "#{@species} with form #{@form} is compatible with #{move} via levelup learnset, please add it to it's 'compatiblemoves' for efficiency!"
      return true
    end

    egglist = getEggMoveList
    if egglist.include?(move)
      # puts "#{@species} with form #{@form} is compatible with #{move} via it's Egg Moves, please add it to it's 'compatiblemoves' for efficiency!"
      return true
    end

    return false
  end

  # The 4 methods below are used by the party Learn menu and the relearner NPCs
  def pbGetNaturalMovesMenu(include_eggmoves)
    # When used for relearner NPC, egg moves (all for Rejuv, only learnt ones otherwise) should be included in relearnable moves, whereas for Learn menu they should be separate
    eggmoves = include_eggmoves ? (Rejuv && $PokemonBag.pbHasItem?(:HM02) ? self.getEggMoveList : self.learntEggMoves || []) : []
    firstmoves = self.firstmoves || []
    # Egg moves among first moves are moved to egg moves page in Learn menu
    firstmoves -= self.getEggMoveList if !include_eggmoves
    relearnmoves = self.getRelearnList
    levelupmoves = []
    for i in self.getMoveList
      level, move = i[0], i[1]
      levelupmoves.push(move) if level <= self.level
    end

    moves = eggmoves + firstmoves + relearnmoves + levelupmoves
    moves.uniq!
    moves.filter! { |move| !self.knowsMove?(move) }
    return moves
  end

  def pbGetTMMovesMenu
    items = $PokemonBag.getPocketItems(TMPOCKET).dup
    # Sort by TM/TMX and number
    items.sort_by! do |item|
      letters, digits = $cache.items[item].name.partition(/\d+/)
      next [letters, digits.to_i]
    end
    moves = items.map { |item| pbGetTM(item) }
    moves.filter! { |move| self.SpeciesCompatible?(move) }
    moves.filter! { |move| !self.knowsMove?(move) }
    return moves
  end

  def pbGetTutorMovesMenu
    moves = pbGetTutorableMoves(onlybought: true)
    moves.filter! { |move| self.SpeciesCompatible?(move) }
    moves.filter! { |move| !self.knowsMove?(move) }
    return moves
  end

  def pbGetEggMovesMenu
    if Rejuv && $PokemonBag.pbHasItem?(:HM02)
      moves = self.getEggMoveList
    else
      # Egg moves among first moves are moved to egg moves page in Learn menu
      moves = self.getEggMoveList.intersection(self.firstmoves || [])
      moves += self.learntEggMoves || []
      moves.uniq!
    end
    moves.filter! { |move| !self.knowsMove?(move) }
    return moves
  end

  def initZmoves(player)
    crystal = @item
    return unless pbIsZCrystal?(crystal)

    @zmoves = [nil, nil, nil, nil]
    if crystal == :INTERCEPTZ
      @zmoves[0] = PBMove.new(:UNLEASHEDPOWER)
      @zmoves[1] = PBMove.new(:BLINDINGSPEED)
      @zmoves[2] = $game_switches[:RenegadeRoute] && player ? PBMove.new(:CHTHONICMALADY) : PBMove.new(:ELYSIANSHIELD)
      @zmoves[3] = PBMove.new(:DOMAINSHIFT)
      return
    end

    zmove = $cache.items[crystal]&.zmove
    return unless zmove
    zmovedata = $cache.moves[zmove].zmovedata

    if zmovedata.type
      for i in 0...@moves.length
        move = @moves[i]
        next if move.type != zmovedata.type

        @zmoves[i] = move.category == :status ? PBMove.new(move.move) : PBMove.new(zmove)
      end
    elsif zmovedata.basemove
      return unless zmovedata.isCompatible?(@species, @form)
      for i in 0...@moves.length
        move = @moves[i]
        next if move.move != zmovedata.basemove

        @zmoves[i] = PBMove.new(zmove)
      end
    end
  end

  def updateZMoveIndex(index)
    zmove = $cache.items[@item]&.zmove
    return unless zmove
    zmovedata = $cache.moves[zmove].zmovedata
    if zmovedata.type
      if @moves[index].type != zmovedata.type
        @zmoves[index] = nil
      else
        @zmoves[index] =
          @moves[index].category == :status ? PBMove.new(@moves[index].move) : PBMove.new(zmove)
      end
    elsif zmovedata.basemove
      if zmovedata.basemove != @moves[index].move || !zmovedata.isCompatible?(@species, @form)
        @zmoves[index] = nil
      else
        @zmoves[index] = PBMove.new(zmove)
      end
    end
  end

  ################################################################################
  # Nature
  ################################################################################
  def nature
    return @natureflag if @natureflag != nil

    return @nature
  end

  def setNature(value)
    @natureflag = value
    self.calcStats
  end

  def nature=(value)
    @nature = value
    self.calcStats
  end

  def canShowNature?
    return true unless (self.isShadow? rescue false)
    return self.heartStage <= 3
  end

  ################################################################################
  # Shininess
  ################################################################################
  def isShiny?
    return @shinyflag if @shinyflag != nil

    a = self.personalID ^ @trainerID
    b = a & 0xFFFF
    c = (a >> 16) & 0xFFFF
    d = b ^ c
    return d < SHINYPOKEMONCHANCE
  end

  def makeShiny
    @shinyflag = true
  end

  def makeNotShiny
    @shinyflag = false
  end

  ################################################################################
  # Gender
  ################################################################################
  def gender
    return @genderflag if @genderflag != nil

    ratio = $cache.pkmn[self.species, self.form].GenderRatio
    case ratio
      when :Genderless then return :N # genderless
      when :MaleZero then return :F # always female
      when :FemZero then return :M # always male
      when :FemEighth then genderbyte = 31
      when :FemQuarter then genderbyte = 63
      when :FemHalf then genderbyte = 127
      when :MaleQuarter then genderbyte = 191
      when :MaleEighth then genderbyte = 223
    end
    return (self.personalID & 0xFF) <= genderbyte ? :F : :M
  end

  def isMale?
    return self.gender == :M
  end

  def isFemale?
    return self.gender == :F
  end

  def isGenderless?
    return self.gender == :N
  end

  def setGender(value)
    value = :M if value == "Male"
    value = :F if value == "Female"
    value = :N if value == "Genderless" || value == "Any"
    return if ![:M, :F, :N].include?(value)

    @genderflag = value
  end

  def makeMale; setGender(:M); end
  def makeFemale; setGender(:F); end
  def makeGenderless; setGender(:N); end

  ################################################################################
  # Pokérus
  ################################################################################
  def givePokerus(strain = 0)
    return if self.pokerusStage == 2 # Can't re-infect a cured Pokémon

    if strain <= 0 || strain >= 16
      strain = 1 + rand(15)
    end
    time = 1 + (strain % 4)
    @pokerus = time
    @pokerus |= strain << 4
  end

  def resetPokerusTime
    return if @pokerus == 0

    strain = @pokerus % 16
    time = 1 + (strain % 4)
    @pokerus = time
    @pokerus |= strain << 4
  end

  def lowerPokerusCount
    return if self.pokerusStage != 1

    @pokerus -= 1
  end

  def pokerusStage
    return 0 if !@pokerus || @pokerus == 0 # Not infected
    return 2 if @pokerus > 0 && (@pokerus % 16) == 0 # Cured

    return 1 # Infected
  end

  ################################################################################
  # Forms
  ################################################################################
  def form=(value)
    @form = value
    self.calcStats
    initZmoves(true) if @species == :NECROZMA
  end

  # Calls form= but also registers the new form in pokedex.
  # Should not be used by AI.
  def changeForm(value)
    self.form = value unless self.form == value
    # Sometimes the form might already be set to the value when this is called, eg, when mega-ing (as makeMega gets called before changeForm), but pokedex registration should happen anyway
    $Trainer.pokedex.setSeen(self)
    $Trainer.pokedex.setOwned(self) if !$Trainer.pokedex.owned?(@species, @form) && ($Trainer.party.include?(self) || $PokemonStorage.contains?(self))
  end

  def getForm
    if self.species == :DIALGA && self.form.between?(0, 1)
      return self.item == :ADAMANTCRYSTAL ? 1 : 0
    end
    if self.species == :PALKIA && self.form.between?(0, 1)
      return self.item == :LUSTROUSGLOBE ? 1 : 0
    end
    if self.species == :GIRATINA && self.form.between?(0, 1)
      return self.item == :GRISEOUSCORE || DistortionWorld.include?($game_map.map_id) ? 1 : 0
    end
    if self.species == :ARCEUS && self.ability == :MULTITYPE
      case self.item
        when :FISTPLATE, :FIGHTINIUMZ then arcform = 1
        when :SKYPLATE, :FLYINIUMZ then arcform = 2
        when :TOXICPLATE, :POISONIUMZ then arcform = 3
        when :EARTHPLATE, :GROUNDIUMZ then arcform = 4
        when :STONEPLATE, :ROCKIUMZ then arcform = 5
        when :INSECTPLATE, :BUGINIUMZ then arcform = 6
        when :SPOOKYPLATE, :GHOSTIUMZ then arcform = 7
        when :IRONPLATE, :STEELIUMZ then arcform = 8
        when :FLAMEPLATE, :FIRIUMZ then arcform = 10
        when :SPLASHPLATE, :WATERIUMZ then arcform = 11
        when :MEADOWPLATE, :GRASSIUMZ then arcform = 12
        when :ZAPPLATE, :ELECTRIUMZ then arcform = 13
        when :MINDPLATE, :PSYCHIUMZ then arcform = 14
        when :ICICLEPLATE, :ICIUMZ then arcform = 15
        when :DRACOPLATE, :DRAGONIUMZ then arcform = 16
        when :DREADPLATE, :DARKINIUMZ then arcform = 17
        when :PIXIEPLATE, :FAIRIUMZ then arcform = 18
        else arcform = 0
      end
      return 19 + arcform if Reborn && self.form > 18

      return arcform
    end
    if self.species == :GENESECT && self.form.between?(0, 4)
      case self.item
        when :SHOCKDRIVE then return 1
        when :BURNDRIVE then return 2
        when :CHILLDRIVE then return 3
        when :DOUSEDRIVE then return 4
        else return 0
      end
    end
    if self.species == :SILVALLY && self.ability == :RKSSYSTEM
      case self.item
        when :FIGHTINGMEMORY then return 1
        when :FLYINGMEMORY then return 2
        when :POISONMEMORY then return 3
        when :GROUNDMEMORY then return 4
        when :ROCKMEMORY then return 5
        when :BUGMEMORY then return 6
        when :GHOSTMEMORY then return 7
        when :STEELMEMORY then return 8
        when :GLITCHMEMORY then return 9
        when :FIREMEMORY then return 10
        when :WATERMEMORY then return 11
        when :GRASSMEMORY then return 12
        when :ELECTRICMEMORY then return 13
        when :PSYCHICMEMORY then return 14
        when :ICEMEMORY then return 15
        when :DRAGONMEMORY then return 16
        when :DARKMEMORY then return 17
        when :FAIRYMEMORY then return 18
        else return 0
      end
    end
    if self.species == :OGERPON && self.form.between?(0, 3)
      case self.item
        when :WELLSPRINGMASK then return 1
        when :HEARTHFLAMEMASK then return 2
        when :CORNERSTONEMASK then return 3
        else return 0
      end
    end

    return self.form
  end

  def transformZygarde
    self.originalForm = @form
    self.form = 2
  end

  def revertZygarde
    hpbackup = self.hp
    self.form = self.originalForm || self.form
    self.originalForm = nil
    self.hp = [hpbackup, self.totalhp].min
  end

  def changeFormOnLeavingField
    self.form = 0 if [:CASTFORM, :CHERRIM, :WISHIWASHI, :MORPEKO, :CRAMORANT].include?(@species) && @form != 0
    # self.form = 0 if @species == :MELOETTA && @form != 0
    self.form = 0 if @species == :AEGISLASH && @form == 1
    self.form = @form - 1 if @species == :DARMANITAN && @form.odd?
    self.form = (@originalForm || 0) if @species == :MINIOR && @form == 7
  end

  def changeFormOnBattleStart
    if ((@species == :ZACIAN && @item == :RUSTEDSWORD) || (@species == :ZAMAZENTA && @item == :RUSTEDSHIELD)) && @form == 0
      self.form = 1
      for i in 0...@moves.length
        if @moves[i].move == :IRONHEAD
          oldmovepp, oldmoveppup, oldmovetotalpp = @moves[i].pp, @moves[i].ppup, @moves[i].totalpp
          bigmove = @species == :ZACIAN ? :BEHEMOTHBLADE : :BEHEMOTHBASH
          @moves[i] = PBMove.new(bigmove)
          @moves[i].ppup = oldmoveppup
          @moves[i].pp = (oldmovepp * (@moves[i].totalpp.to_f / oldmovetotalpp)).floor
        end
      end
    end
  end

  # Called for all trainer party Pokemon at battle end, as well as for any Pokemon being sent to the PC directly from battle (ie, upon catching a new Pokemon)
  # Does not need to handle form reversions that are handled by pbResetForm method of Battler class
  def changeFormOnBattleEnd
    if self.original
      self.species = self.original[0]
      self.form = self.original[1]
      self.level = self.original[2]
      self.ability = self.original[3]
      self.original = nil
    end
    self.makeUnmega if self.isMega?
    self.makeUnprimal if self.isPrimal?
    self.makeUnultra if self.isUltra?
    self.makeUnterastallized if self.isTerastallized?
    self.revertZygarde if self.species == :ZYGARDE && @form == 2
    if (@species == :ZACIAN || @species == :ZAMAZENTA) && @form == 1
      self.form = 0
      bigmove = @species == :ZACIAN ? :BEHEMOTHBLADE : :BEHEMOTHBASH
      for i in 0...@moves.length
        if @moves[i].move == bigmove
          oldmovepp, oldmoveppup, oldmovetotalpp = @moves[i].pp, @moves[i].ppup, @moves[i].totalpp
          @moves[i] = PBMove.new(:IRONHEAD)
          @moves[i].ppup = oldmoveppup
          @moves[i].pp = (oldmovepp * (@moves[i].totalpp.to_f / oldmovetotalpp)).floor
        end
      end
    end
    self.form = self.getForm # Dialga / Palkia / Giratina / Arceus / Genesect / Silvally / Ogerpon
    self.form = 0 if [:MIMIKYU, :EISCUE, :PALAFIN].include?(@species)
    if @species == :TERAPAGOS && self.form != 0
      self.form = 0
      self.ability = self.abilityIndex # stupid merch turtle
    end
    if Rejuv
      self.form = 1 if [:PARAS, :PARASECT].include?(@species) && @form == 2
      self.prismPower = false
    end
  end

  def makeTransformClone(user) # user is the pokemon using transform/imposter
    copy = self.clone
    copy.status = user.status
    copy.prismPower = user.prismPower if Rejuv
    copy.aura = user.aura
    return copy
  end

  def baseForm
    return getCacheData.baseForm
  end

  def isUntransformableForm?
    return getCacheData.checkFlag?(:BlockTransform)
  end

  def getFormName
    formnames = getCacheData(true).forms
    return "Normal Form" if formnames.empty?
    return formnames[@form].clone
  end

  def hasMegaForm?
    return false if self.isMega? # don't do this if you're mega.

    megaEvo = self.getMegaEvoData
    return false if megaEvo.empty?
    return false if @species == :RAYQUAZA && pbIsZCrystal?(@item)
    return true if @species == :RAYQUAZA && self.moves.any? { |move| megaEvo.has_key?(move.move) }
    return megaEvo.has_key?(@item)
  end

  def hasPrimalForm?
    return false if self.isPrimal?
    return true if getCacheData.checkFlag?(:PrimalForm)
    return false
  end

  def hasUltraForm?
    return @species == :NECROZMA && @item == :ULTRANECROZIUMZ && [1, 2].include?(@form)
  end

  def hasTeraForm?
    return false if self.isTerastallized?
    return false if pbIsZCrystal?(@item)
    return true if getCacheData.checkFlag?(:TerastalForm)
    return false
  end

  def isMega?
    return getCacheData.checkFlag?(:Mega)
  end

  def makeMega
    megaEvo = self.getMegaEvoData
    form = megaEvo[@item]
    if !form # rayquaza, aka non item based
      moves = self.moves.map { |m| m.move }
      move = moves.find { |m| megaEvo.has_key?(m) }
      form = megaEvo[move] if move
    end
    return if !form

    form = $cache.pkmn[@species].forms.invert[form]
    self.originalForm = @form
    self.form = form
    self.originalAbility = self.ability
    self.ability = self.abilityIndex
  end

  def makeUnmega
    if !self.originalForm && $Trainer.party.include?(self)
      dp("this mon's original form was not set, somehow. please report this: species:#{@species} form:#{getCacheData(true).forms[@form]} thx <3")
    end
    self.form = self.originalForm || 0
    self.ability = self.originalAbility if self.originalAbility
    self.originalAbility = nil
    self.originalForm = nil
  end

  def isPrimal?
    return getCacheData.checkFlag?(:Primal)
  end

  def makePrimal
    v = getCacheData.checkFlag?(:PrimalForm)
    self.form = v if v.is_a?(Integer)
    self.originalAbility = self.ability
    self.ability = self.abilityIndex
  end

  def makeUnprimal
    self.form = 0
    self.ability = self.originalAbility if self.originalAbility
    self.originalAbility = nil
  end

  def isUltra?
    return getCacheData.checkFlag?(:Ultra)
  end

  def makeUltra
    v = getCacheData.checkFlag?(:UltraForm)
    self.originalForm = @form
    self.form = v if v.is_a?(Integer)
    self.originalAbility = self.ability
    self.ability = self.abilityIndex
  end

  def makeUnultra
    if !self.originalForm && $Trainer.party.include?(self)
      dp("this mon's original form was not set, somehow. please report this: species:#{@species} form:#{getCacheData(true).forms[@form]} thx <3")
    end
    self.form = self.originalForm || { SOLGALEO: 1, LUNALA: 2 }[self.fused&.species] || 0
    self.ability = self.originalAbility if self.originalAbility
    self.originalAbility = nil
    self.originalForm = nil
  end

  def isTerastallized?
    return getCacheData.checkFlag?(:Terastal)
  end

  def makeTerastallized
    v = getCacheData.checkFlag?(:TerastalForm)
    self.originalForm = @form
    self.form = v if v.is_a?(Integer)
    self.originalAbility = self.ability
    self.ability = self.abilityIndex
  end

  def makeUnterastallized
    if !self.originalForm && $Trainer.party.include?(self)
      dp("this mon's original form was not set, somehow. please report this: species:#{@species} form:#{getCacheData(true).forms[@form]} thx <3")
    end
    self.form = self.originalForm || 0
    self.ability = self.originalAbility if self.originalAbility
    self.originalAbility = nil
    self.originalForm = nil
  end

  def isStellarTerapagos?
    return @species == :TERAPAGOS && self.isTerastallized?
  end

  def isPulse?
    getCacheData.checkFlag?(:Pulse)
  end

  def isRift?
    getCacheData.checkFlag?(:Rift)
  end

  def isPerfection?
    getCacheData.checkFlag?(:Perfection)
  end

  def isKarmaBeast?
    getCacheData.checkFlag?(:Karma)
  end

  ################################################################################
  # Other
  ################################################################################
  def hasAnItem?
    return !@item.nil?
  end

  def isAirborne?
    return false if @item == :IRONBALL
    return true if self.hasType?(:FLYING)
    return true if PBStuff::LevitateAbilities.include?(@ability)
    return true if @item == :AIRBALLOON

    return false
  end

  def setItem(value)
    @item = value
    @zmoves = nil if !$cache.items[value] || !$cache.items[value].zmove
  end

  def checksAfterItemChange
    self.initZmoves(true)
    self.calcStats if self.shouldUpdateStatsOnItemChange?

    check = self.form
    self.changeForm(self.getForm)
    return if check == self.form

    if self.getAbilityList.length > 1
      if self.getAbilityList.include?(self.originalAbility)
        self.ability = self.originalAbility
        self.originalAbility = nil
      else
        self.initAbility
      end
    else
      self.originalAbility = self.originalAbility.nil? ? self.ability : nil
      self.initAbility
    end
  end

  def shouldUpdateStatsOnItemChange?; false; end

  def mail
    return nil if !@mail

    if @mail.item == 0 || !self.hasAnItem? || @mail.item != self.item
      @mail = nil
      return nil
    end
    return @mail
  end

  def language
    return @language ? @language : 0
  end

  def markings
    @markings = 0 if !@markings
    return @markings
  end

  def unownShape
    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ?!"[@form, 1]
  end

  def weight
    return getCacheData.Weight
  end

  def height
    return getCacheData.Height
  end

  def evYield
    return getCacheData.EVs
  end

  def getCatchRate
    return @catchRate ? @catchRate : getCacheData.CatchRate
  end

  def eggGroups
    return getCacheData.EggGroups
  end

  def dexnum
    return getCacheData.dexnum
  end

  def egg?
    return @eggsteps > 0
  end

  def hp=(value)
    value = 0 if value < 0
    @hp = value
    self.healStatus if @hp == 0
  end

  def healHP
    @hp = @totalhp
  end

  def healStatus
    @status = nil
    @statusCount = 0
  end

  def healPP(index = -1)
    for i in 0...4
      next if !@moves[i]

      @moves[i].pp = @moves[i].totalpp
    end
  end

  def heal
    return if egg?

    healHP
    healStatus
    healPP
  end

  def changeHappiness(method)
    sub100, sub200 = @happiness < 100, @happiness < 200
    gain = case method
      # Positives
      when :Walk then sub200 ? 2 : 1
      when :LevelUp, :Candy then sub100 ? 5 : (sub200 ? 4 : 3)
      when :Groom, :Regular then sub200 ? 16 : 5
      when :Groom2, :Travellers then sub200 ? 13 : 8
      when :Groom3 then 255
      when :Vitamin then sub100 ? 5 : (sub200 ? 3 : 2)
      when :Feather then sub100 ? 3 : (sub200 ? 2 : 1)
      when :EVBerry then sub100 ? 10 : (sub200 ? 5 : 2)
      when :XItem then 1
      when :BlueCandy then 220
      when :Luxurious then sub200 ? 30 : 70
      when :GoodCandy then sub100 ? 15 : (sub200 ? 10 : 5)
      # Negatives
      when :Faint then -1
      when :Powder then sub200 ? -5 : -10
      when :EnergyRoot then sub200 ? -10 : -15
      when :RevivalHerb then sub200 ? -15 : -20
      when :BadCandy then sub100 ? -5 : (sub200 ? -4 : -3)
      else 0
    end
    puts "Unknown happiness-changing method" if gain == 0

    if gain > 0
      gain += 1 if self.ballused == :LUXURYBALL
      gain += 1 if @obtainMap == $game_map.map_id
      gain = (gain * 1.5).round if self.item == :SOOTHEBELL
    end
    @happiness += gain
    @happiness = @happiness.clamp(0, 255)
  end

  def recoilTaken
    return @recoilTaken ? @recoilTaken : 0
  end

  def walkedSteps
    return @walkedSteps ? @walkedSteps : 0
  end

  def timesMoveUsed
    return @timesMoveUsed ? @timesMoveUsed : 0
  end

  def defeatedEnemies
    return @defeatedEnemies ? @defeatedEnemies : 0
  end

  def unusable; nil; end # Stub definition for easy access in common scripts

  ################################################################################
  # Ownership, obtained information
  ################################################################################
  # Returns whether the specified Trainer is NOT this Pokemon's original trainer.
  def isForeign?(trainer)
    return @trainerID != trainer.id || @ot != trainer.name
  end

  # Returns the public portion of the original trainer's ID.
  def publicID
    return @trainerID & 0xFFFF
  end

  # Returns this Pokémon's level when this Pokémon was obtained.
  def obtainLevel
    @obtainLevel = 0 if !@obtainLevel
    return @obtainLevel
  end

  # Returns the time when this Pokémon was obtained.
  def timeReceived
    return @timeReceived if !@timeReceived.is_a?(Numeric)
    return @timeReceived ? Time.at(@timeReceived) : Time.gm(2000)
  end

  # Sets the time when this Pokémon was obtained.
  def timeReceived=(value)
    # Seconds since Unix epoch
    if shouldDivergeTime?
      timediverge = $Settings.unrealTimeDiverge
      $Settings.unrealTimeDiverge = 0
      value = Time.new
    end
    if value.is_a?(Time)
      @timeReceived = value.to_i
    else
      @timeReceived = value
    end
    $Settings.unrealTimeDiverge = timediverge if timediverge
  end

  # Returns the time when this Pokémon hatched.
  def timeEggHatched
    if obtainMode == 1
      return @timeEggHatched if !@timeEggHatched.is_a?(Numeric)
      return @timeEggHatched ? Time.at(@timeEggHatched) : Time.gm(2000)
    else
      return Time.gm(2000)
    end
  end

  # Sets the time when this Pokémon hatched.
  def timeEggHatched=(value)
    # Seconds since Unix epoch
    if shouldDivergeTime?
      timediverge = $Settings.unrealTimeDiverge
      $Settings.unrealTimeDiverge = 0
      value = Time.new
    end
    if value.is_a?(Time)
      @timeEggHatched = value.to_i
    else
      @timeEggHatched = value
    end
    $Settings.unrealTimeDiverge = timediverge if timediverge
  end

  def canRelearnAll?
    @relearner = [false, 0] if !@relearner
    return @relearner[0]
  end

  def updateRelearnBar
    @relearner = [false, 0] if !@relearner
    @relearner[1] += 1 if @relearner[1] < 3
    activateRelearner() if @relearner[1] >= 3
  end

  def activateRelearner()
    if !@relearner
      @relearner = [true, 3]
    else
      @relearner[0] = true
    end
  end

  def canChangeAllHPType?
    return @changeAllHPType == true
  end

  def obedient
    return false if Rejuv && self.disobedient
    return self.level <= LEVELCAPS[$Trainer.numbadges]
  end

  def logname # Used by AI
    return getMonName(@species)
  end

  def removeBattleOnlyAttributes
    attrs = [:@sosmon, :@originalhp, :@stolen, :@backupstats]
    attrs += [:@disguise, :@unusable, :@catchRate] if Rejuv
    attrs.each { |a| self.remove_instance_variable(a) if self.instance_variable_defined?(a) }
  end

  def export(snapshot: false, flavor: false, showdown: false)
    if showdown
      name, custom = getMonFormName(@species, @form, @gender, returncustom: true)
      if custom
        output = "#{custom} (#{name})"
      elsif @name
        output = "#{@name} (#{name})"
      else
        output = "#{name}"
      end
      output += " (#{self.gender.to_s})" unless self.isGenderless?
      output += " @ #{getItemName(@item)}" if @item
      output += "\n"

      output += "Ability: #{getAbilityName(@ability)}\n" if @ability
      output += "Level: #{@level}\n"
      output += "Shiny: Yes\n" if self.isShiny?
      output += "Happiness: #{@happiness}\n" if @happiness

      statAry = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]
      if @ev.sum >= 4 #If EVs are significant
        output += "EVs: "
        for e in 0...@ev.length
          next if @ev[e] == 0

          output += "#{@ev[e]} #{statAry[e]}"
          next if e == @ev.length - 1

          output += " / "
        end
        output += "\n"
      end

      output += "#{getNatureName(self.nature)} Nature\n" if self.nature

      output += "IVs: "
      for i in 0...@iv.length
        next if @iv[i] == 31

        output += "#{@iv[i]} #{statAry[i]}"
        next if i == @iv.length - 1

        output += " / "
      end
      output += "\n"

      if @moves
        for move in @moves
          next if !move

          output += "- #{getMoveName(move.move)}"
          output += " [#{getTypeName(@hptype)}]" if move.move == :HIDDENPOWER && @hptype
          output += "\n"
        end
      end
      return output
    else
      output = "{\n"
      output += "  :boss => #{@bossID},\n" if @bossID
      output += "  :species => #{@species.inspect},\n"
      output += "  :form => #{@form},\n" if @form != 0
      output += "  :ability => #{@ability.inspect},\n"
      output += "  :name => #{@name.inspect},\n" if @name != getMonName(@species, @form)
      output += "  :level => #{@level},\n"
      output += "  :gender => #{self.gender.inspect},\n"
      output += "  :item => #{@item.inspect},\n" if @item
      output += "  :nature => #{@nature.inspect},\n"
      output += "  :happiness => #{@happiness},\n"
      output += "  :ev => #{@ev.inspect},\n" if @ev.sum >= 4
      ivOutput = @iv.inspect
      ivOutput = @iv[0] if @iv.none? { |i| i != @iv[0] }
      ivOutput = 32 if @iv == [31, 31, 31, 31, 31, 0]
      output += "  :iv => #{ivOutput},\n"
      output += "  :moves => ["
      for m in 0..3
        output += @moves[m] ? @moves[m].move.inspect : "nil"
        output += ", " unless m == 3
      end
      output += "],\n"
      output += "  :hptype => #{@hptype.inspect},\n" if @hptype
      output += "  :shiny => true,\n" if self.isShiny?
      output += "  :shadow => true,\n" if self.isShadow?
      output += "  :aura => #{@aura.inspect},\n" if @aura
      if snapshot
        output += "  :starthp => #{@hp}" if @hp < @totalhp
        output += "  :status => #{@status.inspect},\n" if @status
        output += "  :statusCount => #{@statusCount.inspect},\n" if @statusCount > 0
        output += "  :disguise => #{@disguise}\n" if @disguise
      end
      if flavor
        output += "  :ball => #{@ballused.inspect}\n" if @ballused
        output += "  :slidein => #{@slidein.inspect}\n" if @slidein
        output += "  :trainerID => #{@trainerID.inspect},\n"
        output += "  :catchtext => #{@obtainText.inspect},\n" if @obtainText
        output += "  :obtaintype => #{@obtainMode.inspect},\n"
        output += "  :catchlevel => #{@obtainLevel.inspect},\n"
        output += "  :catchmap => #{@obtainMap.inspect},\n"
        output += "  :catchtime => #{getArrayFromTime(@timeReceived).inspect},\n"
        output += "  :hatchmap => #{@hatchedMap.inspect}\n" if @hatchedMap != 0
        output += "  :hatchtime => #{getArrayFromTime(@timeEggHatched).inspect}\n" if @timeEggHatched
        output += "  :originalTrainer => #{@ot.inspect},\n"
        output += "  :hiddenID => #{@personalID.to_s},\n"
      end
      output += "}"
    end
  end

  class PokemonBuilder
    attr_accessor :pokemon
    attr_accessor :trainer
    attr_accessor :trainertype
    attr_accessor :bossdata
    attr_accessor :bossid
    attr_accessor :hasLevelCap
    attr_accessor :source
    attr_accessor :isEnemy
    attr_accessor :isNPC

    def initialize(poke, trainer = $Trainer, trainertype = nil, bossdata: $cache.bosses, test: false, hasLevelCap: false, source: nil)
      @trainertype = trainertype
      @bossdata = bossdata
      @hasLevelCap = hasLevelCap
      @source = source
      @isEnemy = [:trainer, :sos, :boss].include?(@source)
      @isNPC = @isEnemy || [:ally].include?(@source)
      @test = test
      if poke.is_a?(Symbol)
        key = $cache.pkmn.key?(poke) ? :species : :boss
        poke = [[key, poke]].to_h
      end
      return nil if !poke || !poke.is_a?(Hash)
      @trainer = poke.fetch(:originalTrainer, trainer)
      @trainer = knownTrainer(@trainer, @trainertype) if @trainer.is_a?(String)
      @trainertype ||= @trainer.trainertype if !@trainer.trainertype.nil?

      self.pokemon = poke
    end

    def pokemon=(poke)
      if poke.is_a?(PokeBattle_Pokemon)
        @pokemon = poke
        return
      end
      if !poke.is_a?(Hash)
        puts "Error: Supplied value `#{args[0].class}` is not a `PokeBattle_Pokemon` or valid Hash."
        return
      end
      boss = @bossdata.dig(poke[:boss])
      @bossid = poke[:boss]
      if boss.is_a?(Hash) # Loaded from Debug Trainer/Boss
        boss = BossData.new(@bossid, boss)
        @bossdata[@bossid] = boss
      end
      poke = boss.moninfo if boss
      species = poke[:species]
      level = @test ? poke.fetch(:level, 100) : poke.fetch(:level, 10)
      form = poke.fetch(:form, 0)
      form = $cache.pkmn[species].forms.invert[form] if form.is_a?(String)
      chess_exists = FieldIDToSym.values.include?(:CHESS) # Ensuring Chess Pieces remain consistent even with IV/EV passwords

      @pokemon = PokeBattle_Pokemon.new(species, level, @trainer, !@isNPC, form)
      bossFunction(boss, @bossid, @pokemon) if boss
      @pokemon.setItem(poke[:item])
      # Ability needs to be set before getForm is called so as to not revert dev team Silvally forms with non-RKS System abilities and such
      @pokemon.setAbility(poke.fetch(:ability, @isNPC ? 0 : @pokemon.ability))
      @pokemon.form = form if form != 0 # Fix for dev pre-mega forms
      @pokemon.form = @pokemon.getForm
      if poke[:moves]
        @pokemon.moves.delete_if { |move| poke[:moves].include?(move.move) }
        if @isNPC
          k = 0
          for move in poke[:moves]
            next if move.nil?
            @pokemon.moves[k] = PBMove.new(move)
            if level >= 100 && @trainer.skill >= PokeBattle_AI::BESTSKILL
              @pokemon.moves[k].ppup = 3
              @pokemon.moves[k].pp = @pokemon.moves[k].totalpp
            end
            k += 1
          end
        else
          moves = @pokemon.moves + poke[:moves].map { |move| move.nil? ? nil : PBMove.new(move) }
          @pokemon.moves = moves.last(4)
        end
      else
        @pokemon.resetMoves
      end
      @pokemon.moves.compact!
      @pokemon.initZmoves(false)
      if poke[:shadow] # if this is a Shadow Pokémon
        @pokemon.makeShadow
        @pokemon.pbUpdateShadowMoves(true)
      end
      case poke[:gender]
        when :M then @pokemon.makeMale
        when :F then @pokemon.makeFemale
        when :N then @pokemon.makeGenderless
      end
      if !poke[:shiny].nil?
        @pokemon.shinyflag = poke[:shiny]
      else
        @pokemon.makeNotShiny if @isNPC && !boss&.capturable
      end
      @pokemon.setNature(poke.fetch(:nature, @isNPC ? :HARDY : @pokemon.nature))
      applyIVs(poke[:iv])
      applyEVs(poke[:ev])
      if chess_exists
        @pokemon.calcStats
        backupstats = @pokemon.getStats
      end
      applyPasswords()
      @pokemon.calcStats
      if chess_exists
        newstats = @pokemon.getStats
        @pokemon.backupstats = backupstats if newstats != backupstats
      end
      hp = @pokemon.totalhp
      if poke[:starthp] # pre-damaging (needs to be done after calcStats)
        hp = (@pokemon.totalhp * poke[:starthp]).floor if poke[:starthp].is_a?(Float)
        hp = poke[:starthp] if poke[:starthp].is_a?(Integer)
        hp = @pokemon.totalhp if hp > @pokemon.totalhp
      end
      @pokemon.hp = hp
      @pokemon.status = poke[:status] if poke[:status] # pre-statusing
      @pokemon.statusCount = poke[:statusCount] if poke[:statusCount] && poke[:status] == :SLEEP
      @pokemon.happiness = poke.fetch(:happiness, 70)
      @pokemon.name = poke[:name] if poke[:name]
      @customBall = poke.key?(:ball)
      @pokemon.ballused = poke.fetch(:ball, $cache.trainertypes[@trainertype]&.ball || :POKEBALL)
      @pokemon.slidein = poke.fetch(:slidein, false)
      @pokemon.trainerID = poke[:trainerID] if poke[:trainerID]
      @pokemon.hptype = poke[:hptype] if poke[:hptype]
      @pokemon.aura = poke[:aura] if poke[:aura]
      @pokemon.obtainText = poke[:catchtext] if poke[:catchtext]
      @pokemon.obtainMode = poke[:obtaintype] if poke[:obtaintype]
      @pokemon.obtainLevel = poke[:catchlevel] if poke[:catchlevel]
      @pokemon.obtainMap = poke[:catchmap] if poke[:catchmap]
      timediverge = $Settings.unrealTimeDiverge
      $Settings.unrealTimeDiverge = 0
      @pokemon.timeReceived = getTimeFromArray(poke[:catchtime]) if poke[:catchtime]
      @pokemon.hatchedMap = poke[:hatchmap] if poke[:hatchmap]
      @pokemon.timeEggHatched = getTimeFromArray(poke[:hatchtime]) if poke[:hatchtime]
      $Settings.unrealTimeDiverge = timediverge
      @pokemon.ot = poke[:originalTrainer] if poke[:originalTrainer]
      @pokemon.personalID = @pokemon.personalID.to_s if poke[:hiddenID]

      return unless Rejuv

      @pokemon.catchRate = poke[:catchRate] if poke[:catchRate]
      @pokemon.naturetext = poke[:naturetext] if poke[:naturetext]
      @pokemon.obtainExtra = poke[:obtainExtra] if poke[:obtainExtra]
      if poke[:flickerID]
        @pokemon.flickerID = {
          :interval => poke[:flickerID][:interval] || 1,
          :IDlist => poke[:flickerID][:IDlist],
          :weight => poke[:flickerID][:weight] || 1,
          :timer => 0,
          :display => @pokemon.publicID,
        }
      end
      if poke[:flickerLocation]
        @pokemon.flickerLocation = {
          :interval => poke[:flickerLocation][:interval] || 1,
          :IDlist => poke[:flickerLocation][:Locationlist],
          :weight => poke[:flickerLocation][:weight] || 1,
          :timer => 0,
          :display => @pokemon.obtainText || pbGetMapNameFromId(@pokemon.obtainMap),
        }
      end
      @pokemon.disguise = PokeBattle_Pokemon::PokemonBuilder.new(poke[:disguise], source: @source).build if poke[:disguise]
      @pokemon.disobedient = poke[:disobedient]
    end

    def applyIVs(iv)
      if !@isNPC
        return if iv.nil?
        return if $game_switches[:Full_IVs] || $game_switches[:Empty_IVs_Password]
      end
      iv = iv.dup if iv.is_a?(Array)
      iv = @test ? 31 : 10 if iv.nil?
      if iv == 32 # Trick room IVs
        @trickRoom = true
        iv = Array.new(6, 31)
        iv[5] = 0
      end
      iv = Array.new(6, iv) if iv.is_a?(Numeric)
      @pokemon.iv = iv
    end

    def applyEVs(ev)
      return if ev.nil? && !@isNPC
      ev = ev.dup if ev.is_a?(Array)
      ev = Array.new(6, ev) if ev.is_a?(Numeric)
      evdefault = @test ? 0 : [85, level * 3 / 2].min
      ev = Array.new(6, evdefault) if !ev
      ev[PBStats::SPEED] = 0 if @trickRoom
      @pokemon.ev = ev
    end

    def applyPasswords
      # Apply passwords related to non-player sourced Pokemon
      return unless @isNPC

      # If the boss is intended to be capturable or the Pokemon is snaggable
      canCatch = @bossdata[@bossid]&.capturable || (@pokemon.isShadow? && $PokemonGlobal.snagMachine)
      iv = @pokemon.iv
      evs = @pokemon.ev

      # Shadow pokemon can be snagged/bosses can be captured, so don't give them EV changes unless player password is on too
      evs = Array.new(6, 85) if $game_switches[:Flat_EV_Password] && !canCatch
      evs = Array.new(6, 0) if $game_switches[:Empty_EVs_Password] && !canCatch

      if @isEnemy
        # Apply enemy-specific passwords

        # Shadow pokemon can be snagged/bosses can be captured, so don't give them IV changes unless player password is on too
        iv = Array.new(6, 0) if ($game_switches[:Empty_Trainer_IVs_Password] && !canCatch) || (canCatch && $game_switches[:Empty_IVs_Password])
        iv = Array.new(6, 31) if ($game_switches[:Max_Trainer_IVs_Password] && !canCatch) || (canCatch && $game_switches[:Full_IVs])

        if Desolation && $game_switches[:SimulatorBattle]
          # Still needs to overwrite levels during sim battles
          @pokemon.level = LEVELCAPS[$Trainer.numbadges]
        end

        if !$game_switches[:NotPlayerCharacter] || $game_switches[:InterceptorsWish]
          # We bypass these specific passwords during NPC segments to standardize intended difficulty
          unless @hasLevelCap
            @pokemon.level = getPasswordModifiedLevel(@pokemon.level)
          end

          if $game_switches[:AutoMinMax_Password]
            cap = [9 * @pokemon.level, 504].min
            if evs.sum < cap || (evs.uniq.size == 1 && evs.sum <= 510)
              evs, nature = autoMinMaxEVAssignment(@pokemon)
              @pokemon.setNature(nature)
            end
          end

          # PULSE2 should only not be applied when the Pokemon is catchable (boss/shadow) or
          # in specific scenarios (see `isPulse2Allowed?`)
          evs = Array.new(6, 252) if $game_switches[:Only_Pulse_2] && !canCatch && isPulse2Allowed?()
        end
      else
        # Apply player-affecting passwords to ally NPC sourced Pokemon
        iv = Array.new(6, 31) if $game_switches[:Full_IVs]
        iv = Array.new(6, 0) if $game_switches[:Empty_IVs_Password]
      end

      # Always ensure 0 speed EV/IV for trick room sets
      evs[PBStats::SPEED] = 0 if @trickRoom
      iv[PBStats::SPEED] = 0 if @trickRoom

      # Apply any 'illegal' EV values from set definition
      for i in 0...6
        evs[i] = @pokemon.ev[i] if @pokemon.ev[i] > 252
      end

      @pokemon.iv = iv
      @pokemon.ev = evs
    end

    def trainer=(value)
      value = knownTrainer(value, @trainertype) if value.is_a?(String)
      return if !value.is_a?(PokeBattle_Trainer)
      @trainer = value
      @pokemon.trainerID = @trainer.id
      @pokemon.ot = @trainer.name
      @pokemon.language = @trainer.language
      self.trainertype ||= @trainer.trainertype if !@trainer.trainertype.nil?
    end

    def trainertype=(value)
      return if !value.is_a?(Symbol)
      @trainertype = value
      @pokemon.ballused = $cache.trainertypes[@trainertype]&.ball || @pokemon.ballused unless @customBall
    end

    def bossdata=(value)
      return if !@bossid
      return if !value.is_a?(Hash)
      if !value.key?(@bossid)
        puts "Error: Supplied boss data no longer includes data for boss: #{@bossid}."
        return
      end
      @bossdata = value
      self.pokemon = {boss: @bossid}
    end

    def bossid=(value)
      if !@bossdata.key?(value)
        puts "Error: Boss data does not include data for boss: #{value}."
        return
      end
      self.pokemon = {boss: value}
    end

    def build
      return @pokemon
    end

    def method_missing(method, *args, &block)
      if @pokemon.respond_to?(method)
        @pokemon.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      @pokemon.respond_to?(method) || super
    end
  end
end

# for verification and also for dumpTeams (order matters for dumpTeams)
PokemonBuilderHashKeys = [
  :boss, :species, :form, :level, :item, :ability, :moves, :hptype, :happiness, :nature, :iv, :ev,
  :gender, :name, :shadow, :shiny, :ball, :slidein, :aura, :starthp, :status, :statusCount,
  # rejuv stuff
  :disguise, :disobedient, :relearnall,
  # flavor data
  :obtaintype, :originalTrainer, :trainerID, :hiddenID, :catchlevel, :catchmap, :catchtext, :catchtime,
  :hatchmap, :hatchtime,
  # rejuv-specific flavor data
  :flickerID, :flickerLocation, :obtainExtra, :naturetext, :fakeOT,
]

# gotta put this somewhere!!!!!!!!!!!!!!!
def drawSpot(bitmap, spotpattern, x, y, red, green, blue)
  height = spotpattern.length
  width = spotpattern[0].length
  for yy in 0...height
    spot = spotpattern[yy]
    for xx in 0...width
      if spot[xx] == 1
        xOrg = (x + xx) << 1
        yOrg = (y + yy) << 1
        color = bitmap.get_pixel(xOrg, yOrg)
        r = color.red + red
        g = color.green + green
        b = color.blue + blue
        color.red = [[r, 0].max, 255].min
        color.green = [[g, 0].max, 255].min
        color.blue = [[b, 0].max, 255].min
        bitmap.set_pixel(xOrg, yOrg, color)
        bitmap.set_pixel(xOrg + 1, yOrg, color)
        bitmap.set_pixel(xOrg, yOrg + 1, color)
        bitmap.set_pixel(xOrg + 1, yOrg + 1, color)
      end
    end
  end
end

def pbSpindaSpots(pokemon, bitmap)
  spot1 = [
    [0, 0, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 0, 0],
  ]
  spot2 = [
    [0, 0, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 0, 0],
  ]
  spot3 = [
    [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0],
  ]
  spot4 = [
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0],
  ]
  id = pokemon.personalID
  h = (id >> 28) & 15
  g = (id >> 24) & 15
  f = (id >> 20) & 15
  e = (id >> 16) & 15
  d = (id >> 12) & 15
  c = (id >> 8) & 15
  b = (id >> 4) & 15
  a = (id) & 15
  if pokemon.isShiny?
    drawSpot(bitmap, spot1, b + 43, a + 35, -120, -120, -20)
    drawSpot(bitmap, spot2, d + 31, c + 34, -120, -120, -20)
    drawSpot(bitmap, spot3, f + 49, e + 17, -120, -120, -20)
    drawSpot(bitmap, spot4, h + 25, g + 16, -120, -120, -20)
  else
    drawSpot(bitmap, spot1, b + 43, a + 35, 0, -115, -75)
    drawSpot(bitmap, spot2, d + 31, c + 34, 0, -115, -75)
    drawSpot(bitmap, spot3, f + 49, e + 17, 0, -115, -75)
    drawSpot(bitmap, spot4, h + 25, g + 16, 0, -115, -75)
  end
end

def pbModifyPokemonSprite(pokemon, bitmap)
  if pokemon.status == :PETRIFIED
    bitmap = makeGrayscaleBitmap(bitmap, bitmap.width, bitmap.height)
  elsif pokemon.isShadow? && !hasShadowSprite?(pokemon.species, pokemon.form)
    bitmap = makeShadowBitmap(bitmap, bitmap.width, bitmap.height)
  elsif Rejuv && (pokemon.item == :BLKPRISM || (pokemon.ability == :PRISMPOWER && pokemon.prismPower == true))
    bitmap = makePrismBitmap(bitmap, bitmap.width, bitmap.height)
  elsif pokemon.aura
    auraColors = AuraTypeToColor[pokemon.aura]
    bitmap = makeAuraBitmap(bitmap, bitmap.width, bitmap.height, *auraColors, 1000)
  end
  return bitmap
end

def getListOfSpecies
  arr = []
  $cache.pkmn.each { |symbol, dat|
    arr.push(dat.name)
  }
  return arr
end

def pbBaseStatTotal(species, form)
  return $cache.pkmn[species, form].BaseStats.sum
end

def getHPZone(hp, totalhp)
  hpzone = 0
  hpzone = 1 if hp <= (totalhp * (PBScene::HPGAUGE_YEL / 100.0)).floor
  hpzone = 2 if hp <= (totalhp * (PBScene::HPGAUGE_RED / 100.0)).floor
  return hpzone
end

def getPasswordModifiedLevel(level)
  # levelfloor password
  if $game_switches[:Level_Floor_Password] && $Trainer.numbadges > 0 && level != 1
    # Apply password only after player has a badge, ignore F.E.A.R. Pokemon
    # If the Pokemon's level is less than the previous non-postgame level cap (caps at 95), plus the extended maximum level from the postgame,
    # then it is increased to equal that
    targetlevel = LEVELCAPS[$Trainer.numbadges - 1] + $game_variables[:Extended_Max_Level]
    level = targetlevel if level < targetlevel
  end
  # leveloffset password
  if $game_switches[:Offset_Trainer_Levels]
    if $game_variables[:Level_Offset_Value] < 0
      level = [level + $game_variables[:Level_Offset_Value], 1].max
    else
      level += $game_variables[:Level_Offset_Value]
    end
  end
  # percentlevel password
  if $game_switches[:Percent_Trainer_Levels]
    if $game_variables[:Level_Offset_Percent] < 100
      level = [(level * $game_variables[:Level_Offset_Percent] * 0.01).round, 1].max
    else
      level *= ($game_variables[:Level_Offset_Percent] * 0.01)
    end
  end
  return level
end

# moves that are learned by almost all pokemon via TM/Tutor
# ones not learned by a pokemon should be present in its exceptionlist
def getUniversalTMs()
  moves = [
    :ATTRACT, :CONFIDE, :DOUBLETEAM, :ENDURE, :FACADE, :FRUSTRATION, :HIDDENPOWER,
    :PROTECT, :REST, :RETURN, :ROUND, :SECRETPOWER, :SLEEPTALK, :SNORE, :SUBSTITUTE, :SWAGGER,
  ]
  moves.push(:TOXIC) if Gen < 8
  return moves
end

def getPlayerMaxEVs()
  return $game_switches && $game_switches[:No_Total_EV_Cap] ? 1512 : 510
end

def pbCatchTime
  return pbGetTimeNow.getgm.to_i # Use GMT
end

def isPulse2Allowed?; true; end

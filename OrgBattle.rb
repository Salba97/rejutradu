#===============================================================================
# General purpose utilities
#===============================================================================
class Array
  def shuffle
    dup.shuffle!
  end unless method_defined? :shuffle

  def ^(other) # xor of two arrays
    return (self | other) - (self & other)
  end

  def shuffle!
    size.times do |i|
      r = Kernel.rand(size)
      self[i], self[r] = self[r], self[i]
    end
    self
  end unless method_defined? :shuffle!
end

module Enumerable
  def transform
    ret = []
    self.each() { |item| ret.push(yield(item)) }
    return ret
  end
end

#===============================================================================
# Pokémon Organized Battle
#===============================================================================
def pbHasEligible?(*arg)
  return pbBattleChallenge.rules.ruleset.hasValidTeam?($Trainer.party)
end

class BTPokemon
  def self.fromPokemon(pokemon)
    # print "fromPokemon"
    return self.new(pokemon.species, pokemon.item, pokemon.nature, pokemon.moves, pokemon.evs, pokemon.form, pokemon.ability, pokemon.gender)
  end

  def self.fromDOH(data)
    return self.new(data[:species], data[:item], data[:nature], data[:moves], data[:evs], data[:form], data[:ability], data[:gender])
  end

  def createPokemon(level, iv, trainer)
    pokemon = PokeBattle_Pokemon.new(@species, level, trainer, false)
    pokemon.setGender(@gender) if @gender
    pokemon.setItem(@item)
    pokemon.personalID = rand(65536)
    pokemon.personalID |= rand(65536) << 8
    pokemon.personalID -= pokemon.personalID % 25
    pokemon.personalID += $cache.natures.keys.index(nature)
    pokemon.personalID &= 0xFFFFFFFF
    pokemon.happiness = 0
    pokemon.happiness = 255 if @moves.include?(:RETURN)
    pokemon.moves = @moves.map { |move| PBMove.new(move) }
    pokemon.form = @form # I hate necrozma and don't want to deal with it anymore in a clean way so this is what you get
    pokemon.moves = @moves.map { |move| PBMove.new(move) } # hi cass I don't know what's going on here but I'm going to leave it.
    pokemon.form = pokemon.getForm # also screw you necrozma too this is probably your fault
    pokemon.hptype = @hptype
    for i in 0...6
      pokemon.iv[i] = iv
      pokemon.ev[i] = @ev[i]
    end
    pokemon.ability = @ability
    pokemon.setNature(@nature)
    pokemon.calcStats
    return pokemon
  end

  def to_s
    ret = "{ "
    ret += "species: #{@species.inspect}, "
    ret += "item: #{@item.inspect}, "
    ret += "nature: #{@nature.inspect}, " if @nature != nil
    moves = [@move1, @move2, @move3, @move4].compact
    ret += "moves: #{moves.inspect}, "
    ret += "ev: #{@ev.inspect}, " if !@ev.empty?
    ret += "form: #{@form}, " if @form != 0
    ret += "gender: #{@gender.inspect}, " if @gender
    ret += "ability: #{@ability.inspect}, "
    ret += "hptype: #{@hptype.inspect}, " if @hptype != nil
    ret += "},\n"
    return ret
  end

  def inspect; self.to_s; end
end

def pbGetBTTrainers(challengeID)
  trlists = (load_data("Data/trainerlists.dat") rescue [])
  for i in 0...trlists.length
    tr = trlists[i]
    if !tr[5] && tr[2].include?(challengeID)
      return tr[0]
    end
  end
  for i in 0...trlists.length
    tr = trlists[i]
    if tr[5] # is default list
      return tr[0]
    end
  end
  return []
end

def pbGetBTPokemon(challengeID)
  trlists = (load_data("Data/trainerlists.dat") rescue [])
  for tr in trlists
    if !tr[5] && tr[2].include?(challengeID)
      return tr[1]
    end
  end
  for tr in trlists
    if tr[5] # is default list
      return tr[1]
    end
  end
  return []
end

class Game_Map
  attr_accessor :map_id
end

class Game_Player
  attr_accessor :direction

  def moveto2(x, y)
    @x = x
    @y = y
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
end

class BattleChallengeType
  attr_accessor :currentWins
  attr_accessor :previousWins
  attr_accessor :maxWins
  attr_accessor :currentSwaps
  attr_accessor :previousSwaps
  attr_accessor :maxSwaps
  attr_reader :doublebattle
  attr_reader :numPokemon
  attr_reader :battletype
  attr_reader :mode

  def initialize
    @previousWins = 0
    @maxWins = 0
    @currentWins = 0
    @currentSwaps = 0
    @previousSwaps = 0
    @maxSwaps = 0
  end

  def saveWins(challenge)
    if challenge.decision != 0 # if won or lost
      if challenge.decision == 1 # if won
        @currentWins = challenge.wins
        @currentSwaps = challenge.swaps
      else
        @currentWins = 0
        @currentSwaps = 0
      end
      @maxWins = [@maxWins, challenge.wins].max
      @previousWins = challenge.wins
      @maxSwaps = [@maxSwaps, challenge.swaps].max
      @previousSwaps = challenge.swaps
    else # if undecided
      @currentWins = 0
      @currentSwaps = 0
    end
  end
end

class BattleChallengeData
  attr_reader :resting
  attr_reader :wins
  attr_reader :swaps
  attr_reader :inProgress
  attr_reader :battleNumber
  attr_reader :numRounds
  attr_accessor :decision
  attr_reader :party
  attr_reader :oldParty
  attr_reader :extraData
  attr_reader :stylechallenge # added

  def setExtraData(value)
    @extraData = value
  end

  def pbAddWin
    if @inProgress
      @battleNumber += 1
      @wins += 1
    end
  end

  def pbAddSwap
    if @inProgress
      @swaps += 1
    end
  end

  def pbMatchOver?
    return true if !@inProgress
    return true if @decision != 0

    return @battleNumber > @numRounds
  end

  def initialize
    reset
  end

  def nextTrainer
    return @trainers[@battleNumber - 1]
  end

  def pbGoToStart
    if $scene.is_a?(Scene_Map)
      $game_temp.player_transferring = true
      $game_temp.player_new_map_id = @start[0]
      $game_temp.player_new_x = @start[1]
      $game_temp.player_new_y = @start[2]
      $game_temp.player_new_direction = 8
      $scene.transfer_player
    end
  end

  def setParty(value)
    if @inProgress
      $Trainer.party = value
      @party = value
    else
      @party = value
    end
  end

  def pbStart(t, numRounds)
    @inProgress = true
    @resting = false
    @decision = 0
    @stylechallenge = 0
    @swaps = t.currentSwaps
    @wins = t.currentWins
    @battleNumber = 1
    @trainers = []
    raise _INTL("Number of rounds is 0 or less.") if numRounds <= 0

    @numRounds = numRounds
    btTrainers = $cache.bttrainers
    while @trainers.length < @numRounds
      newtrainer = pbBattleChallengeTrainer(@wins + @trainers.length, btTrainers)
      found = false
      for tr in @trainers
        found = true if tr == newtrainer
      end
      @trainers.push(newtrainer) if !found
    end
    @start = [$game_map.map_id, $game_player.x, $game_player.y]
    @oldParty = $Trainer.party
    $Trainer.party = @party if @party
    pbSave
  end

  def pbfieldeffect(styles, doubles) # added this for different type of challenges
    @doublebattlefact = doubles
    @stylechallenge = styles
  end

  def doublebattlefact; @doublebattlefact; end

  # style 0 = no field, style 1 = random every battle, style 2 is same for whole match (5 battles)
  def whatfieldeffect # gives information depending on round and style
    if @stylechallenge == 1 || @stylechallenge == 2
      if @stylechallenge == 1 || (@stylechallenge == 2 && @battleNumber == 1)
        $game_variables[:Forced_Field_Effect] = pbRandomField
        $game_variables[:Factory_Field_Persister] = $game_variables[:Forced_Field_Effect] if @stylechallenge == 2
      else
        $game_variables[:Forced_Field_Effect] = $game_variables[:Factory_Field_Persister] if $game_variables[:Factory_Field_Persister].is_a?(Symbol)
      end
      case $game_variables[:Forced_Field_Effect]
        when :INDOOR
          return _INTL("The battle will take place with no field.")
        when :DARKCRYSTALCAVERN, :CAVE, :CRYSTALCAVERN
          return _INTL("The battle will take place in the {1}.", getFieldName($game_variables[:Forced_Field_Effect]))
        when :UNDERWATER
          return _INTL("The battle will take place {1}.", getFieldName($game_variables[:Forced_Field_Effect]))
        else
          return _INTL("The battle will take place on the {1}.", getFieldName($game_variables[:Forced_Field_Effect]))
      end
    elsif @stylechallenge == 0
      # "placeholder no field no life"
      if @doublebattlefact
        case @battleNumber
          when 1
            # tell name all pokemon
            chosenspoilers = (0..3).to_a.shuffle[0..3]
            mons = chosenspoilers.map do |index|
              pokemon = @opponentnew.party[index]
              next getMonName(pokemon.species, pokemon.form)
            end
            return _INTL("The Pokémon you'll be battling are {1}, {2}, {3}, and {4}.", *mons)
          when 2
            # tell 2 of the pokemon name, at random
            chosenspoilers = (0..3).to_a.shuffle[0..1]
            mons = chosenspoilers.map do |index|
              pokemon = @opponentnew.party[index]
              next getMonName(pokemon.species, pokemon.form)
            end
            return _INTL("Two of the four Pokémon you'll be facing are {1} and {2}.", *mons)
          when 3
            # tell name lead pokemon
            pokemon = @opponentnew.party[0]
            return _INTL("One of the leading Pokémon is {1}.", getMonName(pokemon.species, pokemon.form))
          # when 4
          #   #tell one of leading's pokemon move
          #   "One of the leading Pokémon's moves is " + getMoveName(@opponentnew.party[rand(1)].moves[rand(3)].id).to_s
          # when 5
          #   #supposedly, the most common type, did item instead
          #   "One of the leading Pokémon will be holding the " + getItemName(@opponentnew.party[rand(1)].item).to_s
          when 4
            # supposedly, the most common type, did random type instead
            return _INTL("One of the Pokémon has the {1} type.", getTypeName(@opponentnew.party.sample.type1))
          when 5
            # supposedly, the most common type, did nothing instead
            return _INTL("There is no information on your last opponent.")
        end
      else
        case @battleNumber
          when 1
            # tell name all pokemon
            chosenspoilers = (0..2).to_a.shuffle[0..2]
            mons = chosenspoilers.map do |index|
              pokemon = @opponentnew.party[index]
              next getMonName(pokemon.species, pokemon.form)
            end
            return _INTL("The Pokémon you'll be battling are {1}, {2}, and {3}.", *mons)
          when 2
            # tell 2 of the pokemon name, at random
            chosenspoilers = (0..3).to_a.shuffle[0..1]
            mons = chosenspoilers .map do |index|
              pokemon = @opponentnew.party[index]
              next getMonName(pokemon.species, pokemon.form)
            end
            return _INTL("Two of the three Pokémon you'll be facing are {1} and {2}.", *mons)
          when 3
            # tell name lead Pokémon
            pokemon = @opponentnew.party[0]
            return _INTL("The leading Pokémon is {1}.", getMonName(pokemon.species, pokemon.form))
          #  when 4
          #    #tell one of leading's Pokémon move, not sure if Pokémons or Pokémon's is correct grammatical form
          #    "One of the leading Pokémons move is " + getMoveName(@opponentnew.party[0].moves[rand(3)].id).to_s
          #  when 5
          #    #supposedly, the most common type, did item instead
          #    "The leading Pokémon will be holding the " + getItemName(@opponentnew.party[0].item).to_s
          when 4
            # supposedly, the most common type, did random type instead
            return _INTL("One of the Pokémon has the {1} type.", getTypeName(@opponentnew.party.sample.type1))
          when 5
            # supposedly, the most common type, did nothing instead
            return _INTL("There is no information on your last opponent.")
        end
      end
    else
      return _INTL("There is no information on your next opponent.")
    end
  end

  def pbCancel
    $Trainer.party = @oldParty if @oldParty
    reset
  end

  attr_accessor :oldopponent
  attr_accessor :opponentnew

  def pbEnd
    $Trainer.party = @oldParty if @oldParty
    $game_variables[:Forced_Field_Effect] = 0 # resetting variables
    @oldopponent = nil
    $rentalnew = nil
    return if !@inProgress

    save = (@decision != 0)
    reset
    $game_map.need_refresh = true
    pbSave if save
  end

  def pbGoOn
    return if !@inProgress

    @resting = false
    pbSaveInProgress # dunno yet if I want the game to save everytime you win
  end

  def pbRest
    return if !@inProgress

    @resting = true
    if $game_switches
      $game_switches[:Battle_Tower_Doors] = false
    end
    pbSaveInProgress
  end

  private

  def reset
    @inProgress = false
    @resting = false
    @start = nil
    @decision = 0
    @wins = 0
    @swaps = 0
    @battleNumber = 0
    @trainers = []
    @oldParty = nil
    @party = nil
    @extraData = nil
    @stylechallenge = 0
  end

  def pbSaveInProgress
    oldmapid = $game_map.map_id
    oldx = $game_player.x
    oldy = $game_player.y
    olddirection = $game_player.direction
    $game_map.map_id = @start[0]
    $game_player.moveto2(@start[1], @start[2])
    $game_player.direction = 8 # facing up
    pbSave # dunno yet if I want the game to save everytime you win
    $game_map.map_id = oldmapid
    $game_player.moveto2(oldx, oldy)
    $game_player.direction = olddirection
  end
end

class BattleChallenge
  attr_reader :currentChallenge
  attr_reader :bc

  BattleTower   = 0
  BattlePalace  = 1
  BattleArena   = 2
  BattleFactory = 3

  def initialize
    @bc = BattleChallengeData.new
    @currentChallenge = -1
    @types = {}
  end

  def rules
    if !@rules
      @rules = modeToRules(
        self.data.doublebattle,
        self.data.numPokemon,
        self.data.battletype, self.data.mode
      )
    end
    return @rules
  end

  def modeToRules(doublebattle, numPokemon, battletype, mode)
    rules = PokemonChallengeRules.new
    if battletype == BattlePalace
      rules.setBattleType(BattlePalace.new)
    elsif battletype == BattleArena
      rules.setBattleType(BattleArena.new)
      doublebattle = false
    else
      rules.setBattleType(BattleTower.new)
    end
    if mode == 1 # Open Level
      rules.setRuleset(StandardRules(numPokemon, MAXIMUMLEVEL))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(30))
    elsif mode == 2 # Battle Tent
      rules.setRuleset(StandardRules(numPokemon, MAXIMUMLEVEL))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(60))
    else
      rules.setRuleset(StandardRules(numPokemon, 50))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(50))
    end
    if doublebattle
      rules.addBattleRule(DoubleBattle.new)
    else
      rules.addBattleRule(SingleBattle.new)
    end
    return rules
  end

  def set(id, numrounds, rules)
    @rules = rules
    @id = id
    @numRounds = numrounds
    pbWriteCup(id, rules)
  end

  def start(*args)
    t = ensureType(@id)
    @currentChallenge = @id # must appear before pbStart
    @bc.pbStart(t, @numRounds)
  end

  def register(id, doublebattle, numrounds, numPokemon, battletype, mode = 1)
    t = ensureType(id)
    if battletype == BattleFactory
      @bc.setExtraData(BattleFactoryData.new(@bc))
      numPokemon = 3
      battletype = BattleTower
    end
    t.numRounds = numrounds
    @rules = modeToRules(doublebattle, numPokemon, battletype, mode)
  end

  def pbInChallenge?
    return pbInProgress?
  end

  def data
    return nil if !pbInProgress? || @currentChallenge < 0

    return ensureType(@currentChallenge).clone
  end

  def getCurrentWins(challenge)
    return ensureType(challenge).currentWins
  end

  # print pbBattleChallenge.getCurrentWins(pbBattleChallenge)
  def getPreviousWins(challenge)
    return ensureType(challenge).previousWins
  end

  def getMaxWins(challenge)
    return ensureType(challenge).maxWins
  end

  def getCurrentSwaps(challenge)
    return ensureType(challenge).currentSwaps
  end

  def getPreviousSwaps(challenge)
    return ensureType(challenge).previousSwaps
  end

  def getMaxSwaps(challenge)
    return ensureType(challenge).maxSwaps
  end

  def pbStart(challenge)
  end

  def pbEnd
    if @currentChallenge != -1
      ensureType(@currentChallenge).saveWins(@bc)
      @currentChallenge = -1
    end
    @bc.pbEnd
  end

  def pbBattle
    # make opponent based on what challange the player chose
    if @currentChallenge == "factorysingleopen" || @currentChallenge == "factorydoubleopen"
      opponent = @bc.opponentnew
    else
      opponent = pbGenerateBattleTrainer(self.nextTrainer, self.rules)
    end
    bttrainers = $cache.bttrainers
    trainerdata = bttrainers[self.nextTrainer]
    return pbOrganizedBattleEx(
      opponent,
      self.rules,
      pbGetMessageFromHash(:BattleTowerLoseSpeech, trainerdata.loseSpeech),
      pbGetMessageFromHash(:BattleTowerWinSpeech, trainerdata.winSpeech),
    )
  end

  def pbInProgress?
    return @bc.inProgress
  end

  def pbResting?
    return @bc.resting
  end

  def pbIsDoublesResting? # needed because otherwise wrong guy would walk when restarting
    return @bc.doublebattlefact
  end

  def doublebattlefact; @bc.doublebattlefact; end

  def setDecision(value)
    @bc.decision = value
  end

  def setParty(value)
    @bc.setParty(value)
  end

  def extra
    @bc.setExtraData(BattleFactoryData.new(@bc))
  end

  def decision; @bc.decision; end
  def wins; @bc.wins; end
  def swaps; @bc.swaps; end
  def battleNumber; @bc.battleNumber; end
  def nextTrainer; @bc.nextTrainer; end
  def stylechallenge; @bc.stylechallenge; end
  def pbGoOn; @bc.pbGoOn; end
  def pbAddWin; @bc.pbAddWin; end
  def pbCancel; @bc.pbCancel; end
  def pbRest; @bc.pbRest; end
  def pbMatchOver?; @bc.pbMatchOver?; end
  def pbGoToStart; @bc.pbGoToStart; end
  def pbfieldeffect(styles, doubles); @bc.pbfieldeffect(styles, doubles); end
  def whatfieldeffect; @bc.whatfieldeffect; end


  private

  def ensureType(id)
    if @types.is_a?(Array)
      oldtypes = @types
      @types = {}
      for i in 0...oldtypes.length
        if oldtypes[i]
          @types[i] = oldtypes[i]
        end
      end
    end
    if !@types[id]
      @types[id] = BattleChallengeType.new
    end
    return @types[id]
  end
end

def pbRecordLastBattle
  $PokemonGlobal.lastbattle = $PokemonTemp.lastbattle
  $PokemonTemp.lastbattle = nil
end

def pbPlayBattle(battledata)
  if battledata
    scene = pbNewBattleScene
    scene.abortable = true
    lastbattle = Marshal.restore(StringInput.new(battledata))
    case lastbattle[0]
      when BattleChallenge::BattleTower
        battleplayer = PokeBattle_BattlePlayer.new(scene, lastbattle)
      when BattleChallenge::BattlePalace
        battleplayer = PokeBattle_BattlePalacePlayer.new(scene, lastbattle)
      when BattleChallenge::BattleArena
        battleplayer = PokeBattle_BattleArenaPlayer.new(scene, lastbattle)
    end
    bgm = BattlePlayerHelper.pbGetBattleBGM(lastbattle)
    pbBattleAnimation(bgm) {
      pbSceneStandby {
        decision = battleplayer.pbStartBattle
      }
    }
  end
end

def pbDebugPlayBattle
  params = ChooseNumberParams.new
  params.setRange(0, 500)
  params.setInitialValue(0)
  params.setCancelValue(-1)
  num = Kernel.pbMessageChooseNumber(_INTL("Choose a battle."), params)
  if num >= 0
    pbPlayBattleFromFile(sprintf("Battles/Battle%03d.dat", num))
  end
end

def pbPlayLastBattle
  pbPlayBattle($PokemonGlobal.lastbattle)
end

def pbPlayBattleFromFile(filename)
  pbRgssOpen(filename, "rb") { |f|
    pbPlayBattle(f.read)
  }
end

class Game_Event
  def pbInChallenge?
    return pbBattleChallenge.pbInChallenge?
  end
end

def pbBattleChallenge
  if !$PokemonGlobal.challenge
    $PokemonGlobal.challenge = BattleChallenge.new
  end
  return $PokemonGlobal.challenge
end

def pbBattleChallengeTrainer(numwins, bttrainers)
  # don't prefer one trainer over another
  return rand(bttrainers.length)
end

def pbBattleChallengeGraphic(event)
  nextTrainer = pbBattleChallenge.nextTrainer
  bttrainers = $cache.bttrainers
  filename = getTrainerOverworldSprite(bttrainers[nextTrainer].tclass)
  # filename=pbTrainerCharNameFile((bttrainers[nextTrainer][0] rescue 0))
  if pbBattleChallenge.battleNumber == 5 && (pbBattleChallenge.currentChallenge == 'towersingle' || pbBattleChallenge.currentChallenge == 'towerdouble') # the last round
    towerboss = $game_variables[610]
    case towerboss
      when "Bee" then filename = "trchar177"
      when "Biggles" then filename = "pkmn_garbodor"
      when "Santiago" then filename = "trchar143"
      when "Danielle" then filename = "trchar169"
      when "Sandy" then filename = "trchar158"
      when "Aster" then filename = "trchar135"
      when "Seacrest" then filename = "trchar168"
      when "Meganium" then filename = "pkmn_meganium"
      when "CL:4R1-C3" then filename = "pkmn_breloom2"
      when "Corin-Rouge" then filename = "trchar127"
      when "Indra" then filename = "trchar172"
      when "Archer" then filename = "trchar111"
      when "Maxwell" then filename = "trchar112"
      when "Alistasia" then filename = "trchar117"
      when "Craudburry" then filename = "trchar171"
      when "Nyu" then filename = "trchar170"
      when "Smeargletail" then filename = "pkmn_smeargle2"
      when "Zero" then filename = "trchar070b"
      when "Cass" then filename = "trchar165"
      when "Eustace" then filename = "NPC 02"
      when "McKrezzy" then filename = "trchar173"
      when "Marcello" then filename = "trchar147"
      when "Kanaya" then filename = "trchar175"
      when "Bill" then filename = "trchar179"
      when "Direction" then filename = "NPC 28"
      when "Simon" then filename = "trchar156"
      when "Randall" then filename = "trchar146"
      when "Europa" then filename = "trchar178"
      when "Maelstrom" then filename = "trchar180"
      when "Murmina" then filename = "trchar176"
      when "John" then filename = "trchar138"
      when "Eastman" then filename = "trchar174"
      when "Breslin" then filename = "trchar187"
      when "Mewtwo" then filename = "pkmn_mewtwo2"
      when "Crim" then filename = "trchar206"
      when "Nelly" then filename = "trchar213"
    end
  end
  begin
    bitmap = AnimatedBitmap.new("Graphics/Characters/" + filename)
    bitmap.dispose
    event.character_name = filename
  rescue
    event.character_name = "Red"
  end
end

def pbBattleChallengeBeginSpeech
  if !pbBattleChallenge.pbInProgress?
    return _INTL("...")
  elsif pbBattleChallenge.battleNumber == 5 && (pbBattleChallenge.currentChallenge == 'towersingle' || pbBattleChallenge.currentChallenge == 'towerdouble') # the last round
    towerboss = $game_variables[610]
    case towerboss
      when "Bee" then return _INTL("Hey! I thought I'd come down here, see if there was anything new to see. It's pretty neat!")
      when "Biggles" then return _INTL("IF AH WIN, CAN HAVE HUG?")
      when "Santiago" then return _INTL("LET'S HAVE A FUCKIN' BAD-ASS BATTLE!")
      when "Danielle" then return _INTL("Oh hey, if it isn't my favorite gofer!")
      when "Sandy" then return _INTL("I haven't had a challenger for a while, this oughtta be fun!")
      when "Aster" then return _INTL("Been a while, huh, boss? Let's make it a great battle, for old times' sake. And for her.")
      when "Seacrest" then return _INTL("It's so much nicer to battle now that the city's so beautiful again.")
      when "Meganium" then return _INTL("Madame Meganium stares at you levelly.")
      when "CL:4R1-C3" then return _INTL("BREEEEEEEEE-")
      when "Corin-Rouge" then return _INTL("Finally, our destined reunion!")
      when "Indra" then return _INTL("Are YOU ready to take on Agate Circus' best clown?")
      when "Archer" then return _INTL("Aqua Gang may be gone, but I'm going to make a splash here!")
      when "Maxwell" then return _INTL("I may have disbanded the Magma Gang, but you bet you're gonna see I'm still hot stuff!")
      when "Alistasia" then return _INTL("Let's put on a great show, maybe drum up some publicity for the Circus!")
      when "Craudburry" then return _INTL("I'll send you packing, you MISERABLE SLIME!")
      when "Nyu" then return _INTL("Oh, hiya~ Here to show me your Pikachu?")
      when "Smeargletail" then return _INTL("Smeargle holds up a sign that says 'human not win this battle'.")
      when "Zero" then return _INTL("...Hey. Well, let's get to it, shall we?")
      when "Cass" then return _INTL("hi. i'm cass. let's FITE.")
      when "Eustace" then return _INTL("Hmph. I wish they would stop sending incompetents out to face me.")
      when "McKrezzy" then return _INTL("All right, let's jazz this place up.")
      when "Marcello" then return _INTL("Hello! Fancy a lemonade?")
      when "Kanaya" then return _INTL("All right. The faster we get this fight done, the faster I can get back to work.")
      when "Bill" then return _INTL("Oh, h'llo. Fancy a friendly match?")
      when "Direction" then return _INTL("I don't need my crystal ball to see your loss here.")
      when "Simon" then return _INTL("...Hi. Good to see you again.")
      when "Randall" then return _INTL("Heya, partner! Well-- 'course we're not partners right now, but-- Let's just have fun, 'kay?")
      when "Europa" then return _INTL("Now how's about I show you how we battle over in Train Town?")
      when "Maelstrom" then return _INTL("Get ready for a stormy battle!")
      when "Murmina" then return _INTL("Hey. We've got a clean slate now; let's just have a good battle.")
      when "John" then return _INTL("We are no longer enemies, but do not make the mistake of underestimating me.")
      when "Eastman" then return _INTL("Nice to get a break from official duty!")
      when "Breslin" then return _INTL("'Ello. Told you I might stop by!")
      when "Mewtwo" then return _INTL("Tu...")
      when "Crim" then return _INTL("Oh hey! I'm Crim! I'm so excited to be here, let's have some fun!")
      when "Nelly" then return _INTL("Get ready for my Eevee power!")
    end
  else
    bttrainers = $cache.bttrainers
    tr = bttrainers[pbBattleChallenge.nextTrainer]
    return tr ? pbGetMessageFromHash(:BattleTowerIntroSpeech, tr.introSpeech) : _INTL("...")
  end
end

def pbEntryScreen(*arg)
  retval = false
  pbFadeOutIn(99999) {
    scene = PokemonScreen_Scene.new
    screen = PokemonScreen.new(scene, $Trainer.party)
    ret = screen.pbPokemonMultipleEntryScreenEx(pbBattleChallenge.rules.ruleset)
    # Set party
    pbBattleChallenge.setParty(ret) if ret
    # Continue (return true) if Pokémon were chosen
    retval = (ret != nil && ret.length > 0)
  }
  return retval
end

def pbBattleChallengeBattle
  return pbBattleChallenge.pbBattle
end

class BattleFactoryData
  def initialize(bcdata)
    @bcdata = bcdata
  end

  def pbPrepareRentals
    @trainerid = @bcdata.nextTrainer
    $rentalsnew = pbBattleFactoryPokemon(@bcdata.wins, @bcdata.swaps, [])
    bttrainers = $cache.bttrainers
    trainerdata = bttrainers[@trainerid]
    @bcdata.opponentnew = pbGenerateBattleTrainer(@trainerid, pbBattleFactoryRules(@bcdata.doublebattlefact, true))
  end

  def pbChooseRentals
    pbFadeOutIn(99999) {
      @bcdata.pbAddSwap
      scene = BattleSwapScene.new
      screen = BattleSwapScreen.new(scene)
      $rentalsnew = screen.pbStartRent($rentalsnew)
      pbBattleChallenge.setParty($rentalsnew)
    }
  end

  def pbBattle(challenge)
    bttrainers = $cache.bttrainers
    trainerdata = bttrainers[@trainerid]
    return pbOrganizedBattleEx(opponent, challenge.rules, trainerdata.loseSpeech, trainerdata.winSpeech)
  end

  def pbPrepareSwaps # opponent hat to be generated here, because info of opposing pokemon is given after this
    @bcdata.oldopponent = @bcdata.opponentnew.party
    @trainerid = @bcdata.nextTrainer
    bttrainers = $cache.bttrainers
    trainerdata = bttrainers[@trainerid]
    @bcdata.opponentnew = pbGenerateBattleTrainer(@trainerid, pbBattleFactoryRules(@bcdata.doublebattlefact, true))
  end

  def pbChooseSwaps
    swapMade = true
    pbFadeOutIn(99999) {
      if !$rentalsnew
        $rentalsnew = $Trainer.party
      end
      scene = BattleSwapScene.new
      screen = BattleSwapScreen.new(scene)
      swapMade = screen.pbStartSwap($rentalsnew, @bcdata.oldopponent)
      if swapMade
        @bcdata.pbAddSwap
      end
      @bcdata.setParty($rentalsnew)
    }
    return swapMade
  end
end

def pbBattleFactoryPokemon(numwins, numswaps, rentals)
  btpokemon = $cache.btmons
  bttrainers = $cache.bttrainers
  ivPresets = [ # Flat IV spreads based on "round" number
    0, 4, 8, 12,
    16, 20, 24, 31
  ]
  strengthThreshold = [ # Number of swaps required to add a strong IV spread.
    4, 9, 14, 19, 24, 29
  ]
  ivgroups = [6, 0]

  strengthThreshold.each { |threshold|
    if numswaps > threshold # As thresholds are met, add to the stronger iv group
      ivgroups[0] -= 1
      ivgroups[1] += 1
    else
      break # No need to iterate if we do not meet the threshold
    end
  }

  index = numwins / 5 # 5 battles per round.
  index = -1 if index > ivPresets.length - 1
  ivTable = Array.new(6, ivPresets[index])

  if ivPresets[index] != 31 # Ignore this if we are already at 31 IVs
    strengthIndices = (0..5).entries.sample(ivgroups[1]) # Sample the determined amount of Pokemon to strengthen
    strengthIndices.each { |strengthIndex| ivTable[strengthIndex] = ivPresets[index + 1]}
  end

  party = []
  while party.length < 6
    species = btpokemon.keys.sample(6)
    selected = []
    for x in species
      selected.push(btpokemon[x].sample())
    end
    party = Array.new(6) { |i| selected[i].createPokemon(100, ivTable[i], $Trainer) }
    party.uniq! { |mon| mon.species }
    party.uniq! { |mon| mon.type1 }
  end
=begin
  begin
    party.clear
    resorted = (0...pokemonnumbers.length).to_a.shuffle[0..5] #uses different technique. instead of randomly generating numers
    while party.length<6                                      #it creates an array with all the numbers in it, then shuffles it.
      for n in (0...resorted.length)                          #Then the first 6 values are sliced. This all to avoid duplicates of same number
        rnd=pokemonnumbers[resorted[n]]                       #later found out other technique has method for duplicates anyway
        #### Optional code for if we rank species sets by difficulty
        #### Add a negative number at the start of bttrainers PokemonNos section for a given trainer to force them to use that index of the species set (or highest if there aren't that many).
        #### i.e. if PokemonNos started with -1, the trainer would always use the first (likely weakest) set of each species, and if it was -100 they'd always go for the strongest. No negative will randomly decide a set
        #### All stuff relating to this feature will be double instead of single commented
        ## difficultySetting = false
        ##if pokemonnumbers[0]<0
        ##  difficultySetting = abs(pokemonnumbers[0])
        ##end
        ##loop do
        ##  break if rnd>0
        ##  rnd=pokemonnumbers[rand(pokemonnumbers.length)]
        ##end
        ### New Code for changing bttrainers to be based on species rather than id in btpokemon##
        monlist = []
        for mon in btpokemon
          if mon.species==rnd
            monlist.push(mon)
          else
            if monlist.length>0
              break
            end
          end
        end
        ##if !difficultySetting
        rndpoke = monlist[rand(monlist.length)]
        ##else
        ##  diffindex = difficultySetting - 1
        ##  if monlist.length < difficultySetting
        ##    rndpoke = monlist[-1]
        ##  else
        ##    rndpoke = monlist[diffindex]
        ##  end
        ##end
        ###Commented out code should replace next line
        #rndpoke=btpokemon[rnd]
        indvalue=(party.length<ivgroups[0]) ? ivs[0] : ivs[1]
        pkmn=rndpoke.createPokemon(100,indvalue,nil)
        party.push(pkmn)
      end
    end
  end until party.length ==6
=end
  return party
end

def pbGenerateBattleTowerBoss
  if pbBattleChallenge.currentChallenge == 'towersingle' # only for battle tower singles right now
    # SYNTAX IS [ID, NAME, PARTY INDEX, FIELD]
    bosslist = [[:BEE, "Bee", 1000, :CORROSIVE],         [:LAHVER, "Biggles", 1000, :WASTELAND], [:CUEBALL, "Santiago", 1000, :STARLIGHT],
                [:SEER, "Danielle", 1000, :MIRROR],                [:SANDY, "Sandy", 1000, :SWAMP], [:ASTER, "Aster", 1000, :DESERT],
                [:SEACREST, "Seacrest", 1000, :UNDERWATER],        [:MEGANIUM, "Meganium", 1000, :INVERSE],
                [:BRELOOM, "CL:4R1-C3", 1000, :FACTORY],           [:CORINROUGE, "Corin-Rouge", 1000, :FAIRYTALE],  [:INDRA, "Indra", 1000, :MIRROR],
                [:INDRA, "Indra", 1001, :RAINBOW],                 [:INDRA, "Indra", 1002, :RAINBOW],               [:Archer, "Archer", 1000, :SWAMP],
                [:Maxwell, "Maxwell", 1000, :GRASSY],              [:RINGMASTER, "Alistasia", 1000, :BIGTOP],       [:HARRIDAN, "Craudburry", 1000, :HOLY],
                [:PIKANYU, "Nyu", 1000, :ELECTERRAIN],             [:SMEARGLE, "Smeargletail", 1000, :DESERT],      [:ZEL3, "Zero", 1000, :NEWWORLD],
                [:ZEL3, "Zero", 1001, :NEWWORLD],                  [:CASS, "Cass", 1000, :NEWWORLD],                [:CASS, "Cass", 1001, :HOLY],
                [:MASTERMIND, "Eustace", 1000, :NEWWORLD],         [:MCKREZZY, "McKrezzy", 1000, :CAVE],            [:MARCELLO, "Marcello", 1000, :GLITCH],
                [:KANAYA, "Kanaya", 1000, :DESERT],                [:BUFF, "Bill", 1000, :INVERSE],                 [:MISSDIRECTION, "Direction", 1000, :GLITCH],
                [:MISSDIRECTION, "Direction", 1001, :PSYTERRAIN],  [:SIMON, "Simon", 1000, :FOREST],                [:RANDALL, "Randall", 1000, pbRandomField],
                [:EUROPA, "Europa", 1000, :CORROSIVEMIST],         [:MAEL, "Maelstrom", 1000, :GRASSY],             [:MURMINA, "Murmina", 1000, :BIGTOP],
                [:NWOrderly, "John", 1000, :STARLIGHT],            [:CHIEF, "Eastman", 1000, :STARLIGHT],           [:CRIM, "Crim", 1000, :FAIRYTALE],
                [:NELLY, "Nelly", 1000, :GRASSY],                  [:NELLY, "Nelly", 1001, :WATERSURFACE]]
    if $game_variables[616] > 18 # zeraora quest done
      bosslist.push([:POACHERB, "Breslin", 1000, :STARLIGHT])
    end
    chosenboss = bosslist[rand(bosslist.length)]
    if $game_variables[726] == 1 # mewtwo quest started
      chosenboss = [:DEFNOT, "Mewtwo", 1000, :RAINBOW]
    end
    tempboss = pbLoadTrainer(chosenboss[0], chosenboss[1], chosenboss[2])
    # return [boss,chosenboss[3]]
    # return $towerBoss
    boss = tempboss[0]
    for i in tempboss[2]
      boss.party.push(i)
    end
    $game_variables[575] = [boss, chosenboss[3]]
    $game_variables[610] = chosenboss[1]
  elsif pbBattleChallenge.currentChallenge == 'towerdouble' # doubles from cad
    # SYNTAX IS [ID, NAME, PARTY INDEX, FIELD]
    bosslist = [[:BEE, "Bee", 2000, :CORROSIVE], [:LAHVER, "Biggles", 2000, :WASTELAND], [:CUEBALL, "Santiago", 2000, :STARLIGHT],
                [:SEER, "Danielle", 2000, :MIRROR],                [:SANDY, "Sandy", 2000, :SWAMP],                 [:ASTER, "Aster", 2000, :DESERT],
                [:SEACREST, "Seacrest", 2000, :UNDERWATER],        [:MEGANIUM, "Meganium", 2000, :INVERSE],
                [:BRELOOM, "CL:4R1-C3", 2000, :FACTORY],           [:CORINROUGE, "Corin-Rouge", 2000, :FAIRYTALE],  [:INDRA, "Indra", 2000, :MIRROR],
                [:INDRA, "Indra", 2001, :RAINBOW],                 [:INDRA, "Indra", 2002, :RAINBOW],               [:Archer, "Archer", 2000, :SWAMP],
                [:Maxwell, "Maxwell", 2000, :GRASSY],              [:RINGMASTER, "Alistasia", 2000, :BIGTOP],       [:HARRIDAN, "Craudburry", 2000, :HOLY],
                [:PIKANYU, "Nyu", 2000, :ELECTERRAIN],             [:ZEL3, "Zero", 2000, :NEWWORLD],                [:ZEL3, "Zero", 2001, :NEWWORLD],
                [:MASTERMIND, "Eustace", 2000, :NEWWORLD],         [:MCKREZZY, "McKrezzy", 2000, :CAVE],
                [:KANAYA, "Kanaya", 2000, :DESERT],                [:BUFF, "Bill", 2000, :INVERSE],                 [:MISSDIRECTION, "Direction", 2000, :GLITCH],
                [:MISSDIRECTION, "Direction", 2001, :PSYTERRAIN],  [:SIMON, "Simon", 2000, :FOREST],                [:RANDALL, "Randall", 2000, pbRandomField],
                [:EUROPA, "Europa", 2000, :CORROSIVEMIST],         [:MAEL, "Maelstrom", 2000, :GRASSY],             [:MURMINA, "Murmina", 2000, :BIGTOP],
                [:NWOrderly, "John", 2000, :STARLIGHT],            [:CHIEF, "Eastman", 2000, :STARLIGHT],           [:NELLY, "Nelly", 2000, :STARLIGHT]]
    if $game_variables[616] > 18 # zeraora quest done
      bosslist.push([:POACHERB, "Breslin", 2000, :STARLIGHT])
    end
    chosenboss = bosslist[rand(bosslist.length)]
    tempboss = pbLoadTrainer(chosenboss[0], chosenboss[1], chosenboss[2])
    # return [boss,chosenboss[3]]
    # return $towerBoss
    boss = tempboss[0]
    for i in tempboss[2]
      boss.party.push(i)
    end
    $game_variables[575] = [boss, chosenboss[3]]
    $game_variables[610] = chosenboss[1]
  end
end

def pbGenerateBattleTrainer(trainerid, rule)
  if pbBattleChallenge.battleNumber == 5 && (pbBattleChallenge.currentChallenge == 'towersingle' || pbBattleChallenge.currentChallenge == 'towerdouble') # the last round
    # towerboss = pbGenerateBattleTowerBoss
    # towerboss = $towerBoss
    towerboss = $game_variables[575]
    if $game_switches[:Battle_Tower_FE_Enabled]
      $game_variables[:Forced_Field_Effect] = towerboss[1]
    end
    $PokemonGlobal.nextBattleBGM = RPG::AudioFile.new("Nightclub- Mirror Ball")
    return towerboss[0]
  end

  bttrainers = $cache.bttrainers
  trainerdata = bttrainers[trainerid]
  opponent = PokeBattle_Trainer.new(pbGetMessageFromHash(:BattleTowerTrainerNames, trainerdata.name), trainerdata.tclass)
  btpokemon = $cache.btmons

  # Individual Values
  indvalues = 0
  if pbBattleChallenge.currentChallenge == "factorysingleopen" || pbBattleChallenge.currentChallenge == "factorydoubleopen"
    # Iv's for Battle Factory
    ivPresets = [ # Flat IV spreads based on "round" number
      0, 4, 8, 12,
      16, 20, 24, 31
    ]
    index = pbBattleChallenge.wins / 5 # 5 battles per round.
    lastRound = pbBattleChallenge.battleNumber == 5
    index += 1 if lastRound # Increase the strength of the "floor boss"
    index = -1 if index > ivPresets.length - 1 # Default to max is past 7 rounds
    indvalues = ivPresets[index]
  else
    indvalues = [5 * (pbBattleChallenge.wins / 7.0).floor, 31].min
    # IV's for Battle Tower
  end

  # Trainerdata
  pokemonnumbers = trainerdata.monIndexes
  if pokemonnumbers.length < rule.ruleset.suggestedNumber
    for n in pokemonnumbers
      monset = btpokemon[n].sample()
      pkmn = monset[setnum].createPokemon(rule.ruleset.suggestedLevel, indvalues, opponent)
      opponent.party.push(pkmn)
    end
    return opponent
  end
  err = []
  begin
    puts err[-1] if !err.empty?
    opponent.party.clear
    while opponent.party.length < rule.ruleset.suggestedNumber
      ids = pokemonnumbers.sample(rule.ruleset.suggestedNumber)
      for id in ids
        monset = btpokemon[id].sample()
        mon = monset.createPokemon(rule.ruleset.suggestedLevel, indvalues, opponent)
        opponent.party.push(mon)
      end
    end
    # samplesize = rule.ruleset.suggestedNumber
    # ids = pokemonnumbers.sample(samplesize)
    # ids.each{|id| opponent.party.push(btpokemon[id].createPokemon(rule.ruleset.suggestedLevel,indvalues,opponent))}
  end until rule.ruleset.isValid?(opponent.party, err)
  Events.onBattleFacilityChallenge.trigger(nil, opponent)

  return opponent

=begin
    while opponent.party.length<rule.ruleset.suggestedNumber
      rnd=pokemonnumbers[rand(pokemonnumbers.length)]
      dp(sprintf("trainerid = %s, rnd = %d",trainerid,rnd)) #There's a trainer running amuck with an invalid pokemon number i think. It crashed my game twice but couln't reproduce it anyway. Problem shows it face at CreatePokemon a few lines down
      #### Optional code for if we rank species sets by difficulty
      #### Add a negative number at the start of bttrainers PokemonNos section for a given trainer to force them to use that index of the species set (or highest if there aren't that many).
      #### i.e. if PokemonNos started with -1, the trainer would always use the first (likely weakest) set of each species, and if it was -100 they'd always go for the strongest. No negative will randomly decide a set
      #### All stuff relating to this feature will be double instead of single commented
      ## difficultySetting = false
      ##if pokemonnumbers[0]<0
      ##  difficultySetting = abs(pokemonnumbers[0])
      ##end
      ##loop do
      ##  break if rnd>0
      ##  rnd=pokemonnumbers[rand(pokemonnumbers.length)]
      ##end
      ### New Code for changing bttrainers to be based on species rather than id in btpokemon##
      monlist = []
      for mon in btpokemon
        if mon.species==rnd
          monlist.push(mon)
        else
          if monlist.length>0
            break
          end
        end
      end
      ##if !difficultySetting
      rndpoke = monlist[rand(monlist.length)]
      next if rndpoke==nil
      ##else
      ##  diffindex = difficultySetting - 1
      ##  if monlist.length < difficultySetting
      ##    rndpoke = monlist[-1]
      ##  else
      ##    rndpoke = monlist[diffindex]
      ##  end
      ##end
      ###Commented out code should replace next line
      #rndpoke=btpokemon[rnd]
      pkmn=rndpoke.createPokemon(
         rule.ruleset.suggestedLevel,indvalues,opponent)
      opponent.party.push(pkmn)
    end
  end until rule.ruleset.isValid?(opponent.party)
  return opponent
=end
end

def pbOrganizedBattleEx(opponent, challengedata, endspeech, endspeechwin)
  if !challengedata
    challengedata = PokemonChallengeRules.new
  end
  scene = pbNewBattleScene
  for i in 0...$Trainer.party.length
    $Trainer.party[i].heal
  end
  olditems = $Trainer.party.transform { |p| p.item }
  olditems2 = opponent.party.transform { |p| p.item }
  opponent.skill = PokeBattle_AI::BESTSKILL # making sure every battle trainer is smart
  battle = challengedata.createBattle(scene, $Trainer, opponent)
  battle.controlPlayer = $game_switches[:AI_Play] || $game_switches[:Forced_AI_Play]
  battle.internalbattle = false
  battle.endspeech = endspeech
  battle.endspeechwin = endspeechwin
  if pbBattleChallenge.battleNumber == 5 && (pbBattleChallenge.currentChallenge == 'towersingle' || pbBattleChallenge.currentChallenge == 'towerdouble') # the last round
    battle = pbMinibossDialogueOverwrite(battle)
  end
  if $DEBUG && Input.press?(Input::CTRL)
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    $PokemonTemp.lastbattle = nil
    return true
  end
  oldlevels = challengedata.adjustLevels($Trainer.party, opponent.party)
  pbPrepareBattle(battle)
  decision = 0
  trainerbgm = pbGetTrainerBattleBGM(opponent)
  pbBattleAnimation(trainerbgm) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
  }
  challengedata.unadjustLevels($Trainer.party, opponent.party, oldlevels)
  for i in 0...$Trainer.party.length
    # Healing is done by an NPC between battles.
    # Also this actually heals the team even if nuzlocke password is active which is not intended (confirmed with Ame).
    # $Trainer.party[i].heal
    $Trainer.party[i].setItem(olditems[i])
  end
  for i in 0...opponent.party.length
    opponent.party[i].heal
    opponent.party[i].setItem(olditems2[i])
  end
  Input.update
  if decision == 1 || decision == 2 || decision == 5
    $PokemonTemp.lastbattle = nil
  else
    $PokemonTemp.lastbattle = nil
  end
  return decision == 1
end

def pbIsBanned?(pokemon)
  return StandardSpeciesRestriction.new.isValid?(pokemon)
end

def pbMinibossDialogueOverwrite(battle)
  towerboss = $game_variables[610]
  case towerboss
    when "Bee"
      battle.endspeech = _INTL("Eh, wasn't my best showing, but it was fun.")
      battle.endspeechwin = _INTL("Huh... maybe this is the beginning of my new path?")
    when "Biggles"
      battle.endspeech = _INTL("NO HUG FOR BIGGLES...")
      battle.endspeechwin = _INTL("BIGGLES WIN! HUG NOW?")
    when "Santiago"
      battle.endspeech = _INTL("What the fuck? That's fucking bullshit, man!")
      battle.endspeechwin = _INTL("Did I fucking win? That's fucking awesome!")
    when "Danielle"
      battle.endspeech = _INTL("Of course you won, when you had the advantage. Next time try battling without being able to see, and then we'll see who's the better Trainer.")
      battle.endspeechwin = _INTL("Wow! Beaten by a girl who can't see, hm? I bet that's going to give your ego a bruising. Well, good! Hee hee.")
    when "Sandy"
      battle.endspeech = _INTL("All right, all right, you've put me back on solid ground now.")
      battle.endspeechwin = _INTL("See what happens when you love the planet? It loves you back!")
    when "Aster"
      battle.endspeech = _INTL("Well fought. Thank you.")
      battle.endspeechwin = _INTL("Maybe... I'm finally growing. Thank you.")
    when "Seacrest"
      battle.endspeech = _INTL("Had a feeling this was how it'd go.")
      battle.endspeechwin = _INTL("You've come a long way since we met, but this is the end of the line for today.")
    when "Meganium"
      battle.endspeech = _INTL("Madame Meganium gives you a long, level look, and then gives a small nod of approval.")
      battle.endspeechwin = _INTL("Madame Meganium tosses her head proudly.")
    when "CL:4R1-C3"
      battle.endspeech = _INTL("-LOOOOOOOOM! Error! Error!")
      battle.endspeechwin = _INTL("-LOOM. Beep beep!")
    when "Corin-Rouge"
      battle.endspeech = _INTL("And once more, I face my defeat...")
      battle.endspeechwin = _INTL("The light of victory shines upon me...")
    when "Indra"
      battle.endspeech = _INTL("Aaaaaand we have a winner! The fabulous Champion!")
      battle.endspeechwin = _INTL("Aaaand once more the dashing clown Indra reigns victorious!")
    when "Archer"
      battle.endspeech = _INTL("Ah, well. It was entertaining enough.")
      battle.endspeechwin = _INTL("What's the matter? Would you say you're a little washed up?")
    when "Maxwell"
      battle.endspeech = _INTL("Guess I didn't do so hot.")
      battle.endspeechwin = _INTL("FOR GLORY, BABY!")
    when "Alistasia"
      battle.endspeech = _INTL("Pretty much what I figured, but it was fun!")
      battle.endspeechwin = _INTL("Hey, that was great! I wonder if anyone recorded it? Maybe we could use it as a promo video...")
    when "Craudburry"
      battle.endspeech = _INTL("How DARE YOU? You came here just to HUMILIATE a KIND OLD WOMAN! I'll sue you! I'LL SUE THIS WHOLE CLUB!")
      battle.endspeechwin = _INTL("See? SEE? I'VE STILL GOT IT!")
    when "Nyu"
      battle.endspeech = _INTL("No fair! I didn't get to play with your Pikachu!")
      battle.endspeechwin = _INTL("I guess my Pikachu were stronger. All Pikachu are good though.")
    when "Smeargletail"
      battle.endspeech = _INTL("Smeargle holds out a notepad and hastily scribbles, 'guess human did win. good battle.'")
      battle.endspeechwin = _INTL("Smeargle holds out a notepad and flips a page to where he's written 'smeargle best trainer. human good battler too though.")
    when "Zero"
      battle.endspeech = _INTL("Just like always.")
      battle.endspeechwin = _INTL("...Huh. I won. How about that?")
    when "Cass"
      battle.endspeech = _INTL("is this done yet? good.")
      battle.endspeechwin = _INTL("oh hey. that was kind of fun.")
    when "Eustace"
      battle.endspeech = _INTL("Hmph. I suppose you weren't completely incompetent for a change.")
      battle.endspeechwin = _INTL("Hmph. I've seen Magikarp with more skill at battling and more intellect.")
    when "McKrezzy"
      battle.endspeech = _INTL("A smooth victory.")
      battle.endspeechwin = _INTL("I guess you can't compete with a true master, in battle or in music.")
    when "Marcello"
      battle.endspeech = _INTL("Well, that wasn't very nice!")
      battle.endspeechwin = _INTL("My Pokémon did great. Such good boys. And girls.")
    when "Kanaya"
      battle.endspeech = _INTL("Well, back to work.")
      battle.endspeechwin = _INTL("I won. Woohoo. Okay, back to work.")
    when "Bill"
      battle.endspeech = _INTL("Didn't win, but that was a right good battle.")
      battle.endspeechwin = _INTL("And that there's a lesson to ya.")
    when "Direction"
      battle.endspeech = _INTL("B-but- How could I have been wrong?")
      battle.endspeechwin = _INTL("It's as I told you. My prophecies are never wrong.")
    when "Simon"
      battle.endspeech = _INTL("Even with my defeat, it was pleasant to battle with you once more.")
      battle.endspeechwin = _INTL("Man. No hard feelings, but I have to admit, it was nice to win against you for a change.")
    when "Randall"
      battle.endspeech = _INTL("Eh. I always told ya I wasn't much of a battler.")
      battle.endspeechwin = _INTL("I won? Really truly?")
    when "Europa"
      battle.endspeech = _INTL("Guess you didn't need to learn after all.")
      battle.endspeechwin = _INTL("And that's how ya battle in Train Town!")
    when "Maelstrom"
      battle.endspeech = _INTL("Guess the winds of fate weren't blowing for me.")
      battle.endspeechwin = _INTL("Sometimes one good move's all it takes to turn the tide.")
    when "Murmina"
      battle.endspeech = _INTL("I did my best, okay? Good luck.")
      battle.endspeechwin = _INTL("...That was a good battle. Thank you.")
    when "John"
      battle.endspeech = _INTL("And yet it appears I was the one who underestimated you. My apologies.")
      battle.endspeechwin = _INTL("Excellent... This is a step forward.")
    when "Eastman"
      battle.endspeech = _INTL("Heh... you pulled off some arrestingly good moves there.")
      battle.endspeechwin = _INTL("Nice. Now the boys owe me dinner!")
    when "Breslin"
      battle.endspeech = _INTL("I suppose I shouldn't have expected to win against the Champion on my first try.")
      battle.endspeechwin = _INTL("Hm. Guess it was a good thing after all, coming here.")
    when "Mewtwo"
      battle.endspeech = _INTL("...")
      battle.endspeechwin = _INTL("...!")
    when "Crim"
      battle.endspeech = _INTL("That was awesome! You're really something, you know that?")
      battle.endspeechwin = _INTL("I'll see you in the back alley!")
    when "Nelly"
      battle.endspeech = _INTL("I can't believe you'd go all out on my cute Eeveelutions!")
      battle.endspeechwin = _INTL("Eevee power reigns supreme!")
  end
  return battle
end

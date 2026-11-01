# Results of battle:
#    0 - Undecided or aborted
#    1 - Player won
#    2 - Player lost
#    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#    4 - Wild Pokémon was caught
#    5 - Draw

################################################################################
# Main battle class.
################################################################################
class PokeBattle_Battle
  attr_reader(:scene)             # Scene object for this battle
  attr_accessor(:decision)        # Decision: 0=undecided; 1=win; 2=loss; 3=escaped; 4=caught
  attr_accessor(:internalbattle)  # Internal battle flag
  attr_accessor(:doublebattle)    # Double battle flag
  attr_accessor(:cantescape)      # True if player can't escape
  attr_accessor(:shiftStyle)      # Shift/Set "battle style" option
  attr_accessor(:battlescene)     # "Battle scene" option
  attr_reader(:player)            # Player trainer(s)
  attr_reader(:opponent)          # Opponent trainer(s)
  attr_accessor(:fakeopponent)      # dummy for AI boss pokemon
  attr_accessor(:party1)          # player's (combined) Pokémon party
  attr_accessor(:party2)          # opponent's (combined) Pokémon party
  attr_reader(:partyorder)        # Order of Pokémon in player's party
  attr_reader(:partyorder2)       # Order of Pokémon in opponent's party
  attr_reader(:revealedPokemon)   # For tracking which pokemon have been sent out
  attr_reader(:revealedBosses)    # For in-battle Pulse Dex
  attr_reader(:battlers)          # Currently active Pokémon
  attr_reader(:priority)          # Move order of active Pokémon
  attr_accessor(:speedData)       # Calculated speed stats (before Trick Room) of active Pokémon
  attr_accessor(:moveOrder)       # Active Pokémon, ordered by move execution
  attr_accessor(:speedOrder)      # Active Pokémon, ordered by calculated speed
  attr_accessor(:items)           # Items held by opponents
  attr_accessor(:partneritems)    # Items held by AI partners :)
  attr_accessor(:sides)           # Effects common to each side of a battle
  attr_accessor(:state)
  attr_accessor(:field)           # Effects common to the whole of a battle
  attr_accessor(:environment)     # Battle surroundings
  attr_accessor(:weather)         # Current weather, custom methods should use pbWeather instead
  attr_accessor(:weatherduration) # Duration of current weather, or -1 if indefinite
  attr_accessor(:weatherbackup)   # The original weather of the area, if it exists.  #### DemICE - persistentweather
  attr_reader(:preSurgeField)     # Used to enable pre-surge field entry effects in case of no Overlays
  attr_accessor(:struggle)        # The Struggle move
  # Array of 4 arrays, one for each battler
  # Inner array can have the following values:
  # Nothing: [:skip]
  # Move:    [:move, moveIndex, PokeBattle_Move, targetIndex]
  # Switch:  [:switch, partyIndex]
  # Item:    [:item, itemSymbol, partyIndex]
  # Call:    [:call]
  # Run:     [:run]
  attr_accessor(:choices)         # Choices made by each Pokémon this round
  attr_accessor(:lastMoveUsed)    # Last move used
  attr_accessor(:lastMoveUser)    # Last move user
  attr_accessor(:synchronize)     # Synchronize state
  attr_accessor(:pickupA)         # Pickup stack A (not during attack)
  attr_accessor(:pickupB)         # Pickup stack B (during attack)
  attr_accessor(:permanenteffects) # Effects that persist through switches
  # The following 4 arrays @megaEvolution, @ultraBurst, @terastal and @zMove all have the same format.
  # It's an array of [sideIndex => [ownerIndex => battlerIndex]]
  # sideIndex:    0 = player's side, 1 = opponent's side
  # ownerIndex:   0 in singles, 0 or 1 in doubles - index of the trainer on their respective side
  # battlerIndex: 0-3 which slot is using the mega/ultra/zmove, -1 when not yet used, -2 used before
  attr_accessor(:megaEvolution)   # Battle index of each trainer's Pokémon to Mega Evolve
  attr_accessor(:ultraBurst)      # Battle index of each trainer's Pokémon to Ultra Burst
  attr_accessor(:terastal)        # Battle index of each trainer's Pokémon to Terastallize
  attr_accessor(:zMove)           # Battle index of each trainer's Pokémon to use A Z-move
  attr_accessor(:amuletcoin)      # Whether Amulet Coin's effect applies
  attr_accessor(:echoedVoice)     # Echoed Voice counter
  attr_accessor(:echoedThisRound) # Whether or not was Echoed Voice used this round
  attr_accessor(:happyhour)       # Whether Happy Hour's effect applies
  attr_accessor(:extramoney)      # Money gained in battle by using Pay Day
  attr_accessor(:endspeech)       # Speech by opponent when player wins
  attr_accessor(:endspeech2)      # Speech by opponent when player wins
  attr_accessor(:endspeechwin)    # Speech by opponent when opponent wins
  attr_accessor(:endspeechwin2)   # Speech by opponent when opponent wins
  attr_accessor(:switchedOut)
  attr_accessor(:fusionMove)
  attr_accessor(:ai)              # our baby who's gonna throw a lot of tantrums...
  attr_accessor(:rules)
  attr_reader(:turncount)
  attr_accessor :controlPlayer
  attr_accessor(:disableExpGain)  # True id no exp gain during this battle
  attr_accessor(:fainted_mons)    # Store which pokemon were fainted at the start of the battle
  attr_accessor(:handled_opp_messages)
  attr_accessor(:phase)
  attr_accessor(:recorded)
  attr_accessor(:sosbattle)       # Stores fight is an sos battle or not
  attr_accessor(:eruption)        # Eruption variable for Volcano Top field
  attr_accessor(:catchmessageplayed)
  attr_accessor(:battleRandom)
  attr_accessor(:seed)
  attr_accessor(:restoreItems)    # Whether Player's items should be restored after battle
  attr_accessor(:levelCap)        # Set level mechanic. Caps Pokemon to this number
  attr_accessor(:raiseToLevel)    # Whether Pokemon below levelCap should be brought to it
  attr_accessor(:delayEffectHash) # Hash list memory of delayed actions initiated in this battle, keyed with unique identifier

  # rejuv
  attr_accessor(:specialchoices)         # Choices for special moves made by each Pokémon this round
  attr_accessor(:specialmoves)         # special moves usable by for this battle
  attr_accessor(:specialParty)


  #boss mechanics
  attr_accessor :snapshot

  include PokeBattle_BattleCommon

  PLAYERMAXPARTYSIZE = 6
  OPPONENTMAXPARTYSIZE = 6

  # deso npc commentary
  def createNewBattleRecord
    if $game_variables[:BattleDataArray].nil? || !$game_variables[:BattleDataArray].kind_of?(Array)
      $game_variables[:BattleDataArray] = []
    end
    if @opponent.kind_of?(Array)
      $game_variables[:BattleDataArray] << Battle_Data.new([@opponent[0].name, @opponent[1].name], @party1, @party2)
    else
      $game_variables[:BattleDataArray] << Battle_Data.new(@opponent.name, @party1, @party2)
    end
  end

  def pbRandom(x = 1.0)
    return @battleRandom.rand(x)
  end

  def sample(array)
    return array[pbRandom(array.length)]
  end

  # Can't use ruby's built-in shuffle because we want to call pbRandom
  # This is a custom implementation of Fisher-Yates shuffle algorithm
  def shuffle(array)
    array = array.dup
    (1...array.length).reverse_each do |i|
      j = pbRandom(i + 1)
      array[i], array[j] = array[j], array[i]
    end
    return array
  end

  def getTieBreakArray
    return shuffle(Array(0...@battlers.length))
  end

  # Used for looping over battlers.
  # Makes sure the order is consistent for online battles.
  def eachBattler(&block)
    if pbTieBreak == 1
      return @battlers.each(&block)
    else
      # .each_slice(2) takes [0, 1, 2, 3] and gives [[0, 1], [2, 3]]
      # .flat_map(&:reverse) turns it into [1, 0, 3, 2]
      return @battlers.each_slice(2).flat_map(&:reverse).each(&block)
    end
  end

  def isOnline?
    return false
  end

  def allMons(parties)
    allmons = []
    for party in parties
      for mon in party
        allmons.push(mon)
      end
    end
    return allmons
  end

  def checkPartyBosses(party)
    for mon in party
      return true if $cache.bosses[mon.bossID]
    end
    return false
  end

  ################################################################################
  # Initialise battle class.
  ################################################################################
  def initialize(scene, p1, p2, player, opponent, recorded = false, specialmoves = [])
    $battle          = self # Make current battle globally available for debugging
    @seed            = Time.now.to_i # Set the seed to the value from battle log file to reproduce the same battle scenario
    @battleRandom    = Random.new(@seed)
    @battle          = self
    @scene           = scene
    @decision        = 0
    @internalbattle  = true
    @doublebattle    = false
    @cantescape      = false
    @shiftStyle      = true
    @battlescene     = true
    @recorded        = recorded # deso npc commentary
    if opponent && player.is_a?(Array) && player.length == 0
      player = player[0]
    end
    if opponent && opponent.is_a?(Array) && opponent.length == 0
      opponent = opponent[0]
    end
    @player          = player                # PokeBattle_Trainer object
    @opponent        = opponent              # PokeBattle_Trainer object
    @party1          = p1
    @party2          = p2
    @partyorder      = [(0...PLAYERMAXPARTYSIZE).to_a]
    @partyorder2     = [(0...OPPONENTMAXPARTYSIZE).to_a]
    @partyorder.push  (0...PLAYERMAXPARTYSIZE).to_a if @player.is_a?(Array)
    @partyorder2.push (0...OPPONENTMAXPARTYSIZE).to_a if @opponent.is_a?(Array)
    @revealedPokemon = [] # Contains arrays that look like [side index, party index, pkmn index]
    @revealedBosses  = [] unless Desolation # Contains arrays that look like [species, form]
    @battlers        = []
    @items           = nil
    @partneritems    = nil
    @sides           = [
      Battle_Side.new(self, 0),   # Player's side
      Battle_Side.new(self, 1),   # Foe's side
    ]
    @state           = Battle_Global.new # Whole field (gravity/rooms)
    @field           = PokeBattle_Field.new(self)
    @environment     = :None # e.g. Tall grass, cave, still water
    @weather         = 0
    @weatherduration = 0
    @weatherbackup   = 0 #### DemICE - persistentweather
    @choices         = [[nil], [nil], [nil], [nil]]

    @specialchoices  = [[nil], [nil], [nil], [nil]]

    @successStates   = []
    @lastMoveUsed    = -1
    @lastMoveUser    = -1
    @synchronize     = [-1, -1, 0]
    @pickupA         = []
    @pickupB         = []
    @permanenteffects = Hash.new { |hash, key| hash[key] = {} }
    @specialMove     = []

    playernum = @player.is_a?(Array) ? @player.length : 1
    oppnum = @opponent.is_a?(Array) ? @opponent.length : 1

    @megaEvolution   = []
    @ultraBurst      = []
    @terastal        = []
    @zMove           = []
    @megaEvolution[0] = [-1] * playernum
    @ultraBurst[0]    = [-1] * playernum
    @terastal[0]      = [-1] * playernum
    @zMove[0]         = [-1] * playernum
    @megaEvolution[1] = [-1] * oppnum
    @ultraBurst[1]    = [-1] * oppnum
    @terastal[1]      = [-1] * oppnum
    @zMove[1]         = [-1] * oppnum

    @handled_opp_messages = []
    oppnum.times {
      @handled_opp_messages.push({ ace: false, entry: [], faint: [], boss: [] })
    }

    @amuletcoin      = false
    @echoedVoice     = 0
    @echoedThisRound = false
    @happyhour       = false
    @switchedOut     = []
    @extramoney      = 0
    @endspeech       = ""
    @endspeech2      = ""
    @endspeechwin    = ""
    @endspeechwin2   = ""
    @rules           = {}
    @turncount       = 0
    @speedData       = [{}, {}, {}, {}]
    @snaggedpokemon  = []
    @caughtpokemon   = []
    @delayEffectHash = {}
    @runCommand      = 0
    @disableExpGain  = false
    @eruption        = false # Volcanictop Eruption check
    @catchmessageplayed    = false
    @sosbattle       = :none # varies from :none for no sos pokemon, to :singlePokemonPlayerSide in cases where there's an SOS pokemon but the player only gets one pokemon, to :full
    @restoreItems    = Rejuv && $game_switches[:NotPlayerCharacter]
    @levelCap        = nil
    @raiseToLevel    = false
    @struggle = PokeBattle_Move.pbFromPBMove(self, PBMove.new(:STRUGGLE), nil)
    @struggle.pp = -1
    @specialParty = [[],[],[],[]]
    for i in 0...4
      @battlers[i] = PokeBattle_Battler.new(self, i)
    end
    @specialmoves = specialmoves
    @moveOrder  = @battlers.clone
    @speedOrder = @battlers.clone
    if !isOnline?
      for i in allMons(@party1)
        next if !i || i.nil?
        @permanenteffects[i][:Disobedient] = !i.obedient
      end
    end
    for i in allMons(@party1) + allMons(@party2)
      next if !i

      @permanenteffects[i][:ItemToKeep] = i.item # can be changed during battle
      @permanenteffects[i][:OriginalItem] = i.item # cannot be changed during battle

      i.changeFormOnBattleStart # Zacian / Zamazenta
    end
    if @recorded || @battle.FE == :CROWD
      createNewBattleRecord
    end
  end

  def setLevelCap(level, raiseToLevel = true)
    return if isOnline?
    @disableExpGain = true
    @restoreItems = true
    @levelCap = level
    @raiseToLevel = raiseToLevel
    for i in allMons(@party1) + allMons(@party2)
      next if !i || i.isEgg?

      if i.level > @levelCap || @raiseToLevel
        if @party1[0].include?(i)
          @permanenteffects[i][:StoredLevel] = i.level
          @permanenteffects[i][:StoredEXP] = i.exp
        end

        i.level = @levelCap
        i.exp = PBExp.startExperience(@levelCap, i.growthrate)
        i.calcStats
      end
    end
  end

  ################################################################################
  # Info about battle.
  ################################################################################
  def pbIsWild?
    return !@opponent ? true : false
  end

  def pbDoubleBattleAllowed?
    return true
  end

  def pbWeather(moveuser)
    # moveuser is provided when there's a move being used, as Mega Sol applies in only those cases
    return :SUNNYDAY if moveuser&.ability == :MEGASOL || moveuser&.crested == :SUNFLORA
    return :RAINDANCE if moveuser&.crested == :RAIKOU || moveuser&.pbPartner&.crested == :RAIKOU
    return 0 if pbCheckGlobalAbility([:CLOUDNINE, :AIRLOCK])
    return @weather
  end

  def canSetWeather?(newweather, primal: false, showMessage: false)
    blocker = @battle.FE == :SKY ? pbCheckGlobalAbility(:CLOUDNINE) : nil

    if blocker
      pbAbilityBoxAndDisplay(blocker, _INTL("But it failed!")) if showMessage
      return false
    elsif @state.effects[:NeverMeltIce]
      pbDisplay(_INTL("There is no relief from this frigid cold!")) if showMessage
      return false
    elsif @state.effects[:HeavyRain] && !primal
      pbDisplay(_INTL("There is no relief from this heavy rain!")) if showMessage
      return false
    elsif @state.effects[:HarshSunlight] && !primal
      pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!")) if showMessage
      return false
    elsif @state.effects[:DeltaStream] && !primal
      pbDisplay(_INTL("The mysterious air current blows on regardless!")) if showMessage
      return false
    elsif @field.effect == :NEWWORLD
      pbDisplay(_INTL("The weather drifted off into space...")) if showMessage
      return false
    elsif @field.effect == :UNDERWATER
      pbDisplay(_INTL("You're too deep to notice the weather!")) if showMessage
      return false
    elsif ([:SUPERHEATED, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@field.effect) || (@field.effect == :DRAGONSDEN && Rejuv)) && [:HAIL, :SNOW].include?(newweather)
      pbDisplay(newweather == :HAIL ? _INTL("The hail melted away.") : _INTL("The snow melted away.")) if showMessage
      return false
    elsif @field.effect == :INFERNAL && newweather == :RAINDANCE
      pbDisplay(_INTL("The rain evaporated.")) if showMessage
      return false
    elsif @weather == newweather
      if !primal
        pbDisplay(_INTL("But it failed!")) if showMessage
        return false
      else
        # No message since since primal weather setting never actually gets here, this is just a failsafe
        return false if newweather == :RAINDANCE && @state.effects[:HeavyRain]
        return false if newweather == :SUNNYDAY && @state.effects[:HarshSunlight]
        return false if newweather == :STRONGWINDS && @state.effects[:DeltaStream]
      end
    end
    return true
  end

  def pbSetWeather(weather, duration, message = nil, rainbowduration = nil, showanimation: true)
    weather = :HAIL if @field.effect == :FROZENDIMENSION && weather == :SNOW
    settingInitialWeather = weather == @weatherbackup
    weatherbefore = @weather
    @weather = weather
    @weatherduration = settingInitialWeather ? -1 : duration
    @state.effects[:HeavyRain] = false
    @state.effects[:HarshSunlight] = false
    @state.effects[:DeltaStream] = false
    @state.effects[:NeverMeltIce] = false
    # Persistent weather message
    pbDisplay(_INTL("The weather returned to its original state!")) if settingInitialWeather
    # Animation
    animation = case @weather
      when :SUNNYDAY then "Sunny"
      when :RAINDANCE then "Rain"
      when :SANDSTORM then "Sandstorm"
      when :HAIL, :SNOW then "Hail"
      when :STRONGWINDS then "Wind"
      when :SHADOWSKY then "SHADOWSKY"
      else nil
    end
    pbCommonAnimation(animation) if animation && showanimation
    # Main message
    if message.nil?
      message = case @weather
        when :SUNNYDAY then _INTL("The sunlight turned harsh!")
        when :RAINDANCE then _INTL("It started to rain!")
        when :SANDSTORM then _INTL("A sandstorm kicked up!")
        when :HAIL then _INTL("It started to hail!")
        when :SNOW then _INTL("It started to snow!")
        when :STRONGWINDS then _INTL("Strong winds kicked up around the field!")
        when :SHADOWSKY then _INTL("A shadowy aura filled the sky!")
        else nil
      end
    end
    pbDisplay(message) if message
    # Starlight Arena
    if blockedStarlight?(nil, @weather) && !blockedStarlight?(nil, weatherbefore)
      message = case @weather
        when :SUNNYDAY then _INTL("The sunlight eclipsed the starry sky!")
        when :SHADOWSKY then _INTL("The shadowy sky blocked out the starlight!")
        else _INTL("The weather blocked out the starry sky!")
      end
      pbDisplay(message)
    end
    # Darkness Field
    if @weather == :SUNNYDAY
      reduceField if ProgressiveFieldCheck(PBFields::DARKNESS, 2, 3)
    end
    # Rainbow Field
    if (@weather == :RAINDANCE && weatherbefore == :SUNNYDAY) || (@weather == :SUNNYDAY && weatherbefore == :RAINDANCE)
      if canChangeFE? && !(@field.effect == :RAINBOW && @field.duration <= 0)
        rainbowduration = rainbowduration || duration
        if @field.effect == :RAINBOW
          pbCommonAnimation("RainbowE")
          pbDisplay(_INTL("The weather refreshed the rainbow!"))
          @field.duration = rainbowduration if @field.duration < rainbowduration
        else
          message = _INTL("The weather created a rainbow!")
          setField(:RAINBOW, rainbowduration, message)
        end
      end
    end
    # Ice Face
    # This placement should be sufficient because according to showdown, Ice Face doesn't
    # activate when the Cloud Nine mon leaves the field while Hail/Snow weather is active.
    if [:HAIL, :SNOW].include?(pbWeather(nil))
      priority = setSpeedOrder
      for facemon in priority
        if facemon.ability == :ICEFACE && facemon.species == :EISCUE && facemon.form == 1
          pbShowAbilityBox(facemon)
          facemon.pbRegenFace
          pbDisplay(_INTL("{1} transformed!", facemon.name))
          pbHideAbilityBox(facemon)
        end
      end
    end
    # Things to check whenever weather changes
    setSpeedOrder.each { |i| i.pbCheckWeatherForm }
    protosynthesisCheck
  end

  def pbEndWeather(showMessage: true, noPersistent: false, endOfRound: false)
    return if @weather == 0

    if showMessage
      message = case @weather
        when :SUNNYDAY then @state.effects[:HarshSunlight] ? _INTL("The extremely harsh sunlight faded!") : _INTL("The harsh sunlight faded.")
        when :RAINDANCE then @state.effects[:HeavyRain] ? _INTL("The heavy rain has lifted!") : _INTL("The rain stopped.")
        when :SANDSTORM then _INTL("The sandstorm subsided.")
        when :HAIL then _INTL("The hail stopped.")
        when :SNOW then _INTL("The snow stopped.")
        when :STRONGWINDS then @state.effects[:DeltaStream] ? _INTL("The mysterious air current has dissipated!") : _INTL("The strong wind petered out.")
        when :SHADOWSKY then _INTL("The shadowy aura faded away!")
        else nil
      end
      pbDisplay(message) if message
    end

    pbDisplay(_INTL("The starry sky shone through!")) if blockedStarlight?(nil, @weather)

    @weather = 0
    @weatherduration = 0
    @state.effects[:HeavyRain] = false
    @state.effects[:HarshSunlight] = false
    @state.effects[:DeltaStream] = false
    @weatherbackup = 0 if noPersistent

    v = persistentWeather(endOfRound: endOfRound)
    unless v
      # If persistentWeather set up a new weather, these things have already been checked, no need to do it again
      setSpeedOrder.each { |i| i.pbCheckWeatherForm }
      protosynthesisCheck
    end
  end

  def quarkdriveCheck
    priority = setSpeedOrder
    if @field.effect == :ELECTERRAIN || @field.overlay == :ELECTERRAIN || @field.effect == :NEWWORLD
      for i in priority
        next if i.isFainted?
        next if i.ability != :QUARKDRIVE
        next if i.effects[:Quarkdrive][0] != 0
        next if i.effects[:Transform]

        boostStat = i.getHighestStatWithStages
        i.effects[:Quarkdrive] = [boostStat, false]
        cause = @field.effect == :NEWWORLD ? _INTL("ethereal energy") : _INTL("Electric Terrain")
        pbAbilityBoxAndDisplay(i, _INTL("The {1} activated {2}'s {3}, heightening its {4}!", cause, i.pbThis(true), getAbilityName(i.ability), getStatName(boostStat)))
      end
    else
      for i in priority
        next if i.isFainted?
        next if i.effects[:Quarkdrive][0] == 0
        next if i.effects[:Quarkdrive][1] == true

        i.effects[:Quarkdrive][0] = 0
        pbDisplay(_INTL("{1}'s {2} wore off!", i.pbThis, getAbilityName(i.ability)))
        if i.hasWorkingItem(:BOOSTERENERGY) && i.ability == :QUARKDRIVE && !i.effects[:Transform]
          pbCommonAnimation("UseItem", i, nil)
          boostStat = i.getHighestStatWithStages
          i.effects[:Quarkdrive] = [boostStat, true]
          pbAbilityBoxAndDisplay(i, _INTL("{1} used its {2} to activate {3}, heightening its {4}!", i.pbThis, getItemName(i.item), getAbilityName(i.ability), getStatName(boostStat)))
          i.pbDisposeItem
        end
      end
    end
  end

  def protosynthesisCheck
    priority = setSpeedOrder
    if pbWeather(nil) == :SUNNYDAY || @field.effect == :NEWWORLD || Rejuv && [:DESERT].include?(@battle.FE)
      for i in priority
        next if i.isFainted?
        next if i.ability != :PROTOSYNTHESIS
        next if i.effects[:Protosynthesis][0] != 0
        next if i.effects[:Transform]

        boostStat = i.getHighestStatWithStages
        i.effects[:Protosynthesis] = [boostStat, false]
        cause = @field.effect == :NEWWORLD ? _INTL("ethereal energy") : _INTL("harsh sunlight")
        pbAbilityBoxAndDisplay(i, _INTL("The {1} activated {2}'s {3}, heightening its {4}!", cause, i.pbThis(true), getAbilityName(i.ability), getStatName(boostStat)))
      end
    else
      for i in priority
        next if i.isFainted?
        next if i.effects[:Protosynthesis][0] == 0
        next if i.effects[:Protosynthesis][1] == true

        i.effects[:Protosynthesis][0] = 0
        pbDisplay(_INTL("{1}'s {2} wore off!", i.pbThis, getAbilityName(i.ability)))
        if i.hasWorkingItem(:BOOSTERENERGY) && i.ability == :PROTOSYNTHESIS && !i.effects[:Transform]
          pbCommonAnimation("UseItem", i, nil)
          boostStat = i.getHighestStatWithStages
          i.effects[:Protosynthesis] = [boostStat, true]
          pbAbilityBoxAndDisplay(i, _INTL("{1} used its {2} to activate {3}, heightening its {4}!", i.pbThis, getItemName(i.item), getAbilityName(i.ability), getStatName(boostStat)))
          i.pbDisposeItem
        end
      end
    end
  end

  def pbStatChangeChecks
    return if @battlers.any? { |i| i.applyingEntryEffects }

    # White Herb
    priority = setSpeedOrder
    priority.each { |battler| battler.triggerWhiteHerb if battler.hasWorkingItem(:WHITEHERB) }

    # Opportunist / Mirror Herb
    priority = setSpeedOrder
    for battler in priority
      next if battler.isFainted?
      next if ![:OPPORTUNIST, :MEMORYLEAK].include?(battler.ability) && !battler.hasWorkingItem(:MIRRORHERB)
      next if battler.ability == :MEMORYLEAK && !(battler.pbPartner.hp > 0)

      hash = Hash.new(0)
      for i in priority
        next if !battler.pbIsOpposing?(i.index) && battler.ability != :MEMORYLEAK
        next if battler.index != i.index && battler.ability == :MEMORYLEAK
        i.copyableStatBoosts.each { |stat, amount| hash[stat] += amount }
      end

      if battler.ability == :MEMORYLEAK
        next if hash.none? { |stat, amount| amount > 0 && (stat == :crit ? battler.pbPartner.effects[:FocusEnergy] < amount : battler.pbPartner.pbCanIncreaseStatStage?(stat, battler.pbPartner, nil)) }
      else
        next if hash.none? { |stat, amount| amount > 0 && (stat == :crit ? battler.effects[:FocusEnergy] < amount : battler.pbCanIncreaseStatStage?(stat, battler, nil)) }
      end

      if battler.ability == :MEMORYLEAK
        pbShowAbilityBox(battler)
        battler.pbPartner.pbOpportunistCopy(hash, memoryleak: true)
        pbHideAbilityBox(battler)
      end

      if battler.ability == :OPPORTUNIST
        pbShowAbilityBox(battler)
        battler.pbOpportunistCopy(hash)
        pbHideAbilityBox(battler)
      end

      if battler.hasWorkingItem(:MIRRORHERB)
        pbShowAbilityBox(battler, item: true)
        pbCommonAnimation("UseItem", battler, nil)
        pbDisplay(_INTL("{1} used its {2} to mirror its opponent's stat boosts!", battler.pbThis, getItemName(battler.item)))
        battler.pbOpportunistCopy(hash)
        pbHideAbilityBox(battler)
        battler.pbDisposeItem
      end
    end
    priority.each { |battler| battler.copyableStatBoosts.clear }

    # Eject Pack
    priority = setSpeedOrder
    priority.each { |battler| battler.pbEjectPackCheck }
  end

  def itemActivationsCheck
    # Ability Shield vs Neutralizing Gas
    if pbCheckGlobalAbility(:NEUTRALIZINGGAS)
      priority = setSpeedOrder
      for i in priority
        if i.hasWorkingItem(:ABILITYSHIELD) && i.ability == nil && i.backupability != nil && !i.effects[:GastroAcid]
          i.ability = i.backupability
        elsif !i.hasWorkingItem(:ABILITYSHIELD) && !(PBStuff::FIXEDABILITIES + [:NEUTRALIZINGGAS]).include?(i.ability)
          i.changeAbilityWithEffects(:suppress)
        end
      end
    end
    # Utility Umbrella vs Castform/Cherrim
    setSpeedOrder.each { |i| i.pbCheckWeatherForm }
  end

  # The next two methods are used for applying effects by boss shield breaks and trainer skills
  def pbApplySideEffect(effect, effectval, side, agent)
    if effectval.is_a?(Integer) && effectval > 0 && side.effects[effect] > 0
      effectval = side.effects[effect] + effectval
      limits = {
        :Tailwind => 8, :Reflect => 8, :LightScreen => 8, :AuroraVeil => 8, :AreniteWall => 8,
        :Spikes => 3, :ToxicSpikes => 2, :Safeguard => 8, :Mist => 8, :LuckyChant => 8,
        :AntiMatterShield => 8,
      }
      effectval = limits[effect] if limits[effect] && effectval > limits[effect]
    end
    case effect
      when :StickyWeb then side.effects[effect] = agent.pokemon
      when :StealthRock then side.effects[effect] = effectval
      when :Tailwind then pbSetTailwind(effectval, side)
      else side.effects[effect] = effectval
    end
  end

  def pbApplyGlobalEffect(effect, effectval)
    if effectval.is_a?(Integer) && effectval > 0 && @state.effects[effect] > 0
      effectval = @state.effects[effect] + effectval
      limits = {
        :TrickRoom => 8, :WonderRoom => 8, :MagicRoom => 8, :Gravity => 8, :MudSport => 5,
        :WaterSport => 5,
      }
      effectval = limits[effect] if limits[effect] && effectval > limits[effect]
    end
    case effect
      when :TrickRoom then pbSetTrickRoom(effectval)
      when :WonderRoom then pbSetWonderRoom(effectval)
      when :Gravity then pbSetGravity(effectval)
      else @state.effects[effect] = effectval
    end
  end

  def pbSetTrickRoom(duration)
    @state.effects[:TrickRoom] = duration
    priority = setSpeedOrder
    priority.each { |i| i.roomServiceCheck unless i.isFainted? }
  end

  def pbSetWonderRoom(duration)
    @state.effects[:WonderRoom] = duration
    @battlers.each { |i| i.pbSwapDefenses }
  end

  def pbEndWonderRoom
    @state.effects[:WonderRoom] = 0
    @battlers.each { |i| i.pbSwapDefenses if i.wonderroom }
  end

  def pbSetGravity(duration)
    @state.effects[:Gravity] = duration
    eachBattler { |i| i.applyGravity unless i.isFainted? } # correct
    if @field.effect == :NEWWORLD
      message = _INTL("The world's matter reformed!")
      setField(:STARLIGHT, duration, message, ignoreOverlays: true) # temporary field transition, never should be an overlay, failsafe implementation
      @field.duration_condition = proc { |battle| battle.state.effects[:Gravity] != 0 }
      @field.permanent_condition = proc { |battle| battle.FE != :STARLIGHT }
    end
  end

  def pbSetTailwind(duration, side)
    side.effects[:Tailwind] = duration
    battler = @battlers[side.index] # pbCheckSideAbility needs a battler parameter
    for abilityholder in pbCheckSideAbility(:WINDPOWER, battler)
      pbShowAbilityBox(abilityholder)
      abilityholder.effects[:Charge] = 2
      pbAnimation(:CHARGE, abilityholder, nil)
      pbDisplay(_INTL("Being hit by {1} charged {2} with power!", getMoveName(:TAILWIND), abilityholder.pbThis(true)))
      pbHideAbilityBox(abilityholder)
    end
    for abilityholder in pbCheckSideAbility(:WINDRIDER, battler)
      if abilityholder.pbCanIncreaseStatStage?(PBStats::ATTACK, abilityholder, nil)
        pbShowAbilityBox(abilityholder)
        abilityholder.pbChangeStats(PBStats::ATTACK, 1, abilityholder, nil, abilitycheck: :skip)
        pbHideAbilityBox(abilityholder)
      end
    end
    if [:MOUNTAIN, :SNOWYMOUNTAIN, :VOLCANICTOP, :SKY].include?(@field.effect) && canSetWeather?(:STRONGWINDS)
      duration = @field.effect == :SKY ? 8 : 6
      pbSetWeather(:STRONGWINDS, duration)
    end
  end

  def pbEndSideEffects(sides, effects)
    sides = Array(sides)
    effects.each { |effect| sides.each { |side| side.endEffect(effect) } }
  end

  ################################################################################
  # Get battler info.
  ################################################################################
  def pbIsOpposing?(index)
    return index.odd?
  end

  def pbOwnedByPlayer?(index)
    return false if pbIsOpposing?(index)
    return false if @player.is_a?(Array) && index == 2
    return false if @battle.battlers[index].issosmon

    return true
  end

  def pbOwnedByAIPartner?(index)
    # primarily a check for multi-battles.
    return @player.is_a?(Array) && index == 2
  end

  def aiControlled?(index)
    return true if @controlPlayer
    return false if pbOwnedByPlayer?(index)
    return false if pbOwnedByAIPartner?(index) && $game_switches[:Control_Partners]
    return true
  end

  def pbIsDoubleBattler?(index)
    return index >= 2
  end

  def pbThisEx(battlerindex, pokemonindex)
    party = pbPartySingleOwner(battlerindex)
    if pbIsOpposing?(battlerindex)
      if @opponent || party[pokemonindex].sosmon
        return _INTL("The foe's {1}", party[pokemonindex].name)
      elsif Rejuv && party[pokemonindex].isbossmon && party[pokemonindex].bossID != :SHADOWDEN
        return party[pokemonindex].name
      else
        return _INTL("The wild {1}", party[pokemonindex].name)
      end
    else
      return party[pokemonindex].name
    end
  end

  # Checks whether an item can be removed from a Pokémon.
  def pbIsUnlosableItem(pkmn, item, symbiosis: false)
    return true if pbIsMail?(item)
    return true if pbIsZCrystal?(item) && !(Rejuv && symbiosis)
    return false if pkmn.effects[:Transform]
    return true if pkmn.species == :ARCEUS && pkmn.ability == :MULTITYPE && $cache.items[item].checkFlag?(:plate)
    return true if pkmn.species == :SILVALLY && (pkmn.ability == :RKSSYSTEM || pkmn.crested == :SILVALLY) && $cache.items[item].checkFlag?(:memory)
    return true if PBStuff::POKEMONTOMEGASTONE[pkmn.species].include?(item) && !(Rejuv && symbiosis)
    return true if Rejuv && (PBStuff::POKEMONTOCREST[pkmn.species] == item || item == :BLKPRISM) && !symbiosis
    return true if Rejuv && pkmn.effects[:clearDisguise] && PBStuff::POKEMONTOCREST[pkmn.pokemon.species] == item
    return true if Rejuv && item == :ZOROCREST && pkmn.effects[:Illusion]
    return true if pkmn.species == :GENESECT && [:SHOCKDRIVE, :BURNDRIVE, :CHILLDRIVE, :DOUSEDRIVE].include?(item)
    return true if pkmn.species == :GROUDON && item == :REDORB
    return true if pkmn.species == :KYOGRE && item == :BLUEORB
    return true if pkmn.species == :DIALGA && item == :ADAMANTCRYSTAL
    return true if pkmn.species == :PALKIA && item == :LUSTROUSGLOBE
    return true if pkmn.species == :GIRATINA && item == :GRISEOUSCORE
    return true if pkmn.species == :ZACIAN && item == :RUSTEDSWORD
    return true if pkmn.species == :ZAMAZENTA && item == :RUSTEDSHIELD
    return true if [:QUARKDRIVE, :PROTOSYNTHESIS].intersect?([pkmn.ability, pkmn.backupability]) && item == :BOOSTERENERGY
    return true if pkmn.species == :OGERPON && [:WELLSPRINGMASK, :HEARTHFLAMEMASK, :CORNERSTONEMASK].include?(item)

    return false
  end

  def pbCheckSideAbility(abilities, battler, excludeSelf: false, checkMoldBroken: false, moldBrokenArray: nil)
    abilities = Array(abilities)
    abilityholders = []
    for i in @battlers
      # important to check using indexes here since the 'battler' may not be present on the field, as in the case of a Future Sight user
      next if battler.pbIsOpposing?(i.index)
      next if excludeSelf && i == battler
      next if !abilities.include?(i.ability)
      next if checkMoldBroken && (moldBrokenArray ? moldBrokenArray[i.index] : i.moldbroken)

      abilityholders.push(i)
    end
    return abilityholders
  end

  def pbCheckSideCrest(crest, battler, excludeSelf: false)
    crestholders = []
    for i in @battlers
      # important to check using indexes here since the 'battler' may not be present on the field, as in the case of a Future Sight user
      next if battler.pbIsOpposing?(i.index)
      next if excludeSelf && i == battler
      next if i.crested != crest

      crestholders.push(i)
    end
    return crestholders
  end

  def pbCheckSideItem(item, battler, excludeSelf: false)
    itemholders = []
    for i in @battlers
      # important to check using indexes here since the 'battler' may not be present on the field, as in the case of a Future Sight user
      next if battler.pbIsOpposing?(i.index)
      next if excludeSelf && i == battler
      next if i.item != item

      itemholders.push(i)
    end
    return itemholders
  end


  def pbCheckGlobalAbility(abilities)
    abilities = Array(abilities)
    return @battlers.any? { |i| abilities.include?(i.ability) }
  end

  def pbFindGlobalAbilityUser(abilities, checkMoldBroken: false, moldBrokenArray: nil)
    abilities = Array(abilities)
    priority = setSpeedOrder
    for i in priority
      next if !abilities.include?(i.ability)
      next if checkMoldBroken && (moldBrokenArray ? moldBrokenArray[i.index] : i.moldbroken)

      return i
    end
    return nil
  end

  def priorityBlockingAbilities
    return [:DAZZLING, :QUEENLYMAJESTY, :ARMORTAIL] + (@field.effect == :STARLIGHT ? [:MIRRORARMOR] : [])
  end

  def magicGuardAbilities
    return [:MAGICGUARD] + (@field.effect == :COLOSSEUM ? [:WONDERGUARD] : [])
  end

  ################################################################################
  # Player-related info.
  ################################################################################
  def pbPlayer
    return @player.is_a?(Array) ? @player[0] : @player
  end

  def pbGetOwnerItems(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return [] if !@items
      if @opponent.is_a?(Array)
        return battlerIndex == 1 ? @items[0] : @items[1]
      else
        return @items
      end
    elsif @player.is_a?(Array) && battlerIndex == 2
      return [] if !@partneritems

      return @partneritems
    else
      return []
    end
  end

  def items=(items)
    @items = items.clone
  end

  def pbGetMegaRingName(battlerIndex)
    if pbBelongsToPlayer?(battlerIndex) || pbBelongsToAlterEgo?(battlerIndex)
      for i in MegaZItems
        return getItemName(i) if $PokemonBag.pbHasItem?(i)
      end
    else
      for i in MegaZItems
        return getItemName(i) if pbGetOwnerItems(battlerIndex).include?(i)
      end
    end
    if (@battlers[battlerIndex].isbossmon || @battlers[battlerIndex].issosmon) && !@opponent
      return _INTL("bursting energy")
    end
    if Reborn && pbGetOwner(battlerIndex).trainertype == :HYPNO2
      # For 'trainer is a pokemon' situations, but this is the only one that matters w/o randomizer
      return _INTL("bursting energy")
    end
    if Reborn && ANOMALYLIST.include?(pbGetOwner(battlerIndex).trainertype)
      return _INTL("anomalous energy")
    end
    return _INTL("Key Stone")
  end

  def pbHasMegaRing(battlerIndex)
    return true if !(pbBelongsToPlayer?(battlerIndex) || pbBelongsToAlterEgo?(battlerIndex))

    return MegaZItems.any? { |i| $PokemonBag.pbHasItem?(i) }
  end

  def pbHasZRing(battlerIndex)
    return true if !(pbBelongsToPlayer?(battlerIndex) || pbBelongsToAlterEgo?(battlerIndex))

    return MegaZItems.any? { |i| $PokemonBag.pbHasItem?(i) }
  end

  def pbHasTeraOrb(battlerIndex)
    # boss pokemon and their SoS supports can be assumed that they can tera without a tera orb in the style of tera raids
    return true if (@battlers[battlerIndex].isbossmon || @battlers[battlerIndex].issosmon) && !pbGetOwner(battlerIndex)
    # the player needs to have a tera orb in their posession, we don't worry about having to charge it up
    # the reborn alter ego trainers are also considered having a tera orb if the player has one
    if pbBelongsToPlayer?(battlerIndex) || pbBelongsToAlterEgo?(battlerIndex)
      return $PokemonBag.pbHasItem?(:TERAORB)
    end
    # other non-player trainers still need to have the tera orb on their itemlist to terastallize
    return pbGetOwnerItems(battlerIndex).include?(:TERAORB)
  end

  ################################################################################
  # Get party info, manipulate parties.
  ################################################################################
  def pbPokemonCount(party)
    count = 0
    for i in party
      next if !i

      count += 1 if (i.hp > 0 && !i.isEgg? && !i.stolen && !i.unusable) || (i.isbossmon && i.shieldCount > 0)
    end
    return count
  end

  def pbPokemonCountAllParties(parties)
    count = 0
    for party in parties
      count += pbPokemonCount(party)
    end
    return count
  end

  def pbAllFainted?(party)
    pbPokemonCount(party) == 0
  end

  def pbAllFaintedAllParties?(parties)
    for party in parties
      return false if !pbAllFainted?(party)
    end
    return true
  end

  def pbAnySideAllFainted?
    return pbAllFaintedAllParties?(@party1) || pbAllFaintedAllParties?(@party2)
  end

  def pbBothSidesAllFainted?
    return pbAllFaintedAllParties?(@party1) && pbAllFaintedAllParties?(@party2)
  end

  def pbMaxLevelFromIndex(index)
    party = pbPartySingleOwner(index)
    maxlevel = 0
    for i in party
      next if !i
      maxlevel = i.level if maxlevel < i.level
    end
    return maxlevel
  end

  def pbMaxLevel(party)
    lv = 0
    for i in party
      next if !i

      lv = i.level if lv < i.level
    end
    return lv
  end

  def pbParty(index)
    return pbIsOpposing?(index) ? @party2 : @party1
  end

  def pbCombinedParty(index)
    return allMons(pbIsOpposing?(index) ? @party2 : @party1)
  end

  def pbFindNextUnfainted(party, start = 0)
    for i in start...party.length
      next if !party[i]
      return i if party[i].hp > 0 && !party[i].isEgg?
    end
    return -1
  end

  def pbGetOwner(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return battlerIndex == 1 ? @opponent[0] : @opponent[1]
      else
        if @opponent.nil?
          if @battle.battlers[battlerIndex].isbossmon || @battle.battlers[battlerIndex].issosmon
            return @fakeopponent
          end
        else
          return @opponent
        end
      end
    else
      if @player.is_a?(Array)
        return battlerIndex == 0 ? @player[0] : @player[1]
      else
        return @player
      end
    end
  end

  def pbGetOwnerPartner(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return battlerIndex == 1 ? @opponent[1] : @opponent[0]
      else
        if @opponent.nil?
          if @battle.battlers[battlerIndex].isbossmon || @battle.battlers[battlerIndex].issosmon
            return @fakeopponent
          end
        else
          return @opponent
        end
      end
    else
      if @player.is_a?(Array)
        return battlerIndex == 0 ? @player[1] : @player[0]
      else
        return @player
      end
    end
  end

  def pbPartySingleOwner(battlerIndex)
    oi = pbGetOwnerIndex(battlerIndex)
    return pbIsOpposing?(battlerIndex) ? @party2[oi] : @party1[oi]
  end

  def pbPartySingleOwnerNonBattler(battler)
    party = pbPartySingleOwner(battler.index)
    party = party.find_all { |mon| !mon.nil? && battler.pokemon != mon }
    return party
  end

  def pbGetOwnerIndex(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return @opponent.is_a?(Array) ? (battlerIndex == 1 ? 0 : 1) : 0
    else
      return @player.is_a?(Array) ? (battlerIndex == 0 ? 0 : 1) : 0
    end
  end

  def pbBelongsToPlayer?(battlerIndex)
    if @player.is_a?(Array) && @player.length > 1
      return battlerIndex == 0
    end

    return battlerIndex % 2 == 0
  end

  def pbBelongsToInterceptor?(battlerIndex)
    return false if !Rejuv
    return false if pbGetOwner(battlerIndex).is_a?(Array)
    return false if pbGetOwner(battlerIndex) != @opponent
    return true if [:INTERCEPTORARMOR].include?(pbGetOwner(battlerIndex)&.trainertype) && pbGetOwner(battlerIndex)&.name == $Trainer.name
    return false
  end

  def pbBelongsToAlterEgo?(battlerIndex)
    return Reborn && AlterEgos.include?(pbGetOwner(battlerIndex)&.trainertype)
  end

  def pbAddToPlayerParty(pokemon)
    party = pbPartySingleOwner(0)
    for i in 0...party.length
      party[i] = pokemon if !party[i]
    end
  end

  def pbCreateSpecialParty(moves, pokemonIndex, battlerIndex)
    return if @specialParty[battlerIndex].length > 0
    for i in moves
      mon = PokeBattle_Pokemon.new(PBStuff::SPECIALMOVETOPOKEMON[i.move][0], 100, $Trainer, false, PBStuff::SPECIALMOVETOPOKEMON[i.move][1])
      mon.ev = PBStuff::SPECIALMOVETOPOKEMON[i.move][2]
      mon.nature = PBStuff::SPECIALMOVETOPOKEMON[i.move][3]
      mon.iv = Array.new(6,31)
      mon.calcStats
      mon.shinyflag = false
      mon = @ai.pbMakeFakeBattler(mon, pokemonIndex, false, battlerIndex)
      mon.effects[:Illusion] = nil if mon.effects[:Illusion]
      @specialParty[battlerIndex].push(mon)
    end
  end

  def pbRemoveFromParty(battlerIndex, partyIndex)
    party = pbPartySingleOwner(battlerIndex)
    party[partyIndex] = nil
    # The code for doubles doesn't work correctly but it doesn't seem to be actually necessary to move the indexes.
    # side = pbIsOpposing?(battlerIndex) ? @opponent : @player
    # if !side || !side.is_a?(Array) # Wild or single opponent
    #   party.compact!
    #   battler = @battlers[battlerIndex].pbPartner
    #   battler.pokemonIndex -= 1 if battler && battler.pokemonIndex > partyIndex
    #   # for i in battlerIndex...party.length
    #   #   for j in 0..3
    #   #     next if !@battlers[j]
    #   #     if pbGetOwner(j) == side && @battlers[j].pokemonIndex == i
    #   #       @battlers[j].pokemonIndex -= 1
    #   #       break
    #   #     end
    #   #   end
    #   # end
    # else
    #   if battlerIndex < pbSecondPartyBegin(battlerIndex) - 1
    #     for i in battlerIndex...pbSecondPartyBegin(battlerIndex)
    #       if i >= pbSecondPartyBegin(battlerIndex) - 1
    #         party[i] = nil
    #       else
    #         party[i] = party[i + 1]
    #       end
    #     end
    #   else
    #     for i in battlerIndex...party.length
    #       if i >= party.length - 1
    #         party[i] = nil
    #       else
    #         party[i] = party[i + 1]
    #       end
    #     end
    #   end
    # end
  end

  def pbIsEnemy(battlerIndex)
    return (battlerIndex % 2) != 0
  end

  def currentJurisdiction?
    return nil if !Rejuv
    return :NEVED if [623].include?($game_map.map_id) && $game_variables[:V14StoryPT3] < 11
    return :GEARA if [621].include?($game_map.map_id) && $game_switches[:GearaJurisdictionOn]
    return :PERCIVAL if [627, 682, 669, 439].include?($game_map.map_id)
    return nil
  end

  def pieceAssignment(party, trainer_array)
    return if party.length == 0
    pkmnparty = party.find_all { |mon| !mon.nil? && !mon.isEgg? && !mon.sosmon }
    pieces = getPiecesFromParty(pkmnparty, @doublebattle, !trainer_array)
    pkmnparty.each_with_index { |pkmn, i|
      @permanenteffects[pkmn][:Piece] = pieces[i]
    }
  end

  def pbOpeningMessage(trainer)
    line = trainer.teamAttributes[:openingLine]
    if line
      line = pbGetMessageFromHash(:OpeningSpeech, line)
      pbDisplayAutoPaused(line)
    end
  end

  # Last Pokemon script; credits to venom12 and HelioAU
  def pbAceMessage(index)
    trainer = pbGetOwner(index)
    return if !trainer

    oppindex = pbGetOwnerIndex(index)
    return if @handled_opp_messages[oppindex][:ace]

    unfaintedParty = pbPartySingleOwner(index).find_all{ |pkmn| pkmn && !pkmn.egg? && !pkmn.stolen && pkmn.hp > 0 }
    return unless unfaintedParty.all? { |pkmn| @battlers.any? { |battler| battler.pokemon == pkmn } }

    # acemusic may be defined either as just a string containing the track name,
    # or a hash with the following keys: name, volume, pitch, position, fadeIn, eval
    # (with all keys other than name being optional)
    ace_music = trainer.teamAttributes[:acemusic]
    ace_music = { name: $game_variables[:LastMonMusic] } if Desolation && $game_switches[:LastMon]
    ace_music = { name: ace_music } if ace_music.is_a?(String)
    if ace_music
      volume = ace_music[:volume] || 100
      pitch = ace_music[:pitch] || 100
      position = ace_music[:position] || 0
      fadeIn = ace_music[:fadeIn] || false
      condition = eval(ace_music[:eval] || "true")
      pbBGMPlay(ace_music[:name], volume, pitch, position: position, fadeIn: fadeIn) if condition
    end

    ace_text = trainer.teamAttributes[:ace]
    if ace_text
      ace_text = pbGetMessageFromHash(:AceSpeech, ace_text)
      pbDisplayTrainerMessage(ace_text, oppindex)
    end

    @handled_opp_messages[oppindex][:ace] = true
  end

  def pbPokemonEntryMessage(index, pokemon)
    trainer = pbGetOwner(index)
    return if !trainer

    oppindex = pbGetOwnerIndex(index)
    pkmnindex = pbPartySingleOwner(index).index(pokemon)
    return if @handled_opp_messages[oppindex][:entry].include?(pkmnindex)
    return if pbIsRevealedPokemon?(1, oppindex, pkmnindex)

    line = trainer.teamAttributes.dig(:entryLines, pkmnindex)
    return unless line

    msg = pbGetMessageFromHash(:OtherTrainerSpeech, line)
    pbDisplayTrainerMessage(msg, oppindex)

    @handled_opp_messages[oppindex][:entry].push(pkmnindex)
  end

  def pbOnFaintMessages
    Array(@opponent).each.with_index { |trainer, oppindex|
      lines = trainer.teamAttributes[:faintLines] || {}
      lines.each { |pkmnindex, line|
        next if @handled_opp_messages[oppindex][:faint].include?(pkmnindex)
        next unless @party2[oppindex][pkmnindex].hp <= 0

        msg = pbGetMessageFromHash(:OtherTrainerSpeech, line)
        pbDisplayTrainerMessage(msg, oppindex)

        @handled_opp_messages[oppindex][:faint].push(pkmnindex)
      }
    }
  end

  ################################################################################
  # Check whether actions can be taken.
  ################################################################################
  def pbCanShowCommands?(idxPokemon)
    thispkmn = @battlers[idxPokemon]
    return false if thispkmn.isFainted?
    return false if thispkmn.effects[:Commander]
    return false if thispkmn.effects[:TwoTurnAttack] != 0
    return false if thispkmn.effects[:HyperBeam] > 0
    return false if thispkmn.effects[:Rollout] > 0
    return false if thispkmn.effects[:Outrage] > 0
    return false if thispkmn.effects[:Rage] && @field.effect == :GLITCH
    return false if thispkmn.effects[:Uproar] > 0
    return false if thispkmn.effects[:Bide] > 0

    return (thispkmn.chargeTurns? == true && !thispkmn.chargeAttack[:canAttack]) ? false : true
    return true
  end

  def zMove
    return @zMove
  end

  ################################################################################
  # Attacking.
  ################################################################################
  def pbCanShowFightMenu?(idxPokemon)
    return false if !pbCanShowCommands?(idxPokemon)
    return false if [0, 1, 2, 3].none? { |i| pbCanChooseMove?(idxPokemon, i) }
    return true
  end

  def pbCanChooseMove?(idxPokemon, idxMove, zpower: nil, sleeptalk: false, instructed: false, showMessage: false)
    if idxPokemon.is_a?(PokeBattle_Battler) # Used by AI, we need to run this for fake battlers of not-on-field pokemon too
      pkmn = idxPokemon
      idxPokemon = pkmn.index
    else
      pkmn = @battlers[idxPokemon]
    end
    side = pbIsOpposing?(idxPokemon) ? 1 : 0
    owner = pbGetOwnerIndex(idxPokemon)
    zpower = @zMove[side][owner] == idxPokemon if zpower.nil?
    if idxMove.is_a?(PokeBattle_Move) # Used by AI getAIMemory, fake moves are run through here too
      basemove = idxMove
      ppcheckmove = idxMove
      encorecheckindex = pkmn.moves.index(idxMove) # Can be nil
    else
      basemove = zpower && !sleeptalk ? pkmn.zmoves[idxMove] : pkmn.moves[idxMove]
      ppcheckmove = pkmn.moves[idxMove]
      encorecheckindex = idxMove
    end
    return false if !basemove

    unless zpower
      if pkmn.effects[:ChoiceBand] && pkmn.itemWorks? && [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(pkmn.item)
        if pkmn.moves.none? { |moveloop| moveloop.move == pkmn.effects[:ChoiceBand] }
          pkmn.effects[:ChoiceBand] = nil
        end
      end
      if pkmn.effects[:GorillaLock] && pkmn.ability == :GORILLATACTICS
        if pkmn.moves.none? { |moveloop| moveloop.move == pkmn.effects[:GorillaLock] }
          pkmn.effects[:GorillaLock] = nil
        end
      end
    end
    # There's probably a better place to put this

    opp1 = pkmn.pbOpposing1
    opp2 = pkmn.pbOpposing2
    failure = nil
    case true
      when pkmn.permeffs[:LifeBlood]#[:movesSuppression].include?(basemove.move)
        failure = :stopPN if pkmn.permeffs[:LifeBlood][:movesSuppression].include?(basemove.move)
      when (!zpower && !sleeptalk && basemove&.pp <= 0 && basemove&.totalpp > 0) || (zpower && !PBStuff::INTERCEPTMOVES.include?(basemove.move) && !sleeptalk && ppcheckmove&.pp <= 0 && ppcheckmove&.totalpp > 0)
        failure = :NoPP
      when !zpower && !sleeptalk && pkmn.effects[:ChoiceBand] &&
         pkmn.itemWorks? && [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(pkmn.item) &&
         pkmn.moves.any? { |moveloop| moveloop.move == pkmn.effects[:ChoiceBand] } &&
         basemove.move != pkmn.effects[:ChoiceBand]
        failure = :ChoiceBand
      when !zpower && !sleeptalk && pkmn.effects[:GorillaLock] &&
         pkmn.ability == :GORILLATACTICS &&
         pkmn.moves.any? { |moveloop| moveloop.move == pkmn.effects[:GorillaLock] } &&
         basemove.move != pkmn.effects[:GorillaLock]
        failure = :GorillaLock
      when pkmn.hasWorkingItem(:ASSAULTVEST) && !instructed && basemove.pbIsStatus? && basemove.move != :MEFIRST
        failure = :AssaultVest
      when !zpower && [opp1, opp2].any? { |opp| opp.effects[:Imprison] && opp.moves.any? { |oppmove| basemove.move == oppmove&.move } }
        failure = :Imprison
      when pkmn.effects[:Taunt] > 0 && basemove.pbIsStatus? && !zpower
        failure = :Taunt
      when pkmn.effects[:Torment] && !instructed && !zpower && basemove.move == pkmn.lastRegularMoveUsed
        failure = :Torment
      when basemove.hasFlag?(:cooldown) && !instructed && !sleeptalk && !zpower && basemove.move == pkmn.lastRegularMoveUsed
        # gigaton hammer can be executed if forced by encore, but not selected back to back
        failure = :Cooldown
      when pkmn.effects[:Disable] > 0 && basemove.move == pkmn.effects[:DisableMove] && !sleeptalk && !zpower
        failure = :Disable
      when pkmn.status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, pkmn).none? && (basemove.isHealingMove? || basemove.isDrainingMove?)
        failure = :Petrification
      when (basemove.isHealingMove? || basemove.isDrainingMove?) && !zpower && pkmn.effects[:HealBlock] > 0 && !basemove.specialmove
        failure = :HealBlock
      when basemove.checkSoundMove?(pkmn) && pkmn.effects[:ThroatChop] > 0 && !zpower
        failure = :ThroatChop
      when pkmn.effects[:Encore] > 0 && encorecheckindex != pkmn.effects[:EncoreIndex] && !zpower
        failure = :Encore
      when basemove.function == 0x13C && !pkmn.permeffs[:Belch] && pkmn.crested != :SWALOT && Gen < Champs
        failure = :BelchNoBerry
      when basemove.function == 0x17A && (pkmn.item.nil? || !pbIsBerry?(pkmn.item)) && Gen < Champs # Stuff Cheeks
        failure = :StuffCheeksNoBerry
      when basemove.unusableInGravity? && @state.effects[:Gravity] != 0 && !zpower
        failure = :Gravity
      when [0x012, 0x161].include?(basemove.function) && pkmn.turncount != 0 && Gen >= Champs # Fake Out / First Impression
        failure = :Generic
      when [0x113, 0x114].include?(basemove.function) && pkmn.effects[:Stockpile] == 0 && Gen >= Champs # Swallow / Spit Up
        failure = :Generic
      when basemove.function == 0x15E && !pkmn.hasType?(:FIRE) && Gen >= Champs # Burn Up
        failure = :Generic
      when basemove.function == 0x517 && !pkmn.hasType?(:ELECTRIC) && Gen >= Champs # Double Shock
        failure = :Generic
      when basemove.function == 0x125 && !pkmn.canLastResort? && Gen >= Champs # Last Resort
        failure = :Generic
    end
    return true unless failure

    if showMessage
      case failure
        when :stopPN then message = _INTL("{1}' {2} has been suppressed!", pkmn.pbThis, basemove.name)
        when :NoPP then message = _INTL("There's no PP left for this move!")
        when :ChoiceBand then message = _INTL("{1} only allows the use of {2}!", getItemName(pkmn.item), getMoveName(pkmn.effects[:ChoiceBand]))
        when :GorillaLock then message = _INTL("{1} only allows the use of {2}!", getAbilityName(pkmn.ability), getMoveName(pkmn.effects[:GorillaLock]))
        when :AssaultVest then message = _INTL("{1} prevents status moves from being used!", getItemName(pkmn.item, :The))
        when :Imprison then message = _INTL("{1} can't use its sealed {2}!", pkmn.pbThis, basemove.name)
        when :Taunt then message = _INTL("{1} can't use {2} after the taunt!", pkmn.pbThis, basemove.name)
        when :Torment then message = _INTL("{1} can't use the same move in a row due to the torment!", pkmn.pbThis)
        when :Cooldown then message = _INTL("{1} can't use {2} twice in a row!", pkmn.pbThis, basemove.name)
        when :Disable then message = _INTL("{1}'s {2} is disabled!", pkmn.pbThis, basemove.name)
        when :HealBlock then message = _INTL("{1} is prevented from healing, so it can't use {2}!", pkmn.pbThis, basemove.name)
        when :Petrification then message = _INTL("{1} is prevented from healing, so it can't use {2}!", pkmn.pbThis, basemove.name)
        when :ThroatChop then message = _INTL("{1} prevents {2} from using {3}!", getMoveName(:THROATCHOP), pkmn.pbThis(true), basemove.name)
        when :Encore then message = _INTL("{1} can only use {2}!", pkmn.pbThis, getMoveName(pkmn.effects[:EncoreMove]))
        when :BelchNoBerry then message = _INTL("{1} hasn't eaten any held Berries, so it can't possibly belch!", pkmn.pbThis)
        when :StuffCheeksNoBerry then message = _INTL("{1} can't use {2} without a berry!", pkmn.pbThis, basemove.name)
        when :Gravity then message = _INTL("{1} can't use {2} because of gravity!", pkmn.pbThis, basemove.name)
        when :Generic then message = _INTL("This move can't be used!")
      end
      pbDisplayCommandPaused(message)
    end
    return false
  end

  def pbAutoChooseMove(idxPokemon, showMessage = true)
    thispkmn = @battlers[idxPokemon]
    if thispkmn.isFainted?
      @choices[idxPokemon] = [nil]
      return true
    end
    if thispkmn.effects[:Encore] > 0 && pbCanChooseMove?(idxPokemon, thispkmn.effects[:EncoreIndex])
      PBDebug.dblog("[Auto choosing Encore move...]")
      # move choice array: [:move, idxmove, obj, idxtarget]
      @choices[idxPokemon] = [:move, thispkmn.effects[:EncoreIndex], thispkmn.moves[thispkmn.effects[:EncoreIndex]], -1] # No target chosen yet
      if @doublebattle
        basemove = thispkmn.moves[thispkmn.effects[:EncoreIndex]]
        targetchoices = thispkmn.pbTarget(basemove)
        if [:SingleNonUser, :DragonDarts, :NonUserPosition].include?(targetchoices)
          @scene.pbFightMenuEncore(idxPokemon, thispkmn.effects[:EncoreIndex])
          target = @scene.pbChooseTarget(idxPokemon)
          pbRegisterTarget(idxPokemon, target) if target >= 0
          return false if target < 0
        elsif [:SingleOpposing, :UserOrPartner].include?(targetchoices)
          @scene.pbFightMenuEncore(idxPokemon, thispkmn.effects[:EncoreIndex])
          target = @scene.pbChooseTargetOneSide(idxPokemon, targetchoices)
          pbRegisterTarget(idxPokemon, target) if target >= 0
          return false if target < 0
        end
      end
      return true
    else
      if !pbIsOpposing?(idxPokemon)
        pbDisplay(_INTL("{1} has no moves left that it can use!", thispkmn.pbThis)) if showMessage
      end
      @choices[idxPokemon] = [:move, -1, @struggle, -1]
      return true
    end
  end

  def pbRegisterMove(idxPokemon, idxMove, showMessage: false)
    return false if idxMove.nil?
    thispkmn = @battlers[idxPokemon]
    side = pbIsOpposing?(idxPokemon) ? 1 : 0
    owner = pbGetOwnerIndex(idxPokemon)
    basemove = @zMove[side][owner] == idxPokemon ? thispkmn.zmoves[idxMove] : thispkmn.moves[idxMove]
    thispkmn.selectedMove = basemove.move
    return false if !pbCanChooseMove?(idxPokemon, idxMove, showMessage: showMessage)

    @choices[idxPokemon] = [:move, idxMove, basemove, -1]
    return true
  end

  def pbPokemonFromSpecialParty(move, battler)
    for mon in @specialParty[battler.index]
      specialMovePoke = mon if mon.species == PBStuff::SPECIALMOVETOPOKEMON[move][0]
    end
    return specialMovePoke
  end

  def pbRegisterSpecialMove(idxPokemon, idxMove, showMessages = true)
    return false if idxMove.nil?
    thispkmn = @battlers[idxPokemon]
    side = pbIsOpposing?(idxPokemon) ? 1 : 0
    owner = pbGetOwnerIndex(idxPokemon)
    basemove = thispkmn.specialmoves[idxMove]
    thispkmn.selectedSpecialMove = basemove.move
    specialMovePoke = pbPokemonFromSpecialParty(basemove.move, @battlers[idxPokemon])

    if @sides[side].effects[:SpecialMoves][basemove.move] < basemove.chargetime
      pbDisplayPaused(_INTL("{1} isn't charged up yet!", thispkmn.specialmoves[idxMove].name)) if @sides[side].effects[:SpecialMoves][basemove.move] >= 0
      pbDisplayPaused(_INTL("{1} has been used up!", thispkmn.specialmoves[idxMove].name)) if @sides[side].effects[:SpecialMoves][basemove.move] < 0
      return false
    end
    if @specialchoices[thispkmn.pbPartner.index] != [nil]
      if @specialchoices[thispkmn.pbPartner.index][2].move == thispkmn.selectedSpecialMove
        pbDisplayPaused(_INTL("{1} is already selected!", thispkmn.specialmoves[idxMove].name))
        return false
      end
    end

    # @choices[idxPokemon] = [:move, idxMove, basemove, -1]
    @specialchoices[idxPokemon] = [:move, idxMove, basemove, -1, specialMovePoke, idxPokemon]
    return true
  end


  def pbChoseMoveFunctionCode?(i, code)
    return false if @battlers[i].isFainted?

    if @choices[i][0] == :move && @choices[i][1] >= 0
      choice = @choices[i][1]
      return @battlers[i].zmoves[choice].function == code if @choices[i][2].zmove

      return @battlers[i].moves[choice].function == code
    end
    return false
  end

  def pbRegisterTarget(idxPokemon, idxTarget)
    @choices[idxPokemon][3] = idxTarget # Set target of move
    return true
  end

  def pbRegisterSpecialMoveTarget(idxPokemon, idxTarget)
    @specialchoices[idxPokemon][3] = idxTarget # Set target of move
    return true
  end

  # Needs to be overridable for online battles.
  def pbTieBreak
    return 1
  end

  # Dynamic Speed stuff
  def setActPrioData
    for i in 0...@battlers.length
      @speedData[i][:actPriority] = 0
      @speedData[i][:actPriority] = -1 if @battlers[i].effects[:Quash]
      @speedData[i][:actPriority] = 1 if @battlers[i].effects[:AfterYou]
    end
  end

  def setMovePrioData
    return if @speedData[0][:movePriority] && !DynamicSpeed

    for i in 0...@battlers.length
      @speedData[i][:movePriority] = 0
      @speedData[i][:movePriority] = @choices[i][2].priorityCheck(@battlers[i]) if @choices[i][0] == :move
    end
  end

  def setSubPrioData
    return if @speedData[0][:subPriority]

    eachBattler do |battler| # correct
      i = battler.index
      @speedData[i][:subPriority] = 0
      if @choices[i][0] == :move
        @speedData[i][:subPriority] = -1 if battler.ability == :STALL || (battler.ability == :MYCELIUMMIGHT && @choices[i][2].pbIsStatus?)
        @speedData[i][:subPriority] = -1 if battler.itemWorks? && [:LAGGINGTAIL, :FULLINCENSE].include?(battler.item)
        if battler.ability == :QUICKDRAW && @choices[i][2].pbIsDamaging? && pbRandom(100) < 30
          @speedData[i][:subPriority] = 1
          battler.effects[:QuickDrawSnipe] = true if @battle.FE == :COLOSSEUM
          pbShowAbilityBox(battler)
          pbDisplayBrief(_INTL("{1} made {2} move faster!", getAbilityName(battler.ability), battler.pbThis(true)))
          pbHideAbilityBox(battler)
        elsif battler.hasWorkingItem(:QUICKCLAW) && pbRandom(100) < 20
          pbShowAbilityBox(battler, item: true)
          pbCommonAnimation("UseItem", battler, nil)
          @speedData[i][:subPriority] = 1
          pbDisplayBrief(_INTL("{1}'s {2} let it move first!", battler.pbThis, getItemName(battler.item)))
          pbHideAbilityBox(battler)
        elsif battler.pbCustapBerry
          @speedData[i][:subPriority] = 1
        end
      end
    end
  end

  def setTieBreakData
    return if @speedData[0][:tieBreak] && @phase == :attackPhase

    tieBreak = getTieBreakArray
    # In an online battle, pbTieBreak returns "0" for one client and "1" for the other client.
    # Both clients believe they are the "home side" of the battle, and both clients use the exact same RNG calls.
    # This means their tiebreak values would generate the exact same, down to the index.
    # So we need to tell the pbTieBreak "1" client to swap tiebreak data with the other side.
    if pbTieBreak == 0
      for i in 0...(@battlers.length / 2)
        tieBreak[2 * i], tieBreak[2 * i + 1] = tieBreak[2 * i + 1], tieBreak[2 * i]
      end
    end

    for i in 0...@battlers.length
      @speedData[i][:tieBreak] = tieBreak[i]
    end
  end

  def setSpeedData(megas = nil)
    return if @speedData[0][:speed] && !DynamicSpeed && !megas

    for i in 0...@battlers.length
      next if !DynamicSpeed && megas && !megas.include?(i)

      @speedData[i][:speed] = @state.effects[:TrickRoom] == 0 ? @battlers[i].pbSpeed : -@battlers[i].pbSpeed
    end
  end

  def setMoveOrder
    # Sets the order in which battlers execute their selected moves this turn
    # Returns this order
    # Use this method to get the remaining battlers that haven't moved yet this turn
    # Can also contain fainted battlers that tried to act

    # Filter out empty battle slots at the start of the turn
    @moveOrder.delete_if { |battler| battler.isFainted? } if @moveOrder.length == @battlers.length

    priorityarray = []
    for i in 0...@moveOrder.length
      index = @moveOrder[i].index
      priorityarray[i] = [
        @speedData[index][:actPriority],  # Action priority
        @speedData[index][:movePriority], # Move priority
        @speedData[index][:subPriority],  # Sub-priority
        @speedData[index][:speed],        # Calculated speed stat
        @speedData[index][:tieBreak],     # Tiebreak index
        index                             # Battler index
      ]
    end
    priorityarray.sort! { |a, b| b <=> a }

    for i in 0...@moveOrder.length
      @moveOrder[i] = @battlers[priorityarray[i][-1]]
    end

    return @moveOrder.clone
  end

  def getSpecialMoveUsers(moveOrder)
    specialmoveusers = moveOrder.select {|fakeBattler| @specialchoices[fakeBattler.index] != [nil] && fakeBattler.specialMoveUsed == false}
    specialmoveusers.map! {|mon| @specialchoices[mon.index][4]}
    return specialmoveusers
  end

  def setSpeedOrder(calcSpeedData: true)
    # Sets the order in which speed-related effects resolve this turn
    # Returns this order
    # Use this method to determine the order of the current speed stat of all battlers
    # End-of-turn effects primarily use this instead of move order
    if calcSpeedData
      setTieBreakData
      setSpeedData
    end

    priorityarray = []
    for i in 0...@battlers.length
      priorityarray[i] = [
        @speedData[i][:speed],       # Calculated speed stat
        @speedData[i][:tieBreak],    # Tiebreak index
        i                            # Battler index
      ]
    end
    priorityarray.sort! { |a, b| b <=> a }

    for i in 0...@battlers.length
      @speedOrder[i] = @battlers[priorityarray[i][-1]]
    end

    return @speedOrder.clone
  end

  def clearTurnOrderData
    @speedData  = [{}, {}, {}, {}]
    @moveOrder  = @battlers.clone
    @speedOrder = @battlers.clone
  end

  # Makes target pokemon move immediately next
  def pbMoveAfter(target)
    return if target.acted?

    target.effects[:AfterYou] = true
    setActPrioData
  end

  def pbClearChoices(index)
    @choices[index] = [nil]
  end

  ################################################################################
  # Switching Pokémon.
  ################################################################################
  def pbCanSwitchLax?(idxPokemon, pkmnidxTo, showMessage: false, revival: false)
    return true if pkmnidxTo < 0

    party = pbPartySingleOwner(idxPokemon)
    return false if pkmnidxTo >= party.length
    return false if !party[pkmnidxTo]
    return false if party[pkmnidxTo].nil?

    thispkmn = @battlers[idxPokemon]

    failure = nil
    case true
      when party[pkmnidxTo].unusable then failure = :Unusable
      when party[pkmnidxTo].hp > 0 && revival then failure = :Revival
      when party[pkmnidxTo].hp <= 0 && !revival then failure = :Fainted
      when party[pkmnidxTo].hp > 0 && revival then failure = :Revival
      when thispkmn.pokemonIndex == pkmnidxTo ||
       (pbGetOwnerIndex(idxPokemon) == pbGetOwnerIndex(thispkmn.pbPartner.index) &&
       thispkmn.pbPartner.pokemonIndex == pkmnidxTo)
        failure = :AlreadyInBattle
      when party[pkmnidxTo].stolen then failure = :Stolen
      when party[pkmnidxTo].isEgg? then failure = :Egg
      when party[pkmnidxTo].sosmon then failure = :SOS
      when !@opponent && pbIsOpposing?(idxPokemon) then failure = :WildPokemon
      when thispkmn.effects[:Commandee] then failure = :Commandee
    end
    return true unless failure

    if showMessage
      case failure
        when :Fainted then message = _INTL("{1} has no energy left to battle!", party[pkmnidxTo].name)
        when :Revival then message = _INTL("{1} isn't fainted!", party[pkmnidxTo].name)
        when :AlreadyInBattle then message = _INTL("{1} is already in battle!", party[pkmnidxTo].name)
        when :Revival then message = _INTL("{1} isn't fainted!", party[pkmnidxTo].name)
        when :Stolen then message = _INTL("{1} won't listen to your commands!", party[pkmnidxTo].name)
        when :Unusable then message = _INTL("{1} isn't responding!", party[pkmnidxTo].name)
        when :Egg then message = _INTL("An Egg can't battle!")
        when :Commandee then message = _INTL("{1} can't be switched out!", thispkmn.pokemon.name)
        else message = nil # SOS and WildPokemon failures don't need a message since they can't happen on player side
      end
      pbDisplayCommandPaused(message) if message
    end
    return false
  end

  def pbCanSwitch?(idxPokemon, pkmnidxTo, showMessage: false, ai_phase: false)
    # Multi-Turn Attacks/Mean Look
    return false if !pbCanSwitchLax?(idxPokemon, pkmnidxTo, showMessage: showMessage)

    thispkmn = @battlers[idxPokemon]
    isOpposing = pbIsOpposing?(idxPokemon)
    party = pbPartySingleOwner(idxPokemon)
    running = pkmnidxTo == -1

    failure = nil
    case true
      when !ai_phase && !running && pbGetOwnerIndex(idxPokemon) == pbGetOwnerIndex(thispkmn.pbPartner.index) && (0..3).any? { |i| isOpposing == pbIsOpposing?(i) && @choices[i][0] == :switch && @choices[i][1] == pkmnidxTo }
        failure = :AlreadyChosen
      when thispkmn.effects[:SkyDrop]
        failure = :SkyDrop
      when thispkmn.hasType?(:GHOST) && !([:DIMENSIONAL].include?(@field.effect) && pbCheckSideAbility(:SHADOWTAG, thispkmn.pbOpposing1).any?)
        return true
      when thispkmn.ability == :RUNAWAY && Gen >= Champs
        return true
      when thispkmn.hasWorkingItem(:SHEDSHELL)
        return true
      when @field.effect == :INFERNAL && thispkmn.status == :SLEEP && pbCheckSideAbility(:BADDREAMS, thispkmn.pbOpposing1).any?
        failure = :InfernalDreams
      when thispkmn.effects[:MultiTurn] > 0 || thispkmn.effects[:MeanLook] >= 0 || @state.effects[:FairyLock] == 1 || thispkmn.effects[:Octolock] >= 0
        failure = :Trapped
      when thispkmn.effects[:Ingrain]
        failure = :Ingrain
      when [:DIMENSIONAL, :FROZENDIMENSION].include?(@field.effect) && thispkmn.effects[:Embargo] > 0
        failure = :DimensionalEmbargo
      else
        abils = []
        abils.push(:MAGNETPULL) if thispkmn.hasType?(:STEEL)
        abils.push(:ARENATRAP) unless thispkmn.isAirborne?
        abils.push(:SHADOWTAG) unless thispkmn.ability == :SHADOWTAG
        trapper = pbCheckSideAbility(abils, thispkmn.pbOpposing1).first
        failure = :TrappingAbility if trapper
    end
    return true unless failure

    if showMessage
      case failure
        when :AlreadyChosen then message = _INTL("{1} has already been selected.", party[pkmnidxTo].name)
        when :SkyDrop, :Trapped, :Ingrain then message = running ? _INTL("{1} can't escape!", thispkmn.pbThis) : _INTL("{1} can't be switched out!", thispkmn.pbThis)
        when :InfernalDreams then message = running ? _INTL("{1}'s terrible dreams prevent it from escaping!", thispkmn.pbThis) : _INTL("{1}'s terrible dreams prevent it from being switched out!", thispkmn.pbThis)
        when :DimensionalEmbargo then message = running ? _INTL("{1} can't escape due to Embargo!", thispkmn.pbThis) : _INTL("{1} can't be switched out due to Embargo!", thispkmn.pbThis)
        when :TrappingAbility then message = running ? _INTL("{1} prevents escaping with {2}!", trapper.pbThis, getAbilityName(trapper.ability)) : _INTL("{1}'s {2} prevents switching!", trapper.pbThis, getAbilityName(trapper.ability))
      end
      pbDisplayCommandPaused(message)
    end
    return false
  end

  def pbRegisterSwitch(idxPokemon, idxOther)
    return false if !pbCanSwitch?(idxPokemon, idxOther)

    @choices[idxPokemon] = [:switch, idxOther]
    pbDisableAButtonChoices(idxPokemon)
    return true
  end

  def pbCanChooseNonActive?(index, exclude: nil)
    party = pbPartySingleOwner(index)
    return (0...party.length).any? { |i| i != exclude && pbCanSwitchLax?(index, i) }
  end

  def pbCanChooseNonActiveCount(index)
    party = pbPartySingleOwner(index)
    return (0...party.length).count { |i| pbCanSwitchLax?(index, i) }
  end

  def pbJudgeSwitch(favorDraws = false)
    if !favorDraws
      return if @decision > 0
    else
      return if @decision == 5
    end
    pbJudge()
    return if @decision > 0
  end

  def pbReplaceFaintedBattlers(favorDraws = false)
    # Show on-faint messages before fainted battlers are replaced
    pbOnFaintMessages

    if !favorDraws
      return if @decision > 0
    else
      return if @decision == 5
    end
    pbJudge()
    return if @decision > 0

    # Find which indices are fainted and need to be replaced
    switchers = (0...4).reject { |index|
      (!@doublebattle && pbIsDoubleBattler?(index)) ||
      (@battle.sosbattle == :singlePokemonPlayerSide && index == 2) ||
      (@battlers[index] && !@battlers[index].isFainted?)
    }
    return if switchers.empty?

    # Get which pokemon to switch into which battler slot for all slots
    finalswitcharray = []
    groupedswitchers = switchers.group_by { |i| pbGetOwner(i) }
    for trainer, indices in groupedswitchers
      next if !pbCanChooseNonActive?(indices.first) # All pokemon KO'd
      # If it's a wild battle and the player needs to make a replacement, give prompt to run first
      if pbIsWild? && @battlers.none? { |battler| battler.isbossmon } && trainer == $Trainer
        return if !pbDisplayConfirm(_INTL("Use next Pokémon?")) && pbRun(indices.first, true) > 0
      end

      switchhash = pbSwitchInBetween(indices.sort, true, false, :Replacement)
      for index, partyindex in switchhash
        next if partyindex < 0

        finalswitcharray.push([index, partyindex, false])
      end
    end

    # Sendout order is based on the speeds (without stages or modifiers) of the fainted battlers
    # speed attribute of fainted battlers is preserved till they are replaced so this just works
    priority = setSpeedOrder
    sendoutorder = finalswitcharray.sort_by{ |index, partyindex, shift| priority.index(@battlers[index]) }.reverse

    # Handle Shift mode
    if @shiftStyle && !isOnline? && @internalbattle && @battle.FE != :COLOSSEUM && !@doublebattle && !@controlPlayer && !pbIsWild? && switchers.any? { |i| pbIsOpposing?(i) } && !switchers.include?(0) && pbCanChooseNonActive?(0)
      incomingindex, incomingpartyindex, shift = sendoutorder.find { |index, partyindex, shift| pbIsOpposing?(index) }
      newname = pbSwitchInName(incomingindex, incomingpartyindex) # Illusion
      opponent = pbGetOwner(incomingindex)
      pbDisplayPaused(_INTL("{1} is\nabout to send in {2}.", opponent.fullname, newname))
      if pbDisplayConfirm(_INTL("Will you switch your Pokémon?"))
        partyindex = pbSwitchInBetween([0], true, true, :Replacement)[0]
        sendoutorder.prepend([0, partyindex, true]) unless partyindex < 0
      end
    end

    # First send out all pokemon in sendout order
    for index, partyindex, shift in sendoutorder
      if shift
        pbDisplayBrief(_INTL("{1}, that's enough!\nCome back!", @battlers[index].name))
        pbClearChoices(index)
        @battlers[index].vanished = false
        @scene.pbRecall(index)
        @battlers[index].leaveField
      end
      pbMessagesOnReplace(index, partyindex)
      pbReplace(index, partyindex)
      @scene.partyBetweenKO2(!pbOwnedByPlayer?(index)) unless @doublebattle
    end

    # Then activate entry effects effects for all pokemon in order of the speeds (with modifiers) of the new battlers (handled by pbApplyEntryEffects)
    battlers = sendoutorder.map { |index, partyindex, shift| @battlers[index] }
    pbApplyEntryEffects(battlers)
  end

  # Accepts an array like this: [[index, pokemon, slidein]]
  def pbSendOut(slots)
    opposing = nil
    slots.each_with_index do |(index, pokemon, slidein), i|
      raise "Unexpected index" if !opposing.nil? && opposing != index.odd?
      opposing = index.odd?
      slots[i][2] = slidein || (pokemon.slidein && !pbIsRevealedBattler?(index)) || pokemon.ballused == :NOBALL
    end

    opposing ? @scene.pbTrainerSendOut(slots) : @scene.pbSendOut(slots)

    slots.each do |index, pokemon, slidein|
      if pbIsOpposing?(index)
        pbAceMessage(index)
        pbPokemonEntryMessage(index, pokemon)
      end
      @scene.pbResetMoveIndex(index)
      @ai.addMonToMemory(pokemon, index)
      @battlers[index].pbOnSendOutIllusionChecks
      $Trainer.pokedex.setSeen(@battlers[index].visiblePokemon)
      pbRegisterRevealedPokemon(index)
      pbRegisterRevealedBoss(index)
    end
  end

  def pbReplace(index, newpoke, batonpass = false)
    @switchedOut[index] = true
    if @battlers[index].unburdened
      @battlers[index].unburdened = false
      @battlers[index].speed /= 2
    end
    oldpoke = @battlers[index].pokemonIndex
    party = pbPartySingleOwner(index)
    if !pbOwnedByPlayer?(index)
      partyNameOverwrite(party, newpoke) if $game_switches[:NameOverwrite]
      $Trainer.pokedex.setSeen(party[newpoke])
    end
    @battlers[index].pbInitialize(party[newpoke], newpoke, batonpass)
    # Reorder the party for this battle
    oi = pbGetOwnerIndex(index)
    partyorder = pbIsOpposing?(index) ? @partyorder2[oi] : @partyorder[oi]
    bpo = -1
    bpn = -1
    for i in 0...partyorder.length
      bpo = i if partyorder[i] == oldpoke
      bpn = i if partyorder[i] == newpoke
    end
    if bpo != -1
      partyorder[bpo], partyorder[bpn] = partyorder[bpn], partyorder[bpo]
    end
    pbSendOut([[index, party[newpoke], false]])
  end

  def partyNameOverwrite(party, newpoke)
  end

  def pbRecallAndReplace(index, newpoke, batonpass = false)
    if @battlers[index].unburdened
      @battlers[index].unburdened = false
      @battlers[index].speed /= 2
    end
    pbClearChoices(index)
    @battlers[index].vanished = false if @battlers[index].vanished
    @scene.pbRecall(index) unless @battlers[index].isFainted?
    @battlers[index].leaveField
    pbMessagesOnReplace(index, newpoke)
    pbReplace(index, newpoke, batonpass)
    @scene.partyBetweenKO2(!pbOwnedByPlayer?(index)) unless @doublebattle
    pbApplyEntryEffects(@battlers[index])
  end

  def pbMessagesOnReplace(index, newpoke)
    newname = pbSwitchInName(index, newpoke)
    if pbOwnedByPlayer?(index)
      opposing = @battlers[index].pbOppositeOpposing
      if opposing.hp <= 0 || opposing.hp == opposing.totalhp
        pbDisplayBrief(_INTL("Go! {1}!", newname))
      elsif opposing.hp >= (opposing.totalhp / 2.0)
        pbDisplayBrief(_INTL("Do it! {1}!", newname))
      elsif opposing.hp >= (opposing.totalhp / 4.0)
        pbDisplayBrief(_INTL("Go for it, {1}!", newname))
      else
        pbDisplayBrief(_INTL("Your foe's weak!\nGet 'em, {1}!", newname))
      end
    else
      owner = pbGetOwner(index)
      pbDisplayBrief(_INTL("{1} sent out {2}!", owner.fullname, newname))
    end
  end

  def pbSwitchInBetween(indices, lax, cancancel, agent) # Overridden by Online
    raise if indices.length < 1 || indices.length > 2
    raise if indices.length == 2 && pbGetOwner(indices.first) != pbGetOwner(indices[1])

    if aiControlled?(indices.first) || $testing
      return @ai.pbChooseNewEnemy(indices, agent)
    else
      return @scene.pbSwitchPlayer(indices, lax, cancancel)
    end
  end

  def pbSwitchInName(index, newpoke)
    party = pbPartySingleOwner(index)
    pkmn = party[newpoke]

    name = pbIsOpposing?(index) ? getMonName(pkmn.species, pkmn.form) : pkmn.name

    # Illusion
    if pkmn.ability == :ILLUSION
      illusionpoke, illusionindex = illusionChoice(index, newpoke)
      if illusionpoke != nil
        name = pbIsOpposing?(index) ? getMonName(illusionpoke.species, illusionpoke.form) : illusionpoke.name
      end
    end

    # Clear Disguise
    disguise = Rejuv ? pkmn.disguise : nil
    if disguise
      name = pbIsOpposing?(index) ? getMonName(disguise.species, disguise.form) : disguise.name
    end

    return name
  end

  def pbRegisterRevealedPokemon(index)
    sideindex = pbIsOpposing?(index) ? 1 : 0
    trainerindex = pbGetOwnerIndex(index)
    pokemonindex = @battlers[index].pokemonIndex
    array = [sideindex, trainerindex, pokemonindex]
    @revealedPokemon.push(array) unless @revealedPokemon.include?(array)
  end

  def pbIsRevealedBattler?(index, illusiontarget: false)
    sideindex = pbIsOpposing?(index) ? 1 : 0
    trainerindex = pbGetOwnerIndex(index)
    battler = illusiontarget ? @battlers[index].effects[:Illusion] : @battlers[index]
    pokemonindex = battler.pokemonIndex
    return pbIsRevealedPokemon?(sideindex, trainerindex, pokemonindex)
  end

  def pbIsRevealedPokemon?(sideindex, trainerindex, pokemonindex)
    return @revealedPokemon.include?([sideindex, trainerindex, pokemonindex])
  end

  def pbRegisterRevealedBoss(index)
    return if Desolation
    battler = @battlers[index].effects[:Illusion] || @battlers[index]
    return unless (Reborn && battler.pokemon.isPulse?) || (Rejuv && battler.pokemon.isRift?)
    array = [battler.species, battler.form]
    @revealedBosses.push(array) unless @revealedBosses.include?(array)
  end

  ################################################################################
  # Reviving Pokémon.
  ################################################################################
  def pbRevive(index, move, rejuvenation = false)
    revivepoke = nil
    pkmnindex = nil
    party = pbPartySingleOwner(index)
    if !aiControlled?(index) || rejuvenation
      oi = pbGetOwnerIndex(index)
      modparty = []
      for i in 0...6
        modparty.push(party[@partyorder[oi][i]])
      end
      pkmnlist = PokemonScreen_Scene.new
      pkmnscreen = PokemonScreen.new(pkmnlist, modparty)
      pkmnscreen.pbStartScene(_INTL("Use on which Pokémon?"))
      loop do
        pkmnscreen.pbSetHelpText(_INTL("Use on which Pokémon?"))
        activecmd = pkmnscreen.pbChoosePokemon
        if activecmd >= 0 && !party[@partyorder[oi][activecmd]].nil?
          commands = []
          cmdRevive = -1
          cmdSummary = -1
          pkmnindex = @partyorder[oi][activecmd]
          commands[cmdRevive = commands.length] = _INTL("Revive") if !party[pkmnindex].isEgg? && party[pkmnindex].hp <= 0 && !party[pkmnindex].unusable && @battlers[index].pokemonIndex != pkmnindex
          commands[cmdSummary = commands.length] = _INTL("Summary") if !party[pkmnindex].unusable
          commands[commands.length] = _INTL("Cancel")
          command = pkmnlist.pbShowCommands(_INTL("Do what with {1}?", party[pkmnindex].name), commands)
          if cmdRevive >= 0 && command == cmdRevive
            revivepoke = party[pkmnindex]
            pkmnlist.pbEndScene
            break
          elsif cmdSummary >= 0 && command == cmdSummary
            pkmnlist.pbSummary(activecmd)
          end
        end
      end
    else
      reviveoptions = @battle.ai.getReviveScoresParty(index)
      pkmnindex = reviveoptions.index(reviveoptions.max)
      revivepoke = party[pkmnindex]
    end
    revivepoke.status = nil
    mult = @battle.FE == :HOLY ? 0.75 : 0.5
    mult = 1.0 if move == :REJUVENATION
    revivepoke.hp = [(revivepoke.totalhp * mult).floor, 1].max

    return pkmnindex
  end

  ################################################################################
  # Using an item.
  ################################################################################
  # Uses an item on a Pokémon in the player's party.
  def pbUseItemOnPokemon(item, pkmnIndex, userPkmn, scene)
    oi = pbGetOwnerIndex(userPkmn.index)
    pokemon = @party1[oi][pkmnIndex]
    name = pbGetOwner(userPkmn.index).fullname
    name = pbGetOwner(userPkmn.index).name if pbBelongsToPlayer?(userPkmn.index)
    pbDisplayBrief(_INTL("{1} used {2}.", name, getItemName(item, :the, useunit: false)))
    ret = false
    if pokemon.isEgg? || pokemon.stolen
      pbDisplay(_INTL("But it had no effect!"))
    else
      battler = @battlers.find { |battler| battler.pokemon == pokemon }
      ret = ItemHandlers.triggerBattleUseOnPokemon(item, pokemon, battler, scene)
      if @recorded
        $game_variables[:BattleDataArray].last().playerUsedAnItem
      end
    end
    if !ret && pbBelongsToPlayer?(userPkmn.index)
      if $PokemonBag.pbCanStore?(item)
        $PokemonBag.pbStoreItem(item)
      else
        raise _INTL("Couldn't return unused item to Bag somehow.")
      end
    end
    return ret
  end

  # Uses an item on an active Pokémon.
  def pbUseItemOnBattler(item, index, userPkmn, scene)
    ret = ItemHandlers.triggerBattleUseOnBattler(item, @battlers[index], scene)
    if !ret && pbBelongsToPlayer?(userPkmn.index)
      if $PokemonBag.pbCanStore?(item)
        $PokemonBag.pbStoreItem(item)
      else
        raise _INTL("Couldn't return unused item to Bag somehow.")
      end
      if @recorded
        $game_variables[:BattleDataArray].last().playerUsedAnItem
      end
    end
    return ret
  end

  def pbRegisterItem(idxPokemon, item, idxTarget)
    if ItemHandlers.hasUseInBattle(item) # Poke Balls, Poke Doll, Flutes
      return false unless ItemHandlers.checkUseInBattle(item, @battlers[idxPokemon], @scene)
      if [2, 3].include?(idxPokemon) && !@battlers[idxPokemon ^ 2].isFainted?
        return false unless pbDisplayConfirm(_INTL("Using this item will cancel the action picked by {1} this turn. Continue?", @battlers[idxPokemon ^ 2].name))
      end

      ret = ItemHandlers.triggerUseInBattle(item, @battlers[idxPokemon], self)
      return false unless ret > 0

      $PokemonBag.pbDeleteItem(item) if ret == 1
      @choices[idxPokemon ^ 2] = [:skip] unless @battlers[idxPokemon ^ 2].isFainted? # Cancel partner's turn
    end
    @choices[idxPokemon] = [:item, item, idxTarget]
    pbDisableAButtonChoices(idxPokemon)
    return true
  end

  def pbEnemyUseItem(item, battler)
    return 0 if !@internalbattle
    return 0 if pbIsPokeBall?(item) # the AI has no balls

    medicinedata = $cache.items[item].medicine
    return if !medicinedata

    items = pbGetOwnerItems(battler.index)
    return if !items

    items.delete_at(items.index(item)) if items.include?(item)

    opponent = pbGetOwner(battler.index)
    pbDisplayBrief(_INTL("{1} used {2}!", opponent.fullname, getItemName(item, :the, useunit: false))) if opponent&.fullname
    pbCommonAnimation("UseItemBag", battler, nil)

    $game_variables[:BattleDataArray].last().opponentUsedAnItem if @recorded

    battler.pbCureStatus if medicinedata.status && [battler.status, :FULLHEAL].include?(medicinedata.status)
    battler.pbCureConfusion if medicinedata.status && medicinedata.status == :FULLHEAL
    if medicinedata.hp
      healing = getItemHP(medicinedata.hp, battler.totalhp)
      battler.pbRecoverHP(healing, true, true, message: _INTL("{1}'s HP was restored.", battler.pbThis), fullrecover: medicinedata.hp == 1.0)
    end
    if medicinedata.xitem
      stat, amount = medicinedata.xitem[:stat], medicinedata.xitem[:amount]
      battler.pbChangeStats(stat, amount, battler, nil)
    end
  end

  ################################################################################
  # Fleeing from battle.
  ################################################################################
  def pbCanRun?(idxPokemon)
    return false if @opponent

    if @battlers.any? { |battler| battler.isbossmon }
      return true if @battlers.any? { |battler| battler.canrun }
    end
    return false if @battlers.any? { |battler| battler.isbossmon && !@cantescape }

    thispkmn = @battlers[idxPokemon]
    return true if thispkmn.hasWorkingItem(:SMOKEBALL)
    return true if thispkmn.hasWorkingItem(:MAGNETICLURE)
    return true if thispkmn.hasWorkingItem(:MIRRORLURE)
    return true if thispkmn.ability == :RUNAWAY

    return pbCanSwitch?(idxPokemon, -1)
  end

  def pbRun(idxPokemon, duringBattle = false)
    thispkmn = @battlers[idxPokemon]
    if pbIsOpposing?(idxPokemon)
      return 0 if @opponent

      @choices[i] = [:run]
      return -1
    end

    if @battlers.any? { |battler| battler.isbossmon }
      if ($DEBUG && Input.press?(Input::CTRL)) || $game_switches[:No_Battles_Pass]
        if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
          @decision = 1
          return 1
        elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
          @decision = 2
          return 1
        end
      end
      if @battlers.any? { |battler| battler.canrun }
        pbSEPlay("escape", 100)
        pbDisplayAutoPaused(_INTL("Got away safely!"))
        @decision = 3
        return 1
      else
        if pbDisplayConfirm(_INTL("Would you like to forfeit the match and quit now?"))
          pbDisplay(_INTL("{1} forfeited the match!", self.pbPlayer.name))
          @decision = 2
          return 1
        else
          return 0
        end
      end
    end


    if @opponent
      if ($DEBUG && Input.press?(Input::CTRL)) || $game_switches[:No_Battles_Pass]
        if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
          @decision = 1
          return 1
        elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
          @decision = 2
          return 1
        end
      elsif @internalbattle
        if pbDisplayConfirm(_INTL("Would you like to forfeit the battle?"))
          pbDisplay(_INTL("{1} forfeited the match!", self.pbPlayer.name))
          @decision = 2
          return 1
        end
      elsif pbDisplayConfirm(_INTL("Would you like to forfeit the match and quit now?"))
        pbDisplay(_INTL("{1} forfeited the match!", self.pbPlayer.name))
        @decision = 3
        return 1
      end
      return 0
    end
    if $DEBUG && Input.press?(Input::CTRL)
      pbSEPlay("escape", 100)
      pbDisplayAutoPaused(_INTL("Got away safely!"))
      @decision = 3
      return 1
    end
    if @cantescape || $game_switches[:Never_Escape]
      pbDisplayCommandPaused(_INTL("Can't escape!"))
      return 0
    end
    if thispkmn.hasType?(:GHOST)
      pbSEPlay("escape", 100)
      pbDisplayAutoPaused(_INTL("Got away safely!"))
      @decision = 3
      return 1
    end
    if thispkmn.hasWorkingItem(:SMOKEBALL) || thispkmn.hasWorkingItem(:MAGNETICLURE) || thispkmn.hasWorkingItem(:MIRRORLURE)
      if duringBattle
        pbSEPlay("escape", 100)
        pbDisplayAutoPaused(_INTL("Got away safely!"))
      else
        pbSEPlay("escape", 100)
        pbDisplayAutoPaused(_INTL("{1} fled using its {2}!", thispkmn.pbThis, getItemName(thispkmn.item)))
      end
      @decision = 3
      return 1
    end
    if thispkmn.ability == :RUNAWAY
      if duringBattle
        pbSEPlay("escape", 100)
        pbDisplayAutoPaused(_INTL("Got away safely!"))
      else
        pbShowAbilityBox(thispkmn)
        pbSEPlay("escape", 100)
        pbDisplayAutoPaused(_INTL("Got away safely!"))
        pbHideAbilityBox(thispkmn)
      end
      @decision = 3
      return 1
    end
    return 0 if !duringBattle && !pbCanSwitch?(idxPokemon, -1, showMessage: true)

    # Note: not pbSpeed, because using unmodified Speed
    speedPlayer = @battlers[idxPokemon].speed
    opposing = @battlers[idxPokemon].pbOppositeOpposing
    if opposing.isFainted?
      opposing = opposing.pbPartner
    end
    if !opposing.isFainted?
      speedEnemy = opposing.speed
      if speedPlayer > speedEnemy
        rate = 256
      else
        speedEnemy = 1 if speedEnemy <= 0
        rate = speedPlayer * 128 / speedEnemy
        rate += @runCommand * 30
        rate &= 0xFF
      end
    else
      rate = 256
    end
    ret = 1
    if pbRandom(256) < rate
      pbSEPlay("escape", 100)
      pbDisplayAutoPaused(_INTL("Got away safely!"))
      @decision = 3
    else
      pbDisplayCommandPaused(_INTL("Can't escape!"))
      ret = -1
    end
    if !duringBattle
      @runCommand += 1
    end
    if @doublebattle && idxPokemon == 0 && !@battlers[2].isFainted?
      @choices[2] = [:run] # Prevent partner from choosing an action this turn
    end
    return ret
  end

  ################################################################################
  # Mega Evolve battler.
  ################################################################################
  def pbCanMegaEvolve?(index, aiBattler: nil)
    return false if !isOnline? && $game_switches[:No_Mega_Evolution]
    return false if !pbHasMegaRing(index)

    battler = aiBattler || @battlers[index]
    return false if !battler.hasMega?
    return false if battler.pbOwnSide.effects[:PsyBlades] == true
    return false if battler.permeffs[:EvolutionReverted]
    return false unless pbGetOwner(index) || battler.isbossmon || battler.issosmon # only trainers and boss pokemon can Mega Evolve

    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    return false if @terastal[side][owner] != -1
    return false if @megaEvolution[side][owner] != -1 && @megaEvolution[side][owner] != index

    return true
  end

  def pbRegisterMegaEvolution(index)
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @megaEvolution[side][owner] = index
  end

  def pbUnRegisterMegaEvolution(index)
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @megaEvolution[side][owner] = -1
  end

  def pbMegaEvolve(index)
    # Things that disallow mega-evolution
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasMega? rescue false)
    return if (@battlers[index].isMega? rescue true)
    return unless pbGetOwner(index) || @battlers[index].isbossmon || @battlers[index].issosmon # only trainers and boss pokemon can Mega Evolve

    # Battle message start
    if @battlers[index].issosmon
      ownername = @battlers[index].pbPartner.isbossmon ? @battlers[index].pbPartner.name : @battlers[index].name
    elsif @battlers[index].isbossmon
      ownername = @battlers[index].name
    elsif pbBelongsToPlayer?(index)
      ownername = pbGetOwner(index).name
    else
      ownername = pbGetOwner(index).fullname
    end
    if @battlers[index].species == :RAYQUAZA
      pbDisplay(_INTL("{1}'s fervent wish has reached {2}!", ownername, @battlers[index].pbThis))
    else
      pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!", @battlers[index].pbThis, getItemName(@battlers[index].item), ownername, pbGetMegaRingName(index)))
    end

    # Animation
    if @battlers[index].species == :RAYQUAZA
      pbCommonAnimation("MegaEvolutionRayquaza", @battlers[index], nil)
    else
      pbCommonAnimation("MegaEvolution", @battlers[index], nil)
    end

    # Update battler
    @battlers[index].effects[:SpeedSwap] = 0 if Gen < Champs
    @battlers[index].pokemon.makeMega
    @battlers[index].changeForm(@battlers[index].pokemon.form)
    @battlers[index].pbUpdate(true)

    owner = pbGetOwner(index)
    # Since we want TrainerEffects type/ability changes to persist after mega evolution, set the following
    if owner&.trainereffect
      if owner&.trainereffect[@battlers[index].pokemonIndex]
        if owner&.trainereffect[@battlers[index].pokemonIndex][:typeChange]
          @battlers[index].type1 = owner&.trainereffect[@battlers[index].pokemonIndex][:typeChange][0]
          @battlers[index].type2 = owner&.trainereffect[@battlers[index].pokemonIndex][:typeChange][1] if owner&.trainereffect[@battlers[index].pokemonIndex][:typeChange][1]
        end
        if owner&.trainereffect[@battlers[index].pokemonIndex][:addType]
          @battlers[index].effects[:TemporaryType] = owner&.trainereffect[@battlers[index].pokemonIndex][:addType]
        end
        if owner&.trainereffect[@battlers[index].pokemonIndex][:abilitychange]
          @battlers[index].ability = owner&.trainereffect[@battlers[index].pokemonIndex][:abilitychange]
          @battlers[index].pokemon.ability = owner&.trainereffect[@battlers[index].pokemonIndex][:abilitychange]
        end
      end
    end
    @scene.pbChangePokemon(@battlers[index], @battlers[index].pokemon)

    # Battle message finish
    formname = $cache.pkmn[@battlers[index].pokemon.species].forms[@battlers[index].form]
    if formname.include?("Form")
      formname = formname.split("Form")[0].strip
    end
    meganame = formname + " " + getMonName(@battlers[index].pokemon.species, @battlers[index].pokemon.form)
    if @battlers[index].item == :DEMONSTONE
      pbDisplay(_INTL("{1} mutated into {2}!", @battlers[index].pbThis, meganame))
    else
      pbDisplay(_INTL("{1} has Mega Evolved into {2}!", @battlers[index].pbThis, meganame))
    end

    # Remember trainer has mega-evolved
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @megaEvolution[side][owner] = useMegaLimit ? -2 : -1
    @terastal[side][owner] = useMegaLimit ? -2 : -1 # terastallization and mega evolution are linked, only one of them can be done per battle

    # Re-update ability of mega-evolved mon
    @battlers[index].pbAbilitiesOnSwitchIn
  end

  def useMegaLimit
    return true
  end

  ################################################################################
  # Ultra Burst battler.
  ################################################################################
  def pbCanUltraBurst?(index, aiBattler: nil)
    return false if !isOnline? && $game_switches[:No_Mega_Evolution]
    return false if !pbHasZRing(index)

    battler = aiBattler || @battlers[index]
    return false if !battler.hasUltra?
    return false if battler.pbOwnSide.effects[:PsyBlades] == true
    return false unless pbGetOwner(index) || battler.isbossmon || battler.issosmon # only trainers and boss pokemon can Ultra Burst

    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    return false if @ultraBurst[side][owner] != -1 && @ultraBurst[side][owner] != index

    return true
  end

  def pbRegisterUltraBurst(index)
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @ultraBurst[side][owner] = index
  end

  def pbUnRegisterUltraBurst(index)
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @ultraBurst[side][owner] = -1
  end

  def pbUltraBurst(index)
    # Things that disallow ultra bursting
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasUltra? rescue false)
    return if (@battlers[index].isUltra? rescue true)
    return unless pbGetOwner(index) || @battlers[index].isbossmon || @battlers[index].issosmon # only trainers and boss pokemon can Ultra Burst

    # Battle message start
    pbDisplay(_INTL("Bright light is about to burst out of {1}!", @battlers[index].pbThis(true)))

    # Animation
    pbCommonAnimation("UltraBurst", @battlers[index], nil)

    # Update battler
    @battlers[index].effects[:SpeedSwap] = 0 if Gen < Champs
    @battlers[index].pokemon.makeUltra
    @battlers[index].changeForm(@battlers[index].pokemon.form)
    @battlers[index].pbUpdate(true)
    @scene.pbChangePokemon(@battlers[index], @battlers[index].pokemon)

    # Battle message finish
    pbDisplay(_INTL("{1} regained its true power through Ultra Burst!", @battlers[index].pbThis))

    # Remember trainer has ultra bursted
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @ultraBurst[side][owner] = -2

    # Re-update ability of ultra bursted mon
    @battlers[index].pbAbilitiesOnSwitchIn
  end

  ################################################################################
  # Terastallize battler.
  ################################################################################
  def pbCanTerastallize?(index, aiBattler: nil)
    return false if !isOnline? && $game_switches[:No_Mega_Evolution]
    return false if !pbHasTeraOrb(index)

    battler = aiBattler || @battlers[index]
    return false if !battler.hasTera?
    return false unless pbGetOwner(index) || battler.isbossmon || battler.issosmon # only trainers and boss pokemon can Terrastalize

    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    return false if @megaEvolution[side][owner] != -1
    return false if @terastal[side][owner] != -1 && @terastal[side][owner] != index

    return true
  end

  def pbRegisterTerastallization(index)
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @terastal[side][owner] = index
  end

  def pbUnRegisterTerastallization(index)
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @terastal[side][owner] = -1
  end

  def pbTerastallize(index)
    # Things that disallow terastallization
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasTera? rescue false)
    return if (@battlers[index].isTerastallized? rescue true)
    return unless pbGetOwner(index) || @battlers[index].isbossmon || @battlers[index].issosmon

    # Battle message start
    ownername = pbBelongsToPlayer?(index) ? pbGetOwner(index)&.name : pbGetOwner(index)&.fullname
    if ownername
      pbDisplay(_INTL("{1} is resonating with the energy from {2}'s Tera Orb!", @battlers[index].pbThis, ownername))
    else
      pbDisplay(_INTL("{1} is shining with Terastal energy!", @battlers[index].pbThis))
    end

    pbCommonAnimation("MegaEvolution", @battlers[index], nil) # filler animation

    # Update battler
    @battlers[index].effects[:SpeedSwap] = 0 if Gen < Champs
    @battlers[index].pokemon.makeTerastallized
    @battlers[index].changeForm(@battlers[index].pokemon.form)
    @battlers[index].pbUpdate(true)
    @scene.pbChangePokemon(@battlers[index], @battlers[index].pokemon)

    teratype = @battlers[index].pokemon.species == :TERAPAGOS ? getTypeName(:STELLAR) : getTypeName(@battlers[index].type1)
    pbDisplay(_INTL("{1} Terastallized into the {2} type!", @battlers[index].pbThis, teratype))

    # Remember trainer has terastallized
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @terastal[side][owner] = useMegaLimit ? -2 : -1
    @megaEvolution[side][owner] = useMegaLimit ? -2 : -1 # terastallization and mega evolution are linked, only one of them can be done per battle

    # Re-update ability of terastallized mon
    @battlers[index].pbAbilitiesOnSwitchIn
    # Activate Teraform Zero
    if @battlers[index].ability == :TERAFORMZERO
      if @weather != 0 || canEndTempFieldOrOverlay?
        pbShowAbilityBox(@battlers[index])
        pbEndWeather(noPersistent: true)
        endTempFieldOrOverlay
        pbHideAbilityBox(@battlers[index])
      end
    end
  end

  ################################################################################
  # Use Z-Move.
  ################################################################################
  def pbCanZMove?(index)
    return true if @battlers[index].effects[:IgnoreZflag] == true
    return false if $game_switches[:No_Z_Move]
    return false if !@battlers[index].hasZMove?
    return false if !pbHasZRing(index)
    return false if @battlers[index].pbOwnSide.effects[:PsyBlades] == true


    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    return true if @zMove[side][owner] == -1
    return false if @zMove[side][owner] != index

    return true
  end

  # def pbCanSpecialMove?(index)
  #   return false if
  # end

  def pbRegisterZMove(index)
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @zMove[side][owner] = index
  end

  def pbUnRegisterZMove(index)
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @zMove[side][owner] = -1
  end

  def pbRegisterUsedZMove(index)
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    return if @zMove[side][owner] == -1
    return if pbBelongsToInterceptor?(index)
    @zMove[side][owner] = -2
  end

  def pbUseZMove(index, choice, crystal, specialZ = false)
    # Things that disallow z-move
    return if !@battlers[index] || !@battlers[index].pokemon

    if !specialZ
      return if !(@battlers[index].hasZMove? rescue false)
    end

    # Illusion wearing off when using a Z-Move
    if @battlers[index].effects[:Illusion]
      @battlers[index].breakIllusion
    end

    # Animation
    pbCommonAnimation("ZPower", @battlers[index], nil)

    # Battle message
    if choice[2].data.zmovedata&.intercept
      owner = pbGetOwner(index)
      if owner
        pbDisplay(_INTL("{1} is drawing from the Core's power!", owner.trainername))
      else
        pbDisplay(_INTL("{1} is drawing from the Core's power!", @battlers[index].pbThis))
      end
    else
      pbDisplay(_INTL("{1} surrounded itself with its Z-Power!", @battlers[index].pbThis))
    end
  end

  def pbDisableAButtonChoices(index)
    side = pbIsOpposing?(index) ? 1 : 0
    owner = pbGetOwnerIndex(index)
    @megaEvolution[side][owner] = -1 if @megaEvolution[side][owner] == index
    @ultraBurst[side][owner] = -1 if @ultraBurst[side][owner] == index
    @terastal[side][owner] = -1 if @terastal[side][owner] == index
    @zMove[side][owner] = -1 if @zMove[side][owner] == index
  end

  ################################################################################
  # Call battler.
  ################################################################################
  def pbCall(index)
    owner = pbGetOwner(index)
    pbDisplay(_INTL("{1} called {2}!", owner.trainername, @battlers[index].name))
    pbDisplay(_INTL("{1}!", @battlers[index].name))
    if @battlers[index].isShadow?
      if @battlers[index].inHyperMode?
        @battlers[index].pokemon.hypermode = false
        @battlers[index].pokemon.adjustHeart(-300)
        pbDisplay(_INTL("{1} came to its senses from the Trainer's call!", @battlers[index].pbThis))
      else
        pbDisplay(_INTL("But nothing happened!"))
      end
    elsif @battlers[index].status != :SLEEP && @battlers[index].pbCanIncreaseStatStage?(PBStats::ACCURACY, @battlers[index], nil)
      @battlers[index].pbChangeStats(PBStats::ACCURACY, 1, @battlers[index], nil, abilitycheck: :skip)
    else
      pbDisplay(_INTL("But nothing happened!"))
    end
  end

  ################################################################################
  # Gaining Experience.
  ################################################################################
  def pbGainEXP
    return if !@internalbattle || @disableExpGain

    @scene.gainEXPPhase = true
    # Find who died and get their base EXP & level
    for i in 0...4 # Not ordered by priority
      if !@doublebattle && pbIsDoubleBattler?(i)
        @battlers[i].participants = []
        next
      end
      next unless pbIsOpposing?(i) && @battlers[i].participants.length > 0 && (@battlers[i].isFainted? || @decision == 4)

      baseexp = @battlers[i].baseExp
      level = @battlers[i].level
      mon_order = [] # order that the mons should be given EXP in
      # find who fought
      partic = 0
      for j in @battlers[i].participants
        next if !@party1[0][j] || @party1[0][j].isEgg?
        next if @party1[0][j].hp <= 0 && !$game_switches[:Exp_All_Plus_On]

        partic += 1
        mon_order.push(j)
      end
      next if partic == 0 && $game_switches[:Exp_All_Plus_On]

      # push the rest of the party on that array
      for j in 0...@party1[0].length
        next if !@party1[0][j] || @party1[0][j].isEgg?
        next if @party1[0][j].hp <= 0 && !$game_switches[:Exp_All_Plus_On]

        mon_order.push(j) if !mon_order.include?(j)
      end

      # get the base participant EXP
      partic = 1 if partic == 0
      partic_exp = (level * baseexp / partic).floor
      partic_exp = (partic_exp * 3 / 2).floor if @opponent

      # distribute EXP to each mon in the party
      messageskip = false
      for j in mon_order
        thispoke = @party1[0][j]

        # pokemon information for messages
        hasEXPshare = thispoke.item == :EXPSHARE || @permanenteffects[thispoke][:ItemToKeep] == :EXPSHARE
        tradeBoost = (thispoke.trainerID != self.pbPlayer.id && thispoke.trainerID != 0) || (thispoke.language != 0 && thispoke.language != self.pbPlayer.language)
        # Pokemon get a 1.2x exp. boost if they've met their evolution condition in battle
        evoBoost = checkEvolution(thispoke, battle: true, doublebattle: @doublebattle)
        mon_fought = @battlers[i].participants.include?(j)

        # did this mon fight?
        if mon_fought
          exp = partic_exp
        elsif hasEXPshare || $game_switches[:Exp_All_On] || $game_switches[:Exp_All_Plus_On] # didn't participate- has EXP Share or EXP All is on
          exp = (partic_exp / 3).floor # reduced
          exp = (partic_exp / 2).floor if $game_switches[:Exp_All_Plus_On]
        else # does not get EXP
          next
        end

        # Gain effort value points, using RS effort values
        pbGainEvs(thispoke, i) if mon_fought || hasEXPshare

        # reborn-added EXP booster: 8% per level over 100
        exp *= (1 + ((thispoke.level - 100) * 0.08)) if thispoke.level > 100
        if USENEWEXPFORMULA   # Use new (Gen 5) Exp. formula
          leveladjust = ((2 * level + 10.0) / (level + thispoke.level + 10.0))**2.5
          exp = (exp * leveladjust / 5).floor + 1
        else                  # Use old (Gen 1-4) Exp. formula
          exp = (exp / 7).floor
        end

        # Trade EXP; different language EXP
        exp *= (thispoke.language != 0 && thispoke.language != self.pbPlayer.language) ? 1.7 : 1.5 if tradeBoost
        # Delayed evolution EXP
        exp *= 1.2 if evoBoost

        exp = (exp * 3 / 2).floor if thispoke.item == :LUCKYEGG || @permanenteffects[thispoke][:ItemToKeep] == :LUCKYEGG
        exp = (exp * $game_variables[:Exp_Percent] / 100).floor if $game_switches[:Percent_Exp_Gains]
        exp = [-1, exp.floor].min if exp < 0
        exp = [0, exp.floor].max if exp >= 0 # Includes NoExp in formula

        # We have the EXP that this mon can gain.
        growthrate = thispoke.growthrate
        if $game_switches[:Hard_Level_Cap] || !Reborn || $game_switches[:Exp_All_On] || $game_switches[:Exp_All_Plus_On] # Rejuv-style Level Cap
          badgenum = pbPlayer.numbadges
          if thispoke.level >= LEVELCAPS[badgenum] && !negExp? # Allows negative exp to keep going down
            exp = 0
          elsif thispoke.level < LEVELCAPS[badgenum]
            totalExpNeeded = PBExp.startExperience(LEVELCAPS[badgenum], growthrate)
            currExpNeeded = totalExpNeeded - thispoke.exp
            exp = [currExpNeeded, exp].min
          end
        end
        newexp = PBExp.addExperience(thispoke.exp, exp, growthrate)
        exp = (newexp - thispoke.exp).floor
        exp = 0 if noExp?
        next if exp == 0

        if mon_fought || (hasEXPshare && !$game_switches[:Exp_All_On] && !$game_switches[:Exp_All_Plus_On])
          # EXP All text is handled at the end
          if tradeBoost || evoBoost || thispoke.item == :LUCKYEGG
            # Combine into tertiary statements as alternate
            pbDisplay(_INTL("{1} lost a boosted {2} Exp. Points!", thispoke.name, -1 * exp)) if negExp?
            pbDisplay(_INTL("{1} gained a boosted {2} Exp. Points!", thispoke.name, exp)) if posExp? || noExp?
          else
            # Combine into tertiary statements as alternate
            pbDisplay(_INTL("{1} lost {2} Exp. Points!", thispoke.name, -1 * exp)) if negExp?
            pbDisplay(_INTL("{1} gained {2} Exp. Points!", thispoke.name, exp)) if posExp? || noExp?
          end
        elsif $game_switches[:Exp_All_On] || $game_switches[:Exp_All_Plus_On]
          # Combine into tertiary statements as alternate
          if !messageskip
            itemname = $game_switches[:Exp_All_Plus_On] ? getItemName(:EXPALLPLUS, :the) : getItemName(:EXPALL, :the)
            pbDisplay(_INTL("The rest of your team lost Exp. Points thanks to {1}!", itemname)) if negExp?
            pbDisplay(_INTL("The rest of your team gained Exp. Points thanks to {1}!", itemname)) if posExp? || noExp?
          end
          messageskip = true
        end

        # actually add the EXP
        if thispoke.respond_to?("isShadow?") && thispoke.isShadow?
          thispoke.exp += exp
          next
        end
        newlevel = PBExp.levelFromExperience(newexp, growthrate)
        oldlevel = thispoke.level
        battler = @battlers.find { |battler| battler.pokemon == thispoke && !battler.isFainted? && !battler.issosmon } # Find battler
        curlevel = oldlevel
        oldstats = thispoke.getStats
        tempexp1 = thispoke.exp
        loop do
          startexp = PBExp.startExperience(curlevel, growthrate)
          endexp = PBExp.startExperience(curlevel + 1, growthrate)
          tempexp2 = (endexp < newexp) ? endexp : newexp if posExp? || noExp?
          tempexp2 = (startexp > newexp) ? startexp : newexp if negExp?
          thispoke.exp = tempexp2
          @scene.pbEXPBar(thispoke, battler, startexp, endexp, tempexp1, tempexp2) # EXP Bar animation
          tempexp1 = tempexp2
          curlevel += 1 if posExp? || noExp?
          curlevel -= 1 if negExp?
          if (curlevel > newlevel && (posExp? || noExp?)) || (curlevel < newlevel && negExp?)
            @scene.pbRefresh
            break
          end
          thispoke.level = curlevel
          thispoke.changeHappiness(:LevelUp)
        end
        next if newlevel == oldlevel

        # leveled up! or lvl down! :(
        thispoke.calcStats
        battler.pbUpdate(false) if battler
        @scene.pbRefresh
        message = negExp? ?
          _INTL("\\se[]{1} fell to Level {2}!\\se[itemlevel]", thispoke.name, newlevel) :
          _INTL("\\se[]{1} grew to Level {2}!\\se[itemlevel]", thispoke.name, newlevel)
        window = pbStatChangeDisplayWindow(thispoke, oldstats, highlight: false)
        pbDisplayAutoPaused(message)
        window&.dispose

        # Finding all moves learned at this level
        movelist = thispoke.getMoveList
        for lvl in oldlevel + 1..newlevel
          for k in movelist
            if k[0] == lvl # Learned a new move
              pbTryLearnMoveBattle(j, k[1])
            end
          end
        end

        # make sure that evo DOESN'T HAPPEN ON LVL DOWN
        next if negExp?

        # evolve if able to
        newspecies = checkEvolution(thispoke, battle: true, doublebattle: @doublebattle)
        next if newspecies.nil?

        if newspecies[:species] == :MAUSHOLD && !battler # silent evo if tandemaus is not on field
          pbCarryOutEvolution(thispoke, newspecies, silent: true)
        else # normal evo
          pbMidBattleEvo(thispoke, newspecies, battler)
        end
      end

      # Now clear the participants array
      @battlers[i].participants = []
    end
    @scene.gainEXPPhase = false
  end

  def pbMidBattleEvo(pkmn, newspecies, battler)
    return if $DEBUG && Input.press?(Input::CTRL)

    pbFadeOutInWithMusic(99999) {
      evolved = pbCarryOutEvolution(pkmn, newspecies)
      $game_map.autoplayAsCue
      if evolved && battler
        @scene.pbChangePokemon(battler, pkmn)
        battler.species = pkmn.species
        battler.form = pkmn.form
        battler.pbUpdate(true)
        battler.name = pkmn.name
        @scene.sprites["battlebox#{battler.index}"].refresh
        for ii in 0...pkmn.moves.length
          battler.moves[ii] = PokeBattle_Move.pbFromPBMove(self, pkmn.moves[ii], pkmn)
        end
      end
    }
  end

  def pbGainEvs(thispoke, i) # Gain effort value points, using RS effort values
    return if $game_switches[:Stop_Ev_Gain]

    totalev = thispoke.ev.sum
    return if totalev >= 510 && !$game_switches[:No_Total_EV_Cap]

    evyield = @battlers[i].evYield # Original species, not current species
    for k in 0..5
      next if thispoke.ev[k] >= 252

      evgain = evyield[k]
      evgain *= 8 if thispoke.item == :MACHOBRACE || @permanenteffects[thispoke][:ItemToKeep] == :MACHOBRACE
      poweritem = [:POWERWEIGHT, :POWERBRACER, :POWERBELT, :POWERANKLET, :POWERLENS, :POWERBAND].include?(thispoke.item)
      evgain = 0 if poweritem
      case k
        when 0 then evgain += 32 if thispoke.item == :POWERWEIGHT
        when 1 then evgain += 32 if thispoke.item == :POWERBRACER
        when 2 then evgain += 32 if thispoke.item == :POWERBELT
        when 3 then evgain += 32 if thispoke.item == :POWERLENS
        when 4 then evgain += 32 if thispoke.item == :POWERBAND
        when 5 then evgain += 32 if thispoke.item == :POWERANKLET
      end
      case k
        when 0 then evgain += 8 if thispoke.item == :CANONPOWERWEIGHT
        when 1 then evgain += 8 if thispoke.item == :CANONPOWERBRACER
        when 2 then evgain += 8 if thispoke.item == :CANONPOWERBELT
        when 3 then evgain += 8 if thispoke.item == :CANONPOWERLENS
        when 4 then evgain += 8 if thispoke.item == :CANONPOWERBAND
        when 5 then evgain += 8 if thispoke.item == :CANONPOWERANKLET
      end
      evgain *= 4 if thispoke.pokerusStage >= 1 # Infected or cured
      next unless evgain > 0

      # Can't exceed overall limit
      evgain -= totalev + evgain - 510 if totalev + evgain > 510 && !$game_switches[:No_Total_EV_Cap]
      # Can't exceed stat limit
      evgain -= thispoke.ev[k] + evgain - 252 if thispoke.ev[k] + evgain > 252
      # Add EV gain
      thispoke.ev[k] += evgain
      totalev += evgain

      if poweritem && totalev >= getPlayerMaxEVs()
        pbDisplayPaused(_INTL("{1} has finished its training!", thispoke.name), color: ColorTags[:Blue])
      elsif poweritem && thispoke.ev[k] == 252
        pbDisplayPaused(_INTL("{1}'s {2} is fully trained!", thispoke.name, getStatName(k)), color: ColorTags[:Blue])
      end

      return if totalev >= 510 && !$game_switches[:No_Total_EV_Cap]
    end
  end

  ################################################################################
  # Learning a move.
  ################################################################################
  def pbTryLearnMoveBattle(pkmnIndex, move)
    return if $DEBUG && Input.press?(Input::CTRL)

    pokemon = @party1[0][pkmnIndex]
    return if !pokemon
    return if pokemon.knowsMove?(move)

    pkmnname = pokemon.name
    movename = getMoveName(move)
    for i in 0...4
      if !pokemon.moves[i]
        pbLearnMovePokemon(pokemon, move, i)
        pbDisplayPaused(_INTL("{1} learned\n{2}!\\se[itemlevel]", pkmnname, movename))
        return
      end
    end
    pbDisplayPaused(_INTL("{1} wants to learn the\nmove {2}.", pkmnname, movename))
    if pbDisplayConfirm(_INTL("Should another move be forgotten and replaced with {1}?", movename))
      forgetmove = @scene.pbForgetMove(pokemon, move)
      if forgetmove >= 0
        oldmovename = getMoveName(pokemon.moves[forgetmove].move)
        pbLearnMovePokemon(pokemon, move, forgetmove)
        pbDisplayPaused(_INTL("\\se[]One...\\wt[8]two...\\wt[8]and...\\wt[12]ta-da!\\se[balldrop]"))
        pbDisplayPaused(_INTL("{1} forgot {2}...\nand it learned {3} instead!\\se[itemlevel]", pkmnname, oldmovename, movename))
      end
    end
  end

  def pbLearnMovePokemon(pokemon, move, moveIndex, fullPP: false)
    battler = @battlers.find { |battler| battler.pokemon == pokemon }
    pokemon.moves[moveIndex] = PBMove.new(move) # Replaces current/total PP
    if fullPP
      pokemon.moves[moveIndex].ppup = 3
      pokemon.moves[moveIndex].pp = pokemon.moves[moveIndex].totalpp
    end
    battler.moves[moveIndex] = PokeBattle_Move.pbFromPBMove(self, pokemon.moves[moveIndex], battler.pokemon) if battler
    if !pokemon.zmoves.nil? && pokemon.item != :INTERCEPTZ
      pokemon.updateZMoveIndex(moveIndex)
      updateZMoveIndexBattler(moveIndex, battler) if battler
    end
  end

  def pbLearnMoveBattler(battler, move, moveIndex)
    battler.moves[moveIndex] = PokeBattle_Move.pbFromPBMove(self, PBMove.new(move), battler.pokemon)
    if !battler.zmoves.nil? && battler.item != :INTERCEPTZ
      updateZMoveIndexBattler(moveIndex, battler)
    end
  end

  def updateZMoveIndexBattler(index, battler, ignore = false)
    zmovesym = $cache.items[battler.item]&.zmove
    return unless zmovesym
    zmovedata = $cache.moves[zmovesym].zmovedata
    if zmovedata.type
      if battler.moves[index].type != zmovedata.type
        battler.zmoves[index] = nil
      else
        zmove = battler.moves[index].category == :status ? PBMove.new(battler.moves[index].move) : PBMove.new(zmovesym)
        battler.zmoves[index] = PokeBattle_Move.pbFromPBMove(self, zmove, battler.pokemon, battler.moves[index])
      end
    elsif ignore
      zmove = battler.moves[index].category == :status ? PBMove.new(battler.moves[index].move) : PBMove.new($cache.items[PBStuff::TYPETOZCRYSTAL[battler.moves[index].type]].zmove)
      battler.zmoves[index] = PokeBattle_Move.pbFromPBMove(self, zmove, battler.pokemon, battler.moves[index])
    elsif zmovedata.basemove
      if zmovedata.basemove != battler.moves[index].move || !zmovedata.isCompatible?(battler.species, battler.form)
        battler.zmoves[index] = nil
      else
        zmove = PBMove.new(zmovesym)
        battler.zmoves[index] = PokeBattle_Move.pbFromPBMove(self, zmove, battler.pokemon, battler.moves[index])
      end
    end
  end

  ################################################################################
  # Abilities.
  ################################################################################
  def pbOnBattleStart
    for i in 0...4 # Currently unfainted participants will earn EXP even if they faint afterwards
      @battlers[i].pbUpdateParticipants if pbIsOpposing?(i)
      @amuletcoin = true if !pbIsOpposing?(i) && [:AMULETCOIN, :LUCKINCENSE].include?(@battlers[i].item)
    end

    # Pre-Surge checks
    unless Overlays
      priority = setSpeedOrder
      for i in priority
        i.pbItemsOnField(true)
        i.pbAbilitiesOnField(true)
      end
      @preSurgeField = @field.effect
    end

    # Activate entry effects for all battlers
    pbApplyEntryEffects(@battlers)

    @preSurgeField = nil
    pbJudge
  end

  def pbApplyEntryEffects(battlers)
    battlers = Array(battlers)
    battlers = setSpeedOrder.filter { |i| battlers.include?(i) } unless battlers.length == 1
    battlers.each { |i| bossEntryText(i)}
    battlers.each { |i| i.applyingEntryEffects = true }
    battlers.each { |i| pbOnActiveOne(i) }
    battlers.each { |i| i.applyingEntryEffects = false }

    # Field entry effects (abilities, items) should be activated only after all other entry effects have been resolved, for the battlers switching in
    # This is because other entry effects may set fields, which leads to field entry effects activating twice for one switch-in (one from setField and one from pbAbilitiesOnSwitchIn)
    battlers = setSpeedOrder.filter { |i| battlers.include?(i) } unless battlers.length == 1
    battlers.each { |i|
      i.pbItemsOnField(true)
      i.pbAbilitiesOnOverlay(true)
      i.pbAbilitiesOnField(true)
    }

    pbStatChangeChecks
  end

  def pbOnActiveOne(pkmn)
    return false if pkmn.isFainted?

    # Neutralizing Gas
    if pbCheckGlobalAbility(:NEUTRALIZINGGAS) && !(PBStuff::FIXEDABILITIES + [:NEUTRALIZINGGAS]).include?(pkmn.ability) && !pkmn.hasWorkingItem(:ABILITYSHIELD)
      pkmn.changeAbilityWithEffects(:suppress)
    end
    if pkmn.permeffs[:LifeBlood]
      if pkmn.permeffs[:LifeBlood][:abilitySuppression]
        pkmn.changeAbilityWithEffects(:suppress)
      end
      if pkmn.permeffs[:LifeBlood][:typeSuppression]
        pkmn.changeType(:QMARKS)
      end
    end
    for i in 0...4 # Currently unfainted participants will earn EXP even if they faint afterwards
      @battlers[i].pbUpdateParticipants if pbIsOpposing?(i)
      @amuletcoin = true if !pbIsOpposing?(i) && [:AMULETCOIN, :LUCKINCENSE].include?(@battlers[i].item)
    end
    # Chess Field piece boosts
    if @field.effect == :CHESS
      case pkmn.piece
        when :PAWN
          pbDisplay(_INTL("{1} became a Pawn and stormed up the board!", pkmn.pbThis))
        when :KING
          pbDisplay(_INTL("{1} became a King and exposed itself!", pkmn.pbThis))
        when :KNIGHT
          pbDisplay(_INTL("{1} became a Knight and readied its position!", pkmn.pbThis)) # oo they shmovin' but i gotta change this im sry
        when :BISHOP
          pbDisplay(_INTL("{1} became a Bishop and took the diagonal!", pkmn.pbThis))
          pkmn.pbChangeStats(PBStats::Offensive, 1, pkmn, nil)
        when :ROOK
          pbDisplay(_INTL("{1} became a Rook and took the open file!", pkmn.pbThis))
          pkmn.pbChangeStats(PBStats::Defensive, 1, pkmn, nil)
        when :QUEEN
          pbDisplay(_INTL("{1} became a Queen and was placed on the center of the board!", pkmn.pbThis))
          pkmn.pbChangeStats(PBStats::Defensive, 1, pkmn, nil)
      end
    elsif @field.effect == :CROWD
      pkmn.tempBoosts = [0, 0, 0, 0, 0, 0]
      scoreToCompare = $game_variables[:BattleDataArray].last().getScoreAndSide(pkmn)
      highestOpposingScore = [0, nil, ""]
      for b in 0...@battlers.length
        battlerArray = $game_variables[:BattleDataArray].last().getScoreAndSide(@battlers[b])
        if battlerArray[1] != scoreToCompare[1] && battlerArray[0].to_i > highestOpposingScore[0].to_i
          highestOpposingScore = battlerArray
        end
      end
      oppScore = highestOpposingScore[0].to_i
      buffs = [0, 0, 0, 0, 0, 0]
      message = nil
      if oppScore >= 3
        $overscored = highestOpposingScore[2]
        buffs[PBStats::ATTACK] += 1
        buffs[PBStats::SPATK] += 1
        buffs[PBStats::SPEED] += 1
        message = _INTL("The crowd begins rooting for an underdog to take {1} down a peg!", highestOpposingScore[2])
      end
      if oppScore >= 4
        $overscored = highestOpposingScore[2]
        buffs[PBStats::DEFENSE] += 1
        buffs[PBStats::SPDEF] += 1
        buffs[PBStats::SPEED] += 1
        message = _INTL("{1} has overstayed its welcome for the crowd!", highestOpposingScore[2])
      end
      if oppScore >= 5
        $overscored = highestOpposingScore[2]
        buffs[PBStats::ATTACK] += 1
        buffs[PBStats::DEFENSE] += 1
        buffs[PBStats::SPATK] += 1
        buffs[PBStats::SPDEF] += 1
        buffs[PBStats::SPEED] += 1
        message = _INTL("\"DON'T GIVE UP NOW, {1}!!\"", scoreToCompare[2].upcase)
      end
      if message
        pbDisplay(message)
        stats, amounts = [], []
        buffs.each_with_index { |boost, stat|
          next if boost == 0
          stats.push(stat)
          amounts.push(boost)
        }
        pkmn.pbChangeStats(stats, amounts, pkmn, nil, abilitycheck: :hide, statmessage: :none, ignoreContrary: true, counter: :Crowd)
        # pbChangeStats adds boosts to tempBoosts if they actually happen
      end
    end
    # Shadow Pokemon
    if pkmn.isShadow? && pbIsOpposing?(pkmn.index)
      pbCommonAnimation("Shadow", pkmn, nil)
      pbDisplay(_INTL("Oh!\nA Shadow Pokémon!"))
    end
    # Black Prism Rage
    if Rejuv
      if pkmn.item == :BLKPRISM && !@battle.pbOwnedByPlayer?(pkmn.index)
        stats = PBStats::Omni
        pkmn.pbChangeStats(stats, 2, pkmn, nil, abilitycheck: :hide, statmessage: :none, ignoreContrary: true)
        @battle.pbDisplay(_INTL("{1} is in a wild rage!", pkmn.pokemon.name))
      end
      if pkmn.item == :BLACKLANTERN
        pbAnimation(:TAILGLOW,  pkmn, nil)
        @battle.pbDisplay(_INTL("{1}'s Black Lantern is shining ominously...", pkmn.pbThis))
      end
    end
    # Healing Wish
    healingWish(pkmn)
    # Lunar Dance
    lunarDance(pkmn)
    # Z-Memento/Parting Shot
    zHeal(pkmn)
    if pkmn.effects[:MaliciousMoth] > 0
      pbCommonAnimation("MalMoths", pkmn, nil)
      pbDisplay(_INTL("{1} was infested by the Malicious Moths!", pkmn.pbThis))
    end
    # Spikes
    pkmn.pbOwnSide.effects[:Spikes] = 0 if [:WATERSURFACE, :MURKWATERSURFACE, :SKY, :CLOUDS].include?(@field.effect)
    if pkmn.pbOwnSide.effects[:Spikes] > 0 && @field.effect != :WASTELAND &&
       (!pkmn.isAirborne? || (Rejuv && @field.effect == :ELECTERRAIN)) &&
       !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS) && !magicGuardAbilities.include?(pkmn.ability)
      spikesdiv = [8.0, 8.0, 6.0, 4.0][pkmn.pbOwnSide.effects[:Spikes]]
      if Rejuv && @battle.FE == :ELECTERRAIN
        atype = :ELECTRIC
        eff = PBTypes.typesEff(atype, pkmn.types, inverse: inverse?)
        unless eff.immune?
          pkmn.pbReduceHP((pkmn.totalhp / spikesdiv * eff.multiplier).floor, true, message: _INTL("{1} was hurt by the electrified spikes!", pkmn.pbThis))
          pkmn.pbPassiveTypeEffCheck(atype)
        end
      else
        pkmn.pbReduceHP((pkmn.totalhp / spikesdiv).floor, true, message: _INTL("{1} was hurt by the spikes!", pkmn.pbThis))
      end
    end
    if pkmn.isFainted?
      pkmn.pbFaint
      pbHazardFaintCheck
      return
    end
    # Stealth Rock
    if pkmn.pbOwnSide.effects[:StealthRock] && @field.effect != :WASTELAND &&
       !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS) && !magicGuardAbilities.include?(pkmn.ability)
      atype = :ROCK
      if @field.effect == :CRYSTALCAVERN
        atype = @field.getRoll(update_roll: true)
        @field.fieldroll = nil # unlocks fieldroll so the next roll isn't a repeat
      end
      atype = :FIRE if @field.effect == :VOLCANICTOP || @field.effect == :INFERNAL || (Rejuv && @field.effect == :DRAGONSDEN)
      atype = :POISON if @field.effect == :CORRUPTED
      eff = PBTypes.typesEff(atype, pkmn.types, inverse: inverse?)
      unless eff.immune?
        mult = eff.multiplier
        mult *= 2 if @field.effect == :ROCKY || @field.effect == :CAVE
        message = case true
          when @field.effect == :CRYSTALCAVERN
            _INTL("Crystallized stones dug into {1}!", pkmn.pbThis(true))
          when @field.effect == :VOLCANICTOP || @field.effect == :INFERNAL || (Rejuv && @field.effect == :DRAGONSDEN)
            _INTL("Molten stones dug into {1}!", pkmn.pbThis(true))
          when @field.effect == :CORRUPTED
            _INTL("Corrupted stones dug into {1}!", pkmn.pbThis(true))
          else
            _INTL("Pointed stones dug into {1}!", pkmn.pbThis(true))
        end
        pkmn.pbReduceHP((pkmn.totalhp / 8.0 * mult).floor, true, message: message)
        pkmn.pbPassiveTypeEffCheck(atype)
      end
    end
    if pkmn.isFainted?
      pkmn.pbFaint
      pbHazardFaintCheck
      return
    end
    # Corrosive Field Entry
    if @field.effect == :CORROSIVE &&
       !pkmn.isAirborne? && !pkmn.hasType?(:POISON) && !pkmn.hasType?(:STEEL) &&
       !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS) && pkmn.crested != :ZANGOOSE &&
       ![:MAGICGUARD, :POISONHEAL, :IMMUNITY, :WONDERGUARD, :TOXICBOOST, :PASTELVEIL].include?(pkmn.ability) &&
       !(pkmn.isbossmon && pkmn.immunities[:fieldEffectDamage].include?(@field.effect))
      atype = :POISON
      eff = PBTypes.typesEff(atype, pkmn.types, inverse: inverse?)
      unless eff.immune?
        pkmn.pbReduceHP((pkmn.totalhp / 4.0 * eff.multiplier).floor, true, message: _INTL("{1} was seared by the corrosion!", pkmn.pbThis))
        pkmn.pbPassiveTypeEffCheck(atype)
      end
    end
    concertNoise(pkmn) if [:CONCERT3, :CONCERT4].include?(@field.effect)
    if pkmn.isFainted?
      pkmn.pbFaint
      pbHazardFaintCheck
      return
    end
    pbCrestEffects(pkmn.index, pkmn.pokemon) if Rejuv
    # Sticky Web
    pkmn.pbOwnSide.effects[:StickyWeb] = nil if [:SKY, :CLOUDS].include?(@field.effect)
    if pkmn.pbOwnSide.effects[:StickyWeb] && @field.effect != :WASTELAND &&
       !pkmn.isAirborne? && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
      amount = @field.effect == :FOREST ? -2 : -1
      setter = @battlers.find { |battler| battler.pokemon == pkmn.pbOwnSide.effects[:StickyWeb] }
      pbDisplay(_INTL("{1} was caught in a sticky web!", pkmn.pbThis))
      pkmn.pbChangeStats(PBStats::SPEED, amount, setter, nil)
    end
    # Toxic Spikes
    pkmn.pbOwnSide.effects[:ToxicSpikes] = 0 if [:WATERSURFACE, :MURKWATERSURFACE, :SKY, :CLOUDS].include?(@field.effect)
    if pkmn.pbOwnSide.effects[:ToxicSpikes] > 0 && @field.effect != :WASTELAND && !pkmn.isAirborne?
      if pkmn.hasType?(:POISON) && @field.effect != :CORROSIVE
        pkmn.pbOwnSide.effects[:ToxicSpikes] = 0
        pbDisplay(pkmn.pbOwnSide.endEffectMessage(:ToxicSpikes))
      elsif pkmn.pbCanPoison?(nil, nil) && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
        pkmn.pbPoison(pkmn, pkmn.pbOwnSide.effects[:ToxicSpikes] > 1)
      end
    end
    if pkmn.status == :PETRIFIED
      pkmn.effects[:Petrification] = pkmn.pbOppositeOpposing.index
    end
    # Emergency exit caused by taking hazard damage
    pkmn.carryOutUserSwitch if pkmn.userSwitch

    # ITEMS
    # Balloon
    if pkmn.hasWorkingItem(:AIRBALLOON)
      msg = _INTL("{1} floats in the air with its {2}!", pkmn.pbThis, getItemName(pkmn.item))
      @battle.pbAbilityBoxAndDisplay(pkmn, msg, item: true)
    end
    # Room Service
    pkmn.roomServiceCheck
    # Berries (ones already meeting their activation condition when pokemon is switched in)
    pkmn.pbBerryHerbCheck
    # pbItemsOnField would go here too but it needs to have a lower priority for us so it's handled separately in pbApplyEntryEffects

    # Imposter (should activate only when pokemon is sent out)
    if pkmn.ability == :IMPOSTER
      choice = pkmn.pbOppositeOpposing
      if choice.hp > 0 && pkmn.pbCanTransform?(choice, nil)
        pbShowAbilityBox(pkmn)
        pbAnimation(:TRANSFORM,  pkmn, choice)
        pkmn.pbTransform(choice)
        pbHideAbilityBox(pkmn)
      else
        @ai.discloseIllusion(choice, :noTransform) if choice.effects[:Illusion]
      end
    end

    # Tera Shift
    if pkmn.ability == :TERASHIFT && pkmn.pokemon.species == :TERAPAGOS && pkmn.form == 0
      pbShowAbilityBox(pkmn)
      pkmn.changeForm(1)
      pkmn.pokemon.ability = pkmn.pokemon.abilityIndex
      pbCommonAnimation("TypeRoll", pkmn, nil)
      pkmn.pbUpdate(true)
      @scene.pbChangePokemon(pkmn, pkmn.pokemon)
      pbDisplay(_INTL("{1} transformed!", pkmn.pbThis))
      pbHideAbilityBox(pkmn)
    end

    runtrainerskills(pkmn)
    pbShieldEffects(pkmn, pkmn.onEntryEffects, true) if pkmn.isbossmon && pkmn.onEntryEffects

    pkmn.pbAbilitiesOnSwitchIn
  end

  def pbHazardFaintCheck # Looks a little weird, might need to be revisited
    if @phase != :attackPhase
      pbGainEXP
      10.times do
        # loop in case the new mon immediately dies to hazards
        pbReplaceFaintedBattlers
      end
      return if @decision > 0

      priority = setSpeedOrder
      for i in priority
        i.pbRegularIntervalChecks
      end
    else
      pbJudge
    end
  end

  ################################################################################
  # Judging.
  ################################################################################
  def pbJudgeCheckpoint(attacker, move = 0)
  end

  def pbDecisionOnTime
    count1 = 0
    count2 = 0
    hptotal1 = 0
    hptotal2 = 0
    for i in allMons(@party1)
      next if !i

      if i.hp > 0 && !i.isEgg?
        count1 += 1
        hptotal1 += i.hp
      end
    end
    for i in allMons(@party2)
      next if !i

      if i.hp > 0 && !i.isEgg?
        count2 += 1
        hptotal2 += i.hp
      end
    end
    return 1 if count1 > count2     # win
    return 2 if count1 < count2     # loss
    return 1 if hptotal1 > hptotal2 # win
    return 2 if hptotal1 < hptotal2 # loss

    return 5 # draw
  end

  def pbDecisionOnTime2
    count1 = 0
    count2 = 0
    hptotal1 = 0
    hptotal2 = 0
    for i in allMons(@party1)
      next if !i

      if i.hp > 0 && !i.isEgg?
        count1 += 1
        hptotal1 += (i.hp * 100 / i.totalhp)
      end
    end
    hptotal1 /= count1 if count1 > 0
    for i in allMons(@party2)
      next if !i

      if i.hp > 0 && !i.isEgg?
        count2 += 1
        hptotal2 += (i.hp * 100 / i.totalhp)
      end
    end
    hptotal2 /= count2 if count2 > 0
    return 1 if count1 > count2     # win
    return 2 if count1 < count2     # loss
    return 1 if hptotal1 > hptotal2 # win
    return 2 if hptotal1 < hptotal2 # loss

    return 5 # draw
  end

  def pbDecisionOnDraw
    return 5 # draw
  end

  def pbJudge
    # PBDebug.dblog("[Counts: #{pbPokemonCount(@party1)}/#{pbPokemonCount(@party2)}]")
    if pbBothSidesAllFainted?
      @decision = pbDecisionOnDraw() # Draw
    elsif pbAllFaintedAllParties?(@party1)
      @decision = 2 # Loss
    elsif pbAllFaintedAllParties?(@party2)
      @decision = 1 # Win
    end
  end

  ################################################################################
  # Messages and animations.
  ################################################################################
  def pbApplySceneBG(sprite, filename)
    @scene.pbApplyBGSprite(sprite, filename)
  end

  def pbDisplay(msg, color: nil)
    @scene.pbDisplayMessage(msg, color: color)
  end

  def pbDisplayWaiting(msg)
    @scene.pbDisplayWaiting(msg)
  end

  def pbDisplayPaused(msg, color: nil)
    @scene.pbDisplayPausedMessage(msg, color: color)
  end

  def pbDisplayCommandPaused(msg)
    @scene.pbDisplayCommandPaused(msg)
  end

  def pbDisplayAutoPaused(msg)
    if @controlPlayer || $game_switches[:SpeedSkip_Password]
      @scene.pbDisplayMessage(msg)
    else
      @scene.pbDisplayPausedMessage(msg)
    end
  end

  def pbDisplayTrainerMessage(msg, oppindex, hidesprite: true)
    trainer = @battle.opponent.is_a?(Array) ? @battle.opponent[oppindex] : @battle.opponent
    trainertype = nil
    trainertype = :HEATHER2 if trainer.trainertype == :HEATHER
    trainertype = :ANNA3 if trainer.trainertype == :ANNA

    @scene.pbShowOpponent(oppindex, trainertype)
    @scene.speakingTrainer = trainer.name
    pbDisplayAutoPaused(msg.gsub(/\\[Pp][Nn]/, self.pbPlayer.name))
    @scene.speakingTrainer = nil
    @scene.pbHideOpponent if hidesprite
  end

  def pbDisplayBrief(msg)
    @scene.pbDisplayMessage(msg, true)
  end

  def pbDisplayConfirm(msg)
    @scene.pbDisplayConfirmMessage(msg)
  end

  def pbDisplayConfirmSerious(msg)
    @scene.pbDisplayConfirmMessageSerious(msg)
  end

  def pbShowCommands(msg, commands, cancancel = true)
    @scene.pbShowCommands(msg, commands, cancancel)
  end

  def pbAnimation(moveid, attacker, opponent, hitnum = 0)
    @scene.pbAnimation(moveid, attacker, opponent, hitnum)
  end

  def pbCommonAnimation(name, attacker = nil, opponent = nil, hitnum = 0)
    @scene.pbCommonAnimation(name, attacker, opponent, hitnum)
  end

  def pbChangeBGSprite
    filename = @field.backdrop
    path = "Graphics/Battlebacks/battlebg" + filename + ".png"
    pbApplySceneBG("battlebg", path)
    path = "Graphics/Battlebacks/playerbase" + filename + ".png"
    path = "Graphics/Battlebacks/playerbaseDummy" if !pbResolveBitmap(sprintf(path))
    pbApplySceneBG("playerbase", path)
    path = "Graphics/Battlebacks/enemybase" + filename + ".png"
    path = "Graphics/Battlebacks/enemybaseDummy" if !pbResolveBitmap(sprintf(path))
    pbApplySceneBG("enemybase", path)
  end

  def pbShowAbilityBox(battler, item: nil, attrname: nil, crest: nil)
    @scene.pbShowAbilityBox(battler, item: item, attrname: attrname, crest: crest)
  end

  def pbHideAbilityBox(battler)
    @scene.pbHideAbilityBox(battler)
  end

  def pbChangeAbilityBox(battler)
    @scene.pbChangeAbilityBox(battler)
  end

  def pbAbilityBoxAndDisplay(battler, message, item: nil, attrname: nil)
    @scene.pbAbilityBoxAndDisplay(battler, message, item: item, attrname: attrname)
  end

  def pbAbilityBoxAndWait(battler, item: nil, attrname: nil)
    @scene.pbAbilityBoxAndWait(battler, item: item, attrname: attrname)
  end

  def pbPlaySubstituteAnimation(battler)
    battler.effects[:UsingSubstituteRightNow] = true
    pbAnimation(:SUBSTITUTE, battler, nil)
    battler.effects[:UsingSubstituteRightNow] = false
    @scene.pbSubstituteSprite(battler)
  end

  ################################################################################
  # Trainereffects (Rejuv Xen Mage style on entry effects cause by trainer)
  ################################################################################
  def runtrainerskills(pkmn, delayKey = nil, faint = false, moveReaction = false, move: nil)
    monindex = pkmn.pokemonIndex
    trainer = pbGetOwner(pkmn.index)
    return if trainer.nil?
    return if trainer.trainereffect.nil?
    return if trainer.trainereffect[:effectmode].nil?

    if !delayKey && !faint && !moveReaction
      trainer.trainereffectused = [] if !trainer.trainereffectused
      if trainer.trainereffect[:effectmode] == :Party
        trainereffect = trainer.trainereffect[monindex]
        return if trainereffect.nil?
        if trainereffect[:buffactivation] == :Limited
          return if trainer.trainereffectused.include?(monindex)

          trainer.trainereffectused.push(monindex)
        end
      # on god if someone tries to use Fainted effect mode on a Multibattle heads will roll
      elsif trainer.trainereffect[:effectmode] == :Fainted
        trainereffect = trainer.trainereffect[pkmn.pbFaintedPokemonCount]
        return if trainereffect.nil?
        if trainereffect[:buffactivation] == :Limited
          return if trainer.trainereffectused.include?(pkmn.pbFaintedPokemonCount)

          trainer.trainereffectused.push(pkmn.pbFaintedPokemonCount)
        end
      end
    elsif faint
      trainereffect = pkmn.effects[:LastWord]
    elsif moveReaction
      trainer.moveReactionsused = [] if !trainer.moveReactionsused
      if moveReaction[:All]
        trainereffect = moveReaction[:All]
        if trainereffect[:buffactivation] == :OneTimeBattle
          return if trainer.moveReactionsused.include?(monindex)
          trainer.moveReactionsused = Array.new(@battle.pbPartySingleOwner(pkmn.index).length) {|i| i}
        elsif trainereffect[:buffactivation] == :Limited
          return if trainer.moveReactionsused.include?(monindex)
          trainer.moveReactionsused.push(monindex)
        end
      else
        trainereffect = moveReaction[monindex]
        if trainereffect[:buffactivation] == :Limited
          return if trainer.moveReactionsused.include?(monindex)
          trainer.moveReactionsused.push(monindex)
        end
      end
    elsif delayKey
      trainereffect = trainer.delayRegister[delayKey]
    end
    return if trainereffect.nil?
    spriteoverwrite = trainereffect[:sprite] ? trainereffect[:sprite] : nil
    unless spriteoverwrite == :None
      trainertype = spriteoverwrite ? spriteoverwrite[0] : nil
      outfit = spriteoverwrite ? spriteoverwrite[1] : nil
      if @opponent.is_a?(Array)
        if @opponent.include?(trainer)
          opponent = @opponent.index(trainer)
          @scene.pbShowOpponent(opponent, trainertype, outfit)
          showtrainer = true
        end
      else
        if @opponent == trainer
          @scene.pbShowOpponent(0, trainertype, outfit)
          showtrainer = true
        end
      end
    end

    if trainereffect[:pokemonsprite]
      monsprite = trainereffect[:pokemonsprite][0]
      form = trainereffect[:pokemonsprite][1] ? trainereffect[:pokemonsprite][1] : 0
      shiny = trainereffect[:pokemonsprite][2] ? true : false
      @scene.pbShowPokemon(monsprite, form, shiny, trainereffect[:pokemonsprite][3],  trainereffect[:pokemonsprite][4],  trainereffect[:pokemonsprite][5])
      showpokemon = true
    end

    if trainereffect[:applySwitchInAbility]
      saveAbility = pkmn.ability
      pkmn.changeAbility(trainereffect[:applySwitchInAbility])
      pkmn.pbAbilitiesOnSwitchIn(applySwitchInAbility: true)
      pkmn.changeAbility(saveAbility)
    end
    if trainereffect[:message]
      if trainer.trainereffect[:messagesList]
        if trainer.trainereffect[:messagesList][pkmn.pbFaintedPokemonCount] != ""
          message = trainer.trainereffect[:messagesList][pkmn.pbFaintedPokemonCount]
          pbDisplayAutoPaused(message)
        end
      else
        if trainereffect[:message] != ""
          messages = Array(trainereffect[:message])
          messages.each { |message| pbDisplayAutoPaused(message) }
        end
      end
    end
    if trainereffect[:ArchetypeMessage] && trainereffect[:ArchetypeMessage] != ""
      messages = Array(trainereffect[:ArchetypeMessage])
      pbShowAbilityBox(pkmn, attrname: (_INTL("{1}'s Archetype", trainer.name)))
      messages.each { |message| pbDisplayAutoPaused(message) }
      pbHideAbilityBox(pkmn)
    end
    if trainereffect[:animation]
      if trainereffect[:animation].is_a?(Array)
        move = trainereffect[:animation][0]
        target = @battlers[trainereffect[:animation][2]]
        user = @battlers[trainereffect[:animation][1]]
      else
        move = trainereffect[:animation]
        target = pkmn
        user = pkmn
      end
      pbAnimation(move, pkmn, target)
    end
    if trainereffect[:transformTo]
      poke = trainereffect[:transformTo]
      if pkmn.species != poke[:species]
        pkmn.pokemon.species = poke[:species]
        pkmn.pokemon.form = poke[:form]
        pkmn.species = poke[:species]
        pkmn.form = poke[:form]
        pkmn.pokemon.makeShiny if poke[:shiny]
        pkmn.pokemon.ability = poke[:ability]
        pkmn.pokemon.moves.clear
        pkmn.moves.clear
        poke[:moves].each_with_index { |move, k|
          next if move.nil?

          pbLearnMovePokemon(pkmn.pokemon, move, k, fullPP: pkmn.level >= 75)
        }
        pkmn.pbUpdate(true)
        pbAnimation(:TRANSFORM, pkmn, pkmn)
        @scene.pbChangePokemon(pkmn, pkmn.pokemon)
      end
    end
    if trainereffect[:CustomMethod]
      if trainereffect[:CustomMethod].is_a?(Array)
        for effect in trainereffect[:CustomMethod]
          eval(effect)
        end
      else
        eval(trainereffect[:CustomMethod])
      end
    end
    if trainereffect[:fieldChange] && trainereffect[:fieldChange][0] != @field.effect
      if trainereffect[:fieldChange][3]
        pbAnimation(trainereffect[:fieldChange][3], pkmn, nil)
      else
        pbAnimation(:MAGICROOM, pkmn, nil)
      end
      if [:ELECTERRAIN, :GRASSY, :MISTY, :PSYTERRAIN, :RAINBOW].include?(@battle.field.effect) && @turncount == 0
        oldfe = @battle.field.effect
        feduration = @battle.field.duration
      end

      fieldmessage = trainereffect[:fieldChange][1] && trainereffect[:fieldChange][1] != "" ? trainereffect[:fieldChange][1] : _INTL("The field was changed!")
      setField(trainereffect[:fieldChange][0], trainereffect[:fieldChange][2], fieldmessage)
      @battle.field.duration = trainereffect[:fieldChange][2]
      if oldfe
        @field.overlay = oldfe
        @field.overlayCounter = feduration
      end
      #p @battle.field.permanent_condition
    end
    if trainereffect[:overlayChange] && trainereffect[:overlayChange] != @field.overlay
      fieldmessage = (trainereffect[:overlayChange][1] && trainereffect[:overlayChange][1] != "") ? trainereffect[:overlayChange][1] : _INTL("The overlay was changed!")
      if trainereffect[:overlayChange][3]
        pbAnimation(trainereffect[:overlayChange][3], pkmn, nil)
      else
        pbAnimation(:MAGICROOM, pkmn, nil)
      end
      setField(trainereffect[:overlayChange][0], trainereffect[:overlayChange][2], fieldmessage)
    end
    if trainereffect[:typeChange]
      pkmn.type1 = trainereffect[:typeChange][0]
      pkmn.type2 = trainereffect[:typeChange][1] if trainereffect[:typeChange][1]
      typechangeMessage = trainereffect[:typeChangeMessage]
      pbDisplay(_INTL(typechangeMessage, pkmn.pbThis)) if typechangeMessage
    end
    if trainereffect[:itemchange]
      pkmn.seedCheck # god this is stupid but necessary now due to entry effects
      pkmn.item = trainereffect[:itemchange]
      pkmn.pokemon.setItem(trainereffect[:itemchange])
      if pbGetOwner(pkmn.index)
        @party2[pbGetOwnerIndex(pkmn.index)][pkmn.pokemonIndex].setItem(trainereffect[:itemchange])
      end
      if $cache.items[pkmn.item] && $cache.items[pkmn.item].zmove
        pkmn.pokemon.initZmoves(false)
        if !pkmn.pokemon.zmoves.nil?
          pkmn.zmoves = [nil, nil, nil, nil]
          for i in 0...pkmn.pokemon.zmoves.length
            zmove = pkmn.pokemon.zmoves[i]
            pkmn.zmoves[i] =
              PokeBattle_Move.pbFromPBMove(self, zmove, pkmn.pokemon, pkmn.moves[i]) if !zmove.nil?
          end
        end
      else
        pkmn.pokemon.zmoves = nil
        pkmn.zmoves = nil
      end
    end
    if trainereffect[:abilitychange]
      pkmn.ability = trainereffect[:abilitychange]
      pkmn.pokemon.ability = trainereffect[:abilitychange]
      pkmn.pbAbilitiesOnSwitchIn
      abilitychangemessage = trainereffect[:abilitychangeMessage]
      pbDisplay(_INTL(abilitychangemessage, pkmn.pbThis)) if abilitychangemessage
    end
    trainereffect[:pokemonEffect].each_pair { |effect, effectval|
      pbAnimation(effectval[1], pkmn, nil) if !effectval[1].nil?
      target = pkmn.lastAttacker if pkmn.lastAttacker != -1
      if target.is_a?(Integer) && target != -1
        target = @battlers[target]
      end
      if target == 0 && [:SUPERGRUDGE, :GRUDGE, :PETRIFYBOND].include?(effect)
        if !pkmn.pbOpposing1.isFainted?
          pkmn.pbOpposing1.effects[effect] = effectval[0]
          pbAnimation(effectval[1], pkmn.pbOpposing1, nil) if !effectval[1].nil?
          target = pkmn.pbOpposing1
        else
          if !pkmn.pbOpposing2.isFainted?
            pkmn.pbOpposing2.effects[effect] = effectval[0]
            pbAnimation(effectval[1], pkmn.pbOpposing2, nil) if !effectval[1].nil?
            target = pkmn.pbOpposing2
          end
        end
      end
      case effect
      when :Wish
        pkmn.effects[:Wish] = effectval[0]
        pkmn.effects[:WishMaker] = pkmn.pokemonIndex
        pkmn.effects[:WishAmount] = [(pkmn.totalhp / 2.0).floor, 1].max
        effectmessage = effectval[2]
        pbDisplay(_INTL(effectmessage, trainer.trainername, pkmn.pbThis))
      when :PETRIFYBOND
        if pkmn.effects[:LastWord][:hpGate] == 0
          if target && !target.isFainted? && target.status == :PETRIFIED
            if effectval[2] != ""
              effectmessage = effectval[2]
              pbDisplay(_INTL(effectmessage, trainer.trainername, pkmn.pbThis))
            end
            target.pbReduceHP(target.hp)
            target.pbFaint # no return
          end
        end
      when :SaltCure
        if target && !target.is_a?(Integer)
          target.effects[effect] = effectval[0]
          effectmessage = effectval[2] != "" ? effectval[2] : _INTL("An effect was put up by {1}!")
          pbDisplay(_INTL(effectmessage, trainer.trainername, pkmn.pbThis))
        end
      when :SUPERGRUDGE
        if target && !target.is_a?(Integer)
          if move == nil
            move = target.moves.find { |move| move.move == target.lastMoveUsed } if target.lastMoveUsed != -1
          end
          for i in target.moves
            if i.move == move.move
              target.pbSetPP(i, i.pp = 0)
            else
              target.pbSetPP(i, i.pp = 1) if i.pp > 0
            end
          end
          @battle.pbDisplay(_INTL("{1}'s lost almost all its PP due to the grudge!", target.pbThis))
        end
      when :GRUDGE
        if target && !target.is_a?(Integer)
          if pkmn.effects[:Taunt] == 0
            if move == nil
              move = target.moves.find { |move| move.move == target.lastMoveUsed } if target.lastMoveUsed != -1
            end
            if move != nil
              target.pbSetPP(move, move.pp = 0)
              @battle.pbDisplay(_INTL("{1}'s {2} lost all its PP due to the grudge!", target.pbThis, move.name))
            end
          end
        end
      else
        if effectval[2] != ""
          effectmessage = effectval[2]
          pbDisplay(_INTL(effectmessage, trainer.trainername, pkmn.pbThis))
        end
        pkmn.effects[effect] = effectval[0]
      end
    } if trainereffect[:pokemonEffect]
    trainereffect[:targetIndexEffect].each_pair { |effect, effectval|
      target = @battlers[effectval[0]]
      target.effects[effect] = effectval[1]
      if pkmn.index == target.index
        animationAttacker = pkmn.pbPartner && !pkmn.pbPartner.isFainted? ? pkmn.pbPartner : pkmn
      else
        animationAttacker = pkmn
      end
      if !@battle.battlers[target.index].isFainted?
        pbAnimation(effectval[2], animationAttacker, target) if !effectval[2].nil?
        effectmessage = effectval[3] != "" ? effectval[3] : _INTL("An effect was put up by {1}!")
        if target != pkmn
          pbDisplay(_INTL(effectmessage, trainer.name, target.pbThis(true))) unless effectmessage == :None
        end
      end
    } if trainereffect[:targetIndexEffect]
    flippedtopartner = false
    trainereffect[:firstUnfaintedOpposingEffect].each_pair { |effect, effectval|
      target = pkmn
      if !pkmn.pbOpposing1.isFainted?
        pkmn.pbOpposing1.effects[effect] = effectval[0]
        if effect == :FutureSightMove
          pkmn.pbOpposing1.effects[:FutureSightUserIndex] = pkmn.index
          pkmn.pbOpposing1.effects[:FutureSightPokemon] = pkmn.pokemon
        end
        if effect == :MaliciousMoth
          if pkmn.pbOpposing1.effects[:MaliciousMoth] != -1
            if !pkmn.pbOpposing2.isFainted? && pkmn.pbOpposing2.effects[:MaliciousMoth] == -1
              pkmn.pbOpposing2.effects[:MaliciousMoth] = effectval[0]
              flippedtopartner = true
              pbCommonAnimation(effectval[1], pkmn.pbOpposing2, nil)
            end
          end
        end
        if effect == :Yawn
          if caller_locations.any? { |string| string.to_s.include?("pbRecallAndReplace")}
            pkmn.pbOpposing1.effects[effect] += 1
          end
        end
        if effectval[1] && !flippedtopartner
          if effectval[1] == "MaliciousMoth" || effectval[1] == "MalMoths"
            pbCommonAnimation(effectval[1], pkmn.pbOpposing1, nil)
          else
            pbAnimation(effectval[1], pkmn.pbOpposing1, nil)
          end
        end
        target = flippedtopartner ?  pkmn.pbOpposing2 : pkmn.pbOpposing1
      else
        if !pkmn.pbOpposing2.isFainted?
          pkmn.pbOpposing2.effects[effect] = effectval[0]
          if effect == :FutureSightMove
            pkmn.pbOpposing2.effects[:FutureSightUserIndex] = pkmn.index
            pkmn.pbOpposing2.effects[:FutureSightPokemon] = pkmn.pokemon
          end
          if effect == :Yawn
            if caller_locations.any? { |string| string.to_s.include?("pbRecallAndReplace")}
              pkmn.pbOpposing2.effects[effect] += 1
            end
          end
          if effect == :MaliciousMoth
            if pkmn.pbOpposing2.effects[:MaliciousMoth] != -1
              if !pkmn.pbOpposing1.isFainted? && pkmn.pbOpposing1.effects[:MaliciousMoth] == -1
                pkmn.pbOpposing1.effects[:MaliciousMoth] = effectval[0]
                flippedtopartner = true
                pbCommonAnimation(effectval[1], pkmn.pbOpposing1, nil)
              end
            end
          end
          if effectval[1] && !flippedtopartner
            if effectval[1] == "MaliciousMoth" || effectval[1] == "MalMoths"
              pbCommonAnimation(effectval[1], pkmn.pbOpposing2, nil)
            else
              pbAnimation(effectval[1], pkmn.pbOpposing2, nil)
            end
          end
          target = flippedtopartner ? pkmn.pbOpposing1 : pkmn.pbOpposing2
        end
      end
      effectmessage = effectval[2] != "" ? effectval[2] : _INTL("An effect was put up by {1}!")
      if target != pkmn
        pbDisplay(_INTL(effectmessage, trainer.name, target.pbThis, target.pbThis(true))) unless effectmessage == :None
      end
    } if trainereffect[:firstUnfaintedOpposingEffect]
    if trainereffect[:playerSideStatusChanges]
      if !pkmn.pbOpposing1.isFainted?
        if pkmn.pbOpposing1.pbCanApplySelectStatus?(trainereffect[:playerSideStatusChanges][0], pkmn, nil, showMessage: true)
          pkmn.pbOpposing1.pbApplySelectStatus(trainereffect[:playerSideStatusChanges][0], pkmn)
        end
      end
      if !pkmn.pbOpposing2.isFainted?
        if pkmn.pbOpposing1.pbCanApplySelectStatus?(trainereffect[:playerSideStatusChanges][0], pkmn, nil, showMessage: true)
          pkmn.pbOpposing2.pbApplySelectStatus(trainereffect[:playerSideStatusChanges][0], pkmn)
        end
      end
    end
    trainereffect[:opposingEffects].each_pair { |effect, effectval|
      if !pkmn.pbOpposing1.isFainted?
        pkmn.pbOpposing1.effects[effect] = effectval[0]
        pbAnimation(effectval[1], pkmn.pbOpposing1, nil) if !effectval[1].nil?
      end
      if !pkmn.pbOpposing2.isFainted?
        pkmn.pbOpposing2.effects[effect] = effectval[0]
        pbAnimation(effectval[1], pkmn.pbOpposing2, nil) if !effectval[1].nil?
      end
      effectmessage = effectval[2] != "" ? effectval[2] : _INTL("An effect was put up by {1}!")
      pbDisplay(_INTL(effectmessage, trainer.trainername, pkmn.pbThis(true)))
    } if trainereffect[:opposingEffects]
    if trainereffect[:weatherChange]
      if trainereffect[:weatherChange][0] == :Reset
        pbEndWeather
      else
        weathermessage = trainereffect[:weatherChange][2] ? trainereffect[:weatherChange][2] : nil
        rainbowduration = trainereffect[:weatherChange][1].nil? || trainereffect[:weatherChange][1] == -1 ? 5 : trainereffect[:weatherChange][1]
        duration = trainereffect[:weatherChange][1] ? trainereffect[:weatherChange][1] : -1
        duration = -1 if $game_switches[:Gen_5_Weather] == true && !self.isOnline?
        pbSetWeather(trainereffect[:weatherChange][0], duration, weathermessage, rainbowduration)
        noWeather
      end
    end
    # Effects affecting whole battlefield
    trainereffect[:stateChanges].each_pair { |effect, effectval|
      pbAnimation(effectval[1], pkmn, nil) if !effectval[1].nil?
      statemessage = effectval[2] != "" ? effectval[2] : _INTL("The state of the battle was changed!")
      pbDisplay(_INTL(statemessage, trainer.trainername)) unless statemessage == :None
      pbApplyGlobalEffect(effect, effectval[0])
    } if trainereffect[:stateChanges]

    # Effects affecting individual sides of battle
    [trainereffect[:trainersideChanges], trainereffect[:opposingsideChanges]].each_with_index { |data, i|
      next if data.nil?
      side = i == 0 ? pkmn.pbOwnSide : pkmn.pbOpposingSide
      data.each_pair { |effect, effectval|
        pbAnimation(effectval[1], pkmn, nil) if !effectval[1].nil?
        statemessage = effectval[2] != "" ? effectval[2] : _INTL("An effect was put up by {1}!")
        pbDisplay(_INTL(statemessage, trainer.trainername, pkmn.pbThis(true))) unless statemessage == :None
        pbApplySideEffect(effect, effectval[0], side, pkmn)
        if effect == :PsyBlades && effectval[0] == true
          @battlers.each do |mon|
            next if mon.isFainted?
            next if mon.pbOwnSide.effects[:PsyBlades] == false
            next if mon.crested == false
            mon.undoCrestStats
          end
        end
      }
    }
    if trainereffect[:pokemonStatusChanges]
      pkmn.status = trainereffect[:pokemonStatusChanges]
    end
    if trainereffect[:formchange]
      if trainereffect[:formchange].is_a?(Array)
        pkmn.pokemon.form = trainereffect[:formchange][0]
        pkmn.form = pkmn.pokemon.form
        pkmn.pokemon.ability = pkmn.pokemon.abilityIndex
        pbCommonAnimation(trainereffect[:formchange][1], pkmn, nil) if trainereffect[:formchange][1]
        pkmn.pbUpdate(true)
        @scene.pbChangePokemon(pkmn, pkmn.pokemon)
        if pkmn.effects[:Substitute] == 0
          @scene.pbUnSubstituteSprite(pkmn)
        else
          @scene.pbSubstituteSprite(pkmn)
        end
      else
        pkmn.pokemon.form = trainereffect[:formchange]
        pkmn.form = pkmn.pokemon.form
        pkmn.pokemon.ability = pkmn.pokemon.abilityIndex
        pbAnimation(:TRANSFORM, pkmn, nil)
        pkmn.pbUpdate(true)
        @scene.pbChangePokemon(pkmn, pkmn.pokemon)
        if pkmn.effects[:Substitute] == 0
          @scene.pbUnSubstituteSprite(pkmn)
        else
          @scene.pbSubstituteSprite(pkmn)
        end
      end
    end
    if trainereffect[:pokemonStatChanges]
      stats, amounts = *hashToParallelArrays(trainereffect[:pokemonStatChanges])
      pkmn.pbChangeStats(stats, amounts, pkmn, nil)
    end
    if trainereffect[:pokemonInterceptorBoosts]
      stats = [pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef]
      statsAtk = [pkmn.attack, pkmn.spatk]
      statsDef = [pkmn.defense, pkmn.spdef]
      statsarray = []
      statstoboost = [statsAtk.max] + [statsDef.max]
      stats.each do  |stat|
        statsarray.push(stats.index(stat) + 1) if statstoboost.include?(stat)
      end
      statsarray.uniq!
      # If multiple stats are tied for highest, they are prioritized in this order
      @battle.pbDisplay(_INTL("The power of the Core is enveloping {1}!", pkmn.pbThis))
      pkmn.pbChangeStats(statsarray, 1, pkmn, nil)
    end
    if trainereffect[:opposingSideStatChanges]
      for i in [pkmn.pbOpposing1, pkmn.pbOpposing2]
        next unless i.passiveAbilityApplies?

        stats, amounts = *hashToParallelArrays(trainereffect[:opposingSideStatChanges])
        i.pbChangeStats(stats, amounts, pkmn, nil)
      end
    end
    pbStatChangeChecks
    if trainereffect[:teraType]
      pkmn.teraTypeEffect = trainereffect[:teraType]
      if pkmn.teraTypeEffect.is_a?(Array)
        teratypemessage = (_INTL("{1} gained ", pkmn.pbThis))
        pkmn.teraTypeEffect.each do |teratype|
          teratypemessage += (_INTL("{1} ",getTypeName(teratype)))
          teratypemessage += (_INTL("and ")) if teratype != pkmn.teraTypeEffect.last
        end
        teratypemessage += (_INTL("-type resistances and strengths!"))
        @battle.pbDisplay(teratypemessage)
      else
        @battle.pbDisplay(_INTL("{1} gained {2}-type resistances and strengths!", pkmn.pbThis, getTypeName(trainereffect[:teraType])))
      end
    end
    if trainereffect[:addType]
      pkmn.effects[:TemporaryType] = trainereffect[:addType] #if !pkmn.types.include?(trainereffect[:addType])
      pbAnimation(trainereffect[:addTypeAnimation], pkmn, nil) if !trainereffect[:addTypeAnimation].nil?
      pbDisplay(_INTL("{1} gained the {2}-type!", pkmn.pbThis, getTypeName(pkmn.effects[:TemporaryType])))
    end
    if trainereffect[:applyCrest]
      pkmn.crested = trainereffect[:applyCrest]
      pkmn.crestStats
      pkmn.fakeCrest = true
      pbCrestEntry(pkmn.index, pkmn)
    end
    if trainereffect[:turntypeDamage]
      type, animation, damageDenom, message, hitself = trainereffect[:turntypeDamage]
      damageDenom ||= 8

      pokemonDummy = PokeBattle_Pokemon.new(:DITTO, 1)
      battlerDummy = PokeBattle_Battler.new(self, @battlers.length, true)
      battlerDummy.pbInitPokemon(pokemonDummy, @battlers.length)
      moveDummy = PokeBattle_Move_FFF.new(self, battlerDummy, type)
      moveDummy.category = :status

      targets = @battlers.map { |battler| battler.isFainted? ? nil : battler }.compact
      if !hitself
        targets.delete(pkmn) if targets.include?(pkmn)
        targets.delete(pkmn.pbPartner) if targets.include?(pkmn.pbPartner)
      end

      hitflags = [:Success] * targets.length
      moveDummy.pbTypeImmunities(battlerDummy, targets, hitflags)

      targets.each_with_index { |opp, i|
        case hitflags[i]
          when :Success
            vanished = opp.isSemiInvul?
            pbAnimation(animation, pkmn, opp)
            eff = moveDummy.pbTypeModifier(type, battlerDummy, opp)
            damage = [(opp.totalhp * eff.multiplier / damageDenom).floor, 1].max
            if delayKey == :RageOfTheHeavens2 && ((opp.lastRoundMoved == @turncount -1 && PBStuff::PROTECTMOVE.include?(opp.lastRegularMoveUsed)) || opp.effects[:Protect])
              pbDisplay(_INTL("{1}'s Protection guarded it from the strike!", opp.pbThis))
            else
              if delayKey == :RageOfTheHeavens2
                eff2 = moveDummy.pbTypeModifier(:ELECTRIC, battlerDummy, opp)
                damage = 0 if eff2.immune?
                if opp.hp > 0 && damage > 0
                  opp.pbReduceHP(damage)
                  opp.pbEffectsOnDealingDamage(moveDummy, battlerDummy, opp, damage, true)
                end
              else
                if opp.hp > 0 && damage > 0
                  opp.pbReduceHP(damage)
                  opp.pbEffectsOnDealingDamage(moveDummy, battlerDummy, opp, damage, true)
                end
              end
            end
            if vanished
              pbWait(2) # Wait 2 frames to give the damage animation time to finish playing fully before re-vanishing
              @scene.pbVanishSprite(opp)
              @scene.pbDisableShadowTemp(opp)
            end
          else
            battlerDummy.moveFailureEffects(battlerDummy, moveDummy, opp, hitflags[i])
        end
      }

      pbDisplay(_INTL(message, pkmn.pbThis)) if message
    end
    if trainereffect[:instantMove]
      moveobject = PokeBattle_Move.pbFromPBMove(self, PBMove.new(trainereffect[:instantMove][0]), pkmn.pokemon)
      if $cache.moves[trainereffect[:instantMove][0]].zmovedata
        moveobject.zmove = true
      end
      if trainereffect[:instantMove][1] == :LastAttacker
        if pkmn.lastAttacker != -1
          target = pkmn.lastAttacker
          pkmn.pbUseMoveSimple(moveobject, -1, target, specialZ: true)
        end
      else
        target = trainereffect[:instantMove][1] ? trainereffect[:instantMove][1] : pkmn.index
        pkmn.pbUseMoveSimple(moveobject, -1, target, specialZ: true)
      end
    end
    if trainereffect[:userSwitch]
      pkmn.userSwitch = :TrainerSkill
    end
    if trainereffect[:reuseZMovePlayer]
      # @party1.zMove          = -1
      @battle.zMove[0][0] = -1
      for i in @battlers
        next if !pkmn.pbIsOpposing?(i.index) || i.hp <= 0

        i.zmoves = [nil, nil, nil, nil]
        for j in 0...4
          @battle.updateZMoveIndexBattler(j, i, true)
        end
        # mon gets a flag to allow it to use zmoves with it
        i.effects[:IgnoreZflag] = true
        pbCommonAnimation("ZPower", i, nil)
      end
    end
    if trainereffect[:LastWord]
      pbAnimation(:GRUDGE, pkmn, nil)
      pbDisplay(_INTL("{1} is preparing to have the last word...", pkmn.pbThis))
      pkmn.effects[:LastWord] = trainereffect[:LastWord]
    end
    if delayKey
      waitListIndex = trainer.delayList.index([delayKey, 0])
      trainer.delayList[waitListIndex] = nil
    end
    if trainereffect[:queueDelays]
      trainer.delayList = [] if trainer.delayList.nil?
      for effect in trainereffect[:queueDelays]
        trainer.delayList.push([effect, trainer.delayRegister[effect][:delay].clone])
      end
    end
    @scene.pbHideOpponent if showtrainer
    @scene.pbHidePokemon if showpokemon
    if trainereffect[:userSwitch] && !faint && !moveReaction
      pkmn.carryOutUserSwitch
    end
  end

  def moveReact(targets, choice, user, midturn: false)
    battler = nil
    usertrainer = pbGetOwner(user.index)
    # grab a battler within the list of targets for the move we are reacting to
    # check that battlers trainer for if they have a trainereffect set, then set battler to that as a base
    for i in targets
      trainer = pbGetOwner(i.index)
      if @player.is_a?(Array)
        if [@player[0],@player[1]].include?(trainer)
          if @opponent.is_a?(Array)
            trainer = [@opponent[0],@opponent[1]].select{|trainers| !trainers.trainereffect.nil?}[0]
          else
            trainer = @opponent
          end
        end
      else
        if @player == trainer
          if @opponent.is_a?(Array)
            trainer = [@opponent[0],@opponent[1]].select{|trainers| !trainers.trainereffect.nil?}[0]
          else
            trainer = @opponent
          end
        end
      end
      next if trainer.nil?
      next if trainer.trainereffect.nil?
      next if trainer.trainereffect[:effectmode].nil?

      battler = i
      if pbOwnedByPlayer?(battler.index)
        battler = battler.pbFirstOpposing
      end
      break if battler # no need to keep going if we have a valid battler
    end

    if trainer&.trainereffect
      return if trainer == usertrainer
      if trainer&.trainereffect[:ReactToMoves]
        trainereffect = trainer&.trainereffect[:ReactToMoves]
        return if !trainereffect[:midturn] && midturn # checking for where this gets run from.
        return if trainereffect[:midturn] && !midturn # if we do midturn reactions, don't run it if it isnt midturn
        if trainereffect[:movesToReact]
          trainereffect[:movesToReact].each { |moves|
            validmoves = moves.first
            if validmoves.is_a?(Array)
              if validmoves.include?(choice.move)
                runtrainerskills(battler, false, false, trainereffect[:movesToReact][validmoves])
                if trainereffect[:movesToReact][validmoves][:both]
                  if !battler.pbPartner&.isFainted?
                    runtrainerskills(battler.pbPartner, false, false, trainereffect[:movesToReact][validmoves])
                  end
                end
              end
            else
              if validmoves == choice.move
                runtrainerskills(battler, false, false, trainereffect[:movesToReact][validmoves])
                if trainereffect[:movesToReact][validmoves][:both]
                  if !battler.pbPartner&.isFainted?
                    runtrainerskills(battler.pbPartner, false, false, trainereffect[:movesToReact][validmoves])
                  end
                end
              end
            end
          }
        end
      end
    end
  end

  def delayedaction
    trainerPriority = []
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      trainer = pbGetOwner(i.index)
      if trainer && trainer.delayList
        for effectkeys in trainer.delayList
          delayeffect = trainer.delayRegister[effectkeys[0]]
          activeDelays = deep_copy(trainer.delayList).transpose[0]
          if delayeffect[:pokemonBound]
            if pbPartySingleOwner(i.index)[delayeffect[:pokemonBound]].hp == 0
              trainer.delayList.delete(effectkeys)
              next
            end
          end
          if delayeffect[:getsOverwritten]
            if activeDelays.intersect?(delayeffect[:getsOverwritten])
              trainer.delayList.delete(effectkeys)
              next
            end
          end
          if delayeffect[:endCondition]
            if eval(delayeffect[:endCondition])
              trainer.delayList.delete(effectkeys)
              next
            end
          end
        end
        trainerPriority.push(trainer) if !trainer.delayList.empty? && !trainerPriority.include?(trainer)
      end
      if i.isbossmon && !i.bossDelayList.nil?
        for effectkeys in i.bossDelayList
          delayeffect = $cache.bosses[i.pokemon.bossID].delayRegister[effectkeys[0]]
          activeDelays = deep_copy(i.bossDelayList).transpose[0]
          if delayeffect[:getsOverwritten]
            if activeDelays.intersect?(delayeffect[:getsOverwritten])
              i.bossDelayList.delete(effectkeys)
              next
            end
          end
          if delayeffect[:endCondition]
            if eval(delayeffect[:endCondition])
              i.bossDelayList.delete(effectkeys)
              next
            end
          end
        end
        next if i.bossDelayList.empty?
        # running the delayed Effect may add a new effect to the list,
        # so that this new effect isn't run immediately we limit the iteration to the length of the list at the start
        for index in 0...i.bossDelayList.length
          delaykeys = i.bossDelayList[index]
          next if delaykeys.nil?
          delaykeys[1] -= 1 if delaykeys[1] > 0
          if delaykeys[1] == 0
            delayeffect = $cache.bosses[i.pokemon.bossID].delayRegister[delaykeys[0]]
            pbShieldEffects(i, delayeffect, false, delaykeys[0])
            for j in priority
              next if j.fainted
              j.pbFaint if j.isFainted?
            end
            pbReplaceFaintedBattlers
          end
        end
        i.bossDelayList.compact! # remove nil values which is to say expended delayed actions
      end
    end
    return if trainerPriority.empty?
    for trainer in trainerPriority
      next if trainer.delayList.nil?
      # running the delayed Effect may add a new effect to the list,
      # so that this new effect isn't run immediately we limit the iteration to the length of the list at the start
      for index in 0...trainer.delayList.length
        battler = nil
        delaykeys = trainer.delayList[index]
        next if delaykeys.nil?
        delayEffect = trainer.delayRegister[delaykeys[0]]
        for i in priority
          next if i.isFainted?
          next if pbGetOwner(i.index) != trainer
          next if delayEffect[:pokemonBound] && (delayEffect[:pokemonBound] != i.pokemonIndex)
          battler = i
        end
        next unless battler
        delaykeys[1] -= 1 if delaykeys[1] > 0
        if delaykeys[1] == 0
          runtrainerskills(battler, delaykeys[0])
          for j in priority
            next if j.fainted
            j.pbFaint if j.isFainted?
          end
          pbReplaceFaintedBattlers
        end
      end
      trainer.delayList.compact! # remove nil values which is to say expended delayed actions
    end
  end

  ################################################################################
  # Battle core.
  ################################################################################
  def pbStartBattle(canlose = false)
    for party in @party1
      if party.length > PLAYERMAXPARTYSIZE
        raise ArgumentError.new(_INTL("Party 1 has more than {1} Pokémon.", PLAYERMAXPARTYSIZE))
      end
    end
    for party in @party2
      if party.length > OPPONENTMAXPARTYSIZE
        raise ArgumentError.new(_INTL("Party 2 has more than {1} Pokémon.", OPPONENTMAXPARTYSIZE))
      end
    end

    #========================
    # Initialize AI in battle
    #========================
    @ai = pbInstantiateAI
    $ai_log_data = [PokeBattle_AI_Info.new, PokeBattle_AI_Info.new, PokeBattle_AI_Info.new, PokeBattle_AI_Info.new] unless isOnline?
    if !@opponent
      #========================
      # Initialize wild Pokémon
      #========================
      if @party2[0].length == 1
        wildpoke = @party2[0][0]
        @battlers[1].pbInitialize(wildpoke, 0, false)
        $Trainer.pokedex.setSeen(wildpoke)
        pbRegisterRevealedBoss(1)
        @scene.pbStartBattle(self)
        if @battlers[1].isbossmon && @battlers[1].entryText != nil
          bossEntryText(@battlers[1])
        elsif $game_switches[:Unique_Wild_Encounter]
          msg = _INTL("{1} appeared!", wildpoke.name)
          pbDisplayBrief(msg)
        else
          msg = _INTL("A wild {1} appeared!", wildpoke.name)
          pbDisplayBrief(msg)
        end
      elsif @party2[0].length == 2
        @battlers[1].pbInitialize(@party2[0][0], 0, false)
        @battlers[3].pbInitialize(@party2[0][1], 0, false)
        $Trainer.pokedex.setSeen(@party2[0][0])
        $Trainer.pokedex.setSeen(@party2[0][1])
        pbRegisterRevealedBoss(1)
        pbRegisterRevealedBoss(3)
        @scene.pbStartBattle(self)
        bosses = [@battlers[1],@battlers[3]].select {|boss| boss.isbossmon}
        if bosses.include?(@battlers[1]) && bosses.include?(@battlers[3])
          bossEntryText(@battlers[1])
          bossEntryText(@battlers[3]) if @battlers[1].entryText != @battlers[3].entryText
        elsif bosses.include?(@battlers[1])
          bossEntryText(@battlers[1])
          pbDisplayPaused(_INTL("A wild {1} appeared!", @party2[0][1].name))
        elsif bosses.include?(@battlers[3])
          bossEntryText(@battlers[3])
          pbDisplayPaused(_INTL("A wild {1} appeared!", @party2[0][0].name))
        else
          pbDisplayBrief(_INTL("A wild {1} and\n{2} appeared!", @party2[0][0].name, @party2[0][1].name))
        end
      else
        raise _INTL("Only one or two wild Pokémon are allowed")
      end
    elsif @doublebattle
      #=======================================
      # Initialize opponents in double battles
      #=======================================
      if @opponent.is_a?(Array)
        if @opponent.length == 1
          @opponent = @opponent[0]
        elsif @opponent.length != 2
          raise _INTL("Opponents with zero or more than two people are not allowed")
        end
      end
      if @player.is_a?(Array)
        if @player.length == 1
          @player = @player[0]
        elsif @player.length != 2
          raise _INTL("Player trainers with zero or more than two people are not allowed")
        end
      end
      @scene.pbStartBattle(self)
      if @opponent.is_a?(Array)
        lineOpponents = @opponent.select { |opp| opp.teamAttributes[:openingLine] }
        if !lineOpponents.empty?
          lineOpponents.each { |opp| pbOpeningMessage(opp) }
        else
          pbDisplayAutoPaused(_INTL("{1} and {2} would like to battle!", @opponent[0].fullname, @opponent[1].fullname))
        end
        sendout1 = pbFindNextUnfainted(@party2[0])
        raise _INTL("Opponent 1 has no unfainted Pokémon") if sendout1 < 0

        sendout2 = pbFindNextUnfainted(@party2[1])
        raise _INTL("Opponent 2 has no unfainted Pokémon") if sendout2 < 0

        @battlers[1].pbInitialize(@party2[0][sendout1], sendout1, false)
        @battlers[3].pbInitialize(@party2[1][sendout2], sendout2, false)
        leadname1 = pbSwitchInName(1, sendout1) # Illusion
        leadname2 = pbSwitchInName(3, sendout2) # Illusion
        pbDisplayBrief(_INTL("{1} and {2} sent out {3} and {4}!", @opponent[0].fullname, @opponent[1].fullname, leadname1, leadname2))
        pbSendOut([[1, @party2[0][sendout1], false], [3, @party2[1][sendout2], false]])
        bosses = [@battlers[1],@battlers[3]].select {|boss| boss.isbossmon}
        if bosses.include?(@battlers[1]) && bosses.include?(@battlers[3])
          bossEntryText(@battlers[1])
          bossEntryText(@battlers[3]) if @battlers[1].entryText != @battlers[3].entryText
        elsif bosses.include?(@battlers[1])
          bossEntryText(@battlers[1])
        elsif bosses.include?(@battlers[3])
          bossEntryText(@battlers[3])
        end
      else
        if @opponent.teamAttributes[:openingLine]
          pbOpeningMessage(@opponent)
        else
          pbDisplayAutoPaused(_INTL("{1} would like to battle!", @opponent.fullname))
        end
        sendout1 = pbFindNextUnfainted(@party2[0])
        sendout2 = pbFindNextUnfainted(@party2[0], sendout1 + 1)
        if sendout1 < 0 || sendout2 < 0
          # raise _INTL("Opponent doesn't have two unfainted Pokémon")
          leadname = pbSwitchInName(1, sendout1) # Illusion
          pbDisplayBrief(_INTL("{1} sent out {2}!", @opponent.fullname, leadname))
          @battlers[1].pbInitialize(@party2[0][sendout1], sendout1, false)
          pbSendOut([[1, @party2[0][sendout1], false]])
        else
          @battlers[1].pbInitialize(@party2[0][sendout1], sendout1, false)
          @battlers[3].pbInitialize(@party2[0][sendout2], sendout2, false)
          leadname1 = pbSwitchInName(1, sendout1) # Illusion
          leadname2 = pbSwitchInName(3, sendout2) # Illusion
          pbDisplayBrief(_INTL("{1} sent out {2} and {3}!", @opponent.fullname, leadname1, leadname2))
          pbSendOut([[1, @party2[0][sendout1], false], [3, @party2[0][sendout2], false]])
        end
      end
    else
      #======================================
      # Initialize opponent in single battles
      #======================================
      sendout = pbFindNextUnfainted(@party2[0])
      raise _INTL("Trainer has no unfainted Pokémon") if sendout < 0

      if @opponent.is_a?(Array)
        raise _INTL("Opponent trainer must be only one person in single battles") if @opponent.length != 1

        @opponent = @opponent[0]
      end
      if @player.is_a?(Array)
        raise _INTL("Player trainer must be only one person in single battles") if @player.length != 1

        @player = @player[0]
      end
      trainerpoke = @party2[0][sendout]
      @scene.pbStartBattle(self)
        if @opponent.teamAttributes[:openingLine]
          pbOpeningMessage(@opponent)
        else
          pbDisplayAutoPaused(_INTL("{1} would like to battle!", @opponent.fullname))
        end

      @battlers[1].pbInitialize(trainerpoke, sendout, false)
      leadname = pbSwitchInName(1, sendout) # Illusion
      pbDisplayBrief(_INTL("{1} sent out {2}!", @opponent.fullname, leadname))

      pbSendOut([[1, trainerpoke, false]])
      if @battlers[1].entryText != nil
        bossEntryText(@battlers[1])
      end
    end
    #=====================================
    # Initialize players in double battles
    #=====================================
    pbBossSOS(false, true)

    if @doublebattle && @sosbattle != :singlePokemonPlayerSide
      if @player.is_a?(Array)
        sendout1 = pbFindNextUnfainted(@party1[0])
        raise _INTL("Player 1 has no unfainted Pokémon") if sendout1 < 0

        sendout2 = pbFindNextUnfainted(@party1[1])
        raise _INTL("Player 2 has no unfainted Pokémon") if sendout2 < 0

        @battlers[0].pbInitialize(@party1[0][sendout1], sendout1, false)
        @battlers[2].pbInitialize(@party1[1][sendout2], sendout2, false)
        leadname1 = pbSwitchInName(0, sendout1) # Illusion
        leadname2 = pbSwitchInName(2, sendout2) # Illusion
        pbDisplayBrief(_INTL("{1} sent out {2}! Go! {3}!", @player[1].fullname, leadname2, leadname1))
        $Trainer.pokedex.setSeen(@party1[0][sendout1])
        $Trainer.pokedex.setSeen(@party1[1][sendout2])
        pbSendOut([[0, @party1[0][sendout1], false], [2, @party1[1][sendout2], false]])
      else
        sendout1 = pbFindNextUnfainted(@party1[0])
        sendout2 = pbFindNextUnfainted(@party1[0], sendout1 + 1)
        @battlers[0].pbInitialize(@party1[0][sendout1], sendout1, false)
        @battlers[2].pbInitialize(@party1[0][sendout2], sendout2, false) unless sendout2 == -1
        if sendout2 > -1
          leadname1 = pbSwitchInName(0, sendout1) # Illusion
          leadname2 = pbSwitchInName(2, sendout2) # Illusion
          pbDisplayBrief(_INTL("Go! {1} and {2}!", leadname1, leadname2))
        else
          leadname = pbSwitchInName(0, sendout1) # Illusion
          pbDisplayBrief(_INTL("Go! {1}!", leadname))
        end
        slots = [[0, @party1[0][sendout1], false]]
        slots.push [2, @party1[0][sendout2], false] unless sendout2 == -1
        pbSendOut(slots)
      end
    else
      #====================================
      # Initialize player in single battles
      #====================================
      sendout = pbFindNextUnfainted(@party1[0])
      if sendout < 0
        raise _INTL("Player has no unfainted Pokémon")
      end

      playerpoke = @party1[0][sendout]
      @battlers[0].pbInitialize(playerpoke, sendout, false)
      leadname = pbSwitchInName(0, sendout) # Illusion
      pbDisplayBrief(_INTL("Go! {1}!", leadname))
      pbSendOut([[0, playerpoke, false]])
    end
    #=======================================================
    # Keep track of who fainted in battle + piece assignment
    #=======================================================
    @fainted_mons = Array.new($Trainer.party.length) { |i| $Trainer.party[i].hp <= 0 }
    if @doublebattle
      if @player.is_a?(Array)
        pieceAssignment(pbPartySingleOwner(0), true)
        pieceAssignment(pbPartySingleOwner(2), true)
      else
        pieceAssignment(@party1[0], false)
      end
      if @opponent.is_a?(Array)
        pieceAssignment(pbPartySingleOwner(1), true)
        pieceAssignment(pbPartySingleOwner(3), true)
      else
        pieceAssignment(@party2[0], false)
      end
    else
      pieceAssignment(@party1[0], false)
      pieceAssignment(@party2[0], false)
    end

    #==================
    # Initialize battle
    #==================
    noWeather
    if @weather == :SUNNYDAY
      pbCommonAnimation("Sunny")
      pbDisplay(_INTL("The sunlight is harsh!"))
    elsif @weather == :RAINDANCE
      pbCommonAnimation("Rain")
      pbDisplay(_INTL("It's raining!"))
    elsif @weather == :SANDSTORM
      pbCommonAnimation("Sandstorm")
      pbDisplay(_INTL("The sandstorm is raging!"))
    elsif @weather == :HAIL
      pbCommonAnimation("Hail")
      pbDisplay(_INTL("It's hailing!"))
    elsif @weather == :SNOW
      pbCommonAnimation("Hail")
      pbDisplay(_INTL("It's snowing!"))
    elsif @weather == :STRONGWINDS
      pbCommonAnimation("Wind")
      pbDisplay(_INTL("It's windy!"))
    elsif @weather == :SHADOWSKY
      pbCommonAnimation("SHADOWSKY")
      pbDisplay(_INTL("The sky is filled with a shadowy aura!"))
    end
    # Field Effects BEGIN UPDATE
    if @field.introMessage
      fieldmessage = pbGetMessageFromHash(:FieldMessages, @field.introMessage)
      fieldmessage = _INTL("The dawn of a New World shines down upon the broken land.") if pbCheckGlobalAbility(:WORLDOFNIGHTMARES) && @field.effect == :STARLIGHT
      fieldmessages = fieldmessage.gsub("|", "").split("\n\n")
      fieldmessages.each { |msg| pbDisplay(msg) }
      $game_variables[:Cave_Collapse] = 0
      pbSetGravity(-1) if @field.effect == :DEEPEARTH
    end
    # END OF UPDATE

    # Entry effects on battle start
    pbOnBattleStart

    # Fix Charge, Laser Focus and Lock-On duration from seeds
    for i in @battlers
      i.effects[:LockOn] -= 1 if i.effects[:LockOn] > 0
      i.effects[:Charge] -= 1 if i.effects[:Charge] > 0 && Gen < 9
      i.effects[:LaserFocus] -= 1 if i.effects[:LaserFocus] > 0
    end

    @turncount = 1
    PBDebug.flush # transfer logs from buffer to file at start of battle
    return pbBattleLoop(canlose)
  end

  def pbInstantiateAI # Overridden by tests
    return PokeBattle_AI.new(self)
  end

  def pbBattleLoop(canlose)
    if !isOnline? # for subclassing- online processing continues separately
      catch(:decision) do
        loop do # Now begin the battle loop
          pbRunTurn
        end
      end
      return pbEndOfBattle(canlose)
    end
  end

  def pbRunTurn
    fakeOutBattleEnd if Rejuv && @decision == 1
    throw(:decision) if @decision > 0

    addRoundStringToLog

    PBDebug.logonerr {
      @phase = :commandPhase
      pbCommandPhase
      @phase = nil
    }
    fakeOutBattleEnd if Rejuv && @decision == 1
    throw(:decision) if @decision > 0

    PBDebug.logonerr {
      @phase = :attackPhase
      pbAttackPhase()
      @phase = nil
    }
    fakeOutBattleEnd if Rejuv && @decision == 1
    throw(:decision) if @decision > 0

    PBDebug.logonerr {
      @phase = :endOfRoundPhase
      pbEndOfRoundPhase
      @phase = nil
    }
    fakeOutBattleEnd if Rejuv && @decision == 1
    throw(:decision) if @decision > 0

    @turncount += 1
    PBDebug.flush # transfer logs from buffer to file at end of every round
  end

  ################################################################################
  # Command phase.
  ################################################################################
  def pbCommandMenu(i)
    return @scene.pbCommandMenu(i)
  end

  def pbAutoFightMenu(i)
    return false
  end

  def pbCommandPhase()
    delayedaction
    @scene.pbBeginCommandPhase
    @scene.pbResetCommandIndices if $Settings.remember_commands == 0
    tts("Battlers: ")
    for i in 0...4
      tts(pbPokemonString(battlers[i])) if !pbIsEnemy(i)
      tts(pbEnemyPokemonString(battlers[i])) if pbIsEnemy(i)
      break if !@doublebattle && i >= 1
    end
    for i in 0...4 # Reset choices if commands can be shown
      if Rejuv
        @specialchoices[i] = [nil]
      end
      if pbCanShowCommands?(i) || @battlers[i].isFainted?

        @choices[i] = [nil]
      else
        battler = @battlers[i]
        unless !@doublebattle && pbIsDoubleBattler?(i)
          PBDebug.dblog("[Reusing commands for #{battler.logname}]")
        end
      end
    end
    for i in 0..3
      @switchedOut[i] = false
    end
    # Reset choices to perform Mega Evolution/Z-Moves/Ultra Burst if it wasn't done somehow
    for i in 0...@megaEvolution[0].length
      @megaEvolution[0][i] = -1 if @megaEvolution[0][i] >= 0
    end
    for i in 0...@megaEvolution[1].length
      @megaEvolution[1][i] = -1 if @megaEvolution[1][i] >= 0
    end
    for i in 0...@ultraBurst[0].length
      @ultraBurst[0][i] = -1 if @ultraBurst[0][i] >= 0
    end
    for i in 0...@ultraBurst[1].length
      @ultraBurst[1][i] = -1 if @ultraBurst[1][i] >= 0
    end
    for i in 0...@terastal[0].length
      @terastal[0][i] = -1 if @terastal[0][i] >= 0
    end
    for i in 0...@terastal[1].length
      @terastal[1][i] = -1 if @terastal[1][i] >= 0
    end
    for i in 0...@zMove[0].length
      @zMove[0][i] = -1 if @zMove[0][i] >= 0
    end
    for i in 0...@zMove[1].length
      @zMove[1][i] = -1 if @zMove[1][i] >= 0
    end
    pbJudge # juuuust in case we don't want to be here
    return if @decision > 0

    for i in 0...4
      @battlers[i].pbUpdateDynamicZMoves
    end

    # Clear message box (necessary when animations are disabled)
    @scene.pbClear

    # Experimental: Let the AI choose its moves in a separate thread
    aithread = nil
    decimationcheck = false
    decimationindexes = []
    unless isOnline?
      for i in 0...4
        if @battlers[i].hp > 0 && (!pbOwnedByPlayer?(i) && !(pbOwnedByAIPartner?(i) && $game_switches[:Control_Partners]) || @controlPlayer)
          if @battlers[i].pbHasMove?(:DECIMATION)
            decimationcheck = true
            decimationindexes.push(i)
          end
        end
      end
      @ai.processAIturn

      # commenting out as per haru's request

      # if $kirin || decimationcheck
      #   @ai.processAIturn
      # else
      #   aithread = Thread.new do
      #     @ai.processAIturn
      #   end
      # end
    end

    if decimationcheck
      for decimationindex in decimationindexes
        if @choices[decimationindex][2]&.move == :DECIMATION
          target = @choices[decimationindex][3] != -1 ? @battlers[@choices[decimationindex][3]] : @battlers[decimationindex].pbOppositeOpposing
          pbDisplay(_INTL("{1} is charging Decimation at {2}!", @battlers[decimationindex].name, target.name))
        end
      end
    end

    commandDone = false
    until commandDone
      commandDone = commandloop()
      return if commandDone == :Flee
    end

    aithread&.join unless isOnline?



    logPlayerChoices()

    # AI Data collection perry
    if !(pbIsWild? && !(@battlers.any? { |i| i.isbossmon || i.issosmon}))  && !isOnline?
      for i in 0...4
        $ai_log_data[i].logAIScorings() if @battlers[i].hp > 0 && aiControlled?(i)
      end
    end
    if $game_variables[:LuckShinies] != 0 && Rejuv
      for battler in @battlers
        if battler.isWildPokemon? && !battler.isFainted? && battler.pokemon.isShiny? && !battler.isbossmon && !battler.issosmon && @decision != 4
          if pbRandom(100) < 10
            pbSEPlay("escape", 100)
            pbDisplay(_INTL("{1} fled!", battler.name))
            @decision = 3
          end
        end
      end
    end
    # Displays the message box window so battle animations don't play over menus
    @scene.pbShowWindow(PokeBattle_Scene::MESSAGEBOX)
  end

  def commandloop()
    for i in 0...4
      return true if @decision != 0
      next if !@choices[i][0].nil?
      next if @battlers[i].issosmon
      next if !pbCanShowCommands?(i)
      next if aiControlled?(i)
      # side = pbIsOpposing?(i) ? 1 : 0 # unneccessary we are only dealing with player side actions so it's always side 0
      owner = pbGetOwnerIndex(i)

      catch :CommandInput do
        loop do
          cmd = pbCommandMenu(i)
          if cmd == 0 # Fight
            if pbCanShowFightMenu?(i)
              throw :CommandInput if pbAutoFightMenu(i)
              loop do
                index = @scene.pbFightMenu(i)
                if index < 0
                  pbDisableAButtonChoices(i)
                  break
                end
                if !pbRegisterMove(i, index, showMessage: true)
                  @zMove[0][owner] = -1 if @zMove[0][owner] == i
                  next
                end
                if @doublebattle
                  basemove = @zMove[0][owner] == i ? @battlers[i].zmoves[index] : @battlers[i].moves[index]
                  target = @battlers[i].pbTarget(basemove)
                  if [:SingleNonUser, :DragonDarts, :NonUserPosition].include?(target)
                    target = @scene.pbChooseTarget(i)
                    if target < 0
                      @zMove[0][owner] = -1 if @zMove[0][owner] == i
                      next
                    end
                    pbRegisterTarget(i, target)
                  elsif [:SingleOpposing, :UserOrPartner].include?(target)
                    target = @scene.pbChooseTargetOneSide(i, target)
                    if target < 0
                      @zMove[0][owner] = -1 if @zMove[0][owner] == i
                      next
                    end
                    pbRegisterTarget(i, target)
                  end
                end
                throw :CommandInput
              end
            else
              throw :CommandInput if pbAutoChooseMove(i)
            end
          elsif cmd == 1 # Bag
            if !@internalbattle
              if pbOwnedByPlayer?(i)
                pbDisplay(_INTL("Items can't be used here."))
              end
            elsif @battlers[i].effects[:SkyDrop]
              pbDisplay(_INTL("Sky Drop won't let {1} go!", @battlers[i].name))
            else
              item = @scene.pbItemMenu(i)
              if item[0]
                if pbRegisterItem(i, item[0], item[1])
                  @specialchoices[i] = [nil]
                  throw :CommandInput
                end
              end
            end
          elsif cmd == 2 # Pokémon
            # Cannot use pbSwitchInBetween here because of online battles
            partyindex = @scene.pbSwitchPlayer([i], false, true)[i]
            if partyindex >= 0
              throw :CommandInput if pbRegisterSwitch(i, partyindex)
            end
          elsif cmd == 3   # Run
            run = pbRun(i)
            if run > 0
              return :Flee
            elsif run < 0
              if @megaEvolution[0][owner] == i
                @megaEvolution[0][owner] = -1
              end
              if @ultraBurst[0][owner] == i
                @ultraBurst[0][owner] = -1
              end
              if @terastal[0][owner] == i
                @terastal[0][owner] = -1
              end
              if @zMove[0][owner] == i
                @zMove[0][owner] = -1
              end
              throw :CommandInput
            end
          elsif cmd == 4   # Call
            @choices[i] = [:call]
            if @megaEvolution[0][owner] == i
              @megaEvolution[0][owner] = -1
            end
            if @ultraBurst[0][owner] == i
              @ultraBurst[0][owner] = -1
            end
            if @terastal[0][owner] == i
              @terastal[0][owner] = -1
            end
            if @zMove[0][owner] == i
              @zMove[0][owner] = -1
            end
            throw :CommandInput
          elsif cmd == 5 # rejuv special moves
            loop do
              if $game_switches[:Only_Ally_Moves]
                counter = 0
                @battlers[i].specialmoves.each do |move, effect|
                  counter += 1 if @sides[0].effects[:SpecialMoves][move.move] == -1
                end
                if counter == 6 && @specialchoices[@battlers[i].pbPartner.index] != [nil]
                  throw :CommandInput
                  break
                end
              end
              index = @scene.pbFightMenuDX(i)
              if index < 0
                break
              end
              if !pbRegisterSpecialMove(i, index)
                next
              end
              if @doublebattle
                basemove = @battlers[i].specialmoves[index]
                target = @battlers[i].pbTarget(basemove)
                if [:SingleNonUser, :DragonDarts, :NonUserPosition].include?(target)
                  target = @scene.pbChooseTarget(i, special: true)
                  if target < 0
                    next
                  end
                  pbRegisterSpecialMoveTarget(i, target)
                elsif [:SingleOpposing, :UserOrPartner].include?(target)
                  target = @scene.pbChooseTargetOneSide(i, target, special: true)
                  if target < 0
                    next
                  end
                  pbRegisterSpecialMoveTarget(i, target)
                end
              end
              if [:ORBITALRING].include?(@battlers[i].specialmoves[index].move) || $game_switches[:Only_Ally_Moves]
                throw :CommandInput
                break
              end
              break # break here to get back to the main fight menu, as special choice selection doesn't end movechoice
            end
          elsif cmd == -1 # Go back to first battler's choice
            @megaEvolution[0][0] = -1 if @megaEvolution[0][0] >= 0
            @ultraBurst[0][0] = -1 if @ultraBurst[0][0] >= 0
            @terastal[0][0] = -1 if @terastal[0][0] >= 0
            @zMove[0][0] = -1 if @zMove[0][0] >= 0
            # only reset second playerside trainer registers if there is such a trainer and the player has control of them
            # if the player doesn't control them don't overrule AI actions running parallel
            if @player.is_a?(Array) && $game_switches[:Control_Partners]
              @megaEvolution[0][1] = -1 if @megaEvolution[0][1] >= 0
              @ultraBurst[0][1] = -1 if @ultraBurst[0][1] >= 0
              @terastal[0][1] = -1 if @terastal[0][1] >= 0
              @zMove[0][1] = -1 if @zMove[0][1] >= 0
            end
            for j in 0...4 # Reset choices if commands can be shown
              next if !pbOwnedByPlayer?(j) && !(pbOwnedByAIPartner?(j) && $game_switches[:Control_Partners])
              if pbCanShowCommands?(j) || @battlers[j].isFainted?
                @choices[j] = [nil]
                @specialchoices[j] = [nil]
              end
            end
            # Restore the item the player's first Pokémon was due to use
            if @choices[0][0] == :item && $PokemonBag && $PokemonBag.pbCanStore?(@choices[0][1])
              $PokemonBag.pbStoreItem(@choices[0][1])
            end
            return false
          elsif cmd == :ball # Throw default Poke Ball using Z
            if pbRegisterItem(i, $PokemonBag.defaultBall, @battle.battlers[i].pokemonIndex)
              throw :CommandInput
            end
          end
        end
      end
    end
    return true
  end

  def logPlayerChoices()
    PBDebug.dblog("\n" + ("_" * 78) + "\nPlayer's choices:")
    logExtraAction(0)
    logExtraAction(1) if @player.is_a?(Array)
    logBattlerChoice(0)
    logBattlerChoice(2) if doublebattle
  end

  def logExtraAction(ownerIndex)
    if @megaEvolution[0][ownerIndex] >= 0
      PBDebug.dblog(sprintf("%s: mega evolve", @battlers[@megaEvolution[0][ownerIndex]].logname))
    end
    if @ultraBurst[0][ownerIndex] >= 0
      PBDebug.dblog(sprintf("%s: Ultra burst", @battlers[@ultraBurst[0][ownerIndex]].logname))
    end
    if @terastal[0][ownerIndex] >= 0
      PBDebug.dblog(sprintf("%s: terastallize", @battlers[@terastal[0][ownerIndex]].logname))
    end
    if @zMove[0][ownerIndex] >= 0
      PBDebug.dblog(sprintf("%s: Z-move", @battlers[@zMove[0][ownerIndex]].logname))
    end
  end

  def logBattlerChoice(battlerIndex)
    choice = @choices[battlerIndex]
    name = @battlers[battlerIndex].logname
    case choice[0]
      when :move
        string = sprintf("%s: use %s", name, choice[2] ? choice[2].name : "???")
        if @battle.doublebattle && choice[3].is_a?(Integer)
          targetname = @battlers[choice[3]].logname
          string += sprintf(" against %s", targetname)
        end
        PBDebug.dblog(string)
      when :switch
        targetname = pbPartySingleOwner(battlerIndex)[choice[1]].logname
        PBDebug.dblog(sprintf("%s: switch to %s", name, targetname))
      when :item
        targetname = pbPartySingleOwner(battlerIndex)[choice[2]].logname
        PBDebug.dblog(sprintf("%s: use item %s on %s", name, getItemName(choice[1]), targetname))
      when :call, :run then PBDebug.dblog(sprintf("%s: %s", name, choice[0]))
    end
  end

  ################################################################################
  # Attack phase.
  ################################################################################
  def pbAttackPhase
    @scene.pbBeginAttackPhase
    clearTurnOrderData
    setTieBreakData
    setSubPrioData # Quick Claw / Custap here
    @fusionMove = nil
    for i in 0...4
      if @choices[i][0] != :move && @choices[i][0] != :switch
        # @battlers[i].effects[:DestinyBond]=false # Effect gets removed on move use, NOT move choice
        @battlers[i].effects[:Grudge] = false
      end
      if !@battlers[i].isFainted?
        @battlers[i].turncount += 1
        @battlers[i].permeffs[:ChargeAttackCountdown] += 1 if @battlers[i].permeffs[:ChargeAttackCountdown] && @battlers[i].chargeAttackRequirementMet?
        @battlers[i].missAcc = false
      end
      @battlers[i].effects[:Rage] = false if @choices[i][0] != :move || @choices[i][2].move != :RAGE
      # @battlers[i].pbCustapBerry # Moved to later, timing was incorrect here
    end
    # Calculate priority at this time
    priority = setSpeedOrder
    # Call at Pokémon
    for i in priority
      pbCall(i.index) if @choices[i.index][0] == :call
    end
    # Switch out Pokémon
    for i in priority
      if @choices[i.index][0] == :switch && !(@field.effect == :COLOSSEUM)
        index = @choices[i.index][1] # party position of Pokémon to switch to
        self.lastMoveUser = i.index
        if !pbOwnedByPlayer?(i.index)
          owner = pbGetOwner(i.index)
          pbDisplayBrief(_INTL("{1} withdrew {2}!", owner.fullname, getMonName(i.species, i.form)))
        else
          pbDisplayBrief(_INTL("{1}, that's enough!\nCome back!", i.name))
        end

        # Check for Pursuit
        pbCheckPursuit(i)
        return if @decision > 0
        next if i.isFainted?

        pbRecallAndReplace(i.index, index)
      end
    end
    # Use items
    for i in priority
      next unless @choices[i.index][0] == :item

      if !pbOwnedByPlayer?(i.index) && !(pbOwnedByAIPartner?(i.index) && $game_switches[:Control_Partners])
        pbEnemyUseItem(@choices[i.index][1], i)
        i.itemUsed = true
        i.itemUsed2 = true
      else
        # Player use item
        item = @choices[i.index][1]
        pkmnIndex = @choices[i.index][2]
        if item
          i.itemUsed = true
          i.itemUsed2 = true
          next if ItemHandlers.hasUseInBattle(item) # Poke Balls, Poke Doll, Flutes (handled elsewhere)

          if ItemHandlers.hasBattleUseOnBattler(item) # X items, Dire Hit, Guard Spec
            pbUseItemOnBattler(item, i.index, i, @scene)
          else
            pbUseItemOnPokemon(item, pkmnIndex, i, @scene) unless pkmnIndex < 0
          end
        end
      end
      pbStatChangeChecks
      pbSendOutRevivedBattler(i, pkmnIndex)
    end
    # Mega Evolution / Ultra Burst / Terastallization
    megas = []
    for i in priority
      next if @choices[i.index][0] != :move

      side = pbIsOpposing?(i.index) ? 1 : 0
      owner = pbGetOwnerIndex(i.index)
      if @megaEvolution[side][owner] == i.index
        pbMegaEvolve(i.index)
        megas.push(i.index)
      end
      if @ultraBurst[side][owner] == i.index
        pbUltraBurst(i.index)
        megas.push(i.index)
      end
      if @terastal[side][owner] == i.index
        pbTerastallize(i.index)
        megas.push(i.index)
      end
    end

    # Reuni crest type switch
    for i in priority
      next if @choices[i.index][0] != :move || @choices[i.index][1] < 0
      next if i.crested != :REUNICLUS

      protypes = [i.moves[@choices[i.index][1]].pbIsPhysical?(i), i.moves[@choices[i.index][1]].pbIsSpecial?(i)]
      if protypes[0] == true || protypes[1] == true
        protype = :FIGHTING if protypes[0] == true
        protype = :PSYCHIC if protypes[1] == true
        if i.types(excludeReflector: true) != [protype]
          i.changeType(protype)
          i.pbUpdate(false) if i.species == :REUNICLUS
          msg = _INTL("{1} transformed into the {2} type!", i.pbThis, getTypeName(protype))
          pbAbilityBoxAndDisplay(i, msg, item: true)
        end
      end
    end
    # Goth crest type switch
    for i in priority
      next if @choices[i.index][0] != :move || @choices[i.index][1] < 0
      next if i.crested != :GOTHITELLE

      protype = i.moves[@choices[i.index][1]].type
      next unless [:PSYCHIC, :DARK].include?(protype)

      if i.types(excludeReflector: true) != [protype]
        i.changeType(protype)
        msg = _INTL("{1} transformed into the {2} type!", i.pbThis, getTypeName(protype))
        pbAbilityBoxAndDisplay(i, msg, item: true)
      end
    end
    setActPrioData
    setMovePrioData
    setSpeedData(megas) # Update speed data -only- for mons that mega evolved this turn
    priority = setSpeedOrder(calcSpeedData: false)

    # Antiwoke password sleep forcing
    if $game_switches[:AntiWoke_Password]
      uproaractive = @battlers.any? { |i| i.effects[:Uproar] > 0 }
      for i in 0...4
        if pbOwnedByPlayer?(i) && !@battlers[i].isFainted?
          if @battlers[i].status != :SLEEP && @battlers[i].ability != :COMATOSE && !uproaractive
            @battlers[i].pbSleep
          end
          if @battlers[i].status == :SLEEP
            @battlers[i].statusCount = 5
          end
        end
      end
    end

    # move animations before main move processing
    for i in priority
      if pbChoseMoveFunctionCode?(i.index, 0x115) # Focus Punch
        pbCommonAnimation("FocusPunch", i, nil)
        pbDisplay(_INTL("{1} is tightening its focus!", i.pbThis))
      elsif pbChoseMoveFunctionCode?(i.index, 0x15D) # Beak Blast
        pbCommonAnimation("BeakBlast", i, nil)
        i.effects[:BeakBlast] = true
        pbDisplay(_INTL("{1} started heating up its beak!", i.pbThis))
      elsif pbChoseMoveFunctionCode?(i.index, 0x16B) # Shell Trap
        pbCommonAnimation("ShellTrap", i, nil)
        i.effects[:ShellTrap] = true
        pbDisplay(_INTL("{1} set a shell trap!", i.pbThis))
      end
    end


    # Use attacks
    loop do
      setMoveOrder
      specialmoveusers = getSpecialMoveUsers(priority)
      break if @moveOrder.empty? && specialmoveusers.all? {|mon| mon.specialMoveUsed == true}


      battler = @moveOrder.first
      for i in specialmoveusers
        if battler
          attacking = @choices[battler.index][0] == :move ? true : false
          if attacking
            if ((@specialchoices[i.index][2].priorityCheck(i) > @choices[battler.index][2].priorityCheck(battler)) || (@specialchoices[i.index][4].pbSpeed > battler.pbSpeed && (@specialchoices[i.index][2].priorityCheck(i) >= @choices[battler.index][2].priorityCheck(battler)))) && i.specialMoveUsed == false
              i.pbProcessTurn(@specialchoices[i.index])
              i.specialMoveUsed = true
              next
            end
          end
        else
          if i.specialMoveUsed == false
            i.pbProcessTurn(@specialchoices[i.index])
            i.specialMoveUsed = true
            next
          end
        end
      end
      break if !battler


      v = battler.pbProcessTurn(@choices[battler.index])
      PBDebug.dblog("") if v

      if @state.effects[:Round]
        for j in 1...@moveOrder.length
          b = @moveOrder[j]
          if !b.hasMovedThisRound? && @choices[b.index][0] == :move && @choices[b.index][2].move == :ROUND
            pbMoveAfter(b)
            break
          end
        end
      end

      # Shell Trap
      for ii in 0...4
        if @battlers[ii].effects[:ShellTrap] && @battlers[ii].effects[:ShellTrapAttacked]
          @battlers[ii].effects[:ShellTrap] = false
          if pbChoseMoveFunctionCode?(ii, 0x16B)
            pbMoveAfter(@battlers[ii])
          else # Via seed
            @battlers[ii].pbUseMoveSimple(:SHELLTRAP, -1, -1)
          end
        end
      end

      setSpeedData
      @moveOrder.shift

      return if @decision > 0
    end
  end

  # Send out second battler in doubles after using a Revive if a battler slot is free.
  def pbSendOutRevivedBattler(battler, pkmnIndex, reviveindex = 0, rejuvenation = false)
    return unless @doublebattle && ((@battle.pbGetOwner(battler.index) == @battle.pbGetOwner(battler.pbPartner.index)) || rejuvenation)  && battler.pbPartner.isFainted?
    return if @sosbattle == :singlePokemonPlayerSide
    return if pkmnIndex.nil? || (battler.pokemonIndex == pkmnIndex && reviveindex == 0)


    if reviveindex == 2
      mon = pbPartySingleOwner(reviveindex)[pkmnIndex]
    else
      mon = pbPartySingleOwner(battler.index)[pkmnIndex]
    end
    return if mon.nil? || mon.isEgg? || mon.hp <= 0

    @battle.pbMessagesOnReplace(battler.pbPartner.index, pkmnIndex)
    @battle.pbReplace(battler.pbPartner.index, pkmnIndex)
    @battle.pbApplyEntryEffects(battler.pbPartner)
  end

  def pbCheckPursuit(switcher)
    priority = setSpeedOrder
    for battler in priority
      next if !switcher.pbIsOpposing?(battler.index) # Allies don't trigger Pursuit
      next if battler.hasMovedThisRound? || @moveOrder.first == battler
      next unless pbChoseMoveFunctionCode?(battler.index, 0x88) # If Pursuit was chosen, regardless of target

      if switcher.vanished
        switcher.vanished = false
        pbCommonAnimation("Fade in", switcher, nil)
      end

      pbPursuitInterrupt(battler, switcher)
      break if switcher.isFainted?
    end
  end

  def pbPursuitInterrupt(pursuiter, switcher)
    return if pursuiter.status == :SLEEP || pursuiter.status == :FROZEN || pursuiter.effects[:Truant]

    # Try to Mega-evolve/Ultra-burst before using pursuit
    side = pbIsOpposing?(pursuiter.index) ? 1 : 0
    owner = pbGetOwnerIndex(pursuiter.index)
    if @megaEvolution[side][owner] == pursuiter.index
      pbMegaEvolve(pursuiter.index)
    end
    if @ultraBurst[side][owner] == pursuiter.index
      pbUltraBurst(pursuiter.index)
    end
    if @terastal[side][owner] == pursuiter.index
      pbTerastallize(pursuiter.index)
    end
    # Goth crest type switch
    if pursuiter.crested == :GOTHITELLE && pursuiter.moves[@choices[pursuiter.index][1]].type == :DARK
      protype = :DARK
      if pursuiter.types(excludeReflector: true) != [protype]
        pursuiter.changeType(protype)
        msg = _INTL("{1} had its type changed to {2}!", pursuiter.pbThis, getTypeName(protype))
        pbAbilityBoxAndDisplay(pursuiter, msg, item: true)
      end
    end
    # Change target to switcher and then use pursuit on it
    @choices[pursuiter.index][3] = switcher.index
    pursuiter.effects[:Pursuiter] = true # Reset in pbProcessTurn when the pursuiter would normally have its turn
    switcher.effects[:Pursuitee] = true # Reset when the switch is resolved
    pursuiter.pbUseMove(@choices[pursuiter.index])
  end

  ################################################################################
  # End of round.
  ################################################################################
  def pbEndOfRoundPhase(skipcelebi = false)
    if @echoedThisRound
      @echoedVoice = [@echoedVoice + 1, 4].min
      @echoedThisRound = false
    else
      @echoedVoice = 0
    end

    priority = setSpeedOrder
    for battler in priority
      if battler.effects[:ShellTrap] && !pbChoseMoveFunctionCode?(battler.index, 0x16B) && !battler.effects[:ShellTrapAttacked]
        pbDisplay(_INTL("{1}'s shell trap didn't work!", battler.name))
      end
    end
    for i in @battlers
      i.forcedSwitchEarlier = false
      next if i.hp <= 0

      i.damagestate.reset
      i.endTurn = false
      i.specialMoveUsed = false
      i.effects[:Protect] = nil
      i.effects[:HyperBeam] -= 1 if i.effects[:HyperBeam] > 0
      i.effects[:BeakBlast] = false
      i.effects[:ShellTrap] = false
      i.effects[:ShellTrapAttacked] = false
      if [:BURNING, :VOLCANIC, :INFERNAL].include?(@field.effect) && i.effects[:BurnUp]
        i.type1 = i.pokemon.type1
        i.type2 = i.pokemon.type2
        i.effects[:BurnUp] = false
      end
      i.effects[:Powder] = false
      i.effects[:MeFirst] = false
      i.effects[:Jealousy] = false
      i.effects[:LashOut] = false
      i.effects[:HelpingHand] = 0
      i.effects[:MagicCoat] = false
      i.effects[:QuickDrawSnipe] = false
      i.effects[:UseCharge] = false
      i.effects[:ThroatChop] -= 1 if i.effects[:ThroatChop] > 0
      i.itemUsed = false
      i.shieldsBrokenThisTurn = [0, 0, 0, 0] if i.isbossmon
    end
    @state.effects[:IonDeluge] = false
    @state.effects[:Round] = false
    for i in @sides
      i.resetProtect
    end

    # End-turn resolution order, modified for Rebornverse engine
    # https://www.smogon.com/forums/threads/sword-shield-battle-mechanics-research.3655528/post-9244179
    # https://github.com/smogon/pokemon-showdown

    # Storm-9
    storm_9 = pbFindGlobalAbilityUser(:TEMPEST)
    if storm_9
      weather = sample([:RAINDANCE, :HAIL, :SANDSTORM, :STRONGWINDS, :SHADOWSKY] - [@weather])
      case weather
        when :RAINDANCE then message = _INTL("Storm-9 created a downpour!")
        when :HAIL then message = _INTL("Storm-9 brought hailfall!")
        when :SANDSTORM then message = _INTL("Storm-9 whipped up a duststorm!")
        when :STRONGWINDS then message = _INTL("Storm-9 whipped up terrible winds!")
        when :SHADOWSKY then message = _INTL("Storm-9 shrouded the sky in a shadowy aura...")
      end
      pbShowAbilityBox(storm_9)
      pbSetWeather(weather, 8, message)
      pbHideAbilityBox(storm_9)
    end

    # Weather ending
    if @weather != 0
      @weatherduration = @weatherduration - 1 if @weatherduration > 0
      pbEndWeather(endOfRound: true) if @weatherduration == 0
    end

    # Weather effects
    case @weather
      when :SUNNYDAY
        pbCommonAnimation("Sunny")
        if @field.effect == :DARKCRYSTALCAVERN
          duration = @weatherduration + 1
          message = _INTL("The sun lit up the crystal cavern!")
          setField(:CRYSTALCAVERN, duration, message, ignoreOverlays: true) # temporary field transition, never should be an overlay, failsafe implementation
          @field.duration_condition = proc { |battle| battle.weather == :SUNNYDAY }
          @field.permanent_condition = proc { |battle| battle.FE != :CRYSTALCAVERN }
        end
      when :RAINDANCE
        pbCommonAnimation("Rain")
        if @field.effect == :BURNING
          breakField(_INTL("The rain snuffed out the flame!"))
        end
        if @field.effect == :VOLCANIC
          message = _INTL("The rain snuffed out the flame!")
          setField(:CAVE, 0, message)
        end
      when :SANDSTORM
        pbCommonAnimation("Sandstorm")
        if @field.effect == :BURNING
          breakField(_INTL("The sand snuffed out the flame!"))
        end
        if @field.effect == :VOLCANIC
          message = _INTL("The sand snuffed out the flame!")
          setField(:CAVE, 0, message)
        end
        if @field.effect == :RAINBOW
          breakField(_INTL("The weather blocked out the rainbow!"))
        end
      when :HAIL, :SNOW
        pbCommonAnimation("Hail")
        if @field.effect == :RAINBOW
          breakField(_INTL("The weather blocked out the rainbow!"))
        end
        if @field.effect == :MOUNTAIN
          @field.counter += 1
          if @field.counter == 3
            message = _INTL("The mountain was covered in snow!")
            setField(:SNOWYMOUNTAIN, 0, message)
          end
        end
      when :STRONGWINDS
        pbCommonAnimation("Wind")
      when :SHADOWSKY
        pbCommonAnimation("SHADOWSKY")
    end

    priority = setSpeedOrder
    activeweather = pbWeather(nil)
    if activeweather == :SUNNYDAY
      for i in priority
        next if i.isFainted?
        next if i.hasWorkingItem(:UTILITYUMBRELLA)

        # Solar Power / Castform Crest
        if (i.ability == :SOLARPOWER || (i.crested == :CASTFORM && i.form == 1)) && @field.effect != :FROZENDIMENSION
          pbShowAbilityBox(i, item: i.crested == :CASTFORM)
          i.pbReduceHP((i.totalhp / 8.0).floor, true, message: _INTL("{1} was hurt by the sunlight!", i.pbThis))
          pbHideAbilityBox(i)
          i.pbFaint if i.isFainted?
        end
        next if i.isFainted?

        # Dry Skin
        if i.ability == :DRYSKIN
          pbShowAbilityBox(i)
          i.pbReduceHP((i.totalhp / 8.0).floor, true, message: _INTL("{1} was hurt by the sunlight!", i.pbThis))
          pbHideAbilityBox(i)
          i.pbFaint if i.isFainted?
        end
        next if i.isFainted?

        # Desert Grass/Water-type
        if Rejuv && @field.effect == :DESERT && (i.hasType?(:GRASS) || i.hasType?(:WATER)) && ![:SOLARPOWER, :CHLOROPHYLL, :MEGASOL].include?(i.ability)
          i.pbReduceHP((i.totalhp / 8.0).floor, true, message: _INTL("{1} was hurt by the sunlight!", i.pbThis))
          i.pbFaint if i.isFainted?
        end
        next if i.isFainted?

        # Druddigon Crest
        if i.crested == :DRUDDIGON && i.canHeal?
          pbShowAbilityBox(i, item: true)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true)
          pbHideAbilityBox(i)
        end
      end
    end

    for i in priority
      next if i.isFainted?
      # Sunflora Crest
      if i.crested == :SUNFLORA && i.canHeal?
        pbShowAbilityBox(i, item: true)
        i.pbRecoverHP((i.totalhp / 10.0).floor, true, message: _INTL("{1} was healed a little by the sunlight!", i.pbThis))
        pbHideAbilityBox(i)
      end
    end

    if activeweather == :RAINDANCE
      for i in priority
        next if i.isFainted?
        next if i.hasWorkingItem(:UTILITYUMBRELLA)

        # Dry Skin
        if i.ability == :DRYSKIN && i.canHeal?
          pbShowAbilityBox(i)
          i.pbRecoverHP((i.totalhp / 8.0).floor, true, message: _INTL("{1} was healed by the rain!", i.pbThis))
          pbHideAbilityBox(i)
        end

        # Rain Dish / Castform Crest
        if (i.ability == :RAINDISH || (i.crested == :CASTFORM && i.form == 2)) && i.canHeal?
          pbShowAbilityBox(i, item: i.crested == :CASTFORM)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} was healed a little by the rain!", i.pbThis))
          pbHideAbilityBox(i)
        end

        # Clouds Volt Absorb
        if i.ability == :VOLTABSORB && @field.effect == :CLOUDS && i.canHeal?
          pbShowAbilityBox(i)
          i.pbRecoverHP((i.totalhp / 12.0).floor, true, message: _INTL("{1}'s {2} restored its health!", i.pbThis, getAbilityName(i.ability)))
          pbHideAbilityBox(i)
        end
      end
    end

    if activeweather == :SANDSTORM
      endmessage = false
      mons = []
      reductions = []
      for i in priority
        next if i.isFainted?
        next if !i.takesWeatherDamage?
        next if $cache.moves[i.effects[:TwoTurnAttack]] && [0xCA, 0xCB].include?($cache.moves[i.effects[:TwoTurnAttack]].function) # Dig, Dive

        pbDisplay(_INTL("The Pokémon were buffeted by the sandstorm!")) if !endmessage
        endmessage = true
        @scene.pbDamageAnimation(i, 0, quick: true)
        mons.push(i)
        divisor = Rejuv && @field.effect == :DESERT ? 8.0 : 16.0
        reductions.push((i.totalhp / divisor).floor)
      end
      pbReduceBattlersHP(mons, reductions)
    end

    if activeweather == :HAIL
      endmessage = false
      mons = []
      reductions = []
      for i in priority
        next if i.isFainted?
        next if !i.takesWeatherDamage?
        next if $cache.moves[i.effects[:TwoTurnAttack]] && [0xCA, 0xCB].include?($cache.moves[i.effects[:TwoTurnAttack]].function) # Dig, Dive

        pbDisplay(_INTL("The Pokémon were buffeted by the hail!")) if !endmessage
        endmessage = true
        @scene.pbDamageAnimation(i, 0, quick: true)
        mons.push(i)
        divisor = @field.effect == :FROZENDIMENSION ? 8.0 : 16.0
        reductions.push((i.totalhp / divisor).floor)
      end
      pbReduceBattlersHP(mons, reductions)
    end

    snowfall = [:HAIL, :SNOW].include?(activeweather)
    for i in priority
      next if i.isFainted?

      # Ice Body
      if i.ability == :ICEBODY && (snowfall || i.crested == :GLACEON) && i.canHeal?
        if snowfall
          pbShowAbilityBox(i)
          source = activeweather == :SNOW ? _INTL("snow") : _INTL("hail")
          i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} was healed a little by the {2}!", i.pbThis, source))
        else
          pbShowAbilityBox(i, item: true)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true)
        end
        pbHideAbilityBox(i)
      end
    end

    if activeweather == :SHADOWSKY
      endmessage = false
      mons = []
      reductions = []
      for i in priority
        next if i.isFainted?
        next if !i.takesWeatherDamage?
        next if $cache.moves[i.effects[:TwoTurnAttack]] && [0xCA, 0xCB].include?($cache.moves[i.effects[:TwoTurnAttack]].function) # Dig, Dive

        pbDisplay(_INTL("The Pokémon were struck by bursts of light!")) if !endmessage
        endmessage = true
        @scene.pbDamageAnimation(i, 0, quick: true)
        mons.push(i)
        divisor = [:DIMENSIONAL, :FROZENDIMENSION].include?(@field.effect) ? 8.0 : 16.0
        reductions.push((i.totalhp / divisor).floor)
      end
      pbReduceBattlersHP(mons, reductions)
    end

    # Ability switch checkpoint
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      i.carryOutUserSwitch if [:Ability, :BossEffect, :TrainerEffect].include?(i.userSwitch)
    end

    # Temporal Shift
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      if i.ability == :TEMPORALSHIFT
        for j in priority
          next if j.isFainted?

          if !(i == j || i.pbPartner == j || j.hasType?(:NORMAL)) && j.effects[:FutureSight] == 0
            j.effects[:FutureSight] = 3
            j.effects[:FutureSightMove] = :FutureHex
            j.effects[:FutureSightUserIndex] = i.index
            j.effects[:FutureSightPokemon] = i.pokemon
            pbAbilityBoxAndDisplay(i, _INTL("{1} casts a hex!", i.pbThis))
            break
          end
        end
      end
    end
    # Future Sight/Doom Desire
    eachBattler do |i| # not speed order
      next if i.effects[:FutureSight] <= 0

      i.effects[:FutureSight] -= 1
      next if i.effects[:FutureSight] != 0
      next if i.isFainted?

      move, moveuser, disabled_items = i.pbFutureSightUserPlusMove
      next if moveuser.pokemon == i.pokemon

      userOnField = @battlers.include?(moveuser) # check if battler on the field
      pbDisplay(_INTL("{1} took the {2} attack!", i.pbThis, move.name))
      flags = { totaldamage: 0, UserFaintCause: [], AttackerOffField: !userOnField, FutureSight: true }
      successflag = moveuser.pbSuccessCheck(move, [i], flags, true).first
      if successflag != :Success
        moveuser.moveFailureEffects(moveuser, move, i, successflag)
        successflag = :Success if successflag == :MirrorMissReflect
      end
      if successflag == :Success
        i.moveDamageStateInit(i, move)
        preMoveHP = i.hp
        feedbackMessages = {
          i.index => [],
        }
        damage = move.pbCalcDamage(moveuser, i, 0, feedbackMessages) # return value is an int
        revanish = false
        if i.vanished
          revanish = true
          @battle.scene.pbUnVanishSprite(i)
        end
        move.damageCalcMessages(moveuser, feedbackMessages)
        userOnField ? pbAnimation(move.move, moveuser, i) : pbAnimation(move.move, i, i)

        damage, bossbreaks = move.pbReduceHPDamage(moveuser, [i], [damage]) # return value is an array!
        flags[:totaldamage] += damage.first
        move.pbOnDamageLost(damage.first, moveuser, i, bossbreaks)
        move.pbEffectMessages(moveuser, i)
        move.damageCalcMessages(moveuser, feedbackMessages, late: true)
        moveuser.pbResolveMoveEffects(moveuser, move, [i], damage, [successflag], 0, flags)
        if revanish && !i.isFainted?
          pbCommonAnimation("Fade out", i, nil)
          @scene.pbVanishSprite(i)
        end
        targetFainted = false
        # future sight user only needs to be fainted from retaliation damage if the original user is still on the field
        if moveuser.isFainted? && userOnField
          moveuser.pbFaint
          if @recorded || @field.effect == :CROWD
            for target in flags[:UserFaintCause]
              $game_variables[:BattleDataArray].last().pokemonFaintedAnEnemy(@battlers, target, moveuser, move)
            end
          end
        end
        if i.isFainted?
          i.pbFaint
          targetFainted = true
          if @recorded || @field.effect == :CROWD
            $game_variables[:BattleDataArray].last().pokemonFaintedAnEnemy(@battlers, moveuser, i, move)
          end
        end
        move.pbEffectAfterMove(moveuser, [i], [successflag]) # future proofing in case there is ever an effect like this attached to a future sight move
        unless i.isFainted? || i.damagestate.substitute
          i.pbTargetEffectsDamaged(moveuser, move, preMoveHP, true)
        end
        i.pbBerryHerbCheck
        i.pbEmergencyExitCheck(preMoveHP) unless i.damagestate.substitute
        moveuser.pbOnKillEffects([i], move, flags) if targetFainted
        # Life Orb
        if !moveuser.isFainted? && (moveuser.ability != :SHEERFORCE || move.effect == 0)
          if moveuser.hasWorkingItem(:LIFEORB) && successflag == :Success && !magicGuardAbilities.include?(moveuser.ability)
            pbShowAbilityBox(moveuser, item: true)
            moveuser.pbReduceHP((moveuser.totalhp / 10.0).floor, true, message: _INTL("{1} lost some of its HP!", moveuser.pbThis))
            pbHideAbilityBox(moveuser)
            moveuser.pbFaint if moveuser.isFainted?
          end
        end
      end
      i.effects[:FutureSightMove] = nil
      i.effects[:FutureSightUserIndex] = -1
      i.effects[:FutureSightPokemon] = nil
      if !disabled_items.empty?
        moveuser.item = disabled_items[:item]
        moveuser.ability = disabled_items[:ability]
      end
    end

    # Boss Charge Attack
    priority = setSpeedOrder
    for i in priority
      next if !i.isbossmon
      next if i.isFainted?

      if i.chargeAttack
        next if i.status == :SLEEP || i.status == :FROZEN
        next if !i.chargeAttackRequirementMet?
        chargeAttack = i.chargeAttack
        if chargeAttack[:turns] - i.permeffs[:ChargeAttackCountdown] == 0
          if i.chargeTurns? == false && chargeAttack[:turns] - i.permeffs[:ChargeAttackCountdown] == 0
            for m in allMons(@party1)
              m.status = :FAINTED
              m.hp = 0
            end
            if chargeAttack[:chargeAttackMessage]
              pbDisplay(_INTL("{1}", chargeAttack[:chargeAttackMessage]))
              if chargeAttack[:chargeAttackAnimation]
                if !i.pbOpposing1.isFainted?
                  target = i.pbOpposing1
                else
                  if !i.pbOpposing2.isFainted?
                    target = i.pbOpposing2
                  else
                    target = i
                  end
                end
                pbAnimation(chargeAttack[:chargeAttackAnimation], i, i)
                pbAnimation(chargeAttack[:chargeAttackAnimation], target, target)
              end
            else
              pbDisplay(_INTL("{1} unleashed its power!", i.pbThis))
              pbAnimation(:EXPLOSION, i, i)
            end
            for j in priority
              next if j.isFainted?
              next if j.isbossmon

              j.pbReduceHP(j.hp, true)
              j.pbFaint if j.isFainted?
            end
            @decision = 2
            return
          end
        else
          if chargeAttack[:intermediateattack]
            if chargeAttack[:canIntermediateAttack] == true
              newmove = PokeBattle_BossMove.new(self, i.pokemon, chargeAttack[:intermediateattack])
              i.pbUseMoveSimple(newmove, -1, -1)
            else
              chargeAttack[:canIntermediateAttack] = true
            end
          end
        end
      end
    end

    # Rejuv Life Blood
    if Rejuv
      pbLifeBlood
    end

    # Wish
    priority = setSpeedOrder
    for i in priority
      if i.effects[:Wish] > 0
        i.effects[:Wish] -= 1
        if i.effects[:Wish] == 0
          next if i.isFainted?

          if !i.canHeal?
            @battle.pbDisplay(_INTL("{1} was prevented from healing!", i.pbThis)) if i.hp != i.totalhp
            next
          end

          wishmaker = pbThisEx(i.index, i.effects[:WishMaker])
          i.pbRecoverHP(i.effects[:WishAmount], true, message: _INTL("{1}'s wish came true!", wishmaker))
        end
      end
    end

    if Rejuv
      currentJurisdiction = currentJurisdiction?
      priority = setSpeedOrder
      turncount = @turncount
      endmessage = false
      for i in priority
        case currentJurisdiction
        when :NEVED
          next if pbBelongsToPlayer?(i.index)
          next if !@doublebattle && i.index > 1
          pbShowAbilityBox(i, attrname: _INTL("Neved's Jurisdiction"))
          pbDisplay(_INTL("The S.S. Bridgette's cannons are aiming!")) if !endmessage
          mons, reductions = [], []
          for j in priority
            next if j.isFainted?
            next if !j.pbIsOpposing?(i.index)
            if [:BULLETPROOF, :MAGICGUARD, :SHELLARMOR, :BATTLEARMOR].include?(j.ability)
              pbDisplay(_INTL("{1}'s {2} made it immune to the cannonfire!", j.pbThis, getAbilityName(j.ability))) if !endmessage
              next
            end

            pbDisplay(_INTL("The Pokémon were hit by the cannon barrage!")) if !endmessage
            endmessage = true
            @scene.pbDamageAnimation(j, 0, quick: true)
            mons.push(j)
            damagecount = 1/128.0
            damagecount = [damagecount * ((1.5 ** turncount).floor), 1/4.0].min
            reductions.push((j.totalhp * damagecount).floor)
          end
          pbReduceBattlersHP(mons, reductions)
          pbHideAbilityBox(i)
        end
      end
    end

    # Field Effects
    # Grassy Terrain is grouped with item healing effects (Black Sludge / Leftovers) in canon,
    # but we separate them to allow for better end-of-round effect messaging
    priority = setSpeedOrder
    # eruption check - insane, too much, but makes typh op, so i no question
    eruptionChecker if @field.effect == :VOLCANICTOP && @weather == :SUNNYDAY && @state.effects[:HarshSunlight]
    endmessage = false
    swampspeedsink = false
    consecratedspeeddrop = false
    for i in priority
      next if i.isFainted?

      if [:ELECTERRAIN, :SHORTCIRCUIT].include?(@field.effect)
        if i.ability == :VOLTABSORB && i.canHeal? && (@field.effect == :SHORTCIRCUIT || Rejuv)
          pbShowAbilityBox(i)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} absorbed stray electricity!", i.pbThis))
          pbHideAbilityBox(i)
        end
      end

      if @field.effect == :ELECTERRAIN
        if i.turncount > 0 && i.ability == :MOTORDRIVE
          if i.pbCanIncreaseStatStage?(PBStats::SPEED, i, nil)
            pbShowAbilityBox(i)
            i.pbChangeStats(PBStats::SPEED, 1, i, nil, abilitycheck: :skip)
            pbHideAbilityBox(i)
          end
        end
      end

      if @field.effect == :GRASSY
        if !i.isAirborne? && !i.isSemiInvul? && i.canHeal?
          pbDisplay(_INTL("The grass healed the Pokémon on the battlefield.")) if !endmessage
          endmessage = true
          i.pbRecoverHP((i.totalhp / 16.0).floor, true)
        end
        if i.ability == :SAPSIPPER && i.canHeal?
          pbShowAbilityBox(i)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} ate some grass to recover!", i.pbThis))
          pbHideAbilityBox(i)
        end
      end

      if @field.effect == :MISTY
        if i.ability == :DRYSKIN && i.canHeal?
          pbShowAbilityBox(i)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} was healed a little by the mist!", i.pbThis))
          pbHideAbilityBox(i)
        end
      end
      if [:VOLCANIC, :INFERNAL, :ROCKY, :CAVE, :VOLCANICTOP].include?(@field.effect) &&  i.ability == :COALFURNACE
        if i.ability == :COALFURNACE
          if !i.effects[:CoalFurnace]
            i.effects[:CoalFurnace] = true
            pbAbilityBoxAndDisplay(i, _INTL("The power of {1}'s Fire-type moves rose!", i.pbThis(true)))
          end
        end
        if i.pbCanIncreaseStatStage?(PBStats::SPEED, i, nil)
          pbShowAbilityBox(i)
          i.pbChangeStats(PBStats::SPEED, 1, i, nil, abilitycheck: :skip)
          pbHideAbilityBox(i)
        end
      end
      if [:BURNING, :VOLCANIC, :INFERNAL].include?(@field.effect)
        if i.ability == :FLASHFIRE
          if !i.effects[:FlashFire]
            i.effects[:FlashFire] = true
            pbAbilityBoxAndDisplay(i, _INTL("The power of {1}'s Fire-type moves rose!", i.pbThis(true)))
          end
        end
        if i.burningFieldPassiveDamage?
          if i.ability == :WELLBAKEDBODY
            if i.pbCanIncreaseStatStage?(PBStats::DEFENSE, i, nil)
              pbShowAbilityBox(i)
              i.pbChangeStats(PBStats::DEFENSE, 1, i, nil, abilitycheck: :skip)
              pbHideAbilityBox(i)
            end
          else
            eff = PBTypes.typesEff(:FIRE, i.types, inverse: inverse?)
            mult = eff.multiplier
            mult *= 2 if [:LEAFGUARD, :ICEBODY, :FLUFFY, :GRASSPELT].include?(i.ability)
            mult *= 2 if i.effects[:TarShot]
            pbDisplay(_INTL("The Pokémon were burned by the field!")) if !endmessage
            endmessage = true
            i.pbReduceHP((i.totalhp / 8.0 * mult).floor, true)
            i.pbFaint if i.isFainted?
            next if i.isFainted?
            if i.ability == :THERMALEXCHANGE
              if i.pbCanIncreaseStatStage?(PBStats::ATTACK, i, nil)
                pbShowAbilityBox(i)
                i.pbChangeStats(PBStats::ATTACK, 1, i, nil, abilitycheck: :skip)
                pbHideAbilityBox(i)
              end
            end
          end
        end
      end

      if @field.effect == :SWAMP
        if !i.hasWorkingItem(:HEAVYDUTYBOOTS) && !i.hasWorkingItem(:CLEARAMULET) && !i.isAirborne? &&
            ![:WHITESMOKE, :CLEARBODY, :QUICKFEET, :SWIFTSWIM, :PROPELLERTAIL].include?(i.ability)
          amount = -1
          amount = -2 if i.effects[:MultiTurn] > 0 && Rejuv
          swampspeedsink = true if i.pbChangeStats(PBStats::SPEED, amount, nil, nil, statmessage: :none)
        end
        if i.ability == :DRYSKIN && i.canHeal?
          pbShowAbilityBox(i)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} was healed a little by the murk!", i.pbThis))
          pbHideAbilityBox(i)
        end
        if Rejuv && i.effects[:SwampWeb] >= 0
          statdropper = @battlers[i.effects[:SwampWeb]]
          stat = sample(PBStats::Omni)
          i.pbChangeStats(stat, -1, statdropper, nil)
        end
      end

      if @field.effect == :RAINBOW
        if i.ability == :CLOUDNINE
          incstats = []
          for stat in PBStats::All
            incstats.push(stat) if i.pbCanIncreaseStatStage?(stat, i, nil)
          end
          if !incstats.empty?
            pbShowAbilityBox(i)
            incstat = @battle.sample(incstats)
            i.pbChangeStats(incstat, 1, i, nil, abilitycheck: :skip)
            pbHideAbilityBox(i)
          end
        end
      end

      if @field.effect == :DEUXFINALIS # Deux Finalis Field
        if i.status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, i).none?
          amount = -1
          consecratedspeeddrop = true if i.pbChangeStats(PBStats::SPEED, amount, i, nil, statmessage: :none)
        end
      end

      if @field.effect == :CORROSIVE
        if i.ability == :GRASSPELT
          pbShowAbilityBox(i)
          i.pbReduceHP((i.totalhp / 8.0).floor, true, message: _INTL("{1}'s pelt is withering!", i.pbThis))
          pbHideAbilityBox(i)
          i.pbFaint if i.isFainted?
        end
      end

      if @field.effect == :CORROSIVEMIST
        if i.pbCanPoison?(nil, nil) && !@battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS)
          pbDisplay(_INTL("The Pokémon were poisoned by the corrosive mist!")) if !endmessage
          endmessage = true
          i.pbPoison(i, message: false)
        end
      end

      if [:CORROSIVEMIST, :CORRUPTED].include?(@field.effect)
        if i.ability == :DRYSKIN && !i.hasType?(:STEEL)
          if !i.hasType?(:POISON)
            pbShowAbilityBox(i)
            pbCommonAnimation("Poison", i, nil)
            i.pbReduceHP((i.totalhp / 8.0).floor, message: _INTL("{1} absorbed the poison!", i.pbThis))
            pbHideAbilityBox(i)
            i.pbFaint if i.isFainted?
          elsif i.canHeal?
            pbShowAbilityBox(i)
            pbCommonAnimation("Poison", i, nil)
            i.pbRecoverHP((i.totalhp / 8.0).floor, message: _INTL("{1} was healed by the poison!", i.pbThis))
            pbHideAbilityBox(i)
          end
        end
      end

      if @field.effect == :DESERT
        if i.ability == :EARTHEATER && i.canHeal?
          pbShowAbilityBox(i)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} ate sand to recover!", i.pbThis))
          pbHideAbilityBox(i)
        end
        if i.ability == :DRYSKIN
          pbShowAbilityBox(i)
          i.pbReduceHP((i.totalhp / 8.0).floor, true, message: _INTL("{1} was hurt by the desert air!", i.pbThis))
          pbHideAbilityBox(i)
          i.pbFaint if i.isFainted?
        end
      end

      if [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION].include?(@field.effect)
        if (i.ability == :ICEBODY) && i.canHeal?
          pbShowAbilityBox(i)
          source = @field.effect == :SNOWYMOUNTAIN ? _INTL("snow") : _INTL("ice")
          i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} was healed a little by the {2}!", i.pbThis, source))
          pbHideAbilityBox(i)
        end
      end

      if @field.effect == :FOREST
        if i.ability == :SAPSIPPER && i.canHeal?
          pbShowAbilityBox(i)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} drank tree sap to recover!", i.pbThis))
          pbHideAbilityBox(i)
        end
      end

      if @field.effect == :VOLCANICTOP && @eruption
        if i.hasType?(:FIRE) || i.effects[:AquaRing] || i.pbOwnSide.effects[:WideGuard] || i.pbOwnSide.effects[:AreniteWall] > 0
          pbDisplay(_INTL("{1} is immune to the eruption!", i.pbThis))
        elsif [:MAGMAARMOR, :FLASHFIRE, :FLAREBOOST, :BLAZE, :FLAMEBODY, :SOLIDROCK, :STURDY, :BATTLEARMOR, :SHELLARMOR, :WATERBUBBLE, :MAGICGUARD, :WONDERGUARD, :PRISMARMOR].include?(i.ability)
          pbShowAbilityBox(i)
          pbDisplay(_INTL("{1} is immune to the eruption!", i.pbThis))
        else
          mult = PBTypes.typesEff(:FIRE, i.types, inverse: inverse?).multiplier
          mult /= 2 if i.ability == :THICKFAT
          mult *= 2 if i.effects[:TarShot]
          i.pbReduceHP((i.totalhp / 8.0 * mult).floor, true, message: _INTL("{1} is hurt by the eruption!", i.pbThis))
          i.pbFaint if i.isFainted?
          next if i.isFainted?
        end
        if i.ability == :MAGMAARMOR
          if i.pbCanIncreaseAnyStat?(PBStats::Defensive, i, nil)
            pbShowAbilityBox(i)
            i.pbChangeStats(PBStats::Defensive, 1, i, nil, abilitycheck: :hide)
          end
        end
        if i.ability == :FLAREBOOST
          if i.pbCanIncreaseStatStage?(PBStats::SPATK, i, nil)
            pbShowAbilityBox(i)
            i.pbChangeStats(PBStats::SPATK, 1, i, nil, abilitycheck: :skip)
          end
        end
        if i.ability == :FLASHFIRE
          if !i.effects[:FlashFire]
            i.effects[:FlashFire] = true
            pbShowAbilityBox(i)
            pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!", i.pbThis(true)))
          end
        end
        if i.ability == :BLAZE
          if !i.effects[:Blazed]
            i.effects[:Blazed] = true
            pbShowAbilityBox(i)
            pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!", i.pbThis(true)))
          end
        end
        if i.status == :SLEEP && i.ability != :SOUNDPROOF
          i.pbCureStatus
          pbDisplay(_INTL("{1} woke up due to the eruption!", i.pbThis))
        end
        if i.effects[:LeechSeed] >= 0
          i.effects[:LeechSeed] = -1
          pbDisplay(_INTL("{1}'s Leech Seed burned away in the eruption!", i.pbThis))
        end
        pbHideAbilityBox(i)
      end

      if [:WATERSURFACE, :UNDERWATER].include?(@field.effect)
        if [:WATERABSORB, :DRYSKIN].include?(i.ability) && i.canHeal? && (@field.effect == :UNDERWATER || !i.isAirborne?)
          pbShowAbilityBox(i)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} absorbed some of the water!", i.pbThis))
          pbHideAbilityBox(i)
        end
        if i.effects[:TarShot]
          i.effects[:TarShot] = false
          pbDisplay(_INTL("The tar washed off {1} in the water!", i.pbThis(true)))
        end
      end

      if [:HAUNTED, :DIMENSIONAL, :DEUXFINALIS, :INFERNAL].include?(@field.effect)
        if i.ability == :SOULEATER && i.canHeal?
          pbShowAbilityBox(i)
          i.pbRecoverHP((i.totalhp / 16.0).floor, true)
          pbDisplay(_INTL("{1} devoured spirits to recover!", i.pbThis))
          pbHideAbilityBox(i)
        end
      end

      if @field.effect == :UNDERWATER
        if i.underwaterFieldPassiveDamage?
          eff = PBTypes.typesEff(:WATER, i.types, inverse: inverse?)
          mult = eff.multiplier
          mult *= 2 if [:FLAMEBODY, :MAGMAARMOR].include?(i.ability)
          i.pbReduceHP((i.totalhp / 8.0 * mult).floor, true, message: _INTL("{1} struggled in the water!", i.pbThis))
          i.pbFaint if i.isFainted?
        end
      end

      if [:CRYSTALCAVERN, :NEWWORLD].include?(@field.effect)
        i.pbMimicry
      end

      if @field.effect == :MURKWATERSURFACE
        if i.hasType?(:POISON) && [:DRYSKIN, :WATERABSORB].include?(i.ability) && !i.isAirborne? && i.canHeal?
          pbShowAbilityBox(i)
          pbCommonAnimation("Poison", i, nil)
          i.pbRecoverHP((i.totalhp / 8.0).floor, message: _INTL("{1} is healed by the poisoned water!", i.pbThis))
          pbHideAbilityBox(i)
        end
        if i.murkyWaterSurfacePassiveDamage?
          mult = PBTypes.typesEff(:POISON, i.types, inverse: inverse?).multiplier
          mult *= 2 if [:FLAMEBODY, :MAGMAARMOR, :DRYSKIN, :WATERABSORB].include?(i.ability)
          if !$cache.moves[i.effects[:TwoTurnAttack]].nil? &&
              $cache.moves[i.effects[:TwoTurnAttack]].function == 0xCB # Dive
            i.pbReduceHP((i.totalhp / 2.0 * mult).floor, true, message: _INTL("{1} suffocated underneath the toxic water!", i.pbThis))
          elsif !i.isAirborne?
            pbDisplay(_INTL("The Pokémon are hurt by the toxic water!")) if !endmessage
            endmessage = true
            i.pbReduceHP((i.totalhp / 8.0 * mult).floor, true)
          end
        end
        i.pbFaint if i.isFainted?
      end

      if [:SWAMP, :WATERSURFACE, :UNDERWATER, :MURKWATERSURFACE].include?(@field.effect)
        if i.ability == :WATERCOMPACTION && (@field.effect == :UNDERWATER || !i.isAirborne?)
          if i.pbCanIncreaseStatStage?(PBStats::DEFENSE, i, nil)
            pbShowAbilityBox(i)
            i.pbChangeStats(PBStats::DEFENSE, 2, i, nil, abilitycheck: :skip)
            pbHideAbilityBox(i)
          end
        end
      end

      if [:MOUNTAIN, :SNOWYMOUNTAIN].include?(@field.effect)
        if pbWeather(nil) == :STRONGWINDS
          if i.ability == :WINDRIDER
            if i.pbCanIncreaseStatStage?(PBStats::ATTACK, i, nil)
              pbShowAbilityBox(i)
              i.pbChangeStats(PBStats::ATTACK, 1, i, nil, abilitycheck: :skip)
              pbHideAbilityBox(i)
            end
          end
          if i.ability == :WINDPOWER
            pbShowAbilityBox(i)
            i.effects[:Charge] = 2
            pbAnimation(:CHARGE, i, nil)
            pbDisplay(_INTL("The wind charged {1} with power!", i.pbThis(true)))
            pbHideAbilityBox(i)
          end
        end
      end

      if [:DESERT, :HAUNTED].include?(@field.effect)
        if i.ability == :WANDERINGSPIRIT
          if i.pbCanReduceStatStage?(PBStats::SPEED, i, nil)
            pbShowAbilityBox(i)
            i.pbChangeStats(PBStats::SPEED, -1, i, nil, abilitycheck: :skip)
            pbHideAbilityBox(i)
          end
        end
      end

      if @field.effect == :CORRUPTED
        if [:GRASSPELT, :LEAFGUARD, :FLOWERVEIL].include?(i.ability)
          pbShowAbilityBox(i)
          i.pbReduceHP((i.totalhp / 8.0).floor, true, message: _INTL("{1}'s foliage caused harm!", i.pbThis))
          pbHideAbilityBox(i)
          i.pbFaint if i.isFainted?
          next if i.isFainted?
        end
        if !i.isAirborne? && !i.hasType?(:POISON) && ![:WONDERSKIN, :IMMUNITY, :PASTELVEIL].include?(i.ability)
          if i.pbCanPoison?(nil, nil)
            pbDisplay(_INTL("The Pokémon were poisoned!")) if !endmessage
            endmessage = true
            i.pbPoison(i, message: false)
          end
        end
      end

      if @field.effect == :BEWITCHED
        if !i.isAirborne? && i.hasType?(:GRASS) && i.canHeal?
          pbDisplay(_INTL("The woods healed the {1}-type Pokémon on the battlefield.", getTypeName(:GRASS))) if !endmessage
          endmessage = true
          i.pbRecoverHP((i.totalhp / 16.0).floor, true)
        end
      end

      if @field.effect == :INFERNAL
        if i.effects[:Torment] == true && i.ability != :MAGICGUARD
          i.pbReduceHP((i.totalhp / 8.0).floor, true, message: _INTL("{1} is hurt by {2}!", i.pbThis, getMoveName(:TORMENT)))
          i.pbFaint if i.isFainted?
        end
      end

      if [:BURNING, :VOLCANIC, :VOLCANICTOP, :WATERSURFACE, :UNDERWATER, :INFERNAL].include?(@field.effect)
        if i.turncount > 0 &&  i.ability == :STEAMENGINE
          if i.pbCanIncreaseStatStage?(PBStats::SPEED, i, nil)
            pbShowAbilityBox(i)
            i.pbChangeStats(PBStats::SPEED, 1, i, nil, abilitycheck: :skip)
            pbHideAbilityBox(i)
          end
        end
      end
    end
    # Swamp speed drop message
    pbDisplay(_INTL("The Pokémon's Speed sank...")) if swampspeedsink || consecratedspeeddrop
    # Overlays
    priority = setSpeedOrder
    endmessage = false
    for i in priority
      next if i.isFainted?

      case @field.overlay
        when :ELECTERRAIN
          if i.ability == :VOLTABSORB && i.canHeal?
            pbShowAbilityBox(i)
            i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} absorbed stray electricity!", i.pbThis))
            pbHideAbilityBox(i)
          end
        when :GRASSY
          if !i.isAirborne? && !i.isSemiInvul? && i.canHeal?
            pbDisplay(_INTL("The grass healed the Pokémon on the battlefield.")) if !endmessage
            endmessage = true
            i.pbRecoverHP((i.totalhp / 16.0).floor, true)
          end
          if i.ability == :SAPSIPPER && i.canHeal?
            pbShowAbilityBox(i)
            i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} ate some grass to recover!", i.pbThis))
            pbHideAbilityBox(i)
          end
        when :MISTY
          if i.ability == :DRYSKIN && i.canHeal?
            pbShowAbilityBox(i)
            i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} was healed a little by the mist!", i.pbThis))
            pbHideAbilityBox(i)
          end
      end
    end
    # eruption check 2 (having the hazard removal in the main loop above causes the messaging to malfunction)
    if @field.effect == :VOLCANICTOP && @eruption
      hazardsOnSide = false
      for i in @sides
        if i.effects[:Spikes] > 0
          i.effects[:Spikes] = 0
          hazardsOnSide = true
        end
        if i.effects[:ToxicSpikes] > 0
          i.effects[:ToxicSpikes] = 0
          hazardsOnSide = true
        end
        if i.effects[:StealthRock]
          i.effects[:StealthRock] = false
          hazardsOnSide = true
        end
        if i.effects[:StickyWeb]
          i.effects[:StickyWeb] = nil
          hazardsOnSide = true
        end
      end
      pbDisplay(_INTL("The eruption removed all hazards from the field!")) if hazardsOnSide
    end

    # Status Curing Abilities
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      # Shed Skin
      if i.ability == :SHEDSKIN
        if (pbRandom(10) < 3 || @field.effect == :DRAGONSDEN) && !i.status.nil?
          pbShowAbilityBox(i)
          i.pbCureStatus
          if @field.effect == :DRAGONSDEN
            pbDisplay(_INTL("{1}'s scaled sheen glimmers brightly!", i.pbThis))
            i.pbRecoverHP((i.totalhp / 4.0).floor, true) if i.canHeal?
            stats = [PBStats::SPEED, PBStats::SPATK, PBStats::DEFENSE, PBStats::SPDEF]
            amounts = [1, 1, -1, -1]
            i.pbChangeStats(stats, amounts, i, nil, statmessage: :none, abilitycheck: :hide)
          end
          pbHideAbilityBox(i)
        end
      end
      # Hydration
      if i.hydrationActive? && !i.status.nil?
        pbShowAbilityBox(i)
        i.pbCureStatus
        pbHideAbilityBox(i)
      end
      # Healer
      if i.ability == :HEALER
        partner = i.pbPartner
        if pbRandom(10) < (Gen >= Champs ? 5 : 3) && partner.hp > 0 && !partner.status.nil?
          pbShowAbilityBox(i)
          partner.pbCureStatus
          pbHideAbilityBox(i)
        end
      end
    end

    # Passive HP Items
    priority = setSpeedOrder
    priority.each { |i| i.pbPassiveItemHP unless i.isFainted? }

    # Ability switch checkpoint
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      i.carryOutUserSwitch if [:Ability, :BossEffect, :TrainerEffect].include?(i.userSwitch)
    end

    # Aqua Ring
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:AquaRing] == false

      if @field.effect == :CORROSIVEMIST && !i.hasType?(:STEEL) && !i.hasType?(:POISON)
        pbCommonAnimation("Poison", i, nil)
        i.pbReduceHP((i.totalhp / 16.0).floor, message: _INTL("{1}'s {2} absorbed the poison!", i.pbThis, getMoveName(:AQUARING)))
        i.pbFaint if i.isFainted?
      elsif i.canHeal?
        hpgain = (i.totalhp / 16.0).floor
        i.absorbHP(hpgain, nil, :AquaRing)
      end
    end

    # Ingrain
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:Ingrain] == false

      if ((!Rejuv && @field.effect == :SWAMP) || [:CORROSIVE, :CORRUPTED].include?(@field.effect)) && !i.hasType?(:STEEL) && !i.hasType?(:POISON)
        unless i.ability == :MAGICGUARD
          pbCommonAnimation("Poison", i, nil)
          i.pbReduceHP((i.totalhp / 16.0).floor, message: _INTL("{1} absorbed foul nutrients with its roots!", i.pbThis))
          i.pbFaint if i.isFainted?
        end
      elsif i.canHeal?
        hpgain = (i.totalhp / 16.0).floor
        i.absorbHP(hpgain, nil, :Ingrain)
      end
    end

    # Leech Seed
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:LeechSeed] == -1

      recipient = @battlers[i.effects[:LeechSeed]]
      if recipient && !recipient.isFainted? && !magicGuardAbilities.include?(i.ability) # if recipient exists
        pbCommonAnimation("LeechSeed", recipient, i)
        hploss = (i.totalhp / 8.0).floor
        hploss *= 2 if @field.effect == :WASTELAND
        hploss = i.pbReduceHP(hploss, true, message: _INTL("{1}'s health is sapped by {2}!", i.pbThis, getMoveName(:LEECHSEED)))
        i.pbFaint if i.isFainted?

        recipient.absorbHP(hploss, i, :LeechSeed) if recipient.canHeal?
        recipient.pbFaint if recipient.isFainted?
      end

    end

    # NeverMeltIce - Freeze
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      if i.status == :FROZEN && !magicGuardAbilities.include?(i.ability) && @state.effects[:NeverMeltIce] && i.crested != :SUICUNE
        i.pbContinueStatus
        hploss = (i.totalhp / 8.0).floor
        i.pbReduceHP(hploss)
      end
    end

    # Petrification
    priority = setSpeedOrder
    for i in priority
      if i.status == :PETRIFIED && !magicGuardAbilities.include?(i.ability) && i.crested != :SUICUNE
        fairyAura = @battle.pbCheckSideAbility(:FAIRYAURA, i)
        hploss = (i.totalhp / 8.0).floor
        hploss = i.pbReduceHP(hploss, true) if fairyAura.none? # late message

        aurabroken = @battle.pbFindGlobalAbilityUser(:AURABREAK, checkMoldBroken: true)
        i.pbFaint if i.isFainted?
        if i.isFainted?
          i.pbFaint
          break
        end
        for j in priority
          next if j.isFainted?
          next if !(j.ability == :DARKAURA)
          next if j == i

          pbShowAbilityBox(j)
          if aurabroken
            hploss = (j.totalhp / 8.0).floor
            hploss = j.pbReduceHP(hploss, true)
            j.pbFaint if j.isFainted?
            if j.isFainted?
              j.pbFaint
              break
            end
          else
            pbCommonAnimation("LeechSeed", j, i)
            pbDisplay(_INTL("{1}'s health is sapped by the {2}'s dark aura!", i.pbThis, j.pbThis(true)))
            j.absorbHP(hploss, i, :DarkAura)
            pbHideAbilityBox(j)
          end
          pbHideAbilityBox(j)
        end
      end
    end

    # Poison
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      # Bad poison counter tick
      if i.status == :POISON && i.statusCount > 0
        i.effects[:Toxic] += 1
        i.effects[:Toxic] = [15, i.effects[:Toxic]].min # Toxic damage caps at 15/16
      end
      # Poison damage
      if i.status == :POISON && !magicGuardAbilities.include?(i.ability) && i.crested != :SUICUNE && !(i.ability == :GUTS && @battle.FE == :CROWD) && !(i.ability == :POISONHEAL || i.crested == :ZANGOOSE)
        i.pbContinueStatus
        hploss = (i.totalhp / 8.0).floor
        hploss = (i.totalhp / 16.0).floor * i.effects[:Toxic] if i.statusCount > 0
        i.pbReduceHP(hploss) # early message
        i.pbFaint if i.isFainted?
        next if i.isFainted?
        stop_pn = pbFindGlobalAbilityUser(:STOPPN)
        if stop_pn
          # treated as a self drop due to it being caused by the poison that is already affecting them
          if i.pbCanReduceAnyStat?(PBStats::Defensive, i, nil)
            pbShowAbilityBox(stop_pn)
            i.pbChangeStats(PBStats::Defensive, -1, nil, nil, abilitycheck: :hide)
            pbHideAbilityBox(stop_pn)
          end
        end
      end
      # Poison healing (Poison Heal / Zangoose Crest)
      if (i.ability == :POISONHEAL || i.crested == :ZANGOOSE) && i.canHeal? &&
         (i.status == :POISON || [:CORROSIVEMIST, :CORRUPTED].include?(@battle.FE) || ([:CORROSIVE, :MURKWATERSURFACE, :WASTELAND].include?(@battle.FE) && !i.isAirborne?))
        pbShowAbilityBox(i, item: i.crested == :ZANGOOSE)
        pbCommonAnimation("Poison", i, nil)
        i.pbRecoverHP((i.totalhp / 8.0).floor, message: _INTL("{1} was healed by the poison!", i.pbThis))
        pbHideAbilityBox(i)
      end
    end

    # Gluttony - Deux Finalis
    priority = setSpeedOrder
    for i in priority
      if (i.ability == :GLUTTONY) &&  @battle.FE == :DEUXFINALIS && i.canHeal?
        pbShowAbilityBox(i)
        pbCommonAnimation("Nom", i, nil)
        i.pbRecoverHP((i.totalhp / 16.0).floor, true)
        pbDisplay(_INTL("{1} started devouring its surroundings!", i.pbThis))
        pbHideAbilityBox(i)
      end
    end

    # Purifying Salt
    priority = setSpeedOrder
    for i in priority
      if (i.ability == :PURIFYINGSALT) &&  @battle.FE == :DEUXFINALIS && i.canHeal?
        pbShowAbilityBox(i)
        pbCommonAnimation("SandTomb", i, nil)
        i.pbRecoverHP((i.totalhp / 16.0).floor, true)
        pbDisplay(_INTL("{1} repaired itself using the surrounding salt!", i.pbThis))
        pbHideAbilityBox(i)
      end
    end

    # Burn
    priority = setSpeedOrder
    for i in priority
      if i.status == :BURN && !magicGuardAbilities.include?(i.ability) && !(i.ability == :GUTS && @battle.FE == :CROWD) && i.crested != :SUICUNE
        i.pbContinueStatus
        hploss = (i.totalhp / 16.0).floor
        hploss = (i.totalhp / 32.0).floor if i.ability == :HEATPROOF || @field.effect == :ICY
        i.pbReduceHP(hploss) # early message
        i.pbFaint if i.isFainted?
      end
    end

    # Sleep
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      # Nightmare
      if i.effects[:Nightmare] && !magicGuardAbilities.include?(i.ability) && @field.effect != :RAINBOW
        if i.isSleeping? || @battle.FE == :INFERNAL || @battle.pbCheckSideAbility(:WORLDOFNIGHTMARES, i.pbOpposing1).any?
          pbCommonAnimation("Nightmare", i, nil)
          pbDisplay(_INTL("{1} is locked in a nightmare!", i.pbThis))
          hploss = (i.totalhp / 4.0).floor
          hploss = (i.totalhp / 3.0).floor if [:HAUNTED, :DARKNESS3].include?(@field.effect)
          i.pbReduceHP(hploss, true, message: _INTL("{1} is locked in a nightmare!", i.pbThis))
        else
          i.effects[:Nightmare] = false
        end
      end
      i.pbFaint if i.isFainted?
      next if i.isFainted?

      next unless i.isSleeping?

      # sleepyswamp #sleepydimension #spookydreams #fairyringsleep #sleepycorro
      unless magicGuardAbilities.include?(i.ability)
        if @field.effect == :SWAMP # Swamp Field
          hploss = (i.totalhp / 16.0).floor
          hploss = (i.totalhp / 8.0).floor if i.effects[:MultiTurn] > 0 && Rejuv
          i.pbReduceHP(hploss, true, message: _INTL("{1}'s strength is sapped by the swamp!", i.pbThis))
        elsif @field.effect == :DIMENSIONAL # Dimensional Field (Rejuv)
          i.pbReduceHP((i.totalhp / 16.0).floor, true, message: _INTL("{1}'s dream is corrupted by the dimension!", i.pbThis))
        elsif @field.effect == :HAUNTED && !i.hasType?(:GHOST) # Haunted Field (Rejuv)
          i.pbReduceHP((i.totalhp / 16.0).floor, true, message: _INTL("{1}'s dream is corrupted by the evil spirits!", i.pbThis))
        elsif @field.effect == :BEWITCHED # Bewitched Woods (Rejuv)
          i.pbReduceHP((i.totalhp / 16.0).floor, true, message: _INTL("{1}'s dream is corrupted by the evil in the woods!", i.pbThis))
        elsif @field.effect == :CORROSIVE && !i.isAirborne? && !i.hasType?(:STEEL) && !i.hasType?(:POISON) &&
              ![:POISONHEAL, :TOXICBOOST, :WONDERGUARD, :IMMUNITY, :PASTELVEIL].include?(i.ability) && i.crested != :ZANGOOSE
          i.pbReduceHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} is seared by the corrosion!", i.pbThis))
        end
      end
      i.pbFaint if i.isFainted?
      next if i.isFainted?
      # sleepyrainbow
      if @field.effect == :RAINBOW && i.canHeal? # Rainbow Field
        i.pbRecoverHP((i.totalhp / 16.0).floor, true, message: _INTL("{1} recovered health in its peaceful sleep!", i.pbThis))
      end
    end

    # Curse
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:Curse] == false

      if @field.effect == :HOLY
        i.effects[:Curse] = false
        pbDisplay(_INTL("{1}'s curse was lifted!", i.pbThis))
      elsif !magicGuardAbilities.include?(i.ability)
        pbCommonAnimation("Curse", i, nil)
        i.pbReduceHP((i.totalhp / 4.0).floor, true, message: _INTL("{1} is afflicted by the curse!", i.pbThis))
      end
      i.pbFaint if i.isFainted?
    end

    # Salt Cure
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:SaltCure] == false
      next if magicGuardAbilities.include?(i.ability)

      pbCommonAnimation("SaltCure", i, nil)
      divisor = Gen >= Champs ? ([:HOLY, :DEUXFINALIS].include?(@battle.FE) ? 8.0 : 16.0) : ([:HOLY, :DEUXFINALIS].include?(@battle.FE) ? 6.0 : 8.0)
      divisor /= 2 if i.hasType?(:STEEL) || i.hasType?(:WATER)
      i.pbReduceHP((i.totalhp / divisor).floor, true, message: _INTL("{1} is hurt by {2}!", i.pbThis, getMoveName(:SALTCURE)))
      i.pbFaint if i.isFainted?
    end

    # Heal Block - Dimensional Fields
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:HealBlock] == 0

      if [:DIMENSIONAL, :FROZENDIMENSION, :INFERNAL].include?(@field.effect)
        if !magicGuardAbilities.include?(i.ability)
          pbCommonAnimation("Curse", i, nil)
          pbDisplay(_INTL("{1}'s Heal Block is draining its health!", i.pbThis))
          i.pbReduceHP((i.totalhp / 16.0).floor, true)
        end
      end
      i.pbFaint if i.isFainted?
    end

    # Multi-turn attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      if i.effects[:MultiTurn] > 0
        i.effects[:MultiTurn] -= 1
        movename = getMoveName(i.effects[:MultiTurnAttack])
        if i.effects[:MultiTurn] == 0
          pbDisplay(_INTL("{1} was freed from {2}!", i.pbThis, movename))
          i.effects[:BindingBand] = false
        elsif !magicGuardAbilities.include?(i.ability)
          case i.effects[:MultiTurnAttack]
            when :BIND then pbCommonAnimation("Bind", i, nil)
            when :CLAMP then pbCommonAnimation("Clamp", i, nil)
            when :FIRESPIN then pbCommonAnimation("FireSpin", i, nil)
            when :MAGMASTORM then pbCommonAnimation("Magma Storm", i, nil)
            when :SANDTOMB, :DESERTSMARK then pbCommonAnimation("SandTomb", i, nil)
            when :INFESTATION then pbCommonAnimation("Infestation", i, nil)
            when :WHIRLPOOL then pbCommonAnimation("Whirlpool", i, nil)
            else pbCommonAnimation("Wrap", i, nil)
          end
          binddamage = 0
          binddamage += 1 if i.effects[:BindingBand]
          case i.effects[:MultiTurnAttack]
            when :MAGMASTORM
              binddamage += 1 if @field.effect == :DRAGONSDEN
            when :SANDTOMB
              binddamage += 1 if @field.effect == :DESERT
            when :WHIRLPOOL
              binddamage += 1 if [:WATERSURFACE, :UNDERWATER].include?(@field.effect)
            when :INFESTATION
              case @field.effect
                when :FOREST, :FLOWERGARDEN3 then binddamage += 1
                when :FLOWERGARDEN4 then binddamage += 2
                when :FLOWERGARDEN5 then binddamage += 3
              end
            when :FIRESPIN
              binddamage += 1 if [:BURNING, :VOLCANIC, :HAUNTED].include?(@field.effect)
            when :THUNDERCAGE
              binddamage += 1 if @field.effect == :ELECTERRAIN
          end
          binddiv = [8.0, 6.0, 4.0, 3.0, 2.0][binddamage]
          i.pbReduceHP((i.totalhp / binddiv).floor, true, message: _INTL("{1} is hurt by {2}!", i.pbThis, movename))
          i.pbFaint if i.isFainted?
          next if i.isFainted?
          if i.effects[:MultiTurnAttack] == :SANDTOMB && @field.effect == :ASHENBEACH
            i.pbChangeStats(PBStats::ACCURACY, -1, nil, nil)
          end
          if Rejuv && @field.effect == :SWAMP && [:SNAPTRAP, :INFESTATION].include?(i.effects[:MultiTurnAttack])
            stat = sample(PBStats::Omni)
            i.pbChangeStats(stat, -1, nil, nil)
          end
        end
      end
    end

    # Syrup Bomb
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:SyrupBombTurns] == 0

      statdropper = @battlers[i.effects[:SyrupBombUser]]
      if i.pbCanReduceStatStage?(PBStats::SPEED, statdropper, nil)
        pbCommonAnimation("Bind", i, nil)
        i.pbChangeStats(PBStats::SPEED, -1, statdropper, nil, abilitycheck: :skip, statmessage: :SyrupBomb)
      end
      i.effects[:SyrupBombTurns] -= 1
      i.effects[:SyrupBombUser] = -1 if i.effects[:SyrupBombTurns] == 0
    end

    # Octolock
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:Octolock] == -1

      statdropper = @battlers[i.effects[:Octolock]]
      if i.pbCanReduceStatStage?(PBStats::DEFENSE, statdropper, nil) || i.pbCanReduceStatStage?(PBStats::SPDEF, statdropper, nil)
        pbCommonAnimation("Bind", i, nil)
        amount = @battle.FE == :UNDERWATER ? -2 : -1
        i.pbChangeStats(PBStats::Defensive, amount, statdropper, nil, abilitycheck: :hide, statmessage: :Octolock)
      end
    end

    # Taunt
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:Taunt] == 0

      i.effects[:Taunt] -= 1
      if i.effects[:Taunt] == 0
        pbDisplay(_INTL("{1}'s taunt wore off!", i.pbThis))
      end
    end

    # Chthonic Malady
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:ChthonicMalady] == 0
      next if i.effects[:Torment] == false

      i.effects[:ChthonicMalady] -= 1
      if i.effects[:ChthonicMalady] == 0
        i.effects[:Torment] = false
        pbDisplay(_INTL("{1}'s torment wore off!", i.pbThis))
      end
    end

    # Encore
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:Encore] == 0

      if i.moves[i.effects[:EncoreIndex]].move != i.effects[:EncoreMove]
        i.effects[:Encore] = 0
        i.effects[:EncoreIndex] = 0
        i.effects[:EncoreMove] = 0
      else
        i.effects[:Encore] -= 1 if !i.permeffs[:Frenzy]
        if i.effects[:Encore] == 0 || !i.moves[i.effects[:EncoreIndex]].usable?
          i.effects[:Encore] = 0
          pbDisplay(_INTL("{1}'s encore ended!", i.pbThis))
        end
      end
    end
    # Disable/Cursed Body
    for i in priority
      next if i.isFainted?
      next if i.effects[:Disable] == 0

      i.effects[:Disable] -= 1
      if i.effects[:Disable] == 0
        i.effects[:DisableMove] = 0
        pbDisplay(_INTL("{1}'s move is no longer disabled!", i.pbThis))
      end
    end

    # Magnet Rise
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:MagnetRise] == 0

      i.effects[:MagnetRise] -= 1 if i.crested != :PROBOPASS
      if i.effects[:MagnetRise] == 0
        pbDisplay(_INTL("{1}'s electromagnetism wore off!", i.pbThis))
      end
    end

    # Telekinesis
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:Telekinesis] == 0

      i.effects[:Telekinesis] -= 1
      if i.effects[:Telekinesis] == 0
        pbDisplay(_INTL("{1} was freed from the telekinesis!", i.pbThis))
      end
    end

    # Heal Block
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:HealBlock] == 0

      i.effects[:HealBlock] -= 1
      if i.effects[:HealBlock] == 0
        pbDisplay(_INTL("{1} is no longer prevented from healing!", i.pbThis))
      end
    end

    # Embargo
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:Embargo] == 0

      i.effects[:Embargo] -= 1
      if i.effects[:Embargo] == 0
        pbDisplay(_INTL("{1} can use items again!", i.pbThis))
      end
    end

    # Yawn
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:Yawn] == 0

      i.effects[:Yawn] -= 1
      if i.effects[:Yawn] == 0 && i.pbCanSleep?(i, nil)
        i.pbSleep
      end
    end

    # Malicious Moth
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if !pbOwnedByPlayer?(i.index) && !pbOwnedByAIPartner?(i.index)

      if i.effects[:MaliciousMoth] > 0
        if !i.pbPartner.isFainted?
          if i.pbPartner.effects[:MaliciousMoth] == -1 && i.effects[:MaliciousMoth] == 1
            if (i.pbPartner.item == :BLACKLANTERN || i.item == :BLACKLANTERN)
              pbDisplay(_INTL("{1} was protected from the Malicious Moths by the {2}!", i.pbPartner.pbThis(true), getItemName(i.pbPartner.item)))
            else
              pbCommonAnimation("MalMoths", i.pbPartner, nil)
              i.pbPartner.effects[:MaliciousMoth] = 2
              pbDisplay(_INTL("{1}'s Malicious Moths spread to {2}...", i.pbThis, i.pbPartner.pbThis))
            end
          end
        end
        if [i.item, i.pbPartner.item].include?(:BLACKLANTERN)
          i.effects[:MaliciousMoth] = -1
          i.pbPartner.effects[:MaliciousMoth] = -1
          pbDisplay(_INTL("The Malicious Moths were warded off by the Black Lantern!"))
        end
        if i.item != :BLACKLANTERN && i.pbPartner.item != :BLACKLANTERN
          i.effects[:MaliciousMoth] -= 1
          pbDisplay(_INTL("{1}'s Malicious Moths countdown fell to {2}!", i.pbThis, i.effects[:MaliciousMoth]))
        end
        if i.effects[:MaliciousMoth] == 0
          pbCommonAnimation("MaliciousMoth", i, i)
          i.vanished = true
          i.pokemon.unusable = true
          i.pbReduceHP(i.hp, true)
        end
      end
      i.pbFaint if i.isFainted?
    end

    # Perish Song
    perishSongUsers = []
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.effects[:PerishSong] == 0

      if i.isbossmon && i.immunities[:moves].include?(:PERISHSONG)
        pbDisplay(_INTL("{1} grew resistant to the {2}!", i.pbThis, getMoveName(:PERISHSONG)))
        i.effects[:PerishSong] = 0
        next
      end
      i.effects[:PerishSong] -= 1
      pbDisplay(_INTL("{1}'s perish count fell to {2}!", i.pbThis, i.effects[:PerishSong]))
      if i.effects[:PerishSong] == 0
        i.immunities[:moves].push(:PERISHSONG) if i.isbossmon
        perishSongUsers.push(i.effects[:PerishSongUser])
        i.pbReduceHP(i.hp, true)
      end
      i.pbFaint if i.isFainted?
    end
    if perishSongUsers.length > 0
      # If all remaining Pokemon fainted by a Perish Song triggered by a single side
      if (perishSongUsers.find_all { |item| pbIsOpposing?(item) }.length == perishSongUsers.length) ||
         (perishSongUsers.find_all { |item| !pbIsOpposing?(item) }.length == perishSongUsers.length)
        pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
      end
    end
    if @decision > 0
      pbGainEXP
      return
    end

    # Roost ending
    @battlers.each { |i| i.effects[:Roost] = false }

    # Ability switch checkpoint
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      i.carryOutUserSwitch if [:Ability, :BossEffect, :TrainerEffect].include?(i.userSwitch)
    end

    # Side effects
    sideeffects = [*PBStuff::SCREENEFFECTS.values, :Safeguard, :Mist, :Tailwind, :LuckyChant]
    for side in @sides
      for effect in sideeffects
        next if side.effects[effect] == 0

        side.effects[effect] -= 1
        if side.effects[effect] == 0
          pbDisplay(side.endEffectMessage(effect))
        end
      end
    end

    # Trick Room
    if @state.effects[:TrickRoom] > 0
      @state.effects[:TrickRoom] = @state.effects[:TrickRoom] - 1 if @field.effect != :FROZENDIMENSION
      if @state.effects[:TrickRoom] == 0
        pbDisplay(_INTL("The twisted dimensions returned to normal!"))
      end
    end

    # Gravity
    if @state.effects[:Gravity] > 0
      @state.effects[:Gravity] -= 1 if @field.effect != :FROZENDIMENSION
      pbDisplay(_INTL("Gravity returned to normal!")) if @state.effects[:Gravity] == 0
    end

    # Water Sport
    if @state.effects[:WaterSport] > 0
      @state.effects[:WaterSport] -= 1
      pbDisplay(_INTL("The effects of {1} have faded.", getMoveName(:WATERSPORT))) if @state.effects[:WaterSport] == 0
    end

    # Mud Sport
    if @state.effects[:MudSport] > 0
      @state.effects[:MudSport] -= 1
      if @state.effects[:MudSport] == 0
        pbDisplay(_INTL("The effects of {1} have faded.", getMoveName(:MUDSPORT)))
      end
    end

    # Wonder Room
    if @state.effects[:WonderRoom] > 0
      @state.effects[:WonderRoom] -= 1 if @field.effect != :FROZENDIMENSION
      if @state.effects[:WonderRoom] == 0
        pbDisplay(_INTL("{1} wore off, and {2} and {3} stats returned to normal!", getMoveName(:WONDERROOM), getStatName(PBStats::DEFENSE), getStatName(PBStats::SPDEF)))
        pbEndWonderRoom
      end
    end

    # Magic Room
    if @state.effects[:MagicRoom] > 0
      @state.effects[:MagicRoom] -= 1 if @field.effect != :FROZENDIMENSION
      pbDisplay(_INTL("{1} wore off, and held items' effects returned to normal!", getMoveName(:MAGICROOM))) if @state.effects[:MagicRoom] == 0
    end

    setSpeedOrder.each { |i| i.pbBerryHerbCheck }
    itemActivationsCheck # for activating/deactivating items after Embargo and Magic Room checks are done

    # Fairy Lock
    if @state.effects[:FairyLock] > 0
      @state.effects[:FairyLock] -= 1
      # Fairy Lock seems to have no end-of-effect text so I've added some.
      pbDisplay(_INTL("The {1} was released.", getMoveName(:FAIRYLOCK))) if @state.effects[:FairyLock] == 0
    end

    # Special Moves - Rejuv
    if Rejuv
      priority = setSpeedOrder
      for i in priority
        next if pbIsOpposing?(i.index)
        next if i.isFainted?
        for j in i.specialmoves
          next if sides[0].effects[:SpecialMoves][j.move] < 0
          sides[0].effects[:SpecialMoves][j.move] += 1 if sides[0].effects[:SpecialMoves][j.move] < j.chargetime
        end
      end
    end

    # Temporary field effects
    if @field.duration > 0
      @field.checkPermCondition(self)
    end
    if @field.duration > 0
      @field.duration -= 1
      @field.duration = 0 if @field.duration_condition && !@field.duration_condition.call(self)
      if @field.duration == 0
        endTempField
      end
    end


    # Overlays
    if Overlays && @field.overlay && @field.effect != :FROZENDIMENSION
      if @field.overlayCounter > 0
        @field.overlayCounter > 1 ? @field.overlayCounter -= 1 : endTempFieldOrOverlay
      end
    end


    # Wasteland hazard interaction
    if @field.effect == :WASTELAND
      # Stealth Rock
      if @sides.any? { |side| side.effects[:StealthRock] }
        pbDisplay(_INTL("The waste swallowed up the pointed stones!"))
        pbDisplay(_INTL("...Rocks spewed out from the ground below!"))
        mons = []
        reductions = []
        for mon in priority
          next unless mon.pbOwnSide.effects[:StealthRock]
          next if mon.isFainted?
          next if mon.isSemiInvul?
          next if mon.ability == :MAGICGUARD

          atype = :ROCK
          eff = PBTypes.typesEff(atype, mon.types, inverse: inverse?)
          next if eff.immune?

          mons.push(mon)
          reductions.push((mon.totalhp / 4.0 * eff.multiplier).floor)
          mon.pbPassiveTypeEffCheck(atype)
        end
        @scene.pbDamageAnimation(mons, 0, quick: true)
        pbReduceBattlersHP(mons, reductions)
        @sides.each { |side| side.effects[:StealthRock] = false }
      end

      # Spikes
      if @sides.any? { |side| side.effects[:Spikes] > 0 }
        pbDisplay(_INTL("The waste swallowed up the spikes!"))
        pbDisplay(_INTL("...Stalagmites burst up from the ground!"))
        mons = []
        reductions = []
        for mon in priority
          next unless mon.pbOwnSide.effects[:Spikes] > 0
          next if mon.isFainted?
          next if mon.isAirborne?
          next if mon.isSemiInvul?
          next if mon.ability == :MAGICGUARD

          spikescount = mon.pbOwnSide.effects[:Spikes]
          mons.push(mon)
          reductions.push((spikescount * mon.totalhp / 3.0).floor)
        end
        @scene.pbDamageAnimation(mons, 0, quick: true)
        pbReduceBattlersHP(mons, reductions)
        @sides.each { |side| side.effects[:Spikes] = 0 }
      end

      # Toxic Spikes
      if @sides.any? { |side| side.effects[:ToxicSpikes] > 0 }
        pbDisplay(_INTL("The waste swallowed up the poison spikes!"))
        pbDisplay(_INTL("...Poison needles shot up from the ground!"))
        mons = []
        reductions = []
        for mon in priority
          next unless mon.pbOwnSide.effects[:ToxicSpikes] > 0
          next if mon.isFainted?
          next if mon.isAirborne?
          next if mon.isSemiInvul?
          next if mon.ability == :MAGICGUARD
          next if mon.hasType?(:STEEL)
          next if mon.hasType?(:POISON)

          tspikescount = mon.pbOwnSide.effects[:ToxicSpikes]
          mons.push(mon)
          reductions.push((tspikescount * mon.totalhp / 8.0).floor)
        end
        @scene.pbDamageAnimation(mons, 0, quick: true)
        pbReduceBattlersHP(mons, reductions)
        mons.select! { |mon| !mon.isFainted? }
        for mon in mons
          tspikescount = mon.pbOwnSide.effects[:ToxicSpikes]
          mon.pbPoison(mon, tspikescount > 1, message: false) if mon.pbCanPoison?(nil, nil)
          # no originator or move for the pbCanPoison? check since wasteland toxic spikes are environmental
        end
        @sides.each { |side| side.effects[:ToxicSpikes] = 0 }
      end

      # Sticky Web
      if @sides.any? { |side| side.effects[:StickyWeb] }
        pbDisplay(_INTL("The waste swallowed up the sticky web!"))
        pbDisplay(_INTL("...Sticky string shot out of the ground!"))
        for mon in priority
          next unless mon.pbOwnSide.effects[:StickyWeb]
          next if mon.isFainted?
          next if mon.isSemiInvul?
          # the view is that during this interaction the original setter is lost and now considered coming from the field
          # so the statdrop call is made without a statinducer; passing a nil value
          mon.pbChangeStats(PBStats::SPEED, -4, nil, nil)
        end
        @sides.each { |side| side.effects[:StickyWeb] = false }
      end
    end

    # Mostly everything else
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      # Uproar
      if i.effects[:Uproar] > 0
        i.effects[:Uproar] -= 1
        i.effects[:Uproar] = 0 if i.effects[:ThroatChop] > 0
        if i.effects[:Uproar] == 0
          pbDisplay(_INTL("{1} calmed down.", i.pbThis))
        else
          pbDisplay(_INTL("{1} is making an uproar!", i.pbThis))
        end
      end

      # Accumulation
      if i.ability == :ACCUMULATION && i.turncount > 0 && ![:SPITUP, :SWALLOW].include?(i.lastMoveUsed)
        if i.effects[:Stockpile] < 3
          pbShowAbilityBox(i)
          i.pbAddStockpile(nil)
          pbHideAbilityBox(i)
        end
      end

      # Bad Dreams
      if i.ability == :BADDREAMS && @battle.FE != :RAINBOW
        dreamPriority = setSpeedOrder
        for j in dreamPriority
          next unless j.pbIsOpposing?(i.index)
          next unless j.isSleeping?
          next if magicGuardAbilities.include?(j.ability)

          pbShowAbilityBox(i)
          hpdrain = (j.totalhp / 8.0).floor
          hpdrain = (j.totalhp / 6.0).floor if @battle.FE == :DARKNESS2 || @battle.OV == :DARKNESS2
          hpdrain = (j.totalhp / 4.0).floor if [:INFERNAL, :DARKNESS3].include?(@battle.FE)
          j.pbReduceHP(hpdrain, true, message: _INTL("{1} is tormented!", j.pbThis))
          j.pbFaint if j.isFainted?
        end
        pbHideAbilityBox(i)
      end

      # Wildfire
      if i.ability == :WILDFIRE
        endmessage = false
        mons = []
        reductions = []
        firePriority = setSpeedOrder
        for j in firePriority
          next if j.isFainted?
          next unless j.pbIsOpposing?(i.index)
          next if j.hasType?(:FIRE)
          next if magicGuardAbilities.include?(j.ability)

          pbShowAbilityBox(i)
          pbCommonAnimation("FireSpin", j, nil)
          pbDisplay(_INTL("The Pokémon were burnt by the wildfire!!")) if !endmessage
          endmessage = true
          @scene.pbDamageAnimation(j, 0, quick: true)
          mons.push(j)
          hpdrain = (j.totalhp / 16.0).floor
          hpdrain = (j.totalhp / 8.0).floor if (j.status == :BURN && j.crested != :SUICUNE) || i.effects[:MultiTurnAttack] == :FIRESPIN
          hpdrain = (j.totalhp / 6.0).floor if [:GRASSY, :FOREST, :FLOWERGARDEN1, :FLOWERGARDEN2, :FLOWERGARDEN3, :FLOWERGARDEN4, :FLOWERGARDEN5, :INFERNAL].include?(@battle.FE)
          reductions.push(hpdrain)
        end
        pbReduceBattlersHP(mons, reductions)
        pbHideAbilityBox(i)
      end

      # Water Barrage
      if i.ability == :WATERBARRAGE
        endmessage = false
        mons = []
        reductions = []
        waterPriority = setSpeedOrder
        for j in waterPriority
          next if j.isFainted?
          next unless j.pbIsOpposing?(i.index)
          next if j.hasType?(:WATER)
          next if magicGuardAbilities.include?(j.ability)

          pbShowAbilityBox(i)
          pbCommonAnimation("Rain") if !endmessage
          pbDisplay(_INTL("The Pokémon were hit by the cannon barrage!")) if !endmessage
          endmessage = true
          @scene.pbDamageAnimation(j, 0, quick: true)
          mons.push(j)
          damageorder = [1/16.0, 2/16.0, 3/16.0]
          hpdrain = (j.totalhp * damageorder[@turncount % 3]).floor
          reductions.push(hpdrain)
        end
        pbReduceBattlersHP(mons, reductions)
        pbHideAbilityBox(i)
      end

      # Pollenflight
      if i.ability == :POLLENFLIGHT
        firePriority = setSpeedOrder
        for j in firePriority
          next if j.isFainted?
          next unless j.pbIsOpposing?(i.index)
          next if j.hasType?(:GRASS)
          next if magicGuardAbilities.include?(j.ability)

          pbShowAbilityBox(i)
          hpdrain = (j.totalhp / 16.0).floor
          hpdrain = (j.totalhp / 32.0).floor if j.effects[:LeechSeed] >= 0
          pbCommonAnimation("LeechSeed", i, j)
          hploss = j.pbReduceHP(hpdrain, true, message: _INTL("{1}'s health is sapped by {2}'s pollen!", j.pbThis, i.pbThis(true)))
          j.pbFaint if j.isFainted?

          i.absorbHP(hploss, j, :Pollenflight) if i.canHeal?
          i.pbFaint if i.isFainted?
          break if i.isFainted?
        end
        pbHideAbilityBox(i)
      end

      # Ball Fetch
      if i.ability == :BALLFETCH && !@ballToFetch.nil? && i.item.nil? && i.permeffs[:ItemToKeep].nil?
        pokeball = @ballToFetch
        @ballToFetch = nil
        message = _INTL("{1} found {2}!", i.pbThis, getItemName(pokeball, :a))
        pbAbilityBoxAndDisplay(i, message)
        i.obtainItem(pokeball)
      end

      # Cud Chew
      if i.effects[:CudChewTurns] > 0
        i.effects[:CudChewTurns] -= 1
        if i.effects[:CudChewTurns] == 0
          if i.ability == :CUDCHEW
            pbShowAbilityBox(i)
            i.pbEatBerry(i.effects[:CudChewBerry])
            # Berry consumption is not affected by Magic Room, tested on canon games
            pbHideAbilityBox(i)
          end
          i.effects[:CudChewBerry] = nil
        end
      end

      # Harvest
      if i.ability == :HARVEST && i.item.nil? && !i.permeffs[:ItemRecycle].nil? && pbIsBerry?(i.permeffs[:ItemRecycle])
        if (pbWeather(nil) == :SUNNYDAY && !i.hasWorkingItem(:UTILITYUMBRELLA)) ||
           @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5) ||
           (Rejuv && @battle.FE == :GRASSY) ||
           pbRandom(2) == 0
          item = i.permeffs[:ItemRecycle]
          i.permeffs[:ItemRecycle] = nil
          message = _INTL("{1} harvested {2}!", i.pbThis, getItemName(item, :a))
          pbAbilityBoxAndDisplay(i, message)
          i.obtainItem(item, recycled: true)
          i.pbBerryHerbCheck
        end
      end

      # Moody
      if i.ability == :MOODY
        incstats, decstats = [], []
        for stat in 1..(Gen <= 7 ? 7 : 5)
          incstats.push(stat) if i.pbCanIncreaseStatStage?(stat, i, nil)
          decstats.push(stat) if i.pbCanReduceStatStage?(stat, i, nil)
        end
        if !incstats.empty?
          pbShowAbilityBox(i)
          incstat = @battle.sample(incstats)
          i.pbChangeStats(incstat, 2, i, nil, abilitycheck: :skip)
          decstats -= [incstat]
        end
        if !decstats.empty?
          pbShowAbilityBox(i)
          decstat = @battle.sample(decstats)
          i.pbChangeStats(decstat, -1, i, nil, abilitycheck: :skip)
        end
        pbHideAbilityBox(i)
      end

      # Pickup (help me -Orsan).
      # tested on SV and in showdown, it deprioritizes items that activate during an attack, such as type berries, focus sashes, and presumably gems. that's represented here as pickupB.
      if i.ability == :PICKUP && i.item.nil?
        for pickuptarget in @pickupA + @pickupB # loop through pickupA first, then pickupB
          next if i.index == pickuptarget
          next if battlers[pickuptarget].isFainted?
          next if battlers[pickuptarget].permeffs[:ItemRecycle].nil?

          item = battlers[pickuptarget].permeffs[:ItemRecycle]
          battlers[pickuptarget].permeffs[:ItemRecycle] = nil
          message = _INTL("{1} found {2}!", i.pbThis, getItemName(item, :a))
          pbAbilityBoxAndDisplay(i, message)
          i.obtainItem(item, recycled: true)
          break
        end
      end

      # Slow Start
      if i.effects[:SlowStart] < 5
        i.effects[:SlowStart] += @battle.FE == :ELECTERRAIN ? 2 : 1
        if i.effects[:SlowStart] >= 5 && i.ability == :SLOWSTART && @battle.FE != :DEEPEARTH
          pbDisplay(_INTL("{1} finally got its act together!", i.pbThis))
        end
      end

      # Speed Boost
      # A Pokémon's turncount is 0 if it became active after the beginning of a round
      if i.turncount > 0 && i.ability == :SPEEDBOOST
        if i.pbCanIncreaseStatStage?(PBStats::SPEED, i, nil)
          pbShowAbilityBox(i)
          i.pbChangeStats(PBStats::SPEED, 1, i, nil, abilitycheck: :skip)
          pbHideAbilityBox(i)
        end
      end

      # World of Nightmares
      if i.ability == :WORLDOFNIGHTMARES
        nightmarePriority = setSpeedOrder
        for j in nightmarePriority
          next unless j.pbIsOpposing?(i.index)
          next if j.isFainted?

          pbShowAbilityBox(i)
          nightmarechip = [64, j.turncount].min
          nightmarechip *= 2 if @battle.FE == :NEWWORLD
          j.pbReduceHP((j.totalhp / 32.0).floor * nightmarechip, true, message: _INTL("{1}'s nightmares are becoming a reality!", j.pbThis))
          j.pbFaint if j.isFainted?
        end
        pbHideAbilityBox(i)
      end

      # Toxic Orb
      if i.hasWorkingItem(:TOXICORB) && i.status.nil? && i.pbCanPoison?(i, nil)
        i.pbPoison(i, true, message: _INTL("{1} was badly poisoned by {2}!", i.pbThis, getItemName(i.item, :the)))
      end

      # Flame Orb
      if i.hasWorkingItem(:FLAMEORB) && i.status.nil? && i.pbCanBurn?(i, nil)
        i.pbBurn(i, message: _INTL("{1} was burned by {2}!", i.pbThis, getItemName(i.item, :the)))
      end

      # Sticky Barb
      if i.hasWorkingItem(:STICKYBARB) && !magicGuardAbilities.include?(i.ability)
        pbShowAbilityBox(i, item: true)
        pbCommonAnimation("UseItem", i, nil)
        i.pbReduceHP((i.totalhp / 8.0).floor, message: _INTL("{1} was hurt by its {2}!", i.pbThis, getItemName(i.item)))
        pbHideAbilityBox(i)
      end
      if i.hasWorkingItem(:BLACKLANTERN) && PBStuff::MOTHLIST.include?(i.species)
        pbAnimation(:TAILGLOW, i, nil)
        i.pbReduceHP((i.totalhp / 8.0).floor, message: _INTL("{1} was hurt by its {2}!", i.pbThis, getItemName(i.item)))
      end
      i.pbFaint if i.isFainted?
    end

    # Ability switch checkpoint
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      i.carryOutUserSwitch if [:Ability, :BossEffect, :TrainerEffect].include?(i.userSwitch)
    end

    # Form checks
    priority = @battlers.sort_by { |i| i.speed }
    priority.each { |i| i.pbCheckFormRoundEnd unless i.isFainted? }

    # Hunger Switch
    priority = setSpeedOrder
    for i in priority
      break if @field.effect == :FROZENDIMENSION
      next if i.isFainted?
      next unless i.species == :MORPEKO
      next unless i.ability == :HUNGERSWITCH

      pbShowAbilityBox(i)
      i.changeForm(i.form == 0 ? 1 : 0)
      i.pbUpdate(true)
      scene.pbChangePokemon(i, i.pokemon)
      pbDisplay(_INTL("{1} transformed!", i.pbThis))
      pbHideAbilityBox(i)
    end

    # Recovered items from Harvest/Pickup + White Herb, Opportunist, Mirror Herb, Eject Pack
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?

      i.pbBerryHerbCheck
      i.pbItemsOnField(consumablesOnly: true)
      i.roomServiceCheck
    end

    pbGainEXP

    # for i in priority
    #   if i.crested == :CELEBI
    #     timewarp(i, 1)
    #   end
    # end

    # LAWDS stall credit to DemICE for the concept
    return if skipcelebi == true
    for i in priority
      if i.crested == :CELEBI && !i.isFainted?
        pbDisplay(_INTL("{1} accelerated the passage of time!",i.pbThis))
        pbEndOfRoundPhase(true)
      end
    end

    # Replace fainted battlers at end of turn
    pbReplaceFaintedBattlers

    for i in priority
      break if @party2[0][0].nil?
      break if @state.effects[:sosBuffer] != 0
      next if i.isFainted?
      next if i.nil?

      @state.effects[:sosBuffer] = 3 if @doublebattle && i.isbossmon && i.pbPartner.issosmon
      @state.effects[:sosBuffer] = 4 if $cache.bosses[@party2[0][0].bossID] && $cache.bosses[@party2[0][0].bossID].name == "Spacea"
    end
    # sosBuffer
    if @state.effects[:sosBuffer] > 0
      @state.effects[:sosBuffer] -= 1
    end
    pbBossSOS() if @state.effects[:sosBuffer] == 0
    # Boss calling SOS after a shield break at end-of-turn
    if @callingSOS
      pbBossSOS(true)
      @callingSOS = false
    end

    return if @decision > 0

    # Replace second
    pbReplaceFaintedBattlers

    for i in priority
      i.pbRegularIntervalChecks
    end

    for i in @battlers
      if i.turncount > 0
        if i.ability == :TRUANT
          i.effects[:Truant] = !i.effects[:Truant]
        else
          i.effects[:Truant] = false
        end
      end
      if i.effects[:LockOn] > 0 # Also Mind Reader
        i.effects[:LockOn] -= 1
        i.effects[:LockOnPos] = -1 if i.effects[:LockOn] == 0
      end
      i.effects[:Roost] = false
      i.effects[:Flinch] = false
      i.effects[:FollowMe] = false
      i.effects[:RagePowder] = false
      i.effects[:ParentalBond] = false
      i.effects[:TyphBond] = false
      i.effects[:SurgingBlessing] = 0
      i.effects[:CincCrest] = false
      i.effects[:Charge] -= 1 if i.effects[:Charge] > 0 && Gen < 9
      i.effects[:LaserFocus] -= 1 if i.effects[:LaserFocus] > 0
      i.effects[:Snatch] = false
      i.effects[:Electrify] = false
      i.effects[:AfterYou] = false
      i.effects[:Quash] = false
      i.lastHPLost = 0
      i.lastAttacker = -1
      i.effects[:Endure] = false
      i.effects[:Counter] = 0
      i.effects[:CounterTarget] = -1
      i.effects[:MirrorCoat] = 0
      i.effects[:MirrorCoatTarget] = -1
      if i.capturable && @catchmessageplayed == false
        if i.shieldCount == 0
          @catchmessageplayed = true
          @battle.pbDisplayPaused(_INTL("{1}'s guard is low! Try capturing it!", i.pbThis))
        end
      end
    end
    for side in @sides
      if side.effects[:PokemonFaintedThisTurn]
        side.effects[:PokemonFaintedThisTurn] = false
        side.effects[:Retaliate] = true
      else
        side.effects[:Retaliate] = false
      end
      side.effects[:AllySwitch] = false
    end
    @pickupA = []
    @pickupB = []
    @eruption = false
  end

  ################################################################################
  # End of battle.
  ################################################################################
  def pbEndOfBattle(canlose = false)
    $position = Audio.bgm_pos
    PBDebug.log("") # line break
    case @decision
      ##### WIN #####
      when 1
        $game_variables[:Egg_Battle_Count] += 1 if Desolation && $game_variables[:Egg_Battle_Count] > 0 && $game_variables[:Egg_Battle_Count] < 1000
        if @opponent
          @scene.pbTrainerBattleSuccess
          msg = case true
            when @opponent.is_a?(Array) && @player.is_a?(Array)
              _INTL("{1} and {2} defeated {3} and {4}!", self.pbPlayer.name, @player[1].fullname, @opponent[0].fullname, @opponent[1].fullname)
            when @opponent.is_a?(Array) && !@player.is_a?(Array)
              _INTL("{1} defeated {2} and {3}!", self.pbPlayer.name, @opponent[0].fullname, @opponent[1].fullname)
            when !@opponent.is_a?(Array) && @player.is_a?(Array)
              _INTL("{1} and {2} defeated {3}!", self.pbPlayer.name, @player[1].fullname, @opponent.fullname)
            else # Both player and opponent single trainers
              _INTL("{1} defeated {2}!", self.pbPlayer.name, @opponent.fullname)
          end
          pbDisplayPaused(msg)
          # Trainer lines when player wins
          endspeech = pbGetMessageFromHash(:EndSpeechLose, @endspeech)
          pbDisplayTrainerMessage(endspeech, 0, hidesprite: false)
          if @opponent.is_a?(Array)
            @scene.pbHideOpponent
            endspeech = pbGetMessageFromHash(:EndSpeechLose, @endspeech2)
            pbDisplayTrainerMessage(endspeech, 1, hidesprite: false)
          end
          # Calculate money gained for winning
          if @internalbattle
            tmoney = 0
            if @opponent.is_a?(Array) # Double battles
              maxlevel1 = 0
              maxlevel2 = 0
              for mon in @party2[0]
                maxlevel1 = mon.level if mon && maxlevel1 < mon.level
              end
              for mon in @party2[1]
                maxlevel2 = mon.level if mon && maxlevel2 < mon.level
              end
              maxlevel1 = [100, maxlevel1].min
              maxlevel2 = [100, maxlevel2].min
              tmoney += maxlevel1 * @opponent[0].moneyEarned
              tmoney += maxlevel2 * @opponent[1].moneyEarned
            else
              maxlevel = 0
              for mon in allMons(@party2)
                maxlevel = mon.level if mon && maxlevel < mon.level
              end
              tmoney += maxlevel * @opponent.moneyEarned
            end
            # If Amulet Coin/Luck Incense's effect applies, double money earned
            if Desolation || Rejuv
              badgemultiplier = 1 + (self.pbPlayer.numbadges / 2).floor
              tmoney *= badgemultiplier
            else
              badgemultiplier = 1 + (self.pbPlayer.numbadges / 6.0)
              tmoney *= badgemultiplier
              tmoney = tmoney.floor
            end
            tmoney *= 2 if @amuletcoin
            tmoney *= 2 if @happyhour
            tmoney *= 2 if $game_switches[:Moneybags]
            if $game_switches[:Grinding_Trainer_Money_Cut] || $game_switches[:Penniless_Mode] # grinding trainers
              tmoney = (tmoney * 0.25).floor
            end
            tmoney *= 2 if $game_variables[:LuckMoney] != 0
            tmoney = 0 if $game_variables[:LuckMoney] > 10 || $game_variables[:LuckMoney] < -10
            tmoney = 0 if $game_switches[:NotPlayerCharacter]
            oldmoney = self.pbPlayer.money
            if $game_variables[:LuckMoney] < 0
              self.pbPlayer.money -= tmoney
              moneylost = oldmoney - self.pbPlayer.money
              if moneylost > 0
                pbDisplayAutoPaused(_INTL("{1} paid {2} for winning!", self.pbPlayer.name, getPurchaseDisplay(tmoney)))
              end
            else
              tmoney = 0 if $game_switches[:NotPlayerCharacter]
              self.pbPlayer.money += tmoney
              moneygained = self.pbPlayer.money - oldmoney
              if moneygained > 0
                pbDisplayAutoPaused(_INTL("{1} got {2} for winning!", self.pbPlayer.name, getPurchaseDisplay(tmoney)))
              end
            end
          end
        elsif @party2[0][0]&.isbossmon || @party2[0][1]&.isbossmon
          bosses = allMons(@party2).select {|boss| boss.isbossmon}
          if bosses.include?(@party2[0][0]) && bosses.include?(@party2[0][1])
            bossname1 = $cache.bosses[@party2[0][0].bossID].name ? $cache.bosses[@party2[0][0].bossID].name : @party2[0][0].name
            bossname2 = $cache.bosses[@party2[0][1].bossID].name ? $cache.bosses[@party2[0][1].bossID].name : @party2[0][1].name
            @scene.pbBossBattleSuccess([bossname1,bossname2])
            if @player.is_a?(Array)
              msg = _INTL("{1} and {2} defeated {3} and {4}!", self.pbPlayer.name, @player[1].fullname, bossname1, bossname2)
            else
              msg = _INTL("{1} defeated {2} and {3}!", self.pbPlayer.name, bossname1, bossname2)
            end
            pbDisplayPaused(msg)
          elsif bosses.include?(@party2[0][0])
            bossname1 = $cache.bosses[@party2[0][0].bossID].name ? $cache.bosses[@party2[0][0].bossID].name : @party2[0][0].name
            bossname1 = @party2[0][0].name if bossname1 == ""
            @scene.pbBossBattleSuccess([bossname1])
            if @player.is_a?(Array)
              msg = _INTL("{1} and {2} defeated {3}!", self.pbPlayer.name, @player[1].fullname, bossname1)
            else
              msg = _INTL("{1} defeated {2}!", self.pbPlayer.name, bossname1)
            end
            pbDisplayPaused(msg)
          elsif bosses.include?(@party2[0][1])
            bossname2 = $cache.bosses[@party2[0][1].bossID].name ? $cache.bosses[@party2[0][1].bossID].name : @party2[0][1].name
            bossname2 = @party2[0][0].name if bossname2 == ""
            @scene.pbBossBattleSuccess([bossname2])
            if @player.is_a?(Array)
              msg = _INTL("{1} and {2} defeated {3}!", self.pbPlayer.name, @player[1].fullname, bossname2)
            else
              msg = _INTL("{1} defeated {2}!", self.pbPlayer.name, bossname2)
            end
            pbDisplayPaused(msg)
          end
        end
        if @internalbattle && @extramoney > 0
          @extramoney *= 2 if @amuletcoin
          @extramoney *= 2 if @happyhour
          oldmoney = self.pbPlayer.money
          @extramoney = 0 if $game_switches[:NotPlayerCharacter]
          self.pbPlayer.money += @extramoney
          moneygained = self.pbPlayer.money - oldmoney
          if moneygained > 0
            pbDisplayAutoPaused(_INTL("{1} picked up {2}!", self.pbPlayer.name, getPurchaseDisplay(@extramoney)))
          end
        end
        for pkmn in @snaggedpokemon
          pbBattleStorePokemon(pkmn)
        end
        # Update Healingitem
        if $PokemonGlobal.partner && @player.is_a?(Array)
          $PokemonGlobal.partner[4] = @partneritems if $PokemonGlobal.partner[4] != @partneritems
        end
      ##### LOSE, DRAW #####
      when 2, 5
        if @internalbattle
          msg = @player.is_a?(Array) ?
            _INTL("{1} and {2} are out of usable Pokémon!", self.pbPlayer.name, @player[1].fullname) :
            _INTL("{1} is out of usable Pokémon!", self.pbPlayer.name)
          pbDisplayAutoPaused(msg)
          moneylost = pbMaxLevelFromIndex(0)
          if Desolation || Rejuv
            # Badge no. multiplier for money lost
            multipliers = [8, 16, 24, 36, 48, 64, 80, 100, 120, 140, 160, 180, 190, 200, 210, 220, 230, 240, 250, 250]
            moneylost *= multipliers[[multipliers.length - 1, self.pbPlayer.numbadges].min]
          else
            moneylost *= 8 * (1 + self.pbPlayer.numbadges)
          end
          moneylost = self.pbPlayer.money if moneylost > self.pbPlayer.money
          moneylost = 0 if $game_switches[:No_Money_Loss]
          $game_switches[:Eizen_Shadow_Capture] = false
          self.pbPlayer.money -= moneylost
          if @opponent
            msg = case true
              when @opponent.is_a?(Array) && @player.is_a?(Array)
                _INTL("{1} and {2} lost against {3} and {4}!", self.pbPlayer.name, @player[1].fullname, @opponent[0].fullname, @opponent[1].fullname)
              when @opponent.is_a?(Array) && !@player.is_a?(Array)
                _INTL("{1} lost against {2} and {3}!", self.pbPlayer.name, @opponent[0].fullname, @opponent[1].fullname)
              when !@opponent.is_a?(Array) && @player.is_a?(Array)
                _INTL("{1} and {2} lost against {3}!", self.pbPlayer.name, @player[1].fullname, @opponent.fullname)
              else # Both player and opponent single trainers
                _INTL("{1} lost against {2}!", self.pbPlayer.name, @opponent.fullname)
            end
            pbDisplayPaused(msg)
            if moneylost > 0
              pbDisplayAutoPaused(_INTL("{1} paid {2} as the prize money...", self.pbPlayer.name, getPurchaseDisplay(moneylost)))
              pbDisplayAutoPaused(_INTL("...")) if !canlose
            end
          else
            if moneylost > 0
              pbDisplayAutoPaused(_INTL("{1} panicked and lost {2}...", self.pbPlayer.name, getPurchaseDisplay(moneylost)))
              pbDisplayAutoPaused(_INTL("...")) if !canlose
            end
          end
          pbDisplayAutoPaused(_INTL("{1} blacked out!", self.pbPlayer.name)) if !canlose
        elsif @decision == 2
          # Trainer lines when player loses
          pbDisplayTrainerMessage(@endspeechwin, 0, hidesprite: false)
          if @opponent.is_a?(Array)
            @scene.pbHideOpponent
            pbDisplayTrainerMessage(@endspeechwin2, 1, hidesprite: false)
          end
        elsif @decision == 5
          PBDebug.dblog("***[Battle ended in a draw.]***")
        end
        $game_screen.weather(0, 0, 0)
    end
    returnStolenPokemon(true)
    # Change bad poison to normal poison
    for i in $Trainer.party
      next if i.nil?

      if i.statusCount > 0 && i.status == :POISON
        i.statusCount = 0
      end
    end

    # Pass on Pokérus within the party
    infected = []
    for i in 0...$Trainer.party.length
      infected.push(i) if $Trainer.party[i].pokerusStage == 1
    end
    for i in infected
      strain = $Trainer.party[i].pokerus / 16
      if i > 0 && $Trainer.party[i - 1].pokerusStage == 0
        $Trainer.party[i - 1].givePokerus(strain) if pbRandom(3) == 0
      end
      if i < $Trainer.party.length - 1 && $Trainer.party[i + 1].pokerusStage == 0
        $Trainer.party[i + 1].givePokerus(strain) if pbRandom(3) == 0
      end
    end

    # Rejuv Contracts / Deso Drinks
    if @opponent && !@battle.isOnline?
      if $game_variables[:LuckMoney] != 0
        $game_variables[:LuckMoney] -= 1 if $game_variables[:LuckMoney] > 0
        $game_variables[:LuckMoney] += 1 if $game_variables[:LuckMoney] < 0
        message = _INTL("Mr Luck's money contract lost its effect!")
        pbDisplayPaused(message) if $game_variables[:LuckMoney] == 0
      end
    end
    if !@opponent && !@party2[0][0].isbossmon && !@battle.isOnline?
      if $game_variables[:LuckShinies] != 0
        $game_variables[:LuckShinies] -= 1 if $game_variables[:LuckShinies] > 0
        $game_variables[:LuckShinies] += 1 if $game_variables[:LuckShinies] < 0
        message = _INTL("Mr Luck's shiny contract lost its effect!")
        message = _INTL("The effects of the Shiny Drink wore off!") if Desolation
        pbDisplayPaused(message) if $game_variables[:LuckShinies] == 0
      end
      if $game_variables[:LuckMoves] != 0
        $game_variables[:LuckMoves][0] -= 1 if $game_variables[:LuckMoves][0] > 0
        $game_variables[:LuckMoves][0] += 1 if $game_variables[:LuckMoves][0] < 0
        if $game_variables[:LuckMoves][0] == 0
          $game_variables[:LuckMoves] = 0
          message = _INTL("Mr Luck's technique contract lost its effect!")
          message = _INTL("The effects of the Egg Drink wore off!") if Desolation
          pbDisplayPaused(message)
        end
      end
      if $game_variables[:DrinkIVs] > 0
        $game_variables[:DrinkIVs] -= 1
        message = _INTL("The effects of the IV Drink wore off!")
        pbDisplayPaused(message) if $game_variables[:DrinkIVs] == 0
      end
      if $game_variables[:DrinkItems] > 0
        $game_variables[:DrinkItems] -= 1
        message = _INTL("The effects of the Item Drink wore off!")
        pbDisplayPaused(message) if $game_variables[:DrinkItems] == 0
      end
    end

    @scene.pbEndBattle(@decision)

    # Resetting all the temporary forms
    @battlers.each { |i| i.pbResetForm }

    # Making Pokemon usable again
    for i in $Trainer.party
      next if i.nil?
      i.unusable = false if i.unusable
    end

    # reset waiting list for trainer objects that persist after a battle (player and partner)
    if @player.is_a?(Array)
      for trainer in @player
        trainer.delayList = nil
      end
    else
      @player.delayList = nil
    end

    partnermons = $PokemonGlobal.partner && @player.is_a?(Array) ? @party1[1] : []
    snaggedmons = @decision == 1 ? @snaggedpokemon : []
    for i in ($Trainer.party | partnermons).compact
      # Reset forms for all player and partner pokemon (wild-caught and snagged pokemon that got sent to the PC are accounted for in pbStoreCaught)
      i.changeFormOnBattleEnd
      # Remove attributes needed only in battle (caught pokemon accounted for on catch)
      i.removeBattleOnlyAttributes
    end
    # Reset items for all player and partner pokemon, and also all snagged mons in case any got sent to the PC (required to prevent item duplication scenarios, but not for wild-caught mons since item changes are handled differently for wild pokemon)
    for i in ($Trainer.party | partnermons | snaggedmons).compact
      if @restoreItems || partnermons.include?(i) # partner pokemon always have their item restored
        i.setItem(@permanenteffects[i][:OriginalItem])
      elsif @permanenteffects[i][:ItemToKeep] && @permanenteffects[i][:ItemToKeep] != @permanenteffects[i][:OriginalItem]
        # Deposit items obtained from wild Pokemon via Thief, etc. directly to bag at end of battle
        $PokemonTemp.battleStolenItems.push(@permanenteffects[i][:ItemToKeep])
        i.setItem(nil)
      else
        i.setItem(@permanenteffects[i][:ItemToKeep])
      end
    end
    # Reset levels for all player-side pokemon for 'levelCap' battles like the ones in the Nightclub
    if @levelCap
      for i in ($Trainer.party | partnermons).compact
        i.level = @permanenteffects[i].fetch(:StoredLevel, i.level)
        i.exp = @permanenteffects[i].fetch(:StoredEXP, i.level)
        i.calcStats
      end
    end

    @snaggedpokemon.clear

    # Set variables to field effect values
    $game_variables[:Field_Effect_End_Of_Battle] = @field.effect
    $game_variables[:Field_Counter_End_Of_Battle] = @field.counter
    $game_variables[:Weather_End_Of_Battle] = @weather
    favPokeTracker(:train)

    PBDebug.close(true) # close log file at end of battle (also transfers any leftover logs from buffer to file)

    return @decision
  end

  def getLogFileName
    return nil if pbIsWild? && !($cache.bosses[@battle.pbPartySingleOwner(1)[0].bossID] || $cache.bosses[@battle.pbPartySingleOwner(3)[0].bossID])

    replacechars = /[^0-9A-Za-z\.\-_ ]/
    timestring = Time.new.strftime("%Y-%m-%d_%H-%M-%S")
    if pbIsWild? && (@battle.checkPartyBosses(@battle.pbPartySingleOwner(1)) || @battle.checkPartyBosses(@battle.pbPartySingleOwner(3)))
      opp1name = $cache.bosses[@battle.pbPartySingleOwner(1)[0].bossID] ? $cache.bosses[@battle.pbPartySingleOwner(1)[0].bossID].name : @battle.pbPartySingleOwner(1)[0].name
      if @battle.pbPartySingleOwner(3)[1]
        opp2name = $cache.bosses[@battle.pbPartySingleOwner(3)[1].bossID] ? $cache.bosses[@battle.pbPartySingleOwner(3)[1].bossID].name : @battle.pbPartySingleOwner(3)[1].name
      end
      oppname = @doublebattle ? "#{opp1name} and #{opp2name}" : opp1name
    else
      oppname = @opponent.kind_of?(Array) ? "#{@opponent[0].name} and #{@opponent[1].name}" : @opponent.name
    end
    trainame = $PokemonGlobal.partner && @doublebattle && @player.kind_of?(Array) ? "#{$Trainer.name} and #{@player[1].name}" : $Trainer.name
    trainame = trainame.gsub(replacechars, "_")
    fieldname = getFieldName(@field.effect)
    battleformat = @doublebattle ? "Doubles" : "Singles"
    oppname = oppname.gsub(replacechars, "_")
    filename = "#{timestring} - #{trainame} vs. #{oppname} (#{fieldname} #{battleformat})"

    filename = limitedFileName(filename)
    return filename
  end

  def addRoundStringToLog
    roundstring = _INTL("Round {1}", @turncount.to_s)
    sep = "*" * 34
    PBDebug.log("\n#{sep} #{roundstring} #{sep}")
    sep = "=" * (16 - @turncount.to_s.length)
    @scene.addToBattleLog("#{sep} #{roundstring} #{sep}", tts: roundstring, color: :round)
  end

  # Inspired by Battler.pbReduceHP + faint check
  def pbReduceBattlersHP(mons, hploss, anim = false)
    raise "array length mismatch" if mons.length != hploss.length
    return if mons == []

    oldhps = []
    amt = []
    damagelimit = []
    onBreakdata = nil
    hpthreshold = 0

    mons.each_with_index do |battler, i|
      dmglimit = battler.hp
      hpthreshold = 0

      if battler.isbossmon && battler.shieldCount > 0 && battler.onBreakEffects && battler.onBreakEffects[battler.shieldCount]
        onBreakdata = battler.onBreakEffects[battler.shieldCount]
        if !@snapshot.nil? && @snapshot[1] && @snapshot[1][:snapshotUses] == 0
          onBreakdata = battler.onBreakEffects[battler.shieldCount * -1]
        end
        hpthreshold = onBreakdata && onBreakdata[:threshold] ? onBreakdata[:threshold] : 0
        unless hpthreshold == 1
          dmglimit = battler.hp - (battler.totalhp * hpthreshold).round
        end
      end

      amount = hploss[i]
      if amount >= dmglimit
        amount = dmglimit
      elsif amount <= 0 && !battler.isFainted?
        amount = 1
      end

      if battler.issosmon && battler.hp - amount == 0
        priority = setSpeedOrder
        for mon in priority
          bossmon = mon if mon.isbossmon
        end
        battler.lastAttacker = bossmon.index if bossmon
      end

      oldhp = battler.hp
      battler.hp -= amount
      raise _INTL("HP less than 0") if battler.hp < 0
      raise _INTL("HP greater than total HP") if battler.hp > battler.totalhp

      if amount > 0
        oldhps.push oldhp
        amt.push amount
        damagelimit.push dmglimit
      end
    end

    @battle.scene.pbHPChanged(mons, oldhps, anim) if oldhps.length > 0

    mons.each_with_index do |battler, i|
      battler.checkLastWord(oldhps[i])
      if battler.isbossmon && amt[i] == damagelimit[i] && battler.shieldCount > 0
        @battle.scene.pbShieldBreakToText(battler) # TTS + Logging
        battler.pbRecoverHP(battler.totalhp, true, fullrecover: true)
        if hpthreshold == 1
          if onBreakdata && onBreakdata[:thresholdmessage] && onBreakdata[:thresholdmessage] != ""
            battlerstring = onBreakdata[:thresholdmessage].start_with?("{1}") ? battler.pbThis : battler.pbThis(true)
            pbDisplay(_INTL(onBreakdata[:thresholdmessage], battlerstring))
          end
          @battle.pbShieldEffects(battler, onBreakdata, false, nil, true) if onBreakdata
          battler.reconstructAdmin if Rejuv
        else
          pbShieldEffects(battler, onBreakdata) if onBreakdata
          if battler.userSwitch != :BossEffect
            shieldCountChange = onBreakdata && onBreakdata[:shieldCountChange] ? onBreakdata[:shieldCountChange] : 1
            battler.shieldCount -= shieldCountChange
            @scene.pbUpdateShield(battler.shieldCount, battler.index)
          end
          @callingSOS = true if battler.sosDetails
        end
      end
      battler.pbFaint if battler.isFainted?
      battler.pbBerryHerbCheck
      battler.pbEmergencyExitCheck(oldhps[i])
    end
  end

  def inverse?
    return ($game_switches[:Inversemode] && !isOnline?) ^ (@field.effect == :INVERSE)
  end

  def illusionChoice(index, partyIndex)
    fullparty = pbPartySingleOwner(index)
    partyorder = pbIsOpposing?(index) ? @partyorder2 : @partyorder
    oi = pbGetOwnerIndex(index)
    illusionindex = partyorder[oi].find_all{ |pos| fullparty[pos] && !fullparty[pos].egg? && fullparty[pos].hp > 0 }.last
    return nil if illusionindex.nil?

    illusion = fullparty[illusionindex]
    return nil if illusion == fullparty[partyIndex] || illusionindex == partyIndex
    return illusion, illusionindex
  end

  # Ally Switch
  def swapBattlers(a, b)
    # Swap the battler positions
    @battlers[a], @battlers[b] = @battlers[b], @battlers[a]
    @battlers[a].index = a
    @battlers[b].index = b

    # Adjust choices
    @choices[a], @choices[b] = @choices[b], @choices[a]
    side = pbIsOpposing?(a) ? 1 : 0
    owner = pbGetOwnerIndex(a)
    if @zMove[side][owner] == a
      @zMove[side][owner] = b
    elsif @zMove[side][owner] == b
      @zMove[side][owner] = a
    end

    # Swap speed data
    @speedData[a], @speedData[b] = @speedData[b], @speedData[a]

    # Swap switched out data
    @switchedOut[a], @switchedOut[b] = @switchedOut[b], @switchedOut[a]

    # Swap AI data
    @ai.aimondata[a], @ai.aimondata[b] = @ai.aimondata[b], @ai.aimondata[a]
    @ai.aimondata[a].index = a
    @ai.aimondata[b].index = b

    # Swap effects that use index as value
    for i in @battlers
      for e in PokeBattle_Battler::PosEff
        if i.effects[e] == a
          i.effects[e] = b
        elsif i.effects[e] == b
          i.effects[e] = a
        end
      end
    end

    # Some effects are tied to the slot rather than the battler
    for e in PokeBattle_Battler::PermEff
      @battlers[a].effects[e], @battlers[b].effects[e] = @battlers[b].effects[e], @battlers[a].effects[e]
    end

    # Fix partyorder array
    partyorder = side == 1 ? @partyorder2[owner] : @partyorder[owner]
    partyorder[0], partyorder[1] = partyorder[1], partyorder[0]

    # Swap battlers visually
    @scene.swapBattlers(a, b)

    # Trigger pending Healing Wish and Lunar Dance
    healingWish(@battlers[a])
    healingWish(@battlers[b])
    lunarDance(@battlers[a])
    lunarDance(@battlers[b])
    zHeal(@battlers[a])
    zHeal(@battlers[b])
  end

  def healingWish(pkmn)
    return unless pkmn.effects[:HealingWish]
    unless [:FAIRYTALE, :STARLIGHT].include?(@field.effect)
      return if Gen >= 8 && pkmn.hp == pkmn.totalhp && pkmn.status.nil?
    end
    pkmn.pbRecoverHP(pkmn.totalhp, true, fullrecover: true) if pkmn.canHeal? # late message
    pkmn.healStatus
    if [:FAIRYTALE, :STARLIGHT].include?(@field.effect)
      pkmn.pbChangeStats(PBStats::Offensive, 1, pkmn, nil)
    end
    pbDisplay(_INTL("The healing wish came true for {1}!", pkmn.pbThis(true)))
    pkmn.effects[:HealingWish] = false
  end

  def lunarDance(pkmn)
    return unless pkmn.effects[:LunarDance]
    unless [:STARLIGHT, :NEWWORLD, :BIGTOP, :DANCEFLOOR].include?(@field.effect)
      return if Gen >= 8 && pkmn.hp == pkmn.totalhp && pkmn.status.nil? && pkmn.moves.none?{ |move| move && move.pp != move.totalpp }
    end
    pkmn.pbRecoverHP(pkmn.totalhp, true, fullrecover: true) if pkmn.canHeal? # late message
    pkmn.healStatus
    pkmn.moves.each { |move| move.pp = move.totalpp if move }
    if [:STARLIGHT, :NEWWORLD, :BIGTOP, :DANCEFLOOR].include?(@field.effect)
      stats = PBStats::Offensive if @field.effect == :STARLIGHT
      stats = PBStats::Omni if [:NEWWORLD, :BIGTOP, :DANCEFLOOR].include?(@field.effect)
      pkmn.pbChangeStats(stats, 1, pkmn, nil)
    end
    pbDisplay(_INTL("{1} became cloaked in mystical moonlight!", pkmn.pbThis))
    pkmn.effects[:LunarDance] = false
  end

  def zHeal(pkmn)
    return unless pkmn.effects[:ZHeal]
    return if Gen >= 8 && pkmn.hp == pkmn.totalhp
    pkmn.pbRecoverHP(pkmn.totalhp, false, message: _INTL("{1}'s HP was restored by the Z-Power!", pkmn.pbThis), fullrecover: true)
    pkmn.effects[:ZHeal] = false
  end
end

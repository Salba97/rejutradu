class PokeBattle_Battler
  attr_reader :battle
  attr_accessor :pokemon
  attr_accessor :originalpokemon # for accessing permanenteffects of AI fake battlers
  attr_reader :personalID
  attr_reader :name
  attr_accessor :index
  attr_accessor :pokemonIndex
  attr_reader :totalhp
  attr_accessor :fainted
  attr_reader :usingsubmove
  attr_reader :level
  attr_reader :statusCount
  attr_reader :hp
  attr_reader :item
  attr_reader :status
  attr_accessor :lastAttacker
  attr_accessor :turncount
  attr_accessor :effects
  attr_accessor :species
  attr_accessor :type1
  attr_accessor :type2
  attr_accessor :ability
  attr_accessor :gender
  attr_accessor :attack
  attr_accessor :defense
  attr_accessor :spatk
  attr_accessor :spdef
  attr_accessor :speed
  attr_accessor :baseExp
  attr_accessor :evYield
  attr_accessor :stages
  attr_accessor :iv
  attr_accessor :moves
  attr_accessor :zmoves
  attr_accessor :participants
  attr_accessor :lastHPLost
  attr_accessor :lastMoveUsed
  attr_accessor :lastRegularMoveUsed
  attr_accessor :lastRoundMoved
  attr_accessor :movesUsed
  attr_accessor :currentMove
  attr_accessor :damagestate
  attr_accessor :unburdened
  attr_accessor :selectedMove
  attr_accessor :wonderroom
  attr_accessor :itemUsed
  attr_accessor :itemUsed2 # Stays while the battler is out
  attr_accessor :userSwitch
  attr_accessor :forcedSwitch
  attr_accessor :forcedSwitchEarlier
  attr_accessor :vanished
  attr_accessor :moldbroken
  attr_accessor :sleeptalkUsed
  attr_accessor :missAcc
  attr_accessor :backupability
  attr_accessor :lastMoveChoice
  attr_accessor :isFirstMoveOfRound
  attr_accessor :crested
  attr_accessor :onBreakEffects # rejuv for boss system
  attr_accessor :onEntryEffects # rejuv for boss system
  attr_accessor :chargeAttack # rejuv for boss system
  attr_accessor :immunities # rejuv for boss system
  attr_accessor :capturable # rejuv for boss system
  attr_accessor :canrun # rejuv for boss system
  attr_accessor :delcrestparty
  attr_accessor :roll # currently only used in Deso for Crowd Field
  attr_accessor :tempBoosts # currently only used in Deso for Crowd Field
  attr_accessor :copyableStatBoosts # For Opportunist / Mirror Herb
  attr_accessor :applyingEntryEffects # Used to ensure field entry effects don't activate twice
  #boss mechanics
  attr_accessor :shieldCount
  attr_accessor :barGraphic
  attr_accessor :entryText
  attr_accessor :inspectText
  attr_accessor :sosDetails
  attr_accessor :randomSetChanges
  attr_accessor :shieldsBroken
  attr_accessor :shieldsBrokenThisTurn
  attr_accessor :currentSOS
  attr_accessor :reconstructcounter

  #v14 special mechanics
  attr_accessor :specialmoves
  attr_accessor :selectedSpecialMove
  attr_accessor :specialMoveUsed
  attr_accessor :fakeMove
  attr_accessor :fakeCrest
  attr_accessor :teraTypeEffect

  def inHyperMode?
    return false
  end

  def isShadow?
    return false
  end

  # simple true/false vars
  SwitchEff = [
    :AfterYou, :AquaRing, :BindingBand, :BeakBlast, :BurnUp, :CincCrest, :Commandee, :Commander, :Curse,
    :DefenseCurl, :DestinyBond, :DestinyRate, :Disguise, :DoubleShock, :Electrify, :Endure, :FairyLockRate,
    :FlashFire, :Flinch, :FollowMe, :Foresight, :GastroAcid, :GlaiveRush, :Grudge, :IceFace,
    :Imprison, :Ingrain, :Jealousy, :LashOut, :MagicCoat, :MeFirst, :Minimize,
    :MiracleEye, :Nightmare, :NoRetreat, :ParentalBond, :Powder, :MicleBerry, :EjectPack,
    :PowerTrick, :ProteanUsed, :QuickDrawSnipe, :Quash, :RagePowder, :Rage, :Roost, :SaltCure,
    :ShellTrap, :ShellTrapAttacked, :Shelter, :SkyDrop, :SmackDown, :Snatch, :Tantrum, :TarShot,
    :TeraShell, :Torment, :TracePending, :Truant, :TyphBond, :UsingSubstituteRightNow,
    :TypeGemActivated, :TypeBerryActivated, :DelaySymbiosis, :UseCharge,
    :Pursuiter, :Pursuitee, :CheckLandCriticalEvo, :CoalFurnace, :WeatherProtection,
  ]

  # turn count vars
  TurnEff = [
    :Bide, :Charge, :Confusion, :Disable, :Embargo, :Encore,
    :FuryCutter, :HealBlock, :HyperBeam, :LaserFocus, :LockOn, :MagnetRise,
    :Metronome, :MultiTurn, :Outrage, :PerishSong, :Taunt, :Telekinesis,
    :ThroatChop, :Toxic, :Uproar, :Yawn, :TwoTurnAttack, :ChthonicMalady,
    :SlowStart, :CudChewTurns, :SyrupBombTurns,
  ]

  # position vars
  PosEff = [
    :Attract, :BideTarget, :LeechSeed, :LockOnTarget, :MeanLook, :MirrorCoatTarget, :CounterTarget,
    :MultiTurnUser, :Octolock, :Petrification, :FutureSightUserIndex, :PerishSongUser, :SyrupBombUser,
    :SwampWeb,
  ]

  # other counter vars
  CountEff = [
    :BideDamage, :Damage, :FocusEnergy, :ProtectRate, :Rollout, :EchoedVoice, :SpeedSwap,
    :Stockpile, :StockpileDef, :StockpileSpDef, :Substitute, :SupremeOverlord, :WeightModifier, :Counter, :MirrorCoat,
    :AllySwitchRate, :HelpingHand, :SurgingBlessing,
  ]

  # weirdo shit (usually move objects)
  OtherEff = [
    :ChoicedMove, :DisableMove, :EncoreMove, :MagicBounce, :Protect, :BouncedMove, :ZoroCrest,
    :TemporaryType, :Transform, :ReflectorTypes, :CudChewBerry, :PowerHerb, :ShownBaseStats # :TwoTurnAttack
  ]

  BatonEff = [
    :AquaRing, :Confusion, :Curse, :Embargo, :FocusEnergy, :LaserFocus,
    :GastroAcid, :HealBlock, :Ingrain, :LeechSeed, :Shelter, :MagnetRise,
    :PerishSong, :PerishSongUser, :PowerTrick, :Substitute, :Telekinesis, :MeanLook,
  ]

  PermEff = [
    :FutureSight, :FutureSightMove, :FutureSightUserIndex, :FutureSightPokemon,
    :HealingWish, :LunarDance, :Wish, :WishAmount, :WishMaker, :ZHeal,
  ]

  # :VespiCrest and :Illusion are not included here

  ################################################################################
  # Complex accessors
  ################################################################################
  def nature
    return @pokemon ? @pokemon.nature : 0
  end

  def ev
    return @pokemon ? @pokemon.ev : 0
  end

  def happiness
    return @pokemon ? @pokemon.happiness : 0
  end

  def pokerusStage
    return @pokemon ? @pokemon.pokerusStage : 0
  end

  # Gender methods -- @pokemon is not used so as to respect Transform-changed genders
  def isMale?
    return self.gender == :M
  end

  def isFemale?
    return self.gender == :F
  end

  def isGenderless?
    return self.gender == :N
  end

  def getCacheData
    return @pokemon ? @pokemon.getCacheData : nil
  end

  attr_reader :form

  def form=(value)
    @effects[:TemporaryType] = nil if @form != value
    @form = value
    # Avoid nonexistent Ditto / Mew form when AI makes a battler clone of one transformed into a non-0 form of another mon.
    @pokemon.form = value if @pokemon && !self.effects[:Transform]
  end

  # Performs form change but also registers the new form in pokedex.
  # Should not be used by AI.
  def changeForm(value)
    @effects[:TemporaryType] = nil if @form != value
    @form = value
    @pokemon.changeForm(value) if @pokemon
  end

  def name=(value)
    @name = value
  end

  def type1=(value)
    @type1 = value
    @effects[:clearDisguise].type1 = value if @effects[:clearDisguise] && @effects[:clearDisguise] != self
    @effects[:Illusion].type1 = value if @effects[:Illusion] && !@effects[:clearDisguise] && @effects[:Illusion] != self
  end

  def type2=(value)
    @type2 = value
    @effects[:clearDisguise].type1 = value if @effects[:clearDisguise] && @effects[:clearDisguise] != self
    @effects[:Illusion].type2 = value if @effects[:Illusion] && !@effects[:clearDisguise] && @effects[:Illusion] != self
  end

  def types(excludeReflector: false)
    if excludeReflector
      return [@type1, @type2, @effects[:TemporaryType]].filter{ |item| !item.nil? }.uniq
    else
      return [@type1, @type2, @effects[:TemporaryType], *@effects[:ReflectorTypes]].filter{ |item| !item.nil? }.uniq
    end
  end

  def canChangeType?
    return false if [:MULTITYPE, :RKSSYSTEM].include?(self.ability)
    return false if self.crested == :SILVALLY && self.item != :DARKMEMORY
    return false if self.isTerastallized?
    return true
  end

  def changeType(*types)
    self.type1 = types[0]
    self.type2 = types[1] # Usually will be nil
    @effects[:TemporaryType] = types[2] # Usually will be nil
  end

  def visiblePokemon(cry = false)
    if cry == true
      return self.pokemon if @effects[:clearDisguise]
    else
      return @effects[:clearDisguise].pokemon if @effects[:clearDisguise]
    end

    return @effects[:Illusion].pokemon if @effects[:Illusion]
    return @effects[:Transform] if @effects[:Transform]
    return @pokemon
  end

  def hasMega?
    if @pokemon
      return (@pokemon.hasMegaForm? rescue false)
    end

    return false
  end

  def hasUltra?
    if @pokemon
      return (@pokemon.hasUltraForm? rescue false)
    end

    return false
  end

  def hasTera?
    if @pokemon
      return (@pokemon.hasTeraForm? rescue false)
    end

    return false
  end

  def hasCrest?(species = self.species)
    return false if !Rejuv
    return false if self.pbOwnSide.effects[:PsyBlades] == true

    return true if $PokemonBag.pbQuantity(:SILVCREST) > 0 && species == :SILVALLY && @battle.pbOwnedByPlayer?(@index)
    return true if self.item == :GOLDENAPPLE && [:PANGORO, :ZORUA].include?(species)
    return true if @battle.pbGetOwnerItems(@index).include?(:SILVCREST) && species == :SILVALLY && !@battle.pbOwnedByPlayer?(@index)
    return false if !self.item || !$cache.items[self.item].checkFlag?(:crest)
    return false if species == :DARMANITAN && ![0, 1].include?(self.form)
    return false if [:TYPHLOSION, :SAMUROTT, :ELECTRODE].include?(species) && self.form != 0
    return false if species == :AMPHAROS && self.form != 1

    return PBStuff::POKEMONTOCREST[species] == self.item
  end

  def chargeAttackRequirementMet?
    return false if !self.isbossmon
    return false if !self.chargeAttack

    requirementMet = self.chargeAttack[:shieldCountRequirement] ? eval(self.chargeAttack[:shieldCountRequirement]) : true
    return requirementMet
  end

  def chargeTurns?
    return false if !Rejuv
    return false if !self.isbossmon

    if self.chargeAttack
      chargeAttack = self.chargeAttack
      return true if chargeAttack[:canAttack] && chargeAttack[:canAttack] == false
      return false if self.permeffs[:ChargeAttackCountdown] % chargeAttack[:turns] == 0 && chargeAttack[:continueCharging]
      return false if self.permeffs[:ChargeAttackCountdown] > chargeAttack[:turns] && !chargeAttack[:continueCharging]

      return true
    end
    return false
  end

  def pbZCrystalFromType(type)
    return PBStuff::TYPETOZCRYSTAL[type]
  end

  def hasZMove?
    return false if @zmoves.nil?
    return false if !@zmoves.any?
    return false if @item == :ULTRANECROZIUMZ && !(@species == :NECROZMA && @form == 3)

    return true
  end

  def pbUpdateDynamicZMoves
    for i in 0...4
      pbUpdateDynamicZMove(i)
    end
  end

  def pbUpdateDynamicZMove(moveindex)
    return false if self.item == :INTERCEPTZ || @zmoves.nil?

    if @zmoves[moveindex] && [0x087, 0x312].include?(@moves[moveindex].function) # Weather Ball, Terrain Pulse
      type = @moves[moveindex].pbType(self)
      type = @moves[moveindex].type unless PBStuff::TYPETOZCRYSTAL[type]

      if PBStuff::TYPETOZCRYSTAL[type]
        transformedMove = PBMove.new($cache.items[PBStuff::TYPETOZCRYSTAL[type]].zmove)
        @zmoves[moveindex] = PokeBattle_Move.pbFromPBMove(@battle, transformedMove, self.pokemon, @moves[moveindex])
        return true
      end
    end

    return false
  end

  def pbCompatibleZMoveFromMove?(move, moveindex = false)
    pkmn = self
    return true if pkmn.effects[:IgnoreZflag]

    move = pkmn.moves[move] if moveindex
    zmove = $cache.items[pkmn.item]&.zmove
    return false unless zmove
    return true if pkmn.item == :INTERCEPTZ

    zmovedata = $cache.moves[zmove].zmovedata
    return true if zmovedata.type == move.type
    return true if zmovedata.basemove == move.move
    return false
  end

  def isMega?
    if @pokemon
      return (@pokemon.isMega? rescue false)
    end

    return false
  end

  def isUltra?
    if @pokemon
      return (@pokemon.isUltra? rescue false)
    end

    return false
  end

  def isPrimal?
    if @pokemon
      return (@pokemon.isPrimal? rescue false)
    end

    return false
  end

  def isTerastallized?
    if @pokemon
      return (@pokemon.isTerastallized? rescue false)
    end

    return false
  end

  def isStellarTerapagos?
    return @pokemon&.isStellarTerapagos?
  end

  def isWildPokemon?
    return @battle.pbIsWild? && @battle.pbIsOpposing?(self.index)
  end

  def isUntransformableForm?
    if @pokemon
      return (@pokemon.isUntransformableForm? rescue false)
    end

    return false
  end

  def level=(value)
    @level = value
    @pokemon.level = value if @pokemon
  end

  def status=(value)
    if @status == :SLEEP && value.nil?
      @effects[:Truant] = false
    end
    if @status == :PETRIFIED && value.nil?
      if self.effects[:Substitute] == 0
        @battle.scene.pbUnSubstituteSprite(self)
      else
        @battle.scene.pbSubstituteSprite(self)
      end
    end
    @status = value
    @pokemon.status = value if @pokemon
    if value != :POISON
      @effects[:Toxic] = 0
    end
    if value != :POISON && value != :SLEEP
      @statusCount = 0
      @pokemon.statusCount = 0 if @pokemon
    end
    if value != :SLEEP
      self.permeffs[:SleptTurns] = nil
    end
  end

  def statusCount=(value)
    @statusCount = value
    @pokemon.statusCount = value if @pokemon
  end

  def healStatus
    self.status = nil
    self.statusCount = 0
  end

  def hp=(value)
    @hp = value.to_i
    @pokemon.hp = value.to_i if @pokemon
  end

  def totalhp=(value) # Needed for the AI
    @totalhp = value.to_i
    @pokemon.totalhp = value.to_i if @pokemon
  end

  def item=(value)
    @unburdened = true if @ability == :UNBURDEN && @item && value.nil?
    @item = value
    @pokemon.item = value if @pokemon
  end

  def weight
    w = @weight
    w += @effects[:WeightModifier]
    w *= 2 if self.ability == :HEAVYMETAL && !self.moldbroken
    w /= 2 if self.ability == :LIGHTMETAL && !self.moldbroken
    w /= 2 if self.hasWorkingItem(:FLOATSTONE)
    w *= 2 if @battle.FE == :DEEPEARTH
    w = 1 if w < 1
    return w
  end

  def isbossmon
    return @pokemon ? @pokemon.isbossmon : false
  end

  def issosmon
    return @pokemon ? @pokemon.sosmon : false
  end

  def ownedstate
    return false if !@pokemon || @battle.opponent || @pokemon.getCacheData.checkFlag?(:ExcludeDex)
    return 2 if $Trainer.pokedex.meaningful_owned?(@pokemon.species, @pokemon.form) # owned form
    return 1 if $Trainer.pokedex.owned?(@pokemon.species) # owned species but not form
    return false
  end

  def permeffs
    pokemon = @originalpokemon || @pokemon # originalpokemon is set only for AI fake battlers
    return @battle.permanenteffects[pokemon]
  end

  def piece
    return self.permeffs[:Piece]
  end

  ################################################################################
  # Creating a battler
  ################################################################################
  def initialize(btl, index, fakebattler = false)
    @battle       = btl
    @index        = index
    @fainted      = true
    @usingsubmove = false
    @damagestate  = PokeBattle_DamageState.new
    @unburdened   = false
    @wonderroom   = false
    @userSwitch   = nil
    @endTurn      = false
    @forcedSwitch = false
    @forcedSwitchEarlier = false
    @vanished     = false
    @moldbroken   = false
    @missAcc      = false
    @tempBoosts = [0, 0, 0, 0, 0, 0] # crowd field temp boosts
    @capturable = false
    @copyableStatBoosts = Hash.new(0)

    # blank values
    @name         = ""
    @species      = 0
    @level        = 0
    @hp           = 0
    @totalhp      = 0
    @gender       = 0
    @ability      = 0
    @type1        = 0
    @type2        = 0
    @form         = 0
    @attack       = 0
    @defense      = 0
    @speed        = 0
    @spatk        = 0
    @spdef        = 0
    @baseExp      = 0
    @evYield      = [0, 0, 0, 0, 0, 0]
    @status       = nil
    @statusCount  = 0
    @pokemon      = nil
    @pokemonIndex = -1
    @participants = []
    @moves        = []
    @zmoves       = nil
    @specialmoves = nil
    @iv           = [0, 0, 0, 0, 0, 0]
    @item         = nil
    @weight       = 0

    pbInitEffects(fakebattler: fakebattler)
  end

  def pbInitPokemon(pkmn, pkmnIndex)
    if pkmn.isEgg?
      raise _INTL("An egg can't be an active Pokémon")
    end

    if !@effects.nil?
      if @effects[:MaliciousMoth] != -1
        @effects[:MaliciousMoth] = -1 if @item == :BLACKLANTERN
      end
    end

    @name         = pkmn.name
    @species      = pkmn.species
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @gender       = pkmn.gender
    @ability      = pkmn.ability
    @backupability = pkmn.ability
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    @form         = pkmn.form
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @speed        = pkmn.speed
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @baseExp      = pkmn.baseExp
    @evYield      = pkmn.evYield
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
    @personalID   = pkmn.personalID
    @pokemon      = pkmn
    @pokemonIndex = pkmnIndex
    @fainted      = false
    @participants = [] # Participants will earn Exp. Points if this battler is defeated
    @moves        = []
    for move in pkmn.moves
      @moves.push(PokeBattle_Move.pbFromPBMove(@battle, move, pkmn)) if move
    end

    if !pkmn.zmoves.nil?
      @zmoves = [nil, nil, nil, nil]
      for i in 0...pkmn.zmoves.length
        zmove = pkmn.zmoves[i]
        @zmoves[i] = PokeBattle_Move.pbFromPBMove(@battle, zmove, pkmn, @moves[i]) if !zmove.nil?
      end
    else
      @zmoves = nil
    end
    @iv           = pkmn.iv
    @item         = pkmn.item
    @weight       = pkmn.weight
    @fakeCrest = false
    @teraTypeEffect = nil
    if self.hasCrest?(@species)
      @crested = @species == :ZORUA ? :ZOROARK : @species
    else
      @crested = false
    end
    @entryText = nil
    @delcrestparty = nil
    crestStats if @crested

    if Rejuv
      @battle.ai.aimondata[index].skill = 100 if pkmn.isbossmon && !pkmn.sosmon
      if !@pokemon.prismPower
        @pokemon.prismPower = false
      end
      if @battle.specialmoves.length > 0
        @specialmoves = Array.new(@battle.specialmoves.length) {nil}
        for i in 0..@battle.specialmoves.length
          break if i>=7
          @specialmoves[i] = PokeBattle_Move.pbFromPBMove(@battle, PBMove.new(@battle.specialmoves[i]), pkmn, nil) if !@battle.specialmoves[i].nil?

        end
      else
        @specialmoves = []
      end
    end
  end

  def pbInitEffects(batonpass: false, faint: false, fakebattler: false)
    oldeffects = @effects.nil? ? nil : @effects.clone

    # effects
    @effects = {}
    # bulk effects
    SwitchEff.each { |eff| @effects[eff] = false }
    TurnEff.each { |eff| @effects[eff] = 0 }
    PosEff.each { |eff| @effects[eff] = -1 }
    CountEff.each { |eff| @effects[eff] = 0 }
    OtherEff.each { |eff| @effects[eff] = nil }
    if !oldeffects.nil?
      PermEff.each { |eff| @effects[eff] = oldeffects[eff] }
    else
      @effects[:FutureSight]       = 0
      @effects[:FutureSightMove]   = nil
      @effects[:FutureSightUserIndex] = -1
      @effects[:FutureSightPokemon] = nil
      @effects[:HealingWish]       = false
      @effects[:LunarDance]        = false
      @effects[:Wish]              = 0
      @effects[:WishAmount]        = 0
      @effects[:WishMaker]         = -1
      @effects[:ZHeal]             = false
    end
    @effects[:ReflectorTypes]   = []
    @effects[:Quarkdrive]       = [0, false] # stat, booster energy
    @effects[:Protosynthesis]   = [0, false] # stat, booster energy
    @effects[:Disguise]         = self.species == :MIMIKYU && self.form == 0 # Mimikyu
    @effects[:IceFace]          = self.species == :EISCUE && self.form == 0 # Eiscue

    clearDisguise = Rejuv ? self.pokemon&.disguise : nil
    if clearDisguise && !faint && !fakebattler
      disguiseBattler = @battle.ai.pbMakeFakeBattler(clearDisguise.clone, self.pokemonIndex, false, self.index)
      disguiseBattler.effects[:Illusion] = nil if disguiseBattler.effects[:Illusion]
      @effects[:clearDisguise] = disguiseBattler
      @effects[:clearDisguise].form = clearDisguise.form.clone
      @effects[:clearDisguise].effects = @effects
      @effects[:clearDisguise].stages = @stages
      @effects[:clearDisguise].item = clearDisguise.item.clone
      disguisedMoves = clearDisguise.moves.clone

      for i in 0...disguisedMoves.length
        @effects[:clearDisguise].pokemon.moves[i] = disguisedMoves[i] if !disguisedMoves[i].nil?
        disguisedMoves[i] = PokeBattle_Move.pbFromPBMove(@battle, disguisedMoves[i], self.pokemon, nil) if !disguisedMoves[i].nil?
      end
      @effects[:clearDisguise].moves = disguisedMoves
      if pbIsZCrystal?(self.item)
        @effects[:clearDisguise].pokemon.initZmoves(@effects[:clearDisguise].item)
      end
      if !@effects[:clearDisguise].pokemon.zmoves.nil?
        @effects[:clearDisguise].zmoves = [nil, nil, nil, nil]
        for i in 0...@effects[:clearDisguise].pokemon.zmoves.length
          zmove = @effects[:clearDisguise].pokemon.zmoves[i]
          @effects[:clearDisguise].zmoves[i] = PokeBattle_Move.pbFromPBMove(@battle, zmove, @effects[:clearDisguise].pokemon, @effects[:clearDisguise].moves[i]) if !zmove.nil?
        end
      else
        @effects[:clearDisguise].zmoves = nil
      end
      @effects[:ZoroCrest] = @effects[:clearDisguise] if self.crested == :ZOROARK
    end

    self.permeffs[:LastUsedIllusionIndex] = nil
    if (self.ability == :ILLUSION || self.crested == :ZOROARK) && !clearDisguise && !faint
      illusion, illusionindex = @battle.illusionChoice(self.index, self.pokemonIndex)
      if !illusion.nil?
        @effects[:Illusion] = @battle.ai.pbMakeFakeBattler(illusion.clone, illusionindex, false, @index)
        @effects[:ZoroCrest] = @effects[:Illusion] if self.crested == :ZOROARK
        @effects[:Illusion].form = illusion.form.clone
        @effects[:Illusion].effects = @effects
        @effects[:Illusion].stages = @stages
        self.permeffs[:LastUsedIllusionIndex] = illusionindex unless fakebattler
      end
    end

    # non-effects
    @damagestate.reset
    @lastAttacker         = -1
    @lastHPLost           = 0
    @lastMoveUsed         = -1
    @lastRegularMoveUsed  = -1
    @specialMoveUsed      = false
    @lastRoundMoved       = -1
    @itemUsed             = false
    @itemUsed2            = false
    @wonderroom           = false
    @movesUsed            = []
    @turncount            = 0
    @roll                 = 0 # crowd field stat roll
    @onField              = true

    # stuff for other battlers???
    for i in @battle.battlers
      next if !i || fakebattler

      if i.effects[:MultiTurnUser] == @index
        i.effects[:MultiTurn] = 0
        i.effects[:MultiTurnUser] = -1
        i.effects[:BindingBand] = false
      end
      if i.effects[:MeanLook] == @index
        i.effects[:MeanLook] = -1
        i.effects[:SwampWeb] = -1
      end
      i.effects[:Attract] = -1 if i.effects[:Attract] == @index
      i.effects[:Octolock] = -1 if i.effects[:Octolock] == @index
      if i.effects[:SyrupBombUser] == @index
        i.effects[:SyrupBombTurns] = 0
        i.effects[:SyrupBombUser] = -1
      end
    end
    if oldeffects
      @effects[:MaliciousMoth] = (oldeffects[:MaliciousMoth] >= 0 && @item != :BLACKLANTERN) ? 2 : -1
    else
      @effects[:MaliciousMoth] = -1
    end
    if batonpass
      if oldeffects[:PowerTrick]
        self.attack, self.defense = self.defense, self.attack
        @effects[:PowerTrick] = oldeffects[:PowerTrick]
      end
      BatonEff.each { |eff| @effects[eff] = oldeffects[eff] }
    else
      @stages = Array.new(8, 0) # Seven stats (0 is blank) with no stages
    end

    if @battle.state.effects[:WonderRoom] > 0
      pbSwapDefenses if !@wonderroom
    end
    unless fakebattler
      @battle.battlers.each { |i| i.pbResetLockOn if i.effects[:LockOnTarget] == @index }
    end
  end

  # noability is used in pbCheckWeatherForm so as to prevent an infinite loop between that and changeAbility
  # ai is used when pbUpdate is called by the AI so as to suppress the battle processing parts of changeAbility
  def pbUpdate(fullchange = false, noability: false, fakebattler: false, deevolution: false)
    return if !@pokemon

    @pokemon.calcStats
    @level     = @pokemon.level
    @hp        = @pokemon.hp
    @totalhp   = @pokemon.totalhp
    return if @effects[:Transform]

    @attack    = @pokemon.attack
    @defense   = @pokemon.defense
    @speed     = @pokemon.speed
    @spatk     = @pokemon.spatk
    @spdef     = @pokemon.spdef
    crestStats if @crested
    @spdef, @defense = @defense, @spdef if @wonderroom
    return if !fullchange

    @baseExp   = @pokemon.baseExp
    @evYield   = @pokemon.evYield
    @type1   = @pokemon.type1
    @type2   = @pokemon.type2

    unless (noability || @crested == :SILVALLY || @crested == :ZOROARK) && deevolution == false
      oldability, newability = self.changeAbility(@pokemon.ability)
      self.pbEffectsOnAbilityChange(oldability, newability) unless fakebattler
    end
  end

  def pbInitBoss(pkmn, index)
    bossdata = $cache.bosses
    boss = bossdata[pkmn.bossID]
    if boss.immunities
      @immunities = {
        :moves => [],
        :fieldEffectDamage => [],
      }
      immunitiesarray = []
      if boss.immunities[:moves]
        for i in boss.immunities[:moves]
          immunitiesarray.push(i)
        end
      end
      @immunities[:moves] = immunitiesarray
      immunitiesarray = []
      if boss.immunities[:fieldEffectDamage]
        for i in boss.immunities[:fieldEffectDamage]
          immunitiesarray.push(i)
        end
      end
      @immunities[:fieldEffectDamage] = immunitiesarray
    else
      @immunities = {
        :moves => [],
        :fieldEffectDamage => [],
      }
    end
    @onBreakEffects = boss.onBreakEffects
    @onEntryEffects = boss.onEntryEffects
    @barGraphic = boss.barGraphic
    @entryText = boss.entryText ? boss.entryText : nil
    @inspectText = boss.inspectText ? boss.inspectText : nil
    @battle.doublebattle = true if boss.doublebattle
    if boss.chargeAttack
      @chargeAttack = {}
      boss.chargeAttack.each do |key, value|
        @chargeAttack[key] = value
      end
    else
      @chargeAttack = nil
    end
    if boss.sosDetails
      @sosDetails = {}
      boss.sosDetails.each do |key, value|
        @sosDetails[key] = value
      end
    else
      @sosDetails = nil
    end
    if boss.randomSetChanges
      @randomSetChanges = {}
      boss.randomSetChanges.each do |key, value|
        @randomSetChanges[key] = value
      end
    else
      @randomSetChanges = nil
    end
    @name = boss.name unless boss.name == ""
    @shieldCount = pkmn.shieldCount || 0
    @reconstructcounter = 0
    @shieldsBroken = Array.new(@shieldCount, false)
    @shieldsBrokenThisTurn = [0, 0, 0, 0]
    @currentSOS = 0
    self.permeffs[:ChargeAttackCountdown] = 0
    @battle.typesequence = 0
    @battle.callingSOS = false
    @capturable = boss.capturable ? boss.capturable : false
    @canrun = boss.canrun ? boss.canrun : false
    @battle.cantescape = true if !@canrun
  end

  def pbInitialize(pkmn, index, batonpass)
    # Cure status of previous Pokemon with Natural Cure
    if self.ability == :NATURALCURE && @pokemon
      self.healStatus
    end
    if self.ability == :REGENERATOR && @pokemon && @hp > 0 && self.status != :PETRIFIED
      self.pbRecoverHP((self.totalhp / 3.0).floor, false, false) # Healing isn't shown on HP bar before switching
    end
    if self.ability == :ZEROTOHERO
      self.pbHeroTransform
    end
    pbInitPokemon(pkmn, index)
    pbInitEffects(batonpass: batonpass)
    pbInitBoss(pkmn, index) if self.isbossmon
  end

  # Used only to erase the battler of a Shadow Pokémon that has been snagged.
  def pbReset
    @pokemon                = nil
    @pokemonIndex           = -1
    self.hp                 = 0
    pbInitEffects
    # reset status
    self.status             = 0
    self.statusCount        = 0
    @fainted                = true
    # reset choice
    @battle.choices[@index] = [nil]
    @battle.specialchoices[index] = [nil]
    return true
  end

  # Update Pokémon who will gain EXP if this battler is defeated
  def pbUpdateParticipants
    return if self.isFainted? # can't update if already fainted
    return unless @battle.pbIsOpposing?(@index) # player gets EXP only from opposing pokemon

    for i in [self.pbOpposing1, self.pbOpposing2]
      if !i.isFainted? && @battle.pbBelongsToPlayer?(i.index)
        @participants.push(i.pokemonIndex) unless @participants.include?(i.pokemonIndex)
      end
    end
  end

  def arceusSilvallyFormFromItem
    if @species == :SILVALLY
      case @item
        when :FIGHTINGMEMORY    then return 1
        when :FLYINGMEMORY      then return 2
        when :POISONMEMORY      then return 3
        when :GROUNDMEMORY      then return 4
        when :ROCKMEMORY        then return 5
        when :BUGMEMORY         then return 6
        when :GHOSTMEMORY       then return 7
        when :STEELMEMORY       then return 8
        when :GLITCHMEMORY      then return 9
        when :FIREMEMORY        then return 10
        when :WATERMEMORY       then return 11
        when :GRASSMEMORY       then return 12
        when :ELECTRICMEMORY    then return 13
        when :PSYCHICMEMORY     then return 14
        when :ICEMEMORY         then return 15
        when :DRAGONMEMORY      then return 16
        when :DARKMEMORY        then return 17
        when :FAIRYMEMORY       then return 18
        else return 0
      end
    elsif @species == :ARCEUS
      case @item
        when :FISTPLATE, :FIGHTINIUMZ    then return 1
        when :SKYPLATE, :FLYINIUMZ       then return 2
        when :TOXICPLATE, :POISONIUMZ    then return 3
        when :EARTHPLATE, :GROUNDIUMZ    then return 4
        when :STONEPLATE, :ROCKIUMZ      then return 5
        when :INSECTPLATE, :BUGINIUMZ    then return 6
        when :SPOOKYPLATE, :GHOSTIUMZ    then return 7
        when :IRONPLATE, :STEELIUMZ      then return 8
        when :FLAMEPLATE, :FIRIUMZ       then return 10
        when :SPLASHPLATE, :WATERIUMZ    then return 11
        when :MEADOWPLATE, :GRASSIUMZ    then return 12
        when :ZAPPLATE, :ELECTRIUMZ      then return 13
        when :MINDPLATE, :PSYCHIUMZ      then return 14
        when :ICICLEPLATE, :ICIUMZ       then return 15
        when :DRACOPLATE, :DRAGONIUMZ    then return 16
        when :DREADPLATE, :DARKINIUMZ    then return 17
        when :PIXIEPLATE, :FAIRIUMZ      then return 18
        else return 0
      end
    end
  end

  ################################################################################
  # About this battler
  ################################################################################
  def pbThis(lowercase = false)
    if @battle.pbIsOpposing?(@index)
      if @battle.opponent || self.issosmon
        return lowercase ? _INTL("the foe's {1}", self.name) : _INTL("The foe's {1}", self.name)
      elsif self.isbossmon && !(Rejuv && @pokemon.bossID == :SHADOWDEN)
        return self.name
      else
        return lowercase ? _INTL("the wild {1}", self.name) : _INTL("The wild {1}", self.name)
      end
    elsif @battle.pbOwnedByPlayer?(@index)
      return self.name
    else
      return lowercase ? _INTL("the ally {1}", self.name) : _INTL("The ally {1}", self.name)
    end
  end

  def name
    return @effects[:clearDisguise].name if @effects[:clearDisguise] && @effects[:clearDisguise] != self
    return @effects[:Illusion] && @effects[:Illusion] != self ? @effects[:Illusion].name : @name
  end

  def logname # Used by AI
    # Species names ignore Illusion
    name = getMonName(@species)
    if @battle.battlers.any? { |battler| battler.index != @index && !battler.isFainted? && battler.realspecies == @species }
      name += " [#{@index}]"
    end
    return name
  end

  def ttsname
    name = self.name
    dupes = @battle.battlers.find_all { |battler| battler.index != @index && !battler.isFainted? && battler.name == self.name }
    if dupes.any? { |dupe| @battle.pbGetOwner(dupe.index) != @battle.pbGetOwner(@index) }
      name = self.isWildPokemon? ? _INTL("Wild {1}", self.name) : _INTL("{1}'s {2}", @battle.pbGetOwner(@index).name, self.name)
    end
    if dupes.any? { |dupe| @battle.pbGetOwner(dupe.index) == @battle.pbGetOwner(@index) }
      name += " (" + ([0, 3].include?(@index) ? _INTL("Left") : _INTL("Right")) + ")"
    end
    return name
  end

  def species
    return @effects[:clearDisguise].species if @effects[:clearDisguise] && @effects[:clearDisguise] != self
    return @effects[:Illusion] && @effects[:Illusion] != self ? @effects[:Illusion].species : @species
  end

  def realspecies
    return @species
  end

  def hasType?(type)
    return self.types.include?(type)
  end

  def pbHasMove?(*moves)
    known = []
    for i in @moves
      next if i.nil?
      known.push i.move
    end
    return known.intersect?(moves)
  end

  def pbHasMoveFunction?(*codes)
    return @moves.any? {|move| move && codes.include?(move.function)}
  end

  def hasMovedThisRound?
    return false if !@lastRoundMoved

    return @lastRoundMoved == @battle.turncount
  end

  def acted?
    return true if self.hasMovedThisRound?
    return true if @itemUsed
    return true if @battle.switchedOut[@index]

    return false
  end

  def movingLast?(analytic: false)
    order = @battle.moveOrder.reject { |battler| (battler.isFainted? && !analytic) || battler.acted? }
    return order.one? && order.first == self
  end

  def isFainted?
    return @hp <= 0
  end

  def isFaintedAndNoShields?
    return isFainted? && !(isbossmon && @shieldCount > 0)
  end

  def passiveAbilityApplies? # Should abilities like Intimidate even try to affect this mon?
    return @onField && !isFaintedAndNoShields?
  end

  # i am leaving them here but both of the next 2 methods are depreciated, don't use them
  # they checks things we handle entirely differently now, so all they do is add
  # tiny bits of extra processing work when called, for no gain - Falirion
  def abilityWorks?(ignorefainted: false)
    return false if self.isFainted? && !ignorefainted
    return false if @effects[:GastroAcid]
    if !(PBStuff::FIXEDABILITIES + [:NEUTRALIZINGGAS]).include?(@ability)
      return false if @battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS) && !self.hasWorkingItem(:ABILITYSHIELD)
    end

    return true
  end

  def hasWorkingAbility(ability, ignorefainted: false)
    return false if !self.abilityWorks?(ignorefainted: ignorefainted)
    return @ability == ability
  end

  def itemWorks?(ignorefainted: false, ignorenoitem: false)
    return false if self.isFainted? && !ignorefainted
    return false if @item.nil? && !ignorenoitem
    return false if self.pbOwnSide.effects[:PsyBlades] == true
    return true if pbIsCrest?(@item) && !ignorenoitem

    return false if @effects[:Embargo] > 0
    return false if @battle.state.effects[:MagicRoom] > 0
    return false if self.ability == :KLUTZ && (ignorenoitem || @item != :ABILITYSHIELD)
    return true
  end

  def hasWorkingItem(item, ignorefainted: false)
    return false if !self.itemWorks?(ignorefainted: ignorefainted)
    return @item == item
  end

  def isAirborne?(moldbreakcheck: false, magnetRiseElectricTerrain: false, celestialIdolPsychicTerrain: false)
    return false if self.hasWorkingItem(:IRONBALL) && @battle.FE != :DEEPEARTH
    return false if @effects[:Ingrain]
    return false if @effects[:SmackDown]

    if !moldbreakcheck || !self.moldbroken
      return true if self.ability == :GRAVITYCONTROL
      return true if [:MAGNETPULL, :CONTRARY, :UNAWARE, :OBLIVIOUS].include?(self.ability) && @battle.FE == :DEEPEARTH
    end
    return false if @battle.state.effects[:Gravity] != 0
    return true if self.hasType?(:FLYING) && @effects[:Roost] == false

    if !moldbreakcheck || !self.moldbroken
      return true if PBStuff::LevitateAbilities.include?(self.ability) && !([:SOLARIDOL, :LUNARIDOL].include?(self.ability) && celestialIdolPsychicTerrain)
    end
    return true if self.hasWorkingItem(:AIRBALLOON)
    return true if @effects[:MagnetRise] > 0 && !magnetRiseElectricTerrain
    return true if @effects[:Telekinesis] > 0

    return false
  end

  def isSemiInvul?
    return PBStuff::SEMIINVULMOVE.include?(self.effects[:TwoTurnAttack]) || self.effects[:SkyDrop]
  end

  def isSleeping?
    return true if self.status == :SLEEP
    return true if self.ability == :COMATOSE && @battle.FE != :ELECTERRAIN
    return false
  end

  def canHeal?
    return false if @effects[:HealBlock] != 0
    return false if self.status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, self).none? && self.crested != :SUICUNE
    return false if self.hp == self.totalhp
    return true
  end

  def canLastResort?
    unusedMove = false
    knowsAnotherMove = false
    knowsLastResort = false
    for i in @moves
      next if i.nil? || i.move.nil?
      if i.function == 0x125
        knowsLastResort = true
        next
      end
      knowsAnotherMove = true
      unusedMove = true unless @movesUsed.include?(i.move) || @battle.FE == :DARKNESS1 || @battle.OV == :DARKNESS2
    end
    return knowsLastResort && knowsAnotherMove && !unusedMove
  end

  def pbSpeed()
    return @speed if self.isFainted? # Relevant for sendout order of faint replacements

    speed = @effects[:SpeedSwap] != 0 ? @effects[:SpeedSwap] : @speed
    stage = @stages[PBStats::SPEED] + 6
    speed = (speed * PBStats::StageMul[stage]).floor
    speed *= 2 if self.pbOwnSide.effects[:Tailwind] > 0
    if @unburdened
      # AI battlers yet to switch in are allowed to have the unburdened flag while having an item
      if (self.ability != :UNBURDEN || self.item != nil) && @battle.battlers.include?(self)
        @unburdened = false
      else
        speed *= 2
      end
    end

    # Abilities and crests
    speed *= 2   if self.swiftSwimActive?
    speed *= 2   if self.surgeSurferActive?
    speed *= 2   if self.telepathyActive?
    speed *= 2   if self.chlorophyllActive?
    speed *= 1.5 if self.quickFeetActive?
    speed *= 2   if self.sandRushActive?
    speed *= 2   if self.slushRushActive?

    speed *= 0.75 if @battle.pbCheckGlobalAbility(:WINGSOFRUIN) && self.ability != :WINGSOFRUIN
    speed *= 0.5 if self.ability == :SLOWSTART && self.effects[:SlowStart] < 5 && @battle.FE != :DEEPEARTH
    speed *= 1.5 if self.ability == :QUARKDRIVE && self.effects[:Quarkdrive][0] == PBStats::SPEED
    speed *= 1.5 if self.ability == :PROTOSYNTHESIS && self.effects[:Protosynthesis][0] == PBStats::SPEED
    speed *= 1.5 if self.ability == :STEADFAST && (@battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN)

    case @battle.FE
      when :NEWWORLD
        speed *= 0.75 if !self.isAirborne?
      when :WATERSURFACE, :MURKWATERSURFACE
        speed *= 0.75 if !self.isAirborne? && !self.hasType?(:WATER) && ![:SURGESURFER, :SWIFTSWIM].include?(self.ability)
      when :UNDERWATER
        speed *= 0.5 if !self.hasType?(:WATER) && ![:EELEVATE, :STEELWORKER, :SWIFTSWIM].include?(self.ability)
    end
    if self.itemWorks?
      if self.item == :CHOICESCARF
        speed = (speed * 1.5).floor
      elsif PBStuff::TRAININGITEMS.include?(self.item)
        speed = (speed / 2.0).floor
      elsif @battle.FE == :DEEPEARTH && self.item == :FLOATSTONE
        speed = (speed * 1.2).floor
      elsif self.item == :QUICKPOWDER && self.pokemon.species == :DITTO && !self.effects[:Transform]
        speed = (speed * 2.0).floor
      elsif self.item == :IRONBALL
        speed *= 0.5 unless @battle.FE == :DEEPEARTH
      elsif @battle.FE == :CLOUDS && self.item == :SWIFTWING
        speed = (speed * 1.1).floor
      end
    end
    if self.status == :PARALYSIS && self.ability != :QUICKFEET
      speed = (speed / 2.0).floor
    end
    speed = 1 if speed <= 1
    return speed.floor
  end

  ################################################################################
  # Change HP
  ################################################################################
  def pbReduceHP(amt, anim = false, emercheck = true, message: nil)
    damagelimit = self.hp
    hpthreshold = 0

    if self.isbossmon && self.shieldCount > 0 && self.onBreakEffects && self.onBreakEffects[self.shieldCount]
      onBreakdata = self.onBreakEffects[self.shieldCount]
      if !@battle.snapshot.nil? && @battle.snapshot[1] && @battle.snapshot[1][:snapshotUses] == 0
        onBreakdata = self.onBreakEffects[self.shieldCount * -1]
      end
      hpthreshold = onBreakdata && onBreakdata[:threshold] ? onBreakdata[:threshold] : 0
      unless hpthreshold == 1
        damagelimit = self.hp - (self.totalhp * hpthreshold).round
      end
    end

    if amt >= damagelimit
      amt = damagelimit
    elsif amt <= 0 && !self.isFainted?
      amt = 1
    end

    # following bit is here because of Spacea's special gimmick.
    # If the Pokemon dies due to non-direct damage, it counts as if Spacea killed it, and
    # it returns fainted.
    if self.issosmon && self.hp - amt == 0
      priority = @battle.setSpeedOrder
      for i in priority
        bossmon = i if i.isbossmon
      end
      self.lastAttacker = bossmon.index if bossmon
    end

    oldhp = self.hp
    self.hp -= amt
    raise _INTL("HP less than 0") if self.hp < 0
    raise _INTL("HP greater than total HP") if self.hp > @totalhp
    if amt > 0
      @battle.scene.pbHPChanged([self], [oldhp], anim)
      @battle.pbDisplay(message) if message
    end
    self.checkLastWord(oldhp)

    if self.isbossmon && amt == damagelimit && self.shieldCount > 0
      @battle.scene.pbShieldBreakToText(self) # TTS + Logging
      self.pbRecoverHP(self.totalhp, true, fullrecover: true)
      party = @battle.pbPartySingleOwner(self.index)
      party[self.pokemonIndex].status = self.status
      self.effects[:Toxic] = 0 if self.status == :POISON && self.statusCount > 0 # keep toxic poison, reset build up
      if hpthreshold == 1
        if onBreakdata && onBreakdata[:thresholdmessage] && onBreakdata[:thresholdmessage] != ""
          battlerstring = onBreakdata[:thresholdmessage].start_with?("{1}") ? self.pbThis : self.pbThis(true)
          @battle.pbDisplay(_INTL(onBreakdata[:thresholdmessage], battlerstring))
        end
        @battle.pbShieldEffects(self, onBreakdata, false, nil, true) if onBreakdata
        reconstructAdmin if Rejuv
      else
        @battle.pbShieldEffects(self, onBreakdata) if onBreakdata
        shieldCountChange = onBreakdata && onBreakdata[:shieldCountChange] ? onBreakdata[:shieldCountChange] : 1
        if !(onBreakdata && onBreakdata[:userSwitch] && @battle.pbCanChooseNonActive?(self.index))
          self.shieldCount -= shieldCountChange if self.shieldCount > 0
          @battle.scene.pbUpdateShield(self.shieldCount, self.index)
          @battle.callingSOS = true if self.sosDetails
        end
      end
    end
    if emercheck
      pbBerryHerbCheck
      pbEmergencyExitCheck(oldhp)
    end
    return amt
  end

  def pbRecoverHP(amt, anim = false, hpbaranim = true, message: nil, fullrecover: false)
    # reduce healing effects on back alley if the recover amount isn't 100% of the mon's HP
    amt = (amt * 0.67).floor if @battle.FE == :BACKALLEY && !fullrecover
    amt = (amt * 1.2).floor if @battle.pbCheckSideAbility([:INVIGORATE], self).any?
    if self.hp + amt > @totalhp
      amt = @totalhp - self.hp
    elsif amt <= 0 && self.hp != @totalhp
      amt = 1
    end
    oldhp = self.hp
    self.hp += amt
    raise _INTL("HP less than 0") if self.hp < 0
    raise _INTL("HP greater than total HP") if self.hp > @totalhp

    if amt > 0
      @battle.scene.pbHPChanged([self], [oldhp], anim) if hpbaranim
      @battle.pbDisplay(message) if message
    end
    return amt
  end

  def pbFaint(showMessage = true)
    if !self.isFainted?
      dp("!!!***Can't faint with HP greater than 0")
      return false
    end

    if @fainted
      return true
    end
    if self.isbossmon
      if self.shieldCount > 0 && self.onBreakEffects
        onBreakdata = self.onBreakEffects[self.shieldCount]
        if !@battle.snapshot.nil?
          if @battle.snapshot[1]
            if @battle.snapshot[1][:snapshotUses] == 0
              onBreakdata = self.onBreakEffects[-1 * self.shieldCount]
            end
          end
        end
        hpthreshold = onBreakdata && onBreakdata[:threshold] ? onBreakdata[:threshold] : 0
        # self.pbRecoverHP(self.totalhp, true, fullrecover: true) if self.hp == 0
        case hpthreshold
          when 0
            boss = @battle.battlers[self.index]
            @battle.scene.pbShieldBreakToText(self) # TTS + Logging
            self.pbRecoverHP(self.totalhp, true, fullrecover: true)
            party = @battle.pbPartySingleOwner(self.index)
            party[self.pokemonIndex].status = self.status
            self.effects[:Toxic] = 0 if self.status == :POISON && self.statusCount > 0 # keep toxic poison, reset build up
            @battle.pbShieldEffects(self, onBreakdata) if onBreakdata
            shieldCountChange = onBreakdata && onBreakdata[:shieldCountChange] ? onBreakdata[:shieldCountChange] : 1
            if !(onBreakdata && onBreakdata[:userSwitch] && @battle.pbCanChooseNonActive?(self.index))
              self.shieldCount -= shieldCountChange if self.shieldCount > 0
              @battle.scene.pbUpdateShield(boss.shieldCount, self.index)
              @battle.callingSOS = true if boss.sosDetails
            end
          when 1
            @battle.scene.pbShieldBreakToText(self) # TTS + Logging
            self.pbRecoverHP(self.totalhp, true, fullrecover: true)
            self.effects[:Toxic] = 0 if self.status == :POISON && self.statusCount > 0 # keep toxic poison, reset build up
            if onBreakdata
              if onBreakdata[:thresholdmessage] && onBreakdata[:thresholdmessage] != ""
                if onBreakdata[:thresholdmessage].start_with?("{1}")
                  @battle.pbDisplay(_INTL(onBreakdata[:thresholdmessage], self.pbThis))
                else
                  @battle.pbDisplay(_INTL(onBreakdata[:thresholdmessage], self.pbThis(true)))
                end
              end
              @battle.pbShieldEffects(self, onBreakdata, false, nil, true) if onBreakdata
              reconstructAdmin if Rejuv
            end
        end
        return false
      end
    end

    if [:PARAS, :PARASECT].include?(@species) && @pokemon.form == 1 && @ability == :RESUSCITATION
      @battle.scene.pbFakeOutFainted(self)
      pbUpdate(true)
      @battle.pbShowAbilityBox(self)
      self.pbRecoverHP(self.totalhp, true, fullrecover: true)
      @battle.pbDisplayPaused(_INTL("{1} was resuscitated!", self.pbThis))
      if @battle.FE == :HAUNTED
        for i in PBStats::All
          @stages[i] = 0 if @stages[i] < 0
        end
      end
      @battle.pbHideAbilityBox(self)
      return false
    end

    @battle.scene.pbFainted(self)
    @battle.pbDisplay(_INTL("{1} fainted!", self.pbThis), color: :faint) if showMessage
    sosmon = self.issosmon
    stealBack = @battle.returnStolenPokemon(false, self, self.lastAttacker)
    if [:POWEROFALCHEMY, :RECEIVER].include?(self.pbPartner.ability) && !self.pbPartner.hasWorkingItem(:ABILITYSHIELD)
      transferability = self.ability || self.backupability
      if !PBStuff::ABILITYBLACKLIST.include?(transferability) && !transferability.nil?
        message = _INTL("{1}'s {2} was taken over!", self.pbThis, getAbilityName(transferability))
        self.pbPartner.changeAbilityWithEffects(transferability, message: message)
      end
    end
    self.disableAbility
    if self.crested == :RAIKOU
      if @battle.state.effects[:RaikouStorm] == true
        @battle.endTempFieldOrOverlay if (@battle.OV == :ELECTERRAIN || @battle.FE == :ELECTERRAIN)
      end
    end
    priority = @battle.setSpeedOrder
    for i in priority
      next if i.isFainted?

      if i.ability == :SOULHEART
        if [:MISTY, :RAINBOW, :FAIRYTALE].include?(@battle.FE)
          if i.pbCanIncreaseAnyStat?(PBStats::Special, i, nil)
            @battle.pbShowAbilityBox(i)
            i.pbChangeStats(PBStats::Special, 1, i, nil, abilitycheck: :hide)
            @battle.pbHideAbilityBox(i)
          end
        elsif [:DEUXFINALIS].include?(@battle.FE)
          if i.pbCanIncreaseAnyStat?(PBStats::Offensive, i, nil)
            @battle.pbShowAbilityBox(i)
            i.pbChangeStats(PBStats::Offensive, 1, i, nil, abilitycheck: :hide)
            @battle.pbHideAbilityBox(i)
          end
        else
          if i.pbCanIncreaseStatStage?(PBStats::SPATK, i, nil)
            @battle.pbShowAbilityBox(i)
            i.pbChangeStats(PBStats::SPATK, 1, i, nil, abilitycheck: :skip)
            @battle.pbHideAbilityBox(i)
          end
        end
      end
    end
    droprelease = self.effects[:SkyDroppee]
    # if locked in sky drop while fainting
    if self.effects[:SkyDrop]
      battler = @battle.battlers.find { |i| i.effects[:SkyDroppee] == self && !i.isFainted? }
      if battler # to be safe
        @battle.scene.pbUnVanishSprite(battler)
        battler.effects[:TwoTurnAttack] = 0
        battler.effects[:SkyDroppee] = nil
      end
    end
    # Get Tatsugiri out of Dondozo's mouth when Dondozo faints
    if self.effects[:Commandee] && self.pbPartner.effects[:Commander]
      self.pbPartner.effects[:Commander] = false
      @battle.scene.pbUnVanishSprite(self.pbPartner, true)
    end

    pbInitEffects(faint: true) # clears `effects` hash
    self.bossDelayList = nil
    self.onEntryEffects = nil
    self.vanished = false
    # reset status
    self.healStatus
    recoilevo = checkEvolutionEx(@pokemon) { |pokemon, method, condition, evo|
      next true if method == :TakeRecoil
    }
    @pokemon.recoilTaken = 0 if recoilevo
    self.pbOwnSide.effects[:PokemonFaintedThisTurn] = true
    self.pbOwnSide.effects[:AlliesFainted] += 1 if self.pbOwnSide.effects[:AlliesFainted] < 100
    if @pokemon && @battle.internalbattle
      @pokemon.changeHappiness(:Faint)
    end
    @fainted = true
    # reset choice
    @battle.choices[@index] = [nil]
    #@battle.specialchoices[index] = [nil]
    # reset 'A button' choices in case pokemon faints without being able to use them
    @battle.pbDisableAButtonChoices(@index)

    @userSwitch = nil
    @endTurn = false
    unless stealBack
      if self.isMega?
        @pokemon.makeUnmega
      end
      if self.isUltra?
        @pokemon.makeUnultra
      end
      if self.isTerastallized?
        @pokemon.makeUnterastallized
      end
      # reset mimikyu form if it faints
      if [:MIMIKYU, :EISCUE].include?(@species) && @pokemon.form == 1
        self.form = 0
      end
      if [:PARAS, :PARASECT].include?(@species) && @pokemon.form == 2
        self.form = 1
      end
    end
    # deactivate ability
    self.ability = nil
    self.crested = false
    if droprelease != nil
      oppmon = droprelease
      oppmon.effects[:SkyDrop] = false
      @battle.scene.pbUnVanishSprite(oppmon)
      @battle.pbDisplay(_INTL("{1} was freed from the {2}!", oppmon.pbThis, getMoveName(:SKYDROP)))
    end
    @battle.party2[0].pop if sosmon
    if stealBack
      self.pbReset
    end
    @battle.scene.partyBetweenKO1(self.index.odd?) unless @battle.doublebattle || pbNonActivePokemonCount == 0
    return true
  end

  ################################################################################
  # Find other battlers/sides in relation to this battler
  ################################################################################
  # Returns the data structure for this battler's side
  def pbOwnSide
    return @battle.sides[@index & 1] # Player: 0 and 2; Foe: 1 and 3
  end

  # Returns the data structure for the opposing Pokémon's side
  def pbOpposingSide
    return @battle.sides[(@index & 1) ^ 1] # Player: 1 and 3; Foe: 0 and 2
  end

  # Returns whether the position belongs to the opposing Pokémon's side
  def pbIsOpposing?(i)
    return (@index & 1) != (i & 1)
  end

  # Returns the battler's partner
  def pbPartner
    # puts @battle.battlers.inspect
    return @battle.battlers[@index ^ 2]
  end

  # Returns the battler's first opposing Pokémon
  def pbOpposing1
    return @battle.battlers[((@index & 1) ^ 1)]
  end

  # Returns the battler's second opposing Pokémon
  def pbOpposing2
    return @battle.battlers[((@index & 1) ^ 1) + 2]
  end

  def pbOppositeOpposing
    if @battle.doublebattle
      return @battle.battlers[@index ^ 3].pokemon.nil? ? @battle.battlers[@index ^ 1] : @battle.battlers[@index ^ 3]
    else
      return @battle.battlers[@index ^ 1]
    end
  end

  def pbCrossOpposing
    if @battle.doublebattle
      return @battle.battlers[@index ^ 1].pokemon.nil? ? @battle.battlers[@index ^ 3] : @battle.battlers[@index ^ 1]
    else
      return @battle.battlers[@index ^ 1] # there is only 2 battlers in singles that are used, pbCrossOpposing has no business returning anything except 0 or 1 in singles so same as pbOppositeOpposing
    end
  end

  def pbFirstOpposing
    return @battle.doublebattle ? (self.pbOppositeOpposing.hp > 0 ? self.pbOppositeOpposing : self.pbCrossOpposing) : self.pbOppositeOpposing
  end

  def pbNonActivePokemonCount()
    count = 0
    party = @battle.pbPartySingleOwner(self.index)
    for i in 0...party.length
      next if !isFainted? && i == self.pokemonIndex
      if @battle.pbGetOwnerIndex(self.index) == @battle.pbGetOwnerIndex(pbPartner.index)
        next if !pbPartner.isFainted? && i == pbPartner.pokemonIndex
      end
      next unless party[i] && !party[i].isEgg? && party[i].hp > 0
      count += 1
    end
    return count
  end

  def pbFaintedPokemonCount()
    count = 0
    party = @battle.pbCombinedParty(self.index)
    for i in 0...party.length
      if party[i] && !party[i].isEgg? && party[i].hp == 0
        count += 1
      end
    end
    return count
  end

  def pbEnemyFaintedPokemonCount()
    count = 0
    party = @battle.pbCombinedParty(pbOppositeOpposing.index)
    for i in 0...party.length
      if party[i] && !party[i].isEgg? && party[i].hp == 0
        count += 1
      end
    end
    return count
  end

  def pbBeatUpParty()
    return @battle.pbPartySingleOwner(self.index).find_all { |mon|
      mon && !mon.isEgg? && mon.hp > 0 && mon.status.nil?
    }
  end

  ################################################################################
  # Forms
  ################################################################################
  def pbCheckWeatherForm
    return if self.isFainted?

    transformed = false
    # Forecast
    if self.pokemon&.species == :CASTFORM && !self.isFainted?
      if self.ability == :FORECAST
        weather = @battle.pbWeather(nil)
        if weather == :SUNNYDAY && !self.hasWorkingItem(:UTILITYUMBRELLA)
          if self.form != 1
            self.form = 1
            transformed = true
          end
        elsif weather == :RAINDANCE && !self.hasWorkingItem(:UTILITYUMBRELLA)
          if self.form != 2
            self.form = 2
            transformed = true
          end
        elsif [:HAIL, :SNOW].include?(weather)
          if self.form != 3
            self.form = 3
            transformed = true
          end
        else
          if self.form != 0
            self.form = 0
            transformed = true
          end
        end
      else
        if self.form != 0
          self.form = 0
          @battle.pbCommonAnimation("Forecast", self, nil)
          pbUpdate(true, noability: true)
          @battle.scene.pbChangePokemon(self, @pokemon)
        end
      end
    end
    # Flower Gift
    if self.pokemon&.species == :CHERRIM && !self.isFainted?
      if self.ability == :FLOWERGIFT
        if self.flowerGiftActive?
          if self.form != 1
            self.form = 1
            transformed = true
          end
        elsif self.form != 0
          self.form = 0
          transformed = true
        end
      else
        if self.form != 0
          self.form = 0
          @battle.pbCommonAnimation("FlowerGiftNotSun", self, nil)
          pbUpdate(true, noability: true)
          @battle.scene.pbChangePokemon(self, @pokemon)
        end
      end
    end
    # If the form of the Pokémon changed, but not due to losing the ability
    if transformed && !self.effects[:clearDisguise]

      # Animations
      @battle.pbShowAbilityBox(self, crest: self.crested == :CHERRIM)
      # Animation
      @battle.pbCommonAnimation("Forecast", self, nil) if self.species == :CASTFORM
      @battle.pbCommonAnimation(self.form == 1 ? "FlowerGiftSun" : "FlowerGiftNotSun", self, nil) if self.species == :CHERRIM
      # Battler update
      pbUpdate(true)
      @battle.scene.pbChangePokemon(self, @pokemon)
      @battle.pbDisplay(_INTL("{1} transformed!", pbThis))
      @battle.pbHideAbilityBox(self)
    end
  end

  def pbCheckStance(basemove)
    stanceChangeIllusions(basemove) if Rejuv
    # Aegislash
    transformed = false
    if self.pokemon && self.pokemon.species == :AEGISLASH && !self.isFainted? && !self.effects[:clearDisguise]
      if self.ability == :STANCECHANGE && !@effects[:Transform]
        # in Shield Forme and used a damaging move
        if self.form == 0 && !basemove.nil? && basemove.pbIsDamaging?
          @battle.pbShowAbilityBox(self)
          self.form = 1
          @battle.pbCommonAnimation("StanceAttack", self, nil)
          transformed = true
        # in Blade Forme and used King's Shield
        elsif self.form == 1 && !basemove.nil? && basemove.move == :KINGSSHIELD
          @battle.pbShowAbilityBox(self)
          self.form = 0
          @battle.pbCommonAnimation("StanceProtect", self, nil)
          transformed = true
        end
        if transformed == true
          if self.species == :AEGISLASH && (self.type1 != @pokemon.type1 || self.type2 != @pokemon.type2)
            pbUpdate(false)
          else
            pbUpdate(true)
          end
          @battle.scene.pbChangePokemon(self, @pokemon)
          message = self.form == 0 ? _INTL("Changed to Shield Forme!") : _INTL("Changed to Blade Forme!")
          @battle.pbDisplay(message)
          if @battle.FE == :FAIRYTALE || (Rejuv && @battle.FE == :CHESS)
            amounts = self.form == 0 ? [-1, 1] : [1, -1]
            self.pbChangeStats(PBStats::Physical, amounts, self, nil, abilitycheck: :hide)
          end
        end
        @battle.pbHideAbilityBox(self)
      end
    end
  end

  def zenModeTransform
    @battle.pbShowAbilityBox(self, item: self.crested == :DARMANITAN)
    self.form += self.form.even? ? 1 : -1
    @battle.pbCommonAnimation("ZenMode", self, nil)
    pbUpdate(true)
    @battle.scene.pbChangePokemon(self, @pokemon)
    abilityname = getAbilityName(:ZENMODE)
    message = self.form.even? ? _INTL("{1} ended!", abilityname) : _INTL("{1} triggered!", abilityname)
    @battle.pbDisplay(message)
    @battle.pbHideAbilityBox(self)
  end

  def gulpMissileTransform
    if [:SWAMP, :WATERSURFACE, :UNDERWATER].include?(@battle.FE)
      self.changeForm(1) # Gulping Form
    elsif [:ELECTERRAIN, :FACTORY, :SHORTCIRCUIT].include?(@battle.FE)
      self.changeForm(2) # Gorging Form
    elsif self.hp * 2.0 > self.totalhp
      self.changeForm(1) # Gulping Form
    else
      self.changeForm(2) # Gorging Form
    end
    pbUpdate(false)
    @battle.scene.pbChangePokemon(self, self.pokemon)
  end

  def pbCheckFormRoundEnd
    # Wishiwashi
    if self.pokemon&.species == :WISHIWASHI && !self.isFainted?
      if self.ability == :SCHOOLING && !@effects[:Transform]
        schoolHP = (self.totalhp / 4.0).floor
        if (self.hp > schoolHP && self.level > 19) || @battle.FE == :UNDERWATER || ([:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.FE) && !self.isAirborne?)
          if self.form != 1
            @battle.pbShowAbilityBox(self)
            self.form = 1
            @battle.pbCommonAnimation("SchoolForm", self, nil)
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self, @pokemon)
            @battle.pbDisplay(_INTL("{1} formed a school!", pbThis))
          end
        else
          if self.form != 0
            @battle.pbShowAbilityBox(self)
            self.form = 0
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self, @pokemon)
            @battle.pbDisplay(_INTL("{1} stopped schooling!", pbThis))
          end
        end
        @battle.pbHideAbilityBox(self)
      end
    end
    # Darmanitan
    if self.pokemon&.species == :DARMANITAN && !self.isFainted?
      if self.ability == :ZENMODE || self.crested == :DARMANITAN
        zenHP = (self.totalhp / 2.0).floor
        unovaZenFields = Rejuv ? [:ASHENBEACH, :PSYTERRAIN] : [:ASHENBEACH]
        galarZenFields = [:BURNING, :SUPERHEATED]
        # Darmanitan Crest
        if self.crested == :DARMANITAN
          zenModeTransform if self.form == 0
        else
          if self.hp <= zenHP || (unovaZenFields.include?(@battle.FE) && self.form < 2) || (galarZenFields.include?(@battle.FE) && self.form > 1)
            zenModeTransform if self.form.even?
          else
            zenModeTransform if self.form.odd?
          end
        end
      else
        zenModeTransform if self.form.odd?
      end
    end
    # Minior
    if self.pokemon&.species == :MINIOR && !self.isFainted?
      if self.ability == :SHIELDSDOWN && !@effects[:Transform]
        coreHP = (self.totalhp / 2.0).floor
        if self.hp > coreHP
          if self.form != 7
            @battle.pbShowAbilityBox(self)
            @pokemon.originalForm = @pokemon.form
            self.form = 7
            @battle.pbCommonAnimation("ShieldsUp", self, nil)
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self, @pokemon)
            @battle.pbDisplay(_INTL("{1}'s shields came up!", pbThis))
          end
        else
          if self.form == 7
            @battle.pbShowAbilityBox(self)
            self.form = @pokemon.originalForm || 0
            @pokemon.originalForm = nil
            @battle.pbCommonAnimation("ShieldsDown", self, nil)
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self, @pokemon)
            @battle.pbDisplay(_INTL("{1}'s shields went down!", pbThis))
          end
        end
        @battle.pbHideAbilityBox(self)
      end
    end
    # Eiscue on fire fields
    if self.pokemon&.species == :EISCUE && !self.isFainted? &&
       self.effects[:IceFace] && [:VOLCANIC, :VOLCANICTOP, :INFERNAL, :BURNING].include?(@battle.FE)
      @battle.pbShowAbilityBox(self)
      self.pbBreakDisguise
      @battle.pbDisplay(_INTL("{1} transformed!", self.name))
      self.effects[:IceFace] = false
      @battle.pbHideAbilityBox(self)
    end
    # Download mons on Dimensional
    if @battle.FE == :DIMENSIONAL && self.ability == :DOWNLOAD && self.canChangeType?
      self.changeType(@battle.getRandomType)
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} transformed into the {2} type!", self.pbThis, getTypeName(self.type1)))
    end
    # Zygarde
    if self.pokemon&.species == :ZYGARDE && [0, 1].include?(self.form) &&
       self.ability == :POWERCONSTRUCT && self.hp <= (self.totalhp / 2.0).floor &&
       !self.isFainted? && !self.effects[:Transform]
      @battle.pbDisplay(_INTL("You sense the presence of many!"))
      @battle.pbShowAbilityBox(self)
      @battle.pbCommonAnimation("ZygardeForms", self, nil)
      @pokemon.transformZygarde
      changeForm(@pokemon.form)
      pbUpdate(true)
      @battle.scene.pbChangePokemon(self, @pokemon)
      @battle.pbDisplay(_INTL("{1} transformed into its Complete Forme!", pbThis))
      if @battle.FE == :DEEPEARTH
        @battle.pbDisplay(_INTL("The Core's energy empowered {1}!", pbThis(true)))
        stats = PBStats::Omni
        self.pbChangeStats(stats, 1, self, nil, abilitycheck: :hide)
      end
      @battle.pbHideAbilityBox(self)
    end
    # Silvally / Arceus
    if ((self.ability == :RKSSYSTEM && self.pokemon&.species == :SILVALLY) || self.crested == :SILVALLY ||
      (self.ability == :MULTITYPE && self.pokemon&.species == :ARCEUS)) && !self.isFainted?
      oldform = self.form

      if @battle.FE == :NEWWORLD
        self.pbNWTypeRoll
        return
      end

      # exception for ??? Arceus from glitch seed
      return if self.species == :ARCEUS && self.type1 == :QMARKS

      if self.species == :SILVALLY && [:GLITCH, :HOLY].include?(@battle.FE)
        self.form = 9 if @battle.FE == :GLITCH
        self.form = 17 if @battle.FE == :HOLY
        if self.form != oldform
          @battle.pbShowAbilityBox(self, attrname: getAbilityName(:RKSSYSTEM), crest: false)
          @battle.pbCommonAnimation("SilvallyGlitch", self, nil) if @battle.FE == :GLITCH
          @battle.pbCommonAnimation("SilvallyHoly", self, nil) if @battle.FE == :HOLY
          pbUpdate(true)
          @battle.scene.pbChangePokemon(self, @pokemon)
          @battle.pbDisplay(_INTL("{1} was corrupted by the rogue data!", pbThis)) if @battle.FE == :GLITCH
          @battle.pbDisplay(_INTL("A false god holds no power here...")) if @battle.FE == :HOLY
          @battle.pbHideAbilityBox(self)
        end
        return
      end

      self.form = arceusSilvallyFormFromItem
      self.form += pulseArceusTypes if $game_switches[:Pulse_Arceus] && self.species == :ARCEUS && self.pokemon.trainerID == 00000
      if self.form != oldform
        @battle.pbShowAbilityBox(self)
        pbUpdate(true)
        @battle.pbCommonAnimation("TypeRoll", self, nil)
        @battle.scene.pbChangePokemon(self, @pokemon)
        @battle.pbDisplay(_INTL("{1} reverted to the {2} type!", pbThis, getTypeName(self.type1)))
        @battle.pbHideAbilityBox(self)
      end
    end
  end

  def pbCheckBurmyForm
    return if self.species != :BURMY || self.isFainted?

    originalform = self.form
    if $cache.FEData[@battle.FE].burmyCloak == :TRASHCLOAK
      self.form = 2 # Trash Cloak
    elsif $cache.FEData[@battle.FE].burmyCloak == :PLANTCLOAK
      self.form = 0 # Plant Cloak
    elsif $cache.FEData[@battle.FE].burmyCloak == :SANDYCLOAK
      self.form = 1 # Sandy Cloak
    else
      env = @battle.environment
      if env == :Sand || env == :Rock || env == :Cave
        self.form = 1 # Sandy Cloak
      elsif env == :Grass || env == :TallGrass || env == :MovingWater || env == :StillWater || env == :Underwater
        self.form = 0 # Plant Cloak
      else
        self.form = 2 # Trash Cloak
      end
    end
    if originalform != self.form
      case self.form
        when 1 then @battle.pbCommonAnimation("BurmySandy", self, nil)
        when 2 then @battle.pbCommonAnimation("BurmyTrash", self, nil)
        else @battle.pbCommonAnimation("BurmyPlant", self, nil)
      end
      @battle.scene.pbChangePokemon(self, @pokemon)
      @battle.pbDisplay(_INTL("{1} changed form to match the environment!", pbThis))
    end
  end

  def pbBreakDisguise
    self.form = 1
    pbUpdate(true)
    if !self.effects[:clearDisguise]
      @battle.pbCommonAnimation("DisguiseBust1", self, nil)
      @battle.scene.pbChangePokemon(self, @pokemon)
      @battle.pbCommonAnimation("DisguiseBust2", self, nil)
      @battle.scene.pbDamageAnimation(self, 0)
    end
  end

  def pbRegenFace
    self.form = 0
    @effects[:IceFace] = true
    pbUpdate(true)
    @battle.scene.pbChangePokemon(self, @pokemon)
  end

  def pbHeroTransform
    return if self.isFainted?
    return if @effects[:Transform]
    return unless @pokemon && @pokemon.species == :PALAFIN
    return unless self.form == 0
    return if self.permeffs[:ZeroToHero]

    self.form = 1
    self.permeffs[:ZeroToHero] = :transformed
  end

  def pbResetForm
    return if !@pokemon
    return if @effects[:Transform]

    @pokemon.changeFormOnLeavingField
    self.form = @pokemon.form

    # pbResetForm should not call into pbUpdate for the battler directly, as this causes Natural Cure and Regenerator to not interact correctly
    # And it's not necessary as pbResetForm is only called when a battler leaves the field (faint, switch, battle end)
    # pbUpdate(true)
  end

  ################################################################################
  # Ability effects
  ################################################################################
  def abilitySuppressed?
    return @ability.nil? && !@backupability.nil?
  end

  def changeAbility(newability, ai: false)
    oldability = @ability
    fixedabilities = PBStuff::FIXEDABILITIES + [:NEUTRALIZINGGAS]

    # The order of the conditions is important here
    if newability == :suppress
      @ability = nil
    # When no ability suppressing effects are active
    elsif !@effects[:GastroAcid] && !@battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS)
      @ability = newability
      @backupability = newability
    # Edge case when somehow acquiring a fixed ability while neutralizing gas is active
    elsif fixedabilities.include?(newability) && !@effects[:GastroAcid]
      @ability = newability
      @backupability = newability
    # Edge case when somehow losing a fixed ability while neutralizing gas is active
    elsif fixedabilities.include?(oldability) && !fixedabilities.include?(newability)
      @ability = nil
      @backupability = newability
    # When ability suppressing effects are active (apart from the above two edge cases)
    else
      @backupability = newability
    end

    @effects[:Illusion].ability = @ability if @crested == :ZOROARK && @effects[:Illusion] && @effects[:Illusion] != self

    return oldability, newability
  end

  # Always needs to be called after changeAbility (barring fakebattler stuff), but some other things might need to be called between the two methods
  # This is handled using utility methods like the two below this one
  def pbEffectsOnAbilityChange(oldability, newability)
    @effects[:GorillaLock] = nil
    @effects[:Truant] = false
    @effects[:ProteanUsed] = false unless newability == :suppress
    @effects[:ReflectorTypes].clear if oldability == :REFLECTOR
    self.breakIllusion if @effects[:Illusion] != nil && @ability != :ILLUSION && @crested != :ZOROARK
    self.pbCheckWeatherForm
    self.disableAbility(oldability) if @ability != oldability
  end

  def changeAbilityWithEffects(ability, message: nil, box: true, activate: true)
    box = false if ability == :suppress
    @battle.pbShowAbilityBox(self) if box
    oldability, newability = self.changeAbility(ability)
    @battle.pbChangeAbilityBox(self) if box
    @battle.pbDisplay(message) if message
    @battle.pbHideAbilityBox(self) if box
    self.pbEffectsOnAbilityChange(oldability, newability)
    self.pbAbilitiesOnSwitchIn if activate
  end

  def swapAbilities(opp)
    allies = @battle.pbIsOpposing?(self.index) == @battle.pbIsOpposing?(opp.index)
    selfability = self.ability || self.backupability
    oppability = opp.ability || opp.backupability
    # We could do a different animation in case of allies but we're sticking to canon which just skips the ability boxes altogether
    @battle.pbShowAbilityBox(self) unless allies
    @battle.pbShowAbilityBox(opp) unless allies
    oldself, newself = self.changeAbility(oppability)
    oldopp, newopp = opp.changeAbility(selfability)
    @battle.pbChangeAbilityBox(self) unless allies
    @battle.pbChangeAbilityBox(opp) unless allies
    @battle.pbDisplay(_INTL("{1} swapped Abilities with its target!", self.pbThis))
    @battle.pbHideAbilityBox(self) unless allies
    @battle.pbHideAbilityBox(opp) unless allies
    self.pbEffectsOnAbilityChange(oldself, newself)
    opp.pbEffectsOnAbilityChange(oldopp, newopp)
    self.pbAbilitiesOnSwitchIn
    opp.pbAbilitiesOnSwitchIn
  end

  def pbAbilitiesOnField(delayStatChangeChecks = false, applySwitchInAbility: false)
    if !applySwitchInAbility
      return if @battle.preSurgeField && @battle.FE == @battle.preSurgeField
      return if @applyingEntryEffects
    end
    return if self.ability.nil?

    if @battle.FE == :ELECTERRAIN
      if self.ability == :LIGHTNINGROD && Rejuv
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPATK, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :ELECTROMORPHOSIS
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPATK, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    if Rejuv && @battle.FE == :CHESS
      if self.ability == :STALL
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("{1} is playing defensively!", pbThis, getAbilityName(ability)))
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :STANCECHANGE
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    if Rejuv && @battle.FE == :SWAMP
      if self.ability == :RATTLED
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    if Rejuv && @battle.FE == :FACTORY
      if self.ability == :LIGHTMETAL
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("{1}'s light body makes it nimble!", pbThis))
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :HEAVYMETAL
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil) || pbCanReduceStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("{1}'s heavy body is sturdy and unmoving!", pbThis))
          pbChangeStats([PBStats::DEFENSE, PBStats::SPEED], [1, -1], self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    # Volcanic Field Entry
    if @battle.FE == :VOLCANIC
      if self.ability == :MAGMAARMOR
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    # Mirror Field Entry
    if @battle.FE == :MIRROR
      if pbCanIncreaseStatStage?(PBStats::EVASION, self, nil)
        if [:SNOWCLOAK, :SANDVEIL, :TANGLEDFEET, :MAGICBOUNCE, :COLORCHANGE, :MIRRORARMOR].include?(self.ability)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::EVASION, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
        if self.ability == :ILLUSION
          @battle.pbShowAbilityBox(self, attrname: _INTL("Ability"))
          pbChangeStats(PBStats::EVASION, 2, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      # Keen Eye / Compound Eye
      if [:KEENEYE, :COMPOUNDEYES].include?(self.ability)
        @battle.pbShowAbilityBox(self)
        pbChangeStats(PBStats::ACCURACY, 1, self, nil, abilitycheck: :hide)
        self.effects[:LaserFocus] = 2
        @battle.pbAnimation(:LASERFOCUS, self, nil)
        @battle.pbDisplay(_INTL("{1} concentrated intensely!", pbThis))
        @battle.pbHideAbilityBox(self)
      end
      # Illuminate
      if self.ability == :ILLUMINATE
        for i in [pbOpposing1, pbOpposing2]
          next unless i.passiveAbilityApplies?

          @battle.pbShowAbilityBox(self)
          i.pbChangeStats(PBStats::ACCURACY, -1, self, :Intimidate)
        end
        @battle.pbHideAbilityBox(self)
      end
    end
    # Fairy Tale Field Entry
    if @battle.FE == :FAIRYTALE
      if [:ARMORTAIL, :BATTLEARMOR, :SHELLARMOR, :STANCECHANGE].include?(self.ability)
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip, statmessage: :FieldAbility)
          @battle.pbHideAbilityBox(self)
        end
      end
      if [:MAGICGUARD, :MAGICBOUNCE, :MIRRORARMOR, :PASTELVEIL].include?(self.ability)
        if pbCanIncreaseStatStage?(PBStats::SPDEF, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPDEF, 1, self, nil, abilitycheck: :skip, statmessage: :FieldAbility)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :POWEROFALCHEMY
        if pbCanIncreaseAnyStat?(PBStats::Defensive, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::Defensive, 1, self, nil, abilitycheck: :hide, statmessage: :FieldAbility)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :MAGICIAN
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPATK, 1, self, nil, abilitycheck: :skip, statmessage: :FieldAbility)
          @battle.pbHideAbilityBox(self)
        end
      end
    end

    # Dragon's Den Entry
    if @battle.FE == :DRAGONSDEN
      if self.ability == :MAGMAARMOR
        if pbCanIncreaseAnyStat?(PBStats::Defensive, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::Defensive, 1, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
      if Rejuv && self.ability == :SHELLARMOR
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    # Flower Garden Entry
    flowergardenabils = [:FLOWERGIFT, :FLOWERVEIL, :DROUGHT, :DRIZZLE, :ORICHALCUMPULSE]
    flowergardenabils.push(:GRASSYSURGE) if Rejuv
    if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 1, 4) && flowergardenabils.include?(ability)
      @battle.pbShowAbilityBox(self)
      @battle.growField(self.pbThis, self)
      @battle.pbHideAbilityBox(self)
    end
    # Starlight Arena Entry
    if @battle.FE == :STARLIGHT
      if self.ability == :ILLUMINATE
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("{1} flared up with starlight!", pbThis))
          pbChangeStats(PBStats::SPATK, 2, self , nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
        if self.pbPartner.ability == :MIRRORARMOR && Rejuv
          @battle.pbShowAbilityBox(self.pbPartner)
          self.pbPartner.effects[:FollowMe] = true
          @battle.pbAnimation(:SPOTLIGHT, self, self.pbPartner)
          @battle.pbDisplay(_INTL("{1}'s dazzling shine put a spotlight on its partner!", pbThis))
          @battle.pbHideAbilityBox(self.pbPartner)
        end
      end
    end
    # Psychic Terrain Entry
    if @battle.FE == :PSYTERRAIN
      if self.ability == :ANTICIPATION || (Rejuv && self.ability == :FOREWARN)
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPATK, 2, self , nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :MINDSEYE
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPATK, 1, self , nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    # Misty Terrain + Corrosive Mist Entry
    if [:MISTY, :CORROSIVEMIST].include?(@battle.FE)
      if self.ability == :WATERCOMPACTION
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 2, self , nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    # Crystal Cavern entry
    if @battle.FE == :CRYSTALCAVERN
      if self.ability == :TERAFORMZERO
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPATK, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    # Rejuv Dimensional field entry
    if [:DIMENSIONAL, :FROZENDIMENSION, :DEUXFINALIS].include?(@battle.FE)
      if self.ability == :RATTLED
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if [:DIMENSIONAL, :FROZENDIMENSION].include?(@battle.FE)
        if self.ability == :BERSERK
          if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
            @battle.pbShowAbilityBox(self)
            pbChangeStats(PBStats::SPATK, 1, self, nil, abilitycheck: :skip, statmessage: :FieldAbility)
            @battle.pbHideAbilityBox(self)
          end
        end
        if self.ability == :ANGERSHELL
          upstats = [PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED]
          downstats = PBStats::Defensive
          if self.pbCanIncreaseAnyStat?(upstats, self, nil) || self.pbCanReduceAnyStat?(downstats, self, nil)
            @battle.pbShowAbilityBox(self)
            self.pbChangeStats(upstats + downstats, [1, 1, 1, -1, -1], self, nil, abilitycheck: :hide)
            @battle.pbHideAbilityBox(self)
          end
        end
        if self.ability == :JUSTIFIED || self.ability == :ANGERPOINT
          if pbCanIncreaseStatStage?(PBStats::ATTACK, self, nil)
            @battle.pbShowAbilityBox(self)
            pbChangeStats(PBStats::ATTACK, 1, self, nil, abilitycheck: :skip, statmessage: :FieldAbility)
            @battle.pbHideAbilityBox(self)
          end
        end
      end
      if self.ability == :PRESSURE
        @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} is exerting its pressure!", pbThis))
        for i in [pbOpposing1, pbOpposing2]
          next unless i.passiveAbilityApplies?

          stats = PBStats::Defensive
          # Extra check used when lowering multiple stats, in order to show single message for blanket stat-drop-prevention effects
          next if !i.pbCanReduceAnyStat?(stats, self, :Intimidate, showMessage: true)

          i.pbChangeStats(stats, -1, self, :Intimidate)
        end
        @battle.pbHideAbilityBox(self)
      end
      if PBStuff::UnnerveAbilities.include?(self.ability)
        display_abil = [:ASONECHILLING, :ASONEGRIM].include?(self.ability) ? :UNNERVE : self.ability
        msg = @battle.pbIsOpposing?(@index) ?
          _INTL("Your team is too nervous to eat Berries!") :
          _INTL("The opposing team is too nervous to eat Berries!")
        @battle.pbAbilityBoxAndDisplay(self, msg, attrname: getAbilityName(display_abil))
        for i in [pbOpposing1, pbOpposing2]
          next unless i.passiveAbilityApplies?

          i.pbChangeStats(PBStats::SPEED, -1, self, :Intimidate)
        end
        @battle.pbHideAbilityBox(self)
      end
      if @battle.FE == :FROZENDIMENSION && self.ability == :HUNGERSWITCH && self.species == :MORPEKO && self.form == 0
        @battle.pbShowAbilityBox(self)
        self.changeForm(1)
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self, @pokemon)
        @battle.pbDisplay(_INTL("{1} transformed!", self.pbThis))
        @battle.pbHideAbilityBox(self)
      end
    end
    if @battle.FE == :HAUNTED
      if self.ability == :RATTLED
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :SHADOWTAG && @battle.pbOwnedByPlayer?(@index)
        items = []
        items.push(pbOpposing1) if pbOpposing1.item && !pbOpposing1.isFainted?
        items.push(pbOpposing2) if pbOpposing2.item && !pbOpposing2.isFainted?
        for i in items
          @battle.pbShowAbilityBox(self)
          itemname = getItemName(i.item)
          @battle.pbDisplay(_INTL("{1}'s shadow frisked {2} and found its {3}!", pbThis, i.pbThis(true), itemname))
          @battle.ai.discloseItem(i)
        end
        @battle.pbHideAbilityBox(self)
      end
    end
    # Rejuv sky field entry
    if @battle.FE == :SKY
      if self.ability == :BIGPECKS
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if PBStuff::LevitateAbilities.include?(self.ability)
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :CLOUDNINE && @battle.weather != 0
        @battle.pbShowAbilityBox(self)
        @battle.pbEndWeather(noPersistent: true)
        @battle.pbHideAbilityBox(self)
      end
    end
    # Colosseum Field Entry
    if @battle.FE == :COLOSSEUM
      if [:BATTLEARMOR, :SHELLARMOR].include?(self.ability)
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip, statmessage: :FieldAbility)
          @battle.pbHideAbilityBox(self)
        end
      end
      if [:MIRRORARMOR, :MAGICGUARD].include?(self.ability)
        if pbCanIncreaseStatStage?(PBStats::SPDEF, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPDEF, 1, self, nil, abilitycheck: :skip, statmessage: :FieldAbility)
          @battle.pbHideAbilityBox(self)
        end
      end
      if [:NOGUARD, :JUSTIFIED].include?(self.ability)
        if pbCanIncreaseAnyStat?(PBStats::Offensive, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::Offensive, 1, self, nil, abilitycheck: :hide, statmessage: :FieldAbility)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    if @battle.FE == :INFERNAL
      if [:MAGMAARMOR, :FLAMEBODY, :DESOLATELAND].include?(self.ability)
        if pbCanIncreaseAnyStat?(PBStats::Defensive, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::Defensive, 1, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    if @battle.FE == :DEEPEARTH
      if self.ability == :LIGHTMETAL
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :HEAVYMETAL
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil) || pbCanReduceStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("{1}'s weight makes it harder to be moved!", pbThis))
          pbChangeStats([PBStats::DEFENSE, PBStats::SPEED], [1, -1], self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :SLOWSTART
        if pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::DEFENSE, PBStats::SPDEF], self, nil) || pbCanReduceAnyStat?([PBStats::SPEED, PBStats::EVASION], self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("Slow but powerful!"))
          stats = [PBStats::ATTACK, PBStats::DEFENSE, PBStats::SPDEF, PBStats::SPEED, PBStats::EVASION]
          amounts = [1, 1, 1, -6, -6]
          pbChangeStats(stats, amounts, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :MAGNETPULL
        @battle.pbAbilityBoxAndDisplay(self, _INTL("The strong magnetism causes {1} to float!", self.pbThis(true)))
      end
      if self.ability == :UNAWARE || self.ability == :OBLIVIOUS
        @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} fails to notice the intense gravity...", self.pbThis))
      end
      if self.ability == :CONTRARY
        @battle.pbAbilityBoxAndDisplay(self, _INTL("Gravity's just a theory, after all..."))
      end
    end
    if @battle.ProgressiveFieldCheck(PBFields::CONCERT)
      if [:SOUNDPROOF, :PUNKROCK, :HEAVYMETAL, :SOLIDROCK, :ROCKHEAD].include?(self.ability)
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("{1} is accustomed to the music!", pbThis))
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if ([:RUNAWAY, :EMERGENCYEXIT].include?(self.ability) && @battle.FE != :CONCERT1) || (self.ability == :RATTLED && [:CONCERT3, :CONCERT4].include?(@battle.FE))
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("{1} wants to get away from the noise!", pbThis))
          increment = self.ability == :RATTLED ? 2 : 1
          pbChangeStats(PBStats::SPEED, increment, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if [:PLUS, :GALVANIZE, :HEAVYMETAL, :SOLIDROCK, :PUNKROCK].include?(self.ability) && @battle.FE != :CONCERT4
        @battle.pbShowAbilityBox(self)
        @battle.growField(self.pbThis, self)
        @battle.pbHideAbilityBox(self)
      end
      if [:MINUS, :KLUTZ].include?(self.ability) && @battle.FE != :CONCERT1
        @battle.pbShowAbilityBox(self)
        @battle.reduceField
        @battle.pbHideAbilityBox(self)
      end
    end
    if @battle.FE == :BACKALLEY
      if self.ability == :PICKPOCKET || self.ability == :MERCILESS
        if pbCanIncreaseStatStage?(PBStats::ATTACK, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("Merciless cutpurses get ready to strike!"))
          pbChangeStats(PBStats::ATTACK, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :MAGICIAN
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("The street magician plays its tricks!"))
          pbChangeStats(PBStats::SPATK, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :ANTICIPATION || self.ability == :FOREWARN
        if pbCanIncreaseAnyStat?(PBStats::Defensive, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("{1} is getting ready to defend itself!", pbThis))
          pbChangeStats(PBStats::Defensive, 1, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :RATTLED
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("The gloomy backalley makes {1} ready to bolt!", pbThis(true)))
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    if @battle.FE == :CITY
      if self.ability == :EARLYBIRD
        if pbCanIncreaseStatStage?(PBStats::ATTACK, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("The early bird catches the worm!", pbThis))
          pbChangeStats(PBStats::ATTACK, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :BIGPECKS
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :RATTLED || self.ability == :PICKUP
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          if self.ability == :RATTLED
            @battle.pbDisplay(_INTL("The busy city is rattling {1}!", pbThis(true)))
          else
            @battle.pbDisplay(_INTL("{1} is picking up speed!", pbThis))
          end
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    # Clouds from Deso Entry
    if @battle.FE == :CLOUDS
      if self.ability == :CLOUDNINE
        if pbCanIncreaseAnyStat?(PBStats::Defensive, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::Defensive, 1, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :FORECAST
        if pbCanIncreaseAnyStat?([PBStats::DEFENSE, PBStats::SPDEF, PBStats::SPEED], self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats([PBStats::DEFENSE, PBStats::SPDEF, PBStats::SPEED], 1, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :OVERCOAT
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :BIGPECKS
        if pbCanIncreaseStatStage?(PBStats::ATTACK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::ATTACK, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :WINDPOWER
        if pbCanIncreaseStatStage?(PBStats::SPDEF, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPDEF, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :LIGHTNINGROD && @battle.pbWeather(nil) == :RAINDANCE
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPATK, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :MOTORDRIVE && @battle.pbWeather(nil) == :RAINDANCE
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :SNOWCLOAK && [:HAIL, :SNOW].include?(@battle.pbWeather(nil))
        if pbCanIncreaseStatStage?(PBStats::SPDEF, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPDEF, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :ICEBODY && [:HAIL, :SNOW].include?(@battle.pbWeather(nil))
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    # Darkness field, Deso
    if PBFields::DARKNESS.include?(@battle.FE)
      if self.ability == :RATTLED || (self.ability == :PICKPOCKET && @battle.FE != :DARKNESS1)
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          increment = self.ability == :PICKPOCKET && @battle.FE == :DARKNESS3 ? 2 : 1
          pbChangeStats(PBStats::SPEED, increment, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    # Dancefloor field from Deso
    if @battle.FE == :DANCEFLOOR
      if [:MAGICGUARD, :MAGICBOUNCE, :MAGICIAN].include?(self.ability)
        if pbCanIncreaseStatStage?(PBStats::SPDEF, self, nil)
          @battle.pbShowAbilityBox(self)
          increment = self.ability == :MAGICIAN ? 1 : 2
          pbChangeStats(PBStats::SPDEF, increment, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :DANCER
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPATK, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :INSOMNIA
        if pbCanIncreaseAnyStat?(PBStats::Defensive, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::Defensive, 1, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.ability == :ILLUMINATE
        if pbCanIncreaseAnyStat?(PBStats::Special, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::Special, 1, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    # Crowd Field, Deso
    if @battle.FE == :CROWD
      if self.ability == :IRONFIST
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end

    @battle.pbStatChangeChecks unless delayStatChangeChecks
  end

  def pbAbilitiesOnOverlay(delayStatChangeChecks = false, applySwitchInAbility: false)
    return if @applyingEntryEffects && !applySwitchInAbility
    return if self.ability.nil?

    if @battle.OV == :PSYTERRAIN
      if self.ability == :ANTICIPATION || (Rejuv && self.ability == :FOREWARN)
        if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPATK, 1, self , nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    if @battle.OV == :MISTY
      if self.ability == :WATERCOMPACTION
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 2, self , nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    if @battle.OV == :DARKNESS2
      if [:PICKPOCKET, :RATTLED].include?(self.ability)
        if pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end

    @battle.pbStatChangeChecks unless delayStatChangeChecks
  end

  def pbRegularIntervalChecks(abilityactivation: false)
    return if @hp <= 0

    # Primal Reversions
    if (self.species == :KYOGRE && self.item == :BLUEORB) || (self.species == :GROUDON && self.item == :REDORB)
      if @pokemon.form == 0
        if self.species == :KYOGRE
          @battle.pbCommonAnimation("PrimalReversionKyogre", self, nil)
        else
          @battle.pbCommonAnimation("PrimalReversionGroudon", self, nil)
        end
        @pokemon.makePrimal
        changeForm(@pokemon.form)
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self, @pokemon)
        @battle.pbDisplay(_INTL("{1}'s Primal Reversion!\nIt reverted to its primal state!", pbThis))
      end
    end

    # Trace
    if @effects[:TracePending] || abilityactivation
      v = self.pbTrace
      self.pbAbilitiesOnSwitchIn if v && !abilityactivation
      # abilityactivation means it's being called at the start of pbAbilitiesOnSwitchIn and has to go through the entire rest of it anyway, so don't do it twice
    end

    # Commander
    if !self.isFainted? && !self.pbPartner.isFainted? && @battle.pbGetOwnerIndex(self.index) == @battle.pbGetOwnerIndex(self.pbPartner.index)
      tatsugiri = nil
      if self.pokemon.species == :TATSUGIRI && self.pbPartner.pokemon.species == :DONDOZO
        tatsugiri = self
        dondozo = self.pbPartner
      elsif self.pokemon.species == :DONDOZO && self.pbPartner.pokemon.species == :TATSUGIRI
        tatsugiri = self.pbPartner
        dondozo = self
      end
      if tatsugiri && tatsugiri.ability == :COMMANDER && !dondozo.effects[:Commandee] && ![tatsugiri, dondozo].any? { |pkmn| pkmn.isSemiInvul? }
        @battle.pbShowAbilityBox(tatsugiri)
        if tatsugiri.effects[:Substitute] > 0
          tatsugiri.effects[:Substitute] = 0
          @battle.scene.pbUnSubstituteSprite(tatsugiri)
        end
        if [0, 3].include?(tatsugiri.index) # left battler positions
          @battle.pbCommonAnimation("Commander1", tatsugiri, nil)
        else # right battler positions
          @battle.pbCommonAnimation("Commander2", tatsugiri, nil)
        end
        @battle.scene.pbVanishSprite(tatsugiri)
        @battle.pbDisplay(_INTL("{1} was swallowed by {2} and became its commander!", tatsugiri.pbThis, dondozo.name))
        @battle.pbClearChoices(tatsugiri.index)
        tatsugiri.pbCancelMoves
        tatsugiri.effects[:Commander] = true
        dondozo.pbChangeStats(PBStats::Omni, 2, dondozo, nil, abilitycheck: :hide)
        dondozo.effects[:Commandee] = true
        @battle.pbHideAbilityBox(tatsugiri)
      end
    end

    # Crowd Field comeback temp boost wear-off
    tempBoostRemovalCheck unless abilityactivation
  end

  def pbAbilitiesOnSwitchIn(applySwitchInAbility: false)
    return if @hp <= 0
    # Primal Reversions, Trace, Commander, Crowd Field comeback temp boost wear-off
    self.pbRegularIntervalChecks(abilityactivation: true)

    #### FORM CHECKS
    self.pbCheckFormRoundEnd
    self.pbCheckBurmyForm
    self.pbCheckWeatherForm



    #### NEUTRALIZING GAS
    if self.ability == :NEUTRALIZINGGAS
      @battle.pbAbilityBoxAndDisplay(self, _INTL("Neutralizing gas filled the area!"))
      priority = @battle.setSpeedOrder
      worked = false
      for battler in priority
        if !(PBStuff::FIXEDABILITIES + [:NEUTRALIZINGGAS]).include?(battler.ability)
          if battler.hasWorkingItem(:ABILITYSHIELD)
            @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!", battler.pbThis, getItemName(battler.item)))
          else
            battler.changeAbilityWithEffects(:suppress)
          end
        end
        if @battle.FE == :DEUXFINALIS
          for i in 1...battler.stages.length # skips HP
            if battler.stages[i] != 0
              battler.stages[i] = 0
              worked = true
            end
          end
        end
      end
      @battle.pbDisplay(_INTL("All stat changes have been cleared!")) if worked
    end

    #### START OF WEATHER ABILITIES
    # Primal Weather
    if self.ability == :PRIMORDIALSEA && !@battle.state.effects[:HeavyRain]
      @battle.pbShowAbilityBox(self)
      if @battle.canSetWeather?(:RAINDANCE, primal: true, showMessage: true)
        rainbowduration = self.hasWorkingItem(:DAMPROCK) ? 8 : 5
        message = _INTL("A heavy rain began to fall!")
        @battle.pbSetWeather(:RAINDANCE, -1, message, rainbowduration)
        @battle.state.effects[:HeavyRain] = true
      end
      if Rejuv && @battle.FE == :DEUXFINALIS && @battle.state.effects[:HeavyRain]
        message = _INTL("The salt world was flooded!")
        @battle.setField(:DIMENSIONAL, 0, message, ignoreOverlays: true)
        @battle.field.duration_condition = proc { |battle| battle.state.effects[:HeavyRain] == true }
      end
      @battle.pbHideAbilityBox(self)
    end

    if self.ability == :DESOLATELAND && !@battle.state.effects[:HarshSunlight]
      @battle.pbShowAbilityBox(self)
      if @battle.canSetWeather?(:SUNNYDAY, primal: true, showMessage: true)
        rainbowduration = self.hasWorkingItem(:HEATROCK) ? 8 : 5
        message = _INTL("The sunlight turned extremely harsh!")
        @battle.pbSetWeather(:SUNNYDAY, -1, message, rainbowduration)
        @battle.state.effects[:HarshSunlight] = true
      end
      @battle.pbHideAbilityBox(self)
      if Rejuv && @battle.FE == :GRASSY && @battle.state.effects[:HarshSunlight]
        message = _INTL("The extremely harsh sunlight dried out the meadow!")
        @battle.setField(:DESERT, 0, message)
      end
    end

    if self.ability == :DELTASTREAM && !@battle.state.effects[:DeltaStream]
      @battle.pbShowAbilityBox(self)
      if @battle.canSetWeather?(:STRONGWINDS, primal: true, showMessage: true)
        message = _INTL("A mysterious air current is protecting Flying-type Pokémon!")
        @battle.pbSetWeather(:STRONGWINDS, -1, message)
        @battle.state.effects[:DeltaStream] = true
      end
      @battle.pbHideAbilityBox(self)
    end

    # Surges
    duration = self.hasWorkingItem(:AMPLIFIELDROCK) ? 8 : 5
    if self.ability == :HADRONENGINE && @battle.FE == :NEWWORLD
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} used the energy of the New World to energize its futuristic engine!", pbThis))
    elsif self.ability == :HADRONENGINE && (@battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN)
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} used the Electric Terrain to energize its futuristic engine!", pbThis))
    elsif ([:ELECTRICSURGE, :HADRONENGINE].include?(self.ability) || self.crested == :RAIKOU) && @battle.FE != :ELECTERRAIN && @battle.OV != :ELECTERRAIN
      if self.crested == :RAIKOU
        @battle.pbShowAbilityBox(self, item: true)
        @battle.pbCommonAnimation("Rain")
      else
        @battle.pbShowAbilityBox(self)
      end
      if @battle.canChangeFE?(:ELECTERRAIN, showMessage: true)
        @battle.pbAnimation(:ELECTRICTERRAIN, self, nil)
        message = self.ability == :HADRONENGINE ? _INTL("{1} turned the ground into Electric Terrain, energizing its futuristic engine!", pbThis) : self.crested == :RAIKOU ? _INTL("A thunderstorm began whirling around {1}!", pbThis) : nil
        @battle.setField(:ELECTERRAIN, duration, message, user: self)
        @battle.state.effects[:RaikouStorm] = true if self.crested == :RAIKOU
      end
      @battle.pbHideAbilityBox(self)
    end
    if self.ability == :GRASSYSURGE && @battle.FE != :GRASSY && @battle.OV != :GRASSY
      @battle.pbShowAbilityBox(self)
      duration = 8 if Overlays && [:FOREST, :BEWITCHED].include?(@battle.FE)
      if @battle.canChangeFE?(:GRASSY, showMessage: true)
        @battle.pbAnimation(:GRASSYTERRAIN, self, nil)
        @battle.setField(:GRASSY, duration, nil)
      end
      @battle.pbHideAbilityBox(self)
    end
    if self.ability == :MISTYSURGE && @battle.FE != :MISTY && @battle.OV != :MISTY && (!Overlays || @battle.FE != :CORROSIVEMIST)
      @battle.pbShowAbilityBox(self)
      if @battle.canChangeFE?(:MISTY, showMessage: true)
        @battle.pbAnimation(:MISTYTERRAIN, self, nil)
        @battle.setField(:MISTY, duration, nil)
      end
      @battle.pbHideAbilityBox(self)
    end
    if self.ability == :PSYCHICSURGE && @battle.FE != :PSYTERRAIN && @battle.OV != :PSYTERRAIN
      @battle.pbShowAbilityBox(self)
      if @battle.canChangeFE?(:PSYTERRAIN, showMessage: true)
        @battle.pbAnimation(:PSYCHICTERRAIN, self, nil)
        @battle.setField(:PSYTERRAIN, duration, nil)
      end
      @battle.pbHideAbilityBox(self)
    end
    if self.ability == :DARKSURGE
      @battle.pbShowAbilityBox(self)
      if @battle.FE == :DARKNESS3
        self.pbChangeStats(PBStats::SPEED, 1, self, nil)
      elsif [:DARKNESS2, :DARKNESS1].include?(@battle.FE)
        message = _INTL("{1} deepened the darkness!", pbThis)
        @battle.growField(message, self)
      elsif @battle.canChangeFE?(:DARKNESS2, showMessage: true)
        message = _INTL("Darkness gathers...")
        @battle.setField(:DARKNESS2, 3, message)
      end
      @battle.pbHideAbilityBox(self)
    end

    # Curious Medicine
    if self.ability == :CURIOUSMEDICINE
      worked = false
      if @battle.FE == :BEWITCHED
        @battle.battlers.each { |j|
          for i in 1...j.stages.length # skips HP
            if j.stages[i] != 0
              j.stages[i] = 0
            end
          end
        }
        @battle.pbAbilityBoxAndDisplay(self, _INTL("All stat changes on the field were eliminated!"))
      else
        for i in 1...pbPartner.stages.length # skips HP
          if pbPartner.stages[i] != 0
            pbPartner.stages[i] = 0
            worked = true
          end
        end
        @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s stat changes were eliminated!", pbPartner.pbThis)) if worked
      end
    end

    # Hospitality
    if self.ability == :HOSPITALITY && pbPartner.hp > 0
      if pbPartner.canHeal?
        @battle.pbShowAbilityBox(self)
        pbPartner.pbRecoverHP((pbPartner.totalhp / 4.0).floor, true, message: _INTL("{1} drank down all the matcha that {2} made!", pbPartner.pbThis, pbThis(true)))
        @battle.pbHideAbilityBox(self)
      end
    end

    # Sworn Duty - Rejuv Custom Ability
    if self.ability == :SWORNDUTY && pbPartner.hp > 0
      if pbPartner.canHeal?
        @battle.pbShowAbilityBox(self)
        healing = @battle.FE == :FAIRYTALE ? (pbPartner.totalhp / 3.0).floor : (pbPartner.totalhp / 4.0).floor
        pbPartner.pbRecoverHP(healing, true, message: _INTL("{1} shared its mead with {2}!", pbThis, pbPartner.pbThis))
        @battle.pbHideAbilityBox(self)
      end
    end

    # Gravity Control
    if self.ability == :GRAVITYCONTROL && @battle.state.effects[:Gravity] == 0
      @battle.pbShowAbilityBox(self)
      @battle.pbAnimation(:GRAVITY, self, nil)
      duration = self.hasWorkingItem(:AMPLIFIELDROCK) || @battle.FE == :PSYTERRAIN ? 8 : 5
      duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
      @battle.pbDisplay(_INTL("Gravity intensified!"))
      @battle.pbSetGravity(duration)
      # Handle Gravity-related field interactions
      basemove = PokeBattle_Move.pbFromPBMove(@battle, PBMove.new(:GRAVITY), @pokemon)
      @battle.fieldEffectAfterMove(basemove, self, [])
      @battle.pbHideAbilityBox(self)
    end

    # Weather Abilities
    if self.ability == :DRIZZLE && @battle.weather != :RAINDANCE
      @battle.pbShowAbilityBox(self)
      if @battle.canSetWeather?(:RAINDANCE, showMessage: true)
        duration = self.hasWorkingItem(:DAMPROCK) || [:CLOUDS, :SKY].include?(@battle.FE) ? 8 : 5
        duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
        rainbowduration = duration
        duration = -1 if $game_switches[:Gen_5_Weather] == true && !@battle.isOnline?
        @battle.pbSetWeather(:RAINDANCE, duration, nil, rainbowduration)
      end
      @battle.pbHideAbilityBox(self)
    end

    if self.ability == :SANDSTREAM && @battle.weather != :SANDSTORM
      @battle.pbShowAbilityBox(self)
      if @battle.canSetWeather?(:SANDSTORM, showMessage: true)
        duration = self.hasWorkingItem(:SMOOTHROCK) || [:DESERT, :ASHENBEACH, :SKY].include?(@battle.FE) ? 8 : 5
        duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
        duration = -1 if $game_switches[:Gen_5_Weather] == true && !@battle.isOnline?
        @battle.pbSetWeather(:SANDSTORM, duration)
      end
      @battle.pbHideAbilityBox(self)
    end

    if self.ability == :ORICHALCUMPULSE && @battle.FE == :NEWWORLD
      @battle.pbAbilityBoxAndDisplay(self, _INTL("The energy of the New World sent {1}'s ancient pulse into a frenzy!", pbThis))
    elsif self.ability == :ORICHALCUMPULSE && @battle.weather == :SUNNYDAY
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} basked in the sunlight, sending its ancient pulse into a frenzy!", pbThis))
    elsif [:DROUGHT, :ORICHALCUMPULSE].include?(self.ability) && @battle.weather != :SUNNYDAY
      @battle.pbShowAbilityBox(self)
      if @battle.canSetWeather?(:SUNNYDAY, showMessage: true)
        duration = self.hasWorkingItem(:HEATROCK) || [:DESERT, :MOUNTAIN, :SNOWYMOUNTAIN, :SKY].include?(@battle.FE) ? 8 : 5
        duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
        rainbowduration = duration
        duration = -1 if $game_switches[:Gen_5_Weather] == true && !@battle.isOnline?
        message = self.ability == :ORICHALCUMPULSE ? _INTL("{1} turned the sunlight harsh, sending its ancient pulse into a frenzy!", pbThis) : nil
        @battle.pbSetWeather(:SUNNYDAY, duration, message, rainbowduration)
      end
      @battle.pbHideAbilityBox(self)
    end

    if [:HAILWARNING, :SNOWWARNING].include?(self.ability)
      weather = self.ability == :SNOWWARNING ? :SNOW : :HAIL
      if @battle.weather != weather
        @battle.pbShowAbilityBox(self)
        if @battle.canSetWeather?(weather, showMessage: true)
          duration = self.hasWorkingItem(:ICYROCK) || [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION, :SKY, :CLOUDS].include?(@battle.FE) ? 8 : 5
          duration = 3 + @battle.pbRandom(6) if @battle.FE == :DIMENSIONAL
          duration = -1 if $game_switches[:Gen_5_Weather] == true && !@battle.isOnline?
          @battle.pbSetWeather(weather, duration)
        end
        @battle.pbHideAbilityBox(self)
      end
    end

    if self.ability == :TEMPEST
      weather = @battle.sample([:RAINDANCE, :HAIL, :SANDSTORM, :STRONGWINDS, :SHADOWSKY] - [@battle.weather])
      case weather
        when :RAINDANCE then message = _INTL("Storm-9 created a downpour!")
        when :HAIL then message = _INTL("Storm-9 brought hailfall!")
        when :SANDSTORM then message = _INTL("Storm-9 whipped up a duststorm!")
        when :STRONGWINDS then message = _INTL("Storm-9 whipped up terrible winds!")
        when :SHADOWSKY then message = _INTL("Storm-9 shrouded the sky in a shadowy aura...")
      end
      @battle.pbShowAbilityBox(self)
      @battle.pbSetWeather(weather, 8, message)
      @battle.pbHideAbilityBox(self)
    end

    if [:AIRLOCK, :CLOUDNINE].include?(self.ability)
      @battle.pbAbilityBoxAndDisplay(self, _INTL("The effects of the weather disappeared."))
      @battle.setSpeedOrder.each { |i| i.pbCheckWeatherForm }
      @battle.protosynthesisCheck
    end
    # Message-only activations
    case self.ability
      when :PRESSURE then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} is exerting its pressure!", pbThis)) if !(PBStuff::DimensionalFields.include?(@battle.FE))
      when :MOLDBREAKER then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} breaks the mold!", pbThis))
      when :COMATOSE then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} is drowsing!", pbThis)) if @battle.FE != :ELECTERRAIN
      when :TERAVOLT then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} is radiating a bursting aura!", pbThis))
      when :TURBOBLAZE then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} is radiating a blazing aura!", pbThis))
      when :FAIRYAURA then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} is radiating a fairy aura!", pbThis))
      when :DARKAURA then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} is radiating a dark aura!", pbThis))
      when :AURABREAK then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} reversed all other Pokémon's auras!", pbThis))
      when :ASONECHILLING, :ASONEGRIM then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} has two Abilities!", pbThis))
      when :WINGSOFRUIN then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s {2} lowered the {3} of all surrounding Pokémon!", pbThis, getAbilityName(self.ability), getStatName(PBStats::SPEED)))
      when :BEADSOFRUIN then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s {2} weakened the {3} of all surrounding Pokémon!", pbThis, getAbilityName(self.ability), getStatName(PBStats::SPDEF)))
      when :SWORDOFRUIN then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s {2} weakened the {3} of all surrounding Pokémon!", pbThis, getAbilityName(self.ability), getStatName(PBStats::DEFENSE)))
      when :TABLETSOFRUIN then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s {2} weakened the {3} of all surrounding Pokémon!", pbThis, getAbilityName(self.ability), getStatName(PBStats::ATTACK)))
      when :VESSELOFRUIN then @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s {2} weakened the {3} of all surrounding Pokémon!", pbThis, getAbilityName(self.ability), getStatName(PBStats::SPATK)))
    end

    # Mimicry
    self.pbMimicry

    # Ice Face
    if self.ability == :ICEFACE && self.form == 1 && self.species == :EISCUE
      if [:HAIL, :SNOW].include?(@battle.weather)
        @battle.pbShowAbilityBox(self)
        self.pbRegenFace
        @battle.pbDisplay(_INTL("{1} transformed!", self.pbThis))
        @battle.pbHideAbilityBox(self)
      end
    end

    # Pastel Veil
    if self.ability == :PASTELVEIL && @battle.FE != :INFERNAL
      if self.pbPartner.status == :POISON
        @battle.pbShowAbilityBox(self)
        self.pbPartner.pbCureStatus
        @battle.pbHideAbilityBox(self)
      end
    end

    # Intimidate
    if self.ability == :INTIMIDATE
      for i in [pbOpposing1, pbOpposing2]
        next unless i.passiveAbilityApplies?

        @battle.pbShowAbilityBox(self)
        stats = @battle.FE == :CROWD ? PBStats::Physical : [PBStats::ATTACK]
        # Adrenaline Orb triggers even if Intimidate fails, unless it's due to being behind Sub or Attack being too low (taking into account Contrary)
        triggerAdrenaline = i.hasWorkingItem(:ADRENALINEORB) && i.effects[:Substitute] == 0 && stats.any? { |stat| !i.pbTooLowEX?(stat) }
        # Failures
        failure = false
        # Guard Dog (always activates regardless of failure conditions, except Sub)
        if i.ability == :GUARDDOG && i.effects[:Substitute] == 0
          @battle.pbShowAbilityBox(i)
          i.pbChangeStats(PBStats::ATTACK, 1, i, nil)
          @battle.pbHideAbilityBox(i)
          failure = true
        # Other failure conditions
        elsif !i.pbCanReduceAnyStat?(stats, self, :Intimidate, showMessage: true)
          failure = true
        # Anti-Intimidate Abilities
        elsif PBStuff::NoIntimidateAbilities.include?(i.ability)
          message = stats.length == 1 ? _INTL("{1}'s {2} was not lowered!", i.pbThis, getStatName(stats[0])) : _INTL("{1}'s stats were not lowered!", i.pbThis)
          @battle.pbAbilityBoxAndDisplay(i, message)
          failure = true
        end
        # Actual stat drop
        worked = !failure && i.pbChangeStats(stats, -1, self, :Intimidate)
        # Rattled
        if worked && Gen >= 8 && i.ability == :RATTLED
          @battle.pbShowAbilityBox(i)
          i.pbChangeStats(PBStats::SPEED, 1, i, nil)
          @battle.pbHideAbilityBox(i)
        end
        # Adrenaline Orb
        i.triggerAdrenalineOrb(delaysymbiosis: true) if triggerAdrenaline
      end
      # Symbiosis after Adr Orb (Symbiosis should activate only after both pokemon have had a chance to use their Adr Orbs)
      [pbOpposing1, pbOpposing2].each { |i| i.pbSymbiosis if i.effects[:DelaySymbiosis] }
      @battle.pbHideAbilityBox(self)
    end

    # Supersweet Syrup
    if self.ability == :SUPERSWEETSYRUP && !self.permeffs[:SupersweetSyrup]
      messageshown = false
      for i in [pbOpposing1, pbOpposing2]
        next unless i.passiveAbilityApplies?

        @battle.pbShowAbilityBox(self)
        @battle.pbDisplay(_INTL("A supersweet aroma is wafting from the syrup covering {1}!", pbThis(true))) if !messageshown
        messageshown = true
        i.pbChangeStats(PBStats::EVASION, -1, self, :Intimidate)
        self.permeffs[:SupersweetSyrup] = true
      end
      @battle.pbHideAbilityBox(self)
    end

    # Saccharine Nectar
    if self.ability == :SACCHARINENECTAR && !self.permeffs[:SaccharineNectar]
      messageshown = false
      for i in @battle.battlers
        next if !self.pbIsOpposing?(i.index)
        next if i.isFainted? && !(i.isbossmon && i.shieldCount > 0)

        @battle.pbShowAbilityBox(self)
        @battle.pbDisplay(_INTL("A supersweet aroma is wafting from {1}!", pbThis(true))) if !messageshown
        messageshown = true
        i.pbChangeStats(PBStats::SPEED, -1, self, :Intimidate)
        self.permeffs[:SaccharineNectar] = true
      end
      @battle.pbHideAbilityBox(self)
    end
    # Rejuv abilities
    rejuvAbilities if Rejuv

    # Download
    if self.ability == :DOWNLOAD
      if Rejuv && [:GLITCH].include?(@battle.FE)
        if pbCanIncreaseAnyStat?(PBStats::Offensive, self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("{1} is glitching out!", pbThis))
          pbChangeStats(PBStats::Offensive, 1, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      else
        odef = ospdef = 0
        opp1 = pbOpposing1
        opp2 = pbOpposing2
        if opp1 && opp1.hp > 0
          odef += opp1.defense * PBStats::StageMul[opp1.stages[PBStats::DEFENSE] + 6]
          ospdef += opp1.spdef * PBStats::StageMul[opp1.stages[PBStats::SPDEF] + 6]
        end
        if opp2 && opp2.hp > 0
          odef += opp2.defense * PBStats::StageMul[opp2.stages[PBStats::DEFENSE] + 6]
          ospdef += opp2.spdef * PBStats::StageMul[opp2.stages[PBStats::SPDEF] + 6]
        end
        stat = ospdef > odef ? PBStats::ATTACK : PBStats::SPATK
        if pbCanIncreaseStatStage?(stat, self, nil)
          @battle.pbShowAbilityBox(self)
          increment = [:FACTORY, :CITY, :BACKALLEY].include?(@battle.FE) ? 2 : 1
          pbChangeStats(stat, increment, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end


    if self.ability == :QUARKDRIVE && @battle.FE == :GLITCH
      @battle.pbShowAbilityBox(self)
      @battle.pbCommonAnimation("SilvallyGlitch", self, nil)
      @battle.pbDisplay(_INTL("{1} was corrupted by the rogue data!", pbThis))
      self.effects[:TemporaryType] = :QMARKS
      @battle.pbHideAbilityBox(self)
    end

    # Defragment
    if self.ability == :DEFRAGMENT
      if Rejuv && [:GLITCH].include?(@battle.FE)
        if pbCanIncreaseAnyStat?([PBStats::DEFENSE, PBStats::SPDEF], self, nil)
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("{1} is glitching out!", pbThis))
          pbChangeStats([PBStats::DEFENSE, PBStats::SPDEF], 1, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      else
        oatt = ospatk = 0
        opp1 = pbOpposing1
        opp2 = pbOpposing2
        if opp1 && opp1.hp > 0
          oatt += opp1.attack * PBStats::StageMul[opp1.stages[PBStats::ATTACK] + 6]
          ospatk += opp1.spatk * PBStats::StageMul[opp1.stages[PBStats::SPATK] + 6]
        end
        if opp2 && opp2.hp > 0
          oatt += opp2.attack * PBStats::StageMul[opp2.stages[PBStats::ATTACK] + 6]
          ospatk += opp2.spatk * PBStats::StageMul[opp2.stages[PBStats::SPATK] + 6]
        end
        stat = ospatk > oatt ? PBStats::SPDEF : PBStats::DEFENSE
        if pbCanIncreaseStatStage?(stat, self, nil)
          @battle.pbShowAbilityBox(self)
          increment = [:FACTORY, :CITY, :BACKALLEY].include?(@battle.FE) ? 2 : 1
          pbChangeStats(stat, increment, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    end

    # Screen Cleaner
    if self.ability == :SCREENCLEANER
      if @battle.sides.any? { |side| side.anyScreenActive? }
        @battle.pbShowAbilityBox(self)
        @battle.pbEndSideEffects(@battle.sides, PBStuff::SCREENEFFECTS.values)
      end
      if @battle.FE == :MIRROR
        mirrorCleaned = false
        for i in 0...4
          mirrorCleaned = true if @battle.battlers[i].stages[PBStats::ACCURACY] != 0 || @battle.battlers[i].stages[PBStats::EVASION] != 0
          @battle.battlers[i].stages[PBStats::ACCURACY] = 0
          @battle.battlers[i].stages[PBStats::EVASION] = 0
        end
        if mirrorCleaned
          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("The mirrors were cleaned!"))
        end
      end
      @battle.pbHideAbilityBox(self)
    end

    # Dauntless Shield
    if self.ability == :DAUNTLESSSHIELD
      if [:FAIRYTALE, :COLOSSEUM].include?(@battle.FE)
        if pbCanIncreaseAnyStat?(PBStats::Defensive, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::Defensive, 1, self, nil, abilitycheck: :hide)
          @battle.pbDisplay(_INTL("The fighting master's shield protects {1}!", pbThis(true)))
          @battle.pbHideAbilityBox(self)
        end
      elsif Gen < 9 || !self.permeffs[:DauntlessShield]
        if pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::DEFENSE, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
        self.permeffs[:DauntlessShield] = true
      end
    end

    # Intrepid Sword
    if self.ability == :INTREPIDSWORD
      if [:FAIRYTALE, :COLOSSEUM].include?(@battle.FE)
        if pbCanIncreaseAnyStat?(PBStats::Offensive, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::Offensive, 1, self, nil, abilitycheck: :hide)
          @battle.pbDisplay(_INTL("The fairy king's sword empowered {1}!", pbThis(true)))
          @battle.pbHideAbilityBox(self)
        end
      elsif Gen < 9 || !self.permeffs[:IntrepidSword]
        if pbCanIncreaseStatStage?(PBStats::ATTACK, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::ATTACK, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
        self.permeffs[:IntrepidSword] = true
      end
    end

    # Embody Aspect
    stat = nil
    case self.ability
      when :EMBODYASPECTTEAL then stat, mask = PBStats::SPEED, :TEALMASK
      when :EMBODYASPECTWELLSPRING then stat, mask = PBStats::SPDEF, :WELLSPRINGMASK
      when :EMBODYASPECTHEARTHFLAME then stat, mask = PBStats::ATTACK, :HEARTHFLAMEMASK
      when :EMBODYASPECTCORNERSTONE then stat, mask = PBStats::DEFENSE, :CORNERSTONEMASK
    end
    if stat && pbCanIncreaseStatStage?(stat, self, nil)
      @battle.pbShowAbilityBox(self)
      pbChangeStats(stat, 1, self, nil, statmessage: mask, abilitycheck: :skip)
      @battle.pbHideAbilityBox(self)
    end

    # Zero to Hero
    if self.ability == :ZEROTOHERO && self.permeffs[:ZeroToHero] == :transformed
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} underwent a heroic transformation!", pbThis))
      if @battle.FE == :BIGTOP
        self.effects[:HelpingHand] += 1
        @battle.pbAnimation(:HELPINGHAND, self, nil)
        @battle.pbDisplay(_INTL("The crowd cheers for {1}!", pbThis(true)))
      end
      self.permeffs[:ZeroToHero] = :sentout
    end

    # Supreme Overlord
    if self.ability == :SUPREMEOVERLORD && self.pbOwnSide.effects[:AlliesFainted] > 0
      # Supreme Overlord in canon takes a snapshot of fainted allies on switch-in and doesn't update it while battling.
      self.effects[:SupremeOverlord] = [self.pbOwnSide.effects[:AlliesFainted], 5].min
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} gained strength from the fallen!", pbThis))
    end

    # Slow Start
    if self.ability == :SLOWSTART && self.effects[:SlowStart] < 5 && @battle.FE != :DEEPEARTH
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} is slow to get going!", pbThis))
    end

    # Frisk
    if self.ability == :FRISK
      if @battle.FE == :CITY
        messageshown = false
        for i in [pbOpposing1, pbOpposing2]
          next unless i.passiveAbilityApplies?

          @battle.pbShowAbilityBox(self)
          @battle.pbDisplay(_INTL("Just a routine inspection.")) if !messageshown
          messageshown = true
          i.pbChangeStats(PBStats::SPDEF, -1, self, :Intimidate)
        end
      end

      items = []
      items.push(pbOpposing1) if pbOpposing1.item && !pbOpposing1.isFainted?
      items.push(pbOpposing2) if pbOpposing2.item && !pbOpposing2.isFainted?
      frisked = false
      for i in items
        @battle.pbShowAbilityBox(self)
        itemname = getItemName(i.item)
        message = frisked ? _INTL("{1} was frisked, revealing its {2}!", i.name, itemname) : _INTL("{1} frisked {2} and found its {3}!", pbThis, i.pbThis(true), itemname)
        @battle.pbDisplay(message)
        @battle.ai.discloseItem(i)

        if @battle.FE == :BACKALLEY
          wildBattle = @battle.pbIsWild? && @battle.battlers.none? { |battler| battler.isbossmon && battler.pokemon.bossID != :SHADOWDEN }
          if self.item.nil? && i.effects[:Substitute] == 0 &&
             (i.ability != :STICKYHOLD || i.moldbroken) &&
             !@battle.pbIsUnlosableItem(i, i.item) &&
             !@battle.pbIsUnlosableItem(self, i.item) &&
             !(wildBattle && !@battle.pbIsOpposing?(i)) # doesn't work against the player in wild battles
            @battle.pbCommonAnimation("Covet", self, i)
            @battle.pbDisplay(_INTL("Don't mind if I do!"))
            i.transferItem(self)
          end
        end
        frisked = true
      end

      @battle.pbHideAbilityBox(self)
    end

    # Anticipation
    if self.ability == :ANTICIPATION
      found = false
      for foe in [pbOpposing1, pbOpposing2]
        next if foe.isFainted?

        for j in foe.moves
          eff = PBTypes.typesEff(j.type, self.types, inverse: @battle.inverse?)
          if (j.pbIsDamaging? && eff.superEffective? &&
             ![0x71, 0x72, 0x73].include?(j.function)) || # Counter, Mirror Coat, Metal Burst
             (j.function == 0x70 && !eff.immune?) # OHKO
            found = true
            break
          end
        end
        break if found
      end
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} shuddered!", pbThis)) if found
    end

    # Unnerve
    if PBStuff::UnnerveAbilities.include?(self.ability) && !(PBStuff::DimensionalFields.include?(@battle.FE))
      display_abil = [:ASONECHILLING, :ASONEGRIM].include?(self.ability) ? :UNNERVE : self.ability
      msg = @battle.pbIsOpposing?(@index) ?
        _INTL("Your team is too nervous to eat Berries!") :
        _INTL("The opposing team is too nervous to eat Berries!")
      @battle.pbAbilityBoxAndDisplay(self, msg, attrname: getAbilityName(display_abil))
    end

    # Forewarn
    if self.ability == :FOREWARN
      highestpower = 0
      moves = []
      opponents = []
      for foe in [pbOpposing1, pbOpposing2]
        next if foe.isFainted?

        for j in foe.moves
          power = j.basedamage
          power = 160 if j.function == 0x70 # OHKO
          power = 150 if j.function == 0x8B # Eruption
          power = 120 if [0x71, 0x72, 0x73].include?(j.function) # Counter, Mirror Coat, Metal Burst
          power = 80 if [0x6A, 0x6B, 0x6D, 0x6E, 0x6F, 0x89, 0x8A, 0x8C, 0x8D, 0x90, 0x96, 0x97, 0x98, 0x9A].include?(j.function)
          # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave, Return, Frustration, Crush Grip, Gyro Ball, Hidden Power, Natural Gift, Trump Card, Flail, Grass Knot
          if power > highestpower
            highestpower = power
            moves = [j.move]
            opponents = [foe]
          elsif power == highestpower
            moves.push(j.move)
            opponents.push(foe)
          end
        end
      end
      if moves.length > 0
        chosen = @battle.pbRandom(moves.length)
        move = moves[chosen]
        opponent = opponents[chosen]
        @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s {2} was revealed!", opponent.pbThis, getMoveName(move)))
        warnedMove = PokeBattle_Move.pbFromPBMove(@battle, PBMove.new(move), self.pokemon)
        @battle.ai.addMoveToMemory(opponent, warnedMove)
      end
    end

    # Costar
    if self.ability == :COSTAR && pbPartner.hp > 0
      @battle.pbShowAbilityBox(self)
      @battle.pbCommonAnimation("Costar", self, pbPartner)
      for i in 1...pbPartner.stages.length
        self.stages[i] = pbPartner.stages[i]
      end
      self.effects[:FocusEnergy] = pbPartner.effects[:FocusEnergy]
      @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!", pbThis, pbPartner.pbThis(true)))
      if @battle.FE == :BIGTOP
        pbChangeStats(PBStats::Offensive, 1, self, nil, abilitycheck: :hide)
      end
      @battle.pbHideAbilityBox(self)
    end

    # Quark Drive
    if self.ability == :QUARKDRIVE && self.effects[:Quarkdrive][0] == 0 && !self.effects[:Transform]
      boostStat = self.getHighestStatWithStages
      if @battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN
        self.effects[:Quarkdrive] = [boostStat, false]
        @battle.pbAbilityBoxAndDisplay(self, _INTL("The Electric Terrain activated {1}'s {2}, heightening its {3}!", pbThis(true), getAbilityName(self.ability), getStatName(boostStat)))
      elsif self.hasWorkingItem(:BOOSTERENERGY)
        @battle.pbCommonAnimation("UseItem", self, nil)
        self.effects[:Quarkdrive] = [boostStat, true]
        @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} used its {2} to activate {3}, heightening its {4}!", pbThis, getItemName(self.item), getAbilityName(self.ability), getStatName(boostStat)))
        self.pbDisposeItem
      end
    end

    # Protosynthesis
    if self.ability == :PROTOSYNTHESIS && self.effects[:Protosynthesis][0] == 0 && !self.effects[:Transform]
      boostStat = self.getHighestStatWithStages
      if @battle.pbWeather(nil) == :SUNNYDAY
        self.effects[:Protosynthesis] = [boostStat, false]
        @battle.pbAbilityBoxAndDisplay(self, _INTL("The harsh sunlight activated {1}'s {2}, heightening its {3}!", pbThis(true), getAbilityName(self.ability), getStatName(boostStat)))
      elsif self.hasWorkingItem(:BOOSTERENERGY)
        @battle.pbCommonAnimation("UseItem", self, nil)
        self.effects[:Protosynthesis] = [boostStat, true]
        @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} used its {2} to activate {3}, heightening its {4}!", pbThis, getItemName(self.item), getAbilityName(self.ability), getStatName(boostStat)))
        self.pbDisposeItem
      end
    end

    # Wind Rider when switching in with Tailwind already up
    if self.ability == :WINDRIDER && self.pbOwnSide.effects[:Tailwind] > 0
      if self.pbCanIncreaseStatStage?(PBStats::ATTACK, self, nil)
        @battle.pbShowAbilityBox(self)
        self.pbChangeStats(PBStats::ATTACK, 1, self, nil, abilitycheck: :skip)
        @battle.pbHideAbilityBox(self)
      end
    end

    # Field and Overlay Ability boosts on entry
    self.pbAbilitiesOnOverlay(true, applySwitchInAbility: applySwitchInAbility)
    self.pbAbilitiesOnField(true, applySwitchInAbility: applySwitchInAbility)

    # Opportunist / Mirror Herb / White Herb / Eject Pack
    @battle.pbStatChangeChecks

  end

  def leaveField
    @onField = false
    self.permeffs[:HitsTaken] = 0 if Gen >= Champs
    self.pbResetForm
    self.entryText = nil
    self.endTurn = false
    self.disableAbility
    if self.isbossmon
      self.bossDelayList = nil
    end
    if self.crested == :RAIKOU
      if @battle.state.effects[:RaikouStorm] == true
        @battle.endTempFieldOrOverlay if (@battle.OV == :ELECTERRAIN || @battle.FE == :ELECTERRAIN)
      end
    end
  end

  def disableAbility(clearedAbility = :none)
    # clearedAbility is passed by changeAbility where we want to disable the old ability, not the new one (note that the old ability can also be nil)
    ability = clearedAbility != :none ? clearedAbility : self.ability

    globalAbilities = [:NEUTRALIZINGGAS, :CLOUDNINE, :AIRLOCK, :PRIMORDIALSEA, :DESOLATELAND, :DELTASTREAM, :TEMPEST, :DARKSURGE]
    sideAbilities = PBStuff::UnnerveAbilities
    return unless (globalAbilities + sideAbilities).include?(ability)

    # Ability has to be taken away for global/side checks to recognize the ability not being on field anymore
    self.ability = nil if clearedAbility == :none

    if globalAbilities.include?(ability)
      abilities = [:CLOUDNINE, :AIRLOCK].include?(ability) ? [:CLOUDNINE, :AIRLOCK] : [ability]
      abilityactive = @battle.pbCheckGlobalAbility(abilities)
    else
      abilities = PBStuff::UnnerveAbilities.include?(ability) ? PBStuff::UnnerveAbilities : [ability]
      abilityactive = @battle.pbCheckSideAbility(abilities, self).any?
    end
    return if abilityactive

    case ability
      when :NEUTRALIZINGGAS
        @battle.pbDisplay(_INTL("The effects of the neutralizing gas wore off!"))
        priority = @battle.setSpeedOrder
        for pkmn in priority
          if pkmn.index != self.index && !pkmn.effects[:GastroAcid] && pkmn.ability.nil? && !pkmn.backupability.nil?
            pkmn.ability = pkmn.backupability
            pkmn.pbAbilitiesOnSwitchIn
          end
        end
      when :CLOUDNINE, :AIRLOCK
        @battle.setSpeedOrder.each { |i| i.pbCheckWeatherForm }
        @battle.protosynthesisCheck
      when :PRIMORDIALSEA
        @battle.pbEndWeather if @battle.state.effects[:HeavyRain]
      when :DESOLATELAND
        @battle.pbEndWeather if @battle.state.effects[:HarshSunlight]
      when :DELTASTREAM
        @battle.pbEndWeather if @battle.state.effects[:DeltaStream]
      when :TEMPEST
        @battle.noWeather
      when :DARKSURGE
        if PBFields::DARKNESS.include?(@battle.FE) && @battle.field.duration > 0
          @battle.field.duration = 0
          @battle.endTempField
        end
      when *PBStuff::UnnerveAbilities
        priority = @battle.setSpeedOrder
        priority.each { |pkmn| pkmn.pbBerryHerbCheck if self.pbIsOpposing?(pkmn.index) }
    end

    # Ability has to be given back after the global/side checks are done
    # This is needed for activation of abilities like Regenerator, Natural Cure and Zero To Hero
    self.ability = ability if clearedAbility == :none
  end

  def pbEffectsOnDealingDamage(move, user, target, damage, attackerNotPresent = false, futureSight = false)
    return if target.nil?
    return if move.pbIsStatus?
    primaryType = move.pbType(user)
    movetypes = [primaryType, *move.getSecondaryType(user, primaryType)]
    physicalmove = move.pbIsPhysical?(user, movetypes[0])
    specialmove = move.pbIsSpecial?(user, movetypes[0])

    # Make the target flinch
    # needs to be checked before mummy/wandering spirit stench is check before ability change
    unless target.damagestate.substitute
      if (target.ability != :SHIELDDUST || target.moldbroken) && !target.hasWorkingItem(:COVERTCLOAK)
        if (user.hasWorkingItem(:KINGSROCK) || user.hasWorkingItem(:RAZORFANG)) && !move.canFlinch? && !(user.ability == :SHEERFORCE && move.effect > 0)
          sample = (@battle.FE == :RAINBOW || @battle.OV == :RAINBOW || user.ability == :SERENEGRACE) ? 5 : 10
          if @battle.pbRandom(sample) == 0
            target.effects[:Flinch] = true
          end
        elsif user.ability == :STENCH && !move.canFlinch?
          sample = [:WASTELAND, :MURKWATERSURFACE, :BACKALLEY, :CITY].include?(@battle.FE) ? 5 : 10
          if @battle.pbRandom(sample) == 0
            target.effects[:Flinch] = true
          end
        end
        if user.ability == :TOXICCHAIN && @battle.pbRandom(10) < 3
          if target.pbCanPoison?(user, move)
            @battle.pbShowAbilityBox(user)
            target.pbPoison(user, true)
            @battle.pbHideAbilityBox(user)
          end
        end
        # Sword of Ruin Deux Finalis effect
        if user.ability == :SWORDOFRUIN && @battle.FE == :DEUXFINALIS && target.pbCanPetrify?(user, move)
          @battle.pbShowAbilityBox(user)
          target.pbPetrify(user)
          @battle.pbHideAbilityBox(user)
        end
        if user.ability == :CORROSION && @battle.FE == :WASTELAND && @battle.pbRandom(10) == 0
          case @battle.pbRandom(4)
            when 0
              if target.pbCanBurn?(user, move)
                @battle.pbShowAbilityBox(user)
                target.pbBurn(user)
              end
            when 1
              if target.pbCanPoison?(user, move)
                @battle.pbShowAbilityBox(user)
                target.pbPoison(user)
              end
            when 2
              if target.pbCanParalyze?(user, move)
                @battle.pbShowAbilityBox(user)
                target.pbParalyze(user)
              end
            when 3
              if target.pbCanFreeze?(user, move)
                @battle.pbShowAbilityBox(user)
                target.pbFreeze
              end
          end
          @battle.pbHideAbilityBox(user)
        end
      end
    end
    if !target.damagestate.substitute && !move.zmove && user.makesContact?(move)
      eschance = 3
      eschance = 6 if @battle.FE == :CORRUPTED
      if user.ability == :POISONTOUCH && target.pbCanPoison?(user, move) && (target.ability != :SHIELDDUST || target.moldbroken) && !target.hasWorkingItem(:COVERTCLOAK) && @battle.pbRandom(10) < eschance
        @battle.pbShowAbilityBox(user)
        target.pbPoison(user)
        @battle.pbHideAbilityBox(user)
      end
      unless user.hasWorkingItem(:PROTECTIVEPADS)
        if target.effects[:BeakBlast] && user.pbCanBurn?(target, nil)
          user.pbBurn(target)
        end
        if target.ability == :AFTERMATH && !user.isFainted? && target.hp <= 0 && !@battle.pbCheckGlobalAbility(:DAMP) && !@battle.magicGuardAbilities.include?(user.ability)
          @battle.pbShowAbilityBox(target)
          damagedivider = @battle.FE == :CORROSIVEMIST ? 2.0 : 4.0
          user.pbReduceHP((user.totalhp / damagedivider).floor, true, message: _INTL("{1} was hurt!", user.pbThis))
          @battle.pbHideAbilityBox(target)
        end
        if [:IRONBARBS, :ROUGHSKIN].include?(target.ability) && !user.isFainted? && !@battle.magicGuardAbilities.include?(user.ability)
          @battle.pbShowAbilityBox(target)
          user.pbReduceHP((user.totalhp / 8.0).floor, true)
          @battle.pbHideAbilityBox(target)
        end
        if target.hasWorkingItem(:ROCKYHELMET, ignorefainted: true) && !user.isFainted? && !@battle.magicGuardAbilities.include?(user.ability)
          @battle.pbShowAbilityBox(target, item: true)
          user.pbReduceHP((user.totalhp / 6.0).floor, true)
          @battle.pbHideAbilityBox(target)
        end
        if target.pbOwnSide.effects[:AntiMatterShield] != 0  && !user.isFainted? && !@battle.magicGuardAbilities.include?(user.ability)
          user.pbReduceHP((user.totalhp / 6.0).floor, true)
          @battle.pbDisplay(_INTL("{1} hurt itself on the Anti-Matter Shield!", user.pbThis))
        end
        if target.ability == :EXTRAFLUFFYMANE && !user.isFainted? && !target.isFainted? && user.effects[:MultiTurn] == 0
          @battle.pbShowAbilityBox(target)
          user.effects[:MultiTurn] = 5
          user.effects[:MultiTurnAttack] = :BIND
          user.effects[:MultiTurnUser] = target.index
          user.effects[:BindingBand] = target.hasWorkingItem(:BINDINGBAND)
          @battle.pbDisplay(_INTL("{1}'s fluffy mane trapped {2}!", target.pbThis, user.pbThis(true)))
          @battle.pbHideAbilityBox(target)
        end
        eschance = 3
        eschance = 6 if [:FOREST, :WASTELAND, :BEWITCHED].include?(@battle.FE)
        # Effect Spore
        if !user.powderImmune? && target.ability == :EFFECTSPORE && @battle.pbRandom(10) < eschance
          rnd = @battle.pbRandom(3)
          if rnd == 0 && user.pbCanPoison?(target, nil)
            @battle.pbShowAbilityBox(target)
            user.pbPoison(target)
          elsif rnd == 1 && user.pbCanSleep?(target, nil)
            @battle.pbShowAbilityBox(target)
            user.pbSleep
          elsif rnd == 2 && user.pbCanParalyze?(target, nil)
            @battle.pbShowAbilityBox(target)
            user.pbParalyze(target)
          end
          @battle.pbHideAbilityBox(target)
        end
        if target.ability == :FLAMEBODY && user.pbCanBurn?(target, nil) && @battle.FE != :FROZENDIMENSION && @battle.pbRandom(10) < 3
          @battle.pbShowAbilityBox(target)
          user.pbBurn(target)
          @battle.pbHideAbilityBox(target)
        end
        eschance = 3
        eschance = 6 if [:WASTELAND, :CORRUPTED].include?(@battle.FE)
        if target.ability == :POISONPOINT && user.pbCanPoison?(target, nil) && @battle.pbRandom(10) < eschance
          @battle.pbShowAbilityBox(target)
          user.pbPoison(target)
          @battle.pbHideAbilityBox(target)
        end
        if target.types.include?(:ICE) && user.pbCanFreeze?(target, nil) && @battle.state.effects[:NeverMeltIce]
          @battle.pbShowAbilityBox(target, attrname: "Never Melt Ice")
          user.pbFreeze(message: _INTL("{1} was frostbitten!", target.pbThis))
          @battle.pbHideAbilityBox(target)
        end
        eschance = 3
        eschance = 6 if @battle.FE == :SHORTCIRCUIT || (Rejuv && @battle.FE == :ELECTERRAIN)
        if target.ability == :STATIC && user.pbCanParalyze?(target, nil) && @battle.pbRandom(10) < eschance
          @battle.pbShowAbilityBox(target)
          user.pbParalyze(target)
          @battle.pbHideAbilityBox(target)
        end
        if target.ability == :CUTECHARM && @battle.pbRandom(10) < 3
          if user.pbCanAttract?(target, nil)
            @battle.pbShowAbilityBox(target)
            user.pbAttract(target)
            @battle.pbHideAbilityBox(target)
          end
        end
        if target.ability == :PERISHBODY && user.effects[:PerishSong] == 0 && target.effects[:PerishSong] == 0 && @battle.FE != :HOLY
          @battle.pbShowAbilityBox(target)
          if @battle.FE == :INFERNAL
            @battle.pbDisplay(_INTL("Both Pokémon will faint in one turn!"))
            user.effects[:PerishSong] = 2
            user.effects[:PerishSongUser] = target.index
            target.effects[:PerishSong] = 2
            target.effects[:PerishSongUser] = target.index
          else
            @battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
            user.effects[:PerishSong] = 4
            user.effects[:PerishSongUser] = target.index
            target.effects[:PerishSong] = 4
            target.effects[:PerishSongUser] = target.index
          end
          if [:DIMENSIONAL, :HAUNTED, :INFERNAL].include?(@battle.FE)
            target.effects[:MeanLook] = user.index
            @battle.pbDisplay(_INTL("{1} can no longer escape!", target.pbThis))
          end
          if @battle.FE == :DEUXFINALIS
            user.pbPetrify(target)
          end
          @battle.pbHideAbilityBox(target)
        end
        if [:GOOEY, :TANGLINGHAIR].include?(target.ability)
          @battle.pbShowAbilityBox(target)
          statchange = target.ability == :GOOEY && [:SWAMP, :MURKWATERSURFACE].include?(@battle.FE) ? -2 : -1
          user.pbChangeStats(PBStats::SPEED, statchange, target, nil)
          user.pbPoison(target) if target.ability == :GOOEY && @battle.FE == :WASTELAND && user.pbCanPoison?(target, nil)
          @battle.pbHideAbilityBox(target)
        end
        if target.hasWorkingItem(:STICKYBARB, ignorefainted: true) && user.item.nil? && !user.isFainted?
          @battle.pbDisplay(_INTL("{1}'s {2} latched on to {3}!", target.pbThis, getItemName(target.item), user.pbThis(true)))
          target.transferItem(user)
        end
        if [:MUMMY, :LINGERINGAROMA].include?(target.ability) && !user.hasWorkingItem(:ABILITYSHIELD) && !user.isFainted?
          userability = user.ability || user.backupability
          if !(PBStuff::FIXEDABILITIES + [:MUMMY, :LINGERINGAROMA] - [:ORICHALCUMPULSE, :HADRONENGINE]).include?(userability)
            message = target.ability == :MUMMY ?
              _INTL("{1}'s Ability became {2}!", user.pbThis, getAbilityName(target.ability)) :
              _INTL("A lingering aroma clings to {1}!", user.pbThis(true))
            user.changeAbilityWithEffects(target.ability, message: message)
          end
        end
        if target.ability == :WANDERINGSPIRIT && !user.hasWorkingItem(:ABILITYSHIELD) && !target.hasWorkingItem(:ABILITYSHIELD) && !user.isFainted? # && !@user.isBoss
          userability = user.ability || user.backupability
          if !(PBStuff::ABILITYBLACKLIST + [:WANDERINGSPIRIT]).include?(userability) && !userability.nil?
            target.swapAbilities(user)
          end
        end
      end
    end
    if @battle.FE == :GLITCH # Glitch Field Hyper Beam Reset
      if user.hp > 0 && target.hp <= 0
        user.effects[:HyperBeam] = 0
      end
    end
    if !target.damagestate.substitute
      if (target.ability == :CURSEDBODY && @battle.FE != :HOLY && (@battle.pbRandom(10) < 3 || (target.isFainted? && @battle.FE == :HAUNTED))) || target.crested == :BEHEEYEM
        if user.effects[:Disable] <= 0 && move.usable? && !user.isFainted? && user.moves.include?(move)
          item = target.crested == :BEHEEYEM
          attrname = nil
          if target.effects[:clearDisguise]
            item = nil
            attrname = getAbilityName(:CURSEDBODY)
          end
          msg = _INTL("{1}'s {2} was disabled!", user.pbThis, move.name)
          @battle.pbAbilityBoxAndDisplay(target, msg, item: item, attrname: attrname)
          user.effects[:Disable] = 4
          user.effects[:DisableMove] = move.move
        end
      end
      unless attackerNotPresent
        # Bastiodon Crest
        if target.crested == :BASTIODON && !target.damagestate.disguise && !@battle.magicGuardAbilities.include?(user.ability)
          attrname = target.crested != target.species ? _INTL("bursting aura") : nil
          @battle.pbShowAbilityBox(target, item: true, attrname: attrname)
          user.pbReduceHP((damage / 2.0).floor, true) # decoupled messaging
          targetheal = !target.isFainted? && target.canHeal?
          if targetheal
            target.pbRecoverHP((damage / 2.0).floor)
            @battle.pbDisplay(_INTL("{1} was hurt, restoring {2}'s HP!", user.pbThis, target.pbThis(true)))
          else
            @battle.pbDisplay(_INTL("{1} was hurt!", user.pbThis))
          end
          @battle.pbHideAbilityBox(target)
        end
        if target.ability == :INNARDSOUT && !user.isFainted? &&
           target.hp <= 0 && !@battle.magicGuardAbilities.include?(user.ability)
          @battle.pbShowAbilityBox(target)
          user.pbReduceHP(damage, true, message: _INTL("{1} was hurt!", user.pbThis))
          @battle.pbHideAbilityBox(target)
        end
        if @battle.currentJurisdiction? == :GEARA && !user.isFainted? &&
           target.hp <= 0 && !@battle.magicGuardAbilities.include?(user.ability) && !@battle.pbBelongsToPlayer?(target.index)
          @battle.pbShowAbilityBox(target, attrname: _INTL("Geara's Jurisdiction"))
          user.pbReduceHP((damage / 2.0).floor, true, message: _INTL("{1}'s soul struck at {2}!", target.pbThis, user.pbThis))
          @battle.pbHideAbilityBox(target)
        end
        if target.ability == :GULPMISSILE && target.species == :CRAMORANT && !user.isFainted? && target.form != 0
          @battle.pbShowAbilityBox(target)
          @battle.pbDisplay(_INTL("{1} spit its catch at {2}!", target.pbThis, user.pbThis(true)))
          oldform = target.form
          target.changeForm(0)
          target.pbUpdate(false)
          @battle.scene.pbChangePokemon(target, target.pokemon)
          if !@battle.magicGuardAbilities.include?(user.ability)
            if @battle.FE == :UNDERWATER
              mult = PBTypes.typesEff(:WATER, user.types, inverse: @battle.inverse?).multiplier
              user.pbReduceHP((user.totalhp / 4.0 * mult).floor, true)
            else
              user.pbReduceHP((user.totalhp / 4.0).floor, true)
            end
          end
          if oldform == 1 # Gulping Form
            user.pbChangeStats(PBStats::DEFENSE, -1, target, nil, abilitycheck: :hide)
          elsif oldform == 2 # Gorging Form
            user.pbParalyze(target) if user.pbCanParalyze?(target, nil)
          end
          @battle.pbHideAbilityBox(target)
        end
      end
      if target.effects[:Illusion] != nil
        target.breakIllusion
      end
      if target.effects[:clearDisguise] != nil && target.damagestate.typemod.superEffective? && @battle.pbBelongsToPlayer?(user.index)
        target.breakClearDisguise
      end
      if target.ability == :JUSTIFIED && movetypes.include?(:DARK)
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK, target, nil)
          @battle.pbShowAbilityBox(target)
          stat = @battle.FE == :HOLY ? 2 : 1
          target.pbChangeStats(PBStats::ATTACK, stat, target, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(target)
        end
      end
      if target.ability == :RATTLED && [:BUG, :DARK, :GHOST].intersect?(movetypes)
        if target.pbCanIncreaseStatStage?(PBStats::SPEED, target, nil)
          @battle.pbShowAbilityBox(target)
          target.pbChangeStats(PBStats::SPEED, 1, target, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(target)
        end
      end
      if target.ability == :WEAKARMOR && physicalmove
        if target.pbCanReduceStatStage?(PBStats::DEFENSE, target, nil) || target.pbCanIncreaseStatStage?(PBStats::SPEED, target, nil)
          @battle.pbShowAbilityBox(target)
          target.pbChangeStats([PBStats::DEFENSE, PBStats::SPEED], [-1, 2], target, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(target)
        end
      end
      if target.ability == :STAMINA
        if target.pbCanIncreaseStatStage?(PBStats::DEFENSE, target, nil)
          @battle.pbShowAbilityBox(target)
          target.pbChangeStats(PBStats::DEFENSE, 1, target, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(target)
        end
      end
      if target.crested == :NOCTOWL
        if target.pbCanIncreaseStatStage?(PBStats::SPDEF, target, nil)
          @battle.pbShowAbilityBox(target, item: true)
          target.pbChangeStats(PBStats::SPDEF, 1, target, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(target)
        end
      end
      if target.ability == :WATERCOMPACTION && movetypes.include?(:WATER)
        if @battle.FE != :ASHENBEACH
          if target.pbCanIncreaseStatStage?(PBStats::DEFENSE, target, nil)
            @battle.pbShowAbilityBox(target)
            target.pbChangeStats(PBStats::DEFENSE, 2, target, nil, abilitycheck: :skip)
            @battle.pbHideAbilityBox(target)
          end
        else
          if target.pbCanIncreaseAnyStat?(PBStats::Defensive, target, nil)
            @battle.pbShowAbilityBox(target)
            target.pbChangeStats(PBStats::Defensive, 2, target, nil, abilitycheck: :hide)
            @battle.pbHideAbilityBox(target)
          end
        end
      end
      # Cotton Down
      if target.ability == :COTTONDOWN
        for i in [target.pbOpposing1, target.pbOpposing2, target.pbPartner]
          next unless i.passiveAbilityApplies?

          @battle.pbShowAbilityBox(target)
          amount = [:BEWITCHED, :GRASSY, :FLOWERGARDEN2, :FLOWERGARDEN3, :FLOWERGARDEN4, :FLOWERGARDEN5].include?(@battle.FE) ? -2 : -1
          i.pbChangeStats(PBStats::SPEED, amount, target, nil)
        end
        @battle.pbHideAbilityBox(target)
      end
      # Foam Spray
      if target.ability == :FOAMSPRAY
        for i in @battle.battlers
          next if i == target
          next if i.isFainted? && !(i.isbossmon && i.shieldCount > 0)

          @battle.pbShowAbilityBox(target)
          amount = [:WATERSURFACE, :SWAMP, :MURKWATERSURFACE].include?(@battle.FE) ? -2 : -1
          i.pbChangeStats(PBStats::DEFENSE, amount, target, nil)
        end
        @battle.pbHideAbilityBox(target)
      end
      # Sand Spit
      if target.ability == :SANDSPIT && @battle.canSetWeather?(:SANDSTORM)
        @battle.pbShowAbilityBox(target)
        @battle.pbAnimation(:SANDSTORM, target, nil)
        duration = target.hasWorkingItem(:SMOOTHROCK) || [:DESERT, :ASHENBEACH, :SKY].include?(@battle.FE) ? 8 : 5
        @battle.pbSetWeather(:SANDSTORM, duration)
        if [:DESERT, :ASHENBEACH].include?(@battle.FE)
          user.pbChangeStats(PBStats::ACCURACY, -1, target, nil, abilitycheck: :hide)
        end
        @battle.pbHideAbilityBox(target)
      end
      # Steam Engine
      if target.ability == :STEAMENGINE && [:WATER, :FIRE].intersect?(movetypes)
        if target.pbCanIncreaseStatStage?(PBStats::SPEED, target, nil)
          @battle.pbShowAbilityBox(target)
          target.pbChangeStats(PBStats::SPEED, 6, target, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(target)
        end
      end
      # Electromorphosis
      if target.ability == :ELECTROMORPHOSIS && (!target.isFainted? || (target.isbossmon && target.shieldCount > 0))
        unless target.effects[:Charge] > 0
          @battle.pbShowAbilityBox(target)
          target.effects[:Charge] = 2
          @battle.pbAnimation(:CHARGE, target, nil)
          @battle.pbDisplay(_INTL("Being hit by {1} charged {2} with power!", getMoveName(move.move), target.pbThis(true)))
          @battle.pbHideAbilityBox(target)
        end
      end
      # Seed Sower
      if target.ability == :SEEDSOWER
        if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 1, 4)
          @battle.pbShowAbilityBox(target)
          @battle.growField(target.pbThis, target)
          @battle.pbHideAbilityBox(target)
        elsif @battle.canChangeFE?(:GRASSY) && @battle.OV != :GRASSY && @battle.FE != :FROZENDIMENSION && (Overlays || @battle.FE != :FLOWERGARDEN5)
          @battle.pbShowAbilityBox(target)
          @battle.pbAnimation(:GRASSYTERRAIN, target, nil)
          duration = target.hasWorkingItem(:AMPLIFIELDROCK) ? 8 : 5
          duration = 8 if Overlays && [:FOREST, :BEWITCHED].include?(@battle.FE)
          @battle.setField(:GRASSY, duration, nil)
          @battle.pbHideAbilityBox(target)
        end
      end
      # Thermal Exchange
      if target.ability == :THERMALEXCHANGE && movetypes.include?(:FIRE)
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK, target, nil)
          @battle.pbShowAbilityBox(target)
          target.pbChangeStats(PBStats::ATTACK, 1, target, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(target)
        end
      end
      # Toxic Debris
      if target.ability == :TOXICDEBRIS && target.pbOpposingSide.effects[:ToxicSpikes] < 2 && physicalmove
        @battle.pbShowAbilityBox(target)
        @battle.pbAnimation(:TOXICSPIKES, target, nil)
        target.pbOpposingSide.effects[:ToxicSpikes] += 1
        if !@battle.pbIsOpposing?(target.index)
          @battle.pbDisplay(_INTL("Poison spikes were scattered on the ground all around the opposing team!"))
        else
          @battle.pbDisplay(_INTL("Poison spikes were scattered on the ground all around your team!"))
        end
        @battle.pbHideAbilityBox(target)
      end
      # Wind Power
      if target.ability == :WINDPOWER && move.windMove?
        @battle.pbShowAbilityBox(target)
        target.effects[:Charge] = 2
        @battle.pbAnimation(:CHARGE, target, nil)
        @battle.pbDisplay(_INTL("Being hit by {1} charged {2} with power!", getMoveName(move.move), target.pbThis(true)))
        @battle.pbHideAbilityBox(target)
      end
      # Spicy Spray
      if target.ability == :SPICYSPRAY && user.pbCanBurn?(target, nil)
        # The canon ability pop-up conditions are weird for this one, making a bit of a deviation
        @battle.pbShowAbilityBox(target)
        user.pbBurn(target)
        @battle.pbHideAbilityBox(target)
      end
      # Absorb Bulb, Snowball, Cell Battery, Luminous Moss
      stat = nil
      if target.itemWorks?
        case target.item
          when :ABSORBBULB then stat, type = PBStats::SPATK, :WATER
          when :SNOWBALL then stat, type = PBStats::ATTACK, :ICE
          when :CELLBATTERY then stat, type = PBStats::ATTACK, :ELECTRIC
          when :LUMINOUSMOSS then stat, type = PBStats::SPDEF, :WATER
        end
      end
      if stat && target.pbCanIncreaseStatStage?(stat, target, nil) && movetypes.include?(type)
        @battle.pbShowAbilityBox(target, item: true)
        @battle.pbCommonAnimation("UseItem", target, nil)
        target.pbChangeStats(stat, 1, target, nil, abilitycheck: :skip, statmessage: :Item)
        @battle.pbHideAbilityBox(target)
        target.pbDisposeItem(symbiosis: :delay)
      end
      # Jaboca/Rowap Berry
      unless user.isFainted? || @battle.magicGuardAbilities.include?(user.ability) ||
         @battle.pbCheckSideAbility(PBStuff::UnnerveAbilities, target.pbOpposing1).any? ||
         futureSight || !target.itemWorks?(ignorefainted: true)
        if (target.item == :JABOCABERRY && physicalmove) || (target.item == :ROWAPBERRY && specialmove)
          @battle.pbShowAbilityBox(target, item: true)
          @battle.pbCommonAnimation("Nom", target)
          user.pbReduceHP((user.totalhp / 8.0).floor, true, message: _INTL("{1} was hurt by {2}'s {3}!", user.pbThis, target.pbThis(true), getItemName(target.item)))
          @battle.pbHideAbilityBox(target)
          target.pbCudChew(target.item)
          target.pbDisposeItem(symbiosis: :delay)
        end
      end
      if target.hasWorkingItem(:WEAKNESSPOLICY) && target.damagestate.typemod.superEffective?
        if target.pbCanIncreaseAnyStat?(PBStats::Offensive, target, nil)
          @battle.pbShowAbilityBox(target, item: true)
          @battle.pbCommonAnimation("UseItem", target, nil)
          target.pbChangeStats(PBStats::Offensive, 2, target, nil, abilitycheck: :hide, statmessage: :Item)
          @battle.pbHideAbilityBox(target)
          target.pbDisposeItem(symbiosis: :delay)
        end
      end
      if target.ability == :ANGERPOINT && target.damagestate.critical
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK, target, nil)
          @battle.pbShowAbilityBox(target)
          target.pbChangeStats(PBStats::ATTACK, 12, target, nil, abilitycheck: :skip, statmessage: :none)
          @battle.pbDisplay(_INTL("{1} maxed its {2}!", target.pbThis, getStatName(PBStats::ATTACK)))
          @battle.pbHideAbilityBox(target)
        end
      end
      if target.effects[:Rage]
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK, target, nil)
          target.pbChangeStats(PBStats::ATTACK, 1, target, nil, abilitycheck: :skip, statmessage: :none)
          @battle.pbDisplay(_INTL("{1}'s rage is building!", target.pbThis))
        end
      end
      if target.hasWorkingItem(:AIRBALLOON, ignorefainted: true)
        @battle.pbDisplay(_INTL("{1}'s {2} popped!", target.pbThis, getItemName(target.item)))
        target.pbDisposeItem(pickupable: false)
      end
    end
  end

  def pbSynchronize
    s = @battle.synchronize[0]
    t = @battle.synchronize[1]
    if s >= 0 && t >= 0 && @battle.battlers[s].ability == :SYNCHRONIZE &&
       @battle.synchronize[2].is_a?(Symbol) && !@battle.battlers[t].isFainted?
      # see [2024281]&0xF0, [202420C]
      sbattler = @battle.battlers[s]
      tbattler = @battle.battlers[t]
      if @battle.synchronize[2] == :POISON
        # UPDATE 11/17/2013
        # allows for transfering of `badly poisoned` instead of just poison.
        # changed from: tbattler.pbPoison(sbattler)
        @battle.pbShowAbilityBox(sbattler)
        if tbattler.pbCanPoison?(sbattler, nil, showMessage: true)
          tbattler.pbPoison(sbattler, sbattler.statusCount == 1)
        end
      elsif @battle.synchronize[2] == :BURN
        @battle.pbShowAbilityBox(sbattler)
        if tbattler.pbCanBurn?(sbattler, nil, showMessage: true)
          tbattler.pbBurn(sbattler)
        end
      elsif @battle.synchronize[2] == :PARALYSIS
        @battle.pbShowAbilityBox(sbattler)
        if tbattler.pbCanParalyze?(sbattler, nil, showMessage: true)
          tbattler.pbParalyze(sbattler)
        end
      end
      @battle.pbHideAbilityBox(sbattler)
    end
  end

  def getReflectorTypes(target, setTypes = true)
    typesToReflect = []
    for type in [target.type1, target.type2]
      next if type.nil?
      next if typesToReflect.include?(type)
      typesToReflect.push(type)
    end
    return false if self.effects[:ReflectorTypes] == typesToReflect # technically this causes different order to be different, but fine
    self.effects[:ReflectorTypes] = typesToReflect if setTypes
    return true
  end

  def pbAbilityCureCheck
    return if self.isFainted?

    if (self.ability == :LIMBER && self.status == :PARALYSIS) ||
       ([:VITALSPIRIT, :INSOMNIA].include?(self.ability) && self.status == :SLEEP) ||
       ([:IMMUNITY, :PASTELVEIL].include?(self.ability) && self.status == :POISON) ||
       (self.ability == :MAGMAARMOR && self.status == :FROZEN) ||
       ([:WATERVEIL, :WATERBUBBLE, :THERMALEXCHANGE].include?(self.ability) && self.status == :BURN)
      @battle.pbShowAbilityBox(self)
      self.pbCureStatus
      @battle.pbHideAbilityBox(self)
    end

    if self.ability == :OBLIVIOUS && @effects[:Attract] >= 0
      @effects[:Attract] = -1
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} got over its infatuation!", pbThis))
    end
    if self.ability == :OBLIVIOUS && @effects[:Taunt] > 0
      @effects[:Taunt] = 0
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s taunt wore off!", pbThis))
    end
    if self.ability == :OWNTEMPO && @effects[:Confusion] > 0
      @battle.pbShowAbilityBox(self)
      self.pbCureConfusion
      @battle.pbHideAbilityBox(self)
    end
  end

  def pbEmergencyExitCheck(oldhp)
    return unless [:EMERGENCYEXIT, :WIMPOUT].include?(self.ability)
    return unless oldhp > (@totalhp / 2.0).floor && self.hp <= (@totalhp / 2.0).floor && self.hp != 0

    if @battle.FE == :COLOSSEUM
      if self.ability == :WIMPOUT
        @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} has nowhere to run!", self.pbThis))
      elsif self.ability == :EMERGENCYEXIT
        if self.pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          self.pbChangeStats(PBStats::SPEED, 2, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
      end
    else
      if @battle.pbIsWild? && @battle.battlers.none? { |battler| battler.isbossmon && battler.pokemon.bossID != :SHADOWDEN }
        # when a boss is initialized cantescape is getting set on the battle, so wild bosses will never be fleed from unless the boss's settings explicitly allow it
        unless @battle.cantescape || $game_switches[:Never_Escape]
          @battle.pbShowAbilityBox(self)
          pbSEPlay("escape", 100)
          if @battle.pbIsOpposing?(self.index)
            @battle.pbDisplayPaused(_INTL("{1} fled!", self.pbThis))
          else
            @battle.pbDisplayAutoPaused(_INTL("Got away safely!"))
          end
          @battle.pbHideAbilityBox(self)
          @battle.decision = 3 # Set decision to escaped
        end
      else
        if self.canTriggerUserSwitch?
          message = _INTL("{1} is tactically retreating!", self.pbThis) if self.ability == :EMERGENCYEXIT
          message = _INTL("{1} is wimping out!", self.pbThis) if self.ability == :WIMPOUT
          @battle.pbAbilityBoxAndDisplay(self, message)
          self.userSwitch = :Ability
        end
      end
    end
  end

  def breakIllusion
    self.effects[:Illusion] = nil
    @battle.pbAnimation(:TRANSFORM, self, self) if !self.isFainted?
    @battle.scene.pbChangePokemon(self, self.pokemon)
    @battle.pbDisplay(_INTL("{1}'s illusion wore off!", self.pbThis))
    $Trainer.pokedex.setSeen(self.pokemon)
  end

  def breakClearDisguise
    self.effects[:clearDisguise] = nil
    @battle.pbAnimation(:TRANSFORM, self, self) if !self.isFainted?
    @battle.scene.pbChangePokemon(self, self.pokemon)
    @battle.pbDisplay(_INTL("{1}'s illusion was broken!", self.pbThis))
    $Trainer.pokedex.setSeen(self.pokemon)
    # Once broken, the disguise shouldn't be restored on switching out and back in
    self.pokemon.disguise = nil
  end

  ################################################################################
  # Held item effects
  ################################################################################
  def removeItem(permanent: false, recycle: false)
    item = self.item

    self.item = nil
    self.effects[:ChoiceBand] = nil

    self.permeffs[:ItemToKeep] = nil if permanent && item == self.permeffs[:ItemToKeep]
    self.permeffs[:ItemRecycle] = item if recycle

    return item
  end

  def obtainItem(item, recycled: false)
    self.item = item
    self.permeffs[:ItemToKeep] = item if !recycled || (self.permeffs[:ItemToKeep].nil? && item == self.permeffs[:OriginalItem])
  end

  # caller battler is the one giving the item, 'target' is the one receiving
  def transferItem(target)
    target.item = self.removeItem
    self.checkPermanentItemTransfer(target, false)
  end

  # fully symmetrical, caller battler and 'target' are interchangeable
  def swapItems(target)
    selfitem = self.removeItem
    targetitem = target.removeItem
    self.item, target.item = targetitem, selfitem
    self.checkPermanentItemTransfer(target, true)
  end

  def checkPermanentItemTransfer(target, swap)
    wildBattle = @battle.pbIsWild? && @battle.battlers.none? { |battler| battler.isbossmon && battler.pokemon.bossID != :SHADOWDEN }
    return unless wildBattle

    return if target == self.pbPartner # Prevents item loss to a partner trainer in a wild battle

    return unless (target.permeffs[:ItemToKeep].nil? && target.item == self.permeffs[:ItemToKeep]) || (swap && self.permeffs[:ItemToKeep].nil? && self.item == target.permeffs[:ItemToKeep])

    target.permeffs[:ItemToKeep] = target.item
    self.permeffs[:ItemToKeep] = self.item
  end

  def roomServiceCheck
    return if @battle.state.effects[:TrickRoom] == 0
    return unless self.hasWorkingItem(:ROOMSERVICE)
    return unless self.pbCanReduceStatStage?(PBStats::SPEED, self, nil)

    @battle.pbShowAbilityBox(self, item: true)
    @battle.pbCommonAnimation("UseItem", self, nil)
    self.pbChangeStats(PBStats::SPEED, -1, self, nil, statmessage: :Item)
    @battle.pbHideAbilityBox(self)
    self.pbDisposeItem
  end

  def seedCheck
    seeddata = @battle.field.seeds
    return if self.item != seeddata[:seedtype]

    @battle.pbShowAbilityBox(self, item: true)

    # Use item animation
    @battle.pbCommonAnimation("UseItem", self, nil)

    # Stat boost from seed
    stats, amounts = *hashToParallelArrays(seeddata[:stats])
    self.pbChangeStats(stats, amounts, self, nil, statmessage: :Item)

    abilitychange = nil
    # Special effect from seed that needs specific code
    case @battle.FE
      when :MISTY, :RAINBOW, :STARLIGHT
        if self.effects[:Wish] == 0
          self.effects[:Wish] = 2
          self.effects[:WishAmount] = ((self.totalhp + 1) * 0.75).floor
          self.effects[:WishMaker] = self.pokemonIndex
          @battle.pbAnimation(:WISH, self, nil)
          @battle.pbDisplay(_INTL("A wish was made for {1}!", self.pbThis(true)))
        end
      when :BURNING, :DESERT, :VOLCANIC
        self.effects[:MultiTurn] = 4
        self.effects[:MultiTurnUser] = self.index
      when :SWAMP
        abilitychange = :CLEARBODY if Rejuv
      when :CORROSIVEMIST, :MURKWATERSURFACE, :CORRUPTED
        self.pbPoison(self, true) if self.pbCanPoison?(self, nil)
      when :ICY
        if !self.isAirborne? && self.ability != :MAGICGUARD
          spikesdiv = [8.0, 8.0, 6.0, 4.0][self.pbOwnSide.effects[:Spikes]]
          self.pbReduceHP((self.totalhp / spikesdiv).floor, true, message: _INTL("{1} was hurt by the icy spikes!", self.pbThis))
        end
      when :ROCKY, :CAVE
        if self.ability != :MAGICGUARD
          atype = :ROCK
          eff = PBTypes.typesEff(atype, self.types, inverse: @battle.inverse?)
          unless eff.immune?
            # Note: Stealth Rock damage is doubled on these fields.
            self.pbReduceHP((self.totalhp / 4.0 * eff.multiplier).floor, true, message: _INTL("Pointed stones dug into {1}!", self.pbThis(true)))
            self.pbPassiveTypeEffCheck(atype)
          end
        end
      when :WASTELAND
        self.pbOwnSide.effects[:StealthRock] = true
        self.pbOpposingSide.effects[:StealthRock] = true
        @battle.pbDisplay(_INTL("Pointed stones float in the air around the battlefield!"))
      when :UNDERWATER
        self.changeType(:WATER) if self.canChangeType?
      when :GLITCH
        self.changeType(:QMARKS) if self.canChangeType?
        if self.pokemon.species == :ARCEUS && self.ability == :MULTITYPE
          @battle.pbShowAbilityBox(self)
          roll = 9
          roll += pulseArceusTypes if $game_switches[:Pulse_Arceus] && self.pokemon.trainerID == 00000
          if self.form != roll
            self.changeForm(roll)
            @battle.pbCommonAnimation("SilvallyGlitch", self, nil)
            self.pbUpdate(true)
            @battle.scene.pbChangePokemon(self, self.pokemon)
          end
        end
      when :NEWWORLD
        self.currentMove = 0
      when :INVERSE
        if Rejuv
          self.changeType(:NORMAL) if self.canChangeType?
          abilitychange = :NORMALIZE
        else
          self.currentMove = 0
        end
      when :PSYTERRAIN
        self.pbConfuse if self.pbCanConfuse?(self, nil)
      when :DIMENSIONAL
        @battle.pbAnimation(:TRICKROOM, self, nil)
        if @battle.state.effects[:TrickRoom] == 0
          @battle.pbDisplay(_INTL("{1} twisted the dimensions!", self.pbThis))
          duration = 3 + @battle.pbRandom(6)
          @battle.pbSetTrickRoom(duration)
        else
          @battle.pbDisplay(_INTL("The twisted dimensions returned to normal!"))
          @battle.state.effects[:TrickRoom] = 0
        end
      when :HAUNTED
        self.pbBurn(self) if self.pbCanBurn?(self, nil)
      when :INFERNAL
        self.effects[:MeanLook] = self.index
      when :DEEPEARTH
        self.effects[:WeightModifier] += self.pokemon.weight
      when :CLOUDS
        abilitychange = :CLOUDNINE
      when :CROWD
        self.cheer
      when :DANCEFLOOR
        abilitychange = :DANCER
      when :DEUXFINALIS
        if ![:GOODASGOLD, :SOUNDPROOF].include?(self.ability)
          self.effects[:PerishSong] = 4
          self.effects[:PerishSongUser] = self.index
        end
      when :BIGTOP, :CONCERT1, :CONCERT2, :CONCERT3, :CONCERT4
        self.effects[:HelpingHand] += 1
    end
    if abilitychange
      selfability = self.ability || self.backupability
      unless (PBStuff::FIXEDABILITIES + [abilitychange]).include?(selfability)
        # TODO: Remove "activate: false" when we fix items activating before abilities on switch-in, right now it would cause double ability activation so leaving as-is
        self.changeAbilityWithEffects(abilitychange, activate: false)
      end
    end

    # Special effect from seed that doesn't need specific code
    self.effects[seeddata[:effect]] = seeddata[:duration] if seeddata[:effect].is_a?(Symbol)

    # Animation
    @battle.pbCommonAnimation(seeddata[:animation], self, nil) if seeddata[:animation].is_a?(String)
    @battle.pbAnimation(seeddata[:animation], self, nil) if seeddata[:animation].is_a?(Symbol)

    # Message
    if seeddata[:message].is_a?(String) && seeddata[:message] != ""
      lowercase = !seeddata[:message].start_with?("{1}")
      @battle.pbDisplay(_INTL(pbGetMessageFromHash(:FieldMessages, seeddata[:message]), self.pbThis(lowercase)))
    end

    @battle.pbHideAbilityBox(self)

    # Field growth after seed message
    if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 1, 4)
      @battle.growField(_INTL("{1}", getItemName(self.item, :The)), self)
    end
    if @battle.ProgressiveFieldCheck(PBFields::DARKNESS, 1, 2)
      message = @battle.FE == :DARKNESS1 ? _INTL("The shadows grow...") : _INTL("The shadows engulf the surroundings!")
      @battle.growField(message, self)
    end

    self.pbDisposeItem
  end

  def pbItemsOnField(delayStatChangeChecks = false, consumablesOnly: false)
    # TODO: Activate these effects when items are changed via Trick, Thief, etc.
    return if @battle.preSurgeField && @battle.FE == @battle.preSurgeField
    return if @applyingEntryEffects
    return unless self.itemWorks?

    # Seeds
    self.seedCheck
    self.pbFaint if self.isFainted? # Some seeds damage the user

    # Rejuv Electric Terrain
    if Rejuv && @battle.FE == :ELECTERRAIN
      if self.item == :CELLBATTERY
        if self.pbCanIncreaseStatStage?(PBStats::ATTACK, self, nil)
          @battle.pbShowAbilityBox(self, item: true)
          @battle.pbCommonAnimation("UseItem", self, nil)
          self.pbChangeStats(PBStats::ATTACK, 1, self, nil, abilitycheck: :skip, statmessage: :Item)
          @battle.pbHideAbilityBox(self)
          self.pbDisposeItem
        end
      end
    end

    @battle.pbStatChangeChecks unless delayStatChangeChecks

    return if consumablesOnly

    # Mirror Arena
    if @battle.FE == :MIRROR
      if [:BRIGHTPOWDER, :LAXINCENSE, :COVERTCLOAK].include?(self.item)
        if self.pbCanIncreaseStatStage?(PBStats::EVASION, self, nil)
          @battle.pbShowAbilityBox(self, item: true)
          @battle.pbCommonAnimation("UseItem", self, nil)
          self.pbChangeStats(PBStats::EVASION, 1, self, nil, abilitycheck: :skip, statmessage: :Item)
          @battle.pbHideAbilityBox(self)
        end
      end
      if [:ZOOMLENS, :WIDELENS].include?(self.item)
        @battle.pbShowAbilityBox(self, item: true)
        @battle.pbCommonAnimation("UseItem", self, nil)
        self.pbChangeStats(PBStats::ACCURACY, 1, self, nil, abilitycheck: :hide, statmessage: :Item)
        self.effects[:LaserFocus] = 2
        @battle.pbAnimation(:LASERFOCUS, self, nil)
        @battle.pbDisplay(_INTL("{1} concentrated intensely using its {2}!", pbThis, getItemName(self.item)))
        @battle.pbHideAbilityBox(self)
      end
    end

    # Deep Earth
    if @battle.FE == :DEEPEARTH
      if self.item == :IRONBALL
        if self.pbCanReduceStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self, item: true)
          @battle.pbCommonAnimation("UseItem", self, nil)
          self.pbChangeStats(PBStats::SPEED, -2, self, nil, abilitycheck: :skip, statmessage: :Item)
          @battle.pbHideAbilityBox(self)
        end
      end
      if self.item == :MAGNET
        if self.pbCanReduceStatStage?(PBStats::SPEED, self, nil) || self.pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
          @battle.pbShowAbilityBox(self, item: true)
          @battle.pbCommonAnimation("UseItem", self, nil)
          @battle.pbDisplay(_INTL("{1}'s {2} is affected by the magnetic field!", self.pbThis, getItemName(self.item)))
          self.pbChangeStats([PBStats::SPEED, PBStats::SPATK], [-1, 1], self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
    end

    @battle.pbStatChangeChecks unless delayStatChangeChecks
  end

  def pbPassiveItemHP
    return if self.isFainted?
    return if !self.itemWorks?
    return if !self.canHeal? && !self.pbPartner&.canHeal? # make the check go for partner here because the first couple entries heal user and partner

    # Black Sludge (damage)
    if self.item == :BLACKSLUDGE && !hasType?(:POISON) && !@battle.magicGuardAbilities.include?(self.ability)
      @battle.pbShowAbilityBox(self, item: true)
      @battle.pbCommonAnimation("UseItem", self, nil)
      hploss = (self.totalhp / 8.0).floor
      hploss = (self.totalhp / 4.0).floor if [:CORRUPTED].include?(@battle.FE)
      pbReduceHP(hploss, true, message: _INTL("{1} is hurt by its {2}!", pbThis, getItemName(self.item)))
      @battle.pbHideAbilityBox(self)
      pbFaint if self.isFainted?
      return
    end

    # Meganium Crest
    if self.crested == :MEGANIUM
      if self.canHeal?
        # Heal Meganium
        @battle.pbShowAbilityBox(self, item: true)
        pbRecoverHP((self.totalhp / 8.0).floor, true)
      end
      partner = self.pbPartner
      if !partner.isFainted? && partner.canHeal?
        # Heal its partner
        @battle.pbShowAbilityBox(self, item: true)
        partner.pbRecoverHP((partner.totalhp / 16.0).floor, true)
      end
      @battle.pbHideAbilityBox(self)
    end

    # Dessert Tray
    if self.ability == :DESSERTTRAY
      if self.canHeal?
        # Heal ability user
        @battle.pbShowAbilityBox(self)
        pbRecoverHP((self.totalhp / 16.0).floor, true)
      end
      partner = self.pbPartner
      if !partner.isFainted? && partner.canHeal?
        # Heal its partner
        @battle.pbShowAbilityBox(self)
        partner.pbRecoverHP((partner.totalhp / 16.0).floor, true)
      end
      @battle.pbHideAbilityBox(self)
    end

    return unless self.canHeal?

    hpgain, message = 0, nil

    # Leftovers, Black Sludge (healing), Health Wing in the Clouds (Deso)
    if self.item == :LEFTOVERS || (self.item == :BLACKSLUDGE && hasType?(:POISON)) || (@battle.FE == :CLOUDS && self.item == :HEALTHWING)
      hpgain = (self.totalhp / 16.0).floor
      hpgain = (self.totalhp / 8.0).floor if [:CORRUPTED].include?(@battle.FE) && self.item == :BLACKSLUDGE
    end
    # Infernape Crest, Gothitelle Crest
    if self.crested == :INFERNAPE || (self.crested == :GOTHITELLE && self.hasType?(:PSYCHIC))
      hpgain = (self.totalhp / 16.0).floor
    end
    # Spiritomb Crest
    if self.crested == :SPIRITOMB
      hpgain = (self.totalhp * pbEnemyFaintedPokemonCount / 16.0).floor # Can be 0
    end
    # Vespiquen Crest
    if self.crested == :VESPIQUEN && !@effects[:VespiCrest] # In Defense Stance
      hpgain = (self.totalhp / 16.0).floor
      message = _INTL("{1}'s swarm patched up her injuries!", pbThis)
    end

    if hpgain > 0
      @battle.pbShowAbilityBox(self, item: true)
      @battle.pbCommonAnimation("UseItem", self, nil) unless self.crested
      pbRecoverHP(hpgain, true, message: message)
      @battle.pbHideAbilityBox(self)
    end
  end

  def pbBerryHerbCheck(onlyCure = false)
    return if self.isFainted?
    return if !self.itemWorks?

    itemname = getItemName(self.item)

    if self.item == :BERRYJUICE
      if !onlyCure && self.hp <= (self.totalhp / 2.0).floor && self.canHeal?
        @battle.pbShowAbilityBox(self, item: true)
        @battle.pbCommonAnimation("UseItem", self, nil)
        self.pbRecoverHP(20, true, message: _INTL("{1} restored its health using its {2}!", pbThis, itemname))
        @battle.pbHideAbilityBox(self)
        pbDisposeItem
      end
      return
    elsif self.item == :MENTALHERB
      triggerMentalHerb
      return
    end

    return if self.item.nil? || !pbIsBerry?(self.item)
    return if @battle.pbCheckSideAbility(PBStuff::UnnerveAbilities, pbOpposing1).any?

    pbEatBerry if pbBerryCheck(onlyCure: onlyCure)
  end

  def triggerWhiteHerb(flinged = false)
    return unless PBStats::All.any? { |stat| @stages[stat] < 0 }

    @battle.pbShowAbilityBox(self, item: :WHITEHERB)
    @battle.pbCommonAnimation("UseItem", self, nil)
    @battle.pbDisplay(_INTL("{1} returned its stats to normal using its {2}!", pbThis, getItemName(:WHITEHERB)))

    PBStats::All.each { |stat| @stages[stat] = 0 if @stages[stat] < 0 }

    @battle.pbHideAbilityBox(self)
    pbDisposeItem unless flinged
  end

  def triggerMentalHerb(flinged = false)
    return unless @effects[:Attract] >= 0 || @effects[:Taunt] > 0 || @effects[:Encore] > 0 || @effects[:Torment] || @effects[:Disable] > 0 || @effects[:HealBlock] > 0

    @battle.pbShowAbilityBox(self, item: :MENTALHERB)
    @battle.pbCommonAnimation("UseItem", self, nil)
    @battle.pbDisplay(_INTL("{1} used its {2}!", pbThis, getItemName(:MENTALHERB)))

    @battle.pbDisplay(_INTL("{1} cured its infatuation status!", pbThis)) if @effects[:Attract] >= 0
    @battle.pbDisplay(_INTL("{1}'s taunt wore off!", pbThis)) if @effects[:Taunt] > 0
    @battle.pbDisplay(_INTL("{1}'s encore ended!", pbThis)) if @effects[:Encore] > 0
    @battle.pbDisplay(_INTL("{1}'s torment wore off!", pbThis)) if @effects[:Torment]
    @battle.pbDisplay(_INTL("{1}'s move is no longer disabled!", pbThis)) if @effects[:Disable] > 0
    @battle.pbDisplay(_INTL("{1} is no longer prevented from healing!", pbThis)) if @effects[:HealBlock] > 0

    @effects[:Attract] = -1
    @effects[:Taunt] = 0
    @effects[:Encore] = 0
    @effects[:EncoreMove] = 0
    @effects[:EncoreIndex] = 0
    @effects[:Torment] = false
    @effects[:Disable] = 0
    @effects[:DisableMove] = 0
    @effects[:HealBlock] = 0

    @battle.pbHideAbilityBox(self)
    pbDisposeItem unless flinged
  end

  def pbBerryCheck(berry = nil, onlyCure: false)
    special = !berry.nil? # Berry isn't the battler's held item
    berry = self.item if berry.nil?
    return unless pbIsBerry?(berry)

    medicinedata = $cache.items[berry].medicine
    # Cure Berries
    case berry
      when :CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY then return true if self.status == medicinedata.status
      when :PERSIMBERRY then return true if @effects[:Confusion] > 0
      when :LUMBERRY    then return true if !self.status.nil? || @effects[:Confusion] > 0 || self.permeffs[:Frenzy]
    end

    # Leave if we're only checking for cures
    return false if onlyCure

    # Healing Berries
    pinch_hp = (self.totalhp / (self.ability == :GLUTTONY ? 2.0 : 4.0)).floor
    if self.canHeal?
      case berry
        when :ORANBERRY, :SITRUSBERRY then return true if self.hp <= (self.totalhp / 2.0).floor || special
        when :ENIGMABERRY then return true if self.damagestate.typemod.superEffective? || special
        when :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY then return true if self.hp <= pinch_hp || special
      end
    end

    # Non-healing Pinch Berries
    if self.hp <= pinch_hp || special
      stats = nil
      case berry
        when :LIECHIBERRY then stats = [PBStats::ATTACK]
        when :GANLONBERRY then stats = [PBStats::DEFENSE]
        when :PETAYABERRY then stats = [PBStats::SPATK]
        when :APICOTBERRY then stats = [PBStats::SPDEF]
        when :SALACBERRY  then stats = [PBStats::SPEED]
        when :STARFBERRY  then stats = PBStats::Omni
        when :LANSATBERRY then return true if @effects[:FocusEnergy] < 1
        when :MICLEBERRY  then return true unless @effects[:MicleBerry]
      end
      return true if stats && self.pbCanIncreaseAnyStat?(stats, self, nil)
    end

    # Leppa Berry
    if berry == :LEPPABERRY
      return true if special
      return true if @pokemon.moves.any? { |move| move.move && !PokeBattle_Move.pbFromPBMove(@battle, move, @pokemon).usable? }
    end

    # No Berry is eaten
    return false
  end

  def pbEatBerry(berry = nil, animation: true)
    special = !berry.nil? # Berry isn't the battler's held item
    berry = self.item if berry.nil?
    return unless pbIsBerry?(berry)

    medicinedata = $cache.items[berry].medicine
    itemname = getItemName(berry)

    @battle.pbShowAbilityBox(self, item: berry) if animation

    # Animation
    @battle.pbCommonAnimation("Nom", self, nil) if animation

    # One Bad Apple

    recipient = self.ability == :ONEBADAPPLE ? self.pbFirstOpposing : self

    # Cure Berries
    status_cured = false
    case berry
      when :CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY then status_cured = true if self.status == medicinedata.status
      when :LUMBERRY then status_cured = true if !self.status.nil?
    end
    self.pbCureStatus(item: !special) if status_cured
    self.pbCureConfusion(item: !special) if [:PERSIMBERRY, :LUMBERRY].include?(berry)
    self.pbCureFrenzy(item: !special) if  [:PERSIMBERRY, :LUMBERRY].include?(berry)

    if self.ability == :ONEBADAPPLE
      if status_cured
        @battle.pbShowAbilityBox(self)
        case berry
          when :CHERIBERRY  then recipient.pbParalyze(self) if recipient.pbCanParalyze?(self,nil)
          when :CHESTOBERRY then recipient.pbSleep(self) if recipient.pbCanSleep?(self,nil)
          when :PECHABERRY  then recipient.pbPoison(self) if recipient.pbCanPoison?(self,nil)
          when :RAWSTBERRY  then recipient.pbBurn(self) if recipient.pbCanBurn?(self,nil)
          when :ASPEARBERRY then recipient.pbFreeze(self) if recipient.pbCanFreeze?(self,nil)
        end
      end
      if berry == :PERSIMBERRY
        @battle.pbShowAbilityBox(self)
        recipient.pbConfuse(nil)
        @battle.pbHideAbilityBox(self)
      end
    end

    # Healing Berries
    if self.canHeal?
      healing = 0
      case berry
        when :ORANBERRY, :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY
          healing = getItemHP(medicinedata.hp, self.totalhp)
        when :ENIGMABERRY
          healing = (self.totalhp / 4.0).floor
      end
      if healing > 0
        healing *= 2 if self.ability == :RIPEN
        self.pbRecoverHP(healing, true, message: _INTL("{1} restored its health using its {2}!", pbThis, itemname))
        if [:FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY].include?(berry)
          flavors = $cache.items[berry].berry.flavors
          dislike = $cache.natures[self.nature].dislike
          confusion = flavors.include?(dislike)
          if confusion && pbCanConfuse?(self, nil)
            @battle.pbDisplay(_INTL("For {1}, {2} was too {3}!", pbThis(true), getItemName(berry, :the), getFlavorName(dislike)))
            pbConfuse
          end
        end
        if self.ability == :ONEBADAPPLE
          @battle.pbShowAbilityBox(self)
          recipient.pbReduceHP(healing)
          @battle.pbHideAbilityBox(self)
        end
      end
    end

    # Stat-changing Berries
    chosen_stat = 0
    increment = 1
    case berry
      when :LIECHIBERRY                then chosen_stat = PBStats::ATTACK
      when :GANLONBERRY, :KEEBERRY     then chosen_stat = PBStats::DEFENSE
      when :PETAYABERRY                then chosen_stat = PBStats::SPATK
      when :APICOTBERRY, :MARANGABERRY then chosen_stat = PBStats::SPDEF
      when :SALACBERRY                 then chosen_stat = PBStats::SPEED
      when :STARFBERRY
        stats = PBStats::Omni
        stats = stats.select { |stat| self.pbCanIncreaseStatStage?(stat, self, nil) }
        chosen_stat = @battle.sample(stats) unless stats.empty?
        increment = 2
    end
    increment *= 2 if self.ability == :RIPEN
    pbChangeStats(chosen_stat, increment, self, nil, statmessage: berry) if chosen_stat > 0

    if self.ability == :ONEBADAPPLE && chosen_stat > 0
      @battle.pbShowAbilityBox(self)
      recipient.pbChangeStats(chosen_stat, -increment, self, nil, statmessage: berry)
      @battle.pbHideAbilityBox(self)
    end

    # Lansat Berry
    if berry == :LANSATBERRY && @effects[:FocusEnergy] < 1
      @effects[:FocusEnergy] = 2
      @battle.pbDisplay(_INTL("{1} used {2} to get pumped!", pbThis, getItemName(berry, :the)))
    end

    if self.ability == :ONEBADAPPLE && berry == :LANSATBERRY
      @battle.pbShowAbilityBox(self)
      @battle.pbAnimation(:LOCKON, self, recipient)
      self.effects[:LockOn] = 2
      self.effects[:LockOnTarget] = recipient.index
      @battle.pbHideAbilityBox(self)
    end
    # Micle Berry
    if berry == :MICLEBERRY && !@effects[:MicleBerry]
      @effects[:MicleBerry] = true
      @battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move using its {2}!", pbThis, itemname))
    end

    if self.ability == :ONEBADAPPLE && berry == :MICLEBERRY
      @battle.pbShowAbilityBox(self)
      @battle.pbAnimation(:LOCKON, self, recipient)
      pbChangeStats(PBStats::ACCURACY, -1, recipient, nil, statmessage: berry)
      @battle.pbHideAbilityBox(self)
    end

    # Leppa Berry
    if berry == :LEPPABERRY
      zero_pp = @pokemon.moves.any? { |move| move.move && !PokeBattle_Move.pbFromPBMove(@battle, move, @pokemon).usable? }
      for i in 0...@pokemon.moves.length
        pokemove = @pokemon.moves[i]
        if !zero_pp
          next if pokemove.pp == pokemove.totalpp
        else
          next if pokemove.pp != 0
        end

        pokemove.pp += self.ability == :RIPEN ? 20 : 10
        pokemove.pp = [pokemove.totalpp, pokemove.pp].min
        self.moves[i].pp = pokemove.pp
        @battle.pbDisplay(_INTL("{1} restored {2}'s PP using its {3}!", pbThis, getMoveName(pokemove.move), itemname))
        break
      end
    end

    if self.ability == :ONEBADAPPLE && berry == :LEPPABERRY
      randomindex = @battle.pbRandom(4)
      @battle.pbShowAbilityBox(self)
      for i in 0...recipient.pokemon.moves.length
        next if i != randomindex
        pokemove = @pokemon.moves[i] if i == randomindex
        pokemove.pp == 0
        @battle.pbDisplay(_INTL("{1} depleted {2}'s PP using its {3}!", self.pbThis, getMoveName(pokemove.move), itemname))
      end
      @battle.pbHideAbilityBox(self)
    end

    @battle.pbHideAbilityBox(self) if animation

    # Cud Chew
    pbCudChew(berry)

    # Dispose
    if special
      pbBurp
      pbSymbiosis
    else
      pbDisposeItem
    end
  end

  def pbCudChew(berry)
    if self.ability == :CUDCHEW && self.effects[:CudChewBerry].nil?
      self.effects[:CudChewBerry] = berry
      self.effects[:CudChewTurns] = 2
    end
  end

  def pbCustapBerry
    return false if @battle.pbCheckSideAbility(PBStuff::UnnerveAbilities, self.pbOpposing1).any?
    return false unless self.hasWorkingItem(:CUSTAPBERRY)
    return false unless (self.ability == :GLUTTONY && self.hp <= (self.totalhp / 2.0).floor) || self.hp <= (self.totalhp / 4.0).floor

    @battle.pbShowAbilityBox(self, item: true)
    @battle.pbCommonAnimation("Nom", self, nil)
    @battle.pbDisplay(_INTL("{1}'s {2} let it move first!", pbThis, getItemName(self.item)))
    @battle.pbHideAbilityBox(self)
    self.pbCudChew(:CUSTAPBERRY)
    self.pbDisposeItem
    return true
  end

  def pbEjectPackCheck(immediate: true)
    return if self.isFainted?

    return unless self.effects[:EjectPack]
    self.effects[:EjectPack] = false

    return unless self.hasWorkingItem(:EJECTPACK)
    return unless self.canTriggerUserSwitch?

    immediate ? self.carryOutUserSwitch(:EjectPack) : self.userSwitch = :EjectPack
  end

  def triggerAdrenalineOrb(delaysymbiosis: false)
    return unless pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)

    @battle.pbShowAbilityBox(self, item: true)
    @battle.pbCommonAnimation("UseItem", self, nil)
    pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip, statmessage: :Item)
    @battle.pbHideAbilityBox(self)
    pbDisposeItem(symbiosis: delaysymbiosis ? :delay : true)
  end

  def pbDisposeItem(burp: true, symbiosis: true, pickupable: true, duringattack: false)
    return if self.item.nil?

    berry = pbIsBerry?(self.item)

    @battle.pickupA.delete(self.index)
    @battle.pickupB.delete(self.index)
    if duringattack && pickupable
      @battle.pickupB.unshift(self.index)
    elsif pickupable
      @battle.pickupA.unshift(self.index)
    end

    removeItem(permanent: true, recycle: true)
    pbBurp if burp && berry
    pbSymbiosis if symbiosis == true
    self.effects[:DelaySymbiosis] = true if symbiosis == :delay
  end

  def pbBurp(target = self)
    target.permeffs[:Belch] = true
    if target.ability == :CHEEKPOUCH && !target.isFainted? && target.canHeal?
      @battle.pbShowAbilityBox(target)
      target.pbRecoverHP((target.totalhp / 3.0).floor, true, message: _INTL("{1} had its HP restored.", pbThis))
      @battle.pbHideAbilityBox(target)
    end
  end

  def pbSymbiosis
    target = self # Battler receiving the item
    target.effects[:DelaySymbiosis] = false
    return if target.isFainted? || target.pbPartner.isFainted?
    return if target.pbPartner.ability != :SYMBIOSIS
    return if !target.item.nil? || target.pbPartner.item.nil? || @battle.pbIsUnlosableItem(target.pbPartner, target.pbPartner.item) || @battle.pbIsUnlosableItem(target, target.pbPartner.item, symbiosis: true)

    @battle.pbAbilityBoxAndDisplay(target.pbPartner, _INTL("{1} shared its {2} with {3}!", target.pbPartner.pbThis, getItemName(target.pbPartner.item), target.pbThis(true)))
    target.pbPartner.transferItem(target)

    if target.hasCrest?
      if target.species == :ZORUA
        target.crested = :ZOROARK
      else
        target.crested = target.species
      end
      target.crestStats
      @battle.pbCrestEffects(target.index, target)
    end
  end

  ################################################################################
  # Move user and targets
  ################################################################################
  def pbFindTargets(choice, targets)
    move = choice[2]
    target = choice[3]

    if target >= 0 && @battle.doublebattle && @battle.battlers[target].pbOwnSide.effects[:AllySwitch] &&
       ([:PROPELLERTAIL, :STALWART].include?(self.ability) || move.function == 0x179) # Snipe Shot
      # The intended target has moved using Ally Switch but Snipe Shot, Propeller Tail and Stalwart are unaffected.
      target = target ^ 2
    end

    # Targets in normal cases
    case pbTarget(move)
      when :SingleNonUser, :SingleOpposing
        if target >= 0 # Pre-chosen target
          targetBattler = @battle.battlers[target]
          if !pbIsOpposing?(targetBattler.index)
            move.pbAddTarget(targets, targetBattler, self)
          else
            move.pbAddTarget(targets, targetBattler.pbPartner, self) if !move.pbAddTarget(targets, targetBattler, self) && move.move != :MEFIRST
          end
        else
          pbRandomTarget(targets, move)
        end
      when :OppositeOpposing
        move.pbAddTarget(targets, pbCrossOpposing, self) if !move.pbAddTarget(targets, pbOppositeOpposing, self)
        pbRandomTarget(targets, move) if targets.length == 0
      when :RandomOpposing
        pbRandomTarget(targets, move)
      when :AllOpposing
        move.pbAddTarget(targets, pbOpposing1, self)
        move.pbAddTarget(targets, pbOpposing2, self)
      when :AllNonUsers
        move.pbAddTarget(targets, pbOpposing1, self)
        move.pbAddTarget(targets, pbOpposing2, self)
        move.pbAddTarget(targets, pbPartner, self)
      when :DragonDarts
        if target >= 0 # Pre-chosen target
          targetBattler = @battle.battlers[target]
          move.pbAddTarget(targets, targetBattler, self)
          move.pbAddTarget(targets, targetBattler.pbPartner, self) if targetBattler.pbPartner != self
        else
          pbRandomTarget(targets, move)
          move.pbAddTarget(targets, targets.first.pbPartner, self) if targets.length > 0
        end
      when :UserOrPartner
        if target >= 0 # Pre-chosen target
          targetBattler = @battle.battlers[target]
          move.pbAddTarget(targets, targetBattler.pbPartner, self) if !move.pbAddTarget(targets, targetBattler, self)
        else
          move.pbAddTarget(targets, self, self)
        end
      when :Partner
        move.pbAddTarget(targets, pbPartner, self)
      when :AllyBattlers # magnetic flux, gear up, gen 8 howl, life dew, jungle healing, lunar blessing
        move.pbAddTarget(targets, pbPartner, self)
        move.pbAddTarget(targets, self, self)
      when :AllBattlers # perish song, rototiller, flower shield, teatime, shadow half
        move.pbAddTarget(targets, pbOpposing1, self)
        move.pbAddTarget(targets, pbOpposing2, self)
        move.pbAddTarget(targets, pbPartner, self)
        move.pbAddTarget(targets, self, self)
      when :OpposingSide
        move.pbAddTarget(targets, pbOpposing1, self)
        move.pbAddTarget(targets, pbOpposing2, self)
        if targets.length < 1
          move.pbAddTarget(targets, self, self)
        end
      when :NonUserPosition # aims at a battler position, no fainted check, no retarget
        if target >= 0 # Pre-chosen target
          targets.push(@battle.battlers[target])
        else
          targets.push(@battle.sample([pbOppositeOpposing, pbCrossOpposing]))
        end
      else # :User, :BothSides, :UserSide, :NoTarget
        move.pbAddTarget(targets, self, self)
    end
  end

  def pbChangeUser(basemove, user, targets)
    return user unless !basemove.zmove && basemove.canSnatch?

    priority = @battle.setSpeedOrder
    for i in priority
      next unless i.effects[:Snatch]

      @battle.pbDisplay(_INTL("{1} snatched {2}'s move!", i.pbThis, user.pbThis(true)))
      if @battle.FE == :BACKALLEY
        stat = @battle.sample(PBStats::Omni)
        i.pbChangeStats(stat, 2, i, nil)
      end
      i.effects[:Snatch] = false
      target = user # keep original move user for pressure check below
      # edit existing targets array (do not use "targets = [i]")
      targets.clear
      targets.push(i)
      user = i # Change user to user of Snatch
      # Snatch's PP is reduced if old user has Pressure
      userchoice = @battle.choices[user.index][1]
      if target.ability == :PRESSURE && userchoice >= 0
        pressuremove = user.moves[userchoice]
        pbSetPP(pressuremove, pressuremove.pp - 1) if pressuremove.pp > 0
        if [:DIMENSIONAL, :DEEPEARTH].include?(@battle.FE)
          pressuremove = user.moves[userchoice]
          pbSetPP(pressuremove, pressuremove.pp - 1) if pressuremove.pp > 0
        end
      end
      break # No Snatch chaining Gen 5 onwards
    end
    return user
  end

  def pbTarget(move)
    target = move.target
    if move.function == 0x10D && hasType?(:GHOST) # Curse
      # Gen 8 change changes Curse to random opponent but we decided to ignore this change
      # target = Gen >= 8 ? :RandomOpposing : :SingleNonUser
      target = :SingleNonUser
    elsif move.function == 0x167 && ((@status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, self).none?) || @effects[:HealBlock] > 0) # Pollen Puff when Heal Blocked
      target = :SingleOpposing
    elsif move.type == :FIRE && self.crested == :ENTEI
      target = :AllOpposing
    elsif self.isbossmon && (Rejuv && @pokemon.bossID == :M31YVELTAL) && move.move == :WHIRLWIND
      target = :AllOpposing
    elsif (@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN) && move.move == :EXPANDINGFORCE
      target = :AllOpposing
    elsif move.function == 0x522 && isStellarTerapagos? # Tera Starstorm
      target = :AllOpposing
    elsif @battle.FE == :FLOWERGARDEN5 && (move.powderMove? || PBFields::MAXGARDENMOVES.include?(move.move))
      target = :AllOpposing
    elsif @battle.FE == :HAUNTED && (move.move == :MEANLOOK || move.move == :FIRESPIN)
      target = :AllOpposing
    elsif @battle.FE == :DEEPEARTH && move.move == :TOPSYTURVY
      target = :AllNonUsers
    elsif @battle.FE == :DEEPEARTH && move.move == :GRAVITY
      target = :AllOpposing
    elsif self.ability == :TEMPEST && move.move == :WEATHERBALL
      target = :AllOpposing
    elsif self.ability == :WORLDOFNIGHTMARES && move.move == :NIGHTMARE
      target = :AllOpposing
    end
    return target
  end

  def pbRandomTarget(targets, move)
    choices = []
    choices.push(pbOpposing1) unless pbOpposing1.isFainted?
    choices.push(pbOpposing2) unless pbOpposing2.isFainted?
    if choices.length > 0
      targets.push(@battle.sample(choices))
    end
  end

  def pbChangeTarget(basemove, user, targets)
    return targets if [0x0AE, 0x0B0, 0x0B3, 0x179, 0x0CE].include?(basemove.function) # Mirror Move / Me First / Nature Power / Snipe Shot / Sky Drop
    return [user] if user.effects[:TwoTurnAttack] == basemove.move
    return targets if [:STALWART, :PROPELLERTAIL].include?(user.ability)
    targetchoices = pbTarget(basemove)
    return targets unless [:SingleNonUser, :NonUserPosition, :SingleOpposing, :RandomOpposing, :OppositeOpposing, :DragonDarts].include?(targetchoices)

    changeeffect = -1
    priority = @battle.setSpeedOrder
    primarytype = basemove.pbType(user)
    movetypes = [basemove.pbType(user), *basemove.getSecondaryType(user, primarytype)]
    originalTarget = targets[0] # used to confirm if a redirection message needs to be displayed, only applied to single target moves

    for i in priority # use Pokémon earliest in priority
      next if i.index == user.index || i.isFainted?

      if ((i.ability == :LIGHTNINGROD && movetypes.include?(:ELECTRIC) && !(user == i.pbPartner && basemove.move == :THUNDERRAID)) ||
        (i.ability == :STORMDRAIN && movetypes.include?(:WATER))) && !i.moldbroken
        target = i
        changeeffect = 1
        break
      end
    end

    for i in priority # use Pokémon earliest in priority
      next if !user.pbIsOpposing?(i.index) || i.isFainted?

      if i.effects[:FollowMe] || (i.effects[:RagePowder] && !user.powderImmune?) || (i.item == :BLACKLANTERN && !i.permeffs[:BlackLanternLight] && PBStuff::MOTHLIST.include?(user.species))
        target = i
        changeeffect = 0
        i.permeffs[:BlackLanternLight] = true if i.item == :BLACKLANTERN
        # no break
      end
    end

    if changeeffect > -1
      targets = [target]
      if changeeffect == 1 && (originalTarget != target || targetchoices == :DragonDarts) # a redirection involving Dragon Darts always has an effect so always displays a message
        @battle.pbDisplay(_INTL("{1} took the attack!", target.pbThis))
      end
    end
    return targets
  end

  def pbFutureSightUserPlusMove()
    moveuser = nil
    disabled_items = {}
    # check if battler on the field
    for battler in @battle.battlers
      moveuser = battler if battler.pokemon == @effects[:FutureSightPokemon] && !battler.isFainted?
    end
    # if battler not on the field, make a fake one
    if moveuser.nil?
      moveuser = PokeBattle_Battler.new(@battle, @effects[:FutureSightUserIndex], true)
      party = @battle.pbPartySingleOwner(@effects[:FutureSightUserIndex])
      # get the party position of the future sight pokemon, if the pokemon doesn't exist anymore in the relevant party, as it can happen with SOS pokemon, don't assign a party position
      partyIndex = party.include?(@effects[:FutureSightPokemon]) ? party.find_index(@effects[:FutureSightPokemon]) : -1
      moveuser.pbInitPokemon(@effects[:FutureSightPokemon], partyIndex)
      disabled_items = { :item => moveuser.item.clone, :ability => moveuser.ability.clone }
      moveuser.item = nil
      moveuser.ability = nil
    end
    futuremove = PBStuff::FUTUREATTACKS[@effects[:FutureSightMove]]
    move = PokeBattle_Move.pbFromPBMove(@battle, PBMove.new(futuremove), moveuser.pokemon)
    return move, moveuser, disabled_items
  end

  ################################################################################
  # Move PP
  ################################################################################
  def pbSetPP(move, pp)
    move.pp = pp
    # Not effects[:Mimic], since Mimic can't copy Mimic
    if move.basemove && move.move == move.basemove.move && !@effects[:Transform]
      move.basemove.pp = pp
    end
  end

  def pbReducePP(move, pressure = false)
    if @effects[:TwoTurnAttack] != 0 ||
       @effects[:Bide] > 0 ||
       @effects[:Outrage] > 0 ||
       @effects[:Rollout] > 0 ||
       @effects[:HyperBeam] > 0 ||
       @effects[:Uproar] > 0
      # No need to reduce PP if two-turn attack
      return true
    end
    return true if move.pp < 0 # No need to reduce PP for special calls of moves
    return true if move.totalpp == 0 # Infinite PP, can always be used
    return false if move.pp == 0

    if move.pp > 0
      pbSetPP(move, move.pp - 1)
      shouldcount = checkEvolutionEx(@pokemon) { |pokemon, method, condition, evo|
        next true if method == :UseMove && move.move == condition[1]
      }
      @pokemon.timesMoveUsed += 1 if shouldcount && !pressure
    end
    return true
  end

  def pbReducePPOther(move)
    pbSetPP(move, move.pp - 1) if move.pp > 0
  end

  ################################################################################
  # Using a move
  ################################################################################
  def pbObedienceCheck?(choice)
    return true if $DEBUG && Input.press?(Input::CTRL)
    return true if $game_switches[:IsThisStillPokemon?]
    return true if @battle.isOnline?
    return true if choice[0] != :move
    if self.respond_to?("pbHyperModeObedience")
      shadowDisobediance = self.pbHyperModeObedience(move)
    end
    return true unless self.permeffs[:Disobedient] || shadowDisobediance

    if @battle.pbOwnedByPlayer?(@index) && @battle.internalbattle
      badgelevel = (@battle.pbPlayer.numbadges >= 0 && @battle.pbPlayer.numbadges < LEVELCAPS.length) ? LEVELCAPS[@battle.pbPlayer.numbadges] : LEVELCAPS[0]
      move = choice[2]
      disobedient = false
      a = ((@level + badgelevel) * @battle.pbRandom(256) / 256.0).floor
      disobedient |= a >= badgelevel if !(Rejuv && $game_switches[:NotPlayerCharacter])
      disobedient |= shadowDisobediance
      if Rejuv && self.pokemon.disobedient && @battle.pbRandom(10) >= 1
        disobedient = true
      end
      if disobedient
        @effects[:Rage] = false
        if self.status == :SLEEP &&
           (move.function == 0x11 || move.function == 0xB4) # Snore, Sleep Talk
          @battle.pbDisplay(_INTL("{1} ignored orders while asleep!", pbThis))
          return false
        end
        b = ((@level + badgelevel) * @battle.pbRandom(256) / 256.0).floor
        # if b<badgelevel
        #  return false if !@battle.pbCanShowFightMenu?(@index)
        #  othermoves=[]
        #  for i in 0...4
        #    next if i==choice[1]
        #    othermoves[othermoves.length]=i if @battle.pbCanChooseMove?(@index,i)
        #  end
        #  if othermoves.length>0
        #    @battle.pbDisplay(_INTL("{1} ignored orders!",pbThis))
        #    newchoice=othermoves[@battle.pbRandom(othermoves.length)]
        #    choice[1]=newchoice
        #    choice[2]=@moves[newchoice]
        #    choice[3]=-1
        #  end
        #  return true
        # elsif self.status!=:SLEEP
        if self.status != :SLEEP
          c = @level - b
          r = @battle.pbRandom(256)
          if r < c && pbCanSleep?(self, nil)
            pbSleep(message: _INTL("{1} took a nap!", pbThis))
            return false
          end
          r -= c
          if r < c
            @battle.pbDisplay(_INTL("{1} won't obey!", pbThis))
            @battle.pbDisplay(_INTL("It hurt itself from its confusion!"))
            pbConfusionDamage
          else
            message = @battle.pbRandom(4)
            @battle.pbDisplay(_INTL("{1} ignored orders!", pbThis)) if message == 0
            @battle.pbDisplay(_INTL("{1} turned away!", pbThis)) if message == 1
            @battle.pbDisplay(_INTL("{1} is loafing around!", pbThis)) if message == 2
            @battle.pbDisplay(_INTL("{1} pretended not to notice!", pbThis)) if message == 3
          end
          return false
        end
      end
      return true
    else
      return true
    end
  end

  def successCheckFinished?(targets, hitflags, basemove)
    targetchoices = pbTarget(basemove)
    if targets.length > 1
      if targetchoices == :DragonDarts
        hitflags.each_with_index do |hitflag, i|
          if ![:Success, :MirrorMissReflect].include?(hitflag)
            hitflags.delete_at(i)
            targets.delete_at(i)
            break
          end
        end
      elsif targetchoices == :OpposingSide
        for bounceEffect in [:MagicCoated, :MagicBounced]
          if hitflags.include?(bounceEffect)
            # just so we are clear
            # there is going to be at most 2 targets on here so only one needs to be removed
            # we are akwardly specifically deleting the unwanted target from the array instead of replacing with a new array
            # because these arrays aren't returned they are edited as pointers so it has to stay the same array
            index = (hitflags.index(bounceEffect) + 1) % 2
            hitflags.delete_at(index)
            targets.delete_at(index)
            break
          end
        end
      end
    end
    return !hitflags.intersect?([:Success, :MirrorMissReflect])
  end

  # pbSuccessCheck and by extension pbTypeImmunities have to check a failure condition for each target of a move before moving on to the next one
  # this is canonical behaviour which becomes relevant in the case of dragon darts, because in the case of dragon darts if the attack fails against both targets
  # the failure condition that is reported and resolved is the lowest priority between the 2 targets (the latest to be checked)
  # the first target to fail is ignored entirely, target order only matters if both target fail for the same reason, in which case the target that wasn't originally chosen is reported (the 2nd target)
  def pbSuccessCheck(basemove, targets, flags, accuracy = true)
    targetchoices = pbTarget(basemove)
    # certain moves have the user themself assigned as the target, none of the failure conditions after this point apply to such moves
    # moves with the user itself as the target are never damaging (in this turn anyway in the context of 2 turn moves) and are as such treated as status moves
    # the only way a move like that is going to fail is due to inherent failure conditions so check those otherwise success
    if targets.difference([self]).none? && ![:AllBattlers, :AllyBattlers, :DragonDarts].include?(targetchoices)
      if [:SingleNonUser, :UserOrPartner].include?(targetchoices) && self.pbOwnSide.effects[:AllySwitch]
        # The user ended up targeting itself because of Ally Switch. In this case the move should fail.
        # In case it was a Z-Move, the Z-Power boost should still apply (which it does above).
        return [:SelfTargetFailure]
      elsif !basemove.pbCanAffectTarget(self, targets.first)
        return [:MoveFailCat2]
      elsif !basemove.pbEffectValid(self, targets.first)
        return [:MoveFailCat3]
      else
        return [:StatusSuccess]
      end
    end

    hitflags = [:Success] * targets.length
    if targetchoices != :OpposingSide
      targets.each_with_index do |target, i|
        next if hitflags[i] != :Success
        next if !target.effects[:Commander]
        hitflags[i] = :Commander
      end
      targets.each_with_index do |target, i|
        next if hitflags[i] != :Success
        next unless basemove.invulMisses?(self, target)
        hitflags[i] = :Invulmiss
      end
      return hitflags if successCheckFinished?(targets, hitflags, basemove)
      movetoblock = basemove.callermove || basemove # Psychic Terrain considers priority of the caller move only, if there is one
      if (@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN) && movetoblock.priorityCheck(self) > 0
        targets.each_with_index do |target, i|
          next if hitflags[i] != :Success
          next if target.isAirborne?
          next if @battle.FE == :CHESS && self.piece == :KING && Rejuv # skip the King, otherwise OV would completely negate it
          next if !self.pbIsOpposing?(target.index) # Does not apply to user and ally
          hitflags[i] = :NoPriority
        end
        return hitflags if successCheckFinished?(targets, hitflags, basemove)
      end
      if basemove.canProtect? && !flags[:FutureSight] && !basemove.zmove && !basemove.unseenFistCheck(self) && !(Rejuv && basemove.move == :KOWTOWCLEAVE && @battle.FE == :CHESS) # Bypassing protect with decreased damage is handled elsewhere
        if [:AllOpposing, :AllNonUsers].include?(targetchoices)
          targets.each_with_index do |target, i|
            next if hitflags[i] != :Success
            next if !target.pbOwnSide.effects[:WideGuard]
            hitflags[i] = :WideGuard
          end
          return hitflags if successCheckFinished?(targets, hitflags, basemove)
        end
        if basemove.priorityCheck(self) > 0
          targets.each_with_index do |target, i|
            next if hitflags[i] != :Success
            next if !target.pbOwnSide.effects[:QuickGuard]
            hitflags[i] = :QuickGuard
          end
          return hitflags if successCheckFinished?(targets, hitflags, basemove)
        end
        if basemove.pbIsStatus?
          targets.each_with_index do |target, i|
            next if hitflags[i] != :Success
            next if !target.pbOwnSide.effects[:CraftyShield]
            hitflags[i] = :CraftyShield
          end
          return hitflags if successCheckFinished?(targets, hitflags, basemove)
        end
        if basemove.pbIsDamaging?
          targets.each_with_index do |target, i|
            next if hitflags[i] != :Success
            next if !target.pbOwnSide.effects[:MatBlock]
            hitflags[i] = :MatBlock
          end
          return hitflags if successCheckFinished?(targets, hitflags, basemove)
        end
        # Protect / King's Shield / Obstruct / Spiky Shield / Baneful Bunker / Silk Trap / Burning Bulwark
        targets.each_with_index do |target, i|
          next if hitflags[i] != :Success
          next if !target.effects[:Protect]
          if basemove.pbIsStatus?
            case target.effects[:Protect]
              when :KingsShield then next unless [:FAIRYTALE, :CHESS].include?(@battle.FE)
              when :Obstruct then next unless [:DIMENSIONAL, :CHESS].include?(@battle.FE)
              when :SilkTrap then next unless [:FOREST].include?(@battle.FE)
              when :BurningBulwark then next unless [:BURNING, :VOLCANIC, :NEWWORLD].include?(@battle.FE)
            end
          end
          hitflags[i] = target.effects[:Protect]
        end
        return hitflags if successCheckFinished?(targets, hitflags, basemove)
      end
      if basemove.pbIsStatus?
        targets.each_with_index do |target, i|
          next if hitflags[i] != :Success
          next if target.moldbroken
          hitflags[i] = :GoodAsGold if target.ability == :GOODASGOLD
        end
        return hitflags if successCheckFinished?(targets, hitflags, basemove)
      end
    end
    if basemove.canMagicCoat? && !self.effects[:MagicBounced]
      targets.each_with_index do |target, i|
        next if hitflags[i] != :Success
        hitflags[i] = :MagicCoated if target.effects[:MagicCoat]
      end
      return hitflags if successCheckFinished?(targets, hitflags, basemove)
      targets.each_with_index do |target, i|
        next if hitflags[i] != :Success
        next if target.moldbroken
        hitflags[i] = :MagicBounced if target.ability == :MAGICBOUNCE
      end
      return hitflags if successCheckFinished?(targets, hitflags, basemove)
    end
    # we have gotten past the section why hazard moves are listed as targeting all opponents, and should handle as self targeted now, to avoid issues
    if targetchoices == :OpposingSide
      # it is important that this remains the same array object so even if "targets = [self]" looks easier, it would in fact be wrong
      targets.clear
      targets.push(self)
      hitflags = [:Success]
    end
    if targetchoices != :OpposingSide
      if basemove.powderMove?
        targets.each_with_index do |target, i|
          next if hitflags[i] != :Success
          next if target.moldbroken
          hitflags[i] = :Overcoat if target.ability == :OVERCOAT
        end
        return hitflags if successCheckFinished?(targets, hitflags, basemove)
      end
      if basemove.windMove?
        targets.each_with_index do |target, i|
          next if hitflags[i] != :Success
          next if target.moldbroken
          hitflags[i] = :WindRider if target.ability == :WINDRIDER
        end
        return hitflags if successCheckFinished?(targets, hitflags, basemove)
      end
      basemove.pbTypeImmunities(self, targets, hitflags)
      return hitflags if successCheckFinished?(targets, hitflags, basemove)
      if basemove.pbIsDamaging?
        # Canon timing for Telepathy is in the middle of type immunity abilities but moving it here
        # allows us to keep it together with Holy Field, without affecting anything mechanically
        targets.each_with_index do |target, i|
          next if hitflags[i] != :Success
          next if self.pbIsOpposing?(target.index)
          next if target.moldbroken
          hitflags[i] = :Telepathy if target.ability == :TELEPATHY
        end
        return hitflags if successCheckFinished?(targets, hitflags, basemove)
        if @battle.FE == :HOLY
          targets.each_with_index do |target, i|
            next if hitflags[i] != :Success
            next if self.pbIsOpposing?(target.index)
            hitflags[i] = :Holy
          end
          return hitflags if successCheckFinished?(targets, hitflags, basemove)
        end
      end
      if basemove.powderMove?
        targets.each_with_index do |target, i|
          next if hitflags[i] != :Success
          hitflags[i] = :SafetyGoggles if target.hasWorkingItem(:SAFETYGOGGLES)
        end
      end
      if basemove.bulletMove?
        targets.each_with_index do |target, i|
          next if hitflags[i] != :Success
          next if target.moldbroken
          hitflags[i] = :BulletProof if target.ability == :BULLETPROOF
        end
        return hitflags if successCheckFinished?(targets, hitflags, basemove)
        if @battle.FE == :ROCKY
          targets.each_with_index do |target, i|
            next if hitflags[i] != :Success
            next if !(target.effects[:Substitute] > 0 || target.stages[PBStats::DEFENSE] > 0) || self.ability == :HOTSHOT
            hitflags[i] = :RockyBulletProof
          end
          return hitflags if successCheckFinished?(targets, hitflags, basemove)
        end
      end
      targets.each_with_index do |target, i|
        next if hitflags[i] != :Success
        next if !target.isbossmon
        hitflags[i] = :BossImmunity if bossImmunityCheck(basemove, self, target)
      end
      return hitflags if successCheckFinished?(targets, hitflags, basemove)
      movetoblock = basemove.callermove || basemove # Prankster vs Dark interaction considers only whether the caller move is boosted by Prankster, if there is one
      if @battle.FE != :BEWITCHED && !(Rejuv && @battle.FE == :GLITCH) && self.ability == :PRANKSTER && movetoblock.pbIsStatus?
        targets.each_with_index do |target, i|
          next if hitflags[i] != :Success
          next if !self.pbIsOpposing?(target.index) # Does not apply to user and ally
          hitflags[i] = :PranksterDark if target.hasType?(:DARK)
        end
        return hitflags if successCheckFinished?(targets, hitflags, basemove)
      end
      if basemove.powderMove?
        targets.each_with_index do |target, i|
          next if hitflags[i] != :Success
          hitflags[i] = :PowderGrass if target.hasType?(:GRASS)
        end
        return hitflags if successCheckFinished?(targets, hitflags, basemove)
      end
    end
    targets.each_with_index do |target, i|
      next if hitflags[i] != :Success
      hitflags[i] = :MoveFailCat2 if !basemove.pbCanAffectTarget(self, target)
    end
    return hitflags if successCheckFinished?(targets, hitflags, basemove)
    if accuracy
      targets.each_with_index do |target, i|
        next if hitflags[i] != :Success
        next if basemove.pbAccuracyCheck(self, target) # Includes Counter/Mirror Coat
        if @battle.FE == :MIRROR && (targetchoices == :SingleNonUser || basemove.move == :MIRRORCOAT) &&
           !self.makesContact?(basemove) && basemove.pbIsSpecial?(self, basemove.type) &&
           target.stages[PBStats::EVASION] > 0 && basemove.function != 0x70 # OHKO moves (Sheer Cold)
          hitflags[i] = :MirrorMissReflect
        else
          self.missAcc = true unless basemove.function == 0x70 # OHKO moves don't activate Blunder Policy
          hitflags[i] = :AccuracyMiss
        end
      end
      return hitflags if successCheckFinished?(targets, hitflags, basemove)
    end
    targets.each_with_index do |target, i|
      next if ![:Success, :MirrorMissReflect].include?(hitflags[i])
      hitflags[i] = :MoveFailCat3 if !basemove.pbEffectValid(self, target)
    end
    return hitflags if successCheckFinished?(targets, hitflags, basemove)
    targets.each_with_index do |target, i|
      next if ![:Success, :MirrorMissReflect].include?(hitflags[i])
      hitflags[i] = :StatusSuccess if self.effects[:TwoTurnAttack] == basemove.move || basemove.pbIsStatus?
    end
    return hitflags
  end

  def moveFailureEffects(user, basemove, target, hitflag)
    targetchoices = pbTarget(basemove)
    # messaging of move failure
    case hitflag
      when :PranksterDark, :TypeImmunity
        @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
      when :NoPriority then @battle.pbDisplay(_INTL("{1} is protected by the {2}!", target.pbThis, getMoveName(:PSYCHICTERRAIN)))
      when :Soundproof, :GoodAsGold, :Levitate, :WonderGuard, :BulletProof, :MagmaArmor, :PurifyingSalt
        @battle.pbAbilityBoxAndDisplay(target, _INTL("It doesn't affect\n{1}...", target.pbThis(true)))
      when :MatBlock, :Protect, :KingsShield, :SpikyShield, :BanefulBunker, :Obstruct, :SilkTrap, :BurningBulwark
        @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
      when :AirBalloon then @battle.pbDisplay(_INTL("{1} floats above the attack on its {2}!", target.pbThis, getItemName(target.item)))
      when :MagnetRise then @battle.pbDisplay(_INTL("{1} floats above the attack with electromagnetism!", target.pbThis))
      when :Telekinesis then @battle.pbDisplay(_INTL("{1} floats above the attack with telekinesis!", target.pbThis))
      when :MirrorMissReflect then @battle.pbDisplay(_INTL("The attack was reflected by the mirror!"))
      when :BossImmunity then @battle.pbDisplay(_INTL("{1} resisted the attack!", target.pbThis))
      when :RockyBulletProof then @battle.pbDisplay(_INTL("{1} hid behind a rock to dodge the attack!", target.pbThis))
      when :Telepathy then @battle.pbAbilityBoxAndDisplay(target, _INTL("{1} avoids attacks by its ally Pokémon!", target.pbThis))
      when :Holy then @battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!", target.pbThis))
      when :Commander then @battle.pbDisplay(_INTL("{1} avoided the attack!", target.pbThis))
      when :CraftyShield then @battle.pbDisplay(_INTL("{1} protected {2}!", getMoveName(:CRAFTYSHIELD), target.pbThis(true)))
      when :QuickGuard then @battle.pbDisplay(_INTL("{1} protected {2}!", getMoveName(:QUICKGUARD), target.pbThis(true)))
      when :WideGuard then @battle.pbDisplay(_INTL("{1} protected {2}!", getMoveName(:WIDEGUARD), target.pbThis(true)))
      when :Invulmiss, :AccuracyMiss
        if (targetchoices == :AllOpposing && [user.pbOpposing1, user.pbOpposing2].count{ |i| !i.isFainted? } > 1) ||
           (targetchoices == :AllNonUsers && [user.pbOpposing1, user.pbOpposing2, user.pbPartner].count{ |i| !i.isFainted? } > 1) ||
           basemove.function == 0x70 # OHKO moves
          @battle.pbDisplay(_INTL("{1} avoided the attack!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s attack missed!", user.pbThis))
          if user.effects[:SkyDroppee] != nil
            target.effects[:SkyDrop] = false
            user.effects[:SkyDroppee] = nil
            @battle.scene.pbUnVanishSprite(target)
            @battle.pbDisplay(_INTL("{1} was freed from the {2}!", target.pbThis, getMoveName(:SKYDROP)))
          end
        end
      # the difference between category 2 and 3 move failures is that category 3 failures do not activate Stomping Tantrum
      # aswell as their timing, Category 3 move failures are checked after the accuracy check is made, category 2 beforehand
      when :MoveFailCat2
        basemove.pbCanAffectTarget(user, target, true)
      when :MoveFailCat3
        basemove.pbEffectValid(user, target, true)
    end
    # effects of protection/immunity
    contact = user.makesContact?(basemove) && !user.hasWorkingItem(:PROTECTIVEPADS)
    case hitflag
      when :KingsShield
        if contact
          stats = [:FAIRYTALE, :CHESS, :COLOSSEUM].include?(@battle.FE) ? PBStats::Offensive : PBStats::ATTACK
          amount = Gen <= 7 ? -2 : -1
          user.pbChangeStats(stats, amount, target, nil)
        end
      when :Obstruct
        if contact
          amount = -2
          user.pbChangeStats(PBStats::DEFENSE, amount, target, nil)
        end
      when :SpikyShield
        if contact
          damagedivider = @battle.FE == :COLOSSEUM ? 4.0 : 8.0
          user.pbReduceHP((user.totalhp / damagedivider).floor, true, message: _INTL("{1} was hurt!", user.pbThis))
        end
      when :BanefulBunker
        if contact
          user.pbPoison(target) if user.pbCanPoison?(target, nil)
        end
      when :SilkTrap
        if contact
          user.pbChangeStats(PBStats::SPEED, -1, target, nil)
        end
      when :BurningBulwark
        if contact
          user.pbBurn(target) if user.pbCanBurn?(target, nil)
        end
      when :MagicCoated
        target.bounceMove(user, :MagicCoat, basemove.move)
      when :MagicBounced
        target.bounceMove(user, :MagicBounce, basemove.move)
      when :ProtectiveRime
        @battle.pbShowAbilityBox(user)
        @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
        @battle.pbHideAbilityBox(user)
      when :SoundproofCrest
        abilityholder = @battle.pbCheckSideCrest(:FLYGON, target, excludeSelf: false).first
        @battle.pbShowAbilityBox(abilityholder, item: true)
        @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
        @battle.pbHideAbilityBox(abilityholder)
      when :SapSipperAbility, :SapSipperItem
        stats = hitflag == :SapSipperItem ? PBStats::Offensive : [PBStats::ATTACK]
        @battle.pbShowAbilityBox(target, item: hitflag == :SapSipperItem)
        if target.pbCanIncreaseAnyStat?(stats, target, nil)
          target.pbChangeStats(stats, 1, target, nil, abilitycheck: :skip)
        else
          @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
        end
        @battle.pbHideAbilityBox(target)
      when :DrainRod
        @battle.pbShowAbilityBox(target)
        statboost = 1
        if (Rejuv && @battle.FE == :SHORTCIRCUIT) && target.ability == :LIGHTNINGROD
          damageroll = @battle.field.getRoll(update_roll: true, maximize_roll: @battle.OV == :ELECTERRAIN)
          statboosts = [1, 2, 0, 1, 3]
          statboost = statboosts[PBStuff::SHORTCIRCUITROLLS.find_index(damageroll)]
        end
        if statboost != 0 && target.pbCanIncreaseStatStage?(PBStats::SPATK, target, nil)
          target.pbChangeStats(PBStats::SPATK, statboost, target, nil, abilitycheck: :skip)
        else
          @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
        end
        @battle.pbHideAbilityBox(target)
      when :MotorDriveAbility, :MotorDriveItem
        @battle.pbShowAbilityBox(target, item: hitflag == :MotorDriveItem)
        statboost = 1
        statboost = 2 if @battle.FE == :FACTORY
        if Rejuv && @battle.FE == :SHORTCIRCUIT
          damageroll = @battle.field.getRoll(update_roll: true, maximize_roll: @battle.OV == :ELECTERRAIN)
          statboosts = [1, 2, 0, 1, 3]
          statboost = statboosts[PBStuff::SHORTCIRCUITROLLS.find_index(damageroll)]
        end
        if statboost != 0 && target.pbCanIncreaseStatStage?(PBStats::SPEED, target, nil)
          target.pbChangeStats(PBStats::SPEED, statboost, target, nil, abilitycheck: :skip)
        else
          @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
        end
        @battle.pbHideAbilityBox(target)
      when :HpAbsorbAbility, :HpAbsorbItem, :HpAbsorbField
        @battle.pbShowAbilityBox(target, item: hitflag == :HpAbsorbItem) unless hitflag == :HpAbsorbField
        hpgain = (target.totalhp / 4.0).floor
        if (Rejuv && @battle.FE == :SHORTCIRCUIT) && target.ability == :VOLTABSORB
          damageroll = @battle.field.getRoll(update_roll: true, maximize_roll: @battle.OV == :ELECTERRAIN)
          hpgain = (target.totalhp * damageroll / 4.0).floor
        end
        if target.canHeal?
          target.pbRecoverHP(hpgain, true, message: _INTL("{1} had its HP restored.", target.pbThis))
        else
          @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
        end
        @battle.pbHideAbilityBox(target)
      when :CoalFurnace
        @battle.pbShowAbilityBox(target)
        if !target.effects[:CoalFurnace]
          target.effects[:CoalFurnace] = true
          @battle.pbDisplay(_INTL("{1}'s {2} activated!", target.pbThis, getAbilityName(target.ability)))
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!", target.pbThis, getAbilityName(target.ability), basemove.name))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!", target.pbThis, getAbilityName(target.ability), basemove.name))
        end
        @battle.pbHideAbilityBox(target)
      when :FlashFireAbility, :FlashFireItem
        @battle.pbShowAbilityBox(target, item: hitflag == :FlashFireItem)
        if !target.effects[:FlashFire]
          target.effects[:FlashFire] = true
          @battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!", target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
        end
        @battle.pbHideAbilityBox(target)
      when :WellBakedBody
        @battle.pbShowAbilityBox(target)
        if target.pbCanIncreaseStatStage?(PBStats::DEFENSE, target, nil)
          target.pbChangeStats(PBStats::DEFENSE, 2, target, nil, abilitycheck: :skip)
        else
          @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
        end
        @battle.pbHideAbilityBox(target)
      when :Overcoat
        @battle.pbAbilityBoxAndDisplay(target, _INTL("It doesn't affect\n{1}...", target.pbThis(true)))
      when :SafetyGoggles
        @battle.pbDisplay(_INTL("{1} is not affected by {2} thanks to its {3}!", target.pbThis, basemove.name, getItemName(target.item)))
      when :PowderGrass
        @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
      when :WindRider
        @battle.pbShowAbilityBox(target)
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK, target, nil)
          target.pbChangeStats(PBStats::ATTACK, 1, target, nil, abilitycheck: :skip)
        else
          @battle.pbDisplay(_INTL("It doesn't affect\n{1}...", target.pbThis(true)))
        end
        @battle.pbHideAbilityBox(target)
    end
  end

  def moveCrashDamage(user, basemove)
    # might be best to move into the move function?
    if [0x10B, 0x506].include?(basemove.function) && !@battle.magicGuardAbilities.include?(user.ability) # High Jump Kick, Jump Kick, Supercell Slam, Axe Kick
      user.pbReduceHP((user.totalhp / 2.0).floor, true, message: _INTL("{1} kept going and crashed!", user.pbThis))
    end

    if user.makesContact?(basemove) && basemove.pbIsPhysical?(user, basemove.pbType(user))
      # Rocky Field Crash
      if @battle.FE == :ROCKY && user.ability != :ROCKHEAD
        @battle.pbDisplay(_INTL("{1} hit a rock instead!", user.pbThis))
        if !@battle.magicGuardAbilities.include?(user.ability)
          crashdivider = user.ability == :GORILLATACTICS ? 4.0 : 8.0
          user.pbReduceHP((user.totalhp / crashdivider).floor, true) # early message
        end
      end
      # Mirror Arena Crash
      if @battle.FE == :MIRROR
        @battle.pbDisplay(_INTL("{1} hit a mirror instead!", user.pbThis))
        @battle.pbDisplay(_INTL("The mirror shattered!"))
        if !@battle.magicGuardAbilities.include?(user.ability)
          user.pbReduceHP((user.totalhp / 4.0).floor, true) # early message
        end
        user.pbChangeStats(PBStats::EVASION, -1, user, basemove, abilitycheck: :hide) if user.stages[PBStats::EVASION] > 0
      end
    end
  end

  def bounceMove(target, bounceType, moveID)
    @battle.pbShowAbilityBox(self) if bounceType == :MagicBounce
    # target for this method should generally be the original user
    self.effects[:MagicBounced] = true
    self.pbChangeStats(PBStats::EVASION, 1, self, nil, abilitycheck: :hide) if @battle.FE == :MIRROR && bounceType == :MagicBounce
    self.pbUseMoveSimple(moveID, -1, target.index)
    self.effects[:MagicBounced] = false
    @battle.pbHideAbilityBox(self) if bounceType == :MagicBounce
  end

  def multiHitInterrupt(user, targets, basemove, hitflag)
    return true if user.isFainted? # user has been fainted, interrupt the move
    # user asleep to begin with doesn't reach here unless the move is usable asleep so only need to check it on hit 2 onwards
    return true if user.status == :SLEEP && !basemove.pbCanUseWhileAsleep? && !@simplemove
    for target in targets
      next if !target.isFainted?
      if target.isbossmon && target.shieldCount > 0
        target.pbFaint unless (target.shieldsBrokenThisTurn[user.index] > 0 || target.endTurn == true || (target.sosDetails && (target.sosDetails[:playerMons] || target.sosDetails[:playerParty])))
      end
    end
    return true if target.endTurn == true
    return true unless targets.any? { |target| !target.isFainted? } # no target is still unfainted, interrupt the move
    # Never break if previous hit succeeded
    return !hitflag.intersect?([:Success, :StatusSuccess])
  end

  def pbTryUseMove(choice, basemove, flags = { passedtrying: false, instructed: false })
    return true if flags[:passedtrying]
    # TODO: Return true if attack has been Mirror Coated once already
    return false if !pbObedienceCheck?(choice)
    return false if self.forcedSwitchEarlier
    if choice[1] == -2 # Battle Palace
      @battle.pbDisplay(_INTL("{1} appears incapable of using its power!", pbThis))
      return false
    end
    if @effects[:HyperBeam] > 0
      @battle.pbDisplay(_INTL("{1} must recharge!", pbThis))
      return false
    end
    if self.status == :SLEEP && !@simplemove
      if self.statusCount > 0 # statusCount is -1 for infinite sleep (antiwoke password)
        self.statusCount -= 1
        self.permeffs[:SleptTurns] += 1 if self.permeffs[:SleptTurns]
        self.pbCureStatus if self.statusCount <= 0
      end
      if self.statusCount != 0
        self.pbContinueStatus
        return false unless basemove.pbCanUseWhileAsleep? || self.crested == :SUICUNE # Snore/Sleep Talk
      end
    end
    if self.status == :FROZEN && !@battle.state.effects[:NeverMeltIce]
      self.statusCount += 1
      if basemove.canThawUser? && !(basemove.move == :BURNUP && !self.hasType?(:FIRE))
        self.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} melted the ice!", pbThis, basemove.name))
      elsif self.statusCount >= 3 && Gen >= Champs
        self.pbCureStatus
      elsif @battle.pbRandom(20) < (Gen >= Champs ? 5 : 4)
        self.pbCureStatus
      else
        if self.crested != :SUICUNE
          self.pbContinueStatus
          return false
        end
      end
    end
    # PP check
    # PP doesn't have to be checked for if the move is being continued from an earlier turn
    unless flags[:specialusage] || @effects[:Bide] > 0 || @effects[:Outrage] > 0 || @effects[:TwoTurnAttack] != 0 || @effects[:Rollout] > 0 || @effects[:HyperBeam] > 0 || @effects[:Uproar] > 0
      ppmove = choice[2].zmove ? self.moves[choice[1]] : basemove
      unless ppmove&.usable? || PBStuff::INTERCEPTMOVES.include?(choice[2].move)  # pp values below 0 are reserved for special circumstances and should pass the check
        @battle.pbDisplay(_INTL("{1} used\n{2}!", pbThis, basemove.name))
        @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
        @battle.ai.addMoveToMemory(self, basemove)
        return false
      end
    end

    if self.ability == :TRUANT && @effects[:Truant]
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} is loafing around!", pbThis))
      return false
    end
    if basemove.function == 0x115 && ((@lastHPLost > 0 && !@damagestate.substitute) || @battle.FE == :ELECTERRAIN) # Focus Punch
      @battle.pbDisplay(_INTL("{1} lost its focus and couldn't move!", pbThis))
      @battle.ai.addMoveToMemory(self, basemove)
      return false
    end
    if @effects[:Flinch] && !@simplemove && self.ability != :INNERFOCUS
      if @battle.FE == :ROCKY && self.stages[PBStats::DEFENSE] >= 1
        @battle.pbDisplay(_INTL("{1} won't flinch because of its bolstered Defenses!", pbThis))
      else
        @battle.pbDisplay(_INTL("{1} flinched and couldn't move!", pbThis))
        if @battle.FE == :ROCKY && ![:STEADFAST, :STURDY, :MAGICGUARD].include?(self.ability)
          damage = [1, (self.totalhp / 4.0).floor].max
          self.pbReduceHP(damage, true, message: _INTL("{1} was knocked into a rock!", pbThis))
          if self.isFainted?
            self.pbFaint
            return false
          end
        end
        if self.ability == :STEADFAST && pbCanIncreaseStatStage?(PBStats::SPEED, self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats(PBStats::SPEED, 1, self, nil, abilitycheck: :skip)
          @battle.pbHideAbilityBox(self)
        end
        if self.isbossmon && self.chargeAttack
          self.chargeAttack[:canIntermediateAttack] = false
        end
        return false
      end
    end
    if @effects[:Disable] > 0 && basemove.move == @effects[:DisableMove] && !choice[2].zmove
      @battle.pbDisplay(_INTL("{1}'s {2} is disabled!", pbThis, basemove.name))
      # Move has to have been used already so doesn't need to be added to AI memory
      return false
    end
    if self.permeffs[:LifeBlood]
      if self.permeffs[:LifeBlood][:movesSuppression].include?(basemove.move)
        @battle.pbDisplay(_INTL("{1}'s {2} is disabled!", pbThis, basemove.name))
        return false
      end
    end
    if @battle.state.effects[:Gravity] != 0 && basemove.unusableInGravity? && !(basemove.move == :MAGNETRISE && @battle.FE == :DEEPEARTH)
      @battle.pbDisplay(_INTL("{1} can't use {2} because of gravity!", pbThis, basemove.name))
      @battle.ai.addMoveToMemory(self, basemove)
      return false
    end
    if (@effects[:HealBlock] > 0 || (@status == :PETRIFIED && @battle.pbCheckSideAbility(:FAIRYAURA, self).none?)) &&
       (basemove.isHealingMove? || basemove.isDrainingMove?) && !choice[2].zmove
      @battle.pbDisplay(_INTL("{1} is prevented from healing, so it can't use {2}!", pbThis, basemove.name))
      @battle.ai.addMoveToMemory(self, basemove)
      return false
    end
    if basemove.checkSoundMove?(self) && self.effects[:ThroatChop] > 0
      @battle.pbDisplay(_INTL("{1} prevents {2} from using {3}!", getMoveName(:THROATCHOP), pbThis(true), basemove.name))
      return false
    end
    if !choice[2].zmove && (!flags[:specialusage] || flags[:danced] || flags[:instructed])
      if @effects[:ChoiceBand] && self.itemWorks? && [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(@item)
        if @moves.any? { |moveloop| moveloop.move == @effects[:ChoiceBand] }
          if basemove.move != @effects[:ChoiceBand] && !@sleeptalkUsed
            @battle.pbDisplay(_INTL("{1} used\n{2}!", pbThis, basemove.name))
            @battle.pbDisplay(_INTL("But it failed!"))
            @battle.ai.addMoveToMemory(self, basemove)
            return false
          end
        else
          @effects[:ChoiceBand] = nil
        end
      end
      if @effects[:GorillaLock] && @ability == :GORILLATACTICS
        if @moves.any? { |moveloop| moveloop.move == @effects[:GorillaLock] }
          if basemove.move != @effects[:GorillaLock] && !@sleeptalkUsed
            @battle.pbDisplay(_INTL("{1} used\n{2}!", pbThis, basemove.name))
            @battle.pbDisplay(_INTL("But it failed!"))
            @battle.ai.addMoveToMemory(self, basemove)
            return false
          end
        else
          @effects[:GorillaLock] = nil
        end
      end
    end
    if @effects[:Taunt] > 0 && basemove.pbIsStatus? && !choice[2].zmove
      @battle.pbDisplay(_INTL("{1} can't use {2} after the taunt!", pbThis, basemove.name))
      @battle.ai.addMoveToMemory(self, basemove)
      return false
    end
    if !@simplemove && !choice[2].zmove && [self.pbOpposing1, self.pbOpposing2].any? { |opp| opp.effects[:Imprison] && opp.moves.any? { |oppmove| basemove.move == oppmove&.move } }
      @battle.pbDisplay(_INTL("{1} can't use its sealed {2}!", pbThis, basemove.name))
      @battle.ai.addMoveToMemory(self, basemove)
      # PBDebug.dblog("[#{opponent.logname} has: #{opponent.moves[0]&.move}, #{opponent.moves[1]&.move}, #{opponent.moves[2]&.move}, #{opponent.moves[3]&.move}]")
      return false
    end
    if @effects[:Confusion] > 0 && !@simplemove
      if @effects[:Confusion] == 1
        pbCureConfusion
      else
        @effects[:Confusion] -= 1
        pbContinueConfusion
        if @battle.pbRandom(3) == 0
          @battle.pbDisplay(_INTL("It hurt itself in its confusion!"))
          pbConfusionDamage
          if self.isbossmon && self.chargeAttack
            self.chargeAttack[:canIntermediateAttack] = false
          end
          return false
        end
      end
    end
    if self.status == :PARALYSIS && !@simplemove && !basemove.zmove && self.crested != :SUICUNE
      if @battle.pbRandom(8) < (Gen >= Champs ? 1 : 2)
        pbContinueStatus
        pbCancelMoves
        return false
      end
    end
    if @effects[:Attract] >= 0 && !@simplemove && !basemove.zmove && self.crested != :SUICUNE
      pbAnnounceAttract(@battle.battlers[@effects[:Attract]])
      if @battle.pbRandom(2) == 0
        pbContinueAttract
        if self.isbossmon && self.chargeAttack
          self.chargeAttack[:canIntermediateAttack] = false
        end
        return false
      end
    end
    if self.isbossmon
      if self.chargeAttack
        if self.chargeAttackRequirementMet?
          chargeAttack = self.chargeAttack
          if chargeAttack[:canAttack] == false
            if chargeAttack[:intermediateattack][:name] != basemove.name
              if chargeAttack[:chargingMessage]
                @battle.pbDisplay(_INTL(chargeAttack[:chargingMessage], pbThis))
              else
                @battle.pbDisplay(_INTL("{1} is biding its time...", pbThis))
              end
              return false
            end
          end
          @battle.pbDisplay(_INTL("{1} turns remaining.", chargeAttack[:turns] - self.permeffs[:ChargeAttackCountdown]))
        end
      end
    end
    pbCheckStance(basemove) if self.ability == :STANCECHANGE
    if self.crested == :VESPIQUEN
      if basemove.pbIsStatus? && @effects[:VespiCrest] == true
        @battle.pbShowAbilityBox(self, item: true)
        @effects[:VespiCrest] = false
        self.pbChangeStats(PBStats::Offensive, -1, self, nil, abilitycheck: :hide)
        self.pbChangeStats(PBStats::Defensive, 1, self, nil, abilitycheck: :hide)
        @battle.pbDisplay(_INTL("Changed to Defense Stance!"))
      elsif basemove.pbIsDamaging? && @effects[:VespiCrest] == false
        @battle.pbShowAbilityBox(self, item: true)
        @effects[:VespiCrest] = true
        self.pbChangeStats(PBStats::Defensive, -1, self, nil, abilitycheck: :hide)
        self.pbChangeStats(PBStats::Offensive, 1, self, nil, abilitycheck: :hide)
        @battle.pbDisplay(_INTL("Changed to Attack Stance!"))
      end
      @battle.pbHideAbilityBox(self)
    end
    flags[:passedtrying] = true
    return true
  end

  def applyPressure(basemove, user, targets)
    for target in targets
      if target.ability == :PRESSURE && user.pbIsOpposing?(target.index)
        pressuredmove = (basemove.zmove && user.zmoves&.include?(basemove)) ? user.moves[user.zmoves.index(basemove)] : basemove
        user.pbReducePP(pressuredmove, true) # Reduce PP
        if [:DIMENSIONAL, :DEEPEARTH].include?(@battle.FE)
          user.pbReducePP(pressuredmove, true)
        end
      end
    end
  end

  def pbOnStartUse(user, targets, basemove, flags)
    primarytype = basemove.pbType(user)
    types = [primarytype, *basemove.getSecondaryType(user, primarytype)]
    if basemove.pbIsDamaging?
      if @battle.pbWeather(user) == :SUNNYDAY && @battle.state.effects[:HarshSunlight] && types[0] == :WATER
        @battle.pbDisplay(_INTL("The Water-type attack evaporated in the extremely harsh sunlight!"))
        return false
      end
      if @battle.pbWeather(user) == :RAINDANCE && @battle.state.effects[:HeavyRain] && types[0] == :FIRE
        @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
        return false
      end
    end
    if Rejuv && @battle.FE == :CHESS && user.ability == :KLUTZ && PBFields::CHESSMOVES.include?(basemove.move)
      @battle.pbAbilityBoxAndDisplay(user, _INTL("It was too much of a klutz to move the chess piece."))
      return false
    end
    if user.effects[:Powder] && types[0] == :FIRE
      @battle.pbCommonAnimation("Powder", user, nil)
      @battle.pbDisplay(_INTL("When the flame touched the powder on the Pokémon, it exploded!"))
      user.pbReduceHP((user.totalhp / 4.0).floor) # early message
      user.pbFaint if user.isFainted?
      return false
    end
    if basemove.explosiveMove?
      bearer = @battle.pbFindGlobalAbilityUser(:DAMP, checkMoldBroken: true)
      if bearer
        @battle.pbAbilityBoxAndDisplay(bearer, _INTL("{1} cannot use {2}!", user.pbThis, basemove.name))
        return false
      end
    end
    # !!! Queenly Majesty does in fact block priority spread moves - tested on showdown using gale wings Air Cutter against Tsareena with a partner.
    #     What it doesn't block is whole side or whole field affecting moves - Spikes and Grassy Terrain as respective examples.
    #     Bulbapedia's wording is confusing and can be easily misinterpreted as not blocking priority spread moves which is incorrect.
    targetsOpp = targets.any? { |target| user.pbIsOpposing?(target.index) }
    if targetsOpp && user.pbTarget(basemove) != :OpposingSide
      movetoblock = basemove.callermove || basemove # Queenly Majesty considers priority of the caller move only, if there is one
      if movetoblock.priorityCheck(user) > 0
        noPriority = @battle.pbCheckSideAbility(@battle.priorityBlockingAbilities, user.pbOpposing1, checkMoldBroken: true)
        if noPriority.any? && !(Rejuv && movetoblock.move == :KOWTOWCLEAVE && @battle.FE == :CHESS) # kowtow on chess pierces protection at 0.25x power
          @battle.pbAbilityBoxAndDisplay(noPriority.first, _INTL("{1} cannot use {2}!", user.pbThis, basemove.name))
          return false
        end
      end
    end
    # annoyingly Sucker Punch and Poltergeist have break-off conditions at this timing that require the move's target
    return basemove.pbOnStartUse(user, targets)
  end

  def pbConfusionDamage
    self.damagestate.reset
    confmove = PokeBattle_Confusion.new(@battle, nil)
    damage = confmove.pbCalcDamage(self, self)
    damage, bossbreaks = confmove.pbReduceHPDamage(self, [self], [damage])
    confmove.pbEffectMessages(self, self)
    confmove.pbOnDamageLost(damage[0], self, self, bossbreaks)
    self.effects[:Tantrum] = true
    pbFaint if self.isFainted?
  end

  def pbResolveMoveEffects(user, basemove, targets, calcdamage, hitflag, hitcount, flags = { totaldamage: 0, UserFaintCause: [] })
    targets.each_with_index do |target, i|
      if [:Success, :StatusSuccess].include?(hitflag[i])
        basemove.pbEffectTarget(user, target, hitcount, targets)
        if target.isbossmon
          target.immunities[:moves].push(basemove.move) if basemove.function == 0x70 # OHKO moves
        end
      end
    end
    basemove.pbEffect(user, targets, hitcount)
    if user.ability != :SHEERFORCE
      targets.each_with_index do |target, i|
        # Status Moves don't have secondary effects, so :StatusSuccess flag is getting skipped here as well
        next unless hitflag[i] == :Success && (target.ability != :SHIELDDUST || target.moldbroken) && !target.hasWorkingItem(:COVERTCLOAK)
        basemove.pbAdditionalEffect(user, target) if basemove.additionalEffectChance(user, basemove.effect, hitcount)
        basemove.pbSecondAdditionalEffect(user, target) if basemove.additionalEffectChance(user, basemove.moreeffect, hitcount)
      end
      basemove.pbAdditionalEffectSelf(user) if basemove.additionalEffectChance(user, basemove.effect, hitcount)
    end
    targets.each_with_index do |target, i|
      next unless [:Success, :StatusSuccess].include?(hitflag[i])
      if hitflag[i] != :StatusSuccess # Status moves are not dealing damage
        attackerNotPresent = flags[:AttackerOffField] == true
        futureSight = flags[:FutureSight] == true
        pbEffectsOnDealingDamage(basemove, user, target, calcdamage[i], attackerNotPresent, futureSight)
        target.addHitsTaken unless target.damagestate.substitute
      end
      flags[:UserFaintCause].push(target) if user.isFainted? && flags[:UserFaintCause].length == 0
    end
  end

  def pbOnKillEffects(targets, basemove, flags = { totaldamage: 0 })
    return if self.isFainted?
    return unless flags[:totaldamage] > 0

    checkEvolutionEx(self.pokemon) { |pokemon, method, condition, evo|
      if method == :DefeatEnemies
        for i in targets
          self.pokemon.defeatedEnemies += 1 if i.pokemon.species == condition[1] && (i.item == condition[2] || condition[2].nil?)
        end
      end
    }

    # Execution
    if self.ability == :EXECUTION && self.canHeal?
      @battle.pbShowAbilityBox(self)
      hpgain = (self.totalhp / 8.0).floor * targets.length
      self.pbRecoverHP(hpgain, true, message: _INTL("{1} healed some of its wounds!", self.pbThis))
      @battle.pbHideAbilityBox(self)
    end

    return if @battle.pbAnySideAllFainted?

    # Grim Neigh
    if [:GRIMNEIGH, :ASONEGRIM].include?(self.ability)
      if pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
        display_abil = self.ability == :ASONEGRIM ? :GRIMNEIGH : self.ability
        @battle.pbShowAbilityBox(self, attrname: getAbilityName(display_abil))
        increment = targets.length
        increment *= 2 if [:DEUXFINALIS, :HAUNTED].include?(@battle.FE)
        self.pbChangeStats(PBStats::SPATK, increment, self, nil, abilitycheck: :skip)
        @battle.pbHideAbilityBox(self)
      end
    end
    # Moxie, Chilling Neigh
    if [:MOXIE, :CHILLINGNEIGH, :ASONECHILLING].include?(self.ability)
      if pbCanIncreaseStatStage?(PBStats::ATTACK, self, nil)
        display_abil = self.ability == :ASONECHILLING ? :CHILLINGNEIGH : self.ability
        @battle.pbShowAbilityBox(self, attrname: getAbilityName(display_abil))
        increment = targets.length
        increment *= 2 if [:DEUXFINALIS, :FROZENDIMENSION].include?(@battle.FE) && [:CHILLINGNEIGH, :ASONECHILLING].include?(self.ability)
        self.pbChangeStats(PBStats::ATTACK, increment, self, nil, abilitycheck: :skip)
        @battle.pbHideAbilityBox(self)
      end
    end
    # Beast Boost
    if [:BEASTBOOST, :EELEVATE].include?(self.ability)
      stat = self.getHighestRawStat
      statmod = @battle.FE == :DIMENSIONAL && self.ability == :BEASTBOOST ? 2 : 1
      if pbCanIncreaseStatStage?(stat, self, nil)
        @battle.pbShowAbilityBox(self)
        increment = targets.length * statmod
        self.pbChangeStats(stat, increment, self, nil, abilitycheck: :skip)
        @battle.pbHideAbilityBox(self)
      end
    end
    # Colosseum
    if @battle.FE == :COLOSSEUM
      statindices = [0, 0, 0, 0, 0]
      targets.each { |target|
        statindex = target.getHighestRawStat - 1
        statindices[statindex] += 1
      }
      stats, amounts = [], []
      statindices.each_with_index { |increment, i|
        next if increment == 0
        stats.push(i + 1)
        amounts.push(increment)
      }
      self.pbChangeStats(stats, amounts, self, nil, abilitycheck: :hide, statmessage: :ColosseumKill)
    end
    # Back Alley + Pursuit
    if @battle.FE == :BACKALLEY && basemove.move == :PURSUIT
      self.pbChangeStats(PBStats::SPEED, 1, self, basemove, abilitycheck: :hide, statmessage: :BackalleyPursuit)
    end
    # Battle Bond
    if [:BATTLEBOND, :PRISMPOWER].include?(self.ability) && !self.permeffs[:BattleBond]
      if self.pbCanIncreaseAnyStat?([PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED], self, nil)
        @battle.pbShowAbilityBox(self)
        stats = [PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED]
        # stats.append(PBStats::DEFENSE, PBStats::SPDEF) if self.ability == :PRISMPOWER
        self.pbChangeStats(stats, 1, self, nil, abilitycheck: :hide)
        case self.ability
          when :BATTLEBOND
            battlebondstring = self.isWildPokemon? ?
              _INTL("{1} became fully charged due to its bond!", self.pbThis) :
              _INTL("{1} became fully charged due to its bond with its Trainer!", self.pbThis)
            @battle.pbDisplay(battlebondstring)
          when :PRISMPOWER
            @battle.pbDisplay(_INTL("{1} became shrouded in a mysterious light due to its Prism Power!", self.pbThis))
            self.pokemon.prismPower = true
            @battle.scene.pbChangePokemon(self, @pokemon)
        end
        @battle.pbHideAbilityBox(self)
        self.permeffs[:BattleBond] = true
      end
    end
  end

  def pbTargetEffectsDamaged(user, basemove, predamageHP, futureSight = false)
    # Sheer Force attacks proc Berserk as of Champions
    return if user.ability == :SHEERFORCE && basemove.effect > 0 && Gen < Champs

    if predamageHP > (self.totalhp / 2.0).floor && self.hp <= (self.totalhp / 2.0).floor
      # Berserk
      if self.ability == :BERSERK && pbCanIncreaseStatStage?(PBStats::SPATK, self, nil)
        @battle.pbShowAbilityBox(self)
        statgain = Rejuv && @battle.FE == :DRAGONSDEN ? 2 : 1
        self.pbChangeStats(PBStats::SPATK, statgain, self, nil, abilitycheck: :skip)
        @battle.pbHideAbilityBox(self)
      end
      # Anger Shell
      if self.ability == :ANGERSHELL
        upstats = [PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED]
        downstats = PBStats::Defensive
        if self.pbCanIncreaseAnyStat?(upstats, self, nil) || self.pbCanReduceAnyStat?(downstats, self, nil)
          @battle.pbShowAbilityBox(self)
          self.pbChangeStats(upstats + downstats, [1, 1, 1, -1, -1], self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    movetype = basemove.pbType(user)
    # Color Change
    if self.ability == :COLORCHANGE && self.canChangeType? && ![:SHADOW, :QMARKS, :STELLAR].include?(movetype) && !self.hasType?(movetype) && basemove.move != :STRUGGLE
      self.changeType(movetype)
      @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s type changed to {2}!", self.pbThis, getTypeName(movetype)))
    end
    # Kee and Maranga Berry
    unless @battle.pbCheckSideAbility(PBStuff::UnnerveAbilities, self.pbOpposing1).any?
      self.pbEatBerry if self.hasWorkingItem(:KEEBERRY) && basemove.pbIsPhysical?(user, movetype) && self.pbCanIncreaseStatStage?(PBStats::DEFENSE, self, nil)
      self.pbEatBerry if self.hasWorkingItem(:MARANGABERRY) && basemove.pbIsSpecial?(user, movetype) && self.pbCanIncreaseStatStage?(PBStats::SPDEF, self, nil)
    end
    # Red Card
    if self.hasWorkingItem(:REDCARD) && !futureSight && !user.isFainted? && !user.forcedSwitch
      choices = @battle.pbPartySingleOwner(user.index).select.with_index { |pkmn, i| @battle.pbCanSwitchLax?(user.index, i) }
      if choices.length != 0
        @battle.pbShowAbilityBox(self, item: true)
        @battle.pbCommonAnimation("UseItem", self, nil)
        @battle.pbDisplay(_INTL("{1} held up its {2} against {3}!", self.pbThis, getItemName(self.item), user.pbThis(true)))
        @battle.pbHideAbilityBox(self)
        self.pbDisposeItem
        if self.isWildPokemon? && !@battle.battlers.any? { |battler| battler.isbossmon } && !@battle.doublebattle
          # If a red card is held by a wild pokemon in a single wild battle and the trainer has pokemon to switch to, it will cause the trainer to flee instead of switching
          @battle.decision = 3 # Set decision to escaped
        else
          if self.canForceSwitchOpponent?(user, showMessage: true)
            user.forcedSwitch = true
          end
        end
      end
    end
    # Eject Button
    if self.hasWorkingItem(:EJECTBUTTON) && !futureSight && self.canTriggerUserSwitch?
      # eject button does not activate if the holder is a wild pokemon
      # no specific check for this should be required as the wild pokemon will not have another pokemon to switch to and will fail the switch check
      self.userSwitch = :EjectButton
    end
  end

  def pbUseMoveSimple(move, index, target, danced: false, specialZ: false, callermove: nil)
    if move.is_a?(PokeBattle_Move)
      moveobject = move
    else
      moveobject = PokeBattle_Move.pbFromPBMove(@battle, PBMove.new(move), self.pokemon)
    end
    # For turning called moves into Z-Moves when the caller move is a Z-Move
    side = @battle.pbIsOpposing?(self.index) ? 1 : 0
    owner = @battle.pbGetOwnerIndex(self.index)
    if @battle.zMove[side][owner] == self.index && moveobject.basedamage > 0 && !danced
      crystal = pbZCrystalFromType(moveobject.type)
      zmoveID = $cache.items[crystal].zmove
      moveobject = PokeBattle_Move.pbFromPBMove(@battle, PBMove.new(zmoveID), self.pokemon, moveobject)
    end
    moveobject.callermove = callermove if callermove
    choice = [:move, index, moveobject, target]
    @battle.choices[@index][1] = index if index >= 0
    @usingsubmove = true
    @simplemove = danced == false
    pbUseMove(choice, { specialusage: true, danced: danced, specialZ: specialZ })
    @usingsubmove = false
    @simplemove = false
  end

  def pbDancerMoveCheck(id)
    if self.ability == :DANCER && @battle.FE == :BIGTOP # Big Top
      if $cache.moves[id]&.checkFlag?(:dancemove)
        if pbCanIncreaseAnyStat?([PBStats::SPATK, PBStats::SPEED], self, nil)
          @battle.pbShowAbilityBox(self)
          pbChangeStats([PBStats::SPATK, PBStats::SPEED], 1, self, nil, abilitycheck: :hide)
          @battle.pbHideAbilityBox(self)
        end
      end
    end
    priority = @battle.setSpeedOrder
    for i in priority
      next if i == self

      if i.ability == :DANCER && $cache.moves[id]&.checkFlag?(:dancemove)
        @battle.pbAbilityBoxAndDisplay(i, _INTL("{1} joined in with the dance!", i.pbThis))
        i.pbUseMoveSimple(id, -1, -1, danced: true)
      end
    end
  end

  # norandomness used by AI, makes only the lowest rolls get considered in case of random rolls
  def pbGetHitNumber(basemove, norandomness: false)
    targetchoices = pbTarget(basemove)
    self.effects[:ParentalBond] = false
    self.effects[:TyphBond] = false
    self.effects[:CincCrest] = false
    numhits = 0
    if norandomness
      if [0x0C0, 0x307].include?(basemove.function) # Bullet Seed, Scale Shot
        if self.ability == :SKILLLINK || (self.crested == :FEAROW && basemove.move == :FURYATTACK)
          numhits = 5
        else
          numhits = self.hasWorkingItem(:LOADEDDICE) ? 4 : 2
        end
      elsif basemove.function == 0x50A # Population Bomb
        numhits = self.hasWorkingItem(:LOADEDDICE) ? 4 : 10
      end
    end
    numhits = basemove.pbNumHits(self) if numhits == 0
    return numhits if basemove.pbIsStatus? # Parental bond and similar effects do only apply to damaging moves
    return numhits if basemove.zmove # z-moves do NOT get modified
    return numhits if [0x70, 0x0E1, 0x0E0, 0x0D3, 0x0D1, 0x0F7, 0x06E, 0x0C1].include?(basemove.function) # OHKO moves, final gambit, Explosion moves, Rollout/Ice Ball, Uproar, Fling, Endeavor, Beat Up
    return numhits if PBStuff::TWOTURNMOVE.include?(basemove.move) # moves with charge up turn do not get affected in any circumstances, even with power herb
    numhits *= 4 if self.crested == :LEDIAN && basemove.punchMove? # revisit this in case there is a multitarget punchmove
    return numhits if numhits > 1 # after this point moves that are already multihit will not get modified we may return now
    return numhits unless self.ability == :PARENTALBOND || [:CINCCINO, :TYPHLOSION].include?(self.crested)
    # spread move checking (AllyBattlers moves are never damaging so not checking those)
    if [:AllOpposing, :AllNonUsers, :AllBattlers].include?(targetchoices)
      counter = 0
      for k in @battle.battlers
        next if [:AllOpposing, :AllNonUsers].include?(targetchoices) && k == self
        next if targetchoices == :AllOpposing && !self.pbIsOpposing?(k.index)
        next if k.isFainted?
        counter += 1
      end
      # don't modify hitcount if an attack hits multiple targets
      return numhits unless counter == 1
    end
    if self.crested == :CINCCINO
      self.effects[:CincCrest] = true
      if self.ability == :SKILLLINK
        numhits = 5
      elsif norandomness
        numhits = 2
      else
        hitchances = [2, 2, 3, 3, 4, 5]
        numhits = @battle.sample(hitchances)
      end
    elsif self.makesContact?(basemove) && self.crested == :TYPHLOSION
      self.effects[:TyphBond] = true
      numhits = 2
    elsif self.ability == :PARENTALBOND
      self.effects[:ParentalBond] = true
      numhits = 2
    end
    return numhits
  end

  def moveDamageStateInit(target, basemove)
    # Reset damage state, set Focus Band/Focus Sash to available
    target.damagestate.reset
    if target.hasWorkingItem(:FOCUSBAND) && @battle.pbRandom(10) == 0
      target.damagestate.focusband = true
    end
    if target.hasWorkingItem(:FOCUSSASH)
      target.damagestate.focussash = true
    end
    if target.crested == :RAMPARDOS && !target.permeffs[:RampCrest]
      target.damagestate.rampcrest = true
    end
  end

  def logMoveUse(choice, basemove, user, flags)
    return unless $cache.moves[basemove.move]
    user.lastMoveUsed = basemove.move
    @lastMoveChoice = choice.clone
    if !flags[:specialusage]
      user.lastRegularMoveUsed = basemove.move
      user.lastRoundMoved = @battle.turncount
      if !basemove.zmove
        if basemove.user == user.pokemon
          if user.effects[:ChoiceBand] == nil && user.itemWorks? && [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(user.item)
            user.effects[:ChoiceBand] = basemove.move
          end
          if user.effects[:GorillaLock] == nil && user.ability == :GORILLATACTICS
            user.effects[:GorillaLock] = basemove.move
          end
        end
      else
        @battle.pbRegisterUsedZMove(user.index)
      end
    else
      self.lastRegularMoveUsed = -1 if basemove.move == :STRUGGLE
    end
    @battle.lastMoveUsed = basemove.move
    @battle.lastMoveUser = user.index
    if basemove.zmove
      user.lastMoveUsed = -1
      user.lastRegularMoveUsed = -1
      @battle.lastMoveUsed = -1
    end
  end

  def applyPostMoveEffects(basemove, user, targets, hitflag)
    basemove.pbEffectAfterMove(user, targets, hitflag)
    if !@battle.opponent&.is_a?(Array)
      if @battle.opponent&.trainertype == :LEADER_ALLEN2 && !@battle.pbOwnedByPlayer?(user.index)
        if user.pbPartner.hp > 0 && !user.pbPartner.acted?
          @battle.pbAnimation(:AFTERYOU, user, user.pbPartner)
          user.pbPartner.effects[:AfterYou] = true
          @battle.pbDisplay(_INTL("{1} follows {2}'s lead!", user.pbPartner.pbThis, user.pbThis(true)))
          @battle.setActPrioData
        end
      end
    end
    targets.each_with_index do |target, i|
      next unless [:Success, :StatusSuccess].include?(hitflag[i])
      basemove.pbEffectTargetAfterMove(user, target, targets)
      # damaging fire type moves and certain non fire type moves with a burn chance can thaw a frozen target
      if target.status == :FROZEN && (basemove.pbType(user) == :FIRE || [0x0A, 0x51E].include?(basemove.function)) && hitflag[i] == :Success
        target.pbCureStatus
      end
    end
  end

  def pbUseMove(choice, flags = { danced: false, totaldamage: 0, specialusage: false, specialZ: false })
    if @battle.recorded == true
      $game_variables[:BattleDataArray].last().pokemonTrackMove(choice, self, @battle.battlers)
    end
    danced = flags[:danced]
    # TODO: lastMoveUsed is not to be updated on nested calls
    flags[:totaldamage] = 0 if !flags[:totaldamage]
    # hasMovedThisRound by itself isn't enough for, say, Fake Out + Instruct.
    @isFirstMoveOfRound = !self.hasMovedThisRound?
    # Start using the move
    pbBeginTurn(choice)
    # Force the use of certain moves if they're already being used
    unless flags[:specialusage]
      if @effects[:TwoTurnAttack] != 0 || @effects[:HyperBeam] > 0 || @effects[:Outrage] > 0 || @effects[:Rollout] > 0 || @effects[:Uproar] > 0 || @effects[:Bide] > 0
        PBDebug.dblog("[Continuing move]")
        choice[2] = PokeBattle_Move.pbFromPBMove(@battle, PBMove.new(@currentMove), self.pokemon) if @currentMove != 0
        flags[:specialusage] = true
      elsif @effects[:Encore] > 0 && !choice[2].zmove && choice[2] != @battle.struggle
        if @battle.pbCanShowCommands?(@index)
          PBDebug.dblog("[Using Encore move]")
          if choice[1] != @effects[:EncoreIndex] # Was Encored mid-round
            choice[1] = @effects[:EncoreIndex]
            choice[2] = @moves[@effects[:EncoreIndex]]
            choice[3] = -1 # No target chosen
          end
        end
      end
    end
    basemove = choice[2]
    return if !basemove

    return false if self.effects[:SkyDrop] || self.effects[:Commander]

    if !pbTryUseMove(choice, basemove, flags)
      if self.vanished
        @battle.scene.pbUnVanishSprite(self)
        self.releaseSkyDroppee
      end
      # Commented out because the cases we tested (Encore / Disable / Sketch / Mimic / Spite / Instruct)
      # all work after a sleep turn using the last used move.
      # self.lastMoveUsed = -1
      if !flags[:specialusage]
        # self.lastRegularMoveUsed = -1
        self.lastRoundMoved = @battle.turncount
      end
      self.effects[:Tantrum] = self.effects[:HyperBeam] <= 0 # recharge turns do not trigger tantrum; everything else does
      if self.effects[:Uproar] > 0
        self.effects[:Uproar] = 0
        @battle.pbDisplay(_INTL("{1} calmed down.", pbThis))
      end
      if !flags[:specialusage] || basemove.move == :STRUGGLE
        self.effects[:ProtectRate] = 0
      end
      pbCancelMoves
      @battle.pbGainEXP
      pbEndTurn(choice)
      @battle.pbJudgeSwitch
      return
    end

    # Set Mold Breaker
    moldbroken = [:MOLDBREAKER, :TERAVOLT, :TURBOBLAZE].include?(self.ability) || [0x166, 0x176, 0x200].include?(basemove.function) # Solgaluna/crozma signatures
    moldbroken = true if self.ability == :MYCELIUMMIGHT && basemove.pbIsStatus?
    for i in 0..3
      @battle.battlers[i].moldbroken = moldbroken && !@battle.battlers[i].hasWorkingItem(:ABILITYSHIELD)
    end
    # reduce PP and log the used move to AI memory, showing the Move Use Message guarantee's PP deduction
    # that PP isn't 0 has already been confirmed in pbTryUseMove
    if !flags[:specialusage]
      @battle.ai.addMoveToMemory(self, basemove)
      self.movesUsed.push(basemove.move) # For Last Resort (and Battle Data)
      ppmove = choice[2].zmove ? self.moves[choice[1]] : basemove
      pbReducePP(ppmove) if !PBStuff::INTERCEPTMOVES.include?(choice[2].move)
    end
    # Remember that user chose a two-turn move
    # it is very important that this is done AFTER pp deduction otherwise PP usage with two turn moves breaks
    if basemove.pbTwoTurnAttack(self)
      # Beginning use of two-turn attack
      @effects[:TwoTurnAttack] = basemove.move
      @currentMove = basemove.move
    else
      @effects[:TwoTurnAttack] = 0 # Cancel use of two-turn attack
      @effects[:SkyDroppee] = nil if basemove.move != :SKYDROP
    end
    @battle.pbUseZMove(self.index, choice, self.item, flags[:specialZ]) if choice[2].zmove && (!flags[:specialusage] || flags[:specialZ])
    if self.effects[:clearDisguise]
      puts(choice)
      if choice[2].zmove
        puts(choice[1])
        puts(self.effects[:clearDisguise].zmoves)
        fakeMove = self.effects[:clearDisguise].zmoves[choice[1]] if !fakeMove
      else
        fakeMove = self.effects[:clearDisguise].moves[choice[1]] if !fakeMove
      end
      self.effects[:clearDisguise].fakeMove = fakeMove
    end
    user = self
    # Status Z-move effects
    pbZStatus(@battle, basemove.move, user) if basemove.zmove && basemove.category == :status && PBStuff::TYPETOZCRYSTAL[basemove.type] == user.item
    # "X used Y!" message
    @battle.scene.moveUseDisplayPhase = true
    basemove.pbDisplayUseMessage(self, choice)
    @battle.scene.moveUseDisplayPhase = false
    # Find the user and target(s)
    targets = []
    pbFindTargets(choice, targets)
    # Important!: the first field roll for Crystal Cavern is made here (move.getSecondaryType)
    # which fixes the rolled type for the rest of the move, make sure it stays that way
    # or if the type needs to be called earlier, make sure the roll is fixed then
    primarytype = basemove.pbType(user)
    moveTypes = [primarytype, *basemove.getSecondaryType(user, primarytype)]
    targets = pbChangeTarget(basemove, user, targets)
    applyPressure(basemove, user, targets)
    user = pbChangeUser(basemove, user, targets) # targets will get overwriten if snatch happens but due to pointers it doesn't have to be a return value
    originalUser = user
    # Special Moves (Rejuv)
    if basemove.specialmove
      for mon in @battle.specialParty[user.index]
        user = mon if mon.species == PBStuff::SPECIALMOVETOPOKEMON[basemove.move][0]
      end
      originalUser.pbOwnSide.effects[:SpecialMoves][basemove.move] = -1
    end

    if !basemove.isMoveValidOnField?(user, showMessage: true)
      logMoveUse(choice, basemove, user, flags)
      if self.vanished
        @battle.scene.pbUnVanishSprite(self)
        self.releaseSkyDroppee
      end
      user.effects[:Tantrum] = true
      user.effects[:Metronome] = 0
      user.effects[:FuryCutter] = 0
      pbCancelMoves
      @battle.field.fieldroll = nil
      @battle.field.overlayroll = nil
      pbEndTurn(choice)
      @battle.pbJudgeSwitch
      return
    end
    case basemove.pbShortUseMove(user, targets.first) # moves executed like this only have one target, so only one target is handled
      when :CallerMove
        # Move that calls other moves
        # move logging has to be done MANUALLY and not via logMoveUse since for the purposes of metronome the called move is the last move that was used and can be chained
        # the caller move does not appear at all for this consideration, so lastMoveUsed has to be skipped here entirely
        opponent = targets.first
        if user.effects[:clearDisguise]&.fakeMove
          basemove.pbShowAnimation(user.effects[:clearDisguise].fakeMove.move, user, opponent, 0, [opponent], true)
        else
          basemove.pbShowAnimation(basemove.move, user, opponent, 0, [opponent], true)
        end
        basemove.pbEffectTarget(user, opponent, 0, [opponent])
        basemove.pbEffect(user, [opponent])
        @lastMoveChoice = choice.clone
        if !flags[:specialusage]
          user.lastRegularMoveUsed = basemove.move # the caller move was the last "regular move" (read as: actual move in the moveset of the user) used
          user.lastRoundMoved = @battle.turncount
          if !basemove.zmove
            # caller move will be choice locked if applicable not the called move
            if user.effects[:ChoiceBand] == nil && user.itemWorks? && [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(user.item)
              user.effects[:ChoiceBand] = basemove.move
            end
            if user.effects[:GorillaLock] == nil && user.ability == :GORILLATACTICS
              user.effects[:GorillaLock] = basemove.move
            end
          else
            @battle.pbRegisterUsedZMove(user.index)
          end
        end
        @battle.lastMoveUser = user.index
        # only exception to the above statement sketch/Copycat and other copying moves WILL fail if the last move used was a z-move and as such
        # Z-caller moves should reset lastMoveUsed and similar attributes to base
        if basemove.zmove
          user.lastMoveUsed = -1
          user.lastRegularMoveUsed = -1
          @battle.lastMoveUsed = -1
        end
        @battle.field.fieldroll = nil
        @battle.field.overlayroll = nil
        pbEndTurn(choice)
        @battle.pbJudgeSwitch
        return
      when :FutureSight, :Bide
        logMoveUse(choice, basemove, user, flags)
        @battle.field.fieldroll = nil
        @battle.field.overlayroll = nil
        # technically incorrect, but functionally identical, if you are building a metronome chain on bide i really don't think i can help you
        self.effects[:Metronome] = 0
        self.effects[:FuryCutter] = 0
        pbEndTurn(choice)
        @battle.pbJudgeSwitch
        return
      when :FailedMove
        # early executing move failing
        logMoveUse(choice, basemove, user, flags)
        @battle.field.fieldroll = nil
        @battle.field.overlayroll = nil
        user.effects[:Tantrum] = true
        user.effects[:Metronome] = 0
        user.effects[:FuryCutter] = 0
        pbCancelMoves
        pbEndTurn(choice)
        @battle.pbJudgeSwitch
        return
    end
    if basemove.function == 0x92
      @battle.echoedThisRound = true
    end
    if basemove.function != 0x91 # Fury Cutter
      self.effects[:FuryCutter] = 0
    end
    if basemove.move != self.lastMoveUsed
      self.effects[:Metronome] = 0
    end
    # Check Category 1 Move Failure Conditions, which are Move failures that happen before Protean, and before locking in self damage due to Explosion/ Mind Blown
    if !pbOnStartUse(user, targets, basemove, flags)
      logMoveUse(choice, basemove, user, flags)
      if self.vanished
        @battle.scene.pbUnVanishSprite(self)
        self.releaseSkyDroppee
      end
      user.effects[:Tantrum] = basemove.move != :REST # all failure conditions except ones relating to rest in this section cause tantrum to deal double damage
      user.effects[:Metronome] = 0
      user.effects[:FuryCutter] = 0
      pbCancelMoves
      @battle.field.fieldroll = nil
      @battle.field.overlayroll = nil
      pbEndTurn(choice)
      @battle.pbJudgeSwitch
      return
    end
    if [:PROTEAN, :LIBERO].include?(user.ability) && (Gen < 9 || !@effects[:ProteanUsed]) && user.canChangeType? && basemove.move != :STRUGGLE
      if !user.hasType?(moveTypes[0]) || (!user.type2.nil? && user.type1 != user.type2)
        user.changeType(moveTypes[0])
        @battle.pbAbilityBoxAndDisplay(user, _INTL("{1} transformed into the {2} type!", user.pbThis, getTypeName(moveTypes[0])))
        @effects[:ProteanUsed] = true if !Rejuv
      end
    end
    # Teatime message plays after Protean and regardless of whether the move succeeds
    if basemove.move == :TEATIME
      @battle.pbDisplay(_INTL("It's teatime! Everyone dug into their Berries!"))
    end
    targetchoices = pbTarget(basemove)
    hitflag = []
    # tracker to attribute which target was the reason if user fainted as a result of its own move
    # User faints as a result of selfinflicted KO moves (e.g. Explosion) or due to move crash or recoil damage are attributed to all targets of the move
    flags[:UserFaintCause] = []
    realnumhits = 0
    # If a move doesn't have a listed target at this point it fails
    if targets.length == 0
      @battle.pbDisplay(_INTL("But there was no target..."))
      @effects[:Rollout] = 0 if @effects[:Rollout] > 0
      if PBStuff::SEMIINVULMOVE.include?(basemove.move) # Sprites for two turn moves
        @battle.scene.pbUnVanishSprite(user)
      end
    else
      @battle.moveReact(targets, choice[2], user, midturn: true)
      reflectedList = []
      targets.each do |target|
        if target.effects[:ReflectMove]
          targets = [user]
          reflectedList = [target, user]
        end
      end
      # We have targets
      targets.each do |target|
        moveDamageStateInit(target, basemove)
      end
      hitflag = user.pbSuccessCheck(basemove, targets, flags)
      preMoveHP = []
      targets.each do |target|
        preMoveHP.push(target.hp)
      end
      numhits = user.pbGetHitNumber(basemove)
      killtracker = []
      calcdamage = []
      revanishtracker = []
      if targetchoices == :DragonDarts
        dartTargets = targets.clone
        targets = [dartTargets.first]
      end
      for hitcount in 0...numhits
        feedbackMessages = {}
        replayMessages = false
        if hitcount > 0
          if targetchoices == :DragonDarts && dartTargets.length > 1
            # there is no need to adjust the hitflags with the targets,
            # the only situation where there are 2 valid targets listed is if the move connects with both targets
            # and as such both hitflags would be success
            targets = [dartTargets.last]
          else
            # replay damage calc feedbackMessage if a boss shield broke mid attack, boss stats and/or field may have changed altering feedback

            replayMessages = targets.any? { |target| target.isbossmon && target.isFainted? && target.shieldCount > 0}
            if multiHitInterrupt(user, targets, basemove, hitflag)
              @battle.scene.pbUnVanishSprite(user) if basemove.move == :THUNDERRAID
              break
            end
            hitflagBackup = hitflag.clone if [:Success, :StatusSuccess].intersect?(hitflag)
            targets.each do |target|
              moveDamageStateInit(target, basemove)
            end
            hitflag = user.pbSuccessCheck(basemove, targets, flags, basemove.checkAccuracyEachHit(user))
            # if the move gets to this point atleast one hit has connected or at the very least not missed due to accuracy, no blunder policy
            user.missAcc = false unless targetchoices == :DragonDarts # exception here is Dragon Darts, if it is in this branch it's likely that it missed a second target, missAcc should not be set to false
          end
        end
        targets.each_with_index do |target, i|
          feedbackMessages[target.index] = []
          next calcdamage[i] = 0 if target.isFainted?
          unless [:Success, :StatusSuccess].include?(hitflag[i])
            moveFailureEffects(user, basemove, target, hitflag[i])
            calcdamage[i] = 0
            next unless hitflag[i] == :MirrorMissReflect
            hitflag[i] = :Success # we have handled the mirror reflect we can treat it as a success now
          end
        end
        targets.each_with_index do |target, i|
          if !@battle.isOnline? && target.effects[:Illusion] && hitflag[i] != :AccuracyMiss &&
             hitflag[i] != user.pbSuccessCheck(basemove, [target.effects[:Illusion]], flags, false).first
            @battle.ai.discloseIllusion(target, :immunity)
          end
          next unless [:Success, :StatusSuccess].include?(hitflag[i])
          calcdamage[i] = basemove.pbCalcDamage(user, target, hitcount, feedbackMessages)
          revanish = false
          if target.vanished && (basemove.function != 0xCE || target.effects[:TwoTurnAttack] != 0)
            revanish = true
            revanish = false if basemove.function == 0xCE # Sky Drop
            revanish = false if basemove.function == 0x11C && [:FLY, :BOUNCE].include?(target.effects[:TwoTurnAttack]) # Smack down
            revanishtracker[i] = revanish
            @battle.scene.pbUnVanishSprite(target)
          end
        end
        if [:Success, :StatusSuccess].intersect?(hitflag)
          # the attack connects with atleast one target
          realnumhits += 1 # this hit really happens, count it
          basemove.damageCalcMessages(user, feedbackMessages) if realnumhits == 1 || replayMessages
          replayMessages = false
          # show move animation
          # if we turn over the user as the target instead of no target the animation for hazard moves breaks
          # as such if the only target of the move is the user themself we turn over no target to the animation call
          animTarget = nil
          # and now we find the first best target that actually got hit, because passing a missed target as the animation target causes sprite visibility issues
          if targets != [user]
            listindex = hitflag.index { |flag| [:Success, :StatusSuccess].include?(flag) }
            animTarget = targets[listindex]
          end
          if user.effects[:clearDisguise]&.fakeMove
            basemove.pbShowAnimation(user.effects[:clearDisguise]&.fakeMove.move, user, animTarget, hitcount, targets, true)
          elsif reflectedList != []
            basemove.pbShowAnimation(basemove.move, reflectedList[0], reflectedList[1], hitcount, targets, true)
          else
            basemove.pbShowAnimation(basemove.move, user, animTarget, hitcount, targets, true)
          end
          # Gulp Missile
          if user.species == :CRAMORANT && user.ability == :GULPMISSILE && user.form == 0 && !user.isFainted? && [:SURF, :DIVE].include?(basemove.move)
            user.gulpMissileTransform
          end
          # deal damage, skip if no damage is dealt to any target
          if !hitflag.include?(:StatusSuccess) # we may skip damage dealing and associated effects and messages if successful move was a non-damage dealing move
            calcdamage, bossbreaks = basemove.pbReduceHPDamage(user, targets, calcdamage) if calcdamage.max > 0
            targets.each_with_index do |target, i|
              if hitflag[i] == :Success # successful damaging move
                flags[:totaldamage] += calcdamage[i]
                basemove.pbOnDamageLost(calcdamage[i], user, target, bossbreaks)
                basemove.pbEffectMessages(user, target, targets.length > 1)
              end
            end
          end
          # Delayed type berry consumption
          targets.each do |target|
            if target.effects[:TypeBerryActivated]
              @battle.pbDisplay(_INTL("{1} weakened the damage to {2}!", getItemName(target.item, :The), target.pbThis(true)))
              target.pbDisposeItem(symbiosis: :delay, duringattack: true)
              target.effects[:TypeBerryActivated] = false
            end
          end
          user = originalUser # revert back from specialmove change
          basemove.damageCalcMessages(user, feedbackMessages, late: true) if realnumhits == 1 || replayMessages
          pbResolveMoveEffects(user, basemove, targets, calcdamage, hitflag, hitcount, flags)
          user.effects[:Tantrum] = false # no matter what happens if a move gets here even if the effect of a status move fails at this point, tantrum is not active
          user.pbHyperMode if basemove.type == :SHADOW && basemove.move != :CHTHONICMALADY
        elsif realnumhits == 0 # total failure conditions don't apply if a previous hit in a multihit connected
          # the attack didn't connect with any of its targets
          # handle overall failure
          if user.vanished
            @battle.scene.pbUnVanishSprite(user)
            user.releaseSkyDroppee
          end
          nonTantrumFails = [:WideGuard, :QuickGuard, :CraftyShield, :MatBlock, :Protect, :KingsShield, :SpikyShield, :BanefulBunker, :Obstruct, :SilkTrap, :BurningBulwark, :MoveFailCat3]
          user.effects[:Tantrum] = !nonTantrumFails.intersect?(hitflag)
          user.effects[:Outrage] = 0 if basemove.function == 0xD2 # Outrage
          user.effects[:TwoTurnAttack] = 0 if basemove.function == 0x0CE # Sky Drop
          user.effects[:Rollout] = 0 if basemove.function == 0xD3 # Rollout
          user.effects[:FuryCutter] = 0 if basemove.function == 0x91 # Fury Cutter
          user.effects[:BeakBlast] = false if basemove.function == 0x15D # Beak Blast
          if user.effects[:Uproar] > 0 && basemove.function == 0x0D1 # Uproar
            user.effects[:Uproar] = 0
            @battle.pbDisplay(_INTL("{1} calmed down.", user.pbThis))
          end
          moveCrashDamage(user, basemove)
          if user.isFainted? && flags[:UserFaintCause].length == 0
            flags[:UserFaintCause] = flags[:UserFaintCause] + targets
          end
        end
        if numhits > 1
          for j in 0...4
            @battle.battlers[j].pbBerryHerbCheck
          end
        end
      end # end hitnumber loop
      if realnumhits > 0 && ![:Success, :StatusSuccess].intersect?(hitflag)
        # accounting for instances in which a multihit move fails on a later hit but connected at least once, this grabs the last successful set of hitflags
        hitflag = hitflagBackup if hitflagBackup
      end
      if targetchoices == :DragonDarts
        targets = dartTargets
      end
      if numhits > 1
        for target in targets
          target.pbEffectivenessMessage(targets.length > 1)
        end
        if realnumhits == 1 # exclude 0
          @battle.pbDisplay(_INTL("Hit {1} time!", realnumhits))
        elsif realnumhits > 1
          @battle.pbDisplay(_INTL("Hit {1} times!", realnumhits))
        end
      end
      @battle.moveReact(targets,choice[2], user, midturn: false)
      # Applying Last Word Effects
      targets.each_with_index do |target, i|
        target.checkLastWord(preMoveHP[i], moveStorage: choice[2])
      end
      # revanishing targets that were hit during semi-invulnerable turns
      targets.each_with_index do |target, i|
        next unless revanishtracker[i]
        next if target.isFainted?
        @battle.pbCommonAnimation("Fade out", target, nil)
        @battle.scene.pbVanishSprite(target)
      end
    end
    unless user.isFainted?
      recoil = basemove.getRecoil(user, flags[:totaldamage], basemove.recoil, hitflag)
      if recoil > 0
        recoil = basemove.inflictRecoil(user, recoil, hitflag)
        if basemove.recoil > 0 # Same condition as Reckless (does not count recoil from Struggle / Mind Blown / Chloroblast / Explosion)
          recoilevo = checkEvolutionEx(user.pokemon) { |pokemon, method, condition, evo|
            next true if method == :TakeRecoil
          }
          user.pokemon.recoilTaken += recoil if recoilevo
        end
      end
      flags[:UserFaintCause] = flags[:UserFaintCause] + targets
    end
    # In Champions, effects like Knock Off happen even if the user faints while using the move.
    applyPostMoveEffects(basemove, user, targets, hitflag) if Gen >= Champs
    if user.isFainted?
      user.pbFaint
      if @battle.recorded || @battle.FE == :CROWD
        for target in flags[:UserFaintCause]
          $game_variables[:BattleDataArray].last().pokemonFaintedAnEnemy(@battle.battlers, target, user, basemove)
        end
      end
    end
    if hitflag.any?
      targets.each_with_index do |target, i|
        if target.isFainted?
          grudge = target.effects[:Grudge]
          destinybond = target.effects[:DestinyBond]
          if grudge && !user.isFainted?
            pbSetPP(basemove, basemove.pp = 0)
            @battle.pbDisplay(_INTL("{1}'s {2} lost all its PP due to the grudge!", user.pbThis, basemove.name))
          end
          target.pbFaint
          if @battle.recorded || @battle.FE == :CROWD
            $game_variables[:BattleDataArray].last().pokemonFaintedAnEnemy(@battle.battlers, user, target, basemove)
          end
          killtracker.push(target)
          if destinybond && !user.isFainted? && target.pbIsOpposing?(user.index)
            @battle.pbDisplay(_INTL("{1} took its attacker down with it!", target.pbThis))
            if user.isbossmon
              if !user.immunities[:moves].include?(:DESTINYBOND)
                user.pbReduceHP(user.hp) # early message
                user.pbFaint if user.isFainted? # pbReduceHP triggers boss shieldbreak, need to doublecheck that boss is still fainted for faint handling
                user.immunities[:moves].push(:DESTINYBOND)
              else
                @battle.pbDisplay(_INTL("{1} resisted the {2}!", user.pbThis, getMoveName(:DESTINYBOND)))
              end
            else
              user.pbReduceHP(user.hp) # early message
              user.pbFaint # no return
              @battle.pbJudgeCheckpoint(user)
            end
          end
        end
      end
      # Before Champions, effects like Knock Off don't happen if the user faints while using the move.
      applyPostMoveEffects(basemove, user, targets, hitflag) if Gen < Champs
      # Frenzy Encore Effect
      if user.permeffs[:Frenzy] && user.effects[:Encore] == 0
        user.effects[:Encore] = 4
        user.effects[:EncoreIndex] = choice[1]
        user.effects[:EncoreMove] = basemove.move
        @battle.pbDisplay(_INTL("{1} became fixated on {2}!", user.pbThis, getMoveName(basemove.move)))
      end
      # Magician
      if user.ability == :MAGICIAN && user.item.nil?
        wildBattle = @battle.pbIsWild? && @battle.battlers.none? { |battler| battler.isbossmon && battler.pokemon.bossID != :SHADOWDEN }
        targets.each_with_index do |target, i|
          next unless hitflag[i] == :Success
          next if wildBattle && !@battle.pbIsOpposing?(target.index) # magician doesn't work against the player in wild battles
          next if target.damagestate.substitute
          next if target.item.nil?
          next if @battle.pbIsUnlosableItem(target, target.item)
          next if @battle.pbIsUnlosableItem(user, target.item) # Can't obtain an item that would become unlosable
          # no fainted check bc apparently magician activates even against a fainted target

          @battle.pbShowAbilityBox(user)
          if target.ability == :STICKYHOLD && !target.moldbroken
            @battle.pbAbilityBoxAndDisplay(target, _INTL("{1}'s item cannot be removed!", target.pbThis))
          else
            @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!", user.pbThis, target.pbThis(true), getItemName(target.item)))
            target.transferItem(user)
          end
          @battle.pbHideAbilityBox(user)
        end
      end

      info = {}
      targets.each_with_index { |target, i| info[target] = { hitflag: hitflag[i], preMoveHP: preMoveHP[i] } }
      # Sheer Force affected things (checked in speed order of targets)
      targetsbyspeed = @battle.setSpeedOrder.filter { |battler| targets.include?(battler) }
      targetsbyspeed.each do |target|
        next unless info[target][:hitflag] == :Success
        next if target.damagestate.substitute
        next if target.isFainted?

        target.pbTargetEffectsDamaged(user, basemove, info[target][:preMoveHP])
      end
      # Berry check
      for j in 0...4
        @battle.battlers[j].pbBerryHerbCheck
      end
      # Emergency Exit / Wimp Out
      unless user.ability == :SHEERFORCE && basemove.effect > 0 && Gen < Champs
        targetsbyspeed = @battle.setSpeedOrder.filter { |battler| targets.include?(battler) }
        targetsbyspeed.each do |target|
          next unless info[target][:hitflag] == :Success
          next if target.damagestate.substitute

          target.pbEmergencyExitCheck(info[target][:preMoveHP])
        end
      end
      # Ability cure check
      for j in 0...4
        @battle.battlers[j].pbAbilityCureCheck
      end
      @battle.field.fieldroll = nil
      @battle.field.overlayroll = nil
      # Probopass Crest
      targets.each_with_index do |target, i|
        next if target == user
        if user.crested == :PROBOPASS
          if basemove.pbIsDamaging? && basemove.move != :PROBOPOG && [:Success, :StatusSuccess].intersect?(hitflag)
            msg = _INTL("{1}'s mini noses followed up on the attack!", user.pbThis)
            @battle.pbAbilityBoxAndDisplay(user, msg, item: true)
            if basemove.target == :AllOpposing || basemove.target == :AllNonUsers
              movetarget = target
              movetarget = user.pbCrossOpposing if user.pbPartner == target
              movetarget = movetarget.pbPartner if movetarget.isFainted?
            else
              movetarget = target
              movetarget = movetarget.pbPartner if movetarget.isFainted?
            end
            if movetarget.isFainted?
              @battle.pbDisplay(_INTL("But there was no target..."))
            else
              user.pbUseMoveSimple(:PROBOPOG, -1, movetarget.index)
            end
          end
        end
      end
      # Swalot Crest
      if user.crested == :SWALOT
        attrname = user.fakeCrest ? "Blessing" : getItemName(user.item)
        if basemove.move == :BELCH && [:Success, :StatusSuccess].intersect?(hitflag)
          move = :SPITUP
          msg = _INTL("{1} used\n{2}!", user.pbThis, getMoveName(move))
          @battle.pbAbilityBoxAndDisplay(user, msg, item: true, attrname: attrname)
          movetarget = targets[0]
          movetarget = movetarget.pbPartner if movetarget.isFainted?
          if movetarget.isFainted?
            @battle.pbDisplay(_INTL("But there was no target..."))
          else
            user.pbUseMoveSimple(move, -1, movetarget.index)
          end
        end
        if ![:STOCKPILE, :SPITUP, :SWALLOW].include?(basemove.move) && user.effects[:Stockpile] < 3
          @battle.pbShowAbilityBox(user, item: true, attrname: attrname)
          user.pbAddStockpile(nil)
          @battle.pbHideAbilityBox(user)
        end
      end
      # On Kill effects
      user.pbOnKillEffects(killtracker, basemove, flags) unless killtracker.empty?

      # Boss calling SOS after a shield break
      if @battle.callingSOS
        @battle.pbBossSOS(true)
        @battle.callingSOS = false
      end

      # Blunder Policy
      if user.missAcc
        if user.hasWorkingItem(:BLUNDERPOLICY)
          if user.pbCanIncreaseStatStage?(PBStats::SPEED, user, nil)
            @battle.pbShowAbilityBox(user, item: true)
            @battle.pbCommonAnimation("UseItem", user, nil)
            user.pbChangeStats(PBStats::SPEED, 2, user, nil, abilitycheck: :skip, statmessage: :Item)
            @battle.pbHideAbilityBox(user)
            user.pbDisposeItem
          end
        end
        if @battle.ProgressiveFieldCheck(PBFields::CONCERT)
          @battle.reduceField
        end
      end

      # Throat Spray
      if [:Success, :StatusSuccess].intersect?(hitflag)
        if user.hasWorkingItem(:THROATSPRAY) && basemove.checkSoundMove?(user) && user.hp > 0
          if user.pbCanIncreaseStatStage?(PBStats::SPATK, user, nil)
            @battle.pbShowAbilityBox(user, item: true)
            @battle.pbCommonAnimation("UseItem", user, nil)
            user.pbChangeStats(PBStats::SPATK, 1, user, nil, abilitycheck: :skip, statmessage: :Item)
            @battle.pbHideAbilityBox(user)
            user.pbDisposeItem
          end
        end
      end

      # Protective Rime
      if [:Success, :StatusSuccess].intersect?(hitflag)
        if user.ability == :PROTECTIVERIME && basemove.checkSoundMove?(user)
          if user.pbOwnSide.effects[:AuroraVeil] == 0
            @battle.pbShowAbilityBox(user)
            @battle.pbAnimation(:AURORAVEIL, user, nil)
            user.pbOwnSide.effects[:AuroraVeil] = 2
            @battle.pbHideAbilityBox(user)
          end
        end
      end

      # Misc Field Effects
      if @battle.FE == :DIMENSIONAL
        if [:DIG, :DIVE, :FLY, :BOUNCE, :SKYDROP].include?(basemove.move) && user.effects[:TwoTurnAttack] != 0
          mons = []
          combust = []
          unless (user.isShadow? rescue false) || user.hasType?(:SHADOW) || user.isFainted?
            mons.push(user)
            combust.push([user.totalhp / 4, 1].max)
          end
          if basemove.move == :SKYDROP
            targets.each_with_index do |target, i|
              next if target.isFainted?
              next unless [:Success, :StatusSuccess].include?(hitflag[i])
              next if (target.isShadow? rescue false) || target.hasType?(:SHADOW)
              mons.push(target)
              combust.push([target.totalhp / 4, 1].max)
            end
          end
          unless mons.empty?
            @battle.pbDisplay(_INTL("The corrupted dimension is harmful to the untainted!"))
            @battle.pbReduceBattlersHP(mons, combust)
            for mon in mons
              mon.pbFaint if mon.isFainted?
            end
          end
        end
      end
      if user.effects[:TwoTurnAttack] != 0 && basemove.immediate && !user.isFainted?
        # Field-based two-turn attack immediate message
        if [:GEOMANCY, :METEORBEAM].include?(basemove.move) && @battle.FE == :STARLIGHT
          @battle.pbDisplay(_INTL("{1} absorbed the starlight!", user.pbThis))
        end
        # Power Herb / Claydol Crest / Mega Sol
        case user.effects[:PowerHerb]
          when :Item
            @battle.pbShowAbilityBox(user, item: true)
            @battle.pbCommonAnimation("UseItem", user, nil)
            @battle.pbDisplay(_INTL("{1} became fully charged due to its {2}!", user.pbThis, getItemName(user.item)))
            @battle.pbHideAbilityBox(user)
            pbDisposeItem(duringattack: true)
          when :Crest
            @battle.pbAbilityBoxAndWait(user, item: true)
          when :Ability
            @battle.pbAbilityBoxAndWait(user)
        end
        user.effects[:PowerHerb] = nil
        logMoveUse(choice, basemove, user, flags)
        user.pbUseMove(choice, flags)
        return # the remaining checks of move execution are going to be handled in the 2nd instance of this move, we can finish here
        # additionally metronome can't be counted yet 2 turn moves turned immediate only count once after the execution of the damaging portion
      end

      unless user.isFainted?
        # Icy Field speed raise
        if @battle.FE == :ICY && !user.isAirborne?
          if (basemove.priority >= 1 && basemove.pbIsDamaging? && user.makesContact?(basemove)) || [:FEINT, :ROLLOUT, :DEFENSECURL, :STEAMROLLER, :LUNGE, :ICEBALL, :SPINOUT, :ICESPINNER].include?(basemove.move)
            user.pbChangeStats(PBStats::SPEED, 1, user, basemove, abilitycheck: :hide, statmessage: :IcySpeed)
          end
        end

        # Goth Crest
        if user.crested == :GOTHITELLE && user.hasType?(:DARK) && flags[:totaldamage] > 0 && user.canHeal?
          @battle.pbShowAbilityBox(user, item: true)
          user.pbRecoverHP((flags[:totaldamage] / 4.0).floor, true)
          @battle.pbHideAbilityBox(user)
        end

        # Dark Aura on Deux Finalis
        if (((user.crested == :PANGORO || user.ability == :DARKAURA) && [:DIMENSIONAL,:FROZENDIMENSION, :DEUXFINALIS].include?(@battle.FE)) || user.hasWorkingItem(:SOULSTONEHELD)) && flags[:totaldamage] > 0 && user.canHeal?
          source = (user.ability == :DARKAURA && [:DIMENSIONAL,:FROZENDIMENSION, :DEUXFINALIS].include?(@battle.FE)) ? getAbilityName(user.ability) : getItemName(user.item)
          @battle.pbShowAbilityBox(user, item: user.ability != :DARKAURA)
          mult = @battle.FE == :DEUXFINALIS ? 3.0 : 4.0
          user.pbRecoverHP((flags[:totaldamage] / mult).floor, true)
          @battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!", user.pbThis, source))
          @battle.pbHideAbilityBox(user)
        end


        # Sheer Force affected items
        unless user.ability == :SHEERFORCE && basemove.effect > 0
          # Shell Bell
          if (user.hasWorkingItem(:SHELLBELL) || user.crested == :TORTERRA) && flags[:totaldamage] > 0 && user.canHeal?
            @battle.pbShowAbilityBox(user, item: true)
            hpgain = (flags[:totaldamage] / (@battle.FE == :ASHENBEACH ? 4.0 : 8.0)).floor
            message = nil
            message = _INTL("{1} restored a little HP using its {2}!", user.pbThis, getItemName(user.item)) unless user.crested == :TORTERRA
            user.pbRecoverHP(hpgain, true, message: message)
            @battle.pbHideAbilityBox(user)
          end

          # Life Orb
          if user.hasWorkingItem(:LIFEORB) && hitflag.include?(:Success) && !@battle.magicGuardAbilities.include?(user.ability) && flags[:totaldamage] > 0
            @battle.pbShowAbilityBox(user, item: true)
            user.pbReduceHP((user.totalhp / 10.0).floor, true, message: _INTL("{1} lost some of its HP!", user.pbThis))
            @battle.pbHideAbilityBox(user)
          end

          user.pbFaint if user.isFainted? # no return
        end
      end

      # Pickpocket
      if (user.ability != :SHEERFORCE || basemove.effect == 0 || Gen >= Champs) &&
         user.makesContact?(basemove) &&
         !user.item.nil? &&
         !@battle.pbIsUnlosableItem(user, user.item)
        wildBattle = @battle.pbIsWild? && @battle.battlers.none? { |battler| battler.isbossmon && battler.pokemon.bossID != :SHADOWDEN }
        targets.each_with_index do |target, i|
          next if target.ability != :PICKPOCKET
          next if hitflag[i] != :Success
          next if wildBattle && !@battle.pbIsOpposing?(user.index) # pickpocket doesn't work against the player in wild battles
          next if !target.item.nil?
          next if target.damagestate.substitute
          next if @battle.pbIsUnlosableItem(target, user.item) # Can't obtain an item that would become unlosable

          @battle.pbShowAbilityBox(target)
          if user.ability == :STICKYHOLD
            @battle.pbAbilityBoxAndDisplay(user, _INTL("{1}'s item cannot be removed!", user.pbThis))
          else
            @battle.pbDisplay(_INTL("{1} had its {2} stolen!", user.pbThis, getItemName(user.item)))
            user.transferItem(target)
          end
          @battle.pbHideAbilityBox(target)
        end
      end

      # Delayed type gem consumption
      if user.effects[:TypeGemActivated]
        user.pbDisposeItem(duringattack: true)
        user.effects[:TypeGemActivated] = false
      end

      # The user executed a move, so use up the Micle Berry effect
      user.effects[:MicleBerry] = false

      # Delayed symbiosis for items that activate on taking damage (Type Berries, Weakness Policy, Focus Sash, etc.)
      # After effects are resolved on all targets and after all hits in case of multihit moves
      targets.each do |target|
        target.pbSymbiosis if target.effects[:DelaySymbiosis]
      end
    end

    # Mold Breaker reset
    @battle.battlers.each { |i| i.moldbroken = false }

    if [:Success, :StatusSuccess].intersect?(hitflag)
      # the counter for metronome ticks up even when the metronome item isn't held
      user.effects[:Metronome] += 1 # no need to check for the move we check at the start of the move if it's the same as the last and reset if it's not
      if basemove.function == 0x91 # Fury Cutter
        user.effects[:FuryCutter] += 1 if user.effects[:FuryCutter] < 2
      else
        user.effects[:FuryCutter] = 0
      end
    else
      user.effects[:Metronome] = 0
      user.effects[:FuryCutter] = 0
    end

    # Dancer
    if basemove && hitflag.any?
      pbDancerMoveCheck(basemove.move) unless danced || user.effects[:MagicBounced]
    end
    if danced
      if user.effects[:Outrage] > 0
        user.effects[:Outrage] = 0
      end
    end

    # Eject Pack
    priority = @battle.setSpeedOrder
    priority.each { |i| i.pbEjectPackCheck(immediate: false) } # Only sets userSwitch, handled below

    # Switch effects triggered by move
    # If either side is fully beaten no switching needs to happen, the battle ends
    unless @battle.pbAnySideAllFainted?
      priority = @battle.setSpeedOrder
      # Forced switches (cannot select pokemon to send in)
      priority.each { |i| i.carryOutForcedSwitch if i.forcedSwitch }
      # Self switches (can select pokemon to send in)
      priority.each { |i| i.carryOutUserSwitch if i.userSwitch }
    end

    if basemove.function == 0xE0 # Self-Destruct / Explosion
      user.effects[:DelayFaint] = false
      user.hp = 0
      user.pbFaint
    end

    # failsafe to catch field locks from from self targeted moves or other cases that slipped though the cracks
    # placed here so the fieldroll is unlocked before fields change due to move interactions
    @battle.field.fieldroll = nil
    @battle.field.overlayroll = nil
    @battle.fieldEffectAfterMove(basemove, user, hitflag)
    user.checkLandCriticalEvo
    @battle.pbGainEXP

    # Check if move order should be switched for shell trap

    # Record move as having been used
    logMoveUse(choice, basemove, user, flags)
    # End of move usage
    pbEndTurn(choice)
    @battle.pbJudgeSwitch
    return
  end

  def pbEffectivenessMessage(multipletargets)
    if @damagestate.typemod.doubleSuperEffective?
      @battle.pbDisplay(multipletargets ? _INTL("It's extremely effective on {1}!", pbThis(true)) : _INTL("It's extremely effective!"))
    elsif @damagestate.typemod.superEffective?
      @battle.pbDisplay(multipletargets ? _INTL("It's super effective on {1}!", pbThis(true)) : _INTL("It's super effective!"))
    elsif @damagestate.typemod.doubleResisted?
      @battle.pbDisplay(multipletargets ? _INTL("It's mostly ineffective on {1}...", pbThis(true)) : _INTL("It's mostly ineffective..."))
    elsif @damagestate.typemod.resisted?
      @battle.pbDisplay(multipletargets ? _INTL("It's not very effective on {1}...", pbThis(true)) : _INTL("It's not very effective..."))
    end
  end

  def pbCancelMoves
    # If failed pbTryUseMove or have already used Pursuit to chase a switching foe
    # Cancel multi-turn attacks
    @effects[:TwoTurnAttack] = 0 if @effects[:TwoTurnAttack] != 0
    @effects[:Outrage] = 0
    @effects[:Rollout] = 0
    @effects[:Uproar] = 0
    @effects[:Bide] = 0
    @effects[:HyperBeam] = 0
    @currentMove = 0
  end

  ################################################################################
  # Mock effective stat calculation
  ################################################################################
  def changeSpecialStat(unaware: false, crit: false, attacker: false, moldBrokenArray: nil, onlyModifiers: false)
    spatk = pbSpecialAttack(unaware: unaware, crit: crit, attacker: attacker, moldBrokenArray: moldBrokenArray, onlyModifiers: onlyModifiers)
    spdef = pbSpecialDefense(unaware: unaware, crit: crit, attacker: attacker, moldBrokenArray: moldBrokenArray, onlyModifiers: onlyModifiers)

    if attacker
      return spdef > spatk # is special defense better for the attacker
    else
      return spatk > spdef # is special attack better for the defender
    end
  end

  def pbAttack(unaware: false, crit: false, moldBrokenArray: nil)
    atkmult = 0x1000
    weather = @battle.pbWeather(self)
    if self.ability == :GUTS
      atkmult *= 1.5 if !self.status.nil?
    else
      atkmult *= 0.5 if self.status == :BURN && self.crested != :SUICUNE
    end
    for abilityholder in @battle.pbCheckSideAbility(:FLOWERGIFT, self)
      atkmult *= 1.5 if abilityholder.flowerGiftActive?
    end
    atkmult *= 0.5 if self.ability == :DEFEATIST && self.hp <= (self.totalhp / 2).floor
    atkmult *= 0.5 if self.ability == :SLOWSTART && self.effects[:SlowStart] < 5 && @battle.FE != :DEEPEARTH
    atkmult *= [:BACKALLEY, :CITY].include?(@battle.FE) ? 1.75 : 1.5 if self.ability == :HUSTLE
    atkmult *= 1.5 if self.ability == :GORILLATACTICS
    atkmult *= 1.3 if self.ability == :PROTOSYNTHESIS && self.effects[:Protosynthesis][0] == PBStats::ATTACK
    atkmult *= 1.3 if self.ability == :QUARKDRIVE && self.effects[:Quarkdrive][0] == PBStats::ATTACK
    atkmult *= PBMults::ParadoxLeads if self.ability == :ORICHALCUMPULSE && (weather == :SUNNYDAY || @battle.FE == :NEWWORLD)
    ruinmod = 0.75
    ruinmod = 0.667 if @battle.FE == :NEWWORLD
    ruinmod = 0.875 if @battle.FE == :HOLY
    atkmult *= ruinmod if @battle.pbCheckGlobalAbility(:TABLETSOFRUIN) && self.ability != :TABLETSOFRUIN && !(@battle.FE == :DEUXFINALIS && @battle.pbCheckSideAbility(:TABLETSOFRUIN, self))
    atkmult *= 1.5 if self.ability == :SOLARIDOL && weather == :SUNNYDAY && !self.hasWorkingItem(:UTILITYUMBRELLA)
    atkmult *= 2.0 if self.ability == :HUGEPOWER
    atkmult *= 2.0 if self.ability == :PUREPOWER && !(@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN)
    atkmult *= 2.0 if self.hasWorkingItem(:THICKCLUB) && [:CUBONE, :MAROWAK].include?(self.pokemon.species)
    atkmult *= 2.0 if self.hasWorkingItem(:LIGHTBALL) && self.pokemon.species == :PIKACHU
    atkmult *= 1.5 if self.hasWorkingItem(:CHOICEBAND)
    atkmult *= 1.1 if self.hasWorkingItem(:MUSCLEWING) && @battle.FE == :CLOUDS

    return (self.attack * atkmult * 1.0 / 0x1000).round if unaware

    atkstage = self.stages[PBStats::ATTACK] + 6
    atkstage = self.stages[PBStats::SPEED] + 6 if self.crested == :DEDENNE
    atkstage = 6 if crit && atkstage < 6

    return (self.attack * PBStats::StageMul[atkstage] * atkmult * 1.0 / 0x1000).round
  end

  def pbDefense(unaware: false, crit: false, moldBrokenArray: nil)
    defmult = 0x1000
    weather = @battle.pbWeather(nil)
    selfMoldBroken = moldBrokenArray && moldBrokenArray[self.index]
    unless selfMoldBroken
      defmult *= 1.5 if self.ability == :MARVELSCALE && (!self.status.nil? || [:MISTY, :RAINBOW, :FAIRYTALE, :DRAGONSDEN, :STARLIGHT, :DEUXFINALIS].include?(@battle.FE) || @battle.OV == :MISTY)
      defmult *= 2.0 if self.ability == :FURCOAT
      defmult *= 1.5 if self.ability == :GRASSPELT && ([:GRASSY, :FOREST].include?(@battle.FE) || @battle.OV == :GRASSY)
    end
    for abilityholder in @battle.pbCheckSideAbility(:FLOWERGIFT, self)
      defmult *= 1.5 if abilityholder.crested == :CHERRIM
    end
    defmult *= 1.3 if self.ability == :PROTOSYNTHESIS && self.effects[:Protosynthesis][0] == PBStats::DEFENSE
    defmult *= 1.3 if self.ability == :QUARKDRIVE && self.effects[:Quarkdrive][0] == PBStats::DEFENSE
    ruinmod = 0.75
    ruinmod = 0.667 if @battle.FE == :NEWWORLD
    ruinmod = 0.875 if @battle.FE == :HOLY
    defmult *= ruinmod if self.wonderroom && @battle.pbCheckGlobalAbility(:BEADSOFRUIN) && self.ability != :BEADSOFRUIN && !(@battle.FE == :DEUXFINALIS && @battle.pbCheckSideAbility(:BEADSOFRUIN, self))
    defmult *= ruinmod if !self.wonderroom && @battle.pbCheckGlobalAbility(:SWORDOFRUIN) && self.ability != :SWORDOFRUIN && !(@battle.FE == :DEUXFINALIS && @battle.pbCheckSideAbility(:SWORDOFRUIN, self))
    defmult *= 1.5 if self.hasType?(:ICE) && weather == :SNOW
    defmult *= 1.5 if self.evioliteActive?
    defmult *= 2.0 if self.hasWorkingItem(:METALPOWDER) && self.pokemon.species == :DITTO && !self.effects[:Transform]
    defmult *= 1.1 if self.hasWorkingItem(:RESISTWING) && @battle.FE == :CLOUDS
    defmult *= self.fieldDefenseBoost(nil, :physical)

    return (self.defense * defmult * 1.0 / 0x1000).round if unaware

    defstage = self.stages[PBStats::DEFENSE] + 6
    defstage = 6 if crit && defstage > 6

    return (self.defense * PBStats::StageMul[defstage] * defmult * 1.0 / 0x1000).round
  end

  def pbSpecialAttack(unaware: false, crit: false, attacker: true, moldBrokenArray: nil, onlyModifiers: false)
    ruinmod = 0.75
    ruinmod = 0.667 if @battle.FE == :NEWWORLD
    ruinmod = 0.875 if @battle.FE == :HOLY
    spatkmult = 0x1000
    weather = @battle.pbWeather(attacker ? self : nil)
    spatkmult *= 0.5 if self.ability == :DEFEATIST && self.hp <= (self.totalhp / 2).floor
    selfMoldBroken = moldBrokenArray && moldBrokenArray[self.index]
    unless selfMoldBroken
      spatkmult *= 2.0 if self.ability == :PUREPOWER && (@battle.FE == :PSYTERRAIN || @battle.OV == :PSYTERRAIN)
      if [:MINUS, :PLUS].include?(self.ability)
        if [:MINUS, :PLUS].include?(self.pbPartner.ability) || @battle.FE == :SHORTCIRCUIT || (Rejuv && @battle.FE == :ELECTERRAIN) || @battle.OV == :ELECTERRAIN
          spatkmult *= 1.5
        end
      end
      spatkmult *= 1.5 if self.ability == :LUNARIDOL && [:HAIL, :SNOW].include?(weather)
      spatkmult *= 1.5 if (self.ability == :SOLARPOWER || (self.crested == :CASTFORM && self.form == 1)) && weather == :SUNNYDAY && !(self.hasWorkingItem(:UTILITYUMBRELLA) || @battle.FE == :FROZENDIMENSION)
      spatkmult *= PBMults::ParadoxLeads if self.ability == :HADRONENGINE && (@battle.FE == :NEWWORLD || @battle.FE == :ELECTERRAIN || @battle.OV == :ELECTERRAIN)
    end
    for abilityholder in @battle.pbCheckSideAbility(:FLOWERGIFT, self)
      spatkmult *= 1.5 if abilityholder.crested == :CHERRIM
    end
    spatkmult *= 1.3 if self.ability == :QUARKDRIVE && self.effects[:Quarkdrive][0] == PBStats::SPATK
    spatkmult *= 1.3 if self.ability == :PROTOSYNTHESIS && self.effects[:Protosynthesis][0] == PBStats::SPATK
    spatkmult *= ruinmod if @battle.pbCheckGlobalAbility(:VESSELOFRUIN) && self.ability != :VESSELOFRUIN && !(@battle.FE == :DEUXFINALIS && @battle.pbCheckSideAbility(:VESSELOFRUIN, self))
    spatkmult *= 1.5 if self.hasWorkingItem(:CHOICESPECS)
    spatkmult *= 1.1 if self.hasWorkingItem(:GENIUSWING) && @battle.FE == :CLOUDS
    spatkmult *= 2.0 if self.hasWorkingItem(:DEEPSEATOOTH) && self.pokemon.species == :CLAMPERL
    spatkmult *= 2.0 if self.hasWorkingItem(:LIGHTBALL) && self.pokemon.species == :PIKACHU

    return (spatkmult * 1.0 / 0x1000).round if onlyModifiers
    return (self.spatk * spatkmult * 1.0 / 0x1000).round if unaware

    spatkstage = self.stages[PBStats::SPATK] + 6
    spatkstage = self.stages[PBStats::DEFENSE] + 6 if self.crested == :CLAYDOL
    if crit
      if attacker
        spatkstage = 6 if spatkstage < 6
      else
        spatkstage = 6 if spatkstage > 6
      end
    end

    return (self.spatk * PBStats::StageMul[spatkstage] * spatkmult * 1.0 / 0x1000).round
  end

  def pbSpecialDefense(unaware: false, crit: false, attacker: false, moldBrokenArray: nil, onlyModifiers: false)
    spdefmult = 0x1000
    weather = @battle.pbWeather(attacker ? self : nil)
    for abilityholder in @battle.pbCheckSideAbility(:FLOWERGIFT, self, checkMoldBroken: true, moldBrokenArray: moldBrokenArray)
      spdefmult *= 1.5 if abilityholder.flowerGiftActive?
    end
    selfMoldBroken = moldBrokenArray && moldBrokenArray[self.index]
    spdefmult *= 1.3 if self.ability == :PROTOSYNTHESIS && self.effects[:Protosynthesis][0] == PBStats::SPDEF
    spdefmult *= 1.3 if self.ability == :QUARKDRIVE && self.effects[:Quarkdrive][0] == PBStats::SPDEF
    ruinmod = 0.75
    ruinmod = 0.667 if @battle.FE == :NEWWORLD
    ruinmod = 0.875 if @battle.FE == :HOLY
    spdefmult *= ruinmod if !self.wonderroom && @battle.pbCheckGlobalAbility(:BEADSOFRUIN) && self.ability != :BEADSOFRUIN
    spdefmult *= ruinmod if self.wonderroom && @battle.pbCheckGlobalAbility(:SWORDOFRUIN) && self.ability != :SWORDOFRUIN
    spdefmult *= 1.5 if weather == :SANDSTORM && self.hasType?(:ROCK)
    spdefmult *= 1.1 if self.hasWorkingItem(:CLEVERWING) && @battle.FE == :CLOUDS
    spdefmult *= 1.5 if self.evioliteActive?
    spdefmult *= 1.5 if self.hasWorkingItem(:ASSAULTVEST)
    spdefmult *= 2.0 if self.hasWorkingItem(:DEEPSEASCALE) && self.pokemon.species == :CLAMPERL
    spdefmult *= self.fieldDefenseBoost(attacker ? self : nil, :special)

    return (spdefmult * 1.0 / 0x1000).round if onlyModifiers
    return (self.spdef * spdefmult * 1.0 / 0x1000).round if unaware

    spdefstage = self.stages[PBStats::SPDEF] + 6
    if crit
      if attacker
        spdefstage = 6 if spdefstage < 6
      else
        spdefstage = 6 if spdefstage > 6
      end
    end

    return (self.spdef * PBStats::StageMul[spdefstage] * spdefmult * 1.0 / 0x1000).round
  end

  ################################################################################
  # Turn processing
  ################################################################################
  def pbBeginTurn(choice)
    # Cancel some lingering effects which only apply until the user next moves
    @effects[:DestinyBond] = false
    @effects[:Grudge] = false
    @effects[:GlaiveRush] = false
    # Encore's effect ends if the encored move is no longer available
    if @effects[:Encore] > 0 &&
       @moves[@effects[:EncoreIndex]].move != @effects[:EncoreMove]
      PBDebug.dblog("[Resetting Encore effect]")
      @effects[:Encore] = 0
      @effects[:EncoreIndex] = 0
      @effects[:EncoreMove] = 0
    end
    # Gen 9 Charge wears off if the user attempts to use an Electric move
    # The UseCharge effect is what's used to apply the actual damage boost in damage calc
    if @effects[:Charge] > 0
      if Gen < 9
        @effects[:UseCharge] = true
      elsif choice[0] == :move && choice[2].pbType(self) == :ELECTRIC
        @effects[:Charge] = 0
        @effects[:UseCharge] = true
      end
    end
    if choice[0] == :move && choice[2].zmove
      choice[2] = @zmoves[choice[1]] if pbUpdateDynamicZMove(choice[1])
    end
  end

  def pbEndTurn(choice)
    # True end(?)
    @battle.battlers.each { |i| i.effects[:ReflectMove] = false }
    @battle.battlers.each { |i| i.effects[:TeraShell] = false }
    @battle.battlers.each { |i| i.moldbroken = false }
    # Reset category and type for correct display in command menu next turn
    if choice[0] == :move
      smartCategoryFunctions = [0x176, 0x20D, 0x309, 0x80A, 0x80B] # Photon Geyser / Super Ultra Mega Death Move / Shell Side Arm / Unleashed Power / Blinding Speed
      smartCategoryFunctions.push(0x522) if isStellarTerapagos? # Tera Starstorm
      smartCategoryFunctions.push(0x09F) if @crested == :SILVALLY
      if smartCategoryFunctions.include?(choice[2].function)
        choice[2].category = choice[2].data.category
      end
      if [0x206, 0x20E].include?(choice[2].function) # Probopass Crest Move, Mirror Beam
        choice[2].type = choice[2].data.type
      end
    end
    @selectedMove = nil
    @selectedSpecialMove = nil
    @battle.synchronize = [-1, -1, 0]
    @battle.itemActivationsCheck # for activating/deactivating items after they're Tricked, Thiefed, etc.
    @battle.pbStatChangeChecks
    @battle.eachBattler do |battler|
      battler.pbAbilityCureCheck
      battler.pbBerryHerbCheck
      battler.pbRegularIntervalChecks
    end
  end

  def pbProcessTurn(choice)
    # Can't use a move if fainted
    return if self.isFainted? && !choice[2]&.specialmove
    # Wild roaming Pokémon always flee if possible
    if !@battle.opponent && @battle.pbIsOpposing?(self.index) && @battle.rules["alwaysflee"] && @battle.pbCanRun?(self.index) &&
       $PokemonTemp.roamerIndex && $game_variables[RoamingSpecies[$PokemonTemp.roamerIndex][:variable]] <= @battle.turncount
      pbBeginTurn(choice)
      pbSEPlay("escape", 100)
      @battle.pbDisplay(_INTL("{1} fled!", self.pbThis))
      @battle.decision = 3
      pbEndTurn(choice)
      return
    end
    if $game_variables[:LuckShinies] != 0 && Rejuv
      for battler in @battle.battlers
        if battler.isWildPokemon? && !battler.isFainted? && battler.pokemon.isShiny? && !battler.isbossmon && !battler.issosmon
          if @battle.pbRandom(100) < 10
            pbBeginTurn(choice)
            pbSEPlay("escape", 100)
            @battle.pbDisplay(_INTL("{1} fled!", battler.name))
            @battle.decision = 3
            pbEndTurn(choice)
            return
          end
        end
      end
    end

    if choice[0] == :switch && @battle.FE == :COLOSSEUM
      index = choice[1] # party position of Pokémon to switch to
      @battle.lastMoveUser = self.index
      if !@battle.pbOwnedByPlayer?(self.index)
        owner = @battle.pbGetOwner(self.index)
        @battle.pbDisplayBrief(_INTL("{1} withdrew {2}!", owner.fullname, getMonName(self.species, self.form)))
      else
        @battle.pbDisplayBrief(_INTL("{1}, that's enough!\nCome back!", self.name))
      end

      @battle.pbRecallAndReplace(self.index, index)
    end

    # If this battler's action for this round wasn't "use a move"
    if choice[0] != :move && @battle.specialchoices[self.index][0] != :move
      # Clean up effects that end at battler's turn
      pbBeginTurn(choice)
      pbEndTurn(choice)
      return
    end


    # Turn is skipped if attacker used Pursuit during switch
    if @effects[:Pursuiter]
      @effects[:Pursuiter] = false
      pbCancelMoves
      pbEndTurn(choice)
      @battle.pbJudgeSwitch
      return
    end

    # Rejuv Special Move

    # if Rejuv
    #   if @battle.specialchoices[self.index][0] == :move && @battle.specialchoices[self.index][2].move == :ORBITALRING
    #     pbBeginTurn(choice)
    #     pbEndTurn(choice)
    #     return
    #   end
    # end

    PBDebug.logonerr {
      pbUseMove(choice, { specialusage: choice[2] == @battle.struggle })
    }
    return true
  end

  def pbSwapDefenses
    @spdef, @defense = @defense, @spdef
    @wonderroom = !@wonderroom
    if @effects[:Illusion] && @effects[:Illusion] != self
      @effects[:Illusion].pbSwapDefenses if @wonderroom != @effects[:Illusion].wonderroom
    end
  end

  def pbResetLockOn
    self.effects[:LockOn] = 0
    self.effects[:LockOnTarget] = -1
  end

  def checkLastWord(oldhp, moveStorage: nil)
    return if @effects[:LastWord].nil?
    return if @effects[:LastWord][:hpGate].nil? #|| @effects[:LastWord][:hpGate] == 0
    hpthreshold = (self.totalhp * self.effects[:LastWord][:hpGate]).floor
    @battle.runtrainerskills(self, false, true, move: moveStorage) if (oldhp > hpthreshold) && self.hp <= hpthreshold
  end

  def cheer
    return if self.isFainted?
    messageroll = [
      _INTL("{1} received the crowd's cheers! Full power!", self.name),
      _INTL("{1} received the crowd's cheers! Unyielding as the earth!", self.name),
      _INTL("{1} received the crowd's cheers! Full speed ahead!", self.name)
    ][self.roll]
    effectroll = [
      self.attack > self.spatk ? PBStats::ATTACK : PBStats::SPATK,
      self.defense > self.spdef ? PBStats::DEFENSE : PBStats::SPDEF,
      PBStats::SPEED,
    ][self.roll]
    @battle.pbDisplay(messageroll)
    self.pbChangeStats(effectroll, 1, nil, nil)
    self.roll += 1
    self.roll = 0 if self.roll > 2
  end

  def boo
    return if self.isFainted?
    dropstat = self.getHighestStatWithStages
    self.pbChangeStats(dropstat, -1, nil, nil, statmessage: :CrowdBoo)
  end

  def tempBoostRemovalCheck
    return unless self.tempBoosts.any? { |stat| stat > 0 }

    removeBoosts = nil
    if @battle.FE == :CROWD
      scoreToCompare = $game_variables[:BattleDataArray].last().getScoreAndSide(self)
      highestOpposingScore = [0, nil, ""]
      @battle.eachBattler do |battler|
        battlerArray = $game_variables[:BattleDataArray].last().getScoreAndSide(battler)
        if battlerArray[1] != scoreToCompare[1] && battlerArray[0].to_i > highestOpposingScore[0].to_i
          highestOpposingScore = battlerArray
        end
      end
      oppScore = highestOpposingScore[0].to_i
      removeBoosts = :opponentGone if oppScore < 3
    else
      removeBoosts = :fieldChanged
    end
    return unless removeBoosts

    if removeBoosts == :opponentGone
      @battle.pbDisplay(_INTL("The cheers of the crowd recede as {1} leaves the field!", $overscored))
    else
      @battle.pbDisplay(_INTL("The cheers recede as the crowd disappears!"))
    end
    stats, amounts = [], []
    self.tempBoosts.each_with_index { |boost, stat|
      next if boost == 0
      stats.push(stat)
      amounts.push(-boost)
    }
    self.pbChangeStats(stats, amounts, self, nil, abilitycheck: :hide, statmessage: :none, ignoreContrary: true)
    self.tempBoosts = [0, 0, 0, 0, 0, 0]
  end

  def releaseSkyDroppee
    droprelease = self.effects[:SkyDroppee]
    if droprelease != nil
      droprelease.effects[:SkyDrop] = false
      @effects[:SkyDroppee] = nil
      @battle.scene.pbUnVanishSprite(droprelease)
      @battle.pbDisplay(_INTL("{1} was freed from the {2}!", droprelease.pbThis, getMoveName(:SKYDROP)))
    end
  end

  def makesContact?(move, assumePhysical: false)
    contactMove = assumePhysical ? move.contactMoveWhenPhysical? : move.contactMove?
    return false unless contactMove
    return false if self.ability == :LONGREACH
    return !self.hasWorkingItem(:PUNCHINGGLOVE) if move.punchMove?
    return true
  end

  def getHitsTaken
    self.permeffs[:HitsTaken] = 0 if !self.permeffs[:HitsTaken]
    hits = self.permeffs[:HitsTaken]
    return [hits, 6].min
  end

  def addHitsTaken
    self.permeffs[:HitsTaken] = 0 if !self.permeffs[:HitsTaken]
    self.permeffs[:HitsTaken] += 1
  end

  def addCritsLanded
    self.permeffs[:CritsLanded] = 0 if !self.permeffs[:CritsLanded]
    self.permeffs[:CritsLanded] += 1
    self.effects[:CheckLandCriticalEvo] = true
  end

  def checkLandCriticalEvo
    return unless self.effects[:CheckLandCriticalEvo]
    self.effects[:CheckLandCriticalEvo] = false

    return if @battle.disableExpGain # Evo should be disabled in all situations where gaining EXP is disabled
    return unless @battle.pbOwnedByPlayer?(self.index)
    return if self.hp <= 0
    return if EVERSTONE_ITEMS.include?(self.item)

    check = checkEvolutionEx(self.pokemon) { |pokemon, method, condition, evo|
      next [evo, condition] if method == :LandCritical
    }
    return unless check

    newspecies, required = *check
    crits = self.permeffs[:CritsLanded]
    return if !crits || crits < required

    @battle.pbMidBattleEvo(self.pokemon, newspecies, self)
  end

  # For the AI to recognize Illusion in situations where there is some passive damage that is dependent only on types
  # Currently only used for hazards, because their effectiveness is (currently) not influenced by any other factors like abilities or items
  # To be called only when the battler actually takes damage, since immunity may be due to causes other than types (Magic Guard, Heavy Duty Boots) and thus shouldn't necessarily disclose Illusion
  def pbPassiveTypeEffCheck(type)
    return if self.isFainted? || !self.effects[:Illusion] || @battle.isOnline?

    eff1 = PBTypes.typesEff(type, self.types, inverse: @battle.inverse?)
    eff2 = PBTypes.typesEff(type, self.effects[:Illusion].types, inverse: @battle.inverse?)
    @battle.ai.discloseIllusion(self, :passiveTypeEff) if eff2 != eff1
  end

  def pbOnSendOutIllusionChecks
    return if !self.effects[:Illusion] || @battle.isOnline?

    if @battle.pbIsRevealedBattler?(self.index, illusiontarget: true)
      origpkmn = @battle.pbPartySingleOwner(self.index)[self.effects[:Illusion].pokemonIndex]
      # Disclose if illusion user and illusion target's status is different and illusion target has been revealed before
      @battle.ai.discloseIllusion(self, :diffStatus) if self.status != origpkmn.status
      # Disclose if HP fraction is different within one decimal place (that is the precision used in inspect and battle log, to be changed if those are changed)
      hp1 = (self.hp / self.totalhp.to_f * 100).round(1)
      hp2 = (origpkmn.hp / origpkmn.totalhp.to_f * 100).round(1)
      @battle.ai.discloseIllusion(self, :diffHP) if hp1 != hp2
    end
    # Disclose if illusion user's status is invalid for the pokemon it's illusioned as
    invalid = { :POISON => :POISON, :BURN => :FIRE, :PARALYSIS => :ELECTRIC, :FROZEN => :ICE }
    status, types = self.status, self.effects[:Illusion].types
    @battle.ai.discloseIllusion(self, :invalidStatus) if invalid[status] && types.include?(invalid[status])
  end
end

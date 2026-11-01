def bossFunction(boss, bossid, pokemon)
  pokemon.enablebossmon
  pokemon.shieldCount = boss.shieldCount
  pokemon.bossID = bossid
end

#===============================================================================
# Data box for boss battles (by Stochastic)
# - adapted by Sardines for Pokemon Rejuvenation
#===============================================================================
class PokeBattle_Pokemon
  attr_accessor(:isbossmon) # is a boss pokemon
  attr_accessor(:shieldCount) # number of shields
  attr_accessor(:bossID) # id of the boss idk
  attr_accessor(:sosmon) # is it a pokemon called by SOS
  attr_accessor(:originalhp) # hp at which spacea stole the player's pokemon
  attr_accessor(:stolen) # stolen by spacea have fun idiot
  attr_accessor(:original) # species/form the pokemon was at the start

  @isbossmon = false
  @sosmon = false
  def enablebossmon
    @isbossmon = true
  end

  def resetToBaseForm
    # Meloetta intentionally isn't reset in Reborn.
    @form = 0 if @species == :AEGISLASH && @form == 1
    @form = 0 if @species == :MORPEKO
    makeUnmega if isMega?
    makeUnprimal if isPrimal?
    makeUnultra if isUltra?
    makeUnterastallized if isTerastallized?
  end

  alias __core_baseStats baseStats unless method_defined?(:__core_baseStats)
  def baseStats
    val = __core_baseStats
    val = $cache.bosses[self.bossID].moninfo[:BaseStats] if self.bossID && $cache.bosses[self.bossID].moninfo[:BaseStats]
    return val
  end
end

def bossEntryText(boss)
  entrytext = boss.entryText
  bossPartyIndex = @battle.pbGetOwnerIndex(boss.index)

  return if entrytext.nil? || entrytext == "" || @handled_opp_messages[bossPartyIndex][:boss].include?(boss.pokemonIndex)
  entrytext = entrytext.gsub(/\\PN/, $Trainer.name)
  karma = $cache.pkmn[boss.pokemon.species, boss.pokemon.form].checkFlag?(:Karma)
  if karma
    pbSEPlay("SFX - Blip", 80, 140)
    pbDisplayPaused(entrytext, color: :karma)
  else
    pbDisplayPaused(entrytext)
  end
  @handled_opp_messages[bossPartyIndex][:boss].push(boss.pokemonIndex)
end

def bossHandler(decision, pokemon)
  return if !pokemon.isbossmon
  return if decision != 4
  return raidHandler(decision, pokemon) if $game_switches[:Raid]

  poke = $cache.bosses[pokemon.bossID].moninfo
  if poke[:moves]
    k = 0
    for move in poke[:moves]
      next if move.nil?

      pokemon.moves[k] = PBMove.new(move)
      k += 1
    end
  else
    pokemon.resetMoves
  end
  pokemon.level = poke[:level]
  pokemon.exp = PBExp.startExperience(poke[:level], pokemon.growthrate)
  pokemon.isbossmon = false
  pokemon.shieldCount = nil
  pokemon.activateRelearner() if poke[:relearnall]
  pokemon.obtainMode = poke[:obtaintype]
  pokemon.hatchedMap = poke[:hatchmap]
  pokemon.obtainMap = poke[:catchmap]
  pokemon.timeEggHatched = pbCatchTime if poke[:scrambleTime]
  pokemon.bossID = nil
  pokemon.item = nil
  if poke[:ev]
    pokemon.ev = poke[:ev]
  else
    for i in 0...6
      pokemon.ev[i] = 0
    end
  end
end

def isTwoVsOneBoss?(boss)
  # checks to see if the fight starts with 2 pokemon on the players side, regardless of if a partner exists
  boss = boss.is_a?(PokeBattle_Pokemon) ? boss : boss.pokemon
  return false if !$cache.bosses[boss.bossID]
  return $cache.bosses[boss.bossID].doublebattle
end

class PokeBattle_Battle
  attr_accessor :typesequence
  attr_accessor :callingSOS
  attr_accessor :blockedInspect

  def pbShieldEffects(battler, onBreakdata, onEntry = false, delayKey = nil, admin = false)
    if battler.shieldsBroken[battler.shieldCount + 1] == true && !onBreakdata[:queueDelays] && !onBreakdata[:trainerqueueDelays] && !pbAllFaintedAllParties?(@party2) && !admin
      return
    end

    vanished = false
    vanished = true if battler.vanished
    @scene.pbUnVanishSprite(battler) if vanished
    if onBreakdata[:animation]
      pbAnimation(onBreakdata[:animation], battler, nil)
    end
    if onBreakdata[:transformTo]
      poke = onBreakdata[:transformTo]
      if battler.species != poke[:species]
        battler.pokemon.species = poke[:species]
        battler.pokemon.form = poke[:form]
        battler.species = poke[:species]
        battler.form = poke[:form]
        battler.pokemon.makeShiny if poke[:shiny]
        battler.pokemon.ability = poke[:ability]
        battler.pokemon.moves.clear
        battler.name = poke[:name]
        battler.moves.clear
        poke[:moves].each_with_index { |move, k|
          next if move.nil?

          pbLearnMovePokemon(battler.pokemon, move, k, fullPP: battler.level >= 75)
        }
        battler.pbUpdate(true)
        pbAnimation(:TRANSFORM, battler, battler)
        @scene.pbChangePokemon(battler, battler.pokemon)
      end
    end
    if onBreakdata[:ArchetypeMessage]
      trainer = pbGetOwner(battler.index)
      if @opponent.is_a?(Array)
        if @opponent.include?(trainer)
          opponent = @opponent.index(trainer)
          @scene.pbShowOpponent(opponent, trainer.trainertype)
          showtrainer = true
        end
      else
        if @opponent == trainer
          @scene.pbShowOpponent(0, trainer.trainertype)
          showtrainer = true
        end
      end
      messages = Array(onBreakdata[:ArchetypeMessage])
      pbShowAbilityBox(battler, attrname: (_INTL("{1}'s Archetype", trainer.name)))
      messages.each { |message| pbDisplayAutoPaused(message) }
      pbHideAbilityBox(battler)
    end
    if onBreakdata[:message]
      messages = onBreakdata[:message].is_a?(Array) ? onBreakdata[:message] : [onBreakdata[:message]]
      for message in messages
        next if message.nil? || message == ""
        battlerstring = message.start_with?("{1}") ? battler.pbThis : battler.pbThis(true)
        pbDisplay(_INTL(message, battlerstring))
      end
    end
    if onBreakdata[:CustomMethod]
      if onBreakdata[:CustomMethod].is_a?(Array)
        for effect in onBreakdata[:CustomMethod]
          eval(effect)
        end
      else
        indexbackup = battler.index if onBreakdata[:CustomMethod].include?("timewarp")
        eval(onBreakdata[:CustomMethod])
        battler = @battlers[indexbackup] if onBreakdata[:CustomMethod].include?("timewarp")
      end
    end
    if onBreakdata[:fieldChange] && onBreakdata[:fieldChange] != @field.effect
      fieldmessage = onBreakdata[:fieldChangeMessage] && onBreakdata[:fieldChangeMessage] != "" ? onBreakdata[:fieldChangeMessage] : _INTL("The field was changed!")
      setField(onBreakdata[:fieldChange], 0, fieldmessage)
      @field.duration = 0
    end
    if onBreakdata[:overlay] && onBreakdata[:overlay] != @field.overlay
      fieldmessage = (onBreakdata[:overlay][1] && onBreakdata[:overlay][1] != "") ? onBreakdata[:overlay][1] : _INTL("The overlay was changed!")
      if onBreakdata[:overlay][3]
        pbAnimation(onBreakdata[:overlay][3], battler, nil)
      else
        pbAnimation(:MAGICROOM, battler, nil)
      end
      setField(onBreakdata[:overlay][0], onBreakdata[:overlay][2], fieldmessage)
    end
    multiturnsymbols = [:CLAMP, :FIRESPIN, :SANDTOMB, :DESERTSMARK, :WRAP, :MAGMASTORM, :INFESTATION, :BIND, :WHIRLPOOL]
    if onBreakdata[:bossEffect]
      onBreakdata[:bossEffect].each { |key, value|
        if multiturnsymbols.include?(key)
          battler.effects[:MultiTurnAttack] = key
          battler.effects[:MultiTurn] = value[0] ? value[0] : 5
          pbCommonAnimation(value[1].to_s, battler, nil) if value[1]
        elsif key == :ShellTrap
          battler.effects[key] = value[0] ? value[0] : 5
          pbCommonAnimation(value[1], battler, nil) if value[1]
        else
          battler.effects[key] = value[0] ? value[0] : 5
          pbAnimation(value[1], battler, nil) if value[1]
        end
        unless value[2].nil? || value[2] == ""
          battlerstring = value[2].start_with?("{1}") ? battler.pbThis : battler.pbThis(true)
          pbDisplay(_INTL(value[2], battlerstring))
        end
      }
    end
    if onBreakdata[:playerEffects]
      onBreakdata[:playerEffects].each { |key, value|
        successfulEffect = false
        for opponent in [battler.pbOpposing1, battler.pbOpposing2]
          next if opponent.isFainted? || opponent.issosmon
          next if key == :PerishSong && opponent.effects[:PerishSong] > 0
          successCheck = true
          if multiturnsymbols.include?(key)
            opponent.effects[:MultiTurnAttack] = key
            opponent.effects[:MultiTurn] = value[0] ? value[0] : 5
            pbCommonAnimation(value[1].to_s, opponent, nil) if value[1]
          else
            opponent.effects[:PerishSongUser] = battler.index if key == :PerishSong
            if key == :FutureSightMove
              opponent.effects[:FutureSightUserIndex] = battler.index
              opponent.effects[:FutureSightPokemon] = battler.pokemon
            end
            if key == :LockOnTarget
              opponent.effects[:LockOnTarget] = value[0]
            end
            if key == :GastroAcid
              if PBStuff::FIXEDABILITIES.include?(opponent.ability) || opponent.hasWorkingItem(:ABILITYSHIELD)
                successCheck = false
              else
                opponent.changeAbilityWithEffects(:suppress)
              end
            end
            if successCheck
              opponent.effects[key] = value[0] ? value[0] : 5
              pbAnimation(value[1], battler, opponent) if value[1]
              successfulEffect = true
            end
          end
        end
        if successfulEffect && !value[2].nil? && value[2] != ""
          battlerstring = value[2].start_with?("{1}") ? battler.pbThis : battler.pbThis(true)
          pbDisplay(_INTL(value[2], battlerstring))
        end
      }
    end
    if onBreakdata[:ev]
      battler.pokemon.ev = onBreakdata[:ev]
      battler.pokemon.calcStats
      battler.pbUpdate()
      if pbGetOwner(battler.index)
        @party2[pbGetOwnerIndex(battler.index)][battler.pokemonIndex].ev = onBreakdata[:ev]
        @party2[pbGetOwnerIndex(battler.index)][battler.pokemonIndex].calcStats
      end
    end
    if onBreakdata[:speciesUpdate] || onBreakdata[:formchange]
      speciesUpdate = onBreakdata[:speciesUpdate]
      formchange = onBreakdata[:formchange]
      if speciesUpdate
        battler.pokemon.species = speciesUpdate
        battler.species = speciesUpdate
      end
      if formchange
        battler.pokemon.form = formchange.is_a?(Array) ? formchange[0] : formchange
        battler.form = battler.pokemon.form
        battler.pokemon.ability = battler.pokemon.abilityIndex
      end
      if formchange&.is_a?(Array) && formchange[1]
        pbCommonAnimation(formchange[1], battler, nil)
      else
        pbAnimation(:TRANSFORM, battler, nil)
      end
      battler.pbUpdate(true)
      @scene.pbChangePokemon(battler, battler.pokemon)
      if battler.effects[:Substitute] == 0
        @scene.pbUnSubstituteSprite(battler)
      else
        @scene.pbSubstituteSprite(battler)
      end
    end
    if onBreakdata[:bgmChange]
      pbBGMPlay(onBreakdata[:bgmChange]) if FileTest.audio_exist?("Audio/BGM/" + onBreakdata[:bgmChange])
    end
    if onBreakdata[:abilitychange]
      newAbility = onBreakdata[:abilitychange]
      currentAbility = battler.ability || battler.backupability
      message = _INTL("{1} acquired {2}!", battler.pbThis, getAbilityName(newAbility))
      if currentAbility != newAbility
        battler.changeAbilityWithEffects(newAbility, message: message)
      else
        pbShowAbilityBox(battler)
        pbDisplay(message)
        pbHideAbilityBox(battler)
        battler.pbAbilitiesOnSwitchIn
      end
      battler.pokemon.ability = newAbility
      if pbGetOwner(battler.index)
        @party2[pbGetOwnerIndex(battler.index)][battler.pokemonIndex].setAbility(newAbility)
      end
    end
    if onBreakdata[:moveImmunities]
      battler.immunities[:moves].push(onBreakdata[:moveImmunities])
    end
    if onBreakdata[:weatherChange]
      if onBreakdata[:weatherChange][0] == :Reset
        pbEndWeather
      else
        weathermessage = onBreakdata[:weatherChange][2] ? onBreakdata[:weatherChange][2] : nil
        rainbowduration = onBreakdata[:weatherChange][1].nil? || onBreakdata[:weatherChange][1] == -1 ? 5 : onBreakdata[:weatherChange][1]
        duration = onBreakdata[:weatherChange][1] ? onBreakdata[:weatherChange][1] : -1
        duration = -1 if $game_switches[:Gen_5_Weather] == true && !self.isOnline?
        pbSetWeather(onBreakdata[:weatherChange][0], duration, weathermessage, rainbowduration)
        noWeather
      end
    end
    if onBreakdata[:statusCure]
      pbAnimation(:REFRESH, battler, nil)
      battler.pbCureStatus if battler.status != :PETRIFIED
    end
    if onBreakdata[:statusCleanse]
      pbAnimation(:HEALINGWISH, battler, nil)
      battler.pbCureStatus
    end
    animplay = false
    negativeEffects = [:Curse, :GastroAcid, :Imprison, :Nightmare, :TarShot, :SmackDown, :Encore, :HealBlock, :Octolock, :MultiTurn, :ChthonicMalady, :LeechSeed, :Petrification, :Attract, :Torment, :SyrupBombTurns, :SyrupBombUser, :SaltCure, :VengefulHex]
    if onBreakdata[:effectClear]
      for i in negativeEffects
        if PokeBattle_Battler::SwitchEff.include?(i)
          if battler.effects[i] != false
            battler.effects[i] = false
            animplay = true
          end
        end
        if PokeBattle_Battler::TurnEff.include?(i) || PokeBattle_Battler::CountEff.include?(i)
          if battler.effects[i] != 0
            battler.effects[i] = 0
            animplay = true
          end
        end
        if PokeBattle_Battler::PosEff.include?(i)
          if battler.effects[i] != -1
            battler.effects[i] = -1
            animplay = true
          end
        end
        if PokeBattle_Battler::OtherEff.include?(i)
          if battler.effects[i] != nil
            battler.effects[i] = nil
            animplay = true
          end
        end
      end
      battler.attack = battler.pokemon.attack
      battler.spatk = battler.pokemon.spatk
      battler.defense = battler.pokemon.defense
      battler.spdef = battler.pokemon.spdef
      pbAnimation(:HEALBELL, battler, nil) if animplay == true
      pbDisplayBrief(_INTL("{1} cleared itself of negative effects!", battler.pbThis))
    end
    if onBreakdata[:playerSideStatusChanges]
      for i in 0..3
        if i % 2 == 0
          next if self.battlers[i].nil?
          next if self.battlers[i].isFainted?

          if self.battlers[i].pbCanApplySelectStatus?(onBreakdata[:playerSideStatusChanges][0], battler, nil)
            self.battlers[i].pbApplySelectStatus(onBreakdata[:playerSideStatusChanges][0], battler, duration: 2)
          end
        end
      end
    end
    if onBreakdata[:bossSideStatusChanges]
      for i in 0..3
        if i % 2 != 0
          next if self.battlers[i].nil?
          next if self.battlers[i].isFainted?

          if self.battlers[i].pbCanApplySelectStatus?(onBreakdata[:bossSideStatusChanges][0], battler, nil)
            self.battlers[i].pbApplySelectStatus(onBreakdata[:bossSideStatusChanges][0], battler, duration: 2)
          end
        end
      end
    end

    # Effects affecting individual sides of battle
    [onBreakdata[:playersideChanges], onBreakdata[:bosssideChanges]].each_with_index { |data, i|
      next if data.nil?
      side = i == 0 ? battler.pbOpposingSide : battler.pbOwnSide
      data.each { |key, array|
        pbAnimation(array[1], battler, nil) if array[1]
        unless array[2].nil?
          defaultmessage = i == 0 ? _INTL("An Effect was put up on the side opposite to {1}!") : _INTL("An Effect was put up on {1}'s side!")
          statemessage = array[2] != "" ? array[2] : defaultmessage
          battlerstring = statemessage.start_with?("{1}") ? battler.pbThis : battler.pbThis(true)
          pbDisplay(_INTL(statemessage, battlerstring))
        end
        effect, effectval = key, array[0]
        pbApplySideEffect(effect, effectval, side, battler)
      }
    }
    if onBreakdata[:turntypeDamage]
      type, animation, damageDenom, message, hitself = onBreakdata[:turntypeDamage]
      damageDenom ||= 8

      pokemonDummy = PokeBattle_Pokemon.new(:DITTO, 1)
      battlerDummy = PokeBattle_Battler.new(self, @battlers.length, true)
      battlerDummy.pbInitPokemon(pokemonDummy, @battlers.length)
      moveDummy = PokeBattle_Move_FFF.new(self, battlerDummy, type)
      moveDummy.category = :status

      targets = @battlers.map { |battler2| battler2.isFainted? ? nil : battler2 }.compact
      if !hitself
        targets.delete(battler) if targets.include?(battler)
      end

      hitflags = [:Success] * targets.length
      moveDummy.pbTypeImmunities(battlerDummy, targets, hitflags)

      targets.each_with_index { |opp, i|
        case hitflags[i]
          when :Success
            pbAnimation(animation, battler, opp)
            eff = moveDummy.pbTypeModifier(type, battlerDummy, opp)
            damage = [(opp.totalhp * eff.multiplier / damageDenom).floor, 1].max
            if opp.hp > 0 && damage > 0
              opp.pbReduceHP(damage)
              opp.pbEffectsOnDealingDamage(moveDummy, battlerDummy, opp, damage, true)
            end
          else
            battlerDummy.moveFailureEffects(battlerDummy, moveDummy, opp, hitflags[i])
        end
      }

      pbDisplay(_INTL(message, battler.pbThis)) if message
    end
    # Effects affecting whole battlefield
    if onBreakdata[:stateChanges]
      onBreakdata[:stateChanges].each { |key, array|
        pbAnimation(array[1], battler, nil) if array[1]
        unless array[2].nil?
          statemessage = array[2] != "" ? array[2] : _INTL("The state of the battle was changed!")
          battlerstring = statemessage.start_with?("{1}") ? battler.pbThis : battler.pbThis(true)
          pbDisplay(_INTL(statemessage, battlerstring))
        end
        effect, effectval = key, (array[0] ? array[0] : 5)
        pbApplyGlobalEffect(effect, effectval)
      }
    end

    if battler.randomSetChanges
      items = battler.randomSetChanges.values
      setdetails = items[rand(items.length)]
      if setdetails[:typeChange]
        battler.type1 = setdetails[:typeChange][0]
        battler.type2 = setdetails[:typeChange][1] if setdetails[:typeChange][1]
      end
      if setdetails[:movesetUpdate]
        k = 0
        for move in setdetails[:movesetUpdate]
          next if move.nil?

          battler.pokemon.moves[k] = PBMove.new(move)
          if battler.level >= 100 && opponent.skill >= PokeBattle_AI::BESTSKILL
            battler.pokemon.moves[k].ppup = 3
            battler.pokemon.moves[k].pp = battler.pokemon.moves[k].totalpp
          end
          k += 1
        end
        battler.moves = []
        for move in battler.pokemon.moves
          battler.moves.push(PokeBattle_Move.pbFromPBMove(self, move, battler.pokemon)) if move
        end
      end
      if setdetails[:bossStatChanges]
        stats, amounts = *hashToParallelArrays(setdetails[:bossStatChanges])
        battler.pbChangeStats(stats, amounts, battler, nil, abilitycheck: :hide, statmessage: :bossShieldSelf)
      end
      battler.randomSetChanges.delete(battler.randomSetChanges.key(setdetails))
    else
      if onBreakdata[:typeChange]
        battler.type1 = onBreakdata[:typeChange][0]
        battler.type2 = onBreakdata[:typeChange][1] if onBreakdata[:typeChange][1]
      end
      if onBreakdata[:movesetUpdate]
        battler.pokemon.moves.clear
        battler.moves.clear
        onBreakdata[:movesetUpdate].each_with_index { |move, k|
          next if move.nil?

          pbLearnMovePokemon(battler.pokemon, move, k, fullPP: battler.level >= 75)
        }
      end
    end
    if onBreakdata[:typeSequence]
      if delayKey
        typeset = onBreakdata[:typeSequence].values
        battler.type1 = typeset[@typesequence][:typeChange][0]
        battler.type2 = typeset[@typesequence][:typeChange][1] if typeset[@typesequence][:typeChange][1]
        pbSet(1, @typesequence)
        @typesequence = (@typesequence + 1) % typeset.length
      end
    end
    if onBreakdata[:itemchange]
      battler.item = onBreakdata[:itemchange]
      battler.pokemon.setItem(onBreakdata[:itemchange])
      if pbGetOwner(battler.index)
        @party2[pbGetOwnerIndex(battler.index)][battler.pokemonIndex].setItem(onBreakdata[:itemchange])
      end
      if battler.hasCrest?
        if battler.species == :ZORUA
          battler.crested = :ZOROARK
        else
          battler.crested = battler.species
        end
        battler.crestStats
        pbCrestEffects(battler.index, battler)
      end
      if $cache.items[battler.item] && $cache.items[battler.item].zmove
        battler.pokemon.initZmoves(false)
        if !battler.pokemon.zmoves.nil?
          battler.zmoves = [nil, nil, nil, nil]
          for i in 0...battler.pokemon.zmoves.length
            zmove = battler.pokemon.zmoves[i]
            battler.zmoves[i] =
              PokeBattle_Move.pbFromPBMove(self, zmove, battler.pokemon, battler.moves[i]) if !zmove.nil?
          end
        end
      else
        battler.pokemon.zmoves = nil
        battler.zmoves = nil
      end
    end

    # placing all the stat change things next to each other

    if onBreakdata[:statDropCure]
      for s in PBStats::All
        battler.stages[s] = 0 if battler.stages[s] < 0
      end
      pbAnimation(:REFRESH, battler, nil)
      pbDisplayBrief(_INTL("{1} cleared itself of stat drops!", battler.pbThis))
    end

    if onBreakdata[:statBoostRefresh]
      for s in PBStats::All
        battler.stages[s] = 0 if battler.stages[s] > 0
      end
      pbAnimation(:REFRESH, battler, nil)
      pbDisplayBrief(_INTL("{1} cleared itself of stat boosts!", battler.pbThis))
    end

    if onBreakdata[:statChangeRefresh]
      for s in PBStats::All
        battler.stages[s] = 0 if battler.stages[s] != 0
      end
      pbAnimation(:HAZE, battler, nil)
      pbDisplayBrief(_INTL("{1} cleared itself of stat changes!", battler.pbThis))
    end

    if onBreakdata[:bossStatChanges]
      stats, amounts = *hashToParallelArrays(onBreakdata[:bossStatChanges])
      battler.pbChangeStats(stats, amounts, battler, nil, abilitycheck: :hide, statmessage: :bossShieldSelf)
    end

    if onBreakdata[:playerSideStatChanges]
      for i in [battler.pbOpposing1, battler.pbOpposing2]
        next unless i.passiveAbilityApplies?
        next if i.issosmon

        stats, amounts = *hashToParallelArrays(onBreakdata[:playerSideStatChanges])
        i.pbChangeStats(stats, amounts, battler, nil, statmessage: :bossShieldOpp)
      end
    end

    if onBreakdata[:lockOnTarget]
      choices = []
      choices.push(battler.pbOpposing1) unless battler.pbOpposing1.isFainted?
      choices.push(battler.pbOpposing2) unless battler.pbOpposing2.isFainted?
      if choices.length > 0
        target = sample(choices)
        if target&.hp > 0
          battler.effects[:LockOn] = 2
          battler.effects[:LockOnTarget] = target.index
        end
      end
    end
    pbStatChangeChecks
    if onBreakdata[:teraType]
      battler.teraTypeEffect = onBreakdata[:teraType]
      if battler.teraTypeEffect.is_a?(Array)
        teratypemessage = (_INTL("{1} gained ", battler.pbThis))
        battler.teraTypeEffect.each do |teratype|
          teratypemessage += (_INTL("{1} ",getTypeName(teratype)))
          teratypemessage += (_INTL("and ")) if teratype != battler.teraTypeEffect.last
        end
        teratypemessage += (_INTL("-type resistances and strengths!"))
        @battle.pbDisplay(teratypemessage)
      else
        @battle.pbDisplay(_INTL("{1} gained {2}-type resistances and strengths!", battler.pbThis, getTypeName(onBreakdata[:teraType])))
      end
    end
    if delayKey
      if !onBreakdata[:CustomMethod] || !onBreakdata[:CustomMethod].include?("timewarp")
        waitListIndex = battler.bossDelayList.index([delayKey, 0])
        battler.bossDelayList[waitListIndex] = nil
      end
    end
    if onBreakdata[:soscontinuous]
      if battler.sosDetails
        battler.sosDetails[:continuous] = true
      end
    end
    if onBreakdata[:queueDelays]
      battler.bossDelayList = [] if battler.bossDelayList.nil?
      for effect in onBreakdata[:queueDelays]
        battler.bossDelayList.push([effect, $cache.bosses[battler.pokemon.bossID].delayRegister[effect][:delay].clone])
      end
    end
    if onBreakdata[:trainerqueueDelays]
      trainer = pbGetOwner(battler.index)
      if trainer
        trainer.delayList = [] if trainer.delayList.nil?
        for effect in onBreakdata[:trainerqueueDelays]
          trainer.delayList.push([effect, trainer.delayRegister[effect][:delay].clone])
        end
      end
    end
    if onBreakdata[:instantMove]
      if onBreakdata[:instantMove][1] == :FirstUnfainted
        if !battler.pbOpposing1.isFainted?
          target = battler.pbOpposing1
        else
          if !battler.pbOpposing2.isFainted?
            target = battler.pbOpposing2
          end
        end
        if target
          battler.pbUseMoveSimple(onBreakdata[:instantMove][0], -1, target.index, specialZ: true)
        end
      elsif onBreakdata[:instantMove][1] == :LockedOn
        if battler.effects[:LockOnTarget]
          target = @battlers[battler.effects[:LockOnTarget]]
        else
          if !battler.pbOpposing1.isFainted?
            target = battler.pbOpposing1
          else
            if !battler.pbOpposing2.isFainted?
              target = battler.pbOpposing2
            end
          end
        end
        if target
          battler.pbUseMoveSimple(onBreakdata[:instantMove][0], -1, target.index, specialZ: true)
        end
      else
        battler.pbUseMoveSimple(onBreakdata[:instantMove][0], -1, onBreakdata[:instantMove][1], specialZ: true)
      end
    end
    if onBreakdata[:chargeSetupMessage]
      messages = onBreakdata[:chargeSetupMessage].is_a?(Array) ? onBreakdata[:chargeSetupMessage] : [onBreakdata[:chargeSetupMessage]]
      for message in messages
        next if message.nil? || message == ""
        battlerstring = message.start_with?("{1}") ? battler.pbThis : battler.pbThis(true)
        pbDisplay(_INTL(message, battlerstring))
      end
    end
    if onEntry
      pbBossSOS(false, true)
    else
      @callingSOS = true # Delay the call until after the current SOS faints
    end
    if onBreakdata[:opponentSwitch]
      if !(battler.lastAttacker >= 0)
        lastattacker = battler.lastAttacker
      else
        lastattacker = battler.pbFirstOpposing
      end
      if lastattacker != -1
        if pbCanChooseNonActive?(lastattacker.index)
          lastattacker.userSwitch = :BossEffect
        end
      else
        if pbCanChooseNonActive?(battler.pbFirstOpposing.index)
          battler.pbFirstOpposing.userSwitch = :BossEffect
        end
      end
    end
    if onBreakdata[:userSwitch]
      if pbCanChooseNonActive?(battler.index)
        battler.userSwitch = :BossEffect
      end
    end
    if onBreakdata[:endTurn]
      battler.endTurn = true
    end
    @scene.pbVanishSprite(battler) if vanished
    @scene.pbHideOpponent if showtrainer
  end

  def spaceaManip
    sosmon = []
    priority = setSpeedOrder
    for i in priority
      battler = i if i.isbossmon
      sosmon.push(i) if i.issosmon
    end
    return if !battler
    return if sosmon.empty?

    animplay = false
    if !battler.status.nil?
      for j in 0..sosmon.length
        next if !sosmon[j]
        next if sosmon[j].isFainted?

        sosmon[j].status = battler.status
        if [:SLEEP, :POISON].include?(battler.status)
          sosmon[j].statusCount = battler.statusCount
        end
      end
      battler.healStatus
      animplay = true
    end
    negativeEffects = [:Curse, :GastroAcid, :Imprison, :Nightmare, :TarShot, :SmackDown, :Encore, :HealBlock, :MultiTurn, :LeechSeed, :Petrification, :Attract, :Torment, :Octolock, :SyrupBombTurns, :SyrupBombUser, :SaltCure, :VengefulHex]
    for i in negativeEffects
      if PokeBattle_Battler::SwitchEff.include?(i)
        if battler.effects[i] != false
          for j in 0..sosmon.length
            next if !sosmon[j]
            next if sosmon[j].isFainted?

            sosmon[j].effects[i] = battler.effects[i]
          end
          battler.effects[i] = false
          animplay = true
        end
      end
      if PokeBattle_Battler::TurnEff.include?(i) || PokeBattle_Battler::CountEff.include?(i)
        if battler.effects[i] != 0
          for j in 0..sosmon.length
            next if !sosmon[j]
            next if sosmon[j].isFainted?

            sosmon.effects[i] = battler.effects[i]
          end
          battler.effects[i] = 0
          animplay = true
        end
      end
      if PokeBattle_Battler::PosEff.include?(i)
        if battler.effects[i] != -1
          for j in 0..sosmon.length
            next if !sosmon[j]
            next if sosmon[j].isFainted?

            sosmon[j].effects[i] = battler.effects[i]
          end
          battler.effects[i] = -1
          animplay = true
        end
      end
      if PokeBattle_Battler::OtherEff.include?(i)
        if battler.effects[i] != nil
          for j in 0..sosmon.length
            next if !sosmon[j]
            next if sosmon[j].isFainted?

            sosmon[j].effects[i] = battler.effects[i]
          end
          battler.effects[i] = nil
          animplay = true
        end
      end
    end
    for j in 0..sosmon.length
      pbAnimation(:PAINSPLIT, battler, sosmon[j]) if animplay == true
    end
    pbDisplay(_INTL("Spacea transferred her ailments around!"))
  end

  def checkBossesAndSOS
    array = [[], []] # first array contains boss pokemon, second sos pokemon
    for i in @battlers
      next if !(i.isbossmon || i.issosmon)
      if i.isbossmon
        next if i.isFainted? && i.shieldCount < 1
      else
        next if i.isFainted?
      end
      array[0].push(i) if i.isbossmon
      array[1].push(i) if i.issosmon
    end
    return array
  end

  def pbBossSOS(shieldbreak = false, onEntry = false, burnthefatherfeedthezygarde: false)
    bossarray = checkBossesAndSOS
    battler = bossarray[0][0]
    return if !battler
    return if bossarray[0].length > 1 # if more than one boss exists, do not run SOS
    return if @opponent && pbPokemonCountAllParties(@party2) > 1 && battler.name != "Devil's Advocate" # if this is a trainer battle and opposing party length isnt a single pokemon, do not run SOS
    sosData = battler.sosDetails
    if sosData
      if sosData[:refreshingRequirement]
        if shieldbreak && !onEntry && @sosbattle != :none && sosData[:refreshingRequirement].include?(battler.shieldCount)
          variable = pbRefreshSOSPokemon(sosData)
          return if variable
        elsif !onEntry
          return
        end
      end
      return if bossarray[1].length > 0 # if an SOS pokemon already exists, do not run SOS

      if sosData[:clearingRequirement]
        if eval(sosData[:clearingRequirement])
          pbResetBattlers(@sosbattle == :singlePokemonPlayerSide) if !onEntry && @sosbattle != :none
          return
        end
      end

      # is the parter position of the boss occupied? but anything? if yes don't spawn the SoS
      return if !battler.pbPartner.isFainted? && (!battler.pbPartner.isbossmon || battler.pbPartner.shieldCount < 1)

      allowed = false
      allowed = true if shieldbreak || onEntry || sosData[:continuous]
      if eval(sosData[:activationRequirement]) || burnthefatherfeedthezygarde
        if allowed
          if sosData[:totalMonCount]
            sosBattle(battler) if battler.currentSOS < sosData[:totalMonCount]
          else
            sosBattle(battler)
          end
        end
      end
    end
  end


  def pbRefreshSOSPokemon(sosData)
    sosmon = nil
    priority = setSpeedOrder
    for i in priority
      sosmon = i if i.issosmon
      # sosmonarray.push(i) if i.issosmon
      bossmon = i if i.isbossmon
    end
    # sosmonarray.uniq!
    return false if !sosmon

    if sosmon.isFainted?
      pbCommonAnimation("ZPower", bossmon, nil)
      pbAnimation(:HELPINGHAND, bossmon, sosmon)
      sosBattle(bossmon)
      return true
    end
    bossmon.currentSOS += 1
    pbCommonAnimation("ZPower", bossmon, nil)
    pbAnimation(:HELPINGHAND, bossmon, sosmon)
    pbDisplayPaused(_INTL("{1} revitalized its allies!", bossmon.name))
    if sosData[:moninfos][bossmon.currentSOS]
      pbAnimation(:REFRESH, sosmon, nil)
      sosmon.pbRecoverHP(sosmon.totalhp, true, fullrecover: true) if sosmon.hp != sosmon.totalhp
      sosmon.healStatus if sosmon.status != nil
      sosmon.pokemon = pbLoadSOSMon(sosData[:moninfos][bossmon.currentSOS], bossmon)
      sosmon.species = sosmon.pokemon.species
      sosmon.form = sosmon.pokemon.form
      sosmon.ability = sosmon.pokemon.ability
      sosmon.moves = []
      for move in sosmon.pokemon.moves
        sosmon.moves.push(PokeBattle_Move.pbFromPBMove(self, move, sosmon.pokemon)) if move
      end
      sosmon.item = sosmon.pokemon.item
      if $cache.items[sosmon.item] && $cache.items[sosmon.item].zmove
        sosmon.pokemon.initZmoves(false)
        if !sosmon.pokemon.zmoves.nil?
          sosmon.zmoves = [nil, nil, nil, nil]
          for i in 0...sosmon.pokemon.zmoves.length
            zmove = sosmon.pokemon.zmoves[i]
            sosmon.zmoves[i] = PokeBattle_Move.pbFromPBMove(self, zmove, sosmon.pokemon, sosmon.moves[i]) if !zmove.nil?
          end
        end
      else
        sosmon.pokemon.zmoves = nil
        sosmon.zmoves = nil
      end
      sosmon.pbUpdate(true)
    end
    return true
  end

  def returnStolenPokemon(returnAll = false, returnedSoSMon = nil, lastattacker = nil)
    returnlist = []
    if returnAll
      for pokemon in @party1[0]
        next if pokemon.nil?
        returnlist.push(pokemon) if pokemon.stolen
      end
    else
      return false if returnedSoSMon.nil?
      return false unless returnedSoSMon.issosmon
      return false unless returnedSoSMon.pokemon.stolen
      returnlist.push(returnedSoSMon.pokemon)
    end
    stealBack = false
    for pokemon in returnlist
      pokemon.stolen = false
      pokemon.sosmon = false
      for battler in @battlers
        battler.effects[:FutureSightUserIndex] = 0 if battler.effects[:FutureSightPokemon] == pokemon
      end
      if returnedSoSMon && lastattacker
        # stolen Pokemon was knocked out by its original owner
        if returnedSoSMon.pbIsOpposing?(lastattacker)
          pokemon.form = @permanenteffects[pokemon][:FormWhenStolen]
          pokemon.hp = @permanenteffects[pokemon][:HPWhenStolen]
          stealBack = true
        end
      end
      @permanenteffects[pokemon][:FormWhenStolen] = nil
      @permanenteffects[pokemon][:HPWhenStolen] = nil
    end
    return stealBack
  end

  def pbRemoveFromPartyTemporary(battlerIndex, partyIndex)
    party = pbPartySingleOwner(battlerIndex)
    storedmon = party[partyIndex]
    if @battlers[battlerIndex].effects[:TypeGemActivated]
      @battlers[battlerIndex].pbDisposeItem(duringattack: true)
      @battlers[battlerIndex].effects[:TypeGemActivated] = false
    end
    storedmon.stolen = true
    @battlers[battlerIndex].pbReset
    @battlers[battlerIndex].participants = []
    @battlers[battlerIndex].pokemonIndex = partyIndex
  end

  def burnthefatherfeedthedog(battler)
    sosData = battler.sosDetails

    # save initial battle state
    initbattlestate = @doublebattle

    # force sos through special method that bypasses the usual checks and restrictions
    pbBossSOS(true, false, burnthefatherfeedthezygarde: true)
    for i in 0...@battlers.length
      next if @battlers[i].isFainted?
      next if @battlers[i].nil?

      if @battlers[i].issosmon
        next if @scene.sprites["battlebox#{i}"].nil?

        pbAnimation(:THOUSANDARROWS, @battlers[i].pbPartner, @battlers[i])
        @scene.pbFainted(@battlers[i])
        8.times do
          @scene.sprites["battlebox#{i}"].opacity -= 32
          @scene.pbGraphicsUpdate
          Input.update
        end
        @scene.sprites["battlebox#{i}"].visible = false
        @scene.sprites["shadow#{i}"].visible = false
        @scene.sprites["pokemon#{i}"].visible = false
        @scene.pbGraphicsUpdate
      end
    end
    @battlers[3].pbReset
    for i in 0..@party2[0].length
      next if @party2[0][i].nil?

      @party2[0].delete_at(i) if !@party2[0][i].isbossmon
    end

    # set sos battle to none + double battle to initial battle state before sos got called
    @sosbattle = :none
    @doublebattle = initbattlestate

    # resets battlebox to single bossmon position
    @scene.pbChangePokemon(battler, battler.pokemon)
    @scene.sprites["battlebox#{battler.index}"].dispose
    @scene.sprites["battlebox#{battler.index}"] = @scene.createPokemonDataBox(battler, false, @scene.viewport, self)
    @scene.sprites["battlebox#{battler.index}"].appear
    while @scene.sprites["battlebox#{battler.index}"].appearing
      @scene.sprites["battlebox#{battler.index}"].update
    end
    @scene.sprites["battlebox#{battler.index}"].refresh

    # dialogue to explain the fusion
    pbDisplayPaused(_INTL("{1}'s cells pinned Yveltal down!", battler.pbThis))

    # fusion
    battler.pokemon.species = :YVELTAL
    battler.pokemon.form = 0
    battler.pokemon.fused = deep_copy(battler.pokemon)
    battler.pokemon.createCustomMon
    battler.pokemon.species = :ZYGARDE
    battler.changeForm(5)
    battler.pokemon.customForm.instance_variable_set(:@Type1, :DRAGON)
    battler.pokemon.customForm.instance_variable_set(:@Type2, :DARK)
    battler.pokemon.setAbility(:DARKAURA)
    coreSpread = [4, 4, 1, 4, 1, 1]
    coreInvestment = battler.pokemon.customForm.checkFlag?(:CoreInvestment)
    for i in 0..5
      coreInvestment[i] = coreSpread[i]
    end
    battler.pokemon.recalcStats()
    pbCommonAnimation("ZygardeForms", battler, nil)
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler, battler.pokemon)
    pbDisplayPaused(_INTL("{1}'s Opportunity consumed Yveltal!", battler.pbThis))

    @scene.sprites["fightwindow"].battler = @battlers[0]
  end

  def pbResetBattlers(settonormal = false)
    for i in 0...@battlers.length
      battler = @battlers[i] if @battlers[i].isbossmon
    end
    return if !battler

    sosData = battler.sosDetails
    for i in 0...@battlers.length
      next if @battlers[i].isFainted?
      next if @battlers[i].nil?

      if @battlers[i].issosmon
        next if @scene.sprites["battlebox#{i}"].nil?

        pbAnimation(:SPACIALREND, @battlers[i], @battlers[i])
        @scene.pbFainted(@battlers[i])
        8.times do
          @scene.sprites["battlebox#{i}"].opacity -= 32
          @scene.pbGraphicsUpdate
          Input.update
        end
        @scene.sprites["battlebox#{i}"].visible = false
        @scene.sprites["shadow#{i}"].visible = false
        @scene.sprites["pokemon#{i}"].visible = false
        @scene.pbGraphicsUpdate
      end
    end
    if sosData[:playerMons] || sosData[:playerParty]
      returnStolenPokemon(true)
    else
      for i in 0...@battlers.length
        next if @battlers[i].isFainted?
        next if @battlers[i].nil?

        if !(i == 0 || i == 1)
          @battlers[i].pbReset
        end
      end
    end
    for i in 0..@party2[0].length
      next if @party2[0][i].nil?

      @party2[0].delete_at(i) if !@party2[0][i].isbossmon
    end
    if @doublebattle || @sosbattle != :none
      if settonormal
        @doublebattle = false
        @sosbattle = :none
      end
      for i in 0...@battlers.length
        next if @battlers[i].isFainted?
        next if @battlers[i].nil?

        @scene.sprites["battlebox#{i}"].visible = false
        @scene.sprites["battlebox#{i}"].dispose if !@battlers[i].pokemon.nil?
        @scene.pbChangePokemon(@battlers[i], @battlers[i].pokemon)
        @scene.sprites["battlebox#{i}"] =
          @scene.createPokemonDataBox(@battlers[i], @doublebattle, @scene.viewport, self)
        @scene.sprites["battlebox#{i}"].appear
        loop do
          @scene.sprites["battlebox#{i}"].update
          @scene.pbGraphicsUpdate
          Input.update
          break if !@scene.sprites["battlebox#{i}"].appearing
        end
        @battlers[i].vanished = false
      end
    end
    @scene.sprites["fightwindow"].battler = @battlers[0]
  end

  def assignSoSPiece(pokemon, boss)

    # Kinghts / Bishops / Rooks
    stats = pokemon.backupstats || pokemon.getStats()
    stats = stats[1..] # All stats minus HP
    maxstat = stats.index(stats.max) + 1
    # If multiple stats are tied for highest, they will be prioritized in this order: Atk > Def > SpA > SpD > Spd
    piece = case maxstat
      when PBStats::ATTACK, PBStats::SPATK then :BISHOP
      when PBStats::DEFENSE, PBStats::SPDEF then :ROOK
      else :KNIGHT
    end
    # King
    ability = Rejuv && pokemon.ability == :SUPREMEOVERLORD
    item = pokemon.item == :KINGSROCK
    if !@permanenteffects[boss][:assignedSoSKing] && (ability || item)
      piece = :KING
      @permanenteffects[boss][:assignedSoSKing] = true
    end

    @permanenteffects[pokemon][:Piece] = piece
  end

  def sosBattleSpecial(battler)
    sosData = battler.sosDetails
    bossData = $cache.bosses[battler.pokemon.bossID]
    playerMon = battler.pbOppositeOpposing
    return if !playerMon
    return if !battler.pbPartner.isFainted?

    if sosData
      battler.currentSOS += 1
      priority = setSpeedOrder
      if sosData[:playerMons]
        sosmon = @party1[0][playerMon.pokemonIndex] if !playerMon.isFainted?
        return false if battler.isFainted?
        return false if !sosmon

        @permanenteffects[sosmon][:HPWhenStolen] = sosmon.hp
        @permanenteffects[sosmon][:FormWhenStolen] = sosmon.form
        sosmon.sosmon = true
        @party2[0].push(sosmon)
        @doublebattle = true
        sosIndex = battler.pbPartner.index
        @choices[sosIndex] = [nil]
        @specialchoices[sosIndex] = [nil]
        @sosbattle = ($PokemonGlobal.partner || bossData&.doublebattle) ? :full : :singlePokemonPlayerSide
        pbAnimation(:SPACIALREND, playerMon, nil)
        @scene.pbFainted(playerMon)
        pbRemoveFromPartyTemporary(playerMon.index, playerMon.pokemonIndex)
        @battlers[sosIndex].pbInitialize(@party2[0][-1], @party2.length - 1, false)
        @scene.pbIntroSOS(self, sosIndex)
        for i in @battlers
          i.effects[:FutureSightUserIndex] = sosIndex if i.effects[:FutureSightPokemon] == sosmon
        end
        if @ai.aimondata[sosIndex] == nil
          @ai.aimondata[sosIndex] = AI_MonData.new(nil, sosIndex, self)
          @ai.aimondata[sosIndex].skill = 100
        end
        # Fill the second slot on player side with dummy data when the battle changes fron singles to doubles.
        if @ai.aimondata[2] == nil
          @ai.aimondata[2] = AI_MonData.new(@battle.player, 2, @battle)
          @ai.aimondata[2].skill = 100
        end
        @state.effects[:sosBuffer] = 6
        for data in @ai.aimondata
          next if data.nil?

          @ai.mondata = data
          @ai.mondata.partyroles = (@ai.mondata.skill >= PokeBattle_AI::HIGHSKILL) ? @ai.pbGetMonRoles : Array.new(@ai.mondata.party.length) { Array.new() }
        end
        pbDisplayPaused(_INTL("SPACEA: What's yours is mine! I'll take good care of it!"))
        pbOnActiveOne(@battlers[sosIndex])

        pbJudge()
        if @decision > 0
          return
        end

        spaceaManip
        for i in priority
          i.pbCancelMoves
          pbClearChoices(i.index)
        end
        for i in priority
          i.pbEndTurn(@choices[battler.index])
        end
      end
    end
  end

  def sosBattle(battler)
    sosData = battler.sosDetails
    bossData = $cache.bosses[battler.pokemon.bossID]
    return sosBattleSpecial(battler) if sosData[:playerMons]
    if sosData
      battler.currentSOS += 1
      currentSOSoffset = 0
      if sosData[:sosOffsets]
        sosData[:sosOffsets].each do |condition|
          currentSOSoffset += 1 if eval(condition)
        end
      end
      sosRegisterIndex = battler.currentSOS + currentSOSoffset
      pbPlayCry(battler.pokemon)
      if sosData[:moninfos][sosRegisterIndex]
        sosmon = sosData[:moninfos][sosRegisterIndex]
      else
        items = sosData[:moninfos].values
        sosmon = items[rand(items.length)]
      end
      genwildpoke = pbLoadSOSMon(sosmon, battler)
      @party2[0].push(genwildpoke)
      assignSoSPiece(genwildpoke, battler.pokemon)
      @doublebattle = true
      sosIndex = battler.pbPartner.index
      @sosbattle = ($PokemonGlobal.partner || bossData&.doublebattle) ? :full : :singlePokemonPlayerSide
      @battlers[sosIndex].pbInitialize(@party2[0][-1], @party2[0].length - 1, false)
      @choices[sosIndex] = [nil]
      @specialchoices[sosIndex] = [nil]
      @scene.pbIntroSOS(self, sosIndex)
      if @ai.aimondata[sosIndex] == nil
        @ai.aimondata[sosIndex] = AI_MonData.new(nil, sosIndex, self)
        @ai.aimondata[sosIndex].skill = 100
      end
      # Fill the second slot on player side with dummy data when the battle changes fron singles to doubles.
      if @ai.aimondata[2] == nil
        @ai.aimondata[2] = AI_MonData.new(@battle.player, 2, @battle)
        @ai.aimondata[2].skill = 100
      end
      for data in @ai.aimondata
        next if data.nil?

        @ai.mondata = data
        @ai.mondata.partyroles = (@ai.mondata.skill >= PokeBattle_AI::HIGHSKILL) ? @ai.pbGetMonRoles : Array.new(@ai.mondata.party.length) { Array.new() }
      end
      if sosData[:entryMessage]
        if sosData[:entryMessage] != ""
          message = sosData[:entryMessage].is_a?(Array) ? sosData[:entryMessage][sosRegisterIndex - 1] : sosData[:entryMessage]
          battlerstring = message.start_with?("{1}") ? battler.pbThis : battler.pbThis(true)
          sosString = @party2[0][-1].name
          pbDisplay(_INTL(message, battlerstring, sosString))
        end
      else
        pbDisplayPaused(_INTL("{1} called for help and\n{2} appeared!", battler.name, @party2[0][-1].name))
      end
      $Trainer.pokedex.setSeen(genwildpoke)
      pbRegisterRevealedBoss(sosIndex)
      pbApplyEntryEffects(@battlers[sosIndex])
    end
  end

  def pbStasis(battler)
    priority = setSpeedOrder
    for mon in priority
      next if mon.isFainted?
      next if mon.permeffs[:Stasis]
      next if !@battle.pbOwnedByPlayer?(mon.index)
      mon.permeffs[:Stasis] = true
      if mon.permeffs[:Stasis]
        pbAnimation(:FAIRYLOCK, mon, battler)
        pbDisplay(_INTL("{1} was frozen in time!", mon.pbThis))
      end
    end
  end

  def pbPokemonEvolutionRevert(user, base = false)
    target = user.pbOppositeOpposing
    return if target.item == :EVERSTONE
    if !target.permeffs[:EvolutionReverted]
      target.pokemon.original = [target.pokemon.species, target.pokemon.form, target.level, target.pokemon.ability]
    end
    if target.isMega?
      target.pokemon.resetToBaseForm
      target.pbUpdate(true)
      pbAnimation(:ROAROFTIME, target, nil)
      @battle.scene.pbChangePokemon(target, target.pokemon)
      target.pokemon.original[1] = target.pokemon.form
      target.permeffs[:EvolutionReverted] = true
      pbDisplay(_INTL("{1} was reverted!", target.pbThis))
      return
    end
    preevo = pbGetPreviousForm(target.pokemon.species, target.pokemon.form)
    preevo = pbGetPreviousForm(preevo[0], preevo[1]) if base == true
    preevoability = resolvePreEvoAbility(target.pokemon.getCacheData, $cache.pkmn[preevo[0], preevo[1], target.pokemon.gender], target.pokemon.ability)

    target.species = preevo[0]
    originalSpecies = target.pokemon.species
    target.pokemon.species = preevo[0]
    target.pokemon.form = preevo[1]
    target.pokemon.level = 1 if base == true
    target.pokemon.ability = preevoability
    target.pbUpdate(true, deevolution: true)
    target.undoCrestStats
    pbAnimation(:ROAROFTIME, target, nil)
    @scene.pbChangePokemon(target, target.pokemon)
    target.permeffs[:EvolutionReverted] = true
    pbDisplay(_INTL("{1} was reverted!", target.pbThis))
  end


  def pbLifeBloodAnalysis(battler)
    priority = setSpeedOrder
    pbSEPlay("SFX - Blip", 80, 140)
    pbCommonAnimation("GlitchE")
    pbDisplay(_INTL("{1} is analyzing the siphoned data!", battler.pbThis))
    if !@permanenteffects[battler.pokemon][:analysis]
      @permanenteffects[battler.pokemon][:analysis] = {
        :partialAnalysis => [],
        :semiAnalysis => [],
        :fullAnalysis => [],
      }
      for mon in @party1[0]
        next if mon.nil?
        next if !@permanenteffects[mon][:LifeBlood]
        currBattler = @battlers.select {|pokemon| pokemon.personalID == mon.personalID}[0]
        eff = @permanenteffects[mon][:LifeBlood]
        case eff[:LifeBloodStage]
          when 1
            @permanenteffects[battler.pokemon][:analysis][:partialAnalysis].append(mon)
          when 2
            @permanenteffects[battler.pokemon][:analysis][:semiAnalysis].append(mon)
          when 3
            @permanenteffects[battler.pokemon][:analysis][:fullAnalysis].append(mon)
        end
        @permanenteffects[mon][:LifeBlood][:turncount] = 0
        @permanenteffects[mon][:LifeBlood][:abilitySuppression] = false
        @permanenteffects[mon][:LifeBlood][:typeSuppression] = false
        @permanenteffects[mon][:LifeBlood][:movesSuppression] = []
        if currBattler
          currBattler.ability = currBattler.backupability
          currBattler.changeType(currBattler.pokemon.type1, currBattler.pokemon.type2)
          pbAnimation(:REFRESH, currBattler, currBattler)
          pbDisplay(_INTL("{1}'s suppression was lifted!", currBattler.pbThis))
        end
      end
    end
    onBreakdata = battler.onBreakEffects[battler.shieldCount]
    pbAnimation(:GEOMANCY, battler, nil)
    analysis = onBreakdata[:partialAnalysis]
    if analysis
      pbShieldEffects(battler, analysis, false)
    end
    if @permanenteffects[battler.pokemon][:analysis][:semiAnalysis].length >= 2
      analysis = onBreakdata[:semiAnalysis]
      if analysis
        pbShieldEffects(battler, analysis, false)
      end
    end
    if @permanenteffects[battler.pokemon][:analysis][:fullAnalysis].length >= 1
      analysis = onBreakdata[:fullAnalysis]
      if analysis
        pbShieldEffects(battler, analysis, false)
      end
    end
  end


  def pbLifeBlood
    priority = setSpeedOrder
    lifebloodBearer = pbFindGlobalAbilityUser(:LIFEBLOOD)
    return false if !lifebloodBearer&.isbossmon
    case $game_variables[:DifficultyModes]
    when 0
      return false if lifebloodBearer.shieldCount < 3
    when 1
      return false if lifebloodBearer.shieldCount < 1
    end
    for mon in priority
      next if mon.isFainted?
      next if mon.ability == :LIFEBLOOD
      advancementAnim = false
      if !mon.permeffs[:LifeBlood]
        mon.permeffs[:LifeBlood] = {
          :turncount => 0,
          :abilitySuppression => false,
          :typeSuppression => false,
          :movesSuppression => [],
          :LifeBloodStage => 0,
        }
      end
      mon.permeffs[:LifeBlood][:turncount] += mon.permeffs[:LifeBlood][:turncount] == 0 ? mon.turncount : 1
      if mon.permeffs[:LifeBlood][:turncount] >= 1 && !mon.permeffs[:LifeBlood][:abilitySuppression]
        pbDisplay(_INTL("{1}'s {2} was suppressed!", mon.pbThis, getAbilityName(mon.ability)))
        mon.permeffs[:LifeBlood][:abilitySuppression] = true
        mon.permeffs[:LifeBlood][:LifeBloodStage] = 1
        mon.changeAbilityWithEffects(:suppress)
        advancementAnim = true
      end
      if mon.permeffs[:LifeBlood][:turncount] >= 3 && !mon.permeffs[:LifeBlood][:typeSuppression]
        mon.permeffs[:LifeBlood][:typeSuppression] = true
        mon.changeType(:QMARKS)
        pbDisplay(_INTL("{1}'s types were suppressed!", mon.pbThis))
        advancementAnim = true
      end
      if mon.permeffs[:LifeBlood][:turncount] >= 6 && mon.turncount > 0
        if mon.permeffs[:LifeBlood][:turncount] >= 6 && !mon.permeffs[:LifeBlood][:movesSuppression].include?(mon.moves[0].move)
          pbDisplay(_INTL("{1}'s {2} was suppressed!", mon.pbThis, getMoveName(mon.moves[0].move)))
          mon.permeffs[:LifeBlood][:movesSuppression].push(mon.moves[0].move)
          mon.permeffs[:LifeBlood][:LifeBloodStage] = 2
        end
        if mon.permeffs[:LifeBlood][:turncount] >= 7 && !mon.permeffs[:LifeBlood][:movesSuppression].include?(mon.moves[1].move)
          pbDisplay(_INTL("{1}'s {2} was suppressed!", mon.pbThis, getMoveName(mon.moves[1].move)))
          mon.permeffs[:LifeBlood][:movesSuppression].push(mon.moves[1].move)
        end
        if mon.permeffs[:LifeBlood][:turncount] >= 8 && !mon.permeffs[:LifeBlood][:movesSuppression].include?(mon.moves[2].move)
          pbDisplay(_INTL("{1}'s {2} was suppressed!", mon.pbThis, getMoveName(mon.moves[2].move)))
          mon.permeffs[:LifeBlood][:movesSuppression].push(mon.moves[2].move)
        end
        if mon.permeffs[:LifeBlood][:turncount] >= 8 && !mon.permeffs[:LifeBlood][:movesSuppression].include?(mon.moves[3].move)
          pbDisplay(_INTL("{1}'s {2} was suppressed!", mon.pbThis, getMoveName(mon.moves[3].move)))
          mon.permeffs[:LifeBlood][:movesSuppression].push(mon.moves[3].move)
          mon.permeffs[:LifeBlood][:LifeBloodStage] = 3
        end
        advancementAnim = true
      end
      pbAnimation(:CONVERSION, mon, nil) if advancementAnim
    end
  end
end

class PokeBattle_Battler
  attr_accessor :bossDelayList
  attr_accessor :endTurn


  def bossImmunityCheck(basemove, user, target)
    immunitylist = target.immunities[:moves]
    return true if immunitylist.include?(basemove.move)
    return false
  end

end

def pbLoadWildBoss(poke, bossdata)
  builder = PokeBattle_Pokemon::PokemonBuilder.new(poke, bossdata: bossdata, source: :boss)
  pokemon = builder.build()
  Events.onBossCreate.trigger(nil, pokemon)
  return pokemon
end

def pbLoadSOSMon(poke, boss)
  builder = PokeBattle_Pokemon::PokemonBuilder.new(poke, boss.name, source: :sos)
  builder.sosmon = true
  pokemon = builder.build()
  return pokemon
end

class BossPokemonDataBox < SpriteWrapper
  attr_reader :battler
  attr_accessor :selected
  attr_reader :animatingHP
  attr_reader :animatingEXP
  attr_reader :appearing
  attr_accessor :shieldCount
  attr_accessor :doublebattle

  def initialize(battler, doublebattle, viewport = nil)
    super(viewport)
    @battler = battler
    @frame = 0
    @showhp = true
    @appearing = false
    @animatingHP = false
    @starthp = 0
    @currenthp = 0
    @endhp = 0
    @doublebattle = doublebattle
    @shieldCount = battler.shieldCount
    @databox = AnimatedBitmap.new("Graphics/Pictures/Battle/boss_bar")
    if battler.barGraphic && battler.barGraphic != ""
      @databox = AnimatedBitmap.new("Graphics/Pictures/Battle/" + battler.barGraphic)
    end
    if doublebattle
      case @battler.index
        when 1
          @spriteX = PBScene::BOSSBOXD1_X
          @spriteY = PBScene::BOSSBOXD1_Y
        when 3
          @spriteX = PBScene::BOSSBOXD2_X
          @spriteY = PBScene::BOSSBOXD2_Y
      end
    else
      @spriteX = PBScene::BOSSBOX_X
      @spriteY = PBScene::BOSSBOX_Y
    end
    @yOffset = 8
    @contents = BitmapWrapper.new(@databox.width, @databox.height + @yOffset)
    self.bitmap = @contents
    self.visible = false
    self.z = 50
    pbSetSmallFont(self.bitmap)
    refresh
  end

  def dispose
    @databox.dispose
    @contents.dispose
    super
  end

  def exp
    return 0
  end

  def hp
    return @animatingHP ? @currenthp : @battler.hp
  end

  def animateHP(oldhp, newhp)
    @starthp = oldhp
    @currenthp = oldhp
    @endhp = newhp
    @animatingHP = true
  end

  def animateEXP(oldexp, newexp)
  end

  def appear
    refresh
    self.visible = true
    self.opacity = 255
    self.x = @spriteX - 320
    self.y = @spriteY
    @appearing = true
  end

  def battlerType(battler)
    typearray = [battler.type1.to_s.upcase]
    typearray.push(battler.type2.to_s.upcase) if battler.type2 && (battler.type2 != battler.type1)
    return typearray
  end

  def refresh
    self.bitmap.clear
    return if !@battler.pokemon

    self.bitmap.blt(0, @yOffset, @databox.bitmap, Rect.new(0, 0, @databox.width, @databox.height))
    base = PBScene::BOXBASE
    shadow = PBScene::BOXSHADOW
    pbSetSystemFont(self.bitmap)
    pokename = @battler.effects[:clearDisguise] ? @battler.battle.pbSwitchInName(@battler.index, @battler.pokemonIndex) : @battler.name
    textpos = [
      ["#{pokename}", 8, @yOffset + 6, false, base, shadow]
    ]
    pbDrawTextPositions(self.bitmap, textpos)

    if @shieldCount > 0
      @hpbar = AnimatedBitmap.new("Graphics/Pictures/Battle/hpbarbossshields")
    else
      @hpbar = AnimatedBitmap.new("Graphics/Pictures/Battle/hpbarboss")
    end
    hpgauge = (@battler.totalhp == 0 || self.hp == 0) ? 0 : [self.hp * PBScene::BOSSHPGAUGE / @battler.totalhp, 2].max.to_grid
    hpzone = getHPZone(self.hp, @battler.totalhp)
    hpGaugeX = PBScene::BOSSHPGAUGE_X
    hpGaugeY = PBScene::BOSSHPGAUGE_Y
    self.bitmap.blt(hpGaugeX , @yOffset + hpGaugeY, @hpbar.bitmap, Rect.new(0, hpzone * 12, hpgauge, 12))
    @shieldsdisplay = AnimatedBitmap.new("Graphics/Pictures/Battle/boss_shieldbar")
    shieldGaugeX = PBScene::SHIELDGAUGE_X
    shieldGaugeY = PBScene::SHIELDGAUGE_Y
    self.bitmap.blt(shieldGaugeX, @yOffset + shieldGaugeY, @shieldsdisplay.bitmap, Rect.new(0, 0, @shieldsdisplay.width, @shieldsdisplay.height))
    shieldX = PBScene::SHIELDS_X # array
    shieldY = PBScene::SHIELDS_Y # array
    @shields = AnimatedBitmap.new("Graphics/Pictures/Battle/bossbarshield")
    if @shieldCount > 0
      count = 0
      loop do
        self.bitmap.blt(shieldGaugeX + shieldX[count], @yOffset + shieldGaugeY + shieldY[count], @shields.bitmap, Rect.new(0, 0, @shields.width, @shields.height))
        count += 1
        break if count == @shieldCount
      end
    end
    battlerTypes = battlerType(battler)
    typepos = []
    typepos.push([sprintf("Graphics/Icons/bosstype%s", battlerTypes[0]), shieldGaugeX + 24, @yOffset + shieldGaugeY + 24, 0, 0, 64, 28])
    if !battler.type2.nil?
      typepos.push([sprintf("Graphics/Icons/bosstype%s", battlerTypes[1]), shieldGaugeX + 44, @yOffset + shieldGaugeY + 24, 0, 0, 64, 28])
    end
    pbDrawImagePositions(self.bitmap, typepos)
    # Crest

    imagepos = []

    namepos = self.bitmap.text_size(pokename).width

    if @battler.status != nil
      doubles = Rejuv ? "D" : ""
      imagepos.push([sprintf("Graphics/Pictures/Battle/BattleStatuses" + doubles + "%s", battler.status), hpGaugeX, @yOffset + hpGaugeY - 2, 0, 0, 64, 28])
      pbDrawImagePositions(self.bitmap, imagepos)
    end
  end

  def update
    super
    @frame += 1
    if @animatingHP
      if @currenthp < @endhp
        @currenthp += [4, (@battler.totalhp.to_f / PBScene::BOSSHPGAUGE).floor].max
        @currenthp = @endhp if @currenthp > @endhp
      elsif @currenthp > @endhp
        @currenthp -= [4, (@battler.totalhp.to_f / PBScene::BOSSHPGAUGE).floor].max
        @currenthp = @endhp if @currenthp < @endhp
      end
      @animatingHP = false if @currenthp == @endhp
      refresh
    end
    if @appearing
      self.x += DATA_BOX_APPEAR_SPEED
      @appearing = false if self.x >= @spriteX
      self.y = @spriteY
      return
    end
    self.x = @spriteX
    self.y = @spriteY
  end
end

class SosPokemonDataBox < SpriteWrapper
  attr_reader :battler
  attr_accessor :selected
  attr_reader :animatingHP
  attr_reader :animatingEXP
  attr_reader :appearing
  attr_accessor :doublebattle

  def initialize(battler, doublebattle, viewport = nil)
    super(viewport)
    @battler = battler
    @frame = 0
    @animatingHP = false
    @starthp = 0
    @currenthp = 0
    @endhp = 0
    @appearing = false
    @doublebattle = doublebattle
    @statuses = AnimatedBitmap.new("Graphics/Pictures/Battle/BattleStatuses")
    @hpbox = Bitmap.new("Graphics/Pictures/Battle/boss_bar")
    if battler.barGraphic && battler.barGraphic != ""
      @hpbox = Bitmap.new("Graphics/Pictures/Battle/" + battler.barGraphic)
    end
    @hpboxX = 0
    @hpboxY = PBScene::SOSHPGAUGE_Y
    case @battler.index
      when 1
        @spriteX = PBScene::SOSBOX1_X
        @spriteY = PBScene::SOSBOX1_Y
      when 3
        @spriteX = PBScene::SOSBOX2_X
        @spriteY = PBScene::SOSBOX2_Y
    end
    @contents = BitmapWrapper.new(@hpbox.width, @hpbox.height)
    self.bitmap = @contents
    self.visible = false
    self.z = 50
    pbSetSmallFont(self.bitmap)


    refresh
  end

  def dispose
    @databox.dispose
    @contents.dispose
    super
  end

  def exp
    return 0
  end

  def hp
    return @animatingHP ? @currenthp : @battler.hp
  end

  def animateHP(oldhp, newhp)
    @starthp = oldhp
    @currenthp = oldhp
    @endhp = newhp
    @animatingHP = true
  end

  def animateEXP(oldexp, newexp)
  end

  def appear
    refresh
    self.visible = true
    self.opacity = 255
    self.x = @spriteX - 320
    self.y = @spriteY
    @appearing = true
  end

  def refresh
    self.bitmap.clear
    return if !@battler.pokemon

    filename = "Graphics/Pictures/Battle/boss_bar_sos"
    @databox = AnimatedBitmap.new(filename)

    self.bitmap.blt(0, 0, @databox.bitmap, Rect.new(0, 0, @databox.width, @databox.height))

    base = PBScene::BOXBASE
    shadow = PBScene::BOXSHADOW
    headerY = 8

    # Pokemon Name
    pokename = @battler.name
    pbSetSmallFont(self.bitmap)

    textpos = [
      [pokename, 6, headerY, false, base, shadow]
    ]

    pbDrawTextPositions(self.bitmap, textpos)
    pbSetSmallFont(self.bitmap)
    # Level
    textpos = []
    imagepos = []
    gendertarget = @battler.effects[:Illusion] ? @battler.effects[:Illusion] : @battler
    genderX = self.bitmap.text_size(pokename).width
    genderX += 10
    if genderX > 165 && !@doublebattle && (@battler.index & 1) == 1 # opposing pokemon
      genderX = 224
    end
    unless gendertarget.isGenderless?
      colors = gendertarget.isMale? ? [Color.new(48, 96, 216), shadow] : [Color.new(248, 88, 40), shadow]
      textpos.push([genderSign(gendertarget.gender), genderX, headerY, false, *colors])
    end
    pbDrawTextPositions(self.bitmap, textpos)
    @hpbar = AnimatedBitmap.new("Graphics/Pictures/Battle/hpbarsos")
    hpgauge = (@battler.totalhp == 0 || self.hp == 0) ? 0 : [self.hp * PBScene::SOSHPGAUGE / @battler.totalhp, 2].max.to_grid
    hpzone = getHPZone(self.hp, @battler.totalhp)
    hpGaugeX = PBScene::SOSHPGAUGE_X
    hpGaugeY = PBScene::SOSHPGAUGE_Y
    self.bitmap.blt(hpGaugeX, hpGaugeY, @hpbar.bitmap, Rect.new(0, hpzone * 12, hpgauge, 12))
    # Crest
    if @battler.crested
      if @battler.fakeCrest
        imagepos.push(["Graphics/Pictures/Battle/battleApplyCrest.png", genderX + 20, headerY, 0, 0, -1, -1])
      else
        imagepos.push(["Graphics/Pictures/Battle/battleCrest.png", genderX + 20, headerY, 0, 0, -1, -1])
      end
    end
    # Status
    if !@battler.status.nil?
      statusX = Rejuv ? hpGaugeX + 2 : hpGaugeX + 128
      statusY = Rejuv ? hpGaugeY - 2 : headerY + 2
      doubles = Rejuv ? "D" : ""
      imagepos.push([sprintf("Graphics/Pictures/Battle/BattleStatuses" + doubles + "%s", @battler.status), statusX, statusY, 0, 0, 64, 28])
    end
    pbDrawImagePositions(self.bitmap, imagepos)
  end

  def update
    super
    @frame += 1
    if @animatingHP
      if @currenthp < @endhp
        @currenthp += [4, (@battler.totalhp.to_f / PBScene::SOSHPGAUGE).floor].max
        @currenthp = @endhp if @currenthp > @endhp
      elsif @currenthp > @endhp
        @currenthp -= [4, (@battler.totalhp.to_f / PBScene::SOSHPGAUGE).floor].max
        @currenthp = @endhp if @currenthp < @endhp
      end
      @animatingHP = false if @currenthp == @endhp
      refresh
    end
    if @appearing
      self.x += DATA_BOX_APPEAR_SPEED
      @appearing = false if self.x >= @spriteX
      self.y = @spriteY
      return
    end
    self.x = @spriteX
    self.y = @spriteY
  end
end

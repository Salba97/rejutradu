class PokeBattle_Battle
  attr_accessor :zettacounter

  OPPONENTMAXPARTYSIZE = 24  # like 50% more than we actually need, but just in case
  # btw alex, azery, jan... if you need more than THIS then we need to have a talk

  def pbCrestEffects(index, pokemon)

    return if !@battlers[index].crested
    pbCrestEntry(index, pokemon)
    battler = @battlers[index]

    case battler.crested
      when :CASTFORM
        weathermoves = battler.moves.find { |move| [:SUNNYDAY, :RAINDANCE, :SANDSTORM, :HAIL, :SNOWSCAPE].include?(move.move) }
        return if weathermoves.nil?

        weather = weathermoves.move
        weather = :SNOW if weather == :SNOWSCAPE
        return if !canSetWeather?(weather)

        case weather
          when :SUNNYDAY then duration = [:DESERT, :MOUNTAIN, :SNOWYMOUNTAIN, :SKY].include?(@field.effect) ? 8 : 5
          when :RAINDANCE then duration = [:CLOUDS, :SKY].include?(@field.effect) ? 8 : 5
          when :SANDSTORM then duration = [:DESERT, :ASHENBEACH, :SKY].include?(@field.effect) ? 8 : 5
          when :HAIL, :SNOW then duration = [:ICY, :SNOWYMOUNTAIN, :FROZENDIMENSION, :SKY, :CLOUDS].include?(@field.effect) ? 8 : 5
        end
        duration = -1 if $game_switches[:Gen_5_Weather] == true
        pbShowAbilityBox(battler, item: true)
        pbSetWeather(weather, duration)
        pbHideAbilityBox(battler)
      when :THIEVUL
        for i in [battler.pbOpposing1, battler.pbOpposing2]
          next unless i.passiveAbilityApplies?

          pbShowAbilityBox(battler, item: true)
          i.pbChangeStats(PBStats::SPATK, -1, battler, :Intimidate)
        end
        if battler.pbCanIncreaseStatStage?(PBStats::SPATK, battler, nil)
          pbShowAbilityBox(battler, item: true)
          battler.pbChangeStats(PBStats::SPATK, 1, battler, nil, abilitycheck: :skip)
        end
        pbHideAbilityBox(battler)
      when :PROBOPASS
        pbShowAbilityBox(battler, item: true)
        battler.effects[:MagnetRise] = 8
        pbAnimation(:MAGNETRISE, battler, nil) # Magnet Rise animation
        pbDisplay(_INTL("¡{1} levitó gracias al electromagnetismo!", battler.pbThis))
        pbHideAbilityBox(battler)
      when :PHIONE
        pbShowAbilityBox(battler, item: true)
        battler.effects[:AquaRing] = true
        pbAnimation(:AQUARING, battler, nil) # Aqua Ring animation
        pbHideAbilityBox(battler)
      when :VESPIQUEN
        pbShowAbilityBox(battler, item: true)
        battler.effects[:VespiCrest] = true
        battler.pbChangeStats(PBStats::Offensive, 1, battler, nil, abilitycheck: :hide)
        pbHideAbilityBox(battler)
      when :ZANGOOSE
        if battler.status != :POISON
          pbShowAbilityBox(battler, item: true)
          battler.pbPoison(battler, true, message: _INTL("¡{1} ha sido envenenado por su {2}!", battler.pbThis, getItemName(battler.item)))
          pbHideAbilityBox(battler)
        end
    end
  end

  def pbCrestEntry(index, pokemon)
    battler = @battlers[index]
    trainer = pbGetOwner(index)
    case battler.crested
      when :FURRET
        pbShowAbilityBox(battler, item: true)
        sublife = [(battler.totalhp / 4.0).floor, 1].max
        if battler.hp <= sublife
          pbDisplay(_INTL("¡Estaba demasiado débil para crear un sustituto!"))
          pbHideAbilityBox(battler)
          return -1
        end
        battler.pbReduceHP(sublife, false, false) # late message
        pbPlaySubstituteAnimation(battler)
        battler.effects[:Substitute] = sublife
        pbDisplay(_INTL("¡{1} creó un sustituto!", battler.pbThis))
        pbHideAbilityBox(battler)
      when :SILVALLY
        newability = PBStuff::SILVALLYCRESTABILITIES.keys.include?(battler.item) ? PBStuff::SILVALLYCRESTABILITIES[battler.item] : :SCRAPPY
        pbShowAbilityBox(battler, attrname: getItemName(:SILVCREST), crest: true)
        pbDisplay(_INTL("¡{1} obtuvo {2}!", battler.pbThis, getAbilityName(newability)))
        pbHideAbilityBox(battler)
      when :SUICUNE
        pbShowAbilityBox(battler, item: true)
        pbAnimation(:TAILWIND, battler, nil)
        pbDisplay(_INTL("¡{1} levantó un Viento Afín de corta duración!", battler.pbThis))
        if battler.pbOwnSide.effects[:Tailwind] == 0
          pbSetTailwind(1, battler.pbOwnSide)
        else
          pbSetTailwind(battler.pbOwnSide.effects[:Tailwind] + 1, battler.pbOwnSide)
        end
        pbHideAbilityBox(battler)
      when :DELCATTY
        if battler.effects[:clearDisguise] != nil
          pbShowAbilityBox(battler, attrname: getAbilityName(:PROTOSYNTHESIS))
          pbDisplay(_INTL("¡{1} usó su Energía Potenciadora para activar {3} y aumentar su {4}!", battler.pbThis, getItemName(battler.item), getAbilityName(:PROTOSYNTHESIS), getStatName(PBStats::SPEED)))
          pbHideAbilityBox(battler)
        else
          msg = _INTL("¡{1} obtuvo fuerza gracias al poder de la amistad!", battler.pbThis)
          if battler.fakeCrest
            attrmsg = trainer.name == "M2" ? _INTL("Arquetipo de M2") : _INTL("aura")
            pbAbilityBoxAndDisplay(battler, msg, attrname: attrmsg)
          else
            pbAbilityBoxAndDisplay(battler, msg, item: true)
          end
        end
      when :PANGORO
        pbAbilityBoxAndDisplay(battler, _INTL("¡{1} está irradiando un aura oscura!", battler.pbThis), item: true)
      when :REUNICLUS
        if battler.moves[0].pbIsPhysical?(battler)
          pbShowAbilityBox(battler, item: true)
          battler.attack, battler.spatk = battler.spatk, battler.attack # @type1 == :FIGHTING
          battler.type1 = :FIGHTING
          pbDisplay(_INTL("¡El tipo de {1} ha cambiado a {2}!", battler.pbThis, getTypeName(battler.type1)))
          pbHideAbilityBox(battler)
        end
      when :SHIINOTIC
        if battler.pbPartner.hp > 0
          pbShowAbilityBox(battler, item: true)
          pbAnimation(:SPOTLIGHT, battler, battler.pbPartner)
          pbDisplay(_INTL("¡El brillo de {1} ha puesto a su compañero bajo los focos!", battler.pbThis))
          battler.pbPartner.effects[:FollowMe] = true
          pbHideAbilityBox(battler)
        end
    end
  end

  def partyNameOverwrite(party, newpoke)
    @zettacounter = 0 if @zettacounter.nil?
    if party[newpoke].name == getMonName(party[newpoke].species, party[newpoke].form) && @zettacounter < 4
      zettaNames = ["Do", "Not", "Forget", "About"]
      @zettacounter = 0 if @zettacounter.nil?
      party[newpoke].name = zettaNames[@zettacounter]
      @zettacounter += 1
    end
  end

  # behold war crime central, these 2 methods are evil and probably messy, but given the result i couldn't care less this is awesome - Fal
  def battlesnapshot(battler, snapshotindex = 0, uselimit = -1)
    @snapshot = [] if @snapshot.nil?
    return if !@snapshot[snapshotindex].nil?

    battledata = {:battle => self.pbCopyToBattleState}

    for ivar_name in [:@opponent, :@player, :@ai, :@turncount]
      battledata[:battle].remove_instance_variable(ivar_name)
    end
    if [:attackPhase, :endOfRoundPhase].include?(@phase)
      savedBossBattler = battledata[:battle].battlers[battler.index]
      if @phase == :attackPhase && savedBossBattler.lastHPLost > 0
        savedBossBattler.hp = savedBossBattler.lastHPLost
        savedBossBattler.pokemon.hp= savedBossBattler.lastHPLost
      else
        savedBossBattler.hp = savedBossBattler.totalhp / 4
        savedBossBattler.pokemon.hp= savedBossBattler.totalhp / 4
      end
    end

    # clear fainted SoS battler objects and revert battle to singles state if applicable
    # this is necessary to avoid issues with fainted SoS battles being restored and fainting again which cause problems with tbe boss party
    battledata[:battle].battlers.each_with_index { |battler, i|
      if battler.issosmon && battler.isFainted?
        battledata[:battle].battlers[i] = PokeBattle_Battler.new(self, i)
      end
    }
    if battledata[:battle].sosbattle == :singlePokemonPlayerSide
      if battledata[:battle].battlers.none? { |battler| battler.issosmon}
        battledata[:battle].sosbattle = :none
        battledata[:battle].doublebattle = false
      end
    end
    battledata[:Trainerbag] = $PokemonBag.deep_clone
    battledata[:snapshotUses] = uselimit
    pbAnimation(:FUTURESIGHT, battler, nil)
    @snapshot[snapshotindex] = battledata
  end

  def timewarp(battler, snapshotindex = 0)
    return if @snapshot.nil?
    return if snapshotindex >= @snapshot.length
    saveload = @snapshot[snapshotindex]
    return if saveload.nil?
    return if saveload[:snapshotUses] == 0

    namespace = {saveload[:battle].object_id => @battle}

    pbAnimation(:ROAROFTIME, battler, nil)
    hideBattleUI
    # we are overwritting the attributes of the existing pokemon instead of replacing them with copies so that the same pokemon object persists
    # this is important for certain battle references like battlers, UI, future sight user, sticky web user, etc.
    # this also allows to only have to do this replacement once for the player team because otherwise we would have to ensure that
    # $Trainer.party and @battle.party1 (the player part of it) reference the same objects
    for partyindex in 0...@party1.length
      @party1[partyindex].each_with_index do |mon, i|
        saved = saveload[:battle].party1[partyindex][i]
        namespace[saved.object_id] = mon
        mon.instance_variables.each do |ivar_name|
          mon.instance_variable_set(ivar_name, saved.instance_variable_get(ivar_name).deep_clone(namespace))
        end
        mon.calcStats
        mon.initZmoves(true)
      end
    end
    for partyindex in 0...@party2.length
      @party2[partyindex].each_with_index do |mon, i|
        saved = saveload[:battle].party2[partyindex][i]
        if !saved
          @party2[partyindex].delete(mon)
          next
        end
        namespace[saved.object_id] = mon
        mon.instance_variables.each do |ivar_name|
          mon.instance_variable_set(ivar_name, saved.instance_variable_get(ivar_name).deep_clone(namespace))
        end
        mon.calcStats
        mon.initZmoves(true)
      end
      # add SoS mons back that were called in the old battlestate but defeated since
      if @party2[partyindex].length < saveload[:battle].party2[partyindex].length
        for index in 0...saveload[:battle].party2[partyindex].length
          @party2[partyindex].push(saveload[:battle].party2[partyindex][index].deep_clone(namespace)) if saveload[:battle].party2[partyindex][index].sosmon
        end
      end
    end
    # remove SoS pokemon that weren't called yet in the old battle state
    if @sosbattle != :none && saveload[:battle].sosbattle == :none
      for i in 0...@battlers.length
        if @battlers[i].issosmon
          removeBattlerScene(i)
          @party2[@battle.pbGetOwnerIndex(i)].delete_at(@battlers[i].pokemonIndex)
          @battlers[i] = PokeBattle_Battler.new(self, i)
        end
      end
    end
    $PokemonBag = saveload[:Trainerbag].deep_clone(namespace)
    # put aside the defaultproc of permanent effects, we need to restore it later
    permeffectsproc = @permanenteffects.default_proc
    # apply all saved battle keys to the current battle
    saveload[:battle].instance_variables.each do |ivar_name|
      next if [:@party1, :@party2].include?(ivar_name)
      self.instance_variable_set(ivar_name, saveload[:battle].instance_variable_get(ivar_name).deep_clone(namespace))
    end
    # restore defaultproc
    @permanenteffects.default_proc = permeffectsproc
    pbChangeBGSprite
    # restablish battler state
    for battler in saveload[:battle].battlers
      next if battler.nil? || battler.pokemonIndex == -1
      i = battler.index
      @scene.pbChangePokemon(@battlers[i], @battlers[i].pokemon)
    end
    # reset the move and speed order to reflect the restored battle state
    self.setMoveOrder
    self.setSpeedOrder
    for i in 0...@battlers.length
      next if @battlers[i].pokemonIndex == -1

      showBattlerUI(i)
      if @battlers[i].isbossmon
        @scene.pbUpdateShield(@battlers[i].shieldCount, @battlers[i].index)
      end
    end
    @scene.sprites["fightwindow"].battler = @battlers[0] if @scene.sprites
    for i in 0...@battlers.length
      next if @battlers[i].pokemon.nil?

      if @battlers[i].isFainted?
        @battlers[i].fainted = false
        @battlers[i].pbFaint
      end
    end
    pbReplaceFaintedBattlers
    saveload[:snapshotUses] -= 1 if saveload[:snapshotUses] > 0
  end

  # the following 3 methods are extracted sections of timewarp relating to the battle UI
  # these are moved for the benefit of the testenviroment so they can be dummied out
  def hideBattleUI
    for i in 0...@battlers.length
      next if @scene.sprites["battlebox#{i}"].nil?

      8.times do
        @scene.sprites["battlebox#{i}"].opacity -= 32
        @scene.pbGraphicsUpdate
        Input.update
      end
      @scene.sprites["battlebox#{i}"].visible = false
      @scene.sprites["battlebox#{i}"].dispose if !@battlers[i].pokemon.nil?
      @scene.pbGraphicsUpdate
    end
  end

  def removeBattlerScene(battlerindex)
    @scene.sprites["battlebox#{battlerindex}"] =
      @scene.createPokemonDataBox(@battlers[battlerindex], @doublebattle, @scene.viewport, self)
    @scene.sprites["shadow#{battlerindex}"].visible = false
    @scene.sprites["pokemon#{battlerindex}"].visible = false
    @scene.sprites["battlebox#{battlerindex}"].visible = false
  end

  def showBattlerUI(battlerindex)
    doubles = battlerindex.even? && @sosbattle == :singlePokemonPlayerSide ? false : @doublebattle
    @scene.sprites["battlebox#{battlerindex}"] = @scene.createPokemonDataBox(@battlers[battlerindex], doubles, @scene.viewport, self)
    @scene.sprites["battlebox#{battlerindex}"].appear
    loop do
      @scene.sprites["battlebox#{battlerindex}"].update
      @scene.pbGraphicsUpdate
      Input.update
      break if !@scene.sprites["battlebox#{battlerindex}"].appearing
    end
    @battle.scene.pbUnVanishSprite(@battlers[battlerindex]) if !@scene.sprites["pokemon#{battlerindex}"].visible
  end

  def fakeOutBattleEnd
    return if @opponent
    return if !@party2[0][0].isbossmon
    return if !$cache.bosses[@party2[0][0].bossID].onBreakEffects
    return if !$cache.bosses[@party2[0][0].bossID].onBreakEffects[0]
    return if @snapshot[1][:snapshotUses] == 0

    bossname = $cache.bosses[@party2[0][0].bossID].name
    @scene.pbBossBattleSuccess([bossname])
    pbDisplayPaused(_INTL("¡{1} ha derrotado a\n{2}!", self.pbPlayer.name, bossname))
    @scene.sprites["pokemon1"].y = -4
    pbShieldEffects(@battlers[1], $cache.bosses[@party2[0][0].bossID].onBreakEffects[0])
    @battlers[1].currentSOS = 0
    for i in 0...4
      sosmon = @battlers[i] if @battlers[i].issosmon
    end
    if sosmon
      pbResetBattlers(true)
    end
    @decision = 0
    pbDisplayPaused(_INTL("TIEMPA: La libertad de decidir tu propio destino tiene dos caras..."))
    pbDisplayPaused(_INTL("Un solo error y podrías perderlo todo."))
    pbDisplayPaused(_INTL("¿Veamos cuántas veces puedes evitar tu fracaso?"))
    pbDisplayPaused(_INTL("¡¡Podemos intentarlo tantas veces como HAGA FALTA!!"))
  end

  def useMegaLimit
    # Just in case Rejuvenation ever adds online battles.
    return true if isOnline?
    # Currently unused and turned off by save conversion.
    return false if $game_switches[:No_Mega_Limit]
    # Disable mega limit in Mt. Ruin (Percival's Jurisdiction effect).
    # Intentionally applies to players as well.
    return false if currentJurisdiction? == :PERCIVAL
    return true
  end
end
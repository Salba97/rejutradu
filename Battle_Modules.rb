# Results of battle:
#    0 - Undecided or aborted
#    1 - Player won
#    2 - Player lost
#    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#    4 - Wild Pokémon was caught
#    5 - Draw

################################################################################
# Success State.
################################################################################
class PokeBattle_SuccessState
  attr_accessor :typemod
  attr_accessor :useState # 0 - not used, 1 - failed, 2 - succeeded
  attr_accessor :protected
  attr_accessor :skill # Used in Battle Arena

  def initialize
    clear
  end

  def clear
    @typemod = Typemod.normal
    @useState = 0
    @protected = false
    @skill = 0
  end

  def updateSkill
    if @useState == 1 && !@protected
      @skill -= 2
    elsif @useState == 2
      if @typemod.superEffective?
        @skill += 2 # "Super effective"
      elsif @typemod.resisted?
        @skill -= 1 # "Not very effective"
      elsif @typemod.immune?
        @skill -= 2 # Ineffective
      else
        @skill += 1
      end
    end
    @typemod = Typemod.normal
    @useState = 0
    @protected = false
  end
end

################################################################################
# Catching and storing Pokémon.
################################################################################
module PokeBattle_BattleCommon
  def pbBattleStorePokemon(pokemon)
    if !(pokemon.isShadow? rescue false) && $Settings.nicknames == 0
      if pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?", pokemon.name))
        species = getMonName(pokemon.species, pokemon.form)
        nickname = @scene.pbNameEntry(_INTL("{1}'s nickname?", species), pokemon)
        pokemon.name = nickname if nickname != ""
      end
    end
    oldcurbox = $PokemonStorage.pbDefaultBox
    storedbox = pbBattleStorePokemonCore(pokemon)

    return if !storedbox # Pokemon couldn't be added to party or PC

    pokemon.changeFormOnBattleEnd

    # This needs to be run after changeFormOnBattleEnd to register any form the pokemon reverts to
    # The form of the pokemon when catching has been registered in pbThrowPokeball
    $Trainer.pokedex.setOwned(pokemon)

    return if storedbox < 0

    creator = pbGetStorageCreator(true)
    curboxname = $PokemonStorage[oldcurbox].name
    boxname = $PokemonStorage[storedbox].name
    if storedbox != oldcurbox
      pbDisplayPaused(_INTL("Box \"{1}\" on {2}'s PC was full.", curboxname, creator))
      pbDisplayPaused(_INTL("{1} was transferred to box \"{2}\".", pokemon.name, boxname))
    else
      pbDisplayPaused(_INTL("{1} was transferred to {2}'s PC.", pokemon.name, creator))
      pbDisplayPaused(_INTL("It was stored in box \"{1}\".", boxname))
    end
  end

  def pbBallFetch(pokeball)
    @ballToFetch = pokeball
  end

  def pbThrowPokeBall(idxPokemon, ball, rareness = nil, showplayer = false)
    targetindex = @scene.pbChooseBallTarget(idxPokemon)
    return false if targetindex == -1 # Cancelled

    battler = @battlers[targetindex]
    pbDisplayBrief(_INTL("{1} threw {2}!", pbPlayer.name, getItemName(ball, :a)))
    $PokemonBag.defaultBall = ball # Change default poke ball

    if !pbCanCatch?(battler)
      @scene.pbThrowAndDeflect(ball, 1)
      if pbIsWild? || $game_switches[:No_Catching]
        # This switch is also turned on for trainer battles where the 'trainer' is a pokemon, eg, anomalies
        pbDisplay(_INTL("The Pokémon knocked the ball away!"))
      else
        pbDisplay(_INTL("The Trainer blocked your Poké Ball!\nDon't be a thief!"))
      end
      pbBallFetch(ball)
      return true
    end

    oldform = battler.form
    battler.form = battler.pokemon.getForm
    pokemon = battler.pokemon

    rareness = pokemon.getCatchRate if !rareness
    rareness /= 2 if $game_variables[:LuckMoves] != 0 && Rejuv
    a = battler.totalhp
    b = battler.hp
    rareness = BallHandlers.modifyCatchRate(ball, rareness, self, battler)
    rareness += 1 if $PokemonBag.pbQuantity(:CATCHINGCHARM) > 0
    rareness += 1 if Reborn && $PokemonBag.pbQuantity(:CATCHINGCHARM2) > 0
    rareness += 1 if Reborn && $PokemonBag.pbQuantity(:CATCHINGCHARM3) > 0
    rareness += 1 if Reborn && $PokemonBag.pbQuantity(:CATCHINGCHARM4) > 0
    if battler.isbossmon && battler.capturable && battler.shieldCount == 0
      rareness += 3
    end

    x = ((a * 3 - b * 2) * rareness) / (a * 3)
    if battler.status == :SLEEP || battler.status == :FROZEN
      x = x * 2.5
    elsif !battler.status.nil?
      x = x * 3 / 2
    end

    # Critical Capture chances based on caught species'
    c = 0
    if $Trainer
      mod = -3
      mod += 0.5 if $Trainer.pokedex.getOwnedCount > 500
      mod += 0.5 if $Trainer.pokedex.getOwnedCount > 400
      mod += 0.5 if $Trainer.pokedex.getOwnedCount > 300
      mod += 0.5 if $Trainer.pokedex.getOwnedCount > 200
      mod += 0.5 if $Trainer.pokedex.getOwnedCount > 100
      mod += 0.5 if $Trainer.pokedex.getOwnedCount > 30
      c = (x * (2**mod)).floor
    end

    shakes = 0; critical = false; critsuccess = false
    if x > 255 || BallHandlers.isUnconditional?(ball, self, battler)
      shakes = 4
    else
      x = 1 if x == 0
      y = (65536 / ((255.0 / x)**0.1875)).floor
      puts "c = #{c}; x = #{x}"
      percentage = (1 / ((255.0 / x)**0.1875))**4
      puts "Catch chance: #{percentage * 100}%"
      percentage = c / 256.0 * (1 / ((255.0 / x)**0.1875))
      puts "Crit chance: #{percentage * 100}%"
      if pbRandom(256) < c
        critical = true
        if pbRandom(65536) < y
          critsuccess = true
          shakes = 4
        end
      else
        shakes += 1 if pbRandom(65536) < y
        shakes += 1 if pbRandom(65536) < y
        shakes += 1 if pbRandom(65536) < y
        shakes += 1 if pbRandom(65536) < y
      end
    end
    shakes = 4 if ball == :PREMIERBALL && shakes >= 3

    if $DEBUG && Input.press?(Input::CTRL)
      shakes = 4
      critsuccess = true if critical
    end

    @scene.pbThrow(ball, critical ? 1 : shakes, critical, critsuccess, battler.index, showplayer)

    case shakes
      when 0, 1, 2, 3
        message = [
          _INTL("Oh no! The Pokémon broke free!"),
          _INTL("Aww... It appeared to be caught!"),
          _INTL("Aargh! Almost had it!"),
          _INTL("Shoot! It was so close, too!"),
        ][shakes]
        pbDisplay(message)
        BallHandlers.onFailCatch(ball, self, pokemon)
        pbBallFetch(ball)
        battler.form = oldform
      when 4
        @scene.pbWildBattleSuccess if pbIsWild? && battler.pbPartner.isFainted?
        pbDisplayPaused(_INTL("Gotcha! {1} was caught!", pokemon.name))
        @scene.pbThrowSuccess



        ownedbefore = $Trainer.pokedex.meaningful_owned?(pokemon.species, pokemon.form)
        # This needs to be run before leaveField to register the current form of the pokemon
        # Any form the pokemon reverts to will be registered in pbBattleStorePokemon
        $Trainer.pokedex.setOwned(pokemon)

        if pbIsWild? && !ownedbefore && !pokemon.getCacheData.checkFlag?(:ExcludeDex) && $Trainer.pokedex.canViewDex
          pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.", pokemon.name))
          @scene.pbShowPokedex(pokemon.species, pokemon.form, pokemon.gender)
        end

        16.times do
          @scene.sprites["battlebox#{battler.index}"].opacity -= 16 # Battler databox
          @scene.sprites["capture"].opacity -= 16 if @scene.sprites["capture"] # Poke Ball that the Pokemon was caught in
          @scene.pbGraphicsUpdate
        end

        battler.leaveField

        if !pbIsWild?
          pbRemoveFromParty(battler.index, battler.pokemonIndex)
          # Snagged shadow mons apparently use player as OT in canon
          owner = !Reborn && battler.isShadow? ? pbPlayer : pbGetOwner(battler.index)
          battler.pbReset
          battler.participants = []
          if !(Rejuv && pokemon.trainerID < 65536) # deliberatly placed metadata
            pokemon.ot = owner.name
            pokemon.trainerID = owner.id
          end
          pokemon.slidein = false # the pokemon is in a poke ball now, no reason to force slidein
          pokemon.obtainMode = 5 # snagged
        else
          @decision = 4 unless !battler.pbPartner.isFainted?
          pokemon.obtainMode = 3 # caught
        end

        BallHandlers.onCatch(ball, self, pokemon)

        if pokemon.item == :BLKPRISM
          $PokemonBag.pbStoreItem(pokemon.item)
          pokemon.setItem(nil)
          battler.permeffs[:ItemToKeep] = nil
          incrementBlackPrisms(1)
          pbDisplayPaused(_INTL("{1}'s Black Prism was deposited into the bag.", pokemon.name))
        end

        pokemon.ballused = ball
        pokemon.pbRecordFirstMoves
        pokemon.form = pokemon.getForm
        addFusion(pokemon)
        pokemon.removeBattleOnlyAttributes

        pbGainEXP

        if !pbIsWild?
          pokemon.pbUpdateShadowMoves
          if $game_switches[:Eizen_Shadow_Capture]
            if self.pbPlayer.party.length < 6 && !PokemonSelection.hasSavedTeam?
              pbBattleStorePokemon(pokemon)
            else
              @snaggedpokemon.push(pokemon)
            end
          else
            @snaggedpokemon.push(pokemon)
          end
          @scene.partyBetweenKO1 unless @battle.doublebattle
        else
          @caughtpokemon.push(pokemon)
          pbBattleStorePokemon(pokemon)
        end
    end
    return true
  end

  def pbCanCatch?(target)
    return false if isOnline?
    return false if target.issosmon
    return false if target.isbossmon && (!pbIsWild? || !target.capturable || target.shieldCount > 0)
    if pbIsWild?
      return true unless $game_switches[:No_Catching]
    else
      # "yoink" password only allows one snag per battle
      return true if $game_switches[:SnagMachine_Password] && @snaggedpokemon == [] &&
                    !target.getCacheData.checkFlag?(:ExcludeDex) &&
                    target.ev.all? { |ev| ev <= 252 }
      return true if $PokemonGlobal.snagMachine && target.isShadow?
    end
    return false
  end

  def pbCanThrowDefaultBall?(index)
    return false if Desolation # Disabling for Desolation till graphic is made
    ball = $PokemonBag.defaultBall
    return false unless ball
    return false if !ItemHandlers.checkUseInBattle(ball, @battlers[index], nil) # Can't throw a poke ball
    return false if [@battlers[index].pbOpposing1, @battlers[index].pbOpposing2].all? { |target|
      target.isFainted? || target.isSemiInvul? || !pbCanCatch?(target)
    } # Can throw a poke ball but it will be deflected
    return true
  end

  def addFusion(pokemon)
    fusion = nil
    fusion = :RESHIRAM if pokemon.species == :KYUREM && pokemon.form == 1
    fusion = :ZEKROM if pokemon.species == :KYUREM && pokemon.form == 2
    fusion = :SOLGALEO if pokemon.species == :NECROZMA && pokemon.form == 1
    fusion = :LUNALA if pokemon.species == :NECROZMA && pokemon.form == 2
    fusion = :GLASTRIER if pokemon.species == :CALYREX && pokemon.form == 1
    fusion = :SPECTRIER if pokemon.species == :CALYREX && pokemon.form == 2
    fusion = :SOLROCK if Rejuv && pokemon.species == :LUNATONE && pokemon.form == 1
    fusion = :LUNATONE if Rejuv && pokemon.species == :SOLROCK && pokemon.form == 1
    return unless fusion

    pokemon.fused = PokeBattle_Pokemon.new(fusion, pokemon.level)
    pokemon.fused.ot = pokemon.ot
    pokemon.fused.trainerID = pokemon.trainerID
  end

  def pbBattleStorePokemonCore(pokemon)
    player = self.pbPlayer
    if player.party.length < 6 && !PokemonSelection.hasSavedTeam?
      player.party[player.party.length] = pokemon
      return -1
    end
    while true
      if !PokemonSelection.hasSavedTeam? && pbDisplayConfirmSerious(_INTL("The party is full; do you want to send a party member to the PC?"))
        iMon = -2
        unusablecount = 0
        for i in $Trainer.party
          next if i.isEgg?
          next if i.hp < 1

          unusablecount += 1
        end
        pbFadeOutIn(99999) {
          scene = PokemonScreen_Scene.new
          screen = PokemonScreen.new(scene, player.party)
          screen.pbStartScene(_INTL("Choose a Pokémon."))
          loop do
            iMon = screen.pbChoosePokemon
            if iMon < 0
              screen.pbEndScene
              break
            end
            pkmn = $Trainer.party[iMon]
            if iMon >= 0 && pbHasImportantFieldMove?(iMon) && (Rejuv && !$game_switches[:AngelicaTower])
              if Rejuv
                scene.pbDisplay(_INTL("You can't return a Pokémon that knows a HM move to the PC."))
              else
                scene.pbDisplay(_INTL("You can't return a Pokémon that knows a TMX move to the PC."))
              end
              iMon = -2
            elsif unusablecount <= 1 && !pkmn.isEgg? && pkmn.hp > 0 && pokemon.isEgg?
              scene.pbDisplay(_INTL("That's your last Pokémon!"))
            else
              if Rejuv && $game_switches[:AngelicaTower] && pkmn.item
                scene.pbDisplay(_INTL("{1}'s {2} was deposited into the bag.", pkmn.name, getItemName(pkmn.item)))
                $PokemonBag.pbStoreItem(pkmn.item)
                pkmn.item = nil
              end
              if pkmn.item && !pbIsZCrystal?(pkmn.item)
                if scene.pbDisplayConfirm(_INTL("This Pokémon is holding {1}. Do you want to remove it?", getItemName(pkmn.item, :a)))
                  scene.pbDisplay(_INTL("Received {1} from {2}.", getItemName(pkmn.item, :the), pkmn.name))
                  $PokemonBag.pbStoreItem(pkmn.item)
                  pkmn.item = nil
                end
              end
              screen.pbEndScene
              break
            end
          end
        }
        if iMon >= 0
          iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
          if iBox >= 0
            player.party[iMon].heal
            pbDisplay(_INTL("{1} was sent to {2}.", player.party[iMon].name, $PokemonStorage[iBox].name))
            player.party[iMon] = nil
            player.party.compact!
            player.party[player.party.length] = pokemon
            return -1
          else
            pbDisplay(_INTL("No space left in the PC..."))
            return false
          end
        end
      else
        pokemon.heal
        oldcurbox = $PokemonStorage.pbDefaultBox
        storedbox = $PokemonStorage.pbStoreCaught(pokemon)
        if storedbox < 0
          pbDisplay(_INTL("Can't catch any more..."))
          return oldcurbox
        else
          return storedbox
        end
      end
    end
  end
end

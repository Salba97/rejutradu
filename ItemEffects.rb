#===============================================================================
# This script implements items included by default in Pokemon Essentials.
#===============================================================================

#===============================================================================
# UseFromBag handlers
# Return values: nil = not used ("next" without a value is equivalent to "next nil")
#                0   = go to pokemon screen to use
#                1   = used, item not consumed
#                2   = close the Bag to use, item not consumed
#                3   = used, item consumed
#                4   = close the Bag to use, item consumed
#===============================================================================

def pbRepel(item, steps)
  if Desolation
    return nil
  elsif $PokemonGlobal.repel > 0
    Kernel.pbMessage(_INTL("The effects of the previous Repel still linger!"))
    return nil
  else
    Kernel.pbMessage(_INTL("{1} used {2}.", $Trainer.name, getItemName(item, :the)))
    $PokemonGlobal.repel = steps
    return 3
  end
end

def pbNecrozmaMoves(pokemon)
  form = pokemon.form
  return if form == 3

  moves = [
    :SUNSTEELSTRIKE,  # Dusk Mane
    :MOONGEISTBEAM    # Dawn Wings
  ]
  moves.each { |move|
    pbDeleteMoveByID(pokemon, move, false)
  }
  pbTryLearnMove(pokemon, moves[form - 1]) if form > 0
  pokemon.pbLearnMove(:CONFUSION) if pokemon.moves.empty?
end

def pbKyuremMoves(pokemon)
  form = pokemon.form
  icemoves = [
    :GLACIATE,        # Normal
    :ICEBURN,         # White
    :FREEZESHOCK      # Black
  ]
  fusionmoves = [
    :SCARYFACE,       # Normal
    :FUSIONFLARE,     # White
    :FUSIONBOLT       # Black
  ]
  for i in 0...pokemon.moves.length
    if icemoves.include?(pokemon.moves[i].move)
      pokemon.pbLearnMoveAtIndex(icemoves[form], i)
    end
    if fusionmoves.include?(pokemon.moves[i].move)
      pokemon.pbLearnMoveAtIndex(fusionmoves[form], i)
    end
  end
end

def pbHoopaMoves(pokemon)
  for i in 0...pokemon.moves.length
    if pokemon.form == 1 && pokemon.moves[i].move == :HYPERSPACEHOLE
      pokemon.pbLearnMoveAtIndex(:HYPERSPACEFURY, i)
    end
    if pokemon.form == 0 && pokemon.moves[i].move == :HYPERSPACEFURY
      pokemon.pbLearnMoveAtIndex(:HYPERSPACEHOLE, i)
    end
  end
end

if !Desolation
  ItemHandlers::UseFromBag.add(:REPEL, proc { |item| pbRepel(item, 200) })

  ItemHandlers::UseFromBag.add(:SUPERREPEL, proc { |item| pbRepel(item, 400) })

  ItemHandlers::UseFromBag.add(:MAXREPEL, proc { |item| pbRepel(item, 500) })
end

if Reborn
  def rainbowScent
    firstline = !$game_switches[:FirstUse] || $game_variables[:EncounterRateModifier] == 1 ?
      _INTL("The Rainbow Scent is not active.") :
      _INTL("The Rainbow Scent is set to {1}%.", ($game_variables[:EncounterRateModifier] * 100).round)
    selection = Kernel.pbMessage(
      firstline + "\n" + _INTL("Would you like to change it?"),
      [
        _INTL("0%"),
        _INTL("10%"),
        _INTL("25%"),
        _INTL("50%"),
        _INTL("100%"),
        _INTL("10000%"),
        _INTL("Cancel"),
      ],
      -1
    )
    case selection
      when 0 then $game_variables[:EncounterRateModifier] = 0
      when 1 then $game_variables[:EncounterRateModifier] = 0.1
      when 2 then $game_variables[:EncounterRateModifier] = 0.25
      when 3 then $game_variables[:EncounterRateModifier] = 0.5
      when 4 then $game_variables[:EncounterRateModifier] = 1
      when 5 then $game_variables[:EncounterRateModifier] = 100
      else return
    end
    chance = $game_variables[:EncounterRateModifier]
    Kernel.pbMessage(_INTL("The Rainbow Scent has been set to {1}%.\nWild Pokémon will appear {2}x as often.", (chance * 100).round, chance))
    $game_switches[:FirstUse] = true
  end

  ItemHandlers::UseFromBag.add(:RAINBOWSCENT, proc { |item|
    rainbowScent
  })

  ItemHandlers::UseInField.add(:RAINBOWSCENT, proc { |item|
    rainbowScent
  })
end

Events.onStepTaken += proc {
  if $game_player.terrain_tag != PBTerrain::Ice # Shouldn't count down if on ice
    if $PokemonGlobal.repel > 0
      $PokemonGlobal.repel -= 1
      if $PokemonGlobal.repel <= 0
        $game_switches[:Stop_Arrows_Shooting] = true
        $game_switches[:Stop_Icycle_Falling] = true
        Kernel.pbMessage(_INTL("Repel's effect wore off..."))
        if !Desolation
          ret = pbChooseItemFromList(_INTL("Do you want to use another Repel?"), 1, :REPEL, :SUPERREPEL, :MAXREPEL)
        else
          ret = nil
        end
        if ret
          pbUseItem($PokemonBag, ret)
          $game_variables[1] = 0
        end
        $game_switches[:Stop_Arrows_Shooting] = false
        $game_switches[:Stop_Icycle_Falling] = false
      end
    end
  end
}

ItemHandlers::UseFromBag.add(:BLACKFLUTE, proc { |item|
  Kernel.pbMessage(_INTL("{1} used {2}.", $Trainer.name, getItemName(item, :the)))
  Kernel.pbMessage(_INTL("Wild Pokémon will be repelled."))
  $PokemonMap.blackFluteUsed = true
  $PokemonMap.whiteFluteUsed = false
  next 1
})

ItemHandlers::UseFromBag.add(:WHITEFLUTE, proc { |item|
  Kernel.pbMessage(_INTL("{1} used {2}.", $Trainer.name, getItemName(item, :the)))
  Kernel.pbMessage(_INTL("Wild Pokémon will be lured."))
  $PokemonMap.blackFluteUsed = false
  $PokemonMap.whiteFluteUsed = true
  next 1
})

ItemHandlers::UseFromBag.add(:HONEY, proc { |item| next 4 })

ItemHandlers::UseFromBag.add(:ESCAPEROPE, proc { |item|
  next if !pbCanDig?(showmsg: true)

  next 4 # End screen and consume item
})

ItemHandlers::UseFromBag.add(:SACREDASH, proc { |item|
  if $Trainer.pokemonCount == 0
    Kernel.pbMessage(_INTL("There is no Pokémon."))
    next
  end
  if $Trainer.party.none? { |i| i.hp <= 0 && !i.isEgg? && !i.unusable }
    Kernel.pbMessage(_INTL("It won't have any effect."))
    next
  end
  pbFadeOutIn(99999) {
    scene = PokemonScreen_Scene.new
    screen = PokemonScreen.new(scene, $Trainer.party)
    screen.pbStartScene(_INTL("Using item..."))
    for i in $Trainer.party
      if i.hp <= 0 && !i.isEgg? && !i.unusable
        i.heal
        screen.pbRefresh
        screen.pbDisplay(_INTL("{1}'s HP was restored.", i.name))
      end
    end
    screen.pbEndScene
  }
  next 3
})

# 0 not used, 1 used but not consumed
ItemHandlers::UseFromBag.add(:EXPALL, proc { |item|
  current = $game_switches[:Exp_All_On] ? _INTL("ON") : _INTL("OFF")
  alternate = $game_switches[:Exp_All_On] ? _INTL("OFF") : _INTL("ON")
  if Kernel.pbConfirmMessage(_INTL("{1} is currently {2}. Would you like to turn it {3}?", getItemName(item), current, alternate))
    $game_switches[:Exp_All_On] = !$game_switches[:Exp_All_On]
    next 1
  end
})

ItemHandlers::UseFromBag.add(:EXPALLPLUS, proc { |item|
  current = $game_switches[:Exp_All_Plus_On] ? _INTL("ON") : _INTL("OFF")
  alternate = $game_switches[:Exp_All_Plus_On] ? _INTL("OFF") : _INTL("ON")
  if Kernel.pbConfirmMessage(_INTL("{1} is currently {2}. Would you like to turn it {3}?", getItemName(item), current, alternate))
    $game_switches[:Exp_All_Plus_On] = !$game_switches[:Exp_All_Plus_On]
    next 1
  end
})

ItemHandlers::UseFromBag.add(:BICYCLE, proc { |item|
  next pbBikeCheck ? 2 : nil
})

ItemHandlers::UseFromBag.add(:REMOTEPC, proc { |item|
  v = pbTryUseRemotePC(false)
  next v ? 1 : 0
})

def pbTryUseRemotePC(confirmation)
  if $game_variables[:E4_Tracker] > 0
    Kernel.pbMessage(_INTL("Cannot use the Remote PC here."))
    return false
  end
  if ($game_switches[:NotPlayerCharacter] && !$game_switches[:InterceptorsWish]) ||
     $game_switches[:IsThisStillPokemon?] ||
     hasActiveRentalTeam?()
    Kernel.pbMessage(_INTL("Cannot use the Remote PC right now."))
    return false
  end
  if $game_switches[:Free_Remote_PC]
    Kernel.pbMessage(_INTL("\\se[computeropen]Powered up the Remote PC."))
    pbPokeCenterPC(false)
    return true
  end
  qty = $PokemonBag.pbQuantity(:CELLBATTERY)
  if qty <= 0
    Kernel.pbMessage(_INTL("No Cell Battery to power the Remote PC."))
    return false
  end
  if confirmation
    unless Kernel.pbConfirmMessage(_INTL("Use a Cell Battery to power the Remote PC?") + "\n<o=128>" + _INTL("{1} {2} left.", qty, getItemName(:CELLBATTERY, plural: qty != 1)))
      return false
    end
    pbSEPlay("computeropen")
  else
    Kernel.pbMessage(_INTL("\\se[computeropen]Used a Cell Battery to power the Remote PC."))
  end
  $PokemonBag.pbDeleteItem(:CELLBATTERY)
  pbPokeCenterPC(false)
  return true
end

# ItemHandlers::UseFromBag.copy(:BICYCLE, :MACHBIKE, :ACROBIKE)

ItemHandlers::UseFromBag.add(:OLDROD, proc { |item|
  terrain = Kernel.pbFacingTerrainTag
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction)
  if ((pbIsWaterTag?(terrain) || pbIsGrimeTag?(terrain)) && !$PokemonGlobal.surfing && notCliff) ||
     (pbIsWaterTag?(terrain) && $PokemonGlobal.surfing)
    next 2
  else # lavasurfing here if lavasurfing/lavafishing
    Kernel.pbMessage(_INTL("Can't use that here."))
    next
  end
})
ItemHandlers::UseFromBag.copy(:OLDROD, :GOODROD, :SUPERROD)

ItemHandlers::UseFromBag.add(:ITEMFINDER, proc { |item| next 2 })

ItemHandlers::UseFromBag.copy(:ITEMFINDER, :DOWSINGMCHN)

ItemHandlers::UseFromBag.add(:TOWNMAP, proc { |item|
  pbShowMap(-1, false)
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:MEMBERSHIPCARD, proc { |item|
  $game_switches[:Show_Department_Card] = true
  next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:DEXCERTIFICATE, proc { |item|
  $game_switches[:Show_Dex_Certificate] = true
  next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:SPIRITTRACKER, proc { |item|
  Kernel.pbMessage(_INTL("Spirits released: {1}", $game_variables[548]))
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:BLUEORB3, proc { |item|
  $game_switches[:Blue_Orb_Quest] = true
  next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:COINCASE, proc { |item|
  Kernel.pbMessage(getCurrencyDisplay($PokemonGlobal.coins, shorthand: false, currency: :Coins))
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:MONEYBAG, proc { |item|
  Kernel.pbMessage(_INTL("Rob's Funds: {1}", getPurchaseDisplay($game_variables[:MoneyBag])))
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:GATHERCUBE, proc { |item|
  if Rejuv
    next 2
  else
    Kernel.pbMessage(_INTL("Z-cells gathered: {1}", $game_variables[:Z_Cells]))
  end

  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:ACHIEVEMENTCARD, proc { |item|
  Kernel.pbMessage(getCurrencyDisplay($game_variables[:AP], shorthand: false, currency: :AP))
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:BADGECARD, proc { |item|
  PBDebug.logonerr {
    scene = PokemonTrainerCardSceneGBC.new
    screen = PokemonTrainerCard.new(scene)
    pbFadeOutIn(99999) {
      screen.pbStartScreen
    }
  }
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:GOLDENWINGS, proc { |item|
  next pbGoldenItemCheck(item) ? 2 : nil
})

def pbGoldenItemCheck(item)
  move = PBStuff::HMTOGOLDITEM.invert[item]
  machine = getTMFromMove(move)
  if machine && !$PokemonBag.pbHasItem?(machine)
    machinetype = getItemName(machine).gsub(/\d/, "") # get rid of numbers from the item name to get "HM" or "TM"
    Kernel.pbMessage(_INTL("You don't have the {1} for this!", machinetype))
    return false
  end
  if !Kernel.pbCanUseHiddenMove?(:Trainer, move, showmessage: true)
    return false
  end
  return true
end

ItemHandlers::UseFromBag.add(:GOLDENWINGS, proc { |item|
  next pbGoldenItemCheck(item) ? 2 : nil
})

ItemHandlers::UseFromBag.add(:GOLDENWINGS, proc { |item|
  next pbGoldenItemCheck(item) ? 2 : nil
})

ItemHandlers::UseFromBag.add(:WAILMERPAIL, proc { |item|
  facingEvent = $game_player.pbFacingEvent
  berryData = facingEvent.variable if facingEvent&.variable.is_a?(BerryPlantData)
  if !berryData || !berryData.growing?
    Kernel.pbMessage(_INTL("Can't use that here."))
    next
  end
  next 2
})

ItemHandlers::UseFromBag.copy(:WAILMERPAIL, :SPRAYDUCK, :SQUIRTBOTTLE)

#===============================================================================
# UseOnPokemon handlers
#===============================================================================

ItemHandlers::UseOnPokemon.add(:FIRESTONE, proc { |item, pokemon, scene|
  newspecies = checkEvolution(pokemon, useditem: item)
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if newspecies.nil?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      pbCarryOutEvolution(pokemon, newspecies, item: item, cancancel: false)
      scene.pbRefreshAnnotations(proc { |p| !checkEvolution(p, useditem: item).nil? })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.copy(:FIRESTONE, *EVOSTONES)

ItemHandlers::UseOnPokemon.addIf( # HP restoring consumables
  proc { |item|
    medicine = $cache.items[item].medicine
    medicine && medicine.hp && !medicine.status
  },
  proc { |item, pokemon, scene|
    amount = $cache.items[item].medicine.hp
    if pbHPItem(pokemon, nil, amount, scene)
      happiness = $cache.items[item].medicine.happiness
      pokemon.changeHappiness(happiness) if happiness
      next true
    end
    next false
  }
)

ItemHandlers::UseOnPokemon.addIf( # Status healing consumables
  proc { |item|
    medicine = $cache.items[item].medicine
    medicine && medicine.status && !medicine.hp
  },
  proc { |item, pokemon, scene|
    status = $cache.items[item].medicine.status
    if pbStatusItem(pokemon, nil, status, scene)
      happiness = $cache.items[item].medicine.happiness
      pokemon.changeHappiness(happiness) if happiness
      next true
    end
    next false
  }
)

ItemHandlers::UseOnPokemon.add(:BLUEFLUTE, proc { |item, pokemon, scene|
  pbStatusItem(pokemon, nil, :SLEEP, scene)
  next false
})

ItemHandlers::UseOnPokemon.copy(:BLUEFLUTE, :POKEFLUTE)

ItemHandlers::UseOnPokemon.addIf( # Full Restore
  proc { |item|
    medicine = $cache.items[item].medicine
    medicine && medicine.hp && medicine.status
  },
  proc { |item, pokemon, scene|
    if pokemon.hp <= 0 || (pokemon.status.nil? && pokemon.hp == pokemon.totalhp)
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    else
      medicine = $cache.items[item].medicine
      pbItemCureStatus(pokemon, nil, medicine.status, scene)
      pbItemRestoreHP(pokemon, nil, medicine.hp, scene)
      happiness = $cache.items[item].medicine.happiness
      pokemon.changeHappiness(happiness) if happiness
      next true
    end
  }
)

ItemHandlers::UseOnPokemon.addIf( # Revival consumables
  proc { |item|
    medicine = $cache.items[item].medicine
    medicine && medicine.revive && item != :SACREDASH
  },
  proc { |item, pokemon, scene|
    amount = $cache.items[item].medicine.revive
    if pbReviveItem(pokemon, nil, amount, scene)
      happiness = $cache.items[item].medicine.happiness
      pokemon.changeHappiness(happiness) if happiness
      next true
    end
    next false
  }
)

ItemHandlers::UseOnPokemon.add(:POKESNAX, proc { |item, pokemon, scene|
  if pokemon.happiness == 255
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.changeHappiness(:LevelUp)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} ate {2} happily!", pokemon.name, getItemName(item, :the, useunit: false)))
    next true
  end
})

ItemHandlers::UseOnPokemon.copy(:POKESNAX, :GOURMETTREAT)

ItemHandlers::UseOnPokemon.add(:MAGICMOOMILK, proc { |item, pokemon, scene|
  amount = $cache.items[item].medicine.hp
  hp_restored = pbHPItem(pokemon, nil, amount, scene)
  if hp_restored || pokemon.hp == pokemon.totalhp
    move = scene.pbChooseMove(pokemon, _INTL("Restore which move?"))
    if move >= 0
      if pbRestorePP(pokemon, move, 10) == 0
        scene.pbDisplay(_INTL("It won't have any effect."))
        next true
      else
        scene.pbDisplay(_INTL("PP was restored."))
        next true
      end
    end
  end
  next false
})

ItemHandlers::UseOnPokemon.add(:ETHER, proc { |item, pokemon, scene|
  move = scene.pbChooseMove(pokemon, _INTL("Restore which move?"))
  if move >= 0
    if pbRestorePP(pokemon, move, 10) == 0
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    else
      scene.pbDisplay(_INTL("PP was restored."))
      next true
    end
  end
  next false
})

ItemHandlers::UseOnPokemon.copy(:ETHER, :LEPPABERRY)

ItemHandlers::UseOnPokemon.add(:MAXETHER, proc { |item, pokemon, scene|
  move = scene.pbChooseMove(pokemon, _INTL("Restore which move?"))
  if move >= 0
    if pbRestorePP(pokemon, move, pokemon.moves[move].totalpp - pokemon.moves[move].pp) == 0
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    else
      scene.pbDisplay(_INTL("PP was restored."))
      next true
    end
  end
  next false
})

ItemHandlers::UseOnPokemon.add(:ELIXIR, proc { |item, pokemon, scene|
  pprestored = 0
  for i in 0...pokemon.moves.length
    pprestored += pbRestorePP(pokemon, i, 10)
  end
  if pprestored == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    scene.pbDisplay(_INTL("PP was restored."))
    next true
  end
})

ItemHandlers::UseOnPokemon.copy(:ELIXIR, :ROSETEA)

ItemHandlers::UseOnPokemon.add(:MAXELIXIR, proc { |item, pokemon, scene|
  pprestored = 0
  for i in 0...pokemon.moves.length
    pprestored += pbRestorePP(pokemon, i, pokemon.moves[i].totalpp - pokemon.moves[i].pp)
  end
  if pprestored == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    scene.pbDisplay(_INTL("PP was restored."))
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:PPUP, proc { |item, pokemon, scene|
  move = scene.pbChooseMove(pokemon, _INTL("Boost PP of which move?"))
  if move >= 0
    if pokemon.moves[move].totalpp == 0 || pokemon.moves[move].ppup >= 3
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    else
      pokemon.moves[move].ppup += 1
      movename = getMoveName(pokemon.moves[move].move)
      scene.pbDisplay(_INTL("{1}'s PP increased.", movename))
      next true
    end
  end
})

ItemHandlers::UseOnPokemon.add(:PPMAX, proc { |item, pokemon, scene|
  move = scene.pbChooseMove(pokemon, _INTL("Boost PP of which move?"))
  if move >= 0
    if pokemon.moves[move].totalpp == 0 || pokemon.moves[move].ppup >= 3
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    else
      pokemon.moves[move].ppup = 3
      movename = getMoveName(pokemon.moves[move].move)
      scene.pbDisplay(_INTL("{1}'s PP increased.", movename))
      next true
    end
  end
})

ItemHandlers::UseOnPokemon.add(:PPALL, proc { |item, pokemon, scene|
  numMoves = pokemon.moves.length
  for i in 0...numMoves
    hasmoves = true if pokemon.moves[i].totalpp != 0 && pokemon.moves[i].ppup < 3
  end
  if !hasmoves
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    for i in 0...numMoves
      next if pokemon.moves[i].totalpp == 0

      pokemon.moves[i].ppup = 3
    end
    scene.pbDisplay(_INTL("The PP of {1}'s moves was maximized.", pokemon.name))
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:PRISONBOTTLE, proc { |item, pokemon, scene|
  if pokemon.species == :HOOPA && pokemon.form == 0 && pokemon.hp >= 0
    pokemon.changeForm(1)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
    pbHoopaMoves(pokemon) if Gen >= 9
    next true
  elsif pokemon.species == :HOOPA && pokemon.form == 1 && pokemon.hp >= 0
    pokemon.changeForm(0)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
    pbHoopaMoves(pokemon) if Gen >= 9
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

##################################################################################
# Z Crystals                                                                     #
##################################################################################
ItemHandlers::UseOnPokemon.add(:NORMALIUMZ, proc { |item, pokemon, scene|
  next pbGiveItem(item, pokemon, scene, scene, zcrystal: true)
})

ItemHandlers::UseOnPokemon.copy(
  :NORMALIUMZ, :FLYINIUMZ, :GROUNDIUMZ, :BUGINIUMZ, :STEELIUMZ,
  :WATERIUMZ, :ELECTRIUMZ, :ICIUMZ, :DARKINIUMZ, :FIGHTINIUMZ, :POISONIUMZ, :ROCKIUMZ, :GHOSTIUMZ,
  :FIRIUMZ, :GRASSIUMZ, :PSYCHIUMZ, :DRAGONIUMZ, :FAIRIUMZ
)

ItemHandlers::UseOnPokemon.copy(
  :NORMALIUMZ, :ALORAICHIUMZ, :DECIDIUMZ, :INCINIUMZ, :PRIMARIUMZ,
  :EEVIUMZ, :PIKANIUMZ, :SNORLIUMZ, :MEWNIUMZ, :TAPUNIUMZ, :MARSHADIUMZ, :KOMMONIUMZ, :LYCANIUMZ,
  :MIMIKIUMZ, :SOLGANIUMZ, :LUNALIUMZ, :ULTRANECROZIUMZ, :INTERCEPTZ
)
##################################################################################

def pbChangeLevel(pokemon, newlevel, scene)
  newlevel = 1 if newlevel < 1
  newlevel = MAXIMUMLEVEL if newlevel > MAXIMUMLEVEL
  return Kernel.pbMessage(_INTL("{1}'s level remained unchanged.", pokemon.name)) if pokemon.level == newlevel

  # Stat differences
  oldlevel = pokemon.level
  oldstats = pokemon.getStats

  # General new level stuff
  pokemon.level = newlevel
  pokemon.exp = PBExp.startExperience(pokemon.level, pokemon.growthrate)
  pokemon.calcStats
  scene.pbRefresh

  # Message
  message = oldlevel > newlevel ?
    _INTL("\\se[]{1} was downgraded to Level {2}!\\se[itemlevel]", pokemon.name, pokemon.level) :
    _INTL("\\se[]{1} was elevated to Level {2}!\\se[itemlevel]", pokemon.name, pokemon.level)
  window = pbStatChangeDisplayWindow(pokemon, oldstats, highlight: false)
  Kernel.pbMessage(message)
  window&.dispose

  if newlevel > oldlevel
    # Happiness
    pokemon.changeHappiness(:LevelUp)

    # New moves learned in region
    movelist = pokemon.getMoveList
    for i in movelist
      if i[0] <= pokemon.level && i[0] > oldlevel
        pbTryLearnMove(pokemon, i[1], ignoreifknown: true)
      end
    end

    # Possible evolution
    newspecies = checkEvolution(pokemon)
    if newspecies != nil
      pbFadeOutInWithMusic(99999) {
        pbCarryOutEvolution(pokemon, newspecies)
      }
    end
  end
end

def IncreaseExp(pokemon, exp, scene) # For Exp Candies
  newexp = PBExp.addExperience(pokemon.exp, exp, pokemon.growthrate)
  exp = (newexp - pokemon.exp)
  oldlevel = pokemon.level
  if exp > 0
    scene.pbDisplay(_INTL("{1} gained {2} Exp. Points!", pokemon.name, exp))
    newlevel = PBExp.levelFromExperience(newexp, pokemon.growthrate)
    tempexp = 0
    curlevel = pokemon.level
    if newlevel < curlevel
      debuginfo = "#{pokemon.name}: #{pokemon.level}/#{newlevel} | #{pokemon.exp}/#{newexp} | gain: #{exp}"
      raise RuntimeError.new(
        _INTL(
          "The new level ({1}) is less than the Pokémon's\ncurrent level ({2}), which shouldn't happen.\n[Debug: {3}]",
          newlevel, curlevel, debuginfo
        )
      )
      return
    end
    oldstats = pokemon.getStats
    passedlevels = []
    loop do
      # EXP Bar increment
      startexp = PBExp.startExperience(curlevel, pokemon.growthrate)
      endexp = PBExp.startExperience(curlevel + 1, pokemon.growthrate)
      tempexp2 = (endexp < newexp) ? endexp : newexp
      pokemon.exp = tempexp2
      tempexp1 = tempexp2
      curlevel += 1
      if curlevel > newlevel
        pokemon.calcStats
        break
      else
        passedlevels.push(curlevel)
      end
      pokemon.level = newlevel
      pokemon.changeHappiness(:LevelUp)
      pokemon.calcStats
    end
    if pokemon.level > oldlevel
      window = pbStatChangeDisplayWindow(pokemon, oldstats, highlight: false)
      Kernel.pbMessage(_INTL("\\se[]{1} grew to Level {2}!\\se[itemlevel]", pokemon.name, pokemon.level))
      window&.dispose
      # New moves learned
      movelist = pokemon.getMoveList
      for j in passedlevels
        for i in movelist
          if i[0] == j
            pbTryLearnMove(pokemon, i[1], ignoreifknown: true)
          end
        end
      end
      # Evolution
      newspecies = checkEvolution(pokemon)
      if newspecies
        pbFadeOutInWithMusic(99999) {
          pbCarryOutEvolution(pokemon, newspecies)
        }
      end
    end
  end
end

ItemHandlers::UseOnPokemon.add(:RARECANDY, proc { |item, pokemon, scene, amount = 1|
  finallevelcap = 100 + $game_variables[:Extended_Max_Level]
  if (pokemon.isShadow? rescue false) || noExp?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  elsif pokemon.level >= MAXIMUMLEVEL || pokemon.level >= finallevelcap
    if checkEvolution(pokemon)
      newspecies = checkEvolution(pokemon)
      if newspecies
        pbFadeOutInWithMusic(99999) {
          pbCarryOutEvolution(pokemon, newspecies)
        }
      end
      next true, 1
    else
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false, 0
    end
  else
    amount = amount
    amount = MAXIMUMLEVEL - pokemon.level if MAXIMUMLEVEL - pokemon.level < amount
    amount = finallevelcap - pokemon.level if finallevelcap - pokemon.level < amount
    pbChangeLevel(pokemon, pokemon.level + amount, scene)
    scene.pbHardRefresh
    next true, amount
  end
})

ItemHandlers::UseOnPokemon.add(:COMMONCANDY, proc { |item, pokemon, scene, amount = 1|
  if pokemon.level == 1 || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  else
    amount = pokemon.level - 1 if amount >= pokemon.level
    pbChangeLevel(pokemon, pokemon.level - amount, scene)
    pokemon.changeHappiness(:BadCandy)
    scene.pbHardRefresh
    next true, amount
  end
})
ItemHandlers::UseOnPokemon.copy(:COMMONCANDY, :REVERSECANDY)
ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE, proc { |item, pokemon, scene|
  form       = pokemon.form
  tempabil   = pokemon.abilityIndex
  abilid     = pokemon.ability
  abillist   = pokemon.getAbilityList
  name       = pokemon.getFormName

  if abillist.length == 1 || !abillist.include?(abilid) || pokemon.species == :ZYGARDE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end

  commands = []
  command_option = []
  abils = []
  for i in 0...abillist.length
    abil = abillist[i]
    next if abils.include?(abil)

    hiddentag = i == 0 || abil != pokemon.getCacheData.HiddenAbility ? "" : "(H) "
    colortag = abil == abilid ? (isCurrentWindowskinDark ? ColorTags : LightColorTags)[:Blue] : ""
    commands.push(hiddentag + colortag + getAbilityName(abil))
    command_option.push(i)
    abils.push(abil)
  end

  cmd = scene.pbShowCommands(_INTL("Which ability would you like to change to?"), commands)
  next false if cmd == -1

  if abillist[command_option[cmd]] == abilid
    scene.pbDisplay(_INTL("{1} already has this ability.", pokemon.name))
    next false
  end

  pokemon.setAbility(abillist[command_option[cmd]])
  scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", pokemon.name, getAbilityName(pokemon.ability)))
  next true
})

def pbResetEVStat(pokemon, scene, stat)
  if pokemon.ev[stat] == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  else
    oldstats = pokemon.getStats
    pokemon.ev[stat] = 0
    pokemon.calcStats
    window = pbStatChangeDisplayWindow(pokemon, oldstats)
    scene.pbDisplay(_INTL("{1} forgot its {2} training!\nIts base {2} was reset!", pokemon.name, getStatName(stat)))
    window&.dispose
    scene.pbRefresh
    return true
  end
end

ItemHandlers::UseOnPokemon.add(:HPRESETBAG, proc { |item, pokemon, scene|
  next pbResetEVStat(pokemon, scene, PBStats::HP)
})

ItemHandlers::UseOnPokemon.add(:ATKRESETBAG, proc { |item, pokemon, scene|
  next pbResetEVStat(pokemon, scene, PBStats::ATTACK)
})

ItemHandlers::UseOnPokemon.add(:DEFRESETBAG, proc { |item, pokemon, scene|
  next pbResetEVStat(pokemon, scene, PBStats::DEFENSE)
})

ItemHandlers::UseOnPokemon.add(:SPARESETBAG, proc { |item, pokemon, scene|
  next pbResetEVStat(pokemon, scene, PBStats::SPATK)
})

ItemHandlers::UseOnPokemon.add(:SPDRESETBAG, proc { |item, pokemon, scene|
  next pbResetEVStat(pokemon, scene, PBStats::SPDEF)
})

ItemHandlers::UseOnPokemon.add(:SPERESETBAG, proc { |item, pokemon, scene|
  next pbResetEVStat(pokemon, scene, PBStats::SPEED)
})

ItemHandlers::UseOnPokemon.add(:FULLRESETBAG, proc { |item, pokemon, scene|
  if pokemon.ev.all? { |ev| ev == 0 }
    scene.pbDisplay(_INTL("It won't have any effect."))
  else
    oldstats = pokemon.getStats
    (0...6).each { |i| pokemon.ev[i] = 0 }
    pokemon.calcStats
    window = pbStatChangeDisplayWindow(pokemon, oldstats)
    scene.pbDisplay(_INTL("{1} forgot all its training!\nIts base stats were reset!", pokemon.name))
    window&.dispose
    scene.pbRefresh
  end
})

ItemHandlers::UseOnPokemon.add(:EVTUNER, proc { |item, pokemon, scene|
  # make stat list
  stats = (0..5).map { |stat| getStatName(stat, :full) }
  evcommands = []
  ret = false
  loop do
    for i in 0...stats.length
      evcommands.push(stats[i] + " (#{pokemon.ev[i]})")
    end
    cmd = 0
    # Show menu with stats to chose from
    cmd = scene.pbShowCommands(_INTL("Select first EV stat to swap."), evcommands)
    if cmd == -1 # cancelled
      break
    elsif cmd >= 0 && cmd < stats.length # choose first stat
      evcommands2 = []
      loop do
        for i in 0...stats.length
          if i == cmd
            evcommands2.push("[X]" + stats[i] + " (#{pokemon.ev[i]})")
          else
            evcommands2.push(stats[i] + " (#{pokemon.ev[i]})")
          end
        end
        cmd2 = 0
        # Show menu with stats to chose from
        cmd2 = scene.pbShowCommands(_INTL("Select second EV stat to swap with first one."), evcommands2)
        if cmd2 == -1 # cancelled
          break
        elsif cmd == cmd2 # chose same stat
          scene.pbDisplay(_INTL("Can't swap a stat with itself!"))
          break
        elsif cmd2 >= 0 && cmd2 < stats.length # chose second stat
          if Kernel.pbConfirmMessage(_INTL("Do you want to swap {1}'s {2} stat with its {3} stat?", pokemon.name, stats[cmd], stats[cmd2]))
            oldstats = pokemon.getStats
            pokemon.ev[cmd], pokemon.ev[cmd2] = pokemon.ev[cmd2], pokemon.ev[cmd]
            pokemon.calcStats
            window = pbStatChangeDisplayWindow(pokemon, oldstats)
            scene.pbDisplay(_INTL("Swapped the two stats' EVs around!"))
            window&.dispose
            scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
            ret = true
          end
          break
        end
      end
      break
    end
  end
  next ret
})

ItemHandlers::UseOnPokemon.add(:EVBOOSTER, proc { |item, pokemon, scene|
  # make stat list
  stats = (0..5).map { |stat| getStatName(stat, :full) }
  ret = false
  if pokemon.ev.sum >= getPlayerMaxEVs()
    scene.pbDisplay(_INTL("{1} already reached its max EVs!", pokemon.name))
    next ret
  end
  loop do
    evcommands = []
    for i in 0...stats.length
      evcommands.push(stats[i] + " (#{pokemon.ev[i]})")
    end
    cmd = 0
    # Show menu with stats to chose from
    cmd = scene.pbShowCommands(_INTL("Select which EV stat to boost."), evcommands)
    if cmd == -1 # cancelled
      break
    elsif cmd >= 0 && cmd < stats.length # choose first stat
      if pokemon.ev[cmd] >= 252
        scene.pbDisplay(_INTL("The {1} stat is already maxed!", stats[cmd]))
        next
      end
      if Kernel.pbConfirmMessage(_INTL("Do you want to boost {1}'s {2} stat?", pokemon.name, stats[cmd]))
        oldstats = pokemon.getStats
        evs_left = 510 - pokemon.ev.sum
        if evs_left > 252 - pokemon.ev[cmd] || $game_switches[:No_Total_EV_Cap]
          pokemon.ev[cmd] = 252
        else
          pokemon.ev[cmd] += evs_left
        end
        pokemon.calcStats
        window = pbStatChangeDisplayWindow(pokemon, oldstats)
        scene.pbDisplay(_INTL("Boosted the {1} stat!", stats[cmd]))
        window&.dispose
        scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
        ret = true
      end
      break
    end
  end
  next ret
})

def useVitamin(pokemon, scene, amount, stat)
  consumed = 0
  # "stopgains" password is intentionally ignored
  while consumed < amount
    break if pbRaiseEffortValues(pokemon, stat) == 0

    pokemon.changeHappiness(:Vitamin)
    consumed += 1
  end

  if consumed == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false, 0
  end

  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s {2} increased.", pokemon.name, getStatName(stat, :full)))
  return true, consumed
end

ItemHandlers::UseOnPokemon.add(:HPUP, proc { |item, pokemon, scene, amount = 1|
  next useVitamin(pokemon, scene, amount, PBStats::HP)
})

ItemHandlers::UseOnPokemon.add(:PROTEIN, proc { |item, pokemon, scene, amount = 1|
  next useVitamin(pokemon, scene, amount, PBStats::ATTACK)
})

ItemHandlers::UseOnPokemon.add(:IRON, proc { |item, pokemon, scene, amount = 1|
  next useVitamin(pokemon, scene, amount, PBStats::DEFENSE)
})

ItemHandlers::UseOnPokemon.add(:CALCIUM, proc { |item, pokemon, scene, amount = 1|
  next useVitamin(pokemon, scene, amount, PBStats::SPATK)
})

ItemHandlers::UseOnPokemon.add(:ZINC, proc { |item, pokemon, scene, amount = 1|
  next useVitamin(pokemon, scene, amount, PBStats::SPDEF)
})

ItemHandlers::UseOnPokemon.add(:CARBOS, proc { |item, pokemon, scene, amount = 1|
  next useVitamin(pokemon, scene, amount, PBStats::SPEED)
})

def useFeather(pokemon, scene, amount, stat)
  consumed = 0
  # "stopgains" password is intentionally ignored
  while consumed < amount
    break if pbRaiseEffortValues(pokemon, stat, 4, false) == 0

    pokemon.changeHappiness(:Feather)
    consumed += 1
  end

  if consumed == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false, 0
  end

  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s {2} increased.", pokemon.name, getStatName(stat, :full)))
  return true, consumed
end

ItemHandlers::UseOnPokemon.add(:HEALTHWING, proc { |item, pokemon, scene, amount = 1|
  next useFeather(pokemon, scene, amount, PBStats::HP)
})

ItemHandlers::UseOnPokemon.add(:MUSCLEWING, proc { |item, pokemon, scene, amount = 1|
  next useFeather(pokemon, scene, amount, PBStats::ATTACK)
})

ItemHandlers::UseOnPokemon.add(:RESISTWING, proc { |item, pokemon, scene, amount = 1|
  next useFeather(pokemon, scene, amount, PBStats::DEFENSE)
})

ItemHandlers::UseOnPokemon.add(:GENIUSWING, proc { |item, pokemon, scene, amount = 1|
  next useFeather(pokemon, scene, amount, PBStats::SPATK)
})

ItemHandlers::UseOnPokemon.add(:CLEVERWING, proc { |item, pokemon, scene, amount = 1|
  next useFeather(pokemon, scene, amount, PBStats::SPDEF)
})

ItemHandlers::UseOnPokemon.add(:SWIFTWING, proc { |item, pokemon, scene, amount = 1|
  next useFeather(pokemon, scene, amount, PBStats::SPEED)
})

def useEVBerry(item, pokemon, scene, amount)
  stat = PBStuff::EVBERRIES[item]
  originalev = pokemon.ev[stat]
  consumed = 0
  while consumed < amount
    break if pokemon.happiness == 255 && pokemon.ev[stat] == 0

    pokemon.changeHappiness(:EVBerry)
    pokemon.ev[stat] -= 20
    pokemon.ev[stat] = 0 if pokemon.ev[stat] < 0
    consumed += 1
  end

  if consumed == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false, 0
  end

  pokemon.calcStats
  scene.pbRefresh

  if pokemon.happiness == 255 && originalev > pokemon.ev[stat]
    scene.pbDisplay(_INTL("{1} adores you!\nThe base {2} fell!", pokemon.name, getStatName(stat, :full)))
  elsif pokemon.happiness == 255
    scene.pbDisplay(_INTL("{1} adores you!\nThe base {2} can't fall!", pokemon.name, getStatName(stat, :full)))
  elsif originalev > pokemon.ev[stat]
    scene.pbDisplay(_INTL("{1} turned friendly.\nThe base {2} fell!", pokemon.name, getStatName(stat, :full)))
  else
    scene.pbDisplay(_INTL("{1} turned friendly.\nThe base {2} can't fall!", pokemon.name, getStatName(stat, :full)))
  end

  return true, consumed
end

ItemHandlers::UseOnPokemon.add(:POMEGBERRY, proc { |item, pokemon, scene, amount = 1|
  next useEVBerry(item, pokemon, scene, amount)
})

ItemHandlers::UseOnPokemon.copy(:POMEGBERRY, *PBStuff::EVBERRIES.keys)

##################################################################################
# New Gen 8 Items
##################################################################################

def ExpCandy(pokemon, scene, amount, value)
  if pokemon.level >= MAXIMUMLEVEL || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false, 0
  end

  value = (value * $game_variables[:Exp_Percent] / 100.0).floor if $game_switches[:Percent_Exp_Gains]

  exp = value * amount
  result = LevelLimitExpGain(pokemon, exp)

  if result == -1
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false, 0
  end

  exp = result
  amount_consumed = (result / (value * 1.0)).ceil
  IncreaseExp(pokemon, exp, scene)

  scene.pbHardRefresh
  return true, amount_consumed
end

ItemHandlers::UseOnPokemon.add(:EXPCANDYXS, proc { |item, pokemon, scene, amount = 1|
  next ExpCandy(pokemon, scene, amount, 100)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYS, proc { |item, pokemon, scene, amount = 1|
  next ExpCandy(pokemon, scene, amount, 800)
})

ItemHandlers::UseOnPokemon.copy(:EXPCANDYS, :PHANTOMCANDYS)

ItemHandlers::UseOnPokemon.add(:EXPCANDYM, proc { |item, pokemon, scene, amount = 1|
  next ExpCandy(pokemon, scene, amount, 3000)
})

ItemHandlers::UseOnPokemon.copy(:EXPCANDYM, :PHANTOMCANDYM)

ItemHandlers::UseOnPokemon.add(:EXPCANDYL, proc { |item, pokemon, scene, amount = 1|
  next ExpCandy(pokemon, scene, amount, 10000)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYXL, proc { |item, pokemon, scene, amount = 1|
  next ExpCandy(pokemon, scene, amount, 30000)
})

def pbUseMint(pokemon, scene, nature)
  if pokemon.nature == nature || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  else
    oldstats = pokemon.getStats
    pokemon.setNature(nature)
    message = [:LONELY, :RELAXED, :CALM, :JOLLY].include?(nature) ?
      _INTL("{1} feels {2}!", pokemon.name, getNatureName(nature)) :
      _INTL("{1} becomes {2}!", pokemon.name, getNatureName(nature))
    window = pbStatChangeDisplayWindow(pokemon, oldstats)
    scene.pbDisplay(message)
    window&.dispose
    scene.pbRefresh
    return true
  end
end

ItemHandlers::UseOnPokemon.add(:ADAMANTMINT, proc { |item, pokemon, scene|
  next pbUseMint(pokemon, scene, $cache.items[item].checkFlag?(:mint))
})

ItemHandlers::UseOnPokemon.copy(
  :ADAMANTMINT,
  :LONELYMINT, :NAUGHTYMINT, :BRAVEMINT, :BOLDMINT, :IMPISHMINT,
  :LAXMINT, :RELAXEDMINT, :MODESTMINT, :MILDMINT, :RASHMINT,
  :QUIETMINT, :CALMMINT, :GENTLEMINT, :CAREFULMINT, :SASSYMINT,
  :TIMIDMINT, :HASTYMINT, :JOLLYMINT, :NAIVEMINT, :SERIOUSMINT,
)

ItemHandlers::UseOnPokemon.add(:CELLIMPRINT, proc { |item, pokemon, scene|
  ivsmaxed = true
  ivnames = (0..5).map { |stat| getStatName(stat, :full) }
  ivorder = [0, 1, 2, 3, 4, 5]
  listindexes = []
  possible_ivs = []
  for i in ivorder
    if pokemon.iv[i] != 31
      ivsmaxed = false
      listindexes.push(i)
      possible_ivs.push(ivnames[i] + ": " + pokemon.iv[i].to_s)
    end
  end
  if $game_switches[:Empty_IVs_Password]
    scene.pbDisplay(_INTL("It won't have any effect!", pokemon.name))
    next false
  end
  if ivsmaxed
    scene.pbDisplay(_INTL("All of {1}'s IVs are already maxed out.", pokemon.name))
    next false
  else
    possible_ivs.push("Cancel")
    ret = Kernel.pbMessage(_INTL("Which IV would you like to max?"), possible_ivs, possible_ivs.length)
    if ret == possible_ivs.length - 1
      next false
    else
      oldstats = pokemon.getStats
      pokemon.iv[listindexes[ret]] = 31
      pokemon.calcStats
      window = pbStatChangeDisplayWindow(pokemon, oldstats)
      scene.pbDisplay(_INTL("{1}'s {2} was maxed out!", pokemon.name, ivnames[listindexes[ret]]))
      window&.dispose
      scene.pbRefresh
      next true
    end
  end
})

ItemHandlers::UseOnPokemon.add(:NEGATIVEIMPRINT, proc { |item, pokemon, scene|
  ivsminned = true
  ivnames = (0..5).map { |stat| getStatName(stat, :full) }
  ivorder = [0, 1, 2, 3, 4, 5]
  listindexes = []
  possible_ivs = []
  for i in ivorder
    if pokemon.iv[i] != 0
      ivsminned = false
      listindexes.push(i)
      possible_ivs.push(ivnames[i] + ": " + pokemon.iv[i].to_s)
    end
  end
  if ivsminned
    scene.pbDisplay(_INTL("All of {1}'s IVs are already minimized.", pokemon.name))
    next false
  else
    possible_ivs.push("Cancel")
    ret = Kernel.pbMessage(_INTL("Which IV would you like to minimize?"), possible_ivs, possible_ivs.length)
    if ret == possible_ivs.length - 1
      next false
    else
      oldstats = pokemon.getStats
      pokemon.iv[listindexes[ret]] = 0
      pokemon.calcStats
      window = pbStatChangeDisplayWindow(pokemon, oldstats)
      scene.pbDisplay(_INTL("{1}'s {2} was minimized!", pokemon.name, ivnames[listindexes[ret]]))
      window&.dispose
      scene.pbRefresh
      next true
    end
  end
})

##################################################################################
# New Gen 8 Items end
##################################################################################

ItemHandlers::UseOnPokemon.add(:GRACIDEA, proc { |item, pokemon, scene|
  if pokemon.species == :SHAYMIN && pokemon.hp >= 0 && pokemon.status != :FROZEN
    if pokemon.form == 0
      pokemon.changeForm(1)
      pokemon.initAbility
      pokemon.calcStats
    elsif pokemon.form == 1
      pokemon.changeForm(0)
      pokemon.initAbility
      pokemon.calcStats
    end
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:REVEALGLASS, proc { |item, pokemon, scene|
  if [:TORNADUS, :THUNDURUS, :LANDORUS, :ENAMOROUS].include?(pokemon.species) && pokemon.hp >= 0
    pokemon.changeForm(pokemon.form == 0 ? 1 : 0)
    scene.pbRefresh
    if pokemon.form == 1
      pokemon.originalAbility = pokemon.ability
      pokemon.initAbility
    elsif pokemon.form == 0 && !pokemon.originalAbility.nil?
      pokemon.ability = pokemon.originalAbility
      pokemon.originalAbility = nil
    else
      pokemon.initAbility
    end
    pokemon.calcStats
    scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS, proc { |item, pokemon, scene|
  if pokemon.species == :KYUREM && pokemon.hp >= 0
    if pokemon.fused != nil
      if $Trainer.party.length >= 6
        scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
        next false
      else
        $Trainer.party[$Trainer.party.length] = pokemon.fused
        pokemon.fused = nil
        pokemon.changeForm(0)
        pokemon.initAbility
        pokemon.calcStats
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
        pbKyuremMoves(pokemon)
        next true
      end
    else
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      if chosen >= 0
        poke2 = $Trainer.party[chosen]
        if poke2.species == :RESHIRAM || poke2.species == :ZEKROM && poke2.hp >= 0
          pokemon.changeForm(1) if poke2.species == :RESHIRAM
          pokemon.changeForm(2) if poke2.species == :ZEKROM
          pokemon.initAbility
          pokemon.calcStats
          pokemon.fused = poke2
          pbRemovePokemonAt(chosen)
          scene.pbHardRefresh
          scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
          pbKyuremMoves(pokemon)
          next true
        elsif pokemon == poke2
          scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
        else
          scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
        end
      else
        next false
      end
    end
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:NSOLARIZER, proc { |item, pokemon, scene|
  if pokemon.species == :NECROZMA && pokemon.hp >= 0
    if pokemon.fused != nil
      if $Trainer.party.length >= 6
        scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
        next false
      else
        $Trainer.party[$Trainer.party.length] = pokemon.fused
        pokemon.fused = nil
        pokemon.changeForm(0)
        pokemon.initAbility
        pokemon.calcStats
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
        pbNecrozmaMoves(pokemon)
        next true
      end
    else
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      if chosen >= 0
        poke2 = $Trainer.party[chosen]
        if poke2.species == :SOLGALEO && poke2.hp >= 0
          pokemon.changeForm(1)
          pokemon.initAbility
          pokemon.calcStats
          pokemon.fused = poke2
          pbRemovePokemonAt(chosen)
          scene.pbHardRefresh
          scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
          pbNecrozmaMoves(pokemon)
          next true
        elsif pokemon == poke2
          scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
        elsif poke2.species == :LUNALA
          scene.pbDisplay(_INTL("This item can't fuse {1} with {2}.", poke2.name, pokemon.name))
        else
          scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
        end
      else
        next false
      end
    end
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:NLUNARIZER, proc { |item, pokemon, scene|
  if pokemon.species == :NECROZMA && pokemon.hp >= 0
    if pokemon.fused != nil
      if $Trainer.party.length >= 6
        scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
        next false
      else
        $Trainer.party[$Trainer.party.length] = pokemon.fused
        pokemon.fused = nil
        pokemon.changeForm(0)
        pokemon.initAbility
        pokemon.calcStats
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
        pbNecrozmaMoves(pokemon)
        next true
      end
    else
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      if chosen >= 0
        poke2 = $Trainer.party[chosen]
        if poke2.species == :LUNALA && poke2.hp >= 0
          pokemon.changeForm(2)
          pokemon.initAbility
          pokemon.calcStats
          pokemon.fused = poke2
          pbRemovePokemonAt(chosen)
          scene.pbHardRefresh
          scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
          pbNecrozmaMoves(pokemon)
          next true
        elsif pokemon == poke2
          scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
        elsif poke2.species == :SOLGALEO
          scene.pbDisplay(_INTL("This item can't fuse {1} with {2}.", poke2.name, pokemon.name))
        else
          scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
        end
      else
        next false
      end
    end
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:REDNECTAR, proc { |item, pokemon, scene|
  if pokemon.species == :ORICORIO && pokemon.form != 0 && pokemon.hp >= 0
    pokemon.changeForm(0)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} transformed!", pokemon.name))
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:YELLOWNECTAR, proc { |item, pokemon, scene|
  if pokemon.species == :ORICORIO && pokemon.form != 1 && pokemon.hp >= 0
    pokemon.changeForm(1)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} transformed!", pokemon.name))
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:PINKNECTAR, proc { |item, pokemon, scene|
  if pokemon.species == :ORICORIO && pokemon.form != 2 && pokemon.hp >= 0
    pokemon.changeForm(2)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} transformed!", pokemon.name))
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:PURPLENECTAR, proc { |item, pokemon, scene|
  if pokemon.species == :ORICORIO && pokemon.form != 3 && pokemon.hp >= 0
    pokemon.changeForm(3)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} transformed!", pokemon.name))
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:PINKPETAL, proc { |item, pokemon, scene|
  if [:DEERLING, :SAWSBUCK].include?(pokemon.species) && pokemon.form != 0 && pokemon.hp >= 0
    pokemon.changeForm(0)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} transformed!", pokemon.name))
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:GREENPETAL, proc { |item, pokemon, scene|
  if [:DEERLING, :SAWSBUCK].include?(pokemon.species) && pokemon.form != 1 && pokemon.hp >= 0
    pokemon.changeForm(1)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} transformed!", pokemon.name))
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:ORANGEPETAL, proc { |item, pokemon, scene|
  if [:DEERLING, :SAWSBUCK].include?(pokemon.species) && pokemon.form != 2 && pokemon.hp >= 0
    pokemon.changeForm(2)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} transformed!", pokemon.name))
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:BLUEPETAL, proc { |item, pokemon, scene|
  if [:DEERLING, :SAWSBUCK].include?(pokemon.species) && pokemon.form != 3 && pokemon.hp >= 0
    pokemon.changeForm(3)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} transformed!", pokemon.name))
    next true
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:PAINTJAR, proc { |item, pokemon, scene|
  if !pokemon.isShiny?
    scene.pbDisplay(_INTL("{1} is now shiny!", pokemon.name))
    next pokemon.makeShiny
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:PHASEDIAL, proc { |item, pokemon, scene|
  if (pokemon.species == :SOLROCK || pokemon.species == :LUNATONE) && pokemon.hp >= 0
    if pokemon.fused != nil
      if $Trainer.party.length >= 6
        scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
        next false
      else
        $Trainer.party[$Trainer.party.length] = pokemon.fused
        pokemon.fused = nil
        pokemon.changeForm(0)
        pokemon.initAbility
        pokemon.calcStats
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
        next true
      end
    else
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      if chosen >= 0
        poke2 = $Trainer.party[chosen]
        if poke2.form != 0 || poke2.fused
          scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
        elsif ((poke2.species == :LUNATONE && pokemon.species == :SOLROCK) ||
          (poke2.species == :SOLROCK && pokemon.species == :LUNATONE)) && poke2.hp >= 0
          pokemon.changeForm(1)
          pokemon.initAbility
          pokemon.calcStats
          pokemon.fused = poke2
          pbRemovePokemonAt(chosen)
          scene.pbHardRefresh
          scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
          next true
        elsif pokemon == poke2
          scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
        else
          scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
        end
      else
        next false
      end
    end
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

#===============================================================================
# UseInField handlers
#===============================================================================

ItemHandlers::UseInField.add(:HONEY, proc { |item|
  Kernel.pbMessage(_INTL("{1} used {2}!", $Trainer.name, getItemName(item, :the, useunit: false)))
  pbSweetScent
})

ItemHandlers::UseInField.add(:ESCAPEROPE, lambda { |item|
  next if !pbCanDig?(showmsg: true)

  Kernel.pbMessage(_INTL("{1} used the Escape Rope.", $Trainer.name))
  pbDig(escaperope: true)
})

def hookBeforeEscapeRope
  # Intentionally empty, added as a hook for mod overrides since overriding escape rope handling isn't easy.
end

def hookAfterEscapeRope
  # Intentionally empty, added as a hook for mod overrides since overriding escape rope handling isn't easy.
end

ItemHandlers::UseInField.add(:BICYCLE, proc { |item|
  if pbBikeCheck
    if $PokemonGlobal.bicycle
      Kernel.pbDismountBike
    else
      Kernel.pbMountBike
    end
  end
})

ItemHandlers::UseInField.add(:REMOTEPC, proc { |item|
  v = pbTryUseRemotePC(false)
})

# ItemHandlers::UseInField.copy(:BICYCLE, :MACHBIKE, :ACROBIKE)

ItemHandlers::UseInField.add(:OLDROD, proc { |item|
  terrain = Kernel.pbFacingTerrainTag
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction)
  if (!pbIsWaterTag?(terrain) && !pbIsGrimeTag?(terrain)) ||
     (!notCliff && !$PokemonGlobal.surfing) # lavasurfing if needed
    Kernel.pbMessage(_INTL("Can't use that here."))
    next
  end

  if $game_switches[:Riding_Tauros]
    Kernel.pbMessage(_INTL("You can't fish while riding a Pokémon!"))
    next
  end

  encounter = $PokemonEncounters.hasEncounter?(EncounterTypes::OldRod)
  if pbFishing(encounter, 1)
    pbEncounter(EncounterTypes::OldRod)
  end
})

ItemHandlers::UseInField.add(:GOODROD, proc { |item|
  terrain = Kernel.pbFacingTerrainTag
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction)
  if (!pbIsWaterTag?(terrain) && !pbIsGrimeTag?(terrain)) ||
     (!notCliff && !$PokemonGlobal.surfing) # lavasurfing if needed
    Kernel.pbMessage(_INTL("Can't use that here."))
    next
  end

  if $game_switches[:Riding_Tauros]
    Kernel.pbMessage(_INTL("You can't fish while riding a Pokémon!"))
    next
  end

  encounter = $PokemonEncounters.hasEncounter?(EncounterTypes::GoodRod)
  if pbFishing(encounter, 2)
    pbEncounter(EncounterTypes::GoodRod)
  end
})

ItemHandlers::UseInField.add(:SUPERROD, proc { |item|
  terrain = Kernel.pbFacingTerrainTag
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction)
  if (!pbIsWaterTag?(terrain) && !pbIsGrimeTag?(terrain)) ||
     (!notCliff && !$PokemonGlobal.surfing) # lavasurfing if needed
    Kernel.pbMessage(_INTL("Can't use that here."))
    next
  end

  if $game_switches[:Riding_Tauros]
    Kernel.pbMessage(_INTL("You can't fish while riding a Pokémon!"))
    next
  end

  encounter = $PokemonEncounters.hasEncounter?(EncounterTypes::SuperRod)
  if pbFishing(encounter, 3)
    pbEncounter(EncounterTypes::SuperRod)
  end
})

ItemHandlers::UseInField.add(:ITEMFINDER, proc { |item|
  event = pbClosestHiddenItem
  pbSEPlay("itemfinder1")
  if !event
    Kernel.pbMessage(_INTL("... ... ... ...Nope!\nThere's no response."))
    next
  end

  offsetX = event.x - $game_player.x
  offsetY = event.y - $game_player.y
  if offsetX == 0 && offsetY == 0
    for i in 0...32
      Graphics.update
      Input.update
      $game_player.turn_right_90 if (i & 7) == 0
      pbUpdateSceneMap
    end
    pbSEPlay("itemfinder2")
    $scene.spriteset.addEventAnimation(ITEMFINDER_ANIMATION_ID, event, true)
    Kernel.pbMessage(_INTL("{1}'s indicating something right underfoot!\1", getItemName(item, :The)))
    next
  end

  direction = $game_player.direction
  if offsetX.abs > offsetY.abs
    direction = offsetX < 0 ? 4 : 6
  else
    direction = offsetY < 0 ? 8 : 2
  end
  for i in 0...8
    Graphics.update
    Input.update
    if i == 0
      $game_player.turn_down if direction == 2
      $game_player.turn_left if direction == 4
      $game_player.turn_right if direction == 6
      $game_player.turn_up if direction == 8
    end
    pbUpdateSceneMap
  end
  pitch = 100 - (offsetY <=> 0) * offsetY.abs
  angle = Math.atan2(offsetY, offsetX)
  volume = 100 - 10 * (Math.sqrt(offsetX.abs * offsetX.abs + offsetY.abs * offsetY.abs) - 1)
  pbSEPlay("itemfinder2", volume, pitch, x: Math.cos(angle), y: Math.sin(angle))
  $scene.spriteset.addEventAnimation(ITEMFINDER_ANIMATION_ID, event, true)
  # Kernel.pbMessage(_INTL("Huh?\n{1}'s responding!\1",getItemName(item, :The)))
  # Kernel.pbMessage(_INTL("There's an item buried around here!"))
  if $game_switches[:Blindstep]
    message = "There's an item "
    if offsetX < 0
      message += (-1 * offsetX).to_s + " tile"
      message += offsetX != -1 ? "s" : ""
      message += " left"
      message += offsetY != 0 ? " and " : ""
    elsif offsetX > 0
      message += (offsetX).to_s + " tile"
      message += offsetX != 1 ? "s" : ""
      message += " right"
      message += offsetY != 0 ? " and " : ""
    end
    if offsetY < 0
      message += (-1 * offsetY).to_s + " tile"
      message += offsetY != -1 ? "s" : ""
      message += " up"
    elsif offsetY > 0
      message += (offsetY).to_s + " tile"
      message += offsetY != 1 ? "s" : ""
      message += " down"
    end
    message += " from here!"
    Kernel.pbMessage(message)
  end
})

ItemHandlers::UseInField.copy(:ITEMFINDER, :DOWSINGMCHN)

ItemHandlers::UseInField.add(:TOWNMAP, proc { |item|
  pbShowMap(-1, false)
})

ItemHandlers::UseInField.add(:COINCASE, proc { |item|
  Kernel.pbMessage(getCurrencyDisplay($PokemonGlobal.coins, shorthand: false, currency: :Coins))
})

ItemHandlers::UseInField.add(:MONEYBAGS, proc { |item|
  Kernel.pbMessage(_INTL("Money: {1}$", $game_variables[:MoneyBags]))
})

ItemHandlers::UseInField.add(:MEMBERSHIPCARD, proc { |item|
  # Kernel.pbMessage(_INTL("Stickers: {1}",$game_variables[175]))
  $game_switches[:Show_Department_Card] = true
})

ItemHandlers::UseInField.add(:DEXCERTIFICATE, proc { |item|
  $game_switches[:Show_Dex_Certificate] = true
})

ItemHandlers::UseInField.add(:SPIRITTRACKER, proc { |item|
  Kernel.pbMessage(_INTL("Spirits released: {1}", $game_variables[548]))
})

# ItemHandlers::UseInField.add(:POKEBLOCKCASE,proc{|item|
#   Kernel.pbMessage(_INTL("Can't use that here."))
# })

ItemHandlers::UseInField.add(:BLUEORB3, proc { |item|
  $game_switches[:Blue_Orb_Quest] = true
})

ItemHandlers::UseInField.add(:GATHERCUBE, proc { |item|
  if Rejuv
    pbInfoBox(2)
  else
    Kernel.pbMessage(_INTL("Z-cells gathered: {1}", $game_variables[:Z_Cells]))
  end
})

ItemHandlers::UseInField.add(:GOLDENWINGS, proc { |item|
  next unless pbGoldenItemCheck(item)

  ret = pbSelectFlyLocation()
  if ret
    $PokemonTemp.flydata = ret
    Kernel.pbUseHiddenMove(:Trainer, :FLY)
  end
})

ItemHandlers::UseInField.add(:GOLDENLANTERN, proc { |item|
  next unless pbGoldenItemCheck(item)

  Kernel.pbUseHiddenMove(:Trainer, :FLASH)
})

ItemHandlers::UseInField.add(:WAILMERPAIL, proc { |item|
  facingEvent = $game_player.pbFacingEvent
  next unless facingEvent
  berryData = facingEvent.variable
  pbWaterBerry(berryData)
})

ItemHandlers::UseInField.copy(:WAILMERPAIL, :SPRAYDUCK, :SQUIRTBOTTLE)

#===============================================================================
# BattleUseOnPokemon handlers
#===============================================================================

ItemHandlers::BattleUseOnPokemon.addIf( # HP restoring consumables
  proc { |item|
    medicine = $cache.items[item].medicine
    medicine && medicine.hp && !medicine.status
  },
  proc { |item, pokemon, battler, scene|
    amount = $cache.items[item].medicine.hp
    if pbHPItem(pokemon, battler, amount, scene)
      happiness = $cache.items[item].medicine.happiness
      pokemon.changeHappiness(happiness) if happiness
      next true
    end
    next false
  }
)

ItemHandlers::BattleUseOnPokemon.addIf( # Status healing consumables
  proc { |item|
    medicine = $cache.items[item].medicine
    medicine && medicine.status && !medicine.hp
  },
  proc { |item, pokemon, battler, scene|
    status = $cache.items[item].medicine.status
    if pbStatusItem(pokemon, battler, status, scene) && pokemon.status != :PETRIFIED
      happiness = $cache.items[item].medicine.happiness
      pokemon.changeHappiness(happiness) if happiness
      next true
    end
    next false
  }
)

ItemHandlers::BattleUseOnPokemon.add(:MAGICMOOMILK, proc { |item, pokemon, battler, scene|
  amount = $cache.items[item].medicine.hp
  if pbHPItem(pokemon, battler, amount, scene)
    # scene.pbDisplay(_INTL("PP was restored.")) # Currently unsupported
    next true
  end
  next false
})

ItemHandlers::BattleUseOnPokemon.addIf( # Full Restore
  proc { |item|
    medicine = $cache.items[item].medicine
    medicine && medicine.hp && medicine.status
  },
  proc { |item, pokemon, battler, scene|
    if pokemon.hp <= 0 || pokemon.status == :PETRIFIED || (pokemon.status.nil? && pokemon.hp == pokemon.totalhp &&
       (!battler || battler.effects[:Confusion] == 0))
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    else
      scene.pbCommonAnimation("UseItemBag", battler, nil) if battler
      medicine = $cache.items[item].medicine
      pbItemCureStatus(pokemon, battler, medicine.status, scene)
      pbItemRestoreHP(pokemon, battler, medicine.hp, scene)
      happiness = $cache.items[item].medicine.happiness
      pokemon.changeHappiness(happiness) if happiness
      next true
    end
  }
)

ItemHandlers::BattleUseOnPokemon.addIf( # Revival consumables
  proc { |item|
    medicine = $cache.items[item].medicine
    medicine && medicine.revive && item != :SACREDASH
  },
  proc { |item, pokemon, battler, scene|
    amount = $cache.items[item].medicine.revive
    if pbReviveItem(pokemon, battler, amount, scene)
      happiness = $cache.items[item].medicine.happiness
      pokemon.changeHappiness(happiness) if happiness
      next true
    end
    next false
  }
)

ItemHandlers::BattleUseOnPokemon.add(:POKESNAX, proc { |item, pokemon, battler, scene|
  if pokemon.happiness == 255
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.changeHappiness(:LevelUp)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} ate {2} happily!", pokemon.name, getItemName(item, :the, useunit: false)))
    next true
  end
})

ItemHandlers::BattleUseOnPokemon.copy(:POKESNAX, :GOURMETTREAT)

ItemHandlers::BattleUseOnPokemon.add(:ETHER, proc { |item, pokemon, battler, scene|
  #   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
  #   if move>=0
  #     if pbBattleRestorePP(pokemon,battler,move,10)==0
  #       scene.pbDisplay(_INTL("It won't have any effect."))
  #       next false
  #     else
  scene.pbCommonAnimation("UseItemBag", battler, nil) if battler
  scene.pbDisplay(_INTL("PP was restored."))
  next true
  #     end
  #   end
  #   next false
})

ItemHandlers::BattleUseOnPokemon.copy(:ETHER, :LEPPABERRY)

ItemHandlers::BattleUseOnPokemon.add(:MAXETHER, proc { |item, pokemon, battler, scene|
  #   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
  #   if move>=0
  #     if pbBattleRestorePP(pokemon,battler,move,pokemon.moves[move].totalpp-pokemon.moves[move].pp)==0
  #       scene.pbDisplay(_INTL("It won't have any effect."))
  #       next false
  #     else
  scene.pbCommonAnimation("UseItemBag", battler, nil) if battler
  scene.pbDisplay(_INTL("PP was restored."))
  next true
  #     end
  #   end
  #   next false
})
ItemHandlers::BattleUseOnPokemon.add(:ELIXIR, proc { |item, pokemon, battler, scene|
  pprestored = 0
  for i in 0...pokemon.moves.length
    pprestored += pbBattleRestorePP(pokemon, battler, i, 10)
  end
  if pprestored == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    scene.pbCommonAnimation("UseItemBag", battler, nil) if battler
    scene.pbDisplay(_INTL("PP was restored."))
    next true
  end
})

ItemHandlers::BattleUseOnPokemon.copy(:ELIXIR, :ROSETEA)

ItemHandlers::BattleUseOnPokemon.add(:MAXELIXIR, proc { |item, pokemon, battler, scene|
  pprestored = 0
  for i in 0...pokemon.moves.length
    pprestored += pbBattleRestorePP(pokemon, battler, i, pokemon.moves[i].totalpp - pokemon.moves[i].pp)
  end
  if pprestored == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    scene.pbCommonAnimation("UseItemBag", battler, nil) if battler
    scene.pbDisplay(_INTL("PP was restored."))
    next true
  end
})

ItemHandlers::BattleUseOnPokemon.add(:PERSIMBERRY, proc { |item, pokemon, battler, scene|
  if battler && battler.effects[:Confusion] > 0
    scene.pbCommonAnimation("UseItemBag", battler, nil)
    battler.pbCureConfusion
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

#===============================================================================
# BattleUseOnBattler handlers
#===============================================================================

ItemHandlers::BattleUseOnBattler.addIf(
  lambda { |item| $cache.items[item].medicine&.xitem },
  lambda { |item, battler, scene|
    stat, amount = $cache.items[item].medicine.xitem[:stat], $cache.items[item].medicine.xitem[:amount]
    playername = battler.battle.pbPlayer.name
    scene.pbCommonAnimation("UseItemBag", battler, nil)
    scene.pbDisplay(_INTL("{1} used {2}.", playername, getItemName(item, :the)))
    if battler.pbChangeStats(stat, amount, battler, nil)
      battler.pokemon.changeHappiness(:XItem)
      return true
    else
      scene.pbDisplay(_INTL("But it had no effect!"))
      return false
    end
  }
)

ItemHandlers::BattleUseOnBattler.add(:DIREHIT, lambda { |item, battler, scene|
  playername = battler.battle.pbPlayer.name
  scene.pbDisplay(_INTL("{1} used {2}.", playername, getItemName(item, :the)))
  if battler.effects[:FocusEnergy] >= 2
    scene.pbDisplay(_INTL("But it had no effect!"))
    return false
  else
    battler.effects[:FocusEnergy] = 2
    battler.pokemon.changeHappiness(:XItem)
    scene.pbDisplay(_INTL("{1} is getting pumped!", battler.pbThis))
    return true
  end
})

ItemHandlers::BattleUseOnBattler.copy(:DIREHIT, :DIREHIT2)

ItemHandlers::BattleUseOnBattler.add(:DIREHIT3, lambda { |item, battler, scene|
  playername = battler.battle.pbPlayer.name
  scene.pbDisplay(_INTL("{1} used {2}.", playername, getItemName(item, :the)))
  if battler.effects[:FocusEnergy] >= 3
    scene.pbDisplay(_INTL("But it had no effect!"))
    return false
  else
    battler.effects[:FocusEnergy] = 3
    battler.pokemon.changeHappiness(:XItem)
    scene.pbDisplay(_INTL("{1} is getting pumped!", battler.pbThis))
    return true
  end
})

ItemHandlers::BattleUseOnBattler.add(:GUARDSPEC, lambda { |item, battler, scene|
  playername = battler.battle.pbPlayer.name
  scene.pbDisplay(_INTL("{1} used {2}.", playername, getItemName(item, :the)))
  if battler.pbOwnSide.effects[:Mist] > 0
    scene.pbDisplay(_INTL("But it had no effect!"))
    return false
  else
    battler.pbOwnSide.effects[:Mist] = 5
    battler.pokemon.changeHappiness(:XItem)
    if !battler.pbIsOpposing?(battler.index) # Item not implemented for enemies. Messages may be incorrect for them if it is.
      scene.pbDisplay(_INTL("Your team became shrouded in mist!"))
    else
      scene.pbDisplay(_INTL("The foe's team became shrouded in mist!"))
    end
    return true
  end
})

#===============================================================================
# UseInBattle handlers
# The BattleUseOnBattler handlers are used for checks before actually using the item, via checkUseInBattle
# While the UseInBattle handlers are used to carry out the actual usage, via triggerUseInBattle
# UseInBattle return values: 0 = Not used, 1 = Used and consumed, 2 = Used but not consumed
#===============================================================================
ItemHandlers::BattleUseOnBattler.add(:POKEDOLL, lambda { |item, battler, scene|
  battle = battler.battle
  if battle.opponent || battler.pbOpposing1.isbossmon || battler.pbOpposing2.isbossmon
    scene.pbDisplayCommandPaused(_INTL("Can't use that here.")) if scene
    return false
  end
  return true
})
ItemHandlers::BattleUseOnBattler.copy(:POKEDOLL, :FLUFFYTAIL, :POKETOY)

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  playername = battle.pbPlayer.name
  battle.pbDisplay(_INTL("{1} used {2}.", playername, getItemName(item, :the)))
  battle.decision = 3
  pbSEPlay("escape", 100)
  battle.pbDisplayAutoPaused(_INTL("Got away safely!"))
  next 1
})
ItemHandlers::UseInBattle.copy(:POKEDOLL, :FLUFFYTAIL, :POKETOY)

ItemHandlers::BattleUseOnBattler.addIf(
  lambda { |item| pbIsPokeBall?(item) }, # Any Poké Ball
  lambda { |item, battler, scene|
    battle = battler.battle
    target1, target2 = battler.pbOpposing1, battler.pbOpposing2
    failure = case true
      when target1.isFainted? && target2.isFainted? then :BothFainted
      when battle.pbIsWild? && !target1.isFainted? && !target2.isFainted? then :TwoWildMons
      when (target1.isFainted? || target1.isSemiInvul?) && (target2.isFainted? || target2.isSemiInvul?) then :BothSemiInvul
      when battle.pbPlayer.party.length >= 6 && $PokemonStorage.full? then :NoRoom
      else nil
    end
    return true unless failure

    if scene # scene is nil when no messages are required, used for pokeball shortcut feature
      message = case failure
        when :BothFainted then _INTL("There's no Pokémon to aim the Poké Ball at!")
        when :TwoWildMons then _INTL("It's no good! It's impossible to aim when there are two Pokémon!")
        when :BothSemiInvul then _INTL("It's no good! It's impossible to aim at a Pokémon that's not in sight!")
        when :NoRoom then _INTL("The boxes are full! You can't catch anymore Pokémon!")
        else nil
      end
      scene.pbDisplayCommandPaused(message) if message
    end
    return false
  }
)

ItemHandlers::UseInBattle.addIf(
  proc { |item| pbIsPokeBall?(item) }, # Any Poké Ball
  proc { |item, battler, battle|
    ret = battle.pbThrowPokeBall(battler.index, item)
    next ret ? 1 : 0
  }
)

ItemHandlers::BattleUseOnBattler.add(:BLUEFLUTE, lambda { |item, battler, scene|
  if battler.status != :SLEEP
    scene.pbDisplayCommandPaused(_INTL("It won't have any effect.")) if scene
    return false
  end
  return true
})
ItemHandlers::BattleUseOnBattler.copy(:BLUEFLUTE, :POKEFLUTE)

ItemHandlers::UseInBattle.add(:BLUEFLUTE, proc { |item, battler, battle|
  pbStatusItem(battler.pokemon, battler, :SLEEP, battle.scene)
  next 2
})
ItemHandlers::UseInBattle.copy(:BLUEFLUTE, :POKEFLUTE)

ItemHandlers::BattleUseOnBattler.add(:YELLOWFLUTE, lambda { |item, battler, scene|
  if battler.effects[:Confusion] <= 0
    scene.pbDisplayCommandPaused(_INTL("It won't have any effect.")) if scene
    return false
  end
  return true
})

ItemHandlers::UseInBattle.add(:YELLOWFLUTE, proc { |item, battler, battle|
  battle.pbCommonAnimation("UseItemBag", battler, nil)
  battler.pbCureConfusion
  next 2
})

ItemHandlers::BattleUseOnBattler.add(:REDFLUTE, lambda { |item, battler, scene|
  if battler.effects[:Attract] < 0
    scene.pbDisplayCommandPaused(_INTL("It won't have any effect.")) if scene
    return false
  end
  return true
})

ItemHandlers::UseInBattle.add(:REDFLUTE, proc { |item, battler, battle|
  battle.pbCommonAnimation("UseItemBag", battler, nil)
  battler.effects[:Attract] = -1
  battle.pbDisplay(_INTL("{1} got over its infatuation.", battler.pokemon.name))
  next 2
})

def pbPurify(pokemon, scene)
  return unless pokemon.heartgauge == 0 && pokemon.shadow
  return if !pokemon.savedev && !pokemon.savedexp

  pokemon.shadow = false
  pokemon.purified = true
  # pokemon.giveRibbon(PBRibbons::NATIONAL)
  scene.pbDisplay(_INTL("{1} opened the door to its heart!", pokemon.name))
  oldmoves = []
  for i in 0...4
    if pokemon.moves[i]
      oldmoves.push(pokemon.moves[i].move)
    else
      oldmoves.push(nil)
    end
  end
  pokemon.pbUpdateShadowMoves()
  for i in 0...4
    if !pokemon.moves[i].nil? && pokemon.moves[i].move != oldmoves[i]
      scene.pbDisplay(_INTL("{1} regained the move \n{2}!", pokemon.name, getMoveName(pokemon.moves[i].move)))
    end
  end
  pokemon.pbRecordFirstMoves
  if pokemon.savedev
    for i in 0...6
      pbApplyEVGain(pokemon, i, pokemon.savedev[i])
    end
    pokemon.savedev = nil
  end
  totalExpNeeded = PBExp.startExperience(LEVELCAPS[$Trainer.numbadges], pokemon.growthrate)
  currExpNeeded = totalExpNeeded - pokemon.exp
  exp = [currExpNeeded, pokemon.savedexp].min
  newexp = PBExp.addExperience(pokemon.exp, exp || 0, pokemon.growthrate)
  pokemon.savedexp = nil
  newlevel = PBExp.levelFromExperience(newexp, pokemon.growthrate)
  curlevel = pokemon.level
  if newexp != pokemon.exp
    scene.pbDisplay(_INTL("{1} regained {2} Exp. Points!", pokemon.name, newexp - pokemon.exp))
  end
  if newlevel == curlevel
    pokemon.exp = newexp
    pokemon.calcStats
  else
    pbChangeLevel(pokemon, newlevel, scene) # for convenience
    pokemon.exp = newexp
  end
  speciesname = getMonName(pokemon.species, pokemon.form)
  if $Settings.nicknames == 0
    if scene.pbConfirm(_INTL("Would you like to give a nickname to {1}?", speciesname))
      helptext = _INTL("{1}'s nickname?", speciesname)
      newname = pbEnterPokemonName(helptext, 0, 12, "", pokemon)
      pokemon.name = newname if newname != ""
    end
  end
end

class PokemonTemp
  attr_accessor :heartgauges
end

class PokeBattle_Pokemon
  attr_accessor :purified # denotes a former shadow pokemon
end

Events.onStartBattle += proc {
  $PokemonTemp.heartgauges = []
  for i in 0...$Trainer.party.length
    $PokemonTemp.heartgauges[i] = $Trainer.party[i].heartgauge
  end
}

Events.onEndBattle += proc { |sender, e|
  for i in 0...$PokemonTemp.heartgauges.length
    pokemon = $Trainer.party[i]
    if pokemon && ($PokemonTemp.heartgauges[i] &&
       $PokemonTemp.heartgauges[i] != 0 && pokemon.heartgauge == 0)
      pbReadyToPurify(pokemon)
    end
  end
}



# Scene class for handling appearance of the screen
class RelicStoneScene
  # Processes the scene
  def pbPurify()
  end

  # Update the scene here, this is called once each frame
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  # End the scene here
  def pbEndScene
    # Fade out all sprites
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Dispose all sprites
    pbDisposeSpriteHash(@sprites)
    # Dispose the viewport
    @viewport.dispose
  end

  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(
      @sprites["msgwindow"], msg, brief
    ) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(
      @sprites["msgwindow"], msg
    ) { pbUpdate }
  end

  def pbStartScene(pokemon)
    # Create sprite hash
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @pokemon = pokemon
    addBackgroundPlane(@sprites, "bg", "relicstonebg", @viewport)
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible = true
    @sprites["msgwindow"].viewport = @viewport
    @sprites["msgwindow"].text = ""
    @sprites["msgwindow"].x = 0
    @sprites["msgwindow"].y = Graphics.height - 96
    @sprites["msgwindow"].width = Graphics.width
    @sprites["msgwindow"].height = 96
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end

# Screen class for handling game logic
class RelicStoneScreen
  def initialize(scene)
    @scene = scene
  end

  def pbDisplay(x)
    @scene.pbDisplay(x)
  end

  def pbConfirm(x)
    @scene.pbConfirm(x)
  end

  def pbRefresh
  end

  def pbStartScreen(pokemon)
    @scene.pbStartScene(pokemon)
    @scene.pbPurify()
    pbPurify(pokemon, self)
    @scene.pbEndScene()
  end
end

def pbRelicStoneScreen(pokemon)
  retval = true
  pbFadeOutIn(99999) {
    scene = RelicStoneScene.new
    screen = RelicStoneScreen.new(scene)
    retval = screen.pbStartScreen(pokemon)
  }
  return retval
end

def pbIsPurifiable?(pkmn)
  return false if !pkmn
  if pkmn.isShadow? && pkmn.heartgauge == 0 &&
     !(pkmn.species == :LUGIA)
    return true
  end

  return false
end

def pbHasPurifiableInParty()
  return $Trainer.party.any? { |item| pbIsPurifiable?(item) }
end

def pbRelicStone()
  if pbHasPurifiableInParty()
    Kernel.pbMessage(_INTL("There's a Pokémon that may open the door to its heart!"))
    # Choose a purifiable Pokemon
    pbChoosePokemon(1, 2, proc { |poke|
      !poke.isEgg? && poke.hp > 0 && poke.isShadow? && poke.heartgauge == 0
    })
    if $game_variables[1] >= 0
      pbRelicStoneScreen($Trainer.party[$game_variables[1]])
    end
  else
    Kernel.pbMessage(_INTL("You have no Pokémon that can be purified."))
  end
end

def pbRaiseHappinessAndReduceHeart(pokemon, scene, amount)
  if !pokemon.isShadow?
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  if pokemon.happiness == 255 && pokemon.heartgauge == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  elsif pokemon.happiness == 255
    pokemon.adjustHeart(-amount)
    scene.pbDisplay(_INTL("{1} adores you!\nThe door to its heart opened a little.", pokemon.name))
    pbReadyToPurify(pokemon)
    return true
  elsif pokemon.heartgauge == 0
    pokemon.changeHappiness(:Vitamin)
    scene.pbDisplay(_INTL("{1} turned friendly.", pokemon.name))
    return true
  else
    pokemon.changeHappiness(:Vitamin)
    pokemon.adjustHeart(-amount)
    scene.pbDisplay(_INTL("{1} turned friendly.\nThe door to its heart opened a little.", pokemon.name))
    pbReadyToPurify(pokemon)
    return true
  end
end

ItemHandlers::UseOnPokemon.add(:JOYSCENT, proc { |item, pokemon, scene|
  next pbRaiseHappinessAndReduceHeart(pokemon, scene, 500)
})

ItemHandlers::UseOnPokemon.add(:EXCITESCENT, proc { |item, pokemon, scene|
  next pbRaiseHappinessAndReduceHeart(pokemon, scene, 1000)
})

ItemHandlers::UseOnPokemon.add(:VIVIDSCENT, proc { |item, pokemon, scene|
  next pbRaiseHappinessAndReduceHeart(pokemon, scene, 2000)
})

ItemHandlers::UseOnPokemon.add(:TIMEFLUTE, proc { |item, pokemon, scene|
  pbRaiseHappinessAndReduceHeart(pokemon, scene, 5000)
  next false
})

def pbApplyEVGain(pokemon, ev, evgain)
  totalev = 0
  for i in 0...6
    totalev += pokemon.ev[i]
  end
  if totalev + evgain > 510 # Can't exceed overall limit
    evgain -= totalev + evgain - 510
  end
  if pokemon.ev[ev] + evgain > 255
    evgain -= totalev + evgain - 255
  end
  if evgain > 0
    pokemon.ev[ev] += evgain
  end
end

def pbReplaceMoves(pokemon, move1, move2 = 0, move3 = 0, move4 = 0)
  return if !pokemon

  [move1, move2, move3, move4].each { |move|
    moveIndex = -1
    if move != 0
      # Look for given move
      for i in 0...4
        next if pokemon.moves[i].nil?

        moveIndex = i if pokemon.moves[i].move == move
      end
    end
    if moveIndex == -1
      # Look for slot to replace move
      for i in 0...4
        if move != 0 && (pokemon.moves[i].nil? || (
            pokemon.moves[i].move != move1 &&
            pokemon.moves[i].move != move2 &&
            pokemon.moves[i].move != move3 &&
            pokemon.moves[i].move != move4))
          # Replace move
          pokemon.moves[i] = PBMove.new(move)
          break
        elsif move == 0 && (pokemon.moves[i].nil? || (
            pokemon.moves[i].move != move1 &&
            pokemon.moves[i].move != move2 &&
            pokemon.moves[i].move != move3 &&
            pokemon.moves[i].move != move4))
          pbDeleteMove(pokemon, i)
          break
        end
      end
    end
  }
end

def pbReadyToPurify(pokemon)
  return if !pokemon || !pokemon.isShadow?

  pokemon.pbUpdateShadowMoves()
  if pokemon.heartgauge == 0
    Kernel.pbMessage(_INTL("{1} can now be purified!", pokemon.name))
  end
end

Events.onStepTaken += proc {
  for pkmn in $Trainer.party
    if pkmn.hp > 0 && !pkmn.isEgg? && pkmn.heartgauge > 0
      pkmn.adjustHeart(-1)
      pbReadyToPurify(pkmn) if pkmn.heartgauge == 0
    end
  end
  if ($PokemonGlobal.purifyChamber rescue nil)
    $PokemonGlobal.purifyChamber.update
  end
  for i in 0...2
    pkmn = $PokemonGlobal.daycare[i][0]
    next if !pkmn

    pkmn.adjustHeart(-1)
    pkmn.pbUpdateShadowMoves()
  end
}

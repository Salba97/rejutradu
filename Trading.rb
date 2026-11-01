class PokemonTradeScene
  def pbRunPictures(pictures, sprites)
    loop do
      for i in 0...pictures.length
        pictures[i].update
      end
      for i in 0...sprites.length
        if sprites[i].is_a?(IconSprite)
          setPictureIconSprite(sprites[i], pictures[i])
        else
          setPictureSprite(sprites[i], pictures[i])
        end
      end
      Graphics.update
      Input.update
      running = false
      for i in 0...pictures.length
        running = true if pictures[i].running?
      end
      break if !running
    end
  end

  def pbStartScreen(pokemon, pokemon2, trader1, trader2)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @pokemon = pokemon
    @pokemon2 = pokemon2
    @trader1 = trader1
    @trader2 = trader2
    addBackgroundOrColoredPlane(@sprites, "background", "tradebg", Color.new(248, 248, 248), @viewport)
    rsprite1 = PokemonSprite.new(@viewport)
    rsprite1.setPokemonBitmap(@pokemon, false)
    rsprite1.ox = rsprite1.bitmap.width / 2
    rsprite1.oy = rsprite1.bitmap.height / 2
    rsprite1.x = Graphics.width / 2
    rsprite1.y = (Graphics.height - 96) * 2 / 3
    @sprites["rsprite1"] = rsprite1
    rsprite2 = PokemonSprite.new(@viewport)
    rsprite2.setPokemonBitmap(@pokemon2, false)
    rsprite2.ox = rsprite2.bitmap.width / 2
    rsprite2.oy = rsprite2.bitmap.height / 2
    rsprite2.x = Graphics.width / 2
    rsprite2.y = (Graphics.height - 96) * 2 / 3
    rsprite2.visible = false
    @sprites["rsprite2"] = rsprite2
    @sprites["msgwindow"] = Kernel.pbCreateMessageWindow(@viewport)
    pbFadeInAndShow(@sprites)
  end

  def pbScene1
    spriteBall = IconSprite.new(0, 0, @viewport)
    pictureBall = PictureEx.new(0)
    picturePoke = PictureEx.new(0)
    # Starting position of ball
    pictureBall.moveVisible(1, true)
    pictureBall.moveName(1, sprintf("Graphics/Pictures/Battle/%s", @pokemon.ballused))
    pictureBall.moveOrigin(1, PictureOrigin::Center)
    pictureBall.moveXY(0, 1, Graphics.width / 2, 48)
    # Starting position of sprite
    picturePoke.moveVisible(1, true)
    picturePoke.moveOrigin(1, PictureOrigin::Center)
    rsprite1 = @sprites["rsprite1"]
    rsprite1.ox = 0
    rsprite1.oy = 0
    picturePoke.moveXY(0, 1, rsprite1.x, rsprite1.y)
    # Change sprite color
    delay = picturePoke.totalDuration + 4
    picturePoke.moveColor(10, delay, Color.new(31 * 8, 22 * 8, 30 * 8, 255))
    # Recall
    delay = picturePoke.totalDuration
    picturePoke.moveSE(delay, "Audio/SE/recall")
    pictureBall.moveName(delay, sprintf("Graphics/Pictures/Battle/%s_open", @pokemon.ballused))
    # Move sprite to ball
    picturePoke.moveZoom(15, delay, 0)
    picturePoke.moveXY(15, delay, Graphics.width / 2, 48)
    picturePoke.moveSE(delay + 10, "Audio/SE/jumptoball")
    picturePoke.moveVisible(delay + 15, false)
    pictureBall.moveName(picturePoke.totalDuration + 2, sprintf("Graphics/Pictures/Battle/%s", @pokemon.ballused))
    delay = picturePoke.totalDuration + 20
    pictureBall.moveXY(12, delay, Graphics.width / 2, -32)
    pbRunPictures(
      [picturePoke, pictureBall],
      [@sprites["rsprite1"], spriteBall]
    )
    spriteBall.dispose
  end

  def pbScene2
    spriteBall = IconSprite.new(0, 0, @viewport)
    pictureBall = PictureEx.new(0)
    picturePoke = PictureEx.new(0)
    # Starting position of ball
    pictureBall.moveVisible(1, true)
    pictureBall.moveName(1, sprintf("Graphics/Pictures/Battle/%s", @pokemon2.ballused))
    pictureBall.moveOrigin(1, PictureOrigin::Center)
    pictureBall.moveXY(0, 1, Graphics.width / 2, -32)
    # Starting position of sprite
    picturePoke.moveVisible(1, false)
    picturePoke.moveOrigin(1, PictureOrigin::Center)
    picturePoke.moveZoom(0, 1, 0)
    picturePoke.moveColor(0, 1, Color.new(31 * 8, 22 * 8, 30 * 8, 255))
    # Dropping ball
    y = Graphics.height - 96 - 16
    delay = picturePoke.totalDuration + 4
    pictureBall.moveXY(15, delay, Graphics.width / 2, y)
    pictureBall.moveSE(pictureBall.totalDuration, "Audio/SE/balldrop")
    pictureBall.moveXY(8, pictureBall.totalDuration + 2, Graphics.width / 2, y - 60)
    pictureBall.moveXY(7, pictureBall.totalDuration + 2, Graphics.width / 2, y)
    pictureBall.moveSE(pictureBall.totalDuration, "Audio/SE/balldrop")
    pictureBall.moveXY(6, pictureBall.totalDuration + 2, Graphics.width / 2, y - 40)
    pictureBall.moveXY(5, pictureBall.totalDuration + 2, Graphics.width / 2, y)
    pictureBall.moveSE(pictureBall.totalDuration, "Audio/SE/balldrop")
    pictureBall.moveXY(4, pictureBall.totalDuration + 2, Graphics.width / 2, y - 20)
    pictureBall.moveXY(3, pictureBall.totalDuration + 2, Graphics.width / 2, y)
    pictureBall.moveSE(pictureBall.totalDuration, "Audio/SE/balldrop")
    picturePoke.moveXY(0, pictureBall.totalDuration, Graphics.width / 2, y)
    delay = pictureBall.totalDuration + 18
    y = (Graphics.height - 96) * 2 / 3
    picturePoke.moveSE(delay, "Audio/SE/recall")
    cry = pbResolveAudioSE(pbCryFile(@pokemon2))
    picturePoke.moveSE(delay, cry) if cry
    pictureBall.moveName(delay, sprintf("Graphics/Pictures/Battle/%s", @pokemon2.ballused))
    pictureBall.moveVisible(delay + 10, false)
    picturePoke.moveVisible(delay, true)
    picturePoke.moveZoom(15, delay, 100)
    picturePoke.moveXY(15, delay, Graphics.width / 2, y)
    delay = picturePoke.totalDuration
    picturePoke.moveColor(10, delay, Color.new(31 * 8, 22 * 8, 30 * 8, 0))
    pbRunPictures(
      [picturePoke, pictureBall],
      [@sprites["rsprite2"], spriteBall]
    )
    spriteBall.dispose
  end

  def pbEndScreen
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"])
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    newspecies = checkEvolution(@pokemon2, tradedmon: @pokemon)
    if !newspecies.nil?
      pbCarryOutEvolution(@pokemon2, newspecies, cancancel: false)
    end
  end

  def pbTrade
    # @pokemon is pokemon being sent, @pokemon2 is pokemon being received
    pbBGMStop()
    pbBGMPlay("Evolution")
    pbPlayCry(@pokemon)
    speciesname1 = getMonName(@pokemon.species, @pokemon.form)
    speciesname2 = getMonName(@pokemon2.species, @pokemon2.form)
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
      _ISPRINTF("{1:s}\nID: {2:05d}   OT: {3:s}\\wtnp[0]", @pokemon.name, @pokemon.publicID, @pokemon.ot)
    )
    Kernel.pbMessageWaitForInput(@sprites["msgwindow"], 100, true)
    pbPlayDecisionSE()
    pbScene1
    message = case [@pokemon.isEgg?, @pokemon2.isEgg?]
      when [false, false] then _INTL("For {1}'s {2},\n{3} sends {4}.\1")
      when [true, false] then _INTL("For {1}'s {2} Egg,\n{3} sends {4}.\1")
      when [false, true] then _INTL("For {1}'s {2},\n{3} offers a mystery egg!\1")
      when [true, true] then _INTL("For {1}'s {2} Egg,\n{3} offers a mystery egg!\1")
    end
    Kernel.pbMessageDisplay(@sprites["msgwindow"], _INTL(message, @trader1, speciesname1, @trader2, speciesname2))
    Kernel.pbMessageDisplay(@sprites["msgwindow"], _INTL("{1} bids farewell to {2}.", @trader2, speciesname2)) unless @pokemon2.isEgg?
    pbScene2
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
      _ISPRINTF("{1:s}\nID: {2:05d}   OT: {3:s}\1", @pokemon2.name, @pokemon2.publicID, @pokemon2.ot)
    )
    message = @pokemon2.isEgg? ? _INTL("Take good care of it!") : _INTL("Take good care of {1}.")
    Kernel.pbMessageDisplay(@sprites["msgwindow"], _INTL(message, speciesname2))
    pbBGMStop()
  end
end

def pbStartTrade(pokemonIndex, newpoke, nickname, trainerName, onlineName = nil, newLevel = nil, form = 0)
  myPokemon = $Trainer.party[pokemonIndex]
  online = !onlineName.nil? && onlineName != false
  opponent = online ? PokeBattle_Trainer.new(trainerName, nil) : knownTrainer(trainerName)
  makeEgg = $game_switches[:Egg_Trade] # Used by in-game (non-online) trades
  newpoke = PokeBattle_Pokemon::PokemonBuilder.new(newpoke).build if newpoke.is_a?(Hash)
  if newpoke.is_a?(PokeBattle_Pokemon)
    yourPokemon = newpoke
  else
    level = makeEgg ? EGGINITIALLEVEL : (newLevel || myPokemon.level)
    yourPokemon = PokeBattle_Pokemon.new(newpoke, level, opponent, true, form)
  end
  if makeEgg
    yourPokemon.eggsteps = yourPokemon.getCacheData.EggSteps
  end
  unless yourPokemon.isEgg?
    $Trainer.pokedex.setOwned(yourPokemon)
    yourPokemon.pbRecordFirstMoves
  end
  yourPokemon.name = yourPokemon.isEgg? ? _INTL("Egg") : nickname
  yourPokemon.obtainMode = 2 # traded
  yourPokemon.obtainLevel = yourPokemon.level
  yourPokemon.happiness = yourPokemon.getCacheData.Happiness
  pbFadeOutInWithMusic(99999) {
    evo = PokemonTradeScene.new
    evo.pbStartScreen(myPokemon, yourPokemon, onlineName || $Trainer.name, opponent.name)
    evo.pbTrade
    evo.pbEndScreen
  }
  yourPokemon.item = myPokemon.item if !online && yourPokemon.item.nil?
  $Trainer.party[pokemonIndex] = yourPokemon
end

def get_wonder_gift(partyindex)
  return rand(2) == 0 ? get_wonder_gift_nyu : get_wonder_gift_random(partyindex)
end

def get_wonder_gift_nyu
  firststagelist = []
  $cache.pkmn.each { |species, data|
    next if pbGetBabySpecies(species)[0] != species && species != :PIKACHU
    next if [:MANAPHY, :DITTO].include?(species)
    next if data[0].EggGroups.include?(:Undiscovered) && species != :UNOWN
    firststagelist.push(species)
  }
  giftspecies = firststagelist.sample
  forms = getLegalForms(giftspecies)
  giftform = forms.keys.sample || 0
  gift = PokeBattle_Pokemon.new(giftspecies, 1, knownTrainer("Nyu"), true, giftform)
  gift.name = "Pikachu"
  gift.obtainMap = 299 # Nyu's House
  eggmove = $cache.pkmn[giftspecies, giftform].EggMoves.sample
  gift.pbLearnMove(eggmove) if eggmove
  return gift
end

def get_wonder_gift_random(partyindex)
  baseBSTVariance = 10 # Adjustable, change to a constant if a game-specific override is needed
  chosenMon = $Trainer.party[partyindex]
  chosenMonBST = pbBaseStatTotal(chosenMon.species, chosenMon.form)
  wonderMonSpecies, wonderMonForm = nil, nil
  bstVariance = baseBSTVariance
  loopCount = 0
  loop do
    randIndex = rand($cache.pkmn.length)
    wonderMonSpecies = $cache.pkmn.values[randIndex].mon
    forms = getLegalForms(wonderMonSpecies)
    wonderMonForm = forms.keys.sample
    if wonderMonForm.nil?
      # no-op
    elsif $game_switches[:Unlimited_Wondertrade]
      break if !chosenMon.isEgg? || pbCanBeEgg?(wonderMonSpecies, wonderMonForm)
    elsif (PBStuff::LEGENDARYLIST + PBStuff::ULTRABEASTS + PBStuff::PARADOXLIST).include?(wonderMonSpecies)
      # no-op
    elsif (chosenMonBST - pbBaseStatTotal(wonderMonSpecies, wonderMonForm)).abs <= bstVariance
      break if !chosenMon.isEgg? || pbCanBeEgg?(wonderMonSpecies, wonderMonForm)
    end
    loopCount += 1
    bstVariance += baseBSTVariance if loopCount >= 25
    loopCount = 0 if loopCount >= 25
  end
  trainerName = getRandomNameEx(rand(3), nil, 1, 7)
  gift = PokeBattle_Pokemon.new(wonderMonSpecies, chosenMon.level, PokeBattle_Trainer.new(trainerName, nil), true, wonderMonForm)
  gift.eggsteps = gift.getCacheData.EggSteps if chosenMon.isEgg? # Egg in return for egg
  gift.name = gift.isEgg? ? _INTL("Egg") : getRandomNameEx(rand(3), nil, 1, 7)
  return gift
end

# Use this method to test an 'offline' wonder trade (i = party index of pokemon to trade away)
def test_offline_wt(i)
  receivemon = get_wonder_gift(i)
  pbStartTrade(i, receivemon, receivemon.name, receivemon.ot, $Trainer.name)
end

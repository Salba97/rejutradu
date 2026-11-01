#===============================================================================
# * Egg Hatch Animation - by FL (Credits will be apreciated)
#                         Tweaked by Maruno
#===============================================================================
# This script is for Pokémon Essentials. It's an egg hatch animation that
# works even with special eggs like Manaphy egg.
#===============================================================================
# To this script works, put it above Main and put a picture (a 5 frames
# sprite sheet) with egg sprite height and 5 times the egg sprite width at
# Graphics/Battlers/eggCracks.
#===============================================================================
class PokemonEggHatchScene
  def pbStartScene(pokemon)
    @skipped = false
    @skippable = true
    @sprites = {}
    @pokemon = pokemon
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @pokemon.eggsteps = 1 # Just for drawing the egg
    addBackgroundOrColoredPlane(@sprites, "background", "hatchbg", Color.new(248, 248, 248), @viewport)
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokemon"].x = Graphics.width / 2 - @sprites["pokemon"].bitmap.width / 2
    @sprites["pokemon"].y = 32 + Graphics.height / 2 - @sprites["pokemon"].bitmap.height / 2
    @sprites["hatch"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 200
    @sprites["overlay"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["overlay"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(255, 255, 255))
    @sprites["overlay"].opacity = 0
    @pokemon.eggsteps = 0 # Correct egg steps again
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    crackfilename = sprintf("Graphics/Battlers/eggCracks")
    crackfilename = pbResolveBitmap(crackfilename)
    hatchSheet = AnimatedBitmap.new(crackfilename)
    pbBGMPlay("Evolution")
    # Egg animation
    updateScene(60)
    pbPositionHatchMask(hatchSheet, 0)
    pbSEPlay("ballshake") unless @skipped
    swingEgg(2)
    updateScene(8)
    pbPositionHatchMask(hatchSheet, 1)
    pbSEPlay("ballshake") unless @skipped
    swingEgg(2)
    updateScene(16)
    pbPositionHatchMask(hatchSheet, 2)
    pbSEPlay("ballshake") unless @skipped
    swingEgg(4, 2)
    updateScene(16)
    pbPositionHatchMask(hatchSheet, 3)
    pbSEPlay("ballshake") unless @skipped
    swingEgg(8, 4)
    updateScene(8)
    pbPositionHatchMask(hatchSheet, 4)
    pbSEPlay("recall")
    @skippable = false
    # Fade and change the sprite
    fadeSpeed = 15
    for i in 1..(255 / fadeSpeed)
      @sprites["pokemon"].tone = Tone.new(i * fadeSpeed, i * fadeSpeed, i * fadeSpeed)
      @sprites["overlay"].opacity = i * fadeSpeed
      updateScene
    end
    updateScene(30)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokemon"].x -= 64
    @sprites["pokemon"].y -= 64
    @sprites["hatch"].visible = false
    for i in 1..(255 / fadeSpeed)
      @sprites["pokemon"].tone = Tone.new(255 - i * fadeSpeed, 255 - i * fadeSpeed, 255 - i * fadeSpeed)
      @sprites["overlay"].opacity = 255 - i * fadeSpeed
      updateScene
    end
    @sprites["pokemon"].tone = Tone.new(0, 0, 0)
    @sprites["overlay"].opacity = 0
    # Finish scene
    frames = pbCryFrameLength(@newspecies)
    pbPlayCry(@pokemon)
    frames.times do
      Graphics.update
    end
    Kernel.pbMessage(_INTL("\\se[]{1} hatched from the Egg!\\wt[80]", @pokemon.name))
    if $Settings.nicknames == 0
      if Kernel.pbConfirmMessage(_INTL("Would you like to nickname the newly hatched {1}?", @pokemon.name))
        species = getMonName(@pokemon.species, @pokemon.form)
        nickname = pbEnterPokemonName(_INTL("{1}'s nickname?", @pokemon.name), 0, 12, "", @pokemon)
        @pokemon.name = nickname if nickname != ""
      end
    end
  end

  def pbPositionHatchMask(hatchSheet, index)
    @sprites["hatch"].bitmap.clear
    frames = 5
    frameWidth = hatchSheet.width / frames
    rect = Rect.new(frameWidth * index, 0, frameWidth, hatchSheet.height)
    @sprites["hatch"].bitmap.blt(@sprites["pokemon"].x - 44, @sprites["pokemon"].y - 44, hatchSheet.bitmap, rect)
  end

  def swingEgg(speed, swingTimes = 1) # Only accepts 2, 4 or 8 for speed.
    limit = 8
    targets = [@sprites["pokemon"].x - limit, @sprites["pokemon"].x + limit, @sprites["pokemon"].x]
    swingTimes.times do
      usedSpeed = speed
      for target in targets
        usedSpeed *= -1
        while target != @sprites["pokemon"].x
          @sprites["pokemon"].x += usedSpeed
          @sprites["hatch"].x += usedSpeed
          updateScene
        end
      end
    end
  end

  def updateScene(frames = 1) # Can be used for "wait" effect
    return if @skipped && @skippable

    frames.times do
      Graphics.update
      Input.update
      self.update
      if (Input.press?(Input::C) || Input.press?(Input::B)) && @skippable
        @skipped = true
        break
      end
    end
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class PokemonEggHatchScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(pokemon)
    @scene.pbStartScene(pokemon)
    @scene.pbMain
    @scene.pbEndScene
  end
end

def pbHatchAnimation(pokemon)
  Kernel.pbMessage(_INTL("Huh?\1"))
  pbFadeOutInWithMusic(99999) {
    scene = PokemonEggHatchScene.new
    screen = PokemonEggHatchScreen.new(scene)
    screen.pbStartScreen(pokemon)
  }
  return true
end

def pbHatch(pokemon)
  speciesname = getMonName(pokemon.species, pokemon.form)
  shiny = pokemon.isShiny?
  pokemon.name = speciesname
  # Rejuv has use cases of non-player OT and trainer ID for eggs
  pokemon.trainerID = pokemon.trainerID ? pokemon.trainerID : $Trainer.id
  pokemon.ot = pokemon.ot ? pokemon.ot : $Trainer.name
  if pokemon.isShiny? != shiny
    shiny ? pokemon.makeShiny : pokemon.makeNotShiny
  end
  pokemon.happiness = 120
  timediverge = $Settings.unrealTimeDiverge
  $Settings.unrealTimeDiverge = 0
  pokemon.timeEggHatched = pbCatchTime
  $Settings.unrealTimeDiverge = timediverge
  pokemon.obtainMode = 1 # hatched from egg
  pokemon.hatchedMap = $game_map.map_id
  $Trainer.pokedex.setOwned(pokemon)
  pokemon.pbRecordFirstMoves
  val = pbHatchAnimation(pokemon)
  # puts val
  # if val
  #   Kernel.pbMessage(_INTL("Huh?\1"))
  #   Kernel.pbMessage(_INTL("...\1"))
  #   Kernel.pbMessage(_INTL("... .... .....\1"))
  #   Kernel.pbMessage(_INTL("{1} hatched from the Egg!",speciesname))
  #   if Kernel.pbConfirmMessage(_INTL("Would you like to nickname the newly hatched {1}?",speciesname))
  #     species=getMonName(pokemon.species)
  #     nickname=pbEnterPokemonName(_INTL("{1}'s nickname?",speciesname),0,12,"",pokemon)
  #     pokemon.name=nickname if nickname!=""
  #   end
  # end
end

Events.onStepTaken += proc { |sender, e|
  next if !$Trainer

  for egg in $Trainer.party
    if egg.eggsteps > 0 && egg.status != :PETRIFIED
      egg.eggsteps -= 1
      for i in $Trainer.party
        if !i.isEgg? && [:FLAMEBODY, :MAGMAARMOR, :STEAMENGINE].include?(i.ability)
          egg.eggsteps -= 1
          break
        end
      end
      if egg.eggsteps <= 0
        egg.eggsteps = 0
        pbHatch(egg)
      end
    end
  end
}

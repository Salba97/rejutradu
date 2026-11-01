#===============================================================================
# * Hall of Fame - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It makes a recordable Hall of Fame
# like the Gen 3 games.
#
#===============================================================================
#
# To this scripts works, put it above main, put a 512x384 picture in
# hallfamebars and a 8x24 background picture in hallfamebg. To call this script,
# use 'pbHallOfFameEntry'. After you recorder the first entry, you can access
# the hall teams using a PC. You can also check the player Hall of Fame last
# number using '$PokemonGlobal.hallOfFameLastNumber'.
#
#===============================================================================
class HallOfFameScene
  # When true, all pokémon will be in one line
  # When false, all pokémon will be in two lines
  SINGLEROW = false
  # Make the pokémon movement ON in hall entry
  ANIMATION = true
  # Speed in pokémon movement in hall entry. Don't use less than 2!
  ANIMATIONSPEED = 32
  # Entry wait time between each pokémon (and trainer) is show
  ENTRYWAITTIME = 128
  # Maximum number limit of simultaneous hall entries saved.
  # 0 = Doesn't save any hall. -1 = no limit
  # Prefer to use larger numbers (like 500 and 1000) than don't put a limit
  # If a player exceed this limit, the first one will be removed
  HALLLIMIT = 50
  # The entry music name. Put "" to doesn't play anything
  ENTRYMUSIC = "Atmosphere- Credits"
  # Allow eggs to be show and saved in hall
  ALLOWEGGS = true
  # Remove the hallbars when the trainer sprite appears
  REMOVEBARS = true
  # The final fade speed on entry
  FINALFADESPEED = 16
  # Sprites opacity value when them aren't selected
  OPACITY = 64

  INFO_LINE_1_Y = 308
  INFO_LINE_2_Y = 340
  MOVE_NAME_1_X = 132
  MOVE_NAME_2_X = 332
  HEAD_COLORS = ColorArrays[:Orange2]
  INFO_COLORS_1 = ColorArrays[:Blue2]
  INFO_COLORS_2 = ColorArrays[:Green2]
  INFO_COLORS_3 = ColorArrays[:Red]
  INFO_COLORS_4 = ColorArrays[:Magenta]

  def initialize
    @infobox = 0
    @selected = false
    @hallEntry = []
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbUpdateAnimation
    if @battlerIndex <= @hallEntry.size
      if @xmovement[@battlerIndex] != 0 || @ymovement[@battlerIndex] != 0
        spriteIndex = (@battlerIndex < @hallEntry.size) ? @battlerIndex : -1
        moveSprite(spriteIndex)
      else
        @battlerIndex += 1
        if @battlerIndex <= @hallEntry.size
          # If it is a pokémon, write the pokémon text, wait the
          # ENTRYWAITTIME and goes to the next battler
          pbPlayCry(@hallEntry[@battlerIndex - 1])
          writePokemonData(@hallEntry[@battlerIndex - 1], -1)
          pbWait(ENTRYWAITTIME)
          if @battlerIndex < @hallEntry.size # Preparates the next battler
            setPokemonSpritesOpacity(@battlerIndex, OPACITY)
            @sprites["overlay"].bitmap.clear
          else # Show the welcome message and preparates the trainer
            setPokemonSpritesOpacity(-1)
            writeWelcome
            pbWait(ENTRYWAITTIME * 2)
            setPokemonSpritesOpacity(-1, OPACITY) if !SINGLEROW
            createTrainerBattler
          end
        end
      end
    elsif @battlerIndex > @hallEntry.size
      # Write the trainer data and fade
      writeTrainerData
      pbWait(ENTRYWAITTIME)
      fadeSpeed = ((Math.log(2**12) - Math.log(FINALFADESPEED)) / Math.log(2)).floor
      pbBGMFade((2**fadeSpeed).to_f / 20) if @useMusic
      slowFadeOut(@sprites, fadeSpeed) { pbUpdate }
      @alreadyFadedInEnd = true
      @battlerIndex += 1
    end
  end

  def pbUpdatePC(move = 0)
    @battlerIndex += move

    # Change the team
    previndex = @hallIndex
    if @battlerIndex > @hallEntry.size - 1 && move == 10
      @hallIndex -= 1
      # Go to first battler of previous page if navigating using Left/Right
      # Go to same battler index as selected on current page if navigating using Up/Down
      @battlerIndex = move == 1 ? 0 : @battlerIndex - 10
    end
    if @battlerIndex < 0 && move == -10
      @hallIndex += 1
      # Go to last battler of previous page if navigating using Left/Right
      # Go to same battler index as selected on current page if navigating using Up/Down
      @battlerIndex = move == -1 ? @hallEntry.size - 1 : @battlerIndex + 10
    end

    @hallIndex %= $PokemonGlobal.hallOfFame.size

    if @hallIndex != previndex
      @hallEntry = $PokemonGlobal.hallOfFame[@hallIndex]
      @battlerIndex = @hallEntry.size - 1 if @battlerIndex >= @hallEntry.size
      createBattlers(false)
    else
      @battlerIndex %= @hallEntry.size
    end

    # Change the pokemon
    pbPlayCry(@hallEntry[@battlerIndex]) if @selected
    setPokemonSpritesOpacity(@battlerIndex, OPACITY)
    setPokemonSpritesZ
    writePokemonData(@hallEntry[@battlerIndex])
  end

  def slowFadeOut(sprites, exponent) # 2 exponent
    # To handle values above 8
    extraWaitExponent = exponent - 9
    exponent = 8 if 8 < exponent
    max = 2**exponent
    speed = (2**8) / max
    for j in 0..max
      pbWait(2**extraWaitExponent) if extraWaitExponent > -1
      pbSetSpritesToColor(sprites, Color.new(0, 0, 0, j * speed))
      block_given? ? yield : pbUpdateSpriteHash(sprites)
    end
  end

  # Dispose the sprite if the sprite exists and make it null
  def restartSpritePosition(sprites, spritename)
    sprites[spritename].dispose if sprites.include?(spritename) && sprites[spritename]
    sprites[spritename] = nil
  end

  # Change the pokémon sprites opacity except the index one, if in selection mode
  def setPokemonSpritesOpacity(index, opacity = 255)
    for n in 0...@hallEntry.size
      next if !@sprites["pokemon#{n}"]
      @sprites["pokemon#{n}"].opacity = n == index || !@selected ? 255 : opacity
    end
  end

  def setPokemonSpritesZ
    for n in 0...@hallEntry.size
      next if !@sprites["pokemon#{n}"]
      @sprites["pokemon#{n}"].z = n == @battlerIndex && @selected ? 10 : 1
    end
  end

  # Placement for pokemon icons
  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Comment the below line to doesn't use a background
    addBackgroundPlane(@sprites, "bg", "hallfamebg", @viewport)
    @sprites["hallbars"] = IconSprite.new(@viewport)
    @sprites["hallbars"].setBitmap("Graphics/Pictures/hallfamebars")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 10
    @alreadyFadedInEnd = false
    @useMusic = false
    @battlerIndex = 0
  end

  def pbStartSceneEntry
    pbStartScene
    @useMusic = (ENTRYMUSIC && ENTRYMUSIC != "")
    pbBGMPlay(ENTRYMUSIC) if @useMusic
    saveHallEntry
    @xmovement = []
    @ymovement = []
    createBattlers
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartScenePC
    $PokemonGlobal.hallOfFame.each { |entry| entry.each { |pkmn| pkmn.healHP } } # For legacy saves
    pbStartScene
    @hallIndex = $PokemonGlobal.hallOfFame.size - 1
    @hallEntry = $PokemonGlobal.hallOfFame[-1]
    createBattlers(false)
    pbFadeInAndShow(@sprites) { pbUpdate }
    pbUpdatePC
  end

  def saveHallEntry
    for i in $Trainer.party
      next if i.isEgg? && !ALLOWEGGS
      # Clones every pokémon object, heals them so they have full HP cries when viewing the entry
      pkmn = i.clone
      pkmn.healHP
      @hallEntry.push(pkmn)
    end
    favPokeTracker(:hof)
    # Update the global variables
    $PokemonGlobal.hallOfFame.push(@hallEntry)
    $PokemonGlobal.hallOfFameLastNumber += 1
    $PokemonGlobal.hallOfFame.delete_at(0) if HALLLIMIT > -1 && $PokemonGlobal.hallOfFame.size > HALLLIMIT
  end

  # Return the x/y point position in screen for battler index number
  # Don't use odd numbers!
  def xpointformula(battlernumber)
    ret = 0
    if !SINGLEROW
      ret = 32 + 160 * xpositionformula(battlernumber)
    else
      ret = (60 * (battlernumber / 2) + 48) * (xpositionformula(battlernumber) - 1)
      ret += Graphics.width / 2 - 56
    end
    return ret
  end

  def ypointformula(battlernumber)
    ret = 0
    if !SINGLEROW
      ret = 32 + 128 * ypositionformula(battlernumber) / 2
    else
      ret = 96 - 8 * (battlernumber / 2)
    end
    return ret
  end

  # Returns 0, 1 or 2 as the x (column) value
  def xpositionformula(battlernumber)
    if !SINGLEROW
      return battlernumber % 3
      # return (battlernumber / 3 % 2 == 0) ? (19 - battlernumber) % 3 : (19 + battlernumber) % 3
    else
      return battlernumber % 2 * 2
    end
  end

  # Returns 0, 1 or 2 as the y (row) value
  def ypositionformula(battlernumber)
    if !SINGLEROW
      return (battlernumber / 3) % 2 * 2
    else
      return 1
    end
  end

  def createBattlers(hide = true)
    # Movement in animation
    for i in 0...6
      # Clear all 6 pokémon sprites and dispose the ones that exists every time
      # that this method is call
      restartSpritePosition(@sprites, "pokemon#{i}")
      next if i >= @hallEntry.size

      xpoint = xpointformula(i)
      ypoint = ypointformula(i)
      pkmn = @hallEntry[i]
      @sprites["pokemon#{i}"] = PokemonSprite.new(@viewport)
      @sprites["pokemon#{i}"].setPokemonBitmap(pkmn, battle: true)
      # This method doesn't put the exact coordinates
      pbPositionPokemonSprite(@sprites["pokemon#{i}"], xpoint, ypoint)
      @sprites["pokemon#{i}"].z = 7 - i if SINGLEROW
      next if !hide

      # Animation distance calculation
      horizontal = 1 - xpositionformula(i)
      vertical = 1 - ypositionformula(i)
      xdistance = (horizontal == -1) ? -@sprites["pokemon#{i}"].bitmap.width : Graphics.width
      ydistance = (vertical == -1) ? -@sprites["pokemon#{i}"].bitmap.height : Graphics.height
      xdistance = ((xdistance - @sprites["pokemon#{i}"].x) / ANIMATIONSPEED).abs + 1
      ydistance = ((ydistance - @sprites["pokemon#{i}"].y) / ANIMATIONSPEED).abs + 1
      biggerdistance = (xdistance > ydistance) ? xdistance : ydistance
      @xmovement[i] = biggerdistance
      @xmovement[i] *= -1 if horizontal == -1
      @xmovement[i] = 0   if horizontal == 0
      @ymovement[i] = biggerdistance
      @ymovement[i] *= -1 if vertical == -1
      @ymovement[i] = 0   if vertical == 0
      # Hide the battlers
      @sprites["pokemon#{i}"].x += @xmovement[i] * ANIMATIONSPEED
      @sprites["pokemon#{i}"].y += @ymovement[i] * ANIMATIONSPEED
    end
  end

  def moveSprite(i)
    spritename = (i > -1) ? "pokemon#{i}" : "trainer"
    speed = (i > -1) ? ANIMATIONSPEED : 2
    if !ANIMATION # Skips animation
      @sprites[spritename].x -= speed * @xmovement[i]
      @xmovement[i] = 0
      @sprites[spritename].y -= speed * @ymovement[i]
      @ymovement[i] = 0
    end
    if @xmovement[i] != 0
      direction = (@xmovement[i] > 0) ? -1 : 1
      @sprites[spritename].x += speed * direction
      @xmovement[i] += direction
    end
    if @ymovement[i] != 0
      direction = (@ymovement[i] > 0) ? -1 : 1
      @sprites[spritename].y += speed * direction
      @ymovement[i] += direction
    end
  end

  def createTrainerBattler
    @sprites["trainer"] = IconSprite.new(@viewport)
    @sprites["trainer"].setBitmap(pbTrainerSpriteFile($Trainer.trainertype, $Trainer.outfit))
    if !SINGLEROW
      @sprites["trainer"].x = Graphics.width - 96
      @sprites["trainer"].y = 160
    else
      @sprites["trainer"].x = Graphics.width / 2
      @sprites["trainer"].y = 178
    end
    @sprites["trainer"].z = 9
    @sprites["trainer"].ox = @sprites["trainer"].bitmap.width / 2
    @sprites["trainer"].oy = @sprites["trainer"].bitmap.height / 2
    if REMOVEBARS
      @sprites["overlay"].bitmap.clear
      @sprites["hallbars"].visible = false
    end
    @xmovement[@battlerIndex] = 0
    @ymovement[@battlerIndex] = 0
    if ANIMATION && !SINGLEROW # Trainer Animation
      startpoint = Graphics.width / 2
      # 2 is the trainer speed
      @xmovement[@battlerIndex] = (startpoint - @sprites["trainer"].x) / 2
      @sprites["trainer"].x = startpoint
    else
      pbWait(ENTRYWAITTIME)
    end
  end

  def writeTrainerData
    colortag = (isCurrentWindowskinDark ? ColorTags : LightColorTags)[PokemonSaveScene::TXT_COLOR]
    lefttext = _INTL("Name") + colortag + "<r>" + $Trainer.name + "</c3><br>"
    pubid = sprintf("%05d", $Trainer.publicID($Trainer.id))
    lefttext += _INTL("ID No.") + colortag + "<r>" + pubid + "</c3><br>"
    totalsec = Graphics.frame_count / 40 # Graphics.frame_rate # Turbo
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    lefttext += _INTL("Time") + colortag + "<r>" + _ISPRINTF("{1:02d}:{2:02d}", hour, min) + "</c3><br>"
    lefttext += _INTL("Pokédex") + colortag + "<r>#{$Trainer.pokedex.getOwnedCount}/#{$Trainer.pokedex.getSeenCount}</c3><br>"
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new(lefttext)
    @sprites["messagebox"].viewport = @viewport
    @sprites["messagebox"].width = 192 if @sprites["messagebox"].width < 192
    @sprites["msgwindow"] = Kernel.pbCreateMessageWindow(@viewport)
    Kernel.pbMessageDisplay(@sprites["msgwindow"], _INTL("Congratulations, Champion!\\^"))
  end

  def writePokemonData(pokemon, hallNumber = nil)
    overlay = @sprites["overlay"].bitmap
    overlay.clear

    hallNumber = $PokemonGlobal.hallOfFameLastNumber + @hallIndex - $PokemonGlobal.hallOfFame.size + 1 if !hallNumber
    if hallNumber > -1
      pbSetSystemFont(overlay)
      pbDrawTextPositions(overlay, [[_INTL("Hall of Fame No.  {1}", hallNumber), Graphics.width / 2, 0, :center, *HEAD_COLORS]])
      unless @selected
        tts(_INTL("Hall of Fame Number {1}", hallNumber), true)
        mons = @hallEntry.filter{ |i| i && !i.isEgg? }.map{ |i| getMonName(i.species, i.form) }.join(", ")
        tts(mons)
      end
    end

    drawInfobox(overlay, pokemon) if @selected && !pokemon.isEgg?
  end

  def drawInfobox(overlay, pokemon)
    case @infobox
      when 0 then drawInfoboxOne(overlay, pokemon)
      when 1 then drawInfoboxTwo(overlay, pokemon)
      when 2 then drawInfoboxThree(overlay, pokemon)
    end
  end

  def drawInfoboxOne(overlay, pokemon)
    pbSetNarrowFont(overlay)
    textpos = []

    pokename = pokemon.name
    speciesname = getMonName(pokemon.species, pokemon.form)
    pokename += " / " + speciesname if speciesname != pokename
    pokename += " (" + _INTL("Lv. {1}", pokemon.level)
    pokename += ", " + genderSign(pokemon.gender) unless pokemon.isGenderless?
    pokename += ")"
    typeicons = typeIcons(*pokemon.types)
    itemname = pokemon.item ? getItemName(pokemon.item, short: true) : _INTL("No item")
    naturename = pokemon.canShowNature? ? getNatureName(pokemon.nature) : "???"
    abilityname = getAbilityName(pokemon.ability, true)

    tts(_INTL("Pokémon: {1}", pokename), true) # Say "Pokémon" first to give time for the cry to play
    ttsTypeIconsInText(typeicons)
    tts(_INTL("Item: {1}", itemname))
    tts(_INTL("Nature: {1}", naturename))
    tts(_INTL("Ability: {1}", abilityname))

    pbDrawPokemonTypeIcons(overlay, typeicons)
    textpos += [
      [pokename, 20, INFO_LINE_1_Y, :left, *INFO_COLORS_1],
      [itemname, 20, INFO_LINE_2_Y, :left, *INFO_COLORS_2],
      [naturename, Graphics.width / 2, INFO_LINE_2_Y, :center, *INFO_COLORS_2],
      [abilityname, Graphics.width - 20, INFO_LINE_2_Y, :right, *INFO_COLORS_2],
    ]
    pbDrawTextPositions(overlay, textpos)
  end

  def pbDrawPokemonTypeIcons(overlay, typeicons)
    drawFormattedTextEx(overlay, Graphics.width - 148, INFO_LINE_1_Y, 132, "<r>" + typeicons)
  end

  def drawInfoboxTwo(overlay, pokemon)
    pbSetNarrowFont(overlay)
    textpos = []
    imagepos = []

    tts(_INTL("Moves:"))
    unless Reborn
      ypos = ((INFO_LINE_1_Y + INFO_LINE_2_Y) / 2).to_grid
      textpos += [[_INTL("Moves:"), 20, ypos, :left, *INFO_COLORS_3]]
    end
    for i in 0..3
      next unless pokemon.moves[i]

      movesym = pokemon.moves[i].move
      movetype = pbMoveSummaryType(pokemon.moves[i], pokemon)
      tts(getMoveName(movesym))

      xpos = [0, 2].include?(i) ? MOVE_NAME_1_X : MOVE_NAME_2_X
      ypos = [0, 1].include?(i) ? INFO_LINE_1_Y : INFO_LINE_2_Y
      textpos += [[getMoveShortName(movesym), xpos, ypos, :left, *INFO_COLORS_3]]

      drawMoveTypeIcon(overlay, movetype, xpos, ypos)
    end
    pbDrawImagePositions(overlay, imagepos)
    pbDrawTextPositions(overlay, textpos)
  end

  def drawMoveTypeIcon(overlay, movetype, xpos, ypos)
    iconxpos = xpos - 36
    iconypos = ypos - 2
    graphic = Bitmap.new(sprintf("Graphics/Icons/minitype%s", movetype))
    pbDrawBitmap(overlay, [graphic, iconxpos, iconypos])
  end

  def drawInfoboxThree(overlay, pokemon)
    pbSetNarrowFont(overlay)
    evstr = _INTL("EV") + ": " + pokemon.ev.map.with_index{ |value, stat| value.to_s + " " + getStatName(stat, :supershort) }.join(" | ")
    ivstr = _INTL("IV") + ": " + pokemon.iv.map.with_index{ |value, stat| value.to_s + " " + getStatName(stat, :supershort) }.join(" | ")
    textpos = [
      [evstr, Graphics.width / 2, INFO_LINE_1_Y, :center, *INFO_COLORS_4],
      [ivstr, Graphics.width / 2, INFO_LINE_2_Y, :center, *INFO_COLORS_4],
    ]
    pbDrawTextPositions(overlay, textpos)
    ttsInfoboxThree(pokemon)
  end

  def ttsInfoboxThree(pokemon)
    str = _INTL("EVs:")
    str += (0..5).map{ |stat| (pokemon.ev[stat].to_s + " " + getStatName(stat)) }.join(", ")
    str += "\n" + _INTL("IVs:")
    str += (0..5).map{ |stat| (pokemon.iv[stat].to_s + " " + getStatName(stat)) }.join(", ")
    tts(str, true)
  end

  def writeWelcome
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    pbSetSystemFont(overlay)

    text = _INTL("Welcome to the Hall of Fame!")
    pbDrawTextPositions(overlay, [[text, Graphics.width / 2, Graphics.height - 80, :center, *HEAD_COLORS]])
    tts(text)
  end

  def pbChangeBattleForm(index)
    pkmn = @hallEntry[index]
    case true
      when pkmn.hasMegaForm? then pkmn.makeMega
      when pkmn.isMega? then pkmn.makeUnmega
      when pkmn.hasPrimalForm? then pkmn.makePrimal
      when pkmn.isPrimal? then pkmn.makeUnprimal
      when pkmn.hasUltraForm? then pkmn.makeUltra
      when pkmn.isUltra? then pkmn.makeUnultra
      when pkmn.hasTeraForm? then pkmn.makeTerastallized
      when pkmn.isTerastallized? then pkmn.makeUnTerastallized
      else return
    end
    @sprites["pokemon#{index}"].setPokemonBitmap(pkmn, battle: true)
  end

  def pbEndScene
    $game_map.autoplay if @useMusic
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"]) if @sprites.include?("msgwindow")
    pbFadeOutAndHide(@sprites) { pbUpdate } if !@alreadyFadedInEnd
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbPCSelection
    loop do
      Graphics.update
      Input.update
      pbUpdate

      if Input.trigger?(Input::B) # End selection or exit scene if no mon is selected
        if @selected
          @selected = false
          pbUpdatePC
        else
          break
        end
      end
      if Input.trigger?(Input::C) # Start selection or go to next info page of selected mon
        if !@selected
          @selected = true
          pbUpdatePC
        elsif !@hallEntry[@battlerIndex].isEgg?
          pbSEPlay("Choose")
          @infobox += 1
          @infobox = 0 if @infobox > 2
          writePokemonData(@hallEntry[@battlerIndex])
        end
      end
      if Input.repeat?(Input::LEFT) # If a mon is selected, move the selection one mon forward, otherwise go to previous entry
        @selected ? pbUpdatePC(-1) : pbPrevEntry()
      end
      if Input.repeat?(Input::RIGHT) # If a mon is selected, move the selection one mon backward, otherwise go to next entry
        @selected ? pbUpdatePC(1) : pbNextEntry()
      end
      if Input.repeat?(Input::UP) # If a mon is selected, move the selection three mons forward, otherwise go to previous entry
        @selected ? pbUpdatePC(-3) : pbPrevEntry()
      end
      if Input.repeat?(Input::DOWN) # If a mon is selected, move the selection three mons backward, otherwise go to next entry
        @selected ? pbUpdatePC(3) : pbNextEntry()
      end
      if Input.repeat?(Input::L) # Go to next entry
        pbPrevEntry()
      end
      if Input.repeat?(Input::R) # Go to previous entry
        pbNextEntry()
      end
      if Input.trigger?(Input::X) # Mega / Unmega
        pbSEPlay("Choose") unless @selected
        @selected ? pbChangeBattleForm(@battlerIndex) : @hallEntry.each_with_index { |p, i| pbChangeBattleForm(i) }
        pbUpdatePC
      end
    end
  end

  def pbPrevEntry
    pbSEPlay("Choose") unless @selected # Don't play over cry
    pbUpdatePC(10)
  end

  def pbNextEntry
    pbSEPlay("Choose") unless @selected # Don't play over cry
    pbUpdatePC(-10)
  end

  def pbAnimationLoop
    loop do
      Graphics.update
      Input.update
      pbUpdate
      pbUpdateAnimation
      break if @battlerIndex == @hallEntry.size + 2
    end
  end
end

class HallOfFameScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreenEntry
    @scene.pbStartSceneEntry
    @scene.pbAnimationLoop
    @scene.pbEndScene
  end

  def pbStartScreenPC
    @scene.pbStartScenePC
    @scene.pbPCSelection
    @scene.pbEndScene
  end
end

MenuHandlers.add(:pc_menu, :hall_of_fame,
  name:      proc { _INTL("Hall of Fame") },
  order:     40,
  condition: proc { $PokemonGlobal.hallOfFameLastNumber > 0 },
  effect:    proc {
    Kernel.pbMessage(_INTL("\\se[accesspc]Accessed the Hall of Fame."))
    pbHallOfFamePC
    next nil
  }
)

def pbHallOfFameEntry
  scene = HallOfFameScene.new
  screen = HallOfFameScreen.new(scene)
  screen.pbStartScreenEntry
end

def pbSilentHallEntry # Reborn addition
  scene = HallOfFameScene.new
  scene.saveHallEntry
end

def pbHallOfFamePC
  scene = HallOfFameScene.new
  screen = HallOfFameScreen.new(scene)
  screen.pbStartScreenPC
end

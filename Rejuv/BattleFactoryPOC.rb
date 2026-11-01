class LuckSwapScene

  PATH = "Graphics/Pictures/LuckSwap/"
  BGCOLOR = Color.new(140, 140, 220)
  TEXTCOLOR = Color.new(238, 238, 238)
  SHADOWCOLOR = Color.new(60, 60, 60)
  POKECOLOR = Color.new(230, 76, 128)
  POKESHADOWCOLOR = Color.new(90, 45, 60)


  def initialize; @inSummary = false; end

  def cursorPos
    return ballOffsetMult * @index + ballOffsetX + 32
  end

  def ballOffsetMult
    80
  end

  def ballOffsetX
    (Graphics.width - (80 * @length - 40)) / 2 - 28
  end

  def createOffBall(i)
    ball = IconSprite.new(0, 0, @viewport)
    ball.setBitmap(PATH + "ball")
    ball.y = (Graphics.height / 2) - (ball.bitmap.height / 2)
    ball.x = ballOffsetMult * i + ballOffsetX
    return ball
  end

  def createOnBall(i)
    ball = AnimatedSprite.new(PATH + "ballSelected", 28, 96, 64, rand(0..2) + rand(0..1) + 2, @viewport)
    ball.y = (Graphics.height / 2) - (ball.bitmap.height / 2)
    ball.x = ballOffsetMult * i + ballOffsetX
    ball.play
    return ball
  end

  def getMonDisplay
    str = "<r><fs=48>"
    if @mode == 0
      str += getMonName($rentalsnew[@index].species, $rentalsnew[@index].form)
    else
      str += @party ? getMonName(@currentPokemon[@index].species, @currentPokemon[@index].form) : getMonName(@newPokemon[@index].species, @newPokemon[@index].form)
    end
    str += "</fs></r>"
    str
  end

  # Processes the scene
  def pbChoosePokemon(canCancel)
    return @index if @inSummary
    loop do
      Graphics.update
      Input.update
      pbUpdate

      if Input.trigger?(Input::RIGHT)
        @index += 1
        if @index > @length - 1
          @index = 0
        end
        @update = true
      elsif Input.trigger?(Input::LEFT)
        @index -= 1
        if @index < 0
          @index = @length - 1
        end
        @update = true
      end

      if Input.trigger?(Input::B) && canCancel
        return -1
      end

      if Input.trigger?(Input::C)
        @sprites["pokemon"].setPokemonBitmap(@mode == 0 ? $rentalsnew[@index] : @party ? @currentPokemon[@index] : @newPokemon[@index])
        @sprites["pokemon"].x = Graphics.width / 2 - @sprites["pokemon"].bitmap.width / 2
        @sprites["pokemon"].y = Graphics.height / 2 - @sprites["pokemon"].bitmap.height / 2

        playInBG

        @sprites["pokemon"].visible = true
        return @index
      end
    end
  end

  def playInBG
    @sprites["pokemonbg"].dispose
    @sprites["pokemonbg"] = BitmapSprite.new(@sprites["pokemon"].bitmap.width, @sprites["pokemon"].bitmap.height, @viewport)
    @sprites["pokemonbg"].z = 999998
    bg = @sprites["pokemonbg"]
    bg.x = @sprites["pokemon"].x
    bg.y = @sprites["pokemon"].y
    bg.opacity = 150
    bgbmp = bg.bitmap

    bgbmp.fill_rect(bgbmp.width / 2 - 1, bgbmp.height / 2, 2, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.fill_rect(bgbmp.width / 2 - 8, bgbmp.height / 2, 16, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.fill_rect(bgbmp.width / 2 - 16, bgbmp.height / 2, 32, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.fill_rect(bgbmp.width / 2 - 32, bgbmp.height / 2, 64, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.fill_rect(bgbmp.width / 2 - 64, bgbmp.height / 2, 128, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    if bgbmp.width > 255
      bgbmp.fill_rect(bgbmp.width / 2 - 128, bgbmp.height / 2, 256, 2, BGCOLOR)
      1.times do
        pbWait(1)
      end
    end

    bgbmp.fill_rect(0, bgbmp.height / 2, bgbmp.width, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.fill_rect(0, bgbmp.height / 2 - 8, bgbmp.width, 16, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.fill_rect(0, bgbmp.height / 2 - 16, bgbmp.width, 32, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.fill_rect(0, bgbmp.height / 2 - 32, bgbmp.width, 64, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.fill_rect(0, bgbmp.height / 2 - 64, bgbmp.width, 128, BGCOLOR)
    1.times do
      pbWait(1)
    end

    if bgbmp.height > 255
      bgbmp.fill_rect(0, bgbmp.height / 2 - 128, bgbmp.width, 256, BGCOLOR)
      1.times do
        pbWait(1)
      end
    end

    bgbmp.fill_rect(0, 0, bgbmp.width, bgbmp.height, BGCOLOR)
    1.times do
      pbWait(1)
    end
  end

  def playOutBG
    bg = @sprites["pokemonbg"]
    bgbmp = bg.bitmap


    if bgbmp.height > 255
      bgbmp.clear
      bgbmp.fill_rect(0, bgbmp.height / 2 - 128, bgbmp.width, 256, BGCOLOR)
      1.times do
        pbWait(1)
      end
    end

    bgbmp.clear
    bgbmp.fill_rect(0, bgbmp.height / 2 - 64, bgbmp.width, 128, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.clear
    bgbmp.fill_rect(0, bgbmp.height / 2 - 32, bgbmp.width, 64, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.clear
    bgbmp.fill_rect(0, bgbmp.height / 2 - 16, bgbmp.width, 32, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.clear
    bgbmp.fill_rect(0, bgbmp.height / 2 - 8, bgbmp.width, 16, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.clear
    bgbmp.fill_rect(0, bgbmp.height / 2, bgbmp.width, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    if bgbmp.width > 255
      bgbmp.clear
      bgbmp.fill_rect(bgbmp.width / 2 - 128, bgbmp.height / 2, 256, 2, BGCOLOR)
      1.times do
        pbWait(1)
      end
    end

    bgbmp.clear
    bgbmp.fill_rect(bgbmp.width / 2 - 64, bgbmp.height / 2, 128, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.clear
    bgbmp.fill_rect(bgbmp.width / 2 - 32, bgbmp.height / 2, 64, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.clear
    bgbmp.fill_rect(bgbmp.width / 2 - 16, bgbmp.height / 2, 32, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.clear
    bgbmp.fill_rect(bgbmp.width / 2 - 8, bgbmp.height / 2, 16, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.clear
    bgbmp.fill_rect(bgbmp.width / 2 - 1, bgbmp.height / 2, 2, 2, BGCOLOR)
    1.times do
      pbWait(1)
    end

    bgbmp.clear

  end

  def pbGetFieldName(rental)
    return "LUCK SWAP"
    # TODO XEN TOWER FORMAT
    if $game_variables[:Forced_Field_Effect] == 0 || $game_variables[:Forced_Field_Effect] == :INDOOR
      if rental
        return "Rental Pokémon"
      else
        return "Swap Pokémon"
      end
    else
      return $cache.FEData[$game_variables[:Forced_Field_Effect]].name
    end
  end

  def pbShowCommands(commands)
    UIHelper.pbShowCommands(@sprites["msgwindow"], nil, commands) { pbUpdate }
  end

  def pbConfirm(message)
    UIHelper.pbConfirm(@sprites["msgwindow"], message) { pbUpdate }
  end

  def pbUpdateChoices(choices)

    oldchoices = @choices
    @choices = choices
    off = oldchoices.find_all { |c| !@choices.include?(c) }
    @selected.delete_if { |s| off.include?(s) }
    for i in 0..@length
      if off.include?(i)
        @sprites["ball#{i}"].dispose
        @sprites["ball#{i}"] = createOffBall(i)
      else
        if @choices.include?(i) && !@selected.include?(i)
          @sprites["ball#{i}"].dispose
          @sprites["ball#{i}"] = createOnBall(i)
          @selected.push(i)
        end
      end
    end

    @sprites["help"].bitmap.clear
    if choices.length == 0
      drawFormattedTextEx(@sprites["help"].bitmap, 8, 304, 400, "Choose the first Pokémon.", TEXTCOLOR, SHADOWCOLOR)
    elsif choices.length == 1
      drawFormattedTextEx(@sprites["help"].bitmap, 8, 304, 400, "Choose the second Pokémon.", TEXTCOLOR, SHADOWCOLOR)
    elsif choices.length == 2
      drawFormattedTextEx(@sprites["help"].bitmap, 8, 304, 400, "Choose the third Pokémon.", TEXTCOLOR, SHADOWCOLOR)
    elsif choices.length == 3 && pbBattleChallenge.doublebattlefact
      drawFormattedTextEx(@sprites["help"].bitmap, 8, 304, 400, "Choose the fourth Pokémon.", TEXTCOLOR, SHADOWCOLOR)
    end

    clearPokemon
  end

  def pbSwapChosen(pkmnindex)
    clearPokemon
    @party = false
    @length = @newPokemon.length
    @index = 0
    @update = true
    @pkmnindex = pkmnindex
    @sprites["help"].bitmap.clear
    @sprites["monName"].bitmap.clear
    @sprites["arrow"].visible = false

    for j in 0...@currentPokemon.length
      @sprites["party#{j}"].x += 22
    end
    for j in 0...@newPokemon.length
      @sprites["ball#{j}"].x += 22
    end
    pbWait(1)

    for i in 1..19
      for j in 0...@currentPokemon.length
        @sprites["party#{j}"].x += 26
      end
      for j in 0...@newPokemon.length
        @sprites["ball#{j}"].x += 26
      end
      pbWait(1)
    end

    @mode = 2

    pbUpdate
    drawFormattedTextEx(@sprites["help"].bitmap, 8, 304, 276, "Select Pokémon to accept.", TEXTCOLOR, SHADOWCOLOR)
    @sprites["arrow"].visible = true
  end

  def pbSwapCanceled
    @party = true
    @index = @pkmnindex
    @update = true
    @length = @currentPokemon.length
    @sprites["help"].bitmap.clear
    @sprites["monName"].bitmap.clear
    @sprites["arrow"].visible = false

    for j in 0...@currentPokemon.length
      @sprites["party#{j}"].x -= 22
    end
    for j in 0...@newPokemon.length
      @sprites["ball#{j}"].x -= 22
    end
    pbWait(1)

    for i in 1..19
      for j in 0...@currentPokemon.length
        @sprites["party#{j}"].x -= 26
      end
      for j in 0...@newPokemon.length
        @sprites["ball#{j}"].x -= 26
      end
      pbWait(1)
    end

    @mode = 1

    pbUpdate
    drawFormattedTextEx(@sprites["help"].bitmap, 8, 304, 276, "Select Pokémon to swap.", TEXTCOLOR, SHADOWCOLOR)
    @sprites["arrow"].visible = true
  end

  def pbSummary(list, index)
    @inSummary = true
    visibleSprites = pbFadeOutAndHide(@sprites) { pbUpdate }
    scene = PokemonSummaryScene.new
    screen = PokemonSummary.new(scene)
    @index = screen.pbStartScreen(list, index)

    @sprites["pokemon"].setPokemonBitmap(@mode == 0 ? $rentalsnew[@index] : @party ? @currentPokemon[@index] : @newPokemon[@index])
    @sprites["pokemon"].x = Graphics.width / 2 - @sprites["pokemon"].bitmap.width / 2
    @sprites["pokemon"].y = Graphics.height / 2 - @sprites["pokemon"].bitmap.height / 2
    @sprites["pokemonbg"].dispose
    @sprites["pokemonbg"] = BitmapSprite.new(@sprites["pokemon"].bitmap.width, @sprites["pokemon"].bitmap.height, @viewport)
    @sprites["pokemonbg"].z = 999998
    bg = @sprites["pokemonbg"]
    bg.x = @sprites["pokemon"].x
    bg.y = @sprites["pokemon"].y
    bg.opacity = 150
    bg.bitmap.fill_rect(0, 0, bg.bitmap.width, bg.bitmap.height, BGCOLOR)
    @sprites["monName"].bitmap.clear
    drawFormattedTextLine(@sprites["monName"].bitmap, 0, -4, Graphics.width, getMonDisplay, POKECOLOR, POKESHADOWCOLOR, 48)

    pbFadeInAndShow(@sprites, visibleSprites) { pbUpdate }
  end

  # Update the scene here, this is called once each frame
  def pbUpdate

    @sprites["arrow"].x = cursorPos

    pbUpdateSpriteHash(@sprites)
    # Add other things that should be updated

    return if !@update
    @update = false
    @sprites["monName"].bitmap.clear
    drawFormattedTextLine(@sprites["monName"].bitmap, 0, -4, Graphics.width, getMonDisplay, POKECOLOR, POKESHADOWCOLOR, 48)
  end

  def clearPokemon
    @sprites["pokemon"].visible = false
    @inSummary = false if @inSummary
    playOutBG
  end

  # End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate } # Fade out all sprites
    pbDisposeSpriteHash(@sprites) # Dispose all sprites
    @viewport.dispose # Dispose the viewport
  end

  def pbStartSwapScene(currentPokemon, newPokemon)
    # Create sprite hash
    @sprites = {}
    @mode = 1 # swap
    @length = pbBattleChallenge.doublebattlefact ? 4 : 3
    @length = currentPokemon.length
    @index = 0
    @choices = []
    @selected = []
    @currentPokemon = currentPokemon
    @newPokemon = newPokemon
    @party = true
    # Allocate viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap(PATH + "bg")

    @sprites["title"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    title = @sprites["title"].bitmap
    pbSetSystemFont(title)
    drawFormattedTextEx(title, 8, 46, 276, "<fs=48>LUCK SWAP</fs>", TEXTCOLOR, SHADOWCOLOR)

    @sprites["help"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    help = @sprites["help"].bitmap
    pbSetSystemFont(help)
    drawFormattedTextEx(help, 8, 304, 276, "Select Pokémon to swap.", TEXTCOLOR, SHADOWCOLOR)

    @sprites["monName"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    info = @sprites["monName"].bitmap
    pbSetSystemFont(info)
    drawFormattedTextLine(info, 0, -4, Graphics.width, getMonDisplay, POKECOLOR, POKESHADOWCOLOR, 48)

    @sprites["msgwindow"] = Window_AdvancedTextPokemon.newWithSize(
      "", 0, Graphics.height - 64, Graphics.height, 64, @viewport
    )
    @sprites["msgwindow"].visible = false


    for i in 0...@length
      @sprites["party#{i}"] = createOnBall(i)
    end

    @length = @newPokemon.length
    @party = false
    for i in 0...@length
      @sprites["ball#{i}"] = createOffBall(i)
      @sprites["ball#{i}"].x -= Graphics.width
    end
    @length = @currentPokemon.length
    @party = true

    @sprites["arrow"] = AnimatedSprite.new(PATH + "arrow", 6, 32, 32, 5, @viewport)
    @sprites["arrow"].y = @sprites["party0"].y - 16
    @sprites["arrow"].x = cursorPos
    @sprites["arrow"].play

    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap($rentalsnew[@index])
    @sprites["pokemon"].visible = false
    @sprites["pokemon"].z = 999999

    @sprites["pokemonbg"] = BitmapSprite.new(@sprites["pokemon"].bitmap.width, @sprites["pokemon"].bitmap.height, @viewport)
    @sprites["pokemonbg"].z = 999998

    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartRentScene(rentals)
    # Create sprite hash
    @sprites = {}
    @mode = 0 # rental
    @index = 0
    @choices = []
    @selected = []
    @length = 6
    $rentalsnew = rentals
    # Allocate viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap(PATH + "bg")

    @sprites["title"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    title = @sprites["title"].bitmap
    pbSetSystemFont(title)
    drawFormattedTextEx(title, 8, 46, 276, "<fs=48>LUCK SWAP</fs>", TEXTCOLOR, SHADOWCOLOR)

    @sprites["help"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    help = @sprites["help"].bitmap
    pbSetSystemFont(help)
    drawFormattedTextEx(help, 8, 304, 400, "Choose the first Pokémon.", TEXTCOLOR, SHADOWCOLOR)


    @sprites["monName"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    info = @sprites["monName"].bitmap
    pbSetSystemFont(info)
    drawFormattedTextLine(info, 0, -4, Graphics.width, getMonDisplay, POKECOLOR, POKESHADOWCOLOR, 48)


    @sprites["msgwindow"] = Window_AdvancedTextPokemon.newWithSize(
      "", 0, Graphics.height - 64, Graphics.height, 64, @viewport
    )
    @sprites["msgwindow"].visible = false


    for i in 0...@length
      @sprites["ball#{i}"] = createOffBall(i)
    end

    @sprites["arrow"] = AnimatedSprite.new(PATH + "arrow", 6, 32, 32, 5, @viewport)
    @sprites["arrow"].y = @sprites["ball0"].y - 16
    @sprites["arrow"].x = cursorPos
    @sprites["arrow"].play

    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap($rentalsnew[@index])
    @sprites["pokemon"].visible = false
    @sprites["pokemon"].z = 999999

    @sprites["pokemonbg"] = BitmapSprite.new(@sprites["pokemon"].bitmap.width, @sprites["pokemon"].bitmap.height, @viewport)
    @sprites["pokemonbg"].z = 999998

    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end

class BattleFactoryData
  def pbChooseRentalsLuck
    pbFadeOutIn(99999) {
      scene = LuckSwapScene.new
      screen = LuckSwapScreen.new(scene)
      $rentalsnew = screen.pbStartRent($rentalsnew)
      @bcdata.pbAddSwap
      pbBattleChallenge.setParty($rentalsnew)
    }
  end

  def pbPrepareRentalsLuck
    $rentalsnew = pbBattleFactoryPokemon(@bcdata.wins, @bcdata.swaps, [])
  end

  def pbChooseSwapsLuck
    swapMade = true
    pbFadeOutIn(99999) {
      if !$rentalsnew
        $rentalsnew = $Trainer.party
      end
      scene = LuckSwapScene.new
      screen = LuckSwapScreen.new(scene)
      swapMade = screen.pbStartSwap($rentalsnew, $cache.xtpool.common.sample(3).map{ |m| m.createPokemon })
    }
    return swapMade
  end
end

def testbf
  pbBattleChallenge.set("factorysingleopen",5,pbBattleFactoryRules(false,true))
  pbBattleChallenge.start
  pbBattleChallenge.pbfieldeffect(0,false)

  pbBattleChallenge.extra.pbPrepareRentalsLuck
  pbBattleChallenge.extra.pbChooseRentalsLuck

end

def testbfs
  pbBattleChallenge.set("factorysingleopen",5,pbBattleFactoryRules(false,true))
  pbBattleChallenge.start
  pbBattleChallenge.pbfieldeffect(0,false)

  pbBattleChallenge.extra.pbChooseSwapsLuck

end

def drawFormattedTextLine(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
  base = !baseColor ? Color.new(12 * 8, 12 * 8, 12 * 8) : baseColor.clone
  shadow = !shadowColor ? Color.new(26 * 8, 26 * 8, 25 * 8) : shadowColor.clone
  text = "<c2=" + colorToRgb16(base) + colorToRgb16(shadow) + ">" + text
  chars = getFormattedText(bitmap, x, y, width, -1, text, lineheight)
  drawFormattedChars(bitmap, chars)
end

class LuckSwapScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartRent(rentals)
    @scene.pbStartRentScene(rentals)
    chosen = []
    loop do
      index = @scene.pbChoosePokemon(false)
      commands = []
      commands.push(_INTL("Summary"))
      if chosen.any? { |item| item == index }
        commands.push(_INTL("Deselect"))
      else
        commands.push(_INTL("Rent"))
      end
      commands.push(_INTL("Cancel"))
      command = @scene.pbShowCommands(commands)
      if command == 0
        @scene.pbSummary(rentals, index)
      elsif command == 1
        if chosen.any? { |item| item == index }
          chosen.delete(index)
          @scene.pbUpdateChoices(chosen.clone)
        else
          chosen.push(index)
          @scene.pbUpdateChoices(chosen.clone)
          if chosen.length == 3 && !pbBattleChallenge.doublebattlefact
            if @scene.pbConfirm(_INTL("Are these three Pokémon OK?"))
              retval = []
              chosen.each { |i| retval.push(rentals[i]) }
              @scene.pbEndScene
              return retval
            else
              chosen.delete(index)
              @scene.pbUpdateChoices(chosen.clone)
            end
          end
          if chosen.length == 4
            if @scene.pbConfirm(_INTL("Are these four Pokémon OK?"))
              retval = []
              chosen.each { |i| retval.push(rentals[i]) }
              @scene.pbEndScene
              return retval
            else
              chosen.delete(index)
              @scene.pbUpdateChoices(chosen.clone)
            end
          end
        end
      else
        @scene.clearPokemon
      end
    end
  end

  def pbStartSwap(currentPokemon, newPokemon)
    @scene.pbStartSwapScene(currentPokemon, newPokemon)
    loop do
      pkmn = @scene.pbChoosePokemon(true)
      if pkmn >= 0
        commands = [_INTL("Summary"), _INTL("Swap"), _INTL("Rechoose")]
        command = @scene.pbShowCommands(commands)
        if command == 0
          @scene.pbSummary(currentPokemon, pkmn)
        elsif command == 1
          @scene.pbSwapChosen(pkmn)
          yourPkmn = pkmn
          loop do
            pkmn = @scene.pbChoosePokemon(true)
            if pkmn >= 0
              commands = [_INTL("Summary"), _INTL("Choose"), _INTL("Cancel")]
              command = @scene.pbShowCommands(commands)
              if command == 0
                @scene.pbSummary(newPokemon, pkmn)
              elsif command == 1
                @scene.pbEndScene
                currentPokemon[yourPkmn] = newPokemon[pkmn]
                return true
              else
                @scene.clearPokemon
              end
            elsif pkmn == -1
              @scene.pbSwapCanceled
              break # Back to first screen
            end
          end
        else
          @scene.clearPokemon
        end
      else
        # Canceled
        if @scene.pbConfirm(_INTL("Quit swapping?"))
          @scene.pbEndScene
          return false
        end
      end
    end
  end
end

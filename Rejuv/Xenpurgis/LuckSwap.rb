def luckTickets
  return $PokemonGlobal.xenTower.tickets
end

def addLuckTickets(amt)
  $PokemonGlobal.xenTower.tickets += amt
end

def removeLuckTickets(amt)
  $PokemonGlobal.xenTower.tickets -= amt
end

def rollLuckpon(tier = :common)
  return $PokemonGlobal.xenTower.roll(tier)
end

def getTowerAttempts
  return $PokemonGlobal.xenTower.attempts
end

def luckItemPool
  return {
    :itemball => [
      :HYPERPOTION, :MAXPOTION, :FULLRESTORE, :REVIVE, :MAXREVIVE,
      :FRESHWATER, :SODAPOP, :LEMONADE, :MOOMOOMILK, :ENERGYPOWDER,
      :ENERGYROOT, :HEALPOWDER, :LUMBERRY, :CASTELIACONE, :ETHER,
      :ELIXIR, :SITRUSBERRY, :LEPPABERRY
    ],
    :chest => [
      :LEFTOVERS, :CHOICEBAND, :CHOICESPECS, :CHOICESCARF, :FOCUSSASH,
      :LIFEORB, :EXPERTBELT, :BLACKSLUDGE, :ROCKYHELMET, :SCOPELENS,
      :WIDELENS, :MUSCLEBAND, :WISEGLASSES, :QUICKCLAW, :BRIGHTPOWDER,
      :KINGSROCK, :ASSAULTVEST, :AIRBALLOON, :WEAKNESSPOLICY
    ]
  }
end

def luckItem(quantity = 1, rolls = 1, pool = :itemball)
  return if !xenTowerInProgress
  itemPool = luckItemPool

  samples = []
  rolls.times do
    samples.push(itemPool[pool].sample(random: $PokemonGlobal.xenTower.random))
  end
  results = {}
  samples.each { |s|
    item = s
    amt = quantity
    if s.is_a?(Array)
      item = s[0]
      amt = s[1] * quantity
    end
    if results.any? { |k, v| k == item }
      results[item] += amt
    else
      results.store(item, amt)
    end
  }

  results.each { |item, amt|
    Kernel.pbItemBall(item, amt)
  }
end

def scaleTowerMon(pokemon)
  level = 50; ev = 25; iv = 10
  (level = 72; ev = 35; iv = 15) if $game_switches[:DefeatedXenTowerMadelis]
  (level = 87; ev = 50; iv = 20) if $game_switches[:DefeatedXenTowerFlora]
  pokemon.level = [level, pokemon.level].max
  pokemon.exp = PBExp.startExperience(level, pokemon.growthrate)
  pokemon.ev.map! { |e| [e, ev].max }
  pokemon.iv.map! { |i| [i, iv].max }
  pokemon.calcStats
end

class LuckSwapScene

  PATH = "Graphics/Pictures/LuckSwap/"
  BGCOLOR = Color.new(140, 140, 220)
  TEXTCOLOR = Color.new(238, 238, 238)
  SHADOWCOLOR = Color.new(60, 60, 60)
  POKECOLOR = Color.new(230, 76, 128)
  POKESHADOWCOLOR = Color.new(90, 45, 60)

  attr_reader :rentals

  def initialize(pool, count = 4)
    @inSummary = false
    @length = count
    @rentals = pool
  end

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

  def createBlessing(i)
    ball = IconSprite.new(0, 0, @viewport)
    ball.setBitmap(PATH + "blessing") #idk
    ball.y = (Graphics.height / 2) - (ball.bitmap.height / 2)
    ball.x = ballOffsetMult * i + ballOffsetX
    return ball
  end

  def getMonDisplay
    str = "<r><fs=45>"
    if @mode == :pick
      str += getMonName(@rentals[@index].species, @rentals[@index].form)
    elsif @mode == :blessing
      str += "" #get blessing dat
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
        pbPlayCursorSE()
        @index += 1
        if @index > @length - 1
          @index = 0
        end
        @update = true
      elsif Input.trigger?(Input::LEFT)
        pbPlayCursorSE()
        @index -= 1
        if @index < 0
          @index = @length - 1
        end
        @update = true
      end

      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        @sprites["pokemon"].setPokemonBitmap(@mode == :pick ? @rentals[@index] : @party ? @currentPokemon[@index] : @newPokemon[@index])
        @sprites["pokemon"].x = Graphics.width / 2 - @sprites["pokemon"].bitmap.width / 2
        @sprites["pokemon"].y = Graphics.height / 2 - @sprites["pokemon"].bitmap.height / 2

        playInBG

        @sprites["pokemon"].visible = true
        return @index
      end

      if Input.trigger?(Input::B) && canCancel
        pbPlayCancelSE()
        text = @mode == :swap ? _INTL("quit swapping? eat your ticket.") : _INTL("quit choosing? eat your ticket.")
        if pbConfirm(text)
          if $Trainer.party.empty? && $PokemonGlobal.xenTower.tickets == 1
            pbDisplay(_INTL("You must pull at least one MONSTER!"))
            return -1
          else
            pbDisplay(_INTL("Mr Luck's son ate one ticket."))
            return -2
          end
        else
          pbDisplay(_INTL("Take your time!"))
        end
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
  end

  def pbShowCommands(commands)
    UIHelper.pbShowCommands(@sprites["msgwindow"], nil, commands) { pbUpdate }
  end

  def pbConfirm(message)
    UIHelper.pbConfirm(@sprites["msgwindow"], message) { pbUpdate }
  end

  def pbDisplay(message, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], message, brief) { pbUpdate }
  end

  def pbUpdateChoices(choices)
    clearPokemon
    return
  end

  def pbSwapChosen(pkmnindex)
    clearPokemon
    @party = false
    @length = 4
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

    @mode = :swapPicked

    pbUpdate
    drawFormattedTextEx(@sprites["help"].bitmap, 8, 304, 276, _INTL("Choose a MONSTER!"), TEXTCOLOR, SHADOWCOLOR)
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

    @mode = :swap

    pbUpdate
    drawFormattedTextEx(@sprites["help"].bitmap, 8, 304, 276, _INTL("Choose a MONSTER to swap!"), TEXTCOLOR, SHADOWCOLOR)
    @sprites["arrow"].visible = true
  end

  def pbSummary(list, index)
    @inSummary = true
    visibleSprites = pbFadeOutAndHide(@sprites) { pbUpdate }
    scene = PokemonSummaryScene.new
    screen = PokemonSummary.new(scene)
    @index = screen.pbStartScreen(list, index)

    @sprites["pokemon"].setPokemonBitmap(list[@index])
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
    drawFormattedTextLine(@sprites["monName"].bitmap, 0, 0, Graphics.width, getMonDisplay, POKECOLOR, POKESHADOWCOLOR, 48)

    @update = true
    pbFadeInAndShow(@sprites, visibleSprites) { pbUpdate }
  end

  # Update the scene here, this is called once each frame
  def pbUpdate

    pbUpdateSpriteHash(@sprites)
    # Add other things that should be updated

    return if !@update
    @sprites["arrow"].x = cursorPos unless @sprites["arrow"].nil? # idk why this can be nil
    @update = false
    @sprites["monName"].bitmap.clear
    drawFormattedTextLine(@sprites["monName"].bitmap, 0, 0, Graphics.width, getMonDisplay, POKECOLOR, POKESHADOWCOLOR, 48)
    if !@party
      for i in 0...@length
        @sprites["ball#{i}"].dispose
        if i == @index
          @sprites["ball#{i}"] = createOnBall(i)
        else
          @sprites["ball#{i}"] = createOffBall(i)
        end
      end
    end
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

  def startLuckponSwap(newPokemon)
    # Create sprite hash
    @sprites = {}
    @mode = :swap # swap
    @index = 0
    @choices = []
    @selected = []
    @currentPokemon = $Trainer.party
    @length = @currentPokemon.length
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
    drawFormattedTextEx(title, 8, 46, 276, _INTL("<fs=45>LUCK SWAP</fs>"), TEXTCOLOR, SHADOWCOLOR)

    @sprites["help"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    help = @sprites["help"].bitmap
    pbSetSystemFont(help)
    drawFormattedTextEx(help, 8, 304, 276, _INTL("Choose a MONSTER to swap!"), TEXTCOLOR, SHADOWCOLOR)

    @sprites["monName"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    info = @sprites["monName"].bitmap
    pbSetSystemFont(info)
    drawFormattedTextLine(info, 0, 0, Graphics.width, getMonDisplay, POKECOLOR, POKESHADOWCOLOR, 48)

    @sprites["msgwindow"] = Window_AdvancedTextPokemon.newWithSize(
      "", 0, Graphics.height - 64, Graphics.height, 64, @viewport
    )
    @sprites["msgwindow"].visible = false


    for i in 0...@length
      @sprites["party#{i}"] = createOnBall(i)
    end

    @length = 4
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
    @sprites["pokemon"].setPokemonBitmap(@rentals[@index])
    @sprites["pokemon"].visible = false
    @sprites["pokemon"].z = 999999

    @sprites["pokemonbg"] = BitmapSprite.new(@sprites["pokemon"].bitmap.width, @sprites["pokemon"].bitmap.height, @viewport)
    @sprites["pokemonbg"].z = 999998

    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def startLuckponPick
    # Create sprite hash
    @sprites = {}
    @mode = :pick # rental
    @index = 0
    @choices = []
    @selected = []
    # Allocate viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap(PATH + "bg")

    @sprites["title"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    title = @sprites["title"].bitmap
    pbSetSystemFont(title)
    drawFormattedTextEx(title, 8, 46, 276, _INTL("<fs=45>LUCK SWAP</fs>"), TEXTCOLOR, SHADOWCOLOR)

    @sprites["help"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    help = @sprites["help"].bitmap
    pbSetSystemFont(help)
    drawFormattedTextEx(help, 8, 304, 400, _INTL("Choose a MONSTER!"), TEXTCOLOR, SHADOWCOLOR)


    @sprites["monName"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    info = @sprites["monName"].bitmap
    pbSetSystemFont(info)
    drawFormattedTextLine(info, 0, 0, Graphics.width, getMonDisplay, POKECOLOR, POKESHADOWCOLOR, 48)


    @sprites["msgwindow"] = Window_AdvancedTextPokemon.newWithSize(
      "", 0, Graphics.height - 64, Graphics.height, 64, @viewport
    )
    @sprites["msgwindow"].visible = false

    @sprites["ball0"] = createOnBall(0)
    for i in 1...@length
      @sprites["ball#{i}"] = createOffBall(i)
    end

    @sprites["arrow"] = AnimatedSprite.new(PATH + "arrow", 6, 32, 32, 5, @viewport)
    @sprites["arrow"].y = @sprites["ball0"].y - 16
    @sprites["arrow"].x = cursorPos
    @sprites["arrow"].play

    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap(@rentals[@index])
    @sprites["pokemon"].visible = false
    @sprites["pokemon"].z = 999999

    @sprites["pokemonbg"] = BitmapSprite.new(@sprites["pokemon"].bitmap.width, @sprites["pokemon"].bitmap.height, @viewport)
    @sprites["pokemonbg"].z = 999998

    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
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
    @rentals = @scene.rentals
  end

  def startLuckponPick
    @scene.startLuckponPick
    chosen = []
    canCancel = $Trainer.party.length > 0
    loop do
      index = @scene.pbChoosePokemon(canCancel)
      if index == -2
        @scene.pbEndScene
        break
      end
      commands = []
      commands.push(_INTL("Summary"))
      commands.push(_INTL("Choose"))
      commands.push(_INTL("Cancel"))
      command = @scene.pbShowCommands(commands)
      if command == 0
        @scene.pbSummary(@rentals, index)
      elsif command == 1
        mon = @rentals[index]
        if @scene.pbConfirm(_INTL("Is this okay?!"))
          @scene.pbEndScene
          return mon
        else
          @scene.pbDisplay(_INTL("Ok. Take your time."))
          @scene.clearPokemon
        end
      else
        @scene.clearPokemon
      end
    end
  end

  def startLuckponSwap(newPokemon)
    currentPokemon = $Trainer.party
    @scene.startLuckponSwap(newPokemon)
    loop do
      pkmn = @scene.pbChoosePokemon(true)
      if pkmn >= 0
        commands = [_INTL("Summary"), _INTL("Swap"), _INTL("Cancel")]
        command = @scene.pbShowCommands(commands)
        if command == 0
          @scene.pbSummary(currentPokemon, pkmn)
        elsif command == 1
          if Kernel.pbConfirmMessage(_INTL("Are you sure? No takesies-backsies."))
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
              elsif pkmn == -2
                # @scene.pbSwapCanceled
                # break # Back to first screen
                @scene.pbEndScene
                return false
              end
            end
          end
        else
          @scene.clearPokemon
        end
      else
        # Canceled
        @scene.pbEndScene
        return false
      end
    end
  end
end

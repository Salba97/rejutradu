class DefaultControlsScene
  KeyboardHeadingColors = ColorArrays[:Blue2] # [Base, Shadow]
  GamepadHeadingColors = ColorArrays[:Magenta] # [Base, Shadow]
  KeyColors = ColorArrays[:Gray3] # [Base, Shadow]
  TextColors = ColorArrays[:White3] # [Base, Shadow]
  LineHeight = 28
  X = 14
  Y = 8
  TotalPages = 5

  def initialize(page, gamepad = false)
    @page = page
    @gamepad = gamepad

    @buttonTriangle = buttonBitmap(:Triangle)
    @buttonSquare = buttonBitmap(:Square)
    @buttonCross = buttonBitmap(:Cross)
    @buttonCircle = buttonBitmap(:Circle)
  end

  def pbRender
    drawPage(true)
    pbActivate
    pbEndScene
  end

  def drawPage(starting = false)
    unless starting
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
    end

    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites, "background", "helpbg2", @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    overlay = @sprites["overlay"].bitmap

    @texts, @images = [], []
    case @page
      when 0 then @gamepad ? getGeneralControlsGamepad : getGeneralControlsKeyboard
      when 1 then @gamepad ? getOWControlsGamepad : getOWControlsKeyboard
      when 2 then @gamepad ? getBattleControlsGamepad : getBattleControlsKeyboard
      when 3 then @gamepad ? getPartyControlsGamepad : getPartyControlsKeyboard
      when 4 then @gamepad ? getStorageControlsGamepad : getStorageControlsKeyboard
    end

    @ttsIndex = 0
    ttsCurrentLine
    pbSetSystemFont(overlay)
    @images.each { |image| pbDrawBitmap(overlay, image) }
    @texts.each { |text|
      str = text[0].clone
      if str.include?(":")
        str = shadowc3tag(*KeyColors) + str # Add starting tag at start
        str.gsub!(":", ":</c>") # Add ending tag after ":"
      end
      drawFormattedTextEx(overlay, text[1], text[2], Graphics.width - X - 8, str, text[4], text[5], LineHeight)
    }
    pbDeactivateWindows(@sprites)
    starting ? pbFadeInAndShow(@sprites) { pbUpdateSpriteHash(@sprites) } : pbUpdateSpriteHash(@sprites)
  end

  def pbActivate
    pbActivateWindow(@sprites, nil) {
      loop do
        Graphics.update
        Input.update
        if Input.press?(Input::CTRL) && Input.trigger?(Input::DOWN) # Next TTS line
          @index += 1
          @index = 0 if @index >= @texts.length
          ttsCurrentLine
        elsif Input.press?(Input::CTRL) && Input.trigger?(Input::UP) # Prev TTS line
          @index -= 1
          @index = @texts.length - 1 if @index <= -1
          ttsCurrentLine
        elsif Input.trigger?(Input::LEFT)
          @page -= 1
          @page = TotalPages - 1 if @page < 0
          pbPlayCursorSE()
          drawPage
        elsif Input.trigger?(Input::RIGHT)
          @page += 1
          @page = 0 if @page > TotalPages - 1
          pbPlayCursorSE()
          drawPage
        elsif Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
          @gamepad = !@gamepad
          pbPlayCursorSE()
          drawPage
        elsif Input.trigger?(Input::B) || Input.trigger?(Input::C) || Input.triggerex?(Input::F2)
          break
        end
      end
    }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbRefreshSceneMap
  end

  def ttsCurrentLine
    textarray = @texts[@ttsIndex]
    text = textarray[0].clone

    if text.include?("       ")
      icon = textarray[6]
      case icon
        when :Cross then string = "Cross or A"
        when :Circle then string = "Circle or B"
        when :Square then string = "Square or X"
        when :Triangle then string = "Triangle or Y"
      end
      text.gsub!("       ", string)
    end
    text.gsub!("<r>", ", ")

    text += "\n" + _INTL("Use Ctrl + Up or Down keys to navigate between lines.") unless @tipSpoken
    @tipSpoken = true
    tts(text, true)
  end


  def getGeneralControlsKeyboard
    addTitle(mobile? ? _INTL("General Controls - Basic") : _INTL("General Controls - Keyboard"))
    i = 0
    @texts.push [_INTL("C / Enter / Space:   Select"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("X / Escape:   Cancel"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("X / Escape (hold):   Skip Text"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Q (PgUp) / W (PgDn):   Previous Page / Next Page"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [mobile? ? _INTL("H + Q / W:   Skip 10 Pages") : _INTL("Shift + Q / W:   Skip 10 Pages"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Home / End:   Jump to First / Last Item"), X, Y + LineHeight * (i += 1), 0, *TextColors] unless mobile?
    @texts.push [mobile? ? _INTL("L (hold) / T:   Speed Up") : _INTL("Tab / M:   Toggle Speed Up"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [mobile? ? _INTL("M:   Mute / Unmute") : _INTL("F7:   Mute / Unmute"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    # Kirin doesn't seem to support soft reset
    @texts.push [_INTL("F12:   Soft Reset"), X, Y + LineHeight * (i += 1), 0, *TextColors] unless $kirin
    @texts.push [_INTL("F3:   Save Screenshot"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("F1:   Change Controls"), X, Y + LineHeight * (i += 1), 0, *TextColors] unless mobile?
    @texts.push [mobile? ? _INTL("F11:   View Controls") : _INTL("F2:   View Defaults"), X, Y + LineHeight * (i += 1), 0, *TextColors]
  end

  def getOWControlsKeyboard
    addTitle(mobile? ? _INTL("Overworld Controls - Basic") : _INTL("Overworld Controls - Keyboard"))
    blindstep = $game_switches && $game_switches[:Blindstep]
    i = 0
    @texts.push [_INTL("C / Enter / Space:   Interact"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("X / Escape:   Menu"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [mobile? ? _INTL("H (hold) / Z:   Run") : _INTL("Shift (hold) / Z:   Run"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Z (hold):   Smart Travel"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("S:   Registered Item"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("S (hold):   Text Log"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [blindstep ? _INTL("D:   Coordinates") : _INTL("D:   Quick Save"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [blindstep ? _INTL("D (hold):   Quick Save") : _INTL("D (hold):   Coordinates"), X, Y + LineHeight * (i += 1), 0, *TextColors]
  end

  def getBattleControlsKeyboard
    addTitle(mobile? ? _INTL("Battle Controls - Basic") : _INTL("Battle Controls - Keyboard"))
    megazring = $PokemonBag && MegaZItems.any? { |i| $PokemonBag.pbHasItem?(i) }
    fieldnotes = $game_switches && $game_switches[:Field_Notes]
    pulsenotes = $game_switches && $game_switches[:Pulse_Dex] && Reborn
    riftnotes = $game_switches && $game_switches[:RiftDex] && Rejuv
    i = 0
    @texts.push [_INTL("A:   Mega / Z-Move"), X, Y + LineHeight * (i += 1), 0, *TextColors] if megazring
    @texts.push [_INTL("S:   Battle Log"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("D:   Field Notes"), X, Y + LineHeight * (i += 1), 0, *TextColors] if fieldnotes
    @texts.push [_INTL("D (hold):   PULSE Notes"), X, Y + LineHeight * (i += 1), 0, *TextColors] if pulsenotes
    @texts.push [_INTL("D (hold):   Rift Notes"), X, Y + LineHeight * (i += 1), 0, *TextColors] if riftnotes
    @texts.push [!Desolation ? _INTL("Z:   Move Details / Default Poké Ball") : _INTL("Z:   Move Details"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Q:   Self Inspect"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("W:   Foe Inspect"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [mobile? ? _INTL("H:   Toggle Stat Boosts Visibility") : _INTL("Shift:   Toggle Stat Boosts Visibility"), X, Y + LineHeight * (i += 1), 0, *TextColors] unless Rejuv
  end

  def getPartyControlsKeyboard
    addTitle(mobile? ? _INTL("Party Controls - Basic") : _INTL("Party Controls - Keyboard"))
    remotepc = $PokemonBag&.pbHasItem?(:REMOTEPC)
    i = 0
    @texts.push [_INTL("A:   Switch"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("S:   Item"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("D:   Quick Summary"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Z:   Learn Moves"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Q:   Auto-Heal"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("W:   Edit Auto-Heal List"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("D (hold):   Summary"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Z (hold):   Remote PC"), X, Y + LineHeight * (i += 1), 0, *TextColors] if remotepc
  end

  def getStorageControlsKeyboard
    addTitle(mobile? ? _INTL("Storage Controls - Basic") : _INTL("Storage Controls - Keyboard"))
    i = 0
    @texts.push [_INTL("A:   Move"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("S:   Item"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("D:   Summary"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Z:   Multi-Move"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Q / W:   Previous Box / Next Box"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("A (hold):   Quick Swap"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("S (hold):   Toggle Party View"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Z (hold):   Deposit / Withdraw"), X, Y + LineHeight * (i += 1), 0, *TextColors]
  end


  def getGeneralControlsGamepad
    addTitle(_INTL("General Controls - Gamepad"))
    i = 0
    @texts.push [_INTL("       :   Select"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Cross]
    @images.push [@buttonCross, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("       :   Cancel"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Circle]
    @images.push [@buttonCircle, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("        (hold):   Skip Text"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Circle]
    @images.push [@buttonCircle, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("L1 / R1:   Previous Page / Next Page"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("R2 + L1 / R1:   Skip 10 Pages"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("L2 (hold) / Back:   Speed Up"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("LS:   Mute / Unmute"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Guide:   Soft Reset"), X, Y + LineHeight * (i += 1), 0, *TextColors]
  end

  def getOWControlsGamepad
    addTitle(_INTL("Overworld Controls - Gamepad"))
    blindstep = $game_switches && $game_switches[:Blindstep]
    i = 0
    @texts.push [_INTL("       :   Interact"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Cross]
    @images.push [@buttonCross, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("       :   Menu"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Circle]
    @images.push [@buttonCircle, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("R2 (hold) / Start:   Run"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Start (hold):   Smart Travel"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("       :   Registered Item"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Square]
    @images.push [@buttonSquare, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("        (hold):   Text Log"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Square]
    @images.push [@buttonSquare, X, Y + LineHeight * i + 4]
    @texts.push [blindstep ? _INTL("RS:   Coordinates") : _INTL("RS:   Quick Save"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [blindstep ? _INTL("RS (hold):   Quick Save") : _INTL("RS (hold):   Coordinates"), X, Y + LineHeight * (i += 1), 0, *TextColors]
  end

  def getBattleControlsGamepad
    addTitle(_INTL("Battle Controls - Gamepad"))
    megazring = $PokemonBag && MegaZItems.any? { |i| $PokemonBag.pbHasItem?(i) }
    fieldnotes = $game_switches && $game_switches[:Field_Notes]
    pulsenotes = $game_switches && $game_switches[:Pulse_Dex] && Reborn
    riftnotes = $game_switches && $game_switches[:RiftDex] && Rejuv
    i = 0
    if megazring
      @texts.push [_INTL("       :   Mega / Z-Move"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Triangle]
      @images.push [@buttonTriangle, X, Y + LineHeight * i + 4]
    end
    @texts.push [_INTL("        :   Battle Log"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Square]
    @images.push [@buttonSquare, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("RS:   Field Notes"), X, Y + LineHeight * (i += 1), 0, *TextColors] if fieldnotes
    @texts.push [_INTL("RS (hold):   PULSE Notes"), X, Y + LineHeight * (i += 1), 0, *TextColors] if pulsenotes
    @texts.push [_INTL("RS (hold):   Rift Notes"), X, Y + LineHeight * (i += 1), 0, *TextColors] if riftnotes
    @texts.push [!Desolation ? _INTL("Start:   Move Details / Default Poké Ball") : _INTL("Start:   Move Details"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("L1:   Self Inspect"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("R1:   Foe Inspect"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("R2:   Toggle Stat Boosts Visibility"), X, Y + LineHeight * (i += 1), 0, *TextColors] unless Rejuv
  end

  def getPartyControlsGamepad
    addTitle(_INTL("Party Controls - Gamepad"))
    remotepc = $PokemonBag && $PokemonBag.pbHasItem?(:REMOTEPC)
    i = 0
    @texts.push [_INTL("       :   Switch"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Triangle]
    @images.push [@buttonTriangle, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("       :   Item"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Square]
    @images.push [@buttonSquare, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("RS:   Quick Summary"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Start:   Learn Moves"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("L1:   Auto-Heal"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("R1:   Edit Auto-Heal List"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("RS (hold):   Summary"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Start (hold):   Remote PC"), X, Y + LineHeight * (i += 1), 0, *TextColors] if remotepc
  end

  def getStorageControlsGamepad
    addTitle(_INTL("Storage Controls - Gamepad"))
    i = 0
    @texts.push [_INTL("       :   Move"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Triangle]
    @images.push [@buttonTriangle, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("       :   Item"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Square]
    @images.push [@buttonSquare, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("RS:   Summary"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("Start:   Multi-Move"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("L1 / R1:   Previous Box / Next Box"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    @texts.push [_INTL("        (hold):   Quick Swap"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Triangle]
    @images.push [@buttonTriangle, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("        (hold):   Toggle Party View"), X, Y + LineHeight * (i += 1), 0, *TextColors, :Square]
    @images.push [@buttonSquare, X, Y + LineHeight * i + 4]
    @texts.push [_INTL("Start (hold):   Deposit / Withdraw"), X, Y + LineHeight * (i += 1), 0, *TextColors]
  end


  def addTitle(title)
    @texts.push [title + "<r>" + "< #{@page + 1}/#{TotalPages} >", X, Y, 0, *(@gamepad ? GamepadHeadingColors : KeyboardHeadingColors)]
  end

  def buttonBitmap(full)
    color_empty = KeyColors[0]
    color_full = KeyColors[0]

    bitmap = Bitmap.new(24, 24)

    renderButtonEmpty = -> (x, y) {
      for i in 0..3
        for j in 0..3
          next unless ([0, 3].include?(i) && [1, 2].include?(j)) || ([0, 3].include?(j) && [1, 2].include?(i))
          bitmap.set_pixel(x + i * 2, y + j * 2, color_empty)
          bitmap.set_pixel(x + i * 2 + 1, y + j * 2, color_empty)
          bitmap.set_pixel(x + i * 2, y + j * 2 + 1, color_empty)
          bitmap.set_pixel(x + i * 2 + 1, y + j * 2 + 1, color_empty)
        end
      end
    }

    renderButtonFull = -> (x, y) {
      for i in 0..3
        for j in 0..3
          next if [0, 3].include?(i) && [0, 3].include?(j)
          bitmap.set_pixel(x + i * 2, y + j * 2, color_full)
          bitmap.set_pixel(x + i * 2 + 1, y + j * 2, color_full)
          bitmap.set_pixel(x + i * 2, y + j * 2 + 1, color_full)
          bitmap.set_pixel(x + i * 2 + 1, y + j * 2 + 1, color_full)
        end
      end
    }

    (full == :Triangle ? renderButtonFull : renderButtonEmpty).call(8, 0)
    (full == :Square ? renderButtonFull : renderButtonEmpty).call(0, 8)
    (full == :Circle ? renderButtonFull : renderButtonEmpty).call(16, 8)
    (full == :Cross ? renderButtonFull : renderButtonEmpty).call(8, 16)

    return bitmap
  end
end

def controlsDialogue
  choices = {}
  choices[:configure] = _INTL("Configure (F1)") unless mobile?
  choices[:keyboard] = mobile? ? _INTL("View Basic Controls (F11)") : _INTL("View Keyboard Defaults (F2)")
  choices[:gamepad] = mobile? ? _INTL("View Gamepad Controls") : _INTL("View Gamepad Defaults")
  choices[:cancel] = _INTL("Cancel")

  choice = Kernel.pbChoice(_INTL("What would you like to do?"), choices)

  return if choice == :cancel || choice == nil

  if choice == :configure
    System.show_settings
    return
  end

  scene = DefaultControlsScene.new(0, choice == :gamepad)
  pbFadeOutIn(99999) { scene.pbRender }
end

def ttsSortControls(*sorttypes)
  strings = [_INTL("Sorting Controls")]
  for sorttype in sorttypes
    case sorttype
      when :name then string = _INTL("A: Sort by name")
      when :type then string = _INTL("Z: Sort by type")
      when :number then string = _INTL("S: Sort by number")
      else next
    end
    strings.push(string)
  end
  tts(strings.join("\n"), true)
end

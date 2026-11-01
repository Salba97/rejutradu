#===============================================================================
# Text Log
# Made for Reborn-verse engine
# With inspiration from Kyu's Kyu TextLog V3.0 for Pokémon Essentials
#===============================================================================

class PokemonGlobalMetadata
  attr_accessor :log
end

module TextLog
  TextLogLimit = 200

  def TextLog.add(text, tts: nil)
    return if $game_switches[:Wing_Dings] && !$game_switches[:Blindstep] # Don't log message when Terra takes away fonts, except for blindstep since we intentionally allowed TTS to bypass it

    $PokemonGlobal.log = [] if !$PokemonGlobal.log
    $PokemonGlobal.log.shift while $PokemonGlobal.log.length >= TextLogLimit
    $PokemonGlobal.log.push(tts.nil? ? text : [text, tts])
  end

  def TextLog.addChoiceText(text)
    return if $PokemonTemp.notLogging # Don't log choice if previous message had the <nolog> tag

    color = TextLog.getChoiceTextColor()
    TextLog.add(color + "    > " + text, tts: _INTL("Player Choice: {1}", text))
  end

  def TextLog.getChoiceTextColor() # For games to potentially override
    return ColorTags[:Blue2]
  end

  def TextLog.show(msgwindow = nil)
    # Don't allow showing in main menu (when no save file is loaded) ($game_map -is- reset on soft reset unlike other global variables)
    return unless $game_map
    # Don't allow showing while the message window is still drawing its text, but allow while it's waiting for player input to progress to the next line
    return if msgwindow&.busy? && !msgwindow.pausing?

    v = msgwindow.stopPause if msgwindow
    TextLogScene.new(msgwindow.nil?)
    msgwindow.startPause if msgwindow && v
  end
end

class TextLogScene
  LineHeight = 26
  LinePadding = 16
  TopYMargin = 14
  BottomYMargin = TopYMargin + LineHeight + 4
  RightXMargin = 20
  LeftXMargin = RightXMargin + 10 # Need to accommodate cursor on left side
  BackgroundOpacity = 200
  SliderSize = [10, 22] # Dimensions of the textLogSlider graphic ([width, height])
  SliderX = Graphics.width - SliderSize[0] - 8
  SliderTop = TopYMargin
  SliderBottom = Graphics.height - SliderTop

  def initialize(holdS)
    @holdS = holdS
    # Viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Background
    background = Sprite.new(@viewport)
    background.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    background.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
    background.opacity = BackgroundOpacity
    # Slider bar
    bar = shapeBitmap(:Rect, [SliderSize[0], SliderBottom - SliderTop], Color.new(80, 80, 80))
    pbDrawBitmap(background.bitmap, [bar, SliderX, SliderTop])
    # Canvas to draw text on
    canvassprite = Sprite.new(@viewport)
    canvassprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @canvas = canvassprite.bitmap
    pbSetSystemFont(@canvas)

    pbPlayDecisionSE()
    setup()

    loop do
      update()
      break if @close
    end
  end

  def getTexts
    texts = $PokemonGlobal.log.clone
    texts = [ColorTags[:Default] + _INTL("The Text Log is currently empty.")] if !texts || texts.empty?
    return texts
  end

  def setup
    # Initialize texts
    @texts = getTexts()
    @texts.map! { |text|
      # Each 'text' can either be a single string, or an array of the base string and an alternate TTS-friendly version
      next [modifyTextForLog(text[0]), text[1]] if text.is_a?(Array)
      next [modifyTextForLog(text), nil]
    }

    # Initialize cursor graphic
    @cursor = IconSprite.new(10, TopYMargin, @viewport)
    @cursor.setBitmap("Graphics/Pictures/selarrow")

    # Initialize slider graphic
    @slider = IconSprite.new(SliderX, SliderTop, @viewport)
    @slider.setBitmap("Graphics/Pictures/textLogSlider")

    # Simulate drawing from top to find out if there are enough lines to enable scrolling, draw from top if not
    enoughLines = false
    height = TopYMargin
    for text in @texts
      chars = getFormattedTextTextLog(text[0], height, -1)
      linecount = chars.map{ |chararray| chararray[0] }.count("\n") + 1
      height += LineHeight * linecount
      if height > Graphics.height - BottomYMargin
        enoughLines = true
        break
      end
      height += self.class::LinePadding
    end

    # cursorpositions stores the drawn dialogue indices and the heights at which they're drawn
    # topindex and bottomindex are respectively indices of the top-most and bottom-most dialogue on screen that isn't cut (or is the only one drawn)
    @cursorpositions = {}
    if enoughLines
      @bottomindex = @texts.length - 1
      drawLinesFromBottom()
    else
      @topindex = 0
      drawLinesFromTop()
    end
    @cursorindex = @bottomindex
    updateCursor()
  end

  def drawLinesFromTop
    @cursorpositions.clear
    height = TopYMargin
    i = @topindex
    while i <= @texts.length - 1
      text = @texts[i][0]

      # Draw next dialogue upto the part that fits
      chars = getFormattedTextTextLog(text, height, -1)
      fullchars = chars.clone
      chars.filter! { |chararray| chararray[2] <= Graphics.height - BottomYMargin }
      drawFormattedChars(@canvas, chars)

      # If the dialogue didn't fit completely, stop drawing
      if chars != fullchars
        # But update cursorpositions and bottomindex if it was the first (and only) dialogue drawn
        if i == @topindex
          @cursorpositions[i] = height
          @bottomindex = i
        end

        return
      end

      @cursorpositions[i] = height
      @bottomindex = i

      linecount = chars.map{ |chararray| chararray[0] }.count("\n") + 1
      height += LineHeight * linecount
      height += self.class::LinePadding
      i += 1
    end
  end

  # Significantly more complicated than drawLinesFromTop, which is to be expected, since text is supposed to be written from top to bottom and that's how the text drawing function works
  def drawLinesFromBottom
    @cursorpositions.clear
    height = Graphics.height - BottomYMargin + LineHeight
    i = @bottomindex
    while i >= 0
      text = @texts[i][0]

      # Calculate how many lines the next dialogue is gonna take
      chars = getFormattedTextTextLog(text, TopYMargin, -1)
      linecount = chars.map{ |chararray| chararray[0] }.count("\n") + 1

      # If the next dialogue will fit in the available space, move up, calc, and draw as normal
      if linecount * LineHeight <= height
        height -= LineHeight * linecount
        chars = getFormattedTextTextLog(text, height, Graphics.height - TopYMargin - BottomYMargin)
        drawFormattedChars(@canvas, chars)

        @cursorpositions[i] = height
        @topindex = i

        height -= self.class::LinePadding
        i -= 1
      # If the next dialogue won't fit in the available space, draw the part that fits and then exit
      else
        # If it's the first (and only) dialogue being drawn, draw as if drawing from top, and also update cursorpositions and topindex
        if i == @bottomindex
          # Can just use the already calced chars since we actually have to draw from TopYMargin
          chars.filter! { |chararray| chararray[2] <= height }
          drawFormattedChars(@canvas, chars)

          @cursorpositions[i] = TopYMargin
          @topindex = i

          return
        # Otherwise, move up, calc, trim off overflowing lines from top, and draw the rest (and skip updating cursorpositions and topindex)
        else
          newheight = height - (linecount * LineHeight)
          chars = getFormattedTextTextLog(text, newheight, -1)
          chars.filter! { |chararray| chararray[2] >= 0 }
          drawFormattedChars(@canvas, chars)

          return
        end
      end
    end
  end

  def updateCursor
    # TTS selected line
    line = @texts[@cursorindex]
    tts(line[1].nil? ? toUnformattedText(line[0]) : line[1], true)

    # Update cursor position
    @cursor.y = @cursorpositions[@cursorindex]

    # Update slider position
    height = SliderTop
    if @texts.length > 1
      range = SliderBottom - SliderTop - SliderSize[1]
      height += range.to_f * @cursorindex / (@texts.length - 1)
      height = height.round.to_grid
    end
    @slider.y = height
  end

  def update
    Graphics.update
    Input.update
    oldcursorindex = @cursorindex

    if @texts.length > 1
      down = 0
      down = 1 if Input.repeat?(Input::DOWN) || Input.repeat?(Input::RIGHT)
      down = Input.shiftKeyPressed? ? 100 : 10 if Input.repeat?(Input::R)
      if Input.trigger?(Input::DOWN) && @cursorindex >= @texts.length - 1
        # Loop around when Down pressed (NOT held, hence trigger? instead of repeat?)
        @cursorindex = 0
      else
        # Go to next dialogue (Down = x1, PgDown = x10, Shift + PgDown = x100)
        down.times { @cursorindex >= @texts.length - 1 ? break : @cursorindex += 1 }
      end

      up = 0
      up = 1 if Input.repeat?(Input::UP) || Input.repeat?(Input::LEFT)
      up = Input.shiftKeyPressed? ? 100 : 10 if Input.repeat?(Input::L)
      if Input.trigger?(Input::UP) && @cursorindex <= 0
        # Loop around when Up pressed (NOT held, hence trigger? instead of repeat?)
        @cursorindex = @texts.length - 1
      else
        # Go to previous dialogue (Up = x1, PgUp = x10, Shift + PgUp = x100)
        up.times { @cursorindex <= 0 ? break : @cursorindex -= 1 }
      end
    end

    if @cursorindex != oldcursorindex
      if @cursorindex > @bottomindex
        @canvas.clear
        @bottomindex = @cursorindex
        drawLinesFromBottom()
      end
      if @cursorindex < @topindex
        @canvas.clear
        @topindex = @cursorindex
        drawLinesFromTop()
      end
      pbPlayCursorSE()
      updateCursor()
    end

    if Input.trigger?(Input::B) || Input.trigger?(Input::C) || (!@holdS && Input.trigger?(Input::Y))
      # We can't close the log on pressing S if it was opened by holding S, because that causes registered item use to be triggered as soon as the log is closed
      close()
    end
  end

  def close
    @viewport.dispose
    pbPlayCancelSE()
    @close = true
  end

  def modifyTextForLog(text) # Makes some modifications like replacing tags before displaying
    # Remove unprintable characters that are needed when displaying messages in dialogue boxes (for the sake of TTS)
    text = TextPlaceholders.removeFrom(text)
    # Replace color tags for light windowskins with color tags for dark windowskins, since text log always has a dark background
    ColorsUsedInEvents.each { |key| text.gsub!(LightColorTags[key], ColorTags[key]) }
    # Remove alignment tags
    alignmenttags = ["<ac>", "</ac>", "<al>", "</al>", "<ar>", "</ar>", "<r>"]
    alignmenttags.each { |tag| text.gsub!(tag, "") }
    # Remove font size tags
    text.gsub!(/<fs=[0-9]+>/, "")
    text.gsub!("</fs>", "")
    return text
  end

  def getFormattedTextTextLog(text, startheight, endheight) # Utility function
    return getFormattedText(@canvas, LeftXMargin, startheight, Graphics.width - LeftXMargin - RightXMargin, endheight, text, LineHeight)
  end
end

class BattleLogScene < TextLogScene
  LinePadding = 10

  def initialize(scene, busy_msgwindow)
    @scene = scene
    @busy_msgwindow = busy_msgwindow
    super(false)
  end

  def getTexts
    texts = @scene.log.clone

    # If a message is being displayed and waiting for player input to progress to the next line, don't show that message
    # This behaviour is intentionally different from the OW log which doesn't show messages till they have been removed from the screen
    texts.pop if @busy_msgwindow

    texts = [_INTL("The Battle Log is currently empty.")] if !texts || texts.empty?
    return texts
  end

  def modifyTextForLog(text)
    text = ColorTags[:Default] + text unless text.start_with?("<c")
    return text
  end
end

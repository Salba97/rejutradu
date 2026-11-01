class BlessingsScene

  def initialize(group, blessings)
    pbSEPlay("PRSFX- Twinkle Tackle3", 100, 145)
    @blessings = blessings
    @dimport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @dimport.tone.set(-50, -50, -50, 0)

    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @path = "Graphics/Pictures/BlessingUI/"

    @sprites["portrait"] = IconSprite.new(0, 0, @viewport)
    @sprites["portrait"].setBitmap(@path + "portraits#{group}")
    @sprites["portrait"].visible = false

    space = 8 * [0, 2, 1][@blessings.length - 1]
    startOffset = 57
    yStart = ((302 - (space * (@blessings.length - 1)) - (86 * @blessings.length)) / 2) + startOffset
    @choiceOffset = 86 + space

    width = 300
    x = 1.0
    for i in 0...@blessings.length
      @sprites["blessing#{i}"] = BlessingBox.new(blessings[i], 0, yStart + (@choiceOffset * i), @viewport)
      @sprites["blessing#{i}"].x -= width * (x)
      x += 0.5
    end


    @arrowY = yStart - 8
    @index = 0
    @sprites["arrow"] = IconSprite.new(218, @arrowY, @viewport)
    @sprites["arrow"].setBitmap(@path + "arrow")
    @sprites["arrow"].visible = false

    @sprites["overlay"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"].setBitmap(@path + "blessingOverlay")
    @sprites["overlay"].visible = false

    m = ["portrait", "overlay"]
    m.each { |spr|
      @sprites[spr].tone.set(255, 255, 255, 0)
      @sprites[spr].opacity = 0
      @sprites[spr].visible = true
    }

    for i in 0...5
      m.each { |spr| @sprites[spr].opacity += 51 }
      pbWait(1)
    end

    x = 255
    for i in 0...10
      x -= 25.5
      m.each { |spr| @sprites[spr].tone.set(x, x, x, 0) }
      pbWait(1)
    end

    inc = 25
    for i in 0...30
      for j in 0...@blessings.length
        @sprites["blessing#{j}"].x += inc unless @sprites["blessing#{j}"].x == 0
        @sprites["blessing#{j}"].x = 0 if @sprites["blessing#{j}"].x + inc >= 0
      end
      pbWait(1)
    end

    @sprites["arrow"].visible = true
    changeIndex(0)
  end

  def main

    choice = nil
    loop do
      Graphics.update
      Input.update
      choice = update
      break if !choice.nil?

    end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @dimport.dispose

    return nil if choice == -1
    return @blessings[choice]
  end

  def update
    pbUpdateSpriteHash(@sprites)
    if Input.trigger?(Input::C)
      return @index
    end
    if Input.trigger?(Input::UP)
      changeIndex(-1)
    end
    if Input.trigger?(Input::DOWN)
      changeIndex(1)
    end
    if Input.trigger?(Input::B)
      # Switch to map screen
      pbPlayCancelSE()

      return -1
    end
    return nil
  end

  def changeIndex(val)
    return if @blessings.length <= 1
    if val != 0
      @index += val
      @index = 2 if @index < 0
      @index = 0 if @index > 2
      newY = @arrowY + (@choiceOffset * @index)

      diff = ((newY - @sprites["arrow"].y) / 4.0)
      for i in 0...4
        @sprites["arrow"].y += diff
        pbWait(1)
      end
      pbPlayCursorSE()
    end

    for i in 0...@blessings.length
      @sprites["blessing#{i}"].updateBitmap(@index == i)
    end
  end
end

class BlessingBox < IconSprite
  def initialize(blessing, x, y, viewport)
    super(x, y, viewport)
    @initialized = true
    @blessing = blessing
    @rank = getBlessingRank(blessing) + 1
    updateBitmap
  end

  def updateBitmap(highlighted = false)
    pbPlayDecisionSE()
    path = "Graphics/Pictures/BlessingUI/blessingChoice"
    maxRank = $cache.blessings[@blessing].maxRank
    ranks = [1, 2, 3][0...maxRank]
    path += "#{ranks[@rank - 1]}"
    path += "Highlighted" if highlighted
    setBitmap(path)
  end

  def setBitmap(loc)
    super(loc)
    drawText
  end

  def x=(value)
    super(value)
    drawText if @initialized
  end

  def visible=(value)
    super
    @textbmp.visible = value if @initialized
  end

  def dispose
    super
    @textbmp&.dispose
  end

  def drawText

    @textbmp&.dispose
    @textbmp = BitmapSprite.new(self.bitmap.width, self.bitmap.height, @viewport)
    @textbmp.x = self.x
    @textbmp.y = self.y
    @textbmp.z = 99999
    color = Color.new(248, 248, 248)
    shadow = Color.new(0, 0, 0)
    pbSetSystemFont(@textbmp.bitmap)


    rankText = "I" * @rank
    text = getBlessingName(@blessing) + " " + rankText

    fontsize = @textbmp.bitmap.font.size / 2.0
    drawFormattedTextEx(@textbmp.bitmap, 12, 2, @textbmp.bitmap.width - 72, "<ac><fs=#{fontsize}>#{text}</fs></ac>", color, shadow, 16)

    pbSetSmallFont(@textbmp.bitmap)

    fontsize = @textbmp.bitmap.font.size / 2.0
    desc = getBlessingDesc(@blessing, @rank)
    drawFormattedTextEx(@textbmp.bitmap, 12, 20, @textbmp.bitmap.width - 72, "<ac><fs=#{fontsize}>#{desc}</fs></ac>", color, shadow, 10)
  end
end

def rollBlessing(group)
  pool = $cache.blessings.keys.find_all { |blessing| $cache.blessings[blessing].group == group && getBlessingRank(blessing) < $cache.blessings[blessing].maxRank }
  size = pool.length < 3 ? pool.length : 3
  sel = pool.sample(size, random: $PokemonGlobal.xenTower.random)
  (clearBlessingOverlay; cleared = true) if $game_temp.blessing_overlay&.visible
  scene = BlessingsScene.new(group, sel)
  choice = scene.main
  if choice
    pbSEPlay("expfull")

    addBlessing(choice)
    startBlessingOverlay if cleared
    showBlessings if !$game_temp.blessing_overlay&.visible && $Settings.alwaysShowOverlay
  end
end

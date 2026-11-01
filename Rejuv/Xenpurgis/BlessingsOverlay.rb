class BlessingsOverlay
  attr_accessor :sprites
  attr_accessor :viewport
  attr_accessor :visible
  attr_accessor :focused
  attr_accessor :need_redraw

  BOXWIDTH = Graphics.width - 86

  def initialize(visible, focused = false)
    @visible = visible
    @need_redraw = false
    @focused = focused
    @curX = 0
    @curY = 0
    @index = 0
    @dimport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @dimport.z = 99999
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @blessingSprites = {}
    @sprites["bg"] = IconSprite.new(0, -16, @viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Blessings/hudBlessingBG")
    @sprites["bg"].visible = @visible
    drawBlessings
    @sprites["mouseOverWindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["mouseOverWindow"].visible = false
    @sprites["infowindow"] = Window_AdvancedTextPokemon.newWithSize("", 0, 106, Graphics.width, 32, @viewport)
    @sprites["infowindow"].visible = false
    updateInfoWindow
    @sprites["cursor"] = IconSprite.new(0, 0, @viewport)
    @sprites["cursor"].setBitmap("Graphics/Pictures/Blessings/blessingCursor")
    @sprites["cursor"].visible = @focused
    @showingInfo = nil
  end

  def visible=(value)
    @visible = value
    if value == false
      pbHideMenu
    else
      pbShowMenu
    end
  end

  def focused=(value)
    @focused = value == 1 ? true : value
    if value != 1
      @curX = 0
      @curY = 0
      @index = 0
      @sprites["cursor"].x = 0
      @sprites["cursor"].y = 0
    end
    @sprites["cursor"].visible = @focused
    @sprites["infowindow"].visible = @focused

    if @focused == true
      @dimport.tone.set(-50, -50, -50, 0)
      self.visible = true
    else
      @dimport.tone.set(0, 0, 0, 0)
      self.visible = false if $Settings.alwaysShowOverlay == 0
    end
  end

  def focus(fromMouse = false)
    self.focused = fromMouse ? 1 : true
    updateInfoWindow
    loop do
      Graphics.update
      Input.update
      return if !@focused
      update
    end
  end

  def drawBlessings
    @blessingSprites.each { |_, v| v.dispose }
    @cachedBlessings = getPlayerBlessings.dup
    x = -32
    y = 0
    @cachedBlessings.each { |blessing, rank|
      if x + 32 >= Graphics.width
        x = 0
        y += 32
      else
        x += 32
      end
      @blessingSprites[blessing] = BlessingIcon.new(blessing, rank, x, y, @viewport)
      @blessingSprites[blessing].visible = @visible
    }
    @rows = y / 32 + 1
    @columns = @rows > 1 ? 16 : x / 32 + 1
    @maxX = x / 32
  end

  def pbShowMenu
    @sprites.merge(@blessingSprites).each { |n, s| s.visible = true unless (n == "mouseOverWindow" && !@showingInfo) || (["cursor", "infowindow"].include?(n) && !@focused) }
  end

  def pbHideMenu
    @sprites.merge(@blessingSprites).each { |_, s| s.visible = false }
  end

  def update
    drawBlessings if @cachedBlessings != getPlayerBlessings

    if $Settings.ignoreMouse == 1 && !mobile?
      anyMouseOver = nil
      @blessingSprites.each { |symbol, sprite|
        if sprite.is_a?(BlessingIcon)
          if sprite.isMouseOver?
            anyMouseOver = sprite.blessing
            showMouseOverWindow(sprite) if @showingInfo != anyMouseOver
          end
        end
      }
      hideMouseOverWindow if !anyMouseOver && @showingInfo

      if @showingInfo
        mouse = Mouse::getMousePos(true)
        offsetX = [0, BORDERWIDTH][$Settings.border]
        offsetY = [0, BORDERHEIGHT][$Settings.border]
        mouse[0] += 12 - offsetX
        mouse[1] += 12 - offsetY
        x = mouse[0]
        if x + @sprites["mouseOverWindow"].width > Graphics.width
          x = Graphics.width - @sprites["mouseOverWindow"].width
        end
        @sprites["mouseOverWindow"].x = x
        @sprites["mouseOverWindow"].y = mouse[1]
      end

      if Input.triggerex?(Input::LeftMouseKey) || Input.triggerex?(Input::RightMouseKey)
        if anyMouseOver
          oldindex = @index
          @index = @cachedBlessings.keys.index(@showingInfo)

          x = @blessingSprites[@showingInfo].x
          y = @blessingSprites[@showingInfo].y
          @sprites["cursor"].x = x
          @sprites["cursor"].y = y
          @curX = x / 32
          @curY = y / 32
          if !@focused
            self.focus(true)
          else
            updateInfoWindow if @index != oldindex
          end
        else
          self.focused = false unless isMouseOverInfoWindow?
        end
      end
    end

    if @focused
      oldindex = @index
      if Input.trigger?(Input::UP)
        updateCursor(:y, 1)
      end
      if Input.trigger?(Input::DOWN)
        updateCursor(:y, -1)
      end
      if Input.trigger?(Input::RIGHT)
        updateCursor(:x, 1)
      end
      if Input.trigger?(Input::LEFT)
        updateCursor(:x, -1)
      end
      if Input.trigger?(Input::B)
        # Switch to map screen
        pbPlayCancelSE()

        self.focused = false
      end
      updateInfoWindow if @index != oldindex
    end

    pbUpdate
  end

  def updateCursor(axis, amt)
    case axis
      when :x
        @curX += amt
        if @curX > @columns - 1
          @curX = 0
        end
        if @curX < 0
          @curX = @columns - 1
        end

        @sprites["cursor"].x = @curX * 32
      when :y
        return if @rows == 1
        return if @curY == @rows - 1 && @curX > @maxX

        @curY += amt
        if @curY > @rows - 1
          @curY = 0
        end
        if @curY < 0
          @curY = @rows - 1
        end

        @sprites["cursor"].y = @curY * 32
      else
        return
    end
    @index = @curX + (@curY * 16)
    pbPlayCursorSE()
  end

  def showMouseOverWindow(sprite)
    blessing = sprite.blessing
    text = getBlessingDesc(blessing, sprite.rank)
    @sprites["mouseOverWindow"].resizeToFit(text, BOXWIDTH)
    @sprites["mouseOverWindow"].text = text
    @sprites["mouseOverWindow"].visible = true
    @showingInfo = blessing
  end

  def hideMouseOverWindow
    @sprites["mouseOverWindow"].visible = false
    @showingInfo = nil
  end

  def updateInfoWindow
    return if !@focused

    blessing = getPlayerBlessings.keys[@index]
    rank = getBlessingRank(blessing)
    rankText = "I" * rank
    desc = "<fn=#{pbSmallFontName}><fs=25><lh=22>" + getBlessingDesc(blessing, rank, true)
    text = getBlessingName(blessing) + " " + rankText + "\n" + desc

    rules = getBlessingRules(blessing)
    text = text + "\n#{ColorTags[:Gray]}" + rules.join("\n") + "</c3>" if !rules.empty?
    text += "</lh></fs></fn>"

    @sprites["infowindow"].text = text
    @sprites["infowindow"].resizeHeightToFit(text, Graphics.width)
    @sprites["infowindow"].y = (Graphics.height - @sprites["infowindow"].height) / 2
  end

  def isMouseOverInfoWindow?
    mouse = Mouse::getMousePos(true)
    offsetX = [0, BORDERWIDTH][$Settings.border]
    offsetY = [0, BORDERHEIGHT][$Settings.border]
    rect = Rect.new(@sprites["infowindow"].x + offsetX, @sprites["infowindow"].y + offsetY, @sprites["infowindow"].width, @sprites["infowindow"].height)
    return rect.contains(mouse[0], mouse[1])
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    pbUpdateSpriteHash(@blessingSprites)
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@blessingSprites)
    @viewport.dispose
    @dimport.dispose
  end

  def redraw
    @dimport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @dimport.tone.set(-50, -50, -50, 0) if @focused
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    @sprites.each { |_, s| s.viewport = viewport }
    @blessingSprites.each { |_, s| s.viewport = viewport }
    @viewport = viewport
    pbUpdate
  end
end

class BlessingIcon < IconSprite
  attr_reader :blessing
  attr_reader :rank
  def initialize(blessing, rank, x, y, viewport = nil)
    super(viewport)
    @blessing = blessing
    self.x = x
    self.y = y
    iconPath = $cache.blessings[@blessing].icon
    iconPath = "Graphics/Pictures/Blessings/#{@blessing}" if !pbResolveBitmap(iconPath)
    iconPath = "Graphics/Icons/bosstypeQMARKS" if !pbResolveBitmap(iconPath)
    icon = AnimatedBitmap.new(iconPath)
    bmp = BitmapWrapper.new(32, 32)
    width = (bmp.width - icon.width) / 2
    height = (bmp.height - icon.height) / 2
    bmp.blt(width, height, icon.bitmap, Rect.new(0, 0, icon.width, icon.height))
    icon.dispose
    self.bitmap = bmp
    pbSetSmallFont(self.bitmap)
    @rank = rank
    chars = getFormattedText(self.bitmap, 2, -8, bitmap.width, bitmap.height, "<ar><fs=#{self.bitmap.font.size / 2}>#{"I" * @rank}<fs></ar>")
    drawFormattedChars(self.bitmap, chars)
  end

  def isMouseOver?
    mouse = Mouse::getMousePos(true)
    offsetX = [0, BORDERWIDTH][$Settings.border]
    offsetY = [0, BORDERHEIGHT][$Settings.border]
    rect = Rect.new(self.x + offsetX, self.y + offsetY, self.bitmap.width, self.bitmap.height)
    return rect.contains(mouse[0], mouse[1])
  end
end

class Game_Temp
  attr_accessor :blessing_calling
end

class Scene_Map
  def checkKeyPresses
    if Input.trigger?(Input::X) && $game_temp.blessing_overlay
      $game_temp.blessing_calling = true
    end
  end

  def handleKeyPresses
    if $game_temp.blessing_calling
      call_blessing
    end
  end

  def call_blessing
    $game_player.straighten
    $game_map.update
    $game_temp.blessing_overlay.focus if !$PokemonGlobal.xenTower.blessings.empty?
    $game_temp.blessing_calling = false
    $game_screen.getTimeCurrent(true)
    $game_map.refresh
  end
end

class Game_Character
  unless @blessingAliases
    alias __blessings_updateOther updateOther
    @blessingAliases = true
  end
  def updateOther
    __blessings_updateOther
    if $game_temp.blessing_overlay
      showBlessings if $Settings.alwaysShowOverlay == 1 && $game_temp.blessing_overlay.visible == false && $game_switches[2091] && !pbMapInterpreterRunning?
      hideBlessings if ($Settings.alwaysShowOverlay == 0 || pbMapInterpreterRunning?) && $game_temp.blessing_overlay.visible == true
      $game_temp.blessing_overlay.update if $Settings.alwaysShowOverlay == 1 && $game_temp.blessing_overlay.visible == true
      clearBlessingOverlay if $game_switches[1958]
    end
  end
end

class PokeBattle_Scene
  def checkKeyPressesCommand
    # Check for shift and EXCLUDE Meta/Ctrl/Alt + Shift keybinds
    if Input.shiftKeyTriggered? && !Input.isComboKeyPressed?
      call_blessing
    end
  end

  def checkKeyPressesFight
    if Input.shiftKeyTriggered? && !Input.isComboKeyPressed?
      call_blessing
    end
  end

  def checkKeyPressesFightDx
    if Input.shiftKeyTriggered? && !Input.isComboKeyPressed?
      call_blessing
    end
  end

  def call_blessing
    return if !xenTowerInProgress || getPlayerBlessings.empty?
    s = BlessingsOverlay.new(true)
    s.focus
    s.pbEndScene
  end
end

class Game_Screen
  attr_accessor :showingBlessings
end

def startBlessingOverlay(visible = false)
  $game_temp.blessing_overlay = BlessingsOverlay.new(visible)
  $game_screen.showingBlessings = visible
end

def showBlessings
  return if !$game_temp.blessing_overlay
  $game_temp.blessing_overlay.visible = true
  $game_screen.showingBlessings = true
end

def hideBlessings
  return if !$game_temp.blessing_overlay
  $game_temp.blessing_overlay.visible = false
  $game_screen.showingBlessings = false
end

def clearBlessingOverlay
  $game_temp.blessing_overlay.pbEndScene
  $game_temp.blessing_overlay = nil
  $game_screen.showingBlessings = nil
end

begin
  def pbTilesetWrapper
    return PokemonDataWrapper.new(
      "Data/Tilesets.rxdata",
      "Data/TilesetsTemp.rxdata",
      Proc.new {
        Kernel.pbMessage(_INTL("The editor has detected that the tileset data was recently edited in RPG Maker XP."))
        next !Kernel.pbConfirmMessage(_INTL("Do you want to load those recent edits?"))
      }
    )
  end

  class PokemonTilesetScene

    ROW_SIZE = 8
    AUTOTILE_SIZE = 48
    TILE_SIZE = 32
    CURSOR_THICKNESS = 4
    COLLISION_THICKNESS = 4
    RESERVED_AUTOTILES = ROW_SIZE * AUTOTILE_SIZE

    CHECKERBOARD_LIGHT = Color.new(192, 192, 192)
    CHECKERBOARD_DARK = Color.new(128, 128, 128)
    SELECTION_COLOR = Color.new(255, 0, 0)
    HOVER_COLOR = Color.new(0, 255, 0, 100)
    PRIORITY_COLORS = [Color.new(0, 0, 255), Color.new(0, 50, 255), Color.new(0, 100, 255), Color.new(0, 150, 255), Color.new(0, 200, 255)]
    BUSH_COLOR = Color.new(255, 255, 255)
    COUNTER_COLOR = Color.new(50, 200, 200)

    COLLISION_COLOR = Color.new(128, 0, 0)

    def tileset_size
      return @tileset.terrain_tags.xsize
    end

    def display_height
      return (Graphics.height - 64) / TILE_SIZE
    end

    def tileset_height
      totalsize = tileset_size - RESERVED_AUTOTILES + ROW_SIZE
      return (totalsize.to_f / ROW_SIZE).ceil
    end

    def row(tile)
      return 0 if tile < RESERVED_AUTOTILES
      return (tile - RESERVED_AUTOTILES + ROW_SIZE) / ROW_SIZE
    end

    def column(tile)
      return tile / AUTOTILE_SIZE if tile < RESERVED_AUTOTILES
      return (tile - RESERVED_AUTOTILES) % ROW_SIZE
    end

    def current_row_min
      return @selected.map { |it| row(it) }.min
    end

    def current_column_min
      return @selected.map { |it| column(it) }.min
    end

    def current_row_max
      return @selected.map { |it| row(it) }.max
    end

    def current_column_max
      return @selected.map { |it| column(it) }.max
    end

    def recenter_screen(target)
      if target < RESERVED_AUTOTILES
        @scroll = 0
      else
        @scroll = [row(target) - 5, 0].max
      end
    end

    def set_selected(row_or_tile, column = nil)
      target = column ? tileset_position(row_or_tile, column) : row_or_tile

      if target < RESERVED_AUTOTILES
        target -= target % AUTOTILE_SIZE
      end

      recenter_screen(target)

      @selected = [target]
    end

    def move_cursor(direction, wasTrigger = false)
      shiftLength = 0
      shiftDirection = nil
      targetRow = current_row_min
      targetColumn = current_column_min
      case direction
        when :Up
          if targetRow <= 0 && wasTrigger
            shiftLength = 1
            shiftDirection = :Up
            targetRow = tileset_height - 1
            @scroll = [targetRow - 5, 0].max
          elsif targetRow > 0
            targetRow -= 1
            shiftLength = 1
            shiftDirection = :Up
            @scroll = targetRow if targetRow < @scroll
          end
        when :Down
          if targetRow + 1 >= tileset_height && wasTrigger
            shiftLength = 1
            shiftDirection = :Down
            targetRow = 0
            @scroll = 0
          elsif targetRow + 1 < tileset_height
            shiftLength = 1
            shiftDirection = :Down
            targetRow += 1
            @scroll += 1 if targetRow - @scroll >= display_height
          end
        when :Left
          if targetColumn <= 0 && wasTrigger
            shiftLength = 1
            shiftDirection = :Left
            targetColumn = ROW_SIZE - 1
          elsif targetColumn > 0
            shiftLength = 1
            shiftDirection = :Left
            targetColumn -= 1
          end
        when :Right
          if targetColumn >= ROW_SIZE - 1 && wasTrigger
            shiftLength = 1
            shiftDirection = :Right
            targetColumn = 0
          elsif targetColumn < ROW_SIZE - 1
            shiftLength = 1
            shiftDirection = :Right
            targetColumn += 1
          end
        when :PageUp
          if targetRow == 0 && wasTrigger
            shiftLength = display_height
            shiftDirection = :Up
            targetRow = tileset_height - 1
            @scroll = [targetRow - 5, 0].max
          elsif targetRow > 0
            shiftLength = [display_height, targetRow].min
            shiftDirection = :Up
            targetRow -= display_height
            targetRow = 0 if targetRow < 0
            @scroll -= display_height
            @scroll = 0 if @scroll < 0
          end
        when :PageDown
          if targetRow + display_height >= tileset_height && wasTrigger
            shiftLength = display_height
            shiftDirection = :Down
            targetRow = 0
            @scroll = 0
          elsif targetRow + display_height < tileset_height
            shiftLength = [tileset_height - targetRow, display_height].min
            shiftDirection = :Down
            targetRow += display_height
            targetRow = tileset_height if targetRow > tileset_height
            @scroll += display_height
            @scroll = tileset_height - display_height if @scroll >= tileset_height - display_height
          end
      end

      target = tileset_position(targetRow, targetColumn)
      recenter_screen(target) if targetRow < @scroll || targetRow >= @scroll + display_height

      shift = Input.press?(Input::SHIFT)
      ctrl = Input.press?(Input::CTRL)
      if shift || ctrl
        # This shift behavior isn't perfect - can't shrink selection box
        shifting = @selected
        shiftLength.times {
          shifted = []
          shifting.each { |pos|
            posRow = row(pos)
            posColumn = column(pos)

            case shiftDirection
              when :Up
                posRow -= 1
                posRow = tileset_height if posRow < 0
              when :Down
                posRow += 1
                posRow = 0 if posRow >= tileset_height
              when :Left
                posColumn -= 1
                posColumn = ROW_SIZE if posColumn < 0
              when :Right
                posColumn += 1
                posColumn = 0 if posColumn >= ROW_SIZE
            end

            shifted.push(tileset_position(posRow, posColumn))
          }
          @selected += shifted if shift
          shifting = shifted
        }
        if ctrl && !shift
          @selected = shifting
        end
        @selected.uniq!
      else
        @selected = [target]
      end
      pbUpdateTileset
    end

    def tileset_position(rowIdx, columnIdx)
      return AUTOTILE_SIZE * columnIdx if rowIdx == 0
      return RESERVED_AUTOTILES + (rowIdx - 1) * ROW_SIZE + columnIdx
    end

    def terrain_tag_name(tag)
      return "No tag" if tag == 0
      return "N/A" if tag.nil?
      return getConstantName(PBTerrain, tag)
    end

    #####################
    ### Undo handling
    #####################

    def recordAction(action, commitAction)
      if commitAction
        if @actionStack.size > @actionStackPosition
          @actionStack.slice! @actionStackPosition..
        end
        @actionStack.push(action)
      end
      @actionStackPosition += 1
    end

    def undoAction
      return unless @actionStackPosition > 0
      @actionStackPosition -= 1
      prevAction = @actionStack[@actionStackPosition]
      tag = prevAction[0]
      positions = prevAction[1]

      reversionTarget = nil
      text = nil

      case tag
        when :TerrainTag
          reversionTarget = @tileset.terrain_tags
          text = _INTL("Undo Edit Terrain Tag")
        when :PassageBit
          reversionTarget = @tileset.passages
          text = _INTL("Undo Edit Collision")
        when :Priority
          reversionTarget = @tileset.priorities
          text = _INTL("Undo Edit Priority")
      end

      if reversionTarget
        for pos, idx in positions.to_enum.with_index.reverse_each
          if pos < RESERVED_AUTOTILES
            autotile = pos - (pos % AUTOTILE_SIZE)
            for i in 0...AUTOTILE_SIZE
              reversionTarget[autotile + i] = prevAction[2][idx][i]
            end
          else
            reversionTarget[pos] = prevAction[2][idx]
          end
        end
      end

      doPopup(text) if text
      pbUpdateTileset
    end

    def redoAction
      return unless @actionStack.size > @actionStackPosition
      nextAction = @actionStack[@actionStackPosition]
      tag = nextAction[0]
      positions = nextAction[1]
      case tag
        when :TerrainTag
          setTerrainTag(positions, nextAction[3], commitAction: false)
          doPopup(_INTL("Redo Edit Terrain Tag"))
        when :PassageBit
          setPassageBit(positions, nextAction[3], nextAction[4], commitAction: false)
          doPopup(_INTL("Redo Edit Collision"))
        when :Priority
          setPriority(positions, nextAction[3], commitAction: false)
          doPopup(_INTL("Redo Edit Priority"))
      end
      pbUpdateTileset
    end

    def doPopup(text)
      if @sprites["popup"] && !@sprites["popup"].disposed?
        @sprites["popup"].dispose
      end
      @sprites["popup"] = PopupWindow.new(text)
    end

    def applyChangeAndCollect(target, pos, value = nil)
      if pos < RESERVED_AUTOTILES
        autotile = pos - (pos % AUTOTILE_SIZE)
        autotileValues = []
        for i in 0...AUTOTILE_SIZE
          autotileValues.push(target[autotile + i])
          if block_given?
            yield target, autotile + i
          elsif value
            target[autotile + i] = value
          end
        end
        return autotileValues
      else
        prevValue = target[pos]
        if block_given?
          yield target, pos
        elsif value
          target[pos] = value
        end
        return prevValue
      end
    end

    def setTerrainTag(positions, value, commitAction: true)
      prevValues = []
      for pos in positions
        prevValues.push(applyChangeAndCollect(@tileset.terrain_tags, pos, value))
      end
      recordAction([:TerrainTag, positions, prevValues, value], commitAction)
    end

    def flipPassageBit(positions, bit, commitAction: true)
      value = positions.any? { |pos| (@tileset.passages[pos] & bit) != bit }
      setPassageBit(positions, bit, value, commitAction: commitAction)
    end

    def setPassageBit(positions, bit, value, commitAction: true)
      prevValues = []
      for pos in positions
        prevValues.push(applyChangeAndCollect(@tileset.passages, pos) { |target, subpos|
          target[subpos] |= bit
          target[subpos] ^= bit if !value # Negates
        })
      end
      recordAction([:PassageBit, positions, prevValues, bit, value], commitAction)
    end

    def setPriority(positions, value, commitAction: true)
      prevValues = []
      for pos in positions
        prevValues.push(applyChangeAndCollect(@tileset.priorities, pos, value))
      end
      recordAction([:Priority, positions, prevValues, value], commitAction)
    end

    #####################
    ### End undo handling
    #####################

    def withAlpha(color, opacity)
      return Color.new(color.red, color.green, color.blue, opacity)
    end

    def drawPassageFlags(pass, pri, baseX, baseY, extras = @passageExtrasOverlay, canvas = "passages", opacity = 192)
      blockColor = withAlpha(COLLISION_COLOR, opacity)
      for bit, x, y in [[0b1000,  0,  1],
                        [0b0100, -1,  0],
                        [0b0001,  0, -1],
                        [0b0010,  1,  0]]
        if (pass & bit) != 0
          # Calculate positions for drawing
          drawX = x < 0 ? TILE_SIZE - COLLISION_THICKNESS : 0
          drawY = y < 0 ? TILE_SIZE - COLLISION_THICKNESS : 0
          width = x == 0 ? TILE_SIZE : COLLISION_THICKNESS
          height = y == 0 ? TILE_SIZE : COLLISION_THICKNESS
          @sprites[canvas].bitmap.fill_rect(baseX + drawX, baseY + drawY, width, height, blockColor)
        end
      end

      if extras
        if pri > 0
          priorityColor = withAlpha(PRIORITY_COLORS[pri - 1], opacity)
          @sprites[canvas].bitmap.fill_rect(baseX, baseY + (TILE_SIZE - (pri * 6)), 6, 6, priorityColor)
        end

        if pass & 0x40 != 0 # Bush
          bushColor = withAlpha(BUSH_COLOR, opacity)
          @sprites[canvas].bitmap.fill_rect(baseX + 10, baseY + 6, 4, 20, bushColor)
          @sprites[canvas].bitmap.fill_rect(baseX + 18, baseY + 6, 4, 20, bushColor)
          @sprites[canvas].bitmap.fill_rect(baseX + 6, baseY + 10, 20, 4, bushColor)
          @sprites[canvas].bitmap.fill_rect(baseX + 6, baseY + 18, 20, 4, bushColor)
        end

        if pass & 0x80 != 0 # Counter
          counterColor = withAlpha(COUNTER_COLOR, opacity)
          @sprites[canvas].bitmap.fill_rect(baseX + 14, baseY + 4, 4, 24, counterColor)
        end
      end
    end

    def pbDrawSelection
      edgemap = Table.new(ROW_SIZE, display_height + 2, 9)

      # Don't draw existing selection box if user is dragging and not holding a modifier
      if !@targetPos || !@selectingPos || Input.press?(Input::SHIFT) || Input.press?(Input::CTRL)
        for selection in @selected
          rowIdx = row(selection)
          # Include offscreen for selection bound purposes
          if rowIdx >= @scroll - 1 && rowIdx <= @scroll + display_height + 1
            shiftedRow = rowIdx - (@scroll - 1)
            columnIdx = column(selection)
            for i in 0...9
              edgemap[columnIdx, shiftedRow, i] = 1
            end
          end
        end

        # Calculate contours of selection
        for selection in @selected
          rowIdx = row(selection)
          if rowIdx >= @scroll && rowIdx <= @scroll + display_height
            shiftedRow = rowIdx - (@scroll - 1)
            columnIdx = column(selection)
            for xOffset in -1..1
              for yOffset in -1..1
                next if xOffset == 0 && yOffset == 0
                edgeidx = (xOffset + 1) * 3 + (yOffset + 1)

                next if xOffset < 0 && columnIdx == 0
                next if xOffset > 0 && columnIdx == ROW_SIZE - 1

                edgemap[columnIdx, shiftedRow, edgeidx] = 0 if edgemap[columnIdx + xOffset, shiftedRow + yOffset, 4] == 1 # "presence" flag
              end
            end
          end
        end
      end

      # Draw selection box
      if @targetPos && @selectingPos
        minX = [@targetPos[0], @selectingPos[0]].min
        minY = [@targetPos[1], @selectingPos[1]].min - (@scroll - 1)
        maxX = [@targetPos[0], @selectingPos[0]].max
        maxY = [@targetPos[1], @selectingPos[1]].max - (@scroll - 1)

        for x in minX..maxX
          edgemap[x, maxY, 5] = 1 if maxY > 0 && maxY <= display_height
          edgemap[x, minY, 3] = 1 if minY > 0 && maxY <= display_height
        end

        for y in minY..maxY
          if y > 0 && y <= display_height
            edgemap[minX, y, 1] = 1
            edgemap[maxX, y, 7] = 1
          end
        end
      end

      # Draw selection box contours
      for x in 0...ROW_SIZE
        for y in 0...display_height
          xx = x * TILE_SIZE
          yy = y * TILE_SIZE

          cursorOffset = TILE_SIZE - CURSOR_THICKNESS

          for xOffset in -1..1
            for yOffset in -1..1
              next if xOffset == 0 && yOffset == 0
              edgeidx = (xOffset + 1) * 3 + (yOffset + 1)
              next unless edgemap[x, y + 1, edgeidx] == 1
              xShift = [0, 0, cursorOffset][xOffset + 1]
              yShift = [0, 0, cursorOffset][yOffset + 1]
              width = xOffset == 0 ? TILE_SIZE : CURSOR_THICKNESS
              height = yOffset == 0 ? TILE_SIZE : CURSOR_THICKNESS
              @sprites["overlay"].bitmap.fill_rect(xx + xShift, yy + yShift, width, height, SELECTION_COLOR)
            end
          end
        end
      end
    end

    def pbUpdateTileset
      @sprites["overlay"].bitmap.clear
      @sprites["passages"].bitmap.clear
      @sprites["terraintags"].bitmap.clear
      @sprites["background"].bitmap.clear
      @sprites["tileset"].bitmap.clear
      # Copy entire tileset section
      @tilehelper.bltSection(@sprites["tileset"].bitmap, 0, 0, Rect.new(0, (@scroll - 1) * TILE_SIZE, 256, Graphics.height - 64))

      halftile = TILE_SIZE / 2

      textpos = []

      # Draw background and autotiles
      for y in 0...display_height
        rowIdx = y + @scroll
        next if rowIdx >= tileset_height

        for x in 0...ROW_SIZE
          position = tileset_position(rowIdx, x)
          xx = x * TILE_SIZE
          yy = y * TILE_SIZE
          if position < RESERVED_AUTOTILES
            @tilehelper.bltTile(@sprites["tileset"].bitmap, xx, yy, position)
          end
          @sprites["background"].bitmap.fill_rect(xx,            yy,            halftile, halftile, CHECKERBOARD_DARK)
          @sprites["background"].bitmap.fill_rect(xx + halftile, yy,            halftile, halftile, CHECKERBOARD_LIGHT)
          @sprites["background"].bitmap.fill_rect(xx,            yy + halftile, halftile, halftile, CHECKERBOARD_LIGHT)
          @sprites["background"].bitmap.fill_rect(xx + halftile, yy + halftile, halftile, halftile, CHECKERBOARD_DARK)

          tag = @tileset.terrain_tags[position]
          pass = @tileset.passages[position]
          pri = @tileset.priorities[position]
          if @passageOverlay
            drawPassageFlags(pass, pri, xx, yy)
          end
          if @terrainTagOverlay && tag != 0
            textpos.push(["#{tag}", xx + halftile, yy, :center, Color.new(80, 80, 80), Color.new(192, 192, 192)])
          end
        end
      end

      pbDrawSelection

      pbDrawTextPositions(@sprites["terraintags"].bitmap, textpos)

      if @mousePosition && @mousePosition[1] < tileset_height
        pbUpdateBlurb([tileset_position(@mousePosition[1], @mousePosition[0])])
      else
        pbUpdateBlurb(@selected)
      end
    end

    def pbUpdateMousePosition(target)
      if @mousePosition != target
        @sprites["mouselayer"].bitmap.clear
        if target && target[1] < tileset_height
          x, y = target
          xx = x * TILE_SIZE
          yy = (y - @scroll) * TILE_SIZE
          @sprites["mouselayer"].bitmap.fill_rect(xx, yy, TILE_SIZE, TILE_SIZE, HOVER_COLOR)
          pbUpdateBlurb([tileset_position(y, x)])
        else
          pbUpdateBlurb(@selected)
        end
      end

      @mousePosition = target
    end

    def pbUpdateBlurb(positions)
      @sprites["passageinfo"].bitmap.clear
      if positions.size != 1
        @sprites["tilesetinfo"].text = _INTL("{1} tiles selected", positions.size)
      else
        tag = @tileset.terrain_tags[positions[0]]
        pass = @tileset.passages[positions[0]]
        pri = @tileset.priorities[positions[0]]
        if positions[0] < RESERVED_AUTOTILES
          autotile = positions[0] - (positions[0] % AUTOTILE_SIZE)
          desc = _INTL("AT {1}-{2}\n{3}", autotile, autotile + AUTOTILE_SIZE, terrain_tag_name(tag))
        else
          desc = _INTL("Tile {1}\n{2}", positions[0], terrain_tag_name(tag))
        end
        @sprites["passageinfo"].bitmap.fill_rect(148, 16, TILE_SIZE, TILE_SIZE, CHECKERBOARD_DARK) if !isDarkWindowskin(@sprites["title"].windowskin)
        drawPassageFlags(pass, pri, 148, 16, true, "passageinfo", 255)
        @sprites["tilesetinfo"].text = desc
      end
    end

    def pbChooseTileset
      commands = []
      for i in 1...@tilesetwrapper.data.length
        commands.push(sprintf("%03d %s", i, @tilesetwrapper.data[i].name))
      end

      ret = Kernel.pbShowCommands(nil, commands, -1, @tileset.id - 1)
      if ret >= 0
        if @actionStackPosition == 0 || Kernel.pbConfirmMessageSerious(_INTL("You have unsaved changes. Switch anyway?"))
          @tileset = @tilesetwrapper.data[ret + 1]
          @tilehelper.dispose
          @tilehelper = TileDrawingHelper.fromTileset(@tileset)
          @selected = [0]
          @scroll = 0
          @actionStackPosition = 0
          @actionStack = []
          pbUpdateTileset
        end
      end
    end

    def pbStartScene
      @actionStack = []
      @actionStackPosition = 0

      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @viewport_overlay = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport_overlay.z = 99999
      @tilesetwrapper = pbTilesetWrapper
      @tileset = @tilesetwrapper.data[$game_map.tileset_id]
      @tilehelper = TileDrawingHelper.fromTileset(@tileset)
      @sprites = {}
      @sprites["background"] = BitmapSprite.new(ROW_SIZE * TILE_SIZE, Graphics.height - 64, @viewport)
      @sprites["background"].x = 0
      @sprites["background"].y = 64
      @sprites["background"].visible = true

      @sprites["tilesetinfo"] = Window_UnformattedTextPokemon.newWithSize("", Graphics.width - 196, Graphics.height - 96, 196, 96, @viewport)

      @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(_INTL("Terrain Tags (Q/W: SCROLL; Z: MENU)"), 0, 0, Graphics.width, 64, @viewport)

      @sprites["passageinfo"] = BitmapSprite.new(196, 96, @viewport_overlay)
      @sprites["passageinfo"].x = Graphics.width - 196
      @sprites["passageinfo"].y = Graphics.height - 96

      @sprites["tileset"] = BitmapSprite.new(ROW_SIZE * TILE_SIZE, Graphics.height - 64, @viewport)
      @sprites["tileset"].x = 0
      @sprites["tileset"].y = 64

      @sprites["passages"] = BitmapSprite.new(256, Graphics.height - 64, @viewport_overlay)
      @sprites["passages"].x = 0
      @sprites["passages"].y = 64

      @sprites["terraintags"] = BitmapSprite.new(256, Graphics.height - 64, @viewport_overlay)
      @sprites["terraintags"].x = 0
      @sprites["terraintags"].y = 64
      pbSetSystemFont(@sprites["terraintags"].bitmap)

      @sprites["overlay"] = BitmapSprite.new(256, Graphics.height - 64, @viewport_overlay)
      @sprites["overlay"].x = 0
      @sprites["overlay"].y = 64

      @sprites["mouselayer"] = BitmapSprite.new(256, Graphics.height - 64, @viewport_overlay)
      @sprites["mouselayer"].x = 0
      @sprites["mouselayer"].y = 64

      @sprites["title"].visible = true
      @sprites["tilesetinfo"].visible = true
      @sprites["passageinfo"].visible = true
      @sprites["terraintags"].visible = true
      @sprites["passages"].visible = true
      @sprites["overlay"].visible = true
      @sprites["mouselayer"].visible = true

      set_selected(0) if !defined?(@selected)

      @passageOverlay = true
      @passageExtrasOverlay = false
      @terrainTagOverlay = false

      pbUpdateTileset
      pbFadeInAndShow(@sprites)

      modifierPressed = false
      ########
      loop do
        pbUpdateSpriteHash(@sprites)
        Graphics.update
        Input.update

        if Input.modifierKeyPressed?
          if Input.triggerex?(:Z) # Use triggerex because this is "undo/redo"
            if Input.press?(Input::SHIFT)
              redoAction
              next
            else
              undoAction
              next
            end
          end
        end

        mouseTilesetUpdate = false

        mousePos = Mouse::getMousePos
        mousePos[0] -= $ResizeOffsetX if mousePos && defined?($ResizeOffsetX)
        mousePos[1] -= $ResizeOffsetX if mousePos && defined?($ResizeOffsetY)
        if (mousePos &&
            mousePos[0] >= 0 && mousePos[0] < TILE_SIZE * ROW_SIZE &&
            mousePos[1] >= 64 && mousePos[1] < 64 + TILE_SIZE * display_height)
          target = [mousePos[0] / TILE_SIZE, (mousePos[1] - 64) / TILE_SIZE + @scroll]
          pbUpdateMousePosition(target)
        else
          pbUpdateMousePosition(nil)
        end

        if Input.triggerex?(Input::LeftMouseKey)
          @selectingPos = @mousePosition
          @targetPos = @selectingPos
          mouseTilesetUpdate = true
        elsif Input.releaseex?(Input::LeftMouseKey) && @selectingPos
          if @mousePosition
            finalPos = @mousePosition

            minX = [finalPos[0], @selectingPos[0]].min
            minY = [finalPos[1], @selectingPos[1]].min
            maxX = [finalPos[0], @selectingPos[0]].max
            maxY = [finalPos[1], @selectingPos[1]].max

            selection = []

            for x in minX..maxX
              for y in minY..maxY
                selection.push(tileset_position(y, x))
              end
            end

            if Input.press?(Input::CTRL)
              @selected = @selected + selection - (@selected & selection)
            elsif Input.press?(Input::SHIFT)
              @selected += selection
            else
              @selected = selection
            end
            @selected.uniq!
          end
          @selectingPos = nil
          @targetPos = nil
          mouseTilesetUpdate = true
        elsif Input.pressex?(Input::LeftMouseKey) && @selectingPos # Still holding it down
          mouseTilesetUpdate |= Input.press?(Input::CTRL) || Input.trigger?(Input::SHIFT) ||
                                Input.release?(Input::CTRL) || Input.release?(Input::SHIFT) ||
                                @mousePosition != @targetPos
          @targetPos = @mousePosition
        end

        if Input.scroll_v > 0
          @scroll = [0, @scroll - 1].max
          mouseTilesetUpdate = true
        elsif Input.scroll_v < 0
          @scroll = [@scroll + 1, tileset_height - 5].min
          mouseTilesetUpdate = true
        end

        pbUpdateTileset if mouseTilesetUpdate

        if Input.trigger?(Input::X)
          @passageOverlay = !@passageOverlay
          pbUpdateTileset
        elsif Input.trigger?(Input::Y)
          @terrainTagOverlay = !@terrainTagOverlay
          pbUpdateTileset
        end

        if Input.repeat?(Input::UP)
          move_cursor(:Up, Input.trigger?(Input::UP))
        elsif Input.repeat?(Input::DOWN)
          move_cursor(:Down, Input.trigger?(Input::DOWN))
        elsif Input.repeat?(Input::LEFT)
          move_cursor(:Left, Input.trigger?(Input::LEFT))
        elsif Input.repeat?(Input::RIGHT)
          move_cursor(:Right, Input.trigger?(Input::RIGHT))
        elsif Input.repeat?(Input::L)
          move_cursor(:PageUp, Input.trigger?(Input::L))
        elsif Input.repeat?(Input::R)
          move_cursor(:PageDown, Input.trigger?(Input::R))
        elsif Input.trigger?(Input::A)
          commands = []
          cmdCollision = -1
          cmdExtras = -1
          cmdTerrainTag = -1
          cmdTop = -1
          cmdJump = -1
          cmdBottom = -1
          cmdTileset = -1
          cmdHelp = -1

          commands[cmdCollision = commands.length] = @passageOverlay ? _INTL("Hide collision") : _INTL("Show collision")
          if @passageOverlay
            commands[cmdExtras = commands.length] = @passageExtrasOverlay ? _INTL("Hide extra details") : _INTL("Show extra details")
          end
          commands[cmdTerrainTag = commands.length] = @terrainTagOverlay ? _INTL("Hide tags") : _INTL("Show tags")
          commands[cmdTop = commands.length] = _INTL("Go to top")
          commands[cmdJump = commands.length] = _INTL("Jump to tile")
          commands[cmdBottom = commands.length] = _INTL("Go to bottom")
          commands[cmdTileset = commands.length] = _INTL("Change tileset")
          commands[cmdHelp = commands.length] = _INTL("Help")

          ret = Kernel.pbShowCommands(nil, commands, -1)
          if cmdCollision != -1 && ret == cmdCollision
            @passageOverlay = !@passageOverlay
            pbUpdateTileset
          elsif cmdExtras != -1 && ret == cmdExtras
            @passageExtrasOverlay = !@passageExtrasOverlay
            pbUpdateTileset
          elsif cmdTerrainTag != -1 && ret == cmdTerrainTag
            @terrainTagOverlay = !@terrainTagOverlay
            pbUpdateTileset
          elsif cmdTop != -1 && ret == cmdTop
            set_selected(0, current_column_min)
            pbUpdateTileset
          elsif cmdJump != -1 && ret == cmdJump
            params = ChooseNumberParams.new
            params.setRange(0, tileset_size)
            params.setDefaultValue(@selected[0])
            params.setCancelValue(-1)
            target = Kernel.pbMessageChooseNumber(_INTL("Jump to which tile?"), params)
            if target != -1
              set_selected(target)
              pbUpdateTileset
            end
          elsif cmdBottom != -1 && ret == cmdBottom
            set_selected(tileset_height - 1, current_column_max)
            pbUpdateTileset
          elsif cmdTileset != -1 && ret == cmdTileset
            pbChooseTileset
          elsif cmdHelp != -1 && ret == cmdHelp
            msgs = [_INTL("\\l[9]\\c[1]Tileset Editor\\c[0]"),
                    _INTL("The Extra Details overlay represents three things."),
                    _INTL("A Bush (\\c[8]\#\\c[0]) tile will render over most events on the same tile."),
                    _INTL("An event can be interacted with if it's on the other side of a Counter (<c3=32c8c8,065d5d>|\\c[0]) tile."),
                    _INTL("Priority (\\c[1].\\c[0]) is used for event and tile layering. Higher dot, higher priority.")]
            msgwindow = Kernel.pbCreateMessageWindow
            Kernel.pbMessageDisplay(msgwindow, msgs.join("\n"), false) # No letterbyletter
            loop do
              Graphics.update
              Input.update
              break if Input.trigger?(Input::C) || Input.press?(Input::B)
            end
            Kernel.pbDisposeMessageWindow(msgwindow)
            Input.update
          end
        elsif Input.trigger?(Input::B)
          if @actionStackPosition > 0
            if Kernel.pbConfirmMessage(_INTL("Save changes?"))
              @tilesetwrapper.save
              $cache.cacheTilesets
              if $game_map && $MapFactory
                $MapFactory.setup($game_map.map_id)
                $game_player.center($game_player.x, $game_player.y)
                if $scene.is_a?(Scene_Map)
                  $scene.disposeSpritesets
                  $scene.createSpritesets
                end
              end
              Kernel.pbMessage(_INTL("To ensure that the changes remain, close and reopen RPG Maker XP."))
            end
          end
          break if Kernel.pbConfirmMessage(_INTL("Exit editor?"))
        elsif Input.trigger?(Input::C)
          option = 0
          while option >= 0
            option = Kernel.pbShowCommands(nil,
              [_INTL("Terrain Tag"), _INTL("Collision"), _INTL("Priority")], -1, option)
            case option
              when 0 # Terrain Tag
                maxValue = 0
                for c in PBTerrain.constants
                  v = PBTerrain.const_get(c.to_sym)
                  maxValue = v if v.is_a?(Numeric) && v > maxValue
                end

                values = @selected.map { |it| @tileset.terrain_tags[it] }.uniq
                defaultCommand = values.size == 1 ? values.first : 0

                args = [nil, Array.new(maxValue + 1) { |i| terrain_tag_name(i).to_s }, -1, defaultCommand]
                newvalue = Kernel.pbShowCommands(*args)
                if newvalue != -1
                  setTerrainTag(@selected, newvalue)
                end
              when 1 # Passability
                baseCommands = [_INTL("Up"), _INTL("Down"), _INTL("Left"), _INTL("Right"), _INTL("All collision"), _INTL("Bush"), _INTL("Countertop")]
                passBits = [0b1000, 0b0001, 0b0010, 0b0100, 0b1111, 0x40, 0x80]
                suboption = 0
                while suboption != -1
                  commands = baseCommands.each_with_index.map { |command, idx|
                    anyFound = false
                    anyNotMatching = false
                    for pos in @selected
                      if (@tileset.passages[pos] & passBits[idx]) == passBits[idx]
                        anyFound = true
                        break if anyNotMatching
                      else
                        anyNotMatching = true
                        break if anyFound
                      end
                    end

                    if !anyFound
                      mark = '    '
                    elsif !anyNotMatching
                      mark = '> '
                    else
                      mark = '* '
                    end

                    next mark + command
                  }

                  suboption = Kernel.pbShowCommands(nil, commands, -1, suboption)
                  if suboption != -1
                    flipPassageBit(@selected, passBits[suboption])
                  end
                  pbUpdateTileset
                end
              when 2 # Priority
                params = ChooseNumberParams.new
                params.setRange(0, 5)
                values = @selected.map { |it| @tileset.priorities[it] }.uniq
                if values.size == 1
                  params.setDefaultValue(values.first)
                end
                params.setCancelValue(-1)
                priority = Kernel.pbMessageChooseNumber(_INTL("Set tile priority."), params)
                if priority != -1
                  setPriority(@selected, priority)
                end
            end
            pbUpdateTileset
          end
        end
      end
      ########
      pbFadeOutAndHide(@sprites)
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
      @tilehelper.dispose
    end
  end

  def pbTilesetScreen
    pbFadeOutIn(99999) {
      scene = PokemonTilesetScene.new
      scene.pbStartScene
    }
  end
rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}" == "Reset"
    raise $!
  else
  end
end

################################################################################
# "Voltorb Flip" mini-game
# By KitsuneKouta
# Accessibility by wiresegal
#-------------------------------------------------------------------------------
# Run with:      pbVoltorbFlip
################################################################################
class VoltorbFlip
  LineTotal = Struct.new('LineTotal', :totalPoints, :totalVoltorbs)
  LineData = Struct.new('LineData', :remainingPoints, :remainingVoltorbs, :unsolvedTiles, :unimportantTiles)

  ### SOLVER

  def boardAnalysis
    squareData = []

    rows = Array.new(5) { |row|
      Enumerator.new do |y|
        for col in 0...5
          y << squareData[5 * row + col]
        end
      end
    }

    cols = Array.new(5) { |col|
      Enumerator.new do |y|
        for row in 0...5
          y << squareData[5 * row + col]
        end
      end
    }

    for row in 0...5
      for col in 0...5
        idx = row * 5 + col
        xpos, ypos, square, flipped = @squares[idx]

        if flipped
          squareData[idx] = [false, false, false, false]
          squareData[idx][square] = true
        else
          squareData[idx] = [true, true, true, true]
        end
      end
    end

    loop do
      rowDatas = Array.new(5) { |i| LineData.new(@rowTotals[i].totalPoints, @rowTotals[i].totalVoltorbs, 0, 0) }
      colDatas = Array.new(5) { |i| LineData.new(@columnTotals[i].totalPoints, @columnTotals[i].totalVoltorbs, 0, 0) }

      for row in 0...5
        for col in 0...5
          idx = row * 5 + col
          sqdata = squareData[idx]

          rowData = rowDatas[row]
          colData = colDatas[col]
          if sqdata.one? # Solved
            square = sqdata.index(true)
            voltorb = square == 0

            rowData.remainingPoints -= square
            rowData.remainingVoltorbs -= 1 if voltorb

            colData.remainingPoints -= square
            colData.remainingVoltorbs -= 1 if voltorb
          else
            rowData.unsolvedTiles += 1
            rowData.unimportantTiles += 1 if sqdata == [true, true, false, false]
            colData.unsolvedTiles += 1
            colData.unimportantTiles += 1 if sqdata == [true, true, false, false]
          end
        end
      end

      anyUpdate = false

      for rowIdx in 0...5
        row = rows[rowIdx]
        rowData = rowDatas[rowIdx]
        next if rowData.unsolvedTiles == 0 # no unsolved tiles left

        anyUpdate = runHeuristics(rowData, row)
        break if anyUpdate
      end

      next if anyUpdate

      for colIdx in 0...5
        col = cols[colIdx]
        colData = colDatas[colIdx]
        next if colData.unsolvedTiles == 0 # no unsolved tiles left

        anyUpdate = runHeuristics(colData, col)
        break if anyUpdate
      end

      @lastrowDatas = rowDatas
      @lastcolDatas = colDatas
      return squareData unless anyUpdate
    end
  end

  def runHeuristics(lineData, line)
    return runHeuristic0(lineData, line) ||
           runHeuristic1(lineData, line) ||
           runHeuristic2(lineData, line) ||
           runHeuristic3(lineData, line) ||
           runHeuristic4(lineData, line) ||
           runHeuristic5(lineData, line) ||
           runHeuristic6(lineData, line) ||
           runHeuristic7(lineData, line) ||
           runHeuristic8(lineData, line) ||
           runHeuristic9(lineData, line)
  end

  # Heuristic #0 - If RemainingVoltorbs + RemainingPoints == NumUnsolvedTiles, eliminate all possibilities except V and 1 from unsolved tiles
  def runHeuristic0(lineData, line)
    return false if lineData.remainingVoltorbs + lineData.remainingPoints != lineData.unsolvedTiles

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true if tile[2] || tile[3]
        tile[2] = false
        tile[3] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #1 - If NumUnsolvedTiles - RemainingVoltorbs == RemainingPoints - 1, remove 3 as a possible option
  def runHeuristic1(lineData, line)
    return false if lineData.unsolvedTiles - lineData.remainingVoltorbs != lineData.remainingPoints - 1

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true if tile[3]
        tile[3] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #2 - If RemainingVoltorbs == 0, eliminate any possible voltorbs
  def runHeuristic2(lineData, line)
    return false if lineData.remainingVoltorbs != 0

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true if tile[0]
        tile[0] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #3 - If NumUnsolvedTiles - 1 == RemainingVoltorbs, mark all tiles as either voltorbs or tiles with a value of RemainingPoints
  def runHeuristic3(lineData, line)
    return false if lineData.unsolvedTiles - 1 != lineData.remainingVoltorbs

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        for value in 1..3
          next if lineData.remainingPoints == value
          anyUpdate = true if tile[value]
          tile[value] = false
        end
      end
    end
    return anyUpdate
  end

  # Heuristic #4 - If (NumUnsolvedTiles - RemainingVoltorbs) <= ((RemainingPoints + 1)/3), eliminate 1 as a possibility from all tiles
  def runHeuristic4(lineData, line)
    return false if (lineData.unsolvedTiles - lineData.remainingVoltorbs) > ((lineData.remainingPoints + 1) / 3)

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true if tile[1]
        tile[1] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #5 - If RemainingVoltorbs == 0 and RemainingPoints = NumUnsolvedTiles, mark all unsolved tiles as definitely 1s
  def runHeuristic5(lineData, line)
    return false if !((lineData.remainingVoltorbs == 0) && (lineData.remainingPoints == lineData.unsolvedTiles))

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true
        tile[0] = false
        tile[1] = true
        tile[2] = false
        tile[3] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #6 - If RemainingVoltorbs == NumUnsolvedTiles, mark all unsolved tiles as definitely voltorbs
  def runHeuristic6(lineData, line)
    return false if lineData.remainingVoltorbs != lineData.unsolvedTiles

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true
        tile[0] = true
        tile[1] = false
        tile[2] = false
        tile[3] = false
      end
    end
    return anyUpdate
  end

  # Heuristic #7 - If NumUnsolvedTiles == 1, fill in the single unsolved tile using RemainingPoints
  def runHeuristic7(lineData, line)
    return false if lineData.unsolvedTiles != 1 || lineData.remainingPoints > 3 # points > 3 is not possible, so to avoid a panic

    for tile in line
      unless tile.one? # Solved
        for value in 0..3
          tile[value] = (value == lineData.remainingPoints)
        end
        return true
      end
    end
    return false
  end

  # Heuristic #8 - If RemainingPoints == NumUnsolvedTiles*3, mark all unknowns as definitely 3s
  def runHeuristic8(lineData, line)
    return false if lineData.remainingPoints != lineData.unsolvedTiles * 3

    anyUpdate = false
    for tile in line
      unless tile.one? # Solved
        anyUpdate = true
        tile[0] = false
        tile[1] = false
        tile[2] = false
        tile[3] = true
      end
    end

    return anyUpdate
  end

  # Heuristic #9 - If (NumUnsolvedTiles - NumUnimportantTiles) <= ((RemainingPoints + 1)/3), eliminate voltorb as a possibility from all important tiles
  def runHeuristic9(lineData, line)
    return false if (lineData.unsolvedTiles - lineData.unimportantTiles) > ((lineData.remainingPoints - lineData.unimportantTiles + lineData.remainingVoltorbs + 1) / 3)

    anyUpdate = false
    for tile in line
      unless tile.one? || tile == [true, true, false, false] # Solved
        anyUpdate = true if tile[0]
        tile[0] = false
      end
    end
    return anyUpdate
  end

  ### END SOLVER

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStart
    # Set initial level
    @level = 1
    # Maximum and minimum total point values for each level
    @levelRanges = [
      [20, 50], [50, 100], [100, 200], [200, 350],
      [350, 600], [600, 1000], [1000, 2000], [2000, 3500]
    ]
    @firstRound = true
    pbNewGame
  end

  def pbNewGame
    # Initialize variables
    @sprites = {}
    @cursor = []
    @marks = []
    @coins = []
    @rowTotals = []
    @columnTotals = []
    @points = 0
    @index = [0, 0]
    # [x,y,points,selected]
    @squares = [0, 0, 0, false]
    @directory = "Graphics/Pictures/Voltorb Flip/"
    squareValues = []
    total = 1
    voltorbs = 0
    for i in 0...25
      # Sets the value to 1 by default
      squareValues[i] = 1
      # Sets the value to 0 (a voltorb) if # for that level hasn't been reached
      if voltorbs < 5 + (@level / 2).ceil
        squareValues[i] = 0
        voltorbs += 1
      # Sets the value randomly to a 2 or 3 if the total is less than the max
      elsif total < @levelRanges[@level - 1][1]
        squareValues[i] = rand(2) + 2
        total *= squareValues[i]
      end
      if total > (@levelRanges[@level - 1][1])
        # Lowers value of square to 1 if over max
        total /= squareValues[i]
        squareValues[i] = 1
      end
    end
    # Randomize the values a little
    for i in 0...25
      temp = squareValues[i]
      if squareValues[i] > 1
        if rand(10) > 8
          total /= squareValues[i]
          squareValues[i] -= 1
          total *= squareValues[i]
        end
      end
      if total < @levelRanges[@level - 1][0]
        if squareValues[i] > 0
          total /= squareValues[i]
          squareValues[i] = temp
          total *= squareValues[i]
        end
      end
    end
    # Populate @squares array
    for i in 0...25
      if i % 5 == 0
        x = i
      end
      r = rand(squareValues.length)
      @squares[i] = [(i - x).abs * 64 + 128, (i / 5).abs * 64, squareValues[r], false]
      squareValues.delete_at(r)
    end
    pbCreateSprites
    # Display numbers (all zeroes, as no values have been calculated yet)
    for i in 0...5
      pbUpdateRowNumbers(0, 0, i)
      pbUpdateColumnNumbers(0, 0, i)
    end
    pbDrawShadowText(@sprites["text"].bitmap, 8, 16, 118, 26, _INTL("Your coins"), Color.new(60, 60, 60), Color.new(150, 190, 170), 1)
    pbDrawShadowText(@sprites["text"].bitmap, 8, 82, 118, 26, _INTL("Earned coins"), Color.new(60, 60, 60), Color.new(150, 190, 170), 1)
    # Draw current level
    pbDrawShadowText(@sprites["level"].bitmap, 8, 150, 118, 28, _INTL("Level {1}", @level.to_s), Color.new(60, 60, 60), Color.new(150, 190, 170), 1)
    # Displays total and current coins
    pbUpdateCoins
    # Draw curtain effect
    if @firstRound
      loop do
        @sprites["curtainL"].angle -= 5
        @sprites["curtainR"].angle += 5
        pbWait(1)
        if @sprites["curtainL"].angle <= -180
          break
        end
      end
    end
    @sprites["curtainL"].visible = false
    @sprites["curtainR"].visible = false
    @sprites["curtain"].opacity = 100
    if $PokemonGlobal.coins >= MAXCOINS
      Kernel.pbMessage(_INTL("Your Coin Case has been filled."))
      $PokemonGlobal.coins = MAXCOINS # As a precaution
      @quit = true
    #    elsif !Kernel.pbConfirmMessage(_INTL("Play Voltorb Flip Lv. {1}?",@level)) && $PokemonGlobal.coins<99999
    #      @quit=true
    else
      @sprites["curtain"].opacity = 0
      # Erase 0s to prepare to replace with values
      @sprites["numbers"].bitmap.clear
      # Reset arrays to empty
      @rowTotals = Array.new(5) { LineTotal.new(0, 0) }
      @columnTotals = Array.new(5) { LineTotal.new(0, 0) }
      # Draw numbers for each row and column
      for rowIdx in 0...5
        row = @rowTotals[rowIdx]
        for colIdx in 0...5
          column = @columnTotals[colIdx]
          squareValue = @squares[(rowIdx * 5) + colIdx][2]
          row.totalPoints += squareValue
          column.totalPoints += squareValue
          if squareValue == 0
            row.totalVoltorbs += 1
            column.totalVoltorbs += 1
          end

          if rowIdx == 4
            pbUpdateColumnNumbers(column.totalPoints, column.totalVoltorbs, colIdx)
          end
        end
        pbUpdateRowNumbers(row.totalPoints, row.totalVoltorbs, rowIdx)
      end
    end
    tts(_INTL("New Game of Voltorb Flip! Press A for hints."))
    ttsTile(doRow: true, doColumn: true)
  end

  def ttsTile(doRow: false, doColumn: false)
    x, y = @index
    idx = x * 5 + y
    if @squares[idx][3]
      tts(_INTL("Tile {1}, {2} - Value {3}", x + 1, y + 1, @squares[idx][2]))
    else
      tts(_INTL("Tile {1}, {2}", x + 1, y + 1))
    end
    tts(_INTL("Row has {1} points and {2} Voltorbs", @rowTotals[y].totalPoints, @rowTotals[y].totalVoltorbs)) if doRow
    tts(_INTL("Column has {1} points and {2} Voltorbs", @columnTotals[x].totalPoints, @columnTotals[x].totalVoltorbs)) if doColumn
  end

  def pbCreateSprites
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = RPG::Cache.load_bitmap(@directory + "boardbg")
    @sprites["text"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["text"].bitmap)
    @sprites["level"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["level"].bitmap)
    @sprites["curtain"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["curtain"].z = 99999
    @sprites["curtain"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
    @sprites["curtain"].opacity = 0
    @sprites["curtainL"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["curtainL"].z = 99999
    @sprites["curtainL"].x = 256
    @sprites["curtainL"].angle = -90
    @sprites["curtainL"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
    @sprites["curtainR"] = BitmapSprite.new(Graphics.width, Graphics.height * 2, @viewport)
    @sprites["curtainR"].z = 99999
    @sprites["curtainR"].x = 256
    @sprites["curtainR"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height * 2, Color.new(0, 0, 0))
    @sprites["cursor"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["cursor"].z = 99998
    @sprites["icon"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["icon"].z = 99997
    @sprites["mark"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["memo"] = Sprite.new(@viewport)
    @sprites["memo"].bitmap = RPG::Cache.load_bitmap(@directory + "memo")
    @sprites["memo"].x = 10
    @sprites["memo"].y = 244
    @sprites["memo"].visible = false
    @sprites["numbers"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["totalCoins"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["currentCoins"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["animation"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["animation"].z = 99999
    for i in 0...6
      @sprites[i] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites[i].z = 99996
      @sprites[i].visible = false
    end
    # Creates images ahead of time for the display-all animation (reduces lag)
    icons = []
    points = 0
    for i in 0...3
      for j in 0...25
        points = @squares[j][2] if i == 2
        icons[j] = [@directory + "tiles", @squares[j][0], @squares[j][1], 320 + (i * 64) + (points * 64), 0, 64, 64]
      end
      icons.compact!
      pbDrawImagePositions(@sprites[i].bitmap, icons)
    end
    icons = []
    for i in 0...25
      icons[i] = [@directory + "tiles", @squares[i][0], @squares[i][1], @squares[i][2] * 64, 0, 64, 64]
    end
    pbDrawImagePositions(@sprites[5].bitmap, icons)
    # Default cursor image
    @cursor[0] = [@directory + "cursor", 0 + 128, 0, 0, 0, 64, 64]
  end

  def getInput
    if Input.trigger?(Input::UP)
      pbSEPlay("Choose")
      if @index[1] > 0
        @index[1] -= 1
        @sprites["cursor"].y -= 64
      else
        @index[1] = 4
        @sprites["cursor"].y = 256
      end
      ttsTile(doRow: true)
    elsif Input.trigger?(Input::DOWN)
      pbSEPlay("Choose")
      if @index[1] < 4
        @index[1] += 1
        @sprites["cursor"].y += 64
      else
        @index[1] = 0
        @sprites["cursor"].y = 0
      end
      ttsTile(doRow: true)
    elsif Input.trigger?(Input::LEFT)
      pbSEPlay("Choose")
      if @index[0] > 0
        @index[0] -= 1
        @sprites["cursor"].x -= 64
      else
        @index[0] = 4
        @sprites["cursor"].x = 256
      end
      ttsTile(doColumn: true)
    elsif Input.trigger?(Input::RIGHT)
      pbSEPlay("Choose")
      if @index[0] < 4
        @index[0] += 1
        @sprites["cursor"].x += 64
      else
        @index[0] = 0
        @sprites["cursor"].x = 0
      end
      ttsTile(doColumn: true)
    elsif Input.trigger?(Input::C)
      if @cursor[0][3] == 64 # If in mark mode
        for i in 0...@squares.length
          if @index[0] * 64 + 128 == @squares[i][0] && @index[1] * 64 == @squares[i][1] && @squares[i][3] == false
            pbSEPlay("Voltorb Flip Mark")
          end
        end
        for i in 0...@marks.length + 1
          if @marks[i] == nil
            @marks[i] = [@directory + "tiles", @index[0] * 64 + 128, @index[1] * 64, 256, 0, 64, 64]
          elsif @marks[i][1] == @index[0] * 64 + 128 && @marks[i][2] == @index[1] * 64
            @marks.delete_at(i)
            @marks.compact!
            @sprites["mark"].bitmap.clear
            break
          end
        end
        pbDrawImagePositions(@sprites["mark"].bitmap, @marks)
        pbWait(2)
      else
        # Display the tile for the selected spot
        icons = []
        for i in 0...@squares.length
          if @index[0] * 64 + 128 == @squares[i][0] && @index[1] * 64 == @squares[i][1] && @squares[i][3] == false
            pbAnimateTile(@index[0] * 64 + 128, @index[1] * 64, @squares[i][2])
            @squares[i][3] = true
            # If Voltorb (0), display all tiles on the board
            if @squares[i][2] == 0
              pbSEPlay("Voltorb Flip Explosion")
              # Play explosion animation
              # Part1
              animation = []
              for j in 0...3
                animation[0] = icons[0] = [@directory + "tiles", @index[0] * 64 + 128, @index[1] * 64, 704 + (64 * j), 0, 64, 64]
                pbDrawImagePositions(@sprites["animation"].bitmap, animation)
                pbWait(3)
                @sprites["animation"].bitmap.clear
              end
              # Part2
              animation = []
              for j in 0...6
                animation[0] = [@directory + "explosion", @index[0] * 64 - 32 + 128, @index[1] * 64 - 32, j * 128, 0, 128, 128]
                pbDrawImagePositions(@sprites["animation"].bitmap, animation)
                pbWait(3)
                @sprites["animation"].bitmap.clear
              end
              # Unskippable text block, parameter 2 = wait time (corresponds to ME length)
              Kernel.pbMessage(_INTL("\\me[Voltorb Flip Game Over]Oh no! You get {1}!\\wtnp[50]", getPurchaseDisplay(0, shorthand: false, currency: :Coins)))
              pbShowAndDispose
              @sprites["mark"].bitmap.clear
              if @level > 1
                # Determine how many levels to reduce by
                newLevel = 0
                for j in 0...@squares.length
                  if @squares[j][3] == true && @squares[j][2] > 1
                    newLevel += 1
                  end
                end
                if newLevel > @level
                  newLevel = @level
                end
                if @level > newLevel
                  @level = newLevel
                  @level = 1 if @level < 1
                  Kernel.pbMessage(_INTL("\\se[Voltorb Flip Level Dropped]Dropped to Game Lv. {1}!", @level.to_s))
                end
              end
              # Update level text
              @sprites["level"].bitmap.clear
              pbDrawShadowText(@sprites["level"].bitmap, 8, 150, 118, 28, "Level " + @level.to_s, Color.new(60, 60, 60), Color.new(150, 190, 170), 1)
              @points = 0
              pbUpdateCoins
              # Revert numbers to 0s
              @sprites["numbers"].bitmap.clear
              for i in 0...5
                pbUpdateRowNumbers(0, 0, i)
                pbUpdateColumnNumbers(0, 0, i)
              end
              pbDisposeSpriteHash(@sprites)
              @firstRound = false
              pbNewGame
            else
              # Play tile animation
              animation = []
              for j in 0...4
                animation[0] =
                  [@directory + "flipAnimation", @index[0] * 64 - 14 + 128, @index[1] * 64 - 16, j * 92, 0, 92, 96]
                pbDrawImagePositions(@sprites["animation"].bitmap, animation)
                pbWait(3)
                @sprites["animation"].bitmap.clear
              end
              if @points == 0
                @points += @squares[i][2]
                pbSEPlay("Voltorb Flip Point")
              elsif @squares[i][2] > 1
                @points *= @squares[i][2]
                pbSEPlay("Voltorb Flip Point")
              end
              tts(_INTL("Flipped a {1} point tile", @squares[i][2]))
              break
            end
          end
        end
      end
      count = 0
      for i in 0...@squares.length
        if @squares[i][3] == false && @squares[i][2] > 1
          count += 1
        end
      end
      pbUpdateCoins
      # Game cleared
      if count == 0
        @sprites["curtain"].opacity = 100
        Kernel.pbMessage(_INTL("\\me[Voltorb Flip Win]Board clear!\\wtnp[40]"))
        #        Kernel.pbMessage(_INTL("You've found all of the hidden x2 and x3 cards."))
        #        Kernel.pbMessage(_INTL("This means you've found all the Coins in this game, so the game is now over."))
        Kernel.pbMessage(_INTL("{1} received {2}!", $Trainer.name, getPurchaseDisplay(@points, shorthand: false, currency: :Coins)))
        # Update level text
        @sprites["level"].bitmap.clear
        pbDrawShadowText(@sprites["level"].bitmap, 8, 150, 118, 28, _INTL("Level {1}", @level.to_s), Color.new(60, 60, 60), Color.new(150, 190, 170), 1)
        $PokemonGlobal.coins += @points
        @points = 0
        pbUpdateCoins
        @sprites["curtain"].opacity = 0
        pbShowAndDispose
        # Revert numbers to 0s
        @sprites["numbers"].bitmap.clear
        for i in 0...5
          pbUpdateRowNumbers(0, 0, i)
          pbUpdateColumnNumbers(0, 0, i)
        end
        @sprites["curtain"].opacity = 100
        if @level < 8
          @level += 1
          Kernel.pbMessage(_INTL("Advanced to Game Lv. {1}!", @level.to_s))
          #          if @firstRound
          #            Kernel.pbMessage(_INTL("Congratulations!"))
          #            Kernel.pbMessage(_INTL("You can receive even more Coins in the next game!"))
          @firstRound = false
          #          end
        end
        pbDisposeSpriteHash(@sprites)
        pbNewGame
      end
    elsif Input.trigger?(Input::A) || Input.trigger?(Input::X) || Input.trigger?(Input::Y)
      if $game_switches[:Blindstep]
        if Kernel.pbConfirmMessage(_INTL("Do you want a hint?"))
          knownGood = []
          knownBad = []
          knownIrrelevant = []
          knownOne = []

          boardAnalysis.each_with_index { |it, idx|
            next if @squares[idx][3]
            solved = it.one?

            if solved && it[0]
              knownBad.push(idx)
            elsif solved && it[1]
              knownOne.push(idx)
            elsif !it[0]
              knownGood.push(idx)
            elsif it == [true, true, false, false]
              knownIrrelevant.push(idx)
            end
          }

          jumpTo = false
          idx = nil
          comment = ""

          if !knownGood.empty?
            jumpTo = true
            idx = knownGood.sample
            comment = _INTL("guaranteed to be safe")
          elsif !knownOne.empty?
            jumpTo = true
            idx = knownOne.sample
            comment = _INTL("guaranteed to be a 1")
          elsif !knownBad.empty?
            idx = knownBad.sample
            comment = _INTL("guaranteed to be a Voltorb")
          elsif !knownIrrelevant.empty?
            idx = knownIrrelevant.sample
            comment = _INTL("either a Voltorb or a 1")
          end

          if idx
            x = idx % 5
            y = idx / 5
            Kernel.pbMessage(_INTL("Tile {1}, {2} is {3}.", x + 1, y + 1, comment))

            readRow = @index[1] != y
            readColumn = @index[0] != x
            if jumpTo && (readRow || readColumn)
              pbSEPlay("Choose")

              @index[0] = x
              @index[1] = y
              @sprites["cursor"].x = 64 * x
              @sprites["cursor"].y = 64 * y

              ttsTile(doRow: readRow, doColumn: readColumn)
            end
          else
            Kernel.pbMessage(_INTL("No hints are available right now. Make an educated guess!"))
          end
        end
      else
        pbSEPlay("Choose")
        @sprites["cursor"].bitmap.clear
        if @cursor[0][3] == 0 # If in normal mode
          @cursor[0] = [@directory + "cursor", 128, 0, 64, 0, 64, 64]
          @sprites["memo"].visible = true
        else # Mark mode
          @cursor[0] = [@directory + "cursor", 128, 0, 0, 0, 64, 64]
          @sprites["memo"].visible = false
        end
      end
    elsif Input.trigger?(Input::B)
      @sprites["curtain"].opacity = 100
      if @points == 0
        if Kernel.pbConfirmMessage(_INTL("You haven't found any {1}! Are you sure you want to quit?", getCurrencyName(:Coins, true)))
          @sprites["curtain"].opacity = 0
          pbShowAndDispose
          @quit = true
        end
      elsif Kernel.pbConfirmMessage(_INTL("If you quit now, you will receive {1}. Will you quit?", getPurchaseDisplay(@points, shorthand: false, currency: :Coins)))
        Kernel.pbMessage(_INTL("{1} received {2}!", $Trainer.name, getPurchaseDisplay(@points, shorthand: false, currency: :Coins)))
        $PokemonGlobal.coins += @points
        @points = 0
        pbUpdateCoins
        @sprites["curtain"].opacity = 0
        pbShowAndDispose
        @quit = true
      end
      @sprites["curtain"].opacity = 0
    end
    # Draw cursor
    pbDrawImagePositions(@sprites["cursor"].bitmap, @cursor)
  end

  def pbUpdateRowNumbers(num, voltorbs, i)
    # Create and split a string for the number, with padded 0s
    numberSprites = []

    zeroes = 2 - num.to_s.length
    numText = ""
    for j in 0...zeroes
      numText += "0"
    end
    numText += num.to_s
    numImages = numText.split(//)[0...2]
    for j in 0...2
      numberSprites[j] = [@directory + "numbersSmall", 472 + j * 16, i * 64 + 8, numImages[j].to_i * 16, 0, 16, 16]
    end
    numberSprites.push [@directory + "numbersSmall", 488, i * 64 + 34, voltorbs * 16, 0, 16, 16]
    # Display the numbers
    pbDrawImagePositions(@sprites["numbers"].bitmap, numberSprites)
  end

  def pbUpdateColumnNumbers(num, voltorbs, i)
    # Create and split a string for the number, with padded 0s
    numberSprites = []

    zeroes = 2 - num.to_s.length
    numText = ""
    for j in 0...zeroes
      numText += "0"
    end
    numText += num.to_s
    numImages = numText.split(//)[0...2]
    for j in 0...2
      numberSprites[j] = [@directory + "numbersSmall", (i * 64) + 152 + j * 16, 328, numImages[j].to_i * 16, 0, 16, 16]
    end
    numberSprites.push [@directory + "numbersSmall", (i * 64) + 168, 354, voltorbs * 16, 0, 16, 16]
    # Display the numbers
    pbDrawImagePositions(@sprites["numbers"].bitmap, numberSprites)
  end

  def pbCreateCoins(source, y)
    zeroes = 5 - source.to_s.length
    coinText = ""
    for i in 0...zeroes
      coinText += "0"
    end
    coinText += source.to_s
    coinImages = coinText.split(//)[0...5]
    for i in 0...5
      @coins[i] = [@directory + "numbersScore", 6 + i * 24, y, coinImages[i].to_i * 24, 0, 24, 38]
    end
  end

  def pbUpdateCoins
    # Update coins display
    tts(getCurrencyDisplay($PokemonGlobal.coins, commas: false, shorthand: false, currency: :Coins)) if @lastcoins != $PokemonGlobal.coins
    @lastcoins = $PokemonGlobal.coins

    @sprites["totalCoins"].bitmap.clear
    pbCreateCoins($PokemonGlobal.coins, 44)
    pbDrawImagePositions(@sprites["totalCoins"].bitmap, @coins)

    # Update points display
    tts(_INTL("Points: {1}", @points)) if @points != 0 && @lastpoints != @points
    @lastpoints = @points

    @sprites["currentCoins"].bitmap.clear
    pbCreateCoins(@points, 110)
    pbDrawImagePositions(@sprites["currentCoins"].bitmap, @coins)
  end

  def pbAnimateTile(x, y, tile)
    icons = []
    points = 0
    for i in 0...3
      points = tile if i == 2
      icons[i] = [@directory + "tiles", x, y, 320 + (i * 64) + (points * 64), 0, 64, 64]
      pbDrawImagePositions(@sprites["icon"].bitmap, icons)
      pbWait(2)
    end
    icons[3] = [@directory + "tiles", x, y, tile * 64, 0, 64, 64]
    pbDrawImagePositions(@sprites["icon"].bitmap, icons)
    pbSEPlay("Voltorb Flip Tile")
  end

  def pbShowAndDispose
    # Make pre-rendered sprites visible (this approach reduces lag)
    for i in 0...5
      @sprites[i].visible = true
      pbWait(1) if i < 3
      @sprites[i].bitmap.clear
      @sprites[i].z = 99997
    end
    pbSEPlay("Voltorb Flip Tile")
    @sprites[5].visible = true
    @sprites["mark"].bitmap.clear
    pbWait(2)
    # Wait for user input to continue
    loop do
      pbWait(1)
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        break
      end
    end
    # "Dispose" of tiles by column
    for i in 0...5
      icons = []
      pbSEPlay("Voltorb Flip Tile")
      for j in 0...5
        icons[j] =
          [@directory + "tiles", @squares[i + (j * 5)][0], @squares[i + (j * 5)][1], 448 + (@squares[i + (j * 5)][2] * 64), 0,
           64, 64]
      end
      pbDrawImagePositions(@sprites[i].bitmap, icons)
      pbWait(2)
      for j in 0...5
        icons[j] = [@directory + "tiles", @squares[i + (j * 5)][0], @squares[i + (j * 5)][1], 384, 0, 64, 64]
      end
      pbDrawImagePositions(@sprites[i].bitmap, icons)
      pbWait(2)
      for j in 0...5
        icons[j] = [@directory + "tiles", @squares[i + (j * 5)][0], @squares[i + (j * 5)][1], 320, 0, 64, 64]
      end
      pbDrawImagePositions(@sprites[i].bitmap, icons)
      pbWait(2)
      for j in 0...5
        icons[j] = [@directory + "tiles", @squares[i + (j * 5)][0], @squares[i + (j * 5)][1], 896, 0, 64, 64]
      end
      pbDrawImagePositions(@sprites[i].bitmap, icons)
      pbWait(2)
    end
    @sprites["icon"].bitmap.clear
    for i in 0...6
      @sprites[i].bitmap.clear
    end
    @sprites["cursor"].bitmap.clear
  end

  #  def pbWaitText(msg,frames)
  #    msgwindow=Kernel.pbCreateMessageWindow
  #    Kernel.pbMessageDisplay(msgwindow,msg)
  #    frames.times do
  #      pbWait(1)
  #    end
  #    Kernel.pbDisposeMessageWindow(msgwindow)
  #  end

  def pbEndScene
    @sprites["curtainL"].angle = -180
    @sprites["curtainR"].angle = 90
    # Draw curtain effect
    @sprites["curtainL"].visible = true
    @sprites["curtainR"].visible = true
    loop do
      @sprites["curtainL"].angle += 9
      # Fixes a minor graphical bug
      @sprites["curtainL"].y -= 2 if @sprites["curtainL"].angle >= -90
      @sprites["curtainR"].angle -= 9
      pbWait(1)
      if @sprites["curtainL"].angle >= -90
        break
      end
    end
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      getInput
      if @quit
        break
      end
    end
  end
end

class VoltorbFlipScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStart
    @scene.pbScene
    @scene.pbEndScene
  end
end

def pbVoltorbFlip
  if $PokemonBag.pbQuantity(:COINCASE) <= 0
    Kernel.pbMessage(_INTL("You can't play unless you have a Coin Case."))
  elsif $PokemonGlobal.coins == MAXCOINS
    Kernel.pbMessage(_INTL("Your Coin Case is full!"))
  else
    scene = VoltorbFlip.new
    screen = VoltorbFlipScreen.new(scene)
    screen.pbStartScreen
  end
end

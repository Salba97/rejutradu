def pbTryUseMoveTutorApp
  if $game_variables[:E4_Tracker] > 0
    Kernel.pbMessage(_INTL("Cannot use the Move Tutor app here."))
    return
  end
  if pbGetTutorableMoves == []
    Kernel.pbMessage(_INTL("You don't have any registered moves."))
    return
  end
  if ($game_switches[:NotPlayerCharacter] && !$game_switches[:InterceptorsWish]) || xenTowerInProgress
    Kernel.pbMessage(_INTL("Cannot learn Move Tutor moves here..."))
    return
  end
  pbUseMoveTutorApp
end

def pbUseMoveTutorApp
  pbFadeOutIn(99999) { Scene_MoveTutor.new }
end

def pbGetTutorableMoves(onlybought: false)
  tutormoveslist = []
  if !$Trainer.tutorlist
    $Trainer.tutorlist = []
  end
  if $Trainer.tutorlist.any? { |i| i.is_a?(Integer) }
    for i in 0...$Trainer.tutorlist.length
      next if !$Trainer.tutorlist[i].is_a?(Integer)

      for j in $cache.moves.keys
        if $cache.moves[j].checkFlag?(:ID) == $Trainer.tutorlist[i]
          $Trainer.tutorlist[i] = $cache.moves[j].move
        end
      end
    end
  end
  $Trainer.tutorlist.each { |i| tutormoveslist.push(i) }
  unless onlybought
    $Trainer.buyablelist = [] if !$Trainer.buyablelist
    $Trainer.buyablelist.each { |i| tutormoveslist.push(i) unless tutormoveslist.include?(i[0]) }
  end
  return tutormoveslist | [] # remove duplicates
end

################################################################################
# Scene class for handling appearance of the screen
################################################################################
class Scene_MoveTutor
  VISIBLEMOVES = 4
  POKEMON_SPRITES_X = [300, 410, 300, 410, 300, 410]
  POKEMON_SPRITES_Y = [60, 78, 140, 164, 220, 244]

  def initialize
    pbInitMoves

    pbCreateViewportAndSprites
    addBackgroundPlane(@sprites, "background", "tutorbg", @viewport)
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }

    loop do
      v = update
      break if !v
    end

    pbFadeOutAndHide(@sprites) { pbUpdate } # Fade out all sprites
    pbDisposeSpriteHash(@sprites) # Dispose all sprites
    @viewport.dispose # Dispose the viewport
  end

  # Update the scene here, this is called once each frame
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbInitMoves
    @moves = pbGetTutorableMoves
    @moveCommands = []
    @moves.each { |i|
      move = i.is_a?(Array) ? i[0] : i
      @moveCommands.push(getMoveShortName(move))
    }
  end

  def pbCreateViewportAndSprites
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["selector"] = IconSprite.new(0, 0, @viewport)
    @sprites["selector"].setBitmap("Graphics/Pictures/reminderSel")
    @sprites["selector"].y = 78
    @sprites["selector"].src_rect = Rect.new(0, 72, 258, 72)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 100000
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["commands"] = Window_CommandPokemon.new(@moveCommands, 32)
    @sprites["commands"].x = Graphics.width
    @sprites["commands"].height = 32 * (VISIBLEMOVES + 1)
    pbTMSprites
    pbDrawMoveList
    render_header
  end

  def pbTMSprites
    xvalues = POKEMON_SPRITES_X
    yvalues = POKEMON_SPRITES_Y
    for i in 0...$Trainer.party.length
      if !@sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"] = IconSprite.new(0, 0, @viewport)
        @sprites["pokemon#{i}"].bitmap = pbPokemonIconBitmap($Trainer.party[i])
        @sprites["pokemon#{i}"].src_rect = Rect.new(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
        @sprites["pokemon#{i}"].x = xvalues[i] - (AURA_SPRITE_OFFSET / 2)
        @sprites["pokemon#{i}"].y = yvalues[i] - (AURA_SPRITE_OFFSET / 2)
        @sprites["pokemon#{i}"].z = 100000
        @sprites["pokemon#{i}"].visible = false
      else
        @sprites["pokemon#{i}"].bitmap = pbPokemonIconBitmap($Trainer.party[i])
        @sprites["pokemon#{i}"].src_rect = Rect.new(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
      end
      unless @sprites["possiblelearn#{i}"]
        @sprites["possiblelearn#{i}"] = IconSprite.new(0, 0, @viewport)
        @sprites["possiblelearn#{i}"].x = xvalues[i] + 32
        @sprites["possiblelearn#{i}"].y = yvalues[i] + 32
        @sprites["possiblelearn#{i}"].z = 100000
        @sprites["possiblelearn#{i}"].visible = false
      end
    end
  end

  def pbDrawMoveList
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    textpos = []
    imagepos = []
    type1rect = Rect.new(0, 0, 64, 28)
    textpos.push [_INTL("Teach which move?"), 16, 8, 0, *LightColorArrays[:Default]]
    yPos = 82
    for i in 0...VISIBLEMOVES
      listitem = @moves[@sprites["commands"].top_item + i]
      if listitem
        move = listitem.is_a?(Array) ? listitem[0] : listitem
        movedata = $cache.moves[move]
        if movedata
          typeimage = AnimatedBitmap.new(sprintf("Graphics/Icons/type%s", movedata.type))
          overlay.blt(12, yPos + 2, typeimage.bitmap, type1rect)
          basecolor = listitem.is_a?(Array) ? Color.new(124, 124, 124) : Color.new(248, 248, 248)
          textpos.push([getMoveShortName(move), 80, yPos, 0, basecolor, Color.new(0, 0, 0)])
          if movedata.maxpp > 0
            textpos.push([_INTL("PP"), 112, yPos + 32, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
            textpos.push([_ISPRINTF("{1:d}/{2:d}", movedata.maxpp, movedata.maxpp), 230, yPos + 32, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)])
          end
        else
          textpos.push(["-", 80, yPos, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
          textpos.push(["--", 228, yPos + 32, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)])
        end
      end
      yPos += 64
    end
    selected = @moves[@sprites["commands"].index]
    move = selected.is_a?(Array) ? selected[0] : selected
    selmovedata = $cache.moves[move]
    if selmovedata
      canlearnmove = PokemonBag.pbPartyCanLearnThisMove?(selmovedata.move)
      for i in 0...$Trainer.party.length
        @sprites["pokemon#{i}"].visible = true
        @sprites["possiblelearn#{i}"].visible = true
        sprite = case canlearnmove[i]
          when 0 then "Graphics/Pictures/Bag/tmnope" # unable
          when 1 then "Graphics/Pictures/Bag/tmcheck" # able
          when 2 then "Graphics/Pictures/Bag/tmdash" # learned
          else nil
        end
        @sprites["possiblelearn#{i}"].setBitmap(sprite)
      end
    else
      for i in 0...$Trainer.party.length
        @sprites["pokemon#{i}"].visible = false
        @sprites["possiblelearn#{i}"].visible = false
      end
    end
    imagepos.push(["Graphics/Pictures/reminderSel", 0, 78 + (@sprites["commands"].index - @sprites["commands"].top_item) * 64, 0, 0, 258, 72])
    pbDrawTextPositions(overlay, textpos)
    if @sprites["commands"].index < @moves.length - 1
      imagepos.push(["Graphics/Pictures/reminderButtons", 48, 350, 0, 0, 76, 32])
    end
    if @sprites["commands"].index > 0
      imagepos.push(["Graphics/Pictures/reminderButtons", 134, 350, 76, 0, 76, 32])
    end
    pbDrawImagePositions(overlay, imagepos)
    ttsCurMove(selmovedata, selected.is_a?(Array))
  end

  def ttsCurMove(selmovedata, buyable)
    string = ""
    # The move name is sent to tts by the command menu
    string += getTypeName(selmovedata.type) + ", "
    string += "#{selmovedata.maxpp} base and #{selmovedata.maxpp * 8 / 5} max PP"
    string += ", buyable" if buyable
    tts(string)
  end

  def render_header
    # intentionally empty
  end

  def update
    move = pbChooseMove
    if move.is_a?(Symbol)
      if Kernel.pbConfirmMessage(_INTL("Teach {1}?", getMoveName(move)))
        if pbMoveTutorChoose(move, bytutorapp: true)
          pbDrawMoveList
        end
      end
      return true
    elsif move.is_a?(Array)
      movesym, item, quantity = move[0], move[1], move[2]
      itemname = getItemName(item, plural: quantity > 1)
      Kernel.pbMessage(_INTL("Teaching {1} requires a payment of {2} {3}.", getMoveName(movesym), quantity, itemname))
      if $PokemonBag.pbQuantity(item) >= quantity
        if Kernel.pbConfirMessagem(_INTL("Teach this move?"))
          if pbMoveTutorChoose(movesym, bytutorapp: true)
            $PokemonBag.pbDeleteItem(item, quantity)
            $Trainer.tutorlist.push(movesym) # This moves the move to the regular tutorlist so cost doesn't have to be paid again
            $Trainer.buyablelist.delete_if { |i| i[0] == movesym } # This deletes the move from the buyable list
            refreshMoveList # Refresh the UI to reflect the move having been bought
          end
        end
      else
        itemname = getItemName(item, plural: true)
        Kernel.pbMessage(_INTL("Not enough {1}!", itemname))
      end
      return true
    end
    return false
  end

  # Processes the scene
  def pbChooseMove
    oldcmd = -1
    pbActivateWindow(@sprites, "commands") {
      loop do
        oldcmd = @sprites["commands"].index
        sort = nil
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["commands"].index != oldcmd
          @sprites["selector"].x = 0
          @sprites["selector"].y = 78 + (@sprites["commands"].index - @sprites["commands"].top_item) * 64
          pbDrawMoveList
        end
        # Cancel
        if Input.trigger?(Input::B)
          pbPlayCancelSE()
          return 0
        end
        # Select
        if Input.trigger?(Input::C)
          return @moves[@sprites["commands"].index]
        end
        # Sort controls
        sort = :name if Input.trigger?(Input::X)
        sort = :type if Input.trigger?(Input::A)
        if sort
          pbPlayDecisionSE()
          tts(sort == :name ? _INTL("Sorted by name") : _INTL("Sorted by type"), true)
          $Trainer.tutorlist.sort_by! { |move| getMoveName(move) } if sort == :name # Sort by move name
          $Trainer.tutorlist.sort_by! { |move| [getTypeName($cache.moves[move].type), getMoveName(move)] } if sort == :type # Sort by move type, and by move name within type
          refreshMoveList
        end
        # TTS sort controls
        if Input.triggerex?(Input::F2)
          ttsSortControls(:name, :type)
        end
      end
    }
  end

  def refreshMoveList
    # oldindex = @sprites["commands"].index
    pbInitMoves
    @sprites["commands"] = Window_CommandPokemon.new(@moveCommands, 32)
    @sprites["commands"].x = Graphics.width
    @sprites["commands"].height = 32 * (VISIBLEMOVES + 1)
    # @sprites["commands"].index = oldindex
    pbDrawMoveList
  end
end

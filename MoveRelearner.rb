def pbHasRelearnableMove?(pokemon)
  return [] if !pokemon || pokemon.isEgg? || (pokemon.isShadow? rescue false)
  return pokemon.pbGetNaturalMovesMenu(true).length > 0
end

################################################################################
# Scene class for handling appearance of the screen
################################################################################
class MoveRelearnerScene
  VISIBLEMOVES = 4
  RELEARNER_BG_PATHS = { general: "reminderbg" }
  SPRITESM_PATH = "Graphics/Icons/type%s"
  MOVEICON_PATH = "Graphics/Icons/type%s"

  # COLORS : [base, shadow]
  FONT_COLOR_1 = [Color.new(248, 248, 248), Color.new(0, 0, 0)]
  FONT_COLOR_2 = [Color.new(64, 64, 64), Color.new(176, 176, 176)]
  FONT_COLOR_3 = LightColorArrays[:Default]

  # POSITIONS : [x, y, step (optional)]
  SPRITESM_OFFSET = [288, 44]
  PKMNTYPEDUAL_OFFSET = [366, 70, 436, 70]
  PKMNTYPE_OFFSET = [400, 70]
  MOVEICON_OFFSET = [12, 0]
  MOVENAME_OFFSET = [MOVEICON_OFFSET[0] + 68, 0]
  POWER_OFFSET = [468, 146]
  ACCURACY_OFFSET = [468, 178]
  CATEG_OFFSET = [436, 116]
  MOVES_Y_OFFSET = [82, 64]
  MOVEDESC_OFFSET = [272, 210, 232] # [x, y, width]
  ARROW_POS_X = [4, 216]
  ARROW_POS_Y = 350

  def render_header
    # intentionally empty
  end

  # Update the scene here, this is called once each frame
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def determinePages
    @pages = @relearner ? [:relearn] : [:tms, :tutors, :relearn, :egg]
  end

  def pbStartScene(party, pkmnid, relearner)
    @party = party
    @partyid = pkmnid
    @pokemon = party[pkmnid]
    @relearner = relearner
    determinePages
    # Create sprite hash
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    initializePage(@pokemon, @pages.first)
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def refreshMoves(sortRefresh: false)
    initializePage(@pokemon, @page, sortRefresh: sortRefresh)
  end

  def initializePage(pokemon, page, sortRefresh: false)
    @pokemon = pokemon
    @partyid = @party.index(pokemon)
    @page = page
    @moves = []
    @error = nil

    pbDrawBackground()
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible = false
    @sprites["msgwindow"].viewport = @viewport
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].y = ARROW_POS_X[0]
    @sprites["rightarrow"].x = ARROW_POS_X[1]
    @sprites["rightarrow"].y = ARROW_POS_Y
    @sprites["leftarrow"].y = ARROW_POS_Y
    @sprites["leftarrow"].play
    @sprites["rightarrow"].play


    case page
    when :tms
      @label = Rejuv ? _INTL("TM & HM moves") : _INTL("TM & TMX moves")
      @moves = @pokemon.pbGetTMMovesMenu
    when :tutors
      @label = _INTL("Move Tutor moves")
      if $game_variables[:E4_Tracker] > 0 || ($game_switches[:NotPlayerCharacter] && !$game_switches[:InterceptorsWish]) || xenTowerInProgress
        @error = _INTL("Cannot learn Move Tutor moves here.")
      else
        @moves = @pokemon.pbGetTutorMovesMenu
      end
    when :relearn
      @label = _INTL("Natural moves")
      if $game_variables[:E4_Tracker] > 0
        @error = _INTL("Cannot relearn moves here.")
      elsif !@pokemon.canRelearnAll? && !@relearner && !$game_switches[:Always_Relearn]
        if $game_switches[:Portable_Move_Relearner]
          @error = _INTL("This Pokémon can't remember its moves on its own yet... \nPress C to reteach.")
        else
          @error = _INTL("This Pokémon can't remember its moves on its own yet...")
        end
      else
        @moves = @pokemon.pbGetNaturalMovesMenu(@relearner)
      end
    when :egg
      @label = Rejuv && $PokemonBag.pbHasItem?(:HM02) ? _INTL("Egg moves") : _INTL("Learnt egg moves")
      if $game_variables[:E4_Tracker] > 0
        @error = _INTL("Cannot learn egg moves here.")
      elsif !@pokemon.canRelearnAll? && !@relearner && !$game_switches[:Always_Relearn]
        @error = _INTL("This Pokémon can't remember its moves on its own yet...")
      else
        @moves = @pokemon.pbGetEggMovesMenu
      end
    end

    if @moves == [] && @error.nil?
      @error = _INTL("No moves available.")
    end

    applySorting

    tts("#{pokemon.name}'s #{@label}", true) unless @relearner || sortRefresh

    @sprites["pokeicon"].dispose if @sprites["pokeicon"]
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites["pokeicon"].x = SPRITESM_OFFSET[0]
    @sprites["pokeicon"].y = SPRITESM_OFFSET[1]

    moveCommands = @moves.map { |i| pbGetDisplayMoveName(i) }
    @sprites["commands"] = Window_CommandPokemon.new(moveCommands, 32)
    @sprites["commands"].x = Graphics.width
    @sprites["commands"].height = 32 * (VISIBLEMOVES + 1)
    pbDrawMoveList
  end

  def pbDrawMoveList
    render_header()
    pbScrollBackground()

    overlay = @sprites["overlay"].bitmap
    overlay.clear
    textpos = []
    smalltextpos = []
    imagepos = []

    pbAddLabelText(textpos)

    type1rect = Rect.new(0, 0, 64, 28)
    type2rect = Rect.new(0, 0, 64, 28)
    if @pokemon.type2.nil? || @pokemon.type1 == @pokemon.type2
      type1image = AnimatedBitmap.new(sprintf(SPRITESM_PATH, @pokemon.type1))
      overlay.blt(PKMNTYPE_OFFSET[0], PKMNTYPE_OFFSET[1], type1image.bitmap, type1rect)
    else
      type1image = AnimatedBitmap.new(sprintf(SPRITESM_PATH, @pokemon.type1))
      type2image = AnimatedBitmap.new(sprintf(SPRITESM_PATH, @pokemon.type2))
      overlay.blt(PKMNTYPEDUAL_OFFSET[0], PKMNTYPEDUAL_OFFSET[1], type1image.bitmap, type1rect)
      overlay.blt(PKMNTYPEDUAL_OFFSET[2], PKMNTYPEDUAL_OFFSET[3], type2image.bitmap, type2rect)
    end

    yPos = MOVES_Y_OFFSET[0]
    for i in 0...VISIBLEMOVES
      moveobject = @moves[@sprites["commands"].top_item + i]
      if moveobject
        movedata = $cache.moves[moveobject]
        if movedata
          typeimage = AnimatedBitmap.new(sprintf(MOVEICON_PATH, pbMoveSummaryType(movedata, @pokemon)))
          overlay.blt(MOVEICON_OFFSET[0], yPos + MOVEICON_OFFSET[1], typeimage.bitmap, type1rect)
          textpos.push([pbGetDisplayMoveName(moveobject), MOVENAME_OFFSET[0], yPos + MOVENAME_OFFSET[1], 0, *FONT_COLOR_1])
        end
        pbAddPPText(textpos, movedata, yPos)
      end
      yPos += MOVES_Y_OFFSET[1]
    end

    if @moves != []
      pbAddSelectionAndArrowGraphics(imagepos)
      selmovedata = $cache.moves[@moves[@sprites["commands"].index]]
      pbAddSelectedMoveData(overlay, textpos, smalltextpos, imagepos, selmovedata)
      basedamage = selmovedata.basedamage
      textpos.push([basedamage <= 1 ? (basedamage == 1 ? "???" : "---") : sprintf("%d", basedamage), *powerOffset(selmovedata), :center, *FONT_COLOR_2])
      accuracy = selmovedata.accuracy
      textpos.push([accuracy == 0 ? "---" : sprintf("%d", accuracy), *accuracyOffset(selmovedata), :center, *FONT_COLOR_2])
      priority = selmovedata.priority
      textpos.push([sprintf("%+d", priority), *priorityOffset(selmovedata), :center, *FONT_COLOR_2]) if priorityOffset(selmovedata)
      cattype = { physical: 0, special: 1, status: 2 }[selmovedata.category]
      imagepos.push(["Graphics/Pictures/category", *CATEG_OFFSET, 0, cattype * 28, 64, 28])
    end

    pbDrawImagePositions(overlay, imagepos)

    pbSetSmallFont(overlay)
    pbDrawTextPositions(overlay, smalltextpos)
    pbSetSystemFont(overlay)
    pbDrawTextPositions(overlay, textpos)

    pbDrawDescOrError(overlay, selmovedata)
  end

  def powerOffset(movedata)
    return POWER_OFFSET
  end

  def accuracyOffset(movedata)
    return ACCURACY_OFFSET
  end

  def priorityOffset(movedata)
    return nil
  end

  def applySorting
    $PokemonGlobal.moveRelearnerSorting = {} if $PokemonGlobal.moveRelearnerSorting.nil?
    sorting = $PokemonGlobal.moveRelearnerSorting[@page] || ([:tutors, :egg].include?(@page) ? :name : :number)
    case sorting
      when :name
        @moves.sort_by! do |move|
          next getMoveName(move)
        end
      when :type
        @moves.sort_by! do |move|
          next [getTypeName($cache.moves[move].type), getMoveName(move)]
        end
    end
  end

  def pbGetDisplayMoveName(move)
    getMoveShortName(move)
  end

  def pbDrawBackground
    addBackgroundPlane(@sprites, "bg", RELEARNER_BG_PATHS.values[0], @viewport)
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/reminderSel")
    @sprites["background"].y = 78
    @sprites["background"].src_rect = Rect.new(0, 72, 258, 72)
  end

  def pbScrollBackground
    @sprites["background"].x = 0
    @sprites["background"].y = 78 + (@sprites["commands"].index - @sprites["commands"].top_item) * 64
  end

  def pbAddLabelText(textpos)
    textpos.push [@label, 16, 8, 0, *FONT_COLOR_3]
  end

  def pbAddPPText(textpos, movedata, yPos)
    if movedata && movedata.maxpp > 0
      textpos.push([_INTL("PP"), 112, yPos + 32, 0, *FONT_COLOR_2])
      textpos.push([_ISPRINTF("{1:d}/{2:d}", movedata.maxpp, movedata.maxpp), MOVEICON_OFFSET[0] + 230, yPos + 32, 1, *FONT_COLOR_2])
    elsif !movedata
      textpos.push(["-", 80, yPos, 0, *FONT_COLOR_2])
      textpos.push(["--", 228, yPos + 32, 1, *FONT_COLOR_2])
    end
  end

  def pbAddSelectionAndArrowGraphics(imagepos)
    index = @sprites["commands"].index
    imagepos.push(["Graphics/Pictures/reminderSel", 0, 78 + (index - @sprites["commands"].top_item) * 64, 0, 0, 258, 72])
    imagepos.push(["Graphics/Pictures/reminderButtons", 48, 350, 0, 0, 76, 32]) if index > 0
    imagepos.push(["Graphics/Pictures/reminderButtons", 134, 350, 76, 0, 76, 32]) if index < @moves.length - 1
  end

  def pbAddSelectedMoveData(overlay, textpos, smalltextpos, imagepos, selmovedata)
    textpos.push([_INTL("CATEGORY"), 272, 114, 0, *FONT_COLOR_1])
    textpos.push([_INTL("POWER"), 272, 146, 0, *FONT_COLOR_1])
    textpos.push([_INTL("ACCURACY"), 272, 178, 0, *FONT_COLOR_1])
  end

  def pbDrawDescOrError(overlay, selmovedata)
    text = @moves != [] ? getMoveDesc(selmovedata.move) : @error
    drawTextEx(overlay, *MOVEDESC_OFFSET, 5, text, *FONT_COLOR_2)
    tts(@moves != [] ? moveToString(selmovedata.move, selmovedata, @pokemon, false) : @error, true)
  end

  # Processes the scene
  def pbChooseMove
    pbActivateWindow(@sprites, "commands") {
      loop do
        oldcmd = @sprites["commands"].index
        sort = nil
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["commands"].index != oldcmd
          pbDrawMoveList
        end
        # Sort controls
        numSort = ![:tutors, :egg].include?(@page)
        sort = :name if Input.trigger?(Input::X)
        sort = :type if Input.trigger?(Input::A)
        sort = :number if Input.trigger?(Input::Y) && numSort
        if sort && sort != $PokemonGlobal.moveRelearnerSorting[@page] && @moves != []
          $PokemonGlobal.moveRelearnerSorting[@page] = sort
          pbPlayDecisionSE()
          tts(sort == :name ? _INTL("Sorted by name") : (sort == :type ? _INTL("Sorted by type") : _INTL("Sorted by number")), true)
          refreshMoves(sortRefresh: true)
        end
        # TTS sort controls
        if Input.triggerex?(Input::F2)
          ttsSortControls(:name, :type, numSort ? :number : nil)
        end
        # Cancel
        if Input.trigger?(Input::B)
          return @pokemon, 0
        end
        # Select
        if Input.trigger?(Input::C)
          pokemon, move = handleRelearnerSelection
          if move != -1
            return pokemon, move
          end
        end
        # Page change
        if @pages.length > 1
          pokemon = @pokemon
          page = @page
          if Input.repeat?(Input::LEFT)
            if !@relearner && @pages.index(@page) == 0
              loop do
                pokemon = @party[(@party.index(pokemon) - 1) % @party.length]
                break if !pokemon.isEgg? || pokemon == @pokemon
              end
            end
            page = @pages[(@pages.index(@page) - 1) % @pages.length]
          end
          if Input.repeat?(Input::RIGHT)
            if !@relearner && @pages.index(@page) == @pages.length - 1
              loop do
                pokemon = @party[(@party.index(pokemon) + 1) % @party.length]
                break if !pokemon.isEgg? || pokemon == @pokemon
              end
            end
            page = @pages[(@pages.index(@page) + 1) % @pages.length]
          end
          if page != @page || pokemon != @pokemon
            pbPlayCursorSE()
            initializePage(pokemon, page)
          end
        end
      end
    }
  end

  def handleRelearnerSelection
    return @pokemon, @moves[@sprites["commands"].index]
  end

  # End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate } # Fade out all sprites
    pbDisposeSpriteHash(@sprites) # Dispose all sprites
    @viewport.dispose # Dispose the viewport
  end
end

# Screen class for handling game logic
class MoveRelearnerScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(party, pkmnid, relearner)
    @scene.pbStartScene(party, pkmnid, relearner)
    loop do
      pokemon, move = @scene.pbChooseMove
      if !move.is_a?(Symbol)
        # Learning from party menu doesn't require a confirmation to exit.
        if !relearner || Kernel.pbConfirmMessage(_INTL("Give up trying to teach a new move to {1}?", pokemon.name))
          @scene.pbEndScene
          return false
        end
      elsif Kernel.pbConfirmMessage(_INTL("Teach {1}?", getMoveName(move)))
        if pbTryLearnMove(pokemon, move, dontrestorePP: !relearner)
          # Move Relearner only teaches one move and then exits the screen.
          if relearner
            pokemon.updateRelearnBar if !pokemon.canRelearnAll? && !Desolation
            @scene.pbEndScene
            return true
          end
          # Refresh move list to remove the newly taught move and re-add forgotten move.
          @scene.refreshMoves
        end
      end
    end
  end
end

def pbRelearnMoveScreen(party, pkmnid, relearner: true)
  retval = true
  pbFadeOutIn(99999) {
    scene = MoveRelearnerScene.new
    screen = MoveRelearnerScreen.new(scene)
    retval = screen.pbStartScreen(party, pkmnid, relearner)
  }
  return retval
end

class PokemonGlobalMetadata
  attr_accessor :moveRelearnerSorting
end

def notableMoveFlags(move)
  flags = {
    :contact => _INTL("Contact"),
    :punchmove => _INTL("Punching"),
    :sharpmove => _INTL("Slicing"),
    :soundmove => _INTL("Sound-Based"),
    :windmove => _INTL("Wind"),
    :powdermove => _INTL("Powder"),
    :dancemove => _INTL("Dance"),
    :ballmove => _INTL("Ball & Bomb"),
    :bombmove => _INTL("Ball & Bomb"),
    :bitingmove => _INTL("Biting"),
    :pulsemove => _INTL("Pulse"),
    :healingmove => _INTL("Healing"),
    :explosivemove => _INTL("Explosive"),
    :mentalmove => _INTL("Mental"),
  }
  movedata = $cache.moves[move]
  moveflags = []
  flags.each do |flag, name|
    moveflags.push(name) if movedata.checkFlag?(flag)
  end
  return moveflags
end

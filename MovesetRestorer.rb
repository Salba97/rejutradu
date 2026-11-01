############### Moveset Restorer ######################

def pbRestoreMovesetScreen(pokemon)
  retval = true
  pbFadeOutIn(99999) {
    scene = MoveRestorerScene.new
    screen = MoveRestorerScreen.new(scene)
    retval = screen.pbStartScreen(pokemon)
  }
  return retval
end

def getSetName()
  return $game_variables[6]
end

def duplicateMovesetChecker(pokemon)
  $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
  for moveset in $PokemonGlobal.storedMovesets
    if moveset[:id] == pokemon.species
      different = false
      for i in 0...pokemon.moves.length
        found = false
        for j in 0...moveset[:moves].length
          if pokemon.moves[i].move == moveset[:moves][j][:move]
            found = true
          end
        end
        different = true if !found
      end
      if !different
        return moveset[:name]
      end
    end
  end
  return false
end

def duplicateNameChecker(pokemon)
  $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
  name = getSetName
  for moveset in $PokemonGlobal.storedMovesets
    if moveset[:id] == pokemon.species
      if moveset[:name] == name
        return true
      end
    end
  end
  return false
end

def updateMovesetName(pokemon)
  $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
  name = getSetName
  for moveset in $PokemonGlobal.storedMovesets
    if moveset[:id] == pokemon.species
      if moveset[:name] == name
        moveset[:moves] = pokemon.moves.map { |move| { move: move.move, ppup: move.ppup } }
        return true
      end
    end
  end
  return false
end

def movesetRecorder(pokemon)
  name = getSetName
  $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
  moveset = { name: name, moves: pokemon.moves.map { |move| { move: move.move, ppup: move.ppup } }, id: pokemon.species }
  $PokemonGlobal.storedMovesets.append(moveset)
  return true
end

def getMovesets(species, form)
  $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
  mon_sets = []
  for moveset in $PokemonGlobal.storedMovesets
    next unless moveset[:id] == species

    pokemon = PokeBattle_Pokemon.new(species, 1, $Trainer, false, form)
    compatible = moveset[:moves].all? { |move| isLegalMoves?(pokemon, [move[:move]]) }
    mon_sets.append(moveset) if compatible
  end
  return mon_sets
end

def hasMovesets(species, form)
  return !getMovesets(species, form).empty?
end

def deleteSet(pokemon, setname)
  $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
  $PokemonGlobal.storedMovesets.delete_if { |moveset| moveset[:id] == pokemon.species && moveset[:name] == setname }
  if !hasMovesets(pokemon.species, pokemon.form)
    Kernel.pbMessage(_INTL("'{1}' has been deleted.", setname))
    return true
  else
    return pokemon.species
  end
end

def restoreSet(pokemon, setname)
  $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
  for moveset in $PokemonGlobal.storedMovesets
    if moveset[:id] == pokemon.species
      if moveset[:name] == setname
        pokemon.moves.clear()
        moveset[:moves].each_with_index { |move, i|
          pokemon.moves[i] = PBMove.new(move[:move])
          pokemon.moves[i].ppup = move[:ppup]
          pokemon.moves[i].pp = pokemon.moves[i].totalpp
        }
        pokemon.initZmoves(true)
        Kernel.pbMessage(_INTL("'{1}' has been restored.", setname))
        return true
      end
    end
  end
end

# Screen class for handling game logic
class MoveRestorerScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(pokemon)
    @scene.pbStartScene(pokemon)
    loop do
      setname = @scene.pbChoose
      if setname == ""
        if @scene.pbConfirm(_INTL("Stop selecting movesets for {1}?", pokemon.name))
          @scene.pbEndScene
          return false
        end
      else
        ret = pbConfirmRelearnDeleteSets(pokemon, setname)
        if ret
          @scene.pbEndScene
          return ret
        end
      end
    end
  end

  def pbConfirmRelearnDeleteSets(pokemon, setname)
    cmdRestore = -1
    cmdDelete = -1
    cmdCancel = -1
    commands = []
    commands[cmdRestore = commands.length] = _INTL("Restore")
    commands[cmdDelete = commands.length] = _INTL("Delete")
    commands[commands.length] = _INTL("Cancel")
    command = @scene.pbShowCommands(_INTL("Do what with '{1}'?", setname), commands)
    if cmdRestore >= 0 && command == cmdRestore
      if restoreSet(pokemon, setname)
        @scene.pbEndScene
        return true
      end
    elsif cmdDelete >= 0 && command == cmdDelete
      if @scene.pbConfirm(_INTL("Forget this moveset?"))
        ret = deleteSet(pokemon, setname)
        if ret
          return true
        elsif ret != nil
          @scene.pbUpdateList(pokemon)
        end
      else
        # Do nothing
      end
    elsif cmdCancel >= 0 && command == cmdCancel
      # Do nothing
    end
  end
end

class MoveRestorerScene
  POKEICON_OFFSET = [288, 44]
  TYPE_OFFSET_SINGLE = [400, 70]
  TYPE_OFFSET_1 = [366, 70]
  TYPE_OFFSET_2 = [436, 70]
  SET_OFFSET = [292, 114, 32] # x, 1st y, vertical gap
  SET_COLOR = [Color.new(64, 64, 64), Color.new(176, 176, 176)]
  MOVE_1_Y = 82
  VISIBLESETS = 8

  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(pokemon)
    @pokemon = pokemon
    @movesets = getMovesets(pokemon.species, pokemon.form)
    movesetCommands = []
    @movesets.each { |i| movesetCommands.push(i[:name]) }
    # Create sprite hash
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    addBackgroundPlane(@sprites, "bg", "restorerbg", @viewport)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites["pokeicon"].x = POKEICON_OFFSET[0]
    @sprites["pokeicon"].y = POKEICON_OFFSET[1]
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"].play
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["moveOverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbSetSystemFont(@sprites["moveOverlay"].bitmap)
    @sprites["commands"] = Window_CommandPokemon.new(movesetCommands, 32)
    @sprites["commands"].x = Graphics.width
    @sprites["commands"].height = 32 * (VISIBLESETS + 1)
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible = false
    @sprites["msgwindow"].viewport = @viewport
    pbSetList
    pbDrawSetMoves
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdateList(pokemon)
    @movesets = getMovesets(pokemon.species, pokemon.form)
    movesetCommands = []
    @movesets.each { |i| movesetCommands.push(i[:name]) }
    @sprites["commands"] = Window_CommandPokemon.new(movesetCommands, 32)
    @sprites["commands"].x = Graphics.width
    @sprites["commands"].height = 32 * (VISIBLESETS + 1)
    pbSetList
    pbDrawSetMoves
  end

  def pbSetList
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    textpos = []
    imagepos = []
    type1rect = Rect.new(0, 0, 64, 28)
    type2rect = Rect.new(0, 0, 64, 28)
    if @pokemon.type2.nil? || @pokemon.type1 == @pokemon.type2
      type1image = AnimatedBitmap.new(sprintf("Graphics/Icons/type%s", @pokemon.type1))
      overlay.blt(*TYPE_OFFSET_SINGLE, type1image.bitmap, type1rect)
    else
      type1image = AnimatedBitmap.new(sprintf("Graphics/Icons/type%s", @pokemon.type1))
      overlay.blt(*TYPE_OFFSET_1, type1image.bitmap, type1rect)
      type2image = AnimatedBitmap.new(sprintf("Graphics/Icons/type%s", @pokemon.type2))
      overlay.blt(*TYPE_OFFSET_2, type2image.bitmap, type2rect)
    end
    yPos = SET_OFFSET[1]
    for i in 0...VISIBLESETS
      storedset = @movesets[@sprites["commands"].top_item + i]
      if storedset
        textpos.push([storedset[:name], SET_OFFSET[0], yPos, 0, *SET_COLOR])
      end
      yPos += SET_OFFSET[2]
    end
    pbAddExtraText(textpos)
    pbAddSelectionAndArrowGraphics(imagepos)
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
    pbDrawSetMoves
  end

  def pbAddExtraText(textpos)
    textpos.push([_INTL("Restore which moveset?"), 6, 8, 0, *LightColorArrays[:Default]])
  end

  def pbAddSelectionAndArrowGraphics(imagepos)
    index = @sprites["commands"].index
    # imagepos.push(["Graphics/Pictures/reminderSel", 0, 78 + (index - @sprites["commands"].top_item) * 64, 0, 0, 258, 72])
    imagepos.push(["Graphics/Pictures/reminderButtons", 48, 350, 0, 0, 76, 32]) if index < @movesets.length - 1
    imagepos.push(["Graphics/Pictures/reminderButtons", 134, 350, 76, 0, 76, 32]) if index > 0
  end

  def pbDrawSetMoves
    overlay = @sprites["moveOverlay"].bitmap
    overlay.clear
    textpos = []
    imagepos = []
    selmoveset = @movesets[@sprites["commands"].index][:moves]
    yPos = MOVE_1_Y
    for move in selmoveset
      m = PBMove.new(move[:move])
      m.ppup = move[:ppup]
      pbAddMoveTextsAndImages(m, yPos, textpos, imagepos)
      yPos += 64
    end
    @sprites["rightarrow"].x = 254
    @sprites["rightarrow"].y = 116 + (@sprites["commands"].index - @sprites["commands"].top_item) * 32
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
  end

  def pbAddMoveTextsAndImages(m, yPos, textpos, imagepos)
    imagepos.push([sprintf("Graphics/Icons/type%s", pbMoveSummaryType(m, @pokemon)), 12, yPos + 2, 0, 0, 64, 28])
    textpos.push([getMoveShortName(m.move), 80, yPos, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)])
    if m.totalpp > 0
      textpos.push([_INTL("PP"), 112, yPos + 32, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
      textpos.push([_ISPRINTF("{1:d}/{2:d}", m.totalpp, m.totalpp), 230, yPos + 32, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    end
  end

  # Processes the scene
  def pbChoose
    oldcmd = -1
    pbActivateWindow(@sprites, "commands") {
      loop do
        oldcmd = @sprites["commands"].index
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["commands"].index != oldcmd
          #  @sprites["background"].x=0
          #  @sprites["background"].y=78+(@sprites["commands"].index-@sprites["commands"].top_item)*64
          pbSetList
        end
        if Input.trigger?(Input::B)
          return ""
        end
        if Input.trigger?(Input::C)
          return @movesets[@sprites["commands"].index][:name]
        end
      end
    }
  end

  def pbShowCommands(message, commands, index = 0)
    ret = 0
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.resizeHeightToFit(message, Graphics.width - 180)
    msgwindow.text = message
    pbBottomRight(msgwindow)
    cmdwindow = Window_CommandPokemon.new(commands)
    cmdwindow.viewport = @viewport
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height = Graphics.height - msgwindow.height if cmdwindow.height > Graphics.height - msgwindow.height
    cmdwindow.update
    cmdwindow.index = index
    pbBottomRight(cmdwindow)
    cmdwindow.y -= msgwindow.height
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        ret = -1
        break
      end
      if Input.trigger?(Input::C)
        ret = cmdwindow.index
        break
      end
      pbUpdateSpriteHash(@sprites)
      msgwindow.update
      cmdwindow.update
    end
    msgwindow.dispose
    cmdwindow.dispose
    Input.update
    return ret
  end

  # End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate } # Fade out all sprites
    pbDisposeSpriteHash(@sprites) # Dispose all sprites
    @viewport.dispose # Dispose the viewport
  end
end

#===============================================================================
# ** Scene_iPod
# ** Created by xLeD (Scene_Jukebox)
# ** Modified by Harshboy
# ** Modified by Kurotsune
#-------------------------------------------------------------------------------
#  This class performs menu screen processing.
#===============================================================================
class Scene_Jukebox
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0, fromPokeGear = true)
    @menu_index = menu_index
    @fromPokeGear = fromPokeGear
  end

  #-----------------------------------------------------------------------------
  # * Main Processing
  #-----------------------------------------------------------------------------
  def main
    # Makes the text window
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["background"] = IconSprite.new(0, 0)
    @sprites["background"].setBitmap("Graphics/Pictures/jukeboxbg")
    @sprites["background"].z = 255
    files = []
    Dir.chdir("Audio/BGM/") {
      Dir.glob("*.mp3") { |f| files.push(File.basename(f, File.extname(f))) }
      Dir.glob("*.ogg") { |f| files.push(File.basename(f, File.extname(f))) }
      Dir.glob("*.mid") { |f| files.push(File.basename(f, File.extname(f))) }
    }
    if Dir.exist?("patch/Audio/BGM/")
      Dir.chdir("patch/Audio/BGM/") {
        Dir.glob("*.mp3") { |f| files.push(File.basename(f, File.extname(f))) }
        Dir.glob("*.ogg") { |f| files.push(File.basename(f, File.extname(f))) }
        Dir.glob("*.mid") { |f| files.push(File.basename(f, File.extname(f))) }
      }
    end
    files.uniq!
    files = spoilerFilter(files) if Rejuv
    files.sort!
    files.push("Stop Playing")
    if $game_system.playing_bgm && $game_system.playing_bgm.name != ""
      files.delete($game_system.playing_bgm.name)
      files.unshift($game_system.playing_bgm.name)
    end
    @choices = files
    @sprites["command_window"] = Window_JukeboxCommand.new(@choices, 324)
    @sprites["command_window"].windowskin = nil
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].setHW_XYZ(224, 324, 94, 92, 256)
    @sprites["command_window"].baseColor, @sprites["command_window"].shadowColor = *ColorArrays[:Default]
    render_header
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepares for transition
    Graphics.freeze
    # Disposes the windows
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def render_header
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(_INTL("Jukebox"), 2, -18, 128, 64, @viewport)
    @sprites["header"].baseColor, @sprites["header"].shadowColor = *ColorArrays[:Default]
    @sprites["header"].windowskin = nil
  end

  def spoilerFilter(tracklist)
    heardTracks = $Unidata[:heardTracks] || []
    return tracklist - (SPOILERTRACKS - heardTracks)
  end

  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    # Update windows
    pbUpdateSpriteHash(@sprites)
    updateCustom
    return
  end

  #-----------------------------------------------------------------------------
  # * Frame Update (when command window is active)
  #-----------------------------------------------------------------------------
  def updateCustom
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      if @fromPokeGear
        $scene = Scene_Pokegear.new(:jukebox)
      else
        $scene = Scene_Map.new
      end
      return
    end
    if Input.trigger?(Input::C)
      $PokemonMap.whiteFluteUsed = false if $PokemonMap
      $PokemonMap.blackFluteUsed = false if $PokemonMap
      if !$Settings.volume
        $Settings.volume = 100.0
      end
      if @sprites["command_window"].index == @sprites["command_window"].commands.length - 1
        if Reborn && !@fromPokeGear
          $game_variables[808] = 0
          $game_map.map.bgm.name = "Nightclub- Main"
          pbBGMPlay($game_map.map.bgm)
        else
          $game_system.setDefaultBGM(nil, $Settings.volume)
          $game_system.bgm_stop
          $game_map.autoplay
        end
      else
        if Reborn && !@fromPokeGear
          $game_variables[808] = @sprites["command_window"].commands[@sprites["command_window"].index]
          $game_system.setDefaultBGM(nil, $Settings.volume)
          $game_system.bgm_play(
            pbResolveAudioFile($game_variables[808], $Settings.volume)
          )
        else
          $game_system.setDefaultBGM(
            @sprites["command_window"].commands[@sprites["command_window"].index], $Settings.volume
          )
        end
      end
      @sprites["command_window"].refresh
    end
  end

  def update_command # Almost certainly redundant now.
    # If B button was pressed
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      # Switch to map screen
      if @fromPokeGear == true
        $scene = Scene_Pokegear.new(:jukebox)
      else
        $scene = Scene_Map.new
      end
      return
    end
  end
end

class Window_JukeboxCommand < Window_CommandPokemon
  PlayingBGMColors = ColorArrays[:Magenta]
  CancelColors = ColorArrays[:Gray2]

  def drawItem(index, count, rect)
    pbSetSystemFont(self.contents) if @starting
    rect = drawCursor(index, rect)
    colors = [self.baseColor, self.shadowColor]
    colors = CancelColors if index == @commands.length - 1 # Stop Playing
    if $scene.is_a?(Scene_Jukebox)
      playing = $game_system.getDefaultBGM || $game_system.playing_bgm
      colors = PlayingBGMColors if playing && @commands[index] == playing.name
    end
    pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, @commands[index], *colors)
  end
end

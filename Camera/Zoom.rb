class ZoomMap
  attr_accessor :goal
  attr_accessor :speed

  def initialize(goal, speed, byFrames = false)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    self.goal = goal
    self.setSpeed(speed, byFrames)
    @sprites = {}
    @sprites["map"] = Sprite.new(@viewport)
    @sprites["map"].bitmap =  Graphics.snap_to_bitmap
    @sprites["map"].center_origins
    @sprites["map"].x = Graphics.width / 2
    @sprites["map"].y = Graphics.height / 2
    Graphics.update
  end

  def setSpeed(speed, byFrames = false)
    if byFrames
      self.speed = 1.0 / (speed * 2)
    else
      self.speed = speed
    end
  end

  def update
    if @sprites
      @sprites["map"].bitmap.clear
      messagewindow = $game_temp.message_window
      savewindow = $game_temp.save_window
      cmdwindow = $game_temp.cmd_window
      ready_window = $game_temp.ready_window
      pausemenu = $game_temp.pause_menu_scene
      partymenu = $game_temp.party_menu_scene
      vs_window_main = $game_temp.vs_window_main
      vs_window_player = $game_temp.vs_window_player
      vs_window_opp = $game_temp.vs_window_opp
      vs_window_vs = $game_temp.vs_window_vs
      blessings = $game_temp.blessing_overlay if $game_temp.blessing_overlay&.visible
      messagewindow.visible = false if messagewindow
      savewindow.visible = false if savewindow
      cmdwindow.visible = false if cmdwindow
      ready_window.visible = false if ready_window
      pausemenu.pbHideMenu if pausemenu
      partymenu.hideHUD if partymenu
      blessings.pbHideMenu if blessings
      vs_window_main.visible = false if vs_window_main
      vs_window_player.visible = false if vs_window_player
      vs_window_opp.visible = false if vs_window_opp
      vs_window_vs.visible = false if vs_window_vs
      # @sprites["map"].bitmap = self.goal >= 1 ? Graphics.snap_to_bitmap : makeMapScreenshot($game_map.map_id)
      @sprites["map"].bitmap = Graphics.snap_to_bitmap
      @sprites["map"].center_origins
      @sprites["map"].x = Graphics.width / 2
      @sprites["map"].y = Graphics.height / 2
      messagewindow.visible = true if messagewindow
      savewindow.visible = true if savewindow
      cmdwindow.visible = true if cmdwindow
      ready_window.visible = true if ready_window
      pausemenu.pbShowMenu if pausemenu && !savewindow
      partymenu.showHUD if partymenu
      blessings.pbShowMenu if blessings
      vs_window_main.visible = true if vs_window_main
      vs_window_player.visible = true if vs_window_player
      vs_window_opp.visible = true if vs_window_opp
      vs_window_vs.visible = true if vs_window_vs

      if @sprites["map"].zoom != self.goal
        if @sprites["map"].zoom < self.goal
          altspeed = self.goal - @sprites["map"].zoom
          @sprites["map"].zoom += [self.speed, altspeed].min
        else
          altspeed = @sprites["map"].zoom - self.goal
          @sprites["map"].zoom -= [self.speed, altspeed].min
        end
      else
        blessings.redraw if blessings&.need_redraw
      end
      if $game_system&.background_zoom != [@goal, @speed]
        $game_system.background_zoom = [@goal, @speed]
      end

    else
      dispose
    end
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def disposed?
    @viewport.disposed?
  end
end

def pbZoomMap(goal, speed, byFrames = false)
  $game_temp.blessing_overlay&.need_redraw = true
  if !$game_temp.background_zoom
    $game_temp.background_zoom = ZoomMap.new(goal, speed, byFrames)
  else
    $game_temp.background_zoom.goal = goal
    $game_temp.background_zoom.setSpeed(speed, byFrames)
  end
end

def pbDisposeZoomMap
  if $game_temp.background_zoom
    $game_temp.background_zoom.dispose
    $game_temp.background_zoom = nil
  end
  Graphics.update
end

Events.onMapUpdate += proc { |_sender, _e|
  next if !$Trainer
  if $game_temp.background_zoom.is_a?(ZoomMap) && !pbIsFaded?
    $game_temp.background_zoom.update
    sprites = $game_temp.background_zoom.instance_variable_get(:@sprites)
    if $game_temp.background_zoom.goal == 1 && sprites["map"].zoom == 1
      pbDisposeZoomMap
    end
  end
}

#===============================================================================
# Pause Menu Rewriting
#===============================================================================
# If you're using an alternate pause UI,
# you should probably delete this whole section.

class Scene_Map
  def call_menu
    $game_screen.getTimeCurrent
    $game_player.straighten
    $game_map.update
    $game_temp.pause_menu_scene = PokemonMenu_Scene.new
    pause_menu_screen = PokemonMenu.new($game_temp.pause_menu_scene)
    pause_menu_screen.pbStartPokemonMenu
    $game_temp.menu_calling = false
    $game_screen.getTimeCurrent(true)
    $game_map.refresh
    $game_temp.pause_menu_scene = nil
    $game_screen.getTimeCurrent
  end
end

class PokemonMenu_Scene
  def pbShowMenu
    pbStartScene if @sprites["cmdwindow"] && @sprites["cmdwindow"].disposed?
    @sprites["cmdwindow"].visible = true if @sprites["cmdwindow"]
    @sprites["infowindow"].visible = @infostate if @sprites["infowindow"]
    @sprites["helpwindow"].visible = @helpstate if @sprites["helpwindow"]
  end

  def pbHideMenu
    @sprites["cmdwindow"].visible = false if @sprites["cmdwindow"]
    @sprites["infowindow"].visible = false if @sprites["infowindow"]
    @sprites["helpwindow"].visible = false if @sprites["helpwindow"]
  end
end

class PokemonReadyMenu_Scene
  alias __zoom_readyMenu pbStartScene unless method_defined?(:__zoom_readyMenu)
  def pbStartScene(*args)
    __zoom_readyMenu(*args)
    $game_temp.ready_window = @sprites["cmdwindow"]
  end
end

class Spriteset_Map
  def update
    updateOldFL
    if !@@hud
      $game_temp.party_menu_scene = HUD.new(@viewport1b)
      @@hud = $game_temp.party_menu_scene
    end
    @@hud.update
  end

  class HUD
    def showHUD
      @sprites.each { |name, spr| spr.visible = true if spr }
    end

    def hideHUD
      @sprites.each { |name, spr| spr.visible = false if spr }
    end
  end
end

#===============================================================================
# Sprite Utilities
#===============================================================================
# If you have these utilities defined elsewhere, you can delete this section.
class Sprite
  # Utility from Marin
  # Centers the sprite by setting the origin points to half the width and height
  def center_origins
    return if !self.bitmap
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
  end

  # Utility from Luka
  #-----------------------------------------------------------------------------
  #  gets zoom
  #-----------------------------------------------------------------------------
  def zoom
    return self.zoom_x
  end
  #-----------------------------------------------------------------------------
  #  sets all zoom values
  #-----------------------------------------------------------------------------
  def zoom=(val)
    self.zoom_x = val
    self.zoom_y = val
  end
end

#===============================================================================
# Game Temp and Message Window rewriting
#===============================================================================
# This code is to allow the ZoomMap class to hide these windows
# when taking a screenshot, so that the text won't be zoomed in.
class Game_System
  attr_accessor :background_zoom
end

class Game_Temp
  attr_accessor :background_zoom
  attr_accessor :message_window
  attr_accessor :cmd_window
  attr_accessor :save_window
  attr_accessor :ready_window
  attr_accessor :pause_menu_scene
  attr_accessor :pause_menu_screen
  attr_accessor :party_menu_scene
  attr_accessor :vs_window_main
  attr_accessor :vs_window_player
  attr_accessor :vs_window_opp
  attr_accessor :vs_window_vs
  attr_accessor :blessing_overlay

  def zoom_amount
    @background_zoom ? @background_zoom.goal : 1
  end

  def vs_window_main
    return @vs_window_main if !@vs_window_main&.disposed?
  end

  def vs_window_player
    return @vs_window_player if !@vs_window_player&.disposed?
  end

  def vs_window_opp
    return @vs_window_opp if !@vs_window_opp&.disposed?
  end

  def vs_window_vs
    return @vs_window_vs if !@vs_window_vs&.disposed?
  end
end

def Kernel.pbCreateMessageWindow(viewport = nil, skin = nil)
  $game_temp.message_window = Window_AdvancedTextPokemon.new("")
  msgwindow = $game_temp.message_window
  if !viewport
    msgwindow.z = 99999
  else
    msgwindow.viewport = viewport
  end
  msgwindow.visible = true
  msgwindow.letterbyletter = true
  msgwindow.back_opacity = MessageConfig::WindowOpacity
  pbBottomLeftLines(msgwindow, 2)
  $game_temp.message_window_showing = true if $game_temp
  $game_message.visible = true if $game_message
  skin = MessageConfig.pbGetSpeechFrame() if !skin
  msgwindow.setSkin(skin)
  return msgwindow
end

def Kernel.pbDisposeMessageWindow(msgwindow)
  $game_temp.message_window_showing = false if $game_temp
  $game_message.visible = false if $game_message && $game_temp.message_window
  msgwindow.dispose if msgwindow
end

# See also pbBattleAnimation for zoom-related code conditioned with defined?(ZoomMap)

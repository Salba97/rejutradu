#==============================================================================
# ** Dynamic Lights
#------------------------------------------------------------------------------
# by kellessdee
# Version: 1.00
# Date: 23/05/2011
#------------------------------------------------------------------------------
# Version History:
#
#   1.00 - First release
#------------------------------------------------------------------------------
# Description:
#
#   Allows the user to set up dynamic lights on the game map
#------------------------------------------------------------------------------
# Compatibility:
#
#------------------------------------------------------------------------------
# Instructions:
#
#   To create an event as a light source, create an event and set the first
#   command as a comment. The syntax is as follows:
#       render_light filename
#       radius
#       tone_red tone_green tone_blue
#       flicker
#       glow
#       brightness
#------------------------------------------------------------------------------
# Parameters:
#
#   filename      :the light picture file
#   radius        :radius in pixels
#   tone_red      :tone red value to be mixed (0 - 255)
#   tone_green    :tone green value to be mixed (0 - 255)
#   tone_blue     :tone blue value to be mixed (0 - 255)
#   flicker       :type true if you want the lights to flicker
#   glow          :type true if you want the lights to glow
#   brightness    :the brightness of the light source (0 - 255)
#------------------------------------------------------------------------------
# Notes:
#
#   Any questions, comments or issues you may reach me at:
#
#     kellessdee@gmail.com
#     http://www.rmxpunlimited.com/forums (look for kellessdee)
#     http://wakingdreams.weebly.com/
#
#==============================================================================

#==============================================================================
# ** Sprite_Light_Source
#------------------------------------------------------------------------------
#   Displays the light on the screen
#==============================================================================
class Light_Source < Sprite
  #----------------------------------------------------------------------------
  # * Constants
  #----------------------------------------------------------------------------
  DEFAULT = 'Graphics/Pictures/LEwhite'
  SWITCH = 42
  #----------------------------------------------------------------------------
  # * Public Instance Variables
  #----------------------------------------------------------------------------
  attr_accessor :event
  attr_reader :original_tone
  attr_reader :sst
  attr_accessor :fadein
  attr_reader :map_id
  #----------------------------------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------------------------------
  def initialize(event, radius, tone, flicker, glow, brightness, filename, sst)
    super()
    self.z = 2
    self.tone = tone
    self.opacity = 0
    self.x = (event.real_x - radius * 2 - $MapFactory.getMapNoAdd(event.map_id).display_x) / 4 + 12
    self.y = (event.real_y - radius * 2 - $MapFactory.getMapNoAdd(event.map_id).display_y) / 4 + 6
    bmp = filename == nil ? RPG::Cache.load_bitmap(DEFAULT) : RPG::Cache.load_bitmap(filename)
    self.bitmap = Bitmap.new(radius, radius)
    self.bitmap.stretch_blt(Rect.new(0, 0, radius, radius), bmp, bmp.rect)
    @radius = radius
    @brightness = brightness
    @fadein = true
    @event = event
    @flicker = flicker
    @glow = glow
    @step = 0.001
    @flickerDir = 1
    @count = 0
    @original_tone = tone
    @maxBrightness = @brightness + 20
    @minBrightness = @brightness - 20
    @sst = sst # supersede the tone, take prio over game_screen
    @map_id = @event.map_id
  end
  #----------------------------------------------------------------------------
  # * Update Frame
  #----------------------------------------------------------------------------
  def update
    # fade in lights
    if $game_screen.tone_duration == 0 || @sst
      if @fadein
        self.opacity += @brightness / 10
        @fadein = false if self.opacity >= @brightness
      end
      # Update flicker effect
      if @flicker
        opacity = rand(-5..5)
        if self.opacity + opacity > @maxBrightness
          opacity = opacity.abs * -1
        end
        if self.opacity + opacity < @minBrightness
          opacity = opacity.abs
        end
        self.opacity += opacity
      end
      # Update Glow effect
      if @glow
        self.zoom_x += @step
        self.zoom_y += @step
        @count += 1
        if @count == 220
          @step = -@step
          @count = 0
        end
      end
    end
    self.x = (@event.real_x - (@radius * 2).to_f * self.zoom_x - $MapFactory.getMapNoAdd(event.map_id).display_x) / 4 + 12
    self.y = (@event.real_y - (@radius * 2).to_f * self.zoom_y - $MapFactory.getMapNoAdd(event.map_id).display_y) / 4 + 6
  end
end
#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#   Redefine initialization to create light array
#   Redefine update to update light array
#   Redefine dispose to destroy light array
#   Added render light method to set up light array
#==============================================================================
class Spriteset_Map
  #----------------------------------------------------------------------------
  # * Method Aliases
  #----------------------------------------------------------------------------
  unless @dynamicLightningAliases
    alias :new_light_render_init :initialize
    alias :new_light_render_updt :update
    alias :new_light_render_disp :dispose
    @dynamicLightningAliases = true
  end
  attr_accessor :refresh_lights
  attr_accessor :light_source
  #----------------------------------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------------------------------
  def initialize(map = nil)
    @light_source = []
    @refresh_lights = true
    new_light_render_init(map)
  end
  #----------------------------------------------------------------------------
  # * Update Frame
  #----------------------------------------------------------------------------
  def update
    if $game_switches && $game_switches[Light_Source::SWITCH]
      disposeLights
    end
    if !@light_source.empty?
      if $game_screen.tone_target == Tone.new(-255, -255, -255, 0)
        @light_source.each { |light|
          next if light.sst
          if $game_screen.tone_duration == 0
            light.tone.gray = 0
          else
            d = $game_screen.tone_duration
            light.tone.red = (light.tone.red * (d - 1) - 255) / d
            light.tone.green = (light.tone.green * (d - 1) - 255) / d
            light.tone.blue = (light.tone.blue * (d - 1) - 255) / d
            light.tone.gray = (light.tone.gray * (d - 1)) / d
          end
        }
      else
        @light_source.each{ |light| (light.tone = light.original_tone; light.fadein = true; light.opacity = 0) if light.tone != light.original_tone }
      end
      @light_source.each {|light| light.update }
    end
    new_light_render_updt
    return if !@refresh_lights
    render_light_source
  end
  #----------------------------------------------------------------------------
  # * Dispose Object
  #----------------------------------------------------------------------------
  def dispose
    if $game_temp.player_new_map_id == $game_map.map_id
      $game_temp.lightCopy = @light_source
    else
      disposeLights
    end
    new_light_render_disp
  end

  def disposeLights
    @light_source.each {|light| light.dispose }
    @light_source = []
  end
  #----------------------------------------------------------------------------
  # * Render Light Source
  #----------------------------------------------------------------------------
  def render_light_source
    return if $game_screen&.tone_duration != 0
    @refresh_lights = false
    if $game_temp.lightCopy
      @light_source = $game_temp.lightCopy
      $game_temp.lightCopy = nil
      return
    end
    @map.events.values.each {|event|
      next if event.list == nil
      if event.list[0].code == 108 && event.list[0].parameters[0].split[0] == 'render_light'
        # Get file name
        filename = event.list[0].parameters[0].split[1]
        parms = []
        (1..6).each {|i|
          if event.list[i].code == 108
            parms << event.list[i].parameters
          end
        }
        6.times {|i| parms[i] = [0] if !parms[i] || parms[i] == [nil] }
        # Get Radius
        rad = parms[0][0].to_i
        t = parms[1][0].split
        ton = Tone.new(-t[0].to_i, -t[1].to_i, -t[2].to_i)
        fli = (parms[2] == ['true'])
        glo = (parms[3] == ['true'])
        bri = parms[4][0].to_i
        sst = (parms[5] == ['true'])
        @light_source << Light_Source.new(event, rad, ton, fli, glo, bri, filename, sst)
        @light_source << Light_Source.new(event, rad + 50, ton, fli, glo, bri - 25, filename, sst)
        @light_source << Light_Source.new(event, rad + 100, ton, fli, glo, bri - 50, filename, sst)
      end
    }
  end
end

class Game_Map
  alias __dl_refresh refresh unless method_defined?(:__dl_refresh)
  def refresh
    __dl_refresh
    return if $PokemonTemp.begunNewGame
    if $scene.is_a?(Scene_Map) && !$scene.spritesetNil? && $scene.spriteset.light_source.empty?
      $scene.spriteset.refresh_lights = true
    end
  end
end

class Scene_Map
  def spritesetNil?
    return @spriteset.nil? || self.spriteset.nil?
  end
end

class Game_Screen
  attr_reader :tone_target
end

class Game_Temp
  attr_accessor :lightCopy
end

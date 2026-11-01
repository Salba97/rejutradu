#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# Zer0 Advanced Weather
# Author: ForeverZer0
# Base Script: Ccoa
# Color Effects: Agckuu Coceg
# Version: 1.1
# Date: 4.7.2010
#
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
#
# Instructions:
#
#    1. Place anywhere below Spriteset_Map.
#    2. Weather can be still be changed with the normal script call...
#
#           $game_screen.weather(type, power, transition)
#
#       ...but a new addition has been added. The weather variation can be
#       changed by using this script call:
#
#           $game_screen.weather(type, power, transition, variation)
#
#       If you omit the variation, it will be assumed to be 0 and the normal
#       default weather pattern will be used.
#
# Notes/Issues:
#
#    Realistic Storm uses random volume and pitch for the thunder. It also
#    incorporates a quick screen shake (Agckuu Coceg), but only if the
#    volume and pitch are both high (ForeverZer0), to give a realistic feel
#    to the storm.
#
# Credits/Thanks:
#
#     1. Ccoa (base script, most default weather effects)
#     2. Agckuu Coceg (inspiration, most color effects)
#     3. Blizzard (Bitmap2Code program made new effects possible)
#     4. ForeverZer0 (all the rest ;)
#
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
#
#  Anything within () is a possible variation for the respective weather type.
#   The first item is the default, or 0, and the following are 1, 2, etc. in
#   order.
#
# Weather Types
#   1. Rain (Normal, Blood, Oil, Acid, Golden, Sepia)
#   2. Storm (Normal, Blood, Oil, Acid, Golden, Sepia)
#   3. Snow (Normal, Crimson)
#   4. Hail
#   5. Rain w/ thunder & lightning (Normal, Blood, Oil, Acid, Golden, Sepia)
#   6. Falling Leaves (Green, Yellow, Autumn, Red Maple)
#   7. Blowing Leaves (Green, Yellow, Autumn, Red Maple)
#   8. Swirling Leaves (Green, Yellow, Autumn, Red Maple)
#   9. Realistic Storm
#  10. Sakura Petals
#  11. Petals (Rose, Lavender, Tiger Lily, Pink, Blue, Green, Blue-Purple)
#  12. Feathers
#  13. Butterflies (Violet, Red, Yellow, Aqua-blue, Green)
#  14. Sparkles (Blue, Lavender, Pink, Green, White)
#  15. User Defined
#  16. Blowing Snow (Normal, Crimson)
#  17. Meteors (Normal, Flame, Rock)
#  18. Falling Ash
#  19. Bubbles
#  20. Bubbles 2
#  21. Sparkles (Up) (Blue, Lavender, Pink, Green, White)
#  22. Falling Rocks
#  23. Arrows
#  24. Starburst-Burst
#  25. Starburst-Up
#  26. Starburst-Rain
#  27. Monochromatic Starburst-Burst (Yellow, Green, Aqua-blue, Blue, Violet, Red)
#  28. Monochromatic Starburst-Up (same as above)
#  29. Monochromatic Starburst-Down (same as above)
#  30. Bombs (Water, Ice, Flare)
#  31. Birds
#  32. Bats
#  33. Bees
#  34. Fish
#  35. Ravens
#  36. Sunny
#  37. Sandstorm
#  38. Winds
#  39. legacy Rain
#  40. legacy Storm
#
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# BEGIN CONFIGURATION
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=

# WEATHER_TYPE_VARIABLE  = 0
# ID of game variable. Will be equal to the "type" of weather.

# ADVERSE_WEATHER_SWITCH = 0
# ID of the game switch. Will be true during bad weather. (see below)

# ADVERSE_WEATHER = [:Rain, :Storm, :Hail, :Thunder, :RealThunder, :Blizzard]
# Include any effects you wish. Adverse weather switch will be true when
# any of these weather patterns are occurring.

THUNDER_RATE = 6
# Adjust how constant the thunder is. Higher values will increase the delay
# between thunder strikes. Weather power will still effect the rate, but this
# will change the overall rate. 0 will result in constant, unending screen
# flashes. Not good for epileptics... :P

#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# END CONFIGURATION
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=

#-------------------------------------------------------------------------------
#  Weather Power:
#    An integer from 0-50.  0 = no weather, 50 = 500 sprites
#-------------------------------------------------------------------------------
#  Transition:
#    The number of frames to "transition" the weather in
#-------------------------------------------------------------------------------
#  Usage of user-defined weather:
#    Look at the following globals:
#-------------------------------------------------------------------------------
$WEATHER_UPDATE = false   # the $WEATHER_IMAGES array has changed, please update
$WEATHER_IMAGES = []      # the array of picture names to use
$WEATHER_X = 0            # the number of pixels the image should move horizontally (positive = right, negative = left)
$WEATHER_Y = 0            # the number of pixels the image should move vertically (positive = down, negative = up)
$WEATHER_FADE = 0         # how much the image should fade each update (0 = no fade, 255 = fade instantly)
$WEATHER_ANIMATED = false # whether or not the image should cycle through all the images
#-------------------------------------------------------------------------------

module RPG
  class Weather
    def initialize(viewport = nil)
      @sunvalue = 0
      @sun = 0
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = viewport.z + 1
      @sprites = []

      $game_screen = Game_Screen.new if $game_screen == nil
      @type = @max = @ox = @oy = @count = 0
      @current_pose, @info, @countarray = [], [], []

      (1..500).each { |i|
        sprite = Sprite.new(viewport)
        sprite.z = 1000
        sprite.visible = false
        sprite.opacity = 0
        @sprites.push(sprite)
        @current_pose.push(0)
        @info.push(rand(50))
        @countarray.push(rand(15))
      }
    end

    def dispose
      @sprites&.each { |sprite| sprite.dispose }

      @rain_bitmap&.dispose
      @storm_bitmap&.dispose
      @impact_bitmap&.dispose
      @meteor_bitmap&.dispose
      @hail_bitmap&.dispose
      @sakura_bitmap&.dispose
      @snow_bitmap&.dispose
      @bomb_bitmap&.dispose
      @arrow_bitmap&.dispose
      @fish_bitmap&.dispose
      @wind_bitmap&.dispose
      @leaf_bitmaps&.each { |image| image.dispose }
      @petal_bitmaps&.each { |image| image.dispose }
      @feather_bitmaps&.each { |image| image.dispose }
      @sparkle_bitmaps&.each { |image| image.dispose }
      @starburst_bitmaps&.each { |image| image.dispose }
      @monostarburst_bitmaps&.each { |image| image.dispose }
      @fallingrocks_bitmaps&.each { |image| image.dispose }
      @butterfly_bitmaps&.each { |image| image.dispose }
      @bird_bitmaps&.each { |image| image.dispose }
      @bat_bitmaps&.each { |image| image.dispose }
      @bee_bitmaps&.each { |image| image.dispose }
      @raven_bitmaps&.each { |image| image.dispose }
      @user_bitmaps&.each { |image| image.dispose }
      @sand_bitmaps&.each { |image| image.dispose }
      @rain_legacy_bitmaps&.each { |image| image.dispose }
      @storm_legacy_bitmaps&.each { |image| image.dispose }
      @snow_bitmaps&.each { |image| image.dispose }
      @ash_bitmaps&.each { |image| image.dispose }
      @bubble_bitmaps&.each { |image| image.dispose }
      @bubble2_bitmaps&.each { |image| image.dispose }

      @viewport.dispose

      $WEATHER_UPDATE = true
    end

    def double_bitmaps
      @rain_bitmap = double_bitmap(@rain_bitmap) if @rain_bitmap
      @storm_bitmap = double_bitmap(@storm_bitmap) if @storm_bitmap
      @impact_bitmap = double_bitmap(@impact_bitmap) if @impact_bitmap
      @meteor_bitmap = double_bitmap(@meteor_bitmap) if @meteor_bitmap
      @hail_bitmap = double_bitmap(@hail_bitmap) if @hail_bitmap
      @sakura_bitmap = double_bitmap(@sakura_bitmap) if @sakura_bitmap
      @snow_bitmap = double_bitmap(@snow_bitmap) if @snow_bitmap
      @bomb_bitmap = double_bitmap(@bomb_bitmap) if @bomb_bitmap
      @arrow_bitmap = double_bitmap(@arrow_bitmap) if @arrow_bitmap
      @fish_bitmap = double_bitmap(@fish_bitmap) if @fish_bitmap
      @wind_bitmap = double_bitmap(@wind_bitmap) if @wind_bitmap

      sets = [
        @leaf_bitmaps,
        @petal_bitmaps,
        @feather_bitmaps,
        @sparkle_bitmaps,
        @starburst_bitmaps,
        @monostarburst_bitmaps,
        @fallingrocks_bitmaps,
        @butterfly_bitmaps,
        @bird_bitmaps,
        @bat_bitmaps,
        @bee_bitmaps,
        @raven_bitmaps,
        @user_bitmaps,
        @sand_bitmaps,
        @rain_legacy_bitmaps,
        @storm_legacy_bitmaps,
        @snow_bitmaps,
        @ash_bitmaps,
        @bubble_bitmaps,
        @bubble2_bitmaps,
      ]
      sets.each do |bitmaps|
        next unless bitmaps
        bitmaps.each_with_index do |bitmap, i|
          bitmaps[i] = double_bitmap(bitmap)
        end
      end
    end

    def double_bitmap(bitmap)
      m = 2
      double = Bitmap.new(bitmap.width * m, bitmap.height * m)
      for x in 0...bitmap.width
        for y in 0...bitmap.height
          double.fill_rect(x * m, y * m, m, m, bitmap.get_pixel(x, y))
        end
      end
      return double
    end

    #-------------------------------------------------------------------------------
    def setWeatherType(type, variant, double_size)
      return if @type == type && @variant == variant && @double_size == double_size

      @type = type
      @variant = variant
      @double_size = double_size
      make_bitmaps(type, variant)
      double_bitmaps if double_size

      case @type
        when :Rain, :Thunder, :RealThunder                    # Rain, Thunder, Real Thunder
          bitmap = @rain_bitmap
        when :Storm                                           # Storm
          bitmap = @storm_bitmap
        when :Snow, :Blizzard, :SnowAlt, :BlizzardAlt         # Snow
          bitmap = @snow_bitmap
        when :Hail                                            # Hail
          bitmap = @hail_bitmap
        when :FallingLeaves, :BlowingLeaves, :SwirlingLeaves  # Leaves
          bitmap = @leaf_bitmaps
        when :SakuraPetals                                    # Sakura petals
          bitmap = @sakura_bitmap
        when :FlowerPetals                                    # Flower petals
          bitmap = @petal_bitmaps[0]
        when :Feathers                                        # Feathers
          bitmap = @feather_bitmaps[0]
        when :Butterflies                                     # Butterflies
          bitmap = @butterfly_bitmaps
        when :Sparkles, :SparklesUp                           # Sparkles, Sparkles up
          bitmap = @sparkle_bitmaps[0]
        when :UserDefined                                     # User-defined
          r = rand(@user_bitmaps.size)
          bitmap = @user_bitmaps[r]
        when :Meteors                                         # Meteors
          bitmap = @meteor_bitmap
        when :FallingAsh                                      # Falling ash
          bitmap = @ash_bitmaps[rand(2)]
        when :Bubbles                                         # Bubbles
          bitmap = @bubble_bitmaps[rand(2)]
        when :Bubbles2                                        # Bubbles 2
          bitmap = @bubble2_bitmaps[rand(4)]
        when :FallingRocks                                    # Falling rocks
          bitmap = @fallingrocks_bitmaps
        when :Arrows                                          # Arrows
          bitmap = @arrow_bitmap
        when :Starburst, :StarburstUp, :StarburstRain         # Starburst
          bitmap = @starburst_bitmaps[0]
        when :MonoBurst, :MonoUp, :MonoRain                   # Mono-starburst
          bitmap = @monostarburst_bitmaps[0]
        when :Bombs                                           # Bombs
          bitmap = @bomb_bitmap
        when :Birds                                           # Birds
          bitmap = @bird_bitmaps
        when :Bats                                            # Bats
          bitmap = @bat_bitmaps
        when :Bees                                            # Bees
          bitmap = @bee_bitmaps
        when :Fish                                            # Fish
          bitmap = @fish_bitmap
        when :Raven                                           # Ravens
          bitmap = @raven_bitmaps
        when :Sunny                                           # Sun

        when :Sandstorm                                       # Sandstorm
          bitmap = @sand_bitmaps
        when :Winds                                           # Winds
          bitmap = @wind_bitmap
        when :RainLegacy                                      # old Rain from Reborn
          bitmap = @rain_legacy_bitmaps
        when :StormLegacy                                     # old Storm from Reborn
          bitmap = @storm_legacy_bitmaps
        else # No weather
          @viewport.tone.set(0, 0, 0, 0)
          bitmap = nil
      end

      # Operates the Adverse Weather Switch and Weather Type Variable
      # WARNING: If you need this, don't just uncomment it, would need different switch/variable for each game.
      # if $game_switches != nil && $game_variables != nil
      #   $game_variables[WEATHER_TYPE_VARIABLE] = $game_screen.weather_type
      #   if ADVERSE_WEATHER.include?($game_screen.weather_type)
      #     $game_switches[ADVERSE_WEATHER_SWITCH] = true
      #   else
      #     $game_switches[ADVERSE_WEATHER_SWITCH] = false
      #   end
      # end

      (1..500).each { |i|
        sprite = @sprites[i]
        if sprite != nil
          sprite.visible = (i <= @max)
          if [:Snow, :SnowAlt].include?(@type)
            r = @info[i] = rand(4)
            sprite.bitmap = @snow_bitmaps[r]
          elsif @type == :FallingLeaves || @type == :BlowingLeaves || @type == :SwirlingLeaves
            @current_pose[i] = rand(13)
            sprite.bitmap = @leaf_bitmaps[@current_pose[i]]
          elsif @type == :Butterflies
            @current_pose[i] = rand(16)
            sprite.bitmap = @butterfly_bitmaps[@current_pose[i]]
          elsif @type == :Bubbles
            sprite.bitmap = @bubble_bitmaps[rand(2)]
          elsif @type == :Bubbles2
            sprite.bitmap = @bubble2_bitmaps[rand(4)]
          elsif @type == :FallingRocks
            r = @info[i] = rand(3)
            sprite.bitmap = @fallingrocks_bitmaps[r]
          elsif @type == :Birds
            @current_pose[i] = rand(4)
            sprite.bitmap = @bird_bitmaps[@current_pose[i]]
          elsif @type == :Bats
            @current_pose[i] = rand(16)
            sprite.bitmap = @bat_bitmaps[@current_pose[i]]
          elsif @type == :Bees
            @current_pose[i] = rand(16)
            sprite.bitmap = @bee_bitmaps[@current_pose[i]]
          elsif @type == :Fish
            @info[i] = rand(200)
            sprite.bitmap = bitmap
          elsif @type == :Raven
            @current_pose[i] = rand(16)
            sprite.bitmap = @raven_bitmaps[@current_pose[i]]
          elsif @type == :Sandstorm
            r = @info[i] = rand(2)
            sprite.bitmap = @sand_bitmaps[r]
          elsif @type == :Sunny
            sprite.bitmap = nil
          elsif @type == :RainLegacy
            @info[i] = rand(16)
            sprite.bitmap = @rain_legacy_bitmaps[0]
          elsif @type == :StormLegacy
            @info[i] = rand(16)
            sprite.bitmap = @storm_legacy_bitmaps[0]
          else
            sprite.bitmap = bitmap
          end
        end
      }
    end

    def ox=(ox)
      return if @ox == ox

      @ox = ox
      @sprites.each { |sprite| sprite.ox = @ox }
    end

    def oy=(oy)
      return if @oy == oy

      @oy = oy
      @sprites.each { |sprite| sprite.oy = @oy }
    end

    def max=(max)
      return if @max == max

      if @type == :Sunny
        @max = max.clamp(0, 40)
        if @max == 0
          for sprite in @sprites
            sprite.dispose
          end
          @sprites.clear
        else
          for i in 1..40
            sprite = @sprites[i]
            if sprite != nil
              sprite.visible = (i <= @max)
            end
          end
        end
        return
      end

      @max = max.clamp(0, 500)
      (1..500).each { |i|
        sprite = @sprites[i]
        sprite.visible = i <= @max if sprite != nil
      }
    end

    #-------------------------------------------------------------------------------
    def update
      if Desolation && $game_switches[:SpecialDarkness] && $PokemonTemp.darknessSprite != nil
        $PokemonTemp.darknessSprite.refresh
      end

      return if @type == 0

      if @type == :Sunny
        if $game_screen.tone_duration == 0
          unless @sun == @max || @sun == -@max
            @sun = @max
          end
          @sun = -@sun if @sunvalue > @max || @sunvalue < 0
          @sunvalue = @sunvalue + @sun / 32
          @viewport.tone.set(@sunvalue + 31, @sunvalue + 31, @sunvalue / 2 + 15, 0)
        elsif $cache.mapdata[$game_map.map_id].Outdoor
          totaltone = (($game_screen.tone.red + $game_screen.tone.green + $game_screen.tone.blue) / 3.0)
          @viewport.tone.set(
            (@sunvalue + 31) * ((255 + totaltone) / 255),
            (@sunvalue + 31) * ((255 + totaltone) / 255),
            (@sunvalue / 2 + 15) * ((255 + totaltone) / 255),
            0
          )
        end
        @viewport.update
        return
      end

      maxlimit = [@max, 20].min
      case @type
        when :Rain, :Thunder, :RealThunder, :RainLegacy # Rain
          @viewport.tone.set(-maxlimit * 3 / 4, -maxlimit * 3 / 4, -maxlimit * 3 / 4, 10)
        when :Storm, :StormLegacy # Storm
          @viewport.tone.set(-maxlimit * 6 / 4, -maxlimit * 6 / 4, -maxlimit * 6 / 4, 10)
        when :Snow, :Blizzard, :SnowAlt, :BlizzardAlt # Snow
          @viewport.tone.set(maxlimit / 2, maxlimit / 2, maxlimit / 2, 0)
        when :Hail # Hail
          @viewport.tone.set(maxlimit * 3 / 4, maxlimit * 3 / 4, maxlimit * 3 / 4, 0)
        else
          @viewport.tone.set(0, 0, 0, 0)
      end

      if @type == :StormLegacy && $Settings.photosensitive == 0
        rnd = rand(500)
        if rnd < 2
          $game_screen.start_flash(Color.new(255, 255, 255, 230), (rnd + 1) * 20)
        end
      end

      (1..@max).each { |i|
        sprite = @sprites[i]
        break if sprite == nil

        #----------------------------------------------------------------------
        if @type == :Rain || @type == :Thunder || @type == :RealThunder # Rain
          if sprite.opacity <= 150
            if @current_pose[i] == 0
              sprite.y += @rain_bitmap.height
              sprite.x -= @rain_bitmap.width - @rain_splash.width / 2
              sprite.bitmap = @rain_splash
              @current_pose[i] = 1
            end
          else
            sprite.x -= 2
            sprite.y += 16
            if @type == :Thunder && (rand((THUNDER_RATE * 2000) - @max) == 0) && $Settings.photosensitive == 0
              case $game_screen.weather_variation
                when 0, 2, 3, 4 # Normal, Acid, Oil, and Golden
                  $game_screen.start_flash(Color.new(255, 255, 255, 255), 5)
                when 1 # Blood
                  $game_screen.start_flash(Color.new(141, 9, 9, 255), 5)
                when 5 # Sepia
                  $game_screen.start_flash(Color.new(169, 152, 142, 255), 5)
              end
              # Audio.se_play('Audio/SE/061-Thunderclap01')
            end
          end
          sprite.opacity -= 8
        end
        if @type == :RealThunder && (rand((THUNDER_RATE * 2000) - @max) == 0) && $Settings.photosensitive == 0
          thundervolume = rand(50) + 50 # Random number 50-100
          thunderpitch = rand(100) + 50 # Random number 50-150
          #       Audio.se_play('Audio/SE/061-Thunderclap01', thundervolume, thunderpitch)
          # Screen will not flash or shake unless the volume and pitch are high
          if thundervolume > 75 && thunderpitch > 100
            $game_screen.start_flash(Color.new(255, 255, 255, 255), 7)
            $game_screen.start_shake(9, 7, 5)
          end
        end
        #----------------------------------------------------------------------
        if @type == :Storm # Storm
          sprite.x -= 8
          sprite.y += 16
          sprite.opacity -= 12
        end
        #----------------------------------------------------------------------
        if @type == :Snow # Snow
          case @info[i]
            when 0
              sprite.y += 1
            when 1
              sprite.y += 3
            when 2
              sprite.y += 5
            when 3
              sprite.y += 7
          end
          sprite.opacity -= 3
        end
        if @type == :SnowAlt # Alternative Snow for Reborn
          case @info[i]
            when 0, 1
              sprite.y += 2
            when 2
              sprite.y += 4
            when 3
              sprite.y += 6
          end
          sprite.opacity -= 3
        end
        #----------------------------------------------------------------------
        if @type == :Hail # Hail
          sprite.x -= 1
          sprite.y += 18
          sprite.opacity -= 15
        end
        #----------------------------------------------------------------------
        if @type == :FallingLeaves # Falling Leaves
          @count = rand(20)
          if @count == 0
            sprite.bitmap = @leaf_bitmaps[@current_pose[i]]
            @current_pose[i] = (@current_pose[i] + 1) % 13
          end
          sprite.y += 1
        end
        #----------------------------------------------------------------------
        if @type == :BlowingLeaves # Blowing Leaves
          @count = rand(20)
          if @count == 0
            sprite.bitmap = @leaf_bitmaps[@current_pose[i]]
            @current_pose[i] = (@current_pose[i] + 1) % 13
          end
          sprite.x -= 10
          sprite.y += rand(4)
        end
        #----------------------------------------------------------------------
        if @type == :SwirlingLeaves # Swirling Leaves
          @count = rand(20)
          if @count == 0
            sprite.bitmap = @leaf_bitmaps[@current_pose[i]]
            @current_pose[i] = (@current_pose[i] + 1) % 13
          end
          if @info[i] != 0
            if @info[i] >= 1 && @info[i] <= 10
              sprite.x -= 4
              sprite.y -= 2
            elsif @info[i] >= 11 && @info[i] <= 16
              sprite.x -= 2
              sprite.y -= 4
            elsif @info[i] >= 17 && @info[i] <= 20
              sprite.y -= 3
            elsif @info[i] >= 21 && @info[i] <= 30
              sprite.y -= 2
              sprite.x += 1
            elsif @info[i] >= 31 && @info[i] <= 36
              sprite.y -= 1
              sprite.x += 3
            elsif @info[i] >= 37 && @info[i] <= 40
              sprite.x += 5
            elsif @info[i] >= 41 && @info[i] <= 46
              sprite.y += 1
              sprite.x += 3
            elsif @info[i] >= 47 && @info[i] <= 58
              sprite.y += 2
              sprite.x += 1
            elsif @info[i] >= 59 && @info[i] <= 64
              sprite.y += 3
            elsif @info[i] >= 65 && @info[i] <= 70
              sprite.x -= 1
              sprite.y += 2
            elsif @info[i] >= 71 && @info[i] <= 81
              sprite.x -= 3
              sprite.y += 1
            elsif @info[i] >= 82 && @info[i] <= 87
              sprite.x -= 5
            end
            @info[i] = (@info[i] + 1) % 88
          else
            if rand(200) == 0
              @info[i] = 1
            end
            sprite.x -= 5
            sprite.y += 1
          end
        end
        #----------------------------------------------------------------------
        if @type == :SakuraPetals # Sakura Petals
          if @info[i] < 25
            sprite.x -= 1
          else
            sprite.x += 1
          end
          @info[i] = (@info[i] + 1) % 50
          sprite.y += 1
        end
        #----------------------------------------------------------------------
        if @type == :FlowerPetals # Flower Petals
          @count = rand(20)
          if @count == 0
            sprite.bitmap = @petal_bitmaps[@current_pose[i]]
            @current_pose[i] = (@current_pose[i] + 1) % @petal_bitmaps.size
          end
          if @info[i] % 2 == 0
            if @info[i] < 10
              sprite.x -= 1
            elsif sprite.x += 1
            end
          end
          sprite.y += 1
        end
        #----------------------------------------------------------------------
        if @type == :Feathers # Feathers
          if @countarray[i] == 0
            @current_pose[i] = (@current_pose[i] + 1) % @feather_bitmaps.size
            sprite.bitmap = @feather_bitmaps[@current_pose[i]]
          end
          @countarray[i] = (@countarray[i] + 1) % 15
          if rand(100) == 0
            sprite.x -= 1
          end
          if rand(100) == 0
            sprite.y -= 1
          end
          if @info[i] < 50
            if rand(2) == 0
              sprite.x -= 1
            else
              sprite.y -= 1
            end
          else
            if rand(2) == 0
              sprite.x += 1
            else
              sprite.y += 1
            end
          end
          @info[i] = (@info[i] + 1) % 100
        end
        #----------------------------------------------------------------------
        if @type == :Butterflies # Butterflies
          @count = (@count += 1) % 5
          @info[i] = rand(50)
          sprite.bitmap = @butterfly_bitmaps[@current_pose[i]]
          if @count == 0 || 3
            if @count == 0
              case @current_pose[i]
                when 0, 1, 2, 3
                  @current_pose[i] = (@current_pose[i] += 1) % 4
                when 4, 5, 6, 7
                  @current_pose[i] = ((@current_pose[i] += 1) % 4) + 4
                when 8, 9, 10, 11
                  @current_pose[i] = ((@current_pose[i] += 1) % 4) + 8
                when 12, 13, 14, 15
                  @current_pose[i] = ((@current_pose[i] += 1) % 4) + 12
              end
            end
            case @current_pose[i]
              when 0, 1, 2, 3
                sprite.y -= 1
                sprite.x -= 1 if @current_pose[i] == 0
                sprite.x += 1 if @current_pose[i] == 2
              when 4, 5, 6, 7
                sprite.y += 1
                sprite.x += 1 if @current_pose[i] == 4
                sprite.x -= 1 if @current_pose[i] == 6
              when 8, 9, 10, 11
                sprite.x -= 1
                sprite.y -= 1 if @current_pose[i] == 8
                sprite.y += 1 if @current_pose[i] == 10
              when 12, 13, 14, 15
                sprite.x += 1
                sprite.y -= 1 if @current_pose[i] == 12
                sprite.y += 1 if @current_pose[i] == 14
            end
            if @info[i] < 10
              @current_pose[i] = (@current_pose[i] += 1) % 16
            end
          end
        end
        #----------------------------------------------------------------------
        if @type == :Sparkles # Sparkles
          if @countarray[i] == 0
            @current_pose[i] = (@current_pose[i] + 1) % @sparkle_bitmaps.size
            sprite.bitmap = @sparkle_bitmaps[@current_pose[i]]
          end
          @countarray[i] = (@countarray[i] + 1) % 15
          sprite.y += 1
          sprite.opacity -= 1
        end
        #----------------------------------------------------------------------
        if @type == :UserDefined # User-Defined
          if $WEATHER_UPDATE
            update_user_defined
            $WEATHER_UPDATE = false
          end
          if $WEATHER_ANIMATED && @countarray[i] == 0
            @current_pose[i] = (@current_pose[i] + 1) % @user_bitmaps.size
            sprite.bitmap = @user_bitmaps[@current_pose[i]]
          end
          sprite.x += $WEATHER_X
          sprite.y += $WEATHER_Y
          sprite.opacity -= $WEATHER_FADE
        end
        #----------------------------------------------------------------------
        if [:Blizzard, :BlizzardAlt].include?(@type) # Blowing Snow
          sprite.x -= 10
          sprite.y += 6
          sprite.opacity -= 4
        end
        #----------------------------------------------------------------------
        if @type == :Meteors # Meteors
          if @countarray[i] > 0
            if rand(20) == 0
              sprite.bitmap = @impact_bitmap
              @countarray[i] = -5
            else
              sprite.x -= 6
              sprite.y += 10
            end
          else
            @countarray[i] += 1
            if @countarray[i] == 0
              sprite.bitmap = @meteor_bitmap
              sprite.opacity = 0
              @count_array = 1
            end
          end
        end
        #----------------------------------------------------------------------
        if @type == :FallingAsh # Ash
          sprite.y += 2
          x_increment = 1
          if @double_size
            x_increment = Graphics.frame_count.even? ? 2 : 0
          end
          case @countarray[i] % 3
            when 0
              sprite.x -= x_increment
            when 1
              sprite.x += x_increment
          end
        end
        #----------------------------------------------------------------------
        if @type == :Bubbles || @type == :Bubbles2 # Bubbles
          switch = rand(75) + rand(75) + 1
          if @info[i] < switch / 2
            sprite.x -= 1
          else
            sprite.x += 1
          end
          @info[i] = (@info[i] + 1) % switch
          sprite.y -= 1
          if switch % 2 == 0
            sprite.opacity -= 1
          end
        end
        #----------------------------------------------------------------------
        if @type == :SparklesUp # Sparkles Up
          if @countarray[i] == 0
            @current_pose[i] = (@current_pose[i] + 1) % @sparkle_bitmaps.size
            sprite.bitmap = @sparkle_bitmaps[@current_pose[i]]
          end
          @countarray[i] = (@countarray[i] + 1) % 15
          sprite.y -= 1
          sprite.opacity -= 1
        end
        #----------------------------------------------------------------------
        if @type == :FallingRocks # Falling Rocks
          case @info[i]
            when 0 # large
              sprite.y += 10
            when 1 # small
              sprite.y += 5
            when 2 # mid-size
              sprite.y += 7
          end
          sprite.opacity -= 1
        end
        #----------------------------------------------------------------------
        if @type == :Arrows # Arrows
          sprite.y += 10
          sprite.x -= 7
        end
        #----------------------------------------------------------------------
        if @type == :Starburst # Starburst
          if @countarray[i] == 0
            @current_pose[i] = (@current_pose[i] + 1) % @starburst_bitmaps.size
            sprite.bitmap = @starburst_bitmaps[@current_pose[i]]
          end
          @countarray[i] = (@countarray[i] + 1) % 15
          sprite.y += 1
          sprite.opacity -= 1
        end
        #----------------------------------------------------------------------
        if @type == :StarburstUp # Starburst up
          if @countarray[i] == 0
            @current_pose[i] = (@current_pose[i] + 1) % @starburst_bitmaps.size
            sprite.bitmap = @starburst_bitmaps[@current_pose[i]]
          end
          @countarray[i] = (@countarray[i] + 1) % 15
          sprite.y -= 1
          sprite.opacity -= 1
        end
        #----------------------------------------------------------------------
        if @type == :StarburstRain # Starburst Rain
          if @countarray[i] == 0
            @current_pose[i] = (@current_pose[i] + 1) % @starburst_bitmaps.size
            sprite.bitmap = @starburst_bitmaps[@current_pose[i]]
          end
          @countarray[i] = (@countarray[i] + 1) % 15
          sprite.x -= 2
          sprite.y += 8
          sprite.opacity -= 1
        end
        #----------------------------------------------------------------------
        if @type == :MonoBurst # Monochromatic Starburst
          if @countarray[i] == 0
            @current_pose[i] = (@current_pose[i] + 1) % @monostarburst_bitmaps.size
            sprite.bitmap = @monostarburst_bitmaps[@current_pose[i]]
          end
          @countarray[i] = (@countarray[i] + 1) % 15
          sprite.y += 1
          sprite.opacity -= 1
        end
        #----------------------------------------------------------------------
        if @type == :MonoUp # Monochromatic Starburst Up
          if @countarray[i] == 0
            @current_pose[i] = (@current_pose[i] + 1) % @monostarburst_bitmaps.size
            sprite.bitmap = @monostarburst_bitmaps[@current_pose[i]]
          end
          @countarray[i] = (@countarray[i] + 1) % 15
          sprite.y -= 1
          sprite.opacity -= 1
        end
        #----------------------------------------------------------------------
        if @type == :MonoRain # Monochromatic Starburst Rain
          if @countarray[i] == 0
            @current_pose[i] = (@current_pose[i] + 1) % @monostarburst_bitmaps.size
            sprite.bitmap = @monostarburst_bitmaps[@current_pose[i]]
          end
          @countarray[i] = (@countarray[i] + 1) % 15
          sprite.x -= 2
          sprite.y += 8
          sprite.opacity -= 1
        end
        #----------------------------------------------------------------------
        if @type == :Bombs # Bombs
          if @countarray[i] > 0
            if rand(20) == 0
              sprite.bitmap = @bomb_impact_bitmap
              @countarray[i] = -5
            else
              sprite.x -= 3
              sprite.y += 5
            end
          else
            @countarray[i] += 1
            if @countarray[i] == 0
              sprite.bitmap = @bomb_bitmap
              sprite.opacity = 0
              @count_array = 1
            end
          end
        end
        #----------------------------------------------------------------------
        if @type == :Birds # Birds
          @count = (@count += 1) % 5
          if @count == 0
            @current_pose[i] = (@current_pose[i] += 1) % 4
          end
          sprite.bitmap = @bird_bitmaps[@current_pose[i]]
          sprite.x -= rand(2) + 3
          sprite.y -= 1 if @info[i].between?(0, 20)
          sprite.y += 1 if @info[i].between?(20, 40)
          sprite.y -= 1 if @info[i].between?(40, 70)
          sprite.y += 1 if @info[i].between?(70, 120)
          @info[i] = (@info[i] += 1) % 120
        end
        #----------------------------------------------------------------------
        if @type == :Bats || @type == :Bees # Bats and Bees
          @count = (@count += 1) % 5
          sprite.bitmap = @bat_bitmaps[@current_pose[i]] if @type == :Bats
          sprite.bitmap = @bee_bitmaps[@current_pose[i]] if @type == :Bees
          if @count == 0 || 3
            if @count == 0
              case @current_pose[i]
                when 0, 1, 2, 3       # Left
                  @current_pose[i] = (@current_pose[i] += 1) % 4
                when 4, 5, 6, 7       # Up
                  @current_pose[i] = ((@current_pose[i] += 1) % 4) + 4
                when 8, 9, 10, 11     # Right
                  @current_pose[i] = ((@current_pose[i] += 1) % 4) + 8
                when 12, 13, 14, 15   # Down
                  @current_pose[i] = ((@current_pose[i] += 1) % 4) + 12
              end
            end
            @info[i] = rand(50)
            case @current_pose[i]
              when 0, 1, 2, 3
                sprite.x -= 4
                sprite.y += 3 if @info[i] <= 35
                sprite.y -= 3 if @info[i] > 35
              when 4, 5, 6, 7
                sprite.y -= 4
                sprite.x += 3 if @info[i] <= 40
                sprite.x -= 3 if @info[i] > 40
              when 8, 9, 10, 11
                sprite.x += 4
                sprite.y += 3 if @info[i] <= 15
                sprite.y -= 3 if @info[i] > 15
              when 12, 13, 14, 15
                sprite.y += 4
                sprite.x += 3 if @info[i] <= 25
                sprite.x -= 3 if @info[i] > 25
            end
            if @info[i] < 10
              @current_pose[i] = (@current_pose[i] += 1) % 16
            end
          end
        end
        #----------------------------------------------------------------------
        if @type == :Fish # Fish
          @info[i] = (@info[i] += 1) % 200
          sprite.x -= rand(2) + 1
          sprite.x -= 3 if @info[i] >= 180
          sprite.y -= 1 if @info[i] < 75
          sprite.y += 1 if @info[i].between?(75, 150)
        end
        #----------------------------------------------------------------------
        if @type == :Raven # Ravens
          @count = (@count += 1) % 5
          sprite.bitmap = @raven_bitmaps[@current_pose[i]]
          if @count == 0 || 3
            if @count == 0
              case @current_pose[i]
                when 0, 1, 2, 3       # Left
                  @current_pose[i] = (@current_pose[i] += 1) % 4
                when 4, 5, 6, 7       # Up
                  @current_pose[i] = ((@current_pose[i] += 1) % 4) + 4
                when 8, 9, 10, 11     # Right
                  @current_pose[i] = ((@current_pose[i] += 1) % 4) + 8
                when 12, 13, 14, 15   # Down
                  @current_pose[i] = ((@current_pose[i] += 1) % 4) + 12
              end
            end
            @info[i] = rand(50)
            case @current_pose[i]
              when 0, 1, 2, 3
                sprite.x -= 2
                sprite.y += 1 if @info[i] <= 35
                sprite.y -= 1 if @info[i] > 35
              when 4, 5, 6, 7
                sprite.y -= 2
                sprite.x += 1 if @info[i] <= 40
                sprite.x -= 1 if @info[i] > 40
              when 8, 9, 10, 11
                sprite.x += 2
                sprite.y += 1 if @info[i] <= 15
                sprite.y -= 1 if @info[i] > 15
              when 12, 13, 14, 15
                sprite.y += 2
                sprite.x += 1 if @info[i] <= 25
                sprite.x -= 1 if @info[i] > 25
            end
            if @info[i] < 5
              @current_pose[i] = (@current_pose[i] += 1) % 16
            end
          end
        end
        #----------------------------------------------------------------------
        if @type == :Sandstorm # Sandstorm
          sprite.x += 12
          sprite.y += -4
          sprite.opacity -= 2
          @viewport.tone.set(@max / 2, 0, -@max / 2, 0)
        end
        #----------------------------------------------------------------------
        if @type == :Winds # Winds
          sprite.x += 4
          sprite.y += 1
        end
        #----------------------------------------------------------------------
        if @type == :RainLegacy # old Rain from Reborn
          sprite.bitmap = @rain_legacy_bitmaps[@current_pose[i]]
          if @current_pose[i] == 0
            sprite.x += -10
            sprite.y += 40
          end
          if @current_pose[i] == 0 && @countarray[i] > @info[i]
            @current_pose[i] = 1
            @countarray[i] = 0
          end
          if @current_pose[i] == 1 && @countarray[i] == 3
            @current_pose[i] = 2
            @countarray[i] = 0
          end
          if @current_pose[i] == 2 && @countarray[i] == 2
            @current_pose[i] = 3
            @countarray[i] = 0
          end
          if @current_pose[i] == 3 && @countarray[i] == 3
            @current_pose[i] = 0
            sprite.opacity = 0
            @countarray[i] = 0
            @info[i] = rand(16)
          end
          @countarray[i] += 1
        end
        #----------------------------------------------------------------------
        if @type == :StormLegacy # old Storm from Reborn
          sprite.bitmap = @storm_legacy_bitmaps[@current_pose[i]]
          if @current_pose[i] == 0
            sprite.x += -40
            sprite.y += 40
          end
          if @current_pose[i] == 0 && @countarray[i] > @info[i]
            @current_pose[i] = 1
            @countarray[i] = 0
          end
          if @current_pose[i] == 1 && @countarray[i] == 3
            @current_pose[i] = 2
            @countarray[i] = 0
          end
          if @current_pose[i] == 2 && @countarray[i] == 2
            @current_pose[i] = 3
            @countarray[i] = 0
          end
          if @current_pose[i] == 3 && @countarray[i] == 3
            @current_pose[i] = 0
            sprite.opacity = 0
            @countarray[i] = 0
            @info[i] = rand(16)
          end
          @countarray[i] += 1
        end

        #----------------------------------------------------------------------
        # Reset off-screen sprites back
        w = Graphics.width
        h = Graphics.height
        minx = -w / 4
        miny = -h / 4
        maxx = w - minx
        maxy = h - miny
        x = sprite.x - @ox
        y = sprite.y - @oy
        if sprite.bitmap
          if [:RainLegacy, :StormLegacy].include?(@type)
            if sprite.opacity == 0 # Only check for the sprite vanishing
              sprite.x = @ox + rand(w + sprite.bitmap.width * 2).to_grid
              sprite.y = @oy - sprite.bitmap.height # Fall from the top of the screen
              sprite.opacity = 255
            end
          else
            if sprite.opacity < 64 || x < minx || x > maxx || y < miny || y > maxy
              sprite.x = @ox - (sprite.bitmap.width / 2).to_grid + rand(w + w / 2).to_grid - w / 4
              sprite.y = @oy - (sprite.bitmap.height / 2).to_grid + rand(h + h / 2).to_grid - h / 4
              sprite.opacity = 255
              case @type
                when :Sandstorm
                  sprite.mirror = rand(2) == 0
                when :Rain, :Thunder, :RealThunder
                  sprite.bitmap = @rain_bitmap
                  @current_pose[i] = 0
              end
            end
          end
        end
        pbDayNightTint(sprite)
      }
    end

    #-------------------------------------------------------------------------------
    def make_bitmaps(weather, variant)
      # All the colors for each type are used only for their respective bitmaps
      # now, therefore the colors can be changed for one type without worrying
      # about messing up another that shares that color.

      #-------------------------------------------------------------------------------
      # Rain Bitmap
      if [:Rain, :Thunder, :RealThunder].include?(weather)
        @rain_bitmap = Bitmap.new(7, 56)
        rain_color = case variant
                       when 1 then Color.new(141, 9, 9)            # Blood Rain
                       when 2 then Color.new(15, 15, 15)           # Oil Rain
                       when 3 then Color.new(76, 91, 43)           # Acid Rain
                       when 4 then Color.new(218, 207, 36)         # Golden Rain
                       when 5 then Color.new(100, 75, 63)          # Sepia Rain
                       else
                         Color.new(255, 255, 255) # Normal
                     end

        (0..6).each { |i| @rain_bitmap.fill_rect(6 - i, i * 8, 1, 8, rain_color) }
      end
      #-------------------------------------------------------------------------------
      # Storm Bitmap
      if weather == :Storm
        @storm_bitmap = Bitmap.new(34, 64)
        case variant
          when 1 # Blood
            storm_color1 = Color.new(141, 9, 9)
            storm_color2 = Color.new(141, 9, 9, 128)
          when 2 # Oil
            storm_color1 = Color.new(15, 15, 15)
            storm_color2 = Color.new(15, 15, 15, 128)
          when 3 # Acid
            storm_color1 = Color.new(227, 217, 56)
            storm_color2 = Color.new(218, 207, 36)
          when 4 # Golden
            storm_color1 = Color.new(227, 217, 56)
            storm_color2 = Color.new(218, 207, 36)
          when 5 # Sepia
            storm_color1 = Color.new(167, 149, 139)
            storm_color2 = Color.new(100, 75, 63)
          else # Normal, Realistic (Default)
            storm_color1 = Color.new(255, 255, 255)
            storm_color2 = Color.new(255, 255, 255, 128)
        end

        (0..31).each { |i|
          @storm_bitmap.fill_rect(33 - i, i * 2, 1, 2, storm_color2)
          @storm_bitmap.fill_rect(32 - i, i * 2, 1, 2, storm_color1)
          @storm_bitmap.fill_rect(31 - i, i * 2, 1, 2, storm_color2)
        }
      end
      #-------------------------------------------------------------------------------
      # Splash Bitmap
      if [:Rain, :Thunder, :RealThunder].include?(weather)
        @rain_splash = Bitmap.new(8, 5)
        case variant
          when 1 # Blood splash
            splash_color1 = Color.new(141, 9, 9)
            splash_color2 = Color.new(141, 9, 9, 128)
          when 2 # Oil splash
            splash_color1 = Color.new(0, 0, 0)
            splash_color2 = Color.new(15, 15, 15)
          when 4 # Golden splash
            splash_color1 = Color.new(227, 217, 56)
            splash_color2 = Color.new(218, 207, 36)
          when 5 # Sepia splash
            splash_color1 = Color.new(167, 149, 139)
            splash_color2 = Color.new(100, 75, 63)
          else # Normal (Default)
            splash_color1 = Color.new(255, 255, 255)
            splash_color2 = Color.new(255, 255, 255, 128)
        end

        @rain_splash.fill_rect(1, 0, 6, 1, splash_color2)
        @rain_splash.fill_rect(1, 4, 6, 1, splash_color2)
        @rain_splash.fill_rect(0, 1, 1, 3, splash_color2)
        @rain_splash.fill_rect(7, 1, 1, 3, splash_color2)
        @rain_splash.set_pixel(1, 0, splash_color1)
        @rain_splash.set_pixel(0, 1, splash_color1)
      end
      #-------------------------------------------------------------------------------
      # Snow Bitmaps
      if [:Snow, :Blizzard, :SnowAlt, :BlizzardAlt].include?(weather)
        case variant
          when 1 # Crimson
            snow_color1 = Color.new(141, 9, 9)
            snow_color2 = Color.new(141, 9, 9, 128)
            snow_color3 = Color.new(141, 9, 9, 204)
          else # Normal (Default)
            snow_color1 = Color.new(255, 255, 255)
            snow_color2 = Color.new(255, 255, 255, 128)
            snow_color3 = Color.new(255, 255, 255, 204)
        end

        case weather
          # Used for Blowing Snow
          when :Blizzard
            @snow_bitmap = Bitmap.new(6, 6)
            @snow_bitmap.fill_rect(0, 1, 6, 4, snow_color2)
            @snow_bitmap.fill_rect(1, 0, 4, 6, snow_color2)
            @snow_bitmap.fill_rect(1, 2, 4, 2, snow_color1)
            @snow_bitmap.fill_rect(2, 1, 2, 4, snow_color1)
          when :BlizzardAlt
            @snow_bitmap = Bitmap.new(4, 4)
            @snow_bitmap.fill_rect(1, 0, 2, 4, snow_color2)
            @snow_bitmap.fill_rect(0, 1, 4, 2, snow_color2)
            @snow_bitmap.fill_rect(1, 1, 2, 2, snow_color1)
          # Used for Falling Snow
          when :Snow
            @snow_bitmaps = []
            @snow_bitmaps[0] = Bitmap.new(3, 3)
            @snow_bitmaps[0].fill_rect(0, 0, 3, 3, snow_color2)
            @snow_bitmaps[0].fill_rect(0, 1, 3, 1, snow_color3)
            @snow_bitmaps[0].fill_rect(1, 0, 1, 3, snow_color3)
            @snow_bitmaps[0].set_pixel(1, 1, snow_color1)

            @snow_bitmaps[1] = Bitmap.new(4, 4)
            @snow_bitmaps[1].fill_rect(0, 1, 4, 2, snow_color2)
            @snow_bitmaps[1].fill_rect(1, 0, 2, 4, snow_color2)
            @snow_bitmaps[1].fill_rect(1, 1, 2, 2, snow_color1)

            @snow_bitmaps[2] = Bitmap.new(5, 5)
            @snow_bitmaps[2].fill_rect(0, 1, 5, 3, snow_color3)
            @snow_bitmaps[2].fill_rect(1, 0, 3, 5, snow_color3)
            @snow_bitmaps[2].fill_rect(1, 1, 3, 3, snow_color2)
            @snow_bitmaps[2].fill_rect(2, 1, 3, 1, snow_color1)
            @snow_bitmaps[2].fill_rect(1, 2, 1, 3, snow_color1)

            @snow_bitmaps[3] = Bitmap.new(7, 7)
            @snow_bitmaps[3].fill_rect(1, 1, 5, 5, snow_color3)
            @snow_bitmaps[3].fill_rect(2, 0, 7, 3, snow_color3)
            @snow_bitmaps[3].fill_rect(0, 2, 3, 7, snow_color3)
            @snow_bitmaps[3].fill_rect(2, 1, 5, 3, snow_color2)
            @snow_bitmaps[3].fill_rect(1, 2, 3, 5, snow_color2)
            @snow_bitmaps[3].fill_rect(2, 2, 3, 3, snow_color1)
            @snow_bitmaps[3].fill_rect(3, 1, 5, 1, snow_color1)
            @snow_bitmaps[3].fill_rect(1, 3, 1, 5, snow_color1)
          when :SnowAlt
            @snow_bitmaps = []
            @snow_bitmaps[0] = Bitmap.new(3, 3)
            @snow_bitmaps[0].fill_rect(0, 0, 3, 3, snow_color2)
            @snow_bitmaps[0].fill_rect(0, 1, 3, 1, snow_color3)
            @snow_bitmaps[0].fill_rect(1, 0, 1, 3, snow_color3)
            @snow_bitmaps[0].set_pixel(1, 1, snow_color1)

            @snow_bitmaps[1] = Bitmap.new(3, 3)
            @snow_bitmaps[1].fill_rect(1, 0, 2, 1, snow_color1)
            @snow_bitmaps[1].fill_rect(0, 1, 2, 1, snow_color1)
            @snow_bitmaps[1].set_pixel(0, 2, snow_color1)
            @snow_bitmaps[1].set_pixel(2, 1, snow_color2)
            @snow_bitmaps[1].set_pixel(1, 2, snow_color2)

            @snow_bitmaps[2] = Bitmap.new(4, 4)
            @snow_bitmaps[2].fill_rect(0, 1, 1, 3, snow_color1)
            @snow_bitmaps[2].fill_rect(1, 0, 3, 1, snow_color1)
            @snow_bitmaps[2].fill_rect(1, 1, 2, 2, snow_color2)
            @snow_bitmaps[2].fill_rect(3, 1, 1, 2, snow_color3)
            @snow_bitmaps[2].fill_rect(1, 3, 2, 1, snow_color3)

            @snow_bitmaps[3] = Bitmap.new(4, 4)
            @snow_bitmaps[3].fill_rect(2, 1, 2, 1, snow_color1)
            @snow_bitmaps[3].fill_rect(1, 2, 1, 2, snow_color1)
            @snow_bitmaps[3].fill_rect(2, 0, 2, 1, snow_color2)
            @snow_bitmaps[3].fill_rect(0, 2, 1, 2, snow_color2)
            @snow_bitmaps[3].set_pixel(1, 1, snow_color2)
            @snow_bitmaps[3].set_pixel(2, 2, snow_color2)
            @snow_bitmaps[3].set_pixel(3, 2, snow_color3)
            @snow_bitmaps[3].set_pixel(2, 3, snow_color3)
        end
      end
      #-------------------------------------------------------------------------------
      # Hail
      if weather == :Hail
        hail_color1 = Color.new(215, 227, 227, 150)
        hail_color2 = Color.new(214, 217, 217, 150)
        hail_color3 = Color.new(233, 233, 233, 250)
        hail_color4 = Color.new(222, 239, 243, 250)

        @hail_bitmap = Bitmap.new(4, 4)
        @hail_bitmap.fill_rect(1, 0, 2, 1, hail_color1)
        @hail_bitmap.fill_rect(0, 1, 1, 2, hail_color1)
        @hail_bitmap.fill_rect(3, 1, 1, 2, hail_color2)
        @hail_bitmap.fill_rect(1, 3, 2, 1, hail_color2)
        @hail_bitmap.fill_rect(1, 1, 2, 2, hail_color3)
        @hail_bitmap.set_pixel(1, 1, hail_color4)
      end
      #-------------------------------------------------------------------------------
      # Sakura Petals
      if weather == :SakuraPetals
        sakura_color1 = Color.new(255, 167, 192, 255)
        sakura_color2 = Color.new(213, 106, 136, 255)

        @sakura_bitmap = Bitmap.new(4, 4)
        @sakura_bitmap.fill_rect(0, 3, 1, 1, sakura_color1)
        @sakura_bitmap.fill_rect(1, 2, 1, 1, sakura_color1)
        @sakura_bitmap.fill_rect(2, 1, 1, 1, sakura_color1)
        @sakura_bitmap.fill_rect(3, 0, 1, 1, sakura_color1)
        @sakura_bitmap.fill_rect(1, 3, 1, 1, sakura_color2)
        @sakura_bitmap.fill_rect(2, 2, 1, 1, sakura_color2)
        @sakura_bitmap.fill_rect(3, 1, 1, 1, sakura_color2)
      end
      #-------------------------------------------------------------------------------
      # Leaf Bitmaps
      if [:FallingLeaves, :BlowingLeaves, :SwirlingLeaves].include?(weather)
        @leaf_bitmaps = []
        case variant
          when 1 # Yellow
            leaf_color1 = Color.new(110, 104, 3)
            leaf_color2 = Color.new(205, 194, 23)
            leaf_color3 = Color.new(186, 176, 14)
            leaf_color4 = Color.new(218, 207, 36)
            leaf_color5 = Color.new(227, 217, 56)
          when 2 # Autumn
            leaf_color1 = Color.new(248, 88, 0)
            leaf_color2 = Color.new(144, 80, 56)
            leaf_color3 = Color.new(152, 0, 0)
            leaf_color4 = Color.new(232, 160, 128)
            leaf_color5 = Color.new(72, 40, 0)
          when 3 # Red Maple
            leaf_color1 = Color.new(255, 0, 0)
            leaf_color2 = Color.new(179, 17, 17)
            leaf_color3 = Color.new(141, 9, 9)
            leaf_color4 = Color.new(179, 17, 17)
            leaf_color5 = Color.new(141, 9, 9)
          else # Green (Default)
            leaf_color1 = Color.new(62, 76, 31)
            leaf_color2 = Color.new(76, 91, 43)
            leaf_color3 = Color.new(105, 114, 66)
            leaf_color4 = Color.new(128, 136, 88)
            leaf_color5 = Color.new(146, 154, 106)
        end

        # 1st leaf bitmap
        @leaf_bitmaps[0] = Bitmap.new(16, 16)
        @leaf_bitmaps[0].set_pixel(1, 0, leaf_color1)
        @leaf_bitmaps[0].set_pixel(1, 1, leaf_color2)
        @leaf_bitmaps[0].set_pixel(2, 1, leaf_color1)
        @leaf_bitmaps[0].set_pixel(2, 2, leaf_color3)
        @leaf_bitmaps[0].set_pixel(3, 2, leaf_color1)
        @leaf_bitmaps[0].set_pixel(4, 2, leaf_color3)
        @leaf_bitmaps[0].fill_rect(2, 3, 3, 1, leaf_color2)
        @leaf_bitmaps[0].set_pixel(5, 3, leaf_color3)
        @leaf_bitmaps[0].fill_rect(2, 4, 2, 1, leaf_color2)
        @leaf_bitmaps[0].set_pixel(4, 4, leaf_color1)
        @leaf_bitmaps[0].set_pixel(5, 4, leaf_color4)
        @leaf_bitmaps[0].set_pixel(6, 4, leaf_color3)
        @leaf_bitmaps[0].set_pixel(3, 5, leaf_color2)
        @leaf_bitmaps[0].set_pixel(4, 5, leaf_color1)
        @leaf_bitmaps[0].set_pixel(5, 5, leaf_color3)
        @leaf_bitmaps[0].set_pixel(6, 5, leaf_color4)
        @leaf_bitmaps[0].set_pixel(4, 6, leaf_color2)
        @leaf_bitmaps[0].set_pixel(5, 6, leaf_color1)
        @leaf_bitmaps[0].set_pixel(6, 6, leaf_color4)
        @leaf_bitmaps[0].set_pixel(6, 7, leaf_color3)

        # 2nd leaf bitmap
        @leaf_bitmaps[1] = Bitmap.new(16, 16)
        @leaf_bitmaps[1].fill_rect(1, 1, 1, 2, leaf_color2)
        @leaf_bitmaps[1].fill_rect(2, 2, 2, 1, leaf_color3)
        @leaf_bitmaps[1].set_pixel(4, 2, leaf_color4)
        @leaf_bitmaps[1].fill_rect(2, 3, 2, 1, leaf_color1)
        @leaf_bitmaps[1].fill_rect(4, 3, 2, 1, leaf_color4)
        @leaf_bitmaps[1].set_pixel(2, 4, leaf_color2)
        @leaf_bitmaps[1].set_pixel(3, 4, leaf_color1)
        @leaf_bitmaps[1].set_pixel(4, 4, leaf_color3)
        @leaf_bitmaps[1].fill_rect(5, 4, 2, 1, leaf_color4)
        @leaf_bitmaps[1].set_pixel(3, 5, leaf_color2)
        @leaf_bitmaps[1].set_pixel(4, 5, leaf_color1)
        @leaf_bitmaps[1].set_pixel(5, 5, leaf_color3)
        @leaf_bitmaps[1].set_pixel(6, 5, leaf_color4)
        @leaf_bitmaps[1].set_pixel(5, 6, leaf_color1)
        @leaf_bitmaps[1].fill_rect(6, 6, 2, 1, leaf_color3)

        # 3rd leaf bitmap
        @leaf_bitmaps[2] = Bitmap.new(16, 16)
        @leaf_bitmaps[2].set_pixel(1, 1, leaf_color1)
        @leaf_bitmaps[2].fill_rect(1, 2, 2, 1, leaf_color2)
        @leaf_bitmaps[2].set_pixel(2, 3, leaf_color2)
        @leaf_bitmaps[2].set_pixel(3, 3, leaf_color1)
        @leaf_bitmaps[2].set_pixel(4, 3, leaf_color2)
        @leaf_bitmaps[2].fill_rect(2, 4, 2, 1, leaf_color2)
        @leaf_bitmaps[2].set_pixel(4, 4, leaf_color1)
        @leaf_bitmaps[2].set_pixel(5, 4, leaf_color4)
        @leaf_bitmaps[2].set_pixel(3, 5, leaf_color2)
        @leaf_bitmaps[2].set_pixel(4, 5, leaf_color1)
        @leaf_bitmaps[2].fill_rect(5, 5, 2, 1, leaf_color3)
        @leaf_bitmaps[2].fill_rect(4, 6, 2, 1, leaf_color2)
        @leaf_bitmaps[2].set_pixel(6, 6, leaf_color4)
        @leaf_bitmaps[2].set_pixel(6, 7, leaf_color3)

        # 4th leaf bitmap
        @leaf_bitmaps[3] = Bitmap.new(16, 16)
        @leaf_bitmaps[3].fill_rect(0, 3, 1, 2, leaf_color1)
        @leaf_bitmaps[3].set_pixel(1, 4, leaf_color2)
        @leaf_bitmaps[3].set_pixel(2, 4, leaf_color3)
        @leaf_bitmaps[3].set_pixel(3, 4, leaf_color4)
        @leaf_bitmaps[3].set_pixel(4, 4, leaf_color1)
        @leaf_bitmaps[3].set_pixel(7, 4, leaf_color2)
        @leaf_bitmaps[3].set_pixel(1, 5, leaf_color1)
        @leaf_bitmaps[3].set_pixel(2, 5, leaf_color2)
        @leaf_bitmaps[3].set_pixel(3, 5, leaf_color4)
        @leaf_bitmaps[3].set_pixel(4, 5, leaf_color5)
        @leaf_bitmaps[3].set_pixel(5, 5, leaf_color4)
        @leaf_bitmaps[3].set_pixel(6, 5, leaf_color3)
        @leaf_bitmaps[3].set_pixel(7, 5, leaf_color2)
        @leaf_bitmaps[3].fill_rect(2, 6, 2, 1, leaf_color2)
        @leaf_bitmaps[3].set_pixel(4, 6, leaf_color4)
        @leaf_bitmaps[3].set_pixel(5, 6, leaf_color3)
        @leaf_bitmaps[3].set_pixel(6, 6, leaf_color2)

        # 5th leaf bitmap
        @leaf_bitmaps[4] = Bitmap.new(16, 16)
        @leaf_bitmaps[4].set_pixel(6, 2, leaf_color2)
        @leaf_bitmaps[4].set_pixel(7, 2, leaf_color1)
        @leaf_bitmaps[4].fill_rect(4, 3, 2, 1, leaf_color2)
        @leaf_bitmaps[4].set_pixel(6, 3, leaf_color3)
        @leaf_bitmaps[4].set_pixel(2, 4, leaf_color1)
        @leaf_bitmaps[4].fill_rect(3, 4, 2, 1, leaf_color3)
        @leaf_bitmaps[4].set_pixel(5, 4, leaf_color4)
        @leaf_bitmaps[4].set_pixel(6, 4, leaf_color3)
        @leaf_bitmaps[4].set_pixel(1, 5, leaf_color2)
        @leaf_bitmaps[4].set_pixel(2, 5, leaf_color3)
        @leaf_bitmaps[4].set_pixel(3, 5, leaf_color4)
        @leaf_bitmaps[4].set_pixel(4, 5, leaf_color5)
        @leaf_bitmaps[4].set_pixel(5, 5, leaf_color2)
        @leaf_bitmaps[4].set_pixel(2, 6, leaf_color1)
        @leaf_bitmaps[4].fill_rect(3, 6, 2, 1, leaf_color2)

        # 6th leaf bitmap
        @leaf_bitmaps[5] = Bitmap.new(16, 16)
        @leaf_bitmaps[5].fill_rect(6, 2, 2, 1, leaf_color2)
        @leaf_bitmaps[5].fill_rect(4, 3, 2, 1, leaf_color2)
        @leaf_bitmaps[5].set_pixel(6, 3, leaf_color3)
        @leaf_bitmaps[5].set_pixel(3, 4, leaf_color2)
        @leaf_bitmaps[5].set_pixel(4, 4, leaf_color3)
        @leaf_bitmaps[5].set_pixel(5, 4, leaf_color4)
        @leaf_bitmaps[5].set_pixel(6, 4, leaf_color5)
        @leaf_bitmaps[5].set_pixel(1, 5, leaf_color2)
        @leaf_bitmaps[5].set_pixel(2, 5, leaf_color3)
        @leaf_bitmaps[5].fill_rect(3, 5, 2, 1, leaf_color5)
        @leaf_bitmaps[5].set_pixel(5, 5, leaf_color4)
        @leaf_bitmaps[5].set_pixel(2, 6, leaf_color2)
        @leaf_bitmaps[5].set_pixel(3, 6, leaf_color3)
        @leaf_bitmaps[5].set_pixel(4, 6, leaf_color4)

        # 7th leaf bitmap
        @leaf_bitmaps[6] = Bitmap.new(8, 8)
        @leaf_bitmaps[6].fill_rect(6, 1, 1, 2, leaf_color2)
        @leaf_bitmaps[6].fill_rect(4, 2, 2, 1, leaf_color2)
        @leaf_bitmaps[6].fill_rect(6, 2, 1, 2, leaf_color1)
        @leaf_bitmaps[6].fill_rect(3, 3, 2, 1, leaf_color2)
        @leaf_bitmaps[6].set_pixel(5, 3, leaf_color3)
        @leaf_bitmaps[6].set_pixel(2, 4, leaf_color2)
        @leaf_bitmaps[6].set_pixel(3, 4, leaf_color3)
        @leaf_bitmaps[6].set_pixel(4, 4, leaf_color4)
        @leaf_bitmaps[6].set_pixel(5, 4, leaf_color2)
        @leaf_bitmaps[6].set_pixel(1, 5, leaf_color2)
        @leaf_bitmaps[6].set_pixel(2, 5, leaf_color3)
        @leaf_bitmaps[6].fill_rect(3, 5, 2, 1, leaf_color2)
        @leaf_bitmaps[6].set_pixel(1, 6, leaf_color1)
        @leaf_bitmaps[6].set_pixel(2, 6, leaf_color2)

        # 8th leaf bitmap
        @leaf_bitmaps[7] = Bitmap.new(8, 8)
        @leaf_bitmaps[7].set_pixel(6, 1, leaf_color2)
        @leaf_bitmaps[7].fill_rect(4, 2, 3, 2, leaf_color2)
        @leaf_bitmaps[7].set_pixel(3, 3, leaf_color1)
        @leaf_bitmaps[7].set_pixel(2, 4, leaf_color1)
        @leaf_bitmaps[7].set_pixel(3, 4, leaf_color2)
        @leaf_bitmaps[7].fill_rect(4, 4, 2, 1, leaf_color3)
        @leaf_bitmaps[7].set_pixel(1, 5, leaf_color1)
        @leaf_bitmaps[7].set_pixel(2, 5, leaf_color2)
        @leaf_bitmaps[7].fill_rect(3, 5, 2, 1, leaf_color4)
        @leaf_bitmaps[7].set_pixel(2, 6, leaf_color2)
        @leaf_bitmaps[7].set_pixel(3, 6, leaf_color4)

        # 9th leaf bitmap
        @leaf_bitmaps[8] = Bitmap.new(8, 8)
        @leaf_bitmaps[8].fill_rect(6, 1, 1, 2, leaf_color2)
        @leaf_bitmaps[8].fill_rect(4, 2, 2, 1, leaf_color2)
        @leaf_bitmaps[8].fill_rect(6, 2, 1, 2, leaf_color1)
        @leaf_bitmaps[8].fill_rect(3, 3, 2, 1, leaf_color2)
        @leaf_bitmaps[8].set_pixel(5, 3, leaf_color3)
        @leaf_bitmaps[8].set_pixel(2, 4, leaf_color2)
        @leaf_bitmaps[8].set_pixel(3, 4, leaf_color3)
        @leaf_bitmaps[8].set_pixel(4, 4, leaf_color4)
        @leaf_bitmaps[8].set_pixel(5, 4, leaf_color2)
        @leaf_bitmaps[8].set_pixel(1, 5, leaf_color2)
        @leaf_bitmaps[8].set_pixel(2, 5, leaf_color3)
        @leaf_bitmaps[8].fill_rect(3, 5, 2, 1, leaf_color2)
        @leaf_bitmaps[8].set_pixel(1, 6, leaf_color1)
        @leaf_bitmaps[8].set_pixel(2, 6, leaf_color2)

        # 10th leaf bitmap
        @leaf_bitmaps[9] = Bitmap.new(8, 8)
        @leaf_bitmaps[9].fill_rect(6, 2, 2, 1, leaf_color2)
        @leaf_bitmaps[9].fill_rect(4, 3, 2, 1, leaf_color2)
        @leaf_bitmaps[9].set_pixel(6, 3, leaf_color3)
        @leaf_bitmaps[9].set_pixel(3, 4, leaf_color2)
        @leaf_bitmaps[9].set_pixel(4, 4, leaf_color3)
        @leaf_bitmaps[9].set_pixel(5, 4, leaf_color4)
        @leaf_bitmaps[9].set_pixel(6, 4, leaf_color5)
        @leaf_bitmaps[9].set_pixel(1, 5, leaf_color2)
        @leaf_bitmaps[9].set_pixel(2, 5, leaf_color3)
        @leaf_bitmaps[9].fill_rect(3, 5, 2, 1, leaf_color5)
        @leaf_bitmaps[9].set_pixel(5, 5, leaf_color4)
        @leaf_bitmaps[9].set_pixel(2, 6, leaf_color2)
        @leaf_bitmaps[9].set_pixel(3, 6, leaf_color3)
        @leaf_bitmaps[9].set_pixel(4, 6, leaf_color4)

        # 11th leaf bitmap
        @leaf_bitmaps[10] = Bitmap.new(8, 8)
        @leaf_bitmaps[10].set_pixel(6, 2, leaf_color2)
        @leaf_bitmaps[10].set_pixel(7, 2, leaf_color1)
        @leaf_bitmaps[10].fill_rect(4, 3, 2, 1, leaf_color2)
        @leaf_bitmaps[10].set_pixel(6, 3, leaf_color3)
        @leaf_bitmaps[10].set_pixel(2, 4, leaf_color1)
        @leaf_bitmaps[10].fill_rect(3, 4, 2, 1, leaf_color3)
        @leaf_bitmaps[10].set_pixel(5, 4, leaf_color4)
        @leaf_bitmaps[10].set_pixel(6, 4, leaf_color3)
        @leaf_bitmaps[10].set_pixel(1, 5, leaf_color2)
        @leaf_bitmaps[10].set_pixel(2, 5, leaf_color3)
        @leaf_bitmaps[10].set_pixel(3, 5, leaf_color4)
        @leaf_bitmaps[10].set_pixel(4, 5, leaf_color5)
        @leaf_bitmaps[10].set_pixel(5, 5, leaf_color2)
        @leaf_bitmaps[10].set_pixel(2, 6, leaf_color1)
        @leaf_bitmaps[10].fill_rect(3, 6, 2, 1, leaf_color2)

        # 12th leaf bitmap
        @leaf_bitmaps[11] = Bitmap.new(8, 8)
        @leaf_bitmaps[11].fill_rect(0, 3, 1, 2, leaf_color1)
        @leaf_bitmaps[11].set_pixel(1, 4, leaf_color2)
        @leaf_bitmaps[11].set_pixel(2, 4, leaf_color3)
        @leaf_bitmaps[11].set_pixel(3, 4, leaf_color4)
        @leaf_bitmaps[11].set_pixel(4, 4, leaf_color1)
        @leaf_bitmaps[11].set_pixel(7, 4, leaf_color2)
        @leaf_bitmaps[11].set_pixel(1, 5, leaf_color1)
        @leaf_bitmaps[11].set_pixel(2, 5, leaf_color2)
        @leaf_bitmaps[11].set_pixel(3, 5, leaf_color4)
        @leaf_bitmaps[11].set_pixel(4, 5, leaf_color5)
        @leaf_bitmaps[11].set_pixel(5, 5, leaf_color4)
        @leaf_bitmaps[11].set_pixel(6, 5, leaf_color3)
        @leaf_bitmaps[11].set_pixel(7, 5, leaf_color2)
        @leaf_bitmaps[11].fill_rect(2, 6, 2, 1, leaf_color2)
        @leaf_bitmaps[11].set_pixel(4, 6, leaf_color4)
        @leaf_bitmaps[11].set_pixel(5, 6, leaf_color3)
        @leaf_bitmaps[11].set_pixel(6, 6, leaf_color2)

        # 13th leaf bitmap
        @leaf_bitmaps[12] = Bitmap.new(8, 8)
        @leaf_bitmaps[12].set_pixel(1, 1, leaf_color1)
        @leaf_bitmaps[12].fill_rect(1, 2, 2, 1, leaf_color2)
        @leaf_bitmaps[12].set_pixel(2, 3, leaf_color2)
        @leaf_bitmaps[12].set_pixel(3, 3, leaf_color1)
        @leaf_bitmaps[12].set_pixel(4, 3, leaf_color2)
        @leaf_bitmaps[12].fill_rect(2, 4, 2, 1, leaf_color2)
        @leaf_bitmaps[12].set_pixel(4, 4, leaf_color1)
        @leaf_bitmaps[12].set_pixel(5, 4, leaf_color4)
        @leaf_bitmaps[12].set_pixel(3, 5, leaf_color2)
        @leaf_bitmaps[12].set_pixel(4, 5, leaf_color1)
        @leaf_bitmaps[12].fill_rect(5, 5, 2, 1, leaf_color3)
        @leaf_bitmaps[12].fill_rect(4, 6, 2, 1, leaf_color2)
        @leaf_bitmaps[12].set_pixel(6, 6, leaf_color4)
        @leaf_bitmaps[12].set_pixel(6, 7, leaf_color3)
      end
      #-------------------------------------------------------------------------------
      # Petals
      if weather == :FlowerPetals
        @petal_bitmaps = []
        case variant
          when 1 # Lavender
            petal_color1 = Color.new(213, 80, 254)
            petal_color2 = Color.new(176, 92, 201)
            petal_color3 = Color.new(154, 86, 175)
          when 2 # Tiger Lily
            petal_color1 = Color.new(254, 154, 40)
            petal_color2 = Color.new(254, 162, 65)
            petal_color3 = Color.new(254, 135, 71)
          when 3 # Pink
            petal_color1 = Color.new(247, 80, 119)
            petal_color2 = Color.new(247, 101, 138)
            petal_color3 = Color.new(244, 105, 165)
          when 4 # Blue
            petal_color1 = Color.new(109, 126, 238)
            petal_color2 = Color.new(128, 143, 240)
            petal_color3 = Color.new(129, 165, 236)
          when 5 # Green
            petal_color1 = Color.new(136, 217, 135)
            petal_color2 = Color.new(153, 221, 152)
            petal_color3 = Color.new(170, 221, 154)
          when 6 # Blue-Purple
            petal_color1 = Color.new(94, 44, 170)
            petal_color2 = Color.new(105, 62, 170)
            petal_color3 = Color.new(78, 60, 168)
          else # Rose
            petal_color1 = Color.new(255, 0, 0)
            petal_color2 = Color.new(179, 17, 17)
            petal_color3 = Color.new(141, 9, 9)
        end

        # 1st petal bitmap
        @petal_bitmaps[0] = Bitmap.new(3, 3)
        @petal_bitmaps[0].fill_rect(1, 0, 2, 1, petal_color1)
        @petal_bitmaps[0].fill_rect(0, 1, 1, 2, petal_color1)
        @petal_bitmaps[0].fill_rect(1, 1, 2, 2, petal_color2)
        @petal_bitmaps[0].set_pixel(2, 2, petal_color3)

        # 2nd petal bitmap
        @petal_bitmaps[1] = Bitmap.new(3, 3)
        @petal_bitmaps[1].set_pixel(0, 1, petal_color2)
        @petal_bitmaps[1].set_pixel(1, 1, petal_color1)
        @petal_bitmaps[1].fill_rect(1, 2, 1, 2, petal_color2)
      end
      #-------------------------------------------------------------------------------
      # Feathers
      if weather == :Feathers
        @feather_bitmaps = []
        feather_color1 = Color.new(255, 255, 255)
        feather_color2 = Color.new(214, 217, 217, 150)

        # 1st feather bitmap
        @feather_bitmaps[0] = Bitmap.new(3, 3)
        @feather_bitmaps[0].set_pixel(0, 2, feather_color1)
        @feather_bitmaps[0].set_pixel(1, 2, feather_color2)
        @feather_bitmaps[0].set_pixel(2, 1, feather_color2)

        # 2nd feather bitmap
        @feather_bitmaps[0] = Bitmap.new(3, 3)
        @feather_bitmaps[0].set_pixel(0, 0, feather_color1)
        @feather_bitmaps[0].set_pixel(0, 1, feather_color2)
        @feather_bitmaps[0].set_pixel(1, 2, feather_color2)

        # 3rd feather bitmap
        @feather_bitmaps[0] = Bitmap.new(3, 3)
        @feather_bitmaps[0].set_pixel(2, 0, feather_color1)
        @feather_bitmaps[0].set_pixel(1, 0, feather_color2)
        @feather_bitmaps[0].set_pixel(0, 1, feather_color2)

        # 4th feather bitmap
        @feather_bitmaps[0] = Bitmap.new(3, 3)
        @feather_bitmaps[0].set_pixel(2, 2, feather_color1)
        @feather_bitmaps[0].set_pixel(2, 1, feather_color2)
        @feather_bitmaps[0].set_pixel(1, 0, feather_color2)
      end
      #-------------------------------------------------------------------------------
      # Sparkle bitmaps
      if [:Sparkles, :SparklesUp].include?(weather)
        @sparkle_bitmaps = []
        case variant
          when 1 # Lavender
            sparkle_color1 = Color.new(197, 181, 255)
            sparkle_color2 = Color.new(171, 126, 234)
            sparkle_color3 = Color.new(187, 77, 234)
            sparkle_color4 = Color.new(255, 255, 255)
          when 2 # Pink
            sparkle_color1 = Color.new(255, 181, 234)
            sparkle_color2 = Color.new(232, 125, 178)
            sparkle_color3 = Color.new(232, 76, 110)
            sparkle_color4 = Color.new(255, 255, 255)
          when 3 # Green
            sparkle_color1 = Color.new(222, 255, 181)
            sparkle_color2 = Color.new(157, 226, 122)
            sparkle_color3 = Color.new(85, 226, 74)
            sparkle_color4 = Color.new(255, 255, 255)
          when 4 # White
            sparkle_color1 = Color.new(236, 236, 236)
            sparkle_color2 = Color.new(218, 218, 218)
            sparkle_color3 = Color.new(210, 210, 210)
            sparkle_color4 = Color.new(255, 255, 255)
          else # Blue
            sparkle_color1 = Color.new(181, 244, 255)
            sparkle_color2 = Color.new(126, 197, 235)
            sparkle_color3 = Color.new(77, 136, 225)
            sparkle_color4 = Color.new(255, 255, 255)
        end

        # 1st sparkle bitmap
        @sparkle_bitmaps[0] = Bitmap.new(7, 7)
        @sparkle_bitmaps[0].set_pixel(3, 3, sparkle_color3)

        # 2nd sparkle bitmap
        @sparkle_bitmaps[1] = Bitmap.new(7, 7)
        @sparkle_bitmaps[1].fill_rect(3, 2, 1, 3, sparkle_color3)
        @sparkle_bitmaps[1].fill_rect(2, 3, 3, 1, sparkle_color3)
        @sparkle_bitmaps[1].set_pixel(3, 3, sparkle_color2)

        # 3rd sparkle bitmap
        @sparkle_bitmaps[2] = Bitmap.new(7, 7)
        @sparkle_bitmaps[2].set_pixel(1, 1, sparkle_color3)
        @sparkle_bitmaps[2].set_pixel(5, 1, sparkle_color3)
        @sparkle_bitmaps[2].set_pixel(2, 2, sparkle_color2)
        @sparkle_bitmaps[2].set_pixel(4, 2, sparkle_color2)
        @sparkle_bitmaps[2].set_pixel(3, 3, sparkle_color1)
        @sparkle_bitmaps[2].set_pixel(2, 4, sparkle_color2)
        @sparkle_bitmaps[2].set_pixel(4, 4, sparkle_color2)
        @sparkle_bitmaps[2].set_pixel(1, 5, sparkle_color3)
        @sparkle_bitmaps[2].set_pixel(5, 5, sparkle_color3)

        # 4th sparkle bitmap
        @sparkle_bitmaps[3] = Bitmap.new(7, 7)
        @sparkle_bitmaps[3].fill_rect(3, 1, 1, 5, sparkle_color3)
        @sparkle_bitmaps[3].fill_rect(1, 3, 5, 1, sparkle_color3)
        @sparkle_bitmaps[3].fill_rect(3, 2, 1, 3, sparkle_color2)
        @sparkle_bitmaps[3].fill_rect(2, 3, 3, 1, sparkle_color2)
        @sparkle_bitmaps[3].set_pixel(3, 3, sparkle_color1)

        # 5th sparkle bitmap
        @sparkle_bitmaps[4] = Bitmap.new(7, 7)
        @sparkle_bitmaps[4].fill_rect(2, 2, 3, 3, sparkle_color2)
        @sparkle_bitmaps[4].fill_rect(3, 2, 1, 3, sparkle_color3)
        @sparkle_bitmaps[4].fill_rect(2, 3, 3, 1, sparkle_color3)
        @sparkle_bitmaps[4].set_pixel(3, 3, sparkle_color1)
        @sparkle_bitmaps[4].set_pixel(1, 1, sparkle_color3)
        @sparkle_bitmaps[4].set_pixel(5, 1, sparkle_color3)
        @sparkle_bitmaps[4].set_pixel(1, 5, sparkle_color3)
        @sparkle_bitmaps[4].set_pixel(5, 1, sparkle_color3)

        # 6th sparkle bitmap
        @sparkle_bitmaps[5] = Bitmap.new(7, 7)
        @sparkle_bitmaps[5].fill_rect(2, 1, 3, 5, sparkle_color3)
        @sparkle_bitmaps[5].fill_rect(1, 2, 5, 3, sparkle_color3)
        @sparkle_bitmaps[5].fill_rect(2, 2, 3, 3, sparkle_color2)
        @sparkle_bitmaps[5].fill_rect(3, 1, 1, 5, sparkle_color2)
        @sparkle_bitmaps[5].fill_rect(1, 3, 5, 1, sparkle_color2)
        @sparkle_bitmaps[5].fill_rect(3, 2, 1, 3, sparkle_color1)
        @sparkle_bitmaps[5].fill_rect(2, 3, 3, 1, sparkle_color1)
        @sparkle_bitmaps[5].set_pixel(3, 3, sparkle_color4)

        # 7th sparkle bitmap
        @sparkle_bitmaps[6] = Bitmap.new(7, 7)
        @sparkle_bitmaps[6].fill_rect(2, 1, 3, 5, sparkle_color2)
        @sparkle_bitmaps[6].fill_rect(1, 2, 5, 3, sparkle_color2)
        @sparkle_bitmaps[6].fill_rect(3, 0, 1, 7, sparkle_color3)
        @sparkle_bitmaps[6].fill_rect(0, 3, 7, 1, sparkle_color3)
        @sparkle_bitmaps[6].fill_rect(2, 2, 3, 3, sparkle_color1)
        @sparkle_bitmaps[6].fill_rect(3, 2, 1, 3, sparkle_color2)
        @sparkle_bitmaps[6].fill_rect(2, 3, 3, 1, sparkle_color2)
        @sparkle_bitmaps[6].set_pixel(3, 3, sparkle_color4)
      end
      #-------------------------------------------------------------------------------
      # Meteor bitmap
      if weather == :Meteors
        case variant
          when 1 # Flame Meteor
            meteor_color1 = Color.new(248, 88, 0)
            meteor_color2 = Color.new(205, 194, 23)
            meteor_color3 = Color.new(218, 207, 36)
          when 2 # Rock Meteor
            meteor_color1 = Color.new(60, 60, 60)
            meteor_color2 = Color.new(248, 88, 0)
            meteor_color3 = Color.new(218, 207, 36)
          else # Normal Meteor
            meteor_color1 = Color.new(232, 160, 128)
            meteor_color2 = Color.new(248, 88, 0)
            meteor_color3 = Color.new(179, 17, 17)
        end

        @meteor_bitmap = Bitmap.new(14, 12)
        @meteor_bitmap.fill_rect(0, 8, 5, 4, meteor_color1)
        @meteor_bitmap.fill_rect(1, 7, 6, 4, meteor_color1)
        @meteor_bitmap.set_pixel(7, 8, meteor_color1)
        @meteor_bitmap.fill_rect(1, 8, 2, 2, meteor_color2)
        @meteor_bitmap.set_pixel(2, 7, meteor_color2)
        @meteor_bitmap.fill_rect(3, 6, 2, 1, meteor_color2)
        @meteor_bitmap.set_pixel(3, 8, meteor_color2)
        @meteor_bitmap.set_pixel(3, 10, meteor_color2)
        @meteor_bitmap.set_pixel(4, 9, meteor_color2)
        @meteor_bitmap.fill_rect(5, 5, 1, 5, meteor_color2)
        @meteor_bitmap.fill_rect(6, 4, 1, 5, meteor_color2)
        @meteor_bitmap.fill_rect(7, 3, 1, 5, meteor_color2)
        @meteor_bitmap.fill_rect(8, 6, 1, 2, meteor_color2)
        @meteor_bitmap.set_pixel(9, 5, meteor_color2)
        @meteor_bitmap.set_pixel(3, 8, meteor_color3)
        @meteor_bitmap.fill_rect(4, 7, 1, 2, meteor_color3)
        @meteor_bitmap.set_pixel(4, 5, meteor_color3)
        @meteor_bitmap.set_pixel(5, 4, meteor_color3)
        @meteor_bitmap.set_pixel(5, 6, meteor_color3)
        @meteor_bitmap.set_pixel(6, 5, meteor_color3)
        @meteor_bitmap.set_pixel(6, 7, meteor_color3)
        @meteor_bitmap.fill_rect(7, 4, 1, 3, meteor_color3)
        @meteor_bitmap.fill_rect(8, 3, 1, 3, meteor_color3)
        @meteor_bitmap.fill_rect(9, 2, 1, 3, meteor_color3)
        @meteor_bitmap.fill_rect(10, 1, 1, 3, meteor_color3)
        @meteor_bitmap.fill_rect(11, 0, 1, 3, meteor_color3)
        @meteor_bitmap.fill_rect(12, 0, 1, 2, meteor_color3)
        @meteor_bitmap.set_pixel(13, 0, meteor_color3)

        # Impact bitmap
        @impact_bitmap = Bitmap.new(22, 11)
        @impact_bitmap.fill_rect(0, 5, 1, 2, meteor_color2)
        @impact_bitmap.set_pixel(1, 4, meteor_color2)
        @impact_bitmap.set_pixel(1, 6, meteor_color2)
        @impact_bitmap.set_pixel(2, 3, meteor_color2)
        @impact_bitmap.set_pixel(2, 7, meteor_color2)
        @impact_bitmap.set_pixel(3, 2, meteor_color3)
        @impact_bitmap.set_pixel(3, 7, meteor_color3)
        @impact_bitmap.set_pixel(4, 2, meteor_color2)
        @impact_bitmap.set_pixel(4, 8, meteor_color2)
        @impact_bitmap.set_pixel(5, 2, meteor_color3)
        @impact_bitmap.fill_rect(5, 8, 3, 1, meteor_color2)
        @impact_bitmap.set_pixel(6, 1, meteor_color3)
        @impact_bitmap.fill_rect(7, 1, 8, 1, meteor_color2)
        @impact_bitmap.fill_rect(7, 9, 8, 1, meteor_color3)
      end
      #-------------------------------------------------------------------------------
      # Ash bitmaps
      if weather == :FallingAsh
        @ash_bitmaps = []
        case variant
          when 1 # White
            ash_color1 = Color.new(210, 210, 210, 250)
            ash_color2 = Color.new(255, 255, 255)
            ash_color3 = Color.new(214, 217, 217, 150)
          when 2 # Cinders
            ash_color1 = Color.new(255, 180, 0)
            ash_color2 = Color.new(255, 120, 0)
            ash_color3 = Color.new(255, 60, 0)
          else # Smog
            ash_color1 = Color.new(115, 115, 115)
            ash_color2 = Color.new(140, 140, 140)
            ash_color3 = Color.new(165, 165, 165)
        end

        @ash_bitmaps[0] = Bitmap.new(3, 3)
        @ash_bitmaps[0].fill_rect(0, 1, 1, 3, ash_color3)
        @ash_bitmaps[0].fill_rect(1, 0, 3, 1, ash_color2)
        @ash_bitmaps[0].set_pixel(1, 1, ash_color1)
        @ash_bitmaps[1] = Bitmap.new(3, 3)
        @ash_bitmaps[1].fill_rect(0, 1, 1, 3, ash_color3)
        @ash_bitmaps[1].fill_rect(1, 0, 3, 1, ash_color2)
        @ash_bitmaps[1].set_pixel(1, 1, ash_color1)
      end
      #-------------------------------------------------------------------------------
      # Bubble bitmaps
      if weather == :Bubbles
        @bubble_bitmaps = []
        bubble_color1 = Color.new(77, 136, 225, 160)
        bubble_color2 = Color.new(197, 253, 254, 160)
        bubble_color3 = Color.new(225, 190, 244, 160)
        bubble_color4 = Color.new(255, 255, 255)

        # first bubble bitmap
        @bubble_bitmaps[0] = Bitmap.new(24, 24)
        @bubble_bitmaps[0].fill_rect(0, 9, 24, 5, bubble_color1)
        @bubble_bitmaps[0].fill_rect(1, 6, 22, 11, bubble_color1)
        @bubble_bitmaps[0].fill_rect(2, 5, 20, 13, bubble_color1)
        @bubble_bitmaps[0].fill_rect(3, 4, 18, 15, bubble_color1)
        @bubble_bitmaps[0].fill_rect(4, 3, 16, 17, bubble_color1)
        @bubble_bitmaps[0].fill_rect(5, 2, 14, 19, bubble_color1)
        @bubble_bitmaps[0].fill_rect(6, 1, 12, 21, bubble_color1)
        @bubble_bitmaps[0].fill_rect(9, 0, 5, 24, bubble_color1)
        @bubble_bitmaps[0].fill_rect(2, 11, 20, 4, bubble_color2)
        @bubble_bitmaps[0].fill_rect(3, 7, 18, 10, bubble_color2)
        @bubble_bitmaps[0].fill_rect(4, 6, 16, 12, bubble_color2)
        @bubble_bitmaps[0].fill_rect(5, 5, 14, 14, bubble_color2)
        @bubble_bitmaps[0].fill_rect(6, 4, 12, 16, bubble_color2)
        @bubble_bitmaps[0].fill_rect(9, 2, 4, 20, bubble_color2)
        @bubble_bitmaps[0].fill_rect(5, 10, 1, 7, bubble_color3)
        @bubble_bitmaps[0].fill_rect(6, 14, 1, 5, bubble_color3)
        @bubble_bitmaps[0].fill_rect(7, 15, 1, 4, bubble_color3)
        @bubble_bitmaps[0].fill_rect(8, 16, 1, 4, bubble_color3)
        @bubble_bitmaps[0].fill_rect(9, 17, 1, 3, bubble_color3)
        @bubble_bitmaps[0].fill_rect(10, 18, 4, 3, bubble_color3)
        @bubble_bitmaps[0].fill_rect(14, 18, 1, 2, bubble_color3)
        @bubble_bitmaps[0].fill_rect(13, 5, 4, 4, bubble_color4)
        @bubble_bitmaps[0].fill_rect(14, 4, 2, 1, bubble_color4)
        @bubble_bitmaps[0].set_pixel(17, 6, bubble_color4)

        # second bubble bitmap
        @bubble_bitmaps[1] = Bitmap.new(14, 15)
        @bubble_bitmaps[1].fill_rect(0, 4, 14, 7, bubble_color1)
        @bubble_bitmaps[1].fill_rect(1, 3, 12, 9, bubble_color1)
        @bubble_bitmaps[1].fill_rect(2, 2, 10, 11, bubble_color1)
        @bubble_bitmaps[1].fill_rect(3, 1, 8, 13, bubble_color1)
        @bubble_bitmaps[1].fill_rect(5, 0, 4, 15, bubble_color1)
        @bubble_bitmaps[1].fill_rect(1, 5, 12, 4, bubble_color2)
        @bubble_bitmaps[1].fill_rect(2, 4, 10, 6, bubble_color2)
        @bubble_bitmaps[1].fill_rect(3, 3, 8, 8, bubble_color2)
        @bubble_bitmaps[1].fill_rect(4, 2, 6, 10, bubble_color2)
        @bubble_bitmaps[1].fill_rect(1, 5, 12, 4, bubble_color2)
        @bubble_bitmaps[1].fill_rect(3, 9, 1, 2, bubble_color3)
        @bubble_bitmaps[1].fill_rect(4, 10, 1, 2, bubble_color3)
        @bubble_bitmaps[1].fill_rect(5, 11, 4, 1, bubble_color3)
        @bubble_bitmaps[1].fill_rect(6, 12, 2, 1, bubble_color4)
        @bubble_bitmaps[1].fill_rect(8, 3, 2, 2, bubble_color4)
        @bubble_bitmaps[1].set_pixel(7, 4, bubble_color4)
        @bubble_bitmaps[1].set_pixel(8, 5, bubble_color4)
      end

      if weather == :Bubbles2
        # Other option for bubbles
        @bubble2_bitmaps = Array.new
        bubble2_color1 = Color.new(145, 150, 155, 160)
        bubble2_color2 = Color.new(180, 180, 185, 160)
        bubble2_color3 = Color.new(225, 225, 235, 160)
        bubble2_color4 = Color.new(145, 145, 165, 160)
        bubble2_color5 = Color.new(165, 170, 180, 160)
        bubble2_color6 = Color.new(255, 255, 255, 160)

        # first bubble 2 bitmap
        @bubble2_bitmaps[0] = Bitmap.new(6, 6)
        @bubble2_bitmaps[0].fill_rect(0, 0, 6, 6, bubble2_color1)
        @bubble2_bitmaps[0].fill_rect(0, 2, 6, 2, bubble2_color2)
        @bubble2_bitmaps[0].fill_rect(2, 0, 2, 6, bubble2_color2)
        @bubble2_bitmaps[0].fill_rect(2, 2, 2, 2, bubble2_color3)

        # second bubble 2 bitmap
        @bubble2_bitmaps[1] = Bitmap.new(8, 8)
        @bubble2_bitmaps[1].fill_rect(0, 2, 2, 4, bubble2_color4)
        @bubble2_bitmaps[1].fill_rect(2, 0, 4, 2, bubble2_color1)
        @bubble2_bitmaps[1].fill_rect(6, 2, 2, 2, bubble2_color1)
        @bubble2_bitmaps[1].fill_rect(2, 6, 2, 2, bubble2_color1)
        @bubble2_bitmaps[1].fill_rect(6, 4, 2, 2, bubble2_color2)
        @bubble2_bitmaps[1].fill_rect(4, 6, 2, 2, bubble2_color2)
        @bubble2_bitmaps[1].fill_rect(4, 4, 2, 2, bubble2_color5)
        @bubble2_bitmaps[1].fill_rect(2, 4, 2, 2, bubble2_color3)
        @bubble2_bitmaps[1].fill_rect(4, 2, 2, 2, bubble2_color3)
        @bubble2_bitmaps[1].fill_rect(2, 2, 2, 2, bubble2_color6)

        # third bubble 2 bitmap
        @bubble2_bitmaps[2] = Bitmap.new(8, 10)
        @bubble2_bitmaps[2].fill_rect(8, 2, 2, 4, bubble2_color4)
        @bubble2_bitmaps[2].fill_rect(2, 0, 8, 2, bubble2_color1)
        @bubble2_bitmaps[2].fill_rect(2, 6, 8, 2, bubble2_color1)
        @bubble2_bitmaps[2].fill_rect(4, 0, 2, 2, bubble2_color2)
        @bubble2_bitmaps[2].fill_rect(4, 6, 2, 2, bubble2_color2)
        @bubble2_bitmaps[2].fill_rect(0, 2, 2, 2, bubble2_color2)
        @bubble2_bitmaps[2].fill_rect(0, 4, 2, 2, bubble2_color5)
        @bubble2_bitmaps[2].fill_rect(2, 2, 6, 4, bubble2_color3)
        @bubble2_bitmaps[2].fill_rect(2, 2, 4, 2, bubble2_color6)
        @bubble2_bitmaps[2].fill_rect(4, 4, 2, 2, bubble2_color6)

        # fourth bubble 2 bitmap
        @bubble2_bitmaps[3] = Bitmap.new(14, 14)
        @bubble2_bitmaps[3].fill_rect(4, 0, 4, 2, bubble2_color4)
        @bubble2_bitmaps[3].fill_rect(0, 4, 2, 4, bubble2_color4)
        @bubble2_bitmaps[3].fill_rect(12, 4, 2, 4, bubble2_color4)
        @bubble2_bitmaps[3].fill_rect(8, 0, 2, 2, bubble2_color1)
        @bubble2_bitmaps[3].fill_rect(0, 6, 2, 2, bubble2_color1)
        @bubble2_bitmaps[3].fill_rect(12, 6, 2, 2, bubble2_color1)
        @bubble2_bitmaps[3].fill_rect(4, 12, 6, 2, bubble2_color1)
        @bubble2_bitmaps[3].fill_rect(8, 0, 2, 2, bubble2_color1)
        @bubble2_bitmaps[3].fill_rect(2, 2, 10, 10, bubble2_color2)
        @bubble2_bitmaps[3].fill_rect(6, 12, 2, 2, bubble2_color2)
        @bubble2_bitmaps[3].fill_rect(2, 4, 10, 6, bubble2_color3)
        @bubble2_bitmaps[3].fill_rect(4, 2, 2, 2, bubble2_color3)
        @bubble2_bitmaps[3].fill_rect(6, 10, 4, 2, bubble2_color3)
        @bubble2_bitmaps[3].fill_rect(6, 4, 2, 2, bubble2_color6)
        @bubble2_bitmaps[3].fill_rect(4, 6, 2, 2, bubble2_color6)
      end
      #-------------------------------------------------------------------------------
      # Bomb bitmap
      if weather == :Bombs
        case variant
          when 1 # Flare
            bomb_color1 = Color.new(205, 194, 23)
            bomb_color2 = Color.new(248, 88, 0)
          when 2 # Ice
            bomb_color1 = Color.new(181, 244, 255)
            bomb_color2 = Color.new(181, 244, 255)
          else # Water
            bomb_color1 = Color.new(197, 253, 254, 160)
            bomb_color2 = Color.new(197, 253, 254, 160)
        end

        @bomb_bitmap = Bitmap.new(8, 8)
        @bomb_bitmap.fill_rect(0, 2, 2, 4, bomb_color1)
        @bomb_bitmap.fill_rect(2, 0, 4, 2, bomb_color1)
        @bomb_bitmap.fill_rect(6, 2, 2, 2, bomb_color1)
        @bomb_bitmap.fill_rect(2, 6, 2, 2, bomb_color2)
        @bomb_bitmap.fill_rect(6, 4, 2, 2, bomb_color2)
        @bomb_bitmap.fill_rect(4, 6, 2, 2, bomb_color1)
        @bomb_bitmap.fill_rect(4, 4, 2, 2, bomb_color2)
        @bomb_bitmap.fill_rect(2, 4, 2, 2, bomb_color1)
        @bomb_bitmap.fill_rect(4, 2, 2, 2, bomb_color1)
        @bomb_bitmap.fill_rect(2, 2, 2, 2, bomb_color1)

        # Bomb impact bitmap
        @bomb_impact_bitmap = Bitmap.new(8, 5)
        @bomb_impact_bitmap.fill_rect(1, 0, 6, 1, bomb_color2)
        @bomb_impact_bitmap.fill_rect(1, 4, 6, 1, bomb_color2)
        @bomb_impact_bitmap.fill_rect(0, 1, 1, 3, bomb_color1)
        @bomb_impact_bitmap.fill_rect(7, 1, 1, 3, bomb_color1)
        @bomb_impact_bitmap.set_pixel(1, 0, bomb_color1)
        @bomb_impact_bitmap.set_pixel(0, 1, bomb_color1)
      end
      #-------------------------------------------------------------------------------
      # Starburst bitmaps (prismatic)
      if [:Starburst, :StarburstUp, :StarburstRain].include?(weather)
        @starburst_bitmaps = []
        starburst_color1 = Color.new(233, 210, 142)
        starburst_color2 = Color.new(219, 191, 95)
        starburst_color3 = Color.new(242, 229, 190)
        starburst_color4 = Color.new(241, 185, 187)
        starburst_color5 = Color.new(196, 55, 84)
        starburst_color6 = Color.new(178, 15, 56)
        starburst_color7 = Color.new(189, 225, 242)
        starburst_color8 = Color.new(102, 181, 221)
        starburst_color9 = Color.new(5, 88, 168)
        starburst_color10 = Color.new(205, 246, 205)
        starburst_color11 = Color.new(88, 221, 89)
        starburst_color12 = Color.new(44, 166, 0)
        starburst_color13 = Color.new(216, 197, 255)
        starburst_color14 = Color.new(155, 107, 255)
        starburst_color15 = Color.new(71, 0, 222)
        starburst_color16 = Color.new(255, 220, 177)
        starburst_color17 = Color.new(255, 180, 85)
        starburst_color18 = Color.new(222, 124, 0)

        # 1st starburst bitmap
        @starburst_bitmaps[0] = Bitmap.new(8, 8)
        @starburst_bitmaps[0].set_pixel(3, 3, starburst_color3)

        # 2nd starburst bitmap
        @starburst_bitmaps[1] = Bitmap.new(8, 8)
        @starburst_bitmaps[1].fill_rect(3, 2, 1, 3, starburst_color1)
        @starburst_bitmaps[1].fill_rect(2, 3, 3, 1, starburst_color1)
        @starburst_bitmaps[1].set_pixel(3, 3, starburst_color3)

        # 3rd starburst bitmap
        @starburst_bitmaps[2] = Bitmap.new(7, 7)
        @starburst_bitmaps[2].set_pixel(1, 1, starburst_color1)
        @starburst_bitmaps[2].set_pixel(5, 1, starburst_color1)
        @starburst_bitmaps[2].set_pixel(2, 2, starburst_color2)
        @starburst_bitmaps[2].set_pixel(4, 2, starburst_color1)
        @starburst_bitmaps[2].set_pixel(3, 3, starburst_color3)
        @starburst_bitmaps[2].set_pixel(2, 4, starburst_color2)
        @starburst_bitmaps[2].set_pixel(4, 4, starburst_color2)
        @starburst_bitmaps[2].set_pixel(1, 5, starburst_color1)
        @starburst_bitmaps[2].set_pixel(5, 5, starburst_color1)

        # 4th starburst bitmap
        @starburst_bitmaps[3] = Bitmap.new(7, 7)
        @starburst_bitmaps[3].fill_rect(3, 1, 1, 5, starburst_color1)
        @starburst_bitmaps[3].fill_rect(1, 3, 5, 1, starburst_color2)
        @starburst_bitmaps[3].fill_rect(3, 2, 1, 3, starburst_color1)
        @starburst_bitmaps[3].fill_rect(2, 3, 3, 1, starburst_color2)
        @starburst_bitmaps[3].set_pixel(3, 3, starburst_color3)

        # 5th starburst bitmap
        @starburst_bitmaps[4] = Bitmap.new(7, 7)
        @starburst_bitmaps[4].fill_rect(2, 2, 3, 3, starburst_color1)
        @starburst_bitmaps[4].fill_rect(3, 2, 1, 3, starburst_color1)
        @starburst_bitmaps[4].fill_rect(2, 3, 3, 1, starburst_color2)
        @starburst_bitmaps[4].set_pixel(3, 3, starburst_color3)
        @starburst_bitmaps[4].set_pixel(1, 1, starburst_color1)
        @starburst_bitmaps[4].set_pixel(5, 1, starburst_color1)
        @starburst_bitmaps[4].set_pixel(1, 5, starburst_color2)
        @starburst_bitmaps[4].set_pixel(5, 1, starburst_color2)

        # 6th starburst bitmap
        @starburst_bitmaps[5] = Bitmap.new(8, 8)
        @starburst_bitmaps[5].fill_rect(3, 2, 1, 3, starburst_color1)
        @starburst_bitmaps[5].fill_rect(2, 3, 3, 1, starburst_color1)
        @starburst_bitmaps[5].set_pixel(3, 3, starburst_color3)

        # 7th starburst bitmap
        @starburst_bitmaps[6] = Bitmap.new(8, 8)
        @starburst_bitmaps[6].fill_rect(3, 2, 1, 3, starburst_color11)
        @starburst_bitmaps[6].fill_rect(2, 3, 3, 1, starburst_color11)
        @starburst_bitmaps[6].set_pixel(3, 3, starburst_color10)

        # 8th starburst bitmap
        @starburst_bitmaps[7] = Bitmap.new(7, 7)
        @starburst_bitmaps[7].set_pixel(1, 1, starburst_color12)
        @starburst_bitmaps[7].set_pixel(5, 1, starburst_color12)
        @starburst_bitmaps[7].set_pixel(2, 2, starburst_color12)
        @starburst_bitmaps[7].set_pixel(4, 2, starburst_color12)
        @starburst_bitmaps[7].set_pixel(3, 3, starburst_color11)
        @starburst_bitmaps[7].set_pixel(2, 4, starburst_color11)
        @starburst_bitmaps[7].set_pixel(4, 4, starburst_color11)
        @starburst_bitmaps[7].set_pixel(1, 5, starburst_color11)
        @starburst_bitmaps[7].set_pixel(5, 5, starburst_color10)

        # 9th starburst bitmap
        @starburst_bitmaps[8] = Bitmap.new(7, 7)
        @starburst_bitmaps[8].fill_rect(3, 1, 1, 5, starburst_color12)
        @starburst_bitmaps[8].fill_rect(1, 3, 5, 1, starburst_color12)
        @starburst_bitmaps[8].fill_rect(3, 2, 1, 3, starburst_color11)
        @starburst_bitmaps[8].fill_rect(2, 3, 3, 1, starburst_color11)
        @starburst_bitmaps[8].set_pixel(3, 3, starburst_color10)

        # 10th starburst bitmap
        @starburst_bitmaps[9] = Bitmap.new(7, 7)
        @starburst_bitmaps[9].fill_rect(2, 1, 3, 5, starburst_color12)
        @starburst_bitmaps[9].fill_rect(1, 2, 5, 3, starburst_color12)
        @starburst_bitmaps[9].fill_rect(2, 2, 3, 3, starburst_color11)
        @starburst_bitmaps[9].fill_rect(3, 1, 1, 5, starburst_color11)
        @starburst_bitmaps[9].fill_rect(1, 3, 5, 1, starburst_color11)
        @starburst_bitmaps[9].fill_rect(3, 2, 1, 3, starburst_color10)
        @starburst_bitmaps[9].fill_rect(2, 3, 3, 1, starburst_color10)
        @starburst_bitmaps[9].set_pixel(3, 3, starburst_color10)

        # 11th starburst bitmap
        @starburst_bitmaps[10] = Bitmap.new(7, 7)
        @starburst_bitmaps[10].fill_rect(2, 2, 3, 3, starburst_color12)
        @starburst_bitmaps[10].fill_rect(3, 2, 1, 3, starburst_color12)
        @starburst_bitmaps[10].fill_rect(2, 3, 3, 1, starburst_color11)
        @starburst_bitmaps[10].set_pixel(3, 3, starburst_color10)
        @starburst_bitmaps[10].set_pixel(1, 1, starburst_color11)
        @starburst_bitmaps[10].set_pixel(5, 1, starburst_color11)
        @starburst_bitmaps[10].set_pixel(1, 5, starburst_color12)
        @starburst_bitmaps[10].set_pixel(5, 1, starburst_color12)

        # 12th starburst bitmap
        @starburst_bitmaps[11] = Bitmap.new(8, 8)
        @starburst_bitmaps[11].fill_rect(3, 2, 1, 3, starburst_color11)
        @starburst_bitmaps[11].fill_rect(2, 3, 3, 1, starburst_color11)
        @starburst_bitmaps[11].set_pixel(3, 3, starburst_color10)

        # 13th starburst bitmap
        @starburst_bitmaps[12] = Bitmap.new(8, 8)
        @starburst_bitmaps[12].fill_rect(3, 2, 1, 3, starburst_color8)
        @starburst_bitmaps[12].fill_rect(2, 3, 3, 1, starburst_color8)
        @starburst_bitmaps[12].set_pixel(3, 3, starburst_color7)

        # 14th starburst bitmap
        @starburst_bitmaps[13] = Bitmap.new(7, 7)
        @starburst_bitmaps[13].set_pixel(1, 1, starburst_color9)
        @starburst_bitmaps[13].set_pixel(5, 1, starburst_color9)
        @starburst_bitmaps[13].set_pixel(2, 2, starburst_color9)
        @starburst_bitmaps[13].set_pixel(4, 2, starburst_color9)
        @starburst_bitmaps[13].set_pixel(3, 3, starburst_color8)
        @starburst_bitmaps[13].set_pixel(2, 4, starburst_color8)
        @starburst_bitmaps[13].set_pixel(4, 4, starburst_color8)
        @starburst_bitmaps[13].set_pixel(1, 5, starburst_color8)
        @starburst_bitmaps[13].set_pixel(5, 5, starburst_color7)

        # 15th starburst bitmap
        @starburst_bitmaps[14] = Bitmap.new(7, 7)
        @starburst_bitmaps[14].fill_rect(3, 1, 1, 5, starburst_color9)
        @starburst_bitmaps[14].fill_rect(1, 3, 5, 1, starburst_color9)
        @starburst_bitmaps[14].fill_rect(3, 2, 1, 3, starburst_color8)
        @starburst_bitmaps[14].fill_rect(2, 3, 3, 1, starburst_color8)
        @starburst_bitmaps[14].set_pixel(3, 3, starburst_color7)

        # 16th starburst bitmap
        @starburst_bitmaps[15] = Bitmap.new(7, 7)
        @starburst_bitmaps[15].fill_rect(2, 1, 3, 5, starburst_color9)
        @starburst_bitmaps[15].fill_rect(1, 2, 5, 3, starburst_color9)
        @starburst_bitmaps[15].fill_rect(2, 2, 3, 3, starburst_color8)
        @starburst_bitmaps[15].fill_rect(3, 1, 1, 5, starburst_color8)
        @starburst_bitmaps[15].fill_rect(1, 3, 5, 1, starburst_color8)
        @starburst_bitmaps[15].fill_rect(3, 2, 1, 3, starburst_color7)
        @starburst_bitmaps[15].fill_rect(2, 3, 3, 1, starburst_color7)
        @starburst_bitmaps[15].set_pixel(3, 3, starburst_color7)

        # 17th starburst bitmap
        @starburst_bitmaps[16] = Bitmap.new(8, 8)
        @starburst_bitmaps[16].fill_rect(3, 2, 1, 3, starburst_color8)
        @starburst_bitmaps[16].fill_rect(2, 3, 3, 1, starburst_color8)
        @starburst_bitmaps[16].set_pixel(3, 3, starburst_color7)

        # 18th starburst bitmap
        @starburst_bitmaps[17] = Bitmap.new(8, 8)
        @starburst_bitmaps[17].fill_rect(3, 2, 1, 3, starburst_color14)
        @starburst_bitmaps[17].fill_rect(2, 3, 3, 1, starburst_color14)
        @starburst_bitmaps[17].set_pixel(3, 3, starburst_color13)

        # 19th starburst bitmap
        @starburst_bitmaps[18] = Bitmap.new(7, 7)
        @starburst_bitmaps[18].set_pixel(1, 1, starburst_color15)
        @starburst_bitmaps[18].set_pixel(5, 1, starburst_color15)
        @starburst_bitmaps[18].set_pixel(2, 2, starburst_color15)
        @starburst_bitmaps[18].set_pixel(4, 2, starburst_color15)
        @starburst_bitmaps[18].set_pixel(3, 3, starburst_color14)
        @starburst_bitmaps[18].set_pixel(2, 4, starburst_color14)
        @starburst_bitmaps[18].set_pixel(4, 4, starburst_color14)
        @starburst_bitmaps[18].set_pixel(1, 5, starburst_color14)
        @starburst_bitmaps[18].set_pixel(5, 5, starburst_color13)

        # 20th starburst bitmap
        @starburst_bitmaps[19] = Bitmap.new(7, 7)
        @starburst_bitmaps[19].fill_rect(3, 1, 1, 5, starburst_color15)
        @starburst_bitmaps[19].fill_rect(1, 3, 5, 1, starburst_color15)
        @starburst_bitmaps[19].fill_rect(3, 2, 1, 3, starburst_color14)
        @starburst_bitmaps[19].fill_rect(2, 3, 3, 1, starburst_color14)
        @starburst_bitmaps[19].set_pixel(3, 3, starburst_color14)

        # 21st starburst bitmap
        @starburst_bitmaps[20] = Bitmap.new(7, 7)
        @starburst_bitmaps[20].fill_rect(2, 1, 3, 5, starburst_color15)
        @starburst_bitmaps[20].fill_rect(1, 2, 5, 3, starburst_color15)
        @starburst_bitmaps[20].fill_rect(2, 2, 3, 3, starburst_color14)
        @starburst_bitmaps[20].fill_rect(3, 1, 1, 5, starburst_color14)
        @starburst_bitmaps[20].fill_rect(1, 3, 5, 1, starburst_color14)
        @starburst_bitmaps[20].fill_rect(3, 2, 1, 3, starburst_color13)
        @starburst_bitmaps[20].fill_rect(2, 3, 3, 1, starburst_color13)
        @starburst_bitmaps[20].set_pixel(3, 3, starburst_color13)

        # 22nd starburst bitmap
        @starburst_bitmaps[21] = Bitmap.new(7, 7)
        @starburst_bitmaps[21].fill_rect(2, 1, 3, 5, starburst_color14)
        @starburst_bitmaps[21].fill_rect(1, 2, 5, 3, starburst_color14)
        @starburst_bitmaps[21].fill_rect(3, 0, 1, 7, starburst_color15)
        @starburst_bitmaps[21].fill_rect(0, 3, 7, 1, starburst_color15)
        @starburst_bitmaps[21].fill_rect(2, 2, 3, 3, starburst_color13)
        @starburst_bitmaps[21].fill_rect(3, 2, 1, 3, starburst_color14)
        @starburst_bitmaps[21].fill_rect(2, 3, 3, 1, starburst_color14)
        @starburst_bitmaps[21].set_pixel(3, 3, starburst_color13)

        # 23rd starburst bitmap
        @starburst_bitmaps[22] = Bitmap.new(8, 8)
        @starburst_bitmaps[22].fill_rect(3, 2, 1, 3, starburst_color14)
        @starburst_bitmaps[22].fill_rect(2, 3, 3, 1, starburst_color14)
        @starburst_bitmaps[22].set_pixel(3, 3, starburst_color13)

        # 24th starburst bitmap
        @starburst_bitmaps[23] = Bitmap.new(8, 8)
        @starburst_bitmaps[23].fill_rect(3, 2, 1, 3, starburst_color5)
        @starburst_bitmaps[23].fill_rect(2, 3, 3, 1, starburst_color5)
        @starburst_bitmaps[23].set_pixel(3, 3, starburst_color4)

        # 25th starburst bitmap
        @starburst_bitmaps[24] = Bitmap.new(7, 7)
        @starburst_bitmaps[24].set_pixel(1, 1, starburst_color6)
        @starburst_bitmaps[24].set_pixel(5, 1, starburst_color6)
        @starburst_bitmaps[24].set_pixel(2, 2, starburst_color6)
        @starburst_bitmaps[24].set_pixel(4, 2, starburst_color6)
        @starburst_bitmaps[24].set_pixel(3, 3, starburst_color5)
        @starburst_bitmaps[24].set_pixel(2, 4, starburst_color5)
        @starburst_bitmaps[24].set_pixel(4, 4, starburst_color5)
        @starburst_bitmaps[24].set_pixel(1, 5, starburst_color5)
        @starburst_bitmaps[24].set_pixel(5, 5, starburst_color4)

        # 26th starburst bitmap
        @starburst_bitmaps[25] = Bitmap.new(7, 7)
        @starburst_bitmaps[25].fill_rect(3, 1, 1, 5, starburst_color6)
        @starburst_bitmaps[25].fill_rect(1, 3, 5, 1, starburst_color6)
        @starburst_bitmaps[25].fill_rect(3, 2, 1, 3, starburst_color5)
        @starburst_bitmaps[25].fill_rect(2, 3, 3, 1, starburst_color5)
        @starburst_bitmaps[25].set_pixel(3, 3, starburst_color4)

        # 27th starburst bitmap
        @starburst_bitmaps[26] = Bitmap.new(7, 7)
        @starburst_bitmaps[26].fill_rect(2, 1, 3, 5, starburst_color6)
        @starburst_bitmaps[26].fill_rect(1, 2, 5, 3, starburst_color6)
        @starburst_bitmaps[26].fill_rect(2, 2, 3, 3, starburst_color5)
        @starburst_bitmaps[26].fill_rect(3, 1, 1, 5, starburst_color5)
        @starburst_bitmaps[26].fill_rect(1, 3, 5, 1, starburst_color5)
        @starburst_bitmaps[26].fill_rect(3, 2, 1, 3, starburst_color4)
        @starburst_bitmaps[26].fill_rect(2, 3, 3, 1, starburst_color4)
        @starburst_bitmaps[26].set_pixel(3, 3, starburst_color4)

        # 28th starburst bitmap
        @starburst_bitmaps[27] = Bitmap.new(7, 7)
        @starburst_bitmaps[27].fill_rect(2, 1, 3, 5, starburst_color5)
        @starburst_bitmaps[27].fill_rect(1, 2, 5, 3, starburst_color5)
        @starburst_bitmaps[27].fill_rect(3, 0, 1, 7, starburst_color6)
        @starburst_bitmaps[27].fill_rect(0, 3, 7, 1, starburst_color6)
        @starburst_bitmaps[27].fill_rect(2, 2, 3, 3, starburst_color4)
        @starburst_bitmaps[27].fill_rect(3, 2, 1, 3, starburst_color5)
        @starburst_bitmaps[27].fill_rect(2, 3, 3, 1, starburst_color5)
        @starburst_bitmaps[27].set_pixel(3, 3, starburst_color4)

        # 29th starburst bitmap
        @starburst_bitmaps[28] = Bitmap.new(8, 8)
        @starburst_bitmaps[28].fill_rect(3, 2, 1, 3, starburst_color5)
        @starburst_bitmaps[28].fill_rect(2, 3, 3, 1, starburst_color5)
        @starburst_bitmaps[28].set_pixel(3, 3, starburst_color4)

        # 30th starburst bitmap
        @starburst_bitmaps[29] = Bitmap.new(8, 8)
        @starburst_bitmaps[29].fill_rect(3, 2, 1, 3, starburst_color17)
        @starburst_bitmaps[29].fill_rect(2, 3, 3, 1, starburst_color17)
        @starburst_bitmaps[29].set_pixel(3, 3, starburst_color16)

        # 31st starburst bitmap
        @starburst_bitmaps[30] = Bitmap.new(7, 7)
        @starburst_bitmaps[30].set_pixel(1, 1, starburst_color18)
        @starburst_bitmaps[30].set_pixel(5, 1, starburst_color18)
        @starburst_bitmaps[30].set_pixel(2, 2, starburst_color18)
        @starburst_bitmaps[30].set_pixel(4, 2, starburst_color18)
        @starburst_bitmaps[30].set_pixel(3, 3, starburst_color17)
        @starburst_bitmaps[30].set_pixel(2, 4, starburst_color17)
        @starburst_bitmaps[30].set_pixel(4, 4, starburst_color17)
        @starburst_bitmaps[30].set_pixel(1, 5, starburst_color17)
        @starburst_bitmaps[30].set_pixel(5, 5, starburst_color16)

        # 32nd starburst bitmap
        @starburst_bitmaps[31] = Bitmap.new(7, 7)
        @starburst_bitmaps[31].fill_rect(3, 1, 1, 5, starburst_color18)
        @starburst_bitmaps[31].fill_rect(1, 3, 5, 1, starburst_color18)
        @starburst_bitmaps[31].fill_rect(3, 2, 1, 3, starburst_color17)
        @starburst_bitmaps[31].fill_rect(2, 3, 3, 1, starburst_color17)
        @starburst_bitmaps[31].set_pixel(3, 3, starburst_color16)

        # 33rd starburst bitmap
        @starburst_bitmaps[32] = Bitmap.new(7, 7)
        @starburst_bitmaps[32].fill_rect(2, 1, 3, 5, starburst_color18)
        @starburst_bitmaps[32].fill_rect(1, 2, 5, 3, starburst_color18)
        @starburst_bitmaps[32].fill_rect(2, 2, 3, 3, starburst_color17)
        @starburst_bitmaps[32].fill_rect(3, 1, 1, 5, starburst_color17)
        @starburst_bitmaps[32].fill_rect(1, 3, 5, 1, starburst_color17)
        @starburst_bitmaps[32].fill_rect(3, 2, 1, 3, starburst_color16)
        @starburst_bitmaps[32].fill_rect(2, 3, 3, 1, starburst_color16)
        @starburst_bitmaps[32].set_pixel(3, 3, starburst_color16)

        # 34th starburst bitmap
        @starburst_bitmaps[33] = Bitmap.new(7, 7)
        @starburst_bitmaps[33].fill_rect(2, 1, 3, 5, starburst_color17)
        @starburst_bitmaps[33].fill_rect(1, 2, 5, 3, starburst_color17)
        @starburst_bitmaps[33].fill_rect(3, 0, 1, 7, starburst_color18)
        @starburst_bitmaps[33].fill_rect(0, 3, 7, 1, starburst_color18)
        @starburst_bitmaps[33].fill_rect(2, 2, 3, 3, starburst_color16)
        @starburst_bitmaps[33].fill_rect(3, 2, 1, 3, starburst_color17)
        @starburst_bitmaps[33].fill_rect(2, 3, 3, 1, starburst_color17)
        @starburst_bitmaps[33].set_pixel(3, 3, starburst_color16)

        # 35th starburst bitmap
        @starburst_bitmaps[34] = Bitmap.new(8, 8)
        @starburst_bitmaps[34].fill_rect(3, 2, 1, 3, starburst_color17)
        @starburst_bitmaps[34].fill_rect(2, 3, 3, 1, starburst_color17)
        @starburst_bitmaps[34].set_pixel(3, 3, starburst_color16)

        # 36th starburst bitmap
        @starburst_bitmaps[35] = Bitmap.new(8, 8)
        @starburst_bitmaps[35].set_pixel(3, 3, starburst_color16)
      end
      #-------------------------------------------------------------------------------
      # Monochrome starburst bitmaps
      if [:MonoBurst, :MonoUp, :MonoRain].include?(weather)
        @monostarburst_bitmaps = []
        case variant
          when 1 # Green
            monostarburst_color1 = Color.new(159, 232, 141)
            monostarburst_color2 = Color.new(198, 239, 189)
            monostarburst_color3 = Color.new(115, 216, 95)
          when 2 # Aqua-blue
            monostarburst_color1 = Color.new(139, 229, 217)
            monostarburst_color2 = Color.new(189, 237, 231)
            monostarburst_color3 = Color.new(94, 214, 202)
          when 3 # Blue
            monostarburst_color1 = Color.new(138, 153, 226)
            monostarburst_color2 = Color.new(187, 195, 234)
            monostarburst_color3 = Color.new(93, 108, 211)
          when 4 # Violet
            monostarburst_color1 = Color.new(205, 139, 224)
            monostarburst_color2 = Color.new(221, 185, 232)
            monostarburst_color3 = Color.new(189, 94, 209)
          when 5 # Red
            monostarburst_color1 = Color.new(221, 139, 161)
            monostarburst_color2 = Color.new(229, 183, 196)
            monostarburst_color3 = Color.new(206, 92, 117)
          when 6 # Black
            monostarburst_color1 = Color.new(-255, -255, -255)
            monostarburst_color2 = Color.new(85, -204, -255)
            monostarburst_color3 = Color.new(-255, -255, -255)
          else # Yellow (Default)
            monostarburst_color1 = Color.new(233, 210, 142)
            monostarburst_color2 = Color.new(242, 229, 190)
            monostarburst_color3 = Color.new(219, 191, 95)
        end

        # 1st starburst bitmap
        @monostarburst_bitmaps[0] = Bitmap.new(8, 8)
        @monostarburst_bitmaps[0].set_pixel(3, 3, monostarburst_color2)

        # 2nd starburst bitmap
        @monostarburst_bitmaps[1] = Bitmap.new(8, 8)
        @monostarburst_bitmaps[1].fill_rect(3, 2, 1, 3, monostarburst_color1)
        @monostarburst_bitmaps[1].fill_rect(2, 3, 3, 1, monostarburst_color1)
        @monostarburst_bitmaps[1].set_pixel(3, 3, monostarburst_color2)

        # 3d starburst bitmap
        @monostarburst_bitmaps[2] = Bitmap.new(7, 7)
        @monostarburst_bitmaps[2].set_pixel(1, 1, monostarburst_color3)
        @monostarburst_bitmaps[2].set_pixel(5, 1, monostarburst_color3)
        @monostarburst_bitmaps[2].set_pixel(2, 2, monostarburst_color3)
        @monostarburst_bitmaps[2].set_pixel(4, 2, monostarburst_color3)
        @monostarburst_bitmaps[2].set_pixel(3, 3, monostarburst_color1)
        @monostarburst_bitmaps[2].set_pixel(2, 4, monostarburst_color1)
        @monostarburst_bitmaps[2].set_pixel(4, 4, monostarburst_color1)
        @monostarburst_bitmaps[2].set_pixel(1, 5, monostarburst_color1)
        @monostarburst_bitmaps[2].set_pixel(5, 5, monostarburst_color2)

        # 4th starburst bitmap
        @monostarburst_bitmaps[3] = Bitmap.new(7, 7)
        @monostarburst_bitmaps[3].fill_rect(3, 1, 1, 5, monostarburst_color3)
        @monostarburst_bitmaps[3].fill_rect(1, 3, 5, 1, monostarburst_color3)
        @monostarburst_bitmaps[3].fill_rect(3, 2, 1, 3, monostarburst_color1)
        @monostarburst_bitmaps[3].fill_rect(2, 3, 3, 1, monostarburst_color1)
        @monostarburst_bitmaps[3].set_pixel(3, 3, monostarburst_color2)

        # 5th starburst bitmap
        @monostarburst_bitmaps[4] = Bitmap.new(7, 7)
        @monostarburst_bitmaps[4].fill_rect(2, 1, 3, 5, monostarburst_color3)
        @monostarburst_bitmaps[4].fill_rect(1, 2, 5, 3, monostarburst_color3)
        @monostarburst_bitmaps[4].fill_rect(2, 2, 3, 3, monostarburst_color1)
        @monostarburst_bitmaps[4].fill_rect(3, 1, 1, 5, monostarburst_color1)
        @monostarburst_bitmaps[4].fill_rect(1, 3, 5, 1, monostarburst_color1)
        @monostarburst_bitmaps[4].fill_rect(3, 2, 1, 3, monostarburst_color2)
        @monostarburst_bitmaps[4].fill_rect(2, 3, 3, 1, monostarburst_color2)
        @monostarburst_bitmaps[4].set_pixel(3, 3, monostarburst_color2)

        # 6th starburst bitmap
        @monostarburst_bitmaps[5] = Bitmap.new(7, 7)
        @monostarburst_bitmaps[5].fill_rect(2, 1, 3, 5, monostarburst_color1)
        @monostarburst_bitmaps[5].fill_rect(1, 2, 5, 3, monostarburst_color1)
        @monostarburst_bitmaps[5].fill_rect(3, 0, 1, 7, monostarburst_color3)
        @monostarburst_bitmaps[5].fill_rect(0, 3, 7, 1, monostarburst_color3)
        @monostarburst_bitmaps[5].fill_rect(2, 2, 3, 3, monostarburst_color2)
        @monostarburst_bitmaps[5].fill_rect(3, 2, 1, 3, monostarburst_color1)
        @monostarburst_bitmaps[5].fill_rect(2, 3, 3, 1, monostarburst_color1)
        @monostarburst_bitmaps[5].set_pixel(3, 3, monostarburst_color2)

        # 7th starburst bitmap
        @monostarburst_bitmaps[6] = Bitmap.new(8, 8)
        @monostarburst_bitmaps[6].fill_rect(3, 2, 1, 3, monostarburst_color1)
        @monostarburst_bitmaps[6].fill_rect(2, 3, 3, 1, monostarburst_color1)
        @monostarburst_bitmaps[6].set_pixel(3, 3, monostarburst_color2)

        # 8th starburst bitmap
        @monostarburst_bitmaps[7] = Bitmap.new(8, 8)
        @monostarburst_bitmaps[7].set_pixel(3, 3, monostarburst_color2)
      end
      #-------------------------------------------------------------------------------
      # Falling rock bitmaps
      if weather == :FallingRocks
        @fallingrocks_bitmaps = []
        rock_color1 = Color.new(173, 145, 127)
        rock_color2 = Color.new(195, 159, 153)
        rock_color3 = Color.new(128, 120, 112)
        rock_color4 = Color.new(99, 92, 116)
        rock_color5 = Color.new(107, 89, 79)
        rock_color6 = Color.new(130, 110, 97)
        rock_color7 = Color.new(214, 181, 150)
        rock_color8 = Color.new(155, 129, 112)
        rock_color9 = Color.new(193, 177, 180)
        rock_color10 = Color.new(180, 180, 180)

        # 1st falling rock bitmap
        @fallingrocks_bitmaps[0] = Bitmap.new(10, 7)
        @fallingrocks_bitmaps[0].fill_rect(3, 0, 3, 1, rock_color1)
        @fallingrocks_bitmaps[0].fill_rect(1, 1, 2, 1, rock_color1)
        @fallingrocks_bitmaps[0].set_pixel(3, 1, rock_color10)
        @fallingrocks_bitmaps[0].fill_rect(4, 1, 1, 3, rock_color9)
        @fallingrocks_bitmaps[0].set_pixel(5, 1, rock_color2)
        @fallingrocks_bitmaps[0].set_pixel(6, 1, rock_color1)
        @fallingrocks_bitmaps[0].set_pixel(0, 2, rock_color1)
        @fallingrocks_bitmaps[0].fill_rect(1, 2, 3, 1, rock_color7)
        @fallingrocks_bitmaps[0].set_pixel(5, 2, rock_color9)
        @fallingrocks_bitmaps[0].set_pixel(6, 2, rock_color2)
        @fallingrocks_bitmaps[0].set_pixel(7, 2, rock_color3)
        @fallingrocks_bitmaps[0].fill_rect(8, 2, 2, 3, rock_color4)
        @fallingrocks_bitmaps[0].set_pixel(0, 3, rock_color3)
        @fallingrocks_bitmaps[0].set_pixel(1, 3, rock_color10)
        @fallingrocks_bitmaps[0].set_pixel(2, 3, rock_color7)
        @fallingrocks_bitmaps[0].set_pixel(3, 3, rock_color10)
        @fallingrocks_bitmaps[0].set_pixel(5, 3, rock_color2)
        @fallingrocks_bitmaps[0].set_pixel(6, 3, rock_color1)
        @fallingrocks_bitmaps[0].set_pixel(7, 3, rock_color5)
        @fallingrocks_bitmaps[0].fill_rect(0, 4, 2, 1, rock_color5)
        @fallingrocks_bitmaps[0].set_pixel(2, 4, rock_color3)
        @fallingrocks_bitmaps[0].set_pixel(3, 4, rock_color9)
        @fallingrocks_bitmaps[0].set_pixel(4, 4, rock_color2)
        @fallingrocks_bitmaps[0].set_pixel(5, 4, rock_color1)
        @fallingrocks_bitmaps[0].set_pixel(6, 4, rock_color8)
        @fallingrocks_bitmaps[0].set_pixel(7, 4, rock_color3)
        @fallingrocks_bitmaps[0].set_pixel(1, 5, rock_color4)
        @fallingrocks_bitmaps[0].fill_rect(2, 5, 2, 1, rock_color5)
        @fallingrocks_bitmaps[0].fill_rect(4, 5, 2, 1, rock_color3)
        @fallingrocks_bitmaps[0].fill_rect(6, 5, 2, 1, rock_color5)
        @fallingrocks_bitmaps[0].set_pixel(8, 5, rock_color4)
        @fallingrocks_bitmaps[0].fill_rect(3, 6, 5, 1, rock_color4)

        # 2nd falling rock bitmap
        @fallingrocks_bitmaps[1] = Bitmap.new(5, 4)
        @fallingrocks_bitmaps[1].set_pixel(1, 0, rock_color8)
        @fallingrocks_bitmaps[1].set_pixel(2, 0, rock_color1)
        @fallingrocks_bitmaps[1].set_pixel(3, 0, rock_color6)
        @fallingrocks_bitmaps[1].set_pixel(0, 1, rock_color6)
        @fallingrocks_bitmaps[1].set_pixel(1, 1, rock_color1)
        @fallingrocks_bitmaps[1].set_pixel(2, 1, rock_color2)
        @fallingrocks_bitmaps[1].set_pixel(3, 1, rock_color1)
        @fallingrocks_bitmaps[1].set_pixel(4, 1, rock_color5)
        @fallingrocks_bitmaps[1].fill_rect(0, 2, 1, 2, rock_color4)
        @fallingrocks_bitmaps[1].fill_rect(1, 2, 2, 1, rock_color6)
        @fallingrocks_bitmaps[1].set_pixel(3, 2, rock_color5)
        @fallingrocks_bitmaps[1].fill_rect(1, 3, 3, 1, rock_color4)

        # 3rd falling rock bitmap
        @fallingrocks_bitmaps[2] = Bitmap.new(7, 6)
        @fallingrocks_bitmaps[2].set_pixel(2, 0, rock_color4)
        @fallingrocks_bitmaps[2].set_pixel(3, 0, rock_color3)
        @fallingrocks_bitmaps[2].set_pixel(4, 0, rock_color8)
        @fallingrocks_bitmaps[2].set_pixel(5, 0, rock_color6)
        @fallingrocks_bitmaps[2].set_pixel(1, 1, rock_color3)
        @fallingrocks_bitmaps[2].set_pixel(2, 1, rock_color8)
        @fallingrocks_bitmaps[2].set_pixel(3, 1, rock_color2)
        @fallingrocks_bitmaps[2].fill_rect(4, 1, 1, 2, rock_color9)
        @fallingrocks_bitmaps[2].set_pixel(5, 1, rock_color8)
        @fallingrocks_bitmaps[2].fill_rect(6, 1, 1, 3, rock_color4)
        @fallingrocks_bitmaps[2].set_pixel(0, 2, rock_color3)
        @fallingrocks_bitmaps[2].set_pixel(1, 2, rock_color8)
        @fallingrocks_bitmaps[2].set_pixel(2, 2, rock_color2)
        @fallingrocks_bitmaps[2].fill_rect(3, 2, 1, 2, rock_color9)
        @fallingrocks_bitmaps[2].set_pixel(5, 2, rock_color6)
        @fallingrocks_bitmaps[2].set_pixel(0, 3, rock_color6)
        @fallingrocks_bitmaps[2].set_pixel(1, 3, rock_color2)
        @fallingrocks_bitmaps[2].set_pixel(2, 3, rock_color7)
        @fallingrocks_bitmaps[2].set_pixel(4, 3, rock_color6)
        @fallingrocks_bitmaps[2].fill_rect(5, 3, 1, 2, rock_color4)
        @fallingrocks_bitmaps[2].set_pixel(0, 4, rock_color5)
        @fallingrocks_bitmaps[2].set_pixel(1, 4, rock_color6)
        @fallingrocks_bitmaps[2].set_pixel(2, 4, rock_color9)
        @fallingrocks_bitmaps[2].set_pixel(3, 4, rock_color6)
        @fallingrocks_bitmaps[2].fill_rect(4, 4, 1, 2, rock_color4)
        @fallingrocks_bitmaps[2].set_pixel(0, 5, rock_color6)
        @fallingrocks_bitmaps[2].fill_rect(1, 5, 2, 1, rock_color5)
        @fallingrocks_bitmaps[2].set_pixel(3, 5, rock_color4)
      end
      #-------------------------------------------------------------------------------
      # Arrows
      if weather == :Arrows
        arrow_color1 = Color.new(38, 0, 0)
        arrow_color2 = Color.new(73, 10, 42)
        arrow_color3 = Color.new(80, 50, 20)
        arrow_color4 = Color.new(255, 255, 255)
        arrow_color5 = Color.new(180, 180, 180)

        @arrow_bitmap = Bitmap.new(23, 23)
        @arrow_bitmap.fill_rect(19, 0, 1, 3, arrow_color4)
        @arrow_bitmap.fill_rect(20, 0, 1, 2, arrow_color5)
        @arrow_bitmap.set_pixel(22, 0, arrow_color3)
        @arrow_bitmap.fill_rect(18, 1, 1, 3, arrow_color5)
        @arrow_bitmap.set_pixel(21, 1, arrow_color3)
        @arrow_bitmap.fill_rect(17, 2, 1, 3, arrow_color4)
        @arrow_bitmap.set_pixel(20, 2, arrow_color3)
        @arrow_bitmap.fill_rect(21, 2, 2, 1, arrow_color5)
        @arrow_bitmap.set_pixel(19, 3, arrow_color3)
        @arrow_bitmap.fill_rect(20, 3, 3, 1, arrow_color4)
        @arrow_bitmap.set_pixel(18, 4, arrow_color3)
        @arrow_bitmap.fill_rect(19, 4, 3, 1, arrow_color5)
        @arrow_bitmap.set_pixel(17, 5, arrow_color3)
        @arrow_bitmap.fill_rect(18, 5, 3, 1, arrow_color4)
        @arrow_bitmap.set_pixel(16, 6, arrow_color3)
        @arrow_bitmap.set_pixel(15, 7, arrow_color3)
        @arrow_bitmap.set_pixel(14, 8, arrow_color3)
        @arrow_bitmap.set_pixel(13, 9, arrow_color3)
        @arrow_bitmap.set_pixel(12, 10, arrow_color3)
        @arrow_bitmap.set_pixel(11, 11, arrow_color3)
        @arrow_bitmap.set_pixel(10, 12, arrow_color3)
        @arrow_bitmap.set_pixel(9, 13, arrow_color3)
        @arrow_bitmap.set_pixel(8, 14, arrow_color3)
        @arrow_bitmap.set_pixel(7, 15, arrow_color3)
        @arrow_bitmap.set_pixel(6, 16, arrow_color3)
        @arrow_bitmap.set_pixel(5, 17, arrow_color3)
        @arrow_bitmap.set_pixel(4, 18, arrow_color3)
        @arrow_bitmap.fill_rect(1, 19, 3, 1, arrow_color1)
        @arrow_bitmap.fill_rect(0, 20, 1, 3, arrow_color1)
        @arrow_bitmap.set_pixel(1, 20, arrow_color2)
        @arrow_bitmap.set_pixel(2, 20, arrow_color5)
        @arrow_bitmap.fill_rect(3, 20, 1, 2, arrow_color1)
        @arrow_bitmap.set_pixel(1, 21, arrow_color5)
        @arrow_bitmap.set_pixel(2, 21, arrow_color2)
        @arrow_bitmap.fill_rect(1, 22, 2, 1, arrow_color1)
      end
      #-------------------------------------------------------------------------------
      # Butterflies
      if weather == :Butterflies
        @butterfly_bitmaps = []
        case variant
          when 1
            # Red butterflies
            butterfly_color1 = Color.new(204, 53, 55)
            butterfly_color2 = Color.new(206, 76, 74)
            butterfly_color3 = Color.new(252, 131, 137)
            butterfly_color4 = Color.new(255, 178, 163)
            butterfly_color5 = Color.new(175, 35, 49)
          when 2
            # Yellow butterflies
            butterfly_color1 = Color.new(209, 190, 75)
            butterfly_color2 = Color.new(254, 228, 131)
            butterfly_color3 = Color.new(205, 178, 52)
            butterfly_color4 = Color.new(255, 255, 162)
            butterfly_color5 = Color.new(177, 141, 34)
          when 3
            # Aqua-blue butterflies
            butterfly_color1 = Color.new(53, 204, 201)
            butterfly_color2 = Color.new(73, 204, 204)
            butterfly_color3 = Color.new(129, 249, 243)
            butterfly_color4 = Color.new(163, 241, 255)
            butterfly_color5 = Color.new(34, 173, 159)
          when 4
            # Green butterflies
            butterfly_color1 = Color.new(63, 204, 53)
            butterfly_color2 = Color.new(77, 204, 73)
            butterfly_color3 = Color.new(138, 247, 128)
            butterfly_color4 = Color.new(163, 255, 173)
            butterfly_color5 = Color.new(54, 170, 34)
          else
            # Violet butterflies
            butterfly_color1 = Color.new(163, 53, 204)
            butterfly_color2 = Color.new(173, 73, 204)
            butterfly_color3 = Color.new(209, 128, 242)
            butterfly_color4 = Color.new(247, 163, 255)
            butterfly_color5 = Color.new(121, 33, 165)
        end

        # Butterfly up 1
        @butterfly_bitmaps[0] = Bitmap.new(9, 6)
        @butterfly_bitmaps[0].fill_rect(1, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[0].fill_rect(6, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[0].fill_rect(0, 1, 1, 2, butterfly_color1)
        @butterfly_bitmaps[0].set_pixel(1, 1, butterfly_color2)
        @butterfly_bitmaps[0].fill_rect(2, 1, 1, 2, butterfly_color4)
        @butterfly_bitmaps[0].set_pixel(3, 1, butterfly_color1)
        @butterfly_bitmaps[0].set_pixel(5, 1, butterfly_color1)
        @butterfly_bitmaps[0].fill_rect(6, 1, 1, 2, butterfly_color4)
        @butterfly_bitmaps[0].set_pixel(7, 1, butterfly_color2)
        @butterfly_bitmaps[0].fill_rect(8, 1, 1, 2, butterfly_color1)
        @butterfly_bitmaps[0].set_pixel(1, 2, butterfly_color4)
        @butterfly_bitmaps[0].set_pixel(3, 2, butterfly_color4)
        @butterfly_bitmaps[0].set_pixel(4, 2, butterfly_color1)
        @butterfly_bitmaps[0].set_pixel(5, 2, butterfly_color4)
        @butterfly_bitmaps[0].set_pixel(7, 2, butterfly_color4)
        @butterfly_bitmaps[0].set_pixel(1, 3, butterfly_color5)
        @butterfly_bitmaps[0].fill_rect(2, 3, 2, 1, butterfly_color2)
        @butterfly_bitmaps[0].set_pixel(4, 3, butterfly_color5)
        @butterfly_bitmaps[0].fill_rect(5, 3, 2, 1, butterfly_color2)
        @butterfly_bitmaps[0].set_pixel(7, 3, butterfly_color5)
        @butterfly_bitmaps[0].fill_rect(1, 4, 1, 2, butterfly_color1)
        @butterfly_bitmaps[0].set_pixel(2, 4, butterfly_color4)
        @butterfly_bitmaps[0].set_pixel(3, 4, butterfly_color5)
        @butterfly_bitmaps[0].set_pixel(5, 4, butterfly_color5)
        @butterfly_bitmaps[0].set_pixel(6, 4, butterfly_color4)
        @butterfly_bitmaps[0].fill_rect(7, 4, 1, 2, butterfly_color1)
        @butterfly_bitmaps[0].set_pixel(2, 5, butterfly_color1)
        @butterfly_bitmaps[0].set_pixel(6, 5, butterfly_color1)

        # Butterfly up 2
        @butterfly_bitmaps[1] = Bitmap.new(9, 6)
        @butterfly_bitmaps[1].fill_rect(2, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[1].fill_rect(5, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[1].fill_rect(0, 1, 1, 2, butterfly_color1)
        @butterfly_bitmaps[1].fill_rect(1, 1, 3, 1, butterfly_color4)
        @butterfly_bitmaps[1].fill_rect(4, 1, 1, 2, butterfly_color1)
        @butterfly_bitmaps[1].fill_rect(5, 1, 3, 1, butterfly_color4)
        @butterfly_bitmaps[1].fill_rect(8, 1, 1, 2, butterfly_color1)
        @butterfly_bitmaps[1].fill_rect(1, 2, 2, 1, butterfly_color4)
        @butterfly_bitmaps[1].set_pixel(3, 2, butterfly_color2)
        @butterfly_bitmaps[1].set_pixel(5, 2, butterfly_color2)
        @butterfly_bitmaps[1].fill_rect(6, 2, 2, 1, butterfly_color4)
        @butterfly_bitmaps[1].set_pixel(1, 3, butterfly_color5)
        @butterfly_bitmaps[1].fill_rect(2, 3, 2, 1, butterfly_color1)
        @butterfly_bitmaps[1].set_pixel(4, 3, butterfly_color5)
        @butterfly_bitmaps[1].fill_rect(5, 3, 2, 1, butterfly_color1)
        @butterfly_bitmaps[1].set_pixel(7, 3, butterfly_color5)
        @butterfly_bitmaps[1].set_pixel(1, 4, butterfly_color1)
        @butterfly_bitmaps[1].set_pixel(2, 4, butterfly_color2)
        @butterfly_bitmaps[1].set_pixel(3, 4, butterfly_color5)
        @butterfly_bitmaps[1].set_pixel(5, 4, butterfly_color5)
        @butterfly_bitmaps[1].set_pixel(6, 4, butterfly_color2)
        @butterfly_bitmaps[1].set_pixel(7, 4, butterfly_color1)
        @butterfly_bitmaps[1].set_pixel(2, 5, butterfly_color1)
        @butterfly_bitmaps[1].set_pixel(6, 5, butterfly_color1)

        # Butterfly up 3
        @butterfly_bitmaps[2] = Bitmap.new(9, 6)
        @butterfly_bitmaps[2].fill_rect(1, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[2].fill_rect(6, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[2].fill_rect(0, 1, 1, 2, butterfly_color1)
        @butterfly_bitmaps[2].set_pixel(1, 1, butterfly_color2)
        @butterfly_bitmaps[2].fill_rect(2, 1, 1, 2, butterfly_color4)
        @butterfly_bitmaps[2].set_pixel(3, 1, butterfly_color1)
        @butterfly_bitmaps[2].set_pixel(5, 1, butterfly_color1)
        @butterfly_bitmaps[2].fill_rect(6, 1, 1, 2, butterfly_color4)
        @butterfly_bitmaps[2].set_pixel(7, 1, butterfly_color2)
        @butterfly_bitmaps[2].fill_rect(8, 1, 1, 2, butterfly_color1)
        @butterfly_bitmaps[2].set_pixel(1, 2, butterfly_color4)
        @butterfly_bitmaps[2].set_pixel(3, 2, butterfly_color4)
        @butterfly_bitmaps[2].set_pixel(4, 2, butterfly_color1)
        @butterfly_bitmaps[2].set_pixel(5, 2, butterfly_color4)
        @butterfly_bitmaps[2].set_pixel(7, 2, butterfly_color4)
        @butterfly_bitmaps[2].set_pixel(1, 3, butterfly_color5)
        @butterfly_bitmaps[2].fill_rect(2, 3, 2, 1, butterfly_color2)
        @butterfly_bitmaps[2].set_pixel(4, 3, butterfly_color5)
        @butterfly_bitmaps[2].fill_rect(5, 3, 2, 1, butterfly_color2)
        @butterfly_bitmaps[2].set_pixel(7, 3, butterfly_color5)
        @butterfly_bitmaps[2].fill_rect(1, 4, 1, 2, butterfly_color1)
        @butterfly_bitmaps[2].set_pixel(2, 4, butterfly_color4)
        @butterfly_bitmaps[2].set_pixel(3, 4, butterfly_color5)
        @butterfly_bitmaps[2].set_pixel(5, 4, butterfly_color5)
        @butterfly_bitmaps[2].set_pixel(6, 4, butterfly_color4)
        @butterfly_bitmaps[2].fill_rect(7, 4, 1, 2, butterfly_color1)
        @butterfly_bitmaps[2].set_pixel(2, 5, butterfly_color1)
        @butterfly_bitmaps[2].set_pixel(6, 5, butterfly_color1)

        # Butterfly up 4
        @butterfly_bitmaps[3] = Bitmap.new(7, 6)
        @butterfly_bitmaps[3].fill_rect(1, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[3].fill_rect(4, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[3].fill_rect(0, 1, 1, 2, butterfly_color1)
        @butterfly_bitmaps[3].fill_rect(1, 1, 2, 2, butterfly_color4)
        @butterfly_bitmaps[3].fill_rect(4, 1, 2, 2, butterfly_color4)
        @butterfly_bitmaps[3].fill_rect(6, 1, 1, 2, butterfly_color1)
        @butterfly_bitmaps[3].fill_rect(3, 2, 1, 2, butterfly_color1)
        @butterfly_bitmaps[3].set_pixel(1, 3, butterfly_color5)
        @butterfly_bitmaps[3].fill_rect(2, 3, 1, 2, butterfly_color2)
        @butterfly_bitmaps[3].fill_rect(4, 3, 1, 2, butterfly_color2)
        @butterfly_bitmaps[3].set_pixel(5, 3, butterfly_color5)
        @butterfly_bitmaps[3].set_pixel(1, 4, butterfly_color2)
        @butterfly_bitmaps[3].set_pixel(3, 4, butterfly_color5)
        @butterfly_bitmaps[3].set_pixel(5, 4, butterfly_color2)
        @butterfly_bitmaps[3].set_pixel(1, 5, butterfly_color1)
        @butterfly_bitmaps[3].set_pixel(2, 5, butterfly_color5)
        @butterfly_bitmaps[3].set_pixel(4, 5, butterfly_color5)
        @butterfly_bitmaps[3].set_pixel(5, 5, butterfly_color1)

        # Butterfly down 1
        @butterfly_bitmaps[4] = Bitmap.new(9, 6)
        @butterfly_bitmaps[4].fill_rect(1, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[4].fill_rect(6, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[4].set_pixel(1, 1, butterfly_color1)
        @butterfly_bitmaps[4].set_pixel(2, 1, butterfly_color4)
        @butterfly_bitmaps[4].set_pixel(3, 1, butterfly_color5)
        @butterfly_bitmaps[4].set_pixel(5, 1, butterfly_color5)
        @butterfly_bitmaps[4].set_pixel(6, 1, butterfly_color4)
        @butterfly_bitmaps[4].set_pixel(7, 1, butterfly_color1)
        @butterfly_bitmaps[4].set_pixel(1, 2, butterfly_color5)
        @butterfly_bitmaps[4].fill_rect(2, 2, 2, 1, butterfly_color2)
        @butterfly_bitmaps[4].set_pixel(4, 2, butterfly_color5)
        @butterfly_bitmaps[4].fill_rect(5, 2, 2, 1, butterfly_color2)
        @butterfly_bitmaps[4].set_pixel(7, 2, butterfly_color5)
        @butterfly_bitmaps[4].fill_rect(0, 3, 1, 2, butterfly_color1)
        @butterfly_bitmaps[4].fill_rect(1, 3, 3, 1, butterfly_color4)
        @butterfly_bitmaps[4].set_pixel(4, 3, butterfly_color1)
        @butterfly_bitmaps[4].fill_rect(5, 3, 3, 1, butterfly_color4)
        @butterfly_bitmaps[4].fill_rect(8, 3, 1, 2, butterfly_color1)
        @butterfly_bitmaps[4].set_pixel(1, 4, butterfly_color2)
        @butterfly_bitmaps[4].set_pixel(2, 4, butterfly_color4)
        @butterfly_bitmaps[4].set_pixel(3, 4, butterfly_color1)
        @butterfly_bitmaps[4].set_pixel(5, 4, butterfly_color1)
        @butterfly_bitmaps[4].set_pixel(6, 4, butterfly_color4)
        @butterfly_bitmaps[4].set_pixel(7, 4, butterfly_color2)
        @butterfly_bitmaps[4].fill_rect(1, 5, 2, 1, butterfly_color1)
        @butterfly_bitmaps[4].fill_rect(6, 5, 2, 1, butterfly_color1)

        # Butterfly down 2
        @butterfly_bitmaps[5] = Bitmap.new(9, 6)
        @butterfly_bitmaps[5].set_pixel(2, 0, butterfly_color1)
        @butterfly_bitmaps[5].set_pixel(6, 0, butterfly_color1)
        @butterfly_bitmaps[5].set_pixel(1, 1, butterfly_color1)
        @butterfly_bitmaps[5].set_pixel(2, 1, butterfly_color2)
        @butterfly_bitmaps[5].set_pixel(3, 1, butterfly_color5)
        @butterfly_bitmaps[5].set_pixel(5, 1, butterfly_color5)
        @butterfly_bitmaps[5].set_pixel(6, 1, butterfly_color2)
        @butterfly_bitmaps[5].set_pixel(7, 1, butterfly_color1)
        @butterfly_bitmaps[5].set_pixel(1, 2, butterfly_color5)
        @butterfly_bitmaps[5].fill_rect(2, 2, 2, 1, butterfly_color1)
        @butterfly_bitmaps[5].set_pixel(4, 2, butterfly_color5)
        @butterfly_bitmaps[5].fill_rect(5, 2, 2, 1, butterfly_color1)
        @butterfly_bitmaps[5].set_pixel(7, 2, butterfly_color5)
        @butterfly_bitmaps[5].fill_rect(0, 3, 1, 2, butterfly_color1)
        @butterfly_bitmaps[5].fill_rect(1, 3, 2, 2, butterfly_color4)
        @butterfly_bitmaps[5].set_pixel(3, 3, butterfly_color2)
        @butterfly_bitmaps[5].fill_rect(4, 3, 1, 2, butterfly_color1)
        @butterfly_bitmaps[5].set_pixel(5, 3, butterfly_color2)
        @butterfly_bitmaps[5].fill_rect(6, 3, 2, 2, butterfly_color4)
        @butterfly_bitmaps[5].fill_rect(8, 3, 1, 2, butterfly_color1)
        @butterfly_bitmaps[5].set_pixel(3, 4, butterfly_color4)
        @butterfly_bitmaps[5].set_pixel(5, 4, butterfly_color4)
        @butterfly_bitmaps[5].fill_rect(2, 5, 2, 1, butterfly_color1)
        @butterfly_bitmaps[5].fill_rect(5, 5, 2, 1, butterfly_color1)

        # Butterfly down 3
        @butterfly_bitmaps[6] = Bitmap.new(9, 6)
        @butterfly_bitmaps[6].fill_rect(1, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[6].fill_rect(6, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[6].set_pixel(1, 1, butterfly_color1)
        @butterfly_bitmaps[6].set_pixel(2, 1, butterfly_color4)
        @butterfly_bitmaps[6].set_pixel(3, 1, butterfly_color5)
        @butterfly_bitmaps[6].set_pixel(5, 1, butterfly_color5)
        @butterfly_bitmaps[6].set_pixel(6, 1, butterfly_color4)
        @butterfly_bitmaps[6].set_pixel(7, 1, butterfly_color1)
        @butterfly_bitmaps[6].set_pixel(1, 2, butterfly_color5)
        @butterfly_bitmaps[6].fill_rect(2, 2, 2, 1, butterfly_color2)
        @butterfly_bitmaps[6].set_pixel(4, 2, butterfly_color5)
        @butterfly_bitmaps[6].fill_rect(5, 2, 2, 1, butterfly_color2)
        @butterfly_bitmaps[6].set_pixel(7, 2, butterfly_color5)
        @butterfly_bitmaps[6].fill_rect(0, 3, 1, 2, butterfly_color1)
        @butterfly_bitmaps[6].fill_rect(1, 3, 3, 1, butterfly_color4)
        @butterfly_bitmaps[6].set_pixel(4, 3, butterfly_color1)
        @butterfly_bitmaps[6].fill_rect(5, 3, 3, 1, butterfly_color4)
        @butterfly_bitmaps[6].fill_rect(8, 3, 1, 2, butterfly_color1)
        @butterfly_bitmaps[6].set_pixel(1, 4, butterfly_color2)
        @butterfly_bitmaps[6].set_pixel(2, 4, butterfly_color4)
        @butterfly_bitmaps[6].set_pixel(3, 4, butterfly_color1)
        @butterfly_bitmaps[6].set_pixel(5, 4, butterfly_color1)
        @butterfly_bitmaps[6].set_pixel(6, 4, butterfly_color4)
        @butterfly_bitmaps[6].set_pixel(7, 4, butterfly_color2)
        @butterfly_bitmaps[6].fill_rect(1, 5, 2, 1, butterfly_color1)
        @butterfly_bitmaps[6].fill_rect(6, 5, 2, 1, butterfly_color1)

        # Butterfly down 4
        @butterfly_bitmaps[7] = Bitmap.new(7, 6)
        @butterfly_bitmaps[7].set_pixel(1, 0, butterfly_color1)
        @butterfly_bitmaps[7].set_pixel(2, 0, butterfly_color5)
        @butterfly_bitmaps[7].set_pixel(4, 0, butterfly_color5)
        @butterfly_bitmaps[7].set_pixel(5, 0, butterfly_color1)
        @butterfly_bitmaps[7].fill_rect(1, 1, 2, 1, butterfly_color2)
        @butterfly_bitmaps[7].set_pixel(3, 1, butterfly_color5)
        @butterfly_bitmaps[7].fill_rect(4, 1, 2, 1, butterfly_color2)
        @butterfly_bitmaps[7].set_pixel(1, 2, butterfly_color5)
        @butterfly_bitmaps[7].set_pixel(2, 2, butterfly_color2)
        @butterfly_bitmaps[7].fill_rect(3, 2, 1, 2, butterfly_color1)
        @butterfly_bitmaps[7].set_pixel(4, 2, butterfly_color2)
        @butterfly_bitmaps[7].set_pixel(5, 2, butterfly_color5)
        @butterfly_bitmaps[7].fill_rect(0, 3, 1, 2, butterfly_color1)
        @butterfly_bitmaps[7].fill_rect(1, 3, 2, 2, butterfly_color4)
        @butterfly_bitmaps[7].fill_rect(4, 3, 2, 2, butterfly_color4)
        @butterfly_bitmaps[7].fill_rect(6, 3, 1, 2, butterfly_color1)
        @butterfly_bitmaps[7].fill_rect(1, 5, 2, 1, butterfly_color1)
        @butterfly_bitmaps[7].fill_rect(4, 5, 2, 1, butterfly_color1)

        # Butterfly left 1
        @butterfly_bitmaps[8] = Bitmap.new(7, 7)
        @butterfly_bitmaps[8].set_pixel(2, 0, butterfly_color3)
        @butterfly_bitmaps[8].fill_rect(3, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[8].fill_rect(0, 1, 2, 2, butterfly_color3)
        @butterfly_bitmaps[8].set_pixel(2, 1, butterfly_color2)
        @butterfly_bitmaps[8].fill_rect(3, 1, 1, 3, butterfly_color4)
        @butterfly_bitmaps[8].set_pixel(4, 1, butterfly_color2)
        @butterfly_bitmaps[8].fill_rect(5, 1, 1, 3, butterfly_color1)
        @butterfly_bitmaps[8].fill_rect(2, 2, 1, 2, butterfly_color4)
        @butterfly_bitmaps[8].set_pixel(4, 2, butterfly_color4)
        @butterfly_bitmaps[8].set_pixel(0, 3, butterfly_color3)
        @butterfly_bitmaps[8].fill_rect(1, 3, 1, 2, butterfly_color5)
        @butterfly_bitmaps[8].set_pixel(4, 3, butterfly_color2)
        @butterfly_bitmaps[8].fill_rect(2, 4, 2, 1, butterfly_color2)
        @butterfly_bitmaps[8].set_pixel(4, 4, butterfly_color1)
        @butterfly_bitmaps[8].set_pixel(5, 4, butterfly_color5)
        @butterfly_bitmaps[8].set_pixel(2, 5, butterfly_color5)
        @butterfly_bitmaps[8].set_pixel(3, 5, butterfly_color1)
        @butterfly_bitmaps[8].fill_rect(4, 5, 2, 1, butterfly_color2)
        @butterfly_bitmaps[8].set_pixel(6, 5, butterfly_color1)
        @butterfly_bitmaps[8].set_pixel(3, 6, butterfly_color5)
        @butterfly_bitmaps[8].fill_rect(4, 6, 2, 1, butterfly_color1)

        # Butterfly left 2
        @butterfly_bitmaps[9] = Bitmap.new(7, 6)
        @butterfly_bitmaps[9].fill_rect(1, 0, 2, 1, butterfly_color2)
        @butterfly_bitmaps[9].set_pixel(3, 0, butterfly_color1)
        @butterfly_bitmaps[9].fill_rect(0, 1, 1, 2, butterfly_color3)
        @butterfly_bitmaps[9].set_pixel(1, 1, butterfly_color2)
        @butterfly_bitmaps[9].set_pixel(2, 1, butterfly_color4)
        @butterfly_bitmaps[9].set_pixel(3, 1, butterfly_color2)
        @butterfly_bitmaps[9].set_pixel(4, 1, butterfly_color3)
        @butterfly_bitmaps[9].set_pixel(1, 2, butterfly_color5)
        @butterfly_bitmaps[9].set_pixel(2, 2, butterfly_color2)
        @butterfly_bitmaps[9].set_pixel(3, 2, butterfly_color4)
        @butterfly_bitmaps[9].fill_rect(4, 2, 1, 2, butterfly_color2)
        @butterfly_bitmaps[9].fill_rect(5, 2, 1, 2, butterfly_color3)
        @butterfly_bitmaps[9].set_pixel(2, 3, butterfly_color5)
        @butterfly_bitmaps[9].set_pixel(3, 3, butterfly_color3)
        @butterfly_bitmaps[9].set_pixel(4, 4, butterfly_color3)
        @butterfly_bitmaps[9].set_pixel(5, 4, butterfly_color2)
        @butterfly_bitmaps[9].set_pixel(6, 4, butterfly_color3)
        @butterfly_bitmaps[9].set_pixel(5, 5, butterfly_color3)
        @butterfly_bitmaps[9].set_pixel(6, 5, butterfly_color2)

        # Butterfly left 3
        @butterfly_bitmaps[10] = Bitmap.new(7, 6)
        @butterfly_bitmaps[10].fill_rect(2, 0, 2, 1, butterfly_color3)
        @butterfly_bitmaps[10].set_pixel(4, 0, butterfly_color5)
        @butterfly_bitmaps[10].fill_rect(0, 1, 2, 1, butterfly_color3)
        @butterfly_bitmaps[10].set_pixel(2, 1, butterfly_color2)
        @butterfly_bitmaps[10].fill_rect(3, 1, 2, 2, butterfly_color4)
        @butterfly_bitmaps[10].set_pixel(5, 1, butterfly_color5)
        @butterfly_bitmaps[10].set_pixel(0, 2, butterfly_color3)
        @butterfly_bitmaps[10].set_pixel(1, 2, butterfly_color2)
        @butterfly_bitmaps[10].fill_rect(2, 2, 1, 2, butterfly_color4)
        @butterfly_bitmaps[10].set_pixel(5, 2, butterfly_color3)
        @butterfly_bitmaps[10].set_pixel(1, 3, butterfly_color3)
        @butterfly_bitmaps[10].set_pixel(3, 3, butterfly_color2)
        @butterfly_bitmaps[10].set_pixel(4, 3, butterfly_color3)
        @butterfly_bitmaps[10].fill_rect(5, 3, 1, 2, butterfly_color2)
        @butterfly_bitmaps[10].fill_rect(6, 3, 1, 2, butterfly_color3)
        @butterfly_bitmaps[10].fill_rect(2, 4, 2, 1, butterfly_color3)
        @butterfly_bitmaps[10].set_pixel(4, 4, butterfly_color2)
        @butterfly_bitmaps[10].fill_rect(4, 5, 2, 1, butterfly_color3)

        # Butterfly left 4
        @butterfly_bitmaps[11] = Bitmap.new(7, 6)
        @butterfly_bitmaps[11].fill_rect(1, 0, 2, 1, butterfly_color2)
        @butterfly_bitmaps[11].set_pixel(3, 0, butterfly_color1)
        @butterfly_bitmaps[11].fill_rect(0, 1, 2, 1, butterfly_color3)
        @butterfly_bitmaps[11].set_pixel(2, 1, butterfly_color4)
        @butterfly_bitmaps[11].set_pixel(3, 1, butterfly_color2)
        @butterfly_bitmaps[11].set_pixel(4, 1, butterfly_color3)
        @butterfly_bitmaps[11].set_pixel(0, 2, butterfly_color3)
        @butterfly_bitmaps[11].set_pixel(1, 2, butterfly_color5)
        @butterfly_bitmaps[11].set_pixel(2, 2, butterfly_color2)
        @butterfly_bitmaps[11].set_pixel(3, 2, butterfly_color4)
        @butterfly_bitmaps[11].fill_rect(4, 2, 1, 2, butterfly_color2)
        @butterfly_bitmaps[11].fill_rect(5, 2, 1, 2, butterfly_color3)
        @butterfly_bitmaps[11].set_pixel(2, 3, butterfly_color5)
        @butterfly_bitmaps[11].set_pixel(3, 3, butterfly_color3)
        @butterfly_bitmaps[11].set_pixel(4, 4, butterfly_color3)
        @butterfly_bitmaps[11].set_pixel(5, 4, butterfly_color2)
        @butterfly_bitmaps[11].fill_rect(6, 4, 1, 2, butterfly_color3)
        @butterfly_bitmaps[11].set_pixel(5, 5, butterfly_color3)

        # Butterfly right 1
        @butterfly_bitmaps[12] = Bitmap.new(7, 7)
        @butterfly_bitmaps[12].fill_rect(2, 0, 2, 1, butterfly_color1)
        @butterfly_bitmaps[12].set_pixel(4, 0, butterfly_color3)
        @butterfly_bitmaps[12].fill_rect(1, 1, 1, 3, butterfly_color1)
        @butterfly_bitmaps[12].set_pixel(2, 1, butterfly_color2)
        @butterfly_bitmaps[12].fill_rect(3, 1, 1, 3, butterfly_color4)
        @butterfly_bitmaps[12].set_pixel(4, 1, butterfly_color2)
        @butterfly_bitmaps[12].fill_rect(5, 1, 2, 2, butterfly_color3)
        @butterfly_bitmaps[12].set_pixel(2, 2, butterfly_color4)
        @butterfly_bitmaps[12].fill_rect(4, 2, 1, 2, butterfly_color4)
        @butterfly_bitmaps[12].set_pixel(2, 3, butterfly_color2)
        @butterfly_bitmaps[12].fill_rect(5, 3, 1, 2, butterfly_color5)
        @butterfly_bitmaps[12].set_pixel(6, 3, butterfly_color3)
        @butterfly_bitmaps[12].set_pixel(1, 4, butterfly_color5)
        @butterfly_bitmaps[12].set_pixel(2, 4, butterfly_color1)
        @butterfly_bitmaps[12].fill_rect(3, 4, 2, 1, butterfly_color2)
        @butterfly_bitmaps[12].set_pixel(0, 5, butterfly_color1)
        @butterfly_bitmaps[12].fill_rect(1, 5, 2, 1, butterfly_color2)
        @butterfly_bitmaps[12].set_pixel(3, 5, butterfly_color1)
        @butterfly_bitmaps[12].set_pixel(4, 5, butterfly_color5)
        @butterfly_bitmaps[12].fill_rect(1, 6, 2, 1, butterfly_color1)
        @butterfly_bitmaps[12].set_pixel(3, 6, butterfly_color5)

        # Butterfly right 2
        @butterfly_bitmaps[13] = Bitmap.new(7, 6)
        @butterfly_bitmaps[13].set_pixel(3, 0, butterfly_color1)
        @butterfly_bitmaps[13].fill_rect(4, 0, 2, 1, butterfly_color2)
        @butterfly_bitmaps[13].set_pixel(2, 1, butterfly_color3)
        @butterfly_bitmaps[13].set_pixel(3, 1, butterfly_color2)
        @butterfly_bitmaps[13].set_pixel(4, 1, butterfly_color4)
        @butterfly_bitmaps[13].set_pixel(5, 1, butterfly_color2)
        @butterfly_bitmaps[13].fill_rect(6, 1, 1, 2, butterfly_color3)
        @butterfly_bitmaps[13].fill_rect(1, 2, 1, 2, butterfly_color3)
        @butterfly_bitmaps[13].fill_rect(2, 2, 1, 2, butterfly_color2)
        @butterfly_bitmaps[13].set_pixel(3, 2, butterfly_color4)
        @butterfly_bitmaps[13].set_pixel(4, 2, butterfly_color2)
        @butterfly_bitmaps[13].set_pixel(5, 2, butterfly_color5)
        @butterfly_bitmaps[13].set_pixel(3, 3, butterfly_color3)
        @butterfly_bitmaps[13].set_pixel(4, 3, butterfly_color5)
        @butterfly_bitmaps[13].set_pixel(0, 4, butterfly_color3)
        @butterfly_bitmaps[13].set_pixel(1, 4, butterfly_color2)
        @butterfly_bitmaps[13].set_pixel(2, 4, butterfly_color3)
        @butterfly_bitmaps[13].set_pixel(0, 5, butterfly_color2)
        @butterfly_bitmaps[13].set_pixel(1, 5, butterfly_color3)

        # Butterfly right 3
        @butterfly_bitmaps[14] = Bitmap.new(7, 6)
        @butterfly_bitmaps[14].set_pixel(2, 0, butterfly_color5)
        @butterfly_bitmaps[14].fill_rect(3, 0, 2, 1, butterfly_color3)
        @butterfly_bitmaps[14].set_pixel(1, 1, butterfly_color5)
        @butterfly_bitmaps[14].fill_rect(2, 1, 2, 2, butterfly_color4)
        @butterfly_bitmaps[14].set_pixel(4, 1, butterfly_color2)
        @butterfly_bitmaps[14].fill_rect(5, 1, 2, 1, butterfly_color3)
        @butterfly_bitmaps[14].set_pixel(1, 2, butterfly_color3)
        @butterfly_bitmaps[14].fill_rect(4, 2, 1, 2, butterfly_color4)
        @butterfly_bitmaps[14].set_pixel(5, 2, butterfly_color2)
        @butterfly_bitmaps[14].set_pixel(6, 2, butterfly_color3)
        @butterfly_bitmaps[14].fill_rect(0, 3, 1, 2, butterfly_color3)
        @butterfly_bitmaps[14].fill_rect(1, 3, 1, 2, butterfly_color2)
        @butterfly_bitmaps[14].set_pixel(2, 3, butterfly_color3)
        @butterfly_bitmaps[14].set_pixel(3, 3, butterfly_color2)
        @butterfly_bitmaps[14].set_pixel(5, 3, butterfly_color3)
        @butterfly_bitmaps[14].set_pixel(2, 4, butterfly_color2)
        @butterfly_bitmaps[14].fill_rect(3, 4, 2, 1, butterfly_color3)
        @butterfly_bitmaps[14].fill_rect(1, 5, 2, 1, butterfly_color3)

        # Butterfly right 4
        @butterfly_bitmaps[15] = Bitmap.new(7, 6)
        @butterfly_bitmaps[15].set_pixel(3, 0, butterfly_color1)
        @butterfly_bitmaps[15].fill_rect(4, 0, 2, 1, butterfly_color2)
        @butterfly_bitmaps[15].set_pixel(2, 1, butterfly_color3)
        @butterfly_bitmaps[15].set_pixel(3, 1, butterfly_color2)
        @butterfly_bitmaps[15].set_pixel(4, 1, butterfly_color4)
        @butterfly_bitmaps[15].fill_rect(5, 1, 2, 1, butterfly_color3)
        @butterfly_bitmaps[15].fill_rect(1, 2, 1, 2, butterfly_color3)
        @butterfly_bitmaps[15].fill_rect(2, 2, 1, 2, butterfly_color2)
        @butterfly_bitmaps[15].set_pixel(3, 2, butterfly_color4)
        @butterfly_bitmaps[15].set_pixel(4, 2, butterfly_color2)
        @butterfly_bitmaps[15].set_pixel(5, 2, butterfly_color5)
        @butterfly_bitmaps[15].set_pixel(6, 2, butterfly_color3)
        @butterfly_bitmaps[15].set_pixel(3, 3, butterfly_color3)
        @butterfly_bitmaps[15].set_pixel(4, 3, butterfly_color5)
        @butterfly_bitmaps[15].fill_rect(0, 4, 1, 2, butterfly_color3)
        @butterfly_bitmaps[15].set_pixel(1, 4, butterfly_color2)
        @butterfly_bitmaps[15].set_pixel(2, 4, butterfly_color3)
        @butterfly_bitmaps[15].set_pixel(1, 5, butterfly_color3)
      end
      #-------------------------------------------------------------------------------
      # Bird bitmaps
      if weather == :Birds
        @bird_bitmaps = []
        bird_color1 = Color.new(100, 100, 100)
        bird_color2 = Color.new(170, 170, 170)
        bird_color3 = Color.new(136, 136, 136)
        bird_color4 = Color.new(204, 204, 204)
        bird_color5 = Color.new(240, 240, 240)
        bird_color6 = Color.new(73, 51, 87)
        bird_color7 = Color.new(191, 90, 97)
        bird_color8 = Color.new(255, 255, 255)
        bird_color9 = Color.new(223, 130, 142)

        # Bird left 1
        @bird_bitmaps[0] = Bitmap.new(12, 10)
        @bird_bitmaps[0].fill_rect(7, 0, 3, 1, bird_color1)
        @bird_bitmaps[0].set_pixel(5, 1, bird_color1)
        @bird_bitmaps[0].fill_rect(6, 1, 2, 1, bird_color2)
        @bird_bitmaps[0].set_pixel(8, 1, bird_color3)
        @bird_bitmaps[0].set_pixel(9, 1, bird_color1)
        @bird_bitmaps[0].set_pixel(3, 2, bird_color1)
        @bird_bitmaps[0].set_pixel(4, 2, bird_color2)
        @bird_bitmaps[0].set_pixel(5, 2, bird_color3)
        @bird_bitmaps[0].set_pixel(6, 2, bird_color4)
        @bird_bitmaps[0].fill_rect(7, 2, 5, 1, bird_color8)
        @bird_bitmaps[0].set_pixel(3, 3, bird_color6)
        @bird_bitmaps[0].set_pixel(4, 3, bird_color3)
        @bird_bitmaps[0].fill_rect(5, 3, 1, 3, bird_color8)
        @bird_bitmaps[0].set_pixel(6, 3, bird_color3)
        @bird_bitmaps[0].fill_rect(7, 3, 2, 1, bird_color4)
        @bird_bitmaps[0].set_pixel(9, 3, bird_color8)
        @bird_bitmaps[0].set_pixel(10, 3, bird_color2)
        @bird_bitmaps[0].set_pixel(11, 3, bird_color6)
        @bird_bitmaps[0].fill_rect(1, 4, 2, 1, bird_color3)
        @bird_bitmaps[0].set_pixel(3, 4, bird_color1)
        @bird_bitmaps[0].fill_rect(4, 4, 1, 2, bird_color2)
        @bird_bitmaps[0].set_pixel(6, 4, bird_color2)
        @bird_bitmaps[0].fill_rect(7, 4, 1, 2, bird_color4)
        @bird_bitmaps[0].set_pixel(8, 4, bird_color8)
        @bird_bitmaps[0].set_pixel(9, 4, bird_color2)
        @bird_bitmaps[0].set_pixel(10, 4, bird_color6)
        @bird_bitmaps[0].fill_rect(1, 5, 3, 1, bird_color8)
        @bird_bitmaps[0].set_pixel(6, 5, bird_color3)
        @bird_bitmaps[0].set_pixel(8, 5, bird_color2)
        @bird_bitmaps[0].set_pixel(1, 6, bird_color6)
        @bird_bitmaps[0].set_pixel(2, 6, bird_color2)
        @bird_bitmaps[0].fill_rect(3, 6, 2, 2, bird_color8)
        @bird_bitmaps[0].set_pixel(5, 6, bird_color4)
        @bird_bitmaps[0].set_pixel(6, 6, bird_color2)
        @bird_bitmaps[0].set_pixel(7, 6, bird_color1)
        @bird_bitmaps[0].set_pixel(2, 7, bird_color1)
        @bird_bitmaps[0].fill_rect(5, 7, 2, 1, bird_color8)
        @bird_bitmaps[0].fill_rect(7, 7, 1, 2, bird_color2)
        @bird_bitmaps[0].fill_rect(8, 7, 1, 2, bird_color8)
        @bird_bitmaps[0].fill_rect(9, 7, 1, 2, bird_color1)
        @bird_bitmaps[0].set_pixel(4, 8, bird_color6)
        @bird_bitmaps[0].fill_rect(5, 8, 2, 1, bird_color2)
        @bird_bitmaps[0].set_pixel(6, 9, bird_color6)
        @bird_bitmaps[0].fill_rect(8, 9, 2, 1, bird_color6)

        # Bird left 2
        @bird_bitmaps[1] = Bitmap.new(10, 13)
        @bird_bitmaps[1].set_pixel(5, 0, bird_color1)
        @bird_bitmaps[1].set_pixel(7, 0, bird_color4)
        @bird_bitmaps[1].set_pixel(8, 0, bird_color1)
        @bird_bitmaps[1].fill_rect(5, 1, 1, 4, bird_color2)
        @bird_bitmaps[1].set_pixel(6, 1, bird_color1)
        @bird_bitmaps[1].fill_rect(7, 1, 1, 2, bird_color8)
        @bird_bitmaps[1].set_pixel(8, 1, bird_color4)
        @bird_bitmaps[1].set_pixel(6, 2, bird_color3)
        @bird_bitmaps[1].set_pixel(8, 2, bird_color5)
        @bird_bitmaps[1].fill_rect(9, 2, 1, 4, bird_color1)
        @bird_bitmaps[1].fill_rect(6, 3, 3, 1, bird_color4)
        @bird_bitmaps[1].set_pixel(4, 4, bird_color1)
        @bird_bitmaps[1].set_pixel(6, 4, bird_color8)
        @bird_bitmaps[1].fill_rect(7, 4, 1, 3, bird_color4)
        @bird_bitmaps[1].set_pixel(8, 4, bird_color8)
        @bird_bitmaps[1].set_pixel(4, 5, bird_color2)
        @bird_bitmaps[1].set_pixel(5, 5, bird_color8)
        @bird_bitmaps[1].set_pixel(6, 5, bird_color2)
        @bird_bitmaps[1].set_pixel(8, 5, bird_color5)
        @bird_bitmaps[1].set_pixel(4, 6, bird_color8)
        @bird_bitmaps[1].set_pixel(5, 6, bird_color1)
        @bird_bitmaps[1].fill_rect(6, 6, 1, 2, bird_color4)
        @bird_bitmaps[1].set_pixel(8, 6, bird_color3)
        @bird_bitmaps[1].fill_rect(2, 7, 1, 2, bird_color3)
        @bird_bitmaps[1].set_pixel(3, 7, bird_color1)
        @bird_bitmaps[1].set_pixel(4, 7, bird_color2)
        @bird_bitmaps[1].set_pixel(5, 7, bird_color3)
        @bird_bitmaps[1].set_pixel(7, 7, bird_color3)
        @bird_bitmaps[1].set_pixel(8, 7, bird_color1)
        @bird_bitmaps[1].set_pixel(1, 8, bird_color7)
        @bird_bitmaps[1].fill_rect(3, 8, 1, 2, bird_color8)
        @bird_bitmaps[1].set_pixel(4, 8, bird_color4)
        @bird_bitmaps[1].set_pixel(5, 8, bird_color2)
        @bird_bitmaps[1].fill_rect(6, 8, 1, 2, bird_color3)
        @bird_bitmaps[1].fill_rect(7, 8, 1, 2, bird_color1)
        @bird_bitmaps[1].set_pixel(1, 9, bird_color6)
        @bird_bitmaps[1].set_pixel(2, 9, bird_color2)
        @bird_bitmaps[1].fill_rect(4, 9, 1, 2, bird_color8)
        @bird_bitmaps[1].set_pixel(5, 9, bird_color4)
        @bird_bitmaps[1].set_pixel(3, 10, bird_color2)
        @bird_bitmaps[1].fill_rect(5, 10, 2, 1, bird_color8)
        @bird_bitmaps[1].set_pixel(7, 10, bird_color4)
        @bird_bitmaps[1].set_pixel(8, 10, bird_color8)
        @bird_bitmaps[1].set_pixel(9, 10, bird_color2)
        @bird_bitmaps[1].set_pixel(4, 11, bird_color3)
        @bird_bitmaps[1].set_pixel(5, 11, bird_color2)
        @bird_bitmaps[1].set_pixel(6, 11, bird_color4)
        @bird_bitmaps[1].set_pixel(7, 11, bird_color1)
        @bird_bitmaps[1].set_pixel(8, 11, bird_color2)
        @bird_bitmaps[1].set_pixel(9, 11, bird_color4)
        @bird_bitmaps[1].set_pixel(6, 12, bird_color6)
        @bird_bitmaps[1].set_pixel(7, 12, bird_color7)
        @bird_bitmaps[1].set_pixel(9, 12, bird_color6)

        # Bird left 3
        @bird_bitmaps[2] = Bitmap.new(12, 7)
        @bird_bitmaps[2].set_pixel(4, 0, bird_color3)
        @bird_bitmaps[2].fill_rect(5, 0, 3, 1, bird_color1)
        @bird_bitmaps[2].set_pixel(3, 1, bird_color3)
        @bird_bitmaps[2].fill_rect(4, 1, 1, 4, bird_color8)
        @bird_bitmaps[2].set_pixel(5, 1, bird_color4)
        @bird_bitmaps[2].set_pixel(6, 1, bird_color2)
        @bird_bitmaps[2].set_pixel(7, 1, bird_color4)
        @bird_bitmaps[2].set_pixel(3, 2, bird_color7)
        @bird_bitmaps[2].fill_rect(5, 2, 2, 2, bird_color8)
        @bird_bitmaps[2].set_pixel(7, 2, bird_color2)
        @bird_bitmaps[2].set_pixel(8, 2, bird_color1)
        @bird_bitmaps[2].set_pixel(2, 3, bird_color3)
        @bird_bitmaps[2].fill_rect(3, 3, 1, 2, bird_color2)
        @bird_bitmaps[2].set_pixel(7, 3, bird_color8)
        @bird_bitmaps[2].set_pixel(8, 3, bird_color2)
        @bird_bitmaps[2].set_pixel(0, 4, bird_color1)
        @bird_bitmaps[2].set_pixel(1, 4, bird_color4)
        @bird_bitmaps[2].set_pixel(2, 4, bird_color8)
        @bird_bitmaps[2].set_pixel(5, 4, bird_color8)
        @bird_bitmaps[2].fill_rect(6, 4, 1, 2, bird_color3)
        @bird_bitmaps[2].set_pixel(7, 4, bird_color2)
        @bird_bitmaps[2].set_pixel(8, 4, bird_color4)
        @bird_bitmaps[2].fill_rect(9, 4, 2, 1, bird_color8)
        @bird_bitmaps[2].set_pixel(11, 4, bird_color2)
        @bird_bitmaps[2].set_pixel(1, 5, bird_color6)
        @bird_bitmaps[2].set_pixel(2, 5, bird_color3)
        @bird_bitmaps[2].set_pixel(3, 5, bird_color8)
        @bird_bitmaps[2].set_pixel(4, 5, bird_color3)
        @bird_bitmaps[2].set_pixel(5, 5, bird_color2)
        @bird_bitmaps[2].set_pixel(7, 5, bird_color4)
        @bird_bitmaps[2].fill_rect(8, 5, 2, 1, bird_color2)
        @bird_bitmaps[2].set_pixel(10, 5, bird_color8)
        @bird_bitmaps[2].set_pixel(11, 5, bird_color1)
        @bird_bitmaps[2].fill_rect(2, 6, 2, 1, bird_color6)
        @bird_bitmaps[2].set_pixel(4, 6, bird_color2)
        @bird_bitmaps[2].fill_rect(5, 6, 4, 1, bird_color6)
        @bird_bitmaps[2].fill_rect(10, 6, 2, 1, bird_color6)

        # Bird left 4
        @bird_bitmaps[3] = Bitmap.new(12, 9)
        @bird_bitmaps[3].fill_rect(3, 0, 2, 1, bird_color3)
        @bird_bitmaps[3].set_pixel(3, 1, bird_color4)
        @bird_bitmaps[3].fill_rect(4, 1, 1, 2, bird_color8)
        @bird_bitmaps[3].set_pixel(5, 1, bird_color2)
        @bird_bitmaps[3].set_pixel(6, 1, bird_color1)
        @bird_bitmaps[3].set_pixel(2, 2, bird_color9)
        @bird_bitmaps[3].set_pixel(3, 2, bird_color2)
        @bird_bitmaps[3].fill_rect(5, 2, 3, 1, bird_color8)
        @bird_bitmaps[3].set_pixel(8, 2, bird_color1)
        @bird_bitmaps[3].fill_rect(3, 3, 1, 2, bird_color3)
        @bird_bitmaps[3].set_pixel(4, 3, bird_color2)
        @bird_bitmaps[3].fill_rect(5, 3, 2, 2, bird_color8)
        @bird_bitmaps[3].set_pixel(7, 3, bird_color4)
        @bird_bitmaps[3].fill_rect(8, 3, 2, 1, bird_color8)
        @bird_bitmaps[3].fill_rect(10, 3, 2, 1, bird_color2)
        @bird_bitmaps[3].fill_rect(2, 4, 1, 2, bird_color3)
        @bird_bitmaps[3].fill_rect(4, 4, 1, 2, bird_color8)
        @bird_bitmaps[3].fill_rect(7, 4, 1, 2, bird_color8)
        @bird_bitmaps[3].set_pixel(8, 4, bird_color2)
        @bird_bitmaps[3].set_pixel(9, 4, bird_color1)
        @bird_bitmaps[3].set_pixel(10, 4, bird_color8)
        @bird_bitmaps[3].set_pixel(11, 4, bird_color4)
        @bird_bitmaps[3].set_pixel(0, 5, bird_color1)
        @bird_bitmaps[3].set_pixel(1, 5, bird_color2)
        @bird_bitmaps[3].fill_rect(3, 5, 1, 3, bird_color8)
        @bird_bitmaps[3].set_pixel(5, 5, bird_color5)
        @bird_bitmaps[3].fill_rect(6, 5, 1, 2, bird_color2)
        @bird_bitmaps[3].set_pixel(8, 5, bird_color6)
        @bird_bitmaps[3].set_pixel(9, 5, bird_color7)
        @bird_bitmaps[3].set_pixel(10, 5, bird_color2)
        @bird_bitmaps[3].set_pixel(11, 5, bird_color6)
        @bird_bitmaps[3].set_pixel(2, 6, bird_color8)
        @bird_bitmaps[3].fill_rect(4, 6, 2, 1, bird_color4)
        @bird_bitmaps[3].set_pixel(7, 6, bird_color1)
        @bird_bitmaps[3].set_pixel(1, 7, bird_color3)
        @bird_bitmaps[3].set_pixel(2, 7, bird_color5)
        @bird_bitmaps[3].set_pixel(4, 7, bird_color2)
        @bird_bitmaps[3].fill_rect(5, 7, 2, 1, bird_color1)
        @bird_bitmaps[3].set_pixel(0, 8, bird_color3)
        @bird_bitmaps[3].set_pixel(1, 8, bird_color8)
        @bird_bitmaps[3].fill_rect(2, 8, 2, 1, bird_color1)
      end
      #-------------------------------------------------------------------------------
      # Bat bitmaps
      if weather == :Bats
        @bat_bitmaps = []
        bat_color1 = Color.new(80, 62, 92)
        bat_color2 = Color.new(80, 80, 104)
        bat_color3 = Color.new(137, 137, 160)
        bat_color4 = Color.new(57, 57, 57)
        bat_color5 = Color.new(42, 42, 66)
        bat_color6 = Color.new(76, 67, 68)
        bat_color7 = Color.new(24, 24, 48)
        bat_color8 = Color.new(181, 156, 85)
        bat_color9 = Color.new(99, 99, 122)
        bat_color10 = Color.new(118, 118, 141)
        bat_color11 = Color.new(90, 90, 90)
        bat_color12 = Color.new(61, 61, 85)
        bat_color13 = Color.new(109, 91, 38)
        bat_color14 = Color.new(156, 156, 156)
        bat_color15 = Color.new(203, 179, 74)
        bat_color16 = Color.new(24, 24, 24)
        bat_color17 = Color.new(222, 222, 222)
        bat_color18 = Color.new(249, 226, 145)

        # Bat left 1
        @bat_bitmaps[0] = Bitmap.new(10, 8)
        @bat_bitmaps[0].fill_rect(1, 0, 3, 2, bat_color1)
        @bat_bitmaps[0].fill_rect(6, 0, 1, 4, bat_color2)
        @bat_bitmaps[0].set_pixel(7, 0, bat_color3)
        @bat_bitmaps[0].set_pixel(8, 0, bat_color4)
        @bat_bitmaps[0].set_pixel(9, 0, bat_color5)
        @bat_bitmaps[0].fill_rect(5, 1, 1, 3, bat_color2)
        @bat_bitmaps[0].fill_rect(7, 1, 2, 1, bat_color6)
        @bat_bitmaps[0].set_pixel(1, 2, bat_color3)
        @bat_bitmaps[0].set_pixel(2, 2, bat_color7)
        @bat_bitmaps[0].set_pixel(3, 2, bat_color5)
        @bat_bitmaps[0].set_pixel(4, 2, bat_color2)
        @bat_bitmaps[0].set_pixel(7, 2, bat_color6)
        @bat_bitmaps[0].set_pixel(0, 3, bat_color8)
        @bat_bitmaps[0].fill_rect(1, 3, 2, 1, bat_color9)
        @bat_bitmaps[0].set_pixel(3, 3, bat_color10)
        @bat_bitmaps[0].set_pixel(4, 3, bat_color1)
        @bat_bitmaps[0].set_pixel(7, 3, bat_color11)
        @bat_bitmaps[0].set_pixel(0, 4, bat_color12)
        @bat_bitmaps[0].fill_rect(1, 4, 2, 1, bat_color13)
        @bat_bitmaps[0].set_pixel(3, 4, bat_color9)
        @bat_bitmaps[0].fill_rect(4, 4, 2, 1, bat_color5)
        @bat_bitmaps[0].fill_rect(6, 4, 2, 1, bat_color4)
        @bat_bitmaps[0].set_pixel(0, 5, bat_color5)
        @bat_bitmaps[0].fill_rect(1, 5, 1, 2, bat_color12)
        @bat_bitmaps[0].fill_rect(2, 5, 1, 2, bat_color2)
        @bat_bitmaps[0].set_pixel(3, 5, bat_color12)
        @bat_bitmaps[0].fill_rect(4, 5, 1, 2, bat_color5)
        @bat_bitmaps[0].set_pixel(5, 5, bat_color4)
        @bat_bitmaps[0].set_pixel(6, 5, bat_color11)
        @bat_bitmaps[0].set_pixel(3, 6, bat_color9)
        @bat_bitmaps[0].set_pixel(5, 6, bat_color7)
        @bat_bitmaps[0].set_pixel(2, 7, bat_color5)
        @bat_bitmaps[0].fill_rect(3, 7, 2, 1, bat_color12)
        @bat_bitmaps[0].set_pixel(5, 7, bat_color5)

        # Bat left 2
        @bat_bitmaps[1] = Bitmap.new(9, 7)
        @bat_bitmaps[1].set_pixel(1, 0, bat_color10)
        @bat_bitmaps[1].fill_rect(2, 0, 2, 1, bat_color5)
        @bat_bitmaps[1].set_pixel(0, 1, bat_color13)
        @bat_bitmaps[1].set_pixel(1, 1, bat_color9)
        @bat_bitmaps[1].set_pixel(2, 1, bat_color2)
        @bat_bitmaps[1].set_pixel(3, 1, bat_color9)
        @bat_bitmaps[1].set_pixel(0, 2, bat_color14)
        @bat_bitmaps[1].set_pixel(1, 2, bat_color8)
        @bat_bitmaps[1].set_pixel(2, 2, bat_color15)
        @bat_bitmaps[1].fill_rect(3, 2, 2, 1, bat_color12)
        @bat_bitmaps[1].set_pixel(0, 3, bat_color5)
        @bat_bitmaps[1].set_pixel(1, 3, bat_color12)
        @bat_bitmaps[1].set_pixel(2, 3, bat_color9)
        @bat_bitmaps[1].fill_rect(3, 3, 1, 2, bat_color2)
        @bat_bitmaps[1].fill_rect(4, 3, 1, 2, bat_color5)
        @bat_bitmaps[1].set_pixel(5, 3, bat_color10)
        @bat_bitmaps[1].set_pixel(6, 3, bat_color2)
        @bat_bitmaps[1].set_pixel(1, 4, bat_color5)
        @bat_bitmaps[1].set_pixel(2, 4, bat_color2)
        @bat_bitmaps[1].fill_rect(5, 4, 1, 2, bat_color7)
        @bat_bitmaps[1].set_pixel(6, 4, bat_color9)
        @bat_bitmaps[1].set_pixel(7, 4, bat_color2)
        @bat_bitmaps[1].set_pixel(3, 5, bat_color5)
        @bat_bitmaps[1].set_pixel(4, 5, bat_color12)
        @bat_bitmaps[1].set_pixel(6, 5, bat_color10)
        @bat_bitmaps[1].set_pixel(7, 5, bat_color9)
        @bat_bitmaps[1].set_pixel(8, 5, bat_color2)
        @bat_bitmaps[1].set_pixel(8, 6, bat_color7)

        # Bat left 3
        @bat_bitmaps[2] = Bitmap.new(6, 11)
        @bat_bitmaps[2].set_pixel(1, 0, bat_color5)
        @bat_bitmaps[2].set_pixel(0, 1, bat_color13)
        @bat_bitmaps[2].set_pixel(1, 1, bat_color9)
        @bat_bitmaps[2].fill_rect(2, 1, 2, 1, bat_color10)
        @bat_bitmaps[2].set_pixel(0, 2, bat_color12)
        @bat_bitmaps[2].fill_rect(1, 2, 2, 2, bat_color13)
        @bat_bitmaps[2].set_pixel(3, 2, bat_color9)
        @bat_bitmaps[2].set_pixel(0, 3, bat_color7)
        @bat_bitmaps[2].fill_rect(3, 3, 2, 1, bat_color5)
        @bat_bitmaps[2].fill_rect(0, 4, 1, 4, bat_color1)
        @bat_bitmaps[2].set_pixel(1, 4, bat_color2)
        @bat_bitmaps[2].set_pixel(2, 4, bat_color9)
        @bat_bitmaps[2].set_pixel(3, 4, bat_color12)
        @bat_bitmaps[2].set_pixel(4, 4, bat_color2)
        @bat_bitmaps[2].set_pixel(5, 4, bat_color5)
        @bat_bitmaps[2].fill_rect(1, 5, 1, 2, bat_color1)
        @bat_bitmaps[2].set_pixel(2, 5, bat_color12)
        @bat_bitmaps[2].set_pixel(3, 5, bat_color5)
        @bat_bitmaps[2].fill_rect(4, 5, 1, 4, bat_color9)
        @bat_bitmaps[2].fill_rect(5, 5, 1, 2, bat_color2)
        @bat_bitmaps[2].set_pixel(3, 6, bat_color12)
        @bat_bitmaps[2].set_pixel(2, 7, bat_color12)
        @bat_bitmaps[2].set_pixel(3, 7, bat_color10)
        @bat_bitmaps[2].set_pixel(5, 7, bat_color9)
        @bat_bitmaps[2].set_pixel(3, 8, bat_color12)
        @bat_bitmaps[2].set_pixel(5, 8, bat_color12)
        @bat_bitmaps[2].fill_rect(4, 9, 2, 1, bat_color2)
        @bat_bitmaps[2].set_pixel(5, 10, bat_color12)

        # Bat left 4
        @bat_bitmaps[3] = Bitmap.new(9, 7)
        @bat_bitmaps[3].set_pixel(1, 0, bat_color10)
        @bat_bitmaps[3].fill_rect(2, 0, 2, 1, bat_color5)
        @bat_bitmaps[3].set_pixel(0, 1, bat_color13)
        @bat_bitmaps[3].set_pixel(1, 1, bat_color9)
        @bat_bitmaps[3].set_pixel(2, 1, bat_color2)
        @bat_bitmaps[3].set_pixel(3, 1, bat_color9)
        @bat_bitmaps[3].set_pixel(0, 2, bat_color14)
        @bat_bitmaps[3].set_pixel(1, 2, bat_color8)
        @bat_bitmaps[3].set_pixel(2, 2, bat_color15)
        @bat_bitmaps[3].fill_rect(3, 2, 2, 1, bat_color12)
        @bat_bitmaps[3].set_pixel(0, 3, bat_color5)
        @bat_bitmaps[3].set_pixel(1, 3, bat_color12)
        @bat_bitmaps[3].set_pixel(2, 3, bat_color9)
        @bat_bitmaps[3].fill_rect(3, 3, 1, 2, bat_color2)
        @bat_bitmaps[3].fill_rect(4, 3, 1, 2, bat_color5)
        @bat_bitmaps[3].set_pixel(5, 3, bat_color10)
        @bat_bitmaps[3].set_pixel(6, 3, bat_color2)
        @bat_bitmaps[3].set_pixel(1, 4, bat_color5)
        @bat_bitmaps[3].set_pixel(2, 4, bat_color2)
        @bat_bitmaps[3].fill_rect(5, 4, 1, 2, bat_color7)
        @bat_bitmaps[3].set_pixel(6, 4, bat_color9)
        @bat_bitmaps[3].set_pixel(7, 4, bat_color2)
        @bat_bitmaps[3].set_pixel(3, 5, bat_color5)
        @bat_bitmaps[3].set_pixel(4, 5, bat_color12)
        @bat_bitmaps[3].set_pixel(6, 5, bat_color10)
        @bat_bitmaps[3].set_pixel(7, 5, bat_color9)
        @bat_bitmaps[3].set_pixel(8, 5, bat_color2)
        @bat_bitmaps[3].set_pixel(8, 6, bat_color7)

        # Bat up 1
        @bat_bitmaps[4] = Bitmap.new(11, 9)
        @bat_bitmaps[4].set_pixel(0, 0, bat_color9)
        @bat_bitmaps[4].set_pixel(1, 0, bat_color3)
        @bat_bitmaps[4].set_pixel(8, 0, bat_color2)
        @bat_bitmaps[4].set_pixel(9, 0, bat_color10)
        @bat_bitmaps[4].set_pixel(10, 0, bat_color4)
        @bat_bitmaps[4].set_pixel(0, 1, bat_color4)
        @bat_bitmaps[4].fill_rect(1, 1, 1, 2, bat_color9)
        @bat_bitmaps[4].set_pixel(2, 1, bat_color2)
        @bat_bitmaps[4].set_pixel(3, 1, bat_color9)
        @bat_bitmaps[4].set_pixel(7, 1, bat_color2)
        @bat_bitmaps[4].fill_rect(8, 1, 2, 1, bat_color9)
        @bat_bitmaps[4].fill_rect(2, 2, 1, 2, bat_color9)
        @bat_bitmaps[4].fill_rect(4, 2, 1, 2, bat_color10)
        @bat_bitmaps[4].fill_rect(5, 2, 1, 6, bat_color9)
        @bat_bitmaps[4].set_pixel(6, 2, bat_color10)
        @bat_bitmaps[4].set_pixel(7, 2, bat_color7)
        @bat_bitmaps[4].set_pixel(8, 2, bat_color9)
        @bat_bitmaps[4].set_pixel(9, 2, bat_color2)
        @bat_bitmaps[4].set_pixel(1, 3, bat_color2)
        @bat_bitmaps[4].set_pixel(3, 3, bat_color7)
        @bat_bitmaps[4].fill_rect(6, 3, 1, 2, bat_color9)
        @bat_bitmaps[4].set_pixel(7, 3, bat_color12)
        @bat_bitmaps[4].set_pixel(8, 3, bat_color2)
        @bat_bitmaps[4].set_pixel(9, 3, bat_color12)
        @bat_bitmaps[4].set_pixel(1, 4, bat_color12)
        @bat_bitmaps[4].fill_rect(2, 4, 1, 2, bat_color2)
        @bat_bitmaps[4].set_pixel(3, 4, bat_color12)
        @bat_bitmaps[4].fill_rect(4, 4, 1, 3, bat_color9)
        @bat_bitmaps[4].fill_rect(7, 4, 2, 1, bat_color9)
        @bat_bitmaps[4].set_pixel(9, 4, bat_color16)
        @bat_bitmaps[4].set_pixel(3, 5, bat_color2)
        @bat_bitmaps[4].fill_rect(6, 5, 2, 1, bat_color2)
        @bat_bitmaps[4].set_pixel(8, 5, bat_color16)
        @bat_bitmaps[4].set_pixel(2, 6, bat_color16)
        @bat_bitmaps[4].fill_rect(3, 6, 1, 2, bat_color12)
        @bat_bitmaps[4].fill_rect(6, 6, 1, 2, bat_color9)
        @bat_bitmaps[4].set_pixel(7, 6, bat_color12)
        @bat_bitmaps[4].set_pixel(4, 7, bat_color2)
        @bat_bitmaps[4].set_pixel(7, 7, bat_color7)
        @bat_bitmaps[4].set_pixel(3, 8, bat_color7)
        @bat_bitmaps[4].set_pixel(4, 8, bat_color16)
        @bat_bitmaps[4].fill_rect(5, 8, 2, 1, bat_color12)

        # Bat up 2
        @bat_bitmaps[5] = Bitmap.new(12, 9)
        @bat_bitmaps[5].fill_rect(5, 0, 1, 5, bat_color9)
        @bat_bitmaps[5].set_pixel(6, 0, bat_color12)
        @bat_bitmaps[5].set_pixel(7, 0, bat_color10)
        @bat_bitmaps[5].set_pixel(6, 1, bat_color10)
        @bat_bitmaps[5].fill_rect(7, 1, 1, 5, bat_color9)
        @bat_bitmaps[5].set_pixel(4, 2, bat_color7)
        @bat_bitmaps[5].fill_rect(6, 2, 1, 4, bat_color9)
        @bat_bitmaps[5].set_pixel(4, 3, bat_color12)
        @bat_bitmaps[5].fill_rect(8, 3, 2, 1, bat_color12)
        @bat_bitmaps[5].set_pixel(2, 4, bat_color2)
        @bat_bitmaps[5].fill_rect(3, 4, 2, 1, bat_color9)
        @bat_bitmaps[5].set_pixel(8, 4, bat_color9)
        @bat_bitmaps[5].set_pixel(9, 4, bat_color2)
        @bat_bitmaps[5].set_pixel(10, 4, bat_color12)
        @bat_bitmaps[5].set_pixel(1, 5, bat_color12)
        @bat_bitmaps[5].fill_rect(2, 5, 1, 2, bat_color9)
        @bat_bitmaps[5].fill_rect(3, 5, 1, 2, bat_color2)
        @bat_bitmaps[5].set_pixel(4, 5, bat_color9)
        @bat_bitmaps[5].set_pixel(5, 5, bat_color2)
        @bat_bitmaps[5].set_pixel(8, 5, bat_color2)
        @bat_bitmaps[5].fill_rect(9, 5, 1, 2, bat_color9)
        @bat_bitmaps[5].set_pixel(10, 5, bat_color2)
        @bat_bitmaps[5].fill_rect(1, 6, 1, 2, bat_color2)
        @bat_bitmaps[5].set_pixel(4, 6, bat_color7)
        @bat_bitmaps[5].set_pixel(5, 6, bat_color16)
        @bat_bitmaps[5].set_pixel(6, 6, bat_color2)
        @bat_bitmaps[5].fill_rect(7, 6, 2, 1, bat_color12)
        @bat_bitmaps[5].set_pixel(10, 6, bat_color9)
        @bat_bitmaps[5].set_pixel(11, 6, bat_color7)
        @bat_bitmaps[5].fill_rect(0, 7, 1, 2, bat_color7)
        @bat_bitmaps[5].set_pixel(10, 7, bat_color7)
        @bat_bitmaps[5].set_pixel(11, 7, bat_color2)

        # Bat up 3
        @bat_bitmaps[6] = Bitmap.new(9, 11)
        @bat_bitmaps[6].set_pixel(3, 0, bat_color12)
        @bat_bitmaps[6].set_pixel(5, 0, bat_color12)
        @bat_bitmaps[6].fill_rect(3, 1, 1, 2, bat_color10)
        @bat_bitmaps[6].fill_rect(4, 1, 1, 5, bat_color9)
        @bat_bitmaps[6].set_pixel(5, 1, bat_color10)
        @bat_bitmaps[6].set_pixel(2, 2, bat_color7)
        @bat_bitmaps[6].fill_rect(5, 2, 1, 3, bat_color9)
        @bat_bitmaps[6].set_pixel(2, 3, bat_color2)
        @bat_bitmaps[6].fill_rect(3, 3, 1, 3, bat_color9)
        @bat_bitmaps[6].set_pixel(6, 3, bat_color12)
        @bat_bitmaps[6].set_pixel(1, 4, bat_color12)
        @bat_bitmaps[6].fill_rect(2, 4, 1, 2, bat_color9)
        @bat_bitmaps[6].set_pixel(6, 4, bat_color2)
        @bat_bitmaps[6].set_pixel(1, 5, bat_color2)
        @bat_bitmaps[6].fill_rect(5, 5, 1, 2, bat_color2)
        @bat_bitmaps[6].set_pixel(6, 5, bat_color9)
        @bat_bitmaps[6].set_pixel(7, 5, bat_color2)
        @bat_bitmaps[6].set_pixel(0, 6, bat_color12)
        @bat_bitmaps[6].fill_rect(1, 6, 1, 2, bat_color9)
        @bat_bitmaps[6].fill_rect(2, 6, 1, 2, bat_color7)
        @bat_bitmaps[6].set_pixel(3, 6, bat_color12)
        @bat_bitmaps[6].set_pixel(4, 6, bat_color2)
        @bat_bitmaps[6].set_pixel(6, 6, bat_color2)
        @bat_bitmaps[6].fill_rect(7, 6, 1, 2, bat_color9)
        @bat_bitmaps[6].set_pixel(0, 7, bat_color2)
        @bat_bitmaps[6].set_pixel(3, 7, bat_color16)
        @bat_bitmaps[6].fill_rect(4, 7, 3, 1, bat_color12)
        @bat_bitmaps[6].set_pixel(8, 7, bat_color7)
        @bat_bitmaps[6].set_pixel(0, 8, bat_color9)
        @bat_bitmaps[6].set_pixel(7, 8, bat_color2)
        @bat_bitmaps[6].fill_rect(8, 8, 1, 3, bat_color12)
        @bat_bitmaps[6].set_pixel(0, 9, bat_color12)
        @bat_bitmaps[6].set_pixel(7, 9, bat_color7)
        @bat_bitmaps[6].set_pixel(0, 10, bat_color7)

        # Bat up 4
        @bat_bitmaps[7] = Bitmap.new(12, 8)
        @bat_bitmaps[7].fill_rect(5, 0, 1, 5, bat_color9)
        @bat_bitmaps[7].set_pixel(6, 0, bat_color12)
        @bat_bitmaps[7].set_pixel(7, 0, bat_color10)
        @bat_bitmaps[7].set_pixel(6, 1, bat_color10)
        @bat_bitmaps[7].fill_rect(7, 1, 1, 4, bat_color9)
        @bat_bitmaps[7].set_pixel(2, 2, bat_color12)
        @bat_bitmaps[7].set_pixel(4, 2, bat_color7)
        @bat_bitmaps[7].fill_rect(6, 2, 1, 4, bat_color9)
        @bat_bitmaps[7].fill_rect(9, 2, 1, 2, bat_color2)
        @bat_bitmaps[7].fill_rect(2, 3, 1, 2, bat_color9)
        @bat_bitmaps[7].set_pixel(3, 3, bat_color7)
        @bat_bitmaps[7].set_pixel(4, 3, bat_color12)
        @bat_bitmaps[7].set_pixel(8, 3, bat_color12)
        @bat_bitmaps[7].fill_rect(10, 3, 1, 3, bat_color2)
        @bat_bitmaps[7].set_pixel(1, 4, bat_color12)
        @bat_bitmaps[7].fill_rect(3, 4, 2, 1, bat_color9)
        @bat_bitmaps[7].fill_rect(8, 4, 2, 1, bat_color9)
        @bat_bitmaps[7].set_pixel(1, 5, bat_color9)
        @bat_bitmaps[7].fill_rect(2, 5, 3, 1, bat_color12)
        @bat_bitmaps[7].set_pixel(5, 5, bat_color2)
        @bat_bitmaps[7].fill_rect(7, 5, 2, 1, bat_color2)
        @bat_bitmaps[7].set_pixel(9, 5, bat_color12)
        @bat_bitmaps[7].set_pixel(11, 5, bat_color12)
        @bat_bitmaps[7].set_pixel(0, 6, bat_color12)
        @bat_bitmaps[7].set_pixel(1, 6, bat_color2)
        @bat_bitmaps[7].set_pixel(4, 6, bat_color7)
        @bat_bitmaps[7].set_pixel(5, 6, bat_color16)
        @bat_bitmaps[7].set_pixel(6, 6, bat_color2)
        @bat_bitmaps[7].set_pixel(7, 6, bat_color12)
        @bat_bitmaps[7].set_pixel(8, 6, bat_color7)
        @bat_bitmaps[7].set_pixel(10, 6, bat_color7)
        @bat_bitmaps[7].set_pixel(11, 6, bat_color2)
        @bat_bitmaps[7].set_pixel(0, 7, bat_color7)

        # Bat right 1
        @bat_bitmaps[8] = Bitmap.new(10, 8)
        @bat_bitmaps[8].set_pixel(0, 0, bat_color5)
        @bat_bitmaps[8].set_pixel(1, 0, bat_color4)
        @bat_bitmaps[8].set_pixel(2, 0, bat_color3)
        @bat_bitmaps[8].fill_rect(3, 0, 1, 4, bat_color2)
        @bat_bitmaps[8].fill_rect(6, 0, 3, 2, bat_color1)
        @bat_bitmaps[8].set_pixel(1, 1, bat_color6)
        @bat_bitmaps[8].set_pixel(2, 1, bat_color4)
        @bat_bitmaps[8].fill_rect(4, 1, 1, 3, bat_color2)
        @bat_bitmaps[8].set_pixel(5, 1, bat_color1)
        @bat_bitmaps[8].set_pixel(2, 2, bat_color6)
        @bat_bitmaps[8].set_pixel(5, 2, bat_color10)
        @bat_bitmaps[8].set_pixel(6, 2, bat_color5)
        @bat_bitmaps[8].set_pixel(7, 2, bat_color7)
        @bat_bitmaps[8].set_pixel(8, 2, bat_color12)
        @bat_bitmaps[8].set_pixel(2, 3, bat_color11)
        @bat_bitmaps[8].set_pixel(5, 3, bat_color1)
        @bat_bitmaps[8].set_pixel(6, 3, bat_color10)
        @bat_bitmaps[8].fill_rect(7, 3, 2, 1, bat_color9)
        @bat_bitmaps[8].set_pixel(9, 3, bat_color8)
        @bat_bitmaps[8].set_pixel(2, 4, bat_color2)
        @bat_bitmaps[8].set_pixel(3, 4, bat_color4)
        @bat_bitmaps[8].set_pixel(4, 4, bat_color5)
        @bat_bitmaps[8].set_pixel(5, 4, bat_color7)
        @bat_bitmaps[8].set_pixel(6, 4, bat_color9)
        @bat_bitmaps[8].set_pixel(7, 4, bat_color13)
        @bat_bitmaps[8].fill_rect(8, 4, 2, 1, bat_color12)
        @bat_bitmaps[8].set_pixel(2, 5, bat_color4)
        @bat_bitmaps[8].set_pixel(3, 5, bat_color11)
        @bat_bitmaps[8].set_pixel(4, 5, bat_color4)
        @bat_bitmaps[8].fill_rect(5, 5, 2, 1, bat_color12)
        @bat_bitmaps[8].fill_rect(7, 5, 1, 2, bat_color2)
        @bat_bitmaps[8].set_pixel(8, 5, bat_color7)
        @bat_bitmaps[8].set_pixel(9, 5, bat_color5)
        @bat_bitmaps[8].set_pixel(4, 6, bat_color7)
        @bat_bitmaps[8].fill_rect(5, 6, 1, 2, bat_color5)
        @bat_bitmaps[8].set_pixel(6, 6, bat_color9)
        @bat_bitmaps[8].set_pixel(8, 6, bat_color5)
        @bat_bitmaps[8].set_pixel(4, 7, bat_color5)
        @bat_bitmaps[8].set_pixel(6, 7, bat_color12)
        @bat_bitmaps[8].set_pixel(7, 7, bat_color5)

        # Bat right 2
        @bat_bitmaps[9] = Bitmap.new(9, 7)
        @bat_bitmaps[9].fill_rect(5, 0, 3, 1, bat_color5)
        @bat_bitmaps[9].set_pixel(4, 1, bat_color5)
        @bat_bitmaps[9].set_pixel(5, 1, bat_color9)
        @bat_bitmaps[9].fill_rect(6, 1, 2, 1, bat_color2)
        @bat_bitmaps[9].set_pixel(8, 1, bat_color13)
        @bat_bitmaps[9].set_pixel(4, 2, bat_color7)
        @bat_bitmaps[9].set_pixel(5, 2, bat_color12)
        @bat_bitmaps[9].set_pixel(6, 2, bat_color15)
        @bat_bitmaps[9].fill_rect(7, 2, 1, 2, bat_color12)
        @bat_bitmaps[9].set_pixel(8, 2, bat_color14)
        @bat_bitmaps[9].set_pixel(2, 3, bat_color2)
        @bat_bitmaps[9].set_pixel(3, 3, bat_color10)
        @bat_bitmaps[9].set_pixel(4, 3, bat_color5)
        @bat_bitmaps[9].fill_rect(5, 3, 1, 2, bat_color2)
        @bat_bitmaps[9].set_pixel(6, 3, bat_color9)
        @bat_bitmaps[9].set_pixel(8, 3, bat_color5)
        @bat_bitmaps[9].set_pixel(1, 4, bat_color2)
        @bat_bitmaps[9].set_pixel(2, 4, bat_color9)
        @bat_bitmaps[9].fill_rect(3, 4, 1, 2, bat_color7)
        @bat_bitmaps[9].set_pixel(4, 4, bat_color12)
        @bat_bitmaps[9].set_pixel(6, 4, bat_color2)
        @bat_bitmaps[9].set_pixel(0, 5, bat_color2)
        @bat_bitmaps[9].fill_rect(1, 5, 2, 1, bat_color10)
        @bat_bitmaps[9].set_pixel(4, 5, bat_color7)
        @bat_bitmaps[9].set_pixel(5, 5, bat_color5)
        @bat_bitmaps[9].set_pixel(0, 6, bat_color7)

        # Bat right 3
        @bat_bitmaps[10] = Bitmap.new(6, 11)
        @bat_bitmaps[10].set_pixel(4, 0, bat_color10)
        @bat_bitmaps[10].fill_rect(2, 1, 2, 1, bat_color10)
        @bat_bitmaps[10].set_pixel(4, 1, bat_color9)
        @bat_bitmaps[10].set_pixel(5, 1, bat_color13)
        @bat_bitmaps[10].set_pixel(1, 2, bat_color5)
        @bat_bitmaps[10].set_pixel(2, 2, bat_color9)
        @bat_bitmaps[10].fill_rect(3, 2, 1, 2, bat_color13)
        @bat_bitmaps[10].fill_rect(4, 2, 2, 1, bat_color12)
        @bat_bitmaps[10].set_pixel(1, 3, bat_color2)
        @bat_bitmaps[10].set_pixel(2, 3, bat_color5)
        @bat_bitmaps[10].set_pixel(4, 3, bat_color17)
        @bat_bitmaps[10].set_pixel(5, 3, bat_color7)
        @bat_bitmaps[10].set_pixel(0, 4, bat_color5)
        @bat_bitmaps[10].set_pixel(1, 4, bat_color9)
        @bat_bitmaps[10].set_pixel(2, 4, bat_color12)
        @bat_bitmaps[10].set_pixel(3, 4, bat_color9)
        @bat_bitmaps[10].set_pixel(4, 4, bat_color5)
        @bat_bitmaps[10].fill_rect(5, 4, 1, 4, bat_color1)
        @bat_bitmaps[10].fill_rect(0, 5, 1, 2, bat_color2)
        @bat_bitmaps[10].fill_rect(1, 5, 1, 2, bat_color10)
        @bat_bitmaps[10].set_pixel(2, 5, bat_color5)
        @bat_bitmaps[10].set_pixel(3, 5, bat_color12)
        @bat_bitmaps[10].fill_rect(4, 5, 1, 3, bat_color1)
        @bat_bitmaps[10].set_pixel(2, 6, bat_color12)
        @bat_bitmaps[10].fill_rect(0, 7, 2, 1, bat_color9)
        @bat_bitmaps[10].set_pixel(2, 7, bat_color10)
        @bat_bitmaps[10].set_pixel(3, 7, bat_color12)
        @bat_bitmaps[10].set_pixel(0, 8, bat_color12)
        @bat_bitmaps[10].set_pixel(1, 8, bat_color10)
        @bat_bitmaps[10].set_pixel(2, 8, bat_color12)
        @bat_bitmaps[10].set_pixel(0, 9, bat_color2)
        @bat_bitmaps[10].set_pixel(1, 9, bat_color12)
        @bat_bitmaps[10].set_pixel(0, 10, bat_color12)

        # Bat right 4
        @bat_bitmaps[11] = Bitmap.new(9, 7)
        @bat_bitmaps[11].fill_rect(5, 0, 3, 1, bat_color5)
        @bat_bitmaps[11].set_pixel(4, 1, bat_color5)
        @bat_bitmaps[11].set_pixel(5, 1, bat_color9)
        @bat_bitmaps[11].fill_rect(6, 1, 2, 1, bat_color2)
        @bat_bitmaps[11].set_pixel(8, 1, bat_color13)
        @bat_bitmaps[11].set_pixel(4, 2, bat_color7)
        @bat_bitmaps[11].set_pixel(5, 2, bat_color12)
        @bat_bitmaps[11].set_pixel(6, 2, bat_color15)
        @bat_bitmaps[11].fill_rect(7, 2, 1, 2, bat_color12)
        @bat_bitmaps[11].set_pixel(8, 2, bat_color14)
        @bat_bitmaps[11].set_pixel(2, 3, bat_color2)
        @bat_bitmaps[11].set_pixel(3, 3, bat_color10)
        @bat_bitmaps[11].set_pixel(4, 3, bat_color5)
        @bat_bitmaps[11].fill_rect(5, 3, 1, 2, bat_color2)
        @bat_bitmaps[11].set_pixel(6, 3, bat_color9)
        @bat_bitmaps[11].set_pixel(8, 3, bat_color5)
        @bat_bitmaps[11].set_pixel(1, 4, bat_color2)
        @bat_bitmaps[11].set_pixel(2, 4, bat_color9)
        @bat_bitmaps[11].fill_rect(3, 4, 1, 2, bat_color7)
        @bat_bitmaps[11].set_pixel(4, 4, bat_color12)
        @bat_bitmaps[11].set_pixel(6, 4, bat_color2)
        @bat_bitmaps[11].set_pixel(0, 5, bat_color2)
        @bat_bitmaps[11].fill_rect(1, 5, 2, 1, bat_color10)
        @bat_bitmaps[11].set_pixel(4, 5, bat_color7)
        @bat_bitmaps[11].set_pixel(5, 5, bat_color5)
        @bat_bitmaps[11].set_pixel(0, 6, bat_color7)

        # Bat down 1
        @bat_bitmaps[12] = Bitmap.new(11, 9)
        @bat_bitmaps[12].set_pixel(0, 0, bat_color12)
        @bat_bitmaps[12].set_pixel(1, 0, bat_color3)
        @bat_bitmaps[12].set_pixel(8, 0, bat_color9)
        @bat_bitmaps[12].set_pixel(9, 0, bat_color10)
        @bat_bitmaps[12].set_pixel(10, 0, bat_color4)
        @bat_bitmaps[12].fill_rect(0, 1, 2, 1, bat_color4)
        @bat_bitmaps[12].fill_rect(2, 1, 2, 1, bat_color9)
        @bat_bitmaps[12].set_pixel(7, 1, bat_color2)
        @bat_bitmaps[12].set_pixel(8, 1, bat_color12)
        @bat_bitmaps[12].set_pixel(9, 1, bat_color6)
        @bat_bitmaps[12].set_pixel(1, 2, bat_color5)
        @bat_bitmaps[12].set_pixel(2, 2, bat_color9)
        @bat_bitmaps[12].set_pixel(4, 2, bat_color2)
        @bat_bitmaps[12].set_pixel(5, 2, bat_color10)
        @bat_bitmaps[12].set_pixel(6, 2, bat_color5)
        @bat_bitmaps[12].set_pixel(7, 2, bat_color7)
        @bat_bitmaps[12].set_pixel(8, 2, bat_color5)
        @bat_bitmaps[12].set_pixel(9, 2, bat_color2)
        @bat_bitmaps[12].set_pixel(1, 3, bat_color11)
        @bat_bitmaps[12].fill_rect(2, 3, 2, 1, bat_color7)
        @bat_bitmaps[12].set_pixel(4, 3, bat_color13)
        @bat_bitmaps[12].set_pixel(5, 3, bat_color9)
        @bat_bitmaps[12].set_pixel(6, 3, bat_color13)
        @bat_bitmaps[12].set_pixel(7, 3, bat_color2)
        @bat_bitmaps[12].set_pixel(8, 3, bat_color6)
        @bat_bitmaps[12].set_pixel(9, 3, bat_color4)
        @bat_bitmaps[12].set_pixel(1, 4, bat_color2)
        @bat_bitmaps[12].set_pixel(2, 4, bat_color4)
        @bat_bitmaps[12].set_pixel(3, 4, bat_color12)
        @bat_bitmaps[12].set_pixel(4, 4, bat_color15)
        @bat_bitmaps[12].fill_rect(5, 4, 1, 2, bat_color12)
        @bat_bitmaps[12].set_pixel(6, 4, bat_color8)
        @bat_bitmaps[12].fill_rect(7, 4, 2, 1, bat_color5)
        @bat_bitmaps[12].set_pixel(9, 4, bat_color16)
        @bat_bitmaps[12].set_pixel(2, 5, bat_color6)
        @bat_bitmaps[12].fill_rect(3, 5, 1, 2, bat_color7)
        @bat_bitmaps[12].set_pixel(4, 5, bat_color2)
        @bat_bitmaps[12].fill_rect(6, 5, 1, 2, bat_color12)
        @bat_bitmaps[12].set_pixel(7, 5, bat_color4)
        @bat_bitmaps[12].set_pixel(8, 5, bat_color16)
        @bat_bitmaps[12].set_pixel(2, 6, bat_color16)
        @bat_bitmaps[12].set_pixel(4, 6, bat_color9)
        @bat_bitmaps[12].set_pixel(5, 6, bat_color2)
        @bat_bitmaps[12].fill_rect(7, 6, 1, 2, bat_color7)
        @bat_bitmaps[12].set_pixel(3, 7, bat_color12)
        @bat_bitmaps[12].set_pixel(4, 7, bat_color7)
        @bat_bitmaps[12].fill_rect(5, 7, 2, 1, bat_color5)
        @bat_bitmaps[12].set_pixel(5, 8, bat_color4)

        # Bat down 2
        @bat_bitmaps[13] = Bitmap.new(12, 7)
        @bat_bitmaps[13].set_pixel(5, 0, bat_color10)
        @bat_bitmaps[13].set_pixel(6, 0, bat_color12)
        @bat_bitmaps[13].set_pixel(7, 0, bat_color10)
        @bat_bitmaps[13].set_pixel(4, 1, bat_color7)
        @bat_bitmaps[13].set_pixel(5, 1, bat_color9)
        @bat_bitmaps[13].set_pixel(6, 1, bat_color10)
        @bat_bitmaps[13].set_pixel(7, 1, bat_color2)
        @bat_bitmaps[13].fill_rect(3, 2, 2, 1, bat_color12)
        @bat_bitmaps[13].set_pixel(5, 2, bat_color15)
        @bat_bitmaps[13].set_pixel(6, 2, bat_color12)
        @bat_bitmaps[13].set_pixel(7, 2, bat_color8)
        @bat_bitmaps[13].set_pixel(8, 2, bat_color12)
        @bat_bitmaps[13].set_pixel(2, 3, bat_color2)
        @bat_bitmaps[13].set_pixel(3, 3, bat_color9)
        @bat_bitmaps[13].set_pixel(4, 3, bat_color5)
        @bat_bitmaps[13].set_pixel(5, 3, bat_color7)
        @bat_bitmaps[13].set_pixel(6, 3, bat_color17)
        @bat_bitmaps[13].set_pixel(7, 3, bat_color12)
        @bat_bitmaps[13].fill_rect(8, 3, 2, 1, bat_color2)
        @bat_bitmaps[13].set_pixel(1, 4, bat_color9)
        @bat_bitmaps[13].fill_rect(2, 4, 2, 1, bat_color4)
        @bat_bitmaps[13].set_pixel(4, 4, bat_color7)
        @bat_bitmaps[13].fill_rect(5, 4, 2, 1, bat_color9)
        @bat_bitmaps[13].set_pixel(7, 4, bat_color2)
        @bat_bitmaps[13].set_pixel(8, 4, bat_color4)
        @bat_bitmaps[13].fill_rect(9, 4, 2, 1, bat_color7)
        @bat_bitmaps[13].set_pixel(11, 4, bat_color2)
        @bat_bitmaps[13].set_pixel(0, 5, bat_color12)
        @bat_bitmaps[13].set_pixel(2, 5, bat_color7)
        @bat_bitmaps[13].set_pixel(4, 5, bat_color12)
        @bat_bitmaps[13].set_pixel(5, 5, bat_color7)
        @bat_bitmaps[13].fill_rect(6, 5, 2, 1, bat_color5)
        @bat_bitmaps[13].fill_rect(8, 5, 2, 1, bat_color7)
        @bat_bitmaps[13].set_pixel(11, 5, bat_color5)
        @bat_bitmaps[13].set_pixel(5, 6, bat_color4)
        @bat_bitmaps[13].fill_rect(6, 6, 2, 1, bat_color7)

        # Bat down 3
        @bat_bitmaps[14] = Bitmap.new(9, 9)
        @bat_bitmaps[14].set_pixel(3, 0, bat_color10)
        @bat_bitmaps[14].set_pixel(4, 0, bat_color12)
        @bat_bitmaps[14].set_pixel(5, 0, bat_color10)
        @bat_bitmaps[14].set_pixel(3, 1, bat_color2)
        @bat_bitmaps[14].set_pixel(4, 1, bat_color9)
        @bat_bitmaps[14].set_pixel(5, 1, bat_color5)
        @bat_bitmaps[14].fill_rect(2, 2, 1, 2, bat_color12)
        @bat_bitmaps[14].set_pixel(3, 2, bat_color18)
        @bat_bitmaps[14].set_pixel(4, 2, bat_color13)
        @bat_bitmaps[14].set_pixel(5, 2, bat_color18)
        @bat_bitmaps[14].fill_rect(1, 3, 1, 2, bat_color2)
        @bat_bitmaps[14].set_pixel(3, 3, bat_color7)
        @bat_bitmaps[14].set_pixel(4, 3, bat_color17)
        @bat_bitmaps[14].set_pixel(5, 3, bat_color12)
        @bat_bitmaps[14].set_pixel(6, 3, bat_color2)
        @bat_bitmaps[14].set_pixel(2, 4, bat_color5)
        @bat_bitmaps[14].set_pixel(3, 4, bat_color9)
        @bat_bitmaps[14].fill_rect(4, 4, 2, 1, bat_color2)
        @bat_bitmaps[14].set_pixel(6, 4, bat_color9)
        @bat_bitmaps[14].set_pixel(7, 4, bat_color5)
        @bat_bitmaps[14].set_pixel(0, 5, bat_color2)
        @bat_bitmaps[14].fill_rect(1, 5, 1, 2, bat_color9)
        @bat_bitmaps[14].set_pixel(2, 5, bat_color7)
        @bat_bitmaps[14].set_pixel(3, 5, bat_color5)
        @bat_bitmaps[14].fill_rect(4, 5, 2, 1, bat_color12)
        @bat_bitmaps[14].set_pixel(6, 5, bat_color5)
        @bat_bitmaps[14].set_pixel(7, 5, bat_color2)
        @bat_bitmaps[14].set_pixel(8, 5, bat_color12)
        @bat_bitmaps[14].set_pixel(0, 6, bat_color12)
        @bat_bitmaps[14].set_pixel(2, 6, bat_color12)
        @bat_bitmaps[14].set_pixel(3, 6, bat_color4)
        @bat_bitmaps[14].fill_rect(4, 6, 2, 1, bat_color7)
        @bat_bitmaps[14].set_pixel(6, 6, bat_color9)
        @bat_bitmaps[14].set_pixel(7, 6, bat_color12)
        @bat_bitmaps[14].set_pixel(8, 6, bat_color5)
        @bat_bitmaps[14].set_pixel(0, 7, bat_color2)
        @bat_bitmaps[14].set_pixel(1, 7, bat_color5)
        @bat_bitmaps[14].set_pixel(7, 7, bat_color2)
        @bat_bitmaps[14].set_pixel(8, 7, bat_color12)
        @bat_bitmaps[14].set_pixel(0, 8, bat_color5)
        @bat_bitmaps[14].set_pixel(8, 8, bat_color9)

        # Bat down 4
        @bat_bitmaps[15] = Bitmap.new(12, 7)
        @bat_bitmaps[15].set_pixel(5, 0, bat_color12)
        @bat_bitmaps[15].set_pixel(7, 0, bat_color12)
        @bat_bitmaps[15].set_pixel(5, 1, bat_color2)
        @bat_bitmaps[15].set_pixel(6, 1, bat_color9)
        @bat_bitmaps[15].set_pixel(7, 1, bat_color5)
        @bat_bitmaps[15].set_pixel(2, 2, bat_color9)
        @bat_bitmaps[15].set_pixel(4, 2, bat_color7)
        @bat_bitmaps[15].set_pixel(5, 2, bat_color18)
        @bat_bitmaps[15].set_pixel(6, 2, bat_color13)
        @bat_bitmaps[15].set_pixel(7, 2, bat_color18)
        @bat_bitmaps[15].fill_rect(9, 2, 2, 1, bat_color12)
        @bat_bitmaps[15].fill_rect(1, 3, 3, 1, bat_color12)
        @bat_bitmaps[15].set_pixel(4, 3, bat_color2)
        @bat_bitmaps[15].set_pixel(5, 3, bat_color5)
        @bat_bitmaps[15].set_pixel(6, 3, bat_color7)
        @bat_bitmaps[15].set_pixel(7, 3, bat_color5)
        @bat_bitmaps[15].set_pixel(8, 3, bat_color12)
        @bat_bitmaps[15].fill_rect(9, 3, 2, 1, bat_color2)
        @bat_bitmaps[15].fill_rect(0, 4, 3, 1, bat_color12)
        @bat_bitmaps[15].set_pixel(3, 4, bat_color4)
        @bat_bitmaps[15].set_pixel(4, 4, bat_color7)
        @bat_bitmaps[15].set_pixel(5, 4, bat_color9)
        @bat_bitmaps[15].fill_rect(6, 4, 2, 1, bat_color2)
        @bat_bitmaps[15].fill_rect(8, 4, 3, 1, bat_color4)
        @bat_bitmaps[15].set_pixel(11, 4, bat_color9)
        @bat_bitmaps[15].set_pixel(0, 5, bat_color2)
        @bat_bitmaps[15].set_pixel(1, 5, bat_color7)
        @bat_bitmaps[15].set_pixel(3, 5, bat_color7)
        @bat_bitmaps[15].fill_rect(4, 5, 2, 1, bat_color5)
        @bat_bitmaps[15].fill_rect(6, 5, 2, 1, bat_color12)
        @bat_bitmaps[15].set_pixel(8, 5, bat_color7)
        @bat_bitmaps[15].set_pixel(11, 5, bat_color4)
        @bat_bitmaps[15].set_pixel(0, 6, bat_color7)
        @bat_bitmaps[15].set_pixel(4, 6, bat_color7)
        @bat_bitmaps[15].set_pixel(5, 6, bat_color4)
        @bat_bitmaps[15].set_pixel(6, 6, bat_color5)
        @bat_bitmaps[15].set_pixel(7, 6, bat_color7)
      end
      #-------------------------------------------------------------------------------
      # Bee bitmaps
      if weather == :Bees
        # Bee left 1
        @bee_bitmaps = []
        @bee_bitmaps[0] = Bitmap.new(6, 7)
        @bee_bitmaps[0].fill_rect(2, 0, 1, 2, Color.new(128, 100, 138))
        @bee_bitmaps[0].fill_rect(4, 0, 1, 2, Color.new(201, 201, 201))
        @bee_bitmaps[0].set_pixel(5, 0, Color.new(100, 100, 100))
        @bee_bitmaps[0].set_pixel(0, 1, Color.new(57, 57, 57))
        @bee_bitmaps[0].set_pixel(3, 1, Color.new(136, 136, 136))
        @bee_bitmaps[0].set_pixel(0, 2, Color.new(124, 81, 63))
        @bee_bitmaps[0].set_pixel(1, 2, Color.new(83, 46, 41))
        @bee_bitmaps[0].fill_rect(2, 2, 1, 2, Color.new(151, 83, 25))
        @bee_bitmaps[0].set_pixel(3, 2, Color.new(100, 100, 100))
        @bee_bitmaps[0].set_pixel(5, 2, Color.new(170, 170, 170))
        @bee_bitmaps[0].set_pixel(0, 3, Color.new(83, 46, 41))
        @bee_bitmaps[0].set_pixel(1, 3, Color.new(151, 83, 25))
        @bee_bitmaps[0].set_pixel(3, 3, Color.new(83, 46, 41))
        @bee_bitmaps[0].fill_rect(4, 3, 1, 2, Color.new(124, 81, 63))
        @bee_bitmaps[0].set_pixel(1, 4, Color.new(83, 46, 41))
        @bee_bitmaps[0].set_pixel(2, 4, Color.new(30, 30, 30))
        @bee_bitmaps[0].set_pixel(3, 4, Color.new(193, 119, 50))
        @bee_bitmaps[0].fill_rect(3, 5, 2, 1, Color.new(30, 30, 30))
        @bee_bitmaps[0].set_pixel(4, 6, Color.new(100, 72, 20))

        # Bee left 2
        @bee_bitmaps[1] = Bitmap.new(6, 6)
        @bee_bitmaps[1].set_pixel(1, 0, Color.new(128, 100, 138))
        @bee_bitmaps[1].fill_rect(0, 1, 2, 1, Color.new(57, 57, 57))
        @bee_bitmaps[1].set_pixel(3, 1, Color.new(201, 201, 201))
        @bee_bitmaps[1].set_pixel(5, 1, Color.new(255, 255, 255))
        @bee_bitmaps[1].fill_rect(0, 2, 3, 1, Color.new(83, 46, 41))
        @bee_bitmaps[1].set_pixel(3, 2, Color.new(151, 83, 25))
        @bee_bitmaps[1].set_pixel(1, 3, Color.new(83, 46, 41))
        @bee_bitmaps[1].set_pixel(2, 3, Color.new(211, 118, 36))
        @bee_bitmaps[1].set_pixel(3, 3, Color.new(193, 119, 50))
        @bee_bitmaps[1].set_pixel(4, 3, Color.new(255, 255, 255))
        @bee_bitmaps[1].set_pixel(1, 4, Color.new(124, 81, 63))
        @bee_bitmaps[1].fill_rect(2, 4, 2, 1, Color.new(83, 46, 41))
        @bee_bitmaps[1].set_pixel(4, 4, Color.new(124, 81, 63))
        @bee_bitmaps[1].set_pixel(4, 5, Color.new(100, 72, 20))

        # Bee left 3
        @bee_bitmaps[2] = Bitmap.new(5, 7)
        @bee_bitmaps[2].fill_rect(2, 0, 1, 2, Color.new(128, 100, 138))
        @bee_bitmaps[2].set_pixel(3, 0, Color.new(255, 255, 255))
        @bee_bitmaps[2].set_pixel(3, 1, Color.new(170, 170, 170))
        @bee_bitmaps[2].set_pixel(1, 2, Color.new(57, 57, 57))
        @bee_bitmaps[2].set_pixel(2, 2, Color.new(211, 118, 36))
        @bee_bitmaps[2].set_pixel(0, 3, Color.new(255, 216, 89))
        @bee_bitmaps[2].fill_rect(1, 3, 1, 2, Color.new(151, 83, 25))
        @bee_bitmaps[2].set_pixel(2, 3, Color.new(83, 46, 41))
        @bee_bitmaps[2].set_pixel(3, 3, Color.new(151, 83, 25))
        @bee_bitmaps[2].set_pixel(2, 4, Color.new(151, 83, 25))
        @bee_bitmaps[2].set_pixel(3, 4, Color.new(193, 119, 50))
        @bee_bitmaps[2].set_pixel(4, 4, Color.new(201, 201, 201))
        @bee_bitmaps[2].set_pixel(2, 5, Color.new(83, 46, 41))
        @bee_bitmaps[2].set_pixel(3, 5, Color.new(124, 81, 63))
        @bee_bitmaps[2].set_pixel(4, 5, Color.new(193, 119, 50))
        @bee_bitmaps[2].set_pixel(4, 6, Color.new(219, 204, 120))

        # Bee left 4
        @bee_bitmaps[3] = Bitmap.new(6, 6)
        @bee_bitmaps[3].set_pixel(1, 0, Color.new(128, 100, 138))
        @bee_bitmaps[3].fill_rect(0, 1, 2, 1, Color.new(57, 57, 57))
        @bee_bitmaps[3].set_pixel(3, 1, Color.new(201, 201, 201))
        @bee_bitmaps[3].set_pixel(5, 1, Color.new(255, 255, 255))
        @bee_bitmaps[3].fill_rect(0, 2, 3, 1, Color.new(83, 46, 41))
        @bee_bitmaps[3].set_pixel(3, 2, Color.new(151, 83, 25))
        @bee_bitmaps[3].set_pixel(1, 3, Color.new(83, 46, 41))
        @bee_bitmaps[3].set_pixel(2, 3, Color.new(211, 118, 36))
        @bee_bitmaps[3].set_pixel(3, 3, Color.new(193, 119, 50))
        @bee_bitmaps[3].set_pixel(4, 3, Color.new(255, 255, 255))
        @bee_bitmaps[3].set_pixel(1, 4, Color.new(124, 81, 63))
        @bee_bitmaps[3].fill_rect(2, 4, 2, 1, Color.new(83, 46, 41))
        @bee_bitmaps[3].set_pixel(4, 4, Color.new(124, 81, 63))
        @bee_bitmaps[3].set_pixel(4, 5, Color.new(100, 72, 20))

        # Bee up 1
        @bee_bitmaps[4] = Bitmap.new(7, 6)
        @bee_bitmaps[4].set_pixel(2, 0, Color.new(57, 57, 57))
        @bee_bitmaps[4].set_pixel(4, 0, Color.new(57, 57, 57))
        @bee_bitmaps[4].fill_rect(0, 1, 2, 1, Color.new(201, 201, 201))
        @bee_bitmaps[4].set_pixel(2, 1, Color.new(71, 71, 71))
        @bee_bitmaps[4].fill_rect(3, 1, 1, 2, Color.new(252, 133, 37))
        @bee_bitmaps[4].set_pixel(4, 1, Color.new(71, 71, 71))
        @bee_bitmaps[4].fill_rect(5, 1, 2, 1, Color.new(201, 201, 201))
        @bee_bitmaps[4].set_pixel(2, 2, Color.new(170, 170, 170))
        @bee_bitmaps[4].set_pixel(4, 2, Color.new(170, 170, 170))
        @bee_bitmaps[4].set_pixel(0, 3, Color.new(136, 136, 136))
        @bee_bitmaps[4].set_pixel(1, 3, Color.new(240, 240, 240))
        @bee_bitmaps[4].set_pixel(2, 3, Color.new(83, 46, 41))
        @bee_bitmaps[4].set_pixel(3, 3, Color.new(244, 192, 79))
        @bee_bitmaps[4].set_pixel(4, 3, Color.new(83, 46, 41))
        @bee_bitmaps[4].set_pixel(5, 3, Color.new(240, 240, 240))
        @bee_bitmaps[4].set_pixel(6, 3, Color.new(136, 136, 136))
        @bee_bitmaps[4].set_pixel(2, 4, Color.new(124, 81, 63))
        @bee_bitmaps[4].set_pixel(3, 4, Color.new(193, 119, 50))
        @bee_bitmaps[4].set_pixel(4, 4, Color.new(124, 81, 63))
        @bee_bitmaps[4].set_pixel(3, 5, Color.new(83, 46, 41))

        # Bee up 2
        @bee_bitmaps[5] = Bitmap.new(7, 6)
        @bee_bitmaps[5].set_pixel(0, 0, Color.new(206, 215, 221))
        @bee_bitmaps[5].set_pixel(1, 0, Color.new(170, 170, 170))
        @bee_bitmaps[5].set_pixel(3, 0, Color.new(188, 107, 30))
        @bee_bitmaps[5].set_pixel(5, 0, Color.new(170, 170, 170))
        @bee_bitmaps[5].set_pixel(6, 0, Color.new(206, 215, 221))
        @bee_bitmaps[5].set_pixel(0, 1, Color.new(102, 163, 192))
        @bee_bitmaps[5].set_pixel(2, 1, Color.new(170, 170, 170))
        @bee_bitmaps[5].set_pixel(3, 1, Color.new(252, 133, 37))
        @bee_bitmaps[5].set_pixel(4, 1, Color.new(170, 170, 170))
        @bee_bitmaps[5].set_pixel(6, 1, Color.new(102, 163, 192))
        @bee_bitmaps[5].set_pixel(0, 2, Color.new(206, 215, 221))
        @bee_bitmaps[5].fill_rect(2, 2, 3, 1, Color.new(211, 118, 36))
        @bee_bitmaps[5].set_pixel(6, 2, Color.new(206, 215, 221))
        @bee_bitmaps[5].fill_rect(2, 3, 1, 2, Color.new(124, 81, 63))
        @bee_bitmaps[5].set_pixel(3, 3, Color.new(255, 216, 89))
        @bee_bitmaps[5].fill_rect(4, 3, 1, 2, Color.new(124, 81, 63))
        @bee_bitmaps[5].set_pixel(3, 4, Color.new(83, 46, 41))
        @bee_bitmaps[5].set_pixel(3, 5, Color.new(100, 72, 20))

        # Bee up 3
        @bee_bitmaps[6] = Bitmap.new(3, 7)
        @bee_bitmaps[6].set_pixel(0, 0, Color.new(240, 240, 240))
        @bee_bitmaps[6].set_pixel(2, 0, Color.new(240, 240, 240))
        @bee_bitmaps[6].set_pixel(0, 1, Color.new(201, 201, 201))
        @bee_bitmaps[6].set_pixel(1, 1, Color.new(255, 216, 89))
        @bee_bitmaps[6].set_pixel(2, 1, Color.new(201, 201, 201))
        @bee_bitmaps[6].fill_rect(0, 2, 3, 1, Color.new(252, 133, 37))
        @bee_bitmaps[6].set_pixel(0, 3, Color.new(100, 100, 100))
        @bee_bitmaps[6].set_pixel(1, 3, Color.new(151, 83, 25))
        @bee_bitmaps[6].set_pixel(2, 3, Color.new(100, 100, 100))
        @bee_bitmaps[6].set_pixel(0, 4, Color.new(240, 240, 240))
        @bee_bitmaps[6].set_pixel(1, 4, Color.new(83, 46, 41))
        @bee_bitmaps[6].set_pixel(2, 4, Color.new(240, 240, 240))
        @bee_bitmaps[6].set_pixel(0, 5, Color.new(83, 46, 41))
        @bee_bitmaps[6].set_pixel(1, 5, Color.new(226, 163, 69))
        @bee_bitmaps[6].set_pixel(2, 5, Color.new(83, 46, 41))
        @bee_bitmaps[6].set_pixel(1, 6, Color.new(219, 204, 120))

        # Bee up 4
        @bee_bitmaps[7] = Bitmap.new(7, 6)
        @bee_bitmaps[7].set_pixel(0, 0, Color.new(206, 215, 221))
        @bee_bitmaps[7].set_pixel(1, 0, Color.new(170, 170, 170))
        @bee_bitmaps[7].set_pixel(3, 0, Color.new(188, 107, 30))
        @bee_bitmaps[7].set_pixel(5, 0, Color.new(170, 170, 170))
        @bee_bitmaps[7].set_pixel(6, 0, Color.new(206, 215, 221))
        @bee_bitmaps[7].set_pixel(0, 1, Color.new(102, 163, 192))
        @bee_bitmaps[7].set_pixel(2, 1, Color.new(170, 170, 170))
        @bee_bitmaps[7].set_pixel(3, 1, Color.new(252, 133, 37))
        @bee_bitmaps[7].set_pixel(4, 1, Color.new(170, 170, 170))
        @bee_bitmaps[7].set_pixel(6, 1, Color.new(102, 163, 192))
        @bee_bitmaps[7].set_pixel(0, 2, Color.new(206, 215, 221))
        @bee_bitmaps[7].fill_rect(2, 2, 3, 1, Color.new(211, 118, 36))
        @bee_bitmaps[7].set_pixel(6, 2, Color.new(206, 215, 221))
        @bee_bitmaps[7].fill_rect(2, 3, 1, 2, Color.new(124, 81, 63))
        @bee_bitmaps[7].set_pixel(3, 3, Color.new(255, 216, 89))
        @bee_bitmaps[7].fill_rect(4, 3, 1, 2, Color.new(124, 81, 63))
        @bee_bitmaps[7].set_pixel(3, 4, Color.new(83, 46, 41))
        @bee_bitmaps[7].set_pixel(3, 5, Color.new(100, 72, 20))

        # Bee right 1
        @bee_bitmaps[8] = Bitmap.new(6, 6)
        @bee_bitmaps[8].set_pixel(0, 0, Color.new(201, 201, 201))
        @bee_bitmaps[8].set_pixel(1, 0, Color.new(170, 170, 170))
        @bee_bitmaps[8].fill_rect(3, 0, 1, 2, Color.new(128, 100, 138))
        @bee_bitmaps[8].set_pixel(1, 1, Color.new(255, 255, 255))
        @bee_bitmaps[8].fill_rect(4, 1, 2, 1, Color.new(57, 57, 57))
        @bee_bitmaps[8].set_pixel(0, 2, Color.new(136, 136, 136))
        @bee_bitmaps[8].set_pixel(2, 2, Color.new(100, 100, 100))
        @bee_bitmaps[8].set_pixel(3, 2, Color.new(193, 119, 50))
        @bee_bitmaps[8].set_pixel(4, 2, Color.new(226, 163, 69))
        @bee_bitmaps[8].set_pixel(0, 3, Color.new(71, 71, 71))
        @bee_bitmaps[8].fill_rect(1, 3, 1, 2, Color.new(226, 163, 69))
        @bee_bitmaps[8].set_pixel(2, 3, Color.new(151, 83, 25))
        @bee_bitmaps[8].fill_rect(3, 3, 1, 2, Color.new(83, 46, 41))
        @bee_bitmaps[8].set_pixel(4, 3, Color.new(151, 83, 25))
        @bee_bitmaps[8].fill_rect(2, 4, 1, 2, Color.new(83, 46, 41))
        @bee_bitmaps[8].set_pixel(4, 4, Color.new(30, 30, 30))
        @bee_bitmaps[8].set_pixel(1, 5, Color.new(83, 46, 41))
        @bee_bitmaps[8].set_pixel(3, 5, Color.new(30, 30, 30))

        # Bee right 2
        @bee_bitmaps[9] = Bitmap.new(6, 6)
        @bee_bitmaps[9].set_pixel(0, 0, Color.new(102, 163, 192))
        @bee_bitmaps[9].set_pixel(1, 0, Color.new(255, 255, 255))
        @bee_bitmaps[9].fill_rect(3, 0, 2, 1, Color.new(128, 100, 138))
        @bee_bitmaps[9].set_pixel(0, 1, Color.new(255, 255, 255))
        @bee_bitmaps[9].set_pixel(2, 1, Color.new(201, 201, 201))
        @bee_bitmaps[9].set_pixel(3, 1, Color.new(128, 100, 138))
        @bee_bitmaps[9].fill_rect(4, 1, 2, 1, Color.new(57, 57, 57))
        @bee_bitmaps[9].set_pixel(2, 2, Color.new(151, 83, 25))
        @bee_bitmaps[9].fill_rect(3, 2, 2, 1, Color.new(193, 119, 50))
        @bee_bitmaps[9].set_pixel(1, 3, Color.new(170, 170, 170))
        @bee_bitmaps[9].set_pixel(2, 3, Color.new(252, 133, 37))
        @bee_bitmaps[9].set_pixel(3, 3, Color.new(151, 83, 25))
        @bee_bitmaps[9].set_pixel(4, 3, Color.new(83, 46, 41))
        @bee_bitmaps[9].set_pixel(1, 4, Color.new(193, 119, 50))
        @bee_bitmaps[9].fill_rect(2, 4, 1, 2, Color.new(83, 46, 41))
        @bee_bitmaps[9].set_pixel(3, 4, Color.new(30, 30, 30))
        @bee_bitmaps[9].set_pixel(1, 5, Color.new(30, 30, 30))

        # Bee right 3
        @bee_bitmaps[10] = Bitmap.new(5, 7)
        @bee_bitmaps[10].set_pixel(1, 0, Color.new(255, 255, 255))
        @bee_bitmaps[10].fill_rect(2, 0, 1, 2, Color.new(128, 100, 138))
        @bee_bitmaps[10].set_pixel(1, 1, Color.new(201, 201, 201))
        @bee_bitmaps[10].set_pixel(1, 2, Color.new(100, 100, 100))
        @bee_bitmaps[10].fill_rect(2, 2, 1, 2, Color.new(151, 83, 25))
        @bee_bitmaps[10].set_pixel(3, 2, Color.new(255, 216, 89))
        @bee_bitmaps[10].set_pixel(1, 3, Color.new(252, 133, 37))
        @bee_bitmaps[10].fill_rect(3, 3, 1, 2, Color.new(151, 83, 25))
        @bee_bitmaps[10].set_pixel(4, 3, Color.new(83, 46, 41))
        @bee_bitmaps[10].set_pixel(0, 4, Color.new(255, 255, 255))
        @bee_bitmaps[10].fill_rect(1, 4, 1, 2, Color.new(83, 46, 41))
        @bee_bitmaps[10].set_pixel(2, 4, Color.new(211, 118, 36))
        @bee_bitmaps[10].set_pixel(0, 5, Color.new(124, 81, 63))
        @bee_bitmaps[10].set_pixel(0, 6, Color.new(100, 72, 20))

        # Bee right 4
        @bee_bitmaps[11] = Bitmap.new(6, 6)
        @bee_bitmaps[11].set_pixel(0, 0, Color.new(102, 163, 192))
        @bee_bitmaps[11].set_pixel(1, 0, Color.new(255, 255, 255))
        @bee_bitmaps[11].fill_rect(3, 0, 2, 1, Color.new(128, 100, 138))
        @bee_bitmaps[11].set_pixel(0, 1, Color.new(255, 255, 255))
        @bee_bitmaps[11].set_pixel(2, 1, Color.new(201, 201, 201))
        @bee_bitmaps[11].set_pixel(3, 1, Color.new(128, 100, 138))
        @bee_bitmaps[11].fill_rect(4, 1, 2, 1, Color.new(57, 57, 57))
        @bee_bitmaps[11].set_pixel(2, 2, Color.new(151, 83, 25))
        @bee_bitmaps[11].fill_rect(3, 2, 2, 1, Color.new(193, 119, 50))
        @bee_bitmaps[11].set_pixel(1, 3, Color.new(170, 170, 170))
        @bee_bitmaps[11].set_pixel(2, 3, Color.new(252, 133, 37))
        @bee_bitmaps[11].set_pixel(3, 3, Color.new(151, 83, 25))
        @bee_bitmaps[11].set_pixel(4, 3, Color.new(83, 46, 41))
        @bee_bitmaps[11].set_pixel(1, 4, Color.new(193, 119, 50))
        @bee_bitmaps[11].fill_rect(2, 4, 1, 2, Color.new(83, 46, 41))
        @bee_bitmaps[11].set_pixel(3, 4, Color.new(30, 30, 30))
        @bee_bitmaps[11].set_pixel(1, 5, Color.new(30, 30, 30))

        # Bee down 1
        @bee_bitmaps[12] = Bitmap.new(7, 6)
        @bee_bitmaps[12].set_pixel(2, 0, Color.new(57, 57, 57))
        @bee_bitmaps[12].set_pixel(4, 0, Color.new(57, 57, 57))
        @bee_bitmaps[12].set_pixel(0, 1, Color.new(255, 255, 255))
        @bee_bitmaps[12].set_pixel(1, 1, Color.new(170, 170, 170))
        @bee_bitmaps[12].set_pixel(2, 1, Color.new(83, 46, 41))
        @bee_bitmaps[12].set_pixel(3, 1, Color.new(226, 163, 69))
        @bee_bitmaps[12].set_pixel(4, 1, Color.new(83, 46, 41))
        @bee_bitmaps[12].set_pixel(5, 1, Color.new(170, 170, 170))
        @bee_bitmaps[12].set_pixel(6, 1, Color.new(255, 255, 255))
        @bee_bitmaps[12].set_pixel(1, 2, Color.new(100, 100, 100))
        @bee_bitmaps[12].set_pixel(2, 2, Color.new(252, 133, 37))
        @bee_bitmaps[12].set_pixel(3, 2, Color.new(83, 46, 41))
        @bee_bitmaps[12].set_pixel(4, 2, Color.new(252, 133, 37))
        @bee_bitmaps[12].set_pixel(5, 2, Color.new(100, 100, 100))
        @bee_bitmaps[12].set_pixel(0, 3, Color.new(255, 255, 255))
        @bee_bitmaps[12].set_pixel(1, 3, Color.new(71, 71, 71))
        @bee_bitmaps[12].set_pixel(2, 3, Color.new(255, 216, 89))
        @bee_bitmaps[12].set_pixel(3, 3, Color.new(30, 30, 30))
        @bee_bitmaps[12].set_pixel(4, 3, Color.new(255, 216, 89))
        @bee_bitmaps[12].set_pixel(5, 3, Color.new(71, 71, 71))
        @bee_bitmaps[12].set_pixel(6, 3, Color.new(255, 255, 255))
        @bee_bitmaps[12].set_pixel(2, 4, Color.new(30, 30, 30))
        @bee_bitmaps[12].set_pixel(3, 4, Color.new(124, 81, 63))
        @bee_bitmaps[12].set_pixel(4, 4, Color.new(30, 30, 30))
        @bee_bitmaps[12].set_pixel(3, 5, Color.new(100, 72, 20))

        # Bee down 2
        @bee_bitmaps[13] = Bitmap.new(7, 6)
        @bee_bitmaps[13].set_pixel(0, 0, Color.new(206, 215, 221))
        @bee_bitmaps[13].set_pixel(1, 0, Color.new(170, 170, 170))
        @bee_bitmaps[13].fill_rect(3, 0, 1, 2, Color.new(209, 136, 57))
        @bee_bitmaps[13].set_pixel(5, 0, Color.new(170, 170, 170))
        @bee_bitmaps[13].set_pixel(6, 0, Color.new(206, 215, 221))
        @bee_bitmaps[13].set_pixel(0, 1, Color.new(102, 163, 192))
        @bee_bitmaps[13].set_pixel(2, 1, Color.new(112, 61, 20))
        @bee_bitmaps[13].set_pixel(4, 1, Color.new(112, 61, 20))
        @bee_bitmaps[13].set_pixel(6, 1, Color.new(102, 163, 192))
        @bee_bitmaps[13].set_pixel(0, 2, Color.new(206, 215, 221))
        @bee_bitmaps[13].set_pixel(2, 2, Color.new(211, 118, 36))
        @bee_bitmaps[13].set_pixel(3, 2, Color.new(188, 107, 30))
        @bee_bitmaps[13].set_pixel(4, 2, Color.new(211, 118, 36))
        @bee_bitmaps[13].set_pixel(6, 2, Color.new(206, 215, 221))
        @bee_bitmaps[13].fill_rect(2, 3, 1, 2, Color.new(30, 30, 30))
        @bee_bitmaps[13].set_pixel(3, 3, Color.new(83, 46, 41))
        @bee_bitmaps[13].fill_rect(4, 3, 1, 2, Color.new(30, 30, 30))
        @bee_bitmaps[13].set_pixel(3, 4, Color.new(193, 119, 50))
        @bee_bitmaps[13].set_pixel(3, 5, Color.new(219, 204, 120))

        # Bee down 3
        @bee_bitmaps[14] = Bitmap.new(5, 7)
        @bee_bitmaps[14].set_pixel(0, 0, Color.new(255, 255, 255))
        @bee_bitmaps[14].set_pixel(4, 0, Color.new(255, 255, 255))
        @bee_bitmaps[14].set_pixel(0, 1, Color.new(170, 170, 170))
        @bee_bitmaps[14].set_pixel(2, 1, Color.new(255, 216, 89))
        @bee_bitmaps[14].set_pixel(4, 1, Color.new(170, 170, 170))
        @bee_bitmaps[14].fill_rect(1, 2, 1, 2, Color.new(151, 83, 25))
        @bee_bitmaps[14].set_pixel(2, 2, Color.new(83, 46, 41))
        @bee_bitmaps[14].fill_rect(3, 2, 1, 2, Color.new(151, 83, 25))
        @bee_bitmaps[14].set_pixel(2, 3, Color.new(252, 133, 37))
        @bee_bitmaps[14].set_pixel(0, 4, Color.new(206, 215, 221))
        @bee_bitmaps[14].fill_rect(1, 4, 3, 1, Color.new(124, 81, 63))
        @bee_bitmaps[14].set_pixel(4, 4, Color.new(206, 215, 221))
        @bee_bitmaps[14].set_pixel(0, 5, Color.new(170, 170, 170))
        @bee_bitmaps[14].set_pixel(2, 5, Color.new(193, 119, 50))
        @bee_bitmaps[14].set_pixel(4, 5, Color.new(170, 170, 170))
        @bee_bitmaps[14].set_pixel(2, 6, Color.new(100, 72, 20))

        # Bee down 4
        @bee_bitmaps[15] = Bitmap.new(7, 6)
        @bee_bitmaps[15].set_pixel(0, 0, Color.new(206, 215, 221))
        @bee_bitmaps[15].set_pixel(1, 0, Color.new(170, 170, 170))
        @bee_bitmaps[15].fill_rect(3, 0, 1, 2, Color.new(209, 136, 57))
        @bee_bitmaps[15].set_pixel(5, 0, Color.new(170, 170, 170))
        @bee_bitmaps[15].set_pixel(6, 0, Color.new(206, 215, 221))
        @bee_bitmaps[15].set_pixel(0, 1, Color.new(102, 163, 192))
        @bee_bitmaps[15].set_pixel(2, 1, Color.new(112, 61, 20))
        @bee_bitmaps[15].set_pixel(4, 1, Color.new(112, 61, 20))
        @bee_bitmaps[15].set_pixel(6, 1, Color.new(102, 163, 192))
        @bee_bitmaps[15].set_pixel(0, 2, Color.new(206, 215, 221))
        @bee_bitmaps[15].set_pixel(2, 2, Color.new(211, 118, 36))
        @bee_bitmaps[15].set_pixel(3, 2, Color.new(188, 107, 30))
        @bee_bitmaps[15].set_pixel(4, 2, Color.new(211, 118, 36))
        @bee_bitmaps[15].set_pixel(6, 2, Color.new(206, 215, 221))
        @bee_bitmaps[15].fill_rect(2, 3, 1, 2, Color.new(30, 30, 30))
        @bee_bitmaps[15].set_pixel(3, 3, Color.new(83, 46, 41))
        @bee_bitmaps[15].fill_rect(4, 3, 1, 2, Color.new(30, 30, 30))
        @bee_bitmaps[15].set_pixel(3, 4, Color.new(193, 119, 50))
        @bee_bitmaps[15].set_pixel(3, 5, Color.new(219, 204, 120))
      end
      #-------------------------------------------------------------------------------
      # Fish bitmap
      if weather == :Fish
        fish_color1 = Color.new(114, 114, 114)
        fish_color2 = Color.new(86, 86, 86)
        fish_color3 = Color.new(177, 170, 170)
        fish_color4 = Color.new(113, 154, 170)
        fish_color5 = Color.new(143, 166, 191)
        fish_color6 = Color.new(149, 175, 202)
        fish_color7 = Color.new(133, 138, 132)
        fish_color8 = Color.new(207, 208, 206)
        fish_color9 = Color.new(160, 166, 160)
        fish_color10 = Color.new(229, 229, 231)
        fish_color11 = Color.new(176, 173, 184)

        # Small fish bitmap
        @fish_bitmap = Bitmap.new(19, 6)
        @fish_bitmap.fill_rect(3, 0, 9, 1, fish_color1)
        @fish_bitmap.set_pixel(1, 1, fish_color2)
        @fish_bitmap.set_pixel(2, 1, fish_color1)
        @fish_bitmap.set_pixel(3, 1, fish_color3)
        @fish_bitmap.fill_rect(4, 1, 2, 1, fish_color4)
        @fish_bitmap.set_pixel(6, 1, fish_color5)
        @fish_bitmap.fill_rect(7, 1, 2, 1, fish_color6)
        @fish_bitmap.fill_rect(9, 1, 2, 1, fish_color5)
        @fish_bitmap.set_pixel(11, 1, fish_color7)
        @fish_bitmap.fill_rect(12, 1, 2, 1, fish_color1)
        @fish_bitmap.fill_rect(14, 1, 2, 1, fish_color2)
        @fish_bitmap.set_pixel(16, 1, fish_color7)
        @fish_bitmap.set_pixel(17, 1, fish_color3)
        @fish_bitmap.set_pixel(18, 1, fish_color1)
        @fish_bitmap.fill_rect(0, 2, 1, 2, fish_color2)
        @fish_bitmap.set_pixel(1, 2, fish_color7)
        @fish_bitmap.set_pixel(2, 2, fish_color3)
        @fish_bitmap.fill_rect(3, 2, 1, 2, fish_color8)
        @fish_bitmap.fill_rect(4, 2, 1, 2, fish_color1)
        @fish_bitmap.set_pixel(5, 2, fish_color9)
        @fish_bitmap.fill_rect(6, 2, 2, 1, fish_color3)
        @fish_bitmap.fill_rect(8, 2, 4, 1, fish_color8)
        @fish_bitmap.fill_rect(12, 2, 3, 1, fish_color3)
        @fish_bitmap.set_pixel(15, 2, fish_color7)
        @fish_bitmap.set_pixel(16, 2, fish_color1)
        @fish_bitmap.set_pixel(17, 2, fish_color2)
        @fish_bitmap.set_pixel(1, 3, fish_color3)
        @fish_bitmap.set_pixel(2, 3, fish_color8)
        @fish_bitmap.set_pixel(5, 3, fish_color7)
        @fish_bitmap.fill_rect(6, 3, 4, 1, fish_color8)
        @fish_bitmap.fill_rect(10, 3, 3, 1, fish_color10)
        @fish_bitmap.fill_rect(13, 3, 2, 1, fish_color8)
        @fish_bitmap.set_pixel(15, 3, fish_color3)
        @fish_bitmap.set_pixel(16, 3, fish_color7)
        @fish_bitmap.set_pixel(17, 3, fish_color1)
        @fish_bitmap.fill_rect(1, 4, 3, 1, fish_color2)
        @fish_bitmap.set_pixel(4, 4, fish_color3)
        @fish_bitmap.set_pixel(5, 4, fish_color1)
        @fish_bitmap.fill_rect(6, 4, 3, 1, fish_color3)
        @fish_bitmap.set_pixel(9, 4, fish_color9)
        @fish_bitmap.fill_rect(10, 4, 2, 1, fish_color7)
        @fish_bitmap.fill_rect(12, 4, 2, 1, fish_color1)
        @fish_bitmap.fill_rect(14, 4, 2, 1, fish_color2)
        @fish_bitmap.set_pixel(16, 4, fish_color1)
        @fish_bitmap.set_pixel(17, 4, fish_color3)
        @fish_bitmap.set_pixel(18, 4, fish_color7)
        @fish_bitmap.set_pixel(3, 5, fish_color11)
        @fish_bitmap.fill_rect(4, 5, 2, 1, fish_color2)
        @fish_bitmap.fill_rect(6, 5, 6, 1, fish_color1)
      end
      #-------------------------------------------------------------------------------
      # Raven bitmaps
      if weather == :Raven
        @raven_bitmaps = []
        raven_color1 = Color.new(57, 57, 57)
        raven_color2 = Color.new(71, 71, 71)
        raven_color3 = Color.new(30, 30, 30)
        raven_color4 = Color.new(84, 83, 80)
        raven_color5 = Color.new(100, 100, 100)
        raven_color6 = Color.new(136, 136, 136)
        raven_color7 = Color.new(76, 80, 80)

        # Raven left 1
        @raven_bitmaps[0] = Bitmap.new(14, 11)
        @raven_bitmaps[0].fill_rect(7, 0, 3, 1, raven_color1)
        @raven_bitmaps[0].fill_rect(5, 1, 1, 3, raven_color1)
        @raven_bitmaps[0].fill_rect(6, 1, 2, 2, raven_color2)
        @raven_bitmaps[0].set_pixel(8, 1, raven_color1)
        @raven_bitmaps[0].fill_rect(9, 1, 1, 2, raven_color2)
        @raven_bitmaps[0].fill_rect(10, 1, 1, 2, raven_color3)
        @raven_bitmaps[0].fill_rect(8, 2, 1, 2, raven_color2)
        @raven_bitmaps[0].fill_rect(1, 3, 1, 2, raven_color1)
        @raven_bitmaps[0].fill_rect(2, 3, 2, 2, raven_color4)
        @raven_bitmaps[0].set_pixel(4, 3, raven_color2)
        @raven_bitmaps[0].set_pixel(6, 3, raven_color1)
        @raven_bitmaps[0].set_pixel(7, 3, raven_color2)
        @raven_bitmaps[0].set_pixel(9, 3, raven_color1)
        @raven_bitmaps[0].set_pixel(0, 4, raven_color5)
        @raven_bitmaps[0].fill_rect(4, 4, 2, 1, raven_color4)
        @raven_bitmaps[0].set_pixel(6, 4, raven_color2)
        @raven_bitmaps[0].fill_rect(7, 4, 3, 2, raven_color4)
        @raven_bitmaps[0].fill_rect(10, 4, 1, 2, raven_color1)
        @raven_bitmaps[0].fill_rect(11, 4, 2, 1, raven_color3)
        @raven_bitmaps[0].set_pixel(0, 5, raven_color1)
        @raven_bitmaps[0].fill_rect(1, 5, 2, 1, raven_color3)
        @raven_bitmaps[0].set_pixel(3, 5, raven_color1)
        @raven_bitmaps[0].fill_rect(4, 5, 2, 1, raven_color2)
        @raven_bitmaps[0].set_pixel(6, 5, raven_color1)
        @raven_bitmaps[0].fill_rect(11, 5, 1, 2, raven_color4)
        @raven_bitmaps[0].fill_rect(12, 5, 1, 2, raven_color1)
        @raven_bitmaps[0].set_pixel(13, 5, raven_color3)
        @raven_bitmaps[0].set_pixel(4, 6, raven_color1)
        @raven_bitmaps[0].set_pixel(5, 6, raven_color2)
        @raven_bitmaps[0].fill_rect(6, 6, 3, 1, raven_color4)
        @raven_bitmaps[0].set_pixel(9, 6, raven_color1)
        @raven_bitmaps[0].fill_rect(10, 6, 1, 2, raven_color3)
        @raven_bitmaps[0].set_pixel(13, 6, raven_color1)
        @raven_bitmaps[0].set_pixel(4, 7, raven_color3)
        @raven_bitmaps[0].fill_rect(5, 7, 3, 1, raven_color4)
        @raven_bitmaps[0].set_pixel(8, 7, raven_color3)
        @raven_bitmaps[0].set_pixel(9, 7, raven_color2)
        @raven_bitmaps[0].set_pixel(11, 7, raven_color3)
        @raven_bitmaps[0].set_pixel(12, 7, raven_color2)
        @raven_bitmaps[0].set_pixel(13, 7, raven_color3)
        @raven_bitmaps[0].set_pixel(5, 8, raven_color3)
        @raven_bitmaps[0].set_pixel(6, 8, raven_color4)
        @raven_bitmaps[0].set_pixel(7, 8, raven_color3)
        @raven_bitmaps[0].set_pixel(8, 8, raven_color2)
        @raven_bitmaps[0].set_pixel(9, 8, raven_color3)
        @raven_bitmaps[0].set_pixel(11, 8, raven_color1)
        @raven_bitmaps[0].set_pixel(6, 9, raven_color3)
        @raven_bitmaps[0].set_pixel(7, 9, raven_color1)
        @raven_bitmaps[0].fill_rect(8, 9, 1, 2, raven_color3)
        @raven_bitmaps[0].set_pixel(7, 10, raven_color3)

        # Raven left 2
        @raven_bitmaps[1] = Bitmap.new(15, 12)
        @raven_bitmaps[1].fill_rect(5, 0, 2, 1, raven_color2)
        @raven_bitmaps[1].set_pixel(7, 0, raven_color1)
        @raven_bitmaps[1].fill_rect(2, 1, 3, 1, raven_color1)
        @raven_bitmaps[1].set_pixel(5, 1, raven_color3)
        @raven_bitmaps[1].fill_rect(6, 1, 3, 1, raven_color2)
        @raven_bitmaps[1].fill_rect(1, 2, 5, 1, raven_color4)
        @raven_bitmaps[1].fill_rect(6, 2, 2, 1, raven_color2)
        @raven_bitmaps[1].fill_rect(8, 2, 2, 1, raven_color1)
        @raven_bitmaps[1].set_pixel(0, 3, raven_color6)
        @raven_bitmaps[1].set_pixel(1, 3, raven_color1)
        @raven_bitmaps[1].set_pixel(2, 3, raven_color4)
        @raven_bitmaps[1].set_pixel(3, 3, raven_color1)
        @raven_bitmaps[1].fill_rect(4, 3, 2, 1, raven_color4)
        @raven_bitmaps[1].set_pixel(6, 3, raven_color1)
        @raven_bitmaps[1].fill_rect(7, 3, 3, 1, raven_color4)
        @raven_bitmaps[1].fill_rect(10, 3, 2, 1, raven_color1)
        @raven_bitmaps[1].fill_rect(12, 3, 2, 1, raven_color3)
        @raven_bitmaps[1].set_pixel(3, 4, raven_color3)
        @raven_bitmaps[1].set_pixel(4, 4, raven_color1)
        @raven_bitmaps[1].set_pixel(5, 4, raven_color3)
        @raven_bitmaps[1].set_pixel(6, 4, raven_color2)
        @raven_bitmaps[1].fill_rect(7, 4, 2, 1, raven_color4)
        @raven_bitmaps[1].fill_rect(9, 4, 2, 1, raven_color2)
        @raven_bitmaps[1].set_pixel(11, 4, raven_color1)
        @raven_bitmaps[1].fill_rect(12, 4, 2, 1, raven_color4)
        @raven_bitmaps[1].set_pixel(14, 4, raven_color3)
        @raven_bitmaps[1].set_pixel(5, 5, raven_color1)
        @raven_bitmaps[1].fill_rect(6, 5, 2, 1, raven_color4)
        @raven_bitmaps[1].set_pixel(8, 5, raven_color3)
        @raven_bitmaps[1].set_pixel(9, 5, raven_color2)
        @raven_bitmaps[1].fill_rect(10, 5, 1, 2, raven_color1)
        @raven_bitmaps[1].set_pixel(11, 5, raven_color3)
        @raven_bitmaps[1].set_pixel(12, 5, raven_color4)
        @raven_bitmaps[1].set_pixel(13, 5, raven_color3)
        @raven_bitmaps[1].set_pixel(4, 6, raven_color2)
        @raven_bitmaps[1].fill_rect(5, 6, 2, 2, raven_color4)
        @raven_bitmaps[1].set_pixel(7, 6, raven_color1)
        @raven_bitmaps[1].set_pixel(8, 6, raven_color2)
        @raven_bitmaps[1].set_pixel(9, 6, raven_color1)
        @raven_bitmaps[1].set_pixel(12, 6, raven_color3)
        @raven_bitmaps[1].set_pixel(13, 6, raven_color1)
        @raven_bitmaps[1].set_pixel(4, 7, raven_color3)
        @raven_bitmaps[1].set_pixel(7, 7, raven_color3)
        @raven_bitmaps[1].set_pixel(8, 7, raven_color1)
        @raven_bitmaps[1].set_pixel(11, 7, raven_color1)
        @raven_bitmaps[1].set_pixel(5, 8, raven_color4)
        @raven_bitmaps[1].set_pixel(6, 8, raven_color1)
        @raven_bitmaps[1].set_pixel(7, 8, raven_color4)
        @raven_bitmaps[1].fill_rect(8, 8, 1, 2, raven_color3)
        @raven_bitmaps[1].set_pixel(5, 9, raven_color3)
        @raven_bitmaps[1].set_pixel(6, 9, raven_color4)
        @raven_bitmaps[1].set_pixel(7, 9, raven_color3)
        @raven_bitmaps[1].set_pixel(6, 10, raven_color2)
        @raven_bitmaps[1].set_pixel(7, 10, raven_color1)
        @raven_bitmaps[1].fill_rect(6, 11, 2, 1, raven_color3)

        # Raven left 3
        @raven_bitmaps[2] = Bitmap.new(14, 13)
        @raven_bitmaps[2].set_pixel(3, 0, raven_color2)
        @raven_bitmaps[2].set_pixel(4, 0, raven_color1)
        @raven_bitmaps[2].fill_rect(6, 0, 3, 1, raven_color1)
        @raven_bitmaps[2].set_pixel(1, 1, raven_color1)
        @raven_bitmaps[2].fill_rect(2, 1, 4, 1, raven_color4)
        @raven_bitmaps[2].set_pixel(6, 1, raven_color2)
        @raven_bitmaps[2].fill_rect(7, 1, 3, 1, raven_color1)
        @raven_bitmaps[2].set_pixel(10, 1, raven_color3)
        @raven_bitmaps[2].fill_rect(0, 2, 2, 1, raven_color5)
        @raven_bitmaps[2].set_pixel(2, 2, raven_color2)
        @raven_bitmaps[2].fill_rect(3, 2, 8, 1, raven_color4)
        @raven_bitmaps[2].set_pixel(11, 2, raven_color3)
        @raven_bitmaps[2].set_pixel(4, 3, raven_color1)
        @raven_bitmaps[2].fill_rect(5, 3, 1, 2, raven_color3)
        @raven_bitmaps[2].fill_rect(6, 3, 3, 1, raven_color4)
        @raven_bitmaps[2].fill_rect(9, 3, 3, 1, raven_color2)
        @raven_bitmaps[2].set_pixel(12, 3, raven_color3)
        @raven_bitmaps[2].fill_rect(6, 4, 2, 3, raven_color4)
        @raven_bitmaps[2].fill_rect(8, 4, 1, 4, raven_color1)
        @raven_bitmaps[2].fill_rect(9, 4, 1, 3, raven_color3)
        @raven_bitmaps[2].fill_rect(10, 4, 1, 2, raven_color1)
        @raven_bitmaps[2].set_pixel(11, 4, raven_color2)
        @raven_bitmaps[2].fill_rect(12, 4, 2, 1, raven_color1)
        @raven_bitmaps[2].fill_rect(5, 5, 1, 3, raven_color4)
        @raven_bitmaps[2].set_pixel(11, 5, raven_color3)
        @raven_bitmaps[2].set_pixel(12, 5, raven_color2)
        @raven_bitmaps[2].set_pixel(13, 5, raven_color3)
        @raven_bitmaps[2].set_pixel(4, 6, raven_color1)
        @raven_bitmaps[2].set_pixel(11, 6, raven_color1)
        @raven_bitmaps[2].set_pixel(12, 6, raven_color3)
        @raven_bitmaps[2].set_pixel(3, 7, raven_color3)
        @raven_bitmaps[2].set_pixel(4, 7, raven_color4)
        @raven_bitmaps[2].fill_rect(6, 7, 1, 2, raven_color4)
        @raven_bitmaps[2].fill_rect(7, 7, 1, 2, raven_color2)
        @raven_bitmaps[2].fill_rect(4, 8, 1, 3, raven_color2)
        @raven_bitmaps[2].fill_rect(5, 8, 1, 2, raven_color1)
        @raven_bitmaps[2].set_pixel(6, 9, raven_color2)
        @raven_bitmaps[2].set_pixel(7, 9, raven_color1)
        @raven_bitmaps[2].set_pixel(3, 10, raven_color3)
        @raven_bitmaps[2].set_pixel(5, 10, raven_color3)
        @raven_bitmaps[2].set_pixel(6, 10, raven_color1)
        @raven_bitmaps[2].fill_rect(3, 11, 2, 1, raven_color1)
        @raven_bitmaps[2].set_pixel(6, 11, raven_color3)
        @raven_bitmaps[2].set_pixel(3, 12, raven_color3)

        # Raven left 4
        @raven_bitmaps[3] = Bitmap.new(14, 13)
        @raven_bitmaps[3].fill_rect(10, 0, 1, 2, raven_color1)
        @raven_bitmaps[3].fill_rect(7, 1, 2, 1, raven_color1)
        @raven_bitmaps[3].fill_rect(9, 1, 1, 3, raven_color2)
        @raven_bitmaps[3].set_pixel(11, 1, raven_color1)
        @raven_bitmaps[3].fill_rect(5, 2, 1, 2, raven_color1)
        @raven_bitmaps[3].fill_rect(6, 2, 3, 2, raven_color2)
        @raven_bitmaps[3].fill_rect(10, 2, 1, 2, raven_color2)
        @raven_bitmaps[3].set_pixel(11, 2, raven_color3)
        @raven_bitmaps[3].set_pixel(4, 3, raven_color3)
        @raven_bitmaps[3].set_pixel(5, 4, raven_color3)
        @raven_bitmaps[3].fill_rect(6, 4, 4, 1, raven_color1)
        @raven_bitmaps[3].set_pixel(10, 4, raven_color3)
        @raven_bitmaps[3].set_pixel(2, 5, raven_color2)
        @raven_bitmaps[3].set_pixel(3, 5, raven_color1)
        @raven_bitmaps[3].set_pixel(4, 5, raven_color3)
        @raven_bitmaps[3].fill_rect(5, 5, 3, 1, raven_color2)
        @raven_bitmaps[3].set_pixel(8, 5, raven_color1)
        @raven_bitmaps[3].set_pixel(9, 5, raven_color3)
        @raven_bitmaps[3].fill_rect(1, 6, 4, 1, raven_color4)
        @raven_bitmaps[3].set_pixel(5, 6, raven_color3)
        @raven_bitmaps[3].fill_rect(6, 6, 4, 1, raven_color2)
        @raven_bitmaps[3].set_pixel(10, 6, raven_color3)
        @raven_bitmaps[3].set_pixel(0, 7, raven_color6)
        @raven_bitmaps[3].set_pixel(1, 7, raven_color1)
        @raven_bitmaps[3].set_pixel(2, 7, raven_color2)
        @raven_bitmaps[3].fill_rect(3, 7, 2, 1, raven_color4)
        @raven_bitmaps[3].set_pixel(5, 7, raven_color1)
        @raven_bitmaps[3].fill_rect(6, 7, 1, 3, raven_color3)
        @raven_bitmaps[3].fill_rect(7, 7, 2, 1, raven_color2)
        @raven_bitmaps[3].set_pixel(9, 7, raven_color3)
        @raven_bitmaps[3].set_pixel(10, 7, raven_color1)
        @raven_bitmaps[3].set_pixel(11, 7, raven_color2)
        @raven_bitmaps[3].set_pixel(12, 7, raven_color3)
        @raven_bitmaps[3].set_pixel(3, 8, raven_color3)
        @raven_bitmaps[3].set_pixel(4, 8, raven_color1)
        @raven_bitmaps[3].fill_rect(5, 8, 1, 2, raven_color3)
        @raven_bitmaps[3].set_pixel(7, 8, raven_color2)
        @raven_bitmaps[3].set_pixel(8, 8, raven_color3)
        @raven_bitmaps[3].set_pixel(9, 8, raven_color2)
        @raven_bitmaps[3].fill_rect(10, 8, 1, 3, raven_color3)
        @raven_bitmaps[3].fill_rect(11, 8, 1, 2, raven_color1)
        @raven_bitmaps[3].fill_rect(12, 8, 1, 2, raven_color2)
        @raven_bitmaps[3].set_pixel(13, 8, raven_color3)
        @raven_bitmaps[3].set_pixel(7, 9, raven_color1)
        @raven_bitmaps[3].fill_rect(8, 9, 1, 3, raven_color2)
        @raven_bitmaps[3].fill_rect(9, 9, 1, 2, raven_color1)
        @raven_bitmaps[3].fill_rect(7, 10, 1, 2, raven_color3)
        @raven_bitmaps[3].set_pixel(9, 11, raven_color3)
        @raven_bitmaps[3].set_pixel(8, 12, raven_color3)

        # Raven up 1
        @raven_bitmaps[4] = Bitmap.new(20, 10)
        @raven_bitmaps[4].fill_rect(9, 0, 2, 1, raven_color3)
        @raven_bitmaps[4].fill_rect(9, 1, 2, 1, raven_color4)
        @raven_bitmaps[4].fill_rect(1, 2, 2, 1, raven_color3)
        @raven_bitmaps[4].set_pixel(3, 2, raven_color1)
        @raven_bitmaps[4].set_pixel(8, 2, raven_color3)
        @raven_bitmaps[4].fill_rect(9, 2, 2, 1, raven_color1)
        @raven_bitmaps[4].set_pixel(11, 2, raven_color3)
        @raven_bitmaps[4].set_pixel(16, 2, raven_color1)
        @raven_bitmaps[4].fill_rect(17, 2, 2, 1, raven_color3)
        @raven_bitmaps[4].fill_rect(0, 3, 1, 2, raven_color3)
        @raven_bitmaps[4].set_pixel(1, 3, raven_color1)
        @raven_bitmaps[4].fill_rect(2, 3, 3, 1, raven_color4)
        @raven_bitmaps[4].set_pixel(5, 3, raven_color1)
        @raven_bitmaps[4].fill_rect(6, 3, 2, 1, raven_color3)
        @raven_bitmaps[4].set_pixel(8, 3, raven_color1)
        @raven_bitmaps[4].fill_rect(9, 3, 2, 3, raven_color4)
        @raven_bitmaps[4].set_pixel(11, 3, raven_color1)
        @raven_bitmaps[4].fill_rect(12, 3, 2, 1, raven_color3)
        @raven_bitmaps[4].set_pixel(14, 3, raven_color1)
        @raven_bitmaps[4].fill_rect(15, 3, 3, 1, raven_color4)
        @raven_bitmaps[4].set_pixel(18, 3, raven_color1)
        @raven_bitmaps[4].fill_rect(19, 3, 1, 2, raven_color3)
        @raven_bitmaps[4].set_pixel(1, 4, raven_color2)
        @raven_bitmaps[4].set_pixel(2, 4, raven_color3)
        @raven_bitmaps[4].set_pixel(3, 4, raven_color4)
        @raven_bitmaps[4].set_pixel(4, 4, raven_color1)
        @raven_bitmaps[4].fill_rect(5, 4, 2, 1, raven_color4)
        @raven_bitmaps[4].fill_rect(7, 4, 2, 1, raven_color2)
        @raven_bitmaps[4].fill_rect(11, 4, 2, 1, raven_color2)
        @raven_bitmaps[4].fill_rect(13, 4, 2, 1, raven_color4)
        @raven_bitmaps[4].set_pixel(15, 4, raven_color1)
        @raven_bitmaps[4].set_pixel(16, 4, raven_color4)
        @raven_bitmaps[4].set_pixel(17, 4, raven_color3)
        @raven_bitmaps[4].set_pixel(18, 4, raven_color2)
        @raven_bitmaps[4].set_pixel(2, 5, raven_color2)
        @raven_bitmaps[4].set_pixel(3, 5, raven_color3)
        @raven_bitmaps[4].set_pixel(4, 5, raven_color4)
        @raven_bitmaps[4].fill_rect(5, 5, 2, 1, raven_color1)
        @raven_bitmaps[4].set_pixel(7, 5, raven_color2)
        @raven_bitmaps[4].set_pixel(8, 5, raven_color1)
        @raven_bitmaps[4].set_pixel(11, 5, raven_color1)
        @raven_bitmaps[4].set_pixel(12, 5, raven_color2)
        @raven_bitmaps[4].fill_rect(13, 5, 2, 1, raven_color1)
        @raven_bitmaps[4].set_pixel(15, 5, raven_color4)
        @raven_bitmaps[4].set_pixel(16, 5, raven_color3)
        @raven_bitmaps[4].set_pixel(17, 5, raven_color2)
        @raven_bitmaps[4].set_pixel(4, 6, raven_color3)
        @raven_bitmaps[4].set_pixel(5, 6, raven_color1)
        @raven_bitmaps[4].fill_rect(6, 6, 3, 1, raven_color3)
        @raven_bitmaps[4].fill_rect(9, 6, 2, 2, raven_color2)
        @raven_bitmaps[4].fill_rect(11, 6, 3, 1, raven_color3)
        @raven_bitmaps[4].set_pixel(14, 6, raven_color1)
        @raven_bitmaps[4].set_pixel(15, 6, raven_color3)
        @raven_bitmaps[4].set_pixel(8, 7, raven_color3)
        @raven_bitmaps[4].set_pixel(11, 7, raven_color3)
        @raven_bitmaps[4].set_pixel(8, 8, raven_color2)
        @raven_bitmaps[4].fill_rect(9, 8, 2, 1, raven_color4)
        @raven_bitmaps[4].set_pixel(11, 8, raven_color2)
        @raven_bitmaps[4].set_pixel(8, 9, raven_color3)
        @raven_bitmaps[4].fill_rect(9, 9, 2, 1, raven_color2)
        @raven_bitmaps[4].set_pixel(11, 9, raven_color3)

        # Raven up 2
        @raven_bitmaps[5] = Bitmap.new(16, 10)
        @raven_bitmaps[5].fill_rect(7, 0, 2, 3, raven_color2)
        @raven_bitmaps[5].fill_rect(6, 1, 1, 2, raven_color3)
        @raven_bitmaps[5].fill_rect(9, 1, 1, 2, raven_color3)
        @raven_bitmaps[5].set_pixel(5, 3, raven_color1)
        @raven_bitmaps[5].set_pixel(6, 3, raven_color2)
        @raven_bitmaps[5].fill_rect(7, 3, 2, 3, raven_color4)
        @raven_bitmaps[5].set_pixel(9, 3, raven_color2)
        @raven_bitmaps[5].set_pixel(10, 3, raven_color1)
        @raven_bitmaps[5].set_pixel(3, 4, raven_color3)
        @raven_bitmaps[5].set_pixel(4, 4, raven_color1)
        @raven_bitmaps[5].fill_rect(5, 4, 1, 2, raven_color2)
        @raven_bitmaps[5].set_pixel(6, 4, raven_color1)
        @raven_bitmaps[5].set_pixel(9, 4, raven_color1)
        @raven_bitmaps[5].fill_rect(10, 4, 1, 2, raven_color2)
        @raven_bitmaps[5].set_pixel(11, 4, raven_color1)
        @raven_bitmaps[5].set_pixel(12, 4, raven_color3)
        @raven_bitmaps[5].set_pixel(2, 5, raven_color3)
        @raven_bitmaps[5].fill_rect(3, 5, 2, 1, raven_color2)
        @raven_bitmaps[5].fill_rect(6, 5, 1, 2, raven_color3)
        @raven_bitmaps[5].fill_rect(9, 5, 1, 2, raven_color3)
        @raven_bitmaps[5].fill_rect(11, 5, 2, 1, raven_color2)
        @raven_bitmaps[5].set_pixel(13, 5, raven_color3)
        @raven_bitmaps[5].set_pixel(1, 6, raven_color3)
        @raven_bitmaps[5].fill_rect(2, 6, 1, 2, raven_color2)
        @raven_bitmaps[5].set_pixel(3, 6, raven_color1)
        @raven_bitmaps[5].set_pixel(4, 6, raven_color2)
        @raven_bitmaps[5].set_pixel(5, 6, raven_color1)
        @raven_bitmaps[5].fill_rect(7, 6, 2, 1, raven_color1)
        @raven_bitmaps[5].set_pixel(10, 6, raven_color1)
        @raven_bitmaps[5].set_pixel(11, 6, raven_color2)
        @raven_bitmaps[5].set_pixel(12, 6, raven_color1)
        @raven_bitmaps[5].fill_rect(13, 6, 1, 2, raven_color2)
        @raven_bitmaps[5].set_pixel(14, 6, raven_color3)
        @raven_bitmaps[5].fill_rect(0, 7, 1, 2, raven_color3)
        @raven_bitmaps[5].set_pixel(1, 7, raven_color2)
        @raven_bitmaps[5].set_pixel(3, 7, raven_color2)
        @raven_bitmaps[5].fill_rect(4, 7, 2, 1, raven_color3)
        @raven_bitmaps[5].fill_rect(6, 7, 1, 2, raven_color1)
        @raven_bitmaps[5].fill_rect(7, 7, 2, 2, raven_color2)
        @raven_bitmaps[5].fill_rect(9, 7, 1, 2, raven_color1)
        @raven_bitmaps[5].fill_rect(10, 7, 2, 2, raven_color3)
        @raven_bitmaps[5].set_pixel(12, 7, raven_color2)
        @raven_bitmaps[5].set_pixel(14, 7, raven_color2)
        @raven_bitmaps[5].fill_rect(15, 7, 1, 2, raven_color3)
        @raven_bitmaps[5].fill_rect(1, 8, 2, 1, raven_color3)
        @raven_bitmaps[5].set_pixel(3, 8, raven_color1)
        @raven_bitmaps[5].set_pixel(4, 8, raven_color3)
        @raven_bitmaps[5].set_pixel(12, 8, raven_color1)
        @raven_bitmaps[5].fill_rect(13, 8, 2, 1, raven_color3)
        @raven_bitmaps[5].set_pixel(2, 9, raven_color3)
        @raven_bitmaps[5].fill_rect(7, 9, 2, 1, raven_color3)
        @raven_bitmaps[5].set_pixel(13, 9, raven_color3)

        # Raven up 3
        @raven_bitmaps[6] = Bitmap.new(16, 9)
        @raven_bitmaps[6].fill_rect(7, 0, 2, 1, raven_color1)
        @raven_bitmaps[6].set_pixel(3, 1, raven_color3)
        @raven_bitmaps[6].fill_rect(7, 1, 2, 5, raven_color4)
        @raven_bitmaps[6].set_pixel(12, 1, raven_color3)
        @raven_bitmaps[6].fill_rect(2, 2, 1, 2, raven_color3)
        @raven_bitmaps[6].fill_rect(3, 2, 2, 3, raven_color2)
        @raven_bitmaps[6].fill_rect(5, 2, 2, 1, raven_color3)
        @raven_bitmaps[6].fill_rect(9, 2, 2, 1, raven_color3)
        @raven_bitmaps[6].fill_rect(11, 2, 2, 3, raven_color2)
        @raven_bitmaps[6].fill_rect(13, 2, 1, 2, raven_color3)
        @raven_bitmaps[6].set_pixel(5, 3, raven_color1)
        @raven_bitmaps[6].set_pixel(6, 3, raven_color2)
        @raven_bitmaps[6].set_pixel(9, 3, raven_color2)
        @raven_bitmaps[6].set_pixel(10, 3, raven_color1)
        @raven_bitmaps[6].set_pixel(2, 4, raven_color1)
        @raven_bitmaps[6].set_pixel(5, 4, raven_color3)
        @raven_bitmaps[6].set_pixel(6, 4, raven_color1)
        @raven_bitmaps[6].set_pixel(9, 4, raven_color1)
        @raven_bitmaps[6].set_pixel(10, 4, raven_color3)
        @raven_bitmaps[6].set_pixel(13, 4, raven_color1)
        @raven_bitmaps[6].fill_rect(1, 5, 2, 1, raven_color3)
        @raven_bitmaps[6].fill_rect(3, 5, 2, 1, raven_color1)
        @raven_bitmaps[6].fill_rect(6, 5, 1, 2, raven_color3)
        @raven_bitmaps[6].fill_rect(9, 5, 1, 2, raven_color3)
        @raven_bitmaps[6].fill_rect(11, 5, 2, 1, raven_color1)
        @raven_bitmaps[6].fill_rect(13, 5, 2, 1, raven_color3)
        @raven_bitmaps[6].fill_rect(0, 6, 1, 2, raven_color3)
        @raven_bitmaps[6].set_pixel(1, 6, raven_color1)
        @raven_bitmaps[6].fill_rect(2, 6, 2, 1, raven_color3)
        @raven_bitmaps[6].fill_rect(7, 6, 2, 1, raven_color2)
        @raven_bitmaps[6].fill_rect(12, 6, 2, 1, raven_color3)
        @raven_bitmaps[6].set_pixel(14, 6, raven_color1)
        @raven_bitmaps[6].fill_rect(15, 6, 1, 2, raven_color3)
        @raven_bitmaps[6].set_pixel(6, 7, raven_color2)
        @raven_bitmaps[6].fill_rect(7, 7, 2, 1, raven_color4)
        @raven_bitmaps[6].set_pixel(9, 7, raven_color2)
        @raven_bitmaps[6].set_pixel(6, 8, raven_color3)
        @raven_bitmaps[6].fill_rect(7, 8, 2, 1, raven_color2)
        @raven_bitmaps[6].set_pixel(9, 8, raven_color3)

        # Raven up 4
        @raven_bitmaps[7] = Bitmap.new(16, 14)
        @raven_bitmaps[7].set_pixel(0, 0, raven_color1)
        @raven_bitmaps[7].set_pixel(1, 0, raven_color3)
        @raven_bitmaps[7].set_pixel(0, 1, raven_color3)
        @raven_bitmaps[7].set_pixel(1, 1, raven_color2)
        @raven_bitmaps[7].set_pixel(2, 1, raven_color3)
        @raven_bitmaps[7].fill_rect(14, 1, 1, 2, raven_color2)
        @raven_bitmaps[7].set_pixel(15, 1, raven_color1)
        @raven_bitmaps[7].set_pixel(1, 2, raven_color3)
        @raven_bitmaps[7].set_pixel(2, 2, raven_color2)
        @raven_bitmaps[7].fill_rect(3, 2, 1, 2, raven_color1)
        @raven_bitmaps[7].set_pixel(4, 2, raven_color3)
        @raven_bitmaps[7].set_pixel(12, 2, raven_color3)
        @raven_bitmaps[7].fill_rect(13, 2, 1, 2, raven_color1)
        @raven_bitmaps[7].set_pixel(0, 3, raven_color3)
        @raven_bitmaps[7].set_pixel(1, 3, raven_color1)
        @raven_bitmaps[7].set_pixel(2, 3, raven_color3)
        @raven_bitmaps[7].fill_rect(4, 3, 1, 2, raven_color2)
        @raven_bitmaps[7].fill_rect(5, 3, 1, 2, raven_color3)
        @raven_bitmaps[7].set_pixel(11, 3, raven_color1)
        @raven_bitmaps[7].fill_rect(12, 3, 1, 2, raven_color2)
        @raven_bitmaps[7].fill_rect(14, 3, 2, 1, raven_color3)
        @raven_bitmaps[7].set_pixel(1, 4, raven_color3)
        @raven_bitmaps[7].fill_rect(2, 4, 2, 2, raven_color2)
        @raven_bitmaps[7].fill_rect(7, 4, 2, 1, raven_color3)
        @raven_bitmaps[7].set_pixel(10, 4, raven_color3)
        @raven_bitmaps[7].fill_rect(11, 4, 1, 2, raven_color2)
        @raven_bitmaps[7].fill_rect(13, 4, 2, 1, raven_color2)
        @raven_bitmaps[7].set_pixel(15, 4, raven_color3)
        @raven_bitmaps[7].set_pixel(1, 5, raven_color1)
        @raven_bitmaps[7].fill_rect(4, 5, 1, 3, raven_color1)
        @raven_bitmaps[7].fill_rect(6, 5, 1, 2, raven_color3)
        @raven_bitmaps[7].fill_rect(7, 5, 2, 2, raven_color2)
        @raven_bitmaps[7].fill_rect(9, 5, 1, 2, raven_color3)
        @raven_bitmaps[7].fill_rect(12, 5, 1, 4, raven_color1)
        @raven_bitmaps[7].fill_rect(13, 5, 2, 1, raven_color3)
        @raven_bitmaps[7].fill_rect(1, 6, 2, 1, raven_color3)
        @raven_bitmaps[7].fill_rect(3, 6, 1, 2, raven_color1)
        @raven_bitmaps[7].fill_rect(5, 6, 1, 3, raven_color1)
        @raven_bitmaps[7].set_pixel(10, 6, raven_color3)
        @raven_bitmaps[7].fill_rect(11, 6, 1, 3, raven_color1)
        @raven_bitmaps[7].set_pixel(13, 6, raven_color2)
        @raven_bitmaps[7].set_pixel(14, 6, raven_color1)
        @raven_bitmaps[7].set_pixel(2, 7, raven_color3)
        @raven_bitmaps[7].set_pixel(6, 7, raven_color2)
        @raven_bitmaps[7].fill_rect(7, 7, 2, 3, raven_color4)
        @raven_bitmaps[7].set_pixel(9, 7, raven_color2)
        @raven_bitmaps[7].fill_rect(10, 7, 1, 2, raven_color1)
        @raven_bitmaps[7].set_pixel(13, 7, raven_color1)
        @raven_bitmaps[7].set_pixel(14, 7, raven_color3)
        @raven_bitmaps[7].fill_rect(3, 8, 2, 1, raven_color3)
        @raven_bitmaps[7].set_pixel(6, 8, raven_color1)
        @raven_bitmaps[7].set_pixel(9, 8, raven_color1)
        @raven_bitmaps[7].fill_rect(6, 9, 1, 2, raven_color3)
        @raven_bitmaps[7].fill_rect(9, 9, 2, 1, raven_color3)
        @raven_bitmaps[7].fill_rect(7, 10, 2, 1, raven_color1)
        @raven_bitmaps[7].set_pixel(9, 10, raven_color3)
        @raven_bitmaps[7].fill_rect(6, 11, 1, 2, raven_color1)
        @raven_bitmaps[7].fill_rect(7, 11, 2, 2, raven_color2)
        @raven_bitmaps[7].fill_rect(9, 11, 1, 2, raven_color1)
        @raven_bitmaps[7].set_pixel(5, 12, raven_color3)
        @raven_bitmaps[7].set_pixel(10, 12, raven_color3)
        @raven_bitmaps[7].fill_rect(7, 13, 2, 1, raven_color3)

        # Raven right 1
        @raven_bitmaps[8] = Bitmap.new(15, 11)
        @raven_bitmaps[8].fill_rect(5, 0, 2, 1, raven_color1)
        @raven_bitmaps[8].fill_rect(4, 1, 2, 1, raven_color2)
        @raven_bitmaps[8].set_pixel(6, 1, raven_color1)
        @raven_bitmaps[8].fill_rect(7, 1, 1, 3, raven_color2)
        @raven_bitmaps[8].set_pixel(8, 1, raven_color1)
        @raven_bitmaps[8].set_pixel(4, 2, raven_color1)
        @raven_bitmaps[8].fill_rect(5, 2, 2, 1, raven_color2)
        @raven_bitmaps[8].set_pixel(8, 2, raven_color2)
        @raven_bitmaps[8].set_pixel(4, 3, raven_color3)
        @raven_bitmaps[8].set_pixel(5, 3, raven_color1)
        @raven_bitmaps[8].set_pixel(6, 3, raven_color2)
        @raven_bitmaps[8].set_pixel(8, 3, raven_color1)
        @raven_bitmaps[8].fill_rect(9, 3, 2, 1, raven_color2)
        @raven_bitmaps[8].fill_rect(11, 3, 1, 2, raven_color4)
        @raven_bitmaps[8].set_pixel(12, 3, raven_color2)
        @raven_bitmaps[8].fill_rect(1, 4, 2, 1, raven_color3)
        @raven_bitmaps[8].set_pixel(3, 4, raven_color1)
        @raven_bitmaps[8].fill_rect(4, 4, 4, 1, raven_color4)
        @raven_bitmaps[8].set_pixel(8, 4, raven_color2)
        @raven_bitmaps[8].fill_rect(9, 4, 2, 1, raven_color4)
        @raven_bitmaps[8].fill_rect(12, 4, 1, 2, raven_color3)
        @raven_bitmaps[8].set_pixel(13, 4, raven_color1)
        @raven_bitmaps[8].set_pixel(1, 5, raven_color1)
        @raven_bitmaps[8].set_pixel(2, 5, raven_color2)
        @raven_bitmaps[8].set_pixel(3, 5, raven_color3)
        @raven_bitmaps[8].fill_rect(4, 5, 3, 1, raven_color4)
        @raven_bitmaps[8].set_pixel(7, 5, raven_color2)
        @raven_bitmaps[8].set_pixel(8, 5, raven_color1)
        @raven_bitmaps[8].fill_rect(9, 5, 1, 3, raven_color2)
        @raven_bitmaps[8].set_pixel(10, 5, raven_color1)
        @raven_bitmaps[8].set_pixel(11, 5, raven_color3)
        @raven_bitmaps[8].set_pixel(13, 5, raven_color3)
        @raven_bitmaps[8].set_pixel(14, 5, raven_color5)
        @raven_bitmaps[8].set_pixel(0, 6, raven_color3)
        @raven_bitmaps[8].fill_rect(1, 6, 1, 2, raven_color2)
        @raven_bitmaps[8].fill_rect(2, 6, 2, 1, raven_color1)
        @raven_bitmaps[8].fill_rect(4, 6, 1, 3, raven_color3)
        @raven_bitmaps[8].fill_rect(5, 6, 3, 1, raven_color4)
        @raven_bitmaps[8].set_pixel(8, 6, raven_color2)
        @raven_bitmaps[8].set_pixel(10, 6, raven_color3)
        @raven_bitmaps[8].set_pixel(2, 7, raven_color1)
        @raven_bitmaps[8].fill_rect(3, 7, 1, 2, raven_color3)
        @raven_bitmaps[8].fill_rect(5, 7, 1, 2, raven_color1)
        @raven_bitmaps[8].fill_rect(6, 7, 3, 1, raven_color4)
        @raven_bitmaps[8].fill_rect(6, 8, 3, 1, raven_color2)
        @raven_bitmaps[8].set_pixel(5, 9, raven_color3)
        @raven_bitmaps[8].fill_rect(6, 9, 2, 1, raven_color1)
        @raven_bitmaps[8].set_pixel(6, 10, raven_color3)

        # Raven right 2
        @raven_bitmaps[9] = Bitmap.new(15, 12)
        @raven_bitmaps[9].fill_rect(6, 0, 2, 1, raven_color1)
        @raven_bitmaps[9].fill_rect(8, 0, 1, 3, raven_color2)
        @raven_bitmaps[9].set_pixel(9, 0, raven_color1)
        @raven_bitmaps[9].fill_rect(5, 1, 1, 2, raven_color1)
        @raven_bitmaps[9].fill_rect(6, 1, 2, 2, raven_color2)
        @raven_bitmaps[9].set_pixel(9, 1, raven_color3)
        @raven_bitmaps[9].set_pixel(10, 1, raven_color1)
        @raven_bitmaps[9].set_pixel(11, 1, raven_color2)
        @raven_bitmaps[9].set_pixel(9, 2, raven_color2)
        @raven_bitmaps[9].fill_rect(10, 2, 3, 1, raven_color4)
        @raven_bitmaps[9].set_pixel(13, 2, raven_color1)
        @raven_bitmaps[9].fill_rect(1, 3, 2, 1, raven_color3)
        @raven_bitmaps[9].set_pixel(3, 3, raven_color1)
        @raven_bitmaps[9].fill_rect(4, 3, 6, 1, raven_color4)
        @raven_bitmaps[9].set_pixel(10, 3, raven_color2)
        @raven_bitmaps[9].set_pixel(11, 3, raven_color4)
        @raven_bitmaps[9].set_pixel(12, 3, raven_color2)
        @raven_bitmaps[9].fill_rect(13, 3, 2, 1, raven_color5)
        @raven_bitmaps[9].set_pixel(0, 4, raven_color1)
        @raven_bitmaps[9].fill_rect(1, 4, 1, 2, raven_color4)
        @raven_bitmaps[9].fill_rect(2, 4, 3, 1, raven_color2)
        @raven_bitmaps[9].fill_rect(5, 4, 3, 1, raven_color4)
        @raven_bitmaps[9].fill_rect(8, 4, 2, 1, raven_color1)
        @raven_bitmaps[9].set_pixel(10, 4, raven_color3)
        @raven_bitmaps[9].fill_rect(0, 5, 1, 2, raven_color3)
        @raven_bitmaps[9].fill_rect(2, 5, 2, 1, raven_color1)
        @raven_bitmaps[9].set_pixel(4, 5, raven_color2)
        @raven_bitmaps[9].set_pixel(5, 5, raven_color3)
        @raven_bitmaps[9].fill_rect(6, 5, 1, 3, raven_color1)
        @raven_bitmaps[9].set_pixel(7, 5, raven_color4)
        @raven_bitmaps[9].set_pixel(8, 5, raven_color2)
        @raven_bitmaps[9].set_pixel(9, 5, raven_color3)
        @raven_bitmaps[9].set_pixel(1, 6, raven_color1)
        @raven_bitmaps[9].set_pixel(4, 6, raven_color3)
        @raven_bitmaps[9].set_pixel(5, 6, raven_color1)
        @raven_bitmaps[9].set_pixel(7, 6, raven_color2)
        @raven_bitmaps[9].fill_rect(8, 6, 2, 1, raven_color4)
        @raven_bitmaps[9].set_pixel(10, 6, raven_color3)
        @raven_bitmaps[9].set_pixel(3, 7, raven_color3)
        @raven_bitmaps[9].set_pixel(5, 7, raven_color3)
        @raven_bitmaps[9].fill_rect(7, 7, 2, 1, raven_color4)
        @raven_bitmaps[9].set_pixel(9, 7, raven_color2)
        @raven_bitmaps[9].fill_rect(6, 8, 2, 1, raven_color2)
        @raven_bitmaps[9].set_pixel(8, 8, raven_color4)
        @raven_bitmaps[9].set_pixel(9, 8, raven_color3)
        @raven_bitmaps[9].fill_rect(6, 9, 2, 1, raven_color1)
        @raven_bitmaps[9].set_pixel(8, 9, raven_color2)
        @raven_bitmaps[9].set_pixel(6, 10, raven_color3)
        @raven_bitmaps[9].set_pixel(7, 10, raven_color2)
        @raven_bitmaps[9].set_pixel(8, 10, raven_color3)
        @raven_bitmaps[9].set_pixel(7, 11, raven_color3)

        # Raven right 3
        @raven_bitmaps[10] = Bitmap.new(13, 13)
        @raven_bitmaps[10].fill_rect(5, 0, 6, 1, raven_color1)
        @raven_bitmaps[10].set_pixel(3, 1, raven_color3)
        @raven_bitmaps[10].fill_rect(4, 1, 3, 1, raven_color1)
        @raven_bitmaps[10].fill_rect(7, 1, 2, 1, raven_color2)
        @raven_bitmaps[10].fill_rect(9, 1, 3, 1, raven_color4)
        @raven_bitmaps[10].fill_rect(2, 2, 1, 2, raven_color2)
        @raven_bitmaps[10].fill_rect(3, 2, 6, 1, raven_color4)
        @raven_bitmaps[10].set_pixel(9, 2, raven_color1)
        @raven_bitmaps[10].set_pixel(10, 2, raven_color4)
        @raven_bitmaps[10].set_pixel(11, 2, raven_color1)
        @raven_bitmaps[10].set_pixel(12, 2, raven_color6)
        @raven_bitmaps[10].set_pixel(0, 3, raven_color3)
        @raven_bitmaps[10].set_pixel(1, 3, raven_color4)
        @raven_bitmaps[10].set_pixel(3, 3, raven_color2)
        @raven_bitmaps[10].fill_rect(4, 3, 3, 1, raven_color4)
        @raven_bitmaps[10].fill_rect(7, 3, 2, 1, raven_color1)
        @raven_bitmaps[10].set_pixel(9, 3, raven_color3)
        @raven_bitmaps[10].fill_rect(0, 4, 1, 2, raven_color2)
        @raven_bitmaps[10].fill_rect(1, 4, 3, 1, raven_color1)
        @raven_bitmaps[10].set_pixel(4, 4, raven_color3)
        @raven_bitmaps[10].fill_rect(5, 4, 1, 3, raven_color2)
        @raven_bitmaps[10].fill_rect(6, 4, 1, 5, raven_color4)
        @raven_bitmaps[10].set_pixel(7, 4, raven_color2)
        @raven_bitmaps[10].fill_rect(8, 4, 1, 2, raven_color3)
        @raven_bitmaps[10].set_pixel(1, 5, raven_color1)
        @raven_bitmaps[10].set_pixel(3, 5, raven_color3)
        @raven_bitmaps[10].set_pixel(4, 5, raven_color1)
        @raven_bitmaps[10].fill_rect(7, 5, 1, 4, raven_color4)
        @raven_bitmaps[10].set_pixel(0, 6, raven_color3)
        @raven_bitmaps[10].set_pixel(2, 6, raven_color3)
        @raven_bitmaps[10].fill_rect(4, 6, 1, 2, raven_color3)
        @raven_bitmaps[10].fill_rect(8, 6, 1, 3, raven_color4)
        @raven_bitmaps[10].set_pixel(9, 6, raven_color3)
        @raven_bitmaps[10].set_pixel(5, 7, raven_color1)
        @raven_bitmaps[10].set_pixel(9, 7, raven_color2)
        @raven_bitmaps[10].fill_rect(5, 8, 1, 2, raven_color3)
        @raven_bitmaps[10].fill_rect(9, 8, 1, 2, raven_color3)
        @raven_bitmaps[10].set_pixel(6, 9, raven_color1)
        @raven_bitmaps[10].fill_rect(7, 9, 2, 1, raven_color2)
        @raven_bitmaps[10].set_pixel(6, 10, raven_color3)
        @raven_bitmaps[10].set_pixel(7, 10, raven_color2)
        @raven_bitmaps[10].fill_rect(8, 10, 1, 2, raven_color3)
        @raven_bitmaps[10].set_pixel(9, 10, raven_color2)
        @raven_bitmaps[10].set_pixel(7, 11, raven_color3)
        @raven_bitmaps[10].fill_rect(9, 11, 1, 2, raven_color1)
        @raven_bitmaps[10].set_pixel(10, 11, raven_color3)

        # Raven right 4
        @raven_bitmaps[11] = Bitmap.new(14, 12)
        @raven_bitmaps[11].fill_rect(2, 0, 2, 1, raven_color1)
        @raven_bitmaps[11].fill_rect(2, 1, 1, 2, raven_color1)
        @raven_bitmaps[11].fill_rect(3, 1, 2, 3, raven_color2)
        @raven_bitmaps[11].set_pixel(5, 1, raven_color1)
        @raven_bitmaps[11].fill_rect(5, 2, 3, 2, raven_color2)
        @raven_bitmaps[11].fill_rect(8, 2, 1, 2, raven_color1)
        @raven_bitmaps[11].set_pixel(2, 3, raven_color3)
        @raven_bitmaps[11].set_pixel(3, 4, raven_color3)
        @raven_bitmaps[11].fill_rect(4, 4, 4, 1, raven_color1)
        @raven_bitmaps[11].set_pixel(8, 4, raven_color3)
        @raven_bitmaps[11].set_pixel(4, 5, raven_color3)
        @raven_bitmaps[11].fill_rect(5, 5, 4, 1, raven_color2)
        @raven_bitmaps[11].set_pixel(9, 5, raven_color1)
        @raven_bitmaps[11].set_pixel(10, 5, raven_color2)
        @raven_bitmaps[11].set_pixel(2, 6, raven_color3)
        @raven_bitmaps[11].set_pixel(3, 6, raven_color1)
        @raven_bitmaps[11].fill_rect(4, 6, 3, 2, raven_color2)
        @raven_bitmaps[11].fill_rect(7, 6, 1, 4, raven_color3)
        @raven_bitmaps[11].set_pixel(8, 6, raven_color1)
        @raven_bitmaps[11].fill_rect(9, 6, 3, 1, raven_color4)
        @raven_bitmaps[11].set_pixel(12, 6, raven_color1)
        @raven_bitmaps[11].set_pixel(0, 7, raven_color3)
        @raven_bitmaps[11].fill_rect(1, 7, 1, 2, raven_color1)
        @raven_bitmaps[11].fill_rect(2, 7, 1, 2, raven_color4)
        @raven_bitmaps[11].set_pixel(3, 7, raven_color2)
        @raven_bitmaps[11].set_pixel(8, 7, raven_color3)
        @raven_bitmaps[11].set_pixel(9, 7, raven_color4)
        @raven_bitmaps[11].set_pixel(10, 7, raven_color1)
        @raven_bitmaps[11].set_pixel(11, 7, raven_color2)
        @raven_bitmaps[11].set_pixel(12, 7, raven_color5)
        @raven_bitmaps[11].set_pixel(13, 7, raven_color1)
        @raven_bitmaps[11].set_pixel(0, 8, raven_color1)
        @raven_bitmaps[11].fill_rect(3, 8, 2, 1, raven_color1)
        @raven_bitmaps[11].fill_rect(5, 8, 1, 3, raven_color2)
        @raven_bitmaps[11].fill_rect(6, 8, 1, 2, raven_color3)
        @raven_bitmaps[11].fill_rect(8, 8, 2, 1, raven_color1)
        @raven_bitmaps[11].set_pixel(0, 9, raven_color3)
        @raven_bitmaps[11].set_pixel(1, 9, raven_color2)
        @raven_bitmaps[11].set_pixel(2, 9, raven_color3)
        @raven_bitmaps[11].set_pixel(3, 9, raven_color2)
        @raven_bitmaps[11].fill_rect(4, 9, 1, 2, raven_color3)
        @raven_bitmaps[11].set_pixel(8, 9, raven_color3)
        @raven_bitmaps[11].set_pixel(3, 10, raven_color1)
        @raven_bitmaps[11].fill_rect(4, 11, 2, 1, raven_color1)

        # Raven down 1
        @raven_bitmaps[12] = Bitmap.new(20, 10)
        @raven_bitmaps[12].set_pixel(7, 0, raven_color3)
        @raven_bitmaps[12].fill_rect(8, 0, 1, 2, raven_color1)
        @raven_bitmaps[12].fill_rect(9, 0, 2, 1, raven_color2)
        @raven_bitmaps[12].fill_rect(11, 0, 1, 2, raven_color1)
        @raven_bitmaps[12].set_pixel(12, 0, raven_color3)
        @raven_bitmaps[12].fill_rect(9, 1, 2, 1, raven_color4)
        @raven_bitmaps[12].fill_rect(6, 2, 1, 2, raven_color3)
        @raven_bitmaps[12].set_pixel(8, 2, raven_color3)
        @raven_bitmaps[12].fill_rect(9, 2, 2, 1, raven_color2)
        @raven_bitmaps[12].set_pixel(11, 2, raven_color3)
        @raven_bitmaps[12].fill_rect(13, 2, 1, 2, raven_color3)
        @raven_bitmaps[12].set_pixel(4, 3, raven_color1)
        @raven_bitmaps[12].set_pixel(5, 3, raven_color2)
        @raven_bitmaps[12].fill_rect(7, 3, 1, 2, raven_color2)
        @raven_bitmaps[12].fill_rect(8, 3, 1, 3, raven_color1)
        @raven_bitmaps[12].fill_rect(9, 3, 2, 2, raven_color4)
        @raven_bitmaps[12].fill_rect(11, 3, 1, 3, raven_color1)
        @raven_bitmaps[12].fill_rect(12, 3, 1, 2, raven_color2)
        @raven_bitmaps[12].set_pixel(14, 3, raven_color2)
        @raven_bitmaps[12].set_pixel(15, 3, raven_color1)
        @raven_bitmaps[12].set_pixel(2, 4, raven_color3)
        @raven_bitmaps[12].fill_rect(3, 4, 4, 2, raven_color4)
        @raven_bitmaps[12].fill_rect(13, 4, 4, 2, raven_color4)
        @raven_bitmaps[12].set_pixel(17, 4, raven_color3)
        @raven_bitmaps[12].set_pixel(1, 5, raven_color1)
        @raven_bitmaps[12].set_pixel(2, 5, raven_color2)
        @raven_bitmaps[12].set_pixel(7, 5, raven_color1)
        @raven_bitmaps[12].fill_rect(9, 5, 2, 1, raven_color2)
        @raven_bitmaps[12].set_pixel(12, 5, raven_color1)
        @raven_bitmaps[12].set_pixel(17, 5, raven_color2)
        @raven_bitmaps[12].set_pixel(18, 5, raven_color1)
        @raven_bitmaps[12].set_pixel(1, 6, raven_color3)
        @raven_bitmaps[12].set_pixel(2, 6, raven_color4)
        @raven_bitmaps[12].set_pixel(3, 6, raven_color2)
        @raven_bitmaps[12].set_pixel(4, 6, raven_color3)
        @raven_bitmaps[12].fill_rect(8, 6, 1, 2, raven_color3)
        @raven_bitmaps[12].fill_rect(9, 6, 2, 1, raven_color4)
        @raven_bitmaps[12].fill_rect(11, 6, 1, 2, raven_color3)
        @raven_bitmaps[12].set_pixel(15, 6, raven_color3)
        @raven_bitmaps[12].set_pixel(16, 6, raven_color2)
        @raven_bitmaps[12].set_pixel(17, 6, raven_color4)
        @raven_bitmaps[12].set_pixel(18, 6, raven_color3)
        @raven_bitmaps[12].set_pixel(0, 7, raven_color1)
        @raven_bitmaps[12].set_pixel(1, 7, raven_color2)
        @raven_bitmaps[12].set_pixel(2, 7, raven_color3)
        @raven_bitmaps[12].fill_rect(9, 7, 2, 1, raven_color1)
        @raven_bitmaps[12].set_pixel(17, 7, raven_color3)
        @raven_bitmaps[12].set_pixel(18, 7, raven_color2)
        @raven_bitmaps[12].set_pixel(19, 7, raven_color1)
        @raven_bitmaps[12].set_pixel(0, 8, raven_color3)
        @raven_bitmaps[12].fill_rect(9, 8, 2, 2, raven_color3)
        @raven_bitmaps[12].set_pixel(19, 8, raven_color3)

        # Raven down 2
        @raven_bitmaps[13] = Bitmap.new(14, 12)
        @raven_bitmaps[13].fill_rect(6, 0, 2, 1, raven_color2)
        @raven_bitmaps[13].set_pixel(5, 1, raven_color2)
        @raven_bitmaps[13].fill_rect(6, 1, 2, 1, raven_color4)
        @raven_bitmaps[13].set_pixel(8, 1, raven_color2)
        @raven_bitmaps[13].fill_rect(5, 2, 1, 2, raven_color3)
        @raven_bitmaps[13].fill_rect(6, 2, 2, 1, raven_color2)
        @raven_bitmaps[13].fill_rect(8, 2, 1, 2, raven_color3)
        @raven_bitmaps[13].fill_rect(6, 3, 2, 1, raven_color4)
        @raven_bitmaps[13].set_pixel(3, 4, raven_color3)
        @raven_bitmaps[13].fill_rect(4, 4, 1, 2, raven_color2)
        @raven_bitmaps[13].fill_rect(5, 4, 4, 1, raven_color1)
        @raven_bitmaps[13].fill_rect(9, 4, 1, 2, raven_color2)
        @raven_bitmaps[13].set_pixel(10, 4, raven_color3)
        @raven_bitmaps[13].set_pixel(2, 5, raven_color3)
        @raven_bitmaps[13].fill_rect(3, 5, 1, 2, raven_color2)
        @raven_bitmaps[13].fill_rect(5, 5, 1, 2, raven_color3)
        @raven_bitmaps[13].fill_rect(6, 5, 2, 1, raven_color4)
        @raven_bitmaps[13].fill_rect(8, 5, 1, 2, raven_color3)
        @raven_bitmaps[13].fill_rect(10, 5, 1, 2, raven_color2)
        @raven_bitmaps[13].set_pixel(11, 5, raven_color3)
        @raven_bitmaps[13].set_pixel(2, 6, raven_color1)
        @raven_bitmaps[13].set_pixel(4, 6, raven_color1)
        @raven_bitmaps[13].fill_rect(6, 6, 2, 1, raven_color1)
        @raven_bitmaps[13].set_pixel(9, 6, raven_color1)
        @raven_bitmaps[13].set_pixel(11, 6, raven_color1)
        @raven_bitmaps[13].fill_rect(1, 7, 1, 2, raven_color3)
        @raven_bitmaps[13].fill_rect(2, 7, 1, 2, raven_color2)
        @raven_bitmaps[13].set_pixel(3, 7, raven_color1)
        @raven_bitmaps[13].set_pixel(4, 7, raven_color3)
        @raven_bitmaps[13].fill_rect(6, 7, 2, 1, raven_color7)
        @raven_bitmaps[13].set_pixel(9, 7, raven_color3)
        @raven_bitmaps[13].set_pixel(10, 7, raven_color1)
        @raven_bitmaps[13].fill_rect(11, 7, 1, 2, raven_color2)
        @raven_bitmaps[13].fill_rect(12, 7, 1, 2, raven_color3)
        @raven_bitmaps[13].fill_rect(3, 8, 1, 2, raven_color3)
        @raven_bitmaps[13].fill_rect(6, 8, 2, 1, raven_color3)
        @raven_bitmaps[13].fill_rect(10, 8, 1, 2, raven_color3)
        @raven_bitmaps[13].fill_rect(1, 9, 2, 1, raven_color1)
        @raven_bitmaps[13].fill_rect(11, 9, 2, 1, raven_color1)
        @raven_bitmaps[13].fill_rect(0, 10, 2, 1, raven_color1)
        @raven_bitmaps[13].set_pixel(2, 10, raven_color3)
        @raven_bitmaps[13].set_pixel(11, 10, raven_color3)
        @raven_bitmaps[13].fill_rect(12, 10, 2, 1, raven_color1)
        @raven_bitmaps[13].set_pixel(0, 11, raven_color3)
        @raven_bitmaps[13].set_pixel(13, 11, raven_color3)

        # Raven down 3
        @raven_bitmaps[14] = Bitmap.new(16, 10)
        @raven_bitmaps[14].fill_rect(6, 0, 1, 2, raven_color1)
        @raven_bitmaps[14].fill_rect(7, 0, 2, 1, raven_color2)
        @raven_bitmaps[14].fill_rect(9, 0, 1, 2, raven_color1)
        @raven_bitmaps[14].fill_rect(7, 1, 2, 1, raven_color4)
        @raven_bitmaps[14].fill_rect(3, 2, 2, 1, raven_color3)
        @raven_bitmaps[14].fill_rect(6, 2, 1, 2, raven_color3)
        @raven_bitmaps[14].set_pixel(7, 2, raven_color2)
        @raven_bitmaps[14].set_pixel(8, 2, raven_color1)
        @raven_bitmaps[14].fill_rect(9, 2, 1, 2, raven_color3)
        @raven_bitmaps[14].set_pixel(1, 3, raven_color3)
        @raven_bitmaps[14].fill_rect(2, 3, 4, 2, raven_color2)
        @raven_bitmaps[14].fill_rect(7, 3, 2, 1, raven_color4)
        @raven_bitmaps[14].fill_rect(10, 3, 2, 2, raven_color2)
        @raven_bitmaps[14].set_pixel(12, 3, raven_color1)
        @raven_bitmaps[14].fill_rect(13, 3, 1, 2, raven_color3)
        @raven_bitmaps[14].set_pixel(1, 4, raven_color1)
        @raven_bitmaps[14].set_pixel(6, 4, raven_color1)
        @raven_bitmaps[14].fill_rect(7, 4, 3, 1, raven_color2)
        @raven_bitmaps[14].fill_rect(12, 4, 1, 2, raven_color2)
        @raven_bitmaps[14].fill_rect(0, 5, 2, 1, raven_color3)
        @raven_bitmaps[14].set_pixel(2, 5, raven_color2)
        @raven_bitmaps[14].set_pixel(3, 5, raven_color1)
        @raven_bitmaps[14].fill_rect(4, 5, 3, 1, raven_color3)
        @raven_bitmaps[14].fill_rect(7, 5, 2, 2, raven_color4)
        @raven_bitmaps[14].fill_rect(9, 5, 2, 1, raven_color3)
        @raven_bitmaps[14].set_pixel(11, 5, raven_color1)
        @raven_bitmaps[14].fill_rect(13, 5, 2, 1, raven_color1)
        @raven_bitmaps[14].set_pixel(1, 6, raven_color2)
        @raven_bitmaps[14].set_pixel(2, 6, raven_color1)
        @raven_bitmaps[14].set_pixel(6, 6, raven_color3)
        @raven_bitmaps[14].set_pixel(9, 6, raven_color3)
        @raven_bitmaps[14].set_pixel(12, 6, raven_color1)
        @raven_bitmaps[14].set_pixel(13, 6, raven_color2)
        @raven_bitmaps[14].set_pixel(14, 6, raven_color3)
        @raven_bitmaps[14].set_pixel(0, 7, raven_color3)
        @raven_bitmaps[14].set_pixel(1, 7, raven_color1)
        @raven_bitmaps[14].fill_rect(7, 7, 2, 1, raven_color5)
        @raven_bitmaps[14].fill_rect(13, 7, 2, 1, raven_color1)
        @raven_bitmaps[14].set_pixel(0, 8, raven_color1)
        @raven_bitmaps[14].fill_rect(7, 8, 2, 1, raven_color1)
        @raven_bitmaps[14].set_pixel(14, 8, raven_color1)
        @raven_bitmaps[14].fill_rect(15, 8, 1, 2, raven_color3)

        # Raven down 4
        @raven_bitmaps[15] = Bitmap.new(18, 10)
        @raven_bitmaps[15].set_pixel(3, 0, raven_color3)
        @raven_bitmaps[15].fill_rect(8, 0, 2, 1, raven_color2)
        @raven_bitmaps[15].set_pixel(14, 0, raven_color3)
        @raven_bitmaps[15].set_pixel(0, 1, raven_color1)
        @raven_bitmaps[15].set_pixel(1, 1, raven_color2)
        @raven_bitmaps[15].fill_rect(2, 1, 3, 1, raven_color1)
        @raven_bitmaps[15].fill_rect(5, 1, 2, 1, raven_color3)
        @raven_bitmaps[15].set_pixel(7, 1, raven_color2)
        @raven_bitmaps[15].fill_rect(8, 1, 2, 1, raven_color4)
        @raven_bitmaps[15].set_pixel(10, 1, raven_color2)
        @raven_bitmaps[15].fill_rect(11, 1, 2, 1, raven_color3)
        @raven_bitmaps[15].fill_rect(13, 1, 3, 1, raven_color1)
        @raven_bitmaps[15].set_pixel(16, 1, raven_color2)
        @raven_bitmaps[15].set_pixel(17, 1, raven_color1)
        @raven_bitmaps[15].set_pixel(1, 2, raven_color3)
        @raven_bitmaps[15].set_pixel(2, 2, raven_color4)
        @raven_bitmaps[15].set_pixel(3, 2, raven_color2)
        @raven_bitmaps[15].fill_rect(4, 2, 1, 3, raven_color4)
        @raven_bitmaps[15].set_pixel(5, 2, raven_color1)
        @raven_bitmaps[15].fill_rect(6, 2, 2, 1, raven_color3)
        @raven_bitmaps[15].fill_rect(8, 2, 2, 1, raven_color2)
        @raven_bitmaps[15].fill_rect(10, 2, 2, 1, raven_color3)
        @raven_bitmaps[15].set_pixel(12, 2, raven_color1)
        @raven_bitmaps[15].fill_rect(13, 2, 1, 3, raven_color4)
        @raven_bitmaps[15].set_pixel(14, 2, raven_color2)
        @raven_bitmaps[15].set_pixel(15, 2, raven_color4)
        @raven_bitmaps[15].set_pixel(16, 2, raven_color3)
        @raven_bitmaps[15].set_pixel(2, 3, raven_color3)
        @raven_bitmaps[15].fill_rect(3, 3, 1, 2, raven_color4)
        @raven_bitmaps[15].fill_rect(5, 3, 1, 2, raven_color2)
        @raven_bitmaps[15].fill_rect(6, 3, 1, 2, raven_color4)
        @raven_bitmaps[15].set_pixel(7, 3, raven_color3)
        @raven_bitmaps[15].fill_rect(8, 3, 2, 2, raven_color4)
        @raven_bitmaps[15].set_pixel(10, 3, raven_color3)
        @raven_bitmaps[15].fill_rect(11, 3, 1, 2, raven_color4)
        @raven_bitmaps[15].fill_rect(12, 3, 1, 2, raven_color2)
        @raven_bitmaps[15].fill_rect(14, 3, 1, 2, raven_color4)
        @raven_bitmaps[15].set_pixel(15, 3, raven_color3)
        @raven_bitmaps[15].set_pixel(7, 4, raven_color1)
        @raven_bitmaps[15].set_pixel(10, 4, raven_color1)
        @raven_bitmaps[15].fill_rect(3, 5, 3, 1, raven_color3)
        @raven_bitmaps[15].set_pixel(6, 5, raven_color1)
        @raven_bitmaps[15].fill_rect(7, 5, 4, 1, raven_color2)
        @raven_bitmaps[15].set_pixel(11, 5, raven_color1)
        @raven_bitmaps[15].fill_rect(12, 5, 3, 1, raven_color3)
        @raven_bitmaps[15].fill_rect(7, 6, 1, 2, raven_color3)
        @raven_bitmaps[15].fill_rect(8, 6, 2, 2, raven_color4)
        @raven_bitmaps[15].fill_rect(10, 6, 1, 2, raven_color3)
        @raven_bitmaps[15].fill_rect(8, 8, 2, 1, raven_color7)
        @raven_bitmaps[15].fill_rect(8, 9, 2, 1, raven_color3)
      end
      #-------------------------------------------------------------------------------
      # Sandstorm
      if weather == :Sandstorm
        @sand_bitmaps = []

        sandstormColors = [
          Color.new(31 * 8, 28 * 8, 17 * 8, 30),
          Color.new(23 * 8, 16 * 8, 9 * 8, 60),
          Color.new(29 * 8, 24 * 8, 15 * 8, 80),
          Color.new(26 * 8, 20 * 8, 12 * 8, 110),
          Color.new(20 * 8, 13 * 8, 6 * 8, 95),
          Color.new(31 * 8, 30 * 8, 20 * 8, 125),
          Color.new(27 * 8, 25 * 8, 20 * 8, 45)
        ]
        bmwidth = 200
        bmheight = 200

        @sand_bitmaps[0] = Bitmap.new(bmwidth, bmheight)
        @sand_bitmaps[1] = Bitmap.new(bmwidth, bmheight)

        for i in 0..540
          @sand_bitmaps[0].fill_rect(rand(bmwidth / 2) * 2, rand(bmheight / 2) * 2, 2, 2, sandstormColors[rand(7)])
          @sand_bitmaps[1].fill_rect(rand(bmwidth / 2) * 2, rand(bmheight / 2) * 2, 2, 2, sandstormColors[rand(7)])
        end
      end
      #-------------------------------------------------------------------------------
      # Sunlight
      # if weather == :Sunny
      #   @sun_bitmap = []
      #   tempx = 5
      #   while tempx < 255
      #     bitmap = Bitmap.new(Graphics.width, Graphics.height)
      #     bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(255, 255, 255, tempx))
      #     tempx += 10
      #     @sun_bitmap.push(bitmap)
      #   end
      # end
      #-------------------------------------------------------------------------------
      # Winds
      if weather == :Winds
        @wind_bitmap = Bitmap.new(192, 192)
        colorWind = Color.new(200, 200, 200, 50)
        for i in 0...192
          @wind_bitmap.fill_rect(190 - i * 2, (192 - i) / 10, 2, 6, colorWind)
        end
      end
      #-------------------------------------------------------------------------------
      legacyColors = [
        Color.new(135, 207, 255, 204),
        Color.new(161, 222, 255, 204),
        Color.new(201, 239, 255, 204),
        Color.new(255, 255, 255, 204),
      ]
      # old Rain from reborn
      if weather == :RainLegacy
        @rain_legacy_bitmaps = []

        # Bitmap 0
        @rain_legacy_bitmaps[0] = Bitmap.new(32, 128)
        for i in 0...16
          case i
            when 0..3   then color = legacyColors[0]
            when 4..6   then color = legacyColors[1]
            when 7..11  then color = legacyColors[2]
            when 12..15 then color = legacyColors[3]
          end
          @rain_legacy_bitmaps[0].fill_rect(30 - i * 2, i * 8, 2, 8, color)
        end

        # Bitmap 1
        @rain_legacy_bitmaps[1] = Bitmap.new(32, 128)
        for i in 0...12
          case i
            when 0..2   then color = legacyColors[0]
            when 3..6   then color = legacyColors[1]
            when 7..9   then color = legacyColors[2]
            when 10..11 then color = legacyColors[3]
          end
          @rain_legacy_bitmaps[1].fill_rect(22 - i * 2, 32 + i * 8, 2, 8, color)
        end
        @rain_legacy_bitmaps[1].fill_rect(2, 108, 2, 2, legacyColors[2])
        @rain_legacy_bitmaps[1].fill_rect(14, 118, 2, 2, legacyColors[2])

        # Bitmap 2
        @rain_legacy_bitmaps[2] = Bitmap.new(32, 128)
        for i in 0...3
          case i
            when 0..1 then color = legacyColors[1]
            when 2    then color = legacyColors[2]
          end
          @rain_legacy_bitmaps[2].fill_rect(6 - i * 2, 104 + i * 8, 2, 8, color)
        end
        @rain_legacy_bitmaps[2].fill_rect(0, 112, 2, 2, legacyColors[1])
        @rain_legacy_bitmaps[2].fill_rect(14, 118, 2, 2, legacyColors[3])

        # Bitmap 3
        @rain_legacy_bitmaps[3] = Bitmap.new(32, 128)
        @rain_legacy_bitmaps[3].fill_rect(2, 120, 2, 2, legacyColors[1])
        @rain_legacy_bitmaps[3].fill_rect(4, 112, 2, 2, legacyColors[1])
        @rain_legacy_bitmaps[3].fill_rect(12, 120, 2, 2, legacyColors[2])
      end
      #-------------------------------------------------------------------------------
      # old Storm from reborn
      if weather == :StormLegacy
        @storm_legacy_bitmaps = []

        # Bitmap 0
        @storm_legacy_bitmaps[0] = Bitmap.new(192, 192)
        for i in 0...96
          case i
            when 0..23  then color = legacyColors[0]
            when 24..41 then color = legacyColors[1]
            when 42..71 then color = legacyColors[2]
            when 72..95 then color = legacyColors[3]
          end
          @storm_legacy_bitmaps[0].fill_rect(190 - i * 2, i * 2, 2, 2, color)
        end

        # Bitmap 1
        @storm_legacy_bitmaps[1] = Bitmap.new(192, 192)
        for i in 0...72
          case i
            when 0..17  then color = legacyColors[0]
            when 18..41 then color = legacyColors[1]
            when 42..59 then color = legacyColors[2]
            when 60..71 then color = legacyColors[3]
          end
          @storm_legacy_bitmaps[1].fill_rect(142 - i * 2, 48 + i * 2, 2, 2, color)
        end
        @storm_legacy_bitmaps[1].fill_rect(2, 172, 2, 2, legacyColors[2])
        @storm_legacy_bitmaps[1].fill_rect(14, 182, 2, 2, legacyColors[2])

        # Bitmap 2
        @storm_legacy_bitmaps[2] = Bitmap.new(192, 192)
        for i in 0...12
          case i
            when 0..7  then color = legacyColors[1]
            when 8..11 then color = legacyColors[2]
          end
          @storm_legacy_bitmaps[2].fill_rect(24 - i * 2, 156 + i * 2, 2, 2, color)
        end
        @storm_legacy_bitmaps[2].fill_rect(0, 176, 2, 2, legacyColors[1])
        @storm_legacy_bitmaps[2].fill_rect(14, 182, 2, 2, legacyColors[3])

        # Bitmap 3
        @storm_legacy_bitmaps[3] = Bitmap.new(192, 192)
        @storm_legacy_bitmaps[3].fill_rect(2, 184, 2, 2, legacyColors[1])
        @storm_legacy_bitmaps[3].fill_rect(4, 176, 2, 2, legacyColors[1])
        @storm_legacy_bitmaps[3].fill_rect(12, 184, 2, 2, legacyColors[2])

      end

      #-------------------------------------------------------------------------------
      if weather == :UserDefined
        @user_bitmaps = []
        update_user_defined
      end
    end

    #-------------------------------------------------------------------------------
    def update_user_defined
      @user_bitmaps.each { |image| image.dispose }
      $WEATHER_IMAGES.each { |name| @user_bitmaps.push(RPG::Cache.picture(name)) }
      @sprites.each { |sprite| sprite.bitmap = @user_bitmaps[rand(@user_bitmaps.size)] }
    end
    attr_reader :type
    attr_reader :max
    attr_reader :ox
    attr_reader :oy
  end
end

#-------------------------------------------------------------------------------
# Game_Screen
#-------------------------------------------------------------------------------
class Game_Screen
  attr_accessor :weather_variation
  attr_accessor :variation_update
  attr_accessor :double_size
  attr_reader :power

  unless @weatherAliases
    alias zer0_weather_color_init initialize
    @weatherAliases = true
  end

  def initialize
    zer0_weather_color_init
    @weather_variation = 0
    @variation_update = false
    @double_size = false
  end

  def weather(type, power, duration, variation = 0)
    if !type.is_a?(Symbol)
      case type
        when 1 then type = :Rain
        when 2 then type = :Storm
        when 3 then type = :Snow
        when 4 then type = :Hail
        when 5 then type = :Thunder
        when 6 then type = :FallingLeaves
        when 7 then type = :BlowingLeaves
        when 8 then type = :SwirlingLeaves
        when 9 then type = :RealThunder
        when 10 then type = :SakuraPetals
        when 11 then type = :FlowerPetals
        when 12 then type = :Feathers
        when 13 then type = :Butterflies
        when 14 then type = :Sparkles
        when 15 then type = :UserDefined
        when 16 then type = :Blizzard
        when 17 then type = :Meteors
        when 18 then type = :FallingAsh
        when 19 then type = :Bubbles
        when 20 then type = :Bubbles2
        when 21 then type = :SparklesUp
        when 22 then type = :FallingRocks
        when 23 then type = :Arrows
        when 24 then type = :Starburst
        when 25 then type = :StarburstUp
        when 26 then type = :StarburstRain
        when 27 then type = :MonoBurst
        when 28 then type = :MonoUp
        when 29 then type = :MonoRain
        when 30 then type = :Bombs
        when 31 then type = :Birds
        when 32 then type = :Bats
        when 33 then type = :Bees
        when 34 then type = :Fish
        when 35 then type = :Raven
        when 36 then type = :Sunny
        when 37 then type = :Sandstorm
        when 38 then type = :Winds
        when 39 then type = :RainLegacy
        when 40 then type = :StormLegacy
        when 41 then type = :SnowAlt
        when 42 then type = :BlizzardAlt
        else type = :Clear
      end
    end

    double_size = false
    if Reborn
      # Useful if someone uses RMXP's Set Weather command.
      # iirc Laura's E4 room relies on this
      type = :RainLegacy if type == :Rain
      type = :StormLegacy if type == :Storm
      type = :SnowAlt if type == :Snow
      type = :BlizzardAlt if type == :Blizzard
      # Some advanced weather effects need to be double-sized in Reborn.
      double_size = true if [:FallingAsh, :SnowAlt, :BlizzardAlt].include?(type)
    end

    @variation_update = true if variation != @weather_variation
    @weather_variation = variation
    @double_size = double_size
    @weather_type_target = type
    @weather_duration = duration
    if @weather_type_target != 0
      @weather_type = @weather_type_target
    end
    @power = power
    @weather_max_target = @weather_type_target == 0 ? 0.0 : (power + 1) * 4.0
    if @weather_duration == 0
      @weather_type = @weather_type_target
      @weather_max = @weather_max_target
    end
  end

  def isRaining?(type = @weather_type)
    return [:Rain, :Storm, :Thunder, :RealThunder, :RainLegacy, :StormLegacy].include?(type)
  end

  def isThunderstorm?(type = @weather_type)
    return [:Storm, :Thunder, :RealThunder, :StormLegacy].include?(type)
  end

  def isHailing?(type = @weather_type)
    return [:Snow, :Hail, :Blizzard, :SnowAlt, :BlizzardAlt].include?(type)
  end

  def isBlizzard?(type = @weather_type)
    return [:Blizzard, :BlizzardAlt].include?(type)
  end

  def isSandstorm?(type = @weather_type)
    return [:Sandstorm].include?(type)
  end

  def isSunny?(type = @weather_type)
    return [:Sunny].include?(type)
  end

  def isWindy?(type = @weather_type)
    return [:BlowingLeaves, :SwirlingLeaves, :Winds].include?(type)
  end

  def isClear?(type = @weather_type)
    return !isRaining?(type) && !isHailing?(type) && !isSandstorm?(type) && !isSunny?(type) && !isWindy?(type)
  end

  # Matches filenames in Graphics/Pictures/Pokegear/TimeWeather
  def weatherLabel(type = @weather_type)
    return "Blizzard" if isBlizzard?(type)
    # return "HeavyRain" # unused
    return "Windy" if isWindy?(type)
    return "Sunny" if isSunny?(type)
    return "Sandstorm" if isSandstorm?(type)
    return "Snow" if isHailing?(type)
    return "Storm" if isThunderstorm?(type)
    return "Rain" if isRaining?(type)
    return "Clear"
  end

  # The integer returned here need to match the old values used for various weathers in previous versions.
  def currentWeatherVariableValue(type = @weather_type)
    # 8 used to be :Blizzard
    # 7 used to be :HeavyRain
    # I don't think they were really used over :Snow and :Storm.
    return 6 if isWindy?(type)
    return 5 if isSunny?(type)
    return 4 if isSandstorm?(type)
    return 3 if isHailing?(type)
    return 2 if isThunderstorm?(type)
    return 1 if isRaining?(type)
    return 0
  end
end

#-------------------------------------------------------------------------------
# Spriteset_Map
#-------------------------------------------------------------------------------
class Spriteset_Map
  unless @advancedWeatherAliases
    alias :zer0_weather_variation_upd :update
    @advancedWeatherAliases = true
  end

  # This will re-cache the weather bitmaps when a new variation is chosen
  def update
    if $game_screen.variation_update
      @weather.dispose if @weather != nil
      @weather = RPG::Weather.new(@viewport1)
      $game_screen.variation_update = false
    end
    zer0_weather_variation_upd
  end
end

def pbPrepareBattle(battle)
  weather = nil
  case true
    when $game_screen.isRaining? then weather = :RAINDANCE
    when $game_screen.isHailing?
      # Frozen Dimension changes Snow to Hail.
      # Gen 7 Reborn uses Hail everywhere.
      weather = battle.FE == :FROZENDIMENSION || Gen < 9 ? :HAIL : :SNOW
    when $game_screen.isSandstorm? then weather = :SANDSTORM
    when $game_screen.isSunny? then weather = :SUNNYDAY
    when $game_screen.isWindy? then weather = :STRONGWINDS
  end
  if weather
    battle.weather = weather
    battle.weatherbackup = weather
    battle.weatherduration = -1
  end
  battle.shiftStyle = $Settings.battlestyle == 0
  battle.battlescene = $Settings.battlescene == 0
  battle.environment = pbGetEnvironment
end

#===============================================================================
# ** Game_Screen
#-------------------------------------------------------------------------------
#  This class handles screen maintenance data, such as change in color tone,
#  flashing, etc. Refer to "$game_screen" for the instance of this class.
#===============================================================================

class Game_Screen
  #-----------------------------------------------------------------------------
  # * Public Instance Variables
  #-----------------------------------------------------------------------------
  attr_reader     :brightness               # brightness
  attr_reader     :tone                     # color tone
  attr_reader     :flash_color              # flash color
  attr_reader     :shakeX                   # shakeX positioning
  attr_reader     :shakeY                   # shakeX positioning
  attr_reader     :pictures                 # pictures
  attr_reader     :weather_type             # weather type
  attr_reader     :weather_max              # max number of weather sprites
  attr_reader     :tone_duration
  attr_accessor   :regionalWeather

  #-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    @brightness = 255
    @fadeout_duration = 0
    @fadein_duration = 0
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = @tone
    @tone_duration = 0
    @flash_color = Color.new(0, 0, 0, 0)
    @flash_duration = 0
    @shakeX_power = 0
    @shakeX_speed = 0
    @shakeX_duration = 0
    @shakeX_direction = 1
    @shakeX = 0
    @shakeY_power = 0
    @shakeY_speed = 0
    @shakeY_duration = 0
    @shakeY_direction = 1
    @shakeY = 0
    @pictures = [nil]
    for i in 1..100
      @pictures.push(Game_Picture.new(i))
    end
    @weather_type = :Clear
    @weather_max = 0.0
    @weather_type_target = :Clear
    @weather_max_target = 0.0
    @weather_duration = 0
    @regionalWeather = RegionalWeather.new if Reborn
  end

  #-----------------------------------------------------------------------------
  # * Start Changing Color Tone
  #     tone : color tone
  #     duration : time
  #-----------------------------------------------------------------------------
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end

  #-----------------------------------------------------------------------------
  # * Start Flashing
  #     color : color
  #     duration : time
  #-----------------------------------------------------------------------------
  def start_flash(color, duration)
    return if $Settings.photosensitive == 1

    @flash_color = color.clone
    @flash_duration = duration
  end

  #-----------------------------------------------------------------------------
  # * Start Shaking
  #     power : strength
  #     speed : speed
  #     duration : time
  #-----------------------------------------------------------------------------
  def start_shake(power, speed, duration, axis = :x)
    if axis == :x
      start_shakeX(power, speed, duration)
    else
      start_shakeY(power, speed, duration)
    end
  end

  def start_shakeX(power, speed, duration)
    return if $Settings.photosensitive == 1

    @shakeX_power = power
    @shakeX_speed = speed
    @shakeX_duration = duration
  end

  def start_shakeY(power, speed, duration)
    return if $Settings.photosensitive == 1

    @shakeY_power = power
    @shakeY_speed = speed
    @shakeY_duration = duration
  end

  def isShaking?
    return @shakeX_duration != 0 || @shakeY_duration != 0
  end

  def initAddedVars
    @shakeX_power = 0
    @shakeX_speed = 0
    @shakeX_duration = 0
    @shakeX_direction = 1
    @shakeX = 0
    @shakeY_power = 0
    @shakeY_speed = 0
    @shakeY_duration = 0
    @shakeY_direction = 1
    @shakeY = 0
  end

  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    if @fadeout_duration && @fadeout_duration >= 1
      d = @fadeout_duration
      @brightness = (@brightness * (d - 1)) / d
      @fadeout_duration -= 1
    end
    if @fadein_duration && @fadein_duration >= 1
      d = @fadein_duration
      @brightness = (@brightness * (d - 1) + 255) / d
      @fadein_duration -= 1
    end
    if @tone_duration >= 1
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
    if @flash_duration >= 1
      d = @flash_duration
      @flash_color.alpha = @flash_color.alpha * (d - 1) / d
      @flash_duration -= 1
    end
    if @shakeX_duration >= 1 || @shakeX != 0
      delta = (@shakeX_power * @shakeX_speed * @shakeX_direction) / 10.0
      if @shakeX_duration <= 1 && @shakeX * (@shakeX + delta) < 0
        @shakeX = 0
      else
        @shakeX += delta
      end
      if @shakeX > @shakeX_power * 2
        @shakeX_direction = -1
      end
      if @shakeX < - @shakeX_power * 2
        @shakeX_direction = 1
      end
      if @shakeX_duration >= 1
        @shakeX_duration -= 1
      end
    end
    if @shakeY_duration >= 1 || @shakeY != 0
      delta = (@shakeY_power * @shakeY_speed * @shakeY_direction) / 10.0
      if @shakeY_duration <= 1 && @shakeY * (@shakeY + delta) < 0
        @shakeY = 0
      else
        @shakeY += delta
      end
      if @shakeY > @shakeY_power * 2
        @shakeY_direction = -1
      end
      if @shakeY < - @shakeY_power * 2
        @shakeY_direction = 1
      end
      if @shakeY_duration >= 1
        @shakeY_duration -= 1
      end
    end
    if @weather_duration >= 1
      d = @weather_duration
      @weather_max = (@weather_max * (d - 1) + @weather_max_target) / d
      @weather_duration -= 1
      if @weather_duration == 0
        @weather_type = @weather_type_target
      end
    end
    if $game_temp.in_battle
      for i in 51..100
        @pictures[i].update
      end
    else
      for i in 1..50
        @pictures[i].update
      end
    end
  end

  def changeWeatherPlan(weather)
    if $game_switches[:Force_Weather]
      Kernel.pbMessage(_INTL("The Plot forbids this right now."))
      return
    end
    # Teknite Ridge wind
    if Reborn && $game_map.map_id == 642 && $game_switches[851]
      Kernel.pbMessage(_INTL("The Plot forbids this right now."))
      return
    end
    if weather == :Sunny && PBDayNight.isNight?(pbGetTimeNow)
      Kernel.pbMessage(_INTL("Weather can't be sunny during night time."))
      return
    end
    region = @regionalWeather.determineRegion
    if region.nil?
      Kernel.pbMessage(_INTL("It won't work here."))
    end

    # Set temporary weather override for current region.
    # Expires at the end of the current 8-hour period or when a different region is visited.
    @weatherOverride = [region, @regionalWeather.startTime, weather]

    setWeather # Give visual feedback of the change
    playWeatherOrDiveBGS

    $game_variables[:Weather_End_Of_Battle] = weather

    Kernel.pbMessage(_INTL("The weather has been set."))
  end

  def getCurrentWeather
    # get the current type/intensity pair and mod by region
    region = @regionalWeather.determineRegion
    return :Clear if region.nil?

    currentWeather = @regionalWeather.determineCurrentWeather
    unless @weatherOverride.nil?
      if @weatherOverride[0] == region && @weatherOverride[1] == @regionalWeather.startTime
        # Apply weather override
        currentWeather = @weatherOverride[2]
      else
        # Remove weather override when next period starts or different region is visited
        @weatherOverride = nil
      end
    end

    if $game_switches[:Force_Weather]
      return $game_variables[:Weather_Override]
    end

    # Teknite Ridge wind
    if Reborn && $game_map.map_id == 642 && $game_switches[851]
      return :Winds
    end

    if currentWeather == :Sunny && PBDayNight.isNight?(pbGetTimeNow) # can't be sunny at night
      return :Clear
    end

    return currentWeather
  end

  def setWeather
    return if !Reborn

    currentWeather = getCurrentWeather

    # If the weather is the same as before, keep the power to avoid power changes on map transitions
    power = @regionalWeather.rollPower(currentWeather)
    power = $game_screen.power if currentWeather == $game_screen.weather_type && !$game_screen.power.nil?

    # The variable should be set even while indoors because of Opal Ward Pansear/Panpour
    $game_variables[:Current_Weather] = currentWeatherVariableValue(currentWeather)

    if !$cache.mapdata[$game_map.map_id].Outdoor
      $game_screen.weather(:Clear, 0, 20)
      return
    end

    # apply weather
    $game_screen.weather(currentWeather, power, 20)
    $game_map.need_refresh = true
  end
end

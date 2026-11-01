#===============================================================================
# ** Scene_TimeWeather
# ** Created by BlueTowel
# ** Featuring RestToWait by Waynolt
#-------------------------------------------------------------------------------
#  This class performs menu screen processing.
#===============================================================================
class Scene_TimeWeather
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
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
    @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/TimeWeather/navbgtw")
    @sprites["background"].z = 255

    @sprites["weatherNow"] = IconSprite.new(112, 240)
    @sprites["weatherNext"] = IconSprite.new(304, 240)
    @sprites["weatherNow"].z = 255
    @sprites["weatherNext"].z = 255

    @sprites["timeFrame"] = IconSprite.new(182, 50)
    @sprites["timeFrame"].setBitmap(sprintf("Graphics/Pictures/Pokegear/TimeWeather/timeFrame"))
    @sprites["timeFrame"].z = 0

    @sprites["weatherFrame1"] = IconSprite.new(112, 240)
    @sprites["weatherFrame1"].setBitmap(sprintf("Graphics/Pictures/Pokegear/TimeWeather/weatherFrame"))
    @sprites["weatherFrame1"].z = 0

    @sprites["weatherFrame2"] = IconSprite.new(304, 240)
    @sprites["weatherFrame2"].setBitmap(sprintf("Graphics/Pictures/Pokegear/TimeWeather/weatherFrame"))
    @sprites["weatherFrame2"].z = 0

    render_header
    refresh

    # intro tts (for non-selectable things)
    time = pbGetTimeNow
    tts(time.strftime("%A %e %B"))
    tts("Current Time: " + time.strftime("%k %M"))
    tts("Location: " + $game_map.name.to_s)
    tts("Current Weather: " + @weatherType.to_s)
    tts("Weather at " + Time.at($game_screen.regionalWeather.nextWeatherTime).strftime("%H:%M") + ": " + @nextWeatherType.to_s)
    @selection = 0

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

  def refresh
    region = $game_screen.regionalWeather.determineRegion
    @weatherType = region ? $game_screen.weatherLabel($game_screen.getCurrentWeather) : "Unknown"

    @sprites["weatherNow"].setBitmap(sprintf("Graphics/Pictures/Pokegear/TimeWeather/weather_%s", @weatherType))

    forecast = $game_screen.regionalWeather.getForecast
    @nextWeatherType = region && forecast ? $game_screen.weatherLabel(forecast[0]) : "Unknown"

    @sprites["weatherNext"].setBitmap(sprintf("Graphics/Pictures/Pokegear/TimeWeather/weather_%s", @nextWeatherType))

    pbTimeText
  end

  def render_header
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(_INTL("Time & Weather"), -12, -18, 216, 64, @viewport)
    @sprites["header"].baseColor = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.new(0, 0, 0)
    @sprites["header"].windowskin = nil
  end

  #-----------------------------------------------------------------------------
  # * Display Time
  #-----------------------------------------------------------------------------
  def pbTimeText
    time = pbGetTimeNow
    timeOfDay = "Day"
    timeOfDay = "Night" if PBDayNight.isNight?(time)
    timeOfDay = "Evening" if PBDayNight.isEvening?(time)
    timeOfDay = "Morning" if PBDayNight.isMorning?(time)
    presentTime = time.strftime("%H:%M")
    todaysDate = time.strftime("%a %-d %b")
    todaysDate += " - " + timeOfDay

    @sprites["timenow"]&.dispose
    @sprites["timenow"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    timenow = @sprites["timenow"].bitmap
    baseColor = Color.new(248, 248, 248)
    textPositions = [[presentTime, 256, 50, 2, baseColor]]
    pbSetSystemFont(timenow)
    timenow.font.size *= 2
    pbDrawTextPositions(timenow, textPositions)

    @sprites["datenow"]&.dispose
    @sprites["datenow"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    datenow = @sprites["datenow"].bitmap
    baseColor = Color.new(248, 248, 248)
    textPositions = [[todaysDate, 256, 110, 2, baseColor]]
    pbSetSmallFont(datenow)
    pbDrawTextPositions(datenow, textPositions)

    @sprites["location"]&.dispose
    @sprites["location"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    currentLocation = pbGetMapNameFromId($game_map.map_id)
    location = @sprites["location"].bitmap
    baseColor = Color.new(248, 248, 248)
    textPositions = [[currentLocation, 256, 154, 2, baseColor]]
    pbSetSystemFont(location)
    pbDrawTextPositions(location, textPositions)

    @sprites["locPin"]&.dispose
    @sprites["locPin"] = IconSprite.new(256 - (location.text_size(currentLocation).width / 2) - 34, 153)
    @sprites["locPin"].setBitmap("Graphics/Pictures/Pokegear/TimeWeather/locPin")
    @sprites["locPin"].z = 255

    @sprites["weather"]&.dispose
    @sprites["weather"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    weatherChangeTime = _INTL("WEATHER AT {1}", Time.at($game_screen.regionalWeather.nextWeatherTime).strftime("%H:%M"))
    weather = @sprites["weather"].bitmap
    baseColor = Color.new(248, 248, 248)
    textPositions = [
      [_INTL("CURRENT WEATHER"), 70, 210, 0, baseColor],
      [weatherChangeTime, 274, 210, 0, baseColor],
    ]
    pbSetSystemFont(weather)
    pbDrawTextPositions(weather, textPositions)
  end

  #-----------------------------------------------------------------------------
  # * Rest to Wait
  #-----------------------------------------------------------------------------
  def restTime
    if $Settings.unrealTimeDiverge == 0
      Kernel.pbMessage(_INTL("Enable Unreal Time in Options to use the waiting feature."))
      return
    end

    timePast = getHowLongToRestFor() # Returns the number of real time seconds that are supposed to have been passed
    return nil if timePast == 0

    $gameTimeLastCheck -= timePast
    $game_screen.getTimeCurrent() # Will update the time
    refresh
    Kernel.pbMessage(_INTL("Please exit the area to properly update its events."))
  end

  def getHowLongToRestFor
    choice = Kernel.pbMessage(
      _INTL("Do you wish to rest for a while or until some time?"),
      [
        _INTL("For a while."),
        _INTL("Until some time."),
        _INTL("I changed my mind."),
      ],
      3
    )
    return getHowLongToRestForAsPeriod if choice == 0
    return getHowLongToRestForAsPointInTime if choice == 1

    return 0
  end

  def getHowLongToRestForAsPeriod
    params = ChooseNumberParams.new
    params.setRange(0, 9999)
    params.setDefaultValue(0)
    hours = Kernel.pbMessageChooseNumber(_INTL("How many hours would you like to rest?"), params)
    seconds = hours * 3600
    return seconds.to_f / $game_screen.getTimeScale().to_f
  end

  def getHowLongToRestForAsPointInTime
    now = $game_screen.getTimeCurrent()
    # Get the target weekday
    choiceWday = Kernel.pbMessage(
      _INTL("When would you like to wake up?"),
      [
        _INTL("Sunday"),
        _INTL("Monday"),
        _INTL("Tuesday"),
        _INTL("Wednesday"),
        _INTL("Thursday"),
        _INTL("Friday"),
        _INTL("Saturday"),
        _INTL("Nevermind"),
      ],
      8
    )
    if choiceWday == 7
      return 0
    end

    daysPast = choiceWday - now.wday
    while daysPast < 0
      daysPast += 7
    end
    # Get the target hour
    params = ChooseNumberParams.new
    params.setRange(0, 23)
    params.setDefaultValue(now.hour)
    choiceHour = Kernel.pbMessageChooseNumber(_INTL("At which hour?"), params)
    hoursPast = choiceHour - now.hour
    # Combine the two
    hours = daysPast * 24 + hoursPast
    while hours < 0
      # Go to the next week
      hours += 168 # 24*7 = 168
    end
    seconds = hours * 3600 # 60*60 = 3600
    return seconds.to_f / $game_screen.getTimeScale().to_f
  end

  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    # Update windows
    pbUpdateSpriteHash(@sprites)
    updateCustom
  end
  #-----------------------------------------------------------------------------
  # * Frame Update (when command window is active)
  #-----------------------------------------------------------------------------

  # Commands
  def updateCustom
    update = false # for tts
    # selection (0=empty, 1=time, 2=current weather, 3=next weather)
    if Input.trigger?(Input::UP) || Input.repeat?(Input::UP) || Input.trigger?(Input::LEFT) || Input.repeat?(Input::LEFT)
      pbPlayCursorSE()
      @selection > 1 ? @selection -= 1 : @selection = 3
      update = true
    elsif Input.trigger?(Input::DOWN) || Input.repeat?(Input::DOWN) || Input.trigger?(Input::RIGHT) || Input.repeat?(Input::RIGHT)
      pbPlayCursorSE()
      @selection < 3 ? @selection += 1 : @selection = 1
      update = true
    end

    if @selection == 1
      # display timeframe, hide other frames
      @sprites["timeFrame"].z = 255
      @sprites["weatherFrame1"].z = 0
      @sprites["weatherFrame2"].z = 0
      if update
        tts("Current Time: " + pbGetTimeNow.strftime("%k %M"))
      end
    elsif @selection == 2
      # display weatherframe at current, hide other frames
      @sprites["timeFrame"].z = 0
      @sprites["weatherFrame1"].z = 255
      @sprites["weatherFrame2"].z = 0
      if update
        tts("Current Weather: " + @weatherType)
      end
    elsif @selection == 3
      # display weatherframe at next, hide other frames
      @sprites["timeFrame"].z = 0
      @sprites["weatherFrame1"].z = 0
      @sprites["weatherFrame2"].z = 255
      if update
        tts("Weather at " + Time.at($game_screen.regionalWeather.nextWeatherTime).strftime("%H:%M") + ": " + @nextWeatherType.to_s)
      end
    end

    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      $scene = Scene_Pokegear.new(:weather)
      return
    end
    if Input.trigger?(Input::C)
      case @selection
        when 0, 1
          if $game_switches[:Unreal_Time]
            restTime
          else
            Kernel.pbMessage(_INTL("Remember to take regular breaks!"))
          end
        when 2
          changeWeather
        when 3
          nextWeather
      end
    end
  end

  def changeWeather
    if !$game_switches[:Weather_password] && !$DEBUG
      Kernel.pbMessage(_INTL("Current weather: {1}", @weatherType))
      return
    end

    choices = []
    choices.push _INTL("Clear")
    choices.push _INTL("Rain")
    choices.push _INTL("Storm")
    choices.push _INTL("Sunny")
    choices.push _INTL("Snow")
    choices.push _INTL("Sandstorm")
    choices.push _INTL("Windy")
    choices.push _INTL("Cancel")

    choice = Kernel.pbMessage(_INTL("Current weather: {1}\nSelect weather type.", @weatherType), choices, -1)
    return unless choice.between?(0, choices.length - 2)

    weather = [:Clear, Reborn ? :RainLegacy : :Rain, Reborn ? :StormLegacy : :Storm, :Sunny, :Snow, :Sandstorm, :Winds][choice]

    $game_screen.changeWeatherPlan(weather)
    refresh
  end

  def nextWeather
    if $game_screen.regionalWeather.getForecast.nil?
      Kernel.pbMessage(_INTL("No data for this location."))
      return
    end

    $game_screen.regionalWeather.weatherApp

    cmd = Kernel.pbMessage("Reroll forecast?", [_INTL("Yes"), _INTL("No")], -1)
    if cmd == 0
      $game_screen.regionalWeather.rerollSeed
      $game_screen.regionalWeather.resetForecast
    end
  end
end

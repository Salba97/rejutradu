#==============================================================================
# BerryPlantData from Essentials, with slight modifications
#==============================================================================
class BerryPlantData
  attr_accessor :berry_id
  attr_accessor :data
  attr_accessor :time_alive
  attr_accessor :time_last_updated
  attr_accessor :growth_stage
  attr_accessor :watered_this_stage
  attr_accessor :watering_count

  NUMBER_OF_GROWTH_STAGES = 4

  def initialize
    reset
  end

  def reset
    @berry_id           = nil
    @data               = nil
    @time_alive         = 0
    @time_last_updated  = 0
    @growth_stage       = 0
    @watered_this_stage = false
    @watering_count     = 0
  end

  def plant(berry_id)
    reset
    @berry_id          = berry_id
    @data              = $cache.items[@berry_id].berry
    @growth_stage      = 1
    @time_last_updated = (pbGetTimeNow.to_i / 60) * 60 # accurate to the minute
  end

  def planted?
    return @growth_stage > 0
  end

  def growing?
    return @growth_stage > 0 && @growth_stage < 5
  end

  def grown?
    return @growth_stage >= 5
  end

  def water
    if !@watered_this_stage
      @watered_this_stage = true
      @watering_count += 1
    end
  end

  def berry_yield
    # Formula: https://bulbapedia.bulbagarden.net/wiki/Berry#Yield
    return @berry_yield unless @berry_yield.nil?

    if @watering_count == 0
      @berry_yield = @data.yield.min
    else
      yield_range = @data.yield.max - @data.yield.min
      random = rand(0..yield_range)
      dividend = yield_range * (@watering_count - 1) + random
      extra = dividend % 4 >= 2 ? 1 : 0
      @berry_yield = dividend / 4 + extra + @data.yield.min
    end
    return @berry_yield
  end

  # We use old mechanics in this engine, but want to update every frame while the map is loaded.
  def update
    return if !planted?

    time_now = pbGetTimeNow.to_i
    time_delta = time_now - @time_last_updated
    return if time_delta <= 0

    new_time_alive = @time_alive + time_delta
    time_per_stage = @data.time / NUMBER_OF_GROWTH_STAGES * 3600 # in seconds
    # Update how long plant has been alive for
    old_growth_stage = @growth_stage
    @time_alive = new_time_alive
    @growth_stage = 1 + @time_alive / time_per_stage
    @time_last_updated = time_now
    # Record watering
    new_growth_stage = [@growth_stage, NUMBER_OF_GROWTH_STAGES + 1].min
    @watered_this_stage = false if new_growth_stage > old_growth_stage
    water if $game_screen&.isRaining?
  end
end

Events.onSpritesetCreate += proc { |sender, e|
  spriteset = e[0]
  viewport = e[1]
  map = spriteset.map
  for i in map.events.keys
    if map.events[i].name == "BerryPlant"
      spriteset.addUserSprite(BerryPlantSprite.new(map.events[i], map, viewport))
    end
  end
}

class BerryPlantSprite
  BLINK_RATE = 4

  def initialize(event, map, viewport)
    @event = event
    @map = map
    @old_stage = 0
    @frames = 0
    @sparkling = false
    @wait_sparkling = false
    @disposed = false
    berryData = event.variable
    return if !berryData

    @old_stage = berryData.growth_stage
    @event.character_name = ""
    update_plant(berryData)
    set_event_graphic(berryData, true)
  end

  def dispose
    @event = nil
    @map = nil
    @disposed = true
  end

  def disposed?
    @disposed
  end

  def set_event_graphic(berryData, full_check = false)
    return if (!berryData || (berryData.growth_stage == @old_stage && !full_check)) && !@sparkling

    if berryData.growth_stage == 0
      @event.character_name = ""
    else
      if @old_stage != berryData.growth_stage && @old_stage > 0 && berryData.growth_stage <= BerryPlantData::NUMBER_OF_GROWTH_STAGES + 1
        start_sparkling
      end
      growth_stage = berryData.growth_stage
      growth_stage -= 1 if @sparkling && @frames <= 64
      if growth_stage == 1
        @event.character_name = "berrytreeplanted" # Common to all berries
        @event.turn_down
      else
        filename = sprintf("berrytree%s", getItemName(berryData.berry_id)) rescue nil
        filename = "berrytree#{berryData.berry_id}" if !pbResolveBitmap("Graphics/Characters/" + filename)
        if pbResolveBitmap("Graphics/Characters/" + filename)
          @event.character_name = filename
          case growth_stage
            when 2 then @event.turn_down  # X sprouted
            when 3 then @event.turn_left  # X taller
            when 4 then @event.turn_right # X flowering
            else        @event.turn_up if growth_stage >= 5 # X berries
          end
        else
          @event.character_name = "itemball"
        end
      end
      if @sparkling
        @frames += 1
        # Sprite blinking
        if @frames <= 128 && $Settings.photosensitive == 0
          @event.character_name = "" if @frames / BLINK_RATE % 2 == 0
        end
        if @frames == 193
          @frames = 0
          @sparkling = false
        end
      end
    end
    @old_stage = berryData.growth_stage
  end

  def start_sparkling
    unless $scene.spriteset.nil?
      $scene.spriteset.addEventAnimation(PLANT_SPARKLE_ANIMATION_ID, @event, true)
      @sparkling = true
      @wait_sparkling = false
    else
      @wait_sparkling = true
    end
  end

  def update_plant(berryData)
    berryData.update if berryData&.planted?
  end

  def update
    berryData = @event.variable
    return unless berryData

    start_sparkling if @wait_sparkling
    update_plant(berryData)
    set_event_graphic(berryData)
  end
end

def pbBerryPlant
  interp = pbMapInterpreter
  thisEvent = interp.get_character(0)
  berryData = interp.getVariable
  if !berryData
    berryData = BerryPlantData.new
    interp.setVariable(berryData)
  end
  berry = berryData.berry_id
  # Interact with the event based on its growth
  if berryData.grown?
    thisEvent.turn_up # Stop the event turning towards the player
    pbPickBerry(berry, berryData.berry_yield)
    return
  elsif berryData.growing?
    case berryData.growth_stage
      when 1 # X planted
        thisEvent.turn_down
        Kernel.pbMessage(_INTL("{1} was planted here.", getItemName(berry, :A)))
      when 2 # X sprouted
        thisEvent.turn_down
        Kernel.pbMessage(_INTL("{1} has sprouted.", getItemName(berry, :The)))
      when 3 # X taller
        thisEvent.turn_left
        Kernel.pbMessage(_INTL("This {1} plant is growing taller.", getItemName(berry)))
      when 4 # X flowering
        thisEvent.turn_right
        case berryData.watering_count
          when 4    then Kernel.pbMessage(_INTL("These {1} flowers are blooming very beautifully.", getItemName(berry)))
          when 2, 3 then Kernel.pbMessage(_INTL("These {1} flowers are blooming prettily.", getItemName(berry)))
          else           Kernel.pbMessage(_INTL("These {1} flowers are blooming cutely.", getItemName(berry)))
        end
    end
    # Water the growing plant
    item = [:SPRAYDUCK, :SQUIRTBOTTLE, :WAILMERPAIL].find { |i| $PokemonBag.pbQuantity(i) > 0 }
    pbWaterBerry(berryData) if item && Kernel.pbConfirmMessage(_INTL("Want to water {1} plant with {2}?", getItemName(berry, :the), getItemName(item, :the)))
    return
  end
  # Nothing planted yet
  return unless Kernel.pbConfirmMessage(_INTL("It's soft, loamy soil.\nWant to plant a Berry?"))

  pbFadeOutIn(99999) {
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene, $PokemonBag)
    berry = screen.pbChooseBerryScreen
  }
  if berry
    berryData.plant(berry)
    $PokemonBag.pbDeleteItem(berry, 1)
    Kernel.pbMessage(_INTL("{1} planted {2} in the soft, loamy soil.", $Trainer.name, getItemName(berry, :a)))
  end
end

def pbPickBerry(berry, qty = 1)
  Kernel.pbMessage(_INTL("You found {1} {2}!", qty, getItemName(berry, plural: qty > 1)))
  askmessage = _INTL("Do you want to pick {1}?", getItemName(berry, :the, plural: qty > 1))
  return false if !Kernel.pbConfirmMessage(askmessage)

  v = pbPutBerryInBag(berry, qty)
  return false if !v

  interp = pbMapInterpreter
  thisEvent = interp.get_character(0)
  berryData = interp.getVariable
  if berryData
    berryData.reset
  else
    berryData = BerryPlantData.new
    interp.setVariable(berryData)
  end
  pbSetSelfSwitch(thisEvent.id, "A", true)
  return true
end

def pbPutBerryInBag(berry, quantity)
  if !$PokemonBag.pbCanStore?(berry, quantity)
    Kernel.pbMessage(_INTL("Too bad...\nThe Bag is full."))
    return false
  end
  if quantity > 1
    Kernel.pbMessage(_INTL("\\se[berrypick]{1} picked {2} \\c[1]{3}\\c[0].\\wtnp[30]", $Trainer.name, quantity, getItemName(berry, plural: true)))
  else
    Kernel.pbMessage(_INTL("\\se[berrypick]{1} picked {2}.\\wtnp[30]", $Trainer.name, getItemName(berry, :the, color: true)))
  end
  Kernel.pbTryStoreItem(berry, quantity) # Can't return false as condition has been checked already
  Kernel.pbMessage(_INTL("The soil returned to its soft and loamy state."))
  return true
end

def pbWaterBerry(berryData)
  berryData.water
  Kernel.pbMessage(_INTL("{1} watered {2} plant.\\wtnp[40]", $Trainer.name, getItemName(berryData.berry_id, :the)))
  Kernel.pbMessage(_INTL("The plant seems to be delighted."))
end

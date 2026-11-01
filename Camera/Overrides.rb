class Game_Player
  # alias __camera_moveInput moveInput unless method_defined?(:__camera_moveInput)
  # def moveInput(direction)
  #   last_speed = @move_speed
  #   __camera_moveInput(direction)
  #   if FancyCamera::INCREASE_WHEN_RUNNING
  #     pbCameraSpeed(cameraSpeedFormula(@move_speed).round(4)) unless last_speed == @move_speed || $game_system.map_interpreter.running? ||
  #                                                           @move_route_forcing || $game_temp.message_window_showing || $PokemonTemp.miniupdate
  #     pbCameraSpeed(1) if @bump_se && @bump_se > 0
  #   end
  # end

  def update
    ### START Walk_Run.rb OVERRIDE
      last_speed = @move_speed
      last_cam_speed = $game_temp.camera_speed
      if pbGetTerrainTag == PBTerrain::Ice
        @move_speed = 5.0
      elsif !moving? && !@move_route_forcing && $PokemonGlobal
        if $PokemonGlobal.bicycle
          @move_speed = 6.0
        elsif $PokemonGlobal.surfing
          @move_speed = 5.0
        elsif $PokemonGlobal.lavasurfing
          @move_speed = 5.0
        elsif $PokemonGlobal.diving
          @move_speed = 5.0
        elsif $game_switches[:Riding_Tauros]
          @move_speed = 5.5
        elsif pbCanRun?
          if Kernel.pbFacingTerrainTag == PBTerrain::SandDune
            @move_speed = 3.8
          else
            @move_speed = 5.0
          end
        else
          if Kernel.pbFacingTerrainTag == PBTerrain::SandDune
            @move_speed = 3.0
          else
            @move_speed = 4.0
          end
        end
      end
      @move_speed = jumping? ? 5.0 : @move_speed
      if FancyCamera::INCREASE_WHEN_RUNNING
        if @bump_se && @bump_se > 0
          pbCameraSpeed(1)
        else
          camspeed = cameraSpeedFormula(@move_speed).round(4)
          pbCameraSpeed(camspeed) unless (last_speed == @move_speed && last_cam_speed == camspeed) || $game_system.map_interpreter.running? ||
                                                              @move_route_forcing || $game_temp.message_window_showing || $PokemonTemp.miniupdate ||
                                                              $game_temp.isCameraScrolling
        end
      end
    ### END Walk_Run.rb OVERRIDE

    # Start Vanilla Code A
      # Remember whether or not moving in local variables
      last_moving = moving?
      # If moving, event running, move route forcing, and message window
      # display are all not occurring
      dir = Input.dir4

      unless moving? || $game_system.map_interpreter.running? ||
            @move_route_forcing || $game_temp.message_window_showing ||
            $PokemonTemp.miniupdate
        # Move player in the direction the directional button is being pressed
        @waiter = 0 if !@waiter
        @waiter = ($speed_up ? $Settings.turboSpeedMultiplier : 1).floor if @lastdir != dir && Graphics.frame_count - @lastdirframe != 1
        @waiter -= 1
        if dir == @lastdir && Graphics.frame_count - @lastdirframe > 0 && !Input.press?(Input::ALT)
          case dir
            when 2 then move_down
            when 4 then move_left
            when 6 then move_right
            when 8 then move_up
          end
        elsif dir != @lastdir && Graphics.frame_count - @lastdirframe > 0
          case dir
            when 2 then turn_down
            when 4 then turn_left
            when 6 then turn_right
            when 8 then turn_up
          end
        end
      end
      $PokemonTemp.dependentEvents.updateDependentEvents
      @waiter = 0 if !@waiter

      @lastdir = dir if @waiter < 0
      @lastdirframe = Graphics.frame_count if dir != 0
      # Remember coordinates in local variables
      last_real_x = @real_x
      last_real_y = @real_y
      super
    # End Vanilla Code A

    # Camera + new screen post method handling
    update_screen_position(last_real_x, last_real_y)

    # Start Vanilla Code B
      # Count down the time between allowed bump sounds
      @bump_se -= 1 if @bump_se && @bump_se > 0
      # If not moving
      unless moving?
        # If player was moving last time
        if last_moving
          $PokemonTemp.dependentEvents.pbTurnDependentEvents
          result = pbCheckEventTriggerFromDistance([2])
          # Event determinant is via touch of same position event
          result |= check_event_trigger_here([1, 2])
          # If event which started does not exist
          Kernel.pbOnStepTaken(result) # *Added function call
        end
        # If C button was pressed
        if Input.trigger?(Input::C) && !$PokemonTemp.miniupdate
          # Same position and front event determinant
          check_event_trigger_here([0])
          check_event_trigger_there([0, 2]) # *Modified to prevent unnecessary triggers
        end
      end
    # End Vanilla Code B
  end

  def getSpeedTransition
    # Hacky solution to a hacky problem with transfering player where the game cannot accurately detect the
    # player's move speed because event handling
    autorunning = $Settings.autorunning == 0 ? true : false

    # Flip autorunning while Shift is pressed.
    if Input.shiftKeyPressed?
      autorunning = !autorunning
    end
    if pbGetTerrainTag == PBTerrain::Ice
      @move_speed = 5.0
    elsif !moving? && !@move_route_forcing && $PokemonGlobal
      if $PokemonGlobal.bicycle
        @move_speed = 6.0
      elsif $PokemonGlobal.surfing
        @move_speed = 5.0
      elsif $PokemonGlobal.lavasurfing
        @move_speed = 5.0
      elsif $PokemonGlobal.diving
        @move_speed = 5.0
      elsif $game_switches[:Riding_Tauros]
        @move_speed = 5.5
      elsif autorunning
        if Kernel.pbFacingTerrainTag == PBTerrain::SandDune
          @move_speed = 3.8
        else
          @move_speed = 5.0
        end
      else
        if Kernel.pbFacingTerrainTag == PBTerrain::SandDune
          @move_speed = 3.0
        else
          @move_speed = 4.0
        end
      end
    end
    @move_speed = jumping? ? 5.0 : @move_speed

    return @move_speed
  end

  # Center player on-screen
  def update_screen_position(last_real_x, last_real_y)
    return if self.map.scrolling?
    $game_temp.last_camera_pos = [self.map.display_x, self.map.display_y]
    target = [@real_x - m_center_x, @real_y - m_center_y]
    if $game_temp.camera_pos && $game_temp.camera_pos != [0, 0]
      if (!self.isCameraCentered? || $game_temp.camera_lock) || pbMapInterpreterRunning?
        target = $game_temp.camera_pos
      else
        $game_temp.camera_pos = [0, 0] if self.isCameraCentered? && !$game_temp.camera_lock
      end
    end
    if $game_temp.camera_target_event && $game_temp.camera_target_event != 0
      event = $game_map.events[$game_temp.camera_target_event]
      if event
        target = [event.real_x - m_center_x, event.real_y - m_center_y]
      end
    end
    if $game_temp.camera_shake > 0
      power = $game_temp.camera_shake * FancyCamera::SHAKE_STRENGTH
      target = [target[0] + rand(-power..power), target[1] + rand(-power..power)]
    end
    if $game_temp.camera_offset && $game_temp.camera_offset != [0, 0]
      target = [target[0] + ($game_temp.camera_offset[0] * Game_Map.realResX), target[1] + ($game_temp.camera_offset[1] * Game_Map.realResY)]
    end
    if self.map.snap_edges
      max_x = (self.map.width - Graphics.width / Game_Map::TILEWIDTH) * Game_Map.realResX
      target[0] = [0, [target[0], max_x].min].max
      max_y = (self.map.height - Graphics.height / Game_Map::TILEHEIGHT) * Game_Map.realResY
      target[1] = [0, [target[1], max_y].min].max
    end
    dX = target[0] - self.map.display_x
    dY = target[1] - self.map.display_y
    distance = Math.sqrt(dX * dX + dY * dY)

    if distance == 0
      $game_temp.isCameraScrolling = false
      $game_temp.waitForCamera = false
      @move_vector = nil
      return
    end

    if !@move_vector # || ($game_switches[:Fancy_Camera_Toggle] && $Settings.cameraAccessibility == 0)
      @move_vector = [1.0, 1.0]
      if dX != 0 && dY != 0
        @move_vector[0] = (dX.abs.to_f / dY.abs) if dX.abs > dY.abs
        @move_vector[1] = (dY.abs.to_f / dX.abs) if dX.abs < dY.abs
      end
      # p [dX, dY]
    end

    distanceThreshold = 0.75
    speed = ($game_temp.camera_speed * 0.2).round(4)
    newX, newY = target
    if $game_switches[:Fancy_Camera_Toggle] && $Settings.cameraAccessibility == 0
      x = ease_in_out(self.map.display_x, target[0], speed) - self.map.display_x
      newX = self.map.display_x + (x * (1 + (@move_vector[0] / 100.0)))
      y = ease_in_out(self.map.display_y, target[1], speed) - self.map.display_y
      newY = self.map.display_y + (y * (1 + (@move_vector[1] / 100.0)))
    else
      speed = @move_speed
      speed = cameraSpeedFormulaInvert($game_temp.camera_speed).round(4) if $game_temp.isCameraScrolling
      speed = @move_speed if @move_route_forcing
      distance2 = 2**speed

      dFX = distance2 * @move_vector[0] * (dX.negative? ? -1 : dX == 0 ? 0 : 1)
      dFY = distance2 * @move_vector[1] * (dY.negative? ? -1 : dY == 0 ? 0 : 1)

      newX = self.map.display_x + dFX
      newY = self.map.display_y + dFY
    end

    # Make sure these values are grid locked
    newX = newX.round
    newY = newY.round
    xOffset = newX % 2
    newX = newX + xOffset if newX % 2 != 0
    yOffset = newY % 2
    newY = newY + yOffset if newY % 2 != 0

    if newX == $game_temp.last_camera_pos[0] && newX != target[0]
      newX += 2 * (dX.negative? ? -1 : dX == 0 ? 0 : 1)
    end

    if newY == $game_temp.last_camera_pos[1] && newY != target[1]
      newY += 2 * (dY.negative? ? -1 : dY == 0 ? 0 : 1)
    end

    if !newX.between?(*[target[0], self.map.display_x].sort)
      newX = target[0]
    end
    if !newY.between?(*[target[1], self.map.display_y].sort)
      newY = target[1]
    end

    if dX.abs < 1.0
      self.map.display_x = target[0]
    else
      self.map.display_x = newX
    end
    if dY.abs < 1.0
      self.map.display_y = target[1]
    else
      self.map.display_y = newY
    end
  end

  def isCameraCentered?
    return [$game_temp.camera_x, $game_temp.camera_y] == [self.x, self.y]
  end

=begin
  ?? this seems to exist already but slightly changed. I imagine essentials 21+ has weird changes here and there
  def moveto(x, y, center = true)
    super
    center(x, y) if center
    make_encounter_count
  end
=end

  alias __camera_center center unless method_defined?(:__camera_center)
  def center(x, y)
    speed = getSpeedTransition
    pbCameraReset(cameraSpeedFormula(speed).round(4)) if $game_temp.camera_pos
    __camera_center(x, y)
    # self.map.display_x = (x * Game_Map::REAL_RES_X) - SCREEN_CENTER_X
    # self.map.display_y = (y * Game_Map::REAL_RES_Y) - SCREEN_CENTER_Y
    # SCREEN_CENTER_Z = (Graphics.zeight * 2 - 64)
    # REAL_RES_Z = 128
  end
end

def m_center_x
  # (Graphics.height * 2 - 64)
  (Graphics.width / 2 - Game_Map::TILEWIDTH / 2) * Game_Map::XSUBPIXEL
end

def m_center_y
  # (Graphics.height * 2 - 64)
  (Graphics.height / 2 - Game_Map::TILEHEIGHT / 2) * Game_Map::YSUBPIXEL
end

def cameraSpeedFormula(speed)
  # base speed 4, camera speed 1
  CameraSpline.predict(speed)
end

def cameraSpeedFormulaInvert(speed)
  CameraSpline.inverse(speed)
end

module CameraSpline
  MIN = 0
  MAX = 99

  def self.predict(x)
    rcs1, rcs2, rcs3 = rcs_basis(x)

    0.186113 + (0.310422 * x) - (0.0440059 * rcs1) + (0.149681 * rcs2) - (0.162521 * rcs3)
  end

  def self.inverse(y, tolerance: 1e-10)
    low = MIN
    high = MAX

    while high - low > tolerance
      mid = (low + high) / 2.0

      if predict(mid) < y
        low = mid
      else
        high = mid
      end
    end

    return (low + high) / 2.0
  end

  def self.cube_positive(x)
    return x > 0 ? x**3 : 0.0
  end

  def self.rcs_basis(x)
    knots = [1.0, 2.25, 3.5, 5.0]

    k1, k2, k3, k4 = knots

    return [
      cube_positive(x - k1) - ((k4 - k1) / (k4 - k3)) * cube_positive(x - k3) +
        ((k3 - k1) / (k4 - k3)) * cube_positive(x - k4),
      cube_positive(x - k2) - ((k4 - k2) / (k4 - k3)) * cube_positive(x - k3) +
        ((k3 - k2) / (k4 - k3)) * cube_positive(x - k4),
      cube_positive(x - k3) - ((k4 - k3) / (k4 - k3)) * cube_positive(x - k3) +
        ((k3 - k3) / (k4 - k3)) * cube_positive(x - k4)
    ]
  end
end

class Interpreter
  #-----------------------------------------------------------------------------
  # * Scroll Map
  #-----------------------------------------------------------------------------
  def command_203
    return true if $game_temp.in_battle
    speed = cameraSpeedFormula(@parameters[2]).round(4)
    pbCameraScrollDirection(@parameters[0], @parameters[1], speed)
    return true
  end
end

def pbScrollMap(direction, distance, speed)
  speed = cameraSpeedFormula(speed).round(4)
  pbCameraScrollDirection(direction, distance, speed)
  waitForCamera
end

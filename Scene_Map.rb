#===============================================================================
# ** Modified Scene_Map class for Pokémon.
#-------------------------------------------------------------------------------
#
#===============================================================================
class Scene_Map
  def spriteset
    for i in @spritesets.values
      return i if i.map == $game_map
    end
    return @spritesets.values[0]
  end

  def disposeSpritesets
    return if !@spritesets

    for i in @spritesets.keys
      if @spritesets[i]
        @spritesets[i].dispose
        @spritesets[i] = nil
      end
    end
    @spritesets.clear
    @spritesets = {}
  end

  def createSpritesets
    @spritesets = {}
    for map in $MapFactory.maps
      @spritesets[map.map_id] = Spriteset_Map.new(map)
    end
    $MapFactory.setSceneStarted(self)
    updateSpritesets
  end

  def updateMaps
    for map in $MapFactory.maps
      map.update
    end
    $MapFactory.updateMaps(self)
  end

  def updateSpritesets
    @spritesets = {} if !@spritesets
    TilemapUtils.updateAutoTiles if defined?(TilemapUtils)
    keys = @spritesets.keys.clone
    for i in keys
      if !$MapFactory.hasMap?(i)
        @spritesets[i].dispose if @spritesets[i]
        @spritesets[i] = nil
        @spritesets.delete(i)
      else
        @spritesets[i].update
      end
    end
    for map in $MapFactory.maps
      if !@spritesets[map.map_id]
        @spritesets[map.map_id] = Spriteset_Map.new(map)
      end
    end
    Events.onMapUpdate.trigger(self)
  end

  def main
    createSpritesets
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    disposeSpritesets
    if $game_temp.to_title
      Graphics.transition
      Graphics.freeze
    end
  end

  def miniupdate
    $PokemonTemp.miniupdate = true if $PokemonTemp
    loop do
      updateMaps
      $game_player.update
      $game_system.update
      $game_screen.update
      unless $game_temp.player_transferring
        break
      end

      transfer_player
      if $game_temp.transition_processing
        break
      end
    end
    updateSpritesets
    $PokemonTemp.miniupdate = false if $PokemonTemp
  end

  def update
    loop do
      updateMaps
      pbMapInterpreter.update
      $game_player.update
      $game_system.update
      $game_screen.update
      unless $game_temp.player_transferring
        break
      end

      transfer_player
      if $game_temp.transition_processing
        break
      end
    end
    updateSpritesets
    if $game_temp.to_title
      $scene = pbCallTitle
      return
    end
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" + $game_temp.transition_name)
      end
    end
    if $game_temp.message_window_showing
      return
    end

    if Input.trigger?(Input::C)
      unless pbMapInterpreterRunning?
        $PokemonTemp.hiddenMoveEventCalling = true
      end
    end

    # Pause Menu
    if Input.trigger?(Input::B)
      unless pbMapInterpreterRunning? || $game_system.menu_disabled || $game_player.moving?
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end

    # Autorun / Smart Travel
    @smartTravel = false if Input.time?(Input::A) == 0.0 && !Input.release?(Input::A)
    if Input.time?(Input::A) >= 0.5
      if $game_switches[:Blindstep]
        @smartTravel = true
      elsif !pbMapInterpreterRunning?
        smartTravel
      end
    elsif Input.release?(Input::A) && !Input.press?(Input::A)
      if @smartTravel
        @smartTravel = false
        smartTravel if !pbMapInterpreterRunning?
      elsif !pbMapInterpreterRunning?
        if $Settings.autorunning == 1
          $Settings.autorunning = 0
          saveSettings
        else
          $Settings.autorunning = 1
          saveSettings
        end
      end
    end

    # Coordinates / Quicksave
    @quickSave = false if Input.time?(Input::Z) == 0.0 && !Input.release?(Input::Z)
    if Input.time?(Input::Z) >= 0.5
      if $game_switches[:Blindstep]
        @quickSave = true
      else
        if $game_player && $game_map
          message = sprintf("X %d, Y %d, map %d, %s", $game_player.x, $game_player.y, $game_map.map_id, $game_map.name)
          Kernel.pbMessage(message)
        end
      end
    elsif Input.release?(Input::Z) && !Input.press?(Input::Z)
      if @quickSave || !$game_switches[:Blindstep]
        @quickSave = false
        quickSave
      elsif $game_player && $game_map
        message = sprintf("X %d, Y %d, map %d, %s", $game_player.x, $game_player.y, $game_map.map_id, $game_map.name)
        tts(message, true)
      end
    end

    # Ready menu / Text log
    @textLog = false if Input.time?(Input::Y) == 0.0 && !Input.release?(Input::Y)
    if Input.time?(Input::Y) >= 0.5
      if $game_switches[:Blindstep]
        @textLog = true
      else
        TextLog.show unless pbMapInterpreterRunning?
      end
    elsif Input.release?(Input::Y) && !Input.press?(Input::Y)
      if @textLog
        @textLog = false
        TextLog.show unless pbMapInterpreterRunning?
      else
        if $PokemonTemp && !pbMapInterpreterRunning? && !hidePlayerPossessions?
          $PokemonTemp.keyItemCalling = true
        end
      end
    end

    # View default controls
    if Input.triggerex?(Input::F2) && !pbMapInterpreterRunning?
      scene = DefaultControlsScene.new(1)
      pbFadeOutIn(99999) { scene.pbRender }
    end

    # Debug menu
    if $DEBUG && Input.press?(Input::F9)
      $game_temp.debug_calling = true
    end

    checkKeyPresses()

    # Actually doing the action chosen
    unless $game_player.moving?
      if $game_temp.battle_calling
        call_battle
      elsif $game_temp.shop_calling
        call_shop
      elsif $game_temp.name_calling
        call_name
      elsif $game_temp.menu_calling
        call_menu
      elsif $game_temp.save_calling
        call_save
      elsif $game_temp.debug_calling
        call_debug
      elsif $PokemonTemp && $PokemonTemp.keyItemCalling
        $PokemonTemp.keyItemCalling = false
        $game_player.straighten
        Kernel.pbUseKeyItem
      elsif $PokemonTemp && $PokemonTemp.hiddenMoveEventCalling
        $PokemonTemp.hiddenMoveEventCalling = false
        $game_player.straighten
        Events.onAction.trigger(self)
      else
        handleKeyPresses()
      end
    end
  end

  # To be overwritten per game
  def checkKeyPresses; end
  def handleKeyPresses; end

  def call_name
    $game_temp.name_calling = false
    $game_player.straighten
    $game_map.update
  end

  def call_menu
    $game_screen.getTimeCurrent

    $game_player.straighten
    $game_map.update
    sscene = PokemonMenu_Scene.new
    sscreen = PokemonMenu.new(sscene)
    sscreen.pbStartPokemonMenu
    $game_temp.menu_calling = false
    $game_screen.getTimeCurrent(true)
    $game_map.refresh

    $game_screen.getTimeCurrent
  end

  def call_debug
    $game_temp.debug_calling = false
    pbPlayDecisionSE()
    $game_player.straighten
    $scene = Scene_Debug.new
  end

  def autofade(mapid)
    # Fades music on the map if it is not the same as the previous map.
    # Also saves the previous map
    playingBGM = $game_system.playing_bgm
    playingBGS = $game_system.playing_bgs
    if !playingBGM && !playingBGS
      $previous_map = nil
      return
    end
    $previous_map = $cache.map_load(mapid)
    $previous_map_id = mapid

    actual_bgm_name = $game_map.getAutoplayBGM(mapid).clone
    if actual_bgm_name.include?("Reborn- ") && $game_switches[:Reborn_City_Restore]
      actual_bgm_name["Reborn- "] = "White- "
    end
    actual_bgm_name = $previous_map.bgm.name if !FileTest.audio_exist?("Audio/BGM/" + actual_bgm_name)

    if playingBGM && $previous_map.autoplay_bgm
      if (PBDayNight.isNight?(pbGetTimeNow) rescue false)
        if playingBGM.name != actual_bgm_name && playingBGM.name != actual_bgm_name + "n"
          pbBGMFade(0.8)
        end
      else
        if playingBGM.name != actual_bgm_name
          pbBGMFade(0.8)
        end
      end
    end
    if playingBGS && $previous_map.autoplay_bgs
      if playingBGS.name != $previous_map.bgs.name
        pbBGMFade(0.8)
      end
    end
    Graphics.frame_reset
  end

  def transfer_player(cancelVehicles = true)
    #CP_Profiler.begin
    starttime = Time.now
    # cancelVehicles = !($PokemonGlobal && ($PokemonGlobal.surfing || $PokemonGlobal.lavasurfing || $PokemonGlobal.diving))
    $game_temp.player_transferring = false
    if cancelVehicles && !$game_switches[:Retain_Vehicle]
      Kernel.pbCancelVehicles($game_temp.player_new_map_id)
    end
    autofade($game_temp.player_new_map_id) if !$game_switches[:Disable_Signposts_Music]
    if $game_map.map_id != $game_temp.player_new_map_id
      # Remove the temp value for handling elsewhere.
      map = $game_temp.player_new_map_id
      $game_temp.player_new_map_id = 0
      $MapFactory.setup(map)
    end
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    case $game_temp.player_new_direction
      when 2
        $game_player.turn_down
      when 4
        $game_player.turn_left
      when 6
        $game_player.turn_right
      when 8
        $game_player.turn_up
    end
    $game_player.straighten
    $game_map.update
    disposeSpritesets
    RPG::Cache.clear
    createSpritesets
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      Graphics.transition(20)
    end
    $game_screen.setWeather
    $game_map.autoplay if !$game_switches[:Disable_Signposts_Music]
    Graphics.frame_reset
    Input.update

    $game_variables[:Field_Effect_End_Of_Battle] = 0
    $game_variables[:Field_Counter_End_Of_Battle] = 0
    $game_variables[:Weather_End_Of_Battle] = 0

    $game_switches[:Rock_Climb_Convenience] = false
    $game_switches[:Cut_Convenience] = false
    $game_switches[:Waterfall_Convenience] = false
    $game_switches[:MagmaDrift_Convenience] = false
    $game_switches[:Surf_Convenience] = false
    $game_switches[:Rock_Smash_Convenience] = false
    $game_switches[:WaterWalk] = false

    # Actually reset the temp variables.
    $game_temp.player_new_map_id = 0
    $game_temp.player_new_x = 0
    $game_temp.player_new_y = 0
    $game_temp.player_new_direction = 0
    #CP_Profiler.print
    stoptime = Time.now
    puts "map transfer time: "
    puts stoptime - starttime
  end

  def quickSave
    # Ideally we'd like to use !pbMapInterpreterRunning? instead of !$game_player.move_route_forcing to prevent
    # quicksave during cutscenes. The problem is people are abusing it to save mid-gauntlet.
    # Quicksave mainly tends to break a save file if you use it while moving so let's at least prevent that.
    return if $game_system&.save_disabled || $game_player.move_route_forcing
    # Legendaries in Reborn are no longer in gauntlets with anomalies so we can do this.
    # "gauntletsave" password was added to save mid-gauntlets.
    return if Reborn && pbMapInterpreterRunning?
    # Prevent quicksave while softlocked.
    return if pbMapInterpreter.move_route_waiting
    # Freezes on Spinel Town due to the constantly moving eeveelutions.
    $game_switches[:Mid_quicksave] = true unless Reborn && $game_map.map_id == 271
    $game_switches[:Stop_Icycle_Falling] = true
    for event in $game_map.events.values
      event.minilock
    end
    pbHandleSave(quick: true)
    for event in $game_map.events.values
      event.unlock
    end
    $game_switches[:Mid_quicksave] = false
    $game_switches[:Stop_Icycle_Falling] = false
  end
end

def gauntletSave
  return unless $game_switches[:Gauntlet_Save]
  eventSave
end

def eventSave
  return unless $game_switches[:Enable_Event_Save]
  $game_switches[:Mid_quicksave] = true
  $game_switches[:Stop_Icycle_Falling] = true
  pbHandleSave(quick: true)
  $game_switches[:Mid_quicksave] = false
  $game_switches[:Stop_Icycle_Falling] = false
end

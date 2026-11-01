class MoveHandlerHash < HandlerHash
  def initialize
    super(:PBMoves)
  end
end

module HiddenMoveHandlers
  CanUseMove = MoveHandlerHash.new
  ConfirmUseMove = MoveHandlerHash.new
  UseMove = MoveHandlerHash.new

  def self.addCanUseMove(item, proc)
    CanUseMove.add(item, proc)
  end

  def self.addConfirmUseMove(item, proc)
    ConfirmUseMove.add(item, proc)
  end

  def self.addUseMove(item, proc)
    UseMove.add(item, proc)
  end

  def self.hasHandler(item)
    return false if !Reborn && item == :TELEPORT # Absolutely no one wants to deal with this mess right now, so sue us or don't

    return CanUseMove[item] != nil && UseMove[item] != nil
  end

  def self.triggerCanUseMove(item, pokemon, showmsg)
    # Returns whether move can be used
    if $game_switches[:NotPlayerCharacter]
      if showmsg
        pokemon == :Trainer ?
        Kernel.pbMessage(_INTL("Golden items cannot be used at this time.")) :
        Kernel.pbMessage(_INTL("You can't use this move right now."))
      end
      return false
    end
    if !CanUseMove[item]
      return false # Should never get here
    else
      return CanUseMove.trigger(item, pokemon, showmsg)
    end
  end

  def self.triggerConfirmUseMove(item, pokemon)
    # For certain moves only, prompts the player to confirm if the move should be used after it's selected
    if !ConfirmUseMove[item]
      return true
    else
      return ConfirmUseMove.trigger(item, pokemon)
    end
  end

  def self.triggerUseMove(item, pokemon)
    # Returns whether move was used
    if !UseMove[item]
      return false # Should never get here
    else
      return UseMove.trigger(item, pokemon)
    end
  end
end

def pbHiddenMoveAnimation(pokemon)
  # pokemon may be nil or a symbol in certain cases
  return false unless pokemon.is_a?(PokeBattle_Pokemon)
  return false if $game_switches[:EasyHMs_Password] || $game_switches[:SpeedSkip_Password]

  viewport = Viewport.new(0, 0, 0, 0)
  viewport.z = 99999
  bg = Sprite.new(viewport)
  bg.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/hiddenMovebg")
  sprite = PokemonSprite.new(viewport)
  sprite.setPokemonBitmap(pokemon)
  sprite.z = 1
  sprite.ox = sprite.bitmap.width / 2
  sprite.oy = sprite.bitmap.height / 2
  sprite.visible = false
  strobebitmap = AnimatedBitmap.new("Graphics/Pictures/hiddenMoveStrobes")
  strobes = []
  15.times do |i|
    strobe = BitmapSprite.new(26 * 2, 8 * 2, viewport)
    strobe.bitmap.blt(0, 0, strobebitmap.bitmap, Rect.new(0, (i % 2) * 8 * 2, 26 * 2, 8 * 2))
    strobe.z = ((i % 2) == 0 ? 2 : 0)
    strobe.visible = false
    strobes.push(strobe)
  end
  strobebitmap.dispose
  interp = RectInterpolator.new(
    Rect.new(0, Graphics.height / 2, Graphics.width, 0),
    Rect.new(0, (Graphics.height - bg.bitmap.height) / 2, Graphics.width, bg.bitmap.height),
    10
  )
  ptinterp = nil
  phase = 1
  frames = 0
  begin
    Graphics.update
    Input.update
    case phase
      when 1 # Expand viewport height from zero to full
        interp.update
        interp.set(viewport.rect)
        bg.oy = (bg.bitmap.height - viewport.rect.height) / 2
        if interp.done?
          phase = 2
          ptinterp = PointInterpolator.new(Graphics.width + (sprite.bitmap.width / 2), bg.bitmap.height / 2, Graphics.width / 2, bg.bitmap.height / 2, 16)
        end
      when 2 # Slide Pokémon sprite in from right to centre
        ptinterp.update
        sprite.x = ptinterp.x
        sprite.y = ptinterp.y
        sprite.visible = true
        if ptinterp.done?
          phase = 3
          pbPlayCry(pokemon)
          frames = 0
        end
      when 3 # Wait
        frames += 1
        if frames > 30
          phase = 4
          ptinterp = PointInterpolator.new(Graphics.width / 2, bg.bitmap.height / 2, -(sprite.bitmap.width / 2), bg.bitmap.height / 2, 16)
          frames = 0
        end
      when 4 # Slide Pokémon sprite off from centre to left
        ptinterp.update
        sprite.x = ptinterp.x
        sprite.y = ptinterp.y
        if ptinterp.done?
          phase = 5
          sprite.visible = false
          interp = RectInterpolator.new(
            Rect.new(0, (Graphics.height - bg.bitmap.height) / 2, Graphics.width, bg.bitmap.height),
            Rect.new(0, Graphics.height / 2, Graphics.width, 0),
            10
          )
        end
      when 5 # Shrink viewport height from full to zero
        interp.update
        interp.set(viewport.rect)
        bg.oy = (bg.bitmap.height - viewport.rect.height) / 2
        phase = 6 if interp.done?
    end
    for strobe in strobes
      strobe.ox = strobe.viewport.rect.x
      strobe.oy = strobe.viewport.rect.y
      if !strobe.visible
        randomY = 16 * (1 + rand(bg.bitmap.height / 16 - 2))
        strobe.y = randomY + (Graphics.height - bg.bitmap.height) / 2
        strobe.x = rand(Graphics.width)
        strobe.visible = true
      elsif strobe.x < Graphics.width
        strobe.x += 32
      else
        randomY = 16 * (1 + rand(bg.bitmap.height / 16 - 2))
        strobe.y = randomY + (Graphics.height - bg.bitmap.height) / 2
        strobe.x = -strobe.bitmap.width - rand(Graphics.width / 4)
      end
    end
    pbUpdateSceneMap
  end while phase != 6
  sprite.dispose
  for strobe in strobes
    strobe.dispose
  end
  strobes.clear
  bg.dispose
  viewport.dispose
  return true
end

#===============================================================================
# Rock Climb
#===============================================================================
def Kernel.pbRockClimb
  return false if $game_switches[:NotPlayerCharacter]

  if pbCheckHMBadges(:ROCKCLIMB)
    movefinder = pbCheckMove(:ROCKCLIMB)
    if movefinder
      return true if $game_switches[:Rock_Climb_Convenience]

      pbHMUseMessage(movefinder, :ROCKCLIMB)
      $game_switches[:Rock_Climb_Convenience] = true
      return true
    end
  end

  Kernel.pbMessage(_INTL("The wall is very rocky. A Pokémon might be able to climb it."))
  return false
end

def hookBeforeRockClimb
  # Intentionally empty, added as a hook for mod overrides to avoid having to update all rock climb events in the mod.
end

def hookAfterRockClimb
  # Intentionally empty, added as a hook for mod overrides to avoid having to update all rock climb events in the mod.
end

#===============================================================================
# Cut
#===============================================================================
def Kernel.pbCut
  return false if $game_switches[:NotPlayerCharacter]

  if pbCheckHMBadges(:CUT)
    movefinder = pbCheckMove(:CUT)
    if movefinder
      if $game_switches[:Cut_Convenience]
        pbSEPlay("PRSFX- Cut")
        return true
      end

      Kernel.pbMessage(_INTL("This tree looks like it can be cut down!\1"))
      if Kernel.pbConfirmMessage(_INTL("Would you like to cut it?"))
        pbHMUseMessage(movefinder, :CUT)
        pbSEPlay("PRSFX- Cut")
        $game_switches[:Cut_Convenience] = true
        return true
      end

      return false
    end
  end

  Kernel.pbMessage(_INTL("This tree looks like it can be cut down."))
  return false
end

HiddenMoveHandlers::CanUseMove.add(:CUT, lambda { |move, pkmn, showmsg|
  if !pbCheckHMBadges(:CUT)
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
    return false
  end
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || facingEvent.name != "Tree" || facingEvent.list.length <= 1
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:CUT, lambda { |move, pokemon|
  pbHMUseMessage(pokemon, move, onlyanim: true)
  facingEvent = $game_player.pbFacingEvent
  if facingEvent
    facingEvent.erase
    $PokemonMap.addErasedEvent(facingEvent.id)
  end
  return true
})

#===============================================================================
# Headbutt
#===============================================================================
def Kernel.pbHeadbuttEffect(event)
  if !pbEncounter(EncounterTypes::Headbutt)
    Kernel.pbMessage(_INTL("Nope.  Nothing..."))
  end
end

def Kernel.pbHeadbutt(event)
  movefinder = pbCheckMove(:HEADBUTT)
  if movefinder
    if Kernel.pbConfirmMessage(_INTL("A Pokémon could be in this tree.  Would you like to use Headbutt?"))
      pbHMUseMessage(movefinder, :HEADBUTT)
      Kernel.pbHeadbuttEffect(event)
    end
  else
    Kernel.pbMessage(_INTL("A Pokémon could be in this tree.  Maybe a Pokémon could shake it."))
  end
  Input.update
  return
end

def Kernel.pbHeadbutt2(event)
  movefinder = pbCheckMove(:HEADBUTT)
  if movefinder
    if Kernel.pbConfirmMessage(_INTL("A Pokémon might fall from this pole.  Want to headbutt it?"))
      pbHMUseMessage(movefinder, :HEADBUTT, _INTL("{1} did a headbutt!"))
      Kernel.pbHeadbuttEffect(event)
    end
  else
    Kernel.pbMessage(_INTL("A Pokémon might fall from this pole.  Maybe a Pokémon could shake it."))
  end
  Input.update
  return
end

HiddenMoveHandlers::CanUseMove.add(:HEADBUTT, lambda { |move, pkmn, showmsg|
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || facingEvent.name != "HeadbuttTree" || facingEvent.list.length <= 1
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:HEADBUTT, lambda { |move, pokemon|
  pbHMUseMessage(pokemon, move, onlyanim: true)
  facingEvent = $game_player.pbFacingEvent
  Kernel.pbHeadbuttEffect(facingEvent)
})

#===============================================================================
# Rock Smash
#===============================================================================
def pbRockSmashRandomEncounter
  if rand(100) < 25
    pbEncounter(EncounterTypes::RockSmash)
  end
end

def Kernel.pbRockSmash
  return false if $game_switches[:NotPlayerCharacter]

  if pbCheckHMBadges(:ROCKSMASH)
    movefinder = pbCheckMove(:ROCKSMASH)
    if movefinder
      if $game_switches[:Rock_Smash_Convenience]
        pbSEPlay("PRSFX- Rock Smash")
        return true
      end

      message = $game_switches[:Wall_Smash] ?
        _INTL("This wall appears to be breakable.\nWould you like to use Rock Smash?") :
        _INTL("This rock appears to be breakable.\nWould you like to use Rock Smash?")
      if Kernel.pbConfirmMessage(message)
        pbHMUseMessage(movefinder, :ROCKSMASH)
        pbSEPlay("PRSFX- Rock Smash")
        $game_switches[:Rock_Smash_Convenience] = true
        return true
      end

      return false
    end
  end

  if $game_switches[:Wall_Smash]
    Kernel.pbMessage(_INTL("It's a brittle wall. A Pokémon may be able to smash it."))
  else
    Kernel.pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:ROCKSMASH, lambda { |move, pkmn, showmsg|
  if !pbCheckHMBadges(:ROCKSMASH)
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
    return false
  end
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || facingEvent.name != "Rock" || facingEvent.list.length <= 1
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:ROCKSMASH, lambda { |move, pokemon|
  pbHMUseMessage(pokemon, move, onlyanim: true)
  facingEvent = $game_player.pbFacingEvent
  if facingEvent
    facingEvent.erase
    $PokemonMap.addErasedEvent(facingEvent.id)
    pbRockSmashRandomEncounter
  end
  return true
})

#===============================================================================
# Strength
#===============================================================================
def Kernel.pbStrength
  return false if $game_switches[:NotPlayerCharacter]

  if $PokemonMap.strengthUsed
    Kernel.pbMessage(_INTL("Strength made it possible to move boulders around."))
    return true
  end

  if pbCheckHMBadges(:STRENGTH)
    movefinder = pbCheckMove(:STRENGTH)
    if movefinder
      Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside."))
      if Kernel.pbConfirmMessage(_INTL("Would you like to use Strength?"))
        pbHMUseMessage(movefinder, :STRENGTH)
        $PokemonMap.strengthUsed = true
        return true
      end

      return false
    end
  end

  Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside."))
  return false
end

Events.onAction += lambda { |sender, e|
  facingEvent = $game_player.pbFacingEvent
  $surfnodive = false # Fringe cases with diving
  if facingEvent
    if facingEvent.name == "Boulder"
      Kernel.pbStrength
      return
    end
  end
}

HiddenMoveHandlers::CanUseMove.add(:STRENGTH, lambda { |move, pkmn, showmsg|
  if !pbCheckHMBadges(:STRENGTH)
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
    return false
  end
  if $PokemonMap.strengthUsed
    Kernel.pbMessage(_INTL("Strength is already being used.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:STRENGTH, lambda { |move, pokemon|
  pbHMUseMessage(pokemon, move, onlyanim: true)
  $PokemonMap.strengthUsed = true
  return true
})

#===============================================================================
# Surf
#===============================================================================
def Kernel.pbSurf
  return false if $game_player.pbHasDependentEvents?
  return false if $game_switches[:Cant_Surf]
  return false if $game_switches[:NotPlayerCharacter]

  if pbCheckHMBadges(:SURF)
    movefinder = pbCheckMove(:SURF)
    if movefinder
      if $game_switches[:Surf_Convenience]
        pbBGMPlay($cache.metadata[:Surf]) if $Settings.bike_and_surf_music == 1
        pbStartSurfing
        return true
      end

      if Kernel.pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
        pbHMUseMessage(movefinder, :SURF)
        $game_variables[:SurferID] = movefinder.is_a?(PokeBattle_Pokemon) ? movefinder.personalID : 0
        pbBGMPlay($cache.metadata[:Surf]) if $Settings.bike_and_surf_music == 1
        pbStartSurfing
        $game_switches[:Surf_Convenience] = true
        return true
      end
    end
  end

  return false
end

def pbStartSurfing
  Kernel.pbCancelVehicles
  $PokemonEncounters.clearStepCount
  surfing = pbIsWaterTag?(Kernel.pbFacingTerrainTag)
  $PokemonGlobal.surfing = true if surfing
  $PokemonGlobal.lavasurfing = true if !surfing
  $game_switches[:Faux_Surf] = true
  $game_map.refresh
  Kernel.pbUpdateVehicle
  currentTag = $game_player.pbTerrainTag
  direction = $game_player.direction
  direction = Direction::DownLeft if direction == Direction::Left && currentTag == PBTerrain::StairUpRight
  direction = Direction::DownRight if direction == Direction::Right && currentTag == PBTerrain::StairUpLeft
  $game_player.jumpDirection(direction)
  waitForJump
  Kernel.pbUpdateVehicle
  pbSEPlay("Surf Splash") if surfing
  $game_player.check_event_trigger_here([1, 2])
end

def pbEndSurf(direction = $game_player.direction)
  return false unless $PokemonGlobal.surfing || $PokemonGlobal.lavasurfing

  surfing = $PokemonGlobal.surfing
  currentTag = $game_player.pbTerrainTag
  facingTag = Kernel.pbFacingTerrainTag
  return false if surfing && !(pbIsSurfableTag?(currentTag) && !pbIsSurfableTag?(facingTag))
  return false if !surfing && !(pbIsPassableLavaTag?(currentTag) && !pbIsPassableLavaTag?(facingTag))

  if $game_player.jumpDirection(direction)
    Kernel.pbCancelVehicles
    waitForJump
    pbSEPlay("Surf Surface") if surfing
    $game_switches[:Faux_Surf] = false
    $game_map.autoplayAsCue
    $game_player.increase_steps
    # This already happens at the end of Game_Player.update, calling it again here can cause two encounters when surf ends.
    # result = $game_player.check_event_trigger_here([1, 2])
    # Kernel.pbOnStepTaken(result)
    $game_map.refresh
  end
  return true
end

def Kernel.pbTransferSurfing(mapid, xcoord, ycoord, direction = $game_player.direction, noFade = false)
  if noFade
    $game_temp.player_new_map_id = mapid
    $game_temp.player_new_x = xcoord
    $game_temp.player_new_y = ycoord
    $game_temp.player_new_direction = direction
    Kernel.pbCancelVehicles
    $PokemonGlobal.surfing = true
    Kernel.pbUpdateVehicle
    $scene.transfer_player(false)
    $game_map.autoplay
    $game_map.refresh
  else
    pbFadeOutIn(99999) {
      $game_temp.player_new_map_id = mapid
      $game_temp.player_new_x = xcoord
      $game_temp.player_new_y = ycoord
      $game_temp.player_new_direction = direction
      Kernel.pbCancelVehicles
      $PokemonGlobal.surfing = true
      Kernel.pbUpdateVehicle
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
    }
  end
end

def pbIsFacingTileSurfPassable
  # Originally the check if a tile is not a cliff was just this line:
  # $game_map.passable?($game_player.x, $game_player.y, $game_player.direction)

  # That however didn't work correctly for several tiles on Azurine Island so I was looking for a better check.
  # The only one that worked for me was $game_player.passable? while $PokemonGlobal.surfing is true.
  # If you know a better way to correctly check the passability then please simplify this.
  surfing = $PokemonGlobal.surfing
  $PokemonGlobal.surfing = true
  passable = $game_player.passable?($game_player.x, $game_player.y, $game_player.direction)
  $PokemonGlobal.surfing = surfing

  # The code above doesn't work if the facing tile is on a different map through a map connection.
  # This code handles that case but doesn't handle cliffs correctly so it can't be used as a general solution.
  # Technically this still allows land surfing if there is an inaccessible water tile at the other side of
  # a map connection but I'm not aware of such case actually existing anywhere.
  facingTile = $MapFactory.getFacingTile($game_player.direction)
  if facingTile && facingTile[0] != $game_map.map_id
    passable = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
  end

  # Finally we need to fix stairs leading down to water such as Celestinine Mountain.
  passable = true if pbIsDiagonalStairTag?($game_player.pbTerrainTag)

  return passable
end

Events.onAction += lambda { |sender, e|
  terrain = Kernel.pbFacingTerrainTag
  notCliff = pbIsFacingTileSurfPassable
  if pbIsSurfableTag?(terrain) && !$PokemonGlobal.surfing && notCliff
    $surfnodive = true # Fringe cases with diving
    Kernel.pbSurf
    return
  end
}

HiddenMoveHandlers::CanUseMove.add(:SURF, lambda { |move, pkmn, showmsg|
  terrain = Kernel.pbFacingTerrainTag
  notCliff = pbIsFacingTileSurfPassable
  if !pbCheckHMBadges(:SURF)
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
    return false
  end
  if $PokemonGlobal.surfing
    Kernel.pbMessage(_INTL("You're already surfing.")) if showmsg
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    return false
  end
  if !pbIsSurfableTag?(terrain) || !notCliff || $game_switches[:Cant_Surf]
    Kernel.pbMessage(_INTL("No surfing here!")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:SURF, lambda { |move, pokemon|
  pbHMUseMessage(pokemon, move, onlyanim: true)
  $game_variables[:SurferID] = pokemon.is_a?(PokeBattle_Pokemon) ? pokemon.personalID : 0
  $game_temp.menu_calling = false
  pbStartSurfing
  return true
})

#===============================================================================
# Lave Surf
#===============================================================================
def Kernel.pbLavaSurf
  return false if $game_player.pbHasDependentEvents?
  return false if $game_switches[:Cant_Surf]
  return false if $game_switches[:NotPlayerCharacter]

  if pbCheckHMBadges(:MAGMADRIFT)
    movefinder = pbCheckMove(:MAGMADRIFT)
    if ($DEBUG && Input.press?(Input::CTRL)) || movefinder
      if $game_switches[:MagmaDrift_Convenience]
        pbBGMPlay($cache.metadata[:LavaSurf]) if $Settings.bike_and_surf_music == 1
        pbStartSurfing
        return true
      end

      if Kernel.pbConfirmMessage(_INTL("The lava is a deep red...\nWould you like to surf on it?"))
        pbHMUseMessage(movefinder, :MAGMADRIFT)
        pbBGMPlay($cache.metadata[:LavaSurf]) if $Settings.bike_and_surf_music == 1
        pbStartSurfing
        $game_switches[:MagmaDrift_Convenience] = true
        return true
      end
    end
  end

  return false
end

def Kernel.pbTransferLavaSurfing(mapid, xcoord, ycoord, direction = $game_player.direction, noFade = false)
  if noFade
    $game_temp.player_new_map_id = mapid
    $game_temp.player_new_x = xcoord
    $game_temp.player_new_y = ycoord
    $game_temp.player_new_direction = direction
    Kernel.pbCancelVehicles
    $PokemonGlobal.lavasurfing = true
    Kernel.pbUpdateVehicle
    $scene.transfer_player(false)
    $game_map.autoplay
    $game_map.refresh
  else
    pbFadeOutIn(99999) {
      $game_temp.player_new_map_id = mapid
      $game_temp.player_new_x = xcoord
      $game_temp.player_new_y = ycoord
      $game_temp.player_new_direction = direction
      Kernel.pbCancelVehicles
      $PokemonGlobal.lavasurfing = true
      Kernel.pbUpdateVehicle
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
    }
  end
end

Events.onAction += lambda { |sender, e|
  terrain = Kernel.pbFacingTerrainTag
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction)
  if pbIsPassableLavaTag?(terrain) && !$PokemonGlobal.lavasurfing && notCliff
    # $surfnodive=true #Fringe cases with diving
    Kernel.pbLavaSurf
    return
  end
}

HiddenMoveHandlers::CanUseMove.add(:MAGMADRIFT, lambda { |move, pkmn, showmsg|
  terrain = Kernel.pbFacingTerrainTag
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction)
  if !pbCheckHMBadges(:MAGMADRIFT)
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
    return false
  end
  if $PokemonGlobal.lavasurfing
    Kernel.pbMessage(_INTL("You're already surfing.")) if showmsg
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    return false
  end
  if !pbIsPassableLavaTag?(terrain) || !notCliff
    Kernel.pbMessage(_INTL("No surfing here!")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:MAGMADRIFT, lambda { |move, pokemon|
  pbHMUseMessage(pokemon, move, onlyanim: true)
  $game_temp.menu_calling = false
  pbStartSurfing
  return true
})

#===============================================================================
# Waterfall
#===============================================================================
def Kernel.pbAscendWaterfall(event = nil)
  facingEvent = $game_player.pbFacingEvent
  if facingEvent && facingEvent.name == "NeoWTele"
    $game_switches[:Waterfall_Convenience] = true
    facingEvent.start
    return
  end
  event = $game_player if !event
  return if !event
  return if event.direction == 4 || event.direction == 6 # can't ascend if not facing up

  oldthrough = event.through
  oldmovespeed = event.move_speed
  terrain = Kernel.pbFacingTerrainTag
  return if terrain != PBTerrain::Waterfall && terrain != PBTerrain::WaterfallCrest

  event.through = true
  event.move_speed = 5
  loop do
    event.move_forward(true)
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    terrain = pbGetTerrainTag(event)
    break if terrain != PBTerrain::Waterfall && terrain != PBTerrain::WaterfallCrest
  end
  event.through = oldthrough
  facingEvent = $game_player.pbFacingEvent
  if facingEvent && facingEvent.name == "WTele"
    event.move_forward(true)
  end
  event.move_speed = oldmovespeed
end

def Kernel.pbDescendWaterfall(event = nil)
  event = $game_player if !event
  return if !event
  return if event.direction != 2 # Can't descend if not facing down

  oldthrough = event.through
  oldmovespeed = event.move_speed
  terrain = Kernel.pbFacingTerrainTag
  return if terrain != PBTerrain::Waterfall && terrain != PBTerrain::WaterfallCrest

  event.through = true
  event.move_speed = 5
  loop do
    event.move_down
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    terrain = pbGetTerrainTag(event)
    break if terrain != PBTerrain::Waterfall && terrain != PBTerrain::WaterfallCrest
  end
  event.center(event.x, event.y) if event == $game_player
  event.through = oldthrough
  event.move_speed = oldmovespeed
end

def Kernel.pbWaterfall
  facingEvent = $game_player.pbFacingEvent
  return if facingEvent && facingEvent.name == "NeoWTele"

  pbAscendWaterfall if Kernel.pbWaterfallDialogue
end

def Kernel.pbWaterfallDialogue
  return false if $game_switches[:NotPlayerCharacter]

  if pbCheckHMBadges(:WATERFALL)
    movefinder = pbCheckMove(:WATERFALL)
    if movefinder
      return true if $game_switches[:Waterfall_Convenience]

      if Kernel.pbConfirmMessage(_INTL("It's a large waterfall.  Would you like to use Waterfall?"))
        pbHMUseMessage(movefinder, :WATERFALL)
        $game_switches[:Waterfall_Convenience] = true
        return true
      end

      return false
    end
  end

  Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
  return false
end

Events.onAction += lambda { |sender, e|
  terrain = Kernel.pbFacingTerrainTag
  if terrain == PBTerrain::Waterfall
    Kernel.pbWaterfall
    return
  end
  if terrain == PBTerrain::WaterfallCrest
    Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    return
  end
}

HiddenMoveHandlers::CanUseMove.add(:WATERFALL, lambda { |move, pkmn, showmsg|
  if !pbCheckHMBadges(:WATERFALL)
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
    return false
  end
  terrain = Kernel.pbFacingTerrainTag
  if terrain != PBTerrain::Waterfall
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:WATERFALL, lambda { |move, pokemon|
  pbHMUseMessage(pokemon, move, onlyanim: true)
  Kernel.pbAscendWaterfall
  return true
})

#===============================================================================
# Dive
#===============================================================================
def Kernel.pbDive
  return false if $game_switches[:NotPlayerCharacter]

  divemap = $cache.mapdata[$game_map.map_id].DiveMap
  return false if !divemap

  if pbCheckHMBadges(:DIVE)
    movefinder = pbCheckMove(:DIVE)
    if movefinder
      if Kernel.pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
        pbHMUseMessage(movefinder, :DIVE)
        $game_variables[:DiverID] = movefinder.is_a?(PokeBattle_Pokemon) ? movefinder.personalID : 0
        pbFadeOutIn(99999) {
          $game_temp.player_new_map_id = divemap
          $game_temp.player_new_x = $game_player.x
          $game_temp.player_new_y = $game_player.y
          $game_temp.player_new_direction = $game_player.direction
          Kernel.pbCancelVehicles
          $PokemonGlobal.diving = true
          Kernel.pbUpdateVehicle
          $scene.transfer_player(false)
          $game_map.autoplay
          $game_map.refresh
        }
        return true
      end

      return false
    end
  end

  Kernel.pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
  return false
end

def Kernel.pbSurfacing
  return false if $game_switches[:NotPlayerCharacter]
  return if !$PokemonGlobal.diving

  facingEvent = $game_player.pbFacingEvent
  return false if facingEvent

  divemap = $cache.mapdata[$game_map.map_id].SurfaceMap
  return if !divemap

  if pbCheckHMBadges(:DIVE)
    movefinder = pbCheckMove(:DIVE)
    if movefinder
      if Kernel.pbConfirmMessage(_INTL("Light is filtering down from above. Would you like to use Dive?"))
        pbHMUseMessage(movefinder, :DIVE)
        pbFadeOutIn(99999) {
          $game_temp.player_new_map_id = divemap
          $game_temp.player_new_x = $game_player.x
          $game_temp.player_new_y = $game_player.y
          $game_temp.player_new_direction = $game_player.direction
          Kernel.pbCancelVehicles
          $PokemonGlobal.surfing = true
          Kernel.pbUpdateVehicle
          $game_switches[:Faux_Surf] = true
          $scene.transfer_player(false)
          surfbgm = $cache.metadata[:Surf]
          if surfbgm && $Settings.bike_and_surf_music == 1
            pbCueBGM(surfbgm, 0.5)
          else
            $game_map.autoplayAsCue
          end
          $game_map.refresh
        }
        return true
      end

      return false
    end
  end

  Kernel.pbMessage(_INTL("Light is filtering down from above. A Pokémon may be able to surface here."))
  return false
end

Events.onAction += lambda { |sender, e|
  terrain = $game_player.terrain_tag
  if pbIsDeepWaterTag?(terrain) && !$surfnodive
    Kernel.pbDive
    return
  end
  if $PokemonGlobal.diving
    if DIVINGSURFACEANYWHERE
      Kernel.pbSurfacing
      return
    else
      divemap = $cache.mapdata[$game_map.map_id].SurfaceMap
      return if divemap.nil?

      if pbIsDeepWaterTag?($MapFactory.getTerrainTag(divemap, $game_player.x, $game_player.y))
        Kernel.pbSurfacing
        return
      end
    end
  end
}

HiddenMoveHandlers::CanUseMove.add(:DIVE, lambda { |move, pkmn, showmsg|
  if !pbCheckHMBadges(:DIVE)
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
    return false
  end
  if $PokemonGlobal.diving
    return true if DIVINGSURFACEANYWHERE

    divemap = $cache.mapdata[$game_map.map_id].SurfaceMap
    if !divemap.nil? && pbIsDeepWaterTag?($MapFactory.getTerrainTag(divemap, $game_player.x, $game_player.y))
      return true
    else
      Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
      return false
    end
  end
  if !pbIsDeepWaterTag?($game_player.terrain_tag)
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  if !$cache.mapdata[$game_map.map_id].DiveMap
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:DIVE, lambda { |move, pokemon|
  wasdiving = $PokemonGlobal.diving
  if $PokemonGlobal.diving
    divemap = $cache.mapdata[$game_map.map_id].SurfaceMap
  else
    divemap = $cache.mapdata[$game_map.map_id].DiveMap
  end
  return false if !divemap

  pbHMUseMessage(pokemon, move, onlyanim: true)
  pbFadeOutIn(99999) {
    $game_temp.player_new_map_id = divemap
    $game_temp.player_new_x = $game_player.x
    $game_temp.player_new_y = $game_player.y
    $game_temp.player_new_direction = $game_player.direction
    Kernel.pbCancelVehicles
    if wasdiving
      $PokemonGlobal.surfing = true
    else
      $game_variables[:DiverID] = pokemon.is_a?(PokeBattle_Pokemon) ? pokemon.personalID : 0
      $PokemonGlobal.diving = true
    end
    Kernel.pbUpdateVehicle
    $scene.transfer_player(false)
    $game_map.autoplay
    $game_map.refresh
  }
  return true
})

def Kernel.pbTransferUnderwater(mapid, xcoord, ycoord, direction = $game_player.direction, noFade = false)
  if noFade
    $game_temp.player_new_map_id = mapid
    $game_temp.player_new_x = xcoord
    $game_temp.player_new_y = ycoord
    $game_temp.player_new_direction = direction
    Kernel.pbCancelVehicles
    $PokemonGlobal.diving = true
    Kernel.pbUpdateVehicle
    $scene.transfer_player(false)
    $game_map.autoplay
    $game_map.refresh
  else
    pbFadeOutIn(99999) {
      $game_temp.player_new_map_id = mapid
      $game_temp.player_new_x = xcoord
      $game_temp.player_new_y = ycoord
      $game_temp.player_new_direction = direction
      Kernel.pbCancelVehicles
      $PokemonGlobal.diving = true
      Kernel.pbUpdateVehicle
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
    }
  end
end

#===============================================================================
# Fly
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLY, lambda { |move, pkmn, showmsg|
  if !pbCheckHMBadges(:FLY)
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
    return false
  end
  if Rejuv && inPast?
    Kernel.pbMessage(_INTL("You are unable to fly in the past!")) if showmsg
    next false
  end
  if $game_switches[:NoFlyZone]
    Kernel.pbMessage(_INTL("You can't use this right now!")) if showmsg
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    return false
  end
  if !$cache.mapdata[$game_map.map_id].Outdoor && !(Rejuv && PBStuff::INDOORFLYMAPSREJUV.include?($game_map.map_id))
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:FLY, lambda { |move, pokemon|
  return false unless $PokemonTemp.flydata

  pbHMUseMessage(pokemon, move, onlyanim: true)
  pbExecuteTravelMapChange(:Fly)
  return true
})

#===============================================================================
# Flash
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLASH, lambda { |move, pkmn, showmsg|
  if !pbCheckHMBadges(:FLASH)
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
    return false
  end
  if !$cache.mapdata[$game_map.map_id].DarkMap
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  if $PokemonGlobal.flashUsed
    Kernel.pbMessage(_INTL("This is in use already.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:FLASH, lambda { |move, pokemon|
  darkness = $PokemonTemp.darknessSprite
  return false if !darkness || darkness.disposed?

  pbHMUseMessage(pokemon, move, onlyanim: true)
  $PokemonGlobal.flashUsed = true
  while darkness.radius < 192
    Graphics.update
    Input.update
    pbUpdateSceneMap
    darkness.radius += 4
  end
  return true
})

#===============================================================================
# Teleport
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:TELEPORT, lambda { |move, pkmn, showmsg|
  if !$cache.mapdata[$game_map.map_id].Outdoor
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    return false
  end
  healing = $PokemonGlobal.healingSpot || $cache.metadata[:home]
  if !healing
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::ConfirmUseMove.add(:TELEPORT, lambda { |move, pkmn|
  healing = $PokemonGlobal.healingSpot || $cache.metadata[:home]
  return false if !healing

  mapname = pbGetMapNameFromId(healing[0])
  return Kernel.pbConfirmMessage(_INTL("Use Teleport to return to the last visited healing spot in {1}?", mapname))
})

HiddenMoveHandlers::UseMove.add(:TELEPORT, lambda { |move, pokemon|
  healing = $PokemonGlobal.healingSpot || $cache.metadata[:home]
  return false if !healing

  pbHMUseMessage(pokemon, move, onlyanim: true)
  hookBeforeTeleport
  pbFadeOutIn(99999) {
    Kernel.pbCancelVehicles
    $game_temp.player_new_map_id = healing[0]
    $game_temp.player_new_x = healing[1]
    $game_temp.player_new_y = healing[2]
    $game_temp.player_new_direction = 2
    $game_player.direction_fix = false
    pbToneChangeAll(Tone.new(-255, -255, -255), 0)
    preFadeInChanges
    $scene.transfer_player
    pbToneChangeAll(Tone.new(0, 0, 0), 8)
    $game_map.autoplay
    $game_map.refresh
    $game_variables[:Forced_Field_Effect] = 0
    # for rage/sleep powder
    $game_switches[:Rage_Powder_Vial] = false
    $game_switches[:Sleep_Powder_Vial] = false
  }
  hookAfterTeleport
  pbEraseEscapePoint
  return true
})

def hookBeforeTeleport
  # Intentionally empty, added as a hook for mod overrides since overriding teleport handling isn't easy.
end

def hookAfterTeleport
  # Intentionally empty, added as a hook for mod overrides since overriding teleport handling isn't easy.
end

#===============================================================================
# Dig
#===============================================================================
def pbCanDig?(showmsg: false)
  escape = ($PokemonGlobal.escapePoint rescue nil)
  if !escape || escape == []
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  # Meant to disable using Dig in a sub-area of a dungeon without disabling it in the whole dungeon after coming back out of the sub-area, eg, Rhodochrine Tree inside Rhodochrine Jungle
  if $cache.mapdata[$game_map.map_id].NoDigging
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    return false
  end
  return true
end

def pbDig(escaperope: false)
  escaperope ? hookBeforeEscapeRope : hookBeforeDig
  pbFadeOutIn(99999) {
    Kernel.pbCancelVehicles
    escape = $PokemonGlobal.escapePoint
    $game_temp.player_new_map_id = escape[0]
    $game_temp.player_new_x = escape[1]
    $game_temp.player_new_y = escape[2]
    $game_temp.player_new_direction = escape[3]
    $game_player.direction_fix = false
    pbToneChangeAll(Tone.new(-255, -255, -255), 0)
    preFadeInChanges
    $scene.transfer_player
    pbToneChangeAll(Tone.new(0, 0, 0), 8)
    $game_map.autoplay
    $game_map.refresh
    if pbIsWaterTag?(Kernel.pbFacingTerrainTag) && !$PokemonGlobal.surfing
      $PokemonEncounters.clearStepCount
      $PokemonGlobal.surfing = true
      $game_switches[:Faux_Surf] = true
      $game_map.refresh
      Kernel.pbUpdateVehicle
    end
    if pbIsLavaTag?(Kernel.pbFacingTerrainTag) && !$PokemonGlobal.lavasurfing
      $PokemonEncounters.clearStepCount
      $PokemonGlobal.lavasurfing = true
      $game_switches[:Faux_Surf] = true
      $game_map.refresh
      Kernel.pbUpdateVehicle
    end
    $game_variables[:Forced_Field_Effect] = 0
    $game_variables[:Forced_BaseField] = 0
    $game_variables[:AltFieldGraphic] = 0
  }
  escaperope ? hookAfterEscapeRope : hookAfterDig
  pbEraseEscapePoint
  terrain = Kernel.pbFacingTerrainTag
  if (pbIsWaterTag?(terrain) && !$PokemonGlobal.surfing) ||
     (pbIsLavaTag?(terrain) && !$PokemonGlobal.lavasurfing)
    pbStartSurfing
  end
  return true
end

def pbFakeDig
  pbDig if pbCanDig?
end

HiddenMoveHandlers::CanUseMove.add(:DIG, lambda { |move, pkmn, showmsg|
  return pbCanDig?(showmsg: showmsg)
})

HiddenMoveHandlers::ConfirmUseMove.add(:DIG, lambda { |move, pkmn|
  mapname = pbGetMapNameFromId($PokemonGlobal.escapePoint[0])
  return Kernel.pbConfirmMessage(_INTL("Use Dig to escape from here and return to {1}?", mapname))
})

HiddenMoveHandlers::UseMove.add(:DIG, lambda { |move, pokemon|
  pbHMUseMessage(pokemon, move, onlyanim: true)
  return pbDig
})

def hookBeforeDig
  # Intentionally empty, added as a hook for mod overrides since overriding dig handling isn't easy.
end

def hookAfterDig
  # Intentionally empty, added as a hook for mod overrides since overriding dig handling isn't easy.
end

#===============================================================================
# Sweet Scent
#===============================================================================
def pbSweetScent
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  count = 0
  viewport.color.alpha -= 10
  begin
    if viewport.color.alpha < 128 && count == 0
      viewport.color.red = 255
      viewport.color.green = 0
      viewport.color.blue = 0
      viewport.color.alpha += 8
    else
      count += 1
      if count > 10
        viewport.color.alpha -= 8
      end
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end until viewport.color.alpha <= 0
  viewport.dispose
  enctype = $PokemonEncounters.pbEncounterType
  if enctype < 0 || !$PokemonEncounters.isEncounterPossibleHere?() || !pbEncounter(enctype)
    Kernel.pbMessage(_INTL("There appears to be nothing here..."))
  end
end

HiddenMoveHandlers::CanUseMove.add(:SWEETSCENT, lambda { |move, pkmn, showmsg|
  return true
})

HiddenMoveHandlers::UseMove.add(:SWEETSCENT, lambda { |move, pokemon|
  pbHMUseMessage(pokemon, move, onlyanim: true)
  pbSweetScent
  return true
})

#===============================================================================
# General functions
#===============================================================================

def Kernel.pbCanUseHiddenMove?(pkmn, move, showmessage: false)
  return HiddenMoveHandlers.triggerCanUseMove(move, pkmn, showmessage)
end

def Kernel.pbConfirmUseHiddenMove?(pkmn, move)
  return HiddenMoveHandlers.triggerConfirmUseMove(move, pkmn)
end

def Kernel.pbUseHiddenMove(pokemon, move)
  return HiddenMoveHandlers.triggerUseMove(move, pokemon)
end

def Kernel.pbHiddenMoveEvent
  Events.onAction.trigger(nil)
end

# Play BGS while over a dive spot
def playWeatherOrDiveBGS
  return unless Reborn

  blindstep = $game_switches && $game_switches[:Blindstep]

  if blindstep
    if pbIsDeepWaterTag?($game_player.terrain_tag)
      pbBGSPlay("Ambient Depth")
      return
    end
    if $PokemonGlobal.diving
      divemap = $cache.mapdata[$game_map.map_id].SurfaceMap
      if !divemap.nil? && pbIsDeepWaterTag?($MapFactory.getTerrainTag(divemap, $game_player.x, $game_player.y))
        pbBGSPlay("Ambient Light")
        return
      end
    end
  end

  weatherBGS = nil
  case true
    when $game_screen&.isThunderstorm? then weatherBGS = "Weather- Storm"
    when $game_screen&.isRaining? then weatherBGS = "Weather- Rain"
    when $game_screen&.isWindy? then weatherBGS = "Weather- Wind"
    when blindstep && $game_screen.isHailing? then weatherBGS = "Weather- Snow (Blindstep)"
    when blindstep && $game_screen.isSandstorm? then weatherBGS = "Weather- Sandstorm (Blindstep)"
    when blindstep && $game_screen.isSunny? then weatherBGS = "Weather- Sun (Blindstep)"
  end

  if weatherBGS
    pbBGSPlay(weatherBGS)
  else
    pbBGSStop(0.5)
  end

  playingBGS = $game_system.getPlayingBGS
  if !playingBGS.nil? && ["Ambient Light", "Ambient Depth"].include?(playingBGS.name)
    if $game_map.map.autoplay_bgs
      pbBGSPlay($game_map.bgs)
    else
      pbBGSStop(0.5)
    end
  end
end

Events.onStepTaken += proc {
  playWeatherOrDiveBGS
}

def pbCheckHMBadges(move)
  return true if GAME_VERSION == 'dev' && $DEBUG && Input.press?(Input::CTRL)
  badge = HM_TO_BADGE[move]
  return HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges >= badge : $Trainer.badges[badge]
end

def pbHMUseMessage(user, move, message = nil, onlyanim: false)
  message = _INTL("{1} used {2}!") if message.nil?
  finalmsg = case true
    when user.is_a?(PokeBattle_Pokemon)
      _INTL(message, user.name, getMoveName(move))
    when user == :Trainer
      # triggered using a Golden item (Rejuv)
      _INTL(message, $Trainer.name, getItemName(PBStuff::HMTOGOLDITEM[move], :the))
    else
      # triggered by Debug + Ctrl (user == :Debug)
      _INTL("(Debug)") + " " + _INTL(message, $Trainer.name, getMoveName(move))
  end

  Kernel.pbMessage(finalmsg) unless onlyanim
  anim = pbHiddenMoveAnimation(user)
  Kernel.pbMessage(finalmsg) if onlyanim && !anim

  if move == :STRENGTH
    name = user.is_a?(PokeBattle_Pokemon) ? user.name : $Trainer.name
    Kernel.pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!", name))
  end
end

def pbSelectFlyLocation
  region = getMapPosition($game_map.map_id)[0]
  if $game_switches[:Blindstep]
    return Blindstep.flyMenu
  else
    scene = PokemonRegionMapScene.new(region, false)
    screen = PokemonRegionMap.new(scene)
    return screen.pbStartFlyScreen
  end
end

def pbExecuteTravelMapChange(mode)
  return unless $PokemonTemp.flydata

  $game_system.bgs_stop
  $game_screen.weather(0, 0, 0)
  pbFlyAnimation if mode == :Fly
  pbSEPlay("PRSFX- Fly2")

  pbFadeOutIn(99999) {
    Kernel.pbCancelVehicles
    $game_temp.player_new_map_id = $PokemonTemp.flydata[0]
    $game_temp.player_new_x = $PokemonTemp.flydata[1]
    $game_temp.player_new_y = $PokemonTemp.flydata[2]
    $PokemonTemp.flydata = nil
    $game_temp.player_new_direction = 2
    $game_player.direction_fix = false
    pbToneChangeAll(Tone.new(-255, -255, -255), 0)
    preFadeInChanges
    $scene.transfer_player
    pbToneChangeAll(Tone.new(0, 0, 0), 8)
    $game_map.autoplay
    $game_map.refresh
    $game_variables[:Forced_Field_Effect] = 0
    # for rage/sleep powder
    $game_switches[:Rage_Powder_Vial] = false
    $game_switches[:Sleep_Powder_Vial] = false
  }

  pbFlyAnimation(true) if mode == :Fly
  pbEraseEscapePoint
  # $game_screen.setWeather
end

# Method is used for transport methods between maps, so basically Fly/Dig/Teleport
def preFadeInChanges
  Kernel.pbDismountTauros
end

#===============================================================================
# Smart Travel
#===============================================================================

def smartTravel()
  return if $game_system.menu_disabled # Used in certain quick time events and character switch scenarios
  return if $game_switches[:NotPlayerCharacter] # Disable in character switch scenarios

  # Flash
  user = pbCheckMove(:FLASH)
  if user && Kernel.pbCanUseHiddenMove?(user, :FLASH)
    Kernel.pbUseHiddenMove(user, :FLASH)
    return
  end

  # Fly and Bus
  flyuser = pbCheckMove(:FLY)
  flyuser = nil unless Kernel.pbCanUseHiddenMove?(user, :FLY)
  busmap = Desolation ? pbGetBattleBusMap : nil

  if flyuser && busmap
    cmd = Kernel.pbMessage(_INTL("Which mode of travel would you like to use?"), [_INTL("Fly"), _INTL("Bus")], -1)
    return if cmd == -1

    cmd == 0 ? (busmap = nil) : (flyuser = nil)
  end

  if flyuser
    ret = pbSelectFlyLocation()
    if ret
      $PokemonTemp.flydata = ret
      Kernel.pbUseHiddenMove(flyuser, :FLY)
    end
    return
  end
  if busmap
    ret = pbSelectBusLocation(busmap)
    if ret
      $PokemonTemp.flydata = ret
      pbUseBattleBus
    end
    return
  end

  # Dig
  user = pbCheckMove(:DIG)
  if user && Kernel.pbCanUseHiddenMove?(user, :DIG)
    if Kernel.pbConfirmUseHiddenMove?(user, :DIG)
      Kernel.pbUseHiddenMove(user, :DIG)
    end
    return
  end

  # Escape Rope
  if pbCanDig? && $PokemonBag.pbQuantity(:ESCAPEROPE) > 0
    mapname = pbGetMapNameFromId($PokemonGlobal.escapePoint[0])
    if Kernel.pbConfirmMessage(_INTL("Use {1} to return to {2}?", getItemName(:ESCAPEROPE, :a), mapname))
      $PokemonBag.pbDeleteItem(:ESCAPEROPE)
      ItemHandlers.triggerUseInField(:ESCAPEROPE)
    end
    return
  end

  if Reborn
    # Teleport
    user = pbCheckMove(:TELEPORT)
    if user && Kernel.pbCanUseHiddenMove?(user, :TELEPORT)
      if Kernel.pbConfirmUseHiddenMove?(user, :TELEPORT)
        Kernel.pbUseHiddenMove(user, :TELEPORT)
      end
      return
    end
  end

  Kernel.pbMessage(_INTL("No Smart Travel method available."))
end

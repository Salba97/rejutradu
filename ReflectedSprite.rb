class ReflectedSprite
  attr_accessor :visible
  attr_accessor :event

  def initialize(sprite, event, viewport = nil)
    @rsprite = sprite
    @sprite = nil
    @event = event
    @disposed = false
    @viewport = viewport
    update
  end

  def dispose
    if !@disposed
      @sprite.dispose if @sprite
      @sprite = nil
      @disposed = true
    end
  end

  def disposed?
    @disposed
  end

  def update
    return if disposed?

    currentY = @event.real_y.to_i / 128
    limit = @rsprite.src_rect.height
    rect_height = limit
    shouldShow = false
    # Clipping at Y
    i = 0
    while i < rect_height + 32
      nextY = currentY + 1 + (i >> 5)
      terrain_tag = @event.map.terrain_tag(@event.x, nextY)
      if !pbIsReflectiveTag?(terrain_tag) # The terrain types that will have reflections in them
        limit = ((nextY * 128) - @event.map.display_y + 3).to_i / 4
        limit -= @rsprite.y
        break
      else
        shouldShow = true
      end
      i += Game_Map::TILEHEIGHT
    end
    shouldShow = false if !visible
    if limit > 0 && shouldShow
      # Just-in-time creation of sprite
      if !@sprite
        @sprite = Sprite.new(@viewport)
      end
    else
      # Just-in-time disposal of sprite
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end
    if @sprite
      x = @rsprite.x - @rsprite.ox
      y = @rsprite.y - @rsprite.oy

      # Arbitrary shift reflection up if on still water, only for player while surfing
      if @event == $game_player && ($PokemonGlobal.surfing || $PokemonGlobal.diving)
        #terrain_tag = @event.map.terrain_tag(@event.x, @event.y)
        #if [PBTerrain::StillDeepWater, PBTerrain::StillWater, PBTerrain::Glass].include?(terrain_tag)
        y -= 34
        limit += 19
        #end
      end

      # Counter sprites with offset
      if @rsprite.character.character_name[/offset/]
        y -= 32
        limit += 16
      end

      width = @rsprite.src_rect.width
      height = rect_height
      frame = (Graphics.frame_count % 40) / 10

      # Not sure why this code was commented out but it seems to work better.
      @sprite.x = x + width / 2
      @sprite.y = y + height + height / 2
      @sprite.ox = width / 2
      @sprite.oy = height / 2
      # @sprite.z = @rsprite.z - 1 # below the player

      # This code was here instead of the code above. No clue who added it and why.
      # The reflection position was very odd with this code, especially for the player.
      # @sprite.x = @rsprite.x
      # @sprite.y = @rsprite.y - height / 6
      # @sprite.ox = @rsprite.ox
      # @sprite.oy = @rsprite.oy
      # Okay this line makes more sense to me than @rsprite.z - 1
      @sprite.z = 1 # Don't reflect in cliffs and stuff

      @sprite.angle = 180.0
      @sprite.zoom_x = @rsprite.zoom_x
      @sprite.zoom_y = @rsprite.zoom_y
      if @event.map.terrain_tag(@event.x, @event.y + 1) != PBTerrain::Glass
        if frame == 1
          @sprite.zoom_x *= 1.05
        elsif frame == 2
          @sprite.zoom_x *= 1.1
        elsif frame == 3
          @sprite.zoom_x *= 1.05
        end
      end
      @sprite.mirror = true
      @sprite.bitmap = @rsprite.bitmap
      @sprite.tone = @rsprite.tone
      if @event == $game_player && $PokemonGlobal.diving && ADJUST_DIVE_SPRITE
        @sprite.color.set(-200, -156, -111, 96)
      else
        @sprite.color.set(248, 248, 248, 96)
      end
      @sprite.opacity = @rsprite.opacity * 0.4
      @sprite.src_rect = @rsprite.src_rect
      if limit < rect_height
        diff = rect_height - limit
        @sprite.src_rect.y += diff
        @sprite.src_rect.height = limit
        @sprite.y -= diff
      end
    end
  end
end

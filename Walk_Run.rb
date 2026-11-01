class Game_Player
  def fullPattern
    case self.direction
      when 2
        return self.pattern
      when 4
        return 4 + self.pattern
      when 6
        return 8 + self.pattern
      when 8
        return 12 + self.pattern
      else
        return 0
    end
  end

  def setDefaultCharName(chname, pattern)
    return if pattern < 0 || pattern >= 16

    @defaultCharacterName = chname
    @direction = [2, 4, 6, 8][pattern / 4]
    @pattern = pattern % 4
  end

  def pbCanRun?
    return false if $game_temp.menu_calling

    terrain = pbGetTerrainTag
    autorunning = $Settings.autorunning == 0 ? true : false

    # Flip autorunning while Shift is pressed.
    if Input.shiftKeyPressed?
      autorunning = !autorunning
    end

    return autorunning && !pbMapInterpreterRunning? && !@move_route_forcing &&
           $PokemonGlobal && $PokemonGlobal.runningShoes &&
           !$PokemonGlobal.diving && !$PokemonGlobal.surfing && !$PokemonGlobal.lavasurfing &&
           !$PokemonGlobal.bicycle && !$game_switches[:Riding_Tauros] &&
           !$game_temp.in_battle && !$game_temp.message_window_showing &&
           terrain != PBTerrain::TallGrass && terrain != PBTerrain::Ice
  end

  def pbIsRunning?
    return @lastGraphic == :run
    # return !moving? && !@move_route_forcing && pbCanRun?
  end

  def character_name
    if !@defaultCharacterName
      @defaultCharacterName = ""
    end
    if @defaultCharacterName != ""
      return @defaultCharacterName
    end

    if !moving? && !@move_route_forcing && !$game_temp.ready_items_menu
      if $PokemonGlobal.playerID >= 0 && !$PokemonGlobal.bicycle && !$PokemonGlobal.diving && !$PokemonGlobal.surfing && !$PokemonGlobal.lavasurfing
        input_dir4 = Input.dir4
        if input_dir4 != 0 && passable?(@x, @y, input_dir4) && pbCanRun? && !Input.press?(Input::ALT)
          # Display running character sprite
          unless @lastGraphic == :run
            @character_name = pbGetPlayerCharset(:run)
            @lastGraphic = :run
          end
        else
          # Display normal character sprite
          unless @lastGraphic == :walk
            @character_name = pbGetPlayerCharset(:walk)
            @lastGraphic = :walk
          end
        end
      end
    end
    return @character_name
  end

  alias update_old update unless method_defined?(:update_old)

  def update
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
    update_old
  end
end

Field_Note_MainMenu_Y = 64
Field_Note_BG_Y = 48
Field_Note_Window_Y = 66

class Scene_Pokegear
  BTN_BASEYPOS = 206
  def setup
    @buttonnames = []
    @buttons = []
    addButton("FieldNotes", _INTL("Notas de campo")) if $game_switches[:Field_Notes]
    addButton("Map", _INTL("Mapa"))
    addButton("Jukebox", _INTL("Jukebox"))
    addButton("Achievements", _INTL("Logros"))
    addButton("Rift Dex", _INTL("Rift Dex")) if $game_switches[:RiftDex]
    addButton("Spice Scent", _INTL("Perfumes"))
    if $Trainer.tutorlist && ($game_switches[:NotPlayerCharacter] == false || $game_switches[:InterceptorsWish] == true)
      addButton("Move Tutor", _INTL("Tutor de movimientos"))
    end
  end

  def default_index
    case @menu_index
      when :notes then return @buttonnames.index("FieldNotes")
      when :tutor then return @buttonnames.index("Move Tutor")
      when :map then return @buttonnames.index("Map")
      when :jukebox then return @buttonnames.index("Jukebox")
      when :achievements then return @buttonnames.index("Achievements")
      when :rift then return @buttonnames.index("Rift Dex")
      when :scent then return @buttonnames.index("Spice Scent")
      else return @menu_index.is_a?(Integer) ? @menu_index : 0
    end
  end

  def checkChoice
    selectedButtonIndex = @sprites["command_window"].index
    selectedButtonName = @buttonnames[selectedButtonIndex]
    case selectedButtonName
      when "Map"
        region = getMapPosition($game_map.map_id)[0]
        pbShowMap(region, false)
      when "Jukebox"
        $scene = Scene_Jukebox.new
      when "Achievements"
        scene = PokemonAchievementsScene.new
        screen = PokemonAchievements.new(scene)
        pbFadeOutIn(99999) {
          screen.pbStartScreen
        }
      when "FieldNotes"
        $scene = Scene_FieldNotes.new
      when "Rift Dex"
        $scene = Scene_RiftDex.new
      when "Spice Scent"
        $scene = Scene_EncounterRate.new
      when "Move Tutor"
        pbTryUseMoveTutorApp
    end
  end
end
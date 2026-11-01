class Scene_DebugIntro
  def main
    Graphics.transition(0)
    ThreadLoader.awaitScripts
    sscene = PokemonLoadScene.new
    sscreen = PokemonLoad.new(sscene)
    sscreen.pbStartLoadScreen
    Graphics.freeze
  end
end

def pbCallTitle # :nodoc:
  if $DEBUG
    return Scene_DebugIntro.new
  else
    return Scene_Intro.new(['intro1'], "sp")
  end
end

def mainFunction # :nodoc:
  pbCriticalCode { mainFunctionDebug }
  return 1
end

def mainFunctionDebug # :nodoc:
  begin
    startup
    $game_system = Game_System.new
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    while $scene != nil
      $scene.main
    end
    Graphics.transition(2)
  rescue Hangup
    pbEmergencySave
    raise
  end
end

def mainFunctionNoGraphics
  $game_system = Game_System.new
  $game_switches       = Game_Switches.new
  $game_variables      = Game_Variables.new
  $PokemonTemp   = PokemonTemp.new
  $game_temp     = Game_Temp.new
  $game_system   = Game_System.new
  $Trainer = PokeBattle_Trainer.new("deez nutz", 5)
  $game_screen         = Game_Screen.new
  $game_player         = Game_Player.new
  $PokemonGlobal       = PokemonGlobalMetadata.new
  $PokemonBag = PokemonBag.new
  $testing = true
  File.open("Scripts/Battle_TestEnvironment.rb") { |f|
    eval(f.read)
  }
  # battle=pbListScreenPop(_INTL("SINGLE TRAINER"),TrainerBattleLister.new(0,false))
  # save_data(battle,"battle") battleTowerRanking dumpbtmons
  battleTowerRanking
end

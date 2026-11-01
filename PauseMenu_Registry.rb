# Vanilla Pause Menu Registry
# Context Procs take: |scene, screen|

MenuHandlers.add(:pause_menu, :pokedex,
  name:      proc { _INTL("Pokédex") },
  order:     10,
  condition: proc { |scene, screen| $Trainer.pokedex.canViewDex && pbViablePokedexes.length > 0 },
  effect:    proc { |scene, screen|
    pbFadeOutIn(99999) {
      scene_pokedex = PokemonPokedexScene.new
      screen_pokedex = PokemonPokedex.new(scene_pokedex)
      if pbViablePokedexes.length > 1
        screen_pokedex.pbStartRegionScreen
      else
        screen_pokedex.pbStartPokedexScreen
      end
      scene.pbRefresh
    }
    next nil
  }
)

MenuHandlers.add(:pause_menu, :pokemon,
  name:      proc { _INTL("Pokémon") },
  order:     20,
  condition: proc { |scene, screen| $Trainer.party.length > 0 && !hidePlayerPossessions? },
  effect:    proc { |scene, screen|
    sscene = PokemonScreen_Scene.new
    sscreen = PokemonScreen.new(sscene, $Trainer.party)
    hiddenmove = nil
    pbFadeOutIn(99999) {
      hiddenmove = sscreen.pbPokemonScreen
      if hiddenmove
        scene.pbEndScene
      else
        scene.pbRefresh
      end
    }
    if hiddenmove
      Kernel.pbUseHiddenMove(hiddenmove[0], hiddenmove[1])
      next :break
    end
    next nil
  }
)

MenuHandlers.add(:pause_menu, :bag,
  name:      proc { _INTL("Bag") },
  order:     30,
  condition: proc { |scene, screen| !hidePlayerPossessions? },
  effect:    proc { |scene, screen|
    item = nil
    scene_bag = PokemonBag_Scene.new
    screen_bag = PokemonBagScreen.new(scene_bag, $PokemonBag)
    pbFadeOutIn(99999) {
      item = screen_bag.pbStartScreen
      if item
        scene.pbEndScene
      else
        scene.pbRefresh
      end
    }
    if item
      Kernel.pbUseKeyItemInField(item)
      next :break
    end
    next nil
  }
)

MenuHandlers.add(:pause_menu, :pokegear,
  name:      proc { Rejuv ? _INTL("CyberNav") : _INTL("Pokégear") },
  order:     40,
  condition: proc { |scene, screen| $Trainer.pokegear && !hidePlayerPossessions? },
  effect:    proc { |scene, screen|
    pbLoadRpgxpScene(Scene_Pokegear.new)
    if $UsingBattleBus
      $UsingBattleBus = false
      scene.pbEndScene
      pbUseBattleBus
      next :break
    end
    Graphics.update unless Rejuv # What does this do?
    next nil
  }
)

if Rejuv # More optimal than using 'condition'
  MenuHandlers.add(:pause_menu, :quests_rejuv,
    name:      proc { _INTL("Quests") },
    order:     45,
    effect:    proc { |scene, screen|
      pbPlayDecisionSE
      pbFadeOutIn(99999) {
        pbViewQuests
        scene.pbRefresh
      }
      next nil
    }
  )
end

MenuHandlers.add(:pause_menu, :trainer,
  name:      proc { $Trainer.name },
  order:     50,
  condition: proc { |scene, screen| $Trainer.badges },
  effect:    proc { |scene, screen|
    PBDebug.logonerr {
      scene_trainer = PokemonTrainerCardScene.new
      screen_trainer = PokemonTrainerCard.new(scene_trainer)
      pbFadeOutIn(99999) {
        screen_trainer.pbStartScreen
        scene.pbRefresh
      }
    }
    next nil
  }
)

MenuHandlers.add(:pause_menu, :quit_safari,
  name:      proc { _INTL("Quit") },
  order:     60,
  condition: proc { |scene, screen| pbInSafari? },
  effect:    proc { |scene, screen|
    scene.pbHideMenu
    if Kernel.pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
      scene.pbEndScene
      pbSafariState.decision = 1
      pbSafariState.pbGoToStart
      next :break
    else
      scene.pbShowMenu
      next nil
    end
  }
)

MenuHandlers.add(:pause_menu, :save,
  name:      proc { _INTL("Save") },
  order:     60,
  condition: proc { |scene, screen| !pbInSafari? && !$game_system&.save_disabled },
  effect:    proc { |scene, screen|
    scene.pbHideMenu
    ret = pbSaveScreen
    if ret == :Success
      scene.pbEndScene
      next :break
    else
      scene.pbShowMenu
      next nil
    end
  }
)

MenuHandlers.add(:pause_menu, :options,
  name:      proc { _INTL("Options") },
  order:     70,
  effect:    proc { |scene, screen|
    opt_scene = PokemonOptionScene.new
    opt_screen = PokemonOption.new(opt_scene)
    pbFadeOutIn(99999) {
      opt_screen.pbStartScreen
      ["cmdwindow", "infowindow", "helpwindow"].each { |window|
        # In case windowskin was changed
        scene.sprites[window].setSkin(MessageConfig.pbGetSystemFrame())
        scene.sprites[window].setDefaultTextColors
      }
      pbUpdateSceneMap
      scene.pbRefresh
    }
    $updateFLHUD = true
    next nil
  }
)

MenuHandlers.add(:pause_menu, :controls,
  name:      proc { _INTL("Controls") },
  order:     80,
  effect:    proc { |scene, screen|
    controlsDialogue
    next nil
  }
)

MenuHandlers.add(:pause_menu, :debug,
  name:      proc { _INTL("Debug") },
  order:     90,
  condition: proc { |scene, screen| $DEBUG || $game_switches[:MiniDebug_Pass] },
  effect:    proc { |scene, screen|
    pbFadeOutIn(99999) {
      pbDebugMenu
      scene.pbRefresh
    }
    next nil
  }
)

MenuHandlers.add(:pause_menu, :quit_game,
  name:      proc { _INTL("Quit Game") },
  order:     100,
  effect:    proc { |scene, screen|
    scene.pbHideMenu
    if Kernel.pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
      if !$game_system&.save_disabled
        ret = pbSaveScreen(cancancel: false)
        next nil if ret == :Failure
      else
        confirm = Kernel.pbConfirmMessage(_INTL("\\c[2]You can not save the game right now. Quit anyway?"))
        next nil if !confirm
      end
      scene.pbEndScene
      $scene = nil
      exit
    else
      scene.pbShowMenu
      next nil
    end
  }
)

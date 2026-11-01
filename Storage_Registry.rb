# Top-Level PC Menu Registry
MenuHandlers.add(:pc_menu, :storage_system,
  name:      proc { _INTL("{1}'s PC", pbGetStorageCreator) },
  order:     10,
  effect:    proc {
    Kernel.pbMessage(_INTL("\\se[accesspc]The Pokémon Storage System was opened."))
    loop do
      # Build the inner storage menu dynamically
      commands, helptexts, actions = MenuHandlers.build(:storage_system_menu)

      # Pass the dynamic arrays to the vanilla UI method
      command = Kernel.pbShowCommandsWithHelp(nil, commands, helptexts, -1)

      break if command < 0 || command >= actions.length

      should_break = actions[command].call
      break if should_break == :break
    end
    next nil
  }
)

MenuHandlers.add(:pc_menu, :trainer_pc,
  name:      proc { _INTL("{1}'s PC", $Trainer.name) },
  order:     20,
  condition: proc { false }, # Hides this option
  effect:    proc {
    Kernel.pbMessage(_INTL("\\se[accesspc]Accessed {1}'s PC.", $Trainer.name))
    pbTrainerPCMenu
    next nil
  }
)

MenuHandlers.add(:pc_menu, :log_off,
  name:      proc { _INTL("Log Off") },
  order:     nil,
  effect:    proc {
    next :break
  }
)

# Storage System Inner Menu Registry
MenuHandlers.add(:storage_system_menu, :move,
  name:      proc { _INTL("Move Pokémon") },
  helptext:  proc { _INTL("Organize the Pokémon in Boxes and in your party.") },
  order:     10,
  effect:    proc {
    pbFadeOutIn(99999) {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.pbStartScreen(0)
    }
    next nil
  }
)

MenuHandlers.add(:storage_system_menu, :deposit,
  name:      proc { _INTL("Deposit Pokémon") },
  helptext:  proc { _INTL("Store Pokémon in your party in Boxes.") },
  order:     20,
  effect:    proc {
    count = $PokemonStorage.party.count { |p| p && p.hp > 0 }
    if count <= 1
      Kernel.pbMessage(_INTL("Can't deposit the last Pokémon!"))
    else
      pbFadeOutIn(99999) {
        scene = PokemonStorageScene.new
        screen = PokemonStorageScreen.new(scene, $PokemonStorage)
        screen.pbStartScreen(1)
      }
    end
    next nil
  }
)

MenuHandlers.add(:storage_system_menu, :withdraw,
  name:      proc { _INTL("Withdraw Pokémon") },
  helptext:  proc { _INTL("Move Pokémon stored in Boxes to your party.") },
  order:     30,
  effect:    proc {
    if $PokemonStorage.party.length >= 6
      Kernel.pbMessage(_INTL("Your party is full!"))
    else
      pbFadeOutIn(99999) {
        scene = PokemonStorageScene.new
        screen = PokemonStorageScreen.new(scene, $PokemonStorage)
        screen.pbStartScreen(2)
      }
    end
    next nil
  }
)

MenuHandlers.add(:storage_system_menu, :exit,
  name:      proc { _INTL("See ya!") },
  helptext:  proc { _INTL("Return to the previous menu.") },
  order:     nil,
  effect:    proc {
    next :break
  }
)

# Box Commands Menu Registry
# Context Procs take: |screen, mode|
MenuHandlers.add(:box_commands_menu, :jump,
  name:      proc { _INTL("Jump") },
  order:     10,
  effect:    proc { |screen, mode|
    destbox = screen.scene.pbChooseBox(_INTL("Jump to which Box?"))
    if destbox >= 0
      screen.scene.pbJumpToBox(destbox)
    end
  }
)

MenuHandlers.add(:box_commands_menu, :wallpaper,
  name:      proc { _INTL("Wallpaper") },
  order:     20,
  effect:    proc { |screen, mode|
    commands = boxNames
    wpaper = screen.pbShowCommands(_INTL("Pick the wallpaper."), commands)
    if wpaper >= 0
      screen.scene.pbChangeBackground(wpaper)
    end
  }
)

MenuHandlers.add(:box_commands_menu, :name,
  name:      proc { _INTL("Name") },
  order:     30,
  effect:    proc { |screen, mode|
    screen.scene.pbBoxName()
  }
)

MenuHandlers.add(:box_commands_menu, :select_all,
  name:      proc { |screen, mode| screen.currentBoxFullySelected?() ? _INTL("Deselect All") : _INTL("Select All") },
  order:     40,
  condition: proc { |screen, mode| mode == 0 },
  effect:    proc { |screen, mode|
    if screen.pbHeldPokemon
      Kernel.pbMessage(_INTL("Can't Multi-Move while holding a Pokémon."))
    else
      screen.selectAll()
    end
  }
)

MenuHandlers.add(:box_commands_menu, :find,
  name:      proc { _INTL("Search") },
  order:     50,
  effect:    proc { |screen, mode|
    screen.pbFindPokemon
  }
)

MenuHandlers.add(:box_commands_menu, :sort_box,
  name:      proc { _INTL("Sort Box") },
  order:     60,
  effect:    proc { |screen, mode|
    ret = screen.pbSortPokemon()
    if ret == -2
      screen.pbDisplay(_INTL("{1} is empty.", $PokemonStorage[$PokemonStorage.currentBox].name))
    elsif ret != -1
      screen.scene.pbHardRefresh
      screen.pbDisplay(_INTL("{1} was sorted.", $PokemonStorage[$PokemonStorage.currentBox].name))
    end
  }
)

MenuHandlers.add(:box_commands_menu, :sort_pc,
  name:      proc { _INTL("Sort PC") },
  order:     70,
  effect:    proc { |screen, mode|
    minbox = screen.scene.pbChooseBox(_INTL("Which box to sort first?"))
    next if minbox == -1

    maxbox = screen.scene.pbChooseBox(_INTL("Which box to sort last?"))
    next if maxbox == -1

    ret = screen.pbSortPokemon(minbox, maxbox)
    if ret == -2
      if minbox == maxbox
        screen.pbDisplay(_INTL("{1} is empty.", $PokemonStorage[minbox].name))
      else
        screen.pbDisplay(_INTL("{1} to {2} are empty.", $PokemonStorage[minbox].name, $PokemonStorage[maxbox].name))
      end
    elsif ret != -1
      screen.scene.pbHardRefresh
      if minbox == maxbox
        screen.pbDisplay(_INTL("{1} was sorted.", $PokemonStorage[minbox].name))
      else
        screen.pbDisplay(_INTL("{1} to {2} were sorted.", $PokemonStorage[minbox].name, $PokemonStorage[maxbox].name))
      end
    end
  }
)

MenuHandlers.add(:box_commands_menu, :set_default,
  name:      proc { |screen, mode| $PokemonStorage.defaultBox == $PokemonStorage.currentBox ? _INTL("Unset Default") : _INTL("Set Default") },
  order:     80,
  effect:    proc { |screen, mode|
    if $PokemonStorage.defaultBox == $PokemonStorage.currentBox
      $PokemonStorage.defaultBox = nil
      screen.pbDisplay(_INTL("{1} is no longer default for new Pokémon.", $PokemonStorage[$PokemonStorage.currentBox].name))
    else
      $PokemonStorage.defaultBox = $PokemonStorage.currentBox
      screen.pbDisplay(_INTL("{1} was set as default for new Pokémon.", $PokemonStorage[$PokemonStorage.currentBox].name))
    end
  }
)

MenuHandlers.add(:box_commands_menu, :cancel,
  name:      proc { _INTL("Cancel") },
  order:     nil,
  effect:    proc { |screen, mode|
    next nil
  }
)

# Pokémon Context Menu Registry
# Context Procs take: |screen, mode, selected, pokemon, heldpoke|
MenuHandlers.add(:storage_mon_menu, :select,
  name:      proc { _INTL("Select") },
  order:     10,
  condition: proc { |screen, mode, selected, pokemon, heldpoke| mode == -1 && pokemon },
  effect:    proc { |screen, mode, selected, pokemon, heldpoke|
    next :break_with_selected
  }
)

MenuHandlers.add(:storage_mon_menu, :move_shift_place,
  name:      proc { |screen, mode, selected, pokemon, heldpoke|
    if heldpoke
      pokemon ? _INTL("Shift") : _INTL("Place")
    elsif mode == 0
      _INTL("Move")
    else
      selected[0] == -1 ? _INTL("Store") : _INTL("Withdraw")
    end
  },
  order:     20,
  condition: proc { |screen, mode, selected, pokemon, heldpoke| pokemon || heldpoke },
  effect:    proc { |screen, mode, selected, pokemon, heldpoke|
    if heldpoke && pokemon
      screen.pbSwap(selected)
    elsif heldpoke
      screen.pbPlace(selected)
    elsif mode == 0
      screen.pbHold(selected)
    else
      screen.pbStoreOrWithdraw(selected, heldpoke)
    end
    next nil
  }
)

MenuHandlers.add(:storage_mon_menu, :summary,
  name:      proc { _INTL("Summary") },
  order:     30,
  condition: proc { |screen, mode, selected, pokemon, heldpoke| pokemon || heldpoke },
  effect:    proc { |screen, mode, selected, pokemon, heldpoke|
    screen.pbSummary(selected, heldpoke)
    next nil
  }
)

MenuHandlers.add(:storage_mon_menu, :multi_move,
  name:      proc { _INTL("Multi-Move") },
  order:     40,
  condition: proc { |screen, mode, selected, pokemon, heldpoke| mode == 0 && selected[0] != -1 },
  effect:    proc { |screen, mode, selected, pokemon, heldpoke|
    if selected[0] >= 0 && !heldpoke
      screen.pbHold(selected, true)
    elsif heldpoke
      Kernel.pbMessage(_INTL("Can't Multi-Move while holding a Pokémon."))
    else
      Kernel.pbMessage(_INTL("Can't Multi-Move a Pokémon from your party."))
    end
    next nil
  }
)

MenuHandlers.add(:storage_mon_menu, :store_withdraw,
  name:      proc { |screen, mode, selected, pokemon, heldpoke| selected[0] == -1 ? _INTL("Store") : _INTL("Withdraw") },
  order:     50,
  condition: proc { |screen, mode, selected, pokemon, heldpoke| mode == 0 && (pokemon || heldpoke) },
  effect:    proc { |screen, mode, selected, pokemon, heldpoke|
    screen.pbStoreOrWithdraw(selected, heldpoke)
    next nil
  }
)

MenuHandlers.add(:storage_mon_menu, :item,
  name:      proc { _INTL("Item") },
  order:     60,
  condition: proc { |screen, mode, selected, pokemon, heldpoke|
    [0, -1].include?(mode) && ((heldpoke && !heldpoke.isEgg?) || (!heldpoke && pokemon && !pokemon.isEgg?))
  },
  effect:    proc { |screen, mode, selected, pokemon, heldpoke|
    screen.pbItem(selected, heldpoke)
    next nil
  }
)

MenuHandlers.add(:storage_mon_menu, :mark,
  name:      proc { _INTL("Mark") },
  order:     70,
  condition: proc { |screen, mode, selected, pokemon, heldpoke| pokemon || heldpoke },
  effect:    proc { |screen, mode, selected, pokemon, heldpoke|
    screen.pbMark(selected, heldpoke)
    next nil
  }
)

MenuHandlers.add(:storage_mon_menu, :release,
  name:      proc { _INTL("Release") },
  order:     80,
  condition: proc { |screen, mode, selected, pokemon, heldpoke| mode != -1 && (pokemon || heldpoke) },
  effect:    proc { |screen, mode, selected, pokemon, heldpoke|
    screen.pbRelease(selected, heldpoke)
    next nil
  }
)

MenuHandlers.add(:storage_mon_menu, :debug,
  name:      proc { _INTL("Debug") },
  order:     90,
  condition: proc { |screen, mode, selected, pokemon, heldpoke|
    mode == 0 && ($DEBUG || $game_switches[:MiniDebug_Pass]) && (pokemon || heldpoke)
  },
  effect:    proc { |screen, mode, selected, pokemon, heldpoke|
    pkmn = heldpoke ? heldpoke : pokemon
    # Use .send to force the execution context to the screen, preventing @scene is nil crashes
    screen.send(:pbPokemonDebug, screen, pkmn, nil, selected, heldpoke)
    next nil
  }
)

MenuHandlers.add(:storage_mon_menu, :cancel,
  name:      proc { _INTL("Cancel") },
  order:     nil,
  condition: proc { true },
  effect:    proc { |screen, mode, selected, pokemon, heldpoke|
    next :break
  }
)

# Storage Sort Menu Registry
# Context Procs take: |default| (The fallback sorting lambda)
MenuHandlers.add(:storage_sort_menu, :name,
  name:      proc { _INTL("Nickname") },
  order:     10,
  effect:    proc { |default|
    next proc { |x, y|
      name_cmp = x.name <=> y.name
      name_cmp == 0 ? default.call(x, y) : name_cmp
    }
  }
)

MenuHandlers.add(:storage_sort_menu, :level,
  name:      proc { _INTL("Level") },
  order:     20,
  effect:    proc { |default|
    next proc { |x, y|
      level_cmp = y.level <=> x.level
      level_cmp == 0 ? default.call(x, y) : level_cmp
    }
  }
)

MenuHandlers.add(:storage_sort_menu, :dex_no,
  name:      proc { _INTL("Dex No.") },
  order:     30,
  effect:    proc { |default|
    next proc { |x, y| default.call(x, y) }
  }
)

MenuHandlers.add(:storage_sort_menu, :species,
  name:      proc { _INTL("Species") },
  order:     40,
  effect:    proc { |default|
    next proc { |x, y|
      species_cmp = getMonName(x.species) <=> getMonName(y.species)
      species_cmp == 0 ? default.call(x, y) : species_cmp
    }
  }
)

MenuHandlers.add(:storage_sort_menu, :type,
  name:      proc { _INTL("Type") },
  order:     50,
  effect:    proc { |default|
    next proc { |x, y|
      cmp_1 = 2 * (getTypeName(x.type1) <=> getTypeName(y.type1))
      cmp_2 = getTypeName(x.type2) <=> getTypeName(y.type2)
      type_cmp = cmp_1 + cmp_2
      type_cmp == 0 ? default.call(x, y) : type_cmp
    }
  }
)

MenuHandlers.add(:storage_sort_menu, :shiny,
  name:      proc { _INTL("Shiny") },
  order:     60,
  effect:    proc { |default|
    next proc { |x, y|
      if !x.isShiny? && y.isShiny?
        1
      elsif x.isShiny? && !y.isShiny?
        -1
      else
        default.call(x, y)
      end
    }
  }
)

MenuHandlers.add(:storage_sort_menu, :item,
  name:      proc { _INTL("Item") },
  order:     70,
  effect:    proc { |default|
    next proc { |x, y|
      if x.item.nil? && !y.item.nil?
        1
      elsif !x.item.nil? && y.item.nil?
        -1
      else
        itemname1 = x.item.nil? ? "" : getItemName(x.item)
        itemname2 = y.item.nil? ? "" : getItemName(y.item)
        item_cmp = itemname1 <=> itemname2
        item_cmp == 0 ? default.call(x, y) : item_cmp
      end
    }
  }
)

MenuHandlers.add(:storage_sort_menu, :total_iv,
  name:      proc { _INTL("Total IVs") },
  order:     80,
  effect:    proc { |default|
    next proc { |x, y|
      iv_cmp = y.iv.sum <=> x.iv.sum
      iv_cmp == 0 ? default.call(x, y) : iv_cmp
    }
  }
)

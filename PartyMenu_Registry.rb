# Vanilla Party Menu Registry
# Context Procs take: |screen, party, pkmnid|

MenuHandlers.add(:party_menu, :summary,
  name:      proc { |*args| _INTL("Summary") },
  order:     10,
  effect:    proc { |screen, party, pkmnid|
    screen.scene.pbSummary(pkmnid)
    next nil
  }
)

MenuHandlers.add(:party_menu, :learn,
  name:      proc { |*args| _INTL("Learn") },
  order:     20,
  condition: proc { |screen, party, pkmnid|
    pkmn = party[pkmnid]
    next !(pkmn.isEgg? || (pkmn.isShadow? rescue false))
  },
  effect:    proc { |screen, party, pkmnid|
    pbRelearnMoveScreen(party, pkmnid, relearner: false)
    next nil
  }
)

MenuHandlers.add(:party_menu, :switch,
  name:      proc { |*args| _INTL("Switch") },
  order:     30,
  condition: proc { |screen, party, pkmnid| party.length > 1 },
  effect:    proc { |screen, party, pkmnid|
    screen.scene.pbSetHelpText(_INTL("Move to where?"))
    oldpkmnid = pkmnid
    newpkmnid = screen.scene.pbChoosePokemon(true)
    if newpkmnid >= 0 && newpkmnid != oldpkmnid
      screen.pbSwitch(oldpkmnid, newpkmnid)
    end
    next nil
  }
)

MenuHandlers.add(:party_menu, :mail,
  name:      proc { |*args| _INTL("Mail") },
  order:     40,
  condition: proc { |screen, party, pkmnid| !party[pkmnid].isEgg? && party[pkmnid].mail },
  effect:    proc { |screen, party, pkmnid|
    pkmn = party[pkmnid]
    command = screen.scene.pbShowCommands(_INTL("Do what with the mail?"), [_INTL("Read"), _INTL("Take"), _INTL("Cancel")])
    case command
      when 0 # Read
        pbFadeOutIn(99999) { pbDisplayMail(pkmn.mail, pkmn) }
      when 1 # Take
        pbTakeItem(pkmn, screen)
        screen.pbRefreshSingle(pkmnid)
    end
    next nil
  }
)

MenuHandlers.add(:party_menu, :item,
  name:      proc { |*args| _INTL("Item") },
  order:     40, # Replaces mail, so same order
  condition: proc { |screen, party, pkmnid| !party[pkmnid].isEgg? && !party[pkmnid].mail },
  effect:    proc { |screen, party, pkmnid|
    screen.itemMenu(pkmnid, party[pkmnid])
    next nil
  }
)

MenuHandlers.add(:party_menu, :rename,
  name:      proc { |*args| _INTL("Rename") },
  order:     50,
  condition: proc { |screen, party, pkmnid| !party[pkmnid].isEgg? },
  effect:    proc { |screen, party, pkmnid|
    pkmn = party[pkmnid]
    species = getMonName(pkmn.species, pkmn.form)
    if $Settings.useKeyboard?
      $game_variables[5] = Kernel.pbMessageFreeText(_INTL("{1}'s nickname?", species), "", 12)
    else
      $game_variables[5] = pbEnterPokemonName(_INTL("{1}'s nickname?", species), 0, 12, pkmn.name, pkmn)
    end
    if pbGet(5) == ""
      pkmn.name = getMonName(pkmn.species, pkmn.form)
      pbSet(5, pkmn.name)
    end
    if pbGet(5) != pkmn.name
      pkmn.name = pbGet(5)
      screen.pbDisplay(_INTL("{1} was renamed to {2}.", species, pkmn.name))
    end
    next nil
  }
)

# Dynamic Hidden Move Evaluators (Registers 4 dynamic slots per Pokémon)
4.times do |i|
  MenuHandlers.add(:party_menu, :"hidden_move_#{i}",
    name:      proc { |screen, party, pkmnid| getMoveName(party[pkmnid].moves[i].move) },
    order:     60 + i,
    color: :Blue2,

    # Menu building
    condition: proc { |screen, party, pkmnid|
      pkmn = party[pkmnid]
      next false if pkmn.isEgg? || pkmn.moves[i].nil? || pkmn.moves[i].move.nil?
      move = pkmn.moves[i].move
      next [:MILKDRINK, :SOFTBOILED].include?(move) ||
        (move == :RELICSONG && pkmn.species == :MELOETTA && [0, 1].include?(pkmn.form)) ||
        HiddenMoveHandlers.hasHandler(move)
    },

    # Menu execution
    effect:    proc { |screen, party, pkmnid|
      pkmn = party[pkmnid]
      move = pkmn.moves[i].move
      movename = getMoveName(move)

      # HP Healing Moves Handling
      if [:SOFTBOILED, :MILKDRINK].include?(move)
        hpamount = (pkmn.totalhp / 5.0).floor
        if pkmn.hp <= hpamount
          screen.pbDisplay(_INTL("{1} does not have enough HP to use {2}!", pkmn.name, movename))
          next nil
        end
        screen.scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
        loop do
          new_pkmnid = screen.scene.pbChoosePokemon(true)
          break if new_pkmnid < 0

          newpkmn = party[new_pkmnid]
          if newpkmn == pkmn
            screen.pbDisplay(_INTL("{1} can't use {2} on itself!", pkmn.name, movename))
          elsif newpkmn.isEgg?
            screen.pbDisplay(_INTL("{1} can't be used on an Egg!", movename))
          elsif newpkmn.hp == 0 || newpkmn.hp == newpkmn.totalhp
            screen.pbDisplay(_INTL("{1} can't be used on that Pokémon.", movename))
          else
            pkmn.hp -= hpamount
            pbItemRestoreHP(newpkmn, nil, hpamount, screen.scene)
            screen.pbRefresh
            if pkmn.hp <= hpamount
              screen.pbDisplay(_INTL("{1} can't use {2} any more!", pkmn.name, movename))
              break
            end
          end
        end
        screen.scene.pbSelect(pkmnid)
        screen.pbRefresh
        next nil

      # Meloetta Relic Song Handling
      elsif move == :RELICSONG
        pbHiddenMoveAnimation(pkmn)
        pkmn.changeForm(pkmn.form == 0 ? 1 : 0)
        screen.pbRefresh
        Kernel.pbMessage(_INTL("{1} used {2} to change its form!", pkmn.name, getMoveName(move)))
        next nil

      # Standard Hidden Move Handling with badge check
      else
        next screen.tryUseHiddenMoveFromParty(pkmn, move) # Returns out of pbPokemonScreen on successful move use
      end
    }
  )
end

MenuHandlers.add(:party_menu, :hp_type,
  name:      proc { |*args| _INTL("Hidden Power") },
  order:     70,
  color: :Blue2,
  condition: proc { |screen, party, pkmnid| !party[pkmnid].isEgg? && party[pkmnid].canChangeAllHPType?},
  effect:    proc { |screen, party, pkmnid|
  pkmn = party[pkmnid]
  oldhptype = pbHiddenPower(pkmn)
  commands = []
  types = {}
  i = 0
  $cache.types.each do |type, data|
    next if [:NORMAL, :QMARKS, :SHADOW, :STELLAR].include?(type)
    commands.push(getTypeName(type))
    types[i] = type
    i += 1
  end
  oldhptypeval = commands.index(getTypeName(pkmn.hptype))
  cmd = screen.scene.pbShowCommands(_INTL("Hidden Power {1}.", getTypeName(oldhptype)), commands, oldhptypeval)
  # Break
  if cmd == -1
    next nil
  # Set nature override
  elsif cmd >= 0 && cmd < types.length
    pkmn.hptype = types[cmd]
  end

  screen.scene.pbHardRefresh
  next nil
  }
)

MenuHandlers.add(:party_menu, :use_tmx,
  name:      proc { |*args| _INTL("Use TMX") },
  order:     80,
  condition: proc { |screen, party, pkmnid| !party[pkmnid].isEgg? && $game_switches[:EasyHMs_Password] },
  effect:    proc { |screen, party, pkmnid|
    next screen.passwordUseTMX(party[pkmnid]) # Returns out of pbPokemonScreen on successful move use
  }
)


MenuHandlers.add(:party_menu, :debug,
  name:      proc { |*args| _INTL("Debug") },
  order:     90,
  condition: proc { |screen, party, pkmnid| $DEBUG || $game_switches[:MiniDebug_Pass] },
  effect:    proc { |screen, party, pkmnid|
    # Due to the way debug was written, we need to call pbPokemonDebug on the screen object to force Ruby to execute the global method as if it were running directly inside the PokemonScreen class. This prevents the "@scene is nil" crash.
    screen.pbPokemonDebug(screen, party[pkmnid], pkmnid)
    next nil
  }
)

MenuHandlers.add(:party_menu, :cancel,
  name:      proc { |*args| _INTL("Cancel") },
  order:     nil,
  effect:    proc { |screen, party, pkmnid|
    next nil
  }
)

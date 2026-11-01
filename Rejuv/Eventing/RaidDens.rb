###################################
# Raid Den Syntax Documentation
###################################
=begin
  Raids are stored in two separate parts: Encounters and Dens.

  Encounters:
    Encounter keys double as identifiers and species.
    Encounter hashes follow the same format as any other Pokemon hash.

    Extra hash definitions:
      species:
        In the case that an identifier is NOT a species, the species should
        be defined here. See :GALARSTUNFISK in denectext.rb for an example.
      shinyChance:
        Dens may choose to have an additional roll for shiny Pokemon.
        Value must be a float from 0 to 1. Default is 0.
      level:
        Levels are typically assigned via the den with a range.
        In the case that a level is defined here, it completely overrides the
        default levels + range. See :BELDUM in denenctext.rb for an example.

  Dens:
    Dens are defined as basic identifiers with RaidDen objects.

    .addTable(condition, table)
      Tables are defined First-In First-Out (FIFO), so the first table listed will always
      be selected if its condition is met.

      condition - Can be a Symbol, Integer, String, or empty.
                  When supplied a Symbol/Integer, the value is checked against $game_switches.
                    Symbols are defined in constant `Switches`.
                  When supplied a String, the string is ran in the code base to see if the table
                  would be selected.
      table - An array of hashes.
        :encounter - Value must be a defined Encounter identifier.
        :weight - Float, default 1.0.
                  Weighted sampling uses the method outlined in RubyDoc - Enumerable::max_by

    .setLevels(level)
      level - Array of integers. Default [95, 80, 65, 50, 35]
              Also follows FIFO ordering.
              Array length should match the amount of encounter tables you include.

    .setLevelRange(range)
      When generating an encounter, this range is used to assign random levels.
      range - Range or 2 Integers. Default -5 to 5.

    .setMessage(message)
      Overrides the default "This den contains a {1}-star {2}." message.
      {1} - Star level, see method below.
      {2} - Pokemon name.
=end

def checkRaidStar(level)
  return 5 if level >= 90
  return 4 if level >= 75
  return 3 if level >= 60
  return 2 if level >= 45
  return 1 if level >= 30

  5
end

def getDenEncounter(enc)
  return $cache.denencounters[enc]
end

def raidDen(denSymbol)
  den = $cache.dens[denSymbol]
  mon = den.generateEncounter
  Events.onWildPokemonCreate.trigger(nil, mon)

  message = den.message ? den.getMessage : _INTL("This den contains a {1}-star {2}!")
  Kernel.pbMessage(_INTL(message, checkRaidStar(mon.level), getMonName(mon.species, mon.form)))
  variable = Variables[:BattleResult]
  if Kernel.pbConfirmMessage(_INTL("Would you like to fight it?"))
    bossFunction($cache.bosses[:SHADOWDEN], :SHADOWDEN, mon)
    $game_switches[:Raid] = true
    mon.makeShadow
    ret = pbWildBattleObject(mon, variable)

    $game_switches[:Raid] = false
    return ret
  else
    $PokemonGlobal.nextBattleBGM = nil
    $PokemonGlobal.nextBattleVictoryBGM = nil
    $PokemonGlobal.nextBattleBack = nil
    if Kernel.pbConfirmMessage(_INTL("Would you like to clear the den?"))
      $game_variables[:BattleResult] = 1
      return true
    end
    $game_variables[:BattleResult] = 3
    return false
  end
end

def raidHandler(decision, pokemon)
  return if !$game_switches[:Raid]

  #pokemon.makeShadow
  pokemon.isbossmon = false
  pokemon.shieldCount = nil
  pokemon.bossID = nil
  if decision == 4
    if !$Trainer.pokedex.nil?
      $Trainer.pokedex.setOwned(pokemon)
    end
  end
end

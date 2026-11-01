################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate += proc { |sender, e|
  pokemon = e[0]
  if $game_switches[:Force_Wild_Shiny]
    pokemon.makeShiny
  end
  if $game_switches[:No_Catching]
    pokemon.makeNotShiny
  end
}

Events.onBossCreate += proc { |sender, e|
  pokemon = e[0]
  if Rejuv
    if [:TWINDANCERS, :TWINDANCERS_1].include?(pokemon.bossID)
      if $game_switches[1371] == true
        pokemon.hp = (pokemon.totalhp * 0.75).floor
      end
    end
  end
}

Events.onTrainerPartyLoad += proc { |sender, e|
  if e[0] # Trainer data should exist to be loaded, but may not exist somehow
    trainer = e[0][0] # A PokeBattle_Trainer object of the loaded trainer
    items = e[0][1]   # An array of the trainer's items they can use
    party = e[0][2]   # An array of the trainer's Pokémon
    if Reborn && (trainer.trainertype == :SHELLY || trainer.trainertype == :FUTURESHELLY) && trainer.name == "Shelly"
      if party[5].species == :LEAVANNY # [0] is the Pokemon's place in the trainer party, with 0 being slot 1 and so forth (must be changed in all following lines) & where species is the species to change
        party[5].name = $Trainer.name
        case $game_variables[:Player_Gender]
          when 0 # Male player
            party[5].makeMale
          when 1 # Female player
            party[5].makeFemale
          when 2 # Nonbinary player - added in PokeBattle_Pokemon
            party[5].makeGenderless
        end
      end
      if party[3].species == :PRIMARINA && party[3].name == "Adrienn"
        party[3].makeGenderless
      end
    end
    if Reborn && trainer.trainertype == :DARKRAI && trainer.name == "Darkrai"
      if party[3].species == :DARKRAI # [0] is the Pokemon's place in the trainer party, with 0 being slot 1 and so forth (must be changed in all following lines) & where species is the species to change
        party[3].name = $game_variables[782] if $game_variables[782].is_a?(String) && $game_variables[782] != ""
        party[3].makeShiny if $game_switches[2200] == true
      end
    end
    if Reborn && trainer.trainertype == :NELLY
      hash = { 0 => :EEVEE, 1 => :VAPOREON, 2 => :JOLTEON, 3 => :FLAREON, 4 => :ESPEON, 5 => :UMBREON, 6 => :LEAFEON, 7 => :GLACEON, 8 => :SYLVEON }
      for pkmn in party
        pkmn.makeShiny if pkmn.species == hash[$game_variables[816]]
      end
    end
  end
}

# UPDATE 11/19/2013
# Cute Charm now gives a 2/3 chance of being opposite gender
Events.onWildPokemonCreate += proc { |sender, e|
  pokemon = e[0]
  user = fieldAbilityUser
  if !user.egg? && user.ability == :CUTECHARM && !user.isGenderless? && rand(3) < 2
    ratio = pokemon.getCacheData.GenderRatio
    if ![:Genderless, :MaleZero, :FemZero].include?(ratio)
      user.isMale? ? pokemon.makeFemale : pokemon.makeMale
    end
  end
}

# UPDATE 8/1/2022
# sync will now give a 100% chance of encountered pokemon having
# the same nature as the party leader
Events.onWildPokemonCreate += proc { |sender, e|
  pokemon = e[0]
  user = fieldAbilityUser
  if !user.egg? && user.ability == :SYNCHRONIZE
    pokemon.setNature(user.nature)
  end
}

Events.onWildPokemonCreate += proc { |sender, e|
  pokemon = e[0]
  itemhash = pokemon.getCacheData.getWildItems

  item = nil
  if itemhash[:always]
    item = itemhash[:always]
  elsif !itemhash.empty? && $game_variables[:DrinkItems] != 0
    item = itemhash.values.uniq.sample
  elsif !itemhash.empty?
    user = fieldAbilityUser
    chances = !user.isEgg? && [:COMPOUNDEYES, :SUPERLUCK].include?(user.ability) ?
      { common: 60, uncommon: 20, rare: 5 } :
      { common: 50, uncommon: 5, rare: 1 }
    itemrnd = rand(100)
    if itemrnd < chances[:common]
      item = itemhash[:common]
    elsif itemrnd < chances[:common] + chances[:uncommon]
      item = itemhash[:uncommon]
    elsif itemrnd < chances[:common] + chances[:uncommon] + chances[:rare]
      item = itemhash[:rare]
    end
  end
  pokemon.setItem(item) if item

  if rand(65536) < POKERUSCHANCE
    pokemon.givePokerus
  end
}

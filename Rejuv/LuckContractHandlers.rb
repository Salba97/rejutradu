Events.onWildPokemonCreate += proc { |sender, e|
  pokemon = e[0]
  check = rand(100)
  if $cache.mapdata[$game_map.map_id]&.MapPosition
    check = rand(80) if $cache.mapdata[$game_map.map_id]&.MapPosition[0] == 1
  end
  check = rand(70) if [175, 183, 225].include?($game_map.map_id)
  check = rand(30) if $PokemonBag.pbHasItem?(:SHAYDASCHARM)
  check = rand(20) if $game_variables[:LuckShinies] < 0
  check = rand(2) if $game_variables[:LuckShinies] < 0 && $PokemonBag.pbHasItem?(:SHAYDASCHARM)
  if check == 0 && !($game_variables[:WildMods] > 0 && pokemon.item != nil)
    pokemon.item = :BLKPRISM
    if !(pokemon.getCacheData.EggGroups.include?(:Undiscovered) || pokemon.species == :MANAPHY) # undiscovered group or manaphy
      stat1, stat2, stat3 = [0, 1, 2, 3, 4, 5].sample(3)
      for i in 0..5
        pokemon.iv[i] = 31 if [stat1, stat2, stat3].include?(i)
      end
    end
  end
}

Events.onWildPokemonCreate += proc { |sender, e|
  pokemon = e[0]
  exceptionlist = [95, 98, 100, 120, 128, 129]
  m2helltime = m2hell ? true : false

  if Rejuv
    if m2helltime
      movelist = [:FINALGAMBIT, :FINALGAMBIT, :FINALGAMBIT, :FINALGAMBIT]
      for i in 0...pokemon.moves.length
        break if i > 3

        moveid = movelist[i]
        pokemon.moves[i] = moveid.nil? ? nil : PBMove.new(moveid)
      end
      pokemon.ev[0] = 252
      pokemon.ev[5] = 252
      pokemon.item = pokemon.species == :DUGTRIO ? :AIRBALLOON : :CHOICESCARF
      pokemon.ability = :DAZZLING if pokemon.species == :BRUXISH
      m2hell = true
    end
  end

  if $game_variables[:LuckMoves] != 0 && !exceptionlist.include?($game_variables[:WildMods]) && m2helltime == false
    bonuslist = pokemon.getCacheData.compatiblemoves
    exceptionlist = pokemon.getCacheData.moveexceptions
    bonuslist = bonuslist + (getUniversalTMs() - exceptionlist)
    bonuslist += pokemon.getEggMoveList
    bonuslist.uniq!
    bonuslist = bonuslist - [:FISSURE, :ROCKCLIMB, :MAGMADRIFT, :QUICKSILVERSPEAR]
    extramove = bonuslist[$game_variables[:LuckMoves][1].rand(bonuslist.length)] if !bonuslist.empty?
    newmovelist = []
    pokemon.moves = pokemon.moves.reverse
    for moves in pokemon.moves
      newmovelist.push(moves.move)
    end
    if extramove && !newmovelist.include?(extramove)
      newmovelist[-1] = extramove
    end
    newmovelist.uniq!
    newmovelist = [:SELFDESTRUCT] if $game_variables[:LuckMoves][0] < 0
    pokemon.moves = []
    for i in 0...newmovelist.length
      break if i > 3

      moveid = newmovelist[i]
      pokemon.moves[i] = moveid.nil? ? nil : PBMove.new(moveid)
    end
  end
}

def getWonderTowerPool(pool)
  return $cache.wonderpool.pool(pool)
end

def generateWonderTowerEncounter(pool, levels)
  pool = getWonderTowerPool(pool)

  level = levels.entries.sample(random: $game_variables[:WonderTowerSeed])
  enc = pool.sample(random: $game_variables[:WonderTowerSeed])

  pbWildBattleObject(enc.createPokemon(level))
end

def wonderTowerItemPool
  return {
    :fieldBerry => [:SITRUSBERRY, :ASPEARBERRY, :ORANBERRY, :PECHABERRY],
    :fieldStone => [:DUSKSTONE, :WATERSTONE, :LEAFSTONE],
    :fieldHeal => [:POTION, :SODAPOP, :MOOMOOMILK, :LEMONADE, :SUPERPOTION],
    :fieldStatus => [:BURNHEAL, :FULLHEAL, :ANTIDOTE, :ENERGYPOWDER],
    :fieldTM => [:TM01, :TM02, :TM06],
    :fieldPlate => [:FLAMEPLATE, :SPLASHPLATE, :MEADOWPLATE],
    :fieldPP => [:SUPERPOTION, :MAXPOTION, :ETHER],

    :castleHeal => [:MAXPOTION, :MAXREVIVE, :FULLRESTORE],
    :castlePP => [:ELIXIR, :FULLRESTORE, :ETHER],
    :castleTM1 => [:TM55, :TM81, :TM84],
    :castleTM2 => [:TM24, :TM35, :TM53],
    :castleTM3 => [:TM30, :TM33, :TM36],

    :forestTM1 => [:TM04, :TM31, :TM51, :TM57],
    :forestTM2 => [:RM01, :RM02, :RM04, :RM06, :RM08, :RM09],
    :forestTM3 => [:TM09, :TM10, :TM23],
    :forestTM4 => [:TM86, :TM91, :TM93],
    :forestHM => [:HM02, :HM05, :HM06],
    :forestPP => [:REVIVE, :LUMBERRY, :PPUP],
    :forestStone => [:WATERSTONE, :LEAFSTONE, :FIRESTONE],
    :forestBattle => [
      :SHARPBEAK, :MYSTICWATER, :FOCUSSASH, :TWISTEDSPOON, :METALCOAT, :LUCKYEGG,
      :EVIOLITE, :DREADPLATE, :CHARCOAL, :LIFEORB, :SOFTSAND
    ],
  }
end

def generateWonderTowerItem(pool)
  table = wonderTowerItemPool[pool]
  item = table.sample(random: $game_variables[:WonderTowerSeed])
  item = table[$game_variables[41] - 1] if pool.to_s.include?("Stone")
  Kernel.pbItemBall(item)
end

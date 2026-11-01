module BallHandlers
  IsUnconditional = ItemHandlerHash.new
  ModifyCatchRate = ItemHandlerHash.new
  OnCatch = ItemHandlerHash.new
  OnFailCatch = ItemHandlerHash.new
  if Reborn || Desolation
    BallTypes = {
      0 => :POKEBALL,
      1 => :GREATBALL,
      2 => :SAFARIBALL,
      3 => :ULTRABALL,
      4 => :MASTERBALL,
      5 => :NETBALL,
      6 => :DIVEBALL,
      7 => :NESTBALL,
      8 => :REPEATBALL,
      9 => :TIMERBALL,
      10 => :LUXURYBALL,
      11 => :PREMIERBALL,
      12 => :DUSKBALL,
      13 => :HEALBALL,
      14 => :QUICKBALL,
      15 => :CHERISHBALL,
      16 => :FASTBALL,
      17 => :LEVELBALL,
      18 => :LUREBALL,
      19 => :HEAVYBALL,
      20 => :LOVEBALL,
      21 => :FRIENDBALL,
      22 => :MOONBALL,
      23 => :SPORTBALL,
      24 => :BEASTBALL,
      25 => :GLITTERBALL,
      26 => :DREAMBALL
    }
  else
    BallTypes = {
      0 => :POKEBALL,
      1 => :GREATBALL,
      2 => :SAFARIBALL,
      3 => :ULTRABALL,
      4 => :MASTERBALL,
      5 => :NETBALL,
      6 => :DIVEBALL,
      7 => :NESTBALL,
      8 => :REPEATBALL,
      9 => :TIMERBALL,
      10 => :LUXURYBALL,
      11 => :PREMIERBALL,
      12 => :DUSKBALL,
      13 => :HEALBALL,
      14 => :QUICKBALL,
      15 => :CHERISHBALL,
      16 => :FASTBALL,
      17 => :LEVELBALL,
      18 => :LUREBALL,
      19 => :HEAVYBALL,
      20 => :LOVEBALL,
      21 => :FRIENDBALL,
      22 => :MOONBALL,
      23 => :SPORTBALL,
      24 => :STEAMBALL,
      25 => :MINERALBALL,
      26 => :BEASTBALL,
      27 => :DREAMBALL,
      28 => :XENBALL,
    }
  end

  def self.isUnconditional?(ball, battle, battler)
    if !IsUnconditional[ball]
      return false
    end

    return IsUnconditional.trigger(ball, battle, battler)
  end

  def self.modifyCatchRate(ball, catchRate, battle, battler)
    if pbIsUltraBeast?(battler) && ball != :BEASTBALL && !self.isUnconditional?(ball, battle, battler)
      return (catchRate * 0.1).floor
    end

    if !ModifyCatchRate[ball]
      return catchRate
    end

    return ModifyCatchRate.trigger(ball, catchRate, battle, battler)
  end

  def self.onCatch(ball, battle, pokemon)
    if OnCatch[ball]
      OnCatch.trigger(ball, battle, pokemon)
    end
  end

  def self.onFailCatch(ball, battle, pokemon)
    if OnFailCatch[ball]
      OnFailCatch.trigger(ball, battle, pokemon)
    end
  end
end

def pbBallTypeToBall(balltype)
  return BallHandlers::BallTypes[balltype] if BallHandlers::BallTypes[balltype]
  return :POKEBALL
end

def pbGetBallType(ball)
  for key in BallHandlers::BallTypes.keys
    return key if BallHandlers::BallTypes[key] == ball
  end
  return 0
end

def pbIsUltraBeast?(battler)
  return PBStuff::ULTRABEASTS.include?(battler.species)
end

################################

BallHandlers::ModifyCatchRate.add(:GREATBALL, proc { |ball, catchRate, battle, battler|
  next (catchRate * 1.5).floor
})

BallHandlers::ModifyCatchRate.add(:SAFARIBALL, proc { |ball, catchRate, battle, battler|
  next (catchRate * 1.5).floor
})

BallHandlers::ModifyCatchRate.add(:ULTRABALL, proc { |ball, catchRate, battle, battler|
  next catchRate * 2
})

BallHandlers::ModifyCatchRate.add(:PREMIERBALL, proc { |ball, catchRate, battle, battler|
  next (catchRate * 0.25).floor
})

BallHandlers::IsUnconditional.add(:MASTERBALL, proc { |ball, battle, battler|
  next true
})

BallHandlers::ModifyCatchRate.add(:NETBALL, proc { |ball, catchRate, battle, battler|
  catchRate = (catchRate * 3.5).floor if battler.hasType?(:BUG) || battler.hasType?(:WATER)
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:DIVEBALL, proc { |ball, catchRate, battle, battler|
  catchRate = (catchRate * 3.5).floor if battle.environment == :Underwater || [:WATERSURFACE, :UNDERWATER].include?(battle.FE)
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:NESTBALL, proc { |ball, catchRate, battle, battler|
  # catchRate *= (41 - battler.level) / 10 if battler.level <= 40
  modifier = [8 - 0.2 * (battler.level - 1), 1].max
  catchRate = (catchRate * modifier).floor
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:REPEATBALL, proc { |ball, catchRate, battle, battler|
  catchRate = (catchRate * 3.5).floor if battle.pbPlayer.pokedex.owned?(battler.species)
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:TIMERBALL, proc { |ball, catchRate, battle, battler|
  multiplier = [1 + (0.3 * battle.turncount), 4].min
  catchRate = (catchRate * multiplier).floor
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:DUSKBALL, proc { |ball, catchRate, battle, battler|
  catchRate = (catchRate * 3.5).floor if PBDayNight.isNight?(pbGetTimeNow) || [:DARKCRYSTALCAVERN, :SHORTCIRCUIT, :UNDERWATER, :CAVE, :CRYSTALCAVERN, :DRAGONSDEN, :STARLIGHT, :NEWWORLD, :INVERSE].include?(battle.FE)
  next catchRate
})

BallHandlers::OnCatch.add(:HEALBALL, proc { |ball, battle, pokemon|
  pokemon.heal
})

BallHandlers::ModifyCatchRate.add(:QUICKBALL, proc { |ball, catchRate, battle, battler|
  catchRate *= 5 if battle.turncount <= 1
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:FASTBALL, proc { |ball, catchRate, battle, battler|
  basestats = battler.getCacheData.BaseStats
  basespeed = basestats[-1]
  catchRate *= 4 if basespeed >= 100
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:LEVELBALL, proc { |ball, catchRate, battle, battler|
  plevel = [battle.battlers[0].level, battle.battlers[2].level].max
  case true
    when plevel >= battler.level * 4 then catchRate *= 8
    when plevel >= battler.level * 2 then catchRate *= 4
    when plevel > battler.level then catchRate *= 2
  end
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:LUREBALL, proc { |ball, catchRate, battle, battler|
  catchRate *= 5 if [EncounterTypes::OldRod, EncounterTypes::GoodRod, EncounterTypes::SuperRod].include?($PokemonTemp.encounterType)
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:HEAVYBALL, proc { |ball, catchRate, battle, battler|
  weight = battler.weight
  case true
    when weight >= 3000 then catchRate += 30
    when weight >= 2000 then catchRate += 20
    when weight <= 999 then catchRate -= 20
  end
  catchRate = [catchRate, 1].max
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:LOVEBALL, proc { |ball, catchRate, battle, battler|
  catchRate *= 8 if [battle.battlers[0], battle.battlers[2]].any? { |i| !i.isFainted? && i.species == battler.species && ((battler.isMale? && i.isFemale?) || (battler.isFemale? && i.isMale?)) }
  next catchRate
})

BallHandlers::OnCatch.add(:FRIENDBALL, proc { |ball, battle, pokemon|
  pokemon.happiness = 200
})

BallHandlers::ModifyCatchRate.add(:MOONBALL, proc { |ball, catchRate, battle, battler|
  evos = pbGetEvolvedFormData(battler.pokemon.species, battler.pokemon.form)
  catchRate *= 4 if evos&.any? { |evo| evo[:parameter] == :MOONSTONE }
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:SPORTBALL, proc { |ball, catchRate, battle, battler|
  # Commented out because the 1.5 modifier only applies in bug catching contest which we don't use.
  # next (catchRate * 1.5).floor
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:BEASTBALL, proc { |ball, catchRate, battle, battler|
  next catchRate * 5 if pbIsUltraBeast?(battler)
  next (catchRate * 0.1).floor
})

BallHandlers::ModifyCatchRate.add(:DREAMBALL, proc { |ball, catchRate, battle, battler|
  catchRate *= 4 if battler.status == :SLEEP
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:GLITTERBALL, proc { |ball, catchRate, battle, battler|
  catchRate *= 8 if battler.pokemon.isShiny?
  next catchRate
})

BallHandlers::OnCatch.add(:GLITTERBALL, proc { |ball, battle, pokemon|
  pokemon.makeShiny
})

BallHandlers::ModifyCatchRate.add(:STEAMBALL, proc { |ball, catchRate, battle, battler|
  catchRate = (catchRate * 3.5).floor if battler.hasType?(:FIRE) || battler.hasType?(:WATER)
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:MINERALBALL, proc { |ball, catchRate, battle, battler|
  catchRate = (catchRate * 3.5).floor if battler.hasType?(:ROCK) || battler.hasType?(:GROUND) || battler.hasType?(:STEEL)
  next catchRate
})

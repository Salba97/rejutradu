class PBMove
  attr_reader(:move)     # Gets the symbol of the move
  attr_accessor(:pp)     # Gets the number of PP remaining for this move.
  attr_accessor(:ppup)   # Gets the number of PP Ups used for this move.

  def initialize(move = nil)
    @move = move
    @ppup = 0
    @pp = totalpp
  end

  def totalpp
    return (maxpp * (1 + 0.2 * @ppup)).floor
  end

  # yanking these from PB_Move. might be unnecessary!
  def function
    return $cache.moves[@move].function
  end

  def type
    return $cache.moves[@move].type
  end

  def category
    return $cache.moves[@move].category
  end

  def basedamage
    return $cache.moves[@move].basedamage
  end

  def accuracy
    return $cache.moves[@move].accuracy
  end

  def maxpp
    return $cache.moves[@move].maxpp
  end

  def target
    return $cache.moves[@move].target
  end

  def priority
    return $cache.moves[@move].priority
  end

  # To be used only in pbMoveSummaryType and Battle_Move#summaryType, those methods can be used in other places
  def summaryType(pokemon, type = self.type)
    case self.function
      when 0x16A, 0x80B, 0x81E # Revelation Dance, Blinding Speed, Tera Blast
        return pokemon.type1
      when 0x090, 0x80A # Hidden Power, Unleashed Power
        return pbHiddenPower(pokemon)
      when 0x096 # Natural Gift
        return pbNaturalGiftType(pokemon.item)
      when 0x09F # Judgment/Multi-Attack/Techno Blast/Multipulse
        return pbJudgmentLikeMoveType(@move, pokemon.species, pokemon.form, pokemon.item, type)
      when 0x186 # Aura Wheel
        return :DARK if pokemon.species == :MORPEKO && pokemon.form == 1
      when 0x20C # Gilded Arrow/Gilded Helix
        return pokemon.type2 if pokemon.type2 && pokemon.type2 != :FAIRY && pokemon.type2 != :DARK
        return pokemon.type1
      when 0x512 # Raging Bull
        if pokemon.species == :TAUROS
          case pokemon.form
            when 1 then return :FIGHTING
            when 2 then return :FIRE
            when 3 then return :WATER
          end
        end
      when 0x520 # Ivy Cudgel
        if pokemon.species == :OGERPON
          case pokemon.form
            when 1, 5 then return :WATER
            when 2, 6 then return :FIRE
            when 3, 7 then return :ROCK
          end
        end
      when 0x522 # Tera Starstorm
        return :STELLAR if pokemon.isTerastallized?
      when 0x80D # Domain Shift
        return $game_switches[:RenegadeRoute] ? :SHADOW : :FAIRY
    end
    return type
  end

  # To be used only in pbMoveSummaryPower and Battle_Move#summaryPower, those methods can be used in other places
  def summaryPower(pokemon, basedamage = self.basedamage)
    case self.function
      when 0x089 # Return
        return [(pokemon.happiness * 2 / 5.0).floor, 1].max
      when 0x08A # Frustration
        return [((255 - pokemon.happiness) * 2 / 5.0).floor, 1].max
      when 0x096 # Natural Gift
        return pbNaturalGiftDamage(pokemon.item)
      when 0x0F7 # Fling
        return pbFlingDamage(pokemon.item)
    end
    return basedamage
  end
end

def pbMoveSummaryType(movedata, pokemon)
  if movedata.is_a?(MoveData)
    movedata = PBMove.new(movedata.move)
  end

  type = movedata.summaryType(pokemon)
  type = pbAbilityMoveTypeChange(movedata.move, pokemon.ability, type)
  type = pbCrestMoveTypeChange(pokemon.species, pokemon.form, pokemon.item, type)
  return type
end

def pbMoveSummaryPower(movedata, pokemon)
  if movedata.is_a?(MoveData)
    movedata = PBMove.new(movedata.move)
  end

  if pokemon.species == :LUVDISC && pokemon.item == :LUVCREST && movedata.basedamage > 0
    return [250 - pokemon.happiness, 1].max if movedata.function == 0x08A # Frustration
    return [pokemon.happiness, 250].min
  end
  return movedata.summaryPower(pokemon)
end

def pbAbilityMoveTypeChange(move, ability, type, field = nil)
  return type if PBStuff::ZMOVES.include?(move)

  case ability
    when :NORMALIZE   then return :NORMAL
    when :PIXILATE    then return :FAIRY    if type == :NORMAL && field != :GLITCH
    when :AERILATE    then return :FLYING   if type == :NORMAL
    when :GALVANIZE   then return :ELECTRIC if type == :NORMAL
    when :REFRIGERATE then return :ICE      if type == :NORMAL
    when :DRAGONIZE   then return :DRAGON   if type == :NORMAL
    when :DUSKILATE   then return :DARK     if type == :NORMAL && field != :GLITCH
    when :LIQUIDVOICE
      return field == :ICY ? :ICE : :WATER if $cache.moves[move]&.checkFlag?(:soundmove)
  end
  return type
end

def pbCrestMoveTypeChange(species, form, item, type)
  return type unless type == :NORMAL

  case true
    when species == :SIMISEAR && item == :SEARCREST then return :WATER
    when species == :SIMIPOUR && item == :POURCREST then return :GRASS
    when species == :SIMISAGE && item == :SAGECREST then return :FIRE
    when species == :LUXRAY   && item == :LUXCREST  then return :ELECTRIC
    when species == :SAWSBUCK && item == :SAWSCREST && [0, 1, 2, 3].include?(form)
      return { 0 => :WATER, 1 => :FIRE, 2 => :GROUND, 3 => :ICE }[form]
  end
  return type
end

def pbJudgmentLikeMoveType(move, species, form, item, type)
  if move == :TECHNOBLAST
    case item
      when :SHOCKDRIVE then return :ELECTRIC
      when :BURNDRIVE then return :FIRE
      when :CHILLDRIVE then return :ICE
      when :DOUSEDRIVE then return :WATER
    end
  elsif move == :MULTIATTACK
    itemtype = $cache.items[item]&.checkFlag?(:memory)
    return itemtype if itemtype
  elsif [:JUDGMENT, :MULTIPULSE].include?(move)
    if $cache.items[item]&.checkFlag?(:plate)
      itemtype = $cache.items[item]&.checkFlag?(:typeboost)
      return itemtype if itemtype
    end
  end
  if (move == :JUDGMENT && species == :ARCEUS) || (move == :MULTIATTACK && species == :SILVALLY)
    return $cache.types.keys[form % 19]
  end
  return type
end

def pbNaturalGiftType(item)
  return :NORMAL if item.nil? || !pbIsBerry?(item)
  return $cache.items[item].berry.naturaltype || :NORMAL
end

def pbFlingDamage(item)
  return 0 if item.nil?
  return 10 if (pbIsBerry?(item) || pbIsSeed?(item) || pbIsMint?(item) || pbIsNectar?(item))
  return 80 if pbIsMegaStone?(item)
  return $cache.items[item].checkFlag?(:flingdamage) || 1
end

def pbNaturalGiftDamage(item)
  return 0 if item.nil? || !pbIsBerry?(item)
  return $cache.items[item].berry.naturalpower || 1
end

def moveToString(move, moveobj, pokemon, summaryscreen)
  movedata = $game_switches[:Randomized_Challenge] && $Randomizer.randomMoves ? $rndcache.moves[move] : $cache.moves[move]
  string = ""
  string += getMoveName(move) + ", " if summaryscreen # In learn screen the move name is sent to tts by the command menu
  string += pbMoveSummaryType(movedata, pokemon).to_s + " type, "
  string += movedata.category.to_s.capitalize + ", "
  if movedata.category != :status
    basedamage = pbMoveSummaryPower(movedata, pokemon)
    string += (basedamage == 1 ? "Unknown" : basedamage.to_s) + " power, "
  end
  string += (movedata.accuracy == 0 ? "Perfect" : movedata.accuracy.to_s) + " accuracy, "
  string += sprintf("%+d", movedata.priority) + " priority, " if movedata.priority
  if summaryscreen
    string += moveobj.pp.to_s + " out of " + moveobj.totalpp.to_s + " PP, " unless moveobj.totalpp == 0
  else
    string += "#{moveobj.maxpp} base and #{moveobj.maxpp * 8 / 5} max PP, "
  end
  string += movedata.desc
  flags = notableMoveFlags(move).join(", ")
  string += " Flags: " + flags unless flags.empty?
  return string
end

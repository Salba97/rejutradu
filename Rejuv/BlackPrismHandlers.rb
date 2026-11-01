

class PokeBattle_Trainer
  attr_accessor :prismData

  def prismData
    @prismData = [0, 0, 0, 0] if !@prismData || @prismData.empty?
    @prismData
  end

  alias :__core_numbadges :numbadges unless method_defined?(:__core_numbadges)
  def numbadges
    badges = 0
    if $game_switches && $game_switches[:AngelicaTower]
      badges = 1 if $game_variables[:AngelicaGymStory] >= 12
      badges = 2 if $game_variables[:AngelicaGymStory] >= 16
    else
      badges = __core_numbadges
    end
    return badges
  end
end

Kernel.singleton_class.send(:alias_method, :__core_pbReceiveItem, :pbReceiveItem) unless Kernel.respond_to?(:__core_pbReceiveItem)
Kernel.singleton_class.send(:alias_method, :__core_itemBall_Prisms, :pbItemBall) unless Kernel.respond_to?(:__core_itemBall_Prisms)
alias :__core_addItemSilent :addItemSilent unless method_defined?(:__core_addItemSilent)

def addItemSilent(*args)
  console = false
  console = true if Input.text_input == true
  console = true if caller_locations.any? { |script| script.to_s.include?("pbDebugMenu") }
  $game_switches[args[0]] = true if !$game_switches[:AngelicaTower] && (pbIsTM?(args[0]) || $cache.items[args[0]].checkFlag?(:crest))
  incrementBlackPrisms(0, args[1].nil? ? 1 : args[1]) if args[0] == :BLKPRISM && console == false
  ret = __core_addItemSilent(*args)

  return ret
end

def Kernel.pbItemBall(*args)
  console = false
  console = true if Input.text_input == true
  $game_switches[args[0]] = true if !$game_switches[:AngelicaTower] && (pbIsTM?(args[0]) || $cache.items[args[0]].checkFlag?(:crest))
  incrementBlackPrisms(2, args[1].nil? ? 1 : args[1]) if args[0] == :BLKPRISM && console == false
  ret = __core_itemBall_Prisms(*args)

  return ret
end

def Kernel.pbReceiveItem(*args)
  console = false
  console = true if Input.text_input == true
  console = true if caller_locations.any? { |script| script.to_s.include?("pbDebugMenu") }
  $game_switches[args[0]] = true if !$game_switches[:AngelicaTower] && (pbIsTM?(args[0]) || $cache.items[args[0]].checkFlag?(:crest))
  incrementBlackPrisms(0, args[1].nil? ? 1 : args[1]) if args[0] == :BLKPRISM && console == false
  ret = __core_pbReceiveItem(*args)

  return ret
end

def incrementBlackPrisms(obtainmentmenthod = nil, qty = 1)
  # 0 = receive
  # 1 = caught
  # 2 = itemball
  # 3 = others(illegitimate)
  return if obtainmentmenthod == nil

  if !$Trainer.prismData
    $Trainer.prismData = [0, 0, 0, 0]
  end
  $Trainer.prismData[obtainmentmenthod] += qty
end

def trackPrismData
  if !$Trainer.prismData
    $Trainer.prismData = [0, 0, 0, 0]
    return false
  end
  totalprisms = $PokemonBag.pbQuantity(:BLKPRISM)
  return false if totalprisms == 0

  sum = 0
  for i in $Trainer.prismData
    next if i == $Trainer.prismData[3]

    sum += i
  end
  if totalprisms > sum
    illegitimate = totalprisms - sum
    $Trainer.prismData[3] = illegitimate
    return true
  end
  return false
end

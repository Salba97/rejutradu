SEEDS = [:ELEMENTALSEED, :MAGICALSEED, :TELLURICSEED, :SYNTHETICSEED]
GEMS = [:FIREGEM, :WATERGEM, :ELECTRICGEM, :GRASSGEM,
        :ICEGEM, :FIGHTINGGEM, :POISONGEM, :GROUNDGEM,
        :FLYINGGEM, :PSYCHICGEM, :BUGGEM, :ROCKGEM,
        :GHOSTGEM, :DRAGONGEM, :DARKGEM, :STEELGEM,
        :NORMALGEM, :FAIRYGEM]
EVOSTONES = [
  :FIRESTONE, :THUNDERSTONE, :WATERSTONE, :LEAFSTONE, :MOONSTONE,
  :SUNSTONE, :DUSKSTONE, :DAWNSTONE, :SHINYSTONE, :ICESTONE,
  # Gen 8
  :SWEETAPPLE, :TARTAPPLE, :CRACKEDPOT, :CHIPPEDPOT, :GALARICACUFF, :GALARICAWREATH,
  # Gen 9
  :BLACKAUGURITE, :PEATBLOCK, :SCROLLOFWATERS, :SCROLLOFDARKNESS, :AUSPICIOUSARMOR,
  :MALICIOUSARMOR, :SYRUPYAPPLE, :UNREMARKABLETEACUP, :MASTERPIECETEACUP, :METALALLOY,
  # Custom
  :LINKSTONE, :LINKHEART, :APOPHYLLPAN, :XENWASTE, :NIGHTMAREFUEL, :ANCIENTTEACH,
  :REBORNFLOWER,
]
MULCH = [:GROWTHMULCH, :DAMPMULCH, :STABLEMULCH, :GOOEYMULCH]

def getMonName(species, form = 0)
  form = 0 if !species.is_a?(Numeric) && !species.is_a?(Symbol)
  if species.is_a?(Integer)
    species = $cache.pkmn.keys[species - 1]
  end
  name = $cache.pkmn[species, form].name
  return pbGetMessageFromHash(:Species, name)
end

def getOnlyMonFormName(species, form)
  formname = $cache.pkmn[species].forms[form]
  return pbGetMessageFromHash(:FormNames, formname)
end

def getItemName(item, article = nil, plural: false, useunit: nil, color: false, short: false)
  item = $cache.items.keys[item - 1] if item.is_a?(Integer)

  if plural
    name = pbGetMessageFromHash(:ItemPlurals, $cache.items[item].plural)
  elsif (useunit || (article && useunit != false)) && $cache.items[item].unit
    name = pbGetMessageFromHash(:ItemUnits, $cache.items[item].unit)
  elsif short && $cache.items[item].shortname
    name = pbGetMessageFromHash(:Items, $cache.items[item].shortname)
  else
    name = pbGetMessageFromHash(:Items, $cache.items[item].name)
  end

  articlestr = getArticleForItemName(name, item, article, plural)

  name = "\\c[1]" + name + "\\c[0]" if color
  name = articlestr + name
  return name
end

# To be overridden by translations that need to account for other things (like gender and plural) to decide which article to use
def getArticleForItemName(name, item, article, plural)
  return "" if $cache.items[item].checkFlag?(:noArticle)

  case article
    when :a, :A then articlestr = (startsWithVowelSound?(name) ? "an " : "a ")
    when :the, :The then articlestr = "the "
    else return ""
  end
  articlestr.capitalize! if [:A, :The].include?(article)
  return articlestr
end

def getItemDescription(item)
  if item.is_a?(Integer)
    item = $cache.items.keys[item - 1]
  end
  return if item.nil?

  if pbIsTM?(item)
    return getMoveDesc(pbGetTM(item))
  end
  return pbGetMessageFromHash(:ItemDescriptions, $cache.items[item].desc)
end

def getTMFromMove(move)
  for item in $cache.items.keys
    next if !pbIsTM?(item)
    return item if $cache.items[item].flags[:tm] == move
  end
  return nil
end

def getMoveName(move)
  return pbGetMessageFromHash(:MovesLong, $cache.moves[move].getFullName)
end

def getMoveShortName(move)
  return pbGetMessageFromHash(:Moves, $cache.moves[move].name)
end

def getZMoveName(move, tts: false) # for use in summary screen only
  if move == :MENACINGMOONRAZEMAELSTROM && !tts # full name doesn't fit
    return Reborn ? _INTL("M. Moonraze Maelstrom") : _INTL("Menace Moonraze Maelstrom")
  end
  name = getMoveName(move)
  name = "Z-" + name if $cache.moves[move].category == :status && !PBStuff::UniqueStatusZMoves.include?(move)
  return name
end

def getMoveType(move)
  return :QMARKS if move == :FAKEMOVE

  return $cache.moves[move].type
end

def getMoveCategory(move)
  return $cache.moves[move].category
end

def getNatureName(nature)
  return "" if $cache.natures[nature].nil?

  return pbGetMessageFromHash(:Natures, $cache.natures[nature].name)
end

def getMoveDesc(move)
  return "" if $cache.moves[move].nil?

  return pbGetMessageFromHash(:MoveDescriptions, $cache.moves[move].desc)
end

def getAllMoves
  return $cache.moves.keys.filter { |move| !(PBStuff::ANIMATIONDUMMIES + PBStuff::ZMOVES).include?(move) }
end

def getAllTutorMoves
  return TUTORMOVES.dup
end

def getAllTMMoves # Accounts for randomizer
  tmlist = []
  for item, itemdata in $cache.items
    next unless itemdata.checkFlag?(:tm)
    tmlist.push(pbGetTM(item))
  end
  return tmlist
end

def isTutorOrTM?(move)
  return true if getAllTutorMoves.include?(move)
  return true if getAllTMMoves.include?(move)
  return false
end

def getTypeName(type)
  return "" if $cache.types[type].nil?

  return pbGetMessageFromHash(:Types, $cache.types[type].name)
end

def getAbilityName(abil, short = false)
  return "" if $cache.abil[abil].nil?

  ret = short ? $cache.abil[abil].name : $cache.abil[abil].fullName
  ret = pbGetMessageFromHash(:Abilities, ret) if short
  ret = pbGetMessageFromHash(:AbilitiesLong, ret) if !short
  ret = ret.gsub(/\\[Pp][Nn]/, $Trainer.name) if $Trainer
  return ret
end

def getAbilityNameUnique(abil)
  name = getAbilityName(abil)
  addition = {
    :HAILWARNING => _INTL("Hail"),
    :SNOWWARNING => _INTL("Snow"),
    :ASONECHILLING => _INTL("Ice"),
    :ASONEGRIM => _INTL("Shadow"),
    :EMBODYASPECTTEAL => _INTL("Teal"),
    :EMBODYASPECTWELLSPRING => _INTL("Wellspring"),
    :EMBODYASPECTHEARTHFLAME => _INTL("Hearthflame"),
    :EMBODYASPECTCORNERSTONE => _INTL("Cornerstone"),
  }[abil]
  name = name + " (#{addition})" if addition
  return name
end

def getAbilityDesc(abil, short = false)
  return "" if $cache.abil[abil].nil?

  desc = short ? $cache.abil[abil].desc : $cache.abil[abil].fullDesc
  return pbGetMessageFromHash(:AbilityDescs, desc) if short
  return pbGetMessageFromHash(:AbilityDescsLong, desc)
end

def getStatName(stat, mode = :battle)
  case mode
    when :battle
      array = [_INTL("HP"), _INTL("Attack"), _INTL("Defense"), _INTL("Sp. Atk"), _INTL("Sp. Def"), _INTL("Speed"), _INTL("accuracy"), _INTL("evasiveness")]
    when :full
      array = [_INTL("HP"), _INTL("Attack"), _INTL("Defense"), _INTL("Special Attack"), _INTL("Special Defense"), _INTL("Speed"), _INTL("Accuracy"), _INTL("Evasion")]
    when :desc
      array = [_INTL("HP"), _INTL("Attack"), _INTL("Defense"), _INTL("Sp. Atk"), _INTL("Sp. Def"), _INTL("Speed"), _INTL("Accuracy"), _INTL("Evasion")]
    when :short
      array = [_INTL("HP"), _INTL("ATK"), _INTL("DEF"), _INTL("SPA"), _INTL("SPD"), _INTL("SPE"), _INTL("ACC"), _INTL("EVA")]
    when :supershort
      array = [_INTL("HP"), _INTL("Atk"), _INTL("Def"), _INTL("SpA"), _INTL("SpD"), _INTL("Spe"), _INTL("Acc"), _INTL("Eva")]
  end
  return array[stat]
end

def getAllPokemonColors
  return {
    "Green" => _INTL("Green"),
    "Red" => _INTL("Red"),
    "Black" => _INTL("Black"),
    "Blue" => _INTL("Blue"),
    "White" => _INTL("White"),
    "Brown" => _INTL("Brown"),
    "Yellow" => _INTL("Yellow"),
    "Purple" => _INTL("Purple"),
    "Pink" => _INTL("Pink"),
    "Gray" => _INTL("Gray"),
  }
end

def getPokemonColorName(color)
  return getAllPokemonColors[color]
end

def getAllPokemonShapes
  return {
    :quadruped => _INTL("Quadruped"),
    :bipedtail => _INTL("Biped, tailed"),
    :bipednotail => _INTL("Biped, no tail"),
    :tentacles => _INTL("Multiped"),
    :insectoid => _INTL("Insectoid"),
    :fins => _INTL("Finned"),
    :serpentine => _INTL("Serpentine"),
    :onewings => _INTL("Winged (single)"),
    :manywings => _INTL("Winged (many)"),
    :headonly => _INTL("Head only"),
    :headbase => _INTL("Head and base"),
    :headlegs => _INTL("Head and legs"),
    :headarms => _INTL("Head and arms"),
    :multibody => _INTL("Multiple bodies"),
  }
end

def getPokemonShapeName(shape)
  return getAllPokemonShapes[shape]
end

def getGenderRatioName(genderRatio)
  return {
    :Genderless => _INTL("Genderless"),
    :MaleZero => "♀ 100%",
    :FemZero => "♂ 100%",
    :FemEighth => "♂ 87.5% / ♀ 12.5%",
    :FemQuarter => "♂ 75% / ♀ 25%",
    :FemHalf => "♂ 50% / ♀ 50%",
    :MaleQuarter => "♂ 25% / ♀ 75%",
    :MaleEighth => "♂ 12.5% / ♀ 87.5%",
  }[genderRatio]
end

def getGrowthRateName(growthRate)
  return {
    :MediumFast => _INTL("Medium Fast"),
    :Erratic => _INTL("Erratic"),
    :Fluctuating => _INTL("Fluctuating"),
    :MediumSlow => _INTL("Medium Slow"),
    :Fast => _INTL("Fast"),
    :Slow => _INTL("Slow"),
  }[growthRate]
end

def getAllEggGroups
  return {
    :Amorphous => _INTL("Amorphous"),
    :Bug => _INTL("Bug"),
    :Ditto => _INTL("Ditto"),
    :Dragon => _INTL("Dragon"),
    :Fairy => _INTL("Fairy"),
    :Field => _INTL("Field"),
    :Flying => _INTL("Flying"),
    :Grass => _INTL("Grass"),
    :HumanLike => _INTL("Human-Like"),
    :Mineral => _INTL("Mineral"),
    :Monster => _INTL("Monster"),
    :Undiscovered => _INTL("Undiscovered"),
    :Water1 => _INTL("Water 1"),
    :Water2 => _INTL("Water 2"),
    :Water3 => _INTL("Water 3"),
  }
end

def getEggGroupName(eggGroup)
  return getAllEggGroups[eggGroup]
end

# Used for prices
def getPurchaseDisplay(value, shorthand: true, commas: true, currency: :Money)
  return $cache.currencies[currency].format(value, shorthand, commas)
end

# Used for listing currency
# Leave value nil when you just need the string without a number
def getCurrencyDisplay(value = nil, shorthand: true, commas: true, currency: :Money)
  obj = $cache.currencies[currency]
  plural = value != 1
  display = "#{shorthand ? obj.getShorthand(plural) : obj.getName(plural)}:"
  return display if value.nil?
  return display + " #{commas ? pbCommaNumber(value) : value}"
end

def getCurrencyName(currency, plural = true)
  return $cache.currencies[currency].getName(plural)
end

def getCurrencyShorthand(currency, plural = true)
  return $cache.currencies[currency].getShorthand(plural)
end

def getCurrencyDescription(currency)
  return $cache.currencies[currency].getDescription
end

def startsWithVowelSound?(itemname)
  return false if itemname == ""

  return false if ["Utility Umbrella"].include?(itemname)
  return true if itemname.start_with?(/[aeiou]/i)
  return true if itemname.start_with?("N-") # N-Solarizer/N-Lunarizer
  firstword = itemname.split(" ")[0]
  firstword.gsub!(/\d/, "") # get rid of any numbers in the string (for HM and RM names)
  return true if ["HP", "X", "'R'", "HM", "SPU", "RM"].include?(firstword)

  return false
end

# Used in stat change messages, field notes and other places
# Uses Oxford comma
# Use "" as conjunctive if only commas are to be used throughout
def joinStrings(strings, conjunctive = nil)
  conjunctive = conjunctive.nil? ? _INTL("and") : conjunctive
  finalstring = ""
  strings.each_with_index { |string, i|
    if i > 0
      if i != strings.length - 1 || conjunctive.empty?
        finalstring += ", "
      elsif strings.length > 2
        finalstring += ", #{conjunctive} "
      else
        finalstring += " #{conjunctive} "
      end
    end
    finalstring += string
  }
  return finalstring
end

def pbIsHiddenMove?(move)
  return false if !$cache.items

  for i in 0...$cache.items.length
    next if !$cache.items[i]

    atk = pbGetTM(item)
    next if !atk
    return true if move == atk
  end
  return false
end

def pbGetPocket(item)
  itemdata = $cache.items[item]
  return 2 if (itemdata.medicine && !itemdata.berry) || itemdata.checkFlag?(:battleitem)
  return 3 if itemdata.checkFlag?(:ball)
  return 4 if itemdata.checkFlag?(:tm)
  return 5 if itemdata.berry
  return 6 if itemdata.checkFlag?(:crystal) || itemdata.checkFlag?(:crest)
  return 7 if false
  return 8 if itemdata.checkFlag?(:keyitem)

  return 1
end

# Important items can't be sold, given to hold, or tossed.
def pbIsImportantItem?(item)
  return pbIsKeyItem?(item) || pbIsTM?(item) || pbIsZCrystal?(item) || $cache.items[item].checkFlag?(:repeatableUse)
end

def isUsableItem?(item)
  return !$cache.items[item].checkFlag?(:noUse)
end

def shouldShowQuantity?(item)
  return !pbIsImportantItem?(item) || $cache.items[item].checkFlag?(:showQuantity)
end

def pbIsTM?(item)
  return item.nil? ? false : $cache.items[item].checkFlag?(:tm) ? true : false
end

def pbGetTM(item)
  return item.nil? ? false : $cache.items[item].checkFlag?(:tm)
end

def pbGetMachineMoveName(machine)
  return getMoveName(pbGetTM(machine))
end

def pbIsMail?(item)
  return item.nil? ? false : $cache.items[item].checkFlag?(:mail)
end

def pbIsPokeBall?(item)
  return item.nil? ? false : $cache.items[item].checkFlag?(:ball)
end

def pbIsBerry?(item)
  return item.nil? ? false : !$cache.items[item].berry.nil?
end

def pbIsApricorn?(item)
  return pbIsBerry?(item) && $cache.items[item].name.include?("Apricorn")
end

def pbIsSeed?(item)
  return item.nil? ? false : SEEDS.include?(item)
end

def pbIsTypeGem?(item)
  return item.nil? ? false : $cache.items[item].checkFlag?(:gem)
end

def pbIsKeyItem?(item)
  return item.nil? ? false : $cache.items[item].checkFlag?(:keyitem)
end

def pbIsZCrystal?(item)
  return item.nil? ? false : $cache.items[item].zmove
end

def pbIsCrest?(item)
  return item.nil? ? false : $cache.items[item].checkFlag?(:crest)
end

def pbIsTypeZCrystal?(item)
  return false if item.nil?

  zmove = $cache.items[item].zmove
  return zmove && $cache.moves[zmove]&.zmovedata&.type
end

def pbIsMegaStone?(item)
  return item.nil? ? false : $cache.items[item].checkFlag?(:crystal) && !$cache.items[item].zmove && ![:REDORB, :BLUEORB].include?(item)
end

def pbIsMint?(item)
  return item.nil? ? false : $cache.items[item].checkFlag?(:mint)
end

def pbIsNectar?(item)
  return item.nil? ? false : $cache.items[item].checkFlag?(:nectar)
end

def pbIsEvolutionStone?(item)
  return item.nil? ? false : EVOSTONES.include?(item)
end

def pbIsMulch?(item)
  return item.nil? ? false : MULCH.include?(item)
end

def pbIsGoodItem(item)
  return false if item.nil?

  return [:CHOICEBAND, :CHOICESCARF, :CHOICESPECS, :FOCUSSASH,
          :LUCKYEGG, :EXPSHARE, :LIFEORB, :LEFTOVERS, :EVIOLITE,
          :ASSAULTVEST, :ROCKYHELMET].include?(item) || pbIsMegaStone?(item)
end

def itemChoicesWithQty(items)
  choices = {}
  items.each do |item|
    choices[item] = getItemName(item) + " <r>x " + $PokemonBag.pbQuantity(item).to_s
  end
  return choices
end

# The text in the windows in the methods below works because the font used has the same width for all digits and +/- symbols
# \u2007 (figure space) is a whitespace character of the same width as those
def pbStatChangeDisplayWindow(pokemon, oldstats, highlight: true)
  return nil if $game_switches[:Blindstep] || $game_switches[:SpeedSkip_Password]

  newstats = pokemon.getStats
  return nil if newstats == oldstats

  colortags = isCurrentWindowskinDark ? ColorTags : LightColorTags
  statdiffs = (0...6).map { |i| newstats[i] - oldstats[i] }
  statsize = newstats.max.to_s.length
  diffsize = sprintf("%+d", statdiffs.max).length
  space = "\u2007" * 3

  strings = []
  for i in 0...6
    statdiff = statdiffs[i]
    tags = case true
      when !highlight then ["", ""]
      when statdiff > 0 then [colortags[:Red], "</c3>"]
      when statdiff < 0 then [colortags[:Blue], "</c3>"]
      else ["<o=128>", "</o>"]
    end
    statname = i == 0 ? _INTL("Max. HP") : getStatName(i)
    statdiffstr = statdiff == 0 ? "-" * diffsize : sprintf("%+d", statdiff).rjust(diffsize, "\u2007")
    newstatstr = newstats[i].to_s.rjust(statsize, "\u2007")
    strings.push(statname + "<r>" + space + tags[0] + statdiffstr + space + newstatstr + tags[1])
  end
  string = strings.join("\n")

  window = Window_AdvancedTextPokemon.new(string)
  window.z = 99999
  window.y = 0
  window.x = Graphics.width - window.width
  return window
end

def pbUsedItemsDisplay(message, useditems)
  colortags = isCurrentWindowskinDark ? ColorTags : LightColorTags
  space = "\u2007" * 2

  itemstrings = []
  for item, amount in useditems
    itemname = colortags[:Blue2] + getItemName(item) + "</c3>"
    usedstr = "-" + amount.to_s
    qty = $PokemonBag.pbQuantity(item)
    leftstr = qty.to_s.rjust(3, "\u2007")
    leftstr = colortags[:Red2] + leftstr + "</c3>" if qty <= (pbIsBerry?(item) ? 1 : 0)
    itemstrings.push(itemname + "<r>" + space + usedstr + space + leftstr)
  end

  windowstrings = []
  itemstrings.each_slice(8) { |slice| windowstrings.push(slice.join("\n")) } # One window can only fit 8 items

  pbDisplayMessageWithMultipleWindows(message, windowstrings)
end

def pbDisplayMessageWithMultipleWindows(message, windowstrings)
  msgwindow = Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(
    msgwindow, message, false,
    proc { |msgwindow|
      while !windowstrings.empty?
        displaywindow = Window_AdvancedTextPokemon.new(windowstrings.shift)
        displaywindow.z = 99999
        pbPositionNearMsgWindow(displaywindow, msgwindow, :right)
        loop do
          Graphics.update
          Input.update
          if Input.trigger?(Input::C)
            displaywindow.dispose
            break
          end
        end
      end
    }
  )
  Kernel.pbDisposeMessageWindow(msgwindow)
end

class ItemHandlerHash < HandlerHash
  def initialize
    super(:PBItems)
  end
end

module ItemHandlers
  UseFromBag = ItemHandlerHash.new
  UseInField = ItemHandlerHash.new
  UseOnPokemon = ItemHandlerHash.new
  BattleUseOnBattler = ItemHandlerHash.new
  BattleUseOnPokemon = ItemHandlerHash.new
  UseInBattle = ItemHandlerHash.new
  MultipleAtOnce = [
    :EXPCANDYL, :EXPCANDYXL, :EXPCANDYM, :EXPCANDYS, :EXPCANDYXS,
    :COMMONCANDY, :REVERSECANDY, :RARECANDY,
    :PHANTOMCANDYS, :PHANTOMCANDYM,
    :HPUP, :PROTEIN, :IRON, :CALCIUM, :ZINC, :CARBOS,
    :HEALTHWING, :MUSCLEWING, :RESISTWING, :GENIUSWING, :CLEVERWING, :SWIFTWING,
    :POMEGBERRY, :KELPSYBERRY, :QUALOTBERRY, :HONDEWBERRY, :GREPABERRY, :TAMATOBERRY,
  ]

  def self.addUseFromBag(item, proc)
    UseFromBag.add(item, proc)
  end

  def self.addUseInField(item, proc)
    UseInField.add(item, proc)
  end

  def self.addUseOnPokemon(item, proc)
    UseOnPokemon.add(item, proc)
  end

  def self.addBattleUseOnBattler(item, proc)
    BattleUseOnBattler.add(item, proc)
  end

  def self.addBattleUseOnPokemon(item, proc)
    BattleUseOnPokemon.add(item, proc)
  end

  def self.hasOutHandler(item) # Shows "Use" option in Bag
    return !UseFromBag[item].nil? || !UseOnPokemon[item].nil?
  end

  def self.hasUseOnPokemonHandler(item) # Can select item for "Use" from party screen
    return !UseOnPokemon[item].nil?
  end

  def self.hasKeyItemHandler(item) # Shows "Register" option in Bag
    return !UseInField[item].nil?
  end

  def self.hasBattleUseOnBattler(item)
    return !BattleUseOnBattler[item].nil?
  end

  def self.hasBattleUseOnPokemon(item)
    return !BattleUseOnPokemon[item].nil?
  end

  def self.hasUseInBattle(item)
    return !UseInBattle[item].nil?
  end

  def self.triggerUseFromBag(item)
    # Return value:
    # 0 - Item not used
    # 1 - Item used, don't end screen
    # 2 - Item used, end screen
    # 3 - Item used, consume item
    # 4 - Item used, end screen, consume item
    if !UseFromBag[item]
      # Check the UseInField handler if present
      if UseInField[item]
        UseInField.trigger(item)
        return 1 # item was used
      end
      return 0 # item was not used
    else
      UseFromBag.trigger(item)
    end
  end

  def self.triggerUseInField(item)
    # No return value
    if !UseInField[item]
      return false
    else
      UseInField.trigger(item)
      return true
    end
  end

  def self.triggerUseOnPokemon(item, pokemon, scene)
    # Returns whether item was used
    if !UseOnPokemon[item]
      return false
    else
      return UseOnPokemon.trigger(item, pokemon, scene)
    end
  end

  def self.triggerBattleUseOnBattler(item, battler, scene)
    # Returns whether item was used
    if !BattleUseOnBattler[item]
      return false
    else
      return BattleUseOnBattler.trigger(item, battler, scene)
    end
  end

  def self.triggerBattleUseOnPokemon(item, pokemon, battler, scene)
    # Returns whether item was used
    if !BattleUseOnPokemon[item]
      return false
    else
      return BattleUseOnPokemon.trigger(item, pokemon, battler, scene)
    end
  end

  def self.checkUseInBattle(item, battler, scene)
    return unless BattleUseOnBattler[item]
    return BattleUseOnBattler.trigger(item, battler, scene)
  end

  def self.triggerUseInBattle(item, battler, battle)
    return false unless UseInBattle[item]
    return UseInBattle.trigger(item, battler, battle)
  end
end

def pbHPItem(pokemon, battler, restorehp, scene)
  if pokemon.hp <= 0 || pokemon.hp == pokemon.totalhp || pokemon.status == :PETRIFIED
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  else
    scene.pbCommonAnimation("UseItemBag", battler, nil) if battler
    pbItemRestoreHP(pokemon, battler, restorehp, scene)
    return true
  end
end

def pbItemRestoreHP(pokemon, battler, restorehp, scene)
  healing = getItemHP(restorehp, pokemon.totalhp)
  newhp = pokemon.hp + healing
  newhp = pokemon.totalhp if newhp > pokemon.totalhp
  hpgain = newhp - pokemon.hp
  pokemon.hp = newhp
  return unless hpgain > 0

  if battler
    battler.pbRecoverHP(hpgain, true, message: _INTL("{1}'s HP was restored.", battler.pbThis), fullrecover: restorehp == 1.0)
  else
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.", pokemon.name, hpgain))
  end
end

def pbReviveItem(pokemon, battler, restorehp, scene)
  restorehp = getItemHP(restorehp, pokemon.totalhp)
  if pokemon.hp > 0 || $game_switches[:Nuzlocke_Mode] || pokemon.unusable
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  else
    pokemon.healStatus
    pokemon.hp = restorehp
    if battler && battler.battle.pbPartySingleOwner(battler.index).any? { |i| i == pokemon }
      battler.pbReset
      # battler.pbInitialize(pokemon,i,false)
    end
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored.", pokemon.name))
    return true
  end
end

def getItemHP(restorehp, totalhp)
  unless restorehp.is_a?(Integer)
    restorehp = [(totalhp * restorehp.to_f).floor, 1].max
  end
  return restorehp
end

def pbStatusItem(pokemon, battler, curestatus, scene)
  if pokemon.hp <= 0 || !pokemon.status || ![pokemon.status, :FULLHEAL].include?(curestatus)
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  else
    scene.pbCommonAnimation("UseItemBag", battler, nil) if battler
    pbItemCureStatus(pokemon, battler, curestatus, scene)
    return true
  end
end

def pbItemCureStatus(pokemon, battler, curestatus, scene)
  oldstatus = pokemon.status
  pokemon.healStatus
  if battler
    battler.pbCureStatus
    battler.pbCureConfusion if curestatus == :FULLHEAL
  end
  unless battler
    scene.pbRefresh
    message = nil
    case oldstatus
      when :SLEEP     then message = _INTL("{1} woke up!", pokemon.name)
      when :POISON    then message = _INTL("{1} was cured of its poisoning!", pokemon.name)
      when :BURN      then message = _INTL("{1}'s burn was healed!", pokemon.name)
      when :PARALYSIS then message = _INTL("{1} was cured of paralysis!", pokemon.name)
      when :FROZEN    then message = _INTL("{1} thawed out!", pokemon.name)
      when :PETRIFIED then message = _INTL("{1} was released from the stone.", pokemon.name)
    end
    scene.pbDisplay(message) if message
  end
end

def pbRaiseEffortValues(pokemon, ev, evgain = 32, evlimit = true)
  totalev = pokemon.ev.sum
  evgain = 510 - totalev if totalev + evgain > 510 && !$game_switches[:No_Total_EV_Cap]
  evgain = 252 - pokemon.ev[ev] if pokemon.ev[ev] + evgain > 252
  if evgain > 0
    pokemon.ev[ev] += evgain
    pokemon.calcStats
  end
  return evgain
end

def pbRestorePP(pokemon, move, pp)
  return 0 if pokemon.moves[move].move.nil?
  return 0 if pokemon.moves[move].totalpp == 0

  newpp = pokemon.moves[move].pp + pp
  if newpp > pokemon.moves[move].totalpp
    newpp = pokemon.moves[move].totalpp
  end
  oldpp = pokemon.moves[move].pp
  pokemon.moves[move].pp = newpp
  return newpp - oldpp
end

def pbBattleRestorePP(pokemon, battler, move, pp)
  ret = pbRestorePP(pokemon, move, pp)
  if ret > 0
    battler.pbSetPP(battler.moves[move], pokemon.moves[move].pp) if battler
  end
  return ret
end

def pbBikeCheck
  if $PokemonGlobal.surfing || $PokemonGlobal.lavasurfing ||
     (!$PokemonGlobal.bicycle && ([PBTerrain::TallGrass, PBTerrain::SandDune, PBTerrain::Ice].include?(pbGetTerrainTag)))
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
    return false
  end
  if $PokemonGlobal.bicycle
    return true
  else
    val = $cache.mapdata[$game_map.map_id].Bicycle
    val = $cache.mapdata[$game_map.map_id].Outdoor if val == nil
    if !val
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end
    return true
  end
end

def pbClosestHiddenItem
  result = []
  playerX = $game_player.x
  playerY = $game_player.y
  for event in $game_map.events.values
    blindstepItem = false
    if $game_switches[:Blindstep]
      character = event.nil? ? "" : event.character_name
      blindstepItem = character.start_with?("itemball") || character == "zycell"
    end
    next unless event.name == "HiddenItem" || blindstepItem
    next if (playerX - event.x).abs >= 8
    next if (playerY - event.y).abs >= 6
    next if $game_self_switches[[$game_map.map_id, event.id, "A"]]
    next if $game_self_switches[[$game_map.map_id, event.id, "B"]]
    next if $game_self_switches[[$game_map.map_id, event.id, "C"]]
    next if $game_self_switches[[$game_map.map_id, event.id, "D"]]

    result.push(event)
  end
  return nil if result.length == 0

  ret = nil
  retmin = 0
  for event in result
    dist = (playerX - event.x).abs + (playerY - event.y).abs
    if !ret || retmin > dist
      ret = event
      retmin = dist
    end
  end
  return ret
end

def Kernel.pbUseKeyItemInField(item)
  if !ItemHandlers.triggerUseInField(item)
    Kernel.pbMessage(_INTL("Can't use that here.")) if $game_switches[:Application_Applied] == false
  end
end

def pbForgetMove(pokemon, moveToLearn)
  ret = -1
  pbFadeOutIn(99999) {
    scene = PokemonSummaryScene.new
    screen = PokemonSummary.new(scene)
    ret = screen.pbStartForgetScreen([pokemon], 0, moveToLearn)
  }
  return ret
end

def pbTryLearnMove(pokemon, move, ignoreifknown: false, dontrestorePP: false, debug: false)
  return false if !pokemon

  movename = getMoveName(move)
  if pokemon.isEgg? && !debug
    Kernel.pbMessage(_INTL("{1} can't be taught to an Egg.", movename))
    return false
  end
  if pokemon.respond_to?("isShadow?") && pokemon.isShadow?
    Kernel.pbMessage(_INTL("{1} can't be taught to this Pokémon.", movename))
    return false
  end

  pkmnname = pokemon.name
  if pokemon.knowsMove?(move)
    Kernel.pbMessage(_INTL("{1} already knows\n{2}.", pkmnname, movename)) unless ignoreifknown
    return false
  end

  for i in 0...4
    if pokemon.moves[i].nil?
      pokemon.pbLearnMoveAtIndex(move, i)
      Kernel.pbMessage(_INTL("{1} learned\n{2}!\\se[itemlevel]", pkmnname, movename))
      return true
    end
  end
  Kernel.pbMessage(_INTL("{1} wants to learn the\nmove {2}.", pkmnname, movename)) unless debug
  if debug || Kernel.pbConfirmMessage(_INTL("Should another move be forgotten and replaced with {1}?", movename))
    forgetmove = pbForgetMove(pokemon, move)
    if forgetmove >= 0
      oldmovename = getMoveName(pokemon.moves[forgetmove].move)
      pokemon.pbLearnMoveAtIndex(move, forgetmove, dontrestorePP: dontrestorePP)
      Kernel.pbMessage(_INTL("\\se[]One...\\wt[8]two...\\wt[8]and...\\wt[12]ta-da!\\se[balldrop]")) unless debug
      Kernel.pbMessage(_INTL("{1} forgot {2}...\nand it learned {3} instead!\\se[itemlevel]", pkmnname, oldmovename, movename))
      return true
    end
  end
  return false
end

def pbCheckUseOnPokemon(item, pokemon, screen)
  return pokemon && !pokemon.isEgg?
end

def pbUseItemOnPokemon(item, pokemon, scene)
  if pbIsTM?(item)
    machine = pbGetTM(item)
    return false if machine == nil

    movename = getMoveName(machine)
    if (pokemon.isShadow? rescue false)
      Kernel.pbMessage(_INTL("Shadow Pokémon can't be taught any moves."))
    elsif !pokemon.isCompatibleWithMove?(machine)
      Kernel.pbMessage(_INTL("{1} is not compatible with {2}, so it can't be learned.", movename, pokemon.name))
    else
      if $cache.items[item].checkFlag?(:tmx)
        Kernel.pbMessage(_INTL("\\se[accesspc]Booted up a TMX.\nIt contained {1}.", movename))
      elsif $cache.items[item].name.to_s.include?("RM")
        Kernel.pbMessage(_INTL("\\se[accesspc]Booted up an RM.\nIt contained {1}.", movename))
      else
        Kernel.pbMessage(_INTL("\\se[accesspc]Booted up a TM.\nIt contained {1}.", movename))
      end
      if Kernel.pbConfirmMessage(_INTL("Teach {1} to {2}?", movename, pokemon.name))
        if pbTryLearnMove(pokemon, machine, dontrestorePP: true)
          $PokemonBag.pbDeleteItem(item) if pbIsTM?(item) && !INFINITETMS
          return true
        end
      end
    end
    return false
  else
    ret = ItemHandlers.triggerUseOnPokemon(item, pokemon, scene)
    if ret && !pbIsImportantItem?(item)
      $PokemonBag.pbDeleteItem(item)
      if $PokemonBag.pbQuantity(item) <= 0
        Kernel.pbMessage(_INTL("You used your last {1}.", getItemName(item)))
      end
    end
    return ret
  end
end

def pbUseItem(bag, item, bagscene = nil)
  found = false
  intret = ItemHandlers.triggerUseFromBag(item)
  case intret
    when 0
      if pbGetTM(item)
        ret = true
        if $Trainer.pokemonCount == 0
          Kernel.pbMessage(_INTL("There is no Pokémon."))
          return 0
        end
        movename = pbGetMachineMoveName(item)
        if $cache.items[item].checkFlag?(:tmx)
          Kernel.pbMessage(_INTL("\\se[accesspc]Booted up a TMX.\nIt contained {1}.", movename))
        elsif $cache.items[item].name.to_s.include?("RM")
          Kernel.pbMessage(_INTL("\\se[accesspc]Booted up an RM.\nIt contained {1}.", movename))
        else
          Kernel.pbMessage(_INTL("\\se[accesspc]Booted up a TM.\nIt contained {1}.", movename))
        end
        if !Kernel.pbConfirmMessage(_INTL("Teach {1} to a Pokémon?", movename))
          return 0
        elsif pbMoveTutorChoose(pbGetTM(item), bymachine: true)
          bag.pbDeleteItem(item) if pbIsTM?(item) && !INFINITETMS
          return 1
        else
          return 0
        end
      elsif isUsableItem?(item) # Item is usable on a Pokémon
        if $Trainer.pokemonCount == 0
          Kernel.pbMessage(_INTL("There is no Pokémon."))
          return 0
        end
        ret = false
        annot = nil
        if pbIsEvolutionStone?(item)
          annot = []
          for pkmn in $Trainer.party
            elig = !checkEvolution(pkmn, useditem: item).nil?
            text = elig ? _INTL("Able") : _INTL("Not Able")
            colors = elig ? ANNOT_ELIGIBLE_COLORS : ANNOT_INELIGIBLE_COLORS
            annot.push([text, colors])
          end
        end
        pbFadeOutIn(99999) {
          scene = PokemonScreen_Scene.new
          screen = PokemonScreen.new(scene, $Trainer.party)
          screen.pbStartScene(_INTL("Use on which Pokémon?"), annot)
          loop do
            scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
            chosen = screen.pbChoosePokemon
            if chosen >= 0
              pokemon = $Trainer.party[chosen]
              if !pbCheckUseOnPokemon(item, pokemon, screen)
                pbPlayBuzzerSE()
                next
              end
              # Option to use multiple of the item at once
              if ItemHandlers::MultipleAtOnce.include?(item)
                # Asking how many
                viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
                viewport.z = 99999
                helpwindow = Window_UnformattedTextPokemon.new("")
                helpwindow.viewport = viewport
                amount = UIHelper.pbChooseNumber(helpwindow, _INTL("How many do you want to use?"), bag.pbQuantity(item))
                helpwindow.dispose
                viewport.dispose

                # Applying it
                ret, amount_consumed = ItemHandlers::UseOnPokemon.trigger(item, pokemon, scene, amount)
                if ret # Usable on Pokémon, consumed
                  bag.pbDeleteItem(item, amount_consumed)
                end
                if bag.pbQuantity(item) <= 0
                  Kernel.pbMessage(_INTL("You used your last {1}.", getItemName(item))) if bag.pbQuantity(item) <= 0
                  break
                end
                break if !ret
              else
                ret = ItemHandlers.triggerUseOnPokemon(item, pokemon, screen)
                if ret && !pbIsImportantItem?(item)
                  bag.pbDeleteItem(item)
                end
                if bag.pbQuantity(item) <= 0
                  Kernel.pbMessage(_INTL("You used your last {1}.", getItemName(item))) if bag.pbQuantity(item) <= 0
                  break
                end
              end
            else
              ret = false
              break
            end
          end
          screen.pbEndScene
          bagscene.pbRefresh if bagscene
        }
        return ret ? 1 : 0
      end
    when 1 # Item used
      return 1
    when 2 # Item used, end screen
      return 2
    when 3 # Item used, consume item
      bag.pbDeleteItem(item)
      return 1
    when 4 # Item used, end screen and consume item
      bag.pbDeleteItem(item)
      return 2
  end
end

def Kernel.pbChooseItem(var = 0)
  ret = 0
  scene = PokemonBag_Scene.new
  screen = PokemonBagScreen.new(scene, $PokemonBag)
  pbFadeOutIn(99999) {
    ret = screen.pbChooseItemScreen
  }
  $game_variables[var] = ret if var > 0
  return ret
end

# Shows a list of items to choose from, with the chosen item's ID being stored
# in the given Global Variable. Only items which the player has are listed.
def pbChooseItemFromList(message, variable, *args)
  commands = []
  items = []
  for item in args
    if $PokemonBag.pbQuantity(item) > 0
      commands.push(getItemName(item))
      items.push(item)
    end
  end
  if commands.length == 0
    $game_variables[variable] = 0
    return nil
  end
  commands.push(_INTL("Cancel"))
  items.push(nil)
  ret = Kernel.pbMessage(message, commands, -1)
  if ret < 0 || ret >= commands.length - 1
    $game_variables[variable] = -1
    return nil
  else
    $game_variables[variable] = items[ret]
    return items[ret]
  end
end

def pbGiveItem(item, pkmn, screen, scene, zcrystal: false)
  if pkmn.isEgg?
    screen.pbDisplay(_INTL("Eggs can't hold items."))
    return false
  end
  if pkmn.mail
    screen.pbDisplay(_INTL("Mail must be removed before holding an item."))
    return false
  end
  if pkmn.item == item
    screen.pbDisplay(_INTL("{1} is already holding {2}.", pkmn.name, getItemName(item, :a)))
    return false
  end
  if hasActiveRentalTeam?()
    screen.pbDisplay(_INTL("You are not allowed to change the rental team's items."))
    return false
  end
  if (item == :BLUEORB && pkmn.species != :KYOGRE) || (item == :REDORB && pkmn.species != :GROUDON)
    screen.pbDisplay(_INTL("{1} can't be held by {2}!", getItemName(item, :The), pkmn.name))
    return false
  end

  screen.pbDisplay(_INTL("{1} will be given to {2} so that it can use its Z-Power!", getItemName(item, :A), pkmn.name)) if zcrystal

  if pkmn.item
    screen.pbDisplay(_INTL("{1} is already holding {2}.\1", pkmn.name, getItemName(pkmn.item, :a)))
    if screen.pbConfirm(_INTL("Would you like to switch the two items?"))
      if !$PokemonBag.pbStoreItem(pkmn.item)
        screen.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
      else
        if !pbIsMail?(item) || pbMailScreen(item, pkmn, screen, scene) # Open the mail screen if necessary
          $PokemonBag.pbDeleteItem(item) unless zcrystal
          screen.pbDisplay(_INTL("{1} was taken and replaced with {2}.", getItemName(pkmn.item, :The), getItemName(item, :the)))
          pkmn.setItem(item)
          pkmn.checksAfterItemChange
          return true
        end
      end
    end
  else
    if !pbIsMail?(item) || pbMailScreen(item, pkmn, screen, scene) # Open the mail screen if necessary
      $PokemonBag.pbDeleteItem(item) unless zcrystal
      pkmn.setItem(item)
      screen.pbDisplay(_INTL("{1} was given {2} to hold.", pkmn.name, getItemName(item, :the)))
      pkmn.checksAfterItemChange
      return true
    end
  end
  return false
end

def pbTakeItem(pkmn, screen)
  if !pkmn.hasAnItem?
    screen.pbDisplay(_INTL("{1} isn't holding anything.", pkmn.name))
  elsif !$PokemonBag.pbCanStore?(pkmn.item)
    screen.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
  elsif pkmn.mail
    # if screen.pbConfirm(_INTL("Send the removed mail to your PC?"))
    #   if !pbMoveToMailbox(pkmn)
    #     screen.pbDisplay(_INTL("Your PC's Mailbox is full."))
    #   else
    #     screen.pbDisplay(_INTL("The mail was sent to your PC."))
    #     pkmn.setItem(nil)
    #   end
    # els
    if screen.pbConfirm(_INTL("If the mail is removed, the message will be lost. Is that ok?"))
      $PokemonBag.pbStoreItem(pkmn.item)
      pkmn.setItem(nil)
      pkmn.mail = nil
      screen.pbDisplay(_INTL("Mail was taken from the Pokémon."))
    end
  else
    $PokemonBag.pbStoreItem(pkmn.item)
    screen.pbDisplay(_INTL("Received {1} from {2}.", getItemName(pkmn.item, :the), pkmn.name))
    pkmn.setItem(nil)
    pkmn.checksAfterItemChange
  end
end

def getFlavorName(flavor)
  case flavor
    when :spicy  then return _INTL("spicy")
    when :dry    then return _INTL("dry")
    when :sweet  then return _INTL("sweet")
    when :bitter then return _INTL("bitter")
    when :sour   then return _INTL("sour")
  end
  return nil
end

def getChessPieceName(piece)
  return case piece
    when :QUEEN then _INTL("Queen")
    when :PAWN then _INTL("Pawn")
    when :KING then _INTL("King")
    when :KNIGHT then _INTL("Knight")
    when :BISHOP then _INTL("Bishop")
    when :ROOK then _INTL("Rook")
    else nil
  end
end

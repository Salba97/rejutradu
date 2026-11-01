#===============================================================================
# Advanced Pokédex
# Original script by FL for Pokémon Essentials
# Heavily modified and adjusted for Reborn-verse engine
#===============================================================================
#
# When a switch is ON, displays pokemon data in the pokedex for caught pokemon such as
# stats, abilities, base exp, egg groups, wild held items, evolutions, movesets, etc.
#
# To make this script work, you'll need to add a 512x384 background for the main
# screen at "Graphics/Pictures/advancedPokedex", and three 512x32 graphics for
# the top pokedex selection bar at "Graphics/Pictures/advancedPokedexEntryBar",
# "Graphics/Pictures/advancedPokedexNestBar" and
# "Graphics/Pictures/advancedPokedexFormBar".
#
#===============================================================================

class AdvancedPokedexScene
  attr_reader :pagecategory

  # When true shows egg steps of the first evolution stage (incense babies included), in case current pokemon can't be an egg
  EGGSTEPSFIRSTSTAGE = true
  # When true displays TM/Tutor moves
  SHOWMACHINETUTORMOVES = true

  HeaderColorTag = LightColorTags[:Blue]
  HighlightColorTag = shadowc3tag(Color.new(77, 77, 70), Color.new(147, 151, 151)) # Slightly darkened version of the color below
  DataTextColors = LightColorArrays[:Default]
  GUITextColors = Rejuv ? ColorArrays[:Default] : LightColorArrays[:Default]
  PhysicalMoveColors = [Color.new(115, 69, 69), Color.new(184, 168, 168)]
  SpecialMoveColors = [Color.new(84, 69, 115), Color.new(173, 168, 184)]

  BASE_X = 30
  EXTRA_X = 224
  BASE_Y = 64
  EXTRA_Y = 32

  def pbStartScene(dummymon, pagecategory)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @pagecategory = pagecategory

    @dummymon = dummymon
    @species, @formnum = @dummymon.species, @dummymon.form
    @mondata = @dummymon.getCacheData

    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/advancedPokedex")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["overlay"].x = 0
    @sprites["overlay"].y = 0
    @sprites["info"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["icon"] = PokemonSpeciesIconSprite.new(@species, @dummymon.gender, @formnum, @dummymon.isShiny?, @dummymon.isShadow?, @viewport)
    @sprites["icon"].x = 52
    @sprites["icon"].y = 290
    @type1 = @mondata.Type1
    @type2 = @mondata.Type2
    @page = 1
    @totalPages = 0
    if canShowInfo?
      @infoPages = 3
      @infoArray = getInfo
      @levelMovesArray = getLevelMoves
      @levelMovesPages = (@levelMovesArray.size + 9) / 10
      @eggMovesArray = getEggMoves
      @eggMovesPages = (@eggMovesArray.size + 9) / 10
      @totalPages = @infoPages + @levelMovesPages + @eggMovesPages
      if SHOWMACHINETUTORMOVES
        machineTutorMoves = getMachineTutorMoves
        @machineMovesArray = machineTutorMoves[0]
        @machineMovesPages = (@machineMovesArray.size + 9) / 10
        @tutorMovesArray = machineTutorMoves[1]
        @tutorMovesPages = (@tutorMovesArray.size + 9) / 10
        @totalPages += @machineMovesPages + @tutorMovesPages
      end
      setPageFromPageCategory
      displayPage(false)
    else
      drawBottom
    end
    pbUpdate
    return true
  end

  def canShowInfo?
    return $Trainer.pokedex.owned?(@species, @formnum)
  end

  def getInfo
    ret = Array.new(6) { Array.new(6, "") } # 6 columns (3 pages) each with 6 rows of strings

    ### PAGE 1
    ### Abilities
    abilities = @mondata.Abilities.clone
    hidden = @mondata.HiddenAbility
    hidden = abilities.pop if abilities.length > 2 && hidden.nil? # randomizer creates 3 abilities instead of 2 abilities + 1 hidden
    headerString = abilities.length > 1 ? _INTL("Abilities:") : _INTL("Ability:")
    headerString = headerify(headerString)
    abilityString = joinStrings(abilities.map { |a| getAbilityName(a) }, "")
    ret[0][0] = headerString + " " + abilityString
    ret[0][1] = headerify(_INTL("Hidden Ability:")) + " " + getAbilityName(hidden) if hidden

    ### Base Stats
    baseStats = @mondata.BaseStats
    ret[0][2] = {
      0 => headerify(_INTL("Base Stats:")),
      EXTRA_X => highlight(_INTL("TOTAL:")) + " " + baseStats.sum.to_s,
    }
    # Using a hash so that Total is read right after Base Stats by TTS
    (0..5).each { |stat|
      column, row = stat / 3, (stat % 3) + 3
      label = highlight(getStatName(stat, :short).rjust(3, "\u2007") + ":")
      value = baseStats[stat].to_s.rjust(3, "\u2007")
      ret[column][row] = label + " " + value
    }

    ### PAGE 2
    ### Catch Rate
    ret[2][0] = headerify(_INTL("Catch Rate:")) + " " + "#{@mondata.CatchRate}/255"

    ### Base EXP Yield
    ret[2][1] = headerify(_INTL("Base EXP Yield:")) + " " + @mondata.BaseEXP.to_s

    ### EV Yield
    evstrings = @mondata.EVs.map.with_index { |num, stat| num > 0 ? num.to_s + " " + getStatName(stat) : nil }.compact
    evstring = joinStrings(evstrings, "")
    ret[2][2] = headerify(_INTL("EV Yield:")) + " " + evstring

    ### Gender Ratio
    genderstring = getGenderRatioName(@mondata.GenderRatio)
    genderstring.gsub!("♂", LightColorTags[:Blue2] + "♂" + "</c3>")
    genderstring.gsub!("♀", LightColorTags[:Red2] + "♀" + "</c3>")
    ret[2][3] = headerify(_INTL("Gender:")) + " " + genderstring

    ### Wild Held Items
    wilditems = @mondata.getWildItems
    headerString = wilditems.length > 1 ? (_INTL("Wild Held Items:")) : (_INTL("Wild Held Item:"))
    headerString = headerify(headerString)
    if wilditems.empty?
      ret[2][4] = headerString + " " + (_INTL("None"))
    else
      i = 4
      for rarity, item in wilditems
        ret[2][i] = {}
        ret[2][i][0] = headerString if i == 4
        offset = @sprites["overlay"].bitmap.text_size(toUnformattedText(headerString)).width
        itemfile = pbItemIconFile(item).gsub("Graphics/Icons/", "")
        chance = { always: 100, common: 50, uncommon: 5, rare: 1 }[rarity]
        ret[2][i][offset] = "  " + "<icon=#{itemfile}>" + "  " + getItemName(item) + " (#{chance}%)"
        i += 1
      end
    end

    ### Color
    ret[3][0] = headerify(_INTL("Color:")) + " " + getPokemonColorName(@mondata.Color)

    ### Shape
    shape = @mondata.shape
    ret[3][1] = headerify(_INTL("Shape:")) + " " + getPokemonShapeName(shape) if shape # Only Reborn has shapes rn

    ### PAGE 3
    ### Egg Groups
    headerString = @mondata.EggGroups.length > 1 ? _INTL("Egg Groups:") : _INTL("Egg Group:")
    headerString = headerify(headerString)
    eggGroupString = getEggGroupName(@mondata.EggGroups[0] || :Ditto)
    eggGroupString += ", " + getEggGroupName(@mondata.EggGroups[1]) if @mondata.EggGroups[1]
    ret[4][0] = headerString + " " + eggGroupString

    ### Steps to Hatch
    headerString = headerify(_INTL("Steps to Hatch:"))
    steps = nil
    if pbCanBeEgg?(@species, @formnum) || ($game_switches[:Randomized_Challenge] && ($Randomizer.randomStatics || $Randomizer.seededStatics || $Randomizer.randomEvolutions))
      steps = @mondata.EggSteps
    elsif EGGSTEPSFIRSTSTAGE
      baby = pbGetBabySpecies(@species, @formnum)
      if pbCanBeEgg?(baby[0], baby[1])
        headerString += " (" + highlight(getMonName(baby[0])) + ")"
        steps = $cache.pkmn[baby[0], baby[1]].EggSteps
      end
    end
    stepString = steps ? pbCommaNumber(steps) : _INTL("Cannot be hatched.")
    fullString = headerString + " " + stepString
    if steps
      cyclesString = " (" + _INTL("{1} cycles", steps / 255) + ")"
      fullString += cyclesString unless getLineCount(fullString + cyclesString) > 1
    end
    ret[4][1] = fullString

    ### Base Friendship
    ret[4][2] = headerify(_INTL("Base Friendship:")) + " " + @mondata.Happiness.to_s

    ### Growth Rate
    growthRate = @mondata.GrowthRate
    maxexp = pbCommaNumber(PBExp.pbGetExpInternal(100, growthRate))
    ret[4][3] = headerify(_INTL("Growth Rate:")) + " " + getGrowthRateName(growthRate) + " " + _INTL("({1} at Lv 100)", maxexp)

    ### Pre-Evolution
    headerString = headerify(_INTL("Pre-Evolution:"))
    preevo = pbGetPreviousForm(@species, @formnum)
    preevoexists = true
    if preevo == [@species, @formnum]
      preevoexists = false # No preevo defined in montext
    else
      # Check if the defined preevo actually has an evolution defined that matches this pokemon
      # isMeaningfulForm is used to allow matching cosmetic and battle-only forms as well
      # evo[:form] being a symbol means it's always fine to match
      preevo_evodata = pbGetEvolvedFormData(*preevo)
      actuallypreevo = preevo_evodata&.any? { |evo|
        evospecies, evoform = evo[:species], (evo[:form].is_a?(Numeric) ? evo[:form] : preevo[1])
        next evospecies == @species && (evoform == @formnum || !isMeaningfulForm(@species, @formnum, evoform) || evo[:form].is_a?(Symbol))
      }
      if !actuallypreevo
        # This catches Bloodmoon Ursaluna (produces Teddiursa on breeding so needs Ursaring defined as the preevo, but Ursaring should not be -shown- as the preevo as there is no method to evolve it into Bloodmoon)
        preevoexists = false
      end
    end
    if preevoexists
      preevostr = getMonName(*preevo)
      preevostr += " (" + getOnlyMonFormName(*preevo) + ")" if preevo[1] != 0
      preevostr = highlight(preevostr)
    else
      preevostr = _INTL("Does not have one.")
    end
    ret[4][4] = headerString + " " + preevostr

    ### Evolutions
    # Get the evolution explanation strings
    evodata = pbGetEvolvedFormData(@species, @formnum).clone || []
    evodata.sort_by! { |evo|
      [evo[:species], evo[:form].is_a?(Numeric) ? evo[:form] : 0]
    }
    evostrings = evodata.map { |evo| getEvolutionMessage(evo, evodata.length) }
    # Build full string
    headerString = evostrings.length > 1 ? _INTL("Evolutions:") : _INTL("Evolution:")
    headerString = headerify(headerString)
    if evostrings.empty?
      finalStrings = [headerString + " " + _INTL("Does not evolve further.")]
    elsif evostrings.length == 1
      finalStrings = [headerString + " " + evostrings[0]]
    else
      finalStrings = [headerString] + evostrings
    end
    fullString = finalStrings.join("\n")
    # Put the data on the pages
    linecount = getLineCount(fullString)
    if linecount == 1
      # Keep data on same page if possible
      ret[4][5] = fullString
    else
      # Add new pages otherwise
      ret[4][5] = _INTL("Go to next page for evolution data.")
      column = 6
      line = 0
      while !finalStrings.empty?
        if ret[column].nil?
          2.times { ret.push(Array.new(6, "")) }
          @infoPages += 1
        end
        linecount = getLineCount(finalStrings.first)
        if (line - 1) + linecount > 5 && line != 0
          ret[column][5] = ". . ."
          column += 2
          line = 0
        else
          ret[column][line] = finalStrings.shift
          line += linecount
          if line > 5
            column += 2
            line = 0
          end
        end
      end
    end

    return ret
  end

  def getLineCount(string)
    chars = getFormattedText(@sprites["overlay"].bitmap, BASE_X, 0, Graphics.width - (BASE_X * 1.5).round, -1, string)
    return chars.map{ |chararray| chararray[0] }.count("\n") + 1
  end

  # Takes an evolution data hash and returns a string that explains the evolution
  def getEvolutionMessage(evolution, totalEvos)
    evoSpecies = evolution[:species]
    evoForm = evolution[:form] || @formnum
    evoForm = 0 if !evoForm.is_a?(Numeric)
    evoMethod = evolution[:method]
    evoParameter = evolution[:parameter]
    evoLocation = evolution[:location]

    explanation = getEvoMethodExplanation(evoMethod, evoParameter)
    explanation = _INTL("on leveling up") + (explanation == "" ? "" : " ") + explanation unless NonLevelUpEvoMethods.include?(evoMethod)
    explanation += ", " + _INTL("if you try to cancel the evolution") if @species == :INKAY
    if evoLocation && EvoLocations[evoLocation]&.any?
      locations = locationNames(evoLocation) || mapIDsToMapNames(EvoLocations[evoLocation])
      explanation += ", " + _INTL("in {1}", joinStrings(locations, "or"))
    end

    ret = getMonName(evoSpecies, evoForm)
    ret += " (" + getOnlyMonFormName(evoSpecies, evoForm) + ")" if evoForm != 0 && totalEvos > 1
    ret = highlight(ret)
    ret += ", " + explanation + "."

    # Alternate evolution forms determined by getEvolutionForm (review this if that's updated)
    if evolution[:form] == :nature
      altFormName = getOnlyMonFormName(evoSpecies, 1)
      natures = [:LONELY, :BOLD, :RELAXED, :TIMID, :SERIOUS, :MODEST, :MILD, :QUIET, :BASHFUL, :CALM, :GENTLE, :CAREFUL].map { |n| getNatureName(n) }
      ret += " " + _INTL("For {1}, must have one of the following natures: {2}", highlight(altFormName), joinStrings(natures, _INTL("or")))
    end

    return ret
  end

  def getEvoMethodExplanation(method, param)
    return case method
      when :Happiness
        _INTL("while happy")
      when :HappinessDay
        _INTL("while happy during daytime")
      when :HappinessNight
        _INTL("while happy during nighttime")
      when :Level, :Ninjask
        param > 0 ? _INTL("to Lv {1}+", param) : "" # Location based evos use :Level + 0
      when :Trade
        _INTL("on trading")
      when :TradeItem
        _INTL("on trading while holding {1}", getItemName(param))
      when :Item
        _INTL("on using {1}", getItemName(param))
      when :AttackGreater
        _INTL("to Lv {1}+ if ATK > DEF", param)
      when :AtkDefEqual
        _INTL("to Lv {1}+ if ATK = DEF", param)
      when :DefenseGreater
        _INTL("to Lv {1}+ if ATK < DEF", param)
      when :Silcoon, :Cascoon
        _INTL("to Lv {1}+, depending on personality", param)
      when :Shedinja
        _INTL("along with Ninjask if there is an empty slot in the party and a Poké Ball in the Bag", param)
      when :ItemMale
        _INTL("on using {1}, if male", getItemName(param))
      when :ItemFemale
        _INTL("on using {1}, if female", getItemName(param))
      when :DayHoldItem
        _INTL("while holding {1} during daytime", getItemName(param))
      when :NightHoldItem
        _INTL("while holding {1} during nighttime", getItemName(param))
      when :HasMove
        _INTL("while knowing the move {1}", getMoveName(param))
      when :HasInParty
        _INTL("while having {1} in the party", getMonName(param))
      when :LevelMale
        _INTL("to Lv {1}+, if male", param)
      when :LevelFemale
        _INTL("to Lv {1}+, if female", param)
      when :TradeSpecies
        _INTL("on trading with {1}", getMonName(param))
      when :BadInfluence
        _INTL("to Lv {1}+ if there is a Dark-Type in the party", param)
      when :Affection
        typename = getTypeName(param)
        if typename.start_with?(/[aeiou]/i)
          _INTL("while happy and knowing an {1}-Type move", typename)
        else
          _INTL("while happy and knowing a {1}-Type move", typename)
        end
      when :LevelRain
        _INTL("to Lv {1}+ while it's raining", param)
      when :LevelDay
        _INTL("to Lv {1}+ during daytime", param)
      when :LevelNight
        _INTL("to Lv {1}+ during nighttime", param)
      when :LevelDusk
        _INTL("to Lv {1}+ during dusk hours", param)
      when :LandCritical
        _INTL("on landing {1} critical hits in one battle", param)
      when :Runerigus
        _INTL("while having 49 or more HP missing")
      when :LevelBattle
        _INTL("to Lv {1}+ during battle", param)
      when :LevelPartner
        _INTL("to Lv {1}+ during a double battle or while having a partner Trainer", param)
      when :TakeRecoil
        _INTL("after having taken recoil worth {1} HP", param)
      when :WalkSteps
        _INTL("after having travelled {1} steps as party lead with the Trainer", param)
      when :UseMove
        _INTL("after having used the move {1} {2} times", getMoveName(param[1]), param[0])
      when :DefeatEnemies
        if param[2]
          _INTL("after having defeated {1} {2} holding {3}", param[0], getMonName(param[1]), getItemName(param[2]))
        else
          _INTL("after having defeated {1} {2}", param[0], getMonName(param[1]))
        end
      when :CollectItem
        _INTL("while having {1} {2} in the bag", param[0], getItemName(param[1], plural: param[0] > 1))
      else
        "method unknown"
    end
  end

  def getLevelMoves
    ret = []
    relearnmoves = @dummymon.getRelearnList
    for move in relearnmoves
      ret.push(highlight(_INTL("Re").rjust(3, "\u2007")) + " " + getMoveString(move))
    end
    levelupmoves = @dummymon.getMoveList
    for i in levelupmoves
      level, move = i[0], i[1]
      levelstr = level != 0 ? sprintf("%d", level) : _INTL("Ev")
      ret.push(highlight(levelstr.rjust(3, "\u2007")) + " " + getMoveString(move))
    end
    return ret
  end

  def getEggMoves
    movelist = @dummymon.getEggMoveList

    return movelist.sort_by{ |move| getMoveShortName(move) }.map{ |move| getMoveString(move) }
  end

  def getMachineTutorMoves
    tmlist = getAllTMMoves
    tutorlist = getAllTutorMoves

    movelist = @dummymon.getFullMoveset(false, false) # Moves in relearn/level-up/egg move pools are also eligible to be learnt by TM/tutor

    tmlist.delete_if { |move| !movelist.include?(move) }
    tms = tmlist.sort_by{ |move| getMoveShortName(move) }.map{ |move| getMoveString(move) }

    tutorlist.delete_if { |move| !movelist.include?(move) }
    tutors = tutorlist.sort_by{ |move| getMoveShortName(move) }.map{ |move| getMoveString(move) }

    return [tms, tutors]
  end

  def getMoveString(move)
    # colortag = case category
    #   when :physical then shadowc3tag(*PhysicalMoveColors)
    #   when :special then shadowc3tag(*SpecialMoveColors)
    #   else ""
    # end
    # Somehow I dislike the colors in practice.
    # My brain keeps thinking there is something wrong with a red move even though I know it's just physical.
    colortag = ""
    icontag = "<icon=minitype#{$cache.moves[move].type}>"
    return icontag + " " + colortag + getMoveShortName(move)
  end

  def setPageFromPageCategory
    @page = case @pagecategory
      when nil then 1
      when 1, 2, 3 then @pagecategory
      when :levelupmoves then @infoPages + 1
      when :eggmoves then @infoPages + @levelMovesPages + 1
      when :machinemoves then @infoPages + @levelMovesPages + @eggMovesPages + 1
      when :tutormoves then @infoPages + @levelMovesPages + @eggMovesPages + @machineMovesPages + 1
      else [4, @infoPages].min # Any of the extra Evolutions pages after page 3
    end
    @page = 1 if @page > @totalPages
  end

  def displayPage(interrupt = true)
    return unless canShowInfo?

    if @page <= @infoPages
      pageInfo(@page, interrupt)
      @pagecategory = @page
    elsif @page <= @infoPages + @levelMovesPages
      pageMoves(@levelMovesArray, _INTL("Level Up Moves:"), @page - @infoPages, @levelMovesPages, interrupt)
      @pagecategory = :levelupmoves
    elsif @page <= @infoPages + @levelMovesPages + @eggMovesPages
      pageMoves(@eggMovesArray, _INTL("Egg Moves:"), @page - @infoPages - @levelMovesPages, @eggMovesPages, interrupt)
      @pagecategory = :eggmoves
    elsif SHOWMACHINETUTORMOVES
      if @page <= @infoPages + @levelMovesPages + @eggMovesPages + @machineMovesPages
        pageMoves(@machineMovesArray, _INTL("Machine Moves:"), @page - @infoPages - @levelMovesPages - @eggMovesPages, @machineMovesPages, interrupt)
        @pagecategory = :machinemoves
      elsif @page <= @infoPages + @levelMovesPages + @eggMovesPages + @machineMovesPages + @tutorMovesPages
        pageMoves(@tutorMovesArray, _INTL("Tutor Moves:"), @page - @infoPages - @levelMovesPages - @eggMovesPages - @machineMovesPages, @tutorMovesPages, interrupt)
        @pagecategory = :tutormoves
      end
    end
  end

  def pageInfo(page, interrupt = true)
    textpos = []
    for i in (12 * (page - 1))...(12 * page)
      line = i % 6
      column = i / 6
      info = @infoArray[column][line]
      next if !info

      x = BASE_X + EXTRA_X * (column % 2)
      y = BASE_Y + EXTRA_Y * line

      if !info.is_a?(Hash)
        textpos.push([info, x, y])
      else
        info.each { |xpos, text| textpos.push([text, x + xpos, y, xpos != 0]) }
      end
    end
    drawPage(textpos, [], interrupt)
  end

  def pageMoves(movesArray, label, page, totalpages, interrupt = true)
    textpos = []
    textpos.push([headerify(label), BASE_X, BASE_Y])
    textpos.push([headerify("#{page}/#{totalpages}"), Graphics.width - 68, BASE_Y, true])

    narrowtextpos = []
    for i in (10 * (page - 1))...(10 * page)
      break if i >= movesArray.size

      line = i % 5
      column = i / 5
      x = BASE_X + EXTRA_X * (column % 2)
      y = BASE_Y + EXTRA_Y * (line + 1) + 4
      narrowtextpos.push([movesArray[i], x, y])
    end
    drawPage(textpos, narrowtextpos, interrupt)
  end

  def drawPage(textpos, narrowtextpos, interrupt = true)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    drawBottom

    @ttsIndex, @ttsLines = 0, []

    pbSetSystemFont(overlay)
    for text in textpos
      drawFormattedTextEx(overlay, text[1], text[2], Graphics.width - (BASE_X * 1.5).round, text[0], *DataTextColors)
      ttstext = toUnformattedText(text[0])
      text[3] ? @ttsLines[-1] += " " + ttstext : @ttsLines.push(ttstext) unless ttstext.empty?
      # 4th element of each textpos array is used to determine whether the string should be concatenated with the previous string for TTS
    end

    pbSetNarrowFont(overlay)
    for text in narrowtextpos
      drawFormattedTextEx(overlay, text[1], text[2], Graphics.width - (BASE_X * 1.5).round, text[0], *DataTextColors)
      ttstext = toUnformattedText(text[0])
      icon = text[0].scan(/<icon=minitype([^>]+)>/)
      ttstext += " (" + getTypeName(icon[0][0].intern) + ")" unless icon.empty?
      @ttsLines.push(ttstext) unless ttstext.empty?
    end

    drawStats if @page == 1
    ttsCurrentLine(interrupt)
  end

  # Colors from PZ3_Summary (colors_gauge_tst slightly darkened), implementation based on PulseDex
  def drawStats
    gauge_colors = [
      Color.new(161, 129, 65), # VERY LOW
      Color.new(129, 161, 65), # LOW
      Color.new(65, 161, 65), # HIGH
      Color.new(65, 161, 129) # VERY HIGH
    ]
    maxbasestats_softcap = 200
    bitmap = @sprites["overlay"].bitmap
    stats = @mondata.BaseStats
    for i in 0..5
      index = case true
        when stats[i] >= (maxbasestats_softcap * 0.75).floor then 3
        when stats[i] >= (maxbasestats_softcap * 0.5).floor then 2
        when stats[i] >= (maxbasestats_softcap * 0.25).floor then 1
        else 0
      end
      color = gauge_colors[index]
      graycolor = Color.new(170, 170, 170)
      width = (stats[i] * 90 / maxbasestats_softcap).to_grid
      statbitmap = BitmapWrapper.new(90, 8)
      statbitmap.fill_rect(Rect.new(0, 2, width, 8), color)
      statbitmap.fill_rect(Rect.new(width, 2, maxbasestats_softcap, 8), graycolor)
      x = 130 + (EXTRA_X * (i / 3))
      y = 170 + (EXTRA_Y * (i % 3))
      bitmap.blt(x, y, statbitmap, statbitmap.rect)
    end
  end

  def headerify(string)
    return HeaderColorTag + string + "</c>"
  end

  def highlight(string)
    return HighlightColorTag + string + "</c>"
  end

  def drawBottom
    @sprites["info"].bitmap.clear
    pbSetSystemFont(@sprites["info"].bitmap)
    height = Graphics.height - 54
    text = [[getMonName(@species), Graphics.width / 2, height - 32, 2, *GUITextColors]]

    type1x = @type2 ? Graphics.width / 2 - 100 : Graphics.width / 2 - 48
    type1bitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/pokedex#{@type1}")
    @sprites["info"].bitmap.blt(type1x, height, type1bitmap.bitmap, Rect.new(0, 0, 96, 32))
    type1bitmap.dispose
    if @type2
      type2bitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/pokedex#{@type2}")
      @sprites["info"].bitmap.blt(Graphics.width / 2 + 4, height, type2bitmap.bitmap, Rect.new(0, 0, 96, 32))
      type2bitmap.dispose
    end

    if canShowInfo?
      text.push([_INTL("Page"), Graphics.width - 52, height - 32, 1, *GUITextColors])
      text.push(["#{@page}/#{@totalPages}", Graphics.width - 52, height, 1, *GUITextColors])
    else
      message = _INTL("No data available.")
      text.push([message, Graphics.width / 2, Graphics.height / 2 - 50, 2, *DataTextColors])
      tts(message)
    end

    pbDrawTextPositions(@sprites["info"].bitmap, text)
  end

  def pbUpdate
    @sprites["icon"].update
  end

  def ttsCurrentLine(interrupt = true)
    tts(@ttsLines[@ttsIndex], interrupt)
  end

  def pbControls(listlimits)
    Graphics.transition
    ret = 0
    loop do
      Graphics.update
      Input.update
      oldpage = @page
      pbUpdate
      if Input.press?(Input::CTRL) && Input.trigger?(Input::DOWN) && @ttsLines&.any? # Next TTS line
        @ttsIndex += 1
        @ttsIndex = 0 if @ttsIndex >= @ttsLines.length
        ttsCurrentLine
      elsif Input.press?(Input::CTRL) && Input.trigger?(Input::UP) && @ttsLines&.any? # Prev TTS line
        @ttsIndex -= 1
        @ttsIndex = @ttsLines.length - 1 if @ttsIndex <= -1
        ttsCurrentLine
      elsif Input.repeat?(Input::DOWN) # Next page
        @page += 1
        @page = 1 if @page > @totalPages
      elsif Input.repeat?(Input::UP) # Prev page
        @page -= 1
        @page = @totalPages if @page < 1
      elsif Input.trigger?(Input::LEFT) # Left page in dex
        ret = 4
        break
      elsif Input.trigger?(Input::RIGHT) # Right page in dex
        ret = 6
        break
      elsif Input.repeat?(Input::L) && listlimits & 1 == 0 # Prev pokemon (if not at top of list)
        ret = 8
        break
      elsif Input.repeat?(Input::R) && listlimits & 2 == 0 # Next pokemon (if not at end of list)
        ret = 2
        break
      elsif Input.trigger?(Input::B)
        ret = 1
        pbPlayCancelSE()
        pbFadeOutAndHide(@sprites)
        break
      elsif Input.trigger?(Input::C) && canShowInfo?
        tts(_INTL("Page {1} out of {2}", @page, @totalPages), true)
      end
      if @page != oldpage
        pbPlayCursorSE()
        displayPage
      end
    end
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class AdvancedPokedex
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(dummymon, pagecategory, listlimits)
    @scene.pbStartScene(dummymon, pagecategory)
    ret = @scene.pbControls(listlimits)
    @scene.pbEndScene
    return ret, @scene.pagecategory
  end
end

def unlockedAdvDex?
  return false if $game_switches[:NotPlayerCharacter]
  return Reborn || $game_switches[:Advanced_Pokedex]
end

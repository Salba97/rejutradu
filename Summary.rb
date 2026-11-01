class MoveSelectionSprite < SpriteWrapper
  attr_reader :preselected
  attr_reader :index

  def initialize(viewport = nil, fifthmove = false)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/Pictures/Summary/summarymovesel")
    @frame = 0
    @index = 0
    @fifthmove = fifthmove
    @preselected = false
    @updating = false
    @spriteVisible = true
    refresh
  end

  def dispose
    @movesel.dispose
    super
  end

  def index=(value)
    @index = value
    refresh
  end

  def preselected=(value)
    @preselected = value
    refresh
  end

  def visible=(value)
    super
    @spriteVisible = value if !@updating
  end

  def refresh
    w = @movesel.width
    h = @movesel.height / 2
    self.x = 240
    self.y = 92 + (self.index * 64)
    self.y -= 76 if @fifthmove
    self.y += 20 if @fifthmove && self.index == 4
    self.bitmap = @movesel.bitmap
    if self.preselected
      self.src_rect.set(0, h, w, h)
    else
      self.src_rect.set(0, 0, w, h)
    end
  end

  def update
    @updating = true
    super
    @movesel.update
    @updating = false
    refresh
  end
end

class PokemonSummaryScene
  LightBase = Color.new(248, 248, 248)
  LightShadow = Color.new(104, 104, 104)
  DarkBase = Color.new(64, 64, 64)
  DarkShadow = Color.new(176, 176, 176)
  ShinyBase = Color.new(248, 56, 32)
  ShinyShadow = Color.new(224, 152, 144)
  MissingAbilDesc = "Ability description missing!"
  MissingAbilName = "Name missing!"
  NoAbilDesc = "No effect."
  NoAbilName = "No ability"
  NotRealAbil = "Ability does not exist!"
  BALL_OFFSET = [14, 60]
  MOVEDESC_OFFSET = [4, 218, 230] # [x, y, width]
  ITEM_OFFSET = [10, 352]
  # Total item name drawing space in the graphic is 196 px, starting x position being 10 px means maximum allowed item name size should be 188 px (with 2 px padding on right side)
  GenderIconPos = [178, 62]
  PokemonSpritePos = [40, 144]

  def pbPokerus(pkmn)
    return pkmn.pokerusStage
  end

  def pbLevelDisplay(pkmn)
    return pkmn.obtainLevel == :Undefinable ? "???" : pkmn.level.to_s
  end

  def pbTimeReceived(pkmn, tts: false)
    plaintextcolor = "<c3=404040,B0B0B0>"
    if pkmn.timeReceived.is_a?(Time)
      month = pbGetAbbrevMonthName(pkmn.timeReceived.mon)
      date = pkmn.timeReceived.day
      year = pkmn.timeReceived.year
      return tts ?
        _INTL("Received on {1} {2}, {3}", month, date, year) :
        plaintextcolor + _INTL("{1} {2}, {3}\n", month, date, year)
    elsif pkmn.timeReceived.is_a?(String)
      return tts ?
        _INTL("Received on {1}", pkmn.timeReceived) :
        pkmn.timeReceived + "\n"
    elsif pkmn.timeReceived == :Glitched
      month = pbGetAbbrevMonthName(rand(12)+ 1)
      date = rand(22) + 10
      year = rand(2101) + 1000
      return tts ?
        _INTL("Time received is unreadable") :
        plaintextcolor + _INTL("{1} {2}, {3}\n", month, date, year)
    end
    return ""
  end

  def pbPublicID(pkmn, tts: false)
    idno = pkmn.ot == "" ? $Trainer.publicID($Trainer.id) : pkmn.publicID
    if Rejuv && pkmn.flickerID && !tts
      idno = pkmn.getflickerID
    end
    idno = sprintf("%05d", idno)
    return idno
  end

  def pbObtainMap(pkmn, tts: false)
    mapname = pbGetMapNameFromId(pkmn.obtainMap)
    if (pkmn.obtainText rescue false) && pkmn.obtainText != ""
      mapname = pkmn.obtainText
    end
    if Rejuv && pkmn.flickerLocation && !tts
      mapname = pkmn.getflickerLocation(mapname)
    end
    return mapname
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(party, partyindex)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @party = party
    @partyindex = partyindex
    @pokemon = @party[@partyindex]
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokemon"].mirror = false
    @sprites["pokemon"].color = Color.new(0, 0, 0, 0)
    pbPositionPokemonSprite(@sprites["pokemon"], *PokemonSpritePos)
    @sprites["pokemon"].y += 100 if @pokemon.species == :EXEGGUTOR && @pokemon.form == 1
    @sprites["pokeicon"] = PokemonBoxIcon.new(@pokemon, @viewport)
    @sprites["pokeicon"].x = 14 - (AURA_SPRITE_OFFSET / 2)
    @sprites["pokeicon"].y = 52 - (AURA_SPRITE_OFFSET / 2)
    @sprites["pokeicon"].mirror = false
    @sprites["pokeicon"].visible = false
    @sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible = false
    @sprites["movepresel"].preselected = true
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible = false
    @page = 0
    @abilpage = false
    @zmovepage = false
    drawPageOne(@pokemon)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartForgetScene(party, partyindex, moveToLearn)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @party = party
    @partyindex = partyindex
    @pokemon = @party[@partyindex]
    @sprites = {}
    @page = 3
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["pokeicon"] = PokemonBoxIcon.new(@pokemon, @viewport)
    @sprites["pokeicon"].x = 14 - (AURA_SPRITE_OFFSET / 2)
    @sprites["pokeicon"].y = 52 - (AURA_SPRITE_OFFSET / 2)
    @sprites["pokeicon"].mirror = false
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport, moveToLearn != 0)
    @sprites["movesel"].visible = false
    @sprites["movesel"].visible = true
    @sprites["movesel"].index = 0
    drawSelectedMove(@pokemon, moveToLearn, @pokemon.moves[0].move)
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def drawMarkings(bitmap, x, y, width, height, markings)
    totaltext = ""
    oldfontname = bitmap.font.name
    oldfontsize = bitmap.font.size
    oldfontcolor = bitmap.font.color
    bitmap.font.size = 24
    bitmap.font.name = "Arial"
    PokemonStorage::MARKINGCHARS.each { |item| totaltext += item }
    totalsize = bitmap.text_size(totaltext)
    realX = x + (width / 2) - (totalsize.width / 2)
    realY = y + (height / 2) - (totalsize.height / 2)
    i = 0
    PokemonStorage::MARKINGCHARS.each { |item|
      marked = (markings & (1 << i)) != 0
      bitmap.font.color = (marked) ? Color.new(72, 64, 56) : Color.new(184, 184, 160)
      itemwidth = bitmap.text_size(item).width
      bitmap.draw_text(realX, realY, itemwidth + 2, totalsize.height, item)
      realX += itemwidth
      i += 1
    }
    bitmap.font.name = oldfontname
    bitmap.font.size = oldfontsize
    bitmap.font.color = oldfontcolor
  end

  def drawMarkingsSprite(overlay, x, y, width, height, markings, count, spacing)
    marks = []
    new_x = 0

    for i in 0..(count - 1)
      if (markings & (1 << i)) != 0
        sheet = sprintf("Graphics/Pictures/Storage/mark%d_on", i + 1)
      else
        sheet = sprintf("Graphics/Pictures/Storage/mark%d_off", i + 1)
      end
      new_x += i == 0 ? x : width + spacing
      marks.push([sheet, new_x, y, 0, 0, width, height])
    end

    pbDrawImagePositions(overlay, marks)
  end

  def pbAddBallGraphic(imagepos)
    ballused = @pokemon.ballused ? @pokemon.ballused : :POKEBALL
    return if ballused == :NOBALL

    ballimage = "Graphics/Pictures/Summary/summaryball" + ballused.to_s
    imagepos.push([ballimage, BALL_OFFSET[0], BALL_OFFSET[1], 0, 0, -1, -1])
  end

  def pbAddStatus(imagepos)
    status = case true
      when @pokemon.hp == 0 then :FAINTED
      when !@pokemon.status.nil? then @pokemon.status
      when pbPokerus(@pokemon) == 1 then :POKERUS
      else nil
    end
    imagepos.push([sprintf("Graphics/Pictures/Party/status%s", status), 120, 100, 0, 0, 44, 16]) if status
    imagepos.push(["Graphics/Pictures/Summary/summaryPokerus", 176, 100, 0, 0, -1, -1]) if pbPokerus(@pokemon) == 2
  end

  def pbAddGenderSign(textpos)
    return if @pokemon.isGenderless?

    colors = @pokemon.isMale? ? [Color.new(24, 112, 216), Color.new(136, 168, 208)] : [ShinyBase, ShinyShadow]
    textpos.push([genderSign(@pokemon.gender), *GenderIconPos, 0, *colors])
  end

  def pbAddItemName(textpos)
    itemname = @pokemon.hasAnItem? ? getItemName(@pokemon.item, short: true) : _INTL("None")
    textpos.push([itemname, ITEM_OFFSET[0], ITEM_OFFSET[1], 0, DarkBase, DarkShadow])
  end

  def ttsAbilDetails(pkmn)
    lines = []
    abil = $cache.abil[pkmn.ability]
    abilname = abil.nil? ? (pkmn.ability.nil? ? NoAbilName : pkmn.ability.to_s) : abil.name.nil? ? MissingAbilName : getAbilityName(pkmn.ability)
    abildesc = abil.nil? ? (pkmn.ability.nil? ? NoAbilDesc : NotRealAbil) : abil.desc.nil? ? MissingAbilDesc : getAbilityDesc(pkmn.ability)
    lines.push(_INTL("Ability: {1}", abilname))
    lines.push(abildesc)
    return lines
  end

  def ttsMarkings(pkmn)
    lines = []
    markings = []
    for i in 0...PokemonStorage::MARKINGCHARS.length
      markname = getMarkingNames[i]
      markings.push(markname) unless pkmn.markings & (1 << i) == 0
    end
    lines.push(_INTL("Markings: {1}", markings.join(", "))) unless pkmn.markings == 0
    return lines
  end

  def setTTSLines(lines)
    @ttsLines = lines
    @ttsIndex = 0
    ttsCurrentLine
  end

  def ttsCurrentLine
    tts(@ttsLines[@ttsIndex], true)
  end

  ###########
  # PAGE 1 #
  ###########

  def drawPageOne(pokemon)
    if pokemon.isEgg?
      drawPageOneEgg(pokemon)
      return
    end

    ttsPageOne(pokemon)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/summary1")
    imagepos = []
    if pokemon.isShiny?
      imagepos.push(["Graphics/Pictures/shiny", 2, 134, 0, 0, -1, -1])
    end
    pbAddStatus(imagepos)
    pbAddBallGraphic(imagepos)
    if (pokemon.isShadow? rescue false)
      imagepos.push(["Graphics/Pictures/Summary/summaryShadow", 224, 240, 0, 0, -1, -1])
      maxgauge = 248
      heartlevel = pokemon.getHeartGaugeBarLevel(maxgauge)
      imagepos.push(["Graphics/Pictures/Summary/summaryShadowBar", 242, 280, 0, 0, heartlevel, -1])
    end
    pbDrawImagePositions(overlay, imagepos)
    pbSetSystemFont(overlay)
    numberbase = (pokemon.isShiny?) ? ShinyBase : DarkBase
    numbershadow = (pokemon.isShiny?) ? ShinyShadow : DarkShadow
    speciesname = getMonName(pokemon.species, pokemon.form)
    pokename = @pokemon.name
    textpos = [
      [_INTL("INFO"), 26, 16, 0, LightBase, LightShadow],
      [pokename, 46, 62, 0, LightBase, LightShadow],
      [pbLevelDisplay(pokemon), 46, 92, 0, DarkBase, DarkShadow],
      [_INTL("Item"), 16, 320, 0, LightBase, LightShadow],
      [_ISPRINTF("Dex No."), 238, 80, 0, LightBase, LightShadow],
      [sprintf("%03d", pokemon.dexnum), 435, 80, 2, numberbase, numbershadow],
      [_INTL("Species"), 238, 112, 0, LightBase, LightShadow],
      [speciesname, 435, 112, 2, DarkBase, DarkShadow],
      [_INTL("Type"), 238, 144, 0, LightBase, LightShadow],
      [_INTL("OT"), 238, 176, 0, LightBase, LightShadow],
      [_INTL("ID No."), 238, 208, 0, LightBase, LightShadow],
    ]
    if (pokemon.isShadow? rescue false)
      textpos.push([_INTL("Heart Gauge"), 238, 240, 0, LightBase, LightShadow])
      heartmessage = getHeartMessage(pokemon.heartStage)
      memo = sprintf("<c3=404040,B0B0B0>%s\n", heartmessage)
      drawFormattedTextEx(overlay, 238, 304, 276, memo)
    else
      textpos.push([_INTL("Exp. Points"), 238, 240, 0, LightBase, LightShadow])
      textpos.push([sprintf("%d", pokemon.exp), 488, 272, :right, DarkBase, DarkShadow])
      textpos.push([_INTL("To Next Lv."), 238, 304, 0, LightBase, LightShadow])
      textpos.push([pokemon.getEXPBarText, 488, 336, :right, DarkBase, DarkShadow])
    end
    idno = pbPublicID(pokemon)
    if !pokemon.personalID(true).is_a?(Numeric)
      idno[rand(idno.length)] = rand(33..126).chr
      idno[rand(idno.length)] = rand(33..126).chr
    end
    textpos.push([idno, 435, 208, 2, DarkBase, DarkShadow])
    if pokemon.ot == ""
      textpos.push([$Trainer.name, 435, 176, 2, DarkBase, DarkShadow])
    elsif Rejuv && pokemon.fakeOT == true
      ownerbase = DarkBase
      ownershadow = DarkShadow
      name = pokemon.ot
      name = sprintf("%05s", name)
      name[rand(name.length)] = rand(33..126).chr
      name[rand(name.length)] = rand(33..126).chr
      textpos.push([name, 435, 176, 2, ownerbase, ownershadow])
    else
      ownerbase = DarkBase
      ownershadow = DarkShadow
      textpos.push([pokemon.ot, 435, 176, 2, ownerbase, ownershadow])
    end
    pbAddGenderSign(textpos)
    pbAddItemName(textpos)
    pbDrawTextPositions(overlay, textpos)
    drawMarkings(overlay, 15, 291, 72, 20, pokemon.markings)
    imagepos = []
    if pokemon.type2.nil?
      imagepos.push([sprintf("Graphics/Icons/type%s", pokemon.type1), 402, 146, 0, 0, 64, 28])
    else
      imagepos.push([sprintf("Graphics/Icons/type%s", pokemon.type1), 370, 146, 0, 0, 64, 28])
      imagepos.push([sprintf("Graphics/Icons/type%s", pokemon.type2), 436, 146, 0, 0, 64, 28])
    end
    pbDrawImagePositions(overlay, imagepos)
    maxgauge = 130
    explevel = pokemon.getEXPBarLevel(maxgauge)
    overlay.fill_rect(362, 372, explevel, 2, Color.new(72, 120, 160))
    overlay.fill_rect(362, 374, explevel, 4, Color.new(24, 144, 248))
  end

  def ttsPageOne(pkmn)
    lines = []
    firsttext = _INTL("{1}'s Summary", pkmn.name)
    firsttext += "\n" + _INTL("Use Ctrl + Up or Down keys to navigate between lines.") unless @tipSpoken
    @tipSpoken = true
    lines.push(firsttext)

    pkmnname = getMonName(pkmn.species, pkmn.form)
    formname = getOnlyMonFormName(pkmn.species, pkmn.form)
    string = _INTL("{1} ({2})", pkmnname, formname)
    string = _INTL("Shiny {1}", string) if pkmn.isShiny?
    string = _INTL("Shadow {1}", string) if (pkmn.isShadow? rescue false)
    string = _INTL("{1} - {2}", pkmn.name, string) if pkmn.name != pkmnname
    lines.push(string)

    lines.push(_INTL("Gender: {1}", genderName(pkmn.gender))) unless pkmn.isGenderless? || formname == genderName(pkmn.gender)

    ballused = pkmn.ballused ? pkmn.ballused : :POKEBALL
    lines.push(_INTL("Caught in {1}", getItemName(ballused))) unless ballused == :NOBALL

    lines.push(_INTL("Level {1}", pkmn.level))

    if pkmn.type2 && pkmn.type2 != pkmn.type1
      types = sprintf("%s / %s", getTypeName(pkmn.type1), getTypeName(pkmn.type2))
    else
      types = getTypeName(pkmn.type1)
    end
    lines.push(_INTL("Types: {1}", types))

    lines.push(_INTL("Pokerus (Infectious)")) if pbPokerus(pkmn) == 1
    lines.push(_INTL("Pokerus")) if pbPokerus(pkmn) == 2

    if pkmn.hp == 0
      lines.push(_INTL("Status: Fainted"))
    elsif pkmn.status
      lines.push(_INTL("Status: {1}", pkmn.status.to_s.downcase))
    end

    lines.push(_INTL("HP: {1} out of {2}", pkmn.hp, pkmn.totalhp))

    lines.push(_INTL("Item: {1}", pkmn.item ? getItemName(pkmn.item) : _INTL("None")))

    lines.push(_INTL("Nature: {1}", getNatureName(pkmn.nature)))
    lines.push(_INTL("Ability: {1}", getAbilityName(pkmn.ability)))

    lines.push(_INTL("Trainer: {1}, ID: {2}", pkmn.ot, pbPublicID(pkmn, tts: true)))

    lines.push(*ttsMarkings(pkmn))

    if (pkmn.isShadow? rescue false)
      lines.push(_INTL("Heart Gauge: {1}", pkmn.getHeartGaugeBarTextTTS))
      heartmessage = getHeartMessage(pkmn.heartStage)
      lines.push(heartmessage)
    else
      lines.push(_INTL("EXP: {1}", pkmn.getEXPBarText(tts: true)))
    end

    lines.push(_INTL("Press C to view Pokedex Entry"))
    setTTSLines(lines)
  end

  def getHeartMessage(stage)
    return [
      _INTL("The door to its heart is open! Undo the final lock!"),
      _INTL("The door to its heart is almost fully open."),
      _INTL("The door to its heart is nearly open."),
      _INTL("The door to its heart is opening wider."),
      _INTL("The door to its heart is opening up."),
      _INTL("The door to its heart is tightly shut."),
    ][stage]
  end

  ############
  # EGG PAGE #
  ############

  def drawPageOneEgg(pokemon)
    ttsPageOneEgg(pokemon)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/summaryEgg")
    imagepos = []
    pbAddStatus(imagepos)
    pbAddBallGraphic(imagepos)
    pbDrawImagePositions(overlay, imagepos)
    pbSetSystemFont(overlay)
    textpos = [
      [_INTL("TRAINER MEMO"), 26, 16, 0, LightBase, LightShadow],
      [pokemon.name, 46, 62, 0, LightBase, LightShadow],
      [_INTL("Item"), 16, 320, 0, LightBase, LightShadow],
    ]
    pbAddItemName(textpos)
    pbDrawTextPositions(overlay, textpos)
    memo = ""
    memo += pbTimeReceived(pokemon)
    mapname = pbObtainMap(pokemon)
    if mapname && mapname != ""
      memo += _INTL("<c3=404040,B0B0B0>A mysterious Pokémon Egg received from <c3=F83820,E09890>{1}<c3=404040,B0B0B0>.\n", mapname)
    end
    memo += "<c3=404040,B0B0B0>\n"
    memo += _INTL("<c3=404040,B0B0B0>\"The Egg Watch\"\n")
    eggstate = getEggState(pokemon.eggsteps)
    memo += sprintf("<c3=404040,B0B0B0>%s\n", eggstate)
    drawFormattedTextEx(overlay, 232, 78, 266, memo)
    drawMarkings(overlay, 15, 291, 72, 20, pokemon.markings)
  end

  def ttsPageOneEgg(pkmn)
    lines = []
    lines.push(_INTL("{1}'s History", pkmn.name))

    pkmnname = getMonName(pkmn.species, pkmn.form)
    string = _INTL("{1} ({2}) Egg", pkmnname, pkmn.getFormName)
    string = _INTL("Shiny {1}", string) if pkmn.isShiny?
    string = _INTL("Shadow {1}", string) if (pkmn.isShadow? rescue false)
    lines.push(string)

    ballused = pkmn.ballused ? pkmn.ballused : :POKEBALL
    lines.push(_INTL("In {1}", getItemName(ballused))) unless ballused == :NOBALL

    timeReceived = pbTimeReceived(pkmn, tts: true)
    lines.push(timeReceived) unless timeReceived == ""

    mapname = pbObtainMap(pkmn, tts: true)
    if mapname && mapname != ""
      lines.push(_INTL("A mysterious Pokémon Egg received from {1}.", mapname))
    end

    eggstate = getEggState(pkmn.eggsteps)
    lines.push(eggstate)

    setTTSLines(lines)
  end

  def getEggState(steps)
    eggstate = _INTL("It looks like this Egg will take a long time to hatch.")
    eggstate = _INTL("What will hatch from this? It doesn't seem close to hatching.") if steps < 10200
    eggstate = _INTL("It appears to move occasionally. It may be close to hatching.") if steps < 2550
    eggstate = _INTL("Sounds can be heard coming from inside! It will hatch soon!") if steps < 1275
    return eggstate
  end

  ################
  # ABILITY PAGE #
  ################

  def drawAbilPage(pokemon)
    ttsAbilPage(pokemon)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/summaryAbility")
    imagepos = []
    if pokemon.isShiny?
      imagepos.push(["Graphics/Pictures/shiny", 2, 134, 0, 0, -1, -1])
    end
    pbAddStatus(imagepos)
    pbAddBallGraphic(imagepos)
    pbDrawImagePositions(overlay, imagepos)
    pbSetSystemFont(overlay)
    pokename = @pokemon.name
    textpos = [
      [_INTL("ABILITY"), 26, 16, 0, LightBase, LightShadow],
      [pokename, 46, 62, 0, LightBase, LightShadow],
      [pbLevelDisplay(pokemon), 46, 92, 0, DarkBase, DarkShadow],
      [_INTL("Item"), 16, 320, 0, LightBase, LightShadow],
    ]
    pbAddGenderSign(textpos)
    pbAddItemName(textpos)
    pbDrawTextPositions(overlay, textpos)
    memo = ""
    abil = $cache.abil[@pokemon.ability]
    abilname = abil.nil? ? (@pokemon.ability.nil? ? NoAbilName : @pokemon.ability.to_s) : abil.name.nil? ? MissingAbilName : getAbilityName(@pokemon.ability)
    abildesc = abil.nil? ? (@pokemon.ability.nil? ? NoAbilDesc : NotRealAbil) : abil.desc.nil? ? MissingAbilDesc : getAbilityDesc(@pokemon.ability, false)
    memo += "<c3=F8F8F8,686868>" + _INTL("Ability:") + "\n"
    memo += "<c3=404040,B0B0B0>" + abilname + "\n"
    memo += "<c3=F8F8F8,686868>" + _INTL("Description:") + "\n"
    memo += "<c3=404040,B0B0B0>" + abildesc
    drawFormattedTextEx(overlay, 232, 78, 272, memo)
    drawMarkings(overlay, 15, 291, 72, 20, pokemon.markings)
  end

  def ttsAbilPage(pkmn)
    lines = []
    lines.push(*ttsAbilDetails(pkmn))
    setTTSLines(lines)
  end

  ###########
  # PAGE 2 #
  ###########

  def drawPageTwo(pokemon)
    ttsPageTwo(pokemon)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/summary2")
    imagepos = []
    if pokemon.isShiny?
      imagepos.push(["Graphics/Pictures/shiny", 2, 134, 0, 0, -1, -1])
    end
    pbAddStatus(imagepos)
    pbAddBallGraphic(imagepos)
    pbDrawImagePositions(overlay, imagepos)
    pbSetSystemFont(overlay)
    pokename = @pokemon.name
    textpos = [
      [_INTL("TRAINER MEMO"), 26, 16, 0, LightBase, LightShadow],
      [pokename, 46, 62, 0, LightBase, LightShadow],
      [pbLevelDisplay(pokemon), 46, 92, 0, DarkBase, DarkShadow],
      [_INTL("Item"), 16, 320, 0, LightBase, LightShadow],
    ]
    pbAddGenderSign(textpos)
    pbAddItemName(textpos)
    pbDrawTextPositions(overlay, textpos)
    memo = ""
    plaintextcolor = "<c3=404040,B0B0B0>"
    highlightcolor = pokemon.obtainMode == 7 ? "<c3=266F9F,71B1DD>" : "<c3=F83820,E09890>"
    if Rejuv && pokemon.naturetext
      memo += highlightcolor + pokemon.naturetext + "\n"
    elsif pokemon.canShowNature?
      memo += _INTL("{1}{2}{3} nature.", highlightcolor, getNatureName(@pokemon.nature), plaintextcolor) + "\n"
    end
    memo += pbTimeReceived(pokemon)
    mapname = pbObtainMap(pokemon)
    if mapname && mapname != ""
      memo += sprintf(highlightcolor + "%s\n", mapname)
    else
      memo += highlightcolor + _INTL("Faraway place") + "\n"
    end
    if pokemon.obtainMode
      mettext = getMetText(pokemon.obtainMode, pokemon.obtainLevel, pokemon.ot)
      memo += sprintf(plaintextcolor + "%s\n", mettext)
      if pokemon.obtainMode == 1 # hatched
        if pokemon.timeEggHatched.is_a?(Time)
          month = pbGetAbbrevMonthName(pokemon.timeEggHatched.mon)
          date = pokemon.timeEggHatched.day
          year = pokemon.timeEggHatched.year
          memo += plaintextcolor + _INTL("{1} {2}, {3}\n", month, date, year)
        elsif pokemon.timeEggHatched.is_a?(String)
          memo += pokemon.timeEggHatched + "\n"
        else pokemon.timeEggHatched == :Glitched
          month = pbGetAbbrevMonthName(rand(12)+ 1)
          date = rand(22) + 10
          year = rand(2101) + 1000
          memo += plaintextcolor + _INTL("{1} {2}, {3}\n", month, date, year)
        end
        mapname = pbGetMapNameFromId(pokemon.hatchedMap)
        if mapname && mapname != ""
          memo += sprintf(highlightcolor + "%s\n", mapname)
        else
          memo += highlightcolor + _INTL("Faraway place") + "\n"
        end
        memo += plaintextcolor + _INTL("Egg hatched.") + "\n"
      elsif pokemon.obtainMode == 6
        memo += highlightcolor + _INTL("{1}", pokemon.hatchedMap) + "\n" if pokemon.hatchedMap != 0
        memo += plaintextcolor + _INTL("{1}", pokemon.obtainExtra) + "\n" if pokemon.obtainExtra
        memo += plaintextcolor + "\n"
      elsif pokemon.obtainMode == 7
        memo += highlightcolor + _INTL("{1}", pokemon.obtainExtra) + "\n" if pokemon.obtainExtra
      else
        memo += highlightcolor + "\n"
      end
    end
    if pokemon.canShowNature? && pokemon.obtainMode != 7
      memo += sprintf(plaintextcolor + "%s\n", getCharacteristic(pokemon))
      # if $cache.natures[pokemon.nature].like != $cache.natures[pokemon.nature].dislike
      #  memo+=sprintf("<c3=404040,B0B0B0>It likes <c3=F83820,E09890>%s<c3=404040,B0B0B0> food.\n",$cache.natures[pokemon.nature].like)
      #  memo+=sprintf("<c3=404040,B0B0B0>It dislikes <c3=F83820,E09890>%s<c3=404040,B0B0B0> food.\n",$cache.natures[pokemon.nature].dislike)
      # else
      #  memo+=sprintf("<c3=404040,B0B0B0>It does not particularly favor any food.\n")
      # end
    end
    drawFormattedTextEx(overlay, 232, 78, 276, memo)
    drawMarkings(overlay, 15, 291, 72, 20, pokemon.markings)
  end

  def ttsPageTwo(pkmn)
    lines = []
    lines.push(_INTL("{1}'s History", pkmn.name))

    unless Reborn
      if pkmn.canShowNature?
        lines.push(_INTL("Nature: {1}", getNatureName(pkmn.nature)))
      end
    end

    timeReceived = pbTimeReceived(pkmn, tts: true)
    lines.push(timeReceived) unless timeReceived == ""

    mapname = pbObtainMap(pkmn, tts: true)
    if !mapname || mapname == ""
      mapname = _INTL("Faraway place")
    end
    lines.push(mapname)

    if pkmn.obtainMode
      mettext = getMetText(pkmn.obtainMode, pkmn.obtainLevel, pkmn.ot)
      lines.push(mettext)
      if pkmn.obtainMode == 1 # hatched
        if pkmn.timeEggHatched.is_a?(Time)
          month = pbGetAbbrevMonthName(pkmn.timeEggHatched.mon)
          date = pkmn.timeEggHatched.day
          year = pkmn.timeEggHatched.year
          lines.push(_INTL("Received on {1} {2}, {3}", month, date, year))
        elsif pkmn.timeEggHatched.is_a?(String)
          lines.push(_INTL("Received on {1}", pkmn.timeEggHatched))
        elsif pkmn.timeEggHatched == :Glitched
          lines.push(_INTL("Time received is unreadable"))
        end
        mapname = pbGetMapNameFromId(pkmn.hatchedMap)
        if mapname && mapname != ""
          lines.push(mapname)
        end
      end
    end

    if pkmn.canShowNature?
      lines.push(getCharacteristic(pkmn))
    end

    setTTSLines(lines)
  end

  def getCharacteristic(pokemon)
    characteristics = [
      _INTL("Loves to eat."),
      _INTL("Often dozes off."),
      _INTL("Often scatters things."),
      _INTL("Scatters things often."),
      _INTL("Likes to relax."),
      _INTL("Proud of its power."),
      _INTL("Likes to thrash about."),
      _INTL("A little quick tempered."),
      _INTL("Likes to fight."),
      _INTL("Quick tempered."),
      _INTL("Sturdy body."),
      _INTL("Capable of taking hits."),
      _INTL("Highly persistent."),
      _INTL("Good endurance."),
      _INTL("Good perseverance."),
      _INTL("Highly curious."),
      _INTL("Mischievous."),
      _INTL("Thoroughly cunning."),
      _INTL("Often lost in thought."),
      _INTL("Very finicky."),
      _INTL("Strong willed."),
      _INTL("Somewhat vain."),
      _INTL("Strongly defiant."),
      _INTL("Hates to lose."),
      _INTL("Somewhat stubborn."),
      _INTL("Likes to run."),
      _INTL("Alert to sounds."),
      _INTL("Impetuous and silly."),
      _INTL("Somewhat of a clown."),
      _INTL("Quick to flee."),
    ]
    bestiv = 0
    tiebreaker = pokemon.personalID % 6
    for i in 0...6
      if pokemon.iv[i] == pokemon.iv[bestiv]
        bestiv = i if i >= tiebreaker && bestiv < tiebreaker
      elsif pokemon.iv[i] > pokemon.iv[bestiv]
        bestiv = i
      end
    end
    return characteristics[bestiv * 5 + pokemon.iv[bestiv] % 5]
  end

  def getMetText(mode, level, owner)
    return [
      _INTL("Met at Lv. {1}.", level),
      _INTL("Egg received."),
      _INTL("Traded at Lv. {1}.", level),
      _INTL("Caught at Lv. {1}.", level),
      _INTL("Had a fateful encounter at Lv. {1}.", level),
      _INTL("Snagged at Lv. {1}.", level),
      _INTL("Tamed at Lv. {1}.", level),
      "<c3=266F9F,71B1DD>" + "\n" + _INTL("Granted to {1}.", owner),
    ][mode]
  end

  ###########
  # PAGE 3 #
  ###########

  def drawPageThree(pokemon)
    ttsPageThree(pokemon)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/summary3")
    imagepos = []
    if pokemon.isShiny?
      imagepos.push(["Graphics/Pictures/shiny", 2, 134, 0, 0, -1, -1])
    end
    pbAddStatus(imagepos)
    pbAddBallGraphic(imagepos)
    pbDrawImagePositions(overlay, imagepos)
    statshadows = []
    for i in 0...6; statshadows[i] = LightShadow; end
    if pokemon.canShowNature?
      natup = $cache.natures[pokemon.nature].incStat
      natdn = $cache.natures[pokemon.nature].decStat
      statshadows[natup] = Color.new(136, 96, 72) if natup != natdn
      statshadows[natdn] = Color.new(64, 120, 152) if natup != natdn
    end
    pbSetSystemFont(overlay)
    abil = $cache.abil[pokemon.ability]
    abilityname = abil.nil? ? (pokemon.ability.nil? ? NoAbilName : pokemon.ability.to_s) : abil.name.nil? ? MissingAbilName : getAbilityName(pokemon.ability, true)
    abilitydesc = abil.nil? ? (pokemon.ability.nil? ? NoAbilDesc : NotRealAbil) : abil.desc.nil? ? MissingAbilDesc : getAbilityDesc(pokemon.ability, true)
    pokename = @pokemon.name
    textpos = [
      [_INTL("SKILLS"), 26, 16, 0, LightBase, LightShadow],
      [pokename, 46, 62, 0, LightBase, LightShadow],
      [pbLevelDisplay(pokemon), 46, 92, 0, DarkBase, DarkShadow],
      [_INTL("Item"), 16, 320, 0, LightBase, LightShadow],
      [_INTL("HP"), 292, 76, 2, LightBase, LightShadow],
      [sprintf("%3d/%3d", pokemon.hp, pokemon.totalhp), 462, 76, 1, DarkBase, DarkShadow],
      [_INTL("Attack"), 248, 120, 0, LightBase, statshadows[PBStats::ATTACK]],
      [sprintf("%d", pokemon.attack), 456, 120, 1, DarkBase, DarkShadow],
      [_INTL("Defense"), 248, 152, 0, LightBase, statshadows[PBStats::DEFENSE]],
      [sprintf("%d", pokemon.defense), 456, 152, 1, DarkBase, DarkShadow],
      [_INTL("Sp. Atk"), 248, 184, 0, LightBase, statshadows[PBStats::SPATK]],
      [sprintf("%d", pokemon.spatk), 456, 184, 1, DarkBase, DarkShadow],
      [_INTL("Sp. Def"), 248, 216, 0, LightBase, statshadows[PBStats::SPDEF]],
      [sprintf("%d", pokemon.spdef), 456, 216, 1, DarkBase, DarkShadow],
      [_INTL("Speed"), 248, 248, 0, LightBase, statshadows[PBStats::SPEED]],
      [sprintf("%d", pokemon.speed), 456, 248, 1, DarkBase, DarkShadow],
      [_INTL("Ability"), 224, 284, 0, LightBase, LightShadow],
      [abilityname, 358, 284, 0, DarkBase, DarkShadow],
    ]
    pbAddGenderSign(textpos)
    pbAddItemName(textpos)
    pbDrawTextPositions(overlay, textpos)
    drawTextEx(overlay, 224, 316, 282, 2, abilitydesc, DarkBase, DarkShadow)
    drawMarkings(overlay, 15, 291, 72, 20, pokemon.markings)
    if pokemon.hp > 0
      hpzone = getHPZone(pokemon.hp, pokemon.totalhp)
      hpcolors = [
        [Color.new(24, 192, 32), Color.new(0, 144, 0)], # Green
        [Color.new(248, 184, 0), Color.new(184, 112, 0)], # Yellow
        [Color.new(240, 80, 32), Color.new(168, 48, 56)], # Red
      ][hpzone]
      hpgauge = (pokemon.totalhp == 0 || pokemon.hp == 0) ? 0 : [pokemon.hp * 96 / pokemon.totalhp, 2].max.to_grid
      overlay.fill_rect(360, 110, hpgauge, 2, hpcolors[1])
      overlay.fill_rect(360, 112, hpgauge, 4, hpcolors[0])
    end
  end

  def ttsPageThree(pkmn)
    lines = []
    lines.push(_INTL("{1}'s Stats", pkmn.name))

    natup = natdn = 0
    if pkmn.canShowNature?
      natup = $cache.natures[pkmn.nature].incStat
      natdn = $cache.natures[pkmn.nature].decStat
    end

    (0..5).each { |stat|
      case stat
        when PBStats::HP      then value = pkmn.totalhp
        when PBStats::ATTACK  then value = pkmn.attack
        when PBStats::DEFENSE then value = pkmn.defense
        when PBStats::SPATK   then value = pkmn.spatk
        when PBStats::SPDEF   then value = pkmn.spdef
        when PBStats::SPEED   then value = pkmn.speed
      end
      naturetext = ""
      naturetext = ", " + _INTL("Boosted by {1} nature", getNatureName(pkmn.nature)) if stat == natup && natup != natdn
      naturetext = ", " + _INTL("Lowered by {1} nature", getNatureName(pkmn.nature)) if stat == natdn && natup != natdn
      lines.push(_INTL("{1}: {2}{3}", getStatName(stat, :full), value, naturetext))
    }

    lines.push(*ttsAbilDetails(pkmn))

    if Reborn
      happiness = pkmn.happiness
      happer = (happiness.to_f / 255 * 100)
      haptext = (happer < 100) ? "#{happer.truncate}%" : "MAX"
      lines.push(_INTL("Friendship: {1}", haptext))
    end

    setTTSLines(lines)
  end

  ###########
  # PAGE 4 #
  ###########

  def drawPageFour(pokemon)
    ttsPageFour(pokemon)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/summary4")
    imagepos = []
    if pokemon.isShiny?
      imagepos.push(["Graphics/Pictures/shiny", 2, 134, 0, 0, -1, -1])
    end
    pbAddStatus(imagepos)
    pbAddBallGraphic(imagepos)
    pbDrawImagePositions(overlay, imagepos)
    statshadows = []
    for i in 0...6; statshadows[i] = LightShadow; end
    if pokemon.canShowNature?
      natup = $cache.natures[pokemon.nature].incStat
      natdn = $cache.natures[pokemon.nature].decStat
      statshadows[natup] = Color.new(136, 96, 72) if natup != natdn
      statshadows[natdn] = Color.new(64, 120, 152) if natup != natdn
    end
    pbSetSystemFont(overlay)
    abil = $cache.abil[pokemon.ability]
    abilityname = abil.nil? ? (pokemon.ability.nil? ? NoAbilName : pokemon.ability.to_s) : abil.name.nil? ? MissingAbilName : getAbilityName(pokemon.ability, true)
    abilitydesc = abil.nil? ? (pokemon.ability.nil? ? NoAbilDesc : NotRealAbil) : abil.desc.nil? ? MissingAbilDesc : getAbilityDesc(pokemon.ability, true)
    pokename = @pokemon.name
    if ["?", "!"].include?(@pokemon.name.split().last)
      pokename = @pokemon.name[0..-2]
    end
    textpos = [
      [_INTL("EV & IV"), 26, 16, 0, LightBase, LightShadow],
      [pokename, 46, 62, 0, LightBase, LightShadow],
      [pbLevelDisplay(pokemon), 46, 92, 0, DarkBase, DarkShadow],
      [_INTL("Item"), 16, 320, 0, LightBase, LightShadow],
      [_INTL("HP"), 292, 76, 2, LightBase, LightShadow],
      [_ISPRINTF("{1:3d}/{2:3d}", pokemon.ev[0], pokemon.iv[0]), 456, 76, 1, DarkBase, DarkShadow],
      [_INTL("Attack"), 248, 120, 0, LightBase, statshadows[PBStats::ATTACK]],
      [_ISPRINTF("{1:3d}/{2:3d}", pokemon.ev[1], pokemon.iv[1]), 456, 120, 1, DarkBase, DarkShadow],
      [_INTL("Defense"), 248, 152, 0, LightBase, statshadows[PBStats::DEFENSE]],
      [_ISPRINTF("{1:3d}/{2:3d}", pokemon.ev[2], pokemon.iv[2]), 456, 152, 1, DarkBase, DarkShadow],
      [_INTL("Sp. Atk"), 248, 184, 0, LightBase, statshadows[PBStats::SPATK]],
      [_ISPRINTF("{1:3d}/{2:3d}", pokemon.ev[3], pokemon.iv[3]), 456, 184, 1, DarkBase, DarkShadow],
      [_INTL("Sp. Def"), 248, 216, 0, LightBase, statshadows[PBStats::SPDEF]],
      [_ISPRINTF("{1:3d}/{2:3d}", pokemon.ev[4], pokemon.iv[4]), 456, 216, 1, DarkBase, DarkShadow],
      [_INTL("Speed"), 248, 248, 0, LightBase, statshadows[PBStats::SPEED]],
      [_ISPRINTF("{1:3d}/{2:3d}", pokemon.ev[5], pokemon.iv[5]), 456, 248, 1, DarkBase, DarkShadow],
      [_INTL("Ability"), 224, 284, 0, LightBase, LightShadow],
      [abilityname, 358, 284, 0, DarkBase, DarkShadow],
    ]
    pbAddGenderSign(textpos)
    pbAddItemName(textpos)
    pbDrawTextPositions(overlay, textpos)
    drawTextEx(overlay, 224, 316, 282, 2, abilitydesc, DarkBase, DarkShadow)
    drawMarkings(overlay, 15, 291, 72, 20, pokemon.markings)
    if pokemon.hp > 0
      hpzone = getHPZone(pokemon.hp, pokemon.totalhp)
      hpcolors = [
        [Color.new(24, 192, 32), Color.new(0, 144, 0)], # Green
        [Color.new(248, 184, 0), Color.new(184, 112, 0)], # Yellow
        [Color.new(240, 80, 32), Color.new(168, 48, 56)], # Red
      ][hpzone]
      hpgauge = (pokemon.totalhp == 0 || pokemon.hp == 0) ? 0 : [pokemon.hp * 96 / pokemon.totalhp, 2].max.to_grid
      overlay.fill_rect(360, 110, hpgauge, 2, hpcolors[1])
      overlay.fill_rect(360, 112, hpgauge, 4, hpcolors[0])
    end
  end

  def ttsPageFour(pkmn)
    lines = []
    lines.push(_INTL("{1}'s Training", pkmn.name))

    natup = natdn = 0
    if pkmn.canShowNature?
      natup = $cache.natures[pkmn.nature].incStat
      natdn = $cache.natures[pkmn.nature].decStat
    end

    (0..5).each { |stat|
      iv = pkmn.iv[stat]
      ev = pkmn.ev[stat]
      naturetext = ""
      naturetext = ", " + _INTL("Boosted by {1} nature", getNatureName(pkmn.nature)) if stat == natup && natup != natdn
      naturetext = ", " + _INTL("Lowered by {1} nature", getNatureName(pkmn.nature)) if stat == natdn && natup != natdn
      lines.push(_INTL("{1}: IV {2}, EV {3}{4}", getStatName(stat, :full), iv, ev, naturetext))
    }

    if Reborn
      currentev = pkmn.ev.sum
      maxev = getPlayerMaxEVs()
      lines.push(_INTL("Trained EVs: {1}", currentev))
      lines.push(_INTL("Remaining EVs: {1}", maxev - currentev))
    else
      lines.push(*ttsAbilDetails(pkmn))
    end

    setTTSLines(lines)
  end

  ###########
  # PAGE 5 #
  ###########

  def drawPageFive(pokemon)
    ttsPageFive(pokemon)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/summary5")
    @sprites["pokemon"].visible = true
    @sprites["pokeicon"].visible = false
    imagepos = []
    if pokemon.isShiny?
      imagepos.push(["Graphics/Pictures/shiny", 2, 134, 0, 0, -1, -1])
    end
    pbAddStatus(imagepos)
    pbAddBallGraphic(imagepos)
    pbDrawImagePositions(overlay, imagepos)
    pbSetSystemFont(overlay)
    pokename = @pokemon.name
    textpos = [
      [_INTL("MOVES"), 26, 16, 0, LightBase, LightShadow],
      [pokename, 46, 62, 0, LightBase, LightShadow],
      [pbLevelDisplay(pokemon), 46, 92, 0, DarkBase, DarkShadow],
      [_INTL("Item"), 16, 320, 0, LightBase, LightShadow],
    ]
    pbAddGenderSign(textpos)
    imagepos = []
    yPos = 98
    for i in 0...pokemon.moves.length
      if pokemon.moves[i].move != nil
        imagepos.push([sprintf("Graphics/Icons/type%s", pbMoveSummaryType(pokemon.moves[i], pokemon)), 248, yPos + 2, 0, 0, 64, 28])
        textpos.push([getMoveShortName(pokemon.moves[i].move), 316, yPos, 0, DarkBase, DarkShadow])
        if pokemon.moves[i].totalpp > 0
          textpos.push([_ISPRINTF("PP"), 342, yPos + 32, 0, DarkBase, DarkShadow])
          textpos.push([sprintf("%d/%d", pokemon.moves[i].pp, pokemon.moves[i].totalpp), 460, yPos + 32, 1, DarkBase, DarkShadow])
        end
      else
        textpos.push(["-", 316, yPos, 0, DarkBase, DarkShadow])
        textpos.push(["--", 442, yPos + 32, 1, DarkBase, DarkShadow])
      end
      yPos += 64
    end
    imagepos.push(["Graphics/Pictures/Summary/summary5zmovebtn", 324, 60, 0, 0, -1, -1]) if pbCanShowZMoves?(pokemon)
    pbAddItemName(textpos)
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
    drawMarkings(overlay, 15, 291, 72, 20, pokemon.markings)
  end

  ###########
  # PAGE 5Z #
  ###########

  def drawZMovePage(pokemon)
    ttsPageFive(pokemon, true)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/summary5")
    @sprites["pokemon"].visible = true
    @sprites["pokeicon"].visible = false
    imagepos = []
    if pokemon.isShiny?
      imagepos.push(["Graphics/Pictures/shiny", 2, 134, 0, 0, -1, -1])
    end
    pbAddStatus(imagepos)
    pbAddBallGraphic(imagepos)
    pbDrawImagePositions(overlay, imagepos)
    pbSetSystemFont(overlay)
    pokename = @pokemon.name
    textpos = [
      [_INTL("MOVES"), 26, 16, 0, LightBase, LightShadow],
      [pokename, 46, 62, 0, LightBase, LightShadow],
      [pbLevelDisplay(pokemon), 46, 92, 0, DarkBase, DarkShadow],
      [_INTL("Item"), 16, 320, 0, LightBase, LightShadow],
    ]
    pbAddGenderSign(textpos)
    imagepos = []
    yPos = 98
    for i in 0...pokemon.moves.length
      if pokemon.zmoves[i] != nil && pokemon.zmoves[i].move != nil
        imagepos.push([sprintf("Graphics/Icons/type%s", pbMoveSummaryType(pokemon.zmoves[i], pokemon)), 248, yPos + 2, 0, 0, 64, 28])
        name = getZMoveName(pokemon.zmoves[i].move)
        drawTextEx(overlay, 316, yPos, 166, 2, name, DarkBase, DarkShadow)
      elsif pokemon.moves[i].move != nil
        imagepos.push([sprintf("Graphics/Icons/type%s", pbMoveSummaryType(pokemon.moves[i], pokemon)), 248, yPos + 2, 0, 0, 64, 28])
        textpos.push([getMoveShortName(pokemon.moves[i].move), 316, yPos, 0, DarkBase, DarkShadow])
        if pokemon.moves[i].totalpp > 0
          textpos.push([_ISPRINTF("PP"), 342, yPos + 32, 0, DarkBase, DarkShadow])
          textpos.push([sprintf("%d/%d", pokemon.moves[i].pp, pokemon.moves[i].totalpp), 460, yPos + 32, 1, DarkBase, DarkShadow])
        end
      else
        textpos.push(["-", 316, yPos, 0, DarkBase, DarkShadow])
        textpos.push(["--", 442, yPos + 32, 1, DarkBase, DarkShadow])
      end
      yPos += 64
    end
    imagepos.push(["Graphics/Pictures/Summary/summary5movebtn", 324, 60, 0, 0, -1, -1])
    pbAddItemName(textpos)
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
    drawMarkings(overlay, 15, 291, 72, 20, pokemon.markings)
  end

  def ttsPageFive(pkmn, z = false)
    lines = []
    lines.push(z ? _INTL("{1}'s Z-Moves", pkmn.name) : _INTL("{1}'s Moves", pkmn.name))

    pkmn.moves.each_with_index { |move, i|
      if move
        if move.totalpp != 0
          lines.push(_INTL("Move {1} - {2}, {3} type, {4} / {5} PP", i + 1, getMoveName(move.move), getTypeName(pbMoveSummaryType(move, pkmn)), move.pp, move.totalpp))
        else
          lines.push(_INTL("Move {1} - {2}, {3} type", i + 1, getMoveName(move.move), getTypeName(pbMoveSummaryType(move, pkmn))))
        end

        if pkmn.zmoves && pkmn.zmoves[i] != nil && pkmn.zmoves[i].move != nil
          name = getZMoveName(pkmn.zmoves[i].move, tts: true)
          if pbMoveSummaryType(pkmn.zmoves[i], pkmn) != pbMoveSummaryType(move, pkmn)
            lines.push(_INTL("Upgrades into {1}, {2} type", name, getTypeName(pbMoveSummaryType(pkmn.zmoves[i], pkmn))))
          else
            lines.push(_INTL("Upgrades into {1}", name))
          end
        end
      end
    }

    lines.push(_INTL("Press C to view details or rearrange"))
    lines.push(_INTL("Press A to toggle Z-Moves")) if pbCanShowZMoves?(pkmn)
    setTTSLines(lines)
  end

  def drawSelectedMove(pokemon, moveToLearn, move)
    overlay = @sprites["overlay"].bitmap
    movedata = $game_switches[:Randomized_Challenge] && $Randomizer.randomMoves ? $rndcache.moves[move] : $cache.moves[move]
    basedamage = pbMoveSummaryPower(movedata, pokemon)
    type = pbMoveSummaryType(movedata, pokemon)
    category = movedata.category
    accuracy = movedata.accuracy

    drawMoveSelection(pokemon, moveToLearn)
    pbSetSystemFont(overlay)
    textpos = [
      [basedamage <= 1 ? basedamage == 1 ? "???" : "---" : sprintf("%d", basedamage), 216, 154, 1, DarkBase, DarkShadow],
      [accuracy == 0 ? "---" : sprintf("%d", accuracy), 216, 186, 1, DarkBase, DarkShadow]
    ]
    pbDrawTextPositions(overlay, textpos)
    cattype = case category
      when :physical then cattype = 0
      when :special then cattype = 1
      else 2
    end
    imagepos = [["Graphics/Pictures/category", 166, 124, 0, cattype * 28, 64, 28]]
    z = @zmovepage ? "" : "z"
    imagepos.push(["Graphics/Pictures/Summary/summary5#{z}movebtn", 324, 60, 0, 0, -1, -1]) if pbCanShowZMoves?(pokemon) && moveToLearn == 0
    pbDrawImagePositions(overlay, imagepos)
    drawTextEx(overlay, *MOVEDESC_OFFSET, 5, getMoveDesc(move), DarkBase, DarkShadow)
  end

  def drawSelectedZeeMove(pokemon, basemove, zmove)
    overlay = @sprites["overlay"].bitmap
    basemovedata = $game_switches[:Randomized_Challenge] && $Randomizer.randomMoves ? $rndcache.moves[basemove] : $cache.moves[basemove]
    zmovedata = $game_switches[:Randomized_Challenge] && $Randomizer.randomMoves ? $rndcache.moves[zmove] : $cache.moves[zmove]
    isTypeSpecificZMove = zmovedata.zmovedata&.type
    basedamage = isTypeSpecificZMove ? ZMoveBaseDamage(PBMove.new(basemove)) : pbMoveSummaryPower(zmovedata, pokemon)
    type = pbMoveSummaryType(zmovedata, pokemon)
    category = isTypeSpecificZMove ? basemovedata.category : zmovedata.category
    accuracy = zmovedata.accuracy

    drawMoveSelection(pokemon, 0)
    pbSetSystemFont(overlay)
    textpos = [
      [basedamage <= 1 ? basedamage == 1 ? "???" : "---" : sprintf("%d", basedamage), 216, 154, 1, DarkBase, DarkShadow],
      [accuracy == 0 ? "---" : sprintf("%d", accuracy), 216, 186, 1, DarkBase, DarkShadow]
    ]
    pbDrawTextPositions(overlay, textpos)
    cattype = case category
      when :physical then cattype = 0
      when :special then cattype = 1
      else 2
    end
    imagepos = [["Graphics/Pictures/category", 166, 124, 0, cattype * 28, 64, 28]]
    imagepos.push(["Graphics/Pictures/Summary/summary5movebtn", 324, 60, 0, 0, -1, -1])
    pbDrawImagePositions(overlay, imagepos)
    desc = (category != :status || PBStuff::UniqueStatusZMoves.include?(zmove)) ? getMoveDesc(zmove) : getStatusZMoveDesc(basemove)
    drawTextEx(overlay, *MOVEDESC_OFFSET, 5, desc, DarkBase, DarkShadow)
  end

  def drawMoveSelection(pokemon, moveToLearn)
    overlay = @sprites["overlay"].bitmap
    overlay.clear

    @sprites["background"].setBitmap("Graphics/Pictures/Summary/summary5details")
    if moveToLearn != 0
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/summary5learning")
    end

    @sprites["pokemon"].visible = false if @sprites["pokemon"]
    @sprites["pokeicon"].bitmap = pbPokemonIconBitmap(pokemon)
    @sprites["pokeicon"].src_rect = Rect.new(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
    @sprites["pokeicon"].visible = true

    pbSetSystemFont(overlay)
    textpos = [
      [_INTL("MOVES"), 26, 16, 0, LightBase, LightShadow],
      [_INTL("CATEGORY"), 20, 122, 0, LightBase, LightShadow],
      [_INTL("POWER"), 20, 154, 0, LightBase, LightShadow],
      [_INTL("ACCURACY"), 20, 186, 0, LightBase, LightShadow]
    ]
    type1rect = Rect.new(0, 0, 64, 28)
    type2rect = Rect.new(0, 0, 64, 28)
    if pokemon.type2.nil? || pokemon.type1 == pokemon.type2
      type1image = AnimatedBitmap.new(sprintf("Graphics/Icons/type%s", pokemon.type1))
      overlay.blt(130, 78, type1image.bitmap, type1rect)
    else
      type1image = AnimatedBitmap.new(sprintf("Graphics/Icons/type%s", pokemon.type1))
      type2image = AnimatedBitmap.new(sprintf("Graphics/Icons/type%s", pokemon.type2))
      overlay.blt(96, 78, type1image.bitmap, type1rect)
      overlay.blt(166, 78, type2image.bitmap, type2rect)
    end
    imagepos = []
    yPos = 98
    yPos -= 76 if moveToLearn != 0
    for i in 0...5
      moveobject = nil
      if i == 4
        moveobject = PBMove.new(moveToLearn) if moveToLearn != 0
        yPos += 20
      else
        moveobject = @zmovepage && !pokemon.zmoves[i].nil? ? pokemon.zmoves[i] : pokemon.moves[i]
      end
      if moveobject
        if @zmovepage && !pokemon.zmoves[i].nil? && moveobject.move != nil
          imagepos.push([sprintf("Graphics/Icons/type%s", pbMoveSummaryType(moveobject, pokemon)), 248, yPos + 2, 0, 0, 64, 28])
          name = getZMoveName(moveobject.move)
          drawTextEx(overlay, 316, yPos, 166, 2, name, DarkBase, DarkShadow)
        elsif moveobject.move != nil
          imagepos.push([sprintf("Graphics/Icons/type%s", pbMoveSummaryType(moveobject, pokemon)), 248, yPos + 2, 0, 0, 64, 28])
          textpos.push([getMoveShortName(moveobject.move), 316, yPos, 0, DarkBase, DarkShadow])
          if moveobject.totalpp > 0
            textpos.push([_ISPRINTF("PP"), 342, yPos + 32, 0, DarkBase, DarkShadow])
            textpos.push([sprintf("%d/%d", moveobject.pp, moveobject.totalpp), 460, yPos + 32, 1, DarkBase, DarkShadow])
          end
        else
          textpos.push(["-", 316, yPos, 0, DarkBase, DarkShadow])
          textpos.push(["--", 442, yPos + 32, 1, DarkBase, DarkShadow])
        end
      end
      yPos += 64
    end
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
  end

  def pbChooseMoveToForget(moveToLearn)
    selmove = 0
    ret = 0
    maxmove = (moveToLearn != 0) ? 4 : 3
    lastread = nil
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if lastread != selmove
        if selmove == 4
          readobj = PBMove.new(moveToLearn) if moveToLearn != 0
        else
          readobj = @pokemon.moves[selmove]
        end
        reading = (selmove == 4) ? moveToLearn : @pokemon.moves[selmove].move
        tts(moveToString(reading, readobj, @pokemon, true))
        lastread = selmove
      end
      if Input.trigger?(Input::B)
        ret = 4
        break
      end
      if Input.trigger?(Input::C)
        break if ret == 4 || moveToLearn == 0 # moveToLearn in this method is only 0 when called via ether effects in battle

        oldname = getMoveName(@pokemon.moves[selmove].move)
        newname = getMoveName(moveToLearn)
        break if Kernel.pbConfirmMessage(_INTL("Is it OK to forget {1}\nand learn {2}?", oldname, newname))
      end

      if Input.trigger?(Input::DOWN)
        selmove += 1
        if selmove < 4 && selmove >= @pokemon.numMoves
          selmove = (moveToLearn > 0) ? maxmove : 0
        end
        selmove = 0 if selmove > maxmove
        @sprites["movesel"].index = selmove
        newmove = (selmove == 4) ? moveToLearn : @pokemon.moves[selmove].move
        drawSelectedMove(@pokemon, moveToLearn, newmove)
        ret = selmove
      end
      if Input.trigger?(Input::UP)
        selmove -= 1
        selmove = maxmove if selmove < 0
        if selmove < 4 && selmove >= @pokemon.numMoves
          selmove = @pokemon.numMoves - 1
        end
        @sprites["movesel"].index = selmove
        newmove = (selmove == 4) ? moveToLearn : @pokemon.moves[selmove].move
        drawSelectedMove(@pokemon, moveToLearn, newmove)
        ret = selmove
      end
    end
    return (ret == 4) ? -1 : ret
  end

  def pbMoveSelection
    @sprites["movesel"].visible = true
    @sprites["movesel"].index = 0
    selmove = 0
    oldselmove = 0
    switching = false
    lastread = nil
    moves = @pokemon.moves # Remember this is a shallow copy
    zmoves = @pokemon.zmoves # Remember this is a shallow copy
    @zmovepage && !zmoves[selmove].nil? ? drawSelectedZeeMove(@pokemon, moves[selmove].move, zmoves[selmove].move) : drawSelectedMove(@pokemon, 0, moves[selmove].move)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if lastread != selmove
        if @zmovepage && !zmoves[selmove].nil?
          readobj = zmoves[selmove]
        else
          readobj = moves[selmove]
        end
        tts(moveToString(readobj.move, readobj, @pokemon, true))
        lastread = selmove
      end
      @sprites["movepresel"].z = @sprites["movesel"].z
      @sprites["movepresel"].z += 1 if @sprites["movepresel"].index == @sprites["movesel"].index
      if Input.trigger?(Input::B)
        break if !switching
        tts(_INTL("Switch canceled."), true)

        @sprites["movepresel"].visible = false
        switching = false
      end
      if Input.trigger?(Input::C) && !(@pokemon.isShadow? rescue false)
        if !switching
          @sprites["movepresel"].index = selmove
          oldselmove = selmove
          @sprites["movepresel"].visible = true
          switching = true
          tts(_INTL("Switch {1} with what move?", getMoveName(moves[selmove].move)), true)
        else
          tmpmove = moves[oldselmove]
          moves[oldselmove] = moves[selmove]
          moves[selmove] = tmpmove
          if !(zmoves.nil? || @pokemon.item == :INTERCEPTZ)
            tmpmove = zmoves[oldselmove]
            zmoves[oldselmove] = zmoves[selmove]
            zmoves[selmove] = tmpmove
          end
          @sprites["movepresel"].visible = false
          switching = false
          tts(_INTL("{1} switched with {2}.", getMoveName(moves[oldselmove].move), getMoveName(moves[selmove].move)), true)
          @zmovepage && !zmoves[selmove].nil? ? drawSelectedZeeMove(@pokemon, moves[selmove].move, zmoves[selmove].move) : drawSelectedMove(@pokemon, 0, moves[selmove].move)
        end
      end
      if Input.trigger?(Input::X) && zmoves != nil && zmoves.any? { |x| x != nil }
        @zmovepage = !@zmovepage
        @zmovepage && !zmoves[selmove].nil? ? drawSelectedZeeMove(@pokemon, moves[selmove].move, zmoves[selmove].move) : drawSelectedMove(@pokemon, 0, moves[selmove].move)
      end
      if Input.trigger?(Input::DOWN)
        selmove += 1
        selmove = 0 if selmove >= @pokemon.numMoves
        @sprites["movesel"].index = selmove
        pbPlayCursorSE()
        @zmovepage && !zmoves[selmove].nil? ? drawSelectedZeeMove(@pokemon, moves[selmove].move, zmoves[selmove].move) : drawSelectedMove(@pokemon, 0, moves[selmove].move)
      end
      if Input.trigger?(Input::UP)
        selmove -= 1
        selmove = @pokemon.numMoves - 1 if selmove < 0
        @sprites["movesel"].index = selmove
        pbPlayCursorSE()
        @zmovepage && !zmoves[selmove].nil? ? drawSelectedZeeMove(@pokemon, moves[selmove].move, zmoves[selmove].move) : drawSelectedMove(@pokemon, 0, moves[selmove].move)
      end
    end
    @sprites["movesel"].visible = false
  end

  def pbCanShowZMoves?(pokemon)
    return pokemon.zmoves != nil && pokemon.zmoves.any? { |x| x != nil }
  end

  def pbQuickPokedexScene
    # Go to dex
    index = @partyindex
    # @party can be an Array (in the party screen) or a PokemonBox (in the PC)
    party = @party.is_a?(PokemonBox) ? @party.pokemon : @party
    pokemonlist = party.map { |i| i.nil? || i.isEgg? ? nil : [i.species, i.gender, i.form] }
    pokedexScene = PokemonPokedexScene.new(true)
    pokedexScene.pbStartDexEntryScene(pokemonlist[index][0], pokemonlist[index][-1], pokemonlist[index][-2])
    @partyindex = pokedexScene.pbDexEntry(index, pokemonlist)
    # TODO: Pass shininess and shadow-ness in pokemonlist as well (simply updating last seen data doesn't work as there may be multiple Pokemon of same species)

    # Return to summary (page needs to be drawn before fade in for a smooth transition)
    pbChangePokemon if @partyindex != index
    drawPageOne(@pokemon) if @partyindex != index
    pbFadeInAndShow(@sprites)
  end

  def pbGoToPrevious
    newindex = @partyindex
    if newindex > 0
      while newindex > 0
        newindex -= 1
        if @party[newindex]
          @partyindex = newindex
          break
        end
        if newindex == 0
          newindex = @party.length
        end
      end
    else
      newindex = @party.length - 1
      while newindex
        if @party[newindex]
          @partyindex = newindex
          break
        end
        newindex -= 1
      end
    end
  end

  def pbGoToNext
    newindex = @partyindex
    if newindex < @party.length - 1
      while newindex < @party.length # -1
        newindex += 1
        if @party[newindex]
          @partyindex = newindex
          break
        end
        if newindex == @party.length
          newindex = -1
        end
      end
    else
      newindex = 0
      while newindex
        if @party[newindex]
          @partyindex = newindex
          break
        end
        newindex += 1
      end
    end
  end

  def pbChangePokemon
    @pokemon = @party[@partyindex]
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokemon"].color = Color.new(0, 0, 0, 0)
    pbPositionPokemonSprite(@sprites["pokemon"], *PokemonSpritePos)
    @sprites["pokemon"].y += 100 if @pokemon.species == :EXEGGUTOR && @pokemon.form == 1
    pbPlayCry(@pokemon) unless @pokemon.isEgg?
  end

  def pbScene
    pbPlayCry(@pokemon) unless @pokemon.isEgg?
    loop do
      Graphics.update
      Input.update
      pbUpdate
      oldindex = @partyindex
      dorefresh = false

      if Input.trigger?(Input::B)
        if @abilpage
          @abilpage = false
          dorefresh = true
        else
          break
        end
      elsif Input.trigger?(Input::C)
        if @page == 0 && !@pokemon.isEgg?
          pbQuickPokedexScene if $Trainer.pokedex.canViewDex
          next
        elsif @page == 2 || (@page == 3 && !Reborn)
          @abilpage = !@abilpage
          dorefresh = true
        elsif @page == 4
          pbMoveSelection
          dorefresh = true
        end
      elsif Input.trigger?(Input::X)
        if @page == 4 && pbCanShowZMoves?(@pokemon)
          @zmovepage = !@zmovepage
          dorefresh = true
        end
      elsif Input.press?(Input::CTRL) && Input.trigger?(Input::DOWN) && @ttsLines&.any? # Next TTS line
        @ttsIndex += 1
        @ttsIndex = 0 if @ttsIndex >= @ttsLines.length
        ttsCurrentLine
      elsif Input.press?(Input::CTRL) && Input.trigger?(Input::UP) && @ttsLines&.any? # Prev TTS line
        @ttsIndex -= 1
        @ttsIndex = @ttsLines.length - 1 if @ttsIndex <= -1
        ttsCurrentLine
      elsif Input.trigger?(Input::DOWN)
        pbGoToNext
      elsif Input.trigger?(Input::UP)
        pbGoToPrevious
      elsif Input.trigger?(Input::LEFT) && !@pokemon.isEgg?
        @page -= 1
        @page = 4 if @page < 0
        pbPlayCursorSE()
        @abilpage = false
        @zmovepage = false
        dorefresh = true
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.isEgg?
        @page += 1
        @page = 0 if @page > 4
        pbPlayCursorSE()
        @abilpage = false
        @zmovepage = false
        dorefresh = true
      end

      if @partyindex != oldindex
        pbChangePokemon
        @page = 0 if @pokemon.isEgg?
        @abilpage = false if @pokemon.isEgg?
        @zmovepage = false
        dorefresh = true
      end
      if Rejuv
        dorefresh = true if @page == 0 && (!@pokemon.personalID(true).is_a?(Numeric) || @pokemon.fakeOT || @pokemon.flickerID)
        dorefresh = true if @page == 1 && (@pokemon.flickerLocation || @pokemon.timeReceived == :Glitched || (@pokemon.obtainMode == 1 && @pokemon.timeEggHatched == :Glitched))
      end
      if dorefresh
        case @page
          when 0 then drawPageOne(@pokemon)
          when 1 then drawPageTwo(@pokemon)
          when 2 then @abilpage ? drawAbilPage(@pokemon) : drawPageThree(@pokemon)
          when 3 then @abilpage ? drawAbilPage(@pokemon) : drawPageFour(@pokemon)
          when 4 then @zmovepage ? drawZMovePage(@pokemon) : drawPageFive(@pokemon)
        end
      end
    end
    return @partyindex
  end
end

class PokemonSummary
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(party, partyindex)
    @scene.pbStartScene(party, partyindex)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbStartForgetScreen(party, partyindex, moveToLearn)
    ret = -1
    @scene.pbStartForgetScene(party, partyindex, moveToLearn)
    loop do
      ret = @scene.pbChooseMoveToForget(moveToLearn)
      if ret >= 0 && moveToLearn != 0 && pbIsHiddenMove?(party[partyindex].moves[ret].move) && !($DEBUG && Input.press?(Input::CTRL))
        Kernel.pbMessage(_INTL("HM moves can't be forgotten now.")) { @scene.pbUpdate }
      else
        break
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbStartChooseMoveScreen(party, partyindex, message)
    ret = -1
    @scene.pbStartForgetScene(party, partyindex, 0)
    Kernel.pbMessage(message) { @scene.pbUpdate }
    loop do
      ret = @scene.pbChooseMoveToForget(0)
      break
    end
    @scene.pbEndScene
    return ret
  end
end

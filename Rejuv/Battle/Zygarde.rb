class PokemonSummaryScene
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
    @sprites["statsel"] = StatSelectionSprite.new(@viewport)
    @sprites["statsel"].visible = false
    @page = 0
    @abilpage = false
    @zmovepage = false
    drawPageOne(@pokemon)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def drawZygardePage(pokemon, allocation = false)
    return if pokemon.customForm.nil?
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/summaryZygarde")
    imagepos = []
    if pbPokerus(pokemon) == 1 || pokemon.hp == 0 || !pokemon.status.nil?
      status = :POKERUS if pbPokerus(pokemon) == 1
      status = pokemon.status if !pokemon.status.nil?
      status = :FAINTED if pokemon.hp == 0
      imagepos.push([sprintf("Graphics/Pictures/Party/status%s", status), 120, 100, 0, 0, 44, 16])
    end
    if pokemon.isShiny?
      imagepos.push(["Graphics/Pictures/shiny", 2, 134, 0, 0, -1, -1])
    end
    if pbPokerus(pokemon) == 2
      imagepos.push(["Graphics/Pictures/Summary/summaryPokerus", 176, 100, 0, 0, -1, -1])
    end
    ballused = pokemon.ballused ? pokemon.ballused : :POKEBALL
    ballimage = "Graphics/Pictures/Summary/summaryball" + ballused.to_s
    imagepos.push([ballimage, 14, 60, 0, 0, -1, -1])
    coreInvestment = pokemon.customForm.checkFlag?(:CoreInvestment)
    coreInvestment.slice!(6..-1) if coreInvestment.length > 6
    baseStats = pokemon.fused.baseStats
    maxstats = baseStats.each_index.select { |i| baseStats[i] == baseStats.max }
    freeCores = $game_variables[:Z_Cores] - coreInvestment.sum + 1
    goldZCore = "Graphics/Pictures/Summary/zygardeslotReserved"
    grayZCore = "Graphics/Pictures/Summary/zygardeslotOptional"
    greenZCore = "Graphics/Pictures/Summary/zygardeslotTaken"
    zcellY = [76, 108, 140, 172, 204, 236] # PS, Ataque, Defensa, Ataque Especial, Defensa Especial, Velocidad
    textpos = []
    goldCoreUsed = false
    for stat in 0..5
      # Los indicadores de inversión de habilidades están espaciados de forma diferente
      cellspacing = 20
      cellbase = 338
      counter = 0
      coreInvestment[stat].times do
        cellimage = maxstats.include?(stat) && counter == 0 && !goldCoreUsed ? goldZCore : greenZCore
        goldCoreUsed = true if cellimage == goldZCore
        imagepos.push([cellimage, cellbase + cellspacing * counter, zcellY[stat], 0, 0, -1, -1])
        counter += 1
      end
      value = ZYGARDE_BASE_STAT + pokemon.coreEffect * counter
      color = [LightBase, LightShadow]
      if stat == 0 && pokemon.ability == :WONDERGUARD
        value = 1
        color = [LightBase, Color.new(64, 120, 152)]
      elsif counter > 0
        color = [Color.new(18, 211, 58), Color.new(9, 103, 28)]
      end
      textpos.push [value.to_s.rjust(3, "\u2007"), 452, zcellY[stat], 0, *color]
    end
    unless goldCoreUsed
      maxstats.each do |stat|
        imagepos.push([grayZCore, cellbase + cellspacing * counter, zcellY[stat], 0, 0, -1, -1])
      end
      freeCores -= 1
    end
    if pokemon.type2.nil?
      imagepos.push([sprintf("Graphics/Icons/type%s", pokemon.type1), 398, 286, 0, 0, 64, 28])
    else
      imagepos.push([sprintf("Graphics/Icons/type%s", pokemon.type1), 364, 286, 0, 0, 64, 28])
      imagepos.push([sprintf("Graphics/Icons/type%s", pokemon.type2), 432, 286, 0, 0, 64, 28])
    end
    pbDrawImagePositions(overlay, imagepos)
    statshadows = []
    for i in 0...6; statshadows[i] = LightShadow; end
    if !(pokemon.isShadow? rescue false) || pokemon.heartStage <= 3
      natup = $cache.natures[pokemon.nature].incStat
      natdn = $cache.natures[pokemon.nature].decStat
      statshadows[natup] = Color.new(136, 96, 72) if natup != natdn
      statshadows[natdn] = Color.new(64, 120, 152) if natup != natdn
    end
    pbSetSystemFont(overlay)
    abil = $cache.abil[pokemon.ability]
    abilityname = abil.nil? ? (pokemon.ability.nil? ? NoAbilName : pokemon.ability.to_s) : abil.name.nil? ? MissingAbilName : getAbilityName(pokemon.ability, true)
    pokename = pokemon.name
    leveldisplay = pokemon.obtainLevel == :Undefinable ? "???" : pokemon.level.to_s
    textpos += [
      [_INTL("NÚCLEOS DE ZYGARDE"), 26, 16, 0, LightBase, LightShadow],
      [pokename, 46, 62, 0, LightBase, LightShadow],
      [leveldisplay, 46, 92, 0, DarkBase, DarkShadow],
      [_INTL("Núcleos:"), 16, 320, 0, LightBase, LightShadow],
      [sprintf("%d", freeCores), 130, 320, 0, LightBase, LightShadow],
      [_INTL("PS"), 240, zcellY[0], 0, LightBase, LightShadow],
      [_INTL("Ataque"), 240, zcellY[1], 0, LightBase, statshadows[PBStats::ATTACK]],
      [_INTL("Defensa"), 240, zcellY[2], 0, LightBase, statshadows[PBStats::DEFENSE]],
      [_INTL("At. Esp."), 240, zcellY[3], 0, LightBase, statshadows[PBStats::SPATK]],
      [_INTL("Def. Esp."), 240, zcellY[4], 0, LightBase, statshadows[PBStats::SPDEF]],
      [_INTL("Velocidad"), 240, zcellY[5], 0, LightBase, statshadows[PBStats::SPEED]],
      [_INTL("Tipo"), 226, 284, 0, LightBase, LightShadow],
      [_INTL("Habilidad"), 226, 316, 0, LightBase, LightShadow],
      [_INTL("Efecto del núcleo"), 226, 348, 0, LightBase, LightShadow],
      [abilityname, 432, 316, :center, LightBase, LightShadow],
      [sprintf("+ %d", pokemon.coreEffect), 432, 348, :center, Color.new(18, 211, 58), Color.new(9, 103, 28)],
    ]
    unless $game_temp.in_battle
      textpos.push([_INTL("Asignar núcleos:  C"), 8, 350, 0, LightBase, LightShadow]) if !allocation
      textpos.push([_INTL("Volver:  X"), 8, 350, 0, LightBase, LightShadow]) if allocation
    end
    if pokemon.isMale?
      textpos.push([_INTL("♂"),  GenderIconPos[0], GenderIconPos[1], 0, Color.new(24, 112, 216), Color.new(136, 168, 208)])
    elsif pokemon.isFemale?
      textpos.push([_INTL("♀"),  GenderIconPos[0], GenderIconPos[1], 0, ShinyBase, ShinyShadow])
    end
    pbDrawTextPositions(overlay, textpos)
    drawMarkings(overlay, 15, 291, 72, 20, pokemon.markings)
  end

  def pbStartZygardeScene(party, partyindex)
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
    @sprites["pokeicon"] = PokemonBoxIcon.new(@pokemon, @viewport)
    @sprites["pokeicon"].x = 14 - (AURA_SPRITE_OFFSET / 2)
    @sprites["pokeicon"].y = 52 - (AURA_SPRITE_OFFSET / 2)
    @sprites["pokeicon"].mirror = false
    @sprites["pokeicon"].visible = false
    @sprites["statsel"] = StatSelectionSprite.new(@viewport)
    @sprites["statsel"].visible = false
    if @pokemon.species == :EXEGGUTOR && @pokemon.form == 1
      @sprites["pokemon"].y += 100
    end
    drawZygardePage(@pokemon)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def coreAllocation(pokemon)
    @sprites["statsel"].visible = true
    @sprites["statsel"].index = 0
    selStat = 0
    baseStats = pokemon.fused.baseStats
    maxstats = baseStats.each_index.select { |i| baseStats[i] == baseStats.max }
    typelist = pokemon.typecrosslist(pokemon.fused.species, pokemon.fused.form, pokemon.fused.gender)
    typeIndex = typelist.index(pokemon.types)
    abilitylist = pokemon.getAbilityList
    abilityIndex = abilitylist.index(pokemon.ability)
    coreInvestment = pokemon.customForm.checkFlag?(:CoreInvestment)
    coreInvestment.slice!(6..-1) if coreInvestment.length > 6
    wonderlock = pokemon.ability == :WONDERGUARD
    @sprites["statsel"].hideRightArrow = true if wonderlock
    minimum = [0, 0, 0, 0, 0, 0]
    minimum[maxstats.first] = 1 if maxstats.length == 1
    freeCores = $game_variables[:Z_Cores] - coreInvestment.sum + 1
    drawZygardePage(pokemon, true)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        unless freeCores < 0
          break
        else
          Kernel.pbMessage(_INTL("No tienes suficientes núcleos de Zygarde."))
        end
      end
      if Input.trigger?(Input::DOWN)
        selStat += 1
        selStat = 0 if selStat > 7
        if selStat < 6
          @sprites["statsel"].hideLeftArrow = coreInvestment[selStat] <= minimum[selStat]
          @sprites["statsel"].hideRightArrow = coreInvestment[selStat] == 5 || freeCores <= 0 || (wonderlock && selStat == 0)
        end
        @sprites["statsel"].index = selStat
        pbPlayCursorSE()
      end
      if Input.trigger?(Input::UP)
        selStat -= 1
        selStat = 7 if selStat < 0
        if selStat < 6
          @sprites["statsel"].hideLeftArrow = coreInvestment[selStat] <= minimum[selStat]
          @sprites["statsel"].hideRightArrow = coreInvestment[selStat] == 5 || freeCores <= 0 || (wonderlock && selStat == 0)
        end
        @sprites["statsel"].index = selStat
        pbPlayCursorSE()
      end
      if Input.trigger?(Input::LEFT)
        if selStat == 6 # Tipo
          typeIndex -= 1
          typeIndex = (typelist.length) - 1 if typeIndex < 0
          pokemon.customForm.instance_variable_set(:@Type1, typelist[typeIndex][0])
          pokemon.customForm.instance_variable_set(:@Type2, typelist[typeIndex][1])
        elsif selStat == 7 # Habilidad
          abilityIndex -= 1
          abilityIndex = abilitylist.length - 1 if abilityIndex < 0
          pokemon.setAbility(abilitylist[abilityIndex])
          if pokemon.ability == :WONDERGUARD
            coreInvestment[0] = 0
            wonderlock = true
          elsif wonderlock && pokemon.ability != :WONDERGUARD
            coreInvestment[0] = minimum[0]
            wonderlock = false
          end
          freeCores = $game_variables[:Z_Cores] - coreInvestment.sum + 1
        else # Estadísticas base
          if coreInvestment[selStat] > minimum[selStat]
            coreInvestment[selStat] -= 1
            freeCores += 1
            @sprites["statsel"].hideLeftArrow = coreInvestment[selStat] == minimum[selStat]
            @sprites["statsel"].hideRightArrow = coreInvestment[selStat] == 5 || freeCores <= 0
          end
        end
        pokemon.recalcStats()
        pbPlayCursorSE()
        drawZygardePage(pokemon, true)
      end
      if Input.trigger?(Input::RIGHT)
        if selStat == 6 # Tipo
          typeIndex += 1
          typeIndex = 0 if typeIndex >= typelist.length
          pokemon.customForm.instance_variable_set(:@Type1, typelist[typeIndex][0])
          pokemon.customForm.instance_variable_set(:@Type2, typelist[typeIndex][1])
        elsif selStat == 7 # Habilidad
          abilityIndex += 1
          abilityIndex = 0 if abilityIndex >= abilitylist.length
          pokemon.setAbility(abilitylist[abilityIndex])
          if pokemon.ability == :WONDERGUARD
            coreInvestment[0] = 0
            wonderlock = true
          elsif wonderlock && pokemon.ability != :WONDERGUARD
            coreInvestment[0] = minimum[0]
            wonderlock = false
          end
          freeCores = $game_variables[:Z_Cores] - coreInvestment.sum + 1
        else # Estadísticas base
          if coreInvestment[selStat] < 5 && freeCores > 0 && !(wonderlock && selStat == 0) &&
             (freeCores > 1 || maxstats.include?(selStat) || maxstats.any? { |stat| coreInvestment[stat] > 0 })
            coreInvestment[selStat] += 1
            freeCores -= 1
            @sprites["statsel"].hideLeftArrow = coreInvestment[selStat] == minimum[selStat]
            @sprites["statsel"].hideRightArrow = coreInvestment[selStat] == 5 || freeCores <= 0
          end
        end
        pokemon.recalcStats()
        pbPlayCursorSE()
        drawZygardePage(pokemon, true)
      end
    end
    pokemon.calcStats
    @sprites["statsel"].visible = false
    drawZygardePage(pokemon)
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
        elsif @page == 5 && !$game_temp.in_battle
          coreAllocation(@pokemon)
        end
      elsif Input.trigger?(Input::X)
        if @page == 4 && pbCanShowZMoves?(@pokemon)
          @zmovepage = !@zmovepage
          dorefresh = true
        end
      elsif Input.press?(Input::CTRL) && Input.trigger?(Input::DOWN) && @ttsLines&.any? # Siguiente línea del TTS
        @ttsIndex += 1
        @ttsIndex = 0 if @ttsIndex >= @ttsLines.length
        ttsCurrentLine
      elsif Input.press?(Input::CTRL) && Input.trigger?(Input::UP) && @ttsLines&.any? # Línea anterior del TTS
        @ttsIndex -= 1
        @ttsIndex = @ttsLines.length - 1 if @ttsIndex <= -1
        ttsCurrentLine
      elsif Input.trigger?(Input::DOWN) && @page != 5
        pbGoToNext
      elsif Input.trigger?(Input::UP) && @page != 5
        pbGoToPrevious
      elsif Input.trigger?(Input::LEFT) && !@pokemon.isEgg?
        @page -= 1
        @page = @pokemon.customForm && @pokemon.species == :ZYGARDE ? 5 : 4 if @page < 0
        pbPlayCursorSE()
        @abilpage = false
        @zmovepage = false
        dorefresh = true
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.isEgg?
        @page += 1
        @page = 0 if @page > (@pokemon.customForm && @pokemon.species == :ZYGARDE ? 5 : 4)
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
          when 5 then drawZygardePage(@pokemon)
        end
      end
    end
    return @partyindex
  end
end

class PokemonSummary
  def pbZygardeScene(party, partyindex)
    ret = -1
    @scene.pbStartZygardeScene(party, partyindex)
    loop do
      Graphics.update
      Input.update
      @scene.pbUpdate
      if Input.trigger?(Input::B)
        if Kernel.pbConfirmMessage(_INTL("¿Terminar la personalización de Zygarde?"))
          break
        end
      end
      if Input.trigger?(Input::C)
        @scene.coreAllocation(party[partyindex])
      end
    end
    @scene.pbEndScene
  end
end

class StatSelectionSprite < SpriteWrapper
  attr_accessor :hideLeftArrow
  attr_accessor :hideRightArrow
  attr_reader :preselected
  attr_reader :index

  def initialize(viewport = nil)
    super(viewport)
    @statsel = AnimatedBitmap.new("Graphics/Pictures/Summary/zygardeSelection")
    @statselArrowleft = AnimatedBitmap.new("Graphics/Pictures/Summary/zygardeSelection_ArrowLeft")
    @statselArrowright = AnimatedBitmap.new("Graphics/Pictures/Summary/zygardeSelection_ArrowRight")
    @contents = BitmapWrapper.new(@statsel.width + @statselArrowleft.width + @statselArrowright.width, @statsel.height / 2)
    @frame = 0
    @index = 0
    @bigframe = false
    @hideLeftArrow = true
    @hideRightArrow = false
    @updating = false
    @spriteVisible = true
    self.bitmap = @contents
    refresh
  end

  def dispose
    @statsel.dispose
    @statselArrowleft.dispose
    @statselArrowright.dispose
    @contents.dispose
    super
  end

  def index=(value)
    @index = value
    @bigframe = value > 5
    refresh
  end

  def visible=(value)
    super
    @spriteVisible = value if !@updating
  end

  def refresh
    self.bitmap.clear
    if @bigframe
      self.x = 308
      self.y = 88 + (self.index * 32)
      self.bitmap.blt(0, 0, @statselArrowleft.bitmap, Rect.new(0, 0, @statselArrowleft.width, @statselArrowleft.height))
      self.bitmap.blt(@statselArrowleft.width - 4, 0, @statselArrowright.bitmap, Rect.new(0, 0, @statselArrowright.width, @statselArrowright.height))
      self.bitmap.blt(@statselArrowleft.width + @statselArrowright.width, 0, @statsel.bitmap, Rect.new(0, @statsel.height / 2, @statsel.width, @statsel.height / 2))
    else
      self.x = 310
      self.y = 72 + (self.index * 32)
      self.bitmap.blt(10, 0, @statselArrowleft.bitmap, Rect.new(0, 0, @statselArrowleft.width, @statselArrowleft.height)) unless @hideLeftArrow
      self.bitmap.blt(@statselArrowleft.width, 0, @statsel.bitmap, Rect.new(0, 0, @statsel.width, @statsel.height / 2))
      self.bitmap.blt(@statselArrowleft.width + (@statsel.width - 44) - 10, 0, @statselArrowright.bitmap, Rect.new(0, 0, @statselArrowright.width, @statselArrowright.height)) unless @hideRightArrow
    end
  end

  def update
    @updating = true
    super
    @statsel.update
    @updating = false
    refresh
  end
end

ItemHandlers::UseOnPokemon.add(:ZSPLICER, proc { |item, pokemon, scene|
  if pokemon.species == :ZYGARDE && pokemon.customForm
    pokemon.customForm = nil
    pokemon.fused.changeForm(0) if pokemon.fused.species == :TERAPAGOS && pokemon.fused.form == 1
    pokemon.moves = pokemon.fused.moves
    pokemon.species = pokemon.fused.species
    pokemon.changeForm(pokemon.fused.form)
    pokemon.ability = pokemon.fused.ability
    pokemon.name = getMonName(pokemon.species, pokemon.fused.form) if pokemon.name == "Zygarde"
    pokemon.fused = nil
    pokemon.checksAfterItemChange
    pokemon.calcStats
    scene.pbHardRefresh
    scene.pbDisplay(_INTL("¡Las células de Zygarde han abandonado a {1}!", pokemon.name))
    next true
  else
    if pokemon.fused
      scene.pbDisplay(_INTL("¡Las células de Zygarde no pueden fusionarse con varios Pokémon a la vez!"))
      next false
    end
    if pokemon.species == :ZYGARDE
      scene.pbDisplay(_INTL("¡No se puede obtener ninguna ventaja de esto!"))
      next false
    end
    playerZygarde = searchPokemon(species: :ZYGARDE)
    if playerZygarde.any? {|pkmn| pkmn.customForm}
      scene.pbDisplay(_INTL("¡La forma de oportunidad de Zygarde ya está activa!"))
      next false
    end
    pokemon.changeForm(1) if pokemon.species == :TERAPAGOS && pokemon.form == 0
    pokemon.fused = deep_copy(pokemon)
    pokemon.createCustomMon
    pokemon.species = :ZYGARDE
    pokemon.changeForm($game_switches[:RenegadeRoute] ? 5 : 4)
    pokemon.ability = :AURABREAK
    pokemon.name = getMonName(pokemon.species, pokemon.fused.form) if pokemon.name == getMonName(pokemon.fused.species, pokemon.fused.form)
    summaryscene = PokemonSummaryScene.new
    screen = PokemonSummary.new(summaryscene)
    screen.pbZygardeScene($Trainer.party, $Trainer.party.index(pokemon))
    pokemon.calcStats
    scene.pbHardRefresh
    scene.pbDisplay(_INTL("¡Las células de Zygarde se han fusionado con {1}!", pokemon.name))
    if $Trainer
      $Trainer.pokedex.setOwned(pokemon) if !$Trainer.pokedex.owned?(pokemon.species, pokemon.form)
    end
    next true
  end
})
################################################################################
# Shows the "Nest" page of the Pokédex entry screen.
################################################################################
class PokemonNestMapScene
  def pbStartScene(dummymon, regionmap = -1)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    region = regionmap
    if region < 0 # Use player's current region
      mappos = $cache.mapdata[$game_map.map_id].MapPosition
      region = mappos ? mappos[0] : 0 # Region 0 default
    end
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/pokedexNest")
    if !Reborn && $game_switches[:Advanced_Pokedex]
      @sprites["dexbar"] = IconSprite.new(0, 0, @viewport)
      @sprites["dexbar"].setBitmap("Graphics/Pictures/Pokedex/advancedPokedexNestBar")
    end
    @sprites["map"] = IconSprite.new(0, 0, @viewport)
    @sprites["map"].setBitmap("Graphics/Pictures/#{$cache.town_map[region][:filename]}")
    @sprites["map"].x += (Graphics.width - @sprites["map"].bitmap.width) / 2
    @sprites["map"].y += (Graphics.height - @sprites["map"].bitmap.height) / 2
    for hidden in REGIONMAPEXTRAS
      if hidden[0] == region && hidden[1] > 0 && $game_switches[hidden[1]]
        if !@sprites["map2"]
          @sprites["map2"] = BitmapSprite.new(480, 320, @viewport)
          @sprites["map2"].x = @sprites["map"].x; @sprites["map2"].y = @sprites["map"].y
        end
        pbDrawImagePositions(
          @sprites["map2"].bitmap,
          [
            [
              "Graphics/Pictures/#{hidden[4]}",
              hidden[2] * PokemonRegionMapScene::SQUAREWIDTH,
              hidden[3] * PokemonRegionMapScene::SQUAREHEIGHT, 0, 0, -1, -1
            ]
          ]
        )
      end
    end
    @point = BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH + 4, PokemonRegionMapScene::SQUAREHEIGHT + 4)
    @point.fill_rect(0, 0, PokemonRegionMapScene::SQUAREWIDTH + 4, PokemonRegionMapScene::SQUAREHEIGHT + 4, Color.new(255, 0, 0))
    @point2 = BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH + 4, PokemonRegionMapScene::SQUAREHEIGHT + 4)
    @point2.fill_rect(4, 0, PokemonRegionMapScene::SQUAREWIDTH, PokemonRegionMapScene::SQUAREHEIGHT + 4, Color.new(255, 0, 0))
    @point3 = BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH + 4, PokemonRegionMapScene::SQUAREHEIGHT + 4)
    @point3.fill_rect(0, 4, PokemonRegionMapScene::SQUAREWIDTH + 4, PokemonRegionMapScene::SQUAREHEIGHT, Color.new(255, 0, 0))
    @point4 = BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH + 4, PokemonRegionMapScene::SQUAREHEIGHT + 4)
    @point4.fill_rect(4, 4, PokemonRegionMapScene::SQUAREWIDTH, PokemonRegionMapScene::SQUAREHEIGHT, Color.new(255, 0, 0))

    points = []
    mapwidth = 1 + PokemonRegionMapScene::RIGHT - PokemonRegionMapScene::LEFT
    @encounters = []
    maps = getRelevantEncounterMaps([region])
    for mapid in maps
      encdata = $cache.mapdata[mapid].getEncounterDataSpecific(dummymon.species, dummymon.form)
      next if encdata.empty?

      encdata.each { |type, chance, note|
        @encounters.push([mapid, pbGetUniqueMapName(mapid), type, chance, note])
      }

      mappos = $cache.mapdata[mapid].MapPosition
      mapX = mappos ? mappos[1] : PokemonRegionMapScene::DEFAULT_X
      mapY = mappos ? mappos[2] : PokemonRegionMapScene::DEFAULT_Y
      mapsize = $cache.mapdata[mapid].MapSize
      if mapsize && mapsize[0] && mapsize[0] > 0
        sqwidth = mapsize[0]
        sqheight = (mapsize[1].length * 1.0 / mapsize[0]).ceil
        for i in 0...sqwidth
          for j in 0...sqheight
            if mapsize[1][i + j * sqwidth, 1].to_i > 0
              points[mapX + i + (mapY + j) * mapwidth] = true
            end
          end
        end
      else
        points[mapX + mapY * mapwidth] = true
      end
    end

    i = 0
    for j in 0...points.length
      if points[j]
        s = SpriteWrapper.new(@viewport)
        s.x = (j % mapwidth) * PokemonRegionMapScene::SQUAREWIDTH - 2
        s.x += (Graphics.width - @sprites["map"].bitmap.width) / 2
        s.y = (j / mapwidth) * PokemonRegionMapScene::SQUAREHEIGHT - 2
        s.y += (Graphics.height - @sprites["map"].bitmap.height) / 2
        if j >= 1 && points[j - 1]
          if j >= mapwidth && points[j - mapwidth]
            s.bitmap = @point4
          else
            s.bitmap = @point2
          end
        else
          if j >= mapwidth && points[j - mapwidth]
            s.bitmap = @point3
          else
            s.bitmap = @point
          end
        end
        @sprites["point#{i}"] = s
        i += 1
      end
    end
    @numpoints = i

    @sprites["mapbottom"] = MapBottomSprite.new(@viewport)
    @sprites["mapbottom"].maplocation = pbGetMessageFromHash(:RegionNames, $cache.town_map[region][:name])
    nesttext = _INTL("{1}'s nest", getMonName(dummymon.species, dummymon.form))
    @sprites["mapbottom"].mapdetails = nesttext
    tts(nesttext, true)
    if @encounters.empty?
      @sprites["mapbottom"].alttext = _INTL("No Known Nests")
    end
    mapids = @encounters.map { |enc| enc[0] }
    tts(mapIDsToMapNames(mapids).join(", "))

    return true
  end

  def pbUpdatePoints
    @numpoints.times { |i|
      @sprites["point#{i}"].opacity = [64, 96, 128, 160, 128, 96][(Graphics.frame_count / 4) % 6]
    }
  end

  def pbMapScene(listlimits)
    Graphics.transition
    ret = 0
    loop do
      Graphics.update
      Input.update
      showingEncounters? ? @sprites["encounters"].update : pbUpdatePoints # No need to do the blinking animations in the background when showing the encounters window
      if Input.trigger?(Input::LEFT)
        ret = 4
        break
      elsif Input.trigger?(Input::RIGHT)
        ret = 6
        break
      elsif Input.repeat?(Input::L) && listlimits & 1 == 0 # If not at top of list
        ret = 8
        break
      elsif Input.repeat?(Input::R) && listlimits & 2 == 0 # If not at end of list
        ret = 2
        break
      elsif showingEncounters? && Input.trigger?(Input::B)
        pbPlayCancelSE()
        @sprites["encounters"].dispose
        @sprites["encounters"] = nil
      elsif !showingEncounters? && !@encounters.empty? && Input.trigger?(Input::C)
        pbPlayDecisionSE()
        encX, encY, encWidth, encHeight = 0, 32, Graphics.width, Graphics.height - 64
        @sprites["encounters"] = encounterDetailsWindow(@encounters, @viewport, encX, encY, encWidth, encHeight)
      elsif Input.trigger?(Input::B)
        ret = 1
        pbPlayCancelSE()
        pbFadeOutAndHide(@sprites)
        break
      end
    end
    return ret
  end

  def showingEncounters?
    return !@sprites["encounters"].nil?
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @point.dispose
    @viewport.dispose
  end
end

class PokemonNestMap
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(dummymon, region, listlimits)
    @scene.pbStartScene(dummymon, region)
    ret = @scene.pbMapScene(listlimits)
    @scene.pbEndScene
    return ret
  end
end

################################################################################
# Shows the "Form" page of the Pokédex entry screen.
################################################################################
class PokedexFormScene
  def pbStartScene(dummymon)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @dummymon = dummymon
    @species = @dummymon.species
    updateVariablesFromDummyPokemon(true)

    @available = [pbAvailableForms, pbAvailableGenders(@formnum)]
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/pokedexForm")
    if !Reborn && $game_switches[:Advanced_Pokedex]
      @sprites["dexbar"] = IconSprite.new(0, 0, @viewport)
      @sprites["dexbar"].setBitmap("Graphics/Pictures/Pokedex/advancedPokedexFormBar")
    end
    @sprites["info"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["front"] = PokemonSprite.new(@viewport)
    @sprites["back"] = PokemonSprite.new(@viewport)
    @sprites["icon"] = PokemonSpeciesIconSprite.new(@species, @gender, @formnum, @shiny, @shadow, @viewport)
    @sprites["icon"].x = 52
    @sprites["icon"].y = 290
    pbUpdate
    return true
  end

  def pbUpdate
    @sprites["info"].bitmap.clear
    pbSetSystemFont(@sprites["info"].bitmap)

    if @gender != ""
      gendertext = hasGenderDifference?(@species, @form) ? genderName(@gender) : _INTL("Any")
      gendertext = _INTL("Gender: {1}", gendertext)
    else
      gendertext = ""
    end

    formtext = @form != 0 && @form != nil ? @form : ""

    if @species == :UNOWN
      formtext = "#{pbGetMessage(:Species, "Unown")} '#{pbGetMessage(:FormNames, formtext)}'"
    else
      formtext = pbGetMessage(:FormNames, formtext)
    end

    nametext = getMonName(@species, @formnum)
    nametext = _INTL("Shadow {1}", nametext) if @shadow
    nametext = _INTL("Shiny {1}", nametext) if @shiny

    line = formtext
    line += "         " if formtext != "" && gendertext != ""
    line += gendertext
    colors = Rejuv ? ColorArrays[:Default] : LightColorArrays[:Default]
    text = [
      [
        nametext,
        Graphics.width / 2, Graphics.height - 86, 2,
        *colors
      ],
      [
        line,
        Graphics.width / 2, Graphics.height - 54, 2,
        *colors
      ],
    ]
    pbDrawTextPositions(@sprites["info"].bitmap, text)

    @sprites["icon"].battle = @battle || false
    # Egg sprite is viewable only if you own the pokemon; this check is needed for when form is changed while having egg view toggled On
    @egg = false if !$Trainer.pokedex.owned?(@species, @formnum)
    @sprites["icon"].egg = @egg || false

    frontBitmap = pbPokemonBitmap(@species, @shiny, false, @gender, @formnum, @shadow, egg: @egg, battle: @battle)
    @sprites["front"].bitmap = frontBitmap || @sprites["front"].bitmap
    backBitmap = pbPokemonBitmap(@species, @shiny, true, @gender, @formnum, @shadow, battle: @battle)
    @sprites["back"].bitmap = @egg ? nil : (backBitmap || @sprites["back"].bitmap)
    # backMetric = @dummymon.getCacheData.BattlerPlayerY
    pbPositionPokemonSprite(@sprites["front"], 74, 96)
    pbPositionPokemonSprite(@sprites["back"], 310, 96) # + 16) # + backMetric * 2)

    @sprites["icon"].update
  end

  def pbAvailableForms
    formnames = $Trainer.pokedex[@species].forms.keys

    availableForms = []
    for forms in formnames
      availableForms.push(forms) if $Trainer.pokedex[@species].debug || $Trainer.pokedex.seen?(@species, forms)
    end

    return availableForms
  end

  def pbAvailableGenders(form)
    availableGenders = []
    if hasGenderDifference?(@species, form)
      availableGenders.push(:M) if $Trainer.pokedex.seen?(@species, form, :M)
      availableGenders.push(:F) if $Trainer.pokedex.seen?(@species, form, :F)
    else
      availableGenders = [:M]
    end
    return availableGenders
  end

  def pbChooseForm
    choicearr = []
    choicearr.push(_INTL("Gender")) if @available[1].length > 1
    choicearr.push(_INTL("Form")) if @available[0].length > 1
    choicearr.push(_INTL("Toggle Shiny")) if $Trainer.pokedex.shinySeen?(@species, @formnum)
    choicearr.push(_INTL("Toggle Shadow")) if $Trainer.pokedex.shadowCaught?(@species, @formnum)
    choicearr.push(_INTL("Toggle Battle Form")) if hasBattleDifference?(@species, @formnum)
    choicearr.push(_INTL("Toggle Egg")) if $Trainer.pokedex.owned?(@species, @formnum) && pbCanBeEgg?(@species, @formnum)
    return if choicearr.length == 0

    choice = Kernel.pbMessage(_INTL("Which sprite would you like to view?"), choicearr, -1)
    return if choice == -1

    if choicearr[choice] == _INTL("Gender")
      genderoptions = @available[1].map { |gender| genderName(gender) }
      genderchoice = Kernel.pbMessage(_INTL("Which gender would you like to view?"), genderoptions, -1)
      return if genderchoice == -1

      gender = [:M, :F][genderchoice]
      @dummymon.setGender(gender)
      updateVariablesFromDummyPokemon
    end
    if choicearr[choice] == _INTL("Form")
      formoptions = @available[0].map { |form| pbGetMessage(:FormNames, form) } # Get display translations
      formchoice = Kernel.pbMessage(_INTL("Which form would you like to view?"), formoptions, -1)
      return if formchoice == -1

      form = @available[0][formchoice] # Get the internal value for indexing
      form = $cache.pkmn[@species].forms.empty? ? 0 : $cache.pkmn[@species].forms.invert[form]

      @dummymon.form = form
      updateVariablesFromDummyPokemon
    end
    if choicearr[choice] == _INTL("Toggle Shiny")
      @dummymon.shinyflag = !@shiny
      updateVariablesFromDummyPokemon
    end
    if choicearr[choice] == _INTL("Toggle Shadow")
      @shadow ? @dummymon.unmakeFakeShadow : @dummymon.makeFakeShadow # Weird but we are inverting here, @shadow is set later
      updateVariablesFromDummyPokemon
    end
    if choicearr[choice] == _INTL("Toggle Battle Form")
      @battle = !@battle
      pbUpdate
    end
    if choicearr[choice] == _INTL("Toggle Egg")
      @egg = !@egg
      pbUpdate
    end
  end

  def changeForm(direction)
    sprites = []
    pbAvailableForms.each do |form|
      formnum = $cache.pkmn[@species].forms.empty? ? 0 : $cache.pkmn[@species].forms.invert[form]
      shiny = $Trainer.pokedex.shinySeen?(@species, formnum)
      shadow = $Trainer.pokedex.shadowCaught?(@species, formnum)
      pbAvailableGenders(formnum).each do |gender|
        genderform = formnum
        sprites.push([genderform, gender, false, false])
        sprites.push([genderform, gender, true, false]) if shiny
        sprites.push([genderform, gender, false, true]) if shadow
        sprites.push([genderform, gender, true, true]) if shiny && shadow
      end
    end
    return if sprites.length <= 1

    current = [@dummymon.form, @dummymon.gender, @dummymon.shinyflag, @dummymon.isShadow?]
    i = sprites.index(current)
    i = 0 if i.nil?
    i += direction
    i %= sprites.length
    sprite = sprites[i]

    @dummymon.form = sprite[0]
    @dummymon.setGender(sprite[1])
    @dummymon.shinyflag = sprite[2]
    sprite[3] ? @dummymon.makeFakeShadow : @dummymon.unmakeFakeShadow
    updateVariablesFromDummyPokemon
    pbPlayCursorSE()
  end

  def updateVariablesFromDummyPokemon(initializing = false)
    @formnum = @dummymon.form

    @form = $cache.pkmn[@species].forms.empty? ? "Normal Form" : $cache.pkmn[@species].forms[@formnum]
    @gender = @dummymon.gender
    @shiny = @dummymon.isShiny?
    @shadow = @dummymon.isShadow?

    return if initializing
    # sprite["icon"] is created only after the variables are set during scene initialization

    @sprites["icon"].form = @formnum
    @sprites["icon"].gender = @gender
    @sprites["icon"].shiny = @shiny
    @sprites["icon"].shadow = @shadow
    pbUpdate
  end

  def pbControls(listlimits)
    Graphics.transition
    ret = 0
    loop do
      Graphics.update
      Input.update
      @sprites["icon"].update
      if Input.trigger?(Input::C)
        pbChooseForm
      elsif Input.trigger?(Input::LEFT)
        ret = 4
        break
      elsif Input.trigger?(Input::RIGHT)
        ret = 6
        break
      elsif Input.repeat?(Input::L) && listlimits & 1 == 0 # If not at top of list
        ret = 8
        break
      elsif Input.repeat?(Input::R) && listlimits & 2 == 0 # If not at end of list
        ret = 2
        break
      elsif Input.repeat?(Input::UP)
        changeForm(-1)
      elsif Input.repeat?(Input::DOWN)
        changeForm(1)
      elsif Input.trigger?(Input::B)
        ret = 1
        pbPlayCancelSE()
        pbFadeOutAndHide(@sprites)
        break
      end
    end
    $Trainer.pokedex[@species].setLastSeen(@form, @gender, @shiny, @shadow)
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class PokedexForm
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(dummymon, listlimits)
    @scene.pbStartScene(dummymon)
    tts(_INTL("Sprite View: {1}", getMonName(dummymon.species, dummymon.form)), true)
    ret = @scene.pbControls(listlimits)
    @scene.pbEndScene
    return ret
  end
end

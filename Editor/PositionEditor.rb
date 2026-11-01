def pbPositionScene
  scene = Scene_BattlerPosition.new
  scene.pbStartScene
end

#===============================================================================
# Scene_BattlerPosition
#===============================================================================
class Scene_BattlerPosition
  TextColors = [Color.new(*[238] * 3), Color.new(*[60] * 3)] # [Base, Shadow]
  LineHeight = 20
  X          = 8
  Y          = 8
  XColumn    = 138
  Bound      = 48
  NavKeys    = {
    :Left  => [:LEFT,   :KP_4],
    :Right => [:RIGHT,  :KP_6],
    :Up    => [:UP,     :KP_8],
    :Down  => [:DOWN,   :KP_2],
    :Minus => [:MINUS,  :KP_MINUS],
    :Plus  => [:EQUALS, :KP_PLUS],
  }

  def pbStartScene
    $game_temp.in_battle = true
    @monindex = 0
    @bgindex = 0
    @side = 0
    @shadowmode = 0
    @editing = false
    @modes = [
      :BattlerPlayerX,
      :BattlerPlayerY,
      :BattlerEnemyX,
      :BattlerEnemyY,
      :BattlerShadowSize,
      :BattlerShadowX,
    ]
    @keylist = setupKeyList
    @bglist = setupBackgroundList
    @changedata = setupChangeData
    updateData
    @endscene = false

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    # Battler sprites
    @sprites["player"] = PokemonBattlerSprite.new(false, 0, @viewport)
    @sprites["enemy"]  = PokemonBattlerSprite.new(false, 1, @viewport)
    # Enemy sprite shadow
    @sprites["shadow"] = PokemonShadowSprite.new(@viewport)
    drawBattlers
    # Background
    @sprites["battlebg"] = AnimatedPlane.new(@viewport)
    @sprites["playerbase"] = IconSprite.new(PBScene::PLAYERBASEX, PBScene::PLAYERBASEY, @viewport)
    @sprites["enemybase"] = IconSprite.new(PBScene::FOEBASEX, PBScene::FOEBASEY, @viewport)
    drawBackground
    @sprites["playerbase"].x -= @sprites["playerbase"].bitmap.width / 2
    @sprites["playerbase"].y -= @sprites["playerbase"].bitmap.height
    @sprites["playerbase"].z = 1
    @sprites["enemybase"].x -= @sprites["enemybase"].bitmap.width / 2
    @sprites["enemybase"].y -= @sprites["enemybase"].bitmap.height / 2
    @sprites["enemybase"].z = 1
    # Battle position boxes
    @sprites["overlay"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"].setBitmap("Graphics/Pictures/PositionOverlay")
    @sprites["overlay"].z = 3
    # Message box
    @sprites["messagebox"] = IconSprite.new(0, Graphics.height - 96, @viewport)
    @sprites["messagebox"].setBitmap("Graphics/Pictures/Battle/battleMessage")
    @sprites["messagebox"].z = 2
    # Info
    @sprites["info"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["info"].z = 95
    pbSetSmallFont(@sprites["info"].bitmap)
    drawText

    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      return if @endscene
    end
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def setupKeyList
    list = []
    $cache.pkmn.each do |monsym, mondata|
      i = -1
      mondata.pokemonData.each do |form, formdata|
        i += 1
        next if form.include?("placeholder")

        key = {}
        key[:species] = monsym
        key[:form] = i
        key[:formname] = form
        key[:dexnum] = formdata.dexnum
        key[:name] = formdata.name
        key[:BattlerPlayerX] = formdata.BattlerPlayerX
        key[:BattlerPlayerY] = formdata.BattlerPlayerY
        key[:BattlerEnemyX] = formdata.BattlerEnemyX
        key[:BattlerEnemyY] = formdata.BattlerEnemyY
        key[:BattlerShadowSize] = formdata.BattlerShadowSize
        key[:BattlerShadowX] = formdata.BattlerShadowX
        if formdata.genderDifferences.any?
          key[:genderDifferences] = {}
          formdata.genderDifferences.each  { |gender, genderData|
            genderKey = {}
            genderKey[:BattlerPlayerX] = genderData.BattlerPlayerX
            genderKey[:BattlerPlayerY] = genderData.BattlerPlayerY
            genderKey[:BattlerEnemyX] = genderData.BattlerEnemyX
            genderKey[:BattlerEnemyY] = genderData.BattlerEnemyY
            genderKey[:BattlerShadowSize] = genderData.BattlerShadowSize
            genderKey[:BattlerShadowX] = genderData.BattlerShadowX
            key[:genderDifferences][gender] = genderKey
          }
        end
        list.push(key)
      end
    end
    return list
  end

  def setupBackgroundList
    list = []
    File.open("Scripts/#{GAMEFOLDER}/Definitions/fieldtext.rb") { |f|
      eval(f.read)
    }
    FIELDEFFECTS.each do |key, data|
      list.concat(data[:graphic])
    end
    return list
  end

  def setupChangeData
    changedata = Hash.new { |h, k| h[k] = {} }
    @keylist.each do |key|
      changedata[key[:species]][key[:formname]] = setupChanges(key)
    end
    return changedata
  end

  def setupChanges(key)
    changes = {}
    @modes.each { |mode| changes[mode] = 0 }
    if key[:genderDifferences]
      changes[:genderDifferences] = {}
      key[:genderDifferences].each { |gender, _|
        changes[:genderDifferences][gender] = {}
        @modes.each { |mode| changes[:genderDifferences][gender][mode] = 0}
      }
    end
    return changes
  end

  def setupBattler(sprite)
    params = {
      0 => { back: true,  x: PBScene::PLAYERBATTLER_X, y: PBScene::PLAYERBATTLER_Y, xflag: :BattlerPlayerX, yflag: :BattlerPlayerY },
      1 => { back: false, x: PBScene::FOEBATTLER_X,    y: PBScene::FOEBATTLER_Y,    xflag: :BattlerEnemyX,  yflag: :BattlerEnemyY  },
    }
    side = params[sprite.index]
    sprite.bitmap = pbPokemonBitmap(@key[:species], @shiny, side[:back], @gender, @key[:form])
    sprite.x = side[:x]
    sprite.y = side[:y]
    xoffset, yoffset = adjustBattleSprite(sprite, @dummymon.getCacheData, sprite.index)
    sprite.x += xoffset
    sprite.y += yoffset
    if sprite.index == 0
      sprite.x += getChangesPlayerX * 2 # Changes in the editor, unsaved
      sprite.y += getChangesPlayerY * 2
    else
      sprite.x += getChangesEnemyX * 2
      sprite.y += getChangesEnemyY * 2
    end
    sprite.z = 5
    sprite.visible = true
  end

  def drawBattlers
    @dummymon = PokeBattle_Pokemon.new(@key[:species], 1, $Trainer, true, @key[:form])
    @dummymon.setGender(@gender)
    # Battler sprites
    setupBattler(@sprites["player"])
    setupBattler(@sprites["enemy"])
    # Enemy sprite shadow
    @sprites["shadow"].setPokemonShadowBitmap(@dummymon.getCacheData, getChangesShadowSize)
    @sprites["shadow"].x = PBScene::FOEBATTLER_X
    @sprites["shadow"].x += adjustShadowSpriteX(@sprites["shadow"], @dummymon.getCacheData)
    @sprites["shadow"].x += getChangesShadowX * 2
    @sprites["shadow"].y = PBScene::FOEBATTLER_Y
    @sprites["shadow"].y -= @sprites["shadow"].bitmap.height / 2
    @sprites["shadow"].z = 4
    @sprites["shadow"].visible = showShadow?(@dummymon.getCacheData)
  end

  def drawBackground
    battlebg = "Graphics/Battlebacks/battlebg#{@bglist[@bgindex]}"
    playerbase = "Graphics/Battlebacks/playerbase#{@bglist[@bgindex]}"
    playerbase = "Graphics/Battlebacks/playerbaseDummy" if !pbResolveBitmap(sprintf(playerbase))
    enemybase = "Graphics/Battlebacks/enemybase#{@bglist[@bgindex]}"
    enemybase = "Graphics/Battlebacks/enemybaseDummy" if !pbResolveBitmap(sprintf(enemybase))
    @sprites["battlebg"].setBitmap(battlebg)
    @sprites["playerbase"].setBitmap(playerbase)
    @sprites["enemybase"].setBitmap(enemybase)
  end

  def drawText
    @sprites["info"].bitmap.clear
    @texts = []
    i = -1

    titletext = _INTL(
      "{1} {2}, {3}{4}{5}",
      @key[:dexnum].to_s.rjust(3, "0"),
      @key[:name],
      @key[:formname],
      @shiny ? _INTL(", Shiny") : "",
      @gender == :F ? _INTL(", Female") : ""
    )
    addText(titletext, i += 1)

    playerX = @dummymon.getCacheData.BattlerPlayerX + getChangesPlayerX
    playerY = @dummymon.getCacheData.BattlerPlayerY + getChangesPlayerY
    addText(_INTL("Player X / Y"), i += 1)
    addText("=> #{playerX} / #{playerY}", i, XColumn)

    enemyX = @dummymon.getCacheData.BattlerEnemyX + getChangesEnemyX
    enemyY = @dummymon.getCacheData.BattlerEnemyY + getChangesEnemyY
    addText(_INTL("Opponent X / Y"), i += 1)
    addText("=> #{enemyX} / #{enemyY}", i, XColumn)

    side = @side == 0 ? _INTL("Player") : _INTL("Opponent")
    addText(_INTL("Side"), i += 1)
    addText("=> #{side}", i, XColumn)

    shadowSize = @dummymon.getCacheData.BattlerShadowSize + getChangesShadowSize
    shadowX = @dummymon.getCacheData.BattlerShadowX + getChangesShadowX
    addText(_INTL("Shadow Size / X"), i += 1)
    addText("=> #{shadowSize} / #{shadowX}", i, XColumn)

    shadowmode = @shadowmode == 0 ? _INTL("Size") : _INTL("X")
    addText(_INTL("Shadow Mode"), i += 1)
    addText("=> #{shadowmode}", i, XColumn)

    background = @bglist[@bgindex]
    addText(_INTL("Background"), i += 1)
    addText("=> #{background}", i, XColumn)

    addText("#{@editing ? _INTL("EDITING...") : ""}", i += 2)
    addText(_INTL("F5: Help"), i += 9, 318)
    pbDrawTextPositions(@sprites["info"].bitmap, @texts)
  end

  def addText(text, i, offset = 0)
    @texts.push [text, X + offset, Y + LineHeight * i, 0, *TextColors]
  end

  # Right now genderforms just encompass female alternate data. If that changes, rework this.
  def isGenderForm?
    return @gender == :F && @key.dig(:genderDifferences, :F)
  end

  def getChangesPlayerX
    playerX = isGenderForm? ?
      @changes[:genderDifferences][:F][:BattlerPlayerX] :
      @changes[:BattlerPlayerX]
    return playerX
  end

  def getChangesPlayerY
    playerY = isGenderForm? ?
      @changes[:genderDifferences][:F][:BattlerPlayerY] :
      @changes[:BattlerPlayerY]
    return playerY
  end

  def getChangesEnemyX
    enemyX = isGenderForm? ?
      @changes[:genderDifferences][:F][:BattlerEnemyX] :
      @changes[:BattlerEnemyX]
    return enemyX
  end

  def getChangesEnemyY
    enemyY = isGenderForm? ?
      @changes[:genderDifferences][:F][:BattlerEnemyY] :
      @changes[:BattlerEnemyY]
    return enemyY
  end

  def getChangesShadowSize
    shadowSize = isGenderForm? ?
      @changes[:genderDifferences][:F][:BattlerShadowSize] :
      @changes[:BattlerShadowSize]
    return shadowSize
  end

  def getChangesShadowX
    shadowX = isGenderForm? ?
      @changes[:genderDifferences][:F][:BattlerShadowX] :
      @changes[:BattlerShadowX]
    return shadowX
  end

  def updateData
    @key = @keylist[@monindex]
    @gender = :M
    @changes = @changedata[@key[:species]][@key[:formname]]
  end

  def changeValue(sym, amt, lower = -Bound, upper = Bound)
    if sym == :BattlerShadowSize
      lower = 0
      upper = Bound * 2
    end
    if isGenderForm?
      val = @key[:genderDifferences][:F][sym] + @changes[:genderDifferences][:F][sym] + amt
      @changes[:genderDifferences][:F][sym] += amt if val.between?(lower, upper)
    else
      val = @key[sym] + @changes[sym] + amt
      @changes[sym] += amt if val.between?(lower, upper)
    end
    drawBattlers
    drawText
  end

  def search
    choices = [_INTL("Species"), _INTL("Background")]
    choice = Kernel.pbMessage(_INTL("Search for what?"), choices, -1)
    return if choice == -1

    found = false
    text = Kernel.pbMessageFreeText(_INTL("Enter {1}.", choices[choice]), "", 999, Graphics.width).upcase
    case choice
      when 0 # Species
        index = @keylist.find_index { |key| key[:species].to_s.upcase == text }
        if index
          @monindex = index
          updateData
          drawBattlers
          drawText
          found = true
        end
      when 1 # Background
        index = @bglist.find_index { |bg| bg.to_s.upcase == text }
        if index
          @bgindex = index
          drawBackground
          drawText
          found = true
        end
    end
    Kernel.pbMessage(_INTL("{1} not found!", choices[choice])) unless found
  end

  def helpWindow
    helptext = ""
    helptext += _INTL("=== Editor Controls ===") + "\n"
    helptext += _INTL("←/→ or Q/W: Change sprite") + "\n"
    helptext += _INTL("Z: Edit, C: Change side, V: Change shadow mode") + "\n"
    helptext += _INTL("←/→/↑/↓: Edit X / Y offsets") + "\n"
    helptext += _INTL("-/+: Edit shadow size / X") + "\n"
    helptext += _INTL("R: Reset battler's changed offsets") + "\n\n"
    helptext += _INTL("=== Other Controls ===") + "\n"
    helptext += _INTL("TOGGLES - S: Shiny, F: Gender, O: Overlay") + "\n"
    helptext += _INTL("A: Search, B: Cycle background") + "\n"
    helptext += _INTL("X: Exit editor")
    title = Window_UnformattedTextPokemon.new(helptext)
    title.width = Graphics.width
    title.height = Graphics.height
    title.viewport = @viewport
    title.z = 99999
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::C) || Input.trigger?(Input::B) || Input.triggerex?(:F5)
    end
    Input.update
    title.dispose
  end

  def update
    if @editing
      changeValue(@modes[@side * 2],     -1) if Input.triggerexAny?(NavKeys[:Left])  || Input.repeatexAny?(NavKeys[:Left])
      changeValue(@modes[@side * 2],      1) if Input.triggerexAny?(NavKeys[:Right]) || Input.repeatexAny?(NavKeys[:Right])
      changeValue(@modes[@side * 2 + 1], -1) if Input.triggerexAny?(NavKeys[:Up])    || Input.repeatexAny?(NavKeys[:Up])
      changeValue(@modes[@side * 2 + 1],  1) if Input.triggerexAny?(NavKeys[:Down])  || Input.repeatexAny?(NavKeys[:Down])
      changeValue(@modes[@shadowmode + 4], -1) if Input.triggerexAny?(NavKeys[:Minus]) || Input.repeatexAny?(NavKeys[:Minus])
      changeValue(@modes[@shadowmode + 4],  1) if Input.triggerexAny?(NavKeys[:Plus])  || Input.repeatexAny?(NavKeys[:Plus])
    else
      oldindex = @monindex
      @monindex = (@monindex - 1) % @keylist.length         if Input.repeat?(Input::LEFT)
      @monindex = [@monindex - 10, 0].max                   if Input.repeat?(Input::L)
      @monindex = (@monindex + 1) % @keylist.length         if Input.repeat?(Input::RIGHT)
      @monindex = [@monindex + 10, @keylist.length - 1].min if Input.repeat?(Input::R)
      if oldindex != @monindex
        updateData
        drawBattlers
        drawText
      end
    end

    if Input.triggerex?(:R)
      @changedata[@key[:species]][@key[:formname]] = setupChanges(@key)
      updateData
      drawBattlers
      drawText
    end

    if Input.triggerex?(:A)
      search
    end

    if Input.triggerex?(:S)
      @shiny = !@shiny
      drawBattlers
      drawText
    end

    if Input.triggerex?(:F)
      @gender = @gender == :F ? :M : :F
      drawBattlers
      drawText
    end

    if Input.triggerex?(:O)
      @sprites["overlay"].visible = !@sprites["overlay"].visible
    end

    if Input.triggerex?(:C)
      @side = (@side + 1) % 2
      drawText
    end

    if Input.triggerex?(:V)
      @shadowmode = (@shadowmode + 1) % 2
      drawText
    end

    if Input.triggerex?(:B)
      @bgindex = (@bgindex + 1) % @bglist.length
      drawBackground
      drawText
    end

    if Input.triggerex?(:F5)
      helpWindow
    end

    if Input.triggerex?(:Z)
      @editing = !@editing
      drawText
    end

    if Input.triggerex?(:X) || Input.trigger?(Input::B)
      if @editing
        @editing = false
        drawText
      else
        if Kernel.pbConfirmMessage(_INTL("Save changes?"))
          saveChanges
        end
        if Kernel.pbConfirmMessage(_INTL("Exit from the editor?"))
          pbEndScene
          return
        end
      end
    end

    pbUpdateSpriteHash(@sprites)
  end

  def saveChanges
    files = ["montext.rb"]
    files.push "montext_modern.rb" if Reborn
    files.each do |file|
      File.open("Scripts/#{GAMEFOLDER}/Definitions/#{file}") { |f|
        eval(f.read)
      }

      if Reborn && file == "montext_modern.rb" && Gen < Champs # TODO: Latest gen constant?
        genbackup = Gen
        Object.const_set(:Gen, Champs)
      end

      newhash = MonDataHash.new()
      mons = MONHASH
      mons.each do |monsym, mondata|
        baseform = mondata.values[0] # Don't clone, because we want to compare against changes we just made
        i = -1
        mondata.each do |form, formdata|
          i += 1
          next if @keylist.none? { |key| key[:species] == monsym && key[:form] == i && key[:formname] == form }
          @modes.each { |mode| writeAttributeToHash(mode, monsym, form, formdata, baseform, mondata, i) }
          if formdata[:genderDifferences]
            @modes.each { |mode| writeAttributeToHash(mode, monsym, form, formdata, baseform, mondata, i, true) }
          end
        end

        inheritFormData(mondata)
        newhash[monsym] = MonWrapper.new(monsym, mondata)
      end
      monDump(newhash, game: GAMEFOLDER, file: file)

      if genbackup
        Object.const_set(:Gen, genbackup)
      end
    end
    compileMons
    compileMonsGen9 if Reborn
    @keylist = setupKeyList
    @changedata = setupChangeData
  end

  def writeAttributeToHash(attribute, monsym, form, formdata, baseform, mondata, i, gender = false)
    if gender
      value = formdata[:genderDifferences][:F][attribute] || baseform[attribute] || 0
      mondata[form][:genderDifferences][:F].delete(attribute)
      value += @changedata[monsym][form][:genderDifferences][:F][attribute]
    else
      value = formdata[attribute] || baseform[attribute] || 0
      mondata[form].delete(attribute)
      value += @changedata[monsym][form][attribute]
    end
    return if i == 0 && value == 0
    return if value == (baseform[attribute] || 0)

    if gender
      mondata[form][:genderDifferences][:F][attribute] = value
    else
      mondata[form][attribute] = value
    end
  end

  def pbEndScene
    $game_temp.in_battle = false
    @endscene = true
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

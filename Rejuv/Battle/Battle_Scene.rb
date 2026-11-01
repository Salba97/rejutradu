# Suplemtary Script that edits and adds to classes in Battle_Scene

class PokemonDataBox < SpriteWrapper
  #### StatBoosts - START
  def aGetStage(i)
    if i == 3
      return -6 if @battler.pbOpposingSide.effects[:LuckyChant] > 0
      return 6 if @battler.effects[:LaserFocus]

      return @battler.effects[:FocusEnergy]
    else
      case i
        when 0
          stat = PBStats::SPATK
        when 1
          stat = PBStats::SPDEF
        when 2
          stat = PBStats::SPEED
        when 4
          stat = PBStats::ATTACK
        when 5
          stat = PBStats::DEFENSE
        when 6
          stat = PBStats::EVASION
        when 7
          stat = PBStats::ACCURACY
      end

      return @battler.stages[stat]
    end
  end

  def aInitStatsTab(bIsFoe)
    aBitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/ShowStatBoosts")

    # Constants
    iWidth_Full = 56
    iHeight_Full = 50

    iLeft1 = 0
    iLeft2P = 27
    iLeft2F = 29

    iRow_Dist = 12
    iRow_Height = 14

    iCol_WidthL = 31
    iCol_WidthR = 27
    iCol_WidthP = 29

    iBorder = 2

    iLeft_NF1 = 0
    iLeft_LF1 = iWidth_Full + iLeft_NF1
    iLeft_GF1 = iWidth_Full + iLeft_LF1
    iLeft_NF2 = iLeft_NF1 + iCol_WidthL - iBorder
    iLeft_LF2 = iWidth_Full + iLeft_NF2
    iLeft_GF2 = iWidth_Full + iLeft_LF2

    iLeft_NP1 = 2
    iLeft_LP1 = iWidth_Full + iLeft_NP1
    iLeft_GP1 = iWidth_Full + iLeft_LP1
    iLeft_NP2 = iLeft_NP1 + iCol_WidthP - iBorder
    iLeft_LP2 = iWidth_Full + iLeft_NP2
    iLeft_GP2 = iWidth_Full + iLeft_LP2

    # Get bitmaps
    @aStatBoostsG = [] # Greater
    @aStatBoostsN = [] # None
    @aStatBoostsL = [] # Lower
    for i in 0...8
      @aStatBoostsG[i] = Bitmap.new(iWidth_Full, iHeight_Full)
      @aStatBoostsN[i] = Bitmap.new(iWidth_Full, iHeight_Full)
      @aStatBoostsL[i] = Bitmap.new(iWidth_Full, iHeight_Full)
    end

    @aStatBoostsNumG = []
    @aStatBoostsNumL = []

    for i in 0...4
      i2 = 4 + i # Right half of the tab

      iHL = i * 12
      iHL2 = iHL + iHeight_Full

      if bIsFoe
        aRect = Rect.new(iLeft_GF1, iHL, iCol_WidthL, iRow_Height)
        @aStatBoostsG[i].blt(iLeft1, iHL, aBitmap.bitmap, aRect)

        aRect = Rect.new(iLeft_NF1, iHL, iCol_WidthL, iRow_Height)
        @aStatBoostsN[i].blt(iLeft1, iHL, aBitmap.bitmap, aRect)

        aRect = Rect.new(iLeft_LF1, iHL, iCol_WidthL, iRow_Height)
        @aStatBoostsL[i].blt(iLeft1, iHL, aBitmap.bitmap, aRect)

        aRect = Rect.new(iLeft_GF2, iHL, iCol_WidthR, iRow_Height)
        @aStatBoostsG[i2].blt(iLeft2F, iHL, aBitmap.bitmap, aRect)

        aRect = Rect.new(iLeft_NF2, iHL, iCol_WidthR, iRow_Height)
        @aStatBoostsN[i2].blt(iLeft2F, iHL, aBitmap.bitmap, aRect)

        aRect = Rect.new(iLeft_LF2, iHL, iCol_WidthR, iRow_Height)
        @aStatBoostsL[i2].blt(iLeft2F, iHL, aBitmap.bitmap, aRect)
      else
        aRect = Rect.new(iLeft_GP1, iHL2, iCol_WidthP, iRow_Height)
        @aStatBoostsG[i].blt(iLeft1, iHL, aBitmap.bitmap, aRect)

        aRect = Rect.new(iLeft_NP1, iHL2, iCol_WidthP, iRow_Height)
        @aStatBoostsN[i].blt(iLeft1, iHL, aBitmap.bitmap, aRect)

        aRect = Rect.new(iLeft_LP1, iHL2, iCol_WidthP, iRow_Height)
        @aStatBoostsL[i].blt(iLeft1, iHL, aBitmap.bitmap, aRect)

        aRect = Rect.new(iLeft_GP2, iHL2, iCol_WidthP, iRow_Height)
        @aStatBoostsG[i2].blt(iLeft2P, iHL, aBitmap.bitmap, aRect)

        aRect = Rect.new(iLeft_NP2, iHL2, iCol_WidthP, iRow_Height)
        @aStatBoostsN[i2].blt(iLeft2P, iHL, aBitmap.bitmap, aRect)

        aRect = Rect.new(iLeft_LP2, iHL2, iCol_WidthP, iRow_Height)
        @aStatBoostsL[i2].blt(iLeft2P, iHL, aBitmap.bitmap, aRect)
      end
    end
    for i in 0...6
      @aStatBoostsNumG[i] = Bitmap.new(4, 6)
      aRect = Rect.new(172, 1 + (i * 7), 4, 6)
      @aStatBoostsNumG[i].blt(0, 0, aBitmap.bitmap, aRect)

      @aStatBoostsNumL[i] = Bitmap.new(4, 6)
      aRect = Rect.new(168, 1 + (i * 7), 4, 6)
      @aStatBoostsNumL[i].blt(0, 0, aBitmap.bitmap, aRect)
    end
  end
  #### StatBoosts - END

  def refresh(loopstop = false)
    self.bitmap.clear
    return if !@battler.pokemon

    bIsFoe = @battler.index.odd?
    filename = "Graphics/Pictures/Battle/battle"
    if @doublebattle
      filename += bIsFoe ? "FoeBoxD" : "PlayerBoxD"
    else
      filename += bIsFoe ? "FoeBoxS" : "PlayerBoxS"
    end
    filename += @battler.status.nil? ? "" : @battler.status.to_s
    @databox = AnimatedBitmap.new(filename)

    self.bitmap.blt(0, 0, @databox.bitmap, Rect.new(0, 0, @databox.width, @databox.height))
    base = PBScene::BOXBASE
    shadow = PBScene::BOXSHADOW
    pokename = @battler.effects[:clearDisguise] ? @battler.battle.pbSwitchInName(@battler.index, @battler.pokemonIndex) : @battler.name

    headerY = bIsFoe ? 22 : 18
    sbX = bIsFoe ? (@spritebaseX - 12) : @spritebaseX
    if @doublebattle
      headerY -= bIsFoe ? 16 : 12
      sbX += bIsFoe ? 8 : 6
    end

    pbSetSystemFont(self.bitmap)
    textpos = [
      [pokename, sbX + 8, headerY, false, base, shadow]
    ]
    genderX = self.bitmap.text_size(pokename).width
    genderX += sbX + 14
    if genderX > 165 && !@doublebattle && (@battler.index & 1) == 1 # opposing pokemon
      genderX = 224
    end
    infotarget = @battler.effects[:Illusion] ? @battler.effects[:Illusion] : @battler.effects[:clearDisguise] ? @battler.effects[:clearDisguise] : @battler
    unless infotarget.gender == :N
      colors = infotarget.isMale? ? [Color.new(48, 96, 216), shadow] : [Color.new(248, 88, 40), shadow]
      textpos.push([genderSign(infotarget.gender), genderX, headerY, false, *colors])
    end
    pbDrawTextPositions(self.bitmap, textpos)
    pbSetSmallFont(self.bitmap)
    leveladjust = bIsFoe ? 198 : 202
    level = @battler.level
    if (@battler.index % 2) == 1
      level = "???" if $game_switches[:Level_qmarks]
      level = 999 if $game_switches[:Level_999]
    end
    level = "???" if @battler.pokemon.obtainLevel == :Undefinable
    longNameAdjust = 0
    if genderX > 140 && bIsFoe
      levelstring = _INTL("Lv{1}", level)
      longNameAdjust = self.bitmap.text_size(levelstring).width >= 50 ? 20 : 14
    end
    textpos = [[_INTL("Lv{1}", level), sbX + leveladjust + longNameAdjust, headerY + 8, true, base, shadow]]
    if @showhp
      hpstring = _ISPRINTF("{1: 2d}/{2: 2d}", self.hp, @battler.totalhp)
      textpos.push([hpstring, sbX + 202, 78, true, base, shadow])
    end
    pbDrawTextPositions(self.bitmap, textpos)
    # Shiny
    imagepos = []
    if infotarget.pokemon.isShiny?
      shinyX = bIsFoe ? 202 : -16
      shinyY = @doublebattle ? 12 : bIsFoe ? 24 : 28
      imagepos.push(["Graphics/Pictures/shiny.png", sbX + shinyX + longNameAdjust, shinyY, 0, 0, -1, -2])
    end
    # Mega
    megaY = @doublebattle ? 32 : 52
    megaY -= 4 if !bIsFoe
    megaX = bIsFoe ? 214 : -26
    megaSym = nil
    case true
      when infotarget.pokemon.isPulse? then megaSym = "Graphics/Pictures/Battle/battlePulseEvoBox.png"
      #when infotarget.pokemon.isRift? then megaSym = "Graphics/Pictures/Battle/battleRiftEvoBox.png"
      when infotarget.pokemon.isPerfection? then megaSym = "Graphics/Pictures/Battle/battlePerfectionEvoBox.png"
      when infotarget.isMega? then megaSym = "Graphics/Pictures/Battle/battleMegaEvoBox.png"
      when infotarget.isUltra? then megaSym = "Graphics/Pictures/Battle/battleMegaEvoBox.png" # Maybe temporary until new icon
      when infotarget.isTerastallized? then megaSym = "Graphics/Pictures/Battle/battleMegaEvoBox.png" # Maybe temporary until new icon
    end
    imagepos.push([megaSym, sbX + megaX, megaY, 0, 0, -1, -1]) if megaSym
    # Crest
    if infotarget.crested
      if infotarget.fakeCrest
        imagepos.push(["Graphics/Pictures/Battle/battleApplyCrest.png", sbX + megaX - 2, megaY, 0, 0, -1, -1])
      else
        imagepos.push(["Graphics/Pictures/Battle/battleCrest.png", sbX + megaX - 2, megaY, 0, 0, -1, -1])
      end
    end
    # Owned
    ownstate = infotarget.ownedstate
    if ownstate && bIsFoe
      if @doublebattle
        imagepos.push(["Graphics/Pictures/Battle/battleBoxOwned#{ownstate == 1 ? "Species" : ""}.png", sbX - 12, 4, 0, 0, -1, -1]) if (@battler.index) == 3
        imagepos.push(["Graphics/Pictures/Battle/battleBoxOwned#{ownstate == 1 ? "Species" : ""}.png", sbX - 18, 4, 0, 0, -1, -1]) if (@battler.index) == 1
      else
        imagepos.push(["Graphics/Pictures/Battle/battleBoxOwned#{ownstate == 1 ? "Species" : ""}.png", sbX - 12, 20, 0, 0, -1, -1])
      end
    end
    pbDrawImagePositions(self.bitmap, imagepos)
    hpgauge = (@battler.totalhp == 0 || self.hp == 0) ? 0 : [self.hp * PBScene::HPGAUGESIZE / @battler.totalhp, 2].max.to_grid
    hpzone = getHPZone(self.hp, @battler.totalhp)
    # fill with black (shows what the HP used to be)
    hpGaugeX = PBScene::HPGAUGE_X
    hpGaugeY = PBScene::HPGAUGE_Y
    if bIsFoe
      hpGaugeX += 8
      hpGaugeY += 4
    end
    hpGaugeY -= bIsFoe ? 16 : 12 if @doublebattle

    if @doublebattle
      @hpbar = AnimatedBitmap.new("Graphics/Pictures/Battle/hpbardoubles")
      hpbarconstant = PBScene::HPGAUGEHEIGHTD
    else
      @hpbar = AnimatedBitmap.new("Graphics/Pictures/Battle/hpbar")
      hpbarconstant = PBScene::HPGAUGEHEIGHTS
    end
    self.bitmap.blt(sbX + hpGaugeX, hpGaugeY, @hpbar.bitmap, Rect.new(0, hpzone * hpbarconstant, hpgauge, hpbarconstant))

    # Status
    if !@battler.status.nil?
      imagepos = []
      if @doublebattle
        imagepos.push([sprintf("Graphics/Pictures/Battle/BattleStatuses" + "D" + "%s", @battler.status), sbX + hpGaugeX + 6, hpGaugeY - 2, 0, 0, 64, 28])
      else
        imagepos.push([sprintf("Graphics/Pictures/Battle/BattleStatuses%s", @battler.status), sbX + hpGaugeX + 6, hpGaugeY, 0, 0, 64, 28])
      end
      pbDrawImagePositions(self.bitmap, imagepos)
    end
    if @showexp
      # fill with EXP color
      expGaugeX = PBScene::EXPGAUGE_X
      expGaugeY = PBScene::EXPGAUGE_Y
      self.bitmap.fill_rect(sbX + expGaugeX, expGaugeY, self.exp.clamp(0, PBScene::EXPGAUGESIZE), 2, PBScene::EXPCOLORSHADOW)
      self.bitmap.fill_rect(sbX + expGaugeX, expGaugeY + 2, self.exp.clamp(0, PBScene::EXPGAUGESIZE), 4, PBScene::EXPCOLORBASE)
    end
    #pbShowStatsBoosts if loopstop == false
  end
end

class DefaultBallButton < BitmapSprite
  GraphicSize = [56, 78] # width, height
  BallOffset = [-4, 0] # x, y
  LeftArrowOffset = [24, 42] # x, y
  RightArrowOffset = [32, 46] # x, y
  TextBoxOffsetX = 0
  TextBoxOffsetY = 46
  TextBoxWidth = 24
end

class PokeBattle_DebugSceneNoLogging
  def pbFakeOutFainted(pkmn)
  end
end

class PokeBattle_DebugScene
  def pbFakeOutFainted(pkmn)
  end
end

class PokeBattle_DebugSceneNoGraphics
  # This method is called whenever a Pokémon faints
  def pbFakeOutFainted(pkmn)
  end
end

####################################################

class PokeBattle_Scene
  def pbInputUpdate
    Input.update
  end

  # This method is called whenever a Pokémon faints.
  def pbFakeOutFainted(pkmn)
    frames = pbCryFrameLength(pkmn.pokemon)
    pbPlayCry(pkmn.pokemon)
    frames.times do
      pbGraphicsUpdate
      pbInputUpdate
    end
    @sprites["shadow#{pkmn.index}"].visible = false
    pkmnsprite = @sprites["pokemon#{pkmn.index}"]
    ycoord = 0
    if @battle.doublebattle
      ycoord = PBScene::PLAYERBATTLERD1_Y if pkmn.index == 0
      ycoord = PBScene::FOEBATTLERD1_Y if pkmn.index == 1
      ycoord = PBScene::PLAYERBATTLERD2_Y if pkmn.index == 2
      ycoord = PBScene::FOEBATTLERD2_Y if pkmn.index == 3
    else
      if @battle.pbIsOpposing?(pkmn.index)
        ycoord = PBScene::FOEBATTLER_Y
      else
        ycoord = PBScene::PLAYERBATTLER_Y
      end
    end
    @battle.pbIsOpposing?(pkmn.index) ? pbSEPlay("faint#{$Settings.audiotype == 0 ? "_R" : ""}") : pbSEPlay("faint#{$Settings.audiotype == 0 ? "_L" : ""}")
    heightsave = pkmnsprite.src_rect.height
    loop do
      pkmnsprite.y += 8
      if pkmnsprite.y - pkmnsprite.oy + pkmnsprite.src_rect.height >= ycoord
        pkmnsprite.src_rect.height = ycoord - pkmnsprite.y + pkmnsprite.oy
      end
      pbGraphicsUpdate
      pbInputUpdate
      break if pkmnsprite.y >= ycoord
    end
    pkmnsprite.visible = false
    pkmn.changeForm(2)
    pbChangePokemon(pkmn, pkmn.pokemon)
    loop do
      pkmnsprite.y -= 4
      if pkmnsprite.y + pkmnsprite.oy + pkmnsprite.src_rect.height <= ycoord
        pkmnsprite.src_rect.height = ycoord - pkmnsprite.y + pkmnsprite.oy
      end
      pbGraphicsUpdate
      pbInputUpdate
      break if pkmnsprite.src_rect.height >= (heightsave - 20)
    end
    frames = pbCryFrameLength(pkmn.pokemon)
    pbPlayCry(pkmn.pokemon)
    pkmnsprite.visible = true
  end



  def pbBackdrop
    backdrop = @battle.field.backdrop
    # Choose bases
    environ = @battle.environment
    base = ""
    if environ == :Grass || environ == :TallGrass
      base = "Grass"
    elsif environ == :Sand
      base = "Sand"
    elsif $PokemonGlobal.surfing
      base = "Water"
    elsif $PokemonGlobal.lavasurfing
      base = "Volcano"
    end
    base = "" if !pbResolveBitmap(sprintf("Graphics/Battlebacks/playerbase" + backdrop + base))
    # Choose time of day
    time = ""
    timenow = pbGetTimeNow
    if PBDayNight.isNight?(timenow)
      time = "Night"
    elsif PBDayNight.isEvening?(timenow)
      time = "Eve"
    end
    time = "" if !pbResolveBitmap(sprintf("Graphics/Battlebacks/battlebg" + backdrop + time))
    battlebg = "Graphics/Battlebacks/battlebg" + backdrop + time
    enemybase = "Graphics/Battlebacks/enemybase" + backdrop + base + time
    playerbase = "Graphics/Battlebacks/playerbase" + backdrop + base + time
    enemybase = "Graphics/Battlebacks/enemybaseDummy" if !pbResolveBitmap(sprintf(enemybase))
    playerbase = "Graphics/Battlebacks/playerbaseDummy" if !pbResolveBitmap(sprintf(playerbase))
    pbAddPlane("battlebg", battlebg, @viewport)
    pbAddSprite(
      "playerbase",
      PBScene::PLAYERBASEX,
      PBScene::PLAYERBASEY, playerbase, @viewport
    )
    @sprites["playerbase"].x -= @sprites["playerbase"].bitmap.width / 2 if @sprites["playerbase"].bitmap != nil
    @sprites["playerbase"].y -= @sprites["playerbase"].bitmap.height if @sprites["playerbase"].bitmap != nil
    pbAddSprite(
      "enemybase",
      PBScene::FOEBASEX,
      PBScene::FOEBASEY, enemybase, @viewport
    )
    @sprites["enemybase"].x -= @sprites["enemybase"].bitmap.width / 2 if @sprites["enemybase"].bitmap != nil
    @sprites["enemybase"].y -= @sprites["enemybase"].bitmap.height / 2 if @sprites["enemybase"].bitmap != nil
    @sprites["battlebg"].z = 0
    @sprites["playerbase"].z = 2
    @sprites["enemybase"].z = 1
  end


  def pbEndBattle(result)
    pbShowWindow(BLANK)
    # Fade out all sprites
    pbBGMFade(1.0) if $game_switches[1404] == false # don't stop the music switch
    pbFadeOutAndHide(@sprites)
    pbDisposeSprites
  end

  alias __rejuv_pbFightMenu pbFightMenu unless method_defined?(:__rejuv_pbFightMenu)
  def pbFightMenu(index)
    v = __rejuv_pbFightMenu(index)
    @battle.specialchoices[index] = [nil] if v < 0
    return v
  end

  def pbFindAnimation(move, userIndex, hitnum)
    begin
      noflip = false
      if (userIndex & 1) == 0 # On player's side
        anim = $cache.move2anim[0].fetch(move.intern)
      else # On opposing side
        anim = $cache.move2anim[1].fetch(move.intern) if $cache.move2anim[1].key?(move.intern)
        noflip = true if anim
        anim = $cache.move2anim[0].fetch(move.intern) if !anim
      end
      return [anim + hitnum, noflip] if move == (:BONEMERANG || :THUNDERRAID)
      return [anim, noflip] if anim

      anim = $cache.move2anim[0].fetch(:TACKLE)
      return [anim, false] if anim
    rescue
      return nil
    end
    return nil
  end
end

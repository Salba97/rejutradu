#===============================================================================
# Pokédex main screen
#===============================================================================
class Window_Pokedex < Window_DrawableCommand
  def initialize(x, y, width, height, scene)
    @pokeballOwned = AnimatedBitmap.new("Graphics/Pictures/Pokedex/pokedexOwned")
    @pokeballSeen = AnimatedBitmap.new("Graphics/Pictures/Pokedex/pokedexSeen")
    @commands = []
    super(x, y, width, height)
    self.windowskin = nil
    self.baseColor, self.shadowColor = *LightColorArrays[:Default]
    @scene = scene
  end

  def getCursorGraphic
    return "Graphics/Pictures/Pokedex/pokedexSel"
  end

  def commands=(value)
    @commands = value
    refresh
  end

  def dispose
    @pokeballOwned.dispose
    @pokeballSeen.dispose
    super
  end

  def num
    return @commands.length == 0 ? 0 : @commands[self.index][5]
  end

  def species
    return @commands.length == 0 ? :BULBASAUR : @commands[self.index][0]
  end

  def form
    return @commands.length == 0 ? 0 : @commands[self.index][-1]
  end

  def gender
    return @commands.length == 0 ? nil : @commands[self.index][-2]
  end

  def itemCount
    return @commands.length
  end

  def drawItem(index, count, rect)
    return if index >= self.top_row + self.page_item_max

    rect = drawCursor(index, rect)
    num = @commands[index][5]
    species = @commands[index][0]
    form = @commands[index][-1]
    text = getSpeciesNumWithZeroes(num) + "  "
    # Seen/Owned icon before species number and name should be based only on species (and not on form) for national dex, to match the displayed total seen/owned counts
    consider_only_species = $PokemonGlobal.pokedexIndex == 0 && !@scene.searchResults
    if $Trainer.pokedex.seen?(species, form) || (consider_only_species && $Trainer.pokedex.seen?(species))
      owned = $Trainer.pokedex.owned?(species, form) || (consider_only_species && $Trainer.pokedex.owned?(species))
      pbCopyBitmap(self.contents, (owned ? @pokeballOwned : @pokeballSeen).bitmap, rect.x - 6, rect.y + 8)
      text += @commands[index][1]
    else
      text += "----------"
    end
    pbDrawShadowText(self.contents, rect.x + 30, rect.y + 6, rect.width, rect.height, text, self.baseColor, self.shadowColor)
    drawCursor(index - 1, itemRect(index - 1))
  end
end

class Window_ComplexCommandPokemon < Window_DrawableCommand
  attr_reader :commands

  def initialize(commands, width = nil)
    @starting = true
    @commands = commands
    dims = []
    getAutoDims(commands, dims, width)
    super(0, 0, dims[0], dims[1])
    @starting = false
  end

  def getCursorGraphic
    return "Graphics/Pictures/selarrowwhite"
  end

  def self.newEmpty(x, y, width, height, viewport = nil)
    ret = self.new([], width)
    ret.x = x
    ret.y = y
    ret.width = width
    ret.height = height
    ret.viewport = viewport
    return ret
  end

  def index=(value)
    super
    refresh if !@starting
  end

  def indexToCommand(index)
    curindex = 0
    i = 0; loop do
      break unless i < @commands.length
      return [i / 2, -1] if index == curindex

      curindex += 1
      return [i / 2, index - curindex] if index - curindex < commands[i + 1].length

      curindex += commands[i + 1].length
      i += 2
    end
    return [-1, -1]
  end

  def getText(array, index)
    cmd = indexToCommand(index)
    return "" if cmd[0] == -1
    return array[cmd[0] * 2] if cmd[1] < 0

    return array[cmd[0] * 2 + 1][cmd[1]]
  end

  def commands=(value)
    @commands = value
    @item_max = commands.length
    self.index = self.index
  end

  def width=(value)
    super
    if !@starting
      self.index = self.index
    end
  end

  def height=(value)
    super
    if !@starting
      self.index = self.index
    end
  end

  def resizeToFit(commands)
    dims = []
    getAutoDims(commands, dims)
    self.width = dims[0]
    self.height = dims[1]
  end

  def itemCount
    mx = 0
    i = 0; loop do
      break unless i < @commands.length

      mx += 1 + @commands[i + 1].length
      i += 2
    end
    return mx
  end

  def drawItem(index, count, rect)
    command = indexToCommand(index)
    return if command[0] < 0

    text = getText(@commands, index)
    rect = drawCursor(index, rect) if command[1] >= 0
    xoffset = command[1] >= 0 ? 0 : 34
    formattedText = getFormattedText(self.contents, rect.x + xoffset, rect.y, rect.width, rect.height, shadowc3tag(self.baseColor, self.shadowColor) + text)
    drawFormattedChars(self.contents, formattedText)
  end
end

class PokemonPokedexScene
  attr_reader :searchResults

  DEXNAME_Y = -18
  DEX_ENTRY_OFFSET = [42, 240, Graphics.width - (42 * 2)]

  POKEDEX_COORDS_DIMENSIONS = [214, 18, 268, 332]
  SEARCH_COORDS_DIMENSIONS = [-8, 32, 284, 352]

  SearchColor1 = ColorTags[:Gray2]
  SearchColor2 = ColorTags[:Blue2]

  def initialize(quick = false)
    @searchResults = false
    @shinyResults = false
    @quickPokedexScene = quick
  end

  def pbUpdate(sprites)
    pbUpdateSpriteHash(sprites)
  end

  # Gets the current region or the last viewed Pokedex.
  def pbGetPokedexRegion
    if DEXDEPENDSONLOCATION
      region = pbGetCurrentRegion
      return region
    else
      return $PokemonGlobal.pokedexIndex
    end
  end

  # Determines the most recent valid Pokedex Region. In the case of the Pokedex having been locked after last being viewed,
  # it will default to the first unlocked dex, usually the National Dex.
  def pbGetSavePositionIndex
    index = pbGetPokedexRegion
    if !$PokemonGlobal.pokedexData[index][:unlocked]
      index = $PokemonGlobal.pokedexData.find { |region, data| data[:unlocked] == true }[0]
    end
    return index
  end

  # Regional dex related methods
  WINDOWSKINOFFSET_X = 18
  WINDOWSKINOFFSET_Y = 23
  ADVTEXTOFFSET = 36

  PROGRESSBAR_WIDTH = 188
  PROGRESSBAR_HEIGHT = 8

  def pbStartRegionScene
    @activeScene = :region

    # setup dex list
    @list = {}
    @regionMenuIndex = pbGetSavePositionIndex
    dexnames = pbDexNames
    $PokemonGlobal.pokedexData.each { |index, data|
      next if !data[:unlocked]
      name = dexnames[index]
      seen = $Trainer.pokedex.getSeenCount(index).to_s
      owned = $Trainer.pokedex.getOwnedCount(index).to_s
      graphic = data[:symbol].to_s
      graphic += "Neo" if Reborn && [1, 3].include?(index) && $game_switches[:Reborn_City_Restore] # Post Restoration graphic change
      @list.store(index, {
        :name => "#{name}",
        :seen => seen,
        :owned => owned,
        :total => pbGetDexList(index).length,
        :graphic => graphic
      })
    }
    totalLength = -1
    @list.each { |k ,v|
      len = v[:total].to_s.length
      totalLength = len if len > totalLength
    }

    # set up sprites
    @regionSprites = {}
    @regionViewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @regionViewport.z = 99999
    @regionSprites["background"] = IconSprite.new(0, 0, @regionViewport)
    @regionSprites["background"].setBitmap("Graphics/Pictures/Pokedex/RegionalBackgrounds/pokedexMenu" + regionHash[:graphic])
    @regionSprites["backgroundOverlay"] = IconSprite.new(0, 0, @regionViewport)
    @regionSprites["backgroundOverlay"].setBitmap("Graphics/Pictures/Pokedex/pokedexMenuOverlay")

    @regionSprites["name"] = Window_AdvancedTextPokemon.newWithSize(stylize(regionHash[:name]), 96, 252 - WINDOWSKINOFFSET_Y, 316, 64, @regionViewport)
    @regionSprites["name"].windowskin = nil

    @regionSprites["seenProgress"] = IconSprite.new(PROGRESSBAR_WIDTH, PROGRESSBAR_HEIGHT, @regionViewport)
    @regionSprites["seenProgress"].x = 162
    @regionSprites["seenProgress"].y = 280
    seenProgressBmp = BitmapWrapper.new(PROGRESSBAR_WIDTH, PROGRESSBAR_HEIGHT, @regionViewport)
    rect = seenProgressBmp.rect
    seenProgressBmp.fill_rect(rect, Color.new(115, 119, 120))
    seenWidth = (regionHash[:seen].to_f / (regionHash[:total] - 1).to_f * PROGRESSBAR_WIDTH).to_i
    @regionSprites["seenProgress"].bitmap = seenProgressBmp
    @regionSprites["seenProgress"].src_rect.width = seenWidth

    @regionSprites["ownedProgress"] = IconSprite.new(PROGRESSBAR_WIDTH, PROGRESSBAR_HEIGHT, @regionViewport)
    @regionSprites["ownedProgress"].x = 162
    @regionSprites["ownedProgress"].y = 280
    ownedProgressBmp = BitmapWrapper.new(PROGRESSBAR_WIDTH, PROGRESSBAR_HEIGHT, @regionViewport)
    rect = ownedProgressBmp.rect
    ownedProgressBmp.fill_rect(rect, Color.new(51, 153, 255))
    ownedWidth = (regionHash[:owned].to_f / (regionHash[:total] - 1).to_f * PROGRESSBAR_WIDTH).to_i
    @regionSprites["ownedProgress"].bitmap = ownedProgressBmp
    @regionSprites["ownedProgress"].src_rect.width = ownedWidth

    ownedWidth = 12 * totalLength + ADVTEXTOFFSET
    ownedX = 162 - ownedWidth + 10
    @regionSprites["owned"] = Window_AdvancedTextPokemon.newWithSize(stylize(regionHash[:owned]), ownedX, 274 - WINDOWSKINOFFSET_Y, ownedWidth, 64, @regionViewport)
    @regionSprites["owned"].windowskin = nil

    totalWidth = 12 * totalLength + ADVTEXTOFFSET
    totalX = 162 + PROGRESSBAR_WIDTH - 14
    @regionSprites["total"] = Window_AdvancedTextPokemon.newWithSize(stylize(regionHash[:total]), totalX, 274 - WINDOWSKINOFFSET_Y, totalWidth, 64, @regionViewport)
    @regionSprites["total"].windowskin = nil
    pbFadeInAndShow(@regionSprites)
  end

  # Stylizes strings for display in the Region Selection Scene so they are centered and white.
  def stylize(string)
    return "<ac><c2=7FFF2d49>#{string}</c2></ac>"
  end

  # Shorthand for getting the list entry of the current index
  def regionHash
    @list[@regionMenuIndex]
  end

  def pbRegionMenu
    indexChanged = false
    loop do
      Graphics.update
      Input.update
      pbUpdate(@regionSprites)

      if Input.trigger?(Input::LEFT)
        indexChanged = true
        @regionMenuIndex -= 1
        @regionMenuIndex = @list.keys[-1] if @regionMenuIndex < @list.keys[0]
      end
      if Input.trigger?(Input::RIGHT)
        indexChanged = true
        @regionMenuIndex += 1
        @regionMenuIndex = @list.keys[0] if @regionMenuIndex > @list.keys[-1]
      end
      if Input.trigger?(Input::C)
        pbEndRegionScene
        pbStartPokedexScene
        pbPokedexMenu
        break
      end
      if Input.trigger?(Input::B)
        break
      end
      if indexChanged
        indexChanged = false
        @regionSprites["background"].setBitmap("Graphics/Pictures/Pokedex/RegionalBackgrounds/pokedexMenu" + regionHash[:graphic])
        @regionSprites["name"].text = stylize(regionHash[:name])
        @regionSprites["total"].text = stylize(regionHash[:total])
        @regionSprites["owned"].text = stylize(regionHash[:owned])
        seenWidth = (regionHash[:seen].to_f / (regionHash[:total] - 1).to_f * PROGRESSBAR_WIDTH).to_i
        @regionSprites["seenProgress"].src_rect.width = seenWidth
        ownedWidth = (regionHash[:owned].to_f / (regionHash[:total] - 1).to_f * PROGRESSBAR_WIDTH).to_i
        @regionSprites["ownedProgress"].src_rect.width = ownedWidth
        $PokemonGlobal.pokedexIndex = @regionMenuIndex
      end
    end
  end

  def pbEndRegionScene
    pbFadeOutAndHide(@regionSprites)
    pbDisposeSpriteHash(@regionSprites)
    @regionViewport.dispose
  end

  # Main pokedex scene related methods
  def pbStartPokedexScene(index = nil)
    @activeScene = :pokedex
    @pokedexSprites = {}
    @pokedexViewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @pokedexViewport.z = 99999
    @pokedexSprites["pokedex"] = Window_Pokedex.new(*POKEDEX_COORDS_DIMENSIONS, self)
    @pokedexSprites["pokedex"].viewport = @pokedexViewport
    @pokedexSprites["dexentry"] = IconSprite.new(0, 0, @pokedexViewport)
    @pokedexSprites["dexentry"].setBitmap("Graphics/Pictures/Pokedex/pokedexEntry")
    @pokedexSprites["dexentry"].visible = false
    @pokedexSprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @pokedexViewport)
    pbSetSystemFont(@pokedexSprites["overlay"].bitmap)
    @pokedexSprites["overlay"].x = 0
    @pokedexSprites["overlay"].y = 0
    @pokedexSprites["overlay"].visible = false

    @pokedexSprites["searchtitle"] = Window_AdvancedTextPokemon.newWithSize("", 2, DEXNAME_Y, Graphics.width, 64, @pokedexViewport)
    @pokedexSprites["searchtitle"].windowskin = nil
    @pokedexSprites["searchtitle"].visible = false
    @pokedexSprites["searchlist"] = Window_ComplexCommandPokemon.newEmpty(*SEARCH_COORDS_DIMENSIONS, @pokedexViewport)
    @pokedexSprites["searchlist"].visible = false
    @pokedexSprites["auxlist"] = Window_CommandPokemonWhiteArrow.newEmpty(250, 32, 284, 224, @pokedexViewport, tts: false)
    @pokedexSprites["auxlist"].visible = false
    @pokedexSprites["messagebox"] = Window_UnformattedTextPokemon.newWithSize("", 254, 256, 264, 128, @pokedexViewport)
    @pokedexSprites["messagebox"].visible = false
    @pokedexSprites["messagebox"].letterbyletter = false
    @pokedexSprites["dexname"] = Window_AdvancedTextPokemon.newWithSize("", 2, DEXNAME_Y, Graphics.width, 64, @pokedexViewport)
    @pokedexSprites["dexname"].windowskin = nil
    setDarkWindowFontColors
    @pokedexSprites["searchtitle"].text = _ISPRINTF("<ac>Search Mode</ac>")

    @pokedexSprites["species"] = Window_AdvancedTextPokemon.newWithSize("", 30, 22, 172, 64, @pokedexViewport)
    @pokedexSprites["species"].windowskin = nil
    @pokedexSprites["seen"] = Window_AdvancedTextPokemon.newWithSize("", 30, 242, 172, 64, @pokedexViewport)
    @pokedexSprites["seen"].windowskin = nil
    @pokedexSprites["owned"] = Window_AdvancedTextPokemon.newWithSize("", 30, 282, 172, 64, @pokedexViewport)
    @pokedexSprites["owned"].windowskin = nil
    setLightWindowFontColors

    addBackgroundPlane(@pokedexSprites, "searchbg", "Pokedex/pokedexSearchbg", @pokedexViewport)
    @pokedexSprites["searchbg"].visible = false

    # Suggestion for changing the background depending on region.  You
    # can change the line below with the following:
    #if pbGetPokedexRegion==-1 # Using national Pokédex
    #  addBackgroundPlane(@pokedexSprites,"background","pokedexbg_national",@pokedexViewport)
    #elsif pbGetPokedexRegion==0 # Using first regional Pokédex
    #  addBackgroundPlane(@pokedexSprites,"background","pokedexbg_regional",@pokedexViewport)
    #end

    addBackgroundPlane(@pokedexSprites, "background", "Pokedex/pokedexbg", @pokedexViewport)
    addBackgroundPlane(@pokedexSprites, "backgroundOverlay", "Pokedex/pokedexbgOverlay", @pokedexViewport) if pbViablePokedexes.length > 1
    @pokedexSprites["slider"] = IconSprite.new(Graphics.width - 44, 62, @pokedexViewport)
    @pokedexSprites["slider"].setBitmap(sprintf("Graphics/Pictures/Pokedex/pokedexSlider"))
    @pokedexSprites["icon"] = IconSprite.new(116, 164, @pokedexViewport)

    returning = !index.nil? # index is passed when returning from a pokemon's page to the main pokedex menu
    @dexlist = pbGetDexListSorted(nil) unless returning # dexlist should not be created again when returning
    pbRefreshMainMenu(index, true, returning: returning)

    pbDeactivateWindows(@pokedexSprites)
    pbFadeInAndShow(@pokedexSprites)
  end

  def setDarkWindowFontColors
    windows = ["dexname", "searchtitle", "searchlist", "auxlist", "messagebox"]
    windows.each { |w|
      @pokedexSprites[w].baseColor, @pokedexSprites[w].shadowColor = *ColorArrays[:Default]
    }
  end

  def setLightWindowFontColors
    windows = ["species", "seen", "owned"]
    windows.each { |w|
      @pokedexSprites[w].baseColor, @pokedexSprites[w].shadowColor = *LightColorArrays[:Default]
    }
  end

  def seen?(species, form)
    return $Trainer.pokedex.seen?(species, form)
  end

  def owned?(species, form)
    return Rejuv ? $Trainer.pokedex.meaningful_owned?(species, form) : $Trainer.pokedex.owned?(species, form)
  end

  def pbRefreshMainMenu(index, fullrefresh, returning: false, interrupt: true)
    unless index == false # index is passed as false by the main menu control loop
      @pokedexSprites["pokedex"].commands = @dexlist
      index = $PokemonGlobal.pokedexData[pbGetSavePositionIndex][:lastIndex] if index.nil?
      index = 0 if index > @dexlist.length - 1
      @pokedexSprites["pokedex"].index = index
    end
    @pokedexSprites["pokedex"].refresh

    if fullrefresh
      if @searchResults
        headertext = _INTL("Search Results - {1}", @pokedexSprites["pokedex"].itemCount)
        seenno = @dexlist.count { |array| seen?(array[0], array[-1]) }
        ownedno = @dexlist.count { |array| owned?(array[0], array[-1]) }
      else
        headertext = _INTL("Pokédex")
        if pbViablePokedexes.length > 1
          thisdex = pbDexNames[pbGetSavePositionIndex]
          headertext = thisdex.is_a?(Array) ? thisdex[0] : thisdex if thisdex
        end
        seenno = $Trainer.pokedex.getSeenCount(pbGetSavePositionIndex)
        ownedno = $Trainer.pokedex.getOwnedCount(pbGetSavePositionIndex)
      end
      @pokedexSprites["dexname"].text = "<ac>" + headertext + "</ac>"
      tts(headertext, interrupt) unless returning

      seentext = _ISPRINTF("Seen:<r>{1:d}", seenno)
      ownedtext = _ISPRINTF("Owned:<r>{1:d}", ownedno)
      @pokedexSprites["seen"].text = seentext
      @pokedexSprites["owned"].text = ownedtext
      ttstext = toUnformattedText(seentext + ", " + ownedtext)
      tts(ttstext) unless returning
    end

    ycoord = 62
    if @pokedexSprites["pokedex"].itemCount > 1
      ycoord += 188.0 * @pokedexSprites["pokedex"].index / (@pokedexSprites["pokedex"].itemCount - 1)
    end
    @pokedexSprites["slider"].y = ycoord

    num = @pokedexSprites["pokedex"].num
    species = @pokedexSprites["pokedex"].species
    form = @pokedexSprites["pokedex"].form
    gender = @pokedexSprites["pokedex"].gender

    if !seen?(species, form)
      @pokedexSprites["icon"].bitmap = nil
      @pokedexSprites["species"].text = _ISPRINTF("")
    else
      gender ||= $Trainer.pokedex[species].lastSeen[:gender]
      shiny = $Trainer.pokedex[species].lastSeen[:shiny] || @shinyResults
      shadow = $Trainer.pokedex[species].lastSeen[:shadow]
      monbitmap = pbPokemonBitmap(species, shiny, false, gender, form, shadow)
      monbitmap = croppedBitmap(species, form, monbitmap)
      @pokedexSprites["icon"].bitmap = monbitmap
      @pokedexSprites["icon"].ox = @pokedexSprites["icon"].bitmap.width / 2
      @pokedexSprites["icon"].oy = @pokedexSprites["icon"].bitmap.height / 2
      @pokedexSprites["species"].text = _ISPRINTF("<ac>{1:s}</ac>", getMonName(species, form))
    end

    ttsCurrentItem(interrupt && (!fullrefresh || returning)) # do an interrupt here if it wasn't already done, because of headertext not being spoken
  end

  def ttsCurrentItem(interrupt = true)
    num = @pokedexSprites["pokedex"].num
    species = @pokedexSprites["pokedex"].species
    form = @pokedexSprites["pokedex"].form

    name = seen?(species, form) ? getMonName(species, form) : _INTL("Unknown")
    tts(num.to_s + ": " + name, interrupt)
  end

  def pbGetDexListSorted(mode)
    dexlist = @searchResults ? @dexlist : pbGetDexList() # No need to create dexlist again if looking at search results
    mode = getSortMode() if mode.nil?

    pbSortDexList(dexlist, mode)

    case mode
      when 0 # Numerical
        # Trim dexlist from bottom to show entries only up until the last seen one
        i = dexlist.length - 1
        loop do
          break if i < 0
          break if seen?(dexlist[i][0], dexlist[i][-1])

          dexlist[i] = nil
          i -= 1
        end
        dexlist.compact!
      when 1 # Alphabetical
        dexlist.filter! { |array| seen?(array[0], array[-1]) }
      else # All other modes
        dexlist.filter! { |array| owned?(array[0], array[-1]) }
    end

    return dexlist
  end

  def pbSortDexList(dexlist, mode)
    # Items are always sorted secondarily by dex num (5) and tertiarily by form num (-1)
    case mode
      when 0 # Numerical (regional dex num for regional dexes, otherwise national dex num)
        dexlist.sort_by! { |a| [a[5], a[-1]] }
      when 1 # Alphabetical
        dexlist.sort_by! { |a| [a[1], a[5], a[-1]] }
      when 2 # Weight (lightest to heaviest)
        dexlist.sort_by! { |a| [a[3], a[5], a[-1]] }
      when 3 # Height (smallest to largest)
        dexlist.sort_by! { |a| [a[2], a[5], a[-1]] }
      when 4, 5, 6, 7, 8, 9 # By base HP/Atk/Def/SpA/SpD/Spd
        dexlist.sort_by! { |a| [a[4][mode - 4], a[5], a[-1]] }
      when 10 # By base stat total
        dexlist.sort_by! { |a| [a[4].sum, a[5], a[-1]] }
    end
  end

  def getSortMode
    return $PokemonGlobal.pokedexMode[$PokemonGlobal.pokedexIndex] || 0
  end

  def setSortMode(mode)
    $PokemonGlobal.pokedexMode[$PokemonGlobal.pokedexIndex] = mode
  end

  def pbUpdateLastIndex(index)
    return if @searchResults
    $PokemonGlobal.pokedexData[pbGetSavePositionIndex][:lastIndex] = index
  end

  def pbPokedexMenu
    pbActivateWindow(@pokedexSprites, "pokedex") {
      loop do
        Graphics.update
        Input.update
        oldindex = @pokedexSprites["pokedex"].index
        pbUpdate(@pokedexSprites)
        newindex = @pokedexSprites["pokedex"].index
        if oldindex != newindex
          pbUpdateLastIndex(newindex)
          pbRefreshMainMenu(false, false)
        end
        if Input.trigger?(Input::B)
          if @searchResults
            pbPlayCancelSE()
            pbCloseSearch
          else
            break
          end
        elsif Input.trigger?(Input::C)
          if seen?(@pokedexSprites["pokedex"].species, @pokedexSprites["pokedex"].form)
            pbPlayDecisionSE()
            pbEndPokedexScene
            # go to dex entry scene
            pbStartDexEntryScene(@dexlist[newindex][0], @dexlist[newindex][-1], @dexlist[newindex][-2])
            i = pbDexEntry(newindex, @dexlist)
            pbUpdateLastIndex(i)
            # go back to pokedex scene
            pbStartPokedexScene(i)
            pbPokedexMenu
            break
          end
        elsif Input.trigger?(Input::Z) && pbViablePokedexes.length > 1
          pbPlayDecisionSE()
          pbEndPokedexScene
          pbStartRegionScene
          pbRegionMenu
          break
        elsif Input.trigger?(Input::A)
          pbPlayDecisionSE()
          pbDexSearch
        elsif Input.trigger?(Input::X) && !@searchResults
          pbExecuteSort(1, shortcut: true) # Alphabetical sort
        elsif Input.trigger?(Input::Y) && !@searchResults
          pbExecuteSort(0, shortcut: true) # Numerical sort
        elsif Input.triggerex?(Input::F2)
          ttsSortControls(:name, :number) # TTS sort controls
        end
      end
    }
  end

  def getSearchCategories
    dexlist = pbGetDexList(search: true)
    dexlist.filter! { |array| seen?(array[0], array[-1]) }
    allCategories = [:Alola, :Galar, :Hisui, :Paldea, :Aevium, :Mega, :Baby, :Starter, :Fossil, :PseudoL, :Legendary, :UBeast, :Paradox, :Evolvable, :FinalStage, :Shiny]
    shownCategories = []
    for cat in allCategories
      shownCategories.push(cat) if dexlist.any? { |array| checkSearchCategoryCondition(cat, array[0], array[-1]) }
    end
    return shownCategories
  end

  def getSearchCategoryName(type, short = false)
    return case type
      when :Alola then short ? _INTL("Alolan") : _INTL("Alolan Forms")
      when :Galar then short ? _INTL("Galarian") : _INTL("Galarian Forms")
      when :Hisui then short ? _INTL("Hisuian") : _INTL("Hisuian Forms")
      when :Paldea then short ? _INTL("Paldean") : _INTL("Paldean Forms")
      when :Aevium then short ? _INTL("Aevian") : _INTL("Aevian Forms")
      when :Mega then short ? _INTL("Mega") : _INTL("Mega Evolutions")
      when :Baby then short ? _INTL("Baby") : _INTL("Baby Pokémon")
      when :Starter then short ? _INTL("Starter") : _INTL("Starter Pokémon")
      when :Fossil then short ? _INTL("Fossil") : _INTL("Fossil Pokémon")
      when :PseudoL then short ? _INTL("Pseudo.") : _INTL("Pseudo-Legendaries")
      when :Legendary then short ? _INTL("Legendary") : _INTL("Legendary Pokémon")
      when :UBeast then short ? _INTL("Ultra Beast") : _INTL("Ultra Beasts")
      when :Paradox then short ? _INTL("Paradox") : _INTL("Paradox Pokémon")
      when :Evolvable then short ? _INTL("Evolvable") : _INTL("Evolvable Pokémon")
      when :FinalStage then short ? _INTL("Final Stage") : _INTL("Final Stage Pokémon")
      when :Shiny then short ? _INTL("Shiny") : _INTL("Shiny Variants")
    end
  end

  def checkSearchCategoryCondition(cat, species, form)
    return case cat
      when :Alola then $cache.pkmn[species].forms[form].include?(_INTL("Alolan"))
      when :Galar then $cache.pkmn[species].forms[form].include?(_INTL("Galarian"))
      when :Hisui then $cache.pkmn[species].forms[form].include?(_INTL("Hisuian"))
      when :Paldea then $cache.pkmn[species].forms[form].include?(_INTL("Paldean"))
      when :Aevium then $cache.pkmn[species].forms[form].include?(_INTL("Aevian"))
      when :Mega then [:Mega, :Primal, :Ultra, :Terastal].any? { |i| $cache.pkmn[species, form].checkFlag?(i) }
      when :Baby
        $cache.pkmn[species, form].EggGroups.include?(:Undiscovered) &&
        pbGetEvolvedFormData(species, form)&.any? { |hash|
          !$cache.pkmn[hash[:species], hash[:form] || form].EggGroups.include?(:Undiscovered)
        }
      when :Starter, :Fossil, :PseudoL
        list = { Starter: PBStuff::STARTERPOKEMON, Fossil: PBStuff::FOSSILPOKEMON, PseudoL: PBStuff::PSEUDOLEGENDARIES }[cat]
        list.include?(species) || list.include?(pbGetBabySpecies(species, form)[0])
      when :Legendary then PBStuff::LEGENDARYLIST.include?(species)
      when :UBeast then PBStuff::ULTRABEASTS.include?(species)
      when :Paradox then PBStuff::PARADOXLIST.include?(species)
      when :Evolvable then !pbGetEvolvedFormData(species, form).nil? # Eviolite condition
      when :FinalStage then pbGetEvolvedFormData(species, form).nil? && [:Mega, :Primal, :Ultra, :Terastal].none? { |i| $cache.pkmn[species, form].checkFlag?(i) }
      when :Shiny then $Trainer.pokedex.seen?(species, form, nil, true, false)
      else false
    end
  end

  def pbDexSearch
    oldsprites = pbFadeOutAndHide(@pokedexSprites)
    params = []
    params[0] = nil # Name
    params[1] = nil # Type
    params[2] = nil # Category
    params[3] = { move: nil, ability: nil, item: nil, egggroup: nil, color: nil } # Advanced options
    params[3][:shape] = nil if Reborn # Only Reborn has shapes rn
    params[4] = getSortMode() # Sort mode for Search
    params[5] = getSortMode() # Sort mode in general

    @orderCommands = [
      _INTL("Numerical"),
      _INTL("Alphabetical"),
      _INTL("Weight"),
      _INTL("Height"),
    ]
    (0..5).each { |stat| @orderCommands.push(_INTL("Base {1}", getStatName(stat))) }
    @orderCommands.push(_INTL("Base Stat Total"))

    @orderHelp = [
      _INTL("All Pokémon are listed by Pokédex number.\n(Shortcut Key: S)"),
      _INTL("Spotted Pokémon are listed alphabetically.\n(Shortcut Key: A)"),
      _INTL("Owned Pokémon are listed from lightest to heaviest."),
      _INTL("Owned Pokémon are listed from smallest to largest."),
    ]
    (0..5).each { |stat| @orderHelp.push(_INTL("Owned Pokémon are listed in order of their base {1} stat.", getStatName(stat))) }
    @orderHelp.push(_INTL("Owned Pokémon are listed in order of their base stat total."))

    @pokedexSprites["searchlist"].index = 1
    searchlist = @pokedexSprites["searchlist"]
    @pokedexSprites["messagebox"].visible = true
    @pokedexSprites["auxlist"].visible = true
    @pokedexSprites["searchlist"].visible = true
    @pokedexSprites["searchbg"].visible = true
    @pokedexSprites["searchtitle"].visible = true
    tts(_INTL("Search Menu"), true)
    pbRefreshDexSearch(params, false)
    pbFadeInAndShow(@pokedexSprites)
    pbActivateWindow(@pokedexSprites, "searchlist") {
      loop do
        Graphics.update
        Input.update
        oldindex = searchlist.index
        pbUpdate(@pokedexSprites)
        if searchlist.index == 0
          if oldindex == 9 && Input.trigger?(Input::DOWN)
            searchlist.index = 1
          elsif oldindex == 1 && Input.trigger?(Input::UP)
            searchlist.index = 9
          else
            searchlist.index = 1
          end
        elsif searchlist.index == 7
          if oldindex == 8
            searchlist.index = 6
          else
            searchlist.index = 8
          end
        end
        if searchlist.index != oldindex
          pbRefreshDexSearch(params)
        end
        if Input.trigger?(Input::C)
          pbPlayDecisionSE()
          command = searchlist.indexToCommand(searchlist.index)
          if command == [2, 0]
            break
          end

          if command == [0, 0]
            input = Kernel.pbMessageFreeText(_INTL("Enter any part of the species name."), params[0] || "", 12) # Longest species name length is 12 (Crabominable)
            params[0] = input == "" ? nil : input
            pbRefreshDexSearch(params)
          elsif command == [0, 1]
            params[1] = pbEnterTypes(_INTL("Which types?"), params[1] || [])
            pbRefreshDexSearch(params)
          elsif command == [0, 2]
            @searchCategories = getSearchCategories unless @searchCategories # Saving to a variable for efficiency
            if @searchCategories.empty?
              Kernel.pbMessage(_INTL("No categories available.\nFind more Pokémon to unlock categories!"))
            else
              params[2] = pbAdvancedSearchInput(:category, params[2])
              pbRefreshDexSearch(params)
            end
          elsif command == [0, 3] && unlockedAdvDex?
            params[3] = pbDexSearchCommandsAdvanced(params[3])
            pbRefreshDexSearch(params)
          elsif command == [0, 4]
            params[4] = pbDexSearchCommands(@orderCommands, params[4], @orderHelp)
            pbRefreshDexSearch(params)
          elsif command == [0, 5]
            dexlist = pbSearchDexList(params)
            if dexlist.length == 0
              Kernel.pbMessage(_INTL("No matching Pokémon were found."))
              next
            end

            @searchResults = true
            @shinyResults = params[2] == :Shiny
            @dexlist = dexlist
            pbRefreshMainMenu(0, true)

            break
          elsif command == [1, 0]
            params[5] = pbDexSearchCommands(@orderCommands, params[5], @orderHelp)
            pbRefreshDexSearch(params)
          elsif command == [1, 1] && !@searchResults
            pbExecuteSort(params[5])
            break
          end
        elsif Input.trigger?(Input::B)
          pbPlayCancelSE()
          ttsCurrentItem
          break
        end
      end
    }
    pbFadeOutAndHide(@pokedexSprites)
    pbFadeInAndShow(@pokedexSprites, oldsprites)
  end

  def pbExecuteSort(mode, shortcut: false)
    return if getSortMode() == mode

    if shortcut
      pbPlayDecisionSE()
      tts(mode == 0 ? _INTL("Sorted by number") : _INTL("Sorted by name"), true)
    end

    setSortMode(mode)

    pbUpdateLastIndex(0)
    @dexlist = pbGetDexListSorted(mode)
    pbRefreshMainMenu(0, false, interrupt: !shortcut)
  end

  def pbSearchDexList(params)
    dexlist = pbGetDexList(search: true)
    adv = params[3] # shorthand
    ownedonly = adv.values.any? { |v| !v.nil? }

    # Filter
    dexlist.filter! { |array|
      species, form, gender = array[0], array[-1], array[-2]
      # Filter out all pokemon that aren't owned/seen
      next false unless (ownedonly ? owned?(species, form) : seen?(species, form))
      # Filter by name
      if !params[0].nil?
        speciesname = array[1]
        next false unless speciesname.downcase.include?(params[0].downcase)
      end
      cacheData = $cache.pkmn[species, form, gender]
      # Filter by type
      if !params[1].nil?
        stype1 = params[1][0]
        stype2 = params[1][1]
        type1 = cacheData.Type1
        type2 = cacheData.Type2
        if stype1.is_a?(Symbol) && stype2.is_a?(Symbol)
          # Find pokemon that match both types
          # Both search types being the same means finding pokemon with -only- that type
          next false unless (stype1 == stype2 && type1 == stype1 && type2.nil?) || (stype1 == type1 && stype2 == type2) || (stype1 == type2 && stype2 == type1)
        elsif stype1.is_a?(Symbol)
          # Find pokemon that match first type entered
          next false unless type1 == stype1 || type2 == stype1
        else
          # Find pokemon that match second type entered
          next false unless type1 == stype2 || type2 == stype2
        end
      end
      # Filter by category
      if !params[2].nil?
        next false unless checkSearchCategoryCondition(params[2], species, form)
      end
      # Filter by advanced pokedex data
      if adv[:move]
        moves = pbGetLearnableMovesForSpecies(species, form)
        next false unless moves.include?(adv[:move])
      end
      if adv[:ability]
        abilities = cacheData.getAbilities
        next false unless abilities.any? { |i| getAbilityName(i) == getAbilityName(adv[:ability]) }
        # There are abilities that are internally different but share names such as As One
        # Thus for abilities we match names rather than internal symbols
      end
      if adv[:item]
        items = cacheData.getWildItems.values
        next false unless items.include?(adv[:item])
      end
      if adv[:egggroup]
        egggroups = cacheData.EggGroups
        next false unless egggroups.include?(adv[:egggroup]) || (adv[:egggroup] == :Ditto && egggroups == [])
      end
      if adv[:color]
        color = cacheData.Color
        next false unless color == adv[:color]
      end
      if adv[:shape]
        shape = cacheData.shape
        next false unless shape == adv[:shape]
      end
      next true
    }

    # Sort
    pbSortDexList(dexlist, params[4])

    return dexlist
  end

  def pbDexSearchCommands(commands, selitem, helptexts = nil, advancedoptions = false)
    ret = -1
    auxlist = @pokedexSprites["auxlist"]
    messagebox = @pokedexSprites["messagebox"]
    auxlist.commands = commands
    auxlist.index = selitem
    oldindex = nil
    pbActivateWindow(@pokedexSprites, "auxlist") {
      loop do
        Graphics.update
        Input.update
        pbUpdate(@pokedexSprites)

        if auxlist.index != oldindex
          tts(toUnformattedText(auxlist.commands[auxlist.index]), true)
          messagebox.text = helptexts ? helptexts[auxlist.index] : ""
          tts(messagebox.text)
        end
        oldindex = auxlist.index

        if Input.trigger?(Input::B)
          ret = advancedoptions ? -1 : selitem
          pbPlayCancelSE()
          break
        end
        if Input.trigger?(Input::C)
          ret = auxlist.index
          pbPlayDecisionSE()
          break
        end
      end
      auxlist.commands = []
    }
    Input.update
    return ret
  end

  def pbDexSearchCommandsAdvanced(optionhash)
    helptexts = optionhash.map { |option, value|
      next case option
        when :move then _INTL("Filter by move learnt.")
        when :ability then _INTL("Filter by ability.")
        when :item then _INTL("Filter by item held in the wild.")
        when :egggroup then _INTL("Filter by egg group.")
        when :color then _INTL("Filter by body color.")
        when :shape then _INTL("Filter by body shape.")
      end
    }

    dexlist = pbGetDexList(search: true) # Created outside of the loop for efficiency

    selindex = 0
    loop do
      commands = optionhash.map { |option, value|
        optionstr = case option
          when :move then _INTL("Move")
          when :ability then _INTL("Ability")
          when :item then _INTL("Item")
          when :egggroup then _INTL("Group")
          when :color then _INTL("Color")
          when :shape then _INTL("Shape")
        end
        valuestr = !value ? _INTL("None") : case option
          when :move then getMoveShortName(value)
          when :ability then getAbilityName(value, true)
          when :item then getItemName(value)
          when :egggroup then getEggGroupName(value)
          when :color then getPokemonColorName(value)
          when :shape then getPokemonShapeName(value)
        end
        next optionstr + ": " + (!value ? SearchColor1 : SearchColor2) + valuestr
      }

      selindex = pbDexSearchCommands(commands, selindex, helptexts, true)
      break if selindex == -1

      searchtype = optionhash.keys[selindex]
      optionhash[searchtype] = pbAdvancedSearchInput(searchtype, optionhash[searchtype], dexlist)
    end
    return optionhash
  end

  def pbAdvancedSearchInput(searchtype, curvalue, dexlist = nil)
    if [:move, :ability, :item].include?(searchtype)
      allOptions = []
      dexlist.each { |array|
        species, form, gender = array[0], array[-1], array[-2]
        next if !owned?(species, form)

        newOptions = case searchtype
          when :move then pbGetLearnableMovesForSpecies(species, form)
          when :ability then $cache.pkmn[species, form, gender].getAbilities
          when :item then $cache.pkmn[species, form, gender].getWildItems.values
        end
        allOptions |= newOptions
      }
      allOptions.uniq! { |i| getAbilityName(i) } if searchtype == :ability
      method = case searchtype
        when :move then :getMoveName
        when :ability then :getAbilityName
        when :item then :getItemName
      end
      if $Settings.useKeyboard? # Use bounded text entry
        msg = case searchtype
          when :move then _INTL("Name of the move?")
          when :ability then _INTL("Name of the ability?")
          when :item then _INTL("Name of the item?")
        end
        return pbEnterBoundedText(msg, allOptions, _INTL("No Pokémon found."), &method(method))
      else # Use long choice list (similar to debug lists)
        allOptionsDisplay = allOptions.map(&method(method))
        allOptions, allOptionsDisplay = allOptions.zip(allOptionsDisplay).sort_by{ |sym, str| str }.transpose # Sort both arrays according to values of latter
        ret = pbLongChoiceList(allOptionsDisplay, 0, 200)
        return ret >= 0 ? allOptions[ret] : nil
      end
    end

    if [:egggroup, :shape, :color, :category].include?(searchtype)
      allOptions = case searchtype
        when :egggroup then getAllEggGroups.keys
        when :color then getAllPokemonColors.keys
        when :shape then getAllPokemonShapes.keys
        when :category then @searchCategories.clone
      end
      allOptions.insert(0, nil)
      subcommands = allOptions.map { |i|
        next SearchColor1 + _INTL("None") if i.nil?
        next case searchtype
          when :egggroup then getEggGroupName(i)
          when :color then getPokemonColorName(i)
          when :shape then getPokemonShapeName(i)
          when :category then getSearchCategoryName(i)
        end
      }
      subselindex = allOptions.index(curvalue)
      subselindex = pbDexSearchCommands(subcommands, subselindex)
      return allOptions[subselindex]
    end

    return nil
  end

  def pbRefreshDexSearch(params, interrupt = true)
    searchlist = @pokedexSprites["searchlist"]
    messagebox = @pokedexSprites["messagebox"]
    namestr = params[0].nil? ? SearchColor1 + _INTL("None") : SearchColor2 + params[0]
    typestr = params[1].nil? ? SearchColor1 + _INTL("None") : typeIcons(*params[1])
    catstr = params[2].nil? ? SearchColor1 + _INTL("None") : SearchColor2 + getSearchCategoryName(params[2], true)
    advtag = !unlockedAdvDex? ? SearchColor1 : (params[3].values.any?{ |v| !v.nil? } ? SearchColor2 : "")
    orderCommandsShort = @orderCommands.clone
    orderCommandsShort[10] = _INTL("B. S. T.") # Base Stat Total doesn't fit
    searchlist.commands = [
      _INTL("Search"),
      [
        _ISPRINTF("Name: {1:s}", namestr),
        _ISPRINTF("Type: {1:s}", typestr),
        _ISPRINTF("Category: {1:s}", catstr),
        advtag + _ISPRINTF("Advanced Options"),
        _ISPRINTF("Order: {1:s}", SearchColor2 + orderCommandsShort[params[4]]),
        _INTL("Start Search")
      ],
      _INTL("Sort"),
      [
        _ISPRINTF("Order: {1:s}", SearchColor2 + orderCommandsShort[params[5]]),
        _INTL("Start Sort")
      ]
    ]
    helptexts = [
      _INTL("Search for Pokémon based on selected parameters."),
      [
        _INTL("Filter by any part of species name.\nSpotted Pokémon only."),
        _INTL("Filter by typing.\nSpotted Pokémon only."),
        _INTL("View a specific category of Pokémon.\nSpotted Pokémon only."),
        unlockedAdvDex? ?
          _INTL("Filter by Advanced Pokédex data.\nOwned Pokémon only.") :
          _INTL("Requires access to Advanced Pokédex."),
        _INTL("Select the Pokédex listing mode."),
        _INTL("Execute search."),
      ],
      _INTL("Switch Pokédex listings."),
      [
        _INTL("Select the Pokédex listing mode."),
        _INTL("Execute sort."),
      ]
    ]
    messagebox.text = searchlist.getText(helptexts, searchlist.index)
    if searchlist.index <= 6
      parameterstr = searchlist.commands[1][searchlist.index - 1]
      tts(toUnformattedText(parameterstr), interrupt)
      ttsTypeIconsInText(parameterstr)
      tts(helptexts[1][searchlist.index - 1]) if searchlist.index != 6
    else
      parameterstr = searchlist.commands[3][searchlist.index - 8]
      tts(toUnformattedText(parameterstr), interrupt)
      tts(helptexts[3][searchlist.index - 8]) if searchlist.index != 9
    end
  end

  def pbCloseSearch
    oldsprites = pbFadeOutAndHide(@pokedexSprites)

    @searchResults = false
    @shinyResults = false
    @dexlist = pbGetDexListSorted(nil)
    pbRefreshMainMenu(nil, true)

    pbFadeInAndShow(@pokedexSprites, oldsprites)
  end

  def pbEndPokedexScene
    pbFadeOutAndHide(@pokedexSprites)
    pbDisposeSpriteHash(@pokedexSprites)
    @pokedexViewport.dispose
  end

  # Leaving this in case it's needed, but now use `pbGetLanguage` as a better check for measurement system.
  #def pbGetCountry()
  #  getUserGeoID = Win32API.new("kernel32", "GetUserGeoID", "l", "i") rescue nil
  #  if getUserGeoID
  #    return getUserGeoID.call(16)
  #  end
  #  return 0
  #end

  # dex entry scene related methods
  def pbStartDexEntryScene(species, form, gender)
    @activeScene = :entry
    @dexEntrySprites = {}
    @dexEntryViewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @dexEntryViewport.z = 99999
    @dexEntrySprites["dexentry"] = IconSprite.new(0, 0, @dexEntryViewport)
    @dexEntrySprites["dexentry"].setBitmap("Graphics/Pictures/Pokedex/pokedexEntry")
    @dexEntrySprites["dexentry"].visible = false
    @dexEntrySprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @dexEntryViewport)
    pbSetSystemFont(@dexEntrySprites["overlay"].bitmap)
    @dexEntrySprites["overlay"].x = 0
    @dexEntrySprites["overlay"].y = 0
    @dexEntrySprites["overlay"].visible = false
    dummymon = $Trainer.pokedex.createDummyPokemon(species, form, gender)
    pbChangeToDexEntry(dummymon)
    #pbDrawImagePositions(@dexEntrySprites["overlay"].bitmap, [["Graphics/Pictures/Pokedex/pokedexBlank", 0, 0, 0, 0, -1, -1]])
    pbFadeInAndShow(@dexEntrySprites)
  end

  def pbSingleDexEntry # remove this and play with battle registration
    pbActivateWindow(@dexEntrySprites, nil) {
      loop do
        Graphics.update
        Input.update
        if Input.trigger?(Input::B) || Input.trigger?(Input::C)
          break
        end
      end
    }
  end

  def pbChangeToDexEntry(dummymon)
    species, form, gender = dummymon.species, dummymon.form, dummymon.gender
    @dexEntrySprites["dexentry"].visible = true
    if !Reborn && $game_switches[:Advanced_Pokedex]
      @dexEntrySprites["dexbar"] = IconSprite.new(0, 0, @dexEntryViewport)
      @dexEntrySprites["dexbar"].setBitmap("Graphics/Pictures/Pokedex/advancedPokedexEntryBar")
    end
    @dexEntrySprites["overlay"].visible = true
    @dexEntrySprites["overlay"].bitmap.clear
    basecolor, shadowcolor = *LightColorArrays[:Default]
    species_offset_x = Rejuv ? 38 : 40
    kind_offset_x = Rejuv ? 70 : 74

    mondata = $game_switches[:Randomized_Challenge] && $Randomizer.randomTypes ? $rndcache.pkmn[species, form, gender] : $cache.pkmn[species, form, gender]
    speciesInt = getDisplayDexNum(mondata, $PokemonGlobal.pokedexIndex)
    speciesText = _ISPRINTF("{1:s}  {2:s}", getSpeciesNumWithZeroes(speciesInt), getMonName(species, form))

    textpos = [
      [speciesText, 244, species_offset_x, 0, *ColorArrays[:Default]],
      [sprintf(_INTL("HT")), 318, 158, 0, basecolor, shadowcolor],
      [sprintf(_INTL("WT")), 318, 190, 0, basecolor, shadowcolor]
    ]

    if owned?(species, form)
      kind = pbGetMessage(:Kinds, mondata.kind)
      height = mondata.Height
      weight = mondata.Weight
      inches = (height / 0.254).round
      pounds = (weight / 0.45359).round
      dexentry = pbGetMessage(:Entries, mondata.dexentry)
      textpos.push([_ISPRINTF("{1:s} Pokémon", kind), 244, kind_offset_x, 0, basecolor, shadowcolor])
      if pbGetLanguage() == "en_US" # If the user language is set to Egnlish (United States)
        textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 456, 158, 1, basecolor, shadowcolor])
        textpos.push([_ISPRINTF("{1:4.1f} lbs.", pounds / 10.0), 490, 190, 1, basecolor, shadowcolor])
      else
        textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 466, 158, 1, basecolor, shadowcolor])
        textpos.push([_ISPRINTF("{1:.1f} kg", weight / 10.0), 478, 190, 1, basecolor, shadowcolor])
      end
      dexentrycolors = Rejuv ? ColorArrays[:Default] : LightColorArrays[:Default]
      drawTextEx(@dexEntrySprites["overlay"].bitmap, *DEX_ENTRY_OFFSET, 4, dexentry, *dexentrycolors)

      if Desolation
        footprintfile = pbPokemonFootprintFile(mondata.dexnum)
        if footprintfile
          footprint = RPG::Cache.load_bitmap(footprintfile)
          @dexEntrySprites["overlay"].bitmap.blt(226, 136, footprint, footprint.rect)
          footprint.dispose
        end
      end

      pbDrawImagePositions(@dexEntrySprites["overlay"].bitmap, [["Graphics/Pictures/Pokedex/pokedexOwned", 212, species_offset_x + 2, 0, 0, -1, -1]])
    else
      textpos.push([_INTL("????? Pokémon"), 244, kind_offset_x, 0, basecolor, shadowcolor])
      if pbGetLanguage() == "en_US" # If the user language is set to Egnlish (United States)
        textpos.push([_INTL("???'??\""), 456, 158, 1, basecolor, shadowcolor])
        textpos.push([_INTL("????.? lbs."), 490, 190, 1, basecolor, shadowcolor])
      else
        textpos.push([_INTL("????.? m"), 466, 158, 1, basecolor, shadowcolor])
        textpos.push([_INTL("????.? kg"), 478, 190, 1, basecolor, shadowcolor])
      end
      pbDrawImagePositions(@dexEntrySprites["overlay"].bitmap, [["Graphics/Pictures/Pokedex/pokedexSeen", 212, species_offset_x + 2, 0, 0, -1, -1]]) if Rejuv
    end
    pbDrawTextPositions(@dexEntrySprites["overlay"].bitmap, textpos)

    pkmnbitmap = pbPokemonBitmap(species, dummymon.isShiny?, false, dummymon.gender, form, dummymon.isShadow?)
    pkmnbitmap = croppedBitmap(species, form, pkmnbitmap)
    x = 40 - (pkmnbitmap.width - 128) / 2
    y = 70 - (pkmnbitmap.height - 128) / 2
    y += 8 if species == :EXEGGUTOR && form == 1
    @dexEntrySprites["overlay"].bitmap.blt(x, y, pkmnbitmap, pkmnbitmap.rect)
    pkmnbitmap.dispose

    type1 = mondata.Type1
    type2 = mondata.Type2
    type1bitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/pokedex#{type1}")
    @dexEntrySprites["overlay"].bitmap.blt(296, 118, type1bitmap.bitmap, Rect.new(0, 0, 96, 32))
    type1bitmap.dispose
    if type2 != nil
      type2bitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/pokedex#{type2}")
      @dexEntrySprites["overlay"].bitmap.blt(396, 118, type2bitmap.bitmap, Rect.new(0, 0, 96, 32))
      type2bitmap.dispose
    end

    @quickPokedexScene ? pbPlayCursorSE() : pbPlayCry(dummymon)

    # tts stuff for pokedex
    tts(speciesInt.to_s, true)
    tts(getMonName(species, form))
    tts(_INTL("Typing: {1}", [type1, type2].compact.map{ |t| getTypeName(t) }.join(" ")))
    if owned?(species, form)
      tts(_INTL("{1} Pokémon", kind))
      if pbGetLanguage() == "en_US" # If the user language is set to Egnlish (United States)
        tts(_ISPRINTF("Height: {1:d} feet {2:02d} inches", inches / 12, inches % 12))
        tts(_ISPRINTF("Weight: {1:4.1f} pounds", pounds / 10.0))
      else
        tts(_ISPRINTF("Height: {1:.1f} meters", height / 10.0))
        tts(_ISPRINTF("Weight: {1:.1f} kilograms", weight / 10.0))
      end
      tts(dexentry)
    else
      tts(_INTL("Data not available."))
    end
  end

  # Takes an array of [species, ..., form] values representing pokemon (pokemonlist), and the index of the pokemon we want to start at in that array (index)
  def pbDexEntry(index, pokemonlist)
    curindex = index
    ret = 0
    page, newpage = 1, 0
    advdexpage = nil
    dummymon = $Trainer.pokedex.createDummyPokemon(pokemonlist[curindex][0], pokemonlist[curindex][-1], pokemonlist[curindex][-2])
    pbActivateWindow(@dexEntrySprites, nil) {
      loop do
        Graphics.update if page == 1
        Input.update
        pbUpdate(@dexEntrySprites)
        oldindex = curindex
        if Input.trigger?(Input::C)
          pbPlayCry(dummymon)
        end
        if Input.trigger?(Input::B) || ret == 1
          if page == 1
            pbPlayCancelSE()
            pbFadeOutAndHide(@dexEntrySprites)
          end
          break
        end
        if Input.trigger?(Input::LEFT) || ret == 4
          newpage = page - 1
          if newpage < 1
            newpage = unlockedAdvDex? ? 4 : 3
          end
          pbPlayCursorSE() if newpage > 1
        end
        if Input.trigger?(Input::RIGHT) || ret == 6
          newpage = page + 1
          if newpage > (unlockedAdvDex? ? 4 : 3)
            newpage = 1
          end
          pbPlayCursorSE() unless newpage == 1 # Don't play SE over cry
        end
        if Input.trigger?(Input::R) || ret == 2
          nextindex = getNextIndexDown(curindex, pokemonlist)
          if nextindex >= 0
            curindex = nextindex
            newpage = page
          end
          pbPlayCursorSE() unless newpage == 1 # Don't play SE over cry
        end
        if Input.trigger?(Input::L) || ret == 8
          nextindex = getNextIndexUp(curindex, pokemonlist)
          if nextindex >= 0
            curindex = nextindex
            newpage = page
          end
          pbPlayCursorSE() if newpage > 1
        end
        ret = 0
        next unless newpage > 0

        page, newpage = newpage, 0
        listlimits = 0
        listlimits += 1 if getNextIndexUp(curindex, pokemonlist) < 0 # At top of list
        listlimits += 2 if getNextIndexDown(curindex, pokemonlist) < 0 # At bottom of list
        dummymon = $Trainer.pokedex.createDummyPokemon(pokemonlist[curindex][0], pokemonlist[curindex][-1], pokemonlist[curindex][-2]) if curindex != oldindex
        case page
          when 1 # Show entry
            pbChangeToDexEntry(dummymon)
          when 2 # Show nest
            region = -1
            if !DEXDEPENDSONLOCATION
              thisdex = pbDexNames[pbGetSavePositionIndex]
              region = thisdex[1] if thisdex.is_a?(Array)
            end
            mappos = getMapPosition($game_map.map_id)
            region = mappos ? mappos[0] : region

            if Rejuv
              scene = PokemonRegionMapScene.new(region, true, nil)
              screen = PokemonRegionMap.new(scene)
              ret = screen.pbStartNestScene(dummymon)
            else
              scene = PokemonNestMapScene.new
              screen = PokemonNestMap.new(scene)
              ret = screen.pbStartScreen(dummymon, region, listlimits)
            end
          when 3 # Show forms
            scene = PokedexFormScene.new
            screen = PokedexForm.new(scene)
            ret = screen.pbStartScreen(dummymon, listlimits)

            # Modify the pokemonlist array in-place to account for form having been changed
            # This makes it so the displayed form stays at whatever it was last set to even when scrolling through pokemon and going back to the pokedex main menu
            # This is however not desired for regional dexes / search results / summary pokedex
            unless $PokemonGlobal.pokedexIndex != 0 || @searchResults || @quickPokedexScene
              pokemonlist.each { |array| array[-1] = $Trainer.pokedex[array[0]].lastSeen[:form] }
            end
          when 4 # Show advanced data
            firsttext = _INTL("Advanced Dex: {1}", getMonName(dummymon.species, dummymon.form))
            firsttext += "\n" + _INTL("Use Ctrl + Up or Down keys to navigate between lines.") unless @tipSpoken
            @tipSpoken = true
            tts(firsttext, true)

            scene = AdvancedPokedexScene.new
            screen = AdvancedPokedex.new(scene)
            ret, advdexpage = screen.pbStartScreen(dummymon, advdexpage, listlimits)
        end
      end
    }
    pbEndDexEntryScene
    return curindex
  end

  def getNextIndexUp(curindex, pokemonlist) # find next pokemon to go to on pressing Up
    nextindex = -1
    i = curindex
    loop do
      i -= 1
      break if i < 0
      if !skipEntry?(i, pokemonlist)
        nextindex = i
        break
      end
    end
    return nextindex
  end

  def getNextIndexDown(curindex, pokemonlist) # find next pokemon to go to on pressing Down
    nextindex = -1
    for i in curindex + 1...pokemonlist.length
      if !skipEntry?(i, pokemonlist)
        nextindex = i
        break
      end
    end
    return nextindex
  end

  def skipEntry?(i, pokemonlist)
    return @quickPokedexScene ? pokemonlist[i].nil? : !seen?(pokemonlist[i][0], pokemonlist[i][-1])
  end

  def pbEndDexEntryScene
    pbDisposeSpriteHash(@dexEntrySprites)
    @dexEntryViewport.dispose
  end

  # method to force end any scene
  def pbEndScene
    case @activeScene
      when :pokedex
        pbEndPokedexScene
      when :entry
        pbEndDexEntryScene
      when :region
        pbEndRegionScene
    end
  end
end

class PokemonPokedex
  def initialize(scene)
    @scene = scene
  end

  def pbBattleDexEntry(species, form, gender)
    @scene.pbStartDexEntryScene(species, form, gender)
    @scene.pbSingleDexEntry
    @scene.pbEndScene
  end

  def pbStartRegionScreen
    @scene.pbStartRegionScene
    @scene.pbRegionMenu
    @scene.pbEndScene
  end

  def pbStartPokedexScreen
    @scene.pbStartPokedexScene
    @scene.pbPokedexMenu
    @scene.pbEndScene
  end
end

def croppedBitmap(species, form, bitmap)
  return bitmap unless species == :EXEGGUTOR && form == 1

  size = 192 # size of cropped bitmap
  croppedBMP = Bitmap.new(size, size)
  x = (bitmap.width / 2) - (size / 2)
  croppedBMP.blt(0, 0, bitmap, Rect.new(x, 0, size, size))
  return croppedBMP
end

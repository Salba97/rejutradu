################################################################################
# The Bag.
################################################################################
class Window_PokemonBag < Window_DrawableCommand
  SortHighlightColors = LightColorArrays[:Red3]
  CloseBagColors = LightColorArrays[:Gray]

  attr_reader :pocket
  attr_reader :sortIndex

  def initialize(bag, pocket, x, y, width, height)
    @bag = bag
    @pocket = pocket
    @sortIndex = -1
    @adapter = PokemonMartAdapter.new
    super(x, y, width, height)
    self.windowskin = nil
  end

  def getCursorGraphic
    return "Graphics/Pictures/Bag/bagSel"
  end

  def itemCount
    return @bag.getPocketItems(@pocket).length + 1
  end

  def pocket=(value)
    @pocket = value
    @item_max = @bag.getPocketItems(@pocket).length + 1
    self.index = @bag.getChoice(@pocket)
    refresh
  end

  def sortIndex=(value)
    @sortIndex = value
    refresh
  end

  def page_row_max; return PokemonBag_Scene::ITEMSVISIBLE; end
  def page_item_max; return PokemonBag_Scene::ITEMSVISIBLE; end

  def itemRect(item)
    if item < 0 || item >= @item_max || item < self.top_item - 1 ||
       item > self.top_item + self.page_item_max
      return Rect.new(0, 0, 0, 0)
    else
      cursor_width = (self.width - self.borderX - (@column_max - 1) * @column_spacing) / @column_max
      x = item % @column_max * (cursor_width + @column_spacing)
      y = item / @column_max * @row_height - @virtualOy
      return Rect.new(x, y, cursor_width, @row_height)
    end
  end

  def drawCursor(index, rect)
    if self.index == index
      pbCopyBitmap(self.contents, @selarrow.bitmap, rect.x, rect.y + 14)
    end
    return Rect.new(rect.x + 16, rect.y + 16, rect.width - 16, rect.height)
  end

  def item
    item = @bag.getPocketItems(@pocket)[self.index]
    return item ? item : nil
  end

  def drawItem(index, count, rect)
    textpos = []
    imagepos = []
    rect = drawCursor(index, rect)
    ypos = rect.y + 4
    pocketItems = @bag.getPocketItems(@pocket)
    if index == pocketItems.length
      textpos.push([_INTL("Close Bag"), rect.x, ypos, false, *CloseBagColors])
    else
      item = pocketItems[index]
      itemname = @adapter.getDisplayName(item, bag: true)
      qty = _ISPRINTF("x{1: 2d}", @bag.contents[item])
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 16
      colors = index == @sortIndex ? SortHighlightColors : [self.baseColor, self.shadowColor]
      textpos.push([itemname, rect.x, ypos, false, *colors])
      if shouldShowQuantity?(item)
        textpos.push([qty, xQty, ypos, false, *colors])
      end
      if pbIsTM?(item)
        type = $cache.moves[pbGetTM(item)].type
        imagepos.push(["Graphics/Icons/minitype#{type}", rect.x + rect.width - 40, ypos + 4, 0, 0, -1, -1])
      end
      if @bag.pbIsRegistered?(item)
        imagepos.push(["Graphics/Pictures/Bag/bagReg", rect.x + rect.width - 58, ypos + 4, 0, 0, -1, -1])
      end
    end
    pbDrawTextPositions(self.contents, textpos)
    pbDrawImagePositions(self.contents, imagepos)
  end

  def refresh
    @item_max = itemCount()
    self.update_cursor_rect
    dwidth = self.width - self.borderX
    dheight = self.height - self.borderY
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    for i in 0...@item_max
      if i < self.top_item - 1 || i > self.top_item + self.page_item_max
        next
      end

      drawItem(i, @item_max, itemRect(i))
    end
  end
end

class PokemonBag_Scene
  ## Configuration
  ITEMLISTBASECOLOR     = Color.new(88, 88, 80)
  ITEMLISTSHADOWCOLOR   = Color.new(168, 184, 184)
  ITEMTEXTBASECOLOR     = Color.new(248, 248, 248)
  ITEMTEXTSHADOWCOLOR   = Color.new(0, 0, 0)
  POCKETNAMEBASECOLOR   = Color.new(88, 88, 80)
  POCKETNAMESHADOWCOLOR = Color.new(168, 184, 184)
  POCKETNAMEY           = 180
  ITEMSVISIBLE          = 7

  SLIDER_Y_COORD = 60
  SLIDER_Y_COORD_BASE = 116.0

  TM_X_VALUES = [16, 106, 16, 106, 16, 106]
  TM_Y_VALUES = [0, 16, 64, 80, 128, 144]

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @bag = bag
    @sprites = {}
    lastpocket = @bag.lastpocket
    lastitem = @bag.getChoice(lastpocket)
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(sprintf("Graphics/Pictures/Bag/bagbg#{lastpocket}"))
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].play
    @sprites["rightarrow"].play
    @sprites["bag"] = IconSprite.new(30, 20, @viewport)
    @sprites["icon"] = IconSprite.new(24, Graphics.height - 72, @viewport)
    @sprites["itemwindow"] = Window_PokemonBag.new(@bag, lastpocket, 168, -8, 314, 40 + 32 + ITEMSVISIBLE * 32)
    @sprites["itemwindow"].viewport = @viewport
    @sprites["itemwindow"].pocket = lastpocket
    @sprites["itemwindow"].index = lastitem
    @sprites["itemwindow"].baseColor = ITEMLISTBASECOLOR
    @sprites["itemwindow"].shadowColor = ITEMLISTSHADOWCOLOR
    @sprites["itemwindow"].refresh
    @sprites["slider"] = IconSprite.new(Graphics.width - 40, 60, @viewport)
    @sprites["slider"].setBitmap(sprintf("Graphics/Pictures/Bag/bagSlider"))
    @sprites["pocketwindow"] = BitmapSprite.new(186, 228, @viewport)
    pbSetSystemFont(@sprites["pocketwindow"].bitmap)
    @sprites["itemtextwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["itemtextwindow"].x = 72
    @sprites["itemtextwindow"].y = 270
    @sprites["itemtextwindow"].width = Graphics.width - 72
    @sprites["itemtextwindow"].height = 128
    @sprites["itemtextwindow"].baseColor = ITEMTEXTBASECOLOR
    @sprites["itemtextwindow"].shadowColor = ITEMTEXTSHADOWCOLOR
    @sprites["itemtextwindow"].visible = true
    @sprites["itemtextwindow"].viewport = @viewport
    @sprites["itemtextwindow"].windowskin = nil
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible = false
    @sprites["msgwindow"].viewport = @viewport
    @sprites["partybg"] = IconSprite.new(0, 0, @viewport)
    @sprites["partybg"].setBitmap(sprintf("Graphics/Pictures/Bag/tmPartyBackground")) rescue nil
    @sprites["partybg"].visible = false
    pbTMSprites
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    favPokeTracker(:train)
    @viewport.dispose
  end

  def pbTMSprites
    for i in 0...$Trainer.party.length
      if !@sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"] = IconSprite.new(0, 0, @viewport)
        @sprites["pokemon#{i}"].bitmap = pbPokemonIconBitmap($Trainer.party[i])
        @sprites["pokemon#{i}"].src_rect = Rect.new(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
        @sprites["pokemon#{i}"].x = TM_X_VALUES[i] - (AURA_SPRITE_OFFSET / 2)
        @sprites["pokemon#{i}"].y = TM_Y_VALUES[i] - (AURA_SPRITE_OFFSET / 2)
        @sprites["pokemon#{i}"].visible = false
      else
        @sprites["pokemon#{i}"].bitmap = pbPokemonIconBitmap($Trainer.party[i])
        @sprites["pokemon#{i}"].src_rect = Rect.new(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
      end
      unless @sprites["possiblelearn#{i}"]
        @sprites["possiblelearn#{i}"] = IconSprite.new(0, 0, @viewport)
        @sprites["possiblelearn#{i}"].x = TM_X_VALUES[i] + 32
        @sprites["possiblelearn#{i}"].y = TM_Y_VALUES[i] + 32
        @sprites["possiblelearn#{i}"].visible = false
      end
    end
  end

  def pbDetermineTMmenu(itemwindow)
    if itemwindow.item.is_a?(Symbol) && (itemwindow.pocket == TMPOCKET || pbIsTM?(itemwindow.item))
      machine = pbGetTM(itemwindow.item)
      canlearnmove = PokemonBag.pbPartyCanLearnThisMove?(machine)
      @sprites["partybg"].visible = true
      for i in 0...$Trainer.party.length
        @sprites["pokemon#{i}"].visible = true
        @sprites["possiblelearn#{i}"].visible = true
        sprite = case canlearnmove[i]
          when 0 then "Graphics/Pictures/Bag/tmnope" # unable
          when 1 then "Graphics/Pictures/Bag/tmcheck" # able
          when 2 then "Graphics/Pictures/Bag/tmdash" # learned
          else nil
        end
        @sprites["possiblelearn#{i}"].setBitmap(sprite)
      end
    else
      @sprites["partybg"].visible = false
      for i in 0...$Trainer.party.length
        @sprites["pokemon#{i}"].visible = false
        @sprites["possiblelearn#{i}"].visible = false
      end
    end
  end

  def pbChooseNumber(helptext, maximum)
    return UIHelper.pbChooseNumber(
      @sprites["helpwindow"], helptext, maximum
    ) { update }
  end

  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { update }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { update }
  end

  def pbShowCommands(helptext, commands)
    return UIHelper.pbShowCommands(
      @sprites["helpwindow"], helptext, commands
    ) { update }
  end

  def pbRefresh
    bm = @sprites["pocketwindow"].bitmap
    bm.clear
    # Set the background bitmap for the currently selected pocket
    @sprites["background"].setBitmap(sprintf("Graphics/Pictures/Bag/bagbg#{@bag.lastpocket}"))
    # Set the bag picture for the currently selected pocket
    @sprites["bag"].setBitmap("Graphics/Pictures/Bag/bag") unless Reborn
    # Draw the pocket name
    name = PokemonBag.pocketNames()[@bag.lastpocket]
    base = POCKETNAMEBASECOLOR
    shadow = POCKETNAMESHADOWCOLOR
    pbDrawTextPositions(
      bm,
      [
        [name, bm.width / 2, POCKETNAMEY, 2, base, shadow]
      ]
    )
    # Reset positions of left/right arrows around the bag
    @sprites["leftarrow"].x = -4
    @sprites["leftarrow"].y = 76
    @sprites["rightarrow"].x = 150
    @sprites["rightarrow"].y = 76
    itemwindow = @sprites["itemwindow"]
    # Draw the slider
    ycoord = SLIDER_Y_COORD
    if itemwindow.itemCount > 1
      ycoord += SLIDER_Y_COORD_BASE * itemwindow.index / (itemwindow.itemCount - 1)
    end
    @sprites["slider"].y = ycoord
    # Set the icon for the currently selected item
    filename = pbItemIconFile(itemwindow.item)
    @sprites["icon"].setBitmap(filename)
    # Display the item's description
    drawBagItemDescription(@sprites["itemtextwindow"], itemwindow.item)

    # Refresh the item window
    itemwindow.refresh
  end

  def drawBagItemDescription(sprite, item)
    sprite.text = item.nil? ? _INTL("Close bag.") : getItemDescription(item)
    case sprite.lines
    when 1
      sprite.y = 302
      sprite.lineHeight = 32
    when 2
      sprite.y = 286
      sprite.lineHeight = 32
    else
      sprite.y = 276
      sprite.lineHeight = 28
    end
    sprite.refresh
  end

  # Called when the item screen wants an item to be chosen from the screen
  def pbChooseItem
    pbRefresh
    pbTMSprites
    @sprites["helpwindow"].visible = false
    itemwindow = @sprites["itemwindow"]
    itemwindow.refresh
    sorting = false
    sortindex = -1
    pbDetermineTMmenu(itemwindow)
    pbActivateWindow(@sprites, "itemwindow") {
      ttsItem(itemwindow.item)
      lastread = itemwindow.item
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        oldindex = itemwindow.index
        self.update
        if itemwindow.item != olditem
          # Update slider position
          ycoord = SLIDER_Y_COORD
          if itemwindow.itemCount > 1
            ycoord += SLIDER_Y_COORD_BASE * itemwindow.index / (itemwindow.itemCount - 1)
          end
          @sprites["slider"].y = ycoord
          # Update item icon and description
          filename = pbItemIconFile(itemwindow.item)
          @sprites["icon"].setBitmap(filename)
          drawBagItemDescription(@sprites["itemtextwindow"], itemwindow.item)
          if itemwindow.item != lastread
            ttsItem(itemwindow.item)
            lastread = itemwindow.item
          end
          pbDetermineTMmenu(itemwindow)
        end
        if itemwindow.index != oldindex
          # Update selected item for current pocket
          @bag.setChoice(itemwindow.pocket, itemwindow.index)
        end
        # Change pockets if Left/Right pressed
        numpockets = PokemonBag.numPockets
        if Input.trigger?(Input::LEFT)
          if !sorting
            pbPlayCursorSE()
            itemwindow.pocket = (itemwindow.pocket == 1) ? numpockets : itemwindow.pocket - 1
            @bag.lastpocket = itemwindow.pocket
            pbRefresh
            pbDetermineTMmenu(itemwindow)
            ttsItem(itemwindow.item, PokemonBag.pocketNames()[itemwindow.pocket] + " Pocket, ")
            lastread = itemwindow.item
          end
        elsif Input.trigger?(Input::RIGHT)
          if !sorting
            pbPlayCursorSE()
            itemwindow.pocket = (itemwindow.pocket == numpockets) ? 1 : itemwindow.pocket + 1
            @bag.lastpocket = itemwindow.pocket
            pbRefresh
            pbDetermineTMmenu(itemwindow)
            ttsItem(itemwindow.item, PokemonBag.pocketNames()[itemwindow.pocket] + " Pocket, ")
            lastread = itemwindow.item
          end
        end
        thispocket = @bag.getPocketItems(itemwindow.pocket)
        # Sorting
        numSort = itemwindow.pocket == TMPOCKET
        sortBy = nil
        sortBy = :name if Input.trigger?(Input::X)
        sortBy = :type if Input.trigger?(Input::A)
        sortBy = :number if Input.trigger?(Input::Y) && numSort
        if sortBy && itemwindow.pocket != FAVORITEPOCKET # Sorting doesn't work in Favorites pocket anyway, the condition is here to prevent SFX and TTS
          pbHandleSort(itemwindow.pocket, sortBy)
          pbRefresh
          ttsItem(itemwindow.item, interrupt: false)
        end
        # TTS sort controls
        if Input.triggerex?(Input::F2)
          ttsSortControls(:name, :type, numSort ? :number : nil)
        end
        # Select item for switching if S is pressed
        if Input.trigger?(Input::Y) && itemwindow.pocket != TMPOCKET && itemwindow.pocket != FAVORITEPOCKET # Item order in Favorites pocket is static
          if itemwindow.index < thispocket.length && thispocket.length > 1
            if @sprites["itemwindow"].sortIndex == itemwindow.index
              pbPlayCancelSE()
              sorting = false
              @sprites["itemwindow"].sortIndex = -1
            else
              pbPlayDecisionSE()
              sorting = true
              sortindex = itemwindow.index
              @sprites["itemwindow"].sortIndex = sortindex
            end
          end
        end
        # Favorite item
        if Input.trigger?(Input::Z) && itemwindow.index < thispocket.length
          if @bag.isFavorite?(itemwindow.item)
            @bag.removeFavorite(itemwindow.item)
            pbPlayDecisionSE()
            tts(_INTL("Removed from Favorite Items"), true)
          else
            @bag.addFavorite(itemwindow.item)
            pbPlayDecisionSE()
            tts(_INTL("Added to Favorite Items"), true)
          end
          pbRefresh
        end
        # Cancel switching or cancel the item screen
        if Input.trigger?(Input::B)
          if sorting
            pbPlayCancelSE()
            sorting = false
            @sprites["itemwindow"].sortIndex = -1
          else
            return nil
          end
        end
        # Confirm selection or item switch
        if Input.trigger?(Input::C)
          if itemwindow.index < thispocket.length
            if sorting
              pbPlayDecisionSE()
              sorting = false
              tmp = thispocket[itemwindow.index]
              thispocket[itemwindow.index] = thispocket[sortindex]
              thispocket[sortindex] = tmp
              @sprites["itemwindow"].sortIndex = -1
              pbRefresh
              next
            else
              pbRefresh
              return thispocket[itemwindow.index]
            end
          else
            return nil
          end
        end
      end
    }
  end

  def pbHandleSort(pocket, sortBy)
    pbPlayDecisionSE()
    tts(sortBy == :name ? _INTL("Sorted by name") : (sortBy == :type ? _INTL("Sorted by type") : _INTL("Sorted by number")), true)
    items = @bag.getPocketItems(pocket)
    case sortBy
      when :name then pocket == TMPOCKET ? pbSortByMoveName(items) : pbSortByName(items)
      when :type then pocket == TMPOCKET ? pbSortByMoveType(items) : pbSortByItemType(items)
      when :number then pbSortByItemType(items) # Only for TM pocket, would be same as pbSortByName, sorts TMs by number
    end
  end

  def pbSortByName(items)
    result = items.sort_by { |item| getItemName(item) }
    pbApplySortingResult(items, result)
  end

  def pbSortByMoveName(items)
    result = items.sort_by { |item| pbGetMachineMoveName(item) }
    pbApplySortingResult(items, result)
  end

  def pbSortByItemType(items)
    result = items.sort_by { |item| pbGetItemTypeIndex(item) }
    pbApplySortingResult(items, result)
  end

  def pbSortByMoveType(items)
    # Sort by move type, and by move name within type
    result = items.sort_by { |item| [getTypeName($cache.moves[pbGetTM(item)].type), pbGetMachineMoveName(item)] }
    pbApplySortingResult(items, result)
  end

  def pbGetItemTypeIndex(item)
    mapping = pbGetSortOrderByTypeMapping
    result = mapping[item]
    return result if result

    # Not in the custom order => sort by name instead
    return getItemName(item)
  end

  def pbApplySortingResult(items, result)
    # Makes use of the fact that a pointer is passed for arrays rather
    # than the content of the variable itself
    for i in 0...items.length
      items[i] = result[i]
    end
  end

  def pbGetSortOrderByTypeMapping
    # The cost of keeping the mapping in memory in case the user sorts the bag may outweigh
    # the CPU cost of re-parsing the sort order every time, so the cache hasn't been applied
    # here for the moment
    # Use the cached mapping if possible
    return @sortOrderMapping if defined?(@sortOrderMapping)

    # First, get all items in the same array
    # ...yeah, categories don't matter, they are just to make it easier to edit the order
    order = pbGetSortOrderByType
    sortedItems = []
    order.each do |flag, cat|
      sortedItems.push(*cat)
    end
    # Now transform the array into an hash, where the values are the array's indexes
    # as a padded string - this way we can later use the item name as a fallback
    # when the item is not mapped, and still have this work correctly for the others
    maxLen = "#{sortedItems.length}".length
    result = {}
    for i in 0...sortedItems.length
      itemId = sortedItems[i]
      result[itemId] = "#{i}".rjust(maxLen, '0')
    end
    @sortOrderMapping = result
    return @sortOrderMapping
  end

  def ttsItem(item, prefix = "", interrupt: true)
    string = prefix
    if pbIsTM?(item)
      type = getTypeName($cache.moves[pbGetTM(item)].type)
      string += getItemName(item) + " " + pbGetMachineMoveName(item) + " (#{type})"
    elsif item
      if @bag.contents[item] > 1 && shouldShowQuantity?(item)
        string += @bag.contents[item].to_s + " " + getItemName(item, plural: true)
      else
        string += getItemName(item)
      end
    else
      string += _INTL("Close bag")
    end
    string += ", " + getItemDescription(item) if item
    tts(string, interrupt)
  end

  def pbGetSortOrderByType
    conditions = { # Items will go into the first category that they apply to
      :overworld => ->(item) { item.checkFlag?(:overworld) },
      :evostone => ->(item) { item.checkFlag?(:evoitem) && item.name.to_s.downcase.include?("stone") },
      :evoitem => ->(item) { item.checkFlag?(:evoitem) },
      :utilityhold => ->(item) { item.checkFlag?(:utilityhold) },
      :battlehold => ->(item) { item.checkFlag?(:battlehold) },
      :consumehold => ->(item) { item.checkFlag?(:consumehold) },
      :incense => ->(item) { item.checkFlag?(:incense) },
      :typeboost => ->(item) {
        item.checkFlag?(:typeboost) && !(item.checkFlag?(:incense) || item.checkFlag?(:gem) || item.checkFlag?(:plate))
      },
      :plate => ->(item) { item.checkFlag?(:plate) },
      :memory => ->(item) { item.checkFlag?(:memory) },
      :gem => ->(item) { item.checkFlag?(:gem) },
      :pokespecifichold => ->(item) { item.checkFlag?(:pokehold) },
      :legendhold => ->(item) { item.checkFlag?(:legendhold) },
      :application => ->(item) { item.checkFlag?(:application) },
      :fossil => ->(item) { item.checkFlag?(:fossil) },
      :nectar => ->(item) { item.checkFlag?(:nectar) },
      :selluseless => ->(item) { item.checkFlag?(:justsell) },
      :healing => ->(item) { item.checkFlag?(:healing) && !item.name.to_s.include?("Ice Cream") },
      :icecream => ->(item) { item.checkFlag?(:healing) && item.name.to_s.include?("Ice Cream") },
      :revival => ->(item) { item.checkFlag?(:revival) },
      :status => ->(item) { item.checkFlag?(:status) },
      :pprestore => ->(item) { item.checkFlag?(:pprestore) },
      :expup => ->(item) { item.checkFlag?(:levelup) },
      :ppup => ->(item) { item.checkFlag?(:evup) && item.name.to_s.include?("PP") },
      :evup => ->(item) {
        # EV Up should only catch EV boosting items - PP ups, imprints, reset discs sorted separately
        item.checkFlag?(:evup) &&
          !(item.name.to_s.include?("PP") || item.name.to_s.include?("Imprint") || item.name.to_s.include?("Reset Disc"))
      },
      :resetdisc => ->(item) { item.checkFlag?(:evup) && item.name.to_s.include?("Reset Disc") },
      :imprint => ->(item) { item.checkFlag?(:evup) && item.name.to_s.include?("Imprint") },
      :mint => ->(item) { item.checkFlag?(:mint) },
      :shadowitem => ->(item) { [:JOYSCENT, :EXCITESCENT, :VIVIDSCENT, :TIMEFLUTE].include?(item.item) },
      :paint => ->(item) { item.item == :PAINTJAR },
      :ball => ->(item) { item.checkFlag?(:ball) },
      :tm => ->(item) {
        item.checkFlag?(:tm) && pbGetTM(item.item) &&
          !(item.name.to_s.include?("TMX") || item.name.to_s.include?("HM") || item.name.to_s.include?("RM"))
      },
      :tmx => ->(item) { item.checkFlag?(:tm) && pbGetTM(item.item) && item.name.to_s.include?("TMX") },
      :hm => ->(item) { item.checkFlag?(:tm) && pbGetTM(item.item) && item.name.to_s.include?("HM") },
      :rm => ->(item) { item.checkFlag?(:tm) && pbGetTM(item.item) && item.name.to_s.include?("RM") },
      :berry => ->(item) {
        item.berry &&
          !(item.berry.resisttype || item.berry.pinch || item.name.to_s.include?("Apricorn"))
      },
      :pinchberry => ->(item) { item.berry&.pinch },
      :resistberry => ->(item) { item.berry&.resisttype },
      :typezcrystal => ->(item) { pbIsTypeZCrystal?(item.item) },
      :zcrystal => ->(item) { item.zmove && !$cache.moves[item.zmove]&.zmovedata&.type },
      :apricorn => ->(item) { item.berry && item.name.to_s.include?("Apricorn") },
      :megastone => ->(item) {
        # Mega stones are non zcrystal crystals... hah!
        # Special case for mega stones - puts orbs separate at the bottom
        item.checkFlag?(:crystal) && !(item.zmove || [:REDORB, :BLUEORB].include?(item.item))
      },
      :orb => ->(item) { item.checkFlag?(:crystal) && [:REDORB, :BLUEORB].include?(item.item) },
      :crest => ->(item) { item.checkFlag?(:crest) },
      :mail => ->(item) { item.checkFlag?(:mail) },
      :battleitem => ->(item) { item.checkFlag?(:battleitem) || item.medicine&.xitem },
      :generalusekey => ->(item) {
        item.checkFlag?(:general) && !item.name.to_s.include?("Exp. All")
      },
      :expall => ->(item) { item.checkFlag?(:general) && item.name.to_s.include?("Exp. All") },
      :goldenitem => ->(item) { item.checkFlag?(:keyitem) && item.name.to_s.include?("Golden") },
      :legendarykey => ->(item) { item.checkFlag?(:legendary) },
      :important => ->(item) { item.checkFlag?(:important) },
      :keys => ->(item) { item.checkFlag?(:keys) },
      :battlepass => ->(item) { item.checkFlag?(:story) && item.name.to_s.include?("Battle Pass") },
      :rebornseal => ->(item) {
        item.checkFlag?(:story) && [:RUBYRING, :SAPPHIREBRACELETS, :EMERALDBROOCH, :AMETHYSTPENDANT].include?(item.item)
      },
      :rebornstar => ->(item) {
        item.checkFlag?(:story) && [:RUBYSTAR, :SAPPHIRESTAR, :EMERALDSTAR, :AMETHYSTSTAR].include?(item.item)
      },
      :storybased => ->(item) { item.checkFlag?(:story) },
      :niche => ->(item) { item.checkFlag?(:niche) },
      :desopiece => ->(item) { item.checkFlag?(:sidequest) && item.name.to_s.include?("Piece") },
      :sidequest => ->(item) { item.checkFlag?(:sidequest) },

      :postgamequest => ->(item) { item.checkFlag?(:questitem) },
      :evcard => ->(item) { item.checkFlag?(:evCard) },
      :noncategorized => ->(item) { true },
    }

    categories = {}
    conditions.each do |key, _obj|
      categories[key] = []
    end

    $cache.items.each do |_key, item|
      # Finds first category for which item lamdba function is true
      category = conditions.find { |_, cat| cat.call(item) }.first
      categories[category].push(item.item) if category
    end

    # Apply manual sorts for specific cases

    # Ultra Potion should be put after Hyper Potion
    if categories[:healing].include?(:ULTRAPOTION)
      categories[:healing].delete(:ULTRAPOTION)
      categories[:healing] = categories[:healing][0, 3] + [:ULTRAPOTION] + categories[:healing][3..-1]
    end

    # Essentials ID order of original balls goes Master, Ultra, Great, Poke. We want to reverse these 4.
    ball_items = categories[:ball]
    categories[:ball] = [:POKEBALL, :GREATBALL, :ULTRABALL, :MASTERBALL] + ball_items.drop(4)

    # Sorts TMs and TMXs by TM Number
    categories[:tmx] = categories[:tmx].sort { |tmx2, tmx3|
      $cache.items[tmx2].name.sub("TMX", "").to_i <=> $cache.items[tmx3].name.sub("TMX", "").to_i
    }
    categories[:hm] = categories[:hm].sort { |hm2, hm3|
      $cache.items[hm2].name.sub("HM", "").to_i <=> $cache.items[hm3].name.sub("HM", "").to_i
    }
    categories[:rm] = categories[:rm].sort { |rm2, rm3|
      $cache.items[rm2].name.sub("RM", "").to_i <=> $cache.items[rm3].name.sub("RM", "").to_i
    }
    categories[:tm] = categories[:tm].sort { |tm2, tm3|
      $cache.items[tm2].name.sub("TM", "").to_i <=> $cache.items[tm3].name.sub("TM", "").to_i
    }

    # Sorts crystals by name
    categories[:megastone] = categories[:megastone].sort!
    categories[:typezcrystal] = categories[:typezcrystal].sort!
    categories[:zcrystal] = categories[:zcrystal].sort!

    # Sorts Reborn seals to actually match Ruby/Sapphire/Emerald/Amethyst
    seal_order = {
      :RUBYRING => 1,
      :SAPPHIREBRACELETS => 2,
      :EMERALDBROOCH => 3,
      :AMETHYSTPENDANT => 4
    }
    categories[:rebornseal] = categories[:rebornseal].sort_by { |key| seal_order[key] }

    return categories
  end
end

class PokemonBag
  attr_reader :registeredItem
  attr_accessor :lastpocket
  attr_reader :pockets
  attr_accessor :registeredItems
  attr_accessor :itemtracker
  attr_accessor :contents
  attr_accessor :favoriteItems
  attr_accessor :defaultBall

  TRACKTM = 0
  TRACKMEGA = 1
  TRACKCRYSTAL = 2
  TRACKMEM = 3

  def self.pocketNames()
    return pbPocketNames
  end

  def self.numPockets()
    return self.pocketNames().length - 1
  end

  def initialize
    @lastpocket = 1
    @pockets = []
    @choices = []
    @contents = {}
    # Initialize each pocket of the array
    for i in 0..PokemonBag.numPockets
      @pockets[i] = []
      @choices[i] = 0
    end
    # initialize items into their pockets
    for item in $cache.items.keys
      @contents[item] = 0
    end
    @registeredItems = []
    @registeredIndex = [0, 0, 1]
    @favoriteItems = []
    initTrackerData
  end

  def pockets
    return @pockets
  end

  def self.pbPartyCanLearnThisMove?(move)
    trutharray = []
    for i in $Trainer.party
      learned = false
      unless i.isEgg?
        for j in 0..(i.moves.length - 1)
          learned = true if i.moves[j].move == move
        end
      end
      if move.nil?
        trutharray.push(3) # no symbol
      elsif learned
        trutharray.push(2) # learned
      elsif i.isEgg? || (i.isShadow? rescue false) || !i.SpeciesCompatible?(move)
        trutharray.push(0) # unable
      else
        trutharray.push(1) # able
      end
    end
    return trutharray
  end

  def rearrange()
    if @pockets.length == 6 && PokemonBag.numPockets == 8
      newpockets = []
      for i in 0..8
        newpockets[i] = []
        @choices[i] = 0 if !@choices[i]
      end
      for i in 0..5
        for item in @pockets[i]
          newpockets[pbGetPocket(item)].push(item)
        end
      end
      @pockets = newpockets
    end

    need_resorting = []
    @pockets.each_with_index do |pocket, idx|
      pocket.select! do |item|
        if !$cache.items[item]
          next false
        elsif pbGetPocket(item) != idx
          need_resorting.push(item)
          next false
        else
          next true
        end
      end
    end
    need_resorting.each do |item|
      @pockets[pbGetPocket(item)].push(item)
    end

    # Move battle items into medicine
    if @pockets[FAVORITEPOCKET].length > 0
      @pockets[2] = @pockets[2] + @pockets[FAVORITEPOCKET]
      @pockets[FAVORITEPOCKET] = []
    end
  end

  # Gets the index of the current selected item in the pocket
  def getChoice(pocket)
    return [@choices[pocket], getPocketItems(pocket).length].min || 0
  end

  # Clears the entire bag
  def clear
    for pocket in @pockets
      pocket.each { |item|
        @contents[item] = 0
      }
      pocket.clear
    end
  end

  # Sets the index of the current selected item in the pocket
  def setChoice(pocket, value)
    @choices[pocket] = value if value <= getPocketItems(pocket).length
  end

  def registeredItems
    @registeredItems = [] if !@registeredItems
    if @registeredItem.is_a?(Array)
      @registeredItems = @registeredItem
      @registeredItem = 0
    end
    if @registeredItem && @registeredItem > 0 && !@registeredItems.include?(@registeredItem)
      @registeredItems.push(@registeredItem)
      @registeredItem = nil
    end
    return @registeredItems
  end

  def pbIsRegistered?(item)
    registeredlist = self.registeredItems
    return registeredlist.include?(item)
  end

  # Registers the item as a key item.  Can be retrieved with $PokemonBag.registeredItem
  def pbRegisterKeyItem(item)
    if item != @registeredItem
      @registeredItem = item
    else
      @registeredItem = nil
    end
  end

  # Registers the item in the Ready Menu.
  def pbRegisterItem(item)
    registeredlist = self.registeredItems
    registeredlist.push(item) if !registeredlist.include?(item)
  end

  # Unregisters the item from the Ready Menu.
  def pbUnregisterItem(item)
    self.registeredItems.delete(item)
  end

  def registeredIndex
    @registeredIndex = [0, 0, 1] if !@registeredIndex
    return @registeredIndex
  end

  def pbQuantity(item)
    return @contents[item].nil? ? 0 : @contents[item]
  end

  def pbHasItem?(item)
    return pbQuantity(item) > 0
  end

  def pbDeleteItem(item, qty = 1)
    currentamt = @contents[item]
    return false if currentamt == 0

    if qty >= currentamt
      @contents[item] = 0
      @pockets[pbGetPocket(item)].delete(item)
      @registeredItems.delete(item)
    else
      @contents[item] = currentamt - qty
    end
    return true
  end

  def pbCanStore?(item, qty = 1)
    return true
  end

  def pbStoreItem(item, qty = 1)
    @contents[item] = 0 if @contents[item].nil?
    # trackItem(item) disabled for now. useless in reborn.
    return false if @contents[item] >= BAGMAXPERSLOT || item.nil?

    @pockets[pbGetPocket(item)].push(item) if @contents[item] == 0
    @contents[item] = pbIsTM?(item) || pbIsZCrystal?(item) ? 1 : [BAGMAXPERSLOT, @contents[item] + qty].min
    return true
  end

  def pbChangeItem(olditem, newitem)
    return unless self.pbHasItem?(olditem)

    oldpocket = @pockets.find_index { |pocket| pocket.include?(olditem) }
    oldindex = @pockets[oldpocket].index(olditem)
    amount = @contents[olditem]

    @pockets[oldpocket].delete(olditem)
    @contents.delete(olditem)

    newpocket = pbGetPocket(newitem)
    if newpocket == oldpocket
      @pockets[oldpocket].insert(oldindex, newitem)
    else
      @pockets[newpocket].push(newitem)
    end
    @contents[newitem] = amount
  end

  # hot new itemtracker functionality!
  def initTrackerData
    @itemtracker = []
    return # effectively disables this.
    hashTM = {} # tms
    hashMEGA = {} # stones
    hashCRYSTAL = {} # crystals
    hashMEM = {} # memories
    # scan the item data so we don't have to write this all out manually!
    $cache.items.each do |item, data|
      hashTM[item] = false if pbIsTM?(item)
      if pbGetPocket(item) == 6 # stones and crystals
        if pbIsZCrystal?(item)
          hashCRYSTAL[item] = false
        else
          hashMEGA[item] = false
        end
      end
      hashMEM[item] = false if data.checkFlag?(:memory)
    end
    @itemtracker[TRACKTM] = hashTM
    @itemtracker[TRACKMEGA] = hashMEGA
    @itemtracker[TRACKCRYSTAL] = hashCRYSTAL
    @itemtracker[TRACKMEM] = hashMEM
  end

  def itemscan
    # scan the bag first
    initTrackerData
    for key in @itemtracker[TRACKTM].keys
      @itemtracker[TRACKTM][key] = true if pbHasItem?(key)
    end
    for key in @itemtracker[TRACKMEGA].keys
      @itemtracker[TRACKMEGA][key] = true if pbHasItem?(key)
    end
    for key in @itemtracker[TRACKCRYSTAL].keys
      @itemtracker[TRACKCRYSTAL][key] = true if pbHasItem?(key)
    end
    for key in @itemtracker[TRACKMEM].keys
      @itemtracker[TRACKMEM][key] = true if pbHasItem?(key)
    end
    # scan the pc???? who uses this
    if $PokemonGlobal.pcItemStorage
      for item in $PokemonGlobal.pcItemStorage.items
        next if pbQuantity(item[0]) == 0

        trackItem(item[0])
      end
    end
    # now scan mons. all of them. everywhere.
    for mon in $Trainer.party
      trackItem(mon.item) if mon.item
    end
    for box in 0...$PokemonStorage.maxBoxes
      for index in 0...$PokemonStorage[box].length
        mon = $PokemonStorage[box, index]
        next if !mon || mon.item.nil?

        trackItem(mon.item)
      end
    end
  end

  def trackItem(item)
    @itemtracker[TRACKTM][item] = true if pbIsTM?(item)
    if pbGetPocket(item) == 6 # stones and crystals
      @itemtracker[TRACKMEGA][item] = true if pbIsZCrystal?(item)
      @itemtracker[TRACKCRYSTAL][item] = true if !pbIsZCrystal?(item)
    end
    @itemtracker[TRACKMEM][item] = true if $cache.items[item].checkFlag?(:memory)
  end

  def favoriteItems
    @favoriteItems = [] unless @favoriteItems
    return @favoriteItems
  end

  def isFavorite?(item)
    return self.favoriteItems.include?(item)
  end

  def addFavorite(item)
    self.favoriteItems.push(item) unless isFavorite?(item)
  end

  def removeFavorite(item)
    self.favoriteItems.delete(item)
  end

  def getPocketItems(pocket)
    if pocket == FAVORITEPOCKET
      items = []
      (1..8).each do |i|
        @pockets[i].each do |item|
          items.push(item) if isFavorite?(item)
        end
      end
      return items
    end

    return @pockets[pocket]
  end

  def setDefaultBall
    return if @defaultBall && pbHasItem?(@defaultBall)
    @defaultBall = @pockets[POKEBALLPOCKET].first # will be nil if no poke balls
  end
end

class PokemonBagScreen
  def initialize(scene, bag)
    @bag = bag
    @scene = scene
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

  # UI logic for the item screen when an item is to be held by a Pokémon.
  def pbGiveItemScreen
    @scene.pbStartScene(@bag)
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if item == nil
      break if !pbIsImportantItem?(item) || pbIsZCrystal?(item)
      # Key items and hidden machines can't be held
      @scene.pbDisplay(_INTL("{1} can't be held.", getItemName(item, :The)))
    end
    @scene.pbEndScene
    return item
  end

  # UI logic for the item screen when an item is to be used on a Pokémon.
  def pbUseItemScreen
    @scene.pbStartScene(@bag)
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if item == nil
      break if ItemHandlers.hasUseOnPokemonHandler(item)
      # Only usable items can be used
      @scene.pbDisplay(_INTL("{1} can't be used.", getItemName(item, :The)))
    end
    @scene.pbEndScene
    return item
  end

  # UI logic for the item screen for choosing an item
  def pbChooseItemScreen
    oldlastpocket = @bag.lastpocket
    @scene.pbStartScene(@bag)
    item = @scene.pbChooseItem
    @scene.pbEndScene
    @bag.lastpocket = oldlastpocket
    return item
  end

  # UI logic for the item screen for choosing a Berry
  def pbChooseBerryScreen
    oldlastpocket = @bag.lastpocket
    @bag.lastpocket = BERRYPOCKET
    @scene.pbStartScene(@bag)
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if item.nil?

      itemname = getItemName(item)
      if !pbIsBerry?(item)
        @scene.pbDisplay(_INTL("That's not a Berry.", itemname))
        next
      else
        break
      end
    end
    @scene.pbEndScene
    @bag.lastpocket = oldlastpocket
    return item
  end

  # UI logic for tossing an item in the item screen.
  def pbTossItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
    storage = $PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage)
    loop do
      item = @scene.pbChooseItem
      break if item.nil?

      if pbIsImportantItem?(item)
        @scene.pbDisplay(_INTL("That's too important to toss out!"))
        next
      end
      qty = storage.pbQuantity(item)
      if qty > 1
        qty = @scene.pbChooseNumber(_INTL("Toss out how many {1}?", getItemName(item, plural: true)), qty)
      end
      if qty > 0
        itemname = getItemName(item, plural: qty > 1, useunit: true)
        if pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
          if !storage.pbDeleteItem(item, qty)
            raise "Can't delete items from storage"
          end

          pbDisplay(_INTL("Threw away {1} {2}.", qty, itemname))
        end
      end
    end
    @scene.pbEndScene
  end

  # UI logic for withdrawing an item in the item screen.
  def pbWithdrawItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
    storage = $PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage)
    loop do
      item = @scene.pbChooseItem
      break if item.nil?

      commands = [_INTL("Withdraw"), _INTL("Give"), _INTL("Cancel")]
      itemname = getItemName(item)
      command = @scene.pbShowCommands(_INTL("{1} is selected.", itemname), commands)
      if command == 0
        qty = storage.pbQuantity(item)
        if qty > 1
          qty = @scene.pbChooseNumber(_INTL("How many do you want to withdraw?"), qty)
        end
        if qty > 0
          if !@bag.pbCanStore?(item, qty)
            pbDisplay(_INTL("There's no more room in the Bag."))
          else
            pbDisplay(_INTL("Withdrew {1} {2}.", qty, getItemName(item, plural: qty > 1, useunit: true)))
            if !storage.pbDeleteItem(item, qty)
              raise "Can't delete items from storage"
            end
            if !@bag.pbStoreItem(item, qty)
              raise "Can't withdraw items from storage"
            end
          end
        end
      elsif command == 1 # Give
        if $Trainer.pokemonCount == 0
          @scene.pbDisplay(_INTL("There is no Pokémon."))
          return nil
        elsif pbIsImportantItem?(item)
          @scene.pbDisplay(_INTL("{1} can't be held.", getItemName(item, :The)))
        else
          pbFadeOutIn(99999) {
            sscene = PokemonScreen_Scene.new
            sscreen = PokemonScreen.new(sscene, $Trainer.party)
            if sscreen.pbPokemonGiveScreen(item)
              # If the item was held, delete the item from storage
              if !storage.pbDeleteItem(item, 1)
                raise "Can't delete item from storage"
              end
            end
            @scene.pbRefresh
          }
        end
      end
    end
    @scene.pbEndScene
  end

  # UI logic for depositing an item in the item screen.
  def pbDepositItemScreen
    @scene.pbStartScene(@bag)
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
    storage = $PokemonGlobal.pcItemStorage
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if item.nil?

      qty = @bag.pbQuantity(item)
      if qty > 1
        qty = @scene.pbChooseNumber(_INTL("How many do you want to deposit?"), qty)
      end
      if qty > 0
        if !storage.pbCanStore?(item, qty)
          pbDisplay(_INTL("There's no room to store items."))
        elsif pbIsKeyItem?(item) || pbIsZCrystal?(item)
          pbDisplay(_INTL("You can't store a Key Item!"))
        else
          pbDisplay(_INTL("Deposited {1} {2}.", qty, getItemName(item, plural: qty > 1, useunit: true)))
          if !@bag.pbDeleteItem(item, qty)
            raise "Can't delete items from bag"
          end
          if !storage.pbStoreItem(item, qty)
            raise "Can't deposit items to storage"
          end
        end
      end
    end
    @scene.pbEndScene
  end

  def pbStartScreen
    @scene.pbStartScene(@bag)
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if item.nil?

      cmdRead = -1
      cmdUse = -1
      cmdGive = -1
      cmdToss = -1
      cmdRegister = -1
      cmdFavorite = -1
      cmdDebug = -1
      commands = []

      # Generate command list
      commands[cmdRead = commands.length] = _INTL("Read") if pbIsMail?(item)
      commands[cmdUse = commands.length] = _INTL("Use") if ItemHandlers.hasOutHandler(item) || (pbIsTM?(item) && $Trainer.party.length > 0)
      commands[cmdGive = commands.length] = _INTL("Give") if $Trainer.party.length > 0 && !pbIsImportantItem?(item)
      commands[cmdToss = commands.length] = _INTL("Toss") if !pbIsImportantItem?(item) || ($DEBUG && Input.press?(Input::CTRL))
      if @bag.registeredItems.include?(item)
        commands[cmdRegister = commands.length] = _INTL("Unregister")
      elsif ItemHandlers.hasKeyItemHandler(item) && pbIsKeyItem?(item)
        commands[cmdRegister = commands.length] = _INTL("Register")
      end
      commands[cmdFavorite = commands.length] = @bag.favoriteItems.include?(item) ? _INTL("Unfavorite") : _INTL("Favorite")
      commands[cmdDebug = commands.length] = _INTL("Debug") if $DEBUG || ($game_switches[:MiniDebug_Pass] && !pbIsImportantItem?(item) && !$cache.items[item].checkFlag?(:crystal))
      commands[commands.length] = _INTL("Cancel")

      # Show commands generated above
      itemname = getItemName(item) # Get item name
      command = @scene.pbShowCommands(_INTL("{1} is selected.", itemname), commands)

      if cmdUse >= 0 && command == cmdUse # Use item
        ret = pbUseItem(@bag, item, @scene)
        # 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
        break if ret == 2 # End screen

        @scene.pbRefresh
        next
      elsif cmdRead >= 0 && command == cmdRead # Read mail
        pbFadeOutIn(99999) {
          pbDisplayMail(PokemonMail.new(item, "", ""))
        }
      elsif cmdRegister >= 0 && command == cmdRegister # Register key item
        if @bag.pbIsRegistered?(item)
          @bag.pbUnregisterItem(item)
        else
          @bag.pbRegisterItem(item)
        end
        @scene.pbRefresh
      elsif cmdGive >= 0 && command == cmdGive # Give item to Pokémon
        if $Trainer.pokemonCount == 0
          @scene.pbDisplay(_INTL("There is no Pokémon."))
        elsif pbIsImportantItem?(item)
          @scene.pbDisplay(_INTL("{1} can't be held.", getItemName(item, :The)))
        elsif hasActiveRentalTeam?()
          @scene.pbDisplay(_INTL("You are not allowed to change the rental team's items."))
        else
          # Give item to a Pokémon
          pbFadeOutIn(99999) {
            sscene = PokemonScreen_Scene.new
            sscreen = PokemonScreen.new(sscene, $Trainer.party)
            sscreen.pbPokemonGiveScreen(item)
            @scene.pbRefresh
          }
        end
      elsif cmdToss >= 0 && command == cmdToss # Toss item
        qty = @bag.pbQuantity(item)
        helptext = _INTL("Toss out how many {1}?", getItemName(item, plural: true))
        qty = @scene.pbChooseNumber(helptext, qty)
        if qty > 0
          itemname = getItemName(item, plural: qty > 1, useunit: true)
          if pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
            pbDisplay(_INTL("Threw away {1} {2}.", qty, itemname))
            qty.times { @bag.pbDeleteItem(item) }
          end
        end
      elsif cmdFavorite >= 0 && command == cmdFavorite # Favorite item
        if @bag.isFavorite?(item)
          @bag.removeFavorite(item)
        else
          @bag.addFavorite(item)
        end
        @scene.pbRefresh
      elsif cmdDebug >= 0 && command == cmdDebug # Debug menu (change quantity)
        qty = @bag.pbQuantity(item)
        newqty = @scene.pbChooseNumber(_INTL("Choose new quantity of {1} (max. {2}).", getItemName(item, plural: true), BAGMAXPERSLOT), BAGMAXPERSLOT)
        next if newqty == 0 # Cancel
        if newqty > qty
          @bag.pbStoreItem(item, newqty - qty)
        elsif newqty < qty
          @bag.pbDeleteItem(item, qty - newqty)
        end
        @scene.pbRefresh
      end
    end
    @scene.pbEndScene
    return item
  end
end

################################################################################
# PC item storage.
################################################################################
class Window_PokemonItemStorage < Window_DrawableCommand
  attr_reader :bag
  attr_reader :pocket
  attr_reader :sortIndex

  def sortIndex=(value)
    @sortIndex = value
    refresh
  end

  def initialize(bag, x, y, width, height)
    @bag = bag
    @sortIndex = -1
    @adapter = PokemonMartAdapter.new
    super(x, y, width, height)
    self.windowskin = nil
  end

  def item
    item = @bag[self.index]
    return item ? item[0] : 0
  end

  def itemCount
    return @bag.length + 1
  end

  def drawItem(index, count, rect)
    textpos = []
    rect = drawCursor(index, rect)
    ypos = rect.y
    if index == @bag.length
      textpos.push([_INTL("CANCEL"), rect.x, ypos, false, self.baseColor, self.shadowColor])
    else
      item = @bag[index][0]
      itemname = @adapter.getDisplayName(item)
      qty = _ISPRINTF("x{1: 2d}", @bag[index][1])
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 2
      colors = index == @sortIndex ? Window_PokemonBag::SortHighlightColors : [self.baseColor, self.shadowColor]
      textpos.push([itemname, rect.x, ypos, false, *colors])
      if shouldShowQuantity?(item)
        textpos.push([qty, xQty, ypos, false, *colors])
      end
    end
    pbDrawTextPositions(self.contents, textpos)
  end
end

class ItemStorageScene
  ## Configuration
  ITEMLISTBASECOLOR   = Color.new(88, 88, 80)
  ITEMLISTSHADOWCOLOR = Color.new(168, 184, 184)
  ITEMTEXTBASECOLOR   = Color.new(248, 248, 248)
  ITEMTEXTSHADOWCOLOR = Color.new(0, 0, 0)
  TITLEBASECOLOR      = Color.new(248, 248, 248)
  TITLESHADOWCOLOR    = Color.new(0, 0, 0)
  ITEMSVISIBLE        = 7

  def initialize(title)
    @title = title
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @bag = bag
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Bag/pcItembg")
    @sprites["icon"] = IconSprite.new(26, 310, @viewport)
    # Item list
    @sprites["itemwindow"] = Window_PokemonItemStorage.new(@bag, 98, 14, 334, 32 + ITEMSVISIBLE * 32)
    @sprites["itemwindow"].viewport = @viewport
    @sprites["itemwindow"].index = 0
    @sprites["itemwindow"].baseColor = ITEMLISTBASECOLOR
    @sprites["itemwindow"].shadowColor = ITEMLISTSHADOWCOLOR
    @sprites["itemwindow"].refresh
    # Title
    @sprites["pocketwindow"] = BitmapSprite.new(88, 64, @viewport)
    @sprites["pocketwindow"].x = 14
    @sprites["pocketwindow"].y = 16
    pbSetNarrowFont(@sprites["pocketwindow"].bitmap)
    # Item description
    @sprites["itemtextwindow"] =
      Window_UnformattedTextPokemon.newWithSize("", 84, 270, Graphics.width - 84, 128, @viewport)
    @sprites["itemtextwindow"].baseColor = ITEMTEXTBASECOLOR
    @sprites["itemtextwindow"].shadowColor = ITEMTEXTSHADOWCOLOR
    @sprites["itemtextwindow"].windowskin = nil
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    # Letter-by-letter message window
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible = false
    @sprites["msgwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefresh
    bm = @sprites["pocketwindow"].bitmap
    # Draw title at upper left corner ("Toss Item/Withdraw Item")
    drawTextEx(bm, 0, 0, bm.width, 2, @title, TITLEBASECOLOR, TITLESHADOWCOLOR)
    itemwindow = @sprites["itemwindow"]
    # Draw item icon
    filename = pbItemIconFile(itemwindow.item)
    @sprites["icon"].setBitmap(filename)
    # Get item description
    drawBagItemDescription(@sprites["itemtextwindow"], itemwindow.item)
    itemwindow.refresh
  end

  def pbChooseItem
    pbRefresh
    @sprites["helpwindow"].visible = false
    itemwindow = @sprites["itemwindow"]
    itemwindow.refresh
    pbActivateWindow(@sprites, "itemwindow") {
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        self.update
        if itemwindow.item != olditem
          self.pbRefresh
        end
        if Input.trigger?(Input::X)
          counter = 1
          while counter < @bag.items.length
            index = counter
            while index > 0
              indexPrev = index - 1
              firstName  = getItemName(@bag.items[indexPrev])
              secondName = getItemName(@bag.items[index])
              if firstName > secondName
                aux = @bag.items[index]
                @bag.items[index]     = @bag.items[indexPrev]
                @bag.items[indexPrev] = aux
              end
              index -= 1
            end
            counter += 1
          end
          pbRefresh
        end
        if Input.trigger?(Input::B)
          return nil
        end

        if Input.trigger?(Input::C)
          if itemwindow.index < @bag.length
            pbRefresh
            return @bag[itemwindow.index]
          else
            return nil
          end
        end
      end
    }
  end

  def pbChooseNumber(helptext, maximum)
    return UIHelper.pbChooseNumber(
      @sprites["helpwindow"], helptext, maximum
    ) { update }
  end

  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { update }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { update }
  end

  def pbShowCommands(helptext, commands)
    return UIHelper.pbShowCommands(
      @sprites["helpwindow"], helptext, commands
    ) { update }
  end
end

class WithdrawItemScene < ItemStorageScene
  def initialize
    super(_INTL("Withdraw\nItem"))
  end
end

class TossItemScene < ItemStorageScene
  def initialize
    super(_INTL("Toss\nItem"))
  end
end

class PCItemStorage
  MAXSIZE = 500
  MAXPERSLOT = 999

  def initialize
    @items = []
    # Start storage with a Potion
    ItemStorageHelper.pbStoreItem(@items, MAXSIZE, MAXPERSLOT, :POTION, 1)
  end

  def items
    return @items
  end

  def empty?
    return @items.length == 0
  end

  def length
    @items.length
  end

  def [](i)
    @items[i]
  end

  def getItem(index)
    if index < 0 || index >= @items.length
      return nil
    else
      return @items[index]
    end
  end

  def getCount(index)
    if index < 0 || index >= @items.length
      return nil
    else
      return @items[index][1]
    end
  end

  def pbQuantity(item)
    return ItemStorageHelper.pbQuantity(@items, MAXSIZE, item)
  end

  def pbDeleteItem(item, qty = 1)
    return ItemStorageHelper.pbDeleteItem(@items, MAXSIZE, item, qty)
  end

  def pbCanStore?(item, qty = 1)
    return ItemStorageHelper.pbCanStore?(@items, MAXSIZE, MAXPERSLOT, item, qty)
  end

  def pbStoreItem(item, qty = 1)
    return ItemStorageHelper.pbStoreItem(@items, MAXSIZE, MAXPERSLOT, item, qty)
  end
end

################################################################################
# Common UI functions used in both the Bag and item storage screens.
# Allows the user to choose a number.  The window _helpwindow_ will
# display the _helptext_.
################################################################################
module UIHelper
  def self.pbChooseNumber(helpwindow, helptext, maximum)
    oldvisible = helpwindow.visible
    helpwindow.visible = true
    helpwindow.text = helptext
    helpwindow.letterbyletter = false
    tts(helptext, true)
    curnumber = 1
    ret = 0
    using_block(numwindow = Window_UnformattedTextPokemon.new("x000")) {
      numwindow.viewport = helpwindow.viewport
      numwindow.letterbyletter = false
      numwindow.text = _ISPRINTF("x{1:03d}", curnumber)
      tts(curnumber)
      numwindow.resizeToFit(numwindow.text, 480)
      pbBottomRight(numwindow) # Move number window to the bottom right
      helpwindow.resizeHeightToFit(helpwindow.text, 480 - numwindow.width)
      pbBottomLeft(helpwindow) # Move help window to the bottom left
      loop do
        Graphics.update
        Input.update
        numwindow.update
        block_given? ? yield : helpwindow.update
        changed = false
        if Input.repeat?(Input::LEFT)
          curnumber -= 10
          curnumber = 1 if curnumber < 1
          changed = true
        elsif Input.repeat?(Input::RIGHT)
          curnumber += 10
          curnumber = maximum if curnumber > maximum
          changed = true
        elsif Input.repeat?(Input::UP)
          curnumber += 1
          curnumber = 1 if curnumber > maximum
          changed = true
        elsif Input.repeat?(Input::DOWN)
          curnumber -= 1
          curnumber = maximum if curnumber < 1
          changed = true
        elsif Input.trigger?(Input::C)
          ret = curnumber
          pbPlayDecisionSE()
          break
        elsif Input.trigger?(Input::B)
          ret = 0
          pbPlayCancelSE()
          break
        end
        if changed
          pbPlayCursorSE()
          numwindow.text = _ISPRINTF("x{1:03d}", curnumber)
          tts(curnumber, true)
        end
      end
    }
    helpwindow.visible = oldvisible
    return ret
  end

  def self.pbDisplayStatic(msgwindow, message)
    oldvisible = msgwindow.visible
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.width = Graphics.width
    msgwindow.resizeHeightToFit(message, Graphics.width)
    msgwindow.text = message
    pbBottomRight(msgwindow)
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        break
      end
      if Input.trigger?(Input::C)
        break
      end

      block_given? ? yield : msgwindow.update
    end
    msgwindow.visible = oldvisible
    Input.update
  end

  # Letter by letter display of the message _msg_ by the window _helpwindow_.
  def self.pbDisplay(helpwindow, msg, brief)
    cw = helpwindow
    cw.letterbyletter = true
    cw.text = msg + TextPlaceholders::InputPause
    pbBottomLeftLines(cw, 2)
    oldvisible = cw.visible
    cw.visible = true
    tts(msg, true)
    loop do
      Graphics.update
      Input.update
      block_given? ? yield : cw.update

      if brief && !cw.busy?
        cw.visible = oldvisible
        return
      end

      inputcheck = Input.trigger?(Input::B) || Input.trigger?(Input::C)
      if !cw.busy? && inputcheck
        cw.visible = oldvisible
        pbPlayDecisionSE()
        return
      end
      cw.check_for_resume(inputcheck)
    end
  end

  # Letter by letter display of the message _msg_ by the window _helpwindow_,
  # used to ask questions.  Returns true if the user chose yes, false if no.
  def self.pbConfirm(helpwindow, msg)
    dw = helpwindow
    oldvisible = dw.visible
    dw.letterbyletter = true
    dw.text = msg
    dw.visible = true
    pbBottomLeftLines(dw, 2)
    tts(msg, true)
    commands = [_INTL("Yes"), _INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.viewport = helpwindow.viewport
    pbBottomRight(cw)
    cw.y -= dw.height
    cw.index = 0
    loop do
      cw.visible = !dw.busy?
      Graphics.update
      Input.update
      cw.update
      block_given? ? yield : dw.update

      inputcheck = Input.trigger?(Input::B) || Input.trigger?(Input::C)
      if !dw.busy? && inputcheck
        confirmed = Input.trigger?(Input::C) && cw.index == 0
        cw.dispose
        dw.visible = oldvisible
        confirmed ? pbPlayDecisionSE() : pbPlayCancelSE()
        return confirmed
      end
      dw.check_for_resume(inputcheck)
    end
  end

  def self.pbShowCommands(helpwindow, helptext, commands)
    ret = -1
    oldvisible = helpwindow.visible
    helpwindow.visible = helptext ? true : false
    helpwindow.letterbyletter = false
    helpwindow.text = helptext ? helptext : ""
    cmdwindow = Window_CommandPokemon.new(commands)
    begin
      cmdwindow.viewport = helpwindow.viewport
      pbBottomRight(cmdwindow)
      helpwindow.resizeHeightToFit(helpwindow.text, 480 - cmdwindow.width)
      pbBottomLeft(helpwindow)
      loop do
        Graphics.update
        Input.update
        yield
        cmdwindow.update
        if Input.trigger?(Input::B)
          ret = -1
          pbPlayCancelSE()
          break
        end
        if Input.trigger?(Input::C)
          ret = cmdwindow.index
          pbPlayDecisionSE()
          break
        end
      end
    ensure
      cmdwindow.dispose if cmdwindow
    end
    helpwindow.visible = oldvisible
    return ret
  end
end

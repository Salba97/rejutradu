# Abstraction layer for Pokemon Essentials
class PokemonMartAdapter
  def getMoney
    return $Trainer.money
  end

  def setMoney(value)
    $Trainer.money = value
  end

  def getInventory()
    return $PokemonBag
  end

  def getPrice(item, selling = false)
    if selling
      return $game_temp.mart_sell[item] if $game_temp.mart_sell[item]
    else
      return $game_temp.mart_buy[item] if $game_temp.mart_buy[item]
    end
    return $cache.items[item].price
  end

  def getItemIcon(item)
    return pbItemIconFile(item)
  end

  def getItemIconRect(item)
    return Rect.new(0, 0, 48, 48)
  end

  def getDisplayName(item, bag: false, short: false)
    itemname = getItemName(item, short: short)
    if pbIsTM?(item)
      machine = pbGetTM(item)
      itemname = itemname + " " + getMoveName(machine)
    end
    if bag
      itemname += " " + ($game_switches[:Exp_All_On] ? _INTL("(On)") : _INTL("(Off)")) if item == :EXPALL
      itemname += " " + ($game_switches[:Exp_All_Plus_On] ? _INTL("(On)") : _INTL("(Off)")) if item == :EXPALLPLUS
    end
    return itemname
  end

  def getName(item)
    return getItemName(item)
  end

  def getDisplayPrice(item, selling = false)
    price = getPrice(item, selling)
    return getPurchaseDisplay(price)
  end

  def getDescription(item)
    return _INTL("Quit shopping.") if !item

    return getItemDescription(item)
  end

  def addItem(item)
    return $PokemonBag.pbStoreItem(item)
  end

  def getQuantity(item)
    return $PokemonBag.pbQuantity(item)
  end

  def canSell?(item)
    return getPrice(item, true) > 0 && !pbIsImportantItem?(item)
  end

  def showQuantity?(item)
    return !pbIsImportantItem?(item)
  end

  def removeItem(item)
    return $PokemonBag.pbDeleteItem(item)
  end
end

class ComplexPokemonMartAdapter
  attr_reader :priceTypes

  def initialize(inventory)
    @baseInventory = inventory

    @baseStock = []
    @priceTypes = []

    rebuildStock
  end

  def rebuildStock
    @baseStock.clear
    @priceTypes.clear

    for item in @baseInventory
      next if !item.shouldShowItem?

      @baseStock.push(item)
      currency = item.currency
      if [:REDSHARD, :BLUESHARD, :GREENSHARD, :YELLOWSHARD, :PURPLESHARD].include?(currency)
        @priceTypes.push(:Shards)
      else
        @priceTypes.push(currency)
      end
    end

    @priceTypes.uniq!
    return @baseStock
  end

  def getStock
    return @baseStock
  end

  def getPriceType(item)
    return item.currency
  end

  def skipPurchase?(item)
    return item.skipPurchase?
  end

  def getPurchaseMessage(messages, item, price, quantity = 0)
    if quantity == 0
      message = item.purchase_confirm_single || messages[:purchase_confirm_single]
      return _INTL(pbGetMessage(:MartMessages, message), getDisplayName(item), formatPrice(price, item), formatPrice(price, item, true))
    else
      message = item.purchase_confirm_multiple || messages[:purchase_confirm_multiple]
      return _INTL(pbGetMessage(:MartMessages, message), getName(item), pbCommaNumber(quantity), formatPrice(price, item), formatPrice(price, item, true))
    end
  end

  def getQuantitySelectMessage(messages, item)
    message = item.choose_quantity || messages[:choose_quantity]
    return _INTL(pbGetMessage(:MartMessages, message), getName(item))
  end

  def getSuccessMessage(messages, item)
    return pbGetMessage(:MartMessages, item.success_message) if item.success_message

    priceType = getPriceType(item)
    case priceType
      when :Money       then return pbGetMessage(:MartMessages, messages[:success_money])
      when :RedEssence  then return pbGetMessage(:MartMessages, messages[:success_re])
      when :Coins       then return pbGetMessage(:MartMessages, messages[:success_coins])
      when :PuppetCoins then return pbGetMessage(:MartMessages, messages[:success_puppet])
      when :AP          then return pbGetMessage(:MartMessages, messages[:success_ap])
      when :BP          then return pbGetMessage(:MartMessages, messages[:success_bp])
      when :Credits     then return pbGetMessage(:MartMessages, messages[:success_credits])
      else                   return pbGetMessage(:MartMessages, messages[:success_items])
    end
    return ""
  end

  def getMoney(item)
    priceType = getPriceType(item)
    source = $cache.currencies[priceType]&.type
    case source
      when :Money     then return $Trainer.money
      when :Coins     then return $PokemonGlobal.coins
      when :Variable  then return $game_variables[priceType]
      else                 return $PokemonBag.pbQuantity(priceType)
    end
  end

  def setMoney(value, item)
    priceType = getPriceType(item)
    source = $cache.currencies[priceType]&.type
    case source
      when :Money     then $Trainer.money = value
      when :Coins     then $PokemonGlobal.coins = value
      when :Variable  then $game_variables[priceType] = value
      else
        current = $PokemonBag.pbQuantity(priceType)
        if value < current
          $PokemonBag.pbDeleteItem(priceType, current - value)
        elsif value > current
          $PokemonBag.pbStoreItem(priceType, value - current)
        end
    end
  end

  def getPrice(item, selling = false)
    if selling
      return $game_temp.mart_sell[item] if $game_temp.mart_sell[item]
      return $cache.items[item].price
    end

    return item.price
  end

  def getItemIcon(item)
    icon = item.nil? ? "Graphics/Icons/Item/itemBack" : item.getIcon
    icon = RPG::Cache.load_bitmap(icon) if icon.is_a?(String)
    return icon
  end

  def getItemIconRect(item)
    return Rect.new(0, 0, 48, 48) if !item
    return item.getIconRect
  end

  def getDisplayName(item)
    return item.getDisplayName
  end

  def getTrueQuantity(item, quantity = 1)
    return item.getTrueQuantity(quantity)
  end

  def getMaxQuantity(item)
    return item.getMaxQuantity
  end

  def getName(item)
    return item.getName
  end

  def formatPrice(price, item, fancy = false)
    return _INTL("Paid") if skipPurchase?(item)
    return _INTL("Free") if price == 0

    currency = getPriceType(item)
    return getPurchaseDisplay(price, shorthand: !fancy, currency: currency) if $cache.currencies.key?(currency) && !item.getCurrencyShortname

    formatter = fancyformatter = getItemName(currency)
    plural = nil
    fancyplural = getItemName(currency, plural: true)
    formatter = plural if price > 1 && plural
    formatter = item.getCurrencyShortname if item.getCurrencyShortname
    formatter = "{1} " + formatter
    fancyformatter = "{1} " + fancyformatter
    fancyplural = "{1} " + fancyplural
    number = pbCommaNumber(price)
    return _INTL(price == 1 ? fancyformatter : fancyplural, number) if fancy
    return _INTL(formatter, number)
  end

  def getDisplayPrice(item, selling = false)
    return formatPrice(getPrice(item, selling), item)
  end

  def getDescription(item)
    return _INTL("Quit shopping.") if !item
    return item.getDescription
  end

  def addItem(item)
    ret = item.add
    if ret.nil?
      dp("Could not add #{item.inspect}. Please report this.")
    end
    return ret
  end

  def afterPurchase(scene, item, amount)
    item.handlePurchase(scene, amount)
  end

  def getQuantity(item)
    return item.getQuantity
  end

  def removeItem(item)
    return item.remove
  end

  def showQuantity?(item)
    return item.showQuantity?
  end
end

###################

class Window_PokemonMart < Window_DrawableCommand
  BASE_COLOR = LightColorArrays[:Default]
  CANCEL_COLOR = LightColorArrays[:Gray]
  ICON_WIDTH = 48
  ICON_HEIGHT = ICON_WIDTH

  def initialize(stock, adapter, x, y, width, height, viewport = nil)
    @stock = stock
    @adapter = adapter
    super(x, y, width, height, viewport)
    @baseColor = BASE_COLOR[0]
    @shadowColor = BASE_COLOR[1]
    self.windowskin = nil
  end

  def getCursorGraphic
    return Reborn ? "Graphics/Pictures/Mart/martSel" : "Graphics/Pictures/martSel"
  end

  def itemCount
    return @stock.length + 1
  end

  def item
    return self.index >= @stock.length ? nil : @stock[self.index]
  end

  def drawItem(index, count, rect)
    textpos = []
    rect = drawCursor(index, rect)
    ypos = rect.y
    if index == count - 1
      textpos.push([_INTL("Cancel"), rect.x, ypos + 2, false, *CANCEL_COLOR])
    else
      item = @stock[index]
      itemname = @adapter.getDisplayName(item)
      qty = @adapter.getDisplayPrice(item)
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 2 - 16
      textpos.push([itemname, rect.x, ypos + 2, false, self.baseColor, self.shadowColor])
      textpos.push([qty, xQty, ypos + 2, false, *currencyColors(item)])
    end
    pbDrawTextPositions(self.contents, textpos)
  end

  def currencyColors(item)
    return CANCEL_COLOR if @adapter.skipPurchase?(item)
    symbol = nil
    case @adapter.getPriceType(item)
      when :REDSHARD then symbol = :ShardRed
      when :BLUESHARD then symbol = :ShardBlue
      when :GREENSHARD then symbol = :ShardGreen
      when :YELLOWSHARD then symbol = :ShardYellow
      when :PURPLESHARD then symbol = :ShardPurple
    end
    colors = Reborn ? ColorArrays : LightColorArrays # Reborn mart UI uses dark backgrounds
    return colors[symbol] if symbol
    return [self.baseColor, self.shadowColor]
  end
end

class BuyAdapter # :nodoc:
  def initialize(adapter)
    @adapter = adapter
  end

  def getDisplayName(item)
    @adapter.getDisplayName(item)
  end

  def getDisplayPrice(item)
    @adapter.getDisplayPrice(item, false)
  end

  def getPriceType(item)
    @adapter.getPriceType(item)
  end

  def skipPurchase?(item)
    @adapter.skipPurchase?(item)
  end

  def isSelling?
    return false
  end
end

class SellAdapter # :nodoc:
  def initialize(adapter)
    @adapter = adapter
  end

  def getDisplayName(item)
    @adapter.getDisplayName(item)
  end

  def getDisplayPrice(item)
    if @adapter.showQuantity?(item)
      return sprintf("x%d", @adapter.getQuantity(item))
    else
      return ""
    end
  end

  def getPriceType(item)
    @adapter.getPriceType(item)
  end

  def isSelling?
    return true
  end
end

class PokemonMartScene
  def initialize(hasPicture, clampBottom, background)
    @hasPicture = hasPicture
    @clampBottom = clampBottom
    @background = background
  end

  def playSoundEventsForText(msg)
    while msg[/(?:\\[Ss][Ee]\[([^\]]*)\])/i]
      msg = $~.pre_match + $~.post_match
      pbSEPlay(pbStringToAudioFile($1))
    end
    return msg
  end

  def update
    pbUpdateSpriteHash(@sprites)
    @subscene.update if @subscene
  end

  def activeAdapter
    return @buying ? @adapter : @sellAdapter
  end

  def cleanupHelpWindow; end # Hook for dark theme

  def pbChooseNumber(helptext, item, maximum)
    curnumber = 1
    ret = 0
    helpwindow = @sprites["helpwindow"]
    itemprice = activeAdapter.getPrice(item, !@buying)
    itemprice /= 2 if !@buying
    itemprice = (itemprice * 0.25).floor if !@buying && $game_switches[:Penniless_Mode]
    pbDisplay(helptext, true)
    using_block(numwindow = Window_AdvancedTextPokemon.new("")) { # Showing number of items
      qty = activeAdapter.getQuantity(item)
      using_block(inbagwindow = Window_AdvancedTextPokemon.new("")) { # Showing quantity in bag
        pbPrepareWindow(numwindow)
        pbPrepareWindow(inbagwindow)
        numwindow.viewport = @viewport
        numwindow.width = 224
        numwindow.height = 64
        numwindow.setDefaultTextColors

        if @buying
          quantity = ->(item, curnumber) {
            next activeAdapter.getTrueQuantity(item, curnumber)
          }
          formatPrice = ->(item, curnumber, price, forTTS) {
            next activeAdapter.formatPrice(curnumber * price, item, forTTS)
          }

          if activeAdapter.showQuantity?(item)
            inbagwindow.visible = @buying
            inbagwindow.viewport = @viewport
            inbagwindow.width = 190
            inbagwindow.height = 64
            inbagwindow.setDefaultTextColors

            if item.is_a?(CurrencyStock) && item.type == :Coins
              inbagwindow.text = _ISPRINTF("In Case:<r>{1:d}  ", qty)
              tts(_INTL("You have {1} {2}", qty, getCurrencyName(:Coins)))
            elsif item.is_a?(CurrencyStock) && item.type == :PuppetCoins
              inbagwindow.text = _ISPRINTF("Inside:<r>{1:d}  ", qty)
              tts(_INTL("You have {1} {2}", qty, getCurrencyName(:Coins)))
            else
              inbagwindow.text = _ISPRINTF("In Bag:<r>{1:d}  ", qty)
              tts(_INTL("In Bag: {1}", qty))
            end
          else
            inbagwindow.visible = false
          end
        else
          quantity = ->(item, curnumber) {
            next curnumber
          }
          formatPrice = ->(item, curnumber, price, forTTS) {
            next getPurchaseDisplay((curnumber * price), commas: forTTS)
          }

          inbagwindow.text = _ISPRINTF("In Bag:<r>{1:d}  ", qty)
          tts(_INTL("In Bag: {1}", qty))
        end

        numwindow.text = _INTL("x{1}<r>{2}", quantity.call(item, curnumber), formatPrice.call(item, curnumber, itemprice, false))
        pbBottomRight(numwindow)
        numwindow.y -= helpwindow.height
        pbBottomLeft(inbagwindow)
        inbagwindow.y -= helpwindow.height
        loop do
          Graphics.update
          Input.update
          numwindow.update
          inbagwindow.update
          self.update
          curnumberbefore = curnumber
          if Input.repeat?(Input::LEFT)
            pbPlayCursorSE()
            curnumber -= 10
            curnumber = 1 if curnumber < 1
          elsif Input.repeat?(Input::RIGHT)
            pbPlayCursorSE()
            curnumber += 10
            curnumber = maximum if curnumber > maximum
          elsif Input.repeat?(Input::UP)
            pbPlayCursorSE()
            curnumber += 1
            curnumber = 1 if curnumber > maximum
          elsif Input.repeat?(Input::DOWN)
            pbPlayCursorSE()
            curnumber -= 1
            curnumber = maximum if curnumber < 1
          elsif Input.trigger?(Input::C)
            pbPlayDecisionSE()
            ret = curnumber
            break
          elsif Input.trigger?(Input::B)
            pbPlayCancelSE()
            ret = 0
            break
          end
          if curnumber != curnumberbefore
            tts(curnumber.to_s)
            numwindow.text = _INTL("x{1}<r>{2}", quantity.call(item, curnumber), formatPrice.call(item, curnumber, itemprice, false))
            tts(formatPrice.call(item, curnumber, itemprice, true))
          end
        end
      }
    }
    helpwindow.visible = false
    return ret
  end

  def pbPrepareWindow(window)
    window.visible = true
    window.letterbyletter = false
  end

  def pbStartBuyOrSellScene(buying, stock, adapter, sellAdapter)
    # Scroll right before showing screen
    pbScrollMap(6, 5, 5) unless @hasPicture
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @stock = stock
    @adapter = adapter
    @sellAdapter = sellAdapter
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(@background || "Graphics/Pictures/martScreen")
    @sprites["icon"] = SpriteWrapper.new(@viewport)
    @sprites["icon"].x = 24
    @sprites["icon"].y = Graphics.height - 72
    winAdapter = buying ? BuyAdapter.new(adapter) : SellAdapter.new(adapter)
    @sprites["itemwindow"] =
      Window_PokemonMart.new(stock, winAdapter, Graphics.width - 316 - 16, 12, 330 + 16, Graphics.height - 126)
    @sprites["itemwindow"].viewport = @viewport
    @sprites["itemwindow"].index = 0
    @sprites["itemwindow"].refresh
    @sprites["itemtextwindow"] = Window_UnformattedTextPokemon.new("")
    pbPrepareWindow(@sprites["itemtextwindow"])
    @sprites["itemtextwindow"].x = 72
    @sprites["itemtextwindow"].y = 270
    @sprites["itemtextwindow"].width = Graphics.width - 72
    @sprites["itemtextwindow"].height = 128
    @sprites["itemtextwindow"].baseColor = Color.new(248, 248, 248)
    @sprites["itemtextwindow"].shadowColor = Color.new(0, 0, 0)
    @sprites["itemtextwindow"].visible = true
    @sprites["itemtextwindow"].viewport = @viewport
    @sprites["itemtextwindow"].windowskin = nil
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["moneywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible = true
    @sprites["moneywindow"].viewport = @viewport
    @sprites["moneywindow"].x = 0
    @sprites["moneywindow"].y = @clampBottom ? Graphics.height - 196 : 0
    @sprites["moneywindow"].width = 190
    @sprites["moneywindow"].height = 96
    @sprites["moneywindow"].setDefaultTextColors
    pbDeactivateWindows(@sprites)
    @buying = buying
    pbRefresh
    Graphics.frame_reset
  end

  def pbStartBuyScene(stock, adapter, sellAdapter)
    pbStartBuyOrSellScene(true, stock, adapter, sellAdapter)
  end

  def pbStartSellScene(bag, adapter, sellAdapter)
    if $PokemonBag
      pbStartSellScene2(bag, adapter, sellAdapter)
    else
      pbStartBuyOrSellScene(false, bag, adapter, sellAdapter)
    end
  end

  def pbStartSellScene2(bag, adapter, sellAdapter)
    @subscene = PokemonBag_Scene.new
    @adapter = adapter
    @sellAdapter = sellAdapter
    @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport2.z = 99999
    for j in 0..17
      col = Color.new(0, 0, 0, j * 15)
      @viewport2.color = col
      Graphics.update
      Input.update
    end
    @subscene.pbStartScene(bag)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["moneywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible = false
    @sprites["moneywindow"].viewport = @viewport
    @sprites["moneywindow"].x = 0
    @sprites["moneywindow"].y = 0
    @sprites["moneywindow"].width = 186
    @sprites["moneywindow"].height = 96
    @sprites["moneywindow"].setDefaultTextColors
    pbDeactivateWindows(@sprites)
    @buying = false
    pbRefresh
  end

  def pbShowMoney
    @sprites["moneywindow"].visible = true
    pbRefresh
    ttsCurrencies
  end

  def pbHideMoney
    @sprites["moneywindow"].visible = false
    pbRefresh
  end

  def pbEndBuyScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    # Scroll left after showing screen
    pbScrollMap(4, 5, 5) unless @hasPicture
  end

  def pbEndSellScene
    if @subscene
      @subscene.pbEndScene
    end
    pbDisposeSpriteHash(@sprites)
    if @viewport2
      for j in 0..17
        col = Color.new(0, 0, 0, (17 - j) * 15)
        @viewport2.color = col
        Graphics.update
        Input.update
      end
      @viewport2.dispose
    end
    @viewport.dispose
    if !@subscene
      pbScrollMap(4, 5, 5)
    end
  end

  def pbDisplay(msg, brief = false)
    msg = playSoundEventsForText(msg)
    cw = @sprites["helpwindow"]
    cw.letterbyletter = true
    cw.text = msg
    tts(msg)
    pbBottomLeftLines(cw, 2)
    cw.visible = true
    i = 0
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      self.update

      if brief && !cw.busy?
        return
      end

      if i == 0 && !cw.busy?
        pbRefresh
      end

      inputcheck = Input.trigger?(Input::B) || Input.trigger?(Input::C)
      cw.check_for_resume(inputcheck)

      if i == 60
        return
      end

      i += 1 if !cw.busy?
    end
  end

  def pbDisplayPaused(msg)
    msg = playSoundEventsForText(msg)
    cw = @sprites["helpwindow"]
    cw.letterbyletter = true
    cw.text = msg
    tts(msg)
    pbBottomLeftLines(cw, 2)
    cw.visible = true
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      wasbusy = cw.busy?
      self.update

      if !cw.busy? && wasbusy
        pbRefresh
      end

      inputcheck = Input.trigger?(Input::B) || Input.trigger?(Input::C)
      if !cw.busy? && inputcheck
        @sprites["helpwindow"].visible = false
        pbPlayDecisionSE()
        return
      end
      cw.check_for_resume(inputcheck)
    end
  end

  def pbConfirm(msg)
    msg = playSoundEventsForText(msg)
    tts(msg)
    dw = @sprites["helpwindow"]
    dw.letterbyletter = true
    dw.text = msg
    dw.visible = true
    pbBottomLeftLines(dw, 2)
    commands = [_INTL("Yes"), _INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.viewport = @viewport
    pbBottomRight(cw)
    cw.y -= dw.height
    cw.index = 0
    pbPlayDecisionSE()
    loop do
      cw.visible = !dw.busy?
      Graphics.update
      Input.update
      cw.update
      self.update

      inputcheck = Input.trigger?(Input::B) || Input.trigger?(Input::C)
      if !dw.busy? && inputcheck
        confirmed = Input.trigger?(Input::C) && cw.index == 0
        cw.dispose
        @sprites["helpwindow"].visible = false
        confirmed ? pbPlayDecisionSE() : pbPlayCancelSE()
        return confirmed
      end
      dw.check_for_resume(inputcheck)
    end
  end

  def pbRefresh
    if !@subscene
      itemwindow = @sprites["itemwindow"]
      @sprites["icon"].bitmap = activeAdapter.getItemIcon(itemwindow.item)
      @sprites["icon"].src_rect = activeAdapter.getItemIconRect(itemwindow.item)
      drawMartItemDescription(@sprites["itemtextwindow"], itemwindow.item)
      itemwindow.refresh
    end
    updateMoneyWindow()
  end

  def updateMoneyWindow
    if @sprites["moneywindow"]
      moneywindow = []

      if @buying
        priceTypes = activeAdapter.priceTypes.clone
      else
        priceTypes = [:Money]
      end

      colors = isDarkWindowskin(@sprites["moneywindow"].windowskin) ? ColorTags : LightColorTags

      if priceTypes.length <= 3
        for type in priceTypes
          moneywindow += getMoneyWindowFormat(type, colors)
        end
      else
        item = @sprites["itemwindow"].item
        moneywindow = getMoneyWindowFormat(item.currency, colors) unless item.nil?
      end

      @sprites["moneywindow"].height = 32 + 32 * moneywindow.size
      @sprites["moneywindow"].y = Graphics.height - 96 - @sprites["moneywindow"].height - 8 if @clampBottom
      @sprites["moneywindow"].text = moneywindow.join("\n")
      @sprites["moneywindow"].visible = !moneywindow.empty?
    end
  end

  def getMoneyWindowFormat(type, colors = LightColorTags)
    moneywindow = []
    case type
      when :Money
        moneywindow.push(getCurrencyDisplay(shorthand: false))
        moneywindow.push(_INTL("<r>{1}", getPurchaseDisplay($Trainer.money)))
      when :RedEssence
        moneywindow.push(getCurrencyDisplay(shorthand: false, currency: :RedEssence))
        moneywindow.push(_INTL("<r>{1}{2}</c3>", colors[:RedEssenceRed], pbCommaNumber($game_variables[:RedEssence])))
      when :Coins
        moneywindow.push(getCurrencyDisplay(shorthand: false, currency: :Coins))
        moneywindow.push(_INTL("<r>{1}", pbCommaNumber($PokemonGlobal.coins)))
      when :PuppetCoins
        moneywindow.push(getCurrencyDisplay(shorthand: false, currency: :PuppetCoins))
        moneywindow.push(_INTL("<r>{1}{2}</c3>", colors[:PuppetPurple], pbCommaNumber($game_variables[:PuppetCoins])))
      when :AP
        moneywindow.push(getCurrencyDisplay(currency: :AP))
        moneywindow.push(_INTL("<r>{1}", pbCommaNumber($game_variables[:AP])))
      when :BP
        moneywindow.push(getCurrencyDisplay(currency: :BP))
        moneywindow.push(_INTL("<r>{1}", pbCommaNumber($game_variables[:BP])))
      when :Shards
        redQuantity = $PokemonBag.pbQuantity(:REDSHARD)
        blueQuantity = $PokemonBag.pbQuantity(:BLUESHARD)
        greenQuantity = $PokemonBag.pbQuantity(:GREENSHARD)
        yellowQuantity = $PokemonBag.pbQuantity(:YELLOWSHARD)

        moneywindow.push(_INTL("Shards:"))
        chars = [redQuantity, blueQuantity, greenQuantity, yellowQuantity].map{ |i| i.to_s }.join.length
        space = " " * (12 - chars)
        moneywindow.push(_INTL(
          "<r>{5}{1}</c3>#{space}{6}{2}</c3>#{space}{7}{3}</c3>#{space}{8}{4}</c3>",
          redQuantity, blueQuantity, greenQuantity, yellowQuantity,
          colors[:ShardRed], colors[:ShardBlue], colors[:ShardGreen], colors[:ShardYellow]
        ))
      else
        currency = $cache.currencies.dig(type)
        display = currency ? getCurrencyDisplay(shorthand: false, currency: type) : "#{getItemName(type, plural: true)}:"
        moneywindow.push(display)
        moneywindow.push(_INTL("<r>{1}", $PokemonBag.pbQuantity(type)))
    end
    return moneywindow
  end

  def ttsCurrencies
    if @buying
      priceTypes = activeAdapter.priceTypes.clone
    else
      priceTypes = [:Money]
    end

    if priceTypes.include?(:Money)
      tts(getCurrencyDisplay(shorthand: false) + " " + getPurchaseDisplay($Trainer.money))
      priceTypes.delete(:Money)
    end

    if priceTypes.include?(:RedEssence)
      tts(getCurrencyDisplay($game_variables[:RedEssence], shorthand: false, commas: false, currency: :RedEssence))
      priceTypes.delete(:RedEssence)
    end

    if priceTypes.include?(:Coins)
      tts(getCurrencyDisplay($PokemonGlobal.coins, shorthand: false, commas: false, currency: :Coins))
      priceTypes.delete(:Coins)
    end

    if priceTypes.include?(:PuppetCoins)
      tts(getCurrencyDisplay($game_variables[:PuppetCoins], shorthand: false, commas: false, currency: :PuppetCoins))
      priceTypes.delete(:PuppetCoins)
    end

    if priceTypes.include?(:AP)
      tts(getCurrencyDisplay($game_variables[:AP], commas: false, currency: :AP))
      priceTypes.delete(:AP)
    end

    if priceTypes.include?(:BP)
      tts(getCurrencyDisplay($game_variables[:BP], commas: false, currency: :BP))
      priceTypes.delete(:BP)
    end

    if priceTypes.include?(:Shards)
      redQuantity = $PokemonBag.pbQuantity(:REDSHARD)
      blueQuantity = $PokemonBag.pbQuantity(:BLUESHARD)
      greenQuantity = $PokemonBag.pbQuantity(:GREENSHARD)
      if Reborn
        finalQuantity = $PokemonBag.pbQuantity(:PURPLESHARD)
        finalColor = getCurrencyShorthand(:PURPLESHARD, false)
      else
        finalQuantity = $PokemonBag.pbQuantity(:YELLOWSHARD)
        finalColor = getCurrencyShorthand(:YELLOWSHARD, false)
      end
      tts(_INTL("Shards: {1} {2}, {3} {4}, {5} {6}, {7} {8}",
        redQuantity, getCurrencyShorthand(:REDSHARD, false), blueQuantity, getCurrencyShorthand(:BLUESHARD, false),
        greenQuantity, getCurrencyShorthand(:GREENSHARD, false), finalQuantity, finalColor))
      priceTypes.delete(:Shards)
    end

    for type in priceTypes
      currency = $cache.currencies.dig(type)
      display = currency ? getCurrencyDisplay(shorthand: false, commas: false, currency: type) : getItemName(type, plural: true)
      tts(_INTL("{1}: {2}", display, $PokemonBag.pbQuantity(type)))
    end
  end

  def pbChooseBuyItem
    itemwindow = @sprites["itemwindow"]
    @sprites["helpwindow"].visible = false
    pbActivateWindow(@sprites, "itemwindow") {
      pbRefresh
      ttsCurrencies
      if !itemwindow.item.nil?
        tts(activeAdapter.getDisplayName(itemwindow.item))
        tts(activeAdapter.formatPrice(activeAdapter.getPrice(itemwindow.item), itemwindow.item, true))
        tts(activeAdapter.getDescription(itemwindow.item))
      else
        tts(_INTL("Quit shopping."))
      end
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        self.update
        if itemwindow.item != olditem
          @sprites["icon"].bitmap = activeAdapter.getItemIcon(itemwindow.item)
          @sprites["icon"].src_rect = activeAdapter.getItemIconRect(itemwindow.item)
          drawMartItemDescription(@sprites["itemtextwindow"], itemwindow.item)
          updateMoneyWindow() if activeAdapter.priceTypes.length > 3
          if !itemwindow.item.nil?
            tts(activeAdapter.getDisplayName(itemwindow.item), true)
            tts(activeAdapter.formatPrice(activeAdapter.getPrice(itemwindow.item), itemwindow.item, true))
            tts(activeAdapter.getDescription(itemwindow.item))
          else
            tts(_INTL("Quit shopping."))
          end

        end
        if Input.trigger?(Input::B)
          return nil
        end

        if Input.trigger?(Input::C)
          if itemwindow.index < @stock.length
            pbRefresh
            return @stock[itemwindow.index]
          else
            return nil
          end
        end
      end
    }
  end

  def pbChooseSellItem
    if @subscene
      return @subscene.pbChooseItem
    else
      return pbChooseBuyItem
    end
  end

  def drawMartItemDescription(sprite, item)
    sprite.text = item.nil? ? _INTL("Quit shopping.") : activeAdapter.getDescription(item)
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
  end
end

#######################################################
class PokemonMartScreen
  def initialize(scene, inventory, messages = {})
    @scene = scene
    @adapter = ComplexPokemonMartAdapter.new(inventory)
    @stock = @adapter.getStock
    @sellAdapter = PokemonMartAdapter.new
    @messages = $cache.marts[:DEFAULT].Messages.merge(messages)
  end

  def pbConfirm(msg)
    return @scene.pbConfirm(msg)
  end

  def pbDisplay(msg)
    return @scene.pbDisplay(msg)
  end

  def pbDisplayPaused(msg)
    return @scene.pbDisplayPaused(msg)
  end

  def empty?
    return @stock.empty?
  end

  def pbBuyScreen
    @scene.pbStartBuyScene(@stock, @adapter, @sellAdapter)
    item = nil
    bought = false
    loop do
      item = @scene.pbChooseBuyItem
      quantity = 0
      break if item.nil?

      itemname = @adapter.getDisplayName(item)
      price = @adapter.getPrice(item)

      next if !pbCheckAffordability(item, price)

      skip = @adapter.skipPurchase?(item)

      if skip
        quantity = 1
        trueQuantity = @adapter.getTrueQuantity(item, quantity)
      elsif !@adapter.showQuantity?(item)
        next if !pbConfirm(@adapter.getPurchaseMessage(@messages, item, price))

        quantity = 1
        trueQuantity = @adapter.getTrueQuantity(item, quantity)
      else
        maxquantity = @adapter.getMaxQuantity(item) - @adapter.getQuantity(item)
        maxquantity /= @adapter.getTrueQuantity(item)
        maxafford = price <= 0 ? maxquantity : @adapter.getMoney(item) / price
        maxafford = maxquantity if maxafford > maxquantity
        if maxafford == 0
          pbBagFullMessage(item)
          next
        end
        quantity = @scene.pbChooseNumber(@adapter.getQuantitySelectMessage(@messages, item), item, maxafford)
        next if quantity == 0

        price *= quantity
        next if !pbCheckAffordability(item, price)

        trueQuantity = @adapter.getTrueQuantity(item, quantity)
        next if !pbConfirm(@adapter.getPurchaseMessage(@messages, item, price, trueQuantity))
      end

      success = false

      added = 0
      trueQuantity.times do
        if !@adapter.addItem(item)
          break
        end
        added += 1
      end
      if added != trueQuantity
        added.times do
          if !@adapter.removeItem(item)
            raise _INTL("Failed to delete stored items")
          end
        end
        pbBagFullMessage(item)
      else
        success = true
      end
      @scene.cleanupHelpWindow if success && item.is_a?(MoveStock)

      if success && !skip
        bought = true
        @adapter.setMoney(@adapter.getMoney(item) - price, item)
        @scene.pbRefresh
        successMessage = @adapter.getSuccessMessage(@messages, item)
        pbDisplayPaused(successMessage) unless successMessage.empty?
        @adapter.afterPurchase(self, item, quantity)

        if item.is_a?(ItemStock)
          if Rejuv && $Trainer.achievements
            $Trainer.achievements.progress(:itemsBought, quantity)
          end
          if $PokemonBag && trueQuantity >= 10 && pbIsPokeBall?(item.item) && item.allowPremierBall
            if trueQuantity < 20 && $PokemonBag.pbStoreItem(:PREMIERBALL)
              pbDisplayPaused(pbGetMessage(:MartMessages, @messages[:premier_one])) unless @messages[:premier_one].empty?
            elsif trueQuantity >= 20 && $PokemonBag.pbStoreItem(:PREMIERBALL, (trueQuantity / 10).floor)
              numballs = (trueQuantity / 10).floor # I could put this in the next line but it would probably slow something down
              pbDisplayPaused(_INTL(pbGetMessage(:MartMessages, @messages[:premier_many]), numballs)) unless @messages[:premier_many].empty?
            end
          end
        end

        @stock = @adapter.rebuildStock
      end
    end
    @scene.pbEndBuyScene
    return bought
  end

  def pbCheckAffordability(item, price)
    return true if @adapter.getMoney(item) >= price
    return true if item.is_a?(MoveStock) && checkTutorMove(item.move)

    priceType = @adapter.getPriceType(item)
    case priceType
      when :Money       then message = pbGetMessage(:MartMessages, @messages[:no_money])
      when :RedEssence  then message = pbGetMessage(:MartMessages, @messages[:no_re])
      when :Coins       then message = pbGetMessage(:MartMessages, @messages[:no_coins])
      when :PuppetCoins then message = pbGetMessage(:MartMessages, @messages[:no_coins])
      when :AP          then message = pbGetMessage(:MartMessages, @messages[:no_ap])
      when :BP          then message = pbGetMessage(:MartMessages, @messages[:no_bp])
      when :Credits     then message = pbGetMessage(:MartMessages, @messages[:no_credits])
      else                   message = _INTL(pbGetMessage(:MartMessages, @messages[:no_items]), getItemName(priceType, plural: true))
    end
    pbDisplayPaused(message) unless message.empty?
    return false
  end

  def pbBagFullMessage(item)
    message = nil
    case item
      when CurrencyStock
        case item.type
          when :PuppetCoins then message = pbGetMessage(:MartMessages, @messages[:full_puppet])
          when :Coins       then message = pbGetMessage(:MartMessages, @messages[:full_coins])
        end
      when ItemStock        then message = pbGetMessage(:MartMessages, @messages[:full_item])
    end
    pbDisplayPaused(message) if message && !message.empty?
  end

  def pbSellScreen
    @scene.pbStartSellScene(@sellAdapter.getInventory, @adapter, @sellAdapter)
    item = nil
    sold = false
    loop do
      item = @scene.pbChooseSellItem
      break if item.nil?

      itemname = @sellAdapter.getDisplayName(item)
      price = @sellAdapter.getPrice(item, true)
      if !@sellAdapter.canSell?(item)
        pbDisplayPaused(_INTL(pbGetMessage(:MartMessages, @messages[:cannot_sell]), itemname)) unless @messages[:cannot_sell].empty?
        next
      end
      qty = @sellAdapter.getQuantity(item)
      next if qty == 0

      @scene.pbShowMoney
      if qty > 1
        qty = @scene.pbChooseNumber(_INTL(pbGetMessage(:MartMessages, @messages[:sell_quantity]), itemname), item, qty)
      end
      if qty == 0
        @scene.pbHideMoney
        next
      end
      price /= 2
      price = (price * 0.25).floor if $game_switches[:Penniless_Mode]
      price *= qty
      if pbConfirm(_INTL(pbGetMessage(:MartMessages, @messages[:sell_confirm]), getPurchaseDisplay(price)))
        sold = true
        @sellAdapter.setMoney(@sellAdapter.getMoney() + price)
        for i in 0...qty
          @sellAdapter.removeItem(item)
        end
        pbDisplayPaused(_INTL(pbGetMessage(:MartMessages, @messages[:sell_success]), getItemName(item, :the), getPurchaseDisplay(price))) unless @messages[:sell_success].empty?
        if Rejuv && $Trainer.achievements
          $Trainer.achievements.progress(:itemsSold, qty)
        end
      end
      @scene.pbHideMoney
    end
    @scene.pbEndSellScene
    return sold
  end
end

def pbComplexMart(mart, allowSell: false, hasPicture: false, clampBottom: false, background: nil, messages: {})
  defaultMessages = $cache.marts[:DEFAULT].Messages
  martData = $cache.marts[mart]
  martMessages = {}
  allowSellCurrent = allowSell
  hasPictureCurrent = hasPicture
  clampBottomCurrent = clampBottom
  backgroundCurrent = background
  if martData
    # Load mart info
    mart = martData.Inventory

    martMessages = martData.Messages
    allowSellCurrent = martData.allowSell unless allowSell
    hasPictureCurrent = martData.hasPicture unless hasPicture
    clampBottomCurrent = martData.clampBottom unless clampBottom
    backgroundCurrent = martData.background unless background
  end

  martMessages = martMessages.merge(messages)
  interactMessages = defaultMessages.merge(martMessages)

  names = mart.keys.map { |it| pbGetMessage(:MartNames, it) }
  marts = mart.values
  commands = names
  commands = [*commands, _INTL("Sell")] if allowSell

  if commands.length == 1
    cmd = 0
    Kernel.pbMessage(pbGetMessage(:MartMessages, interactMessages[:welcome])) unless interactMessages[:welcome].empty?
  else
    commands = [*commands, _INTL("Quit")]
    cmd = Kernel.pbMessage(pbGetMessage(:MartMessages, interactMessages[:welcome]), commands, -1)
  end

  commandStack = []
  doneAny = false
  loop do
    isSingleSubMart = false
    if cmd >= 0 && cmd < names.length
      inventory = marts[cmd]
      if inventory.is_a?(Symbol) # A mart identifier
        martData = $cache.marts[inventory]
        if martData
          # Load mart info
          inventory = martData.Inventory

          # If this is a shop referenced by another shop, skip choosing options if there's only one
          if inventory.keys.size == 1
            commandStack.push([commands, marts, interactMessages, allowSellCurrent, hasPictureCurrent, clampBottomCurrent, backgroundCurrent])
            inventory = inventory.values.first
            isSingleSubMart = true
          end

          martMessages = martData.Messages
          martMessages = martMessages.merge(messages)
          interactMessages = defaultMessages.merge(martMessages)

          allowSellCurrent = martData.allowSell unless allowSell
          hasPictureCurrent = martData.hasPicture unless hasPicture
          clampBottomCurrent = martData.clampBottom unless clampBottom
          backgroundCurrent = martData.background unless background
        else
          inventory = []
        end
      end

      if inventory.is_a?(Hash) # A set of shops
        commandStack.push([commands, marts, interactMessages, allowSellCurrent, hasPictureCurrent, clampBottomCurrent, backgroundCurrent])

        names = inventory.keys.map { |it| pbGetMessage(:MartNames, it) }
        marts = inventory.values

        commands = names
        commands = [*commands, _INTL("Sell")] if allowSellCurrent && commandStack.size == 1 # Root inventory
        commands = [*commands, _INTL("Back")]
        cmd = Kernel.pbMessage(pbGetMessage(:MartMessages, interactMessages[:welcome]), commands, -1)
        next
      elsif inventory.is_a?(Array) # An inventory of items
        scene = PokemonMartScene.new(hasPictureCurrent, clampBottomCurrent, backgroundCurrent)
        screen = PokemonMartScreen.new(scene, inventory, interactMessages)
        if screen.empty?
          Kernel.pbMessage(pbGetMessage(:MartMessages, interactMessages[:nothing_to_buy]))
        else
          Kernel.pbMessage(pbGetMessage(:MartMessages, interactMessages[:welcome])) if isSingleSubMart && !interactMessages[:welcome].empty?
          doneAny = true if screen.pbBuyScreen
          if isSingleSubMart
            Kernel.pbMessage(pbGetMessage(:MartMessages, interactMessages[:goodbye])) unless interactMessages[:goodbye].empty?
            commands, marts, interactMessages, allowSellCurrent, hasPictureCurrent, clampBottomCurrent, backgroundCurrent = commandStack.pop
          end
        end
      end
    elsif allowSell && cmd == names.length
      scene = PokemonMartScene.new(hasPictureCurrent, clampBottomCurrent, backgroundCurrent)
      screen = PokemonMartScreen.new(scene, [], interactMessages)
      doneAny = true if screen.pbSellScreen
    else # Cancel/Quit
      if commandStack.empty?
        Kernel.pbMessage(pbGetMessage(:MartMessages, interactMessages[:goodbye])) unless interactMessages[:goodbye].empty?
        break
      else
        commands, marts, interactMessages, allowSellCurrent, hasPictureCurrent, clampBottomCurrent, backgroundCurrent = commandStack.pop
      end
    end

    if commands.length == 1
      cmd = -1
    else
      cmd = Kernel.pbMessage(pbGetMessage(:MartMessages, interactMessages[:anything_else]), commands, -1)
    end
  end
  return doneAny
end

def pbPokemonMart(stock, speech = nil, cantsell = false)
  for i in 0...stock.length
    next if stock[i].is_a?(StockType)
    stock[i] = nil if !$PokemonBag.pbQuantity(stock[i]).nil? && pbIsImportantItem?(stock[i]) && $PokemonBag.pbQuantity(stock[i]) > 0
  end
  stock.compact!
  messages = {}
  messages[:welcome] = speech if speech

  basicAdapter = PokemonMartAdapter.new
  inventory = stock.map { |it|
    next ItemStock.of(it).costs(basicAdapter.getPrice(it)) if it.is_a?(Symbol)
    next it
  }

  pbComplexMart({ "Buy" => inventory }, allowSell: !cantsell, messages: messages)
  $game_temp.clear_mart_prices
end

def pbDefaultMart(speech = nil, cantsell = false)
  stock = getDefaultMartStock()
  pbPokemonMart(stock, speech, cantsell)
end

def getDefaultMartStock
  case $Trainer.numbadges
    when 0
      return [:POTION, :ANTIDOTE, :POKEBALL]
    when 1
      return [:POTION, :ANTIDOTE, :PARLYZHEAL, :BURNHEAL, :ESCAPEROPE, :REPEL, :POKEBALL]
    when 2..5
      return [:SUPERPOTION, :ANTIDOTE, :PARLYZHEAL, :BURNHEAL, :ESCAPEROPE, :SUPERREPEL, :POKEBALL]
    when 6..9
      return [:SUPERPOTION, :ANTIDOTE, :PARLYZHEAL, :BURNHEAL, :ESCAPEROPE, :SUPERREPEL, :POKEBALL, :GREATBALL]
    when 10..12
      return [:POKEBALL, :GREATBALL, :ULTRABALL, :SUPERREPEL, :MAXREPEL, :ESCAPEROPE, :FULLHEAL, :HYPERPOTION]
    when 13..16
      return [:POKEBALL, :GREATBALL, :ULTRABALL, :SUPERREPEL, :MAXREPEL, :ESCAPEROPE, :FULLHEAL, :ULTRAPOTION]
    when 17
      return [:POKEBALL, :GREATBALL, :ULTRABALL, :SUPERREPEL, :MAXREPEL, :ESCAPEROPE, :FULLHEAL, :ULTRAPOTION, :MAXPOTION]
    when 18
      return [:POKEBALL, :GREATBALL, :ULTRABALL, :SUPERREPEL, :MAXREPEL, :ESCAPEROPE, :FULLHEAL, :HYPERPOTION, :ULTRAPOTION, :MAXPOTION, :FULLRESTORE, :REVIVE]
    else
      return [:POTION, :ANTIDOTE, :POKEBALL]
  end
end

def pbOnBuyingExpAllPlus
  deleted = $PokemonBag.pbDeleteItem(:EXPALL)
  $game_switches[:Exp_All_Plus_On] = $game_switches[:Exp_All_On]
  $game_switches[:Exp_All_On] = false
  $game_switches[:Bought_Exp_All_Upgrade] = true
  $game_switches[:Exp_All_Upgrade] = true # not used anymore but keeping for consistency
  if deleted
    pbDisplayPaused(_INTL("Your Exp. All has been upgraded!"))
    pbDisplayPaused(_INTL("This upgrade increases the amount of EXP each party member gains from battles. In addition, Pokémon may now gain EXP from the Exp. All even if they're fainted."))
  else
    pbDisplayPaused(_INTL("Here you go!"))
    pbDisplayPaused(_INTL("Did you know? Unlike a regular Exp. All, the Exp. All+ allows Pokémon to gain EXP from it even if they're fainted. The amount of EXP is also increased."))
  end
  pbDisplayPaused(_INTL("Enjoy!"))
end

def pbOnBuyingRemotePC
  pbDisplayPaused(_INTL("There you go; one Remote PC deposited safely in your Key Items pocket!"))
  pbDisplayPaused(_INTL("Look, I probably shouldn't say this too loud, but..."))
  pbDisplayPaused(_INTL("This is still an experimental product, okay?"))
  pbDisplayPaused(_INTL("The amount of power it uses to work is a little unsteady, so it'll consume one Cell Battery per use."))
  pbDisplayPaused(_INTL("Here, I'll give you 5 Cell Batteries to get you started."))
  $PokemonBag.pbStoreItem(:CELLBATTERY, 5)
  pbDisplayPaused(_INTL("Be careful with it!"))
  pbDisplayPaused(_INTL("One of the terms of use from the company, is, um,"))
  pbDisplayPaused(_INTL("If you do something like deposit all of your Machine-capable Pokémon when you use your last Cell Battery, no one can be held responsible for this!"))
  pbDisplayPaused(_INTL("Still, it seems like it can be a helpful product, so use it carefully!"))
end

class Game_Temp
  attr_writer :mart_buy
  attr_writer :mart_sell

  def mart_buy
    @mart_buy = {} if !@mart_buy
    return @mart_buy
  end

  def mart_sell
    @mart_sell = {} if !@mart_sell
    return @mart_sell
  end

  def clear_mart_prices
    @mart_buy = {}
    @mart_sell = {}
  end
end

class Interpreter
  def getItem(p)
    if p[0] == 0
      return $data_items[p[1]]
    elsif p[0] == 1
      return $data_weapons[p[1]]
    elsif p[0] == 2
      return $data_armors[p[1]]
    end

    return nil
  end

  def command_302
    $game_temp.battle_abort = true
    shop_goods = [getItem(@parameters)]
    # Loop
    loop do
      # Advance index
      @index += 1
      # If next event command has shop on second line or after
      if @list[@index].code == 605
        # Add goods list to new item
        shop_goods.push(getItem(@list[@index].parameters))
      else
        # End
        pbPokemonMart(shop_goods.compact)
        return true
      end
    end
  end

  def setPrice(item, buyprice = -1, sellprice = -1)
    $game_temp.mart_buy[item] = buyprice if buyprice > 0
    if sellprice >= 0 # 0=can't sell
      $game_temp.mart_sell[item] = sellprice * 2
    else
      $game_temp.mart_sell[item] = buyprice if buyprice > 0
    end
  end

  def setSellPrice(item, sellprice)
    setPrice(item, -1, sellprice)
  end
end


###################################
# Complex Mart Syntax Documentation
###################################
=begin
(If a message is empty, it will be ignored if that message does not require a player response.)

Format for complex shops

Each shop has a variety of message they can set. When not set, they default to the value in
the :DEFAULT shop entry.

Selling is disabled by default.
For the vendor to allow selling, the following flag is required:
  :allowSell => true

If a vendor has a display image (ex. Mr. Luck from Rejuvenation), the following flag is required:
  :hasPicture => true
This will prevent the screen from scrolling and leave the picture in place.

Depending on the orientation of the picture, the following flag may also be required:
  :clampBottom => true
This changes whether the money window is shown on the top of the screen or the bottom of the screen.

If a vendor needs a custom UI image, use the following flag:
  :background => "<GRAPHIC_PATH>"
This will replace the usual Shop UI with whatever is supplied.

A shop :Inventory can be defined in multiple ways.
The most basic definition is an array of inventory items (see later).
Another for defining a shop is a hash, where the key is the shop display name.
  Example:
    :Inventory => {
      "ShopA" => [
        StockType.of()
        StockType.of()
      ]
    }
You can keep expanding this format for sub menus as much as you want.

Additionally, you may also supply another shop's identifier to pull that shop's data.
  Example:
    :Inventory => {
      "ShopA" => {
        "CategoryA" => :PokeMartA
      }
    }
After menuing to "ShopA" and "CategoryA", the game would then pull from $cache.marts[:PokeMartA]

An inventory item is defined using:
  StockType.of(*args).costs(price, [currency])
and the optional methods:
  .limit([amount])
  .properties(**kwargs)

Currently supported StockType classes:
  ItemStock.of(item, [quantity])
    Used for item options, provided they do not require special handling for being currency items.
    `costs()` method is optional, price will default to `itemtext.rb` prices if not supplied.
    Has an optional method `.noPremierBallBonus()` to disallow the Shop from giving Premier Balls when buying Poke Ball items.

  CurrencyStock.of(currency, quantity)
    Used for currency options, like the Game Corner Coin Exchange.
    Current supported types are:
      :Coins
      :PuppetCoins

  PokemonStock.of(pokemonHash)
    Used for Pokemon options.
    `pokemonHash` uses same keys as the ones in `trainertext.rb`, refer to `PokemonBuilder::pokemon=()` method for further details.
      :level is not required, they will default to level 10 if not supplied.

  MoveStock.of(move)
    Used for Move Tutor options.

Additional StockType classes can be defined in `MartStockTypes.rb`

Currently supported currency types.
  :Money - Player money, as in standard shops (Default)
  :RedEssence - Red Essence (Rejuvenation)
  :Coins - Game Corner coins
  :PuppetCoins - Puppet Coins (Rejuvenation)
  :AP - Achievement Points (Rejuvenation)
  :BP - Battle Points
  :Credits - Credits (Desolation)
  (Item ID) - Item as currency

Examples for purchasable items:
  # ItemStock.of(:POTION).costs(300)
  # ItemStock.of(:REDSHARD).costs(2, :BLUESHARD)
  # ItemStock.of(:GREENSHARD, 2).costs(500, :Coins)

Examples for purchasable coins or puppet coins:
  # CurrencyStock.new(:Coins, 50).costs(1000)
  # CurrencyStock.new(:PuppetCoins, 500).costs(1000, :Coins)

Example for purchasable move tutor moves:
  # MoveStock.new(:THROATCHOP).costs(10, :BP)

Examples for purchasable pokemon:
  # PokemonStock.of({ species: :VULPIX, form: 1, level: 50, moves: [:CHARM, :ENCORE], originalTrainer: "Silph Co." }).costs(1000)

Optioanl `limit` method:
  Limits the purchasable amount of stock to 1 or given amount.
  Example:
    ItemStock.of(:RARECANDY).limit()

Optional `properties` method:
  :name
    Overrides the name of the item in both dialogue boxes and Shop UI.
    Example:
      ItemStock.of(:POTION).properties(name: "Pot")

  :display_name
    Overrides the name of the item in the Shop UI. Takes priority over :name
    Example:
      ItemStock.of(:POTION).properties(name: "Pot", display_name: "Regular Potion")

  :description
    Overrides the default description of the item in the Shop UI.
    Each StockType default description can be viewed in the respective `getDescription` method.
    Example:
      PokemonStock.of({ species: VOLTORB }).costs(200).properties(name: "Poké Ball?",
        description: "A real and normal Poké Ball. It's thrown like a ball at a Pokémon, comfortably encapsulating its target.")

  :currency_shortname
    Overrides the currency display in the Shop UI.
    Example:
      ItemStock.of(:ULTRABALL, 3).costs(5, :DATACHIP).properties(currency_shortname: "Chips")

  :icon
    Overrides the icon displayed in the shop.
    Defaults:
      ItemStock: Respective item icon
      CurrencyStock: Coin Case or Puppet Coin icon
      PokemonStock: Respective Pokemon icon
      MoveStock: TM icon for type of move
    Examples:
      PokemonStock.of({ species: SINISTEA }).costs(10, :BP).properties(icon: "Graphics/Icons/Item/unremarkableteacup.png")
      ItemStock.of(:COMMONCANDY).costs(10000000).properties(name: "Rarest Candy?", icon: "Graphics/Icons/Item/rarecandy.png",
        description: "The rarest of all Rare Candies at a reasonable price.")

  :icon_rect
    Overrides the default icon display size.
    Default:
      Rect.new(0, 0, 48, 48)
    Example:
      ItemStock.of(:POTION).properties(icon: "Graphics/Icons/Pokemon/abomasnow.png", icon_rect: [132, 76, 48, 48])

  :purchase_confirm_single/_mulitple
    Overrides the default purchase confirmation message.
    Supports up to 3 variables:
      When the item can be bought in multiples:
        {1} - Name of the item.
        {2} - Quantity of the item.
        {3} - Price of the item (shorthand).
        {4} - Price of the item (full).
      Else:
        {1} - Name of the item.
        {2} - Price of the item (shorthand).
        {3} - Price of the item (full).
    Example:
      ItemStock.of(:POTION).costs(1000).properties(purchase_confirm_multiple: "You want to buy {2} of {1}? I guess that'll run you {3}.")
      MoveStock.of(:FLASH).costs(1000).properties(purchase_confirm_single: "You want to learn {1}? I guess that'll run you {2}.")

  :choose_quantity
    Overrides the message displayed when selecting amount to purchase.
    Example:
      ItemStock.of(:POTION).properties(choose_quantity: "Eh? How many of {1} dyou want?")

  :success_message
    Overrides the message displayed when successfully purchasing an item.
    Can be supplied as an empty String for use with :on_purchase.
    Example:
      ItemStock.of(:POTION).properties(success_message: "Here you go, then. Have your Potions.")

  :conditions
    Sets any amount of entries that are required to be met to show the item in the Shop UI.
    Examples:
      ItemStock.of(:POTION).properties(
        conditions: [
          'shouldSellPotions?'
        ]
      )

      ItemStock.of(:TM01).costs(9000).properties(
        conditions: [
          '$game_switches[:Reborn_City_Restore]'
        ]
      )

      PokemonStock.of({ species: :JANGMOO }).costs(1000).properties(
        conditions: [
          '$game_variables[:JangmoOQuest] > 4'
        ]
      )

      ItemStock.of(:RUBYRING).costs(10000).properties(
        conditions: [
          '!$game_self_switches[[457, 9, "A"]]]'
        ]
      )

  :on_purchase
    Sets any amount of entries that are run when the purchase succeeds.
    Example:
      ItemStock.of(:TM70).costs(5000).properties(success_message: "",
        on_purchase: [
          'trackBoughtTM',
          '$game_switches[1248] = true'
        ]
      )

=end

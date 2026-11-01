class StockType
  attr_reader :price
  attr_reader :currency
  attr_reader :conditions
  attr_reader :purchase_confirm_single
  attr_reader :purchase_confirm_multiple
  attr_reader :choose_quantity
  attr_reader :success_message
  attr_reader :display_name
  attr_reader :name
  attr_reader :description
  attr_reader :on_purchase
  attr_reader :icon
  attr_reader :icon_rect
  attr_reader :currency_shortname
  attr_reader :max_quantity

  def self.of(*args)
    return self.new(*args)
  end

  def costs(price, currency = :Money)
    @price = price
    @currency = currency
    return self
  end

  def limit(max = 1)
    @max_quantity = max
    return self
  end

  def properties(**data)
    @conditions = data[:conditions] || @conditions
    @purchase_confirm_single = data[:purchase_confirm_single]
    @purchase_confirm_multiple = data[:purchase_confirm_multiple]
    @choose_quantity = data[:choose_quantity]
    @success_message = data[:success_message]
    @display_name = data[:display_name]
    @name = data[:name]
    @description = data[:description]
    @on_purchase = data[:on_purchase] || @on_purchase
    @icon = data[:icon]
    @icon_rect = data[:icon_rect]
    @currency_shortname = data[:currency_shortname]
    return self
  end

  def initialize(*args)
    @currency = :Money
    @conditions = []
    @purchase_confirm_single = nil
    @purchase_confirm_multiple = nil
    @choose_quantity = nil
    @success_message = nil
    @display_name = nil
    @name = nil
    @on_purchase = []
    @icon = nil
    @icon_rect = nil
    @currency_shortname = nil
  end

  def shouldShowItem?
    return !@conditions.any? { |condition| eval(condition) == false }
  end

  def skipPurchase?
    return false
  end

  def getStock
  end

  def handlePurchase(scene, amount)
    # `scene` is needed to ensure the `on_purchase` block has access to the scene's methods.
    # `amount` is needed to ensure the `on_purchase` block has access to the amount when needed.
    @on_purchase.each { |o|
      scene.instance_exec(self, amount) { |item, amount|
        eval(o)
      }
    }
  end

  def getQuantity
    return 0
  end

  def showQuantity?
    return false
  end

  def getTrueQuantity(quantity)
    return quantity
  end

  def getMaxQuantity
    return @max_quantity || 1
  end

  def getName
    return pbGetMessageFromHash(:MartItemNames, @name) if @name

    return nil
  end

  def getDisplayName
    return pbGetMessageFromHash(:MartItemNames, @display_name) if @display_name
    return self.getName if @name

    return nil
  end

  def getCurrencyShortname
    return pbGetMessageFromHash(:MartItemNames, @currency_shortname) if @currency_shortname

    return nil
  end

  def getDescription
    return pbGetMessageFromHash(:MartDescriptions, @description) if @description

    return nil
  end

  def getIcon
    return @icon if @icon && pbResolveBitmap(@icon)
    return pbItemIconFile(@icon) if @icon
    return "Graphics/Icons/Item/itemBack"
  end

  def getIconRect
    return Rect.new(*@icon_rect) if @icon_rect
    return Rect.new(0, 0, Window_PokemonMart::ICON_WIDTH, Window_PokemonMart::ICON_HEIGHT)
  end

  def add
    return true
  end

  def remove
    return true
  end
end

class ItemStock < StockType
  attr_reader :item
  attr_reader :quantity
  attr_reader :allowPremierBall

  def initialize(item, quantity = 1)
    super
    @item = item
    @quantity = quantity
    @allowPremierBall = true
  end

  def properties(**data)
    super(**data)
    return self
  end

  def noPremierBallBonus
    @allowPremierBall = false
    return self
  end

  def price
    return $cache.items[@item].price if !@price
    return @price
  end

  def shouldShowItem?
    ret = super
    return false if pbIsImportantItem?(@item) && $PokemonBag.pbHasItem?(@item)
    return ret
  end

  def getStock
    return [@item, @quantity]
  end

  def getQuantity
    return $PokemonBag.pbQuantity(@item)
  end

  def showQuantity?
    return !pbIsImportantItem?(@item) && self.getMaxQuantity > 1
  end

  def getTrueQuantity(quantity = 1)
    return quantity * @quantity
  end

  def getMaxQuantity
    return self.max_quantity || BAGMAXPERSLOT
  end

  def getName
    ret = super
    return ret if ret
    return getItemName(@item)
  end

  def getDisplayName
    ret = super
    return ret if ret

    itemname = getItemName(@item)
    if pbIsTM?(@item)
      move = $cache.items[@item].checkFlag?(:tm)
      itemname = sprintf("%s %s", itemname, getMoveName(move))
    end
    itemname = sprintf("%dx %s", @quantity, itemname) if @quantity > 1
    return itemname
  end

  def getDescription
    ret = super
    return ret if ret

    return getItemDescription(@item)
  end

  def getIcon
    ret = self.icon
    ret = pbItemIconFile(self.icon) if self.icon && !pbResolveBitmap(ret)
    ret = pbItemIconFile(@item) if !pbResolveBitmap(ret)
    ret = "Graphics/Icons/Item/item000" if !pbResolveBitmap(ret)
    return ret
  end

  def add
    return $PokemonBag.pbStoreItem(@item)
  end

  def remove
    return $PokemonBag.pbDeleteItem(@item)
  end

  def to_s
    output = "#{self.class}(#{@item.inspect}"
    output += ", #{@quantity}" if @quantity > 1
    output += ")"
    return output
  end

  def inspect
    return self.to_s
  end
end

class CurrencyStock < StockType
  attr_reader :type
  attr_reader :amount
  attr_reader :plural

  def initialize(type, amount)
    super
    @type = type
    @amount = amount
    @plural = @amount != 1
  end

  def getStock
    return [@type, @amount]
  end

  def getQuantity
    case @type
      when :Coins
        return $PokemonGlobal.coins
      when :PuppetCoins
        return $game_variables[:PuppetCoins]
      else
        return super
    end
  end

  def showQuantity?
    return self.getMaxQuantity > 1
  end

  def getTrueQuantity(quantity)
    return quantity * @amount
  end

  def getMaxQuantity
    ret = self.max_quantity
    return ret if ret
    case @type
      when :Coins
        return MAXCOINS
      when :PuppetCoins
        return 999999999
      else
        return super
    end
  end

  def getName
    ret = super
    return ret if ret
    return getCurrencyName(@type, @plural) if $cache.currencies[@type]
    return @type.to_s
  end

  def getDisplayName
    ret = super
    return ret if ret
    return getPurchaseDisplay(@amount, shorthand: false, currency: @type) if $cache.currencies[@type]
    return _INTL("{1} " + self.getName, @amount)
  end

  def getDescription
    ret = super
    return ret if ret

    return getCurrencyDescription(@type) if $cache.currencies[@type]
    return ""
  end

  def getIcon
    return self.icon if self.icon && pbResolveBitmap(self.icon)
    return pbItemIconFile(self.icon) if self.icon
    case @type
      when :Coins
        return pbItemIconFile(:COINCASE)
      when :PuppetCoins
        return "Graphics/Icons/Item/puppetcoins"
      else
        return "Graphics/Icons/Item/itemBack"
    end
  end

  def add
    case @type
      when :Coins
        return false if self.getMaxQuantity <= $PokemonGlobal.coins
        $PokemonGlobal.coins += 1
      when :PuppetCoins
        return false if self.getMaxQuantity <= $game_variables[:PuppetCoins]
        $game_variables[:PuppetCoins] += 1
      else
        $game_variables[@type] += 1
    end
    return true
  end

  def remove
    case @type
      when :Coins
        return false if $PokemonGlobal.coins <= 0
        $PokemonGlobal.coins += 1
      when :PuppetCoins
        return false if $game_variables[:PuppetCoins] <= 0
        $game_variables[:PuppetCoins] -= 1
      else
        $game_variables[@type] -= 1
    end
    return true
  end

  def to_s
    return "#{self.class}(#{@type.inspect}, #{@currency})"
  end

  def inspect
    return self.to_s
  end
end

class PokemonStock < StockType
  attr_reader :pokemon
  attr_reader :species
  attr_reader :form
  attr_reader :shiny
  attr_reader :girl
  attr_reader :egg
  attr_reader :shadow
  attr_reader :moves

  def initialize(pokemon)
    super
    @pokemon = pokemon
    @species = @pokemon[:species]
    @form = @pokemon.fetch(:form, 0)
    @shiny = @pokemon.fetch(:shiny, false)
    @girl = @pokemon[:gender] == "F" ? true : false
    @egg = @pokemon.fetch(:egg, false)
    @shadow = @pokemon.fetch(:shadow, false)
    @moves = @pokemon[:moves]
  end

  def getStock
    return @pokemon
  end

  def getName
    ret = super
    return ret if ret
    return getMonName(@species, @form)
  end

  def getDisplayName
    ret = super
    return ret if ret
    return getMonFormName(@species, @form, @girl ? :F : nil)
  end

  def getDescription
    ret = super
    return ret if ret

    mon = $cache.pkmn[@species, @form]
    if mon.Type2 && mon.Type2 != mon.Type1
      types = sprintf("%s/%s", getTypeName(mon.Type1), getTypeName(mon.Type2))
    else
      types = getTypeName(mon.Type1)
    end
    kind = pbGetMessage(:Kinds, mon.kind)
    if types.start_with?(/[aeiou]/i)
      desc = _INTL("The {1} Pokémon; an {2} type.", kind, types)
    else
      desc = _INTL("The {1} Pokémon; a {2} type.", kind, types)
    end
    if @moves
      moves = @moves.map { |move| getMoveName(move) }
      moves = joinStrings(moves)
      desc += " " + _INTL("Comes knowing {1}.", moves)
    end
    return desc
  end

  # Override to account for aura math. Values are handled in `getIcon` if icon is not custom.
  def getIconRect
    return super if self.icon
    width = Window_PokemonMart::ICON_WIDTH
    height = Window_PokemonMart::ICON_HEIGHT
    if self.icon_rect
      width = self.icon_rect[2]
      height = self.icon_rect[3]
    end
    return Rect.new(0, 0, width, height)
  end

  def getIcon
    return self.icon if self.icon && pbResolveBitmap(self.icon)
    return pbItemIconFile(self.icon) if self.icon
    if self.icon_rect
      x, y, width, height = self.icon_rect
    else
      x = self.getIconRect.x
      y = self.getIconRect.y
      width = self.getIconRect.width
      height = self.getIconRect.height
    end
    xOffset = 8 + AURA_SPRITE_OFFSET / 2
    yOffset = 12 + AURA_SPRITE_OFFSET / 2
    bmp = pbIconBitmap(@species, @form, @shiny, @girl, @egg, @shadow)
    xOffset += AURA_SPRITE_OFFSET if x >= bmp.width / 2 - AURA_SPRITE_OFFSET
    rect = Rect.new(x + xOffset, y + yOffset, width, height)
    ret = Bitmap.new(width, height).blt(0, 0, bmp, rect)
    return ret
  end

  def add
    return pbAddPokemon(@pokemon)
  end

  def to_s
    return "#{self.class}(#{@species.inspect}, #{@form.inspect})"
  end

  def inspect
    return self.to_s
  end
end

class MoveStock < StockType
  attr_reader :move

  def initialize(move)
    super
    @move = move
  end

  def skipPurchase?
    return checkTutorMove(@move)
  end

  def getStock
    return @move
  end

  def getName
    ret = super
    return ret if ret
    return getMoveName(@move)
  end

  def getDisplayName
    ret = super
    return ret if ret
    return getMoveName(@move)
  end

  def getDescription
    ret = super
    return ret if ret

    return getMoveDesc(@move)
  end

  def getIcon
    return self.icon if self.icon && pbResolveBitmap(self.icon)
    return pbItemIconFile(self.icon) if self.icon
    type = $cache.moves[@move].type
    typename = $cache.types[type].name
    return sprintf("Graphics/Icons/Item/TM - %s", typename)
  end

  def add
    pbMoveTutorChoose(@move)
    addTutorMove(@move)
    return true
  end

  def to_s
    return "#{self.class}(#{@move.inspect})"
  end

  def inspect
    return self.to_s
  end
end

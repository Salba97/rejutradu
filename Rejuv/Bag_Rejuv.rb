class Window_PokemonBag < Window_DrawableCommand
  def drawItem(index, count, rect)
    textpos = []
    imagepos = []
    rect = drawCursor(index, rect)
    ypos = rect.y + 4
    pocketItems = @bag.getPocketItems(@pocket)
    if index == pocketItems.length
      textpos.push([_INTL("CLOSE BAG"), rect.x, ypos, false, self.baseColor, self.shadowColor])
    else
      item = pocketItems[index]
      qty = _ISPRINTF("x{1: 2d}", @bag.contents[item])
      # Use short item name unless the qty is single digit (works for Blue Moon Ice Cream which is the only use case right now)
      itemname = @adapter.getDisplayName(item, bag: true, short: @bag.contents[item] > 9)
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + 4 + rect.width - sizeQty - 16
      baseColor = (index == @sortIndex) ? Color.new(224, 0, 0) : self.baseColor
      shadowColor = (index == @sortIndex) ? Color.new(248, 144, 144) : self.shadowColor
      textpos.push([itemname, rect.x + 28, ypos, false, baseColor, shadowColor])
      if shouldShowQuantity?(item) # Not a Key item or HM (or infinite TM)
        textpos.push([qty, xQty, ypos, false, baseColor, shadowColor])
      end
      if @bag.pbIsRegistered?(item)
        imagepos.push(["Graphics/Pictures/Bag/bagReg", rect.x + rect.width - 60, ypos + 4, 0, 0, -1, -1])
      end
      if pbIsTM?(item)
        type = $cache.moves[pbGetTM(item)].type
        imagepos.push(["Graphics/Icons/minitype#{type}", rect.x - 4, ypos + 2, 0, 0, -1, -1])
      else
        fav = @bag.isFavorite?(item)
        imagepos.push(["Graphics/Pictures/Bag/favicon_#{fav ? "on" : "off"}", rect.x - 6, ypos + 2, 0, 0, -1, -1])
      end
    end
    pbDrawTextPositions(self.contents, textpos)
    pbDrawImagePositions(self.contents, imagepos)
  end
end

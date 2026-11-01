################################################################################
# Lists
################################################################################
def pbListWindow(cmds, width = 256)
  isCursorSmall = true
  viewport = nil
  list = Window_CommandPokemon.newWithSize(cmds, 0, 0, width, Graphics.height, viewport, isCursorSmall)
  list.index = 0
  list.rowHeight = 24
  pbSetSmallFont(list.contents)
  list.refresh
  return list
end

def pbSimpleWindow(text, x, y, width, height, z, viewport)
  win = Window_UnformattedTextPokemon.new(text)
  win.x = x
  win.y = y
  win.width = width
  win.height = height
  win.z = z
  win.viewport = viewport
  return win
end

def pbChooseSpecies(default)
  commands = []
  $cache.pkmn.each_with_index { |(key, value), i|
    label = _ISPRINTF("{1:s} {2:s}", getSpeciesNumWithZeroes(i + 1), getMonName(key))
    commands.push(label)
  }
  ret = pbLongChoiceList(commands, default, 200)
  return ret >= 0 ? ret + 1 : nil
end

def pbChooseSpeciesOrdered(default)
  commands = $cache.pkmn.map { |mon, mondata|
    [mondata.pokemonData[mondata.forms[0]].dexnum, getMonName(mon), mon]
  }
  commands.sort! { |a, b| a[1] <=> b[1] }
  realcommands = []
  for command in commands
    label = _ISPRINTF("{1:s} {2:s}", getSpeciesNumWithZeroes(command[0]), command[1])
    realcommands.push(label)
  end
  ret = pbLongChoiceList(realcommands, default, 200)
  return ret >= 0 ? commands[ret][2] : nil
end

# Displays a sorted list of Pokémon species, and returns the ID of the species
# selected or 0 if the selection was canceled.  defaultItemID, if specified,
# indicates the ID of the species initially shown on the list.
def pbChooseSpeciesList(defaultItemID = 0)
  commands = []
  itemDefault = 0

  commands = $cache.pkmn.map { |pkmn, pkmndata| [pkmn, getMonName(pkmn)] }
  commands.sort! { |a, b| a[1] <=> b[1] }
  if defaultItemID > 0
    commands.each_with_index { |item, index|
      itemDefault = index if item[0] == defaultItemID
    }
  end
  realcommands = []
  for command in commands
    realcommands.push(_ISPRINTF("{1:s}", command[1]))
  end
  ret = pbLongChoiceList(realcommands, itemDefault, 200)
  return ret >= 0 ? commands[ret][0] : nil
end

# Displays a sorted list of moves, and returns the ID of the move selected or
# nil if the selection was canceled.  defaultMoveID, if specified, indicates the
# ID of the move where the cursor is initially placed on the list.
def pbChooseMoveList(moves, defaultMoveID = nil)
  commands = moves.map { |move| [move, getMoveName(move)] }
  commands.sort! { |a, b| a[1] <=> b[1] }

  moveDefault = 0
  if defaultMoveID
    commands.each_with_index { |item, index|
      if item[0] == defaultMoveID
        moveDefault = index
        break
      end
    }
  end

  realcommands = commands.map { |command| _ISPRINTF("{1:s}", command[1]) }

  ret = pbLongChoiceList(realcommands, moveDefault, 256)
  return ret >= 0 ? commands[ret][0] : nil
end

def pbChooseTutorList(defaultMoveID = 0)
  commands = []
  moveDefault = 0
  for i in $Trainer.tutorlist
    name = getMoveName(i)
    commands.push([i, name]) if name != nil && name != ""
  end
  commands.sort! { |a, b| a[1] <=> b[1] }
  if defaultMoveID > 0
    commands.each_with_index { |item, index|
      moveDefault = index if item[0] == defaultMoveID
    }
  end
  realcommands = []
  for command in commands
    realcommands.push(_ISPRINTF("{1:s}", command[1]))
  end
  ret = pbLongChoiceList(realcommands, moveDefault, 200)
  return ret >= 0 ? commands[ret][0] : 0
end

def pbChooseTypeList(defaultMoveID = 0, movetype = false)
  commands = []
  moveDefault = 0
  $cache.types.each { |key, value|
    commands.push([key, value.name]) unless [:QMARKS, :SHADOW, :STELLAR].include?(key)
  }
  commands.sort! { |a, b| a[1] <=> b[1] }
  if defaultMoveID > 0
    commands.each_with_index { |item, index|
      moveDefault = index if item[0] == defaultMoveID
    }
  end
  realcommands = []
  for command in commands
    realcommands.push(_ISPRINTF("{1:s}", command[1]))
  end
  ret = pbLongChoiceList(realcommands, moveDefault, 200)
  return ret >= 0 ? commands[ret][0] : 0
end

# Displays a sorted list of items, and returns the ID of the item selected or
# 0 if the selection was canceled.  defaultItemID, if specified, indicates the
# ID of the item initially shown on the list.
def pbChooseItemList(defaultItemID = 0)
  commands = []
  moveDefault = 0
  # basically make a list of all the items
  for c in PBItems.constants
    i = PBItems.const_get(c)
    if i.is_a?(Integer)
      commands.push([i, getItemName(i)])
    end
  end
  commands.sort! { |a, b| a[1] <=> b[1] }
  if defaultItemID > 0
    commands.each_with_index { |item, index|
      moveDefault = index if item[0] == defaultItemID
    }
  end
  realcommands = []
  for command in commands
    realcommands.push(_ISPRINTF("{1:s}", command[1]))
  end
  ret = pbLongChoiceList(realcommands, moveDefault, 256)
  return ret >= 0 ? commands[ret][0] : 0
end

# Displays a sorted list of abilities, and returns the ID of the ability selected
# or nil if the selection was canceled. defaultAbilityID, if specified, indicates the
# ID of the ability initially shown on the list.
def pbChooseAbilityList(defaultAbilityID = nil)
  commands = $cache.abil.keys.map { |abil| [abil, getAbilityNameUnique(abil)] }
  commands.sort! { |a, b| a[1] <=> b[1] }

  abilityDefault = 0
  if defaultAbilityID
    commands.each_with_index { |item, index|
      if item[0] == defaultAbilityID
        abilityDefault = index
        break
      end
    }
  end

  realcommands = commands.map { |command| _ISPRINTF("{1:s}", command[1]) }

  ret = pbLongChoiceList(realcommands, abilityDefault, 256)
  return ret >= 0 ? commands[ret][0] : nil
end

def pbLongChoiceList(commands, default, width)
  cmdwin = pbListWindow([], width)
  ret = pbCommands2(cmdwin, commands, -1, default - 1, true)
  cmdwin.dispose
  return ret
end

def pbCommands2(cmdwindow, commands, cmdIfCancel, defaultindex = -1, noresize = false)
  helpwindow = pbSimpleWindow(_INTL("Press A to search."), cmdwindow.width, Graphics.height - 64, Graphics.width - cmdwindow.width, 64, 99999, nil)
  cmdwindow.x = 0
  cmdwindow.y = 0
  cmdwindow.width = 256 unless noresize
  cmdwindow.height = Graphics.height if noresize || cmdwindow.height > Graphics.height
  cmdwindow.z = 99999
  cmdwindow.visible = true
  cmdwindow.active = true
  cmdwindow.commands = commands
  cmdwindow.index = defaultindex if defaultindex >= 0
  allcommands = commands
  indexmap = (0...commands.length).to_a # Positions correspond to indices in currently visible list (modified by search), elements correspond to indices in full list

  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::B)
      if cmdIfCancel > 0
        command = cmdIfCancel - 1
        break
      elsif cmdIfCancel < 0
        command = cmdIfCancel
        break
      end
    elsif Input.trigger?(Input::C)
      command = indexmap[cmdwindow.index]
      break
    elsif Input.trigger?(Input::X)
      pbListSearch(allcommands, cmdwindow, indexmap) # Modifies cmdwindow and indexmap
    end
  end

  helpwindow.dispose
  cmdwindow.active = false
  return command
end

def pbCommands3(cmdwindow, commands, cmdIfCancel, defaultindex = -1, noresize = false)
  cmdwindow.z = 99999
  cmdwindow.visible = true
  cmdwindow.commands = commands
  if !noresize
    cmdwindow.width = 256
  else
    cmdwindow.height = Graphics.height
  end
  cmdwindow.height = Graphics.height if cmdwindow.height > Graphics.height
  cmdwindow.x = 0
  cmdwindow.y = 0
  cmdwindow.active = true
  cmdwindow.index = defaultindex if defaultindex >= 0
  ret = []
  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::X)
      command = [5, cmdwindow.index]
      break
    end
    if Input.press?(Input::A)
      if Input.repeat?(Input::UP)
        command = [1, cmdwindow.index]
        break
      elsif Input.repeat?(Input::DOWN)
        command = [2, cmdwindow.index]
        break
      elsif Input.press?(Input::LEFT)
        command = [3, cmdwindow.index]
        break
      elsif Input.press?(Input::RIGHT)
        command = [4, cmdwindow.index]
        break
      end
    end
    if Input.trigger?(Input::B)
      if cmdIfCancel > 0
        command = [0, cmdIfCancel - 1]
        break
      elsif cmdIfCancel < 0
        command = [0, cmdIfCancel]
        break
      end
    end
    if Input.trigger?(Input::C)
      command = [0, cmdwindow.index]
      break
    end
  end
  ret = command
  cmdwindow.active = false
  return ret
end

################################################################################
# Core lister script
################################################################################
def pbListScreen(title, lister, listwidth = 300)
  if lister.commands.length == 0
    value = lister.value(-1)
    lister.dispose
    return value
  end

  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  lister.setViewport(viewport)

  title = Window_UnformattedTextPokemon.new(title)
  title.x = listwidth
  title.y = 0
  title.width = Graphics.width - listwidth
  title.height = 64
  title.z = 2
  title.viewport = viewport

  helpwindow = pbSimpleWindow(_INTL("Search: A"), listwidth, Graphics.height - 64, Graphics.width - listwidth, 64, 2, viewport)

  list = pbListWindow([], listwidth)
  list.z = 2
  list.viewport = viewport
  list.commands = lister.commands
  list.index = lister.startIndex
  indexmap = (0...list.commands.length).to_a # Positions correspond to indices in the list, elements correspond to indices in the lister

  selectedindex = -1
  loop do
    Graphics.update
    Input.update
    list.update
    if list.index != selectedindex
      lister.refresh(indexmap[list.index])
      selectedindex = list.index
    end
    if Input.trigger?(Input::C)
      break
    elsif Input.trigger?(Input::B)
      selectedindex = -1
      break
    elsif Input.trigger?(Input::X)
      selbefore = list.commands[list.index]
      pbListSearch(lister.commands, list, indexmap) # Modifies list and indexmap
      selectedindex = -1 if list.commands[list.index] != selbefore # Cause refresh
    end
  end

  value = lister.value(selectedindex == -1 ? -1 : indexmap[selectedindex])
  title.dispose
  helpwindow.dispose
  lister.dispose
  list.dispose
  return value
end

def pbListSearch(commands, cmdwindow, indexmap)
  string = Kernel.pbMessageFreeText(_INTL("Enter the search string."), "", 30, Graphics.width)
  return if string == ""

  newcommands, newindices = [], []
  commands.each_with_index { |command, i|
    next unless command.downcase.include?(string.downcase)
    newcommands.push(command)
    newindices.push(i)
  }

  if newcommands.empty?
    Kernel.pbMessage(_INTL("No matches found."))
    return
  end

  cmdwindow.commands = newcommands
  cmdwindow.index = 0
  # indexmap must be modified in-place since we aren't returning it
  indexmap.clear
  (0...commands.length).each { |i| indexmap.push(newindices[i]) }
end

def pbListScreenPop(title, lister)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  list = pbListWindow([], 256)
  list.viewport = viewport
  list.z = 2
  title = Window_UnformattedTextPokemon.new(title)
  title.x = 256
  title.y = 0
  title.width = Graphics.width - 256
  title.height = 64
  title.viewport = viewport
  title.z = 2
  lister.setViewport(viewport)
  selectedmap = -1
  commands = lister.commands
  selindex = lister.startIndex
  selectedteams = []
  if commands.length == 0
    value = lister.value(-1)
    lister.dispose
    return value
  end
  list.commands = commands
  list.index = selindex
  loop do
    Graphics.update
    Input.update
    list.update
    if list.index != selectedmap
      lister.refresh(list.index)
      selectedmap = list.index
    end
    if Input.trigger?(Input::C)
      selectedteams.push(lister.value(selectedmap))
      puts "Added."
    elsif Input.trigger?(Input::B)
      selectedmap = -1
      break
    end
  end
  lister.dispose
  title.dispose
  list.dispose
  Input.update
  return selectedteams
end

def pbListScreenBlock(title, lister)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  list = pbListWindow([], 256)
  list.viewport = viewport
  list.z = 2
  title = Window_UnformattedTextPokemon.new(title)
  title.x = 256
  title.y = 0
  title.width = Graphics.width - 256
  title.height = 64
  title.viewport = viewport
  title.z = 2
  lister.setViewport(viewport)
  selectedmap = -1
  commands = lister.commands
  selindex = lister.startIndex
  if commands.length == 0
    value = lister.value(-1)
    lister.dispose
    return value
  end
  list.commands = commands
  list.index = selindex
  loop do
    Graphics.update
    Input.update
    list.update
    if list.index != selectedmap
      lister.refresh(list.index)
      selectedmap = list.index
    end
    if Input.trigger?(Input::A)
      yield(Input::A, lister.value(selectedmap))
      list.commands = lister.commands
      if list.index == list.commands.length
        list.index = list.commands.length
      end
      lister.refresh(list.index)
    elsif Input.trigger?(Input::C)
      yield(Input::C, lister.value(selectedmap))
      list.commands = lister.commands
      if list.index == list.commands.length
        list.index = list.commands.length
      end
      lister.refresh(list.index)
    elsif Input.trigger?(Input::B)
      break
    end
  end
  lister.dispose
  title.dispose
  list.dispose
  Input.update
end

################################################################################
# General listers
################################################################################
class MapLister
  def initialize(selmap, addGlobal = false)
    @sprite = SpriteWrapper.new
    @sprite.bitmap = nil
    @sprite.z = 2
    @commands = []
    @maps = pbMapTree
    @addGlobalOffset = (addGlobal) ? 1 : 0
    @index = 0
    for i in 0...@maps.length
      @index = i + @addGlobalOffset if @maps[i][0] == selmap
    end
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    if @addGlobalOffset == 1
      @commands.push(_INTL("[GLOBAL]"))
    end
    for i in 0...@maps.length
      @commands.push(sprintf("%s%03d %s", ("  " * @maps[i][2]), @maps[i][0], @maps[i][1]))
    end
    return @commands
  end

  def value(index)
    if @addGlobalOffset == 1
      return 0 if index == 0
    end
    return (index < 0) ? -1 : @maps[index - @addGlobalOffset][0]
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index < 0
    return if index == 0 && @addGlobalOffset == 1

    @sprite.bitmap = MinimapCache.minimap(@maps[index - @addGlobalOffset][0])
    @sprite.x = (Graphics.width - ((Graphics.width - 256) / 2)) - (@sprite.bitmap.width / 2)
    @sprite.y = (Graphics.height - (Graphics.height / 2)) - (@sprite.bitmap.height / 2)
  end
end

class ItemLister
  def initialize(selection)
    @sprite = IconSprite.new(0, 0)
    @sprite.bitmap = nil
    @sprite.z = 2
    @selection = selection
    @commands = []
    @ids = []
    @trainers = nil
    @index = 0
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands # Sorted alphabetically
    @itemdata = $cache.items
    cmds = @itemdata.map { |item, itemdata| [item, itemdata.name] }
    cmds.sort! { |a, b| a[1] <=> b[1] }
=begin
    for item in @itemdata.keys
      next if !@itemdata[item]
      name = @itemdata[item].name
      id = @itemdata[item].checkFlag?(:ID)
      if name && name!=""
        cmds.push([id,name])
      end
    end
=end

    @commands = cmds.map { |i| i[1] }
    @ids = cmds.map { |i| i[0] }

    @index = @selection
    @index = @commands.length - 1 if @index >= @commands.length
    @index = 0 if @index < 0
    return @commands
  end

  def value(index)
    return nil if (index < 0)

    realIndex = index
    return @ids[realIndex]
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index < 0

    filename = pbItemIconFile(@ids[index])
    @sprite.setBitmap(filename, 0)
    ww = @sprite.bitmap.width
    wh = @sprite.bitmap.height
    sx = (Graphics.width - 256).to_f() / ww
    sy = (Graphics.height - 64).to_f() / wh
    if sx < 1.0 || sy < 1.0
      if sx > sy
        ww = sy * ww
        wh = (Graphics.height - 64).to_f()
      else
        wh = sx * wh
        ww = (Graphics.width - 256).to_f()
      end
    end
    @sprite.zoom_x = ww * 1.0 / @sprite.bitmap.width
    @sprite.zoom_y = wh * 1.0 / @sprite.bitmap.height
    @sprite.x = (Graphics.width - ((Graphics.width - 256) / 2)) - (ww / 2)
    @sprite.y = (Graphics.height - ((Graphics.height - 64) / 2)) - (wh / 2)
  end
end

class TrainerBattleLister
  def initialize(selection, includeNew)
    @sprite = IconSprite.new
    @sprite.bitmap = nil
    @sprite.z = 2
    @selection = selection
    @commands = []
    @ids = []
    @includeNew = includeNew
    @trainers = nil
    @index = 0
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    @ids.clear
    @trainers = unhashTRlist
    if @includeNew
      @commands.push(_ISPRINTF("[NEW TRAINER BATTLE]"))
      @ids.push(-1)
    end
    @trainers.length.times do |i|
      next if !@trainers[i]

      # Index: TrainerType TrainerName (Team Number)
      # Trainer's name must not be localized
      @commands.push(_ISPRINTF("{1:3d}: {2:s} ({3:s})", i, trainerFullName(@trainers[i][0], @trainers[i][1]), @trainers[i][4]))
      # Trainer type ID
      @ids.push(@trainers[i][0])
    end
    @index = @selection
    @index = @commands.length - 1 if @index >= @commands.length
    @index = 0 if @index < 0
    return @commands
  end

  def value(index)
    return nil if (index < 0)
    return [-1, nil] if index == 0 && @includeNew

    realIndex = (@includeNew) ? index - 1 : index
    return [realIndex, @trainers[realIndex]]
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index < 0

    spriteX = 276
    @sprite.setBitmap(pbTrainerSpriteFile(@ids[index]), 0)
    ww = @sprite.bitmap.width
    wh = @sprite.bitmap.height
    sx = (Graphics.width - spriteX).to_f() / ww
    sy = (Graphics.height - 64).to_f() / wh
    if sx < 1.0 || sy < 1.0
      if sx > sy
        ww = sy * ww
        wh = (Graphics.height - 64).to_f()
      else
        wh = sx * wh
        ww = (Graphics.width - spriteX).to_f()
      end
    end
    @sprite.zoom_x = ww * 1.0 / @sprite.bitmap.width
    @sprite.zoom_y = wh * 1.0 / @sprite.bitmap.height
    @sprite.x = (Graphics.width - ((Graphics.width - spriteX) / 2)) - (ww / 2)
    @sprite.y = (Graphics.height - ((Graphics.height - 64) / 2)) - (wh / 2)
  end
end

################################################################################
# Map drawing
################################################################################
class MapSprite
  def initialize(map, viewport = nil)
    @sprite = Sprite.new(viewport)
    @sprite.bitmap = MinimapCache.minimap(map)
    @sprite.x = (Graphics.width / 2) - (@sprite.bitmap.width / 2)
    @sprite.y = (Graphics.height / 2) - (@sprite.bitmap.height / 2)
  end

  def dispose
    @sprite.dispose
  end

  def z=(value)
    @sprite.z = value
  end

  def getXY
    return nil if !Input.triggerex?(0x01)

    mouse = Mouse::getMousePos(true)
    if mouse[0] < @sprite.x || mouse[0] >= @sprite.x + @sprite.bitmap.width
      return nil
    end
    if mouse[1] < @sprite.y || mouse[1] >= @sprite.y + @sprite.bitmap.height
      return nil
    end

    x = mouse[0] - @sprite.x
    y = mouse[1] - @sprite.y
    return [x / 4, y / 4]
  end
end

class SelectionSprite < Sprite
  def initialize(viewport = nil)
    @sprite = Sprite.new(viewport)
    @sprite.bitmap = nil
    @sprite.z = 2
    @othersprite = nil
  end

  def disposed?
    return @sprite.disposed?
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @othersprite = nil
    @sprite.dispose
  end

  def othersprite=(value)
    @othersprite = value
    if @othersprite && !@othersprite.disposed? &&
       @othersprite.bitmap && !@othersprite.bitmap.disposed?
      @sprite.bitmap = pbDoEnsureBitmap(
        @sprite.bitmap, @othersprite.bitmap.width, @othersprite.bitmap.height
      )
      red = Color.new(255, 0, 0)
      @sprite.bitmap.clear
      @sprite.bitmap.fill_rect(0, 0, @othersprite.bitmap.width, 2, red)
      @sprite.bitmap.fill_rect(0, @othersprite.bitmap.height - 2, @othersprite.bitmap.width, 2, red)
      @sprite.bitmap.fill_rect(0, 0, 2, @othersprite.bitmap.height, red)
      @sprite.bitmap.fill_rect(@othersprite.bitmap.width - 2, 0, 2, @othersprite.bitmap.height, red)
    end
  end

  def update
    if @othersprite && !@othersprite.disposed?
      @sprite.visible = @othersprite.visible
      @sprite.x = @othersprite.x
      @sprite.y = @othersprite.y
    else
      @sprite.visible = false
    end
  end
end

class MinimapCache
  def self.createMinimap(mapid)
    map = $cache.map_load(mapid) rescue nil
    return BitmapWrapper.new(32, 32) unless map

    bitmap = BitmapWrapper.new(map.width * 4, map.height * 4)
    black = Color.new(0, 0, 0)
    tileset = $cache.RXtilesets[map.tileset_id]
    return bitmap unless tileset

    helper = TileDrawingHelper.fromTileset(tileset)
    for y in 0...map.height
      for x in 0...map.width
        for z in 0..2
          id = map.data[x, y, z]
          id = 0 if !id
          helper.bltSmallTile(bitmap, x * 4, y * 4, 4, 4, id)
        end
      end
    end
    bitmap.fill_rect(0, 0, bitmap.width, 1, black)
    bitmap.fill_rect(0, bitmap.height - 1, bitmap.width, 1, black)
    bitmap.fill_rect(0, 0, 1, bitmap.height, black)
    bitmap.fill_rect(bitmap.width - 1, 0, 1, bitmap.height, black)

    return bitmap
  end

  def self.minimap(mapid)
    @minimaps = [] if !@minimaps
    if !@minimaps[mapid] || @minimaps[mapid].disposed?
      @minimaps[mapid] = createMinimap(mapid)
    end
    return @minimaps[mapid].clone
  end
end


################################################################################
# Visual Editor (map connections)
################################################################################
class MapScreenScene

  def getMapSprite(id)
    if !@mapsprites[id]
      @mapsprites[id] = Sprite.new(@viewport)
      @mapsprites[id].z = 0
      @mapsprites[id].bitmap = nil
    end
    if !@mapsprites[id].bitmap || @mapsprites[id].bitmap.disposed?
      @mapsprites[id].bitmap = MinimapCache.minimap(id)
    end
    return @mapsprites[id]
  end

  def close
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@mapsprites)
    @viewport.dispose
  end

  def setMapSpritePos(id, x, y)
    sprite = getMapSprite(id)
    sprite.x = x
    sprite.y = y
    sprite.visible = true
  end

  def putNeighbors(id, sprites)
    conns = @mapconns
    mapsprite = getMapSprite(id)
    dispx = mapsprite.x
    dispy = mapsprite.y
    for conn in conns
      if conn[0] == id
        b = sprites.any? { |i| i == conn[3] }
        if !b
          x = (conn[1] - conn[4]) * 4 + dispx
          y = (conn[2] - conn[5]) * 4 + dispy
          setMapSpritePos(conn[3], x, y)
          sprites.push(conn[3])
          putNeighbors(conn[3], sprites)
        end
      elsif conn[3] == id
        b = sprites.any? { |i| i == conn[0] }
        if !b
          x = (conn[4] - conn[1]) * 4 + dispx
          y = (conn[5] - conn[2]) * 4 + dispy
          setMapSpritePos(conn[0], x, y)
          sprites.push(conn[3])
          putNeighbors(conn[0], sprites)
        end
      end
    end
  end

  def hasConnections?(conns, id)
    for conn in conns
      return true if conn[0] == id || conn[3] == id
    end
    return false
  end

  def connectionsSymmetric?(conn1, conn2)
    if conn1[0] == conn2[0]
      # Equality
      return false if conn1[1] != conn2[1]
      return false if conn1[2] != conn2[2]
      return false if conn1[3] != conn2[3]
      return false if conn1[4] != conn2[4]
      return false if conn1[5] != conn2[5]

      return true
    elsif conn1[0] == conn2[3]
      # Symmetry
      return false if conn1[1] != -conn2[1]
      return false if conn1[2] != -conn2[2]
      return false if conn1[3] != conn2[0]
      return false if conn1[4] != -conn2[4]
      return false if conn1[5] != -conn2[5]

      return true
    end
    return false
  end

  def removeOldConnections(ret, mapid)
    for i in 0...ret.length
      ret[i] = nil if ret[i][0] == mapid || ret[i][3] == mapid
    end
    ret.compact!
  end

  # Returns the maps within _keys_ that are directly connected to this map, _map_.
  def getDirectConnections(keys, map)
    thissprite = getMapSprite(map)
    thisdims = MapFactoryHelper.getMapDims(map)
    ret = []
    for i in keys
      next if i == map

      othersprite = getMapSprite(i)
      otherdims = MapFactoryHelper.getMapDims(i)
      x1 = (thissprite.x - othersprite.x) / 4
      y1 = (thissprite.y - othersprite.y) / 4
      if x1 == otherdims[0] || x1 == -thisdims[0] ||
         y1 == otherdims[1] || y1 == -thisdims[1]
        ret.push(i)
      end
    end
    # If no direct connections, add an indirect connection
    if ret.length == 0
      key = (map == keys[0]) ? keys[1] : keys[0]
      ret.push(key)
    end
    return ret
  end

  def generateConnectionData
    ret = []
    # Create a clone of current map connection
    for conn in @mapconns
      ret.push(conn.clone)
    end
    keys = @mapsprites.keys
    return ret if keys.length < 2

    # Remove all connections containing any sprites on the canvas from the array
    for i in keys
      removeOldConnections(ret, i)
    end
    # Rebuild connections
    for i in keys
      refs = getDirectConnections(keys, i)
      for refmap in refs
        othersprite = getMapSprite(i)
        refsprite = getMapSprite(refmap)
        c1 = (refsprite.x - othersprite.x) / 4
        c2 = (refsprite.y - othersprite.y) / 4
        conn = [refmap, 0, 0, i, c1, c2]
        j = 0
        while j < ret.length && !connectionsSymmetric?(ret[j], conn)
          j += 1
        end
        if j == ret.length
          ret.push(conn)
        end
      end
    end
    return ret
  end

  def putSprite(id)
    addSprite(id)
    putNeighbors(id, [])
  end

  def addSprite(id)
    mapsprite = getMapSprite(id)
    x = (Graphics.width - mapsprite.bitmap.width) / 2
    y = (Graphics.height - mapsprite.bitmap.height) / 2
    mapsprite.x = x.to_i & ~3
    mapsprite.y = y.to_i & ~3
  end

  def saveMapSpritePos
    @mapspritepos.clear
    for i in @mapsprites.keys
      s = @mapsprites[i]
      @mapspritepos[i] = [s.x, s.y] if s && !s.disposed?
    end
  end

  def mapScreen
    @sprites = {}
    @mapsprites = {}
    @mapspritepos = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @lasthitmap = -1
    @lastclick = -1
    @oldmousex = nil
    @oldmousey = nil
    @dragging = false
    @dragmapid = -1
    @dragOffsetX = 0
    @dragOffsetY = 0
    @selmapid = -1
    addBackgroundPlane(@sprites, "background", "trainercardbg", @viewport)
    @sprites["selsprite"] = SelectionSprite.new(@viewport)
    @sprites["title"] = Window_UnformattedTextPokemon.new(_INTL("F5: Help"))
    @sprites["title"].x = 0
    @sprites["title"].y = Graphics.height - 64
    @sprites["title"].width = Graphics.width
    @sprites["title"].height = 64
    @sprites["title"].viewport = @viewport
    @sprites["title"].z = 2
    @mapinfos = $cache.mapinfos
    conns = $cache.connections
    @mapconns = []
    for c in conns
      @mapconns.push(c.clone)
    end
    if $game_map
      @currentmap = $game_map.map_id
    else
      @currentmap = $cache.RXsystem.edit_map_id
    end
    putSprite(@currentmap)
  end

  def setTopSprite(id)
    for i in @mapsprites.keys
      if i == id
        @mapsprites[i].z = 1
      else
        @mapsprites[i].z = 0
      end
    end
  end

  def serializeConnectionData
    conndata = generateConnectionData
    connectionsDumpFromData(conndata)
    compileConnections
    @mapconns = conndata
  end

  def helpWindow
    helptext = _INTL("A: Add map to canvas\n")
    helptext += _INTL("DEL: Delete map from canvas\n")
    helptext += _INTL("S: Go to another map\n")
    helptext += _INTL("Click to select a map\n")
    helptext += _INTL("Drag map to move it\n")
    helptext += _INTL("Arrow keys/drag canvas: Move around canvas")
    title = Window_UnformattedTextPokemon.new(helptext)
    title.x = 0
    title.y = 0
    title.width = Graphics.width * 8 / 10
    title.height = Graphics.height
    title.viewport = @viewport
    title.z = 2
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::C)
      break if Input.trigger?(Input::B)
    end
    Input.update
    title.dispose
  end

  def getMapRect(mapid)
    sprite = getMapSprite(mapid)
    if sprite
      return [
        sprite.x,
        sprite.y,
        sprite.x + sprite.bitmap.width,
        sprite.y + sprite.bitmap.height
      ]
    else
      return nil
    end
  end

  def onDoubleClick(mapid)
    # if mapid >= 0
    #   propertyList(mapid, LOCALMAPS)
    # else
    #   propertyList(0, GLOBALMETADATA)
    # end
  end

  def onClick(mapid, x, y)
    if @lastclick > 0 && Graphics.frame_count - @lastclick < 15 * $Settings.turboSpeedMultiplier
      onDoubleClick(mapid)
      @lastclick = -1
    else
      @lastclick = Graphics.frame_count
      if mapid >= 0
        @dragging = true
        @dragmapid = mapid
        sprite = getMapSprite(mapid)
        @sprites["selsprite"].othersprite = sprite
        @selmapid = mapid
        @dragOffsetX = sprite.x - x
        @dragOffsetY = sprite.y - y
        setTopSprite(mapid)
      else
        @sprites["selsprite"].othersprite = nil
        @dragging = true
        @dragmapid = mapid
        @selmapid = -1
        @dragOffsetX = x
        @dragOffsetY = y
        saveMapSpritePos
      end
    end
  end

  def onRightClick(mapid, x, y)
    #   echo("rightclick (#{mapid})\n")
  end

  def onMouseUp(mapid)
    #   echo("mouseup (#{mapid})\n")
    @dragging = false if @dragging
  end

  def onRightMouseUp(mapid)
    #   echo("rightmouseup (#{mapid})\n")
  end

  def onMouseOver(mapid, x, y)
    #   echo("mouseover (#{mapid},#{x},#{y})\n")
  end

  def onMouseMove(mapid, x, y)
    #   echo("mousemove (#{mapid},#{x},#{y})\n")
    if @dragging
      if @dragmapid >= 0
        sprite = getMapSprite(@dragmapid)
        x = x + @dragOffsetX
        y = y + @dragOffsetY
        sprite.x = x & ~3
        sprite.y = y & ~3
        @sprites["title"].text = _ISPRINTF("F5: Help [{1:03d} {2:s}]", mapid, @mapinfos[@dragmapid].name)
      else
        xpos = x - @dragOffsetX
        ypos = y - @dragOffsetY
        for i in @mapspritepos.keys
          sprite = getMapSprite(i)
          sprite.x = (@mapspritepos[i][0] + xpos) & ~3
          sprite.y = (@mapspritepos[i][1] + ypos) & ~3
        end
        @sprites["title"].text = _INTL("F5: Help")
      end
    else
      if mapid >= 0
        @sprites["title"].text = _ISPRINTF("F5: Help [{1:03d} {2:s}]", mapid, @mapinfos[mapid].name)
      else
        @sprites["title"].text = _INTL("F5: Help")
      end
    end
  end

  def hittest(x, y)
    for i in @mapsprites.keys
      sx = @mapsprites[i].x
      sy = @mapsprites[i].y
      sr = sx + @mapsprites[i].bitmap.width
      sb = sy + @mapsprites[i].bitmap.height
      return i if x >= sx && x < sr && y >= sy && y < sb
    end
    return -1
  end

  def chooseMapScreen(title, currentmap)
    return pbListScreen(title, MapLister.new(currentmap))
  end

  def update
    mousepos = Mouse::getMousePos
    if mousepos
      hitmap = hittest(mousepos[0], mousepos[1])
      if Input.triggerex?(0x01)
        onClick(hitmap, mousepos[0], mousepos[1])
      elsif Input.triggerex?(0x02)
        onRightClick(hitmap, mousepos[0], mousepos[1])
      elsif Input.releaseex?(0x01)
        onMouseUp(hitmap)
      elsif Input.releaseex?(0x02)
        onRightMouseUp(hitmap)
      else
        if @lasthitmap != hitmap
          onMouseOver(hitmap, mousepos[0], mousepos[1])
          @lasthitmap = hitmap
        end
        if @oldmousex != mousepos[0] || @oldmousey != mousepos[1]
          onMouseMove(hitmap, mousepos[0], mousepos[1])
          @oldmousex = mousepos[0]
          @oldmousey = mousepos[1]
        end
      end
    end
    if Input.press?(Input::UP)
      for i in @mapsprites
        next if !i

        i[1].y += 4
      end
    end
    if Input.press?(Input::DOWN)
      for i in @mapsprites
        next if !i

        i[1].y -= 4
      end
    end
    if Input.press?(Input::LEFT)
      for i in @mapsprites
        next if !i

        i[1].x += 4
      end
    end
    if Input.press?(Input::RIGHT)
      for i in @mapsprites
        next if !i

        i[1].x -= 4
      end
    end
    if Input.triggerex?(:A)
      id = chooseMapScreen(_INTL("Add Map"), @currentmap)
      if id > 0
        addSprite(id)
        setTopSprite(id)
        @mapconns = generateConnectionData
      end
    elsif Input.triggerex?(:S)
      id = chooseMapScreen(_INTL("Go to Map"), @currentmap)
      if id > 0
        @mapconns = generateConnectionData
        pbDisposeSpriteHash(@mapsprites)
        @mapsprites.clear
        @sprites["selsprite"].othersprite = nil
        @selmapid = -1
        putSprite(id)
        @currentmap = id
      end
    elsif Input.triggerex?(0x2E) # Delete
      if @mapsprites.keys.length > 1 && @selmapid >= 0
        @mapsprites[@selmapid].bitmap.dispose
        @mapsprites[@selmapid].dispose
        @mapsprites.delete(@selmapid)
        @sprites["selsprite"].othersprite = nil
        @selmapid = -1
      end
    elsif Input.trigger?(Input::F5)
      helpWindow
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbMapScreenLoop
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::B)
        if Kernel.pbConfirmMessage(_INTL("Save changes?"))
          serializeConnectionData
          # message saying to compile?
        end
        break if Kernel.pbConfirmMessage(_INTL("Exit from the editor?"))
      end
    end
  end
end

def pbEditorScreen
  pbCriticalCode {
    mapscreen = MapScreenScene.new
    mapscreen.mapScreen
    mapscreen.pbMapScreenLoop
    mapscreen.close
  }
end

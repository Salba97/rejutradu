def adjustBattleSprite(sprite, cacheData, index)
  spritewidth = (sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.bitmap.width : 128
  x = -spritewidth / 2
  spriteheight = (sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.bitmap.height : 128
  y = -spriteheight
  if index.odd? # Opposing side's Pokémon
    x += cacheData.BattlerEnemyX * 2
    y += cacheData.BattlerEnemyY * 2
  else # Player side's Pokémon
    x += cacheData.BattlerPlayerX * 2
    y += cacheData.BattlerPlayerY * 2
  end
  return x, y
end

def adjustShadowSpriteX(sprite, cacheData)
  ret = 0
  ret -= sprite.bitmap.width / 2
  ret += cacheData.BattlerShadowX * 2
  return ret
end

def pbPositionPokemonSprite(sprite, left, top)
  if sprite.bitmap && !sprite.bitmap.disposed?
    sprite.x = left + (128 - sprite.bitmap.width) / 2
    sprite.y = top + (128 - sprite.bitmap.height) / 2
  else
    sprite.x = left
    sprite.y = top
  end
end

def pbSpriteSetCenter(sprite, cx, cy)
  return if !sprite

  if !sprite.bitmap
    sprite.x = cx
    sprite.y = cy
    return
  end
  realwidth = sprite.bitmap.width * sprite.zoom_x
  realheight = sprite.bitmap.height * sprite.zoom_y
  sprite.x = cx - (realwidth / 2)
  sprite.y = cy - (realheight / 2)
end

AURA_SPRITE_OFFSET = 8

class PokemonSprite < SpriteWrapper
  def initialize(viewport = nil)
    super(viewport)
    @_iconbitmap = nil
  end

  def dispose
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      self.bitmap = @_iconbitmap.bitmap
    end
  end

  def setPokemonBitmap(pokemon, back = false, battle: false)
    @_iconbitmap.dispose if @_iconbitmap
    self.bitmap = pbLoadPokemonBitmap(pokemon, back, battle: battle)
    self.color = Color.new(0, 0, 0, 0)
  end

  def setBitmap(value)
    @_iconbitmap.dispose if @_iconbitmap
    self.bitmap = value
    self.color = Color.new(0, 0, 0, 0)
  end
end

class PokemonIconSprite < SpriteWrapper
  attr_accessor :selected
  attr_accessor :active
  attr_reader :pokemon

  def initialize(pokemon, viewport = nil, vleague: false)
    super(viewport)
    @animbitmap = nil
    if vleague
      @frames = [
        Rect.new(0, 0, 32 + AURA_SPRITE_OFFSET, 32 + AURA_SPRITE_OFFSET),
        Rect.new(32 + AURA_SPRITE_OFFSET, 0, 32 + AURA_SPRITE_OFFSET, 32 + AURA_SPRITE_OFFSET)
      ]
    else
      @frames = [
        Rect.new(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET),
        Rect.new(64 + AURA_SPRITE_OFFSET, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
      ]
    end
    @selected = false
    @animframe = 0
    @active = false
    @frame = 0
    @pokemon = pokemon
    @adjusted_x = -(AURA_SPRITE_OFFSET / 2)
    @adjusted_y = -(AURA_SPRITE_OFFSET / 2)
    @logical_x = 0
    @logical_y = 0
    if @pokemon
      self.bitmap = pbPokemonIconBitmap(@pokemon, vleague: vleague)
      self.src_rect = @frames[@animframe]
    else
      self.bitmap = nil
    end
  end

  def pokemon=(value)
    @pokemon = value
    @animbitmap.dispose if @animbitmap
    @animbitmap = nil
    if @pokemon
      self.bitmap = pbPokemonIconBitmap(@pokemon)
      self.src_rect = @frames[@animframe]
    else
      self.bitmap = nil
    end
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    super
  end

  def x
    @logical_x
  end

  def y
    @logical_y
  end

  def x=(value)
    @logical_x = value
    super(@logical_x + @adjusted_x)
  end

  def y=(value)
    @logical_y = value
    super(@logical_y + @adjusted_y)
  end

  def update
    @updating = true
    super
    if @animbitmap
      @animbitmap.update
      self.bitmap = @animbitmap.bitmap
      self.src_rect = @frames[@animframe]
    end
    self.color = Color.new(0, 0, 0, 0)
    frameskip = 5
    frameskip = 10 if @pokemon && @pokemon.hp <= (@pokemon.totalhp / 2.0)
    frameskip = 20 if @pokemon && @pokemon.hp <= (@pokemon.totalhp / 4.0)
    frameskip = -1 if @pokemon && @pokemon.hp == 0
    if frameskip == -1
      @animframe = 0
      self.src_rect = @frames[@animframe]
    else
      @frame += 1
      @frame = 0 if @frame > 100
      if @frame >= frameskip
        @animframe = (@animframe == 1) ? 0 : 1
        self.src_rect = @frames[@animframe]
        @frame = 0
      end
    end
    if self.selected
      @adjusted_x = 4 - (AURA_SPRITE_OFFSET / 2)
      @adjusted_y = (@animframe == 0) ? -2 : 6 - (AURA_SPRITE_OFFSET / 2)
    else
      @adjusted_x = 0 - (AURA_SPRITE_OFFSET / 2)
      @adjusted_y = 0 - (AURA_SPRITE_OFFSET / 2)
    end
    @updating = false
    self.x = self.x
    self.y = self.y
  end
end

class PokemonShadowSprite < SpriteWrapper
  SUBSTITUTE_SHADOW_SIZE = 19
  SHADOW_COLOR = Color.new(18, 21, 63, 120)

  def initialize(viewport = nil)
    super(viewport)
    @_iconbitmap = nil
  end

  def dispose
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def x=(value)
    super(value.to_grid)
  end

  def y=(value)
    super(value.to_grid)
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      self.bitmap = @_iconbitmap.bitmap
    end
  end

  def setPokemonShadowBitmap(cacheData, change = 0)
    @_iconbitmap.dispose if @_iconbitmap
    shadow = cacheData == "substitute" ? SUBSTITUTE_SHADOW_SIZE : cacheData.BattlerShadowSize
    self.bitmap = drawEllipse(shadow + change, SHADOW_COLOR)
  end

  def drawEllipse(rx, color)
    return BitmapWrapper.new(1, 1) if rx <= 0

    # Get vertical radius, get dimensions, create bitmap at double dimensions
    ry = (rx + 15) / 8.0
    width = rx * 2
    height = (ry * 2).round
    bitmap = BitmapWrapper.new(width * 2, height * 2)
    # Get center of ellipse
    cx = width / 2.0
    cy = height / 2.0

    (0...height).each do |py|
      # Vertical distance from center, normalized to -1 <= dy >= 1
      dy = (py + 0.5 - cy) / ry
      dy2 = dy * dy
      # Horizontal distance for this row
      half_width = rx * Math.sqrt(1.0 - dy2)
      left = (cx - half_width).ceil
      right = (cx + half_width).floor
      # Draw the row
      bitmap.fill_rect(left * 2, py * 2, (right - left + 1) * 2, 2, color)
    end

    return bitmap
  end
end

# Used by the pokedex to display pokemon icons
class PokemonSpeciesIconSprite < SpriteWrapper
  attr_accessor :selected
  attr_accessor :active
  attr_reader :species
  attr_reader :gender
  attr_reader :form
  attr_reader :shiny
  attr_reader :shadow
  attr_reader :egg
  attr_reader :battle

  def initialize(species, gender, form, shiny, shadow = false, viewport = nil)
    super(viewport)
    @animbitmap = nil
    @frames = [
      Rect.new(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET),
      Rect.new(64 + AURA_SPRITE_OFFSET, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
    ]
    @animframe = 0
    @frame = 0
    @logical_x = 0
    @logical_y = 0
    @adjusted_x = -(AURA_SPRITE_OFFSET / 2)
    @adjusted_y = -(AURA_SPRITE_OFFSET / 2)
    @species = species
    @gender = gender
    @form = form
    @shiny = shiny
    @shadow = shadow
    refresh
  end

  def species=(value)
    @species = value
    refresh
  end

  def gender=(value)
    @gender = value
    refresh
  end

  def form=(value)
    @form = value
    refresh
  end

  def shiny=(value)
    @shiny = value
    refresh
  end

  def shadow=(value)
    @shadow = value
    refresh
  end

  def egg=(value)
    @egg = value
    refresh
  end

  def battle=(value)
    @battle = value
    refresh
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    super
  end

  def x
    @logical_x
  end

  def y
    @logical_y
  end

  def x=(value)
    @logical_x = value
    super(@logical_x + @adjusted_x)
  end

  def y=(value)
    @logical_y = value
    super(@logical_y + @adjusted_y)
  end

  def refresh
    @animbitmap.dispose if @animbitmap
    @animbitmap = nil
    self.bitmap = pbIconBitmap(@species, @form, @shiny, @gender == :F, @egg, @shadow, !@battle)
    self.src_rect = @frames[@animframe]
  end

  def update
    @updating = true
    super
    if @animbitmap
      @animbitmap.update
      self.bitmap = @animbitmap.bitmap
      self.src_rect = @frames[@animframe]
    end
    frameskip = 5
    @frame += 1
    @frame = 0 if @frame > 10
    if @frame >= frameskip
      @animframe = @animframe == 1 ? 0 : 1
      self.src_rect = @frames[@animframe]
      @frame = 0
    end
    @updating = false
    self.x = self.x
    self.y = self.y
  end
end

class TrainerWalkingCharSprite < SpriteWrapper
  def initialize(charset, viewport = nil)
    super(viewport)
    @animbitmap = nil
    self.charset = charset
    @animframe = 0   # Current frame
    @frame = 0       # Counter
    @frameskip = 6   # Animation speed
  end

  def charset=(value)
    @animbitmap.dispose if @animbitmap
    @animbitmap = nil
    bitmapFileName = sprintf("Graphics/Characters/%s", value)
    @charset = pbResolveBitmap(bitmapFileName)
    if @charset
      @animbitmap = AnimatedBitmap.new(@charset)
      self.bitmap = @animbitmap.bitmap
      self.src_rect.set(0, 0, self.bitmap.width / 4, self.bitmap.height / 4)
    else
      self.bitmap = nil
    end
  end

  def altcharset=(value) # Used for box icon in the naming screen
    @animbitmap.dispose if @animbitmap
    @animbitmap = nil
    @charset = pbResolveBitmap(value)
    if @charset
      @animbitmap = AnimatedBitmap.new(@charset)
      self.bitmap = @animbitmap.bitmap
      self.src_rect.set(0, 0, self.bitmap.width / 4, self.bitmap.height)
    else
      self.bitmap = nil
    end
  end

  def animspeed=(value)
    @frameskip = value
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    super
  end

  def update
    @updating = true
    super
    if @animbitmap
      @animbitmap.update
      self.bitmap = @animbitmap.bitmap
    end
    @frame += 1
    @frame = 0 if @frame > 100
    if @frame >= @frameskip
      @animframe = (@animframe + 1) % 4
      self.src_rect.x = @animframe * @animbitmap.bitmap.width / 4
      @frame = 0
    end
    @updating = false
  end
end

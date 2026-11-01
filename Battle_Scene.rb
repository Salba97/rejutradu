=begin
- def pbWildBattleSuccess
This method is called when the player wins a wild Pokémon battle.
This method can change the battle's music for example.

- def pbTrainerBattleSuccess
This method is called when the player wins a Trainer battle.
This method can change the battle's music for example.

- def pbFainted(pkmn)
This method is called whenever a Pokémon faints.
pkmn - PokeBattle_Battler object indicating the Pokémon that fainted

- def pbCommandMenu(index)
Use this method to display the list of commands and choose
a command for the player.
index - Index of battler (use e.g. @battle.battlers[index] to
access the battler)
Return values:
0 - Fight
1 - Pokémon
2 - Bag
3 - Run
=end

#===============================================================================
# Command menu (Fight/Pokémon/Bag/Run)
#===============================================================================
class CommandMenuDisplay
  attr_accessor :mode

  def initialize(viewport = nil)
    @display = nil
    if PBScene::USECOMMANDBOX
      @display = IconSprite.new(0, Graphics.height - 96, viewport)
      @display.setBitmap("Graphics/Pictures/Battle/battleCommand")
    end
    @window = Window_CommandPokemon.newWithSize([], Graphics.width - 240, Graphics.height - 96, 240, 96, viewport)
    @window.columns = 2
    @window.columnSpacing = 4
    @window.ignore_input = true
    @msgbox = Window_UnformattedTextPokemon.newWithSize("", 16, Graphics.height - 96 + 2, 220, 96, viewport)
    @msgbox.baseColor = PBScene::MESSAGEBASE
    @msgbox.shadowColor = PBScene::MESSAGESHADOW
    @msgbox.windowskin = nil
    @title = ""
    @buttons = nil
    if PBScene::USECOMMANDBOX
      @window.opacity = 0
      @window.x = Graphics.width
      @buttons = CommandMenuButtons.new(self.index, self.mode, viewport)
    end
  end

  def x; @window.x; end

  def x=(value)
    @window.x = value
    @msgbox.x = value
    @display.x = value if @display
    @buttons.x = value if @buttons
  end

  def y; @window.y; end

  def y=(value)
    @window.y = value
    @msgbox.y = value
    @display.y = value if @display
    @buttons.y = value if @buttons
  end

  def z; @window.z; end

  def z=(value)
    @window.z = value
    @msgbox.z = value
    @display.z = value if @display
    @buttons.z = value + 1 if @buttons
  end

  def ox; @window.ox; end

  def ox=(value)
    @window.ox = value
    @msgbox.ox = value
    @display.ox = value if @display
    @buttons.ox = value if @buttons
  end

  def oy; @window.oy; end

  def oy=(value)
    @window.oy = value
    @msgbox.oy = value
    @display.oy = value if @display
    @buttons.oy = value if @buttons
  end

  def visible; @window.visible; end

  def visible=(value)
    @window.visible = value
    @msgbox.visible = value
    @display.visible = value if @display
    @buttons.visible = value if @buttons
  end

  def color; @window.color; end

  def color=(value)
    @window.color = value
    @msgbox.color = value
    @display.color = value if @display
    @buttons.color = value if @buttons
  end

  def disposed?
    return @msgbox.disposed? || @window.disposed?
  end

  def dispose
    return if disposed?

    @msgbox.dispose
    @window.dispose
    @display.dispose if @display
    @buttons.dispose if @buttons
  end

  def index
    @window.index
  end

  def index=(value)
    @window.index = value
  end

  def setTexts(value)
    @msgbox.text = value[0]
    commands = []
    for i in 1..4
      commands.push(value[i]) if value[i] && value[i] != nil
    end
    @window.commands = commands
  end

  def refresh
    @msgbox.refresh
    @window.refresh
    @buttons.refresh(self.index, self.mode) if @buttons
  end

  def update
    @msgbox.update
    @window.update
    @display.update if @display
    @buttons.update(self.index, self.mode) if @buttons
  end
end

class CommandMenuButtons < BitmapSprite
  def initialize(index = 0, mode = 0, viewport = nil)
    super(260, 96, viewport)
    self.x = Graphics.width - 260
    self.y = Graphics.height - 96
    @mode = mode
    @buttonbitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/battleCommandButtons")
    refresh(index, mode)
  end

  def dispose
    @buttonbitmap.dispose
    super
  end

  def update(index = 0, mode = 0)
    refresh(index, mode)
  end

  def refresh(index, mode = 0) # Command Menu Modes
    self.bitmap.clear
    @mode = mode
    cmdarray = [0, 2, 1, 3]
    case @mode
      when 1
        cmdarray = [0, 2, 1, 4] # Use "Call"
      when 2
        cmdarray = [5, 7, 6, 3] # Safari Zone battle
      when 3
        cmdarray = [0, 8, 1, 3] # Bug Catching Contest
      when 4
        cmdarray = [0, 2, 1, 10] # Rejuv Specialmoves
      when 5
        cmdarray = [10] # Rejuv Specialmoves
    end
    for i in 0...4
      next if i == index
      next if !cmdarray[i]
      x = (i % 2) == 0 ? 0 : 126
      y = (i / 2) == 0 ? 6 : 48
      self.bitmap.blt(x, y, @buttonbitmap.bitmap, Rect.new(0, cmdarray[i] * 46, 130, 46))
    end
    for i in 0...4
      next if i != index
      next if !cmdarray[i]
      x = (i % 2) == 0 ? 0 : 126
      y = (i / 2) == 0 ? 6 : 48
      self.bitmap.blt(x, y, @buttonbitmap.bitmap, Rect.new(130, cmdarray[i] * 46, 130, 46))
    end
  end
end

class FightMenuDisplaySpecial
  attr_reader :battler
  attr_reader :index
  attr_accessor :specialButton

  def initialize(battler, viewport = nil)
    @display = nil
    if PBScene::USEFIGHTBOX
      @display = IconSprite.new(0, Graphics.height - 96, viewport)
      @display.setBitmap("Graphics/Pictures/Battle/battleFightSpecial")
    end
    @window = Window_CommandPokemon.newWithSize([], 0, Graphics.height - 96, 320, 96, viewport)
    @window.tts = false
    @window.columns = 2
    @window.columnSpacing = 4
    @window.ignore_input = true
    pbSetNarrowFont(@window.contents)
    @info = Window_AdvancedTextPokemon.newWithSize(
      "", 320, Graphics.height - 96, Graphics.width - 320, 96, viewport
    )
    pbSetNarrowFont(@info.contents)
    @ctag = shadowctag(PBScene::MENUBASE, PBScene::MENUSHADOW)
    @buttons = nil
    @battler = battler
    @index = 0
    @specialButton = 0 # 0=don't show, 1=show, 2=pressed
    if PBScene::USEFIGHTBOX
      @window.opacity = 0
      @window.x = Graphics.width
      @info.opacity = 0
      @info.x = Graphics.width + Graphics.width - 96
      @buttons = FightMenuButtonsSpecial.new(self.index, nil, viewport, battler)
    end
    refresh
  end

  def x; @window.x; end

  def x=(value)
    @window.x = value
    @info.x = value
    @display.x = value if @display
    @buttons.x = value if @buttons
  end

  def y; @window.y; end

  def y=(value)
    @window.y = value
    @info.y = value
    @display.y = value if @display
    @buttons.y = value if @buttons
  end

  def z; @window.z; end

  def z=(value)
    @window.z = value
    @info.z = value
    @display.z = value if @display
    @buttons.z = value + 1 if @buttons
  end

  def ox; @window.ox; end

  def ox=(value)
    @window.ox = value
    @info.ox = value
    @display.ox = value if @display
    @buttons.ox = value if @buttons
  end

  def oy; @window.oy; end

  def oy=(value)
    @window.oy = value
    @info.oy = value
    @display.oy = value if @display
    @buttons.oy = value if @buttons
  end

  def visible; @window.visible; end

  def visible=(value)
    @window.visible = value
    @info.visible = value
    @display.visible = value if @display
    @buttons.visible = value if @buttons
  end

  def color; @window.color; end

  def color=(value)
    @window.color = value
    @info.color = value
    @display.color = value if @display
    @buttons.color = value if @buttons
  end

  def disposed?
    return @info.disposed? || @window.disposed?
  end

  def dispose
    return if disposed?

    @info.dispose
    @display.dispose if @display
    @buttons.dispose if @buttons
    @window.dispose
  end

  def battler=(value)
    @battler = value
    refresh
  end

  def setIndex(value)
    if @battler && @battler.specialmoves[value]
      @index = value
      @window.index = value
      refresh
      return true
    end
    return false
  end

  def refresh
    return if !@battler

    commands = []
    for i in 0...@battler.specialmoves.length
      break if !@battler.specialmoves[i]

      commands.push(@battler.specialmoves[i].name)
    end
    @window.commands = commands
    selmove = @battler.specialmoves[@index] ? @battler.specialmoves[@index] : @battler.specialmoves[0]
    movetype = getTypeName(selmove.type)
    if selmove.totalpp == 0
      @info.text = _ISPRINTF("{1:s}PP: ---<br>TYPE/{2:s}", @ctag, movetype)
    else
      @info.text = _ISPRINTF("{1:s}PP: {2: 2d}/{3: 2d}<br>TYPE/{4:s}", @ctag, selmove.pp, selmove.totalpp, movetype)
    end
  end

  def update
    @info.update
    @window.update
    @display.update if @display
    if @buttons
      @buttons.update(self.index, @battler, @specialButton)
    end
  end
end

class DefaultBallDisplay
  attr_reader :canthrow
  attr_reader :selected

  def initialize(battle, viewport)
    @battle = battle
    @display = DefaultBallButton.new(self, viewport)
    @canthrow = false
    @selected = false
  end

  def x; @display.x; end

  def x=(value); @display.x = value; end

  def y; @display.y; end

  def y=(value); @display.y = value; end

  def z; @display.z; end

  def z=(value); @display.z = value; end

  def ox; @display.ox; end

  def ox=(value); @display.ox = value; end

  def oy; @display.oy; end

  def oy=(value); @display.oy = value; end

  def visible; @display.visible; end

  def visible=(value); @display.visible = value; end

  def color; @display.color; end

  def color=(value); @display.color = value; end

  def disposed?; @display.disposed?; end

  def dispose; @display.dispose; end

  def update; @display.update; end

  def pbSet(index)
    $PokemonBag.setDefaultBall()
    @canthrow = @battle.pbCanThrowDefaultBall?(index)
    @selected = false
    @display.x = @display.bitmap.width * -1 # Put graphic off-screen at start of turn
    @display.pbRedraw
  end

  def pbSelect
    self.pbToggle
    loop do
      Graphics.update
      Input.update
      @display.update
      self.pbChange(-1) if Input.repeat?(Input::LEFT) || Input.repeat?(Input::UP)
      self.pbChange(1) if Input.repeat?(Input::RIGHT) || Input.repeat?(Input::DOWN)
      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        return true
      end
      if Input.trigger?(Input::B) || Input.trigger?(Input::A)
        self.pbToggle
        return false
      end
    end
  end

  def pbToggle
    @selected = !@selected
    if @selected
      pbPlayCursorSE()
      tts(_INTL("Default Poké Ball selected."), true)
      ball = $PokemonBag.defaultBall
      tts(_INTL("{1}, In Bag: {2}", getItemName(ball), $PokemonBag.pbQuantity(ball)))
    else
      pbPlayCancelSE()
      tts(_INTL("Default Poké Ball unselected."), true)
    end
    @display.pbRedraw
  end

  def pbChange(num)
    balls = $PokemonBag.pockets[POKEBALLPOCKET]
    oldballindex = balls.index($PokemonBag.defaultBall)
    newballindex = oldballindex + num
    newballindex = 0 if newballindex > balls.length - 1 # num +ve
    newballindex = balls.length - 1 if newballindex < 0 # num -ve
    if newballindex == oldballindex
      pbPlayBuzzerSE()
    else
      $PokemonBag.defaultBall = balls[newballindex]
      pbPlayCursorSE()
      ball = $PokemonBag.defaultBall
      tts(_INTL("{1}, In Bag: {2}", getItemName(ball), $PokemonBag.pbQuantity(ball)), true)
      @display.pbRedraw
    end
  end
end

class FightMenuButtonsSpecial < BitmapSprite
  UPPERGAP = 46

  def initialize(index = 0, moves = nil, viewport = nil, battler = nil)
    super(Graphics.width, 96 + UPPERGAP, viewport)
    self.x = 0
    self.y = Graphics.height - 96 - UPPERGAP
    pbSetNarrowFont(self.bitmap)
    refresh(index, moves, 0)
  end

  def dispose
    super
  end

  def update(index = 0, battler = nil, specialButton = 0)
    refresh(index, battler, specialButton)
  end

  def refresh(index, battler, specialButton)
    return if !battler

    moves = nil
    if battler.specialmoves
      moves = []
      for move in battler.specialmoves
        moves.push(move)
      end
    end
    return if !moves

    self.bitmap.clear
    if !battler.battle.opponent.is_a?(Array)
      firstsetspecialmoves = battler.battle.opponent.trainertype == :KINGANDQUEEN ? true : false
      moves_string = firstsetspecialmoves ? "Graphics/Pictures/Battle/battleAllies" : "Graphics/Pictures/Battle/battleAGANG"
    end

    if moves.length > 4
      basex = 12
      xincrement = 66
    else
      basex = 16
      xincrement = 136
    end
    textpos = []
    for i in 0...moves.length
      next if i == index
      next if !moves[i]

      x = basex + (xincrement * i)
      y = 6
      y += UPPERGAP
      imagepos = []
      interval = 0
      case moves[i].move
      when :LONELYMOON, :PROMISEDALAIN
        interval = 0
      when :ORBITALRING, :PROMISEDAXEL
        interval = 1
      when :VENGEFULNUKE, :PROMISEDAERO
        interval = 2
      when :REJUVENATION, :PROMISEDAEVIA
        interval = 3
      when :PROMISEDAEVIS
        interval = 4
      when :PROMISEDARIANA
        interval = 5
      when :PROMISEDANA
        interval = 6
      when
        interval = 1
      end
      if firstsetspecialmoves
        imagepos.push([sprintf(moves_string), x, y, 0, interval * 51, 54, 51])
      else
        imagepos.push([sprintf(moves_string), x, y, 0, interval * 44, 44, 44])
      end
      pbDrawImagePositions(self.bitmap, imagepos)
    end
    for i in 0...moves.length
      next if i != index
      next if !moves[i]

      x = basex + (xincrement * i)
      y = 6
      y += UPPERGAP
      imagepos = []
      interval = 0
      case moves[i].move
      when :LONELYMOON, :PROMISEDALAIN
        interval = 0
      when :ORBITALRING, :PROMISEDAXEL
        interval = 1
      when :VENGEFULNUKE, :PROMISEDAERO
        interval = 2
      when :REJUVENATION, :PROMISEDAEVIA
        interval = 3
      when :PROMISEDAEVIS
        interval = 4
      when :PROMISEDARIANA
        interval = 5
      when :PROMISEDANA
        interval = 6
      when
        interval = 1
      end
      if firstsetspecialmoves
        imagepos.push([sprintf(moves_string), x, y, 54, interval * 51, 54, 51])
      else
        imagepos.push([sprintf(moves_string), x, y, 44, interval * 44, 44, 44])
      end
    end
    pbDrawImagePositions(self.bitmap, imagepos)
    pbDrawTextPositions(self.bitmap, textpos)
  end
end

class DefaultBallButton < BitmapSprite
  GraphicSize = [50, 46] # width, height
  BallOffset = [8, 4] # x, y
  LeftArrowOffset = [2, 14] # x, y
  RightArrowOffset = [40, 14] # x, y
  TextBoxOffsetX = 2
  TextBoxOffsetY = 24
  TextBoxWidth = 44
  TextColors = [PBScene::BOXBASE, nil]

  def initialize(wrapper, viewport)
    super(*GraphicSize, viewport)
    @wrapper = wrapper
    @frame = 0
    @spriteY = 0
    @spriteYExtra = 0
    self.y = ((Graphics.height - 96) / 2) - 32
  end

  def y=(value)
    @spriteY = value
    super(value + @spriteYExtra)
  end

  def dispose
    return if self.disposed?
    [@slot, @ball, @left, @right].each { |i| i.dispose if i }
    super
  end

  def update
    # Make graphic bob while the option is selected
    @frame += 1
    @spriteYExtra = ((@frame / 10).floor & 1) == 1 && @wrapper.selected ? 2 : 0
    self.y = @spriteY

    # Make graphic slide onto screen at start of turn
    self.x = [self.x + 4, 0].min if self.x < 0
  end

  def pbRedraw
    @slot, @ball, @left, @right = nil, nil, nil, nil, nil
    text = nil

    if @wrapper.canthrow
      filename = "Graphics/Pictures/Battle/defaultBallSlot"
      @slot = Bitmap.new(filename) if pbResolveBitmap(filename)

      if @wrapper.selected
        filename = Reborn ?
          "Graphics/Pictures/Battle/#{$PokemonBag.defaultBall}" :
          pbItemIconFile($PokemonBag.defaultBall)
        @ball = Bitmap.new(filename) if pbResolveBitmap(filename)
        if $PokemonBag.pockets[POKEBALLPOCKET].length > 1
          @left = shapeBitmap(:CursorLeft, 6, TextColors[0])
          @right = shapeBitmap(:CursorRight, 6, TextColors[0])
        end

        text = $PokemonBag.pbQuantity($PokemonBag.defaultBall).to_s
        text_width = text.length * 8 # In the font we use here, the width of each digit character is 8 px
        text = nSubscript(text)
      else
        text = _INTL("z")
        text_width = self.bitmap.text_size(text).width

        @frame = 0
        @spriteYExtra = 0
        self.y = @spriteY
      end
    end

    self.bitmap.clear
    self.bitmap.blt(0, 0, @slot, Rect.new(0, 0, @slot.width, @slot.height)) if @slot
    if @ball
      rect = Reborn ?
        Rect.new(0, 16, @ball.width, 48) : # Height of image is 2x height of actual ball
        Rect.new(0, 0, @ball.width, @ball.height)
      self.bitmap.blt(*BallOffset, @ball, rect)
    end
    self.bitmap.blt(*LeftArrowOffset, @left, Rect.new(0, 0, @left.width, @left.height)) if @left
    self.bitmap.blt(*RightArrowOffset, @right, Rect.new(0, 0, @right.width, @right.height)) if @right
    if text
      pbSetSmallFont(self.bitmap)
      text_x = TextBoxOffsetX + ((TextBoxWidth / 2) - (text_width / 2)).to_grid
      text_y = TextBoxOffsetY
      # Draw a rectangular shadow behind the text, with 2px left/right/upper margins
      if Reborn && @wrapper.selected
        one_first = text.start_with?(nSubscript("1")) # "1" has 4px left margin instead of other numbers' 2px
        shadow_x = text_x - 2 + (one_first ? 2 : 0)
        shadow_width = text_width + 2 - (one_first ? 2 : 0)
        shadow = Bitmap.new(shadow_width, 12)
        shadow.fill_rect(Rect.new(0, 0, shadow.width, shadow.height), Color.new(23, 25, 26, 128))
        self.bitmap.blt(shadow_x, text_y + 4, shadow, Rect.new(0, 0, shadow.width, shadow.height))
      end
      pbDrawTextPositions(self.bitmap, [[text, text_x, text_y, :left, *TextColors]])
    end
  end
end

class FightMenuDisplay
  attr_reader :battler
  attr_reader :index
  attr_accessor :megaButton
  attr_accessor :ultraButton
  attr_accessor :teraButton
  attr_accessor :zButton

  def initialize(battler, viewport = nil)
    @display = nil
    if PBScene::USEFIGHTBOX
      @display = IconSprite.new(0, Graphics.height - 96, viewport)
      @display.setBitmap("Graphics/Pictures/Battle/battleFight")
    end
    @window = Window_CommandPokemon.newWithSize([], 0, Graphics.height - 96, 320, 96, viewport)
    @window.tts = false
    @window.columns = 2
    @window.columnSpacing = 4
    @window.ignore_input = true
    pbSetNarrowFont(@window.contents)
    @info = Window_AdvancedTextPokemon.newWithSize(
      "", 320, Graphics.height - 96, Graphics.width - 320, 96, viewport
    )
    pbSetNarrowFont(@info.contents)
    @ctag = shadowctag(PBScene::MENUBASE, PBScene::MENUSHADOW)
    @buttons = nil
    @battler = battler
    @index = 0
    @megaButton = 0 # 0=don't show, 1=show, 2=pressed
    @ultraButton = 0 # 0=don't show, 1=show, 2=pressed
    @teraButton = 0 # 0=don't show, 1=show, 2=pressed
    @zButton = 0 # 0=don't show, 1=show, 2=pressed
    if PBScene::USEFIGHTBOX
      @window.opacity = 0
      @window.x = Graphics.width
      @info.opacity = 0
      @info.x = Graphics.width + Graphics.width - 96
      @buttons = FightMenuButtons.new(self.index, nil, viewport)
    end
    refresh
  end

  def x; @window.x; end

  def x=(value)
    @window.x = value
    @info.x = value
    @display.x = value if @display
    @buttons.x = value if @buttons
  end

  def y; @window.y; end

  def y=(value)
    @window.y = value
    @info.y = value
    @display.y = value if @display
    @buttons.y = value if @buttons
  end

  def z; @window.z; end

  def z=(value)
    @window.z = value
    @info.z = value
    @display.z = value if @display
    @buttons.z = value + 1 if @buttons
  end

  def ox; @window.ox; end

  def ox=(value)
    @window.ox = value
    @info.ox = value
    @display.ox = value if @display
    @buttons.ox = value if @buttons
  end

  def oy; @window.oy; end

  def oy=(value)
    @window.oy = value
    @info.oy = value
    @display.oy = value if @display
    @buttons.oy = value if @buttons
  end

  def visible; @window.visible; end

  def visible=(value)
    @window.visible = value
    @info.visible = value
    @display.visible = value if @display
    @buttons.visible = value if @buttons
  end

  def color; @window.color; end

  def color=(value)
    @window.color = value
    @info.color = value
    @display.color = value if @display
    @buttons.color = value if @buttons
  end

  def disposed?
    return @info.disposed? || @window.disposed?
  end

  def dispose
    return if disposed?

    @info.dispose
    @display.dispose if @display
    @buttons.dispose if @buttons
    @window.dispose
  end

  def battler=(value)
    @battler = value
    refresh
  end

  def setIndex(value)
    if @battler && (@battler.moves[value] || @zButton == 2 && @battler.zmoves[value])
      @index = value
      @window.index = value
      refresh
      return true
    end
    return false
  end

  def refresh
    return if !@battler

    commands = []
    for i in 0...@battler.moves.length
      break if !@battler.moves[i]

      commands.push(@battler.moves[i].shortname)
    end
    @window.commands = commands
    selmove = @battler.moves[@index] ? @battler.moves[@index] : @battler.moves[0]
    movetype = getTypeName(selmove.type)
    if selmove.totalpp == 0
      @info.text = _ISPRINTF("{1:s}PP: ---<br>TYPE/{2:s}", @ctag, movetype)
    else
      @info.text = _ISPRINTF("{1:s}PP: {2: 2d}/{3: 2d}<br>TYPE/{4:s}", @ctag, selmove.pp, selmove.totalpp, movetype)
    end
  end

  def update
    @info.update
    @window.update
    @display.update if @display
    if @buttons
      @buttons.update(self.index, @battler, @megaButton, @zButton, @ultraButton, @teraButton)
    end
  end
end

class FightMenuButtons < BitmapSprite
  UPPERGAP = 46

  def initialize(index = 0, moves = nil, viewport = nil)
    super(Graphics.width, 96 + UPPERGAP, viewport)
    self.x = 0
    self.y = Graphics.height - 96 - UPPERGAP
    pbSetNarrowFont(self.bitmap)
    @megaevobitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/battleMegaEvo")
    @ultraburstbitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/battleUltra")
    @terastalbitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/battleTerastal")
    @zmovebitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/battleZMove")
    @goodmovebitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/fieldUp")
    @badmovebitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/fieldDown")
    refresh(index, moves, 0, 0, 0, 0)
  end

  def dispose
    @megaevobitmap.dispose
    @ultraburstbitmap.dispose
    @terastalbitmap.dispose
    @zmovebitmap.dispose
    @goodmovebitmap.dispose
    @badmovebitmap.dispose
    super
  end

  def update(index = 0, battler = nil, megaButton = 0, zButton = 0, ultraButton = 0, teraButton = 0)
    refresh(index, battler, megaButton, zButton, ultraButton, teraButton)
  end

  def refresh(index, battler, megaButton, zButton, ultraButton, teraButton)
    return if !battler

    moves = nil
    if battler.moves
      moves = []
      for move in battler.moves
        moves.push(move)
      end
    end
    if zButton == 2 && !battler.zmoves.nil?
      for i in 0...battler.zmoves.length
        next if battler.zmoves[i].nil?

        moves[i] = battler.zmoves[i]
      end
    end
    return if !moves

    self.bitmap.clear
    textpos = []
    for i in 0...4
      next if i == index
      next if !moves[i]

      x = ((i % 2) == 0) ? 4 : 192
      y = ((i / 2) == 0) ? 6 : 48
      y += UPPERGAP
      imagepos = []
      movetype = pbMoveBattleSceneType(moves[i], battler)
      imagepos.push([sprintf("Graphics/Pictures/Battle/battleFightButtons%s", movetype), x, y, 0, 0, 192, 46])
      pbDrawImagePositions(self.bitmap, imagepos)
      textpos.push([moves[i].shortname, x + 96, y + 12, 2, PBScene::MENUBASE, PBScene::MENUSHADOW])
    end
    ppcolors = [
      PBScene::PPBASE, PBScene::PPSHADOW,
      PBScene::PPBASE, PBScene::PPSHADOW,
      PBScene::PPBASEYELLOW, PBScene::PPSHADOWYELLOW,
      PBScene::PPBASEORANGE, PBScene::PPSHADOWORANGE,
      PBScene::PPBASERED, PBScene::PPSHADOWRED
    ]
    for i in 0...4
      next if i != index
      next if !moves[i]

      x = ((i % 2) == 0) ? 4 : 192
      y = ((i / 2) == 0) ? 6 : 48
      y += UPPERGAP
      imagepos = []
      movetype = pbMoveBattleSceneType(moves[i], battler)
      secondtype = moves[i].getSecondaryType(battler, movetype, placeholders: true)
      if secondtype == [] || secondtype.include?(movetype)
        imagepos.push([sprintf("Graphics/Icons/type%s", movetype), 416, 20 + UPPERGAP, 0, 0, 64, 28])
      elsif secondtype.length == 1
        imagepos.push([sprintf("Graphics/Icons/type%s", movetype), 402, 20 + UPPERGAP, 0, 0, 64, 28])
        imagepos.push([sprintf("Graphics/Icons/minitype%s", secondtype[0]), 466, 20 + UPPERGAP, 0, 0, 28, 28])
      else
        imagepos.push([sprintf("Graphics/Icons/minitype%s", movetype), 404, 20 + UPPERGAP, 0, 0, 64, 28])
        imagepos.push([sprintf("Graphics/Icons/minitype%s", secondtype[0]), 432, 20 + UPPERGAP, 0, 0, 28, 28])
        imagepos.push([sprintf("Graphics/Icons/minitype%s", secondtype[1]), 460, 20 + UPPERGAP, 0, 0, 28, 28])
      end
      imagepos.push([sprintf("Graphics/Pictures/Battle/battleFightButtons%s", movetype), x, y, 192, 0, 192, 46])
      textpos.push([moves[i].shortname, x + 96, y + 12, 2, PBScene::MENUBASE, PBScene::MENUSHADOW])
      if moves[i].totalpp > 0
        ppfraction = (4.0 * moves[i].pp / moves[i].totalpp).ceil
        textpos.push([_INTL("PP: {1}/{2}", moves[i].pp, moves[i].totalpp), 448, 50 + UPPERGAP, 2, ppcolors[(4 - ppfraction) * 2], ppcolors[(4 - ppfraction) * 2 + 1]])
      end
    end
    pbDrawImagePositions(self.bitmap, imagepos)
    for i in 0...4
      next if !moves[i]

      x = ((i % 2) == 0) ? 4 : 192
      y = ((i / 2) == 0) ? 6 : 48
      y += UPPERGAP
      y -= 2 if Rejuv
      case pbFieldMoveHighlights(moves[i], battler)
        when :buff then self.bitmap.blt(x + 2, y + 2, @goodmovebitmap.bitmap, Rect.new(0, 0, @goodmovebitmap.bitmap.width, @goodmovebitmap.bitmap.height))
        when :nerf then self.bitmap.blt(x + 2, y + 2, @badmovebitmap.bitmap, Rect.new(0, 0, @badmovebitmap.bitmap.width, @badmovebitmap.bitmap.height))
      end
    end
    pbDrawTextPositions(self.bitmap, textpos)
    if megaButton > 0
      self.bitmap.blt(146, 0, @megaevobitmap.bitmap, Rect.new(0, (megaButton - 1) * 46, 96, 46))
    end
    if ultraButton > 0
      self.bitmap.blt(146, 0, @ultraburstbitmap.bitmap, Rect.new(0, (ultraButton - 1) * 46, 96, 46))
    end
    if teraButton > 0
      self.bitmap.blt(146, 0, @terastalbitmap.bitmap, Rect.new(0, (teraButton - 1) * 46, 96, 46))
    end
    if zButton > 0
      self.bitmap.blt(146, 0, @zmovebitmap.bitmap, Rect.new(0, (zButton - 1) * 46, 96, 46))
    end
  end
end

class PokemonBattlerSprite < RPG::Sprite
  attr_accessor :selected
  attr_reader :index

  def initialize(doublebattle, index, viewport = nil)
    super(viewport)
    @selected = 0
    @frame = 0
    @index = index
    @updating = false
    @doublebattle = doublebattle
    @index = index
    @spriteX = 0
    @spriteY = 0
    @spriteXExtra = 0
    @spriteYExtra = 0
    @spriteVisible = false
    @_iconbitmap = nil
    self.visible = false
  end

  def x
    return @spriteX
  end

  def y
    return @spriteY
  end

  def x=(value)
    @spriteX = value
    super(value + @spriteXExtra)
  end

  def y=(value)
    @spriteY = value
    super(value + @spriteYExtra)
  end

  def width; return (self.bitmap) ? self.bitmap.width : 0; end
  def height; return (self.bitmap) ? self.bitmap.height : 0; end

  def dispose
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def selected=(value)
    if @selected == 1 && value != 1 && @spriteYExtra > 0
      @spriteYExtra = 0
      self.y = @spriteY
    end
    @selected = value
  end

  def visible=(value)
    @spriteVisible = value if !@updating
    super
  end

  def setPokemonBitmap(pokemon, back = false)
    @_iconbitmap.dispose if @_iconbitmap
    self.bitmap = pbLoadPokemonBitmap(pokemon, back)
  end

  def update
    @frame += 1
    @updating = true
    @spriteYExtra = 0
    # Pokémon sprite bobbing while Pokémon is selected
    if ((@frame / 10).floor & 1) == 1 && @selected == 1 # When choosing commands for this Pokémon
      @spriteYExtra = 2
    end
    self.x = @spriteX
    self.y = @spriteY
    self.visible = @spriteVisible
    # Pokémon sprite blinking when targeted or damaged
    if @selected == 2 # When targeted or damaged
      self.visible = (@frame % 10 < 7)
    end
    if @_iconbitmap
      @_iconbitmap.update
      self.bitmap = @_iconbitmap.bitmap
    end
    @updating = false
  end
end

DATA_BOX_APPEAR_SPEED = 16

class SafariDataBox < SpriteWrapper
  attr_accessor :selected
  attr_reader :appearing

  def initialize(battle, viewport = nil)
    super(viewport)
    @selected = 0
    @battle = battle
    @databox = AnimatedBitmap.new("Graphics/Pictures/Battle/battlePlayerSafari")
    @spriteX = PBScene::SAFARIBOX_X
    @spriteY = PBScene::SAFARIBOX_Y
    @appearing = false
    @contents = BitmapWrapper.new(@databox.width, @databox.height)
    self.bitmap = @contents
    self.visible = false
    self.z = 50
    refresh
  end

  def appear
    refresh
    self.visible = true
    self.opacity = 255
    self.x = @spriteX + 240
    self.y = @spriteY
    @appearing = true
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0, 0, @databox.bitmap, Rect.new(0, 0, @databox.width, @databox.height))
    pbSetSystemFont(self.bitmap)
    textpos = []
    base = PBScene::BOXBASE
    shadow = PBScene::BOXSHADOW
    textpos.push([_INTL("Safari Balls"), 30, 8, false, base, shadow])
    textpos.push([_INTL("Left: {1}", @battle.ballcount), 30, 38, false, base, shadow])
    pbDrawTextPositions(self.bitmap, textpos)
  end

  def update
    super
    if @appearing
      self.x -= DATA_BOX_APPEAR_SPEED
      @appearing = false if self.x <= @spriteX
      self.y = @spriteY
      return
    end
    self.x = @spriteX
    self.y = @spriteY
  end
end

class PokemonDataBox < SpriteWrapper
  attr_reader :battler
  attr_accessor :selected
  attr_accessor :appearing
  attr_reader :animatingHP
  attr_reader :animatingEXP
  attr_accessor :doublebattle

  @@statsBoostsData = nil # Force the reloading of disposed graphics on soft resetting

  def initialize(battler, doublebattle, viewport = nil)
    super(viewport)
    @explevel = 0
    @battler = battler
    @selected = 0
    @frame = 0
    @showhp = false
    @showexp = false
    @appearing = false
    @animatingHP = false
    @animatingScale = 0 # add this line
    @starthp = 0
    @currenthp = 0
    @endhp = 0
    @expflash = 0
    @doublebattle = doublebattle
    if (@battler.index & 1) == 0 # if player's Pokémon
      @spritebaseX = 34
    else
      @spritebaseX = 16
    end
    @spritebaseY = 0
    initDataBox(doublebattle)
    @contents = BitmapWrapper.new(@databox.width, @databox.height)
    self.bitmap = @contents
    self.visible = false
    self.z = 50
    refreshExpLevel
    refresh
  end

  def initDataBox(doublebattle)
    if doublebattle
      case @battler.index
        when 0
          @databox = AnimatedBitmap.new("Graphics/Pictures/Battle/battlePlayerBoxD")
          @spriteX = PBScene::PLAYERBOXD1_X
          @spriteY = PBScene::PLAYERBOXD1_Y
        when 1
          @databox = AnimatedBitmap.new("Graphics/Pictures/Battle/battleFoeBoxD")
          @spriteX = PBScene::FOEBOXD1_X
          @spriteY = PBScene::FOEBOXD1_Y
        when 2
          @databox = AnimatedBitmap.new("Graphics/Pictures/Battle/battlePlayerBoxD")
          @spriteX = PBScene::PLAYERBOXD2_X
          @spriteY = PBScene::PLAYERBOXD2_Y
        when 3
          @databox = AnimatedBitmap.new("Graphics/Pictures/Battle/battleFoeBoxD")
          @spriteX = PBScene::FOEBOXD2_X
          @spriteY = PBScene::FOEBOXD2_Y
      end
    else
      case @battler.index
        when 0
          @databox = AnimatedBitmap.new("Graphics/Pictures/Battle/battlePlayerBoxS")
          @spriteX = PBScene::PLAYERBOX_X
          @spriteY = PBScene::PLAYERBOX_Y
          @showhp = true
          @showexp = true
        when 1
          @databox = AnimatedBitmap.new("Graphics/Pictures/Battle/battleFoeBoxS")
          @spriteX = PBScene::FOEBOX_X
          @spriteY = PBScene::FOEBOX_Y
      end
    end
  end

  def dispose
    @databox.dispose
    @contents.dispose
    super
  end

  def refreshExpLevel
    if !@battler.pokemon
      @explevel = 0
    else
      growthrate = @battler.pokemon.growthrate
      startexp = PBExp.startExperience(@battler.pokemon.level, growthrate)
      endexp = PBExp.startExperience(@battler.pokemon.level + 1, growthrate)
      if [endexp, @battler.pokemon.exp].include?(startexp)
        @explevel = 0
      else
        @explevel = [(@battler.pokemon.exp - startexp) * PBScene::EXPGAUGESIZE / (endexp - startexp), 2].max.to_grid
      end
    end
  end

  def exp
    return @animatingEXP ? @currentexp : @explevel
  end

  def hp
    return @animatingHP ? @currenthp : @battler.hp
  end

  def animateHP(oldhp, newhp)
    @starthp = oldhp
    @currenthp = oldhp
    @endhp = newhp
    @animatingHP = true
  end

  def animateEXP(oldexp, newexp)
    @currentexp = oldexp
    @endexp = newexp
    @animatingEXP = true
  end

  def appear
    refreshExpLevel
    refresh
    self.visible = true
    self.opacity = 255
    if (@battler.index & 1) == 0 # if player's Pokémon
      self.x = @spriteX + 320
    else
      self.x = @spriteX - 320
    end
    self.y = @spriteY
    @appearing = true
  end

  def refresh(loopstop = false)
    self.bitmap.clear
    return if !@battler.pokemon

    self.bitmap.blt(0, 0, @databox.bitmap, Rect.new(0, 0, @databox.width, @databox.height))
    base = PBScene::BOXBASE
    shadow = PBScene::BOXSHADOW
    pokename = @battler.name
    pbSetSystemFont(self.bitmap)
    textpos = [
      [pokename, @spritebaseX + 8, @spritebaseY + 6, false, base, shadow]
    ]
    genderX = self.bitmap.text_size(pokename).width
    genderX += @spritebaseX + 14
    if genderX > 165 && !@doublebattle && (@battler.index & 1) == 1 # opposing pokemon
      genderX = 224
    end
    infotarget = @battler.effects[:Illusion] ? @battler.effects[:Illusion] : @battler
    unless infotarget.isGenderless?
      colors = infotarget.isMale? ? [Color.new(48, 96, 216), shadow] : [Color.new(248, 88, 40), shadow]
      textpos.push([genderSign(infotarget.gender), genderX, @spritebaseY + 6, false, *colors])
    end
    pbDrawTextPositions(self.bitmap, textpos)
    pbSetSmallFont(self.bitmap)
    level = $game_switches[:Level_999] && (@battler.index % 2) == 1 ? 999 : @battler.level
    textpos = [[_INTL("Lv{1}", level), @spritebaseX + 202, @spritebaseY + 12, true, base, shadow]]
    if @showhp
      hpstring = _ISPRINTF("{1: 2d}/{2: 2d}", self.hp, @battler.totalhp)
      textpos.push([hpstring, @spritebaseX + 188, @spritebaseY + 52, true, base, shadow])
    end
    pbDrawTextPositions(self.bitmap, textpos)
    imagepos = []
    if infotarget.pokemon.isShiny?
      shinyX = 206
      shinyX = 6 if (@battler.index & 1) == 0 # If player's Pokémon
      imagepos.push(["Graphics/Pictures/shiny.png", @spritebaseX + shinyX, @spritebaseY + 36, 0, 0, -1, -1])
    end
    megaY = 34
    megaY = 38 if (@battler.index & 1) == 0 # If player's Pokémon
    megaX = 8
    megaX = -8 if (@battler.index & 1) == 0 # If player's Pokémon
    megaSym = nil
    case true
      when infotarget.pokemon.isPulse? then megaSym = "Graphics/Pictures/Battle/battlePulseEvoBox.png"
      #when infotarget.pokemon.isRift? then megaSym = "Graphics/Pictures/Battle/battleRiftEvoBox.png"
      when infotarget.pokemon.isPerfection? then megaSym = "Graphics/Pictures/Battle/battlePerfectionEvoBox.png"
      when infotarget.isMega? then megaSym = "Graphics/Pictures/Battle/battleMegaEvoBox.png"
      when infotarget.isUltra? then megaSym = "Graphics/Pictures/Battle/battleUltraEvoBox.png"
      when infotarget.isTerastallized? then megaSym = "Graphics/Pictures/Battle/battleTerastalBox.png"
    end
    imagepos.push([megaSym, @spritebaseX + megaX, @spritebaseY + megaY, 0, 0, -1, -1]) if megaSym
    ownstate = infotarget.ownedstate
    if ownstate && (@battler.index & 1) == 1
      imagepos.push(["Graphics/Pictures/Battle/battleBoxOwned#{ownstate == 1 ? "Species" : ""}.png", @spritebaseX + 8, @spritebaseY + 36, 0, 0, -1, -1])
    end
    pbDrawImagePositions(self.bitmap, imagepos)
    statuses = { :SLEEP => 0, :POISON => 1, :BURN => 2, :PARALYSIS => 3, :FROZEN => 4 }
    if !@battler.status.nil?
      imagepos = []
      if Reborn
        imagepos.push(["Graphics/Pictures/Battle/BattleStatuses", @spritebaseX + 24, @spritebaseY + 36, 0, 16 * statuses[@battler.status], 64, 16])
      else
        imagepos.push([sprintf("Graphics/Pictures/Battle/BattleStatuses%s", @battler.status), @spritebaseX + 24, @spritebaseY + 36, 0, 0, 64, 28])
      end
      pbDrawImagePositions(self.bitmap, imagepos)
    end
    hpgauge = (@battler.totalhp == 0 || self.hp == 0) ? 0 : [self.hp * PBScene::HPGAUGESIZE / @battler.totalhp, 2].max.to_grid
    hpzone = getHPZone(self.hp, @battler.totalhp)
    hpcolors = [
      [PBScene::HPGREENDARK, PBScene::HPGREEN],
      [PBScene::HPYELLOWDARK, PBScene::HPYELLOW],
      [PBScene::HPREDDARK, PBScene::HPRED],
    ][hpzone]
    # fill with black (shows what the HP used to be)
    hpGaugeX = PBScene::HPGAUGE_X
    hpGaugeY = PBScene::HPGAUGE_Y
    if @animatingHP && self.hp > 0
      self.bitmap.fill_rect(@spritebaseX + hpGaugeX, @spritebaseY + hpGaugeY, @starthp * PBScene::HPGAUGESIZE / @battler.totalhp, 6, Color.new(0, 0, 0))
    end
    # fill with HP color
    self.bitmap.fill_rect(@spritebaseX + hpGaugeX, @spritebaseY + hpGaugeY, hpgauge, 2, hpcolors[0])
    self.bitmap.fill_rect(@spritebaseX + hpGaugeX, @spritebaseY + hpGaugeY + 2, hpgauge, 4, hpcolors[1])
    if @showexp
      # fill with EXP color
      expGaugeX = PBScene::EXPGAUGE_X
      expGaugeY = PBScene::EXPGAUGE_Y
      self.bitmap.fill_rect(@spritebaseX + expGaugeX, @spritebaseY + expGaugeY, self.exp.clamp(0, PBScene::EXPGAUGESIZE), 2, PBScene::EXPCOLORSHADOW)
      self.bitmap.fill_rect(@spritebaseX + expGaugeX, @spritebaseY + expGaugeY + 2, self.exp.clamp(0, PBScene::EXPGAUGESIZE), 2, PBScene::EXPCOLORBASE)
    end
    pbShowStatsBoosts if loopstop == false
  end

  def pbShowStatsBoosts
    return nil if !pbShouldShowStatsBoosts?

    pbUpdateStatsBoostsBitmap if pbShouldUpdateStatsBoostsBitmap?
    pbDrawStatsBoostsTab
  end

  def pbShouldShowStatsBoosts?
    return false if Rejuv
    return true if !defined?($doShowStatBoosts)

    return $doShowStatBoosts
  end

  def pbShouldUpdateStatsBoostsBitmap?
    return true if !defined?(@@statsBoostsData)
    return true if !@@statsBoostsData
    return true if !@@statsBoostsData[:battlers][@battler.index]
    return true if @@statsBoostsData[:battlers][@battler.index][:bitmap].disposed?

    for pos in 0...@@statsBoostsData[:battlers][@battler.index][:stats].length
      lastVal = @@statsBoostsData[:battlers][@battler.index][:stats][pos]
      currVal = pbGetCurrentStatStage(pos)
      return true if lastVal != currVal
    end
    return false
  end

  def pbGetCurrentStatStage(statPosition)
    mapping = pbGetStatsBoostsDisplayMap
    stat = mapping[statPosition]
    return @battler.stages[stat]
  end

  def pbGetStatsBoostsDisplayMap
    return [
      PBStats::ACCURACY,
      PBStats::ATTACK, PBStats::SPATK,
      PBStats::SPEED,
      PBStats::DEFENSE, PBStats::SPDEF,
      PBStats::EVASION
    ]
  end

  def pbGetStatsBoostsPositionCoordinatesMapping
    return [
      [14, 0],
      [2, 10], [26, 10],
      [14, 20],
      [2, 30], [26, 30],
      [14, 40]
    ]
  end

  def pbGetStatsBoostsTabCoords
    rect = @@statsBoostsData[:battlers][@battler.index][:bitmap].rect
    case @battler.index
      # Player's mon in singles
      when 0
        offset = Desolation ? 20 : 28
        return offset - rect.width, -4
      # Foe's mon in singles
      when 1
        offset = Desolation ? 22 : 10
        return @databox.width - offset, -4
      # Player's other mon in doubles
      when 2
        return 28 - rect.width, -4
      # Foe's other mon in doubles
      else
        return @databox.width - 10, -4
    end
  end

  def pbUpdateStatsBoostsBitmap
    if !defined?(@@statsBoostsData) || !@@statsBoostsData
      @@statsBoostsData = {
        'battlers': []
      }
    end
    # Get the current stages
    if @@statsBoostsData[:battlers][@battler.index]
      len = @@statsBoostsData[:battlers][@battler.index][:stats].length
    else
      @@statsBoostsData[:battlers][@battler.index] = {
        'stats': []
      }
      mapping = pbGetStatsBoostsDisplayMap
      len = mapping.length
    end
    for pos in 0...len
      @@statsBoostsData[:battlers][@battler.index][:stats][pos] = pbGetCurrentStatStage(pos)
    end
    # Get the bitmap
    @@statsBoostsData[:battlers][@battler.index][:bitmap] = pbBuildStatsBoostsBitmap
  end

  def pbBuildStatsBoostsBitmap
    pbEnsureStatsBoostsGraphicsLoaded
    bitmap = @@statsBoostsData[:background].bitmap
    result = Bitmap.new(bitmap.rect.width, bitmap.rect.height)
    result.blt(0, 0, bitmap, bitmap.rect)
    coordsMapping = pbGetStatsBoostsPositionCoordinatesMapping
    for pos in 0...@@statsBoostsData[:battlers][@battler.index][:stats].length
      val = @@statsBoostsData[:battlers][@battler.index][:stats][pos]
      stage = "#{val}"
      next if !@@statsBoostsData[:stages][stage]

      x, y = coordsMapping[pos]
      result.blt(x, y, @@statsBoostsData[:stages][stage], @@statsBoostsData[:stages][stage].rect)
    end
    return result
  end

  def pbEnsureStatsBoostsGraphicsLoaded
    if !@@statsBoostsData[:background] || @@statsBoostsData[:background].disposed?
      @@statsBoostsData[:background] = AnimatedBitmap.new('Graphics/Pictures/Battle/statdis1.png')
    end
    @@statsBoostsData[:stages] = {} if !@@statsBoostsData[:stages]
    stagesToBeLoaded = []
    for i in -6..6
      stage = "#{i}"
      next if @@statsBoostsData[:stages][stage] && !@@statsBoostsData[:stages][stage].disposed?

      stagesToBeLoaded.push(i)
    end
    return nil if stagesToBeLoaded.length <= 0

    rawBmp = AnimatedBitmap.new('Graphics/Pictures/Battle/statdis2.png')
    for i in stagesToBeLoaded
      stage = "#{i}"
      if i == 0
        @@statsBoostsData[:stages][stage] = nil
        next
      end
      rect = pbGetStatsBoostsRect(i)
      bitmap = Bitmap.new(rect.width, rect.height)
      bitmap.blt(0, 0, rawBmp.bitmap, rect)
      @@statsBoostsData[:stages][stage] = bitmap
    end
  end

  def pbGetStatsBoostsRect(stageId)
    stageWidth = 22
    stageHeight = 22
    paddingTop = 0
    if stageId > 0
      i = stageId
      x = 0
    else
      i = -stageId
      x = stageWidth
    end
    y = i * (stageHeight + paddingTop) - stageHeight
    return Rect.new(x, y, stageWidth, stageHeight)
  end

  def pbDrawStatsBoostsTab
    statsBitmap = @@statsBoostsData[:battlers][@battler.index][:bitmap]
    x, y = pbGetStatsBoostsTabCoords
    x, y = pbEnsureStatsBoostsOffsets(x, y)
    refresh(true)
    self.bitmap.blt(x, y, statsBitmap, statsBitmap.rect)
  end

  def pbEnsureStatsBoostsOffsets(x, y)
    offsetX = [-1 * x, 0].max
    offsetY = [-1 * y, 0].max
    # Save the old positions
    type = @doublebattle ? 'doubleBattle' : 'singleBattle'
    @@statsBoostsData[:battlers][@battler.index][:oldGeometry] = {} if !@@statsBoostsData[:battlers][@battler.index][:oldGeometry]
    @@statsBoostsData[:battlers][@battler.index][:oldGeometry][type] = {} if !@@statsBoostsData[:battlers][@battler.index][:oldGeometry][type]
    old = @@statsBoostsData[:battlers][@battler.index][:oldGeometry][type]
    old[:bitmap_width] = self.bitmap.width if !old[:bitmap_width]
    old[:bitmap_height] = self.bitmap.height if !old[:bitmap_height]
    old[:spritebaseX] = @spritebaseX if !old[:spritebaseX]
    old[:spritebaseY] = @spritebaseY if !old[:spritebaseY]
    old[:spriteX] = @spriteX if !old[:spriteX]
    old[:spriteY] = @spriteY if !old[:spriteY]
    # Extend in the positive
    rect = @@statsBoostsData[:battlers][@battler.index][:bitmap].rect
    targetX = [old[:bitmap_width] + offsetX, offsetX + x + rect.width].max
    targetY = [old[:bitmap_height] + offsetY, offsetY + y + rect.height].max
    if self.bitmap.width < targetX || self.bitmap.height < targetY
      temp = Bitmap.new(targetX, targetY)
      temp.blt(0, 0, self.bitmap, self.bitmap.rect)
      self.bitmap = temp
    end
    # Extend in the negative
    if !defined?(@statsBoostsOffsetApplied) || !@statsBoostsOffsetApplied
      if (offsetX != 0 || offsetY != 0)
        bitmap = Bitmap.new(@databox.bitmap.width + 2 * offsetX, @databox.bitmap.height + 2 * offsetY)
        bitmap.blt(offsetX, offsetY, @databox.bitmap, @databox.bitmap.rect)
        @databox.setBitmap(bitmap)

        @spritebaseX = old[:spritebaseX] + offsetX
        @spritebaseY = old[:spritebaseY] + offsetY
        @spriteX = old[:spriteX] - offsetX
        @spriteY = old[:spriteY] - offsetY
      end
      @statsBoostsOffsetApplied = true
    end

    # Fin
    return x + offsetX, y + offsetY
  end

  def update
    super
    @frame += 1
    if @animatingHP
      if @currenthp < @endhp
        @currenthp += [4, (@battler.totalhp.to_f / PBScene::HPGAUGESIZE).floor].max
        @currenthp = @endhp if @currenthp > @endhp
      elsif @currenthp > @endhp
        @currenthp -= [4, (@battler.totalhp.to_f / PBScene::HPGAUGESIZE).floor].max
        @currenthp = @endhp if @currenthp < @endhp
      end
      @animatingHP = false if @currenthp == @endhp
      refresh
    end
    if @animatingEXP
      if !@showexp
        @currentexp = @endexp
      elsif @currentexp < @endexp   # Gaining Exp
        if @endexp >= PBScene::EXPGAUGESIZE ||
           @endexp - @currentexp >= PBScene::EXPGAUGESIZE / 4
          @currentexp += 6
        else
          @currentexp += 3
        end
        @currentexp = @endexp if @currentexp > @endexp
      elsif @currentexp > @endexp   # Losing Exp
        if @endexp <= 0 ||
           @currentexp - @endexp >= PBScene::EXPGAUGESIZE / 4
          @currentexp -= 6
        elsif @currentexp > @endexp
          @currentexp -= 3
        end
        @currentexp = @endexp if @currentexp < @endexp
      end
      refresh
      if @currentexp == @endexp
        if (@currentexp == PBScene::EXPGAUGESIZE && (posExp? || noExp?)) || (@currentexp == 0 && negExp?)
          if @expflash == 0
            pbSEPlay("expfull")
            self.flash(Color.new(64, 200, 248), 8)
            @expflash = 8
          else
            @expflash -= 1
            if @expflash == 0
              @animatingEXP = false
              refreshExpLevel
            end
          end
        else
          @animatingEXP = false
        end
      end
    end
    if @appearing
      if (@battler.index & 1) == 0 # if player's Pokémon
        self.x -= DATA_BOX_APPEAR_SPEED
        @appearing = false if self.x <= @spriteX
      else
        self.x += DATA_BOX_APPEAR_SPEED
        @appearing = false if self.x >= @spriteX
      end
      self.y = @spriteY
      return
    end
    self.x = @spriteX
    self.y = @spriteY
    # Data box bobbing while Pokémon is selected
    if ((@frame / 10).floor & 1) == 1 && @selected == 1 # Choosing commands for this Pokémon
      self.y = @spriteY + 2
    elsif ((@frame / 5).floor & 1) == 1 && @selected == 2 # When targeted or damaged
      self.y = @spriteY + 2
    end
  end
end

class AbilityBox < SpriteWrapper
  attr_reader :playerside
  attr_reader :spriteX
  attr_reader :oldX
  attr_reader :index
  attr_reader :item
  attr_reader :crest
  attr_accessor :onscreen
  attr_accessor :frames
  attr_accessor :mosaic

  AppearSpeed = 24

  def initialize(side, viewport = nil)
    super(viewport)
    @playerside = side == 0
    @onscreen = false
    @frames = 0
    @mosaic = 0
    @abilitybox = AnimatedBitmap.new("Graphics/Pictures/Battle/battleAbility#{@playerside ? "Player" : "Foe"}")
    @spriteX = @playerside ? PBScene::PLAYERABILITYBOX_X : PBScene::FOEABILITYBOX_X
    @spriteY = @playerside ? PBScene::PLAYERABILITYBOX_Y : PBScene::FOEABILITYBOX_Y
    @oldX = @playerside ? (@spriteX - @abilitybox.width) : (@spriteX + @abilitybox.width)
    @oldY = @spriteY
    @contents = BitmapWrapper.new(@abilitybox.width, @abilitybox.height)
    self.bitmap = @contents
    self.x = @oldX
    self.y = @oldY
    self.z = 50
  end

  def setText
    self.bitmap.clear
    self.bitmap.blt(0, 0, @abilitybox.bitmap, Rect.new(0, 0, @abilitybox.width, @abilitybox.height))
    pbSetSmallFont(self.bitmap)

    name_text_size = @contents.text_size(@pokename).width
    attr_text_size = @contents.text_size(@pokeattr).width
    total_text_size = name_text_size + attr_text_size
    max_text_size = @item ? PBScene::MAX_TEXT_SIZE_ITEM : PBScene::MAX_TEXT_SIZE_ABIL
    overlap = total_text_size - PBScene::TEXT_OVERLAP > max_text_size ? total_text_size - max_text_size : PBScene::TEXT_OVERLAP # handles long abilities

    nameX = (@abilitybox.width / 2 - (name_text_size + attr_text_size - overlap) / 2).to_grid
    nameY = 0
    attrX = nameX + name_text_size - overlap
    attrY = nameY + 18

    textpos = [
      [@pokename, nameX, nameY, false, Color.new(238, 238, 238), PBScene::BOXSHADOW], # TODO: Change color back to PBScene::BOXBASE later
      [@pokeattr, attrX, attrY, false, Color.new(238, 238, 238), PBScene::BOXSHADOW], # TODO: Change color back to PBScene::BOXBASE later
    ]
    pbDrawTextPositions(self.bitmap, textpos)

    if @crest
      crestX = attrX - 24
      crest = Bitmap.new("Graphics/Pictures/Battle/battleCrest")
      self.bitmap.blt(crestX, attrY, crest, Rect.new(0, 0, crest.width, crest.height))
    end

    if @item
      item = Bitmap.new(pbItemIconFile(@item))
      item = trimmedBitmap(item)
      itemX = @playerside ? 12 : @abilitybox.width - item.width - 12
      itemY = (@abilitybox.height / 2) - (item.height / 2)
      self.bitmap.blt(itemX.to_grid, itemY.to_grid, item, Rect.new(0, 0, item.width, item.height))
    end

    @oldbitmap = self.bitmap.clone
  end

  def mosaicRefresh
    if @mosaic > 0
      newWidth = [(@oldbitmap.width / @mosaic), 1].max
      newHeight = [(@oldbitmap.height / @mosaic), 1].max
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap = pbDoEnsureBitmap(@mosaicbitmap, newWidth, newHeight)
      @mosaicbitmap.clear
      @mosaicbitmap2 = pbDoEnsureBitmap(@mosaicbitmap2, @oldbitmap.width, @oldbitmap.height)
      @mosaicbitmap2.clear
      @mosaicbitmap.stretch_blt(Rect.new(0, 0, newWidth, newHeight), @oldbitmap, @oldbitmap.rect)
      @mosaicbitmap2.stretch_blt(
        Rect.new(
          -@mosaic / 2 + 1, -@mosaic / 2 + 1,
          @mosaicbitmap2.width, @mosaicbitmap2.height
        ),
        @mosaicbitmap, Rect.new(0, 0, newWidth, newHeight)
      )
      self.bitmap = @mosaicbitmap2
    else
      self.bitmap = @oldbitmap
    end
  end

  def setBattler(battler, item = nil, attrname = nil, crest = nil)
    @index = battler.index
    @pokename = _INTL("{1}'s", battler.name)
    @pokeattr = getAbilityBoxAttrString(battler, item, attrname)
    @crest = (item && battler.crested) || battler.fakeCrest || battler.crested == :SILVALLY || (battler.crested == :ZOROARK && battler.effects[:Illusion].nil?)
    @crest = crest if !crest.nil?
    @item = item && !@crest ? (item.is_a?(Symbol) ? item : battler.item) : nil
  end

  def getDisplayVars
    return [@index, @pokeattr, @item, @crest]
  end

  def appearSpeed
    return $speed_up ? (AppearSpeed * 2 / 3) : AppearSpeed
  end

  def update
    @frames += 1 if @onscreen
  end
end

def showShadow?(cacheData)
  # Add functionality here
  return true
end

# Shows the enemy trainer(s)'s Pokémon being thrown out.  It appears at coords
# (@spritex,@spritey), and moves in y to @endspritey where it stays for the rest
# of the battle, i.e. the latter is the more important value.
# Doesn't show the ball itself being thrown.
class PokeballSendOutAnimation
  SPRITESTEPS = 10
  STARTZOOM = 0.125

  def initialize(sprite, spritehash, pkmn, delayCry)
    battle = pkmn.battle
    @disposed = false
    @ballused = pkmn.pokemon ? pkmn.pokemon.ballused : :POKEBALL
    @PokemonBattlerSprite = sprite
    @PokemonBattlerSprite.visible = false
    @PokemonBattlerSprite.tone = Tone.new(248, 248, 248, 248)
    @pokeballsprite = IconSprite.new(0, 0, sprite.viewport)
    @pokeballsprite.setBitmap(sprintf("Graphics/Pictures/Battle/%s", @ballused))
    if battle.doublebattle && battle.allMons(battle.party2).length != 1
      @spritex = PBScene::FOEBATTLERD1_X if pkmn.index == 1
      @spritex = PBScene::FOEBATTLERD2_X if pkmn.index == 3
    else
      @spritex = PBScene::FOEBATTLER_X
    end
    @spritey = 0
    visiblePokemon = pkmn.effects[:Illusion] ? pkmn.effects[:Illusion] : pkmn
    visiblePokemon = pkmn.effects[:clearDisguise] if pkmn.effects[:clearDisguise]
    xoffset, @endspritey = adjustBattleSprite(sprite, visiblePokemon.getCacheData, pkmn.index)
    # if a battle tagged as doubles only has a single opposing pokemon use singles position
    if battle.doublebattle && battle.allMons(pkmn.battle.party2).length != 1
      @spritey = PBScene::FOEBATTLERD1_Y if pkmn.index == 1
      @spritey = PBScene::FOEBATTLERD2_Y if pkmn.index == 3
      @endspritey += PBScene::FOEBATTLERD1_Y if pkmn.index == 1
      @endspritey += PBScene::FOEBATTLERD2_Y if pkmn.index == 3
    else
      @spritey = PBScene::FOEBATTLER_Y
      @endspritey += PBScene::FOEBATTLER_Y
    end
    @spritehash = spritehash
    @pokeballsprite.x = @spritex - @pokeballsprite.bitmap.width / 2
    @pokeballsprite.y = @spritey - @pokeballsprite.bitmap.height / 2 - 4
    @pokeballsprite.z = @PokemonBattlerSprite.z + 1
    @pkmn = pkmn
    @delayCry = delayCry
    @shadowX = @spritex
    @shadowY = @spritey
    @spritehash["shadow#{@pkmn.index}"].setPokemonShadowBitmap(visiblePokemon.getCacheData)
    @shadowX += adjustShadowSpriteX(@spritehash["shadow#{@pkmn.index}"], visiblePokemon.getCacheData)
    @shadowVisible = showShadow?(visiblePokemon.getCacheData)
    @shadowY -= @spritehash["shadow#{@pkmn.index}"].bitmap.height / 2
    @spritehash["shadow#{@pkmn.index}"].visible = false
    @spritex += xoffset + @PokemonBattlerSprite.width / 2
    @stepspritey = (@spritey - @endspritey)
    @zoomstep = (1.0 - STARTZOOM) / SPRITESTEPS
    @animdone = false
    @frame = 0
  end

  def disposed?
    return @disposed
  end

  def animdone?
    return @animdone
  end

  def dispose
    return if disposed?

    @pokeballsprite.dispose
    @disposed = true
  end

  def update
    return if disposed?

    @pokeballsprite.update
    @frame += 1
    if @frame == 2
      pbSEPlay("recall")
    end
    if @frame == 4
      @PokemonBattlerSprite.visible = true
      @PokemonBattlerSprite.zoom_x = STARTZOOM
      @PokemonBattlerSprite.zoom_y = STARTZOOM
      pbSpriteSetCenter(@PokemonBattlerSprite, @spritex, @spritey)
      pbPlayCry(@pkmn.visiblePokemon(true)) unless @delayCry
      @pokeballsprite.setBitmap(sprintf("Graphics/Pictures/Battle/%s_open", @ballused))
    end
    if @frame == 24 && @delayCry
      pbPlayCry(@pkmn.visiblePokemon(true))
    end
    if @frame == 8
      @pokeballsprite.visible = false
    end
    if @frame > 8 && @frame <= 16
      color = Color.new(248, 248, 248, 256 - (16 - @frame) * 32)
      if $Settings.photosensitive == 0
        @spritehash["enemybase"].color = color
        @spritehash["playerbase"].color = color
        @spritehash["battlebg"].color = color
      end
      for i in 0...4
        @spritehash["shadow#{i}"].color = color if @spritehash["shadow#{i}"]
      end
    end
    if @frame > 16 && @frame <= 24
      color = Color.new(248, 248, 248, (24 - @frame) * 32)
      tone = (24 - @frame) * 32
      @PokemonBattlerSprite.tone = Tone.new(tone, tone, tone, tone)
      if $Settings.photosensitive == 0
        @spritehash["enemybase"].color = color
        @spritehash["playerbase"].color = color
        @spritehash["battlebg"].color = color
      end
      for i in 0...4
        @spritehash["shadow#{i}"].color = color if @spritehash["shadow#{i}"]
      end
    end
    if @frame > 5 && @PokemonBattlerSprite.zoom_x < 1.0
      @PokemonBattlerSprite.zoom_x += @zoomstep
      @PokemonBattlerSprite.zoom_y += @zoomstep
      @PokemonBattlerSprite.zoom_x = 1.0 if @PokemonBattlerSprite.zoom_x > 1.0
      @PokemonBattlerSprite.zoom_y = 1.0 if @PokemonBattlerSprite.zoom_y > 1.0
      currentY = @spritey - (@stepspritey * @PokemonBattlerSprite.zoom_y)
      pbSpriteSetCenter(@PokemonBattlerSprite, @spritex, currentY)
      @PokemonBattlerSprite.y = currentY
    end
    if @PokemonBattlerSprite.tone.gray <= 0 && @PokemonBattlerSprite.zoom_x >= 1.0
      @animdone = true
      if @spritehash["shadow#{@pkmn.index}"]
        @spritehash["shadow#{@pkmn.index}"].x = @shadowX
        @spritehash["shadow#{@pkmn.index}"].y = @shadowY
        @spritehash["shadow#{@pkmn.index}"].visible = @shadowVisible
      end
    end
  end
end

# Shows the player's (or partner's) Pokémon being thrown out.  It appears at
# (@spritex,@spritey), and moves in y to @endspritey where it stays for the rest
# of the battle, i.e. the latter is the more important value.
# Doesn't show the ball itself being thrown.
class PokeballPlayerSendOutAnimation
  #  Ball curve: 8,52; 22,44; 52, 96
  #  Player: Color.new(16*8,23*8,30*8)
  SPRITESTEPS = 10
  STARTZOOM = 0.125

  def initialize(sprite, spritehash, pkmn, delayCry)
    battle = pkmn.battle
    @disposed = false
    @PokemonBattlerSprite = sprite
    @pkmn = pkmn
    @delayCry = delayCry
    @PokemonBattlerSprite.visible = false
    @PokemonBattlerSprite.tone = Tone.new(248, 248, 248, 248)
    @spritehash = spritehash
    playerpos = battle.sosbattle == :singlePokemonPlayerSide ? [PBScene::PLAYERBATTLER_X, PBScene::PLAYERBATTLER_Y] : [PBScene::PLAYERBATTLERD1_X, PBScene::PLAYERBATTLERD1_Y]
    if battle.doublebattle
      @spritex = playerpos[0] if pkmn.index == 0
      @spritex = PBScene::PLAYERBATTLERD2_X if pkmn.index == 2
    else
      @spritex = PBScene::PLAYERBATTLER_X
    end
    @spritey = 0
    visiblePokemon = pkmn.effects[:Illusion] ? pkmn.effects[:Illusion] : pkmn
    visiblePokemon = pkmn.effects[:clearDisguise] if pkmn.effects[:clearDisguise]
    xoffset, @endspritey = adjustBattleSprite(sprite, visiblePokemon.getCacheData, pkmn.index)
    @spritex += xoffset + @PokemonBattlerSprite.width / 2
    if battle.doublebattle
      @spritey += playerpos[1] if pkmn.index == 0
      @spritey += PBScene::PLAYERBATTLERD2_Y if pkmn.index == 2
      @endspritey += playerpos[1] if pkmn.index == 0
      @endspritey += PBScene::PLAYERBATTLERD2_Y if pkmn.index == 2
    else
      @spritey += PBScene::PLAYERBATTLER_Y
      @endspritey += PBScene::PLAYERBATTLER_Y
    end
    @animdone = false
    @frame = 0
  end

  def disposed?
    return @disposed
  end

  def animdone?
    return @animdone
  end

  def dispose
    return if disposed?

    @disposed = true
  end

  def update
    return if disposed?

    @frame += 1
    if @frame == 4
      @PokemonBattlerSprite.visible = true
      @PokemonBattlerSprite.zoom_x = STARTZOOM
      @PokemonBattlerSprite.zoom_y = STARTZOOM
      pbSEPlay("recall")
      pbSpriteSetCenter(@PokemonBattlerSprite, @spritex, @spritey)
      pbPlayCry(@pkmn.visiblePokemon(true)) unless @delayCry
    end
    if @frame == 24 && @delayCry
      pbPlayCry(@pkmn.visiblePokemon(true))
    end
    if @frame > 8 && @frame <= 16
      color = Color.new(248, 248, 248, 256 - (16 - @frame) * 32)
      if $Settings.photosensitive == 0
        @spritehash["enemybase"].color = color
        @spritehash["playerbase"].color = color
        @spritehash["battlebg"].color = color
      end
      for i in 0...4
        @spritehash["shadow#{i}"].color = color if @spritehash["shadow#{i}"]
      end
    end
    if @frame > 16 && @frame <= 24
      color = Color.new(248, 248, 248, (24 - @frame) * 32)
      tone = (24 - @frame) * 32
      @PokemonBattlerSprite.tone = Tone.new(tone, tone, tone, tone)
      if $Settings.photosensitive == 0
        @spritehash["enemybase"].color = color
        @spritehash["playerbase"].color = color
        @spritehash["battlebg"].color = color
      end
      for i in 0...4
        @spritehash["shadow#{i}"].color = color if @spritehash["shadow#{i}"]
      end
    end
    if @frame > 5 && @PokemonBattlerSprite.zoom_x < 1.0
      @PokemonBattlerSprite.zoom_x += 0.1
      @PokemonBattlerSprite.zoom_y += 0.1
      @PokemonBattlerSprite.zoom_x = 1.0 if @PokemonBattlerSprite.zoom_x > 1.0
      @PokemonBattlerSprite.zoom_y = 1.0 if @PokemonBattlerSprite.zoom_y > 1.0
      pbSpriteSetCenter(@PokemonBattlerSprite, @spritex, 0)
      @PokemonBattlerSprite.y = @spritey + (@endspritey - @spritey) * @PokemonBattlerSprite.zoom_y
    end
    if @PokemonBattlerSprite.tone.gray <= 0 && @PokemonBattlerSprite.zoom_x >= 1.0
      @animdone = true
    end
  end
end

# Slide the pokemon in from the side because it is already out of the ball.
class SlideSendOutAnimation
  def initialize(sprite, spritehash, pkmn, delayCry, enemy = false)
    battle = pkmn.battle
    @disposed = false
    @PokemonBattlerSprite = sprite
    @PokemonBattlerSprite.zoom_x = 1.0
    @PokemonBattlerSprite.zoom_y = 1.0
    @pkmn = pkmn
    @delayCry = delayCry
    @PokemonBattlerSprite.visible = false
    @PokemonBattlerSprite.tone = Tone.new(248, 248, 248, 248)
    @spritehash = spritehash
    @enemy = enemy
    if enemy
      pos = [PBScene::FOEBATTLERD1_X, PBScene::FOEBATTLERD1_Y]
    else
      pos = battle.sosbattle == :singlePokemonPlayerSide ? [PBScene::PLAYERBATTLER_X, PBScene::PLAYERBATTLER_Y] : [PBScene::PLAYERBATTLERD1_X, PBScene::PLAYERBATTLERD1_Y]
    end
    if battle.doublebattle
      @spritex = pos[0] if pkmn.index == 0 || pkmn.index == 1
      @spritex = PBScene::PLAYERBATTLERD2_X if pkmn.index == 2
      @spritex = PBScene::FOEBATTLERD2_X if pkmn.index == 3
    else
      @spritex = enemy ? @spritex = PBScene::FOEBATTLER_X : PBScene::PLAYERBATTLER_X
    end
    @spritey = 0
    visiblePokemon = pkmn.effects[:Illusion] ? pkmn.effects[:Illusion] : pkmn
    visiblePokemon = pkmn.effects[:clearDisguise] if pkmn.effects[:clearDisguise]
    xoffset, @endspritey = adjustBattleSprite(sprite, visiblePokemon.getCacheData, pkmn.index)
    if battle.doublebattle
      @spritey = pos[1] if pkmn.index == 0 || pkmn.index == 1
      @spritey = PBScene::PLAYERBATTLERD2_Y if pkmn.index == 2
      @spritey = PBScene::FOEBATTLERD2_Y if pkmn.index == 3
      @endspritey += pos[1] if pkmn.index == 0 || pkmn.index == 1
      @endspritey += PBScene::PLAYERBATTLERD2_Y if pkmn.index == 2
      @endspritey += PBScene::FOEBATTLERD2_Y if pkmn.index == 3
    else
      @spritey = enemy ? PBScene::FOEBATTLER_Y : PBScene::PLAYERBATTLER_Y
      @endspritey += enemy ? PBScene::FOEBATTLER_Y : PBScene::PLAYERBATTLER_Y
    end
    if enemy
      @shadowX = @spritex
      @shadowY = @spritey
      @spritehash["shadow#{@pkmn.index}"].setPokemonShadowBitmap(visiblePokemon.getCacheData)
      @shadowX += adjustShadowSpriteX(@spritehash["shadow#{@pkmn.index}"], visiblePokemon.getCacheData)
      @shadowY -= @spritehash["shadow#{@pkmn.index}"].bitmap.height / 2
      @shadowVisible = showShadow?(visiblePokemon.getCacheData)
      @spritehash["shadow#{@pkmn.index}"].x = @shadowX
      @spritehash["shadow#{@pkmn.index}"].y = @shadowY
    end
    @animdone = false
    @frame = 0
    @spritex += xoffset + @PokemonBattlerSprite.width / 2
    @spritex += enemy ? 240 : -240
    @spritehash["shadow#{@pkmn.index}"].x += 240 if enemy
    @spritehash["shadow#{@pkmn.index}"].visible = @shadowVisible
  end

  def disposed?
    return @disposed
  end

  def animdone?
    return @animdone
  end

  def dispose
    return if disposed?

    @disposed = true
  end

  def update
    return if disposed?

    @frame += 1
    if @frame == 4
      @PokemonBattlerSprite.visible = true
      pbSpriteSetCenter(@PokemonBattlerSprite, @spritex, @spritey)
      pbPlayCry(@pkmn.visiblePokemon(true)) unless @delayCry
      @PokemonBattlerSprite.tone = Tone.new(0, 0, 0, 0)
      @PokemonBattlerSprite.y = @endspritey
      color = Color.new(248, 248, 248, 0)
      for i in 0...4
        @spritehash["shadow#{i}"].color = color if @spritehash["shadow#{i}"]
      end
    end
    if @frame == 24 && @delayCry
      pbPlayCry(@pkmn.visiblePokemon(true))
    end
    if @frame > 6 && @frame <= 26
      @spritex += @enemy ? -12 : 12
      @PokemonBattlerSprite.x += @enemy ? -12 : 12
      @spritehash["shadow#{@pkmn.index}"].x -= 12 if @enemy
    end
    if @frame >= 26
      @animdone = true
    end
  end
end

# Shows the enemy trainer(s) and the enemy party lineup sliding off screen.
# Doesn't show the ball thrown or the Pokémon.
class TrainerFadeAnimation
  def initialize(sprites)
    @frame = 0
    @sprites = sprites
    @animdone = false
  end

  def animdone?
    return @animdone
  end

  def update
    return if @animdone

    @frame += 1
    @sprites["trainer"].x += 8
    @sprites["trainer2"].x += 8 if @sprites["trainer2"]
    @sprites["partybarfoe"].x += 8
    @sprites["partybarfoe"].opacity -= 12
    if @sprites["partybarfoepartner"]
      @sprites["partybarfoepartner"].x += 8
      @sprites["partybarfoepartner"].opacity -= 12
    end
    for i in 0...6
      @sprites["enemy#{i}"].opacity -= 12
      @sprites["enemy#{i}"].x += 8 if @frame >= i * 4
      if @sprites["enemypartner#{i}"]
        @sprites["enemypartner#{i}"].opacity -= 12
        @sprites["enemypartner#{i}"].x += 8 if @frame >= i * 4
      end
    end
    @animdone = true if @sprites["trainer"].x >= Graphics.width && (!@sprites["trainer2"] || @sprites["trainer2"].x >= Graphics.width)
  end

  def dispose
  end
end

# Shows the player (and partner) and the player party lineup sliding off screen.
# Shows the player's/partner's throwing animation (if they have one).
# Doesn't show the ball thrown or the Pokémon.
class PlayerFadeAnimation
  def initialize(sprites, playerthrow = true)
    @frame = 0
    @sprites = sprites
    @animdone = false
    @playerthrow = playerthrow
  end

  def animdone?
    return @animdone
  end

  def update
    return if @animdone

    @frame += 1
    @sprites["player"].x -= 8
    @sprites["playerB"].x -= 8 if @sprites["playerB"]
    @sprites["partybarplayer"].x -= 8
    @sprites["partybarplayer"].opacity -= 12
    if @sprites["partybarpartner"]
      @sprites["partybarpartner"].x -= 8
      @sprites["partybarpartner"].opacity -= 12
    end
    for i in 0...6
      if @sprites["player#{i}"]
        @sprites["player#{i}"].opacity -= 12
        @sprites["player#{i}"].x -= 8 if @frame >= i * 4
      end
      if @sprites["partner#{i}"]
        @sprites["partner#{i}"].opacity -= 12
        @sprites["partner#{i}"].x -= 8 if @frame >= i * 4
      end
    end
    pa = @sprites["player"]
    pb = @sprites["playerB"]
    pawidth = 128
    pbwidth = 128
    if pa && pa.bitmap && !pa.bitmap.disposed?
      if pa.bitmap.height < pa.bitmap.width
        numframes = pa.bitmap.width / pa.bitmap.height # Number of frames
        pawidth = pa.bitmap.width / numframes # Width per frame
        if @playerthrow
          @sprites["player"].src_rect.x = pawidth * 1 if @frame > 0
          @sprites["player"].src_rect.x = pawidth * 2 if @frame > 8
          @sprites["player"].src_rect.x = pawidth * 3 if @frame > 12
          @sprites["player"].src_rect.x = pawidth * 4 if @frame > 16
        end
        @sprites["player"].src_rect.width = pawidth
      else
        pawidth = pa.bitmap.width
        @sprites["player"].src_rect.x = 0
        @sprites["player"].src_rect.width = pawidth
      end
    end
    if pb && pb.bitmap && !pb.bitmap.disposed?
      if pb.bitmap.height < pb.bitmap.width
        numframes = pb.bitmap.width / pb.bitmap.height # Number of frames
        pbwidth = pb.bitmap.width / numframes # Width per frame
        @sprites["playerB"].src_rect.x = pbwidth * 1 if @frame > 0
        @sprites["playerB"].src_rect.x = pbwidth * 2 if @frame > 8
        @sprites["playerB"].src_rect.x = pbwidth * 3 if @frame > 12
        @sprites["playerB"].src_rect.x = pbwidth * 4 if @frame > 16
        @sprites["playerB"].src_rect.width = pbwidth
      else
        pbwidth = pb.bitmap.width
        @sprites["playerB"].src_rect.x = 0
        @sprites["playerB"].src_rect.width = pbwidth
      end
    end
    if pb
      @animdone = true if pb.x <= -pbwidth
    else
      @animdone = true if pa.x <= -pawidth
    end
  end

  def dispose
  end
end

class BattleBoxAppearAnimation
  def initialize(sprite)
    @sprite = sprite
  end

  def animdone?
    return @sprite.visible && !@sprite.appearing
  end

  def update
    return if @animdone
    @sprite.appear unless @sprite.visible
    @sprite.update
  end

  def dispose
  end
end

class ParallelAnimation
  def initialize(*animations)
    @animations = animations
  end

  def update
    @animations.each do |anim|
      anim.update
    end
  end

  def animdone?
    @animations.each do |anim|
      return false unless anim.animdone?
    end
    return true
  end

  def dispose
    @animations.each do |anim|
      anim.dispose
    end
  end
end

class WaitAnimation
  def initialize(frames)
    @frames = frames
  end

  def animdone?
    return @frames == 0
  end

  def update
    @frames -= 1
  end

  def dispose
  end
end

class AnimationQueue
  def initialize(*animations)
    @animations = animations
    @queue = animations.dup
  end

  def update
    if @currentAnim.nil? || @currentAnim.animdone?
      return if @queue == []
      @currentAnim = @queue.shift
    end
    @currentAnim.update
  end

  def animdone?
    @animations.each do |anim|
      return false unless anim.animdone?
    end
    return true
  end

  def dispose
    @animations.each do |anim|
      anim.dispose
    end
  end
end

class PlayerBallSendOutAnimation
  BALL_CURVE = [
    [0, 146], [10, 134], [21, 122], [30, 112],
    [39, 104], [46, 99], [53, 95], [61, 93],
    [68, 93], [75, 96], [82, 102], [89, 111],
    [94, 121], [100, 134], [106, 150], [111, 166],
    [116, 183], [120, 199], [124, 216], [127, 238],
  ]

  def initialize(sprite, balltype, multiplier, traineryoffset)
    @frame = 0
    @animdone = false
    @sprite = sprite

    ballbitmap = sprintf("Graphics/Pictures/Battle/%s", balltype)
    @pictureBall = PictureEx.new(32)
    delay = 1
    @pictureBall.moveVisible(delay, true)
    @pictureBall.moveName(delay, ballbitmap)
    @pictureBall.moveOrigin(delay, PictureOrigin::Center)
    # Setting the ball's movement path
    path = [16, 30, 43, 55, 66, 76, 85, 93, 101, 108, 115, 121, 127]
    angle = 0
    for coord in path
      coord = [coord, ballY(coord)]
      delay = @pictureBall.totalDuration
      @pictureBall.moveAngle(0, delay, angle)
      @pictureBall.moveXY(1, delay, coord[0] * multiplier, coord[1])
      angle += 40
      angle %= 360
    end
    @pictureBall.adjustPosition(0, traineryoffset)
  end

  def animdone?
    return @animdone
  end

  def update
    return if @animdone
    @frame += 1

    @pictureBall.update
    setPictureIconSprite(@sprite, @pictureBall)
    @animdone = !@pictureBall.running?
  end

  def dispose
    @sprite.dispose
  end

  def ballY(x)
    raise ArgumentError, "x out of range" if x < BALL_CURVE.first[0] || x > BALL_CURVE.last[0]

    prev = BALL_CURVE.first
    BALL_CURVE.each do |px, py|
      return py if px == x
      if px > x
        x1, y1 = prev
        x2, y2 = px, py
        return y1 + (y2 - y1) * (x - x1).to_f / (x2 - x1)
      end
      prev = [px, py]
    end
  end
end

def getBallCenterX(index, battle)
  case index
    when 1 then return battle.doublebattle && battle.allMons(battle.party2).length != 1 ? PBScene::FOEBATTLERD1_X : PBScene::FOEBATTLER_X
    when 3 then return PBScene::FOEBATTLERD2_X
  end
end

def getBallEndY(index, battle)
  case index
    when 1 then return battle.doublebattle && battle.allMons(battle.party2).length != 1 ? PBScene::FOEBATTLERD1_Y - 4 : PBScene::FOEBATTLER_Y - 4
    when 3 then return PBScene::FOEBATTLERD2_Y - 4
  end
end

# Shows the player's Poké Ball being thrown to capture a Pokémon.
def pokeballThrow(ball, shakes, critical, critsuccess, targetBattler, scene, battler, burst = -1, showplayer = false)
  animtrainer = false
  if showplayer && @sprites["player"].bitmap.width > @sprites["player"].bitmap.height
    animtrainer = true
  end
  oldvisible = @sprites["shadow#{targetBattler}"].visible
  @sprites["shadow#{targetBattler}"].visible = false
  ballopen = sprintf("Graphics/Pictures/Battle/%s_open", ball.to_s)
  ballclosed = sprintf("Graphics/Pictures/Battle/%s", ball.to_s)
  # sprites
  spritePoke = @sprites["pokemon#{targetBattler}"]
  spriteBall = IconSprite.new(0, 0, @viewport)
  spriteBall.visible = false
  spritePlayer = @sprites["player"] if animtrainer
  # pictures
  pictureBall = PictureEx.new(spritePoke.z + 1)
  picturePoke = PictureEx.new(spritePoke.z)
  dims = [spritePoke.x, spritePoke.y]
  center = getSpriteCenter(@sprites["pokemon#{targetBattler}"])
  ballcenterx = getBallCenterX(targetBattler, @battle)
  ballendy = getBallEndY(targetBattler, @battle)
  if animtrainer
    picturePlayer = PictureEx.new(spritePoke.z + 2)
    playerpos = [@sprites["player"].x, @sprites["player"].y]
  end
  # starting positions
  pictureBall.moveVisible(1, true)
  pictureBall.moveName(1, ballclosed)
  pictureBall.moveOrigin(1, PictureOrigin::Center)
  if animtrainer
    pictureBall.moveXY(0, 1, 64, 256)
  else
    pictureBall.moveXY(0, 1, 10, 180)
  end
  picturePoke.moveVisible(1, true)
  picturePoke.moveOrigin(1, PictureOrigin::Center)
  picturePoke.moveXY(0, 1, center[0], center[1])
  if animtrainer
    picturePlayer.moveVisible(1, true)
    picturePlayer.moveName(1, spritePlayer.name)
    picturePlayer.moveOrigin(1, PictureOrigin::TopLeft)
    picturePlayer.moveXY(0, 1, playerpos[0], playerpos[1])
  end
  # directives
  picturePoke.moveSE(1, "Audio/SE/throw")
  if animtrainer
    pictureBall.moveCurve(30, 1, 64, 256, 30 + Graphics.width / 2, 10, ballcenterx, center[1])
    pictureBall.moveAngle(30, 1, -720)
  else
    pictureBall.moveCurve(30, 1, 150, 70, 30 + Graphics.width / 2, 10, ballcenterx, center[1])
    pictureBall.moveAngle(30, 1, -1080)
  end
  pictureBall.moveAngle(0, pictureBall.totalDuration, 0)
  delay = pictureBall.totalDuration + 4
  picturePoke.moveTone(10, delay, Tone.new(0, -224, -224, 0))
  delay = picturePoke.totalDuration
  picturePoke.moveSE(delay, "Audio/SE/recall")
  pictureBall.moveName(delay + 4, ballopen)
  if animtrainer
    picturePlayer.moveSrc(1, @sprites["player"].bitmap.height, 0)
    picturePlayer.moveXY(0, 1, playerpos[0] - 14, playerpos[1])
    picturePlayer.moveSrc(4, @sprites["player"].bitmap.height * 2, 0)
    picturePlayer.moveXY(0, 4, playerpos[0] - 12, playerpos[1])
    picturePlayer.moveSrc(8, @sprites["player"].bitmap.height * 3, 0)
    picturePlayer.moveXY(0, 8, playerpos[0] + 20, playerpos[1])
    picturePlayer.moveSrc(16, @sprites["player"].bitmap.height * 4, 0)
    picturePlayer.moveXY(0, 16, playerpos[0] + 16, playerpos[1])
    picturePlayer.moveSrc(40, 0, 0)
    picturePlayer.moveXY(0, 40, playerpos[0], playerpos[1])
  end
  loop do
    pictureBall.update
    picturePoke.update
    picturePlayer.update if animtrainer
    setPictureIconSprite(spriteBall, pictureBall)
    setPictureSprite(spritePoke, picturePoke)
    setPictureIconSprite(spritePlayer, picturePlayer) if animtrainer
    pbGraphicsUpdate
    Input.update
    break if !pictureBall.running? && !picturePoke.running?
  end
  # Burst animation here
  if burst >= 0 && scene.battle.battlescene
    scene.pbCommonAnimation("BallBurst#{burst}", battler, nil)
  end
  pictureBall.clearProcesses
  picturePoke.clearProcesses
  delay = 0
  picturePoke.moveZoom(15, delay, 0)
  picturePoke.moveXY(15, delay, ballcenterx, center[1])
  picturePoke.moveSE(delay + 10, "Audio/SE/jumptoball")
  picturePoke.moveVisible(delay + 15, false)
  pictureBall.moveName(picturePoke.totalDuration + 2, ballclosed)
  delay = picturePoke.totalDuration + 6
  if critical
    pictureBall.moveSE(delay, "Audio/SE/ballshake")
    pictureBall.moveXY(2, delay, ballcenterx + 4, center[1])
    pictureBall.moveXY(4, pictureBall.totalDuration, ballcenterx - 4, center[1])
    pictureBall.moveSE(pictureBall.totalDuration, "Audio/SE/ballshake")
    pictureBall.moveXY(4, pictureBall.totalDuration, ballcenterx + 4, center[1])
    pictureBall.moveXY(4, pictureBall.totalDuration, ballcenterx - 4, center[1])
    pictureBall.moveXY(2, pictureBall.totalDuration, ballcenterx, center[1])
    delay = pictureBall.totalDuration + 4
  end
  pictureBall.moveXY(10, delay, ballcenterx, ballendy)
  pictureBall.moveSE(pictureBall.totalDuration, "Audio/SE/balldrop")
  pictureBall.moveXY(5, pictureBall.totalDuration + 2, ballcenterx, ballendy - ((ballendy - center[1]) / 2))
  pictureBall.moveXY(5, pictureBall.totalDuration + 2, ballcenterx, ballendy)
  pictureBall.moveSE(pictureBall.totalDuration, "Audio/SE/balldrop")
  pictureBall.moveXY(3, pictureBall.totalDuration + 2, ballcenterx, ballendy - ((ballendy - center[1]) / 4))
  pictureBall.moveXY(3, pictureBall.totalDuration + 2, ballcenterx, ballendy)
  pictureBall.moveSE(pictureBall.totalDuration, "Audio/SE/balldrop")
  pictureBall.moveXY(1, pictureBall.totalDuration + 2, ballcenterx, ballendy - ((ballendy - center[1]) / 8))
  pictureBall.moveXY(1, pictureBall.totalDuration + 2, ballcenterx, ballendy)
  pictureBall.moveSE(pictureBall.totalDuration, "Audio/SE/balldrop")
  picturePoke.moveXY(0, pictureBall.totalDuration, ballcenterx, ballendy)
  delay = pictureBall.totalDuration + 18 # if shakes==0
  maxshakes = ball == :PREMIERBALL ? 2 : 3
  [shakes, maxshakes].min.times do
    pictureBall.moveSE(delay, "Audio/SE/ballshake")
    pictureBall.moveXY(3, delay, ballcenterx - 8, ballendy)
    pictureBall.moveAngle(3, delay, 20) # positive means counterclockwise
    delay = pictureBall.totalDuration
    pictureBall.moveXY(6, delay, ballcenterx + 8, ballendy)
    pictureBall.moveAngle(6, delay, -20) # negative means clockwise
    delay = pictureBall.totalDuration
    pictureBall.moveXY(3, delay, ballcenterx, ballendy)
    pictureBall.moveAngle(3, delay, 0)
    delay = pictureBall.totalDuration + 18
  end
  if shakes < 4 && !critsuccess
    picturePoke.moveSE(delay, "Audio/SE/recall")
    pictureBall.moveName(delay, ballopen)
    pictureBall.moveVisible(delay + 10, false)
    picturePoke.moveVisible(delay, true)
    picturePoke.moveZoom(15, delay, 100)
    picturePoke.moveXY(15, delay, center[0], center[1])
    picturePoke.moveTone(0, delay, Tone.new(248, 248, 248, 248))
    picturePoke.moveTone(24, delay, Tone.new(0, 0, 0, 0))
    delay = picturePoke.totalDuration
  end
  pictureBall.moveXY(0, delay, ballcenterx, ballendy)
  picturePoke.moveOrigin(picturePoke.totalDuration, PictureOrigin::TopLeft)
  picturePoke.moveXY(0, picturePoke.totalDuration, dims[0], dims[1])
  loop do
    pictureBall.update
    picturePoke.update
    setPictureIconSprite(spriteBall, pictureBall)
    setPictureSprite(spritePoke, picturePoke)
    pbGraphicsUpdate
    Input.update
    break if !pictureBall.running? && !picturePoke.running?
  end
  if shakes < 4 && !critsuccess
    @sprites["shadow#{targetBattler}"].visible = oldvisible
    spriteBall.dispose
  else
    spriteBall.tone = Tone.new(-64, -64, -64, 128)
    pbSEPlay("catchclick", 100)
    @sprites["capture"] = spriteBall
    spritePoke.visible = false
  end
end



####################################################

class PokeBattle_Scene
  attr_reader :viewport
  attr_reader :sprites

  attr_accessor :log
  attr_accessor :gainEXPPhase # Used to disable logging of EXP gain messages in battle logs
  attr_accessor :moveUseDisplayPhase # Used to add color to move-use messages in in-game battle log
  attr_accessor :speakingTrainer # Used to add name tag and color to trainer messages in battle logs

  BLANK      = 0
  MESSAGEBOX = 1
  COMMANDBOX = 2
  FIGHTBOX   = 3
  FIGHTBOXDX = 4

  def initialize
    @battle = nil
    @lastcmd = [0, 0, 0, 0]
    @lastmove = [0, 0, 0, 0]
    @pkmnwindows = [nil, nil, nil, nil]
    @sprites = {}
    @battlestart = true
    @messagemode = false
    @aborted = false
  end

  def pbUpdate
    partyAnimationUpdate
    @sprites["battlebg"].update if @sprites["battlebg"].respond_to?("update")
    @sprites["battlebg2"].update if @sprites["battlebg2"] != nil && @sprites["battlebg2"].respond_to?("update")
  end

  def pbGraphicsUpdate(shift = false, oppside = true, playerside = true)
    partyAnimationUpdate(shift, oppside, playerside)
    @sprites["battlebg"].update if @sprites["battlebg"] != nil && @sprites["battlebg"].respond_to?("update")
    @sprites["battlebg2"].update if @sprites["battlebg2"] != nil && @sprites["battlebg2"].respond_to?("update")
    @sprites["enemybase"].update if @sprites["enemybase"] != nil && @sprites["enemybase"].respond_to?("update")
    @sprites["playerbase"].update if @sprites["playerbase"] != nil && @sprites["playerbase"].respond_to?("update")
    Graphics.update
  end

  def pbApplyBGSprite(sprite, filename)
    @sprites[sprite].setBitmap(filename)
  end

  def pbShowWindow(windowtype)
    @sprites["messagebox"].visible = windowtype == MESSAGEBOX || windowtype == COMMANDBOX || windowtype == FIGHTBOX || windowtype == BLANK
    @sprites["messagewindow"].visible = windowtype == MESSAGEBOX
    @sprites["commandwindow"].visible = windowtype == COMMANDBOX
    @sprites["defaultballdisplay"].visible = windowtype == COMMANDBOX
    @sprites["fightwindow"].visible = windowtype == FIGHTBOX
    @sprites["fightwindowdx"].visible = windowtype == FIGHTBOXDX
  end

  def pbSetMessageMode(mode)
    @messagemode = mode
    msgwindow = @sprites["messagewindow"]
    if mode # Within Pokémon command
      msgwindow.baseColor = PBScene::MENUBASE
      msgwindow.shadowColor = PBScene::MENUSHADOW
      msgwindow.opacity = 255
      msgwindow.setHW_XYZ(96, Graphics.width - 32, 16, Graphics.height - 94)
    else
      msgwindow.baseColor = PBScene::MESSAGEBASE
      msgwindow.shadowColor = PBScene::MESSAGESHADOW
      msgwindow.opacity = 0
      msgwindow.setHW_XYZ(96, Graphics.width - 32, 16, Graphics.height - 94)
    end
  end

  def pbClear
    @sprites["messagewindow"].text = ""
  end

  def pbWaitMessage
    if @briefmessage
      pbShowWindow(MESSAGEBOX)
      cw = @sprites["messagewindow"]
      40.times do
        pbGraphicsUpdate
        Input.update
      end
      # cw.text = ""
      # cw.visible = false
      @briefmessage = false
    end
  end

  def pbDisplay(msg, brief = false)
    pbDisplayMessage(msg, brief)
  end

  def pbDisplayWaiting(msg)
    pbDisplayMessage(msg, log: false)
  end

  def pbDisplayMessage(msg, brief = false, log: true, color: nil)
    ### Controls ###
    msg, controls = pbGetControls(msg)

    ### TTS, Add to Battle Log, Apply Color ###
    msg = pbHandleMessage(msg, color, log)

    ### Show Text ###
    cw = @sprites["messagewindow"]
    cw.text = msg
    i = 0
    loop do
      pbHandleControls(cw, controls)
      pbGraphicsUpdate
      Input.update
      cw.update

      if i == 40
        # cw.text = ""
        # cw.visible = false
        return
      end

      inputcheck = Input.trigger?(Input::C)
      if !cw.busy? && inputcheck
        if !inPartyAnimation?
          return
        end
      end
      cw.check_for_resume(inputcheck)

      if !cw.busy?
        if brief
          @briefmessage = true
          20.times do
            pbGraphicsUpdate
            Input.update
          end
          return
        end
        i += 1
      end
    end
  end

  def pbDisplayCommandPaused(msg)
    pbDisplayPausedMessage(msg, log: false)
  end

  def pbDisplayPausedMessage(msg, log: true, color: nil)
    ### Controls ###
    msg, controls = pbGetControls(msg)

    ### TTS, Add to Battle Log, Apply Color ###
    msg = pbHandleMessage(msg, color, log)
    if @messagemode
      @switchscreen.pbDisplay(msg)
      return
    end

    ### Show text ###
    cw = @sprites["messagewindow"]
    cw.text = msg + TextPlaceholders::InputPause
    loop do
      pbHandleControls(cw, controls)
      pbGraphicsUpdate
      Input.update

      inputcheck = Input.trigger?(Input::C)
      if !cw.busy? && inputcheck
        if !inPartyAnimation?
          cw.text = ""
          cw.visible = false if @messagemode
          pbPlayDecisionSE()
          return
        end
      end
      cw.check_for_resume(inputcheck)

      if Input.trigger?(Input::Y)
        showBattleLog(cw)
      end

      cw.update
    end
  end

  def pbDisplayConfirmMessage(msg)
    return pbShowCommands(msg, [_INTL("Yes"), _INTL("No")], 1) == 0
  end

  def pbDisplayConfirmMessageSerious(msg)
    return pbShowCommands(msg, [_INTL("No"), _INTL("Yes")], 0) == 1
  end

  def pbShowCommands(msg, commands, defaultValue)
    msg = pbHandleMessage(msg, nil, false)
    dw = @sprites["messagewindow"]
    dw.text = msg
    cw = Window_CommandPokemon.new(commands, tts: false)
    cw.x = Graphics.width - cw.width
    cw.y = Graphics.height - cw.height - dw.height
    cw.index = 0
    cw.viewport = @viewport
    pbRefresh
    update_menu = true
    lastread = nil
    loop do
      cw.visible = !dw.busy?
      pbGraphicsUpdate
      Input.update
      pbFrameUpdate(cw, update_menu)
      update_menu = false
      dw.update

      if commands[cw.index] != lastread
        pbPlayCursorSE()
        tts(commands[cw.index])
      end
      lastread = commands[cw.index]

      inputcheck = Input.trigger?(Input::C)
      if !dw.busy? && (inputcheck || (Input.trigger?(Input::B) && defaultValue >= 0))
        update_menu = true
        canceled = Input.trigger?(Input::B)
        cw.dispose
        dw.text = ""
        canceled ? pbPlayCancelSE() : pbPlayDecisionSE()
        return canceled ? defaultValue : cw.index
      end
      dw.check_for_resume(inputcheck)

      if Input.trigger?(Input::DOWN)
        update_menu = true
        cw.index = (cw.index + 1) % commands.length
      elsif Input.trigger?(Input::UP)
        update_menu = true
        cw.index = (cw.index - 1) % commands.length
      elsif Input.trigger?(Input::Y)
        showBattleLog(dw)
      end
    end
  end

  def pbHandleMessage(msg, color, log)
    # Display old message
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)

    charline = msg.gsub!("<char>", "") # gsub! returns nil if no match is found, otherwise the new string

    # TTS
    tts(msg.gsub("\n", " "))

    # Add to battle log
    if log && !@gainEXPPhase
      logcolor = @moveUseDisplayPhase ? :move : color
      logmsg = msg.gsub("\n", " ")
      if charline || @speakingTrainer
        # Different color for character lines
        logcolor = :character
        # Add name tag unless line is marked with <char> (such lines already have name tags)
        logmsg = @speakingTrainer.upcase + ": " + logmsg unless charline
        # Add character lines to overworld log too
        TextLog.add(ColorTags[:Default] + _INTL("[Battle]") + " " + logmsg)
      end
      PBDebug.log(@moveUseDisplayPhase ? ">>> #{logmsg}" : logmsg)
      addToBattleLog(logmsg, color: logcolor)
    end

    # Apply color for display in battle message box
    case color
      when :crit then color = ColorTags[PBScene::CritColor]
      when :faint then color = nil # Faint color is for log only
      when :karma then color = ColorTags[:Blue]
    end
    msg = color + msg if color

    return msg
  end

  def pbGetControls(msg)
    # Supported controls:
    #  \\se[] - Plays a sound effect. Specify a filename (not incl. extension) in Audio/SE folder.
    #           Use this control at the start of a string to play a sound when the message box appears.
    #           Leave the starting se's parameter blank to suppress the default sound.
    #  \\wt[] - Waits for an amount of frames. Specify an integer.
    textchunks = []
    controls = []
    msg = msg.dup # Avoid issues with frozen strings
    while msg[/(?:\\(se|wt)\[([^\]]*)\])/i]
      textchunks.push($~.pre_match)
      controls.push([$~[1].downcase, $~[2], -1])
      msg = $~.post_match
    end
    textchunks.push(msg)
    textchunks.each { |chunk| chunk.gsub!(/\005/, "\\") }
    textlen = 0
    for i in 0...controls.length
      control = controls[i][0]
      textchunks[i] += TextPlaceholders::TimedPause if control == "wt"
      textlen += toUnformattedText(textchunks[i]).scan(/./m).length
      controls[i][2] = textlen
    end
    msg = textchunks.join("")
    for i in 0...controls.length
      control = controls[i][0]
      param = controls[i][1]
      if control == "se" && controls[i][2] == 0
        startSE = param
        controls[i] = nil
      end
    end
    pbSEPlay(pbStringToAudioFile(startSE)) if startSE != nil

    return msg, controls
  end

  def pbHandleControls(cw, controls)
    for i in 0...controls.length
      if controls[i] && controls[i][2] <= cw.position && cw.waitcount == 0
        control = controls[i][0]
        param = controls[i][1]
        if control == "wt" # Wait
          param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
          cw.waitcount += param.to_i * 2
        elsif control == "se" # Play SE
          pbSEPlay(pbStringToAudioFile(param))
        end
        controls[i] = nil
      end
    end
  end

  def addToBattleLog(text, tts: nil, abilitybox: nil, color: nil)
    @log = [] if !@log

    colortag = case color
      when :round then ColorTags[:Orange2]
      when :character then ColorTags[:Green2]
      when :move then ColorTags[:Blue2]
      when :faint then ColorTags[:Red2]
      when :abilitybox then ColorTags[:Magenta]
      when :hp then ColorTags[:Gray3]
      when :crit then ColorTags[PBScene::CritColor]
      else ""
    end

    icontag = ""
    if abilitybox && (abilitybox.item || abilitybox.crest)
      icon = abilitybox.item ? pbItemIconFile(abilitybox.item) : "Graphics/Pictures/Battle/battleCrest"
      icontag = "<img=#{icon}>" + "   "
    end

    text = icontag + colortag + text
    @log.push(tts.nil? ? text : [text, tts])
  end

  def showBattleLog(msgwindow = nil)
    return if msgwindow&.busy? && !msgwindow.pausing?

    v = msgwindow.stopPause if msgwindow
    BattleLogScene.new(self, msgwindow&.busy?)
    msgwindow.startPause if msgwindow && v
  end

  def pbFrameUpdate(cw, update_cw = true)
    cw.update if cw && update_cw
    for i in 0...4
      @sprites["battlebox#{i}"].update if @sprites["battlebox#{i}"]
      @sprites["pokemon#{i}"].update if @sprites["pokemon#{i}"]
    end
  end

  def pbRefresh
    for i in 0...4
      if @sprites["battlebox#{i}"]
        @sprites["battlebox#{i}"].refresh
      end
    end
  end

  def pbAddSprite(id, x, y, filename, viewport)
    sprite = IconSprite.new(x, y, viewport)
    if filename
      sprite.setBitmap(filename) rescue nil
    end
    @sprites[id] = sprite
    return sprite
  end

  def pbAddPlane(id, filename, viewport)
    sprite = AnimatedPlane.new(viewport)
    if filename
      sprite.setBitmap(filename)
    end
    @sprites[id] = sprite
    return sprite
  end

  def pbDisposeSprites
    pbDisposeSpriteHash(@sprites)
  end

  def pbBeginCommandPhase
    # Called whenever a new round begins.
    @battlestart = false
  end

  def pbShowOpponent(index, trainertype = nil, outfit = nil)
    if @battle.opponent
      trainer = @battle.opponent.is_a?(Array) ? @battle.opponent[index] : @battle.opponent
      trainertype = trainer.trainertype if trainertype.nil?
      outfit = trainer.outfit if outfit.nil?
    end
    if trainertype.nil? || outfit.nil?
      trainerfile = pbTrainerSpriteFile(:TEST)
    else
      trainerfile = pbTrainerSpriteFile(trainertype, outfit)
    end
    pbAddSprite("trainer", Graphics.width, PBScene::FOETRAINER_Y, trainerfile, @viewport)
    if @sprites["trainer"].bitmap
      @sprites["trainer"].y -= @sprites["trainer"].bitmap.height
      @sprites["trainer"].z = 8
    end
    20.times do
      pbGraphicsUpdate
      Input.update
      [1, 3].each { |i| @sprites["pokemon#{i}"].opacity -= 6 if @sprites["pokemon#{i}"] }
      @sprites["trainer"].x -= 6
    end
  end

  def pbShowPokemon(mon, form = 0, shiny = false, aura = nil, shadow = false, status = nil)
    dexnum = $cache.pkmn[mon, form].dexnum.to_s.rjust(3, "0")
    dexname = mon.to_s.downcase
    formnumber = form == 0 ? "" : "_#{form}"
    formnumber = form.to_s if Rejuv
    toobig = $cache.pkmn[mon, form].checkFlag?(:toobig)
    bitmapFileName = pbCheckPokemonBitmapFiles(
      Desolation ? dexnum : dexname,
      shiny: shiny,
      formnumber: formnumber
    )
    pbAddSprite("pokemon", Graphics.width, PBScene::FOEBATTLER_Y, bitmapFileName, @viewport)
    spritesheet = RPG::Cache.load_bitmap(bitmapFileName)
    width = spritesheet.width / 2
    width = spritesheet.width if width < 192
    x = shiny ? width : 0 if width != spritesheet.width

    height = spritesheet.height / 2
    height = spritesheet.height if height < 192
    y = 0

    bitmap = Bitmap.new(width, height)
    rectangle = Rect.new(x, y, width, height)

    bitmap.blt(0, 0, spritesheet, rectangle)
    bitmapResize = Bitmap.new(bitmap.width + AURA_SPRITE_OFFSET, bitmap.height + AURA_SPRITE_OFFSET)
    bitmapResize.blt(AURA_SPRITE_OFFSET / 2, AURA_SPRITE_OFFSET / 2, bitmap, Rect.new(0, 0, bitmap.width, bitmap.height))
    bitmap = bitmapResize
    if mon == :SPINDA
      pbSpindaSpots(mon, bitmap)
    end
    if status == :PETRIFIED
      bitmap = makeGrayscaleBitmap(bitmap, bitmap.width, bitmap.height)
    elsif shadow
      bitmap = makeShadowBitmap(bitmap, bitmap.width, bitmap.height)
    elsif aura
      bitmap = makeGrayscaleBitmap(bitmap, bitmap.width, bitmap.height,) if aura == :p2alter
      auraColors = AuraTypeToColor[aura]
      bitmap = makeAuraBitmap(bitmap, bitmap.width, bitmap.height, *auraColors, 1000)
    end
    @sprites["pokemon"].bitmap = bitmap
    if @sprites["pokemon"].bitmap
      @sprites["pokemon"].y = 0
      @sprites["pokemon"].z = 8
    end
    20.times do
      pbGraphicsUpdate
      Input.update
      @sprites["pokemon"].x -= 6
    end
  end

  def pbHideOpponent
    20.times do
      pbGraphicsUpdate
      Input.update
      [1, 3].each { |i| @sprites["pokemon#{i}"].opacity += 6 if @sprites["pokemon#{i}"] }
      @sprites["trainer"].x += 6
    end
  end

  def pbHidePokemon
    20.times do
      pbGraphicsUpdate
      Input.update
      @sprites["pokemon"].x += 6
    end
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text, Graphics.width)
    @sprites["helpwindow"].y = 0
    @sprites["helpwindow"].x = 0
    @sprites["helpwindow"].text = text
    @sprites["helpwindow"].visible = true
  end

  def pbHideHelp
    @sprites["helpwindow"].visible = false
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
      base = "WaterSurface"
      # elsif $PokemonGlobal.lavasurfing
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
    pbAddSprite("playerbase", PBScene::PLAYERBASEX, PBScene::PLAYERBASEY, playerbase, @viewport)
    @sprites["playerbase"].x -= @sprites["playerbase"].bitmap.width / 2 if @sprites["playerbase"].bitmap != nil
    @sprites["playerbase"].y -= @sprites["playerbase"].bitmap.height if @sprites["playerbase"].bitmap != nil
    pbAddSprite("enemybase", PBScene::FOEBASEX, PBScene::FOEBASEY, enemybase, @viewport)
    @sprites["enemybase"].x -= @sprites["enemybase"].bitmap.width / 2 if @sprites["enemybase"].bitmap != nil
    @sprites["enemybase"].y -= @sprites["enemybase"].bitmap.height / 2 if @sprites["enemybase"].bitmap != nil
    @sprites["battlebg"].z = 0
    @sprites["playerbase"].z = 2
    @sprites["enemybase"].z = 1
  end

  # Returns whether the party line-ups are currently appearing on-screen
  def inPartyAnimation?
    return @enablePartyAnim && @partyAnimPhase < 3
  end

  def partyBetweenKO1(oppside = true)
    if oppside
      pbAddSprite("partybarfoe", foePartyBarX, foePartyBarY, "Graphics/Pictures/Battle/battleLineup", @viewport)
    end
    pbAddSprite("partybarplayer", playerPartyBarX, playerPartyBarY, "Graphics/Pictures/Battle/battleLineup", @viewport)
    @sprites["partybarfoe"].x -= @sprites["partybarfoe"].bitmap.width unless !oppside
    @sprites["partybarplayer"].mirror = true
    @sprites["partybarfoe"].z = 40 unless !oppside
    @sprites["partybarplayer"].z = 40
    @sprites["partybarfoe"].visible = false unless !oppside
    @sprites["partybarplayer"].visible = false
    ballmovedist = 16 # How far a ball moves each frame
    # Bar slides on
    @sprites["partybarfoe"].x += ballmovedist unless !oppside
    @sprites["partybarplayer"].x -= ballmovedist
    if oppside && @sprites["partybarfoe"].x + @sprites["partybarfoe"].bitmap.width >= foePartyBarX
      @sprites["partybarfoe"].x = foePartyBarX - @sprites["partybarfoe"].bitmap.width
      @sprites["partybarplayer"].x = playerPartyBarX
    end
    @enablePartyAnim = true
    @partyAnimPhase = 1
    loop do
      pbGraphicsUpdate(true, oppside, !oppside)
      break if @partyAnimPhase == 3
    end
    return
  end

  def partyBetweenKO2(oppside = true)
    if @sprites["partybarfoe"]
      @sprites["partybarfoe"].x -= foePartyBarX unless !oppside
    end
    if @sprites["partybarplayer"]
      @sprites["partybarplayer"].x += Graphics.width - playerPartyBarX
    end
    for i in 0...6
      pbDisposeSprite(@sprites, "enemy#{i}") unless !oppside
      pbDisposeSprite(@sprites, "player#{i}")
    end
  end

  # Shows the party line-ups appearing on-screen
  def partyAnimationUpdate(shift = false, oppside = true, playerside = true)
    return if !inPartyAnimation?

    barmovedist = 32
    ballmovedist = 32 # How far a ball moves each frame
    # Bar slides on
    if @partyAnimPhase == 0
      @sprites["partybarfoe"].x += barmovedist
      @sprites["partybarfoepartner"].x += barmovedist if (@battle.opponent.is_a?(Array) || TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype))
      @sprites["partybarplayer"].x -= barmovedist
      @sprites["partybarpartner"].x -= barmovedist if @battle.player.is_a?(Array)
      if @sprites["partybarfoe"].x + @sprites["partybarfoe"].bitmap.width >= foePartyBarX
        @sprites["partybarfoe"].x = foePartyBarX - @sprites["partybarfoe"].bitmap.width
        @sprites["partybarplayer"].x = playerPartyBarX
        @sprites["partybarfoepartner"].x = foePartyBarX - 20 - @sprites["partybarfoepartner"].bitmap.width if (@battle.opponent.is_a?(Array) ||  TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype))
        @sprites["partybarpartner"].x = playerPartyBarX + 20 if @battle.player.is_a?(Array)
        @partyAnimPhase = 1
      end
      return
    end
    # Set up all balls ready to slide on
    if @partyAnimPhase == 1
      @xposplayer = playerPartyBallOneX
      counter = 0
      # Make sure the ball starts off-screen
      while @xposplayer < Graphics.width
        counter += 1
        @xposplayer += ballmovedist
      end
      @xposenemy = foePartyBallOneX - counter * ballmovedist
      for i in 0...6
        # Choose the ball's graphic (player's side)
        if playerside
          # Player
          ballgraphic = "Graphics/Pictures/Battle/ballempty"
          if @battle.party1[0][i]
            if @battle.party1[0][i].hp <= 0 || @battle.party1[0][i].isEgg?
              ballgraphic = "Graphics/Pictures/Battle/ballfainted"
            elsif !@battle.party1[0][i].status.nil?
              ballgraphic = "Graphics/Pictures/Battle/ballstatus"
            else
              ballgraphic = "Graphics/Pictures/Battle/ballnormal"
            end
          end
          pbAddSprite("player#{i}", @xposplayer + i * ballmovedist * 6, playerPartyBallOneY, ballgraphic, @viewport)
          @sprites["player#{i}"].z = 41
          # Player's partner
          if @battle.player.is_a?(Array)
            ballgraphic = "Graphics/Pictures/Battle/ballempty"
            if @battle.party1[1][i]
              if @battle.party1[1][i].hp <= 0 || @battle.party1[1][i].isEgg?
                ballgraphic = "Graphics/Pictures/Battle/ballfainted"
              elsif !@battle.party1[1][i].status.nil?
                ballgraphic = "Graphics/Pictures/Battle/ballstatus"
              else
                ballgraphic = "Graphics/Pictures/Battle/ballnormal"
              end
            end
            pbAddSprite("partner#{i}", @xposplayer + 20 + i * ballmovedist * 6, playerPartyBallOneY + 40, ballgraphic, @viewport)
            @sprites["partner#{i}"].z = 41
          end
        end
        # Choose the ball's graphic (opponent's side)
        if oppside
          # Opponent
          ballgraphic = "Graphics/Pictures/Battle/ballempty"
          if @battle.party2[0][i]
            if @battle.party2[0][i].hp <= 0 || @battle.party2[0][i].isEgg?
              ballgraphic = "Graphics/Pictures/Battle/ballfainted"
            elsif !@battle.party2[0][i].status.nil?
              ballgraphic = "Graphics/Pictures/Battle/ballstatus"
            else
              ballgraphic = "Graphics/Pictures/Battle/ballnormal"
            end
          end
          y = shift ? foePartyBallOneY - 30 : foePartyBallOneY
          pbAddSprite("enemy#{i}", @xposenemy - i * ballmovedist * 6, y, ballgraphic, @viewport)
          @sprites["enemy#{i}"].z = 41
          # Opponent's partner
          if @battle.opponent.is_a?(Array)
            ballgraphic = "Graphics/Pictures/Battle/ballempty"
            if @battle.party2[1][i]
              if @battle.party2[1][i].hp <= 0 || @battle.party2[1][i].isEgg?
                ballgraphic = "Graphics/Pictures/Battle/ballfainted"
              elsif !@battle.party2[1][i].status.nil?
                ballgraphic = "Graphics/Pictures/Battle/ballstatus"
              else
                ballgraphic = "Graphics/Pictures/Battle/ballnormal"
              end
            end
            y = shift ? foePartyBallOneY - 30 : foePartyBallOneY
            pbAddSprite("enemypartner#{i}", @xposenemy - 20 - i * ballmovedist * 6, y + 40, ballgraphic, @viewport)
            @sprites["enemypartner#{i}"].z = 41
          elsif  @battle.party2[0].length > 6 || TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype)
            ballgraphic = "Graphics/Pictures/Battle/ballempty"
            if @battle.party2[0][i + 6]
              if @battle.party2[0][i + 6].hp <= 0 || @battle.party2[0][i + 6].isEgg?
                ballgraphic = "Graphics/Pictures/Battle/ballfainted"
              elsif !@battle.party2[0][i + 6].status.nil?
                ballgraphic = "Graphics/Pictures/Battle/ballstatus"
              else
                ballgraphic = "Graphics/Pictures/Battle/ballnormal"
              end
            end
            y = shift ? foePartyBallOneY - 30 : foePartyBallOneY
            pbAddSprite("enemypartner#{i}", @xposenemy - 20 - (i + 6) * ballmovedist * 6, y + 40, ballgraphic, @viewport)
            @sprites["enemypartner#{i}"].z = 41
          end
        end
      end
      @partyAnimPhase = 2
    end
    # Balls slide on
    if @partyAnimPhase == 2
      for i in 0...6
        if oppside
          if @sprites["enemy#{i}"].x < foePartyBallOneX - i * PBScene::FOEPARTYBALL_GAP
            @sprites["enemy#{i}"].x += ballmovedist
            @sprites["player#{i}"].x -= ballmovedist if playerside
            @sprites["enemypartner#{i}"].x += ballmovedist if (@battle.opponent.is_a?(Array) || TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype))
            @sprites["partner#{i}"].x -= ballmovedist if playerside && @battle.player.is_a?(Array)
            if @sprites["enemy#{i}"].x >= foePartyBallOneX - i * PBScene::FOEPARTYBALL_GAP
              @sprites["enemy#{i}"].x = foePartyBallOneX - i * PBScene::FOEPARTYBALL_GAP
              @sprites["player#{i}"].x = playerPartyBallOneX + i * PBScene::PLAYERPARTYBALL_GAP if playerside
              @sprites["enemypartner#{i}"].x = foePartyBallOneX - 20 - i * PBScene::FOEPARTYBALL_GAP if (@battle.opponent.is_a?(Array) || TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype))
              @sprites["partner#{i}"].x = playerPartyBallOneX + 20 + i * PBScene::PLAYERPARTYBALL_GAP if playerside && @battle.player.is_a?(Array)
              if i == 5
                @partyAnimPhase = 3
              end
              pbSEPlay(@sprites["enemy#{i}"].name.split("/")[-1]) rescue nil
            end
          end
        else
          if @sprites["player#{i}"].x > playerPartyBallOneX + i * PBScene::PLAYERPARTYBALL_GAP
            @sprites["player#{i}"].x -= ballmovedist
            @sprites["partner#{i}"].x -= ballmovedist if @battle.player.is_a?(Array)
            if @sprites["player#{i}"].x <= playerPartyBallOneX + i * PBScene::PLAYERPARTYBALL_GAP
              @sprites["player#{i}"].x = playerPartyBallOneX + i * PBScene::PLAYERPARTYBALL_GAP
              @sprites["partner#{i}"].x = playerPartyBallOneX + 20 + i * PBScene::PLAYERPARTYBALL_GAP if @battle.player.is_a?(Array)
              if i == 5
                @partyAnimPhase = 3
              end
              pbSEPlay(@sprites["player#{i}"].name.split("/")[-1]) rescue nil
            end
          end
        end
      end
    end
  end

  def createPokemonDataBox(battler, doublebattle, viewport, battle)
    if battle.pbIsEnemy(battler.index)
      if battler.isbossmon
        return BossPokemonDataBox.new(battler, doublebattle, viewport)
      elsif battler.issosmon
        return SosPokemonDataBox.new(battler, doublebattle, viewport)
      end
    end
    return PokemonDataBox.new(battler, doublebattle, viewport)
  end

  def pbStartBattle(battle)
    # Called whenever the battle begins
    @battle = battle
    @lastcmd = [0, 0, 0, 0]
    @lastmove = [0, 0, 0, 0]
    @showingplayer = true
    @showingenemy = true
    @sprites.clear
    @viewport = Viewport.new(0, Graphics.height / 2, Graphics.width, 0)
    @viewport.z = 99999
    @traineryoffset = (Graphics.height - 320) # Adjust player's side for screen size
    @foeyoffset = (@traineryoffset * 3 / 4).floor # Adjust foe's side for screen size
    pbBackdrop
    # Add opponent's party bar
    pbAddSprite(
      "partybarfoe",
      foePartyBarX,
      foePartyBarY,
      "Graphics/Pictures/Battle/battleLineup",
      @viewport
    )
    @sprites["partybarfoe"].x -= @sprites["partybarfoe"].bitmap.width
    @sprites["partybarfoe"].z = 40
    @sprites["partybarfoe"].visible = false
    # Add player's party bar
    pbAddSprite(
      "partybarplayer",
      playerPartyBarX,
      playerPartyBarY,
      "Graphics/Pictures/Battle/battleLineup",
      @viewport
    )
    @sprites["partybarplayer"].mirror = true
    @sprites["partybarplayer"].z = 40
    @sprites["partybarplayer"].visible = false
    # Add opponent partner's party bar
    if (@battle.opponent.is_a?(Array) || TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype))
      pbAddSprite(
        "partybarfoepartner",
        foePartyBarX - 20,
        foePartyBarY + 40,
        "Graphics/Pictures/Battle/battleLineup",
        @viewport
      )
      @sprites["partybarfoepartner"].x -= @sprites["partybarfoepartner"].bitmap.width
      @sprites["partybarfoepartner"].z = 40
      @sprites["partybarfoepartner"].visible = false
    end
    # Add player partner's party bar
    if @battle.player.is_a?(Array)
      pbAddSprite(
        "partybarpartner",
        playerPartyBarX + 20,
        playerPartyBarY + 40,
        "Graphics/Pictures/Battle/battleLineup",
        @viewport
      )
      @sprites["partybarpartner"].mirror = true
      @sprites["partybarpartner"].z = 40
      @sprites["partybarpartner"].visible = false
    end
    # Ability bars
    @sprites["abilityboxplayer"] = AbilityBox.new(0, @viewport) if AbilityBoxes
    @sprites["abilityboxfoe"]    = AbilityBox.new(1, @viewport) if AbilityBoxes
    if @battle.player.is_a?(Array)
      trainerfile = pbPlayerSpriteBackFile(@battle.player[0].trainertype)
      pbAddSprite("player", PBScene::PLAYERTRAINERD1_X, PBScene::PLAYERTRAINERD1_Y, trainerfile, @viewport)
      trainerfile = pbTrainerSpriteBackFile(@battle.player[1].trainertype)
      pbAddSprite("playerB", PBScene::PLAYERTRAINERD2_X, PBScene::PLAYERTRAINERD2_Y, trainerfile, @viewport)
      if @sprites["player"].bitmap
        if @sprites["player"].bitmap.width > @sprites["player"].bitmap.height
          @sprites["player"].src_rect.x = 0
          @sprites["player"].src_rect.width = @sprites["player"].bitmap.width / 5
        end
        @sprites["player"].x -= (@sprites["player"].src_rect.width / 2)
        @sprites["player"].y -= @sprites["player"].bitmap.height
        @sprites["player"].z = 30
      end
      if @sprites["playerB"].bitmap
        if @sprites["playerB"].bitmap.width > @sprites["playerB"].bitmap.height
          @sprites["playerB"].src_rect.x = 0
          @sprites["playerB"].src_rect.width = @sprites["playerB"].bitmap.width / 5
        end
        @sprites["playerB"].x -= (@sprites["playerB"].src_rect.width / 2)
        @sprites["playerB"].y -= @sprites["playerB"].bitmap.height
        @sprites["playerB"].z = 31
      end
    else
      trainerfile = pbPlayerSpriteBackFile(@battle.player.trainertype)
      pbAddSprite("player", PBScene::PLAYERTRAINER_X, PBScene::PLAYERTRAINER_Y, trainerfile, @viewport)
      if @sprites["player"].bitmap
        if @sprites["player"].bitmap.width > @sprites["player"].bitmap.height
          @sprites["player"].src_rect.x = 0
          @sprites["player"].src_rect.width = @sprites["player"].bitmap.width / 5
        end
        @sprites["player"].x -= (@sprites["player"].src_rect.width / 2)
        @sprites["player"].y -= @sprites["player"].bitmap.height
        @sprites["player"].z = 30
      end
    end
    if @battle.opponent
      if @battle.opponent.is_a?(Array)
        trainerfile = pbTrainerSpriteFile(@battle.opponent[1].trainertype, @battle.opponent[1].outfit)
        pbAddSprite("trainer2", PBScene::FOETRAINERD2_X, PBScene::FOETRAINERD2_Y, trainerfile, @viewport)
        trainerfile = pbTrainerSpriteFile(@battle.opponent[0].trainertype, @battle.opponent[0].outfit)
        pbAddSprite("trainer", PBScene::FOETRAINERD1_X, PBScene::FOETRAINERD1_Y, trainerfile, @viewport)
      else
        trainerfile = pbTrainerSpriteFile(@battle.opponent.trainertype, @battle.opponent.outfit)
        pbAddSprite("trainer", PBScene::FOETRAINER_X, PBScene::FOETRAINER_Y, trainerfile, @viewport)
      end
    else
      trainerfile = pbTrainerSpriteFile(:TEST)
      pbAddSprite("trainer", PBScene::FOETRAINER_X, PBScene::FOETRAINER_Y, trainerfile, @viewport)
    end
    if @sprites["trainer"].bitmap
      @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width / 2)
      @sprites["trainer"].y -= @sprites["trainer"].bitmap.height
      @sprites["trainer"].z = 8
    end
    if @sprites["trainer2"] && @sprites["trainer2"].bitmap
      @sprites["trainer2"].x -= (@sprites["trainer2"].bitmap.width / 2)
      @sprites["trainer2"].y -= @sprites["trainer2"].bitmap.height
      @sprites["trainer2"].z = 7
    end
    @sprites["shadow0"] = IconSprite.new(0, 0, @viewport)
    @sprites["shadow0"].z = 3
    @sprites["shadow1"] = PokemonShadowSprite.new(@viewport)
    @sprites["shadow1"].z = 3
    @sprites["shadow1"].visible = false
    @sprites["pokemon0"] = PokemonBattlerSprite.new(battle.doublebattle, 0, @viewport)
    @sprites["pokemon0"].z = 21
    @sprites["pokemon1"] = PokemonBattlerSprite.new(battle.doublebattle, 1, @viewport)
    @sprites["pokemon1"].z = 16
    if battle.doublebattle
      @sprites["shadow2"] = IconSprite.new(0, 0, @viewport)
      @sprites["shadow2"].z = 3
      @sprites["shadow3"] = PokemonShadowSprite.new(@viewport)
      @sprites["shadow3"].z = 3
      @sprites["shadow3"].visible = false
      @sprites["pokemon2"] = PokemonBattlerSprite.new(battle.doublebattle, 2, @viewport)
      @sprites["pokemon2"].z = 26 # Editing to see
      @sprites["pokemon3"] = PokemonBattlerSprite.new(battle.doublebattle, 3, @viewport)
      @sprites["pokemon3"].z = 11
    end
    @sprites["battlebox0"] = createPokemonDataBox(battle.battlers[0], battle.doublebattle, @viewport, battle)
    @sprites["battlebox1"] = createPokemonDataBox(battle.battlers[1], battle.doublebattle, @viewport, battle)
    if battle.doublebattle
      @sprites["battlebox2"] = createPokemonDataBox(battle.battlers[2], battle.doublebattle, @viewport, battle)
      @sprites["battlebox3"] = createPokemonDataBox(battle.battlers[3], battle.doublebattle, @viewport, battle)
    end
    pbAddSprite("messagebox", 0, Graphics.height - 96, "Graphics/Pictures/Battle/battleMessage", @viewport)
    @sprites["messagebox"].z = 90
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].z = 90
    @sprites["messagewindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagewindow"].allocPause("Graphics/Pictures/pause_battle") if Reborn
    @sprites["messagewindow"].letterbyletter = true
    @sprites["messagewindow"].viewport = @viewport
    @sprites["messagewindow"].z = 100
    @sprites["commandwindow"] = CommandMenuDisplay.new(@viewport)
    @sprites["commandwindow"].z = 100
    @sprites["fightwindow"] = FightMenuDisplay.new(nil, @viewport)
    @sprites["fightwindow"].z = 100
    @sprites["defaultballdisplay"] = DefaultBallDisplay.new(@battle, @viewport)
    @sprites["defaultballdisplay"].z = 100
    @sprites["fightwindowdx"] = FightMenuDisplaySpecial.new(nil, @viewport)
    @sprites["fightwindowdx"].z = 100
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].play
    @sprites["rightarrow"].play
    @sprites["leftarrow"].visible = false
    @sprites["rightarrow"].visible = false
    pbShowWindow(MESSAGEBOX)
    pbSetMessageMode(false)
    trainersprite1 = @sprites["trainer"]
    trainersprite2 = @sprites["trainer2"]
    if !@battle.opponent
      @sprites["trainer"].visible = false
      if @battle.party2[0].length >= 1
        if @battle.party2[0].length == 1
          pokemon = @battle.party2[0][0]
          @sprites["pokemon1"].setPokemonBitmap(pokemon, false)
          @sprites["pokemon1"].tone = Tone.new(-128, -128, -128, -128)
          @sprites["pokemon1"].x = PBScene::FOEBATTLER_X
          @sprites["pokemon1"].y = PBScene::FOEBATTLER_Y
          xoffset, yoffset = adjustBattleSprite(@sprites["pokemon1"], pokemon.getCacheData, 1)
          @sprites["pokemon1"].x += xoffset
          @sprites["pokemon1"].y += yoffset
          @sprites["pokemon1"].visible = true
          @sprites["shadow1"].setPokemonShadowBitmap(pokemon.getCacheData)
          @sprites["shadow1"].x = PBScene::FOEBATTLER_X
          @sprites["shadow1"].x += adjustShadowSpriteX(@sprites["shadow1"], pokemon.getCacheData) if @sprites["shadow1"].bitmap != nil
          @sprites["shadow1"].y = PBScene::FOEBATTLER_Y
          @sprites["shadow1"].y -= @sprites["shadow1"].bitmap.height / 2 if @sprites["shadow1"].bitmap != nil
          @sprites["shadow1"].visible = showShadow?(pokemon.getCacheData)
          trainersprite1 = @sprites["pokemon1"]
        elsif @battle.party2[0].length == 2
          pokemon = @battle.party2[0][0]
          @sprites["pokemon1"].setPokemonBitmap(pokemon, false)
          @sprites["pokemon1"].tone = Tone.new(-128, -128, -128, -128)
          @sprites["pokemon1"].x = PBScene::FOEBATTLERD1_X
          @sprites["pokemon1"].y = PBScene::FOEBATTLERD1_Y
          xoffset, yoffset = adjustBattleSprite(@sprites["pokemon1"], pokemon.getCacheData, 1)
          @sprites["pokemon1"].x += xoffset
          @sprites["pokemon1"].y += yoffset
          @sprites["pokemon1"].visible = true
          @sprites["shadow1"].setPokemonShadowBitmap(pokemon.getCacheData)
          @sprites["shadow1"].x = PBScene::FOEBATTLERD1_X
          @sprites["shadow1"].x += adjustShadowSpriteX(@sprites["shadow1"], pokemon.getCacheData) if @sprites["shadow1"].bitmap != nil
          @sprites["shadow1"].y = PBScene::FOEBATTLERD1_Y
          @sprites["shadow1"].y -= @sprites["shadow1"].bitmap.height / 2 if @sprites["shadow1"].bitmap != nil
          @sprites["shadow1"].visible = showShadow?(pokemon.getCacheData)
          trainersprite1 = @sprites["pokemon1"]
          pokemon = @battle.party2[0][1]
          @sprites["pokemon3"].setPokemonBitmap(pokemon, false)
          @sprites["pokemon3"].tone = Tone.new(-128, -128, -128, -128)
          @sprites["pokemon3"].x = PBScene::FOEBATTLERD2_X
          @sprites["pokemon3"].y = PBScene::FOEBATTLERD2_Y
          xoffset, yoffset = adjustBattleSprite(@sprites["pokemon3"], pokemon.getCacheData, 3)
          @sprites["pokemon3"].x += xoffset
          @sprites["pokemon3"].y += yoffset
          @sprites["pokemon3"].visible = true
          @sprites["shadow3"].setPokemonShadowBitmap(pokemon.getCacheData)
          @sprites["shadow3"].x = PBScene::FOEBATTLERD2_X
          @sprites["shadow3"].x += adjustShadowSpriteX(@sprites["shadow3"], pokemon.getCacheData) if @sprites["shadow3"].bitmap != nil
          @sprites["shadow3"].y = PBScene::FOEBATTLERD2_Y
          @sprites["shadow3"].y -= @sprites["shadow3"].bitmap.height / 2 if @sprites["shadow3"].bitmap != nil
          @sprites["shadow3"].visible = showShadow?(pokemon.getCacheData)
          trainersprite2 = @sprites["pokemon3"]
        end
      end
    end
    #################
    # Move trainers/bases/etc. off-screen
    oldx = []
    oldx[0] = @sprites["playerbase"].x; @sprites["playerbase"].x += Graphics.width
    oldx[1] = @sprites["player"].x; @sprites["player"].x += Graphics.width
    if @sprites["playerB"]
      oldx[2] = @sprites["playerB"].x; @sprites["playerB"].x += Graphics.width
    end
    oldx[3] = @sprites["enemybase"].x; @sprites["enemybase"].x -= Graphics.width
    oldx[4] = trainersprite1.x; trainersprite1.x -= Graphics.width
    if trainersprite2
      oldx[5] = trainersprite2.x; trainersprite2.x -= Graphics.width
    end
    oldx[6] = @sprites["shadow1"].x; @sprites["shadow1"].x -= Graphics.width
    if @sprites["shadow3"]
      oldx[7] = @sprites["shadow3"].x; @sprites["shadow3"].x -= Graphics.width
    end
    @sprites["partybarfoe"].x -= foePartyBarX
    @sprites["partybarplayer"].x += Graphics.width - playerPartyBarX
    @sprites["partybarfoepartner"].x -= foePartyBarX - 20 if (@battle.opponent.is_a?(Array) ||  TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype))
    @sprites["partybarpartner"].x += Graphics.width - (playerPartyBarX + 20) if @battle.player.is_a?(Array)
    if @battle.opponent
      @sprites["partybarfoe"].visible = true
      @sprites["partybarplayer"].visible = true
      @sprites["partybarfoepartner"].visible = true if (@battle.opponent.is_a?(Array) ||  TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype))
      @sprites["partybarpartner"].visible = true if @battle.player.is_a?(Array)
    end
    #################
    appearspeed = 18
    ballsAnimationStarted = false
    (1 + Graphics.width / appearspeed).times do
      tobreak = true
      if @viewport.rect.y > 0
        @viewport.rect.y -= appearspeed / 2
        @viewport.rect.y = 0 if @viewport.rect.y < 0
        @viewport.rect.height += appearspeed
        @viewport.rect.height = Graphics.height if @viewport.rect.height > Graphics.height
        tobreak = false
      end
      if !tobreak
        for i in @sprites
          i[1].ox = @viewport.rect.x
          i[1].oy = @viewport.rect.y
        end
      end
      if @sprites["playerbase"].x > oldx[0]
        @sprites["playerbase"].x -= appearspeed; tobreak = false
        @sprites["playerbase"].x = oldx[0] if @sprites["playerbase"].x < oldx[0]
      end
      if @sprites["player"].x > oldx[1]
        @sprites["player"].x -= appearspeed; tobreak = false
        @sprites["player"].x = oldx[1] if @sprites["player"].x < oldx[1]
      end
      if @sprites["playerB"] && @sprites["playerB"].x > oldx[2]
        @sprites["playerB"].x -= appearspeed; tobreak = false
        @sprites["playerB"].x = oldx[2] if @sprites["playerB"].x < oldx[2]
      end
      if @sprites["enemybase"].x < oldx[3]
        @sprites["enemybase"].x += appearspeed; tobreak = false
        @sprites["enemybase"].x = oldx[3] if @sprites["enemybase"].x > oldx[3]
      end
      if trainersprite1.x < oldx[4]
        trainersprite1.x += appearspeed; tobreak = false
        trainersprite1.x = oldx[4] if trainersprite1.x > oldx[4]
      end
      if trainersprite2 && trainersprite2.x < oldx[5]
        trainersprite2.x += appearspeed; tobreak = false
        trainersprite2.x = oldx[5] if trainersprite2.x > oldx[5]
      end
      if @sprites["shadow1"].x < oldx[6]
        @sprites["shadow1"].x += appearspeed; tobreak = false
        @sprites["shadow1"].x = oldx[6] if @sprites["shadow1"].x > oldx[6]
      end
      if @sprites["shadow3"] && @sprites["shadow3"].x < oldx[7]
        @sprites["shadow3"].x += appearspeed; tobreak = false
        @sprites["shadow3"].x = oldx[7] if @sprites["shadow3"].x > oldx[7]
      end
      # Start the animation to show trainer pokeballs.
      # Previously this was done only after this loop but I wanted to make the battle start faster. ~ enu
      if @battle.opponent && !ballsAnimationStarted && @sprites["enemybase"].x >= 0
        ballsAnimationStarted = true
        @enablePartyAnim = true
        @partyAnimPhase = 0
      end
      pbGraphicsUpdate
      Input.update
      break if tobreak
    end
    if !@battle.opponent
      # Play cry for wild Pokémon
      if !@battle.doublebattle
        pbPlayCry(@battle.party2[0][0])
      else
        pbPlayCry(@battle.party2[0][0])
        pbPlayCry(@battle.party2[0][1])
      end
      @sprites["battlebox1"].appear
      @sprites["battlebox3"].appear if @battle.party2[0].length == 2
      appearing = true
      begin
        pbGraphicsUpdate
        Input.update
        @sprites["battlebox1"].update
        @sprites["pokemon1"].tone.red += 8 if @sprites["pokemon1"].tone.red < 0
        @sprites["pokemon1"].tone.blue += 8 if @sprites["pokemon1"].tone.blue < 0
        @sprites["pokemon1"].tone.green += 8 if @sprites["pokemon1"].tone.green < 0
        @sprites["pokemon1"].tone.gray += 8 if @sprites["pokemon1"].tone.gray < 0
        appearing = @sprites["battlebox1"].appearing
        if @battle.party2[0].length == 2
          @sprites["battlebox3"].update
          @sprites["pokemon3"].tone.red += 8 if @sprites["pokemon3"].tone.red < 0
          @sprites["pokemon3"].tone.blue += 8 if @sprites["pokemon3"].tone.blue < 0
          @sprites["pokemon3"].tone.green += 8 if @sprites["pokemon3"].tone.green < 0
          @sprites["pokemon3"].tone.gray += 8 if @sprites["pokemon3"].tone.gray < 0
          appearing = (appearing || @sprites["battlebox3"].appearing)
        end
      end while appearing
      # Show shiny animation for wild Pokémon
      if @battle.party2[0][0].isShiny? && @battle.battlescene
        pbCommonAnimation("Shiny", @battle.battlers[1], nil)
      end
      if @battle.party2[0].length == 2
        if @battle.party2[0][1].isShiny? && @battle.battlescene
          pbCommonAnimation("Shiny", @battle.battlers[3], nil)
        end
      end
    end
  end

  def pbEndBattle(result)
    pbShowWindow(BLANK)
    # Fade out all sprites
    pbBGMFade(1.0)
    pbFadeOutAndHide(@sprites)
    pbDisposeSprites
  end

  def pbDisableShadowTemp(battler)
    if showShadow?(battler.getCacheData) && battler.index.odd?
      @sprites["shadow#{battler.index}"].visible = false
    end
  end

  def pbRecall(battlerindex)
    slideout = @battle.battlers[battlerindex].pokemon.ballused == :NOBALL
    @briefmessage = false
    if @battle.pbIsOpposing?(battlerindex)
      origin = PBScene::FOEBATTLER_Y
      if @battle.doublebattle
        origin = PBScene::FOEBATTLERD1_Y if battlerindex == 1
        origin = PBScene::FOEBATTLERD2_Y if battlerindex == 3
      end
      @sprites["shadow#{battlerindex}"].visible = false
    else
      origin = PBScene::PLAYERBATTLER_Y
      if @battle.doublebattle
        origin = PBScene::PLAYERBATTLERD1_Y if battlerindex == 0
        origin = PBScene::PLAYERBATTLERD2_Y if battlerindex == 2
      end
    end
    spritePoke = @sprites["pokemon#{battlerindex}"]
    picturePoke = PictureEx.new(spritePoke.z)
    center = getSpriteCenter(spritePoke)
    # starting positions
    picturePoke.moveVisible(1, true)
    picturePoke.moveOrigin(1, PictureOrigin::Center)
    picturePoke.moveXY(0, 1, center[0], center[1])
    # directives
    #    picturePoke.moveTone(10,1,Tone.new(0,-224,-224,0))
    if slideout
      delay = picturePoke.totalDuration
      picturePoke.moveXY(20, delay, center[0] + 240, center[1])
      picturePoke.moveOrigin(picturePoke.totalDuration, PictureOrigin::TopLeft)
    else
      picturePoke.moveTone(10, 1, Tone.new(248, 248, 248, 248))
      delay = picturePoke.totalDuration
      picturePoke.moveSE(delay, "Audio/SE/recall")
      picturePoke.moveZoom(15, delay, 0)
      picturePoke.moveXY(15, delay, center[0], origin)
      picturePoke.moveVisible(picturePoke.totalDuration, false)
      picturePoke.moveTone(0, picturePoke.totalDuration, Tone.new(0, 0, 0, 0))
      picturePoke.moveOrigin(picturePoke.totalDuration, PictureOrigin::TopLeft)
    end
    loop do
      picturePoke.update
      setPictureSprite(spritePoke, picturePoke)
      pbGraphicsUpdate
      Input.update
      break if !picturePoke.running?
    end
  end

  # Accepts an array like this: [[index, pokemon, slidein]]
  def pbTrainerSendOut(slots)
    @briefmessage = false
    while inPartyAnimation?; end

    animations = []
    delayCry = false
    slots.each do |battlerindex, pokemon, slidein|
      if @sprites["battlebox#{battlerindex}"]
        @sprites["battlebox#{battlerindex}"].visible = false
        @sprites["pokemon#{battlerindex}"].setPokemonBitmap(@battle.battlers[battlerindex].visiblePokemon, false)
        @sprites["pokemon#{battlerindex}"].opacity = 255
        pbDisposeSprite(@sprites, ["battlebox#{battlerindex}"])
      end
      @sprites["battlebox#{battlerindex}"] = createPokemonDataBox(@battle.battlers[battlerindex], @battle.doublebattle, @viewport, @battle)

      # Setup animations
      boxappear = BattleBoxAppearAnimation.new(@sprites["battlebox#{battlerindex}"])
      if slidein
        slideanim = SlideSendOutAnimation.new(
          @sprites["pokemon#{battlerindex}"],
          @sprites, @battle.battlers[battlerindex],
          delayCry, true,
        )

        animations.push ParallelAnimation.new(slideanim, boxappear)
      else
        trainersendout = PokeballSendOutAnimation.new(
          @sprites["pokemon#{battlerindex}"],
          @sprites, @battle.battlers[battlerindex],
          delayCry,
        )

        # The WaitAnimation controls how long the trainer's pokeball stays on screen before opening.
        animations.push ParallelAnimation.new(
          AnimationQueue.new(WaitAnimation.new(10), trainersendout),
          boxappear,
        )
      end
      delayCry = true
    end

    if @showingenemy
      animations.push TrainerFadeAnimation.new(@sprites)
    end

    sendout = ParallelAnimation.new(*animations)

    loop do
      sendout.update
      pbGraphicsUpdate
      Input.update
      break if sendout.animdone?
    end

    sendout.dispose

    slots.each do |battlerindex, pokemon, slidein|
      if @battle.battlescene && @battle.battlers[battlerindex].visiblePokemon.isShiny?
        pbCommonAnimation("Shiny", @battle.battlers[battlerindex], nil)
      end
    end

    if @showingenemy
      @showingenemy = false
      pbDisposeSprite(@sprites, "trainer")
      pbDisposeSprite(@sprites, "partybarfoe")
      for i in 0...6
        pbDisposeSprite(@sprites, "enemy#{i}")
      end
    end

    # Replace sprite when you Baton Pass a Substitute
    slots.each do |battlerindex, pokemon, slidein|
      if @battle.battlers[battlerindex].effects[:Substitute] > 0
        @battle.pbPlaySubstituteAnimation(@battle.battlers[battlerindex])
      end
    end

    pbRefresh
  end

  # Accepts an array like this: [[index, pokemon, slidein]]
  def pbSendOut(slots) # Player sending out Pokémon
    @briefmessage = false
    while inPartyAnimation?; end

    animations = []
    throw = false
    delayCry = false
    slots.each do |battlerindex, pokemon, slidein|
      @sprites["battlebox#{battlerindex}"].visible = false
      @sprites["pokemon#{battlerindex}"].setPokemonBitmap(@battle.battlers[battlerindex].visiblePokemon, true)
      @sprites["pokemon#{battlerindex}"].opacity = 255

      # Setup animations
      boxappear = BattleBoxAppearAnimation.new(@sprites["battlebox#{battlerindex}"])
      if slidein
        slideanim = SlideSendOutAnimation.new(
          @sprites["pokemon#{battlerindex}"],
          @sprites, @battle.battlers[battlerindex],
          delayCry,
        )

        animations.push ParallelAnimation.new(slideanim, boxappear)
      else
        spriteBall = IconSprite.new(0, 0, @viewport)
        spriteBall.visible = false
        multiplier = 1.0
        if @battle.doublebattle && @battle.sosbattle != :singlePokemonPlayerSide
          multiplier = battlerindex == 0 ? 0.7 : 1.3
        end
        ballanim = PlayerBallSendOutAnimation.new(spriteBall,  pokemon.ballused, multiplier, @traineryoffset)

        playersendout = PokeballPlayerSendOutAnimation.new(
          @sprites["pokemon#{battlerindex}"],
          @sprites, @battle.battlers[battlerindex],
          delayCry,
        )

        animations.push AnimationQueue.new(
          ballanim,
          ParallelAnimation.new(playersendout, boxappear),
        )

        throw = true
      end
      delayCry = true
    end

    sendout = ParallelAnimation.new(*animations)

    if @showingplayer
      # The WaitAnimation controls when the ball throw animation starts.
      # The timing is important to make it appear that the ball is thrown from player's hand.
      sendout = ParallelAnimation.new(
        PlayerFadeAnimation.new(@sprites, throw),
        AnimationQueue.new(WaitAnimation.new(10), sendout)
      )
    end

    # Run animations
    loop do
      sendout.update
      pbGraphicsUpdate
      Input.update
      break if sendout.animdone?
    end

    sendout.dispose

    slots.each do |battlerindex, pokemon, slidein|
      if @battle.battlescene && @battle.battlers[battlerindex].visiblePokemon.isShiny?
        pbCommonAnimation("Shiny", @battle.battlers[battlerindex], nil)
      end
    end

    if @showingplayer
      @showingplayer = false
      pbDisposeSprite(@sprites, "player")
      pbDisposeSprite(@sprites, "partybarplayer")
      for i in 0...6
        pbDisposeSprite(@sprites, "player#{i}")
      end
    end

    # Replace sprite when you Baton Pass a Substitute
    slots.each do |battlerindex, pokemon, slidein|
      if @battle.battlers[battlerindex].effects[:Substitute] > 0
        @battle.pbPlaySubstituteAnimation(@battle.battlers[battlerindex])
      end

      if @battle.pbOwnedByPlayer?(battlerindex) && @battle.battlers[battlerindex].hp > 0
        threshold = (@battle.battlers[battlerindex].totalhp / 4.0).floor
        if $game_switches[:Blindstep] && @battle.battlers[battlerindex].hp <= threshold
          if @battle.doublebattle
            pbAccessibilitySEPlay("Blindstep- LowHP", x: battlerindex == 0 ? -1 : 1)
          else
            pbAccessibilitySEPlay("Blindstep- LowHP")
          end
        end
      end
    end

    pbRefresh
  end

  def pbTrainerWithdraw(battle, pkmn)
    pbRefresh
  end

  def pbWithdraw(battle, pkmn)
    pbRefresh
  end

  # battler = The battler for whom the ability box is being displayed.
  # item = May be passed as an item symbol, or 'true' to refer to the battler's current item. Causes the displayed attribute to be an item instead of an ability. If the battler is 'crested', displays the crest symbol in the box, otherwise displays the item icon.
  # attrname = String that overrides the displayed attribute, for special cases.
  # crest = May be passed as 'true'/'false'. Forces the crest symbol to be displayed/not, for special cases.
  def pbShowAbilityBox(battler, item: nil, attrname: nil, crest: nil)
    return unless AbilityBoxes

    abilitybox = @sprites["abilitybox#{(battler.index & 1 == 0) ? "player" : "foe"}"]
    vars_before = abilitybox.getDisplayVars

    abilitybox.setBattler(battler, item, attrname, crest)

    # If pbShowAbilityBox is called while the box in question is already on screen, check if the new call is supposed to display anything different
    # If not, do an early return, otherwise hide the on-screen box and continue on to show a new one
    if abilitybox.onscreen
      abilitybox.getDisplayVars == vars_before ? return : pbHideAbilityBox(battler)
    end

    abilitybox.setText

    pbSEPlay("ability")
    loop do
      pbGraphicsUpdate
      Input.update
      if abilitybox.playerside
        abilitybox.x += abilitybox.appearSpeed
        if abilitybox.x >= abilitybox.spriteX
          abilitybox.x = abilitybox.spriteX
          break
        end
      else
        abilitybox.x -= abilitybox.appearSpeed
        if abilitybox.x <= abilitybox.spriteX
          abilitybox.x = abilitybox.spriteX
          break
        end
      end
    end
    abilitybox.onscreen = true

    pbAbilityBoxToText(battler, item, attrname, abilitybox: abilitybox) # TTS + Logging
  end

  def pbHideAbilityBox(battler)
    return unless AbilityBoxes

    abilitybox = @sprites["abilitybox#{(battler.index & 1 == 0) ? "player" : "foe"}"]
    return unless abilitybox.onscreen
    return if abilitybox.index != battler.index

    waitframes = PBScene::MINIMUM_FRAMES - abilitybox.frames
    waitframes.times { pbGraphicsUpdate } if waitframes > 0

    loop do
      pbGraphicsUpdate
      Input.update
      if abilitybox.playerside
        abilitybox.x -= abilitybox.appearSpeed
        if abilitybox.x <= abilitybox.oldX
          abilitybox.x = abilitybox.oldX
          break
        end
      else
        abilitybox.x += abilitybox.appearSpeed
        if abilitybox.x >= abilitybox.oldX
          abilitybox.x = abilitybox.oldX
          break
        end
      end
    end
    abilitybox.onscreen = false
    abilitybox.frames = 0
  end

  def pbChangeAbilityBox(battler)
    return unless AbilityBoxes

    abilitybox = @sprites["abilitybox#{(battler.index & 1 == 0) ? "player" : "foe"}"]
    return unless abilitybox.onscreen
    return if abilitybox.index != battler.index

    pbSEPlay("PRSFX- Health Up")
    loop do
      abilitybox.mosaicRefresh
      pbGraphicsUpdate
      Input.update
      abilitybox.mosaic += 1
      break if abilitybox.mosaic >= 10
    end
    abilitybox.setBattler(battler)
    abilitybox.setText
    loop do
      abilitybox.mosaicRefresh
      pbGraphicsUpdate
      Input.update
      abilitybox.mosaic -= 1
      break if abilitybox.mosaic <= 0
    end

    pbAbilityBoxToText(battler, abilitybox: abilitybox) # TTS + Logging
  end

  def pbAbilityBoxAndDisplay(battler, message, item: nil, attrname: nil)
    pbShowAbilityBox(battler, item: item, attrname: attrname)
    pbDisplay(message)
    pbHideAbilityBox(battler)
  end

  def pbAbilityBoxAndWait(battler, item: nil, attrname: nil)
    pbShowAbilityBox(battler, item: item, attrname: attrname)
    pbHideAbilityBox(battler)
  end

  def pbAbilityBoxToText(battler, item = nil, attrname = nil, abilitybox: nil)
    string = getAbilityBoxAttrString(battler, item, attrname)
    msg = _INTL("{1}'s {2}", battler.name, string)
    msg = "[#{msg}]"

    tts(msg)
    PBDebug.log(msg)
    addToBattleLog(msg, abilitybox: abilitybox, color: :abilitybox)
    puts(msg) if $console_battle # test suite
  end

  def pbShieldBreakToText(battler)
    msg = _INTL("{1}'s shield \#{2} was broken", battler.name, battler.shieldCount)
    msg = "[#{msg}]"

    tts(msg)
    PBDebug.log(msg)
    addToBattleLog(msg, color: :faint)
    puts(msg) if $console_battle # test suite
  end

  def pbBeginAttackPhase
    pbSelectBattler(-1)
    pbGraphicsUpdate
  end

  def pbSafariStart
    @briefmessage = false
    @sprites["battlebox0"] = SafariDataBox.new(@battle, @viewport)
    @sprites["battlebox0"].appear
    loop do
      @sprites["battlebox0"].update
      pbGraphicsUpdate
      Input.update
      break if !@sprites["battlebox0"].appearing
    end
    pbRefresh
  end

  def pbResetCommandIndices
    @lastcmd = [0, 0, 0, 0]
  end

  def pbResetMoveIndex(index)
    @lastmove[index] = 0
  end

  def pbSafariCommandMenu(index)
    pbCommandMenuEx(
      index,
      [
        _INTL("What will\n{1} throw?", @battle.pbPlayer.name),
        _INTL("Ball"),
        _INTL("Bait"),
        _INTL("Rock"),
        _INTL("Run")
      ],
      2
    )
  end

  # Use this method to display the list of commands.
  # Return values: 0=Fight, 1=Bag, 2=Pokémon, 3=Run, 4=Call
  def pbCommandMenu(index)
    shadowMon = !@battle.battlers[0].isFainted? && @battle.battlers[0].isShadow?
    if @battle.doublebattle && @battle.pbGetOwnerIndex(0) == @battle.pbGetOwnerIndex(2)
      shadowMon = true if !@battle.battlers[2].isFainted? && @battle.battlers[2].isShadow?
    end
    grandfinale = $game_switches[:Friends_Help_Plz] && @battle.specialmoves.length > 0
    if grandfinale && $game_switches[:Only_Ally_Moves]
        ret = pbCommandMenuEx(
          index,
          [
            _INTL("What will\n{1} do?", @battle.battlers[index].name),
            _INTL("Partner"),
            _INTL("Partner"),
            _INTL("Partner"),
            _INTL("Partner")
          ],
          (5)
        )
        ret = 5
    else
      ret = pbCommandMenuEx(
        index,
        [
          _INTL("What will\n{1} do?", @battle.battlers[index].name),
          _INTL("Fight"),
          _INTL("Bag"),
          _INTL("Pokémon"),
          (grandfinale) ? _INTL("Partner") : ((shadowMon ? _INTL("Call") : _INTL("Run")))
        ],
        ((grandfinale) ? 4 : (shadowMon ? 1 : 0))
      )
      if ret == 3
        ret = (grandfinale) ? 5 : (shadowMon ? 4 : 3) # Convert "Run" to "Call" or "Partners"
      end
    end
    return ret
  end

  def pbToggleStatsBoostsVisibility
    $doShowStatBoosts = true if !defined?($doShowStatBoosts)
    $doShowStatBoosts = !$doShowStatBoosts
    for i in 0..3
      tmp = "battlebox#{i}"
      @sprites[tmp].refresh if @sprites[tmp]
    end
  end

  # Mode: 0 - regular battle
  #       1 - Shadow Pokémon battle
  #       2 - Safari Zone
  #       3 - Bug Catching Contest
  def pbCommandMenuEx(index, texts, mode = 0)
    pbShowWindow(COMMANDBOX)
    cw = @sprites["commandwindow"]
    cw.setTexts(texts)
    cw.index = 0 if @lastcmd[index] == 2 || $Settings.remember_commands == 0
    cw.mode = mode
    balldisplay = @sprites["defaultballdisplay"]
    balldisplay.pbSet(index)
    fieldnotes = readableFieldNotes()
    bossnotes = readableBossNotes(@battle)
    pbSelectBattler(index)
    pbRefresh
    update_menu = true
    holdZ = false
    tts(texts[0].gsub("\n", " "))
    loop do
      pbFrameUpdate(cw, update_menu)
      balldisplay.update
      pbGraphicsUpdate
      Input.update
      update_menu = false

      if Input.triggerex?(Input::F2)
        scene = DefaultControlsScene.new(2)
        pbFadeOutIn(99999) { scene.pbRender }
      elsif Input.shiftKeyTriggered? && !Rejuv
        pbToggleStatsBoostsVisibility
        pbPlayCursorSE()
        ttsStatStages
      elsif Input.trigger?(Input::LEFT)
        if (cw.index & 1) == 1 && mode != 5
          pbPlayCursorSE()
          cw.index -= 1
          update_menu = true
        end
      elsif Input.trigger?(Input::RIGHT)
        if (cw.index & 1) == 0 && mode != 5
          pbPlayCursorSE()
          cw.index += 1
          update_menu = true
        end
      elsif Input.trigger?(Input::UP)
        if (cw.index & 2) == 2 && mode != 5
          pbPlayCursorSE()
          cw.index -= 2
          update_menu = true
        end
      elsif Input.trigger?(Input::DOWN)
        if (cw.index & 2) == 0 && mode != 5
          pbPlayCursorSE()
          cw.index += 2
          update_menu = true
        end
      elsif Input.trigger?(Input::L) # Show Battle Stats feature made by DemICE, Trainer Pokemon
        pbShowBattleStats(index) unless pbInSafari?
      elsif Input.trigger?(Input::R) # Show Battle Stats feature made by DemICE, Opponent Pokemon
        pbShowBattleStats(index ^ 1) unless pbInSafari?
      elsif Input.trigger?(Input::Y) # Battle log
        showBattleLog
      elsif Input.trigger?(Input::A) && balldisplay.canthrow # Default Poke Ball
        ballchosen = balldisplay.pbSelect
        return :ball if ballchosen
      elsif Input.trigger?(Input::C) # Confirm choice
        pbPlayDecisionSE()
        ret = cw.index
        @lastcmd[index] = ret
        return ret
      elsif Input.trigger?(Input::B) # Cancel
        if index == 2 # && @lastcmd[0]!=2 # Commented out for cancelling switches in doubles
          pbPlayDecisionSE()
          return -1
        end
        if @battle.specialchoices[index] != [nil]
          pbPlayDecisionSE()
          return -1
        end
      else
        checkKeyPressesCommand()
      end

      showFieldNotes, showBossNotes = false, false
      holdZ = false if Input.time?(Input::Z) == 0.0 && !Input.release?(Input::Z)
      if Input.time?(Input::Z) >= 0.5
        if $game_switches[:Blindstep]
          holdZ = true
        else
          showBossNotes = true
        end
      elsif Input.release?(Input::Z) && !Input.press?(Input::Z)
        if holdZ
          holdZ = false
          showBossNotes = true
        else
          showFieldNotes = true
        end
      end
      if showFieldNotes && canCheckFieldApp?(fieldnotes)
        pbPlayCursorSE()
        infoscene = Scene_FieldNotes_Battle.new
        pbCheckPokegearScene(infoscene, fieldnotes)
      end
      if showBossNotes && canCheckBossDex?(bossnotes)
        pbPlayCursorSE()
        infoscene = Scene_BossDex_Battle.new
        pbCheckPokegearScene(infoscene, bossnotes)
      end

      tts(texts[cw.index + 1], true) if update_menu
    end
  end

  # To be overwritten per game
  def checkKeyPressesCommand; end

  def pbTransitionFromBattleScene
    pbShowWindow(BLANK)
    pbSetMessageMode(true)
    visiblesprites = pbFadeOutAndHide(@sprites)
    return visiblesprites
  end

  def pbTransitionToBattleScene(visiblesprites)
    pbShowWindow(BLANK)
    pbSetMessageMode(false)
    pbFadeInAndShow(@sprites, visiblesprites)
  end

  # Use this method to display the list of moves for a Pokémon
  def pbFightMenu(index)
    pbShowWindow(FIGHTBOX)
    cw = @sprites["fightwindow"]
    battler = @battle.battlers[index]
    cw.battler = battler
    lastIndex = @lastmove[index]
    if battler.moves[lastIndex]
      cw.setIndex(lastIndex)
    else
      cw.setIndex(0)
    end
    cw.megaButton = 0
    cw.megaButton = 1 if (@battle.pbCanMegaEvolve?(index) && !@battle.pbCanZMove?(index))
    cw.megaButton = 2 if @battle.megaEvolution[(@battle.pbIsOpposing?(index)) ? 1 : 0][@battle.pbGetOwnerIndex(index)] == index && @battle.battlers[index].hasMega?
    cw.ultraButton = 0
    cw.ultraButton = 1 if @battle.pbCanUltraBurst?(index)
    cw.ultraButton = 2 if @battle.ultraBurst[(@battle.pbIsOpposing?(index)) ? 1 : 0][@battle.pbGetOwnerIndex(index)] == index && @battle.battlers[index].hasUltra?
    cw.teraButton = 0
    cw.teraButton = 1 if @battle.pbCanTerastallize?(index)
    cw.teraButton = 2 if @battle.terastal[(@battle.pbIsOpposing?(index)) ? 1 : 0][@battle.pbGetOwnerIndex(index)] == index && @battle.battlers[index].hasTera?
    cw.zButton = 0
    cw.zButton = 1 if @battle.pbCanZMove?(index)
    # cw.zButton=2 if @battle.zMove[(@battle.pbIsOpposing?(index)) ? 1 : 0][@battle.pbGetOwnerIndex(index)] == index && @battle.battlers[index].hasZMove?
    fieldnotes = readableFieldNotes()
    bossnotes = readableBossNotes(@battle)
    pbSelectBattler(index)
    pbRefresh
    update_menu, update_menu_mega = true, true
    holdZ = false
    loop do
      pbFrameUpdate(cw, update_menu || update_menu_mega)
      Graphics.update
      Input.update
      if update_menu
        ttsMove(battler, cw.index, cw.zButton == 2)
        pbDrawMoveDetails(battler, cw.index, cw.zButton == 2) if showingMoveDetails?
      end
      update_menu, update_menu_mega = false, false

      if Input.triggerex?(Input::F2)
        pbDisposeMoveDetails
        scene = DefaultControlsScene.new(2)
        pbFadeOutIn(99999) { scene.pbRender }
      elsif Input.shiftKeyTriggered? && !Rejuv
        pbToggleStatsBoostsVisibility
        pbPlayCursorSE()
        ttsStatStages
      elsif Input.trigger?(Input::LEFT) && (cw.index & 1) == 1 && cw.setIndex(cw.index - 1)
        pbPlayCursorSE()
        update_menu = true
      elsif Input.trigger?(Input::RIGHT) && (cw.index & 1) == 0 && cw.setIndex(cw.index + 1)
        pbPlayCursorSE()
        update_menu = true
      elsif Input.trigger?(Input::UP) && (cw.index & 2) == 2 && cw.setIndex(cw.index - 2)
        pbPlayCursorSE()
        update_menu = true
      elsif Input.trigger?(Input::DOWN) && (cw.index & 2) == 0 && cw.setIndex(cw.index + 2)
        pbPlayCursorSE()
        update_menu = true
      elsif Input.trigger?(Input::L) # Show Battle Stats feature made by DemICE, Trainer Pokemon
        pbDisposeMoveDetails
        pbShowBattleStats(index)
      elsif Input.trigger?(Input::R) # Show Battle Stats feature made by DemICE, Opponent Pokemon
        pbDisposeMoveDetails
        pbShowBattleStats(index ^ 1)
      elsif Input.trigger?(Input::Y) # Battle log
        pbDisposeMoveDetails
        showBattleLog
      elsif Input.trigger?(Input::A) # Toggle move details
        showingMoveDetails? ? pbDisposeMoveDetails : pbDrawMoveDetails(battler, cw.index, cw.zButton == 2)
        pbPlayCursorSE()
      elsif Input.trigger?(Input::C) # Confirm choice
        pbDisposeMoveDetails
        ret = cw.index
        if cw.zButton == 2
          if battler.pbCompatibleZMoveFromMove?(ret, true)
            pbPlayDecisionSE()
            @lastmove[index] = ret
            return ret
          else
            @battle.pbDisplayCommandPaused(_INTL("{1} is not compatible with {2}!", battler.moves[ret].name, getItemName(battler.item)))
            @lastmove[index] = cw.index
            return -1
          end
        else
          pbPlayDecisionSE()
          @lastmove[index] = ret
          return ret
        end
      elsif Input.trigger?(Input::X) # Use Mega Evolution
        if @battle.pbCanMegaEvolve?(index) && !pbIsZCrystal?(battler.item)
          if cw.megaButton == 2
            tts("Mega Evolution deactivated", true)
            @battle.pbUnRegisterMegaEvolution(index)
            cw.megaButton = 1
            pbPlayCancelSE()
          else
            tts("Mega Evolution activated", true)
            @battle.pbRegisterMegaEvolution(index)
            cw.megaButton = 2
            pbPlayDecisionSE()
          end
        end
        if @battle.pbCanUltraBurst?(index)
          if cw.ultraButton == 2
            tts("Ultra Burst deactivated", true)
            @battle.pbUnRegisterUltraBurst(index)
            cw.ultraButton = 1
            pbPlayCancelSE()
          else
            tts("Ultra Burst activated", true)
            @battle.pbRegisterUltraBurst(index)
            cw.ultraButton = 2
            pbPlayDecisionSE()
          end
        end
        if @battle.pbCanTerastallize?(index)
          if cw.teraButton == 2
            tts("Terastallization deactivated", true)
            @battle.pbUnRegisterTerastallization(index)
            cw.teraButton = 1
            pbPlayCancelSE()
          else
            tts("Terastallization activated", true)
            @battle.pbRegisterTerastallization(index)
            cw.teraButton = 2
            pbPlayDecisionSE()
          end
        end
        if @battle.pbCanZMove?(index) # Use Z Move
          if cw.zButton == 2
            tts("Z-Moves deactivated", true)
            @battle.pbUnRegisterZMove(index)
            cw.zButton = 1
            cw.setIndex(0) unless @battle.battlers[index].moves[cw.index]
            pbPlayCancelSE()
          else
            tts("Z-Moves activated", true)
            @battle.pbRegisterZMove(index)
            cw.zButton = 2
            pbPlayDecisionSE()
          end
          update_menu = true if battler.zmoves[cw.index]
        end
        update_menu_mega = true
      elsif Input.trigger?(Input::B) # Cancel fight menu
        pbDisposeMoveDetails
        @lastmove[index] = cw.index
        pbPlayCancelSE()
        return -1
      else
        checkKeyPressesFight()
      end

      showFieldNotes, showBossNotes = false, false
      holdZ = false if Input.time?(Input::Z) == 0.0 && !Input.release?(Input::Z)
      if Input.time?(Input::Z) >= 0.5
        if $game_switches[:Blindstep]
          holdZ = true
        else
          showBossNotes = true
        end
      elsif Input.release?(Input::Z) && !Input.press?(Input::Z)
        if holdZ
          holdZ = false
          showBossNotes = true
        else
          showFieldNotes = true
        end
      end
      if showBossNotes && canCheckBossDex?(bossnotes)
        pbDisposeMoveDetails
        pbPlayCursorSE()
        infoscene = Scene_BossDex_Battle.new
        pbCheckPokegearScene(infoscene, bossnotes)
      end
      if showFieldNotes && canCheckFieldApp?(fieldnotes)
        pbDisposeMoveDetails
        pbPlayCursorSE()
        infoscene = Scene_FieldNotes_Battle.new
        pbCheckPokegearScene(infoscene, fieldnotes)
      end
    end
  end

  # To be overwritten per game
  def checkKeyPressesFight; end

  def pbFightMenuDX(index)
    pbShowWindow(FIGHTBOXDX)
    cw = @sprites["fightwindowdx"]
    battler = @battle.battlers[index]
    cw.battler = battler
    lastIndex = @lastmove[index]
    if battler.moves[lastIndex]
      cw.setIndex(lastIndex)
    else
      cw.setIndex(0)
    end
    cw.specialButton = 1
    pbSelectBattler(index)
    pbRefresh
    @showingMoveDetails = pbDrawSpecialMoveDetails(battler, cw.index, false, specialmove: cw.specialButton == 1)
    update_menu = true
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw, update_menu)
      update_menu = false
      # Update selected command
      if Input.trigger?(Input::LEFT) && cw.index > 0
        pbPlayCursorSE() if cw.setIndex(cw.index - 1)
        @showingMoveDetails = pbDrawSpecialMoveDetails(battler, cw.index, false, specialmove: cw.specialButton == 1) if @showingMoveDetails
        update_menu = true
      elsif Input.trigger?(Input::RIGHT) && cw.index < battler.specialmoves.length
        pbPlayCursorSE() if cw.setIndex(cw.index + 1)
        @showingMoveDetails = pbDrawSpecialMoveDetails(battler, cw.index, false, specialmove: cw.specialButton == 1) if @showingMoveDetails
        update_menu = true
      elsif Input.trigger?(Input::L) # Show Battle Stats feature made by DemICE, Trainer Pokemon
        pbDisposeMoveDetails
        pbShowBattleStats(index)
      elsif Input.trigger?(Input::R) # Show Battle Stats feature made by DemICE, Opponent Pokemon
        pbDisposeMoveDetails
        pbShowBattleStats(index ^ 1)
      elsif Input.trigger?(Input::A)
        @showingMoveDetails ? (pbDisposeMoveDetails; @showingMoveDetails = false) : pbDrawSpecialMoveDetails(battler, cw.index, false, specialmove: cw.specialButton == 1)

        pbPlayCursorSE()
        update_menu = true
      elsif Input.trigger?(Input::C) # Confirm choice
        pbDisposeMoveDetails
        ret = cw.index
        pbPlayDecisionSE()
        @lastmove[index] = ret
        return ret
      elsif Input.trigger?(Input::B)   # Cancel fight menu
        pbDisposeMoveDetails
        @lastmove[index] = cw.index
        pbPlayCancelSE()
        return -1
      else
        checkKeyPressesFightDx()
      end
    end
  end

  # To be overwritten per game
  def checkKeyPressesFightDx; end

  def ttsStatStages
    strings = []
    for battler in @battle.battlers
      next unless battler.stages.any? { |stage| stage != 0 }

      string = battler.stages.map.with_index { |stage, stat|
        stage == 0 ? nil : sprintf("%+d %s", stage, getStatName(stat, :full))
      }.compact.join(", ")

      strings.push(battler.ttsname + ": " + string)
    end
    strings.push(_INTL("No stat stage changes present.")) if strings.empty?
    tts(strings.join(", "), true)
  end

  def ttsMove(battler, moveIndex, zmove, interrupt = true)
    reallyzmove = zmove && battler.pbCompatibleZMoveFromMove?(moveIndex, true)
    move = reallyzmove ? battler.zmoves[moveIndex] : battler.moves[moveIndex]
    name = move.name
    effectivetype = pbMoveBattleSceneType(move, battler)
    secondtype = move.getSecondaryType(battler, effectivetype, placeholders: true)
    secondtypephrase = ""
    ppphrase = ""
    fieldboostphrase = ""
    if secondtype.include?(:RAINBOW)
      secondtypephrase = sprintf(" and a random")
    elsif secondtype.include?(:CRYSTAL)
      secondtypephrase = sprintf(" and a crystal")
    elsif secondtype != [] && !secondtype.include?(effectivetype)
      for i in 0...secondtype.length
        secondtypephrase = secondtypephrase + sprintf(" and %s", getTypeName(secondtype[i]))
      end
    end
    if !zmove
      ppphrase = sprintf(", %d out of %d pp left", move.pp, move.totalpp)
    end
    if pbFieldMoveHighlights(move, battler) == :buff
      fieldboostphrase = ", field-boosted"
    elsif pbFieldMoveHighlights(move, battler) == :nerf
      fieldboostphrase = ", field-diminished"
    end
    tts(sprintf("%s, %s%s type%s%s", name, getTypeName(effectivetype), secondtypephrase, ppphrase, fieldboostphrase), interrupt)
  end

  MoveDetailsDarkColors = [Color.new(248, 248, 248), Color.new(104, 104, 104)]
  MoveDetailsLightColors = [Color.new(64, 64, 64), Color.new(176, 176, 176)]
  MoveDetailsBoostedColors = LightColorArrays[:Green2]
  MoveDetailsLoweredColors = LightColorArrays[:Red]
  MoveCatPos = Rejuv ? 26 : 28

  def pbDrawMoveDetails(battler, moveIndex, zmove)
    pbDisposeMoveDetails # Dispose previous graphic before drawing new one

    @mdviewport = Viewport.new(0, 134, Graphics.width, Graphics.height - 96)
    @mdviewport.z = 999999
    background = IconSprite.new(0, 0, @mdviewport)
    background.setBitmap("Graphics/Pictures/Battle/battleMoveDetails")
    overlaysprite = BitmapSprite.new(Graphics.width, Graphics.height - 230, @mdviewport)
    overlay = overlaysprite.bitmap

    reallyzmove = zmove && battler.pbCompatibleZMoveFromMove?(moveIndex, true)
    move = reallyzmove ? battler.zmoves[moveIndex] : battler.moves[moveIndex]

    # Flags
    flags = notableMoveFlags(move.move).join(", ")
    textpos = [[flags, 506, 128, :right, Color.new(126, 133, 140)]]
    pbSetSmallFont(overlay)
    pbDrawTextPositions(overlay, textpos)

    # Category
    category = move.betterCategory(battler, move.pbType(battler))
    cattype = { physical: 0, special: 1, status: 2 }[category]
    # Power
    rawbasedamage = move.summaryPower(battler)
    basedamage = rawbasedamage == 0 || rawbasedamage == -1 ? rawbasedamage : move.applyTradePowerForAcc(rawbasedamage, battler, battler.pbFirstOpposing)
    powstring = basedamage <= 1 ? (basedamage == 0 ? "---" : "???") : basedamage.to_s
    powcolors = basedamage > rawbasedamage ? MoveDetailsBoostedColors : (basedamage < rawbasedamage ? MoveDetailsLoweredColors : MoveDetailsLightColors)
    # Accuracy
    rawaccuracy = move.accuracy == 0 ? -1 : move.accuracy # Listed accuracy being 0 corresponds to return value of pbCalcAccuracy being -1
    accuracy = move.pbCalcAccuracy(battler, battler.pbFirstOpposing)
    accuracy = 100 if accuracy != -1 && accuracy < 100 && move.tradePowerForAcc?
    accstring = accuracy == -1 ? "---" : accuracy.to_s
    acccolors = accuracy > rawaccuracy || (accuracy != rawaccuracy && accuracy == -1) ? MoveDetailsBoostedColors : (accuracy < rawaccuracy ? MoveDetailsLoweredColors : MoveDetailsLightColors)
    # Priority
    rawpriority = move.priority
    priority = move.priorityCheck(battler)
    pristring = sprintf("%+d", priority)
    pricolors = priority > rawpriority ? MoveDetailsBoostedColors : (priority < rawpriority ? MoveDetailsLoweredColors : MoveDetailsLightColors)
    # Description
    desc = reallyzmove && move.category == :status && !PBStuff::UniqueStatusZMoves.include?(move.move) ? getStatusZMoveDesc(move.move) : getMoveDesc(move.move)

    textpos = [
      [move.shortname, 8, 26, 0, *MoveDetailsDarkColors],
      [powstring, 332, 26, :center, *powcolors],
      [accstring, 418, 26, :center, *acccolors],
      [pristring, 490, 26, :center, *pricolors],
    ]
    pbSetSystemFont(overlay)
    pbDrawTextPositions(overlay, textpos)
    categoryicon = IconSprite.new(214, MoveCatPos, @mdviewport)
    categoryicon.setBitmap("Graphics/Pictures/category")
    categoryicon.src_rect.set(0, cattype * 28, 64, 28)
    drawTextEx(overlay, 8, 60, Graphics.width - 16, 3, desc, *MoveDetailsLightColors, 30)

    ttsString = ""
    ttsString += move.name + ", "
    ttsString += category.to_s.capitalize + ", "
    ttsString += (basedamage == 1 ? "Unknown" : basedamage.to_s) + " power, " if category != :status
    ttsString += (accuracy == -1 ? "Perfect" : accuracy.to_s) + " accuracy, "
    ttsString += pristring + " priority, "
    ttsString += desc
    ttsString += " Flags: " + flags unless flags.empty?
    tts(ttsString, true)
  end

  def pbDrawSpecialMoveDetails(battler, moveIndex, zmove, specialmove: false)
    newscene = !@showingMoveDetails
    pbDisposeMoveDetails unless newscene # Dispose previous graphic before drawing new one

    reallyzmove = zmove && battler.pbCompatibleZMoveFromMove?(moveIndex, true)
    if specialmove
      move = battler.specialmoves[moveIndex]
    else
      move = reallyzmove ? battler.zmoves[moveIndex] : battler.moves[moveIndex]
    end

    regularStatusZMove = reallyzmove && move.category == :status && !PBStuff::UniqueStatusZMoves.include?(move.move)
    cattype = { :physical => 0, :special => 1, :status => 2 }[move.category]
    powstring = move.basedamage <= 1 ? (move.basedamage == 0 ? "---" : "???") : move.basedamage.to_s
    if battler.battle.sides[0].effects[:SpecialMoves][move.move] == -1
      accstring = sprintf("Used")
    else
      accstring = sprintf("Charge: %d/%d",battler.battle.sides[0].effects[:SpecialMoves][move.move], move.chargetime)
    end
    desc = regularStatusZMove ? getStatusZMoveDesc(move.move) : getMoveDesc(move.move)

    @mdviewport = Viewport.new(0, 134, Graphics.width, Graphics.height - 64)
    @mdviewport.z = 999999
    @sprites["card"] = IconSprite.new(0, 0, @mdviewport)
    if specialmove
      @sprites["card"].setBitmap("Graphics/Pictures/Battle/battleSpecialMoveDetails")
    else
      @sprites["card"].setBitmap("Graphics/Pictures/Battle/battleMoveDetails")
    end



    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height - 164, @mdviewport)
    overlay = @sprites["overlay"].bitmap
    pbSetSystemFont(overlay)

    baseForDarkBG = Reborn ? Color.new(142, 166, 178) : Color.new(248, 248, 248)
    shadowForDarkBG = Reborn ? Color.new(25, 38, 51) : Color.new(104, 104, 104)
    baseForLightBG = Reborn ? baseForDarkBG : Color.new(64, 64, 64)
    shadowForLightBG = Reborn ? shadowForDarkBG : Color.new(176, 176, 176)
    name_y_offset = Reborn ? 6 : 0
    other_y_offset = Reborn ? 2 : 0
    desc_x_offset = Reborn ? 2 : 0
    desc_y_offset = Reborn ? 3 : 0

    @sprites["category"] = IconSprite.new(196, MoveCatPos, @mdviewport)
    @sprites["category"].setBitmap("Graphics/Pictures/category")
    @sprites["category"].src_rect.set(0, cattype * 28, 64, 28)

    @sprites["movetype"] = IconSprite.new(264, MoveCatPos, @mdviewport)
    @sprites["movetype"].setBitmap(sprintf("Graphics/Icons/type%s",move.type))
    @sprites["movetype"].src_rect.set(0, 0, 64, 28)


    textpos = [
      [move.name, 8, 26, 0, baseForDarkBG, shadowForDarkBG],
      [powstring, 334, 26, 0, baseForLightBG, shadowForLightBG],
      [accstring, 376, 26, 0, baseForLightBG, shadowForLightBG]
    ]


      # [move.shortname, 8, 26, 0, *MoveDetailsDarkColors],
      # [powstring, 332, 26, :center, *powcolors],
      # [accstring, 418, 26, :center, *acccolors],
      # [pristring, 490, 26, :center, *pricolors],

    pbDrawTextPositions(overlay, textpos)

    specialMovePoke = battler.battle.pbPokemonFromSpecialParty(move.move, battler)

    @sprites["specialMovePoke"] = IconSprite.new(134, -14, @mdviewport)
    @sprites["specialMovePoke"].bitmap = pbPokemonIconBitmap(specialMovePoke.pokemon)
    @sprites["specialMovePoke"].src_rect.set(0, 0, 64, 64)

    drawTextEx(overlay, 8, 60, Graphics.width - 16, 3, desc, *MoveDetailsLightColors, 30)

    ttsString = ""
    ttsString += (reallyzmove ? getZMoveName(move.move, tts: true) : getMoveName(move.move)) + ", " if newscene
    ttsString += move.category.to_s.capitalize + ", "
    ttsString += (move.basedamage == 1 ? "Unknown" : move.basedamage.to_s) + " power, " if move.category != :status
    ttsString += (move.accuracy == 0 ? "Perfect" : move.accuracy.to_s) + " accuracy, "
    ttsString += desc
    tts(ttsString)

    @showingMoveDetails = true
  end

  def pbDisposeMoveDetails
    return unless showingMoveDetails?
    @mdviewport.dispose
    @mdviewport = nil
  end

  def showingMoveDetails?
    return !@mdviewport.nil?
  end

  def pbFightMenuEncore(index, encored_move)
    pbShowWindow(FIGHTBOX)
    cw = @sprites["fightwindow"]
    battler = @battle.battlers[index]
    cw.battler = battler
    cw.setIndex(encored_move)
    pbFrameUpdate(cw, true)
    Graphics.update
    Input.update
  end

  # Use this method to display the inventory
  # The return value is the item chosen, or 0 if the choice was canceled.
  def pbItemMenu(index)
    ret = nil
    retindex = -1
    endscene = true
    oi = @battle.pbGetOwnerIndex(index)

    visiblesprites = pbTransitionFromBattleScene
    itemscene = PokemonBag_Scene.new
    itemscene.pbStartScene($PokemonBag)

    loop do
      item = itemscene.pbChooseItem
      break if item.nil?

      usetype = $cache.items[item].checkFlag?(:noUseInBattle) ? 0 : pbGetPocket(item)
      cmdUse = -1
      cmdCancel = -1
      commands = []
      commands[cmdUse = commands.length] = _INTL("Use") unless usetype == 0
      commands[cmdCancel = commands.length] = _INTL("Cancel")
      itemname = getItemName(item)
      command = itemscene.pbShowCommands(_INTL("{1} is selected.", itemname), commands)
      if cmdUse >= 0 && command == cmdUse
        if $game_switches[:No_Items_Password] == true && (usetype == 1 || usetype == 2 || usetype == 5)
          itemscene.pbDisplay(_INTL("The 'No Items' password is on, so items can't be used in battle."))
        elsif ItemHandlers.hasBattleUseOnBattler(item)
          # Poke Balls, Poke Doll, Flutes, X items, Dire Hit, Guard Spec
          ret = item
          retindex = @battle.battlers[index].pokemonIndex
          break
        else
          modparty = []
          for i in 0...6
            modparty.push(@battle.party1[oi][@battle.partyorder[oi][i]])
          end
          pkmnlist = PokemonScreen_Scene.new
          pkmnscreen = PokemonScreen.new(pkmnlist, modparty)
          itemscene.pbEndScene
          pkmnscreen.pbStartScene(_INTL("Use on which Pokémon?"))
          activecmd = pkmnscreen.pbChoosePokemon
          pkmnid = @battle.partyorder[oi][activecmd]
          if activecmd != -1 && !pbCanUseBattleItem(oi, pkmnid, item, pkmnscreen)
          else
            if activecmd >= 0 && pkmnid >= 0 && ItemHandlers.hasBattleUseOnPokemon(item)
              pkmnlist.pbEndScene
              ret = item
              retindex = pkmnid
              endscene = false
              break
            end
          end
          pkmnlist.pbEndScene
          itemscene.pbStartScene($PokemonBag)
        end
      end
    end
    $PokemonBag.pbDeleteItem(ret) if ret && !ItemHandlers.hasUseInBattle(ret) # Poke Balls, Poke Doll, Flutes

    itemscene.pbEndScene if endscene
    pbTransitionToBattleScene(visiblesprites)

    return [ret, retindex]
  end

  # Tests whether or not the battle item will have any effect
  def pbCanUseBattleItem(ownerIndex, pkmnid, item, pkmnscreen)
    pokemon = @battle.party1[ownerIndex][pkmnid]
    battler = false
    for i in @battle.battlers
      moncheck = i.pokemon
      if pokemon == moncheck
        battler = i
      end
    end
    if battler && (battler.effects[:Commander] || battler.effects[:SkyDrop] || battler.effects[:Embargo] > 0)
      return false
    end
    return true if pokemon.hp > 0 && pokemon.hp < pokemon.totalhp && $cache.items[item].medicine&.hp
    return true if pokemon.hp > 0 && !pokemon.status.nil? && [pokemon.status, :FULLHEAL].include?($cache.items[item].medicine&.status)
    return true if battler && battler.effects[:Confusion] > 0 && (item == :PERSIMBERRY || $cache.items[item].medicine&.status == :FULLHEAL)
    return true if pokemon.hp <= 0 && $cache.items[item].medicine&.revive && item != :SACREDASH
    return true if battler && battler.effects[:Attract] >= 0 && PBStuff::INFATUATIONITEMS.include?(item)
    return true if pokemon.happiness < 255 && [:POKESNAX, :GOURMETTREAT].include?(item)

    if PBStuff::PPITEMS.include?(item)
      ppcheck = false
      movecheck = false
      for i in pokemon.moves
        next if i.pp == i.totalpp

        movecheck = true
        break
      end
      if movecheck
        if [:ETHER, :LEPPABERRY, :MAGICMOOMILK].include?(item)
          move = pbChooseMove(pokemon, _INTL("Restore which move?"))
          if move >= 0
            if pbBattleRestorePP(pokemon, battler, move, 10) == 0
              ppcheck = false
              pkmnscreen.pbDisplay(_INTL("It won't have any effect."))
            else
              return true # ppcheck=true
            end
          else
            ppcheck = false
          end
        elsif item == :MAXETHER
          move = pbChooseMove(pokemon, _INTL("Restore which move?"))
          if move >= 0
            if pbBattleRestorePP(pokemon, battler, move, pokemon.moves[move].totalpp - pokemon.moves[move].pp) == 0
              ppcheck = false
              pkmnscreen.pbDisplay(_INTL("It won't have any effect."))
            else
              return true # ppcheck=true
            end
          else
            ppcheck = false
          end
        else
          ppcheck = true
        end
      else
        pkmnscreen.pbDisplay(_INTL("It won't have any effect."))
      end
      return ppcheck
    end
    pkmnscreen.pbDisplay(_INTL("It won't have any effect."))
    return false
  end

  # Called whenever a Pokémon should forget a move.  It should return -1 if the
  # selection is canceled, or 0 to 3 to indicate the move to forget.  The function
  # should not allow HM moves to be forgotten.
  def pbForgetMove(pokemon, moveToLearn)
    ret = -1
    pbFadeOutIn(99999) {
      scene = PokemonSummaryScene.new
      screen = PokemonSummary.new(scene)
      ret = screen.pbStartForgetScreen([pokemon], 0, moveToLearn)
    }
    return ret
  end

  # Called whenever a Pokémon needs one of its moves chosen. Used for Ether.
  def pbChooseMove(pokemon, message)
    ret = -1
    pbFadeOutIn(99999) {
      scene = PokemonSummaryScene.new
      screen = PokemonSummary.new(scene)
      ret = screen.pbStartChooseMoveScreen([pokemon], 0, message)
    }
    return ret
  end

  def pbNameEntry(helptext, pokemon)
    return pbEnterPokemonName(helptext, 0, 12, "", pokemon)
  end

  def pbSelectBattler(index, selectmode = 1)
    numwindows = @battle.doublebattle ? 4 : 2
    for i in 0...numwindows
      sprite = @sprites["battlebox#{i}"]
      next if !sprite

      sprite.selected = (i == index) ? selectmode : 0
      sprite = @sprites["pokemon#{i}"]
      next if !sprite

      sprite.selected = (i == index) ? selectmode : 0
    end
  end

  def pbFirstTarget(index)
    for i in 0...4
      if i != index && !@battle.battlers[i].isFainted? &&
        @battle.battlers[index].pbIsOpposing?(i)
        if @battle.battlers[i].effects[:Commander] == true
          return @battle.battlers[i].pbPartner.index
        else
          return i
        end
      end
    end
    return -1
  end

  def pbAcupressureTarget(index)
    for i in 0...4
      if (index & 1) == (i & 1) && !@battle.battlers[i].isFainted?
        !@battle.battlers[index].pbIsOpposing?(i)
        return i
      end
    end
    return -1
  end

  def pbUpdateSelected(index)
    numwindows = @battle.doublebattle ? 4 : 2
    for i in 0...numwindows
      next if !@sprites["battlebox#{i}"]
      next if !@sprites["pokemon#{i}"]

      if i == index
        @sprites["battlebox#{i}"].selected = 2
        @sprites["pokemon#{i}"].selected = 2
      else
        @sprites["battlebox#{i}"].selected = 0
        @sprites["pokemon#{i}"].selected = 0
      end
      @sprites["battlebox#{i}"].update
      @sprites["pokemon#{i}"].update
    end
  end

  # Use this method to make the player choose a target
  # for certain moves in double battles.
  def pbChooseTarget(index, special: false)
    window = special ? pbShowWindow(FIGHTBOXDX) : pbShowWindow(FIGHTBOX)
    curwindow = pbFirstTarget(index)
    if curwindow == -1
      raise RuntimeError.new(_INTL("No targets somehow..."))
    end
    tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted?

    loop do
      pbGraphicsUpdate
      Input.update
      pbUpdateSelected(curwindow)
      if Input.trigger?(Input::C)
        pbUpdateSelected(-1)
        return curwindow
      end
      if Input.trigger?(Input::B)
        pbUpdateSelected(-1)
        return -1
      end
      if curwindow >= 0
        if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::DOWN)
          loop do
            newcurwindow = 3 if curwindow == 0
            newcurwindow = 1 if curwindow == 3
            newcurwindow = 2 if curwindow == 1
            newcurwindow = 0 if curwindow == 2
            curwindow = newcurwindow
            next if curwindow == index
            break if !@battle.battlers[curwindow].isFainted?
          end
          tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted?
        elsif Input.trigger?(Input::LEFT) || Input.trigger?(Input::UP)
          loop do
            newcurwindow = 2 if curwindow == 0
            newcurwindow = 1 if curwindow == 2
            newcurwindow = 3 if curwindow == 1
            newcurwindow = 0 if curwindow == 3
            curwindow = newcurwindow
            next if curwindow == index
            break if !@battle.battlers[curwindow].isFainted?
          end
          tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted?
        end
      end
    end
  end

  def pbChooseTargetOneSide(index, target, special: false)
    window = special ? pbShowWindow(FIGHTBOXDX) : pbShowWindow(FIGHTBOX)
    curwindow = target == :SingleOpposing ? pbFirstTarget(index) : pbAcupressureTarget(index)
    if curwindow == -1
      raise RuntimeError.new(_INTL("No targets somehow..."))
    end
    tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted?

    loop do
      pbGraphicsUpdate
      Input.update
      pbUpdateSelected(curwindow)
      if Input.trigger?(Input::C)
        pbUpdateSelected(-1)
        return curwindow
      end
      if Input.trigger?(Input::B)
        pbUpdateSelected(-1)
        return -1
      end
      if curwindow >= 0
        if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::DOWN)
          loop do
            newcurwindow = 2 if curwindow == 0
            newcurwindow = 1 if curwindow == 3
            newcurwindow = 3 if curwindow == 1
            newcurwindow = 0 if curwindow == 2
            curwindow = newcurwindow
            break if !@battle.battlers[curwindow].isFainted?
          end
          tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted?
        elsif Input.trigger?(Input::LEFT) || Input.trigger?(Input::UP)
          loop do
            newcurwindow = 2 if curwindow == 0
            newcurwindow = 0 if curwindow == 2
            newcurwindow = 3 if curwindow == 1
            newcurwindow = 1 if curwindow == 3
            curwindow = newcurwindow
            break if !@battle.battlers[curwindow].isFainted?
          end
          tts(@battle.battlers[curwindow].name, true) if !@battle.battlers[curwindow].isFainted?
        end
      end
    end
  end

  def pbChooseBallTarget(index)
    curwindow = (0...4).find { |i|
      @battle.battlers[index].pbIsOpposing?(i) &&
      !@battle.battlers[i].isFainted? &&
      !@battle.battlers[i].isSemiInvul?
    }
    if curwindow.nil?
      raise RuntimeError.new(_INTL("No targets somehow..."))
    end
    if @battle.battlers[curwindow ^ 2].isFainted? || @battle.battlers[curwindow ^ 2].isSemiInvul?
      return curwindow
    end

    tts(@battle.battlers[curwindow].name, true)
    loop do
      pbGraphicsUpdate
      Input.update
      pbUpdateSelected(curwindow)
      if Input.trigger?(Input::B)
        return -1
      end
      if Input.trigger?(Input::C)
        pbUpdateSelected(-1)
        return curwindow
      end
      if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::DOWN) || Input.trigger?(Input::LEFT) || Input.trigger?(Input::UP)
        curwindow ^= 2
        tts(@battle.battlers[curwindow].name, true)
      end
    end
  end

  def pbSwitchPlayer(indices, lax, cancancel)
    party = @battle.pbPartySingleOwner(indices.first)
    partyorder = @battle.partyorder[@battle.pbGetOwnerIndex(indices.first)]
    modparty = (0...6).map { |i| party[partyorder[i]] }
    doublereplace = indices.length > 1 && @battle.pbCanChooseNonActiveCount(indices.first) > 1 # Two fainted battlers AND more than one remaining pokemon
    helptext = doublereplace ? _INTL("Choose a Pokémon for Left slot.") : _INTL("Choose a Pokémon.")

    visiblesprites = pbTransitionFromBattleScene
    scene = PokemonScreen_Scene.new
    @switchscreen = PokemonScreen.new(scene, modparty)
    @switchscreen.pbStartScene(helptext)

    switchhash = {}
    loop do
      ret = -1
      index = indices.first
      loop do
        if doublereplace
          helptext = switchhash.empty? ? _INTL("Choose a Pokémon for Left slot.") : _INTL("Choose a Pokémon for Right slot.")
        end
        scene.pbSetHelpText(helptext)
        activecmd = @switchscreen.pbChoosePokemon(shortcut_keys: true)
        # Cancel
        if activecmd == -1
          if cancancel # Switch cancelled
            ret = -1
            break
          end
          if switchhash.any? # Second pokemon choice cancelled
            indices.push(switchhash.keys.first)
            indices.sort!
            switchhash.clear
          end
          next
        end
        # Summary shortcut
        if activecmd.is_a?(Array) && activecmd[0] == 3
          scene.pbSummary(activecmd[1])
          next
        end
        # Pokemon chosen
        if activecmd >= 0 && !party[partyorder[activecmd]].nil?
          commands = []
          cmdShift = -1
          cmdSummary = -1
          pkmnindex = partyorder[activecmd]
          commands[cmdShift = commands.length] = _INTL("Switch In") unless party[pkmnindex].isEgg?
          commands[cmdSummary = commands.length] = _INTL("Summary")
          commands[commands.length] = _INTL("Cancel")
          command = scene.pbShowCommands(_INTL("Do what with {1}?", party[pkmnindex].name), commands)
          # Switch In
          if cmdShift >= 0 && command == cmdShift
            # If the pokemon has already been selected for the other slot
            if switchhash.values.include?(pkmnindex)
              scene.pbDisplay(_INTL("This Pokémon has already been selected!"))
              next
            end
            # If the pokemon can't be switched in
            next unless lax ? @battle.pbCanSwitchLax?(index, pkmnindex, showMessage: true) : @battle.pbCanSwitch?(index, pkmnindex, showMessage: true)
            # Specify which slot in case of two fainted battlers AND only one remaining pokemon
            if indices.length > 1 && @battle.pbCanChooseNonActiveCount(indices.first) <= 1
              positions = { 0 => _INTL("Left"), 1 => _INTL("Left"), 2 => _INTL("Right"), 3 => _INTL("Right") }
              commands = indices.map { |i| positions[i] }
              cmd = scene.pbShowCommands(_INTL("Which position should {1} be placed in?", party[pkmnindex].name), commands)
              next if cmd == -1
              index = indices[cmd]
            end
            # Register
            ret = pkmnindex
            break
          end
          # Summary
          if cmdSummary >= 0 && command == cmdSummary
            scene.pbSummary(activecmd)
            next
          end
          # Cancel
          if command == commands.length - 1
            next
          end
        end
      end
      switchhash[index] = ret
      indices.delete(index)
      break if ret == -1
      break if indices.empty?
      break if !@battle.pbCanChooseNonActive?(indices.first, exclude: ret)
      # The party will always have at least one choosable member if this method is being called, so this break condition can only apply for the second selection, hence placed at bottom
    end

    @switchscreen.pbEndScene
    @switchscreen = nil
    pbTransitionToBattleScene(visiblesprites)

    return switchhash
  end

  def pbDamageAnimation(mons, effectiveness, quick: false)
    return if mons == []

    mons = Array(mons)

    @briefmessage = false
    (quick ? 0 : 6).times do
      pbGraphicsUpdate
      Input.update
    end

    $Settings.audiotype = 0 if !$Settings.audiotype
    if $Settings.audiotype != 0 || mons.length > 1
      case effectiveness
        when 0 then pbSEPlay("normaldamage")
        when 1 then pbSEPlay("notverydamage")
        when 2 then pbSEPlay("superdamage")
      end
    else
      pkmn = mons[0]
      case effectiveness
        when 0 then @battle.pbIsOpposing?(pkmn.index) ? pbSEPlay("normaldamage_R") : pbSEPlay("normaldamage_L")
        when 1 then @battle.pbIsOpposing?(pkmn.index) ? pbSEPlay("notverydamage_R") : pbSEPlay("notverydamage_L")
        when 2 then @battle.pbIsOpposing?(pkmn.index) ? pbSEPlay("superdamage_R") : pbSEPlay("superdamage_L")
      end
    end

    blinksprites = []
    sprites = []
    mons.each do |pkmn|
      pkmnsprite = @sprites["pokemon#{pkmn.index}"]
      shadowsprite = @sprites["shadow#{pkmn.index}"]
      sprite = @sprites["battlebox#{pkmn.index}"]
      sprite.selected = 2
      sprites.push [sprite, sprite.visible]
      blinksprites.push pkmnsprite
      blinksprites.push shadowsprite if shadowsprite.visible
    end

    8.times do
      blinksprites.each { |s| s.visible = !s.visible }
      4.times do
        pbGraphicsUpdate
        Input.update
        sprites.each { |pair| pair[0].update }
      end
    end

    sprites.each do |pair|
      sprite, oldvisible = pair
      sprite.selected = 0
      sprite.visible = oldvisible
    end
  end

  # This method is called whenever a Pokémon's HP changes.
  # Used to animate the HP bar.
  def pbHPChanged(mons, oldhps, anim = false)
    raise "array length mismatch" if mons.length != oldhps.length
    @briefmessage = false
    sprites = []
    should_alert_low_hp = []
    mons.each_with_index do |pkmn, i|
      oldhp = oldhps[i]
      hpchange = pkmn.hp - oldhp

      unless hpchange == 0
        if hpchange < 0
          hpchange = -hpchange
          logmsg = "[#{pkmn.pbThis} lost #{hpchange} HP, now has #{pkmn.hp} HP]"
          logmsg2 = _INTL("{1} lost {2} HP")
        else
          logmsg = "[#{pkmn.pbThis} gained #{hpchange} HP, now has #{pkmn.hp} HP]"
          logmsg2 = _INTL("{1} gained {2} HP")
        end
        PBDebug.log(logmsg)
        hpstring = ((hpchange / pkmn.totalhp.to_f * 100).round(1)).to_s + "%"
        hpstring += " (" + hpchange.to_s + ")" if @battle.pbOwnedByPlayer?(pkmn.index)
        logmsg2 = "[" + _INTL(logmsg2, pkmn.pbThis, hpstring) + "]"
        addToBattleLog(logmsg2, color: :hp)
      end

      if anim && @battle.battlescene
        if pkmn.hp > oldhp
          pbCommonAnimation("HealthUp", pkmn, nil)
        elsif pkmn.hp < oldhp
          pbCommonAnimation("HealthDown", pkmn, nil)
        end
      end
      if $game_switches[:Blindstep] && @battle.pbOwnedByPlayer?(pkmn.index) && pkmn.hp > 0 && pkmn.hp < oldhp
        threshold = (pkmn.totalhp / 4.0).floor
        if pkmn.hp <= threshold
          should_alert_low_hp.push pkmn.index
        end
      end
      sprite = @sprites["battlebox#{pkmn.index}"]
      sprite.animateHP(oldhp, pkmn.hp)
      sprites.push sprite
    end

    while sprites.any? { |sprite| sprite.animatingHP }
      pbFrameUpdate(nil)
      pbGraphicsUpdate
      Input.update
      sprites.each { |sprite| sprite.update }
    end

    if should_alert_low_hp != []
      if @battle.doublebattle && should_alert_low_hp.length == 1
        pbAccessibilitySEPlay("Blindstep- LowHP", x: should_alert_low_hp == [0] ? -1 : 1)
      else
        pbAccessibilitySEPlay("Blindstep- LowHP")
      end
    end
  end

  # This method is called whenever a Pokémon faints.
  def pbFainted(pkmn)
    # frames=pbCryFrameLength(pkmn.pokemon)
    if pkmn.pokemon && !pkmn.pokemon.unusable
      pbPlayCry(pkmn.pokemon)
    end
    # frames.times do
    #  pbGraphicsUpdate
    #  Input.update
    # end
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
      Input.update
      break if pkmnsprite.y >= ycoord
    end
    pkmnsprite.visible = false
    pkmnsprite.src_rect.height = heightsave
    8.times do
      @sprites["battlebox#{pkmn.index}"].opacity -= 32
      pbGraphicsUpdate
      Input.update
    end
    @sprites["battlebox#{pkmn.index}"].visible = false
    pkmn.pbResetForm
  end

  def pbVanishSprite(pkmn)
    pkmn.vanished = true
    pkmnsprite = @sprites["pokemon#{pkmn.index}"]
    pkmnsprite.opacity -= 1000
    pbGraphicsUpdate
    Input.update
  end

  def pbUnVanishSprite(pkmn, fade = true)
    pkmn.vanished = false
    @battle.pbCommonAnimation("Fade in", pkmn, nil) if fade
    pkmnsprite = @sprites["pokemon#{pkmn.index}"]
    pkmnsprite.opacity += 1000
    shadowsprite = @sprites["shadow#{pkmn.index}"]
    shadowsprite.visible = true if showShadow?(pkmn.getCacheData)
    pbGraphicsUpdate
    Input.update
  end

  def pbSyncronousVanish(array)
    return if !array || array.length == 0

    10.times do
      array.each { |pkmn| @sprites["pokemon#{pkmn.index}"].opacity -= 30 }
      pbGraphicsUpdate
      Input.update
    end
  end

  def pbSyncronousUnvanish(array)
    return if !array || array.length == 0

    10.times do
      array.each { |pkmn| @sprites["pokemon#{pkmn.index}"].opacity += 30 }
      pbGraphicsUpdate
      Input.update
    end
  end

  def pbSubstituteSprite(pkmn)
    pkmnsprite = @sprites["pokemon#{pkmn.index}"]
    pkmnsprite.setPokemonBitmap("substitute", pkmn.pbIsOpposing?(1))
    if pkmn.index.odd?
      shadowsprite = @sprites["shadow#{pkmn.index}"]
      shadowsprite.setPokemonShadowBitmap("substitute")
    end
    pbPositionSubstitute(pkmn.index)
    pkmnsprite.opacity += 1000
  end

  def pbUnSubstituteSprite(pkmn)
    pkmnsprite = @sprites["pokemon#{pkmn.index}"]
    pbChangePokemon(pkmn, pkmn.visiblePokemon)
    pkmnsprite.opacity += 1000
  end

  def pbPositionSubstitute(index)
    pkmnsprite = @sprites["pokemon#{index}"]
    x, y = pbGetBattleCoords(index)
    pkmnsprite.x = x
    pkmnsprite.x -= pkmnsprite.width / 2
    pkmnsprite.x += index.even? ? -4 : 2 # X adjustment
    pkmnsprite.y = y
    pkmnsprite.y -= pkmnsprite.height / 2
    pkmnsprite.y += index.even? ? -32 : -20 # Y adjustment

    if index.odd?
      shadowsprite = @sprites["shadow#{index}"]
      shadowsprite.x = x
      shadowsprite.x -= shadowsprite.bitmap.width / 2
      shadowsprite.y = y
      shadowsprite.y -= shadowsprite.bitmap.height / 2
    end
  end

  # This method is called when the player wins a wild Pokémon battle.
  # This method can change the battle's music for example.
  def pbWildBattleSuccess
    pbBGMPlay(pbGetWildVictoryBGM())
  end

  # This method is called when the player wins a Trainer battle.
  # This method can change the battle's music for example.
  def pbTrainerBattleSuccess
    pbBGMPlay(pbGetTrainerVictoryBGM(@battle.opponent)) if !$game_switches[:NoVictoryFanfare]
  end

  def pbEXPBar(pokemon, battler, startexp, endexp, tempexp1, tempexp2)
    return unless battler

    @sprites["battlebox#{battler.index}"].refreshExpLevel
    exprange = (endexp - startexp)
    startexplevel = 0
    endexplevel = 0
    if exprange != 0
      startexplevel = (tempexp1 - startexp) * PBScene::EXPGAUGESIZE / exprange
      endexplevel = (tempexp2 - startexp) * PBScene::EXPGAUGESIZE / exprange
    end
    @sprites["battlebox#{battler.index}"].animateEXP(startexplevel, endexplevel)
    while @sprites["battlebox#{battler.index}"].animatingEXP
      pbGraphicsUpdate
      Input.update
      @sprites["battlebox#{battler.index}"].update
    end
  end

  def pbShowPokedex(species, form, gender)
    pbFadeOutIn(99999) {
      scene = PokemonPokedexScene.new
      screen = PokemonPokedex.new(scene)
      screen.pbBattleDexEntry(species, form, gender)
    }
  end

  def pbChangePokemon(attacker, pokemon)
    return if attacker.effects[:Substitute] > 0

    pkmn = @sprites["pokemon#{attacker.index}"]
    shadow = @sprites["shadow#{attacker.index}"]
    back = !@battle.pbIsOpposing?(attacker.index)
    pkmn.setPokemonBitmap(pokemon, back)
    spritex, spritey = pbGetBattleCoords(attacker.index)
    pkmn.x = spritex
    pkmn.y = spritey
    xoffset, yoffset = adjustBattleSprite(pkmn, pokemon.getCacheData, attacker.index)
    pkmn.x += xoffset
    pkmn.y += yoffset
    if shadow && !back
      shadow.setPokemonShadowBitmap(pokemon.getCacheData)
      shadow.x = spritex + adjustShadowSpriteX(shadow, pokemon.getCacheData)
      shadow.y = spritey - shadow.bitmap.height / 2
    end
  end

  def pbGetBattleCoords(index)
    lopsided = @battle.allMons(@battle.party2).length == 1
    if @battle.doublebattle
      case index
        when 0
          spritex = @battle.sosbattle == :singlePokemonPlayerSide ? PBScene::PLAYERBATTLER_X : PBScene::PLAYERBATTLERD1_X
          spritey = PBScene::PLAYERBATTLERD1_Y
        when 1
          spritex = lopsided ? PBScene::FOEBATTLER_X : PBScene::FOEBATTLERD1_X
          spritey = lopsided ? PBScene::FOEBATTLER_Y : PBScene::FOEBATTLERD1_Y
        when 2
          spritex = PBScene::PLAYERBATTLERD2_X
          spritey = PBScene::PLAYERBATTLERD2_Y
        when 3
          spritex = PBScene::FOEBATTLERD2_X
          spritey = PBScene::FOEBATTLERD2_Y
      end
    else
      case index
        when 0
          spritex = PBScene::PLAYERBATTLER_X
          spritey = PBScene::PLAYERBATTLER_Y
        when 1
          spritex = PBScene::FOEBATTLER_X
          spritey = PBScene::FOEBATTLER_Y
      end
    end
    return spritex, spritey
  end

  def pbSaveShadows
    shadows = []
    for i in 0...4
      s = @sprites["shadow#{i}"]
      shadows[i] = s ? s.visible : false
      s.visible = false if s
    end
    yield
    for i in 0...4
      s = @sprites["shadow#{i}"]
      s.visible = shadows[i] if s
    end
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
      return [anim + hitnum, noflip] if move == :BONEMERANG
      return [anim, noflip] if anim

      anim = $cache.move2anim[0].fetch(:TACKLE)
      return [anim, false] if anim
    rescue
      return nil
    end
    return nil
  end

  def pbCommonAnimation(animname, user = nil, target = nil, hitnum = 0)
    return unless @battle.battlescene
    unless defined?(user.vanished).nil?
      return if user.vanished
    end
    unless defined?(target.vanished).nil?
      return if target.vanished
    end
    $cache.animations = load_data("Data/battleanims.dat") if !$cache.animations
    animation = $cache.animations.find { |i| i && i.name == "Common:" + animname }
    if user && @battle.pbIsOpposing?(user.index)
      oppAnimation = $cache.animations.find { |i| i && i.name == "OppCommon:" + animname }
      animation = oppAnimation if oppAnimation
    end
    pbAnimationCore(animation, user, target != nil ? target : user) unless animation.nil?
  end

  def pbAnimation(move, user, target, hitnum = 0)
    return unless @battle.battlescene || move == :SUBSTITUTE
    return if move.nil?

    if move.is_a? PokeBattle_Move
      move = move.move
    elsif !move.is_a? Symbol
      move = move.upcase.strip.gsub(/[^0-9a-z]/i, '')
    end
    animid = pbFindAnimation(move, user.index, hitnum)
    return if !animid

    anim = animid[0]
    autoopp = user.index.odd?
    $cache.animations = load_data("Data/battleanims.dat") if !$cache.animations
    pbSaveShadows {
      if animid[1] # On opposing side and using OppMove animation
        pbAnimationCore($cache.animations[anim], target, user, move, true)
      else         # On player's side, and/or using Move animation
        pbAnimationCore($cache.animations[anim], user, target, move, autoopp)
      end
    }
  end

  def pbAnimationCore(animation, user, target, move = nil, oppmove = false)
    return if !animation

    @briefmessage = false
    usersprite = user ? @sprites["pokemon#{user.index}"] : nil
    targetsprite = target ? @sprites["pokemon#{target.index}"] : nil
    olduserx = usersprite ? usersprite.x : 0
    oldusery = usersprite ? usersprite.y : 0
    oldtargetx = targetsprite ? targetsprite.x : 0
    oldtargety = targetsprite ? targetsprite.y : 0
    if !targetsprite
      target = user if !target
      animplayer = PBAnimationPlayerX.new(animation, user, target, self, move, oppmove)
      userwidth = !usersprite || !usersprite.bitmap || usersprite.bitmap.disposed? ? 128 : usersprite.bitmap.width
      userheight = !usersprite || !usersprite.bitmap || usersprite.bitmap.disposed? ? 128 : usersprite.bitmap.height
      animplayer.setLineTransform(
        PBScene::FOCUSUSER_X, PBScene::FOCUSUSER_Y,
        PBScene::FOCUSTARGET_X, PBScene::FOCUSTARGET_Y,
        olduserx + (userwidth / 2), oldusery + (userheight / 2),
        olduserx + (userwidth / 2), oldusery + (userheight / 2)
      )
    else
      animplayer = PBAnimationPlayerX.new(animation, user, target, self, move, oppmove)
      userwidth = !usersprite || !usersprite.bitmap || usersprite.bitmap.disposed? ? 128 : usersprite.bitmap.width
      userheight = !usersprite || !usersprite.bitmap || usersprite.bitmap.disposed? ? 128 : usersprite.bitmap.height
      targetwidth = !targetsprite.bitmap || targetsprite.bitmap.disposed? ? 128 : targetsprite.bitmap.width
      targetheight = !targetsprite.bitmap || targetsprite.bitmap.disposed? ? 128 : targetsprite.bitmap.height
      animplayer.setLineTransform(
        PBScene::FOCUSUSER_X, PBScene::FOCUSUSER_Y,
        PBScene::FOCUSTARGET_X, PBScene::FOCUSTARGET_Y,
        olduserx + (userwidth / 2), oldusery + (userheight / 2),
        oldtargetx + (targetwidth / 2), oldtargety + (targetheight / 2)
      )
    end
    animplayer.start
    while animplayer.playing?
      animplayer.update
      pbGraphicsUpdate
      Input.update
    end
    pbSyncronousUnvanish(animplayer.hide_partners)
    usersprite.ox = 0 if usersprite
    usersprite.oy = 0 if usersprite
    usersprite.x = olduserx if usersprite
    usersprite.y = oldusery if usersprite
    targetsprite.ox = 0 if targetsprite
    targetsprite.oy = 0 if targetsprite
    targetsprite.x = oldtargetx if targetsprite
    targetsprite.y = oldtargety if targetsprite
    if animplayer.targetSwitch
      animplayer.realtargetsprite.x = animplayer.realtargetOldCoords[0]
      animplayer.realtargetsprite.y = animplayer.realtargetOldCoords[1]
      animplayer.realtargetsprite.ox = animplayer.realtargetOldCoords[2]
      animplayer.realtargetsprite.oy = animplayer.realtargetOldCoords[3]
    end
    if animplayer.partnerbs
      animplayer.animpartner.x = animplayer.partnerOldCoords[0]
      animplayer.animpartner.y = animplayer.partnerOldCoords[1]
      animplayer.animpartner.ox = animplayer.partnerOldCoords[2]
      animplayer.animpartner.oy = animplayer.partnerOldCoords[3]
    end
    if animplayer.allmonbs
      animplayer.target1sprite.x = animplayer.target1OldCoords[0]
      animplayer.target1sprite.y = animplayer.target1OldCoords[1]
      animplayer.target1sprite.ox = animplayer.target1OldCoords[2]
      animplayer.target1sprite.oy = animplayer.target1OldCoords[3]
      if animplayer.target2sprite
        animplayer.target2sprite.x = animplayer.target2OldCoords[0]
        animplayer.target2sprite.y = animplayer.target2OldCoords[1]
        animplayer.target2sprite.ox = animplayer.target2OldCoords[2]
        animplayer.target2sprite.oy = animplayer.target2OldCoords[3]
      end
    end
    animplayer.dispose
  end

  def pbThrowAndDeflect(ball, targetBattler)
    @briefmessage = false
    ball = sprintf("Graphics/Pictures/Battle/%s", ball.to_s)
    # sprite
    spriteBall = IconSprite.new(0, 0, @viewport)
    spriteBall.visible = false
    # picture
    pictureBall = PictureEx.new(@sprites["pokemon#{targetBattler}"].z + 1)
    center = getSpriteCenter(@sprites["pokemon#{targetBattler}"])
    ballcenterx = getBallCenterX(targetBattler, @battle)
    # starting positions
    pictureBall.moveVisible(1, true)
    pictureBall.moveName(1, ball)
    pictureBall.moveOrigin(1, PictureOrigin::Center)
    pictureBall.moveXY(0, 1, 10, 180)
    # directives
    pictureBall.moveSE(1, "Audio/SE/throw")
    pictureBall.moveCurve(30, 1, 150, 70, 30 + Graphics.width / 2, 10, ballcenterx, center[1])
    pictureBall.moveAngle(30, 1, -1080)
    pictureBall.moveAngle(0, pictureBall.totalDuration, 0)
    delay = pictureBall.totalDuration
    pictureBall.moveSE(delay, "Audio/SE/balldrop")
    pictureBall.moveXY(20, delay, 0, Graphics.height)
    loop do
      pictureBall.update
      setPictureIconSprite(spriteBall, pictureBall)
      pbGraphicsUpdate
      Input.update
      break if !pictureBall.running?
    end
    spriteBall.dispose
  end

  def pbThrow(ball, shakes, critical, critsuccess, targetBattler, showplayer = false)
    @briefmessage = false
    burst = -1
    $cache.animations = load_data("Data/battleanims.dat") if !$cache.animations
    for i in 0...2
      t = i == 0 ? ball : 0
      for j in 0...$cache.animations.length
        if $cache.animations[j]
          if $cache.animations[j].name == "Common:BallBurst#{t}"
            burst = t if burst < 0
            break
          end
        end
      end
      break if burst >= 0
    end
    pokeballThrow(ball, shakes, critical, critsuccess, targetBattler, self, @battle.battlers[targetBattler], burst, showplayer)
  end

  def pbThrowSuccess
    if !@battle.opponent
      @briefmessage = false
      #      pbMEPlay("Jingle - HMTM")
      #      120.times do
      pbGraphicsUpdate
      Input.update
    end
  end

  def pbThrowBait
    ball = sprintf("Graphics/Pictures/Battle/battleBait")
    armanim = false
    if @sprites["player"].bitmap.width > @sprites["player"].bitmap.height
      armanim = true
    end
    # sprites
    spritePoke = @sprites["pokemon1"]
    spritePlayer = @sprites["player"]
    spriteBall = IconSprite.new(0, 0, @viewport)
    spriteBall.visible = false
    # pictures
    pictureBall = PictureEx.new(spritePoke.z + 1)
    picturePoke = PictureEx.new(spritePoke.z)
    picturePlayer = PictureEx.new(spritePoke.z + 2)
    pokecenter = getSpriteCenter(@sprites["pokemon1"])
    playerpos = [@sprites["player"].x, @sprites["player"].y]
    # starting positions
    pictureBall.moveVisible(1, true)
    pictureBall.moveName(1, ball)
    pictureBall.moveOrigin(1, PictureOrigin::Center)
    pictureBall.moveXY(0, 1, 64, 256)
    picturePoke.moveVisible(1, true)
    picturePoke.moveOrigin(1, PictureOrigin::Center)
    picturePoke.moveXY(0, 1, pokecenter[0], pokecenter[1])
    picturePlayer.moveVisible(1, true)
    picturePlayer.moveName(1, @sprites["player"].name)
    picturePlayer.moveOrigin(1, PictureOrigin::TopLeft)
    picturePlayer.moveXY(0, 1, playerpos[0], playerpos[1])
    # directives
    picturePoke.moveSE(1, "Audio/SE/throw")
    pictureBall.moveCurve(30, 1, 64, 256, Graphics.width / 2, 48, PBScene::FOEBATTLER_X - 48, PBScene::FOEBATTLER_Y)
    pictureBall.moveAngle(30, 1, -720)
    pictureBall.moveAngle(0, pictureBall.totalDuration, 0)
    if armanim
      picturePlayer.moveSrc(1, @sprites["player"].bitmap.height, 0)
      picturePlayer.moveXY(0, 1, playerpos[0] - 14, playerpos[1])
      picturePlayer.moveSrc(4, @sprites["player"].bitmap.height * 2, 0)
      picturePlayer.moveXY(0, 4, playerpos[0] - 12, playerpos[1])
      picturePlayer.moveSrc(8, @sprites["player"].bitmap.height * 3, 0)
      picturePlayer.moveXY(0, 8, playerpos[0] + 20, playerpos[1])
      picturePlayer.moveSrc(16, @sprites["player"].bitmap.height * 4, 0)
      picturePlayer.moveXY(0, 16, playerpos[0] + 16, playerpos[1])
      picturePlayer.moveSrc(40, 0, 0)
      picturePlayer.moveXY(0, 40, playerpos[0], playerpos[1])
    end
    # Show Pokémon jumping before eating the bait
    picturePoke.moveSE(50, "Audio/SE/jump")
    picturePoke.moveXY(8, 50, pokecenter[0], pokecenter[1] - 8)
    picturePoke.moveXY(8, 58, pokecenter[0], pokecenter[1])
    pictureBall.moveVisible(66, false)
    picturePoke.moveSE(66, "Audio/SE/jump")
    picturePoke.moveXY(8, 66, pokecenter[0], pokecenter[1] - 8)
    picturePoke.moveXY(8, 74, pokecenter[0], pokecenter[1])
    # TODO: Show Pokémon eating the bait (pivots at the bottom right corner)
    loop do
      pictureBall.update
      picturePoke.update
      picturePlayer.update
      setPictureIconSprite(spriteBall, pictureBall)
      setPictureSprite(spritePoke, picturePoke)
      setPictureIconSprite(spritePlayer, picturePlayer)
      pbGraphicsUpdate
      Input.update
      break if !pictureBall.running? && !picturePoke.running? && !picturePlayer.running?
    end
    spriteBall.dispose
  end

  def pbThrowRock
    ball = sprintf("Graphics/Pictures/Battle/battleRock")
    anger = sprintf("Graphics/Pictures/Battle/battleAnger")
    armanim = false
    if @sprites["player"].bitmap.width > @sprites["player"].bitmap.height
      armanim = true
    end
    # sprites
    spritePoke = @sprites["pokemon1"]
    spritePlayer = @sprites["player"]
    spriteBall = IconSprite.new(0, 0, @viewport)
    spriteBall.visible = false
    spriteAnger = IconSprite.new(0, 0, @viewport)
    spriteAnger.visible = false
    # pictures
    pictureBall = PictureEx.new(spritePoke.z + 1)
    picturePoke = PictureEx.new(spritePoke.z)
    picturePlayer = PictureEx.new(spritePoke.z + 2)
    pictureAnger = PictureEx.new(spritePoke.z + 1)
    pokecenter = getSpriteCenter(@sprites["pokemon1"])
    playerpos = [@sprites["player"].x, @sprites["player"].y]
    # starting positions
    pictureBall.moveVisible(1, true)
    pictureBall.moveName(1, ball)
    pictureBall.moveOrigin(1, PictureOrigin::Center)
    pictureBall.moveXY(0, 1, 64, 256)
    picturePoke.moveVisible(1, true)
    picturePoke.moveOrigin(1, PictureOrigin::Center)
    picturePoke.moveXY(0, 1, pokecenter[0], pokecenter[1])
    picturePlayer.moveVisible(1, true)
    picturePlayer.moveName(1, @sprites["player"].name)
    picturePlayer.moveOrigin(1, PictureOrigin::TopLeft)
    picturePlayer.moveXY(0, 1, playerpos[0], playerpos[1])
    pictureAnger.moveVisible(1, false)
    pictureAnger.moveName(1, anger)
    pictureAnger.moveXY(0, 1, pokecenter[0] - 56, pokecenter[1] - 48)
    pictureAnger.moveOrigin(1, PictureOrigin::Center)
    pictureAnger.moveZoom(0, 1, 100)
    # directives
    picturePoke.moveSE(1, "Audio/SE/throw")
    pictureBall.moveCurve(30, 1, 64, 256, Graphics.width / 2, 48, pokecenter[0], pokecenter[1])
    pictureBall.moveAngle(30, 1, -720)
    pictureBall.moveAngle(0, pictureBall.totalDuration, 0)
    pictureBall.moveSE(30, "Audio/SE/notverydamage")
    if armanim
      picturePlayer.moveSrc(1, @sprites["player"].bitmap.height, 0)
      picturePlayer.moveXY(0, 1, playerpos[0] - 14, playerpos[1])
      picturePlayer.moveSrc(4, @sprites["player"].bitmap.height * 2, 0)
      picturePlayer.moveXY(0, 4, playerpos[0] - 12, playerpos[1])
      picturePlayer.moveSrc(8, @sprites["player"].bitmap.height * 3, 0)
      picturePlayer.moveXY(0, 8, playerpos[0] + 20, playerpos[1])
      picturePlayer.moveSrc(16, @sprites["player"].bitmap.height * 4, 0)
      picturePlayer.moveXY(0, 16, playerpos[0] + 16, playerpos[1])
      picturePlayer.moveSrc(40, 0, 0)
      picturePlayer.moveXY(0, 40, playerpos[0], playerpos[1])
    end
    pictureBall.moveVisible(40, false)
    # Show Pokémon being angry
    pictureAnger.moveSE(48, "Audio/SE/jump")
    pictureAnger.moveVisible(48, true)
    pictureAnger.moveZoom(8, 48, 130)
    pictureAnger.moveZoom(8, 56, 100)
    pictureAnger.moveXY(0, 64, pokecenter[0] + 56, pokecenter[1] - 64)
    pictureAnger.moveSE(64, "Audio/SE/jump")
    pictureAnger.moveZoom(8, 64, 130)
    pictureAnger.moveZoom(8, 72, 100)
    pictureAnger.moveVisible(80, false)
    loop do
      pictureBall.update
      picturePoke.update
      picturePlayer.update
      pictureAnger.update
      setPictureIconSprite(spriteBall, pictureBall)
      setPictureSprite(spritePoke, picturePoke)
      setPictureIconSprite(spritePlayer, picturePlayer)
      setPictureIconSprite(spriteAnger, pictureAnger)
      pbGraphicsUpdate
      Input.update
      break if !pictureBall.running? && !picturePoke.running? &&
               !picturePlayer.running? && !pictureAnger.running?
    end
    spriteBall.dispose
  end

  def playerPartyBarX
    return @battle.player.is_a?(Array) ? PBScene::PLAYERPARTYBAR_X - 20 : PBScene::PLAYERPARTYBAR_X
  end

  def playerPartyBarY
    return @battle.player.is_a?(Array) ? PBScene::PLAYERPARTYBAR_Y - 20 : PBScene::PLAYERPARTYBAR_Y
  end

  def playerPartyBallOneX
    return @battle.player.is_a?(Array) ? PBScene::PLAYERPARTYBALL1_X - 20 : PBScene::PLAYERPARTYBALL1_X
  end

  def playerPartyBallOneY
    return @battle.player.is_a?(Array) ? PBScene::PLAYERPARTYBALL1_Y - 20 : PBScene::PLAYERPARTYBALL1_Y
  end

  def foePartyBarX
    return (@battle.opponent.is_a?(Array) || TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype)) ? PBScene::FOEPARTYBAR_X + 20 : PBScene::FOEPARTYBAR_X
  end

  def foePartyBarY
    return (@battle.opponent.is_a?(Array) || TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype)) ? PBScene::FOEPARTYBAR_Y - 40 : PBScene::FOEPARTYBAR_Y
  end

  def foePartyBallOneX
    return (@battle.opponent.is_a?(Array) || TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype)) ? PBScene::FOEPARTYBALL1_X + 20 : PBScene::FOEPARTYBALL1_X
  end

  def foePartyBallOneY
    return (@battle.opponent.is_a?(Array) || TWOTRAINERSINONETYPES.include?(@battle.opponent&.trainertype)) ? PBScene::FOEPARTYBALL1_Y - 40 : PBScene::FOEPARTYBALL1_Y
  end

  # to update databox shield display every hit
  def pbUpdateShield(shield, index)
    return false if !@battle.battlers[index]
    return false if @battle.battlers[index].pokemon.shieldCount == shield

    @battle.battlers[index].pokemon.shieldCount = shield
    @sprites["battlebox#{index}"].shieldCount = shield
    @sprites["battlebox#{index}"].refresh
    if @battle.battlers[index].lastAttacker
      opponentindex = @battle.battlers[index].lastAttacker
    else
      opponentindex = @battle.battlers[index].pbOppositeOpposing.index
    end
    @battle.battlers[index].shieldsBrokenThisTurn[opponentindex] += 1
  end

  def pbIntroSOS(battle, sosmonindex = nil)
    # Called whenever the battle begins
    @battle = battle
    if @battle.opponent
      if @battle.opponent.is_a?(Array)
        trainerfile = pbTrainerSpriteFile(@battle.opponent[1].trainertype, @battle.opponent[1].outfit)
        pbAddSprite(
          "trainer2",
          PBScene::FOETRAINERD2_X,
          PBScene::FOETRAINERD2_Y,
          trainerfile, @viewport
        )
        trainerfile = pbTrainerSpriteFile(@battle.opponent[0].trainertype, @battle.opponent[0].outfit)
        pbAddSprite(
          "trainer",
          PBScene::FOETRAINERD1_X,
          PBScene::FOETRAINERD1_Y,
          trainerfile, @viewport
        )
        @sprites["trainer2"].visible = false
      else
        trainerfile = pbTrainerSpriteFile(@battle.opponent.trainertype, @battle.opponent.outfit)
        pbAddSprite(
          "trainer",
          PBScene::FOETRAINER_X,
          PBScene::FOETRAINER_Y,
          trainerfile, @viewport
        )
      end
      @sprites["trainer"].visible = false

    else
      trainerfile = pbTrainerSpriteFile(:TEST)
      pbAddSprite(
        "trainer",
        PBScene::FOETRAINER_X,
        PBScene::FOETRAINER_Y,
        trainerfile, @viewport
      )
      @sprites["trainer"].visible = false
    end
    @sprites["shadow3"] = PokemonShadowSprite.new(@viewport)
    for i in @battle.battlers
      battler = i if i.isbossmon && i.index != sosmonindex
    end
    battlerIndex = battler.index
    sosIndex = sosmonindex
    if @sprites["battlebox" + sosIndex.to_s].nil? || @sprites["pokemon" + sosIndex.to_s].nil?
      @sprites["battlebox" + sosIndex.to_s] = createPokemonDataBox(battle.battlers[sosIndex], battle.doublebattle, @viewport, battle)
      @sprites["pokemon" + sosIndex.to_s] = PokemonBattlerSprite.new(battle.doublebattle, 3, @viewport)
    end
    @sprites["shadow3"].z = 3
    @sprites["shadow3"].visible = false
    pokemon = @battle.party2[0][battler.pokemonIndex]

    bossposition = battlerIndex == 1 ? [PBScene::FOEBATTLERD1_X, PBScene::FOEBATTLERD1_Y] : [PBScene::FOEBATTLERD2_X, PBScene::FOEBATTLERD2_Y]
    sosposition = sosIndex == 1 ? [PBScene::FOEBATTLERD1_X, PBScene::FOEBATTLERD1_Y] : [PBScene::FOEBATTLERD2_X, PBScene::FOEBATTLERD2_Y]

    battlerSprite = @sprites["pokemon" + battlerIndex.to_s]
    battlerShadow = @sprites["shadow" + battlerIndex.to_s]
    # reinitialize the bosses UI box so it moves to doubles position of it wasn't already
    @sprites["battlebox" + battlerIndex.to_s].dispose
    @sprites["battlebox" + battlerIndex.to_s] = createPokemonDataBox(battle.battlers[battlerIndex], battle.doublebattle, @viewport, battle)
    @sprites["battlebox" + battlerIndex.to_s].appear
    while @sprites["battlebox" + battlerIndex.to_s].appearing
      @sprites["battlebox" + battlerIndex.to_s].update
    end
    @sprites["battlebox" + battlerIndex.to_s].refresh
    battlerSprite.x = bossposition[0]
    battlerSprite.y = bossposition[1]
    xoffset, yoffset = adjustBattleSprite(battlerSprite, pokemon.getCacheData, battlerIndex)
    battlerSprite.x += xoffset
    battlerSprite.y += yoffset
    battlerShadow.setPokemonShadowBitmap(pokemon.getCacheData)
    battlerShadow.x = bossposition[0]
    battlerShadow.x += adjustShadowSpriteX(battlerShadow, pokemon.getCacheData) if battlerShadow.bitmap != nil
    battlerShadow.y = bossposition[1]
    battlerShadow.y -= battlerShadow.bitmap.height / 2 if battlerShadow.bitmap != nil
    @sprites["shadow" + battlerIndex.to_s].visible = showShadow?(pokemon.getCacheData)
    if @battle.party2[0].length >= 1
      pokemon = @battle.party2[0][-1]
      sosBattlebox = @sprites["battlebox" + sosIndex.to_s]
      sosSprite = @sprites["pokemon" + sosIndex.to_s]
      sosShadow = @sprites["shadow" + sosIndex.to_s]
      # another line to account for me running absolute BS for one battle; double check that the battler on the battler box is actually the battler on that index
      sosBattlebox.dispose if sosBattlebox && (sosBattlebox.battler != battle.battlers[sosIndex] || !sosBattlebox.visible)
      @sprites["battlebox" + sosIndex.to_s] = createPokemonDataBox(battle.battlers[sosIndex], battle.doublebattle, @viewport, battle) if !sosBattlebox || sosBattlebox.disposed?
      sosSprite = PokemonBattlerSprite.new(battle.doublebattle, sosIndex, @viewport) if !sosSprite
      sosSprite.setPokemonBitmap(pokemon, sosIndex == 2)
      sosSprite.tone = Tone.new(-128, -128, -128, -128)
      sosSprite.x = sosposition[0]
      sosSprite.y = sosposition[1]
      xoffset, yoffset = adjustBattleSprite(sosSprite, pokemon.getCacheData, sosSprite.index)
      sosSprite.x += xoffset
      sosSprite.y += yoffset
      case sosIndex
        when 1 then sosSprite.z = 16
        when 2 then sosSprite.z = 26
        when 3 then sosSprite.z = 11
      end
      sosSprite.visible = true
      if sosIndex == 2
        sosShadow = IconSprite.new(0, 0, @viewport) if !sosShadow
      end
      sosShadow.setPokemonShadowBitmap(pokemon.getCacheData)
      sosShadow.x = sosposition[0]
      sosShadow.x += adjustShadowSpriteX(sosShadow, pokemon.getCacheData) if sosShadow.bitmap != nil
      sosShadow.y = sosposition[1]
      sosShadow.y -= sosShadow.bitmap.height / 2 if sosShadow.bitmap != nil
      sosShadow.visible = showShadow?(pokemon.getCacheData)
    end
    #################
    appearspeed = 12
    (1 + Graphics.width / appearspeed).times do
      tobreak = true
      if @viewport.rect.y > 0
        @viewport.rect.y -= appearspeed / 2
        @viewport.rect.y = 0 if @viewport.rect.y < 0
        @viewport.rect.height += appearspeed
        @viewport.rect.height = Graphics.height if @viewport.rect.height > Graphics.height
        tobreak = false
      end
      if !tobreak
        for i in @sprites
          next if i[1].nil?

          i[1].ox = @viewport.rect.x
          i[1].oy = @viewport.rect.y
        end
      end
      pbGraphicsUpdate
      Input.update
      break if tobreak
    end
    # Play cry for wild Pokémon
    pbPlayCry(@battle.party2[0][-1])
    @sprites["battlebox" + sosIndex.to_s].appear if @battle.party2[0].length >= 2
    appearing = true
    begin
      pbGraphicsUpdate
      Input.update
      @sprites["battlebox" + sosIndex.to_s].update
      @sprites["pokemon" + sosIndex.to_s].tone.red += 8 if @sprites["pokemon" + sosIndex.to_s].tone.red < 0
      @sprites["pokemon" + sosIndex.to_s].tone.blue += 8 if @sprites["pokemon" + sosIndex.to_s].tone.blue < 0
      @sprites["pokemon" + sosIndex.to_s].tone.green += 8 if @sprites["pokemon" + sosIndex.to_s].tone.green < 0
      @sprites["pokemon" + sosIndex.to_s].tone.gray += 8 if @sprites["pokemon" + sosIndex.to_s].tone.gray < 0
      appearing = @sprites["battlebox" + sosIndex.to_s].appearing
    end while appearing
    # Show shiny animation for wild Pokémon
    if @battle.party2[0][-1].isShiny? && @battle.battlescene
      pbCommonAnimation("Shiny", @battle.battlers[3], nil)
    end
  end

  def pbBossBattleSuccess(bossname = [])
    music = "Victory!"
    if Rejuv
      return if bossname.include?("Tiempa")
      music = getVictoryMusicOverride(music)
    end
    pbBGMPlay(music)
  end

  def swapBattlers(a, b)
    pbSEPlay("PRSFX- Ally Switch")

    battlers = []
    for i in [a, b]
      battlers.push @battle.battlers[i] unless @battle.battlers[i].vanished
    end

    # Hide battlers
    pbSyncronousVanish(battlers)

    # Hide UI
    for i in [a, b]
      8.times do
        @sprites["battlebox#{i}"].opacity -= 32
        pbGraphicsUpdate
        Input.update
      end
      @sprites["battlebox#{i}"].visible = false
      @sprites["battlebox#{i}"].dispose if !@battle.battlers[i].pokemon.nil?
      pbGraphicsUpdate
    end

    # Show UI
    for i in [a, b]
      pbChangePokemon(@battle.battlers[i], @battle.battlers[i].visiblePokemon)
      if @battle.battlers[i].effects[:Substitute] > 0
        pbSubstituteSprite(@battle.battlers[i])
        pbPositionSubstitute(i)
      end
      if Reborn # Reborn has a different UI implementation for boss/SOS data boxes
        @sprites["battlebox#{i}"] = PokemonDataBox.new(@battle.battlers[i], true, @viewport)
      else
        @sprites["battlebox#{i}"] = createPokemonDataBox(@battle.battlers[i], @battle.doublebattle, @viewport, @battle)
      end
      @sprites["battlebox#{i}"].appear

    end
    loop do
      @sprites["battlebox#{a}"].update
      @sprites["battlebox#{b}"].update
      pbGraphicsUpdate
      Input.update
      break if !@sprites["battlebox#{a}"].appearing && !@sprites["battlebox#{b}"].appearing
    end
    lastmove = @lastmove[a]
    @lastmove[a] = @lastmove[b]
    @lastmove[b] = lastmove

    # Show battlers
    pbSyncronousUnvanish(battlers)
  end
end

def getAbilityBoxAttrString(battler, item, attrname)
  return attrname if attrname
  return getItemName(item.is_a?(Symbol) ? item : battler.item) if item
  battlerability = battler.ability || battler.backupability
  return battlerability.nil? ? _INTL("No Ability") : getAbilityName(battlerability)
end

def pbMoveBattleSceneType(move, battler)
  return move.pbType(getBattlerWithFormChange(battler))
end

def getBattlerWithFormChange(battler)
  side = battler.battle.pbIsOpposing?(battler.index) ? 1 : 0
  owner = battler.battle.pbGetOwnerIndex(battler.index)
  formchange = case true
    when !battler.isMega? && battler.hasMega? && battler.battle.megaEvolution[side][owner] == battler.index then :mega
    when !battler.isUltra? && battler.hasUltra? && battler.battle.ultraBurst[side][owner] == battler.index then :ultra
    when !battler.isTerastallized? && battler.hasTera? && battler.battle.terastal[side][owner] == battler.index then :tera
    else nil
  end
  return battler unless formchange

  fakeBattler = battler.battle.ai.pbMakeFakeBattler(battler.pokemon.clone, battler.pokemonIndex, false, battler.index)
  case formchange
    when :mega then fakeBattler.pokemon.makeMega
    when :ultra then fakeBattler.pokemon.makeUltra
    when :tera then fakeBattler.pokemon.makeTerastallized
  end
  fakeBattler.form = fakeBattler.pokemon.form
  fakeBattler.pbUpdate(true, fakebattler: true)
  return fakeBattler
end

def pbFieldMoveHighlights(move, battler)
  battle = move.battle
  return nil if $Settings.field_effects_highlights == 1
  return nil if !battle.field.isFieldEffect?
  return nil if $cache.FEData[battle.FE].fieldAppSwitch.nil?
  return nil if !$game_switches[$cache.FEData[battle.FE].fieldAppSwitch]

  buffed = battle.field.buffedStatusMoves
  attacker = battler
  opponent = attacker.pbFirstOpposing
  return nil if move.powderMove? && battle.FE == :FLOWERGARDEN5 && !battle.doublebattle
  return nil if move.move == :ALLYSWITCH && battle.FE == :CHESS && (!battle.doublebattle || battler.pbOwnSide.effects[:Castled])
  return nil if move.move == :MISTYEXPLOSION && [:MISTY, :CORROSIVEMIST].include?(battle.FE) && attacker.isAirborne?
  return nil if move.move == :EXPANDINGFORCE && battle.FE == :PSYTERRAIN && attacker.isAirborne?
  return nil if move.move == :RISINGVOLTAGE && battle.FE == :ELECTERRAIN && opponent.isAirborne?
  # Not including overlays here since overlay statusBuffs/Nerfs don't actually work right now
  return :buff if buffed&.include?(move.move)
  return :buff if buffed&.any? { |symbol| $cache.moves[symbol].nil? && $cache.moves[move.move].checkFlag?(symbol) }

  nerfed = battle.field.nerfedStatusMoves
  return :nerf if nerfed&.include?(move.move)
  return :nerf if nerfed&.any? { |symbol| $cache.moves[symbol].nil? && $cache.moves[move.move].checkFlag?(symbol) }

  return nil if move.pbIsStatus?

  movetype = pbMoveBattleSceneType(move, attacker)
  typeBoost = move.typeFieldBoost(movetype, attacker, opponent)
  moveBoost = move.moveFieldBoost(attacker)
  totalboost = typeBoost * moveBoost
  return nil if move.pbFixedDamageMove? && totalboost != 0 # boost being 0 means move failure, any other boosts don't apply to fixed damage moves

  return :buff if totalboost > 1
  return :nerf if totalboost < 1
  return nil
end

def pbPokemonString(pkmn, party: false)
  if pkmn.is_a?(PokeBattle_Battler) && !pkmn.pokemon
    return ""
  end

  info = []
  info.push pkmn.name
  info.push "Level #{pkmn.level}"

  if pkmn.hp <= 0
    info.push " Status: Fainted"
  else
    case pkmn.status
      when :SLEEP then info.push " Status: Asleep"
      when :FROZEN then info.push " Status: Frozen"
      when :BURN then info.push " Status: Burned"
      when :PARALYSIS then info.push " Status: Paralyzed"
      when :POISON then info.push " Status: Poisoned"
    end
  end

  info.push(pkmn.hp == pkmn.totalhp ? "Full Health" : "HP: #{pkmn.hp} out of #{pkmn.totalhp}") if pkmn.hp > 0

  unless party
    # This info is available through the quick summary display
    info.push "Type: #{pkmn.types.map{ |t| getTypeName(t) }.join(" ")}"
    info.push "Ability: #{getAbilityName(pkmn.ability)}"
    info.push "Item: #{pkmn.item ? getItemName(pkmn.item) : "None"}"
  end

  info.push "Gender: #{genderName(pkmn.gender)}" unless pkmn.isGenderless?

  return info.join(", ")
end

def pbEnemyPokemonString(pkmn)
  if pkmn.is_a?(PokeBattle_Battler) && !pkmn.pokemon
    return ""
  end

  status = ""
  if pkmn.hp <= 0
    status = " Status: Fainted"
  else
    case pkmn.status
      when :SLEEP
        status = " Status: Asleep"
      when :FROZEN
        status = " Status: Frozen"
      when :BURN
        status = " Status: Burned"
      when :PARALYSIS
        status = " Status: Paralyzed"
      when :POISON
        status = " Status: Poisoned"
    end
  end
  return "#{pkmn.name} (Level #{pkmn.level})#{status} HP: #{(pkmn.hp.to_f / pkmn.totalhp.to_f * 1000).to_i / 10.0} %"
end

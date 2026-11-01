class PokegearButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_accessor :selected

  def initialize(x, y, internalname, displayname, index, viewport)
    super(viewport)
    @index = index
    @internalname = internalname
    @displayname = displayname
    @selected = false
    fembutton = pbResolveBitmap(sprintf("Graphics/Pictures/Pokegear/pokegearButtonf"))
    if $Trainer.isFemale? && fembutton
      @button = AnimatedBitmap.new("Graphics/Pictures/Pokegear/pokegearButtonf")
    else
      @button = AnimatedBitmap.new("Graphics/Pictures/Pokegear/pokegearButton")
    end
    @contents = BitmapWrapper.new(@button.width, @button.height)
    self.bitmap = @contents
    self.x = x
    self.y = y
    refresh
    update
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0, 0, @button.bitmap, Rect.new(0, 0, @button.width, @button.height))
    pbSetSystemFont(self.bitmap)
    textpos = [          # Name is written on both unselected and selected buttons
      [@displayname, self.bitmap.width / 2, 10, 2, Color.new(248, 248, 248), Color.new(40, 40, 40)],
      [@displayname, self.bitmap.width / 2, 62, 2, Color.new(248, 248, 248), Color.new(40, 40, 40)]
    ]
    pbDrawTextPositions(self.bitmap, textpos)
    icon = sprintf("Graphics/Pictures/Pokegear/pokegear" + @internalname)
    imagepos = [         # Icon is put on both unselected and selected buttons
      [icon, 18, 10, 0, 0, -1, -1],
      [icon, 18, 62, 0, 0, -1, -1]
    ]
    pbDrawImagePositions(self.bitmap, imagepos)
  end

  def update
    if self.selected
      self.src_rect.set(0, self.bitmap.height / 2, self.bitmap.width, self.bitmap.height / 2)
    else
      self.src_rect.set(0, 0, self.bitmap.width, self.bitmap.height / 2)
    end
    super
  end
end

#===============================================================================
# - Scene_Pokegear
#-------------------------------------------------------------------------------
# Modified By Harshboy
# Modified by Peter O.
# Also Modified By OblivionMew
# Overhauled by Maruno
# Also Overhauled by Haru
#===============================================================================
class Scene_Pokegear
  BTN_VHEIGHT = 24
  BTN_VSPACING = 48
  BTN_BASEXPOS = 118
  BTN_BASEYPOS = 196

  #-----------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end

  #-----------------------------------------------------------------------------
  # main
  #-----------------------------------------------------------------------------
  def main
    setup()
    init_sprites()
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def init_sprites()
    directory = Desolation ? "Graphics/Pictures/" : "Graphics/Pictures/Pokegear/"
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @button = AnimatedBitmap.new("#{directory}pokegearButton")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0)
    if Desolation && $Trainer.isFemale? && pbResolveBitmap(sprintf("#{directory}pokegearbgf"))
      @sprites["background"].setBitmap("#{directory}pokegearbgf")
    else
      @sprites["background"].setBitmap("#{directory}pokegearbg")
    end
    @sprites["command_window"] = Window_CommandPokemon.new(@buttons, 160, tts: false)
    @sprites["command_window"].index = default_index
    @sprites["command_window"].x = Graphics.width
    @sprites["command_window"].y = -3000 # 0
    @lastread = default_index
    tts(@buttons[default_index], true)
    for i in 0...@buttons.length
      x = BTN_BASEXPOS
      y = BTN_BASEYPOS - (@buttons.length * BTN_VHEIGHT) + (i * BTN_VSPACING)
      @sprites["button#{i}"] = PokegearButton.new(x, y, @buttonnames[i], @buttons[i], i, @viewport)
      @sprites["button#{i}"].selected = i == @sprites["command_window"].index
      @sprites["button#{i}"].update
    end
  end

  #-----------------------------------------------------------------------------
  # update the scene
  #-----------------------------------------------------------------------------
  def update
    for i in 0...@sprites["command_window"].commands.length
      sprite = @sprites["button#{i}"]
      sprite.selected = (i == @sprites["command_window"].index) ? true : false
    end
    pbUpdateSpriteHash(@sprites)
    # update command window and the info if it's active
    if @sprites["command_window"].active
      update_command
      return
    end
  end

  #-----------------------------------------------------------------------------
  # update the command window
  #-----------------------------------------------------------------------------
  def update_command
    if @lastread != @sprites["command_window"].index
      tts(@sprites["command_window"].commands[@sprites["command_window"].index], true)
      @lastread = @sprites["command_window"].index
    end
    if Input.trigger?(Input::B)
      $scene = Scene_Map.new
      return
    end
    if Input.trigger?(Input::C)
      pbPlayDecisionSE()
      checkChoice()
      return
    end
  end

  #-----------------------------------------------------------------------------
  # utility functions
  #-----------------------------------------------------------------------------
  def addButton(internalname, displayname)
    @buttonnames.push(internalname)
    @buttons.push(displayname)
  end
end

# Jinx Scent / Spice Scent
class Scene_EncounterRate
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end

  def main
    if !defined?($game_variables[:EncounterRateModifier]) || $game_switches[:FirstUse] != true
      $game_variables[:EncounterRateModifier] = 1
    end
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["background"] = IconSprite.new(0, 0)
    graphic = Desolation ? "jinxscentbg" : "spicescentbg"
    @sprites["background"].setBitmap("Graphics/Pictures/#{graphic}")
    @sprites["background"].z = 255

    Graphics.transition
    params = ChooseNumberParams.new
    params.setRange(0, 9999)
    params.setInitialValue($game_variables[:EncounterRateModifier].to_f * 100)
    params.setCancelValue($game_variables[:EncounterRateModifier].to_f * 100)
    $game_variables[:EncounterRateModifier] = Kernel.pbChooseNumber(nil, params).to_f / 100
    if Desolation
      $game_switches[904] = $game_variables[:EncounterRateModifier] == 0 ? true : false
    end
    $game_switches[:FirstUse] = true
    if defined?($game_map.map_id)
      $PokemonEncounters.setup($game_map.map_id)
    end
    $scene = Scene_Pokegear.new(:scent)
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

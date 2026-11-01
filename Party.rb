ANNOT_SELECTED_COLORS = ColorArrays[:Blue2]
ANNOT_ELIGIBLE_COLORS = ColorArrays[:Green3]
ANNOT_INELIGIBLE_COLORS = ColorArrays[:Red]

# Data structure representing mail that the Pokémon can hold
class PokemonMail
  attr_accessor :item, :message, :sender, :poke1, :poke2, :poke3

  def initialize(item, message, sender, poke1 = nil, poke2 = nil, poke3 = nil)
    @item = item # Item represented by this mail
    @message = message # Message text
    @sender = sender # Name of the message's sender
    @poke1 = poke1 # [species,gender,shininess,form,shadowness,is egg]
    @poke2 = poke2
    @poke3 = poke3
  end
end

def pbMoveToMailbox(pokemon)
  $PokemonGlobal.mailbox = [] if !$PokemonGlobal.mailbox
  return false if $PokemonGlobal.mailbox.length >= 10
  return false if !pokemon.mail

  $PokemonGlobal.mailbox.push(pokemon.mail)
  pokemon.mail = nil
  return true
end

def pbStoreMail(pkmn, item, message, poke1 = nil, poke2 = nil, poke3 = nil)
  raise _INTL("Pokémon already has mail") if pkmn.mail

  pkmn.mail = PokemonMail.new(item, message, $Trainer.name, poke1, poke2, poke3)
end

MAIL_COLOR_LIGHT = [Color.new(80, 80, 88), Color.new(168, 168, 176)]
MAIL_COLOR_DARK = [Color.new(248, 248, 248), Color.new(72, 80, 88)]

def pbDisplayMail(mail, bearer = nil)
  sprites = {}
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  addBackgroundPlane(sprites, "background", "mailbg", viewport)
  sprites["card"] = IconSprite.new(0, 0, viewport)
  sprites["card"].setBitmap(pbMailBackFile(mail.item))
  sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, viewport)
  overlay = sprites["overlay"].bitmap
  pbSetSystemFont(overlay)
  if mail.poke1 != nil
    sprites["bearer"] = IconSprite.new(64 - AURA_SPRITE_OFFSET / 2, 288 - AURA_SPRITE_OFFSET / 2, viewport)
    sprites["bearer"].bitmap = pbIconBitmap(mail.poke1[0], mail.poke1[3], mail.poke1[2], mail.poke1[1] == 1, mail.poke1[5], mail.poke1[4])
    sprites["bearer"].src_rect.set(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
  end
  if mail.poke2 != nil
    sprites["bearer2"] = IconSprite.new(144 - AURA_SPRITE_OFFSET / 2, 288 - AURA_SPRITE_OFFSET / 2, viewport)
    sprites["bearer2"].bitmap = pbIconBitmap(mail.poke2[0], mail.poke2[3], mail.poke2[2], mail.poke2[1] == 1, mail.poke2[5], mail.poke2[4])
    sprites["bearer2"].src_rect.set(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
  end
  if mail.poke3 != nil
    sprites["bearer3"] = IconSprite.new(224 - AURA_SPRITE_OFFSET / 2, 288 - AURA_SPRITE_OFFSET / 2, viewport)
    sprites["bearer3"].bitmap = pbIconBitmap(mail.poke3[0], mail.poke3[3], mail.poke3[2], mail.poke3[1] == 1, mail.poke3[5], mail.poke3[4])
    sprites["bearer3"].src_rect.set(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
  end
  if mail.message && mail.message != ""
    isDark = isDarkBackground(sprites["card"].bitmap, Rect.new(48, 48, Graphics.width - 96, 32 * 7))
    drawTextEx(overlay, 48, 48, Graphics.width - 96, 7, mail.message, *(isDark ? MAIL_COLOR_DARK : MAIL_COLOR_LIGHT))
  end
  if mail.sender && mail.sender != ""
    isDark = isDarkBackground(sprites["card"].bitmap, Rect.new(336, 322, 144, 32 * 1))
    drawTextEx(overlay, 336, 322, 144 - 16, 1, mail.sender, *(isDark ? MAIL_COLOR_DARK : MAIL_COLOR_LIGHT))
  end
  pbFadeInAndShow(sprites)
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::B) || Input.trigger?(Input::C)
      break
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end

def pbMailScreen(item, pkmn, screen, scene)
  message = ""
  loop do
    prompt = $Settings.useKeyboard? ? _INTL("Please enter a message (max. 256 characters).") : _INTL("Please enter a message.")
    message = Kernel.pbMessageFreeText(prompt, "", 256, Graphics.width) { scene.update }
    if message != ""
      # Store mail if a message was written
      poke1 = poke2 = poke3 = nil
      if screen.is_a?(PokemonScreen) # party screen, as opposed to storage screen
        pkmnid = $Trainer.party.index(pkmn)
        if $Trainer.party[pkmnid + 2]
          p = $Trainer.party[pkmnid + 2]
          poke1 = [p.species, p.gender, p.isShiny?, (p.form rescue 0), (p.isShadow? rescue false), p.isEgg?]
        end
        if $Trainer.party[pkmnid + 1]
          p = $Trainer.party[pkmnid + 1]
          poke2 = [p.species, p.gender, p.isShiny?, (p.form rescue 0), (p.isShadow? rescue false), p.isEgg?]
        end
      end
      poke3 = [pkmn.species, pkmn.gender, pkmn.isShiny?, (pkmn.form rescue 0), (pkmn.isShadow? rescue false), pkmn.isEgg?]
      pbStoreMail(pkmn, item, message, poke1, poke2, poke3)
      return true
    else
      return false if screen.pbConfirm(_INTL("Stop giving the Pokémon Mail?"))
    end
  end
end

###########################

class PokeSelectionPlaceholderSprite < SpriteWrapper
  attr_accessor :text

  def initialize(pokemon, index, viewport = nil)
    super(viewport)
    xvalues = [0, 256, 0, 256, 0, 256]
    yvalues = [0, 16, 96, 112, 192, 208]
    @pbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/partyPanelBlank")
    self.bitmap = @pbitmap.bitmap
    self.x = xvalues[index]
    self.y = yvalues[index]
    @text = nil
  end

  def update
    super
    @pbitmap.update
    self.bitmap = @pbitmap.bitmap
  end

  def selected
    return false
  end

  def selected=(value)
  end

  def preselected
    return false
  end

  def preselected=(value)
  end

  def switching
    return false
  end

  def switching=(value)
  end

  def refresh
  end

  def dispose
    @pbitmap.dispose
    super
  end
end

class PokeSelectionConfirmCancelSprite < SpriteWrapper
  attr_reader :selected

  CANCELBTN_COLOR = [Color.new(248, 248, 248), Color.new(40, 40, 40)]
  NARROWBOX_OFFSET = -6

  def initialize(text, x, y, narrowbox = false, viewport = nil)
    super(viewport)
    @refreshBitmap = true
    @bgsprite = ChangelingSprite.new(0, 0, viewport)
    if narrowbox
      @bgsprite.addBitmap("deselbitmap", "Graphics/Pictures/Party/partyCancelNarrow")
      @bgsprite.addBitmap("selbitmap", "Graphics/Pictures/Party/partyCancelSelNarrow")
    else
      @bgsprite.addBitmap("deselbitmap", "Graphics/Pictures/Party/partyCancel")
      @bgsprite.addBitmap("selbitmap", "Graphics/Pictures/Party/partyCancelSel")
    end
    @bgsprite.changeBitmap("deselbitmap")
    @overlaysprite = BitmapSprite.new(@bgsprite.bitmap.width, @bgsprite.bitmap.height, viewport)
    @yoffset = 8
    pbSetSystemFont(@overlaysprite.bitmap)
    ynarrow = narrowbox ? NARROWBOX_OFFSET : 0
    textpos = [[text, 56, 8 + ynarrow, 2, *CANCELBTN_COLOR]]
    pbDrawTextPositions(@overlaysprite.bitmap, textpos)
    @overlaysprite.z = self.z + 1 # For compatibility with RGSS2
    self.x = x
    self.y = y
  end

  def dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    @bgsprite.dispose
    super
  end

  def viewport=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def selected=(value)
    @selected = value
    refresh
  end

  def refresh
    @bgsprite.changeBitmap((@selected) ? "selbitmap" : "deselbitmap")
    if @bgsprite && !@bgsprite.disposed?
      @bgsprite.x = self.x
      @bgsprite.y = self.y
      @overlaysprite.x = self.x
      @overlaysprite.y = self.y
      @bgsprite.color = self.color
      @overlaysprite.color = self.color
    end
  end
end

class PokeSelectionCancelSprite < PokeSelectionConfirmCancelSprite
  def initialize(viewport = nil)
    text = Reborn ? _INTL("Cancel") : _INTL("CANCEL")
    super(text, 398, 328, false, viewport)
  end
end

class PokeSelectionConfirmSprite < PokeSelectionConfirmCancelSprite
  def initialize(viewport = nil)
    text = Reborn ? _INTL("Confirm") : _INTL("CONFIRM")
    super(text, 398, 308, true, viewport)
  end
end

class PokeSelectionCancelSprite2 < PokeSelectionConfirmCancelSprite
  def initialize(viewport = nil)
    text = Reborn ? _INTL("Cancel") : _INTL("CANCEL")
    super(text, 398, 346, true, viewport)
  end
end

class PokeSelectionSprite < SpriteWrapper
  attr_reader :selected # The cursor is currently on this Pokemon
  attr_reader :preselected # This Pokemon is currently selected for switching with another Pokemon
  attr_reader :switching
  attr_reader :pokemon
  attr_reader :active
  attr_accessor :text
  attr_accessor :textcolors

  FONT_BASE = [Color.new(248, 248, 248), Color.new(40, 40, 40)]
  FONT_MALE = [Color.new(0, 112, 248), Color.new(120, 184, 232)]
  FONT_FEMALE = [Color.new(232, 32, 16), Color.new(248, 168, 184)]
  HP_COLORS = [
    [Color.new(24, 192, 32), Color.new(96, 248, 96)], # Green
    [Color.new(232, 168, 0), Color.new(248, 216, 0)], # Yellow
    [Color.new(248, 72, 56), Color.new(248, 152, 152)], # Red
  ]

  HP_STRING = "{1: 3d}/{2: 3d}"
  HP_X = 178
  ANNOT_X = 96
  ANNOT_Y = 58
  HP_BAR_X = 96
  STATUS_X = 80
  STATUS_Y = 68
  STATUS_WIDTH = 44
  STATUS_HEIGHT = 16

  def initialize(pokemon, index, viewport = nil)
    super(viewport)
    @pokemon = pokemon
    active = (index == 0)
    @active = active
    @deselbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/partyPanel")
    @selbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/partyPanelSel")
    @deselfntbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/partyPanelFnt")
    @selfntbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/partyPanelSelFnt")
    @deselswapbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/partyPanel")
    @selswapbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/partyPanelSel")
    @deselswapfntbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/partyPanelFnt")
    @selswapfntbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/partyPanelSelFnt")
    @pbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/partyPanelBlank")
    @preselbitmap = Reborn ? AnimatedBitmap.new("Graphics/Pictures/Party/partyPreSel") : nil
    @spriteXOffset = 28
    @spriteYOffset = 0
    @pokeballXOffset = 10
    @pokeballYOffset = 0
    @pokenameX = 96
    @pokenameY = 16
    @levelX = 20
    @levelY = 68
    @statusX = STATUS_X
    @statusY = STATUS_Y
    @genderX = 224
    @genderY = 16
    @hpX = HP_X
    @hpY = 60
    @hpbarX = HP_BAR_X
    @hpbarY = 50
    @gaugeX = 128
    @gaugeY = 52
    @itemXOffset = 62
    @itemYOffset = 48
    xvalues = [0, 256, 0, 256, 0, 256]
    yvalues = [0, 16, 96, 112, 192, 208]
    @text = nil
    @pkmnsprite = PokemonIconSprite.new(pokemon, viewport)
    @pkmnsprite.active = active
    @statuses = AnimatedBitmap.new("Graphics/Pictures/statuses")
    @hpbar = AnimatedBitmap.new("Graphics/Pictures/Party/partyHP")
    @hpbarfnt = AnimatedBitmap.new("Graphics/Pictures/Party/partyHPfnt")
    @hpbarswap = AnimatedBitmap.new("Graphics/Pictures/Party/partyHP")
    @hpbarswapfnt = AnimatedBitmap.new("Graphics/Pictures/Party/partyHPfnt")
    @pokeballsprite = ChangelingSprite.new(0, 0, viewport)
    @pokeballsprite.addBitmap("pokeballdesel", "Graphics/Pictures/Party/partyBall")
    @pokeballsprite.addBitmap("pokeballsel", "Graphics/Pictures/Party/partyBallSel")
    @itemsprite = ChangelingSprite.new(0, 0, viewport)
    @itemsprite.addBitmap("itembitmap", "Graphics/Pictures/Party/item")
    @itemsprite.addBitmap("mailbitmap", "Graphics/Pictures/Party/mail")
    @spriteX = xvalues[index]
    @spriteY = yvalues[index]
    @refreshBitmap = true
    @refreshing = false
    @preselected = false
    @switching = false
    @pkmnsprite.z = self.z + 2 # For compatibility with RGSS2
    @itemsprite.z = self.z + 3 # For compatibility with RGSS2
    @pokeballsprite.z = self.z + 1 # For compatibility with RGSS2
    self.selected = false
    self.x = @spriteX
    self.y = @spriteY
    refresh
  end

  def dispose
    @selbitmap.dispose
    @statuses.dispose
    @hpbar.dispose
    @deselbitmap.dispose
    @itemsprite.dispose
    @pkmnsprite.dispose
    @pokeballsprite.dispose
    self.bitmap.dispose
    super
  end

  def selected=(value)
    @selected = value
    @refreshBitmap = true
    refresh
  end

  def textcolors=(value)
    @textcolors = value
    @refreshBitmap = true
    refresh
  end

  def pokemon=(value)
    @pokemon = value
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.pokemon = value
    end
    @refreshBitmap = true
    refresh
  end

  def preselected=(value)
    if value != @preselected
      @preselected = value
      refresh
    end
  end

  def switching=(value)
    if value != @switching
      @switching = value
      refresh
    end
  end

  def color=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def hp
    return @pokemon.hp
  end

  def refresh
    return if @refreshing
    return if disposed?

    @refreshing = true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap = BitmapWrapper.new(@selbitmap.width, @selbitmap.height)
    end
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x = self.x + @spriteXOffset
      @pkmnsprite.y = self.y + @spriteYOffset
      @pkmnsprite.color = pbSrcOver(@pkmnsprite.color, self.color)
      @pkmnsprite.selected = self.selected
    end
    if @pokeballsprite && !@pokeballsprite.disposed?
      @pokeballsprite.x = self.x + @pokeballXOffset
      @pokeballsprite.y = self.y + @pokeballYOffset
      @pokeballsprite.color = self.color
      @pokeballsprite.changeBitmap(self.selected && !@pokemon.unusable ? "pokeballsel" : "pokeballdesel")
    end
    if @itemsprite && !@itemsprite.disposed?
      @itemsprite.visible = (!@pokemon.item.nil?)
      if @itemsprite.visible
        @itemsprite.changeBitmap(@pokemon.mail ? "mailbitmap" : "itembitmap")
        @itemsprite.x = self.x + @itemXOffset
        @itemsprite.y = self.y + @itemYOffset
        @itemsprite.color = self.color
      end
    end
    if @refreshBitmap
      @refreshBitmap = false
      self.bitmap.clear if self.bitmap
      unable = ((@pokemon.hp <= 0 && !@pokemon.isEgg?) || @pokemon.stolen) && !@pokemon.unusable
      unusable = @pokemon.unusable
      if self.selected
        if self.preselected
          bmp = unable || unusable ? @selswapfntbitmap : @selswapbitmap
        elsif @switching
          bmp = unable || unusable ? @selswapfntbitmap : @selswapbitmap
        else
          bmp = unable || unusable ? @selfntbitmap : @selbitmap
        end
      else
        if self.preselected
          bmp = unable || unusable ? @deselswapfntbitmap : @deselswapbitmap
        else
          bmp = unable || unusable ? @deselfntbitmap : @deselbitmap
        end
      end
      self.bitmap.blt(0, 0, bmp.bitmap, Rect.new(0, 0, bmp.width, bmp.height))
      if self.preselected && @preselbitmap
        self.bitmap.blt(0, 0, @preselbitmap.bitmap, Rect.new(0, 0, @preselbitmap.width, @preselbitmap.height))
      end

      base = FONT_BASE[0]
      shadow = FONT_BASE[1]

      pbSetSystemFont(self.bitmap)
      textpos = []
      if !@pokemon.isEgg? && !@pokemon.unusable
        if !@text || @text.length == 0
          tothp = @pokemon.totalhp
          textpos.push([_ISPRINTF(HP_STRING, @pokemon.hp, tothp), @hpX, @hpY, 2, base, shadow])

          barbg = unable ? @hpbarfnt : @hpbar
          if self.preselected || (self.selected && @switching)
            barbg = unable ? @hpbarswapfnt : @hpbarswap
          end
          self.bitmap.blt(@hpbarX, @hpbarY, barbg.bitmap, Rect.new(0, 0, @hpbar.width, @hpbar.height))

          hpgauge = (@pokemon.totalhp == 0 || self.hp == 0) ? 0 : [self.hp * 96 / @pokemon.totalhp, 2].max.to_grid
          hpzone = getHPZone(self.hp, @pokemon.totalhp)
          fillHPGauge(hpgauge, hpzone)
          if @pokemon.hp == 0 || !@pokemon.status.nil?
            status = (@pokemon.hp == 0) ? :FAINTED : @pokemon.status
            imagepos = []
            imagepos.push([sprintf("Graphics/Pictures/Party/status%s", status), @statusX, @statusY, 0, 0, STATUS_WIDTH, STATUS_HEIGHT])
            pbDrawImagePositions(self.bitmap, imagepos)
          end
        end
      end
      pbDrawTextPositions(self.bitmap, textpos)

      pokename = @pokemon.name
      nameYoffset = 0
      if !@pokemon.isEgg? && !@pokemon.isGenderless?
        gendercolors = @pokemon.isMale? ? FONT_MALE : FONT_FEMALE
        textpos = [[genderSign(@pokemon.gender), @genderX, @genderY, :left, *gendercolors]]
        pbDrawTextPositions(self.bitmap, textpos)
        # Use small font for name if name would touch/overlap gender icon
        if @pokenameX + self.bitmap.text_size(pokename).width >= @genderX
          pbSetSmallFont(self.bitmap)
          nameYoffset += 6
        end
      end
      textpos = [[pokename, @pokenameX, @pokenameY + nameYoffset, :left, base, shadow]]
      pbDrawTextPositions(self.bitmap, textpos)

      if !@pokemon.isEgg?
        pbSetSmallFont(self.bitmap)
        leveldisplay = @pokemon.obtainLevel == :Undefinable ? "???" : @pokemon.level
        leveltext = [[_INTL("Lv.{1}", leveldisplay), @levelX, @levelY, 0, base, shadow]]
        pbDrawTextPositions(self.bitmap, leveltext)
      end

      if @text && @text.length > 0
        pbSetSystemFont(self.bitmap)
        annotbase, annotshadow = *@textcolors
        annotation = [[@text, ANNOT_X, ANNOT_Y, 0, annotbase, annotshadow]]
        pbDrawTextPositions(self.bitmap, annotation)
      end
    end
    @refreshing = false
  end

  def update
    super
    @pokeballsprite.update if @pokeballsprite && !@pokeballsprite.disposed?
    @itemsprite.update if @itemsprite && !@itemsprite.disposed?
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.update
    end
  end

  def fillHPGauge(hpgauge, hpzone)
    self.bitmap.fill_rect(@gaugeX, @gaugeY, hpgauge, 2, HP_COLORS[hpzone][0])
    self.bitmap.fill_rect(@gaugeX, @gaugeY + 2, hpgauge, 4, HP_COLORS[hpzone][1])
    self.bitmap.fill_rect(@gaugeX, @gaugeY + 6, hpgauge, 2, HP_COLORS[hpzone][0])
  end
end


##############################


class PokemonScreen_Scene
  SWITCH_SPEED = 24 # Total distance to move is 264 so this number must divide 264

  attr_accessor :sprites

  def pbShowCommands(helptext, commands, index = 0)
    tts(helptext, true)
    ret = -1
    helpwindow = @sprites["helpwindow"]
    helpwindow.visible = true
    using_block(cmdwindow = Window_AdvancedCommandPokemon.new(commands)) {
      cmdwindow.z = @viewport.z + 1
      cmdwindow.index = index
      pbBottomRight(cmdwindow)
      helpwindow.text = ""
      helpwindow.resizeHeightToFit(helptext, Graphics.width - cmdwindow.width)
      helpwindow.text = helptext
      pbBottomLeft(helpwindow)
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        self.update
        if Input.trigger?(Input::B)
          pbPlayCancelSE()
          ret = -1
          break
        end
        if Input.trigger?(Input::C)
          pbPlayDecisionSE()
          ret = cmdwindow.index
          break
        end
      end
    }
    return ret
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbSetHelpText(helptext)
    helpwindow = @sprites["helpwindow"]
    pbBottomLeftLines(helpwindow, 1)
    tts(helptext, true) if helpwindow.text != helptext
    helpwindow.text = helptext
    helpwindow.width = 398
    helpwindow.visible = true
  end

  def pbStartScene(party, starthelptext, annotations = nil, multiselect = false, autoheal: false)
    @sprites = {}
    @party = party
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @multiselect = multiselect
    addBackgroundPlane(@sprites, "partybg", "Party/partybg", @viewport)
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["messagebox"].viewport = @viewport
    @sprites["messagebox"].visible = false
    @sprites["messagebox"].letterbyletter = true
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].visible = true
    if autoheal
      @autohealicon = AnimatedBitmap.new("Graphics/Pictures/Party/autohealicon")
      sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      overlay = sprites["overlay"].bitmap
      overlay.blt(4, 292, @autohealicon.bitmap, Rect.new(0, 0, @autohealicon.width, @autohealicon.height))
    end
    pbBottomLeftLines(@sprites["messagebox"], 2)
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    pbSetHelpText(starthelptext)
    # Add party Pokémon sprites
    for i in 0...6
      if @party[i]
        @sprites["pokemon#{i}"] = PokeSelectionSprite.new(@party[i], i, @viewport)
      else
        @sprites["pokemon#{i}"] = PokeSelectionPlaceholderSprite.new(@party[i], i, @viewport)
      end
      if annotations && annotations[i] && !@party[i].unusable
        @sprites["pokemon#{i}"].text = annotations[i][0]
        @sprites["pokemon#{i}"].textcolors = annotations[i][1]
      end
    end
    if @multiselect
      @sprites["pokemon6"] = PokeSelectionConfirmSprite.new(@viewport)
      @sprites["pokemon7"] = PokeSelectionCancelSprite2.new(@viewport)
    else
      @sprites["pokemon6"] = PokeSelectionCancelSprite.new(@viewport)
    end
    # Select first Pokémon
    @activecmd = 0
    @sprites["pokemon0"].selected = true
    pbFadeInAndShow(@sprites) { update }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbChangeSelection(key, currentsel)
    partylastindex = @party.length - 1 - @party.reverse.find_index { |i| !i.nil? }
    lastindex = showingQuickSummary? ? partylastindex : (@multiselect ? 7 : 6)
    case key
      when Input::LEFT
        loop do
          currentsel -= 1
          currentsel = lastindex if currentsel < 0
          break if validSelection?(currentsel)
        end
      when Input::RIGHT
        loop do
          currentsel += 1
          currentsel = 0 if currentsel > lastindex
          break if validSelection?(currentsel)
        end
      when Input::UP
        firstloop = true
        loop do
          num = firstloop && (1..partylastindex).include?(currentsel) ? 2 : 1
          currentsel -= num
          currentsel = lastindex if currentsel < 0
          break if validSelection?(currentsel)
          firstloop = false
        end
      when Input::DOWN
        firstloop = true
        loop do
          num = firstloop && (0..(partylastindex - 1)).include?(currentsel) ? 2 : 1
          currentsel += num
          currentsel = 0 if currentsel > lastindex
          break if validSelection?(currentsel)
          firstloop = false
        end
    end
    return currentsel
  end

  def validSelection?(currentsel)
    return [7, 6].include?(currentsel) || @party[currentsel]
  end

  def pbRefresh
    for i in 0...6
      sprite = @sprites["pokemon#{i}"]
      if sprite
        if sprite.is_a?(PokeSelectionSprite)
          sprite.pokemon = sprite.pokemon
        else
          sprite.refresh
        end
      end
    end
  end

  def pbRefreshSingle(i)
    sprite = @sprites["pokemon#{i}"]
    if sprite
      if sprite.is_a?(PokeSelectionSprite)
        sprite.pokemon = sprite.pokemon
      else
        sprite.refresh
      end
    end
  end

  def pbHardRefresh
    oldtext = []
    lastselected = -1
    for i in 0...6
      oldtext.push(@sprites["pokemon#{i}"].text)
      lastselected = i if @sprites["pokemon#{i}"].selected
      @sprites["pokemon#{i}"].dispose
    end
    lastselected = @party.length - 1 if lastselected >= @party.length
    lastselected = 0 if lastselected < 0
    for i in 0...6
      if @party[i]
        @sprites["pokemon#{i}"] = PokeSelectionSprite.new(@party[i], i, @viewport)
      else
        @sprites["pokemon#{i}"] = PokeSelectionPlaceholderSprite.new(@party[i], i, @viewport)
      end
      @sprites["pokemon#{i}"].text = oldtext[i]
    end
    pbSelect(lastselected)
  end

  def pbChoosePokemon(switching = false, allow_party_switch = false, canswitch = 0, shortcut_keys: false)
    for i in 0...6
      @sprites["pokemon#{i}"].preselected = (switching && i == @activecmd)
      @sprites["pokemon#{i}"].switching = switching
    end
    pbRefresh
    lastread = nil
    loop do
      Graphics.update
      Input.update
      self.update
      # Changing selection
      oldsel = @activecmd
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key >= 0
        @activecmd = pbChangeSelection(key, @activecmd)
      end
      pkmn = @sprites["pokemon#{@activecmd}"].pokemon if @activecmd < 6
      if @activecmd != oldsel
        pbPlayCursorSE()
        numsprites = @multiselect ? 8 : 7
        for i in 0...numsprites
          @sprites["pokemon#{i}"].selected = (i == @activecmd)
        end
      end
      if @activecmd != lastread
        if @activecmd == 6 && @multiselect
          tts('Confirm', true)
        elsif @activecmd >= 6
          tts('Cancel', true)
        else
          tts(pbPokemonString(pkmn, party: true), !lastread.nil?) # Don't interrupt the helptext when the screen is opened
        end
        lastread = @activecmd
      end
      showQuickSummary if showingQuickSummary? && @activecmd != oldsel

      # Selection / Cancellation
      if showingQuickSummary? && (Input.trigger?(Input::B) || Input.trigger?(Input::C))
        pbPlayCancelSE()
        disposeQuickSummary
      elsif Input.trigger?(Input::B)
        return -1
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE()
        cancelsprite = @multiselect ? 7 : 6
        return @activecmd == cancelsprite ? -1 : @activecmd
      end
      # Switch (not allowed in battle)
      if allow_party_switch && [0, 1].include?(canswitch) && Input.trigger?(Input::X) && @activecmd < 6
        disposeQuickSummary
        pbPlayDecisionSE()
        return [1, @activecmd] if canswitch == 0
        return @activecmd if canswitch == 1
      end
      if shortcut_keys && canswitch == 0 && @activecmd < 6
        # Summary
        if Input.time?(Input::Z) >= 0.5 && !pkmn.isEgg?
          disposeQuickSummary
          pbPlayDecisionSE()
          return [3, @activecmd]
        elsif Input.release?(Input::Z) && !Input.press?(Input::Z)
          # Quick Summary
          if showingQuickSummary?
            pbPlayCancelSE()
            disposeQuickSummary
          else
            pbPlayDecisionSE()
            showQuickSummary
          end
        end
      end
      if allow_party_switch && shortcut_keys # These functions are not allowed in battle
        # Item
        if Input.trigger?(Input::Y) && canswitch == 0 && @activecmd < 6 && !pkmn.isEgg?
          disposeQuickSummary
          pbPlayDecisionSE()
          return [2, @activecmd]
        end
        # Auto-heal
        if Input.trigger?(Input::L)
          disposeQuickSummary
          return [5, @activecmd]
        end
        # Auto-heal options
        if Input.trigger?(Input::R)
          disposeQuickSummary
          return [6, @activecmd]
        end
        # Remote PC
        if Input.time?(Input::A) >= 0.5 && $PokemonBag&.pbHasItem?(:REMOTEPC)
          disposeQuickSummary
          v = pbTryUseRemotePC(true)
          pbHardRefresh if v
        # Moves
        elsif Input.release?(Input::A) && !Input.press?(Input::A) && !pkmn.isEgg? && !(pkmn.isShadow? rescue false)
          disposeQuickSummary
          pbPlayDecisionSE()
          return [4, @activecmd]
        end
      end
      # Controls screen
      if Input.triggerex?(Input::F2)
        disposeQuickSummary
        scene = DefaultControlsScene.new(3)
        pbFadeOutIn(99999) { scene.pbRender }
      end
    end
  end

  def pbSelect(item)
    @activecmd = item
    numsprites = @multiselect ? 8 : 7
    for i in 0...numsprites
      @sprites["pokemon#{i}"].selected = (i == @activecmd)
    end
  end

  def pbDisplay(text)
    msgwindow = @sprites["messagebox"]
    helpwindow = @sprites["helpwindow"]
    msgwindow.text = text
    msgwindow.visible = true
    helpwindow.visible = false
    tts(text, true)
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      self.update

      inputcheck = Input.trigger?(Input::B) || Input.trigger?(Input::C)
      if !msgwindow.busy? && inputcheck
        pbPlayDecisionSE()
        break
      end
      msgwindow.check_for_resume(inputcheck)
    end
    msgwindow.visible = false
    helpwindow.visible = true
  end

  def pbSwitchBegin(oldid, newid)
    oldsprite = @sprites["pokemon#{oldid}"]
    newsprite = @sprites["pokemon#{newid}"]
    for i in 0...6
      @sprites["pokemon#{i}"].preselected = false
    end
    (264 / SWITCH_SPEED).times do
      oldsprite.x += (oldid & 1) == 0 ? -SWITCH_SPEED : SWITCH_SPEED
      newsprite.x += (newid & 1) == 0 ? -SWITCH_SPEED : SWITCH_SPEED
      Graphics.update
      Input.update
      self.update
    end
  end

  def pbSwitchEnd(oldid, newid)
    oldsprite = @sprites["pokemon#{oldid}"]
    newsprite = @sprites["pokemon#{newid}"]
    oldsprite.pokemon = @party[oldid]
    newsprite.pokemon = @party[newid]
    (264 / SWITCH_SPEED).times do
      oldsprite.x -= (oldid & 1) == 0 ? -SWITCH_SPEED : SWITCH_SPEED
      newsprite.x -= (newid & 1) == 0 ? -SWITCH_SPEED : SWITCH_SPEED
      Graphics.update
      Input.update
      self.update
    end
    for i in 0...6
      @sprites["pokemon#{i}"].switching = false
    end
    pbRefresh
  end

  def pbDisplayConfirm(text)
    msgwindow = @sprites["messagebox"]
    helpwindow = @sprites["helpwindow"]
    ret = -1
    msgwindow.text = text
    msgwindow.visible = true
    helpwindow.visible = false
    tts(text, true)
    using_block(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"), _INTL("No")])) {
      cmdwindow.z = @viewport.z + 1
      cmdwindow.visible = false
      pbBottomRight(cmdwindow)
      cmdwindow.y -= msgwindow.height
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible = true if !msgwindow.busy?
        cmdwindow.update
        self.update

        inputcheck = Input.trigger?(Input::B) || Input.trigger?(Input::C)
        if !msgwindow.busy? && inputcheck
          ret = Input.trigger?(Input::C) && cmdwindow.index == 0
          ret ? pbPlayDecisionSE() : pbPlayCancelSE()
          break
        end
        msgwindow.check_for_resume(inputcheck)
      end
    }
    msgwindow.visible = false
    helpwindow.visible = true
    return ret
  end

  def pbConfirm(text)
    return pbDisplayConfirm(text)
  end

  def pbAnnotate(annot, also_if_not_exist)
    return unless annot

    for i in 0...6
      # Make sure there are annotation needed
      next if !also_if_not_exist && (@sprites["pokemon#{i}"].text.nil? || @sprites["pokemon#{i}"].text == "")
      # Make sure annotation for this mon exists
      next unless annot[i]

      @sprites["pokemon#{i}"].text = annot[i][0]
      @sprites["pokemon#{i}"].textcolors = annot[i][1]
    end
  end

  def pbSummary(pkmnid)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummaryScene.new
    screen = PokemonSummary.new(scene)
    index = screen.pbStartScreen(@party, pkmnid)
    pbSelect(index)
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def pbChooseItem(bag, give: false)
    oldsprites = pbFadeOutAndHide(@sprites)
    @sprites["helpwindow"].visible = false
    @sprites["messagebox"].visible = false
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene, bag)
    ret = give ? screen.pbGiveItemScreen : screen.pbUseItemScreen
    pbFadeInAndShow(@sprites, oldsprites)
    return ret
  end

  def showQuickSummary
    disposeQuickSummary # Dispose previous graphic before drawing new one

    pkmn = @sprites["pokemon#{@activecmd}"].pokemon
    shadow = (pkmn.isShadow? rescue false)
    pkmnindex = @activecmd
    width = Graphics.width / 2 + 6
    xpos = (pkmnindex % 2 == 1) ? 0 : Graphics.width - width
    ypos = 8
    height = Graphics.height - (ypos * 2)
    lineheight = 32

    @qsviewport = Viewport.new(xpos, ypos, width, height)
    @qsviewport.z = 999999
    background = Sprite.new(@qsviewport)
    background.bitmap = Bitmap.new(width, height)
    background.bitmap.fill_rect(0, 0, width, height, Color.new(0, 0, 0))
    background.opacity = 220
    overlaysprite = BitmapSprite.new(width, height, @qsviewport)
    overlay = overlaysprite.bitmap

    texts = []
    # Type
    texts.push(_INTL("Type") + ": " + typeIcons(*pkmn.types))
    # Item
    itemstr = pkmn.item ? getItemName(pkmn.item, short: true) : ColorTags[:Gray2] + _INTL("None")
    texts.push(_INTL("Item") + ": " + itemstr)
    # Ability
    texts.push(_INTL("Ability") + ": " + getAbilityName(pkmn.ability, true))
    # Moves
    texts.push(_INTL("Moves") + ":")
    for moveindex in 0..3
      move = pkmn.moves[moveindex]
      if move
        type = pbMoveSummaryType(move, pkmn)
        movestr = "<icon=minitype#{type}>" + " " + getMoveShortName(move.move)
        movestr += " <r>" + ColorTags[:Gray2] + _INTL("{1}/{2}", move.pp, move.totalpp) if move && move.totalpp > 0
      else
        movestr = ColorTags[:Gray2] + " --"
      end
      texts.push(movestr)
    end
    # Nature
    texts.push(_INTL("Nature") + ": " + (pkmn.canShowNature? ? getNatureName(pkmn.nature) : "???"))
    # EVs
    texts.push(_INTL("EVs") + ": " + "#{pkmn.ev.sum} / #{getPlayerMaxEVs()}")
    # Heart Gauge / EXP
    gaugecolor = shadow ? :Magenta : :Blue2
    texts.push(ColorTags[gaugecolor] + (shadow ? _INTL("Heart") : _INTL("EXP")) + ": ")

    # Add colors and right alignment tags
    texts.map!.with_index { |text, i|
      next text if (4..7).include?(i) # Move names
      next text if i == texts.length - 1 # Heart Gauge / EXP
      next ColorTags[:Blue2] + text.gsub(": ", ":</c3> <r>")
    }

    # Draw text
    xpadding, ypadding = 12, 8
    texts.each_with_index { |text, i|
      smallfont = (4..7).include?(i) # Move names
      smallfont ? pbSetSmallFont(overlay) : pbSetSystemFont(overlay)
      ypos = ypadding + (lineheight * i) + (smallfont ? 4 : 0)
      drawFormattedTextEx(overlay, xpadding, ypos, width - xpadding - 4, text, *ColorArrays[:Default], lineheight)
    }

    # Draw Heart Gauge / EXP bar
    maxgauge = 160
    startx, starty = width - 8 - maxgauge, (lineheight * texts.length) - 10
    colorfill, colorempty = ColorArrays[gaugecolor][0], Color.new(80, 80, 80)
    gaugelevel = shadow ? pkmn.getHeartGaugeBarLevel(maxgauge) : pkmn.getEXPBarLevel(maxgauge)
    overlay.fill_rect(startx, starty, gaugelevel, 4, colorfill)
    overlay.fill_rect(startx + gaugelevel, starty, maxgauge - gaugelevel, 4, colorempty)

    # TTS
    tts(pkmn.name, true)
    texts.each_with_index { |text, i|
      tts(toUnformattedText(text))
      ttsTypeIconsInText(text)
      if i == texts.length - 1 # Heart Gauge / EXP
        gaugetext = shadow ? pkmn.getHeartGaugeBarTextTTS : pkmn.getEXPBarText(tts: true)
        tts(gaugetext)
      end
    }
  end

  def disposeQuickSummary
    return unless showingQuickSummary?
    @qsviewport.dispose
    @qsviewport = nil
  end

  def showingQuickSummary?
    return !@qsviewport.nil?
  end
end


######################################


class PokemonScreen
  attr_accessor :scene

  def initialize(scene, party)
    @party = party
    @scene = scene
  end

  def pbHardRefresh
    @scene.pbHardRefresh
  end

  def pbRefresh
    @scene.pbRefresh
  end

  def pbRefreshSingle(i)
    @scene.pbRefreshSingle(i)
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbShowCommands(helptext, commands, index = 0)
    @scene.pbShowCommands(helptext, commands, index)
  end

  def pbConfirm(text)
    return @scene.pbDisplayConfirm(text)
  end

  def pbSwitch(oldid, newid)
    if oldid != newid
      @scene.pbSwitchBegin(oldid, newid)
      tmp = @party[oldid]
      @party[oldid] = @party[newid]
      @party[newid] = tmp
      @scene.pbSwitchEnd(oldid, newid)
    end
  end

  def pbPokemonGiveScreen(item)
    @scene.pbStartScene(@party, _INTL("Give to which Pokémon?"))
    pkmnid = @scene.pbChoosePokemon
    ret = false
    if pkmnid >= 0
      ret = pbGiveItem(item, @party[pkmnid], self, @scene)
    end
    pbRefreshSingle(pkmnid)
    @scene.pbEndScene
    return ret
  end

  def pbPokemonGiveMailScreen(mailIndex)
    @scene.pbStartScene(@party, _INTL("Give to which Pokémon?"))
    pkmnid = @scene.pbChoosePokemon
    if pkmnid >= 0
      pkmn = @party[pkmnid]
      if !pkmn.item.nil? || pkmn.mail
        pbDisplay(_INTL("This Pokémon is holding an item.  It can't hold mail."))
      elsif pkmn.isEgg?
        pbDisplay(_INTL("Eggs can't hold mail."))
      else
        pbDisplay(_INTL("Mail was transferred from the Mailbox."))
        pkmn.mail = $PokemonGlobal.mailbox[mailIndex]
        pkmn.setItem(pkmn.mail.item)
        $PokemonGlobal.mailbox.delete_at(mailIndex)
        pbRefreshSingle(pkmnid)
      end
    end
    @scene.pbEndScene
  end

  def pbStartScene(helptext, annotations = nil)
    @scene.pbStartScene(@party, helptext, annotations)
  end

  def pbSetHelpText(helptext)
    @scene.pbSetHelpText(helptext)
  end

  def pbChoosePokemon(helptext = nil, shortcut_keys: false)
    @scene.pbSetHelpText(helptext) if helptext
    return @scene.pbChoosePokemon(shortcut_keys: shortcut_keys)
  end

  def pbChooseMove(pokemon, helptext)
    movenames = []
    for i in pokemon.moves
      break if i.move.nil?

      if i.totalpp == 0
        movenames.push(_INTL("{1} (PP: ---)", getMoveName(i.move), i.pp, i.totalpp))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})", getMoveName(i.move), i.pp, i.totalpp))
      end
    end
    return @scene.pbShowCommands(helptext, movenames)
  end

  def pbEndScene
    @scene.pbEndScene
  end

  def pbHideCommands
    @scene.sprites["helpwindow"].visible = false
  end

  # Checks for identical species
  def pbCheckSpecies(array)
    for i in 0...array.length
      for j in i + 1...array.length
        return false if array[i].species == array[j].species
      end
    end
    return true
  end

  # Checks for identical held items
  def pbCheckItems(array)
    for i in 0...array.length
      next if !array[i].hasAnItem?

      for j in i + 1...array.length
        return false if array[i].item == array[j].item
      end
    end
    return true
  end

  def pbPokemonMultipleEntryScreenEx(ruleset)
    annot = []
    statuses = []
    textarray = [
      _INTL("Ineligible"), # not used
      _INTL("Eligible"),
      _INTL("Banned"),
      _INTL("First"),
      _INTL("Second"),
      _INTL("Third"),
      _INTL("Fourth"),
      _INTL("Fifth"),
      _INTL("Sixth"),
    ]
    colorarray = [
      ANNOT_INELIGIBLE_COLORS,
      ANNOT_ELIGIBLE_COLORS,
      ANNOT_INELIGIBLE_COLORS,
      ANNOT_SELECTED_COLORS,
      ANNOT_SELECTED_COLORS,
      ANNOT_SELECTED_COLORS,
      ANNOT_SELECTED_COLORS,
      ANNOT_SELECTED_COLORS,
      ANNOT_SELECTED_COLORS,
    ]
    if !ruleset.hasValidTeam?(@party)
      return nil
    end

    ret = nil
    addedEntry = false
    for i in 0...@party.length
      if ruleset.isPokemonValid?(@party[i])
        statuses[i] = 1
      else
        statuses[i] = 2
      end
    end
    for i in 0...@party.length
      text = textarray[statuses[i]]
      colors = colorarray[statuses[i]]
      annot[i] = [text, colors]
    end
    if Rejuv
      if ruleset.minLength == ruleset.number
        message = _INTL("Choose {1} Pokémon and confirm.", ruleset.number)
      else
        message = _INTL("Choose up to {1} Pokémon and confirm.", ruleset.number)
      end
    else
      message = _INTL("Choose Pokémon and confirm.")
    end
    @scene.pbStartScene(@party, message, annot, true)
    loop do
      realorder = []
      for i in 0...@party.length
        for j in 0...@party.length
          if statuses[j] == i + 3
            realorder.push(j)
            break
          end
        end
      end
      for i in 0...realorder.length
        statuses[realorder[i]] = i + 3
      end
      for i in 0...@party.length
        text = textarray[statuses[i]]
        colors = colorarray[statuses[i]]
        annot[i] = [text, colors]
      end
      @scene.pbAnnotate(annot, true)
      if realorder.length == ruleset.number && addedEntry
        @scene.pbSelect(6)
      end
      if Rejuv
        if ruleset.minLength == ruleset.number
          @scene.pbSetHelpText(_INTL("Choose {1} Pokémon and confirm.", ruleset.number))
        else
          @scene.pbSetHelpText(_INTL("Choose up to {1} Pokémon and confirm.", ruleset.number))
        end
      else
        @scene.pbSetHelpText(_INTL("Choose Pokémon and confirm."))
      end
      pkmnid = @scene.pbChoosePokemon
      addedEntry = false
      if pkmnid == 6 # Confirm was chosen
        ret = []
        for i in realorder
          ret.push(@party[i])
        end
        error = []
        if !ruleset.isValid?(ret, error)
          pbDisplay(error[0])
          ret = nil
        else
          break
        end
      end
      if pkmnid < 0 # Canceled
        break
      end

      cmdEntry = -1
      cmdNoEntry = -1
      cmdSummary = -1
      commands = []
      if (statuses[pkmnid] || 0) == 1
        commands[cmdEntry = commands.length] = _INTL("Entry")
      elsif (statuses[pkmnid] || 0) > 2
        commands[cmdNoEntry = commands.length] = _INTL("No Entry")
      end
      pkmn = @party[pkmnid]
      commands[cmdSummary = commands.length] = _INTL("Summary")
      commands[commands.length] = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?", pkmn.name), commands) if pkmn
      if cmdEntry >= 0 && command == cmdEntry
        if realorder.length >= ruleset.number && ruleset.number > 0
          pbDisplay(_INTL("No more than {1} Pokémon may enter.", ruleset.number))
        else
          statuses[pkmnid] = realorder.length + 3
          addedEntry = true
          pbRefreshSingle(pkmnid)
        end
      elsif cmdNoEntry >= 0 && command == cmdNoEntry
        statuses[pkmnid] = 1
        pbRefreshSingle(pkmnid)
      elsif cmdSummary >= 0 && command == cmdSummary
        @scene.pbSummary(pkmnid)
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbChooseAblePokemon(ableProc, allowIneligible = false, giveAway = true)
    annot = []
    eligibility = []
    for pkmn in @party
      elig = ableProc.call(pkmn)
      eligibility.push(elig)
      text = elig ? _INTL("Able") : _INTL("Not Able")
      colors = elig ? ANNOT_ELIGIBLE_COLORS : ANNOT_INELIGIBLE_COLORS
      annot.push([text, colors])
    end
    ret = -1
    @scene.pbStartScene(@party, @party.length > 1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."), annot)
    loop do
      @scene.pbSetHelpText(@party.length > 1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon
      if pkmnid < 0
        break
      elsif !eligibility[pkmnid] && !allowIneligible
        pbDisplay(_INTL("This Pokémon can't be chosen."))
      else
        if giveAway
          hasOtherAblePokemon = false
          for i in 0...@party.length
            next if i == pkmnid

            hasOtherAblePokemon = true if @party[i] && !@party[i].isEgg? && @party[i].hp > 0
          end
          unless hasOtherAblePokemon
            pbDisplay(_INTL("You can't give away your last non-fainted Pokémon."))
            next
          end
        end
        ret = pkmnid
        break
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbRefreshAnnotations(ableProc) # For after using an evolution stone
    annot = []
    for pkmn in @party
      elig = ableProc.call(pkmn)
      text = elig ? _INTL("Able") : _INTL("Not Able")
      colors = elig ? ANNOT_ELIGIBLE_COLORS : ANNOT_INELIGIBLE_COLORS
      annot.push([text, colors])
    end
    @scene.pbAnnotate(annot, false)
  end

  def duplicatePokemon(pkmn, selected)
    if pbConfirm(_INTL("Are you sure you want to copy this Pokémon?"))
      clonedpkmn = deep_copy(pkmn)
      pbStorePokemon(clonedpkmn)
      pbHardRefresh
      pbDisplay(_INTL("The Pokémon was duplicated."))
    end
  end

  def deletePokemon(pkmnid, selected, heldpoke)
    if pbConfirm(_INTL("Are you sure you want to delete this Pokémon?"))
      @party[pkmnid] = nil
      @party.compact!
      pbHardRefresh
      pbDisplay(_INTL("The Pokémon was deleted."))
    end
  end

  def tryUseHiddenMoveFromParty(pkmn, move)
    return nil unless Kernel.pbCanUseHiddenMove?(pkmn, move, showmessage: true) && Kernel.pbConfirmUseHiddenMove?(pkmn, move)

    @scene.pbEndScene
    return [pkmn, move] unless move == :FLY

    ret = pbSelectFlyLocation()
    if ret
      $PokemonTemp.flydata = ret
      $game_system.bgs_stop
      $game_screen.weather(0, 0, 0)
      return [pkmn, move]
    else
      @scene.pbStartScene(@party, @party.length > 1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      return nil
    end
  end

  def passwordUseTMX(pkmn)
    # Find TMs
    aMoves = []
    aCmds = []
    for machine in $PokemonBag.pockets[4]
      atk = pbGetTM(machine)
      if HiddenMoveHandlers.hasHandler(atk)
        aMoves.push(atk)
        # aCmds.push(_INTL("{1}: {2}", $cache.items[aItem][ITEMNAME], getMoveName(atk)))
        aCmds.push(getMoveName(atk))
      end
    end

    # Adding Headbutt to the list
    atk = :HEADBUTT
    if !aMoves.include?(atk)
      aMoves.push(atk)
      aCmds.push(getMoveName(atk))
    end

    # Adding Dig to the list
    atk = :DIG
    if !aMoves.include?(atk)
      aMoves.push(atk)
      aCmds.push(getMoveName(atk))
    end

    # Adding Teleport to the list
    if Reborn
      atk = :TELEPORT
      aMoves.push(atk)
      aCmds.push(getMoveName(atk))
    end

    # Adding Sweet Scent to the list
    atk = :SWEETSCENT
    if !aMoves.include?(atk)
      aMoves.push(atk)
      aCmds.push(getMoveName(atk))
    end

    # Sort TMs
    counter = 1
    while counter < aCmds.length
      index = counter
      while index > 0
        indexPrev = index - 1

        firstName  = getMoveName(aMoves[indexPrev])
        secondName = getMoveName(aMoves[index])

        firstName = "AAAA" if firstName == "Fly"
        secondName = "AAAA" if secondName == "Fly"

        if firstName > secondName
          aux               = aCmds[index]
          aCmds[index]      = aCmds[indexPrev]
          aCmds[indexPrev]  = aux

          aux               = aMoves[index]
          aMoves[index]     = aMoves[indexPrev]
          aMoves[indexPrev] = aux
        end
        index -= 1
      end
      counter += 1
    end

    # Add "None"
    aMoves.push(-1)
    aCmds.push(_INTL("None"))

    iC = Kernel.pbMessage(_INTL("Which TM should be used?"), aCmds, aCmds.length)
    atk = aMoves[iC]
    return nil if atk == -1

    return tryUseHiddenMoveFromParty(pkmn, atk)
  end

  def pbPokemonScreen
    @scene.pbStartScene(@party, @party.length > 1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."), nil, autoheal: true)
    loop do
      @scene.pbSetHelpText(@party.length > 1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon(false, true, shortcut_keys: true)

      # Shortcut Keys handling
      if pkmnid.is_a?(Array) && pkmnid[0] == 1 # Switch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid[1]
        newpkmnid = @scene.pbChoosePokemon(true, true, 1)
        if newpkmnid >= 0 && newpkmnid != oldpkmnid
          pbSwitch(oldpkmnid, newpkmnid)
        end
      end
      if pkmnid.is_a?(Array) && pkmnid[0] == 2 # Item
        pkmn = @party[pkmnid[1]]
        itemMenu(pkmnid[1], pkmn, quick: true)
      end
      if pkmnid.is_a?(Array) && pkmnid[0] == 3 # Summary
        @scene.pbSummary(pkmnid[1])
      end
      if pkmnid.is_a?(Array) && pkmnid[0] == 4 # Moves
        pkmn = @party[pkmnid[1]]
        pbRelearnMoveScreen(@party, pkmnid[1], relearner: false)
      end
      if pkmnid.is_a?(Array) && pkmnid[0] == 5 # Auto-heal
        fullparty = $Settings.fullAutoHeal == 0
        pkmn = @party[pkmnid[1]]
        unless !fullparty && pkmn.nil?
          party = fullparty ? @party : [pkmn]
          runAutoHeal(@scene, party, fullparty)
        end
      end
      if pkmnid.is_a?(Array) && pkmnid[0] == 6 # Auto-heal options
        cmd = nil
        loop do
          cmd = showAutoHealOptions(cmd)
          break if cmd == :break
        end
      end
      next if pkmnid.is_a?(Array)

      break if pkmnid < 0

      pkmn = @party[pkmnid]

      # Generate menu data via the handler
      commands, _helptexts, actions = MenuHandlers.build(:party_menu, self, @party, pkmnid)

      command = @scene.pbShowCommands(_INTL("Do what with {1}?", pkmn.name), commands)
      if command >= 0 && command < actions.length
        result = actions[command].call(self, @party, pkmnid)

        # SPECIAL CASE: If an effect returns an Array,
        # immediately return it out of the menu loop so the map handles it.
        if result.is_a?(Array) && result.length > 0
          return result
        end
      end
    end
    @scene.pbEndScene
    return nil
  end

  def itemMenu(pkmnid, pkmn, quick: false)
    if quick
      command = pkmn.item.nil? ? 1 : 2 # Give or Take
    else
      command = @scene.pbShowCommands(_INTL("Do what with an item?"), [_INTL("Use"), _INTL("Give"), _INTL("Take"), _INTL("Cancel")])
    end
    case command
      when 0 # Use
        item = @scene.pbChooseItem($PokemonBag)
        if !item.nil?
          pbUseItemOnPokemon(item, pkmn, self)
          pbRefreshSingle(pkmnid)
        end
      when 1 # Give
        item = @scene.pbChooseItem($PokemonBag, give: true)
        if !item.nil?
          pbGiveItem(item, pkmn, self, @scene, zcrystal: pbIsZCrystal?(item))
          pbRefreshSingle(pkmnid)
        end
      when 2 # Take
        pbTakeItem(pkmn, self)
        pbRefreshSingle(pkmnid)
    end
  end
end

def showAutoHealOptions(defaultCmd)
  if defaultCmd.nil?
    cmd = Kernel.pbChoice(_INTL("Edit Auto-Heal List:"), {
      0 => _INTL("Add Items to List"),
      1 => _INTL("Remove Items from List"),
    })
    return :break if cmd.nil?
  else
    cmd = defaultCmd
  end

  colors = isCurrentWindowskinDark ? ColorTags : LightColorTags

  if cmd == 0 # Add
    items = ($PokemonBag.pockets[MEDICINEPOCKET] + $PokemonBag.pockets[BERRYPOCKET]).select { |i| autoHealEligibleItem?(i) }
    items -= ($PokemonGlobal.autoHealItems || [])
    if items.empty?
      Kernel.pbMessage(_INTL("You don't have any items that can be added to the list right now.")) if defaultCmd.nil?
      return nil
    end

    items.sort_by! { |i| getItemName(i) } # Sort eligible items for display right now
    choices = itemChoicesWithQty(items)
    choices[:all] = colors[:Blue2] + _INTL("Add All")
    choice = Kernel.pbChoice(_INTL("Choose an item to add."), choices, advanced: true)
    return nil if choice.nil?

    $PokemonGlobal.autoHealItems = [] if !$PokemonGlobal.autoHealItems
    if choice == :all
      items.each { |i| $PokemonGlobal.autoHealItems.push(i) }
      Kernel.pbMessage(_INTL("All eligible items were added to the list."))
    else
      $PokemonGlobal.autoHealItems.push(choice)
      Kernel.pbMessage(_INTL("{1} was added to the list.", getItemName(choice)))
    end
    $PokemonGlobal.autoHealItems.sort_by! { |i| getItemName(i) } # Sort whitelisted items for display in the future
  else # Remove
    if !$PokemonGlobal.autoHealItems || $PokemonGlobal.autoHealItems.empty?
      Kernel.pbMessage(_INTL("You don't have any items in the list right now.")) if defaultCmd.nil?
      return nil
    end

    choices = itemChoicesWithQty($PokemonGlobal.autoHealItems.each)
    choices[:all] = colors[:Blue2] + _INTL("Remove All")
    choice = Kernel.pbChoice(_INTL("Choose an item to remove."), choices, advanced: true)
    return nil if choice.nil?

    if choice == :all
      $PokemonGlobal.autoHealItems.clear
      Kernel.pbMessage(_INTL("All items were removed from the list."))
    else
      $PokemonGlobal.autoHealItems.delete(choice)
      Kernel.pbMessage(_INTL("{1} was removed from the list.", getItemName(choice)))
    end
  end

  return cmd
end

def autoHealEligibleItem?(item)
  return false if [:SACREDASH, :MAGICMOOMILK].include?(item)
  medicinedata = $cache.items[item].medicine
  return false if !medicinedata
  return medicinedata.revive || medicinedata.hp || medicinedata.status
end

def runAutoHeal(scene, party, fullparty)
  if party.all? { |mon| mon.hp == mon.totalhp && mon.status.nil? }
    fullparty ?
      Kernel.pbMessage(_INTL("Your Pokémon are already healthy!")) :
      Kernel.pbMessage(_INTL("{1} is already healthy!", party[0].name))
    return
  end

  eligibleitems = ($PokemonGlobal.autoHealItems || []).select { |i|
    $PokemonBag.pbQuantity(i) > (pbIsBerry?(i) ? 1 : 0) # always leave 1 of each berry
  }

  useditems = {}
  useditems.default = 0

  for mon in party
    next if mon.hp == mon.totalhp && mon.status.nil?

    # first revive the Pokemon if it's fainted
    if mon.hp == 0
      item = eligibleitems
        .select { |i| $cache.items[i].medicine&.revive }
        .min_by { |i| $cache.items[i].medicine.revive } # Healing amount from least to greatest. Only need one revive item.
      if item
        useAutoHealItem(item, mon, useditems)
      else
        next # don't do anything (KO'd but no Revives)
      end
    end

    # heal status conditions
    if !mon.status.nil?
      item = eligibleitems
        .select { |i| $cache.items[i].medicine&.status == mon.status } # Specific status items
        .first # Only need one status item.
      if !item # There wasn't a specific status curing item to use
        item = eligibleitems
          .select { |i| $cache.items[i].medicine&.status == :FULLHEAL }
          .reject { |i| $cache.items[i].medicine.hp } # Handle Full Restores in the HP section
          .first # Only need one status item.
      end
      if item
        confirm = (mon.status == :BURN && mon.item == :FLAMEORB) || (mon.status == :POISON && mon.item == :TOXICORB)
        if !confirm || scene.pbDisplayConfirm(_INTL("Would you like to use {1} on {2}?", getItemName(item, :a), mon.name))
          useAutoHealItem(item, mon, useditems)
        end
      end
    end

    # heal HP
    while mon.hp < mon.totalhp
      hptoheal = mon.totalhp - mon.hp
      items = eligibleitems
        .select { |i| $cache.items[i].medicine&.hp }
        .sort_by { |i| getItemHP($cache.items[i].medicine.hp, mon.totalhp) } # Heal amount from least to greatest.
      break if items.empty?

      # Find the first item that fully heals the Pokemon.
      item = items.find { |i| getItemHP($cache.items[i].medicine.hp, mon.totalhp) >= hptoheal }

      # Use the best healing item you have if you can't fully heal the Pokemon.
      item = items.last if item.nil?
      useAutoHealItem(item, mon, useditems)
    end
  end

  unless useditems.empty?
    scene.pbRefresh
    pbSEPlay("SFX - Quick Recovery", 50)
    message = fullparty ? _INTL("Your Pokémon were healed!") : _INTL("{1} was healed!", party[0].name)
    pbUsedItemsDisplay(message, useditems)
  else
    message = fullparty ?
      _INTL("You don't have any items that can be used to auto-heal your Pokémon!") :
      _INTL("You don't have any items that can be used to auto-heal {1}!", party[0].name)
    Kernel.pbMessage(message + "\n<o=128>" + _INTL("(Press W to edit the auto-heal item list.)"))
  end
end

def useAutoHealItem(item, mon, useditems)
  ItemHandlers.triggerUseOnPokemon(item, mon, SceneStub.new)
  $PokemonBag.pbDeleteItem(item)
  useditems[item] += 1
end

class SceneStub
  def pbDisplay(*args); end
  def pbRefresh; end
  def pbHardRefresh; end

  def pbChooseMove(pokemon, helptext) # Needed to make PP restoring items (Leppa Berry) work
    move = pokemon.moves.find_index { |m| m.pp < m.totalpp }
    return move || -1
  end
end

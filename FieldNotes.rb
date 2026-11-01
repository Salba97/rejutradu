Field_Note_Header_Coords = [2, -18, 300, 64]
Field_Note_Header_Colors = [Color.new(248, 248, 248), Color.new(0, 0, 0)]
Field_Note_MainMenu_Y = 46
Field_Note_BG_Y = 30
Field_Note_Window_Y = 46

# Field Catalogue class. Based on xLed's Jukebox Scene class.
class Scene_FieldNotes
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
    @menu = buildFieldMenu
    @menu_index += 1 if @menu[@menu_index][:skip]
  end

  def buildFieldMenu
    menu = []
    general = { label: ColorTags[:Yellow] + _INTL("General"), field: :INDOOR }
    menu.push(general)

    default = Reborn ? :type : :number
    sorttype = $PokemonGlobal.fieldNoteSorting || default
    if sorttype == :type
      fields = [
        ColorTags[:Blue2] + _INTL("Elemental Fields"), *getFieldsByType(:Elemental),
        ColorTags[:Green2] + _INTL("Telluric Fields"), *getFieldsByType(:Telluric),
        ColorTags[:Red] + _INTL("Synthetic Fields"), *getFieldsByType(:Synthetic),
        ColorTags[:Magenta] + _INTL("Magical Fields"), *getFieldsByType(:Magical),
      ]
    else
      fields = pbFieldSymbols # already sorted by number
      fields.sort_by! { |field| getFieldName(field) } if sorttype == :name
    end
    seenFields = checkSeenFields.keys.collect { |i| fieldIDToSym(i) }

    for field in fields
      if field.is_a?(String) # category labels when sorting by type
        item = { label: field, skip: true }
      else
        prefix = sorttype == :number ? symToFieldID(field).to_s + ". " : (sorttype == :type ? "      " : "")
        if seenFields.include?(field)
          item = { label: prefix + getFieldName(field), field: field }
        else
          item = { label: ColorTags[:Gray2] + prefix + "???" }
        end
      end
      menu.push(item)
    end

    back = { label: ColorTags[:Gray2] + _INTL("Back"), back: true }
    menu.push(back)
    return menu
  end

  #-----------------------------------------------------------------------------
  # * Main Processing
  #-----------------------------------------------------------------------------
  def main
    # Makes the text window
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["background"] = IconSprite.new(0, 0)
    bgfilename = Desolation ? "Graphics/Pictures/navbgFieldNotes" : "Graphics/Pictures/navbg"
    @sprites["background"].setBitmap(bgfilename)
    @sprites["background"].z = 255
    sortfilename = "Graphics/Pictures/navbgsort"
    if pbResolveBitmap(sortfilename)
      @sprites["sort"] = IconSprite.new(102, 324)
      @sprites["sort"].setBitmap(sortfilename)
      @sprites["sort"].z = 255
    end
    @choices = @menu.collect { |field| field[:label] }
    @sprites["command_window"] = Window_CommandPokemonWhiteArrow.newWithSize(@choices, 94, Field_Note_MainMenu_Y, 324, 288, colors: ColorArrays[:Default])
    @sprites["command_window"].windowskin = nil
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].z = 256
    render_header
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepares for transition
    Graphics.freeze
    # Disposes the windows
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def render_header
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(_INTL("Field Notes"), *Field_Note_Header_Coords, @viewport)
    @sprites["header"].baseColor = Field_Note_Header_Colors[0]
    @sprites["header"].shadowColor = Field_Note_Header_Colors[1]
    @sprites["header"].windowskin = nil
  end

  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    pbUpdateSpriteHash(@sprites)

    manualTTS = false
    if Input.repeat?(Input::UP) || Input.repeat?(Input::L)
      menuindex = @sprites["command_window"].index
      item = @menu[menuindex]
      if item[:skip] # Skip category labels
        @sprites["command_window"].index -= 1
        @sprites["command_window"].index = Input.trigger?(Input::UP) ? @menu.size - 1 : 1 if menuindex == 0
        manualTTS = true
      end
    end
    if Input.repeat?(Input::DOWN) || Input.repeat?(Input::R)
      menuindex = @sprites["command_window"].index
      item = @menu[menuindex]
      if item[:skip] # Skip category labels
        @sprites["command_window"].index += 1
        manualTTS = true
      end
    end
    # Category labels get interrupted instantly, so it's not a problem
    tts(@choices[@sprites["command_window"].index].gsub(/<\/?c3(?:=[0-f]+,[0-f]+)?>/, ""), true) if manualTTS

    # update command window and the info if it's active
    if @sprites["command_window"].active
      update_command
      return
    end
  end

  #-----------------------------------------------------------------------------
  # * Command controls
  #-----------------------------------------------------------------------------
  def update_command
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Switch to map screen
      pbPlayCancelSE()
      $scene = Scene_Pokegear.new(:notes)
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Branch by command window cursor position
      menuindex = @sprites["command_window"].index
      item = @menu[menuindex]
      if item[:back]
        # Switch to map screen
        pbPlayCancelSE()
        $scene = Scene_Pokegear.new(:notes)
        return
      elsif item[:field]
        pbPlayDecisionSE()
        $scene = Scene_FieldNotes_Info.new(@menu, menuindex)
      else
        pbPlayBuzzerSE()
      end
    end
    # Sort controls
    sortMenu(:name) if Input.trigger?(Input::X)
    sortMenu(:type) if Input.trigger?(Input::A)
    sortMenu(:number) if Input.trigger?(Input::Y)
    # TTS sort controls
    if Input.triggerex?(Input::F2)
      ttsSortControls(:name, :type, :number)
    end
  end

  def sortMenu(sorttype)
    return if $PokemonGlobal.fieldNoteSorting == sorttype

    $PokemonGlobal.fieldNoteSorting = sorttype
    pbPlayDecisionSE()
    tts(sorttype == :name ? _INTL("Sorted by name") : (sorttype == :type ? _INTL("Sorted by type") : _INTL("Sorted by number")), true)
    $scene = Scene_FieldNotes.new
  end
end

#-----------------------------------------------------------------------------
# * Determines which Fields the trainer has data for
#-----------------------------------------------------------------------------
def checkSeenFields
  # puts $Unidata[:fieldNotes]
  fieldSeen = {}
  for i in 1..TOTALFIELDS
    if $game_switches[$cache.FEData[fieldIDToSym(i)].fieldAppSwitch]
      fieldSeen.store(i, true)
    end
  end
  if $Unidata[:fieldNotes] != nil
    fieldSeen.merge!($Unidata[:fieldNotes])
    if fieldSeen.length > $Unidata[:fieldNotes].length
      $Unidata[:fieldNotes] = fieldSeen
    end
    if Desolation
      for i in 1..TOTALFIELDS
        $game_switches[$cache.FEData[fieldIDToSym(i)].fieldAppSwitch] = $Unidata[:fieldNotes].keys.include?(i)
      end
    end
  end
  return fieldSeen
end

def prepareFieldNoteInfo(fieldeffect, overlay_notes: false)
  fieldnotes = $cache.FENotes.find_all { |note|
    note.fieldeffect == fieldeffect && note.overlay == overlay_notes && (note.condition.nil? || eval(note.condition))
  }
  fieldnotes.prepend(introMessageNote(fieldeffect)) unless fieldeffect == :INDOOR || overlay_notes
  choices = fieldnotes.map { |note| pbGetMessageFromHash(:FieldNotes, note.text) }
  return fieldnotes, choices
end

def prepareFieldNoteCommand(fieldnotes, viewport)
  sprite = Window_FieldEffectNotes.newWithSize(fieldnotes, 8, Field_Note_Window_Y, Graphics.width - 8, 288, viewport, tts: false, colors: ColorArrays[:Default])
  sprite.windowskin = nil
  sprite.z = 256
  return sprite
end

def prepareFieldNoteSprites(viewport, fieldnotes, fieldeffect, overlay_notes: false, in_battle: false)
  sprites = {}
  sprites["fieldbackground"] = IconSprite.new(0, Field_Note_BG_Y, viewport)
  background = notesDisplayGraphic(fieldeffect)
  sprites["fieldbackground"].setBitmap(background)
  sprites["fieldbackground"].z = 254
  sprites["fieldbackground"].opacity -= 200
  sprites["background"] = IconSprite.new(0, 0, viewport)
  sprites["background"].setBitmap("Graphics/Pictures/fieldapp")
  sprites["background"].z = 255

  # Graphic to indicate input for overlay toggle (graphic exists only in Rejuv currently)
  if Rejuv && Overlays && $cache.FEData[fieldeffect].overlay && !in_battle
    sprites["topbar"] = IconSprite.new(0, 0, @viewport)
    sprites["topbar"].setBitmap("Graphics/Pictures/Pokegear/bar#{overlay_notes ? "Overlay" : "Field"}")
    sprites["topbar"].z = 256
  end

  header = fieldeffect == :INDOOR ? _INTL("General") : getFieldName(fieldeffect)
  header += " " + _INTL("Overlay") if overlay_notes
  sprites["header"] = Window_UnformattedTextPokemon.newWithSize(header, *Field_Note_Header_Coords, viewport)
  sprites["header"].baseColor = Field_Note_Header_Colors[0]
  sprites["header"].shadowColor = Field_Note_Header_Colors[1]
  sprites["header"].windowskin = nil
  sprites["header"].z = 257

  sprites["command_window"] = prepareFieldNoteCommand(fieldnotes, viewport)
  return sprites
end

def notesDisplayGraphic(field)
  field = :FLOWERGARDEN4 if field == :FLOWERGARDEN1
  field = :CONCERT4 if field == :CONCERT1
  return "Graphics/Battlebacks/battlebg" + $cache.FEData[field].graphic[0]
end

def ttsNote(note, interrupt = false)
  return if $tts.nil? && !DEV_TTS_TESTING # For efficiency

  text = pbGetMessageFromHash(:FieldNotes, note.text)
  text = text.gsub(/<\/?c(?:=\w+)?>/, "") # Remove opening and closing color tags
  text = text.gsub(" . . .", "") # Remove " . . .", "Press to read more" message is handled later

  defaults = {
    "fieldChange" => "changes to",
    "fieldUp" => "boosted by",
    "fieldRedUp" => "boosted",
    "fieldDown" => "lowered by",
    "fieldPlus" => "additionally",
    "fieldNoSleep" => "unable to sleep",
    "fieldNoFreeze" => "unable to freeze",
    "fieldAllStat" => "random status",
    "fieldBurn" => "Burn status",
    "fieldFaint" => "faint",
    "fieldFreeze" => "Freeze status",
    "fieldParalyze" => "Paralyze status",
    "fieldPoisonStatus" => "Poison status",
    "fieldSleep" => "Sleep status",
  }
  $cache.types.each { |type, data| defaults["type#{type}"] = "#{data.name} type" }
  pattern = /<icon=(\w+)(.*?)>/
  text = text.gsub(pattern) do |match|
    icon = $1
    tts = $2
    tts_content = tts[/,tts="([^"]*)"/, 1]
    default = defaults[icon] || "#{icon}"
    tts_content ? tts_content : default
  end

  text = noteReplace(text)

  for stagetext in [note.cogwheeltext, note.note] # Both cogwheeltext and note are used exclusively for indicating stages
    text += ", Stage " + toUnformattedText(stagetext) if stagetext && stagetext != ""
  end

  text += ", Press to read more" if note.elaboration != ""

  tts(text, interrupt)
end

def noteReplace(note)
  text = note

  strings = {
    "Sp.Atk" => "Special Attack",
    "Sp.Def" => "Special Defense",
    "Atk" => "Attack",
    "Def" => "Defense",
    "???" => "Question Marks",
    " vs " => " versus ",
  }
  text = strings.inject(text) { |str, (word, replace)| str.gsub(word, replace) }
  text = text.gsub(/x(\d+\.?\d*)/) { |match| "#{$1} times" } # Replace multipliers
  text = text.gsub(/Defense(?![\/s]\b)/, "Def") # Fix Defense text

  return text
end

class Window_FieldEffectNotes < Window_CommandPokemonWhiteArrow
  attr_accessor :notes

  def initialize(notes, width, isCursorSmall = false, tts: true, defaultIndex: 0, colors: nil)
    @notes = notes
    super(notes.map { |note| pbGetMessageFromHash(:FieldNotes, note.text) }, width, isCursorSmall, tts: tts, defaultIndex: defaultIndex, colors: colors)
  end

  def drawCursor(index, rect)
    if self.index == index
      pbCopyBitmap(self.contents, @selarrow.bitmap, rect.x, rect.y)
    end
    return Rect.new(rect.x + 24, rect.y, rect.width - 24, rect.height)
  end

  def refresh
    @item_max = itemCount()
    dwidth = self.width - self.borderX
    dheight = self.height - self.borderY
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    for i in 0...@item_max
      if i < self.top_item || i > self.top_item + self.page_item_max
        next
      end

      rect = itemRect(i)
      drawItem(i, @item_max, rect)
      drawNote(i, rect)
      drawCogWheel(i, cogwheelRect(i))
    end
  end

  def drawNote(item, rect)
    note = @notes[item]
    return if note.note.nil?

    pbSetSmallFont(self.contents)
    text = note.note
    chars = getFormattedText(self.contents, rect.x + 2, rect.y + 6, rect.width - 60, rect.height, sprintf("<r>%s</r>", text), rect.height, true, true)
    chars.each { |ch| ch[9] = getAutoShadowColor(ch[8]) }
    drawFormattedChars(self.contents, chars)
  end

  def cogwheelRect(item)
    note = @notes[item]
    if item < 0 || item >= @item_max || item < self.top_item || item > self.top_item + self.page_item_max || (note.elaboration == "" && note.cogwheeltext == "")
      return Rect.new(0, 0, 0, 0)
    else
      x = 414
      y = item / @column_max * @row_height - @virtualOy
      return Rect.new(x, y, 40, @row_height)
    end
  end

  def drawCogWheel(item, rect)
    note = @notes[item]
    return if note.elaboration == "" && note.cogwheeltext == ""

    if note.elaboration != "" && note.cogwheeltext == ""
      cogwheel = AnimatedBitmap.new("Graphics/Icons/fieldTabStar")
      pbCopyBitmap(self.contents, cogwheel.bitmap, rect.x, rect.y)
      return
    end

    pbSetSmallFont(self.contents)
    yoffset = Reborn ? 4 : 6
    text = note.cogwheeltext
    text += "<icon=fieldTabStarEmpty>" if note.elaboration != ""
    chars = getFormattedText(self.contents, rect.x + 2, rect.y + yoffset, rect.width, rect.height, text, rect.height, true, true)
    chars.each { |ch| ch[9] = getAutoShadowColor(ch[8]) }
    case chars.length
      when 1, 2 then boxtype = "fieldTab1"
      when 3, 4 then boxtype = "fieldTab2"
      when 5, 6 then boxtype = "fieldTab3"
      else
        boxtype = "fieldTab4"
    end
    textbox = AnimatedBitmap.new("Graphics/Icons/#{boxtype}")
    pbCopyBitmap(self.contents, textbox.bitmap, rect.x, rect.y)
    drawFormattedChars(self.contents, chars)
  end
end

class Scene_FieldNotes_Info
  attr_accessor :from_index

  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #-----------------------------------------------------------------------------
  def initialize(menu, menu_index)
    @menu = menu
    @menu_index = menu_index
    @fieldeffect = menu[menu_index][:field]
    @overlay_notes = false
  end

  #-----------------------------------------------------------------------------
  # * Main Processing
  #-----------------------------------------------------------------------------
  def main
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @fieldnotes, @choices = prepareFieldNoteInfo(@fieldeffect)
    @sprites = prepareFieldNoteSprites(@viewport, @fieldnotes, @fieldeffect)
    render_header
    ttsOverlayToggle
    ttsNote(@fieldnotes[0])
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def render_header
    # for overrides
  end

  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    pbUpdateSpriteHash(@sprites)
    # update command window and the info if it's active
    if Input.trigger?(Input::B)
      # Switch to map screen
      pbPlayCancelSE()
      $scene = Scene_FieldNotes.new(@menu_index)
      return
    end
    if Input.trigger?(Input::C)
      # Branch by command window cursor position
      fieldindex = @sprites["command_window"].index
      if !@fieldnotes[fieldindex].nil? && @choices[fieldindex] != @choices.length && @fieldnotes[fieldindex].elaboration != ""
        tts(noteReplace(@fieldnotes[fieldindex].translation))
        Kernel.pbMessage(@fieldnotes[fieldindex].translation, tts: false)
      elsif @choices[fieldindex] == @choices.length
        # Switch to map screen
        $scene = Scene_Pokegear.new(:notes)
        return
      end
    end
    if Input.trigger?(Input::RIGHT) || Input.repeat?(Input::RIGHT)
      changeField(1)
    elsif Input.trigger?(Input::LEFT) || Input.repeat?(Input::LEFT)
      changeField(-1)
    end
    if Input.repeat?(Input::UP) || Input.repeat?(Input::L) || Input.repeat?(Input::DOWN) || Input.repeat?(Input::R)
      fieldindex = @sprites["command_window"].index
      ttsNote(@fieldnotes[fieldindex], true)
    end
    # Toggle overlay notes (notes exist only in Rejuv currently)
    if [Input::X, Input::Y, Input::Z, Input::A].any?{ |i| Input.trigger?(i) } && Rejuv && Overlays && $cache.FEData[@fieldeffect].overlay
      toggleOverlay
    end
  end

  def changeField(increment)
    oldindex = @menu_index
    loop do
      @menu_index += increment
      if @menu_index >= @menu.length
        @menu_index = 0
      elsif @menu_index < 0
        @menu_index = @menu.length - 1
      end
      break unless @menu[@menu_index][:field].nil?
    end
    return if @menu_index == oldindex

    @fieldeffect = @menu[@menu_index][:field]
    @overlay_notes = false
    redraw
  end

  def toggleOverlay
    @overlay_notes = !@overlay_notes
    redraw
  end

  def redraw
    pbPlayDecisionSE()
    pbDisposeSpriteHash(@sprites)
    @fieldnotes, @choices = prepareFieldNoteInfo(@fieldeffect, overlay_notes: @overlay_notes)
    @sprites = prepareFieldNoteSprites(@viewport, @fieldnotes, @fieldeffect, overlay_notes: @overlay_notes)
    render_header

    tts(@sprites["header"].text, true)
    ttsOverlayToggle
    ttsNote(@fieldnotes[0])
  end

  def ttsOverlayToggle
    tts(_INTL("Press A to switch to {1}.", @overlay_notes ? _INTL("Field") : _INTL("Overlay"))) if Rejuv && Overlays && $cache.FEData[@fieldeffect].overlay # -Currently- only for Rejuv
  end
end

class Scene_FieldNotes_Battle
  def pbStartScene(fieldhash)
    @index = 0
    @commandindex = []
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @fieldlayers = []
    @fieldlayers.push(fieldhash[:overlay]) if fieldhash[:overlay]
    fieldhash[:fields].each { |fe| @fieldlayers.push(fe) } if fieldhash[:fields]
    @fieldlayers.map! { |fe| fieldToFirstStage(fe) }

    @battle_overlay = fieldhash[:overlay]

    @fieldnotes = []
    @choices = []
    for i in 0..@fieldlayers.length
      fe = @fieldlayers[i]
      @fieldnotes[i], @choices[i] = prepareFieldNoteInfo(fe, overlay_notes: fe == @battle_overlay)
    end

    @sprites = prepareFieldNoteSprites(@viewport, @fieldnotes[0], @fieldlayers[0], overlay_notes: @fieldlayers[0] == @battle_overlay, in_battle: true)
    render_header

    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].x = 8
    @sprites["leftarrow"].y = 176
    @sprites["leftarrow"].z = 256
    @sprites["leftarrow"].play
    @sprites["leftarrow"].visible = false
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"].x = 456
    @sprites["rightarrow"].y = 176
    @sprites["rightarrow"].z = 256
    @sprites["rightarrow"].play
    @sprites["rightarrow"].visible = false

    ttsFieldName
    ttsNote(@fieldnotes[@index][0])

    pbFadeInAndShow(@sprites)
    loop do
      Graphics.update
      Input.update
      self.update
      return if Input.trigger?(Input::B) || Input.trigger?(Input::Z)
    end
  end

  def render_header
    # for overrides
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    pbUpdateSpriteHash(@sprites)
    # update command window and the info if it's active
    if Input.trigger?(Input::B) || Input.trigger?(Input::Y)
      pbPlayCancelSE()
      return
    end
    if Input.trigger?(Input::C)
      # Branch by command window cursor position
      fieldnotes = @fieldnotes[@index]
      choices = @choices[@index]
      noteindex = @sprites["command_window"].index
      if choices[noteindex] == choices.length
        return
      elsif !fieldnotes[noteindex].nil? && fieldnotes[noteindex].elaboration != ""
        tts(noteReplace(fieldnotes[noteindex].translation))
        Kernel.pbMessage(fieldnotes[noteindex].translation, tts: false)
      end
    end
    @sprites["leftarrow"].visible = @index != 0
    @sprites["rightarrow"].visible = @index != @fieldlayers.length - 1
    if Input.trigger?(Input::LEFT)
      pbSwitchFieldNotes(-1)
    elsif Input.trigger?(Input::RIGHT)
      pbSwitchFieldNotes(1)
    end
    if Input.repeat?(Input::UP) || Input.repeat?(Input::L) || Input.repeat?(Input::DOWN) || Input.repeat?(Input::R)
      fieldnotes = @fieldnotes[@index]
      noteindex = @sprites["command_window"].index
      ttsNote(fieldnotes[noteindex], true)
    end
  end

  def pbSwitchFieldNotes(increment)
    return if (increment < 0 && @index <= 0) || (increment > 0 && @index >= @fieldlayers.length - 1)

    pbPlayDecisionSE()
    @commandindex[@index] = @sprites["command_window"].index
    @index += increment

    background = notesDisplayGraphic(@fieldlayers[@index])
    @sprites["fieldbackground"].setBitmap(background)

    header = getFieldName(@fieldlayers[@index])
    header += " " + _INTL("Overlay") if @fieldlayers[@index] == @battle_overlay
    @sprites["header"].text = header

    @sprites["command_window"].dispose
    @sprites["command_window"] = prepareFieldNoteCommand(@fieldnotes[@index], @viewport)
    @sprites["command_window"].index = @commandindex[@index] if @commandindex[@index]

    ttsFieldName
    ttsNote(@fieldnotes[@index][@sprites["command_window"].index])
  end

  def ttsFieldName
    string = @sprites["header"].text
    string += ", Layer #{@index + 1} of #{@fieldlayers.length}" if @fieldlayers.length > 1
    tts(string, true)
  end
end

class PBFieldNote
  attr_accessor :fieldeffect
  attr_accessor :text
  attr_accessor :elaboration
  attr_accessor :cogwheeltext
  attr_accessor :note
  attr_accessor :arguments
  attr_accessor :condition
  attr_accessor :overlay

  # elaboration can contain placeholders {movesAnd}, {movesOr}, {moves}, {abilities}.
  # Those placeholders will be replaced by translated lists of moves or abilities.
  # Lists of moves / abilities symbols should be provided in arguments.
  def initialize(fieldeffect, text, elaboration = "", cogwheeltext = "", note: "", arguments: [], condition: nil)
    @fieldeffect = fieldeffect
    @text = text
    @elaboration = elaboration
    @cogwheeltext = applyStageColors(cogwheeltext)
    @note = applyStageColors(note)
    @arguments = arguments
    @condition = condition
    @overlay = false
  end

  def self.newOV(*args, **kwargs)
    v = self.new(*args, **kwargs)
    v.overlay = true
    return v
  end

  def translation
    template = pbGetMessageFromHash(:FieldNotes, @elaboration)
    i = 0
    return template.gsub(/\{movesAnd\}|\{movesOr\}|\{moves\}|\{abilitiesAnd\}|\{abilitiesOr\}|\{abilities\}|\{naturalType\}|\{overlayList\}/) do |placeholder|
      replacement = ""
      case placeholder
      when "{movesAnd}"
        replacement = listMoves(@arguments[i], _INTL("and"))
      when "{movesOr}"
        replacement = listMoves(@arguments[i], _INTL("or"))
      when "{moves}"
        replacement = listMoves(@arguments[i], "")
      when "{abilitiesAnd}"
        replacement = listAbilities(@arguments[i], _INTL("and"))
      when "{abilitiesOr}"
        replacement = listAbilities(@arguments[i], _INTL("or"))
      when "{abilities}"
        replacement = listAbilities(@arguments[i], "")
      when "{naturalType}"
        replacement = getTypeName($cache.FEData[@fieldeffect].mimicry)
      when "{overlayList}"
        replacement = $cache.FEData.keys.filter{ |fe| $cache.FEData[fe].overlay }.map{ |fe| getFieldName(fe) }.join(", ")
      end
      i += 1
      next replacement
    end
  end

  def applyStageColors(text)
    newtext = ""
    text.each_char { |char|
      newchar = case char
        when "1" then "<c=7cfc00>1</c>"
        when "2" then "<c=ffb347>2</c>"
        when "3" then "<c=ec5800>3</c>"
        when "4" then "<c=ff2800>4</c>"
        when "5" then "<c=ff00ff>5</c>"
        else char
      end
      newtext += newchar
    }
    return newtext
  end
end

def fieldMoves(*args)
  return FIELDEFFECTS.dig(*args)
end

def listMoves(moves, lastsep = "")
  moves = moves.dup
  moves.filter!{ |id| !$cache.moves[id].nil? }
  moves.filter!{ |id| !PBStuff::Gen9Moves.include?(id) } if Gen < 9
  moves.filter!{ |id| !PBStuff::Gen8Moves.include?(id) } if Gen < 8
  moves.filter!{ |id| $cache.moves[id].type != :SHADOW }
  moves.map!{ |id| getMoveName(id) }.sort!.uniq!
  return joinStrings(moves, lastsep)
end

def listAbilities(abilities, lastsep = "")
  abilities = abilities.dup
  abilities.filter!{ |id| !$cache.abil[id].nil? }
  abilities.filter!{ |id| !PBStuff::Gen9Abilities.include?(id) } if Gen < 9
  abilities.filter!{ |id| !PBStuff::Gen8Abilities.include?(id) } if Gen < 8
  abilities.map!{ |id| getAbilityName(id) }.sort!.uniq!
  return joinStrings(abilities, lastsep)
end

def naturePower(fieldeffect)
  # Intentionally not using getMoveName to avoid translation
  move = FIELDEFFECTS.dig(fieldeffect, :naturePower)
  return $cache.moves[move].getFullName
end

def naturePowerNote(field)
  return PBFieldNote.new(field, "Nature Power <icon=fieldChange> #{naturePower(field)}")
end

def naturalTypeNotes(field)
  type = FIELDEFFECTS.dig(field, :mimicry)
  return [PBFieldNote.new(field, "Natural type <icon=fieldChange> #{typeIcon(type)} . . .", "Camouflage and Mimicry make the user {naturalType}-type. Terrain Pulse also becomes {naturalType}-type. Shelter halves {naturalType}-type damage.")] if Rejuv
  return [
    PBFieldNote.new(field, "Camouflage <icon=fieldChange> #{typeIcon(type)}", condition: "Gen < 8"),
    PBFieldNote.new(field, "Natural type <icon=fieldChange> #{typeIcon(type)} . . .", "Camouflage and Mimicry make the user {naturalType}-type. Terrain Pulse also becomes {naturalType}-type.", condition: "Gen >= 8"),
  ]
end

# Added to field notes dynamically, does not need compilation/translation
def introMessageNote(field)
  msg = pbGetMessageFromHash(:FieldMessages, $cache.FEData[field].message)
  msg.gsub!("\n\n", "\n")

  if field == :DARKNESS1 # Darkness field has different intro messages for different stages
    msg2 = pbGetMessageFromHash(:FieldMessages, $cache.FEData[:DARKNESS2].message)
    msg3 = pbGetMessageFromHash(:FieldMessages, $cache.FEData[:DARKNESS3].message)
    return PBFieldNote.new(field, "<c=orange>\"#{msg.split("|").first} . . .\"</c>", "(1) #{msg.gsub("|", "")}\n(2) #{msg2}\n(3) #{msg3}")
  end

  if msg.include?("|")
    return PBFieldNote.new(field, "<c=orange>\"#{msg.split("|").first} . . .\"</c>", msg.gsub("|", ""))
  else
    return PBFieldNote.new(field, "<c=orange>\"#{msg}\"</c>")
  end
end

def fieldToFirstStage(field)
  [PBFields::FLOWERGARDEN, PBFields::CONCERT, PBFields::DARKNESS].each { |array|
    return array.first if array.include?(field)
  }
  return field
end

# Returns valid field symbols
# Doesn't include :INDOOR
# In case of fields with stages, includes the first stage but not the higher levels.
def pbFieldSymbols
  return FieldIDToSym.values - [:INDOOR]
end

def getFieldsByType(type)
  seed = { Elemental: :ELEMENTALSEED, Telluric: :TELLURICSEED, Synthetic: :SYNTHETICSEED, Magical: :MAGICALSEED }[type]
  fields = pbFieldSymbols.select { |field| $cache.FEData[field].seeddata[:seedtype] == seed }
  fields.sort_by! { |field| getFieldName(field) }
  return fields
end

def fieldIDToSym(id)
  return FieldIDToSym[id] || :INDOOR
end

def symToFieldID(sym)
  return FieldIDToSym.invert[sym] || 0
end

def symToFieldIDRMXP # wouldn't fit lol
  return symToFieldID($game_variables[:Forced_Field_Effect])
end

class PokemonGlobalMetadata
  attr_accessor :fieldNoteSorting
end

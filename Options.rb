class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions
  attr_accessor :options

  NAME_COLOR = :Orange2
  SEL_COLOR = :Red2
  BACK_COLOR = :Gray2
  HEAD_COLOR = :ShardBlue

  def initialize(options, x, y, width, height)
    @options = options
    @optvalues = []
    @mustUpdateOptions = false
    for i in 0...@options.length
      @optvalues[i] = 0
    end
    super(x, y, width, height)
  end

  def [](i)
    return @optvalues[i]
  end

  def []=(i, value)
    @optvalues[i] = value
    refresh
  end

  def itemCount
    return @options.length
  end

  def atSectionHeader?
    return @options[self.index].is_a?(String) && self.index != @options.length - 1
  end

  def drawItem(index, count, rect)
    colorarrays = isDarkWindowskin(self.windowskin) ? ColorArrays : LightColorArrays
    rect = drawCursor(index, rect)
    if @options[index].is_a?(String) # Headers and 'Back'
      colors = index == @options.length - 1 ? colorarrays[BACK_COLOR] : colorarrays[HEAD_COLOR]
      optionname = @options[index]
      startX = rect.x
      optionwidth = Graphics.width
    else
      colors = colorarrays[NAME_COLOR]
      optionname = @options[index].name
      offset = 8
      startX = rect.x + offset
      optionwidth = ((rect.width - offset) * 9.5 / 20)
    end
    pbDrawShadowText(self.contents, startX, rect.y, optionwidth, rect.height, optionname, *colors)
    self.contents.draw_text(startX, rect.y, optionwidth, rect.height, optionname)
    return if @options[index].is_a?(String)

    sel_colors = colorarrays[SEL_COLOR]
    if @options[index].is_a?(EnumOption)
      if @options[index].values.length > 1
        totalwidth = 0
        for value in @options[index].values
          totalwidth += self.contents.text_size(value).width
        end
        spacing = (optionwidth - totalwidth) / (@options[index].values.length - 1)
        spacing = 0 if spacing < 0
        xpos = optionwidth + startX
        ivalue = 0
        for value in @options[index].values
          colors = ivalue == self[index] ? sel_colors : [self.baseColor, self.shadowColor]
          pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value, *colors)
          self.contents.draw_text(xpos, rect.y, optionwidth, rect.height, value)
          xpos += self.contents.text_size(value).width
          xpos += spacing
          ivalue += 1
        end
      else
        colors = [self.baseColor, self.shadowColor]
        pbDrawShadowText(self.contents, startX + optionwidth, rect.y, optionwidth, rect.height, optionname, *colors)
      end
    elsif @options[index].is_a?(NumberOption)
      value = @options[index].format.call(@options[index].optstart + self[index])
      xpos = optionwidth + startX
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value, *sel_colors)
    else
      value = @options[index].values[self[index]]
      xpos = optionwidth + startX
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value, *sel_colors)
      self.contents.draw_text(xpos, rect.y, optionwidth, rect.height, value)
    end
  end

  def update
    oldindex = self.index

    if Input.repeat?(Input::DOWN)
      self.index += 1
      self.index += 1 while atSectionHeader?
      self.index = 0 if self.index > @options.length - 1
      self.index += 1 while atSectionHeader?
    elsif Input.repeat?(Input::UP)
      self.index -= 1
      self.index -= 1 while atSectionHeader?
      self.index = @options.length - 1 if self.index < 0
      self.index -= 1 while atSectionHeader?
    elsif Input.repeat?(Input::R)
      self.index += 8 # page size
      self.index -= 1 while atSectionHeader? || self.index > @options.length - 1
    elsif Input.repeat?(Input::L)
      self.index -= 8 # page size
      self.index += 1 while atSectionHeader? || self.index < 0
    end

    dorefresh = self.index != oldindex

    if self.active && !@options[self.index].is_a?(String)
      if Input.repeat?(Input::LEFT) || Input.repeat?(Input::RIGHT)
        oldvalue = @options[self.index].get
        self[self.index] = Input.repeat?(Input::LEFT) ?
          @options[self.index].prev(self[self.index]) :
          @options[self.index].next(self[self.index])
        newvalue = @options[self.index].get
        dorefresh = true if oldvalue != newvalue
      end
    end

    @mustUpdateOptions = dorefresh
    if dorefresh
      pbPlayCursorSE()
      refresh
    end
  end
end

module PropertyMixin
  def get
    @getProc ? @getProc.call() : nil
  end

  def set(value)
    @setProc.call(value) if @setProc
  end
end

class EnumOption
  include PropertyMixin
  attr_reader :values
  attr_reader :name
  attr_reader :description

  def initialize(name, options, getProc, setProc, description = "")
    @values = options
    @name = name
    @getProc = getProc
    @setProc = setProc
    @description = description
  end

  def next(current)
    index = current + 1
    index = @values.length - 1 if index > @values.length - 1
    tts(@values[index], true)
    self.set(index)
    return index
  end

  def prev(current)
    index = current - 1
    index = 0 if index < 0
    tts(@values[index], true)
    self.set(index)
    return index
  end

  def current(index)
    tts(@values[index])
  end
end

class NumberOption
  include PropertyMixin
  attr_reader :name
  attr_reader :format
  attr_reader :optstart
  attr_reader :optinc
  attr_reader :description

  def initialize(name, format, optstart, optend, optinc, getProc, setProc, description = "")
    @name = name
    @format = format
    @optstart = optstart
    @optend = optend
    @optinc = optinc
    @getProc = getProc
    @setProc = setProc
    @description = description
  end

  def next(current)
    index = current + @optstart
    index += @optinc
    if index > @optend
      index = @optstart
    end
    tts(index.to_s, true)
    self.set(index - @optstart)
    return index - @optstart
  end

  def prev(current)
    index = current + @optstart
    index -= @optinc
    if index < @optstart
      index = @optend
    end
    tts(index.to_s, true)
    self.set(index - @optstart)
    return index - @optstart
  end

  def current(index)
    tts((index + @optstart).to_s)
  end
end

def pbSettingToTextSpeed(speed)
  return 2 if speed == 0
  return 1 if speed == 1
  return -2 if speed == 2
  return MessageConfig::TextSpeed if MessageConfig::TextSpeed

  return Graphics.frame_rate > 40 ? -2 : 1
end

module MessageConfig
  def self.pbDefaultSystemFrame
    return pbResolveBitmap(TextFrames[$Settings.frame]) || ""
  end

  def self.pbDefaultSpeechFrame
    return pbResolveBitmap("Graphics/Windowskins/" + SpeechFrames[$Settings.textskin]) || ""
  end

  def self.pbDefaultSystemFontName
    return MessageConfig.pbTryFonts(VersionStyles[0][0], "Arial Narrow", "Arial")
  end

  def self.pbDefaultTextSpeed
    return pbSettingToTextSpeed($Settings.textspeed)
  end

  def pbGetSystemTextSpeed
    return $Settings.textspeed
  end
end

class PokemonOptions
  attr_accessor :textspeed
  attr_accessor :textskipwait
  attr_accessor :volume
  attr_accessor :bgsvolume
  attr_accessor :sevolume
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :nicknames
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :screensize
  attr_accessor :language
  attr_accessor :border
  attr_accessor :backup
  attr_accessor :maxBackup
  attr_accessor :field_effects_highlights
  attr_accessor :remember_commands
  attr_accessor :photosensitive
  attr_accessor :autorunning
  attr_accessor :bike_and_surf_music
  attr_accessor :streamermode
  attr_accessor :audiotype
  attr_accessor :unrealTimeDiverge
  attr_accessor :unrealTimeClock
  attr_accessor :unrealTimeTimeScale
  attr_accessor :turboSpeedMultiplier
  attr_accessor :discordRPC
  attr_accessor :frameskip
  attr_accessor :keyboard
  attr_accessor :performanceMode
  attr_accessor :dynamicTextbox
  attr_accessor :updatePrompts
  attr_accessor :exportBattleLogs
  attr_accessor :fullAutoHeal

  # Now deprecated and unused
  attr_accessor :bagsorttype
  attr_accessor :font
  attr_accessor :autosave

  def initialize
    fixMissingValues
  end

  def fixMissingValues
    @textspeed      = 1 if @textspeed.nil? # Text speed (0=slow, 1=mid, 2=fast)
    @textskipwait   = 0 if @textskipwait.nil? # Wait for text skip (0 is on, 1 is off)
    @volume              = 100 if @volume.nil? # Volume (0 - 100)
    @bgsvolume           = 100 if @bgsvolume.nil? # Volume (0 - 100)
    @sevolume            = 100 if @sevolume.nil? # Volume (0 - 100)
    @audiotype   = 0 if @audiotype.nil? # Stereo / Mono audio (0 / 1)
    @battlescene = 0 if @battlescene.nil? # Battle scene (animations) (0=on, 1=off)
    @battlestyle = 0 if @battlestyle.nil? # Battle style (0=shift, 1=set)
    @nicknames   = 0 if @nicknames.nil? # Give nicknames (0=on, 1=off)
    @frame       = 0 if @frame.nil? # Default window frame (see also TextFrames)
    @textskin    = 0 if @textskin.nil? # Speech frame
    @screensize  = DEFAULTSCREENZOOM.floor.to_i if @screensize.nil? # 0=half size, 1=full size, 2=double size
    @border      = 0 if @border.nil? # Screen border (0=off, 1=on)
    @language    = 0 if @language.nil? # Language (changed from load screen rather than options menu)
    @backup      = 0 if @backup.nil? # Backup on/off
    @maxBackup   = 50 if @maxBackup.nil?
    @field_effects_highlights = 0 if @field_effects_highlights.nil? # Field effect UI highlights on/off
    @remember_commands        = 0 if @remember_commands.nil?
    @photosensitive           = 0 if @photosensitive.nil? # a mode that disables flashes and shakes (0=off, 1=on)
    @autorunning              = 0 if @autorunning.nil? # 0 is on, 1 is off
    @bike_and_surf_music      = 0 if @bike_and_surf_music.nil? # 0 is off, 1 is on
    @streamermode             = 0 if @streamermode.nil?
    @unrealTimeDiverge        = 1 if @unrealTimeDiverge.nil? # Unreal Time (0=off, 1=on)
    @unrealTimeClock          = 1 if @unrealTimeClock.nil? # Unreal Time Clock (0=always, 1=pause menu, 2=off)
    @unrealTimeTimeScale      = 30 if @unrealTimeTimeScale.nil? # Unreal Time Timescale (default 30x real time)
    @turboSpeedMultiplier     = 3.0 if @turboSpeedMultiplier.nil? # Game speed multiplier in turbo mode
    @discordRPC               = 1 if @discordRPC.nil? # Controls Discord rich presence updates (0=off, 1=on)
    @frameskip                = 0 if @frameskip.nil? # mkxp-z frameskip feature (0=off, 1=on)
    @keyboard                 = 0 if @keyboard.nil? # 0 is on, 1 is off
    @performanceMode          = 1 if @performanceMode.nil? # 0 is on, 1 is off
    @dynamicTextbox           = 0 if @dynamicTextbox.nil? # textbox height adjusts to text (0=off, 1=on)
    @updatePrompts            = 0 if @updatePrompts.nil? # 0 is on, 1 is off
    @exportBattleLogs         = 0 if @exportBattleLogs.nil? # 0 = off, 1 = finished battles, 2 = all battles
    @fullAutoHeal             = 0 if @fullAutoHeal.nil? # 0 = party, 1 = pokemon
  end

  def useKeyboard?
    return $Settings.keyboard == 0
  end
end

class PokemonOptionScene
  def initOptions
    optionList = []

    # Gameplay
    optionList.push _INTL("Jugabilidad")
    optionList.push EnumOption.new(
      _INTL("Correr automáticamente"), [_INTL("Sí"), _INTL("No")],
      proc { $Settings.autorunning },
      proc { |value| $Settings.autorunning = value },
      _INTL("Elige si tu personaje correrá automáticamente.")
    )
    optionList.push EnumOption.new(
      _INTL("Velocidad del texto"), [_INTL("Normal"), _INTL("Rápida"), _INTL("Máxima")],
      proc { $Settings.textspeed },
      proc { |value|
        $Settings.textspeed = value
        MessageConfig.pbSetTextSpeed(pbSettingToTextSpeed(value))
      },
      _INTL("Elige entre tres velocidades de texto diferentes.")
    )
    optionList.push EnumOption.new(
      _INTL("Espera al omitir texto"), [_INTL("Sí"), _INTL("No")],
      proc { $Settings.textskipwait },
      proc { |value| $Settings.textskipwait = value },
      _INTL("Activa un retraso antes de que comience a omitirse el texto.")
    )
    optionList.push EnumOption.new(
      _INTL("Cuadro de texto dinámico"), [_INTL("No"), _INTL("Sí")],
      proc { $Settings.dynamicTextbox },
      proc { |value| $Settings.dynamicTextbox = value },
      _INTL("Ajusta la altura del cuadro de diálogo según el texto.")
    )
    optionList.push EnumOption.new(
      _INTL("Usar teclado"), [_INTL("Sí"), _INTL("No")],
      proc { $Settings.keyboard },
      proc { |value| $Settings.keyboard = value },
      _INTL("Elige si quieres usar el teclado integrado del dispositivo para introducir texto.")
    )
    optionList.push EnumOption.new(
      _INTL("Poner motes"), [_INTL("Sí"), _INTL("No")],
      proc { $Settings.nicknames },
      proc { |value| $Settings.nicknames = value },
      _INTL("Elige si quieres que se te pregunte si deseas poner un mote a los Pokémon cuando los obtengas.")
    )
    optionList.push EnumOption.new(
      _INTL("Fotosensibilidad"), [_INTL("No"), _INTL("Sí")],
      proc { $Settings.photosensitive },
      proc { |value|
        valuebefore = $Settings.photosensitive
        $Settings.photosensitive = value
        if value != valuebefore && value == 1 && $Settings.battlescene == 0 # Photosensitivity turned On while battle animations are On
          Kernel.pbMessage(_INTL("Ten en cuenta que algunas animaciones de combate también utilizan destellos y sacudidas de pantalla.\nConsidera desactivarlas en las Opciones de combate según tus necesidades."))
        end
      },
      _INTL("Desactiva los destellos y las sacudidas de pantalla para reducir los efectos relacionados con la fotosensibilidad.")
    )
    optionList.push EnumOption.new(
      _INTL("Modo de curación automática"), [_INTL("Equipo"), _INTL("Pokémon")],
      proc { $Settings.fullAutoHeal },
      proc { |value| $Settings.fullAutoHeal = value },
      _INTL("Elige si la curación automática debe aplicarse a todo el equipo o| únicamente al Pokémon seleccionado.")
    )

    # Battle
    optionList.push _INTL("Combate")
    optionList.push EnumOption.new(
      _INTL("Animaciones de combate"), [_INTL("Sí"), _INTL("No")],
      proc { $Settings.battlescene },
      proc { |value|
        valuebefore = $Settings.battlescene
        $Settings.battlescene = value
        if value != valuebefore && value == 0 && $Settings.photosensitive == 1 # Battle animations turned On while photosensitivity is On
          Kernel.pbMessage(_INTL("Ten en cuenta que algunas animaciones de combate también utilizan destellos y sacudidas de pantalla.\nConsidera desactivarlas según tus necesidades relacionadas con la fotosensibilidad."))
        end
      },
      _INTL("Muestra animaciones durante los combates.")
    )
    optionList.push EnumOption.new(
      _INTL("Estilo de combate"), [_INTL("Cambiar"), _INTL("Fijo")],
      proc { $Settings.battlestyle },
      proc { |value| $Settings.battlestyle = value },
      _INTL("Elige si se te preguntará si quieres cambiar de Pokémon cuando el Pokémon rival se debilite.")
    )
    optionList.push EnumOption.new(
      _INTL("Indicadores del campo"), [_INTL("Sí"), _INTL("No")],
      proc { $Settings.field_effects_highlights },
      proc { |value| $Settings.field_effects_highlights = value },
      _INTL("Muestra recuadros alrededor de los movimientos afectados positiva o negativamente por el campo.")
    )
    optionList.push EnumOption.new(
      _INTL("Cursor de combate"), [_INTL("Luchar"), _INTL("Último usado")],
      proc { $Settings.remember_commands },
      proc { |value| $Settings.remember_commands = value },
      _INTL("Establece la posición predeterminada del cursor del menú de comandos de combate.")
    )
    optionList.push EnumOption.new(
      _INTL("Exportar registros de combate"), [_INTL("No"), _INTL("Finalizados"), _INTL("Todos")],
      proc { $Settings.exportBattleLogs },
      proc { |value| $Settings.exportBattleLogs = value },
      proc { next [
        _INTL("No exportar registros de combate."),
        _INTL("Exportar los registros de combate a la carpeta de guardado de los combates que finalicen."),
        _INTL("Exportar los registros de todos los combates a la carpeta de guardado, incluidos aquellos que se reinicien."),
      ][$Settings.exportBattleLogs] }
    )

    # Audio
    optionList.push _INTL("Audio")
    optionList.push NumberOption.new(
      _INTL("Volumen de música"), proc { |value| _ISPRINTF("{1:d}", value) }, 0, 100, 1,
      proc { $Settings.volume },
      proc { |value|
        $Settings.volume = value
        if $game_map
          playing = $game_system.getDefaultBGM || $game_system.playing_bgm # Accounts for Jukebox
          if playing
            playing.volume = $Settings.volume
            $game_system.bgm_play_internal(playing, $game_system.bgm_position)
          end
        end
      },
      _INTL("Volumen de la música de fondo.")
    )
    optionList.push NumberOption.new(
      _INTL("Volumen de efectos"), proc { |value| _ISPRINTF("{1:d}", value) }, 0, 100, 1,
      proc { $Settings.sevolume },
      proc { |value| $Settings.sevolume = value },
      _INTL("Volumen de los efectos de sonido.")
    )
    optionList.push NumberOption.new(
      _INTL("Volumen de ambiente"), proc { |value| _ISPRINTF("{1:d}", value) }, 0, 100, 1,
      proc { $Settings.bgsvolume },
      proc { |value|
        $Settings.bgsvolume = value
        if $game_map
          playing = $game_system.playing_bgs
          if playing
            playing.volume = $Settings.bgsvolume
            $game_system.bgs_play(playing)
          end
        end
      },
      _INTL("Volumen de los sonidos ambientales, como los del clima.")
    )
    optionList.push EnumOption.new(
      _INTL("Sonido"), [_INTL("Estéreo"), _INTL("Mono")],
      proc { $Settings.audiotype },
      proc { |value| $Settings.audiotype = value },
      _INTL("Elige si el audio puede ser diferente en cada oído o si debe ser el mismo.")
    )
    optionList.push EnumOption.new(
      _INTL("Música de bici y surf"), [_INTL("No"), _INTL("Sí")],
      proc { $Settings.bike_and_surf_music },
      proc { |value| $Settings.bike_and_surf_music = value },
      _INTL("Activa la música especial de la bici y del surf.")
    )

    # Speed and Performance
    optionList.push _INTL("Velocidad y rendimiento")
    unless $joiplay
      optionList.push EnumOption.new(
        _INTL("Salto de fotogramas"), [_INTL("No"), _INTL("Sí")],
        proc { $Settings.frameskip },
        proc { |value|
          $Settings.frameskip = value
          Graphics.frameskip = value == 1
        },
        _INTL("Permite que la aceleración supere la frecuencia de actualización omitiendo fotogramas.")
      )
    end
    optionList.push NumberOption.new(
      _INTL("Multiplicador de velocidad"), proc { |value| _ISPRINTF("{1:.1f}x", value) }, 1, 10, 0.1,
      proc { $Settings.turboSpeedMultiplier - 1 },
      proc { |value|
        $Settings.turboSpeedMultiplier = value + 1
        if $speed_up
          # Intentionally calling it twice to apply the change without toggling turbo
          Graphics.toggleTurbo
          Graphics.toggleTurbo
        end
      },
      _INTL("Multiplicador de velocidad del juego durante el modo Turbo. Los valores más altos requieren el salto de fotogramas.")
    )
    if $joiplay
      optionList.push EnumOption.new(
        _INTL("Modo de rendimiento"), [_INTL("Sí"), _INTL("No")],
        proc { $Settings.performanceMode },
        proc { |value| $Settings.performanceMode = value },
        _INTL("Desactiva los elementos animados y los filtros de día y noche para evitar ralentizaciones. Es necesario reiniciar el juego para| aplicar los cambios.")
      )
    end

    # Customization
    optionList.push _INTL("Personalización")
    optionList.push NumberOption.new(
      _INTL("Marco de diálogo"), proc { |value| _ISPRINTF("{1:d}", value) }, 1, SpeechFrames.length, 1,
      proc { $Settings.textskin },
      proc { |value|
        $Settings.textskin = value
        MessageConfig.pbSetSpeechFrame(
          "Graphics/Windowskins/" + SpeechFrames[value]
        )
        # Update description window
        @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
        @sprites["textbox"].setDefaultTextColors
        @sprites["textbox"].width = @sprites["textbox"].width # Necessary evil
        pbSetSystemFont(@sprites["textbox"].contents)
      },
      proc { _INTL("Marco de diálogo {1}.", 1 + $Settings.textskin) }
    )
    optionList.push NumberOption.new(
      _INTL("Marco de menú"), proc { |value| _ISPRINTF("{1:d}", value) }, 1, TextFrames.length, 1,
      proc { $Settings.frame },
      proc { |value|
        $Settings.frame = value
        MessageConfig.pbSetSystemFrame(TextFrames[value])
        # Update options window
        @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame())
        @sprites["option"].setDefaultTextColors
      },
      proc { _INTL("Marco de menú {1}.", 1 + $Settings.frame) }
    )
    unless Reborn # In Reborn the clock is always displayed in pause menu
      optionList.push EnumOption.new(
        _INTL("Mostrar reloj"), [_INTL("Siempre"), _INTL("Menú"), _INTL("No")],
        proc { $Settings.unrealTimeClock },
        proc { |value| $Settings.unrealTimeClock = value },
        _INTL("Muestra un reloj dentro del juego con la hora actual.")
      )
    end
    unless mobile?
      # Limited by the clamp in mkxp-z Graphics::setScale() function. We can increase it there if we ever need to scale it up further.
      optionList.push NumberOption.new(
        _INTL("Tamaño de pantalla"), proc { |value| value == 0.0 ? _INTL("Pantalla completa") : _ISPRINTF("{1:.1f}x", value) }, 0.0, 4.0, 0.5,
        proc { $Settings.screensize },
        proc { |value|
          oldvalue = $Settings.screensize
          $Settings.screensize = value
          if value != oldvalue
            pbSetResizeFactor($Settings.screensize)
          end
        },
        _INTL("Elige el tamaño de la pantalla.")
      )
      unless Desolation
        optionList.push EnumOption.new(
          _INTL("Borde de pantalla"), [_INTL("No"), _INTL("Sí")],
          proc { $Settings.border },
          proc { |value|
            oldvalue = $Settings.border
            $Settings.border = value
            if value != oldvalue
              pbSetResizeFactor($Settings.screensize)
            end
          },
          _INTL("Elige si quieres mostrar un borde alrededor de la pantalla.")
        )
      end
    end

    # Saving
    optionList.push _INTL("Guardado")
    optionList.push EnumOption.new(
      _INTL("Copias de seguridad"), [_INTL("Sí"), _INTL("No")],
      proc { $Settings.backup },
      proc { |value| $Settings.backup = value },
      _INTL("Conserva los archivos sobrescritos de cada ranura de guardado para poder recuperarlos más adelante.")
    )
    optionList.push NumberOption.new(
      _INTL("Número máximo de copias"), proc { |value| value == 101 ? _INTL("Ilimitadas") : _ISPRINTF("{1:d}", value) }, 1, 101, 1,
      proc { $Settings.maxBackup == 999_999 ? 100 : $Settings.maxBackup },
      proc { |value| $Settings.maxBackup = value == 100 ? 999_999 : value }, # +1
      _INTL("Número máximo de copias de seguridad que se conservarán por cada ranura de guardado.")
    )
    unless RTP.isAlwaysPortable # JoiPlay version is always in Portable mode
      optionList.push EnumOption.new(
        _INTL("Modo portátil"), [_INTL("No"), _INTL("Sí")],
        proc { RTP.isPortable ? 1 : 0 },
        proc { |value|
          value == 1 ? RTP.makePortable : RTP.makeNonPortable
        },
        _INTL("Guarda los datos de guardado en la carpeta del ejecutable del juego.")
      )
    end

    # Network
    optionList.push _INTL("Red")
    # options currently running every time the user accesses the options menu and does anything
    if defined?(DiscordAppID) && DiscordAppID && !mobile?
      optionList.push EnumOption.new(
        _INTL("Actividad de Discord"), [_INTL("No"), _INTL("Sí")],
        proc { $Settings.discordRPC },
        proc { |value| $Settings.discordRPC = value },
        _INTL("Controla la presencia enriquecida de Discord.\nSi está activada, muestra información del juego en Discord.")
      )
    end
    optionList.push EnumOption.new(
      _INTL("Modo streamer"), [_INTL("No"), _INTL("Sí")],
      proc { $Settings.streamermode },
      proc { |value| $Settings.streamermode = value },
      _INTL("Oculta información privada por motivos de seguridad y compatibilidad.")
    )
    optionList.push EnumOption.new(
      _INTL("Avisos de actualización"), [_INTL("Sí"), _INTL("No")],
      proc { $Settings.updatePrompts },
      proc { |value| $Settings.updatePrompts = value },
      _INTL("Elige si quieres recibir avisos sobre nuevas versiones al iniciar el juego.")
    )

    # Unreal Time
    if $game_switches && $game_switches[:Unreal_Time]
      optionList.push _INTL("Tiempo irreal")
      optionList.push EnumOption.new(
        _INTL("Tiempo irreal"), [_INTL("No"), _INTL("Sí")],
        proc { $Settings.unrealTimeDiverge },
        proc { |value| $Settings.unrealTimeDiverge = value },
        _INTL("Utiliza la hora del juego en lugar del reloj del ordenador.")
      )
      optionList.push NumberOption.new(
        _INTL("Escala del tiempo irreal"), proc { |value| _ISPRINTF("{1:d}x", value) }, 1, 60, 1,
        proc { $Settings.unrealTimeTimeScale - 1 },
        proc { |value| $Settings.unrealTimeTimeScale = value + 1 },
        _INTL("Establece la velocidad a la que transcurre el tiempo irreal.")
      )
    end

    optionList.push _INTL("Volver")
    return optionList
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @optionList = initOptions
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["textbox"] = Kernel.pbCreateMessageWindow
    @sprites["textbox"].letterbyletter = false
    @sprites["textbox"].setDefaultTextColors
    # @sprites["textbox"].text=_INTL("Speech frame {1}.",1+$Settings.textskin)
    @sprites["option"] = Window_PokemonOption.new(
      @optionList, 0, 0, Graphics.width, Graphics.height - @sprites["textbox"].height
    )
    @sprites["option"].index += 1 while @sprites["option"].atSectionHeader?
    pbUpdateOptions
    @sprites["option"].viewport = @viewport
    @sprites["option"].visible = true
    # Get the values of each option
    for i in 0...@optionList.length
      @sprites["option"][i] = @optionList[i].is_a?(String) ? nil : @optionList[i].get
    end
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbOptions
    pbActivateWindow(@sprites, "option") {
      loop do
        Graphics.update
        Input.update
        pbUpdate
        pbUpdateOptions if @sprites["option"].mustUpdateOptions
        if Input.trigger?(Input::C) && !@optionList[@sprites["option"].index].is_a?(String)
          desc = pbGetDesc
          if desc.include?("|")
            desc = "..." + desc.split("|")[1].lstrip
            Kernel.pbMessage(desc) # Show full desc
          end
        end
        if Input.trigger?(Input::B) || (Input.trigger?(Input::C) && @sprites["option"].index == @optionList.length - 1)
          saveClientData
          saveSettings

          if defined?(DiscordRPC) && !mobile?
            if $Settings.discordRPC == 0
              DiscordRPC.end
            elsif $Settings.discordRPC == 1
              DiscordRPC.start
            end
          end

          break
        end
      end
    }
  end

  def pbUpdateOptions
    optindex = @sprites["option"].index
    opt = @optionList[optindex]
    name = opt.is_a?(String) ? opt : opt.name

    # Update desc
    desc = pbGetDesc
    desc = desc.split("|")[0] + "..." if desc.include?("|")
    @sprites["textbox"].text = desc # Show trimmed-to-fit desc

    return if name == @lastread

    # tts
    tts(name, true)
    opt.current(@sprites["option"][optindex]) unless opt.is_a?(String)
    tts(@sprites["textbox"].text)
    @lastread = name
  end

  def pbGetDesc
    optindex = @sprites["option"].index
    opt = @optionList[optindex]
    if opt.is_a?(String)
      return optindex == @optionList.length - 1 ? _INTL("Cierra el menú de opciones.") : ""
    end

    desc = opt.description
    desc = desc.call if desc.is_a?(Proc)
    return desc
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    Kernel.pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    pbRefreshSceneMap
    @viewport.dispose
  end
end

class PokemonOption
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbOptions
    @scene.pbEndScene
  end
end
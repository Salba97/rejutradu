class PokemonMenu_Scene
  attr_accessor :sprites
  attr_accessor :viewport

  def pbShowCommands(commands)
    ret = -1
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.viewport = @viewport
    cmdwindow.index = $PokemonTemp.menuLastChoice
    cmdwindow.resizeToFit(commands)
    cmdwindow.commands = commands
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.y = 0
    cmdwindow.visible = true
    lastread = nil
    loop do
      update(cmdwindow)
      if commands[cmdwindow.index] != lastread
        tts(commands[cmdwindow.index], true)
        lastread = commands[cmdwindow.index]
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::B)
        ret = -1
        break
      end
      if Input.trigger?(Input::C)
        ret = cmdwindow.index
        $PokemonTemp.menuLastChoice = ret
        break
      end
    end
    return ret
  end

  def update(cmdwindow)
    cmdwindow.update
  end

  def pbShowInfo(text)
    window = @sprites["infowindow"]
    window.resizeToFit(text, Graphics.height)
    window.text = text
    window.visible = true
    @infostate = true
    window.x = -4
    window.y = [0, 1].include?($Settings.unrealTimeClock) ? 62 : 0 # 62 is the height of the clock display, 0/1 values mean clock is shown always/in pause menu
  end

  def pbShowHelp(text)
    window = @sprites["helpwindow"]
    window.resizeToFit(text, Graphics.height)
    window.text = text
    window.visible = true
    @helpstate = true
    window.x = -4
    window.y = Graphics.height - window.height - 74 # 74 is the height of the HUD display
  end

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["cmdwindow"] = Window_CommandPokemon.new([], tts: false)
    @sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["helpwindow"].visible = false
    @sprites["cmdwindow"].visible = false
    @infostate = false
    @helpstate = false
    $game_temp.in_menu = true
    pbSEPlay("menu")
  end

  def pbHideMenu
    @sprites["cmdwindow"].visible = false
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"].visible = false
  end

  def pbShowMenu
    pbStartScene if @sprites["cmdwindow"].disposed?
    @sprites["cmdwindow"].visible = true
    @sprites["infowindow"].visible = @infostate
    @sprites["helpwindow"].visible = @helpstate
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    $game_temp.in_menu = false
    pbSEPlay("menuclose")
    @viewport.dispose
  end

  def pbRefresh
  end
end

class PokemonMenu
  def initialize(scene)
    @scene = scene
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
  end

  def pbStartPokemonMenu
    @scene.pbStartScene
    endscene = true
    $game_screen.getTimeCurrent(true)

    loop do
      if pbInSafari?
        if SAFARISTEPS <= 0
          @scene.pbShowInfo(_INTL("Balls: {1}", pbSafariState.ballcount))
        else
          @scene.pbShowInfo(_INTL("Steps: {1}/{2}\nBalls: {3}", pbSafariState.steps, SAFARISTEPS, pbSafariState.ballcount))
        end
      end

      # Generate menu data via the handler
      commands, _helptexts, actions = MenuHandlers.build(:pause_menu, @scene, self)

      command = @scene.pbShowCommands(commands)
      if command == -1
        @scene.pbHideMenu
        break
      end
      if command >= 0 && command < actions.length
        should_break = actions[command].call(@scene, self)
        if should_break == :break
          endscene = false
          break
        end
      end
    end
    @scene.pbEndScene if endscene
  end
end

class PokemonTrainerCardScene
  BASE_COLOR = Color.new(210, 215, 220)
  SHADOW_COLOR = Color.new(70, 75, 80)

  # [label x, label y, x, y]
  ID_POS = [332, 64, 468, 64]
  NAME_POS = [34, 64, 302, 64]
  MONEY_POS = [34, 112, 302, 112]
  DEX_POS = [34, 160, 302, 160]
  TIME_POS = [34, 208, 302, 208]
  TRAINER_OFFSET = [128, 148]

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    if $Trainer.isFemale? && pbResolveBitmap(sprintf("Graphics/Pictures/Trainer Card/trainercardbgf"))
      addBackgroundPlane(@sprites, "bg", "trainercardbgf", @viewport)
    else
      addBackgroundPlane(@sprites, "bg", "trainercardbg", @viewport)
    end
    @front = true
    pbDrawTrainerCardFront
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawTrainerCardFront
    @sprites["card"] = IconSprite.new(0, 0, @viewport)
    if $Trainer.isFemale? && pbResolveBitmap(sprintf("Graphics/Pictures/Trainer Card/trainercardf"))
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/trainercardf")
    else
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/trainercard")
    end

    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)

    width = Rejuv ? 100 : 112
    @sprites["trainer"] = IconSprite.new(336, width, @viewport)
    @sprites["trainer"].setBitmap(pbPlayerSpriteFile($Trainer.trainertype))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width - TRAINER_OFFSET[0]) / 2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height - TRAINER_OFFSET[1]) # UPDATED
    @sprites["trainer"].z = 2

    overlay = @sprites["overlay"].bitmap
    overlay.clear
    textPositions, imagePositions = [], []

    $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
    # starttime = _ISPRINTF(
    #  "{1:s} {2:d}, {3:d}",
    #  pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
    #  $PokemonGlobal.startTime.day,
    #  $PokemonGlobal.startTime.year
    # )

    if Reborn && $game_switches[:NotPlayerCharacter] # ID is not set on $Trainer in Reborn implementation
      pubid = KNOWN_TRAINERS[$Trainer.name] ? sprintf("%05d", KNOWN_TRAINERS[$Trainer.name]) : "???"
    else
      pubid = sprintf("%05d", $Trainer.publicID($Trainer.id))
    end
    ownedCount = $game_switches[:NotPlayerCharacter] ? "???" : $Trainer.pokedex.getOwnedCount
    seenCount = $game_switches[:NotPlayerCharacter] ? "???" : $Trainer.pokedex.getSeenCount
    money = $game_switches[:NotPlayerCharacter] ? "???" : getPurchaseDisplay($Trainer.money)
    if $game_switches[:NotPlayerCharacter]
      time = "???"
    else
      totalsec = Graphics.time_passed / 40 + (Process.clock_gettime(Process::CLOCK_MONOTONIC) - Graphics.start_playing).to_i
      hour = totalsec / 60 / 60
      min = totalsec / 60 % 60
      time = _ISPRINTF("{1:02d}:{2:02d}", hour, min)
    end
    textPositions += [
      [_INTL("Money"), MONEY_POS[0], MONEY_POS[1], 0, BASE_COLOR, SHADOW_COLOR],
      [money, MONEY_POS[2], MONEY_POS[3], 1, BASE_COLOR, SHADOW_COLOR],
      [_INTL("Pokédex"), DEX_POS[0], DEX_POS[1], 0, BASE_COLOR, SHADOW_COLOR],
      [_INTL("{1} / {2}", ownedCount, seenCount), DEX_POS[2], DEX_POS[3], 1, BASE_COLOR, SHADOW_COLOR],
      [_INTL("Time"), TIME_POS[0], TIME_POS[1], 0, BASE_COLOR, SHADOW_COLOR],
      # UPDATE- Adding room for 18 badges
      [time, TIME_POS[2], TIME_POS[3], 1, BASE_COLOR, SHADOW_COLOR],
      # [_INTL("Started"), 34, 256, 0, BASE_COLOR, SHADOW_COLOR],
      # [starttime, 302, 256, 1, BASE_COLOR, SHADOW_COLOR],
    ]
    textPositions += pbGetTrainerNameIDText(pubid, $Trainer.name)
    pbDrawTextPositions(overlay, textPositions)

    y = 262
    if $game_switches[:NotPlayerCharacter]
      # no-op (don't draw badges)
    elsif Desolation
      x = 80
      for i in 0...7
        if $Trainer.badges[i]
          imagePositions.push(["Graphics/Pictures/Trainer Card/badges", x, y, i * 48, 0, 48, 48])
        end
        x += 50
      end
      y += 50
      x = 130
      for i in 0...5
        if $Trainer.badges[i + 7]
          imagePositions.push(["Graphics/Pictures/Trainer Card/badges", x, y, i * 48, 48, 48, 48])
        end
        x += 50
      end
    else
      for region in 0...2 # Two rows
        x = 32
        for i in 0...9
          if $Trainer.badges[i + region * 9]
            if Rejuv && ($game_variables[:V13Story] >= 11)
              imagePositions.push(["Graphics/Pictures/Trainer Card/badges_1", x, y, i * 48, region * 48, 48, 48])
            else
              imagePositions.push(["Graphics/Pictures/Trainer Card/badges", x, y, i * 48, region * 48, 48, 48])
            end
          end
          x += 50
        end
        y += 50
      end
    end
    pbDrawImagePositions(overlay, imagePositions)

    tts("Trainer Card")
    tts(sprintf("Name: %s", $Trainer.name))
    tts(sprintf("ID Number: %s", pubid))
    unless $game_switches[:NotPlayerCharacter]
      tts(sprintf("Money: %s", money))
      tts(sprintf("Pokédex: %s seen, %s caught", seenCount, ownedCount))
      tts(sprintf("Time: %s hours and %s minutes", hour, min))
      tts(sprintf("Badges: %d", $Trainer.numbadges))
      tts(sprintf("Level Cap: %d", [LEVELCAPS[$Trainer.numbadges], 100 + $game_variables[:Extended_Max_Level]].min))
    end
  end

  def pbGetTrainerNameIDText(id, name)
    return [
      [_INTL("Name"), NAME_POS[0], NAME_POS[1], 0, BASE_COLOR, SHADOW_COLOR],
      [name, NAME_POS[2], NAME_POS[3], 1, BASE_COLOR, SHADOW_COLOR],
      [_INTL("ID No."), ID_POS[0], ID_POS[1], 0, BASE_COLOR, SHADOW_COLOR],
      [id, ID_POS[2], ID_POS[3], 1, BASE_COLOR, SHADOW_COLOR],
    ]
  end

  def pbTrainerCard
    loop do
      Graphics.update
      Input.update
      self.update
      break if Input.trigger?(Input::B)
      pbTurnCardOver if Input.trigger?(Input::C)
    end
  end

  def pbTurnCardOver
    # no-op
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class PokemonTrainerCard
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end

def favPokeTracker(*args)
  # no-op
end

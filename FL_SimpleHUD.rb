#===============================================================================
# * Simple HUD Optimized - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It displays a simple HUD with the
# party icons, HP Bars and some small text.
#
#===============================================================================
#
# To this script works, put it above main.
#
#===============================================================================
class Spriteset_Map
  class HUD
    # If you wish to use a background picture, put the image path below, like
    # BGPATH="Graphics/Pictures/battleMessage". I recommend a 512x64 picture
    BGPATH = "Graphics/Pictures/hudBG"

    # Make as 'false' to don't show the blue bar
    USEBAR = false

    # Make as 'true' to draw the HUD at bottom
    DRAWATBOTTOM = true

    # Make as 'true' to only show HUD in the pause menu
    DRAWONLYINMENU = true

    # Make as 'false' to don't show the hp bars
    SHOWHPBARS = true

    # When above 0, only displays HUD when this switch is on.
    SWITCHNUMBER = 0

    # Lower this number = more lag.
    FRAMESPERUPDATE = 3

    # The size of drawable content.
    BARHEIGHT = 64

    def initialize(viewport1b)
      @viewport1b = viewport1b
      @sprites = {}
      @yposition = DRAWATBOTTOM ? Graphics.height - 64 : 0
    end

    def showHUD?
      return (
        $Trainer &&
        (SWITCHNUMBER <= 0 || $game_switches[SWITCHNUMBER]) &&
        (!DRAWONLYINMENU || $game_temp.in_menu)
      )
    end

    def create
      @sprites.clear

      @partySpecies = Array.new(6, 0)
      @partyForm = Array.new(6, 0)
      @partyIsEgg = Array.new(6, false)
      @partyHP = Array.new(6, 0)
      @partyTotalHP = Array.new(6, 0)

      if USEBAR
        @sprites["bar"] = IconSprite.new(0, @yposition, @viewport1b)
        barBitmap = Bitmap.new(Graphics.width, BARHEIGHT)
        barRect = Rect.new(0, 0, barBitmap.width, barBitmap.height)
        barBitmap.fill_rect(barRect, Color.new(128, 128, 192))
        @sprites["bar"].bitmap = barBitmap
      end

      drawBarFromPath = "Graphics/Pictures/hudBG"
      if drawBarFromPath
        @sprites["bgbar"] = IconSprite.new(0, 0, @viewport1b)
        @sprites["bgbar"].setBitmap(drawBarFromPath)
        # @sprites["bgbar"].opacity = 30
      end

      @currentTexts = textsDefined
      drawText
      multOffset = 4
      nameLength = $Trainer.name.length
      nameLength -= 9
      multOffset -= nameLength if nameLength > 0

      for i in 0...6
        x = -4 + ((50 + multOffset) * i) - (AURA_SPRITE_OFFSET / 2)
        y = @yposition - 4  - (AURA_SPRITE_OFFSET / 2)
        y -= 8 if SHOWHPBARS
        @sprites["pokeicon#{i}"] = IconSprite.new(x, y, @viewport1b)
      end
      refreshPartyIcons

      if SHOWHPBARS
        borderWidth = 36
        borderHeight = 10
        fillWidth = 32
        fillHeight = 6
        for i in 0...6
          x = ((50 + multOffset) * i) + 30
          y = @yposition + 58

          @sprites["hpbarborder#{i}"] = BitmapSprite.new(
            borderWidth, borderHeight, @viewport1b
          )
          @sprites["hpbarborder#{i}"].x = x - borderWidth / 2
          @sprites["hpbarborder#{i}"].y = (y - borderHeight / 2).to_grid
          @sprites["hpbarborder#{i}"].bitmap.fill_rect(
            Rect.new(0, 0, borderWidth, borderHeight),
            Color.new(32, 32, 32)
          )
          @sprites["hpbarborder#{i}"].bitmap.fill_rect(
            (borderWidth - fillWidth) / 2,
            ((borderHeight - fillHeight) / 2).to_grid,
            fillWidth,
            fillHeight,
            Color.new(96, 96, 96)
          )
          @sprites["hpbarborder#{i}"].visible = false

          @sprites["hpbarfill#{i}"] = BitmapSprite.new(
            fillWidth, fillHeight, @viewport1b
          )
          @sprites["hpbarfill#{i}"].x = x - fillWidth / 2
          @sprites["hpbarfill#{i}"].y = (y - fillHeight / 2).to_grid
        end
        refreshHPBars
      end

      for sprite in @sprites.values
        sprite.z += 600
      end
    end

    def drawText
      baseColor = Color.new(72, 72, 72)
      shadowColor = Color.new(160, 160, 160)

      if @sprites.include?("overlay")
        @sprites["overlay"].bitmap.clear
      else
        width = Graphics.width
        @sprites["overlay"] = BitmapSprite.new(width, BARHEIGHT, @viewport1b)
        @sprites["overlay"].y = @yposition
      end

      xposition = Graphics.width - 64
      textPositions = [
        [@currentTexts[0], xposition, 0, 2, baseColor, shadowColor],
        [@currentTexts[1], xposition, 32, 2, baseColor, shadowColor]
      ]

      pbSetSystemFont(@sprites["overlay"].bitmap)
      pbDrawTextPositions(@sprites["overlay"].bitmap, textPositions)
    end

    # Note that this method is called on each refresh, but the texts
    # only will be redrawed if any character change.
    def textsDefined
      ret = []
      ret[0] = ""
      ret[1] = ""
      return ret
    end

    def refreshPartyIcons
      return if hidePlayerPossessions?

      for i in 0...6
        partyMemberExists = $Trainer.party.size > i
        partySpecie = 0
        partyForm = 0
        partyIsEgg = false
        if partyMemberExists
          partySpecie = $Trainer.party[i].species
          partyForm = $Trainer.party[i].form
          partyIsEgg = $Trainer.party[i].egg?
        end
        refresh = (
          @partySpecies[i] != partySpecie ||
          @partyForm[i] != partyForm ||
          @partyIsEgg[i] != partyIsEgg
        )
        if refresh
          @partySpecies[i] = partySpecie
          @partyForm[i] = partyForm
          @partyIsEgg[i] = partyIsEgg
          if partyMemberExists
            @sprites["pokeicon#{i}"].bitmap = pbPokemonIconBitmap($Trainer.party[i])
            @sprites["pokeicon#{i}"].src_rect = Rect.new(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
          end
          @sprites["pokeicon#{i}"].visible = partyMemberExists
        end
      end
    end

    def refreshHPBars
      return if hidePlayerPossessions?

      for i in 0...6
        hp = 0
        totalhp = 0
        hasHP = i < $Trainer.party.size && !$Trainer.party[i].egg?
        if hasHP
          hp = $Trainer.party[i].hp
          totalhp = $Trainer.party[i].totalhp
        end

        lastTimeWasHP = @partyTotalHP[i] != 0
        @sprites["hpbarborder#{i}"].visible = hasHP if lastTimeWasHP != hasHP

        redrawFill = hp != @partyHP[i] || totalhp != @partyTotalHP[i]
        if redrawFill
          @partyHP[i] = hp
          @partyTotalHP[i] = totalhp
          @sprites["hpbarfill#{i}"].bitmap.clear

          width = @sprites["hpbarfill#{i}"].bitmap.width
          height = @sprites["hpbarfill#{i}"].bitmap.height
          fillAmount = (hp == 0 || totalhp == 0) ? 0 : [hp * width / totalhp, 2].max.to_grid
          if fillAmount > 0
            hpzone = getHPZone(hp, totalhp)
            hpColors = [
              [Color.new(24, 192, 32), Color.new(0, 144, 0)], # Green
              [Color.new(248, 184, 0), Color.new(184, 112, 0)], # Yellow
              [Color.new(240, 80, 32), Color.new(168, 48, 56)], # Red
            ][hpzone]
            shadowHeight = 2
            rect = Rect.new(0, 0, fillAmount, shadowHeight)
            @sprites["hpbarfill#{i}"].bitmap.fill_rect(rect, hpColors[1])
            rect = Rect.new(0, shadowHeight, fillAmount, height - shadowHeight)
            @sprites["hpbarfill#{i}"].bitmap.fill_rect(rect, hpColors[0])
          end
        end
      end
    end

    def update
      if showHUD?
        if $updateFLHUD
          dispose if !@sprites.empty?
          $updateFLHUD = false
        end
        if @sprites.empty?
          create
        else
          updateHUDContent = (
            FRAMESPERUPDATE <= 1 || Graphics.frame_count % FRAMESPERUPDATE == 0
          )
          if updateHUDContent
            newTexts = textsDefined
            if @currentTexts != newTexts
              @currentTexts = newTexts
              drawText
            end
            refreshPartyIcons
            refreshHPBars if SHOWHPBARS
          end
        end
        pbUpdateSpriteHash(@sprites)
      else
        dispose if !@sprites.empty?
      end
    end

    def dispose
      pbDisposeSpriteHash(@sprites)
    end
  end

  unless @FLsimpleHUDAliases
    alias :disposeOldFL :dispose
    alias :updateOldFL :update
    @FLsimpleHUDAliases = true
  end

  @@hud = nil

  def dispose
    @@hud.dispose if @@hud
    disposeOldFL
  end

  def update
    updateOldFL
    @@hud = HUD.new(@viewport1b) if !@@hud
    @@hud.update
  end
end

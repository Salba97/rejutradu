class PokemonGlobalMetadata
  def xenTower
    @xenTower = XenTower.new if !@xenTower
    return @xenTower
  end
end

class XenTower
  attr_reader :inProgress
  attr_reader :maxPartySize
  attr_reader :random
  attr_accessor :blessings
  attr_accessor :tickets
  attr_accessor :attempts
  def initialize()
    @attempts = 0
  end

  def start(tickets = 3)
    @attempts ||= 0
    @inProgress = true
    $game_variables[:PlayerDataBackup] = []
    playerTeamBackup
    playerItemBackup
    $Trainer.party = []
    $PokemonBag = PokemonBag.new
    $game_variables[:PlayerDataBackup][7] = true
    @tickets = 3
    @tickets = 4 if $game_switches[:DefeatedXenTowerMadelis]
    @tickets = 6 if $game_switches[:DefeatedXenTowerFlora]
    @tickets = tickets if tickets != 3
    @maxPartySize = 3
    @maxPartySize = 4 if $game_switches[:DefeatedXenTowerMadelis]
    @maxPartySize = 6 if $game_switches[:DefeatedXenTowerFlora]
    @random = Random.new
    @blessings = {}
    @attempts += 1
  end

  def maxPartySize
    @maxPartySize = 4 if $game_switches[:DefeatedXenTowerMadelis]
    @maxPartySize = 6 if $game_switches[:DefeatedXenTowerFlora]
    return @maxPartySize
  end

  def end(cleared)
    @inProgress = false
    prizes = $Trainer.party
    teamRestore
    playerItemRestore
    depositPrizes(prizes) if cleared
    $game_variables[:PlayerDataBackup] = []
  end

  def roll(pool)
    return false if !@inProgress || @tickets < 1
    @tickets -= 1
    xtpool = getXenTowerPool(pool).sample(4, random: @random).map{ |m| m.createPokemon }
    pbFadeOutIn(99999) {
      scene = LuckSwapScene.new(xtpool)
      screen = LuckSwapScreen.new(scene)
      if $Trainer.party.length < self.maxPartySize
        mon = screen.startLuckponPick
        # do additional mon edits here too

        $Trainer.party.push(mon) if mon

      else
        screen.startLuckponSwap(xtpool)
      end
    }
    if $PokemonGlobal.xenTower.tickets > 0
      # text for using another ticket
      repeat = Kernel.pbConfirmMessage(_INTL("You have {1} tickets remaining. Pull again?", $PokemonGlobal.xenTower.tickets))
      roll(pool) if repeat
    end
    return true
  end
end

def getXenTowerPool(pool)
  return $cache.xtpool.pool(pool)
end

def startXenTower(tickets = 3)
  $PokemonGlobal.xenTower.start(tickets)
  startBlessingOverlay()
end

def endXenTower(cleared = false)
  $PokemonGlobal.xenTower.end(cleared)
  clearBlessingOverlay if $game_temp.blessing_overlay
end

def xenTowerInProgress
  return false if !$Trainer
  return $PokemonGlobal.xenTower.inProgress
end


class DefaultControlsScene
  unless @blessingControlsAliased
    alias __blessings_getOWK getOWControlsKeyboard
    alias __blessings_getBattleK getBattleControlsKeyboard
    alias __blessings_getOWG getOWControlsGamepad
    alias __blessings_getBattleG getBattleControlsGamepad
    @blessingControlsAliased = true
  end

  def getOWControlsKeyboard
    __blessings_getOWK
    i = @texts.length - 1
    if xenTowerInProgress
      @texts.push [_INTL("A:   View Blessings"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    end
  end

  def getBattleControlsKeyboard
    __blessings_getBattleK
    i = @texts.length - 1
    if xenTowerInProgress
      @texts.push [mobile? ? _INTL("H:   View Blessings") : _INTL("Shift:   View Blessings"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    end
  end

  def getOWControlsGamepad
    __blessings_getOWG
    i = @texts.length - 1
    if xenTowerInProgress
      @texts.push [_INTL("       :   View Blessings"), X, Y + LineHeight * (i += 1), 0, *TextColors]
      @images.push [@buttonTriangle, X, Y + LineHeight * i + 4, 0, 0, 24, 24]
    end
  end

  def getBattleControlsGamepad
    __blessings_getBattleG
    i = @texts.length - 1
    if xenTowerInProgress
      @texts.push [_INTL("R2:   View Blessings"), X, Y + LineHeight * (i += 1), 0, *TextColors]
    end
  end
end

def passwordHelloEizen
  Kernel.pbMessage(_INTL("This is not a valid password!"))
  pbCommonEvent(134)
  pbSEPlay("microsam", 100, 100)
  Kernel.pbMessage(_INTL("G R E E T I N G S"))
end

def wllSavePassword
  status = $Unidata[:WLL]
  status = $game_switches[:WLLSaveOverride] if $game_switches[:WLLSavePassword]

  Kernel.pbMessage(_INTL("Save data for Where Love Lies {1} detected.", status ? _INTL("has been") : _INTL("was not")))
  if Kernel.pbConfirmMessage(_INTL("Do wish to {1} WLL crossovers for this save? Please note that this will only effect this save.", status ? _INTL("disable") : _INTL("enable")))
    $game_switches[:WLLSavePassword] = true
    $game_switches[:WLLSaveOverride] = !status
  else
    $game_switches[:WLLSavePassword] = status
  end
end

def hasWLLSave?
  return $game_switches[:WLLSaveOverride] if $game_switches[:WLLSavePassword]
  return $Unidata[:WLL]
end

def rebornSavePassword
  status = $Unidata[:Reborn]
  status = $game_switches[:RebornSaveOverride] if $game_switches[:RebornSavePassword]

  Kernel.pbMessage(_INTL("Save data for Reborn {1} detected.", status ? _INTL("has been") : _INTL("was not")))
  if Kernel.pbConfirmMessage(_INTL("Do wish to {1} Reborn crossovers for this save? Please note that this will only effect this save.", status ? _INTL("disable") : _INTL("enable")))
    $game_switches[:RebornSavePassword] = true
    $game_switches[:RebornSaveOverride] = !status

    if $game_switches[:RebornSaveOverride]
      name = ""
      while name.empty?
        name = Kernel.pbMessageFreeText(_INTL("Please input a name for the Reborn Region's Champion."), $Unidata[:RebornPlayerName], 16)
      end

      $game_variables[:RebornPlayerNameOverride] = name

      $game_variables[:RebornBlakeRouteOverride] = Kernel.pbConfirmMessageSerious(_INTL("Did {1} give Blake the Ruby Ring in Ametrine City?", name)).to_i
    end
  else
    $game_switches[:RebornSavePassword] = status
  end
end

def hasRebornSave?
  return $game_switches[:RebornSaveOverride] if $game_switches[:RebornSavePassword]
  return $Unidata[:Reborn]
end

def rebornPlayerName
  return $game_variables[:RebornPlayerNameOverride] if $game_switches[:RebornSavePassword]
  return $Unidata[:RebornPlayerName]
end

def getLinVar
  return $game_variables[:RebornBlakeRouteOverride] if $game_switches[:RebornSavePassword]
  return $Unidata[:RebornBlakeRoute]
end

def desoSavePassword
  status = $Unidata[:Deso]
  status = $game_switches[:DesoSaveOverride] if $game_switches[:DesoSavePassword]

  Kernel.pbMessage(_INTL("Save data for Desolation {1} detected.", status ? _INTL("has been") : _INTL("was not")))
  if Kernel.pbConfirmMessage(_INTL("Do wish to {1} Desolation crossovers for this save? Please note that this will only effect this save.", status ? _INTL("disable") : _INTL("enable")))
    $game_switches[:DesoSavePassword] = true
    $game_switches[:DesoSaveOverride] = !status

    if $game_switches[:DesoSaveOverride]
      name = ""
      while name.empty?
        name = Kernel.pbMessageFreeText(_INTL("Please input a name for the Desolation protagonist."), $Unidata[:DesoPlayerName], 16)
      end

      $game_variables[:DesoPlayerNameOverride] = name
    end
  else
    $game_switches[:DesoSavePassword] = status
  end
end

def hasDesoSave?
  return $game_switches[:DesoSaveOverride] if $game_switches[:DesoSavePassword]
  return $Unidata[:Deso]
end

def desoPlayerName
  return $game_variables[:DesoPlayerNameOverride] if $game_switches[:DesoSavePassword]
  return $Unidata[:DesoPlayerName]
end

def passwordMintPack
  return if $game_switches[:GameStartPasswords]
  items_to_give = {
    :SERIOUSMINT => 5,
    :LONELYMINT => 5,
    :ADAMANTMINT => 5,
    :NAUGHTYMINT => 5,
    :BRAVEMINT => 5,
    :BOLDMINT => 5,
    :IMPISHMINT => 5,
    :LAXMINT => 5,
    :RELAXEDMINT => 5,
    :MODESTMINT => 5,
    :MILDMINT => 5,
    :RASHMINT => 5,
    :QUIETMINT => 5,
    :CALMMINT => 5,
    :GENTLEMINT => 5,
    :CAREFULMINT => 5,
    :SASSYMINT => 5,
    :TIMIDMINT => 5,
    :HASTYMINT => 5,
    :JOLLYMINT => 5,
    :NAIVEMINT => 5
  }
  items_to_give.each_pair { |item, quantity|
    $PokemonBag.pbStoreItem(item, quantity)
  }
  Kernel.pbMessage(_INTL("\\PN received a package of mints."))
end

def passwordExpAll
  return if $game_switches[:GameStartPasswords]
  $PokemonBag.pbStoreItem(:EXPALL, 1)
  $game_switches[:Exp_All_On] = true
  Kernel.pbMessage(_INTL("\\PN received {1}.", getItemName(:EXPALL, :a)))
end

def passwordShinyCharm
  return if $game_switches[:GameStartPasswords]
  $PokemonBag.pbStoreItem(:SHINYCHARM, 1)
  Kernel.pbMessage(_INTL("\\PN received {1}.", getItemName(:SHINYCHARM, :a)))
end

def passwordGoldenTools
  return if $game_switches[:GameStartPasswords]
  items_to_give = {
    :GOLDENHAMMER => 1,
    :GOLDENAXE => 1,
    :GOLDENLANTERN => 1,
    :GOLDENSURFBOARD => 1,
    :GOLDENCLAWS => 1,
    :GOLDENDRIFTBOARD => 1,
    :GOLDENGAUNTLET => 1,
    :GOLDENWINGS => 1,
    :GOLDENSCUBAGEAR => 1,
    :GOLDENJETPACK => 1,
  }
  items_to_give.each_pair { |item, quantity|
    $PokemonBag.pbStoreItem(item, quantity)
  }
  Kernel.pbMessage(_INTL("\\PN received a set of shiny tools to traverse difficult terrain."))
end

def passwordMegaZRing
  return if $game_switches[:GameStartPasswords]
  $PokemonBag.pbStoreItem(:MEGARING, 1)
  Kernel.pbMessage(_INTL("\\PN received {1}!", getItemName(:MEGARING, :a)))
end

def passwordRemotePC
  return if $game_switches[:GameStartPasswords]
  $PokemonBag.pbStoreItem(:REMOTEPC, 1)
  Kernel.pbMessage(_INTL("\\PN received {1}.", getItemName(:REMOTEPC, :a)))
end

def passwordPowerPack
  return if $game_switches[:GameStartPasswords]
  items_to_give = {
    :HPCARD => 1,
    :ATKCARD => 1,
    :DEFCARD => 1,
    :SPATKCARD => 1,
    :SPDEFCARD => 1,
    :SPEEDCARD => 1,
    :MACHOBRACE => 1,
  }
  items_to_give.each_pair { |item, quantity|
    $PokemonBag.pbStoreItem(item, quantity)
  }
  Kernel.pbMessage(_INTL("\\PN received a package of EV-training gear."))
end

def addPasswordsUserShouldKnow
  if $Unidata[:BadgeCount]
    pbLearnPassword('nointro') if $Unidata[:BadgeCount] >= 1
    pbLearnPassword('terajuma') if $Unidata[:BadgeCount] >= 5
  end
  pbLearnPassword('wll')
  pbLearnPassword('reborn')
  pbLearnPassword('deso')
end

def runPostPasswordMaintenance
  # flip all the field app switches
  if $game_switches[:All_Field_Notes]
    $game_switches[:Field_Notes] = true
    $cache.FEData.each { |key, data|
      $game_switches[data.fieldAppSwitch] = true
    }
  end
end

alias __rejuv_togglePassword pbTogglePassword unless method_defined?(:__rejuv_togglePassword)
def pbTogglePassword(password, item = nil, needsChip = false, isGameStart = false, skipEndMessage: false)
  password_string = password.downcase()
  obj = $cache.passwords[password_string]
  refund = false
  if obj&.checkFlag?(:nocost) == true
    refund = true
    needsChip = false
    item = nil
    skipEndMessage = true
  end
  ret = __rejuv_togglePassword(password, item, needsChip, isGameStart, skipEndMessage: skipEndMessage)
  return false if refund
  return ret
end

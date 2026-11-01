################################################################################
# General purpose utilities
################################################################################
def _pbNextComb(comb, length)
  i = comb.length - 1
  begin
    valid = true
    for j in i...comb.length
      if j == i
        comb[j] += 1
      else
        comb[j] = comb[i] + (j - i)
      end
      if comb[j] >= length
        valid = false
        break
      end
    end
    return true if valid

    i -= 1
  end while i >= 0
  return false
end

# Iterates through the array and yields each combination of _num_ elements in
# the array.
def pbEachCombination(array, num)
  return if array.length < num || num <= 0

  if array.length == num
    yield array
    return
  elsif num == 1
    for x in array
      yield [x]
    end
    return
  end
  currentComb = []
  arr = []
  for i in 0...num
    currentComb[i] = i
  end
  begin
    for i in 0...num
      arr[i] = array[currentComb[i]]
    end
    yield arr
  end while _pbNextComb(currentComb, array.length)
end

def gameGoByeByeNow
  $scene = nil
  return
end

# Returns a language ID
def pbGetLanguage()
  return System.user_language
end

################################################################################
# Player-related utilities, random name generator
################################################################################
def pbChangePlayer(id)
  return false if id < 0

  meta = $cache.metadata[:Players][id]
  return false if !meta

  $Trainer.trainertype = meta[:tclass] if $Trainer
  $PokemonGlobal.playerID = id
  Kernel.pbUpdateVehicle
  $game_player.character_hue = 0
  $Trainer.metaID = id if $Trainer
end

def pbGetPlayerGraphic
  id = $PokemonGlobal.playerID
  return "" if id < 0

  meta = $cache.metadata[:Players][id]
  return "" if !meta

  return pbPlayerSpriteFile(meta[:tclass])
end

def pbGetPlayerID(variableNumber)
  ret = $PokemonGlobal.playerID
  pbSet(variableNumber, ret)
  return nil
end

def pbGetPlayerTrainerType
  id = $PokemonGlobal.playerID
  return 0 if id < 0

  meta = $cache.metadata[:Players][id]
  return 0 if !meta

  return meta[:tclass]
end

def pbGetTrainerTypeGender(trainertype)
  return 2
end

def pbTrainerName(name = nil)
  if $PokemonGlobal.playerID < 0
    pbChangePlayer(0)
  end
  trainertype = pbGetPlayerTrainerType
  trname = name
  if trname == nil
    trname = pbEnterPlayerName(_INTL("Your name?"), 0, 12)
    gender = pbGetTrainerTypeGender(trainertype)
    if trname == ""
      trname = pbSuggestTrainerName(gender, trainertype)
    end
  end
  $Trainer = PokeBattle_Trainer.new(trname, trainertype)
  $PokemonBag = PokemonBag.new
  $PokemonTemp.begunNewGame = true
end

def pbSuggestTrainerName(gender, trainertype)
  if Reborn
    username = pbGetTrainerCanonName(trainertype)
    return username if username
  end
  username = pbGetUserNameEx()
  return username if username
  return getRandomNameEx(gender, nil, 1, 7)
end

def pbGetTrainerCanonName(trainertype)
  hash = $cache.metadata[:Players].find { |i| i[:tclass] == trainertype }
  return nil if hash.nil?
  return hash[:name]
end

def pbGetUserNameEx()
  userName = pbGetUserName()
  userName = userName.gsub(/\s+.*$/, "")
  if userName.length > 0
    userName[0, 1] = userName[0, 1].upcase
    return userName
  end
  userName = userName.gsub(/\d+$/, "")
  if userName.length > 0
    userName[0, 1] = userName[0, 1].upcase
    return userName
  end
  return nil
end

def pbGetUserName()
  return ["Frank", "Johnathan", "Joelle", "Charlene"][rand(4)] if $Settings.streamermode && $Settings.streamermode == 1

  return System.user_name
end

def pbGuessPlayerName()
  username = pbGetUserNameEx()
  return username if username
  dp("couldn't get username [ #{userName}] please report this message: ")
  # owner=MiniRegistry.get(MiniRegistry::HKEY_LOCAL_MACHINE,
  #   "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
  #   "RegisteredOwner","")
  # owner=owner.gsub(/\s+.*$/,"")
  # if owner.length>0 && owner.length<7
  #  owner[0,1]=owner[0,1].upcase
  #  return owner
  # end
  return 0
end

def getRandomNameEx(type, variable, upper, maxLength = 100)
  return "" if maxLength <= 0

  name = ""
  50.times {
    name = ""
    formats = []
    case type
      when 0 # Names for males
        formats = %w(F5 BvE FE FE5 FEvE)
      when 1 # Names for females
        formats = %w(vE6 vEvE6 BvE6 B4 v3 vEv3 Bv3)
      when 2 # Neutral gender names
        formats = %w(WE WEU WEvE BvE BvEU BvEvE)
      else
        return ""
    end
    format = formats[rand(formats.length)]
    format.scan(/./) { |c|
      case c
        when "c" # consonant
          set = %w(b c d f g h j k l m n p r s t v w x z)
          name += set[rand(set.length)]
        when "v" # vowel
          set = %w(a a a e e e i i i o o o u u u)
          name += set[rand(set.length)]
        when "W" # beginning vowel
          set = %w( a a a e e e i i i o o o u u u au au ay ay
                    ea ea ee ee oo oo ou ou )
          name += set[rand(set.length)]
        when "U" # ending vowel
          set = %w(a a a a a e e e i i i o o o o o u u ay ay ie ie ee ue oo)
          name += set[rand(set.length)]
        when "B" # beginning consonant
          set1 = %w(b c d f g h j k l l m n n p r r s s t t v w y z)
          set2 = %w(
            bl br ch cl cr dr fr fl gl gr kh kl kr ph pl pr sc sk sl
            sm sn sp st sw th tr tw vl zh
          )
          name += rand(3) > 0 ? set1[rand(set1.length)] : set2[rand(set2.length)]
        when "E" # ending consonant
          set1 = %w(b c d f g h j k k l l m n n p r r s s t t v z)
          set2 = %w( bb bs ch cs ds fs ft gs gg ld ls
                     nd ng nk rn kt ks
                     ms ns ph pt ps sk sh sp ss st rd
                     rn rp rm rt rk ns th zh)
          name += rand(3) > 0 ? set1[rand(set1.length)] : set2[rand(set2.length)]
        when "f" # consonant and vowel
          set = %w(iz us or)
          name += set[rand(set.length)]
        when "F" # consonant and vowel
          set = %w( bo ba be bu re ro si mi zho se nya gru gruu glee gra glo ra do zo ri
                    di ze go ga pree pro po pa ka ki ku de da ma mo le la li )
          name += set[rand(set.length)]
        when "2"
          set = %w(c f g k l p r s t)
          name += set[rand(set.length)]
        when "3"
          set = %w(nka nda la li ndra sta cha chie)
          name += set[rand(set.length)]
        when "4"
          set = %w(una ona ina ita ila ala ana ia iana)
          name += set[rand(set.length)]
        when "5"
          set = %w(e e o o ius io u u ito io ius us)
          name += set[rand(set.length)]
        when "6"
          set = %w(a a a elle ine ika ina ita ila ala ana)
          name += set[rand(set.length)]
      end
    }
    break if name.length <= maxLength
  }
  name = name[0, maxLength]
  case upper
    when 0
      name = name.upcase
    when 1
      name[0, 1] = name[0, 1].upcase
  end
  if $game_variables && variable
    $game_variables[variable] = name
    $game_map.need_refresh = true if $game_map
  end
  return name
end

def getRandomName(maxLength = 100)
  return getRandomNameEx(2, nil, nil, maxLength)
end

def hidePlayerPossessions?(switches = $game_switches, mapid = $game_map&.map_id)
  return false unless Reborn
  return true if switches && switches[:NotPlayerCharacter]
  return true if mapid == 900 # Another Time
  return false
end

################################################################################
# Character switching in Reborn
################################################################################
def loadTrainerCard(trainername, playerID)
  $Trainer.tempname = $Trainer.name
  $Trainer.name = trainername

  pbChangePlayer(playerID)

  $game_switches[:NotPlayerCharacter] = true
end

def restoreTrainerCard
  $Trainer.name = $Trainer.tempname
  $Trainer.tempname = nil

  playerID = $game_variables[:Player_Sprite]
  pbChangePlayer(playerID)

  $game_switches[:NotPlayerCharacter] = false
end

################################################################################
# Event timing utilities
################################################################################
def pbTimeEvent(variableNumber, secs = 86400)
  if variableNumber && variableNumber >= 0
    if $game_variables
      secs = 0 if secs < 0
      timenow = pbGetTimeNow
      $game_variables[variableNumber] = [timenow.to_f, secs]
      $game_map.refresh if $game_map
    end
  end
end

def pbTimeEventDays(variableNumber, days = 0)
  if variableNumber && variableNumber >= 0
    if $game_variables
      days = 0 if days < 0
      timenow = pbGetTimeNow
      time = timenow.to_f
      expiry = (time % 86400.0) + (days * 86400.0)
      $game_variables[variableNumber] = [time, expiry - time]
      $game_map.refresh if $game_map
    end
  end
end

def pbTimeEventValid(variableNumber)
  retval = false
  if variableNumber && variableNumber >= 0 && $game_variables
    value = $game_variables[variableNumber]
    if value.is_a?(Array)
      timenow = pbGetTimeNow
      retval = (timenow.to_f - value[0] > value[1]) # value[1] is age in seconds
      retval = false if value[1] <= 0 # zero age
    end
    if !retval
      $game_variables[variableNumber] = 0
      $game_map.refresh if $game_map
    end
  end
  return retval
end

################################################################################
# Constants utilities
################################################################################
def hasConst?(mod, constant)
  return false if !mod || !constant || constant == ""

  begin
    return mod.const_defined?(constant.to_sym)
  rescue
    print("broken constant #{constant}")
    print caller
    return false
  end
end

def getConst(mod, constant)
  return nil if !mod || !constant

  begin
    return mod.const_get(constant.to_sym)
  rescue
    return nil
  end
end

def toProperCase(str)
  str = str.to_s if str.is_a?(Symbol)
  split = str.split(" ")
  ret = ""
  split.each { |s|
    ret += s[0].upcase + s[1, s.length].downcase
    ret += " " if split.length != 1
  }
  return ret
end

def nSuperscript(str)
  # When using Power Green Small, returns 4x3 pixel number
  str = str.to_s if str.is_a?(Numeric)

  s = {
    "0" => "\u00b0",
    "1" => "\u00b9",
    "2" => "\u00b2",
    "3" => "\u00b3",
    "4" => "\u2074",
    "5" => "\u2075",
    "6" => "\u2076",
    "7" => "\u2077",
    "8" => "\u2078",
    "9" => "\u2079",
  }

  s.each { |k, v|
    str.gsub!(k, v)
  }
  return str
end

def nSubscript(str)
  # When using Power Green Small, returns 5x3 pixel number
  str = str.to_s if str.is_a?(Numeric)

  s = {
    "0" => "\u2080",
    "1" => "\u2081",
    "2" => "\u2082",
    "3" => "\u2083",
    "4" => "\u2084",
    "5" => "\u2085",
    "6" => "\u2086",
    "7" => "\u2087",
    "8" => "\u2088",
    "9" => "\u2089",
  }

  s.each { |k, v|
    str.gsub!(k, v)
  }
  return str
end

################################################################################
# Implements methods that act on arrays of items.  Each element in an item
# array is itself an array of [itemID, itemCount].
# Used by the Bag, PC item storage, and Triple Triad.
################################################################################
module ItemStorageHelper
  # Returns the quantity of the given item in the items array, maximum size per slot, and item ID
  def self.pbQuantity(items, maxsize, item)
    ret = 0
    for i in 0...maxsize
      itemslot = items[i]
      if itemslot && itemslot[0] == item
        ret += itemslot[1]
      end
    end
    return ret
  end

  # Deletes an item from items array, maximum size per slot, item, and number of items to delete
  def self.pbDeleteItem(items, maxsize, item, qty)
    raise "Invalid value for qty: #{qty}" if qty < 0
    return true if qty == 0

    ret = false
    for i in 0...maxsize
      itemslot = items[i]
      if itemslot && itemslot[0] == item
        amount = [qty, itemslot[1]].min
        itemslot[1] -= amount
        qty -= amount
        items[i] = nil if itemslot[1] == 0
        if qty == 0
          ret = true
          break
        end
      end
    end
    items.compact!
    return ret
  end

  def self.pbCanStore?(items, maxsize, maxPerSlot, item, qty)
    raise "Invalid value for qty: #{qty}" if qty < 0
    return true if qty == 0

    for i in 0...maxsize
      itemslot = items[i]
      if !itemslot
        qty -= [qty, maxPerSlot].min
        return true if qty == 0
      elsif itemslot[0] == item && itemslot[1] < maxPerSlot
        newamt = itemslot[1]
        newamt = [newamt + qty, maxPerSlot].min
        qty -= (newamt - itemslot[1])
        return true if qty == 0
      end
    end
    return false
  end

  def self.pbStoreItem(items, maxsize, maxPerSlot, item, qty, sorting = false)
    raise "Invalid value for qty: #{qty}" if qty < 0
    return true if qty == 0

    for i in 0...maxsize
      itemslot = items[i]
      if !itemslot
        items[i] = [item, [qty, maxPerSlot].min]
        qty -= items[i][1]
        if sorting && POCKETAUTOSORT[pbGetPocket(item)]
          if pbGetPocket(item) == 4
            pocket = items
            counter = 1
            while counter < pocket.length
              index = counter
              while index > 0
                indexPrev = index - 1
                firstName  = (((getItemName(pocket[indexPrev][0])).sub("TM", "00")).sub("X", "100")).to_i
                secondName = (((getItemName(pocket[index][0])).sub("TM", "00")).sub("X", "100")).to_i
                if firstName > secondName
                  aux               = pocket[index]
                  pocket[index]     = pocket[indexPrev]
                  pocket[indexPrev] = aux
                end
                index -= 1
              end
              counter += 1
            end
          elsif pbGetPocket(item) == 5
            items.sort!
          end
        end
        return true if qty == 0
      elsif itemslot[0] == item && itemslot[1] < maxPerSlot
        newamt = itemslot[1]
        newamt = [newamt + qty, maxPerSlot].min
        qty -= (newamt - itemslot[1])
        itemslot[1] = newamt
        return true if qty == 0
      end
    end
    return false
  end
end

################################################################################
# General-purpose utilities with dependencies
################################################################################
# Similar to pbFadeOutIn, but pauses the music as it fades out.
# Requires scripts "Audio" (for bgm_pause) and "SpriteWindow" (for pbFadeOutIn).
def pbFadeOutInWithMusic(zViewport)
  savedBGS, savedBGM, savedBGMpos = pbPauseMusicToResumeLater(true)
  pbFadeOutIn(zViewport) {
    yield
    pbResumePausedMusic(savedBGS, savedBGM, savedBGMpos)
  }
end

def pbPauseMusicToResumeLater(fadeout = false)
  return [nil, nil, 0] unless $game_system && $game_system.is_a?(Game_System)

  savedBGS = $game_system.getPlayingBGS
  savedBGM = $game_system.getPlayingBGM
  savedBGMpos = savedBGM ? Audio.bgm_pos : 0
  $game_system.bgm_pause(fadeout ? 1.0 : 0.0)
  $game_system.bgs_pause(fadeout ? 1.0 : 0.0)
  return [savedBGS, savedBGM, savedBGMpos]
end

def pbResumePausedMusic(savedBGS, savedBGM, savedBGMpos)
  return unless $game_system && $game_system.is_a?(Game_System)

  $game_system.bgs_resume(savedBGS)
  $game_system.bgm_resume(savedBGM, savedBGMpos)
end

def pbHideVisibleObjects
  begin
    visibleObjects = []
    ObjectSpace.each_object(Viewport) { |o|
      if !o.disposed? && o.visible
        visibleObjects.push(o)
        o.visible = false
      end
    }
    ObjectSpace.each_object(Tilemap) { |o|
      if !o.disposed? && o.visible
        visibleObjects.push(o)
        o.visible = false
      end
    }
    # ObjectSpace.each_object(Window){|o|
    #   if !o.disposed? && o.visible
    #     visibleObjects.push(o)
    #     o.visible=false
    #   end
    # }
  rescue
    visibleObjects = []
  end
  return visibleObjects
end

def pbShowObjects(visibleObjects)
  for o in visibleObjects
    if !pbDisposed?(o)
      o.visible = true
    end
  end
end

def pbLoadRpgxpScene(scene)
  return if !$scene.is_a?(Scene_Map)

  oldscene = $scene
  $scene = scene
  Graphics.freeze
  oldscene.disposeSpritesets
  visibleObjects = pbHideVisibleObjects

  Graphics.transition(15)
  Graphics.freeze
  Graphics.update

  while $scene && !$scene.is_a?(Scene_Map)
    $scene.main
  end
  Graphics.transition(15)
  Graphics.freeze
  oldscene.createSpritesets
  pbShowObjects(visibleObjects)
  Graphics.transition(20)
  $scene = oldscene
end

# Runs a common event and waits until the common event is finished.
# Requires the script "PokemonMessages"
def pbCommonEvent(id)
  return false if id < 0

  ce = $cache.RXevents[id]
  return false if !ce

  celist = ce.list
  interp = Interpreter.new
  interp.setup(celist, 0)
  begin
    Graphics.update
    Input.update
    interp.update
    pbUpdateSceneMap
  end while interp.running?
  return true
end

def pbExclaim(event, id = EXCLAMATION_ANIMATION_ID, tinting = false)
  if event.is_a?(Array)
    sprite = nil
    done = []
    for i in event
      if !done.include?(i.id)
        sprite = $scene.spriteset.addUserAnimation(id, i.x, i.y - 1, tinting)
        done.push(i.id)
      end
    end
  else
    sprite = $scene.spriteset.addUserAnimation(id, event.x, event.y - 1, tinting)
  end
  while !sprite.disposed?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

def pbNoticePlayer(event)
  #  if !pbFacingEachOther(event,$game_player)
  pbExclaim(event)
  # end
  pbTurnTowardEvent($game_player, event)
  Kernel.pbMoveTowardPlayer(event)
end

################################################################################
# Loads Pokémon/item/trainer graphics
################################################################################
def basicEggs?
  return $game_switches && $game_switches[:BasicEggs_Password]
end

# Used by the Pokédex
def pbPokemonBitmap(species, shiny = false, back = false, gender = nil, form = 0, shadow = false, egg: false, battle: false, looped: false)
  return false if species == nil

  gender = $Trainer.pokedex[species].lastSeen[:gender] if gender == nil && species != 0 && !looped
  form = $cache.pkmn[species].forms.invert[form] if form.is_a?(String)
  formnumber = form == 0 ? "" : "_#{form}"
  formnumber = form.to_s if Rejuv
  dexnum = $cache.pkmn[species, form].dexnum.to_s.rjust(3, "0")
  dexname = species.to_s.downcase
  toobig = $cache.pkmn[species, form].checkFlag?(:toobig)
  special = nil
  inbattle = ($game_temp && $game_temp.in_battle) || battle
  special = :overworld if !inbattle
  special = :shadow if shadow
  special = :egg if egg

  bitmapFileName = pbCheckPokemonBitmapFiles(
    Desolation ? dexnum : dexname,
    gender: gender,
    shiny: shiny,
    back: back,
    formnumber: formnumber,
    special: special,
    toobig: toobig
  )
  return nil if !pbResolveBitmap(bitmapFileName)

  monbitmap = RPG::Cache.load_bitmap(bitmapFileName)

  bitmap = nil
  rectangle = nil
  gridsize = egg ? 64 : 192 # Egg sprites are 1/3rd in size

  # TODO: Handle sprites in separate PR.
  if Rejuv
    width = monbitmap.width / 2
    width = monbitmap.width if width < gridsize
    x = shiny ? width : 0

    height = monbitmap.height
    height /= 2 unless egg
    height = monbitmap.height if height < gridsize
    y = 0
    y += height if back && height != monbitmap.height

    bitmap = Bitmap.new(width, height)
    rectangle = Rect.new(x, y, width, height)
  else
    if !toobig
      x = shiny ? gridsize : 0
      y = form * gridsize * (egg ? 1 : 2) # No back sprites for eggs
      y += gridsize if back
    else
      x = 0
      y = 0
    end
    maxx = toobig ? monbitmap.width : gridsize
    maxy = toobig ? monbitmap.height : gridsize
    if monbitmap.height <= y
      resetHeight = true
      y = 0
    end

    bitmap = Bitmap.new(maxx, maxy)
    rectangle = Rect.new(x, y, maxx, maxy)
  end

  bitmap.blt(0, 0, monbitmap, rectangle)
  bitmapResize = Bitmap.new(bitmap.width + AURA_SPRITE_OFFSET, bitmap.height + AURA_SPRITE_OFFSET)
  bitmapResize.blt(AURA_SPRITE_OFFSET / 2, AURA_SPRITE_OFFSET / 2, bitmap, Rect.new(0, 0, bitmap.width, bitmap.height))
  bitmap = bitmapResize
  bitmap = makeShadowBitmap(bitmap, bitmap.width, bitmap.height) if shadow
  return bitmap if !resetHeight || Rejuv

  if looped
    dp("#{$cache.pkmn.keys[$cache.pkmn[species, form].dexnum - 1]} form #{form}#{back ? " back" : ""} missing graphic")
    return pbPokemonBitmap(species, shiny, back, nil, 0, shadow, egg: egg, battle: battle, looped: true)
  end
  return pbPokemonBitmap(species, shiny, back, nil, form, shadow, egg: egg, battle: battle, looped: true)
end

def HiddenPowerChanger(mon)
  pbHiddenPower(mon) if !mon.hptype
  oldtype = mon.hptype
  typechoices = [
    _INTL("Bug"), _INTL("Dark"), _INTL("Dragon"), _INTL("Electric"), _INTL("Fairy"), _INTL("Fighting"),
    _INTL("Fire"), _INTL("Flying"), _INTL("Ghost"), _INTL("Grass"), _INTL("Ground"), _INTL("Ice"),
    _INTL("Poison"), _INTL("Psychic"), _INTL("Rock"), _INTL("Steel"), _INTL("Water"), _INTL("Cancel")
  ]
  shouldLoop = true
  while shouldLoop
    shouldLoop = false
    choosetype = Kernel.pbMessage(_INTL("Which type should its move become?"), typechoices, 18)
    case choosetype
      when 0 then newtype = :BUG
      when 1 then newtype = :DARK
      when 2 then newtype = :DRAGON
      when 3 then newtype = :ELECTRIC
      when 4 then newtype = :FAIRY
      when 5 then newtype = :FIGHTING
      when 6 then newtype = :FIRE
      when 7 then newtype = :FLYING
      when 8 then newtype = :GHOST
      when 9 then newtype = :GRASS
      when 10 then newtype = :GROUND
      when 11 then newtype = :ICE
      when 12 then newtype = :POISON
      when 13 then newtype = :PSYCHIC
      when 14 then newtype = :ROCK
      when 15 then newtype = :STEEL
      when 16 then newtype = :WATER
      else newtype = -1
    end
    if newtype == -1
      Kernel.pbMessage(_INTL("Changed your mind?"))
      return false
    end
    if choosetype >= 0 && choosetype < 17 && newtype != oldtype
      mon.hptype = newtype
      return true
    end
    if newtype == oldtype
      Kernel.pbMessage(_INTL("It's already that type!"))
      shouldLoop = true
    else
      Kernel.pbMessage(_INTL("Changed your mind?"))
    end
  end
  return false
end

# This is a lie now; leaving it in case we care later: Note: Returns an AnimatedBitmap, not a Bitmap
def pbLoadPokemonBitmap(pokemon, back = false, battle: false)
  # load dummy bitmap
  # ret=AnimatedBitmap.new(pbResolveBitmap("Graphics/pixel"))
  return Bitmap.new(pbResolveBitmap("Graphics/Battlers/substitute#{back ? "_b" : ""}")) if pokemon == "substitute"

  inbattle = ($game_temp && $game_temp.in_battle) || battle

  species = pokemon.species
  form = pokemon.form
  dexnum = pokemon.getCacheData.dexnum.to_s.rjust(3, "0")
  dexname = species.to_s.downcase
  toobig = pokemon.getCacheData.checkFlag?(:toobig)
  formnumber = form == 0 ? "" : "_#{form}"
  formnumber = form.to_s if Rejuv
  special = nil
  inbattle = ($game_temp && $game_temp.in_battle) || battle
  special = :overworld if !inbattle
  special = :shadow if pokemon.isShadow?
  special = :egg if pokemon.isEgg?

  bitmapFileName = pbCheckPokemonBitmapFiles(
    Desolation ? dexnum : dexname,
    gender: pokemon.gender,
    shiny: pokemon.isShiny?,
    back: back,
    formnumber: formnumber,
    special: special,
    toobig: toobig
  )

  spritesheet = RPG::Cache.load_bitmap(bitmapFileName)

  bitmap = nil
  rectangle = nil
  gridsize = pokemon.isEgg? ? 64 : 192 # Egg sprites are 1/3rd in size

  # TODO: Handle sprites in separate PR.
  if Rejuv
    width = spritesheet.width / 2
    width = spritesheet.width if width < gridsize

    height = spritesheet.height
    height /= 2 unless pokemon.isEgg?
    height = spritesheet.height if height < gridsize

    x = pokemon.isShiny? ? width : 0
    y = 0
    y += height if back && height != spritesheet.height

    bitmap = Bitmap.new(width, height)
    rectangle = Rect.new(x, y, width, height)
  else
    x = pokemon.isShiny? ? gridsize : 0
    x = 0 if pokemon.isPulse? || pokemon.isRift? || (pokemon.isEgg? && basicEggs?) || toobig

    y = form * gridsize * (pokemon.isEgg? ? 1 : 2) # No back sprites for eggs
    y += gridsize if back
    y = 0 if toobig

    if spritesheet.height <= y && pokemon.isFemale? && !pokemon.isEgg? # Has female sprite, but its form isn't on the female sheet
      bitmapFileName = pbCheckPokemonBitmapFiles(Reborn ? dexname : dexnum)
      spritesheet = RPG::Cache.load_bitmap(bitmapFileName)
    end

    if spritesheet.height <= y
      y = back ? gridsize : 0
    end

    bitmap = toobig ? spritesheet : Bitmap.new(gridsize, gridsize)
    rectangle = Rect.new(x, y, gridsize, gridsize)
  end

  bitmap.blt(0, 0, spritesheet, rectangle)
  bitmapResize = Bitmap.new(bitmap.width + AURA_SPRITE_OFFSET, bitmap.height + AURA_SPRITE_OFFSET)
  bitmapResize.blt(AURA_SPRITE_OFFSET / 2, AURA_SPRITE_OFFSET / 2, bitmap, Rect.new(0, 0, bitmap.width, bitmap.height))
  bitmap = bitmapResize
  if pokemon.species == :SPINDA && !pokemon.isEgg?
    pbSpindaSpots(pokemon, bitmap)
  end
  bitmap = pbModifyPokemonSprite(pokemon, bitmap)
  return bitmap
end

def makePrismBitmap(bitmap, width, height)
  colors = bitmap.raw_data.unpack("I*").map { |i| i.to_color }
  min = width + 1
  max = -1
  for x in 0...width / 2
    for y in 0...height / 2
      color = colors[bitmap.pixel(x * 2, y * 2)]
      next if color.alpha != 255

      if x < min
        min = x
      end
      if x > max
        max = x
      end
    end
  end
  max += 2
  min -= 2
  # hacky stuff to cheat intiializing to stay within gradient
  size = (max - min)
  add = 0

  for x in 0...width / 2
    if x >= min
      rgb = hslToRGB(0 + add, 100, 50)
      rainbowAura1 = Color.new(rgb[0], rgb[1], rgb[2], 200)
      rainbowAura2 = Color.new(rgb[0], rgb[1], rgb[2], 70)
      add += (360 / size)
    end
    for y in 0...height / 2
      realX = x * 2
      realY = y * 2
      color = colors[bitmap.pixel(realX, realY)]
      next if color.alpha == 255

      # aura
      # first layer
      testX = realX + 2
      if testX < width
        offsetColor = colors[bitmap.pixel(testX, realY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = rainbowAura1
          colors[bitmap.pixel(realX + 1, realY)] = rainbowAura1
          colors[bitmap.pixel(realX + 1, realY + 1)] = rainbowAura1
          colors[bitmap.pixel(realX, realY + 1)] = rainbowAura1
          next
        end
      end

      testX = realX - 2
      if testX > 0
        offsetColor = colors[bitmap.pixel(testX, realY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = rainbowAura1
          colors[bitmap.pixel(realX + 1, realY)] = rainbowAura1
          colors[bitmap.pixel(realX + 1, realY + 1)] = rainbowAura1
          colors[bitmap.pixel(realX, realY + 1)] = rainbowAura1
          next
        end
      end

      testY = realY + 2
      if testY < height
        offsetColor = colors[bitmap.pixel(realX, testY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = rainbowAura1
          colors[bitmap.pixel(realX + 1, realY)] = rainbowAura1
          colors[bitmap.pixel(realX + 1, realY + 1)] = rainbowAura1
          colors[bitmap.pixel(realX, realY + 1)] = rainbowAura1
          next
        end
      end

      testY = realY - 2
      if testY > 0
        offsetColor = colors[bitmap.pixel(realX, testY)]
        if offsetColor && offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = rainbowAura1
          colors[bitmap.pixel(realX + 1, realY)] = rainbowAura1
          colors[bitmap.pixel(realX + 1, realY + 1)] = rainbowAura1
          colors[bitmap.pixel(realX, realY + 1)] = rainbowAura1
          next
        end
      end

      # second layer
      testX = realX + 4
      if testX < width
        offsetColor = colors[bitmap.pixel(testX, realY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = rainbowAura2
          colors[bitmap.pixel(realX + 1, realY)] = rainbowAura2
          colors[bitmap.pixel(realX + 1, realY + 1)] = rainbowAura2
          colors[bitmap.pixel(realX, realY + 1)] = rainbowAura2
          next
        end
      end

      testX = realX - 4
      if testX > 0
        offsetColor = colors[bitmap.pixel(testX, realY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = rainbowAura2
          colors[bitmap.pixel(realX + 1, realY)] = rainbowAura2
          colors[bitmap.pixel(realX + 1, realY + 1)] = rainbowAura2
          colors[bitmap.pixel(realX, realY + 1)] = rainbowAura2
          next
        end
      end

      testY = realY + 4
      if testY < height
        offsetColor = colors[bitmap.pixel(realX, testY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = rainbowAura2
          colors[bitmap.pixel(realX + 1, realY)] = rainbowAura2
          colors[bitmap.pixel(realX + 1, realY + 1)] = rainbowAura2
          colors[bitmap.pixel(realX, realY + 1)] = rainbowAura2
          next
        end
      end

      testY = realY - 4
      if testY > 0
        offsetColor = colors[bitmap.pixel(realX, testY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = rainbowAura2
          colors[bitmap.pixel(realX + 1, realY)] = rainbowAura2
          colors[bitmap.pixel(realX + 1, realY + 1)] = rainbowAura2
          colors[bitmap.pixel(realX, realY + 1)] = rainbowAura2
          next
        end
      end

      for i in 0...4
        case i
          when 0
            testX = realX + 2
            testY = realY + 2
          when 1
            testX = realX - 2
            testY = realY + 2
          when 2
            testX = realX + 2
            testY = realY - 2
          when 3
            testX = realX - 2
            testY = realY - 2
        end
        if testY < height && testX < width
          offsetColor = colors[bitmap.pixel(testX, testY)]
          if offsetColor.alpha == 255
            colors[bitmap.pixel(realX, realY)] = rainbowAura2
            colors[bitmap.pixel(realX + 1, realY)] = rainbowAura2
            colors[bitmap.pixel(realX + 1, realY + 1)] = rainbowAura2
            colors[bitmap.pixel(realX, realY + 1)] = rainbowAura2
            next
          end
        end
      end
    end
  end
  bitmap.raw_data = colors.map { |c| c.to_i }.pack("I*")
  return bitmap
end

def makeShadowBitmap(bitmap, width, height)
  shadowAura1 = Color.new(220, 90, 255, 200)
  shadowAura2 = Color.new(220, 90, 255, 70)
  colors = bitmap.raw_data.unpack("I*").map { |i| i.to_color }
  for x in 0...width / 2
    for y in 0...height / 2
      realX = x * 2
      realY = y * 2
      color = colors[bitmap.pixel(realX, realY)]

      if color.alpha == 255
        # purplfy them
        rgb = [grayscale(color, :L)] * 3
        hsl = rgbToHSL(rgb[0], rgb[1], rgb[2])
        hsl[0] = 270
        hsl[1] = 75
        rgb = hslToRGB(hsl[0], hsl[1], hsl[2])
        shadowCol = Color.new(rgb[0], rgb[1], rgb[2])
        colors[bitmap.pixel(realX, realY)] = shadowCol
        colors[bitmap.pixel(realX + 1, realY)] = shadowCol
        colors[bitmap.pixel(realX + 1, realY + 1)] = shadowCol
        colors[bitmap.pixel(realX, realY + 1)] = shadowCol
        next
      else
        # aura
        # first layer
        testX = realX + 2
        if testX < width
          offsetColor = colors[bitmap.pixel(testX, realY)]
          if offsetColor.alpha == 255
            colors[bitmap.pixel(realX, realY)] = shadowAura1
            colors[bitmap.pixel(realX + 1, realY)] = shadowAura1
            colors[bitmap.pixel(realX + 1, realY + 1)] = shadowAura1
            colors[bitmap.pixel(realX, realY + 1)] = shadowAura1
            next
          end
        end

        testX = realX - 2
        if testX > 0
          offsetColor = colors[bitmap.pixel(testX, realY)]
          if offsetColor.alpha == 255
            colors[bitmap.pixel(realX, realY)] = shadowAura1
            colors[bitmap.pixel(realX + 1, realY)] = shadowAura1
            colors[bitmap.pixel(realX + 1, realY + 1)] = shadowAura1
            colors[bitmap.pixel(realX, realY + 1)] = shadowAura1
            next
          end
        end

        testY = realY + 2
        if testY < height
          offsetColor = colors[bitmap.pixel(realX, testY)]
          if offsetColor.alpha == 255
            colors[bitmap.pixel(realX, realY)] = shadowAura1
            colors[bitmap.pixel(realX + 1, realY)] = shadowAura1
            colors[bitmap.pixel(realX + 1, realY + 1)] = shadowAura1
            colors[bitmap.pixel(realX, realY + 1)] = shadowAura1
            next
          end
        end

        testY = realY - 2
        if testY > 0
          offsetColor = colors[bitmap.pixel(realX, testY)]
          if offsetColor.alpha == 255
            colors[bitmap.pixel(realX, realY)] = shadowAura1
            colors[bitmap.pixel(realX + 1, realY)] = shadowAura1
            colors[bitmap.pixel(realX + 1, realY + 1)] = shadowAura1
            colors[bitmap.pixel(realX, realY + 1)] = shadowAura1
            next
          end
        end

        # second layer
        testX = realX + 4
        if testX < width
          offsetColor = colors[bitmap.pixel(testX, realY)]
          if offsetColor.alpha == 255
            colors[bitmap.pixel(realX, realY)] = shadowAura2
            colors[bitmap.pixel(realX + 1, realY)] = shadowAura2
            colors[bitmap.pixel(realX + 1, realY + 1)] = shadowAura2
            colors[bitmap.pixel(realX, realY + 1)] = shadowAura2
            next
          end
        end

        testX = realX - 4
        if testX > 0
          offsetColor = colors[bitmap.pixel(testX, realY)]
          if offsetColor.alpha == 255
            colors[bitmap.pixel(realX, realY)] = shadowAura2
            colors[bitmap.pixel(realX + 1, realY)] = shadowAura2
            colors[bitmap.pixel(realX + 1, realY + 1)] = shadowAura2
            colors[bitmap.pixel(realX, realY + 1)] = shadowAura2
            next
          end
        end

        testY = realY + 4
        if testY < height
          offsetColor = colors[bitmap.pixel(realX, testY)]
          if offsetColor.alpha == 255
            colors[bitmap.pixel(realX, realY)] = shadowAura2
            colors[bitmap.pixel(realX + 1, realY)] = shadowAura2
            colors[bitmap.pixel(realX + 1, realY + 1)] = shadowAura2
            colors[bitmap.pixel(realX, realY + 1)] = shadowAura2
            next
          end
        end

        testY = realY - 4
        if testY > 0
          offsetColor = colors[bitmap.pixel(realX, testY)]
          if offsetColor.alpha == 255
            colors[bitmap.pixel(realX, realY)] = shadowAura2
            colors[bitmap.pixel(realX + 1, realY)] = shadowAura2
            colors[bitmap.pixel(realX + 1, realY + 1)] = shadowAura2
            colors[bitmap.pixel(realX, realY + 1)] = shadowAura2
            next
          end
        end

        for i in 0...4
          case i
            when 0
              testX = realX + 2
              testY = realY + 2
            when 1
              testX = realX - 2
              testY = realY + 2
            when 2
              testX = realX + 2
              testY = realY - 2
            when 3
              testX = realX - 2
              testY = realY - 2
          end
          if testY < height && testX < width
            offsetColor = colors[bitmap.pixel(testX, testY)]
            if offsetColor.alpha == 255
              colors[bitmap.pixel(realX, realY)] = shadowAura2
              colors[bitmap.pixel(realX + 1, realY)] = shadowAura2
              colors[bitmap.pixel(realX + 1, realY + 1)] = shadowAura2
              colors[bitmap.pixel(realX, realY + 1)] = shadowAura2
              next
            end
          end
        end
      end
    end
  end
  bitmap.raw_data = colors.map { |c| c.to_i }.pack("I*")
  return bitmap
end

def makeGrayscaleBitmap(bitmap, width, height)
  colors = bitmap.raw_data.unpack("I*").map { |i| i.to_color }
  for x in 0...width / 2
    for y in 0...height / 2
      realX = x * 2
      realY = y * 2
      pixcolor = colors[bitmap.pixel(realX, realY)]
      next if pixcolor.alpha != 255

      lightness = grayscale(pixcolor, :L)
      color = Color.new(lightness, lightness, lightness)
      colors[bitmap.pixel(realX, realY)] = color
      colors[bitmap.pixel(realX + 1, realY)] = color
      colors[bitmap.pixel(realX, realY + 1)] = color
      colors[bitmap.pixel(realX + 1, realY + 1)] = color
    end
  end
  bitmap.raw_data = colors.map { |c| c.to_i }.pack("I*")
  return bitmap
end

def makeAuraBitmap(bitmap, width, height, auraColor1, auraColor2, opacity = 200)
  # ensure the bounds exist while testing
  colors = bitmap.raw_data.unpack("I*").map { |i| i.to_color }
  min = width + 1
  max = -1
  for x in 0...width / 2
    for y in 0...height / 2
      color = colors[bitmap.pixel(x * 2, y * 2)]
      next if color.alpha != 255

      if x < min
        min = x
      end
      if x > max
        max = x
      end
    end
  end
  max += 2
  min -= 2
  # hacky stuff to cheat intiializing to stay within gradient
  size = (max - min)
  dir = 1
  auraCount = 0

  for x in 0...width / 2
    if x >= min && x <= max
      percent = (auraCount.to_f / (size / 7.0))

      red = auraColor1.red + percent * (auraColor2.red - auraColor1.red)
      red = red.clamp(0, 255)
      green = auraColor1.green + percent * (auraColor2.green - auraColor1.green)
      green = green.clamp(0, 255)
      blue = auraColor1.blue + percent * (auraColor2.blue - auraColor1.blue)
      blue = blue.clamp(0, 255)
      dir *= -1 if percent >= 1 || percent < 0

      aura1 = Color.new(red, green, blue, opacity)
      aura2 = Color.new(red, green, blue, opacity - 130)
      auraCount += dir
    end
    for y in 0...height / 2
      realX = x * 2
      realY = y * 2
      color = colors[bitmap.pixel(realX, realY)]
      next if color.alpha == 255

      # aura
      # first layer
      testX = realX + 2
      if testX < width
        offsetColor = colors[bitmap.pixel(testX, realY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = aura1
          colors[bitmap.pixel(realX + 1, realY)] = aura1
          colors[bitmap.pixel(realX + 1, realY + 1)] = aura1
          colors[bitmap.pixel(realX, realY + 1)] = aura1
          next
        end
      end

      testX = realX - 2
      if testX > 0
        offsetColor = colors[bitmap.pixel(testX, realY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = aura1
          colors[bitmap.pixel(realX + 1, realY)] = aura1
          colors[bitmap.pixel(realX + 1, realY + 1)] = aura1
          colors[bitmap.pixel(realX, realY + 1)] = aura1
          next
        end
      end

      testY = realY + 2
      if testY < height
        offsetColor = colors[bitmap.pixel(realX, testY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = aura1
          colors[bitmap.pixel(realX + 1, realY)] = aura1
          colors[bitmap.pixel(realX + 1, realY + 1)] = aura1
          colors[bitmap.pixel(realX, realY + 1)] = aura1
          next
        end
      end

      testY = realY - 2
      if testY > 0
        offsetColor = colors[bitmap.pixel(realX, testY)]
        if offsetColor && offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = aura1
          colors[bitmap.pixel(realX + 1, realY)] = aura1
          colors[bitmap.pixel(realX + 1, realY + 1)] = aura1
          colors[bitmap.pixel(realX, realY + 1)] = aura1
          next
        end
      end

      # second layer
      testX = realX + 4
      if testX < width
        offsetColor = colors[bitmap.pixel(testX, realY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = aura2
          colors[bitmap.pixel(realX + 1, realY)] = aura2
          colors[bitmap.pixel(realX + 1, realY + 1)] = aura2
          colors[bitmap.pixel(realX, realY + 1)] = aura2
          next
        end
      end

      testX = realX - 4
      if testX > 0
        offsetColor = colors[bitmap.pixel(testX, realY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = aura2
          colors[bitmap.pixel(realX + 1, realY)] = aura2
          colors[bitmap.pixel(realX + 1, realY + 1)] = aura2
          colors[bitmap.pixel(realX, realY + 1)] = aura2
          next
        end
      end

      testY = realY + 4
      if testY < height
        offsetColor = colors[bitmap.pixel(realX, testY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = aura2
          colors[bitmap.pixel(realX + 1, realY)] = aura2
          colors[bitmap.pixel(realX + 1, realY + 1)] = aura2
          colors[bitmap.pixel(realX, realY + 1)] = aura2
          next
        end
      end

      testY = realY - 4
      if testY > 0
        offsetColor = colors[bitmap.pixel(realX, testY)]
        if offsetColor.alpha == 255
          colors[bitmap.pixel(realX, realY)] = aura2
          colors[bitmap.pixel(realX + 1, realY)] = aura2
          colors[bitmap.pixel(realX + 1, realY + 1)] = aura2
          colors[bitmap.pixel(realX, realY + 1)] = aura2
          next
        end
      end

      for i in 0...4
        case i
          when 0
            testX = realX + 2
            testY = realY + 2
          when 1
            testX = realX - 2
            testY = realY + 2
          when 2
            testX = realX + 2
            testY = realY - 2
          when 3
            testX = realX - 2
            testY = realY - 2
        end
        if testY < height && testX < width
          offsetColor = colors[bitmap.pixel(testX, testY)]
          if offsetColor.alpha == 255
            colors[bitmap.pixel(realX, realY)] = aura2
            colors[bitmap.pixel(realX + 1, realY)] = aura2
            colors[bitmap.pixel(realX + 1, realY + 1)] = aura2
            colors[bitmap.pixel(realX, realY + 1)] = aura2
            next
          end
        end
      end
    end
  end
  bitmap.raw_data = colors.map { |c| c.to_i }.pack("I*")
  return bitmap
end

def pbCheckPokemonBitmapFiles(pkmn, gender: nil, shiny: false, back: false, formnumber: "", special: "", toobig: false)
  folder = "Graphics/Battlers/"
  isEgg = special == :egg
  isOverworld = special == :overworld
  isShadow = special == :shadow
  gendermod = gender == :F ? (!Desolation || isEgg ? "" : "_") + "f" : ""

  special = "" if special.is_a?(Symbol)
  special = "o" if isOverworld
  special = "_shadow" if isShadow

  if !Rejuv
    if toobig
      shinytag = shiny ? "s" : ""
      backtag = back ? "b" : ""
      bitmapFileName = sprintf("%s%s%s%s%s%s", folder, pkmn, gendermod, shinytag, backtag, formnumber)
      bitmapFileName = sprintf("%s%s%s%s%s", folder, pkmn, shinytag, backtag, formnumber) if !pbResolveBitmap(bitmapFileName)
    else
      if isEgg
        special = Desolation ? "Egg" : "egg"
        bitmapFileName = sprintf("%s%s%s%s", folder, pkmn, gendermod, special)
        bitmapFileName = sprintf("%s%s%s", folder, pkmn, special) if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("%s%s", folder, special) if !pbResolveBitmap(bitmapFileName) || basicEggs?
      else
        bitmapFileName = sprintf("%s%s%s%s", folder, pkmn, gendermod, special)
        bitmapFileName = sprintf("%s%s%s", folder, pkmn, special) if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("%s%s%s", folder, pkmn, gendermod) if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("%s%s", folder, pkmn) if !pbResolveBitmap(bitmapFileName)
      end
    end
  else
    if isEgg
      special = "egg"
      bitmapFileName = sprintf("%s%s/%s%s%s", folder, pkmn, formnumber, gendermod, special)
      bitmapFileName = sprintf("%s%s/%s%s", folder, pkmn, formnumber, special) if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("%s%s", folder, special) if !pbResolveBitmap(bitmapFileName) || basicEggs?
    else
      bitmapFileName = sprintf("%s%s/%s%s%s", folder, pkmn, formnumber, gendermod, special)
      bitmapFileName = sprintf("%s%s/%s%s", folder, pkmn, formnumber, special) if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("%s%s/%s%s", folder, pkmn, formnumber, gendermod) if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("%s%s/%s", folder, pkmn, formnumber) if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("%s%s/0", folder, pkmn) if !pbResolveBitmap(bitmapFileName) # base form
    end
  end

  return bitmapFileName if pbResolveBitmap(bitmapFileName)
  return pbResolveBitmap(sprintf("%ssubstitute", folder))
end

def pbPokemonIconBitmap(pokemon, vleague: false) # pbpokemonbitmap, but for icons
  species = pokemon.species
  form = pokemon.form
  shiny = pokemon.isShiny?
  girl = pokemon.isFemale?
  egg = pokemon.isEgg?
  shadow = (pokemon.isShadow? rescue false)
  overworld = !($game_switches && $game_switches[:In_Battle])
  petrified = pokemon.status == :PETRIFIED
  return pbIconBitmap(species, form, shiny, girl, egg, shadow, overworld, petrified: petrified, vleague: vleague)
end

def pbIconBitmap(species, form = 0, shiny = false, girl = false, egg = false, shadow = false, overworld = true, petrified: false, vleague: false)
  $cache.pkmn[species] rescue return RPG::Cache.load_bitmap("Graphics/Icons/Pokemon/icon000") # Use ? if cache access fails
  raise "#{species} has form nil" if form.nil?

  dexnum = "icon#{$cache.pkmn[species, form].dexnum.to_s.rjust(3, "0")}"
  dexname = species.downcase
  width = 128
  height = 64
  x = shiny ? width : 0
  x = 0 if egg && basicEggs?
  y = form * height
  filename = pbCheckPokemonIconFiles(
    Reborn ? dexname : dexnum,
    girl: girl,
    egg: egg,
    overworld: overworld,
    vleague: vleague,
  )
  iconbitmap = RPG::Cache.load_bitmap(filename)
  if iconbitmap.height <= y && girl && !egg # Has female sprite, but its form isn't on the female sheet
    filename = pbCheckPokemonIconFiles(Reborn ? dexname : dexnum)
    iconbitmap = RPG::Cache.load_bitmap(filename)
  end
  if vleague
    width = iconbitmap.width
    height = iconbitmap.height
  end
  bitmap = Bitmap.new(width, height)
  x = 0 if iconbitmap.width <= x
  y = 0 if iconbitmap.height <= y
  rectangle = Rect.new(x, y, width, height)
  bitmap.blt(0, 0, iconbitmap, rectangle)

  # Move sprites to a bigger bitmap to account for auras
  width = bitmap.width
  height = bitmap.height
  singleWidth = width / 2
  leftRect = Rect.new(0, 0, singleWidth, height)
  leftBmp = Bitmap.new(singleWidth+ AURA_SPRITE_OFFSET, height + AURA_SPRITE_OFFSET)
  leftBmp.blt(AURA_SPRITE_OFFSET / 2, AURA_SPRITE_OFFSET / 2, bitmap, leftRect)

  rightRect = Rect.new(singleWidth, 0, singleWidth, height)
  rightBmp = Bitmap.new(singleWidth+ AURA_SPRITE_OFFSET, height + AURA_SPRITE_OFFSET)
  rightBmp.blt(AURA_SPRITE_OFFSET / 2, AURA_SPRITE_OFFSET / 2, bitmap, rightRect)

  fullBmp = Bitmap.new(leftBmp.width + rightBmp.width, height + AURA_SPRITE_OFFSET)
  fullBmp.blt(0, 0, leftBmp, leftBmp.rect)
  fullBmp.blt(leftBmp.width, 0, rightBmp, rightBmp.rect)

  fullBmp = makeShadowBitmap(fullBmp, fullBmp.width, fullBmp.height) if shadow
  fullBmp = makeGrayscaleBitmap(fullBmp, fullBmp.width, fullBmp.height) if petrified
  return fullBmp
end

def pbCheckPokemonIconFiles(species, girl: false, egg: false, overworld: true, vleague: false)
  folder = "Graphics/Icons/Pokemon/"
  gendermod = girl ? "f" : ""

  if egg
    special = "egg"
    filename = sprintf("%s%s%s%s", folder, species, gendermod, special)
    filename = sprintf("%s%s%s", folder, species, special) if !pbResolveBitmap(filename)
    filename = sprintf("%siconEgg", folder) if !pbResolveBitmap(filename) || basicEggs?
  elsif vleague
    special = "vleague"
    filename = sprintf("%s%s%s", folder, special, species)
  else
    special = overworld ? "o" : ""
    filename = sprintf("%s%s%s%s", folder, species, gendermod, special)
    filename = sprintf("%s%s%s", folder, species, special) if !pbResolveBitmap(filename)
    filename = sprintf("%s%s%s", folder, species, gendermod) if !pbResolveBitmap(filename)
    filename = sprintf("%s%s", folder, species) if !pbResolveBitmap(filename)
  end

  return filename if pbResolveBitmap(filename)
  return sprintf("%sicon000", folder)
end

def getColorShadow(*color, percent: 30)
  if color[0].is_a?(Color)
    red = color[0].red
    green = color[0].green
    blue = color[0].blue
  elsif color.length == 3
    red, green, blue = color
  else
    dp("Invalid color supplied: #{color}")
    return *color
  end
  hsl = rgbToHSL(red, green, blue)
  hsl[2] *= (percent / 100.0)
  return Color.new(*hslToRGB(*hsl))
end

def rgbToHSL(red, green, blue)
  red /= 255.0
  green /= 255.0
  blue /= 255.0
  max = [red, green, blue].max
  min = [red, green, blue].min
  hue = (max + min) / 2.0
  sat = (max + min) / 2.0
  light = (max + min) / 2.0

  if (max == min)
    hue = 0
    sat = 0
  else
    d = max - min;
    sat = light >= 0.5 ? d / (2.0 - max - min) : d / (max + min)
    case max
      when red
        hue = (green - blue) / d + (green < blue ? 6.0 : 0)
      when green
        hue = (blue - red) / d + 2.0
      when blue
        hue = (red - green) / d + 4.0
    end
    hue /= 6.0
  end
  return [(hue * 360), (sat * 100), (light * 100)]
end

def hslToRGB(hue, sat, light)
  hue = hue / 360.0
  sat = sat / 100.0
  light = light / 100.0

  red = 0.0
  green = 0.0
  blue = 0.0

  if (sat == 0.0)
    red = light.to_f
    green = light.to_f
    blue = light.to_f
  else
    q = light < 0.5 ? light * (1 + sat) : light + sat - light * sat
    p = 2 * light - q
    red = hueToRGB(p, q, hue + 1 / 3.0)
    green = hueToRGB(p, q, hue)
    blue = hueToRGB(p, q, hue - 1 / 3.0)
  end

  return [(red * 255), (green * 255), (blue * 255)]
end

def hueToRGB(p, q, t)
  t += 1 if t < 0
  t -= 1                                 if t > 1
  return p + (q - p) * 6 * t             if t < 1 / 6.0
  return q                               if t < 1 / 2.0
  return p + (q - p) * (2 / 3.0 - t) * 6 if t < 2 / 3.0

  return p
end

def grayscale(col, method)
  case method
    when :L # luminance
      return (col.red * 0.2989 + col.green * 0.587 + col.blue * 0.114).floor
    when :A # average
      return ([col.red, col.green, col.blue].sum / 3).floor
    when :S # sight
      return (0.2126 * col.red + 0.7152 * col.green + 0.0722 * col.blue).floor
    else
      return col
  end
end

class Bitmap
  def pixel(x, y)
    return x + (y * self.width)
  end
end

class Color
  def to_i
    return self.alpha.to_i << 24 | self.blue.to_i << 16 | self.green.to_i << 8 | self.red.to_i
  end
end

class Integer
  def to_color
    a = self >> 24
    b = self >> 16 & 0xff
    g = self >> 8 & 0xff
    r = self & 0xff
    return Color.new(r, g, b, a)
  end
end

def checkStringBracketSyntax(string, key)
  stack = []
  convert = { "[" => "]", "{" => "}", "(" => ")" }
  for char in 0...string.length
    stack.push(string[char]) if string[char] == "[" || string[char] == "{" || string[char] == "("
    if string[char] == "]" || string[char] == "}" || string[char] == ")"
      if string[char] != convert[stack.last]
        raise "#{key} syntax error, check your code"
        break
      end
      stack.pop
    end
  end
  return stack.empty?
end

class TrueClass
  def to_i
    return 1
  end
end

class FalseClass
  def to_i
    return 0
  end
end

# Preserving these so cass' scripts can still work if this is uncommented
=begin
def pbPokemonIconFile(pokemon)
  # bitmapFileName = pbResolveBitmap(sprintf("Graphics/Icons/icon000"))
  bitmapFileName = pbCheckPokemonIconFiles([pokemon.species, pokemon.isFemale?, pokemon.isShiny?, (pokemon.form rescue 0), (pokemon.isShadow? rescue false)], pokemon.isEgg?)
  return bitmapFileName
end

def pbCheckPokemonIconFiles(params, egg = false)
  species = params[0]
  if egg
    formnumber = params[3].to_s rescue 0
    formmodifier = formnumber != 0 && formnumber != "0" ? "_" + formnumber.to_s : ""
    shiny = params[2] ? "s" : ""
    gendermod = params[1] ? "f" : ""
    bitmapFileName = sprintf("Graphics/Icons/icon%03d%s%s%segg", species, gendermod, shiny, formmodifier) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Icons/icon%segg", species) rescue nil
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Icons/icon%03d%segg", species, formmodifier)
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Icons/icon%03degg", species)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Icons/iconEgg")
          end
        end
      end
    end
    return pbResolveBitmap(bitmapFileName)
  else
    factors = []
    factors.push([4, params[4], false]) if params[4] && params[4] != false     # shadow
    factors.push([1, params[1], false]) if params[1] && params[1] != false     # gender
    factors.push([2, params[2], false]) if params[2] && params[2] != false     # shiny
    factors.push([3, params[3].to_s, ""]) if params[3] && params[3].to_s != "" && params[3].to_s != "0" # form
    tshadow = false
    tgender = false
    tshiny = false
    tform = ""
    for i in 0...2**factors.length
      for j in 0...factors.length
        case factors[j][0]
          when 1   # gender
            tgender = ((i / (2**j)) % 2 == 0) ? factors[j][1] : factors[j][2]
          when 2   # shiny
            tshiny = ((i / (2**j)) % 2 == 0) ? factors[j][1] : factors[j][2]
          when 3   # form
            tform = ((i / (2**j)) % 2 == 0) ? factors[j][1] : factors[j][2]
          when 4   # shadow
            tshadow = ((i / (2**j)) % 2 == 0) ? factors[j][1] : factors[j][2]
        end
      end
      bitmapFileName = sprintf(
        "Graphics/Icons/icon%s%s%s%s%s",
        species,
        tgender ? "f" : "",
        tshiny ? "s" : "",
        (tform != "" ? "_" + tform : ""),
        tshadow ? "_shadow" : ""
      ) rescue nil
      ret = pbResolveBitmap(bitmapFileName)
      return ret if ret

      bitmapFileName = sprintf("Graphics/Icons/icon%03d%s%s%s%s", species, tgender ? "f" : "", tshiny ? "s" : "", (tform != "" ? "_" + tform : ""), tshadow ? "_shadow" : "")
      ret = pbResolveBitmap(bitmapFileName)
      return ret if ret
    end
  end
  return pbResolveBitmap(sprintf("Graphics/Icons/icon000"))
end
=end

def pbPokemonTypeBitmap(type)
  return RPG::Cache.load_bitmap(sprintf("Graphics/Icons/type#{type}.png"))
end

def typeIcon(type)
  return "<icon=type#{type}>"
end

def typeIcons(*types)
  return types.map{ |t| typeIcon(t) }.join(" ")
end

def ttsTypeIconsInText(text)
  icons = text.scan(/<icon=type([^>]+)>/)
  return if icons.empty?
  tts(icons.flatten.map{ |icon| getTypeName(icon.intern) }.join(" "))
end

def pbPokemonFootprintFile(species) # Used by the Pokédex
  return nil if !species

  bitmapFileName = sprintf("Graphics/Icons/Footprints/footprint%s", species) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Icons/Footprints/footprint%03d", species)
  end
  return pbResolveBitmap(bitmapFileName)
end

def pbItemIconFile(item, conversion = false)
  return "Graphics/Icons/Item/itemBack" if !item

  tmmove = pbGetTM(item)
  if tmmove
    type = $cache.moves[tmmove].type
    typename = $cache.types[type].name
    return sprintf("Graphics/Icons/Item/TM - %s", typename)
  end
  image = $cache.items[item].checkFlag?(:image)
  return sprintf("Graphics/Icons/Item/#{image}") if image

  bitmapFileName = nil
  if !conversion
    bitmapFileName = sprintf("Graphics/Icons/Item/%s.png", item.to_s.downcase)
  else
    bitmapFileName = sprintf("Graphics/Icons/Item/%s", $cache.items[item].checkFlag?(:ID)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Icons/Item/%03d", $cache.items[item].checkFlag?(:ID))
    end
  end
  return bitmapFileName
end

def pbMailBackFile(item)
  return nil if !item

  return sprintf("Graphics/Pictures/Mail/mail%s", item)
end

def pbTrainerCharFile(type)
  return nil if !type

  type = $cache.trainertypes[type].checkFlag?(:ID) if type.is_a?(Symbol)
  bitmapFileName = sprintf("Graphics/Characters/trchar%03d", type)
  return bitmapFileName
end

def pbTrainerCharNameFile(type)
  return nil if !type

  type = $cache.trainertypes[type].checkFlag?(:ID) if type.is_a?(Symbol)
  bitmapFileName = sprintf("trchar%03d", type)
  return bitmapFileName
end

def pbTrainerHeadFile(type)
  return nil if !type

  type = $cache.trainertypes[type].checkFlag?(:ID) if type.is_a?(Symbol)
  bitmapFileName = sprintf("Graphics/Pictures#{Rejuv ? "/RegionMap" : ""}/mapPlayer%03d", type)
  return bitmapFileName
end

def pbPlayerHeadFile(type)
  return nil if !type

  type = $cache.trainertypes[type].checkFlag?(:ID) if type.is_a?(Symbol)
  outfit = $Trainer ? $Trainer.outfit : 0
  bitmapFileName = sprintf("Graphics/Pictures#{Rejuv ? "/RegionMap" : ""}/mapPlayer%03d_%d", type, outfit)
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = pbTrainerHeadFile(type)
  end
  return bitmapFileName
end

def pbTrainerSpriteFile(type, outfit = 0)
  return nil if !type
  raise "unexpected trainer type" unless type.is_a?(Symbol)

  # Directory structure is different for protagonist sprites in Reborn, 'trainer' might be a protagonist (online battles)
  if Reborn && isProtagonistTrainerType?(type)
    return pbPlayerSpriteFile(type)
  end

  id = $cache.trainertypes[type].checkFlag?(:ID)
  if outfit > 0
    bitmapFileName = sprintf("Graphics/Characters/trainer%s_%d", id, outfit) rescue nil
    bitmapFileName = sprintf("Graphics/Characters/trainer%s", id) rescue nil if !pbResolveBitmap(bitmapFileName)
  else
    if Reborn && AlterEgos.include?(type)
      player = $cache.metadata[:Players].find { |player| player[:tclass] == $Trainer.trainertype }
      bitmapFileName = sprintf("Graphics/Characters/%s/alttrainer", player[:directory])
    else
      bitmapFileName = sprintf("Graphics/Characters/trainer%s", id) rescue nil
    end
  end
  if !pbResolveBitmap(bitmapFileName)
    if outfit > 0
      bitmapFileName = sprintf("Graphics/Characters/trainer%03d_%d", id, outfit) rescue nil
      bitmapFileName = sprintf("Graphics/Characters/trainer%03d", id) rescue nil if !pbResolveBitmap(bitmapFileName)
    else
      bitmapFileName = sprintf("Graphics/Characters/trainer%03d", id)
    end
  end
  return bitmapFileName
end

def pbTrainerSpriteBackFile(type)
  return nil if !type
  raise "unexpected trainer type" unless type.is_a?(Symbol)

  id = $cache.trainertypes[type].checkFlag?(:ID)
  bitmapFileName = sprintf("Graphics/Characters/trback%03d", id)
  return bitmapFileName
end

# type is either an object in metatext.rb's METAHASH (like :player2 for example) or in ttypetext.rb's TTypeHash
# For both, the player characters all have :trainer and :trback attributes.
def pbPlayerSpriteFile(type)
  return nil if !type
  raise "unexpected trainer type" unless type.is_a?(Symbol)

  # Directory structure is different for protagonist sprites in Reborn, 'player' might not be a protagonist (character switching)
  if Reborn && !isProtagonistTrainerType?(type)
    return pbTrainerSpriteFile(type)
  end

  id = $cache.trainertypes[type].checkFlag?(:ID)
  outfit = 0
  if Reborn
    player = $cache.metadata[:Players].find { |value| value[:tclass] == type }
    bitmapFileName = sprintf("Graphics/Characters/" + player[:directory] + ($Trainer.outfit > 0 ? " " + $Trainer.outfit.to_s : "") + "/" + player[:trainer]) rescue nil
  else
    outfit = $Trainer ? $Trainer.outfit : 0
    bitmapFileName = sprintf("Graphics/Characters/trainer%s_%d", id, outfit) rescue nil
  end
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Characters/trainer%03d_%d", id, outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = pbTrainerSpriteFile(type)
    end
  end
  return bitmapFileName
end

def pbPlayerSpriteBackFile(type)
  return nil if !type
  raise "unexpected trainer type" unless type.is_a?(Symbol)

  # Directory structure is different for protagonist sprites in Reborn, 'player' might not be a protagonist (character switching)
  if Reborn && !isProtagonistTrainerType?(type)
    return pbTrainerSpriteBackFile(type)
  end

  id = $cache.trainertypes[type].checkFlag?(:ID)
  outfit = 0
  if Reborn
    player = $cache.metadata[:Players].find { |value| value[:tclass] == type }
    bitmapFileName = sprintf("Graphics/Characters/" + player[:directory] + ($Trainer.outfit > 0 ? " " + $Trainer.outfit.to_s : "") + "/" + player[:trback]) rescue nil
  else
    outfit = $Trainer ? $Trainer.outfit : 0
    bitmapFileName = sprintf("Graphics/Characters/trback%s_%d", id, outfit) rescue nil
  end
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Characters/trback%03d_%d", id, outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = pbTrainerSpriteBackFile(type)
    end
  end
  return bitmapFileName
end

def getTrainerOverworldSprite(tclass)
  filename = $cache.trainertypes[tclass].sprite
  if !filename
    dp("hey, this trainer is missing a graphic. please report: ", tclass, " - ", filename, " ty <3")
    filename = "trchar000.png"
  end
  if !pbResolveBitmap("Graphics/Characters/" + filename)
    dp("hey this trainer's graphic does not exist. please report: ", tclass, " - ", filename, " ty <3")
    filename = "trchar000.png"
  end
  return filename
end

def unhashTRlist
  trainerlist = $cache.trainers
  dehashedlist = []
  # hash of all classes
  # hash of all names in class
  # array of all teams in name
  for tclass in trainerlist.keys
    classhash = trainerlist[tclass]
    for name in classhash.keys
      namearray = classhash[name]
      for partydata in namearray
        dehashedlist.push([tclass, name, partydata[1], partydata[0], partydata[0]])
      end
    end
  end
  return dehashedlist
end

################################################################################
# Loads music and sound effects
################################################################################
def pbResolveAudioSE(file)
  return nil if !file
  if RTP.exists?("Audio/SE/" + file, ["", ".wav", ".mp3", ".ogg"])
    return RTP.getPath("Audio/SE/" + file, ["", ".wav", ".mp3", ".ogg"])
  end

  return nil
end

def getPlayTime(filename)
  if safeExists?(filename)
    return [getPlayTime2(filename), 0].max
  elsif safeExists?(filename + ".wav")
    return [getPlayTime2(filename + ".wav"), 0].max
  elsif safeExists?(filename + ".mp3")
    return [getPlayTime2(filename + ".mp3"), 0].max
  elsif safeExists?(filename + ".ogg")
    return [getPlayTime2(filename + ".ogg"), 0].max
  else
    return 0
  end
end

def getPlayTime2(filename)
  time = -1
  return -1 if !safeExists?(filename)

  fgetdw = proc { |file|
    (file.eof? ? 0 : (file.read(4).unpack("V")[0] || 0))
  }
  fgetw = proc { |file|
    (file.eof? ? 0 : (file.read(2).unpack("v")[0] || 0))
  }
  File.open(filename, "rb") { |file|
    file.pos = 0
    fdw = fgetdw.call(file)
    if fdw == 0x46464952 # "RIFF"
      filesize = fgetdw.call(file)
      wave = fgetdw.call(file)
      if wave != 0x45564157 # "WAVE"
        return -1
      end

      fmt = fgetdw.call(file)
      if fmt != 0x20746d66 # "fmt "
        return -1
      end

      fmtsize = fgetdw.call(file)
      format = fgetw.call(file)
      channels = fgetw.call(file)
      rate = fgetdw.call(file)
      bytessec = fgetdw.call(file)
      if bytessec == 0
        return -1
      end

      bytessample = fgetw.call(file)
      bitssample = fgetw.call(file)
      data = fgetdw.call(file)
      if data != 0x61746164 # "data"
        return -1
      end

      datasize = fgetdw.call(file)
      time = (datasize * 1.0) / bytessec
      return time
    elsif fdw == 0x5367674F # "OggS"
      file.pos = 0
      time = oggfiletime(file)
      return time
    end
    file.pos = 0
    # Find the length of an MP3 file
    while true
      rstr = ""
      ateof = false
      while !file.eof?
        if (file.read(1)[0] rescue 0) == 0xFF
          begin; rstr = file.read(3); break; rescue; ateof = true; break; end
        end
      end
      break if ateof || !rstr || rstr.length != 3

      if rstr[0] == 0xFB
        t = rstr[1] >> 4
        next if t == 0 || t == 15

        freqs = [44100, 22050, 11025, 48000]
        bitrates = [32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320]
        bitrate = bitrates[t]
        t = (rstr[1] >> 2) & 3
        freq = freqs[t]
        t = (rstr[1] >> 1) & 1
        filesize = FileTest.size(filename)
        frameLength = ((144000 * bitrate) / freq) + t
        numFrames = filesize / (frameLength + 4)
        time = (numFrames * 1152.0 / freq)
        break
      end
    end
  }
  return time
end

# internal function
def oggfiletime(file)
  fgetdw = proc { |file|
    (file.eof? ? 0 : (file.read(4).unpack("V")[0] || 0))
  }
  pages = []
  page = nil
  loop do
    page = getOggPage(file)
    break if !page

    pages.push(page)
    file.pos = page[3]
  end
  return -1 if pages.length == 0

  curserial = nil
  i = -1
  pcmlengths = []
  rates = []
  for page in pages
    header = page[0]
    serial = header[10, 4].unpack("V")
    frame = header[2, 8].unpack("C*")
    frameno = frame[7]
    frameno = (frameno << 8) | frame[6]
    frameno = (frameno << 8) | frame[5]
    frameno = (frameno << 8) | frame[4]
    frameno = (frameno << 8) | frame[3]
    frameno = (frameno << 8) | frame[2]
    frameno = (frameno << 8) | frame[1]
    frameno = (frameno << 8) | frame[0]
    if serial != curserial
      curserial = serial
      file.pos = page[1]
      packtype = (file.read(1)[0].ord rescue 0)
      string = file.read(6)
      return -1 if string != "vorbis"
      return -1 if packtype != 1

      i += 1
      version = fgetdw.call(file)
      return -1 if version != 0

      rates[i] = fgetdw.call(file)
    end
    pcmlengths[i] = frameno
  end
  ret = 0.0
  for i in 0...pcmlengths.length
    ret += pcmlengths[i].to_f / rates[i].to_f
  end
  return ret * 256.0
end

def getOggPage(file)
  fgetdw = proc { |file|
    (file.eof? ? 0 : (file.read(4).unpack("V")[0] || 0))
  }
  dw = fgetdw.call(file)
  return nil if dw != 0x5367674F

  header = file.read(22)
  bodysize = 0
  hdrbodysize = (file.read(1)[0].ord rescue 0)
  hdrbodysize.times do
    bodysize += (file.read(1)[0].ord rescue 0)
  end
  ret = [header, file.pos, bodysize, file.pos + bodysize]
  return ret
end

def pbCryFrameLength(pokemon, pitch = nil)
  return 0 if !pokemon

  pitch = 100 if !pitch
  pitch = pitch.to_f / 100
  return 0 if pitch <= 0

  playtime = 0.0
  if pokemon.is_a?(Symbol) || pokemon.is_a?(Numeric)
    pkmnwav = pbResolveAudioSE(pbCryFile(pokemon))
    playtime = getPlayTime(pkmnwav) if pkmnwav
  elsif !pokemon.isEgg?
    if pokemon.respond_to?("chatter") && pokemon.chatter
      playtime = pokemon.chatter.time
      pitch = 1.0
    else
      pkmnwav = pbResolveAudioSE(pbCryFile(pokemon))
      playtime = getPlayTime(pkmnwav) if pkmnwav
    end
  end
  playtime /= pitch # sound is lengthened the lower the pitch
  # 4 is added to provide a buffer between sounds
  return (playtime * Graphics.frame_rate).ceil + 4
end

def pbPlayCry(pokemon, volume = 90, pitch = nil)
  return if !pokemon

  if pokemon.is_a?(Symbol) || pokemon.is_a?(Numeric)
    pkmnwav = pbCryFile(pokemon)
    if pkmnwav
      pbSEPlay(RPG::AudioFile.new(pkmnwav, volume, pitch ? pitch : 100)) rescue nil
    end
  elsif !pokemon.isEgg?
    if pokemon.respond_to?("chatter") && pokemon.chatter
      pokemon.chatter.play
    else
      pkmnwav = pbCryFile(pokemon)
      if pkmnwav
        hpbasedpitch = pokemon.species == :PIKACHU ?
          (pokemon.hp * 15 / pokemon.totalhp) + 85 :
          (pokemon.hp * 25 / pokemon.totalhp) + 75
        pbSEPlay(RPG::AudioFile.new(pkmnwav, volume, pitch ? pitch : hpbasedpitch)) rescue nil
      end
    end
  end
end

def pbCryFile(pokemon)
  return nil if !pokemon

  if pokemon.is_a?(Symbol)
    pokemon = $cache.pkmn[pokemon, 0].dexnum
  end
  if pokemon.is_a?(Numeric)
    filename = sprintf("%03dCry", pokemon) if !pbResolveAudioSE(filename)
    return filename if pbResolveAudioSE(filename)
  elsif !pokemon.isEgg?
    filename = sprintf("%sCry_%d", pokemon.dexnum, (pokemon.form rescue 0)) rescue nil
    filename = sprintf("%03dCry_%d", pokemon.dexnum, (pokemon.form rescue 0)) if !pbResolveAudioSE(filename)
    if !pbResolveAudioSE(filename)
      filename = sprintf("%sCry", pokemon.dexnum) rescue nil
    end
    filename = sprintf("%03dCry", pokemon.dexnum) if !pbResolveAudioSE(filename)
    return filename if pbResolveAudioSE(filename)
  end
  return nil
end

def pbGetWildBattleBGM(species)
  return $PokemonGlobal.nextBattleBGM.clone if $PokemonGlobal.nextBattleBGM

  return pbStringToAudioFile("Battle- Legendary") if PBStuff::LEGENDARYLIST.include?(species)

  music = $cache.mapdata[$game_map.map_id].WildBattleBGM
  return pbStringToAudioFile(music) if music

  music = $cache.metadata[:WildBattle]
  return pbStringToAudioFile(music) if music

  return pbStringToAudioFile("Battle- Wild")
end

def pbGetWildVictoryBGM
  return $PokemonGlobal.nextBattleVictoryBGM.clone if $PokemonGlobal.nextBattleVictoryBGM

  if Rejuv
    music = getVictoryMusicOverride(music)
    return pbStringToAudioFile(music) if music
  end

  music = $cache.mapdata[$game_map.map_id].WildVictoryBGM
  return pbStringToAudioFile(music) if music

  music = $cache.metadata[:WildVictory]
  return pbStringToAudioFile(music) if music

  return nil
end

def pbPlayTrainerIntroME(trainertype)
  return unless $cache.trainertypes[trainertype]

  bgm = $cache.trainertypes[trainertype].checkFlag?(:introBGM)
  if bgm && bgm != ""
    bgm = pbStringToAudioFile(bgm)
    pbMEPlay(bgm)
  end
end

def pbGetTrainerBattleBGM(trainer) # can be a PokeBattle_Trainer or an array of PokeBattle_Trainer
  return $PokemonGlobal.nextBattleBGM.clone if $PokemonGlobal.nextBattleBGM

  trainerarray = Array(trainer)
  chosen_trainer = trainerarray.last # In a battle against two trainers, the BGM is based on the second trainer

  music = chosen_trainer.teamAttributes[:battleBGM]
  # May be a string or a hash with keys name, volume, pitch (volume and pitch being optional)
  return pbDataToAudioFile(music) if music && music != ""

  music = $cache.trainertypes[chosen_trainer.trainertype].battleBGM
  # May be a string or a hash with keys name, volume, pitch (volume and pitch being optional)
  return pbDataToAudioFile(music) if music && music != ""

  music = $cache.mapdata[$game_map.map_id].TrainerBattleBGM
  return pbStringToAudioFile(music) if music && music != ""

  music = $cache.metadata[:TrainerBattle]
  return pbStringToAudioFile(music) if music && music != ""

  return nil
end

def pbGetOnlineBattleBGM(trainer) # can be a PokeBattle_Trainer or an array of PokeBattle_Trainer
  if trainer.onlineMusic == :random
    music = OnlineBGM.map{ |name, filename| filename }.sample
  else
    music = trainer.onlineMusic || "Battle- Trainer"
  end
  return music && music != "" ? pbStringToAudioFile(music) : nil
end

def pbGetTrainerVictoryBGM(trainer) # can be a PokeBattle_Trainer or an array of PokeBattle_Trainer
  return $PokemonGlobal.nextBattleVictoryBGM.clone if $PokemonGlobal.nextBattleVictoryBGM

  if Rejuv
    music = getVictoryMusicOverride(music)
    return pbStringToAudioFile(music) if music
  end

  trainerarray = Array(trainer)
  chosen_trainer = trainerarray.last # In a battle against two trainers, the BGM is based on the second trainer

  music = chosen_trainer.teamAttributes[:winBGM]
  # May be a string or a hash with keys name, volume, pitch (volume and pitch being optional)
  return pbDataToAudioFile(music) if music && music != ""

  music = $cache.trainertypes[chosen_trainer.trainertype].winBGM
  # May be a string or a hash with keys name, volume, pitch (volume and pitch being optional)
  return pbDataToAudioFile(music) if music && music != ""

  music = $cache.mapdata[$game_map.map_id].TrainerVictoryBGM
  return pbStringToAudioFile(music) if music && music != ""

  music = $cache.metadata[:TrainerVictory]
  return pbStringToAudioFile(music) if music && music != ""

  return nil
end

################################################################################
# Creating and storing Pokémon
################################################################################
def pbBoxesFull?
  return !$Trainer || ($Trainer.party.length == 6 && $PokemonStorage.full?)
end

def pbNickname(pokemon)
  speciesname = getMonName(pokemon.species, pokemon.form)
  return "" if $Settings.nicknames == 1 || !Kernel.pbConfirmMessage(_INTL("Would you like to give a nickname to {1}?", speciesname))

  helptext = _INTL("{1}'s nickname?", speciesname)
  newname = pbEnterText(helptext, 0, 12, "", 2, pokemon)
  pokemon.name = newname if newname != ""
  return newname
end

def pbStorePokemon(pokemon)
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pokemon.pbRecordFirstMoves
  addPkmnToPartyOrPC(pokemon)
end

def pbNicknameAndStore(pokemon)
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  $Trainer.pokedex.setOwned(pokemon)
  pbNickname(pokemon) if $Settings.nicknames == 0
  # pbEnterPokemonName(helptext,0,12,"",pokemon)
  pbStorePokemon(pokemon)
end

def pbAddPokemon(species, level = nil, seeform = true, form = nil)
  return if !species || !$Trainer

  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  species = $cache.pkmn.keys[species - 1] if species.is_a?(Integer)
  species = PokeBattle_Pokemon::PokemonBuilder.new(species).build if species.is_a?(Hash)
  if !species.is_a?(PokeBattle_Pokemon)
    pokemon = PokeBattle_Pokemon.new(species, level, $Trainer, true, form)
    speciesname = getMonName(pokemon.species, pokemon.form)
  else
    pokemon = species
    speciesname = getMonName(species.species, pokemon.form)
  end
  pokemon.timeReceived = Time.new
  if pokemon.ot == ""
    pokemon.ot = $Trainer.name
    pokemon.trainerID = $Trainer.id
  end

  Kernel.pbMessage(_INTL("{1} obtained {2}!\\se[itemlevel]\1", $Trainer.name, speciesname))
  pbNicknameAndStore(pokemon)
  $Trainer.pokedex.setSeen(pokemon) if seeform
  return true
end

def pbAddPokemonSilent(pokemon, level = nil, seeform = true, ivs = [], ability = nil, moves = nil, female = nil, obtainText = nil, name = nil, ot = nil, shiny = nil, evs = [], nature = nil, item = nil, form = nil)
  return false if !pokemon || pbBoxesFull? || !$Trainer

  pokemon = PokeBattle_Pokemon::PokemonBuilder.new(pokemon).build if pokemon.is_a?(Hash)
  if !pokemon.is_a? PokeBattle_Pokemon
    pokemon = PokeBattle_Pokemon.new(pokemon, level, $Trainer, true, form)
  end
  if pokemon.ot == ""
    pokemon.ot = $Trainer.name
    pokemon.trainerID = $Trainer.id
  end
  if pokemon.eggsteps <= 0 && seeform
    $Trainer.pokedex.setOwned(pokemon)
  end
  pokemon.timeReceived = Time.new
  pokemon.pbRecordFirstMoves
  for i in 0...6
    pokemon.iv[i] = ivs[i] if ivs[i]
    pokemon.ev[i] = evs[i] if evs[i]
  end
  pokemon.calcStats
  pokemon.setAbility(ability) if ability
  if moves
    moves.each { |move| pokemon.pbLearnMove(move) }
  end
  pokemon.item = item if item
  pokemon.initZmoves(false)
  if !female.nil?
    val = female ? 1 : 0
    pokemon.setGender(val)
  end
  pokemon.obtainText = obtainText if obtainText
  pokemon.name = name if name
  pokemon.ot = ot if ot
  pokemon.makeShiny if shiny == 1
  pokemon.setNature(nature) if nature
  addPkmnToPartyOrPC(pokemon)
  return true
end

def pbAddRentalPokemonSilent(pokemon, level = nil)
  return false if !pokemon || pbBoxesFull? || !$Trainer

  pokemon = PokeBattle_Pokemon::PokemonBuilder.new(pokemon).build() if pokemon.is_a?(Hash)
  pokemon = PokeBattle_Pokemon.new(pokemon, level, $Trainer) unless pokemon.is_a?(PokeBattle_Pokemon)
  if pokemon.ot == ""
    pokemon.ot = $Trainer.name
    pokemon.trainerID = $Trainer.id
  end
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length < 6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
  end
  return true
end

def pbAddToParty(pokemon, level = nil, seeform = true)
  return false if !pokemon || !$Trainer # || $Trainer.party.length>=6

  pokemon = PokeBattle_Pokemon.new(pokemon, level, $Trainer)
  pokemon.pbRecordFirstMoves
  speciesname = getMonName(pokemon.species, pokemon.form)
  Kernel.pbMessage(_INTL("{1} obtained {2}!\\se[itemlevel]\1", $Trainer.name, speciesname))
  # pbNicknameAndStore(pokemon)
  pbNickname(pokemon) if $Settings.nicknames == 0
  addPkmnToPartyOrPC(pokemon)
  $Trainer.pokedex.setOwned(pokemon) if seeform
  return true
end

def pbAddToPartySilent(pokemon, level = nil, seeform = true)
  return false if !pokemon || !$Trainer || $Trainer.party.length >= 6

  pokemon = PokeBattle_Pokemon.new(pokemon, level, $Trainer)
  $Trainer.pokedex.setOwned(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  $Trainer.party[$Trainer.party.length] = pokemon
  return true
end

def pbAddForeignPokemon(pokemon, level = nil, ownerName = nil, nickname = nil, ownerGender = 0, seeform = true)
  return false if !pokemon || !$Trainer || $Trainer.party.length >= 6

  pokemon = PokeBattle_Pokemon.new(pokemon, level, $Trainer)
  # Set original trainer to a foreign one (if ID isn't already foreign)
  if pokemon.trainerID == $Trainer.id
    pokemon.trainerID = $Trainer.getForeignID
    pokemon.ot = ownerName if ownerName && ownerName != ""
  end
  # Set nickname
  pokemon.name = nickname[0, 12] if nickname && nickname != ""
  # Recalculate stats
  pokemon.calcStats
  if ownerName
    Kernel.pbMessage(_INTL("{1} received a Pokémon from {2}.\1", $Trainer.name, ownerName))
  else
    Kernel.pbMessage(_INTL("{1} received a Pokémon.\1", $Trainer.name))
  end
  pbStorePokemon(pokemon)
  $Trainer.pokedex.setOwned(pokemon) if seeform
  return true
end

def pbGenerateEgg(pokemon, form = 0, text = "")
  return false if !pokemon || !$Trainer

  pokemon = PokeBattle_Pokemon::PokemonBuilder.new(pokemon).build if pokemon.is_a?(Hash)
  pokemon = PokeBattle_Pokemon.new(pokemon, EGGINITIALLEVEL, $Trainer, true, form)
  # Set egg's details
  pokemon.name = _INTL("Egg")
  pokemon.eggsteps = pokemon.getCacheData.EggSteps
  pokemon.obtainText = text
  # Add egg to party
  # $Trainer.party[$Trainer.party.length]=pokemon
  return pokemon
end

def pbRemovePokemonAt(index)
  return false if index < 0 || index >= $Trainer.party.length

  haveAble = false
  for i in 0...$Trainer.party.length
    next if i == index

    haveAble = true if $Trainer.party[i].hp > 0 && !$Trainer.party[i].isEgg?
  end
  return false if !haveAble

  $Trainer.party.delete_at(index)
  return true
end

def pbTakeItemAndRemovePokemonAt(index)
  if $Trainer.party[index].item
    $PokemonBag.pbStoreItem($Trainer.party[index].item)
  end
  pbRemovePokemonAt(index)
end

def LevelLimitExpGain(pokemon, exp) # For exp candies
  leadersDefeated = $Trainer.numbadges
  if pokemon.level >= LEVELCAPS[leadersDefeated] || pokemon.level >= 100 + $game_variables[:Extended_Max_Level] || noExp? || negExp?
    return -1
  elsif pokemon.level < LEVELCAPS[leadersDefeated]
    levelcap = [LEVELCAPS[leadersDefeated], 100 + $game_variables[:Extended_Max_Level]].min
    totalExpNeeded = PBExp.startExperience(levelcap, pokemon.growthrate)
    currExpNeeded = totalExpNeeded - pokemon.exp
    if exp > currExpNeeded
      return currExpNeeded
    end
  end

  return exp
end

def addPkmnToPartyOrPC(pokemon)
  if $Trainer.party.length < 6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    monsent = false
    while !monsent
      if Kernel.pbConfirmMessageSerious(_INTL("The party is full; do you want to send a party member to the PC?"))
        iMon = -2
        unusablecount = 0
        for i in $Trainer.party
          next if i.isEgg?
          next if i.hp < 1

          unusablecount += 1
        end
        pbFadeOutIn(99999) {
          scene = PokemonScreen_Scene.new
          screen = PokemonScreen.new(scene, $Trainer.party)
          screen.pbStartScene(_INTL("Choose a Pokémon."))
          loop do
            iMon = screen.pbChoosePokemon
            if iMon >= 0 && pbHasImportantFieldMove?(iMon)
              if Rejuv
                Kernel.pbMessage(_INTL("You can't return a Pokémon that knows an HM move to the PC."))
              else
                Kernel.pbMessage(_INTL("You can't return a Pokémon that knows a TMX move to the PC."))
              end
              iMon = -2
            elsif unusablecount <= 1 && !($Trainer.party[iMon].isEgg?) && $Trainer.party[iMon].hp > 0 && pokemon.isEgg?
              Kernel.pbMessage(_INTL("That's your last Pokémon!"))
            else
              screen.pbEndScene
              break
            end
          end
        }
        if iMon >= 0
          iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
          if iBox >= 0
            monsent = true
            $Trainer.party[iMon].heal
            Kernel.pbMessage(_INTL("{1} was sent to {2}.", $Trainer.party[iMon].name, $PokemonStorage[iBox].name))
            $Trainer.party[iMon] = nil
            $Trainer.party.compact!
            $Trainer.party[$Trainer.party.length] = pokemon
          else
            Kernel.pbMessage(_INTL("No space left in the PC."))
            return false
          end
        end
      else
        monsent = true
        oldcurbox = $PokemonStorage.pbDefaultBox
        storedbox = $PokemonStorage.pbStoreCaught(pokemon)
        if storedbox == -1
          Kernel.pbMessage(_INTL("No space left in the PC."))
          return false
        end
        creator = pbGetStorageCreator(true)
        curboxname = $PokemonStorage[oldcurbox].name
        boxname = $PokemonStorage[storedbox].name
        if storedbox != oldcurbox
          Kernel.pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1", curboxname, creator))
          Kernel.pbMessage(_INTL("{1} was transferred to box \"{2}.\"", pokemon.name, boxname))
        else
          Kernel.pbMessage(_INTL("{1} was transferred to {2}'s PC.\1", pokemon.name, creator))
          Kernel.pbMessage(_INTL("It was stored in box \"{1}\".", boxname))
        end
      end
    end
  end
end

################################################################################
# Analysing Pokémon
################################################################################
def pbHealAll
  return if !$Trainer

  for i in $Trainer.party
    if !$game_switches[:Nuzlocke_Mode] || i.hp > 0
      i.heal
    end
  end
end

def pbHealPartner
  return if !$PokemonGlobal.partner

  if $game_switches[:blockPartnerHeal]
    # only heal unfainted pokemon (current use case uses gauntlet heal regardless, if no heal at all is desired further modifications are needed)
    pbPartialHeal()
    # if player party has no usable pokemon, revive and half heal the lead mon
    # this is to prevent the player wandering around with a fully defeated party
    if !$game_switches[:Nuzlocke_Mode] && $Trainer.party.none? { |mon| mon && !mon.isEgg? && mon.hp > 0 }
      firstBattler = $Trainer.party.find { |mon| mon && !mon.isEgg? && mon.hp == 0 }
      firstBattler.healStatus
      firstBattler.hp = 1 + (firstBattler.totalhp / 2.0).floor
    end
  else
    pbHealAll()
  end
  for i in $PokemonGlobal.partner[3]
    i.heal
  end
  pbCheckNuzlockeWipe
end

def pbCheckNuzlockeWipe
  return if !$game_switches[:Nuzlocke_Mode] || $Trainer.party.any? { |i| !i.isEgg? && i.hp > 0 }

  Kernel.pbMessage(_INTL("You no longer have any usable Pokémon in your party."))
  Kernel.pbMessage(_INTL("Please withdraw at least one usable Pokémon to proceed."))
  loop do
    pbFadeOutIn(99999) {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.pbStartScreen(0)
    }
    break if $Trainer.party.any? { |i| !i.isEgg? && i.hp > 0 }

    if Kernel.pbConfirmMessageSerious(_INTL("You did not withdraw any usable Pokémon. Do you wish to forfeit the locke?"))
      if $Trainer.party.none? { |i| !i.isEgg? }
        Kernel.pbMessage(_INTL("In that case, please withdraw at least one non-egg Pokémon."))
      else
        $game_switches[:Nuzlocke_Mode] = false
        Kernel.pbMessage(_INTL("The locke has been removed. Your current party will be healed."))
        pbHealAll()
        break
      end
    end
  end
end

def convertBalls
  for i in $Trainer.party
    if i.ballused.is_a?(Integer)
      for j in BallHandlers::BallTypes.keys
        i.ballused = BallHandlers::BallTypes[j] if j == i.ballused
      end
    end
  end
  for x in 0...$PokemonStorage.maxBoxes
    for y in 0...$PokemonStorage.maxPokemon(x)
      if $PokemonStorage[x, y]
        i = $PokemonStorage[x, y]
        if i.ballused.is_a?(Integer)
          for j in BallHandlers::BallTypes.keys
            i.ballused = BallHandlers::BallTypes[j] if j == i.ballused
          end
        end
      end
     end
  end
  for i in $PokemonGlobal.daycare
    if i[0] && $PokemonGlobal.daycare[i][0].ballused.is_a?(Integer)
      for j in BallHandlers::BallTypes.keys
        i[0].ballused = BallHandlers::BallTypes[j] if j == i[0].ballused
      end
    end
  end
end

def pbBallRenaming(battle = false)
  if battle == true
    BallHandlers::BallTypes.each do |key, data|
      oldfilename = sprintf("Graphics/Pictures/Battle/ball%02d", key.to_s)
      if pbResolveBitmap(oldfilename)
        original = RPG::Cache.load_bitmap(oldfilename)
        original.to_file(sprintf("Graphics/Pictures/Battle/#{data.to_s}.png"))
        File.delete(sprintf("%s.png", oldfilename))
      end
      oldfilenameopen = sprintf("Graphics/Pictures/Battle/ball%02d_open", key.to_s)
      if pbResolveBitmap(oldfilenameopen)
        originalopen = RPG::Cache.load_bitmap(oldfilenameopen)
        originalopen.to_file(sprintf("Graphics/Pictures/Battle/#{data.to_s}_open.png"))
        File.delete(sprintf("%s.png", oldfilenameopen))
      end
    end
  else
    BallHandlers::BallTypes.each do |key, data|
      oldfilename = sprintf("Graphics/Pictures/Summary/summaryball%02d", key.to_s)
      if pbResolveBitmap(oldfilename)
        original = RPG::Cache.load_bitmap(oldfilename)
        original.to_file(sprintf("Graphics/Pictures/Summary/summaryball#{data.to_s}.png"))
        File.delete(sprintf("%s.png", oldfilename))
      end
      # oldfilenameopen=sprintf("Graphics/Pictures/Summary/ball%02d_open",key.to_s)
      # if pbResolveBitmap(oldfilenameopen)
      #     originalopen = RPG::Cache.load_bitmap(oldfilenameopen)
      #     originalopen.to_file(sprintf("Graphics/Pictures/Summary/#{data.to_s}_open.png"))
      #     File.delete(sprintf("%s.png",oldfilenameopen))
      # end
    end
  end
end

def pbStatusRenaming
  height = 16
  width = 48
  oldfilename = sprintf("Graphics/Pictures/Battle/BattleStatuses")
  if pbResolveBitmap(oldfilename)
    statuses = ["Sleep", "Burn", "Frozen", "Poison", "Paralysis"]
    original = RPG::Cache.load_bitmap(oldfilename)
    for status in 1...5
      rectangle = Rect.new(0, (status) * 16, width, height)
      newbitmap = Bitmap.new(width, height)
      newbitmap.blt(0, 0, original, rectangle)
      newbitmap.to_file(sprintf("Graphics/Pictures/Battle/BattleStatuses%s.png", statuses[status]))
    end
    File.delete(sprintf("%s.png", oldfilename))
  end
end

def pbFightIconRenaming
  height = 46
  width = 384
  oldfilename = sprintf("Graphics/Pictures/Battle/battleFightButtons")
  if pbResolveBitmap(oldfilename)
    types = [
      "NORMAL",
      "FIGHTING",
      "FLYING",
      "POISON",
      "GROUND",
      "ROCK",
      "BUG",
      "GHOST",
      "STEEL",
      "QMARKS",
      "FIRE",
      "WATER",
      "GRASS",
      "ELECTRIC",
      "PSYCHIC",
      "ICE",
      "DRAGON",
      "DARK",
      "FAIRY",
      "SHADOW",
    ]
    original = RPG::Cache.load_bitmap(oldfilename)
    for type in 0...20
      rectangle = Rect.new(0, (type) * 46, width, height)
      newbitmap = Bitmap.new(width, height)
      newbitmap.blt(0, 0, original, rectangle)
      newbitmap.to_file(sprintf("Graphics/Pictures/Battle/battleFightButtons%s.png", types[type]))
    end
    File.delete(sprintf("%s.png", oldfilename))
  end
end

def pbBattlerRenamer
  $cache.pkmn.each do |key, data|
    id = $cache.pkmn[key, 0].dexnum
    oldfilename = sprintf("Graphics/Battlers/%03d", id)
    oldfilenameegg = sprintf("Graphics/Battlers/%03degg", id)
    oldfilenamef = sprintf("Graphics/Battlers/%03df", id)
    oldfilenameeggf = sprintf("Graphics/Battlers/%03dfegg", id)
    if pbResolveBitmap(oldfilename)
      original = RPG::Cache.load_bitmap(oldfilename)
      original.to_file(sprintf("Graphics/Battlers/#{key.to_s.downcase!}.png"))
      File.delete(sprintf("%s.png", oldfilename))
    end
    if pbResolveBitmap(oldfilenamef)
      originalf = RPG::Cache.load_bitmap(oldfilenamef)
      originalf.to_file(sprintf("Graphics/Battlers/#{key.to_s.downcase!}f.png"))
      File.delete(sprintf("%s.png", oldfilenamef))
    end
    if pbResolveBitmap(oldfilenameegg)
      originalegg = RPG::Cache.load_bitmap(oldfilenameegg)
      originalegg.to_file(sprintf("Graphics/Battlers/#{key.to_s.downcase!}egg.png"))
      File.delete(sprintf("%s.png", oldfilenameegg))
    end
    if pbResolveBitmap(oldfilenameeggf)
      originaleggf = RPG::Cache.load_bitmap(oldfilenameeggf)
      originaleggf.to_file(sprintf("Graphics/Battlers/#{key.to_s.downcase!}fegg.png"))
      File.delete(sprintf("%s.png", oldfilenameeggf))
    end
    if data[0].checkFlag?(:toobig) || key.to_sym == :GARDEVOIR
      for i in 0...5
        oldfilenameforms = sprintf("Graphics/Battlers/%03d_%s", id, i)
        oldfilenameformsshiny = sprintf("Graphics/Battlers/%03ds_%s", id, i)
        oldfilenameformsback = sprintf("Graphics/Battlers/%03db_%s", id, i)
        oldfilenameformsbackshiny = sprintf("Graphics/Battlers/%03dsb_%s", id, i)
        if pbResolveBitmap(oldfilenameforms)
          originalforms = RPG::Cache.load_bitmap(oldfilenameforms)
          originalforms.to_file(sprintf("Graphics/Battlers/#{key.to_s.downcase!}_%s.png", i))
          File.delete(sprintf("%s.png", oldfilenameforms))
        end
        if pbResolveBitmap(oldfilenameformsshiny)
          originalforms = RPG::Cache.load_bitmap(oldfilenameformsshiny)
          originalforms.to_file(sprintf("Graphics/Battlers/#{key.to_s.downcase!}s_%s.png", i))
          File.delete(sprintf("%s.png", oldfilenameformsshiny))
        end
        if pbResolveBitmap(oldfilenameformsback)
          originalformsback = RPG::Cache.load_bitmap(oldfilenameformsback)
          originalformsback.to_file(sprintf("Graphics/Battlers/#{key.to_s.downcase!}b_%s.png", i))
          File.delete(sprintf("%s.png", oldfilenameformsback))
        end
        if pbResolveBitmap(oldfilenameformsbackshiny)
          originalformsbackshiny = RPG::Cache.load_bitmap(oldfilenameformsbackshiny)
          originalformsbackshiny.to_file(sprintf("Graphics/Battlers/#{key.to_s.downcase!}sb_%s.png", i))
          File.delete(sprintf("%s.png", oldfilenameformsbackshiny))
        end
      end
    end
  end
end

def pbIconRenamer
  $cache.pkmn.each do |key, data|
    id = $cache.pkmn[key, 0].dexnum
    oldfilename = sprintf("Graphics/Icons/icon%03d", id)
    oldfilenameegg = sprintf("Graphics/Icons/icon%03degg", id)
    oldfilenamef = sprintf("Graphics/Icons/icon%03df", id)
    oldfilenameeggf = sprintf("Graphics/Icons/icon%03dfegg", id)
    if pbResolveBitmap(oldfilename)
      original = RPG::Cache.load_bitmap(oldfilename)
      original.to_file(sprintf("Graphics/Icons/#{key.to_s.downcase!}.png"))
      File.delete(sprintf("%s.png", oldfilename))
    end
    if pbResolveBitmap(oldfilenamef)
      originalf = RPG::Cache.load_bitmap(oldfilenamef)
      originalf.to_file(sprintf("Graphics/Icons/#{key.to_s.downcase!}f.png"))
      File.delete(sprintf("%s.png", oldfilenamef))
    end
    if pbResolveBitmap(oldfilenameegg)
      originalegg = RPG::Cache.load_bitmap(oldfilenameegg)
      originalegg.to_file(sprintf("Graphics/Icons/#{key.to_s.downcase!}egg.png"))
      File.delete(sprintf("%s.png", oldfilenameegg))
    end
    if pbResolveBitmap(oldfilenameeggf)
      originaleggf = RPG::Cache.load_bitmap(oldfilenameeggf)
      originaleggf.to_file(sprintf("Graphics/Icons/#{key.to_s.downcase!}fegg.png"))
      File.delete(sprintf("%s.png", oldfilenameeggf))
    end
  end
end

# Heals all Pokémon in the party of Status.
def pbHealAllStatus
  return if !$Trainer

  for i in $Trainer.party
    i.healStatus
  end
end

# Heals all surviving Pokemon in party.
def pbPartialHeal
  return if !$Trainer

  for i in $Trainer.party
    if i && !i.isEgg? && i.hp > 0
      i.healStatus
      i.healHP
    end
  end
end

# Revives all fainted pokemon
def pbReviveHeal
  return if !$Trainer

  for i in $Trainer.party
    if i && !i.isEgg? && i.hp == 0
      i.healStatus
      i.hp = 1 + (i.totalhp / 2.0).floor
    end
  end
end

# Returns the first unfainted, non-egg Pokémon in the player's party.
def pbFirstAblePokemon(variableNumber)
  for i in 0...$Trainer.party.length
    p = $Trainer.party[i]
    if p && !p.isEgg? && p.hp > 0
      pbSet(variableNumber, i)
      return $Trainer.party[i]
    end
  end
  pbSet(variableNumber, -1)
  return nil
end

# Checks whether the player would still have an unfainted Pokémon if the
# Pokémon given by _pokemonIndex_ were removed from the party.
def pbCheckAble(pokemonIndex)
  for i in 0...$Trainer.party.length
    p = $Trainer.party[i]
    next if i == pokemonIndex
    return true if p && !p.isEgg? && p.hp > 0
  end
  return false
end

# Returns true if there are no usable Pokémon in the player's party.
def pbAllFainted
  for i in $Trainer.party
    return false if !i.isEgg? && i.hp > 0
  end
  return true
end

# Returns true if the given species can be legitimately obtained as an egg.
def pbCanBeEgg?(species, form)
  # If the given species has Undiscovered or Ditto egg groups, meaning it can't produce eggs, see if it has an evolution that doesn't have such an egg group and thus could produce an egg with the given species
  eggProducingSpecies, eggProducingForm = species, form
  loop do
    eggGroups = $cache.pkmn[eggProducingSpecies, eggProducingForm].EggGroups
    break unless eggGroups.include?(:Undiscovered) || eggGroups.empty? # empty means Ditto

    evolutions = pbGetEvolvedFormData(eggProducingSpecies, eggProducingForm)
    return false if evolutions.nil?

    eggProducingSpecies, eggProducingForm = evolutions[0][:species], evolutions[0][:form].is_a?(Numeric) ? evolutions[0][:form] : eggProducingForm
  end

  baby = pbGetBabySpecies(eggProducingSpecies, eggProducingForm)
  return true if [species, form] == [baby[0], baby[1]]

  lessbaby = pbGetNonIncenseLowestSpecies(baby[0], baby[1])
  return true if [species, form] == [lessbaby[0], lessbaby[1]]

  return false
end

def pbGetLegalMovesForSpecies(species, level = 100)
  pkmn = PokeBattle_Pokemon.new(species, level, $Trainer, false, 0)
  return pkmn.getAllLegalMoves(true)
end

def pbGetLearnableMovesForSpecies(species, form)
  pkmn = PokeBattle_Pokemon.new(species, 5, $Trainer, false, form)
  return pkmn.getAllLearnableMoves
end

################################################################################
# Look through Pokémon in storage, choose a Pokémon in the party
################################################################################
# Yields every Pokémon/egg in storage in turn.
def pbEachPokemon
  for i in -1...$PokemonStorage.maxBoxes
    for j in 0...$PokemonStorage.maxPokemon(i)
      poke = $PokemonStorage[i][j]
      yield(poke, i) if poke
    end
  end
end

# Yields every Pokémon in storage in turn.
def pbEachNonEggPokemon
  pbEachPokemon { |pokemon, box|
    yield(pokemon, box) if !pokemon.isEgg?
  }
end

# Choose a Pokémon/egg from the party.
# Return value is stored in variable 'variableNumber' and the chosen Pokémon's name in variable 'nameVarNumber'
# Return value is party index number (0-5) if a Pokémon was chosen, -1 if not, and -2 if the choice was skipped due to a password (considered a success but no Pokémon will be given away)
# If giveAway is true then it will be impossible to select the last non-fainted pokemon
# skippw contains the switch numbers/names for passwords that should skip the choice
def pbChoosePokemon(variableNumber, nameVarNumber, ableProc = nil, allowIneligible = false, giveAway = false, skippw: [])
  if skippw.any? { |switch| $game_switches[switch] }
    switch = skippw.find { |switch| $game_switches[switch] }
    pwname = $cache.passwords.find { |pw|
      pw.is_a?(PasswordData) && (
        pw.function.switch == switch ||
        pw.function.switch == Switches.invert[switch] ||
        Switches.invert[pw.function.switch] == switch)
    }&.name || "unknown"
    Kernel.pbMessage(_INTL("(Skipping Pokémon choice due to '{1}' password...)", pwname))
    chosen = -2
  else
    chosen = 0
    pbFadeOutIn(99999) {
      scene = PokemonScreen_Scene.new
      screen = PokemonScreen.new(scene, $Trainer.party)
      if ableProc
        chosen = screen.pbChooseAblePokemon(ableProc, allowIneligible, giveAway)
      else
        screen.pbStartScene(_INTL("Choose a Pokémon."))
        chosen = screen.pbChoosePokemon
        screen.pbEndScene
      end
    }
  end
  pbSet(variableNumber, chosen)
  name = chosen >= 0 ? $Trainer.party[chosen].name : ""
  pbSet(nameVarNumber, name)
end

def pbChooseNonEggPokemon(variableNumber, nameVarNumber)
  pbChoosePokemon(variableNumber, nameVarNumber, proc { |poke|
    !poke.isEgg?
  })
end

def pbChooseAblePokemon(variableNumber, nameVarNumber)
  pbChoosePokemon(variableNumber, nameVarNumber, proc { |poke|
    !poke.isEgg? && poke.hp > 0
  })
end

def pbHasSpecies?(species)
  for pokemon in $Trainer.party
    next if pokemon.isEgg?

    if pokemon.species == species
      pbSet(1, $Trainer.party.index(pokemon))
      return true
    end
  end
  return false
end

def pbHasFatefulSpecies?(species)
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.species == species && pokemon.obtainMode == 4
  end
  return false
end

# Deletes the move at the given index from the given Pokémon.
def pbDeleteMove(pokemon, index)
  pokemon.moves.delete_at(index)
  if !pokemon.zmoves.nil? && pokemon.item != :INTERCEPTZ
    pokemon.zmoves.delete_at(index)
    pokemon.zmoves.push(nil)
  end
end

# Deletes the given move from the given Pokémon.
def pbDeleteMoveByID(pokemon, id, silent = true)
  return if id.nil? || !pokemon

  index = pokemon.moves.find_index { |move| move && move.move == id }
  return if index.nil?

  pkmnname = pokemon.name
  movename = getMoveName(id)
  pbDeleteMove(pokemon, index)
  Kernel.pbMessage(_INTL("{1} forgot {2}...", pkmnname, movename)) if !silent
end

def pbHasImportantFieldMove?(index)
  return false if $game_switches[:EasyHMs_Password]

  tmmoves = [:CUT, :ROCKSMASH, :STRENGTH, :SURF, :MAGMADRIFT, :WATERFALL, :DIVE, :ROCKCLIMB, :FLASH, :FLY]
  return tmmoves.any? { |tmmove| $Trainer.party[index].knowsMove?(tmmove) && !$PokemonBag.pbHasItem?(PBStuff::HMTOGOLDITEM[tmmove]) }
end

# Checks whether any Pokémon in the party knows the given move, and returns
# the index of that Pokémon, or nil if no Pokémon has that move.
def pbCheckMove(move)
  for pkmn in $Trainer.party
    return pkmn if !pkmn.isEgg? && pkmn.knowsMove?(move)
  end
  tmx = getTMFromMove(move)
  hasTMX = tmx.nil? || $PokemonBag.pbHasItem?(tmx)
  if $PokemonBag.pbHasItem?(PBStuff::HMTOGOLDITEM[move]) && !$game_switches[:NotPlayerCharacter]
    return :Trainer if hasTMX
  end
  if $game_switches[:EasyHMs_Password] && hasTMX
    # Return the first mon that -can- learn the move, if there are any
    for pkmn in $Trainer.party
      return pkmn if !pkmn.isEgg? && pkmn.SpeciesCompatible?(move)
    end
    # Otherwise return the first non-egg non-fainted mon
    for pkmn in $Trainer.party
      return pkmn if !pkmn.isEgg? && pkmn.hp > 0
    end
    # If you want to return a -random- non-egg non-fainted mon instead
    # able = $Trainer.party.select { |pkmn| !pkmn.isEgg? && pkmn.hp > 0 }
    # return able[rand(able.length)]
  end
  return :Debug if $DEBUG && Input.press?(Input::CTRL)
  return nil
end

def pbCheckMoveType(move)
  return nil if !move

  if $cache.types.keys.include?(move)
    for i in $Trainer.party
      next if i.isEgg?

      for j in i.moves
        return i if j.type == move
      end
    end
  end
  return nil
end

def getFossilMon(fossil)
  hash = {
    :HELIXFOSSIL => :OMANYTE, :DOMEFOSSIL => :KABUTO,
    :OLDAMBER => :AERODACTYL,
    :ROOTFOSSIL => :LILEEP,     :CLAWFOSSIL => :ANORITH,
    :SKULLFOSSIL => :CRANIDOS,  :ARMORFOSSIL => :SHIELDON,
    :COVERFOSSIL => :TIRTOUGA,  :PLUMEFOSSIL => :ARCHEN,
    :JAWFOSSIL => :TYRUNT,      :SAILFOSSIL => :AMAURA
  }
  # fossil bird + drake => dracozolt
  # fossil bird + dino  => arctozolt
  # fossil fish + drake => dracovish
  # fossil fish + dino  => arctovish
  $game_variables[:Fossil] = hash[fossil]
end

# Returns array of all pokemon objects in the save file
def findAllPokemon(findAllObjects = true)
  all = []

  # Party
  for mon in $Trainer.party
    all.push mon
  end

  # Storage
  if $PokemonStorage
    for box in 0...$PokemonStorage.maxBoxes
      for index in 0...$PokemonStorage[box].length
        mon = $PokemonStorage[box, index]
        next if !mon

        all.push mon
      end
    end
  end

  # Daycare
  mon = $PokemonGlobal.daycare[0][0]
  all.push mon if mon
  mon = $PokemonGlobal.daycare[1][0]
  all.push mon if mon

  # Reborn Zydonger
  if Reborn && $game_variables[700] != 0
    all.push $game_variables[700]
  end

  # This block contains pokemon that don't belong to the player and pokemon objects that don't represent real pokemon
  if findAllObjects
    # Hall of Fame
    for party in $PokemonGlobal.hallOfFame
      for mon in party
        all.push mon
      end
    end

    # Currently registered partner trainer
    if $PokemonGlobal.partner
      for mon in $PokemonGlobal.partner[3]
        all.push mon
      end
    end

    # Character switching
    if $game_variables[:PlayerDataBackup] != 0 && $game_variables[:PlayerDataBackup] != []
      for mon in $game_variables[:PlayerDataBackup][0]
        all.push mon
      end
    end

    # Battle Factory
    if $PokemonGlobal.challenge&.bc&.party
      for mon in $PokemonGlobal.challenge.bc.party
        all.push mon
      end
    end
    if $PokemonGlobal.challenge&.bc&.oldParty
      for mon in $PokemonGlobal.challenge.bc.oldParty
        all.push mon
      end
    end

    # Rejuv Chapter 15 Training Rentals
    if Rejuv
      if $game_variables[543] != 0
        for mon in $game_variables[543]
          all.push mon
        end
      end
      if $game_variables[:BlackBoxPartyStorage].is_a?(Array) && $game_variables[:BlackBoxPartyStorage] != []
        for mon in $game_variables[:BlackBoxPartyStorage]
          all.push mon
        end
      end
    end
  end

  # Fusions (needs to be at the end)
  for mon in all
    all.push mon.fused if mon.fused
  end

  return all
end

def searchItem(item)
  return true if $PokemonBag.pbQuantity(item) > 0
  return true if searchPokemon(item: item).length > 0
  return false
end

# Returns all actual Pokemon in the Player's possession
# can be filtered by Species, Form, originalTrainerID and ability
# species: Symbol
# form: integer
# originalTrainerID: integer (full ID including Secret ID)
# ability: Symbol
def searchPokemon(species: false, form: false, originalTrainerID: false, ability: false, item: false)
  pokemonList = findAllPokemon(false)
  return pokemonList if !species && !form && !originalTrainerID && !ability && !item
  filteredList = []
  for mon in pokemonList
    next if species && mon.species != species
    next if form && mon.form != form
    next if originalTrainerID && mon.trainerID != originalTrainerID
    next if ability && mon.ability != ability
    next if item && mon.item != item

    filteredList.push(mon)
  end
  return filteredList
end

def inBagOrParty?(item)
  return $PokemonBag.pbHasItem?(item) || $Trainer.party.any?{ |i| i && i.item == item }
end

def hasActiveRentalTeam?
  return false
end

################################################################################
# Regional and National Pokédexes
################################################################################
# Gets the Regional Pokédex number of the national species for the specified
# Regional Dex.  The parameter "region" is zero-based.  For example, if two
# regions are defined, they would each be specified as 0 and 1.
def pbGetRegionalNumber(region, nationalSpecies)
  if nationalSpecies <= 0 || nationalSpecies > $cache.pkmn.length
    # Return 0 if national species is outside range
    return 0
  end
  if $cache.regions[region][nationalSpecies]
    return $cache.regions[region][nationalSpecies]
  else
    return 0
  end
end

# Gets the National Pokédex number of the specified species and region.  The
# parameter "region" is zero-based.  For example, if two regions are defined,
# they would each be specified as 0 and 1.
def pbGetNationalNumber(region, regionalSpecies)
  for i in 1...$cache.regions[region].length
    next if $cache.regions[region][i].nil?
    return i if $cache.regions[region][i] == regionalSpecies
  end
  return 0
end

# Gets an array of all national species within the given Regional Dex, sorted by
# Regional Dex number.  The number of items in the array should be the
# number of species in the Regional Dex plus 1, since index 0 is considered
# to be empty.  The parameter "region" is zero-based.  For example, if two
# regions are defined, they would each be specified as 0 and 1.
def pbAllRegionalSpecies(region)
  ret = [0]
  if region >= 0
    for i in 1...$cache.regions[region].length
      next if $cache.regions[region][i].nil?

      regionalNum = $cache.regions[region][i]
      ret[regionalNum] = i if regionalNum != 0
    end
    for i in 0...ret.length
      ret[i] = 0 if !ret[i]
    end
  end
  return ret
end

# Gets the ID number for the current region based on the player's current
# position.  Returns the value of "defaultRegion" (optional, default is -1) if
# no region was defined in the game's metadata.  The ID numbers returned by
# this function depend on the current map's position metadata.
def pbGetCurrentRegion(defaultRegion = -1)
  mappos = getMapPosition($game_map.map_id)
  return mappos ? mappos[0] : defaultRegion
end

def pbUpdateRegionalDexes
  $PokemonGlobal.pokedexData ||= {}
  $PokemonGlobal.pokedexIndex = 0 if !$PokemonGlobal.pokedexIndex.is_a?(Numeric) || $PokemonGlobal.pokedexData.length != $cache.pokedexes.length
  $PokemonGlobal.pokedexData.delete_if { |index, data| !$cache.pokedexes.keys.include?(data[:symbol]) }
  dexnames = pbDexNames
  $cache.pokedexes.each { |sym, data|
    region = $cache.pokedexes.keys.index(sym)
    hash = $PokemonGlobal.pokedexData[region] || {}
    hash[:unlocked] ||= data.default || false
    hash[:lastIndex] ||= 0
    hash[:symbol] ||= sym
    $PokemonGlobal.pokedexData.store(region, hash)
  }
end

def pbViablePokedexes
  ret = []
  $PokemonGlobal.pokedexData.each { |dex, data| ret.push(dex) if data[:unlocked] }
  return ret
end

# Unlocks a Dex list.  The National Dex is - here (or nil argument).
def pbUnlockDex(dex = 0)
  dex = $cache.pokedexes.keys.index(dex) if dex.is_a?(Symbol)
  return if dex >= pbDexNames.length
  $Trainer.pokedex.canViewDex = true
  $PokemonGlobal.pokedexData[dex][:unlocked] = true
end

def pbUnlockAllDexes
  $PokemonGlobal.pokedexData.each { |sym, dex| dex[:unlocked] = true }
end

# Locks a Dex list.  The National Dex is 0 here (or nil argument).
def pbLockDex(dex = 0)
  return if dex >= pbDexNames.length
  $PokemonGlobal.pokedexData[dex][:unlocked] = false
end

def getDexName(dex)
  name = pbGetMessageFromHash(:RegionalPokedexNames, $cache.pokedexes[dex].name)
end

def pbDexNames
  ret = []
  $cache.pokedexes.each { |sym, data|
    ret.push(getDexName(sym))
  }
  return ret
end

def pbGetDexList(region = $PokemonGlobal.pokedexIndex, search: false, editor: false)
  dexlist = []
  region = $PokemonGlobal.pokedexData[region][:symbol] if region.is_a?(Numeric)
  $cache.pkmn.each { |species, wrapper|
    wrapper.pokemonData.each { |form, monData|
      next if monData.flags[:ExcludeDex]

      form = wrapper.forms.invert[form] if form.is_a?(String) # Convert form name to form num (last seen form is stored as form num)

      listentry = getDexListEntry(region, species, form, nil, search, editor)
      dexlist.push(listentry) if listentry

      monData.genderDifferences.each { |gender, genderData|
        listentry = getDexListEntry(region, species, form, gender, search, editor)
        dexlist.push(listentry) if listentry
      } if search
    }
  }
  return dexlist
end

def getDexListEntry(region, species, form, gender, search, editor)
  monData = $cache.pkmn[species, form, gender]
  if region == :National && !editor
    return nil if form != $Trainer.pokedex[species].lastSeen[:form] && !search
  else
    return nil if !monData.checkFlag?(:regionalDex)
    return nil if !monData.checkFlag?(:regionalDex)&.dig(region) && isMeaningfulForm(species, form, monData.baseForm)
    while !isMeaningfulForm(species, form, monData.baseForm) && !monData.checkFlag?(:regionalDex)&.dig(region)
      form = monData.baseForm
      monData = $cache.pkmn[species, form, gender]
      return nil if !monData.checkFlag?(:regionalDex)&.dig(region)
    end
  end
  name = getMonName(species, form)
  dexnum = getDisplayDexNum(monData, $cache.pokedexes.keys.index(region))
  if editor
    return [species, name, form, dexnum, gender]
  else
    return [species, name, monData.Height, monData.Weight, monData.BaseStats, dexnum, gender, form]
  end
end

def getDisplayDexNum(mondata, region)
  regionalnum = region == 0 ? nil : mondata.checkFlag?(:regionalDex, nil)&.dig($PokemonGlobal.pokedexData[region][:symbol])
  return regionalnum || mondata.dexnum
end

def getSpeciesNumWithZeroes(num)
  digits = $cache.pkmn.length.to_s.length
  return num.to_s.rjust(digits, "0")
end

################################################################################
# Known Trainer utilities
################################################################################

def belongsTo(pkmn, name)
  return pkmn.trainerID == KNOWN_TRAINERS[name]
end

################################################################################
# Other utilities
################################################################################
def pbTextEntry(helptext, minlength, maxlength, variableNumber)
  $game_variables[variableNumber] = pbEnterText(helptext, minlength, maxlength)
  $game_map.need_refresh = true if $game_map
end

def pbMoveTutorAnnotations(move, movelist = nil)
  annot = []
  for i in 0...6
    annot[i] = nil
    next if i >= $Trainer.party.length

    mon = $Trainer.party[i]
    if mon.isEgg?
      text = _INTL("Not Able")
      colors = ANNOT_INELIGIBLE_COLORS
    elsif mon.knowsMove?(move)
      text = _INTL("Learned")
      colors = ANNOT_SELECTED_COLORS
    elsif (movelist && movelist.any? { |j| j == mon.species }) || # Checked data from movelist
       mon.SpeciesCompatible?(move) # Checked data from method
      text = _INTL("Able")
      colors = ANNOT_ELIGIBLE_COLORS
    else
      text = _INTL("Not Able")
      colors = ANNOT_INELIGIBLE_COLORS
    end
    annot[i] = [text, colors]
  end
  return annot
end

def pbMoveTutorListAdd(move)
  $Trainer.tutorlist = [] if !$Trainer.tutorlist
  if $Trainer.tutorlist == []
    gear = Rejuv ? _INTL("Cybernav") : _INTL("Pokégear")
    Kernel.pbMessage(_INTL("Hey did you know us Move Tutors have an app set up? Check it out on your {1}!", gear))
  end
  addTutorMove(move)
end

def addTutorMove(moveid)
  $Trainer.tutorlist.push(moveid) unless $Trainer.tutorlist.include?(moveid)
end

def checkTutorMove(moveid)
  $Trainer.tutorlist = [] if !$Trainer.tutorlist
  return $Trainer.tutorlist.include?(moveid)
end

def moveTutorRibbon(pokemon)
  ret = false
  if pokemon.canRelearnAll?
    Kernel.pbMessage(_INTL("It can already remember everything."))
  else
    pokemon.activateRelearner()
    ret = true
  end
  return ret
end

def pbMoveTutorChoose(move, movelist = nil, bymachine: false, bytutorapp: false)
  ret = false
  pbFadeOutIn(99999) {
    scene = PokemonScreen_Scene.new
    movename = getMoveName(move)
    screen = PokemonScreen.new(scene, $Trainer.party)
    annot = pbMoveTutorAnnotations(move, movelist)
    screen.pbStartScene(_INTL("Teach which Pokémon?"), annot)
    if !$Trainer.tutorlist
      $Trainer.tutorlist = []
    end
    loop do
      chosen = screen.pbChoosePokemon
      if chosen >= 0
        pokemon = $Trainer.party[chosen]
        if pokemon.isEgg?
          Kernel.pbMessage(_INTL("{1} can't be taught to an Egg.", movename))
        elsif (pokemon.isShadow? rescue false)
          Kernel.pbMessage(_INTL("Shadow Pokémon can't be taught any moves."))
        elsif movelist && !movelist.any? { |j| j == pokemon.species }
          Kernel.pbMessage(_INTL("{1} is not compatible with {2}, so it can't be learned.", movename, pokemon.name))
        elsif !pokemon.SpeciesCompatible?(move)
          Kernel.pbMessage(_INTL("{1} is not compatible with {2}, so it can't be learned.", movename, pokemon.name))
        else
          if pbTryLearnMove(pokemon, move, dontrestorePP: bymachine || bytutorapp)
            pbMoveTutorListAdd(move) if bymachine == false
            ret = true
            break
          end
        end
      else
        break
      end
    end
    screen.pbEndScene
  }
  return ret # Returns whether the move was learned by a Pokemon
end

def pbMoveReminderAnnotations
  annot = []
  for i in 0...6
    annot[i] = nil
    next if i >= $Trainer.party.length

    mon = $Trainer.party[i]
    if mon.isEgg? || !pbHasRelearnableMove?(mon)
      text = _INTL("Not Able")
      colors = ANNOT_INELIGIBLE_COLORS
    elsif mon.canRelearnAll?
      text = _INTL("Learned")
      colors = ANNOT_SELECTED_COLORS
    else
      text = _INTL("Able")
      colors = ANNOT_ELIGIBLE_COLORS
    end
    annot[i] = [text, colors]
  end
  return annot
end

def pbMoveReminderChoose
  chosen = 0
  pbFadeOutIn(99999) {
    scene = PokemonScreen_Scene.new
    screen = PokemonScreen.new(scene, $Trainer.party)
    annot = pbMoveReminderAnnotations
    screen.pbStartScene(_INTL("Teach which Pokémon?"), annot)
    chosen = screen.pbChoosePokemon
    # Failure messages are handled by the Move Reminder events
    # Refer to pbMoveReminderAnnotations for conditions to write messages for
    screen.pbEndScene
  }
  pbSet(1, chosen)
end

def pbChooseMove(pokemon, variableNumber, nameVarNumber)
  return if !pokemon

  ret = -1
  pbFadeOutIn(99999) {
    scene = PokemonSummaryScene.new
    screen = PokemonSummary.new(scene)
    ret = screen.pbStartForgetScreen([pokemon], 0, 0)
  }
  $game_variables[variableNumber] = ret
  if ret >= 0
    $game_variables[nameVarNumber] = getMoveName(pokemon.moves[ret].move)
  else
    $game_variables[nameVarNumber] = ""
  end
  $game_map.need_refresh = true if $game_map
end

# Opens the Pokémon screen
def pbPokemonScreen
  return if !$Trainer

  sscene = PokemonScreen_Scene.new
  sscreen = PokemonScreen.new(sscene, $Trainer.party)
  pbFadeOutIn(99999) { sscreen.pbPokemonScreen }
end

def pbSaveScreen(cancancel: true)
  scene = PokemonSaveScene.new
  screen = PokemonSave.new(scene)
  scene.pbStartScreen
  ret = pbHandleSave(cancancel: cancancel)
  scene.pbEndScreen
  return ret
end

# stub for Rejuv
def xenTowerInProgress
  return false
end

def pbCommaNumber(number)
  return number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
end

# Apparently this method was removed in newer Ruby versions
if !Array.method_defined?(:nitems)
  class Array
    def nitems
      count { |x| !x.nil? }
    end
  end
end

def startTimer
  $timer = Time.now
end

def stopTimer
  puts Time.now - $timer
end

# gotta put this here so saves don't crash
class BugContestState
end

ROTOM_MOVES = [
  :OVERHEAT,  # Heat, Microwave
  :HYDROPUMP, # Wash, Washing Machine
  :BLIZZARD,  # Frost, Refrigerator
  :AIRSLASH,  # Fan
  :LEAFSTORM, # Mow, Lawnmower
]

def rotomScript(pokemon)
  form = pokemon.form

  ROTOM_MOVES.each { |move|
    pbDeleteMoveByID(pokemon, move, false)
  }
  pbTryLearnMove(pokemon, ROTOM_MOVES[form - 1]) if form > 0
  pokemon.pbLearnMove(:THUNDERSHOCK) if pokemon.moves.empty?
end

def noExp?
  return true if $game_switches[:No_EXP_Gain]

  return $game_switches[:Percent_Exp_Gains] && $game_variables[:Exp_Percent] == 0
end

def posExp?
  return true if !$game_switches[:Percent_Exp_Gains]

  return $game_switches[:Percent_Exp_Gains] && $game_variables[:Exp_Percent] > 0
end

def negExp?
  return $game_switches[:Percent_Exp_Gains] && $game_variables[:Exp_Percent] < 0
end

def listMons
  File.open('forms.txt', 'w') do |file|
    $cache.pkmn.each do |species, mondata|
      mondata.forms.each do |form, name|
        data = $cache.pkmn[species, form]
        next if data.checkFlag?(:ExcludeDex)
        next if name == "Giga Form"
        file.puts data.name + (name != "Normal Form" ? ", " + name : "")
      end
    end
  end
end

def shapeBitmap(shape, size, color)
  pixels = []
  case shape
    when :CursorLeft
      width, height = size, size * 2
      for column in 0...width
        effcolumn = column - (column % 2) # We want the resolution of a pixel, not a half-pixel
        middle = size.even? ? 2 : 1
        for row in (height / 2 - middle - effcolumn)...(height / 2 + middle + effcolumn)
          pixels.push([column, row])
        end
      end
    when :CursorRight
      width, height = size, size * 2
      for column in 0...width
        effcolumn = column - (column % 2) # We want the resolution of a pixel, not a half-pixel
        middle = size.even? ? 2 : 1
        for row in (height / 2 - middle - effcolumn)...(height / 2 + middle + effcolumn)
          pixels.push([width - 1 - column, row]) # Simply mirroring the columns from CursorLeft
        end
      end
    when :Rect
      width, height = *size # Size should be given as an array in this case
      for column in 0...width
        for row in 0...height
          pixels.push([column, row])
        end
      end
    when :RectBorder
      width, height = *size # Size should be given as an array in this case
      for column in 0...width
        effcolumn = column - (column % 2) # Pixel resolution
        for row in 0...height
          effrow = row - (row % 2) # Pixel resolution
          pixels.push([column, row]) if [0, height - 2].include?(effrow) || [0, width - 2].include?(effcolumn)
        end
      end
  end
  bitmap = Bitmap.new(width, height)
  pixels.each { |x, y| bitmap.set_pixel(x, y, color) }
  return bitmap
end

# Takes a bitmap and returns the [x, y, width, height] values to be used to trim empty space from the edges of the bitmap
def trimmedBitmapCoords(bitmap)
  fullWidth, fullHeight = bitmap.width, bitmap.height

  usedCols = (0...fullWidth).select { |x|
    (0...fullHeight).any? { |y| bitmap.get_pixel(x, y).alpha != 0 }
  }
  retX = usedCols.min
  retWidth = usedCols.max - retX + 1

  usedRows = (0...fullHeight).select { |y|
    (0...fullWidth).any? { |x| bitmap.get_pixel(x, y).alpha != 0 }
  }
  retY = usedRows.min
  retHeight = usedRows.max - retY + 1

  return retX, retY, retWidth, retHeight
end

def trimmedBitmap(bitmap)
  x, y, width, height = trimmedBitmapCoords(bitmap)
  newbitmap = Bitmap.new(width, height)
  newbitmap.blt(0, 0, bitmap, Rect.new(x, y, width, height))
  return newbitmap
end

def battlerSquare(bitmap, size = 192)
  width = bitmap.width
  height = bitmap.height
  return bitmap if width == size && width == height
  size = width if width > size
  size = height if height > size
  return changeCanvasSize(bitmap, size)
end

def changeCanvasSize(bitmap, size)
  width = bitmap.width
  height = bitmap.height
  offsetX = (size - width) / 2
  offsetX -= 1 if offsetX % 2 == 1
  offsetY = (size - height) / 2
  offsetY -= 1 if offsetY % 2 == 1
  resizedBitmap = Bitmap.new(size, size)
  resizedBitmap.blt(offsetX, offsetY, bitmap, bitmap.rect)

  return resizedBitmap
end

def resizeNearestNeighbor(bitmap, factor)
  newdata = []
  #unpack data into colors
  olddata = bitmap.raw_data.unpack("I*").map{ |i| i.to_color }

  #get new bounds for new bitmap creation
  newWidth = (bitmap.width * factor).to_i
  newHeight = (bitmap.height * factor).to_i

  #iterate through new bounds
  for y in 0...newHeight
    for x in 0...newWidth
      #calculate original x and y
      oldX = (x / factor).round
      oldY = (y / factor).round

      #calculate original index
      oldIndex = (oldY * bitmap.width + oldX).to_i

      #append
      newdata.push(olddata[oldIndex])
    end
  end

  newBitmap = Bitmap.new(newWidth, newHeight)
  #repack
  newBitmap.raw_data = newdata.map{ |c| c.to_i }.pack("I*")
  return newBitmap
end

# Used by pokedex for encounter location TTS (nest page) and evolution locations (advanced page)
def mapIDsToMapNames(mapIDs)
  mapIDs.reject! { |mapid| !pbCanUseBike?(mapid) } unless mapIDs.all? { |mapid| !pbCanUseBike?(mapid) } # remove buildings unless it's all buildings
  mapNames = mapIDs.map { |id| removeFloorName(pbGetUniqueMapName(id)) }
  mapNames.delete("REMOVED")
  return mapNames.uniq.sort
end

def removeFloorName(name)
  words = name.split(" ")
  words = words[0..-2] if words.length > 1 && words[-1].match(/[0-9]F\Z/) # matches any string that ends with a number followed by an F
  return words.join(" ")
end

def getTimeFromArray(time)
  return time unless time.is_a?(Array)
  timeNow = pbGetTimeNow
  return Time.new(timeNow.year + time[0], time[1], time[2], timeNow.hour, timeNow.min, timeNow.sec)
end

def getArrayFromTime(time)
  return time if time.is_a?(String)
  return time.inspect if time.is_a?(Symbol)
  time = Time.at(time) if time.is_a?(Numeric)
  timeNow = pbGetTimeNow
  return [time.year - timeNow.year, time.month, time.day]
end

def getMonFormName(mon, form = 0, gender = nil, returncustom: false)
  form = form.to_a[0] if form.is_a?(Range)
  formnames = $cache.pkmn[mon].forms
  form = formnames.invert[form] if form.is_a?(String)
  form = 0 if form.nil? || !form.is_a?(Numeric)
  name = getMonName(mon, form)
  name = "Nidoran-F" if mon == :NIDORANfE
  name = "Nidoran-M" if mon == :NIDORANmA

  return name if formnames.empty? || formnames.length == 1 || form == 0 ||
      [:MINIOR, :CHERRIM, :AEGISLASH, :CASTFORM, :SHELLOS, :GASTRODON, :WISHIWASHI, :DEERLING, :SAWSBUCK, :MIMIKYU].include?(mon)
  return name + "-#{gender}" if gender && !$cache.pkmn[mon, form].genderDifferences.empty?

  formName = formnames[form]
  return name if !formName

  if mon == :DARMANITAN
    zen = formName.include?("Zen")
    galar = formName.include?("Galar")
    return name + (galar ? "-Galar" : "") + (zen ? "-Zen" : "")
  end
  return name + "-Alola" if formName.include?("Alolan")
  return name + "-Galar" if formName.include?("Galarian")
  return name + "-Hisui" if formName.include?("Hisuian")
  return name + "-Aevian" if formName.include?("Aevian")
  return name + "-Paldea" if formName.include?("Paldean")
  return name + "-Mega-X" if formName.include?("Mega X")
  return name + "-Mega-Y" if formName.include?("Mega Y")
  return name + "-Mega-Z" if formName.include?("Mega Z")
  return name + "-Mega" if formName.include?("Mega")
  return name + "-Giga" if formName.include?("Giga")
  return name + "-Primal" if formName.include?("Primal")
  return name + "-Therian" if formName.include?("Therian")
  return name + "-Origin" if formName.include?("Origin")
  return "Necrozma-Dusk-Mane" if mon == :NECROZMA && form == 1
  return "Necrozma-Dawn-Wings" if mon == :NECROZMA && form == 2
  return "Necrozma-Ultra" if mon == :NECROZMA && form == 3
  return "Deoxys-Attack" if mon == :DEOXYS && form == 1
  return "Deoxys-Defense" if mon == :DEOXYS && form == 2
  return "Deoxys-Speed" if mon == :DEOXYS && form == 3
  return "Shaymin-Sky" if mon == :SHAYMIN && form == 1
  return "Kyurem-White" if mon == :KYUREM && form == 1
  return "Kyurem-Black" if mon == :KYUREM && form == 2
  return "Meloetta-Pirouette" if mon == :MELOETTA && form == 1
  return "Hoopa-Unbound" if mon == :HOOPA && form == 1
  return "Zygarde-10%" if mon == :ZYGARDE && form == 1
  return "Zygarde-Complete" if mon == :ZYGARDE && form == 2
  return "Zacian-Crowned" if mon == :ZACIAN && form == 1
  return "Zamazenta-Crowned" if mon == :ZAMAZENTA && form == 1
  return "Eternatus-Eternamax" if mon == :ETERNATUS && form == 1
  return "Urshifu-Rapid-Strike" if mon == :URSHIFU && form == 1
  return "Calyrex-Ice" if mon == :CALYREX && form == 1
  return "Calyrex-Shadow" if mon == :CALYREX && form == 2
  if mon == :OGERPON
    case form
      when 1 then return name + "-Wellspring"
      when 2 then return name + "-Hearthflame"
      when 3 then return name + "-Cornerstone"
      when 4 then return name + "-Teal-Tera"
      when 5 then return name + "-Wellspring-Tera"
      when 6 then return name + "-Hearthflame-Tera"
      when 7 then return name + "-Cornerstone-Tera"
    end
  end
  return "Terapagos-Terastal" if mon == :TERAPAGOS && form == 1
  return "Terapagos-Stellar" if mon == :TERAPAGOS && form == 2
  if mon == :TAUROS
    case form
      when 1 then return name + "-Paldea-Combat"
      when 2 then return name + "-Paldea-Blaze"
      when 3 then return name + "-Paldea-Aqua"
    end
  end
  return "Lunatone-Idol" if mon == :LUNATONE && form == 1
  return "Solrock-Idol" if mon == :SOLROCK && form == 1
  if mon == :WORMADAM || mon == :BURMY
    case form
      when 1 then return name + "-Sandy"
      when 2 then return name + "-Trash"
    end
  end
  if mon == :ROTOM
    case form
      when 1 then return "Rotom-Heat"
      when 2 then return "Rotom-Wash"
      when 3 then return "Rotom-Frost"
      when 4 then return "Rotom-Fan"
      when 5 then return "Rotom-Mow"
    end
  end
  return "Basculin-Blue-Striped" if mon == :BASCULIN && form == 1
  return "Basculin-White-Striped" if mon == :BASCULIN && form == 2
  return "Greninja-Bond" if mon == :GRENINJA && form == 2
  return "Lycanroc-Midnight" if mon == :LYCANROC && form == 1
  return "Lycanroc-Dusk" if mon == :LYCANROC && form == 2
  if mon == :ORICORIO
    case form
      when 1 then return "Oricorio-Pom-Pom"
      when 2 then return "Oricorio-Pa'u"
      when 3 then return "Oricorio-Sensu"
    end
  end
  return "Toxtricity-Low-Key" if mon == :TOXTRICITY && form == 1
  return "Ursaluna-Bloodmoon" if mon == :URSALUNA && form == 1
  if mon == :SQUAWKABILLY
    case form
      when 1 then return "Squawkabilly-Blue"
      when 2 then return "Squawkabilly-Yellow"
      when 3 then return "Squawkabilly-White"
    end
  end
  return "Maushold-Three" if mon == :MAUSHOLD && form == 1
  return "Palafin-Hero" if mon == :PALAFIN && form == 1
  return "Dudunsparce-Three-Segment" if mon == :DUDUNSPARCE && form == 1
  return "Gimmighoul-Roaming" if mon == :GIMMIGHOUL && form == 1
  if [:FLABEBE, :FLOETTE, :FLORGES].include?(mon)
    flower = ""
    case form
      when 0 then flower = "Red"
      when 1 then flower = "Blue"
      when 2 then flower = "Black"
      when 3 then flower = "Green"
      when 4 then flower = "Purple"
    end
    return name + "-" + flower
  end
  if mon == :PUMPKABOO || mon == :GOURGEIST
    return name + "-Small" if formName.include?("Small")
    return name + "-Medium" if formName.include?("Medium")
    return name + "-Large" if formName.include?("Large")
    return name + "-Jumbo" if formName.include?("Jumbo")
  end
  if mon == :WOMRADAM
    return name + "-Sandy" if formName.include?("Sandy")
    return name + "-Trash" if formName.include?("Trash")
  end
  if mon == :ARCEUS || mon == :SILVALLY
    return name if form == 0
    return name + "-#{formName}"
  end
  return returncustom ? [name, formName] : name + " " + formName
end

def isCosmeticForm(species, form1, form2)
  return false if PBStuff::CosmeticFormsExceptions.any? { |cspecies, cforms|
    species == cspecies && cforms.include?(form1) && cforms.include?(form2)
  }

  # currently checks type, stats, and abilities
  mondata1, mondata2 = $cache.pkmn[species, form1], $cache.pkmn[species, form2]
  return false if mondata1.Type1 != mondata2.Type1
  return false if mondata1.Type2 != mondata2.Type2
  return false if mondata1.BaseStats != mondata2.BaseStats
  return false if mondata1.Abilities != mondata2.Abilities
  return false if mondata1.HiddenAbility != mondata2.HiddenAbility
  return false if mondata1.Weight != mondata2.Weight

  return true
end

# Note: Currently unused, as `isMeaningfulForm` considers Megas/Similars as meaningful.
# Method itself is likely still useful outside of that context.
def isBattleOnlyForm(species, form1, form2)
  return true if PBStuff::BattleForms.any? { |bspecies, bforms|
    species == bspecies && bforms.include?(form1) && bforms.include?(form2)
  }
  return true if [form1, form2].any? { |thisform|
    otherform = thisform == form1 ? form2 : form1
    data = $cache.pkmn[species, thisform]
    next true if data.MegaEvolutions&.values.include?($cache.pkmn[species].forms[otherform])
    next true if data.checkFlag?(:UltraForm) == otherform
    next true if data.checkFlag?(:PrimalForm) == otherform
    next true if data.checkFlag?(:TerastalForm) == otherform
    next false
  }
  return false
end

def isMeaningfulForm(species, form1, form2)
  return true if form1 == form2

  form1 = $cache.pkmn[species].forms.invert[form1] if form1.is_a?(String)
  form2 = $cache.pkmn[species].forms.invert[form2] if form2.is_a?(String)

  return false if isCosmeticForm(species, form1, form2)
  return false if PBStuff::BattleForms.any? { |bspecies, bforms|
    species == bspecies && bforms.include?(form1) && bforms.include?(form2)
  }

  return true
end

def hasGenderDifference?(species, form = nil)
  form ||= 0
  form = $cache.pkmn[species].forms.invert[form] if form.is_a?(String)
  formnumber = form == 0 ? "" : "_#{form}"
  formnumber = form.to_s if Rejuv
  dexnum = $cache.pkmn[species, form].dexnum.to_s.rjust(3, "0")
  dexname = species.to_s.downcase
  poke = Desolation ? dexnum : dexname
  gendermod = (Desolation ? "_" : "") + "f"

  return pbCheckPokemonBitmapFiles(poke, formnumber: formnumber, gender: :F)&.start_with?("Graphics/Battlers/#{poke}/#{formnumber}#{gendermod}") if Rejuv
  return pbCheckPokemonBitmapFiles(poke, formnumber: formnumber, gender: :F)&.start_with?("Graphics/Battlers/#{poke}#{gendermod}")
end

def hasBattleDifference?(species, form = nil)
  form ||= 0
  form = $cache.pkmn[species].forms.invert[form] if form.is_a?(String)
  formnumber = form == 0 ? "" : "_#{form}"
  formnumber = form.to_s if Rejuv
  dexnum = $cache.pkmn[species, form].dexnum.to_s.rjust(3, "0")
  dexname = species.to_s.downcase
  poke = Desolation ? dexnum : dexname

  return pbCheckPokemonBitmapFiles(poke, formnumber: formnumber, special: :overworld)&.start_with?("Graphics/Battlers/#{poke}/#{formnumber}o") if Rejuv
  return pbCheckPokemonBitmapFiles(poke, formnumber: formnumber, special: :overworld)&.start_with?("Graphics/Battlers/#{poke}o")
end

def hasShadowSprite?(species, form = nil)
  form ||= 0
  form = $cache.pkmn[species].forms.invert[form] if form.is_a?(String)
  formnumber = form == 0 ? "" : "_#{form}"
  formnumber = form.to_s if Rejuv
  dexnum = $cache.pkmn[species, form].dexnum.to_s.rjust(3, "0")
  dexname = species.to_s.downcase
  poke = Desolation ? dexnum : dexname

  return pbCheckPokemonBitmapFiles(poke, formnumber: formnumber, special: :shadow)&.start_with?("Graphics/Battlers/#{poke}/#{formnumber}_shadow") if Rejuv
  return pbCheckPokemonBitmapFiles(poke, formnumber: formnumber, special: :shadow)&.start_with?("Graphics/Battlers/#{poke}_shadow")
end

def exporttotext
  choices = {
    Party: _INTL("Party"),
    Boxes: _INTL("Boxes"),
    PartyAndBoxes: _INTL("Party and Boxes")
  }
  choice = Kernel.pbChoice(_INTL("Select locations to export Pokémon from."), choices)
  return if choice.nil?

  if choice == :Party
    mons = $Trainer.party.clone
  else
    boxchoices = {}
    for box in 0...$PokemonStorage.maxBoxes
      unless $PokemonStorage[box].getAllPokemon().empty?
        boxchoices[box] = $PokemonStorage[box].name
      end
    end

    startbox = Kernel.pbChoice(_INTL("Select the first box."), boxchoices)
    return if startbox.nil?

    endbox = Kernel.pbChoice(_INTL("Select the last box."), boxchoices)
    return if endbox.nil?

    mons = choice == :PartyAndBoxes ? $Trainer.party.clone : []
    (startbox..endbox).each { |box| mons += $PokemonStorage[box].getAllPokemon() }
  end

  string = ""
  for poke in mons
    hasnickname = poke.name != getMonName(poke.species, poke.form)
    technicalname = getMonFormName(poke.species, poke.form, poke.gender)
    string += hasnickname ? "#{poke.name} (#{technicalname})" : technicalname
    string += " (M)" if poke.isMale?
    string += " (F)" if poke.isFemale?
    string += " @ #{getItemName(poke.item)}" if !poke.item.nil?
    string += "\nAbility: #{getAbilityName(poke.ability)}"
    string += "\nLevel: #{poke.level}"
    string += "\nShiny: Yes" if poke.isShiny?
    string += "\nEVs: #{poke.ev[0]} HP / #{poke.ev[1]} Atk / #{poke.ev[2]} Def / #{poke.ev[3]} SpA / #{poke.ev[4]} SpD / #{poke.ev[5]} Spe"
    string += "\n#{getNatureName(poke.nature)} Nature"
    string += "\nIVs: #{poke.iv[0]} HP / #{poke.iv[1]} Atk / #{poke.iv[2]} Def / #{poke.iv[3]} SpA / #{poke.iv[4]} SpD / #{poke.iv[5]} Spe"
    poke.moves.each { |move| string += "\n- #{getMoveName(move.move)}" }
    string += "\n\n"
  end

  timestring = Time.new.strftime("%Y-%m-%d_%H-%M-%S")
  Dir.mkdir(RTP.getSaveFolder + "PokemonExports") if !File.exist?(RTP.getSaveFolder + "PokemonExports")
  filename = RTP.getSaveFileName("PokemonExports/#{timestring} - #{$Trainer.name} - #{choices[choice]} - #{mons.length} Pokemon.txt")
  File.open(filename, "w") { |f| f.write(string) }
  Kernel.pbMessage(_INTL("Export created at {1}.", filename.gsub("/", " / ")))
end

def useTrainerParty(type, name, id)
  trainerinfo = pbLoadTrainer(type, name, id)
  party = trainerinfo[2]
  $Trainer.party = party
end

################################################################################
# Sprite Centering methods
################################################################################
def centerBattleSprites()
  RPG::Cache.clear

  compileMons
  compileMonsGen9 if Reborn
  $cache.cacheDex

  # Load montext
  file = Reborn ? "montext_modern.rb" : "montext.rb"
  File.open("Scripts/#{GAMEFOLDER}/Definitions/#{file}") { |f|
    eval(f.read)
  }
  mons = MONHASH
  data = {}

  cprint "Centering #{"Pokemon".yellow} sprites...\n"
  mons.each do |monsym, mondata|
    # Ogerpon, Silvally and Cramorant have manually aligned sprites so that all forms are on the same base line.
    # Minior is kinda incompatible with this because of using form 7 as base form.
    if [:OGERPON, :CRAMORANT, :SILVALLY, :MINIOR].include?(monsym)
      data[monsym] = mondata
      next
    end

    cprint "Pokemon #{monsym.to_s.yellow}"
    cprint "             \r"
    # Load sprites
    baseform = mondata.values[0].clone
    dexnum = baseform[:dexnum]
    dexname = monsym.to_s.downcase
    names = [
      sprintf("Graphics/Battlers/%03d", dexnum),
      sprintf("Graphics/Battlers/%03d_f", dexnum),
      sprintf("Graphics/Battlers/%03d_o", dexnum),
      sprintf("Graphics/Battlers/%s", dexname),
      sprintf("Graphics/Battlers/%sf", dexname),
      sprintf("Graphics/Battlers/%so", dexname),
    ]
    sprites = {}
    for name in names
      bitmap = pbResolveBitmap(name)
      next if !bitmap
      sprites[bitmap] = RPG::Cache.load_bitmap(bitmap)
    end
    data[monsym] = {}
    spritesChanged = false

    # Shift sprites
    i = -1
    mondata.each do |form, formdata|
      next if form.is_a?(Symbol)
      i += 1

      battlerEnemyX = formdata[:BattlerEnemyX]
      battlerEnemyY = formdata[:BattlerEnemyY]
      battlerAltitude = formdata[:BattlerAltitude]
      battlerPlayerX = formdata[:BattlerPlayerX]
      battlerPlayerY = formdata[:BattlerPlayerY]
      battlerShadowSize = formdata[:BattlerShadowSize]
      battlerEnemyX = baseform[:BattlerEnemyX] if battlerEnemyX.nil?
      battlerEnemyY = baseform[:BattlerEnemyY] if battlerEnemyY.nil?
      battlerAltitude = baseform[:BattlerAltitude] if battlerAltitude.nil?
      battlerPlayerX = baseform[:BattlerPlayerX] if battlerPlayerX.nil?
      battlerPlayerY = baseform[:BattlerPlayerY] if battlerPlayerY.nil?
      battlerShadowSize = baseform[:BattlerShadowSize] if battlerShadowSize.nil?

      opponentY = 0
      opponentY += battlerEnemyY if battlerEnemyY
      opponentY -= battlerAltitude if battlerAltitude
      shift = shiftSpritesY(sprites.values, i * 2)
      opponentY -= (shift / 2).floor if shift != nil
      spritesChanged = true if shift.to_i != 0

      opponentX = 0
      opponentX += battlerEnemyX if battlerEnemyX
      shift = shiftSpritesX(sprites.values, i * 2)
      opponentX -= (shift / 2).floor if shift != nil
      spritesChanged = true if shift.to_i != 0
      shift = shiftSpritesX(sprites.values, i * 2, shiny: true)
      spritesChanged = true if shift.to_i != 0

      playerY = 0
      playerY += battlerPlayerY if battlerPlayerY
      shift = shiftSpritesY(sprites.values, i * 2 + 1)
      playerY -= (shift / 2).floor if shift != nil
      spritesChanged = true if shift.to_i != 0

      playerX = 0
      playerX += battlerPlayerX if battlerPlayerX
      shift = shiftSpritesX(sprites.values, i * 2 + 1)
      playerX -= (shift / 2).floor if shift != nil
      spritesChanged = true if shift.to_i != 0
      shift = shiftSpritesX(sprites.values, i * 2 + 1, shiny: true)
      spritesChanged = true if shift.to_i != 0

      battlerShadowSize = 18 if battlerShadowSize.nil? && (battlerAltitude && battlerAltitude > 0 && (i == 0 || !data[monsym][mondata.keys[0]][:BattlerShadowSize]))

      data[monsym][form] = {}
      if formdata[:toobig]
        # Keep existing data for toobig forms.
        data[monsym][form][:BattlerShadowSize] = formdata[:BattlerShadowSize] if formdata[:BattlerShadowSize]
        data[monsym][form][:BattlerEnemyX] = formdata[:BattlerEnemyX] if formdata[:BattlerEnemyX]
        data[monsym][form][:BattlerEnemyY] = formdata[:BattlerEnemyY] if formdata[:BattlerEnemyY]
        data[monsym][form][:BattlerPlayerX] = formdata[:BattlerPlayerX] if formdata[:BattlerPlayerX]
        data[monsym][form][:BattlerPlayerY] = formdata[:BattlerPlayerY] if formdata[:BattlerPlayerY]
      else
        data[monsym][form][:BattlerShadowSize] = battlerShadowSize if i == 0 || battlerShadowSize != data[monsym][mondata.keys[0]][:BattlerShadowSize]
        data[monsym][form][:BattlerEnemyX] = opponentX if (i == 0 && opponentX != 0) || opponentX != data[monsym][mondata.keys[0]][:BattlerEnemyX].to_i
        data[monsym][form][:BattlerEnemyY] = opponentY if (i == 0 && opponentY != 0) || opponentY != data[monsym][mondata.keys[0]][:BattlerEnemyY].to_i
        data[monsym][form][:BattlerPlayerX] = playerX if (i == 0 && playerX != 0) || playerX != data[monsym][mondata.keys[0]][:BattlerPlayerX].to_i
        data[monsym][form][:BattlerPlayerY] = playerY if (i == 0 && playerY != 0) || playerY != data[monsym][mondata.keys[0]][:BattlerPlayerY].to_i
      end
    end

    # Save sprites
    if spritesChanged
      sprites.each do |name, sprite|
        sprite.to_file(name)
      end
    end
  end
  cprint "Success.                                                \n".green

  # Dump montext
  genbackup = Gen
  files = ["montext.rb"]
  files.push "montext_modern.rb" if Reborn
  files.each do |file|
    File.open("Scripts/#{GAMEFOLDER}/Definitions/#{file}") { |f|
      eval(f.read)
    }
    newhash = MonDataHash.new()
    mons = MONHASH
    mons.each do |monsym, mondata|
      mondata.each do |form, formdata|
        next if form.is_a?(Symbol)

        mons[monsym][form].delete(:BattlerAltitude)
        mons[monsym][form].delete(:BattlerShadow)
        mons[monsym][form].delete(:BattlerShadowSize)
        mons[monsym][form].delete(:BattlerEnemyX)
        mons[monsym][form].delete(:BattlerEnemyY)
        mons[monsym][form].delete(:BattlerPlayerX)
        mons[monsym][form].delete(:BattlerPlayerY)
        next if data[monsym][form].nil?

        mons[monsym][form][:BattlerShadowSize] = data[monsym][form][:BattlerShadowSize] if data[monsym][form][:BattlerShadowSize]
        mons[monsym][form][:BattlerEnemyX] = data[monsym][form][:BattlerEnemyX] if data[monsym][form][:BattlerEnemyX]
        mons[monsym][form][:BattlerEnemyY] = data[monsym][form][:BattlerEnemyY] if data[monsym][form][:BattlerEnemyY]
        mons[monsym][form][:BattlerPlayerX] = data[monsym][form][:BattlerPlayerX] if data[monsym][form][:BattlerPlayerX]
        mons[monsym][form][:BattlerPlayerY] = data[monsym][form][:BattlerPlayerY] if data[monsym][form][:BattlerPlayerY]
      end

      inheritFormData(mondata)
      newhash[monsym] = MonWrapper.new(monsym, mondata)
    end
    Object.const_set(:Gen, Reborn && file == "montext.rb" ? 7 : Champs)
    monDump(newhash, game: GAMEFOLDER, file: file)
    Object.const_set(:Gen, genbackup)
  end
  compileMons
  compileMonsGen9 if Reborn
end

def shiftSpritesY(sprites, i)
  normal = [freelines([sprites[0]], i, 1, 0...192), freelines([sprites[0]], i, -1, 0...192)]
  return nil if normal[0] >= 128 || normal[1] >= 96
  baseline = ((normal.sum / 2).floor / 2).floor * 2
  return 0 if baseline == normal[1]
  full = [freelines(sprites, i, 1, 0...384), freelines(sprites, i, -1, 0...384)]
  sprites.each do |sprite|
    clone = sprite.clone
    sprite.clear_rect(0, 192 * i, 384, 192)
    sprite.blt(0, 192 * i + normal.sum - baseline - (normal[0] - full[0]), clone, Rect.new(0, 192 * i + full[0], 384, 192 - full.sum))
  end
  return normal[1] - baseline
end

def freelines(sprites, i, direction, range = 0...384)
  freelines = []
  sprites.each do |sprite|
    # 1 = get freelines from the top
    # -1 = get freelines from the bottom
    # the brackets are correct!
    y = direction == -1 ? 192 * (i + 1) : 192 * i - 1
    freecounter = 0
    192.times do
      y += direction
      free = true
      for x in range
        free = false if sprite.get_pixel(x, y).alpha != 0
      end
      if free
        freecounter += 1
      else
        break
      end
    end
    freelines.push freecounter
  end
  return freelines.min
end

def shiftSpritesX(sprites, i, shiny: false)
  normal = [freecolumns([sprites[0]], i, 1, shiny: shiny), freecolumns([sprites[0]], i, -1, shiny: shiny)]
  return nil if normal[0] >= 96 || normal[1] >= 96
  offset = ((normal.sum / 2).floor / 2).floor * 2
  return 0 if offset == normal[1]
  full = [freecolumns(sprites, i, 1, shiny: shiny), freecolumns(sprites, i, -1, shiny: shiny)]
  sprites.each do |sprite|
    clone = sprite.clone
    x = shiny ? 192 : 0
    sprite.clear_rect(x, 192 * i, 192, 192)
    sprite.blt(x + normal.sum - offset - (normal[0] - full[0]), 192 * i, clone, Rect.new(x + full[0], 192 * i, 192 - full.sum, 192))
  end
  return normal[1] - offset
end

def freecolumns(sprites, i, direction, shiny: false)
  freecolumns = []
  sprites.each do |sprite|
    # 1 = get freecolumns from the left
    # -1 = get freecolumns from the right
    # the brackets are correct!
    x = direction == -1 ? 192 : -1
    x += 192 if shiny
    freecounter = 0
    192.times do
      x += direction
      free = true
      for y in (192 * i - 1)...(192 * (i + 1))
        free = false if sprite.get_pixel(x, y).alpha != 0
      end
      if free
        freecounter += 1
      else
        break
      end
    end
    freecolumns.push freecounter
  end
  return freecolumns.min
end

def syncPositions
  writes = [:BattlerPlayerX, :BattlerPlayerY, :BattlerEnemyX, :BattlerEnemyY, :BattlerShadowSize, :BattlerShadowX]
  deletes = [:BattlerAltitude, :BattlerShadow] + writes

  File.open("Scripts/Reborn/Definitions/montext_modern.rb") { |f|
    eval(f.read)
  }
  mons = MONHASH

  ["Rejuv", "Desolation"].each do |game|
    File.open("Scripts/#{game}/Definitions/montext.rb") { |f|
      eval(f.read)
    }
    newmons = MONHASH
    newhash = MonDataHash.new()

    mons.each do |monsym, mondata|
      mondata.each do |form, formdata|
        if newmons[monsym][form]
          deletes.each { |attribute| newmons[monsym][form].delete(attribute) }
          writes.each { |attribute| newmons[monsym][form][attribute] = formdata[attribute] if formdata[attribute] }
        end
      end

      inheritFormData(newmons[monsym])
      newhash[monsym] = MonWrapper.new(monsym, newmons[monsym])
    end
    monDump(newhash, game: game, file: "montext.rb")
  end
end

def ensureShadows(game = GAMEFOLDER)
  File.open("Scripts/#{game}/Definitions/montext.rb") { |f|
    eval(f.read)
  }
  mons = MONHASH
  newhash = MonDataHash.new()

  mons.each do |monsym, mondata|
    mondata.each do |form, formdata|
      next unless formdata[:ExcludeDex]
      next if formdata[:BattlerShadowSize]
      formdata[:BattlerShadowSize] = 18
    end

    inheritFormData(mondata)
    newhash[monsym] = MonWrapper.new(monsym, mondata)
  end
  monDump(newhash, game: game, file: "montext.rb")
end

def convertHallOfFame
  File.open("Scripts/ConversionClasses.rb") { |f| eval(f.read) }
  File.open(definition_file_path("montext.rb")) { |f| eval(f.read) }
  File.open(definition_file_path("movetext.rb")) { |f| eval(f.read) }
  File.open(definition_file_path("itemtext.rb")) { |f| eval(f.read) }
  File.open(definition_file_path("abiltext.rb")) { |f| eval(f.read) }

  $PokemonGlobal.hallOfFame.each { |entry|
    entry.each { |pkmn|
      pkmn = convertMon(pkmn) if pkmn.species.is_a?(Integer)
    }
  }
end

def compareDefinitions(file, name, ignore = [])
  hashes = {}
  File.open(definition_file_path(file + ".rb", game: "Reborn")) { |f| eval(f.read) }
  hashes[:reborn] = eval(name)
  File.open(definition_file_path(file + "_modern.rb", game: "Reborn")) { |f| eval(f.read) }
  hashes[:rebornGen9] = eval(name)
  File.open(definition_file_path(file + ".rb", game: "Rejuv")) { |f| eval(f.read) }
  hashes[:rejuvenation] = eval(name)
  File.open(definition_file_path(file + ".rb", game: "Desolation")) { |f| eval(f.read) }
  hashes[:desolation] = eval(name)
  keys = (hashes[:reborn].keys + hashes[:rebornGen9].keys + hashes[:rejuvenation].keys + hashes[:desolation].keys).uniq
  output = ""
  for key in keys
    definitions = {}
    hashes.each do |game, hash|
      definitions[game] = hash[key] unless hash[key].nil?
    end
    flags = []
    definitions.each do |key, value|
      flags += value.keys
    end
    flags.uniq!
    flags -= ignore
    differences = {}
    flags.each do |flag|
      values = {}
      definitions.each do |key, value|
        values[key] = value[flag]
      end
      next if values.values.uniq.length == 1
      differences[flag] = values
    end
    next if differences.empty?
    output += "Differences found for " + key.inspect + "\n"
    differences.each do |flag, values|
      output += flag.inspect + "\n"
      values.each do |key, value|
        output += "#{key}:#{" " * (12 - key.to_s.length)} #{value.inspect}" + "\n"
      end
    end
    output += "\n"
  end
  return output
end

def compareMoves
  output = compareDefinitions("movetext", "MOVEHASH", [:ID, :desc])
  File.write("diff_movetext.txt", output)
end

def compareItems
  output = compareDefinitions("itemtext", "ITEMHASH", [:ID, :tm, :price, :desc])
  File.write("diff_itemtext.txt", output)
end

def compareAbilities
  output = compareDefinitions("abiltext", "ABILHASH", [:ID, :desc, :fullDesc])
  File.write("diff_abiltext.txt", output)
end

def compareAll
  compareMoves
  compareItems
  compareAbilities
end

def genderSign(sym)
  return { M: "♂", F: "♀" }[sym]
end

def genderName(sym)
  return { M: _INTL("Male"), F: _INTL("Female") }[sym]
end

def genderColor(sym)
  return { M: :Blue2, F: :Red2 }[sym]
end

def limitedFileName(filename)
  # Too long file names can cause errors, so this acts as a hard check against them.
  # The lowest limit is that found on certain Linux distros that use the eCryptfs file
  # system, ie, 143 bytes, so we just apply the same for all platforms. If required,
  # this could be made to consider different limits based on platform too.
  filename.chop! while filename.bytesize > 143
  return filename
end

def resolveVideoFile(filename)
  filename += ".ogv" if !filename.include?(".")
  handle = filename.split(".")[-1]
  if handle != "ogv"
    dp(_INTL("Invalid file format. {1} must be a OGV.", filename))
    return nil
  end
  filename = "Graphics/Videos/" + filename if !File.exist?(filename)

  if !File.exist?(filename)
    dp(_INTL("Could not find file {1}.", filename))
    return nil
  end

  return filename
end

def playMovie(filename, skippable = true, volume: nil)
  filename = resolveVideoFile(filename)
  return if !filename

  if volume && $Settings.volume
    volume *= ($Settings.volume / 100.00)
  elsif !volume && $Settings.volume
    volume = $Settings.volume
  else
    volume = 100
  end
  if Graphics.class_variable_get(:@@opacity) > 0
    Graphics.class_variable_set(:@@opacity, 0)
    Graphics.update
  end
  unless $joiplay
    frameskip = Graphics.frameskip
    Graphics.frameskip = false
  end
  border = $ResizeBorder&.sprite.visible
  $ResizeBorder&.sprite.visible = false

  Graphics.play_movie(filename, volume, skippable)

  Graphics.frameskip = frameskip unless $joiplay
  $ResizeBorder&.sprite.visible = border
end

def getAllTeachableMoves
  compatibleMoves = []
  compatibleMoves += getAllTutorMoves
  compatibleMoves += getAllTMMoves
  compatibleMoves += getUniversalTMs()
  compatibleMoves.sort!
  File.write("teachableMoves.txt", compatibleMoves)
end

def checkCompatibleMoves
  compatibleMoves = []
  $cache.pkmn.each { |mon, wrapper|
    wrapper.pokemonData.each { |formName, data|
      compatibleMoves = compatibleMoves | data.compatiblemoves
    }
  }
  compatibleMoves -= getAllTutorMoves
  compatibleMoves -= getAllTMMoves
  compatibleMoves.each { |move|
    puts "Unplaced move: #{move}"
  }
end

#cass wants this.
def givemap
  print $game_map.map_id
end

# Softlock usually happens when there is an event trying to execute a move route which isn't possible and a "Wait for Move's Completion" command.
def debugSoftlock
  unless pbMapInterpreter.move_route_waiting
    puts "Not waiting for move route completion."
    return
  end

  if $game_player.move_route_forcing
    puts "Player move route."
  end

  for event in $game_map.events.values
    if event.move_route_forcing
      puts "Event #{event.id} move route (#{event.character_name})."
    end
  end

  $PokemonTemp.dependentEvents.realEvents.each do |event|
    if event.move_route_forcing
      puts "Dependent event #{event.id} move route (#{event.character_name})."
    end
  end
end

def loadSite(site)
  require 'timeout'

  Timeout::timeout(12) do
    begin
      System.launch(site)
      # This can be used on macOS if needed.
      # system("open", site)
      return true
    rescue
      return false
    end
  end
end

#############
# Game Window Mover - Haru
#
# SetWindowPos sets the window position based on:
#   l: window object (in C, HWND)
#   i: don't care put it as 0
#   i: x pos int
#   i: y pos int
#   i: width int
#   i: height int
#   p: don't care put it as zero (pointer)
# FindWindowEx gets the game window using GAME_TITLE (Defined in SystemConstants.rb for Reborn-Essentials games):
#   l: parent window object
#   l: child window object
#   p: class pointer
#   p: title pointer (pointers are typically packed 'l4' strings for MiniFFI/Win32API)
# AdjustWindowRectEx adjusts given rect bounds so MiniFFI/Win32API doesn't royally screw it up:
#   p: bounds to convert [left, top, right, bottom]
#   l: style long. don't change this unless you know the proper hex values
#   i: does the window have a menu? prolly not, leave as 0
#   p: extended window pointer. why is this not a long? why is the other not a pointer? don't touch it again.
# GetWindowRect gets the current window position"
#   l: window object
#   p: packed string to store data into
#
# (0,0) may not be top left corner depending on the monitor. Sucks.
#############
if Rejuv
  if System.platform[/Windows/]
    SetWindowPos        = Win32API.new 'user32', 'SetWindowPos', ['l', 'i', 'i', 'i', 'i', 'i', 'p'], 'i'
    FindWindowEx        = Win32API.new 'user32', 'FindWindowEx', ['l', 'l', 'p', 'p'], 'i'
    AdjustWindowRectEx  = Win32API.new 'user32', 'AdjustWindowRectEx', ['p', 'l', 'i', 'p'], 'i'
    GetWindowRect       = Win32API.new 'user32', 'GetWindowRect', ['l', 'p'], 'i'
  end
end

def moveWindow(x = 0, y = 0, forceNonWindows = false)
  return if $Settings.photosensitive == 1

  # Do not mess with window position when fullscreened
  # Do not mess with window position when maximized if Streamer Mode is enabled
  #   OBS does not handle this nicely and has different outputs depending on how your environment is set up -3-
  if !defined?(SetWindowPos) || forceNonWindows || Graphics.fullscreen || $Settings.streamermode == 1
    dir = x + y >= 0 ? :x : :y
    power = (x.abs + y.abs) / 4
    $game_screen.start_shake(power.clamp(5, 20), 10, 5, dir) #if !$game_screen.isShaking?
    return
  end
  window = FindWindowEx.call(0, 0, 0, GAME_TITLE)

  posStr = [0, 0, 0, 0].pack('l4') # empty
  GetWindowRect.call(window, posStr)
  pos = posStr.unpack('l4')
  # puts pos.inspect

  rect = [0, 0, pos[2] - pos[0] - 17, pos[3] - pos[1] - 40].pack('l4') # left, top, right, bottom
  style = 0x00CF0000 # WS_OVERLAPPEDWINDOW
  hasMenu = 0 # false
  styleEx = 0x00000200 # WS_EX_CLIENTEDGE
  AdjustWindowRectEx.call(rect, style, hasMenu, styleEx)
  newrect = rect.unpack('l4')
  # puts newrect.inspect


  SetWindowPos.call(window, 0, pos[0] + x, pos[1] + y, newrect[2] - newrect[0] - 3, newrect[3] - newrect[1] - 3, 0)
end

def shakeScreen1
  moveWindow(20, -20)
end

def shakeScreen2
  moveWindow(-20, 40)
end

def shakeScreen3
  moveWindow(30, -30)
end

def shakeScreen4
  moveWindow(-30, 10)
end

def shakeScreen5
  moveWindow(10, -5)
end

def shakeScreen6
  moveWindow(-10, 5)
end

def shakeScreen(forceNonWindows = false)
  if !defined?(SetWindowPos) || forceNonWindows || $Settings.streamermode == 1
    for i in 0...5
      $game_screen.start_shake(10, 10, 10, [:x, :y].sample)
      pbWait(20)
    end
  else
    # shakeScreen1
    # sleep(1.0 / 5.0)
    # shakeScreen2
    # sleep(1.0 / 5.0)
    # shakeScreen3
    # sleep(1.0 / 5.0)
    # shakeScreen4
    # sleep(1.0 / 5.0)
    # shakeScreen5
    # sleep(1.0 / 5.0)
    # shakeScreen6
    pbWait(30)
    shakeScreen1
    pbWait(10)
    shakeScreen2
    pbWait(10)
    shakeScreen3
    pbWait(10)
    shakeScreen4
    pbWait(10)
    shakeScreen5
    pbWait(10)
    shakeScreen6
  end
end

def checkAbilDescs
  $cache.abil.each { |abil, data|
    puts "#{abil},\n" if data.desc.length > 50
  }
end

def enforceTrainerType
  $cache.trainertypes.each { |sym, data|
    $Trainer.trainertype = sym if data.checkFlag?(:ID) == $Trainer.trainertype
  }
  $Trainer.trainertype = $cache.trainertypes.keys[0] if $Trainer.trainertype.is_a?(Integer)
end

def convertMapPos(pos) # REJUV
  return pos if !Rejuv
  return pos if pos[0] == 0 || pos[0] == 1
  return pos if pos[0] == 2 && pos[1] > 15

  pos[0] += 1
  return pos
end

def convertTownMap
  mapdat = $cache.town_map
  exporttext = "TOWNMAP={\n"
  for i in 0...mapdat.length
    region = mapdat[i]
    exporttext += "  #{i} => {\n"
    exporttext += "    :name => #{region[0].inspect},\n"
    exporttext += "    :filename => #{region[1].inspect},\n"
    exporttext += "    :points => {\n"
    if !region[2].nil?
      region[2].each { |arr|
        pos = [i, arr[0], arr[1]]
        pos = convertMapPos(pos) if Rejuv
        exporttext += "      [#{pos[1]}, #{pos[2]}] => {\n"
        exporttext += "        :name => \"#{arr[2]}\",\n"
        exporttext += "        :poi => #{arr[3].nil? ? "nil" : "\"#{arr[3]}\""},\n"
        exporttext += "        :flyData => ["
        exporttext += "#{arr[4]}, #{arr[5]}, #{arr[6]}" if arr[4]
        exporttext += "], # mapid, x, y\n"
        exporttext += "      },\n"
      }
    end
    exporttext += "    },\n"
    exporttext += "  },\n"
  end
  exporttext += "}\n"

  File.open(scripts_path + "/#{GAMEFOLDER}/townmap.rb", "w") { |f|
    f.write(exporttext)
  }
end

def fonttester(num = 22)
  str = "The quick brown fox jumps over the lazy dog."
  Kernel.pbMessage("\\gsc#{str}\n<fn=Garufan><fs=36>stupid</fs></fn> fox.\\egsc")
end

def thegif
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  spr = Sprite.new()
  spr.bitmap = Bitmap.new(".karma.gif")
  spr.viewport = viewport
  spr.bitmap.play
end

def theogv
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  spr = Sprite.new()
  Graphics.play_movie("out.ogv")
end

def fixShadowConversion
  File.open(scripts_path + "/#{GAMEFOLDER}/movetext.rb") { |f| eval(f.read) }
  for mon in $Trainer.party
    next if !mon.isShadow?

    fixShadowconvertMon(mon)
  end
  for box in 0...$PokemonStorage.maxBoxes
    for index in 0...$PokemonStorage[box].length
      mon = $PokemonStorage[box, index]
      next if !mon
      next if !mon.isShadow?

      fixShadowconvertMon(mon)
    end
  end
  if $PokemonGlobal.daycare[0][0] && $PokemonGlobal.daycare[0][0].isShadow?
    fixShadowconvertMon($PokemonGlobal.daycare[0][0])
  end
  if $PokemonGlobal.daycare[1][0] && $PokemonGlobal.daycare[1][0].isShadow?
    fixShadowconvertMon($PokemonGlobal.daycare[1][0])
  end
  remove_const(:MOVEHASH)
end

def fixShadowConvertMon(mon)
  if mon.shadowmoves
    newShadows = []
    for move in mon.shadowmoves
      if move == 0
        newShadows.push(0)
        next
      end
      for i in MOVEHASH.keys
        if MOVEHASH[i][:ID] == move
          newShadows.push(i)
          break
        end
      end
    end
    mon.shadowmoves = newShadows
  end
end

def massEditMons
  $gamefolder = "Reborn"
  cprint "Reading #{$gamefolder}/montext.rb..."
  File.open(scripts_path + "/#{$gamefolder}/montext.rb") { |f|
    eval(f.read)
  }
  cprint "done.\n"
  spacetoclear = 0
  mons = MonDataHash.new()
  MONHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    inheritFormData(value)
    mons[key] = MonWrapper.new(key, value)
  }
  cprint "Compiled data for #{$gamefolder}/mons.dat#{" " * spacetoclear}\n"
  monDump(mons, game: $gamefolder)

  $gamefolder = "Rejuv"
  cprint "Reading #{$gamefolder}/montext.rb..."
  File.open(scripts_path + "/#{$gamefolder}/montext.rb") { |f|
    eval(f.read)
  }
  cprint "done.\n"
  spacetoclear = 0
  mons = MonDataHash.new()
  MONHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    inheritFormData(value)
    mons[key] = MonWrapper.new(key, value)
  }
  cprint "Compiled data for #{$gamefolder}/mons.dat#{" " * spacetoclear}\n"
  monDump(mons, game: $gamefolder)

  $gamefolder = "Desolation"
  cprint "Reading #{$gamefolder}/montext.rb..."
  File.open(scripts_path + "/#{$gamefolder}/montext.rb") { |f|
    eval(f.read)
  }
  cprint "done.\n"
  spacetoclear = 0
  mons = MonDataHash.new()
  MONHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    inheritFormData(value)
    mons[key] = MonWrapper.new(key, value)
  }
  cprint "Compiled data for #{$gamefolder}/mons.dat#{" " * spacetoclear}\n"
  monDump(mons, game: $gamefolder)
end

def checkEvos
  levels = []
  bsts = []
  $cache.pkmn.each { |mon, wrapper|
    wrapper.pokemonData.each { |form, monData|
      next if !monData.evolutions
      next if monData.evolutions.empty?

      evo = monData.evolutions[0]
      next if ![:Level, :LevelDay, :LevelNight, :LevelDusk].include?(evo[:method])

      species = evo[:species]
      level = evo[:parameter]
      bst = $cache.pkmn[species, 0].BaseStats.sum
      levels.push(level)
      bsts.push(bst)
    }
  }
  puts levels
  puts "BREAK"
  puts bsts
end

def isValidForFont
  calls = caller_locations
  return false if calls.any? { |c| c.label && [
    "pbStartPokemonMenu"
  ].any? { |s| c.label.include?(s) }}
  return false if calls.any? { |c| c.path && [
    "Storage"
  ].any? { |s| c.path.include?(s) }}
  return false if !calls.any? { |c| c.path && [
    "PokemonTrainerCardSceneGBC", "Messages", "TextEntry", "Evolution", "Save"
  ].any? { |s| c.path.include?(s) }}
  return true
end

# re-classifying mixed form structures to a new uniform structure
def formReClass
  $cache.pkmn.each { |mon, wrapper|
    # check old data structure
    pulse = wrapper.checkFlag?(:PulseForm) # check if pulse is defined (reborn pulses)
    if pulse
      if pulse.is_a?(Hash)
        pulse.each { |formName, formNum|
          $cache.pkmn[mon, formName].flags.store(:Pulse, true)
        }
      else
        $cache.pkmn[mon, pulse].flags.store(:Pulse, true)
      end
    end
    primal = wrapper.checkFlag?(:PrimalForm) # check if primal is defined (groudon/kyogre)
    $cache.pkmn[mon, primal].flags.store(:Primal, true) if primal
    ultra = wrapper.checkFlag?(:UltraForm) # check if ultra is defined (necrozma)
    $cache.pkmn[mon, ultra].flags.store(:Ultra, true) if ultra

    # remove defunct data
    wrapper.flags.delete(:PrimalForm)
    wrapper.flags.delete(:UltraForm)
    wrapper.flags.delete(:PulseForm)

    # need to check individual forms
    wrapper.pokemonData.each { |formName, data|
      if formName == "Perfection" # check if form is perfection (deso)
        data.flags.store(:Perfection, true)
      end
      if formName.downcase.include?("pulse") # check if form is PULSE2 or Pulse+ (rejuv abra/musharna)
        data.flags.store(:Pulse, true)
      end
      if formName.include?("Rift") # check if form is rift (rejuv)
        data.flags.store(:Rift, true)
      end
      if formName.include?("Karma Beast") # check if form is a consequence of your actions (rejuv)
        data.flags.store(:Karma, true)
      end
      if data.MegaEvolutions && !data.MegaEvolutions.empty? # megas
        data.MegaEvolutions.each { |req, megaForm|
          $cache.pkmn[mon, megaForm].flags.store(:Mega, true)
        }
      end
      data.flags.store(:PrimalForm, 1) if [:GROUDON, :KYOGRE].include?(mon) && formName == "Normal Form"
      data.flags.store(:UltraForm, 3) if mon == :NECROZMA && ["Dawn Wings", "Dusk Mane"].include?(formName)
    }

  }
  monDump
end

class MapMetadata
  def collectEncountersForms
    enc = []
    @EncounterTypes.each { |enctype| enc += self.send(enctype).keys if self.send(enctype) }
    enc = enc.map { |v|
      next [v, 0] if v.is_a?(Symbol)
      species, form = v
      form = 0 if !form.is_a?(Numeric)
      next [species, form]
    }
    return enc.compact.uniq
  end
end

def exportdex
  export = {}
  $cache.mapdata.each { |map|
    next if !map
    next if !map.MapPosition
    regionnum = map.MapPosition[0]
    case regionnum
      when 0
        region = :Floria
      when 1
        region = :Terajuma
      when 2, 3, 4
        region = :Terrial
      else
        next
    end
    export[region] ||= []
    enc = map.collectEncountersForms
    next if !enc
    export[region] += enc
    export[region] = export[region].uniq
  }

  export.each { |region, mons|
    sorted = []
    for i in 0...mons.length
      next if sorted.include?(mons[i])
      baby = pbGetBabySpecies(*mons[i])
      ret = gatherEvolutions(*baby)
      ret = ret.map { |v|
        next [v, 0] if v.is_a?(Symbol)
        species, form = v
        form = 0 if !form.is_a?(Numeric)
        next [species, form]
      }
      sorted += ret
    end
    export[region] = sorted
  }

  export.each { |region, mons|
    out = region.to_s
    mons.each { |species, form|
      out += "\n#{species},#{form}"
    }
    Input.clipboard = out
    p "wait"
  }
end

def importdex
  region = :region
  strs = ""

  i = 1
  strs.split("\n").each { |s|
    st = s.strip
    next if st.empty?
    str, form = st.split(",")
    form = form ? form.to_i : 0
    sym = str.to_sym

    if $cache.pkmn[sym]
      mon = $cache.pkmn[sym, form]
      mon.flags[:regionalDex] ||= {}
      mon.flags[:regionalDex].delete(region)
      mon.flags[:regionalDex].store(region, i)
    else
      puts sym
    end
    i += 1
  }

  monDump
end

def checkBattlerSizes
  path = "Graphics/Battlers/"
  Dir.each_child(path) { |f|
    next if f.include?("000")
    next if f.include?("_") && !f.include?("_f")
    split = f.split(".")[0].split("_")
    dexnum = split[0].gsub(/[A-Za-z]/, "").to_i - 1
    form = split[1].to_i
    next if $cache.pkmn.values[dexnum][form].checkFlag?(:toobig)
    w = 384
    w = 128 if f.end_with?("Egg.png") || f == "egg.png" || f == "eggCracks.png" || f == "substitute.png"
    bmp = RPG::Cache.load_bitmap(path + f)
    puts "#{f}" if bmp.width < w

  }
end

def yoinkmon(args)
  return args
end

def yoinkintro
  map = load_data("Data/Map001.rxdata")
  event = map.events[1]
  trainers = {}
  for i in 1..3
    partyid = [0, 1708, 2184, 2186][i]
    page = event.pages[i]
    list = page.list
    index = 0
    grabTeam = true
    switch = :missing
    while index < list.length - 1
      if list[index].code == 111
        switch = Switches.invert[list[index].parameters[1]]
        if switch
          trainers[switch] ||= {}
          trainers[switch][partyid] ||= []
          grabTeam = true
        end
      end
      if list[index].code == 412
        trainers.delete(switch) if trainers.dig(switch)&.dig(partyid) == []
        switch = :missing
        grabTeam = false
      end
      if grabTeam
        if list[index].code == 355
          code = list[index].parameters[0]
          staticCode = code.dup
          scrIndex = index + 1
          while list[scrIndex].code == 655
            staticCode += "\n" + list[scrIndex].parameters[0]
            scrIndex += 1
          end
          string = staticCode.gsub("pbAddPokemonSilent(", "yoinkmon(")

          if string != staticCode
            poke = eval(string)
            trainers[switch][partyid].push(poke)
          end
        end
      end

      index += 1
    end
  end
  str = "  # SKIP PASSWORD PARTIES\n"
  trainers.each { |trainer, party|
    party.each { |id, team|
      text = ["Act 1 Skip", "Act 2 Skip", "Act 3 Skip"][party.keys.index(id)]
      str += "  {\n"
      str += "    :teamid => [#{trainer.to_s.inspect}, :TRAINER_#{trainer.to_s.upcase}, #{id}], # #{text}\n"
      str += "    :mons => [\n"
      team.each { |mon|
        text = "      " + mon.export.gsub("\n", "\n      ")
        str += text
        str += ",\n"
      }
      str += "    ],\n  },\n"
    }
  }
  str.gsub!("\n", "\n  ")
  str += "#######################"
  Input.clipboard = str
end

def cdex
  dexlist = {}
  region = :Terrial
  $cache.pkmn.each { |species, wrapper|
    wrapper.pokemonData.each { |form, monData|
      next if monData.flags[:ExcludeDex]
      form = wrapper.forms.invert[form] if form.is_a?(String) # Convert form name to form num (last seen form is stored as form num)
      next if !monData.checkFlag?(:regionalDex) || !monData.checkFlag?(:regionalDex)&.dig(region)
      name = getMonName(species, form)
      dexnum = getDisplayDexNum(monData, $cache.pokedexes.keys.index(region))
      dexlist.store(dexnum, [species, form])
    }
  }

  for i in 1..dexlist.length
    if !dexlist[i]
      p "break at #{i}"
      break
    end
  end
end

def splitforms
  root = "Graphics/Battlers/"
  children = Dir.children(root) - ["000.png", "battlers.png", "substitute.png", "substitute_b.png", "Egg.png", "eggCracks.png"]
  out = {}
  v = 0
  children.each { |file|
    next if File.directory?(root + file)
    s = file.split(".")[0]
    rDexnum = s[/\d+/]
    dexnum = rDexnum.to_i - 1
    species = $cache.pkmn.keys[dexnum]
    puts species

    form = 0
    gender = nil
    egg = false
    shiny = false
    back = false
    overworld = false
    shadow = false
    if rDexnum != s
      args, formOrGender = s.split(rDexnum)[1].split("_")

      gender = formOrGender if formOrGender == "f"
      form = formOrGender.to_i if formOrGender && formOrGender != "f"
      if args
        egg = args.include?("Egg")
        back = args.include?("b")
        shiny = args.include?("s")
        overworld = args.include?("o")
        shadow = args.include?("_shadow")
        gender = true if args.include?("f")
      end
    end


    oldPath = root + file
    newPath = root + species.to_s.downcase + "/"
    Dir.mkdir(newPath) if !Dir.exist?(newPath)
    out[newPath] ||= {}
    handle = "#{gender ? "f" : ""}#{overworld ? "o" : ""}#{egg ? "egg" : ""}#{shadow ? "_shadow" : ""}"

    bitmap = Bitmap.new(oldPath)
    width = bitmap.width
    height = bitmap.height

    if egg
      size = 128
      sheetCount = height / 64
      for i in 0...sheetCount
        f = i.to_s + handle

        out[newPath][f] = splitbmp(bitmap, i, size, egg: true)
      end
    elsif width % 384 != 0 || height % 384 != 0
      f = form.to_s + handle
      if out[newPath][f]&.is_a?(Bitmap)
        out[newPath][f] = [out[newPath][f]] + Array.new(3, Bitmap.new(192, 192))
      else
        out[newPath][f] ||= Array.new(4, Bitmap.new(192, 192))
      end
      i = shiny ? 2 : 0
      i += 1 if back
      out[newPath][f][i] = trimmedBitmap(Bitmap.new(oldPath))
    else
      size = 384
      sheetCount = height / size
      for i in 0...sheetCount
        f = i.to_s + handle

        out[newPath][f] = splitbmp(bitmap, i, size)
      end
    end

    File.delete(oldPath)
  }
  out.each { |path, forms|
    forms.each { |file, arr|
      if file.include?("egg")
        # size = 64
        # rect = Rect.new(0, 0, size, size)
        # outbmp = Bitmap.new(size * 2, size)

        # arr.map! { |bmp| changeCanvasSize(bmp, size) }

        # outbmp.blt(   0, 0, arr[0], rect)
        # outbmp.blt(size, 0, arr[1], rect)

        # outbmp.to_file(path + file + ".png")

        arr.to_file(path + file + ".png")
      else
        if arr.is_a?(Array)
          size = 192

          arr.each { |bmp|
            size = bmp.width if bmp.width > size
            size = bmp.height if bmp.height > size
          }

          rect = Rect.new(0, 0, size, size)
          outbmp = Bitmap.new(size * 2, size * 2)

          arr.map! { |bmp| changeCanvasSize(bmp, size) }

          outbmp.blt(   0,    0, arr[0], rect)
          outbmp.blt(   0, size, arr[1], rect)
          outbmp.blt(size,    0, arr[2], rect)
          outbmp.blt(size, size, arr[3], rect)

          outbmp.to_file(path + file + ".png")
        else
          arr.to_file(path + file + ".png")
        end
      end
    }
  }
end

def splitbmp(bitmap, form, size = 384, egg: false)
  arr = []
  spriteSize = size / 2
  height = egg ? spriteSize : size
  sheetRect = Rect.new(0, form * height, size, height)
  sheet = Bitmap.new(size, height).blt(0, 0, bitmap, sheetRect)

  # arr = []
  # arr.push(Bitmap.new(spriteSize, spriteSize).blt(0, 0, sheet, Rect.new(0, 0, spriteSize, spriteSize)))
  # arr.push(Bitmap.new(spriteSize, spriteSize).blt(0, 0, sheet, Rect.new(0, spriteSize, spriteSize, spriteSize))) unless egg
  # arr.push(Bitmap.new(spriteSize, spriteSize).blt(0, 0, sheet, Rect.new(spriteSize, 0, spriteSize, spriteSize)))
  # arr.push(Bitmap.new(spriteSize, spriteSize).blt(0, 0, sheet, Rect.new(spriteSize, spriteSize, spriteSize, spriteSize))) unless egg

  # arr.map! { |b| (trimmedBitmap(b) rescue b) } unless egg
  return sheet
end

def checkAlphaNumFiles(dir = Dir.pwd)
  $nonAlph ||= []
  output = dir == Dir.pwd
  dir = dir + "/" if !dir.end_with?("/")
  Dir.each_child(dir) { |c|
    next if c.start_with?(".") || c == "gems" || c == "stdlib"
    path = dir + c
    puts path
    if File.directory?(path)
      checkAlphaNumFiles(path)
    else
      $nonAlph.push(path) if path.match?(/[^\x00-\x7F]/)
    end
  }
  if output
    puts "-----------------------------"
    puts $nonAlph
  end
end

def fixTrainerUTF
  text = nil
  File.open(definition_file_path("trainertext.rb"), 'rb') { |f| text = f.read() }
  text.gsub!(/\\x([0-9A-F]{2})/) { |match|
    hex = [$1.to_i(16)].pack("C")
    next hex
  }
  File.open(definition_file_path("trainertext.rb"), 'wb') { |f| f.write(text) }
end

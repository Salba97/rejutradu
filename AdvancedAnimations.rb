# Advanced Animation Sheets
#
# An expansion on the regular 4x4 animation sheet RMXP supports.
# Supports any size of animation.
# Animations can either be defined cache (see below) OR be defined in a PNG file itself in a `tEXt` property.
# Animations are ALWAYS taken from cache if they are defined.
# If you lack the tools to add `tEXt`` data to a PNG, look at the methods below:
#   `writeAnimDataToFile`
#   `getAnimDataFromFile`
#
# Defined in Definitions/animsheettext.rb
#   Keys are filepaths
#   Values:
#     frameSize   : Dimensions of the size of the animation
#     frameData   : Frame count of each animation frame
#     useRMXPDirs : Whether the animation uses the RMXP sheet format or an alternative format
#                   Default: True when animation height is <= 4, false otherwise
#                   RMXP Style:
#                     2: Down
#                     4: Left
#                     6: Right
#                     8: Up
#                   Our Style:
#                     1: Down
#                     2: Down-Right
#                     3: Right
#                     4: Up-Right
#                     5: Up
#                     6: Up-Left
#                     7: Left
#                     8: Down-Left

class Sprite_Character
  unless @advancedAnimAliases
    alias advancedAnim_update update
    alias advancedAnim_rect getRect
    @advancedAnimAliases = true
  end

  def update
    advancedAnim_update
    return unless @character.advancedAnim

    if @character.advancedAnim&.needsUpdate
      i = $scene.spriteset.instance_variable_get(:@character_sprites).key(self)
      $scene.spriteset.instance_variable_get(:@character_sprites_bounds)[i] = self.getRect
    end
    advancedAnim = @character.advancedAnim
    # puts @character_name
    # puts self.src_rect.inspect
    # puts "========="

    frameSize = advancedAnim.frameSize
    frameCountX = advancedAnim.frameCountX
    frameCountY = advancedAnim.frameCountY
    useRMXPDirs = advancedAnim.useRMXPDirs

    @cw = @charbitmap.width / frameCountX
    self.ox = (@cw / 2).to_grid

    @ch = @charbitmap.height / frameCountY
    self.oy = @ch.to_grid
    self.oy -= 16 if @character_name[/offset/]
    sx = advancedAnim.pattern * @cw
    if useRMXPDirs
      sy = (@character.direction - 2) / 2 * @ch
    else
      sy = @character.direction * @ch
    end
    self.src_rect.set(sx, sy, @cw, @ch)

    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)

  end

  def getRect
    rect = advancedAnim_rect
    return rect if rect == Rect.new(0, 0, 0, 0)
    filepath = "Graphics/Characters/" + @character.character_name
    animdata = $cache.animSheets[filepath]
    animdata ||= getAnimDataFromFile(filepath)
    if animdata
      @character.advancedAnim = AdvancedAnimation.new
      @character.advancedAnim.init(@character.character_name, animdata)
    else
      @character.advancedAnim = nil
    end
    return rect unless @character.advancedAnim
    advancedAnim = @character.advancedAnim
    frameSize = advancedAnim.frameSize
    frameData = advancedAnim.frameData
    frameCountX = advancedAnim.frameCountX
    frameCountY = advancedAnim.frameCountY

    charbitmap = AnimatedBitmap.new(filepath, @character.character_hue)
    if !frameCountX
      frameCountX = charbitmap.width / frameSize[0]
      advancedAnim.frameCountX = frameCountX
    end
    if !frameCountY
      frameCountY = charbitmap.height / frameSize[1]
      advancedAnim.frameCountY = frameCountY
    end

    useRMXPDirs = advancedAnim.useRMXPDirs

    cw = charbitmap.width / frameCountX
    ch = charbitmap.height / frameCountY
    sx = advancedAnim.pattern * cw
    if useRMXPDirs
      sy = (@character.direction - 2) / 2 * ch
    else
      sy = @character.direction * ch
    end

    r = Rect.new(sx, sy, cw, ch)
    @character.advancedAnim.needsUpdate = false
    return r
  end
end

class Game_Character
  unless @advancedAnimAliases
    alias advancedAnim_updateOther updateOther
    alias advancedAnim_evalMove eval_move_code
    alias advancedAnim_updateMove update_move
    alias advancedAnim_updateStop update_stop
    alias advancedAnim_changeGraphic changeGraphic
    @advancedAnimAliases = true
  end

  attr_accessor :advancedAnim

  def updateOther(*args)
    advancedAnim_updateOther(*args)
    if self != $game_player || !$PokemonGlobal.fishing
      return if @lock_pattern || !@advancedAnim || @advancedAnim.needsUpdate

      if @advancedAnim.ready
        @advancedAnim.anime_count = @advancedAnim.frameData[@advancedAnim.pattern] if !@step_anime && @stop_count > 0
        if @advancedAnim.anime_count > @advancedAnim.frameData[@advancedAnim.pattern]
          if !@step_anime && @stop_count > 0
            @advancedAnim.pattern = @original_pattern
          else
            @advancedAnim.pattern = (@advancedAnim.pattern + 1) % @advancedAnim.frameCountX
          end
          @advancedAnim.anime_count = 0
        end
      end
    end
  end

  def update_move
    advancedAnim_updateMove
    return unless @advancedAnim&.ready
    if @walk_anime
      @advancedAnim.anime_count += 1.5
    elsif @step_anime
      @advancedAnim.anime_count += 1
    end
  end

  def update_stop
    advancedAnim_updateStop
    return unless @advancedAnim&.ready
    if @step_anime
      @advancedAnim.anime_count += 1
    elsif @advancedAnim.pattern != @original_pattern
      @advancedAnim.pattern = @original_pattern
      @advancedAnim.anime_count = 0
    end
  end

  def changeGraphic(*args)
    @advancedAnim.needsUpdate = true if @advancedAnim
    advancedAnim_changeGraphic(*args)
  end
end

class AdvancedAnimation
  attr_accessor :frameCountX
  attr_accessor :frameCountY
  attr_accessor :frameSize
  attr_accessor :frameData
  attr_accessor :pattern
  attr_accessor :anime_count
  attr_accessor :needsUpdate
  attr_accessor :useRMXPDirs

  def initialize
    @pattern = 0
    @anime_count = 0
  end

  def init(name, data)
    @name = name
    @frameSize = data[:frameSize]
    @frameData = data[:frameData]
    @useRMXPDirs = data[:useRMXPDirs] || true
    @needsUpdate = false
  end

  def ready
    return @frameCountX && @frameCountY && @frameSize && @frameData
  end
end

  # Chunk Types
  #   "IHDR" => Header
  #   "IDAT" => ImageData
  #   "PLTE" => Palette
  #   "tRNS" => Transparency
  #   "tEXt" => Text
  #   "zTXt" => CompressedText
  #   "iTXt" => InternationalText
  #   "pHYs" => Physical
  #   "IEND" => End
def writeAnimDataToFile(file, temppath = "tempfile.png", frameSize: nil, frameData: nil)
  return if !frameSize && !frameData # What are we doing then??

  file = pbResolveBitmap(file)
  return nil if !file

  temppath = pbResolveBitmap(temppath)
  notAPNG = false

  File.open(temppath, 'wb') { |out|
    File.open(file, 'rb') { |f|
    header = f.read(8).b
    pngheader = "\x89PNG\r\n\x1a\n".b
      if header != pngheader # Not a png, get out of here
        notAPNG = true
        break
      end

      out.write(header)
      out.write(f.read(4)) # length
      out.write(f.read(4)) # IHDR
      out.write(f.read(13)) # width/height/etc, NNC4 unpack if needed
      out.write(f.read(4)) # crc

      # Write our data into the file
      writeChunk(out, "frameSize", frameSize)
      writeChunk(out, "frameData", frameData)

      loop {
        length = f.read(4)
        type = f.read(4)
        data = f.read(length.unpack1("N"))
        crc = f.read(4)

        if type == "tEXt" # Overwrite/skip existing data
          key, value = data.split("\x00")

          next if key == "frameSize"
          next if key == "frameData"
        end

        out.write(length)
        out.write(type)
        out.write(data)
        out.write(crc)

        break if type == "IEND"
      }
    }
  }

  return if notAPNG

  require 'fileutils' # ensure fileutils is actually loaded
  FileUtils.mv(temppath, file) # move the created temp file to the new image loc
end

def writeChunk(io, title, i)
  data = title + "\0" + i.to_s # \x00 or \0 is a required split point in basically every tEXt implementation.
  crc = Zlib::crc32("tEXt" + data)

  io.write([data.bytesize].pack("N"))
  io.write("tEXt")
  io.write(data)
  io.write([crc].pack("N"))

  return io
end

def getAnimDataFromFile(file)
  file = pbResolveBitmap(file)
  file = "patch/" + file if file && safeExists?("patch/" + file)
  return nil if !file

  frameSize = nil
  frameData = nil

  begin
    File.open(file, 'rb') { |f|
      header = f.read(8).b
      pngheader = "\x89PNG\r\n\x1a\n".b

      break if header != pngheader # Not a PNG, get out of here

      loop {
        length = f.read(4).unpack1("N")
        type = f.read(4)
        data = f.read(length)
        crc = f.read(4)

        if type == "tEXt"
          key, value = data.split("\x00")

          frameSize = eval(value) if key == "frameSize"
          frameData = eval(value) if key == "frameData"
        end

        # We've either hit EOF or found the data we need
        break if type == "IEND" || (frameSize && frameData)
      }
    }
  rescue
    puts "File '#{file}' could not be read: #{$!.message}"
    return nil
  end

  return nil if !frameSize && !frameData
  return { frameSize: frameSize, frameData: frameData }
end

# When down/up/left/right rects are supplied, it will use those to format the updated spritesheet instead
# Otherwise, it will assume this format:
#    1: Down
#    2: Down-Right
#    3: Right
#    4: Up-Right
#    5: Up
#    6: Up-Left
#    7: Left
#    8: Down-Left
def convertAnimSheet(path, animHeight = 1, down: nil, left: nil, right: nil, up: nil)
  file = pbResolveBitmap(path)
  if !file
    path = "Graphics/Characters/#{path}" if !path.include?("/")
    path += ".png" if !path.end_with?(".png")
    file = pbResolveBitmap(path)
  end
  return nil if !file

  rectDefs = [down, left, right, up].compact
  return nil if !rectDefs.empty? && rectDefs.length != 4

  bmp = Bitmap.new(file)
  width = bmp.width
  height = bmp.height
  out = Bitmap.new(width, animHeight * 4)

  if rectDefs.empty?
    rect = Rect.new(0, 0, width, animHeight)
    out.blt(0, 0, bmp, rect)

    rect = Rect.new(0, animHeight * 2, width, animHeight)
    out.blt(0, animHeight * 2, bmp, rect)

    rect = Rect.new(0, animHeight * 4, width, animHeight)
    out.blt(0, animHeight * 3, bmp, rect)

    rect = Rect.new(0, animHeight * 6, width, animHeight)
    out.blt(0, animHeight, bmp, rect)
  else
    rectDefs.each_with_index { |rect, i|
      out.blt(0, animHeight * i, bmp, rect)
    }
  end

  out.to_file(path)
end

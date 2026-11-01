module TextPlaceholders
  # Private Use Areas:
  #   UE000 -   UF8FF
  #  UF0000 -  UFFFFD
  # U100000 - U10FFFD

  InputPause        = "\ue000" # Equivalent to \1, pause until user input
  TimedPause        = "\ue001" # Equivalent to \2, pause for set time determined by scripts
  Image             = "\ue002" # Image substitution character
  ShakingTextStart  = "\ue003"
  ShakingTextStop   = "\ue004"

  def self.include?(char)
    return self.constants.any? { |const|
      self.const_get(const) == char
    }
  end

  def self.removeFrom(text)
    ret = text.dup
    self.constants.each { |const|
      ret.gsub!(self.const_get(const), "")
    }
    return ret
  end

  def self.hasNoWidth?(char)
    return (self.constants - [:Image]).any? { |const|
      self.const_get(const) == char
    }
  end
end

def getLineBrokenChunks(bitmap, value, width, dims, plain = false, lineheight = 32)
  x = 0
  y = 0
  textheight = 0
  ret = []
  if dims
    dims[0] = 0
    dims[1] = 0
  end
  re = /<c=([^>]+)>/
  reNoMatch = /<c=[^>]+>/
  return ret if !bitmap || bitmap.disposed? || width <= 0

  textmsg = value.clone
  lines = 0
  color = Font.default_color
  while (c = textmsg.slice!(/\n|\S*\-+|(\S*([ \r\t\f]?))/)) != nil
    break if c == ""

    ccheck = c
    if ccheck == "\n"
      x = 0
      y += (textheight == 0) ? bitmap.text_size("X").height : textheight
      textheight = 0
      next
    end
    if ccheck[/</] && !plain
      textcols = []
      ccheck.scan(re) { textcols.push(rgbToColor($1)) }
      words = ccheck.split(reNoMatch) # must have no matches because split can include match
    else
      textcols = []
      words = [ccheck]
    end
    for i in 0...words.length
      word = words[i]
      if word && word != ""
        # Strip trailing whitespace - spaces can overflow the textbox since they're blank.
        # This is so that they don't count towards the width of the line.
        textwidth_with_space = bitmap.text_size(word).width
        textwidth_without_space = bitmap.text_size(word.rstrip).width
        # If the spaces don't end up stripped, we do need the width to include the spaces, otherwise text becomes blurry.
        textwidth = textwidth_with_space
        break_after = false
        if x > 0 && x + textwidth_without_space > width
          # The word would overflow the text box, put it on the next line instead.
          x = 0
          y += lineheight # (textheight==0) ? bitmap.text_size("X").height : textheight
          # textheight=0
        elsif x > 0 && x + textwidth_with_space > width
          # The word itself doesn't overflow the textbox but the whitespace afterwards would, strip the whitespace.
          word = word.rstrip
          textwidth = textwidth_without_space
          break_after = true
        end
        textheight = 32 # [textheight,bitmap.text_size(word).height].max
        ret.push([word, x, y, textwidth, textheight, color])
        x += textwidth
        dims[0] = x if dims && dims[0] < x
        if break_after
          # This fixes a mostly theoretical issue with characters narrower than the space character.
          # Otherwise it's possible that a word of one such character (possibly "I") would be attached to the previous line without a space.
          x = 0
          y += lineheight
        end
      end
      if textcols[i]
        color = textcols[i]
      end
    end
  end
  dims[1] = y + textheight if dims
  return ret
end

def renderLineBrokenChunks(bitmap, xDst, yDst, normtext, maxheight = 0)
  for i in 0...normtext.length
    width = normtext[i][3]
    textx = normtext[i][1] + xDst
    texty = normtext[i][2] + yDst
    if maxheight == 0 || normtext[i][2] < maxheight
      bitmap.font.color = normtext[i][5]
      bitmap.draw_text(textx, texty, width + 2, normtext[i][4], normtext[i][0])
    end
  end
end

def renderLineBrokenChunksWithShadow(bitmap, xDst, yDst, normtext, maxheight, baseColor, shadowColor)
  for i in 0...normtext.length
    width = normtext[i][3]
    textx = normtext[i][1] + xDst
    texty = normtext[i][2] + yDst
    if maxheight == 0 || normtext[i][2] < maxheight
      height = normtext[i][4]
      text = normtext[i][0]
      if shadowColor
        bitmap.font.color = shadowColor
        bitmap.draw_text(textx + 2, texty, width + 2, height, text)
        bitmap.draw_text(textx, texty + 2, width + 2, height, text)
        bitmap.draw_text(textx + 2, texty + 2, width + 2, height, text)
      end
      bitmap.font.color = baseColor
      bitmap.draw_text(textx, texty, width + 2, height, text)
    end
  end
end

def ctag(color)
  ret = (color.red.to_i << 24)
  ret |= ((color.green.to_i) << 16)
  ret |= ((color.blue.to_i) << 8)
  ret |= ((color.alpha.to_i))
  return sprintf("<c=%08X>", ret)
end

def shadowctag(base, shadow)
  return sprintf("<c2=%s%s>", colorToRgb16(base), colorToRgb16(shadow))
end

def shadowc3tag(base, shadow)
  return sprintf("<c3=%s,%s>", colorToRgb32(base), colorToRgb32(shadow))
end

def shadowctagFromColor(color)
  return shadowc3tag(color, getContrastColor(color))
end

def shadowctagFromRgb(param)
  return shadowctagFromColor(rgbToColor(param))
end

def colorToRgb32(color)
  return "" if !color
  if color.alpha.to_i == 255
    return sprintf("%02X%02X%02X", color.red.to_i, color.green.to_i, color.blue.to_i)
  else
    return sprintf("%02X%02X%02X%02X", color.red.to_i, color.green.to_i, color.blue.to_i, color.alpha.to_i)
  end
end

def colorToRgb16(color)
  ret = (color.red.to_i >> 3)
  ret |= ((color.green.to_i >> 3) << 5)
  ret |= ((color.blue.to_i >> 3) << 10)
  return sprintf("%04X", ret)
end

def rgbToColor(param)
  return Font.default_color if !param

  baseint = param.to_i(16)
  if param.length == 8 # 32-bit hex
    return Color.new(
      (baseint >> 24) & 0xFF,
      (baseint >> 16) & 0xFF,
      (baseint >> 8) & 0xFF,
      (baseint) & 0xFF
    )
  elsif param.length == 6 # 24-bit hex
    return Color.new(
      (baseint >> 16) & 0xFF,
      (baseint >> 8) & 0xFF,
      (baseint) & 0xFF
    )
  elsif param.length == 4 # 16-bit hex
    return Color.new(
      ((baseint) & 0x1F) << 3,
      ((baseint >> 5) & 0x1F) << 3,
      ((baseint >> 10) & 0x1F) << 3
    )
  elsif param.length == 1 # Color number
    i = param.to_i
    return Font.default_color if i >= 8

    return [
      Color.new(255, 255, 255, 255),
      Color.new(128, 128, 255, 255),
      Color.new(255, 128, 128, 255),
      Color.new(128, 255, 128, 255),
      Color.new(128, 255, 255, 255),
      Color.new(255, 128, 255, 255),
      Color.new(255, 255, 128, 255),
      Color.new(192, 192, 192, 255)
    ][i]
  else
    return Font.default_color
  end
end

def Rgb16ToColor(param)
  baseint = param.to_i(16)
  return Color.new(
    ((baseint) & 0x1F) << 3,
    ((baseint >> 5) & 0x1F) << 3,
    ((baseint >> 10) & 0x1F) << 3
  )
end

def getContrastColor(color)
  raise "No color given" if !color

  r = color.red; g = color.green; b = color.blue
  yuv = [
    r * 0.299 + g * 0.587 + b * 0.114,
    r * -0.1687 + g * -0.3313 + b * 0.500 + 0.5,
    r * 0.500 + g * -0.4187 + b * -0.0813 + 0.5
  ]
  if yuv[0] < 127.5
    yuv[0] += (255 - yuv[0]) / 2
  else
    yuv[0] = yuv[0] / 2
  end
  return Color.new(
    yuv[0] + 1.4075 * (yuv[2] - 0.5),
    yuv[0] - 0.3455 * (yuv[1] - 0.5) - 0.7169 * (yuv[2] - 0.5),
    yuv[0] + 1.7790 * (yuv[1] - 0.5),
    color.alpha
  )
end

def getAutoShadowColor(baseColor)
  shadow = 1.0 / 4.0
  return Color.new(
    baseColor.red * shadow,
    baseColor.green * shadow,
    baseColor.blue * shadow,
    baseColor.alpha,
  )
end

def getLastParam(array, default)
  i = array.length - 1
  while i >= 0
    return array[i] if array[i]

    i -= 1
  end
  return default
end

def isWaitChar(x)
  return ["\001", "\002", TextPlaceholders::InputPause, TextPlaceholders::TimedPause].include?(x)
end

def hasNoWidth?(x)
  return isWaitChar(x) || TextPlaceholders.hasNoWidth?(x)
end

def getFormattedTextForDims(bitmap, xDst, yDst, widthDst, heightDst, text, lineheight, newlineBreaks = true, explicitBreaksOnly = false)
  text2 = text.gsub(/<(\/?)([Cc]|[Cc][2]|[Cc][3]|[Gg][Rr]|[Oo]|[Uu]|[Ss])(\s*\=\s*([^>]*))?>/, "")
  if newlineBreaks
    text2.gsub!(/<(\/?)([Bb][Rr])(\s*\=\s*([^>]*))?>/, "\n")
  end
  return getFormattedText(
    bitmap, xDst, yDst, widthDst, heightDst,
    text2, lineheight, newlineBreaks,
    explicitBreaksOnly, true
  )
end

def getFormattedTextFast(bitmap, xDst, yDst, widthDst, heightDst, text, lineheight, newlineBreaks = true, explicitBreaksOnly = false)
  numchars = 0
  x = y = 0
  characters = []
  charactersInternal = []
  textchunks = []
  controls = []
  charsonline = 0
  textchunks.push(text)
  text = textchunks.join("")
  textchars = text.scan(/./m)
  lastword = [0, 0] # position of last word
  hadspace = false
  hadnonspace = false
  bold = bitmap.font.bold
  italic = bitmap.font.italic
  colorclone = bitmap.font.color
  defaultfontname = bitmap.font.name
  if defaultfontname.is_a?(Array)
    defaultfontname = defaultfontname.find { |i| Font.exist?(i) } || "Arial"
  elsif !Font.exist?(defaultfontname)
    defaultfontname = "Arial"
  end
  defaultfontname = defaultfontname.clone
  defaultfontsize = bitmap.font.size
  havenl = false
  position = 0
  while position < textchars.length
    yStart = 0
    xStart = 0
    width = hasNoWidth?(textchars[position]) ? 0 : bitmap.text_size(textchars[position]).width
    if textchars[position] == "\n"
      if newlineBreaks # treat newline as break
        if true
          havenl = true
          characters.push(["\n", x, y * lineheight + yDst, 0, lineheight, false, false, false, colorclone, nil, false, false, "", defaultfontsize, position, nil, 0])
          y += 1
          x = 0
        end
        hadspace = true
        hadnonspace = false
        position += 1
        next
      else # treat newline as space
        textchars[position] = " "
      end
    end
    isspace = (textchars[position][/\s/] || hasNoWidth?(textchars[position])) ? true : false
    if hadspace && !isspace
      # set last word to here
      lastword[0] = characters.length
      lastword[1] = x
      hadspace = false
      hadnonspace = true
    elsif isspace
      hadspace = true
    end
    textx = x + xStart # independent of xDst
    texty = (lineheight * y) + yDst + yStart
    oldx = x
    # Push character, textx will be calculated later
    if heightDst < 0 || yStart < yDst + heightDst
      havenl = true if hasNoWidth?(textchars[position])
      characters.push(
        [
          textchars[position],
          x + xStart, texty + yStart, width + 2, lineheight,
          false, bold, italic, colorclone, nil, false, false,
          defaultfontname, defaultfontsize, position, nil, 0
        ]
      )
    end
    x += width
    if !explicitBreaksOnly && x + 2 > widthDst && lastword[1] != 0 &&
       (!hadnonspace || !hadspace)
      havenl = true
      characters.insert(
        lastword[0],
        ["\n", x, y * lineheight + yDst, 0, lineheight, false, false, false, colorclone, nil, false, false, "", defaultfontsize, position]
      )
      lastword[0] += 1
      y += 1
      x = 0
      for i in lastword[0]...characters.length
        characters[i][2] += lineheight
        charwidth = characters[i][3] - 2
        characters[i][1] = x
        x += charwidth
      end
      lastword[1] = 0
    end
    position += 1
  end
  # Eliminate spaces before newlines and pause character
  if havenl
    firstspace = -1
    for i in 0...characters.length
      if characters[i][5] # If not a character
        firstspace = -1
      elsif (characters[i][0] == "\n" || hasNoWidth?(characters[i][0])) &&
            firstspace >= 0
        for j in firstspace...i
          characters[j] = nil
        end
        firstspace = -1
      elsif characters[i][0][/[ \r\t]/]
        if firstspace < 0
          firstspace = i
        end
      else
        firstspace = -1
      end
    end
    if firstspace > 0
      for j in firstspace...characters.length
        characters[j] = nil
      end
    end
    characters.compact!
  end
  for i in 0...characters.length
    characters[i][1] = xDst + characters[i][1]
  end
  # Remove all characters with Y greater or equal to _yDst_+_heightDst_
  if heightDst >= 0
    for i in 0...characters.length
      if characters[i][2] >= yDst + heightDst
        characters[i] = nil
      end
    end
    characters.compact!
  end
  return characters
end

def getLastColors(colorstack, opacitystack, defaultcolors)
  colors = getLastParam(colorstack, defaultcolors)
  opacity = getLastParam(opacitystack, 255)
  if opacity != 255
    colors = [
      Color.new(colors[0].red, colors[0].green, colors[0].blue, colors[0].alpha * opacity / 255),
      colors[1] ? Color.new(colors[1].red, colors[1].green, colors[1].blue, colors[1].alpha * opacity / 255) : nil
    ]
  end
  return colors
end



=begin
Formats a string of text and returns an array containing a list
of formatted characters.

Parameters:
bitmap:         Source bitmap.  Will be used to determine the default font of
                the text.
xDst:           X coordinate of the text's top left corner.
yDst:           Y coordinate of the text's top left corner.
widthDst:       Width of the text.  Used to determine line breaks.
heightDst:      Height of the text.  If -1, there is no height restriction. If
                1 or greater, any characters exceeding the height are removed
                from the returned list.
newLineBreaks:  If true, newline characters will be treated as line breaks. The
                default is true.

Return Values:
A list of formatted characters.  Returns an empty array if _bitmap_ is nil
or disposed, or if _widthDst_ is 0 or less or _heightDst_ is 0.

Formatting Specification:
This function uses the following syntax when formatting the text.
<b> ... </b> - Formats the text in bold.
<i> ... </i> - Formats the text in italics.
<u> ... </u> - Underlines the text.
<s> ... </s> - Draws a strikeout line over the text.
<al> ... </al> - Left-aligns the text.  Causes line breaks before and
   after the text.
<r> - Right-aligns the text until the next line break.
<ar> ... </ar> - Right-aligns the text.  Causes line breaks before and
   after the text.
<ac> ... </ac> - Centers the text.  Causes line breaks before and
   after the text.
<br> - Causes a line break.
<c=X> ... </c> - Color specification.  A total of four formats are supported:
   RRGGBBAA, RRGGBB, 16-bit RGB, and Window_Base color numbers.
<c2=X> ... </c2> - Color specification where the first half is the base color and
   the second half is the shadow color.  16-bit RGB is supported.
Added 2009-10-20
<c3=B,S> ... </c3> - Color specification where B is the base color and
   S is the shadow color.   B and/or S can be omitted. A total of four formats are supported:
   RRGGBBAA, RRGGBB, 16-bit RGB, and Window_Base color numbers.
Added 2009-9-12
<o=X> - Displays the text in the given opacity (0-255)
Added 2009-10-19
<outln> - Displays the text in outline format.
Added 2010-05-12
<outln2> - Displays the text in outline format (outlines more exaggerated.
<fn=X> ... </fn> - Formats the text in the specified font, or Arial
   if the font doesn't exist.
<fs=X> ... </fs> - Changes the font size to X.
<icon=X> - Displays the icon X (in Graphics/Icons/).
In addition, the syntax supports the following:
&apos; - Converted to "'".
&lt; - Converted to "<".
&gt; - Converted to ">".
&amp; - Converted to "&".
&quot; - Converted to double quotation mark.

To draw the characters, pass the returned array to the
_drawFormattedChars_ function.
=end

def getFormattedText(
    bitmap, xDst, yDst, widthDst, heightDst, text, lineheight = 32,
    newlineBreaks = true, explicitBreaksOnly = false,
    collapseAlignments = false
  )
  dummybitmap = nil
  if !bitmap || bitmap.disposed? # allows function to be called with nil bitmap
    dummybitmap = Bitmap.new(1, 1)
    bitmap = dummybitmap
    return
  end
  if !bitmap || bitmap.disposed? || widthDst <= 0 || heightDst == 0 || text.length == 0
    return []
  end

  textchunks = []
  controls = []
  images = []
  text = text.gsub(/,tts=\"(\w*\s*)*\"/, "") # Remove tts tags and text
  oldtext = text
  while text[FORMATREGEXP]
    if ["icon", "img"].include?($~[2].downcase)
      # We want to catch image controls but actually parse them as single characters, so bypass real control handling.
      text = $~.pre_match + TextPlaceholders::Image + $~.post_match
      images.push([$~[2].downcase, $~[4], $~[1] == "/" ? true : false])
    else
      textchunks.push($~.pre_match)
      if $~[3]
        controls.push([$~[2].downcase, $~[4], -1, $~[1] == "/" ? true : false])
      else
        controls.push([$~[2].downcase, "", -1, $~[1] == "/" ? true : false])
      end
      text = $~.post_match
    end
  end
  if controls.length == 0 && images.length == 0
    ret = getFormattedTextFast(bitmap, xDst, yDst, widthDst, heightDst, text, lineheight, newlineBreaks, explicitBreaksOnly)
    dummybitmap.dispose if dummybitmap
    return ret
  end
  numchars = 0
  x = y = 0
  characters = []
  charactersInternal = []
  charsonline = 0
  realtext = nil
  realtextStart = ""
  if !explicitBreaksOnly && textchunks.join("").length == 0
    # All commands occurred at the beginning of the text string
    realtext = newlineBreaks ? text : text.gsub(/\n/, " ")
    realtextStart = oldtext[0, oldtext.length - realtext.length]
    realtextHalf = text.length / 2
  end
  textchunks.push(text)
  for chunk in textchunks
    chunk.gsub!(/&lt;/, "<")
    chunk.gsub!(/&gt;/, ">")
    chunk.gsub!(/&apos;/, "'")
    chunk.gsub!(/&quot;/, "\"")
    chunk.gsub!(/&amp;/, "&")
  end
  textlen = 0
  for i in 0...controls.length
    textlen += textchunks[i].scan(/./m).length
    controls[i][2] = textlen
  end
  text = textchunks.join("")
  textchars = text.scan(/./m)
  colorstack = []
  gradientstack = []
  boldcount = 0
  italiccount = 0
  outlinecount = 0
  underlinecount = 0
  strikecount = 0
  rightalign = 0
  outline2count = 0
  opacitystack = []
  oldfont = bitmap.font.clone
  defaultfontname = bitmap.font.name
  defaultfontsize = bitmap.font.size
  fontsize = defaultfontsize
  fontnamestack = []
  fontsizestack = []
  lineheightstack = []
  defaultcolors = [oldfont.color.clone, nil]
  defaultgradient = [oldfont.color.clone, oldfont.color.clone]
  if defaultfontname.is_a?(Array)
    defaultfontname = defaultfontname.find { |i| Font.exist?(i) } || "Arial"
  elsif !Font.exist?(defaultfontname)
    defaultfontname = "Arial"
  end
  defaultfontname = defaultfontname.clone
  fontname = defaultfontname
  defaultlineheight = lineheight
  defaultheight = yDst
  alignstack = []
  lastword = [0, 0] # position of last word
  hadspace = false
  hadnonspace = false
  havenl = false
  position = 0
  while position < textchars.length
    nextline = 0
    graphic = nil
    graphicX = 0
    graphicY = 0
    graphicWidth = nil
    graphicHeight = nil
    graphicRect = nil
    for i in 0...controls.length
      if controls[i] && controls[i][2] == position
        control = controls[i][0]
        param = controls[i][1]
        endtag = controls[i][3]
        if control == "c"
          if endtag
            colorstack.pop
          else
            if ["green", "orange", "red"].include?(param) # Used by field notes
              param = { "green" => "008000", "orange" => "FF8C00", "red" => "DC143C" }[param]
              base = rgbToColor(param)
              shadow = getAutoShadowColor(base)
              colorstack.push([base, shadow])
            else
              color = rgbToColor(param)
              colorstack.push([color, nil])
            end
          end
        elsif control == "c2"
          if endtag
            colorstack.pop
          else
            base = Rgb16ToColor(param[0, 4])
            shadow = Rgb16ToColor(param[4, 4])
            colorstack.push([base, shadow])
          end
        elsif control == "c3"
          if endtag
            colorstack.pop
          else
            param = param.split(",")
            # get pure colors unaffected by opacity
            oldColors = getLastParam(colorstack, defaultcolors)
            base = (param[0] && param[0] != "") ? rgbToColor(param[0]) : oldColors[0]
            shadow = (param[1] && param[1] != "") ? rgbToColor(param[1]) : oldColors[1]
            colorstack.push([base, shadow])
          end
        elsif control == "gr"
          if endtag
            gradientstack.pop
          else
            param.gsub!(",", "")
            param = [param[0, 6], param[6, 6]]
            color1 = (param[0] && param[0] != "") ? rgbToColor(param[0]) : nil
            color2 = (param[1] && param[1] != "") ? rgbToColor(param[1]) : nil
            gradientstack.push([color1, color2])
          end
        elsif control == "o"
          if endtag
            opacitystack.pop
          else
            opacitystack.push(param.sub(/\s+$/, "").to_i)
          end
        elsif control == "b"
          boldcount += (endtag ? -1 : 1)
        elsif control == "i"
          italiccount += (endtag ? -1 : 1)
        elsif control == "u"
          underlinecount += (endtag ? -1 : 1)
        elsif control == "s"
          strikecount += (endtag ? -1 : 1)
        elsif control == "outln"
          outlinecount += (endtag ? -1 : 1)
        elsif control == "outln2"
          outline2count += (endtag ? -1 : 1)
        elsif control == "fs" # Font size
          if endtag
            fontsizestack.pop
          else
            fontsizestack.push(param.sub(/\s+$/, "").to_i)
          end
          fontsize = getLastParam(fontsizestack, defaultfontsize)
          bitmap.font.size = fontsize
        elsif control == "fn" # Font name
          if endtag
            fontnamestack.pop
          else
            fontname = param.sub(/\s+$/, "")
            fontnamestack.push(Font.exist?(fontname) ? fontname : "Arial")
          end
          fontname = getLastParam(fontnamestack, defaultfontname)
          bitmap.font.name = fontname
        elsif control == "ar" # Right align
          if !endtag
            alignstack.push(1)
            nextline = 1 if x > 0 && nextline == 0
          else
            alignstack.pop
            nextline = 1 if x > 0 && nextline == 0
          end
        elsif control == "al" # Left align
          if !endtag
            alignstack.push(0)
            nextline = 1 if x > 0 && nextline == 0
          else
            alignstack.pop;
            nextline = 1 if x > 0 && nextline == 0
          end
        elsif control == "ac" # Center align
          if !endtag
            alignstack.push(2)
            nextline = 1 if x > 0 && nextline == 0
          else
            alignstack.pop
            nextline = 1 if x > 0 && nextline == 0
          end
        elsif control == "br" # Line break
          if !endtag
            nextline += 1
          end
        elsif control == "r" # Right align this line
          if !endtag
            x = 0
            rightalign = 1; lastword = [characters.length, x]
          end
        elsif control == "lh"
          if endtag
            lineheightstack.pop
          else
            lineheightstack.push(param.sub(/\s+$/, "").to_i)
          end
          lineheight = getLastParam(lineheightstack, defaultlineheight)
          yDst = lineheight == defaultlineheight ? defaultheight : (defaultlineheight - lineheight) + yDst
        end
        controls[i] = nil
      end
    end
    bitmap.font.bold = (boldcount > 0)
    bitmap.font.italic = (italiccount > 0)
    if textchars[position] == TextPlaceholders::Image
      # If this character has an image placeholder, begin image processing.
      type, param, endtag = images.delete_at(0)
      if !endtag
        case type
          when "icon"
            param = param.sub(/\s+$/, "")
            graphic = "Graphics/Icons/#{param}"
            graphic = "Graphics/Icons/Item/#{param}"if !pbResolveBitmap(graphic)
          when "img"
            param = param.sub(/\s+$/, "")
            param = param.split("|")
            graphic = param[0]
            if param.length > 1
              graphicX = param[1].to_i
              graphicY = param[2].to_i
              graphicWidth = param[3].to_i
              graphicHeight = param[4].to_i
            end
        end
      end
    end
    if graphic
      begin
        if !graphicWidth
          tempgraphic = Bitmap.new(graphic)
          # Trim any empty spaces from around the graphic before using its dimensions
          graphicX, graphicY, graphicWidth, graphicHeight = trimmedBitmapCoords(tempgraphic)
          tempgraphic.dispose
        end
        width = graphicWidth # +8  # No padding
        xStart = 0 # 4
        fontHeight = bitmap.text_size("X").height + 2 # Icon should be center-aligned to font and font height is different for different fonts
        yStart = ((fontHeight - graphicHeight) / 2).to_grid
        graphicRect = Rect.new(graphicX, graphicY, graphicWidth, graphicHeight)
      rescue
        dp("Could not resolve file: #{graphic}")
        graphic = nil
      end
    end
    if !graphic
      yStart = 0
      xStart = 0
      width = hasNoWidth?(textchars[position]) ? 0 : bitmap.text_size(textchars[position]).width
      width += 2 if width > 0 && outline2count > 0
    end
    if rightalign == 1 && nextline == 0
      alignment = 1
    else
      alignment = getLastParam(alignstack, 0)
    end
    nextline.times do
      havenl = true
      characters.push(["\n", x, y * lineheight + yDst, 0, lineheight, false, false, false, defaultcolors[0], defaultcolors[1], false, false, "", defaultfontsize, position, nil, 0])
      charactersInternal.push([alignment, y, 0])
      y += 1;
      x = 0;
      rightalign = 0;
      lastword = [characters.length, x]
      hadspace = false
      hadnonspace = false
    end
    if textchars[position] == "\n"
      if newlineBreaks
        if nextline == 0
          havenl = true
          characters.push(["\n", x, y * lineheight + yDst, 0, lineheight, false, false, false, defaultcolors[0], defaultcolors[1], false, false, "", defaultfontsize, position, nil, 0, nil])
          charactersInternal.push([alignment, y, 0])
          y += 1
          x = 0
        end
        rightalign = 0
        hadspace = true
        hadnonspace = false
        position += 1
        next
      else
        textchars[position] = " "
        if !graphic
          width = bitmap.text_size(textchars[position]).width
          width += 2 if width > 0 && outline2count > 0
        end
      end
    end
    isspace = (textchars[position][/\s/] || hasNoWidth?(textchars[position])) ? true : false
    if hadspace && !isspace
      # set last word to here
      lastword[0] = characters.length
      lastword[1] = x
      hadspace = false
      hadnonspace = true
    elsif isspace
      hadspace = true
    end
    textx = x + xStart # independent of xDst
    texty = (lineheight * y) + yDst + yStart
    colors = getLastColors(colorstack, opacitystack, defaultcolors)
    gradient = gradientstack[-1]
    gradient = nil if gradient&.any? { |g| g.nil? }
    oldx = x
    # Push character, textx will be calculated later
    if heightDst < 0 || texty < yDst + heightDst
      havenl = true if !graphic && hasNoWidth?(textchars[position])
      extraspace = (!graphic && italiccount > 0) ? 2 + (width / 2) : 2
      characters.push(
        [
          textchars[position],
          x + xStart, texty, width + extraspace, lineheight,
          graphic,
          (boldcount > 0), (italiccount > 0), colors[0], colors[1],
          (underlinecount > 0), (strikecount > 0), fontname, fontsize,
          position, graphicRect,
          ((outlinecount > 0) ? 1 : 0) + ((outline2count > 0) ? 2 : 0),
          gradient
        ]
      )
      charactersInternal.push([alignment, y, xStart, textchars[position], extraspace])
    end
    x += width
    if !explicitBreaksOnly && x + 2 > widthDst && lastword[1] != 0 &&
       (!hadnonspace || !hadspace)
      havenl = true
      characters.insert(
        lastword[0],
        [
          "\n", x, y * lineheight + yDst, 0, lineheight, false,
          false, false, defaultcolors[0], defaultcolors[1], false, false, "", defaultfontsize, position,
          nil, 0, nil
        ]
      )
      charactersInternal.insert(lastword[0], [alignment, y, 0])
      lastword[0] += 1
      y += 1
      x = 0
      for i in lastword[0]...characters.length
        characters[i][2] += lineheight
        charactersInternal[i][1] += 1
        extraspace = (charactersInternal[i][4]) ? charactersInternal[i][4] : 0
        charwidth = characters[i][3] - extraspace
        characters[i][1] = x + charactersInternal[i][2]
        x += charwidth
      end
      lastword[1] = 0
    end
    position += 1
  end
  if havenl
    # Eliminate spaces before newlines and pause character
    firstspace = -1
    for i in 0...characters.length
      if characters[i][5] # If not a character
        firstspace = -1
      elsif (characters[i][0] == "\n" || hasNoWidth?(characters[i][0])) &&
            firstspace >= 0
        for j in firstspace...i
          characters[j] = nil
          charactersInternal[j] = nil
        end
        firstspace = -1
      elsif characters[i][0][/[ \r\t]/]
        if firstspace < 0
          firstspace = i
        end
      else
        firstspace = -1
      end
    end
    if firstspace > 0
      for j in firstspace...characters.length
        characters[j] = nil
        charactersInternal[j] = nil
      end
    end
    characters.compact!
    charactersInternal.compact!
  end
  # Calculate Xs based on alignment
  # First, find all text runs with the same alignment on the same line
  totalwidth = 0
  widthblocks = []
  lastalign = 0
  lasty = 0
  runstart = 0
  for i in 0...characters.length
    c = characters[i]
    if i > 0 && (charactersInternal[i][0] != lastalign ||
       charactersInternal[i][1] != lasty)
      # Found end of run
      widthblocks.push([runstart, i, lastalign, totalwidth, lasty])
      runstart = i
      totalwidth = 0
    end
    lastalign = charactersInternal[i][0]
    lasty = charactersInternal[i][1]
    extraspace = (charactersInternal[i][4]) ? charactersInternal[i][4] : 0
    totalwidth += c[3] - extraspace
  end
  widthblocks.push([runstart, characters.length, lastalign, totalwidth, lasty])
  if collapseAlignments
    # Calculate the total width of each line
    totalLineWidths = []
    for block in widthblocks
      y = block[4]
      if !totalLineWidths[y]
        totalLineWidths[y] = 0
      end
      if totalLineWidths[y] != 0
        # padding in case more than one line has different alignments
        totalLineWidths[y] += 16
      end
      totalLineWidths[y] += block[3]
    end
    # Calculate a new width for the next step
    widthDst = [widthDst, (totalLineWidths.compact.max || 0)].min
  end
  # Now, based on the text runs found, recalculate Xs
  for block in widthblocks
    next if block[0] >= block[1]

    for i in block[0]...block[1]
      case block[2]
        when 1; characters[i][1] = xDst + (widthDst - block[3] - 4) + characters[i][1]
        when 2; characters[i][1] = xDst + ((widthDst / 2) - (block[3] / 2)) + characters[i][1]
        else; characters[i][1] = xDst + characters[i][1]
      end
    end
  end
  # Remove all characters with Y greater or equal to _yDst_+_heightDst_
  if heightDst >= 0
    for i in 0...characters.length
      if characters[i][2] >= yDst + heightDst
        characters[i] = nil
      end
    end
    characters.compact!
  end
  bitmap.font = oldfont
  dummybitmap.dispose if dummybitmap
  return characters
end

# Method below corrects for MKXP-Z's drawText fix (24.3.2024)
# MKXP-Z now clamps text to the passed bounds, which does not
# interact nicely with our fontstack system.
# This method serves to bypass this clamp by handling the math
# before the internals get any values.
alias __core_getFormattedText getFormattedText unless defined?(__core_getFormattedText)
def getFormattedText(*args)
  ret = __core_getFormattedText(*args)
  ret&.each { |ch|
    fontsize = ch[13]
    y = ch[2]
    # The min fixes second page of pokemon summary on Kirin. The font size needs to be 38 on Kirin.
    alignY = y + ((32 - [fontsize, 32].min) / 2)
    ch[2] = alignY
    ch[4] = fontsize
    # Note: This is entirely unrelated to the above code.
    # Using Screen Size 1.5x, Screen Border On and enumag/mkxp-z 2.5.0+ with the new font rendering was causing some text rendering issues.
    # It was particularly noticeable on the Controls screen, mainly the "<" character in the top right corner. Making sure both coords are on grid seems to fix the problem.
    fontname = ch[12]
    if fontsize == getSystemFontSize(fontname)
      ch[1] = ch[1].to_grid
      ch[2] = ch[2].to_grid
    end
  }
  return ret
end

def drawBitmapBuffer(chars)
  width = 1
  height = 1
  for ch in chars
    chx = ch[1] + ch[3]
    chy = ch[2] + ch[4]
    width = chx if width < chx
    height = chy if height < chy
  end
  buffer = Bitmap.new(width, height)
  drawFormattedChars(buffer, chars)
  return buffer
end

def drawSingleFormattedChar(bitmap, ch)
  if ch[0] == TextPlaceholders::ShakingTextStart || ch[0] == TextPlaceholders::ShakingTextStop
    # necessary for shaking text start/endpoints.
    if bitmap.font.color != ch[8]
      bitmap.font.color = ch[8]
    end
    return
  end
  if ch[0] == TextPlaceholders::Image && ch[5] # When expecting graphic
    # Note: We now check both if c[0] is an image placeholder AND if ch[5] was given a file path.
    # This is to purposefully display an incorrect character if something went wrong in processing rather than crashing.
    graphic = Bitmap.new(ch[5])
    graphicRect = ch[15]
    bitmap.blt(ch[1], ch[2], graphic, graphicRect, ch[8].alpha)
    graphic.dispose
  else
    if bitmap.font.size != ch[13]
      bitmap.font.size = ch[13]
    end
    if ch[0] != "\n" && ch[0] != "\r" && ch[0] != " " && !hasNoWidth?(ch[0])
      if bitmap.font.bold != ch[6]
        bitmap.font.bold = ch[6]
      end
      if bitmap.font.italic != ch[7]
        bitmap.font.italic = ch[7]
      end
      if bitmap.font.name != ch[12]
        bitmap.font.name = ch[12]
      end
      offset = 0
      if ch[9] # shadow
        bitmap.font.color = ch[9]
        if (ch[16] & 1) != 0 # outline
          offset = 1
          bitmap.draw_text(ch[1], ch[2], ch[3] + 2, ch[4], ch[0])
          bitmap.draw_text(ch[1], ch[2] + 1, ch[3] + 2, ch[4], ch[0])
          bitmap.draw_text(ch[1], ch[2] + 2, ch[3] + 2, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 1, ch[2], ch[3] + 2, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 1, ch[2] + 2, ch[3] + 2, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 2, ch[2], ch[3] + 2, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 2, ch[2] + 1, ch[3] + 2, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 2, ch[2] + 2, ch[3] + 2, ch[4], ch[0])
        elsif (ch[16] & 2) != 0 # outline 2
          offset = 2
          bitmap.draw_text(ch[1], ch[2], ch[3] + 4, ch[4], ch[0])
          bitmap.draw_text(ch[1], ch[2] + 2, ch[3] + 4, ch[4], ch[0])
          bitmap.draw_text(ch[1], ch[2] + 4, ch[3] + 4, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 2, ch[2], ch[3] + 4, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 2, ch[2] + 4, ch[3] + 4, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 4, ch[2], ch[3] + 4, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 4, ch[2] + 2, ch[3] + 4, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 4, ch[2] + 4, ch[3] + 4, ch[4], ch[0])
        else
          bitmap.draw_text(ch[1] + 2, ch[2], ch[3] + 2, ch[4], ch[0])
          bitmap.draw_text(ch[1], ch[2] + 2, ch[3] + 2, ch[4], ch[0])
          bitmap.draw_text(ch[1] + 2, ch[2] + 2, ch[3] + 2, ch[4], ch[0])
        end
      end
      if bitmap.font.color != ch[8]
        bitmap.font.color = ch[8]
      end
      bitmap.draw_text(ch[1] + offset, ch[2] + offset, ch[3], ch[4], ch[0])
    else
      if bitmap.font.color != ch[8]
        bitmap.font.color = ch[8]
      end
    end
    if ch[10] # underline
      bitmap.fill_rect(ch[1], ch[2] + ch[4] - [(ch[4] - bitmap.font.size) / 2, 0].max - 2, ch[3] - 2, 2, ch[8])
    end
    if ch[11] # strikeout
      bitmap.fill_rect(ch[1], ch[2] + (ch[4] / 2), ch[3] - 2, 2, ch[8])
    end
    if ch[17] # gradient
      realX = ch[1]
      realY = ch[2]
      width = ch[3]
      height = ch[4]
      textColor = ch[8]
      shadowColor = ch[9]
      color1 = ch[17][0]
      color1shadow = getColorShadow(color1)
      color2 = ch[17][1]
      color2shadow = getColorShadow(color2)
      colorBmp = Bitmap.new(width, height)
      shadowBmp = Bitmap.new(width, height)
      if $joiplay
        colorBmp.fill_rect(colorBmp.rect, color1)
        shadowBmp.fill_rect(shadowBmp.rect, color1shadow)
      else
        colorBmp.gradient_fill_rect(colorBmp.rect, color1, color2, true) # true = horizontal
        shadowBmp.gradient_fill_rect(shadowBmp.rect, color1shadow, color2shadow, true)
      end
      for x in 0...width
        for y in 0...height
          if bitmap.get_pixel(x + realX, y + realY) == textColor
            bitmap.set_pixel(x + realX, y + realY, colorBmp.get_pixel(x, y - 4))
            next
          end
          if shadowColor && bitmap.get_pixel(x + realX, y + realY) == shadowColor
            bitmap.set_pixel(x + realX, y + realY, shadowBmp.get_pixel(x, y - 4))
          end
        end
      end
      colorBmp.dispose
    end
  end
end

def drawFormattedChars(bitmap, chars)
  if chars.length == 0 || !bitmap || bitmap.disposed?
    return
  end

  oldfont = bitmap.font.clone
  for ch in chars
    drawSingleFormattedChar(bitmap, ch)
  end
  bitmap.font = oldfont
end

def drawTextTable(bitmap, x, y, totalWidth, rowHeight, columnWidthPercents, table)
  yPos = y
  for i in 0...table.length
    row = table[i]
    xPos = x
    for j in 0...row.length
      cell = row[j]
      cellwidth = columnWidthPercents[j] * totalWidth / 100
      chars = getFormattedText(bitmap, xPos, yPos, cellwidth, -1, cell, rowHeight)
      drawFormattedChars(bitmap, chars)
      xPos += cellwidth
    end
    yPos += rowHeight
  end
end

def drawTextEx(bitmap, x, y, width, numlines, text, baseColor, shadowColor, lineheight = 32)
  normtext = getLineBrokenChunks(bitmap, text, width, nil, true, lineheight)
  lines = normtext.count { |v| v[1] == 0 }
  x = x.call(lines) if x.is_a?(Proc)
  y = y.call(lines) if y.is_a?(Proc)
  renderLineBrokenChunksWithShadow(bitmap, x, y, normtext, numlines * lineheight, baseColor, shadowColor)
  return lines
end

def fmtescape(text)
  if text[/[&<>]/]
    text2 = text.gsub(/&/, "&amp;")
    text2.gsub!(/</, "&lt;")
    text2.gsub!(/>/, "&gt;")
    return text2
  end
  return text
end

# Deprecated -- not to be used in new code
def coloredToFormattedText(text, baseColor = nil, shadowColor = nil)
  base = !baseColor ? Color.new(12 * 8, 12 * 8, 12 * 8) : baseColor.clone
  shadow = !shadowColor ? Color.new(26 * 8, 26 * 8, 25 * 8) : shadowColor.clone
  text2 = text.gsub(/&/, "&amp;")
  text2.gsub!(/</, "&lt;")
  text2.gsub!(/>/, "&gt;")
  text2.gsub!(/\\\[([A-Fa-f0-9]{8,8})\]/) { "<c2=" + $1 + ">" }
  text2 = "<c2=" + colorToRgb16(base) + colorToRgb16(shadow) + ">" + text2
  text2.gsub!(/\\\\/, "\\")
  return text2
end

def drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
  base = !baseColor ? Color.new(12 * 8, 12 * 8, 12 * 8) : baseColor.clone
  shadow = !shadowColor ? Color.new(26 * 8, 26 * 8, 25 * 8) : shadowColor.clone
  text = "<c2=" + colorToRgb16(base) + colorToRgb16(shadow) + ">" + text
  chars = getFormattedText(bitmap, x, y, width, -1, text, lineheight)
  drawFormattedChars(bitmap, chars)
end

# Deprecated -- not to be used in new code
def drawColoredTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil)
  chars = getFormattedText(bitmap, x, y, width, -1, coloredToFormattedText(text), 32)
  drawFormattedChars(bitmap, chars)
end

ColorTags = ColorArrays.transform_values { |colors| shadowc3tag(*colors) }
LightColorTags = LightColorArrays.transform_values { |colors| shadowc3tag(*colors) }
AtebitColorTags = AtebitColorArrays.transform_values { |colors| ctag(colors[0]) }

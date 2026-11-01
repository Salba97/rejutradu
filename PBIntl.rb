def pbAddScriptTexts(items, script)
  script.scan(/(?:_I)\s*\(\s*\"((?:[^\\\"]*\\\"?)*[^\"]*)\"/) { |s|
    string = s[0]
    string.gsub!(/\\\"/, "\"")
    string.gsub!(/\\\\/, "\\")
    items.push(string)
  }
end

def pbAddRgssScriptTexts(items, script)
  script.scan(/(?:_INTL|_ISPRINTF)\s*\(\s*\"((?:[^\\\"]*\\\"?)*[^\"]*)\"/) { |s|
    string = s[0]
    string.gsub!(/\\r/, "\r")
    string.gsub!(/\\n/, "\n")
    string.gsub!(/\\1/, TextPlaceholders::InputPause)
    string.gsub!(/\\\"/, "\"")
    string.gsub!(/\\\\/, "\\")
    items.push(string)
  }
  script.scan(/(?:_INTL|_ISPRINTF)\s*\(\s*\'((?:[^\\\']*\\\'?)*[^\']*)\'/) { |s|
    string = s[0]
    string.gsub!(/\\r/, "\r")
    string.gsub!(/\\n/, "\n")
    string.gsub!(/\\1/, TextPlaceholders::InputPause)
    string.gsub!(/\\\'/, "\'")
    string.gsub!(/\\\\/, "\\")
    items.push(string)
  }
end

def pbSetTextMessages
  Graphics.update
  begin
    t = Time.now.to_i
    texts = []
    for script in [*INIT, *SCRIPTS]
      next if script.nil?
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      src = File.read("Scripts/#{script}.rb")
      pbAddRgssScriptTexts(texts, src)
    end
    # Must add messages because this code is used by both game system and Editor
    MessageTypes.addMessagesAsHash(:ScriptTexts, texts)
    commonevents = load_data("Data/CommonEvents.rxdata")
    items = []
    choices = []
    for event in commonevents.compact
      next if event.name.start_with?("REMOVED")
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      begin
        neednewline = false
        lastitem = ""
        for j in 0...event.list.size
          list = event.list[j]
          if neednewline && list.code != 401
            if lastitem != ""
              lastitem.gsub!(/([^\.\!\?])\s\s+/) { |m| $1 + " " }
              items.push(lastitem)
              lastitem = ""
            end
            neednewline = false
          end
          if list.code == 101
            lastitem += "#{list.parameters[0]}" if !$RPGVX
            neednewline = true
          elsif list.code == 102
            for k in 0...list.parameters[0].length
              choices.push(list.parameters[0][k])
            end
            neednewline = false
          elsif list.code == 401
            lastitem += " " if lastitem != ""
            lastitem += "#{list.parameters[0]}"
            neednewline = true
          elsif list.code == 355 || list.code == 655
            pbAddScriptTexts(items, list.parameters[0])
          elsif list.code == 111 && list.parameters[0] == 12
            pbAddScriptTexts(items, list.parameters[1])
          elsif list.code == 209
            route = list.parameters[1]
            for k in 0...route.list.size
              if route.list[k].code == 45
                pbAddScriptTexts(items, route.list[k].parameters[0])
              end
            end
          end
        end
        if neednewline
          if lastitem != ""
            items.push(lastitem)
            lastitem = ""
          end
        end
      end
    end
    if Time.now.to_i - t >= 5
      t = Time.now.to_i
      Graphics.update
    end
    items |= []
    choices |= []
    items.concat(choices)
    MessageTypes.setMapMessagesAsHash(0, items)
    mapnames = []
    for id in $cache.mapinfos.keys
      next if $cache.mapinfos[id].name.start_with?("REMOVED")
      mapnames.push $cache.mapinfos[id].name
    end
    MessageTypes.setMessagesAsHash(:MapNames, mapnames)
    for id in $cache.mapinfos.keys
      next if $cache.mapinfos[id].name.start_with?("REMOVED")
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      filename = sprintf("Data/Map%03d.%s", id, $RPGVX ? "rvdata" : "rxdata")
      next if !pbRgssExists?(filename)

      map = $cache.map_load(id)
      items = []
      choices = []
      for event in map.events.values
        if Time.now.to_i - t >= 5
          t = Time.now.to_i
          Graphics.update
        end
        begin
          for i in 0...event.pages.size
            neednewline = false
            lastitem = ""
            for j in 0...event.pages[i].list.size
              list = event.pages[i].list[j]
              if neednewline && list.code != 401
                if lastitem != ""
                  lastitem.gsub!(/([^\.\!\?])\s\s+/) { |m| $1 + " " }
                  items.push(lastitem)
                  lastitem = ""
                end
                neednewline = false
              end
              if list.code == 101
                lastitem += "#{list.parameters[0]}" if !$RPGVX
                neednewline = true
              elsif list.code == 102
                for k in 0...list.parameters[0].length
                  choices.push(list.parameters[0][k])
                end
                neednewline = false
              elsif list.code == 401
                lastitem += " " if lastitem != ""
                lastitem += "#{list.parameters[0]}"
                neednewline = true
              elsif list.code == 355 || list.code == 655
                pbAddScriptTexts(items, list.parameters[0])
              elsif list.code == 111 && list.parameters[0] == 12
                pbAddScriptTexts(items, list.parameters[1])
              elsif list.code == 209
                route = list.parameters[1]
                for k in 0...route.list.size
                  if route.list[k].code == 45
                    pbAddScriptTexts(items, route.list[k].parameters[0])
                  end
                end
              end
            end
            if neednewline
              if lastitem != ""
                items.push(lastitem)
                lastitem = ""
              end
            end
          end
        end
      end
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      items |= []
      choices |= []
      items.concat(choices)
      MessageTypes.setMapMessagesAsHash(id, items)
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
    end
  rescue Hangup
  end
  Graphics.update
end

def pbEachIntlSection(file)
  lineno = 1
  re = /^\s*\[\s*([^\]]+)\s*\]\s*$/
  havesection = false
  sectionname = nil
  lastsection = []
  file.each_line { |line|
    if lineno == 1 && line[0] == 0xEF && line[1] == 0xBB && line[2] == 0xBF
      line = line[3, line.length - 3]
    end
    if !line[/^\#\#\#/] && !line[/^\s*$/]
      if line[re]
        if havesection
          puts "Compiling section #{sectionname}"
          yield lastsection, sectionname
        end
        lastsection.clear
        sectionname = $~[1]
        havesection = true
      else
        if sectionname == nil
          raise _INTL("Expected a section at the beginning of the file (line {1})", lineno)
        end

        lastsection.push(line.gsub(/\s+$/, ""))
      end
    end
    lineno += 1
    if lineno % 500 == 0
      Graphics.update
    end
  }
  if havesection
    yield lastsection, sectionname
  end
end

def pbGetText(infile)
  begin
    file = File.open(infile, "rb:utf-8")
  rescue
    raise _INTL("Can't find {1}", infile)
  end
  intldat = {}
  begin
    pbEachIntlSection(file) { |section, name|
      index = name
      if section.length == 0
        next
      end
      matches = name.match(/^([Mm][Aa][Pp])?(\d+)|([a-zA-Z]+)$/)
      if !matches
        raise _INTL("Invalid section name {1}", name)
      end

      ismap = matches[1] && matches[1] != ""
      id = matches[2].to_i
      sym = matches[3] && matches[3] != "" && matches[3].to_sym
      itemlength = 0
      if section[0][/^\d+$/]
        intlhash = []
        itemlength = 3
        if ismap
          raise _INTL(
            "Section {1} can't be an ordered list (section was recognized as an ordered list because its first line is a number)", name
          )
        end
        if section.length % 3 != 0
          raise _INTL(
            "Section {1}'s line count is not divisible by 3 (section was recognized as an ordered list because its first line is a number)", name
          )
        end
      else
        intlhash = OrderedHash.new
        itemlength = 2
        if section.length % 2 != 0
          raise _INTL(
            "Section {1} has an odd number of entries (section was recognized as a hash because its first line is not a number)", name
          )
        end
      end
      i = 0
      loop do
        break unless i < section.length

        if itemlength == 3
          if !section[i][/^\d+$/]
            raise _INTL("Expected a number in section {1}, got {2} instead", name, section[i])
          end

          key = section[i].to_i
          i += 1
        else
          key = MessageTypes.denormalizeValue(section[i])
        end
        intlhash[key] = MessageTypes.denormalizeValue(section[i + 1])
        i += 2
      end
      if ismap
        intldat[0] = [] if !intldat[0]
        intldat[0][id] = intlhash
      else
        intldat[sym] = intlhash
      end
    }
  ensure
    file.close
  end
  puts "Done"
  return intldat
end

def pbCompileText
  outfile = File.open("intl.dat", "wb")
  begin
    intldat = pbGetText("intl.txt")
    Marshal.dump(intldat, outfile)
  rescue
    raise
  ensure
    outfile.close
  end
end

class OrderedHash < Hash
  def initialize
    @keys = []
    super
  end

  def keys
    return @keys.clone
  end

  def inspect
    str = "{"
    for i in 0...@keys.length
      str += ", " if i > 0
      str += @keys[i].inspect + "=>" + self[@keys[i]].inspect
    end
    str += "}"
    return str
  end

  def to_s
    return self.inspect
  end

  def []=(key, value)
    oldvalue = self[key]
    if !oldvalue && value
      @keys.push(key)
    elsif !value
      @keys |= []
      @keys -= [key]
    end
    return super(key, value)
  end

  def self._load(string)
    ret = self.new
    keysvalues = Marshal.load(string)
    keys = keysvalues[0]
    values = keysvalues[1]
    for i in 0...keys.length
      ret[keys[i]] = values[i]
    end
    return ret
  end

  def _dump(depth = 100)
    values = []
    for key in @keys
      values.push(self[key])
    end
    return Marshal.dump([@keys, values])
  end
end

class Messages
  def initialize(filename = nil, delayLoad = false)
    @messages = nil
    @filename = filename
    if @filename && !delayLoad
      loadMessageFile(@filename)
    end
  end

  def delayedLoad
    if @filename && !@messages
      loadMessageFile(@filename)
      @filename = nil
    end
  end

  def self.stringToKey(str)
    if str[/[\r\n\t\1]|^\s+|\s+$|\s{2,}/]
      key = str.clone
      key.gsub!(/^\s+/, "")
      key.gsub!(/\s+$/, "")
      key.gsub!(/\s{2,}/, " ")
      return key
    end
    return str
  end

  def self.normalizeValue(value)
    # Leave support for \1 usage
    if value[/[\r\n\t\x01#{TextPlaceholders::InputPause}]|^[\[\]]/]
      ret = value.clone
      ret.gsub!(/\r/, "<<r>>")
      ret.gsub!(/\n/, "<<n>>")
      ret.gsub!(/\t/, "<<t>>")
      ret.gsub!(/\[/, "<<[>>")
      ret.gsub!(/\]/, "<<]>>")
      ret.gsub!(/[\x01#{TextPlaceholders::InputPause}]/, "<<1>>")
      return ret
    end
    return value
  end

  def self.denormalizeValue(value)
    if value[/<<[rnt1\[\]]>>/]
      ret = value.clone
      ret.gsub!(/<<1>>/, TextPlaceholders::InputPause)
      ret.gsub!(/<<r>>/, "\r")
      ret.gsub!(/<<n>>/, "\n")
      ret.gsub!(/<<\[>>/, "[")
      ret.gsub!(/<<\]>>/, "]")
      ret.gsub!(/<<t>>/, "\t")
      return ret
    end
    return value
  end

  def self.writeObject(f, msgs, secname, origMessages = nil)
    return if !msgs

    if msgs.is_a?(Array)
      f.write("[#{secname}]\n")
      for j in 0...msgs.length
        next if msgs[j] == nil || msgs[j] == ""

        value = Messages.normalizeValue(msgs[j])
        origValue = ""
        if origMessages
          origValue = Messages.normalizeValue(origMessages.get(secname, j))
        else
          origValue = Messages.normalizeValue(MessageTypes.get(secname, j))
        end
        # value = "INTL " + value
        f.write("#{j}\n")
        f.write(origValue + "\n")
        f.write(value + "\n")
      end
    elsif msgs.is_a?(OrderedHash)
      f.write("[#{secname}]\n")
      keys = msgs.keys
      for key in keys
        next if msgs[key] == nil || msgs[key] == ""

        value = Messages.normalizeValue(msgs[key])
        valkey = Messages.normalizeValue(key)
        # value = "INTL " + value
        # key is already serialized
        f.write(valkey + "\n")
        f.write(value + "\n")
      end
    end
  end

  def messages
    return @messages || {}
  end

  def extract(outfile)
    #    return if !@messages
    origMessages = Messages.new("Data/messages.dat")
    File.open(outfile, "wb") { |f|
      f.write("### To localize this text for a particular language, please\n")
      f.write("### translate every second line of this file.\n")
      if origMessages.messages[0]
        for i in 0...origMessages.messages[0].length
          msgs = origMessages.messages[0][i]
          Messages.writeObject(f, msgs, "Map#{i}", origMessages)
        end
      end
      origMessages.messages.each do |key, msgs|
        next if key == 0
        Messages.writeObject(f, msgs, key, origMessages)
      end
    }
  end

  def exportPO
    loadGetText
    origMessages = Messages.new("Data/messages.dat")
    if origMessages.messages[0]
      for i in 0...origMessages.messages[0].length
        next if i != 0 && $cache.mapinfos[i].name.start_with?("REMOVED")
        msgs = origMessages.messages[0][i]
        self.exportFile(sprintf("Map%03d", i), msgs)
      end
    end
    origMessages.messages.each do |key, msgs|
      next if key == 0
      self.exportFile(key.to_s, msgs)
    end
  end

  def exportFile(file, msgs)
    return if msgs.nil?
    raise "Unexprected array" if msgs.is_a?(Array)

    FileUtils.mkdir_p("localization")
    File.open("localization/#{file}.po", 'w:utf-8') do |f|
      header = GetText::POEntry.new(:normal)
      header.msgid = ""
      header.msgstr = <<~EOS.strip
        Project-Id-Version: #{GAME_TITLE.delete_prefix("Pokemon ")} #{GAME_VERSION}
        Content-Type: text/plain; charset=utf-8
      EOS
      f.puts header.to_s
      f.puts

      for key in msgs.keys
        next if msgs[key] == nil || msgs[key] == ""

        entry = GetText::POEntry.new(:normal)
        entry.msgid = key
        entry.msgstr = ""

        f.puts entry.to_s
        f.puts
      end
    end
  end

  def loadGetText
    require 'gettext/tools'
    require 'gettext'
  end

  def compileMO
    loadGetText
    Dir.glob(@getTextLocale + "/*.po") do |file|
      compile_po(file, sprintf("%s/%s.mo", @getTextLocale, File.basename(file, ".po")))
    end
  end

  def clearMessages()
    @messages = {}
  end

  def setMessages(type, array)
    arr = []
    @messages = {} if !@messages
    for i in 0...array.length
      arr[i] = array[i] ? array[i] : ""
    end
    @messages[type] = arr
  end

  def self.createHash(type, array)
    arr = OrderedHash.new
    for i in 0...array.length
      if array[i]
        key = Messages.stringToKey(array[i])
        arr[key] = array[i]
      end
    end
    return arr
  end

  def self.addToHash(type, array, hash)
    if !hash
      hash = OrderedHash.new
    end
    for i in 0...array.length
      if array[i]
        key = Messages.stringToKey(array[i])
        hash[key] = array[i]
      end
    end
    return hash
  end

  def setMapMessagesAsHash(type, array)
    @messages = {} if !@messages
    @messages[0] = [] if !@messages[0]
    @messages[0][type] = Messages.createHash(type, array)
  end

  def addMapMessagesAsHash(type, array)
    @messages = {} if !@messages
    @messages[0] = [] if !@messages[0]
    @messages[0][type] = Messages.addToHash(type, array, @messages[0][type])
  end

  def setMessagesAsHash(type, array)
    @messages = {} if !@messages
    @messages[type] = Messages.createHash(type, array)
  end

  def addMessagesAsHash(type, array)
    @messages = {} if !@messages
    @messages[type] = Messages.addToHash(type, array, @messages[type])
  end

  def saveMessages(filename = nil)
    filename = "Data/messages.dat" if !filename
    File.open(filename, "wb") { |f|
      Marshal.dump(@messages, f)
    }
  end

  def loadMessageFile(filename)
    @getTextLocale = nil
    begin
      Kernel.pbRgssOpen(filename, "rb") { |f|
        puts "loaded messages", filename
        @messages = Marshal.load(f)
      }
      if !@messages.is_a?(Hash)
        @messages = nil
        raise "Corrupted data"
      end
      return @messages
    rescue
      @messages = nil
      return nil
    end
  end

  def getTextLocale
    return @getTextLocale
  end

  def loadTranslationDirectory(directory)
    loadGetText
    @getTextLocale = directory
    @loadedDomains = []
  end

  def set(type, id, value)
    raise "Messages.set is no longer supported, not compatible with PO / MO files"
    delayedLoad
    return if !@messages
    return if !@messages[type]

    @messages[type][id] = value
  end

  def getCount(type)
    delayedLoad
    return 0 if !@messages
    return 0 if !@messages[type]

    return @messages[type].length
  end

  def get(type, id)
    raise "Messages.get is no longer supported, not compatible with PO / MO files"
    delayedLoad
    return "" if id == nil || type == nil
    return "" if !@messages
    return "" if !@messages[type]
    return "" if !@messages[type][id]

    return @messages[type][id]
  end

  def loadDomain(domain)
    directory = @getTextLocale
    path = File.dirname(directory)
    GetText.locale = File.basename(directory)

    return if @loadedDomains.include?(domain)

    mo = sprintf("%s/%s.mo", directory, domain)
    po = sprintf("%s/%s.po", directory, domain)
    if !File.exist?(mo) && File.exist?(po)
      compile_po(po, mo)
    end

    raise "missing " + mo if !File.exist?(mo)
    GetText.bindtextdomain(domain, path: path, output_charset: "utf-8")

    @loadedDomains.push domain
  end

  def getFromHash(type, key)
    unless @getTextLocale.nil?
      key = key.rstrip
      return "" if key == ""
      loadDomain(type.to_s)
      GetText.textdomain(type.to_s)
      return GetText.gettext(Messages.stringToKey(key)).dup
    end

    delayedLoad
    return key if !@messages
    return key if !@messages[type]

    id = Messages.stringToKey(key)
    return key if !@messages[type][id]

    return @messages[type][id]
  end

  def getFromMapHash(type, key)
    unless @getTextLocale.nil?
      key = key.rstrip
      return "" if key == ""
      domain = sprintf("Map%03d", type.to_s)
      loadDomain(domain)
      GetText.textdomain(domain)
      return GetText.gettext(Messages.stringToKey(key)).dup
    end

    delayedLoad
    return key if !@messages
    return key if !@messages[0]
    return key if !@messages[0][type] && !@messages[0][0]

    id = Messages.stringToKey(key)
    if @messages[0][type] && @messages[0][type][id]
      return @messages[0][type][id]
    elsif @messages[0][0] && @messages[0][0][id]
      return @messages[0][0][id]
    end

    return key
  end
end

def compile_po(po_file, mo_file)
  original_stdout = $stdout
  original_stderr = $stderr

  $stdout = File.open(File::NULL, "w")
  $stderr = File.open(File::NULL, "w")

  GetText::Tools::MsgFmt.new.run(po_file, "-o", mo_file)
ensure
  $stdout.close unless $stdout.tty?
  $stderr.close unless $stderr.tty?
  $stdout = original_stdout
  $stderr = original_stderr
end

module MessageTypes
  @@messages         = Messages.new
  @@messagesFallback = Messages.new("Data/messages.dat", true)

  def self.stringToKey(str)
    return Messages.stringToKey(str)
  end

  def self.normalizeValue(value)
    return Messages.normalizeValue(value)
  end

  def self.denormalizeValue(value)
    Messages.denormalizeValue(value)
  end

  def self.writeObject(f, msgs, secname)
    @@messages.writeObject(f, msgs, secname)
  end

  def self.extract(outfile)
    @@messages.extract(outfile)
  end

  def self.exportPO
    @@messages.exportPO
  end

  def self.compileMO
    @@messages.compileMO
  end

  def self.clearMessages
    @@messages.clearMessages
  end

  def self.setMessages(type, array)
    @@messages.setMessages(type, array)
  end

  def self.createHash(type, array)
    Messages.createHash(type, array)
  end

  def self.addMapMessagesAsHash(type, array)
    @@messages.addMapMessagesAsHash(type, array)
  end

  def self.setMapMessagesAsHash(type, array)
    @@messages.setMapMessagesAsHash(type, array)
  end

  def self.addMessagesAsHash(type, array)
    @@messages.addMessagesAsHash(type, array)
  end

  def self.setMessagesAsHash(type, array)
    @@messages.setMessagesAsHash(type, array)
  end

  def self.saveMessages(filename = nil)
    @@messages.saveMessages(filename)
  end

  def self.loadMessageFile(filename)
    @@messages.loadMessageFile(filename)
  end

  def self.loadTranslationDirectory(filename)
    @@messages.loadTranslationDirectory(filename)
  end

  def self.getTextLocale
    @@messages.getTextLocale
  end

  def self.get(type, id)
    ret = @@messages.get(type, id)
    if ret == ""
      ret = @@messagesFallback.get(type, id)
    end
    return ret
  end

  def self.getCount(type)
    c1 = @@messages.getCount(type)
    c2 = @@messagesFallback.getCount(type)
    return c1 > c2 ? c1 : c2
  end

  def self.getOriginal(type, id)
    return @@messagesFallback.get(type, id)
  end

  def self.getFromHash(type, key)
    @@messages.getFromHash(type, key)
  end

  def self.getFromMapHash(type, key)
    @@messages.getFromMapHash(type, key)
  end

  def self.clearMessages
    @@messages = Messages.new
  end
end

def pbChooseLanguage
  commands = []
  LANGUAGES.each do |lang, file|
    commands.push(lang)
  end
  return Kernel.pbShowCommands(nil, commands)
end

def pbLoadLanguage
  language = $Settings.language
  if language.nil? || LANGUAGES.values[language].nil?
    MessageTypes.clearMessages
  else
    path = LANGUAGES.values[language]
    if File.directory?(path)
      MessageTypes.loadTranslationDirectory(path)
    else
      MessageTypes.loadMessageFile(path)
    end
  end
end

def pbGetMessage(type, id)
  # return MessageTypes.get(type, id)
  return MessageTypes.getFromHash(type, id)
end

def pbGetMessageFromHash(type, id)
  return MessageTypes.getFromHash(type, id)
end

# Replaces first argument with a localized version and formats the other
# parameters by replacing {1}, {2}, etc. with those placeholders.
def _INTL(*arg)
  begin
    string = MessageTypes.getFromHash(:ScriptTexts, arg[0])
  rescue
    string = arg[0]
  end
  string = string.clone
  string = string.dup if string.frozen?
  for i in 1...arg.length
    string.gsub!(/\{#{i}\}/, "#{arg[i]}")
  end
  return string
end

# Replaces first argument with a localized version and formats the other
# parameters by replacing {1}, {2}, etc. with those placeholders.
# This version acts more like sprintf, supports e.g. {1:d} or {2:s}
def _ISPRINTF(*arg)
  begin
    string = MessageTypes.getFromHash(:ScriptTexts, arg[0])
  rescue
    string = arg[0]
  end
  string = string.clone
  for i in 1...arg.length
    string.gsub!(/\{#{i}\:([^\}]+?)\}/) { |m|
      next sprintf("%" + $1, arg[i])
    }
  end
  return string
end

def _I(str)
  return _MAPINTL($game_map.map_id, str)
end

def _MAPINTL(mapid, *arg)
  string = MessageTypes.getFromMapHash(mapid, arg[0])
  string = string.clone
  for i in 1...arg.length
    string.gsub!(/\{#{i}\}/, "#{arg[i]}")
  end
  return string
end

def _MAPISPRINTF(mapid, *arg)
  string = MessageTypes.getFromMapHash(mapid, arg[0])
  string = string.clone
  for i in 1...arg.length
    string.gsub!(/\{#{i}\:([^\}]+?)\}/) { |m|
      next sprintf("%" + $1, arg[i])
    }
  end
  return string
end

class String # Console colors for strings
  def white;          "\e[0m#{self}\e[0m"  end
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def yellow;         "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_yellow;      "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end

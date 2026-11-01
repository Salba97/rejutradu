MenuHandlers.add(:pc_menu, :passwords,
  name:      proc { _INTL("Passwords") },
  order:     30,
  condition: proc { !($game_switches[:NotPlayerCharacter] && !$game_switches[:InterceptorsWish]) },
  effect:    proc {
    Kernel.pbMessage(_INTL("\\se[accesspc]Accessed the Password Menu."))
    entry = PasswordEntry.new($PokemonBag.pbQuantity(:DATACHIP), :DATACHIP)
    costToBePaid = entry.pbPasswordEntry
    $PokemonBag.pbDeleteItem(:DATACHIP, costToBePaid) if costToBePaid > 0
    next nil
  }
)

### Password definitions

class BasicPassword
  attr_reader :switch

  def initialize(switch)
    @switch = switch
  end

  def collectStrings
    return [] # Nothing to localize
  end

  def state
    return $game_switches[@switch]
  end

  def on?
    return state
  end

  def off?
    return !state
  end

  def toggle
    $game_switches[@switch] = !$game_switches[@switch]
  end
end

class UserInputPassword < BasicPassword
  attr_reader :variable
  attr_reader :min
  attr_reader :initial
  attr_reader :max
  attr_reader :description

  def initialize(switch, variable, min:, initial:, max:, description:)
    super(switch)
    @variable = variable
    @min = min
    @initial = initial
    @max = max
    @description = description
  end

  def toggle
    super
    if on?
      params = ChooseNumberParams.new
      params.setRange(@min, @max)
      params.setInitialValue(@initial)
      params.setNegativesAllowed(true) if @min < 0 || @max < 0
      $game_variables[variable] = Kernel.pbMessageChooseNumber(pbGetMessage(:PasswordMisc, @description), params)
    end
  end

  def collectStrings
    return [@description]
  end
end

class SetVariablePassword < BasicPassword
  attr_reader :variable
  attr_reader :value

  def initialize(switch, variable, value)
    super(switch)
    @variable = variable
    @value = value
  end

  def toggle
    super
    $game_variables[variable] = value if on?
  end
end

class BasicMessagePassword < BasicPassword
  attr_reader :message

  def initialize(switch, message)
    super(switch)
    @message = message
  end

  def toggle
    super
    Kernel.pbMessage(pbGetMessage(:PasswordMisc, @message)) if on?
  end

  def collectStrings
    return [@message]
  end
end

class ScriptPassword < BasicPassword
  def initialize(switch, script)
    super(switch)
    @script = script
  end

  def toggle
    super
    eval(@script) if on?
  end
end

### Util functions

def pbPasswordComponents(password)
  password = $cache.passwords[password] if password.is_a?(String)
  return [] unless password

  if password.is_a?(BulkPasswordData)
    components = []
    scanning = [] + password.components
    while !scanning.empty?
      scanned = scanning.shift
      scanned = $cache.passwords[scanned] if scanned.is_a?(String)
      next unless scanned

      if scanned.is_a?(BulkPasswordData)
        scanning += scanned.components
      else
        components.push(scanned)
      end
    end
    return components
  else
    return [password]
  end
end

def pbActivePasswords
  passwords = []
  for key, value in $cache.passwords
    next if key.is_a?(Symbol)
    next unless value.is_a?(PasswordData)
    next if passwords.include?(value)
    passwords.push(value) if value.function.on?
  end
  return passwords
end

def pbKnownPasswords
  $Unidata[:knownPasswords] = [] if !$Unidata[:knownPasswords]

  # Migrate older formats
  $Unidata[:knownPasswords].map! { |it| $cache.passwords[it]&.password || it }
  for pass, pw in $cache.passwords
    next if pass.is_a?(Symbol)
    next unless pass == pw.password
    next unless pw.is_a?(PasswordData)

    if pw.function.on?
      $Unidata[:knownPasswords].push(pass)
    end
  end
  $Unidata[:knownPasswords].uniq!

  return $Unidata[:knownPasswords]
end

def addPasswordsUserShouldKnow
  # Hook for games to override
end

def pbIsPasswordKnown?(password)
  components = pbPasswordComponents(password)
  return false if components.empty?
  return pbKnownPasswords.include?(components[0].password) if components.size == 1
  return components.all? { |pass| pbIsPasswordKnown?(pass) }
end

def pbLearnPassword(password)
  components = pbPasswordComponents(password)

  for component in components
    pbKnownPasswords.push(component.password) unless !component || pbKnownPasswords.include?(component.password)
  end
end

### Password menu

def pbTogglePassword(password, item = nil, needsChip = false, isGameStart = false, skipEndMessage: false)
  password_string = password.downcase()

  password = $cache.passwords[password_string]
  if !password
    $game_switches[:PasswordFail] = true
    Kernel.pbMessage(_INTL("That is not a password.")) unless isGameStart
    return false
  end

  passwords = pbPasswordComponents(password)

  if !isGameStart && passwords.any?(&:startOnly)
    Kernel.pbMessage(_INTL("This password cannot be entered anymore."))
    return false
  end

  toggle = true
  turningOff = passwords.all? { |pw| pw.function.on? }

  if !isGameStart && turningOff && passwords.any?(&:cannotDisable)
    Kernel.pbMessage(_INTL("This password cannot be disabled anymore."))
    return false
  end

  if Reborn
    norandbats = !$game_switches[:No_Online_Randbats] && passwords.any? { |pw| pw.disablesOnlineRandBats && pw.function.off? }
    notrades = !$game_switches[:No_Online_Trades] && passwords.any? { |pw| pw.disablesOnlineTrading && pw.function.off? }
    if norandbats || notrades
      message = case true
        when norandbats && notrades then _INTL("This password will permanently disable online random battles and trading for this save file.")
        when norandbats then _INTL("This password will permanently disable online random battles for this save file.")
        else _INTL("This password will permanently disable online trading for this save file.")
      end
      Kernel.pbMessage(message)
      return false unless Kernel.pbConfirmMessage(_INTL("Would you like to continue?"))
    end
  end

  if needsChip
    return false unless Kernel.pbConfirmMessage(_INTL("This will consume a {1}. Do you want to continue?", getItemName(item)))
  elsif item
    Kernel.pbMessage(_INTL("Abusing debug to bypass {1} requirement.", getItemName(item)))
  end

  if passwords.size > 1
    if passwords.any? { |pw| pw.function.off? }
      toggle = false
    elsif turningOff
      return false unless Kernel.pbConfirmMessage(_INTL("This password pack is already fully enabled. Turn it off?"))
    end
  end

  for pw in passwords
    pw.function.toggle if toggle || pw.function.off?
    pbLearnPassword(pw.password)
  end

  unless skipEndMessage
    if turningOff
      if passwords.size > 1
        Kernel.pbMessage(_INTL("Passwords have been disabled."))
      else
        Kernel.pbMessage(_INTL("Password has been disabled."))
      end
    else
      if passwords.size > 1
        Kernel.pbMessage(_INTL("Passwords have been enabled."))
      else
        Kernel.pbMessage(_INTL("Password has been enabled."))
      end
    end
  end
  return true
end

class PasswordEntry
  def PasswordEntry.forGameStart
    return PasswordEntry.new(0, nil, true)
  end

  def initialize(operations, item, isGameStart = false)
    @totalOperations = operations
    @operationsLeft = operations
    @item = item
    @isGameStart = isGameStart
    buildPasswords
  end

  def buildPasswords
    @bulkPasswords = {}
    @passwords = {}

    for pass, pw in $cache.passwords
      next if pass.is_a?(Symbol)
      next unless pass == pw.password
      next unless pbIsPasswordKnown?(pass)

      category = pw.category

      if pw.is_a?(BulkPasswordData)
        @bulkPasswords[category] = [] unless @bulkPasswords[category]
        @bulkPasswords[category].push(pw)
      else
        @passwords[category] = [] unless @passwords[category]
        @passwords[category].push(pw)
      end
    end
  end

  def stateMarker(pw)
    components = pbPasswordComponents(pw)
    anyFalse = false
    anyTrue = false

    for pass in components
      anyFalse = true if pass.function.off?
      anyTrue = true if pass.function.on?
    end

    return '> ' if !anyFalse
    return '    ' if !anyTrue
    return '~ '
  end

  def entryForPasswords(bulklist)
    colortag = (isCurrentWindowskinDark ? ColorTags : LightColorTags)[:Blue2]
    passwordHash = bulklist ? @bulkPasswords : @passwords
    rawCategories = []
    categories = []
    for cat in $cache.passwords[:Ordering]
      next unless passwordHash[cat]
      rawCategories.push(cat)
      categories.push(pbGetMessage(:PasswordCategories, cat))
    end

    unless bulklist
      # Add Manual Entry option
      rawCategories.insert(0, "Manual")
      categories.insert(0, colortag + _INTL("Manual Entry"))
      unless @bulkPasswords.empty?
        # Add Bulk Passwords option
        rawCategories.push("Bulk")
        categories.push(colortag + _INTL("Bulk Passwords"))
      end
    end

    choice = 0
    while choice != -1
      unless bulklist
        # Add Active option
        rawActiveCat, activeCat = "Active", colortag + _INTL("Active")
        passwordHash[rawActiveCat] = pbActivePasswords
        if !passwordHash[rawActiveCat].empty? && !rawCategories.include?(rawActiveCat)
          rawCategories.insert(1, rawActiveCat)
          categories.insert(1, activeCat)
        elsif passwordHash[rawActiveCat].empty? && rawCategories.include?(rawActiveCat)
          rawCategories.delete(rawActiveCat)
          categories.delete(activeCat)
          choice = 0
        end
      end

      if categories.size == 1
        choice = 0
      else
        msg = bulklist ? _INTL("Enter which kind of bulk password?") : _INTL("Enter which kind of password?")
        msg += "\n<o=128>" + _INTL("{1} {2} left.", @operationsLeft, getItemName(@item, plural: @operationsLeft != 1)) if @item
        choice = Kernel.pbMessageAdvanced(msg, categories, -1, nil, choice)
        return true if choice == -1
      end

      if rawCategories[choice] == "Manual"
        passwordEntered = manualEntry
        return true if @isGameStart || (categories.size == 1 && !passwordEntered)
        buildPasswords
        return false
      elsif rawCategories[choice] == "Bulk"
        entryForPasswords(true)
      else
        passwords = []
        commands = []
        helps = []
        for password in passwordHash[rawCategories[choice]]
          passwords.push(password.password)
          commands.push(stateMarker(password) + pbGetMessage(:PasswordNames, password.name))
          helps.push(pbGetMessage(:PasswordDescriptions, password.description))
        end

        command = 0
        while command != -1
          command = Kernel.pbShowCommandsWithHelp(nil, commands, helps, -1, command)
          if command != -1
            wasHoldingCtrl = $DEBUG && Input.press?(Input::CTRL)
            if @item && @operationsLeft <= 0
              unless wasHoldingCtrl
                pbCantSelect
                next
              end
            end

            if pbTogglePassword(passwords[command], @item, @item && !wasHoldingCtrl, @isGameStart) && @item
              @operationsLeft -= 1 unless wasHoldingCtrl
            end

            commands = []
            for password in passwordHash[rawCategories[choice]]
              commands.push(stateMarker(password) + pbGetMessage(:PasswordNames, password.name))
            end
          end
        end
      end

      break if categories.size == 1
    end
    return true
  end

  def manualEntry
    wasHoldingCtrl = $DEBUG && Input.press?(Input::CTRL)
    if @item && @operationsLeft <= 0
      unless wasHoldingCtrl
        pbCantSelect
        return false
      end
    end

    inputstring = pbEnterText(_INTL("Enter password."), 0, 12)
    if !inputstring || inputstring == ""
      $game_switches[:PasswordFail] = true
      return false
    end

    if wasHoldingCtrl && inputstring.downcase == "$debug"
      for pass in $cache.passwords.keys
        next if pass.is_a?(Symbol)
        pbLearnPassword(pass)
      end
      Kernel.pbMessage(_INTL("All passwords learned."))
    else
      if pbTogglePassword(inputstring, @item, @item && !wasHoldingCtrl, @isGameStart) && @item
        @operationsLeft -= 1 unless wasHoldingCtrl
      end
    end
    return true
  end

  def pbCantSelect
    pbPlayBuzzerSE
    msg = _INTL("No {1} available for input.", getItemName(@item))
    msg += "\n<o=128>" + _INTL("(Hold Ctrl to bypass {1} requirement.)", getItemName(@item)) if $DEBUG
    Kernel.pbMessage(msg)
  end

  def pbPasswordEntry
    addPasswordsUserShouldKnow
    $game_switches[:PasswordFail] = false
    loop do
      v = entryForPasswords(false)
      break if v
    end
    runPostPasswordMaintenance
    return @totalOperations - @operationsLeft
  end
end

def runPostPasswordMaintenance
  # Hook for games to override
end

class PokeBattle_Field
  attr_reader :battle
  attr_accessor :effect               # field effect ID
  attr_accessor :data                 # associated field information
  attr_accessor :layer                # order of fields, stacked up from base
  attr_accessor :counter              # counter for certain field triggers
  attr_accessor :counter2             # counter for certain field triggers
  attr_accessor :counter3             # counter for certain field triggers
  attr_accessor :counter4             # counter for certain field triggers
  attr_accessor :counter5             # counter for certain field triggers
  attr_accessor :pledge               # whether a pledge move has been used
  attr_accessor :conversion           # whether conversion has been used
  attr_accessor :duration             # number of turns remaining on a temporary field
  attr_accessor :duration_condition   # condition to still keep remaining on a temporary field
  attr_accessor :permanent_condition  # condition to change a temp field into a permanent field
  attr_accessor :tempFieldIndex       # layer index of the temporary field
  attr_accessor :overlay              # terrain overlay effects seperate from the hard field
  attr_accessor :overlayCounter       # turn timer for overlay effects
  attr_accessor :roll
  attr_accessor :old_counter          # old counter value that shouldn't be overwritten when field returns
  attr_accessor :fieldroll            # memory for RNG roll of certain fields, to hold during move execution
  attr_accessor :overlayroll          # memory for RNG roll of certain overlay, to hold during move execution

  def initialize(battle)
    @battle = battle
    @pledge = nil
    @conversion = nil
    @counter = 0
    # chances are no one except rejuv cave field is ever
    # going to use more than 1 of these but here they are anyway - Fal
    @counter2 = 0
    @counter3 = 0
    @counter4 = 0
    @counter5 = 0
    @duration = 0
    @duration_condition = nil
    @permanent_condition = nil
    @roll = 0
    @tempFieldIndex = nil
    @overlay = nil
    @overlayCounter = 0
    @layer = determineFieldLayers
    @effect = @layer[-1]
    setData
  end

  def setData
    @data = $cache.FEData[@effect]
  end

  def isFieldEffect?
    return false if @effect == :INDOOR || @effect == :INDOORA || @effect == :INDOORB || @effect == :INDOORC || (!Rejuv && (@effect == :CITY || @effect == :CITYNEW))

    return true
  end

  def backup
    return @layer[-2] if @layer[-2]

    return :INDOOR
  end

  def resetFieldVars
    @counter = 0
    @counter2 = 0
    @counter3 = 0
    @counter4 = 0
    @counter5 = 0
  end

  def getRoll(update_roll: false, maximize_roll: false, rollmodifier: 0)
    if @fieldroll
      if @fieldroll[1] != @effect
        raise "Locked in Field roll doesn't match the current field effect!"
      else
        return @fieldroll[0]
      end
    end
    case @effect
      # Sequential rolls
      when :CRYSTALCAVERN
        result = PBStuff::CCROLLS[@roll]
        @roll = (@roll + 1) % PBStuff::CCROLLS.length if update_roll
      when :SHORTCIRCUIT
        result = PBStuff::SHORTCIRCUITROLLS[@roll]
        result = PBStuff::SHORTCIRCUITROLLS.max if maximize_roll
        @roll = (@roll + 1) % PBStuff::SHORTCIRCUITROLLS.length if update_roll
      # Non-sequential (random) rolls
      when :RAINBOW
        result = @battle.getRandomType(:NORMAL)
        result = :QMARKS if !update_roll
      when :NEWWORLD
        result = @battle.getRandomType
        result = :QMARKS if !update_roll
      when :BIGTOP
        if update_roll # normal
          striker = @battle.pbRandom(14)
          striker = striker < 8 ? 13 : 14 if maximize_roll
          striker += rollmodifier
          striker = striker.clamp(0, 14)
          result = PBStuff::BIGTOPROLLS[striker]
        else # average
          strikers = (0...14).to_a
          strikers = [13, 14] if maximize_roll
          strikers.map! { |striker|
            striker += rollmodifier
            striker = striker.clamp(0, 14)
            next PBStuff::BIGTOPROLLS[striker]
          }
          result = strikers.sum.to_f / strikers.length
        end
    end
    @fieldroll = [result, @effect] if update_roll
    return result
  end

  def getOVRoll(update_roll: false, maximize_roll: false, rollmodifier: 0)
    if @overlayroll
      if @overlayroll[1] != @overlay
        raise "Locked in overlay roll doesn't match the current overlay effect!"
      else
        return @overlayroll[0]
      end
    end
    case @overlay
      # Non-sequential (random) rolls
      when :RAINBOW
        result = @battle.getRandomType(:NORMAL)
        result = :QMARKS if !update_roll
    end
    @overlayroll = [result, @overlay] if update_roll
    return result
  end

  def checkPermCondition(battle)
    return if !@permanent_condition
    return if !@permanent_condition.call(battle)

    @duration = 0
    @tempFieldIndex = nil
    @permanent_condition = nil
    @duration_condition = nil
  end

  # FEData hash helpers
  def moveData(movesymbol)
    return @data.fieldmovedata[movesymbol]
  end

  def typeData(type)
    return @data.fieldtypedata[type]
  end

  def fieldChangeData
    return @data.fieldchangeconditions
  end

  def introMessage
    if isFieldEffect?
      return @data.message
    else
      return false
    end
  end

  def buffedStatusMoves
    return @data.statusBuffs
  end

  def nerfedStatusMoves
    return @data.statusNerfs
  end

  def seeds
    return @data.seeddata
  end

  def backdrop
    map_bg = $cache.mapdata[$game_map.map_id].BattleBack
    map_bg = $game_variables[:Forced_BaseField] if $game_variables[:Forced_BaseField] != 0
    related_fe = fieldSymFromGraphic(map_bg)
    if !($game_variables[:AltFieldGraphic].nil? || $game_variables[:AltFieldGraphic] == 0)
      alt_bg = $game_variables[:AltFieldGraphic] # temporary alternate field graphics
      alt_fe = fieldSymFromGraphic(alt_bg)
      return alt_bg if @effect == alt_fe && !alt_bg.nil?
    end
    return map_bg if @effect == related_fe && !map_bg.nil? # alternate field graphics
    return @data.graphic[0] if @effect
    return $cache.FEData[:INDOOR].graphic[0] if map_bg.nil?

    return $cache.mapdata[$game_map.map_id].BattleBack
  end
end

def getFieldName(field)
  return _INTL("No Field") if field == :INDOOR
  return pbGetMessageFromHash(:FieldMessages, $cache.FEData[field].name) if $cache.FEData[field].name
  return ""
end

class PokeBattle_FieldOnline < PokeBattle_Field
  def initialize(field)
    @pledge = nil
    @conversion = nil
    @counter = 0
    @duration = 0
    @roll = 0
    @tempFieldIndex = nil
    # Base field is no field
    @layer = []
    @layer[0] = field
    # Field Effect override from variable
    if $feonline
      @layer.push($feonline)
    end
    @effect = @layer[-1]
    setData
  end

  def backdrop
    return @data.graphic[0] if @effect

    return $cache.FEData[:INDOOR].graphic[0]
  end
end

class PokeBattle_Battle
  def noWeather
    return if @weather == 0
    return if pbCheckGlobalAbility(:TEMPEST)

    if @field.effect == :NEWWORLD
      pbDisplay(_INTL("The weather disappeared into space!"))
      pbEndWeather(showMessage: false)
    elsif @field.effect == :UNDERWATER
      pbDisplay(_INTL("You're too deep to notice the weather!"))
      pbEndWeather(showMessage: false)
    elsif ([:SUPERHEATED, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@field.effect) || (@field.effect == :DRAGONSDEN && Rejuv)) && [:HAIL, :SNOW].include?(@weather)
      pbDisplay(_INTL("The hail melted away!")) if @weather == :HAIL
      pbDisplay(_INTL("The snow melted away!")) if @weather == :SNOW
      pbEndWeather(showMessage: false)
    elsif @field.effect == :INFERNAL && @weather == :RAINDANCE
      pbDisplay(_INTL("The rain evaporated!"))
      pbEndWeather(showMessage: false)
    else
      persistentWeather
    end
  end

  def persistentWeather(endOfRound: false)
    #### Fali - modification so weatherless fields remain so
    return false if @field.effect == :NEWWORLD || @field.effect == :UNDERWATER
    return false if @weather != 0
    return false if @weatherbackup == 0
    return false if @weatherbackup == :RAINDANCE && @field.effect == :INFERNAL
    return false if [:HAIL, :SNOW].include?(@weatherbackup) && ([:SUPERHEATED, :VOLCANIC, :VOLCANICTOP, :INFERNAL].include?(@field.effect) || (@field.effect == :DRAGONSDEN && Rejuv))

    #### DemICE - persistentweather - START
    pbSetWeather(@weatherbackup, -1, showanimation: !endOfRound)
    return true
  end

  def noOverlay
    return if !Overlays || @field.overlay.nil?
    removeOverlay = false
    case @field.effect
      when :NEWWORLD
        pbDisplay(_INTL("The terrain had no solid ground to attach..."))
        removeOverlay = true
      when :UNDERWATER
        pbDisplay(_INTL("The terrain disappeared in the water!"))
        removeOverlay = true
      when @field.overlay
        removeOverlay = true
      when :DARKNESS1, :DARKNESS3
        removeOverlay = true if @field.overlay == :DARKNESS2
      when :CORROSIVEMIST
        removeOverlay = true if @field.overlay == :MISTY
    end
    if removeOverlay
      @field.overlay = nil
      @field.overlayCounter = 0
    end
  end

  def canChangeFE?(newfield = [], ignoreOverlays: false, showMessage: false)
    newfield = Array(newfield)
    if @field.effect == :NEWWORLD
      pbDisplay(_INTL("The terrain had no solid ground to attach...")) if showMessage
      return false
    elsif @field.effect == :UNDERWATER
      pbDisplay(_INTL("The terrain disappeared in the water!")) if showMessage
      return false
    elsif @field.effect == :FROZENDIMENSION
      pbDisplay(_INTL("The frozen dimension remains unchanged.")) if showMessage
      return false
    elsif newfield.include?(@field.effect)
      pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    elsif Overlays && !ignoreOverlays &&
       (newfield.include?(@field.overlay) ||
       (newfield.include?(:MISTY) && @field.effect == :CORROSIVEMIST) ||
       (newfield.include?(:DARKNESS2) && [:DARKNESS1, :DARKNESS3].include?(@field.effect)))
      pbDisplay(_INTL("But it failed!")) if showMessage
      return false
    end
    return true
  end

  def setField(fieldeffect, temp, message, add_on: false, ignoreOverlays: false, changeEffect: nil, basemove: nil, user: nil)
    # fieldeffect = symbol of the field being set
    # temp = number of turns the field persists until reverting to the previous field on the stack; 0 means the field is permanent until broken
    # message = message to be displayed when new field is set, if nil the method will try to determine the message itself, if false no message will be displayed
    # add_on = if true this field layers on top of the current field in the field stack, if temp is greater than 0 this will happen regardless
    # ignoreOverlays = temporary field will be set as a hard field effect, and ignore Overlay implementation if it would apply
    # changeEffect = special code to be run when new field is set
    # basemove and user = move and user that triggered the field change, required by certain changeEffects
    return if @field.effect == fieldeffect

    # Animation
    case fieldeffect
      when :RAINBOW then pbCommonAnimation("RainbowT")
      when :GLITCH then pbCommonAnimation("GlitchT")
    end

    if message == nil
      case fieldeffect
        when :GRASSY then message = _INTL("Grass grew to cover the battlefield!")
        when :MISTY then message = _INTL("Mist swirled around the battlefield!")
        when :ELECTERRAIN then message = _INTL("An electric current ran across the battlefield!")
        when :PSYTERRAIN then message = _INTL("Psychic energy spread across the battlefield!")
      end
    end

    # Setting Overlay instead of Field
    # check if the field to set has an overlay effect, and whether a overlay should be set instead of a full field
    # do not set an overlay if ignoreOverlays is set, or if there is no current fieldeffect (INDOOR)
    if Overlays && $cache.FEData[fieldeffect].overlay && temp > 0 && !ignoreOverlays && (@field.effect != :INDOOR || user&.crested == :RAIKOU)
      @field.overlay = fieldeffect
      temp = 3 + @battle.pbRandom(6) if @field.effect == :DIMENSIONAL
      @field.overlayCounter = temp
      @field.overlayroll = nil
      pbDisplay(message) if message
      priority = setSpeedOrder
      for i in priority
        next if i.isFainted?
        i.pbAbilitiesOnOverlay
        i.pbMimicry
      end
      quarkdriveCheck
      return
    end

    # Save the old Field
    oldfield = @field.effect
    oldfield = @field.layer.pop if temp <= 0 && !add_on

    # Set the new Field
    @field.effect = fieldeffect
    @field.layer.push(fieldeffect)
    if temp > 0
      @field.tempFieldIndex = @field.layer.length - 1 if !@field.tempFieldIndex
      @field.duration = temp
    end
    @field.checkPermCondition(self)

    # Make change effect and message go early in case of waterPollution
    if changeEffect == "@battle.waterPollution"
      eval(changeEffect)
      pbDisplay(message) if message
      message, changeEffect = nil, nil
    end

    # Changes
    @field.resetFieldVars
    @field.setData
    pbChangeBGSprite

    # Message
    pbDisplay(message) if message

    # Change effect
    eval(changeEffect) if changeEffect

    # Check things to be checked on field change
    pbEffectsOnFieldChange(oldfield)
  end

  def breakField(message, changeEffect: nil, basemove: nil, user: nil)
    oldfield = @field.layer.pop
    if Reborn && [:FLOWERGARDEN2, :FLOWERGARDEN3, :FLOWERGARDEN4, :FLOWERGARDEN5].include?(@field.layer[-1])
      @field.layer.pop
      @field.layer.push(:FLOWERGARDEN1) if @field.layer[-1] != :FLOWERGARDEN1
    end
    @field.effect = @field.layer[-1] || :INDOOR
    @field.resetFieldVars
    @field.setData
    pbChangeBGSprite

    pbDisplay(message) if message
    eval(changeEffect) if changeEffect

    pbEffectsOnFieldChange(oldfield)
  end

  def endTempField
    return if !@field.tempFieldIndex

    oldfield = nil
    while @field.layer.length > @field.tempFieldIndex
      oldfield = @field.layer.pop
    end
    if Reborn && [:FLOWERGARDEN2, :FLOWERGARDEN3, :FLOWERGARDEN4, :FLOWERGARDEN5].include?(@field.layer[-1])
      @field.layer.pop
      @field.layer.push(:FLOWERGARDEN1) if @field.layer[-1] != :FLOWERGARDEN1
    end
    @field.tempFieldIndex = nil

    @field.effect = @field.layer[-1] || :INDOOR
    @field.resetFieldVars
    @field.permanent_condition = nil
    @field.duration_condition = nil
    @field.setData
    pbChangeBGSprite

    pbDisplay(getEndTempFieldMessage(oldfield, @field.effect))

    pbEffectsOnFieldChange(oldfield)
  end

  def pbEffectsOnFieldChange(oldfield)
    @state.effects[:Gravity] = 0 if oldfield == :DEEPEARTH && @state.effects[:Gravity] == -1
    pbSetGravity(-1) if @field.effect == :DEEPEARTH
    pbSetWeather(:HAIL, @weatherduration) if @field.effect == :FROZENDIMENSION && @weather == :SNOW
    concertNoise if [:CONCERT3, :CONCERT4].include?(@field.effect)

    @field.fieldroll = nil # field has changed, if this happened mid move the field roll needs to be released

    unless stagesOfSameField?(@field.effect, oldfield)
      priority = setSpeedOrder
      for i in priority
        next if i.isFainted?
        i.pbItemsOnField
        i.pbAbilitiesOnField
        i.pbMimicry
      end
      quarkdriveCheck
    end

    noOverlay if Overlays
    noWeather
    persistentWeather # recheck if no current weather and previous field disallowed the persistent weather effect
  end

  def canEndTempFieldOrOverlay?
    if Overlays
      return !@field.overlay.nil?
    else
      return @field.duration > 0 && @field.permanent_condition.nil?
    end
  end

  def endTempFieldOrOverlay
    return if !canEndTempFieldOrOverlay?

    if Overlays
      removedOverlay = @field.overlay
      @field.overlay = nil
      @field.overlayCounter = 0
      @field.overlayroll = nil
      pbDisplay(getEndTempFieldMessage(removedOverlay, nil))
      priority = setSpeedOrder
      priority.each { |i| i.pbMimicry unless i.isFainted? }
      quarkdriveCheck if removedOverlay == :ELECTERRAIN
    else
      @field.duration = 0
      endTempField
    end
  end

  def getEndTempFieldMessage(oldfield, newfield)
    case oldfield
      when :GRASSY then return _INTL("The grass disappeared from the battlefield.")
      when :MISTY then return _INTL("The mist disappeared from the battlefield.")
      when :ELECTERRAIN then return _INTL("The electricity disappeared from the battlefield.")
      when :PSYTERRAIN then return _INTL("The psychic energy disappeared from the battlefield.") # intentional deviation from canon
      when :RAINBOW then return _INTL("The rainbow disappeared.")
      when *PBFields::DARKNESS then return _INTL("The darkness dissipated.")
      else return _INTL("The terrain returned to normal.") unless [:NEWWORLD, :ELECTERRAIN].include?(newfield)
    end
    case newfield
      when :NEWWORLD then return _INTL("The world broke apart again!")
      when :ELECTERRAIN then return _INTL("The field electrified again!")
    end
  end

  # i don't think we need this but keeping it just in case
  # def getNoField #for when the base graphic isn't blank
  #   return :INDOOR
  #   basefieldbg = $game_map ? $cache.mapdata[$game_map.map_id].BattleBack : ""
  #   basefield = fieldSymFromGraphic(basefieldbg)
  #   basefield = :INDOOR if basefield.nil? || $cache.FEData[basefield].nil?
  #   return basefield
  # end

  def setPledge(moveid, fieldduration)
    previousPledge = @field.pledge
    @field.pledge = moveid

    if previousPledge.nil? || @field.pledge == previousPledge
      pbDisplay(_INTL("The {1} lingers in the air...", getMoveName(@field.pledge)))
      return
    end

    pledgepair = [previousPledge, @field.pledge]
    newfield = getPledgeFieldFromPledgePair(pledgepair)

    if @field.effect == newfield
      if @field.duration <= 0
        pbDisplay(_INTL("The pledges combined!"))
      else
        pbCommonAnimation("RainbowE") if newfield == :RAINBOW
        case newfield
          when :BURNING, :VOLCANIC then pbDisplay(_INTL("The pledges combined and fanned the flames!"))
          when :SWAMP then pbDisplay(_INTL("The pledges combined and reinforced the swamp!"))
          when :RAINBOW then pbDisplay(_INTL("The pledges combined to refresh the rainbow!"))
        end
        @field.duration = fieldduration if @field.duration < fieldduration
      end
    else
      case newfield
        when :BURNING, :VOLCANIC then message = _INTL("The pledges combined and set the field ablaze!")
        when :SWAMP then message = _INTL("The pledges combined and formed a swamp!")
        when :RAINBOW then message = _INTL("The pledges combined to form a rainbow!")
      end
      setField(newfield, fieldduration, message, ignoreOverlays: true)
    end
  end

  def setConversion(moveid, fieldduration)
    previousConversion = @field.conversion
    @field.conversion = moveid

    if previousConversion.nil? || @field.conversion == previousConversion
      pbDisplay(_INTL("Some rogue data remains..."))
      return
    end

    if @field.effect == :GLITCH
      pbCommonAnimation("GlitchE")
      pbDisplay(_INTL("TH~ R0GUE DAa/ta cor$upt?@####"))
      @field.duration = fieldduration if @field.duration < fieldduration
    else
      message = _INTL("TH~ R0GUE DAa/ta cor$upt?@####")
      setField(:GLITCH, fieldduration, message)
    end
  end

  def FE
    return @field.effect
  end

  # overlay shortcut
  def OV
    return @field.overlay
  end

  def shouldApplyFieldChangeDamageBoost(basemove, user)
    fieldmove = @field.moveData(basemove.move)
    return false unless fieldmove

    countersbackup = [@battle.field.counter, @battle.field.counter2, @battle.field.counter3, @battle.field.counter4, @battle.field.counter5]

    conditions = @battle.field.fieldChangeData
    if fieldmove && fieldmove[:counterincrease]
      applyCounterIncrease(fieldmove[:counterincrease][0], fieldmove[:counterincrease][1], fieldmove[:counterincrease][2])
    end

    change = false
    change = true if fieldmove[:fieldchange]
    # don't apply multiplier if conditions to change are not met
    change = false if conditions && conditions[fieldmove[:fieldchange]] && !basemove.runCondition(conditions[fieldmove[:fieldchange]], user)
    # don't apply multiplier if a multistage field changes to a different stage of itself
    change = false if stagesOfSameField?(fieldmove[:fieldchange], @battle.FE)

    # revert counters, this is not the right time to actually increase them because of spread moves in doubles
    @battle.field.counter, @battle.field.counter2, @battle.field.counter3, @battle.field.counter4, @battle.field.counter5 = *countersbackup
    return change
  end

  # returns a boolean whether the maximum was reached
  def applyCounterIncrease(counter, increase, maximum)
    case counter
      when 1 then
        @battle.field.counter += increase
        return @battle.field.counter >= maximum
      when 2 then
        @battle.field.counter2 += increase
        return @battle.field.counter2 >= maximum
      when 3 then
        @battle.field.counter3 += increase
        return @battle.field.counter3 >= maximum
      when 4 then
        @battle.field.counter4 += increase
        return @battle.field.counter4 >= maximum
      when 5 then
        @battle.field.counter5 += increase
        return @battle.field.counter5 >= maximum
    end
  end

  # successFlags is a parameter as certain evals are checking for it, the parameter IS in use
  def fieldEffectAfterMove(basemove, user, successFlags)
    # FIELD TRANSFORMATIONS
    fieldmove = @field.moveData(basemove.move)
    fieldtypes = basemove.typeEffects(basemove.type)
    return if !fieldmove && fieldtypes.empty?

    for subtype in fieldtypes
      if !subtype[:condition]
        eval(subtype[:typeeffect])
      else
        eval(subtype[:typeeffect]) if basemove.runCondition(subtype[:condition], user)
      end
    end
    if fieldmove && fieldmove[:counterincrease]
      unless applyCounterIncrease(fieldmove[:counterincrease][0], fieldmove[:counterincrease][1], fieldmove[:counterincrease][2])
        pbDisplay(pbGetMessageFromHash(:FieldMessages, fieldmove[:counterincrease][3])) unless fieldmove[:counterincrease][3].nil?
      end
    end
    if fieldmove && fieldmove[:moveeffect]
      eval(fieldmove[:moveeffect])
    end
    return if !fieldmove || !fieldmove[:fieldchange]

    change_conditions = @battle.field.fieldChangeData
    if change_conditions[fieldmove[:fieldchange]]
      return if !basemove.runCondition(change_conditions[fieldmove[:fieldchange]], user)
    end

    newfield = fieldmove[:fieldchange]
    newfield = :INDOOR if Rejuv && @field.effect == :ICY && [:WATERSURFACE, :MURKWATERSURFACE, :CAVE].include?(@battle.field.backup)
    if ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 1, 3) && user.ability == :RIPEN &&
       PBFields::FLOWERGARDEN.include?(newfield) && PBFields::FLOWERGARDEN.index(@field.effect) < PBFields::FLOWERGARDEN.index(newfield)
      newfieldmove = $cache.FEData[newfield].fieldmovedata[basemove.move]
      newfield = newfieldmove[:fieldchange]
    end

    message = fieldmove[:changetext] ? pbGetMessageFromHash(:FieldMessages, @field.data.changemessagelist[fieldmove[:changetext] - 1]) : false

    if newfield == :INDOOR
      breakField(message, changeEffect: fieldmove[:changeeffect], basemove: basemove, user: user)
    else
      setField(newfield, 0, message, add_on: fieldmove[:dontchangebackup], changeEffect: fieldmove[:changeeffect], basemove: basemove, user: user)
    end
  end

  # Corrosive Mist & Corrupted Cave
  def mistExplosion(basemove, user)
    bearer = pbFindGlobalAbilityUser(:DAMP)
    if bearer
      pbAbilityBoxAndDisplay(bearer, _INTL("The dampness prevents a complete explosion!"))
      return false
    end

    mons, reductions = [], []
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.isSemiInvul?
      next if i.ability == :FLASHFIRE
      next if i.pbOwnSide.effects[:WideGuard]
      next if i.pbOwnSide.effects[:MatBlock]
      next if i.pbOwnSide.effects[:QuickGuard] && basemove.priorityCheck(user) > 0
      next if i.effects[:Protect]
      next if i.effects[:Commander]

      combustdamage = i.totalhp
      combustdamage = i.totalhp / 2 if @field.effect == :CORRUPTED
      combustdamage -= 1 if (i.effects[:Endure] || i.ability == :STURDY) && @field.effect == :CORROSIVEMIST
      next if combustdamage <= 0

      mons.push(i)
      reductions.push(combustdamage)
    end
    pbReduceBattlersHP(mons, reductions)
    return true
  end

  # Cave
  def caveCollapse(basemove, user)
    if @field.counter == 0
      pbDisplay(_INTL("Bits of rock fell from the crumbling ceiling!"))
      @field.counter += 1
    elsif @field.counter > 0
      @field.counter = 0
      pbDisplay(_INTL("The quake collapsed the ceiling!"))
      $game_variables[:Cave_Collapse] = 1
      mons, reductions = [], []
      priority = setSpeedOrder
      for i in priority
        next if i.isFainted?
        next if [:BULLETPROOF, :ROCKHEAD].include?(i.ability) || Rejuv && i.ability == :EARTHEATER
        next if i.isSemiInvul?
        next if i.pbOwnSide.effects[:WideGuard]
        next if i.pbOwnSide.effects[:MatBlock]
        next if i.pbOwnSide.effects[:QuickGuard] && basemove.priorityCheck(user) > 0
        next if i.effects[:Protect]
        next if i.effects[:Commander]
        if i.isbossmon
          next if i.immunities[:fieldEffectDamage].include?(@battle.FE)
        end

        quakedrop = i.totalhp
        quakedrop -= 1 if i.effects[:Endure] || i.ability == :STURDY || i.ability == :STALWART
        quakedrop /= 2 if [:SHELLARMOR, :BATTLEARMOR, :ARMORTAIL].include?(i.ability)
        quakedrop /= 3 if [:PRISMARMOR, :SOLIDROCK].include?(i.ability)
        next if quakedrop <= 0

        mons.push(i)
        reductions.push(quakedrop)
      end
      pbReduceBattlersHP(mons, reductions)
    end
    return false
  end

  # Mirror
  def mirrorShatter(basemove, user)
    mons, reductions = [], []
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.isSemiInvul?
      next if [:SHELLARMOR, :BATTLEARMOR, :ARMORTAIL].include?(i.ability)
      next if i.pbOwnSide.effects[:WideGuard]
      next if i.pbOwnSide.effects[:MatBlock]
      next if i.pbOwnSide.effects[:QuickGuard] && basemove.priorityCheck(user) > 0
      next if i.effects[:Protect]
      next if i.effects[:Commander]

      shatter = i.totalhp / 2
      next if shatter <= 0

      mons.push(i)
      reductions.push(shatter)
    end
    pbReduceBattlersHP(mons, reductions)
    return true
  end

  # Underwater
  def waterPollution
    @battle.pbDisplay(_INTL("The water was polluted!"))
    mons, reductions = [], []
    priority = setSpeedOrder
    for i in priority
      next if i.isFainted?
      next if i.isSemiInvul?
      next if i.hasType?(:POISON)
      next if i.hasType?(:STEEL)

      toxicdrown = i.totalhp
      next if toxicdrown <= 0

      mons.push(i)
      reductions.push(toxicdrown)
    end
    pbReduceBattlersHP(mons, reductions)
    @battle.field.counter = 0
  end

  # Icy Field
  def iceSpikes
    if ![:WATERSURFACE, :MURKWATERSURFACE].include?(@battle.field.backup)
      spikevar = false
      if @battle.battlers[0].pbOwnSide.effects[:Spikes] < 3
        @battle.battlers[0].pbOwnSide.effects[:Spikes] += 1
        spikevar = true
      end
      if @battle.battlers[1].pbOwnSide.effects[:Spikes] < 3
        @battle.battlers[1].pbOwnSide.effects[:Spikes] += 1
        spikevar = true
      end
      if spikevar
        @battle.pbDisplay(_INTL("The quake broke up the ice into spiky pieces!"))
      end
    end
  end

  # Concert
  def concertNoise(pkmn = nil)
    noisedamage = false
    priority = pkmn ? [pkmn] : setSpeedOrder
    for i in priority
      if i.isSleeping?
        i.pbCureStatus(false) if i.status == :SLEEP
        i.changeAbilityWithEffects(nil, box: false) if i.ability == :COMATOSE
        i.pbReduceHP((i.totalhp / 4.0).floor, true)
        i.pbFaint if i.isFainted?
        noisedamage = true
      end
    end
    @battle.pbDisplay(_INTL("The Concert's noise could wake up even the dead!")) if noisedamage
  end

  # Superheated, Volcanic Top, Ashen Beach
  def fieldAccuracyDrop
    @battle.pbDisplay(_INTL("Steam shot up from the field!")) if @field.effect == :SUPERHEATED || @field.effect == :VOLCANICTOP
    @battle.pbDisplay(_INTL("The ash was stirred up from the ground!")) if @field.effect == :ASHENBEACH && !Rejuv
    @battle.pbDisplay(_INTL("The sand was stirred up from the ground!")) if @field.effect == :ASHENBEACH && Rejuv
    priority = setSpeedOrder
    for battler in priority
      next if battler.isSemiInvul? || battler.effects[:Commander]
      battler.pbChangeStats(PBStats::ACCURACY, -1, nil, nil, abilitycheck: :hide)
    end
  end

  # Volcanic Top
  def eruptionChecker
    @battle.pbDisplay(_INTL("The volcano is going to erupt!")) if !@battle.eruption
    @battle.eruption = true
  end

  def growField(text, user, times = 1)
    if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 1, 4)
      fields = PBFields::FLOWERGARDEN
      message = _INTL("{1} grew the garden!", text)
      times *= 2 if user.ability == :RIPEN
    elsif @battle.ProgressiveFieldCheck(PBFields::CONCERT, 1, 3)
      fields = PBFields::CONCERT
      message = _INTL("{1} is getting the crowd hyped!", text)
    elsif @battle.ProgressiveFieldCheck(PBFields::DARKNESS, 1, 2)
      fields = PBFields::DARKNESS
      message = text
    else
      return
    end

    newindex = fields.index(@battle.FE) + times
    newindex = fields.length - 1 if newindex > fields.length - 1
    newfield = fields[newindex]
    setField(newfield, 0, message, add_on: false)
  end

  def reduceField(times = 1)
    if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 2, 5)
      fields = PBFields::FLOWERGARDEN
      message = _INTL("The garden was cut down!")
    elsif @battle.ProgressiveFieldCheck(PBFields::CONCERT, 2, 4)
      fields = PBFields::CONCERT
      message = _INTL("The crowd is booing!")
    elsif @battle.ProgressiveFieldCheck(PBFields::DARKNESS, 2, 3)
      fields = PBFields::DARKNESS
      message = _INTL("The shadows retreat!")
    else
      return
    end

    newindex = fields.index(@battle.FE) - times
    newindex = 0 if newindex < 0
    newfield = fields[newindex]
    setField(newfield, 0, message, add_on: false)
  end

  # checks whether specific stages of a field with multiple stages is in effect (eg, Flower Garden)
  def ProgressiveFieldCheck(field, startstage = 1, endstage = nil)
    endstage = field.length if endstage.nil?
    for i in startstage - 1...endstage
      return true if @battle.FE == field[i]
    end
    return false
  end

  def getRandomType(except = [])
    except = [except] if except && !except.is_a?(Array)
    types = []
    for j in $cache.types.keys
      types.push(j) if ![:QMARKS, :SHADOW, :STELLAR].include?(j) && !except.include?(j)
    end
    return @battle.sample(types)
  end

  def getMimicryField
    return @field.overlay ? @field.overlay : @field.effect
  end

  def getMimicryType(update_roll: false, no_random: false)
    effect = getMimicryField
    return $cache.FEData[effect].mimicry if no_random
    case effect
      when :INDOOR then return nil
      when :CRYSTALCAVERN, :NEWWORLD then return @field.getRoll(update_roll: update_roll)
      else return $cache.FEData[effect].mimicry
    end
  end

  def getNaturePowerMove
    if Rejuv
      return $cache.FEData[@field.effect]&.naturePower || :TRIATTACK
    else
      return $cache.FEData[getMimicryField]&.naturePower || :TRIATTACK
    end
  end

  def getSecretPowerAnim
    return $cache.FEData[getMimicryField]&.secretPower || :TRIATTACK
  end

  def blockedStarlight?(attacker, weather = nil)
    weather = pbWeather(attacker) if weather.nil?
    return @field.effect == :STARLIGHT && weather != 0 && weather != :STRONGWINDS
  end
end

class PokeBattle_Move
  def runCondition(code, attacker)
    return eval(code)
  end

  def typeEffects(type)
    effects = []
    @battle.field.data.fieldtypedata.each do |key, fieldtype|
      next if !$cache.types[key].nil?
      next if @move == :FAKEMOVE || @move.nil?
      next if !$cache.moves[@move].checkFlag?(key)
      next if !fieldtype[:typeeffect]

      effects.push(fieldtype)
    end

    fieldtype = @battle.field.typeData(type)
    effects.push(fieldtype) if fieldtype && fieldtype[:typeeffect]

    return effects
  end

  def typeFieldMessage(type)
    @battle.field.data.fieldtypedata.each do |key, fieldtype|
      next if !$cache.types[key].nil?
      next if @move == :FAKEMOVE || @move.nil?
      next if !$cache.moves[@move].checkFlag?(key)
      next if !fieldtype[:multtext]

      return @battle.field.data.typemessagelist[fieldtype[:multtext] - 1]
    end

    fieldtype = @battle.field.typeData(type)
    return nil if !fieldtype || !fieldtype[:multtext]

    return @battle.field.data.typemessagelist[fieldtype[:multtext] - 1]
  end

  # returns multiplier value of field boost
  def typeFieldBoost(type, attacker = nil, opponent = nil)
    # Flag-based boosts don't stack with type-based boosts
    mults = []
    @battle.field.data.fieldtypedata.each do |key, fieldtype|
      next if !$cache.types[key].nil?
      next if @move == :FAKEMOVE || @move.nil?
      next if !$cache.moves[@move].checkFlag?(key)
      next if !fieldtype[:mult]
      next if fieldtype[:mult] && @battle.blockedStarlight?(attacker)

      if fieldtype[:condition] && attacker && opponent
        next if !eval(fieldtype[:condition])
      end

      return 0 if fieldtype[:mult] == 0
      mults.push(fieldtype[:mult])
    end

    # Actual type-boosts
    typemult = typeFieldBoostMultiplier(type, attacker, opponent)
    return 0 if typemult == 0
    mults.push(typemult)

    return calculateFieldMultiplier(mults.max)
  end

  def typeFieldBoostMultiplier(type, attacker = nil, opponent = nil)
    fieldtype = @battle.field.typeData(type)
    return 1 if !fieldtype || !fieldtype[:mult]
    return 1 if fieldtype[:mult] && @battle.blockedStarlight?(attacker)
    if fieldtype[:condition] && attacker && opponent
      return 1 if !eval(fieldtype[:condition])
    end
    return fieldtype[:mult]
  end

  def moveFieldMessage
    fieldmove = @battle.field.moveData(@move)
    return nil if !fieldmove || !fieldmove[:multtext]

    return @battle.field.data.movemessagelist[fieldmove[:multtext] - 1]
  end

  def moveFieldBoost(attacker)
    fieldmove = @battle.field.moveData(@move)
    return 1 if !fieldmove || !fieldmove[:mult]
    return 1 if fieldmove[:mult] && @battle.blockedStarlight?(attacker)

    return calculateFieldMultiplier(fieldmove[:mult])
  end

  def calculateFieldMultiplier(multiplier)
    return multiplier if @battle.isOnline?
    return multiplier if multiplier == 0
    if $game_variables[:DifficultyModes] == 1 && !$game_switches[:FieldFrenzy]
      return ((multiplier - 1.0) / 2.0) + 1.0
    elsif $game_variables[:DifficultyModes] != 1 && $game_switches[:FieldFrenzy]
      return ((multiplier - 1.0) * 2.0) + 1.0 if multiplier > 1
      return multiplier / 2.0 if multiplier < 1
    end
    return multiplier
  end

  def isMoveValidOnField?(attacker, showMessage: false)
    type = self.pbType(attacker)
    if self.moveFieldBoost(attacker) == 0
      @battle.pbDisplay(pbGetMessageFromHash(:FieldMessages, self.moveFieldMessage)) if showMessage
      return false
    end
    if !PBStuff::CALLERMOVE.include?(@move) &&  self.typeFieldBoost(type, attacker, nil) == 0
      @battle.pbDisplay(pbGetMessageFromHash(:FieldMessages, self.typeFieldMessage(type))) if showMessage
      return false
    end
    return true
  end

  def typeOverlayMessage(type)
    return nil if !Overlays
    return nil if @battle.OV.nil?

    $cache.FEData[@battle.OV].overlaytypedata do |key, overlaytype|
      next if !$cache.types[key].nil?
      next if @move == :FAKEMOVE || @move.nil?
      next if !$cache.moves[@move].checkFlag?(key)
      next if !overlaytype[:multtext]

      return $cache.FEData[@battle.OV].overlaytypemessagelist[overlaytype[:multtext] - 1]
    end

    overlaytype = $cache.FEData[@battle.OV].overlaytypedata[type]
    return nil if !overlaytype || !overlaytype[:multtext]

    return $cache.FEData[@battle.OV].overlaytypemessagelist[overlaytype[:multtext] - 1]
  end

  def typeOverlayBoost(type, attacker = nil, opponent = nil) # returns multiplier value of overlay boost
    return 1 if !Overlays
    return 1 if @battle.OV.nil?

    # type boost for move flags like soundmove
    mults = []
    $cache.FEData[@battle.OV].overlaytypedata do |key, overlaytype|
      next if !$cache.types[key].nil?
      next if @move == :FAKEMOVE || @move.nil?
      next if !$cache.moves[@move].checkFlag?(key)
      next if !overlaytype[:mult]

      if overlaytype[:condition] && attacker && opponent
        next if !eval(overlaytype[:condition])
      end

      return 0 if overlaytype[:mult] == 0
      mults.push(overlaytype[:mult])
    end

    # Actual type-boosts
    typemult = typeOverlayBoostMultiplier(type, attacker, opponent)
    return 0 if typemult == 0
    mults.push(typemult)

    return calculateFieldMultiplier(mults.max)
  end

  def typeOverlayBoostMultiplier(type, attacker = nil, opponent = nil)
    overlaytype = $cache.FEData[@battle.OV].overlaytypedata[type]
    return 1 if !overlaytype || !overlaytype[:mult]
    if overlaytype[:condition] && attacker && opponent
      return 1 if !eval(overlaytype[:condition])
    end
    return overlaytype[:mult]
  end

  def moveOverlayMessage
    return nil if !Overlays
    return nil if @battle.OV.nil?
    overlaymove = $cache.FEData[@battle.OV].overlaymovedata[@move]
    return nil if !overlaymove || !overlaymove[:multtext]

    return $cache.FEData[@battle.OV].overlaymovemessagelist[overlaymove[:multtext] - 1]
  end

  def moveOverlayBoost
    return 1 if !Overlays
    return 1 if @battle.OV.nil?

    overlaymove = $cache.FEData[@battle.OV].overlaymovedata[@move]
    return 1 if !overlaymove || !overlaymove[:mult]

    return calculateFieldMultiplier(overlaymove[:mult])
  end
end

class PokeBattle_Battler
  def fieldDefenseBoost(attacker, category)
    defmult = 1
    case @battle.FE
      when :MISTY
        defmult *= 1.5 if category == :special && self.hasType?(:FAIRY)
      when :DARKCRYSTALCAVERN
        defmult *= 1.5 if self.hasType?(:DARK) || self.hasType?(:GHOST)
        defmult *= 1.33 if self.ability == :PRISMARMOR
      when :RAINBOW, :CRYSTALCAVERN
        defmult *= 1.33 if self.ability == :PRISMARMOR
      when :DRAGONSDEN
        defmult *= 1.3 if self.hasType?(:DRAGON)
      when :NEWWORLD
        defmult *= 0.9 if self.isAirborne?
      when :SNOWYMOUNTAIN, :ICY
        defmult *= 1.5 if category == :physical && self.hasType?(:ICE) && @battle.pbWeather(attacker) == :HAIL
      when :DESERT
        defmult *= 1.5 if category == :special && self.hasType?(:GROUND)
      when :DIMENSIONAL
        defmult *= 1.5 if self.hasType?(:GHOST)
      when :FROZENDIMENSION
        defmult *= 1.5 if self.hasType?(:GHOST)
        defmult *= 1.2 if self.hasType?(:ICE)
        defmult *= 0.8 if self.hasType?(:FIRE)
      when :DEUXFINALIS
        fieldabilities = [:PURIFYINGSALT, :FAIRYAURA, :AURABREAK, :DARKAURA]
        defmult = 1.3 if (self.hasType?(:DRAGON) || self.hasType?(:NORMAL) || self.hasType?(:DARK) || fieldabilities.include?(self.ability)) && ![:BEADSOFRUIN, :SWORDOFRUIN].include?(attacker&.ability)
        defmult = 1.0 if (@battle.pbWeather(attacker) == :RAINDANCE)
        if attacker
          defmult = 1.0 if @battle.pbCheckSideAbility(:DAMP, attacker, checkMoldBroken: true).any?
        end
      when :DARKNESS2
        defmult *= 1.1 if self.hasType?(:DARK) || self.hasType?(:GHOST)
      when :DARKNESS3
        defmult *= 1.2 if self.hasType?(:DARK) || self.hasType?(:GHOST)
    end
    return defmult
  end

  def burningFieldPassiveDamage?
    return false if isAirborne? || hasType?(:FIRE) || @effects[:AquaRing]
    # Well-Baked Body is handled elsewhere because it prevents the damage but also gives a defense boost.
    return false if [:FLAREBOOST, :MAGMAARMOR, :FLAMEBODY, :FLASHFIRE].include?(@ability)
    return false if [:WATERVEIL, :MAGICGUARD, :HEATPROOF, :WATERBUBBLE].include?(@ability)
    return false if $cache.moves[@effects[:TwoTurnAttack]] && [0xCA, 0xCB].include?($cache.moves[@effects[:TwoTurnAttack]].function) # Dig, Dive

    if self.isbossmon
      return false if self.immunities[:fieldEffectDamage].include?(@battle.FE)
    end
    return true
  end

  def underwaterFieldPassiveDamage?
    return false if hasType?(:WATER)
    return false if [:WATERABSORB, :DRYSKIN, :STORMDRAIN, :SWIFTSWIM, :MAGICGUARD].include?(@ability)
    return false unless PBTypes.typesEff(:WATER, types, inverse: @battle.inverse?).superEffective?

    if self.isbossmon
      return false if self.immunities[:fieldEffectDamage].include?(@battle.FE)
    end
    return true
  end

  def murkyWaterSurfacePassiveDamage?
    return false if hasType?(:STEEL) || hasType?(:POISON)
    return false if [:POISONHEAL, :MAGICGUARD, :WONDERGUARD, :TOXICBOOST, :IMMUNITY, :PASTELVEIL].include?(@ability)
    return false if Rejuv && @ability == :SURGESURFER
    return false if self.crested == :ZANGOOSE

    if self.isbossmon
      return false if self.immunities[:fieldEffectDamage].include?(@battle.FE)
    end
    return true
  end

  def pbNWTypeRoll
    roll = @battle.sample(self.pokemon.pbNWTypeRollTypes)
    display_abil = self.crested == :SILVALLY ? :RKSSYSTEM : self.ability
    @battle.pbShowAbilityBox(self, attrname: getAbilityName(display_abil), crest: false)
    self.changeForm(roll)
    @battle.pbCommonAnimation("TypeRoll", self, nil)
    self.pbUpdate(true)
    @battle.scene.pbChangePokemon(self, self.pokemon)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", self.pbThis, getTypeName(self.type1)))
    @battle.pbHideAbilityBox(self)
  end

  def pbMimicry
    return if self.ability != :MIMICRY

    # Intentionally not using changeType here because Mimicry doesn't remove Forest's Curse / Trick-or-Treat
    mtype = @battle.getMimicryType
    if mtype.nil?
      unless self.type1 == self.pokemon.type1 && self.type2 == self.pokemon.type2
        self.type1 = self.pokemon.type1
        self.type2 = self.pokemon.type2
        @battle.pbAbilityBoxAndDisplay(self, _INTL("{1} returned to its original type!", pbThis))
      end
    else
      unless self.type1 == mtype && (self.type2.nil? || self.type2 == self.type1)
        mtype = @battle.getMimicryType(update_roll: true)
        @battle.field.fieldroll = nil # unlocks fieldroll so the next roll isn't a repeat
        self.type1 = mtype
        self.type2 = nil
        @battle.pbAbilityBoxAndDisplay(self, _INTL("{1}'s type changed to {2}!", pbThis, getTypeName(mtype)))
      end
    end
  end
end

def pulseArceusTypes
  return 19
end

class PokeBattle_Pokemon
  def pbNWTypeRollTypes
    array = (0...pulseArceusTypes).to_a - [9] - [self.form] # exclude qmarks and current form
    array.map! { |i| i + pulseArceusTypes } if (self.species == :ARCEUS && $game_switches[:Pulse_Arceus] && self.trainerID == 00000) # || $DEBUG
    return array
  end
end

def determineFieldLayers
  basefield = $cache.mapdata[$game_map.map_id].BattleBack
  basefield = $game_variables[:Forced_BaseField] if $game_variables[:Forced_BaseField] != 0
  # Base field is no field
  layers = []
  layers[0] = fieldSymFromGraphic(basefield)
  layers[0] = :WATERSURFACE if $PokemonGlobal.surfing
  # layers[0] = :??? if $PokemonGlobal.lavasurfing
  layers[0] = :MURKWATERSURFACE if $game_map.terrain_tag($game_player.x, $game_player.y) == PBTerrain::PokePuddle # Murkwater
  # Field Effect override from variable
  if !$game_variables[:Forced_Field_Effect].nil? && $game_variables[:Forced_Field_Effect] != 0
    layers.push($game_variables[:Forced_Field_Effect])
  end

  if Reborn
    # Password forced / random fields
    fields = randomFields()
    if fields != []
      layers = [fields.sample]
    end
  end

  return layers
end

def getPledgeFieldFromPledgePair(pledgepair)
  newfield = :SWAMP if !pledgepair.include?(:FIREPLEDGE)
  newfield = :RAINBOW if !pledgepair.include?(:GRASSPLEDGE)
  newfield = Rejuv ? :VOLCANIC : :BURNING if !pledgepair.include?(:WATERPLEDGE)
  return newfield
end

def stagesOfSameField?(field1, field2)
  return [PBFields::FLOWERGARDEN, PBFields::CONCERT, PBFields::DARKNESS].any? { |i| i.include?(field1) && i.include?(field2) }
end

# Used both in-battle and in-event
def getPiecesFromParty(party, doublebattle, single_trainer)
  pieces = Array.new(party.length, nil)

  # Queen
  pieces[-1] = :QUEEN

  # Pawns
  sendoutorder = party.find_all { |mon| mon.hp > 0 }
  pawn1, pawn2 = sendoutorder[0], sendoutorder[1]
  pieces[party.index(pawn1)] = :PAWN if pieces[party.index(pawn1)].nil?
  if pawn2 && doublebattle && single_trainer
    pieces[party.index(pawn2)] = :PAWN if pieces[party.index(pawn2)].nil?
  end

  # King
  king_piece = party.sort_by.with_index { |pkmn, i|
    ability = Rejuv && pkmn.ability == :SUPREMEOVERLORD
    item = pkmn.item == :KINGSROCK
    totalhp = pkmn.backupstats ? pkmn.backupstats[PBStats::HP] : pkmn.totalhp
    next [pieces[i].nil? ? 0 : 1, ability ? 0 : 1, item ? 0 : 1, totalhp]
  }.first
  pieces[party.index(king_piece)] = :KING if pieces[party.index(king_piece)].nil?

  # Kinghts / Bishops / Rooks
  party.each_with_index { |pkmn, i|
    next unless pieces[i].nil?

    stats = pkmn.backupstats || pkmn.getStats()
    stats = stats[1..] # All stats minus HP
    maxstat = stats.index(stats.max) + 1
    # If multiple stats are tied for highest, they will be prioritized in this order: Atk > Def > SpA > SpD > Spd
    pieces[i] = case maxstat
      when PBStats::ATTACK, PBStats::SPATK then :BISHOP
      when PBStats::DEFENSE, PBStats::SPDEF then :ROOK
      else :KNIGHT
    end
  }

  return pieces
end

def fieldSymFromGraphic(graphic)
  return :INDOOR if graphic == nil

  $cache.FEData.each { |key, data|
    return key if data.graphic.include?(graphic)
  }
  return :INDOOR
end

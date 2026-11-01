PokeBattle_Battler.class_eval {
  def damageMultipliers()
    atkmult = 1.0
    if [:STARLIGHT, :NEWWORLD].include?(@battle.FE)
      atkmult *= 1.5 if self.ability == :VICTORYSTAR
      atkmult *= 1.5 if self.pbPartner && self.pbPartner.ability == :VICTORYSTAR
    end
    atkmult *= 1.5 if (self.ability == :QUEENLYMAJESTY && [:CHESS, :FAIRYTALE].include?(@battle.FE)) || (@battle.FE == :CHESS && self.piece == :QUEEN)
    atkmult *= 1.5 if self.ability == :LONGREACH && [:MOUNTAIN, :SNOWYMOUNTAIN, :SKY].include?(@battle.FE)
    atkmult *= 1.5 if self.ability == :CORROSION && [:CORROSIVE, :CORROSIVEMIST, :CORRUPTED].include?(@battle.FE)
    atkmult *= [:HAUNTED, :BEWITCHED, :HOLY, :PSYTERRAIN, :DEEPEARTH].include?(@battle.FE) ? 1.5 : 1.3 if self.pbPartner.ability == :POWERSPOT
    if Rejuv && @battle.FE == :CHESS
      atkmult *= 1.2 if [:RECKLESS, :GORILLATACTICS].include?(self.ability)
      atkmult *= 1.2 if self.effects[:Illusion] != nil
      if self.ability == :COMPETITIVE
        frac = (1.0 * self.hp) / (1.0 * self.totalhp)
        multiplier = 1.0
        multiplier += ((1.0 - frac) / 0.8)
        if frac < 0.2
          multiplier = 2.0
        end
        atkmult *= multiplier
      end
    end
    if self.crested == :SPIRITOMB
      allyfainted = self.pbFaintedPokemonCount
      modifier = (allyfainted * 0.2) + 1.0
      atkmult *= modifier
    end
    return atkmult
  end

  def physicalDamageMultipliers()
    atkmult = damageMultipliers
    if self.ability == :TOXICBOOST && (self.status == :POISON || @battle.FE == :CORROSIVEMIST || ([:CORROSIVE, :WASTELAND, :MURKWATERSURFACE].include?(@battle.FE) && !self.isAirborne?))
      atkmult *= @battle.FE == :CORRUPTED ? 2.0 : 1.5
    end
    atkmult *= 1.1 if self.hasWorkingItem(:MUSCLEBAND)
    return atkmult.round(2)
  end

  def specialDamageMultipliers()
    atkmult = damageMultipliers
    atkmult *= (Rejuv && @battle.FE == :ELECTERRAIN) ? 1.5 : 1.3 if self.pbPartner.ability == :BATTERY
    atkmult *= 1.5 if self.ability == :FLAREBOOST && (self.status == :BURN || [:BURNING, :VOLCANIC, :INFERNAL].include?(@battle.FE)) && @battle.FE != :FROZENDIMENSION
    atkmult *= 1.1 if self.hasWorkingItem(:WISEGLASSES)
    return atkmult.round(2)
  end

  def damageReduction()
    defmult = 1.0
    defmult *= 0.5 if self.ability == :MULTISCALE && self.hp == self.totalhp
    defmult *= [:DARKNESS2, :DARKNESS3].include?(@battle.FE) ? 0.33 : 0.5 if self.ability == :SHADOWSHIELD && (@battle.FE == :DIMENSIONAL || self.hp == self.totalhp)
    defmult *= 0.75 if @battle.ProgressiveFieldCheck(PBFields::FLOWERGARDEN, 3, 5) && self.ability == :FLOWERVEIL || (self.pbPartner.ability == :FLOWERVEIL && self.hasType?(:GRASS))
    return defmult
  end

  def physicalDamageReduction()
    defmult = damageReduction
    return defmult.round(2)
  end

  def specialDamageReduction()
    defmult = damageReduction
    defmult *= 0.5 if self.ability == :ICESCALES
    return defmult.round(2)
  end

  def pbCalcAcc()
    accstage = self.stages[PBStats::ACCURACY]
    accuracy = accstage >= 0 ? (accstage + 3) * 100 / 3 : 300 / (3 - accstage)
    accuracy *= 1.67 if @battle.state.effects[:Gravity] != 0
    accuracy *= 1.3 if self.ability == :COMPOUNDEYES
    accuracy *= 1.1 if self.ability == :VICTORYSTAR
    accuracy *= 1.1 if self.pbPartner && self.pbPartner.ability == :VICTORYSTAR
    accuracy *= 1.1 if self.hasWorkingItem(:WIDELENS)
    accuracy *= 0.9 if self.ability == :LONGREACH && [:ROCKY, :FOREST].include?(@battle.FE)
    return accuracy.round
  end

  def pbCalcEva()
    evastage = self.stages[PBStats::EVASION]
    evastage = 0 if self.effects[:Foresight] || self.effects[:MiracleEye]
    evasion = evastage >= 0 ? (evastage + 3) * 100 / 3 : 300 / (3 - evastage)
    evasion *= 1.2 if self.ability == :TANGLEDFEET && self.effects[:Confusion] > 0
    evasion *= 1.2 if self.ability == :SANDVEIL && (@battle.pbWeather(nil) == :SANDSTORM || [:DESERT, :ASHENBEACH].include?(@battle.FE))
    evasion *= 1.2 if self.ability == :SNOWCLOAK && ([:HAIL, :SNOW].include?(@battle.pbWeather(nil)) || [:ICY, :SNOWYMOUNTAIN].include?(@battle.FE))
    evasion *= 1.1 if self.hasWorkingItem(:BRIGHTPOWDER)
    evasion *= 1.1 if self.hasWorkingItem(:LAXINCENSE)
    return evasion.round
  end

  def pbCalcCrit()
    c = 0
    c += self.effects[:FocusEnergy]
    c += 1 if self.ability == :SUPERLUCK
    c += 2 if self.hasWorkingItem(:STICK) && [:FARFETCHD, :SIRFETCHD].include?(self.species)
    c += 2 if self.hasWorkingItem(:LUCKYPUNCH) && self.species == :CHANSEY
    c += 1 if self.hasWorkingItem(:RAZORCLAW)
    c += 1 if self.hasWorkingItem(:SCOPELENS)
    c += 1 if self.crested == :FEAROW
    c += self.stages[PBStats::EVASION].clamp(0, 6) + self.stages[PBStats::ACCURACY].clamp(0, 6) if @battle.FE == :MIRROR
    return c.clamp(0, 3)
  end

  def pbGetBaseStatInspect(stat)
    stats = self.effects[:ShownBaseStats] || self.pokemon.baseStats
    # pokemon must be used rather than battler species/form for Castform Crest etc
    return stats[stat]
  end

  def pbGetRawStat(stat)
    return case stat
      when PBStats::ATTACK then self.attack
      when PBStats::DEFENSE then self.defense
      when PBStats::SPATK then self.spatk
      when PBStats::SPDEF then self.spdef
      when PBStats::SPEED then self.speed
      when PBStats::ACCURACY then 100
      when PBStats::EVASION then 100
      else nil
    end
  end

  def pbGetEffStatInspect(stat)
    return case stat
      when PBStats::ATTACK then pbAttack()
      when PBStats::DEFENSE then pbDefense()
      when PBStats::SPATK then pbSpecialAttack()
      when PBStats::SPDEF then pbSpecialDefense()
      when PBStats::SPEED then pbSpeed()
      when PBStats::ACCURACY then pbCalcAcc()
      when PBStats::EVASION then pbCalcEva()
      else nil
    end
  end
}

def pbShowBattleStats(chosenindex, currentindex = nil)
  chosenindex ^= 2 if @battle.battlers[chosenindex].isFainted? || chosenindex == currentindex # Change to partner
  pkmn = @battle.battlers[chosenindex]
  return if pkmn.isFainted?
  return pbInspectText(pkmn) if pkmn.inspectText

  debug = $DEBUG && Input.press?(Input::CTRL)
  colors = Reborn || isCurrentWindowskinDark ? ColorTags : LightColorTags
  shownmon = pkmn.effects[:Illusion] && !(@battle.pbOwnedByPlayer?(pkmn.index) || @battle.pbOwnedByAIPartner?(pkmn.index)) ? pkmn.effects[:Illusion] : pkmn
  shownmon = pkmn.effects[:clearDisguise] if pkmn.effects[:clearDisguise]
  unknownPulse = isUnknownPulse?(shownmon.species, shownmon.form) # Should account for Transform since base stats do too
  opponentMon = @battle.pbIsOpposing?(pkmn.index)
  qmarks = colors[:Gray2] + "???" + "</c3>"
  report = []
  battEff = []
  delayEff = []
  sideEff = []
  trainer = @battle.pbGetOwner(pkmn.index)

  ### Basic battler info
  # Types
  basetypes = [shownmon.type1, shownmon.type2].filter{ |t| !t.nil? }.uniq
  report.push(_INTL("Typing: ") + (unknownPulse ? qmarks : typeIcons(*basetypes)))
  report.push(_INTL("Added: ") + typeIcons(pkmn.effects[:TemporaryType])) if pkmn.effects[:TemporaryType]
  if pkmn.teraTypeEffect
    if trainer&.name == "M2"
      teratypestring = _INTL("Archetype Type: ")
      pkmn.teraTypeEffect.each do |teratype|
        teratypestring += typeIcons(teratype)
      end
      report.push(teratypestring)
    elsif trainer&.name == "Madame Shogun"
      teratypestring = _INTL("Jurisdiction: ")
      pkmn.teraTypeEffect.each do |teratype|
        teratypestring += typeIcons(teratype)
      end
      report.push(teratypestring)
    else
      teratypestring = _INTL("Type Attributes: ")
      pkmn.teraTypeEffect.each do |teratype|
        teratypestring += typeIcons(teratype)
      end
      report.push(teratypestring)
    end
  end
  report.push(_INTL("Reflected: ") + typeIcons(*pkmn.effects[:ReflectorTypes])) if pkmn.effects[:ReflectorTypes].any?
  report.push(_INTL("Shadow: ") + typeIcons(:SHADOW)) if (pkmn.isShadow? rescue false)
  # Databox contents for Blindstep
  if $game_switches[:Blindstep]
    report.push(_INTL("Species: {1}", getMonName(shownmon.species, shownmon.form)))
    if shownmon.pokemon.isPulse? || shownmon.pokemon.isRift? || shownmon.pokemon.isPerfection? || shownmon.isMega? || shownmon.isPrimal? || shownmon.isUltra? || shownmon.isTerastallized?
      form = shownmon.pokemon.getFormName
      form = form.gsub(/\b(?: Form| Forme)\b/, '')
      report.push(_INTL("Form: {1}", form))
    end
    if pkmn.isWildPokemon?
      ownstr = case shownmon.ownedstate
        when 2 then _INTL("Owned species and form")
        when 1 then _INTL("Owned species")
        else _INTL("Not owned")
      end
      report.push(ownstr)
    end
    report.push(_INTL("Gender: {1}", genderName(shownmon.gender))) unless shownmon.isGenderless?
    report.push(_INTL("Level: {1}", pkmn.level))
    report.push(_INTL("Shiny: {1}", shownmon.pokemon.isShiny? ? _INTL("Yes") : _INTL("No")))
    status = case pkmn.status
      when :SLEEP then _INTL("Asleep")
      when :FROZEN then _INTL("Frozen")
      when :BURN then _INTL("Burned")
      when :PARALYSIS then _INTL("Paralyzed")
      when :POISON then _INTL("Poisoned")
      when :PETRIFIED then _INTL("Petrified")
      else nil
    end
    report.push(_INTL("Status: {1}", status)) if status
  end

  ### Battler stats
  boostedcolor, loweredcolor = colors[:Green2], colors[:Red]
  showStages = Rejuv || $game_switches[:Blindstep]

  # Remaining HP
  hpstring = getStatName(0, :desc) + ": "
  hpstring += ((pkmn.hp / pkmn.totalhp.to_f * 100).round(1)).to_s + "%"
  hpstring += " (#{pkmn.hp}/#{pkmn.totalhp})" if (@battle.doublebattle && !opponentMon) || (debug && opponentMon)
  report.push(hpstring)

  # Base HP
  if !Desolation && opponentMon && !debug
    basehpstring = _INTL("Base {1}", getStatName(PBStats::HP, :desc)) + ": "
    statval = unknownPulse ? qmarks : shownmon.pbGetBaseStatInspect(PBStats::HP).to_s
    basehpstring += statval
    basehpstring += "  " + ("\u2007" * 2) if showStages
    report.push(basehpstring)
  end

  # Atk / Def / SpA / SpD / Spe / Acc / Eva
  if !Desolation || !opponentMon || debug || $game_switches[:Blindstep]
    for stat in PBStats::All
      if !opponentMon || debug || [6, 7].include?(stat)
        statstring = getStatName(stat, :desc) + ": "
        rawstat = pkmn.pbGetRawStat(stat)
        effstat = pkmn.pbGetEffStatInspect(stat)
        statval = effstat.to_s
        statval += "%" if [6, 7].include?(stat)
        statval = (effstat > rawstat ? boostedcolor : loweredcolor) + statval + "</c3>" if effstat != rawstat
        statstring += statval
      else
        statstring = _INTL("Base {1}", getStatName(stat, :desc)) + ": "
        statval = unknownPulse ? qmarks : shownmon.pbGetBaseStatInspect(stat).to_s
        statstring += statval
      end
      if showStages
        usedstat = stat
        usedstat = PBStats::SPEED if pkmn.crested == :DEDENNE && [PBStats::ATTACK].include?(stat)
        usedstat = PBStats::DEFENSE if pkmn.crested == :CLAYDOL && stat == PBStats::SPATK
        stage = pkmn.stages[usedstat]
        stagestr = sprintf("%+d", stage)
        stagestr = (stage > 0 ? boostedcolor : loweredcolor) + stagestr + "</c3>" if stage != 0
        statstring += "  " + stagestr
      end
      report.push(statstring)
    end
  end

  # Crit rate
  critstring = _INTL("Crit. Rate") + ": "
  critstage = pkmn.pbCalcCrit()
  critrate = case true
    when critstage == 0 then 4.2
    when critstage == 1 then 12.5
    when critstage == 2 then 50
    else 100
  end
  critrate = critrate.to_s + "%"
  critrate = boostedcolor + critrate + "</c3>" if critstage > 0
  critstring += critrate
  critstring += "  +" + critstage.to_s + "/3"
  report.push(critstring)

  ### Other battler info
  if !@battle.pbOwnedByPlayer?(pkmn.index)
    # Moves
    if @battle.pbOwnedByAIPartner?(pkmn.index)
      # player should have access to partner moves
      moves = pkmn.moves
      report.push(_INTL("Moves Remaining:"))
    elsif debug
      # debug mode shows all moves
      moves = pkmn.moves
      report.push(_INTL("All Moves (Debug):"))
    else
      # otherwise, only show revealed moves
      moves = @battle.ai.getAIMemory(pkmn, inspecting: true)
      report.push(_INTL("Revealed Moves:")) if moves.length > 0
      if pkmn.effects[:clearDisguise]
        moves.map! {|move|
          realmoveindex = pkmn.moves.find_index { |thismove| thismove.move == move.move }

          move = pkmn.effects[:clearDisguise].moves[realmoveindex]
        }
      end
    end
    for move in moves
      report.push("  " + _INTL("{1}: {2}/{3} PP", move.name, move.pp, move.totalpp))
    end
    if debug
      # IVs / EVs
      ivstr = pkmn.iv.uniq.size == 1 ? _INTL("All {1}", pkmn.iv[0]) : pkmn.iv.map{ |i| i.to_s }.join("/")
      evstr = pkmn.ev.uniq.size == 1 ? _INTL("All {1}", pkmn.ev[0]) : pkmn.ev.map{ |i| i.to_s }.join("/")
      report.push(_INTL("IVs") + ": " + ivstr)
      report.push(_INTL("EVs") + ": " + evstr)
      # Item
      report.push(_INTL("Item: {1}", getItemName(pkmn.item))) unless pkmn.item.nil?
    end
  end
  # Ability
  if !opponentMon || debug
    report.push(_INTL("Ability: {1}", pkmn.ability.nil? ? "Ability Negated" : getAbilityName(pkmn.ability)))
  end
  # Chess Piece
  report.push(_INTL("Chess Piece: {1}", getChessPieceName(pkmn.piece))) if @battle.FE == :CHESS
  # Status info
  statusicon = sprintf("<img=Graphics/Pictures/Party/status%s>", pkmn.status)
  if pkmn.status == :POISON && pkmn.statusCount > 0
    fraction = [15, pkmn.effects[:Toxic] + 1].min / 16.0
    report.push(_INTL("Next {1} Dmg: {2}%", statusicon, (fraction * 100).round(1)))
  end
  report.push(_INTL("{1} Turns: {2}", statusicon, pkmn.permeffs[:SleptTurns])) if pkmn.permeffs[:SleptTurns]
  report.push(_INTL("{1} Turns: {2}", statusicon, pkmn.statusCount)) if pkmn.status == :FROZEN && Gen >= Champs

  ### Battler effects
  battEff.push(_INTL("Wonder Room Stat Swap")) if pkmn.wonderroom == true
  battEff.push(_INTL("Slow Start: {1} turns", (5 - pkmn.effects[:SlowStart]))) if pkmn.ability == :SLOWSTART && pkmn.effects[:SlowStart] < 5 && @battle.FE != :DEEPEARTH
  battEff.push(_INTL("Throat Chop: {1} turns", pkmn.effects[:ThroatChop])) if pkmn.effects[:ThroatChop] != 0
  battEff.push(_INTL("Unburdened")) if pkmn.unburdened && pkmn.ability == :UNBURDEN && !opponentMon
  battEff.push(_INTL("Fallen allies: {1}", pkmn.effects[:SupremeOverlord])) if pkmn.ability == :SUPREMEOVERLORD && pkmn.effects[:SupremeOverlord] > 0
  battEff.push(_INTL("Speed Swap")) if pkmn.effects[:SpeedSwap] != 0
  battEff.push(_INTL("Burn Up")) if pkmn.effects[:BurnUp]
  battEff.push(_INTL("Double Shock")) if pkmn.effects[:DoubleShock]
  battEff.push(_INTL("Uproar: {1} turns", pkmn.effects[:Uproar])) if pkmn.effects[:Uproar] != 0
  battEff.push(_INTL("Truant")) if pkmn.effects[:Truant] && pkmn.ability == :TRUANT && !opponentMon
  battEff.push(_INTL("Torment")) if pkmn.effects[:Torment]
  battEff.push(_INTL("Miracle Eye")) if pkmn.effects[:MiracleEye]
  battEff.push(_INTL("Minimized")) if pkmn.effects[:Minimize]
  battEff.push(_INTL("Recharging")) if pkmn.effects[:HyperBeam] != 0
  battEff.push(_INTL("Fury Cutter: +{1}", pkmn.effects[:FuryCutter])) if pkmn.effects[:FuryCutter] != 0
  battEff.push(_INTL("Mean Look")) if pkmn.effects[:MeanLook] >= 0
  battEff.push(_INTL("Foresight")) if pkmn.effects[:Foresight]
  battEff.push(_INTL("Follow Me")) if pkmn.effects[:FollowMe]
  battEff.push(_INTL("Rage Powder")) if pkmn.effects[:RagePowder]
  battEff.push(_INTL("Flash Fire")) if pkmn.effects[:FlashFire]
  battEff.push(_INTL("Perishing: {1} turns", pkmn.effects[:PerishSong])) if pkmn.effects[:PerishSong] > 0
  battEff.push(_INTL("Malicious Moth: {1} turns", pkmn.effects[:MaliciousMoth])) if pkmn.effects[:MaliciousMoth] > 0
  if pkmn.effects[:FutureSight] > 0
    movename = getMoveName(PBStuff::FUTUREATTACKS[pkmn.effects[:FutureSightMove]])
    battEff.push(_INTL("{1}: {2} turns", movename, pkmn.effects[:FutureSight]))
  end
  battEff.push(_INTL("Leech Seed")) if pkmn.effects[:LeechSeed] >= 0
  battEff.push(_INTL("No Ability")) if pkmn.effects[:GastroAcid]
  battEff.push(_INTL("Curse")) if pkmn.effects[:Curse]
  battEff.push(_INTL("Salt Cure")) if pkmn.effects[:SaltCure]
  battEff.push(_INTL("Nightmare")) if pkmn.effects[:Nightmare]
  battEff.push(_INTL("Lock-On: {1} turns", pkmn.effects[:LockOn])) if pkmn.effects[:LockOn] > 0
  battEff.push(_INTL("Lock-On Target: {1}", @battle.battlers[pkmn.effects[:LockOnTarget]].name)) if pkmn.effects[:LockOnTarget] != -1
  battEff.push(_INTL("Confused")) if pkmn.effects[:Confusion] != 0
  battEff.push(_INTL("Aqua Ring")) if pkmn.effects[:AquaRing]
  battEff.push(_INTL("Ingrain")) if pkmn.effects[:Ingrain]
  battEff.push(_INTL("Charged Up")) if pkmn.effects[:Charge] > 0
  battEff.push(_INTL("Power Trick")) if pkmn.effects[:PowerTrick]
  battEff.push(_INTL("Smacked Down")) if pkmn.effects[:SmackDown]
  battEff.push(_INTL("Sheltered")) if pkmn.effects[:Shelter]
  battEff.push(_INTL("Octolock")) if pkmn.effects[:Octolock] >= 0
  battEff.push(_INTL("Quark Drive: {1}", getStatName(pkmn.effects[:Quarkdrive][0]))) if pkmn.effects[:Quarkdrive][0] != 0 && pkmn.ability == :QUARKDRIVE
  battEff.push(_INTL("Protosynthesis: {1}", getStatName(pkmn.effects[:Protosynthesis][0]))) if pkmn.effects[:Protosynthesis][0] != 0 && pkmn.ability == :PROTOSYNTHESIS
  battEff.push(_INTL("Syrup Bomb: {1} turns", pkmn.effects[:SyrupBombTurns])) if pkmn.effects[:SyrupBombTurns] > 0
  battEff.push(_INTL("Cud Chewing")) if pkmn.effects[:CudChewBerry] != nil && !opponentMon
  battEff.push(_INTL("Air Balloon")) if pkmn.hasWorkingItem(:AIRBALLOON)
  lastmove = pkmn.lastMoveUsed.is_a?(Symbol) ? $cache.moves[pkmn.lastMoveUsed]&.name : nil
  battEff.push(_INTL("Metronome: {1}, {2}x", lastmove, [1.0 + pkmn.effects[:Metronome] * 0.2, 2.0].min)) if pkmn.hasWorkingItem(:METRONOME) && lastmove != nil && !opponentMon
  battEff.push(_INTL("Magnet Rise: {1} turns", pkmn.effects[:MagnetRise])) if pkmn.effects[:MagnetRise] != 0 && pkmn.crested != :PROBOPASS
  if pkmn.crested == :PROBOPASS
    battEff.push(_INTL("Magnet Rise: Permanent", pkmn.effects[:MagnetRise])) if pkmn.effects[:MagnetRise] != 0
  else
    battEff.push(_INTL("Magnet Rise: {1} turns", pkmn.effects[:MagnetRise])) if pkmn.effects[:MagnetRise] != 0
  end
  battEff.push(_INTL("Telekinesis: {1} turns", pkmn.effects[:Telekinesis])) if pkmn.effects[:Telekinesis] != 0
  battEff.push(_INTL("Glaive Rush")) if pkmn.effects[:GlaiveRush]
  battEff.push(_INTL("Heal Block: {1} turns", pkmn.effects[:HealBlock])) if pkmn.effects[:HealBlock] != 0
  battEff.push(_INTL("Embargo: {1} turns", pkmn.effects[:Embargo])) if pkmn.effects[:Embargo] != 0
  battEff.push(_INTL("Disable: {1} turns", pkmn.effects[:Disable])) if pkmn.effects[:Disable] != 0
  battEff.push(_INTL("Encore: {1} turns", pkmn.effects[:Encore])) if pkmn.effects[:Encore] != 0
  battEff.push(_INTL("Taunt: {1} turns", pkmn.effects[:Taunt])) if pkmn.effects[:Taunt] != 0
  battEff.push(_INTL("Infatuated with {1}", @battle.battlers[pkmn.effects[:Attract]].name)) if pkmn.effects[:Attract] >= 0
  battEff.push(_INTL("Lifeblood Counter: {1} turns", pkmn.permeffs[:LifeBlood][:turncount])) if pkmn.permeffs[:LifeBlood]
  report.push(_INTL("Battler Effects:")) unless battEff.empty?
  battEff.each { |string| report.push("  " + string) }

  ### Delayed boss/trainer effects
  # Boss
  if pkmn.bossDelayList
    delaylist = pkmn.bossDelayList
    delayregister = $cache.bosses[pkmn.pokemon.bossID].delayRegister
    for i in delaylist
      j = i[0]
      effectname = delayregister[j][:name] || j
      delayEff.push(_INTL("{1}: {2} turns", effectname, i[1]))
      delayEff.push(delayregister[j][:description]) if delayregister[j][:description]
      delayEff.push(delayregister[j][:conditionals]) if delayregister[j][:conditionals]
    end
  end
  # Trainer
  if trainer&.delayList
    delaylist = trainer.delayList
    delayregister = trainer.delayRegister
    for i in delaylist
      j = i[0]
      effectname = delayregister[j][:name] || j
      delayEff.push(_INTL("{1}: {2} turns", effectname, i[1]))
      delayEff.push(delayregister[j][:description]) if delayregister[j][:description]
      delayEff.push(delayregister[j][:conditionals]) if delayregister[j][:conditionals]
    end
  end
  report.push(_INTL("Delayed Effects:")) unless delayEff.empty?
  delayEff.each { |string| report.push("  " + string) }

  ### Side effects
  sideEff.push(_INTL("Tailwind: {1} turns", pkmn.pbOwnSide.effects[:Tailwind])) if pkmn.pbOwnSide.effects[:Tailwind] > 0
  sideEff.push(_INTL("Reflect: {1} turns", pkmn.pbOwnSide.effects[:Reflect])) if pkmn.pbOwnSide.effects[:Reflect] > 0
  sideEff.push(_INTL("Light Screen: {1} turns", pkmn.pbOwnSide.effects[:LightScreen])) if pkmn.pbOwnSide.effects[:LightScreen] > 0
  sideEff.push(_INTL("Aurora Veil: {1} turns", pkmn.pbOwnSide.effects[:AuroraVeil])) if pkmn.pbOwnSide.effects[:AuroraVeil] > 0
  sideEff.push(_INTL("Arenite Wall: {1} turns", pkmn.pbOwnSide.effects[:AreniteWall])) if pkmn.pbOwnSide.effects[:AreniteWall] > 0
  sideEff.push(_INTL("Safeguard: {1} turns", pkmn.pbOwnSide.effects[:Safeguard])) if pkmn.pbOwnSide.effects[:Safeguard] > 0
  sideEff.push(_INTL("Lucky Chant: {1} turns", pkmn.pbOwnSide.effects[:LuckyChant])) if pkmn.pbOwnSide.effects[:LuckyChant] > 0
  sideEff.push(_INTL("Mist: {1} turns", pkmn.pbOwnSide.effects[:Mist])) if pkmn.pbOwnSide.effects[:Mist] > 0
  sideEff.push(_INTL("Spikes: {1} layers", pkmn.pbOwnSide.effects[:Spikes])) if pkmn.pbOwnSide.effects[:Spikes] > 0
  sideEff.push(_INTL("Toxic Spikes: {1} layers", pkmn.pbOwnSide.effects[:ToxicSpikes])) if pkmn.pbOwnSide.effects[:ToxicSpikes] > 0
  sideEff.push(_INTL("Stealth Rock")) if pkmn.pbOwnSide.effects[:StealthRock]
  sideEff.push(_INTL("Sticky Web")) if pkmn.pbOwnSide.effects[:StickyWeb]

  report.push(_INTL("Side Effects:")) unless sideEff.empty?
  sideEff.each { |string| report.push("  " + string) }

  cutoff = report.length - 1 # Use different color for global effect labels

  ### Global effects
  report.push(_INTL("Echoed Voice: +{1}", @battle.echoedVoice)) if @battle.echoedVoice != 0
  report.push(_INTL("Water Sport: {1} turns", @battle.state.effects[:WaterSport])) if @battle.state.effects[:WaterSport] > 0
  report.push(_INTL("Mud Sport: {1} turns", @battle.state.effects[:MudSport])) if @battle.state.effects[:MudSport] > 0
  report.push(_INTL("Trick Room: {1} turns", @battle.state.effects[:TrickRoom])) if @battle.state.effects[:TrickRoom] > 0
  report.push(_INTL("Wonder Room: {1} turns", @battle.state.effects[:WonderRoom])) if @battle.state.effects[:WonderRoom] > 0
  report.push(_INTL("Magic Room: {1} turns", @battle.state.effects[:MagicRoom])) if @battle.state.effects[:MagicRoom] > 0
  if @battle.state.effects[:Gravity] != 0
    duration = @battle.state.effects[:Gravity] < 0 ? _INTL("Permanent") : _INTL("{1} turns", @battle.state.effects[:Gravity])
    report.push(_INTL("Gravity: {1}", duration))
  end
  weather = case @battle.weather
    when :RAINDANCE then @battle.state.effects[:HeavyRain] ? _INTL("Torrential Rain") : _INTL("Rain")
    when :SUNNYDAY then @battle.state.effects[:HarshSunlight] ? _INTL("Scorching Sun") : _INTL("Sun")
    when :SANDSTORM then _INTL("Sandstorm")
    when :HAIL then @battle.state.effects[:NeverMeltIce] ? _INTL("Nevermelting Hail") : _INTL("Hail")
    when :SNOW then @battle.state.effects[:NeverMeltIce] ? _INTL("Nevermelting Snow") : _INTL("Snow")
    when :STRONGWINDS then _INTL("Strong Winds")
    when :SHADOWSKY then _INTL("Shadow Sky")
    else nil
  end
  if weather
    report.push(_INTL("Weather: {1}", weather))
    duration = @battle.weatherduration < 0 ? _INTL("Permanent") : _INTL("{1} turns", @battle.weatherduration)
    report.push("  " + _INTL("Duration: {1}", duration))
  end
  # report.push(_INTL("Altered Field: {1} turns",@battle.state.effects[:Terrain])) if @battle.state.effects[:Terrain]>0
  # report.push(_INTL("Messed up Field: {1} turns",@battle.state.effects[:Splintered])) if @battle.state.effects[:Splintered]>0
  if @battle.OV
    report.push(_INTL("Overlay: {1}", getFieldName(@battle.OV)))
    duration = _INTL("{1} turns", @battle.field.overlayCounter)
    report.push("  " + _INTL("Duration: {1}", duration))
  end
  report.push(_INTL("Field: {1}", getFieldName(@battle.FE)))
  if @battle.field.duration > 0
    duration = _INTL("{1} turns", @battle.field.duration)
    report.push("  " + _INTL("Duration: {1}", duration))
  end
  [PBFields::FLOWERGARDEN, PBFields::CONCERT, PBFields::DARKNESS].each { |fields|
    report.push("  " + _INTL("Stage: {1}", fields.index(@battle.FE) + 1)) if fields.include?(@battle.FE)
  }
  if [:CRYSTALCAVERN, :SHORTCIRCUIT].include?(@battle.FE)
    maxroll = @battle.FE == :SHORTCIRCUIT && @battle.OV == :ELECTERRAIN ? true : false
    roll = @battle.field.getRoll(maximize_roll: maxroll)
    roll = getTypeName(roll) if @battle.FE == :CRYSTALCAVERN
    roll = roll.to_s + "x" if @battle.FE == :SHORTCIRCUIT
    report.push("  " + _INTL("Next Roll: {1}", roll))
  end
  if @battle.field.layer.length > 1
    sublayer = @battle.field.layer[-2]
    report.push(_INTL("Sub-layer: {1}", getFieldName(sublayer))) if sublayer && sublayer != :INDOOR && !stagesOfSameField?(sublayer, @battle.FE)
  end

  # Add colors and right alignment tags
  report.map!.with_index { |string, i|
    color = i > cutoff ? colors[:Magenta] : colors[:Blue2]
    tags = string.start_with?(" ") ? ["", ""] : [color, "</c3>"]
    next tags[0] + string.gsub(": ", ":#{tags[1]} <r>")
  }

  # Draw party preview
  unless pkmn.isWildPokemon?
    drawPartyPreview(pkmn.index)
    lastitem = _INTL("Select for Party Preview")
    report.push(lastitem) if $game_switches[:Blindstep]
  end

  # Create message window and handle controls
  fieldnotes = readableFieldNotes()
  bossnotes = readableBossNotes(@battle)

  tts("", true) # Interrupt any ongoing message when opening Inspect

  message = _INTL("Inspecting {1}:", $game_switches[:Blindstep] ? pkmn.ttsname : pkmn.name)
  if (pkmn.isbossmon || pkmn.issosmon) && !$game_switches[:Blindstep]
    genderstr = shownmon.isGenderless? ? "" : colors[genderColor(shownmon.gender)] + genderSign(shownmon.gender) + "</c3>, "
    message += "<r>" + genderstr + _INTL("Lv. {1}", pkmn.level) # Gender/Level (need to be shown here for boss/SOS mons as they can't be in the databoxes)
  end
  message += "\n<o=128>" + _INTL("Press {1} again for {2}.", opponentMon ? "W" : "Q", pkmn.pbPartner.name) unless pkmn.pbPartner.isFainted?

  @sprites["msgwindow"] = Kernel.pbCreateMessageWindow
  @sprites["msgwindow"].setSkin("Graphics/Windowskins/inspectskin_full") if Reborn
  ret = Kernel.pbMessageDisplay(
    @sprites["msgwindow"], message, false,
    proc { |msgwindow|
      next pbShowInspect(msgwindow, report, pkmn.index)
    }
  )

  pbEndInspect(pkmn.index)

  case ret
  when :Self
    pbShowBattleStats(opponentMon ? pkmn.index ^ 1 : pkmn.index, pkmn.index)
  when :Foe
    pbShowBattleStats(opponentMon ? pkmn.index : pkmn.index ^ 1, pkmn.index)
  when :BattleLog
    @battle.scene.showBattleLog
    pbShowBattleStats(pkmn.index)
  when :FieldNotes
    if canCheckFieldApp?(fieldnotes)
      pbPlayCursorSE()
      infoscene = Scene_FieldNotes_Battle.new
      pbCheckPokegearScene(infoscene, fieldnotes)
    end
  when :BossNotes
    if canCheckBossDex?(bossnotes)
      pbPlayCursorSE()
      infoscene = Scene_BossDex_Battle.new
      pbCheckPokegearScene(infoscene, bossnotes)
    end
  end
end

PartyPreviewBarWidth = 72 # width of one column
PartyPreviewBarHeight = 288
PartyPreviewIconSpacing = 48 # vertical spacing
PartyPreviewHPBarSize = 52

def drawPartyPreview(pkmnindex)
  sideindex = @battle.pbIsOpposing?(pkmnindex) ? 1 : 0
  trainerindex = @battle.pbGetOwnerIndex(pkmnindex)
  party = (@battle.pbIsOpposing?(pkmnindex) ? @battle.party2 : @battle.party1)[trainerindex]

  columns = (party.length / 6.0).ceil
  barWidth = PartyPreviewBarWidth * columns
  barX = @battle.pbIsOpposing?(pkmnindex) ? Graphics.width - barWidth : 0

  @partyview = Viewport.new(barX, 0, barWidth, PartyPreviewBarHeight)
  @partyview.z = 99999

  @sprites["partyviewbg"] = Sprite.new(@partyview)
  @sprites["partyviewbg"].bitmap = Bitmap.new(barWidth, PartyPreviewBarHeight)
  @sprites["partyviewbg"].bitmap.fill_rect(0, 0, barWidth, PartyPreviewBarHeight, Color.new(24, 25, 26, 200))

  partystatuses = getPartyStatuses(sideindex, trainerindex, party)

  partystatuses.each_with_index { |status, partyindex|
    i = partyindex # For sprite naming convenience
    pokemon = party[i]
    pokeX = i / 6 * PartyPreviewBarWidth
    pokeY = i % 6 * PartyPreviewIconSpacing - 16
    case status
    when :yoinked
      @sprites["inspectpokeicon#{i}"] = IconSprite.new(pokeX + 20, pokeY + 26, @partyview)
      @sprites["inspectpokeicon#{i}"].setBitmap("Graphics/Pictures/Battle/ballempty")
    when :unrevealed
      @sprites["inspectpokeicon#{i}"] = IconSprite.new(pokeX + 20, pokeY + 26, @partyview)
      @sprites["inspectpokeicon#{i}"].setBitmap("Graphics/Pictures/Battle/ballnormal")
    else
      # Show HP of actual Pokemon always
      hp, totalhp = pokemon.hp, pokemon.totalhp
      pbAddHPBar(i, hp, totalhp)

      # Show icon of actual Pokemon or its disguise if it exists
      pokemon = getDisplayedPokemon(pokemon, pkmnindex)
      @sprites["inspectpokeicon#{i}"] = IconSprite.new(pokeX, pokeY, @partyview)
      @sprites["inspectpokeicon#{i}"].bitmap = pbPokemonIconBitmap(pokemon)
      @sprites["inspectpokeicon#{i}"].src_rect = Rect.new(0, 0, 64 + AURA_SPRITE_OFFSET, 64 + AURA_SPRITE_OFFSET)
      @sprites["inspectpokeicon#{i}"].opacity = 120 if status == :fainted

      # Add Pulse icon for Pulses since they don't have unique Pokemon icons
      if pokemon.isPulse?
        @sprites["inspectformicon#{i}"] = IconSprite.new(pokeX + PartyPreviewHPBarSize - 4, pokeY + 40, @partyview)
        @sprites["inspectformicon#{i}"].setBitmap("Graphics/Pictures/Battle/battlePulseEvoBox")
        @sprites["inspectformicon#{i}"].opacity = 120 if status == :fainted
      end
    end
  }
end

def ttsPartyPreview(pkmnindex) # Must correspond to drawPartyPreview
  sideindex = @battle.pbIsOpposing?(pkmnindex) ? 1 : 0
  trainerindex = @battle.pbGetOwnerIndex(pkmnindex)
  party = (@battle.pbIsOpposing?(pkmnindex) ? @battle.party2 : @battle.party1)[trainerindex]

  partystatuses = getPartyStatuses(sideindex, trainerindex, party)

  revealed, fainted = [], [] # revealed = onfield + switchedout
  partystatuses.each_with_index { |status, partyindex|
    next unless [:onfield, :switchedout, :fainted].include?(status)

    pokemon = party[partyindex]
    # Use HP of actual Pokemon always
    hp, totalhp = pokemon.hp, pokemon.totalhp
    # Use name of actual Pokemon or its disguise if it exists
    pokemon = getDisplayedPokemon(pokemon, pkmnindex)

    name = getMonName(pokemon.species, pokemon.form)
    if status == :fainted
      fainted.push(name)
    else
      hpstr = _INTL("{1}% HP", (hp / totalhp.to_f * 100).round)
      revealed.push(name + ": " + hpstr)
    end
  }
  unrevealed = partystatuses.count(:unrevealed)
  yoinked = partystatuses.count(:yoinked)

  string = @battle.pbGetOwner(pkmnindex).trainername
  string += "\n" + _INTL("Remaining Pokémon: {1}", revealed.length + unrevealed)
  string += ", " + revealed.join(", ")
  string += ", " + _INTL("{1} unrevealed Pokémon", unrevealed) unless unrevealed == 0
  string += "\n" + _INTL("Fainted Pokémon: {1}", fainted.length) + ", " + fainted.join(", ") unless fainted.empty?
  string += "\n" + _INTL("{1} empty party slots", yoinked) unless yoinked == 0
  tts(string)
end

def getPartyStatuses(sideindex, trainerindex, party)
  return party.map.with_index { |pokemon, partyindex|
    next :yoinked if pokemon.nil?
    next :onfield if @battle.battlers.any? { |battler| battler.pokemon == pokemon }
    if @battle.pbIsRevealedPokemon?(sideindex, trainerindex, partyindex)
      next pokemon.hp > 0 ? :switchedout : :fainted
    end
    next :unrevealed
  }
end

def getDisplayedPokemon(pokemon, battlerindex)
  battler = @battle.battlers.find { |i| i.pokemon == pokemon }
  if battler
    pokemon = battler.effects[:Illusion].pokemon if battler.effects[:Illusion]
    pokemon = battler.effects[:clearDisguise].pokemon if battler.effects[:clearDisguise]
  elsif Rejuv && pokemon.disguise
    pokemon = pokemon.disguise
  elsif pokemon.ability == :ILLUSION
    illusionindex = @battle.permanenteffects[pokemon][:LastUsedIllusionIndex]
    pokemon = @battle.pbPartySingleOwner(battlerindex)[illusionindex] if illusionindex
  end
  return pokemon
end

def pbAddHPBar(i, hp, totalhp) # Based on FL_SimpleHUD.rb
  borderWidth, borderHeight = PartyPreviewHPBarSize, 10
  fillWidth, fillHeight = PartyPreviewHPBarSize - 4, 6
  hpX = i / 6 * PartyPreviewBarWidth + PartyPreviewBarWidth / 2
  hpY = (i % 6 + 1) * PartyPreviewIconSpacing - 4

  @sprites["inspecthpborder#{i}"] = BitmapSprite.new(borderWidth, borderHeight, @partyview)
  @sprites["inspecthpborder#{i}"].x = hpX - borderWidth / 2
  @sprites["inspecthpborder#{i}"].y = (hpY - borderHeight / 2).to_grid
  @sprites["inspecthpborder#{i}"].bitmap.fill_rect(
    Rect.new(0, 0, borderWidth, borderHeight),
    Color.new(32, 32, 32)
  )
  @sprites["inspecthpborder#{i}"].bitmap.fill_rect(
    (borderWidth - fillWidth) / 2, ((borderHeight - fillHeight) / 2).to_grid,
    fillWidth, fillHeight,
    Color.new(96, 96, 96)
  )
  @sprites["inspecthpborder#{i}"].z = 99999

  @sprites["inspecthpfill#{i}"] = BitmapSprite.new(fillWidth, fillHeight, @partyview)
  @sprites["inspecthpfill#{i}"].x = hpX - fillWidth / 2
  @sprites["inspecthpfill#{i}"].y = (hpY - fillHeight / 2).to_grid
  width = @sprites["inspecthpfill#{i}"].bitmap.width
  height = @sprites["inspecthpfill#{i}"].bitmap.height
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
    @sprites["inspecthpfill#{i}"].bitmap.fill_rect(rect, hpColors[1])
    rect = Rect.new(0, shadowHeight, fillAmount, height - shadowHeight)
    @sprites["inspecthpfill#{i}"].bitmap.fill_rect(rect, hpColors[0])
    @sprites["inspecthpfill#{i}"].z = 99999
  end
end

def pbModifyBattlerSprites(pkmnindex, starting)
  (0..4).to_a.each { |i|
    next if !@sprites["pokemon#{i}"]
    # Change other sprites to be faded
    @sprites["pokemon#{i}"].opacity += (starting ? -140 : 140) if i != pkmnindex
    # Make sprite in focus appear above partner sprite (partner sprites have z value greater by 5)
    @sprites["pokemon#{i}"].z += (starting ? 6 : -6) if i == pkmnindex
  }
end

def pbShowInspect(msgwindow, commands, pkmnindex)
  @sprites["cmdwindow"] = Window_AdvancedCommandPokemon_NoPageScroll.new(commands)
  @sprites["cmdwindow"].z = 99999
  @sprites["cmdwindow"].visible = true
  @sprites["cmdwindow"].resizeToFit(@sprites["cmdwindow"].commands)
  @sprites["cmdwindow"].setSkin("Graphics/Windowskins/inspectskin") if Reborn
  pbPositionNearMsgWindow(@sprites["cmdwindow"], msgwindow, @battle.pbIsOpposing?(pkmnindex) ? :left : :right)
  pbModifyBattlerSprites(pkmnindex, true)

  menusize = 8
  @sprites["cmdwindow"].index = 0
  ret = nil
  holdZ = false
  loop do
    Graphics.update
    Input.update
    @sprites["cmdwindow"].update
    msgwindow.update if msgwindow
    pbUpdateSceneMap

    showFieldNotes, showBossNotes = false, false
    holdZ = false if Input.time?(Input::Z) == 0.0 && !Input.release?(Input::Z)
    if Input.time?(Input::Z) >= 0.5
      if $game_switches[:Blindstep]
        holdZ = true
      else
        showBossNotes = true
      end
    elsif Input.release?(Input::Z) && !Input.press?(Input::Z)
      if holdZ
        holdZ = false
        showBossNotes = true
      else
        showFieldNotes = true
      end
    end

    if showFieldNotes
      ret = :FieldNotes
    elsif showBossNotes
      ret = :BossNotes
    elsif Input.trigger?(Input::L)
      ret = :Self
    elsif Input.trigger?(Input::R)
      ret = :Foe
    elsif Input.trigger?(Input::Y)
      ret = :BattleLog
    elsif Input.trigger?(Input::B)
      ret = :Exit
    elsif Input.trigger?(Input::C)
      index = @sprites["cmdwindow"].index
      if !@battle.battlers[pkmnindex].isWildPokemon? && $game_switches[:Blindstep] && index == commands.length - 1
        ttsPartyPreview(pkmnindex)
      else
        ret = index
      end
    elsif Input.trigger?(Input::LEFT)
      @sprites["cmdwindow"].index -= menusize
      @sprites["cmdwindow"].index = 0 if @sprites["cmdwindow"].index < 0
      @sprites["cmdwindow"].item_changed
    elsif Input.trigger?(Input::RIGHT)
      @sprites["cmdwindow"].index += menusize
      @sprites["cmdwindow"].index = commands.length - 1 if @sprites["cmdwindow"].index > commands.length - 1
      @sprites["cmdwindow"].item_changed
    end

    break if ret
  end
  Input.update
  return ret
end

def pbEndInspect(pkmnindex)
  pbModifyBattlerSprites(pkmnindex, false)
  Kernel.pbDisposeMessageWindow(@sprites["msgwindow"])
  Input.update
  @sprites["cmdwindow"].dispose
  @partyview.dispose if @partyview
end

def readableFieldNotes()
  ret = {}
  ret[:overlay] = @battle.OV if Rejuv && Overlays && @battle.OV && $game_switches[$cache.FEData[@battle.OV].fieldAppSwitch] # -Currently- only for Rejuv
  fieldlayers = @battle.field.layer.clone
  fieldlayers.delete(:INDOOR)
  fieldlayers.uniq! # Needed to stop dupes from backing out
  fieldlayers.filter! { |field| $game_switches[$cache.FEData[field].fieldAppSwitch] }
  fieldlayers.reverse!
  ret[:fields] = fieldlayers if fieldlayers.any?
  return ret
end

def canCheckFieldApp?(notes)
  return false if !$Trainer.pokegear
  return false if !$game_switches[:Field_Notes]

  return notes != {} && !notes.nil?
end

def canCheckBossDex?(notes)
  return false if !$Trainer.pokegear
  return false if !$game_switches[:Pulse_Dex] && Reborn
  return false if !$game_switches[:RiftDex] && Rejuv

  return notes != [] && !notes.nil?
end

def readableBossNotes(battle)
  return nil if Desolation

  data = Reborn ? PULSEDATA : RIFTDATA
  onFieldBosses = battle.battlers.map { |battler|
    pokemon = battler.visiblePokemon
    isBoss = Reborn ? :isPulse? : :isRift?
    pokemon&.send(isBoss) ? [pokemon.species, pokemon.form] : nil
  }.compact
  bosses = onFieldBosses | battle.revealedBosses
  bosses.map! { |species, form|
    formname = $cache.pkmn[species].forms[form]
    bossdata = data.find { |boss, data| $game_switches[boss] && data[:species] == species && (data[:form] == formname || data[:altForm] == formname || data[:dexForms]&.include?(formname)) }
    bossdata ? bossdata[0] : nil
  }.compact!
  return bosses.uniq
end

def isUnknownPulse?(species, form)
  return false unless Reborn
  pulsesym = findPulseData(species, form, :symbol)
  return false if pulsesym.nil? # Not a Pulse
  return false if $game_switches[pulsesym] # Read-Out obtained
  return true
end

def pbCheckPokegearScene(scene, start)
  oldsprites = pbFadeOutAndHide(@sprites)
  infoscene = scene
  infoscene.pbStartScene(start)
  infoscene.pbEndScene
  pbFadeInAndShow(@sprites, oldsprites)
  return
end

class Window_AdvancedCommandPokemon_NoPageScroll < Window_AdvancedCommandPokemon
  def getCursorGraphic
    return Reborn ? "Graphics/Pictures/selarrowwhite" : super
  end

  # Disables scrolling with Q/W because those are used to change Pokemon in Inspect
  def update
    super(false)
  end

  def tts_cur_item(*args)
    super
    text = @commands[self.index]
    ttsTypeIconsInText(text)
  end
end

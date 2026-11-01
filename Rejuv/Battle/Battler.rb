class PokeBattle_Battler
  attr_accessor :zorotransform

  alias __rejuv_pbInitialize pbInitialize unless method_defined?(:__rejuv_pbInitialize)
  def pbInitialize(pkmn, index, batonpass)
    __rejuv_pbInitialize(pkmn, index, batonpass)
    @zorotransform = (self.crested == :ZOROARK && self.ability == :STANCECHANGE) ? 0 : nil
    @battle.pbCreateSpecialParty(@specialmoves, index, @index) if (@index & 1 == 0) && $game_switches[:Friends_Help_Plz]
  end

  def rejuvAbilities
    if self.ability == :REFLECTOR
      if !pbFirstOpposing.isFainted?
        if self.getReflectorTypes(pbFirstOpposing)
          @battle.pbAbilityBoxAndDisplay(self, _INTL("¡{1} ha adquirido los tipos de {2}!", pbThis, pbFirstOpposing.pbThis(true)))
        end
      end
    end
  end

  def stanceChangeIllusions(basemove = nil)
    transformed = false
    if self.effects[:clearDisguise]
      if self.ability == :STANCECHANGE && !@effects[:Transform]
        if self.form == 0 && !basemove.nil? && basemove.pbIsDamaging?
          self.form = 1
          transformed = true
        elsif self.form == 1 && !basemove.nil? && basemove.move == :KINGSSHIELD
          self.form = 0
          transformed = true
        end
        pbUpdate(true)
        if self.ability == :STANCECHANGE && (@battle.FE == :FAIRYTALE || (Rejuv && @battle.FE == :CHESS))
          amounts = self.pokemon.form == 0 ? [-1, 1] : [1, -1]
          self.pbChangeStats(PBStats::Physical, amounts, self, nil, abilitycheck: :hide)
        end
      end
    end
    if self.pokemon && self.crested == :ZOROARK && !self.isFainted?
      if self.ability == :STANCECHANGE && !@effects[:Transform]
        if @zorotransform == 0 && !basemove.nil? && basemove.pbIsDamaging?
          @zorotransform = 1; transformed = true
        elsif @zorotransform == 1 && !basemove.nil? && basemove.move == :KINGSSHIELD
          @zorotransform = 0; transformed = true
        end
        if self.effects[:Illusion] != nil
          self.effects[:Illusion].form = @zorotransform
        end
        if transformed
          @battle.pbShowAbilityBox(self)
          if self.effects[:Illusion] != nil
            if self.effects[:Illusion].form == 1
              @battle.pbCommonAnimation("StanceAttack", self, nil)
            else
              @battle.pbCommonAnimation("StanceProtect", self, nil)
            end
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self, self.effects[:Illusion].pokemon)
            message = self.effects[:Illusion].form == 0 ? _INTL("¡Ha cambiado a la Forma Escudo!") : _INTL("¡Ha cambiado a la Forma Espada!")
            @battle.pbDisplay(message)
          end
          if self.ability == :STANCECHANGE && (@battle.FE == :FAIRYTALE || (Rejuv && @battle.FE == :CHESS))
            amounts = @zorotransform == 0 ? [-1, 1] : [1, -1]
            self.pbChangeStats(PBStats::Physical, amounts, self, nil, abilitycheck: :hide)
          end
          @battle.pbHideAbilityBox(self)
        end
      end
    end # end of update
  end

  def crestStats
    case @crested
      when :SILVALLY
        @ability = PBStuff::SILVALLYCRESTABILITIES.keys.include?(@item) ? PBStuff::SILVALLYCRESTABILITIES[@item] : :SCRAPPY
        @attack *= 1.2
        @spatk *= 1.2
      when :INFERNAPE
        @spdef, @defense = @spatk, @attack
      when :MAGCARGO
        @defense, @speed = @speed, @defense
        @spatk *= 1.2
      when :TYPHLOSION
        @attack = @spatk
      when :CLAYDOL
        @spatk = @defense
      when :DEDENNE
        @attack = @speed
        @spatk = @speed
      when :RELICANTH
        @attack *= 1.25
        @spdef *= 1.35
      when :SKUNTANK
        @attack *= 1.2
        @spatk *= 1.2
      when :HYPNO
        @spatk *= 1.5
      when :STANTLER, :WYRDEER
        @attack *= 1.5
      when :ORICORIO
        @spatk *= 1.25
        @speed *= 1.25
      when :SEVIPER
        @speed *= 1.5
      when :DUSKNOIR
        @attack *= 1.5
      when :COFAGRIGUS
        @defense *= 1.4
        @spatk *= 1.2
      when :ARIADOS
        @speed *= 1.5
      when :PHIONE
        @defense *= 1.5
        @spdef *= 1.5
      when :DELCATTY
        party = @battle.pbCombinedParty(@index)
        if @delcrestparty.nil?
          @delcrestparty = []
          for mon in party
            next if !mon || mon == self || mon.hp <= 0 || mon.isEgg?

            @delcrestparty.push(mon)
          end
        end
        for mon in @delcrestparty
          @attack += (0.1 * mon.attack)
          @defense += (0.1 * mon.defense)
          @speed += (0.1 * mon.speed)
          @spatk += (0.1 * mon.spatk)
          @spdef += (0.1 * mon.spdef)
        end
      when :WHISCASH
        @attack *= 1.2
        @spatk *= 1.2
      when :NOCTOWL
        @defense *= 1.3
      when :CRABOMINABLE
        @defense *= 1.25
        @spdef *= 1.25
      when :REUNICLUS
        @spatk *= 1.25 # buffing this a bit
        if @battle.choices[@index][0] == :move && @battle.choices[@index][1] >= 0
          @attack, @spatk = @spatk, @attack if self.moves[@battle.choices[@index][1]].pbIsPhysical?(self)
        end
      when :GOTHITELLE
        @spatk *= 1.25 # buffing this a bit
      when :SAWSBUCK
        @type1 = :WATER if @form == 0
        @type1 = :FIRE   if @form == 1
        @type1 = :GROUND if @form == 2
        @type1 = :ICE    if @form == 3
      when :SIMISAGE
        @attack *= 1.2
        @spatk *= 1.2
      when :SIMISEAR
        @attack *= 1.2
        @spatk *= 1.2
      when :PANGORO
        @defense *= 1.3
        @spdef *= 1.3
      when :SIMIPOUR
        @attack *= 1.2
        @spatk *= 1.2
      when :SHIINOTIC
        @spdef *= 1.3
      when :CRYOGONAL
        @spdef *= 1.2
        @attack += @spdef * 0.1
        @defense += @spdef * 0.1
        @spatk += @spdef * 0.1
        @speed += @spdef * 0.1
      when :ELECTRODE
       # @attack += @speed * 0.1 nerfing this for good reason
        @defense += @speed * 0.1
        @spatk += @speed * 0.1
        @spdef += @speed * 0.1
      when :ZOROARK
        blacklist = PBStuff::ABILITYBLACKLIST - [:STANCECHANGE, :TRACE]
        if @effects[:ZoroCrest]
          illusion = @effects[:ZoroCrest]
        else
          illusion, illusionindex = @battle.illusionChoice(self.index, self.pokemonIndex)
        end
        if !illusion.nil?
          @ability = illusion.ability if !blacklist.include?(illusion.ability)
        end
    end
    @attack = @attack.floor
    @defense = @defense.floor
    @spatk = @spatk.floor
    @spdef = @spdef.floor
    @speed = @speed.floor
  end

  def undoCrestStats
    self.crested = false
    self.pbUpdate(true)
  end

  def reconstructAdmin
    self.reconstructcounter += 1
    if self.reconstructcounter >= 100 && self.pokemon.bossID == :ADMIN
      if $game_variables[731] < 122 && $game_variables[756] < 85
        @battle.pbDisplayBrief(_INTL("???: Estás perdiendo el tiempo, Interceptor.", self.pbThis))
      else
        @battle.pbDisplayBrief(_INTL("Una voz perdida resonó en tu cabeza...", self.pbThis))
        @battle.pbDisplayBrief(_INTL("???: Estás perdiendo el tiempo, Interceptor.", self.pbThis))
      end
      @battle.pbAnimation(:ROAROFTIME, self, nil)
      @battle.decision = 2
      @battle.pbJudge()
      # if @battle.decision > 0
      #   return
      # end
    elsif self.reconstructcounter >= 3
      @battle.pbDisplayBrief(_INTL("¡{1} parece indestructible...", self.pbThis))
    end
  end
end

class PokeBattle_BossMove < PokeBattle_Move
  def initialize(battle, user, bossmove)
    @battle      = battle
    @move        = bossmove[:move]
    @name        = bossmove[:longname] || bossmove[:name]
    @shortname   = bossmove[:name]
    @pp          = 0
    @zmove       = false
    @user        = user

    @function    = bossmove[:function]
    @type        = bossmove[:type] || :QMARKS
    @category    = bossmove[:category]
    @basedamage  = bossmove[:basedamage]
    @accuracy    = 100
    @maxpp       = 0
    @target      = bossmove[:target]
    @priority    = 0
    @effect      = bossmove[:effect] || 0
    @moreeffect  = bossmove[:moreeffect] || @effect
    @recoil      = 0
  end
end

ZYGARDE_BASE_STAT = 78
ZYGARDE_BASE_CORE_EFFECT = 16

class PokeBattle_Pokemon
  attr_accessor :prismPower
  attr_accessor :fakeOT
  attr_accessor :flickerID
  attr_accessor :flickerLocation
  attr_accessor :changeAllHPType
  attr_accessor :naturetext # overwrite nature note on page 2
  attr_accessor :obtainExtra # any extra details for obtain summary
  attr_accessor :disguise # azery: this was a mistake
  attr_accessor :unusable # azery: this too
  attr_accessor :disobedient # pokemon doesn't obey trainer commands
  attr_accessor :customForm # mondata for customized form not listed in montext
  attr_accessor :catchRate # azery: setting mon specific catch rates for shadows

  unless @rejuvenationAliases
    alias __core_tID publicID
    alias __goAwayZygarde getAbilityList
    @rejuvenationAliases = true
  end

  def publicID(*args)
    ret = __core_tID(*args)
    ret = 777777 if @ot == "Mr. Luck" && @trainerID == KNOWN_TRAINERS["Mr. Luck"]
    return ret
  end

  def getAbilityList
    # We're done dealing with this.
    return __goAwayZygarde - [:POWERCONSTRUCT]
  end

  def typecrosslist(basespecies, baseform, basegender)
    cacheDataMon = $cache.pkmn[basespecies, baseform, basegender]
    cacheDataZygarde = $cache.pkmn[:ZYGARDE, 0]
    baseMonTypes = [cacheDataMon.Type1, cacheDataMon.Type2].compact
    zygardeTypes = [cacheDataZygarde.Type1, cacheDataZygarde.Type2].compact
    typechoices = zygardeTypes.product(baseMonTypes) + baseMonTypes.product(zygardeTypes)
    typechoices.filter! { |typeOption| typeOption[0] != typeOption[1]}
    return typechoices
  end

  def coreEffect()
    return ZYGARDE_BASE_CORE_EFFECT + $cache.abil[self.ability].checkFlag?(:coreEffectModifier, 0)
  end

  def recalcStats()
    coreInvestment = self.customForm.checkFlag?(:CoreInvestment)
    for stat in 0..5
      self.baseStats[stat] = ZYGARDE_BASE_STAT + self.coreEffect() * coreInvestment[stat]
    end
    self.baseStats[0] = 1 if self.ability == :WONDERGUARD
  end

  # creates a MonData object based on current Pokemon and form crossed with Zygarde
  # has user input
  # intended to be used as pokemondata instead of the species data in the cache
  def createCustomMon()
    cacheDataMon = self.getCacheData
    cacheDataZygarde = $cache.pkmn[:ZYGARDE, 0]
    typeInheritance = typecrosslist(@species, @form, self.gender).first
    mergedMoveSet = cacheDataMon.Moveset + cacheDataZygarde.Moveset
    mergedMoveSet.sort! { |a, b| a[0] <=> b[0] }
    eggmoves = self.getEggMoveList.dup
    baseStats = cacheDataMon.BaseStats
    maxstats = baseStats.each_index.select { |i| baseStats[i] == baseStats.max }
    basestats = Array.new(6, ZYGARDE_BASE_STAT)
    basestats[maxstats.first] += ZYGARDE_BASE_CORE_EFFECT if maxstats.length == 1
    statinvestment = Array.new(6, 0) # hp, atk, def, spatk, spdef, speed
    statinvestment[maxstats.first] += 1 if maxstats.length == 1
    abilitylist = cacheDataZygarde.Abilities.union(cacheDataMon.Abilities) - [:POWERCONSTRUCT]
    abilitylist.filter! { |ability| $cache.abil[ability].checkFlag?(:coreEffectModifier) != false }
    raise "Missing ability for Opportunity Zygarde." if abilitylist.empty?
    hidden = $cache.abil[cacheDataMon.HiddenAbility] && $cache.abil[cacheDataMon.HiddenAbility].checkFlag?(:coreEffectModifier) != false ? cacheDataMon.HiddenAbility : nil
    newFormData = {
      :Type1 => typeInheritance[0],
      :Type2 => typeInheritance[1],
      :CatchRate => 0,
      :BaseStats => basestats,
      :CoreInvestment => statinvestment,
      :Abilities => abilitylist,
      :HiddenAbility => hidden,
      :EggMoves => eggmoves,
      :Moveset => mergedMoveSet,
      :Weight => (cacheDataMon.Weight + $cache.pkmn[:ZYGARDE, 2].Weight) / 2,
      :RelearnerMoves => cacheDataMon.RelearnerMoves.union(cacheDataZygarde.RelearnerMoves),
      :compatiblemoves => cacheDataMon.compatiblemoves.union(cacheDataZygarde.compatiblemoves),
      :moveexceptions => cacheDataMon.moveexceptions.intersection(cacheDataZygarde.moveexceptions),
      :EggGroups => cacheDataZygarde.EggGroups, # like hell am i dealing with a mon breeding in this form
      :GrowthRate => cacheDataMon.GrowthRate, # just to avoid having to recalc experience the form will use whichever growthrate the base pokemon used instead of Zygarde
      :evolutions => nil, # yeah i am not allowing base 168 eviolite defenses sue me
    }
    self.customForm = CustomMonData.new(:ZYGARDE, $game_switches[:RenegadeRoute] ? 5 : 4, newFormData)
  end

  def getflickerID
    return publicID if @flickerID.nil?
    @flickerID[:timer] += 1
    return @flickerID[:display] if @flickerID[:timer] < @flickerID[:interval]
    @flickerID[:timer] = 0
    if rand(100) < @flickerID[:weight]
      @flickerID[:display] = @flickerID[:IDlist].sample
    else
      @flickerID[:display] = publicID
    end
    return @flickerID[:display]
  end

  def getflickerLocation(mapname)
    return mapname if @flickerLocation.nil?
    @flickerLocation[:timer] += 1
    return @flickerLocation[:display] if @flickerLocation[:timer] < @flickerLocation[:interval]
    @flickerLocation[:timer] = 0
    if rand(100) < @flickerLocation[:weight]
      @flickerLocation[:display] = @flickerLocation[:IDlist].sample
    else
      @flickerLocation[:display] = mapname
    end
    return @flickerLocation[:display]
  end
end
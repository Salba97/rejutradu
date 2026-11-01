EVOLUTION_METHODS = [
  :Happiness,
  :HappinessDay,
  :HappinessNight,
  :Level,
  :Trade,
  :TradeItem,
  :Item,
  :AttackGreater,
  :AtkDefEqual,
  :DefenseGreater,
  :Silcoon,
  :Cascoon,
  :Ninjask,
  :Shedinja,
  :ItemMale,
  :ItemFemale,
  :DayHoldItem,
  :NightHoldItem,
  :HasMove,
  :HasInParty,
  :LevelMale,
  :LevelFemale,
  :TradeSpecies,
  :BadInfluence,
  :Affection,
  :LevelRain,
  :LevelDay,
  :LevelNight,
  :LevelDusk,
  :LandCritical,
  :Runerigus,
  :EventTrigger, # Alcremie / Runerigus in Reborn (no built-in code, has to be triggered manually by an event)
  :TakeRecoil, # Basculegion
  :WalkSteps, # Rabsca/Pawmot/Brambleghast
  :UseMove, # Annihilape
  :DefeatEnemies, # Kingambit
  :CollectItem, # Gholdengo
  :LevelBattle, # Maushold
  :LevelPartner, # Palafin
]

EVERSTONE_ITEMS = [:EVERSTONE, :EVIOLITE, :EEVIUMZ, :LIGHTBALL, :PIKANIUMZ, :EEVEETITE, :PIKACHUTITE, :DURALUDONITE, :GOLDENAPPLE]

LINKSTONE_ITEMS = [:LINKSTONE, :LINKHEART]

class SpriteMetafile
  VIEWPORT      = 0
  TONE          = 1
  SRC_RECT      = 2
  VISIBLE       = 3
  X             = 4
  Y             = 5
  Z             = 6
  OX            = 7
  OY            = 8
  ZOOM_X        = 9
  ZOOM_Y        = 10
  ANGLE         = 11
  MIRROR        = 12
  BUSH_DEPTH    = 13
  OPACITY       = 14
  BLEND_TYPE    = 15
  COLOR         = 16
  FLASHCOLOR    = 17
  FLASHDURATION = 18
  BITMAP        = 19

  def length
    return @metafile.length
  end

  def [](i)
    return @metafile[i]
  end

  def initialize(viewport = nil)
    @metafile = []
    @values = [
      viewport,
      Tone.new(0, 0, 0, 0), Rect.new(0, 0, 0, 0),
      true,
      0, 0, 0, 0, 0, 100, 100,
      0, false, 0, 255, 0,
      Color.new(0, 0, 0, 0), Color.new(0, 0, 0, 0),
      0
    ]
  end

  def disposed?
    return false
  end

  def dispose
  end

  def flash(color, duration)
    if duration > 0
      @values[FLASHCOLOR] = color.clone
      @values[FLASHDURATION] = duration
      @metafile.push([FLASHCOLOR, color])
      @metafile.push([FLASHDURATION, duration])
    end
  end

  def x
    return @values[X]
  end

  def x=(value)
    @values[X] = value
    @metafile.push([X, value])
  end

  def y
    return @values[Y]
  end

  def y=(value)
    @values[Y] = value
    @metafile.push([Y, value])
  end

  def bitmap
    return nil
  end

  def bitmap=(value)
    if value && !value.disposed?
      @values[SRC_RECT].set(0, 0, value.width, value.height)
      @metafile.push([SRC_RECT, @values[SRC_RECT].clone])
    end
  end

  def src_rect
    return @values[SRC_RECT]
  end

  def src_rect=(value)
    @values[SRC_RECT] = value
    @metafile.push([SRC_RECT, value])
  end

  def visible
    return @values[VISIBLE]
  end

  def visible=(value)
    @values[VISIBLE] = value
    @metafile.push([VISIBLE, value])
  end

  def z
    return @values[Z]
  end

  def z=(value)
    @values[Z] = value
    @metafile.push([Z, value])
  end

  def ox
    return @values[OX]
  end

  def ox=(value)
    @values[OX] = value
    @metafile.push([OX, value])
  end

  def oy
    return @values[OY]
  end

  def oy=(value)
    @values[OY] = value
    @metafile.push([OY, value])
  end

  def zoom_x
    return @values[ZOOM_X]
  end

  def zoom_x=(value)
    @values[ZOOM_X] = value
    @metafile.push([ZOOM_X, value])
  end

  def zoom_y
    return @values[ZOOM_Y]
  end

  def zoom_y=(value)
    @values[ZOOM_Y] = value
    @metafile.push([ZOOM_Y, value])
  end

  def angle
    return @values[ANGLE]
  end

  def zoom=(value)
    @values[ZOOM_X] = value
    @metafile.push([ZOOM_X, value])
    @values[ZOOM_Y] = value
    @metafile.push([ZOOM_Y, value])
  end

  def angle=(value)
    @values[ANGLE] = value
    @metafile.push([ANGLE, value])
  end

  def mirror
    return @values[MIRROR]
  end

  def mirror=(value)
    @values[MIRROR] = value
    @metafile.push([MIRROR, value])
  end

  def bush_depth
    return @values[BUSH_DEPTH]
  end

  def bush_depth=(value)
    @values[BUSH_DEPTH] = value
    @metafile.push([BUSH_DEPTH, value])
  end

  def opacity
    return @values[OPACITY]
  end

  def opacity=(value)
    @values[OPACITY] = value
    @metafile.push([OPACITY, value])
  end

  def blend_type
    return @values[BLEND_TYPE]
  end

  def blend_type=(value)
    @values[BLEND_TYPE] = value
    @metafile.push([BLEND_TYPE, value])
  end

  def color
    return @values[COLOR]
  end

  def color=(value)
    @values[COLOR] = value.clone
    @metafile.push([COLOR, @values[COLOR]])
  end

  def tone
    return @values[TONE]
  end

  def tone=(value)
    @values[TONE] = value.clone
    @metafile.push([TONE, @values[TONE]])
  end

  def update
    @metafile.push([-1, nil])
  end
end

class SpriteMetafilePlayer
  def initialize(metafile, sprite = nil)
    @metafile = metafile
    @sprites = []
    @playing = false
    @index = 0
    @sprites.push(sprite) if sprite
  end

  def add(sprite)
    @sprites.push(sprite)
  end

  def playing?
    return @playing
  end

  def play
    @playing = true
    @index = 0
  end

  def update
    if @playing
      for j in @index...@metafile.length
        @index = j + 1
        break if @metafile[j][0] < 0

        code = @metafile[j][0]
        value = @metafile[j][1]
        for sprite in @sprites
          case code
            when SpriteMetafile::X
              sprite.x = value
            when SpriteMetafile::Y
              sprite.y = value
            when SpriteMetafile::OX
              sprite.ox = value
            when SpriteMetafile::OY
              sprite.oy = value
            when SpriteMetafile::ZOOM_X
              sprite.zoom_x = value
            when SpriteMetafile::ZOOM_Y
              sprite.zoom_y = value
            when SpriteMetafile::SRC_RECT
              sprite.src_rect = value
            when SpriteMetafile::VISIBLE
              sprite.visible = value
            when SpriteMetafile::Z
              sprite.z = value
            # prevent crashes
            when SpriteMetafile::ANGLE
              sprite.angle = (value == 180) ? 179.9 : value
            when SpriteMetafile::MIRROR
              sprite.mirror = value
            when SpriteMetafile::BUSH_DEPTH
              sprite.bush_depth = value
            when SpriteMetafile::OPACITY
              sprite.opacity = value
            when SpriteMetafile::BLEND_TYPE
              sprite.blend_type = value
            when SpriteMetafile::COLOR
              sprite.color = value
            when SpriteMetafile::TONE
              sprite.tone = value
          end
        end
      end
      @playing = false if @index == @metafile.length
    end
  end
end

#####################

class PokemonEvolutionScene
  def pbGenerateMetafiles(s1x, s1y, s2x, s2y)
    sprite = SpriteMetafile.new
    sprite2 = SpriteMetafile.new
    sprite.opacity = 255
    sprite2.opacity = 255
    sprite2.zoom = 0.0
    sprite.ox = s1x
    sprite.oy = s1y
    sprite2.ox = s2x
    sprite2.oy = s2y
    alpha = 0
    for j in 0...26
      sprite.color.red = 255
      sprite.color.green = 255
      sprite.color.blue = 255
      sprite.color.alpha = alpha
      sprite.color = sprite.color
      sprite2.color = sprite.color
      sprite2.color.alpha = 255
      sprite.update
      sprite2.update
      alpha += 5
    end
    totaltempo = 0
    currenttempo = 25
    maxtempo = 280
    while totaltempo < maxtempo
      for j in 0...currenttempo
        if alpha < 255
          sprite.color.red = 255
          sprite.color.green = 255
          sprite.color.blue = 255
          sprite.color.alpha = alpha
          sprite.color = sprite.color
          alpha += 10
        end
        sprite.zoom = [1.1 * (currenttempo - j - 1) / currenttempo, 1.0].min
        sprite2.zoom = [1.1 * (j + 1) / currenttempo, 1.0].min
        sprite.update
        sprite2.update
      end
      totaltempo += currenttempo
      if totaltempo + currenttempo < maxtempo
        for j in 0...currenttempo
          sprite.zoom = [1.1 * (j + 1) / currenttempo, 1.0].min
          sprite2.zoom = [1.1 * (currenttempo - j - 1) / currenttempo, 1.0].min
          sprite.update
          sprite2.update
        end
      end
      totaltempo += currenttempo
      currenttempo = [(currenttempo / 1.5).floor, 5].max
    end
    @metafile1 = sprite
    @metafile2 = sprite2
  end

  def pbSaveSpriteState(sprite)
    state = []
    return state if !sprite || sprite.disposed?

    state[SpriteMetafile::BITMAP]     = sprite.x
    state[SpriteMetafile::X]          = sprite.x
    state[SpriteMetafile::Y]          = sprite.y
    state[SpriteMetafile::SRC_RECT]   = sprite.src_rect.clone
    state[SpriteMetafile::VISIBLE]    = sprite.visible
    state[SpriteMetafile::Z]          = sprite.z
    state[SpriteMetafile::OX]         = sprite.ox
    state[SpriteMetafile::OY]         = sprite.oy
    state[SpriteMetafile::ZOOM_X]     = sprite.zoom_x
    state[SpriteMetafile::ZOOM_Y]     = sprite.zoom_y
    state[SpriteMetafile::ANGLE]      = sprite.angle
    state[SpriteMetafile::MIRROR]     = sprite.mirror
    state[SpriteMetafile::BUSH_DEPTH] = sprite.bush_depth
    state[SpriteMetafile::OPACITY]    = sprite.opacity
    state[SpriteMetafile::BLEND_TYPE] = sprite.blend_type
    state[SpriteMetafile::COLOR]      = sprite.color.clone
    state[SpriteMetafile::TONE]       = sprite.tone.clone
    return state
  end

  def pbRestoreSpriteState(sprite, state)
    return if !state || !sprite || sprite.disposed?

    sprite.x          = state[SpriteMetafile::X]
    sprite.y          = state[SpriteMetafile::Y]
    sprite.src_rect   = state[SpriteMetafile::SRC_RECT]
    sprite.visible    = state[SpriteMetafile::VISIBLE]
    sprite.z          = state[SpriteMetafile::Z]
    sprite.ox         = state[SpriteMetafile::OX]
    sprite.oy         = state[SpriteMetafile::OY]
    sprite.zoom_x     = state[SpriteMetafile::ZOOM_X]
    sprite.zoom_y     = state[SpriteMetafile::ZOOM_Y]
    sprite.angle      = state[SpriteMetafile::ANGLE]
    sprite.mirror     = state[SpriteMetafile::MIRROR]
    sprite.bush_depth = state[SpriteMetafile::BUSH_DEPTH]
    sprite.opacity    = state[SpriteMetafile::OPACITY]
    sprite.blend_type = state[SpriteMetafile::BLEND_TYPE]
    sprite.color      = state[SpriteMetafile::COLOR]
    sprite.tone       = state[SpriteMetafile::TONE]
  end

  def pbSaveSpriteStateAndBitmap(sprite)
    return [] if !sprite || sprite.disposed?

    state = pbSaveSpriteState(sprite)
    state[SpriteMetafile::BITMAP] = sprite.bitmap
    return state
  end

  def pbRestoreSpriteStateAndBitmap(sprite, state)
    return if !state || !sprite || sprite.disposed?

    sprite.bitmap = state[SpriteMetafile::BITMAP]
    pbRestoreSpriteState(sprite, state)
    return state
  end

  # Starts the evolution screen with the given Pokemon and new Pokemon species.

  def pbUpdate(animating = false)
    if animating # Pokémon shouldn't animate during the evolution animation
      @sprites["background"].update
    else
      pbUpdateSpriteHash(@sprites)
    end
  end

  def pbUpdateNarrowScreen
    if @bgviewport.rect.y < 20 * 4
      @bgviewport.rect.height -= 2 * 4
      if @bgviewport.rect.height < Graphics.height - 64
        @bgviewport.rect.y += 4
        @sprites["background"].oy = @bgviewport.rect.y
      end
    end
  end

  def pbUpdateExpandScreen
    if @bgviewport.rect.y > 0
      @bgviewport.rect.y -= 4
      @sprites["background"].oy = @bgviewport.rect.y
    end
    if @bgviewport.rect.height < Graphics.height
      @bgviewport.rect.height += 2 * 4
    end
  end

  def pbFlashInOut(canceled, oldstate, oldstate2)
    tone = 0
    loop do
      Graphics.update
      pbUpdate(true)
      pbUpdateExpandScreen
      tone += 10
      @viewport.tone.set(tone, tone, tone, 0)
      break if tone >= 255
    end
    @bgviewport.rect.y = 0
    @bgviewport.rect.height = Graphics.height
    @sprites["background"].oy = 0
    if canceled
      pbRestoreSpriteState(@sprites["rsprite1"], oldstate)
      pbRestoreSpriteState(@sprites["rsprite2"], oldstate2)
      @sprites["rsprite1"].visible = true
      @sprites["rsprite1"].zoom_x = 1.0
      @sprites["rsprite1"].zoom_y = 1.0
      @sprites["rsprite1"].color.alpha = 0
      @sprites["rsprite2"].visible = false
    else
      @sprites["rsprite1"].visible = false
      @sprites["rsprite2"].visible = true
      @sprites["rsprite2"].zoom_x = 1.0
      @sprites["rsprite2"].zoom_y = 1.0
      @sprites["rsprite2"].color.alpha = 0
    end
    10.times do
      Graphics.update
      pbUpdate(true)
    end
    tone = 255
    loop do
      Graphics.update
      pbUpdate
      tone = [tone - 20, 0].max
      @viewport.tone.set(tone, tone, tone, 0)
      break if tone <= 0
    end
  end

  # Opens the evolution screen
  def pbStartScreen(pokemon, newspecies, item = nil)
    pbStartCore(pokemon, newspecies)
    @sprites = {}
    @bgviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @bgviewport.z = 99999
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    addBackgroundOrColoredPlane(@sprites, "background", "evolutionbg", Color.new(248, 248, 248), @bgviewport)
    rsprite1 = PokemonSprite.new(@viewport)
    rsprite2 = PokemonSprite.new(@viewport)
    rsprite1.setPokemonBitmap(@pokemon, false)
    evolution = @pokemon.clone
    evolution.species = @newspecies
    evolution.form = @newform
    @pokemon.setGender(@pokemon.gender) if @pokemon.gender != evolution.gender
    rsprite2.setPokemonBitmap(evolution, false)
    rsprite1.ox = rsprite1.bitmap.width / 2
    rsprite1.oy = rsprite1.bitmap.height / 2
    rsprite2.ox = rsprite2.bitmap.width / 2
    rsprite2.oy = rsprite2.bitmap.height / 2
    rsprite1.x = Graphics.width / 2
    rsprite1.y = (Graphics.height - 64) / 2
    rsprite2.x = rsprite1.x
    rsprite2.y = rsprite1.y
    rsprite2.opacity = 0
    @sprites["rsprite1"] = rsprite1
    @sprites["rsprite2"] = rsprite2
    pbGenerateMetafiles(rsprite1.ox, rsprite1.oy, rsprite2.ox, rsprite2.oy)
    @sprites["msgwindow"] = Kernel.pbCreateMessageWindow(@viewport)
    pbFadeInAndShow(@sprites)
  end

  # Plays out the evolution scene
  def pbEvolution(cancancel = true, item = nil)
    pbBGMPlay("Evolution")
    metaplayer1 = SpriteMetafilePlayer.new(@metafile1, @sprites["rsprite1"])
    metaplayer2 = SpriteMetafilePlayer.new(@metafile2, @sprites["rsprite2"])
    metaplayer1.play
    metaplayer2.play

    pbPlayCry(@pokemon)
    pkmnname = @pokemon.name
    pkmnname["\\"] = "\\" + 00.chr if pkmnname.include?("\\")
    Kernel.pbMessageDisplay(@sprites["msgwindow"], _INTL("\\se[]What?\n{1} is evolving!\\^", pkmnname))
    Kernel.pbMessageWaitForInput(@sprites["msgwindow"], 100, true)
    pbPlayDecisionSE()
    oldstate = pbSaveSpriteState(@sprites["rsprite1"])
    oldstate2 = pbSaveSpriteState(@sprites["rsprite2"])

    @canceled = (@pokemon.species == :INKAY)

    begin
      pbUpdateNarrowScreen
      metaplayer1.update
      metaplayer2.update
      Graphics.update
      Input.update
      pbUpdate(true)
      if Input.trigger?(Input::C)
        break
      end

      if Input.trigger?(Input::B) && cancancel
        if @pokemon.species == :INKAY
          @canceled = false
        else
          @canceled = true
          pbRestoreSpriteState(@sprites["rsprite1"], oldstate)
          pbRestoreSpriteState(@sprites["rsprite2"], oldstate2)
          Graphics.update
          break
        end
      end
    end while metaplayer1.playing? && metaplayer2.playing?
    pbFlashInOut(@canceled, oldstate, oldstate2)
    if @canceled
      if @pokemon.species == :INKAY
        pbRestoreSpriteState(@sprites["rsprite1"], oldstate)
        pbRestoreSpriteState(@sprites["rsprite2"], oldstate2)
        Graphics.update
      end
      pbPlayCancelSE()
      Kernel.pbMessageDisplay(@sprites["msgwindow"], _INTL("Huh?\n{1} stopped evolving!", pkmnname))
      return false
    else
      pbEvolutionCore
      frames = pbCryFrameLength(@pokemon)
      pbPlayCry(@pokemon)
      frames.times do
        Graphics.update
      end
      Kernel.pbMessageDisplay(@sprites["msgwindow"], _INTL("\\se[]Congratulations! Your {1} evolved into {2}!\\wt[80]", pkmnname, getMonName(@newspecies, @newform)))
      @sprites["msgwindow"].text = ""
      pbEndCore
      return true
    end
  end

  # Closes the evolution screen
  def pbEndScreen
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"])
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  # 'Core' methods for silent evolution
  def pbStartCore(pokemon, newspecies)
    @pokemon = pokemon
    @newspecies = newspecies[:species]
    @newform = getEvolutionForm(@pokemon, newspecies[:form])
  end

  def pbEvolutionCore
    shedinjaEvo = checkEvolutionEx(@pokemon) { |pokemon, method, condition, evo|
      next evo if method == :Shedinja
    }

    checkEvolutionEx(@pokemon) { |pokemon, method, condition, evo|
      case method
        when :TradeItem, :DayHoldItem, :NightHoldItem
          if evo[:species] == @newspecies
            @pokemon.setItem(nil)
          end
        when :CollectItem
          if evo[:species] == @newspecies
            $PokemonBag.pbDeleteItem(condition[1], condition[0])
          end
        when :TakeRecoil
          @pokemon.recoilTaken = 0 if @pokemon.recoilTaken
        when :UseMove
          @pokemon.timesMoveUsed = 0 if @pokemon.timesMoveUsed
        when :DefeatEnemies
          @pokemon.defeatedEnemies = 0 if @pokemon.defeatedEnemies
        when :WalkSteps
          @pokemon.walkedSteps = 0 if @pokemon.walkedSteps
          $PokemonTemp.walkingMon = nil if $PokemonTemp.walkingMon == @pokemon
      end
    }

    newspeciesname = getMonName(@newspecies, @newform)
    oldspeciesname = getMonName(@pokemon.species, @pokemon.form)
    ability = resolveEvolutionAbility(@pokemon.getCacheData, $cache.pkmn[@newspecies, @newform, @pokemon.gender], @pokemon.ability)

    @pokemon.form = @newform
    @pokemon.species = @newspecies
    @pokemon.ability = ability
    $Trainer.pokedex.setOwned(@pokemon)
    @pokemon.name = newspeciesname if @pokemon.name == oldspeciesname
    @pokemon.calcStats

    if shedinjaEvo
      newpokemon = @pokemon.clone
      newpokemon.moves = @pokemon.moves.map(&:clone)
      newpokemon.iv = @pokemon.iv.clone
      newpokemon.ev = @pokemon.ev.clone
      newpokemon.species = shedinjaEvo[:species]
      newpokemon.name = getMonName(newpokemon.species, newpokemon.form)
      newpokemon.initAbility
      newpokemon.setItem(nil)
      # newpokemon.clearAllRibbons
      newpokemon.markings = 0
      newpokemon.calcStats
      newpokemon.heal

      $game_temp.in_battle ? $PokemonTemp.delayedShedinjaEvos.push(newpokemon) : pbAddShedinjaEvo(newpokemon)
    end
  end

  def pbEndCore
    # Check moves for new species
    movelist = @pokemon.getMoveList
    for i in movelist
      if i[0] == 0 || (i[0] == @pokemon.level && (Gen <= 7 || @pokemon.level != 1))
        pbTryLearnMove(@pokemon, i[1], ignoreifknown: true)
      end
    end
  end
end

def pbCarryOutEvolution(pokemon, evohash, item: nil, cancancel: true, silent: false)
  evo = PokemonEvolutionScene.new
  if silent
    evo.pbStartCore(pokemon, evohash)
    ret = evo.pbEvolutionCore
    evo.pbEndCore
  else
    evo.pbStartScreen(pokemon, evohash, item)
    ret = evo.pbEvolution(cancancel, item)
    evo.pbEndScreen
  end
  return ret
end

def pbEventEvolution(var_num) # To be used in events for :EventTrigger evos
  partyindex = pbGet(var_num)
  return unless partyindex.is_a?(Integer)
  pokemon = $Trainer.party[partyindex]
  return unless pokemon
  evodata = pbGetEvolvedFormData(pokemon.species, pokemon.form)
  return unless evodata

  pbFadeOutInWithMusic(99999) {
    pbCarryOutEvolution(pokemon, evodata[0])
  }
end

def resolveEvolutionAbility(base, evo, ability)
  if base.HiddenAbility == ability
    return evo.HiddenAbility || evo.Abilities[0]
  end

  index = base.Abilities.index(ability)
  unless index.nil?
    return evo.Abilities[index] || evo.Abilities[0]
  end

  # Don't change ability if it already was illegal
  return ability
end

def resolvePreEvoAbility(base, preevo, ability)
  if base.HiddenAbility == ability
    return preevo.HiddenAbility || preevo.Abilities[0]
  end

  index = base.Abilities.index(ability)
  unless index.nil?
    return preevo.Abilities[index] || preevo.Abilities[0]
  end

  # Don't change ability if it already was illegal
  return ability
end

def pbAddShedinjaEvo(pokemon)
  return unless $PokemonBag.pbHasItem?(:POKEBALL) && $Trainer.party.length < 6

  pokemon.ballused = :POKEBALL
  $PokemonBag.pbDeleteItem(:POKEBALL)
  $Trainer.party.push(pokemon)
  $Trainer.pokedex.setOwned(pokemon)
end

NonLevelUpEvoMethods = [:Item, :ItemMale, :ItemFemale, :Trade, :TradeItem, :TradeSpecies, :Shedinja, :LandCritical, :EventTrigger]

def checkEvoConditions(pokemon, method, condition, battle, doublebattle)
  case method
    when *NonLevelUpEvoMethods then return false
    # for organization, non-level evos go first, then we do a level check, then we continue.
    when :Happiness then return true if pokemon.happiness >= 220
    when :HappinessDay then return true if pokemon.happiness >= 220 && PBDayNight.isDay?(pbGetTimeNow)
    when :HappinessNight then return true if pokemon.happiness >= 220 && PBDayNight.isNight?(pbGetTimeNow)
    when :Affection then return true if pokemon.happiness >= 220 && pokemon.moves.any? { |move| move.type == condition }
    when :DayHoldItem then return true if pokemon.item == condition && PBDayNight.isDay?(pbGetTimeNow)
    when :NightHoldItem then return true if pokemon.item == condition && PBDayNight.isNight?(pbGetTimeNow)
    when :HasMove then return true if pokemon.moves.any? { |move| move.move == condition }
    when :HasInParty then return true if $Trainer.party.any? { |mon| !mon.isEgg? && mon.species == condition }
    when :Runerigus then return true if pokemon.totalhp - pokemon.hp >= 49
    when :TakeRecoil then return true if pokemon.recoilTaken >= condition
    when :WalkSteps then return true if pokemon.walkedSteps >= condition
    when :UseMove then return true if pokemon.timesMoveUsed >= condition[0]
    when :DefeatEnemies then return true if pokemon.defeatedEnemies >= condition[0]
    when :CollectItem then return true if $PokemonBag.pbQuantity(condition[1]) >= condition[0]
  end
  # the rest require level up beyond a specific level. get out of here if that's not you.
  return false if !condition.is_a?(Integer) || pokemon.level < condition

  case method
    when :Level, :Ninjask then return true
    when :AttackGreater then return true if pokemon.attack > pokemon.defense
    when :AtkDefEqual then return true if pokemon.attack == pokemon.defense
    when :DefenseGreater then return true if pokemon.attack < pokemon.defense
    when :Silcoon then return true if (((pokemon.personalID >> 16) & 0xFFFF) % 10) < 5
    when :Cascoon then return true if (((pokemon.personalID >> 16) & 0xFFFF) % 10) >= 5
    when :LevelMale then return true if pokemon.isMale?
    when :LevelFemale then return true if pokemon.isFemale?
    when :BadInfluence then return true if $Trainer.party.any? { |mon| !mon.isEgg? && mon.hasType?(:DARK) }
    when :LevelRain then return true if $game_screen.isRaining?
    when :LevelDay then return true if PBDayNight.isDay?(pbGetTimeNow)
    when :LevelNight then return true if PBDayNight.isNight?(pbGetTimeNow)
    when :LevelDusk then return true if PBDayNight.isDusk?(pbGetTimeNow)
    when :LevelBattle then return true if battle
    when :LevelPartner then return true if $PokemonGlobal.partner || doublebattle
  end
  return false
end

def checkEvoConditionsItem(pokemon, method, condition, useditem)
  return false if condition != useditem

  case method
    when :Item, :TradeItem, :Trade then return true
    when :ItemMale then return true if pokemon.isMale?
    when :ItemFemale then return true if pokemon.isFemale?
  end
  return false
end

def checkEvoConditionsTrade(pokemon, method, condition, tradedmon)
  case method
    when :Trade then return true
    when :TradeItem then return true if pokemon.item == condition
    when :TradeSpecies
      if tradedmon.nil? # Link Stone use
        return true if $Trainer.party.any? { |mon| mon.species == condition && !EVERSTONE_ITEMS.include?(mon.item) }
      else # Actual trade
        return true if tradedmon.species == condition && !EVERSTONE_ITEMS.include?(tradedmon.item)
      end
  end
  return false
end

# Checks whether a Pokemon can evolve now. If a block is given, calls the block
# with the following parameters:
# Pokemon to check; evolution type; level or other parameter; ID of the new Pokemon species
def checkEvolutionEx(pokemon)
  return nil if pokemon.species.nil? || pokemon.isEgg?
  evolutions = pbGetEvolvedFormData(pokemon.species, pokemon.form)
  return nil if evolutions.nil?
  ret = nil
  for evolution in evolutions
    next if !evolution[:location].nil? && !EvoLocations[evolution[:location]].include?($game_map.map_id)
    ret = yield pokemon, evolution[:method], evolution[:parameter], { species: evolution[:species], form: evolution[:form] }
    break unless ret.nil?
  end
  return ret
end

# Checks whether a Pokemon can evolve now. If an item is used on the Pokémon,
# checks whether the Pokemon can evolve with the given item.
def checkEvolution(pokemon, useditem: nil, tradedmon: nil, battle: false, doublebattle: false)
  return nil if EVERSTONE_ITEMS.include?(pokemon.item)

  return checkEvolutionEx(pokemon) { |pokemon, method, condition, evo|
    if tradedmon
      condition = checkEvoConditionsTrade(pokemon, method, condition, tradedmon)
    elsif useditem.nil?
      condition = checkEvoConditions(pokemon, method, condition, battle, doublebattle)
    elsif LINKSTONE_ITEMS.include?(useditem)
      condition = checkEvoConditionsTrade(pokemon, method, condition, nil)
    else
      condition = checkEvoConditionsItem(pokemon, method, condition, useditem)
    end
    next condition ? evo : nil
  }
end

def getEvolutionForm(mon, targetform)
  form = targetform ? targetform : mon.form
  case form
    when :nature then return [:LONELY, :BOLD, :RELAXED, :TIMID, :SERIOUS, :MODEST, :MILD, :QUIET, :BASHFUL, :CALM, :GENTLE, :CAREFUL].include?(mon.nature) ? 1 : 0
    when :personality then return ((mon.personalID >> 16) & 0xFFFF) % 10
    when :rareform then return mon.personalID % 100 == 0 ? 1 : 0
    else return form
  end
end

def pbGetEvolvedFormData(species, form = 0)
  data = $cache.pkmn[species, form].evolutions
  data = nil if !data.nil? && data.empty? # Just to be safe (evolution possibility checks only check existence)
  return data
end

def pbGetPreviousForm(species, form = 0)
  prespecies = species
  preform = form
  if $cache.pkmn[species, form].preevo
    prespecies = $cache.pkmn[species, form].preevo[:species]
    preform = $cache.pkmn[species, form].preevo[:form]
  end
  return [prespecies, preform]
end

def pbCanEvolveToOrFrom?(pkmn1, pkmn2)
  return pbCanEvolveFrom?(pkmn1, pkmn2) || pbCanEvolveFrom?(pkmn2, pkmn1)
end

def pbCanEvolveFrom?(pkmn1, pkmn2)
  current = [pkmn1.species, pkmn1.form]
  loop do
    previous = pbGetPreviousForm(*current)
    break if previous == current
    current = previous
    return true if current == [pkmn2.species, pkmn2.form]
  end
  return false
end

def pbGetBabySpecies(species, form = 0, items: nil)
  prespecies = [nil, nil]
  while species != prespecies[0]
    species = prespecies[0] if !prespecies[0].nil?
    form = prespecies[1] if !prespecies[1].nil?
    prespecies = pbGetPreviousForm(species, form)

    # items are passed when this method is used to generate an egg in the day-care
    if IncenseBabies && !items.nil?
      if (prespecies[0] == :MUNCHLAX && !items.include?(:FULLINCENSE)) ||
         (prespecies[0] == :WYNAUT && !items.include?(:LAXINCENSE)) ||
         (prespecies[0] == :HAPPINY && !items.include?(:LUCKINCENSE)) ||
         (prespecies[0] == :MIMEJR && !items.include?(:ODDINCENSE)) ||
         (prespecies[0] == :CHINGLING && !items.include?(:PUREINCENSE)) ||
         (prespecies[0] == :BONSLY && !items.include?(:ROCKINCENSE)) ||
         (prespecies[0] == :BUDEW && !items.include?(:ROSEINCENSE)) ||
         (prespecies[0] == :AZURILL && !items.include?(:SEAINCENSE)) ||
         (prespecies[0] == :MANTYKE && !items.include?(:WAVEINCENSE))
        break
      end
    end
  end
  return [species, form]
end

# Given a baby species, returns the lowest possible evolution of that species
# assuming no incense is involved.
# passing the form of the mainparent instead of the baby to the function so the right mr.mime gets returned mainly
def pbGetNonIncenseLowestSpecies(baby, parentform)
  case baby
    when :MUNCHLAX    then return [:SNORLAX, parentform]
    when :WYNAUT      then return [:WOBBUFFET, parentform]
    when :HAPPINY     then return [:CHANSEY, parentform]
    when :MIMEJR      then return [:MRMIME, parentform]
    when :CHINGLING   then return [:CHIMECHO, parentform]
    when :BONSLY      then return [:SUDOWOODO, parentform]
    when :BUDEW       then return [:ROSELIA, parentform]
    when :AZURILL     then return [:MARILL, parentform]
    when :MANTYKE     then return [:MANTINE, parentform]
  end
  return [baby, parentform]
end

def gatherEvolutions(species, form = 0, ret = [])
  return ret if ret.include?([species, form])
  ret.push([species, form])
  evos = $cache.pkmn[species, form].evolutions
  evos&.each { |evo|
    form = evo[:form].is_a?(Numeric) ? evo[:form] : form
    gatherEvolutions(evo[:species], form, ret)
  }
  return ret
end

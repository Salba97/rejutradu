################################################################################
# Interpolators
################################################################################
class RectInterpolator
  def initialize(oldrect, newrect, frames)
    restart(oldrect, newrect, frames)
  end

  def restart(oldrect, newrect, frames)
    @oldrect = oldrect
    @newrect = newrect
    @frames = [frames, 1].max
    @curframe = 0
    @rect = oldrect.clone
  end

  def set(rect)
    rect.set(@rect.x, @rect.y, @rect.width, @rect.height)
  end

  def done?
    @curframe > @frames
  end

  def update
    return if done?

    t = (@curframe * 1.0 / @frames)
    x1 = @oldrect.x
    x2 = @newrect.x
    x = x1 + t * (x2 - x1)
    y1 = @oldrect.y
    y2 = @newrect.y
    y = y1 + t * (y2 - y1)
    rx1 = @oldrect.x + @oldrect.width
    rx2 = @newrect.x + @newrect.width
    rx = rx1 + t * (rx2 - rx1)
    ry1 = @oldrect.y + @oldrect.height
    ry2 = @newrect.y + @newrect.height
    ry = ry1 + t * (ry2 - ry1)
    minx = x < rx ? x : rx
    maxx = x > rx ? x : rx
    miny = y < ry ? y : ry
    maxy = y > ry ? y : ry
    @rect.set(minx, miny, maxx - minx, maxy - miny)
    @curframe += 1
  end
end

class PointInterpolator
  def initialize(oldx, oldy, newx, newy, frames)
    restart(oldx, oldy, newx, newy, frames)
  end

  def restart(oldx, oldy, newx, newy, frames)
    @oldx = oldx
    @oldy = oldy
    @newx = newx
    @newy = newy
    @frames = frames
    @curframe = 0
    @x = oldx
    @y = oldy
  end

  def x; @x; end
  def y; @y; end

  def done?
    @curframe > @frames
  end

  def update
    return if done?

    t = (@curframe * 1.0 / @frames)
    rx1 = @oldx
    rx2 = @newx
    @x = rx1 + t * (rx2 - rx1)
    ry1 = @oldy
    ry2 = @newy
    @y = ry1 + t * (ry2 - ry1)
    @curframe += 1
  end
end

################################################################################
# Visibility circle in dark maps
################################################################################
class DarknessSprite < SpriteWrapper
  attr_reader :radius

  def initialize(viewport = nil)
    super(viewport)
    @darkness = BitmapWrapper.new(Graphics.width, Graphics.height)
    @radius = 80
    @radius = 30 if Desolation && $game_switches[946]
    @radius = 999 if Desolation && $game_switches[944]
    self.bitmap = @darkness
    self.z = 99997
    refresh
  end

  def dispose
    @darkness.dispose
    super
  end

  def radius=(value)
    @radius = value
    refresh
  end

  def refresh
    @darkness.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, 255))
    cx = Graphics.width / 2
    cy = Graphics.height / 2
    cradius = @radius
    numfades = 5
    for i in 1..numfades
      for j in cx - cradius..cx + cradius
        diff2 = (cradius * cradius) - ((j - cx) * (j - cx))
        diff = Math.sqrt(diff2)
        @darkness.fill_rect(j, cy - diff, 1, diff * 2, Color.new(0, 0, 0, 255.0 * (numfades - i) / numfades))
      end
      cradius = (cradius * 0.9).floor
    end
  end
end

class OverlaySprite < SpriteWrapper
  attr_reader :radius

  def initialize(viewport = nil)
    super(viewport)
    if $game_variables[:FogName] == 0
      $game_variables[:FogName] = "apollo"
    end
    @fog = RPG::Cache.load_bitmap(sprintf("Graphics/Custom/#{$game_variables[:FogName]}_1"))
    @radius = 80
    @count = 0
    self.bitmap = @fog
    self.z = 99997
    refresh
  end

  def dispose
    @fog.dispose
    super
  end

  def radius=(value)
    @radius = value
    refresh
  end

  def refresh
    @count += 1
    if @count % 5 == 1
      @fog = RPG::Cache.load_bitmap((sprintf("Graphics/Custom/#{$game_variables[:FogName]}_%01d", ((@count / 5) % 8) + 1)))
      self.bitmap = @fog
    end
  end
end

################################################################################
# Location signpost
################################################################################
class PopupWindow
  def initialize(name, viewport = nil)
    @window = Window_AdvancedTextPokemon.new(name)
    @window.viewport = viewport
    @window.resizeToFit(name, Graphics.width)
    @window.setXYZ(0, -@window.height, 99999)
    # Add some padding (enu)
    @window.margin = SpriteWindow_Base::TEXTPADDING
    @window.width += 2
    @frames = 0
  end

  def disposed?
    @window.disposed?
  end

  def dispose
    @window.dispose
  end

  def disposeEarly?
    return $game_temp.message_window_showing
  end

  def update
    return if @window.disposed?

    @window.update
    if disposeEarly?
      @window.dispose
      return
    end
    if @frames > 80
      @window.y -= 4
      @window.dispose if @window.y + @window.height < 0
    else
      @window.y += 4 if @window.y < 0
      @frames += 1
    end
  end
end

class LocationWindow < PopupWindow
  def initialize(name, viewport = nil)
    super
    @currentmap = $game_map.map_id
  end

  def disposeEarly?
    return super || @currentmap != $game_map.map_id
  end
end

################################################################################
# Lights
################################################################################
class LightEffect
  def initialize(event, viewport = nil, map = nil, filename = nil)
    @light = IconSprite.new(0, 0, viewport)
    if filename != nil && filename != "" && pbResolveBitmap("Graphics/Pictures/" + filename)
      @light.setBitmap("Graphics/Pictures/" + filename)
    else
      @light.setBitmap("Graphics/Pictures/LE")
    end
    @light.z = 1000
    @event = event
    @map = map ? map : $game_map
    @disposed = false
  end

  def disposed?
    return @disposed
  end

  def dispose
    @light.dispose
    @map = nil
    @event = nil
    @disposed = true
  end

  def update
    @light.update
  end
end

class LightEffect_Lamp < LightEffect
  def initialize(event, viewport = nil, map = nil)
    @light = Sprite.new(viewport)
    lamp = AnimatedBitmap.new("Graphics/Pictures/LE")
    @light.bitmap = Bitmap.new(128, 64)
    src_rect = Rect.new(0, 0, 64, 64)
    @light.bitmap.blt(0, 0, lamp.bitmap, src_rect)
    @light.bitmap.blt(20, 0, lamp.bitmap, src_rect)
    lamp.dispose
    @light.visible = true
    @light.z = 1000
    @map = map ? map : $game_map
    @event = event
  end
end

def passable?(passages, tile_id)
  return false if tile_id == nil
  return false if passages[tile_id] == nil

  return passages[tile_id] < 15
end

module ScreenPosHelper
  def self.pbScreenZoomX(ch)
    zoom = 1.0
    return Game_Map::TILEWIDTH / 32.0
  end

  def self.pbScreenZoomY(ch)
    return Game_Map::TILEHEIGHT / 32.0
  end

  def self.pbScreenX(ch)
    return ch.screen_x
  end

  def self.pbScreenY(ch)
    return ch.screen_y
  end

  @heightcache = {}

  def self.bmHeight(bm)
    h = @heightcache[bm]
    if !h
      bmap = AnimatedBitmap.new("Graphics/Characters/" + bm, 0)
      h = bmap.height
      @heightcache[bm] = h
      bmap.dispose
    end
    return h
  end

  def self.pbScreenZ(ch, height = nil)
    if height == nil
      height = 0
      if ch.tile_id > 0
        height = 32
      elsif ch.character_name != ""
        height = bmHeight(ch.character_name) / 4
      end
    end
    return ch.screen_z(height)
  end
end

class LightEffect_Basic < LightEffect
  def initialize(event, viewport = nil, map = nil, filename = nil)
    super
  end

  def update
    return if !@light || !@event

    super
    @light.opacity = 100
    @light.ox = 32
    @light.oy = 48
    if (Object.const_defined?(:ScreenPosHelper) rescue false)
      @light.x = ScreenPosHelper.pbScreenX(@event)
      @light.y = ScreenPosHelper.pbScreenY(@event)
      @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
    else
      @light.x = @event.screen_x
      @light.y = @event.screen_y
      @light.zoom_x = 1.0
    end
    @light.zoom_y = @light.zoom_x
    @light.tone = $game_screen.tone
  end
end

class LightEffect_DayNight < LightEffect
  def initialize(event, viewport = nil, map = nil, filename = nil)
    super
  end

  def update
    return if !@light || !@event

    super
    shade = PBDayNight.getShade
    if shade >= 144 # If light enough, call it fully day.
      shade = 255
    elsif shade <= 64 # If dark enough, call it fully night.
      shade = 0
    else
      shade = 255 - (255 * (144 - shade) / (144 - 64))
    end
    @light.opacity = 255 - shade
    if @light.opacity > 0
      @light.ox = 32
      @light.oy = 48
      if (Object.const_defined?(:ScreenPosHelper) rescue false)
        @light.x = ScreenPosHelper.pbScreenX(@event)
        @light.y = ScreenPosHelper.pbScreenY(@event)
        @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
        @light.zoom_y = ScreenPosHelper.pbScreenZoomY(@event)
      else
        @light.x = @event.screen_x
        @light.y = @event.screen_y
        @light.zoom_x = 1.0
        @light.zoom_y = 1.0
      end
      @light.tone.set($game_screen.tone.red, $game_screen.tone.green, $game_screen.tone.blue, $game_screen.tone.gray)
    end
  end
end

################################################################################
# This module stores encounter-modifying events that can happen during the game.
# A procedure can subscribe to an event by adding itself to the event.  It will
# then be called whenever the event occurs.
################################################################################
module EncounterModifier
  @@procs = []
  @@procsEnd = []

  def self.register(p)
    @@procs.push(p)
  end

  def self.registerEncounterEnd(p)
    @@procsEnd.push(p)
  end

  def self.trigger(encounter)
    for prc in @@procs
      encounter = prc.call(encounter)
    end
    return encounter
  end

  def self.triggerEncounterEnd()
    for prc in @@procsEnd
      prc.call()
    end
  end
end

################################################################################
# This module stores events that can happen during the game.  A procedure can
# subscribe to an event by adding itself to the event.  It will then be called
# whenever the event occurs.
################################################################################
module Events
  @@OnMapChange = Event.new
  @@OnMapSceneChange = Event.new
  @@OnMapUpdate = Event.new
  @@OnMapChanging = Event.new
  @@OnLeaveTile = Event.new
  @@OnStepTaken = Event.new
  @@OnStepTakenTransferPossible = Event.new
  @@OnStepTakenFieldMovement = Event.new
  @@OnWildBattleOverride = Event.new
  @@OnWildBattleEnd = Event.new
  @@OnWildPokemonCreate = Event.new
  @@OnTrainerPartyLoad = Event.new
  @@OnSpritesetCreate = Event.new
  @@OnStartBattle = Event.new
  @@OnEndBattle = Event.new
  @@OnMapCreate = Event.new
  @@OnAction = Event.new
  @@OnBossCreate = Event.new
  @@OnDoubleBattleLoad = Event.new
  @@OnBattleFacilityChallenge = Event.new

  # Triggers when the player presses the Action button on the map.
  def self.onAction=(v)
    @@OnAction = v
  end

  def self.onAction
    @@OnAction
  end

  def self.onStartBattle=(v)
    @@OnStartBattle = v
  end

  def self.onStartBattle
    @@OnStartBattle
  end

  def self.onEndBattle=(v)
    @@OnEndBattle = v
  end

  def self.onEndBattle
    @@OnEndBattle
  end

  # Fires whenever a map is created. Event handler receives two parameters: the
  # map (RPG::Map) and the tileset (RPG::Tileset)
  def self.onMapCreate=(v)
    @@OnMapCreate = v
  end

  def self.onMapCreate
    @@OnMapCreate
  end

  # Fires whenever the player moves to a new map. Event handler receives the old
  # map ID or 0 if none.  Also fires when the first map of the game is loaded
  def self.onMapChange=(v)
    @@OnMapChange = v
  end

  def self.onMapChange
    @@OnMapChange
  end

  # Fires whenever one map is about to change to a different one. Event handler
  # receives the new map ID and the Game_Map object representing the new map.
  # When the event handler is called, $game_map still refers to the old map.
  def self.onMapChanging=(v)
    @@OnMapChanging = v
  end

  def self.onMapChanging
    @@OnMapChanging
  end

  # Fires whenever the player takes a step.
  def self.onStepTaken=(v)
    @@OnStepTaken = v
  end

  def self.onStepTaken
    @@OnStepTaken
  end

  # Fires whenever the player or another event leaves a tile.
  # Parameters:
  # e[0] - Event that just left the tile.
  # e[1] - Map ID where the tile is located (not necessarily
  #  the current map). Use "$MapFactory.getMap(e[1])" to
  #  get the Game_Map object corresponding to that map.
  # e[2] - X-coordinate of the tile
  # e[3] - Y-coordinate of the tile
  def self.onLeaveTile=(v)
    @@OnLeaveTile = v
  end

  def self.onLeaveTile
    @@OnLeaveTile
  end

  # Fires whenever the player or another event enters a tile.
  # Parameters:
  # e[0] - Event that just entered a tile.
  def self.onStepTakenFieldMovement=(v)
    @@OnStepTakenFieldMovement = v
  end

  def self.onStepTakenFieldMovement
    @@OnStepTakenFieldMovement
  end

  # Fires whenever the player takes a step. The event handler may possibly move
  # the player elsewhere.
  # Parameters:
  # e[0] = Array that contains a single boolean value.
  #  If an event handler moves the player to a new map, it should set this value
  # to true. Other event handlers should check this parameter's value.
  def self.onStepTakenTransferPossible=(v)
    @@OnStepTakenTransferPossible = v
  end

  def self.onStepTakenTransferPossible
    @@OnStepTakenTransferPossible
  end

  # Fires each frame during a map update.
  def self.onMapUpdate=(v)
    @@OnMapUpdate = v
  end

  def self.onMapUpdate
    @@OnMapUpdate
  end

  # Triggers at the start of a wild battle.  Event handlers can provide their own
  # wild battle routines to override the default behavior.
  def self.onWildBattleOverride=(v)
    @@OnWildBattleOverride = v
  end

  def self.onWildBattleOverride
    @@OnWildBattleOverride
  end

  # Triggers whenever a wild Pokémon battle ends
  # Parameters:
  # e[0] - Pokémon species
  # e[1] - Pokémon form
  # e[2] - Pokémon level
  # e[3] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
  def self.onWildBattleEnd=(v)
    @@OnWildBattleEnd = v
  end

  def self.onWildBattleEnd
    @@OnWildBattleEnd
  end

  # Triggers whenever a wild Pokémon is created
  # Parameters:
  # e[0] - Pokémon being created
  def self.onWildPokemonCreate=(v)
    @@OnWildPokemonCreate = v
  end

  def self.onWildPokemonCreate
    @@OnWildPokemonCreate
  end

  # Triggers whenever a boss Pokémon is created
  # Parameters:
  # e[0] - Boss being created
  def self.onBossCreate=(v)
    @@OnBossCreate = v
  end

  def self.onBossCreate
    @@OnBossCreate
  end

  # Triggers whenever an NPC trainer's Pokémon party is loaded
  # Parameters:
  # e[0] - Trainer
  # e[1] - Items possessed by the trainer
  # e[2] - Party
  def self.onTrainerPartyLoad=(v)
    @@OnTrainerPartyLoad = v
  end

  def self.onTrainerPartyLoad
    @@OnTrainerPartyLoad
  end

  # Triggers whenever an double battle happens (after regular Event triggers)
  # Parameters:
  # e[0] - first object
  # e[1] - second object
  def self.onDoubleBattleLoad=(v)
    @@OnDoubleBattleLoad = v
  end

  def self.onDoubleBattleLoad
    @@OnDoubleBattleLoad
  end

  # Triggers whenever an NPC trainer's Pokémon party is loaded
  # Parameters:
  # e[0] - Trainer
  # e[1] - Items possessed by the trainer
  # e[2] - Party
  def self.onBattleFacilityChallenge=(v)
    @@OnBattleFacilityChallenge = v
  end

  def self.onBattleFacilityChallenge
    @@OnBattleFacilityChallenge
  end

  # Fires whenever the map scene is regenerated and soon after the player moves
  # to a new map.
  # Parameters:
  # e[0] = Scene_Map object.
  # e[1] = Whether the player just moved to a new map (either true or false).  If
  #   false, some other code had called $scene.createSpritesets to regenerate the
  #   map scene without transferring the player elsewhere
  def self.onMapSceneChange=(v)
    @@OnMapSceneChange = v
  end

  def self.onMapSceneChange
    @@OnMapSceneChange
  end

  # Fires whenever a spriteset is created.
  # Parameters:
  # e[0] = Spriteset being created
  # e[1] = Viewport used for tilemap and characters
  # e[0].map = Map associated with the spriteset (not necessarily the current map).
  def self.onSpritesetCreate=(v)
    @@OnSpritesetCreate = v
  end

  def self.onSpritesetCreate
    @@OnSpritesetCreate
  end
end

################################################################################
# Terrain tags
################################################################################
class PBTerrain
  Ledge           = 1
  Grass           = 2
  Sand            = 3
  Rock            = 4
  DeepWater       = 5
  StillWater      = 6
  Water           = 7
  Waterfall       = 8
  WaterfallCrest  = 9
  TallGrass       = 10
  UnderwaterGrass = 11
  Ice             = 12
  Neutral         = 13 # Overrides water tag to prevent fishing when placed on top of a water tile.
  SootGrass       = 14
  Bridge          = 15
  Puddle          = 16
  Grime           = 17
  PokePuddle      = 18
  Glass           = 19
  DownConveyor    = 20
  LeftConveyor    = 21
  RightConveyor   = 22
  UpConveyor      = 23
  SandDune        = 24
  PokeSand        = 25
  Lava            = 26
  StairUpRight    = 27
  StairUpLeft     = 28
  StillDeepWater  = 29
end

def pbIsSurfableTag?(tag)
  return pbIsWaterTag?(tag)
end

def pbIsWaterTag?(tag)
  return pbIsPassableWaterTag?(tag) || tag == PBTerrain::Waterfall
end

def pbIsLavaTag?(tag)
  return tag == PBTerrain::Lava
end

def pbIsGrimeTag?(tag)
  return tag == PBTerrain::Grime
end

def pbIsPassableLavaTag?(tag)
  return tag == PBTerrain::Lava
end

def pbIsPassableWaterTag?(tag)
  return pbIsJustWaterTag?(tag) || tag == PBTerrain::WaterfallCrest
end

def pbIsJustWaterTag?(tag)
  # Suppress surfing while on a bridge across water.
  return false if $game_switches[:WaterWalk]
  return [PBTerrain::DeepWater, PBTerrain::StillDeepWater, PBTerrain::Water, PBTerrain::StillWater].include?(tag)
end

def pbIsConveyorTag?(tag)
  return [PBTerrain::DownConveyor, PBTerrain::LeftConveyor, PBTerrain::RightConveyor, PBTerrain::UpConveyor].include?(tag)
end

def pbIsGrassTag?(tag)
  return [PBTerrain::Grass, PBTerrain::TallGrass, PBTerrain::UnderwaterGrass, PBTerrain::PokePuddle].include?(tag) ||
         (tag == PBTerrain::Sand && !Rejuv) ||
         (tag == PBTerrain::PokeSand && Rejuv)
end

def pbIsJustGrassTag?(tag)
  return tag == PBTerrain::Grass
end

def pbIsDiagonalStairTag?(tag)
  return [PBTerrain::StairUpRight, PBTerrain::StairUpLeft].include?(tag)
end

def pbIsReflectiveTag?(tag)
  return [PBTerrain::StillWater, PBTerrain::StillDeepWater, PBTerrain::Puddle, PBTerrain::PokePuddle, PBTerrain::Glass].include?(tag)
end

def pbIsDeepWaterTag?(tag)
  return [PBTerrain::DeepWater, PBTerrain::StillDeepWater].include?(tag)
end

################################################################################
# Battles
################################################################################
class Game_Temp
  attr_accessor :background_bitmap
end

def pbNewBattleScene
  return PokeBattle_Scene.new
end

def pbSceneStandby
  if $scene && $scene.is_a?(Scene_Map)
    $scene.disposeSpritesets
  end
  GC.start
  RPG::Cache.clear
  Graphics.frame_reset
  yield
  if $scene && $scene.is_a?(Scene_Map)
    $scene.createSpritesets
  end
end

def getVsTrainerSprite(trainerID, outfit = 0, playersided: false)
  sidemarkers = playersided ? ["Player", "Trainer"] : ["Trainer", "Player"]
  outfitstr = outfit == 0 ? "" : sprintf("_%d", outfit)

  for sidemarker in sidemarkers
    tgraphic = sprintf("Graphics/Transitions/vs%s%s%s", sidemarker, $cache.trainertypes[trainerID].checkFlag?(:ID), outfitstr)
    mirror = sidemarkers.index(sidemarker) == 1
    return tgraphic, mirror if pbResolveBitmap(tgraphic)
  end
  # rerun this method without the outfit if no vs sprite was able to be found, will return nil, false if none could be found then either.
  return getVsTrainerSprite(trainerID, 0, playersided: playersided) if outfit > 0
  return nil, false
end

def pbBattleAnimation(bgm = nil, trainerid = -1, trainername = "", switch_sprites = false, vsoutfit = 0)
  handled = false
  savedBGS, savedBGM, savedBGMpos = pbPauseMusicToResumeLater
  pbMEFade(0.25)
  pbWait(10)
  pbMEStop
  bgm ? pbBGMPlay(bgm) : pbBGMPlay(pbGetWildBattleBGM(0))
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  $game_temp.vs_window_main = viewport if defined?(ZoomMap)
  # Fade to gray a few times.
  if $Settings.photosensitive == 0 && !$game_switches[:SpeedSkip_Password] && !$game_switches[:Blindstep]
    viewport.color = Color.new(17 * 8, 17 * 8, 17 * 8)
    2.times do
      viewport.color.alpha = 0
      4.times do
        viewport.color.alpha += 45
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
      4.times do
        viewport.color.alpha -= 45
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
  end

  ################################################################################
  # VS. animation, by Luka S.J.
  # Tweaked by Maruno.
  # Tweaked by Perry to allow for doubles!
  ###############################################################################
  if vsoutfit != 0 && vsoutfit != [0, 0]
    if trainerid.is_a?(Array)
      tbargraphic = sprintf("Graphics/Transitions/vsBar%s_%d", $cache.trainertypes[trainerid[0]].checkFlag?(:ID), vsoutfit[0])
      tbargraphic2 = sprintf("Graphics/Transitions/vsBar%s_%d", $cache.trainertypes[trainerid[1]].checkFlag?(:ID), vsoutfit[1])
      tbargraphic = sprintf("Graphics/Transitions/vsBar%s", $cache.trainertypes[trainerid[0]].checkFlag?(:ID)) if !pbResolveBitmap(tbargraphic)
      tbargraphic2 = sprintf("Graphics/Transitions/vsBar%s", $cache.trainertypes[trainerid[1]].checkFlag?(:ID)) if !pbResolveBitmap(tbargraphic2)
      tgraphic, mirrorOpp = getVsTrainerSprite(trainerid[0], vsoutfit[0])
      tgraphic2, mirrorOpp2 = getVsTrainerSprite(trainerid[1], vsoutfit[1])
    elsif !$cache.trainertypes[trainerid].nil?
      tbargraphic = sprintf("Graphics/Transitions/vsBar%s_%d", $cache.trainertypes[trainerid].checkFlag?(:ID), vsoutfit)
      tbargraphic = sprintf("Graphics/Transitions/vsBar%s", $cache.trainertypes[trainerid].checkFlag?(:ID)) if !pbResolveBitmap(tbargraphic)
      tgraphic, mirrorOpp = getVsTrainerSprite(trainerid, vsoutfit)
    end
  else
    if trainerid.is_a?(Array)
      tbargraphic = sprintf("Graphics/Transitions/vsBar%s", $cache.trainertypes[trainerid[0]].checkFlag?(:ID))
      tbargraphic2 = sprintf("Graphics/Transitions/vsBar%s", $cache.trainertypes[trainerid[1]].checkFlag?(:ID))
      tgraphic, mirrorOpp = getVsTrainerSprite(trainerid[0])
      tgraphic2, mirrorOpp2 = getVsTrainerSprite(trainerid[1])
    elsif !$cache.trainertypes[trainerid].nil?
      tbargraphic = sprintf("Graphics/Transitions/vsBar%s", $cache.trainertypes[trainerid].checkFlag?(:ID))
      if Reborn && AlterEgos.include?(trainerid)
        player = $cache.metadata[:Players].find { |player| player[:tclass] == $Trainer.trainertype }
        tgraphic = sprintf("Graphics/Characters/%s/%s%s", player[:directory], player[:vstrainer], "Alt")
        mirrorOpp = false
      else
        tgraphic, mirrorOpp = getVsTrainerSprite(trainerid)
      end
    end
  end
  if $PokemonGlobal.partner
    partnergraphic, mirrorPartner = getVsTrainerSprite($PokemonGlobal.partner[0], playersided: true)
  end
  if ((trainerid.is_a?(Array) && ((pbResolveBitmap(tbargraphic) && pbResolveBitmap(tgraphic)) ||
    (pbResolveBitmap(tbargraphic2) && pbResolveBitmap(tgraphic2)))) ||
    (pbResolveBitmap(tbargraphic) && pbResolveBitmap(tgraphic))) && !$game_switches[:VSGraphicOff]
    outfit = $Trainer ? $Trainer.outfit : 0
    # Set up
    viewplayer = Viewport.new(0, Graphics.height / 3, Graphics.width / 2, 128)
    viewplayer.z = viewport.z
    viewopp = Viewport.new(Graphics.width / 2, Graphics.height / 3, Graphics.width / 2, 128)
    viewopp.z = viewport.z
    viewvs = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewvs.z = viewport.z
    if defined?(ZoomMap)
      $game_temp.vs_window_player = viewplayer
      $game_temp.vs_window_opp = viewopp
      $game_temp.vs_window_vs = viewvs
    end
    xoffset = (Graphics.width / 2) / 10
    xoffset = xoffset.round
    xoffset = xoffset * 10

    fade = Sprite.new(viewport)
    fade.bitmap = RPG::Cache.transition("Graphics/Transitions/vsFlash")
    fade.tone = Tone.new(-255, -255, -255)
    fade.opacity = 100
    overlay = Sprite.new(viewport)
    overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(overlay.bitmap)

    bar1 = Sprite.new(viewplayer)
    pbargraphic = sprintf("Graphics/Transitions/vsBar%d_%d", $cache.trainertypes[$Trainer.trainertype].checkFlag?(:ID), outfit)
    pbargraphic = sprintf("Graphics/Transitions/vsBar%d", $cache.trainertypes[$Trainer.trainertype].checkFlag?(:ID)) if !pbResolveBitmap(pbargraphic)
    pbargraphic = sprintf("Graphics/Transitions/vsBar263") if Rejuv && $cache.trainertypes[$Trainer.trainertype].checkFlag?(:player) && outfit == 8
    bar1.bitmap = RPG::Cache.transition(pbargraphic)
    bar1.x = -xoffset
    bar2 = Sprite.new(viewopp)
    if trainerid.is_a?(Array) && !pbResolveBitmap(tgraphic)
      bar2.bitmap = RPG::Cache.transition(tbargraphic2)
    else
      bar2.bitmap = RPG::Cache.transition(tbargraphic)
    end
    bar2.x = xoffset

    vs = Sprite.new(viewvs)
    vs.bitmap = RPG::Cache.transition("Graphics/Transitions/vs")
    vs.ox = vs.bitmap.width / 2
    vs.oy = vs.bitmap.height / 2
    vs.x = Graphics.width / 2
    vs.y = Graphics.height / 1.5
    vs.visible = false
    flash = Sprite.new(viewvs)
    flash.bitmap = RPG::Cache.transition("Graphics/Transitions/vsFlash")
    flash.opacity = 0

    # Animation
    10.times do
      bar1.x += xoffset / 10
      bar2.x -= xoffset / 10
      pbWait(1)
    end
    pbSEPlay("PRSFX- Counter2")
    pbSEPlay("PRSFX- Flash")
    flash.opacity = 255 if $Settings.photosensitive == 0
    bar1.dispose
    bar2.dispose

    bar1 = AnimatedPlane.new(viewplayer)
    bar1.bitmap = RPG::Cache.transition(pbargraphic)
    player = Sprite.new(viewplayer)
    if Reborn && isProtagonistTrainerType?($Trainer.trainertype)
      type = $cache.metadata[:Players].find { |value| value[:tclass] == $Trainer.trainertype }
      pgraphic = sprintf(
        "Graphics/Characters/%s/%s",
        type[:directory] + ($Trainer.outfit > 0 ? " " + $Trainer.outfit.to_s : ""),
        type[:vstrainer],
      )
      mirrorPlayer = false
    else
      pgraphic, mirrorPlayer = getVsTrainerSprite($Trainer.trainertype, outfit, playersided: true)
      if Rejuv && $cache.trainertypes[$Trainer.trainertype].checkFlag?(:player)
        case outfit
          when 8 then pgraphic, mirrorPlayer = getVsTrainerSprite(:INTERCEPTORARMOR, 8, playersided: true)
          when 10, 11 then pgraphic, mirrorPlayer = getVsTrainerSprite(:INTERCEPTORARMOR, 1, playersided: true)
        end
      end
    end
    player.bitmap = RPG::Cache.transition(pgraphic)
    player.x = -xoffset
    player.mirror = true if mirrorPlayer
    partner = nil
    if $PokemonGlobal.partner && pbResolveBitmap(partnergraphic)
      partner = Sprite.new(viewplayer)
      partner.bitmap = RPG::Cache.transition(partnergraphic)
      partner.x = -xoffset + partner.width / 30
      player.x -= partner.width / 4.5
      partner.mirror = true if mirrorPartner
    end
    bar2 = AnimatedPlane.new(viewopp)
    if trainerid.is_a?(Array) && !pbResolveBitmap(tgraphic)
      bar2.bitmap = RPG::Cache.transition(tbargraphic2)
    else
      bar2.bitmap = RPG::Cache.transition(tbargraphic)
    end
    if pbResolveBitmap(tgraphic)
      trainer = Sprite.new(viewopp)
      trainer.bitmap = RPG::Cache.transition(tgraphic)
      trainer.x = xoffset
      trainer.mirror = true if mirrorOpp
      trainer.tone = Tone.new(-255, -255, -255)
      trainer.visible = false if trainer
    end
    if trainerid.is_a?(Array) && pbResolveBitmap(tgraphic2)
      trainer2 = Sprite.new(viewopp)
      trainer2.bitmap = RPG::Cache.transition(tgraphic2)
      trainer2.x = xoffset
      trainer2.mirror = true if mirrorOpp2
      trainer2.tone = Tone.new(-255, -255, -255)
      trainer2.visible = false if trainer2
    end
    if trainerid.is_a?(Array) && pbResolveBitmap(tgraphic) && pbResolveBitmap(tgraphic2)
      if switch_sprites
        trainer.x += trainer2.width / 4.5
        trainer2.x += trainer2.width / 30
      else
        trainer.x += trainer2.width / 30
        trainer2.x += trainer2.width / 4.5
      end
    end
    partner.visible = false if partner

    25.times do
      flash.opacity -= 51 if flash.opacity > 0
      bar1.ox -= 16
      bar2.ox += 16
      pbWait(1)
    end
    trainer.visible = true if trainer
    trainer2.visible = true if trainer2
    partner.visible = true if partner
    11.times do
      bar1.ox -= 16
      bar2.ox += 16
      player.x += xoffset / 10
      partner.x += xoffset / 10 if partner
      trainer.x -= xoffset / 10 if trainer
      trainer2.x -= xoffset / 10 if trainer2
      pbWait(1)
    end
    2.times do
      bar1.ox -= 16
      bar2.ox += 16
      player.x -= xoffset / 20
      partner.x += xoffset / 20 if partner
      if switch_sprites && trainer && trainer2
        trainer.x += xoffset / 20
        trainer2.x -= xoffset / 20
      elsif trainer && !trainer2
        trainer.x += xoffset / 20
      elsif trainer2 && !trainer
        trainer2.x += xoffset / 20
      else
        trainer.x -= xoffset / 20 if trainer
        trainer2.x += xoffset / 20 if trainer2
      end
      pbWait(1)
    end
    10.times do
      bar1.ox -= 16
      bar2.ox += 16
      pbWait(1)
    end
    val = 2
    flash.opacity = 255 if $Settings.photosensitive == 0
    vs.visible = true
    trainer.tone = Tone.new(0, 0, 0) if trainer
    trainer2.tone = Tone.new(0, 0, 0) if trainer2
    # Opponents name
    if trainerid.is_a?(Array) && pbResolveBitmap(tgraphic) && pbResolveBitmap(tgraphic2)
      trainername = _INTL("{1} & {2}", trainername[0], trainername[1])
    elsif trainerid.is_a?(Array) && pbResolveBitmap(tgraphic)
      trainername = trainername[0]
    elsif trainerid.is_a?(Array) && pbResolveBitmap(tgraphic2)
      trainername = trainername[1]
    end
    trainername2 = ""
    if trainername.length > 16
      splits = trainername.split(/ /, trainername[0, 16].split(/ /).length)
      trainername2 = splits.delete_at(-1)
      trainername = splits.join(" ")
    end

    # player name
    playername = $Trainer.name
    if $PokemonGlobal.partner && pbResolveBitmap(partnergraphic)
      playername =  _INTL("{1} & {2}", $Trainer.name, $PokemonGlobal.partner[1])
    end
    playername2 = ""
    if playername.length > 16
      splits = playername.split(/ /, playername[0, 16].split(/ /).length)
      playername2 = splits.delete_at(-1)
      playername = splits.join(" ")
    end
    # placing names
    textpos = [
      [playername, Graphics.width / 4 - 16, (Graphics.height / 1.5) + 10, 2, Color.new(248, 248, 248), Color.new(72, 72, 72)],
      [trainername, (3 * Graphics.width / 4) + 16, (Graphics.height / 1.5) + 10, 2, Color.new(248, 248, 248), Color.new(72, 72, 72)]
    ]
    textpos.push([trainername2, (3 * Graphics.width / 4) + 16, (Graphics.height / 1.5) + 42, 2, Color.new(248, 248, 248), Color.new(72, 72, 72)]) if trainername2 != ""
    textpos.push([playername2, Graphics.width / 4 - 16, (Graphics.height / 1.5) + 42, 2, Color.new(248, 248, 248), Color.new(72, 72, 72)]) if playername2 != ""
    pbDrawTextPositions(overlay.bitmap, textpos)

    pbSEPlay("Sword2")
    70.times do
      bar1.ox -= 16
      bar2.ox += 16
      flash.opacity -= 25.5 if flash.opacity > 0
      vs.x += val
      vs.y -= val
      val = 2 if vs.x <= (Graphics.width / 2) - 2
      val = -2 if vs.x >= (Graphics.width / 2) + 2
      pbWait(1)
    end
    30.times do
      bar1.ox -= 16
      bar2.ox += 16
      vs.zoom_x += 0.2
      vs.zoom_y += 0.2
      pbWait(1)
    end
    flash.tone = Tone.new(-255, -255, -255)
    10.times do
      bar1.ox -= 16
      bar2.ox += 16
      flash.opacity += 25.5
      pbWait(1)
    end
    # End
    player.dispose
    partner.dispose if partner
    trainer.dispose if trainer
    trainer2.dispose if trainer2
    flash.dispose
    vs.dispose
    bar1.dispose
    bar2.dispose
    overlay.dispose
    fade.dispose
    viewvs.dispose
    viewopp.dispose
    viewplayer.dispose
    viewport.color = Color.new(0, 0, 0, 255)
    handled = true
  end
  ################################################################################
  # End of VS. sequence script
  ################################################################################

  # Placed here so that the auto-turbo-toggle for battles happens after the VS anim
  Events.onStartBattle.trigger

  if !handled && !$game_switches[:Blindstep]
    if Sprite.method_defined?(:wave_amp) && rand(15) == 0
      viewport.color = Color.new(0, 0, 0, 255)
      sprite = Sprite.new
      bitmap = Graphics.snap_to_bitmap
      bm = bitmap.clone
      sprite.z = 99999
      sprite.bitmap = bm
      sprite.wave_speed = 500
      for i in 0..25
        sprite.opacity -= 10
        sprite.wave_amp += 60
        sprite.update
        sprite.wave_speed += 30
        Graphics.update
      end
      bitmap.dispose
      bm.dispose
      sprite.dispose
    elsif Bitmap.method_defined?(:radial_blur) && rand(15) == 0
      viewport.color = Color.new(0, 0, 0, 255)
      sprite = Sprite.new
      bitmap = Graphics.snap_to_bitmap
      bm = bitmap.clone
      sprite.z = 99999
      sprite.bitmap = bm
      for i in 0..15
        bm.radial_blur(i, 2)
        sprite.opacity -= 15
        Graphics.update
      end
      bitmap.dispose
      bm.dispose
      sprite.dispose
    else
      transitions = [
        "021-Normal01", "022-Normal02",
        "Battle", "battle1", "battle2", "battle3", "battle4",
        "computertr", "computertrclose",
        "hexatr", "hexatrc", "hexatzr",
      ]

      Graphics.freeze
      viewport.color = Color.new(0, 0, 0, 255)
      Graphics.transition(20, sprintf("Graphics/Transitions/%s", transitions.sample))
    end
    5.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  pbPushFade
  continue = yield if block_given?
  pbPopFade
  if continue
    pbResumePausedMusic(savedBGS, savedBGM, savedBGMpos)
  else
    $game_system.bgm_unpause
    $game_system.bgs_unpause
    Kernel.pbStartOver
  end
  $PokemonGlobal.nextBattleBGM = nil
  $PokemonGlobal.nextBattleVictoryBGM = nil
  $PokemonGlobal.nextBattleBack = nil
  $PokemonEncounters.clearStepCount
  for j in 0..17
    viewport.color = Color.new(0, 0, 0, (17 - j) * 15)
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
  viewport.dispose
end

def pbGetEnvironment
  return :None if !$game_map
  if $PokemonGlobal && $PokemonGlobal.diving
    return :Underwater
  elsif $PokemonEncounters && $PokemonEncounters.isCave?
    return :Cave
  elsif !$cache.mapdata[$game_map.map_id].Outdoor
    return :None
  else
    case $game_player.terrain_tag
      when PBTerrain::Grass       then return :Grass
      when PBTerrain::TallGrass   then return :TallGrass
      when PBTerrain::DeepWater, PBTerrain::Water then return :MovingWater
      when PBTerrain::StillWater, PBTerrain::StillDeepWater then return :StillWater
      when PBTerrain::Rock        then return :Rock
      when PBTerrain::Sand, PBTerrain::PokeSand then return :Sand
    end
    return :None
  end
end

def pbGenerateWildPokemon(species, level, form = nil)
  bossdata = $cache.bosses
  bossspecies = species
  return pbLoadWildBoss(bossspecies, bossdata) if bossdata[bossspecies]

  genwildpoke = PokeBattle_Pokemon.new(species, level, $Trainer, true, $PokemonEncounters.pbDetermineForm(form))
  Events.onWildPokemonCreate.trigger(nil, genwildpoke)
  return genwildpoke
end

# For use in repeatable static pokemon events (eg, Exeggutor in Tourmaline)
def pbGetOWWildMon(symbol)
  mapid = $game_map.map_id
  return nil unless mapid
  encounters = $cache.mapdata[mapid]&.OverworldEncs
  return nil unless encounters && encounters[symbol]

  species = encounters[symbol][:species]
  if species.is_a?(Array)
    form = species[1]
    species = species[0]
  else
    form = 0
  end
  level = encounters[symbol][:level]
  level = level.to_a.sample if level.is_a?(Range)
  return pbGenerateWildPokemon(species, level, form)
end

def fieldAbilityUser
  return $Trainer.party[0]
end

def pbWildBattle(species, level, variable = Variables[:BattleResult], canescape = true, canlose = false)
  return pbWildBattleObject(pbGenerateWildPokemon(species, level), variable, canescape, canlose)
end

def pbWildBattleObject(pokemon, variable = Variables[:BattleResult], canescape = true, canlose = false)
  return if pokemon.nil?

  pokemon = PokeBattle_Pokemon::PokemonBuilder.new(pokemon).build if pokemon.is_a?(Hash)

  $game_temp.in_battle = true
  if ($DEBUG && Input.press?(Input::CTRL)) || $Trainer.pokemonCount == 0
    if $Trainer.pokemonCount > 0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    pbSet(variable, 1)
    $PokemonGlobal.nextBattleBGM = nil
    $PokemonGlobal.nextBattleVictoryBGM = nil
    $PokemonGlobal.nextBattleBack = nil
    $game_temp.in_battle = false
    return true
  end
  handled = [nil]
  Events.onWildBattleOverride.trigger(nil, pokemon.species, pokemon.form, pokemon.level, handled)
  if handled[0] != nil
    $game_temp.in_battle = false
    return handled[0]
  end
  scene = pbNewBattleScene
  if $PokemonGlobal.partner && pokemon.isbossmon
    othertrainer = PokeBattle_Trainer.new(
      $PokemonGlobal.partner[1], $PokemonGlobal.partner[0]
    )
    othertrainer.id = $PokemonGlobal.partner[2]
    othertrainer.party = $PokemonGlobal.partner[3]
    battle = PokeBattle_Battle.new(scene, [$Trainer.party, othertrainer.party], [[pokemon]], [$Trainer, othertrainer], nil)
    battle.partneritems = $PokemonGlobal.partner[4]
    battle.doublebattle = true
  else
    battle = PokeBattle_Battle.new(scene, [$Trainer.party], [[pokemon]], $Trainer, nil)
  end
  battle.internalbattle = true
  battle.cantescape = !canescape
  pbPrepareBattle(battle)
  decision = 0
  if isTwoVsOneBoss?(pokemon) || $PokemonTemp.waitingTrainer
    battle.doublebattle = true
  end
  pbBattleAnimation(pbGetWildBattleBGM(pokemon.species)) {
    pbSceneStandby {
      decision = battle.pbStartBattle(canlose)
    }
    pbHealPartner
    if [2, 5].include?(decision) # if loss or draw
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
      else
        if pbMapInterpreterRunning?
          pbMapInterpreter.exitFallback
        end
      end
    end
    Events.onEndBattle.trigger(nil, decision)
    next ![2, 5].include?(decision) || canlose
  }
  Input.update
  pbSet(variable, decision)
  Events.onWildBattleEnd.trigger(nil, pokemon.species, pokemon.form, pokemon.level, decision)
  bossHandler(decision, pokemon)
  $game_temp.in_battle = false
  return true if canlose
  return ![2, 5].include?(decision)
end

def pbDoubleWildBattle(species1, level1, species2, level2, variable = Variables[:BattleResult], canescape = true, canlose = false)
  return pbDoubleWildBattleObjects(pbGenerateWildPokemon(species1, level1), pbGenerateWildPokemon(species2, level2), variable, canescape, canlose)
end

def pbDoubleWildBattleObjects(pokemon, pokemon2, variable = Variables[:BattleResult], canescape = true, canlose = false)
  $game_temp.in_battle = true
  if ($DEBUG && Input.press?(Input::CTRL)) || $Trainer.pokemonCount == 0
    if $Trainer.pokemonCount > 0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    pbSet(variable, 1)
    $PokemonGlobal.nextBattleBGM = nil
    $PokemonGlobal.nextBattleVictoryBGM = nil
    $PokemonGlobal.nextBattleBack = nil
    $game_temp.in_battle = false
    return true
  end
  pokemon = PokeBattle_Pokemon::PokemonBuilder.new(pokemon).build if pokemon.is_a?(Hash)
  pokemon2 = PokeBattle_Pokemon::PokemonBuilder.new(pokemon2).build if pokemon2.is_a?(Hash)
  Events.onDoubleBattleLoad.trigger("pokemon", pokemon, pokemon2)
  scene = pbNewBattleScene
  if $PokemonGlobal.partner
    othertrainer = PokeBattle_Trainer.new(
      $PokemonGlobal.partner[1], $PokemonGlobal.partner[0]
    )
    othertrainer.id = $PokemonGlobal.partner[2]
    othertrainer.party = $PokemonGlobal.partner[3]
    battle = PokeBattle_Battle.new(scene, [$Trainer.party, othertrainer.party], [[pokemon, pokemon2]], [$Trainer, othertrainer], nil)
    battle.partneritems = $PokemonGlobal.partner[4]
  else
    battle = PokeBattle_Battle.new(scene, [$Trainer.party], [[pokemon, pokemon2]], $Trainer, nil)
  end
  battle.internalbattle = true
  battle.doublebattle = true
  battle.cantescape = !canescape
  pbPrepareBattle(battle)
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(pokemon.species)) {
    pbSceneStandby {
      decision = battle.pbStartBattle(canlose)
    }
    pbHealPartner
    if [2, 5].include?(decision)
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
      else
        if pbMapInterpreterRunning?
          pbMapInterpreter.exitFallback
        end
      end
    end
    Events.onEndBattle.trigger(nil, decision)
    next ![2, 5].include?(decision) || canlose
  }
  Input.update
  pbSet(variable, decision)
  $game_temp.in_battle = false
  return true if canlose
  return ![2, 5].include?(decision)
end

def pbCheckAllFainted()
  if pbAllFainted
    Kernel.pbMessage(_INTL("{1} has no usable Pokémon!\1", $Trainer.name))
    Kernel.pbMessage(_INTL("{1} blacked out!", $Trainer.name))
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    pbFadeOutIn(99999) {
      Kernel.pbStartOver
    }
  end
end

# Runs the Pickup event after a battle if a Pokemon has the ability Pickup.
def Kernel.pbPickup(pokemon)
  return if pokemon.ability != :PICKUP || pokemon.isEgg?
  return if !pokemon.item.nil?
  return if rand(10) != 0

  pickupList = PickupNormal

  pickupListRare = PickupRare
  return if pickupList.length != 18
  return if pickupListRare.length != 11

  randlist = [30, 10, 10, 10, 10, 10, 10, 4, 4, 1, 1]
  items = []
  plevel = [100, pokemon.level].min
  rnd = rand(100)
  itemstart = (plevel - 1) / 10
  itemstart = 0 if itemstart < 0
  for i in 0...9
    items.push(pickupList[i + itemstart])
  end
  items.push(pickupListRare[itemstart])
  items.push(pickupListRare[itemstart + 1])
  cumnumber = 0
  for i in 0...11
    cumnumber += randlist[i]
    if rnd < cumnumber
      return items[i]
    end
  end
end

# Runs the Pickup event after a battle if a Pokemon has the ability Pickup.
def Kernel.pbRunPickup(pokemon)
  return if pokemon.ability != :PICKUP || pokemon.isEgg?
  return if !pokemon.item.nil?

  item = Kernel.pbPickup(pokemon)
  return if item.nil?

  if $PokemonBag.pbCanStore?(item)
    $PokemonBag.pbStoreItem(item)
  else
    pokemon.setItem(item)
  end
  Kernel.pbMessage(_INTL("{1} picked up {2}!", pokemon.name, getItemName(item, :a)))
end

class PokemonTemp
  attr_accessor :encounterType
  attr_accessor :walkingMon
  attr_accessor :walkEvo
  attr_accessor :delayedShedinjaEvos
  attr_accessor :battleStolenItems
end

def pbEncounter(enctype)
  if $PokemonGlobal.partner || (Reborn && makeDoubles?())
    encounter1 = $PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter1

    encounter2 = $PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter2

    $PokemonTemp.encounterType = enctype
    pbDoubleWildBattleObjects(
      pbGenerateWildPokemon(encounter1[0], encounter1[2], encounter1[1]),
      pbGenerateWildPokemon(encounter2[0], encounter2[2], encounter2[1]),
    )
    $PokemonTemp.encounterType = -1
    return true
  else
    encounter = $PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter

    $PokemonTemp.encounterType = enctype
    pbWildBattleObject(pbGenerateWildPokemon(encounter[0], encounter[2], encounter[1]))
    $PokemonTemp.encounterType = -1
    return true
  end
end

Events.onEndBattle += proc { |sender, e|
  $PokemonTemp.delayedShedinjaEvos.each { |pokemon| pbAddShedinjaEvo(pokemon) }
  $PokemonTemp.delayedShedinjaEvos.clear

  $PokemonTemp.battleStolenItems.each { |item|
    $PokemonBag.pbStoreItem(item)
    Kernel.pbMessage(_INTL("{1} was placed in the Bag.", getItemName(item, :The)))
  }
  $PokemonTemp.battleStolenItems.clear

  decision = e[0]
  if decision == 1
    for pkmn in $Trainer.party
      next if pkmn.isEgg? || pkmn.hasAnItem?
      Kernel.pbRunPickup(pkmn)
      if pkmn.ability == :BALLFETCH && $game_variables[:Field_Effect_End_Of_Battle] == :SNOWYMOUNTAIN
        $PokemonBag.pbStoreItem(:SNOWBALL)
        Kernel.pbMessage(_INTL("{1} fetched {2}.", pkmn.name, getItemName(:SNOWBALL, :a)))
      end
      if pkmn.ability == :HONEYGATHER
        chance = 5 + ((pkmn.level - 1) / 10) * 5
        chance = 100 if $game_variables[:Field_Effect_End_Of_Battle] == :FOREST
        if rand(100) < chance
          $PokemonBag.pbStoreItem(:HONEY)
          Kernel.pbMessage(_INTL("{1} gathered some Honey.", pkmn.name))
        end
      end
    end
  end
}

def pbGetReward(species, form)
  reward = $cache.pkmn[species, form].reward
  return unless reward&.any?

  chancetotal = reward[:table].sum { |row| row[:rate] }
  rnd = rand(chancetotal)
  chance = 0
  for row in reward[:table]
    chance += row[:rate]
    if rnd < chance
      Kernel.pbItemBall(reward[:item], row[:num])
      break
    end
  end
end

Events.onWildBattleEnd += proc { |sender, e|
  species  = e[0]
  form     = e[1]
  decision = e[3]
  pbGetReward(species, form) if [1, 4].include?(decision)
}

################################################################################
# Scene_Map and Spriteset_Map
################################################################################
class Spriteset_Map
  def getAnimations
    return @usersprites
  end

  def restoreAnimations(anims)
    @usersprites = anims
  end
end

Events.onSpritesetCreate += proc { |sender, e|
  spriteset = e[0] # Spriteset being created
  viewport = e[1] # Viewport used for tilemap and characters
  map = spriteset.map # Map associated with the spriteset (not necessarily the current map).
  for i in map.events.keys
    if map.events[i].name[/^OutdoorLight\((\w+)\)$/]
      filename = $~[1].to_s
      spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i], viewport, map, filename))
    elsif map.events[i].name == "OutdoorLight"
      spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i], viewport, map))
    elsif map.events[i].name[/^Light\((\w+)\)$/]
      filename = $~[1].to_s
      spriteset.addUserSprite(LightEffect_Basic.new(map.events[i], viewport, map, filename))
    elsif map.events[i].name == "Light"
      spriteset.addUserSprite(LightEffect_Basic.new(map.events[i], viewport, map))
    end
  end
}

def Kernel.pbOnSpritesetCreate(spriteset, viewport)
  Events.onSpritesetCreate.trigger(nil, spriteset, viewport)
end

################################################################################
# Field movement
################################################################################
def pbLedge
  if Kernel.pbFacingTerrainTag == PBTerrain::Ledge
    if $game_player.jumpForward(2)
      pbSEPlay("jump")
      waitForJump
      dustAnimation
      $game_player.increase_steps
      $game_player.check_event_trigger_here([1, 2])
    end
    return true
  end
  return false
end

def dustAnimation
  $scene.spriteset.addEventAnimation(DUST_ANIMATION_ID, $game_player, true)
end

def rockClimbAnimation
  $scene.spriteset.addEventAnimation(ROCK_CLIMB_DUST_ANIMATION_ID, $game_player, true)
  $scene.spriteset.addEventAnimation(ROCK_CLIMB_ROCKS_ANIMATION_ID, $game_player, true)
end

def Kernel.pbSlideOnIce(event = nil)
  event = $game_player if !event
  return if !event
  return if pbGetTerrainTag(event) != PBTerrain::Ice

  $PokemonGlobal.sliding = true
  direction = event.direction
  oldwalkanime = event.walk_anime
  event.straighten
  event.pattern = 1
  event.walk_anime = false
  event.move_speed = 5.0
  loop do
    break if !event.passable?(event.x, event.y, direction)
    break if pbGetTerrainTag(event) != PBTerrain::Ice

    event.move_forward
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  event.center(event.x, event.y) if event == $game_player
  event.straighten
  event.walk_anime = oldwalkanime
  $PokemonGlobal.sliding = false
end

def Kernel.pbConveyorMove(event = nil)
  event = $game_player if !event
  current_tag = pbGetTerrainTag(event)
  return if !event
  return if !pbIsConveyorTag?(current_tag)

  $PokemonGlobal.sliding = true
  oldwalkanime = event.walk_anime
  event.straighten
  event.pattern = 0
  event.walk_anime = false
  loop do
    current_tag = pbGetTerrainTag(event)
    case current_tag
      when PBTerrain::DownConveyor then direction = 2
      when PBTerrain::LeftConveyor then direction = 4
      when PBTerrain::RightConveyor then direction = 6
      when PBTerrain::UpConveyor then direction = 8
    end
    break if !pbIsConveyorTag?(current_tag)
    break if !event.passable?(event.x, event.y, direction)

    case current_tag
      when PBTerrain::DownConveyor then event.move_down(false)
      when PBTerrain::LeftConveyor then event.move_left(false)
      when PBTerrain::RightConveyor then event.move_right(false)
      when PBTerrain::UpConveyor then event.move_up(false)
    end
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  event.center(event.x, event.y) if event == $game_player
  event.straighten
  event.walk_anime = oldwalkanime
  $PokemonGlobal.sliding = false
end

def pbFieldDamage
  flashed = false
  for i in $Trainer.party
    next if i.hp == 0 || i.isEgg?
    if i.ability != :MAGICGUARD &&
       !($game_switches[:Devon_Panel_Puzzle] && ([:VOLTABSORB, :MOTORDRIVE, :LIGHTNINGROD].include?(i.ability) || i.hasType?(:GROUND)))
      if !flashed
        $game_screen.start_flash(Color.new(255, 0, 0, 128), 4)
        flashed = true
      end
      next if i.hp == 1

      i.hp -= (i.totalhp / 8.0).floor
      i.hp = 1 if i.hp == 0
      pbCheckAllFainted()
    elsif i.ability == :VOLTABSORB
      i.hp += (i.totalhp / 16.0).floor
      i.hp = i.totalhp if i.hp > i.totalhp
    end
  end
end

# check to see if a specific event comes within touching distance of certain coordinates
# mostly intended to check for touch with another solid event
# likely to use in a parallel process with a few frames delay timer
def check_event_contact(event, x, y)
  if event.x == x
    return event.y == y - 1 || event.y == y + 1
  elsif event.y == y
    return event.x == x - 1 || event.x == x + 1
  else
    return false
  end
end

# checks whether any of a list of events is in a specific location
# used in eventing to check for overlap on passable events
def check_event_location(events, x, y)
  events = Array(events)
  for event in events
    return true if event.x == x && event.y == y
  end
  return false
end

# Poison event on each step taken
Events.onStepTakenTransferPossible += proc { |sender, e|
  handled = e[0]
  next if handled[0]

  if $PokemonGlobal.stepcount % 4 == 0 && POISONINFIELD && $game_switches[:Overworld_Poison_Password] != true
    flashed = false
    for i in $Trainer.party
      if i.status == :POISON && i.hp > 0 && !i.isEgg? && ![:POISONHEAL, :MAGICGUARD].include?(i.ability) && !(i.species == :ZANGOOSE && i.item == :ZANGCREST)
        if defined?(POISON_ANIMATION_ID) && !flashed
          # $scene.spriteset.addEventAnimation(POISON_ANIMATION_ID, $game_player, true) if $scene.is_a?(Scene_Map)
          $game_player.animation_id = POISON_ANIMATION_ID
          flashed = true
        end
        i.hp -= 1 if i.hp > 1 || POISONFAINTINFIELD
        if i.hp == 1 && !POISONFAINTINFIELD
          i.healStatus
          Kernel.pbMessage(_INTL("{1} survived the poisoning.\nThe poison faded away!\1", i.name))
          next
        end
        handled[0] = true if pbAllFainted
        pbCheckAllFainted()
      end
    end
  end
}

Events.onStepTaken += proc {
  $PokemonGlobal.happinessSteps = 0 if !$PokemonGlobal.happinessSteps
  $PokemonGlobal.happinessSteps += 1

  if $PokemonGlobal.happinessSteps == 128
    for pkmn in $Trainer.party
      if pkmn.hp > 0 && !pkmn.egg?
        pkmn.changeHappiness(:Walk) if rand(2) == 0
      end
    end
    $PokemonGlobal.happinessSteps = 0
  end

  if Reborn
    $game_switches[:Has_PokeSnax] = $PokemonBag.pbQuantity(:POKESNAX) > 0
  end

  walkingMon = getWalkingMon()
  if $PokemonTemp.walkingMon != walkingMon
    $PokemonTemp.walkingMon = walkingMon
    if $PokemonTemp.walkingMon
      $PokemonTemp.walkEvo = checkEvolutionEx($PokemonTemp.walkingMon) { |pokemon, method, condition, evo|
        next true if method == :WalkSteps
      }
    else
      $PokemonTemp.walkEvo = nil
    end
  end
  $PokemonTemp.walkingMon.walkedSteps += 1 if $PokemonTemp.walkEvo
}

def getWalkingMon
  return $Trainer.firstAblePokemon() # Add any special conditions for pokemon to include/exclude here
end

Events.onStepTakenFieldMovement += proc { |sender, e|
  event = e[0] # Get the event affected by field movement
  currentTag = pbGetTerrainTag(event)
  if currentTag == PBTerrain::Grass # Won't show if under bridge
    if event == $game_player
      $scene.spriteset.addEventAnimation(GRASS_ANIMATION_ID, event, true) if $scene.is_a?(Scene_Map)
    end
  elsif event == $game_player && currentTag == PBTerrain::WaterfallCrest
    # Descend waterfall, but only if this event is the player
    Kernel.pbDescendWaterfall(event)
  elsif (currentTag <= 23 && currentTag >= 20) && !$PokemonGlobal.sliding
    Kernel.pbConveyorMove(event)
  elsif currentTag == PBTerrain::Ice && !$PokemonGlobal.sliding
    Kernel.pbSlideOnIce(event)
  end
  if sender.is_a?(Game_Character) && sender.respond_to?("id") && caller.any? { |c| c.to_s.include?("force_move_route") }
    if $PokemonMap && !sender.is_a?(Game_Player) && pbMapInterpreter.move_route_waiting == false
      $PokemonMap.addMovedEvent(sender.id)
    end
  end
}

def pbBattleOnStepTaken()
  return if Desolation && $game_switches[:WildBattles]
  return if $Trainer.ablePokemonCount == 0

  encounterType = $PokemonEncounters.pbEncounterType

  return if encounterType < 0
  return if !$PokemonEncounters.isEncounterPossibleHere?()

  encounter = $PokemonEncounters.pbGenerateEncounter(encounterType)
  encounter = EncounterModifier.trigger(encounter)
  if $PokemonEncounters.pbCanEncounter?(encounter)
    if $PokemonGlobal.partner || (Reborn && makeDoubles?())
      encounter2 = $PokemonEncounters.pbEncounteredPokemon(encounterType)
      pbDoubleWildBattleObjects(
        pbGenerateWildPokemon(encounter[0], encounter[2], encounter[1]),
        pbGenerateWildPokemon(encounter2[0], encounter2[2], encounter2[1]),
      )
    else
      pbWildBattleObject(pbGenerateWildPokemon(encounter[0], encounter[2], encounter[1]))
    end
  end
  EncounterModifier.triggerEncounterEnd()
end

def Kernel.pbOnStepTaken(eventTriggered)
  if $game_player.move_route_forcing || pbMapInterpreterRunning? || !$Trainer
    # if forced movement or if no trainer was created yet
    Events.onStepTakenFieldMovement.trigger(nil, $game_player)
    return
  end
  $PokemonGlobal.stepcount = 0 if !$PokemonGlobal.stepcount
  $PokemonGlobal.stepcount += 1
  $PokemonGlobal.stepcount &= 0x7FFFFFFF
  Events.onStepTaken.trigger(nil)
  #  Events.onStepTakenFieldMovement.trigger(nil,$game_player)
  handled = [nil]
  Events.onStepTakenTransferPossible.trigger(nil, handled)
  return if handled[0]

  if !eventTriggered
    pbBattleOnStepTaken()
  end
end

# This method causes a lot of lag when the game is encrypted
def pbGetPlayerCharset(graphic, trainer = nil)
  player = trainer if trainer.is_a?(Integer)
  player = trainer.metaID if trainer.is_a?(PokeBattle_Trainer)
  player = $PokemonGlobal.playerID if player.nil?
  trainer = $Trainer unless trainer.is_a?(PokeBattle_Trainer)
  outfit = trainer ? trainer.outfit : 0
  meta = $cache.metadata[:Players][player]
  ret = meta[graphic]
  ret = meta[:walk] if !ret || ret == ""
  if meta.has_key?(:directory)
    sprite = meta[:directory] + " " + outfit.to_s + "/" + ret
    fallback = meta[:directory] + "/" + ret
  else
    sprite = ret + "_" + outfit.to_s
    fallback = ret
  end
  sprite = fallback if !pbResolveBitmap("Graphics/Characters/" + sprite)
  sprite = meta[:walk] if !pbResolveBitmap("Graphics/Characters/" + sprite)
  return sprite
end

def Kernel.pbUpdateVehicle
  if $PokemonGlobal.diving
    $game_player.character_name = pbGetPlayerCharset(:dive) # Diving graphic
  elsif $PokemonGlobal.surfing || $PokemonGlobal.lavasurfing
    $game_player.character_name = pbGetPlayerCharset(:surf) # Surfing graphic
  elsif $PokemonGlobal.bicycle
    $game_player.character_name = pbGetPlayerCharset(:bike) # Bicycle graphic
  elsif $game_switches[:Riding_Tauros]
    $game_player.character_name = pbGetPlayerCharset(:ride)
  else
    $game_player.character_name = pbGetPlayerCharset(:walk) # Regular graphic
  end
end

def Kernel.pbCancelVehicles(destination = nil)
  $PokemonGlobal.surfing = false
  $PokemonGlobal.lavasurfing = false
  $game_switches[:Faux_Surf] = false
  $PokemonGlobal.diving = false
  if !destination || !pbCanUseBike?(destination)
    $PokemonGlobal.bicycle = false
  end
  Kernel.pbUpdateVehicle
end

def pbCanUseBike?(mapid)
  val = $cache.mapdata[mapid].Outdoor
  val = $cache.mapdata[mapid].Bicycle if val == nil
  return val ? true : false
end

def Kernel.pbMountBike
  return if $PokemonGlobal.bicycle

  if $game_switches[:Riding_Tauros]
    Kernel.pbMessage(_INTL("You can't bike while riding a Pokémon!"))
  else
    $PokemonGlobal.bicycle = true
    Kernel.pbUpdateVehicle
    bikebgm = $cache.metadata[:Bicycle]
    pbSEPlay("Bike Bell")
    if bikebgm && $Settings.bike_and_surf_music == 1
      pbCueBGM(bikebgm, 0.5)
    end
  end
end

def Kernel.pbDismountBike
  return if !$PokemonGlobal.bicycle

  $PokemonGlobal.bicycle = false
  Kernel.pbUpdateVehicle
  $game_map.autoplayAsCue
end

def Kernel.pbDismountTauros
  if $game_switches[:Riding_Tauros]
    $game_switches[:Riding_Tauros] = false
    $game_player.setDefaultCharName(nil, $game_player.fullPattern)
  end
end

def Kernel.pbSetPokemonCenter
  $PokemonGlobal.pokecenterMapId = $game_map.map_id
  $PokemonGlobal.pokecenterX = $game_player.x
  $PokemonGlobal.pokecenterY = $game_player.y
  $PokemonGlobal.pokecenterDirection = $game_player.direction
end

################################################################################
# Fishing
################################################################################
def pbFishingBegin
  $PokemonGlobal.fishing = true
  if !pbCommonEvent(FISHINGBEGINCOMMONEVENT)
    patternb = 2 * $game_player.direction - 1
    graphic = $PokemonGlobal.surfing ? :surffish : :fishing
    # no encounters while lavasurfing
    charset = pbGetPlayerCharset(graphic)
    4.times do |pattern|
      $game_player.setDefaultCharName(charset, patternb - pattern)
      2.times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
  end
end

def pbFishingEnd
  if !pbCommonEvent(FISHINGENDCOMMONEVENT)
    patternb = 2 * ($game_player.direction - 2)
    graphic = $PokemonGlobal.surfing ? :surffish : :fishing
    # no encounters while lavasurfing
    charset = pbGetPlayerCharset(graphic)
    4.times do |pattern|
      $game_player.setDefaultCharName(charset, patternb + pattern)
      2.times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
  end
  $PokemonGlobal.fishing = false
end

def pbFishing(hasencounter, rodtype = 1)
  bitechance = 50 + (15 * rodtype) # 65, 80, 95
  if $Trainer.party.length > 0
    user = fieldAbilityUser
    unless user.isEgg?
      bitechance *= 2 if user.ability == :STICKYHOLD
      bitechance *= 2 if user.ability == :SUCTIONCUPS
    end
  end
  hookchance = 100
  oldpattern = $game_player.fullPattern
  pbFishingBegin
  msgwindow = Kernel.pbCreateMessageWindow

  if $game_switches[:SpeedSkip_Password]
    if hasencounter && rand(100) < bitechance && (rand(100) < hookchance || FISHINGAUTOHOOK)
      pbSEPlay("Fishing Success")
      Kernel.pbMessageDisplay(msgwindow, _INTL("Oh!  A bite!"), true, tts: false)
      Kernel.pbMessageDisplay(msgwindow, _INTL("Landed a Pokémon!"), true, tts: false)
      Kernel.pbDisposeMessageWindow(msgwindow)
      pbFishingEnd
      $game_player.setDefaultCharName(nil, oldpattern)
      return true
    else
      pbFishingEnd
      $game_player.setDefaultCharName(nil, oldpattern)
      pbSEPlay("Fishing Fail")
      Kernel.pbMessageDisplay(msgwindow, _INTL("Not even a nibble..."), true, tts: false)
      Kernel.pbDisposeMessageWindow(msgwindow)
      return false
    end
  end

  loop do
    time = 2 + rand(10)
    message = ""
    time.times do
      message += ".  "
    end
    if pbWaitMessage(msgwindow, time)
      pbFishingEnd
      $game_player.setDefaultCharName(nil, oldpattern)
      pbSEPlay("Fishing Fail")
      Kernel.pbMessageDisplay(msgwindow, _INTL("Not even a nibble..."), true, tts: false)
      Kernel.pbDisposeMessageWindow(msgwindow)
      return false
    end
    if hasencounter && rand(100) < bitechance
      frames = rand(21) + 25
      if !pbWaitForInput(msgwindow, message + _INTL("\nOh!  A bite!"), frames)
        pbFishingEnd
        $game_player.setDefaultCharName(nil, oldpattern)
        pbSEPlay("Fishing Fail")
        Kernel.pbMessageDisplay(msgwindow, _INTL("The Pokémon got away..."), true, tts: false)
        Kernel.pbDisposeMessageWindow(msgwindow)
        return false
      end
      if rand(100) < hookchance || FISHINGAUTOHOOK
        pbSEPlay("Fishing Success")
        Kernel.pbMessageDisplay(msgwindow, _INTL("Landed a Pokémon!"), true, tts: false)
        Kernel.pbDisposeMessageWindow(msgwindow)
        pbFishingEnd
        $game_player.setDefaultCharName(nil, oldpattern)
        return true
      end
    else
      pbFishingEnd
      $game_player.setDefaultCharName(nil, oldpattern)
      pbSEPlay("Fishing Fail")
      Kernel.pbMessageDisplay(msgwindow, _INTL("Not even a nibble..."), true, tts: false)
      Kernel.pbDisposeMessageWindow(msgwindow)
      return false
    end
  end
  Kernel.pbDisposeMessageWindow(msgwindow)
  return false
end

def pbWaitForInput(msgwindow, message, frames)
  return true if FISHINGAUTOHOOK

  pbSEPlay("Fishing Prompt")
  Kernel.pbMessageDisplay(msgwindow, message, false, tts: false)
  frames *= $Settings.turboSpeedMultiplier if $speed_up
  frames.floor.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    return true if Input.trigger?(Input::C)
    return false if Input.trigger?(Input::B)
  end
  return false
end

def pbWaitMessage(msgwindow, time)
  message = ""
  (time + 1).times do |i|
    message += ".  " if i > 0
    pbSEPlay("Fishing Beat")
    Kernel.pbMessageDisplay(msgwindow, message, false, tts: false)
    20.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        return true
      end
    end
  end
  return false
end



################################################################################
# Moving between maps
################################################################################
Events.onMapChange += proc { |sender, e|
  oldid = e[0] # previous map ID, 0 if no map ID
  healing = $cache.mapdata[$game_map.map_id].HealingSpot
  $PokemonGlobal.healingSpot = healing if healing
  $PokemonMap.clear if $PokemonMap
  $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
  $PokemonGlobal.visitedMaps[$game_map.map_id] = true
  if oldid != 0 && oldid != $game_map.map_id
    weather = $cache.mapdata[$game_map.map_id].Weather
    if weather && rand(100) < weather[1]
      $game_screen.weather(weather[0], 8, 20)
    else
      $game_screen.weather(0, 0, 0)
    end
  end
}

Events.onMapSceneChange += proc { |sender, e|
  scene = e[0]
  mapChanged = e[1]
  next if !scene || !scene.spriteset

  if $game_map
    # lastmapdetails = $PokemonGlobal.mapTrail[0] ? $cache.mapdata[$PokemonGlobal.mapTrail[0]].MapPosition : [-1, 0, 0]
    # lastmapdetails = [-1, 0, 0] if !lastmapdetails
    # newmapdetails = $game_map.map_id ? $cache.mapdata[$game_map.map_id].MapPosition : [-1, 0, 0]
    # newmapdetails = [-1, 0, 0] if !newmapdetails
    $PokemonGlobal.mapTrail = [] if !$PokemonGlobal.mapTrail
    if $PokemonGlobal.mapTrail[0] != $game_map.map_id
      $PokemonGlobal.mapTrail[3] = $PokemonGlobal.mapTrail[2] if $PokemonGlobal.mapTrail[2]
      $PokemonGlobal.mapTrail[2] = $PokemonGlobal.mapTrail[1] if $PokemonGlobal.mapTrail[1]
      $PokemonGlobal.mapTrail[1] = $PokemonGlobal.mapTrail[0] if $PokemonGlobal.mapTrail[0]
    end
    $PokemonGlobal.mapTrail[0] = $game_map.map_id # Update map trail
  end
  darkmap = $cache.mapdata[$game_map.map_id].DarkMap
  if darkmap
    if Desolation && $game_switches[:SpecialDarkness]
      $PokemonTemp.darknessSprite = OverlaySprite.new
      scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
      fog = $PokemonTemp.darknessSprite
      fog.radius = 192
    elsif $PokemonGlobal.flashUsed || (($game_switches[:EasyHMs_Password] || $PokemonBag.pbHasItem?(:GOLDENLANTERN)) && $PokemonBag.pbQuantity(:TM70) > 0 && pbCheckHMBadges(:FLASH))
      $PokemonGlobal.flashUsed = true
      $PokemonTemp.darknessSprite = DarknessSprite.new
      scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
      darkness = $PokemonTemp.darknessSprite
      darkness.radius = 192
    else
      $PokemonTemp.darknessSprite = DarknessSprite.new
      scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
    end
  else
    $PokemonGlobal.flashUsed = false
    if $PokemonTemp.darknessSprite
      $PokemonTemp.darknessSprite.dispose
      $PokemonTemp.darknessSprite = nil
    end
  end
  if mapChanged
    if !$game_switches[:Disable_Signposts_Music] && !$game_switches[:Disable_Signposts] # for ending scenes
      if $cache.mapdata[$game_map.map_id].ShowArea
        nosignpost = false
        if $PokemonGlobal.mapTrail[1]
          for i in 0...NOSIGNPOSTS.length / 2
            nosignpost = true if NOSIGNPOSTS[2 * i] == $PokemonGlobal.mapTrail[1] && NOSIGNPOSTS[2 * i + 1] == $game_map.map_id
            nosignpost = true if NOSIGNPOSTS[2 * i + 1] == $PokemonGlobal.mapTrail[1] && NOSIGNPOSTS[2 * i] == $game_map.map_id
            break if nosignpost
          end
          oldmapname = $cache.mapinfos[$PokemonGlobal.mapTrail[1]].name
          nosignpost = true if $game_map.name == oldmapname
        end
        if !nosignpost
          mapname = pbGetMapNameFromId($game_map.map_id)
          scene.spriteset.addUserSprite(LocationWindow.new(mapname))
          tts(mapname, true)
        end
      end
    end
  end
  if !pbCanUseBike?($game_map.map_id)
    Kernel.pbDismountBike
  end
}

def Kernel.pbStartOver(gameover = false)
  pbHealAll()
  if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId >= 0
    if gameover
      Kernel.pbMessage(_INTL("\\w[]\\wm\\l[3]After the unfortunate defeat, {1} scurried to a Pokémon Center.", $Trainer.name))
    else
      Kernel.pbMessage(_INTL("\\w[]\\wm\\l[3]{1} scurried to a Pokémon Center, protecting the exhausted and fainted Pokémon from further harm.", $Trainer.name))
    end
    Kernel.pbCancelVehicles
    pbRemoveDependencies()
    $game_switches[:Starting_Over] = true
    $game_temp.player_new_map_id = $PokemonGlobal.pokecenterMapId
    $game_temp.player_new_x = $PokemonGlobal.pokecenterX
    $game_temp.player_new_y = $PokemonGlobal.pokecenterY
    $game_temp.player_new_direction = $PokemonGlobal.pokecenterDirection
    $scene.transfer_player if $scene.is_a?(Scene_Map)
    $game_map.refresh
  else
    homedata = $cache.metadata[:home]
    if homedata && !pbRxdataExists?(sprintf("Data/Map%03d", homedata[0]))
      if $DEBUG
        Kernel.pbMessage(_ISPRINTF("Can't find the map 'Map{1:03d}' in the Data folder.  The game will resume at the player's position.", homedata[0]))
      end
      pbHealAll()
      return
    end
    if gameover
      Kernel.pbMessage(_INTL("\\w[]\\wm\\l[3]After the unfortunate defeat, {1} scurried home.", $Trainer.name))
    else
      Kernel.pbMessage(_INTL("\\w[]\\wm\\l[3]{1} scurried home, protecting the exhausted and fainted Pokémon from further harm.", $Trainer.name))
    end
    if homedata
      Kernel.pbCancelVehicles
      pbRemoveDependencies()
      $game_switches[:Starting_Over] = true
      $game_temp.player_new_map_id = homedata[0]
      $game_temp.player_new_x = homedata[1]
      $game_temp.player_new_y = homedata[2]
      $game_temp.player_new_direction = homedata[3]
      $scene.transfer_player if $scene.is_a?(Scene_Map)
      $game_map.refresh
    else
      pbHealAll()
    end
  end
  pbEraseEscapePoint
end

def pbCaveEntranceEx(exiting)
  sprite = BitmapSprite.new(Graphics.width, Graphics.height)
  sprite.z = 100000
  totalBands = 15
  totalFrames = 15
  bandheight = ((Graphics.height / 2) - 10).to_f / totalBands
  bandwidth = ((Graphics.width / 2) - 12).to_f / totalBands
  grays = []
  for i in 0...totalBands
    grays.push(exiting ? 0 : 255)
  end
  totalFrames.times do |j|
    x = 0
    y = 0
    rectwidth = Graphics.width
    rectheight = Graphics.height
    for k in 0...j
      t = 255.0 / totalFrames
      if exiting
        t = 1.0 - t
        t *= 1.0 + ((k) / totalFrames.to_f)
      else
        t *= 1.0 + 0.3 * (((totalFrames - k) / totalFrames.to_f)**0.7)
      end
      grays[k] -= t
      grays[k] = 0 if grays[k] < 0
    end
    for i in 0...totalBands
      currentGray = grays[i]
      sprite.bitmap.fill_rect(Rect.new(x, y, rectwidth, rectheight), Color.new(currentGray, currentGray, currentGray))
      x += bandwidth
      y += bandheight
      rectwidth -= bandwidth * 2
      rectheight -= bandheight * 2
    end
    Graphics.update
    Input.update
  end
  if exiting
    pbToneChangeAll(Tone.new(255, 255, 255), 0)
  else
    pbToneChangeAll(Tone.new(-255, -255, -255), 0)
  end
  for j in 0..15
    if exiting
      sprite.color = Color.new(255, 255, 255, j * 255 / 15)
    else
      sprite.color = Color.new(0, 0, 0, j * 255 / 15)
    end
    Graphics.update
    Input.update
  end
  pbToneChangeAll(Tone.new(0, 0, 0), 8)
  for j in 0..5
    Graphics.update
    Input.update
  end
  sprite.dispose
end

def pbCaveEntrance
  pbSetEscapePoint
  pbCaveEntranceEx(false)
end

def pbCaveExit
  pbEraseEscapePoint
  pbCaveEntranceEx(true)
end

def pbSetEscapePoint
  xco = $game_player.x
  yco = $game_player.y
  case $game_player.direction
    when 2; yco -= 0; dir = 8   # Down
    when 4; xco += 0; dir = 6   # Left
    when 6; xco -= 0; dir = 4   # Right
    when 8; yco += 0; dir = 2   # Up
  end
  $PokemonGlobal.escapePoint = [$game_map.map_id, xco, yco, dir]
end

def pbEraseEscapePoint
  $PokemonGlobal.escapePoint = []
end

################################################################################
# Partner trainer
################################################################################
def pbRegisterPartner(trainerid, trainername, partyid = 0)
  Kernel.pbCancelVehicles
  if Rejuv
    trainer = pbLoadTrainer(trainerid, trainername, partyid, noscaling: true, knownID: true)
  else
    trainer = pbLoadTrainer(trainerid, trainername, partyid)
  end
  trainerobject = trainer[0]
  $PokemonGlobal.partner = [trainerid, trainername, trainerobject.id, trainer[2], trainer[1]]
  Events.onTrainerPartyLoad.trigger(nil, trainer)
end

def pbDeregisterPartner
  $PokemonGlobal.partner = nil
end

################################################################################
# Constant checks
################################################################################
Events.onMapUpdate += proc { |sender, e| # Pokérus check
  last = $PokemonGlobal.pokerusTime
  now = pbGetTimeNow
  if !last || last.year != now.year || last.month != now.month || last.day != now.day
    if $Trainer && $Trainer.party
      if $Trainer.party.length > 0
        for i in $Trainer.pokemonParty
          i.lowerPokerusCount
        end
      end
      $PokemonGlobal.pokerusTime = now
    end
  end
}

# Returns whether the Poké Center should explain Pokérus to the player, if a
# healed Pokémon has it.
def Kernel.pbPokerus?
  return false if $game_switches[:Seen_Pokerus]

  for i in $Trainer.party
    return true if i.pokerusStage == 1
  end
  return false
end

class PokemonTemp
  attr_accessor :cueBGM
  attr_accessor :cueFrames
end

Events.onMapUpdate += proc { |sender, e|
  if $PokemonTemp.cueFrames
    $PokemonTemp.cueFrames -= 1
    if $PokemonTemp.cueFrames <= 0
      $PokemonTemp.cueFrames = nil
      if $game_system.getPlayingBGM == nil
        pbBGMPlay($PokemonTemp.cueBGM)
      end
    end
  end
}

################################################################################
# Audio playing
################################################################################
def pbCueBGM(bgm, seconds, volume = nil, pitch = nil)
  return if !bgm

  bgm = pbResolveAudioFile(bgm, volume, pitch)
  playingBGM = $game_system.playing_bgm
  if !playingBGM || playingBGM.name != bgm.name || playingBGM.pitch != bgm.pitch
    pbBGMFade(seconds)
    if !$PokemonTemp.cueFrames
      $PokemonTemp.cueFrames = (seconds * Graphics.frame_rate) * 3 / 5
    end
    $PokemonTemp.cueBGM = bgm
  elsif playingBGM
    pbBGMPlay(bgm)
  end
end

def pbAutoplayOnTransition
  if $Settings.bike_and_surf_music == 1
    if $PokemonGlobal.surfing
      surfbgm = $cache.metadata[:Surf]
      pbBGMPlay(surfbgm) if surfbgm
      return
    end
    if $PokemonGlobal.lavasurfing
      lavasurfbgm = $cache.metadata[:LavaSurf]
      pbBGMPlay(lavasurfbgm) if lavasurfbgm
      return
    end
  end

  $game_map.autoplayAsCue
end

def pbAutoplayOnSave
  if $Settings.bike_and_surf_music == 1
    if $PokemonGlobal.surfing
      surfbgm = $cache.metadata[:Surf]
      pbBGMPlay(surfbgm) if surfbgm
      return
    end
    if $PokemonGlobal.lavasurfing
      lavasurfbgm = $cache.metadata[:LavaSurf]
      pbBGMPlay(lavasurfbgm) if lavasurfbgm
      return
    end
  end

  $game_map.autoplay(true)
end

def Kernel.pbRxdataExists?(file)
  return pbRgssExists?(file + ".rxdata")
end

################################################################################
# Gaining items
################################################################################
def Kernel.pbItemBall(item, quantity = 1)
  return false if !item || quantity < 1

  if pbIsTM?(item)
    Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found \\c[1]{2}\\c[0]!\nIt contained \\c[1]{3}\\c[0].\\wtnp[30]", $Trainer.name, getItemName(item), pbGetMachineMoveName(item)))
  elsif quantity > 1
    Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found {2} \\c[1]{3}\\c[0]!\\wtnp[30]", $Trainer.name, quantity, getItemName(item, plural: true)))
  else
    Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found {2}!\\wtnp[30]", $Trainer.name, getItemName(item, :a, useunit: !pbIsZCrystal?(item), color: true)))
  end
  return Kernel.pbTryStoreItem(item, quantity)
end

def Kernel.pbReceiveItem(item, quantity = 1)
  return false if !item || quantity < 1

  if pbIsTM?(item)
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained \\c[1]{1}\\c[0]!\nIt contained \\c[1]{2}\\c[0].\\wtnp[30]", getItemName(item), pbGetMachineMoveName(item)))
  elsif quantity > 1
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained {2} \\c[1]{1}\\c[0]!\\wtnp[30]", getItemName(item, plural: true), quantity))
  else
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained {1}!\\wtnp[30]", getItemName(item, :a, useunit: !pbIsZCrystal?(item), color: true)))
  end
  return Kernel.pbTryStoreItem(item, quantity)
end

def addItemSilent(item, quantity = 1)
  return false if !item || quantity < 1
  return $PokemonBag.pbStoreItem(item, quantity)
end

def Kernel.pbTryStoreItem(item, quantity)
  if $PokemonBag.pbStoreItem(item, quantity) # If item can be added
    pocket = pbGetPocket(item)
    Kernel.pbMessage(_INTL("{1} put {2}\nin the <icon=bagPocket{4}> \\c[1]{3}\\c[0] Pocket.", $Trainer.name, getItemName(item, :the, plural: quantity > 1, useunit: !pbIsZCrystal?(item), color: true), PokemonBag.pocketNames()[pocket], pocket))
    return true
  else # Can't add the item
    Kernel.pbMessage(_INTL("Too bad... The Bag is full..."))
    return false
  end
end

def pbReceiveFieldReadout(sym) # Used only by Reborn right now
  num = symToFieldID(sym)

  Kernel.pbMessage(_INTL("\\se[itemlevel]{1} obtained Field Effect Read-Out {2}!", $Trainer.name, num.to_s.rjust(2, "0")))
  Kernel.pbMessage(_INTL("Info on {1} now available!", getFieldName(sym)))

  pbSetSwitch($cache.FEData[sym].fieldAppSwitch, true)
end

################################################################################
# Event locations, terrain tags
################################################################################
def pbEventFacesPlayer?(event, player, distance)
  return false if distance <= 0
  # Event can't reach player if no coordinates coincide
  return false if event.x != player.x && event.y != player.y

  deltaX = (event.direction == 6 ? 1 : event.direction == 4 ? -1 : 0)
  deltaY = (event.direction == 2 ? 1 : event.direction == 8 ? -1 : 0)
  # Check for existence of player
  curx = event.x
  cury = event.y
  found = false
  for i in 0...distance
    curx += deltaX
    cury += deltaY
    if player.x == curx && player.y == cury
      found = true
      break
    end
  end
  return found
end

def pbEventCanReachPlayer?(event, player, distance)
  return false if distance <= 0
  # Event can't reach player if no coordinates coincide
  return false if event.x != player.x && event.y != player.y

  deltaX = (event.direction == 6 ? 1 : event.direction == 4 ? -1 : 0)
  deltaY = (event.direction == 2 ? 1 : event.direction == 8 ? -1 : 0)
  # Check for existence of player
  curx = event.x
  cury = event.y
  found = false
  realdist = 0
  for i in 0...distance
    curx += deltaX
    cury += deltaY
    if player.x == curx && player.y == cury
      found = true
      break
    end
    realdist += 1
  end
  return false if !found

  # Check passability
  curx = event.x
  cury = event.y
  for i in 0...realdist
    if !event.passable?(curx, cury, event.direction)
      return false
    end

    curx += deltaX
    cury += deltaY
  end
  return true
end

def pbFacingTileRegular(direction = nil, event = nil)
  event = $game_player if !event
  return [0, 0, 0] if !event

  x = event.x
  y = event.y
  direction = event.direction if !direction
  case direction
    when 1; y += 1; x -= 1
    when 2; y += 1
    when 3; y += 1; x += 1
    when 4; x -= 1
    when 6; x += 1
    when 7; y -= 1; x -= 1
    when 8; y -= 1
    when 9; y -= 1; x += 1
  end
  return [$game_map ? $game_map.map_id : 0, x, y]
end

def pbFacingTile(direction = nil, event = nil)
  if $MapFactory
    return $MapFactory.getFacingTile(direction, event)
  else
    return pbFacingTileRegular(direction, event)
  end
end

def pbFacingEachOther(event1, event2)
  return false if !event1 || !event2

  if $MapFactory
    tile1 = $MapFactory.getFacingTile(nil, event1)
    tile2 = $MapFactory.getFacingTile(nil, event2)
    return false if !tile1 || !tile2
    if tile1[0] == event2.map.map_id &&
       tile1[1] == event2.x && tile1[2] == event2.y &&
       tile2[0] == event1.map.map_id &&
       tile2[1] == event1.x && tile2[2] == event1.y
      return true
    else
      return false
    end
  else
    tile1 = Kernel.pbFacingTile(nil, event1)
    tile2 = Kernel.pbFacingTile(nil, event2)
    return false if !tile1 || !tile2
    if tile1[1] == event2.x && tile1[2] == event2.y &&
       tile2[1] == event1.x && tile2[2] == event1.y
      return true
    else
      return false
    end
  end
end

def pbGetTerrainTag(event = nil)
  event = $game_player if !event
  return 0 if !event
  if $MapFactory
    return $MapFactory.getTerrainTag(event.map.map_id, event.x, event.y)
  else
    $game_map.terrain_tag(event.x, event.y)
  end
end

def Kernel.pbFacingTerrainTag(event = nil, dir = nil)
  if $MapFactory
    return $MapFactory.getFacingTerrainTag(dir, event)
  else
    event = $game_player if !event
    return 0 if !event

    facing = pbFacingTile(dir, event)
    return $game_map.terrain_tag(facing[1], facing[2])
  end
end

################################################################################
# Event movement
################################################################################
def pbTurnTowardEvent(event, otherEvent)
  sx = 0
  sy = 0
  if $MapFactory
    relativePos = $MapFactory.getThisAndOtherEventRelativePos(otherEvent, event)
    sx = relativePos[0]
    sy = relativePos[1]
  else
    sx = event.x - otherEvent.x
    sy = event.y - otherEvent.y
  end
  return if sx == 0 && sy == 0

  if sx.abs >= sy.abs
    sx > 0 ? event.turn_left : event.turn_right
  else
    sy > 0 ? event.turn_up : event.turn_down
  end
end

def Kernel.pbMoveTowardPlayer(event)
  maxsize = [$game_map.width, $game_map.height].max
  return if !pbEventCanReachPlayer?(event, $game_player, maxsize)

  loop do
    x = event.x
    y = event.y
    event.move_toward_player
    break if event.x == x && event.y == y

    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  $PokemonMap.addMovedEvent(event.id) if $PokemonMap
end

def waitForJump
  while $game_player.jumping?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

def pbWait(numframes)
  numframes.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

module Direction
  DownLeft  = 1
  Down      = 2
  DownRight = 3
  Left      = 4
  UpRight   = 5
  Right     = 6
  UpLeft    = 7
  Up        = 8
end

module PBMoveRoute
  Down               = 1
  Left               = 2
  Right              = 3
  Up                 = 4
  LowerLeft          = 5
  LowerRight         = 6
  UpperLeft          = 7
  UpperRight         = 8
  Random             = 9
  TowardPlayer       = 10
  AwayFromPlayer     = 11
  Forward            = 12
  Backward           = 13
  Jump               = 14 # xoffset, yoffset
  Wait               = 15 # frames
  TurnDown           = 16
  TurnLeft           = 17
  TurnRight          = 18
  TurnUp             = 19
  TurnRight90        = 20
  TurnLeft90         = 21
  Turn180            = 22
  TurnRightOrLeft90  = 23
  TurnRandom         = 24
  TurnTowardPlayer   = 25
  TurnAwayFromPlayer = 26
  SwitchOn           = 27 # 1 param
  SwitchOff          = 28 # 1 param
  ChangeSpeed        = 29 # 1 param
  ChangeFreq         = 30 # 1 param
  WalkAnimeOn        = 31
  WalkAnimeOff       = 32
  StepAnimeOn        = 33
  StepAnimeOff       = 34
  DirectionFixOn     = 35
  DirectionFixOff    = 36
  ThroughOn          = 37
  ThroughOff         = 38
  AlwaysOnTopOn      = 39
  AlwaysOnTopOff     = 40
  Graphic            = 41 # Name, hue, direction, pattern
  Opacity            = 42 # 1 param
  Blending           = 43 # 1 param
  PlaySE             = 44 # 1 param
  Script             = 45 # 1 param
  ScriptAsync        = 101 # 1 param
end

class Game_Character
  def jumpDirection(direction)
    case direction
      when Direction::DownLeft  then return jump(-1, 1)
      when Direction::Down      then return jump(0, 1)
      when Direction::DownRight then return jump(1, 1)
      when Direction::Left      then return jump(-1, 0)
      when Direction::UpLeft    then return jump(-1, -1)
      when Direction::Right     then return jump(1, 0)
      when Direction::UpRight   then return jump(1, -1)
      when Direction::Up        then return jump(0, -1)
    end
  end

  def jumpForward(distance = 1)
    case self.direction
      when Direction::Down  then jump(0, distance)
      when Direction::Left  then jump(-distance, 0)
      when Direction::Right then jump(distance, 0)
      when Direction::Up    then jump(0, -distance)
    end
  end

  def jumpBackward(distance = 1)
    case self.direction
      when Direction::Down  then jump(0, -distance)
      when Direction::Left  then jump(distance, 0)
      when Direction::Right then jump(-distance, 0)
      when Direction::Up    then jump(0, distance)
    end
  end

  def moveLeft90
    case self.direction
      when 2 then move_right
      when 4 then move_down
      when 6 then move_up
      when 8 then move_left
    end
  end

  def moveRight90
    case self.direction
      when 2 then move_left
      when 4 then move_up
      when 6 then move_down
      when 8 then move_right
    end
  end

  def minilock
    @prelock_direction = @direction
    @locked = true
  end
end

def pbMoveRoute(event, commands, through: true)
  route = RPG::MoveRoute.new
  route.repeat = false
  route.skippable = true
  route.list.clear
  route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOn)) if through
  i = 0
  while i < commands.length
    case commands[i]
      when PBMoveRoute::Wait, PBMoveRoute::SwitchOn,
         PBMoveRoute::SwitchOff, PBMoveRoute::ChangeSpeed,
         PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
         PBMoveRoute::Blending, PBMoveRoute::PlaySE,
         PBMoveRoute::Script
        route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1]]))
        i += 1
      when PBMoveRoute::ScriptAsync
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script, [commands[i + 1]]))
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait, [0]))
        i += 1
      when PBMoveRoute::Jump
        route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1], commands[i + 2]]))
        i += 2
      when PBMoveRoute::Graphic
        route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1], commands[i + 2], commands[i + 3], commands[i + 4]]))
        i += 4
      else
        route.list.push(RPG::MoveCommand.new(commands[i]))
    end
    i += 1
  end
  route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOff)) if through
  route.list.push(RPG::MoveCommand.new(0))
  if event
    event.force_move_route(route)
  end
  return route
end

################################################################################
# Screen effects
################################################################################
def pbToneChangeAll(tone, duration)
  $game_screen.start_tone_change(tone, duration * 2)
  for picture in $game_screen.pictures
    picture.start_tone_change(tone, duration * 2) if picture
  end
end

def pbShake(power, speed, frames, axis = :x)
  $game_screen.start_shake(power, speed, frames * 2, axis)
end

def pbFlash(color, frames)
  $game_screen.start_flash(color, frames * 2)
end

def pbScrollMap(direction, distance, speed)
  return if !$game_map

  if speed == 0
    case direction
      when 2 then $game_map.scroll_down(distance * 128)
      when 4 then $game_map.scroll_left(distance * 128)
      when 6 then $game_map.scroll_right(distance * 128)
      when 8 then $game_map.scroll_up(distance * 128)
    end
  else
    $game_map.start_scroll(direction, distance, speed);
    oldx = $game_map.display_x
    oldy = $game_map.display_y
    loop do
      Graphics.update
      Input.update
      if !$game_map.scrolling?
        break
      end

      pbUpdateSceneMap
      if $game_map.display_x == oldx && $game_map.display_y == oldy
        break
      end

      oldx = $game_map.display_x
      oldy = $game_map.display_y
    end
  end
end

################################################################################
# Events
################################################################################
module InterpreterFieldMixin
  # Used in boulder events.  Allows an event to be pushed.  To be used in
  # a script event command.
  def pbPushThisEvent(se = nil, direction = $game_player.direction)
    event = get_character(0)
    oldx = event.x
    oldy = event.y
    # Apply strict version of passable, which makes impassable
    # tiles that are passable only from certain directions
    #  if !event.passableStrict?(event.x,event.y,$game_player.direction)
    #   return
    # end
    event.move_direction(direction)

    $PokemonMap.addMovedEvent(@event_id) if $PokemonMap
    return false if oldx == event.x && oldy == event.y

    pbSEPlay(se) unless se.nil?

    #    $game_player.lock
    begin
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end until !event.moving?
    #    $game_player.unlock
    return true
  end

  def pbPushThisObject(direction = $game_player.direction)
    pbPushThisEvent("strengthrock", direction)
  end

  def pbPushThisBoulder
    if $PokemonMap.strengthUsed && pbPushThisEvent("strengthpush")
      return true
    end
    if !$game_player.bump_se || $game_player.bump_se <= 0
      pbSEPlay(Reborn ? "bump-strength" : "strengthrock")
      $game_player.bump_se = 10
    end
    return false
  end

  def pbHeadbutt
    Kernel.pbHeadbutt(get_character(0))
    return true
  end

  def pbHeadbutt2
    Kernel.pbHeadbutt2(get_character(0))
    return true
  end

  def pbTrainerIntro(symbol)
    pbGlobalLock
    Kernel.pbPlayTrainerIntroME(symbol)
    return true
  end

  def pbTrainerEnd
    pbGlobalUnlock
    e = get_character(0)
    e.erase_route if e
  end

  def pbParams
    @parameters ? @parameters : @params
  end

  def pbGetPokemon(id)
    return $Trainer.party[pbGet(id)]
  end

  def pbSetEventTime(*arg)
    $PokemonGlobal.eventvars = {} if !$PokemonGlobal.eventvars
    time = pbGetTimeNow
    time = time.to_i
    pbSetSelfSwitch(@event_id, "A", true)
    $PokemonGlobal.eventvars[[@map_id, @event_id]] = time
    for otherevt in arg
      pbSetSelfSwitch(otherevt, "A", true)
      $PokemonGlobal.eventvars[[@map_id, otherevt]] = time
    end
  end

  def pbSetEventTimeMultiMap(*arg)
    $PokemonGlobal.eventvars = {} if !$PokemonGlobal.eventvars
    time = pbGetTimeNow
    time = time.to_i
    pbSetSelfSwitch(@event_id, "A", true)
    $PokemonGlobal.eventvars[[@map_id, @event_id]] = time
    for othermap, otherevt in arg
      $game_self_switches[[othermap, otherevt, "A"]] = true
      $PokemonGlobal.eventvars[[othermap, otherevt]] = time
    end
  end

  def getVariable(*arg)
    if arg.length == 0
      return nil if !$PokemonGlobal.eventvars

      return $PokemonGlobal.eventvars[[@map_id, @event_id]]
    else
      return $game_variables[arg[0]]
    end
  end

  def setVariable(*arg)
    if arg.length == 1
      $PokemonGlobal.eventvars = {} if !$PokemonGlobal.eventvars
      $PokemonGlobal.eventvars[[@map_id, @event_id]] = arg[0]
    else
      $game_variables[arg[0]] = arg[1]
      $game_map.need_refresh = true
    end
  end

  def tsOff?(c)
    get_character(0).tsOff?(c)
  end

  def tsOn?(c)
    get_character(0).tsOn?(c)
  end

  alias isTempSwitchOn? tsOn? unless method_defined?(:isTempSwitchOn?)
  alias isTempSwitchOff? tsOff? unless method_defined?(:isTempSwitchOff?)

  def setTempSwitchOn(c)
    get_character(0).setTempSwitchOn(c)
  end

  def setTempSwitchOff(c)
    get_character(0).setTempSwitchOff(c)
  end

  # Must use this approach to share the methods because the methods already
  # defined in a class override those defined in an included module
  CustomEventCommands = <<_END_

  def command_352
    pbSaveScreen
    return true
  end

  def command_125
    value = operate_value(pbParams[0], pbParams[1], pbParams[2])
    $Trainer.money+=value
    return true
  end

  def command_132
    $PokemonGlobal.nextBattleBGM=(pbParams[0]) ? pbParams[0].clone : nil
    return true
  end

  def command_133
    $PokemonGlobal.nextBattleVictoryBGM=(pbParams[0]) ? pbParams[0].clone : nil
    return true
  end

  def command_353
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    pbFadeOutIn(99999){ Kernel.pbStartOver(true) }
  end

  def command_314
    pbHealAll() if pbParams[0] == 0
    return true
  end

_END_
end

class Interpreter
  include InterpreterFieldMixin
  eval(InterpreterFieldMixin::CustomEventCommands)
end

Events.onStartBattle += proc {
  Graphics.onStartBattle
}

Events.onEndBattle += proc { |sender, e|
  Graphics.onEndBattle
}

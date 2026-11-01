# DO NOT EDIT THESE VARIABLES.
# The values are changed automatically by our GitHub Actions workflows when preparing a new patch.
GAME_VERSION = '14.0.28'
MKXP_Z_VERSION = '2.5.2'
JOIPLAY_ASSETS_VERSION = '1.3.1'
KIRIN_ASSETS_VERSION = '1.0.0'

GAME_PATCH_USER = ''

UPDATER_SERVERS = {
  default: 'https://www.rebornevo.com/downloads/rebornremote/Rejuvenation_14.0',
  alternate: '',
}

UPDATER_PATHS = {
  game_versions: 'versions.yaml',
  game_patch: 'patch.zip',
  game_tilesets: 'tilesets.zip',
  mkxp_z_windows: 'mkxp-z.windows.zip',
  mkxp_z_linux: 'mkxp-z.linux.zip',
  mkxp_z_macos: 'mkxp-z.macos.zip',
  joiplay_assets: 'joiplay.zip',
  kirin_assets: 'kirin.zip',
}

Reborn = false
Desolation = false
Rejuv = true

# Scripts which are loaded immediately in order to show the Intro screen.
# Don't add new scripts here unless it's really necessary.
INIT = [
  'Rejuv/Settings',
  'Rejuv/SystemConstants',

  'SpriteResizer',
  'Game_System',

  'RTP',
  'Interpreter',
  'Audio',
  'PBEvent',
  'PBDebug',

  'BitmapCache',
  'Window',
  'SpriteWindow',
  'SW Subclasses',

  'EventScene',
  'Scene_Intro',
  'Rejuv/RejuvIntro',

  'Options',
  'Rejuv/OptionsAddOn',
  'PBIntl',
  'System',
  'DataObjects',
  'Rejuv/CustomDataObjects',
  'Compiler',
  'DataObjects - Compilers',

  'Cache',
  'Rejuv/CacheAddOn',
  'ClientData',
  'Updater',
  'Main',
]

# List of scripts to be loaded while intro screen is being shown. Adjust as needed.
SCRIPTS = [
  'Rejuv/Settings',
  'Rejuv/SystemConstants',

  'RPG_Sprite',
  'Game_Temp',
  'Game_Data',
  'Game_Screen',
  'Game_Picture',
  'Game_CommonEvent',
  'Game_Character',
  'Game_Event',
  'Game_Player',
  'Walk_Run',
  'Game_Map',
  'Map_Scroll',

  $joiplay ? 'TilemapXP' : nil,
  'Spriteset_Map',
  'AnimationSprite',
  'ReflectedSprite',
  'AdvancedAnimations',

  'TileDrawingHelper',
  'Plane',

  'TextToSpeech',
  'Messages',
  'DrawText',
  'TextEntry',
  'TextLog',

  'Scene_Map',

  'PBConstants',
  'PBStuff',
  'PBMove',
  'PBTypes',
  'PBExperience',
  'PBAnimation',
  'PBScene',

  'Pokemon',
  'Items',
  'Field',
  'ShadowPokemon',

  'Battle_Typemod',
  'Battle_ActiveSide',
  'Battle_DamageState',
  'Battler',
  'Battle_Effects',
  'Battle_Move',
  'Battle_ZMove',
  'Battle_MoveEffects',
  'Battle_Modules',
  'Battle',
  'Battle_AI',
  'Battle_Trainer',
  'Battle_SafariZone',
  'Battle_Record',
  'Battle_Scene',
  'Battle_Clauses',
  'Battle_Field',
  'Battle_Inspect',
  'Battle_Shadow',
  'BattleData',

  'Map',
  'Encounters',
  'EncounterModifiers',
  'HiddenMoves',
  'BerryPlants',
  'DayCare',
  'DependentEvents',
  'Time',
  'TimeWeather',
  'Trainers',
  'Roaming',

  'ItemEffects',
  'Balls',
  'Bag',
  'Evolution',
  'Sprite',
  'MenuHandlers',
  'Storage_Registry',
  'Storage',

  'PauseMenu_Registry',
  'PauseMenu',
  'ReadyMenu',
  'Pokedex',
  'PokedexScene',
  'PokedexNestAndForm',
  'PokedexAdvanced',
  'EggHatching',
  'PartyMenu_Registry',
  'Party',
  'Summary',
  'Pokegear',
  'RegionMap',
  'Jukebox',
  'FieldNotes',
  'TrainerCard',
  'Trading',
  'MoveRelearner',
  'Mart',
  'MartStockTypes',
  'HallOfFame',
  'MoveTutor',
  'PokemonBossBattle',

  'Minigame/SlotMachine',
  'Minigame/VoltorbFlip',
  'Minigame/Lottery',
  'Minigame/Mining',
  'Minigame/TilePuzzles',
  'Minigame/Roulette',

  'OrgBattle',
  'OrgBattleRules',
  'OrgBattleGenerator',
  'BattleSwap',
  'Selection',

  'Passwords',
  'Save',
  'Load',
  'Utilities',
  'Controls',
  'Debug',
  'Editor/DebugEditor',
  'Editor/TilesetEditor',
  'Editor/AnimEditor',
  'Editor/DexEditor',
  'Editor/PositionEditor',
  'DataObjects - Yeeters',

  'Profiler',
  'Event YEET professional SP2',

  'Safari',
  'PurifyChamber',

  'FlyAnimation',
  'AdvancedWeather',
  'InField Animation Fix',

  'Rejuv/Achievements/Achievements',
  'Rejuv/Achievements/UI',
  'Rejuv/Eventing/001_VASP',
  'Rejuv/Bag_Rejuv',
  'Rejuv/Eventing/RSECableCar',
  'Rejuv/Eventing/Roulette Game',
  'Rejuv/Eventing/CharacterSwitch',
  'Rejuv/Battle/Difficulty Modes',
  'Rejuv/Eventing/Pseudo3D',
  'Rejuv/Eventing/Self Switch Off',
  'Rejuv/Quest/RecordsTab',
  'Rejuv/Quest/Config',
  'Rejuv/Quest/Quest',
  'Rejuv/Quest/UI',
  'Rejuv/Quest/Data',
  'Rejuv/Battle/MoveEffects',
  'Rejuv/Battle/Battle',
  'Rejuv/Battle/Battler',
  'Rejuv/Battle/PBScene',
  'Rejuv/Battle/Battle_Scene',
  'Rejuv/Eventing/RaidDens',
  'Rejuv/Battle/Zygarde',
  'Rejuv/NewGamePlus',
  'Rejuv/RegionMap',
  'Rejuv/RiftDex',
  'Rejuv/RejuvPasswords',
  'Rejuv/RejuvPokegear',
  'Rejuv/RejuvCustomScripts',
  'Rejuv/BlackPrismHandlers',
  'Rejuv/LuckContractHandlers',
  'Rejuv/WonderTower',
  'Rejuv/Eventing/Dynamic Lighting',
  'Rejuv/Xenpurgis/XenTower',
  'Rejuv/Xenpurgis/LuckSwap',
  'Rejuv/Xenpurgis/Blessings',
  'Rejuv/Xenpurgis/BlessingsScene',
  'Rejuv/Xenpurgis/BlessingsOverlay',
  'Rejuv/Scene_Credits',

  'haru stuff',
  'FL_SimpleHUD',
  'Camera/Zoom',
  'Camera/Config',
  'Camera/Camera',
  'Camera/Overrides',

  # 'Randomizer/RandomizerUtils',
  # 'Randomizer/RandomizerHandler',
  # 'Randomizer/Randomizer',
  # 'Randomizer/RandomizerSettings',
  # 'Randomizer/RandomizerScene',
  # 'Randomizer/RandomizerCache',

  'Battle_Snapshot',

  'DataConversion',
]

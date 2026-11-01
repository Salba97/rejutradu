FIELDEFFECTS = {
  :INDOOR => {
    :name => "",
    :fieldAppSwitch => nil, # Switch ID which determines if the player has the data for this field
    :fieldMessage => "", # \n denotes newline in same dialogue box, \n\n denotes new dialogue box, | denotes point to cut off message for the un-elaborated field note
    :graphic => ["Indoor", "IndoorA", "IndoorB", "IndoorC", "IndoorD", "IndoorE", "IndoorVenam", "AxisHigh", "NightmareSchool"],
    :secretPower => :TRIATTACK,
    :naturePower => :TRIATTACK,
    :mimicry => :NORMAL,
    :burmyCloak => nil, # which cloak burmy gets if send out on this field, nil means it determines of the terrain tag instead
    :damageMods => { # damage modifiers for specific moves, written as multipliers (e.g. 1.5 => [:TACKLE])
    }, # a damage mod of 0 denotes the move outright failing on this field
    :accuracyMods => { # accuracy chance for specific moves, written as percent chance to hit (e.g. 80 => [:TOXIC])
    }, # an accuracy mod of 0 denotes the move always hitting on this field
    :moveMessages => { # the field message displayed when using a move (written as "message" => [move1,move2....] )
    },
    :typeMods => { # secondary types applied to moves (written as "type" => [move1,move2,....])
    },
    :typeAddOns => { # secondary types applied to entire types (written as SecondaryTypeSymbol => [typesymbol1,typesymbol2,...])
    },
    :fieldCounterIncreases => { # field counter increases towards field transformations [counter, increase, maximum, message] => moves
    }, # needs to be separate from moveEffects so that we can correctly apply the 1.3 damage multiplier
    :moveEffects => { # arbitrary commands that are evaled after a move executes but before fieldchanges are checked
    }, # evaled in "fieldEffectAfterMove" method in the battle class
    :typeBoosts => { # damage multipliers applied to all moves of a specific type (e.g. 1.3 => [:FIRE,:WATER])
    }, # a type boost of 0 denotes moves of the type outright failing on this field
    :typeMessages => { # field message shown when using a move of the denoted type ("message" => [type1,type2,....])
    },
    :typeCondition => { # conditions for the type boost written as a string of conditions that are evaled later
    }, # evaled as a function on the move class
    :typeEffects => { # arbitrary commands attached to all moves of a type that are evaled after a move executes but before fieldchanges are checked
    }, # evaled in "fieldEffectAfterMove" method in the battle class
    :changeCondition => { # conditions for a field change written as a string of conditions that are evaled later
    }, # evaled as a function on the move class
    :fieldChange => { # moves that change this field to a different field (Fieldsymbol => [move1,move2,....])
    },
    :dontChangeBackup => [], # list of moves which store the current field as backup when changing the field
    :changeMessage => { # message displayed when changing a field to a different one ("message" => [move1,move2,....])
    },
    :statusBuffs => [], # list of non-damaging moves boosted by the field in different ways, for field highlighting (can have damaging moves too)
    :statusNerfs => [], # list of non-damaging moves diminished by the field in different ways, for field highlighting (can have damaging moves too)
    :changeEffects => { # additional effects that happen when specific moves change a field (such as corrosive mist explosion)
    }, # evaled in "fieldEffectAfterMove" method in the battle class
    :seed => { # the seed effects on this field
      :seedtype => nil, # which seed is activated
      :effect => nil, # which battler effect is being changed if any
      :duration => nil, # duration of the extra effect
      :message => nil, # message shown with the seeds boost
      :animation => nil, # animation associated with the effect
      :stats => { # statchanges caused by the seed
      },
    },
    :overlay => { # effects of this field as an overlay instead of a full field #Rejuv
      :damageMods => { # damage modifiers for specific moves, written as multipliers (e.g. 1.5 => [:TACKLE])
      }, # a damage mod of 0 denotes the move failing on this field
      :typeMods => { # secondary types applied to moves (written as "type" => [move1,move2,....])
      },
      :moveMessages => { # the field message displayed when using a move (written as "message" => [move1,move2....] )
      },
      :typeBoosts => { # damage multipliers applied to all moves of a specific type (e.g. 1.3 => [:FIRE,:WATER])
      },
      :typeMessages => { # field message shown when using a move of the denoted type ("message" => [type1,type2,....])
      },
      :typeCondition => { # conditions for the type boost written as a string of conditions that are evaled later
      }, # evaled as a function on the move class
      :statusBuffs => [], # list of non-damaging moves boosted by the field in different ways, for field highlighting (can have damaging moves too)
      :statusNerfs => [], # list of non-damaging moves diminished by the field in different ways, for field highlighting (can have damaging moves too)
    },
  },

  :ELECTERRAIN => {
    :name => "Electric Terrain",
    :fieldAppSwitch => 2001,
    :fieldMessage => "The field is hyper-charged!",
    :graphic => ["Electric"],
    :secretPower => :SHOCKWAVE,
    :naturePower => :THUNDERBOLT,
    :mimicry => :ELECTRIC,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:EXPLOSION, :SELFDESTRUCT, :HURRICANE, :SURF, :SMACKDOWN, :MUDDYWATER, :THOUSANDARROWS, :WILDBOLTSTORM, :HYDROVORTEX],
      2.0 => [:MAGNETBOMB],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The explosion became hyper-charged!" => [:EXPLOSION, :SELFDESTRUCT],
      "The attack became hyper-charged!" => [:HURRICANE, :SURF, :SMACKDOWN, :HYDROVORTEX, :MUDDYWATER, :THOUSANDARROWS, :WILDBOLTSTORM],
      "The attack powered up!" => [:MAGNETBOMB],
    },
    :typeMods => {
      :ELECTRIC => [:EXPLOSION, :SELFDESTRUCT, :SMACKDOWN, :SURF, :MUDDYWATER, :HURRICANE, :THOUSANDARROWS, :HYDROVORTEX],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ELECTRIC],
    },
    :typeMessages => {
      "The Electric Terrain strengthened the attack!" => [:ELECTRIC],
    },
    :typeCondition => {
      :ELECTRIC => "!attacker.isAirborne?(magnetRiseElectricTerrain: true)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [:TECTONICRAGE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The hyper-charged terrain shorted out!" => [:TECTONICRAGE],
    },
    :statusBuffs => [:CHARGE, :EERIEIMPULSE, :MAGNETRISE, :SPIKES, :ELECTRIFY, :RISINGVOLTAGE, :PSYBLADE],
    :statusNerfs => [:FOCUSPUNCH],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :Charge,
      :duration => 2,
      :message => "{1} began charging power!",
      :animation => :CHARGE,
      :stats => {
        PBStats::SPEED => 1,
      },
    },
    :overlay => {
      :damageMods => {
        1.5 => [:EXPLOSION, :SELFDESTRUCT, :HURRICANE, :SURF, :SMACKDOWN, :MUDDYWATER, :THOUSANDARROWS, :WILDBOLTSTORM],
        2.0 => [:MAGNETBOMB],
      },
      :typeMods => {
        :ELECTRIC => [:EXPLOSION, :SELFDESTRUCT, :SMACKDOWN, :SURF, :MUDDYWATER, :HURRICANE, :THOUSANDARROWS],
      },
      :moveMessages => {
        "The explosion became hyper-charged!" => [:EXPLOSION, :SELFDESTRUCT],
        "The attack became hyper-charged!" => [:HURRICANE, :SURF, :SMACKDOWN, :MUDDYWATER, :THOUSANDARROWS, :WILDBOLTSTORM],
        "The attack powered up!" => [:MAGNETBOMB],
      },
      :typeBoosts => {
        1.3 => [:ELECTRIC],
      },
      :typeMessages => {
        "The Electric Terrain strengthened the attack!" => [:ELECTRIC],
      },
      :typeCondition => {
        :ELECTRIC => "!attacker.isAirborne?(magnetRiseElectricTerrain: true) && @battle.FE != :SHORTCIRCUIT",
      },
      :statusBuffs => [:MAGNETRISE, :RISINGVOLTAGE, :PSYBLADE],
      :statusNerfs => [],
    },
  },

  :GRASSY => {
    :name => "Grassy Terrain",
    :fieldAppSwitch => 2002,
    :fieldMessage => "The field is in full bloom.",
    :graphic => ["Grassy"],
    :secretPower => :SEEDBOMB,
    :naturePower => :ENERGYBALL,
    :mimicry => :GRASS,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:FAIRYWIND, :SILVERWIND, :OMINOUSWIND, :ICYWIND, :RAZORWIND, :GUST, :TWISTER, :GRASSKNOT],
      0.5 => [:MUDDYWATER, :SURF, :EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
    },
    :accuracyMods => {
      80 => [:GRASSWHISTLE],
    },
    :moveMessages => {
      "The wind picked up strength from the field!" => [:FAIRYWIND, :SILVERWIND, :OMINOUSWIND, :ICYWIND, :RAZORWIND, :GUST, :TWISTER],
      "The grass strengthened the attack!" => [:GRASSKNOT],
      "The grass softened the attack..." => [:MUDDYWATER, :SURF, :EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
    },
    :typeMods => {},
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1, 3, "The ground became waterlogged..."] => [:SURF],
      [1, 2, 3, "The ground became waterlogged..."] => [:MUDDYWATER],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:GRASS, :FIRE],
    },
    :typeMessages => {
      "The Grassy Terrain strengthened the attack!" => [:GRASS],
      "The grass below caught flame!" => [:FIRE],
    },
    :typeCondition => {
      :GRASS => "!attacker.isAirborne?",
      :FIRE => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {
      :SWAMP => "@battle.field.counter > 2",
    },
    :fieldChange => {
      :CORROSIVE => [:SLUDGEWAVE, :ACIDDOWNPOUR],
      :SWAMP => [:SURF, :MUDDYWATER],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The grassy terrain was corroded!" => [:SLUDGEWAVE, :ACIDDOWNPOUR],
      "The grassy terrain became marshy!" => [:SURF, :MUDDYWATER],
    },
    :statusBuffs => [:COIL, :GROWTH, :FLORALHEALING, :SYNTHESIS, :WORRYSEED, :INGRAIN, :GRASSWHISTLE, :LEECHSEED, :COTTONSPORE, :NATURESMADNESS, :GRASSYGLIDE],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::DEFENSE => 1,
      },
    },
    :overlay => {
      :damageMods => {
        1.5 => [:FAIRYWIND, :SILVERWIND, :OMINOUSWIND, :ICYWIND, :RAZORWIND, :GUST, :TWISTER],
      },
      :typeMods => {},
      :moveMessages => {
        "The wind picked up strength from the field!" => [:FAIRYWIND, :SILVERWIND, :OMINOUSWIND, :ICYWIND, :RAZORWIND, :GUST, :TWISTER],
      },
      :typeBoosts => {
        1.3 => [:GRASS],
      },
      :typeMessages => {
        "The Grassy Terrain strengthened the attack!" => [:GRASS],
      },
      :typeCondition => {
        :GRASS => "!attacker.isAirborne?",
      },
      :statusBuffs => [:GRASSYGLIDE],
      :statusNerfs => [],
    },
  },

  :MISTY => {
    :name => "Misty Terrain",
    :fieldAppSwitch => 2003,
    :fieldMessage => "Mist settles on the field.",
    :graphic => ["Misty"],
    :secretPower => :MISTBALL,
    :naturePower => :MISTBALL,
    :mimicry => :FAIRY,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [
        :MYSTICALFIRE, :MAGICALLEAF, :DOOMDESIRE, :DOOMDUMMY, :ICYWIND, :MISTBALL, :AURASPHERE, :STEAMERUPTION, :SILVERWIND,
        :MOONGEISTBEAM, :SMOG, :CLEARSMOG, :STRANGESTEAM, :SPRINGTIDESTORM, :HYDROSTEAM
      ],
      0.5 => [:DARKPULSE, :SHADOWBALL, :NIGHTDAZE],
      0 => [:SELFDESTRUCT, :EXPLOSION, :MINDBLOWN],
    },
    :accuracyMods => {
      100 => [:SWEETKISS],
    },
    :moveMessages => {
      "The mist's energy strengthened the attack!" => [
        :MYSTICALFIRE, :MAGICALLEAF, :DOOMDUMMY, :ICYWIND, :MISTBALL,
        :AURASPHERE, :STEAMERUPTION, :SILVERWIND, :MOONGEISTBEAM, :SMOG, :CLEARSMOG, :STRANGESTEAM, :SPRINGTIDESTORM, :HYDROSTEAM
      ],
      "The mist softened the attack..." => [:DARKPULSE, :SHADOWBALL, :NIGHTDAZE],
      "The damp mist prevented the explosion..." => [:SELFDESTRUCT, :EXPLOSION, :MINDBLOWN],
    },
    :typeMods => {},
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1, 2, "Poison spread through the mist!"] => [:CLEARSMOG, :POISONGAS, :SMOG, :CORROSIVEGAS],
      [1, 2, 2, nil] => [:ACIDDOWNPOUR],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FAIRY],
      0.5 => [:DRAGON],
    },
    :typeMessages => {
      "The Misty Terrain strengthened the attack!" => [:FAIRY],
      "The Misty Terrain weakened the attack!" => [:DRAGON],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :CORROSIVEMIST => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :INDOOR => [:WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE, :BLEAKWINDSTORM],
      :CORROSIVEMIST => [:CLEARSMOG, :SMOG, :POISONGAS, :ACIDDOWNPOUR, :CORROSIVEGAS]
    },
    :dontChangeBackup => [:CLEARSMOG, :SMOG, :POISONGAS, :ACIDDOWNPOUR, :CORROSIVEGAS],
    :changeMessage => {
      "The mist was blown away!" => [:WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE, :BLEAKWINDSTORM],
      "The mist was corroded!" => [:CLEARSMOG, :SMOG, :POISONGAS, :ACIDDOWNPOUR],
    },
    :statusBuffs => [:COSMICPOWER, :AROMATICMIST, :SWEETSCENT, :WISH, :AQUARING, :MISTYEXPLOSION],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
    :overlay => {
      :damageMods => {
        1.5 => [:MYSTICALFIRE, :MAGICALLEAF, :DOOMDESIRE, :DOOMDUMMY, :ICYWIND, :MISTBALL, :AURASPHERE, :STEAMERUPTION, :SILVERWIND, :MOONGEISTBEAM, :SMOG, :CLEARSMOG, :STRANGESTEAM, :SPRINGTIDESTORM, :HYDROSTEAM],
      },
      :typeMods => {},
      :moveMessages => {
        "The mist's energy strengthened the attack!" => [:MYSTICALFIRE, :MAGICALLEAF, :DOOMDUMMY, :ICYWIND, :MISTBALL, :AURASPHERE, :STEAMERUPTION, :SILVERWIND, :MOONGEISTBEAM, :SMOG, :CLEARSMOG, :STRANGESTEAM, :SPRINGTIDESTORM, :HYDROSTEAM],
      },
      :typeBoosts => {
        1.3 => [:FAIRY],
      },
      :typeMessages => {
        "The Misty Terrain strengthened the attack!" => [:FAIRY],
      },
      :typeCondition => {},
      :statusBuffs => [:MISTYEXPLOSION],
      :statusNerfs => [],
    },
  },

  :DARKCRYSTALCAVERN => {
    :name => "Dark Crystal Cavern",
    :fieldAppSwitch => 2004,
    :fieldMessage => "Darkness is gathering...",
    :graphic => ["DarkCrystalCavern"],
    :secretPower => :DARKPULSE,
    :naturePower => :DARKPULSE,
    :mimicry => :DARK,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.5 => [:DARKPULSE, :NIGHTDAZE, :NIGHTSLASH, :SHADOWBALL, :SHADOWPUNCH, :SHADOWCLAW, :SHADOWSNEAK, :SHADOWFORCE,
              :SHADOWBONE, :AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :MIRRORBEAM, :TECHNOBLAST, :DOOMDESIRE, :DOOMDUMMY, :POWERGEM, :MOONGEISTBEAM, :PHOTONGEYSER, :DIAMONDSTORM, :MENACINGMOONRAZEMAELSTROM, :BLACKHOLEECLIPSE, :LUMINACRASH, :TERASTARSTORM],
      2.0 => [:PRISMATICLASER],
      0.5 => [:LIGHTTHATBURNSTHESKY],
    },
    :accuracyMods => {
      100 => [:DARKVOID],
    },
    :moveMessages => {
      "The darkness began to gather...!" => [:DARKPULSE, :NIGHTDAZE, :NIGHTSLASH],
      "The darkness strengthened the attack!" => [:SHADOWBALL, :SHADOWPUNCH, :SHADOWCLAW, :SHADOWSNEAK, :SHADOWFORCE, :SHADOWBONE, :MENACINGMOONRAZEMAELSTROM],
      "The crystals' light strengthened the attack!" => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :MIRRORBEAM, :TECHNOBLAST, :DOOMDUMMY, :POWERGEM, :MOONGEISTBEAM, :PHOTONGEYSER, :DIAMONDSTORM, :LUMINACRASH, :TERASTARSTORM],
      "The crystal split the attack!" => [:PRISMATICLASER],
      "The consuming darkness fed the attack!" => [:BLACKHOLEECLIPSE],
      "{2} couldn't consume much light..." => [:LIGHTTHATBURNSTHESKY],
    },
    :typeMods => {
      :DARK => [:TERASTARSTORM],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :CAVE => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :CAVE => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The dark crystals were shattered!" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
    },
    :statusBuffs => [:FLASH, :DARKVOID, :MOONLIGHT, :AURORAVEIL],
    :statusNerfs => [:SOLARBEAM, :SOLARBLADE, :SYNTHESIS, :MORNINGSUN],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :MagicCoat,
      :duration => true,
      :message => "{1} shrouded itself with Magic Coat!",
      :animation => :MAGICCOAT,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },

  :CHESS => {
    :name => "Chess Board",
    :fieldAppSwitch => 2005,
    :fieldMessage => "Opening variation set.",
    :graphic => ["Chess", "Chess1"],
    :secretPower => :FEINT,
    :naturePower => :ANCIENTPOWER,
    :mimicry => :PSYCHIC,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [
        :FEINT, :FEINTATTACK, :FAKEOUT, :SUCKERPUNCH, :FIRSTIMPRESSION, :SHADOWSNEAK, :SMARTSTRIKE, :KOWTOWCLEAVE,
        :THUNDERCLAP, :UPPERHAND, *(PBFields::CHESSMOVES - [:BARRAGE])
      ],
      2.0 => [:BARRAGE],
    },
    :accuracyMods => {},
    :moveMessages => {
      "En passant!" => [:FEINT, :FEINTATTACK, :FAKEOUT, :SUCKERPUNCH, :FIRSTIMPRESSION, :SHADOWSNEAK, :SMARTSTRIKE, :KOWTOWCLEAVE, :THUNDERCLAP, :UPPERHAND],
      "The chess piece slammed forward!" => [*PBFields::CHESSMOVES],
    },
    :typeMods => {
      :ROCK => [*PBFields::CHESSMOVES],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:CALMMIND, :NASTYPLOT, :TRICKROOM, :KINGSSHIELD, :OBSTRUCT, :NORETREAT, :ALLYSWITCH],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :MagicCoat,
      :duration => true,
      :message => "{1} shrouded itself with Magic Coat!",
      :animation => :MAGICCOAT,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },

  :BIGTOP => {
    :name => "Big Top Arena",
    :fieldAppSwitch => 2006,
    :fieldMessage => "Now presenting...!",
    :graphic => ["BigTop"],
    :secretPower => :DYNAMICPUNCH,
    :naturePower => :ACROBATICS,
    :mimicry => :FIGHTING,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:VINEWHIP, :POWERWHIP, :FIRELASH, :FIERYDANCE, :PETALDANCE, :REVELATIONDANCE, :FLY, :ACROBATICS,
              :FIRSTIMPRESSION, :DRUMBEATING, :PAYDAY, :FLOWERTRICK, :AQUASTEP, :MAKEITRAIN],
    },
    :accuracyMods => {
      100 => [:SING],
    },
    :moveMessages => {
      "Back, foul beast!" => [:VINEWHIP, :POWERWHIP, :FIRELASH],
      "What grace!" => [:FIERYDANCE, :PETALDANCE, :REVELATIONDANCE, :AQUASTEP],
      "An extravagant aerial finish!" => [:FLY, :ACROBATICS],
      "And what an entrance it is!" => [:FIRSTIMPRESSION],
      "And a little extra for you, darling!" => [:PAYDAY, :MAKEITRAIN],
      "Loud and clear!" => [:DRUMBEATING],
      "A spectacular magic trick!" => [:FLOWERTRICK],
      "Boo! Get off the stage!" => [:CHILLYRECEPTION],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:soundmove],
    },
    :typeMessages => {
      "Loud and clear!" => [:soundmove],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:ENCORE, :DRAGONDANCE, :QUIVERDANCE, :SWORDSDANCE, :FEATHERDANCE, :LUNARDANCE, :TEETERDANCE, :SING, :BELLYDRUM, :SPOTLIGHT, :AQUABATICS, :CLANGOROUSSOUL, :NORETREAT, :VICTORYDANCE, :CHILLYRECEPTION],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => nil,
      :duration => 0,
      :message => "{1} accepts the crowd's help!",
      :animation => :HELPINGHAND,
      :stats => {
        PBStats::ATTACK => 1,
      },
    },
  },

  :VOLCANIC => {
    :name => "Volcanic Field",
    :fieldAppSwitch => 2007,
    :fieldMessage => "The field is molten!",
    :graphic => ["Volcano"],
    :secretPower => :FLAMETHROWER,
    :naturePower => :FLAMETHROWER,
    :mimicry => :FIRE,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      2.0 => [:SMOG, :CLEARSMOG],
      1.5 => [:SMACKDOWN, :THOUSANDARROWS, :ROCKSLIDE, :INFERNALPARADE],
    },
    :accuracyMods => {
      100 => [:WILLOWISP],
    },
    :moveMessages => {
      "The flames spread from the attack!" => [:SMOG, :CLEARSMOG, :INFERNALPARADE],
      "{1} was knocked into the flames!" => [:SMACKDOWN, :THOUSANDARROWS, :ROCKSLIDE],
    },
    :typeMods => {
      :FIRE => [:SMACKDOWN, :SMOG, :CLEARSMOG, :THOUSANDARROWS, :ROCKSLIDE],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FIRE],
      0.5 => [:GRASS, :ICE],
    },
    :typeMessages => {
      "The blaze amplified the attack!" => [:FIRE],
      "The blaze softened the attack..." => [:GRASS, :ICE],
    },
    :typeCondition => {
      :FIRE => "!attacker.isAirborne?",
      :GRASS => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :CAVE => [
        :WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE, :WATERSPORT, :SURF, :MUDDYWATER, :WATERSPOUT, :WATERPLEDGE, :SPARKLINGARIA, :SLUDGEWAVE, :SANDTOMB, :CONTINENTALCRUSH, :HYDROVORTEX, :OCEANICOPERETTA
      ],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The grime snuffed out the flame!" => [:SLUDGEWAVE],
      "The wind snuffed out the flame!" => [:WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE],
      "The water snuffed out the flame!" => [:WATERSPORT, :SURF, :MUDDYWATER, :WATERSPOUT, :WATERPLEDGE, :SPARKLINGARIA, :HYDROVORTEX, :OCEANICOPERETTA],
      "The sand snuffed out the flame!" => [:SANDTOMB, :CONTINENTALCRUSH],
    },
    :statusBuffs => [:WILLOWISP, :SMOKESCREEN],
    :statusNerfs => [:HAIL, :SNOWSCAPE, :CHILLYRECEPTION],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :MultiTurnAttack,
      :duration => :FIRESPIN,
      :message => "{1} was trapped in the vortex!",
      :animation => :FIRESPIN,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::SPATK => 1,
        PBStats::SPEED => 1,
      },
    },
  },

  :SWAMP => {
    :name => "Swamp Field",
    :fieldAppSwitch => 2008,
    :fieldMessage => "The field is swamped.",
    :graphic => ["Swamp"],
    :secretPower => :MUDDYWATER,
    :naturePower => :MUDDYWATER,
    :mimicry => :WATER,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:MUDBOMB, :MUDSHOT, :MUDSLAP, :MUDBARRAGE, :MUDDYWATER, :SLUDGEWAVE, :GUNKSHOT, :BRINE, :SMACKDOWN,
              :THOUSANDARROWS, :HYDROVORTEX, :SAVAGESPINOUT],
      0.25 => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
      0 => [:SELFDESTRUCT, :EXPLOSION, :MINDBLOWN]
    },
    :accuracyMods => {
      100 => [:SLEEPPOWDER, :STUNSPORE, :POISONPOWDER],
    },
    :moveMessages => {
      "The murk strengthened the attack!" => [:MUDBOMB, :MUDSHOT, :MUDSLAP, :MUDBARRAGE, :MUDDYWATER, :SLUDGEWAVE, :GUNKSHOT, :BRINE, :SMACKDOWN, :THOUSANDARROWS, :HYDROVORTEX],
      "The attack dissipated in the soggy ground..." => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
      "The dampness prevents the explosion!" => [:SELFDESTRUCT, :EXPLOSION, :MINDBLOWN],
      "There are bugs EVERYWHERE!" => [:SAVAGESPINOUT],
    },
    :typeMods => {
      :WATER => [:SMACKDOWN, :THOUSANDARROWS],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.3 => [:BUG, :WATER, :GRASS],
      0.8 => [:FIRE],
    },
    :typeMessages => {
      "Bugs are swarming!" => [:BUG],
      "The dampness strengthened the attack!" => [:WATER],
      "Thick mangroves line the area!" => [:GRASS],
      "The dampness weakened the flame..." => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:SLEEPPOWDER, :STUNSPORE, :POISONPOWDER, :AQUARING, :STRENGTHSAP, :LEECHSEED, :STRINGSHOT, :SPIDERWEB],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => nil,
      :message => "{1}'s body became clear!",
      :animation => :ROCKPOLISH,
      :stats => {
        PBStats::DEFENSE => 1,
      },
    },
  },

  :RAINBOW => {
    :name => "Rainbow Field",
    :fieldAppSwitch => 2009,
    :fieldMessage => "What does it mean?",
    :graphic => ["Rainbow","Rainbow_1"],
    :secretPower => :AURORABEAM,
    :naturePower => :AURORABEAM,
    :mimicry => :DRAGON,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:SILVERWIND, :MYSTICALFIRE, :DRAGONPULSE, :TRIATTACK, :SACREDFIRE, :FIREPLEDGE, :WATERPLEDGE, :GRASSPLEDGE,
              :AURORABEAM, :MIRRORBEAM, :JUDGMENT, :RELICSONG, :HIDDENPOWER, :SECRETPOWER, :WEATHERBALL, :MISTBALL, :HEARTSTAMP, :MOONBLAST, :ZENHEADBUTT, :SPARKLINGARIA, :FLEURCANNON, :PRISMATICLASER, :TWINKLETACKLE, :OCEANICOPERETTA, :SOLARBEAM, :SOLARBLADE, :DAZZLINGGLEAM, :LUMINACRASH],
      0.5 => [:DARKPULSE, :SHADOWBALL, :NIGHTDAZE, :NEVERENDINGNIGHTMARE],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The attack was rainbow-charged!" => [
        :SILVERWIND, :MYSTICALFIRE, :DRAGONPULSE, :TRIATTACK, :SACREDFIRE, :FIREPLEDGE, :WATERPLEDGE, :GRASSPLEDGE, :AURORABEAM, :MIRRORBEAM, :JUDGMENT, :RELICSONG, :HIDDENPOWER, :SECRETPOWER,
        :WEATHERBALL, :MISTBALL, :HEARTSTAMP, :MOONBLAST, :ZENHEADBUTT, :SPARKLINGARIA, :FLEURCANNON, :PRISMATICLASER, :TWINKLETACKLE, :OCEANICOPERETTA, :SOLARBEAM, :SOLARBLADE, :DAZZLINGGLEAM, :LUMINACRASH
      ],
      "The rainbow softened the attack..." => [:DARKPULSE, :SHADOWBALL, :NIGHTDAZE, :NEVERENDINGNIGHTMARE],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:NORMAL],
    },
    :typeMessages => {
      "The rainbow energized the attack!" => [:NORMAL],
    },
    :typeCondition => {
      :NORMAL => "self.pbIsSpecial?(attacker, type)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [:LIGHTTHATBURNSTHESKY, :SANDSEARSTORM],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The rainbow was consumed!" => [:LIGHTTHATBURNSTHESKY],
      "The sandstorm blocked out the rainbow!" => [:SANDSEARSTORM],
    },
    :statusBuffs => [:COSMICPOWER, :MEDITATE, :WISH, :LIFEDEW, :AURORAVEIL, :SONICBOOM],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
    :overlay => {
      :damageMods => {
        1.5 => [:SILVERWIND, :MYSTICALFIRE, :DRAGONPULSE, :TRIATTACK, :SACREDFIRE, :FIREPLEDGE, :WATERPLEDGE, :GRASSPLEDGE,
              :AURORABEAM, :MIRRORBEAM, :JUDGMENT, :RELICSONG, :HIDDENPOWER, :SECRETPOWER, :WEATHERBALL, :MISTBALL, :HEARTSTAMP, :MOONBLAST, :ZENHEADBUTT, :SPARKLINGARIA, :FLEURCANNON, :PRISMATICLASER, :TWINKLETACKLE, :OCEANICOPERETTA, :SOLARBEAM, :SOLARBLADE, :DAZZLINGGLEAM, :LUMINACRASH],
      },
      :typeMods => {},
      :moveMessages => {
        "The attack was rainbow-charged!" => [
          :SILVERWIND, :MYSTICALFIRE, :DRAGONPULSE, :TRIATTACK, :SACREDFIRE, :FIREPLEDGE, :WATERPLEDGE, :GRASSPLEDGE, :AURORABEAM, :MIRRORBEAM, :JUDGMENT, :RELICSONG, :HIDDENPOWER, :SECRETPOWER,
          :WEATHERBALL, :MISTBALL, :HEARTSTAMP, :MOONBLAST, :ZENHEADBUTT, :SPARKLINGARIA, :FLEURCANNON, :PRISMATICLASER, :TWINKLETACKLE, :OCEANICOPERETTA, :SOLARBEAM, :SOLARBLADE, :DAZZLINGGLEAM, :LUMINACRASH
        ],
      },
      :typeBoosts => {
        1.3 => [:NORMAL],
      },
      :typeMessages => {
        "The rainbow energized the attack!" => [:NORMAL],
      },
      :typeCondition => {
        :NORMAL => "self.pbIsSpecial?(attacker, type)",
      },
      :statusBuffs => [],
      :statusNerfs => [],
    },
  },

  :CORROSIVE => {
    :name => "Corrosive Field",
    :fieldAppSwitch => 2010,
    :fieldMessage => "The field is corrupted!",
    :graphic => ["Poison"],
    :secretPower => :ACID,
    :naturePower => :ACIDSPRAY,
    :mimicry => :POISON,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDDYWATER, :WHIRLPOOL, :THOUSANDARROWS, :APPLEACID],
      2.0 => [:ACID, :ACIDSPRAY, :GRASSKNOT, :SNAPTRAP],
    },
    :accuracyMods => {
      100 => [:POISONPOWDER, :SLEEPPOWDER, :STUNSPORE, :TOXIC],
    },
    :moveMessages => {
      "The corrosion strengthened the attack!" => [:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDDYWATER, :WHIRLPOOL, :THOUSANDARROWS, :APPLEACID, :ACID, :ACIDSPRAY, :GRASSKNOT, :SNAPTRAP],
    },
    :typeMods => {
      :POISON => [:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDDYWATER, :WHIRLPOOL, :MUDBOMB, :THOUSANDARROWS, :APPLEACID],
    },
    :typeAddOns => {
      :POISON => [:GRASS],
    },
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :GRASSY => [:SEEDFLARE, :PURIFY],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The polluted field was purified!" => [:SEEDFLARE, :PURIFY],
    },
    :statusBuffs => [:ACIDARMOR, :POISONPOWDER, :SLEEPPOWDER, :STUNSPORE, :TOXIC, :VENOMDRENCH, :VENOSHOCK, :BARBBARRAGE],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :Protect,
      :duration => :BanefulBunker,
      :message => "The Telluric Seed shielded {1} against damage!",
      :animation => :BANEFULBUNKER,
      :stats => {},
    },
  },

  :CORROSIVEMIST => {
    :name => "Corrosive Mist Field",
    :fieldAppSwitch => 2011,
    :fieldMessage => "Corrosive mist settles on the field!",
    :graphic => ["CorrosiveMist"],
    :secretPower => :ACIDSPRAY,
    :naturePower => :CORROSIVEGAS,
    :mimicry => :POISON,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:BUBBLEBEAM, :ACIDSPRAY, :BUBBLE, :SMOG, :CLEARSMOG, :SPARKLINGARIA, :APPLEACID],
    },
    :accuracyMods => {
      100 => [:TOXIC],
    },
    :moveMessages => {
      "The poison strengthened the attack!" => [:BUBBLEBEAM, :ACIDSPRAY, :BUBBLE, :SMOG, :CLEARSMOG, :SPARKLINGARIA, :APPLEACID],
    },
    :typeMods => {
      :POISON => [:BUBBLE, :BUBBLEBEAM, :ENERGYBALL, :SPARKLINGARIA, :APPLEACID, :MISTYEXPLOSION],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FIRE],
    },
    :typeMessages => {
      "The toxic mist caught flame!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [
        :WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE, *PBFields::IGNITEMOVES,
        :SELFDESTRUCT, :EXPLOSION, :BLEAKWINDSTORM
      ],
      :MISTY => [:SEEDFLARE],
      :CORROSIVE => [:GRAVITY],
    },
    :dontChangeBackup => [:GRAVITY],
    :changeMessage => {
      "The mist was blown away!" => [:WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE, :BLEAKWINDSTORM],
      "The polluted mist was purified!" => [:SEEDFLARE],
      "The toxic mist collected on the ground!" => [:GRAVITY],
      "The toxic mist combusted!" => [*PBFields::IGNITEMOVES, :SELFDESTRUCT, :EXPLOSION],
    },
    :statusBuffs => [:ACIDARMOR, :SMOKESCREEN, :TOXIC, :VENOMDRENCH, :VENOSHOCK, :BARBBARRAGE, :MISTYEXPLOSION],
    :statusNerfs => [],
    :changeEffects => {
      "@battle.mistExplosion(basemove, user)" => [*PBFields::IGNITEMOVES, :SELFDESTRUCT, :EXPLOSION],
    },
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::SPATK => 1,
      },
    },
  },

  :DESERT => {
    :name => "Desert Field",
    :fieldAppSwitch => 2012,
    :fieldMessage => "The field is rife with sand.",
    :graphic => ["Desert", "Desert2", "Desert3", "DesertNight", "DesertEve"],
    :secretPower => :SANDTOMB,
    :naturePower => :SANDTOMB,
    :mimicry => :GROUND,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.5 => [:NEEDLEARM, :PINMISSILE, :DIG, :SANDTOMB, :HEATWAVE, :THOUSANDWAVES, :BURNUP, :SEARINGSUNRAZESMASH, :HYDROSTEAM,
              :SOLARBLADE, :SOLARBEAM, :SCALD, :STEAMERUPTION, :SANDSEARSTORM, :BONECLUB, :BONERUSH, :BONEMERANG, :SHADOWBONE, :SCORCHINGSANDS],
      0 => [:SOAK, :AQUARING, :LIFEDEW],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The desert strengthened the attack!" => [:NEEDLEARM, :PINMISSILE, :DIG, :SANDTOMB, :HEATWAVE, :THOUSANDWAVES, :BURNUP, :SEARINGSUNRAZESMASH, :SOLARBLADE, :SOLARBEAM, :SCALD, :STEAMERUPTION, :HYDROSTEAM, :SANDSEARSTORM, :SCORCHINGSANDS],
      "The lifeless desert strengthened the attack!" => [:BONECLUB, :BONERUSH, :BONEMERANG, :SHADOWBONE],
      "The desert is too dry..." => [:SOAK, :AQUARING, :LIFEDEW],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      0.5 => [:WATER, :ELECTRIC],
    },
    :typeMessages => {
      "The desert softened the attack..." => [:WATER, :ELECTRIC],
    },
    :typeCondition => {
      :WATER => "!attacker.isAirborne? && self.move!=:SCALD && self.move!=:STEAMERUPTION && self.move != :HYDROSTEAM",
      :ELECTRIC => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:SANDSTORM, :SUNNYDAY, :SANDATTACK, :SHOREUP, :ARENITEWALL],
    :statusNerfs => [:SOAK],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :MultiTurnAttack,
      :duration => :SANDTOMB,
      :message => "{1} was trapped by Sand Tomb!",
      :animation => :SANDTOMB,
      :stats => {
        PBStats::DEFENSE => 1,
        PBStats::SPDEF => 1,
        PBStats::SPEED => 1,
      },
    },
  },

  :ICY => {
    :name => "Icy Field",
    :fieldAppSwitch => 2013,
    :fieldMessage => "The field is covered in ice.",
    :graphic => ["Icy"],
    :secretPower => :ICESHARD,
    :naturePower => :ICEBEAM,
    :mimicry => :ICE,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.5 => [:BITTERMALICE, :CHILLINGWATER],
      0.5 => [:SCALD, :STEAMERUPTION, :HYDROSTEAM],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The cold strengthened the attack!" => [:BITTERMALICE, :CHILLINGWATER],
      "The cold softened the attack..." => [:SCALD, :STEAMERUPTION, :HYDROSTEAM],
    },
    :typeMods => {},
    :typeAddOns => {
      :ICE => [:ROCK],
    },
    :fieldCounterIncreases => {
      [1, 1, 2, "Parts of the ice melted!"] => [:SCALD, :HYDROSTEAM, :MATCHAGOTCHA],
      [1, 2, 2, nil] => [:STEAMERUPTION],
    },
    :moveEffects => {
      "@battle.iceSpikes" => [*PBFields::QUAKEMOVES],
    },
    :typeBoosts => {
      1.5 => [:ICE],
      0.5 => [:FIRE],
    },
    :typeMessages => {
      "The cold strengthened the attack!" => [:ICE],
      "The cold softened the attack..." => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :INDOOR => "[:WATERSURFACE,:MURKWATERSURFACE, :CAVE].include?(@battle.field.backup) && (self.move!=:DIVE || @battle.field.counter == 3)",
      :WATERSURFACE => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :INDOOR => [:DIVE, *PBFields::QUAKEMOVES],
      :CAVE => [*PBFields::IGNITEMOVES, :MAGMADRIFT, :RAGINGFURY],
      :WATERSURFACE => [:SCALD, :STEAMERUPTION, :HYDROSTEAM, :MATCHAGOTCHA],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The ice was broken from underneath!" => [:DIVE],
      "The quake broke up the ice and revealed the terrain beneath!" => [*PBFields::QUAKEMOVES],
      "The ice melted away!" => [*PBFields::IGNITEMOVES, :MAGMADRIFT, :RAGINGFURY],
      "The hot water melted the ice!" => [:SCALD, :STEAMERUPTION, :HYDROSTEAM],
      "The hot tea melted the ice!" => [:MATCHAGOTCHA],
    },
    :statusBuffs => [:HAIL, :AURORAVEIL, :SNOWSCAPE, :CHILLYRECEPTION, :MATCHAGOTCHA],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPEED => 2,
      },
    },
  },

  :ROCKY => {
    :name => "Rocky Field",
    :fieldAppSwitch => 2014,
    :fieldMessage => "The field is littered with rocks.",
    :graphic => ["Rocky"],
    :secretPower => :ROCKTHROW,
    :naturePower => :ROCKSMASH,
    :mimicry => :ROCK,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.5 => [:ROCKCLIMB, :STRENGTH, :MAGNITUDE, :EARTHQUAKE, :BULLDOZE, :ACCELEROCK],
      2.0 => [:ROCKSMASH],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The rocks strengthened the attack!" => [:ROCKCLIMB, :STRENGTH, :MAGNITUDE, :EARTHQUAKE, :BULLDOZE, :ACCELEROCK],
      "SMASH'D!" => [:ROCKSMASH],
    },
    :typeMods => {
      :ROCK => [:ROCKCLIMB, :EARTHQUAKE, :MAGNITUDE, :STRENGTH, :BULLDOZE],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ROCK],
    },
    :typeMessages => {
      "The field strengthened the attack!" => [:ROCK],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:ROCKPOLISH, :ARENITEWALL, :STEALTHROCK],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::DEFENSE => 1,
        PBStats::SPDEF => 1,
      },
    },
  },

  :FOREST => {
    :name => "Forest Field",
    :fieldAppSwitch => 2015,
    :fieldMessage => "The field is abound with trees.",
    :graphic => ["Forest", "GoldForest", "ForestCave", "2"],
    :secretPower => :WOODHAMMER,
    :naturePower => :WOODHAMMER,
    :mimicry => :BUG,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      0.5 => [:SURF, :MUDDYWATER],
      1.5 => [:GRAVAPPLE, :ATTACKORDER, :ELECTROWEB, :SLASH, :AIRSLASH, :GALESTRIKE, :FURYCUTTER, :AIRCUTTER, :PSYCHOCUT,
              :BREAKINGSWIPE, :BRANCHPOKE],
      2.0 => [:CUT],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The forest softened the attack..." => [:SURF, :MUDDYWATER],
      "They're coming out of the woodwork!" => [:ATTACKORDER],
      "Gossamer and arbor strengthened the attack!" => [:ELECTROWEB],
      "The apple did not fall far from the tree!" => [:GRAVAPPLE],
      "Straight from the tree!" => [:BRANCHPOKE],
      "A tree slammed down!" => [:CUT, :SLASH, :AIRSLASH, :GALESTRIKE, :FURYCUTTER, :AIRCUTTER, :PSYCHOCUT, :BREAKINGSWIPE],
    },
    :typeMods => {
      :GRASS => [:CUT, :SLASH, :AIRSLASH, :GALESTRIKE, :FURYCUTTER, :AIRCUTTER, :PSYCHOCUT, :BREAKINGSWIPE],
    },
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1, 3, "The ground became waterlogged..."] => [:SURF],
      [1, 2, 3, "The ground became waterlogged..."] => [:MUDDYWATER],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:BUG, :GRASS],
    },
    :typeMessages => {
      "The attack spread throughout the forest!" => [:BUG],
      "The forestry strengthened the attack!" => [:GRASS],
    },
    :typeCondition => {
      :BUG => "self.pbIsSpecial?(attacker, type)",
    },
    :typeEffects => {},
    :changeCondition => {
      :SWAMP => "@battle.field.counter > 2",
    },
    :fieldChange => {
      :SWAMP => [:SURF, :MUDDYWATER],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The forest became marshy!" => [:SURF, :MUDDYWATER],
    },
    :statusBuffs => [:STICKYWEB, :DEFENDORDER, :GROWTH, :STRENGTHSAP, :HEALORDER, :NATURESMADNESS, :FORESTSCURSE],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :Protect,
      :duration => :SpikyShield,
      :message => "The Telluric Seed shielded {1} against damage!",
      :animation => :SPIKYSHIELD,
      :stats => {},
    },
  },

  :VOLCANICTOP => {
    :name => "Volcanic Top",
    :fieldAppSwitch => 2016,
    :fieldMessage => "The mountain could erupt any time!",
    :graphic => ["Voltop", "Voltop_1"],
    :secretPower => :FLAMEBURST,
    :naturePower => :ERUPTION,
    :mimicry => :FIRE,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.5 => [:OMINOUSWIND, :SILVERWIND, :RAZORWIND, :ICYWIND, :GUST, :TWISTER, :SMOG, :CLEARSMOG, :PRECIPICEBLADES,
              :THUNDER, :SCALD, :STEAMERUPTION, :INFERNALPARADE, :HYDROSTEAM],
      1.2 => [:ERUPTION, :HEATWAVE, :MAGMASTORM, :LAVAPLUME, :MAGMADRIFT],
      0.5 => [:SURF, :MUDDYWATER, :WATERPLEDGE, :WATERSPOUT, :HYDROPUMP, :SPARKLINGARIA, :HYDROVORTEX, :OCEANICOPERETTA],
    },
    :accuracyMods => {
      0 => [:THUNDER]
    },
    :moveMessages => {
      "The field super-heated the attack!" => [:SCALD, :STEAMERUPTION, :OMINOUSWIND, :SILVERWIND, :RAZORWIND, :ICYWIND, :GUST, :TWISTER, :SMOG, :CLEARSMOG, :PRECIPICEBLADES],
      "The field powers up the flaming attacks!" => [:ERUPTION, :HEATWAVE, :MAGMASTORM, :LAVAPLUME, :MAGMADRIFT, :INFERNALPARADE],
      "The field powers up the attack!" => [:THUNDER],
    },
    :typeMods => {
      :FIRE => [
        :OMINOUSWIND, :SILVERWIND, :RAZORWIND, :ICYWIND, :GUST, :TWISTER, :SMOG, :CLEARSMOG, :PRECIPICEBLADES, :EXPLOSION, :SELFDESTRUCT, :DIG, :DIVE, :SEISMICTOSS, :MAGNETBOMB, :EGGBOMB
      ],
    },
    :typeAddOns => {
      :FIRE => [:ROCK],
    },
    :moveEffects => {
      "@battle.fieldAccuracyDrop" => [
        :SURF, :MUDDYWATER, :WATERPLEDGE, :WATERSPOUT, :SPARKLINGARIA, :OCEANICOPERETTA, :HYDROVORTEX, :HYDROPUMP, :WATERSPORT
      ],
      "@battle.eruptionChecker" => [
        :BULLDOZE, :EARTHQUAKE, :MAGNITUDE, :ERUPTION, :PRECIPICEBLADES, :LAVAPLUME, :MAGMADRIFT, :EARTHPOWER, :FEVERPITCH
      ],
    },
    :typeBoosts => {
      0.5 => [:ICE],
      0.9 => [:WATER],
      1.5 => [:FIRE, :ROCK, :FLYING],
    },
    :typeMessages => {
      "The extreme heat softened the attack..." => [:ICE, :WATER],
      "The attack was super-heated!" => [:FIRE],
      "The mountain strengthened the attack!!" => [:FLYING],
    },
    :typeCondition => {
      :WATER => "!([:SCALD, :HYDROSTEAM, :STEAMERUPTION].include?(self.move))",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :SKY => [:FLY, :BOUNCE,],
      :MOUNTAIN => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The battle was taken to the skies!" => [:FLY, :BOUNCE,],
      "The field cooled off!" => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    },
    :statusBuffs => [:TAILWIND, :STEALTHROCK, :SMOKESCREEN, :POISONGAS],
    :statusNerfs => [:HAIL, :SNOWSCAPE, :CHILLYRECEPTION],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :ShellTrap,
      :duration => true,
      :message => "{1} primed a trap!",
      :animation => "ShellTrap",
      :stats => {
        PBStats::DEFENSE => 1,
      },
    },
  },

  :FACTORY => {
    :name => "Factory Field",
    :fieldAppSwitch => 2017,
    :fieldMessage => "Machines whir in the background.",
    :graphic => ["Factory", "4"],
    :secretPower => :MAGNETBOMB,
    :naturePower => :GEARGRIND,
    :mimicry => :STEEL,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:STEAMROLLER, :TECHNOBLAST, :ULTRAMEGADEATH, :SPINOUT],
      2.0 => [:FLASHCANNON, :GYROBALL, :MAGNETBOMB, :GEARGRIND, :DOUBLEIRONBASH],
    },
    :accuracyMods => {},
    :moveMessages => {
      "ATTACK SEQUENCE UPDATE." => [:STEAMROLLER, :TECHNOBLAST, :ULTRAMEGADEATH, :SPINOUT],
      "ATTACK SEQUENCE INITIATE." => [:FLASHCANNON, :GYROBALL, :MAGNETBOMB, :GEARGRIND, :DOUBLEIRONBASH],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.2 => [:ELECTRIC],
    },
    :typeMessages => {
      "The attack took energy from the field!" => [:ELECTRIC],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :SHORTCIRCUIT => "!(self.move==:ULTRAMEGADEATH && self.pbIsSpecial?(attacker, @type))",
    },
    :fieldChange => {
      :SHORTCIRCUIT => [:AURAWHEEL, :IONDELUGE, :GIGAVOLTHAVOC, :EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :SELFDESTRUCT, :EXPLOSION, :LIGHTTHATBURNSTHESKY, :ULTRAMEGADEATH, :DISCHARGE, :OVERDRIVE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The field was broken!" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :SELFDESTRUCT, :EXPLOSION, :ULTRAMEGADEATH],
      "All the light was consumed!" => [:LIGHTTHATBURNSTHESKY],
      "The field shorted out!" => [:AURAWHEEL, :IONDELUGE, :GIGAVOLTHAVOC, :DISCHARGE, :OVERDRIVE],
    },
    :statusBuffs => [:AUTOTOMIZE, :IRONDEFENSE, :METALSOUND, :SHIFTGEAR, :MAGNETRISE, :GEARUP],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :LaserFocus,
      :duration => 2,
      :message => "{1} is focused!",
      :animation => :LASERFOCUS,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },

  :SHORTCIRCUIT => {
    :name => "Short-Circuit Field",
    :fieldAppSwitch => 2018,
    :fieldMessage => "Bzzt!",
    :graphic => ["ShortCircuit"],
    :secretPower => :ELECTROBALL,
    :naturePower => :DISCHARGE,
    :mimicry => :ELECTRIC,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.667 => [:STEELBEAM],
      1.5 => [:DAZZLINGGLEAM, :SURF, :MUDDYWATER, :MAGNETBOMB, :GYROBALL, :FLASHCANNON, :GEARGRIND, :HYDROVORTEX, :ULTRAMEGADEATH, :LUMINACRASH],
      1.3 => [:DARKPULSE, :NIGHTDAZE, :NIGHTSLASH, :SHADOWBALL, :SHADOWPUNCH, :SHADOWCLAW, :SHADOWSNEAK, :SHADOWFORCE, :SHADOWBONE, :PHANTOMFORCE],
      0.5 => [:LIGHTTHATBURNSTHESKY],
    },
    :accuracyMods => {
      80 => [:ZAPCANNON],
    },
    :moveMessages => {
      "CHARGING UP!" => [:ULTRAMEGADEATH],
      "Blinding!" => [:DAZZLINGGLEAM, :FLASHCANNON, :LUMINACRASH],
      "The attack picked up electricity!" => [:SURF, :MUDDYWATER, :MAGNETBOMB, :GYROBALL, :GEARGRIND, :HYDROVORTEX],
      "The darkness strengthened the attack!" => [:DARKPULSE, :NIGHTDAZE, :NIGHTSLASH, :SHADOWBALL, :SHADOWPUNCH, :SHADOWCLAW, :SHADOWSNEAK, :SHADOWFORCE, :SHADOWBONE, :PHANTOMFORCE],
      "{2} couldn't consume much light..." => [:LIGHTTHATBURNSTHESKY],
    },
    :typeMods => {
      :ELECTRIC => [:SURF, :MUDDYWATER, :MAGNETBOMB, :GYROBALL, :FLASHCANNON, :GEARGRIND, :STEELBEAM],
    },
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1, 2, "Some junk was cleaned up!"] => [:TIDYUP],
      [1, 2, 2, nil] => [:AURAWHEEL, :PARABOLICCHARGE, :WILDCHARGE, :CHARGEBEAM, :IONDELUGE, :GIGAVOLTHAVOC, :ULTRAMEGADEATH, :DISCHARGE, :OVERDRIVE],
    },
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :FACTORY => "@battle.field.counter > 1 && !(self.move==:ULTRAMEGADEATH && self.pbIsPhysical?(attacker, @type))",
    },
    :fieldChange => {
      :FACTORY => [:AURAWHEEL, :PARABOLICCHARGE, :WILDCHARGE, :CHARGEBEAM, :IONDELUGE, :GIGAVOLTHAVOC, :ULTRAMEGADEATH, :DISCHARGE, :OVERDRIVE, :TIDYUP],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "SYSTEM ONLINE." => [:AURAWHEEL, :PARABOLICCHARGE, :WILDCHARGE, :CHARGEBEAM, :IONDELUGE, :GIGAVOLTHAVOC, :ULTRAMEGADEATH, :DISCHARGE, :OVERDRIVE, :TIDYUP],
    },
    :statusBuffs => [:FLASH, :METALSOUND, :MAGNETRISE],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :MagnetRise,
      :duration => 5,
      :message => "{1} levitated with electromagnetism!",
      :animation => :MAGNETRISE,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },

  :WASTELAND => {
    :name => "Wasteland",
    :fieldAppSwitch => 2019,
    :fieldMessage => "The waste is watching...",
    :graphic => ["Wasteland", "Wasteland_1"],
    :secretPower => :GUNKSHOT,
    :naturePower => :GUNKSHOT,
    :mimicry => :POISON,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:VINEWHIP, :POWERWHIP, :MUDSLAP, :MUDBOMB, :MUDSHOT],
      0.25 => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
      2.0 => [:SPITUP],
      1.2 => [:OCTAZOOKA, :SLUDGE, :GUNKSHOT, :SLUDGEWAVE, :SLUDGEBOMB],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The waste did it for the vine!" => [:VINEWHIP, :POWERWHIP],
      "The waste was added to the attack!" => [:MUDSLAP, :MUDBOMB, :MUDSHOT],
      "Wibble-wibble wobble-wobb..." => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
      "BLEAAARGGGGH!" => [:SPITUP],
      "The waste joined the attack!" => [:OCTAZOOKA, :SLUDGE, :GUNKSHOT, :SLUDGEWAVE, :SLUDGEBOMB, :ACIDDOWNPOUR],
    },
    :typeMods => {
      :POISON => [:MUDBOMB, :MUDSLAP, :MUDSHOT],
    },
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1, 3, "Some junk was tidied up!"] => [:TIDYUP],
    },
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :INDOOR => "@battle.field.counter > 2",
    },
    :fieldChange => {
      :INDOOR => [:TIDYUP],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "All tidied up!" => [:TIDYUP],
    },
    :statusBuffs => [:SWALLOW, :STEALTHROCK, :SPIKES, :TOXICSPIKES, :STICKYWEB, :VENOMDRENCH, :VENOSHOCK, :BARBBARRAGE],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::SPATK => 1,
      },
    },
  },

  :ASHENBEACH => {
    :name => "Beach",
    :fieldAppSwitch => 2020,
    :fieldMessage => "Focus and relax to the sound| of crashing waves...",
    :graphic => ["Beach", "AshenBeach", "BeachEve", "BeachNight"],
    :secretPower => :MUDSHOT,
    :naturePower => :MEDITATE,
    :mimicry => :GROUND,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.5 => [:HIDDENPOWER, :BRINE, :SMELLINGSALTS, :CRABHAMMER, :RAZORSHELL, :SHELLSIDEARM, :SHELLTRAP, :SCORCHINGSANDS,
              :SANDSEARSTORM, :STRENGTH, :LANDSWRATH, :THOUSANDWAVES, :SURF, :MUDDYWATER, :WAVECRASH, :CLANGOROUSSOULBLAZE],
      2.0 => [:MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDBARRAGE, :SANDTOMB],
      1.3 => [:STOREDPOWER, :ZENHEADBUTT, :FOCUSBLAST, :AURASPHERE, :FOCUSPUNCH],
      1.2 => [:PSYCHIC],
    },
    :accuracyMods => {
      90 => [:FOCUSBLAST],
    },
    :moveMessages => {
      "...And with pure focus!" => [:HIDDENPOWER, :STRENGTH, :CLANGOROUSSOULBLAZE],
      "The sand strengthened the attack!" => [:LANDSWRATH, :THOUSANDWAVES, :SANDTOMB, :SCORCHINGSANDS, :SANDSEARSTORM],
      "Surf's up!" => [:SURF, :MUDDYWATER, :WAVECRASH],
      "A shining shell on the beach!" => [:RAZORSHELL, :SHELLSIDEARM, :SHELLTRAP],
      "The salty sea strengthened the attack!" => [:BRINE, :SMELLINGSALTS],
      "Time for crab!" => [:CRABHAMMER],
      "Sand mixed into the attack!" => [:MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDBARRAGE],
      "...And with full focus...!" => [:STOREDPOWER, :ZENHEADBUTT, :FOCUSBLAST, :FOCUSPUNCH, :AURASPHERE],
      "...And with focus...!" => [:PSYCHIC],
    },
    :typeMods => {
      :PSYCHIC => [:STRENGTH],
    },
    :typeAddOns => {},
    :moveEffects => {
      "@battle.fieldAccuracyDrop" => [:AIRSLASH, :FIRESPIN, :LEAFTORNADO],
    },
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {
      :windmove => "@battle.fieldAccuracyDrop",
    },
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:CALMMIND, :KINESIS, :MEDITATE, :SANDATTACK, :SANDSTORM, :PSYCHUP, :FOCUSENERGY, :SHOREUP, :ARENITEWALL],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :FocusEnergy,
      :duration => 3,
      :message => "{1}'s Telluric Seed is getting it pumped!",
      :animation => :FOCUSENERGY,
      :stats => {},
    },
  },

  :WATERSURFACE => {
    :name => "Water Surface",
    :fieldAppSwitch => 2021,
    :fieldMessage => "The water's surface is calm.",
    :graphic => ["Water"],
    :secretPower => :AQUAJET,
    :naturePower => :WHIRLPOOL,
    :mimicry => :WATER,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.2 => [:WHIRLPOOL, :SURF, :MUDDYWATER, :WHIRLPOOL, :DIVE, :SLUDGEWAVE, :OCTAZOOKA, :ORIGINPULSE, :HYDROVORTEX, :TRIPLEDIVE],
      0 => [:SPIKES, :TOXICSPIKES],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The attack rode the current!" => [:WHIRLPOOL, :SURF, :MUDDYWATER, :WHIRLPOOL, :DIVE, :ORIGINPULSE, :HYDROVORTEX,:TRIPLEDIVE],
      "Poison spread through the water!" => [:SLUDGEWAVE],
      "...The spikes sank into the water and vanished!" => [:SPIKES, :TOXICSPIKES],
    },
    :typeMods => {},
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1, 2, "Poison spread through the water!"] => [:SLUDGEWAVE],
      [1, 2, 2, nil] => [:ACIDDOWNPOUR],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:WATER, :ELECTRIC],
      0.5 => [:FIRE],
      0 => [:GROUND],
    },
    :typeMessages => {
      "The water conducted the attack!" => [:ELECTRIC],
      "The water strengthened the attack!" => [:WATER],
      "The water deluged the attack..." => [:FIRE],
      "...But there was no solid ground to attack from!" => [:GROUND],
    },
    :typeCondition => {
      :FIRE => "!opponent.isAirborne?",
      :ELECTRIC => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {
      :MURKWATERSURFACE => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :UNDERWATER => [:GRAVITY, :DIVE, :ANCHORSHOT, :GRAVAPPLE, :TRIPLEDIVE],
      :ICY => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
      :MURKWATERSURFACE => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :dontChangeBackup => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    :changeMessage => {
      "The battle sank into the depths!" => [:GRAVITY, :GRAVAPPLE],
      "The battle was pulled underwater!" => [:DIVE, :ANCHORSHOT, :TRIPLEDIVE],
      "The water froze over!" => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
      "The water was polluted!" => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :statusBuffs => [:SPLASH, :AQUARING, :LIFEDEW, :TAKEHEART],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :AquaRing,
      :duration => true,
      :message => "{1} surrounded itself with a veil of water!",
      :animation => :AQUARING,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },

  :UNDERWATER => {
    :name => "Underwater",
    :fieldAppSwitch => 2022,
    :fieldMessage => "Blub blub...",
    :graphic => ["Underwater"],
    :secretPower => :AQUATAIL,
    :naturePower => :WATERPULSE,
    :mimicry => :WATER,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:WATERPULSE, :JETPUNCH],
      2.0 => [:ANCHORSHOT, :DRAGONDARTS],
      0 => [:TARSHOT, :SPICYEXTRACT],
    },
    :accuracyMods => {},
    :moveMessages => {
      "Jet-streamed!" => [:WATERPULSE, :JETPUNCH],
      "From the depths!" => [:ANCHORSHOT, :DRAGONDARTS],
      "The tar washed off instantly!" => [:TARSHOT],
      "The extract washed away!" => [:SPICYEXTRACT],
    },
    :typeMods => {
      :WATER => [:DRAGONDARTS, :GRAVAPPLE],
    },
    :typeAddOns => {
      :WATER => [:GROUND],
    },
    :fieldCounterIncreases => {
      [1, 1, 2, "Poison spread through the water!"] => [:SLUDGEWAVE],
      [1, 2, 2, nil] => [:ACIDDOWNPOUR],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:WATER],
      2.0 => [:ELECTRIC],
      0 => [:FIRE],
    },
    :typeMessages => {
      "The water strengthened the attack!" => [:WATER],
      "The water super-conducted the attack!" => [:ELECTRIC],
      "...But the attack was doused instantly!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :MURKWATERSURFACE => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :WATERSURFACE => [:DIVE, :SKYDROP, :FLY, :BOUNCE, :SHOREUP, :TRIPLEDIVE],
      :MURKWATERSURFACE => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The battle resurfaced!" => [:DIVE, :SKYDROP, :FLY, :BOUNCE, :SHOREUP, :TRIPLEDIVE],
      "The grime sank beneath the battlers!" => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :statusBuffs => [:AQUARING, :TAKEHEART, :OCTOLOCK],
    :statusNerfs => [*PBStuff::WEATHERMOVE, *PBStuff::TERRAINMOVE],
    :changeEffects => {
      "@battle.waterPollution" => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => nil,
      :duration => 0,
      :message => "{1} transformed into the Water type!",
      :animation => :SOAK,
      :stats => {
        PBStats::SPEED => 1,
      },
    },
  },

  :CAVE => {
    :name => "Cave",
    :fieldAppSwitch => 2023,
    :fieldMessage => "The cave echoes dully...",
    :graphic => ["Cave","CaveAqua","CaveDark","CaveDarker"],
    :secretPower => :ROCKWRECKER,
    :naturePower => :ROCKTOMB,
    :mimicry => :ROCK,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.5 => [:ROCKTOMB, :DRUMBEATING, :HYPERDRILL, :DRILLRUN],
      0 => [:SKYDROP],
    },
    :accuracyMods => {},
    :moveMessages => {
      "...Piled on!" => [:ROCKTOMB],
      "Tunneled through!" => [:DRILLRUN, :HYPERDRILL],
      "ECHO-Echo-echo!" => [:DRUMBEATING],
      "The cavern strengthened the attack!" => [:TERASTARSTORM],
      "The cave's low ceiling makes flying high impossible..." => [:SKYDROP],
    },
    :typeMods => {},
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [2, 1, 2, "Draconic energy seeps in..."] => [:DRAGONPULSE],
      [5, 1, 2, "Frost began to spread..."] => [:BLIZZARD],
      [5, 2, 2, nil] => [:SUBZEROSLAMMER],
      [2, 2, 2, nil] => [:DRACOMETEOR, :DEVASTATINGDRAKE],
      [3, 1, 2, "The cave is heating up..."] => [:FEVERPITCH, :MAGMADRIFT, :ERUPTION, :LAVAPLUME, :HEATWAVE, :OVERHEAT, :FUSIONFLARE],
      [4, 1, 2, "Intense gravity is pulling from deep below..."] => [:GRAVITY],
    },
    :moveEffects => {
      "@battle.caveCollapse(basemove, user)" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :CONTINENTALCRUSH],
    },
    :typeBoosts => {
      1.5 => [:ROCK, :soundmove],
      0.5 => [:FLYING],
    },
    :typeMessages => {
      "The cave choked out the air!" => [:FLYING],
      "The cavern strengthened the attack!" => [:ROCK],
      "ECHO-Echo-echo!" => [:soundmove],
    },
    :typeCondition => {
      :FLYING => "!attacker.makesContact?(self)",
    },
    :typeEffects => {},
    :changeCondition => {
      :DRAGONSDEN => "@battle.field.counter2 > 1",
      :VOLCANIC => "@battle.field.counter3 > 1",
      :DEEPEARTH => "@battle.field.counter4 > 1",
      :ICY => "@battle.field.counter5 > 1",
    },
    :fieldChange => {
      :CRYSTALCAVERN => [:POWERGEM, :DIAMONDSTORM, :TERASTARSTORM],
      :ICY => [:BLIZZARD, :SUBZEROSLAMMER],
      :CORRUPTED => [:SLUDGEWAVE, :ACIDDOWNPOUR],
      :VOLCANIC => [:FEVERPITCH, :MAGMADRIFT, :ERUPTION, :LAVAPLUME, :HEATWAVE, :OVERHEAT, :FUSIONFLARE],
      :DRAGONSDEN => [:DRAGONPULSE, :DRACOMETEOR, :DEVASTATINGDRAKE],
      :DEEPEARTH => [:GRAVITY],
    },
    :dontChangeBackup => [:BLIZZARD, :SUBZEROSLAMMER],
    :changeMessage => {
      "The cave was littered with crystals!" => [:POWERGEM, :DIAMONDSTORM],
      "The cavern froze over!" => [:BLIZZARD, :SUBZEROSLAMMER],
      "The cave was corrupted!" => [:SLUDGEWAVE, :ACIDDOWNPOUR],
      "The flame ignited the cave!" => [:FEVERPITCH, :MAGMADRIFT, :ERUPTION, :LAVAPLUME, :HEATWAVE, :OVERHEAT, :FUSIONFLARE],
      "The draconic energy mutated the field!" => [:DRAGONPULSE, :DRACOMETEOR, :DEVASTATINGDRAKE],
      "The battle was pulled deeper into the earth!" => [:GRAVITY],
    },
    :statusBuffs => [:STEALTHROCK],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::DEFENSE => 2,
      },
    },
  },

  :GLITCH => {
    :name => "Glitch Field",
    :fieldAppSwitch => 2024,
    :fieldMessage => "1n!taliz3 .b//////attl3",
    :graphic => ["Glitch", "99"],
    :secretPower => :TECHNOBLAST,
    :naturePower => :METRONOME,
    :mimicry => :QMARKS,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      0 => [:ROAR, :WHIRLWIND],
    },
    :accuracyMods => {
      90 => [:BLIZZARD],
    },
    :moveMessages => {
      "ERROR! MOVE NOT FOUND!" => [:ROAR, :WHIRLWIND],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.2 => [:PSYCHIC],
    },
    :typeMessages => {
      ".0P pl$ nerf!-//" => [:PSYCHIC],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:METRONOME],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => nil,
      :duration => 0,
      :message => "{1}.TYPE = :QMARKS",
      :animation => :AMNESIA,
      :stats => {
        PBStats::DEFENSE => 1,
        PBStats::SPDEF => 1,
      },
    },
  },

  :CRYSTALCAVERN => {
    :name => "Crystal Cavern",
    :fieldAppSwitch => 2025,
    :fieldMessage => "The cave is littered with crystals.",
    :graphic => ["CrystalCavern", "AmethystCave", "CaveAqua"],
    :secretPower => :POWERGEM,
    :naturePower => :POWERGEM,
    :mimicry => :DRAGON,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.3 => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :DAZZLINGGLEAM, :MIRRORSHOT, :MIRRORBEAM, :TECHNOBLAST, :DOOMDESIRE, :DOOMDUMMY,
              :MOONGEISTBEAM, :PHOTONGEYSER, :MENACINGMOONRAZEMAELSTROM, :LUMINACRASH],
      1.5 => [:POWERGEM, :DIAMONDSTORM, :ANCIENTPOWER, :JUDGMENT, :ROCKSMASH, :ROCKTOMB, :STRENGTH, :ROCKCLIMB, :MULTIATTACK, :PRISMATICLASER, :LUSTERPURGE, :TERASTARSTORM],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The crystals' light strengthened the attack!" => [
        :AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :MIRRORBEAM, :TECHNOBLAST, :DOOMDUMMY, :MOONGEISTBEAM, :PHOTONGEYSER, :PRISMATICLASER, :MENACINGMOONRAZEMAELSTROM, :LUMINACRASH, :TERASTARSTORM
      ],
      "The crystals strengthened the attack!" => [:POWERGEM, :DIAMONDSTORM, :ANCIENTPOWER, :JUDGMENT, :ROCKSMASH, :ROCKTOMB, :STRENGTH, :ROCKCLIMB, :MULTIATTACK],
    },
    :typeMods => {},
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1, 2, "The crystals are starting to crack..."] => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE],
      [1, 2, 2, nil] => [:TECTONICRAGE],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ROCK, :DRAGON],
    },
    :typeMessages => {
      "The crystals charged the attack!" => [:ROCK],
      "The crystal energy strengthened the attack!" => [:DRAGON],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :CAVE => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :CAVE => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
      :DARKCRYSTALCAVERN => [:DARKPULSE, :DARKVOID, :NIGHTDAZE, :LIGHTTHATBURNSTHESKY],
    },
    :dontChangeBackup => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :DARKPULSE, :DARKVOID, :NIGHTDAZE],
    :changeMessage => {
      "The crystals were broken up!" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
      "The crystals' light was warped by the darkness!" => [:DARKPULSE, :DARKVOID, :NIGHTDAZE],
      "The crystals' light was consumed!" => [:LIGHTTHATBURNSTHESKY],
    },
    :statusBuffs => [:ROCKPOLISH, :STEALTHROCK, :AURORAVEIL],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :MagicCoat,
      :duration => true,
      :message => "{1} shrouded itself with Magic Coat!",
      :animation => :MAGICCOAT,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },

  :MURKWATERSURFACE => {
    :name => "Murkwater Surface",
    :fieldAppSwitch => 2026,
    :fieldMessage => "The water is tainted...",
    :graphic => ["MurkwaterSurface", "Water2"],
    :secretPower => :SLUDGEBOMB,
    :naturePower => :SLUDGEWAVE,
    :mimicry => :POISON,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:MUDBOMB, :MUDSLAP, :MUDSHOT, :MUDBARRAGE, :SMACKDOWN, :ACID, :ACIDSPRAY, :BRINE, :THOUSANDWAVES, :APPLEACID],
      0 => [:SPIKES, :TOXICSPIKES],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The toxic water strengthened the attack!" => [:MUDBOMB, :MUDBARRAGE, :MUDSLAP, :MUDSHOT, :SMACKDOWN, :ACID, :ACIDSPRAY, :THOUSANDWAVES, :APPLEACID],
      "Stinging!" => [:BRINE],
      "...The spikes sank into the water and vanished!" => [:SPIKES, :TOXICSPIKES],
    },
    :typeMods => {
      :POISON => [:MUDBOMB, :MUDSLAP, :MUDSHOT, :MUDBARRAGE, :SMACKDOWN, :THOUSANDWAVES, :APPLEACID],
      :WATER => [:SLUDGEWAVE],
    },
    :typeAddOns => {
      :POISON => [:WATER],
    },
    :fieldCounterIncreases => {
      [1, 1, 2, "Some sludge was tidied up!"] => [:TIDYUP],
      [1, 2, 2, nil] => [:WHIRLPOOL, :PURIFY],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:WATER, :POISON],
      1.3 => [:ELECTRIC],
      0 => [:GROUND],
    },
    :typeMessages => {
      "The toxic water strengthened the attack!" => [:WATER, :POISON],
      "The toxic water conducted the attack!" => [:ELECTRIC],
      "...But there was no solid ground to attack from!" => [:GROUND],
    },
    :typeCondition => {
      :ELECTRIC => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {
      :WATERSURFACE => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :WATERSURFACE => [:WHIRLPOOL, :PURIFY, :TIDYUP],
      :ICY => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    },
    :dontChangeBackup => [:WHIRLPOOL, :PURIFY, :BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    :changeMessage => {
      "The maelstrom flushed out the poison!" => [:WHIRLPOOL],
      "The attack cleared the waters!" => [:PURIFY],
      "The toxic water froze over!" => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    },
    :statusBuffs => [:ACIDARMOR, :TARSHOT, :VENOMDRENCH, :VENOSHOCK, :BARBBARRAGE],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :AquaRing,
      :duration => true,
      :message => "{1} surrounded itself with a veil of water!",
      :animation => :AQUARING,
      :stats => {
        PBStats::SPEED => 1,
      },
    },
  },

  :MOUNTAIN => {
    :name => "Mountain",
    :fieldAppSwitch => 2027,
    :fieldMessage => "High up!",
    :graphic => ["Mountain"],
    :secretPower => :ROCKBLAST,
    :naturePower => :ROCKSLIDE,
    :mimicry => :ROCK,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.5 => [:VITALTHROW, :CIRCLETHROW, :STORMTHROW, :OMINOUSWIND, :ICYWIND, :SILVERWIND, :TWISTER, :RAZORWIND,
              :FAIRYWIND, :THUNDER, :ERUPTION, :AVALANCHE, :HYPERVOICE, :MOUNTAINGALE, :GUST],
    },
    :accuracyMods => {
      0 => [:THUNDER]
    },
    :moveMessages => {
      "{1} was thrown partway down the mountain!" => [:VITALTHROW, :CIRCLETHROW, :STORMTHROW],
      "The mountain winds strengthened the attack!" => [:OMINOUSWIND, :ICYWIND, :SILVERWIND, :TWISTER, :RAZORWIND, :FAIRYWIND, :MOUNTAINGALE, :GUST],
      "The mountain strengthened the attack!" => [:THUNDER, :ERUPTION, :AVALANCHE],
      "Yodelayheehoo~" => [:HYPERVOICE],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ROCK, :FLYING],
    },
    :typeMessages => {
      "The mountain strengthened the attack!" => [:ROCK],
      "The open air strengthened the attack!" => [:FLYING],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :SNOWYMOUNTAIN => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER, :MOUNTAINGALE],
      :SKY => [:FLY, :BOUNCE],
      :VOLCANICTOP => [:LAVAPLUME, :MAGMADRIFT, :ERUPTION, :INFERNOOVERDRIVE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The mountain was covered in snow!" => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER, :MOUNTAINGALE],
      "The battle was taken to the skies!" => [:FLY, :BOUNCE],
      "The mountain erupted!" => [:LAVAPLUME, :MAGMADRIFT, :ERUPTION, :INFERNOOVERDRIVE],
    },
    :statusBuffs => [:TAILWIND, :SUNNYDAY],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 2,
        PBStats::ACCURACY => -1,
      },
    },
  },

  :SNOWYMOUNTAIN => {
    :name => "Snowy Mountain",
    :fieldAppSwitch => 2028,
    :fieldMessage => "The snow glows white| on the mountain...",
    :graphic => ["SnowyMountain"],
    :secretPower => :ICEBALL,
    :naturePower => :AVALANCHE,
    :mimicry => :ICE,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.5 => [:VITALTHROW, :CIRCLETHROW, :STORMTHROW, :OMINOUSWIND, :SILVERWIND, :TWISTER, :RAZORWIND, :FAIRYWIND,
              :AVALANCHE, :POWDERSNOW, :HYPERVOICE, :GLACIATE, :MOUNTAINGALE, :BITTERMALICE, :GUST, :CHILLINGWATER],
      0.5 => [:SCALD, :STEAMERUPTION, :HYDROSTEAM],
      2.0 => [:ICYWIND],
    },
    :accuracyMods => {
      0 => [:THUNDER]
    },
    :moveMessages => {
      "{1} was thrown partway down the mountain!" => [:VITALTHROW, :CIRCLETHROW, :STORMTHROW],
      "The mountain winds strengthened the attack!" => [:OMINOUSWIND, :SILVERWIND, :TWISTER, :RAZORWIND, :FAIRYWIND, :MOUNTAINGALE, :GUST],
      "The snow strengthened the attack!" => [:AVALANCHE, :POWDERSNOW, :BITTERMALICE, :CHILLINGWATER],
      "The cold softened the attack..." => [:SCALD, :STEAMERUPTION, :HYDROSTEAM],
      "The frigid wind strengthened the attack!" => [:ICYWIND],
      "Yodelayheehoo~" => [:HYPERVOICE],
    },
    :typeMods => {},
    :typeAddOns => {
      :ICE => [:ROCK],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ROCK, :ICE, :FLYING],
      0.5 => [:FIRE],
    },
    :typeMessages => {
      "The snowy mountain strengthened the attack!" => [:ROCK, :ICE],
      "The open air strengthened the attack!" => [:FLYING],
      "The cold softened the attack!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :MOUNTAIN => [*(PBFields::IGNITEMOVES - [:ERUPTION]), :RAGINGFURY],
      :VOLCANICTOP => [:ERUPTION, :MAGMADRIFT],
      :SKY => [:FLY, :BOUNCE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The snow melted away!" => [*(PBFields::IGNITEMOVES - [:ERUPTION]), :RAGINGFURY],
      "The mountain erupted!" => [:ERUPTION, :MAGMADRIFT],
      "The battle was taken to the skies!" => [:FLY, :BOUNCE],
    },
    :statusBuffs => [:TAILWIND, :SUNNYDAY, :HAIL, :SNOWSCAPE, :CHILLYRECEPTION, :AURORAVEIL, :MATCHAGOTCHA],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPATK => 2,
        PBStats::ACCURACY => -1,
      },
    },
  },

  :HOLY => {
    :name => "Blessed Field",
    :fieldAppSwitch => 2029,
    :fieldMessage => "The field is blessed!",
    :graphic => ["Ruin", "Ruin2", "Ruin3","Ruin4"],
    :secretPower => :DAZZLINGGLEAM,
    :naturePower => :JUDGMENT,
    :mimicry => :NORMAL,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.3 => [
        :PSYSTRIKE, :AEROBLAST, :ORIGINPULSE, :DOOMDESIRE, :DOOMDUMMY, :MISTBALL, :CRUSHGRIP, :LUSTERPURGE, :SECRETSWORD,
        :PSYCHOBOOST, :RELICSONG, :SPACIALREND, :HYPERSPACEHOLE, :ROAROFTIME, :LANDSWRATH, :PRECIPICEBLADES, :OBLIVIONWING,
        :DRAGONASCENT, :MOONGEISTBEAM, :SUNSTEELSTRIKE, :PRISMATICLASER, :FLEURCANNON, :DIAMONDSTORM, :GENESISSUPERNOVA,
        :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM, :VCREATE,
        # Gen 8
        :DOUBLEIRONBASH, :BEHEMOTHBLADE, :BEHEMOTHBASH, :THUNDERCAGE, :DRAGONENERGY,
        :FREEZINGGLARE, :THUNDEROUSKICK, :GLACIALLANCE, :ASTRALBARRAGE,
        # Gen 9
        :SPRINGTIDESTORM, :WILDBOLTSTORM, :BLEAKWINDSTORM, :SANDSEARSTORM, :COLLISIONCOURSE,
        :ELECTRODRIFT, :IVYCUDGEL, :TERASTARSTORM,
        # Rejuv Custom
        :MULTIPULSE
      ],
      1.5 => [:MYSTICALFIRE, :MAGICALLEAF, :ANCIENTPOWER, :JUDGMENT, :SACREDFIRE, :EXTREMESPEED, :SACREDSWORD, :RETURN, :MYSTICALPOWER],
      0.5 => [:EERIESPELL, :BITTERBLADE],
    },
    :accuracyMods => {},
    :moveMessages => {
      "Legendary power accelerated the attack!" => [
        :PSYSTRIKE, :AEROBLAST, :SACREDFIRE, :ORIGINPULSE, :DOOMDUMMY, :JUDGMENT, :MISTBALL, :CRUSHGRIP,
        :LUSTERPURGE, :SECRETSWORD, :PSYCHOBOOST, :RELICSONG, :SPACIALREND, :HYPERSPACEHOLE, :ROAROFTIME,
        :LANDSWRATH, :PRECIPICEBLADES, :DRAGONASCENT, :MOONGEISTBEAM, :SUNSTEELSTRIKE, :PRISMATICLASER, :OBLIVIONWING,
        :FLEURCANNON, :DIAMONDSTORM, :GENESISSUPERNOVA, :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM, :VCREATE,
        # Gen 8
        :DOUBLEIRONBASH, :BEHEMOTHBLADE, :BEHEMOTHBASH, :THUNDERCAGE, :DRAGONENERGY,
        :FREEZINGGLARE, :THUNDEROUSKICK, :GLACIALLANCE, :ASTRALBARRAGE,
        # Gen 9
        :SPRINGTIDESTORM, :WILDBOLTSTORM, :BLEAKWINDSTORM, :SANDSEARSTORM, :MYSTICALPOWER,
        :COLLISIONCOURSE, :ELECTRODRIFT, :IVYCUDGEL, :TERASTARSTORM,
        # Rejuv Custom
        :MULTIPULSE
      ],
      "The holy energy resonated with the attack!" => [:MYSTICALFIRE, :MAGICALLEAF, :ANCIENTPOWER, :SACREDSWORD, :RETURN, :MYSTICALPOWER],
      "Godspeed!" => [:EXTREMESPEED],
      "The attack was cleansed..." => [:EERIESPELL, :BITTERBLADE],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FAIRY, :NORMAL],
      1.2 => [:PSYCHIC, :DRAGON],
      0.5 => [:GHOST, :DARK],
    },
    :typeMessages => {
      "The holy energy resonated with the attack!" => [:FAIRY, :NORMAL],
      "The legendary energy resonated with the attack!" => [:PSYCHIC, :DRAGON],
      "The attack was cleansed..." => [:GHOST, :DARK],
    },
    :typeCondition => {
      :FAIRY => "self.pbIsSpecial?(attacker, type)",
      :NORMAL => "self.pbIsSpecial?(attacker, type)",
      :DARK => "self.pbIsSpecial?(attacker, type)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [:LIGHTTHATBURNSTHESKY],
      :HAUNTED => [:CURSE, :PHANTOMFORCE, :SPECTRALSCREAM, :SHADOWFORCE, :OMINOUSWIND, :TRICKORTREAT],
    },
    :dontChangeBackup => [:CURSE, :PHANTOMFORCE, :SPECTRALSCREAM, :SHADOWFORCE, :OMINOUSWIND, :TRICKORTREAT],
    :changeMessage => {
      "Evil spirits gathered!" => [:CURSE, :PHANTOMFORCE, :SPECTRALSCREAM, :SHADOWFORCE, :OMINOUSWIND, :TRICKORTREAT],
      "The holy light was consumed!" => [:LIGHTTHATBURNSTHESKY],
    },
    :statusBuffs => [:LIFEDEW, :WISH, :MIRACLEEYE, :COSMICPOWER, :NATURESMADNESS, :JUNGLEHEALING, :LUNARBLESSING, :TAKEHEART],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :MagicCoat,
      :duration => true,
      :message => "{1} shrouded itself with Magic Coat!",
      :animation => :MAGICCOAT,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },

  :DEEPEARTH => {
    :name => "Deep Earth",
    :fieldAppSwitch => 2030,
    :fieldMessage => "The Core is pulling you in...",
    :graphic => ["DeepEarth", "Zeight", "Zeight2", "Zeight3", "Zeight4"],
    :secretPower => :HEAVYSLAM,
    :naturePower => :GRAVITY,
    :mimicry => :GROUND,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      2.0 => [:LANDSWRATH, :PRECIPICEBLADES, :MAGNETBOMB, :TECTONICRAGE, :CRUSHGRIP, :SMACKDOWN, :COREENFORCER],
      1.5 => [:HEAVYSLAM, :HEATCRASH, :BODYSLAM, :STOMP, :DRAGONRUSH, :STEAMROLLER, :GRAVAPPLE, :ANCIENTPOWER, :FLING,
              :GRASSKNOT, :LOWKICK, :SPACIALREND, :STORMTHROW, :CIRCLETHROW, :VITALTHROW, :BODYPRESS, :SUBMISSION, :ICEHAMMER, :HAMMERARM, :CRABHAMMER, :ICICLECRASH, :THOUSANDARROWS, :THOUSANDWAVES],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The attack came crashing down!" => [:HEAVYSLAM, :HEATCRASH, :BODYSLAM, :STOMP, :DRAGONRUSH, :STEAMROLLER, :GRAVAPPLE, :BODYPRESS, :ICICLECRASH, :FLING],
      "Enjoy the trip!" => [:GRASSKNOT, :LOWKICK],
      "{2} threw their whole weight into it!" => [:ICEHAMMER, :HAMMERARM, :CRABHAMMER],
      "Slammed into the ground!" => [:STORMTHROW, :CIRCLETHROW, :VITALTHROW, :SUBMISSION, :SMACKDOWN],
      "CRUSHED!" => [:CRUSHGRIP],
      "The magnetic field is strengthened!" => [:MAGNETBOMB],
      "The power of the earth is utterly overwhelming!" => [:THOUSANDARROWS, :THOUSANDWAVES, :LANDSWRATH, :PRECIPICEBLADES, :TECTONICRAGE],
      "The power of ages gone by..." => [:ANCIENTPOWER],
      "The power of the Core obliterates all!" => [:COREENFORCER],
      "The intense gravity is ruptured!" => [:SPACIALREND],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.3 => [:ROCK, :PSYCHIC],
      1.5 => [:GROUND],
    },
    :typeMessages => {
      "The Core's magical forces are immense!" => [:PSYCHIC],
      "The earth empowered the attack!" => [:ROCK, :GROUND],
    },
    :typeCondition => {
      :GROUND => "!opponent.hasType?(:GROUND)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:AUTOTOMIZE, :GEOMANCY, :ROTOTILLER, :MAGNETFLUX, :EERIEIMPULSE, :MAGNETRISE, :GRAVITY, :TOPSYTURVY, :SEISMICTOSS, :PSYWAVE],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => nil,
      :message => "{1}'s weight increased!",
      :animation => :QUASH,
      :stats => {
        PBStats::DEFENSE => 1,
      }
    },
  },

  :FAIRYTALE => {
    :name => "Fairy Tale Field",
    :fieldAppSwitch => 2031,
    :fieldMessage => "Once upon a time...",
    :graphic => ["FairyTale"],
    :secretPower => :SLASH,
    :naturePower => :SECRETSWORD,
    :mimicry => :FAIRY,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:SMARTSTRIKE, :MAGICALLEAF, :MYSTICALFIRE, :ANCIENTPOWER, :RELICSONG, :SPARKLINGARIA, :MOONGEISTBEAM, :FLEURCANNON, :BEHEMOTHBASH,
              :OCEANICOPERETTA, :MENACINGMOONRAZEMAELSTROM, :EERIESPELL, :ARMORCANNON],
      2.0 => [:DRAININGKISS, :MISTBALL],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The blade cuts true!" => [:SMARTSTRIKE],
      "The magical energy strengthened the attack!" => [:MAGICALLEAF, :MYSTICALFIRE, :ANCIENTPOWER, :RELICSONG, :SPARKLINGARIA, :MOONGEISTBEAM, :FLEURCANNON, :BEHEMOTHBASH, :MISTBALL, :OCEANICOPERETTA, :MENACINGMOONRAZEMAELSTROM, :EERIESPELL, :ARMORCANNON],
      "True love never hurt so badly!" => [:DRAININGKISS],
      "The shield strikes true!" => [:BEHEMOTHBASH],
    },
    :typeMods => {
      :FAIRY => [:MAGICPOWDER]
    },
    :typeAddOns => {
      :DRAGON => [:FIRE],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:STEEL, :FAIRY, :sharpmove],
      2.0 => [:DRAGON],
    },
    :typeMessages => {
      "For ever after!" => [:FAIRY],
      "For justice!" => [:STEEL],
      "The foul beast's attack gained strength!" => [:DRAGON],
      "The blade cuts true!" => [:sharpmove],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:KINGSSHIELD, :CRAFTYSHIELD, :FLOWERSHIELD, :ACIDARMOR, :NOBLEROAR, :SWORDSDANCE, :WISH, :HEALINGWISH, :MIRACLEEYE, :FORESTSCURSE, :FLORALHEALING],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :Protect,
      :duration => :KingsShield,
      :message => "The Magical Seed shielded {1} against damage!",
      :animation => :KINGSSHIELD,
      :stats => {},
    },
  },

  :DRAGONSDEN => {
    :name => "Dragon's Den",
    :fieldAppSwitch => 2032,
    :fieldMessage => "If you wish to slay a dragon...",
    :graphic => ["DragonsDen", "DragonsDen_1"],
    :secretPower => :DRAGONPULSE,
    :naturePower => :DRAGONPULSE,
    :mimicry => :DRAGON,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      1.5 => [:MEGAKICK, :MAGMASTORM, :LAVAPLUME, :STOMPINGTANTRUM, :EARTHPOWER, :DIAMONDSTORM, :MATRIXSHOT, :SHELLTRAP,
              :POWERGEM, :MAGMADRIFT, :ROCKCLIMB, :STRENGTH, :PAYDAY, :MAKEITRAIN, :TERASTARSTORM],
      2.0 => [:SMACKDOWN, :THOUSANDARROWS, :DRAGONASCENT, :MISTBALL, :LUSTERPURGE],
      0 => [:HAIL, :SNOWSCAPE],
    },
    :accuracyMods => {
      100 => [:DRAGONRUSH],
    },
    :moveMessages => {
      "Trial of the Dragon!!!" => [:STOMPINGTANTRUM, :MEGAKICK],
      "Unrivaled power!" => [:STRENGTH, :ROCKCLIMB],
      "The lava strengthened the attack!" => [:MAGMASTORM, :LAVAPLUME, :EARTHPOWER, :SHELLTRAP, :MAGMADRIFT],
      "{1} was knocked into the lava!" => [:SMACKDOWN, :THOUSANDARROWS],
      "The draconic energy boosted the attack!" => [:DRAGONASCENT, :MISTBALL, :LUSTERPURGE],
      "Sparkling treasure!" => [:PAYDAY, :POWERGEM, :DIAMONDSTORM, :MATRIXSHOT, :MAKEITRAIN, :TERASTARSTORM],
      "The hail is melting in the heat..." => [:HAIL],
      "The snow is melting in the heat..." => [:SNOWSCAPE],
    },
    :typeMods => {
      :FIRE => [:SMACKDOWN, :THOUSANDARROWS, :STRENGTH, :ROCKCLIMB,],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:DRAGON, :FIRE],
      0.5 => [:ICE, :WATER],
    },
    :typeMessages => {
      "The lava's heat boosted the flame!" => [:FIRE],
      "The draconic energy boosted the attack!" => [:DRAGON],
      "The lava's heat softened the attack..." => [:ICE, :WATER],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :CAVE => [:GLACIATE, :SUBZEROSLAMMER, :OCEANICOPERETTA, :HYDROVORTEX],
      :FAIRYTALE => [:MISTBALL],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The lava was frozen solid!" => [:GLACIATE, :SUBZEROSLAMMER],
      "The lava solidified!" => [:OCEANICOPERETTA, :HYDROVORTEX],
      "The mist-ical energy altered the surroundings!" => [:MISTBALL],
    },
    :statusBuffs => [:DRAGONDANCE, :NOBLEROAR, :COIL, :STEALTHROCK],
    :statusNerfs => [:CHILLYRECEPTION],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :FlashFire,
      :duration => true,
      :message => "{1} raised its Fire power!",
      :animation => nil,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },

  :FLOWERGARDEN1 => {
    :name => "Flower Garden",
    :fieldAppSwitch => 2033,
    :fieldMessage => "Seeds line the field.",
    :graphic => ["FlowerGarden0"],
    :secretPower => :SWEETSCENT,
    :naturePower => :GROWTH,
    :mimicry => :GRASS,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {},
    :accuracyMods => {},
    :moveMessages => {},
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :FLOWERGARDEN2 => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :GRASSYTERRAIN, :WATERSPORT, :BLOOMDOOM],
    },
    :dontChangeBackup => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :GRASSYTERRAIN, :WATERSPORT, :BLOOMDOOM],
    :changeMessage => {
      "The garden grew a little!" => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :GRASSYTERRAIN, :WATERSPORT, :BLOOMDOOM],
    },
    :statusBuffs => [:GROWTH, :ROTOTILLER, :RAINDANCE, :WATERSPORT, :SUNNYDAY, :FLOWERSHIELD, :INGRAIN, :FLORALHEALING],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :FLOWERGARDEN2 => {
    :name => "Flower Garden",
    :fieldAppSwitch => 2033,
    :fieldMessage => "Seeds line the field.",
    :graphic => ["FlowerGarden1"],
    :secretPower => :PETALBLIZZARD,
    :naturePower => :GROWTH,
    :mimicry => :GRASS,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:CUT],
    },
    :accuracyMods => {},
    :moveMessages => {
      "{1} was cut down to size!" => [:CUT],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.1 => [:GRASS],
    },
    :typeMessages => {
      "The garden's power boosted the attack!" => [:GRASS],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :FLOWERGARDEN3 => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :GRASSYTERRAIN, :WATERSPORT, :BLOOMDOOM],
      :FLOWERGARDEN1 => [:CUT, :XSCISSOR, :ACIDDOWNPOUR, :BREAKINGSWIPE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The garden was cut down a bit!" => [:CUT, :XSCISSOR, :BREAKINGSWIPE],
      "The garden grew a little!" => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :GRASSYTERRAIN, :WATERSPORT, :BLOOMDOOM],
      "The acid melted the bloom!" => [:ACIDDOWNPOUR],
    },
    :statusBuffs => [:GROWTH, :ROTOTILLER, :RAINDANCE, :WATERSPORT, :SUNNYDAY, :FLOWERSHIELD, :INGRAIN, :FLORALHEALING],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :FLOWERGARDEN3 => {
    :name => "Flower Garden",
    :fieldAppSwitch => 2033,
    :fieldMessage => "Seeds line the field.",
    :graphic => ["FlowerGarden2"],
    :secretPower => :PETALBLIZZARD,
    :naturePower => :GROWTH,
    :mimicry => :GRASS,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:CUT],
      1.2 => [:PETALBLIZZARD, :PETALDANCE, :FLEURCANNON, :SPRINGTIDESTORM, :FLOWERTRICK],
    },
    :accuracyMods => {
      85 => [:SLEEPPOWDER, :STUNSPORE, :POISONPOWDER],
    },
    :moveMessages => {
      "{1} was cut down to size!" => [:CUT],
      "The fresh scent of flowers boosted the attack!" => [:PETALBLIZZARD, :PETALDANCE, :FLEURCANNON, :SPRINGTIDESTORM, :FLOWERTRICK],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FIRE, :BUG],
      1.3 => [:GRASS],
    },
    :typeMessages => {
      "The budding flowers boosted the attack!" => [:GRASS],
      "The attack infested the garden!" => [:BUG],
      "The nearby flowers caught flame!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :FLOWERGARDEN4 => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :GRASSYTERRAIN, :WATERSPORT, :BLOOMDOOM],
      :FLOWERGARDEN2 => [:CUT, :XSCISSOR, :BREAKINGSWIPE],
      :FLOWERGARDEN1 => [:ACIDDOWNPOUR, *(PBFields::IGNITEMOVES - [:INCINERATE])],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The garden caught fire!" => [*(PBFields::IGNITEMOVES - [:INCINERATE])],
      "The garden was cut down a bit!" => [:CUT, :XSCISSOR, :BREAKINGSWIPE],
      "The garden grew a little!" => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :GRASSYTERRAIN, :WATERSPORT, :BLOOMDOOM],
      "The acid melted the bloom!" => [:ACIDDOWNPOUR],
    },
    :statusBuffs => [:GROWTH, :ROTOTILLER, :RAINDANCE, :WATERSPORT, :SUNNYDAY, :FLOWERSHIELD, :SWEETSCENT, :INGRAIN, :FLORALHEALING],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :FLOWERGARDEN4 => {
    :name => "Flower Garden",
    :fieldAppSwitch => 2033,
    :fieldMessage => "Seeds line the field.",
    :graphic => ["FlowerGarden3"],
    :secretPower => :PETALBLIZZARD,
    :naturePower => :GROWTH,
    :mimicry => :GRASS,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:CUT, :PETALBLIZZARD, :PETALDANCE, :FLEURCANNON, :SPRINGTIDESTORM, :FLOWERTRICK],
    },
    :accuracyMods => {
      85 => [:SLEEPPOWDER, :STUNSPORE, :POISONPOWDER],
    },
    :moveMessages => {
      "{1} was cut down to size!" => [:CUT],
      "The vibrant scent of flowers boosted the attack!" => [:PETALBLIZZARD, :PETALDANCE, :FLEURCANNON, :SPRINGTIDESTORM, :FLOWERTRICK],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      2.0 => [:BUG],
      1.5 => [:FIRE, :GRASS],
    },
    :typeMessages => {
      "The blooming flowers boosted the attack!" => [:GRASS],
      "The attack infested the flowers!" => [:BUG],
      "The nearby flowers caught flame!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :FLOWERGARDEN5 => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :GRASSYTERRAIN, :WATERSPORT, :BLOOMDOOM],
      :FLOWERGARDEN3 => [:CUT, :XSCISSOR, :BREAKINGSWIPE],
      :FLOWERGARDEN1 => [:ACIDDOWNPOUR],
      :FLOWERGARDEN2 => [*(PBFields::IGNITEMOVES - [:INCINERATE])],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The garden caught fire!" => [*(PBFields::IGNITEMOVES - [:INCINERATE])],
      "The garden was cut down a bit!" => [:CUT, :XSCISSOR, :BREAKINGSWIPE],
      "The garden grew a little!" => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :GRASSYTERRAIN, :WATERSPORT, :BLOOMDOOM],
      "The acid melted the bloom!" => [:ACIDDOWNPOUR],
    },
    :statusBuffs => [:GROWTH, :ROTOTILLER, :RAINDANCE, :WATERSPORT, :SUNNYDAY, :FLOWERSHIELD, :SWEETSCENT, :INGRAIN, :FLORALHEALING],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :FLOWERGARDEN5 => {
    :name => "Flower Garden",
    :fieldAppSwitch => 2033,
    :fieldMessage => "Seeds line the field.",
    :graphic => ["FlowerGarden4"],
    :secretPower => :PETALDANCE,
    :naturePower => :PETALBLIZZARD,
    :mimicry => :GRASS,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:CUT, :PETALBLIZZARD, :PETALDANCE, :FLEURCANNON, :SPRINGTIDESTORM, :FLOWERTRICK],
    },
    :accuracyMods => {
      85 => [:SLEEPPOWDER, :STUNSPORE, :POISONPOWDER],
    },
    :moveMessages => {
      "{1} was cut down to size!" => [:CUT],
      "The vibrant scent of flowers boosted the attack!" => [:PETALBLIZZARD, :PETALDANCE, :FLEURCANNON, :SPRINGTIDESTORM, :FLOWERTRICK],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      2.0 => [:GRASS, :BUG],
      1.5 => [:FIRE],
    },
    :typeMessages => {
      "The thriving flowers boosted the attack!" => [:GRASS],
      "The attack infested the flowers!" => [:BUG],
      "The nearby flowers caught flame!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :FLOWERGARDEN4 => [:CUT, :XSCISSOR, :BREAKINGSWIPE],
      :FLOWERGARDEN1 => [:ACIDDOWNPOUR],
      :FLOWERGARDEN3 => [*(PBFields::IGNITEMOVES - [:INCINERATE])],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The garden caught fire!" => [*(PBFields::IGNITEMOVES - [:INCINERATE])],
      "The garden was cut down a bit!" => [:CUT, :XSCISSOR, :BREAKINGSWIPE],
      "The acid melted the bloom!" => [:ACIDDOWNPOUR],
    },
    :statusBuffs => [:GROWTH, :ROTOTILLER, :RAINDANCE, :WATERSPORT, :SUNNYDAY, :FLOWERSHIELD, :SWEETSCENT, :INGRAIN, :FLORALHEALING, :powdermove],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },

  :STARLIGHT => {
    :name => "Starlight Arena",
    :fieldAppSwitch => 2034,
    :fieldMessage => "Starlight fills the battlefield.",
    :graphic => ["Starlight", "Starlight1"],
    :secretPower => :SWIFT,
    :naturePower => :MOONBLAST,
    :mimicry => :DARK,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :MIRRORBEAM, :TECHNOBLAST,
              :SOLARBEAM, :PHOTONGEYSER, :MOONBLAST, :PRISMATICLASER, :NIGHTSLASH, :NIGHTDAZE, :LUMINACRASH, :BLOODMOON],
      2.0 => [:DRACOMETEOR, :METEORMASH, :COMETPUNCH, :SPACIALREND, :SWIFT, :HYPERSPACEHOLE, :HYPERSPACEFURY,
              :MOONGEISTBEAM, :SUNSTEELSTRIKE, :METEORASSAULT, :BLACKHOLEECLIPSE, :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM, :LIGHTTHATBURNSTHESKY, :METEORBEAM, :TACHYONCUTTER, :TERASTARSTORM],
      4.0 => [:DOOMDESIRE, :DOOMDUMMY],
    },
    :accuracyMods => {},
    :moveMessages => {
      "Starlight surged through the attack!" => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :MIRRORBEAM, :TECHNOBLAST, :SOLARBEAM, :PHOTONGEYSER, :PRISMATICLASER, :LIGHTTHATBURNSTHESKY, :LUMINACRASH],
      "Lunar energy surged through the attack!" => [:MOONBLAST, :NIGHTSLASH, :NIGHTDAZE, :BLOODMOON],
      "The astral energy boosted the attack!" => [
        :DRACOMETEOR, :METEORMASH, :COMETPUNCH, :SPACIALREND, :SWIFT, :HYPERSPACEFURY, :MOONGEISTBEAM, :SUNSTEELSTRIKE, :METEORASSAULT, :BLACKHOLEECLIPSE, :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM, :METEORBEAM, :TERASTARSTORM, :TACHYONCUTTER
      ],
      "The astral vortex accelerated the attack!" => [:HYPERSPACEHOLE],
      "A star came crashing down!" => [:DOOMDUMMY],
    },
    :typeMods => {
      :FIRE => [:DOOMDUMMY],
      :FAIRY => [:SOLARBEAM, :SOLARBLADE],
    },
    :typeAddOns => {
      :FAIRY => [:DARK],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:DARK, :PSYCHIC],
      1.3 => [:FAIRY],
    },
    :typeMessages => {
      "Starlight supercharged the attack!" => [:FAIRY],
      "The night sky boosted the attack!" => [:DARK],
      "The astral energy boosted the attack!" => [:PSYCHIC],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [:LIGHTTHATBURNSTHESKY],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The cosmic light was consumed!" => [:LIGHTTHATBURNSTHESKY],
    },
    :statusBuffs => [:AURORAVEIL, :COSMICPOWER, :FLASH, :WISH, :HEALINGWISH, :LUNARDANCE, :MOONLIGHT, :TRICKROOM, :MAGICROOM, :WONDERROOM, :LUNARBLESSING],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },

  :NEWWORLD => {
    :name => "New World",
    :fieldAppSwitch => 2035,
    :fieldMessage => "From darkness, from stardust|,\n\nFrom memories of eons past and visions yet to come...",
    :graphic => ["NewWorld"],
    :secretPower => :ROAROFTIME,
    :naturePower => :SPACIALREND,
    :mimicry => :DARK,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :DAZZLINGGLEAM, :MIRRORSHOT, :MIRRORBEAM, :PHOTONGEYSER, :PSYSTRIKE,
              :AEROBLAST, :SACREDFIRE, :MISTBALL, :LUSTERPURGE, :ORIGINPULSE, :PRECIPICEBLADES, :DRAGONASCENT, :PSYCHOBOOST,
              :ROAROFTIME, :MAGMASTORM, :CRUSHGRIP, :JUDGMENT, :SEEDFLARE, :SHADOWFORCE, :SEARINGSHOT, :VCREATE, :SECRETSWORD,
              :SACREDSWORD, :RELICSONG, :FUSIONBOLT, :FUSIONFLARE, :GLACIATE, :ICEBURN, :FREEZESHOCK, :BOLTSTRIKE, :BLUEFLARE,
              :GLACIATE, :TECHNOBLAST, :OBLIVIONWING, :LANDSWRATH, :THOUSANDARROWS, :THOUSANDWAVES, :DIAMONDSTORM, :STEAMERUPTION,
              :COREENFORCER, :FLEURCANNON, :PRISMATICLASER, :SUNSTEELSTRIKE, :SPECTRALTHIEF, :MOONGEISTBEAM, :MULTIATTACK,
              :MINDBLOWN, :PLASMAFISTS, :EARTHPOWER, :POWERGEM, :ERUPTION, :CONTINENTALCRUSH, :GENESISSUPERNOVA, :SOULSTEALING7STARSTRIKE,
              :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM, :DOUBLEIRONBASH, :DYNAMAXCANNON, :BEHEMOTHBLADE, :BEHEMOTHBASH,
              :WICKEDBLOW, :SURGINGSTRIKES, :THUNDERCAGE, :DRAGONENERGY, :FREEZINGGLARE, :FIERYWRATH, :THUNDEROUSKICK,
              :GLACIALLANCE, :ASTRALBARRAGE,:SPRINGTIDESTORM, :WILDBOLTSTORM, :BLEAKWINDSTORM, :SANDSEARSTORM, :MYSTICALPOWER,
              :LUMINACRASH, :COLLISIONCOURSE, :ELECTRODRIFT, :HYDROSTEAM, :THUNDERCLAP, :PSYBLADE, :MIGHTYCLEAVE, :IVYCUDGEL,
              :MALIGNANTCHAIN],
      2.0 => [:VACUUMWAVE, :DRACOMETEOR, :METEORMASH, :MOONBLAST, :COMETPUNCH, :SWIFT, :HYPERSPACEHOLE, :SPACIALREND,
              :HYPERSPACEFURY, :ANCIENTPOWER, :FUTURESIGHT, :FUTUREDUMMY, :BLACKHOLEECLIPSE, :LIGHTTHATBURNSTHESKY, :ETERNABEAM, :METEORBEAM, :BLOODMOON, :TERASTARSTORM, :TACHYONCUTTER],
      4.0 => [:DOOMDESIRE, :DOOMDUMMY],
      0.25 => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
      0 => [:FISSURE],
    },
    :accuracyMods => {
      100 => [:DARKVOID],
    },
    :moveMessages => {
      "The light shone through the infinite darkness!" => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :DAZZLINGGLEAM, :MIRRORSHOT, :MIRRORBEAM, :PHOTONGEYSER, :LIGHTTHATBURNSTHESKY],
      "The ethereal energy strengthened the attack!" => [
        :PSYSTRIKE, :AEROBLAST, :SACREDFIRE, :MISTBALL, :LUSTERPURGE, :ORIGINPULSE, :PRECIPICEBLADES, :DRAGONASCENT, :PSYCHOBOOST, :ROAROFTIME, :MAGMASTORM, :CRUSHGRIP, :JUDGMENT,
        :SEEDFLARE, :SHADOWFORCE, :SEARINGSHOT, :VCREATE, :SECRETSWORD, :SACREDSWORD, :RELICSONG, :FUSIONBOLT, :FUSIONFLARE, :GLACIATE, :ICEBURN, :FREEZESHOCK, :BOLTSTRIKE, :BLUEFLARE,
        :GLACIATE, :TECHNOBLAST, :OBLIVIONWING, :LANDSWRATH, :THOUSANDARROWS, :THOUSANDWAVES, :DIAMONDSTORM, :STEAMERUPTION, :COREENFORCER, :FLEURCANNON, :PRISMATICLASER, :SUNSTEELSTRIKE,
        :SPECTRALTHIEF, :MOONGEISTBEAM, :MULTIATTACK, :MINDBLOWN, :PLASMAFISTS, :GENESISSUPERNOVA, :SOULSTEALING7STARSTRIKE, :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM,
        :DOUBLEIRONBASH, :DYNAMAXCANNON, :BEHEMOTHBLADE, :BEHEMOTHBASH,
        :WICKEDBLOW, :SURGINGSTRIKES, :THUNDERCAGE, :DRAGONENERGY, :FREEZINGGLARE, :FIERYWRATH, :THUNDEROUSKICK,
        :GLACIALLANCE, :ASTRALBARRAGE,:SPRINGTIDESTORM, :WILDBOLTSTORM, :BLEAKWINDSTORM, :SANDSEARSTORM, :MYSTICALPOWER,
        :LUMINACRASH, :COLLISIONCOURSE, :ELECTRODRIFT, :HYDROSTEAM, :THUNDERCLAP, :PSYBLADE, :MIGHTYCLEAVE, :IVYCUDGEL,
      ],
      "The germinal matter amassed in the attack!" => [:EARTHPOWER, :POWERGEM, :ERUPTION, :CONTINENTALCRUSH],
      "The astral energy boosted the attack!" => [:VACUUMWAVE, :DRACOMETEOR, :METEORMASH, :MOONBLAST, :COMETPUNCH, :SWIFT, :HYPERSPACEHOLE, :SPACIALREND, :HYPERSPACEFURY, :ANCIENTPOWER, :FUTUREDUMMY, :ETERNABEAM, :METEORBEAM, :BLOODMOON, :TERASTARSTORM, :TACHYONCUTTER],
      "A star came crashing down on {1}!" => [:DOOMDUMMY],
      "{1} was swallowed up by the void!" => [:BLACKHOLEECLIPSE],
      "The unformed land diffused the attack..." => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE, :FISSURE],
    },
    :typeMods => {
      :FIRE => [:DOOMDUMMY],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:DARK],
    },
    :typeMessages => {
      "Infinity boosted the attack!" => [:DARK],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :STARLIGHT => [:GEOMANCY, :TERASTARSTORM],
    },
    :dontChangeBackup => [:TERASTARSTORM],
    :changeMessage => {
      "The world was regenerated!" => [:GEOMANCY],
      "Starlight amassed into a solid surface!" => [:TERASTARSTORM]
    },
    :statusBuffs => [:DARKVOID, :HEARTSWAP, :TRICKROOM, :MAGICROOM, :WONDERROOM, :COSMICPOWER, :FLASH, :MOONLIGHT, :LUNARDANCE, :NATURESMADNESS, :LUNARBLESSING, :GUARDIANOFALOLA, :JUNGLEHEALING, :TAKEHEART, :RUINATION],
    :statusNerfs => [*PBStuff::WEATHERMOVE, *PBStuff::TERRAINMOVE],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :HyperBeam,
      :duration => 1,
      :message => "{1} must recharge!",
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::DEFENSE => 1,
        PBStats::SPATK => 1,
        PBStats::SPDEF => 1,
        PBStats::SPEED => 1,
      },
    },
  },

  :INVERSE => {
    :name => "Inverse Field",
    :fieldAppSwitch => 2036,
    :fieldMessage => "!trats elttaB",
    :graphic => ["Inverse"],
    :secretPower => :CONFUSION,
    :naturePower => :TRICKROOM,
    :mimicry => :NORMAL,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {},
    :accuracyMods => {},
    :moveMessages => {},
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => nil,
      :duration => 0,
      :message => "{1} was normalized!",
      :animation => :SHARPEN,
      :stats => {},
    },
  },

  :PSYTERRAIN => {
    :name => "Psychic Terrain",
    :fieldAppSwitch => 2037,
    :fieldMessage => "The field became mysterious!",
    :graphic => ["Psychic", "Psychic_2"],
    :secretPower => :PSYCHIC,
    :naturePower => :PSYCHIC,
    :mimicry => :PSYCHIC,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:SECRETPOWER, :HIDDENPOWER, :HEX, :MAGICALLEAF, :MYSTICALFIRE, :MOONBLAST, :AURASPHERE, :FOCUSBLAST,
              :MINDBLOWN],
    },
    :accuracyMods => {
      90 => [:HYPNOSIS],
    },
    :moveMessages => {
      "The psychic energy strengthened the attack!" => [
        :SECRETPOWER, :HIDDENPOWER, :HEX, :MAGICALLEAF, :MYSTICALFIRE, :MOONBLAST, :AURASPHERE, :FOCUSBLAST, :MINDBLOWN
      ],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:PSYCHIC],
    },
    :typeMessages => {
      "The Psychic Terrain strengthened the attack!" => [:PSYCHIC],
    },
    :typeCondition => {
      :PSYCHIC => "!attacker.isAirborne?(celestialIdolPsychicTerrain: true)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:CALMMIND, :COSMICPOWER, :KINESIS, :MEDITATE, :NASTYPLOT, :HYPNOSIS, :PSYCHUP, :MINDREADER, :MIRACLEEYE, :TELEKINESIS, :GRAVITY, :MAGICROOM, :TRICKROOM, :WONDERROOM, :MYSTICALPOWER, :EXPANDINGFORCE],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPATK => 2,
      },
    },
    :overlay => {
      :damageMods => {
        1.5 => [:SECRETPOWER, :HIDDENPOWER, :HEX, :MAGICALLEAF, :MYSTICALFIRE, :MOONBLAST, :AURASPHERE, :FOCUSBLAST, :MINDBLOWN],
      },
      :typeMods => {},
      :moveMessages => {
        "The psychic energy strengthened the attack!" => [:SECRETPOWER, :HIDDENPOWER, :HEX, :MAGICALLEAF, :MYSTICALFIRE, :MOONBLAST, :AURASPHERE, :FOCUSBLAST, :MINDBLOWN],
      },
      :typeBoosts => {
        1.3 => [:PSYCHIC],
      },
      :typeMessages => {
        "The Psychic Terrain strengthened the attack!" => [:PSYCHIC],
      },
      :typeCondition => {
        :PSYCHIC => "!attacker.isAirborne?",
      },
      :statusBuffs => [:EXPANDINGFORCE],
      :statusNerfs => [],
    },
  },

  :DIMENSIONAL => {
    :name => "Dimensional Field",
    :fieldAppSwitch => 2038,
    :fieldMessage => "Darkness radiates.",
    :graphic => ["Dimensional", "Dimensional1", "AelitaRift", "DimensionalGard"],
    :secretPower => :DARKPULSE,
    :naturePower => :DARKPULSE,
    :mimicry => :DARK,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      2.0 => [:BLACKHOLEECLIPSE],
      1.5 => [:HYPERSPACEFURY, :HYPERSPACEHOLE, :SPACIALREND, :ROAROFTIME, :ETERNABEAM, :DYNAMAXCANNON, :SHADOWFORCE, :BITTERBLADE,
              :OUTRAGE, :THRASH, :STOMPINGTANTRUM, :LASHOUT, :FREEZINGGLARE, :FIERYWRATH, :RAGINGFURY, :BITTERMALICE, :TEMPERFLARE, :THUNDEROUSKICK],
      1.2 => [:DARKPULSE, :NIGHTDAZE],
      0 => [:TEATIME, :LUCKYCHANT],
    },
    :accuracyMods => {
      0 => [:DARKVOID, :DARKPULSE, :NIGHTDAZE],
    },
    :moveMessages => {
      "The attack has been corrupted!" => [:HYPERSPACEFURY, :HYPERSPACEHOLE, :SPACIALREND, :ROAROFTIME, :ETERNABEAM, :DYNAMAXCANNON, :SHADOWFORCE, :DARKPULSE, :NIGHTDAZE],
      "The rage continues!" => [:OUTRAGE, :THRASH, :STOMPINGTANTRUM, :LASHOUT, :FREEZINGGLARE, :FIERYWRATH, :RAGINGFURY, :THUNDEROUSKICK, :BITTERBLADE, :BITTERMALICE],
      "But it failed." => [:TEATIME, :LUCKYCHANT],
    },
    :typeMods => {},
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1, 2, "A frightening chill goes down your spine..."] => [:BLIZZARD, :SHEERCOLD, :COLDTRUTH],
      [1, 2, 2, nil] => [:ICEBURN, :FREEZESHOCK, :GLACIATE],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:DARK, :SHADOW],
      1.3 => [:GHOST],
      0.5 => [:FAIRY],
    },
    :typeMessages => {
      "The darkness is here!" => [:DARK],
      "The shadow is strengthened!" => [:SHADOW],
      "The evil aura powered up the attack!" => [:GHOST],
      "The evil aura depleted the attack!" => [:FAIRY],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :FROZENDIMENSION => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :FROZENDIMENSION => [:BLIZZARD, :SHEERCOLD, :ICEBURN, :FREEZESHOCK, :GLACIATE, :COLDTRUTH],
      :INFERNAL => [:PRECIPICEBLADES],
      :INDOOR => [:PURIFY, :SEEDFLARE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The dimension froze up!" => [:BLIZZARD, :SHEERCOLD, :ICEBURN, :FREEZESHOCK, :GLACIATE, :COLDTRUTH],
      "The field went up in flames!" => [:PRECIPICEBLADES],
      "The dimension was purified!" => [:PURIFY, :SEEDFLARE],
    },
    :statusBuffs => [:OBSTRUCT, :QUASH, :EMBARGO, :HEALBLOCK, :DARKVOID],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => nil,
      :duration => nil,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::DEFENSE => 1,
      },
    },
  },

  :FROZENDIMENSION => {
    :name => "Frozen Dimensional Field",
    :fieldAppSwitch => 2039,
    :fieldMessage => "Hate and anger radiates.",
    :graphic => ["Angie","Angie_1"],
    :secretPower => :ICEBEAM,
    :naturePower => :ICEBEAM,
    :mimicry => :ICE,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:RAGINGFURY, :THRASH, :OUTRAGE, :STOMPINGTANTRUM, :RAGE, :LASHOUT, :FREEZINGGLARE, :FIERYWRATH,
              :ROAROFTIME, :BITTERMALICE, :BLACKHOLEECLIPSE, :BITTERBLADE, :BITTERMALICE],
      1.2 => [:SURF, :MUDDYWATER, :WATERPULSE, :HYDROPUMP, :NIGHTSLASH, :DARKPULSE, :HYPERSPACEFURY, :HYPERSPACEHOLE],
      0 => [:MAGICROOM, :WONDERROOM, :TRICKROOM, :GRAVITY, :COURTCHANGE, :TEATIME, :ELECTRICTERRAIN, :GRASSYTERRAIN,
            :PSYCHICTERRAIN, :MISTYTERRAIN],
    },
    :accuracyMods => {
      100 => [:DARKVOID],
    },
    :moveMessages => {
      "The rage continues." => [:RAGINGFURY, :THRASH, :OUTRAGE, :STOMPINGTANTRUM, :RAGE, :LASHOUT, :FREEZINGGLARE, :FIERYWRATH, :ROAROFTIME],
      "The ice warped the attack." => [:SURF, :MUDDYWATER, :WATERPULSE, :HYDROPUMP, :NIGHTSLASH, :DARKPULSE, :HYPERSPACEFURY, :HYPERSPACEHOLE, :BITTERBLADE, :BITTERMALICE],
      "The frozen dimension remains unchanged." => [:MAGICROOM, :WONDERROOM, :TRICKROOM, :GRAVITY, :COURTCHANGE, :ELECTRICTERRAIN, :GRASSYTERRAIN, :PSYCHICTERRAIN, :MISTYTERRAIN],
      "But it failed." => [:TEATIME],
    },
    :typeMods => {
      :ICE => [:SURF, :MUDDYWATER, :WATERPULSE, :HYDROPUMP, :NIGHTSLASH, :DARKPULSE, :BITTERBLADE, :BITTERMALICE],
    },
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1, 2, "The corrupted ice is starting to thaw..."] => [:HEATWAVE, :SEARINGSHOT, :FLAMEBURST,:FIREPLEDGE, :MINDBLOWN, :INCINERATE, :BURNINGJEALOUSY, :RAGINGFURY],
      [1, 2, 2, nil] => [:INFERNOOVERDRIVE, :ERUPTION, :LAVAPLUME],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:DARK, :ICE],
      1.3 => [:GHOST],
    },
    :typeMessages => {
      "The darkness is here!" => [:DARK],
      "The dimension mutated the ice!" => [:ICE],
      "The evil aura powered up the attack!" => [:GHOST],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :DIMENSIONAL => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :DIMENSIONAL => [*PBFields::IGNITEMOVES, :RAGINGFURY],
      :ICY => [:PURIFY],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The dimension thawed away!" => [*PBFields::IGNITEMOVES, :RAGINGFURY],
      "The dimension was purified!" => [:PURIFY],
    },
    :statusBuffs => [:PARTINGSHOT, :AURORAVEIL, :DARKVOID, :HAIL, :SNOWSCAPE, :CHILLYRECEPTION],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :Torment,
      :duration => true,
      :message => "{1} is subjected to torment!",
      :animation => :TORMENT,
      :stats => {
        PBStats::SPEED => 2,
      },
    },
  },

  :HAUNTED => {
    :name => "Haunted Field",
    :fieldAppSwitch => 2040,
    :fieldMessage => "The field is haunted!",
    :graphic => ["Haunted", "Haunted2", "Haunted3"],
    :secretPower => :SHADOWCLAW,
    :naturePower => :PHANTOMFORCE,
    :mimicry => :GHOST,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:FLAMEBURST, :INFERNO, :FLAMECHARGE, :FIRESPIN, :BURNINGJEALOUSY, :TORCHSONG, :BITTERBLADE, :BONECLUB, :BONERUSH, :BONEMERANG, :ASTONISH],
      1.2 => [:SHADOWBONE],
    },
    :accuracyMods => {
      90 => [:WILLOWISP, :HYPNOSIS],
    },
    :moveMessages => {
      "Will-o'-wisps joined the attack!" => [:FLAMEBURST, :INFERNO, :FLAMECHARGE, :FIRESPIN, :BURNINGJEALOUSY, :BITTERBLADE],
      "A dirge for the dead..." => [:TORCHSONG],
      "Spooky scary skeletons!" => [:BONECLUB, :BONERUSH, :BONEMERANG, :SHADOWBONE],
      "Boo!" => [:ASTONISH],
    },
    :typeMods => {
      :GHOST => [:FLAMEBURST, :INFERNO, :FLAMECHARGE, :FIRESPIN],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:GHOST],
    },
    :typeMessages => {
      "The evil aura powered up the attack!" => [:GHOST],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :HOLY => [:JUDGMENT, :ORIGINPULSE, :SACREDFIRE, :PURIFY],
      :INDOOR => [:FLASH, :DAZZLINGGLEAM],
    },
    :dontChangeBackup => [:FLASH, :DAZZLINGGLEAM],
    :changeMessage => {
      "The evil spirits have been exorcised!" => [:JUDGMENT, :ORIGINPULSE, :PURIFY, :SACREDFIRE],
      "The evil spirits have been forced back!" => [:FLASH, :DAZZLINGGLEAM],
    },
    :statusBuffs => [:NIGHTMARE, :SPITE, :CURSE, :DESTINYBOND, :MEANLOOK, :SCARYFACE, :MAGICPOWDER, :HYPNOSIS, :WILLOWISP],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => nil,
      :duration => nil,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::DEFENSE => 1,
        PBStats::SPDEF => 1,
      },
    },
  },

  :CORRUPTED => {
    :name => "Corrupted Cave",
    :fieldAppSwitch => 2041,
    :fieldMessage => "Corruption seeps from every| crevice!",
    :graphic => ["Corrupted"],
    :secretPower => :POISONJAB,
    :naturePower => :GUNKSHOT,
    :mimicry => :POISON,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:SEEDFLARE, :APPLEACID],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The move absorbed the filth!" => [:SEEDFLARE],
      "Chemicals got mixed in!" => [:APPLEACID],
    },
    :typeMods => {
      :POISON => [:ROCKSLIDE, :SMACKDOWN, :STONEEDGE, :ROCKTOMB, :DIAMONDSTORM],
      :ROCK => [:SLUDGEWAVE, :GUNKSHOT],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:POISON],
      1.2 => [:ROCK, :GRASS],
      0.5 => [:FAIRY, :FLYING],
    },
    :typeMessages => {
      "The chemicals strengthened the attack." => [:POISON],
      "The corruption morphed the attack!" => [:ROCK, :GRASS],
      "The corruption weakened the attack." => [:FAIRY],
      "The cave choked out the air!" => [:FLYING],
    },
    :typeCondition => {
      :FLYING => "!attacker.makesContact?(self)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :CAVE => [:SOLARBEAM, :SOLARBLADE, :PURIFY, :SEEDFLARE],
      :VOLCANIC => [:HEATWAVE, :ERUPTION, :LAVAPLUME, :BLASTBURN, :INFERNOOVERDRIVE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The cave was purified!" => [:SOLARBEAM, :SOLARBLADE, :PURIFY, :SEEDFLARE],
      "The cave's corruption combusted!" => [:HEATWAVE, :ERUPTION, :LAVAPLUME, :BLASTBURN, :INFERNOOVERDRIVE],
    },
    :statusBuffs => [:NIGHTMARE, :SPITE, :CURSE, :DESTINYBOND, :MEANLOOK, :SCARYFACE, :MAGICPOWDER, :HYPNOSIS, :WILLOWISP],
    :statusNerfs => [],
    :changeEffects => {
      "@battle.mistExplosion(basemove, user)" => [:HEATWAVE, :ERUPTION, :LAVAPLUME, :BLASTBURN, :INFERNOOVERDRIVE],
    },
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => nil,
      :duration => nil,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::DEFENSE => 2,
      },
    },
  },

  :BEWITCHED => {
    :name => "Bewitched Woods",
    :fieldAppSwitch => 2042,
    :fieldMessage => "Everlasting glow and glamour!",
    :graphic => ["Darchlight", "Darchlight_1"],
    :secretPower => :NEEDLEARM,
    :naturePower => :DAZZLINGGLEAM,
    :mimicry => :FAIRY,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:HEX, :MYSTICALFIRE, :SPIRITBREAK],
      1.4 => [:ICEBEAM, :HYPERBEAM, :SIGNALBEAM, :AURORABEAM, :CHARGEBEAM, :PSYBEAM, :FLASHCANNON, :MIRRORBEAM,
              :MAGICALLEAF, :BUBBLEBEAM],
      1.2 => [:DARKPULSE, :NIGHTDAZE, :MOONBLAST, :VORPALBLADE],
    },
    :accuracyMods => {
      85 => [:SLEEPPOWDER, :POISONPOWDER, :STUNSPORE, :GRASSWHISTLE],
    },
    :moveMessages => {
      "Magic aura amplified the attack!" => [:HEX, :MYSTICALFIRE, :SPIRITBREAK, :ICEBEAM, :HYPERBEAM, :SIGNALBEAM, :AURORABEAM, :CHARGEBEAM, :PSYBEAM, :FLASHCANNON, :MIRRORBEAM, :MAGICALLEAF, :BUBBLEBEAM],
      "The forest is cursed with nightfall!" => [:DARKPULSE, :NIGHTDAZE, :MOONBLAST],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FAIRY, :GRASS],
      1.3 => [:DARK],
    },
    :typeMessages => {
      "The fairy aura amplified the attack's power!" => [:FAIRY],
      "Flourish!" => [:GRASS],
      "The dark aura amplified the attack's power!" => [:DARK],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :FOREST => [:PURIFY],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The evil spirits have been exorcised!" => [:PURIFY],
    },
    :statusBuffs => [:STRENGTHSAP, :FORESTSCURSE, :MAGICPOWDER, :MOONLIGHT, :SLEEPPOWDER, :POISONPOWDER, :STUNSPORE, :GRASSWHISTLE],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots.",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },

  :SKY => {
    :name => "Sky Field",
    :fieldAppSwitch => 2043,
    :fieldMessage => "The sky is filled with clouds.",
    :graphic => ["GoldenArena"],
    :secretPower => :WINGATTACK,
    :naturePower => :SKYATTACK,
    :mimicry => :FLYING,
    :burmyCloak => :PLANTCLOAK,
    :damageMods => {
      1.5 => [:ICYWIND, :SILVERWIND, :OMINOUSWIND, :FAIRYWIND, :AEROBLAST, :FLYINGPRESS, :SKYUPPERCUT, :THUNDERSHOCK,
              :THUNDERBOLT, :STEELWING, :DRAGONDARTS, :GRAVAPPLE, :DRAGONASCENT, :THUNDER, :TWISTER, :RAZORWIND, :DIVE, :ESPERWING, :BLEAKWINDSTORM],
      1.3 => [:SPRINGTIDESTORM, :WILDBOLTSTORM, :SANDSEARSTORM],
      0 => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE, :DIG, :ROTOTILLER, :SPIKES, :TOXICSPIKES, :STICKYWEB]
    },
    :accuracyMods => {
      0 => [:THUNDER, :HURRICANE]
    },
    :moveMessages => {
      "The open skies strengthened the attack!" => [
        :ICYWIND, :SILVERWIND, :OMINOUSWIND, :FAIRYWIND, :AEROBLAST, :FLYINGPRESS, :SKYUPPERCUT, :THUNDERSHOCK, :THUNDERBOLT, :STEELWING, :DRAGONDARTS, :GRAVAPPLE, :DRAGONASCENT, :THUNDER,
        :TWISTER, :RAZORWIND, :DIVE, :ESPERWING, :SPRINGTIDESTORM, :WILDBOLTSTORM, :SANDSEARSTORM, :BLEAKWINDSTORM
      ],
      "But there is no solid ground!" => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE, :DIG, :ROTOTILLER, :SPIKES, :TOXICSPIKES, :STICKYWEB]
    },
    :typeMods => {
      :FLYING => [:DIVE, :TWISTER],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FLYING],
    },
    :typeMessages => {
      "The open air strengthened the attack!" => [:FLYING],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :MOUNTAIN => [:GRAVITY, :INGRAIN, :THOUSANDARROWS, :SMACKDOWN, :GRAVAPPLE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The battle has been brought down to the mountains!" => [:GRAVITY, :INGRAIN, :THOUSANDARROWS, :SMACKDOWN, :GRAVAPPLE],
    },
    :statusBuffs => [:MIRRORMOVE, :TAILWIND, :SUNNYDAY, :HAIL, :SNOWSCAPE, :CHILLYRECEPTION, :SANDSTORM, :RAINDANCE],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::DEFENSE => 1,
        PBStats::SPDEF => 1,
      },
    },
  },

  :COLOSSEUM => {
    :name => "Colosseum",
    :fieldAppSwitch => 2044,
    :fieldMessage => "All eyes are on the combatants!",
    :graphic => ["Colosseum","Colosseum_1"],
    :secretPower => :POWERUPPUNCH,
    :naturePower => :BEATUP,
    :mimicry => :STEEL,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      2.0 => [:BEATUP, :FELLSTINGER, :PAYDAY, :REVERSAL, :PURSUIT],
      1.5 => [:SACREDSWORD, :SECRETSWORD, :SUBMISSION, :METEORASSAULT, :SMARTSTRIKE, :SMACKDOWN, :BRUTALSWING, :ELECTROWEB, :CLANGOROUSSOULBLAZE,
              :VINEWHIP, :PSYCHOCUT, :NIGHTSLASH, :BONEMERANG, :FIRSTIMPRESSION, :BONERUSH, :BONECLUB, :LEAFBLADE, :PAYBACK, :PUNISHMENT, :METEORMASH, :BULLETPUNCH, :CLANGINGSCALES, :STEAMROLLER],
      1.2 => [:STORMTHROW, :WOODHAMMER, :DRAGONHAMMER, :POWERWHIP, :SPIRITSHACKLE, :DRILLRUN, :DRILLPECK, :ICEHAMMER,
              :ICICLESPEAR, :ANCHORSHOT, :CRABHAMMER, :SHADOWBONE, :FIRELASH, :SUCKERPUNCH, :THROATCHOP],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The fighters rallied together!" => [:BEATUP],
      "The coup de grâce!" => [:FELLSTINGER],
      "The audience hurled coins down!" => [:PAYDAY],
      "There is no escape!" => [:PURSUIT],
      "For Honor!" => [:REVERSAL, :SACREDSWORD, :SECRETSWORD, :SUBMISSION, :METEORASSAULT, :SMARTSTRIKE, :SMACKDOWN, :BRUTALSWING, :STORMTHROW],
      "For Glory!" => [
        :ELECTROWEB, :VINEWHIP, :PSYCHOCUT, :NIGHTSLASH, :BONEMERANG, :FIRSTIMPRESSION, :BONERUSH, :BONECLUB, :LEAFBLADE, :PAYBACK, :PUNISHMENT, :METEORMASH, :BULLETPUNCH, :CLANGINGSCALES, :STEAMROLLER, :WOODHAMMER,
        :DRAGONHAMMER, :POWERWHIP, :SPIRITSHACKLE, :DRILLRUN, :DRILLPECK, :ICEHAMMER, :ICICLESPEAR, :ANCHORSHOT, :CRABHAMMER, :SHADOWBONE, :FIRELASH, :SUCKERPUNCH, :THROATCHOP
      ],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusBuffs => [:SWORDSDANCE, :KINGSSHIELD, :HOWL, :NORETREAT, :ROAR, :SWAGGER, :FLATTER],
    :statusNerfs => [:WHIRLWIND],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Taunt,
      :duration => 4,
      :message => "{1} feels taunted!",
      :animation => :TAUNT,
      :stats => {
        PBStats::ATTACK => 1,
      },
    },
  },

  :INFERNAL => {
    :name => "Infernal Field",
    :fieldAppSwitch => 2045,
    :fieldMessage => "The souls of the damned burn on...",
    :graphic => ["Infernal"],
    :secretPower => :INFERNO,
    :naturePower => :PUNISHMENT,
    :mimicry => :FIRE,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      2.0 => [:PUNISHMENT, :SMOG, :DREAMEATER],
      1.5 => [:BLASTBURN, :EARTHPOWER, :INFERNOOVERDRIVE, :PRECIPICEBLADES, :INFERNO, :RAGINGFURY, :INFERNALPARADE],
    },
    :accuracyMods => {
      0 => [:WILLOWISP, :DARKVOID, :INFERNO],
    },
    :moveMessages => {
      "Hellish suffering!" => [:PUNISHMENT, :SMOG, :DREAMEATER],
      "Infernal flames strengthened the attack" => [:BLASTBURN, :EARTHPOWER, :INFERNOOVERDRIVE, :PRECIPICEBLADES, :INFERNO, :RAGINGFURY, :INFERNALPARADE],
    },
    :typeMods => {
      :DARK => [:SPIRITBREAK, :AURASPHERE, :FRUSTRATION],
    },
    :typeAddOns => {
      :FIRE => [:GROUND, :STEEL, :ROCK],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FIRE, :DARK],
      0.5 => [:FAIRY, :WATER],
    },
    :typeMessages => {
      "The infernal flames strengthened the attack!" => [:FIRE, :DARK],
      "The hellfire burnt out the attack!" => [:FAIRY, :WATER],
    },
    :typeCondition => {
      :FAIRY => "self.pbIsSpecial?(attacker, type)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :DIMENSIONAL => [:GLACIATE],
      :VOLCANICTOP => [:JUDGMENT, :ORIGINPULSE, :PURIFY],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The hellish landscape was doused of its fire!" => [:GLACIATE],
      "The hellish landscape was purified!" => [:JUDGMENT, :ORIGINPULSE, :PURIFY],
    },
    :statusBuffs => [:WILLOWISP, :DARKVOID, :TORMENT, :NIGHTMARE, :STEALTHROCK],
    :statusNerfs => [:RAINDANCE, :HAIL, :SNOWSCAPE, :CHILLYRECEPTION],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => nil,
      :duration => nil,
      :message => "{1} can't escape now!",
      :animation => :MEANLOOK,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::SPATK => 1,
      },
    },
  },

  :CONCERT1 => {
    :name => "Concert Venue",
    :fieldAppSwitch => 2046,
    :fieldMessage => "Let's get HYPED!",
    :graphic => ["Concert1"],
    :secretPower => :BOOMBURST,
    :naturePower => :HYPERVOICE,
    :mimicry => :NORMAL,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:ACID, :ACIDSPRAY, :DRUMBEATING, :FAKEOUT, :ROLLOUT, :FIRSTIMPRESSION, :DRAGONTAIL, :CIRCLETHROW, :RAGE, :THRASH,
              :FRUSTRATION, :OUTRAGE, :STOMPINGTANTRUM],
    },
    :accuracyMods => {
      100 => [:SING],
    },
    :moveMessages => {
      "Face melting!" => [:ACID, :ACIDSPRAY, :APPLEACID],
      "Rock and roll!" => [:ROLLOUT],
      "An amazing drumsolo!" => [:DRUMBEATING],
      "What an opening act!" => [:FIRSTIMPRESSION, :FAKEOUT],
      "MOSHPIT!!!" => [:DRAGONTAIL, :CIRCLETHROW],
      "The outraged audience is rioting!" => [:RAGE, :THRASH, :FRUSTRATION, :OUTRAGE, :STOMPINGTANTRUM],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:soundmove],
    },
    :typeMessages => {
      "Loud and clear!" => [:soundmove],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :CONCERT2 => [
        :WORKUP, :ROLLOUT, :FIRSTIMPRESSION, :DRUMBEATING, :REVELATIONDANCE, :FIERYDANCE, :PETALDANCE, :DRAGONDANCE, :QUIVERDANCE, :AQUABATICS, :SWORDSDANCE, :FEATHERDANCE, :SWAGGER, :BOOMBURST, :BUGBUZZ, :CHATTER, :DRAGONCHEER,
        :CLANGINGSCALES, :CLANGOROUSSOUL, :CLANGOROUSSOULBLAZE, :DISARMINGVOICE, :ECHOEDVOICE, :GROWL, :HOWL, :HYPERVOICE, :METALSOUND, :NOBLEROAR, :OVERDRIVE, :PARTINGSHOT, :RELICSONG, :ROAR, :ROUND, :SCREECH, :SHADOWPANIC, :SING, :SNARL, :SPARKLINGARIA, :SUPERSONIC, :UPROAR, :FEVERPITCH, :SPECTRALSCREAM
      ],
      :CONCERT3 => [:LASERFOCUS, :LUCKYCHANT, :FOCUSENERGY, :SPOTLIGHT, :FOLLOWME],
      :CONCERT4 => [:SELFDESTRUCT, :EXPLOSION],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The stunning dance makes the audience go wild!" => [:REVELATIONDANCE, :FIERYDANCE, :PETALDANCE, :DRAGONDANCE, :QUIVERDANCE, :AQUABATICS, :SWORDSDANCE, :FEATHERDANCE],
      "The song is getting the audience hyped!" => [
        :BOOMBURST, :BUGBUZZ, :CHATTER, :CLANGINGSCALES, :CLANGOROUSSOUL, :CLANGOROUSSOULBLAZE, :DISARMINGVOICE, :ECHOEDVOICE, :GROWL, :HOWL, :HYPERVOICE, :METALSOUND, :NOBLEROAR, :OVERDRIVE,
        :PARTINGSHOT, :RELICSONG, :ROAR, :ROUND, :SCREECH, :SHADOWPANIC, :SING, :SNARL, :SPARKLINGARIA, :SUPERSONIC, :UPROAR, :FEVERPITCH, :SPECTRALSCREAM, :DRAGONCHEER,
      ],
      "The crowd is getting hyped!" => [:DRUMBEATING, :FIRSTIMPRESSION, :WORKUP, :ROLLOUT, :SWAGGER],
      "The audience's full attention is on the stage!" => [:LASERFOCUS, :LUCKYCHANT, :FOCUSENERGY, :SPOTLIGHT, :FOLLOWME],
      "The audience cheers for the explosive finish!!" => [:SELFDESTRUCT, :EXPLOSION],
    },
    :statusBuffs => [:ACIDARMOR, :WORKUP, :HOWL, :PARTINGSHOT, :METALSOUND, :SCREECH, :GROWL, :CLANGOROUSSOUL, :SING, :ROAR, :ENCORE, :DRAGONCHEER],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => nil,
      :duration => 0,
      :message => "{1} accepts the crowd's help!",
      :animation => :HELPINGHAND,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },
  :CONCERT2 => {
    :name => "Concert Venue",
    :fieldAppSwitch => 2046,
    :fieldMessage => "Let's get HYPED!",
    :graphic => ["Concert2"],
    :secretPower => :BOOMBURST,
    :naturePower => :HYPERVOICE,
    :mimicry => :NORMAL,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:ACID, :ACIDSPRAY, :DRUMBEATING, :FAKEOUT, :ROLLOUT, :FIRSTIMPRESSION, :DRAGONTAIL, :CIRCLETHROW, :RAGE, :THRASH,
              :FRUSTRATION, :OUTRAGE, :STOMPINGTANTRUM],
    },
    :accuracyMods => {
      100 => [:SING],
    },
    :moveMessages => {
      "Face melting!" => [:ACID, :ACIDSPRAY, :APPLEACID],
      "Rock and roll!" => [:ROLLOUT],
      "An amazing drumsolo!" => [:DRUMBEATING],
      "What an opening act!" => [:FIRSTIMPRESSION, :FAKEOUT],
      "MOSHPIT!!!" => [:DRAGONTAIL, :CIRCLETHROW],
      "The outraged Audience is rioting!" => [:RAGE, :THRASH, :FRUSTRATION, :OUTRAGE, :STOMPINGTANTRUM],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:soundmove],
    },
    :typeMessages => {
      "Loud and clear!" => [:soundmove],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :CONCERT1 => "!attacker.missAcc || (basemove.move != :SHEERCOLD && basemove.move != :COLDTRUTH)",
    },
    :fieldChange => {
      :CONCERT1 => [:THROATCHOP, :SHEERCOLD, :COLDTRUTH, :EMBARGO, :QUASH, :SLACKOFF, :YAWN, :PLAYNICE, :BABYDOLLEYES, :TICKLE],
      :CONCERT3 => [
        :WORKUP, :ROLLOUT, :FIRSTIMPRESSION, :DRUMBEATING, :REVELATIONDANCE, :FIERYDANCE, :PETALDANCE, :DRAGONDANCE, :QUIVERDANCE, :AQUABATICS, :SWORDSDANCE, :FEATHERDANCE, :SWAGGER, :BOOMBURST, :BUGBUZZ, :CHATTER, :DRAGONCHEER,
        :CLANGINGSCALES, :CLANGOROUSSOUL, :CLANGOROUSSOULBLAZE, :DISARMINGVOICE, :ECHOEDVOICE, :GROWL, :HOWL, :HYPERVOICE, :METALSOUND, :NOBLEROAR, :OVERDRIVE, :PARTINGSHOT, :RELICSONG, :ROAR, :ROUND, :SCREECH, :SHADOWPANIC, :SING, :SNARL, :SPARKLINGARIA, :SUPERSONIC, :UPROAR, :FEVERPITCH, :SPECTRALSCREAM
      ],
      :CONCERT4 => [:LASERFOCUS, :LUCKYCHANT, :FOCUSENERGY, :SPOTLIGHT, :FOLLOWME, :SELFDESTRUCT, :EXPLOSION],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The freezing cold drives the audience away..." => [:SHEERCOLD],
      "'Bitter cold AND preaching? I am out of here!'" => [:COLDTRUTH],
      "The leadsingers voice fails..." => [:THROATCHOP],
      "The bar is closed and the crowd does NOT like it..." => [:EMBARGO],
      "The crowd is booing, they want action!" => [:QUASH, :SLACKOFF, :YAWN],
      "The audience is not a fan of this friendly touchy-feely stuff..." => [:PLAYNICE, :BABYDOLLEYES, :TICKLE],
      "The stunning dance makes the audience go wild!" => [:REVELATIONDANCE, :FIERYDANCE, :PETALDANCE, :DRAGONDANCE, :QUIVERDANCE, :AQUABATICS, :SWORDSDANCE, :FEATHERDANCE],
      "The song is getting the audience hyped!" => [
        :BOOMBURST, :BUGBUZZ, :CHATTER, :CLANGINGSCALES, :CLANGOROUSSOUL, :CLANGOROUSSOULBLAZE, :DISARMINGVOICE, :ECHOEDVOICE, :GROWL, :HOWL, :HYPERVOICE, :METALSOUND, :NOBLEROAR, :OVERDRIVE,
        :PARTINGSHOT, :RELICSONG, :ROAR, :ROUND, :SCREECH, :SHADOWPANIC, :SING, :SNARL, :SPARKLINGARIA, :SUPERSONIC, :UPROAR, :FEVERPITCH, :SPECTRALSCREAM, :DRAGONCHEER,
      ],
      "The crowd is getting hyped!" => [:DRUMBEATING, :FIRSTIMPRESSION, :WORKUP, :ROLLOUT, :SWAGGER],
      "The audience's full attention is on the stage!" => [:LASERFOCUS, :LUCKYCHANT, :FOCUSENERGY, :SPOTLIGHT, :FOLLOWME],
      "The audience cheers for the explosive finish!!" => [:SELFDESTRUCT, :EXPLOSION],
    },
    :statusBuffs => [:ACIDARMOR, :WORKUP, :HOWL, :PARTINGSHOT, :METALSOUND, :SCREECH, :GROWL, :CLANGOROUSSOUL, :SING, :ROAR, :ENCORE, :DRAGONCHEER],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => nil,
      :duration => 0,
      :message => "{1} accepts the crowd's help!",
      :animation => :HELPINGHAND,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },
  :CONCERT3 => {
    :name => "Concert Venue",
    :fieldAppSwitch => 2046,
    :fieldMessage => "Let's get HYPED!",
    :graphic => ["Concert3"],
    :secretPower => :BOOMBURST,
    :naturePower => :HYPERVOICE,
    :mimicry => :NORMAL,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:ACID, :ACIDSPRAY, :DRUMBEATING, :FAKEOUT, :ROLLOUT, :FIRSTIMPRESSION, :DRAGONTAIL, :CIRCLETHROW],
    },
    :accuracyMods => {
      100 => [:SING],
    },
    :moveMessages => {
      "Face melting!" => [:ACID, :ACIDSPRAY, :APPLEACID],
      "Rock and roll!" => [:ROLLOUT],
      "An amazing drumsolo!" => [:DRUMBEATING],
      "What an opening act!" => [:FIRSTIMPRESSION, :FAKEOUT],
      "MOSHPIT!!!" => [:DRAGONTAIL, :CIRCLETHROW],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:soundmove],
    },
    :typeMessages => {
      "Loud and clear!" => [:soundmove],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :CONCERT1 => "!attacker.missAcc",
    },
    :fieldChange => {
      :CONCERT1 => [:SHEERCOLD, :COLDTRUTH],
      :CONCERT2 => [:THROATCHOP, :EMBARGO, :QUASH, :SLACKOFF, :YAWN, :PLAYNICE, :BABYDOLLEYES, :TICKLE],
      :CONCERT4 => [
        :WORKUP, :ROLLOUT, :FIRSTIMPRESSION, :DRUMBEATING, :REVELATIONDANCE, :FIERYDANCE, :PETALDANCE, :DRAGONDANCE, :QUIVERDANCE, :AQUABATICS, :SWORDSDANCE, :FEATHERDANCE, :SWAGGER, :LASERFOCUS, :LUCKYCHANT, :FOCUSENERGY, :DRAGONCHEER,
        :SPOTLIGHT, :FOLLOWME, :BOOMBURST, :BUGBUZZ, :CHATTER, :CLANGINGSCALES, :CLANGOROUSSOUL, :CLANGOROUSSOULBLAZE, :DISARMINGVOICE, :ECHOEDVOICE, :GROWL, :HOWL, :HYPERVOICE, :METALSOUND, :NOBLEROAR, :OVERDRIVE, :PARTINGSHOT, :RELICSONG, :ROAR, :ROUND, :SCREECH, :SHADOWPANIC, :SING, :SNARL, :SPARKLINGARIA, :SUPERSONIC, :UPROAR, :FEVERPITCH, :SPECTRALSCREAM, :SELFDESTRUCT, :EXPLOSION
      ],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The freezing cold drives the audience away..." => [:SHEERCOLD],
      "'Bitter cold AND preaching? I am out of here!'" => [:COLDTRUTH],
      "The leadsingers voice fails..." => [:THROATCHOP],
      "The bar is closed and the crowd does NOT like it..." => [:EMBARGO],
      "The crowd is booing, they want action!" => [:QUASH, :SLACKOFF, :YAWN],
      "The audience is not a fan of this friendly touchy-feely stuff..." => [:PLAYNICE, :BABYDOLLEYES, :TICKLE],
      "The stunning dance makes the audience go wild!" => [:REVELATIONDANCE, :FIERYDANCE, :PETALDANCE, :DRAGONDANCE, :QUIVERDANCE, :AQUABATICS, :SWORDSDANCE, :FEATHERDANCE],
      "The song is getting the audience hyped!" => [
        :BOOMBURST, :BUGBUZZ, :CHATTER, :CLANGINGSCALES, :CLANGOROUSSOUL, :CLANGOROUSSOULBLAZE, :DISARMINGVOICE, :ECHOEDVOICE, :GROWL, :HOWL, :HYPERVOICE, :METALSOUND, :NOBLEROAR, :OVERDRIVE,
        :PARTINGSHOT, :RELICSONG, :ROAR, :ROUND, :SCREECH, :SHADOWPANIC, :SING, :SNARL, :SPARKLINGARIA, :SUPERSONIC, :UPROAR, :FEVERPITCH, :SPECTRALSCREAM, :DRAGONCHEER
      ],
      "The crowd is getting hyped!" => [:DRUMBEATING, :FIRSTIMPRESSION, :WORKUP, :ROLLOUT, :SWAGGER],
      "The audience's full attention is on the stage!" => [:LASERFOCUS, :LUCKYCHANT, :FOCUSENERGY, :SPOTLIGHT, :FOLLOWME],
      "The audience cheers for the explosive finish!!" => [:SELFDESTRUCT, :EXPLOSION],
    },
    :statusBuffs => [:ACIDARMOR, :WORKUP, :HOWL, :PARTINGSHOT, :METALSOUND, :SCREECH, :GROWL, :CLANGOROUSSOUL, :SING, :ROAR, :ENCORE, :DRAGONCHEER],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => nil,
      :duration => 0,
      :message => "{1} accepts the crowd's help!",
      :animation => :HELPINGHAND,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },
  :CONCERT4 => {
    :name => "Concert Venue",
    :fieldAppSwitch => 2046,
    :fieldMessage => "Let's get HYPED!",
    :graphic => ["Concert4"],
    :secretPower => :BOOMBURST,
    :naturePower => :HYPERVOICE,
    :mimicry => :NORMAL,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:ACID, :ACIDSPRAY, :DRUMBEATING, :FAKEOUT, :ROLLOUT, :FIRSTIMPRESSION, :DRAGONTAIL, :CIRCLETHROW],
    },
    :accuracyMods => {
      100 => [:SING],
    },
    :moveMessages => {
      "Face melting!" => [:ACID, :ACIDSPRAY, :APPLEACID],
      "Rock and roll!" => [:ROLLOUT],
      "An amazing drumsolo!" => [:DRUMBEATING],
      "What an opening act!" => [:FIRSTIMPRESSION, :FAKEOUT],
      "MOSHPIT!!!" => [:DRAGONTAIL, :CIRCLETHROW],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:soundmove],
    },
    :typeMessages => {
      "Loud and clear!" => [:soundmove],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :CONCERT1 => "!attacker.missAcc",
    },
    :fieldChange => {
      :CONCERT1 => [:SHEERCOLD, :COLDTRUTH],
      :CONCERT3 => [:THROATCHOP, :EMBARGO, :QUASH, :SLACKOFF, :YAWN, :PLAYNICE, :BABYDOLLEYES, :TICKLE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The freezing cold drives the audience away..." => [:SHEERCOLD],
      "'Bitter cold AND preaching? I am out of here!'" => [:COLDTRUTH],
      "The leadsingers voice fails..." => [:THROATCHOP],
      "The bar is closed and the crowd does NOT like it..." => [:EMBARGO],
      "The crowd is booing, they want action!" => [:QUASH, :SLACKOFF, :YAWN],
      "The audience is not a fan of this friendly touchy-feely stuff..." => [:PLAYNICE, :BABYDOLLEYES, :TICKLE],
    },
    :statusBuffs => [:ACIDARMOR, :WORKUP, :HOWL, :PARTINGSHOT, :METALSOUND, :SCREECH, :GROWL, :CLANGOROUSSOUL, :SING, :ROAR, :ENCORE, :DRAGONCHEER],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => nil,
      :duration => 0,
      :message => "{1} accepts the crowd's help!",
      :animation => :HELPINGHAND,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },

  :BACKALLEY => {
    :name => "Back Alley",
    :fieldAppSwitch => 2047,
    :fieldMessage => "Shifty eyes are all around...",
    :graphic => ["Under"],
    :secretPower => :SMOG,
    :naturePower => :BEATUP,
    :mimicry => :STEEL,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:STEAMROLLER, :SMOG, :BEATUP, :PAYDAY, :INFESTATION, :SPECTRALTHIEF, :FIRSTIMPRESSION, :TECHNOBLAST, :SHADOWSNEAK,
              :XSCISSOR, :FURYCUTTER, :NIGHTSLASH, :SACREDSWORD, :AIRSLASH, :AERIALACE, :AIRCUTTER, :LEAFBLADE, :RAZORLEAF, :SLASH, :CUT, :CROSSPOISON, :PSYCHOCUT, :RAZORSHELL, :SOLARBLADE, :BEHEMOTHBLADE, :CEASELESSEDGE, :STONEAXE, :AQUACUTTER, :SLASHANDBURN, :HEXINGSLASH,
              :HORNATTACK, :FURYATTACK, :POISONSTING, :TWINEEDLE, :PINMISSILE, :PECK, :DRILLPECK, :MEGAHORN, :POISONJAB, :NEEDLEARM, :PLUCK, :DRILLRUN, :HORNLEECH, :FELLSTINGER, :SMARTSTRIKE, :BRANCHPOKE, :FALSESURRENDER, :GLACIALLANCE, :GILDEDARROW, :GILDEDHELIX, :QUICKSILVERSPEAR,
              :DRAGONCLAW, :DIRECLAW, :SHADOWCLAW, :METALCLAW, :CRUSHCLAW, :RADIANTCLAW,
            ],
    },
    :accuracyMods => {
      0 => [:SMOG, :POISONGAS],
    },
    :moveMessages => {
      "The power of science is amazing!" => [:TECHNOBLAST],
      "A crowd is gathering!" => [:BEATUP],
      "The city smog is suffocating!" => [:SMOG],
      "Careful on the street!" => [:STEAMROLLER],
      "Gotta make ends meet somehow..." => [:PAYDAY, :SPECTRALTHIEF, :SHADOWSNEAK],
      "A frightening first impression!" => [:FIRSTIMPRESSION],
      "A knife glints in the dark!" => [
        :XSCISSOR, :FURYCUTTER, :NIGHTSLASH, :SACREDSWORD, :AIRSLASH, :AERIALACE, :AIRCUTTER, :LEAFBLADE, :RAZORLEAF, :SLASH, :CUT, :CROSSPOISON, :PSYCHOCUT, :RAZORSHELL, :SOLARBLADE, :BEHEMOTHBLADE,
        :CEASELESSEDGE, :STONEAXE, :AQUACUTTER, :SLASHANDBURN, :HEXINGSLASH, :DRAGONCLAW, :DIRECLAW, :SHADOWCLAW, :METALCLAW, :CRUSHCLAW,
      ],
      "Better watch your back..." => [
        :HORNATTACK, :FURYATTACK, :POISONSTING, :TWINEEDLE, :PINMISSILE, :PECK, :DRILLPECK, :MEGAHORN, :POISONJAB, :NEEDLEARM, :PLUCK, :DRILLRUN, :HORNLEECH, :FELLSTINGER, :SMARTSTRIKE, :BRANCHPOKE,
        :FALSESURRENDER, :GLACIALLANCE, :GILDEDARROW, :GILDEDHELIX, :QUICKSILVERSPEAR
      ],
    },
    :typeMods => {
      :DARK => [:FIRSTIMPRESSION],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:DARK],
      1.3 => [:POISON, :BUG, :STEEL],
      0.5 => [:FAIRY],
    },
    :typeMessages => {
      "Street rules!" => [:DARK],
      "The right tool for the job!" => [:STEEL],
      "In the cracks and the walls!" => [:BUG],
      "All kinds of pollution strengthened the attack!" => [:POISON],
      "This is no place for fairytales..." => [:FAIRY],
    },
    :typeCondition => {
      :DARK => "self.pbIsPhysical?(attacker, @type)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :CITY => [:UPROAR, :HYPERVOICE, :ECHOEDVOICE, :BOOMBURST],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "Cops! Everyone scatter!" => [:UPROAR, :HYPERVOICE, :ECHOEDVOICE, :BOOMBURST],
    },
    :statusBuffs => [:SMOKESCREEN, :NASTYPLOT, :PARTINGSHOT, :FAKETEARS, :POISONGAS, :SMOG, :TRICK, :SWITCHEROO, :CORROSIVEGAS, :SNATCH],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::ACCURACY => 1,
      },
    },
  },

  :CITY => {
    :name => "City",
    :fieldAppSwitch => 2048,
    :fieldMessage => "The streets are busy...",
    :graphic => ["GDCCentralSquare", "City", "GearenNew", "GDCDreamDistrict", "GDCDistrictOfHope", "GDCJudicialDistrict", "GDCScholarDistrict"],
    :secretPower => :SMOG,
    :naturePower => :SMOG,
    :mimicry => :NORMAL,
    :burmyCloak => :TRASHCLOAK,
    :damageMods => {
      1.5 => [:STEAMROLLER, :SMOG, :BEATUP, :PAYDAY, :FIRSTIMPRESSION, :TECHNOBLAST],
    },
    :accuracyMods => {
      0 => [:SMOG, :POISONGAS],
    },
    :moveMessages => {
      "The power of science is amazing!" => [:TECHNOBLAST],
      "A crowd is gathering!" => [:BEATUP],
      "The city smog is suffocating!" => [:SMOG],
      "Careful on the street!" => [:STEAMROLLER],
      "Working 9 to 5 for this!" => [:PAYDAY],
      "An overwhelming first impression!" => [:FIRSTIMPRESSION],
    },
    :typeMods => {
      :NORMAL => [:FIRSTIMPRESSION],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:NORMAL],
      1.3 => [:POISON, :BUG, :STEEL],
    },
    :typeMessages => {
      "The hustle and bustle of the city!" => [:NORMAL],
      "The power of science is amazing!" => [:STEEL],
      "In the cracks and the walls!" => [:BUG],
      "All kinds of pollution strengthened the attack!" => [:POISON],
    },
    :typeCondition => {
      :NORMAL => "self.pbIsPhysical?(attacker, @type)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :BACKALLEY => [:THIEF, :COVET, :PURSUIT],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The criminal ran into a backalley!" => [:THIEF, :COVET, :PURSUIT],
    },
    :statusBuffs => [:SMOKESCREEN, :WORKUP, :AUTOTOMIZE, :SHIFTGEAR, :POISONGAS, :SMOG, :RECYCLE, :CORROSIVEGAS],
    :statusNerfs => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::ACCURACY => 1,
      },
    },
  },

  :DEUXFINALIS => {
    :name => "Deux Finalis",
    :fieldAppSwitch => 2049,
    :fieldMessage => "Purifying mediums line the arena...",
    :graphic => ["Consecrated", "Dissolution"],
    :secretPower => :SALTCURE,
    :naturePower => :SMELLINGSALTS,
    :mimicry => :NORMAL,
    :burmyCloak => :SANDYCLOAK,
    :damageMods => {
      2.0 => [:DOOMDESIRE, :LIGHTOFRUIN, :OBLIVIONWING, :SALTCURE],
      1.5 => [:HYPERSPACEFURY, :HYPERSPACEHOLE, :SPACIALREND, :ROAROFTIME, :ETERNABEAM, :DYNAMAXCANNON, :SHADOWFORCE, :PHANTOMFORCE,
              :BITTERMALICE, :JUDGMENT,  :ANCIENTPOWER, :DIAMONDSTORM, :SHADOWSNEAK,  :BITTERBLADE, :TECHNOBLAST, :MULTIPULSE,
              :LUSTERPURGE, :TERASTARSTORM, :SHADOWCLAW, :SHADOWBALL, :COLDTRUTH, :HYDROVORTEX, :FLASHCANNON],
      1.2 => [:DARKPULSE, :NIGHTDAZE, :BRINE, :RADIANTCLAW],
    },
    :accuracyMods => {
      100 => [:DARKVOID, :NIGHTDAZE, :DIAMONDSTORM, :SCALESHOT, :RUINATION],
    },
    :moveMessages => {
      "The dimensions' barrier was torn apart!" => [:HYPERSPACEFURY, :HYPERSPACEHOLE, :SPACIALREND, :ROAROFTIME, :ETERNABEAM, :DYNAMAXCANNON],
      "The distortion above strengthened the attack!" => [:SHADOWBALL, :SHADOWCLAW, :DARKPULSE, :SHADOWSNEAK, :NIGHTDAZE, :BITTERMALICE, :BITTERBLADE, :SHADOWFORCE, :PHANTOMFORCE],
      "The Lord's judgment is swift and merciless!" => [:JUDGMENT, :COLDTRUTH],
      "The world was flooded!" => [:HYDROVORTEX],
      "All shall end..." => [:LIGHTOFRUIN, :DOOMDESIRE, :OBLIVIONWING],
      "The salt assimilated the target!" => [:SALTCURE],
      "The purifying mediums merged with the attack!" => [:TECHNOBLAST, :ANCIENTPOWER, :BRINE, :DIAMONDSTORM, :LUSTERPURGE, :TERASTARSTORM, :FLASHCANNON],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:DARK, :NORMAL, :DRAGON, :WATER, :ROCK, :FAIRY],
    },
    :typeMessages => {
      "The darkness is here..." => [:DARK],
      "The purifying mediums merged with the attack!" => [:NORMAL, :FAIRY],
      "The legendary energy resonated with the attack!" => [:DRAGON],
      "Doused for the grand-finale!" => [:WATER],
      "The salt wears away at what it touches!" => [:ROCK],
    },
    :typeCondition => {
      :WATER => "opponent.hp <= (opponent.totalhp / 2.0).floor",
      :FAIRY => "self.pbIsSpecial?(attacker, type)",
      :ROCK => "opponent.hasType?(:WATER) || opponent.hasType?(:STEEL)",
      :NORMAL => "!(opponent.species == :YVELTAL && opponent.form == 1)",
    },
    :typeEffects => {},
    :dontChangeBackup => [],
    :statusBuffs => [:DARKVOID, :DRAGONCHEER, :LUCKYCHANT, :CLANGOROUSSOUL, :PURIFY, :GLARE],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => nil,
      :duration => 3,
      :message => nil,
      :animation => :PERISHSONG,
      :stats => {
        PBStats::DEFENSE => 1,
        PBStats::SPDEF => 1,
        PBStats::SPEED => 1,
      },
    },
  },
}

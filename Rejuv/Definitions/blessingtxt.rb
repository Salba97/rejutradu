BLESSINGS = {
  :SHARPENEDSTEEL => {
    :name => "Sharpened Steel",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :STEEL
    },
    :typeBoost => true,
    :group => 1,
    :icon => "Graphics/Icons/bosstypeSTEEL",
  },

  :HEATEDANVIL => {
    :name => "Heated Anvil",
    :desc => "@type@ moves have a @statusChance*100@% chance to inflict @status@.",
    :values => {
      :statusChance => [
        0.2,
        0.35,
        0.5
      ],
      :status => :BURN,
      :type => [:STEEL, :ROCK]
    },
    :moveStatusEffect => true,
    :group => 1,
  },

  :FAVORABLETIDES => {
    :name => "Favorable Tides",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :WATER
    },
    :typeBoost => true,
    :group => 1,
    :icon => "Graphics/Icons/bosstypeWATER",
  },

  :HERBALBATH => {
    :name => "Herbal Bath",
    :desc => "Gradually restore @healAmount*100@% HP every @turns@ turn(s).",
    :values => {
      :healAmount => [
        0.05,
        0.05,
        0.1
      ],
      :turns => [
        2,
        1,
        1
      ]
    },
    :passiveHP => true,
    :group => 1,
  },

  :OBSIDIANPOINT => {
    :name => "Obsidian Point",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :ROCK
    },
    :typeBoost => true,
    :group => 1,
    :icon => "Graphics/Icons/bosstypeROCK",
  },

  :ROCKSOLID => {
    :name => "Rock Solid",
    :desc => [
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle. Additionally, gain a @bonusChance*100@% chance to increase @stats@ every turn.",
    ],
    :values => {
      :boostChance => BlessingTables::SwitchBoost,
      :bonusChance => [
        0.0,
        0.0,
        0.33
      ],
      :stats => [PBStats::DEFENSE]
    },
    :entryEffect => true,
    :endOfTurnStatBoost => true,
    :group => 1,
  },

  :FIERYSPIRIT => {
    :name => "Fiery Spirit",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :FIRE
    },
    :typeBoost => true,
    :group => 2,
    :icon => "Graphics/Icons/bosstypeFIRE",
  },

  :HEATEDRIFLE => {
    :name => "Heated Rifle",
    :desc => "@type@ moves gain +@bonusCrit@ critical-hit ratio.",
    :values => {
      :bonusCrit => [
        1,
        2
      ],
      :type => :FIRE
    },
    :maxRank => 2,
    :modifyCritRate => true,
    :group => 2,
  },

  :ACIDICGRAZE => {
    :name => "Acidic Graze",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :POISON
    },
    :typeBoost => true,
    :group => 2,
    :icon => "Graphics/Icons/bosstypePOISON",
  },

  :CHEMICALBURN => {
    :name => "Chemical Burn",
    :desc => "All @type@ moves have a @statusChance*100@% chance to inflict @status@.",
    :values => {
      :statusChance => [
        0.2,
        0.35,
        0.5
      ],
      :status => [:BURN, :POISON],
      :type => [:POISON, :WATER]
    },
    :moveStatusEffect => true,
    :group => 2,
  },

  :COVERTMEDIUM => {
    :name => "Covert Medium",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :DARK
    },
    :typeBoost => true,
    :group => 2,
    :icon => "Graphics/Icons/bosstypeDARK",
  },

  :TWOFORFLINCHING => {
    :name => "Two-For-Flinching",
    :desc => "Opponents that flinch take @damage*100@% max HP damage.",
    :values => {
      :damage => 0.25
    },
    :maxRank => 1,
    :modifyTryUseMove => true,
    :group => 2,
  },

  :TANGLINGROOTS => {
    :name => "Tangling Roots",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :GRASS
    },
    :typeBoost => true,
    :group => 3,
    :icon => "Graphics/Icons/bosstypeGRASS",
  },

  :NOURISHINGNUTRIENTS => {
    :name => "Nourishing Nutrients",
    :desc => [
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle. Gain a @bonusChance*100@% chance to instead raise @stats@ to @bonusBoost@.",
    ],
    :values => {
      :boostChance => BlessingTables::SwitchBoost,
      :bonusChance => [
        0.0,
        0.0,
        0.33
      ],
      :bonusBoost => 2,
      :stats => [PBStats::SPDEF]
    },
    :entryEffect => true,
    :group => 3,
    :icon => "Graphics/Icons/bosstypeGRASS",
  },

  :EARTHSHAKER => {
    :name => "Earth Shaker",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :GROUND
    },
    :typeBoost => true,
    :group => 3,
    :icon => "Graphics/Icons/bosstypeGROUND",
  },

  :COVERINGTERRAIN => {
    :name => "Covering Terrain",
    :desc => [
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle. Additionally, gain a @bonusChance*100@% chance to increase @stats@ every turn.",
    ],
    :values => {
      :boostChance => BlessingTables::SwitchBoost,
      :bonusChance => [
        0.0,
        0.0,
        0.33
      ],
      :stats => [PBStats::EVASION]
    },
    :entryEffect => true,
    :endOfTurnStatBoost => true,
    :group => 3,
    :icon => "Graphics/Icons/bosstypeGROUND",
  },

  :GALEFORCE => {
    :name => "Gale Force",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :FLYING
    },
    :typeBoost => true,
    :group => 3,
    :icon => "Graphics/Icons/bosstypeFLYING",
  },

  :HAWKSEYE => {
    :name => "Hawk's Eye",
    :desc => [
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle. Additionally, gain a @bonusChance*100@% chance to increase @stats@ every turn.",
    ],
    :values => {
      :boostChance => BlessingTables::SwitchBoost,
      :bonusChance => [
        0.0,
        0.0,
        0.33
      ],
      :stats => [PBStats::ACCURACY]
    },
    :entryEffect => true,
    :endOfTurnStatBoost => true,
    :group => 3,
  },

  :ARCTICNOBILITY => {
    :name => "Arctic Nobility",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :ICE
    },
    :typeBoost => true,
    :group => 4,
    :icon => "Graphics/Icons/bosstypeICE",
  },

  :SLIPNSLIDE => {
    :name => "Slip 'n Slide",
    :desc => [
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle. Additionally, gain a @bonusChance*100@% chance to increase @stats@ every turn.",
    ],
    :values => {
      :boostChance => BlessingTables::SwitchBoost,
      :bonusChance => [
        0.0,
        0.0,
        0.33
      ],
      :stats => [PBStats::SPEED]
    },
    :entryEffect => true,
    :endOfTurnStatBoost => true,
    :group => 4,
  },

  :ROUTINE => {
    :name => "Routine",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :NORMAL
    },
    :typeBoost => true,
    :group => 4,
    :icon => "Graphics/Icons/bosstypeNORMAL",
  },

  :POWERTHROUGH => {
    :name => "Power Through",
    :desc => "@type@ moves gain +@bonusCrit@ critical-hit ratio.",
    :values => {
      :bonusCrit => [
        1,
        2
      ],
      :type => :NORMAL
    },
    :maxRank => 2,
    :modifyCritRate => true,
    :group => 4,
  },

  :GHASTLYAPPLAUSE => {
    :name => "Ghastly Applause",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :GHOST
    },
    :typeBoost => true,
    :group => 4,
    :icon => "Graphics/Icons/bosstypeGHOST",
  },

  :VENGEFULHEX => {
    :name => "Vengeful Hex",
    :desc => "All moves have a @statusChance*100@% chance to apply a @status@, dealing @damage*100@% max Health every turn.",
    :values => {
      :statusChance => [
        0.35,
        0.5,
        0.65
      ],
      :damage => [
        0.0625,
        0.125,
        0.25
      ],
      :status => :VENGEFULHEX
    },
    :moveStatusEffect => true,
    :group => 4,
    :icon => "Graphics/Icons/bosstypeSHADOW",
  },

  :DRAGONSWRATH => {
    :name => "Dragon's Wrath",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :DRAGON
    },
    :typeBoost => true,
    :group => 5,
    :icon => "Graphics/Icons/bosstypeDRAGON",
  },

  :COCKATRICEDEATHSTARE => {
    :name => "Cockatrice Death-stare",
    :desc => "All @type@ moves have a @statusChance*100@% chance to inflict @status@.",
    :values => {
      :statusChance => [
        0.2,
        0.35,
        0.5
      ],
      :status => :PETRIFIED,
      :type => [:DRAGON, :DARK]
    },
    :moveStatusEffect => true,
    :group => 5,
  },

  :HEROSSPIRIT => {
    :name => "Hero's Spirit",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :FAIRY
    },
    :typeBoost => true,
    :group => 5,
    :icon => "Graphics/Icons/bosstypeFAIRY",
  },

  :SLEEPINGBEAUTY => {
    :name => "Sleeping Beauty",
    :desc => "All @type@ moves have a @statusChance*100@% chance to inflict @status@.",
    :values => {
      :statusChance => [
        0.2,
        0.35,
        0.5
      ],
      :status => :SLEEP,
      :type => [:FAIRY]
    },
    :moveStatusEffect => true,
    :group => 5,
  },

  :POWERSUPPLY => {
    :name => "Power Supply",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :ELECTRIC
    },
    :typeBoost => true,
    :group => 5,
    :icon => "Graphics/Icons/bosstypeELECTRIC",
  },

  :BEWILDERINGDUO => {
    :name => "Bewildering Duo",
    :desc => [
      "All moves have a @statusChance*100@% chance to inflict @status@.",
      "All moves have a @statusChance*100@% chance to inflict @status@.",
      "All moves have a @statusChance*100@% chance to inflict @status@. Enemies also gain an additional @hitBonus*100@% chance to hit themselves in Confusion.",
    ],
    :values => {
      :statusChance => [
        0.2,
        0.25,
        0.3
      ],
      :status => :CONFUSION,
      :hitBonus => [
        0.0,
        0.0,
        0.15
      ]
    },
    :moveStatusEffect => true,
    :group => 5,
  },

  :SURGINGSTRIKES => {
    :name => "Surging Strikes",
    :desc => [
      "All moves have a @hitChance*100@% chance to strike again at @damageReduction*100@% damage.",
      "All moves have a @hitChance*100@% chance to strike again at @damageReduction*100@% damage.",
      "All moves have a @hitChance*100@% chance to strike again at @damageReduction*100@% damage. Gain an additional @bonusProcChance*100@% chance to strike @bonusProcHits@ more time(s).",
    ],
    :values => {
      :hitChance => [
        0.3,
        0.7,
        1.0
      ],
      :bonusHits => 1,
      :damageReduction => 0.25,
      :bonusProcChance => [
        0.0,
        0.0,
        0.33
      ],
      :bonusProcHits => 2
    },
    :modifyHitCount => true,
    :modifyTotalDamage => true,
    :group => 5,
  },

  :PACIFISTSPULL => {
    :name => "Pacifist's Pull",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :PSYCHIC
    },
    :typeBoost => true,
    :group => 6,
    :icon => "Graphics/Icons/bosstypePSYCHIC",
  },

  :SOULREAD => {
    :name => "Soul Read",
    :desc => "@type@ moves gain +@bonusCrit@ critical-hit ratio.",
    :values => {
      :bonusCrit => [
        1,
        2
      ],
      :type => :PSYCHIC
    },
    :maxRank => 2,
    :modifyCritRate => true,
    :group => 6,
  },

  :BONAFIDEBUGGIES => {
    :name => "Bonafide Buggies",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :BUG
    },
    :typeBoost => true,
    :group => 6,
    :icon => "Graphics/Icons/bosstypeBUG",
  },

  :DANCEOFTHEFIREFLIES => {
    :name => "Dance of the Fireflies",
    :desc => [
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle. Gain a @bonusChance*100@% chance to instead raise @stats@ to @bonusBoost@.",
    ],
    :values => {
      :boostChance => BlessingTables::SwitchBoost,
      :bonusChance => [
        0.0,
        0.0,
        0.33
      ],
      :bonusBoost => 2,
      :stats => [PBStats::SPATK]
    },
    :entryEffect => true,
    :group => 6,
  },

  :FRIENDLYSPAR => {
    :name => "Friendly Spar",
    :desc => "Boosts the power of @type@ moves by @amount*100@%.",
    :values => {
      :amount => BlessingTables::TypeBoost,
      :type => :FIGHTING
    },
    :typeBoost => true,
    :group => 6,
    :icon => "Graphics/Icons/bosstypeFIGHTING",
  },

  :OFHEARTANDMIND => {
    :name => "Of Heart and Mind",
    :desc => [
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle.",
      "Gain a @boostChance*100@% chance of raising @stats@ when a Pokémon enters a battle. Gain a @bonusChance*100@% chance to instead raise @stats@ to @bonusBoost@.",
    ],
    :values => {
      :boostChance => BlessingTables::SwitchBoost,
      :bonusChance => [
        0.0,
        0.0,
        0.33
      ],
      :bonusBoost => 2,
      :stats => [PBStats::ATTACK]
    },
    :entryEffect => true,
    :group => 6,
  },

}

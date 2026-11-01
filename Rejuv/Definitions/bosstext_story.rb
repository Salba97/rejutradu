BOSSINFOHASH = {

  :BOSSGARBODOR => {
    :name => "Garbage Menace",
    :entryText => "The Garbage Crew approached!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :GARBODOR,
      :level => 10,
      :moves => [:POUND, :ACIDSPRAY, :DOUBLESLAP, :ATTRACT],
      :ability => :STENCH,
      :gender => :M,
      :shiny => true,
      :nature => :NAUGHTY,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 1",
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :TRUBBISH,
          :level => 9,
          :moves => [:POUND, :POISONGAS, :THIEF, nil],
          :ability => :STENCH,
          :iv => 10,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Garbodor's typing changed!",
        :animation => :NASTYPLOT,
        :typeChange => [:POISON, :DARK],
      },
    },
  },

  :RIFTGYARADOS1 => {
    :name => "Rift Gyarados",
    :entryText => "Rift Gyarados attacked in a rage!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :GYARADOS,
      :level => 18,
      :form => 4,
      :moves => [:SHADOWSNEAK, :BITE, :WATERGUN, :LEER],
      :ability => :INTIMIDATE,
      :gender => :M,
      :nature => :NAUGHTY,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Rift Gyarados started acting defensive!",
        :animation => :WITHDRAW,
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => 1,
        },
      },
    },
  },

  :BOSSPYROAR => {
    :name => "Top Dog",
    :entryText => "The freshly evolved Arcanine attacked!",
    :shieldCount => 1,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :ARCANINE,
      :level => 15,
      :moves => [:FIREFANG, :HOWL, :BITE, :ROAR],
      :ability => :FLASHFIRE,
      :gender => :M,
      :nature => :NAUGHTY,
      :iv => 10,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 1",
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :LITLEO,
          :level => 10,
          :moves => [:EMBER, :HEADBUTT, :LEER, :WORKUP],
          :ability => :UNNERVE,
          :iv => 5,
        },
        2 => {
          :species => :GLIGAR,
          :level => 10,
          :moves => [:KNOCKOFF, :SANDATTACK, :POISONSTING, :FURYCUTTER],
          :ability => :UNNERVE,
          :iv => 5,
        },
      },
    },
    :onBreakEffects => {},
  },

  :RIFTCHANDELURE => {
    :name => "Rift Chandelure",
    :entryText => "Otherworldly wind chimes echo through the air...",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :CHANDELURE,
      :level => 55,
      :form => 3,
      :moves => [:SHADOWBALL, :HEX, :FIREBLAST, :WILLOWISP],
      :gender => :M,
      :nature => :TIMID,
      :happiness => 255,
    },
    :onEntryEffects => {
      :message => "A feeling of warmth emanates from Rift Chandelure...",
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :animation => :OMINOUSWIND,
        :message => "The air feels cold and moist...",
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :typeChange => [:GHOST, :WATER],
        :movesetUpdate => [:SHADOWBALL, :HEX, :SURF, :WHIRLPOOL],
        :abilitychange => :TRACE,
      },
      1 => {
        :threshold => 0,
        :animation => :OMINOUSWIND,
        :message => "A sickly sweet scent attacks your nose...",
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
        :typeChange => [:GHOST, :GRASS],
        :movesetUpdate => [:SHADOWBALL, :HEX, :ENERGYBALL, :LEECHSEED],
        :abilitychange => :TRACE,
      },
    },
  },

  :SHADOWMEWTWO => {
    :name => "Shadow Mewtwo",
    :entryText => "Mewtwo's power is building up!",
    :shieldCount => 1,
    :immunities => {},
    :onEntryEffects => {
      :message => "<char>KETA: We have to defeat it quickly or else...",
    },
    :chargeAttack => {
      :turns => 10,
      :chargingMessage => "Mewtwo is charging its attack...",
      :continueCharging => true,
      :canAttack => false,
      :intermediateattack => {
        :move => :HYPERBEAM,
        :type => :SHADOW,
        :basedamage => 40,
        :name => "Shadow Beam",
        :category => :special,
        :target => :AllOpposing,
      },
    },
    :moninfo => {
      :species => :MEWTWO,
      :level => 27,
      :moves => [:SHADOWSNEAK],
      :ability => :PRESSURE,
      :nature => :HARDY,
      :iv => 20,
      :happiness => 0,
      :form => 3,
      :shadow => true,
      :ev => [20, 20, 20, 20, 20, 20],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Shadow Mewtwo's power grows!",
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => -2,
          PBStats::SPATK => 1,
          PBStats::SPDEF => -2,
        },
      },
    },
  },

  :RIFTGYARADOS2 => {
    :name => "Rift Gyarados",
    :entryText => "Rift Gyarados is intent on revenge!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :GYARADOS,
      :level => 31,
      :form => 4,
      :moves => [:PHANTOMFORCE, :WATERFALL, :BITE, :SCREECH],
      :ability => :INTIMIDATE,
      :gender => :M,
      :nature => :NAUGHTY,
      :iv => 20,
      :happiness => 255,
      :ev => [20, 20, 20, 20, 20, 20],
      :BaseStats => [95, 145, 89, 120, 110, 81],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Rift Gyarados's type changed!",
        :typeChange => [:WATER, :DRAGON],
        :movesetUpdate => [:DRAGONBREATH, :WATERFALL, :THUNDERFANG, :SCREECH],
        :fieldChange => :WATERSURFACE,
        :fieldChangeMessage => "Rift Gyarados dragged the battle to the lake!",
      },
      1 => {
        :threshold => 0,
        :message => "Rift Gyarados's type changed!",
        :typeChange => [:FIRE, :DRAGON],
        :movesetUpdate => [:DRAGONBREATH, :LAVAPLUME, :BITE, :SCREECH],
        :statDropCure => true,
        :fieldChange => :INFERNAL,
        :fieldChangeMessage => "Rift Gyarados conflagarated the arena!",
      },
    },
  },

  :PULSEMUSHARNA => {
    :name => "PULSE+ Musharna",
    :entryText => "The dangerous(?) Musharna attacked(?)!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :MUSHARNA,
      :level => 18,
      :form => 2,
      :moves => [:PSYBEAM, :DISARMINGVOICE, :CHARGEBEAM, :SWEETSCENT],
      :gender => :F,
      :nature => :DOCILE,
      :ability => :PASTELVEIL,
      :iv => 0,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :fieldChange => :MISTY,
        :fieldChangeMessage => "Pulse Musharna spread mist everywhere.",
      },
    },
  },

  :PULSEMUSHARNA2 => {
    :name => "PULSE+ Musharna",
    :entryText => "The dangerous(?) Musharna attacked(?) again!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :MUSHARNA,
      :level => 86,
      :form => 2,
      :item => :SITRUSBERRY,
      :moves => [:MISTBALL, :DAZZLINGGLEAM, :AURASPHERE, :SWEETSCENT],
      :gender => :F,
      :nature => :MODEST,
      :ability => :PASTELVEIL,
      :happiness => 255,
    },
    :delayedactions => {
      :SwarmDefend => {
        :delay => 4,
        :message => "Pulse Musharna issued a defend order!",
        :animation => :DEFENDORDER,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
        :queueDelays => [:SwarmAttack],
      },
      :SwarmAttack => {
        :delay => 4,
        :message => "Pulse Musharna issued an attack order!",
        :animation => :ATTACKORDER,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :queueDelays => [:SwarmHeal],
      },
      :SwarmHeal => {
        :delay => 4,
        :message => "Pulse Musharna issued a heal order!",
        :animation => :HEALORDER,
        :statusCure => true,
        :statDropCure => true,
        :effectClear => true,
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :bosssideChanges => {
          :Mist => [5, :MIST, nil],
        },
        :movesetUpdate => [:MISTBALL, :STRANGESTEAM, :MAGICALLEAF, :STUNSPORE],
        :message => "Pulse Musharna is laying lazily in the flowers...",
      },
      1 => {
        :threshold => 0,
        :message => "Pulse Musharna became one with the bugs...",
        :bosssideChanges => {
          :Safeguard => [3, :SAFEGUARD, nil],
        },
        :typeChange => [:BUG, :FAIRY],
        :movesetUpdate => [:BUGBUZZ, :STRANGESTEAM, :MISTBALL, :MYSTICALFIRE],
        :queueDelays => [:SwarmDefend],
      },
    },
  },

  :BOSSGOTHITELLE_SHERIDAN => {
    :name => "Gothitelle",
    :entryText => "The mischievous Gothitelle laughs at you!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :GOTHITELLE,
      :level => 32,
      :form => 1,
      :moves => [:FAKETEARS, :PSYCHIC, :FLATTER, :DARKPULSE],
      :gender => :F,
      :nature => :MODEST,
      :ability => :SHADOWTAG,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
    },
  },

  :CRESCGOTHITELLE => {
    :name => "Gothitelle",
    :entryText => "The mischievous Gothitelle laughs at you!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :GOTHITELLE,
      :level => 45,
      :form => 1,
      :moves => [:PLAYNICE, :PSYSHOCK, :FOCUSBLAST, :DARKPULSE],
      :gender => :F,
      :nature => :MODEST,
      :ability => :COMPETITIVE,
      :iv => 20,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :fieldChange => :PSYTERRAIN,
        :fieldChangeMessage => "Gothitelle laughs at how dumb your face looks. So mean!"
      },
    },
  },

  :KIERANXURK_1 => {
    :name => "Xurkitree",
    :entryText => "Static electricity crackles in the air...",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :XURKITREE,
      :level => 65,
      :moves => [:THUNDER, :ENERGYBALL, :DAZZLINGGLEAM, :TAILGLOW],
      :nature => :MODEST,
      :ability => :BEASTBOOST,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 0, 252, 0, 252],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :fieldChange => :ELECTERRAIN,
        :fieldChangeMessage => "Xurkitree repositions itself."
      },
    },
  },

  :SEAPRINCE => {
    :name => "Manaphy",
    :entryText => "<char>ODESSA: Witness the might of the seas!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => []
    },
    :moninfo => {
      :species => :MANAPHY,
      :level => 53,
      :item => :LEFTOVERS,
      :moves => [:SCALD, :SHADOWBALL, :RAINDANCE, :TAKEHEART],
      :ability => :HYDRATION,
      :nature => :MODEST,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 0",
      :continuous => true,
      :totalMonCount => 3,
      :moninfos => {
        1 => {
          :species => :PHIONE,
          :level => 45,
          :moves => [:SURF, :ENERGYBALL, :HELPINGHAND, :DAZZLINGGLEAM],
          :ability => :HYDRATION,
          :nature => :MODEST,
          :happiness => 255,
        },
      },
    },
    :delayedactions => {
      :DimTheGlow => {
        :delay => 2,
        :message => "The Prince's glowing tail starts to dim...",
        :bossStatChanges => {
          PBStats::SPATK => -1,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "<char>ODESSA: The Prince of the Sea's tail shines bright. Be blinded by its glow!",
        :animation => :TAILGLOW,
        :weatherChange => [:RAINDANCE, 5, "The Rain pours down!"],
        :statusCure => true,
        :itemchange => :LEFTOVERS,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :queueDelays => [:DimTheGlow],
      },
      1 => {
        :threshold => 0,
        :message => "<char>ODESSA: The Prince can command the sea themselves. As such as a Prince should! Be purged by the sacred waters of Kristiline! ",
        :abilitychange => :PRESSURE,
        :fieldChange => :WATERSURFACE,
        :fieldChangeMessage => "The battlefield was taken to the seas!",
        :statusCure => true,
        :itemchange => :LEFTOVERS,
      },
    },
  },

  :RIFTGALVANTULA => {
    :name => "Rift Galvantula",
    :entryText => "Joltik swarm the egg...",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :GALVANTULA,
      :level => 22,
      :form => 2,
      :moves => [:ELECTROWEB, :BUGBITE, :CROSSPOISON, :TOXICTHREAD],
      :gender => :F,
      :nature => :HASTY,
      :ability => :PARENTALBOND,
      :iv => 20,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :moninfos => {
        1 => {
          :species => :JOLTIK,
          :level => 17,
          :moves => [:ELECTROWEB, :STRINGSHOT, :STRUGGLEBUG, nil],
          :ability => :COMPOUNDEYES,
          :form => 1,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :formchange => 1,
        :message => "Rift Galvantula hatched out of the egg!",
        :movesetUpdate => [:ELECTROWEB, :BUGBITE, :CROSSPOISON, :SLUDGE],
        :statDropCure => true,
        :playersideChanges => {
          :ToxicSpikes => [1, :TOXICSPIKES, "Broken eggshell was strewn everywhere!"],
        },
      },
    },
  },

  :RIFTVOLCANION => {
    :name => "Rift Volcanion",
    :entryText => "Rift Volcanion let out a languid grumble...",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :VOLCANION,
      :level => 24,
      :form => 1,
      :moves => [:STEAMERUPTION, :FLAMETHROWER, :SCORCHINGSANDS, :ROCKSLIDE],
      :nature => :LONELY,
      :iv => 0,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Volcanion is losing motivation...",
        :movesetUpdate => [:SCALD, :INCINERATE, :MUDSHOT, :ROCKTOMB],
        :bossStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => -1,
          PBStats::SPATK => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => -1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "Volcanion is losing motivation...",
        :movesetUpdate => [:WATERGUN, :EMBER, :MUDSLAP, :ROCKTHROW],
        :bossStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => -1,
          PBStats::SPATK => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => -1,
        },
      },
    },
  },

  :BOSSDUSKNOIR => {
    :name => "Dusknoir",
    :entryText => "The Dusknoir is threatening you.",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :DUSKNOIR,
      :level => 28,
      :moves => [:SHADOWPUNCH, :WILLOWISP, :INFESTATION, :PAYBACK],
      :gender => :M,
      :nature => :ADAMANT,
      :iv => 20,
      :form => 1,
      :ev => [32, 32, 32, 32, 32, 32],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Dusknoir is about to throw hands!",
        :movesetUpdate => [:SHADOWPUNCH, :WILLOWISP, :ICYWIND, :THUNDERPUNCH],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
    },
  },

  :WISPYGIRATINA => {
    :name => "Renegade Giratina",
    :entryText => "<char>GEARA: Destroy them, Giratina! Show them the might of a Legendary Pokémon!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :GIRATINA,
      :level => 33,
      :moves => [:SHADOWCLAW, :DRAGONBREATH, :SLASH, :SCARYFACE],
      :nature => :HARDY,
      :iv => 20,
      :form => 1,
      :ev => [32, 32, 32, 32, 32, 32],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Giratina's ghastly aura lowered offenses!",
        :statDropCure => true,
        :playerSideStatChanges => {
          PBStats::ATTACK => -1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "Giratina's aura enveloped the battlefield!",
        :bossStatChanges => {
          PBStats::DEFENSE => -2,
          PBStats::SPDEF => -2,
        },
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
        },
      },
    },
  },

  :BOSSCROBAT => {
    :name => "Furious Bat",
    :entryText => "The Crobat attacked with furor!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :CROBAT,
      :level => 32,
      :moves => [:CROSSPOISON, :BITE, :WINGATTACK, :PROTECT],
      :ability => :INFILTRATOR,
      :gender => :F,
      :nature => :NAUGHTY,
      :item => :FLYINGGEM,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 10",
      :continuous => true,
      :moninfos => {
        1 => {
          :species => :ZUBAT,
          :level => 27,
          :moves => [:CONFUSERAY, :POISONFANG, :THIEF,],
          :ability => :INNERFOCUS,
          :iv => 31,
        },
        2 => {
          :species => :WOOBAT,
          :level => 27,
          :moves => [:CONFUSION, :CHARM, :AIRSLASH,],
          :ability => :UNAWARE,
          :iv => 31,
        },
        3 => {
          :species => :NOIBAT,
          :level => 27,
          :moves => [:SUPERFANG, :WHIRLWIND, :AIRSLASH,],
          :ability => :INFILTRATOR,
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :bosssideChanges => {
          :Tailwind => [3, :TAILWIND, nil],
        },
        :movesetUpdate => [:ACROBATICS, :CROSSPOISON, :PROTECT, :UTURN],
        :statDropCure => true,
        :itemchange => :SITRUSBERRY,
      },
    },
  },

  :MADAMESHOGUN => {
    :name => "Madame Shogun",
    :entryText => "With or without my demise, Team Xen's end begins with me!",
    :shieldCount => 4,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :IRONVALIANT,
      :level => 100,
      :form => 2,
      :moves => [:PROMISEDPAIN, nil, nil, nil],
      :nature => :ADAMANT,
      :ev => [0, 255, 0, 255, 0, 255],
      :BaseStats => [200, 105, 110, 105, 105, 100],
    },
    :delayedactions => {
      :WardingStanceStart => {
        :delay => 1,
        :bosssideChanges => {
          :CraftyShield => [true, :CRAFTYSHIELD, "Madame Shogun conjured a status-blocking barrier!"],
        },
        :queueDelays => [:WardingStanceRepeat],
      },
      :WardingStanceRepeat => {
        :delay => 3,
        :bosssideChanges => {
          :CraftyShield => [true, :CRAFTYSHIELD, "Madame Shogun conjured a status-blocking barrier!"],
        },
        :queueDelays => [:WardingStanceRepeat],
      },
    },
    :onBreakEffects => {
      6 => {
        :typeChange => [:STEEL, :ICE],
        :weatherChange => [:SNOW, 5, "A snowstorm enveloped the arena!"],
        :message => "Madame Shogun switched up her stance!",
        :movesetUpdate => [:PROMISEDPAIN, :BANGLEBLADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      4 => {
        :typeChange => [:STEEL, :FIGHTING],
        :statusCure => true,
        :playerEffects => {
            :Curse => [true, :CURSE, "A curse has been placed on your team!"],
        },
        :queueDelays => [:WardingStanceStart],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
        :message => "Madame Shogun switched up her stance!",
        :movesetUpdate => [:PROMISEDPAIN, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      2 => {
        :typeChange => [:STEEL, :FIRE],
        :weatherChange => [:SUNNYDAY, 5, "A bright radiance enveloped the arena!"],
        :statusCure => true,
        :message => "Madame Shogun switched up her stance!",
        :movesetUpdate => [:BANGLEBLADE, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      1 => {
        :typeChange => [:STEEL, :QMARKS],
        :message => "Madame Shogun is putting everything into one final frenzy...",
        :movesetUpdate => [:COMPANIONSHUNGER, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
    },
  },

  :MADAMESHOGUNBSVICTORY => {
    :name => "Madame Shogun",
    :entryText => "With or without my demise, Team Xen's end begins with me!",
    :shieldCount => 5,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :IRONVALIANT,
      :level => 100,
      :form => 2,
      :moves => [:PROMISEDPAIN, :BANGLEBLADE, :BURNINGHATE, nil],
      :nature => :ADAMANT,
      :BaseStats => [200, 105, 110, 105, 105, 100],
    },
    :delayedactions => {
      :WardingStanceStart => {
        :delay => 1,
        :bosssideChanges => {
          :CraftyShield => [true, :CRAFTYSHIELD, "Madame Shogun conjured a status-blocking barrier!"],
        },
        :queueDelays => [:WardingStanceRepeat],
      },
      :WardingStanceRepeat => {
        :delay => 3,
        :bosssideChanges => {
          :CraftyShield => [true, :CRAFTYSHIELD, "Madame Shogun conjured a status-blocking barrier!"],
        },
        :queueDelays => [:WardingStanceRepeat],
      },
      :TarShots => {
        :delay => 2,
        :playerEffects => {
          :TarShot => [true, :TARSHOT, "Your Pokemon became highly flammable!"],
        },
        :queueDelays => [:TarShots],
      },
    },
    :onBreakEffects => {
      6 => {
        :typeChange => [:STEEL, :ICE],
        :weatherChange => [:SNOW, 5, "A snowstorm enveloped the arena!"],
        :message => "Madame Shogun switched up her stance!",
        :movesetUpdate => [:PROMISEDPAIN, :BANGLEBLADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      4 => {
        :typeChange => [:STEEL, :FAIRY],
        :statDropCure => true,
        :message => "Madame Shogun switched up her stance!",
        :movesetUpdate => [:BANGLEBLADE, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      2 => {
        :typeChange => [:STEEL, :FIRE],
        :statusCure => true,
        :message => "Madame Shogun switched up her stance!",
        :queueDelays => [:TarShots],
        :movesetUpdate => [:BANGLEBLADE, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      1 => {
        :typeChange => [:STEEL, :QMARKS],
        :message => "Madame Shogun is putting everything into one final frenzy...",
        :movesetUpdate => [:COMPANIONSHUNGER, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
    },
  },


  :MADAMEXYVELTAL => {
    :name => "Yveltal",
    :entryText => "Yveltal looms above.",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :YVELTAL,
      :level => 75,
      :moves => [:DECIMATION, :HURRICANE, :FOCUSBLAST, nil],
      :nature => :MODEST,
      :ev => [0, 0, 0, 0, 0, 0],
    },
  },

  :TAPUKOKOJUNGLE => {
    :name => "Thunder Warrior",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :TAPUKOKO,
      :level => 42,
      :shiny => true,
      :moves => [:STEELWING, :NATURESMADNESS, :ELECTRICTERRAIN, :DISCHARGE],
      :nature => :TIMID,
      :ability => :ELECTRICSURGE,
      :iv => 20,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Tapu Koko is putting in its all!!",
        :movesetUpdate => [:ELECTROBALL, :TAUNT, :SWIFT, :FLY],
        :statDropCure => true,
      },
    },
  },

  :MADAMESHOGUNSPIRIT => {
    :name => "Madame Shogun",
    :entryText => "",
    :shieldCount => 1,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :IRONVALIANT,
      :level => 100,
      :form => 2,
      :moves => [:PROMISEDPAIN, :BANGLEBLADE, :FROZENFURY, :BURNINGHATE],
      :nature => :ADAMANT,
      :slidein => true,
      :BaseStats => [150, 140, 110, 140, 105, 100],
    },
    :delayedactions => {
      :WardingStanceStart => {
        :delay => 1,
        :bosssideChanges => {
          :CraftyShield => [true, :CRAFTYSHIELD, "Madame Shogun conjured a status-blocking barrier!"],
        },
        :queueDelays => [:WardingStanceRepeat],
      },
      :WardingStanceRepeat => {
        :delay => 3,
        :bosssideChanges => {
          :CraftyShield => [true, :CRAFTYSHIELD, "Madame Shogun conjured a status-blocking barrier!"],
        },
        :queueDelays => [:WardingStanceRepeat],
      },
      :TarShots => {
        :delay => 1,
        :playerEffects => {
          :TarShot => [true, :TARSHOT, "Your Pokemon became highly flammable!"],
        },
        :queueDelays => [:TarShots],
      },
    },
    :onEntryEffects => {
      :queueDelays => [:WardingStanceStart],
    },
    :onBreakEffects => {
      1 => {
        :typeChange => [:STEEL, :QMARKS],
        :message => "Madame Shogun is putting everything into one final frenzy...",
        :movesetUpdate => [:COMPANIONSHUNGER, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
    },
  },

  :BOSSCONKELDURR => {
    :name => "Strained Worker",
    :entryText => "Conkeldurr is agitated!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :CONKELDURR,
      :level => 45,
      :moves => [:CHIPAWAY, :ICEPUNCH, :FIREPUNCH, :THUNDERPUNCH],
      :ability => :IRONFIST,
      :gender => :M,
      :nature => :ADAMANT,
      :iv => 0,
      :happiness => 0,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 1",
      :continuous => true,
      :moninfos => {
        1 => {
          :species => :TIMBURR,
          :level => 30,
          :moves => [:COACHING, :HELPINGHAND, :ROCKTHROW, :HAMMERARM],
          :ability => :IRONFIST,
          :nature => :ADAMANT,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Conkeldurr built a miniature city in anger!",
        :fieldChange => :CITY,
      },
      1 => {
        :threshold => 0,
        :message => "The miniature city was destroyed...",
        :fieldChange => :FOREST,
        :bossStatChanges => {
          PBStats::ATTACK => -1,
        },
      },
    },
  },

  :RIFTCARNIVINE => {
    :name => "Corrupted Carnivine",
    :entryText => "Carnivine is dancing the samba!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :CARNIVINE,
      :level => 40,
      :form => 1,
      :moves => [:DRAGONDANCE, :SEEDBOMB, :DRAGONPULSE, :FLAMEBURST],
      :ability => :OWNTEMPO,
      :gender => :M,
      :nature => :NAUGHTY,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :TANGELA,
          :level => 35,
          :form => 1,
          :moves => [:FOLLOWME, :SWAGGER, :POLLENPUFF, :PETALDANCE],
          :ability => :DANCER,
          :gender => :F,
          :nature => :MODEST,
          :happiness => 255,
        },
        2 => {
          :species => :TANGROWTH,
          :level => 35,
          :form => 1,
          :moves => [:FOLLOWME, :QUASH, :POLLENPUFF, :ROCKTOMB],
          :ability => :DANCER,
          :gender => :M,
          :nature => :MODEST,
          :happiness => 255,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :animation => :SHIFTGEAR,
        :message => ["The rhythm of the music has changed!", "Carnivine did the robot and became Steel-type!"],
        :typeChange => [:GRASS, :STEEL],
        :movesetUpdate => [:SHIFTGEAR, :SEEDBOMB, :IRONHEAD, :KNOCKOFF],
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPATK => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => -1,
        },
        :playerSideStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
        },
      },
      1 => {
        :threshold => 0,
        :animation => :QUIVERDANCE,
        :message => ["The rhythm of the music has changed!", "Carnivine did the jitterbug and became Bug-type!"],
        :typeChange => [:GRASS, :BUG],
        :movesetUpdate => [:QUIVERDANCE, :SEEDBOMB, :POLLENPUFF, :KNOCKOFF],
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => -1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
        },
        :playerSideStatChanges => {
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :TAPUKOKOMAGRODAR => {
    :name => "Thunder Warrior",
    :entryText => "The Thunder Warrior is ready to rumble!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :TAPUKOKO,
      :level => 45,
      :shiny => true,
      :moves => [:LIGHTSCREEN, :NATURESMADNESS, :BRAVEBIRD, :REFLECT],
      :nature => :TIMID,
      :ability => :ELECTRICSURGE,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount <= 1",
      :refreshingRequirement => [0],
      :entryMessage => ["Charizard charged into the fight!", "The Thunder Warrior revitalized Charizard's energy!"],
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :CHARIZARD,
          :level => 40,
          :gender => :F,
          :moves => [:INCINERATE, :AIRSLASH, :DRAGONBREATH, :ROOST],
          :ability => :BLAZE,
          :shiny => true,
          :nature => :TIMID,
        },
        2 => {
          :species => :CHARIZARD,
          :level => 40,
          :gender => :F,
          :item => :CHARIZARDITEX,
          :moves => [:BULLDOZE, :DRAGONBREATH, :INCINERATE, :AIRSLASH],
          :ability => :BLAZE,
          :shiny => true,
          :nature => :BRAVE,
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :ability => :TELEPATHY,
        :itemchange => :ELEMENTALSEED,
        :message => "Tapu Koko is putting in its all!!",
        :movesetUpdate => [:SPARK, :HYPERVOICE, :ROOST, :DAZZLINGGLEAM],
      },
    },
  },

  :BOSS_CHAOTICFUSION => {
    :name => "Chaotic Fusion",
    :entryText => "The fused Pokémon suddenly attacked!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :SOLROCK,
      :level => 48,
      :moves => [:WILLOWISP, :ROCKTOMB, :SOLARFLARE, :MORNINGSUN],
      :nature => :QUIRKY,
      :form => 1,
      :ability => :SOLARIDOL,
      :item => :SITRUSBERRY,
    },
    :onEntryEffects => {
      :weatherChange => [:SUNNYDAY, 5, nil],
    },
    :onBreakEffects => {
      3 => {
        :animation => :FLASH,
        :weatherChange => [:SNOWSCAPE, 5, nil],
        :threshold => 0,
        :message => "Lunatone gained control!",
        :itemchange => :SITRUSBERRY,
        :speciesUpdate => :LUNATONE,
        :formchange => 1,
        :abilitychange => :LUNARIDOL,
        :movesetUpdate => [:COSMICPOWER, :ANCIENTPOWER, :HOARFROSTMOON, :MOONLIGHT],
      },
    },
  },

  :AMETHYSTREGIROCK => {
    :name => "Stone Guardian",
    :entryText => "The Guardian is watching your every move.",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :REGIROCK,
      :level => 48,
      :moves => [:CURSE, :HAMMERARM, :ROCKSLIDE, :EARTHQUAKE],
      :nature => :IMPISH,
      :iv => 31,
      :shiny => true,
      :item => :SITRUSBERRY,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Regirock hardened up!",
        :statDropCure => true,
        :playersideChanges => {
          :StealthRock => [true, :STEALTHROCK, "Floating rocks were deployed!"],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
      },
    },
  },

  :AMETHYSTREGISTEEL => {
    :name => "Iron Guardian",
    :entryText => "The Guardian is watching your every move.",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :REGISTEEL,
      :level => 48,
      :moves => [:CURSE, :HAMMERARM, :IRONHEAD, :EARTHQUAKE],
      :nature => :IMPISH,
      :iv => 31,
      :shiny => true,
      :item => :SITRUSBERRY,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Registeel hardened up!",
        :statDropCure => true,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "Spikes were deployed!"],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
      },
    },
  },

  :BELIAL => {
    :name => "Belial",
    :entryText => "A feisty Volcarona appeared!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :VOLCARONA,
      :level => 40,
      :moves => [:MYSTICALFIRE, :BUGBUZZ, :GIGADRAIN, :SUNNYDAY],
      :ability => :FLAMEBODY,
      :nature => :MODEST,
      :gender => :M,
      :iv => 31,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 0",
      :totalMonCount => 2,
      :continuous => true,
      :moninfos => {
        1 => {
          :species => :SHUCKLE,
          :level => 30,
          :moves => [:STEALTHROCK, :INFESTATION, :STICKYWEB, :HELPINGHAND],
          :ability => :STURDY,
          :nature => :BOLD,
          :iv => 31,
        },
        2 => {
          :species => :MOTHIM,
          :level => 30,
          :moves => [:STRUGGLEBUG, :POISONPOWDER, :PROTECT, :LUNGE],
          :ability => :TINTEDLENS,
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Belial is in its last stand!",
        :abilitychange => :SWARM,
        :fieldChange => :FLOWERGARDEN1,
        :fieldChangeMessage => "The field is covered in flowers!",
        :statusCure => true,
        :statDropCure => true,
        :itemchange => :LEFTOVERS,
      },
    },
  },

  :BOSSKYOGRE => {
    :name => "Leviathan Kyogre",
    :entryText => "Kyogre's power is overwhelming!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :KYOGRE,
      :level => 55,
      :moves => [:MUDDYWATER, :ICYWIND, :ANCIENTPOWER, :THUNDERWAVE],
      :nature => :MODEST,
      :item => :SITRUSBERRY,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Kyogre summoned a storm and flooded the arena!",
        :fieldChange => :WATERSURFACE,
        :movesetUpdate => [:WHIRLPOOL, :SHOCKWAVE, :ANCIENTPOWER, :THUNDERWAVE],
        :statDropCure => true,
      },
    },
  },

  :BOSSGROUDON => {
    :name => "Behemoth Groudon",
    :entryText => "Groudon attacked under command!",
    :shieldCount => 1,
    :immunities => {
      :fieldEffectDamage => [:VOLCANIC],
    },
    :moninfo => {
      :species => :GROUDON,
      :level => 55,
      :moves => [:BULLDOZE, :ROCKSLIDE, :TOXIC, :HEATCRASH],
      :nature => :ADAMANT,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Groudon summoned fierce eruptions!",
        :weatherChange => [:SUNNYDAY, -1, nil],
        :fieldChange => :VOLCANIC,
        :movesetUpdate => [:BULLDOZE, :ROCKSLIDE, :THUNDERWAVE, :HEATWAVE],
        :statDropCure => true,
      },
    },
  },

  :VALORGIRATINA => {
    :name => "Renegade Giratina",
    :entryText => "Giratina is blocking the way forward!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :GIRATINA,
      :level => 55,
      :moves => [:SHADOWFORCE, :AURASPHERE, :EARTHPOWER, :DRAGONCLAW],
      :nature => :NAUGHTY,
      :iv => 31,
      :form => 2,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Giratina drew power from the Distortion World!",
        :statDropCure => true,
        :formChange => 3,
        :itemchange => :GRISEOUSORB,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
    },
  },

  :DARCHGIRATINA => {
    :name => "Clown Caricature",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :GIRATINA,
      :level => 62,
      :moves => [:SLUDGEWAVE, :DRAGONPULSE, :NASTYPLOT, :FIREBLAST],
      :nature => :NAUGHTY,
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :speciesUpdate => :PORYGONZ,
        :message => "a Vir us in  d e  ed ",
        :statDropCure => true,
        :abilitychange => :WONDERGUARD,
        :itemchange => :TOXICORB,
      },
      2 => {
        :threshold => 0,
        :speciesUpdate => :BLACEPHALON,
        :movesetUpdate => [:MINDBLOWN, :SHADOWBALL, :NASTYPLOT, :PRESENT],
        :message => "F u n t i m e s w i t h e v e r y o n e ' s b a d e n d i n g",
        :statDropCure => true,
      },
      1 => {
        :threshold => 0,
        :speciesUpdate => :PIDGEY,
        :message => "Can you even beat a Pidgey? Likely not.",
        :statDropCure => true,
      },
    },
  },

  :LAVALAKAZAM => {
    :name => "Alakazam",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :ALAKAZAM,
      :level => 62,
      :gender => :M,
      :moves => [:CALMMIND, :REFLECT, :LIGHTSCREEN, :NIGHTSHADE],
      :nature => :TIMID,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :formchange => 1,
        :message => "Alakazam is pulling all of its psychic energy to its core!",
        :statDropCure => true,
        :movesetUpdate => [:PSYCHIC, :SHADOWBALL, :FOCUSBLAST, :COUNTER],
        :itemchange => :TWISTEDSPOON,
        :bossStatChanges => {
          PBStats::SPDEF => 2,
          PBStats::SPEED => 2
        },
      },
      1 => {
        :threshold => 0,
        :bosssideChanges => {
          :Reflect => [5, :REFLECT, nil],
        },
        :statDropCure => true,
      },
    },
  },

  :DARKGARDEVOIR => {
    :name => "Dark Gardevoir",
    :entryText => "Gardevoir is staring you down.",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :GARDEVOIR,
      :level => 60,
      :moves => [:DARKPULSE, :DAZZLINGGLEAM, :CALMMIND, :PSYCHIC],
      :nature => :TIMID,
      :form => 2,
      :iv => 31,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :bosssideChanges => {
          :Reflect => [3, :REFLECT, nil],
          :Safeguard => [3, :SAFEGUARD, "Gardevoir quickly set up protection!"],
        },
        :statDropCure => true,
      },
    },
  },

  # Umbral Bosses
  :UMBRALGARDEVOIR => {
    :name => "Umbral Gardevoir",
    :entryText => "Umbral magic envelops Gardevoir!",
    :shieldCount => 2,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :GARDEVOIR,
      :level => 60,
      :item => :LUMBERRY,
      :moves => [:DARKPULSE, :MOONBLAST, :CALMMIND, :PSYSHOCK],
      :nature => :TIMID,
      :form => 2,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 1,
      :moninfos => {
        1 => {
          :species => :TINGLU,
          :level => 55,
          :moves => [:STEALTHROCK, :SPIKES, :RUINATION, :WHIRLWIND],
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "I wAs So LoNeLy, bUt yOu SavEd Me...",
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, "Gardevoir quickly set up protection!"],
        }
      },
      1 => {
        :threshold => 0,
        :message => "aLl tHe ChIlDrEN laUGhEd aNd PlAyEd wItH Me... WaS ThAT nOt EnOuGh?",
        :typeChange => [:FAIRY, :WATER],
        :weatherChange => [:RAIN, -1, "Sprinklers emerge from the top of the trees! Rain pours down!"],
        :movesetUpdate => [:HYDROPUMP, :MOONBLAST, :AQUABATICS, :RECOVER],
      },
    }
  },

  :UMBRALSHIFTRY => {
    :name => "Umbral Shiftry",
    :entryText => "Umbral magic envelops Shiftry!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :SHIFTRY,
      :level => 60,
      :moves => [:KNOCKOFF, :SEEDBOMB, :SWORDSDANCE, :HURRICANE],
      :nature => :TIMID,
      :ability => :WINDRIDER,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 6",
      :continuous => true,
      :totalMonCount => 4,
      :moninfos => {
        1 => {
          :species => :BRAMBLEGHAST,
          :level => 55,
          :moves => [:POLTERGEIST, :POWERWHIP, :STRENGTHSAP, :SPIKES],
          :ability => :WINDRIDER,
          :iv => 31,
        },
        2 => {
          :species => :SHIFTRY,
          :level => 55,
          :moves => [:TAILWIND, :KNOCKOFF, :FOULPLAY, :FAKEOUT],
          :ability => :WINDRIDER,
          :iv => 31,
        },
        3 => {
          :species => :KILOWATTREL,
          :level => 55,
          :moves => [:HURRICANE, :TAILWIND, :ELECTROBALL, :THUNDERBOLT],
          :ability => :WINDPOWER,
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Shiftry readies its blade...",
        :animation => :HURRICANE,
        :weatherChange => [:STRONGWINDS, -1, "The winds pick up heavily!"],
        :typeChange => [:GRASS, :FLYING],
        :movesetUpdate => [:LEAFBLADE, :ACROBATICS, :FOULPLAY, :BRICKBREAK],
        },
      2 => {
        :threshold => 0,
        :message => "Shiftry suddenly loses its connection to the flora...",
        :typeChange => [:DARK, :FLYING],
        :movesetUpdate => [:SUCKERPUNCH, :BRAVEBIRD, :SWORDSDANCE, :NIGHTSLASH],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "An Aerial finish! Shiftry takes the battle to the high skies!",
        :animation => :WONDERROOM,
        :fieldChange => :SKY,
        :movesetUpdate => [:NIGHTSLASH, :FLY, :HURRICANE, :BRAVEBIRD],
        :statDropCure => true,
      },
    },
  },

  :UMBRALUNOWN => {
    :name => "Umbral Unown",
    :entryText => "The Unown shudders in place...",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :UNOWN,
      :level => 60,
      :moves => [:HIDDENPOWER, nil, nil, nil],
      :nature => :TIMID,
      :form => 28,
      :ability => :SLOWSTART,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :ARCHEOPS,
          :level => 55,
          :moves => [:ACROBATICS, :STONEEDGE, :STRENGTHSAP, :HEADSMASH],
          :ability => :DEFEATIST,
        },
        2 => {
          :species => :GIGALITH,
          :level => 55,
          :moves => [:STEALTHROCK, :STONEEDGE, :EARTHQUAKE, :SANDSTORM],
          :ability => :STURDY,
        },
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "<char>KARRINA: mOm I'M hOmE!  !!  mOm? wHaT's GoInG oN? wHat hAPpEneD tO mY hOUse",
        :animation => :MEGAEVOLUTION,
        :speciesUpdate => :ARCANINE,
        :formchange => 1,
        :abilitychange => :ROCKHEAD,
        :fieldChange => :INFERNAL,
        :weatherChange => [:SUNNY, -1, "The dark sun sears your skin..."],
        :movesetUpdate => [:HEADSMASH, :FLAREBLITZ, :CRUNCH, :CLOSECOMBAT],
        :itemchange => :LIFEORB,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
      2 => {
        :threshold => 0,
        :message => "<char>KARRINA: tHe hiDdEn LiBrARy... iT's OpEn?? wHy is it... MoM?? DaD??! WhO... ArE... YoU...???",
        :bgmChange => "Battle - Conclusive",
        :animation => :MEGAEVOLUTION,
        :speciesUpdate => :DIANCIE,
        :formchange => 0,
        :itemchange => :DIANCITE,
        :abilitychange => :MAGICBOUNCE,
        :fieldChange => :CRYSTALCAVERN,
        :movesetUpdate => [:DIAMONDSTORM, :PROTECT, :MOONBLAST, :EARTHPOWER],
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :statDropCure => true,
      },
      1 => {
        :threshold => 0,
        :speciesUpdate => :UNOWN,
        :formchange => 28,
        :bgmChange => "Music - Purgatorium_1",
        :message => "<char>KARRINA: I wIlL AvEngE yOu... i WILL.. wiLl...",
        :animation => :WONDERROOM,
        :fieldChange => :STARLIGHT,
        :movesetUpdate => [:HIDDENPOWER, nil, nil, nil],
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :statDropCure => true,
      },
    }
  },

  :UMBRALDEOXYS => {
    :name => "Umbral Deoxys",
    :entryText => "Deoxys looks up into space... Something appears.",
    :shieldCount => 3,
    :doublebattle => true,
    :immunities => {},
    :delayedactions => {
      :MeteorShrapnel => {
        :delay => 3,
        :turntypeDamage => [:ROCK, :ROCKTOMB, 16, "Shrapnel from the approaching meteor crashed down!"],
        :queueDelays => [:MeteorShrapnel],
      },
    },
    :onEntryEffects => {
      :message => "<char>VIVIAN: That Deoxys summoned another meteorite... We have to stop it before it destroys all of Route 4!",
      :queueDelays => [:MeteorShrapnel],
    },
    :chargeAttack => {
      :turns => 20,
      :continueCharging => true,
      :canAttack => true,
      :chargeAttackMessage => "The meteor has reached Route 4!",
      :chargeAttackAnimation => :DRACOMETEOR,
    },
    :moninfo => {
      :species => :DEOXYS,
      :level => 65,
      :moves => [:SHADOWBALL, :SPIKES, :ICEBEAM, :LIGHTSCREEN],
      :nature => :NAIVE,
      :ability => :PRESSURE,
      :item => :FOCUSSASH,
      :form => 3,
      :iv => 31,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 1,
      :moninfos => {
        1 => {
          :species => :DEOXYS,
          :level => 65,
          :moves => [:LIGHTSCREEN, :REFLECT, :THUNDERWAVE, :SHADOWBALL],
          :item => :LEFTOVERS,
          :form => 4,
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Deoxys changed form!",
        :formchange => 3,
        :movesetUpdate => [:PSYCHOBOOST, :SUPERPOWER, :KNOCKOFF, :STEALTHROCK],
        :playersideChanges => {
          :Spikes => [1, :SPIKES, nil],
        },
      },
      2 => {
        :threshold => 0,
        :message => "Deoxys changed form!",
        :formchange => 1,
        :abilitychange => :PRESSURE,
        :movesetUpdate => [:LOWKICK, :SHADOWBALL, :ROCKSLIDE, :PSYCHOBOOST],
      },
      1 => {
        :threshold => 0,
        :message => "Deoxys changed form!",
        :bgmChange => "RSE - Boss_1",
        :animation => :MEGAEVOLUTION,
        :abilitychange => :PRESSURE,
        :formchange => 2,
        :movesetUpdate => [:PROTECT, :RECOVER, :KNOCKOFF, :TOXIC],
        :statDropCure => true,
      },
    },
  },

  :UMBRALZYGARDE => {
    :name => "Umbral Zygarde",
    :entryText => "Zygarde stands ready...",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :ZYGARDE,
      :level => 70,
      :moves => [:THOUSANDARROWS, :LANDSWRATH, :DRAGONTAIL, :COIL],
      :nature => :ADAMANT,
      :form => 1,
      :shiny => true,
      :ability => :AURABREAK,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "<char>VIVIAN: i'Ll rEpAiR It AlL wItH ZygArdE",
        :animation => :COREENFORCER,
        :formchange => 0,
        :shiny => true,
        :movesetUpdate => [:DRAGONDANCE, :THOUSANDARROWS, :LANDSWRATH, :REST],
      },
    },
  },

  :UMBRALREGIROCK => {
    :name => "Umbral Regirock",
    :entryText => "Regirock starts to shake...",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :REGIROCK,
      :level => 70,
      :moves => [:DRAINPUNCH, :BODYPRESS, :ROCKSLIDE, :EARTHQUAKE],
      :nature => :IMPISH,
      :shiny => true,
      :item => :LEFTOVERS,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 6",
      :continuous => true,
      :totalMonCount => 1,
      :moninfos => {
        1 => {
          :species => :REGIROCK,
          :level => 70,
          :moves => [:GLARE, :TOXIC, :FOLLOWME, :RECOVER],
          :name => "ADMIN",
          :item => :LEFTOVERS,
          :ability => :WONDERGUARD,
          :BaseStats => [1, 1, 1, 1, 1, 1],
          :form => 1,
        },
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>ADMIN: You are to protect your master... If she falls, you shall too.",
        :playersideChanges => {
          :StealthRock => [true, :STEALTHROCK, "Floating rocks were deployed!"],
        },
      },
      2 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>ADMIN: Without you, we shall not be equipped to weather the storm...",
        :weatherChange => [:SANDSTORM, -1, "Sandstorms keep brewing..."],
      },
      1 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>ADMIN: Our final stand...",
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
    }
  },

  :UMBRALXURKITREE => {
    :name => "Umbral Xurkitree",
    :entryText => "Xurkitree is surging with power.",
    :shieldCount => 4,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :XURKITREE,
      :level => 74,
      :moves => [:THUNDERBOLT, :EERIEIMPULSE, :ENERGYBALL, :ZAPCANNON],
      :nature => :IMPISH,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 3",
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :PELIPPER,
          :level => 70,
          :moves => [:AIRSLASH, :KNOCKOFF, :BRINE, :ROOST],
          :ability => :DRIZZLE,
        },
        2 => {
          :species => :SLOWBRO,
          :level => 70,
          :moves => [:YAWN, :PSYCHIC, :SLACKOFF, :GRASSKNOT],
          :ability => :OWNTEMPO,
        },
      },
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>KIERAN: cLeAr, wE nEeD tO KeEP aN eYe oN eDen. tHeY aRe DiVerGiNg.",
      },
      3 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>KIERAN: eDeN, lEaVe tHat gIrL AloNE... StAY fOCusEd ON tHe MisSiOn...",
        :fieldChange => :PSYTERRAIN,
      },
      2 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>KIERAN: eDeN... MaN... wHy dId YoU Go sO FaR?",
      },
      1 => {
        :threshold => 0,
        :effect => nil,
        :message => "Xurkitree caught fire! It changed into an Electric/Fire-type!",
        :typeChange => [:ELECTRIC, :FIRE],
        :fieldChange => :INFERNAL,
        :weatherChange => [:SUNNY, -1, "The fire emits a bright light..."],
        :movesetUpdate => [:INFERNALPARADE, :THUNDERBOLT, :EARTHPOWER, :THUNDERCAGE],
        :statDropCure => true,
      },
    },
  },

  :UMBRALMEOWTH => {
    :name => "Umbral Meowth",
    :entryText => "Meowth's long body fills the room!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :MEOWTH,
      :level => 80,
      :moves => [:FAKEOUT, :KNOCKOFF, :AERIALACE, :HONECLAWS],
      :nature => :IMPISH,
      :ability => :GOODASGOLD,
      :shiny => true,
      :form => 3,
      :item => :LEFTOVERS,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 1,
      :moninfos => {
        1 => {
          :species => :GHOLDENGO,
          :level => 60,
          :moves => [:MAKEITRAIN, :METALSOUND, :SHADOWBALL, :FLASHCANNON],
        },
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>ACE: gRaNdPapPY Is Sick!!!!!! GoTtA FiNd ThE cUrE fASt!!!!!!!",
        :typeChange => [:NORMAL, :POISON],
        :fieldChange => :WASTELAND,
        :animation => :TOXIC,
        :movesetUpdate => [:SLUDGEWAVE, :VENOMDRENCH, :FOULPLAY, :POWERWHIP],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
      2 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>ACE: cAN't fInD a CurE... BUUUT I goT a nIce Job...",
        :animation => :PAYDAY,
        :bossStatChanges => {
          PBStats::SPEED => 1,
        },
      },
      1 => {
        :threshold => 0,
        :effect => nil,
        :bgmChange => "Bad Mood - Hunt Side B",
        :message => "<char>ACE: I gOt PaId!!! gRanDpAPPy is SAVED!! eVeRyBoDy DaNcE",
        :typeChange => [:STEEL,:NORMAL],
        :fieldChange => :CONCERT4,
        :animation => :ENCORE,
        :movesetUpdate => [:MAKEITRAIN, :PAYDAY, :VICTORYDANCE, :EARTHQUAKE],
        :bossStatChanges => {
          PBStats::SPDEF => 1,
        },
      },
    }
  },

  :UMBRALNIGHTMARE => {
    :name => "Umbral Nightmare",
    :entryText => "<char>SHAYDA: ...? wHo tHe HeLl iS tHiS mAn??!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :DARKRAI,
      :level => 70,
      :form => 8,
      :moves => [:SPIRITBREAK, :PSYCHIC, :AURORAVEIL, :THROATCHOP],
      :nature => :BRAVE,
      :shiny => true,
      :item => :PSYCHICGEM,
      :happiness => 0,
    },
    :delayedactions => {
      :TurtleSaysNightmares => {
        :delay => 12,
        :fieldChange => :NEWWORLD,
        :playerSideStatusChanges => [:SLEEP, "Sleep"],
        :message => "All fall to the Puppet Master's sway...",
        :playerEffects => {
          :Nightmare => [true, :NIGHTMARE, "<char>EIZEN: My turtle says you are going to experience some nightmares now."],
        },
      },
    },
    :onEntryEffects => {
      :fieldChange => :STARLIGHT,
      :message => "<char>EIZEN: I believe this is the part where you fall asleep.",
      :queueDelays => [:TurtleSaysNightmares],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "<char>EIZEN: No fairy tale, but this isn't reality either.",
        :bgmChange => "Battle - Inconsistent_sea",
        :movesetUpdate => [:DARKPULSE, :FLAMETHROWER, :PSYSHOCK, :MOONLIGHT],
        :itemchange => :ROSELIBERRY,
      },
      1 => {
        :threshold => 0,
        :message => "<char>EIZEN: My turtle just growled at you.",
        :movesetUpdate => [:BULLETPUNCH, :COMETPUNCH, :THROATCHOP, :PSYSTRIKE],
      },
    },
  },

  :UMBRALANGEL => {
    :name => "Umbral Angel",
    :entryText => "<char>EIZEN: I'll take it from here.",
    :shieldCount => 2,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :GARDEVOIR,
      :level => 70,
      :form => 3,
      :shiny => true,
      :moves => [:DARKPULSE, :LOVELYKISS, :DAZZLINGGLEAM, :HYPERVOICE],
      :gender => :F,
      :nature => :SERIOUS,
      :happiness => 255,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :animation => :SECRETSWORD,
        :message => "<char>EIZEN: The Angel of Death wishes to see you.",
        :bgmChange => "Battle - Inconsistent_sea",
        :movesetUpdate => [:NIGHTSLASH, :LOVELYKISS, :SPIRITBREAK, :SLASH],
      },
      1 => {
        :threshold => 0,
        :animation => :DARKPULSE,
        :message => "<char>EIZEN: How furious... Is this how you treat a lady?",
        :movesetUpdate => [:HYPERSPACEFURY, :MOONBLAST, :EARTHQUAKE, :SCREECH],
      },
    },
  },
  #

  :RIFTGARBODOR => {
    :name => "Rift Garbodor",
    :entryText => "The rampaging Rift Garbodor attacked!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :GARBODOR,
      :level => 57,
      :item => :BLACKSLUDGE,
      :moves => [:DRAINPUNCH, :BULLETSEED, :BRUTALSWING, :SLUDGEWAVE],
      :nature => :SASSY,
      :shiny => true,
      :form => 2,
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Garbodor gorged itself on rotten berries!",
        :typeChange => [:POISON, :GRASS],
        :movesetUpdate => [:DRAINPUNCH, :GIGADRAIN, :BRUTALSWING, :BELCH],
        :itemchange => :SITRUSBERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
        :statDropCure => true,
      },
      2 => {
        :threshold => 0,
        :message => "Garbodor gorged itself on scrap metal!",
        :typeChange => [:POISON, :STEEL],
        :movesetUpdate => [:DRAINPUNCH, :GIGADRAIN, :MAGNETBOMB, :BELCH],
        :itemchange => :METALCOAT,
        :bossStatChanges => {
          PBStats::SPDEF => 1,
        },
        :statDropCure => true,
      },
      1 => {
        :threshold => 0,
        :message => "Garbodor desperately gorged itself on nearby rocks!",
        :typeChange => [:POISON, :ROCK],
        :movesetUpdate => [:ROCKBLAST, :GIGADRAIN, :MAGNETBOMB, :BELCH],
        :itemchange => :ROCKYHELMET,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => -2,
          PBStats::SPATK => 1,
          PBStats::SPDEF => -2,
        },
        :statDropCure => true,
      },
    },
  },

  :RIFTAELITA => {
    :name => "Rift Aelita",
    :entryText => "Rift Aelita is taking aim...",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :REGIROCK,
      :level => 70,
      :item => :LIFEORB,
      :moves => [:ROCKBLAST, :ARMTHRUST, :BULLETSEED, :BARRAGE],
      :nature => :NAUGHTY,
      :form => 2,
      :iv => 31,
    },
    :delayedactions => {
      :SniperShot => {
        :delay => 5,
        :message => "Rift Aelita is cocking her gun...",
        :animation => :LASERFOCUS,
        :bossEffect => {
          :LaserFocus => [1, nil, nil],
        },
        :queueDelays => [:SniperShot],
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Rift Aelita is cocking her gun...",
        :animation => :LASERFOCUS,
        :bossEffect => {
          :LaserFocus => [1, nil, nil],
        },
        :fieldChange => :ROCKY,
        :fieldChangeMessage => "The field became littered with rocks!",
        :movesetUpdate => [:ROCKBLAST, :BULLDOZE, :POLLENPUFF, :SHADOWBALL],
        :bossStatChanges => {
          PBStats::ACCURACY => 1,
        },
        :queueDelays => [:SniperShot],
      },
      2 => {
        :threshold => 0,
        :message => "Aelita let out a piercing screech!",
        :movesetUpdate => [:ROCKWRECKER, :AURASPHERE, :ACIDSPRAY, :ENERGYBALL],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => -1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => -1,
        },
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
      },
    },
  },

  :VIVIANREGIROCK => {
    :name => "Stone Guardian",
    :entryText => "The Stone Guardian attacked!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :REGIROCK,
      :level => 68,
      :shiny => true,
      :moves => [:DRAINPUNCH, :SUPERPOWER, :ROCKSLIDE, :EARTHQUAKE],
      :nature => :IMPISH,
      :iv => 31,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :effect => nil,
        :message => "Regirock drew power from the earth...",
        :itemchange => :ROCKIUMZ,
        :sideChanges => :StealthRock,
        :playersideChangeCount => true,
        :sideChangeAnimation => :STEALTHROCK,
        :sideChangesSide => 0,
        :sideChangeMessage => "Floating rocks were deployed!",
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
      },
    },
  },

  :RIFTFERROTHORN => {
    :name => "Rift Ferrothorn",
    :entryText => "Rift Ferrothorn is readying to attack!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :FERROTHORN,
      :level => 70,
      :moves => [:SEEDBOMB, :LEECHSEED, :GYROBALL, :FIRELASH],
      :nature => :BRAVE,
      :form => 1,
      :iv => 31,
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :bosssideChanges => {
          :Reflect => [3, :REFLECT, nil],
          :LightScreen => [3, nil, "Rift Ferrothorn put up defenses!"],
        },
      },
      2 => {
        :threshold => 0,
        :effect => nil,
        :message => "Rift Ferrothorn became unrestrained!",
        :bgmChange => "Battle - Pseudo Contribution",
        :movesetUpdate => [:FLAREBLITZ, :ENERGYBALL, :IRONHEAD, :SHIFTGEAR],
        :formchange => 2,
        :statDropCure => true,
      },
      1 => {
        :threshold => 0,
        :effect => nil,
        :message => "Rift Ferrothorn is out of control!",
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => -2,
          PBStats::SPATK => 1,
          PBStats::SPDEF => -2,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :RIFTHIPPOWDON => {
    :name => "Rift Hippowdon",
    :entryText => "Rift Hippowdon is filling the arena with sand!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :HIPPOWDON,
      :level => 80,
      :form => 1,
      :moves => [:SPITUP, :HEATWAVE, :EARTHPOWER, :SLUDGEBOMB],
      :gender => :F,
      :nature => :RELAXED,
      :item => :BLACKSLUDGE,
      :iv => 31,
      :happiness => 0,
    },
    :delayedactions => {
      :SearingSandstorm => {
        :delay => 4,
        :message => "The searing sands inflicted burns!",
        :playerSideStatusChanges => [:BURN, "Burn"],
        :queueDelays => [:SearingSandstorm],
      },
      :SandBoost => {
        :delay => 5,
        :message => "Rift Hippowdon is burning up!",
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
    },
    :onEntryEffects => {
      :animation => :SCORCHINGSANDS,
      :message => "The whirling sands are scorching!",
      :queueDelays => [:SearingSandstorm],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Rift Hippowdon shot sand everywhere!",
        :movesetUpdate => [:SPITUP, :EARTHQUAKE, :GUNKSHOT, :FLAMETHROWER],
        :weatherChange => [:SANDSTORM, -1, "Sandstorms keep brewing..."],
        :playersideChanges => {
          :StealthRock => [true, :STEALTHROCK, nil],
        },
      },
      1 => {
        :threshold => 0,
        :statDropCure => true,
        :statusCure => true,
        :message => "The arena is heating up more!",
        :animation => :INFERNO,
        :movesetUpdate => [:SPITUP, :EARTHPOWER, :DRAGONPULSE, :HEATWAVE],
        :weatherChange => [:SANDSTORM, -1, "Sandstorms keep brewing..."],
        :typeChange => [:GROUND, :FIRE],
        :itemchange => :SITRUSBERRY,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, nil],
        },
        :queueDelays => [:SandBoost],
      },
    },
  },

  :ANGELOFDEATH => {
    :name => "Angel of Death",
    :entryText => "The Angel of Death appears with bloodlust...",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :GARDEVOIR,
      :level => 70,
      :form => 3,
      :moves => [:DARKPULSE, :SWEETKISS, :DAZZLINGGLEAM, :MYSTICALFIRE],
      :gender => :F,
      :nature => :SERIOUS,
      :item => :LUMBERRY,
      :iv => 10,
      :happiness => 255,
      :ev => [35, 35, 35, 35, 35, 35],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 3",
      :continuous => true,
      :totalMonCount => 4,
      :moninfos => {
        1 => {
          :species => :RALTS,
          :level => 70,
          :form => 1,
          :moves => [:TORMENT, :HELPINGHAND, :POISONGAS, :NIGHTSHADE],
          :gender => :F,
          :iv => 10,
        },
        2 => {
          :species => :KIRLIA,
          :level => 70,
          :form => 1,
          :moves => [:QUASH, :HELPINGHAND, :WILLOWISP, :SNARL],
          :gender => :F,
          :iv => 10,
        },
      },
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :animation => :SECRETSWORD,
        :message => "The Angel of Death drew its scythe.",
        :movesetUpdate => [:NIGHTSLASH, :SWEETKISS, :SPIRITBREAK, :PSYCHOCUT],
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
        },
      },
      3 => {
        :threshold => 0,
        :animation => :DAZZLINGGLEAM,
        :message => "The Angel of Death summoned minions.",
        :movesetUpdate => [:NIGHTSLASH, :PROTECT, :LAVAPLUME, :SACREDSWORD],
        :playerSideStatChanges => {
          PBStats::SPATK => -1,
        },
      },
      2 => {
        :threshold => 0,
        :animation => :CHARGE,
        :message => "The Angel of Death is summoning power.",
        :movesetUpdate => [:DARKPULSE, :PSYCHOCUT, :BULLDOZE, :AURASPHERE],
      },
      1 => {
        :threshold => 0,
        :animation => :DARKPULSE,
        :message => "The Angel of Death has fury.",
        :movesetUpdate => [:HYPERSPACEFURY, :DAZZLINGGLEAM, :TAUNT, :HYPERVOICE],
      },
    }
  },

  :FALLENANGEL => {
    :name => "Fallen Angel",
    :entryText => "The Angel is on its last legs...",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :GARDEVOIR,
      :level => 70,
      :form => 4,
      :moves => [:LASHOUT, :BURNINGJEALOUSY, :HYPERSPACEHOLE, :THRASH],
      :gender => :F,
      :nature => :LONELY,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :onBreakEffects => {},
  },

  :BOSSARCEUS_CASINO => {
    :name => "Casino Bouncer",
    :entryText => "STOP! You've violated the law! Pay the court a fine or serve your sentence. Your stolen goods are now forfeit.",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :ARCEUS,
      :level => 70,
      :moves => [:JUDGMENT, :PUNISHMENT, :EXTREMESPEED, :LIQUIDATION],
      :nature => :LONELY,
      :ability => :MULTITYPE,
      :item => :FISTPLATE,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "STOP! You've violated the law! Pay the court a fine or serve your sentence. Your stolen goods are now forfeit.",
        :animation => :COSMICPOWER,
      },
    },
  },

  :NIGHTMAREREMIX => {
    :name => "Nightmare Remix",
    :entryText => "The... Puppet Master? Attacks?",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :DARKRAI,
      :level => 70,
      :form => 8,
      :moves => [:SPIRITBREAK, :PSYCHIC, :AURORAVEIL, :THROATCHOP],
      :nature => :BRAVE,
      :happiness => 0,
    },
    :delayedactions => {
      :NightmareEternal => {
        :delay => 5,
        :fieldChange => :NEWWORLD,
        :playerSideStatusChanges => [:SLEEP, "Sleep"],
        :message => "All fall to the Puppet Master's sway...",
        :playerEffects => {
          :Nightmare => [true, :NIGHTMARE, "Now, sleep with this trauma that will leave you sleepless!"],
        },
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
        },
      },
    },
    :onEntryEffects => {
      :fieldChange => :STARLIGHT,
      :message => "Twinkle twinkle little star...",
      :queueDelays => [:NightmareEternal],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Grow weary...",
        :movesetUpdate => [:MOONBLAST, :ICEBEAM, :EARTHQUAKE, :PROTECT],
        :itemchange => :LEFTOVERS,
        :animation => :HYPNOSIS,
        :playerSideStatChanges => {
          PBStats::ATTACK => -3,
          PBStats::SPATK => -3,
        },
      },
      2 => {
        :threshold => 0,
        :message => "Don't sleep... Don't wake up...",
        :movesetUpdate => [:DOOMDESIRE, :VACUUMWAVE, :DARKPULSE, :ANCIENTPOWER],
        :statDropCure => true,
        :statusCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "Welcome the end...",
        :movesetUpdate => [:METEORMASH, :COMETPUNCH, :THROATCHOP, :PSYSTRIKE],
        :statDropCure => true,
      },
    },
  },

  :BIGBETTY => {
    :name => "Big Betty",
    :entryText => "Big Betty stands her ground!",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :EMBOAR,
      :level => 76,
      :moves => [:EARTHQUAKE, :HEADSMASH, :FLAREBLITZ, :WILLOWISP],
      :ability => :BLAZE,
      :gender => :F,
      :form => 2,
      :nature => :ADAMANT,
      :iv => 31,
    },
    :onBreakEffects => {},
  },

  :BIGBETTYTWO => {
    :name => "Big Betty",
    :entryText => "Big Betty stands her ground... again!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :EMBOAR,
      :level => 78,
      :moves => [:EARTHQUAKE, :HEADSMASH, :FLAREBLITZ, :WILLOWISP],
      :ability => :BLAZE,
      :gender => :F,
      :form => 2,
      :nature => :ADAMANT,
      :iv => 31,
    },
    :onEntryEffects => {
      :fieldChange => :FAIRYTALE,
      :fieldChangeMessage => "Goomink's resolve manifested!"
    },
    :onBreakEffects => {},
  },

  :BOSSZEKROM => {
    :name => "Fanciful Ideals",
    :entryText => "Zekrom is crackling with electricity!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :ZEKROM,
      :level => 85,
      :moves => [:FOCUSBLAST, :REFLECT, :BOLTSTRIKE, :OUTRAGE],
      :ability => :TERAVOLT,
      :nature => :NAIVE,
      :iv => 31,
    },
    :onBreakEffects => {},
  },

  :BOSSRESHIRAM => {
    :name => "Imaginary Truths",
    :entryText => "Reshiram is blazing with fire!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :RESHIRAM,
      :level => 85,
      :moves => [:DRAGONCLAW, :FUSIONFLARE, :LIGHTSCREEN, :CRUNCH],
      :ability => :TURBOBLAZE,
      :nature => :TIMID,
      :iv => 31,
    },
    :onBreakEffects => {},
  },

  :BOSSNAGANADEL => {
    :name => "Naganadel",
    :entryText => "Naganadel is ready to kill!",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :NAGANADEL,
      :level => 87,
      :item => :LIFEORB,
      :moves => [:SLUDGEWAVE, :DRAGONPULSE, :TOXIC, :NASTYPLOT],
      :ability => :BEASTBOOST,
      :nature => :TIMID,
      :iv => 31,
      :happiness => 0,
    },
    :onBreakEffects => {},
  },

  :BOSSGOTHITELLE => {
    :name => "Gothitelle",
    :entryText => "Gothitelle is looking serious!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :GOTHITELLE,
      :level => 86,
      :item => :GOTHCREST,
      :moves => [:GRAVITY, :THUNDERBOLT, :PSYCHIC, :DARKPULSE],
      :ability => :SHADOWTAG,
      :gender => :F,
      :nature => :MODEST,
      :form => 1,
    },
    :onBreakEffects => {},
  },

  :STORMNINE => {
    :name => "STORM | Wind",
    :entryText => "Erratic weather begets a disaster...",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :XERNEAS,
      :level => 80,
      :item => :LIFEORB,
      :moves => [:WEATHERBALL, :HURRICANE, :THUNDERBOLT, :PSYSHOCK],
      :ability => :TEMPEST,
      :nature => :MODEST,
      :form => 1,
      :iv => 31,
    },
    :onBreakEffects => {},
  },

  :BOSSCOFAGRIGUS => {
    :name => "Totem Cofagrigus",
    :entryText => "The menacing Cofagrigus attacked!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :COFAGRIGUS,
      :level => 80,
      :moves => [:SHADOWBALL, :NASTYPLOT, :WILLOWISP, :ENERGYBALL],
      :hptype => :FIGHTING,
      :ability => :MUMMY,
      :gender => :M,
      :nature => :MODEST,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :totalMonCount => 4,
      :moninfos => {
        1 => {
          :species => :STANTLER,
          :level => 75,
          :item => :STANTCREST,
          :moves => [:HYPNOSIS, :MEGAHORN, :JUMPKICK, :ZENHEADBUTT],
          :ability => :INTIMIDATE,
          :gender => :F,
          :nature => :JOLLY,
          :happiness => 255,
        },
        2 => {
          :species => :MAGCARGO,
          :level => 75,
          :item => :MAGCREST,
          :moves => [:FLAMEBURST, :YAWN, :EARTHPOWER, :WILLOWISP],
          :ability => :FLAMEBODY,
          :gender => :M,
          :nature => :BOLD,
          :happiness => 255,
        },
        3 => {
          :species => :LEAFEON,
          :level => 75,
          :item => :LEAFCREST,
          :moves => [:SWORDSDANCE, :NATUREPOWER, :LEAFBLADE, :XSCISSOR],
          :ability => :LEAFGUARD,
          :gender => :F,
          :nature => :ADAMANT,
          :happiness => 255,
        },
      },
    },
    :delayedactions =>{
      :PharaohsCurse => {
        :delay => 5,
        :message => "Beware the Pharaoh's curse!",
        :playerEffects => {
          :Curse => [true, :CURSE, nil],
        },
        :queueDelays => [:PharaohsCurse],
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Sand swarms all around!",
        :bosssideChanges => {
          :AreniteWall => [5, :ARENITEWALL, nil],
        },
        :movesetUpdate => [:SHADOWBALL, :BODYPRESS, :CALMMIND, :PSYCHIC],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
      1 => {
        :threshold => 0,
        :movesetUpdate => [:SHADOWBALL, :PROTECT, :ENERGYBALL, :HIDDENPOWER],
        :statDropCure => true,
        :itemchange => :LEFTOVERS,
        :queueDelays => [:PharaohsCurse],
      },
    },
  },

  :COFFEEGREGUS => {
    :name => "COFFEE GREGUS",
    :entryText => "COFFEE GREGUS!",
    :shieldCount => 3,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :COFAGRIGUS,
      :level => 80,
      :moves => [:SHADOWPUNCH, :COMETPUNCH, :BULLETPUNCH, :HOWL],
      :gender => :M,
      :nature => :MODEST,
      :form => 1,
      :happiness => 255,
    },
    :delayedactions =>{
      :DodgingIsCheating => {
        :delay => 2,
        :playerEffects => {
          :Foresight => [true, :FORESIGHT, "THERE IS NO ESCAPE FROM COFFEE GREGUS!"],
        },
        :playerSideStatChanges => {
          PBStats::EVASION => -1,
        },
        :queueDelays => [:DodgingIsCheating],
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :movesetUpdate => [:SHADOWPUNCH, :SCORCHINGSANDS, :AURASPHERE, :HOWL],
        :message => "COFFEE GREGUS!",
        :animation => :BULKUP,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
        :fieldChange => :BIGTOP,
        :fieldChangeMessage => "CLOWN FIESTA!"
      },
      2 => {
        :threshold => 0,
        :movesetUpdate => [:SHADOWPUNCH, :DYNAMICPUNCH, :BODYPRESS, :HOWL],
        :message => "COFFEE GREGUS!",
        :animation => :BULKUP,
        :statDropCure => true,
        :effectClear => true,
        :queueDelays => [:DodgingIsCheating],
      },
    },
  },

  :KAWOPUDUNGA => {
    :name => "Kawopudunga",
    :entryText => "Kawopudunga is ready to feast!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :WAILORD,
      :level => 70,
      :form => 1,
      :moves => [:DIVE, :DARKESTLARIAT, :AQUARING, :FRUSTRATION],
      :gender => :F,
      :nature => :HARDY,
      :item => :SITRUSBERRY,
      :iv => 31,
      :happiness => 0,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :itemchange => :SITRUSBERRY,
        :message => "Kawopudunga changed its type!",
        :movesetUpdate => [:DIVE, :OUTRAGE, :DRAGONDANCE, :HEAVYSLAM],
        :typeChange => [:WATER, :DRAGON],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 2,
        },
      },
      1 => {
        :threshold => 0,
        :itemchange => :SITRUSBERRY,
        :message => "Kawopudunga changed its type!",
        :movesetUpdate => [:DIVE, :DARKPULSE, :RECOVER, :TOXIC],
        :typeChange => [:WATER, :DARK],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::SPATK => 2,
        },
      },
    }
  },

  :BOSSGOURGEIST => {
    :name => "Jack-o'-lantern",
    :entryText => "A large pumpkin suddenly attacked!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :GOURGEIST,
      :level => 75,
      :form => 1,
      :moves => [:WILLOWISP, :SEEDBOMB, :LEECHSEED, :CURSE],
      :gender => :F,
      :ability => :INSOMNIA,
      :nature => :BRAVE,
      :item => :SITRUSBERRY,
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "The Jack-o'-lantern was lit up!",
        :movesetUpdate => [:FLAMETHROWER, :ENERGYBALL, :DISABLE, :ROCKSLIDE],
        :typeChange => [:GRASS, :FIRE],
        :abilitychange => :FLASHFIRE,
        :itemchange => :ELEMENTALSEED,
        :fieldChange => :GRASSY,
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
      },
      2 => {
        :threshold => 0,
        :movesetUpdate => [:GIGADRAIN, :LEECHSEED, :MYSTICALFIRE, :PHANTOMFORCE],
        :bossStatChanges => {
          PBStats::SPDEF => 1,
        },
      },
      1 => {
        :threshold => 0,
        :movesetUpdate => [:GRASSYGLIDE, :ROCKSLIDE, :SYNTHESIS, :SHADOWSNEAK],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
    }
  },

  :BOSSKECLEON => {
    :name => "Wacky Lizard",
    :entryText => "Wacky Lizard's staring into space.",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :KECLEON,
      :level => 80,
      :form => 0,
      :moves => [:PLAYROUGH, :THUNDERPUNCH, :BOUNCE, :EARTHQUAKE],
      :gender => :F,
      :ability => :SHEERFORCE,
      :nature => :BRAVE,
      :item => :SITRUSBERRY,
      :iv => 31,
      :happiness => 0,
    },
    :delayedactions =>{
      :WackyTypeShift => {
        :delay => 1,
        :loopingsetchanges => true,
        :itemchange => :LIFEORB,
        :message => "Wacky Lizard's type shifted!",
        :typeSequence => {
          1 => {
            :typeChange => [:FLYING, :FLYING],
          },
          2 => {
            :typeChange => [:ELECTRIC, :FLYING],
          },
          3 => {
            :typeChange => [:GROUND, :FLYING],
          },
          4 => {
            :typeChange => [:FAIRY, :FLYING],
          },
        },
        :queueDelays => [:WackyTypeShift],
      }
    },
    :onEntryEffects => {
      :queueDelays => [:WackyTypeShift],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :statDropCure => true,
        :bossStatChanges => {},
      },
    },
  },

  :DUFAUX => {
    :name => "Dufaux",
    :entryText => "The Clefairy doll attacked!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :FROSLASS,
      :level => 85,
      :form => 2,
      :moves => [:POISONGAS, :THUNDERBOLT, :ICEBEAM, :MOONBLAST],
      :gender => :F,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 0,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Dufaux attempted to repair itself...",
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, nil],
        },
        :itemchange => :MAGICALSEED,
        :statDropCure => true,
        :statusCure => true,
        :bossStatChanges => {
          PBStats::SPATK => -1,
        }
      },
      1 => {
        :threshold => 0,
        :itemchange => :MAGNET,
        :message => "Dufaux broke out of its shell!",
        :movesetUpdate => [:SLUDGEBOMB, :DISCHARGE, :BLIZZARD, :WILLOWISP],
        :statDropCure => true,
        :formchange => 3,
        :weatherChange => [:SNOWSCAPE, -1, nil],
        :playerSideStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => -1,
          PBStats::SPATK => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => -1,
        },
      },
    },
  },

  :MECHAGYARADOS => {
    :name => "GYARA-01",
    :entryText => "WARNING! WARNING! WARNING!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :GYARADOS,
      :level => 86,
      :form => 3,
      :moves => [:THUNDERBOLT, :HYPERBEAM, :FLAMETHROWER, :SCALD],
      :gender => :F,
      :nature => :HARDY,
      :iv => 31,
      :happiness => 0,
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "DESTRUCTION MODE ENGAGED!",
        :movesetUpdate => [:STEELBEAM, :MINDBLOWN, nil, nil],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
      },
      2 => {
        :threshold => 0,
        :message => "COOLING DOWN...",
        :movesetUpdate => [:HYPERVOICE, :ICEBEAM, :IRONHEAD, :DOUBLEEDGE],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPEED => -1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "SELF-DESTRUCT SEQUENCE ACTIVATED!",
        :movesetUpdate => [:EXPLOSION, nil, nil, nil],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 6,
        },
      },
    },
  },

  :MASTEROFNIGHTMARES => {
    :name => "Master of Nightmares",
    :entryText => "The battle against nightmares has begun.",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :DARKRAI,
      :level => 85,
      :form => 3,
      :moves => [:THUNDERBOLT, :LOWKICK, :BUNRAKUBEATDOWN, :NIGHTMARE],
      :nature => :BRAVE,
      :happiness => 0,
    },
    :delayedactions =>{
      :ElectroShock => {
        :delay => 1,
        :playerSideStatusChanges => [:PARALYSIS, "Paralysis"],
      },
      :SleepNow => {
        :delay => 1,
        :playerEffects => {
          :Yawn => [1, :YAWN, "A strong feeling of drowsiness..."],
        },
      },
    },
    :onEntryEffects => {
      :animation => :IONDELUGE,
      :fieldChange => :ELECTERRAIN,
      :fieldChangeMessage => "Aelita's nightmares manifest into reality...",
      :queueDelays => [:ElectroShock],
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :message => "Memories of being burned alive pass by...",
        :movesetUpdate => [:LAVAPLUME, :BULLDOZE, :BUNRAKUBEATDOWN, :NIGHTMARE],
        :formchange => 4,
        :animation => :ERUPTION,
        :playerSideStatusChanges => [:BURN, "Burn"],
        :playerEffects => {
          :TarShot => [true, :TARSHOT, "You feel highly flammable..."],
        },
        :fieldChange => :VOLCANICTOP,
      },
      3 => {
        :threshold => 0,
        :message => "The feeling of an explosion creeps up your spine...",
        :movesetUpdate => [:DAZZLINGGLEAM, :SACREDSWORD, :BUNRAKUBEATDOWN, :NIGHTMARE],
        :formchange => 5,
        :animation => :EXPLOSION,
        :fieldChange => :DIMENSIONAL,
        :bossStatChanges => {
          PBStats::SPDEF => 1,
        },
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1
        }
      },
      2 => {
        :threshold => 0,
        :message => "You feel death incarnate staring you down...",
        :movesetUpdate => [:AIRSLASH, :DARKPULSE, :BUNRAKUBEATDOWN, :NIGHTMARE],
        :formchange => 6,
        :fieldChange => :CHESS,
        :animation => :DECIMATION,
        :playerEffects => {
          :PerishSong => [3, :PERISHSONG, "Death is imminent..."],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "The true nightmare begins.",
        :movesetUpdate => [:BUNRAKUBEATDOWN, :DARKPULSE, :SHADOWBALL, :THUNDERCAGE],
        :formchange => 2,
        :statDropCure => true,
        :fieldChange => :NEWWORLD,
        :animation => :NIGHTDAZE,
        :queueDelays => [:SleepNow],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
        },
        :itemchange => :GHOSTIUMZ,
      },
    }
  },

  :MASTEROFNIGHTMARES2 => {
    :name => "Master of Nightmares",
    :entryText => "The nightmare will end soon.",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :DARKRAI,
      :level => 80,
      :moves => [:BUNRAKUBEATDOWN, :NIGHTMARE, :TAUNT, :SHADOWCLAW],
      :nature => :MODEST,
      :form => 7,
      :iv => 31,
    },
    :onBreakEffects => {},
  },

  :BOSSKLINKLANG => {
    :name => "Klinklang Queen",
    :entryText => "<char>KLINKLANG: Ohohoho!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :KLINKLANG,
      :level => 82,
      :form => 1,
      :moves => [:SHIFTGEAR, :GEARGRIND, :FACADE, :WILDCHARGE],
      :nature => :ADAMANT,
      :ability => :CLEARBODY,
      :item => :LEFTOVERS,
      :iv => 31,
      :happiness => 0,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "The Klinklang Queen revs up!",
        :statusCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPEED => 1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "Gears appear all around!",
        :movesetUpdate => [:SUBSTITUTE, :GEARGRIND, :FACADE, :WILDCHARGE],
        :fieldChange => :FACTORY,
        :bossStatChanges => {
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :GERBIL2 => {
    :name => "Suicune",
    :entryText => "Suicune appeared before you!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :capturable => true,
    :moninfo => {
      :species => :SUICUNE,
      :level => 80,
      :form => 0,
      :moves => [:AQUARING, :EXTRASENSORY, :SCALD, :CALMMIND],
      :ability => :PRESSURE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :bgmChange => "Battle - Final Endeavor",
        :threshold => 0,
        :message => "",
        :abilitychange => :PRESSURE,
        :fieldChange => :UNDERWATER,
        :fieldChangeMessage => "Suicune changed reality around it!",
        :statusCure => true,
        :statDropCure => true,
        :movesetUpdate => [:SURF, :ICEBEAM, :EXTRASENSORY, :CALMMIND],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
    },
  },

  :GERBIL3 => {
    :name => "Raikou",
    :entryText => "Raikou appeared before you!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :capturable => true,
    :moninfo => {
      :species => :RAIKOU,
      :level => 80,
      :form => 0,
      :moves => [:THUNDERBOLT, :AURASPHERE, :SCALD, :CALMMIND],
      :ability => :PRESSURE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :bgmChange => "Battle - Final Endeavor",
        :threshold => 0,
        :message => "",
        :weatherChange => [:RAINDANCE, 5, nil],
        :fieldChange => :ELECTERRAIN,
        :fieldChangeMessage => "Raikou changed reality around it!",
        :statusCure => true,
        :statDropCure => true,
        :movesetUpdate => [:THUNDERBOLT, :WEATHERBALL, :AURASPHERE, :EXTREMESPEED],
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
      },
    },
  },

  :TIEMPAGOOD => {
    :name => "Tiempa",
    :entryText => "Tiempa is looking ready to attack!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :DIALGA,
      :level => 85,
      :form => 0,
      :item => :ADAMANTORB,
      :moves => [:EARTHPOWER, :FLASHCANNON, :POWERGEM, :DRAGONPULSE],
      :ability => :PRESSURE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
    },
    :delayedactions => {
      :SlowTime => {
        :delay => 3,
        :message => "Tiempa slows down movement!",
        :animation => :FAIRYLOCK,
        :playerSideStatChanges => {
          PBStats::SPEED => -1,
        },
        :queueDelays => [:SlowTime],
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Tiempa twisted time around the field!",
        :statusCure => true,
        :statDropCure => true,
        :itemchange => :ADAMANTORB,
        :movesetUpdate => [:EARTHPOWER, :FLASHCANNON, :AURASPHERE, :ROAROFTIME],
        :playerSideStatChanges => {
          PBStats::SPEED => -1,
        },
        :queueDelays => [:SlowTime],
      },
    },
  },

  :SPACEAGOOD => {
    :name => "Spacea",
    :entryText => "Spacea is finishing what Tiempa started!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :PALKIA,
      :level => 85,
      :form => 0,
      :item => :LUSTROUSORB,
      :moves => [:SURF, :THUNDERBOLT, :DRAGONPULSE, :FLAMETHROWER],
      :ability => :PRESSURE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 2",
      :totalMonCount => 1,
      :playerMons => true,
      :moninfos => {
        1 => {
          :species => :MINIOR,
          :level => 90,
          :form => 0,
          :moves => [:ROCKSLIDE, :CONFUSERAY, :ACROBATICS, :LIGHTSCREEN],
          :ability => :SHIELDSDOWN,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :statDropCure => true,
        :movesetUpdate => [:THUNDER, :FIREBLAST, :SPACIALREND, :HYDROPUMP],
        :itemchange => :LUSTROUSORB,
        :statchanges => :Gravity,
        :stateChangeAnimation => :GRAVITY,
        :stateChangeCount => 99,
        :stateChangeMessage => "The space around was contorted!",
        :bossStatChanges => {},
      },
      1 => {
        :message => "<char>SPACEA: No more... NO... MORE!!!!!!!",
        :animation => :FLASH,
        :bgmChange => "Battle - End of Night",
        :threshold => 0,
        :formchange => 1,
        :statusCure => true,
        :statDropCure => true,
        :itemchange => :LUSTROUSGLOBE,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 1,
        },
      },
    },
  },

  :SPACEABAD => {
    :name => "Spacea",
    :entryText => "Spacea is looking ready to attack!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :PALKIA,
      :level => 90,
      :form => 0,
      :item => :LUSTROUSORB,
      :moves => [:SURF, :DRAGONPULSE, :FLAMETHROWER, :THUNDERBOLT],
      :ability => :PRESSURE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 1",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :MINIOR,
          :level => 85,
          :item => :FLYINGGEM,
          :moves => [:ROCKSLIDE, :CONFUSERAY, :ACROBATICS, :LIGHTSCREEN],
          :ability => :SHIELDSDOWN,
        },
        2 => {
          :species => :CLEFAIRY,
          :level => 85,
          :item => :EVIOLITE,
          :moves => [:FOLLOWME, :HELPINGHAND, :MOONBLAST, :REFLECT],
          :ability => :FRIENDGUARD,
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Spacea twisted the space around the field!",
        :statusCure => true,
        :statDropCure => true,
        :itemchange => :LUSTROUSORB,
        :movesetUpdate => [:HYDROPUMP, :SPACIALREND, :FIREBLAST, :THUNDER],
        :bossStatChanges => {
          PBStats::SPATK => 1,
          PBStats::SPEED => 1,
        },
        :playerSideStatChanges => {
          PBStats::SPEED => -1,
        },
      },
    },
  },

  :TIEMPABAD => {
    :name => "Tiempa",
    :entryText => "Tiempa is finishing what Spacea started!",
    :shieldCount => 3,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => []
    },
    :moninfo => {
      :species => :DIALGA,
      :level => 90,
      :form => 0,
      :item => :ADAMANTORB,
      :moves => [:POWERGEM, :ROAROFTIME, :FLASHCANNON, :EARTHPOWER],
      :ability => :PRESSURE,
      :nature => :MODEST,
      :happiness => 255,
    },
    :delayedactions => {
      :FixtureInTime => {
        :delay => 1,
        :CustomMethod => "battlesnapshot(battler,2,-1)",
        :message => "Tiempa is focusing on the flow of time!",
        :bossStatChanges => {
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
        },
      },
      :RewindTime => {
        :delay => 9,
        :message => "<char>TIEMPA: You are wasting your time, Interceptor...",
        :CustomMethod => "timewarp(battler,2)",
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :statDropCure => true,
        :itemchange => :ADAMANTORB,
      },
      1 => {
        :CustomMethod => "battlesnapshot(battler,1,1)",
      },
      0 => {
        :CustomMethod => "timewarp(battler,1)",
        :movesetUpdate => [:FLAMETHROWER, :ROAROFTIME, :FLASHCANNON, :ICEBEAM],
        :queueDelays => [:FixtureInTime, :RewindTime],
        :message => "<char>TIEMPA: No more... NO... MORE!!!!!!!",
        :animation => :FLASH,
        :bgmChange => "Battle - End of Night",
        :threshold => 0,
        :formchange => 1,
        :statusCure => true,
        :statDropCure => true,
        :itemchange => :ADAMANTCRYSTAL,
      },
    },
  },

  :BOSSRATICATE => {
    :name => "Monstrosity",
    :entryText => "The grotesque rodent attacked!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :RATICATE,
      :level => 16,
      :form => 2,
      :moves => [:POISONFANG, :BITE, :TAILWHIP, :SECRETPOWER],
      :ability => :NOGUARD,
      :nature => :NAUGHTY,
      :iv => 10,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "The Monstrosity started acting desperate!",
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
        },
      },
    },
  },

  :STARMIEGOD => {
    :name => "Shooting Star",
    :entryText => "You can't look away from the Star...",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :STARMIE,
      :level => 88,
      :moves => [:SURF, :THUNDERBOLT, :RECOVER, :PSYCHIC],
      :ability => :NATURALCURE,
      :nature => :MODEST,
      :item => :PETAYABERRY,
      :iv => 31,
      :happiness => 255,
      :shiny => true,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "The Shooting Star is sparkling!",
        :statDropCure => true,
        :fieldChange => :RAINBOW,
        :fieldChangeMessage => "A prismatic luminance buries the surroundings!",
        :movesetUpdate => [:TRIATTACK, :DAZZLINGGLEAM, :RAPIDSPIN, :PSYSHOCK],
        :abilitychange => :PRISMARMOR,
      },
    },
  },

  :UXIEBAD => {
    :name => "Uxie",
    :entryText => "Uxie is defending itself!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :UXIE,
      :level => 85,
      :form => 0,
      :moves => [:PSYCHUP, :PSYCHIC, :DRAININGKISS, :YAWN],
      :ability => :LEVITATE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 0",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :MESPRIT,
          :level => 80,
          :moves => [:CHARM, :PSYSHOCK, :SHADOWBALL, :CONFUSERAY],
          :ability => :LEVITATE,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
        },
        2 => {
          :species => :AZELF,
          :level => 80,
          :moves => [:THUNDERWAVE, :ZENHEADBUTT, :PLAYROUGH, :KNOCKOFF],
          :ability => :LEVITATE,
          :nature => :ADAMANT,
          :iv => 31,
          :happiness => 255,
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Uxie drew power from the Starlight!",
        :abilitychange => :VICTORYSTAR,
        :typeChange => [:PSYCHIC, :FAIRY],
        :fieldChange => :STARLIGHT,
        :movesetUpdate => [:PSYCHIC, :DRAININGKISS, :YAWN, :SIGNALBEAM],
        :fieldChangeMessage => "The field shines bright!",
        :statusCure => true,
        :itemchange => :MAGICALSEED,
        :statBoosts => {
          PBStats::DEFENSE => 1,
        },
      },
    },
  },

  :MESPRITBAD => {
    :name => "Mesprit",
    :entryText => "Mesprit is defending itself!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :MESPRIT,
      :level => 85,
      :form => 0,
      :moves => [:FLATTER, :CHARGEBEAM, :DRAININGKISS, :PSYCHIC],
      :ability => :LEVITATE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 0",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :UXIE,
          :level => 80,
          :moves => [:YAWN, :PSYCHIC, :THUNDERBOLT, :HELPINGHAND],
          :ability => :LEVITATE,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
        },
        2 => {
          :species => :AZELF,
          :level => 80,
          :moves => [:THUNDERWAVE, :ZENHEADBUTT, :PLAYROUGH, :KNOCKOFF],
          :ability => :LEVITATE,
          :nature => :ADAMANT,
          :iv => 31,
          :happiness => 255,
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Mesprit submerged itself in water!",
        :abilitychange => :TECHNICIAN,
        :typeChange => [:PSYCHIC, :WATER],
        :fieldChange => :WATERSURFACE,
        :movesetUpdate => [:PSYCHIC, :DRAININGKISS, :CHARGEBEAM, :WATERPULSE],
        :fieldChangeMessage => "The field was flash flooded!",
        :statusCure => true,
        :itemchange => :ELEMENTALSEED,
        :statBoosts => {
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :AZELFBAD => {
    :name => "Azelf",
    :entryText => "Azelf is defending itself!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :AZELF,
      :level => 85,
      :form => 0,
      :moves => [:TAUNT, :FLAMETHROWER, :KNOCKOFF, :PSYCHIC],
      :ability => :LEVITATE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 0",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :UXIE,
          :level => 80,
          :moves => [:YAWN, :PSYCHIC, :THUNDERBOLT, :HELPINGHAND],
          :ability => :LEVITATE,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
        },
        2 => {
          :species => :MESPRIT,
          :level => 80,
          :moves => [:CHARM, :PSYSHOCK, :SHADOWBALL, :CONFUSERAY],
          :ability => :LEVITATE,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Azelf conflagrated in hellfire!",
        :abilitychange => :MAGMAARMOR,
        :typeChange => [:PSYCHIC, :DARK],
        :fieldChange => :INFERNAL,
        :movesetUpdate => [:TORMENT, :FLAMETHROWER, :KNOCKOFF, :PSYCHIC],
        :fieldChangeMessage => "The field is burning with anguish!",
        :statusCure => true,
        :itemchange => :ELEMENTALSEED,
        :statBoosts => {
          PBStats::ATTACK => 1,
        },
      },
    },
  },

  :RIFTTALON => {
    :name => "Karma Beast Talon",
    :entryText => "Talon fumbles toward you...",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :BRAVIARY,
      :level => 85,
      :form => 2,
      :moves => [:SLUDGEWAVE, :STEELWING, :ESPERWING, :VENOSHOCK],
      :gender => :M,
      :nature => :BRAVE,
      :item => :TELLURICSEED,
      :iv => 31,
      :happiness => 0,
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => ".... stOooP.....",
        :movesetUpdate => [:ACIDARMOR, :BARBBARRAGE, :AIRSLASH, :BODYPRESS],
        :playersideChanges => {
          :ToxicSpikes => [1, :TOXICSPIKES, "Toxic Spikes were set up!"],
        },
      },
      2 => {
        :threshold => 0,
        :message => "oUu.... dOn'T.....",
        :formchange => 3,
        :typeChange => [:POISON, :DRAGON],
        :movesetUpdate => [:HEXINGSLASH, :DRAGONCLAW, :DRACOMETEOR, :ACIDSPRAY],
        :statDropCure => true,
        :statusCure => true,
        :fieldChange => :CORROSIVEMIST,
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
        },
      },
      1 => {
        :threshold => 0,
        :message => ".... pLEase.... enD IT....",
        :movesetUpdate => [:VILEASSAULT, :DRAGONRUSH, :SHADOWCLAW, :DRAGONDANCE],
        :itemchange => :POISONIUMZ,
        :bossStatChanges => {
          PBStats::DEFENSE => -2,
          PBStats::SPDEF => -2,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :NANODRIVE => {
    :name => "NANO DRIVE",
    :entryText => "The NANO DRIVE is analyzing...",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :MAGNEZONE,
      :level => 90,
      :form => 1,
      :moves => [:DOUBLEIRONBASH, :BRICKBREAK, :IRONDEFENSE, :SUCKERPUNCH],
      :nature => :IMPISH,
      :happiness => 0,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "The NANO DRIVE is closing out the battle...",
        :movesetUpdate => [:METEORMASH, :ELECTROWEB, :KINGSSHIELD, :CLOSECOMBAT],
      },
    },
  },

  :NANODRIVE_1 => {
    :name => "NANO DRIVE",
    :entryText => "The NANO DRIVE is analyzing...",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :MAGNEZONE,
      :level => 90,
      :moves => [:HAMMERARM, :WOODHAMMER, :ICEHAMMER, :DRAGONHAMMER],
      :nature => :NAUGHTY,
      :form => 2,
      :happiness => 0,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Will you... Remember all of this too? ",
        :movesetUpdate => [:BLIZZARD, :THUNDER, :FIREBLAST, :HYPERBEAM],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
        :statDropCure => true,
      },
    },
  },

  :IRONHELL => {
    :name => "Iron Moth",
    :entryText => "The Iron Moth is ready to take you down.",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :IRONMOTH,
      :level => 90,
      :moves => [:MORNINGSUN, :FIERYDANCE, :STRUGGLEBUG, :SOLARBEAM],
      :ability => :QUARKDRIVE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "<char>V: You... Grandma was right about you. This ends now.",
        :bossStatChanges => {
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :ARCHRIFTGALVANTULA => {
    :name => "Archrift Galvantula",
    :shieldCount => 2,
    :entryText => "Archrift Galvantula emerges from her Queen...",
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :GALVANTULA,
      :level => 88,
      :form => 3,
      :moves => [:STICKYWEB, :SLUDGEBOMB, :DISCHARGE, :BULLDOZE],
      :gender => :F,
      :nature => :HASTY,
      :happiness => 255,
    },
    :delayedactions => {
      :StrengthenTheWeb => {
        :delay => 5,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
        :message => "The Archrift reinforced its defenses with webbing!",
        :animation => :SPIDERWEB,
        :queueDelays => [:StrengthenTheWeb],
      },
    },
    :onEntryEffects => {
      :fieldChange => :DIMENSIONAL,
      :fieldChangeMessage => "Darkness envelops the arena!",
      :queueDelays => [:StrengthenTheWeb],
    },
    :sosDetails => { # pokemon details
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => false,
      :moninfos => {
        1 => {
          :name => "Rift Galvantula",
          :species => :GALVANTULA,
          :level => 83,
          :moves => [:ELECTROWEB, :STRINGSHOT, :STRUGGLEBUG, nil],
          :ability => :COMPOUNDEYES,
          :form => 2,
          :boss => :RIFTGALVANTULA_2,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "The Archrift changed type!",
        :abilitychange => :PRESSURE,
        :typeChange => [:ELECTRIC, :DARK],
        :movesetUpdate => [:RAGE, :SUPERCELLSLAM, :OBSTRUCT, :AQUATAIL],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "The Archrift changed type!",
        :abilitychange => :UNNERVE,
        :typeChange => [:POISON, :DARK],
        :movesetUpdate => [:DARKPULSE, :SLUDGEBOMB, :SUCKERPUNCH, :PSYCHIC],
        :statDropCure => true,
      },
    },
  },

  :RIFTGALVANTULA_2 => {
    :name => "Rift Galvantula",
    :shieldCount => 1,
    :entryText => "The egg is shaking uncontrollably...",
    :immunities => {},
    :moninfo => {
      :species => :GALVANTULA,
      :level => 83,
      :form => 2,
      :moves => [:ELECTROWEB, :FOLLOWME, :STRENGTHSAP, :DRAGONRAGE],
      :gender => :F,
      :nature => :HASTY,
    },
    :onEntryEffects => {
      :bossStatChanges => {
        PBStats::DEFENSE => 1,
        PBStats::SPDEF => 1,
      },
      :message => "The egg is reinforced with toxic thread...",
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :formchange => 1,
        :message => "Rift Galvantula hatched out of the egg!",
        :abilitychange => :UNNERVE,
        :movesetUpdate => [:SILKTRAP, :IRRITATION, :SLUDGEWAVE, :DISCHARGE],
        :playersideChanges => {
          :ToxicSpikes => [1, :TOXICSPIKES, "Broken eggshell was strewn everywhere!"],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => -2,
          PBStats::SPDEF => -2,
        },
      },
    },
  },

  :ARCHRIFTVOLCANION => {
    :name => "Archrift Volcanion",
    :entryText => "The Archrift Volcanion calls for its mother!",
    :shieldCount => 2,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :VOLCANION,
      :level => 85,
      :item => :MAGICALSEED,
      :form => 2,
      :moves => [:HYDROSTEAM, :HEATWAVE, :SCORCHINGSANDS, :MISTBALL],
    },
    :onEntryEffects => {
      :fieldChange => :MISTY,
      :fieldChangeMessage => "Scalding steam envelops the field!",
      :weatherChange => [:SUNNYDAY, 3, "Harsh sunlight falls on the field!"],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :movesetUpdate => [:STEAMERUPTION, :THUNDER, :RECOVER, :STRANGESTEAM],
        :weatherChange => [:RAINDANCE, 3, "A sudden downpour!"],
      },
      1 => {
        :threshold => 0,
        :message => "The Archrift is feeling motivated!",
        :movesetUpdate => [:HYDROSTEAM, :HEATWAVE, :SCORCHINGSANDS, :MISTBALL],
        :weatherChange => [:SUNNYDAY, 3, "Harsh sunlight falls on the field!"],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
    },
  },

  :SENTAKA => {
    :name => "Sentry Stakataka",
    :entryText => "The Sentry charges up!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :STAKATAKA,
      :level => 90,
      :form => 2,
      :moves => [:METEORBEAM, :AUTOTOMIZE, :ACROBATICS, :SHADOWBALL],
      :ability => :BEASTBOOST,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :movesetUpdate => [:DISCHARGE, :METEORBEAM, :SHADOWBOLT, :FLASHCANNON],
        :bossStatChanges => {
          PBStats::SPEED => 1,
          PBStats::ACCURACY => -1,
        },
        :message => "The Sentry is out of control!",
      },
    },
  },

  :STALKER => {
    :name => "Stalkataka",
    :entryText => "The Stalker stands its ground!",
    :shieldCount => 1,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :STAKATAKA,
      :level => 90,
      :form => 1,
      :moves => [:HEADLONGRUSH, :CURSE, :ROCKSLIDE, :IRONHEAD],
      :ability => :BEASTBOOST,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "The Stalker laid down defensive spikes!"],
        },
      },
    },
  },

  :STALKER_01 => {
    :name => "Stalkataka",
    :entryText => "The Stalker stands its ground!",
    :shieldCount => 2,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :STAKATAKA,
      :level => 90,
      :form => 1,
      :moves => [:HEADLONGRUSH, :CURSE, :ROCKSLIDE, :IRONHEAD],
      :ability => :BEASTBOOST,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "The Stalker laid down defensive spikes!"],
        },
      },

      1 => {
        :threshold => 0,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "The Stalker laid down defensive spikes!"],
        },
      },
    },
  },

  :STALKER_02 => {
    :name => "Stalkataka",
    :entryText => "The Stalker stands its ground!",
    :shieldCount => 2,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :STAKATAKA,
      :level => 90,
      :form => 1,
      :moves => [:HEADLONGRUSH, :CURSE, :ROCKSLIDE, :IRONHEAD],
      :ability => :BEASTBOOST,
      :happiness => 255,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "The Stalker laid down defensive spikes!"],
        },
      },

      1 => {
        :threshold => 0,
        :message => "The Stalker adopts a new strategy.",
        :stateChanges => {
          :MagicRoom => [99, :MAGICROOM, "The Stalker disabled all items!"],
        },
      },
    },
  },

  :TWINDANCERS => {
    :name => "Yulia",
    :entryText => "Showtime! May the audience watch intently!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :LILLIGANT,
      :level => 95,
      :form => 2,
      :item => :MAGICALSEED,
      :moves => [:SHADOWBALL, :FLAMEBURST, :AURASPHERE, :FACADE],
      :ability => :OPPORTUNIST,
      :nature => :MILD,
      :happiness => 255,
      :shiny => true,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Yulia elegantly wipes the dirt off her dress and begins anew! Hear her swan song!",
        :statDropCure => true,
        :movesetUpdate => [:SHADOWBALL, :RAGEFIST, :AURASPHERE, :ALLURINGVOICE],
      },
    },
  },

  :TWINDANCERS_1 => {
    :name => "Lena",
    :entryText => "Showtime! May the audience watch intently!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :LILLIGANT,
      :level => 95,
      :form => 3,
      :item => :SITRUSBERRY,
      :moves => [:HIJUMPKICK, :AFTERYOU, :SWAGGER, :FLOWERTRICK],
      :ability => :DAZZLING,
      :nature => :JOLLY,
      :happiness => 255,
      :shiny => true,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Lena puts it all into her final performance!",
        :statDropCure => true,
        :movesetUpdate => [:FLATTER, :LICK, :PETALBLIZZARD, :AXEKICK],
      },
    },
  },

  :EARTHSHATTERER => {
    :name => "Earth Shatterer",
    :entryText => "Tremble! The Earth's crust is being torn apart!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :TORTERRA,
      :level => 95,
      :form => 1,
      :item => :LEFTOVERS,
      :moves => [:EARTHQUAKE, :STEALTHROCK, :MOUNTAINGALE, :DESERTSMARK],
      :ability => :SHELLARMOR,
      :nature => :ADAMANT,
      :happiness => 255,
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :MOUNTAIN,
      :fieldChangeMessage => "The Earth Shatterer stomps the floor, turning the terrain mountainous!",
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :formchange => 2,
        :message => "Earth Shatterer reduces the terrain to a barren wasteland!",
        :statusCure => true,
        :effectClear => true,
        :abilitychange => :SANDFORCE,
        :fieldChange => :DESERT, # field changes
        :movesetUpdate => [:EARTHQUAKE, :HEATCRASH, :HEAVYSLAM, :SANDSTORM],
      },
    },
  },

  :CHITWO => {
    :name => "Chi-Two",
    :entryText => "Put 'em up! The King of Water has challenged you to a duel to the death!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :FINNEON,
      :level => 90,
      :form => 1,
      :item => :NEVERMELTICE,
      :moves => [:ICEBALL, :DEFENSECURL, :MACHPUNCH, :ZENHEADBUTT],
      :ability => :WINGSOFRUIN,
      :nature => :NAUGHTY,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :formchange => 2,
        :animation => :WHIRLPOOL,
        :typeChange => [:WATER,:FIGHTING],
        :message => "The King of Water brought out the BIG GUNS!!!!!!! UH OH!!!!",
        :itemchange => :PUNCHINGGLOVE,
        :movesetUpdate => [:DYNAMICPUNCH, :ICEPUNCH, :SURGINGSTRIKES, :BULKUP],
      },
    },
  },

  :KINGSOFAPPLES => {
    :name => "Kings of Apples",
    :entryText => "Wallow! Sweetness and tart, what an art! Be trapped in the sap of the Kings of Apples!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :HYDRAPPLE,
      :level => 90,
      :form => 1,
      :item => :IAPAPABERRY,
      :moves => [:SLUDGEWAVE, :MUDDYWATER, :FICKLEBEAM, :SYNTHESIS],
      :ability => :ONEBADAPPLE,
      :nature => :MODEST,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :itemchange => :APICOTBERRY,
        :typeChange => [:BUG,:POISON],
        :movesetUpdate => [:STRUGGLEBUG, :MUDDYWATER, :SLUDGEBOMB, :LEECHSEED],
      },
    },
  },

  :ZARDKINGX => {
    :name => "Charizard",
    :entryText => "The king is enshrouded in draconic energy!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :CHARIZARD,
      :level => 95,
      :form => 1,
      :moves => [:FIREPUNCH, :DRAGONDANCE, :OUTRAGE, :EARTHQUAKE],
      :ability => :TOUGHCLAWS,
      :nature => :ADAMANT,
    },
    :delayedactions => {
      :OppressiveAura => {
        :delay => 3,
        :message => "The king's draconic aura is oppressive!",
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
        },
        :queueDelays => [:OppressiveAura],
      },
    },
    :onBreakEffects => {
      1 => {
        :queueDelays => [:OppressiveAura],
      },
    },
  },

  :ZARDQUEENY => {
    :name => "Charizard",
    :entryText => "The queen is blazing with superhot flames!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :CHARIZARD,
      :level => 90,
      :form => 2,
      :moves => [:HEATWAVE, :AIRSLASH, :DRAGONPULSE, :TAILWIND],
      :ability => :DROUGHT,
      :nature => :MODEST,
    },
    :delayedactions => {
      :overwhelmingInferno => {
        :delay => 3,
        :message => "The queen's intense inferno is overwhelming!",
        :playerSideStatChanges => {
          PBStats::SPATK => -1,
        },
        :queueDelays => [:overwhelmingInferno],
      },
    },
    :onBreakEffects => {
      1 => {
        :queueDelays => [:overwhelmingInferno],
      },
    },
  },

  :THEDURALUDON => {
    :name => "Duraludon",
    :entryText => "Duraludon is surging with power!",
    :shieldCount => 1,
    :barGraphic => "",
    :doublebattle => true,
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :ELECTERRAIN,
      :fieldChangeMessage => "Electricity permeates the area!",
    },
    :moninfo => {
      :species => :DURALUDON,
      :level => 90,
      :item => :LEFTOVERS,
      :form => 1,
      :moves => [:DRAGONPULSE, :FLASHCANNON, :THUNDERBOLT, :THUNDERWAVE],
      :ability => :QUAKEPROOF,
      :nature => :TIMID,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :CHARJABUG,
          :level => 100,
          :moves => [:STICKYWEB, :STRUGGLEBUG, :EERIEIMPULSE, :ELECTROWEB],
          :ability => :BATTERY,
          :nature => :CAREFUL,
        },
        2 => {
          :species => :ABOMASNOW,
          :level => 90,
          :moves => [:AURORAVEIL, :BLIZZARD, :WOODHAMMER, :FOCUSBLAST],
          :ability => :SNOWWARNING,
          :nature => :MILD,
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Duraludon is focused!",
        :animation => :LASERFOCUS,
        :bossEffect => {
          :LaserFocus => [1, nil, nil],
        },
        :abilitychange => :SNIPER,
        :movesetUpdate => [:DRACOMETEOR, :DARKPULSE, :THUNDER, :FOCUSENERGY],
        :itemchange => :SCOPELENS,
        :statBoosts => {
          PBStats::ACCURACY => 1,
        },
      },
    },
  },

  :COLOSSUS => {
    :name => "Coalossal",
    :entryText => "Coalossal is surging with power!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :VOLCANICTOP,
      :fieldChangeMessage => "!"
    },
    :moninfo => {
      :species => :COALOSSAL,
      :level => 90,
      :item => :POWERHERB,
      :form => 1,
      :moves => [:MAGMADRIFT, :TARSHOT, :METEORBEAM, :SCALD],
      :ability => :COALFURNACE,
      :nature => :MODEST,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount <= 3",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :CARKOL,
          :level => 90,
          :moves => [:TARSHOT, :MAGNITUDE, :ROCKBLAST, :STEALTHROCK],
          :ability => :FLASHFIRE,
          :nature => :ADAMANT,
        },
        2 => {
          :species => :NINETALES,
          :level => 90,
          :moves => [:HEATWAVE, :SUNNYDAY, :PROTECT, :WILLOWISP],
          :ability => :DROUGHT,
          :nature => :MILD,
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Coalossal is getting angry!!",
        :fieldChange => :INFERNAL,
        :movesetUpdate => [:TEMPERFLARE, :EARTHQUAKE, :ROCKSLIDE, :STONEEDGE],
        :itemchange => :FLAMEPLATE,
        :statBoosts => {
          PBStats::ATTACK => 1,
          PBStats::SPEED => 6,
        },
      },
    },
  },

  :HOTSTUFFYVELTAL => {
    :name => "Yveltal",
    :entryText => "Yveltal's glower is intense.",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :YVELTAL,
      :level => 90,
      :moves => [:DECIMATION, :HURRICANE, :FOCUSBLAST, :OBLIVIONWING],
      :nature => :HASTY,
    },
    :delayedactions => {
      :RisingPower => {
        :delay => 5,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
        :message => "Yveltal's power is rising. Finish it quick!",
      },
    },
    :onEntryEffects => {
      :queueDelays => [:RisingPower],
    },
    :onBreakEffects => {
      1 => {
        :fieldChange => :INFERNAL,
        :movesetUpdate => [:DECIMATION, :FIERYWRATH, :ROOST, :HEATWAVE],
        :typeChange => [:DARK,:FIRE],
        :threshold => 0,
      },
    },
  },

  :M31YVELTAL => {
    :name => "Father",
    :entryText => "Yveltal looms above.",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :YVELTAL,
      :level => 95,
      :moves => [:DECIMATION, :OBLIVIONWING, :FOCUSBLAST, :DARKPULSE],
      :nature => :MODEST,
      :item => :LIFEORB,
      :iv => 31,
      :ev => [0, 0, 0, 252, 0, 252],
      :ball => :NOBALL,
    },
    :delayedactions => {
      :LetThemKnowFear => {
        :delay => 2,
        :playerSideStatChanges => {
          PBStats::SPEED => -1,
        },
        :queueDelays => [:LetThemKnowFear],
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :playersideChanges => {
          :StealthRock => [true, :STEALTHROCK, "The Xen Mage summoned Stealth Rocks!"],
        },
      },
      2 => {
        :threshold => 0,
        :message => "<char>XEN MAGE: Let them know fear!",
        :animation => :SCARYFACE,
        :playerSideStatChanges => {
          PBStats::SPEED => -1,
        },
        :queueDelays => [:LetThemKnowFear],
      },
      1 => {
        :threshold => 0,
        :message => "<char>XEN MAGE: In your final act, let your hate burn!",
        :animation => :INFERNO,
        :movesetUpdate => [:DECIMATION, :OBLIVIONWING, :FIERYWRATH, :HEATWAVE],
        :playersideChangeMessage => "Yveltal became a Dark/Fire-Type!",
        :typeChange => [:DARK, :FIRE],
      },
    },
  },


  :RIFTCHANDELURE2 => {
    :name => "Rift Chandelure",
    :entryText => "Otherworldly wind chimes echo through the air...",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :CHANDELURE,
      :level => 85,
      :form => 3,
      :moves => [:SHADOWBALL, :HEX, :FIREBLAST, :WILLOWISP],
      :gender => :M,
      :nature => :TIMID,
      :happiness => 255,
    },
    :onEntryEffects => {
      :message => "A feeling of warmth emanates from Rift Chandelure...",
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :animation => :OMINOUSWIND,
        :message => "The air feels cold and moist...",
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :typeChange => [:GHOST, :WATER],
        :movesetUpdate => [:SHADOWBALL, :HEX, :SURF, :WHIRLPOOL],
        :abilitychange => :TRACE,
      },
      1 => {
        :threshold => 0,
        :animation => :OMINOUSWIND,
        :message => "A sickly sweet scent attacks your nose...",
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
        :typeChange => [:GHOST, :GRASS],
        :movesetUpdate => [:SHADOWBALL, :HEX, :ENERGYBALL, :LEECHSEED],
        :abilitychange => :TRACE,
      },
    },
  },

  :RIFTGARBODOR2 => {
    :name => "Rift Garbodor",
    :entryText => "The rampaging Rift Garbodor attacked!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :GARBODOR,
      :level => 87,
      :item => :BLACKSLUDGE,
      :moves => [:DRAINPUNCH, :BULLETSEED, :BRUTALSWING, :SLUDGEWAVE],
      :nature => :SASSY,
      :shiny => true,
      :form => 2,
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Garbodor gorged itself on rotten berries!",
        :typeChange => [:POISON, :GRASS],
        :movesetUpdate => [:DRAINPUNCH, :GIGADRAIN, :BRUTALSWING, :BELCH],
        :itemchange => :SITRUSBERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
        :statDropCure => true,
      },
      2 => {
        :threshold => 0,
        :message => "Garbodor gorged itself on scrap metal!",
        :typeChange => [:POISON, :STEEL],
        :movesetUpdate => [:DRAINPUNCH, :GIGADRAIN, :MAGNETBOMB, :BELCH],
        :itemchange => :METALCOAT,
        :bossStatChanges => {
          PBStats::SPDEF => 1,
        },
        :statDropCure => true,
      },
      1 => {
        :threshold => 0,
        :message => "Garbodor desperately gorged itself on nearby rocks!",
        :typeChange => [:POISON, :ROCK],
        :movesetUpdate => [:ROCKBLAST, :GIGADRAIN, :MAGNETBOMB, :BELCH],
        :itemchange => :ROCKYHELMET,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => -2,
          PBStats::SPATK => 1,
          PBStats::SPDEF => -2,
        },
        :statDropCure => true,
      },
    },
  },

  :RIFTNIHILEGO => {
    :name => "Rift Nihilego",
    :entryText => "You feel your radiance beginning to become dull and dim.",
    :shieldCount => 3,
    :immunities => {},
    :item => :BLACKSLUDGE,
    :doublebattle => true,
    :moninfo => {
      :species => :NIHILEGO,
      :level => 85,
      :moves => [:TOXICSPIKES, :STEALTHROCK, :SPIKES, :DIAMONDSTORM],
      :nature => :BOLD,
      :form => 1,
      :iv => 31,
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Nihilego adapted corrosive toxins!",
        :movesetUpdate => [:TOXIC, :ACIDARMOR, :PROTECT, :STRENGTHSAP],
        :abilitychange => :CORROSION,
      },
      2 => {
        :threshold => 0,
        :message => "Nihilego reconstructed itself!",
        :typeChange => [:POISON, :STEEL],
        :movesetUpdate => [:INJECTION, :SLUDGEBOMB, :NIGHTSHADE, :STRENGTHSAP],
      },
      1 => {
        :threshold => 0,
        :movesetUpdate => [:INJECTION, :SLUDGEBOMB, :NIGHTSHADE, :WRAP],
      },
    },
  },

  :QUEENNIHILEGO => {
    :name => "Queen Nihilego",
    :entryText => "You feel a heavy and crippling sense of dread...",
    :shieldCount => 6,
    :immunities => {},
    :item => :DEMONSTONE,
    :doublebattle => true,
    :onEntryEffects => {
      :message => "<char>CRESCENT: Those crystals on its head are charging an attack... I don't know if we can avoid it.",
    },
    :chargeAttack => {
      :turns => 4,
      :chargingMessage => "Queen Nihilego's crown stops spinning and takes aim.",
      :continueCharging => true,
      :canAttack => false,
      :intermediateattack => {
        :move => :SPACIALREND,
        :type => :SHADOW,
        :basedamage => 200,
        :name => "Nihil Late",
        :category => :special,
        :target => :AllOpposing,
      },
    },
    :moninfo => {
      :species => :NIHILEGO,
      :level => 100,
      :moves => [:NIHILLIGHT, nil, nil, nil],
      :nature => :MODEST,
      :form => 2,
      :iv => 31,
      :ev => [252, 252, 252, 252, 252, 252]
    },
    :onBreakEffects => {
    },
  },

  :QUEENNIHILEGO_1 => {
    :name => "Queen Nihilego",
    :entryText => "You feel a heavy and crippling sense of dread...",
    :shieldCount => 6,
    :immunities => {},
    :item => :DEMONSTONE,
    :doublebattle => true,
    :onEntryEffects => {
      :message => "<char>STORM NYM: I should have dealt with you before you grew into such a problem...",
    },
    :chargeAttack => {
      :turns => 4,
      :chargingMessage => "Queen Nihilego's crown stops spinning and takes aim.",
      :continueCharging => true,
      :canAttack => false,
      :intermediateattack => {
        :move => :SPACIALREND,
        :type => :SHADOW,
        :basedamage => 200,
        :name => "Nihil Late",
        :category => :special,
        :target => :AllOpposing,
      },
    },
    :moninfo => {
      :species => :NIHILEGO,
      :level => 100,
      :moves => [:SPACIALREND, :TOXICSPIKES, :EARTHQUAKE, :NIHILLIGHT],
      :nature => :MODEST,
      :form => 2,
      :iv => 31,
      :ev => [0, 0, 0, 0, 0, 0]
    },
    :onBreakEffects => {
      6 => {
        :message => "<char>STORM-NYM: Impossible!",
      },
      3 => {
        :message => "<char>STORM-NYM: Queen Nihilego! Vitus! What are you doing?! Can't you do anything right?!",
      },
      1 => {
        :message => "<char>STORM-NYM: I can still win... I can still win this! I'll show you! I'll show you and all the rest!",
      },
    },
  },

  ######### XENPURGIS TOWER VARIANTS ############
  :STALKER_01_TOWER => {
    :name => "Stalkataka",
    :entryText => "The Stalker stands its ground!",
    :shieldCount => 1,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :STAKATAKA,
      :level => 75,
      :form => 1,
      :item => :ROCKYHELMET,
      :moves => [:HEADLONGRUSH, :CURSE, :ROCKSLIDE, :IRONHEAD],
      :ability => :BEASTBOOST,
      :nature => :ADAMANT,
      :iv => 31,
    },
    :onBreakEffects => {},
  },

  :TWINDANCERS_TOWER => {
    :name => "Yulia",
    :entryText => "Showtime! May the audience watch intently!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :LILLIGANT,
      :level => 90,
      :form => 2,
      :moves => [:INFERNALPARADE, :FIERYDANCE, :AURASPHERE, :FACADE],
      :ability => :OPPORTUNIST,
      :nature => :MILD,
      :iv => 31,
      :happiness => 255,
      :shiny => true,
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :HAUNTED,
      :fieldChangeMessage => "Yulia's performance acted as a seance!",
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Yulia elegantly wipes the dirt off her dress and begins anew! Hear her swan song!",
        :statusCure => true,
        :movesetUpdate => [:INFERNALPARADE, :STRENGTH, :AURASPHERE, :ALLURINGVOICE],
      },
    },
  },

  :TWINDANCERS_1_TOWER => {
    :name => "Lena",
    :entryText => "Showtime! May the audience watch intently!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :LILLIGANT,
      :level => 90,
      :form => 3,
      :moves => [:HIJUMPKICK, :AFTERYOU, :SWAGGER, :FLOWERTRICK],
      :ability => :DAZZLING,
      :nature => :JOLLY,
      :iv => 31,
      :happiness => 255,
      :shiny => true,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Lena puts it all into her final performance!",
        :statusCure => true,
        :movesetUpdate => [:FLATTER, :LICK, :PETALBLIZZARD, :AXEKICK],
      },
    },
  },

  :EARTHSHATTERER_TOWER => {
    :name => "Earth Shatterer",
    :entryText => "Tremble! The Earth's crust is being torn apart!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :TORTERRA,
      :level => 90,
      :form => 1,
      :item => :LEFTOVERS,
      :moves => [:EARTHQUAKE, :STONEEDGE, :MOUNTAINGALE, :DESERTSMARK],
      :ability => :SHELLARMOR,
      :nature => :ADAMANT,
      :iv => 31,
      :happiness => 255,
    },

    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :MOUNTAIN,
      :fieldChangeMessage => "The Earth Shatterer stomps the floor, turning the terrain mountainous!",
      :playersideChanges => {
        :StealthRock => [true, :STEALTHROCK, nil],
      },
    },

    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :formchange => 2,
        :message => "Earth Shatterer reduces the terrain to a barren wasteland!",
        :abilitychange => :SANDFORCE,
        :fieldChange => :DESERT,
        :movesetUpdate => [:EARTHQUAKE, :HEATCRASH, :HEAVYSLAM, :STONEEDGE],
      },
    },
  },

  :KINGSOFAPPLES_TOWER => {
    :name => "Kings of Apples",
    :entryText => "Wallow! Sweetness and tart, what an art! Be trapped in the sap of the Kings of Apples!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :HYDRAPPLE,
      :level => 95,
      :form => 1,
      :item => :IAPAPABERRY,
      :moves => [:SLUDGEWAVE, :MUDDYWATER, :FICKLEBEAM, :SYNTHESIS],
      :ability => :CHEEKPOUCH,
      :nature => :MODEST,
      :happiness => 255,
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :SWAMP,
      :fieldChangeMessage => "A swamp of mushy apples is formed!",
      :bossEffect => {
        :AquaRing => [true, :AQUARING, "Swamp water enveloped the Kings!"],
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :itemchange => :IAPAPABERRY,
        :typeChange => [:BUG,:POISON],
        :movesetUpdate => [:STRUGGLEBUG, :MUDDYWATER, :SLUDGEBOMB, :LEECHSEED],
        :bossStatChanges => {
          PBStats::SPDEF => 1,
        },
      },
    },
  },

  :CHITWO_TOWER => {
    :name => "Chi-Two",
    :entryText => "Put 'em up! The King of Water has challenged you to a duel to the death!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :FINNEON,
      :level => 95,
      :form => 1,
      :item => :NEVERMELTICE,
      :moves => [:ICEBALL, :DEFENSECURL, :MACHPUNCH, :ZENHEADBUTT],
      :ability => :WINGSOFRUIN,
      :nature => :NAUGHTY,
      :iv => 31,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :formchange => 2,
        :animation => :WHIRLPOOL,
        :message => "The King of Water brought out the BIG GUNS!!!!!!! UH OH!!!!",
        :itemchange => :PUNCHINGGLOVE,
        :movesetUpdate => [:DYNAMICPUNCH, :ICEPUNCH, :WATERFALL, :BULKUP],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
    },
  },
  ##############################################

  :TYRANICAL => {
    :name => "Tyranitar",
    :entryText => "Tyranitar is surging with power!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :TYRANITAR,
      :level => 90,
      :form => 1,
      :moves => [:IRONDEFENSE, :CRUNCH, :ROCKSLIDE, :EARTHQUAKE],
      :ability => :SANDSTREAM,
      :nature => :ADAMANT,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount <= 2",
      :continuous => true,
      :totalMonCount => 1,
      :moninfos => {
        1 => {
          :species => :AGGRON,
          :level => 90,
          :item => :SITRUSBERRY,
          :moves => [:METALBURST, :DRAGONTAIL, :ROCKSLIDE, :IRONTAIL],
          :ability => :STURDY,
          :nature => :CAREFUL,
          :iv => 31,
          :ev => [252, 0, 4, 0, 252, 0],
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Tyranitar is not going down easy!",
        :statusCure => true,
        :effectClear => true,
        :abilitychange => :SANDFORCE,
        :weatherChange => [:SANDSTORM, 8, "Tyranitar roars up a sandstorm!"],
        :movesetUpdate => [:STONEEDGE, :CRUNCH, :SECRETPOWER, :EARTHQUAKE],
        :itemchange => :ROCKYHELMET,
        :statBoosts => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => -2,
          PBStats::EVASION => -2,
        },
      },
    },
  },

  :CADARELLIA => {
    :name => "Cadarellia",
    :entryText => "Cadarellia is kind of dizzy.",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :CRESSELIA,
      :level => 90,
      :form => 2,
      :item => :ROCKYHELMET,
      :moves => [:MOONLIGHT, :STEELBEAM, :BUGBUZZ, :STUNSPORE],
      :ability => :SPEEDBOOST,
      :nature => :MODEST,
      :ev => [0, 0, 252, 252, 4, 0],
      :iv => 31,
      :status => :PARALYSIS,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :movesetUpdate => [:STOREDPOWER, :FLASHCANNON, :BUGBUZZ, :CALMMIND],
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
      },
    },
  },

  :KARMABEASTXERN => { #Wip. ???? type
    :name => "Karma Beast Nymiera",
    :entryText => "<char>???: Stop \\PN.",
    :inspectText =>
    [
      "\\se[]\\c[11]???: Huh?\\1",
      "\\se[]\\c[11]???: Did you really think I'd just let you do that?\\1",
      "\\se[]\\c[11]???: Who do you think made it so you could <i>Inspect</i> to begin with?\\1",
      "\\se[]\\c[11]???: But,\\|\\se[SFX - Blip] if you really want to step out of your bounds like that,\\|",
      "\\se[]\\c[11]???: I'll simply put you back in your cage.\\1",
      "\\se[]\\c[11]???: What's a bird to do when their wings have been plucked anyways?\\1",
    ],
    :shieldCount => 3,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :XERNEAS,
      :level => 90,
      :item => :LEFTOVERS,
      :moves => [:SALTCURE, :COSMICPOWER, :CLEARSMOG, :PROTECT],
      :ability => :LIFEBLOOD,
      :nature => :MODEST,
      :form => 5,
      :iv => 31,
      :ev => [252, 0, 4, 0, 0, 252],
    },
    :delayedactions => {
      :SeeDestructionStart => {
        :delay => 1,
        :playerEffects => {
          :FutureSight => [2, :FUTURESIGHT, "{1} foresaw an attack!"],
          :FutureSightMove => [:FUTURESIGHT, nil, nil],
        },
        :queueDelays => [:SeeDestructionRepeat],
      },
      :SeeDestructionRepeat => {
        :delay => 3,
        :playerEffects => {
          :FutureSight => [2, :FUTURESIGHT, "{1} foresaw an attack!"],
          :FutureSightMove => [:FUTURESIGHT, nil, nil],
        },
        :queueDelays => [:SeeDestructionRepeat],
      },
      :SeeYourEndStart => {
        :delay => 1,
        :instantMove => [:FISSURE, :FirstUnfainted],
      },
      :NoEscapeStart => {
        :delay => 1,
        :lockOnTarget => :true,
        :instantMove => [:FISSURE, :FirstUnfainted],
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Data particles swarmed all around!",
        :playerEffects => {
          :INFESTATION => [8, "Infestation", nil],
        },
      },
      2 => {
        :threshold => 0,
        :queueDelays => [:SeeDestructionStart],
      },
      1 => {
        :threshold => 0,
        :CustomMethod => "pbLifeBloodAnalysis(battler)",
        :partialAnalysis => {
          :statDropCure => true,
          :statusCleanse => true,
          :typeChange => [:FAIRY, :PSYCHIC],
          :statChangeRefresh => true,
          :statusCure => true,
          :abilitychange => :TINTEDLENS,
          :ev => [252, 0, 0, 252, 0, 0],
          :movesetUpdate => [:DAZZLINGGLEAM, :MOONBLAST, :EARTHPOWER, :HEATWAVE],
        },
        :semiAnalysis => {
          :bossStatChanges => {
            PBStats::DEFENSE => 1,
            PBStats::SPDEF => 1,
          },
          :queueDelays => [:SeeYourEndStart],
        },
        :fullAnalysis => {
          :bossStatChanges => {
            PBStats::SPATK => 1,
          },
          :statusCleanse => true,
          :queueDelays => [:NoEscapeStart],
        },
      },
    },
  },

  :PERCYMEWTWO => {
    :name => "Mewtwo",
    :entryText => "<char>PERCIVAL: Again from the top, Mewtwo. \nOne Shadow Ball should do.",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :MEWTWO,
      :moves => [:PSYSTRIKE, :SHADOWBALL, :GRASSKNOT, :FLAMETHROWER],
      :ability => :INSOMNIA,
      :form => 2,
      :level => 105,
      :nature => :NAIVE,
      :happiness => 2,
      :iv => 31,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "<char>PERCIVAL: Am I truly the monster here...? Or is it you?",
        :animation => :EXPLOSION,
        :itemchange => :FOCUSSASH,
        :formchange => 0,
        :fieldChangeMessage => "Mewtwo's Mega power was exhausted...",
        :movesetUpdate => [:AURASPHERE, :PSYSTRIKE, :THUNDERBOLT, :CALMMIND],
      },
    },
  },

  :SHATTEREDTIME => {
    :name => "Shattered Time",
    :entryText => "Shattered Time is getting ready to break through the seams of time...",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :CELEBI,
      :level => 100,
      :moves => [:GIGADRAIN, :NASTYPLOT, :PSYCHIC, :EARTHPOWER],
      :ability => :PROTOSYNTHESIS,
      :nature => :TIMID,
      :iv => 31,
      :item => :BOOSTERENERGY,
      :happiness => 0,
      :form => 2,
      :ev => [104, 0, 0, 152, 0, 252],
    },
    :delayedactions => {
      :RevertEvolutionFast => {
        :delay => 2,
        :CustomMethod => "pbPokemonEvolutionRevert(battler, false)",
        :queueDelays => [:RevertEvolutionFast],
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Shattered Time becomes desperate...",
        :movesetUpdate => [:OVERHEAT, :LEAFSTORM, :PROTECT, :ROAROFTIME],
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::SPEED => -6,
        },
        :queueDelays => [:RevertEvolutionFast],
      },
    },
  },

  :FOEHNMISTRAL_EARLY => {
    :name => "Foehn & Mistral",
    :entryText => "Mistral and Foehn approach!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :GALLADE,
      :level => 40,
      :form => 2,
      :moves => [:DAZZLINGGLEAM, :DRAINPUNCH, :NIGHTSLASH, :SHADOWBALL],
      :nature => :NAIVE,
      :ability => :PARENTALBOND,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Foehn walks in front!",
        :abilitychange => :ANALYTIC,
        :movesetUpdate => [:SHOCKWAVE, :DAZZLINGGLEAM, :SHADOWBALL, :SCALD],
      },
      1 => {
        :threshold => 0,
        :message => "Mistral pushes Foehn away!",
        :animation => :HONECLAWS,
        :abilitychange => :SHARPNESS,
        :movesetUpdate => [:SLASH, :NIGHTSLASH, :PSYCHOCUT, :SPIRITBREAK],
      },
    },
  },
}

BOSSINFOHASH = {

  # Template

  :GODKILLER => {
    :name => "God Killer", # nickname
    :shieldCount => 1, # number of shields
    :barGraphic => "", # what kind of hp bar graphic should be pulled
    :immunities => { # any immunities to things
      :moves => [],
      :fieldEffectDamage => [],
    },
    :capturable => true, # can you catch this boss after shields are removed?
    :entryText => "Heaven-shaking Godkiller appeared.", # dialogue upon enterring battle as a wild pokemon
    :moninfo => { # bosspokemon details
      :species => :GARCHOMP,
      :level => 5,
      :form => 0,
      :item => :LEFTOVERS,
      :moves => [:DRAGONTAIL, :DRAGONTAIL, :DRAGONTAIL, :DRAGONTAIL],
      :ability => :RKSSYSTEM,
      :gender => :F,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 0, 4, 0, 252, 0],
    },
    :sosDetails => { # sospokemon details
      :activationRequirement => "battler.shieldCount == 0",
      :continuous => true,
      :totalMonCount => 3,
      :moninfos => {
        1 => {
          :species => :GARCHOMP,
          :level => 5,
          :form => 0,
          :item => :LEFTOVERS,
          :moves => [:DRAGONTAIL, :DRAGONTAIL, :DRAGONTAIL, :DRAGONTAIL],
          :ability => :RKSSYSTEM,
          :gender => :F,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 0, 4, 0, 252, 0],
        },
        2 => {
          :species => :GYARADOS,
          :level => 5,
          :form => 0,
          :item => :LEFTOVERS,
          :moves => [:DARKPULSE, :PSYSHOCK, :MOONLIGHT, :MOONBLAST],
          :ability => :RKSSYSTEM,
          :gender => :F,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 0, 4, 0, 252, 0],
        },
      },
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :PSYTERRAIN,
      :fieldChangeMessage => "Gothitelle laughs at how dumb your face looks. So mean!"
    },
    :onBreakEffects => { # in order of shield count, with the highest value being the first shield broken and the lowest the last
      1 => {
        :threshold => 0, # if desired, shield can be broken at higher hp% than 0
        :message => "", # message that plays when shield is broken
        :bossEffect => { # effect that applies on the boss when breaking shield
          :MagicCoat => [true, :MAGICCOAT, "{1} shrouded itself with Magic Coat!"], # syntax: effect => [effect value, effect animation, effect message]
        },
        :formchange => 0, # formchanges
        :abilitychange => :DOWNLOAD, # ability to change to upon shieldbreaker
        :fieldChange => :SWAMP, # field changes
        :fieldChangeMessage => "", # message that plays when the field is changes
        :weatherChange => [:RAINDANCE, 5, nil], # weather to apply, duration, customized weather message
        :typeChange => [:FIRE, :ROCK], # any given type changes
        :movesetUpdate => [:EARTHQUAKE, :OUTRAGE, :ROCKSLIDE, :FIREBLAST], # any given moveset changes
        :speciesUpdate => :FLYGON,
        :statusCure => true, # if status is cured when shield is broken
        :effectClear => true, # if effects are cleared when shield is broken
        :bossSideStatusChanges => [:PARALYSIS, "Paralysis"], # what status gets inflicted on a boss/player pokemon when shield is broken. array has 2 elements, first the status symbol, then a string for the animation
        :playerSideStatusChanges => [:PARALYSIS, "Paralysis"], # what status gets inflicted on a boss/player pokemon when shield is broken. array has 2 elements, first the status symbol, then a string for the animation
        :statDropCure => true, # if statdrops are negated when shield is broken
        :playerEffects => { # effects applied upon enemies on breaking shield
          :Curse => [true, :CURSE, "A curse was inflicted on the opposing side!"], # syntax: effect => [effect value, effect animation, effect message]
        },
        :stateChanges => { # handles state changes found in the Battle_Global class(in Battle_ActiveSide file + Trick Room
          :TrickRoom => [5, :TRICKROOM, "The dimensions were changed!"], # syntax: effect => [effect value, effect animation, effect message]
        },
        :playersideChanges => { # handles side changes found in the Battle_Side class(in Battle_ActiveSide file)
          :ToxicSpikes => [1, :TOXICSPIKES, "Toxic Spikes were set up!"], # syntax: effect => [effect value, effect animation, effect message]
        },
        :bosssideChanges => { # handles side changes found in the Battle_Side class(in Battle_ActiveSide file)
          :ToxicSpikes => [1, :TOXICSPIKES, "Toxic Spikes were set up!"], # syntax: effect => [effect value, effect animation, effect message]
        },
        :itemchange => :LEFTOVERS, # item that is given upon breaking shield
        :bgmChange => "Battle - Final Endeavor",
        :bossStatChanges => { # any statboosts that are given
          PBStats::SPATK => 1,
        },
        :playerSideStatChanges => { # any statchanges applied to the players side
          PBStats::SPATK => -1,
        }
      },
    },
  },

  :INTRODEOXYS => {
    :name => "The Final Piece",
    :entryText => "Deoxys emerges from the chess piece!",
    :shieldCount => 2,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :DEOXYS,
      :level => 21,
      :moves => [:KNOCKOFF, :PSYBEAM, :TAUNT, :WRAP],
      :ability => :PRESSURE,
      :nature => :NAIVE,
      :iv => 1,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 1",
      :totalMonCount => 3,
      :moninfos => {
        1 => {
          :species => :DEOXYS,
          :level => 20,
          :moves => [:KNOCKOFF, :PSYBEAM, :TAUNT, :WRAP],
          :form => 1,
          :iv => 10,
        },
        2 => {
          :species => :DEOXYS,
          :level => 20,
          :moves => [:SPIKES, :NIGHTSHADE, :LEER, :WRAP],
          :form => 2,
          :iv => 10,
        },
        3 => {
          :species => :DEOXYS,
          :level => 20,
          :moves => [:SPIKES, :NIGHTSHADE, :LEER, :WRAP],
          :form => 3,
          :iv => 10,
        },
      },
    },
    :onBreakEffects => {},
  },

  :BOSSGARBODOR => {
    :name => "Garbage Menace",
    :entryText => "The Garbodor approached!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :GARBODOR,
      :level => 12,
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
          :level => 11,
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
    }
  },

  :MELIABUNEARY => {
    :name => "Banished Buneary",
    :entryText => "<char>MELIA: Ohmigosh, I'm so sorry for this!! Buneary! Stop that!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :BUNEARY,
      :level => 15,
      :moves => [:FAKEOUT, :FRUSTRATION, :FIREPUNCH, :BABYDOLLEYES],
      :ability => :RUNAWAY,
      :gender => :F,
      :shiny => true,
      :nature => :ADAMANT,
      :iv => 20,
      :happiness => 0,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Buneary shook her hips and pouted!",
        :animation => :DRAGONDANCE,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :BOSSSPIDOPS => {
    :name => "Spider-Gang",
    :entryText => "Spidops creates a web with the picture of a skull in the middle of it!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :SPIDOPS,
      :level => 18,
      :moves => [:SILKTRAP, :STRUGGLEBUG, :BUGBITE, nil],
      :ability => :STAKEOUT,
      :gender => :M,
      :nature => :DOCILE,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 1",
      :totalMonCount => 2,
      :moninfos => {
        2 => {
          :species => :TAROUNTULA,
          :level => 11,
          :moves => [:STRUGGLEBUG, :BUGBITE, :BLOCK, :STRINGSHOT],
          :ability => :INSOMNIA,
          :iv => 10,
        },
      },
    },
    :onBreakEffects => {}
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
      :moves => [:SHADOWSNEAK, :BITE, :WATERPULSE, :SCREECH],
      :ability => :INTIMIDATE,
      :gender => :M,
      :nature => :NAUGHTY,
      :iv => 0,
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Rift Gyarados started acting defensive!",
        :animation => :WITHDRAW,
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
    },
  },

  :CELEBITEST => {
    :name => "Celebi",
    :entryText => "Celebi is testing something out.",
    :shieldCount => 5,
    :immunities => {},
    :onEntryEffects => {
      :playerEffects => {
        :Yawn => [1, :YAWN, "A strong feeling of drowsiness..."],
      },
    },
    :moninfo => {
      :species => :CELEBI,
      :level => 20,
      :form => 2,
      :moves => [:TACKLE, :PROTECT, :PROTECT, :PROTECT],
      :ability => :INTIMIDATE,
      :nature => :NAUGHTY,
      :iv => 20,
      :happiness => 255,
      :ev => [20, 20, 20, 20, 20, 20],
    },
    :onBreakEffects => {
      5 => {
        :threshold => 0,
        :message => "Rift Gyarados started acting defensive!",
        :formchange => [0, "MegaEvolution"],
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
      :level => 20,
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
          :level => 15,
          :moves => [:EMBER, :HEADBUTT, :LEER, :WORKUP],
          :ability => :UNNERVE,
          :iv => 10,
        },
        2 => {
          :species => :GLIGAR,
          :level => 15,
          :moves => [:KNOCKOFF, :SANDATTACK, :POISONSTING, :FURYCUTTER],
          :ability => :UNNERVE,
          :iv => 10,
        },
      },
    },
    :onBreakEffects => {},
  },

  :RIFTCHANDELURE => {
    :name => "Rift Chandelure",
    :entryText => "Otherworldly wind chimes echo through the air...",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :CHANDELURE,
      :level => 60,
      :item => :FIREGEM,
      :form => 3,
      :moves => [:SHADOWBALL, :AIRSLASH, :FIREBLAST, :WILLOWISP],
      :gender => :M,
      :nature => :TIMID,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 0, 252, 4, 252],
    },
    :onEntryEffects => {
      :message => "A feeling of warmth emanates from Rift Chandelure...",
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :animation => :OMINOUSWIND,
        :message => "The air feels cold and moist...",
        :statBoostRefresh => true,
        :itemchange => :WATERGEM,
        :typeChange => [:GHOST, :WATER],
        :movesetUpdate => [:SHADOWBALL, :AIRSLASH, :SURF, :WHIRLPOOL],
        :abilitychange => :TRACE,
      },
      2 => {
        :threshold => 0,
        :animation => :OMINOUSWIND,
        :message => "A sickly sweet scent attacks your nose...",
        :statBoostRefresh => true,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :itemchange => :GRASSGEM,
        :typeChange => [:GHOST, :GRASS],
        :movesetUpdate => [:SHADOWBALL, :AIRSLASH, :ENERGYBALL, :LEECHSEED],
        :abilitychange => :TRACE,
      },
      1 => {
        :threshold => 0,
        :animation => :OMINOUSWIND,
        :message => "The feeling of static is all around...",
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
        :itemchange => :ELECTRICGEM,
        :typeChange => [:GHOST, :ELECTRIC],
        :movesetUpdate => [:SHADOWBALL, :AIRSLASH, :THUNDERBOLT, :THUNDERWAVE],
        :abilitychange => :TRACE,
      },
    }
  },

  :SHADOWMEWTWO => {
    :name => "Shadow Mewtwo",
    :entryText => "Mewtwo's power is building up!",
    :shieldCount => 1,
    :immunities => {},
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :message => "<char>KETA: We have to defeat it quickly or else...",
    },
    :chargeAttack => {
      :turns => 10,
      :chargingMessage => "Mewtwo is charging its attack...",
      :continueCharging => true,
      :canAttack => false,
      :canIntermediateAttack => true,
      :intermediateattack => {
        :move => :HYPERBEAM,
        :type => :SHADOW,
        :basedamage => 60,
        :name => "Shadow Beam",
        :category => :special,
        :target => :AllOpposing,
      },
    },
    :moninfo => {
      :species => :MEWTWO,
      :level => 30,
      :moves => [:SHADOWSNEAK, nil, nil, nil],
      :ability => :PRESSURE,
      :nature => :HARDY,
      :iv => 20,
      :happiness => 0,
      :form => 3,
      :shadow => true,
      :ev => [40, 40, 40, 40, 40, 40],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Shadow Mewtwo's power grows!",
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => -1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => -1,
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
      :level => 35,
      :form => 4,
      :moves => [:PHANTOMFORCE, :WATERFALL, :GRASSYGLIDE, :SCREECH],
      :ability => :INTIMIDATE,
      :gender => :M,
      :nature => :NAUGHTY,
      :iv => 20,
      :happiness => 255,
      :ev => [40, 40, 40, 40, 40, 40],
      :BaseStats => [95, 145, 89, 120, 110, 81],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Rift Gyarados's type changed!",
        :typeChange => [:WATER, :DRAGON],
        :movesetUpdate => [:DRAGONRUSH, :WATERFALL, :THUNDERFANG, :SCREECH],
        :fieldChange => :WATERSURFACE,
        :fieldChangeMessage => "Rift Gyarados dragged the battle to the lake!",
      },
      1 => {
        :threshold => 0,
        :message => "Rift Gyarados's type changed!",
        :typeChange => [:FIRE, :DRAGON],
        :movesetUpdate => [:DRAGONRUSH, :LAVAPLUME, :CRUNCH, :SCREECH],
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
      :level => 20,
      :form => 2,
      :moves => [:PSYBEAM, :DISARMINGVOICE, :CHARGEBEAM, :SWEETSCENT],
      :gender => :F,
      :nature => :DOCILE,
      :ability => :PASTELVEIL,
      :iv => 20,
      :happiness => 255,
      :ev => [20, 20, 20, 20, 20, 20],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :fieldChange => :MISTY,
        :fieldChangeMessage => "Pulse Musharna spread mist everywhere."
      },
    },
  },

  :PULSEMUSHARNA2 => {
    :name => "PULSE+ Musharna",
    :entryText => "The dangerous(?) Musharna attacked(?) again!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :MUSHARNA,
      :level => 91,
      :form => 2,
      :item => :SITRUSBERRY,
      :moves => [:MISTBALL, :DAZZLINGGLEAM, :AURASPHERE, :SWEETSCENT],
      :gender => :F,
      :nature => :MODEST,
      :ability => :PASTELVEIL,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 0, 4, 252, 0, 0],
    },
    :delayedactions => {
      :RelaxingMist => {
        :delay => 3,
        :animation => :FAIRYWIND,
        :message => "The aromatic mist is relaxing...",
        :playerSideStatChanges => {
          PBStats::SPEED => -1,
        },
        :queueDelays => [:RelaxingMist],
      },
      :SwarmDefend => {
        :delay => 3,
        :message => "Pulse Musharna issued a defend order!",
        :animation => :DEFENDORDER,
        :bossStatChanges => {
          PBStats::DEFENSE => 2,
          PBStats::SPDEF => 2,
        },
        :queueDelays => [:SwarmAttack],
      },
      :SwarmAttack => {
        :delay => 3,
        :message => "Pulse Musharna issued an attack order!",
        :animation => :ATTACKORDER,
        :bossStatChanges => {
          PBStats::SPATK => 2,
        },
        :queueDelays => [:SwarmHeal],
      },
      :SwarmHeal => {
        :delay => 3,
        :message => "Pulse Musharna issued a heal order!",
        :animation => :HEALORDER,
        :itemchange => :LEFTOVERS,
        :statusCure => true,
        :statDropCure => true,
        :effectClear => true,
        :bossEffect => {
          :Ingrain => [true, nil, nil],
        },
      },
    },
    :onEntryEffects => {
      :queueDelays => [:RelaxingMist],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :bosssideChanges => {
          :Mist => [5, :MIST, nil],
        },
        :movesetUpdate => [:MISTBALL, :STRANGESTEAM, :PETALDANCE, :STUNSPORE],
        :message => "Pulse Musharna is laying lazily in the flowers...",
        :statusCure => true,
        :statDropCure => true,
        :effectClear => true,
      },
      2 => {
        :threshold => 0,
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, nil],
        },
        :message => "Pulse Musharna became one with the bugs...",
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
      :level => 35,
      :form => 1,
      :moves => [:FAKETEARS, :PSYCHIC, :FLATTER, :DARKPULSE],
      :gender => :F,
      :nature => :MODEST,
      :ability => :SHADOWTAG,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 0, 0, 252, 0, 0],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
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
      :level => 50,
      :form => 1,
      :moves => [:PLAYNICE, :PSYSHOCK, :FOCUSBLAST, :DARKPULSE],
      :gender => :F,
      :nature => :MODEST,
      :ability => :COMPETITIVE,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 0, 0, 252, 0, 0],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :fieldChange => :PSYTERRAIN,
        :fieldChangeMessage => "Gothitelle laughs at how dumb your face looks. So mean!"
      },
    },
  },

  :DAMIENSLATIOS => {
    :name => "Latios",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :LATIOS,
      :level => 100,
      :form => 0,
      :moves => [:BEASTHUNTER, :LUSTERPURGE, :DARKPULSE, :AURASPHERE],
      :nature => :TIMID,
      :ability => :LEVITATE,
      :item => :SOULDEW,
      :shiny => true,
      :iv => 31,
      :aura => :nihilegopoison,
      :ev => [4, 0, 0, 252, 0, 252],
      :happiness => 255,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :instantMove => [:DRAGONCHEER, 1],
        :formchange => [1, "MegaEvolution"],
        :message => "Latios transformed!",
        :ev => [152, 0, 0, 100, 0, 252],
      },
    },
  },


  :DAMIENSLATIOS2 => {
    :name => "Latios",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :LATIOS,
      :level => 100,
      :form => 0,
      :moves => [:BEASTHUNTER, :LUSTERPURGE, :MYSTICALFIRE, :AURASPHERE],
      :nature => :TIMID,
      :item => :DRAGONIUMZ,
      :ability => :LEVITATE,
      :shiny => true,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 0, 0, 252, 0, 252],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :formchange => [1, "MegaEvolution"],
        :itemchange => :HABANBERRY,
        :bossEffect => {
          :FocusEnergy => [3, :DRAGONCHEER, "Latios empowered itself with its draconic energy."],
        },
        :message => "Latios transformed!",
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
      :level => 70,
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

  :BELIAL => {
    :name => "Belial",
    :entryText => "A feisty Volcarona appeared!",
    :shieldCount => 3,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :VOLCARONA,
      :level => 50,
      :item => :LEFTOVERS,
      :moves => [:MYSTICALFIRE, :BUGBUZZ, :GIGADRAIN, :SUNNYDAY],
      :ability => :FLAMEBODY,
      :nature => :MODEST,
      :gender => :M,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 0",
      :totalMonCount => 2,
      :continuous => true,
      :moninfos => {
        1 => {
          :species => :SHUCKLE,
          :level => 40,
          :item => :MENTALHERB,
          :moves => [:STEALTHROCK, :INFESTATION, :STICKYWEB, :HELPINGHAND],
          :ability => :STURDY,
          :nature => :BOLD,
          :iv => 31,
          :happiness => 255,
        },
        2 => {
          :species => :MOTHIM,
          :level => 40,
          :item => :BUGGEM,
          :moves => [:STRUGGLEBUG, :POISONPOWDER, :PROTECT, :LUNGE],
          :ability => :TINTEDLENS,
          :iv => 31,
          :happiness => 255,
        },
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :weatherChange => [:SUNNYDAY, 5, nil],
        :itemchange => :LEFTOVERS,
      },
      2 => {
        :threshold => 0,
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, "Belial shrouded itself with a Safeguard!"],
        },
        :statusCure => true,
        :statDropCure => true,
        :itemchange => :LEFTOVERS,
      },
      1 => {
        :threshold => 0,
        :abilitychange => :SWARM,
        :fieldChange => :FLOWERGARDEN3,
        :fieldChangeMessage => "The field is covered in flowers!",
        :itemchange => :LEFTOVERS,
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
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :MANAPHY,
      :level => 60,
      :item => :LEFTOVERS,
      :moves => [:SCALD, :SHADOWBALL, :RAINDANCE, :TAKEHEART],
      :ability => :HYDRATION,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 1,
      :moninfos => {
        1 => {
          :species => :PHIONE,
          :level => 50,
          :moves => [:WATERPULSE, :ENERGYBALL, :HELPINGHAND, :DAZZLINGGLEAM],
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
          PBStats::SPATK => -3,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "<char>ODESSA: The Prince of the Sea's tail shines bright. Be blinded by its glow!",
        :statusCure => true,
        :itemchange => :LEFTOVERS,
        :bossStatChanges => {
          PBStats::SPATK => 3,
        },
        :queueDelays => [:DimTheGlow],
      },
      1 => {
        :threshold => 0,
        :message => "<char>ODESSA: The Prince can command the seas themselves. Such as a Prince should! Be purged by the sacred waters of Kristiline!",
        :fieldChange => :WATERSURFACE,
        :movesetUpdate => [:ENERGYBALL, :ICEBEAM, :SCALD, :TAKEHEART],
        :fieldChangeMessage => "The battlefield was driven into the open sea!",
        :itemchange => :ELEMENTALSEED,
      },
    },
  },

  :RIFTGALVANTULA => {
    :name => "Rift Galvantula",
    :shieldCount => 2,
    :entryText => "Joltik swarm the egg...",
    :immunities => {},
    :moninfo => {
      :species => :GALVANTULA,
      :level => 25,
      :form => 2,
      :moves => [:ELECTROWEB, :BUGBITE, :CROSSPOISON, :TOXICTHREAD],
      :gender => :F,
      :nature => :HASTY,
      :iv => 20,
      :happiness => 255,
      :ev => [32, 32, 32, 32, 32, 32],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :moninfos => {
        1 => {
          :species => :JOLTIK,
          :level => 20,
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
        :abilitychange => :UNNERVE,
        :movesetUpdate => [:ELECTROWEB, :LUNGE, :CROSSPOISON, :VENOSHOCK],
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
      :level => 28,
      :form => 1,
      :moves => [:STEAMERUPTION, :HEATWAVE, :SCORCHINGSANDS, :ROCKSLIDE],
      :nature => :ADAMANT,
      :iv => 31,
      :happiness => 255,
      :ev => [40, 40, 40, 0, 40, 40],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Volcanion is losing motivation...",
        :movesetUpdate => [:SCALD, :INCINERATE, :MUDSHOT, :ROCKTOMB],
        :bossStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
          PBStats::SPATK => -1,
          PBStats::SPEED => -1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "Volcanion is losing motivation...",
        :movesetUpdate => [:WATERGUN, :EMBER, :MUDSLAP, :ROCKTHROW],
        :bossStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => -2,
          PBStats::SPATK => -1,
          PBStats::SPDEF => -2,
          PBStats::SPEED => -2,
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
      :level => 30,
      :moves => [:SHADOWPUNCH, :WILLOWISP, :INFESTATION, :PAYBACK],
      :gender => :M,
      :nature => :ADAMANT,
      :iv => 31,
      :form => 1,
      :ev => [100, 100, 32, 32, 32, 32],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Dusknoir is about to throw hands!",
        :movesetUpdate => [:SHADOWPUNCH, :WILLOWISP, :ICEPUNCH, :THUNDERPUNCH],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
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
      :level => 35,
      :moves => [:SHADOWCLAW, :DRAGONBREATH, :SLASH, :ICYWIND],
      :nature => :HARDY,
      :item => :GRISEOUSCORE,
      :iv => 31,
      :form => 1,
      :ev => [52, 80, 32, 80, 32, 32],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Giratina's ghastly aura lowered offenses!",
        :statDropCure => true,
        :playerSideStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::SPATK => -1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "Giratina's aura enveloped the battlefield!",
        :bossStatChanges => {
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
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
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :CROBAT,
      :level => 38,
      :moves => [:CROSSPOISON, :BITE, :ACROBATICS, :PROTECT],
      :ability => :INFILTRATOR,
      :gender => :F,
      :nature => :NAUGHTY,
      :item => :FLYINGGEM,
      :iv => 31,
      :happiness => 255,
      :ev => [40, 40, 40, 40, 40, 40],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 10",
      :continuous => true,
      :moninfos => {
        1 => {
          :species => :ZUBAT,
          :level => 32,
          :moves => [:CONFUSERAY, :POISONFANG, :TORMENT, :THIEF],
          :ability => :INNERFOCUS,
          :iv => 31,
        },
        2 => {
          :species => :WOOBAT,
          :level => 32,
          :moves => [:CONFUSION, :CHARM, :HELPINGHAND, :AIRSLASH],
          :ability => :UNAWARE,
          :iv => 31,
        },
        3 => {
          :species => :NOIBAT,
          :level => 32,
          :moves => [:SUPERFANG, :WHIRLWIND, :AIRSLASH, :DRAGONRUSH],
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
        :movesetUpdate => [:BRAVEBIRD, :CROSSPOISON, :PROTECT, :LEECHLIFE],
        :itemchange => :SITRUSBERRY,
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
      :moves => [:DECIMATION, :HURRICANE, :FOCUSBLAST, :DARKPULSE],
      :nature => :MODEST,
      :iv => 31,
      :ev => [48, 48, 48, 48, 48, 48],
    },
  },

  :TAPUKOKOJUNGLE => {
    :name => "Thunder Warrior",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :TAPUKOKO,
      :level => 50,
      :shiny => true,
      :moves => [:STEELWING, :NATURESMADNESS, :ELECTRICTERRAIN, :DISCHARGE],
      :nature => :TIMID,
      :ability => :ELECTRICSURGE,
      :iv => 20,
      :happiness => 255,
      :ev => [32, 32, 32, 32, 32, 32],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Tapu Koko is putting in its all!!",
        :movesetUpdate => [:ELECTROBALL, :TAUNT, :ROOST, :DAZZLINGGLEAM],
        :statDropCure => true,
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
      :level => 50,
      :moves => [:FRUSTRATION, :ICEPUNCH, :FIREPUNCH, :THUNDERPUNCH],
      :ability => :IRONFIST,
      :gender => :M,
      :nature => :ADAMANT,
      :iv => 31,
      :happiness => 0,
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 1",
      :continuous => true,
      :moninfos => {
        1 => {
          :species => :TIMBURR,
          :level => 40,
          :moves => [:COACHING, :HELPINGHAND, :ROCKSLIDE, :HAMMERARM],
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
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
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
      :level => 45,
      :form => 1,
      :moves => [:DRAGONDANCE, :POWERWHIP, :DRAGONPULSE, :FLAMETHROWER],
      :ability => :OWNTEMPO,
      :gender => :M,
      :nature => :BRAVE,
      :item => :YACHEBERRY,
      :iv => 31,
      :happiness => 255,
      :ev => [40, 40, 40, 40, 40, 40],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 4,
      :moninfos => {
        1 => {
          :species => :TANGELA,
          :level => 40,
          :form => 1,
          :item => :LEFTOVERS,
          :moves => [:FOLLOWME, :SWAGGER, :POLLENPUFF, :PETALDANCE],
          :ability => :DANCER,
          :gender => :F,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
          :ev => [0, 128, 0, 128, 0, 252],
        },
        2 => {
          :species => :TANGROWTH,
          :level => 40,
          :form => 1,
          :item => :LEFTOVERS,
          :moves => [:FOLLOWME, :QUASH, :POLLENPUFF, :ROCKTOMB],
          :ability => :DANCER,
          :gender => :M,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 128, 0, 128, 0, 0],
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :animation => :SHIFTGEAR,
        :message => ["The rhythm of the music has changed!", "Carnivine did the robot and became Steel-type!"],
        :typeChange => [:GRASS, :STEEL],
        :movesetUpdate => [:SHIFTGEAR, :POWERWHIP, :IRONHEAD, :FIRELASH],
        :statChangeRefresh => true,
        :itemchange => :OCCABERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPATK => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => -1,
        },
        :playerSideStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPATK => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => -1,
        },
      },
      1 => {
        :threshold => 0,
        :animation => :QUIVERDANCE,
        :message => ["The rhythm of the music has changed!", "Carnivine did the jitterbug and became Bug-type!"],
        :typeChange => [:GRASS, :BUG],
        :movesetUpdate => [:QUIVERDANCE, :LEAFSTORM, :POLLENPUFF, :FIERYDANCE],
        :statChangeRefresh => true,
        :itemchange => :BUGGEM,
        :bossStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => -1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
        },
        :playerSideStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => -1,
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
    :shieldCount => 2,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :TAPUKOKO,
      :level => 50,
      :shiny => true,
      :item => :TELLURICSEED,
      :moves => [:LIGHTSCREEN, :BRAVEBIRD, :WILDCHARGE, :REFLECT],
      :nature => :NAIVE,
      :ability => :ELECTRICSURGE,
      :iv => 31,
      :happiness => 255,
      :ev => [85, 85, 85, 85, 85, 85],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount <= 2",
      :refreshingRequirement => [0],
      :entryMessage => ["Charizard charged into the fight!", "The Thunder Warrior revitalized Charizard's energy!"],
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :CHARIZARD,
          :level => 48,
          :gender => :F,
          :item => :CHARTIBERRY,
          :moves => [:HEATWAVE, :AIRSLASH, :FOCUSBLAST, :ROOST],
          :ability => :BLAZE,
          :shiny => true,
          :nature => :TIMID,
          :iv => 31,
          :ev => [85, 85, 85, 85, 85, 85],
        },
        2 => {
          :species => :CHARIZARD,
          :level => 48,
          :gender => :F,
          :item => :CHARIZARDITEX,
          :moves => [:EARTHQUAKE, :DRAGONCLAW, :HEATWAVE, :THUNDERPUNCH],
          :ability => :BLAZE,
          :shiny => true,
          :nature => :BRAVE,
          :iv => 31,
          :ev => [85, 85, 85, 85, 85, 85],
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :itemchange => :SITRUSBERRY,
        :movesetUpdate => [:WILDCHARGE, :BRAVEBIRD, :ELECTROWEB, :DAZZLINGGLEAM],
      },
      1 => {
        :threshold => 0,
        :abilitychange => :TELEPATHY,
        :overlay => [:ELECTERRAIN, "Electricity permeates the area!", 8, :ELECTRICTERRAIN],
        :itemchange => :LIFEORB,
        :message => "Tapu Koko is putting in its all!!",
        :movesetUpdate => [:WILDCHARGE, :BRAVEBIRD, :ELECTROWEB, :DAZZLINGGLEAM],
      },
    },
  },

  :BOSS_CHAOTICFUSION => {
    :name => "Chaotic Fusion",
    :entryText => "The fused Pokémon suddenly attacked!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :SOLROCK,
      :level => 52,
      :moves => [:WILLOWISP, :ROCKTOMB, :SOLARFLARE, :MORNINGSUN],
      :nature => :QUIRKY,
      :iv => 31,
      :form => 1,
      :ability => :SOLARIDOL,
      :item => :SITRUSBERRY,
      :ev => [252, 0, 252, 0, 4, 0],
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
      2 => {
        :animation => :FLASH,
        :weatherChange => [:SUNNYDAY, 5, nil],
        :threshold => 0,
        :message => "Solrock is leading the charge!",
        :itemchange => :FLAMEPLATE,
        :speciesUpdate => :SOLROCK,
        :formchange => 1,
        :abilitychange => :SOLARIDOL,
        :statDropCure => true,
        :statusCure => true,
        :movesetUpdate => [:ZENHEADBUTT, :STONEEDGE, :SOLARFLARE, :MORNINGSUN],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
        },
      },
      1 => {
        :animation => :FLASH,
        :weatherChange => [:SNOWSCAPE, 5, nil],
        :threshold => 0,
        :message => "Lunatone is desperate!",
        :itemchange => :ICICLEPLATE,
        :speciesUpdate => :LUNATONE,
        :formchange => 1,
        :abilitychange => :LUNARIDOL,
        :movesetUpdate => [:PSYCHIC, :MOONBLAST, :HOARFROSTMOON, :MOONLIGHT],
        :bossStatChanges => {
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
        },
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
      :level => 50,
      :moves => [:CURSE, :BODYPRESS, :ROCKSLIDE, :EARTHQUAKE],
      :nature => :IMPISH,
      :iv => 31,
      :shiny => true,
      :item => :SITRUSBERRY,
      :ev => [100, 52, 252, 0, 100, 0],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Regirock hardened up!",
        :statDropCure => true,
        :playersideChanges => {
          :StealthRock => [true, :STEALTHROCK, "Floating rocks were deployed!"],
        },
        :itemchange => :SITRUSBERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 2,
          PBStats::SPDEF => 2,
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
      :level => 50,
      :moves => [:CURSE, :BODYPRESS, :IRONHEAD, :EARTHQUAKE],
      :nature => :IMPISH,
      :iv => 31,
      :shiny => true,
      :item => :SITRUSBERRY,
      :ev => [100, 52, 252, 0, 100, 0],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Registeel hardened up!",
        :statDropCure => true,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "Spikes were deployed!"],
        },
        :itemchange => :SITRUSBERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 2,
          PBStats::SPDEF => 2,
        },
      },
    },
  },

  :BOSSKYOGRE => {
    :name => "Leviathan Kyogre",
    :entryText => "Kyogre's power is overwhelming!",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :KYOGRE,
      :level => 60,
      :moves => [:MUDDYWATER, :ICEBEAM, :ANCIENTPOWER, :CALMMIND],
      :nature => :MODEST,
      :iv => 31,
      :ev => [85, 85, 85, 85, 85, 85],
    },
    :delayedactions => {
      :WhirlpoolStart => {
        :delay => 1,
        :message => "Whirlpools are forming...",
        :playerSideStatChanges => {
          PBStats::SPEED => -1,
        },
        :queueDelays => [:WhirlpoolFull],
      },
      :WhirlpoolFull => {
        :delay => 1,
        :message => "Whirlpools have fully formed!",
        :playerEffects => {
          :WHIRLPOOL => [8, :WHIRLPOOL, nil],
        },
        :queueDelays => [:WhirlpoolRepeat],
      },
      :WhirlpoolRepeat => {
        :delay => 1,
        :playerEffects => {
          :WHIRLPOOL => [8, :WHIRLPOOL, nil],
        },
        :queueDelays => [:WhirlpoolRepeat],
      },
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :message => "Kyogre summoned a storm and flooded the arena!",
        :weatherChange => [:RAINDANCE, -1, nil],
        :fieldChange => :WATERSURFACE,
        :movesetUpdate => [:WHIRLPOOL, :THUNDERBOLT, :ANCIENTPOWER, :SCARYFACE],
        :queueDelays => [:WhirlpoolStart],
      },
      2 => {
        :threshold => 0,
        :instantMove => [:DIVE, 1],
        :movesetUpdate => [:DIVE, :THUNDERBOLT, :ICEBEAM, :DOUBLEEDGE],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => -2,
        },
      },
      1 => {
        :threshold => 0,
        :message => "Kyogre let out a terrifying roar!",
        :animation => :NOBLEROAR,
        :instantMove => [:HYPERVOICE, 1],
        :playerSideStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => -2,
          PBStats::SPDEF => -2,
          PBStats::SPATK => -1,
        },
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
      :moves => [:EARTHQUAKE, :ROCKSLIDE, :TOXIC, :HEATCRASH],
      :nature => :ADAMANT,
      :iv => 31,
      :item => :SITRUSBERRY,
      :ev => [100, 252, 52, 0, 0, 100],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Groudon summoned fierce eruptions!",
        :weatherChange => [:SUNNYDAY, -1, nil],
        :fieldChange => :VOLCANIC,
        :movesetUpdate => [:EARTHQUAKE, :STONEEDGE, :SWORDSDANCE, :HEATWAVE],
        :statDropCure => true,
      },
    },
  },

  :VALORGIRATINA => {
    :name => "Giratina..?",
    :entryText => "Giratina is blocking the way forward!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :GIRATINA,
      :level => 57,
      :moves => [:HEX, :SLUDGEBOMB, :EARTHPOWER, :SPIKES],
      :nature => :QUIET,
      :form => 2,
      :iv => 31,
      :ev => [85, 85, 85, 85, 85, 85],
      :slidein => true,
    },
    :delayedactions => {
      :WastelandSpikes => {
        :delay => 1,
        :playersideChanges => {
          :ToxicSpikes => [1, :TOXICSPIKES, "Toxic Spikes were set up!"],
        },
        :queueDelays => [:WastelandSpikes],
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :queueDelays => [:WastelandSpikes],
        :message => "Giratina drew power from the Distortion World!",
        :statDropCure => true,
        :formchange => 3,
        :itemchange => :GRISEOUSORB,
        :movesetUpdate => [:DRAGONPULSE, :VENOSHOCK, :STEALTHROCK, :SPIKES],
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
      :level => 64,
      :moves => [:SLUDGEWAVE, :DRAGONPULSE, :DARKPULSE, :FIREBLAST],
      :nature => :NAUGHTY,
      :iv => 31,
      :ev => [85, 85, 85, 85, 85, 85],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :speciesUpdate => :PORYGONZ,
        :message => "a Vir us in  d e  ed ",
        :abilitychange => :WONDERGUARD,
        :itemchange => :TOXICORB,
      },
      2 => {
        :threshold => 0,
        :speciesUpdate => :BLACEPHALON,
        :movesetUpdate => [:MINDBLOWN, :SHADOWBALL, :NASTYPLOT, :PRESENT],
        :message => "F u n t i m e s w i t h e v e r y o n e ' s b a d e n d i n g",
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
        },
      },
      1 => {
        :threshold => 0,
        :speciesUpdate => :PIDGEY,
        :message => "Can you even beat a Pidgey? Likely not.",
      },
    },
  },

  :LAVALAKAZAM => {
    :name => "Alakazam",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :ALAKAZAM,
      :level => 65,
      :gender => :M,
      :moves => [:CALMMIND, :REFLECT, :LIGHTSCREEN, :NIGHTSHADE],
      :nature => :TIMID,
      :iv => 31,
      :ev => [85, 85, 85, 85, 85, 85],
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
          PBStats::SPEED => 2,
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
      :item => :LUMBERRY,
      :moves => [:DARKPULSE, :MOONBLAST, :CALMMIND, :PSYSHOCK],
      :nature => :TIMID,
      :form => 2,
      :iv => 31,
      :ev => [0, 0, 0, 252, 0, 252],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :bosssideChanges => {
          :Reflect => [5, :REFLECT, nil],
          :Safeguard => [5, :SAFEGUARD, "Gardevoir quickly set up protection!"],
        },
        :statDropCure => true,
      },
    },
  },

  # Umbrals Bosses

  :UMBRALGARDEVOIR => {
    :name => "Umbral Gardevoir",
    :entryText => "Umbral magic envelops Gardevoir!",
    :shieldCount => 3,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :GARDEVOIR,
      :level => 60,
      :item => :SITRUSBERRY,
      :ability => :TELEPATHY,
      :moves => [:DARKPULSE, :DAZZLINGGLEAM, :CALMMIND, :PSYSHOCK],
      :nature => :TIMID,
      :form => 2,
      :iv => 31,
      :ev => [0, 252, 0, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 6",
      :continuous => true,
      :totalMonCount => 3,
      :moninfos => {
        1 => {
          :species => :ZOROARK,
          :level => 60,
          :moves => [:SNARL, :WILLOWISP, :BITTERMALICE, :HYPERVOICE],
          :item => :COLBURBERRY,
          :form => 1,
          :gender => :M,
          :shiny => true,
          :nature => :TIMID,
          :ev => [0, 0, 0, 252, 0, 252],
          :iv => 31,
        },
        2 => {
          :species => :KOMMOO,
          :level => 60,
          :moves => [:BOOMBURST, :CLOSECOMBAT, :CLANGINGSCALES, :DRAGONDANCE],
          :gender => :M,
          :item => :COBABERRY,
          :ability => :SOUNDPROOF,
          :nature => :HARDY,
          :ev => [152, 152, 0, 100, 0, 100],
          :iv => 31,
        },
        3 => {
          :species => :TINGLU,
          :level => 60,
          :moves => [:HEAVYSLAM, :ROCKSLIDE, :EARTHQUAKE, :THROATCHOP],
          :item => :SYNTHETICSEED,
          :ev => [252, 252, 0, 0, 0, 0],
          :nature => :SASSY,
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "MR.LuCk wHy WaSn'T I goOD EnOuGh...? DiD I nOt EnTeRTaIN?!",
        :fieldChange => :BIGTOP,
        :animation => :ENCORE,
        :weatherChange => [:SUNNY, -1, "Spotlights on her! Bask in her wonder!"],
        :typeChange => [:FAIRY, :FIRE],
        :movesetUpdate => [:FIRELASH, :ALLURINGVOICE, :DAZZLINGGLEAM, :TORCHSONG],
        },
      2 => {
        :threshold => 0,
        :message => "aLl tHe ChIlDrEN laUGhEd aNd PlAyEd wItH Me... WaS ThAT nOt EnOuGh?",
        :typeChange => [:FAIRY, :WATER],
        :weatherChange => [:RAINDANCE, -1, "Sprinklers emerge from the top of the trees! Rain pours down!"],
        :movesetUpdate => [:SPARKLINGARIA, :ALLURINGVOICE, :PSYCHICNOISE, :HYPERVOICE],
        :bosssideChanges => {
          :Reflect => [5, :REFLECT, nil],
          :Safeguard => [5, :SAFEGUARD, "Gardevoir quickly set up protection!"],
        },
        :itemchange => :LUMBERRY,
      },
      1 => {
        :threshold => 0,
        :message => "mYTrIcKsArELoVeDByAlLBuTnOtByYou........... ",
        :typeChange => [:FAIRY, :GRASS],
        :movesetUpdate => [:POWERWHIP, :BOUNCE, :PLAYROUGH, :FLOWERTRICK],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
    },
  },

  :UMBRALSHIFTRY => {
    :name => "Umbral Shiftry",
    :entryText => "Umbral magic envelops Shiftry!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :SHIFTRY,
      :level => 60,
      :item => :LUMBERRY,
      :moves => [:KNOCKOFF, :SEEDBOMB, :SWORDSDANCE, :HURRICANE],
      :nature => :TIMID,
      :ability => :WINDRIDER,
      :iv => 31,
      :ev => [0, 252, 0, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 6",
      :continuous => true,
      :totalMonCount => 3,
      :moninfos => {
        1 => {
          :species => :BRAMBLEGHAST,
          :level => 60,
          :moves => [:POLTERGEIST, :POWERWHIP, :STRENGTHSAP, :SPIKES],
          :ability => :WINDRIDER,
          :iv => 31,
        },
        2 => {
          :species => :SHIFTRY,
          :level => 60,
          :moves => [:TAILWIND, :KNOCKOFF, :FOULPLAY, :FAKEOUT],
          :ability => :WINDRIDER,
          :iv => 31,
        },
        3 => {
          :species => :KILOWATTREL,
          :level => 60,
          :moves => [:HURRICANE, :TAILWIND, :ELECTROBALL, :THUNDERBOLT],
          :ability => :WINDPOWER,
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Shiftry suddenly loses its connection to the flora...",
        :typeChange => [:DARK, :FLYING],
        :movesetUpdate => [:SUCKERPUNCH, :HURRICANE, :SWORDSDANCE, :NIGHTSLASH],
        :itemchange => :LIFEORB,
        :bossStatChanges => {
          PBStats::ATTACK => 2,
        },
        :statDropCure => false,
      },
      1 => {
        :threshold => 0,
        :message => "An Aerial finish! Shiftry takes the battle to the high skies!",
        :animation => :WONDERROOM,
        :fieldChange => :SKY,
        :weatherChange => [:STRONGWINDS, -1, "The winds pick up heavily!"],
        :movesetUpdate => [:NIGHTSLASH, :FLY, :HURRICANE, :NATUREPOWER],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
        :statDropCure => true,
      },
    },
  },

  :UMBRALUNOWN => {
    :name => "Umbral Unown",
    :entryText => "The Unown shudders in place...",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :UNOWN,
      :level => 65,
      :moves => [:HIDDENPOWER, nil, nil, nil],
      :nature => :TIMID,
      :form => 28,
      :ability => :SLOWSTART,
      :gender => :F,
      :hptype => :FAIRY,
      :iv => 31,
      :ev => [42, 252, 42, 252, 42, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :ARCHEOPS,
          :level => 60,
          :moves => [:ACROBATICS, :STONEEDGE, :STRENGTHSAP, :HEADSMASH],
          :item => :FLYINGGEM,
          :iv => 31,
          :ev => [42, 252, 42, 0, 42, 252],
        },
        2 => {
          :species => :GIGALITH,
          :level => 60,
          :moves => [:STEALTHROCK, :STONEEDGE, :EARTHQUAKE, :SANDSTORM],
          :iv => 31,
          :ev => [42, 252, 252, 0, 42, 0],
        },
      },
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :message => "<char>KARRINA: tHe CiTy sTrEeTs aRe SaFe WiTh Me ArOunD!!",
        :animation => :MEGAEVOLUTION,
        :speciesUpdate => :GRANBULL,
        :formchange => 0,
        :shiny => true,
        :abilitychange => :INTIMIDATE,
        :fieldChange => :BACKALLEY,
        :movesetUpdate => [:CRUNCH, :PLAYROUGH, :FIREFANG, :GIGAIMPACT],
      },
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
        :statDropCure => false,
      },
      2 => {
        :threshold => 0,
        :message => "<char>KARRINA: tHe hiDdEn LiBrARy... iT's OpEn?? wHy is it... MoM?? DaD??! WhO... ArE... YoU...???",
        :bgmChange => "Battle - Conclusive",
        :animation => :MEGAEVOLUTION,
        :speciesUpdate => :DIANCIE,
        :formchange => 0,
        :itemchange => :DIANCITE,
        :abilitychange => :ROCKHEAD,
        :fieldChange => :CRYSTALCAVERN,
        :movesetUpdate => [:DIAMONDSTORM, :PROTECT, :MOONBLAST, :EARTHPOWER],
        :statDropCure => false,
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
          PBStats::SPATK => 6,
        },
        :statDropCure => true,
      },
    }
  },

  :UMBRALDEOXYS => {
    :name => "Umbral Deoxys",
    :entryText => "Deoxys looks up into space... Something appears.",
    :shieldCount => 4,
    :immunities => {},
    :delayedactions => {
      :MeteorShrapnel => {
        :delay => 2,
        :turntypeDamage => [:ROCK, :ROCKTOMB, 8, "Shrapnel from the approaching meteor crashed down!"],
        :queueDelays => [:MeteorShrapnel],
      },
    },
    :onEntryEffects => {
      :message => "<char>VIVIAN: That Deoxys summoned another meteorite... We have to stop it before it destroys all of Route 4!",
      :queueDelays => [:MeteorShrapnel],
    },
    :chargeAttack => {
      :turns => 10,
      :continueCharging => true,
      :canAttack => true,
      :chargeAttackMessage => "The meteor has reached Route 4!",
      :chargeAttackAnimation => :DRACOMETEOR,
    },
    :moninfo => {
      :species => :DEOXYS,
      :level => 70,
      :moves => [:SHADOWBALL, :SPIKES, :ICEBEAM, :LIGHTSCREEN],
      :nature => :NAIVE,
      :ability => :PRESSURE,
      :item => :FOCUSSASH,
      :form => 3,
      :iv => 31,
      :ev => [0, 252, 0, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 3",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :DEOXYS,
          :level => 65,
          :moves => [:LIGHTSCREEN, :REFLECT, :THUNDERWAVE, :SHADOWBALL],
          :item => :LEFTOVERS,
          :ability => :MAGICGUARD,
          :form => 4,
          :iv => 31,
          :ev => [42, 252, 42, 0, 42, 252],
        },
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :movesetUpdate => [:PSYCHOBOOST, :SUPERPOWER, :KNOCKOFF, :STEALTHROCK],
        :playersideChanges => {
          :Spikes => [1, :SPIKES, nil],
        },
      },
      2 => {
        :threshold => 0,
        :message => "Deoxys changed form!",
        :animation => :TRANSFORM,
        :formchange => 1,
        :movesetUpdate => [:LOWKICK, :SHADOWBALL, :ROCKSLIDE, :PSYCHIC],
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :statDropCure => true,
      },
      1 => {
        :threshold => 0,
        :message => "Deoxys changed form!",
        :bgmChange => "RSE - Boss_1",
        :animation => :MEGAEVOLUTION,
        :abilitychange => :MAGICGUARD,
        :formchange => 2,
        :movesetUpdate => [:PROTECT, :RECOVER, :KNOCKOFF, :TOXIC],
        :bossStatChanges => {
          PBStats::DEFENSE => 2,
          PBStats::SPDEF => 2,
        },
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
      :level => 75,
      :moves => [:THOUSANDARROWS, :THOUSANDWAVES, :ROCKSLIDE, :COIL],
      :nature => :JOLLY,
      :form => 1,
      :item => :TELLURICSEED,
      :shiny => true,
      :ability => :AURABREAK,
      :iv => 31,
      :ev => [252, 252, 0, 252, 0, 252]
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "<char>VIVIAN: i'Ll rEpAiR It AlL wItH ZygArdE",
        :animation => :COREENFORCER,
        :itemchange => :YACHEBERRY,
        :formchange => 0,
        :abilitychange => :AURABREAK,
        :shiny => true,
        :bossStatChanges => {
          PBStats::SPATK => 2,
        },
        :movesetUpdate => [:ROCKSLIDE, :THOUSANDWAVES, :LANDSWRATH, :COREENFORCER],
      },
    },
  },

  :UMBRALREGIROCK => {
    :name => "Umbral Regirock",
    :entryText => "Regirock starts to shake...",
    :shieldCount => 5,
    :immunities => {},
    :moninfo => {
      :species => :REGIROCK,
      :level => 75,
      :moves => [:DRAINPUNCH, :BODYPRESS, :ROCKSLIDE, :EARTHQUAKE],
      :nature => :IMPISH,
      :iv => 31,
      :shiny => true,
      :item => :LEFTOVERS,
      :ev => [100, 52, 252, 0, 100, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 6",
      :continuous => true,
      :moninfos => {
        1 => {
          :species => :REGIROCK,
          :level => 75,
          :moves => [:WHIRLWIND, :TOXIC, :FOLLOWME, :GRAVITY],
          :name => "ADMIN",
          :item => :MENTALHERB,
          :ability => :WONDERGUARD,
          :form => 1,
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      5 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>ADMIN: Do exactly as I ask, you selfish child.",
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "Hidden spikes were deployed!"],
        },
      },
      4 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>ADMIN: Another failure. You must become perfect!",
        :playersideChanges => {
          :StealthRock => [true, :STEALTHROCK, "Floating rocks were deployed!"],
        },
      },
      3 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>ADMIN: You are to protect your master... If she falls, you shall too.",
        :playersideChanges => {
          :Spikes => [2, :SPIKES, "Hidden spikes were deployed!"],
        },
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPEED => 1,
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
        :itemchange => :ROCKIUMZ,
        :bossStatChanges => {
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :UMBRALXURKITREE => {
    :name => "Umbral Xurkitree",
    :entryText => "Xurkitree is surging with power.",
    :shieldCount => 5,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :XURKITREE,
      :level => 80,
      :moves => [:THUNDERBOLT, :DAZZLINGGLEAM, :ENERGYBALL, :CALMMIND],
      :nature => :BOLD,
      :iv => 31,
      :item => :AIRBALLOON,
      :ev => [252, 0, 252, 0, 0, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount <= 5",
      :continuous => true,
      :totalMonCount => 4,
      :moninfos => {
        1 => {
          :species => :CLAWITZER,
          :level => 80,
          :moves => [:WATERPULSE, :DARKPULSE, :AURASPHERE, :DRAGONPULSE],
          :item => :WACANBERRY,
          :ability => :MEGALAUNCHER,
          :iv => 31,
          :ev => [42, 0, 42, 252, 252, 0],
        },
        2 => {
          :species => :RAICHU,
          :level => 80,
          :form => 1,
          :moves => [:FAKEOUT, :THUNDERBOLT, :PSYCHIC, :FOCUSBLAST],
          :item => :PSYCHICGEM,
          :iv => 31,
          :ev => [4, 0, 0, 252, 0, 252],
        },
        3 => {
          :species => :SWAMPERT,
          :level => 80,
          :moves => [:WATERFALL, :ROCKSLIDE, :HIGHHORSEPOWER, :ICEPUNCH],
          :item => :SWAMPERTITE,
          :iv => 31,
          :ev => [252, 252, 0, 0, 0, 0],
        },
        4 => {
          :species => :EELEKTROSS,
          :level => 80,
          :moves => [:THUNDERBOLT, :FLAMETHROWER, :GIGADRAIN, :DRAGONPULSE],
          :item => :ASSAULTVEST,
          :iv => 31,
          :ev => [252, 0, 0, 252, 0, 0],
        },
      },
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>KIERAN: cLeAr, wE nEeD tO KeEP aN eYe oN eDen. tHeY aRe DiVerGiNg.",
        :playersideChanges => {
          :ToxicSpikes => [1, :TOXICSPIKES, "Toxic Spikes were deployed!"],
        },
      },
      3 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>KIERAN: eDeN, lEaVe tHat gIrL AloNE... StAY fOCusEd ON tHe MisSiOn...",
        :fieldChange => :PSYTERRAIN,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
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
        :itemchange => :LIFEORB,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :statDropCure => true,
      },
    },
  },

  :UMBRALMEOWTH => {
    :name => "Umbral Meowth",
    :entryText => "Meowth's long body fills the room!",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :MEOWTH,
      :level => 85,
      :moves => [:FAKEOUT, :KNOCKOFF, :AERIALACE, :HONECLAWS],
      :nature => :IMPISH,
      :iv => 31,
      :ability => :GOODASGOLD,
      :shiny => true,
      :form => 3,
      :item => :LEFTOVERS,
      :ev => [100, 252, 52, 52, 52, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 4",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :GHOLDENGO,
          :level => 65,
          :moves => [:MAKEITRAIN, :METALSOUND, :SHADOWBALL, :NASTYPLOT],
          :item => :LIFEORB,
          :iv => 31,
        },
        2 => {
          :species => :GHOLDENGO,
          :level => 65,
          :moves => [:SUBSTITUTE, :LIGHTSCREEN, :REFLECT, :SHADOWBALL],
          :item => :LEFTOVERS,
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>ACE: gRaNdPapPY Is Sick!!!!!! GoTtA FiNd ThE cUrE fASt!!!!!!!",
        :typeChange => [:NORMAL, :POISON],
        :fieldChange => :WASTELAND,
        :animation => :TOXIC,
        :movesetUpdate => [:SLUDGEWAVE, :VENOMDRENCH, :FOULPLAY, :POWERWHIP],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
        },
      },
      3 => {
        :threshold => 0,
        :effect => nil,
        :message => "<char>ACE: cAN't fInD a CurE... BUUUT I goT a nIce Job...",
        :animation => :PAYDAY,
        :bossStatChanges => {
          PBStats::SPDEF => 1,
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
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :UMBRALNIGHTMARE => {
    :name => "Umbral Nightmare",
    :entryText => "<char>SHAYDA: ...? wHo tHe HeLl iS tHiS mAn??!",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :DARKRAI,
      :level => 80,
      :form => 8,
      :moves => [:SPIRITBREAK, :PSYCHIC, :AURORAVEIL, :THROATCHOP],
      :nature => :BRAVE,
      :shiny => true,
      :item => :PSYCHICGEM,
      :iv => 31,
      :happiness => 0,
      :ev => [4, 252, 0, 252, 0, 0],
    },
    :delayedactions => {
      :TurtleSaysNightmares1 => {
        :delay => 1,
        :message => "A new world will dawn in five turns...",
        :queueDelays => [:TurtleSaysNightmares2],
      },
      :TurtleSaysNightmares2 => {
        :delay => 4,
        :fieldChange => :NEWWORLD,
        :playerEffects => {
          :Yawn => [1, :YAWN, "<char>EIZEN: My turtle says you are going to experience some nightmares now."],
        },
        :stateChanges => {
          :FairyLock => [1, :FAIRYLOCK, "No one will be able to run away during the next turn!"],
        },
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 2,
        },
      },
    },
    :onEntryEffects => {
      :fieldChange => :STARLIGHT,
      :message => "<char>EIZEN: I believe this is the part where you fall asleep.",
      :queueDelays => [:TurtleSaysNightmares1],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "<char>EIZEN: No fairy tale, but this isn't reality either.",
        :bgmChange => "Battle - Inconsistent_sea",
        :movesetUpdate => [:DARKPULSE, :FLAMETHROWER, :PSYSHOCK, :MOONLIGHT],
        :itemchange => :ROSELIBERRY,
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, nil],
        },
      },
      2 => {
        :threshold => 0,
        :message => "<char>EIZEN: If you wake up, you won't like what you see...",
        :movesetUpdate => [:DOOMDESIRE, :VACUUMWAVE, :DARKPULSE, :ANCIENTPOWER],
        :itemchange => :FIGHTINGGEM,
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        }
      },
      1 => {
        :threshold => 0,
        :message => "<char>EIZEN: My turtle just growled at you.",
        :playerEffects => {
          :Nightmare => [true, :NIGHTMARE, "<char>EIZEN: My turtle says you are going to experience even more nightmares now."],
        },
        :itemchange => :STEELGEM,
        :movesetUpdate => [:METEORMASH, :COMETPUNCH, :THROATCHOP, :PSYSTRIKE],
      },
    },
  },

  :UMBRALANGEL => {
    :name => "Umbral Angel",
    :entryText => "<char>EIZEN: I'll take it from here.",
    :shieldCount => 3,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :GARDEVOIR,
      :level => 80,
      :form => 3,
      :shiny => true,
      :moves => [:DARKPULSE, :LOVELYKISS, :DAZZLINGGLEAM, :MYSTICALFIRE],
      :gender => :F,
      :nature => :SERIOUS,
      :iv => 31,
      :happiness => 255,
      :ev => [85, 85, 85, 85, 85, 85],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => false,
      :totalMonCount => 1,
      :moninfos => {
        1 => {
          :species => :RALTS,
          :level => 70,
          :form => 1,
          :moves => [:TORMENT, :HELPINGHAND, :POISONGAS, :NIGHTSHADE],
          :gender => :F,
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :animation => :SECRETSWORD,
        :message => "<char>EIZEN: The Angel of Death wishes to see you.",
        :bgmChange => "Battle - Inconsistent_sea",
        :movesetUpdate => [:NIGHTSLASH, :LOVELYKISS, :SPIRITBREAK, :PSYCHOCUT],
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
        },
      },
      2 => {
        :threshold => 0,
        :animation => :DAZZLINGGLEAM,
        :message => "<char>EIZEN: This would be the part where my Angel would summon her minions. That might not happen though.",
        :movesetUpdate => [:DARKPULSE, :PSYCHOCUT, :NIGHTSLASH, :SACREDSWORD],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
      },
      1 => {
        :threshold => 0,
        :animation => :DARKPULSE,
        :message => "<char>EIZEN: How furious... Is this how you treat a lady?",
        :itemchange => :DARKINIUMZ,
        :movesetUpdate => [:HYPERSPACEFURY, :MOONBLAST, :EARTHQUAKE, :SACREDSWORD],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
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
      :level => 60,
      :item => :BLACKSLUDGE,
      :moves => [:DRAINPUNCH, :GIGADRAIN, :DARKESTLARIAT, :SLUDGEWAVE],
      :nature => :SASSY,
      :form => 2,
      :shiny => true,
      :iv => 31,
      :ev => [252, 0, 128, 0, 128, 0],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Garbodor gorged itself on rotten berries!",
        :typeChange => [:POISON, :GRASS],
        :movesetUpdate => [:DRAINPUNCH, :GIGADRAIN, :DARKESTLARIAT, :BELCH],
        :itemchange => :SITRUSBERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
        :statDropCure => true,
      },
      2 => {
        :threshold => 0,
        :message => "Garbodor gorged itself on scrap metal!",
        :typeChange => [:POISON, :STEEL],
        :movesetUpdate => [:DRAINPUNCH, :GIGADRAIN, :GYROBALL, :BELCH],
        :itemchange => :METALCOAT,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
        :statDropCure => true,
      },
      1 => {
        :threshold => 0,
        :message => "Garbodor desperately gorged itself on nearby rocks!",
        :typeChange => [:POISON, :ROCK],
        :movesetUpdate => [:ROCKBLAST, :GIGADRAIN, :GYROBALL, :BELCH],
        :itemchange => :ROCKYHELMET,
        :bossStatChanges => {
          PBStats::ATTACK => 2,
          PBStats::DEFENSE => -1,
          PBStats::SPATK => 2,
          PBStats::SPDEF => -1,
        },
        :statDropCure => true,
      },
    },
  },

  :RIFTAELITA => {
    :name => "Rift Aelita",
    :entryText => "Rift Aelita is taking aim...",
    :shieldCount => 5,
    :immunities => {},
    :moninfo => {
      :species => :REGIROCK,
      :level => 75,
      :item => :LIFEORB,
      :moves => [:ROCKSLIDE, :CLOSECOMBAT, :BULLETSEED, :BARRAGE],
      :nature => :BRAVE,
      :form => 2,
      :iv => 31,
      :ev => [0, 252, 0, 252, 0, 4],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 5",
      :totalMonCount => 3,
      :moninfos => {
        1 => {
          :species => :GOLEM,
          :level => 75,
          :moves => [:DOUBLEEDGE, :ROCKSMASH, :STOMPINGTANTRUM, :HEAVYSLAM],
          :ability => :ROCKHEAD,
          :item => :NORMALGEM,
          :gender => :M,
          :iv => 31,
        },
        2 => {
          :species => :GOLEM,
          :level => 75,
          :form => 1,
          :moves => [:FRUSTRATION, :ROCKSLIDE, :FLAIL, :ROCKSMASH],
          :ability => :GALVANIZE,
          :item => :TELLURICSEED,
          :gender => :F,
          :iv => 31,
        },
      },
    },
    :delayedactions => {
      :SniperShot => {
        :delay => 3,
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
        :movesetUpdate => [:ROCKBLAST, :EARTHQUAKE, :POLLENPUFF, :SHADOWBALL],
        :bossStatChanges => {
          PBStats::ACCURACY => 1,
        },
        :fieldChange => :ROCKY,
        :fieldChangeMessage => "The field became littered with rocks!",
        :queueDelays => [:SniperShot],
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
      },
      2 => {
        :threshold => 0,
        :message => "Rift Aelita let out a piercing screech!",
        :bosssideChanges => {
          :AreniteWall => [8, :ARENITEWALL, nil],
        },
        :movesetUpdate => [:ROCKBLAST, :TRIPLEARROWS, :SLUDGEBOMB, :ENERGYBALL],
      },
      1 => {
        :threshold => 0,
        :message => "Rift Aelita is cornered...",
        :movesetUpdate => [:ROCKSLIDE, :TRIPLEARROWS, :ACCELEROCK, :ZAPCANNON],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
        },
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
      :level => 70,
      :moves => [:DRAINPUNCH, :BODYPRESS, :ROCKSLIDE, :EARTHQUAKE],
      :nature => :IMPISH,
      :iv => 31,
      :shiny => true,
      :item => :LEFTOVERS,
      :ev => [100, 52, 252, 0, 100, 0],
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
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :ADMIN => {
    :name => "ADMIN",
    :shieldCount => 1,
    :immunities => {},
    :canrun => true,
    :moninfo => {
      :species => :REGIROCK,
      :level => 70,
      :moves => [:DRAINPUNCH, :BODYPRESS, :ROCKSLIDE, :EARTHQUAKE],
      :nature => :IMPISH,
      :iv => 31,
      :form => 1,
      :item => :LEFTOVERS,
      :ev => [100, 52, 252, 0, 100, 0],
    },
    :onEntryEffects => {
      :message => "ADMIN drew power from the earth...",
      :itemchange => :ROCKIUMZ,
      :animation => :GEOMANCY,
      :playersideChanges => {
        :StealthRock => [true, :STEALTHROCK, "Floating rocks were deployed!"],
      },
      :bossStatChanges => {
        PBStats::ATTACK => 1,
        PBStats::DEFENSE => 1,
        PBStats::SPATK => 1,
        PBStats::SPDEF => 1,
        PBStats::SPEED => 1,
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 1,
        :effect => nil,
        :thresholdmessage => "ADMIN reconstructed itself.",
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
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
      :level => 75,
      :moves => [:POWERWHIP, :LEECHSEED, :GYROBALL, :FIRELASH],
      :nature => :BRAVE,
      :form => 1,
      :iv => 31,
      :item => :LEFTOVERS,
      :ev => [100, 52, 252, 0, 100, 0],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :bosssideChanges => {
          :Reflect => [5, :REFLECT, nil],
          :LightScreen => [5, nil, "Rift Ferrothorn put up defenses!"],
        },
      },
      2 => {
        :threshold => 0,
        :effect => nil,
        :message => "Rift Ferrothorn became unrestrained!",
        :movesetUpdate => [:FLAREBLITZ, :ENERGYBALL, :IRONHEAD, :SHIFTGEAR],
        :bgmChange => "Battle - Pseudo Contribution",
        :formchange => 2,
        :itemchange => :WHITEHERB,
        :statDropCure => true,
      },
      1 => {
        :threshold => 0,
        :effect => nil,
        :message => "Rift Ferrothorn is out of control!",
        :bossStatChanges => {
          PBStats::ATTACK => 2,
          PBStats::DEFENSE => -2,
          PBStats::SPATK => 2,
          PBStats::SPDEF => -2,
          PBStats::SPEED => 2,
        },
      },
    },
  },

  :RIFTHIPPOWDON => {
    :name => "Rift Hippowdon",
    :entryText => "Rift Hippowdon is filling the arena with sand!",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :HIPPOWDON,
      :level => 85,
      :form => 1,
      :moves => [:SPITUP, :HEATWAVE, :EARTHPOWER, :SLUDGEWAVE],
      :gender => :F,
      :nature => :RELAXED,
      :item => :LEFTOVERS,
      :iv => 31,
      :happiness => 0,
      :ev => [4, 0, 252, 0, 252, 0],
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
      :SandSap => {
        :delay => 4,
        :message => "The sandstorm is weakening your Pokémon!",
        :playerSideStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::DEFENSE => -1,
          PBStats::SPATK => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => -1,
        },
      },
    },
    :onEntryEffects => {
      :animation => :SCORCHINGSANDS,
      :message => "The whirling sands are scorching!",
      :queueDelays => [:SearingSandstorm],
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :message => "Rift Hippowdon shot sand everywhere!",
        :movesetUpdate => [:SPITUP, :EARTHQUAKE, :GUNKSHOT, :HEATWAVE],
        :weatherChange => [:SANDSTORM, -1, "Sandstorms keep brewing..."],
        :playersideChanges => {
          :StealthRock => [true, :STEALTHROCK, nil],
        },
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
      3 => {
        :threshold => 0,
        :message => "A shelter of sand is protecting Rift Hippowdon!",
        :movesetUpdate => [:SPITUP, :EARTHQUAKE, :GUNKSHOT, :BODYPRESS],
        :weatherChange => [:SANDSTORM, -1, "Sandstorms keep brewing..."],
        :bossEffect => {
          :Shelter => [true, :SHELTER, nil],
        },
        :playersideChanges => {
          :Spikes => [1, :SPIKES, nil],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
      },
      2 => {
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
      1 => {
        :threshold => 0,
        :message => "Rift Hippowdon expelled tonnes of sand!",
        :movesetUpdate => [:SPITUP, :DIG, :BODYPRESS, :HEATWAVE],
        :weatherChange => [:SANDSTORM, -1, "Sandstorms keep brewing..."],
        :bosssideChanges => {
          :AreniteWall => [5, :ARENITEWALL, nil],
        },
        :itemchange => :SITRUSBERRY,
        :queueDelays => [:SandSap],
        :fieldChange => :DESERT,
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
      :level => 75,
      :form => 3,
      :moves => [:DARKPULSE, :LOVELYKISS, :DAZZLINGGLEAM, :MYSTICALFIRE],
      :gender => :F,
      :nature => :SERIOUS,
      :iv => 31,
      :happiness => 255,
      :ev => [85, 85, 85, 85, 85, 85],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 4,
      :moninfos => {
        1 => {
          :species => :RALTS,
          :level => 75,
          :form => 1,
          :moves => [:TORMENT, :HELPINGHAND, :POISONGAS, :NIGHTSHADE],
          :gender => :F,
          :iv => 31,
        },
        2 => {
          :species => :KIRLIA,
          :level => 75,
          :form => 1,
          :moves => [:QUASH, :HELPINGHAND, :WILLOWISP, :SNARL],
          :gender => :F,
          :iv => 31,
        },
      },
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :animation => :SECRETSWORD,
        :message => "The Angel of Death drew its scythe.",
        :movesetUpdate => [:NIGHTSLASH, :LOVELYKISS, :SPIRITBREAK, :PSYCHOCUT],
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
        },
      },
      3 => {
        :threshold => 0,
        :animation => :CHARGE,
        :itemchange => :LEFTOVERS,
        :message => "The Angel of Death is drawing power.",
        :movesetUpdate => [:NIGHTSLASH, :PROTECT, :LAVAPLUME, :SACREDSWORD],
        :playerSideStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::SPATK => -1,
        },
      },
      2 => {
        :threshold => 0,
        :animation => :DAZZLINGGLEAM,
        :message => "The Angel of Death summoned minions.",
        :movesetUpdate => [:DARKPULSE, :PSYCHOCUT, :NIGHTSLASH, :AURASPHERE],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
      1 => {
        :threshold => 0,
        :animation => :DARKPULSE,
        :message => "The Angel of Death has fury.",
        :itemchange => :DARKINIUMZ,
        :movesetUpdate => [:HYPERSPACEFURY, :MOONBLAST, :EARTHQUAKE, :BOOMBURST],
      },
    },
  },

  :FALLENANGEL => {
    :name => "Fallen Angel",
    :entryText => "The Angel is on its last legs...",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :GARDEVOIR,
      :level => 75,
      :form => 4,
      :moves => [:LASHOUT, :BURNINGJEALOUSY, :HYPERSPACEHOLE, :THRASH],
      :gender => :F,
      :nature => :LONELY,
      :iv => 31,
      :happiness => 255,
      :ev => [85, 85, 85, 85, 85, 85],
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
      :level => 75,
      :moves => [:JUDGMENT, :PUNISHMENT, :EXTREMESPEED, :LIQUIDATION],
      :nature => :LONELY,
      :ability => :MULTITYPE,
      :item => :FISTPLATE,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 252, 0, 4, 0, 252],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "STOP! You've violated the law! Pay the court a fine or serve your sentence. Your stolen goods are now forfeit.",
        :animation => :COSMICPOWER,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
      },
    },
  },

  :NIGHTMAREREMIX => {
    :name => "Nightmare Remix",
    :entryText => "The... Puppet Master? Attacks?",
    :shieldCount => 5,
    :immunities => {},
    :moninfo => {
      :species => :DARKRAI,
      :level => 80,
      :form => 8,
      :moves => [:SPIRITBREAK, :PSYCHIC, :AURORAVEIL, :THROATCHOP],
      :nature => :BRAVE,
      :item => :PSYCHICGEM,
      :iv => 31,
      :happiness => 0,
      :ev => [4, 252, 0, 252, 0, 0],
    },
    :delayedactions => {
      :NightmareEternal => {
        :delay => 4,
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
      5 => {
        :threshold => 0,
        :message => "No fairy tale...",
        :movesetUpdate => [:DARKPULSE, :FLAMETHROWER, :PSYSHOCK, :MOONLIGHT],
        :itemchange => :ROSELIBERRY,
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, nil],
        },
      },
      4 => {
        :threshold => 0,
        :message => "Grow weary...",
        :movesetUpdate => [:MOONBLAST, :ICEBEAM, :KNOCKOFF, :PROTECT],
        :itemchange => :LEFTOVERS,
        :animation => :HYPNOSIS,
        :playerSideStatChanges => {
          PBStats::ATTACK => -3,
          PBStats::SPATK => -3,
        },
      },
      3 => {
        :threshold => 0,
        :message => "Nightmare...",
        :movesetUpdate => [:DAZZLINGGLEAM, :SACREDSWORD, :ZENHEADBUTT, :DARKVOID],
        :itemchange => :FAIRYGEM,
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 2,
          PBStats::SPDEF => 2,
        },
      },
      2 => {
        :threshold => 0,
        :message => "Don't sleep... Don't wake up...",
        :movesetUpdate => [:DOOMDESIRE, :VACUUMWAVE, :DARKPULSE, :ANCIENTPOWER],
        :itemchange => :FIGHTINGGEM,
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "Welcome the end...",
        :itemchange => :STEELGEM,
        :movesetUpdate => [:METEORMASH, :COMETPUNCH, :THROATCHOP, :PSYSTRIKE],
        :statDropCure => true,
      },
    },
  },

  :KKING => {
    :name => "Klinklang King",
    :entryText => "The gears are grinding!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :KLINKLANG,
      :level => 100,
      :form => 1,
      :moves => [:THUNDERCAGE, :ZINGZAP, :PROTECT, :BULLDOZE],
      :nature => :BRAVE,
      :item => :LEFTOVERS,
      :ability => :SPEEDBOOST,
      :iv => 31,
      :happiness => 0,
      :ev => [4, 252, 0, 252, 0, 0],
    },
    :onBreakEffects => {},
  },

  :BIGBETTY => {
    :name => "Big Betty",
    :entryText => "Big Betty stands her ground!",
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
      :iv => 10,
    },
    :onEntryEffects => {
      :fieldChange => :FAIRYTALE,
      :fieldChangeMessage => "Goomink's resolve manifested!",
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
      :level => 90,
      :item => :LUMBERRY,
      :moves => [:FOCUSBLAST, :REFLECT, :BOLTSTRIKE, :OUTRAGE],
      :ability => :TERAVOLT,
      :nature => :NAIVE,
      :iv => 31,
      :ev => [252, 252, 0, 0, 0, 0],
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
      :level => 90,
      :item => :WISEGLASSES,
      :moves => [:DRAGONCLAW, :FUSIONFLARE, :EARTHPOWER, :CRUNCH],
      :ability => :TURBOBLAZE,
      :nature => :TIMID,
      :iv => 31,
      :ev => [252, 0, 0, 252, 0, 0],
    },
    :onBreakEffects => {},
  },

  :BOSSNAGANADEL => {
    :name => "Naganadel",
    :entryText => "Naganadel is ready to kill!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :NAGANADEL,
      :level => 87,
      :item => :LIFEORB,
      :moves => [:SLUDGEWAVE, :DRAGONPULSE, :HEATWAVE, :NASTYPLOT],
      :ability => :BEASTBOOST,
      :nature => :TIMID,
      :iv => 31,
      :happiness => 0,
      :ev => [0, 0, 4, 252, 0, 252],
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
      :level => 90,
      :moves => [:GRASSKNOT, :FOCUSBLAST, :PSYCHIC, :DARKPULSE],
      :ability => :SHADOWTAG,
      :gender => :F,
      :item => :GOTHCREST,
      :nature => :MODEST,
      :form => 1,
      :iv => 31,
      :ev => [4, 0, 0, 252, 0, 252],
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
      :level => 85,
      :item => :LIFEORB,
      :moves => [:WEATHERBALL, :HURRICANE, :THUNDER, :PSYSHOCK],
      :ability => :TEMPEST,
      :nature => :MODEST,
      :form => 1,
      :iv => 31,
      :ev => [252, 0, 4, 252, 0, 0],
    },
    :onBreakEffects => {},
  },

  :STORMNINERENEGADE => {
    :name => "STORM | Wind",
    :entryText => "Erratic weather begets a disaster...",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :XERNEAS,
      :level => 95,
      :item => :LIFEORB,
      :moves => [:WEATHERBALL, :HURRICANE, :THUNDER, :PSYSHOCK],
      :ability => :TEMPEST,
      :nature => :MODEST,
      :form => 1,
      :iv => 31,
      :ev => [252, 0, 4, 252, 0, 0],
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :itemchange => :SOFTSAND,
        :message => "The Storm changed! ",
        :typeChange => [:GROUND],
        :movesetUpdate => [:MAGMADRIFT, :EARTHQUAKE, :MUDDYWATER, :STONEEDGE],
        :abilitychange => :SANDFORCE,
        :statDropCure => true,
        :formchange => 2,
        :weatherChange => [:SANDSTORM, -1, "Sand emerges from the Storm!"],
      },
      2 => {
        :threshold => 0,
        :itemchange => :MYSTICWATER,
        :message => "The Storm changed! ",
        :typeChange => [:WATER],
        :movesetUpdate => [:SURF, :WATERFALL, :HURRICANE, :THUNDER],
        :abilitychange => :RAINDISH,
        :statDropCure => true,
        :formchange => 3,
        :weatherChange => [:RAINDANCE, -1, "Rain pours from the sky?"],
        :CustomMethod => "@decision = 3",
      },
      1 => {
        :threshold => 0,
        :itemchange => :CHARCOAL,
        :typeChange => [:FIRE,:ELECTRIC],
        :message => "The Storm changed! ",
        :abilitychange => :SOLARPOWER,
        :movesetUpdate => [:FIREBLAST, :THUNDERBOLT, :WOODHAMMER, :BLASTBURN],
        :statDropCure => true,
        :formchange => 4,
        :weatherChange => [:SUNNYDAY, -1, "Fire engulfs the area!"],
      },
    },
  },

  :KARMABEASTXERN => { #Wip. ???? type
    :name => "Karma Beast Nymiera",
    :entryText => "<char>???: Stop \\PN.",
    :inspectText => [
      "\\se[]\\c[11]???: Huh?\\1",
      "\\se[]\\c[11]???: Did you really think I'd just let you do that?\\1",
      "\\se[]\\c[11]???: Who do you think made it so you could <i>Inspect</i> to begin with?\\1",
      "\\se[]\\c[11]???: But,\\|\\se[SFX - Blip] if you really want to step out of your bounds like that,\\|",
      "\\se[]\\c[11]???: I'll simply put you back in your cage.\\1",
      "\\se[]\\c[11]???: What's a bird to do when their wings have been plucked anyways?\\1",
    ],
    :shieldCount => 5,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :XERNEAS,
      :level => 100,
      :item => :LEFTOVERS,
      :moves => [:SALTCURE, :COSMICPOWER, :CLEARSMOG, :PROTECT],
      :ability => :LIFEBLOOD,
      :nature => :RELAXED,
      :form => 5,
      :iv => 31,
      :ev => [252, 0, 252, 0, 0, 0],
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
        :queueDelays => [:SeeYourEndRepeat],
        :getsOverwritten => [:NoEscapeStart, :NoEscapeRepeat],
      },
      :SeeYourEndRepeat => {
        :delay => 3,
        :instantMove => [:FISSURE, :FirstUnfainted],
        :queueDelays => [:SeeYourEndRepeat],
        :getsOverwritten => [:NoEscapeStart, :NoEscapeRepeat],
      },
      :NoEscapeStart => {
        :delay => 1,
        :lockOnTarget => :true,
        :instantMove => [:FISSURE, :FirstUnfainted],
        :queueDelays => [:NoEscapeRepeat],
      },
      :NoEscapeRepeat => {
        :delay => 3,
        :lockOnTarget => :true,
        :instantMove => [:FISSURE, :FirstUnfainted],
        :queueDelays => [:NoEscapeRepeat],
      },
    },
    :onBreakEffects => {
      5 => {
        :threshold => 0,
        :message => "Data particles swarmed all around!",
        :playerEffects => {
          :INFESTATION => [8, "Infestation", nil],
        },
      },
      4 => {
        :threshold => 0,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
        :bossEffect => {
          :Ingrain => [true, :INGRAIN, "The Karma Beast connected itself to the Core!"],
        },
        :queueDelays => [:SeeDestructionStart],
      },
      3 => {
        # lifeblood trigger here, shift battlepace
        :threshold => 0,
        :CustomMethod => "pbLifeBloodAnalysis(battler)",
        :partialAnalysis => {
          :typeChange => [:FAIRY, :PSYCHIC],
          :abilitychange => :FAIRYAURA,
          :ev => [252, 0, 0, 252, 0, 0],
          :movesetUpdate => [:DAZZLINGGLEAM, :MOONBLAST, :EARTHPOWER, :HEATWAVE],
        },
        :semiAnalysis => {
          :effectClear => true,
          :statChangeRefresh => true,
          :statusCure => true,
          :Mist => [5, :MIST, "The Karma Beast enveloped itself in a thick mist..."],
          :playerEffects => {
            :INFESTATION => [8, "Infestation", nil],
          },
          :bossStatChanges => {
            PBStats::SPATK => 1,
          },
        },
        :fullAnalysis => {
          :stateChanges => { # handles state changes found in the Battle_Global class(in Battle_ActiveSide file + Trick Room
            :TrickRoom => [5, :TRICKROOM, "The dimensions were changed!"], # syntax: effect => [effect value, effect animation, effect message]
          },
        },
      },
      2 => {
        :threshold => 0,
        :CustomMethod => "pbLifeBloodAnalysis(battler)",
        :partialAnalysis => {
        },
        :semiAnalysis => {
          :bosssideChanges => {
            :Reflect => [5, :REFLECT, nil],
            :LightScreen => [5, :LIGHTSCREEN, nil],
          },
          :playerEffects => {
            :INFESTATION => [8, "Infestation", nil],
          },
        },
        :fullAnalysis => {
          :stateChanges => { # handles state changes found in the Battle_Global class(in Battle_ActiveSide file + Trick Room
            :TrickRoom => [8, :TRICKROOM, "The dimensions were changed!"], # syntax: effect => [effect value, effect animation, effect message]
          },
        },
      },
      1 => {
        :threshold => 0,
        :CustomMethod => "pbLifeBloodAnalysis(battler)",
        :partialAnalysis => {
          :statDropCure => true,
          :statusCleanse => true,
        },
        :semiAnalysis => {
          :stateChanges => { # handles state changes found in the Battle_Global class(in Battle_ActiveSide file + Trick Room
            :TrickRoom => [8, :TRICKROOM, "The dimensions were changed!"], # syntax: effect => [effect value, effect animation, effect message]
          },
          :itemchange => :MAGICALSEED,
          :effectClear => true, # if effects are cleared when shield is broken
          :queueDelays => [:SeeYourEndStart],
        },
        :fullAnalysis => {
          :queueDelays => [:NoEscapeStart],
        },
      },
    },
  },

  :BOSSCOFAGRIGUS => {
    :name => "Totem Cofagrigus",
    :entryText => "The menacing Cofagrigus attacked!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :COFAGRIGUS,
      :level => 80,
      :moves => [:SHADOWBALL, :TOXICSPIKES, :WILLOWISP, :ENERGYBALL],
      :hptype => :FIGHTING,
      :ability => :MUMMY,
      :gender => :M,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 0, 252, 252, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 3",
      :totalMonCount => 3,
      :moninfos => {
        1 => {
          :species => :STANTLER,
          :level => 75,
          :item => :STANTCREST,
          :moves => [:HYPNOSIS, :MEGAHORN, :JUMPKICK, :ZENHEADBUTT],
          :ability => :INTIMIDATE,
          :gender => :F,
          :nature => :JOLLY,
          :iv => 31,
          :happiness => 255,
          :ev => [0, 252, 0, 0, 0, 252],
        },
        2 => {
          :species => :MAGCARGO,
          :level => 75,
          :item => :MAGCREST,
          :moves => [:FLAMEBURST, :YAWN, :EARTHPOWER, :WILLOWISP],
          :ability => :FLAMEBODY,
          :gender => :M,
          :nature => :BOLD,
          :iv => 31,
          :happiness => 255,
          :ev => [0, 0, 252, 252, 0, 0],
        },
        3 => {
          :species => :LEAFEON,
          :level => 75,
          :item => :LEAFCREST,
          :moves => [:SWORDSDANCE, :NATUREPOWER, :LEAFBLADE, :XSCISSOR],
          :ability => :LEAFGUARD,
          :gender => :F,
          :nature => :ADAMANT,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 128, 0, 0, 252, 0],
        },
      },
    },
    :delayedactions =>{
      :PharaohsCurse => {
        :delay => 3,
        :message => "Beware the Pharaoh's curse!",
        :playerEffects => {
          :Curse => [true, :CURSE, nil],
        },
        :queueDelays => [:PharaohsCurse],
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Sand swarms all around!",
        :bosssideChanges => {
          :AreniteWall => [5, :ARENITEWALL, nil],
        },
        :movesetUpdate => [:SHADOWBALL, :BODYPRESS, :CALMMIND, :PSYCHIC],
        :itemchange => :SITRUSBERRY,
      },
      2 => {
        :threshold => 0,
        :movesetUpdate => [:SHADOWBALL, :PROTECT, :ENERGYBALL, :HIDDENPOWER],
        :itemchange => :LEFTOVERS,
        :queueDelays => [:PharaohsCurse],
      },
      1 => {
        :threshold => 0,
        :itemchange => :COFCREST,
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
        :effectClear => true,
      },
    },
  },

  :COFFEEGREGUS => {
    :name => "COFFEE GREGUS",
    :entryText => "COFFEE GREGUS!",
    :shieldCount => 4,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :COFAGRIGUS,
      :level => 85,
      :moves => [:SHADOWPUNCH, :COMETPUNCH, :BULLETPUNCH, :BULKUP],
      :item => :FOCUSSASH,
      :gender => :M,
      :nature => :MODEST,
      :form => 1,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 252, 0, 0, 0, 252],
    },
    :delayedactions =>{
      :DodgingIsCheating => {
        :delay => 1,
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
      4 => {
        :threshold => 0,
        :movesetUpdate => [:SHADOWPUNCH, :SCORCHINGSANDS, :AURASPHERE, :BULKUP],
        :itemchange => :SITRUSBERRY,
        :message => "COFFEE GREGUS!",
        :animation => :BULKUP,
        :bossStatChanges => {
          PBStats::DEFENSE => 2,
          PBStats::SPDEF => 2,
        },
        :fieldChange => :BIGTOP,
        :fieldChangeMessage => "CLOWN FIESTA!"
      },
      3 => {
        :threshold => 0,
        :movesetUpdate => [:SHADOWPUNCH, :CROSSCHOP, :ICEPUNCH, :BULKUP],
        :itemchange => :GHOSTGEM,
        :bossEffect => {
          :LaserFocus => [1, :LASERFOCUS, nil],
        },
        :message => "COFFEE GREGUS!",
        :animation => :BULKUP,
      },
      2 => {
        :threshold => 0,
        :movesetUpdate => [:SHADOWPUNCH, :DYNAMICPUNCH, :BODYPRESS, :BULKUP],
        :itemchange => :SITRUSBERRY,
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
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :WAILORD,
      :level => 75,
      :form => 1,
      :moves => [:DIVE, :DARKESTLARIAT, :AQUARING, :FRUSTRATION],
      :gender => :F,
      :nature => :HARDY,
      :item => :SITRUSBERRY,
      :iv => 31,
      :happiness => 0,
      :ev => [4, 252, 0, 252, 0, 0],
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :itemchange => :SITRUSBERRY,
        :message => "Kawopudunga changed its type!",
        :movesetUpdate => [:DIVE, :HEAVYSLAM, :NOBLEROAR, :BODYPRESS],
        :typeChange => [:WATER, :STEEL],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 2,
        },
      },
      3 => {
        :threshold => 0,
        :itemchange => :SITRUSBERRY,
        :message => "Kawopudunga changed its type!",
        :movesetUpdate => [:DIVE, :ICICLECRASH, :ENCORE, :FREEZEDRY],
        :typeChange => [:WATER, :ICE],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::SPDEF => 2,
        },
      },
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
    },
  },

  :BOSSKECLEON => {
    :name => "Wacky Lizard",
    :entryText => "Wacky Lizard's staring into space.",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :KECLEON,
      :level => 85,
      :form => 0,
      :moves => [:PLAYROUGH, :THUNDERPUNCH, :BOUNCE, :EARTHQUAKE],
      :gender => :F,
      :ability => :SHEERFORCE,
      :nature => :BRAVE,
      :item => :SITRUSBERRY,
      :iv => 31,
      :happiness => 0,
      :ev => [0, 252, 4, 252, 0, 0],
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
      2 => {
        :threshold => 0,
        :itemchange => :LIFEORB,
        :movesetUpdate => [:THUNDER, :HURRICANE, :MOONBLAST, :EARTHPOWER],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::SPATK => 2,
          PBStats::ACCURACY => 1,
        },
      },
    },
  },

  :BOSSKECLEON1 => {
    :name => "Wacky Lizard",
    :entryText => "Wacky Lizard's staring into space.",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :KECLEON,
      :level => 50,
      :form => 0,
      :moves => [:PLAYROUGH, :THUNDERPUNCH, :BOUNCE, :EARTHQUAKE],
      :gender => :F,
      :ability => :SHEERFORCE,
      :nature => :BRAVE,
      :item => :SITRUSBERRY,
      :iv => 31,
      :happiness => 0,
      :ev => [0, 252, 4, 252, 0, 0],
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
      },
    },
    :onEntryEffects => {
      :queueDelays => [:WackyTypeShift],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :itemchange => :LIFEORB,
        :movesetUpdate => [:THUNDER, :HURRICANE, :MOONBLAST, :EARTHPOWER],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::SPATK => 2,
          PBStats::ACCURACY => 1,
        },
      },
    },
  },

  :BOSSGOURGEIST => {
    :name => "Jack-o'-lantern",
    :entryText => "A large pumpkin suddenly attacked!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :GOURGEIST,
      :level => 80,
      :form => 1,
      :moves => [:WILLOWISP, :SEEDBOMB, :LEECHSEED, :CURSE],
      :gender => :F,
      :ability => :INSOMNIA,
      :nature => :BRAVE,
      :item => :SITRUSBERRY,
      :iv => 31,
      :happiness => 0,
      :ev => [252, 252, 4, 0, 0, 0],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "The Jack-o'-lantern was lit up!",
        :movesetUpdate => [:FIREBLAST, :ENERGYBALL, :TRICKROOM, :ROCKSLIDE],
        :typeChange => [:GRASS, :FIRE],
        :abilitychange => :FLASHFIRE,
        :itemchange => :ELEMENTALSEED,
        :fieldChange => :GRASSY,
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
        :bossStatChanges => {
          PBStats::SPATK => 2,
        },
      },
      2 => {
        :threshold => 0,
        :itemchange => :BIGROOT,
        :movesetUpdate => [:GIGADRAIN, :LEECHSEED, :MYSTICALFIRE, :PHANTOMFORCE],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
      },
      1 => {
        :threshold => 0,
        :movesetUpdate => [:GRASSYGLIDE, :ROCKSLIDE, :SYNTHESIS, :SHADOWSNEAK],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 2,
        },
      },
    },
  },

  :DUFAUX => {
    :name => "Dufaux",
    :entryText => "The Clefairy doll attacked!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :FROSLASS,
      :level => 90,
      :form => 2,
      :moves => [:POISONGAS, :DISCHARGE, :ICEBEAM, :MOONBLAST],
      :gender => :F,
      :nature => :MODEST,
      :item => :SITRUSBERRY,
      :iv => 31,
      :happiness => 0,
      :ev => [252, 0, 0, 252, 0, 0],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Dufaux attempted to repair itself...",
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, nil],
        },
        :itemchange => :MAGICALSEED,
        :statDropCure => true,
        :statusCure => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
      2 => {
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
      1 => {
        :threshold => 0,
        :statDropCure => true,
        :weatherChange => [:SNOWSCAPE, -1, nil],
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
      },
    },
  },

  :MECHAGYARADOS => {
    :name => "GYARA-01",
    :entryText => "WARNING! WARNING! WARNING!",
    :shieldCount => 6,
    :immunities => {},
    :moninfo => {
      :species => :GYARADOS,
      :level => 90,
      :form => 3,
      :moves => [:THUNDERBOLT, :HYPERBEAM, :FLAMETHROWER, :SCALD],
      :gender => :F,
      :nature => :HARDY,
      :iv => 31,
      :happiness => 0,
      :ev => [4, 252, 0, 252, 0, 0],
    },
    :onBreakEffects => {
      5 => {
        :threshold => 0,
        :message => "DESTRUCTION MODE ENGAGED!",
        :movesetUpdate => [:STEELBEAM, :MINDBLOWN, nil, nil],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
      },
      3 => {
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
    :shieldCount => 5,
    :immunities => {},
    :moninfo => {
      :species => :DARKRAI,
      :level => 90,
      :form => 3,
      :moves => [:THUNDERCAGE, :CROSSCHOP, :BUNRAKUBEATDOWN, :NIGHTMARE],
      :nature => :BRAVE,
      :item => :LEFTOVERS,
      :iv => 31,
      :happiness => 0,
      :ev => [4, 252, 0, 252, 0, 0],
    },
    :delayedactions =>{
      :ElectroShock => {
        :delay => 1,
        :playerSideStatusChanges => [:PARALYSIS, "Paralysis"],
        :queueDelays => [:ShockParalysis],
      },
      :ShockParalysis => {
        :delay => 3,
        :playerEffects => {
          :GastroAcid => [true, :EMBARGO, "Abilities have been suppressed!"],
        },
        :queueDelays => [:ShockParalysis],
      },
      :SleepNow => {
        :delay => 1,
        :playerEffects => {
          :Yawn => [1, :YAWN, "A strong feeling of drowsiness..."],
        },
        :queueDelays => [:SleepNowRepeat],
      },
      :SleepNowRepeat => {
        :delay => 4,
        :repeat => true,
        :playerEffects => {
          :Yawn => [1, :YAWN, "A strong feeling of drowsiness..."],
        },
        :queueDelays => [:SleepNowRepeat],
      },
    },
    :onEntryEffects => {
      :animation => :IONDELUGE,
      :fieldChange => :ELECTERRAIN,
      :fieldChangeMessage => "Aelita's nightmares manifest into reality...",
      :queueDelays => [:ElectroShock],
    },
    :onBreakEffects => {
      5 => {
        :threshold => 0,
        :message => "Memories of being burned alive pass by...",
        :movesetUpdate => [:ERUPTION, :EARTHQUAKE, :BUNRAKUBEATDOWN, :NIGHTMARE],
        :formchange => 4,
        :statDropCure => true,
        :animation => :ERUPTION,
        :playerSideStatusChanges => [:BURN, "Burn"],
        :playerEffects => {
          :TarShot => [true, :TARSHOT, "You feel highly flammable..."],
        },
        :fieldChange => :VOLCANICTOP,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
      4 => {
        :threshold => 0,
        :message => "The feeling of an explosion creeps up your spine...",
        :movesetUpdate => [:MOONBLAST, :SACREDSWORD, :BUNRAKUBEATDOWN, :NIGHTMARE],
        :formchange => 5,
        :statDropCure => true,
        :animation => :EXPLOSION,
        :fieldChange => :DIMENSIONAL,
        :bossStatChanges => {
          PBStats::SPDEF => 1,
        },
        :playerSideStatChanges => {
          PBStats::DEFENSE => -2,
          PBStats::SPDEF => -2,
        },
      },
      3 => {
        :threshold => 0,
        :message => "You feel death incarnate staring you down...",
        :movesetUpdate => [:OBLIVIONWING, :DARKPULSE, :BUNRAKUBEATDOWN, :NIGHTMARE],
        :formchange => 6,
        :statDropCure => true,
        :fieldChange => :CHESS,
        :animation => :DECIMATION,
        :playerEffects => {
          :PerishSong => [3, :PERISHSONG, "Death is imminent..."],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
      2 => {
        :threshold => 0,
        :message => "The true nightmare begins.",
        :movesetUpdate => [:BUNRAKUBEATDOWN, :FIERYWRATH, :MOONGEISTBEAM, :THUNDERCAGE],
        :formchange => 2,
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
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
    },
  },

  :MASTEROFNIGHTMARES2 => {
    :name => "Master of Nightmares",
    :entryText => "The nightmare will end soon.",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :DARKRAI,
      :level => 90,
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
      :level => 85,
      :form => 1,
      :moves => [:SHIFTGEAR, :GEARGRIND, :FACADE, :WILDCHARGE],
      :nature => :ADAMANT,
      :item => :LEFTOVERS,
      :iv => 31,
      :happiness => 0,
      :ev => [252, 252, 0, 0, 0, 4],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "The Klinklang Queen revs up!",
        :statusCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "Gears appear all around!",
        :movesetUpdate => [:SUBSTITUTE, :GEARGRIND, :FACADE, :WILDCHARGE],
        :fieldChange => :FACTORY,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPEED => 2,
        },
      },
    },
  },

  :GERBIL1 => {
    :name => "Entei",
    :entryText => "Entei appeared before you!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :capturable => true,
    :moninfo => {
      :species => :ENTEI,
      :level => 85,
      :form => 0,
      :item => :LEFTOVERS,
      :moves => [:SACREDFIRE, :STOMPINGTANTRUM, :EXTREMESPEED, :WILLOWISP],
      :ability => :PRESSURE,
      :nature => :ADAMANT,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 252, 4, 0, 0, 0],
    },
    :onBreakEffects => {
      2 => {
        :bgmChange => "Battle - Final Endeavor",
        :threshold => 0,
        :weatherChange => [:SUNNYDAY, 5, nil],
        :fieldChange => :VOLCANICTOP,
        :fieldChangeMessage => "Entei changed reality around it!",
        :statusCure => true,
        :statDropCure => true,
        :movesetUpdate => [:ERUPTION, :EXTRASENSORY, :STOMPINGTANTRUM, :CALMMIND],
        :itemchange => :CHARCOAL,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 2,
        },
      },
    },
  },

  :GERBIL2 => {
    :name => "Suicune",
    :entryText => "Suicune appeared before you!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :capturable => true,
    :moninfo => {
      :species => :SUICUNE,
      :level => 85,
      :form => 0,
      :item => :LEFTOVERS,
      :moves => [:AQUARING, :EXTRASENSORY, :SCALD, :CALMMIND],
      :ability => :PRESSURE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 0, 4, 252, 0, 0],
    },
    :onBreakEffects => {
      2 => {
        :bgmChange => "Battle - Final Endeavor",
        :threshold => 0,
        :message => "",
        :abilitychange => :PRESSURE,
        :fieldChange => :UNDERWATER,
        :fieldChangeMessage => "Suicune changed reality around it!",
        :statusCure => true,
        :statDropCure => true,
        :itemchange => :MYSTICWATER,
        :movesetUpdate => [:SURF, :ICEBEAM, :EXTRASENSORY, :CALMMIND],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 2,
        },
      },
    }
  },

  :GERBIL3 => {
    :name => "Raikou",
    :entryText => "Raikou appeared before you!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :capturable => true,
    :moninfo => {
      :species => :RAIKOU,
      :level => 85,
      :form => 0,
      :item => :LEFTOVERS,
      :moves => [:THUNDER, :AURASPHERE, :SCALD, :CALMMIND],
      :hptype => :GRASS,
      :ability => :PRESSURE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 0, 4, 252, 0, 0],
    },
    :onBreakEffects => {
      2 => {
        :bgmChange => "Battle - Final Endeavor",
        :threshold => 0,
        :message => "",
        :weatherChange => [:RAINDANCE, -1, "The Rain pours down!"],
        :fieldChange => :ELECTERRAIN,
        :fieldChangeMessage => "Raikou changed reality around it!",
        :statusCure => true,
        :statDropCure => true,
        :itemchange => :MAGNET,
        :movesetUpdate => [:THUNDER, :WEATHERBALL, :AURASPHERE, :HIDDENPOWER],
        :bossStatChanges => {
          PBStats::SPATK => 3,
        },
      },
    },
  },

  :ICESOLDIER => {
    :name => "Ice Soldier",
    :entryText => "En Garde!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :REGICE,
      :level => 90,
      :form => 1,
      :moves => [:SNOWSCAPE, :SURF, :PSYCHIC, :COLDTRUTH],
      :ability => :LEVITATE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 0",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :SABLEYE,
          :level => 85,
          :item => :SABLENITE,
          :moves => [:CONFUSERAY, :WILLOWISP, :PROTECT, :RECOVER],
          :ability => :MAGICBOUNCE,
          :nature => :CAREFUL,
          :form => 1,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 0, 4, 0, 252, 0],
        },
        2 => {
          :species => :SPIRITOMB,
          :level => 80,
          :item => :LEFTOVERS,
          :moves => [:SUCKERPUNCH, :FOULPLAY, :WILLOWISP, :SPITE],
          :ability => :INFILTRATOR,
          :nature => :ADAMANT,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 252, 4, 0, 0, 0],
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "<char>ALICE: Soldier! Protect your Queen! Use everything you have!",
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, "Ice Soldier shrouded itself with a Safeguard!"],
        },
        :abilitychange => :REFRIGERATE,
        :typeChange => [:ICE, :GHOST],
        :fieldChange => :GLITCH,
        :movesetUpdate => [:HYPERBEAM, nil, nil, nil],
        :fieldChangeMessage => "The ice castle is crumbling!",
        :statusCure => true,
        :itemchange => :LEFTOVERS,
        :statBoosts => {
          PBStats::SPATK => 6,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :TIEMPAGOOD => {
    :name => "Tiempa",
    :entryText => "Tiempa is looking ready to attack!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :DIALGA,
      :level => 90,
      :form => 0,
      :item => :ADAMANTORB,
      :moves => [:EARTHPOWER, :FLASHCANNON, :POWERGEM, :DRAGONPULSE],
      :ability => :PRESSURE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :delayedactions => {
      :SlowTime => {
        :delay => 2,
        :message => "Tiempa slows down movement!",
        :animation => :FAIRYLOCK,
        :playerSideStatChanges => {
          PBStats::SPEED => -1,
        },
        :queueDelays => [:SlowTime],
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Tiempa is twisting time around the field!",
        :statusCure => true,
        :statDropCure => true,
        :itemchange => :ADAMANTORB,
        :movesetUpdate => [:EARTHPOWER, :FLASHCANNON, :AURASPHERE, :ROAROFTIME],
        :bossStatChanges => {
          PBStats::SPDEF => 1,
          PBStats::DEFENSE => 1,
        },
        :playerSideStatChanges => {
          PBStats::SPEED => -2,
        },
        :queueDelays => [:SlowTime],
      },
    },
  },

  :SPACEAGOOD => {
    :name => "Spacea",
    :entryText => "Spacea is finishing what Tiempa started!",
    :shieldCount => 3,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :PALKIA,
      :level => 90,
      :form => 0,
      :item => :TELLURICSEED,
      :moves => [:SURF, :HEAVYSLAM, :SPACIALREND, :FLAMETHROWER],
      :ability => :PRESSURE,
      :nature => :MILD,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount <= 3",
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
      3 => {
        :threshold => 0,
        :itemchange => :LUSTROUSORB,
        :stateChanges => {
          :WonderRoom => [99, :WONDERROOM, "The dimensions were changed!"],
        },
      },
      2 => {
        :threshold => 0,
        :movesetUpdate => [:THUNDER, :FIREBLAST, :SPACIALREND, :SURF],
        :itemchange => :LUSTROUSORB,
        :abilitychange => :MOLDBREAKER,
        :bossStatChanges => {
          PBStats::SPDEF => 1,
        },
      },
      1 => {
        :message => "<char>SPACEA: No more... NO... MORE!!!!!!!",
        :animation => :FLASH,
        :bgmChange => "Battle - End of Night",
        :threshold => 0,
        :formchange => 1,
        :effectClear => true,
        :statDropCure => true,
        :itemchange => :LUSTROUSGLOBE,
        :abilitychange => :MOLDBREAKER,
        :movesetUpdate => [:THUNDER, :HEAVYSLAM, :SPACIALREND, :SURF],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
    },
  },

  :SPACEABAD => {
    :name => "Spacea",
    :entryText => "Spacea is looking ready to attack!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :PALKIA,
      :level => 95,
      :form => 0,
      :item => :LUSTROUSORB,
      :moves => [:SURF, :SPACIALREND, :FLAMETHROWER, :HEAVYSLAM],
      :ability => :PRESSURE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :CLEFAIRY,
          :level => 90,
          :item => :EVIOLITE,
          :moves => [:FOLLOWME, :HELPINGHAND, :MOONBLAST, :REFLECT],
          :ability => :FRIENDGUARD,
          :ev => [252, 0, 252, 0, 0, 4],
        },
        2 => {
          :species => :HOOPA,
          :level => 90,
          :item => :TELLURICSEED,
          :moves => [:HYPERSPACEHOLE, :SHADOWBALL, :GRASSKNOT, :THUNDER],
          :ability => :MAGICIAN,
          :ev => [252, 0, 4, 252, 0, 0],
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :statDropCure => true,
        :movesetUpdate => [:HEAVYSLAM, :FIREBLAST, :SPACIALREND, :HYDROPUMP],
        :itemchange => :LUSTROUSORB,
        :abilitychange => :MOLDBREAKER,
        :stateChanges => {
          :WonderRoom => [99, :WONDERROOM, "The dimensions were changed!"],
        },
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "Spacea twisted the space around the field!",
        :statusCure => true,
        :statDropCure => true,
        :effectClear => true,
        :itemchange => :LUSTROUSORB,
        :movesetUpdate => [:HYDROPUMP, :SPACIALREND, :FIREBLAST, :THUNDER],
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
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
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :DIALGA,
      :level => 95,
      :form => 0,
      :item => :TELLURICSEED,
      :moves => [:POWERGEM, :ROAROFTIME, :HEAVYSLAM, :EARTHPOWER],
      :ability => :PRESSURE,
      :nature => :QUIET,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 0, 4, 252, 0, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 3",
      :clearingRequirement => "@snapshot && @snapshot[1] && @snapshot[1][:snapshotUses] == 0",
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :CELEBI,
          :level => 90,
          :form => 0,
          :item => :LIGHTCLAY,
          :moves => [:GRASSKNOT, :REFLECT, :PSYSHOCK, :LIGHTSCREEN],
          :ability => :NATURALCURE,
          :nature => :TIMID,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 0, 0, 252, 0, 0],
        },
        2 => {
          :species => :JIRACHI,
          :level => 90,
          :form => 0,
          :item => :LEFTOVERS,
          :moves => [:MOONBLAST, :FLASHCANNON, :FOLLOWME, :PSYCHIC],
          :ability => :SERENEGRACE,
          :nature => :CALM,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 0, 4, 0, 252, 0],
        },
      },
    },
    :delayedactions => {
      :FixtureInTime => {
        :delay => 1,
        :CustomMethod => "battlesnapshot(battler,2,-1)",
        :message => "Tiempa is focusing on the flow of time!",
        :playerEffects => {
          :FutureSight => [2, :DOOMDESIRE, nil],
          :FutureSightMove => [:DOOMDESIRE, nil, nil],
        },
        :endCondition => "@snapshot.is_a?(Array) && @snapshot[2]",
      },
      :RewindTime1 => {
        :delay => 6,
        :message => "<char>TIEMPA: You are wasting your time, Interceptor...",
        :CustomMethod => "timewarp(battler,2)",
        :getsOverwritten => [:RewindTime2],
        :playerEffects => {
          :FutureSight => [2, :DOOMDESIRE, nil],
          :FutureSightMove => [:DOOMDESIRE, nil, nil],
        },
      },
      :RewindTime2 => {
        :delay => 4,
        :message => "<char>TIEMPA: Just one mistake is all it takes...",
        :CustomMethod => "timewarp(battler,3)",
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
      2 => {
        :CustomMethod => "battlesnapshot(battler,1,1)",
        :threshold => 0,
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => -1,
        },
      },
      1 => {
        :threshold => 0,
        :statusCure => true,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
      },
      0 => {
        :CustomMethod => "timewarp(battler,1)",
        :movesetUpdate => [:PROTECT, :DOOMDESIRE, :SNARL, :ROAROFTIME],
        :queueDelays => [:RewindTime1, :FixtureInTime],
        :message => "<char>TIEMPA: Fate may bow to you... BUT TIME DOES NOT!!!",
        :animation => :FLASH,
        :bgmChange => "Battle - End of Night",
        :fieldChange => :NEWWORLD,
        :threshold => 0,
        :formchange => 1,
        :statusCure => true,
        :statDropCure => true,
        :effectClear => true,
        :itemchange => :ADAMANTCRYSTAL,
      },
      -2 => {
        :threshold => 0,
        :movesetUpdate => [:FLAMETHROWER, :ROAROFTIME, :HEAVYSLAM, :THUNDERBOLT],
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => -1,
        },
      },
      -1 => {
        :CustomMethod => "battlesnapshot(battler,3,-1)",
        :message => "Tiempa's concentration was broken!",
        :movesetUpdate => [:FLAMETHROWER, :ROAROFTIME, :FLASHCANNON, :THUNDERBOLT],
        :threshold => 0,
        :statusCure => true,
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
        :queueDelays => [:RewindTime2],
      },
    },
  },

  :BOSSRATICATE => {
    :name => "Monstrosity",
    :entryText => "The grotesque rodent attacked!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :RATICATE,
      :level => 18,
      :form => 2,
      :moves => [:POISONFANG, :BITE, :TAILWHIP, :SECRETPOWER],
      :ability => :NOGUARD,
      :nature => :NAUGHTY,
      :iv => 20,
      :happiness => 255,
      :ev => [20, 20, 20, 20, 20, 20],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "The Monstrosity started acting desperate!",
        :statDropCure => true,
        :movesetUpdate => [:DIRECLAW, :BITE, :TAILWHIP, :SECRETPOWER],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :STARMIEGOD => {
    :name => "Shooting Star",
    :entryText => "You can't look away from the Star...",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :STARMIE,
      :level => 88,
      :moves => [:SURF, :THUNDERBOLT, :RECOVER, :PSYCHIC],
      :ability => :ANALYTIC,
      :nature => :MODEST,
      :item => :PETAYABERRY,
      :iv => 31,
      :happiness => 255,
      :shiny => true,
      :ev => [0, 0, 0, 252, 0, 252],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "The Shooting Star is sparkling!",
        :statDropCure => true,
        :itemchange => :PETAYABERRY,
        :fieldChange => :RAINBOW,
        :fieldChangeMessage => "A prismatic luminance buries the surroundings!",
        :movesetUpdate => [:TRIATTACK, :DAZZLINGGLEAM, :COSMICPOWER, :PSYSHOCK],
        :abilitychange => :PRISMARMOR,
      },
    },
  },

  :UXIEBAD => {
    :name => "Uxie",
    :entryText => "Uxie is defending itself!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :UXIE,
      :level => 90,
      :form => 0,
      :moves => [:AMNESIA, :MYSTICALPOWER, :DRAININGKISS, :YAWN],
      :ability => :LEVITATE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 0",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :MESPRIT,
          :level => 80,
          :item => :MAGICALSEED,
          :moves => [:CHARM, :PSYSHOCK, :SHADOWBALL, :CONFUSERAY],
          :ability => :LEVITATE,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 0, 4, 0, 252, 0],
        },
        2 => {
          :species => :AZELF,
          :level => 80,
          :item => :MAGICALSEED,
          :moves => [:THUNDERWAVE, :ZENHEADBUTT, :PLAYROUGH, :KNOCKOFF],
          :ability => :LEVITATE,
          :nature => :ADAMANT,
          :iv => 31,
          :happiness => 255,
          :ev => [0, 252, 4, 0, 0, 252],
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Uxie drew power from the Starlight!",
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, "Uxie shrouded itself with a Safeguard!"],
        },
        :abilitychange => :VICTORYSTAR,
        :typeChange => [:PSYCHIC, :FAIRY],
        :fieldChange => :STARLIGHT,
        :movesetUpdate => [:MYSTICALPOWER, :DRAININGKISS, :YAWN, :SIGNALBEAM],
        :fieldChangeMessage => "The field shines bright!",
        :statusCure => true,
        :itemchange => :MAGICALSEED,
        :statBoosts => {
          PBStats::DEFENSE => 1,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :MESPRITBAD => {
    :name => "Mesprit",
    :entryText => "Mesprit is defending itself!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :MESPRIT,
      :level => 90,
      :form => 0,
      :moves => [:WATERPULSE, :CHARGEBEAM, :DRAININGKISS, :MYSTICALPOWER],
      :ability => :LEVITATE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 0",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :UXIE,
          :level => 80,
          :item => :ELEMENTALSEED,
          :moves => [:YAWN, :PSYCHIC, :THUNDERBOLT, :HELPINGHAND],
          :ability => :LEVITATE,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 0, 4, 0, 252, 0],
        },
        2 => {
          :species => :AZELF,
          :level => 80,
          :item => :ELEMENTALSEED,
          :moves => [:THUNDERWAVE, :ZENHEADBUTT, :PLAYROUGH, :KNOCKOFF],
          :ability => :LEVITATE,
          :nature => :ADAMANT,
          :iv => 31,
          :happiness => 255,
          :ev => [0, 252, 4, 0, 0, 252],
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Mesprit surrounded itself in water!",
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, "Mesprit shrouded itself with a Safeguard!"],
        },
        :abilitychange => :TECHNICIAN,
        :typeChange => [:PSYCHIC, :WATER],
        :fieldChange => :WATERSURFACE,
        :movesetUpdate => [:MYSTICALPOWER, :DRAININGKISS, :CHARGEBEAM, :WATERPULSE],
        :fieldChangeMessage => "The field was flash flooded!",
        :statusCure => true,
        :itemchange => :ELEMENTALSEED,
        :statBoosts => {
          PBStats::DEFENSE => 1,
          PBStats::SPEED => 1,
        },
      },
    },
  },

  :AZELFBAD => {
    :name => "Azelf",
    :entryText => "Azelf is defending itself!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :AZELF,
      :level => 90,
      :form => 0,
      :moves => [:NASTYPLOT, :FLAMETHROWER, :KNOCKOFF, :MYSTICALPOWER],
      :ability => :LEVITATE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount == 0",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :UXIE,
          :level => 80,
          :item => :ELEMENTALSEED,
          :moves => [:YAWN, :PSYCHIC, :THUNDERBOLT, :HELPINGHAND],
          :ability => :LEVITATE,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 0, 4, 0, 252, 0],
        },
        2 => {
          :species => :MESPRIT,
          :level => 80,
          :item => :ELEMENTALSEED,
          :moves => [:CHARM, :PSYSHOCK, :SHADOWBALL, :CONFUSERAY],
          :ability => :LEVITATE,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
          :ev => [252, 0, 4, 0, 252, 0],
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Azelf conflagrated in hellfire!",
        :bosssideChanges => {
          :Safeguard => [5, :SAFEGUARD, "Azelf shrouded itself with a Safeguard!"],
        },
        :abilitychange => :MAGMAARMOR,
        :typeChange => [:PSYCHIC, :DARK],
        :fieldChange => :INFERNAL,
        :movesetUpdate => [:TORMENT, :FLAMETHROWER, :KNOCKOFF, :MYSTICALPOWER],
        :fieldChangeMessage => "The field is burning with anguish!",
        :statusCure => true,
        :itemchange => :ELEMENTALSEED,
        :statBoosts => {
          PBStats::ATTACK => 2,
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
      :level => 90,
      :form => 2,
      :moves => [:SLUDGEWAVE, :ACROBATICS, :ESPERWING, :VENOSHOCK],
      :gender => :M,
      :nature => :BRAVE,
      :item => :TELLURICSEED,
      :iv => 31,
      :happiness => 0,
      :ev => [4, 252, 0, 252, 0, 0],
    },
    :onEntryEffects => {
      :fieldChange => :CORRUPTED,
      :fieldChangeMessage => "The arena melted into toxic slag!"
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => ".... stOooP.....",
        :movesetUpdate => [:ACIDARMOR, :BARBBARRAGE, :HURRICANE, :BODYPRESS],
        :playersideChanges => {
          :ToxicSpikes => [1, :TOXICSPIKES, "Toxic Spikes were set up!"],
        },
        :itemchange => :BLACKSLUDGE,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
      2 => {
        :threshold => 0,
        :message => "oUu.... dOn'T.....",
        :typeChange => [:POISON, :DRAGON],
        :movesetUpdate => [:HEXINGSLASH, :DRAGONCLAW, :DRACOMETEOR, :VENOSHOCK],
        :statDropCure => true,
        :statusCure => true,
        :formchange => 3,
        :fieldChange => :CORROSIVEMIST,
        :playerSideStatChanges => {
          PBStats::DEFENSE => -2,
          PBStats::SPDEF => -2
        },
      },
      1 => {
        :threshold => 0,
        :message => ".... pLEase.... enD IT....",
        :movesetUpdate => [:VILEASSAULT, :DRAGONRUSH, :HEATWAVE, :DRAGONDANCE],
        :itemchange => :POISONIUMZ,
        :bossStatChanges => {
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
          PBStats::SPEED => 2,
        },
      },
    },
  },

  :NANODRIVE => {
    :name => "NANO DRIVE",
    :entryText => "The NANO DRIVE is analyzing...",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :MAGNEZONE,
      :level => 93,
      :form => 1,
      :moves => [:DOUBLEIRONBASH, :POWERUPPUNCH, :SHELTER, :SUCKERPUNCH],
      :nature => :IMPISH,
      :item => :PROTECTIVEPADS,
      :iv => 31,
      :happiness => 0,
      :ev => [4, 252, 252, 0, 0, 0],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "The NANO DRIVE is planning...",
        :movesetUpdate => [:DOUBLEIRONBASH, :BRUTALSWING, :BULLETPUNCH, :ELECTROWEB],
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "A layer of Spikes was set up!"],
        },
        :itemchange => :ELECTRICGEM,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
      },
      1 => {
        :threshold => 0,
        :message => "The NANO DRIVE is closing out the battle...",
        :movesetUpdate => [:DOUBLEIRONBASH, :STEAMROLLER, :SPIKYSHIELD, :SUBMISSION],
        :itemchange => :STEELIUMZ,
        :bossStatChanges => {
          PBStats::DEFENSE => 2,
          PBStats::SPDEF => 2,
        },
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
      :level => 95,
      :item => :FOCUSSASH,
      :moves => [:HAMMERARM, :WOODHAMMER, :ICEHAMMER, :DRAGONHAMMER],
      :nature => :NAUGHTY,
      :form => 2,
      :iv => 31,
      :happiness => 0,
      :ev => [0, 252, 0, 252, 0, 4],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Will you... Remember all of this too? ",
        :itemchange => :LIFEORB,
        :movesetUpdate => [:BLIZZARD, :THUNDER, :FIREBLAST, :HYPERBEAM],
        :statDropCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => -1,
        },
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
      :level => 95,
      :item => :AIRBALLOON,
      :moves => [:MORNINGSUN, :FIERYDANCE, :STRUGGLEBUG, :SOLARBEAM],
      :ability => :QUARKDRIVE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :shiny => true,
      :ev => [4, 0, 0, 252, 0, 252],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "<char>V: You're annoying. Let's ramp this up.",
        :statDropCure => true,
        :statusCure => true,
        :itemchange => :ELECTRICGEM,
        :fieldChange => :ELECTERRAIN,
        :movesetUpdate => [:OVERHEAT, :FIERYDANCE, :SLUDGEWAVE, :DISCHARGE],
        :bossStatChanges => {
          PBStats::DEFENSE => 2,
          PBStats::SPATK => 1,
        },
      },
    },
  },

  :DOXIE => {
    :name => "Doxie",
    :entryText => "Doxie is hungry.",
    :shieldCount => 7,
    :immunities => {},
    :moninfo => {
      :species => :MARSHADOW,
      :level => 100,
      :moves => [:SPECTRALTHIEF, :DRAINPUNCH, :SHADOWSNEAK, :SHADOWBALL],
      :ability => :TECHNICIAN,
      :item => :LEPPABERRY,
      :nature => :JOLLY,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 252, 252, 252, 252, 252],
    },
    :onBreakEffects => {
      6 => {
        :threshold => 0,
        :statDropCure => true,
        :statusCure => true,
        :fieldChange => :HAUNTED,
        :itemchange => :LEPPABERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 2,
          PBStats::SPATK => 2,
        },
      },
      5 => {
        :threshold => 0,
        :statDropCure => true,
        :statusCure => true,
        :fieldChange => :HAUNTED,
        :itemchange => :LEPPABERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 2,
          PBStats::SPATK => 2,
        },
      },
      4 => {
        :threshold => 0,
        :statDropCure => true,
        :statusCure => true,
        :fieldChange => :HAUNTED,
        :effectClear => true,
        :itemchange => :LEPPABERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 3,
          PBStats::SPATK => 3,
        },
      },
      3 => {
        :threshold => 0,
        :statDropCure => true,
        :statusCure => true,
        :fieldChange => :HAUNTED,
        :abilitychange => :MOLDBREAKER,
        :itemchange => :LEPPABERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 4,
          PBStats::SPATK => 4,
        },
      },
      2 => {
        :threshold => 0,
        :statDropCure => true,
        :statusCure => true,
        :fieldChange => :HAUNTED,
        :effectClear => true,
        :itemchange => :LEPPABERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 5,
          PBStats::SPATK => 5,
        },
      },
      1 => {
        :threshold => 0,
        :statDropCure => true,
        :statusCure => true,
        :fieldChange => :HAUNTED,
        :abilitychange => :MOLDBREAKER,
        :itemchange => :LEPPABERRY,
        :effectClear => true,
        :bossStatChanges => {
          PBStats::ATTACK => 6,
          PBStats::DEFENSE => 2,
          PBStats::SPATK => 6,
          PBStats::SPDEF => 2,
          PBStats::SPEED => 6,
        },
      },
    },
  },

  :TWINDANCERS => {
    :name => "Yulia",
    :entryText => "Showtime! May the audience watch intently!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :LILLIGANT,
      :level => 95,
      :form => 2,
      :item => :MAGICALSEED,
      :moves => [:SHADOWBALL, :FIERYDANCE, :AURASPHERE, :FACADE],
      :ability => :OPPORTUNIST,
      :nature => :TIMID,
      :iv => 31,
      :happiness => 255,
      :shiny => true,
      :ev => [4, 0, 0, 252, 0, 252],
    },

    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :HAUNTED,
      :fieldChangeMessage => "Yulia's performance acted as a seance!",
      :overlay => [:GRASSY, "Grass grew to cover the battlefield!", 8, :GRASSYTERRAIN],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Yulia elegantly wipes the dirt off her dress and begins anew! Hear her swan song!",
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
        :itemchange => :GHOSTGEM,
        :movesetUpdate => [:INFERNALPARADE, :RAGEFIST, :AURASPHERE, :ALLURINGVOICE],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
    },
  },

  :TWINDANCERS_1 => {
    :name => "Lena",
    :entryText => "Showtime! May the audience watch intently!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :LILLIGANT,
      :level => 95,
      :form => 3,
      :item => :SITRUSBERRY,
      :moves => [:HIJUMPKICK, :AFTERYOU, :SWAGGER, :FLOWERTRICK],
      :ability => :DAZZLING,
      :nature => :JOLLY,
      :iv => 31,
      :happiness => 255,
      :shiny => true,
      :ev => [4, 252, 0, 0, 0, 252],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Lena puts it all into her final performance!",
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
        :itemchange => :FOCUSSASH,
        :movesetUpdate => [:FLATTER, :LICK, :PETALBLIZZARD, :AXEKICK],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
      },
    },
  },

  :EARTHSHATTERER => {
    :name => "Earth Shatterer",
    :entryText => "Tremble! The Earth's crust is being torn apart!",
    :shieldCount => 2,
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
      :ev => [4, 252, 252, 0, 0, 0],
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :MOUNTAIN,
      :fieldChangeMessage => "The Earth Shatterer stomps the floor, turning the terrain mountainous!",
      :playersideChanges => {
        :StealthRock => [true, :STEALTHROCK, nil],
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "The Earth Shatterer bulks up!",
        :stateChanges => {
          :Gravity => [5, :GRAVITY, "The Earth Shatterer's intense mass pulled the battle to the ground!"],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        }
      },
      1 => {
        :threshold => 0,
        :formchange => 2,
        :message => "Earth Shatterer reduces the terrain to a barren wasteland!",
        :statChangeRefresh => true,
        :statusCure => true,
        :effectClear => true,
        :itemchange => :LIECHIBERRY,
        :abilitychange => :SANDFORCE,
        :fieldChange => :DESERT,
        :movesetUpdate => [:EARTHQUAKE, :HEATCRASH, :HEAVYSLAM, :STONEEDGE],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
    },
  },

  :CHITWO => {
    :name => "Chi-Two",
    :entryText => "Put 'em up! The King of Water has challenged you to a duel to the death!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :FINNEON,
      :level => 100,
      :form => 1,
      :item => :NEVERMELTICE,
      :moves => [:ICEBALL, :DEFENSECURL, :MACHPUNCH, :ZENHEADBUTT],
      :ability => :WINGSOFRUIN,
      :nature => :NAUGHTY,
      :iv => 31,
      :happiness => 255,
      :ev => [4, 252, 0, 0, 0, 252],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "The King of Water flexes its mind!",
        :statDropCure => true,
        :statusCure => true,
        :typeChange => [:WATER,:FIGHTING],
        :itemchange => :BLUNDERPOLICY,
        :movesetUpdate => [:HYDROPUMP, :FOCUSBLAST, :HYPNOSIS, :BLIZZARD],
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
      },
      1 => {
        :threshold => 0,
        :formchange => 2,
        :animation => :WHIRLPOOL,
        :typeChange => [:WATER,:FIGHTING],
        :message => "The King of Water brought out the BIG GUNS!!!!!!! UH OH!!!!",
        :itemchange => :PUNCHINGGLOVE,
        :movesetUpdate => [:DYNAMICPUNCH, :ICEPUNCH, :SURGINGSTRIKES, :BULKUP],
        :bossStatChanges => {
          PBStats::ATTACK => 6,
        },
      },
    },
  },

  :KINGSOFAPPLES => {
    :name => "Kings of Apples",
    :entryText => "Wallow! Sweetness and tart, what an art! Be trapped in the sap of the Kings of Apples!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :HYDRAPPLE,
      :level => 95,
      :form => 1,
      :item => :IAPAPABERRY,
      :moves => [:SLUDGEWAVE, :MUDDYWATER, :FICKLEBEAM, :SYNTHESIS],
      :ability => :ONEBADAPPLE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 0, 4, 252, 0, 0],
    },
    :onEntryEffects => {
      :fieldChange => :SWAMP,
      :fieldChangeMessage => "A swamp of mushy apples is formed!",
      :bossEffect => {
        :AquaRing => [true, :AQUARING, "Swamp water enveloped the Kings!"],
      },
      :bosssideChanges => {
        :Mist => [5, :MIST, "The Kings are veiled with mist."]
      },
    },
    :delayedactions => {
      :RottenBerries => {
        :delay => 2,
        :message => "Rotten berries were regurgitated at your Pokémon!",
        :playerSideStatusChanges => [:POISON, "Poison"],
        :playerSideStatChanges => {
          PBStats::SPDEF => -1,
        },
        :queueDelays => [:RottenBerries],
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Several heads scarfed down some berries!",
        :itemchange => :PETAYABERRY,
        :typeChange => [:GRASS,:DRAGON],
        :movesetUpdate => [:SYRUPBOMB, :MUDDYWATER, :FICKLEBEAM, :LEECHSEED],
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :queueDelays => [:RottenBerries],
      },
      2 => {
        :threshold => 0,
        :itemchange => :GANLONBERRY,
        :typeChange => [:BUG,:DRAGON],
        :movesetUpdate => [:STRUGGLEBUG, :MUDDYWATER, :FICKLEBEAM, :SYNTHESIS],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
      1 => {
        :threshold => 0,
        :itemchange => :APICOTBERRY,
        :typeChange => [:BUG,:POISON],
        :movesetUpdate => [:STRUGGLEBUG, :MUDDYWATER, :SLUDGEBOMB, :LEECHSEED],
        :bossStatChanges => {
          PBStats::SPDEF => 1,
        },
      },
    },
  },

  :NASTASIASDEOXYS => {
    :name => "Deoxys",
    :entryText => "",
    :shieldCount => 2,
    :immunities => {},
    :onEntryEffects => {},
    :moninfo => {
      :species => :DEOXYS,
      :level => 97,
      :moves => [:KNOCKOFF, :PSYCHIC, :SPIKES, :STEALTHROCK],
      :nature => :TIMID,
      :ability => :MOLDBREAKER,
      :item => :COLBURBERRY,
      :form => 3,
      :hptype => :FIRE,
      :iv => 31,
      :ev => [252, 4, 100, 0, 152, 0],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Deoxys changed form!",
        :formchange => 2,
        :itemchange => :MAGICALSEED,
        :userSwitch => true,
        :endTurn => true,
        :bosssideChanges => {
          :Reflect => [5, :REFLECT, "Deoxys put up a Reflect!"],
        },
        :opponentSwitch => true,
        :nature => :TIMID,
        :abilitychange => :MAGICGUARD,
        :movesetUpdate => [:BODYPRESS, :COSMICPOWER, :STOREDPOWER, :RECOVER],
        :ev => [252, 0, 252, 0, 0, 4],
      },
      1 => {
        :threshold => 0,
        :message => "Deoxys changed form!",
        :formchange => 1,
        :abilitychange => :MAGICGUARD,
        :bosssideChanges => {
          :LightScreen => [5, :LIGHTSCREEN, "Deoxys put up a Light Screen!"],
        },
        :itemchange => :FOCUSSASH,
        :movesetUpdate => [:DARKPULSE, :HIDDENPOWER, :METEORBEAM, :PSYCHIC],
        :userSwitch => true,
        :endTurn => true,
        :statusCure => true,
        :nature => :NAIVE,
        :ev => [4, 0, 0, 252, 0, 252],
      },
    },
  },


  :NASTASIASDEOXYS2 => {
    :name => "Deoxys",
    :entryText => "",
    :shieldCount => 2,
    :immunities => {},
    :onEntryEffects => {
      :message => "",
    },
    :moninfo => {
      :species => :DEOXYS,
      :level => 100,
      :moves => [:ICYWIND, :METEORBEAM, :PSYCHIC, :THUNDERBOLT],
      :nature => :TIMID,
      :ability => :FRIENDGUARD,
      :item => :POWERHERB,
      :form => 3,
      :iv => 31,
      :ev => [252, 0, 4, 252, 0, 8],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Deoxys changed form!",
        :formchange => 2,
        :itemchange => :ROCKYHELMET,
        :abilitychange => :FRIENDGUARD,
        :userSwitch => true,
        :nature => :BOLD,
        :movesetUpdate => [:PSYCHICNOISE, :THUNDERWAVE, :BODYPRESS, :NIGHTSHADE],
        :ev => [252, 0, 252, 0, 0, 4],
      },
      1 => {
        :threshold => 0,
        :message => "Deoxys changed form!",
        :formchange => 1,
        :abilitychange => :SHEERFORCE,
        :itemchange => :LIFEORB,
        :movesetUpdate => [:THUNDERBOLT, :FIREPUNCH, :BLIZZARD, :PSYCHIC],
        :statusCure => true,
        :userSwitch => true,
        :nature => :NAIVE,
        :ev => [4, 0, 0, 252, 0, 252],
      },
    },
  },


  :TYRANICAL => {
    :name => "Tyranitar",
    :entryText => "Tyranitar is surging with power!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :MOUNTAIN,
      :fieldChangeMessage => "The fight was brought to its mountainous lair!"
    },
    :moninfo => {
      :species => :TYRANITAR,
      :level => 95,
      :item => :WEAKNESSPOLICY,
      :form => 1,
      :moves => [:DRAGONDANCE, :CRUNCH, :ROCKSLIDE, :EARTHQUAKE],
      :ability => :SANDSTREAM,
      :nature => :ADAMANT,
      :iv => 31,
      :ev => [252, 252, 4, 0, 0, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount <= 2",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :AGGRON,
          :level => 95,
          :item => :SITRUSBERRY,
          :moves => [:METALBURST, :DRAGONTAIL, :ROCKSLIDE, :HEAVYSLAM],
          :ability => :STURDY,
          :nature => :CAREFUL,
          :iv => 31,
          :ev => [252, 0, 4, 0, 252, 0],
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Tyranitar is not going down easy!",
        :statusCure => true,
        :effectClear => true,
        :abilitychange => :SANDFORCE,
        :weatherChange => [:SANDSTORM, 8, "Tyranitar roars up a sandstorm!"],
        :movesetUpdate => [:STONEEDGE, :CRUNCH, :IRONHEAD, :EARTHQUAKE],
        :itemchange => :ROCKYHELMET,
        :statBoosts => {
          PBStats::DEFENSE => 2,
          PBStats::SPDEF => 2,
          PBStats::SPEED => -2,
          PBStats::EVASION => -2,
        },
      },
    },
  },

  :EXECUTIONERCHARIZARD => {
    :name => "Charizard",
    :entryText => "Charizard is bursting with energy!",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :CHARIZARD,
      :level => 100,
      :item => :CHARIZARDITEG,
      :moves => [:HEATWAVE, :AIRSLASH, :THUNDERPUNCH, :PROTECT],
      :ability => :BLAZE,
      :nature => :MILD,
      :shiny => true,
      :iv => 31,
      :ev => [0, 0, 0, 252, 0, 252],
    },
    :delayedactions => {
      :TarShots => {
        :delay => 2,
        :playerEffects => {
          :TarShot => [true, :TARSHOT, "Your Pokemon became highly flammable!"],
        },
        :queueDelays => [:TarShots],
      },
      :FireSpinFull => {
        :delay => 1,
        :message => "Flaming vortexes have formed!",
        :playerEffects => {
          :FIRESPIN => [8, :FIRESPIN, nil],
        },
        :queueDelays => [:FireSpinRepeat],
      },
      :FireSpinRepeat => {
        :delay => 1,
        :playerEffects => {
          :FIRESPIN => [8, :FIRESPIN, nil],
        },
        :queueDelays => [:FireSpinRepeat],
      },
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :queueDelays => [:FireSpinFull],
    },
    :onBreakEffects => {
      1 => {
        :queueDelays => [:TarShots],
      },
    },
  },

  :EXECUTIONERCERULEDGE => {
    :name => "Ceruledge",
    :shieldCount => 1,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :CERULEDGE,
      :level => 100,
      :item => :LIFEORB,
      :moves => [:BITTERBLADE, :SHADOWCLAW, :SHADOWSNEAK, :PSYCHOCUT],
      :ability => :FLASHFIRE,
      :shiny => true,
      :iv => 31,
      :ev => [0, 252, 0, 0, 0, 252],
    },
    :onEntryEffects => {}, # effects applied on entry, use same attributes/syntax as onbreakeffects
    :onBreakEffects => {},
  },

  :EIZENSTERAPAGOS => {
    :name => "Terapagos",
    :entryText => "",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :TERAPAGOS,
      :level => 90,
      :item => :COVERTCLOAK,
      :form => 0,
      :moves => [:TERASTARSTORM, :EARTHPOWER, :POWERGEM, :DAZZLINGGLEAM],
      :ability => :TERASHIFT,
      :nature => :MODEST,
      :iv => 31,
      :ev => [252, 0, 4, 252, 0, 0],
    },
    :delayedactions => {
      :ShinyStone => {
        :delay => 1,
        :instantMove => [:ROCKPOLISH, 0],
      },
      :PillarsOfStone => {
        :delay => 1,
        :instantMove => [:STEALTHROCK, 0],
      },
      :StarlitSky => {
        :delay => 1,
        :instantMove => [:WISH, 0],
        :queueDelays => [:StarlitSkyRepeat],
      },
      :StarlitSkyRepeat => {
        :delay => 3,
        :instantMove => [:WISH, 0],
        :queueDelays => [:StarlitSkyRepeat],
      },
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :queueDelays => [:PillarsOfStone],
    },
    :onBreakEffects => {
      2 => {
        :queueDelays => [:ShinyStone, :StarlitSky],
      },
    },
  },

  :ZARDKINGX => {
    :name => "Charizard",
    :entryText => "The king is enshrouded in draconic energy!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :CHARIZARD,
      :level => 95,
      :item => :SHELLBELL,
      :form => 1,
      :moves => [:FLAREBLITZ, :DRAGONDANCE, :DRAGONRUSH, :EARTHQUAKE],
      :ability => :TOUGHCLAWS,
      :nature => :ADAMANT,
      :iv => 31,
      :ev => [0, 252, 4, 0, 0, 252],
    },
    :delayedactions => {
      :OppressiveAura => {
        :delay => 2,
        :message => "The king's draconic aura is oppressive!",
        :playerSideStatChanges => {
          PBStats::DEFENSE => -1,
          PBStats::SPDEF => -1,
        },
        :queueDelays => [:OppressiveAura],
      },
    },
    :onBreakEffects => {
      2 => {
        :queueDelays => [:OppressiveAura],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
      },
    },
  },

  :ZARDQUEENY => {
    :name => "Charizard",
    :entryText => "The queen is blazing with superhot flames!",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :CHARIZARD,
      :level => 95,
      :item => :CHARTIBERRY,
      :form => 2,
      :moves => [:HEATWAVE, :AIRSLASH, :DRAGONPULSE, :TAILWIND],
      :ability => :DROUGHT,
      :nature => :TIMID,
      :iv => 31,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :delayedactions => {
      :OverwhelmingInferno => {
        :delay => 2,
        :message => "The queen's intense inferno is overwhelming!",
        :playerSideStatChanges => {
          PBStats::ATTACK => -1,
          PBStats::SPATK => -1,
          PBStats::SPEED => -1,
        },
        :queueDelays => [:OverwhelmingInferno],
      },
    },
    :onBreakEffects => {
      2 => {
        :itemChange => :ELEMENTALSEED,
        :queueDelays => [:OverwhelmingInferno],
        :message => "The blazing inferno scorches your Pokémon!",
        :animation => :ERUPTION,
      },
    },
  },

  :THEDURALUDON => {
    :name => "Duraludon",
    :entryText => "Duraludon is surging with power!",
    :shieldCount => 2,
    :barGraphic => "",
    :doublebattle => true,
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :overlay => [:ELECTERRAIN, "Electricity permeates the area!", 8, :ELECTRICTERRAIN],
    },
    :moninfo => {
      :species => :DURALUDON,
      :level => 95,
      :item => :LEFTOVERS,
      :form => 1,
      :moves => [:DRAGONPULSE, :FLASHCANNON, :THUNDERBOLT, :THUNDERWAVE],
      :ability => :QUAKEPROOF,
      :nature => :TIMID,
      :iv => 31,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount <= 3",
      :continuous => true,
      :totalMonCount => 3,
      :moninfos => {
        1 => {
          :species => :CHARJABUG,
          :level => 100,
          :item => :EVIOLITE,
          :moves => [:STICKYWEB, :STRUGGLEBUG, :EERIEIMPULSE, :ELECTROWEB],
          :ability => :BATTERY,
          :nature => :CAREFUL,
          :iv => 31,
          :ev => [252, 0, 4, 0, 252, 0],
        },
        2 => {
          :species => :ABOMASNOW,
          :level => 95,
          :item => :FOCUSSASH,
          :moves => [:AURORAVEIL, :BLIZZARD, :WOODHAMMER, :FOCUSBLAST],
          :ability => :SNOWWARNING,
          :nature => :MILD,
          :iv => 31,
          :ev => [0, 4, 0, 252, 0, 252],
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Duraludon is focused!",
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
        :animation => :LASERFOCUS,
        :bossEffect => {
          :LaserFocus => [1, nil, nil],
        },
        :abilitychange => :SNIPER,
        :fieldChange => :ELECTERRAIN,
        :movesetUpdate => [:DRACOMETEOR, :DARKPULSE, :THUNDER, :FOCUSENERGY],
        :itemchange => :SCOPELENS,
        :statBoosts => {
          PBStats::DEFENSE => 1,
          PBStats::ACCURACY => 1,
        },
      },
    },
  },

  :COLOSSUS => {
    :name => "Coalossal",
    :entryText => "Coalossal is surging with power!",
    :shieldCount => 2,
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
      :level => 95,
      :item => :POWERHERB,
      :form => 1,
      :moves => [:MAGMADRIFT, :TARSHOT, :METEORBEAM, :SCALD],
      :ability => :COALFURNACE,
      :nature => :MODEST,
      :iv => 31,
      :ev => [252, 0, 4, 252, 0, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount <= 3",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :CARKOL,
          :level => 100,
          :item => :EVIOLITE,
          :moves => [:TARSHOT, :MAGNITUDE, :ROCKBLAST, :STEALTHROCK],
          :ability => :FLASHFIRE,
          :nature => :ADAMANT,
          :iv => 31,
          :ev => [0, 252, 252, 0, 4, 0],
        },
        2 => {
          :species => :NINETALES,
          :level => 100,
          :item => :HEATROCK,
          :moves => [:HEATWAVE, :SUNNYDAY, :PROTECT, :WILLOWISP],
          :ability => :DROUGHT,
          :nature => :MILD,
          :iv => 31,
          :ev => [0, 4, 252, 0, 0, 252],
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Coalossal is getting angry!!",
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
        :fieldChange => :INFERNAL,
        :movesetUpdate => [:TEMPERFLARE, :EARTHQUAKE, :ROCKSLIDE, :STONEEDGE],
        :itemchange => :SCOPELENS,
        :statBoosts => {
          PBStats::ATTACK => 6,
          PBStats::SPEED => 6,
        },
      },
    },
  },

  :MSSCIZOR => {
    :name => "Ms. Scizor",
    :entryText => "I'm just gonna eat you up <3.",
    :shieldCount => 2,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :VOLCANICTOP,
      :fieldChangeMessage => "!",
    },
    :moninfo => {
      :species => :SCIZOR,
      :level => 100,
      :item => :LEFTOVERS,
      :form => 1,
      :gender => :F,
      :moves => [:BULLETPUNCH, :DUALWINGBEAT, :CHARM, :ATTRACT],
      :ability => :TECHNICIAN,
      :nature => :TIMID,
      :iv => 31,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount <= 3",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :SCIZOR,
          :level => 100,
          :item => :LIFEORB,
          :gender => :F,
          :moves => [:BULLETPUNCH, :CHARM, :ATTRACT, :XSCISSOR],
          :ability => :COMPETITIVE,
          :nature => :CAREFUL,
          :iv => 31,
          :ev => [0, 252, 4, 0, 0, 252],
        },
        2 => {
          :species => :KLEAVOR,
          :level => 100,
          :item => :FOCUSSASH,
          :gender => :F,
          :moves => [:STONEAXE, :BRICKBREAK, :XSCISSOR, :AERIALACE],
          :ability => :SHARPNESS,
          :nature => :JOLLY,
          :iv => 31,
          :ev => [0, 252, 4, 0, 0, 252],
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "Ms. Scizor unfused!",
        :statDropCure => true,
        :statusCure => true,
        :effectClear => true,
        :animation => :LASERFOCUS,
        :bossEffect => {
          :LaserFocus => [1, nil, nil],
        },
        :abilitychange => :SHARPNESS,
        :fieldChange => :FACTORY,
        :movesetUpdate => [:NIGHTSLASH, :SLASH, :STONEAXE, :XSCISSOR],
        :itemchange => :SCOPELENS,
        :statBoosts => {
          PBStats::SPEED => 1,
          PBStats::ATTACK => 4,
        },
      },
    },
  },

  :ARCHRIFTGALVANTULA => {
    :name => "Archrift Galvantula",
    :shieldCount => 3,
    :entryText => "Archrift Galvantula emerges from her Queen...",
    :immunities => {},
    :moninfo => {
      :species => :GALVANTULA,
      :level => 93,
      :form => 3,
      :moves => [:STICKYWEB, :BARBBARRAGE, :DISCHARGE, :SLUDGEWAVE],
      :gender => :F,
      :nature => :HASTY,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 4, 0, 252, 0, 252],
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
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => false,
      :totalMonCount => 1,
      :moninfos => {
        1 => {
          :name => "Rift Galvantula",
          :species => :GALVANTULA,
          :level => 88,
          :moves => [:ELECTROWEB, :STRINGSHOT, :STRUGGLEBUG, :FIREBLAST],
          :ability => :COMPOUNDEYES,
          :form => 2,
          :boss => :RIFTGALVANTULA_2,
        },
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "The Archrift changed type!",
        :abilitychange => :PRESSURE,
        :typeChange => [:ELECTRIC, :DARK],
        :movesetUpdate => [:RAGE, :SUPERCELLSLAM, :OBSTRUCT, :AQUATAIL],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
      2 => {
        :threshold => 0,
        :message => "The Archrift changed type!",
        :abilitychange => :UNNERVE,
        :typeChange => [:POISON, :DARK],
        :movesetUpdate => [:DARKPULSE, :SLUDGEBOMB, :SUCKERPUNCH, :PSYCHIC],
        :statDropCure => true,
      },
      1 => {
        :threshold => 0,
        :message => "The Archrift changed type!",
        :abilitychange => :PRESSURE,
        :typeChange => [:ELECTRIC, :POISON],
        :movesetUpdate => [:THUNDER, :GUNKSHOT, :RECOVER, :LASHOUT],
        :bossStatChanges => {
          PBStats::SPEED => 1,
        },
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
      :level => 93,
      :form => 2,
      :moves => [:ELECTROWEB, :FOLLOWME, :STRENGTHSAP, :DRAGONRAGE],
      :gender => :F,
      :nature => :HASTY,
      :iv => 20,
      :happiness => 255,
      :ev => [252, 0, 4, 0, 0, 252],
    },
    :onEntryEffects => {
      :bossStatChanges => {
        PBStats::DEFENSE => 2,
        PBStats::SPDEF => 2,
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
        :statDropCure => true,
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
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :VOLCANION,
      :level => 95,
      :item => :MAGICALSEED,
      :form => 2,
      :moves => [:HYDROSTEAM, :HEATWAVE, :SCORCHINGSANDS, :MISTBALL],
      :nature => :QUIET,
      :iv => 20,
      :happiness => 255,
      :ev => [252, 0, 0, 252, 0, 0],
    },
    :onEntryEffects => {
      :fieldChange => :MISTY,
      :fieldChangeMessage => "Scalding steam envelops the field!",
      :weatherChange => [:SUNNYDAY, 5, "Harsh sunlight falls on the field!"],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :item => :LEFTOVERS,
        :movesetUpdate => [:STEAMERUPTION, :THUNDER, :RECOVER, :STRANGESTEAM],
        :weatherChange => [:RAINDANCE, 5, "A sudden downpour!"],
      },
      2 => {
        :threshold => 0,
        :message => "The Archrift is feeling motivated!",
        :movesetUpdate => [:HYDROSTEAM, :HEATWAVE, :SCORCHINGSANDS, :MISTBALL],
        :weatherChange => [:SUNNYDAY, 5, "Harsh sunlight falls on the field!"],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => 1,
        },
      },
      1 => {
        :threshold => 0,
        :movesetUpdate => [:STEAMERUPTION, :THUNDER, :RECOVER, :STRANGESTEAM],
        :weatherChange => [:RAINDANCE, 5, "A sudden downpour!"],
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
      :level => 95,
      :form => 2,
      :moves => [:METEORBEAM, :AUTOTOMIZE, :ELECTROBALL, :SHADOWBALL],
      :item => :HARDSTONE,
      :ability => :BEASTBOOST,
      :nature => :TIMID,
      :happiness => 255,
      :ev => [0, 0, 0, 252, 0, 252],
      :iv => 31,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :movesetUpdate => [:DISCHARGE, :METEORBEAM, :EXPLOSION, :FLASHCANNON],
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
      :item => :ROCKYHELMET,
      :moves => [:HEADLONGRUSH, :CURSE, :ROCKSLIDE, :IRONHEAD],
      :ability => :BEASTBOOST,
      :nature => :ADAMANT,
      :ev => [0, 252, 252, 0, 4, 0],
      :iv => 31,
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "The Stalker laid down defensive spikes!"],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
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
      :item => :ROCKYHELMET,
      :moves => [:HEADLONGRUSH, :CURSE, :ROCKSLIDE, :IRONHEAD],
      :ability => :BEASTBOOST,
      :nature => :ADAMANT,
      :ev => [0, 252, 252, 0, 4, 0],
      :iv => 31,
    },
    :sosDetails => { # pokemon details
      :activationRequirement => "battler.shieldCount < 2",
      :continuous => true,
      :moninfos => {
        1 => {
          :species => :DURANT,
          :level => 100,
          :moves => [:ENTRAINMENT, :XSCISSOR, :IRONHEAD, :THUNDERWAVE],
          :ev => [0, 252, 0, 0, 0, 252],
          :iv => 31,
          :nature => :JOLLY,
          :ability => :TRUANT,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "The Stalker laid down defensive spikes!"],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        }
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
      :item => :ROCKYHELMET,
      :moves => [:HEADLONGRUSH, :CURSE, :ROCKSLIDE, :IRONHEAD],
      :ability => :BEASTBOOST,
      :nature => :ADAMANT,
      :happiness => 255,
      :ev => [0, 252, 252, 0, 4, 0],
      :iv => 31,
    },
    :sosDetails => { # pokemon details
      :activationRequirement => "battler.shieldCount < 3",
      :continuous => false,
      :moninfos => {
        1 => {
          :species => :STAKATAKA,
          :name => "Sentry Stakataka",
          :level => 90,
          :form => 2,
          :moves => [:FAKEOUT, :THUNDERWAVE, :KNOCKOFF, :GIGATONHAMMER],
          :ev => [4, 252, 0, 0, 0, 252],
          :iv => 31,
          :nature => :JOLLY,
          :ability => :MOLDBREAKER,
        },

        2 => {
          :species => :STAKATAKA,
          :name => "Sentry Stakataka",
          :level => 90,
          :form => 2,
          :moves => [:PROTECT, :BODYSLAM, :ROCKSLIDE, :HEAVYSLAM],
          :ev => [252, 4, 252, 0, 0, 0],
          :iv => 31,
          :nature => :IMPISH,
          :ability => :POWERSPOT,
        },
      },
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "The Stalker laid down defensive spikes!"],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },

      1 => {
        :threshold => 0,
        :message => "The Stalker adopts a new strategy.",
        :stateChanges => {
          :MagicRoom => [99, :MAGICROOM, "The Stalker disabled all items!"],
        },
        :playersideChanges => {
          :StealthRock => [true, :STEALTHROCK, "The Stalker laid down defensive rocks!"],
        },
        :bossStatChanges => {
          PBStats::SPDEF => 2,
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
      :level => 95,
      :form => 2,
      :item => :ROCKYHELMET,
      :moves => [:MOONLIGHT, :STEELBEAM, :BUGBUZZ, :FACADE],
      :ability => :SPEEDBOOST,
      :nature => :NAUGHTY,
      :ev => [0, 0, 252, 252, 4, 0],
      :iv => 31,
      :status => :PARALYSIS,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :playersideChanges => {
          :Spikes => [3, :SPIKES, "Cadarellia's mechanical parts seem to be malfunctioning!"],
        },
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
      },
      1 => {
        :threshold => 0,
        :statusCure => true,
        :movesetUpdate => [:PSYCHIC, :FLASHCANNON, :BUGBUZZ, :FACADE],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPATK => 1,
          PBStats::SPDEF => 1,
        },
      },
    },
  },

  :DAYWOLF => {
    :name => "Shadow Daywolf",
    :entryText => "A dark aura envelops the Daywolf!",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :LYCANROC,
      :level => 100,
      :form => 3,
      :moves => [:ACCELEROCK, :HOWL, nil, nil],
      :item => :HARDSTONE,
      :ability => :INTIMIDATE,
      :nature => :TIMID,
      :happiness => 255,
      :ev => [0, 252, 0, 0, 0, 252],
      :iv => 31,
    },
    :delayedactions => {
      :FireEmblemCombat => {
        :delay => 2,
        :CustomMethod => "@decision = 3",
      },
    },
    :onEntryEffects => {
      :queueDelays => [:FireEmblemCombat],
    },
    :onBreakEffects => {}
  },

  :DUSKWOLF => {
    :name => "Shadow Duskwolf",
    :entryText => "A dark aura envelops the Duskwolf!",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :LYCANROC,
      :level => 100,
      :form => 5,
      :moves => [:ACCELEROCK, :HOWL, nil, nil],
      :item => :HARDSTONE,
      :ability => :INTIMIDATE,
      :nature => :TIMID,
      :happiness => 255,
      :ev => [0, 252, 0, 0, 0, 252],
      :iv => 31,
    },
    :delayedactions => {
      :FireEmblemCombat => {
        :delay => 2,
        :CustomMethod => "@decision = 3",
      },
    },
    :onEntryEffects => {
      :queueDelays => [:FireEmblemCombat],
    },
    :onBreakEffects => {}
  },

  :NIGHTWOLF => {
    :name => "Shadow Nightwolf",
    :entryText => "A dark aura envelops the Night wolf!",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :LYCANROC,
      :level => 100,
      :form => 4,
      :moves => [:ACCELEROCK, :HOWL, nil, nil],
      :item => :HARDSTONE,
      :ability => :INTIMIDATE,
      :nature => :TIMID,
      :happiness => 255,
      :ev => [0, 252, 0, 0, 0, 252],
      :iv => 31,
    },
    :delayedactions => {
      :FireEmblemCombat => {
        :delay => 2,
        :CustomMethod => "@decision = 3",
      },
    },
    :onEntryEffects => {
      :queueDelays => [:FireEmblemCombat],
    },
    :onBreakEffects => {}
  },

  :ZACWOLF => {
    :name => "The Wolf King",
    :entryText => "The Wolf King approaches...",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :ZACIAN,
      :level => 80,
      :form => 1,
      :moves => [:BEHEMOTHBLADE, :PLAYROUGH, nil, nil],
      :item => :LAGGINGTAIL,
      :ability => :INTREPIDSWORD,
      :nature => :TIMID,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
      :iv => 1,
    },
    :delayedactions => {
      :FireEmblemCombat => {
        :delay => 2,
        :CustomMethod => "@decision = 3",
      },
    },
    :onEntryEffects => {
      :queueDelays => [:FireEmblemCombat],
    },
    :onBreakEffects => {},
  },

  :MADAMEXZEKROM => {
    :name => "Zekrom",
    :entryText => "Veni, Vidi, Vici.",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :ZEKROM,
      :level => 100,
      :moves => [:BOLTSTRIKE, :CRUNCH, :DRAGONTAIL, :LIGHTSCREEN],
      :nature => :ADAMANT,
      :ability => :TERAVOLT,
      :ev => [255, 255, 0, 0, 0, 255],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "MADAME <char>X: Let's see how much you can adapt...",
        :fieldChange => :ELECTERRAIN,
        :fieldChangeMessage => "The field was turned into a Dimensional Rift!",
        :movesetUpdate => [:BOLTSTRIKE, :SECRETPOWER, :PROTECT, :STONEEDGE],
      },
      1 => {
        :threshold => 0,
        :message => "MADAME <char>X: No regrets.",
        :animation => :HONECLAWS,
        :bossStatChanges => {
          PBStats::ATTACK => 2,
          PBStats::SPDEF => 2,
        },
        :movesetUpdate => [:FRUSTRATION, :BOLTSTRIKE, :DARKPULSE, :ROOST],
      },
    },
  },

  :MELMETALBOSS => {
    :name => "Melmetal",
    :entryText => "<char>MELMETAL: Mrrgghh!!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :MELMETAL,
      :level => 105,
      :item => :MELMETALITE,
      :moves => [:DOUBLEIRONBASH, :THUNDERPUNCH, :EARTHQUAKE, :HAMMERARM],
      :ability => :IRONFIST,
      :nature => :ADAMANT,
      :happiness => 0,
      :iv => 31,
      :ev => [20, 252, 0, 0, 192, 44],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "<char>PERCIVAL: This is... How is this possible? Melmetal, get it together! Now!",
        :animation => :FRUSTRATION,
        :itemchange => :SHUCABERRY,
        :movesetUpdate => [:FRUSTRATION, :DOUBLEIRONBASH, :FIREPUNCH, :DARKESTLARIAT],
      },
    },
  },

  :PERCYMEWTWO => {
    :name => "Mewtwo",
    :entryText => "<char>PERCIVAL: Again from the top, Mewtwo. \nOne Shadow Ball should do.",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :MEWTWO,
      :item => :ELEMENTALSEED,
      :moves => [:PSYSTRIKE, :SHADOWBALL, :GRASSKNOT, :FLAMETHROWER],
      :ability => :INSOMNIA,
      :form => 2,
      :level => 105,
      :nature => :NAIVE,
      :happiness => 2,
      :iv => 31,
      :ev => [4, 252, 0, 252, 0, 252],
    },
    :delayedactions => {
      :NoEncoreStart => {
        :delay => 1,
        :message => "<char>PERCIVAL: An encore just won't do. \nMewtwo, give them a nice Disable, why don't you?",
        :instantMove => [:DISABLE, :FirstUnfainted],
        :queueDelays => [:NoEncoreRepeat],
      },
      :NoEncoreRepeat => {
        :delay => 2,
        :instantMove => [:DISABLE, :FirstUnfainted],
        :queueDelays => [:NoEncoreRepeat],
      },
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :queueDelays => [:NoEncoreStart],
      },
      2 => {
        :threshold => 0,
        :message => "<char>PERCIVAL: Clearly this strategy isn't going well. \nHow about we change it all up?",
        :animation => :MEGAEVOLUTION,
        :formchange => 1,
        :itemchange => :LIFEORB,
        :abilitychange => :STEADFAST,
        :fieldChange => :ELECTERRAIN,
        :movesetUpdate => [:DRAINPUNCH, :PSYSTRIKE, :THUNDERPUNCH, :ICEBEAM],
      },
      1 => {
        :threshold => 0,
        :message => "<char>PERCIVAL: Am I truly the monster here...? Or is it you?",
        :animation => :EXPLOSION,
        :statusCure => true,
        :itemchange => :SITRUSBERRY,
        :formchange => 0,
        :fieldChangeMessage => "Mewtwo's Mega power was exhausted...",
        :movesetUpdate => [:AURASPHERE, :PSYSTRIKE, :THUNDERBOLT, :CALMMIND],
      },
    },
  },

  :SHATTEREDTIME => {
    :name => "Shattered Time",
    :entryText => "Shattered Time is getting ready to break through the seams of time...",
    :shieldCount => 4,
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
      :RevertEvolutionSlow => {
        :delay => 3,
        :CustomMethod => "pbPokemonEvolutionRevert(battler, false)",
        :queueDelays => [:RevertEvolutionSlow],
        :getsOverwritten => [:RevertEvolutionFast],
      },
      :RevertEvolutionFast => {
        :delay => 2,
        :CustomMethod => "pbPokemonEvolutionRevert(battler, false)",
        :queueDelays => [:RevertEvolutionFast],
      }
    },
    :onEntryEffects => {
      :message => "<char>HORACE: Pribi is setting up something big... If we don't take her down, none of us will survive...",
      :queueDelays => [:RevertEvolutionSlow],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :fieldChange => :GLITCH,
        :fieldChangeMessage => "<char>HORACE: Space-time in the area is breaking down! We have to end this quickly!",
        :movesetUpdate => [:FRENZYPLANT, :BLASTBURN, :HYDROCANNON, :ROAROFTIME],
        :playerEffects => {
          :FutureSight => [2, :FUTURESIGHT, nil],
          :FutureSightMove => [:FUTURESIGHT, nil, nil],
        },
      },
      1 => {
        :threshold => 0,
        :message => "Shattered Time becomes desperate...",
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => -6,
        },
        :queueDelays => [:RevertEvolutionFast],
      },
    },
  },

  :M31YVELTAL => {
    :name => "Father",
    :entryText => "Yveltal looms above.",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :YVELTAL,
      :level => 100,
      :moves => [:HEATWAVE, :OBLIVIONWING, :FOCUSBLAST, :DARKPULSE],
      :nature => :MODEST,
      :item => :LIFEORB,
      :iv => 31,
      :ev => [0, 0, 0, 252, 0, 252],
      :ball => :NOBALL,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :playersideChanges => {
          :StealthRock => [true, :STEALTHROCK, "The Xen Mage summoned Stealth Rocks!"],
        },
        :userSwitch => true,
        :instantMove => [:WHIRLWIND, 0],
        :endTurn => true,
      },
    },
  },

  :YVELTALCAPTURE => {
    :name => "Yveltal",
    :entryText => "Yveltal's dark aura does nothing to shake you.",
    :shieldCount => 1,
    :barGraphic => "",
    :doublebattle => true,
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :capturable => true,
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 1",
      :continuous => true,
      :totalMonCount => 1,
      :moninfos => {
        1 => {
          :species => :REGICE,
          :level => 100,
          :form => 1,
          :moves => [:SNOWSCAPE, :SURF, :PSYCHIC, :COLDTRUTH],
          :ability => :LEVITATE,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
          :ev => [0, 0, 4, 252, 0, 252],
        },
      },
    },
    :moninfo => {
      :species => :YVELTAL,
      :level => 100,
      :form => 0,
      :moves => [:OBLIVIONWING, :SUCKERPUNCH, :ROOST, :DARKPULSE],
      :ability => :DARKAURA,
      :nature => :TIMID,
      :item => :LIFEORB,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 4, 252, 0, 252],
      :obtaintype => 6,
      :catchmap => 380,
      :relearnall => true,
      :hatchmap => "Someplace below, long ago.",
      :obtainExtra => "Assigned to Vitus.",
      :originalTrainer => "Vitus",
      :trainerID => 42564,
    },
    :onBreakEffects => {},
  },

  :ZYGARDEINT => {
    :name => "Zygarde",
    :entryText => "The A-Gang and their Pokémon feel an acute sense of horrible unease...",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :ZYGARDE,
      :level => 100,
      :moves => [:DRAGONDANCE, :THOUSANDARROWS, :GLARE, :EARTHPOWER],
      :nature => :MODEST,
      :ability => :AURABREAK,
      :item => :SOULSTONE,
      :iv => 31,
      :ev => [252, 252, 0, 252, 0, 0],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 1",
      :totalMonCount => 1,
      :entryMessage => ["Zygarde's call brought forth Yveltal!"],
      :moninfos => {
        1 => {
          :species => :YVELTAL,
          :level => 100,
          :moves => [:OBLIVIONWING, :DARKPULSE, :DECIMATION, :ROOST],
          :ability => :DARKAURA,
          :item => :SOULSTONE,
          :nature => :MODEST,
          :iv => 31,
          :happiness => 255,
          :ev => [0, 0, 4, 252, 0, 252],
        },
      },
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :message => "Cells on Zygarde start to crack and fall off...",
      },
      3 => {
        :threshold => 0,
        :bgmChange => "Battle - End of Night",
        :movesetUpdate => [:OBLIVIONWING, :COREENFORCER, :DARKPULSE, :HEATWAVE],
        :CustomMethod => "burnthefatherfeedthedog(battler)",
        :fieldChange => :DRAGONSDEN,
        :fieldChangeMessage => "The room suddenly turned a red pitch...",
      },
    },
  },

  :MADAMEXRENEGADE => {
    :name => "Madame X",
    :entryText => "Mors certa, hora incerta...",
    :shieldCount => 7,
    :immunities => {},
    :moninfo => {
      :species => :IRONVALIANT,
      :level => 100,
      :form => 1,
      :moves => [:PROMISEDPAIN, :BANGLEBLADE, nil, nil],
      :nature => :ADAMANT,
      :ev => [255, 255, 0, 0, 0, 255],
    },
    :onBreakEffects => {
      6 => {
        :movesetUpdate => [:PROMISEDPAIN, :BANGLEBLADE, :FROZENFURY, nil],
        :threshold => 0,
        :CustomMethod => "@decision = 3 if $game_variables[912] < 67 && $Trainer.id == KNOWN_TRAINERS['Aelita']"
      },
      4 => {
        :movesetUpdate => [:PROMISEDPAIN, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
        :CustomMethod => "@decision = 3 if $game_variables[912] < 67 && $Trainer.id == KNOWN_TRAINERS['Venam']"
      },
      2 => {
        :movesetUpdate => [:COMPANIONSHUNGER, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
        :CustomMethod => "@decision = 3 if $game_variables[912] < 67 && $Trainer.id == KNOWN_TRAINERS['Erin']"
      },
      1 => {
        # form change is handled event side, so she starts on the madame Shogun form when appropriate
        :message => "<char>MADAME X: This is my final stand...",
        :animation => :GEOMANCY,
        :movesetUpdate => [:COMPANIONSHUNGER, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
    },
  },

  :HOTSTUFFYVELTAL => {
    :name => "Yveltal",
    :entryText => "Yveltal's glower is intense.",
    :shieldCount => 7,
    :immunities => {},
    :moninfo => {
      :species => :YVELTAL,
      :level => 95,
      :moves => [:DECIMATION, :HURRICANE, :FOCUSBLAST, :OBLIVIONWING],
      :nature => :HASTY,
      :item => :LAGGINGTAIL,
      :iv => 0,
      :ev => [4, 0, 0, 252, 0, 252],
    },
    :chargeAttack => {
      :turns => 5,
      :shieldCountRequirement => "self.shieldCount < 3",
      :continueCharging => true,
      :canAttack => true,
    },
    :delayedactions => {
      :NastasiaLockon => {
        :delay => 1,
        :playerEffects => {
          :LockOn => [2, nil, nil],
          :LockOnTarget => [1, nil, nil],
        },
        :queueDelays => [:NastasiaLockon],
      },
    },
    :onEntryEffects => {
      :message => "<char>NASTASIA: Deoxys doesn't have much left to give, but we can still help out!",
      :animation => :LOCKON,
      :playerEffects => {
        :LockOn => [2, nil, "Yveltal became Locked-On. It cannot evade attacks!"],
        :LockOnTarget => [1, nil, nil],
      },
      :queueDelays => [:NastasiaLockon],
    },
    :onBreakEffects => {
      7 => {
        :statusCure => true,
        :threshold => 0,
        :fieldChange => :SKY,
        :fieldChangeMessage => "Yveltal dragged the fight to the skies!",
      },
      6 => {
        :statusCure => true,
        :movesetUpdate => [:DECIMATION, :HEATWAVE, :FLAREBLITZ, :ROOST],
        :threshold => 0,
        :shieldCountChange => 4,
        :typeChange => [:DARK, :FIRE],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
          PBStats::SPEED => -2,
        },
        :fieldChange => :INFERNAL,
        :fieldChangeMessage => "The fight crashed back down into the bowels!",
        :chargeSetupMessage => "Yveltal is expending all its energy to return to its cocoon! Finish the fight up quick!",
      },
    },
  },

  :MADAMESHOGUN => {
    :name => "Madame Shogun",
    :entryText => "With or without my demise, Team Xen's end begins with me!",
    :shieldCount => 6,
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
        :typeChange => [:STEEL, :FIGHTING],
        :statusCure => true,
        :playerEffects => {
          :Curse => [true, :CURSE, "A curse has been placed on your team!"],
        },
        :queueDelays => [:WardingStanceStart],
        :message => "Madame Shogun switched up her stance!",
        :movesetUpdate => [:PROMISEDPAIN, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      2 => {
        :typeChange => [:STEEL, :FIRE],
        :weatherChange => [:SUNNYDAY, 5, "A bright radiance enveloped the arena!"],
        :statusCure => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
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
    :shieldCount => 6,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :IRONVALIANT,
      :level => 100,
      :form => 2,
      :moves => [:PROMISEDPAIN, :BANGLEBLADE, :BURNINGHATE, nil],
      :nature => :ADAMANT,
      :ev => [0, 255, 0, 255, 0, 255],
      :BaseStats => [255, 115, 110, 105, 105, 100],
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
      :CounterStance => {
        :delay => 1,
        :bossEffect => {
          :ShellTrap => [true, "ShellTrap", "Madame Shogun primed a trap!"],
        },
        :queueDelays => [:CounterStanceRepeat],
      },
      :CounterStanceRepeat => {
        :delay => 3,
        :bossEffect => {
          :ShellTrap => [true, "ShellTrap", "Madame Shogun primed a trap!"],
        },
        :queueDelays => [:CounterStanceRepeat],
      },
      :TarShots => {
        :delay => 1,
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
        :queueDelays => [:WardingStanceStart],
        :movesetUpdate => [:PROMISEDPAIN, :BANGLEBLADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      5 => {
        :typeChange => [:STEEL, :FIGHTING],
        :statusCure => true,
        :message => "Madame Shogun switched up her stance!",
        :movesetUpdate => [:PROMISEDPAIN, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      4 => {
        :typeChange => [:STEEL, :FAIRY],
        :statDropCure => true,
        :message => "Madame Shogun switched up her stance!",
        :movesetUpdate => [:BANGLEBLADE, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      3 => {
        :message => "Madame Shogun switched up her stance!",
        :statusCure => true,
        :playerEffects => {
          :Curse => [true, :CURSE, "A curse has been placed on your team!"],
        },
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
        :movesetUpdate => [:PROMISEDPAIN, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      2 => {
        :typeChange => [:STEEL, :FIRE],
        :message => "Madame Shogun switched up her stance!",
        :queueDelays => [:TarShots, :CounterStance],
        :statDropCure => true,
        :movesetUpdate => [:BANGLEBLADE, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      1 => {
        :typeChange => [:QMARKS, :QMARKS],
        :message => "Madame Shogun is putting everything into one final frenzy...",
        :instantMove => [:COMPANIONSHUNGER, 0],
        :movesetUpdate => [:COMPANIONSHUNGER, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
    },
  },

  :MADAMESHOGUNSPIRIT => {
    :name => "Madame Shogun",
    :entryText => "",
    :shieldCount => 3,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :IRONVALIANT,
      :level => 100,
      :form => 2,
      :moves => [:PROMISEDPAIN, :BANGLEBLADE, :FROZENFURY, :BURNINGHATE],
      :nature => :ADAMANT,
      :slidein => true,
      :ev => [0, 255, 0, 255, 0, 255],
      :BaseStats => [150, 120, 110, 140, 105, 100],
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
      3 => {
        :typeChange => [:STEEL, :FIGHTING],
        :statusCure => true,
        :message => "Madame Shogun switched up her stance!",
        :movesetUpdate => [:PROMISEDPAIN, :TENSETIRADE, :FROZENFURY, :BURNINGHATE],
        :threshold => 0,
      },
      2 => {
        :typeChange => [:STEEL, :FIRE],
        :queueDelays => [:TarShots],
        :message => "Madame Shogun switched up her stance!",
        :abilitychange => :LEVITATE,
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

  :FOEHNMISTRAL_EARLY => {
    :name => "Foehn & Mistral",
    :entryText => "Mistral and Foehn approach!",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :GALLADE,
      :level => 45,
      :form => 2,
      :moves => [:DAZZLINGGLEAM, :DRAINPUNCH, :NIGHTSLASH, :SHADOWBALL],
      :nature => :MILD,
      :ability => :PARENTALBOND,
      :ev => [0, 252, 0, 0, 0, 252],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Foehn walks in front!",
        :abilitychange => :ANALYTIC,
        :typeChange => [:PSYCHIC, :FAIRY],
        :itemchange => :SITRUSBERRY,
        :bossStatChanges => {
          PBStats::SPDEF => 1,
        },
        :movesetUpdate => [:SHOCKWAVE, :DAZZLINGGLEAM, :SHADOWBALL, :SCALD],
      },
      1 => {
        :threshold => 0,
        :message => "Mistral pushes Foehn away!",
        :animation => :HONECLAWS,
        :typeChange => [:FIGHTING, :PSYCHIC],
        :itemchange => :ELEMENTALSEED,
        :abilitychange => :SHARPNESS,
        :ev => [0, 255, 0, 255, 0, 252],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
        },
        :movesetUpdate => [:LEAFBLADE, :SACREDSWORD, :PSYCHOCUT, :SPIRITBREAK],
      },
    },
  },

  :FOEHNMISTRAL => {
    :name => "Foehn & Mistral",
    :entryText => "Mistral holds onto Foehn's hand.",
    :shieldCount => 4,
    :immunities => {},
    :moninfo => {
      :species => :GALLADE,
      :level => 100,
      :form => 2,
      :moves => [:MOONBLAST, :CLOSECOMBAT, :NIGHTSLASH, :SHADOWBALL],
      :ability => :SYNCHRONIZE,
      :nature => :NAIVE,
      :ev => [255, 255, 0, 255, 0, 255],
    },
    :onBreakEffects => {
      4 => {
        :threshold => 0,
        :message => "Foehn walks in front!",
        :abilitychange => :ANALYTIC,
        :movesetUpdate => [:THUNDERBOLT, :MOONBLAST, :SHADOWBALL, :SURF],
      },
      2 => {
        :threshold => 0,
        :message => "Mistral pushes Foehn away!",
        :animation => :HONECLAWS,
        :abilitychange => :SHARPNESS,
        :bossStatChanges => {
          PBStats::ATTACK => 2,
          PBStats::SPDEF => 2,
        },
        :movesetUpdate => [:CLOSECOMBAT, :NIGHTSLASH, :PSYCHOCUT, :SPIRITBREAK],
      },
      1 => {
        :threshold => 0,
        :message => "Foehn takes Mistral's hand! They fight together!",
        :animation => :HONECLAWS,
        :abilitychange => :PARENTALBOND,
        :bossStatChanges => {
          PBStats::ATTACK => 2,
          PBStats::SPATK => 4,
          PBStats::SPDEF => 2,
        },
        :movesetUpdate => [:MOONBLAST, :DRAINPUNCH, :PSYCHIC, :NIGHTSLASH],
      },
    },
  },

  :MECHAGGRON => {
    :name => "AGG-???",
    :entryText => "The Mecha-Aggron attacked!",
    :shieldCount => 3,
    :barGraphic => "",
    :immunities => {
      :moves => [],
      :fieldEffectDamage => [],
    },
    :moninfo => {
      :species => :AGGRON,
      :level => 85,
      :item => :WEAKNESSPOLICY,
      :form => 2,
      :moves => [:EARTHQUAKE, :JAWLOCK, :IRONDEFENSE, :BODYPRESS],
      :ability => :ROCKHEAD,
      :nature => :ADAMANT,
      :iv => 31,
      :ev => [252, 4, 252, 0, 0, 0],
    },
    :onBreakEffects => {}
  },


  :DRAGAPULTBOSS => {
    :name => "Spectral Predator",
    :entryText => "Dragapult is eyeing you hungrily!",
    :shieldCount => 3,
    :immunities => {},
    :moninfo => {
      :species => :DRAGAPULT,
      :level => 90,
      :moves => [:DRAGONDARTS, :PHANTOMFORCE, :DRAGONDANCE, :FIREBLAST],
      :nature => :NAUGHTY,
      :item => :LIFEORB,
      :iv => 31,
      :ev => [0, 252, 0, 4, 0, 252],
    },
    :sosDetails => {
      :activationRequirement => "battler.shieldCount < 3",
      :moninfos => {
        1 => {
          :species => :DRAKLOAK,
          :level => 95,
          :moves => [:DRAGONRUSH, :OUTRAGE, :DRAGONCHEER, :PHANTOMFORCE],
          :nature => :NAUGHTY,
          :item => :LIFEORB,
          :iv => 31,
          :ev => [0, 252, 0, 0, 0, 252],
        },
      },
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Dragapult started getting desperate!",
        :bossStatChanges => {
          PBStats::ATTACK => 2,
          PBStats::SPDEF => 2,
        },
      },
    },
  },

  :WITCHOFTHEABYSS => {
    :name => "Abyssal Witch",
    :entryText => "The Witch has entered the field!",
    :shieldCount => 3,
    :immunities => {},
    :delayedactions => {
      :FireMagic => {
        :delay => 2,
        :instantMove => [:FIRESPIN, 0],
        :queueDelays => [:FireMagic],
      },
      :Curses => {
        :delay => 1,
        :playerEffects => {
          :Curse => [true, :CURSE, nil],
        },
        :queueDelays => [:CursesRepeat],
      },
      :CursesRepeat => {
        :delay => 3,
        :playerEffects => {
          :Curse => [true, :CURSE, nil],
        },
        :queueDelays => [:CursesRepeat],
      },
      :SongOfTheEnd => {
        :delay => 3,
        :playerEffects => {
          :PerishSong => [2, :PERISHSONG, "{1} will faint in 2 turns!"],
        },
        :queueDelays => [:SongOfTheEnd],
      },
    },
    :moninfo => {
      :species => :MISMAGIUS,
      :level => 100,
      :moves => [:WILLOWISP, :HEX, :CALMMIND, :PROTECT],
      :nature => :TIMID,
      :item => :MAGICALSEED,
      :iv => 31,
      :ev => [0, 0, 0, 252, 0, 252],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :queueDelays => [:FireMagic],
        :message => "The Witch summoned spectral flames!",
        :bossStatChanges => {
          PBStats::SPEED => 1,
        },
      },
      2 => {
        :threshold => 0,
        :instantMove => [:MAGICROOM, 0],
        :queueDelays => [:Curses],
        :statDropCure => true,
        :message => "The Witch laid her curses!",
      },
      1 => {
        :threshold => 0,
        :queueDelays => [:SongOfTheEnd],
      },
    },
  },

  :TALONPORTRAIT => {
    :name => "Gusts of Emptiness",
    :entryText => "Tornadus doesn't recognize you.",
    :shieldCount => 3,
    :immunities => {},
    :item => :LIFEORB,
    :moninfo => {
      :species => :TORNADUS,
      :level => 100,
      :moves => [:HURRICANE, :KNOCKOFF, :HEATWAVE, :GRASSKNOT],
      :nature => :MODEST,
      :iv => 31,
      :ev => [48, 48, 48, 252, 48, 252],
    },
    :onBreakEffects => {
      3 => {
      },
      2 => {
        :weatherChange => [:STRONGWINDS, 5, "Winds suddenly pick up!"],
      },
      1 => {
        :threshold => 0,
        :message => "<char>T4L0N: ### ###### ###### #### ###", # YOU CANNOT ESCAPE YOUR SIN
        :animation => :HURRICANE,
        :formchange => 1,
        :bossStatChanges => {
          PBStats::SPATK => 4,
          PBStats::SPDEF => 2,
        },
        :movesetUpdate => [:BLEAKWINDSTORM, :NASTYPLOT, :HEATWAVE, :FOCUSBLAST],
      },
    },
  },

  :KARRINAPORTRAIT => { #NEEDS EDITING
    :name => "Hollow Diamond",
    :entryText => "This gem has no glimmer or shine.",
    :shieldCount => 3,
    :immunities => {},
    :item => :DIANCITE,
    :moninfo => {
      :species => :DIANCIE,
      :level => 100,
      :moves => [:DIAMONDSTORM, :STEALTHROCK, :PROTECT, :DAZZLINGGLEAM],
      :nature => :ADAMANT,
      :form => 1,
      :iv => 31,
      :ev => [48, 48, 48, 252, 48, 252]
    },
    :onBreakEffects => {
      3 => {
      },
      2 => {
        :weatherChange => [:SANDSTORM, 5, "Winds suddenly pick up!"],
      },
      1 => {
        :threshold => 0,
        :message => "<char>KARRINA: ### ###### ###### #### ###", # YOU CANNOT ESCAPE YOUR SIN
        :animation => :GEOMANCY,
          :bossStatChanges => {
          PBStats::SPATK => 4,
          PBStats::SPDEF => 2,
        },
      },
    },
  },

  :RIFTGARBODOR2 => { #NEEDS EDITING
    :name => "Rift Garbodor",
    :entryText => "The rampaging Rift Garbodor attacked!",
    :shieldCount => 3,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :GARBODOR,
      :level => 90,
      :item => :BLACKSLUDGE,
      :moves => [:DRAINPUNCH, :GIGADRAIN, :DARKESTLARIAT, :SLUDGEWAVE],
      :nature => :SASSY,
      :form => 2,
      :shiny => true,
      :iv => 31,
      :ev => [252, 0, 128, 0, 128, 0],
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :message => "Garbodor gorged itself on rotten berries!",
        :typeChange => [:POISON, :GRASS],
        :movesetUpdate => [:DRAINPUNCH, :GIGADRAIN, :DARKESTLARIAT, :BELCH],
        :itemchange => :SITRUSBERRY,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
        :statDropCure => true,
      },
      2 => {
        :threshold => 0,
        :message => "Garbodor gorged itself on scrap metal!",
        :typeChange => [:POISON, :STEEL],
        :movesetUpdate => [:DRAINPUNCH, :GIGADRAIN, :GYROBALL, :BELCH],
        :itemchange => :METALCOAT,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
        :statDropCure => true,
      },
      1 => {
        :threshold => 0,
        :message => "Garbodor desperately gorged itself on nearby rocks!",
        :typeChange => [:POISON, :ROCK],
        :movesetUpdate => [:ROCKBLAST, :GIGADRAIN, :GYROBALL, :BELCH],
        :itemchange => :ROCKYHELMET,
        :bossStatChanges => {
          PBStats::ATTACK => 2,
          PBStats::DEFENSE => -1,
          PBStats::SPATK => 2,
          PBStats::SPDEF => -1,
        },
        :statDropCure => true,
      },
    },
  },

  :RIFTCHANDELURE2 => {
    :name => "Rift Chandelure",
    :entryText => "Otherworldly wind chimes echo through the air...",
    :shieldCount => 3,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :CHANDELURE,
      :level => 90,
      :item => :FIREGEM,
      :form => 3,
      :moves => [:SHADOWBALL, :AIRSLASH, :FIREBLAST, :WILLOWISP],
      :gender => :M,
      :nature => :TIMID,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 0, 252, 4, 252],
    },
    :onEntryEffects => {
      :message => "A feeling of warmth emanates from Rift Chandelure...",
    },
    :onBreakEffects => {
      3 => {
        :threshold => 0,
        :animation => :OMINOUSWIND,
        :message => "The air feels cold and moist...",
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
        :itemchange => :WATERGEM,
        :typeChange => [:GHOST, :WATER],
        :movesetUpdate => [:SHADOWBALL, :AIRSLASH, :SURF, :WHIRLPOOL],
        :abilitychange => :TRACE,
      },
      2 => {
        :threshold => 0,
        :animation => :OMINOUSWIND,
        :message => "A sickly sweet scent attacks your nose...",
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
          PBStats::SPDEF => 1,
        },
        :itemchange => :GRASSGEM,
        :typeChange => [:GHOST, :GRASS],
        :movesetUpdate => [:SHADOWBALL, :AIRSLASH, :ENERGYBALL, :LEECHSEED],
        :abilitychange => :TRACE,
      },
      1 => {
        :threshold => 0,
        :animation => :OMINOUSWIND,
        :message => "The feeling of static is all around...",
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::SPEED => 1,
        },
        :itemchange => :ELECTRICGEM,
        :typeChange => [:GHOST, :ELECTRIC],
        :movesetUpdate => [:SHADOWBALL, :AIRSLASH, :THUNDERBOLT, :THUNDERWAVE],
        :abilitychange => :TRACE,
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
      :level => 90,
      :moves => [:TOXICSPIKES, :STEALTHROCK, :SPIKES, :DIAMONDSTORM],
      :nature => :BOLD,
      :form => 1,
      :iv => 31,
      :ev => [0, 0, 252, 0, 252, 0],
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
        :statChangeRefresh => true,
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
      1 => {
        :threshold => 0,
        :movesetUpdate => [:INJECTION, :SLUDGEBOMB, :NIGHTSHADE, :WRAP],
        :bossStatChanges => {
          PBStats::ATTACK => 1,
          PBStats::SPATK => 1,
        },
      },
    },
  },

  :WITHER => {
    :name => "Wither",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :TOGEKISS,
      :level => 105,
      :item => :LIFEORB,
      :moves => [:SHADOWFIRE, :SHADOWHALF, :SHADOWWAVE, :SHADOWEND],
      :ability => :INTIMIDATE,
      :nature => :MODEST,
      :name => "Wither",
      :gender => :F,
      :iv => 31,
      :form => 1,
      :happiness => 0,
      :ev => [0, 140, 4, 252, 0, 100],
    },
    :onBreakEffects => {},
  },

  :ETERNAMAX => {
    :name => "Eternatus",
    :shieldCount => 1,
    :immunities => {
      :fieldEffectDamage => [:INFERNAL],
    },
    :moninfo => {
      :species => :ETERNATUS,
      :level => 105,
      :item => :ELEMENTALSEED,
      :moves => [:DYNAMAXCANNON, :SHADOWHALF, :SLUDGEBOMB, :FIREBLAST],
      :ability => :PRESSURE,
      :nature => :MODEST,
      :shiny => true,
      :iv => 31,
      :form => 1,
      :happiness => 0,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :onBreakEffects => {
      1 => {
        :firstUnfaintedOpposingEffect => {
          :MaliciousMoth => [2, "MalMoths", "{2} will be erased in 2 turns..."],
        },
      },
    },
  },

  :QUEENNIHILEGO => {
    :name => "Queen Nihilego",
    :entryText => "You feel a heavy and crippling sense of dread...",
    :shieldCount => 6,
    :immunities => {},
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
      :item => :DEMONSTONE,
      :moves => [:NIHILLIGHT, nil, nil, nil],
      :nature => :MODEST,
      :form => 2,
      :iv => 31,
      :ev => [252, 252, 252, 252, 252, 252],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 1,
        :CustomMethod => "battler.shieldCount = 6 and battler.pokemon.shieldCount = 6 and @battle.scene.sprites[\"battlebox\#{battler.index}\"].shieldCount = 6 and @battle.scene.sprites[\"battlebox\#{battler.index}\"].refresh",
        :message => "<char>STORM-NYM: Your defiance is amusing, but futile.",
        :thresholdmessage => "The Queen is completely unfazed!",
      },
    },
  },

  :QUEENNIHILEGO_1 => {
    :name => "Queen Nihilego",
    :entryText => "You feel a heavy and crippling sense of dread...",
    :shieldCount => 6,
    :immunities => {},
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
      :item => :DEMONSTONE,
      :moves => [:SPACIALREND, :TOXICSPIKES, :EARTHQUAKE, :NIHILLIGHT],
      :nature => :MODEST,
      :form => 2,
      :iv => 31,
      :ev => [0, 0, 0, 0, 0, 0],
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

  :POWEROFUS => {
    :name => "Ditto",
    :shieldCount => 2,
    :immunities => {},
    :delayedactions => {
      :RageOfTheHeavens1 => {
        :delay => 1,
        :sprite => :None,
        :message => "A thunderstorm is roiling up above!",
        :queueDelays => [:RageOfTheHeavens2],
      },
      :RageOfTheHeavens2 => {
        :delay => 4,
        :sprite => :None,
        :turntypeDamage => [:QMARKS, :THUNDER, 3, "An earthshattering bolt of lightning crashed down!"],
        :trainerqueueDelays => [:RageOfTheHeavens2],
      },
    },
    :onEntryEffects => {
      :teraType => [:PSYCHIC],
    },
    :moninfo => {
      :species => :DITTO,
      :level => 100,
      :moves => [:TRANSFORM, :TRANSFORM, :TRANSFORM, :TRANSFORM],
      :ability => :LIMBER,
      :item => :MAGICALSEED,
      :iv => 31,
      :nature => :TIMID,
      :happiness => 255,
      :ev => [252, 0, 4, 252, 0, 252],
    },
    :onBreakEffects => {
      2 => {
        :itemchange => :MAGICALSEED,
        :userSwitch => true,
        :endTurn => true,
      },
      1 => {
        :itemchange => :MAGICALSEED,
        :statusCure => true,
        :movesetUpdate => [:AEROBLAST, :PSYSHOCK, :EARTHPOWER, :DAZZLINGGLEAM],
        :userSwitch => true,
        :endTurn => true,
      },
    },
  },

  :MIMIC => {
    :name => "Mimic",
    :shieldCount => 2,
    :immunities => {},
    :delayedactions => {
      :RageOfTheHeavens1 => {
        :delay => 2,
        :turntypeDamage => [:FLYING, :TWISTER, 16, "The storm-winds came roaring down!"],
        :trainerqueueDelays => [:RageOfTheHeavens1],
        :getsOverwritten => [:RageOfTheHeavens2, :RageOfTheHeavens3],
      },
      :RageOfTheHeavens2 => {
        :delay => 2,
        :turntypeDamage => [:FLYING, :TWISTER, 12, "The storm-winds came roaring down!"],
        :trainerqueueDelays => [:RageOfTheHeavens2],
        :getsOverwritten => [:RageOfTheHeavens3],
      },
      :RageOfTheHeavens3 => {
        :delay => 1,
        :turntypeDamage => [:FLYING, :TWISTER, 12, "The storm-winds came roaring down!"],
        :trainerqueueDelays => [:RageOfTheHeavens3],
      },
    },
    :onEntryEffects => {
      :transformTo => {
        :species => :LUGIA,
        :level => 1,
        :item => :SKYPLATE,
        :moves => [:AEROBLAST, :LIFEDEW, :FOLLOWME, :DAZZLINGGLEAM],
        :ability => :MULTISCALE,
        :nature => :MODEST,
        :shiny => true,
        :form => 0,
        :iv => 31,
        :name => "Lugia",
        :happiness => 255,
        :ev => [0, 0, 4, 252, 0, 252],
      },
    },
    :moninfo => {
      :species => :DITTO,
      :level => 1,
      :moves => [:TRANSFORM, :TRANSFORM, :TRANSFORM, :TRANSFORM],
      :ability => :LIMBER,
      :shiny => true,
      :iv => 31,
      :happiness => 255,
      :ev => [0, 0, 4, 252, 0, 252],
    },
    :onBreakEffects => {
      2 => {
        :message => "The winds are howling louder than before!",
        :trainerqueueDelays => [:RageOfTheHeavens2],
        :userSwitch => true,
      },
      1 => {
        :itemchange => :MAGICALSEED,
        :userSwitch => true,
      },
    },
  },



  :BOSSHARU => { #WIP
    :name => "Haru, The Unshaken",
    :entryText => "Haru stands firm!",
    :shieldCount => 1,
    :doublebattle => true,
    :immunities => {},
    :moninfo => {
      :species => :GIGALITH,
      :level => 30,
      :moves => [:TAKEDOWN, :NOBLEROAR, :FIREFANG, :ROAR],
      :ability => :WEAKARMOR,
      :gender => :M,
      :shiny => true,
      :form => 1,
      :nature => :NAUGHTY,
      :iv => 10,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :sosDetails => { # pokemon details can delete this lol
      :activationRequirement => "battler.shieldCount < 1",
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :BOLDORE,
          :level => 25,
          :moves => [:ROCKSLIDE, :HEADBUTT, :SMACKDOWN, :STEALTHROCK],
          :ability => :STURDY,
          :iv => 10,
        },
      },
    },
    :onBreakEffects => {},
  },

  :BOSSRUTH => { #WIP
    :name => "Ruth, The Hungry",
    :entryText => "Ruth looks like she's about to cry... She's so hungry.",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :CRADILY,
      :level => 34,
      :moves => [:GIGADRAIN, :INGRAIN, :ANCIENTPOWER, :WRINGOUT],
      :ability => :SUCTIONCUPS,
      :gender => :M,
      :form => 1,
      :nature => :BOLD,
      :iv => 10,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :sosDetails => { # pokemon details DELETE
      :activationRequirement => "battler.shieldCount < 1",
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :LILEEP,
          :level => 25,
          :moves => [:ANCIENTPOWER, :BRINE, :WRAP, :CONFUSERAY],
          :ability => :SUCTIONCUPS,
          :iv => 10,
        },
      },
    },
    :onBreakEffects => {},
  },

  :BOSSGUARDIAN => { #WIP Normal Branch. This is the Zone Boss so it should be harder
    :name => "Celebi, The Guardian",
    :entryText => "Celebi looks very thankful!",
    :shieldCount => 3,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :CELEBI,
      :level => 35,
      :moves => [:PSYCHIC, :ANCIENTPOWER, :SHADOWBALL, :DAZZLINGGLEAM],
      :ability => :PRESSURE,
      :shiny => true,
      :form => 1,
      :nature => :MODEST,
      :iv => 10,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :sosDetails => { # pokemon details || can delete this
      :activationRequirement => "battler.shieldCount < 1",
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :ENTEI,
          :level => 35,
          :moves => [:EMBER, :HEADBUTT, :LEER, :WORKUP],
          :ability => :PRESSURE,
          :iv => 10,
        },
        2 => {
          :species => :SUICUNE,
          :level => 35,
          :moves => [:EMBER, :HEADBUTT, :LEER, :WORKUP],
          :ability => :PRESSURE,
          :iv => 10,
        },
        3 => {
          :species => :RAIKOU,
          :level => 35,
          :moves => [:EMBER, :HEADBUTT, :LEER, :WORKUP],
          :ability => :PRESSURE,
          :iv => 10,
        },
      },
    },
    :onBreakEffects => {},
  },

  :BOSSGUARDIAN_1 => { #WIP EON Branch. This is a MINI BOSS. so yeah no SOS
    :name => "Celebi, The Annoyed",
    :entryText => "Celebi looks so annoyed at you right now.",
    :shieldCount => 2,
    :immunities => {},
    :doublebattle => true,
    :moninfo => {
      :species => :CELEBI,
      :level => 40,
      :moves => [:GRASSKNOT, :PSYCHIC, :ANCIENTPOWER, :FUTURESIGHT],
      :ability => :PRESSURE,
      :shiny => true,
      :form => 1,
      :nature => :NAUGHTY,
      :iv => 31,
      :happiness => 255,
    },
    :onBreakEffects => {},
  },

  :BOSSCRESSGEN2 => { #WIP EON Branch. This is the final boss of the roguelike area.
    :name => "Lost Moonsister",
    :entryText => "Cresselia gazes upon the moon with sadness.",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :CRESSELIA,
      :level => 50,
      :moves => [:ICEBEAM, :PSYCHIC, :SHADOWBALL, :CALMMIND],
      :ability => :UNNERVE,
      :shiny => true,
      :form => 1,
      :nature => :MODEST,
      :iv => 10,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :onBreakEffects => {},
  },

  :BOSSDARKGEN2 => { #WIP EON Branch. This is the final boss of the roguelike area.
    :name => "Her Darkside",
    :entryText => "Darkrai feels Cresselia's anguish...",
    :shieldCount => 0,
    :immunities => {},
    :moninfo => {
      :species => :DARKRAI,
      :level => 50,
      :moves => [:DARKPULSE, :SHADOWBALL, :DARKVOID, :DREAMEATER],
      :ability => :UNNERVE,
      :shiny => true,
      :form => 9,
      :nature => :NAUGHTY,
      :iv => 10,
      :happiness => 255,
      :ev => [0, 0, 0, 0, 0, 0],
    },
    :onBreakEffects => {},
  },

  :BOSSABSOL => {
    :name => "Devil's Advocate",
    :entryText => "Absol's gaze pierces your soul.",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :ABSOL,
      :level => 100,
      :item => :ABSOLITEZ,
      :moves => [:NIGHTSLASH, :SHADOWCLAW, :SWORDSDANCE, :PROTECT],
      :ability => :SUPERLUCK,
      :gender => :M,
      :nature => :ADAMANT,
      :iv => 31,
      :ev => [4, 252, 0, 0, 0, 252],
    },
    :delayedactions => {
      :AllThingsMustDie => {
        :delay => 1,
        :playerEffects => {
          :PerishSong => [3, :PERISHSONG, "Absol sang a song of ruin."],
        },
        :queueDelays => [:AllThingsMustDie2],
      },
      :AllThingsMustDie2 => {
        :delay => 3,
        :playerEffects => {
          :PerishSong => [3, :PERISHSONG, "Absol sang a song of ruin."],
        },
        :queueDelays => [:AllThingsMustDie2],
      },
    },
    :sosDetails => { # sospokemon details
      :activationRequirement => "battler.shieldCount <= 2",
      :continuous => true,
      :totalMonCount => 2,
      :moninfos => {
        1 => {
          :species => :CHARIZARD,
          :level => 100,
          :item => :LIFEORB,
          :moves => [:FLAMETHROWER, :AIRSLASH, :WILLOWISP, :FOCUSBLAST],
          :ability => :BLAZE,
          :gender => :F,
          :nature => :JOLLY,
          :shiny => true,
          :iv => 31,
          :ev => [0, 0, 0, 252, 0, 252],
        },
        2 => {
          :species => :SEVIPER,
          :level => 100,
          :item => :SEVCREST,
          :moves => [:SLUDGEBOMB, :GIGADRAIN, :FLAMETHROWER, :DARKPULSE],
          :ability => :SHEDSKIN,
          :gender => :M,
          :nature => :TIMID,
          :iv => 31,
          :ev => [0, 4, 4, 252, 0, 252],
        },
      },
    },
    :onBreakEffects => {},
    :onEntryEffects => {
      :queueDelays => [:AllThingsMustDie],
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
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :playersideChanges => {
          :Spikes => [1, :SPIKES, "The Stalker laid down defensive spikes!"],
        },
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
    },
  },

  :TWINDANCERS_TOWER => {
    :name => "Yulia",
    :entryText => "Showtime! May the audience watch intently!",
    :shieldCount => 1,
    :immunities => {},
    :moninfo => {
      :species => :LILLIGANT,
      :level => 100,
      :form => 2,
      :item => :SITRUSBERRY,
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
      :overlay => [:GRASSY, "Grass grew to cover the battlefield!", 8, :GRASSYTERRAIN],
    },
    :onBreakEffects => {
      1 => {
        :threshold => 0,
        :message => "Yulia elegantly wipes the dirt off her dress and begins anew! Hear her swan song!",
        :statusCure => true,
        :movesetUpdate => [:INFERNALPARADE, :RAGEFIST, :AURASPHERE, :ALLURINGVOICE],
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
      :level => 100,
      :form => 3,
      :item => :SITRUSBERRY,
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
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :TORTERRA,
      :level => 100,
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
        :statusCure => true,
        :itemchange => :WEAKNESSPOLICY,
        :abilitychange => :SANDFORCE,
        :fieldChange => :DESERT,
        :movesetUpdate => [:EARTHQUAKE, :HEATCRASH, :HEAVYSLAM, :STONEEDGE],
      },
    },
  },

  :KINGSOFAPPLES_TOWER => {
    :name => "Kings of Apples",
    :entryText => "Wallow! Sweetness and tart, what an art! Be trapped in the sap of the Kings of Apples!",
    :shieldCount => 2,
    :immunities => {},
    :moninfo => {
      :species => :HYDRAPPLE,
      :level => 100,
      :form => 1,
      :item => :IAPAPABERRY,
      :moves => [:SLUDGEWAVE, :MUDDYWATER, :FICKLEBEAM, :SYNTHESIS],
      :ability => :ONEBADAPPLE,
      :nature => :MODEST,
      :iv => 31,
      :happiness => 255,
      :ev => [252, 0, 4, 252, 0, 0],
    },
    :delayedactions => {
      :RottenBerries => {
        :delay => 4,
        :message => "Rotten berries were regurgitated at your Pokémon!",
        :playerSideStatusChanges => [:POISON, "Poison"],
        :playerSideStatChanges => {
          PBStats::SPDEF => -1,
        },
        :queueDelays => [:RottenBerries],
      },
    },
    :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
      :fieldChange => :SWAMP,
      :fieldChangeMessage => "A swamp of mushy apples is formed!",
      :bossEffect => {
        :AquaRing => [true, :AQUARING, "Swamp water enveloped the Kings!"],
      },
      :queueDelays => [:RottenBerries],
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :itemchange => :GANLONBERRY,
        :typeChange => [:BUG,:DRAGON],
        :movesetUpdate => [:STRUGGLEBUG, :MUDDYWATER, :FICKLEBEAM, :SYNTHESIS],
        :bossStatChanges => {
          PBStats::DEFENSE => 1,
        },
      },
      1 => {
        :threshold => 0,
        :itemchange => :APICOTBERRY,
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
      :level => 100,
      :form => 1,
      :item => :NEVERMELTICE,
      :moves => [:ICEBALL, :DEFENSECURL, :MACHPUNCH, :ZENHEADBUTT],
      :ability => :WINGSOFRUIN,
      :nature => :NAUGHTY,
      :iv => 31,
      :happiness => 255,
    },
    :onBreakEffects => {
      2 => {
        :threshold => 0,
        :message => "The King of Water flexes its mind!",
        :statusCure => true,
        :typeChange => [:WATER,:FIGHTING],
        :itemchange => :BLUNDERPOLICY,
        :movesetUpdate => [:HYDROPUMP, :FOCUSBLAST, :HYPNOSIS, :BLIZZARD],
        :bossStatChanges => {
          PBStats::SPATK => 1,
        },
      },
      1 => {
        :threshold => 0,
        :formchange => 2,
        :animation => :WHIRLPOOL,
        :message => "The King of Water brought out the BIG GUNS!!!!!!! UH OH!!!!",
        :itemchange => :PUNCHINGGLOVE,
        :movesetUpdate => [:DYNAMICPUNCH, :ICEPUNCH, :SURGINGSTRIKES, :BULKUP],
        :bossStatChanges => {
          PBStats::ATTACK => 2,
        },
      },
    },
  },
  #

  # Shadow Den Dummy

  :SHADOWDEN => {
    :name => "",
    :shieldCount => 1,
    :immunities => {},
    :canrun => true,
    :capturable => true, # can you catch this boss after shields are removed?
    :moninfo => {},
    :onBreakEffects => {},
  },
}


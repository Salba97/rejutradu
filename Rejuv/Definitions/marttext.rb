# Refer to Mart.rb for documentation on syntax

MARTHASH = {
  :DEFAULT => {
    :Messages => {
      :welcome => "Welcome!\nHow may I serve you?",
      :goodbye => "Please come again!",
      :anything_else => "Is there anything else I can help you with?",
      :nothing_to_buy => "It looks like I don't have anything to sell you right now!",

      :no_money => "You don't have enough money.",
      :no_puppet => "You don't have enough Puppet Coins.",
      :no_coins => "You don't have enough Coins.",
      :no_ap => "You don't have enough AP.",
      :no_bp => "I'm afraid you don't have the BP for that!",
      :no_re => "You don't have enough Red Essence.",
      :no_items => "You don't have enough {1}.",

      :cannot_sell => "{1}? Oh, no.\nI can't buy that.",
      :sell_quantity => "{1}?\nHow many would you like to sell?",
      :sell_confirm => "I can pay {1}.\nWould that be OK?",
      :sell_success => "Turned over {1}\nand received {2}.",

      :purchase_confirm_single => "Certainly. You want {1}.\nThat will be {2}. OK?",
      :choose_quantity => "{1}? Certainly.\nHow many would you like?",
      :purchase_confirm_multiple => "{1}, and you want {2}.\nThat will be {3}. OK?",

      :full_puppet => "Sorry, but you're too full of coins.",
      :full_coins => "Sorry, but your Coin Case is full.",
      :full_item => "Sorry, but you have no more room in the Bag.",

      :success_money => "Here you are!\nThank you!",
      :success_coins => "Here you are!\nThank you!",
      :success_puppet => "Here you are!\nThank you!",
      :success_ap => "Here you are!\nThank you!",
      :success_re => "Here you are!\nThank you!",
      :success_bp => "Here you are!\nThank you!",
      :success_items => "Here you are!\nThank you!",

      :premier_one => "I'll throw in a Premier Ball, too.",
      :premier_many => "I'll throw in {1} Premier Balls, too.",
    },
    :Inventory => [],
  },

  :APShop => {
    :Messages => {
      :welcome => "We exchange your achievement points for prizes. Which prize would you like?",
      :anything_else => "Which prize would you like?",
      :nothing_to_buy => "Sorry, looks like you've obtained everything here.",

      :no_ap => "Sorry, you'll need more points than that.",

      :purchase_confirm_single => "So, you want the {1}?",
    },
    :Inventory => {
      "General Items" => [
        ItemStock.of(:ABILITYCAPSULE).costs(3, :AP),
        ItemStock.of(:RARECANDY).costs(6, :AP),
        ItemStock.of(:PPUP).costs(6, :AP),
        ItemStock.of(:EXPALL).costs(30, :AP),
        ItemStock.of(:HPCARD).costs(10, :AP),
        ItemStock.of(:ATKCARD).costs(10, :AP),
        ItemStock.of(:DEFCARD).costs(10, :AP),
        ItemStock.of(:SPEEDCARD).costs(10, :AP),
        ItemStock.of(:SPATKCARD).costs(10, :AP),
        ItemStock.of(:SPDEFCARD).costs(10, :AP),
        ItemStock.of(:TM47).costs(5, :AP).properties(
          conditions: [
            '$Trainer.numbadges >= 5',
          ],
        ),
        ItemStock.of(:TM56).costs(5, :AP).properties(
          conditions: [
            '$Trainer.numbadges >= 5',
          ],
        ),
      ],
      "Mints" => [
        ItemStock.of(:LONELYMINT).costs(3, :AP),
        ItemStock.of(:ADAMANTMINT).costs(3, :AP),
        ItemStock.of(:BRAVEMINT).costs(3, :AP),
        ItemStock.of(:NAUGHTYMINT).costs(3, :AP),
        ItemStock.of(:BOLDMINT).costs(3, :AP),
        ItemStock.of(:IMPISHMINT).costs(3, :AP),
        ItemStock.of(:RELAXEDMINT).costs(3, :AP),
        ItemStock.of(:LAXMINT).costs(3, :AP),
        ItemStock.of(:MODESTMINT).costs(3, :AP),
        ItemStock.of(:QUIETMINT).costs(3, :AP),
        ItemStock.of(:RASHMINT).costs(3, :AP),
        ItemStock.of(:MILDMINT).costs(3, :AP),
        ItemStock.of(:CAREFULMINT).costs(3, :AP),
        ItemStock.of(:SASSYMINT).costs(3, :AP),
        ItemStock.of(:CALMMINT).costs(3, :AP),
        ItemStock.of(:GENTLEMINT).costs(3, :AP),
        ItemStock.of(:TIMIDMINT).costs(3, :AP),
        ItemStock.of(:HASTYMINT).costs(3, :AP),
        ItemStock.of(:NAIVEMINT).costs(3, :AP),
        ItemStock.of(:JOLLYMINT).costs(3, :AP),
        ItemStock.of(:SERIOUSMINT).costs(1, :AP),
      ],
      "Travel Items" => [
        ItemStock.of(:GOLDENAXE).costs(10, :AP),
        ItemStock.of(:GOLDENHAMMER).costs(10, :AP),
        ItemStock.of(:GOLDENLANTERN).costs(10, :AP),
        ItemStock.of(:GOLDENSURFBOARD).costs(15, :AP),
        ItemStock.of(:GOLDENGAUNTLET).costs(15, :AP),
        ItemStock.of(:GOLDENSCUBAGEAR).costs(15, :AP),
        ItemStock.of(:GOLDENWINGS).costs(20, :AP),
        ItemStock.of(:GOLDENJETPACK).costs(20, :AP),
        ItemStock.of(:GOLDENDRIFTBOARD).costs(20, :AP),
        ItemStock.of(:GOLDENCLAWS).costs(20, :AP),
      ],
    },
  },

  :DoxiePrisms => {
    :Messages => {
      :welcome => "DOXIE: (Give me your Black Prisms!)",
      :goodbye => "",
      :anything_else => "DOXIE: (Give me your Black Prisms!)",

      :no_items => "DOXIE: Not enough!",

      :purchase_confirm_single => "DOXIE: I will take {3} for {1}.\nIs okay?\nWhat do you say?",
      :choose_quantity => "",
      :purchase_confirm_multiple => "DOXIE: I will take {4} for {2} {1}.\nIs okay?\nWhat do you say?",

      :full_item => "",

      :success_items => "DOXIE: Okie.",
    },
    :Inventory => [
      ItemStock.of(:GREENSHARD, 10).costs(3, :BLKPRISM),
      ItemStock.of(:REDSHARD, 10).costs(3, :BLKPRISM),
      ItemStock.of(:BLUESHARD, 10).costs(3, :BLKPRISM),
      ItemStock.of(:YELLOWSHARD, 10).costs(3, :BLKPRISM),
      ItemStock.of(:HEARTSCALE, 3).costs(1, :BLKPRISM),
      ItemStock.of(:EVTUNER, 2).costs(1, :BLKPRISM).properties(conditions: ['$Trainer.numbadges >= 15']),
      ItemStock.of(:EVBOOSTER, 2).costs(1, :BLKPRISM).properties(conditions: ['$Trainer.numbadges >= 15']),
      ItemStock.of(:NUGGET, 4).costs(5, :BLKPRISM),
      ItemStock.of(:ABILITYCAPSULE, 3).costs(3, :BLKPRISM),
      ItemStock.of(:PEARLSTRING, 3).costs(8, :BLKPRISM),
      ItemStock.of(:CELLIMPRINT, 5).costs(10, :BLKPRISM),
      ItemStock.of(:GLITTERBALL, 3).costs(15, :BLKPRISM).noPremierBallBonus(),
    ],
    :hasPicture => true,
  },

  :MarshieMoves => {
    :Messages => {
      :welcome => "MARSHIE: You want to learn...?",
      :goodbye => "MARSHIE: Alright... you'll be back...",
      :anything_else => "MARSHIE: You want to learn...?",

      :no_items => "MARSHIE: You no have enough...\nMe eat you...",

      :purchase_confirm_single => "MARSHIE: {3}... For {1}...",

      :success_items => "MARSHIE: Yes... Good...",
    },
    :Inventory => [
      MoveStock.of(:BIND).costs(2, :REDSHARD),
      MoveStock.of(:COVET).costs(2, :BLUESHARD),
      MoveStock.of(:BLOCK).costs(2, :YELLOWSHARD),
      MoveStock.of(:SPITE).costs(2, :GREENSHARD),
      MoveStock.of(:SWIFT).costs(2, :YELLOWSHARD),
      MoveStock.of(:AFTERYOU).costs(2, :REDSHARD),
      MoveStock.of(:MAGICCOAT).costs(2, :BLUESHARD),
      MoveStock.of(:VENOMDRENCH).costs(2, :BLUESHARD),
    ],
  },

  :MargoMoves => {
    :Messages => {
      :welcome => "MARGO: WHAT CAN I DO YOU FOR?",
      :goodbye => "MARGO: COME AGAIN!",
      :anything_else => "MARGO: WHAT CAN I DO YOU FOR?",

      :no_items => "MARGO: YOU DON'T HAVE ENOUGH?\nME EAT YOU!",

      :purchase_confirm_single => "MARGO: THAT'LL BE {3}, BUB.",

      :success_items => "MARGO: YOU'RE TOO KIND.",
    },
    :Inventory => [
      MoveStock.of(:RECYCLE).costs(2, :YELLOWSHARD),
      MoveStock.of(:WORRYSEED).costs(2, :GREENSHARD),
      MoveStock.of(:SNORE).costs(2, :REDSHARD),
      MoveStock.of(:SHOCKWAVE).costs(2, :BLUESHARD),
      MoveStock.of(:WATERPULSE).costs(2, :REDSHARD),
      MoveStock.of(:SNATCH).costs(2, :BLUESHARD),
      MoveStock.of(:IMPRISON).costs(2, :BLUESHARD),
      MoveStock.of(:WONDERROOM).costs(2, :GREENSHARD),
      MoveStock.of(:MAGICROOM).costs(2, :YELLOWSHARD),
      MoveStock.of(:ROLEPLAY).costs(2, :YELLOWSHARD),
    ],
  },

  :MarvinMoves => {
    :Messages => {
      :welcome => "MARVIN: Buy Marvin's freedom!!",
      :goodbye => "MARVIN: Please pay Marvin's bail!!",
      :anything_else => "MARVIN: Buy Marvin's freedom!!",

      :no_items => "MARVIN: Marvin will be locked away forever!!",

      :purchase_confirm_single => "MARVIN: Marvin says {2}!",

      :success_items => "MARVIN: Marvin is almost free!!\nMarvin can taste it!!",
    },
    :Inventory => [
      MoveStock.of(:SUPERFANG).costs(3, :REDSHARD),
      MoveStock.of(:TRICK).costs(3, :BLUESHARD),
      MoveStock.of(:DUALCHOP).costs(3, :GREENSHARD),
      MoveStock.of(:HELPINGHAND).costs(3, :YELLOWSHARD),
      MoveStock.of(:GIGADRAIN).costs(3, :YELLOWSHARD),
      MoveStock.of(:SYNTHESIS).costs(3, :GREENSHARD),
      MoveStock.of(:MAGNETRISE).costs(3, :BLUESHARD),
      MoveStock.of(:UPROAR).costs(3, :REDSHARD),
      MoveStock.of(:TELEKINESIS).costs(2, :GREENSHARD),
    ],
  },

  :MarnieMoves => {
    :Messages => {
      :welcome => "MARNIE: Ya interestde? Interested*.",
      :goodbye => "MARNIE: Buy! Bye!*",
      :anything_else => "MARNIE: Ya interestde? Interested*.",

      :no_items => "MARNIE: You don't have enough!\nI hate poor people!*",

      :success_items => "MARNIE: Yay! I'm so happy!\nYou can leave now.*",
    },
    :Inventory => [
      MoveStock.of(:BUGBITE).costs(3, :GREENSHARD).properties(
        purchase_confirm_single: "MARNIE: 1 Geen Sahrd! {3}!*",
      ),
      MoveStock.of(:BOUNCE).costs(3, :BLUESHARD).properties(
        purchase_confirm_single: "MARNIE: 1 Blue Sahrd! {3}!*",
      ),
      MoveStock.of(:DRILLRUN).costs(3, :YELLOWSHARD).properties(
        purchase_confirm_single: "MARNIE: 1 Ylw Sahrd! {3}!*",
      ),
      MoveStock.of(:ELECTROWEB).costs(3, :REDSHARD).properties(
        purchase_confirm_single: "MARNIE: 1 Rad Sahrd! {3}!*",
      ),
      MoveStock.of(:GASTROACID).costs(3, :YELLOWSHARD).properties(
        purchase_confirm_single: "MARNIE: 1 Ylw Sahrd! {3}!*",
      ),
      MoveStock.of(:FOCUSENERGY).costs(3, :REDSHARD).properties(
        purchase_confirm_single: "MARNIE: 1 Rad Sahrd! {3}!*",
      ),
      MoveStock.of(:SKILLSWAP).costs(3, :BLUESHARD).properties(
        purchase_confirm_single: "MARNIE: 1 Blue Sahrd! {3}!*",
      ),
      MoveStock.of(:SIGNALBEAM).costs(3, :GREENSHARD).properties(
        purchase_confirm_single: "MARNIE: 1 Geen Sahrd! {3}!*",
      ),
      MoveStock.of(:COACHING).costs(3, :REDSHARD).properties(
        purchase_confirm_single: "MARNIE: 1 Rad Sahrd! {3}!*",
      ),
    ],
  },

  :MarlowMoves => {
    :Messages => {
      :welcome => "MARLOW: Please buy them, my family is dying a horrible slow death.",
      :goodbye => "MARLOW: Bokay...",
      :anything_else => "MARLOW: Please buy them, my family is dying a horrible slow death.",

      :no_items => "MARLOW: Friend! You don't have enough!",

      :purchase_confirm_single => "MARLOW: That'll be {2}, please!",

      :success_items => "MARLOW: I'm hungry...\nThanks!",
    },
    :Inventory => [
      MoveStock.of(:AQUATAIL).costs(3, :BLUESHARD),
      MoveStock.of(:LASERFOCUS).costs(2, :REDSHARD),
      MoveStock.of(:REVERSAL).costs(3, :GREENSHARD),
      MoveStock.of(:ENDURE).costs(4, :GREENSHARD),
      MoveStock.of(:GRAVITY).costs(2, :GREENSHARD),
      MoveStock.of(:AMNESIA).costs(4, :BLUESHARD),
      MoveStock.of(:ELECTROBALL).costs(2, :YELLOWSHARD),
      MoveStock.of(:ALLYSWITCH).costs(5, :REDSHARD),
      MoveStock.of(:HYPERVOICE).costs(3, :BLUESHARD),
    ],
  },

  :MarleyMoves => {
    :Messages => {
      :welcome => "MARLEY: You buy something?",
      :goodbye => "MARLEY: See you later...",
      :anything_else => "MARLEY: You buy something?",

      :no_items => "MARLEY: Not enough... Shards...",

      :purchase_confirm_single => "MARLEY: Remember to recycle...\n{3}...",

      :success_items => "MARLEY: Thank you for thy patronage.",
    },
    :Inventory => [
      MoveStock.of(:SKYATTACK).costs(4, :GREENSHARD),
      MoveStock.of(:ICYWIND).costs(3, :REDSHARD),
      MoveStock.of(:TAILWIND).costs(5, :YELLOWSHARD),
      MoveStock.of(:BATONPASS).costs(5, :BLUESHARD),
      MoveStock.of(:ENCORE).costs(4, :REDSHARD),
      MoveStock.of(:HIGHHORSEPOWER).costs(3, :GREENSHARD),
      MoveStock.of(:AGILITY).costs(3, :BLUESHARD),
      MoveStock.of(:CRUNCH).costs(3, :YELLOWSHARD),
      MoveStock.of(:BLAZEKICK).costs(3, :REDSHARD),
    ],
  },

  :MacbethMoves => {
    :Messages => {
      :welcome => "<fn=Garufan>MACBETH: ABRACADABRA...</fn>",
      :goodbye => "<fn=Garufan>MACBETH: HOCUS POCUS!</fn>",
      :anything_else => "<fn=Garufan>MACBETH: ABRACADABRA...</fn>",

      :no_items => "<fn=Garufan>MACBETH: DIE!</fn>",

      :purchase_confirm_single => "<fn=Garufan>MACBETH: ALAKAZAM! {2}!</fn> ({2}.)",

      :success_items => "<fn=Garufan>MACBETH: GOOD FORTUNE UPON YOU!.</fn>",
    },
    :Inventory => [
      MoveStock.of(:COSMICPOWER).costs(5, :YELLOWSHARD),
      MoveStock.of(:LEAFBLADE).costs(3, :GREENSHARD),
      MoveStock.of(:AURASPHERE).costs(4, :REDSHARD),
      MoveStock.of(:HEAVYSLAM).costs(4, :BLUESHARD),
      MoveStock.of(:HEATCRASH).costs(4, :REDSHARD),
      MoveStock.of(:GUNKSHOT).costs(5, :GREENSHARD),
      MoveStock.of(:POLLENPUFF).costs(4, :GREENSHARD),
      MoveStock.of(:TERRAINPULSE).costs(4, :YELLOWSHARD),
      MoveStock.of(:RAGEFIST).costs(6, :YELLOWSHARD),
    ],
  },

  :CoinShop => {
    :Messages => {
      :welcome => "Would you like to buy some coins?",
      :goodbye => "Enjoy the games!",
      :anything_else => "Which prize would you like?",

      :no_money => "I'm afraid you don't have the cash. Please come back soon!",

      :purchase_confirm_single => "So, you want the {1}?",

      :success_money => "Thank you very much!",
    },
    :Inventory => [
      CurrencyStock.of(:Coins, 50).costs(1000),
      CurrencyStock.of(:Coins, 500).costs(10000),
    ],
  },

  :CoinTMs => {
    :Messages => {
      :welcome => "We exchange your coins for prizes.\nWhich prize would you like?",
      :anything_else => "Which prize would you like?",

      :no_coins => "Sorry, you'll need more coins than that.",

      :purchase_confirm_single => "So, you want the {1}?",
    },
    :Inventory => [
      ItemStock.of(:TM70).costs(1000, :Coins),
      ItemStock.of(:TM10).costs(5000, :Coins),
      ItemStock.of(:TM150).costs(2000, :Coins).properties(
        display_name: "TM150 Grass Terrain",
        conditions: [
          '$Trainer.numbadges >= 10',
        ],
      ),
      ItemStock.of(:TM151).costs(2000, :Coins).properties(
        display_name: "TM151 Elec. Terrain",
        conditions: [
          '$Trainer.numbadges >= 10',
        ],
      ),
      ItemStock.of(:TM152).costs(2000, :Coins).properties(
        conditions: [
          '$Trainer.numbadges >= 10',
        ],
      ),
      ItemStock.of(:TM153).costs(2000, :Coins).properties(
        display_name: "TM153 Psy. Terrain",
        conditions: [
          '$Trainer.numbadges >= 10',
        ],
      ),
    ],
  },

  :ChrisolaPokemon => {
    :Messages => {
      :welcome => "We exchange your coins for prizes.\nWhich prize would you like?",
      :anything_else => "Which prize would you like?",

      :no_coins => "Sorry, you'll need more coins than that.",

      :purchase_confirm_single => "So, you want the {1}?",
    },
    :Inventory => [
      PokemonStock.of({ species: :SEEL, moves: [:STOCKPILE], originalTrainer: "Blakeory Co." }).costs(1000, :Coins),
      PokemonStock.of({ species: :SPOINK, moves: [:FUTURESIGHT], originalTrainer: "Blakeory Co." }).costs(4000, :Coins),
      PokemonStock.of({ species: :MARACTUS, moves: [:SPIKES], originalTrainer: "Blakeory Co." }).costs(5000, :Coins),
      PokemonStock.of({ species: :HELIOPTILE, moves: [:GLARE], originalTrainer: "Blakeory Co." }).costs(6500, :Coins),
    ],
  },

  :CairoShop => {
    :Messages => {
      :welcome => "CAIRO: Well met. I see you made it to my humble abode.",
      :goodbye => "",
      :anything_else => "",
    },
    :Inventory => {
      "Scents Shop" => :CairoScents,
      "Red Essence Shop" => :CairoRE,
      "Fragment Shop" => :CairoFragments,
    },
    :hasPicture => true,
    :clampBottom => true,
  },

  :CairoScents => {
    :Messages => {
      :welcome => "CAIRO: Very well. I only sell in bulks of 10.",
      :goodbye => "CAIRO: Fine.",

      :no_money => "CAIRO: No money.",

      :choose_quantity => "CAIRO: How many?",
      :purchase_confirm_multiple => "CAIRO: {2}? You're sure?",

      :success_money => "CAIRO: Here.",
    },
    :Inventory => [
      ItemStock.of(:JOYSCENT, 10).costs(5000),
      ItemStock.of(:EXCITESCENT, 10).costs(8500),
      ItemStock.of(:VIVIDSCENT, 10).costs(11000),
    ],
    :hasPicture => true,
    :clampBottom => true,
  },

  :CairoRE => {
    :Messages => {
      :welcome => "CAIRO: I see that you have Red Essence.\nLet's see what we got.",
      :goodbye => "CAIRO: Hmph.",
      :nothing_to_buy => "CAIRO: You've cleared me out. Good.\nKeep on doing what you're doing.",

      :no_re => "CAIRO: Not enough! I can't do anything with this amount.",

      :purchase_confirm_single => "CAIRO: Very well, that will be {3}.",

      :success_re => "CAIRO: You've earned it.",
    },
    :Inventory => [
      ItemStock.of(:BIKEV).costs(250, :RedEssence).limit().properties(
        conditions: [
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:NOCCREST).costs(2000, :RedEssence).limit().properties(
        conditions: [
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:MINUNCREST).costs(2000, :RedEssence).limit().properties(
        conditions: [
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:PLUSLECREST).costs(2000, :RedEssence).limit().properties(
        conditions: [
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:SAGECREST).costs(2000, :RedEssence).limit().properties(
        conditions: [
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:SEARCREST).costs(2000, :RedEssence).limit().properties(
        conditions: [
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:POURCREST).costs(2000, :RedEssence).limit().properties(
        conditions: [
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:LUXCREST).costs(5000, :RedEssence).limit().properties(
        conditions: [
          '$Trainer.numbadges >= 8',
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:DRUDDICREST).costs(5000, :RedEssence).limit().properties(
        conditions: [
          '$Trainer.numbadges >= 8',
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:THIEVCREST).costs(5000, :RedEssence).limit().properties(
        conditions: [
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:SAMUCREST).costs(5000, :RedEssence).limit().properties(
        conditions: [
          '$Trainer.numbadges >= 8',
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:BOLTCREST).costs(9000, :RedEssence).limit().properties(
        conditions: [
          '$Trainer.numbadges >= 13',
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:PROBOCREST).costs(9000, :RedEssence).limit().properties(
        conditions: [
          '$Trainer.numbadges >= 13',
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:SWACREST).costs(9000, :RedEssence).limit().properties(
        conditions: [
          '$Trainer.numbadges >= 13',
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:CINCCREST).costs(9000, :RedEssence).limit().properties(
        conditions: [
          '$Trainer.numbadges >= 13',
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:DELCREST).costs(14000, :RedEssence).limit().properties(
        conditions: [
          '$Trainer.numbadges >= 15',
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
    ],
    :hasPicture => true,
    :clampBottom => true,
  },

  :CairoFragments => {
    :Messages => {
      :welcome => "CAIRO: Very well. I sell these in bulk too.",
      :goodbye => "CAIRO: Fine.",

      :no_money => "CAIRO: No money.",

      :choose_quantity => "CAIRO: How many?",
      :purchase_confirm_multiple => "CAIRO: {2}? You're sure?",

      :success_money => "CAIRO: Here.",
    },
    :Inventory => [
      ItemStock.of(:RIFTFRAGMENT, 5).costs(4956),
      ItemStock.of(:RIFTFRAGMENT, 15).costs(14868),
      ItemStock.of(:RIFTFRAGMENT, 25).costs(24780),
    ],
    :hasPicture => true,
    :clampBottom => true,
  },

  :AkuwaYEAH => {
    :Messages => {
      :welcome => "LET'S GET SCHMOOVIN'!",
      :goodbye => "COME AGAIN! P-please...",
      :anything_else => "LET'S GET SCHMOOVIN'!",

      :no_items => "OH NO!",

      :success_items => "OH YEAH! THANKS!",
    },
    :Inventory => [
      MoveStock.of(:STOMPINGTANTRUM).costs(4, :REDSHARD).properties(purchase_confirm_single: "STOMPY? 4 R-Red shards, p-please...\nD-don't be mad..."),
      MoveStock.of(:IRONTAIL).costs(4, :BLUESHARD).properties(purchase_confirm_single: "IYUNTAIL? 4 B-Blue shards, p-please...\nD-don't be mad..."),
      MoveStock.of(:ENDEAVOR).costs(3, :GREENSHARD).properties(purchase_confirm_single: "DEVA? 3 G-Green shards, p-please...\nD-don't be mad..."),
      MoveStock.of(:IRONDEFENSE).costs(3, :YELLOWSHARD).properties(purchase_confirm_single: "DOFFENSE? 3 Y-Yellow shards, p-please...\nD-don't be mad..."),
      MoveStock.of(:LASHOUT).costs(4, :BLUESHARD).properties(purchase_confirm_single: "LA SHIT? 3 B-Blue shards, p-please...\nD-don't be mad..."),
      MoveStock.of(:REVENGE).costs(3, :REDSHARD).properties(purchase_confirm_single: "REVONGE?? 3 R-Red shards, p-please...\nD-don't be mad..."),
      MoveStock.of(:PETALBLIZZARD).costs(3, :GREENSHARD).properties(purchase_confirm_single: "BLIZZY? 3 G-Green shards, p-please...\nD-don't be mad..."),
      MoveStock.of(:CORROSIVEGAS).costs(3, :YELLOWSHARD).properties(purchase_confirm_single: "GASSY? 3 Y-Yellow shards, p-please...\nD-don't be mad..."),
    ],
  },

  :AkuwaShock => {
    :Messages => {
      :welcome => "So? What do you want it to be?",
      :goodbye => "Come again!",
      :anything_else => "So? What do you want it to be?",

      :no_items => "Sorry, but you don't have enough shards.",

      :purchase_confirm_single => "{1}? That'll be {3}.",

      :success_items => "Thanks a million!",
    },
    :Inventory => [
      MoveStock.of(:FIREPUNCH).costs(3, :REDSHARD),
      MoveStock.of(:ICEPUNCH).costs(3, :BLUESHARD),
      MoveStock.of(:THUNDERPUNCH).costs(3, :YELLOWSHARD),
      MoveStock.of(:HEALBELL).costs(2, :GREENSHARD),
      MoveStock.of(:CHARGE).costs(2, :YELLOWSHARD),
      MoveStock.of(:SKITTERSMACK).costs(3, :GREENSHARD),
      MoveStock.of(:HARDPRESS).costs(3, :YELLOWSHARD),
    ],
  },

  :ACDMCFossils => {
    :Messages => {
      :welcome => "So? What'll it be?",
      :goodbye => "Come again!",
      :anything_else => "So? What'll it be?",

      :no_items => "I'm very sorry, but you don't have enough shards...\nOur stock isn't very high, so in turn we have to increase prices. Please understand.",

      :success_items => "Thank you for your patronage! You can revive your fossils at the counter adjacent to this one.",
    },
    :Inventory => [
      ItemStock.of(:SAILFOSSIL).costs(3, :BLUESHARD).properties(
        purchase_confirm_single: "So the {1} is your choice? That contains the Pokémon Amaura. That'll be {3}.",
      ),
      ItemStock.of(:JAWFOSSIL).costs(3, :REDSHARD).properties(
        purchase_confirm_single: "So the {1} is your choice? That contains the Pokémon Tyrunt. That'll be {3}.",
      ),
      ItemStock.of(:SKULLFOSSIL).costs(3, :GREENSHARD).properties(
        purchase_confirm_single: "So the {1} is your choice? That contains the Pokémon Shieldon. That'll be {3}.",
      ),
      ItemStock.of(:ARMORFOSSIL).costs(3, :YELLOWSHARD).properties(
        purchase_confirm_single: "So the {1} is your choice? That contains the Pokémon Cranidos. That'll be {3}.",
      ),
    ],
  },

  :ACDMCDealer => {
    :Messages => {
      :welcome => "These fossils aren't exactly... legal. So?",
      :goodbye => "Yeah, yeah.",
      :anything_else => "Want anything else?",

      :no_items => "You don't have enough, man...",

      :success_items => "Hah, thanks! Come back any time...",
    },
    :Inventory => [
      ItemStock.of(:FOSSILIZEDDINO).costs(10, :REDSHARD).properties(
        purchase_confirm_single: "So the {1} is your choice? That'll be {3}.",
      ),
      ItemStock.of(:FOSSILIZEDFISH).costs(10, :GREENSHARD).properties(
        purchase_confirm_single: "So the {1} is your choice? That'll be {3}.",
      ),
      ItemStock.of(:FOSSILIZEDBIRD).costs(10, :YELLOWSHARD).properties(
        purchase_confirm_single: "So the {1} is your choice? That'll be {3}.",
      ),
    ],
  },

  :GDCArcadePokemon => {
    :Messages => {
      :welcome => "We exchange your coins for prizes.\nWhich prize would you like?",
      :anything_else => "Which prize would you like?",

      :no_coins => "Sorry, you'll need more coins than that.",

      :purchase_confirm_single => "So, you want the {1}?",
    },
    :Inventory => [
      PokemonStock.of({ species: :ROOKIDEE, originalTrainer: "Blakeory Co." }).costs(3000, :Coins),
      PokemonStock.of({ species: :MIENFOO, moves: [:KNOCKOFF], originalTrainer: "Blakeory Co." }).costs(4000, :Coins),
      PokemonStock.of({ species: :DURANT, moves: [:BATONPASS], originalTrainer: "Blakeory Co." }).costs(7500, :Coins),
      PokemonStock.of({ species: :AXEW, moves: [:NIGHTSLASH], originalTrainer: "Blakeory Co." }).costs(9000, :Coins),
    ],
  },

  :KristilineTMs => {
    :Messages => {},
    :Inventory => [
      ItemStock.of(:RM01).costs(75000).properties(
        conditions: [
          '$Trainer.numbadges >= 12',
        ],
      ),
      ItemStock.of(:RM02).costs(20000),
      ItemStock.of(:RM03).costs(30000),
      ItemStock.of(:RM04).costs(10000),
      ItemStock.of(:RM05).costs(50000).properties(
        conditions: [
          '$Trainer.numbadges >= 12',
        ],
      ),
      ItemStock.of(:RM06).costs(15000),
      ItemStock.of(:RM07).costs(25000),
      ItemStock.of(:RM08).costs(20000),
      ItemStock.of(:RM09).costs(20000),
      ItemStock.of(:TM116).costs(75000).properties(
        conditions: [
          '$Trainer.numbadges >= 12',
        ],
      ),
      ItemStock.of(:TM125).costs(15000).properties(
        conditions: [
          '$Trainer.numbadges >= 12',
        ],
      ),

      ItemStock.of(:TM143).costs(25000),
      ItemStock.of(:TM155).costs(15000).properties(
        conditions: [
          '$Trainer.numbadges >= 12',
        ],
      ),
      ItemStock.of(:TM157).costs(25000),
    ],
  },

  :Goome => {
    :Messages => {
      :welcome => "WeLcOMe GOOM!!",
      :goodbye => "Goom-goom!!!",
      :anything_else => "AnYtHing ElsE?? Goom!!",

      :no_items => "No MoNeY GoOm!!!",
      :nothing_to_buy => "No MoRe GoOm!!!",

      :purchase_confirm_single => "Give Goome {2}?",

      :success_money => "Yay! Goom!!!",
    },
    :Inventory => [
      ItemStock.of(:BASTCREST).costs(100000).limit().properties(
        conditions: [
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:RAMPCREST).costs(100000).limit().properties(
        conditions: [
          '!$game_switches[self.item]',
        ],
        on_purchase: [
          '$game_switches[item.item] = true',
        ],
      ),
      ItemStock.of(:FAIRIUMZ).costs(100000).limit().properties(
        conditions: [
          '!searchItem(self.item)',
        ],
      ),
      ItemStock.of(:DRAGALGITE).costs(100000).limit().properties(
        conditions: [
          '!searchItem(self.item)',
        ],
      ),
      ItemStock.of(:DRAMPANITE).costs(100000).limit().properties(
        conditions: [
          '!searchItem(self.item)',
        ],
      ),
      ItemStock.of(:DRAGONIUMZ).costs(100000).limit().properties(
        conditions: [
          '!searchItem(self.item)',
        ],
      ),
      ItemStock.of(:STEELIUMZ).costs(100000).limit().properties(
        conditions: [
          '!searchItem(self.item)',
        ],
      ),
    ],
  },

  :Goombina => {
    :Messages => {
      :welcome => "GOOMBINA: HI!!!",
      :goodbye => "GOOMBINA: GoooOOOOM!!!\nYoU arE noOoooT WOOOoortHY!",
      :anything_else => "",

      :no_items => "GOOMBINA: No haVe mushroOm! BegoNe!",
      :nothing_to_buy => "GOOMBINA: nO moRe SeLL!",

      :purchase_confirm_single => "Give Goombina {3}?",

      :success_items => "GOOMBINA: GoooOoooOOOO!",
    },
    :Inventory => [
      MoveStock.of(:DRACOMETEOR).costs(1, :BALMMUSHROOM).properties(
        display_name: "GOoMy mEtEOr", icon: "Graphics/Icons/Pokemon/icon704.png", icon_rect: [12, 8, 48, 48],
        description: "It's just a note that says \"GoooOoooOOOO!\"",
      ),
    ],
  },

  :GOOMATORA => {
    :Messages => {
      :welcome => "GOOMATORA: bIiG? mUSHRoom?",
      :goodbye => "GOOMATORA: Get MOre sHROOOOoms!",
      :anything_else => "GOOMATORA: bIiG? mUSHRoom?",

      :no_items => "GOOMATORA: NOOOO!",
      :nothing_to_buy => "GOOMATORA: GoOM oUt Of sTOcK!",

      :purchase_confirm_single => "Give GOOMATORA {3}?",

      :success_items => "GOOMATORA: GOOOOOM!",
    },
    :Inventory => [
      MoveStock.of(:BODYSLAM).costs(2, :BIGMUSHROOM),
      MoveStock.of(:SEEDBOMB).costs(2, :BIGMUSHROOM),
      MoveStock.of(:DRAGONPULSE).costs(3, :BIGMUSHROOM),
      MoveStock.of(:MEGAHORN).costs(3, :BIGMUSHROOM),
      MoveStock.of(:STEALTHROCK).costs(4, :BIGMUSHROOM),
      MoveStock.of(:SPIKES).costs(3, :BIGMUSHROOM),
      MoveStock.of(:TOXICSPIKES).costs(4, :BIGMUSHROOM),
      MoveStock.of(:SCORCHINGSANDS).costs(3, :BIGMUSHROOM),
      MoveStock.of(:ZENHEADBUTT).costs(2, :BIGMUSHROOM),
      MoveStock.of(:LIQUIDATION).costs(3, :BIGMUSHROOM),
      MoveStock.of(:MUDDYWATER).costs(2, :BIGMUSHROOM),
      MoveStock.of(:DEFOG).costs(1, :BIGMUSHROOM),
      MoveStock.of(:ICESPINNER).costs(2, :BIGMUSHROOM),
      MoveStock.of(:BODYPRESS).costs(5, :BIGMUSHROOM),
      MoveStock.of(:STOREDPOWER).costs(5, :BIGMUSHROOM),
      MoveStock.of(:BURNINGJEALOUSY).costs(4, :BIGMUSHROOM),
    ],
  },

  :FestivalPledges => {
    :Messages => {
      :welcome => "So? What'll it be?",
      :goodbye => "Come again!",
      :anything_else => "So? What will it be?",

      :no_items => "Sorry, but you don't have enough shards.",

      :success_items => "Thank you, thank you!",
    },
    :Inventory => [
      MoveStock.of(:FIREPLEDGE).costs(3, :REDSHARD).properties(purchase_confirm_single: "{1}? Honorable. {3}"),
      MoveStock.of(:WATERPLEDGE).costs(3, :BLUESHARD).properties(purchase_confirm_single: "{1}? How noble... {3}"),
      MoveStock.of(:GRASSPLEDGE).costs(3, :GREENSHARD).properties(purchase_confirm_single: "{1}? How... eh. Anyway,\n{3}"),
    ],
  },

  :FestivalBlackHair => {
    :Messages => {
      :welcome => "What will it be?",
      :goodbye => "Come again!",
      :anything_else => "What will it be?",

      :no_items => "Sorry, but you don't have enough shards.",

      :purchase_confirm_single => "{1}? That'll be {3}.",

      :success_items => "Thank you for your patronage!",
    },
    :Inventory => [
      MoveStock.of(:SUPERPOWER).costs(5, :YELLOWSHARD),
      MoveStock.of(:HEATWAVE).costs(5, :BLUESHARD),
      MoveStock.of(:FUTURESIGHT).costs(4, :REDSHARD),
      MoveStock.of(:FLIPTURN).costs(5, :GREENSHARD),
      MoveStock.of(:ALLURINGVOICE).costs(5, :YELLOWSHARD),
    ],
  },

  :FestivalGamer => {
    :Messages => {
      :welcome => "Which one will it be, gamer??",
      :goodbye => "Come again!",
      :anything_else => "Which one will it be, gamer??",

      :no_items => "Sorry, but you don't have enough shards.",

      :purchase_confirm_single => "{1}? That's a weird decision.\n{3}.",

      :success_items => "Obliged!",
    },
    :Inventory => [
      MoveStock.of(:EARTHPOWER).costs(6, :BLUESHARD),
      MoveStock.of(:FOCUSPUNCH).costs(5, :REDSHARD),
      MoveStock.of(:DRAINPUNCH).costs(6, :YELLOWSHARD),
      MoveStock.of(:PAINSPLIT).costs(4, :BLUESHARD),
      MoveStock.of(:MISTYEXPLOSION).costs(7, :REDSHARD),
      MoveStock.of(:SUPERCELLSLAM).costs(5, :REDSHARD),
      MoveStock.of(:PSYCHICNOISE).costs(6, :YELLOWSHARD),
    ],
  },

  :HiyoshiTutor => {
    :Messages => {
      :welcome => "What'll it be?",
      :goodbye => "Come again!",
      :anything_else => "What'll it be?",

      :no_items => "Sorry, but you don't have enough shards.",

      :purchase_confirm_single => "{1}? That'll be {3}.",

      :success_items => "Thank you!",
    },
    :Inventory => [
      MoveStock.of(:SKYATTACK).costs(3, :REDSHARD).properties(purchase_confirm_single: "{1}? Powerful stuff, but risky. That'll be {3}."),
      MoveStock.of(:SKILLSWAP).costs(2, :GREENSHARD).properties(purchase_confirm_single: "If we're talking a game of skill, trainers with this are the top brass.\nWe're talking {3} for it."),
      MoveStock.of(:MAGNETRISE).costs(2, :YELLOWSHARD).properties(purchase_confirm_single: "A hop, skip, and a magnet away from rising to the top!\n{3} please!"),
      MoveStock.of(:GRAVITY).costs(2, :BLUESHARD).properties(purchase_confirm_single: "Dire situations have gravitas, and with this move, so will the battle!\n{3}!"),
      MoveStock.of(:RECYCLE).costs(2, :GREENSHARD).properties(purchase_confirm_single: "The mayor's been on about the 3 R's a lot, but I'm all\nabout Recycling in battle! Gotta keep those items,\nyeah?\n{3}!"),
    ],
  },

  :CorsolaChop => {
    :Messages => {
      :welcome => "...???",
      :goodbye => "",
      :anything_else => "...???",

      :no_items => "CORSOLA: CORSA!!! (NOT ENOUGH!)",

      :purchase_confirm_single => "CORSOLA: Corsa! ({3}.)",

      :success_items => "CORSOLA: C-Corsa! (Thank you!)",
    },
    :Inventory => [
      MoveStock.of(:THROATCHOP).costs(4, :REDSHARD),
    ],
  },

  :NeoGearenTutorF => {
    :Messages => {
      :welcome => "Anything you need? Anything at all?",
      :goodbye => "Come again!",
      :anything_else => "Anything you need? Anything at all?",

      :no_items => "Sorry, but you don't have enough shards.",

      :purchase_confirm_single => "{1} will be {3}.",

      :success_items => "Thank you for your patronage!",
    },
    :Inventory => [
      MoveStock.of(:IRONHEAD).costs(3, :REDSHARD),
      MoveStock.of(:FOULPLAY).costs(3, :BLUESHARD),
      MoveStock.of(:KNOCKOFF).costs(3, :GREENSHARD),
      MoveStock.of(:PSYCHICFANGS).costs(2, :GREENSHARD),
      MoveStock.of(:DUALWINGBEAT).costs(2, :BLUESHARD),
      MoveStock.of(:TEMPERFLARE).costs(2, :REDSHARD),
      MoveStock.of(:FLAREBLITZ).costs(4, :REDSHARD),
      MoveStock.of(:BRAVEBIRD).costs(4, :BLUESHARD),
      MoveStock.of(:POLTERGEIST).costs(4, :YELLOWSHARD),
      MoveStock.of(:BUGBUZZ).costs(4, :GREENSHARD),
    ],
  },

  :NeoGearenDying => {
    :Messages => {
      :welcome => "I need to live!",
      :goodbye => "I'm going to die...",
      :anything_else => "I need to live!",

      :no_items => "I... can't go on like this...",

      :purchase_confirm_single => "{1} is very strong! {3}.",

      :success_items => "Thanks for the meal!",
    },
    :Inventory => [
      MoveStock.of(:LASTRESORT).costs(2, :YELLOWSHARD),
      MoveStock.of(:OUTRAGE).costs(5, :GREENSHARD),
      MoveStock.of(:LOWKICK).costs(3, :BLUESHARD),
      MoveStock.of(:STEELROLLER).costs(4, :YELLOWSHARD),
      MoveStock.of(:POWERGEM).costs(4, :REDSHARD),
    ],
  },

  :ShaydaShop => {
    :Messages => {
      :welcome => "SHAYDA: Welcome to the dark... How may I help you?",
      :goodbye => "SHAYDA: So long, farewell. Adieu to you, and you...",
      :anything_else => "SHAYDA: Very well...",

      :no_items => "SHAYDA: Oh my... It seems you don't have enough.",

      :purchase_confirm_single => "SHAYDA: Thank you for the taste of defeat...",

      :success_items => "SHAYDA: Ah... the fresh taste of bitter dusk...",
    },
    :Inventory => [
      ItemStock.of(:BLKPRISM, 10).costs(1, :UMBRALSHARD),
      ItemStock.of(:TM26).costs(1, :UMBRALSHARD),
      ItemStock.of(:TM24).costs(1, :UMBRALSHARD),
      ItemStock.of(:TM13).costs(1, :UMBRALSHARD),
      ItemStock.of(:LEFTOVERS).costs(1, :UMBRALSHARD),
      ItemStock.of(:LIFEORB).costs(1, :UMBRALSHARD),
      ItemStock.of(:TOXICORB).costs(1, :UMBRALSHARD),
      ItemStock.of(:FLAMEORB).costs(1, :UMBRALSHARD),
      ItemStock.of(:DUBIOUSDISC).costs(1, :UMBRALSHARD),
      ItemStock.of(:LOADEDDICE).costs(1, :UMBRALSHARD),
      ItemStock.of(:AUSPICIOUSARMOR).costs(2, :UMBRALSHARD),
      ItemStock.of(:MALICIOUSARMOR).costs(2, :UMBRALSHARD),
      ItemStock.of(:EVIOLITE).costs(2, :UMBRALSHARD),
      ItemStock.of(:GIMMIGHOULCOIN,100).costs(1, :UMBRALSHARD).properties(
        display_name: "Gimmi. Coin x100"),
      ItemStock.of(:LUCARIONITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:FROSLASSITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:STARAPTITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:GARDEVOIRITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:GALLADITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:GYARADOSITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:VENUSAURITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:VENUSAURITEG).costs(3, :UMBRALSHARD),
      ItemStock.of(:CHARIZARDITEY).costs(3, :UMBRALSHARD),
      ItemStock.of(:CHARIZARDITEX).costs(3, :UMBRALSHARD),
      ItemStock.of(:CHARIZARDITEG).costs(3, :UMBRALSHARD),
      ItemStock.of(:BLASTOISINITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:BLASTOISINITEG).costs(3, :UMBRALSHARD),
      ItemStock.of(:MEGANIUMITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:FERALIGITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:SCEPTILITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:BLAZIKENITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:SWAMPERTITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:EMBOARITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:CHESNAUGHTITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:DELPHOXITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:GRENINJITE).costs(3, :UMBRALSHARD),
      ItemStock.of(:GOLDENAPPLE).costs(3, :UMBRALSHARD),
      ItemStock.of(:ENTEICREST).costs(6, :UMBRALSHARD).limit().properties(conditions: ['!searchItem(self.item) && $Unidata[:EntCrest]']),
      ItemStock.of(:SUICREST).costs(6, :UMBRALSHARD).limit().properties(conditions: ['!searchItem(self.item) && $Unidata[:SuiCrest]']),
      ItemStock.of(:RAICREST).costs(6, :UMBRALSHARD).limit().properties(conditions: ['!searchItem(self.item) && $Unidata[:RaiCrest]']),
      #ItemStock.of(:CELECREST).costs(5, :UMBRALSHARD).limit().properties(conditions: ['!searchItem(self.item) && $Unidata[:CeleCrest]']), # celebi currently unobtainable on paragon so this is commented out for now
      ItemStock.of(:GLIMMORANITEA).costs(6, :UMBRALSHARD).limit().properties(conditions: ['!searchItem(self.item) && $Unidata[:GlimmoraniteA]']),
      MoveStock.of(:RAGEFIST).costs(3, :UMBRALSHARD),
    ],
  },

  :WispyShop => {
    :Messages => {
      :welcome => "LAUREN: Ugh. Another outsider. Well, wanna take a look at what I've got?",
      :goodbye => "LAUREN: So long. Feel free not to come back.",
      :anything_else => "LAUREN: Anything else?",
      :nothing_to_buy => "LAUREN: Got nothing more to give you. You can go now.",

      :no_items => "LAUREN: You outsiders don't know math either, huh?",

      :purchase_confirm_single => "LAUREN: Just the one, right?",

      :success_items => "LAUREN: There we go.",
    },
    :Inventory => [
      MoveStock.of(:PSYBEAM).costs(5000),
      MoveStock.of(:CONFUSERAY).costs(5000),
      MoveStock.of(:METALSOUND).costs(5000),
      MoveStock.of(:METALCLAW).costs(5000),
      MoveStock.of(:POISONTAIL).costs(5000),
      MoveStock.of(:DISARMINGVOICE).costs(5000),
      ItemStock.of(:TM140).costs(5000),
      ItemStock.of(:TM141).costs(5000),
      ItemStock.of(:TM142).costs(5000),
      MoveStock.of(:AIRCUTTER).costs(2, :BLUESHARD),
      MoveStock.of(:HEADBUTT).costs(2, :GREENSHARD),
      MoveStock.of(:FIREPLEDGE).costs(3, :REDSHARD),
      MoveStock.of(:WATERPLEDGE).costs(3, :BLUESHARD),
      MoveStock.of(:GRASSPLEDGE).costs(3, :GREENSHARD),
    ],
  },

  :WispyShop1 => {
    :Messages => {
      :welcome => "LAUREN: Well, guess we're trying something new then? Let's see how it goes.",
      :goodbye => "LAUREN: Come again, I guess.",
      :anything_else => "LAUREN: Anything else?",
      :nothing_to_buy => "LAUREN: Out of anything to teach you, kid.",

      :no_items => "LAUREN: You don't have enough for that.",

      :purchase_confirm_single => "LAUREN: Just the one, right?",

      :success_items => "LAUREN: There we go.",
    },
    :Inventory => [
      MoveStock.of(:PSYBEAM).costs(500),
      MoveStock.of(:CONFUSERAY).costs(500),
      MoveStock.of(:METALSOUND).costs(500),
      MoveStock.of(:METALCLAW).costs(500),
      MoveStock.of(:POISONTAIL).costs(500),
      MoveStock.of(:DISARMINGVOICE).costs(500),
      ItemStock.of(:TM140).costs(3000),
      ItemStock.of(:TM141).costs(3000),
      ItemStock.of(:TM142).costs(3000),
      MoveStock.of(:AIRCUTTER).costs(2, :BLUESHARD),
      MoveStock.of(:HEADBUTT).costs(2, :GREENSHARD),
      MoveStock.of(:FIREPLEDGE).costs(3, :REDSHARD),
      MoveStock.of(:WATERPLEDGE).costs(3, :BLUESHARD),
      MoveStock.of(:GRASSPLEDGE).costs(3, :GREENSHARD),
    ],
  },

  :KieranShop => {
    :Messages => {},
    :Inventory => {
      "General" => :XenPattyGeneral,
      "Stat Items" => :XenPattyStats,
    },
  },

  :XenPatty => {
    :Messages => {
      :welcome => "PATTY: What can I do ya for??",
      :goodbye => "PATTY: Buh-bye! Thanks for your patronage!",
      :anything_else => "PATTY: What can I do ya for??",

      :no_money => "PATTY: How are you broke???",
    },
    :Inventory => {
      "General" => :XenPattyGeneral,
      "Balls" => :XenPattyBalls,
      "Stat Items" => :XenPattyStats,
    },
  },

  :XenPattyGarden => {
    :Messages => {
      :welcome => "PATTY: What can I do ya for??",
      :goodbye => "PATTY: Buh-bye! Thanks for your patronage!",
      :anything_else => "PATTY: What can I do ya for??",

      :no_money => "PATTY: How are you broke???",
    },
    :Inventory => {
      "General" => :XenPattyGeneral,
      "Balls (What he said)" => :XenPattyBalls,
      "Candy" => :XenPattyCandy,
      "Stat Items" => :XenPattyStats,
    },
  },

  :XenPattyStats => {
    :Messages => {
      :welcome => "",
      :goodbye => "",

      :no_money => "PATTY: How are you broke???",
    },
    :Inventory => [
        ItemStock.of(:EVBOOSTER).costs(1),
        ItemStock.of(:BOOSTERENERGY).costs(10000).properties(conditions: ['$game_switches[1931] == true']),
        ItemStock.of(:EVTUNER).costs(1),
        ItemStock.of(:ABILITYCAPSULE).costs(1),
        ItemStock.of(:PPUP).costs(1),
        ItemStock.of(:PPMAX).costs(1),
        ItemStock.of(:CELLIMPRINT).costs(1),
        ItemStock.of(:POMEGBERRY).costs(1),
        ItemStock.of(:KELPSYBERRY).costs(1),
        ItemStock.of(:QUALOTBERRY).costs(1),
        ItemStock.of(:HONDEWBERRY).costs(1),
        ItemStock.of(:GREPABERRY).costs(1),
        ItemStock.of(:TAMATOBERRY).costs(1),
        ItemStock.of(:LONELYMINT).costs(1),
        ItemStock.of(:ADAMANTMINT).costs(1),
        ItemStock.of(:BRAVEMINT).costs(1),
        ItemStock.of(:NAUGHTYMINT).costs(1),
        ItemStock.of(:BOLDMINT).costs(1),
        ItemStock.of(:IMPISHMINT).costs(1),
        ItemStock.of(:RELAXEDMINT).costs(1),
        ItemStock.of(:LAXMINT).costs(1),
        ItemStock.of(:MODESTMINT).costs(1),
        ItemStock.of(:QUIETMINT).costs(1),
        ItemStock.of(:RASHMINT).costs(1),
        ItemStock.of(:MILDMINT).costs(1),
        ItemStock.of(:CAREFULMINT).costs(1),
        ItemStock.of(:SASSYMINT).costs(1),
        ItemStock.of(:CALMMINT).costs(1),
        ItemStock.of(:GENTLEMINT).costs(1),
        ItemStock.of(:TIMIDMINT).costs(1),
        ItemStock.of(:HASTYMINT).costs(1),
        ItemStock.of(:NAIVEMINT).costs(1),
        ItemStock.of(:JOLLYMINT).costs(1),
        ItemStock.of(:SERIOUSMINT).costs(1),
      ],
  },


  :XenPattyGeneral => {
    :Messages => {
      :welcome => "",
      :goodbye => "",

      :no_money => "PATTY: How are you broke???",
    },
    :Inventory => [
      ItemStock.of(:ULTRAPOTION),
      ItemStock.of(:REVIVE),
      ItemStock.of(:FULLHEAL),
      ItemStock.of(:FULLRESTORE),
      ItemStock.of(:MAXPOTION),
      ItemStock.of(:CELLBATTERY),
      ItemStock.of(:HEARTSCALE),
    ],
  },

  :XenPattyBalls => {
    :Messages => {
      :welcome => "",
      :goodbye => "",

      :no_money => "PATTY: How are you broke???",
    },
    :Inventory => [
      ItemStock.of(:POKEBALL),
      ItemStock.of(:GREATBALL),
      ItemStock.of(:ULTRABALL),
      ItemStock.of(:QUICKBALL),
      ItemStock.of(:DUSKBALL),
      ItemStock.of(:TIMERBALL),
      ItemStock.of(:LUXURYBALL),
    ],
  },

  :XenPattyCandy => {
    :Messages => {
      :welcome => "",
      :goodbye => "",

      :no_money => "PATTY: How are you broke???",
    },
    :Inventory => [
      ItemStock.of(:EXPCANDYXS),
      ItemStock.of(:EXPCANDYS),
      ItemStock.of(:EXPCANDYM),
      ItemStock.of(:EXPCANDYL),
      ItemStock.of(:EXPCANDYXL),
    ],
  },

  :PurgatoriumPatty => {
    :Messages => {
      :welcome => "PATTY: What can I do ya for??",
      :goodbye => "PATTY: Buh-bye! Thanks for your patronage!",
      :anything_else => "PATTY: What can I do ya for??",

      :no_money => "PATTY: How are you broke???",
    },
    :Inventory => {
      "General" => [
        ItemStock.of(:POKEBALL),
        ItemStock.of(:GREATBALL),
        ItemStock.of(:ULTRABALL),
        ItemStock.of(:LUXURYBALL),
        ItemStock.of(:QUICKBALL),
        ItemStock.of(:TIMERBALL),
        ItemStock.of(:ULTRAPOTION),
        ItemStock.of(:MAXPOTION),
        ItemStock.of(:FULLRESTORE),
        ItemStock.of(:REVIVE),
        ItemStock.of(:FULLHEAL),
        ItemStock.of(:CELLBATTERY),
        ItemStock.of(:HEARTSCALE),
        ItemStock.of(:EXPCANDYS),
        ItemStock.of(:EXPCANDYM),
        ItemStock.of(:EXPCANDYL),
        ItemStock.of(:EXPCANDYXL),
      ],
      "Battle Items" => [
        ItemStock.of(:CHOICESPECS, 1).costs(10000).limit().properties(conditions: ['$game_switches[2181] == false'],
          on_purchase: [
            '$game_switches[2181] = true',
          ]),
        ItemStock.of(:CHOICEBAND, 1).costs(10000).limit().properties(conditions: ['$game_switches[2182] == false'],
          on_purchase: [
            '$game_switches[2182] = true',
          ]),
        ItemStock.of(:CHOICESCARF, 1).costs(10000).limit().properties(conditions: ['$game_switches[2183] == false'],
          on_purchase: [
            '$game_switches[2183] = true',
        ]),
        ItemStock.of(:ASSAULTVEST, 1).costs(10000).limit().properties(conditions: ['$game_switches[2190] == false'],
          on_purchase: [
            '$game_switches[2190] = true',
        ]),
        ItemStock.of(:LIFEORB, 1).costs(10000).limit().properties(conditions: ['$game_switches[2191] == false'],
          on_purchase: [
            '$game_switches[2191] = true',
        ]),
        ItemStock.of(:LEFTOVERS, 1).costs(10000).limit().properties(conditions: ['$game_switches[2212] == false'],
          on_purchase: [
            '$game_switches[2212] = true',
        ]),
        ItemStock.of(:LOADEDDICE, 1).costs(10000),
        ItemStock.of(:ROCKYHELMET, 1).costs(10000),
        ItemStock.of(:LUMBERRY, 1),
        ItemStock.of(:WHITEHERB, 1),
        ItemStock.of(:POWERHERB, 1),
        ItemStock.of(:MENTALHERB, 1),
        ItemStock.of(:ROOMSERVICE, 1),
        ItemStock.of(:ELEMENTALSEED, 1),
        ItemStock.of(:MAGICALSEED, 1),
        ItemStock.of(:TELLURICSEED, 1),
        ItemStock.of(:SYNTHETICSEED, 1),
      ],
      "Mega Stones" => [
        ItemStock.of(:DRAGONINITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:GARCHOMPITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:GARDEVOIRITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:SCIZORITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:GENGARITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:TYRANITARITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:DURALUDONITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:COALOSSALITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:CHARIZARDITEX, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:CHARIZARDITEY, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:DRAGALGITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:DRAMPANITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:GOLURKITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:FERALIGITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:CHARIZARDITEG, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:GYARADOSITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:GENGARITEG, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:CHESNAUGHTITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:GRENINJITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:DELPHOXITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:BLAZIKENITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:GALLADITE, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),
        ItemStock.of(:SILVCREST, 1).costs(10000).properties(conditions: ['!searchItem(self.item) && $game_variables[912] > 90']),
      ],
      "Stat Items" => [
        ItemStock.of(:EVBOOSTER).costs(1),
        ItemStock.of(:BOOSTERENERGY).costs(10000).properties(conditions: ['$game_switches[1931] == true']),
        ItemStock.of(:EVTUNER).costs(1),
        ItemStock.of(:ABILITYCAPSULE).costs(1),
        ItemStock.of(:PPUP).costs(1),
        ItemStock.of(:PPMAX).costs(1),
        ItemStock.of(:CELLIMPRINT).costs(1),
        ItemStock.of(:POMEGBERRY).costs(1),
        ItemStock.of(:KELPSYBERRY).costs(1),
        ItemStock.of(:QUALOTBERRY).costs(1),
        ItemStock.of(:HONDEWBERRY).costs(1),
        ItemStock.of(:GREPABERRY).costs(1),
        ItemStock.of(:TAMATOBERRY).costs(1),
        ItemStock.of(:LONELYMINT).costs(1),
        ItemStock.of(:ADAMANTMINT).costs(1),
        ItemStock.of(:BRAVEMINT).costs(1),
        ItemStock.of(:NAUGHTYMINT).costs(1),
        ItemStock.of(:BOLDMINT).costs(1),
        ItemStock.of(:IMPISHMINT).costs(1),
        ItemStock.of(:RELAXEDMINT).costs(1),
        ItemStock.of(:LAXMINT).costs(1),
        ItemStock.of(:MODESTMINT).costs(1),
        ItemStock.of(:QUIETMINT).costs(1),
        ItemStock.of(:RASHMINT).costs(1),
        ItemStock.of(:MILDMINT).costs(1),
        ItemStock.of(:CAREFULMINT).costs(1),
        ItemStock.of(:SASSYMINT).costs(1),
        ItemStock.of(:CALMMINT).costs(1),
        ItemStock.of(:GENTLEMINT).costs(1),
        ItemStock.of(:TIMIDMINT).costs(1),
        ItemStock.of(:HASTYMINT).costs(1),
        ItemStock.of(:NAIVEMINT).costs(1),
        ItemStock.of(:JOLLYMINT).costs(1),
        ItemStock.of(:SERIOUSMINT).costs(1),
      ],
      "TMs" => [
        ItemStock.of(:TM75, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # sd, allens tm
        ItemStock.of(:TM158, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # np, alice's tm
        ItemStock.of(:TM04, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # calm mind
        ItemStock.of(:TM08, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # bulk up
        ItemStock.of(:TM18, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # protect
        ItemStock.of(:TM52, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # focus blast
        ItemStock.of(:TM55, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # scald
        ItemStock.of(:TM26, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # earthquake
        ItemStock.of(:TM90, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # substitute
        ItemStock.of(:TM92, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # trick room
        ItemStock.of(:TM165, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # scale shot, damien's tm
        ItemStock.of(:TM14, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # blizzard
        ItemStock.of(:TM25, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']),  # thunder
        ItemStock.of(:TM38, 1).costs(10000).properties(conditions: ['!searchItem(self.item)']), # fire blast,
      ],
    },
  },

  :SomniamMallBerries => {
    :Messages => {
      :welcome => "MALL EMPLOYEE: You want it, we've got it?",
      :goodbye => "MALL EMPLOYEE: Come again!",

      :no_money => "MALL EMPLOYEE: You don't have enough for that!",
    },
    :Inventory => [
      ItemStock.of(:OCCABERRY).costs(3000),
      ItemStock.of(:PASSHOBERRY).costs(3000),
      ItemStock.of(:WACANBERRY).costs(3000),
      ItemStock.of(:RINDOBERRY).costs(3000),
      ItemStock.of(:YACHEBERRY).costs(3000),
      ItemStock.of(:PAYAPABERRY).costs(3000),
      ItemStock.of(:TANGABERRY).costs(3000),
      ItemStock.of(:CHARTIBERRY).costs(3000),
      ItemStock.of(:CHOPLEBERRY).costs(3000),
      ItemStock.of(:KEBIABERRY).costs(3000),
      ItemStock.of(:SHUCABERRY).costs(3000),
      ItemStock.of(:COBABERRY).costs(3000),
      ItemStock.of(:HABANBERRY).costs(3000),
      ItemStock.of(:KASIBBERRY).costs(3000),
      ItemStock.of(:COLBURBERRY).costs(3000),
      ItemStock.of(:BABIRIBERRY).costs(3000),
      ItemStock.of(:CHILANBERRY).costs(3000),
      ItemStock.of(:ROSELIBERRY).costs(3000),
    ],
  },

  :KakoriBeach => {
    :Messages => {
      :welcome => "The person who's supposed to be at this stand went missing so...\nHow about some moves?",
      :goodbye => "If you catch wind of where they are, tell me.",
      :anything_else => "One more?",
      :nothing_to_buy => "Ran me right out..",

      :success_items => "Make good use of that one, y'hear me?",
    },
    :Inventory => [
      MoveStock.of(:DRAGONCHEER).costs(2, :YELLOWSHARD).properties(purchase_confirm_single: "{1}? Bit weird but sure. That'll be {2}."),
      MoveStock.of(:TRAILBLAZE).costs(4, :GREENSHARD).properties(purchase_confirm_single: "{1}? Weak, but useful. That'll be {2}."),
      MoveStock.of(:FEATHERDANCE).costs(3, :BLUESHARD).properties(purchase_confirm_single: "{1}? That Rorim guy really likes it. That'll be {2}."),
      MoveStock.of(:HAZE).costs(3, :BLUESHARD).properties(purchase_confirm_single: "{1}? Useful in a pinch. That'll be {2}."),
      MoveStock.of(:PLUCK).costs(2, :GREENSHARD).properties(purchase_confirm_single: "{1}? That'll be {2}."),
      MoveStock.of(:TAKEDOWN).costs(2, :REDSHARD).properties(purchase_confirm_single: "{1}? That'll be {2}."),
      MoveStock.of(:STRINGSHOT).costs(2, :GREENSHARD).properties(purchase_confirm_single: "{1}? That'll be {2}."),
      MoveStock.of(:POUNCE).costs(2, :GREENSHARD).properties(purchase_confirm_single: "{1}? That'll be {2}."),
      MoveStock.of(:NIGHTSHADE).costs(2, :BLUESHARD).properties(purchase_confirm_single: "{1}? That'll be {2}."),
      MoveStock.of(:LUNGE).costs(3, :REDSHARD).properties(purchase_confirm_single: "{1}? Hopefully not at me. That'll be {2}."),
      MoveStock.of(:CHILLINGWATER).costs(2, :BLUESHARD).properties(purchase_confirm_single: "{1}? Could use some of that, it's blazing. That'll be {2}."),
    ],
  },

  :HerbShop => {
    :Messages => {
      :welcome => "Herbs! Get your herbs here!",

      :success_items => "Make good use of that one, y'hear me?",
    },
    :Inventory => [
      ItemStock.of(:WHITEHERB),
      ItemStock.of(:POWERHERB),
      ItemStock.of(:MENTALHERB),
    ],
  },

  :GemShop => {
    :Inventory => [
      ItemStock.of(:NORMALGEM),
      ItemStock.of(:FIREGEM),
      ItemStock.of(:WATERGEM),
      ItemStock.of(:GRASSGEM),
      ItemStock.of(:ROCKGEM),
      ItemStock.of(:GROUNDGEM),
      ItemStock.of(:FIGHTINGGEM),
      ItemStock.of(:POISONGEM),
      ItemStock.of(:BUGGEM),
      ItemStock.of(:FLYINGGEM),
      ItemStock.of(:ELECTRICGEM),
      ItemStock.of(:ICEGEM),
      ItemStock.of(:GHOSTGEM),
      ItemStock.of(:PSYCHICGEM),
      ItemStock.of(:DARKGEM),
      ItemStock.of(:STEELGEM),
      ItemStock.of(:DRAGONGEM),
      ItemStock.of(:FAIRYGEM),
    ],
  },

  :BerryEmporium => {
    :Inventory => [
      ItemStock.of(:ORANBERRY),
      ItemStock.of(:PECHABERRY),
      ItemStock.of(:RAWSTBERRY),
      ItemStock.of(:CHERIBERRY),
      ItemStock.of(:CHESTOBERRY),
      ItemStock.of(:ASPEARBERRY),
      ItemStock.of(:SITRUSBERRY).properties(conditions: ['$Trainer.numbadges >= 5']),
      ItemStock.of(:OCCABERRY).properties(conditions: ['$Trainer.numbadges >= 8']),
      ItemStock.of(:PASSHOBERRY).properties(conditions: ['$Trainer.numbadges >= 8']),
      ItemStock.of(:WACANBERRY).properties(conditions: ['$Trainer.numbadges >= 8']),
      ItemStock.of(:RINDOBERRY).properties(conditions: ['$Trainer.numbadges >= 8']),
      ItemStock.of(:LUMBERRY).properties(conditions: ['$Trainer.numbadges >= 12']),
    ],
  },

  :BallEmporium => {
    :Inventory => [
      ItemStock.of(:HEAVYBALL),
      ItemStock.of(:MOONBALL),
      ItemStock.of(:LOVEBALL).properties(conditions: ["$Trainer.numbadges >= 1"]),
      ItemStock.of(:FASTBALL).properties(conditions: ["$Trainer.numbadges >= 1"]),
      ItemStock.of(:NESTBALL).properties(conditions: ['$Trainer.numbadges >= 2']),
      ItemStock.of(:NETBALL).properties(conditions: ['$Trainer.numbadges >= 3']),
      ItemStock.of(:TIMERBALL).properties(conditions: ['$Trainer.numbadges >= 5']),
      ItemStock.of(:DIVEBALL).properties(conditions: ['$Trainer.numbadges >= 5']),
      ItemStock.of(:FRIENDBALL).properties(conditions: ['$Trainer.numbadges >= 6']),
      ItemStock.of(:STEAMBALL).properties(conditions: ['$Trainer.numbadges >= 7']),
      ItemStock.of(:MINERALBALL).properties(conditions: ['$Trainer.numbadges >= 7']),
    ],
  },

  :BethShopMining => {
    :Messages => {
      :welcome => "BETH: Hey there \\PN! Ready to trade?",
      :goodbye => "BETH: You have a good one, y'hear?",
      :anything_else => "BETH: Can I getcha anythin' else?",

      :no_items => "BETH: You don't got any of those!",

      :purchase_confirm_single => "BETH: Sounds like a reasonable business purchase!",

      :success_items => "BETH: Look at that! We traded!",
    },
    :Inventory => {
      "Shards 'n Shrooms" => [
        ItemStock.of(:BIGMUSHROOM).costs(3, :TINYMUSHROOM).properties(
          currency_shortname: "Tiny Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM).costs(2, :GREENSHARD),
        ItemStock.of(:BIGMUSHROOM).costs(2, :REDSHARD),
        ItemStock.of(:BIGMUSHROOM).costs(2, :BLUESHARD),
        ItemStock.of(:BIGMUSHROOM).costs(2, :YELLOWSHARD),
        ItemStock.of(:BIGMUSHROOM, 5).costs(4, :GREENSHARD).properties(
          display_name: "5 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM, 5).costs(4, :REDSHARD).properties(
          display_name: "5 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM, 5).costs(4, :BLUESHARD).properties(
          display_name: "5 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM, 5).costs(4, :YELLOWSHARD).properties(
          display_name: "5 Big Shrooms",
        ),
      ],

      "Fancy Rocks" => [
        ItemStock.of(:BIGMUSHROOM, 2).costs(1, :HARDSTONE).properties(
          display_name: "2 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM, 2).costs(1, :ICYROCK).properties(
          display_name: "2 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM, 2).costs(1, :SMOOTHROCK).properties(
          display_name: "2 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM, 2).costs(1, :HEATROCK).properties(
          display_name: "2 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM, 2).costs(1, :DAMPROCK).properties(
          display_name: "2 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM, 2).costs(1, :AMPLIFIELDROCK).properties(
          display_name: "2 Big Shrooms",
        ),
      ],

      "Other Oddities" => [
        ItemStock.of(:BIGMUSHROOM,3).costs(1, :ODDKEYSTONE).properties(
          display_name: "3 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM,2).costs(1, :IRONBALL).properties(
          display_name: "2 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM,2).costs(1, :OVALSTONE).properties(
          display_name: "2 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM,2).costs(1, :FLOATSTONE).properties(
          display_name: "2 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM,2).costs(1, :RAREBONE).properties(
          display_name: "2 Big Shrooms",
        ),
        ItemStock.of(:BIGMUSHROOM,2).costs(1, :STARPIECE).properties(
          display_name: "2 Big Shrooms",
        ),
      ],
    },
  },

  :BethShop => {
    :Messages => {
      :welcome => "We've got the freshest milk in all of Aevium!",

      :success_items => "Make good use of that one, y'hear me?",
    },
    :Inventory => [
      ItemStock.of(:BERRYJUICE),
      ItemStock.of(:FRESHWATER).properties(conditions: ["$Trainer.numbadges >= 2"]),
      ItemStock.of(:LEMONADE).properties(conditions: ["$Trainer.numbadges >= 3"]),
      ItemStock.of(:MOOMOOMILK).properties(conditions: ["$Trainer.numbadges >= 3"]),
    ],
  },
}

def pbInfoBox(number)
  unrealbackup = $unrealClock.visible
  $unrealClock.visible = false
  clues = [
    # 0
    [
      _INTL("1. Underneath Chrisola Hotel."),
      _INTL("2. Underneath Dr. Jenkel's Laboratory."),
      _INTL("3. Underneath the largest fountain."),
    ],
    # 1
    [
      _INTL("Rules of the Land:"),
      _INTL("8. Thou shalt not have better Ice-type Pokémon than me."),
      _INTL("Me as in Angie."),
      _INTL("10. People shall remain a 6 foot distance from each"),
      _INTL("other at all times."),
      _INTL("Those of the same gender must remain double this number."),
      _INTL("12. Thou shalt not pour the milk before the cereal."),
      _INTL("16. Thou shalt not wake up at 7:01 on the dot."),
      _INTL("23. Thou shalt not fish for compliments."),
      _INTL("34. Thou shalt not be mean to Lady Angie."),
      _INTL("40. Thou shalt not look at the moon with a grimace."),
      _INTL("43. Thou shalt not boogie like a maniac a quarter past midnight."),
      _INTL("49. Thou shalt not be hungry after a workout."),
      _INTL("55. Thou shalt not use emojis in text messages."),

    ],
    # 2
    [
      _INTL("Zygarde Cells found: {1}", $game_variables[:Z_Cells]),
      _INTL("Zygarde Cores found: {1}", $game_variables[:Z_Cores]),
      _INTL("Red Essence collected: {1}", $game_variables[:RedEssence]),
      _INTL("Spiritomb Wisps collected: {1}", $game_variables[:SpiritombWisps]),
    ],
    # 3
    [
      _INTL(""),
      _INTL("Up - Sword Swipe. Dmg: 30 (Fairy Aura: 60)"),
      _INTL("Down - Sword Volley. Dmg: 40 (Fairy Aura: 80)"),
      _INTL("Left - Sword Condemn. Dmg: 80 (Fairy Aura: 160)"),
      _INTL("Right - Fairy Aura. Dbls Power."),
      _INTL("A - Geomancy (Ult). Increases Gauge Gen"),
    ],
    # 4
    [
      _INTL("Storm-Nym: Protectors of Aevium"),
      _INTL("I always wonder why Nymiera chose her disciples the way she did."),
      _INTL("Vivian was an Envoy that could predict the coming of calamity."),
      _INTL("Anju, a delicate heiress that controlled aura to preserve life."),
      _INTL("And then you have Hazuki, her shield that never wavered.")
    ],
    # 5
    [
      _INTL("Research: Mega Evolution"),
      _INTL("Victreebel"),
      _INTL("Altaria"),
      _INTL("Pidgeot"),
      _INTL("Sharpedo"),
      _INTL(""),
      _INTL("All four noted here can be found on Route 3 and Kugearen Woods."),
      _INTL("Use a Good Rod to find Carvanha"),
      _INTL("Please have all in your party at once.")
    ],
    # 6
    [
      _INTL("Research: Omni Band"),
      _INTL("4 Yellow Shards"),
      _INTL("4 Blue Shards"),
      _INTL("4 Green Shards"),
      _INTL("4 Red Shards"),
      _INTL("3 Heart Scales"),
      _INTL("2 Blast Powders"),
      _INTL("1 Dawn Stone"),
      _INTL("1 Shiny Stone")
    ],
    # 7
    [
      _INTL("Missing Mother: Locations"),
      _INTL("1. Aqua Apartments:"),
      _INTL("Floor 2 Client: Female with pink dress."),
      _INTL("----"),
      _INTL("2. Velvet Apartments:"),
      _INTL("Floor 3. Client: Female with long brown hair."),
      _INTL("----"),
      _INTL("3. Emerald Apartments:"),
      _INTL("Lobby. Client: Male with bright red hair."),
      _INTL("----"),
      _INTL("----"),
      _INTL("----"),
      _INTL("If you find some compelling evidence about her location"),
      _INTL("just come back to me."),
      _INTL("No need to waste time and search around"),
      _INTL("if you already got a big clue!")
    ],
    # 8
    [
      _INTL("Paused."),

    ],
  ]
  cmdwin = pbListWindow(clues[number], Graphics.width)
  cmdwin.z = 99997
  cmdwin.rowHeight = 20
  cmdwin.refresh
  Graphics.update
  loop do
    Graphics.update
    Input.update
    cmdwin.update
    break if Input.trigger?(Input::C) || Input.trigger?(Input::B)
  end
  cmdwin.dispose
  $unrealClock.visible = unrealbackup
end

Events.onStepTaken += proc {
  if $game_variables[:LabStepLimit] > 0
    $game_variables[:LabStepLimit] -= 1
  end
}

Events.onWildPokemonCreate += proc { |sender, e|
  pokemon = e[0]
  # Egg moves for wild events
  case $game_variables[:WildMods]
    when 1 # A-Exegg
      pokemon.pbLearnMove(:DRAGONHAMMER)
      pokemon.initAbility
    when 2 # Misdreavus/Egyem/Cacturne
      pokemon.pbLearnMove(:NASTYPLOT)
    when 3 # Darmanitan
      pokemon.pbLearnMove(:EXTRASENSORY)
      pokemon.setAbility(:ZENMODE)
    when 4 # Mandibuzz
      pokemon.pbLearnMove(:FOULPLAY)
    when 5 # Trapinch, Pinsir
      pokemon.pbLearnMove(:SUPERPOWER)
    when 6 # Hippopotas/Hippowdon
      pokemon.pbLearnMove(:SUPERPOWER)
    when 7 # Hoppip
      pokemon.pbLearnMove(:STRENGTHSAP)
    when 8 # Fletchling
      pokemon.pbLearnMove(:QUICKGUARD)
    when 9 # Voltorb
      pokemon.pbLearnMove(:SIGNALBEAM)
    when 10 # Pachirisu
      pokemon.pbLearnMove(:ELECTROWEB)
    when 11 # FREE

    when 12 # FREE

    when 13 # FREE

    when 14 # FREE

    when 15 # Shuppet
      pokemon.pbLearnMove(:PAINSPLIT)
    when 16 # Munna
      pokemon.pbLearnMove(:SWIFT)
    when 17 # Murkrow
      pokemon.pbLearnMove(:BRAVEBIRD)
    when 18 # Whismur
      pokemon.pbLearnMove(:EXTRASENSORY)
    when 19 # FREE

    when 20 # Falinks + Snorlax/Absol 33%
      pokemon.pbLearnMove(:STOMPINGTANTRUM)
    when 21 # FREE

    when 22 # FREE

    when 23 # FREE

    when 24 # FREE

    when 25 # FREE

    when 26 # FREE

    when 27 # Yanma
      pokemon.pbLearnMove(:SILVERWIND)
    when 28 # Krabby/Toedscool/Omanyte/Kabuto/Throh
      pokemon.pbLearnMove(:KNOCKOFF)
    when 29 # Kingler/Mareanie
      pokemon.pbLearnMove(:KNOCKOFF)
      pokemon.pbLearnMove(:LIQUIDATION)
    when 30 # Clamperl
      pokemon.pbLearnMove(:CONFUSERAY)
    when 31 # Squirtle
      pokemon.pbLearnMove(:MIRRORCOAT)
    when 32 # Gastrodon/Wooper
      pokemon.pbLearnMove(:EARTHPOWER)
    when 33 # FREE

    when 34 # Mudkip/Garbodor/Miltank
      pokemon.pbLearnMove(:CURSE)
    when 35 # Elekid, Magby
      pokemon.pbLearnMove(:CROSSCHOP)
    when 36 # Piplup
      pokemon.pbLearnMove(:ICYWIND)
    when 37 # Empoleon
      pokemon.pbLearnMove(:LIQUIDATION)
      pokemon.pbLearnMove(:STEALTHROCK)
      pokemon.pbLearnMove(:FLASHCANNON)
    when 38 # FREE

    when 39 # Octillery
      pokemon.pbLearnMove(:GUNKSHOT)
    when 40 # Buneary
      pokemon.pbLearnMove(:COSMICPOWER)
    when 41 # Sneasel
      pokemon.pbLearnMove(:ICICLECRASH)
    when 42 # FREE

    when 43 # FREE

    when 44 # H. Growlithe
      pokemon.pbLearnMove(:HEADSMASH)
      pokemon.pbLearnMove(:MORNINGSUN)
    when 45 # FREE

    when 46 # Litten/Aipom
      pokemon.pbLearnMove(:FAKEOUT)
    when 47 # FREE
    when 48 # Stantler + Absol 33%
      pokemon.pbLearnMove(:MEGAHORN)
    when 49 # Deerling/Sawsbuck
      pokemon.pbLearnMove(:HEADBUTT)
    when 50 # Skarmory
      pokemon.pbLearnMove(:BRAVEBIRD)
    when 51 # Parasect
      pokemon.pbLearnMove(:WIDEGUARD)
    when 52 # FREE

    when 53 # FREE

    when 54 # FREE

    when 55 # FREE

    when 56 # Totodile
      pokemon.pbLearnMove(:ICEPUNCH)
    when 57 # FREE

    when 58 # FREE

    when 59 # FREE

    when 60 # FREE

    when 61 # Komala + Absol 33%
      pokemon.pbLearnMove(:PLAYROUGH)
    when 62 # FREE

    when 63 # FREE

    when 64 # FREE

    when 65 # Clefairy
      pokemon.pbLearnMove(:MISTYTERRAIN)
    when 66 # Jynx
      pokemon.pbLearnMove(:PSYCHIC)
      pokemon.pbLearnMove(:NASTYPLOT)
    when 67 # Nidoran F + Snorlax 33%
      pokemon.pbLearnMove(:CHARM)
      pokemon.pbLearnMove(:MOONLIGHT)
    when 68 # Blitzle
      pokemon.pbLearnMove(:DOUBLEKICK)
    when 69 # Inkay
      pokemon.pbLearnMove(:DESTINYBOND)
    when 70 # Scraggy/Snorlax + Snorlax 33%
      pokemon.pbLearnMove(:POWERUPPUNCH)
    when 71 # Wimpod/Snorunt
      pokemon.pbLearnMove(:SPIKES)
    when 72 # Zangoose/Seviper/Nincada
      pokemon.pbLearnMove(:NIGHTSLASH)
    when 73 # Flabebe
      pokemon.pbLearnMove(:NATUREPOWER)
    when 74 # Ambipom
      pokemon.pbLearnMove(:FAKEOUT)
      pokemon.pbLearnMove(:TAILSLAP)
    when 75 # FREE

    when 76 # FREE

    when 77 # Swablu
      pokemon.pbLearnMove(:PERISHSONG)
    when 78 # FREE

    when 79 # Phantump
      pokemon.pbLearnMove(:TRICK)
    when 80 # Gastly
      pokemon.pbLearnMove(:REFLECTTYPE)
      pokemon.pbLearnMove(:FRUSTRATION)
      pokemon.makeFemale
      pokemon.happiness = 0
      pokemon.ot = "Griselda"
      pokemon.trainerID = KNOWN_TRAINERS[pokemon.ot]
    when 81 # Gossifleur/Lotad
      pokemon.pbLearnMove(:LEECHSEED)
    when 82 # Corsola
      pokemon.pbLearnMove(:THROATCHOP)
    when 83 # Pyukumuku
      pokemon.pbLearnMove(:BLOCK)
    when 84 # Bisharp
      pokemon.item = :LEADERSCREST
    when 85 # Pinsir
      pokemon.pbLearnMove(:QUICKATTACK)
    when 86 # Lapras
      pokemon.pbLearnMove(:FREEZEDRY)
    when 87 # Gible
      pokemon.pbLearnMove(:SCALESHOT)
      pokemon.pbLearnMove(:EARTHQUAKE)
    when 88 # Clawitzer
      pokemon.pbLearnMove(:DRAGONPULSE)
      pokemon.pbLearnMove(:ICYWIND)
    when 89 # Larvesta
      pokemon.pbLearnMove(:GIGADRAIN)
      pokemon.pbLearnMove(:MORNINGSUN)
    when 90 # Vulpix
      pokemon.pbLearnMove(:HEATWAVE)
      pokemon.pbLearnMove(:TAILSLAP)
    when 91 # Dewpider
      pokemon.pbLearnMove(:STICKYWEB)
      pokemon.pbLearnMove(:GIGADRAIN)
    when 92 # Horsea
      pokemon.pbLearnMove(:DRAGONPULSE)
      pokemon.pbLearnMove(:SNIPESHOT)
    when 93 # Wingull/Pelipper
      pokemon.pbLearnMove(:SHOCKWAVE)
      pokemon.pbLearnMove(:SEEDBOMB)
    when 94 # Tepig
      pokemon.pbLearnMove(:SUPERPOWER)
      pokemon.pbLearnMove(:BURNUP)
      pokemon.pbLearnMove(:SUCKERPUNCH)
    when 95 # Mech
      pokemon.pbLearnMove(:JAWLOCK)
      pokemon.pbLearnMove(:THUNDERFANG)
      pokemon.pbLearnMove(:HIGHHORSEPOWER)
      pokemon.pbLearnMove(:HEAVYSLAM)
      pokemon.name = "LAIR-????"
      pokemon.setNature(:ADAMANT)
      pokemon.setGender(:F)
      pokemon.form = 1
      pokemon.makeGenderless
      pokemon.initAbility
      for i in 0...5
        pokemon.iv[i] = 31
      end
      case $game_variables[:DifficultyModes]
        when 0
          pokemon.ev[1] = 252
          pokemon.ev[3] = 252
          pokemon.ev[4] = 4
        when 1
          for i in 0...5
            pokemon.ev[i] = [85, pokemon.level * 3 / 2].min
          end
      end
      pokemon.calcStats
    when 96 # Lapras
      pokemon.pbLearnMove(:ROCKSLIDE)
      pokemon.pbLearnMove(:PSYCHIC)
      pokemon.pbLearnMove(:CONFUSERAY)
      pokemon.pbLearnMove(:SING)
    when 97 # Bidoof

    when 98 # Mech
      pokemon.pbLearnMove(:LIGHTSCREEN)
      pokemon.pbLearnMove(:REFLECT)
      pokemon.name = "CLAY-????"
      pokemon.setNature(:MODEST)
      pokemon.item = :CLAYCREST
      pokemon.form = 1
      pokemon.calcStats
    when 99 # Treecko
      pokemon.pbLearnMove(:LEECHSEED)
    when 100 # Regice
      pokemon.pbLearnMove(:COLDTRUTH)
      pokemon.pbLearnMove(:REFLECT)
      pokemon.pbLearnMove(:THUNDERBOLT)
      pokemon.pbLearnMove(:SHEERCOLD)
      pokemon.name = "REGICE"
      pokemon.setNature(:MODEST)
      case $game_variables[:DifficultyModes]
        when 0
          pokemon.ev[0] = 252
          pokemon.ev[2] = 252
          pokemon.ev[4] = 4
        when 1
          for i in 0...5
            pokemon.ev[i] = [85, pokemon.level * 3 / 2].min
          end
      end
      pokemon.calcStats
    when 101 # Pidove
      pokemon.pbLearnMove(:MORNINGSUN)
    when 102 # Hoothoot
      pokemon.pbLearnMove(:SLEEPTALK)
      pokemon.pbLearnMove(:NIGHTSHADE)
      pokemon.status = :SLEEP
      pokemon.statusCount = 3
      pokemon.setAbility(:TINTEDLENS)
    when 103 # Cubone
      pokemon.pbLearnMove(:ANCIENTPOWER)
      pokemon.pbLearnMove(:PERISHSONG)
    when 104 # Duskull
      pokemon.pbLearnMove(:MEMENTO)
      pokemon.pbLearnMove(:CHARGEBEAM)
    when 105 # FREE

    when 106 # FREE

    when 107 # FREE

    when 108 # MANKEY
      pokemon.pbLearnMove(:VACUUMWAVE)
    when 109 # Corphish
      pokemon.pbLearnMove(:DRAGONDANCE)
    when 110 # Clauncher
      pokemon.pbLearnMove(:SLUDGEBOMB)
    when 111 # Salazzle
      pokemon.pbLearnMove(:BELCH)
      pokemon.item = :TAMATOBERRY
    when 112 # Slakoth
      pokemon.pbLearnMove(:HAMMERARM)
    when 113 # Ariados
      pokemon.pbLearnMove(:GIGADRAIN)
      pokemon.status = :SLEEP
    when 114 # Woobat
      pokemon.pbLearnMove(:ROOST)
      pokemon.pbLearnMove(:HELPINGHAND)
    when 115 # FREE

    when 116 # Deerling/Sawsbuck Winter
      pokemon.pbLearnMove(:SEEDBOMB)
      pokemon.pbLearnMove(:GIGADRAIN)
      pokemon.pbLearnMove(:GRASSWHISTLE)
    when 117 # Paras
      pokemon.pbLearnMove(:FELLSTINGER)
      pokemon.pbLearnMove(:CROSSPOISON)
      pokemon.pbLearnMove(:GRASSYTERRAIN)
    when 118 # Starly
      pokemon.pbLearnMove(:FEATHERDANCE)
      pokemon.pbLearnMove(:REVENGE)
    when 119 # Ruthless
      pokemon.item = :BLKPRISM
      if !$game_switches[:Empty_IVs_Password]
        if !(pokemon.getCacheData.EggGroups.include?(:Undiscovered) || pokemon.species == :MANAPHY) # undiscovered group or manaphy
          stat1, stat2, stat3 = [0, 1, 2, 3, 4, 5].sample(3)
          for i in 0..5
            pokemon.iv[i] = 31 if [stat1, stat2, stat3].include?(i)
          end
        end
      end
    when 120 # RustedMech
      pokemon.pbLearnMove(:GIGAIMPACT)
      pokemon.pbLearnMove(:BITE)
      pokemon.pbLearnMove(:CHARGE)
      pokemon.pbLearnMove(:FOCUSENERGY)
      pokemon.name = "???"
      pokemon.setNature(:NAIVE)
      pokemon.setGender(:F)
      pokemon.makeGenderless
      pokemon.form = 2
      pokemon.initAbility
    when 121 # Aevian Bronzor

    when 122 # Gen 2 Shellder
      pokemon.pbLearnMove(:CURSE)
      pokemon.pbLearnMove(:SELFDESTRUCT)
      pokemon.pbLearnMove(:TRIATTACK)
    when 123 # Gen 2 Zubat
      pokemon.pbLearnMove(:MIMIC)
      pokemon.pbLearnMove(:DOUBLEEDGE)
      pokemon.pbLearnMove(:ENDURE)
      pokemon.pbLearnMove(:PLUCK)
    when 124 # h-sneasel
      pokemon.pbLearnMove(:FAKEOUT)
      pokemon.pbLearnMove(:LASHOUT)
    when 125 # Gen 2 Poliwag
      pokemon.pbLearnMove(:MIMIC)
      pokemon.pbLearnMove(:NATURALGIFT)
      pokemon.pbLearnMove(:DIVE)
    when 126 # Gen 2 Cyndaquil
      pokemon.pbLearnMove(:MIMIC)
      pokemon.pbLearnMove(:NATURALGIFT)
      pokemon.pbLearnMove(:ENDURE)
      pokemon.pbLearnMove(:MUDSLAP)
    when 127 # Gen 2 Onix
      pokemon.pbLearnMove(:ANCIENTPOWER)
      pokemon.pbLearnMove(:NATURALGIFT)
      pokemon.pbLearnMove(:ENDURE)
      pokemon.pbLearnMove(:TWISTER)
    when 128 # Delpha
      pokemon.name = "Delpha"
      pokemon.setNature(:MODEST)
      pokemon.makeFemale
      pokemon.ability = :PRISMPOWER
      pokemon.item = :BLKPRISM
      stat1, stat2, stat3 = [0, 1, 2, 3, 4, 5].sample(3)
      for i in 0..5
        pokemon.iv[i] = 31 if [stat1, stat2, stat3].include?(i)
      end
    when 129 # Territorial Luvdisc
      stat1, stat2, stat3 = [0, 1, 2, 3, 4, 5].sample(3)
      for i in 0..5
        pokemon.iv[i] = 31 if [stat1, stat2, stat3].include?(i)
      end
      pokemon.item = :LUVCREST
      pokemon.happiness = 255
      pokemon.pbLearnMove(:CHARM)
      pokemon.pbLearnMove(:ATTRACT)
      pokemon.pbLearnMove(:DRAININGKISS)
      pokemon.pbLearnMove(:AQUAJET)
    when 130 # Corsola
      pokemon.pbLearnMove(:DESTINYBOND)
    when 131 # Prism Exploud
      pokemon.item = :BLKPRISM
      for i in 0..5
        pokemon.iv[i] = 31
      end
      pokemon.pbLearnMove(:UPROAR)
      pokemon.pbLearnMove(:OUTRAGE)
      pokemon.pbLearnMove(:STOMPINGTANTRUM)
      pokemon.pbLearnMove(:SCREECH)
    when 132 # Grookey
      pokemon.pbLearnMove(:FAKEOUT)
      pokemon.pbLearnMove(:LEECHSEED)
    when 133 # Chimchar
      pokemon.pbLearnMove(:FAKEOUT)
      pokemon.pbLearnMove(:ENCORE)
    when 134 # Gen 2 Larvitar
      pokemon.pbLearnMove(:ANCIENTPOWER)
      pokemon.pbLearnMove(:OUTRAGE)
    when 135 # Nidoran M
      pokemon.pbLearnMove(:SUCKERPUNCH)
      pokemon.pbLearnMove(:MORNINGSUN)
    when 136 # Wooloo
      pokemon.pbLearnMove(:PAYBACK)
      pokemon.pbLearnMove(:COUNTER)
    when 137 # A-Sewaddle
      pokemon.pbLearnMove(:LUNGE)
      pokemon.pbLearnMove(:MEFIRST)
    when 138 # Azelf
      pokemon.pbLearnMove(:NASTYPLOT)
      pokemon.pbLearnMove(:EXTRASENSORY)
      pokemon.pbLearnMove(:LASTRESORT)
      pokemon.pbLearnMove(:SWIFT)
    when 139 # Mesprit
      pokemon.pbLearnMove(:CHARM)
      pokemon.pbLearnMove(:EXTRASENSORY)
      pokemon.pbLearnMove(:COPYCAT)
      pokemon.pbLearnMove(:SWIFT)
    when 140 # Uxie
      pokemon.pbLearnMove(:AMNESIA)
      pokemon.pbLearnMove(:EXTRASENSORY)
      pokemon.pbLearnMove(:FLAIL)
      pokemon.pbLearnMove(:SWIFT)
    when 141 # Lapras
      pokemon.pbLearnMove(:STONEEDGE)
      pokemon.pbLearnMove(:PSYCHIC)
      pokemon.pbLearnMove(:CONFUSERAY)
      pokemon.pbLearnMove(:SING)
    when 142 # Lileep
      pokemon.pbLearnMove(:GRASSKNOT)
    when 143 # flamigo
      pokemon.pbLearnMove(:UTURN)
    when 144 # clodsire
      pokemon.pbLearnMove(:ANCIENTPOWER)
      pokemon.pbLearnMove(:COUNTER)
    when 145 # Keta's Riolu
      pokemon.item = :BLKPRISM
      pokemon.makeFemale
     for i in 0..5
        pokemon.iv[i] = 31
      end
      pokemon.ot = "Kenneth"
      pokemon.makeShiny
      pokemon.pbLearnMove(:BLAZEKICK)
      pokemon.pbLearnMove(:EARTHQUAKE)
      pokemon.pbLearnMove(:COUNTER)
      pokemon.pbLearnMove(:SWORDSDANCE)
    when 146 # Torchic
      pokemon.pbLearnMove(:MEGAKICK)
      pokemon.pbLearnMove(:BOUNCE)
      pokemon.pbLearnMove(:NIGHTSLASH)
      pokemon.pbLearnMove(:FLAREBLITZ)
    when 147 # Rotom
      pokemon.pbLearnMove(:PARABOLICCHARGE)
      pokemon.pbLearnMove(:PARTINGSHOT)
      pokemon.pbLearnMove(:DISCHARGE)
      pokemon.pbLearnMove(:SPECTRALSCREAM)
      pokemon.calcStats
    when 148 # Meloetta
      pokemon.pbLearnMove(:PSYCHIC)
      pokemon.pbLearnMove(:UTURN)
      pokemon.pbLearnMove(:HYPERVOICE)
      pokemon.pbLearnMove(:CLOSECOMBAT)
    when 149 # Regirock
      pokemon.pbLearnMove(:ROCKSLIDE)
      pokemon.pbLearnMove(:EARTHQUAKE)
      pokemon.pbLearnMove(:CURSE)
      pokemon.pbLearnMove(:THUNDERWAVE)
    when 150 # Registeel
      pokemon.pbLearnMove(:HEAVYSLAM)
      pokemon.pbLearnMove(:EARTHQUAKE)
      pokemon.pbLearnMove(:CURSE)
      pokemon.pbLearnMove(:THUNDERWAVE)
    when 151 # Regice
      pokemon.pbLearnMove(:ICEBEAM)
      pokemon.pbLearnMove(:THUNDERBOLT)
      pokemon.pbLearnMove(:CURSE)
      pokemon.pbLearnMove(:THUNDERWAVE)
    when 152 # Shayda's Flutter Mane
     for i in 0..5
        pokemon.iv[i] = 31
      end
      pokemon.ot = "Shayda"
      pokemon.ability = :MAGICGUARD
      pokemon.makeShiny
      pokemon.form = 1
      pokemon.pbLearnMove(:SHADOWBALL)
      pokemon.pbLearnMove(:MOONBLAST)
      pokemon.pbLearnMove(:PSYSHOCK)
      pokemon.pbLearnMove(:WISH)
    when 153 # Type-Null
      pokemon.ot = $Unidata[:NarcyQuestComplete] ? "Vitus" : "Sirius"
      pokemon.trainerID = KNOWN_TRAINERS[pokemon.ot]
    when 154 # Scream Tail
      pokemon.moves.clear
      pokemon.pbLearnMove(:BOOMBURST)
      pokemon.pbLearnMove(:GYROBALL)
      pokemon.pbLearnMove(:PLAYROUGH)
      pokemon.pbLearnMove(:WISH)
    when 155 # Slither Wing
      pokemon.moves.clear
      pokemon.pbLearnMove(:FIRSTIMPRESSION)
      pokemon.pbLearnMove(:DUALWINGBEAT)
      pokemon.pbLearnMove(:LEECHLIFE)
      pokemon.pbLearnMove(:THRASH)
    when 156 # Abra
      pokemon.moves.clear
      pokemon.pbLearnMove(:SHADOWBALL)
      pokemon.pbLearnMove(:PSYBEAM)
      pokemon.pbLearnMove(:MAGICCOAT)
      pokemon.pbLearnMove(:SUBSTITUTE)
    when 157 # Entei
      pokemon.item = :ENTEICREST
    when 158 # Raikou
      pokemon.item = :RAICREST
    when 159 # Suicune
      pokemon.item = :SUICREST
    when 160 # Celebi
      pokemon.item = :CELECREST
  end
}

def pbRentReturn
  $Trainer.party = $game_variables[:TempPartyStorage]
  $game_variables[:TempPartyStorage] = []
end

class MiningGameScene
  BOARDWIDTH  = 13
  BOARDHEIGHT = 10
  ITEMS = [ # Item, probability, graphic x, graphic y, width, height, pattern
    [:HELIXFOSSIL, 2, 5, 3, 4, 4, [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:HELIXFOSSIL, 2, 9, 3, 4, 4, [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1]],
    [:HELIXFOSSIL, 1, 13, 3, 4, 4, [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:HELIXFOSSIL, 1, 17, 3, 4, 4, [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1]],
    [:ROOTFOSSIL, 1, 0, 7, 5, 5, [1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0]],
    [:ROOTFOSSIL, 1, 5, 7, 5, 5, [0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0]],
    [:ROOTFOSSIL, 1, 10, 7, 5, 5, [0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1]],
    [:ROOTFOSSIL, 1, 15, 7, 5, 5, [0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0]],
    [:CLAWFOSSIL, 1, 0, 12, 4, 5, [0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0]],
    [:CLAWFOSSIL, 1, 4, 12, 5, 4, [1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1]],
    [:CLAWFOSSIL, 1, 9, 12, 4, 5, [0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0]],
    [:CLAWFOSSIL, 1, 13, 12, 5, 4, [1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1]],
    [:DOMEFOSSIL, 4, 0, 3, 5, 4, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0]],
    [:SKULLFOSSIL, 4, 20, 7, 4, 4, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0]],
    [:ARMORFOSSIL, 4, 24, 7, 5, 4, [0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0]],
    [:SUNSTONE, 6, 21, 17, 3, 3, [0, 1, 0, 1, 1, 1, 1, 1, 1]],
    [:SHINYSTONE, 6, 26, 29, 3, 3, [0, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:DAWNSTONE, 6, 26, 32, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:ICESTONE, 3, 10, 24, 4, 2, [1, 1, 1, 0, 0, 1, 1, 1]],
    [:ICESTONE, 3, 24, 26, 2, 4, [0, 1, 1, 1, 1, 1, 1, 0]],
    [:BLKPRISM, 5, 23, 33, 3, 2, [1, 1, 1, 0, 1, 1]],
    [:BLKPRISM, 5, 24, 30, 2, 3, [1, 1, 1, 1, 1, 0]],
    [:DUSKSTONE, 6, 14, 23, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:THUNDERSTONE, 6, 26, 11, 3, 3, [0, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:FIRESTONE, 6, 20, 11, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:WATERSTONE, 6, 23, 11, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:LEAFSTONE, 3, 18, 14, 3, 4, [0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0]],
    [:LEAFSTONE, 3, 21, 14, 4, 3, [0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0]],
    [:MOONSTONE, 3, 25, 14, 4, 2, [0, 1, 1, 1, 1, 1, 1, 0]],
    [:MOONSTONE, 3, 27, 16, 2, 4, [1, 0, 1, 1, 1, 1, 0, 1]],
    [:OVALSTONE, 10, 24, 17, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:EVERSTONE, 10, 21, 20, 4, 2, [1, 1, 1, 1, 1, 1, 1, 1]],
    [:STARPIECE, 15, 0, 17, 3, 3, [0, 1, 0, 1, 1, 1, 0, 1, 0]],
    [:RAREBONE, 5, 3, 17, 6, 3, [1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1]],
    [:RAREBONE, 5, 3, 20, 3, 6, [1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1]],
    [:REVIVE, 15, 0, 20, 3, 3, [0, 1, 0, 1, 1, 1, 0, 1, 0]],
    [:MAXREVIVE, 5, 0, 23, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:LIGHTCLAY, 10, 6, 20, 4, 4, [1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1]],
    [:HARDSTONE, 10, 6, 24, 2, 2, [1, 1, 1, 1]],
    [:HEARTSCALE, 85, 8, 24, 2, 2, [1, 0, 1, 1]],
    [:IRONBALL, 10, 9, 17, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:ODDKEYSTONE, 5, 10, 20, 4, 4, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:HEATROCK, 10, 12, 17, 4, 3, [1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:DAMPROCK, 10, 14, 20, 3, 3, [1, 1, 1, 1, 1, 1, 1, 0, 1]],
    [:SMOOTHROCK, 10, 17, 18, 4, 4, [0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0]],
    [:ICYROCK, 10, 17, 22, 4, 4, [0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1]],
    [:AMPLIFIELDROCK, 10, 25, 0, 4, 3, [1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:REDSHARD, 40, 21, 22, 3, 3, [1, 1, 1, 1, 1, 0, 1, 1, 1]],
    [:GREENSHARD, 40, 25, 20, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1]],
    [:YELLOWSHARD, 40, 25, 23, 4, 3, [1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1]],
    [:BLUESHARD, 40, 26, 26, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:INSECTPLATE, 2, 0, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:DREADPLATE, 2, 4, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:DRACOPLATE, 2, 8, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:ZAPPLATE, 2, 12, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:FISTPLATE, 2, 16, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:FLAMEPLATE, 2, 20, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:MEADOWPLATE, 2, 0, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:EARTHPLATE, 2, 4, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:ICICLEPLATE, 2, 8, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:TOXICPLATE, 2, 12, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:MINDPLATE, 2, 16, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:STONEPLATE, 2, 20, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:SKYPLATE, 2, 0, 32, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:SPOOKYPLATE, 2, 4, 32, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:IRONPLATE, 2, 8, 32, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:SPLASHPLATE, 2, 12, 32, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:PIXIEPLATE, 2, 16, 32, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
  ]
  IRON = [ # Graphic x, graphic y, width, height, pattern
    [0, 0, 1, 4, [1, 1, 1, 1]],
    [1, 0, 2, 4, [1, 1, 1, 1, 1, 1, 1, 1]],
    [3, 0, 4, 2, [1, 1, 1, 1, 1, 1, 1, 1]],
    [3, 2, 4, 1, [1, 1, 1, 1]],
    [7, 0, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [0, 5, 3, 2, [1, 1, 0, 0, 1, 1]],
    [0, 7, 3, 2, [0, 1, 0, 1, 1, 1]],
    [3, 5, 3, 2, [0, 1, 1, 1, 1, 0]],
    [3, 7, 3, 2, [1, 1, 1, 0, 1, 0]],
    [6, 3, 2, 3, [1, 0, 1, 1, 0, 1]],
    [8, 3, 2, 3, [0, 1, 1, 1, 1, 0]],
    [6, 6, 2, 3, [1, 0, 1, 1, 1, 0]],
    [8, 6, 2, 3, [0, 1, 1, 1, 0, 1]]
  ]
end

# ##DemICE>>  IV / EV changeing doctor functions
def setIVs(pkmn, cmd2)
  params = ChooseNumberParams.new
  params.setRange(0, 31)
  params.setAutoClamp(true)
  params.setDefaultValue(pkmn.iv[cmd2])
  params.setCancelValue(pkmn.iv[cmd2])
  value = Kernel.pbMessageChooseNumber(_INTL("What would you like the volume of the injection to be? (max. 31)"), params)
  pkmn.iv[cmd2] = value
  pkmn.calcStats
end

def setEVs(pkmn, cmd2)
  maxEV = getPlayerMaxEVs
  # Remove investment from the stat you want to inject
  pkmn.ev[cmd2] = 0
  if pkmn.ev.sum + 252 > maxEV
    # Then remove investment from stats, least to greatest in current investment
    evsort = (0...pkmn.ev.length).sort_by { |i| pkmn.ev[i] }
    evsort.each do |i|
      remainder = pkmn.ev.sum + 252 - maxEV
      pkmn.ev[i] -= [remainder, pkmn.ev[i]].min
      # Stop when there are enough points to allocate
      break unless pkmn.ev.sum + 252 > maxEV
    end
  end
  # Ask player which stat to replace when two stats are max invested
  if pkmn.ev.count(252) == 2 && maxEV == 510
    found = pkmn.ev.each_index.select { |i| pkmn.ev[i] == 252 }
    Kernel.pbMessage(_INTL("Hm, it seems that your {1} already has two maximized stats.", getMonName(pkmn.species, pkmn.form)))
    cmd = Kernel.pbMessage(_INTL("Which one would you like to replace?"), found.map { |i| getStatName(i, :full) })
    pkmn.ev[found[cmd]] = 0
  end
  pkmn.ev[cmd2] = 252
  pkmn.calcStats
end

def pbPartyHasDualTypes(type1, type2)
  typevar = false
  for mon in $Trainer.party
    next if mon.nil? || mon.isEgg?

    typevar = true if mon.hp > 0 && mon.hasType?(type1) && mon.hasType?(type2)
  end
  return typevar
end
# ##>>DemICE

class PokemonScreen
  alias _rejuv_itemMenu itemMenu unless method_defined?(:_rejuv_itemMenu)
  def itemMenu(pkmnid, pkmn, quick: false)
    if hasActiveRentalTeam?()
      pbDisplay(_INTL("You are not allowed to change the rental team's items."))
      return
    end
    _rejuv_itemMenu(pkmnid, pkmn, quick: quick)
  end
end

def pbCallTitleFull # :nodoc:
  splash = "sp"
  return Scene_Intro.new(['intro1'], splash)
end

def mainFunctionTwo # :nodoc:
  begin
    startup
    $game_system = Game_System.new
    $game_mute = false
    Graphics.update
    Graphics.freeze
    puts (Time.now - $boottime)
    $scene = pbCallTitleFull
    while $scene != nil
      $scene.main
    end
    Graphics.transition(2)
  rescue Hangup
    pbEmergencySave
    raise
  end
end

def Kernel.pbStartOver(gameover = false)
  pbHealAll()
  if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId >= 0
    Kernel.pbMessage(_INTL("<ac>\\w[]\\wm\\c[8]\\l[3]Defeat is not an option.\\n{1}... Bathe yourself in our light.</ac>", $Trainer.name))
    Kernel.pbCancelVehicles
    pbRemoveDependencies()
    $game_switches[:Starting_Over] = true
    $game_temp.player_new_map_id = 617
    $game_temp.player_new_x = 10
    $game_temp.player_new_y = 10
    $game_temp.player_new_direction = 1
    clearRaidOutfit(false)
    $scene.transfer_player if $scene.is_a?(Scene_Map)
    for i in 0...$game_screen.pictures.length
      next if !$game_screen.pictures[i]

      $game_screen.pictures[i].erase
    end
    $game_map.refresh
  else
    homedata = $cache.metadata[:home]
    if (homedata && !pbRxdataExists?(sprintf("Data/Map%03d", homedata[0])))
      if $DEBUG
        Kernel.pbMessage(_ISPRINTF("<ac>Can't find the map 'Map{1:03d}' in the Data folder.  The game will resume at the player's position.</ac>", homedata[0]))
      end
      pbHealAll()
      return
    end
    Kernel.pbMessage(_INTL("<ac>\\w[]\\wm\\l[3]Defeat is not an option. {1}... Bathe yourself in our light.</ac>", $Trainer.name))
    if homedata
      Kernel.pbCancelVehicles
      pbRemoveDependencies()
      $game_switches[:Starting_Over] = true
      $game_temp.player_new_map_id = 617
      $game_temp.player_new_x = 10
      $game_temp.player_new_y = 10
      $game_temp.player_new_direction = 1
      clearRaidOutfit(false)
      $scene.transfer_player if $scene.is_a?(Scene_Map)
      for i in 0...$game_screen.pictures.length
        next if !$game_screen.pictures[i]

        $game_screen.pictures[i].erase
      end
      $game_map.refresh
    else
      for i in 0...$game_screen.pictures.length
        next if !$game_screen.pictures[i]

        $game_screen.pictures[i].erase
      end
      $game_map.refresh
      pbHealAll()
    end
  end
  pbEraseEscapePoint
end

class PokemonGlobalMetadata
  def pokedexData
    initializePokedexData if !@pokedexData || @pokedexData.length != $cache.pokedexes.length
    return @pokedexData if $game_switches.nil? || $game_switches[:NotPlayerCharacter] || $Trainer.badges.nil?
    # fix this later stupid head, one of these two aren't initialized and I don't want to shove a & in there.
    @pokedexData[1][:unlocked] = true
    @pokedexData[2][:unlocked] = $PokemonGlobal.visitedMaps[207] || $Trainer.badges[4] # Terajuma Shipyard
    @pokedexData[3][:unlocked] = $PokemonGlobal.visitedMaps[350] || $Trainer.badges[8] # Route 7
    @pokedexData[4][:unlocked] = $PokemonGlobal.visitedMaps[516] || $Trainer.badges[11] # Sashila Village
    return @pokedexData
  end
end

alias __core_getPlayerCharset pbGetPlayerCharset unless defined?(__core_getPlayerCharset)
def pbGetPlayerCharset(graphic, trainer = nil)
  outfit = trainer ? trainer.outfit : $Trainer ? $Trainer.outfit : 0
  skip = $game_switches != nil && $game_switches[:NotPlayerCharacter]
  if outfit == 8
    ret = "Arc_Player_Full"
    ret += "_run" if graphic == :run
    ret += "_surf" if graphic == :surf
    ret += "_fish_offset" if graphic == :fishing
    ret += "_fishsurf" if graphic == :fishsurf
  elsif outfit == 10 && !skip
    ret = "object_gymunit_playerreticle"
    ret += "_run" if graphic == :run
    ret += "_surf" if graphic == :surf
  elsif outfit == 11
    ret = "object_gymunit_general"
    ret += "_run" if graphic == :run
    ret += "_surf" if graphic == :surf
  elsif outfit == 12
    ret = "NPC_Lorna"
    ret += "_run" if graphic == :run
    ret += "_surf" if graphic == :surf
  elsif outfit == 100
    ret = "NPC_Past_Lady"
    ret += "_run" if graphic == :run
    ret += "_surf" if graphic == :surf
  else
    ret = __core_getPlayerCharset(graphic, trainer)
  end
  return ret
end

alias __core_playerSprite pbPlayerSpriteFile unless defined?(__core_playerSprite)
def pbPlayerSpriteFile(type)
  if $Trainer&.trainertype == type
    if $cache.trainertypes[type].checkFlag?(:player)
      case $Trainer.outfit
        when 8 then return "Graphics/Characters/trainer263"
        when 10, 11 then return "Graphics/Characters/trainer263_1"
      end
    end
  end
  return __core_playerSprite(type)
end

alias __core_trainerSprite pbTrainerSpriteFile unless defined?(__core_trainerSprite)
def pbTrainerSpriteFile(type, outfit = 0)
  if $Trainer&.trainertype == type
    if $cache.trainertypes[type].checkFlag?(:player) && $Trainer.outfit == 8
      return "Graphics/Characters/trainer263"
    end
  end
  return __core_trainerSprite(type, outfit)
end

alias __core_playerBackSprite pbPlayerSpriteBackFile unless defined?(__core_playerBackSprite)
def pbPlayerSpriteBackFile(type)
  if $Trainer&.trainertype == type
    if $cache.trainertypes[type].checkFlag?(:player)
      case $Trainer.outfit
        when 8 then return "Graphics/Characters/trback263"
        when 10, 11 then return "Graphics/Characters/trback263_1"
      end
    end
  end
  return __core_playerBackSprite(type)
end

alias __core_trainerBackSprite pbTrainerSpriteBackFile unless defined?(__core_trainerBackSprite)
def pbTrainerSpriteBackFile(type)
  if $Trainer&.trainertype == type
    if $cache.trainertypes[type].checkFlag?(:player) && $Trainer.outfit == 8
      return "Graphics/Characters/trback263"
    end
  end
  return __core_trainerBackSprite(type)
end

class PokeBattle_Trainer
  def outfit=(value)
    @outfit = value
    Kernel.pbUpdateVehicle
  end
end

def namesRoulette
  if $game_variables[930].is_a?(Array)
    returnvar = NamesArray - $game_variables[930]
    returnvar = returnvar.sample
    if returnvar == nil
      returnvar = NamesArray.sample
    else
      $game_variables[930].push(returnvar)
    end
  else
    returnvar = NamesArray.sample
    $game_variables[930] = [returnvar]
  end
  return returnvar
end

def zygardeBecomeSnake
  pokemonlist = searchPokemon(species: :ZYGARDE)
  return false if pokemonlist.empty?
  for mon in pokemonlist
    mon.form = 0
    mon.level = 100
    mon.ability = :AURABREAK
    mon.pbLearnMove(:THOUSANDARROWS)
    mon.pbLearnMove(:THOUSANDWAVES)
    mon.pbLearnMove(:EXTREMESPEED)
    mon.pbLearnMove(:DRAGONDANCE)
    mon.pbRecordFirstMoves
    mon.iv = Array.new(6, 31)
    mon.calcStats
  end
  return true
end

def endOfNight(name)
  return unless KNOWN_TRAINERS.keys.include?(name)
  trainerid = KNOWN_TRAINERS[name]
  # search all pokemon in the player's possesion for pokemon with the characters original trainer ID
  pokemonlist = searchPokemon(originalTrainerID: trainerid)
  for mon in pokemonlist
    next if mon.ot != name
    mon.fakeOT = true # scramble OT name
    mon.personalID = mon.personalID.to_s # scramble OT TrainerID
  end
end

def manipCatchDate(time)
  time = Time.new(time.year - 40, time.month, time.day, time.hour, time.min, time.sec) if inPast?
  time = time.getgm.to_i
  time = :Glitched if [389, 390, 391, 392, 397].include?($game_map.map_id)
  return time
end

def pbCatchTime
  return :Glitched if [389, 390, 391, 392, 397].include?($game_map.map_id)
  time = pbGetTimeNow
  time = Time.new(time.year - 40, time.month, time.day, time.hour, time.min, time.sec) if inPast?
  return time.getgm.to_i
end

def depositPrizes(prizes = $Trainer.party, clearItems: true, clearParty: false)
  prizes.each { |o|
    prize = o.dup
    prize.pbRecordFirstMoves
    prize.item = nil if clearItems
    $PokemonStorage.pbStoreCaught(prize)
    # This needs to be run before leaveField to register the current form of the pokemon
    # Any form the pokemon reverts to will be registered in pbBattleStorePokemon
    $Trainer.pokedex.setOwned(prize)
  }
  $Trainer.party = [] if clearParty
end

class PokemonLoad
  unless @rejuvLoadAliases
    alias __rejuv_loadSavedMap loadSavedMap
    @rejuvLoadAliases = true
  end

  def loadSavedMap
    ret = __rejuv_loadSavedMap
    return ret if ret == :forceload

    if $game_variables[974] == 3 && [678, 679].include?(@currentsave[:map_id])
      $game_variables[974] = 4
      $game_system.newInterp
      $MapFactory.setup(@currentsave[:map_id], true)
      return :ch16quickload
    end

    return ret
  end
end

alias __rejuv_forceLoadMap forceLoadMapConditions? unless defined?(__rejuv_forceLoadMap)
def forceLoadMapConditions?(mapid = nil)
  ret = __rejuv_forceLoadMap(mapid)
  return true if $game_variables[810] <= 56 && mapid == 629 # Theolian Tunnels chase segment
  return true if $game_variables[812] <= 51 && mapid == 666 # Risa Raider's Farewell Concert
  return ret
end

alias __rejuv_forceFixZygarde forceAuraBreakZygarde unless defined?(__rejuv_forceFixZygarde)
def forceAuraBreakZygarde
  return true
end

def refreshLevelCaps
  # level caps
  base = [18, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 85, 90, 90, 100, 100]
  atebit = [30, 40, 50]

  # set level caps based on switches
  const = base
  if $game_switches[:AngelicaTower]
    const = atebit
  end
  Object.send(:remove_const, :LEVELCAPS)
  Object.const_set(:LEVELCAPS, const)
end

def gameSetup()
  # Enable zoom if game was saved with zoom
  if $game_system.background_zoom != nil
    goal = $game_system.background_zoom[0]
    speed = 99
    pbZoomMap(goal, speed)
  end

  # Ensure levelcaps are properly loaded
  refreshLevelCaps

  # Start blessing overlay
  if !$game_screen.showingBlessings.nil?
    startBlessingOverlay($game_screen.showingBlessings)
  end

  # Ch16.3 quick reset work arounds
  if $game_map.map_id == 560
    if $game_map.events[83]&.x == 39
      $game_map.events[83].moveto(49,28)
    end
  end
  if $game_variables[974] == 4
    if $game_map.map_id == 678
      pbBGMPlay("Battle - Thorned Crown For a Prince")
    end
    if $game_map.map_id == 679
      pbSEPlay("SFX - Karma")
    end
  end

  # Mr Luck load shenanigans
  if $game_variables[:ItsALuckyNumber] == 3
    $game_variables[:ItsALuckyNumber] = 4
    $game_map.need_refresh = true
    $game_screen.tone.red = -255
    $game_screen.tone.blue = -255
    $game_screen.tone.green = -255
    $game_screen.tone.gray = 0
    $game_mute = true
  end

  if $game_variables[:BethQuest] == 17
    pbBGMPlay("Music - Route 3")
    $game_variables[:BethQuest] = 18
    if $game_screen.pictures[1]
      $game_screen.pictures[1].erase
    end
    pbZoomMap(1,1)
    $game_map.need_refresh = true
    $game_screen.tone.red = 0
    $game_screen.tone.blue = 0
    $game_screen.tone.green = 0
    $game_screen.tone.gray = 0
  end
end

def pbLoadCopiedTrainer(trainerid, trainername, partyid, party)
  opponent = PokeBattle_Trainer.new(trainername, trainerid)
  items = []

  for trainer in $cache.trainers
    next if trainerid != trainer[0] || partyid != trainer[4]

    items = trainer[2].clone
  end
  if $game_switches[:NotPlayerCharacter]
    if trainername == $game_variables[:PlayerNameBackup] && trainerid == :INTERCEPTORARMOR
      interceptmoves = getInterceptMovesFromParty(party)
      party.each_with_index do |mon, index|
        interceptmove = interceptmoves[index]
        next if interceptmove == nil
        mon.zmoves[0] = PBMove.new(interceptmove) if interceptmove == :UNLEASHEDPOWER
        mon.zmoves[1] = PBMove.new(interceptmove) if interceptmove == :BLINDINGSPEED
        mon.zmoves[2] = PBMove.new(interceptmove) if [:CHTHONICMALADY, :ELYSIANSHIELD].include?(interceptmove)
      end
    end
  end
  return [opponent, items, party]
end

# copied from Reborn
def copyTrainerTeam()
  copied_team = []
  $Trainer.party.each { |mon|
    next if mon.isEgg?

    copy = PokeBattle_Pokemon.new(mon.species, mon.level)
    # descriptive data
    copy.personalID = mon.personalID
    copy.trainerID = mon.trainerID
    copy.name = mon.name
    case mon.gender
      when 0 then copy.makeMale
      when 1 then copy.makeFemale
      else copy.makeGenderless
    end
    copy.shinyflag = mon.shinyflag
    copy.form = mon.form
    # EVs,IVs,Nature
    copy.iv.map! { |_| $game_switches[:Empty_Trainer_IVs_Password] ? 0 : 31 }
    copy.ev.map! { |_| $game_switches[:Empty_EVs_Password] ? 0 : ($game_switches[:Flat_EV_Password] ? 85 : 252) }
    copy.ev = mon.ev
    copy.natureflag = mon.natureflag
    # ability, item
    copy.ability = mon.ability
    copy.item = mon.item
    # Moves
    copy.moves = []
    mon.moves.each { |move|
      newmove = PBMove.new(move.move)
      copy.moves.push(newmove)
    }
    copy.zmoves = []
    copy.hptype = mon.hptype
    # other
    copy.happiness = mon.happiness
    copy.calcStats
    copy.heal
    copied_team.push(copy)
  }
  return copied_team
end

def getFastTravelLocations(id)
  choices = {}
  case id
    when 0
      choices.store(0, _INTL("East Gearen City"))
      choices.store(1, _INTL("West Gearen City")) if $game_switches[652]
      choices.store(2, _INTL("Sheridan Village")) if $game_switches[632]
      choices.store(3, _INTL("Goldenleaf Town")) if $game_switches[633]
      choices.store(4, _INTL("Akuwa Town")) if $game_switches[639]
    when 1
      choices.store(0, _INTL("Kakori Village")) if $game_switches[1423]
      choices.store(1, _INTL("Terajuma Beach")) if $game_switches[1422]
      choices.store(2, _INTL("Jynnobi Pass")) if $game_switches[1419]
      choices.store(3, _INTL("Terajuma Jungle")) if $game_switches[1420]
      choices.store(4, _INTL("Mt. Terajuma")) if $game_switches[1421]
      choices.store(5, _INTL("Teila Resort")) if $game_switches[1424]
      choices.store(6, _INTL("Kristiline Town")) if $game_switches[1427]
      choices.store(7, _INTL("Valor Shore")) if $game_switches[1594]
      choices.store(8, _INTL("Helojak Island")) if $game_switches[1425]
      choices.store(9, _INTL("Valor Summit")) if $game_switches[2097] && $game_variables[264] != 3 # not dealing with you
    when 2
      choices.store(0, _INTL("Oceana Pier"))
      choices.store(1, _INTL("Akuwa Town"))
      choices.store(2, _INTL("Terajuma Shipyard"))
      choices.store(3, _INTL("Teila Resort"))
      choices.store(4, _INTL("Kristiline Town")) if $game_switches[10]
      choices.store(5, _INTL("Sashila Village")) if $game_switches[1223]
    when 3
      choices.store(0, _INTL("Yui's Ranch")) if $game_switches[1640]
      choices.store(1, _INTL("Luck's Tent")) if $game_switches[1639]
      choices.store(2, _INTL("Darchlight Woods")) if $game_switches[1641]
      choices.store(3, _INTL("Route 8")) if $game_switches[1653]
      choices.store(4, _INTL("Route 9")) if $game_switches[1654]
      choices.store(5, _INTL("Honec Woods")) if $game_switches[1642]
      choices.store(6, _INTL("Zorrialyn Coast")) if $game_switches[1655]
      choices.store(7, _INTL("Voidal Chasm")) if $game_switches[1656]
      choices.store(8, _INTL("Alamissa Urben")) if $game_switches[1657]
      choices.store(9, _INTL("Zone Zero")) if $game_switches[1658]
      choices.store(10, _INTL("Pyramid Outskirts")) if $game_switches[1660]
    else
  end
  choices.store(-1, _INTL("None"))
  ret = Kernel.pbMessage(_INTL("Available locations."), choices.values, -1)
  ret = -1 if ret == choices.length - 1
  return choices.keys[ret]
end

def depositBlackBoxMon
  $game_variables[:BlackBoxPartyStorage] = [] if !$game_variables[:BlackBoxPartyStorage].is_a?(Array)
  if $Trainer.party.length == 1
    Kernel.pbMessage(_INTL("ERROR: Requires more than 1"))
    return false
  end
  if $game_variables[:BlackBoxPartyStorage].length == 6
    Kernel.pbMessage(_INTL("ERROR: Stored party full."))
    return false
  end
  pbChoosePokemon(1, 2, proc { |mon| mon.species != :ZYGARDE }, false, true)
  return false if $game_variables[1] == -1
  mon = $Trainer.party.delete_at($game_variables[1])
  $Trainer.party.compact!
  $game_variables[:BlackBoxPartyStorage].push(mon)
  Kernel.pbMessage(_INTL("{1} was dematerialized.", mon.name))
  return true
end

def withdrawBlackBoxMon
  $game_variables[:BlackBoxPartyStorage] = [] if !$game_variables[:BlackBoxPartyStorage].is_a?(Array)
  if $game_variables[:BlackBoxPartyStorage].length == 0
    Kernel.pbMessage(_INTL("ERROR: No stored party"))
    return false
  end
  chosen = 0
  pbFadeOutIn(99999) {
    scene = PokemonScreen_Scene.new
    screen = PokemonScreen.new(scene, $game_variables[:BlackBoxPartyStorage])
    screen.pbStartScene(_INTL("Choose a Pokémon."))
    chosen = screen.pbChoosePokemon
    screen.pbEndScene
  }
  mon = $game_variables[:BlackBoxPartyStorage].delete_at(chosen)
  pbAddRentalPokemonSilent(mon)
  Kernel.pbMessage(_INTL("{1} was rematerialized.", mon.name))

  return true
end

class TextLogScene
  unless @rejuvLogAliases
    alias __rejuv_modifyTextForLog modifyTextForLog
    @rejuvLogAliases = true
  end

  def modifyTextForLog(text)
    modifiedText = __rejuv_modifyTextForLog(text)

    # Clear out GSC-style text, does not display nicely in log
    modifiedText.gsub!(/(<fn=PKMN RBYGSC>)(.*?)(<\/fn>)/) { |match|
      next $~[2]
    }

    # Replace color tags for light windowskins with color tags for dark windowskins, since text log always has a dark background
    ColorsUsedInEvents.each { |key| modifiedText.gsub!(AtebitColorTags[key], ColorTags[key]) }
    ColorsUsedInEvents.each { |key| modifiedText.gsub!(ColorTags[:Gray], ColorTags[:Default]) } # Our gray displays badly on textlog background and is usually only used on white backgrounds

    return modifiedText
  end
end

### ATEBIT-ADJACENT SCRIPTS ###
  alias __core_drawFormat drawSingleFormattedChar unless defined?(__core_drawFormat)
  def drawSingleFormattedChar(bitmap, ch)
    if ch[9]
      # remove shadows because they look garbo without them for gsc font
      ch[9] = nil if $game_switches && $game_switches[:AtebitDesire] && isValidForFont
    end
    __core_drawFormat(bitmap, ch)
  end

  class Window_DrawableCommand
    alias __core_getCursorGraphic getCursorGraphic unless method_defined?(:__core_getCursorGraphic)
    def getCursorGraphic
      return "Graphics/Pictures/selarrowdark" if $game_switches && $game_switches[:AtebitDesire] && isValidForFont
      return __core_getCursorGraphic
    end
  end

  class PokemonSaveScene
    def pbStartScreen
      color = $game_switches[:AtebitDesire] ? :Default : TXT_COLOR
      map = $game_switches[:AtebitDesire] ? :Default : TXT_COLOR_MAP
      colors = isCurrentWindowskinDark ? ColorTags : LightColorTags
      colors = AtebitColorTags if $game_switches[:AtebitDesire]
      txt_color, txt_color_map = colors[color], colors[map]
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @sprites = {}
      totalsec = Graphics.time_passed / 40 + (Process.clock_gettime(Process::CLOCK_MONOTONIC) - Graphics.start_playing).to_i
      hour = totalsec / 60 / 60
      min = totalsec / 60 % 60
      mapname = pbGetMessageFromHash(:MapNames, $cache.mapinfos[$game_map.map_id].name)
      mapstr = "<ac>{1}{2}</c3></ac>"
      tts(mapname)
      playerStr = _INTL("Player")
      legendStr = _INTL("Legendaries")
      badgeStr = _INTL("Badges")
      dexStr = _INTL("Pokédex")
      timeStr = _INTL("Time")
      hourStr = _INTL("h")
      minStr = _INTL("m")
      saveStr = _INTL("Save File")
      if $game_switches[:AtebitDesire]
        mapname = mapname.upcase
        playerStr = txt_color + playerStr.upcase + "</c3>"
        legendStr = txt_color + legendStr.upcase + "</c3>"
        badgeStr = txt_color + badgeStr.upcase + "</c3>"
        dexStr = txt_color + _INTL("DEX") + "</c3>"
        timeStr = txt_color + timeStr.upcase + "</c3>"
        hourStr = txt_color + hourStr.upcase + "</c3>"
        minStr = txt_color + minStr.upcase + "</c3>"
        saveStr = txt_color + saveStr.upcase + "</c3>"
      end
      loctext = _INTL(mapstr, txt_color_map, mapname)
      loctext += _INTL("{3}<r>{1}{2}</c3><br>", txt_color, $Trainer.name, playerStr)
      tts($Trainer.name)
      unless $game_switches[:NotPlayerCharacter]
        postgameCounter = Reborn ? $game_variables[569] : 0
        if postgameCounter > 0
          loctext += _INTL("{3}<r>{1}{2}</c3><br>", txt_color, postgameCounter, legendStr)
          tts("#{postgameCounter} legendaries")
        else
          loctext += _INTL("{3}<r>{1}{2}</c3><br>", txt_color, $Trainer.numbadges, badgeStr)
          tts("#{$Trainer.numbadges} badges")
        end
      end
      if $Trainer.pokedex.canViewDex
        loctext += _INTL("{4}<r>{1}{2}/{3}</c3><br>", txt_color, $Trainer.pokedex.getOwnedCount, $Trainer.pokedex.getSeenCount, dexStr)
        tts("Pokédex: owned #{$Trainer.pokedex.getOwnedCount} / seen #{$Trainer.pokedex.getSeenCount}")
      end
      if hour > 0
        loctext += _ISPRINTF("{4:s}<r>{1:s}{2:02d}{5:s} {3:02d}{6:s}</c3><br>", txt_color, hour, min, timeStr, hourStr, minStr)
        tts("Time: #{hour} hours, #{min} minutes")
      else
        loctext += _ISPRINTF("{3:s}<r>{1:s}{2:02d}{4:s}</c3><br>", txt_color, min, timeStr, minStr)
        tts("Time: #{min} minutes")
      end
      if $Unidata[:saveslot] > 1
        loctext += _INTL("{3}<r>{1}{2}</c3><br>", txt_color, $Unidata[:saveslot], saveStr)
        tts("Save File: #{$Unidata[:saveslot]}")
      else
        loctext += _INTL("{2}<r>{1}1</c3><br>", txt_color, saveStr)
        tts("Save File: 1")
      end
      $game_temp.save_window = Window_AdvancedTextPokemon.new(loctext)
      @sprites["locwindow"] = $game_temp.save_window
      @sprites["locwindow"].setSkin("Graphics/Windowskins/choice 34") if $game_switches[:AtebitDesire]
      @sprites["locwindow"].viewport = @viewport
      @sprites["locwindow"].x = 0
      @sprites["locwindow"].y = 0
      @sprites["locwindow"].width = 228 if @sprites["locwindow"].width < 228
      @sprites["locwindow"].visible = true
    end

    def pbEndScreen
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
      $game_temp.save_window = nil
    end
  end

  class Game_Map
    ATEBITMAPS = [
      293, 340, 366, 379, 394, 460, 521, 673, 642
    ]

    unless @atebitAliases
      alias :__atebit_setup :setup
      @atebitAliases = true
    end

    def setup(*args)
      __atebit_setup(*args)
      $game_switches[:AtebitDesire] = ATEBITMAPS.include?(args[0]) if $game_switches
    end
  end

  module TextPlaceholders
    GSCNum = "\u0080"
    GSCLevel = "\u0081"
    GSCPBold = "\u0082"
    GSCPP = "\u0082\u0082"
    GSCID = "\u0083"
    GSCEnby = "\u26a5"
  end

  # Azery's bullshit down from here

  class PokemonTrainerCardSceneGBC
    BASE_COLOR = Color.new(0, 0, 0)

    # [label x, label y, x, y]
    ID_POS = [135, 112, 302, 112]
    NAME_POS = [135, 76, 281, 76]
    MONEY_POS = [135, 142, 342, 142]
    TRAINER_OFFSET = [128, 148]

    CHAR_X_BASE = 114
    CHAR_Y_BASE = 108
    PARTY_X_BASE = 100
    PARTY_Y_BASE = 52
    PARTY_Y_OFFSET = 34
    ARROW_OFFSET = 12
    WINDOW_X = 96
    WINDOW_WIDTH = 320
    WINDOW_Y = 48
    WINDOW_HEIGHT = 288

    # [starting x, starting y, offset]
    STARS_POS = [30, 54, 34]
    USE_ICONS = true
    FONT = "PKMN RBYGSC"
    PATH = "Graphics/Pictures/Trainer Card/johto/"
    attr_accessor :pagenumber
    attr_accessor :trainerParty

    def update
      pbUpdateSpriteHash(@sprites)
    end

    def initialize
      @pagenumber = 0
      if $game_variables[:VirtualLeagueProgress] > 1
        teamid = (($game_variables[:VirtualLeagueStarter] - 1) * 10) + ($game_variables[:VirtualLeagueProgress] - 1)
        trainerinfo = pbLoadTrainer(:JOHTO_0M, "Ethan", teamid, noscaling: true, knownID: true)
        @trainerParty = trainerinfo[2] if trainerinfo
      end
    end

    def pbStartScene
      @oldswitch = $game_switches[:AtebitDesire]
      $game_switches[:AtebitDesire] = true
      @sprites = {}
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      case $game_variables[:VirtualGender]
      when 1
        gender = "m"
        virtualTrainer = :JOHTO_0M
        @playerGender = "♂"
        @name = "Ethan"
      when 2
        gender = "f"
        virtualTrainer = :JOHTO_0F
        @playerGender = "♀"
        @name = "Kris"
      when 3
        gender = "n"
        virtualTrainer = :JOHTO_0NB
        @playerGender = TextPlaceholders::GSCEnby
        @name = "Silus"
      end
      @name = $game_variables[:VirtualName] if $game_variables[:VirtualName] != 0
      addBackgroundPlane(@sprites, "bg", "trainercardbg", @viewport)
      partycard = pbResolveBitmap(sprintf(PATH + "trainercard_party"))
      @sprites["card"] = IconSprite.new(0, 0, @viewport)
      @sprites["partycard"] = IconSprite.new(0, 0, @viewport)
      @sprites["card"].setBitmap(PATH + "trainercard_#{gender}")

      if partycard
        @sprites["partycard"].setBitmap(PATH + "trainercard_party")
        @sprites["partycard"].visible = false
      end
      @sprites["summarycard"] = IconSprite.new(WINDOW_X, WINDOW_Y, @viewport)

      if Rejuv
        @sprites["trainer"] = IconSprite.new(336, 100, @viewport)
      else
        @sprites["trainer"] = IconSprite.new(336, 112, @viewport)
      end
      @sprites["pokemon"] = PokemonSprite.new(@viewport)
      @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)


      @sprites["trainer"].setBitmap(pbPlayerSpriteFile(virtualTrainer))
      @sprites["trainer"].x = 280
      @sprites["trainer"].y = 0
      @sprites["trainer"].z = 2
      @sprites["overlay"].bitmap.font.name = FONT
      @sprites["overlay"].bitmap.font.size = getSystemFontSize(FONT)
      pbDrawTrainerCardFront
      pbFadeInAndShow(@sprites) { update }
    end

    def pbDrawTrainerCardBack
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      textPositions = []
      if @trainerParty
        for i in 0...@trainerParty.length
          @sprites["party#{i}"] = PokemonIconSprite.new(@trainerParty[i], @viewport, vleague: true)
          @sprites["party#{i}"].z = 99999
          @sprites["party#{i}"].x = PARTY_X_BASE
          @sprites["party#{i}"].y = PARTY_Y_BASE + PARTY_Y_OFFSET * (i)
          if @trainerParty[i].item
            @sprites["party#{i}Item"] = IconSprite.new(PARTY_X_BASE, PARTY_Y_BASE + PARTY_Y_OFFSET * (i), @viewport)
            @sprites["party#{i}Item"].setBitmap(PATH + "item")
            @sprites["party#{i}Item"].z = 99999
          end
          @sprites["party_hpbar#{i}"] = IconSprite.new(276, (76 + PARTY_Y_OFFSET * (i)), @viewport)
          @sprites["party_hpbar#{i}"].setBitmap(PATH + "partyHPBar")
          textPositions.concat([
          [_INTL("{1}", getMonName(@trainerParty[i].species).upcase), 144, (60 + PARTY_Y_OFFSET * (i)), :left, BASE_COLOR],
          [_INTL("{2}{1}", @trainerParty[i].level, @trainerParty[i].level >= 100 ? "" : TextPlaceholders::GSCLevel), 224, (74 + PARTY_Y_OFFSET * (i)), :left, BASE_COLOR],
          [_ISPRINTF("{1:3d}/{2:3d}", @trainerParty[i].hp, @trainerParty[i].totalhp), WINDOW_WIDTH + WINDOW_X, (58 + PARTY_Y_OFFSET * (i)), :right, BASE_COLOR],
          ])
        end
      end
      textPositions.concat([
        [_INTL("CANCEL"), 114, 56 + PARTY_Y_OFFSET * 6, :left, BASE_COLOR],
        [_INTL("VIRTUAL LEAGUE"), Graphics.width / 2, 296, :center, BASE_COLOR],
      ])
      pbDrawTextPositions(overlay, textPositions)
      @index = 0
      @sprites["arrow"] = IconSprite.new(96, 0, @viewport)
      @sprites["arrow"].setBitmap(PATH + "selarrow")
      @sprites["arrow"].z = 99999
      changeIndexParty(0)
    end

    def pbDrawTrainerCardFront
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      @sprites["card"].visible = true
      @sprites["partycard"].visible = false
      totalsec = Graphics.time_passed / 40 + (Process.clock_gettime(Process::CLOCK_MONOTONIC) - Graphics.start_playing).to_i
      hour = totalsec / 60 / 60
      min = totalsec / 60 % 60
      time = _ISPRINTF("{1:02d}:{2:02d}", hour, min)
      $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
      pubid = sprintf("%05d", $Trainer.publicID($Trainer.id))
      ownedCount = $game_switches[:NotPlayerCharacter] ? "???" : $Trainer.pokedex.getOwnedCount
      seenCount = $game_switches[:NotPlayerCharacter] ? "???" : $Trainer.pokedex.getSeenCount
      money = $game_switches[:NotPlayerCharacter] ? "???" : getCurrencyShorthand(:Money) + $Trainer.money.to_s
      textPositions = [
        [_INTL("NAME/{1}", @name), NAME_POS[0], NAME_POS[1], :left, BASE_COLOR],
        [_INTL("#{TextPlaceholders::GSCID + TextPlaceholders::GSCNum}.{1}", pubid), ID_POS[0], ID_POS[1], :left, BASE_COLOR],
        [_INTL("MONEY"), MONEY_POS[0], MONEY_POS[1], :left, BASE_COLOR],
        [money, MONEY_POS[2], MONEY_POS[3], :right, BASE_COLOR],
      ]

      pbDrawTextPositions(overlay, textPositions)
      return if $game_switches[:NotPlayerCharacter]

      badges = [$game_switches[:VirtualGym1], $game_switches[:VirtualGym2], $game_switches[:VirtualGym3],
      $game_switches[:VirtualGym4], $game_switches[:VirtualGym5], $game_switches[:VirtualGym6], $game_switches[:VirtualGym7],
      $game_switches[:VirtualGym8]]

      y = 222
      imagePositions = []
      for region in 0...2 # Two rows
        x = 130
        for i in 0...4
          if badges[i + region * 4]
            imagePositions.push([PATH + "/badges", x, y, i * 32, region * 32, 32, 32])
          end
          x += 64
        end
        y += 50
      end
      pbDrawImagePositions(overlay, imagePositions)
    end

    def drawSummaryHeader
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      @pokemon = @trainerParty[@index]
      @sprites["hpbar"]&.dispose
      case @summaryPage
        when 0
          drawSummaryInfo
        when 1
          drawSummaryMoves
        when 2
          drawSummaryStats
      end
      @sprites["summarycard"].visible = true
      @sprites["pokemon"].visible = true
      @sprites["pokemon"].setPokemonBitmap(@pokemon) if @pokemonIndex != @index
      @sprites["pokemon"].setBitmap(changeCanvasSize(@sprites["pokemon"].bitmap, 124))
      @sprites["pokemon"].x = WINDOW_X
      @sprites["pokemon"].y = WINDOW_Y
      @pokemonIndex = @index

      gendermark = @pokemon.gender == :M ? "♂" : "♀"
      gendermark = "" if @pokemon.gender == :N
      textpos = [
        [
          _ISPRINTF("#{TextPlaceholders::GSCNum}.{1:03d} #{TextPlaceholders::GSCLevel}{2:-3d}{3:s}",
          @pokemon.dexnum, @pokemon.level, gendermark), 128 + WINDOW_X, WINDOW_Y - 2, :left, BASE_COLOR
        ],
        [@pokemon.name, 128 + WINDOW_X, WINDOW_Y + 30, :left, BASE_COLOR],
        ["/" + getMonName(@pokemon.species).upcase, 128 + WINDOW_X + 16, WINDOW_Y + 62, :left, BASE_COLOR],
      ]

      pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    end

    def drawSummaryInfo
      @sprites["summarycard"].setBitmap(PATH + "summaryInfo")

      leftOffsetX = 128
      rightX = 160
      y = 142
      charspace = 16
      @sprites["hpbar"] = IconSprite.new(WINDOW_X, WINDOW_Y + y + 2, @viewport)
      @sprites["hpbar"].setBitmap(PATH + "partyHPBar")
      @sprites["hpbar"].visible = true
      textpos = []
      textpos.push([_INTL("EXP POINTS"), rightX, y, :left, BASE_COLOR])

      y += charspace
      textpos.push([_ISPRINTF("{1:3d}/{1:3d}", @pokemon.hp), leftOffsetX, y, :right, BASE_COLOR])
      textpos.push([_INTL("{1}", @pokemon.exp), WINDOW_WIDTH, y, :right, BASE_COLOR])

      y += charspace * 2
      textpos.push([_INTL("STATUS/"), 0, y, :left, BASE_COLOR])
      textpos.push([_INTL("LEVEL UP"), rightX, y, :left, BASE_COLOR])

      y += charspace
      textpos.push([_INTL("OK"), leftOffsetX, y, :right, BASE_COLOR])
      endexp = PBExp.startExperience(@pokemon.level + 1, @pokemon.growthrate)
      textpos.push([_INTL("{1}", endexp - @pokemon.exp), WINDOW_WIDTH, y, :right, BASE_COLOR])

      y += charspace
      textpos.push([_INTL("TYPE/"), 0, y, :left, BASE_COLOR])
      textpos.push([_INTL("TO #{TextPlaceholders::GSCLevel}{1}", @pokemon.level + 1), WINDOW_WIDTH, y, :right, BASE_COLOR])

      y += charspace
      textpos.push([getTypeName(@pokemon.type1).upcase, charspace, y, :left, BASE_COLOR])

      y += charspace
      textpos.push([getTypeName(@pokemon.type2).upcase, charspace, y, :left, BASE_COLOR]) if @pokemon.type2

      textpos.each { |text| text[1] += WINDOW_X; text[2] += WINDOW_Y }
      pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    end

    def drawSummaryMoves
      @sprites["summarycard"].setBitmap(PATH + "summaryMoves")

      rightX = 130
      y = 126
      charspace = 16

      textpos = []
      itemtext = @pokemon.item ? getItemName(@pokemon.item).upcase : "---"
      itemtext = @pokemon.item.to_s if rightX + WINDOW_X + itemtext.length * charspace > WINDOW_WIDTH + WINDOW_X
      textpos.push([_INTL("ITEM"), 0, y, :left, BASE_COLOR])
      textpos.push([itemtext, rightX, y, :left, BASE_COLOR])

      y += charspace * 2
      textpos.push([_INTL("MOVE"), 0, y, :left, BASE_COLOR])

      @pokemon.moves.each { |m|
        movename = getMoveName(m.move).upcase
        movename = m.move.to_s if rightX + WINDOW_X + movename.length * charspace > WINDOW_WIDTH + WINDOW_X
        textpos.push([movename, rightX, y, :left, BASE_COLOR])
        y += charspace
        textpos.push([_ISPRINTF("#{TextPlaceholders::GSCPP} {1:2d}/{2:2d}", m.pp, m.maxpp), WINDOW_WIDTH, y, :right, BASE_COLOR])
        y += charspace
      }


      textpos.each { |text| text[1] += WINDOW_X; text[2] += WINDOW_Y }
      pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    end

    def drawSummaryStats
      @sprites["summarycard"].setBitmap(PATH + "summaryStats")

      rightX = 176
      y = 126
      charspace = 16

      textpos = []
      textpos.push([_INTL("ATTACK"), rightX, y, :left, BASE_COLOR])

      y += charspace
      textpos.push([_INTL(TextPlaceholders::GSCID + TextPlaceholders::GSCNum + "."), 0, y, :left, BASE_COLOR])
      textpos.push([@pokemon.attack.to_s, WINDOW_WIDTH, y, :right, BASE_COLOR])

      y += charspace
      textpos.push([_ISPRINTF("{1:5d}", @pokemon.publicID), 32, y, :left, BASE_COLOR])
      textpos.push([_INTL("DEFENSE"), rightX, y, :left, BASE_COLOR])

      y += charspace
      textpos.push([@pokemon.defense.to_s, WINDOW_WIDTH, y, :right, BASE_COLOR])

      y += charspace
      textpos.push([_INTL("OT/"), 0, y, :left, BASE_COLOR])
      textpos.push([_INTL("SPECIAL"), rightX, y, :left, BASE_COLOR])

      y += charspace
      textpos.push([@name, 32, y, :left, BASE_COLOR])
      textpos.push([@playerGender, rightX - 16, y, :right, BASE_COLOR])

      stat = [@pokemon.spatk, @pokemon.spdef].max
      textpos.push([stat.to_s, WINDOW_WIDTH, y, :right, BASE_COLOR])

      y += charspace
      textpos.push([_INTL("SPEED"), rightX, y, :left, BASE_COLOR])

      y += charspace
      textpos.push([@pokemon.speed.to_s, WINDOW_WIDTH, y, :right, BASE_COLOR])

      textpos.each { |text| text[1] += WINDOW_X; text[2] += WINDOW_Y }
      pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    end

    def pbTrainerCard
      loop do
        Graphics.update
        Input.update
        self.update
        oldpage = @pagenumber
        if @pagenumber == 0
          updateBadgePage
        elsif @pagenumber == 1
          updatePartyPage
          break if @index == 6 && Input.trigger?(Input::C)
        else
          updateSummaryPage
        end
        break if Input.trigger?(Input::B) && oldpage != 2
      end
    end

    def updateBadgePage
      return if $game_variables[:VirtualLeagueProgress] <= 1
      if Input.trigger?(Input::C) || Input.trigger?(Input::A) || Input.trigger?(Input::RIGHT) || Input.trigger?(Input::LEFT)
        pbPlayDecisionSE()
        @pagenumber = (@pagenumber + 1) % 2
        @sprites["card"].visible = false
        @sprites["partycard"].visible = true
        @sprites["trainer"].visible = false
        pbDrawTrainerCardBack
      end
    end

    def updatePartyPage
      viewSummary = Input.trigger?(Input::C) && @trainerParty[@index]
      if Input.trigger?(Input::A) || Input.trigger?(Input::RIGHT) || Input.trigger?(Input::LEFT) || viewSummary
        pbPlayDecisionSE()
        if @trainerParty
          for i in 0...@trainerParty.length
            @sprites["party#{i}"].dispose
            @sprites["party#{i}Item"]&.dispose
            @sprites["party_hpbar#{i}"].dispose
            @sprites["arrow"].dispose
          end
        end
        if viewSummary
          @pagenumber = 2
          @summaryPage = 0
          drawSummaryHeader
        else
          @pagenumber = (@pagenumber + 1) % 2
          @sprites["card"].visible = true
          @sprites["partycard"].visible = false
          @sprites["trainer"].visible = true
          @index = 0
          pbDrawTrainerCardFront
        end
      end
      if Input.trigger?(Input::UP)
        changeIndexParty(-1)
      end
      if Input.trigger?(Input::DOWN)
        changeIndexParty(1)
      end
    end

    def updateSummaryPage
      if Input.trigger?(Input::UP)
        changeIndexSummary(-1)
      end
      if Input.trigger?(Input::DOWN)
        changeIndexSummary(1)
      end
      if Input.trigger?(Input::LEFT)
        changePageSummary(-1)
      end
      if Input.trigger?(Input::RIGHT)
        changePageSummary(1)
      end
      if Input.trigger?(Input::B)
        case @summaryPage
          when 1
          when 2
          else
            @sprites["hpbar"].dispose
        end
        @pagenumber = 1
        @sprites["partycard"].visible = true
        @sprites["summarycard"].visible = false
        @sprites["pokemon"].visible = false
        pbDrawTrainerCardBack
      end
    end

    def changeIndexParty(increment)
      loop {
        @index += increment
        if @index > 6
          @index = 0
        end
        if @index < 0
          @index = 6
        end
        break if @index == 6 || @trainerParty&.dig(@index)
      }
      pbPlayDecisionSE()
      @sprites["arrow"].y = 56 + PARTY_Y_OFFSET * @index
      @sprites["arrow"].y -= 6 if @index == 6
      for i in 0...@trainerParty.length
        if i == @index
          @sprites["party#{i}"].x += ARROW_OFFSET
          @sprites["party#{i}Item"]&.x += ARROW_OFFSET
        else
          @sprites["party#{i}"].x = PARTY_X_BASE
          @sprites["party#{i}Item"]&.x = PARTY_X_BASE
        end
      end
    end

    def changeIndexSummary(increment)
      loop {
        @index += increment
        if @index > 5
          @index = 0
        end
        if @index < 0
          @index = 5
        end
        break if @trainerParty&.dig(@index)
      }
      pbPlayDecisionSE()
      drawSummaryHeader
    end

    def changePageSummary(increment)
      @summaryPage = (@summaryPage + increment) % 3
      pbPlayDecisionSE
      drawSummaryHeader
    end

    def pbEndScene
      pbFadeOutAndHide(@sprites) { update }
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
      $game_switches[:AtebitDesire] = @oldswitch
    end
  end

  class Window_AdvancedTextPokemon
    unless @atebitAliases
      alias __atebit_pause allocPause
      alias __atebit_moveCursor moveCursor
      @atebitAliases = true
    end

    def allocPause(sprite = "Graphics/Pictures/pause")
      if $game_switches && $game_switches[:AtebitDesire] && !$game_temp&.in_battle
        if !@pausesprite
          @pausesprite = AnimatedSprite.create("Graphics/Pictures/pause_gsc", 4, 6)
          @pausesprite.z = 100000
          @pausesprite.visible = false
        end
      else
        __atebit_pause(sprite)
      end
    end

    def moveCursor
      if $game_switches && $game_switches[:AtebitDesire] && !$game_temp&.in_battle
        if @pausesprite
          cursor = @cursorMode
          cursor = 2 if cursor == 0 && !@endOfText
          case cursor
            when 0 # End of text
              @pausesprite.x = self.x + self.startX + @endOfText.x + @endOfText.width - 2
              @pausesprite.y = self.y + self.startY + @endOfText.y - @scrollY
            when 1 # Lower right
              pauseWidth = @pausesprite.bitmap ? @pausesprite.framewidth : 16
              pauseHeight = @pausesprite.bitmap ? @pausesprite.frameheight : 16
              @pausesprite.x = self.x + self.width - (pauseWidth * 2)
              @pausesprite.y = self.y + self.height - pauseHeight
            when 2 # Lower middle
              pauseWidth = @pausesprite.bitmap ? @pausesprite.framewidth : 16
              pauseHeight = @pausesprite.bitmap ? @pausesprite.frameheight : 16
              @pausesprite.x = self.x + (self.width / 2) - (pauseWidth / 2)
              @pausesprite.y = self.y + self.height - (18 * 2) + (pauseHeight / 2)
          end
        end
      else
        __atebit_moveCursor
      end
    end
  end
###############################


# Used both in-battle and in-event
def getInterceptMovesFromParty(party)
  moves = Array.new(party.length, nil)
  # Route Specific Move
  moves[-1] = $game_variables[910] > 0 ? :CHTHONICMALADY : :ELYSIANSHIELD
  # Blinding Speed
  blinding_speed = party.sort_by.with_index { |mon, i| [moves[i].nil? ? 0 : 1, ![0, 1].include?(i) ? 0 : 1, mon.speed ? 0 : 1, mon.item == :CHOICESCARF ? 0 : 1, [:TIMID, :JOLLY, :NAIVE, :HASTY].include?(mon.nature) ? 0 : 1] }.first
  # Unleashed Power
  unleashed_power = party.sort_by.with_index { |mon, i| [moves[i].nil? ? 0 : 1, [mon.attack, mon.spatk].max ? 0 : 1, [:ADAMANT, :MODEST, :QUIET, :BRAVE].include?(mon.nature) ? 0 : 1] }.first
  moves[party.index(blinding_speed)] = :BLINDINGSPEED if moves[party.index(blinding_speed)].nil?
  moves[party.index(unleashed_power)] = :UNLEASHEDPOWER if moves[party.index(unleashed_power)].nil?
  return moves
end

class PokemonLoadPanel
  LOADINFO_OFFSET = [230, 112, 32]
end

class PokemonPokedexScene
  DEXNAME_Y = -18
  DEX_ENTRY_OFFSET = [42, 240, Graphics.width - (42 * 2)]

  POKEDEX_COORDS_DIMENSIONS = [214, 18, 280, 332]
  SEARCH_COORDS_DIMENSIONS = [-8, 32, 284, 352]

  SearchColor1 = ColorTags[:Gray2]
  SearchColor2 = ColorTags[:Blue2]
end

class Window_Pokedex < Window_DrawableCommand
  def drawItem(index, count, rect)
    return if index >= self.top_row + self.page_item_max

    rect = drawCursor(index, rect)
    num = @commands[index][5]
    species = @commands[index][0]
    form = @commands[index][-1]
    text = getSpeciesNumWithZeroes(num) + "  "
    # Seen/Owned icon before species number and name should be based only on species (and not on form) for national dex, to match the displayed total seen/owned counts
    consider_only_species = $PokemonGlobal.pokedexIndex == 0 && !@scene.searchResults
    if $Trainer.pokedex.seen?(species, form) || (consider_only_species && $Trainer.pokedex.seen?(species))
      owned = $Trainer.pokedex.owned?(species, form) || (consider_only_species && $Trainer.pokedex.owned?(species))
      pbCopyBitmap(self.contents, (owned ? @pokeballOwned : @pokeballSeen).bitmap, rect.x - 4, rect.y + 8)
      text += @commands[index][1]
    else
      text += "----------"
    end
    pbDrawShadowText(self.contents, rect.x + 30, rect.y + 6, rect.width, rect.height, text, self.baseColor, self.shadowColor)
    drawCursor(index - 1, itemRect(index - 1))
  end
end

# constants for custom pc UI for rejuv
class PokemonStorageScene
  BASECOLOR = ColorArrays[:Default] # color, shadow
  BLUECOLOR = [Color.new(24, 112, 216), Color.new(136, 168, 208)]
  REDCOLOR = [Color.new(248, 56, 32), Color.new(224, 152, 144)]

  POKENAME_OFFSET = [12, 6, :left] # x, y, text alignment
  POKELV_OFFSET = [16, 228]
  POKEGENDER_OFFSET = [158, 6]
  POKETYPE_OFFSET = [26, 268, 92, 58] # x, y, x type2, x singletype
  POKEAB_OFFSET = [90, 304]
  POKEITEM_OFFSET = [92, 342]
  POKESHINY_OFFSET = [156, 198]

  MARKING_CONSTS = [102, 238]

end

class PokemonBoxSprite
  BOXNAME_OFFSET = 6
end

class PokemonSummaryScene
  LightBase = Color.new(248, 248, 248)
  LightShadow = Color.new(104, 104, 104)
  DarkBase = Color.new(64, 64, 64)
  DarkShadow = Color.new(176, 176, 176)
  ShinyBase = Color.new(248, 56, 32)
  ShinyShadow = Color.new(224, 152, 144)
  MissingAbilDesc = "Ability description missing!"
  MissingAbilName = "Name missing!"
  NoAbilDesc = "No effect."
  NoAbilName = "No ability"
  NotRealAbil = "Ability does not exist!"
  BALL_OFFSET = [14, 60]
  MOVEDESC_OFFSET = [4, 218, 230] # [x, y, width]
  ITEM_OFFSET = [10, 352]
  GenderIconPos = [188, 62]

  PokemonSpritePos = [40, 144] # sets the position of the pokemon sprite in the summary screen

  MARKING_CONSTS = [22, 302, 14, 14, 4, 6] # x, y, width, height, markingcount, spacing between markings

  def drawMarkings(bitmap, x, y, width, height, markings)
    return drawMarkingsSprite(bitmap, MARKING_CONSTS[0], MARKING_CONSTS[1], MARKING_CONSTS[2], MARKING_CONSTS[3], markings, MARKING_CONSTS[4], MARKING_CONSTS[5]) if !Desolation
  end
end

def moonpawwantedthis
    # Party
  for mon in $Trainer.party
    if mon.species == :BLAZIKEN
      oldname = mon.name
      mon.species = :TORCHIC
      mon.name = "Torchic" if oldname == "Blaziken"
      mon.calcStats
      if mon.item == :BLAZIKENITE
        $PokemonBag.pbStoreItem(mon.item)
        mon.setItem(nil)
      end
      return true
    end
  end
  return false
end

def pbInspectText(pkmn)
  return false if !pkmn.inspectText
  if @battle.blockedInspect
    pbSEPlay("SFX - Blip", 80, 140)
    return print "Access Blocked"
  end
  Kernel.pbMessage(_INTL("\\se[]Inspecting {1}\\wt[8].\\wt[8].\\wt[8].\\wt[8].\\wt[8].\1",pkmn.pbThis), false, 0)
  pbSEPlay("SFX - Blip", 80, 140)
  errorlog = "errorlog.txt"
  if (Object.const_defined?(:RTP) rescue false)
    errorlog = RTP.getSaveFileName("errorlog.txt")
  end
  errorlogline = errorlog.sub(Dir.pwd + "\\", "")
  errorlogline = errorlogline.sub(Dir.pwd + "/", "")
  if errorlogline.length > 20
    errorlogline = "\n" + errorlogline
  end
  text = "[#{GAME_TITLE} #{GAME_VERSION} #{Time.now}]\n"
  text += "Exception: NoMethodError\n"
  text += "Message: undefined method `pbShowBattleStats' for #<PokeBattle_Scene:0x0000020f95f4bdd8 @battle=#<PokeBattle_Battle:0x0000020f95f4bbf8 @seed=1774904122, @battleRandom=#<Random:0x0000020f95f4ba40>, @battle=#<PokeBattle_Battle:0x0000020f95f4bbf8 ...>, @scene=#<PokeBattle_Scene:0x0000020f95f4bdd8 ...>, @decision=0, @internalbattle=true, @doublebattle=true, @cantescape=true, @shiftStyle=false, @battlescene=false, @recorded=false, @player=#<PokeBattle_Trainer:0x0000020f92a494a0 @name=RENEGADE\n"
  text += "Scripts/Battle_Scene.rb:3988:in `block in pbCommandMenuEx'\n"
  text += "Scripts/Battle_Scene.rb:3950:in `loop'\n"
  text += "Scripts/Battle_Scene.rb:3950:in `pbCommandMenuEx'\n"
  text += "Scripts/Battle_Scene.rb:3906:in `pbCommandMenu'\n"
  text += "Scripts/Battle.rb:4183:in `pbCommandMenu'\n"
  text += "Scripts/Battle.rb:4309:in `block (3 levels) in commandloop'\n"
  text += "Scripts/Battle.rb:4308:in `loop'\n"
  text += "Scripts/Battle.rb:4308:in `block (2 levels) in commandloop'\n"
  text += "Scripts/Battle.rb:4307:in `catch'\n"
  text += "Scripts/Battle.rb:4307:in `block in commandloop'\n"
  text += "Scripts/Battle.rb:4298:in `each'\n"
  text += "Scripts/Battle.rb:4298:in `commandloop'\n"
  text += "Scripts/Battle.rb:4268:in `pbCommandPhase'\n"
  text += "Scripts/Battle.rb:4153:in `block in pbRunTurn'\n"
  text += "Scripts/PBDebug.rb:4:in `logonerr'\n"
  text += "Scripts/Battle.rb:4151:in `pbRunTurn'\n"
  text += "Scripts/Battle.rb:4135:in `block (2 levels) in pbBattleLoop'\n"
  text += "Scripts/Battle.rb:4134:in `loop'\n"
  text += "Scripts/Battle.rb:4134:in `block in pbBattleLoop'\n"
  text += "Scripts/Battle.rb:4133:in `catch'\n"
  text += "Scripts/Battle.rb:4133:in `pbBattleLoop'\n"
  text += "Scripts/Battle.rb:4124:in `pbStartBattle'\n"
  text += "Scripts/Field.rb:1239:in `block (2 levels) in pbWildBattleObject'\n"
  text += "Scripts/Field.rb:780:in `pbSceneStandby'\n"
  text += "Scripts/Field.rb:1238:in `block in pbWildBattleObject'\n"
  text += "\nThis exception was logged in #{errorlogline}.\nPress Ctrl+C to copy this message to the clipboard.\n"
  print text
  pbWait(2)
  pkmn.inspectText.each do |line|
    pbSEPlay("SFX - Blip", 80, 140)
    Kernel.pbMessage(line, false, 0, "Graphics/Windowskins/Zeight")
  end
  pbWait(2)
  @battle.blockedInspect = true

end

def loadAGangParty(id = nil)
  player = [:Aevis, :Aevia, :Axel, :Ariana, :Alain, :Aero].find { |n| $game_switches[n] }
  id = Switches[id] if id.is_a?(Symbol)
  id = Switches[[:Act1Password, :Act2Password, :Act3Password].find { |s| $game_switches[s] }] if !id

  tclass = "TRAINER_#{player.to_s.upcase}".to_sym
  tclass = :TRAINER_ARIA if player == :Ariana
  trainer = findParty(tclass, player.to_s, id)

  if !id || !trainer
    dp("Failed to locate party for [#{player.to_s.inspect}, #{tclass.inspect}, #{id}].\nPlease report <3")
    id = 1708
  end
  party = []
  trainer.party.each { |mon|
    party.push(PokeBattle_Pokemon::PokemonBuilder.new(mon).build())
  }
  $Trainer.party = party
end

def getGoomink
  $game_variables[:TempPartyStorage] = $Trainer.party
  $Trainer.party = []
  goomId = (Switches[:GoominkQuest] * 100) + $game_variables[:GoominkQuest]
  trainer = nil
  while !trainer && goomId > Switches[:GoominkQuest]
    trainer = findParty(:HERO, "Goomink", goomId)
    goomId -= 1
  end
  if !trainer
    dp("Could not find party for [:HERO, \"Goomink\", #{(Switches[:GoominkQuest] * 100) + $game_variables[:GoominkQuest]}]")
    pbRentReturn
    return
  end

  party = []
  trainer.party.each { |mon|
    party.push(PokeBattle_Pokemon::PokemonBuilder.new(mon).build())
  }
  $Trainer.party = party
end

def pbPrintException(e)
  emessage=pbGetExceptionMessage(e)
  btrace=""
  if e.backtrace
    maxlength=$INTERNAL ? 25 : 10
    e.backtrace[0,maxlength].each do |i|
      btrace=btrace+"#{i}\n"
    end
  end
  btrace.gsub!(/Section(\d+)/){$RGSS_SCRIPTS[$1.to_i][1]}
  message="[#{GAME_TITLE} #{GAME_VERSION}]\nException: #{e.class}\nMessage: #{emessage}\n#{btrace}"
  errorlog="errorlog.txt"
  if (Object.const_defined?(:RTP) rescue false)
    errorlog=RTP.getSaveFileName("errorlog.txt")
  end
  errorlogline=errorlog.sub(Dir.pwd+"\\","")
  errorlogline=errorlogline.sub(Dir.pwd+"/","")
  if errorlogline.length>20
    errorlogline="\n"+errorlogline
  end
  return if File.exist?(errorlog) && File.size(errorlog) > 100_000_000
  File.open(errorlog,"ab"){|f| f.write(message);f.write("\n") }
  if !e.is_a?(Hangup)
    print("#{message}\nThis exception was logged in #{errorlogline}.\nPress Ctrl+C to copy this message to the clipboard.")
  end
end

module TextLog
  def self.getChoiceTextColor() # For games to potentially override
    color = {
      :Aevis => shadowc3tag(Color.new(71, 230, 135), Color.new(42, 79, 47)),
      :Aevia => shadowc3tag(Color.new(241, 120, 175), Color.new(109, 34, 57)),
      :Axel => shadowc3tag(Color.new(148, 145, 166), Color.new(40, 44, 51)),
      :Ariana => shadowc3tag(Color.new(186, 74, 91), Color.new(63, 24, 30)),
      :Alain => shadowc3tag(Color.new(68, 187, 178), Color.new(14, 60, 50)),
      :Aero => shadowc3tag(Color.new(225, 74, 46), Color.new(75, 26, 30)),
      :Ana => shadowc3tag(Color.new(213, 89, 174), Color.new(62, 19, 38)),
    }.filter { |k, _| $game_switches[k] }.values[0]

    color = :Blue2 if !color || $game_switches[:NotPlayerCharacter]
    color = ColorTags[color] if color.is_a?(Symbol)
    return color
  end
end

module MessageConfig
  unless @messageAliases
    self.singleton_class.send(:alias_method, :__core_getSpeechFrame, :pbGetSpeechFrame)
    self.singleton_class.send(:alias_method, :__core_pbGetSystemFrame, :pbGetSystemFrame)
    self.singleton_class.send(:alias_method, :__core_pbGetSystemFontName, :pbGetSystemFontName)
    @messageAliases = true
  end

  DEUXFINALISMAPS = [
    637, 638, 639, 670
  ]

  def self.pbGetSpeechFrame
    ret = __core_getSpeechFrame
    if $game_map
      ret = pbResolveBitmap("Graphics/Windowskins/speech hgss 21") if DEUXFINALISMAPS.include?($game_map.map_id)
    end
    if $game_switches
      ret = pbResolveBitmap("Graphics/Windowskins/speech hgss 34") if $game_switches[:AtebitDesire] && isValidForFont
    end
    return ret
  end

  def self.pbGetSystemFrame
    ret = __core_pbGetSystemFrame
    if $game_switches
      return pbResolveBitmap("Graphics/Windowskins/choice 34") if $game_switches[:AtebitDesire] && isValidForFont
    end
    return ret
  end

  def self.pbGetSystemFontName
    ret = __core_pbGetSystemFontName
    if $game_switches
      return "PKMN RBYGSC" if $game_switches[:AtebitDesire] && isValidForFont
    end
    return ret
  end
end

def pbInitRandomStatics
  $game_variables[787] = (1..3).to_a.sample
  # 1 = Sizzlipede, 2 = Joltik, 3 = Blipbug
  $game_variables[776] = (1..9).to_a.sample
  # 1 = Ae-Magikarp, 2 = Ae-Budew, 3 = Ae-Wimpod, 4 = Ae-Shroomish, 5 = Ae-Larvesta,
  # 6 = Ae-Bronzor, 7 = Ae-Feebas, 8 = Ae-Sigilyph, 9 = Ae-Jangmo-o
  $game_variables[228] = (0..20).to_a.sample
  # 0 = Azurill, 1 = Impidimp, 2 = Nacli, 3 = Togepi, 4 = Sneasel, 5 = Dhelmise, 6 = Ae-Litwick, 7 = Axew,
  # 8 = Mienfoo, 9 = Pawniard, 10 = Trapinch, 11 = Hippopotas, 12 = Cottonee, 13 = Darumaka, 14 = Hatenna,
  # 15 = Starly, 16 = Tyrunt, 17 = Larvesta, 18 = Mareanie, 19 = Stufful, 20 = Rookidee
  $game_variables[741] = (0..2).to_a.sample
  # 0 = Skiddo, 1 = Mudbray, 2 = G-Ponyta
  $game_variables[968] = (1..3).to_a.sample
  # 1 = P-Combat Tauros, 2 = P-Blaze Tauros, 3 = P-Aqua Tauros
  pbMonoRandEvents
end

def pbMonoRandEvents
  meggcrawli, aevianmyst, mysteryegg, mixeggr2, taurosrandom = [], [], [], [], []
  eventhash = { 787 => meggcrawli, 776 => aevianmyst, 228 => mysteryegg, 741 => mixeggr2, 968 => taurosrandom }
  if $game_switches[:MonoBug]
    meggcrawli.push(1, 2, 3)
    aevianmyst.push(3)
    mysteryegg.push(17)
  end
  if $game_switches[:MonoDark]
    mysteryegg.push(1, 4, 9)
  end
  if $game_switches[:MonoDragon]
    aevianmyst.push(1, 9)
    mysteryegg.push(7, 10, 16)
  end
  if $game_switches[:MonoElectric]
    meggcrawli.push(2)
    aevianmyst.push(4)
    mysteryegg.push(6)
  end
  if $game_switches[:MonoFairy]
    aevianmyst.push(7, 8)
    mysteryegg.push(0, 1, 3, 12, 14)
    mixeggr2.push(2)
  end
  if $game_switches[:MonoFire]
    meggcrawli.push(1)
    aevianmyst.push(1)
    mysteryegg.push(13, 17)
    taurosrandom.push(2)
  end
  if $game_switches[:MonoFighting]
    aevianmyst.push(2)
    mysteryegg.push(8, 19)
    taurosrandom.push(1, 2, 3)
  end
  if $game_switches[:MonoFlying]
    aevianmyst.push(5)
    mysteryegg.push(3, 15, 20)
  end
  if $game_switches[:MonoGhost]
    aevianmyst.push(8)
    mysteryegg.push(5, 6)
  end
  if $game_switches[:MonoGrass]
    aevianmyst.push(4)
    mysteryegg.push(5, 12)
    mixeggr2.push(0)
  end
  if $game_switches[:MonoGround]
    aevianmyst.push(2, 3)
    mysteryegg.push(10, 11)
    mixeggr2.push(1)
  end
  if $game_switches[:MonoIce]
    mysteryegg.push(4)
  end
  if $game_switches[:MonoNormal]
    mysteryegg.push(15, 19)
  end
  if $game_switches[:MonoPoison]
    aevianmyst.push(7, 9)
    mysteryegg.push(18)
  end
  if $game_switches[:MonoPsychic]
    meggcrawli.push(3)
    mysteryegg.push(14)
    mixeggr2.push(2)
  end
  if $game_switches[:MonoRock]
    mysteryegg.push(2, 16)
  end
  if $game_switches[:MonoSteel]
    aevianmyst.push(6)
    mysteryegg.push(9, 20)
  end
  if $game_switches[:MonoWater]
    mysteryegg.push(0, 18)
    taurosrandom.push(3)
  end
  for var, mons in eventhash
    next if mons.length == 0

    mons.uniq! # Removing multiple copies of mons if multiple passwords add them
    $game_variables[var] = mons.sample
  end
end

alias __rejuv_renameTrainer renameTrainer unless defined?(__rejuv_renameTrainer)
def renameTrainer(*args)
  __rejuv_renameTrainer(*args)
  $game_variables[:PlayerNameBackup] = $Trainer.name
end

def getNonsenseText
  text = "<fn=PKMN RBYGSC><fs=18>"
  graphics = [
    "Pictures/Trainer Card/johto/selarrow", "Pictures/Trainer Card/johto/item", "Pictures/Trainer Card/johto/selarrow_sel",
    "Icons/footprint156", "Icons/footprint156", "Icons/footprint156", "Icons/footprint156", "Icons/footprint156",
    "Icons/fieldTabStarEmpty", "Icons/fieldTabStarEmpty", "Icons/fieldTabStarEmpty",
  ].map { |g| "<img=Graphics/#{g}>" }
  bagpocket = "<icon=bagPocket#{rand(7) + 1}>"
  types = ($cache.types.keys - [:STELLAR]).map { |t| "<icon=bosstype#{t}>" } + (Dir.children("Graphics/Pictures/Blessings") - ["hudBlessingBG.png"]).map { |f| "<img=Graphics/Pictures/Blessings/#{f}>"}
  chars = [
    ":3", "LLDLFSLLDFSL", ":3", "hi", "=]", "tehe"
  ]
  pokegraphic = "<icon=Pokemon/icon#{[245, 418, 604, 492, 156, 471].sample}>"

  selected = graphics.sample(6) + [bagpocket, pokegraphic] + types.sample(7) + chars.sample(2)
  selected.shuffle.each { |s|
    text += s + (" " * rand(6))
  }
  return text + "</fs></fn>"
end

def pbHasMoveOfType(type)
  return $Trainer.party.any? do |mon|
    mon.moves.any? do |move|
      pbMoveSummaryType($cache.moves[move.move], mon) == type
    end
  end
end

def convertSave(newsave)
  if newsave[:variable][543]&.is_a?(Array)
    newsave[:variable][543].each { |mon| convertMon(mon) if mon.is_a?(PokeBattle_Pokemon) && mon.species.is_a?(Numeric) }
  end
end

def isPrologueSafeOpen
  return $Unidata[:OpenedPrologueSafe] || $game_switches[2076]
end

class PokeBattle_Scene
  unless @battleSceneAliases_cutin
    alias __cutin_pbCommandMenuEx pbCommandMenuEx
    @battleSceneAliases_cutin = true
  end

  def pbCommandMenuEx(index, texts, mode = 0)
    $seenPartnerMoveIntroThisRuntime = "init" if !defined?($seenPartnerMoveIntroThisRuntime)
    if $game_switches[:PartnerMoveIntro] && $seenPartnerMoveIntroThisRuntime != "#{$Trainer.name}#{$Unidata[:saveslot]}"
      pbShowWindow(COMMANDBOX)
      cw = @sprites["commandwindow"]
      cw.setTexts(texts)
      cw.index = 0 if @lastcmd[index] == 2 || $Settings.remember_commands == 0
      cw.mode = mode
      cw.refresh
      #pbWait(30)
      $seenPartnerMoveIntroThisRuntime = "#{$Trainer.name}#{$Unidata[:saveslot]}"
      $game_switches[:PartnerMoveIntro] = false
      maindim = BitmapSprite.new(Graphics.width, Graphics.height - 96)
      maindim.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height - 96, Color.new(0, 0, 0))
      maindim.opacity = 0
      maindim.z = 999999

      messageboxdim = BitmapSprite.new(Graphics.width, 96)
      messageboxdim.y = Graphics.height - 96
      messageboxdim.bitmap.fill_rect(0, 0, Graphics.width, 48, Color.new(0, 0, 0))
      messageboxdim.bitmap.fill_rect(0, 48, Graphics.width - 134, 48, Color.new(0, 0, 0))
      messageboxdim.opacity = 0
      messageboxdim.z = 999999
      15.times {
        messageboxdim.opacity += 10
        maindim.opacity += 10
        pbWait(1)
      }
      pbWait(30)
      messageboxdim.opacity = 0
      pbDisplayPausedMessage(_INTL("CRESCENT: Remember, just call for us if you need help!"))
      pbShowWindow(COMMANDBOX)

      maindim.opacity = 150
      messageboxdim.opacity = 150
      pbWait(30)

      15.times {
        messageboxdim.opacity -= 10
        maindim.opacity -= 10
        pbWait(1)
      }
      maindim.dispose
      messageboxdim.dispose
    end
    return __cutin_pbCommandMenuEx(index, texts, mode)
  end
end

def clearRaidOutfit(showMessage = true)
  if $game_variables[812].between?(0, 73) && $game_temp.player_new_map_id != 618
    if $Trainer.outfit == 7
      $Trainer.outfit = 9
      $game_variables[259] = 9 # outfit tracker
      $game_variables[681] = 0 # location tracker
      Kernel.pbMessage(_INTL("\\PN changed out of their raid gear.")) if showMessage
    end
  end
end

alias __core_preFadeInChanges preFadeInChanges unless defined?(__core_preFadeInChanges)
def preFadeInChanges
  __core_preFadeInChanges
  clearRaidOutfit()

  if [627, 682, 438].include?($game_map.map_id)
    if $game_screen.pictures[3]
      $game_screen.pictures[3].erase
    end
  end
end

class PokemonEncounters
  unless @m2Aliases
    alias __m2_encounterType pbEncounterType
    alias __m2_isEncGenBlocked isEncounterGenerationBlocked?
    @m2Aliases = true
  end

  def pbEncounterType
    return EncounterTypes::Lava if m2hell
    return __m2_encounterType
  end

  def isEncounterGenerationBlocked?(enctype)
    return true if @stepcount <= 2 && m2hell
    return __m2_isEncGenBlocked(enctype)
  end

  def modifyEncounterGenerationRate(encount, enctype)
    return ENCOUNTER_RAND_MAX if m2hell
    return encount
  end
end

class PokeBattle_Battle
  unless @m2Aliases
    alias __m2_unloseableItem pbIsUnlosableItem
    alias __m2_canRun pbCanRun?
    alias __m2_run pbRun
    @m2Aliases = true
  end

  def pbIsUnlosableItem(*args, **kwargs)
    return true if m2hell && pbIsWild?
    return __m2_unloseableItem(*args, **kwargs)
  end

  def pbCanRun?(*args)
    return false if m2hell
    return __m2_canRun(*args)
  end

  def pbRun(*args)
    thispkmn = @battlers[args[0]]
    if pbIsOpposing?(args[0])
      return 0 if @opponent

      @choices[i] = [:run]
      return -1
    end
    return -1 if m2hell
    return __m2_run(*args)
  end
end

module PokeBattle_BattleCommon
  unless @m2Aliases
    alias __m2_canCatch pbCanCatch?
    @m2Aliases = true
  end

  def pbCanCatch?(*args)
    return false if m2hell
    return __m2_canCatch(*args)
  end
end

def m2hell
  if $game_map.map_id == 675
    if $game_player.x.between?(40, 60) && $game_player.y.between?(4, 21)
      if $PokemonGlobal&.surfing
        return true
      end
    end
  end
  return false
end

class MoveRelearnerScene
  unless @moveRelearnerAliases
    alias __core_handleRelearner handleRelearnerSelection
    @moveRelearnerAliases = true
  end

  def handleRelearnerSelection
    if !@pokemon.canRelearnAll? && !@relearner && [:relearn].include?(@page) && $game_switches[:Portable_Move_Relearner] &&
        !(($game_switches[:NotPlayerCharacter] && !$game_switches[:InterceptorsWish]) || xenTowerInProgress)
      if Kernel.pbConfirmMessage(_INTL("Access Zeight Move Relearner functionality to teach {1}?", @pokemon.name))
        commands = []
        commands.push(_INTL("Teach one-by-one,"))
        commands.push(_INTL("Relearn All?"))
        command = Kernel.pbMessage(_INTL("What would you like to do?"), commands, -1)
        case command
          when 0
            if $PokemonBag.pbQuantity(:HEARTSCALE) > 0
              if pbRelearnMoveScreen($Trainer.party, @partyid)
                $PokemonBag.pbDeleteItem(:HEARTSCALE)
              end
            else
              Kernel.pbMessage(_INTL("Not enough Heart Scales on hand for the service."))
              if $PokemonBag.pbQuantity(:BLKPRISM) > 0
                commands2 = []
                commands2.push(_INTL("Yes."))
                commands2.push(_INTL("No"))
                command2 = Kernel.pbMessage(_INTL("Use a Black Prism instead?"), commands2, -1)
                if command2 == 0
                  if $PokemonBag.pbQuantity(:BLKPRISM) > 0
                    if pbRelearnMoveScreen($Trainer.party, @partyid)
                      $PokemonBag.pbDeleteItem(:BLKPRISM)
                    end
                  else
                    Kernel.pbMessage(_INTL("Not enough Black Prisms on hand for the service."))
                  end
                end
              end
            end
          when 1
            if $PokemonBag.pbQuantity(:HEARTSCALE) > 2
              $PokemonBag.pbDeleteItem(:HEARTSCALE, 3)
              @party[@partyid].activateRelearner()
              refreshMoves
            else
              Kernel.pbMessage(_INTL("Not enough Heart Scales on hand for the service."))
              if $PokemonBag.pbQuantity(:BLKPRISM) > 0
                commands2 = []
                commands2.push(_INTL("Yes."))
                commands2.push(_INTL("No"))
                command2 = Kernel.pbMessage(_INTL("Use Black Prisms instead?"), commands2, -1)
                if command2 == 0
                  if $PokemonBag.pbQuantity(:BLKPRISM) > 2
                    $PokemonBag.pbDeleteItem(:BLKPRISM, 3)
                    @party[@partyid].activateRelearner()
                    refreshMoves
                  else
                    Kernel.pbMessage(_INTL("Not enough Black Prisms on hand for the service."))
                  end
                end
              end
            end
        end
      end
      return @pokemon, -1
    end
    return __core_handleRelearner
  end
end

MessageDisplayEvents.messageBoxSetup += proc { |sender, params|
  msgwindow = params[0]
  text = params[2]

  fontname = "PKMN RBYGSC"
  fontsize = getSystemFontSize(fontname)
  if $game_switches && $game_switches[:AtebitDesire] && isValidForFont
    text.insert(0, "<fn=#{fontname}><fs=#{fontsize}>")
    text.insert(-1, "</fs></fn>")
    msgwindow.setSkin("Graphics/Windowskins/speech hgss 34")
  end

  text.gsub!(/\\gsc/i, "<fn=#{fontname}><fs=#{fontsize}>")
  text.gsub!(/\\egsc/i, "</fs></fn>")
}

MessageDisplayEvents.controlsHandler += proc { |sender, params|
  msgwindow = params[0]
  text = params[2]

  text.gsub!(/\\[Vv]\[(930)\]/) {
    next namesRoulette.to_s
  }
}

def hasActiveRentalTeam?
  return $game_variables[:V13RentalChoice] > 0
end

alias __rejuv_pbTryUseRemotePC pbTryUseRemotePC unless defined?(__rejuv_pbTryUseRemotePC)
def pbTryUseRemotePC(*args)
  if hasActiveRentalTeam?()
    Kernel.pbMessage(_INTL("ERIN: {1}, can you get off that PC and get on with the battle?", $Trainer.name), log: true)
    return false
  end
  return __rejuv_pbTryUseRemotePC(*args)
end

alias __rejuv_makeSaveHash makeSaveHash unless defined?(__rejuv_makeSaveHash)
def makeSaveHash
  if [678, 679].include?($game_map.map_id) && $game_variables[974] == 2
    # Dialogue/Soft Reset skipping for Kaina/M2
    $game_variables[974] = 3
  end
  return __rejuv_makeSaveHash
end

class PokeBattle_Pokemon
  def shouldUpdateStatsOnItemChange?
    # These crests update base stats and they are required to be refreshed.
    return true if @species == :ZORUA
    return true if @species == :CASTFORM && @form.between?(1, 3) # Parity change. Castform 1-3 are not obtainable outside of battle.

    return false
  end
end

# TODO: name method better or abstract the below check
def isPulse2Allowed?
  return !xenTowerInProgress && !$game_switches[:AngelicaTower]
end

def tmSanityCheckRejuv
  return false if ($game_switches[:NotPlayerCharacter] && !$game_switches[:InterceptorsWish]) || xenTowerInProgress
  $cache.items.each do |key, item|
    next if !item.checkFlag?(:tm)
    $game_switches[item.item] = false if !$PokemonBag.pbHasItem?(item.item)
  end
end

def getVictoryMusicOverride(music)
  return "Victory - Paragon.ogg" if $game_variables[811] > 0
  return "Victory - Renegade.ogg" if $game_variables[910] > 0
  return music
end

def gameSpecificConversion(allpokemon)
  $game_variables[:LuckMoves] = [$game_variables[:LuckMoves], Random.new(Time.now.to_i)] if $game_variables[:LuckMoves] != 0 && !$game_variables[:LuckMoves].is_a?(Array)
  $game_switches[:Last_Ace_Switch] = false # just frankly this should only be on for specific battles so it shouldn't be on on saveload basically ever
  $game_switches[:InterceptorsWish] = false if !$game_switches[:NotPlayerCharacter] # Accident in a specific event in Renegade. Is never the case normally.
  if $game_variables[543]&.is_a?(Array)
    allpokemon -= $game_variables[543]
    if $game_variables[646] >= 40
      $game_variables[543] = 0
    else
      $game_variables[543].each { |mon| convertMon(mon) if mon.is_a?(PokeBattle_Pokemon) && mon.species.is_a?(Numeric) }
      allpokemon += $game_variables[543]
    end
  end
  if $game_variables[756] > 26 ||  $game_variables[731] > 35
    $game_switches[:Portable_Move_Relearner] = true if !$game_switches[:Portable_Move_Relearner]
  end
  if $game_variables[812] < 2 && $PokemonGlobal.visitedMaps[618]
    $PokemonGlobal.visitedMaps[618] = false
  end
  if $game_variables[646] >= 100 && $game_variables[425] >= 1 && $game_variables[426] < 2
    $game_variables[426] = 2
    $game_switches[2215] = true
  end
  if checkVersionOlderThan("14.0.0-beta.12")
    $game_switches[:Field_Notes] = true
    $game_switches[2048] = true # city notes
    $game_switches[2038] = true if $game_switches[:RiftDex] # dimensional
    $game_switches[2038] = true if $game_variables[568] > 16 # dragon's den
    $game_variables[960] = rand(3)
    $game_variables[2048] = 0 # because i am fucking stupid
  end
  if checkVersionOlderThan("14.0.0-beta.13")
    $game_variables[971] = rand(3)
  end
  if checkVersionOlderThan("14.0.0-beta.14")
    if !$Unidata[:FinishedV14Story]
      $game_variables[960] = 0
      $Unidata[:EizenTowerSkip] = false
      saveClientData
    end
  end
  if checkVersionOlderThan("14.0.0-beta.15")
    RIFTDATA.each_key { |rift|
      if $game_switches[rift]
        $game_switches[getRiftSpriteSwitch(rift)] = true
        $game_switches[getRiftDefeatedSwitch(rift)] = true
      end
    }
  end
  if checkVersionOlderThan("14.0.0-beta.17")
    RIFTDATA.each_key { |rift|
      $game_switches[getRiftSpriteSwitch(rift)] = true if $game_switches[getRiftDefeatedSwitch(rift)]
    }
  end
  if checkVersionOlderThan("14.0.0-beta.18")
    $game_variables[968] = rand(3) if $game_variables[968] == 0
  end
  if checkVersionOlderThan("14.0.0-beta.24")
    if $game_switches[2110]
      $game_switches[2110] = false
      $game_variables[362] -= 1
    end
  end
  if checkVersionOlderThan("14.0.3")
    if $game_variables[212] > 0
      $game_variables[212] += 1
    end
    if $game_variables[898] > 0 && $game_variables[838] == 0 # accounting for modded files, settnig variables to 0
      $game_variables[898] = 0
    end
  end
  if checkVersionOlderThan("14.0.7")
    completedQuests = getCompletedQuests()
    if completedQuests.include?(:HeroOfSlime)
      $game_variables[617] = 31 if $game_variables[617] == 0
      $game_switches[2209] = false if $game_switches[2209]
    end
    if completedQuests.include?(:MissingChildren)
      $game_variables[429] = 91 if $game_variables[429] == 0
    end

    #$Unidata[:FinishedV14Story] = false if $game_variables[812] < 154
  end
  if checkVersionOlderThan("14.0.9")
    # Fix for Paragon NG++ stuff
    $Unidata[:FinishedV14Story] = true if $PokemonGlobal.visitedMaps[684] && $game_variables[912] == 0
  end
  if checkVersionOlderThan("14.0.21")
    $game_switches[:Omniscience] = false if !pbActivePasswords.include?("omniscience")
    $game_switches[1325] = false
  end
  if checkVersionOlderThan("14.0.15")
    # Fix for Paragon NG++ stuff
    if $game_variables[811] >= 5 && $game_variables[920] == 6
      $game_variables[920] = $game_switches[1957] ? 8 : 7
    end
  end

  # TODO: Remove this or add conditions if the switch becomes used again
  $game_switches[:No_Mega_Limit] = false

  # Fixes Pokedex entry list @forms for species with renamed forms from Scripts#658
  convert(:TAUROS) do |entry|
    next if entry.forms["Paldean Combat Breed"] # converted
    entry.forms["Paldean Combat Breed"] = entry.forms.delete("Combat Breed")
    entry.forms["Paldean Blaze Breed"] = entry.forms.delete("Blaze Breed")
    entry.forms["Paldean Aqua Breed"] = entry.forms.delete("Aqua Breed")
  end
  convert(:MEWTWO) do |entry|
    next if entry.forms["Mega X Form"] # converted
    entry.forms["Mega X Form"] = entry.forms.delete("Mega X")
    entry.forms["Mega Y Form"] = entry.forms.delete("Mega Y")
  end
  convert(:FURFROU) do |entry|
    next if entry.forms["Natural Form"] # converted
    entry.forms["Natural Form"] = entry.forms.delete("Normal Form")
  end
  convert(:SILVALLY) do |entry|
    next if entry.forms["Type: Normal"] # converted
    entry.forms.transform_keys! { |formName| "Type: #{formName}" }
  end
  convert(:MINIOR) do |entry|
    next unless entry.forms["Blue Core"] # converted
    # Rename and reorder
    entry.forms["Red Core"] = entry.forms.delete("Red Core")
    entry.forms["Indigo Core"] = entry.forms.delete("Blue Core") # Blue to Indigo
    entry.forms["Green Core"] = entry.forms.delete("Green Core")
    entry.forms["Violet Core"] = entry.forms.delete("Violet Core")
    entry.forms["White Core"] = entry.forms.delete("White Core")
    entry.forms["Yellow Core"] = entry.forms.delete("Yellow Core")
    entry.forms["Dark Core"] = entry.forms.delete("Dark Core")
    entry.forms["Meteor Form"] = entry.forms.delete("Meteor Form")
  end
  convert(:DIALGA, :PALKIA, :NECROZMA, :ETERNATUS, :CALYREX) do |entry|
    next if entry.forms["Normal Form"] # converted
    entry.forms["Normal Form"] = entry.forms.delete($cache.pkmn[entry.species, 0].name)
    entry.forms.keys[0...-1].each { |formName| entry.forms[formName] = entry.forms.delete(formName) }
  end
  convert(:PUMPKABOO, :GOURGEIST) do |entry|
    next if entry.forms["Jumbo Variety"] # converted
    entry.forms["Jumbo Variety"] = entry.forms.delete("Normal Form")
    entry.forms["Small Variety"] = entry.forms.delete("Small")
  end

  allpokemon.each { |pokemon|
    change = false
    if checkVersionOlderThan("14.0.0-beta.1")
      if pokemon.species == :SNEASLER
        pokemon.form = 0
        change = true
      end

      pokemon.moves.map! { |move| move&.move == :HAIL ? PBMove.new(:SNOWSCAPE) : move }
    end
    if checkVersionOlderThan("14.0.0-beta.14")
      if pokemon.species == :ZYGARDE && pokemon.form > 2
        pokemon.form += 1
        change = true
      end
    end
    if checkVersionOlderThan("14.0.0-beta.22")
      if pokemon.species == :SNEASLER && pokemon.form == 1 && pokemon.ability == :HOSPITALITY
        pokemon.ability = :SWORNDUTY
      end
    end

    if checkVersionOlderThan("14.0.0-beta.23")
      if [:MEOWSTIC, :INDEEDEE, :BASCULEGION, :OINKOLOGNE].include?(pokemon.species)
        change = true
        form = pokemon.form
        pokemon.form = 0
        pokemon.genderflag = [:M, :F][form % 2] # modulo to ensure form is bound to gender index
      end
    end

    if checkVersionOlderThan("14.0.0-beta.24")
      if pokemon.species == :UNFEZANT && pokemon.form == 2
        change = true
        pokemon.form = 1
        pokemon.makeFemale
      end
    end

    if checkVersionOlderThan("14.0.0-beta.26")
      pokemon.timeReceived = :Glitched if pokemon.timeReceived.is_a?(String)
      pokemon.timeEggHatched = :Glitched if pokemon.timeEggHatched.is_a?(String)
    end
    if checkVersionOlderThan("14.0.10")
      if pokemon.species == :POLTCHAGEIST && pokemon.form == 1
        pokemon.form = 0
        pokemon.ability = :HOSPITALITY
      end
    end
    if checkVersionOlderThan("14.0.15")
      if pokemon.species == :SNEASEL && pokemon.form == 2 && pokemon.ability == :HOSPITALITY
        pokemon.ability = :SWORNDUTY
      end
    end
    if checkVersionOlderThan("14.0.21")
      if pokemon.shadowmovenum && !pokemon.isShadow?
        pokemon.purified = true
      end
    end

    if checkVersionOlderThan("14.0.28")
      if pokemon.species == :ZYGARDE && pokemon.form == 0
        pokemon.firstmoves.push(*[:THOUSANDARROWS, :THOUSANDWAVES, :EXTREMESPEED])
        pokemon.firstmoves.uniq!
      end
      pokemon.removeBattleOnlyAttributes # Method was added in this version
    end

    # Fix `zygardeBecomeSnake` using the wrong method, and pre-emptive fix for future mistakes
    if pokemon.firstmoves&.any? { |m| m.is_a?(PokeBattle_Move) }
      pokemon.firstmoves = pokemon.firstmoves.map { |m|
        next m.move if m.is_a?(PokeBattle_Move)
        next m
      }.uniq
    end

    if checkVersionOlderThan("15.0.0-alpha.0") && forceAuraBreakZygarde
      # Goodbye Zygarde. Modders you know what to do if you need to.
      if pokemon.species == :ZYGARDE && pokemon.ability == :POWERCONSTRUCT
        pokemon.ability = :AURABREAK
      end
    end
    pokemon.calcStats if change
  }

  if $game_variables[:VirtualGender] == 0 && $game_variables[:VirtualLeagueProgress] > 0 # Check for old gender switch, and convert to new variable
    $game_variables[:VirtualGender] = $game_switches[:VirtualGirl] ? 2 : 1
  end
  if $game_variables[:VirtualLeagueProgress] > 7
    $game_switches[:VirtualGym7] = true if  $game_switches[:VirtualGym7] == false
  end
  tmSanityCheckRejuv # accounting for a TM related bug in 14.0.0 beta
end

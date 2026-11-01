# Variable 726 holds trainer information
def characterSwitch(character)
  # Backup the player trainer's information
  $game_variables[:PlayerDataBackup] = []
  playerDataBackup
  playerItemBackup
  playerTeamBackup
  playerPCBackup
  $game_switches[:NotPlayerCharacter] = true # NOTPLAYER switch
  bagChange if $game_switches[:InterceptorsWish] == false # Interceptor wish keeps the bag intact
  $game_switches[:No_Money_Loss] = true
  if $PokemonGlobal.bicycle
    Kernel.pbDismountBike
  end
  # Load in the new trainer's information
  if character.is_a?(String)
    case character
      when "Adam"
        pbChangePlayer(24)
        $Trainer.name = "Adam"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:LEADER_ADAM, "Adam", 1, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "Aelita Axis"
        pbChangePlayer(15)
        $Trainer.name = "Aelita"
        $Trainer.outfit = 0
        $PokemonBag = $game_variables[:PlayerDataBackup][6]
        $Trainer.id = KNOWN_TRAINERS["Aelita"]

      when "Aelita"
        pbChangePlayer(15)
        $Trainer.name = "Aelita"
        $Trainer.outfit = 0
        $Trainer.id = KNOWN_TRAINERS["Aelita"]

      when "Aelita Nightmare"
        pbChangePlayer(15)
        $Trainer.name = "Aelita"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:STUDENT_3, "Aelita", 5, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)
        $PokemonBag.pbStoreItem(:FIGHTINIUMZ, 1)

      when "Aelita ANGY"
        pbChangePlayer(18)
        $Trainer.name = "Aelita"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:STUDENT_2, "Aelita", 0, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "Aelita - Airship"
        pbChangePlayer(15)
        $Trainer.name = "Aelita"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:STUDENT_3, "Aelita", 6, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "Aelita - Pyramid"
        pbChangePlayer(15)
        $Trainer.name = "Aelita"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.id = 45886
        trainerinfo = pbLoadTrainer(:STUDENT_3, "Aelita", 0, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "Alexandra"
        pbChangePlayer(16)
        $Trainer.name = "Alexandra"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:ELITE_ALEXANDRA, "Alexandra", 0, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "Amber"
        pbChangePlayer(19)
        $Trainer.name = "Amber"
        $Trainer.outfit = 0
        $Trainer.id = KNOWN_TRAINERS["Amber"]
        $game_switches[:VSGraphicOff] = true # we don't have graphics for her

      when "Amber Realm"
        pbChangePlayer(19)
        $Trainer.name = "Amber"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:LEADER_AMBER2, "Amber", 0, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $game_switches[:VSGraphicOff] = true # we don't have graphics for her

      when "Erin"
        pbChangePlayer(17)
        $Trainer.name = "Erin"
        $Trainer.outfit = 0
        $Trainer.id = KNOWN_TRAINERS["Erin"]

      when "Erin - Diamond"
        pbChangePlayer(17)
        $Trainer.name = "Erin"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:CANDIDGIRL, "Erin", 5, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "Huey Realm"
        pbChangePlayer(21)
        $Trainer.name = "Huey"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:OPTKID, "Huey", 2, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $game_switches[:VSGraphicOff] = true # we don't have graphics for him

      when "Huey"
        pbChangePlayer(21)
        $Trainer.name = "Huey"
        $Trainer.outfit = 0
        $Trainer.id = KNOWN_TRAINERS["Huey"]
        $game_switches[:VSGraphicOff] = true # we don't have graphics for him

      when "Lavender HOH"
        pbChangePlayer(11)
        $Trainer.name = "Lavender"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.id = KNOWN_TRAINERS["Lavender"]

      when "Lavender SPACE"
        pbChangePlayer(22)
        $Trainer.name = "Lavender"
        $Trainer.outfit = 14
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:LEADER_LAVENDER, "Lavender", 2, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)


      when "Lavender"
        pbChangePlayer(22)
        $Trainer.name = "Lavender"
        $Trainer.outfit = 14
        $Trainer.id = KNOWN_TRAINERS["Lavender"]

      when "Marianette"
        pbChangePlayer(2)
        $Trainer.name = "Marianette"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 500
        $Trainer.id = KNOWN_TRAINERS["Marianette"]

      when "Melia"
        pbChangePlayer(12)
        $Trainer.name = "Melia"
        $Trainer.outfit = 0
        $Trainer.id = KNOWN_TRAINERS["Melia"]

      when "Melia - Lab"
        pbChangePlayer(9)
        $Trainer.name = "Melia"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:TRAINER_MELIA1, "Melia", 1, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "Emma"
        pbChangePlayer(10)
        $Trainer.name = "Emma"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:HOOD, "Emma", 1, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "Melia Zeight"
        pbChangePlayer(23)
        $Trainer.name = "Melia"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:ENIGMA_1, "Melia", 4, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "Melia - GDB"
        pbChangePlayer(14)
        $Trainer.name = "Melia"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:ENIGMA_1, "Melia", 5, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "Melia Library"
        pbChangePlayer(12)
        $Trainer.name = "Melia"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:ENIGMA_1, "Melia", 5, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "Melia 1v1"
        pbChangePlayer(12)
        $Trainer.name = "Melia"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:ENIGMA_2, "Melia", 4, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "Melia - Pearl"
        pbChangePlayer(12)
        $Trainer.name = "Melia"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.id = 27973
        trainerinfo = pbLoadTrainer(:ENIGMA_2, "Melia", 3, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "Melia - Inside"
        pbChangePlayer(14)
        $Trainer.name = "Melia"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.id = 27973
        trainerinfo = pbLoadTrainer(:ENIGMA_2, "Melia", 2, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "Ren - Past"
        pbChangePlayer(13)
        $Trainer.name = "Ren"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:OUTCAST, "Ren", 1, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:SILVCREST, 1)
        $PokemonBag.pbStoreItem(:PUPPETCOIN, 1) if $game_variables[:PlayerDataBackup][6].pbHasItem?(:PUPPETCOIN)

        when "Ren - Past1"
        pbChangePlayer(13)
        $Trainer.name = "Ren"
        $Trainer.outfit = 0
        $Trainer.id = KNOWN_TRAINERS["Ren"]

      when "Ren - Pyramid"
        pbChangePlayer(13)
        $Trainer.name = "Ren"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.id = 27412
        trainerinfo = pbLoadTrainer(:OUTCAST, "Ren", 3, noscaling: true, knownID: true)
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:SILVCREST, 1)

      when "Saki Realm", "Saki Axis"
        pbChangePlayer(20)
        $Trainer.name = "Saki"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 1000000000
        $Trainer.id = KNOWN_TRAINERS["Saki"]

      when "Odessa"
        pbChangePlayer(25)
        $Trainer.outfit = 0
        $Trainer.money = 1000000000
        $Trainer.id = KNOWN_TRAINERS["Odessa"]

      when "Melia - Karma1"
        pbChangePlayer(26)
        $Trainer.name = "Melia"
        $Trainer.outfit = 10
        $Trainer.id = KNOWN_TRAINERS["Melia"]

      when "Melia - Karma2"
        pbChangePlayer(26)
        $Trainer.name = "Melia"
        $Trainer.outfit = 10
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.id = 27973
        trainerinfo = pbLoadTrainer(:ENIGMA_2, "Melia", 5, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      # Inside Ice Queendom
      when "Melia - Karma3"
        pbChangePlayer(30)
        $Trainer.name = "Melia"
        $Trainer.outfit = 0
        $Trainer.id = KNOWN_TRAINERS["Melia"]

      when "Melia - Karma4"
        pbChangePlayer(30)
        $Trainer.name = "Melia"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.id = 2797
        trainerinfo = pbLoadTrainer(:ENIGMA_2, "Melia", 5, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)
      ###
      when "Aelita Angie"
        pbChangePlayer(27)
        $Trainer.name = "Aelita"
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.outfit = 0
        trainerinfo = pbLoadTrainer(:STUDENT, "Aelita", 4, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "XG Saber 1"
        pbChangePlayer(28)
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.name = "Saber"
        $Trainer.money = 3000
        $Trainer.id = KNOWN_TRAINERS["Saber"]
        $PokemonBag.pbStoreItem(:POTION, 3)

      when "XG Saber 2"
        pbChangePlayer(28)
        $Trainer.name = "Saber"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 3000
        trainerinfo = pbLoadTrainer(:XG_SABER, "Saber", 1, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:POTION, 5)

      when "XG Saber 3"
        pbChangePlayer(28)
        $Trainer.name = "Saber"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 3000
        trainerinfo = pbLoadTrainer(:XG_SABER, "Saber", 2, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:POTION, 5)

      when "Endbringer"
        pbChangePlayer(29)

      when "AnaQuest-Lose"
        pbChangePlayer(31)
        $Trainer.name = "Ana"
        $Trainer.outfit = 0
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:NANO, "Ana", 1, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "AnaQuest-Win"
        pbChangePlayer(31)
        $Trainer.name = "Ana"
        $Trainer.outfit = 0
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:NANO, "Ana", 2, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]

      when "GoominkBOTW"
        pbChangePlayer(32)
        $Trainer.name = "Goomink"
        $Trainer.outfit = 0
        $Trainer.id = 11986

      when "RenWings"
        pbChangePlayer(33)
        $Trainer.name = "Ren"
        $Trainer.outfit = 0
        $Trainer.id = KNOWN_TRAINERS["Ren"]

      when "Erin - MtRuin"
        pbChangePlayer(17)
        $Trainer.name = "Erin"
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.outfit = 0
        trainerinfo = pbLoadTrainer(:CANDIDGIRL, "Erin", 6, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "Erin - MtRuin1"
        pbChangePlayer(17)
        $Trainer.name = "Erin"
        $Trainer.id = KNOWN_TRAINERS["Erin"]
        $Trainer.outfit = 0

      when "Ren - MtRuin"
        pbChangePlayer(13)
        $Trainer.name = "Ren"
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.outfit = 0
        trainerinfo = pbLoadTrainer(:OUTCAST, "Ren", 11, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)
        $PokemonBag.pbStoreItem(:SILVCREST, 1)

      when "Ren - MtRuin1"
        pbChangePlayer(13)
        $Trainer.name = "Ren"
        $Trainer.outfit = 0
        $Trainer.id = KNOWN_TRAINERS["Ren"]

      when "M2 Mines"
        pbChangePlayer(34)

        $Trainer.name = "M2"
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.outfit = 0
        $Trainer.id = 27411
        clearPC
        trainerinfo = pbLoadTrainer(:TRAINER_M2_1, "M2", 0, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)
        trainerinfoold = pbLoadTrainer(:ENIGMA_2, "Melia", 6, noscaling: true, knownID: true)
        trainerinfoold[2].each { |pokemon| pokemon.disobedient = true}
        pcSwap(trainerinfoold[2])

      when "atebitsalad"
        $Trainer.outfit = 13
        $Trainer.party = []
        $Trainer.money = 0
        $PokemonBag = PokemonBag.new

      when "ErinHurt"
        pbChangePlayer(35)
        $Trainer.name = "Erin"
        $Trainer.party = []
        $Trainer.money = 0

        trainerinfo = pbLoadTrainer(:CANDIDGIRL, "Erin", 7, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "StormNym"
        pbChangePlayer(36)
        $Trainer.outfit = 0
        $Trainer.name = "Storm-Nym"
        $Trainer.party = []
        $Trainer.money = 0

      when "AelitaWeiss"
        pbChangePlayer(37)
        $Trainer.name = "Aelita"
        $Trainer.party = []
        $Trainer.money = 0
        $Trainer.outfit = 0
        trainerinfo = pbLoadTrainer(:STUDENT_3, "Aelita", 9, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "VenamWeiss"
        pbChangePlayer(38)
        $Trainer.name = "Venam"
        $Trainer.party = []
        $Trainer.outfit = 0
        trainerinfo = pbLoadTrainer(:LEADER_VENAM3, "Venam", 5, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "ErinWeiss"
        pbChangePlayer(17)
        $Trainer.name = "Erin"
        $Trainer.party = []
        $Trainer.outfit = 0
        trainerinfo = pbLoadTrainer(:CANDIDGIRL, "Erin", 7, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "AlexandraWeiss"
        pbChangePlayer(16)
        $Trainer.name = "Alexandra"
        $Trainer.outfit = 0
        $Trainer.party = []
        $Trainer.money = 0
        trainerinfo = pbLoadTrainer(:ELITE_ALEXANDRA, "Alexandra", 1, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $game_switches[:VSGraphicOff] = true
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "VenamRenegade"
        pbChangePlayer(38)
        $Trainer.name = "Venam"
        $Trainer.party = []
        $Trainer.outfit = 0
        trainerinfo = pbLoadTrainer(:LEADER_VENAM3, "Venam", 7, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "VenamSeviper"
        pbChangePlayer(41)
        $Trainer.name = "Venam"
        $Trainer.party = []
        $Trainer.outfit = 0
        trainerinfo = pbLoadTrainer(:LEADER_VENAM3, "Venam", 7, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)


      when "Xenpurgis"
        $Trainer.party = []
        $Trainer.outfit = 8
        $Trainer.party = trainerinfo[2]

      when "AGANG"
        pbChangePlayer(40)
        $Trainer.name = "A-Gang"
        $Trainer.party = []
        $Trainer.outfit = 0
        trainerinfo = pbLoadTrainer(:INTERTWINEDFATE, "A-Gang", 0, noscaling: true, knownID: false)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        $PokemonBag.pbStoreItem(:MEGARING, 1)

      when "MarianetteAdult"
        pbChangePlayer(3)
        $Trainer.name = "Marianette"
        $Trainer.outfit = 4
        $Trainer.money = 500


      when "Virtual League"
        case $game_variables[:VirtualGender]
          when 1
            $Trainer.trainertype = :JOHTO_0M
            $Trainer.name = "Ethan"
          when 2
            $Trainer.trainertype = :JOHTO_0F
            $Trainer.name = "Kris"
          when 3
            $Trainer.trainertype = :JOHTO_0NB
            $Trainer.name = "Silus"
        end
        $Trainer.name = $game_variables[:VirtualName] if $game_variables[:VirtualName] != 0
        $Trainer.money = 3000
        teamid = (($game_variables[:VirtualLeagueStarter] - 1) * 10) + ($game_variables[:VirtualLeagueProgress] - 1)
        trainerinfo = pbLoadTrainer(:JOHTO_0M, "Ethan", teamid, noscaling: true, knownID: true)
        $Trainer.id = trainerinfo[0].id
        $Trainer.party = trainerinfo[2]
        for pokemon in $Trainer.party
          pokemon.ot = $Trainer.name
        end
    end
  end
end

def characterRestore(resetbag = true)
  playerSpriteRestore
  playerDataRestore
  teamRestore if !$game_switches[:InterceptorsWish]
  playerPCRestore
  if resetbag == true # prevents bag/money from being reset
    playerItemRestore if !$game_switches[:InterceptorsWish]
  end
  $game_switches[:NotPlayerCharacter] = false # you're now the player!
  $game_switches[:No_Money_Loss] = false # money can be lost again
  $game_switches[:VSGraphicOff] = false # reset vs graphics to on
  $game_switches[:InterceptorsWish] = false # interceptor's wish is off
end

def playerItemBackup
  $game_variables[:PlayerDataBackup][1] = $Trainer.money
  $game_variables[:PlayerDataBackup][6] = $PokemonBag
  $game_variables[:PlayerDataBackup][7] = false
  # if the bag gets swapped, this is flipped to true
  # that way if it isn't swapped, we skip restoring it
end

def playerDataBackup
  $game_variables[:PlayerNameBackup] = $Trainer.name
  $game_variables[:PlayerDataBackup][2] = $Trainer.badges
  $game_variables[:PlayerDataBackup][3] = $Trainer.id
  $game_variables[:PlayerDataBackup][4] = $Trainer.outfit
  $game_variables[:PlayerDataBackup][5] = $Trainer.trainertype
end

def playerTeamBackup
  $game_variables[:PlayerDataBackup][0] = $Trainer.party
end

def pcSwap(pokemon)
  for i in pokemon
    $PokemonStorage.pbStoreCaught(i)
  end
end

def clearPC
  $PokemonStorage = PokemonStorage.new
end

def playerPCBackup
  $game_variables[:PlayerDataBackup][8] = $PokemonStorage
end

def playerPCRestore
  $PokemonStorage = $game_variables[:PlayerDataBackup][8]
end


def playerSpriteRestore
  pbChangePlayer(0) if $game_switches[:Aevis]
  pbChangePlayer(1) if $game_switches[:Aevia]
  pbChangePlayer(5) if $game_switches[:Axel]
  pbChangePlayer(4) if $game_switches[:Ariana]
  pbChangePlayer(6) if $game_switches[:Alain]
  pbChangePlayer(7) if $game_switches[:Aero]
  pbChangePlayer(8) if $game_switches[:Ana]
end

def playerDataRestore
  $Trainer.name = $game_variables[:PlayerNameBackup]
  $Trainer.badges = $game_variables[:PlayerDataBackup][2]
  $Trainer.id = $game_variables[:PlayerDataBackup][3]
  $Trainer.outfit = $game_variables[:PlayerDataBackup][4]
  $Trainer.trainertype = $game_variables[:PlayerDataBackup][5]
end

def playerItemRestore
  $Trainer.money = $game_variables[:PlayerDataBackup][1]
  $PokemonBag = $game_variables[:PlayerDataBackup][6]
  $game_variables[:PlayerDataBackup][7] = false
end

def bagChange
  $PokemonBag = PokemonBag.new
  $game_variables[:PlayerDataBackup][7] = true # indicates that the bag was replaced
  $PokemonBag.pbStoreItem(:FULLHEAL, 4)
  $PokemonBag.pbStoreItem(:MAXPOTION, 6)
  $PokemonBag.pbStoreItem(:REVIVE, 4)
  $PokemonBag.pbStoreItem(:MAXREVIVE, 1)
end


def preloadedTeamSwap(party)
  playerTeamBackup if !$game_switches[:NotPlayerCharacter]
  party = Array(party)
  $Trainer.party = party
end

def teamSwap(trainertype, trainername, partyid = nil)
  if !$game_switches[:NotPlayerCharacter]
    playerTeamBackup
    trainerinfo = pbLoadTrainer(trainertype, trainername, partyid, noscaling: true)
    $Trainer.party = trainerinfo[2]
  else
    trainerinfo = pbLoadTrainer(trainertype, trainername, partyid, noscaling: true)
    $Trainer.id = trainerinfo[0].id
    $Trainer.party = trainerinfo[2]
  end
end

def teamRestore
  $Trainer.party = $game_variables[:PlayerDataBackup][0]
end

# dump and fetch functions for debugging if bagcontents or player party were lost during character switching
def bagyeet
  File.open("bag.dat", "w") { |file|
    Marshal.dump($PokemonBag, file)
  }
end

def bagyoink
  File.open("bag.dat", "r") { |file|
    $PokemonBag = Marshal.load(file)
  }
end

def teamyeet
  File.open("team.dat", "w") { |file|
    Marshal.dump($Trainer.party, file)
  }
end

def teamyoink
  File.open("team.dat", "r") { |file|
    $Trainer.party = Marshal.load(file)
  }
end

def pcyeet
    File.open("pc.dat", "w") { |file|
    Marshal.dump($PokemonStorage, file)
  }
end

def pcyoink
  File.open("pc.dat", "r") { |file|
    $PokemonStorage = Marshal.load(file)
  }
end

def initBattleData
  if $game_variables[:BattleDataArray].nil? || !$game_variables[:BattleDataArray].kind_of?(Array)
    $game_variables[:BattleDataArray] = []
  end
end

class Battle_Data
  attr_accessor :opponentName
  attr_accessor :playerTeam
  attr_accessor :opponentTeam
  # how many "points" each pokemon has scored throughout the battle, one array for
  # each side.
  attr_accessor :playerTeamScores
  attr_accessor :opponentTeamScores
  # the number of healing items has been used for both sides of the battle.
  attr_accessor :playerItemsUsed
  attr_accessor :opponentItemsUsed
  # the name (as in, nickname) of the pokemon who was the MVP of a previous battle
  # with a same opponent.
  attr_accessor :oldMVPName
  # Used for graphical purpose in DisplayBattlers. Keeps track of who was the player's
  # last pokemon to battle and who were they battling.
  attr_accessor :lastPokemonUsed
  attr_accessor :lastPokemonAttacked
  # Used for the nicknaming flag. Stores the nickname of the whole party.
  attr_accessor :nickname
  # Used for the monotype flag. Stores the ID of the type the player's team shares.
  attr_accessor :monotype
  # List of the moves used throughout this battle, and the most used move name.
  attr_accessor :movesUsed
  attr_accessor :mostUsedMove

  # Constructor of the class. Only the the opponent name, their team and the player
  # team are used as parameters, everything else is initialized at zero.
  def initialize(opponentName, playerTeam, opponentTeam)
    @playerTeamScores = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    @opponentTeamScores = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    @playerItemsUsed = 0
    @opponentItemsUsed = 0
    @opponentName = opponentName
    # We specifically clone because not doing so means the state of your team gets
    # updated even after the battle is over, meaning it voids all flags comparing your team.
    @playerTeam = deep_copy(playerTeam)
    @opponentTeam = deep_copy(opponentTeam)
    @oldMVPName = nil
    @lastPokemonUsed = nil
    @lastPokemonAttacked = nil
    @movesUsed = {}
    @mostUsedMove = nil
  end

  # Called by ProcessFlags. Just so we're clear, this is strictly about
  # healing items and such. held items are none of our business.
  def afterBattleItemsResult
    # Self-explanatory : if the player used no items
    if @playerItemsUsed == 0
      itemsResult = "NO_ITEMS"
    # Case if the player used items, but less than the opponent did.
    elsif @playerItemsUsed > 0 && @playerItemsUsed <= @opponentItemsUsed
      itemsResult = "LESS_ITEMS_THAN_OPPONENT"
    # Self-explanatory : if the player used more items than the opponent.
    else
      itemsResult = "MORE_ITEMS_THAN_OPPONENT"
    end
    return itemsResult
  end

  # called by the PokeBattle_Battler class, checks who fainted who and attributes
  # points to the mon based on whether they're legendaries, hold a Z-crystal or a
  # mega-stone.
  def pokemonFaintedAnEnemy(battlers, user, target, move)
    # case the player is scoring
    oi = user.battle.pbGetOwnerIndex(user.index)
    if [0, 2].include?(battlers.rindex(user)) && [1, 3].include?(battlers.rindex(target))
      score = 0
      if target.hasMega? || isLegendary(target.species)
        score = 2
      else
        score = 1
      end
      @playerTeamScores[oi][user.pokemonIndex] += score
      @lastPokemonUsed = user.pokemon.clone
      @lastPokemonAttacked = target.pokemon.clone
    # p @playerTeamScores
    # case the opponent is scoring
    elsif [0, 2].include?(battlers.rindex(target)) && [1, 3].include?(battlers.rindex(user))
      score = 0
      if target.hasMega? || isLegendary(target.species)
        score = 2
      else
        score = 1
      end
      @opponentTeamScores[oi][user.pokemonIndex] += score
      # p @opponentTeamScores
    end
  end

  # Called by ProcessFlags
  # Calculates if the battle was won by a landslide or was more of a close call.
  # Does So by checking how many mons are still unfainted on the player side
  # decides which flag to send depending of the  value of battleresult
  def afterBattleStateOfPartyResult
    # useful to make the calculation work with a variable team size
    total = @playerTeam[0].length
    total += @playerTeam[1].length unless @playerTeam[1].nil?
    faintedMons = 0
    noMonAbove25PercentHealth = true
    for team in @playerTeam
      for i in 0..team.length - 1
        faintedMons += 1 if team[i].hp == 0
        noMonAbove25PercentHealth = false if (team[i].hp.to_f / team[i].totalhp.to_f) > 0.25
      end
    end
    if faintedMons == 0 || @opponentTeamScores.max() == 0
      battleResult = "6-0"
    # elsif(faintedMons==(total-1) && noMonAbove25PercentHealth)
    #  battleResult = "BY_A_THREAD"
    elsif faintedMons <= (total * 0.33).round
      battleResult = "CURB_STOMP"
    elsif faintedMons >= (total * 0.66).round
      battleResult = "CLOSE_CALL"
    end
    return battleResult
  end

  # Called by ProcessFlags
  # using the data collected in @movesUsed through the fight,
  # determine which move was the most used and stores it in @mostUsedMove
  def getMoveData
    $expectedMovesList = [] if $expectedMovesList.nil?
    # for h in 0..$expectedMovesList.length-1
    #   if !PBMoves.getName($expectedMovesList[h]).nil?
    #     $expectedMovesList[h]=PBMoves.getName($expectedMovesList[h]).name
    #   end
    # end
    # #p $expectedMovesList
    totalTurns = 0
    mostUsedMoveCount = 0
    @mostUsedMove = nil
    for i in 0..@movesUsed.length - 1
      totalTurns += @movesUsed.values[i]
      if @movesUsed.values[i] > mostUsedMoveCount
        mostUsedMoveCount = @movesUsed.values[i]
        @mostUsedMove = @movesUsed.keys[i]
      end
    end
    # if one move was chosen more than 45% of the time by the player,
    # returns a flag so the corresponding reaction can be fired
    # if the move is included in the global variable $expectedMoves,
    # we return a different flag - you can use this to watch out for players
    # abusing a field effect, most notably.
    if mostUsedMoveCount.to_f >= totalTurns * 0.45
      if $expectedMovesList.include?(@mostUsedMove)
        moveResult = "SPAMMED_LISTED_MOVE"
      else
        moveResult = "SPAMMED_UNSPECIFIED_MOVE"
      end
    end
    return moveResult
  end

  # Called by ProcessFlags
  # Provided that the player already fought a trainer with the same name, it loads
  # the data of the previous match and returns various flags depending on the differences
  def getRematchData
    rematch = findIfRematchExists
    flags = []
    if !rematch.nil?
      sameTeam = establishTeamSimilarity(rematch)
      sameMVP = establishMVPSimilarity(rematch)
      return flags if (sameTeam.nil? || sameMVP.nil?)

      # fills the oldTeam array with the values of the team used in the previous match
      oldTeam = []
      rematch.playerTeam[0].each { |n| oldTeam << n.personalID }
      mvp = self.getMVPs[0]
      tempflag = ""
      # If the team contains 4 or more mons that were present at the previous battle
      if sameTeam
        tempflag = "SAME_TEAM_"
      # If at least 3 mons are different since last time
      else
        tempflag = "NEW_TEAM_"
      end
      # if the mvp was the same as last time
      if sameMVP
        tempflag += "SAME_MVP"
      # if not but the mvp was already part of your old team
      elsif oldTeam.include?(self.getMVPs[0].personalID)
        tempflag += "DIFFERENT_MVP"
      else
        tempflag += "NEW_MVP"
      end
      flags << tempflag
      # If the MVP was already in the old team but is now a different species/
      # has a mega-stone/has a z-move compared to last time.
      if oldTeam.include?(self.getMVPs[0].personalID)
        oldMon = rematch.playerTeam[0].find { |i| i.personalID == mvp.personalID }
        flags << "MVP_EVOLVED" if hasMVPEvolved(oldMon, mvp)
        flags << "MVP_MEGA" if acquiredMega(oldMon, mvp)
        flags << "MVP_Z_CRYSTAL" if acquiredZCrystal(oldMon, mvp)
      end
      # If the MVP from last time is no longer in the player team
      currentTeam = []
      @playerTeam[0].each { |n| currentTeam << n.personalID }
      if !currentTeam.include?(rematch.getMVPs[0].personalID)
        flags << "OLD_MVP_DISAPPEARED"
      end
    end
    return flags
  end

  # Called by ProcessFlags. Returns whether or not every mon in the team shares a
  # common type or an identical nickname, and whether or not the opponent's team is
  # outnumbering the player's.
  def miscFlags
    flags = []
    names = []
    # opponentAces= getTrainerAceList[$game_variables[:BattleDataArray].last().opponentName.upcase][0]
    @playerTeam[0].each { |i| names << i.name }
    if names.uniq.size == 1 && @playerTeam[0].length > 1
      flags << "IDENTICAL_NICKNAMES"
      @nickname = @playerTeam[0][0].name
    end
    type1 = @playerTeam[0][0].type1
    type2 = @playerTeam[0][0].type2
    count1 = 0
    count2 = 0
    @playerTeam[0].each { |i|
      if i.type1 == type1 || i.type2 == type1
        count1 += 1
      end
      if i.type1 == type2 || i.type2 == type2
        count2 += 1
      end
      # if opponentAces.include? i.species.to_s
      #  flags<< "SHARED_ACE"
      # end
    }
    if count1 == @playerTeam[0].length || count2 == @playerTeam[0].length
      flags << "MONOTYPE"
    end
    if count1 == @playerTeam[0].length
      @monotype = type1
    elsif count2 == @playerTeam[0].length
      @monotype = type2
    end
    if @playerTeam.flatten.length < @opponentTeam.flatten.length
      flags << "OUTNUMBERED"
    elsif @playerTeam.flatten.length > @opponentTeam.flatten.length
      flags << "OUTNUMBERING"
    end
    return flags
  end

  # Called by getRematchData. Establish how many mons were changed compared to the
  # last battle. Does so by using the personalID unique to each mon.
  def establishTeamSimilarity(match)
    oldTeam = []
    match.playerTeam[0].each { |n| oldTeam << n.personalID }
    newTeam = []
    @playerTeam[0].each { |n| newTeam << n.personalID }
    return (newTeam & oldTeam).length > 3
  end

  # Called by getRematchData. Finds the ID of the old MVP and compares it to the ID
  # of the current MVP
  def establishMVPSimilarity(match)
    return nil if match.getMVPs[0].nil?

    oldMVP = match.getMVPs[0]
    @oldMVPName = oldMVP.name
    newMVP = self.getMVPs[0]
    return oldMVP.personalID == newMVP.personalID
  end

  # Called by getRematchData. Checks for evolution by comparing the species of the mvp
  # back in the last battle comapred to now.
  def hasMVPEvolved(oldMon, mvp)
    return oldMon.species != mvp.species
  end

  # Called by getRematchData. Similar as above
  def acquiredMega(oldMon, mvp)
    return !oldMon.hasMegaForm? && mvp.hasMegaForm?
  end

  # Called by getRematchData. Similar as above
  def acquiredZCrystal(oldMon, mvp)
    return !pbIsZCrystal?(oldMon.item) && pbIsZCrystal?(mvp.item)
  end

  # Called by getRematchData. Ensures there is a point at all in doing any of this
  def findIfRematchExists
    # we're voluntarily stopping 1 entry in the array short so we don't arrive at
    # the current battle and have it compare to itself
    hasFoundMatch = nil
    for i in 0..$game_variables[:BattleDataArray].length - 2
      # name is the best thing I could come up to recognize a trainer,
      # so you'll have to improvise if you want to mess around with names
      if $game_variables[:BattleDataArray][i].opponentName == @opponentName
        hasFoundMatch = $game_variables[:BattleDataArray][i]
      end
    end
    return hasFoundMatch
  end

  # called whenever a pokemon uses a move. If the move is used by the player, adds
  # it to the list of moves used during this fight.
  # keep tracks of the count for each move.
  def pokemonTrackMove(choice, user, battlers)
    if [0, 2, 4].include?(battlers.rindex(user))
      move = choice[2].name
      if @movesUsed.key?(move)
        @movesUsed[move] += 1
      else
        @movesUsed[move] = 1
      end
    end
    if Rejuv && battlers.rindex(user) == 0 && choice[3] == 2 && choice[2].pbIsDamaging? && ![0xC1, 0x167].include?(choice[2].function) # Beat Up, Pollen Puff
      $game_switches[:DeliberateFriendlyFire] = true
    end
  end

  # Called by CharacterResponses. Loops through both player and enemy team arrays,
  # splits them at the 6 mark, and find which mon has the highest score in each of the
  # four groups. This is the thing that needs to be modified if you plan to handle
  # triple battles, by adding a third pair of lines.
  def getMVPs
    mvps = []
    player1 = @playerTeamScores[0]
    mvps << @playerTeam[0][player1.rindex(player1.max)]
    opponent1 = @opponentTeamScores[0]
    mvps << @opponentTeam[0][opponent1.rindex(opponent1.max)]
    if !@playerTeam[1].nil?
      player2 = @playerTeamScores[1]
      mvps << @playerTeam[1][player2.rindex(player2.max)]
    end
    if !@opponentTeam[1].nil?
      opponent2 = @opponentTeamScores[1]
      mvps << @opponentTeam[1][opponent2.rindex(opponent2.max)]
    end
    return mvps
  end

  # Same as above, but this time, it returns the mon with the lowest score.
  # If there is a tie, first with the lowest score is picked.
  def getLVPs
    lvps = []
    player1 = @playerTeamScores[0]
    lvps << @playerTeam[0][player1.rindex(player1.min)]
    opponent1 = @opponentTeamScores[0]
    lvps << @opponentTeam[0][opponent1.rindex(opponent1.min)]
    if !@playerTeam[1].nil?
      player2 = @playerTeamScores[1]
      lvps << @playerTeam[1][player2.rindex(player2.min)]
    end
    if !@opponentTeam[1].nil?
      opponent2 = @opponentTeamScores[1]
      lvps << @opponentTeam[1][opponent2.rindex(opponent2.min)]
    end
    return lvps
  end

  # Called by the Battle Class. Simply increments the ItemsUsed attribute.
  def playerUsedAnItem
    $game_variables[:BattleDataArray].last().playerItemsUsed += 1
  end

  # Same as above but for the opponent
  def opponentUsedAnItem
    $game_variables[:BattleDataArray].last().opponentItemsUsed += 1
  end

  # Used for the score calculation bit of PokemonFaintedAnEnemy to determine whether
  # or not a mon counts as a legendary. Currently also includes mythicals, ultra beasts
  # and paradox pokemon.
  def isLegendary(species)
    return (PBStuff::LEGENDARYLIST + PBStuff::ULTRABEASTS + PBStuff::PARADOXLIST).include?(species)
  end

  def isThereMVP()
    if @playerTeamScores[0].max() >= 3
      return "MVP"
    end
  end

  def getScoreAndSide(battler)
    idtofind = battler.personalID
    @playerTeam.each_with_index do |team, index|
      for i in 0...team.length
        if team[i].personalID == idtofind
          return [@playerTeamScores[index][i], "play", team[i].name]
        end
      end
    end
    @opponentTeam.each_with_index do |team, index|
      for j in 0...team.length
        if team[j].personalID == idtofind
          return [@opponentTeamScores[index][j], "opp", team[j].name]
        end
      end
    end
    return 0
  end
end

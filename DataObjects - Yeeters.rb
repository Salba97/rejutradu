def exportAll(game: nil)
  # TODO: clean up yeeters for commented lines
  monDump(game: game)
  dumpPokedexes(game: game)
  moveDump(game: game)
  itemDump(game: game)
  abilDump(game: game)
  mapDump if !game
  metaDump(game: game)
  # fields
  # field notes
  # types
  # trainer types
  # trainers
  dumpNatures(game: game)
  # bosses
  # martdata
  # currencies
  # passwords
end

def dumpDataHashes
  File.open(definition_file_path("PBSpecies.rb")) { |f| eval(f.read) }
  File.open(definition_file_path("PBTrainers.rb")) { |f| eval(f.read) }
  File.open(definition_file_path("PBAbilities.rb")) { |f| eval(f.read) }
  File.open(definition_file_path("PBItems.rb")) { |f| eval(f.read) }
  File.open(definition_file_path("PBTypes.rb")) { |f| eval(f.read) }
  File.open(definition_file_path("PBMoves.rb")) { |f| eval(f.read) }
  itemDump
  moveDump
  encDump
  abilDump
  metaConvert
  trainTypesDump
  monDump
  pbCompileTrainers
  dumpTeams
end

class MonData
  def export
    exporttext = ""
    exporttext += "      :name => #{@name.inspect},\n" if showAttribute?(:@name)
    exporttext += "      :dexnum => #{@dexnum.inspect},\n" if showAttribute?(:@dexnum)
    exporttext += "      :Type1 => #{@Type1.inspect},\n" if showAttribute?(:@Type1)
    exporttext += "      :Type2 => #{@Type2.inspect},\n" if showAttribute?(:@Type2)
    exporttext += "      :BaseStats => #{@BaseStats.inspect},\n" if showAttribute?(:@BaseStats)
    exporttext += "      :EVs => #{@EVs.inspect},\n" if showAttribute?(:@EVs)
    exporttext += "      :Abilities => #{@Abilities},\n" if showAttribute?(:@Abilities)
    exporttext += "      :HiddenAbility => #{@HiddenAbility.inspect},\n" if showAttribute?(:@HiddenAbility)
    exporttext += "      :GrowthRate => #{@GrowthRate.inspect},\n" if showAttribute?(:@GrowthRate)
    exporttext += "      :GenderRatio => #{@GenderRatio.inspect},\n" if showAttribute?(:@GenderRatio)
    exporttext += "      :BaseEXP => #{@BaseEXP.inspect},\n" if showAttribute?(:@BaseEXP)
    exporttext += "      :CatchRate => #{@CatchRate.inspect},\n" if showAttribute?(:@CatchRate)
    exporttext += "      :Happiness => #{@Happiness.inspect},\n" if showAttribute?(:@Happiness)
    exporttext += "      :EggSteps => #{@EggSteps.inspect},\n" if showAttribute?(:@EggSteps)
    if showAttribute?(:@EggMoves)
      exporttext += moveListString(:@EggMoves)
    end
    if showAttribute?(:@preevo)
      exporttext += preevoString
    end
    if showAttribute?(:@RelearnerMoves)
      exporttext += moveListString(:@RelearnerMoves)
    end
    if showAttribute?(:@Moveset)
      exporttext += movesetString
    end
    if showAttribute?(:@compatiblemoves)
      exporttext += moveListString(:@compatiblemoves)
    end
    if showAttribute?(:@moveexceptions)
      exporttext += moveListString(:@moveexceptions)
    end
    if showAttribute?(:@shadowmoves)
      exporttext += moveListString(:@shadowmoves)
    end
    exporttext += "      :Color => #{@Color.inspect},\n" if showAttribute?(:@Color)
    exporttext += "      :EggGroups => #{@EggGroups.inspect},\n" if showAttribute?(:@EggGroups)
    exporttext += "      :Height => #{@Height.inspect},\n" if showAttribute?(:@Height)
    exporttext += "      :Weight => #{@Weight.inspect},\n" if showAttribute?(:@Weight)
    exporttext += "      :kind => #{@kind.inspect},\n" if showAttribute?(:@kind)
    exporttext += "      :dexentry => #{@dexentry.inspect.gsub("\u00A0", "\\u00A0")},\n" if showAttribute?(:@dexentry)
    exporttext += "      :BattlerPlayerX => #{@BattlerPlayerX.inspect},\n" if showAttribute?(:@BattlerPlayerX)
    exporttext += "      :BattlerPlayerY => #{@BattlerPlayerY.inspect},\n" if showAttribute?(:@BattlerPlayerY)
    exporttext += "      :BattlerEnemyX => #{@BattlerEnemyX.inspect},\n" if showAttribute?(:@BattlerEnemyX)
    exporttext += "      :BattlerEnemyY => #{@BattlerEnemyY.inspect},\n" if showAttribute?(:@BattlerEnemyY)
    exporttext += "      :BattlerShadowSize => #{@BattlerShadowSize.inspect},\n" if showAttribute?(:@BattlerShadowSize)
    exporttext += "      :BattlerShadowX => #{@BattlerShadowX.inspect},\n" if showAttribute?(:@BattlerShadowX)
    if showAttribute?(:@evolutions)
      exporttext += evolutionString
    end
    if @MegaEvolutions
      exporttext += megaEvoString
    end
    if @reward
      exporttext += rewardString
    end
    exporttext += "      :shape => #{@shape.inspect},\n" if showAttribute?(:@shape)
    @flags.each { |k, v| exporttext += "      #{k.inspect} => #{v.inspect},\n" }

    # Display baseForm when baseForm is not itself OR baseForm is not 0 but equal to baseForm
    exporttext += "      :baseForm => #{@baseForm.inspect},\n" if @baseForm != 0
    if !self.genderDifferences.empty?
      exporttext += "      :genderDifferences => {\n"
      self.genderDifferenceAttrs.each { |gender, attrs|
        exporttext += "        #{gender.inspect} => {\n"

        exporttext += "          :name => #{self.genderDifferences[gender].send(:name).inspect},\n" if attrs.include?(:@name)
        exporttext += "          :dexnum => #{self.genderDifferences[gender].send(:dexnum).inspect},\n" if attrs.include?(:@dexnum)
        exporttext += "          :Type1 => #{self.genderDifferences[gender].send(:Type1).inspect},\n" if attrs.include?(:@Type1)
        exporttext += "          :Type2 => #{self.genderDifferences[gender].send(:Type2).inspect},\n" if attrs.include?(:@Type2)
        exporttext += "          :BaseStats => #{self.genderDifferences[gender].send(:BaseStats).inspect},\n" if attrs.include?(:@BaseStats)
        exporttext += "          :EVs => #{self.genderDifferences[gender].send(:EVs).inspect},\n" if attrs.include?(:@EVs)
        exporttext += "          :Abilities => #{self.genderDifferences[gender].send(:Abilities)},\n" if attrs.include?(:@Abilities)
        exporttext += "          :HiddenAbility => #{self.genderDifferences[gender].send(:HiddenAbility).inspect},\n" if attrs.include?(:@HiddenAbility)
        exporttext += "          :GrowthRate => #{self.genderDifferences[gender].send(:GrowthRate).inspect},\n" if attrs.include?(:@GrowthRate)
        exporttext += "          :GenderRatio => #{self.genderDifferences[gender].send(:GenderRatio).inspect},\n" if attrs.include?(:@GenderRatio)
        exporttext += "          :BaseEXP => #{self.genderDifferences[gender].send(:BaseEXP).inspect},\n" if attrs.include?(:@BaseEXP)
        exporttext += "          :CatchRate => #{self.genderDifferences[gender].send(:CatchRate).inspect},\n" if attrs.include?(:@CatchRate)
        exporttext += "          :Happiness => #{self.genderDifferences[gender].send(:Happiness).inspect},\n" if attrs.include?(:@Happiness)
        exporttext += "          :EggSteps => #{self.genderDifferences[gender].send(:EggSteps).inspect},\n" if attrs.include?(:@EggSteps)
        if attrs.include?(:@EggMoves)
          str = moveListString(:@EggMoves, self.genderDifferences[gender].send(:EggMoves))
          str = "          " + str.split("\n").join("\n    ").strip + "\n"
          exporttext += str
        end
        if attrs.include?(:@preevo)
          str = preevoString(self.genderDifferences[gender].send(:preevo))
          str = "          " + str.split("\n").join("\n    ").strip + "\n"
          exporttext += str
        end
        if attrs.include?(:@RelearnerMoves)
          str = moveListString(:@RelearnerMoves, self.genderDifferences[gender].send(:RelearnerMoves))
          str = "          " + str.split("\n").join("\n    ").strip + "\n"
          exporttext += str
        end
        if attrs.include?(:@Moveset)
          str = movesetString(self.genderDifferences[gender].send(:Moveset))
          str = "          " + str.split("\n").join("\n    ").strip + "\n"
          exporttext += str
        end
        if attrs.include?(:@compatiblemoves)
          str = moveListString(:@compatiblemoves, self.genderDifferences[gender].send(:compatiblemoves))
          str = "          " + str.split("\n").join("\n    ").strip + "\n"
          exporttext += str
        end
        if attrs.include?(:@moveexceptions)
          str = moveListString(:@moveexceptions, self.genderDifferences[gender].send(:moveexceptions))
          str = "          " + str.split("\n").join("\n    ").strip + "\n"
          exporttext += str
        end
        if attrs.include?(:@shadowmoves)
          str = moveListString(:@shadowmoves, self.genderDifferences[gender].send(:shadowmoves))
          str = "          " + str.split("\n").join("\n    ").strip + "\n"
          exporttext += str
        end
        exporttext += "          :Color => #{self.genderDifferences[gender].send(:Color).inspect},\n" if attrs.include?(:@Color)
        exporttext += "          :EggGroups => #{self.genderDifferences[gender].send(:EggGroups).inspect},\n" if attrs.include?(:@EggGroups)
        exporttext += "          :Height => #{self.genderDifferences[gender].send(:Height).inspect},\n" if attrs.include?(:@Height)
        exporttext += "          :Weight => #{self.genderDifferences[gender].send(:Weight).inspect},\n" if attrs.include?(:@Weight)
        exporttext += "          :kind => #{self.genderDifferences[gender].send(:kind).inspect},\n" if attrs.include?(:@kind)
        exporttext += "          :dexentry => #{self.genderDifferences[gender].send(:dexentry).inspect.gsub("\u00A0", "\\u00A0")},\n" if attrs.include?(:@dexentry)
        exporttext += "          :BattlerPlayerX => #{self.genderDifferences[gender].send(:BattlerPlayerX).inspect},\n" if attrs.include?(:@BattlerPlayerX)
        exporttext += "          :BattlerPlayerY => #{self.genderDifferences[gender].send(:BattlerPlayerY).inspect},\n" if attrs.include?(:@BattlerPlayerY)
        exporttext += "          :BattlerEnemyX => #{self.genderDifferences[gender].send(:BattlerEnemyX).inspect},\n" if attrs.include?(:@BattlerEnemyX)
        exporttext += "          :BattlerEnemyY => #{self.genderDifferences[gender].send(:BattlerEnemyY).inspect},\n" if attrs.include?(:@BattlerEnemyY)
        exporttext += "          :BattlerShadowSize => #{self.genderDifferences[gender].send(:BattlerShadowSize).inspect},\n" if attrs.include?(:@BattlerShadowSize)
        exporttext += "          :BattlerShadowX => #{self.genderDifferences[gender].send(:BattlerShadowX).inspect},\n" if attrs.include?(:@BattlerShadowX)
        if attrs.include?(:@evolutions)
          str = evolutionString(self.genderDifferences[gender].send(:evolutions))
          str = "          " + str.split("\n").join("\n    ").strip + "\n"
          exporttext += str
        end
        if attrs.include?(:@MegaEvolutions)
          str = megaEvoString(self.genderDifferences[gender].send(:MegaEvolutions))
          str = "          " + str.split("\n").join("\n    ").strip + "\n"
          exporttext += str
        end
        if attrs.include?(:@reward)
          str = rewardString(self.genderDifferences[gender].send(:reward))
          str = "          " + str.split("\n").join("\n    ").strip + "\n"
          exporttext += str
        end
        exporttext += "          :shape => #{self.genderDifferences[gender].send(:shape).inspect},\n" if attrs.include?(:@shape)
        exporttext += "        },\n"
      }
      exporttext += "      },\n"
    end
    return exporttext
  end

  def moveListString(atr = nil, data = nil)
    data ||= self.instance_variable_get(atr)
    return "" if atr.nil? || data.nil?
    sym = atr.to_s[1..]
    data.uniq!
    data -= getUniversalTMs() if atr == :@compatiblemoves
    text = ""
    if data.empty?
      text += "      :#{sym} => [],\n"
    else
      text += "      :#{sym} => [\n"
      text += "        "
      i = 0
      for move in data
        text += ":#{move}, "
        i += move.length + 3
        if i > 120 && move != data.last # 120 is about 10 moves, and should be the majority of the screen on a regular sized, 100% zoom monitor.
          text.rstrip!
          text += "\n        "
          i = 0
        end
      end
      text.rstrip!
      text += "\n      ],\n"
    end

    return text
  end

  def preevoString(data = @preevo)
    text = ""
    if data.nil?
      text += "      :preevo => #{data.inspect},\n"
    else
      text += "      :preevo => {\n"
      text += "        :species => :#{data[:species]},\n" if data[:species]
      text += "        :form => #{data[:form]},\n" if data[:form]
      text += "      },\n"
    end

    return text
  end

  def movesetString(data = @Moveset)
    text = ""
    check = 1
    text += "      :Moveset => [\n"
    for move in data
      text += "        [#{move[0]}, :#{move[1]}],\n"
      check += 1
    end
    text += "      ],\n"

    return text
  end

  def evolutionString(data = @evolutions)
    text = ""
    if data.nil?
      text += "      :evolutions => #{data.inspect},\n"
    else
      text += "      :evolutions => [\n"
      for evo in data
        if evo.is_a?(Array)
          text += "        { species: #{evo[0].inspect}, method: #{evo[1].inspect}, parameter: #{evo[2].inspect} },\n"
        else
          text += "        #{better_inspect(evo)},\n"
        end
      end
      text += "      ],\n"
    end

    return text
  end

  def megaEvoString(data = @MegaEvolutions)
    text = ""
    text += "      :MegaEvolutions => {\n"
    data.each { |method, form|
      text += "        #{method.inspect} => #{form.inspect},\n"
    }
    text += "      },\n"

    return text
  end

  def rewardString(data = @reward)
    text = ""
    if data.any?
      text += "      :reward => {\n"
      text += "        :item => #{data[:item].inspect},\n"
      text += "        :table => [\n"
      data[:table].each { |row|
        text += "          { rate: " + "#{row[:rate]},".ljust(6) + "num: " + "#{row[:num]}".ljust(4) + "},\n"
      }
      text += "        ],\n"
      text += "      },\n"
    else
      text += "      :reward => {},\n"
    end

    return text
  end

  def showAttribute?(attribute)
    selfAttr = self.instance_variable_get(attribute)

    baseData = @wrapper[@baseForm]
    return selfAttr != nil if baseData == self || EXCLUSIVE_ATTRS.include?(attribute)

    baseAttr = baseData.instance_variable_get(attribute)
    return selfAttr != baseAttr
  end
end

def abilDump(game: nil)
  exporttext = "ABILHASH = {"
  for i in $cache.abil.keys
    ability = $cache.abil[i]
    exporttext += "\n"
    exporttext += "  :#{i} => {\n"
    exporttext += "    :ID => #{ability.checkFlag?(:ID)},\n" if ability.checkFlag?(:ID)
    exporttext += "    :name => #{ability.name.inspect},\n"
    exporttext += "    :fullName => #{ability.fullName.inspect},\n" if ability.fullName != ability.name
    exporttext += "    :desc => #{ability.desc.inspect},\n"
    exporttext += "    :fullDesc => #{ability.fullDesc.inspect},\n" if ability.fullDesc != ability.desc
    exporttext += "  },\n"
  end
  exporttext += "}\n"
  file = Reborn && Gen >= 9 ? "abiltext_modern.rb" : "abiltext.rb"
  File.open(definition_file_path(file, game: game), "w") { |f|
    f.write(exporttext)
  }
end

def metaDump(game: nil)
  metadata = $cache.metadata
  exporttext = "METAHASH = {\n"
  exporttext += "  :home => #{metadata[:home].inspect},\n"
  exporttext += "  :TrainerVictory => #{metadata[:TrainerVictory].inspect},\n"
  exporttext += "  :WildVictory => #{metadata[:WildVictory].inspect},\n"
  exporttext += "  :TrainerBattle => #{metadata[:TrainerBattle].inspect},\n"
  exporttext += "  :WildBattle => #{metadata[:WildBattle].inspect},\n"
  exporttext += "  :Surf => #{metadata[:Surf].inspect},\n"
  exporttext += "  :LavaSurf => #{metadata[:LavaSurf].inspect},\n" if metadata[:LavaSurf]
  exporttext += "  :Bicycle => #{metadata[:Bicycle].inspect},\n"
  for i in 0...$cache.metadata[:Players].length
    player = $cache.metadata[:Players][i]
    next if player.nil?
    exporttext += "\n  :player#{i} => {"
    if player.empty?
      exporttext += "},\n"
      next
    else
      exporttext += "\n"
    end
    exporttext += "    :name => #{player[:name].inspect},\n"
    exporttext += "    :tclass => #{player[:tclass].inspect},\n"
    exporttext += "    # sprites,\n"
    if Reborn
      exporttext += "    :directory => #{player[:directory].inspect},\n" if player[:directory]
    end
    exporttext += "    :walk => #{player[:walk].inspect},\n" if player[:walk]
    exporttext += "    :run => #{player[:run].inspect},\n" if player[:run]
    exporttext += "    :bike => #{player[:bike].inspect},\n" if player[:bike]
    exporttext += "    :surf => #{player[:surf].inspect},\n" if player[:surf]
    exporttext += "    :dive => #{player[:dive].inspect},\n" if player[:dive]
    exporttext += "    :fishing => #{player[:fishing].inspect},\n" if player[:fishing]
    exporttext += "    :surffish => #{player[:surffish].inspect},\n" if player[:surffish]
    if Reborn
      exporttext += "    :ride => #{player[:ride].inspect},\n" if player[:ride]
      exporttext += "    :cart => #{player[:cart].inspect},\n" if player[:cart]
      exporttext += "    :trainer => #{player[:trainer].inspect},\n" if player[:trainer]
      exporttext += "    :trback => #{player[:trback].inspect},\n" if player[:trback]
      exporttext += "    :vstrainer => #{player[:vstrainer].inspect},\n" if player[:vstrainer]
      exporttext += "    :intro => #{player[:intro].inspect},\n" if player[:intro]
      exporttext += "    :map => #{player[:map].inspect},\n" if player[:map]
      exporttext += "    :event => #{player[:event].inspect},\n" if player[:event]
      exporttext += "    :grayscale => #{player[:grayscale].inspect},\n" if player[:grayscale]
    end
    exporttext += "  },\n"
  end
  exporttext += "}\n"
  File.open(definition_file_path("metatext.rb", game: game), "w") { |f|
    f.write(exporttext)
  }
  cprint "metaDump successful.                                       \n".green
end

def mapDump
  exporttext = "MAPHASH = {"
  for i in 1...$cache.mapdata.length
    cprint "Dumping map ##{i}\r".yellow
    map = $cache.mapdata[i]
    exporttext += "\n" + "  # #{$cache.mapinfos[i].name}\n"
    exporttext += "  #{i} => {"

    subexporttext = ""
    subexporttext += "    :HealingSpot => #{map.HealingSpot.inspect},\n" if map.HealingSpot
    if map.MapPosition
      if map.MapPosition.is_a?(Hash)
        subexporttext += "    :MapPosition => {\n"
        map.MapPosition.each { |key, value|
          subexporttext += "      #{key.inspect} => #{value},\n"
        }
        subexporttext += "    },\n"
      else
        subexporttext += "    :MapPosition => #{convertMapPos(map.MapPosition).inspect},\n"
      end
    end
    subexporttext += "    :Outdoor => #{map.Outdoor},\n" if map.Outdoor
    subexporttext += "    :ShowArea => #{map.ShowArea},\n" if map.ShowArea
    subexporttext += "    :Bicycle => #{map.Bicycle},\n" if map.Bicycle
    # subexporttext += "    :BicycleAlways => #{map.BicycleAlways},\n" if map.BicycleAlways
    subexporttext += "    :NoDigging => #{map.NoDigging},\n" if map.NoDigging
    subexporttext += "    :Weather => #{map.Weather},\n" if map.Weather
    subexporttext += "    :DiveMap => #{map.DiveMap},\n" if map.DiveMap
    subexporttext += "    :DarkMap => #{map.DarkMap},\n" if map.DarkMap
    subexporttext += "    :SafariMap => #{map.SafariMap},\n" if map.SafariMap
    subexporttext += "    :SnapEdges => #{map.SnapEdges},\n" if map.SnapEdges
    # subexporttext += "    :Dungeon => #{map.Dungeon},\n" if map.Dungeon
    subexporttext += "    :BattleBack => \"#{map.BattleBack}\",\n" if map.BattleBack
    subexporttext += "    :WildBattleBGM => \"#{map.WildBattleBGM}\",\n" if map.WildBattleBGM
    subexporttext += "    :TrainerBattleBGM => \"#{map.TrainerBattleBGM}\",\n" if map.TrainerBattleBGM
    subexporttext += "    :WildVictoryBGM => \"#{map.WildVictoryBGM}\",\n" if map.WildVictoryBGM
    subexporttext += "    :TrainerVictoryBGM => \"#{map.TrainerVictoryBGM}\",\n" if map.TrainerVictoryBGM
    subexporttext += "    :MapSize => #{map.MapSize},\n" if map.MapSize
    subexporttext += "    :Switches => #{better_inspect(map.Switches)},\n" if map.Switches
    subexporttext += "    :Variables => #{better_inspect(map.Variables)},\n" if map.Variables
    subexporttext += "    :AltMapName => #{map.AltMapName.inspect},\n" if map.AltMapName
    if map.AltAutoBGM
      subexporttext += "    :AltAutoBGM => {\n"
      map.AltAutoBGM.each { |k, v| subexporttext += "      #{k}: #{better_inspect(v)},\n" }
      subexporttext += "    },\n"
    end
    exporttext += (subexporttext == "" ? "" : "\n" + subexporttext + "  ") + "},\n"
  end
  exporttext += "}\n"
  File.open(definition_file_path("maptext.rb"), "w") { |f|
    f.write(exporttext)
  }
  cprint "mapDump successful.                                        \n".green
end

def metaConvert
  metadata = $cache.metadata
  exporttext = "METAHASH = {\n"
  exporttext += ":home => #{metadata[0][1].inspect},\n"
  exporttext += ":TrainerVictory => \"#{metadata[0][5]}\",\n"
  exporttext += ":WildVictory => \"#{metadata[0][4]}\",\n"
  exporttext += ":TrainerBattle => \"#{metadata[0][3]}\",\n"
  exporttext += ":WildBattle => \"#{metadata[0][2]}\",\n"
  exporttext += ":Surf => \"#{metadata[0][6]}\",\n"
  exporttext += ":Bicycle => \"#{metadata[0][7]}\",\n\n"
  for i in 8...$cache.metadata[0].length
    exporttext += ":player#{i - 7} => {\n"
    exporttext += "  :tclass => :#{getConstantName(PBTrainers, metadata[0][i][0])},\n"
    exporttext += "  #sprites,\n"
    exporttext += "  :walk => \"#{metadata[0][i][1]}\",\n" if metadata[0][i][1] != ""
    exporttext += "  :run => \"#{metadata[0][i][4]}\",\n" if metadata[0][i][4] != ""
    exporttext += "  :bike => \"#{metadata[0][i][2]}\",\n" if metadata[0][i][2] != ""
    exporttext += "  :surf => \"#{metadata[0][i][3]}\",\n" if metadata[0][i][3] != ""
    exporttext += "  :dive => \"#{metadata[0][i][5]}\",\n" if metadata[0][i][5] != ""
    exporttext += "  :fishing => \"#{metadata[0][i][6]}\",\n" if metadata[0][i][6] != ""
    exporttext += "  :surffish => \"#{metadata[0][i][7]}\",\n" if metadata[0][i][7] != ""
    exporttext += "},\n\n"
  end
  for i in 1...$cache.metadata.length
    if metadata[i].nil?
      exporttext += "\##{$cache.mapinfos[i].name}\n"
      exporttext += "#{i} => {}, \n\n"
      next
    end
    exporttext += "\##{$cache.mapinfos[i].name}\n"
    exporttext += "#{i} => { \n"
    exporttext += "  :HealingSpot => #{metadata[i][MetadataHealingSpot].inspect},\n" if metadata[i][MetadataHealingSpot]
    exporttext += "  :MapPosition => #{metadata[i][MetadataMapPosition].inspect},\n" if metadata[i][MetadataMapPosition]
    exporttext += "  :Outdoor => #{metadata[i][MetadataOutdoor]},\n" if metadata[i][MetadataOutdoor]
    exporttext += "  :ShowArea => #{metadata[i][MetadataShowArea]},\n" if metadata[i][MetadataShowArea]
    exporttext += "  :Bicycle => #{metadata[i][MetadataBicycle]},\n" if metadata[i][MetadataBicycle]
    exporttext += "  :BicycleAlways => #{metadata[i][MetadataBicycleAlways]},\n" if metadata[i][MetadataBicycleAlways]
    exporttext += "  :Weather => #{metadata[i][MetadataWeather]},\n" if metadata[i][MetadataWeather]
    exporttext += "  :DiveMap => #{metadata[i][MetadataDiveMap]},\n" if metadata[i][MetadataDiveMap]
    exporttext += "  :DarkMap => #{metadata[i][MetadataDarkMap]},\n" if metadata[i][MetadataDarkMap]
    exporttext += "  :SafariMap => #{metadata[i][MetadataSafariMap]},\n" if metadata[i][MetadataSafariMap]
    exporttext += "  :SnapEdges => #{metadata[i][MetadataSnapEdges]},\n" if metadata[i][MetadataSnapEdges]
    exporttext += "  :Dungeon => #{metadata[i][MetadataDungeon]},\n" if metadata[i][MetadataDungeon]
    exporttext += "  :BattleBack => \"#{metadata[i][MetadataBattleBack]}\",\n" if metadata[i][MetadataBattleBack]
    exporttext += "  :WildBattleBGM => \"#{metadata[i][MetadataMapWildBattleBGM]}\",\n" if metadata[i][MetadataMapWildBattleBGM]
    exporttext += "  :TrainerBattleBGM => \"#{metadata[i][MetadataMapTrainerBattleBGM]}\",\n" if metadata[i][MetadataMapTrainerBattleBGM]
    exporttext += "  :WildVictoryBGM => \"#{metadata[i][MetadataMapWildVictoryBGM]}\",\n" if metadata[i][MetadataMapWildVictoryBGM]
    exporttext += "  :TrainerVictoryBGM => \"#{metadata[i][MetadataMapTrainerVictoryBGM]}\",\n" if metadata[i][MetadataMapTrainerVictoryBGM]
    exporttext += "  :MapSize => #{metadata[i][MetadataMapSize]},\n" if metadata[i][MetadataMapSize]
    exporttext += "},\n\n"
  end
  exporttext += "}\n"
  File.open(definition_file_path("metatext.rb"), "w") { |f|
    f.write(exporttext)
  }
end

def trainTypesDump
  exporttext = "TTYPEHASH = {\n"
  for ttype in $cache.trainertypes
    next if !ttype || ttype.empty?

    exporttext += ":#{getConstantName(PBTrainers, ttype[0])} => {\n"
    exporttext += "  :ID => #{ttype[0]},\n"
    exporttext += "  :title => \"#{ttype[2]}\",\n"
    exporttext += "  :skill => #{ttype[8]},\n"
    exporttext += "  :moneymult => #{ttype[3]},\n" if ttype[3] != 0
    exporttext += "  :battleBGM => \"#{ttype[4]}\",\n" if ttype[4]
    exporttext += "  :winBGM => \"#{ttype[5]}\",\n" if ttype[5]
    exporttext += "},\n\n"
  end
  exporttext += "}\n"
  File.open(definition_file_path("ttypetext.rb"), "w") { |f|
    f.write(exporttext)
  }
end

def dumpTtypes
  exporttext = "TTYPEHASH = {"
  for symbol, data in $cache.trainertypes
    exporttext += "\n  #{symbol.inspect} => {\n"
    keys = [:ID, :title, :epithet, :skill, :moneymult, :battleBGM, :winBGM, :player, :sprite, :ball]
    for key in keys
      value = [:ID, :epithet, :player].include?(key) ? data.checkFlag?(key) : data.send(key)
      next unless value
      value_string = better_inspect(value)
      exporttext += "    #{key.inspect} => #{value_string},\n"
    end
    exporttext += "  },\n"
  end
  exporttext += "}\n"

  File.open(definition_file_path("ttypetext.rb"), "w") { |f|
    f.write(exporttext)
  }
end

def itemDump(game: nil)
  exporttext = "ITEMHASH = {"
  for i in $cache.items.keys
    item = $cache.items[i]
    exporttext += "\n"
    exporttext += "  :#{i} => {\n"
    exporttext += "    :ID => #{item.checkFlag?(:ID)},\n" if item.checkFlag?(:ID)
    exporttext += "    :name => #{item.name.inspect},\n"
    exporttext += "    :shortname => #{item.shortname.inspect},\n" if item.shortname
    exporttext += "    :unit => #{item.unit.inspect},\n" if item.unit
    exporttext += "    :plural => #{item.plural.inspect},\n" if item.plural && !item.generatedPlural
    exporttext += "    :desc => #{item.desc.inspect},\n" unless item.checkFlag?(:tm)
    exporttext += "    :noArticle => true,\n" if item.checkFlag?(:noArticle)
    exporttext += "    :price => #{item.price},\n" if item.price
    if item.medicine
      unless item.medicine.hp || item.medicine.status || item.medicine.revive || item.medicine.xitem || item.medicine.happiness
        exporttext += "    :medicine => {},\n"
      else
        exporttext += "    :medicine => {\n"
        exporttext += "      :hp => #{formatNumeric(item.medicine.hp)},\n" if item.medicine.hp
        exporttext += "      :status => #{item.medicine.status.inspect},\n" if item.medicine.status
        exporttext += "      :revive => #{formatNumeric(item.medicine.revive)},\n" if item.medicine.revive
        if item.medicine.xitem
          stat, amount = item.medicine.xitem[:stat], item.medicine.xitem[:amount]
          statsym = PBStats.constants.find { |const| PBStats.const_get(const) == stat }
          statstr = "PBStats::#{statsym}"
          exporttext += "      :xitem => { stat: #{statstr}, amount: #{amount} },\n"
        end
        exporttext += "      :happiness => #{item.medicine.happiness.inspect},\n" if item.medicine.happiness
        exporttext += "    },\n"
      end
    end
    exporttext += "    :battleitem => true,\n" if item.checkFlag?(:battleitem)
    exporttext += "    :mail => true,\n" if item.checkFlag?(:mail)
    exporttext += "    :ball => true,\n" if item.checkFlag?(:ball)
    if item.berry
      exporttext += "    :berry => {\n"
      exporttext += "      :naturaltype => #{item.berry.naturaltype.inspect},\n" if item.berry.naturaltype
      exporttext += "      :naturalpower => #{item.berry.naturalpower},\n" if item.berry.naturalpower
      exporttext += "      :flavors => #{item.berry.flavors.inspect},\n" if item.berry.flavors
      exporttext += "      :resist => #{item.berry.resisttype.inspect},\n" if item.berry.resisttype
      exporttext += "      :pinch => true,\n" if item.berry.pinch
      exporttext += "      :time => #{item.berry.time.inspect},\n" if item.berry.time
      exporttext += "      :yield => #{item.berry.yield.inspect},\n" if item.berry.yield
      exporttext += "    },\n"
    end
    exporttext += "    :keyitem => true,\n" if item.checkFlag?(:keyitem)
    exporttext += "    :showQuantity => true,\n" if item.checkFlag?(:showQuantity)
    exporttext += "    :overworld => true,\n" if item.checkFlag?(:overworld)
    exporttext += "    :evoitem => true,\n" if item.checkFlag?(:evoitem)
    exporttext += "    :tm => :#{item.checkFlag?(:tm)},\n" if item.checkFlag?(:tm)
    exporttext += "    :crystal => true,\n" if item.checkFlag?(:crystal)
    exporttext += "    :zcrystal => #{item.zmove.inspect},\n" if item.zmove
    exporttext += "    :crest => true,\n" if item.checkFlag?(:crest)
    exporttext += "    :noUseInBattle => true,\n" if item.checkFlag?(:noUseInBattle)
    exporttext += "    :noUse => true,\n" if item.checkFlag?(:noUse)
    exporttext += "    :utilityhold => true,\n" if item.checkFlag?(:utilityhold)
    exporttext += "    :battlehold => true,\n" if item.checkFlag?(:battlehold)
    exporttext += "    :consumehold => true,\n" if item.checkFlag?(:consumehold)
    exporttext += "    :incense => true,\n" if item.checkFlag?(:incense)
    exporttext += "    :typeboost => \:#{item.checkFlag?(:typeboost)}\,\n" if item.checkFlag?(:typeboost)
    exporttext += "    :plate => true,\n" if item.checkFlag?(:plate)
    exporttext += "    :memory => #{item.checkFlag?(:memory).inspect},\n" if item.checkFlag?(:memory)
    exporttext += "    :flingdamage => #{item.checkFlag?(:flingdamage).inspect},\n" if item.checkFlag?(:flingdamage)
    exporttext += "    :gem => true,\n" if item.checkFlag?(:gem)
    exporttext += "    :application => true,\n" if item.checkFlag?(:application)
    exporttext += "    :fossil => true,\n" if item.checkFlag?(:fossil)
    exporttext += "    :nectar => true,\n" if item.checkFlag?(:nectar)
    exporttext += "    :justsell => true,\n" if item.checkFlag?(:justsell)
    exporttext += "    :pokehold => true,\n" if item.checkFlag?(:pokehold)
    exporttext += "    :legendhold => true,\n" if item.checkFlag?(:legendhold)
    exporttext += "    :healing => true,\n" if item.checkFlag?(:healing)
    exporttext += "    :revival => true,\n" if item.checkFlag?(:revival)
    exporttext += "    :status => true,\n" if item.checkFlag?(:status)
    exporttext += "    :pprestore => true,\n" if item.checkFlag?(:pprestore)
    exporttext += "    :levelup => true,\n" if item.checkFlag?(:levelup)
    exporttext += "    :evup => true,\n" if item.checkFlag?(:evup)
    exporttext += "    :repeatableUse => true,\n" if item.checkFlag?(:repeatableUse)
    exporttext += "    :mint => #{item.checkFlag?(:mint).inspect},\n" if item.checkFlag?(:mint)
    exporttext += "    :general => true,\n" if item.checkFlag?(:general)
    exporttext += "    :important => true,\n" if item.checkFlag?(:important)
    exporttext += "    :niche => true,\n" if item.checkFlag?(:niche)
    exporttext += "    :keys => true,\n" if item.checkFlag?(:keys)
    exporttext += "    :image => #{item.checkFlag?(:image).inspect},\n" if item.checkFlag?(:image)
    exporttext += "    :story => true,\n" if item.checkFlag?(:story)
    exporttext += "    :questitem => true,\n" if item.checkFlag?(:questitem)
    exporttext += "    :sidequest => true,\n" if item.checkFlag?(:sidequest)
    exporttext += "    :legendary => true,\n" if item.checkFlag?(:legendary)
    exporttext += "  },\n"
  end
  exporttext += "}\n"
  file = Reborn && Gen >= 9 ? "itemtext_modern.rb" : "itemtext.rb"
  File.open(definition_file_path(file, game: game), "w") { |f|
    f.write(exporttext)
  }
end

def itemDumpLegacy
  exclusions = (21..27).to_a + (454..464).to_a + (493..496).to_a + [50, 513]
  overworld = (1..11).to_a + [49, 690]
  evoitem = (12..20).to_a + (202..211).to_a + [692, 520, 580, 572, 193, 194, 109, 110, 105, 808, 809, 810, 811]
  utilityhold = (75..79).to_a + (120..126).to_a + [873, 70]
  battlehold = (80..94).to_a + (100..108).to_a - [105] + (111..119).to_a + [68, 71, 543, 573, 693, 648, 74, 67, 69, 849, 852]
  consumehold = (95..99).to_a + (774..777).to_a + [114, 579, 850, 66, 72, 73, 560, 576, 818, 819, 851]
  incense = (127..135).to_a
  typehold = (136..152).to_a
  plate = (153..168).to_a + [570]
  memory = (694..710).to_a
  gem = (169..185).to_a + [660]
  questitem = [40, 50, 59, 60, 61, 62, 65, 592, 594, 595, 597, 598, 604, 607, 611, 614]
  application = (669..682).to_a
  fossil = (28..36).to_a + [556, 574, 814, 815, 816, 817]
  nectar = (713..716).to_a
  justsell = (37..58).to_a - [40, 49, 50] + [63, 64, 212, 213, 214, 215, 216, 846]
  pokehold = (186..191).to_a
  legendhold = (195..201).to_a + [192, 812, 813]
  healing =  [217, 218, 219, 612, 220, 221, 234, 237, 238, 239, 711, 240, 857, 241, 242, 533, 523, 524, 605, 236, 593]
  revival = [532, 232, 233, 244, 222]
  status = [228, 243, 235, 229, 230, 231, 561, 691, 223, 224, 225, 226, 227, 527, 528, 529, 530, 531]
  pprestore = [245, 246, 247, 248]
  levelup = [526, 820, 821, 822, 823, 824, 263, 581]
  evup = (249..262).to_a + (642..647).to_a + [865, 863, 806, 848, 872, 861]
  mint = (825..845).to_a
  general = [606, 566, 516, 503, 507, 508, 509, 510, 517, 518, 504, 505, 506, 799, 866]
  important = [514, 512, 804, 807, 589, 590, 847, 869, 870, 871]
  niche = [511, 513, 608, 687, 688, 689]
  story = [525, 535, 778, 805, 534, 609, 616, 641, 800, 801, 802, 803, 856, 868]
  sidequest = [555, 596, 613, 599, 661, 683, 684, 685, 665, 666, 667, 668, 795, 796, 798]
  keys = [515, 521, 522, 536, 591, 600, 601, 602, 603, 615, 640, 686, 662, 663, 664, 794, 797, 862, 858, 859, 860]
  lakekey = [649, 650, 651, 652, 653, 654, 655, 656, 657, 658, 659]
  legendary = [854, 855, 519, 587, 588, 638, 779, 780]
  crest = (823..835).to_a + [861, 893, 894, 1039] + (864..877).to_a + (879..882).to_a + (1025..1035).to_a
  exporttext = "ITEMHASH = {\n"
  for item in $cache.items
    next if item.nil? || item.empty? || (21..27).to_a.include?(item[ITEMID]) || item[ITEMID] == 515 || item[ITEMID] == 560

    begin
      exporttext += ":#{getConstantName(PBItems, item[ITEMID])} => {\n"
    rescue
      next
    end
    exporttext += "  :ID => #{item[ITEMID]},\n"
    exporttext += "  :name => \"#{item[ITEMNAME]}\",\n"
    exporttext += "  :desc => \"#{item[ITEMDESC]}\",\n"
    exporttext += "  :price => #{item[ITEMPRICE]},\n"
    case item[ITEMPOCKET]
      when 2 then pocket = "  :medicine => true,\n"
      when 7 then exporttext += "  :battleitem => true,\n"
    end
    case item[ITEMTYPE]
      when 2 then exporttext += "  :mail => true,\n"
      when 4 then exporttext += "  :ball => true,\n"
      when 5 then exporttext += "  :berry => true,\n"
      when 6 then exporttext += "  :keyitem => true,\n"
      when 7, 8 then exporttext += "  :crystal => true,\n"
    end
    exporttext += "  :tm => :#{getConstantName(PBMoves, item[ITEMMACHINE])}\n" if item[ITEMMACHINE] != 0
    if Reborn
      exporttext += "  :overworld => true,\n" if overworld.include?(item[ITEMID])
      exporttext += "  :evoitem => true,\n" if evoitem.include?(item[ITEMID])
      exporttext += "  :utilityhold => true,\n" if utilityhold.include?(item[ITEMID])
      exporttext += "  :battlehold => true,\n" if battlehold.include?(item[ITEMID])
      exporttext += "  :consumehold => true,\n" if consumehold.include?(item[ITEMID])
      exporttext += "  :incense => true,\n" if incense.include?(item[ITEMID])
      exporttext += "  :typehold => true,\n" if typehold.include?(item[ITEMID])
      exporttext += "  :plate => true,\n" if plate.include?(item[ITEMID])
      exporttext += "  :memory => true,\n" if memory.include?(item[ITEMID])
      exporttext += "  :gem => true,\n" if gem.include?(item[ITEMID])
      exporttext += "  :questitem => true,\n" if questitem.include?(item[ITEMID])
      exporttext += "  :application => true,\n" if application.include?(item[ITEMID])
      exporttext += "  :image => \"application\",\n" if application.include?(item[ITEMID])
      exporttext += "  :fossil => true,\n" if fossil.include?(item[ITEMID])
      exporttext += "  :nectar => true,\n" if nectar.include?(item[ITEMID])
      exporttext += "  :justsell => true,\n" if justsell.include?(item[ITEMID])
      exporttext += "  :pokehold => true,\n" if pokehold.include?(item[ITEMID])
      exporttext += "  :legendhold => true,\n" if legendhold.include?(item[ITEMID])
      exporttext += "  :healing => true,\n" if healing.include?(item[ITEMID])
      exporttext += "  :revival => true,\n" if revival.include?(item[ITEMID])
      exporttext += "  :status => true,\n" if status.include?(item[ITEMID])
      exporttext += "  :pprestore => true,\n" if pprestore.include?(item[ITEMID])
      exporttext += "  :levelup => true,\n" if levelup.include?(item[ITEMID])
      exporttext += "  :evup => true,\n" if evup.include?(item[ITEMID])
      exporttext += "  :mint => true,\n" if mint.include?(item[ITEMID])
      exporttext += "  :general => true,\n" if general.include?(item[ITEMID])
      exporttext += "  :important => true,\n" if important.include?(item[ITEMID])
      exporttext += "  :niche => true,\n" if niche.include?(item[ITEMID])
      exporttext += "  :story => true,\n" if story.include?(item[ITEMID])
      exporttext += "  :sidequest => true,\n" if sidequest.include?(item[ITEMID])
      exporttext += "  :keys => true,\n" if keys.include?(item[ITEMID])
      exporttext += "  :image => \"key\",\n" if (649..659).to_a.include?(item[ITEMID])
      exporttext += "  :legendary => true,\n" if legendary.include?(item[ITEMID])
    end
    if Rejuv
      exporttext += "  :crest => true,\n" if crest.include?(item[ITEMID])
    end
    exporttext += "},\n\n"
  end
  exporttext += "}\n"
  file = Reborn && Gen >= 9 ? "itemtext_modern.rb" : "itemtext.rb"
  File.open(definition_file_path(file), "w") { |f|
    f.write(exporttext)
  }
end

def itemDumpCurrent
  exclusions, memory, mint, fossil, evup, gem, utilityhold, levelup, nectar, extramegastones, zcrystals, crest, legendhold, application, pokehold, megastones, pprestore, consumehold, keys, story, legendary, questitem, important, incense, plate, evoitem, justsell, niche, overworld, revival, status, general, battlehold, sidequest, healing, resistberries, pinchberries = Array.new(36) {
    []
  }
  if Reborn
    exclusions = (21..27).to_a + (454..464).to_a + (493..496).to_a + [50, 513]
    memory = (694..710).to_a
    mint = (825..845).to_a
    fossil = (28..36).to_a + [556, 574] + [814, 815, 816, 817]
    evup = (249..262).to_a + (642..647).to_a + [865, 863, 806, 848, 872, 861]
    levelup = [263, 526, 581, 820, 821, 822, 823, 824]
    utilityhold = (75..79).to_a + (120..126).to_a + [70, 873]
    gem = (169..185).to_a + [660]
    legendhold = (195..201).to_a + [192, 812, 813]
    application = (669..682).to_a
    pokehold = (186..191).to_a
    megastones = (537..542).to_a + (544..554).to_a + [557, 559, 562, 564, 566, 567, 568, 569, 575, 577, 578] + (617..635).to_a
    pprestore = (245..248).to_a
    consumehold = (95..99).to_a + (774..777).to_a + [114, 579, 850, 66, 72, 73, 560, 576, 818, 819, 851]
    keys = [515, 521, 522, 536, 591, 600, 601, 602, 603, 615, 640, 649, 650, 651, 652, 653, 654, 655, 656, 657, 658,
            659, 686, 662, 663, 664, 794, 797, 862, 858, 859, 860]
    story = [525, 535, 778, 805, 534, 609, 616, 641, 800, 801, 802, 803, 856, 868]
    legendary = [854, 855, 519, 587, 588, 638, 779, 780]
    questitem = [40, 50, 59, 60, 61, 62, 65, 592, 594, 595, 597, 598, 604, 607, 611, 614]
    important = [514, 512, 804, 807, 589, 590, 847, 869, 870, 871]
    incense = (127..135).to_a
    plate = (153..168).to_a + [570]
    evoitem = (12..20).to_a + (202..211).to_a + [692, 520, 580, 572, 193, 194, 109, 110, 105, 808, 809, 810, 811]
    justsell = (37..58).to_a - [40, 49, 50] + [63, 64, 212, 213, 214, 215, 216, 846]
    niche = [511, 513, 608, 687, 688, 689]
    overworld = (1..11).to_a + [49, 690]
    revival = [532, 232, 233, 244, 222]
    status = [228, 243, 235, 229, 230, 231, 561, 691, 223, 224, 225, 226, 227, 527, 528, 529, 530, 531]
    general = [606, 566, 516, 503, 507, 508, 509, 510, 517, 518, 504, 505, 506, 799, 866]
    battlehold = (80..94).to_a + (100..108).to_a - [105] + (111..119).to_a + [68, 71, 543, 573, 693, 648, 74, 67, 69, 849, 852]
    sidequest = [555, 596, 613, 599, 661, 683, 684, 685, 665, 666, 667, 668, 795, 796, 798]
    healing = [217, 218, 219, 612, 220, 221, 234, 237, 238, 239, 711, 240, 857, 241, 242, 533, 523, 524, 605, 236, 593]
    resistberries = (424..440).to_a + [571]
    pinchberries = (399..403).to_a + (441..450).to_a - [448]
  elsif Rejuv
    exclusions = (21..27).to_a + (493..496).to_a + [50, 513, 515, 560]
    memory = (694..710).to_a
    mint = (917..937).to_a
    fossil = (28..36).to_a + [556, 574] + [902, 903, 904, 905]
    evup = (249..262).to_a + (1057..1066).to_a
    utilityhold = (75..79).to_a + (120..126).to_a + [70, 1056]
    levelup = (912..916).to_a + [263, 526, 581]
    gem = (169..185).to_a + [660]
    extramegastones = (989..1019).to_a + (537..542).to_a + (544..554).to_a + [557] + [559] + [562] + (564..565).to_a + (568..569).to_a + [575] + (577..578).to_a + [616] + [661] + (781..782).to_a + (805..819).to_a + [1036]
    zcrystals = (718..772).to_a + (842..852).to_a + [1036]
    crest = (823..835).to_a + [861, 893, 894, 1039] + (864..877).to_a + (879..882).to_a + (1025..1035).to_a
    legendhold = (195..201).to_a + [192, 900, 901]
    pokehold = (186..191).to_a
    pprestore = (245..248).to_a
    consumehold = (95..99).to_a + (774..777).to_a + [114, 579, 909, 66, 72, 73, 560, 576, 906, 907, 910]
    legendary = [519, 522, 523, 1067, 840, 841]
    incense = (127..135).to_a
    plate = (153..168).to_a + [570]
    evoitem = (12..20).to_a + (202..211).to_a + [692, 535, 580, 572, 193, 194, 109, 110, 105, 896, 897, 898, 899]
    justsell = (37..58).to_a - [40, 49, 50] + [63, 64, 212, 213, 214, 215, 216]
    overworld = (1..11).to_a + [49, 690]
    revival = [649, 232, 233, 244, 222]
    status = [228, 243, 235, 229, 230, 231, 561, 691, 223, 224, 225, 226, 227]
    battlehold = (80..94).to_a + (100..108).to_a - [105] + (111..119).to_a + [68, 71, 543, 573, 693, 648, 74, 67, 69, 908, 911]
    healing =  [217, 218, 219, 680, 220, 221, 234, 237, 238, 239, 240, 241, 242, 533, 523, 524, 629, 236, 536]
    resistberries = (424..440).to_a + [571]
    pinchberries = (399..403).to_a + (441..450).to_a - [448]
  elsif Desolation
    exclusions = [49]
    memory = (655..670).to_a
    mint = (781..801).to_a
    fossil = (21..35).to_a
    evup = (251..264).to_a + (756..762).to_a
    gem = (169..186).to_a
    utilityhold = (74..78).to_a + (119..125).to_a + [69, 775]
    levelup = (776..780).to_a + [265, 532, 593]
    nectar = (673..676).to_a
    legendhold = (196..202).to_a + [193, 767, 768]
    pokehold = (186..191).to_a
    pprestore = (247..250).to_a
    consumehold = (94..98).to_a + (733..736).to_a + [113, 591, 772, 65, 71, 72, 753, 590, 769, 770, 773]
    legendary = [527, 528, 529, 755, 737, 738]
    incense = (126..134).to_a
    plate = (152..168).to_a
    evoitem = (12..20).to_a + (203..212).to_a + [653, 592, 588, 572, 194, 195, 110, 111, 106, 763, 764, 765, 767]
    justsell = (36..57).to_a - [39, 48, 49] + [62, 63, 212, 213, 214, 215, 216]
    overworld = (1..11).to_a + [49, 651]
    revival = [234, 235, 246, 224]
    status = [230, 245, 237, 231, 232, 231, 587, 652, 225, 226, 227, 228, 229]
    battlehold = (79..93).to_a + (99..107).to_a - [104] + (110..118).to_a + [67, 70, 535, 589, 654, 648, 73, 66, 68, 771, 774]
    healing =  [218, 219, 220, 612, 221, 222, 236, 239, 240, 241, 672, 242, 857, 243, 244, 238, 534]
    resistberries = (435..451).to_a + [466]
    pinchberries = (410..414).to_a + (452..460).to_a - [459]
  end
  typeboost = {
    :ELECTRIC => [:ELECTRICGEM, :MAGNET, :ZAPPLATE],
    :NORMAL => [:NORMALGEM, :SILKSCARF],
    :FIRE => [:FIREGEM, :CHARCOAL, :FLAMEPLATE],
    :WATER => [:WATERGEM, :SPLASHPLATE, :SEAINCENSE, :WAVEINCENSE, :MYSTICWATER],
    :GRASS => [:GRASSGEM, :MIRACLESEED, :MEADOWPLATE, :ROSEINCENSE],
    :FIGHTING => [:FIGHTINGGEM, :FISTPLATE, :BLACKBELT],
    :ROCK => [:ROCKGEM, :ROCKINCENSE, :STONEPLATE, :HARDSTONE],
    :PSYCHIC => [:PSYCHICGEM, :MINDPLATE, :TWISTEDSPOON, :ODDINCENSE],
    :GHOST => [:GHOSTGEM, :SPOOKYPLATE, :SPELLTAG],
    :STEEL => [:STEELGEM, :IRONPLATE, :METALCOAT],
    :FLYING => [:FLYINGGEM, :SKYPLATE, :SHARPBEAK],
    :GROUND => [:GROUNDGEM, :EARTHPLATE, :SOFTSAND],
    :DRAGON => [:DRAGONGEM, :DRACOPLATE, :DRAGONFANG],
    :POISON => [:POISONGEM, :TOXICPLATE, :POISONBARB],
    :BUG => [:BUGGEM, :INSECTPLATE, :SILVERPOWDER],
    :FAIRY => [:FAIRYGEM, :PIXIEPLATE, :FAIRYFEATHER],
    :DARK => [:DARKGEM, :DREADPLATE, :BLACKGLASSES],
    :ICE => [:ICEGEM, :ICICLEPLATE, :NEVERMELTICE],
  }
  megadescrip = "Have %s hold it, and this stone will enable it to Mega Evolve during battle."
  exporttext = "ITEMHASH = {\n"
  for i in $cache.items.keys
    item = $cache.items[i]
    next if item.nil? || exclusions.include?(item.checkFlag?(:ID))

    exporttext += "  :#{i} => {\n"
    exporttext += "    :ID => #{item.checkFlag?(:ID)},\n" if item.checkFlag?(:ID)
    exporttext += "    :name => \"#{item.name}\",\n"
    exporttext += "    :desc => \"#{item.desc}\",\n"
    exporttext += "    :price => #{item.price},\n"
    exporttext += "    :medicine => true,\n" if item.checkFlag?(:medicine) || (healing.include?(item.checkFlag?(:ID)) || levelup.include?(item.checkFlag?(:ID)) || pprestore.include?(item.checkFlag?(:ID)) || status.include?(item.checkFlag?(:ID)) || mint.include?(item.checkFlag?(:ID)) || evup.include?(item.checkFlag?(:ID)) || revival.include?(item.checkFlag?(:ID)))
    exporttext += "    :battleitem => true,\n" if item.checkFlag?(:battleitem)
    exporttext += "    :mail => true,\n" if item.checkFlag?(:mail)
    exporttext += "    :ball => true,\n" if item.checkFlag?(:ball)
    exporttext += "    :berry => true,\n" if item.checkFlag?(:berry)
    exporttext += "    :flavors => true,\n" if item.checkFlag?(:flavors)
    exporttext += "    :keyitem => true,\n" if item.checkFlag?(:keyitem)
    exporttext += "    :crystal => true,\n" if item.checkFlag?(:crystal) || megastones.include?(item.checkFlag?(:ID))
    exporttext += "    :zcrystal => true,\n" if item.checkFlag?(:zcrystal)
    exporttext += "    :tm => :#{item.checkFlag?(:tm)},\n" if item.checkFlag?(:tm) != false
    exporttext += "    :overworld => true,\n" if item.checkFlag?(:overworld) || overworld.include?(item.checkFlag?(:ID))
    exporttext += "    :evoitem => true,\n" if item.checkFlag?(:evoitem) || evoitem.include?(item.checkFlag?(:ID))
    exporttext += "    :crest => true,\n" if item.checkFlag?(:crest)
    exporttext += "    :noUseInBattle => true,\n" if !(ItemHandlers.hasBattleUseOnBattler(i) || ItemHandlers.hasBattleUseOnPokemon(i) || ItemHandlers.hasBattleUseOnPokemon(i))
    exporttext += "    :noUse => true,\n" if !(ItemHandlers.hasOutHandler(i) || (pbIsTM?(i)))
    exporttext += "    :utilityhold => true,\n" if item.checkFlag?(:utilityhold)
    exporttext += "    :battlehold => true,\n" if item.checkFlag?(:battlehold) || battlehold.include?(item.checkFlag?(:ID))
    exporttext += "    :consumehold => true,\n" if item.checkFlag?(:consumehold) || consumehold.include?(item.checkFlag?(:ID))
    exporttext += "    :resistberry => true,\n" if item.checkFlag?(:resistberry) || resistberries.include?(item.checkFlag?(:ID))
    exporttext += "    :pinchberry => true,\n" if item.checkFlag?(:pinchberry) || pinchberries.include?(item.checkFlag?(:ID))
    exporttext += "    :incense => true,\n" if item.checkFlag?(:incense) || incense.include?(item.checkFlag?(:ID))
    if item.checkFlag?(:typeboost)
      exporttext += "    :typeboost => \:#{item.checkFlag?(:typeboost)}\,\n"
    else
      typeboost.each_pair { |typeboost, typeboostitems|
        exporttext += "    :typeboost => \:#{typeboost}\,\n" if typeboostitems.include?(i)
      }
    end
    exporttext += "    :plate => true,\n" if item.checkFlag?(:plate) || plate.include?(item.checkFlag?(:ID))
    exporttext += "    :memory => #{item.checkFlag?(:memory).inspect},\n" if item.checkFlag?(:memory) || memory.include?(item.checkFlag?(:ID))
    exporttext += "    :gem => true,\n" if item.checkFlag?(:gem) || gem.include?(item.checkFlag?(:ID))
    exporttext += "    :questitem => true,\n" if item.checkFlag?(:questitem) || questitem.include?(item.checkFlag?(:ID))
    exporttext += "    :application => true,\n" if item.checkFlag?(:application) || application.include?(item.checkFlag?(:ID))
    exporttext += "    :image => \"application\",\n" if item.checkFlag?(:application) || application.include?(item.checkFlag?(:ID))
    exporttext += "    :fossil => true,\n" if item.checkFlag?(:fossil) || fossil.include?(item.checkFlag?(:ID))
    exporttext += "    :nectar => true,\n" if item.checkFlag?(:nectar) || nectar.include?(item.checkFlag?(:ID))
    exporttext += "    :justsell => true,\n" if item.checkFlag?(:justsell) || justsell.include?(item.checkFlag?(:ID))
    exporttext += "    :pokehold => true,\n" if item.checkFlag?(:pokehold) || pokehold.include?(item.checkFlag?(:ID))
    exporttext += "    :legendhold => true,\n" if item.checkFlag?(:legendhold) || legendhold.include?(item.checkFlag?(:ID))
    exporttext += "    :healing => true,\n" if item.checkFlag?(:healing) || healing.include?(item.checkFlag?(:ID))
    exporttext += "    :revival => true,\n" if item.checkFlag?(:revival) || revival.include?(item.checkFlag?(:ID))
    exporttext += "    :status => true,\n" if item.checkFlag?(:status) || status.include?(item.checkFlag?(:ID))
    exporttext += "    :pprestore => true,\n" if item.checkFlag?(:pprestore) || pprestore.include?(item.checkFlag?(:ID))
    exporttext += "    :levelup => true,\n" if item.checkFlag?(:levelup) || levelup.include?(item.checkFlag?(:ID))
    exporttext += "    :evup => true,\n" if item.checkFlag?(:evup) || evup.include?(item.checkFlag?(:ID))
    exporttext += "    :mint => true,\n" if item.checkFlag?(:mint) || mint.include?(item.checkFlag?(:ID))
    exporttext += "    :general => true,\n" if item.checkFlag?(:general) || general.include?(item.checkFlag?(:ID))
    exporttext += "    :important => true,\n" if item.checkFlag?(:important) || important.include?(item.checkFlag?(:ID))
    exporttext += "    :niche => true,\n" if item.checkFlag?(:niche) || niche.include?(item.checkFlag?(:ID))
    exporttext += "    :story => true,\n" if item.checkFlag?(:story) || story.include?(item.checkFlag?(:ID))
    exporttext += "    :sidequest => true,\n" if item.checkFlag?(:sidequest) || sidequest.include?(item.checkFlag?(:ID))
    exporttext += "    :keys => true,\n" if item.checkFlag?(:keys) || keys.include?(item.checkFlag?(:ID))
    exporttext += "    :image => \"keys\",\n" if item.checkFlag?(:keys) || keys.include?(item.checkFlag?(:ID))
    exporttext += "    :legendary => true,\n" if item.checkFlag?(:legendary) || legendary.include?(item.checkFlag?(:ID))
    exporttext += "  },\n\n"
  end
  exporttext += "}\n"
  File.open(definition_file_path("itemtext.rb"), "w") { |f|
    f.write(exporttext)
  }
end

def monDump(mons = $cache.pkmn, game: nil, file: nil)
  exporttext = "MONHASH = {\n"
  cprint "Beginning #{"Pokemon".yellow} dump...\n"
  mons.each { |mon, wrapper|
    cprint "Pokemon #{mon.to_s.yellow}"
    exporttext += wrapper.export
    cprint "             \r"
  }
  exporttext += "}\n"
  cprint "Success.                                                \n".green
  file = Reborn && Gen >= 9 ? "montext_modern.rb" : "montext.rb" if file.nil?
  File.open(definition_file_path(file, game: game), "w") { |f|
    f.write(exporttext)
  }
end

def moveDump(game: nil)
  # updated to work with the new cache set up
  added = []
  exporttext = "MOVEHASH = {"
  for i in $cache.moves.keys
    move = $cache.moves[i]
    exporttext += "\n"
    exporttext += getHeaderForMoveDump(i, added)
    exporttext += "  :#{i} => {\n"
    exporttext += "    :ID => #{move.checkFlag?(:ID)},\n" if move.checkFlag?(:ID)
    exporttext += "    :name => \"#{move.name}\",\n"

    if (PBStuff::ANIMATIONDUMMIES - PBStuff::SHOWCASEMOVES.keys).include?(i)
      exporttext += "  },\n"
      next
    end

    exporttext += "    :longname => \"#{move.checkFlag?(:longname)}\",\n" if move.checkFlag?(:longname)
    exporttext += "    :desc => \"#{move.desc}\",\n"
    exporttext += sprintf("    :function => 0x%03X,\n", move.function)
    exporttext += "    :type => :#{move.type},\n"
    exporttext += "    :secondtype => :#{move.checkFlag?(:secondtype)},\n" if move.checkFlag?(:secondtype)
    exporttext += "    :category => :#{move.category},\n"
    exporttext += "    :basedamage => #{move.basedamage},\n"
    comment = [:FUTURESIGHT, :DOOMDESIRE].include?(i) ? " # Bypass accuracy check when using the move." : ""
    exporttext += "    :accuracy => #{move.accuracy},#{comment}\n"
    exporttext += "    :maxpp => #{move.maxpp},\n"
    exporttext += "    :effect => #{move.checkFlag?(:effect)},\n" if move.checkFlag?(:effect)
    exporttext += "    :moreeffect => #{move.checkFlag?(:moreeffect)},\n" if move.checkFlag?(:moreeffect)
    exporttext += "    :target => :#{move.target},\n"
    exporttext += "    :priority => #{move.priority},\n" if move.priority && move.priority != 0
    exporttext += "    :contact => true,\n" if move.checkFlag?(:contact)
    exporttext += "    :bypassprotect => true,\n" if move.checkFlag?(:bypassprotect)
    exporttext += "    :magiccoat => true,\n" if move.checkFlag?(:magiccoat)
    exporttext += "    :snatchable => true,\n" if move.checkFlag?(:snatchable)
    exporttext += "    :nonmirror => true,\n" if move.checkFlag?(:nonmirror)
    exporttext += "    :defrost => true,\n" if move.checkFlag?(:defrost)
    exporttext += "    :highcrit => true,\n" if move.checkFlag?(:highcrit)
    exporttext += "    :punchmove => true,\n" if move.checkFlag?(:punchmove)
    exporttext += "    :healingmove => true,\n" if move.checkFlag?(:healingmove)
    exporttext += "    :drainingmove => true,\n" if move.checkFlag?(:drainingmove)
    exporttext += "    :soundmove => true,\n" if move.checkFlag?(:soundmove)
    exporttext += "    :gravityblocked => true,\n" if move.checkFlag?(:gravityblocked)
    exporttext += "    :antiminimize => true,\n" if move.checkFlag?(:antiminimize)
    exporttext += "    :beammove => true,\n" if move.checkFlag?(:beammove)
    exporttext += "    :sharpmove => true,\n" if move.checkFlag?(:sharpmove)
    exporttext += "    :windmove => true,\n" if move.checkFlag?(:windmove)
    exporttext += "    :powdermove => true,\n" if move.checkFlag?(:powdermove)
    exporttext += "    :dancemove => true,\n" if move.checkFlag?(:dancemove)
    exporttext += "    :ballmove => true,\n" if move.checkFlag?(:ballmove)
    exporttext += "    :bombmove => true,\n" if move.checkFlag?(:bombmove)
    exporttext += "    :bitingmove => true,\n" if move.checkFlag?(:bitingmove)
    exporttext += "    :pulsemove => true,\n" if move.checkFlag?(:pulsemove)
    exporttext += "    :explosivemove => true,\n" if move.checkFlag?(:explosivemove)
    exporttext += "    :mentalmove => true,\n" if move.checkFlag?(:mentalmove)
    exporttext += "    :cooldown => true,\n" if move.checkFlag?(:cooldown)
    exporttext += "    :recoil => #{move.checkFlag?(:recoil)},\n" if move.checkFlag?(:recoil)
    exporttext += "    :chargetime => #{move.checkFlag?(:chargetime)},\n" if move.checkFlag?(:chargetime)
    exporttext += "    :specialmove => true,\n" if move.checkFlag?(:specialmove)
    if move.zmovedata
      exporttext += "    :zmovedata => {\n"
      exporttext += "      :type => #{move.zmovedata.type.inspect},\n" if move.zmovedata.type
      exporttext += "      :basemove => #{move.zmovedata.basemove.inspect},\n" if move.zmovedata.basemove
      exporttext += "      :species => #{move.zmovedata.species.inspect},\n" if move.zmovedata.species
      exporttext += "      :intercept => true,\n" if move.zmovedata.intercept
      exporttext += "    },\n"
    end
    exporttext += "  },\n"
  end
  exporttext += "}\n"
  file = Reborn && Gen >= 9 ? "movetext_modern.rb" : "movetext.rb"
  File.open(definition_file_path(file, game: game), "w") { |f|
    f.write(exporttext)
  }
end

def getHeaderForMoveDump(move, added)
  desomoves = [:STARFALL]
  str = ""
  case true
    when PBStuff::ShadowMoves.include?(move) && !added.any? { |i| PBStuff::ShadowMoves.include?(i) }
      str = "  # Shadow moves\n\n"
    when PBStuff::Gen8Moves.include?(move) && !added.any? { |i| PBStuff::Gen8Moves.include?(i) }
      str = "  # Gen 8 moves\n\n"
    when PBStuff::Gen9Moves.include?(move) && !added.any? { |i| PBStuff::Gen9Moves.include?(i) }
      str = "  # Gen 9 moves\n\n"
    when PBStuff::ZMOVES.include?(move) && !added.any? { |i| PBStuff::ZMOVES.include?(i) }
      str = "  # Z-Moves\n\n"
    when PBStuff::ANIMATIONDUMMIES.include?(move) && !added.any? { |i| PBStuff::ANIMATIONDUMMIES.include?(i) }
      str = "  # Animation dummies for move animation compilation\n\n"
    when desomoves.include?(move) && !added.any? { |i| desomoves.include?(i) }
      str = "  # Deso custom moves\n\n"
    else return str
  end
  added.push(move)
  return str
end

def encDump(game: nil)
  exporttext = "ENCHASH = {\n"
  $cache.mapdata.each_with_index { |map, id|
    next if map.nil?

    dump = "  #{id} => { \# #{$cache.mapinfos[id].name}\n"
    preface = dump
    dump += "    :landrate => #{map.landrate},\n" unless map.landrate.nil?
    dump += "    :caverate => #{map.caverate},\n" unless map.caverate.nil?
    dump += "    :waterrate => #{map.waterrate},\n" unless map.waterrate.nil?
    dump += "    :lavarate => #{map.lavarate},\n" unless map.lavarate.nil?
    map.EncounterTypes.each do |type|
      typeEncounters = map.send(type)
      next if typeEncounters.nil?

      dump += "    #{type.inspect} => {\n"
      typeEncounters.each do |mon, details|
        dump += "      #{mon.inspect} => #{details.inspect},\n"
      end
      dump += "    },\n"
    end
    if map.OverworldEncs
      dump += "    :Overworld => {\n"
      map.OverworldEncs.each do |symbol, hash|
        dump += "      #{symbol.inspect} => {\n"
        hash.each { |k, v| dump += "        #{k.inspect} => #{better_inspect(v)},\n" }
        dump += "      },\n"
      end
      dump += "    },\n"
    end
    next if dump == preface

    exporttext += dump + "  },\n"
  }
  exporttext += "}\n"
  File.open(definition_file_path("enctext.rb", game: game), "w") { |f|
    f.write(exporttext)
  }
end

def getConstantName(mod, value)
  for c in mod.constants
    return c if mod.const_get(c.to_sym) == value
  end
  raise _INTL("Value {1} not defined by a constant in {2}", value, mod.name)
end

def dumpTeams(game: nil)
  allteams = []
  $cache.trainers.each do |type, trainers|
    trainers.each do |name, teams|
      teams.each do |partyid, team|
        teamid = [name, type, partyid]
        allteams[team.index] = [teamid, team]
      end
    end
  end

  exporttext = "TEAMARRAY = [\n"
  allteams.each do |teamarray|
    teamid = teamarray[0]
    team = teamarray[1]
    baseTeam = nil

    exporttext += "  {\n"
    exporttext += "    :teamid => #{teamid.inspect},\n"
    if team.baseTeam
      exporttext += "    :baseTeam => #{team.baseTeam.inspect},\n"
      ttype, tname, tid = team.baseTeam[1], team.baseTeam[0], team.baseTeam[2]
      baseTeam = $cache.trainers.dig(ttype, tname, tid)
    end

    simple_keys = [:items, :openingLine, :ace, :defeat, :battleBGM, :acemusic, :winBGM, :aceIndex, :sendAceLast, :noShiftStyle, :partySize]
    for key in simple_keys
      exporttext += "    #{key.inspect} => #{team.getValue(key).inspect},\n" if team.shouldWrite?(key, baseTeam)
    end

    # todo trainereffect
    # todo setParty

    if team.shouldWrite?(:party, baseTeam)
      exporttext += "    :mons => [\n"
      team.party.each_with_index do |pkmn, pkmnindex|
        exporttext += "      {\n"
        for key in PokemonBuilderHashKeys
          next unless (key == :aura ? pkmn.has_key?(key) : pkmn[key]) # nil is allowed for aura
          exporttext += "        #{key.inspect} => #{pkmn[key].inspect},\n"
        end
        for key in TeamData::PerPokemonTeamAttributes
          value = team.teamAttributes.dig(key, pkmnindex)
          exporttext += "        #{key.inspect} => #{value.inspect},\n" if value
        end
        exporttext += "      },\n"
      end
      exporttext += "    ],\n"
    end

    exporttext += "  },\n"
  end
  exporttext += "]\n"

  File.open(definition_file_path("trainertext.rb", game: game), "w") { |f|
    f.write(exporttext)
  }
end

def convertTeam
  lines = []
  linenos = []
  lineno = 1
  File.open("PBS/trainers.txt", "rb") { |f|
    FileLineData.file = "PBS/trainers.txt"
    f.each_line { |line|
      line = prepline(line)
      if line != ""
        lines.push(line)
        linenos.push(lineno)
      end
      lineno += 1
    }
  }
  nameoffset = 0
  trainers = []
  trainernames = []
  i = 0; loop do
    break unless i < lines.length

    FileLineData.setLine(lines[i], linenos[i])
    trainername = lines[i]
    FileLineData.setLine(lines[i + 1], linenos[i + 1])
    nameline = strsplit(lines[i + 1], /\s*,\s*/)
    name = nameline[0]
    raise _INTL("Trainer name too long\n{1}", FileLineData.linereport) if name.length >= 0x10000

    trainernames.push(name)
    partyid = 0
    if nameline[1] && nameline[1] != ""
      raise _INTL("Expected a number for the trainer battle ID\n{1}", FileLineData.linereport) if !nameline[1][/^\d+$/]

      partyid = nameline[1].to_i
    end
    FileLineData.setLine(lines[i + 2], linenos[i + 2])
    items = strsplit(lines[i + 2], /\s*,\s*/)
    items[0].gsub!(/^\s+/, "")
    raise _INTL("Expected a number for the number of Pokémon\n{1}", FileLineData.linereport) if !items[0][/^\d+$/]

    numpoke = items[0].to_i
    realitems = []
    for j in 1...items.length # Number of Pokémon and items held by Trainer
      realitems.push(items[j].to_sym)
    end
    pkmn = []
    for j in 0...numpoke
      FileLineData.setLine(lines[i + j + 3], linenos[i + j + 3])
      poke = strsplit(lines[i + j + 3], /\s*,\s*/)
      mon = {}
      poke[0] = poke[0].to_sym
      mon.store(:species, poke[0])
      mon.store(:level, poke[1].to_i) # Level

      if !poke[2] || poke[2] == "" # item
        # next
      else
        mon.store(:item, poke[2].to_sym)
      end

      strmoves = [poke[3], poke[4], poke[5], poke[6]]
      moves = []
      strmoves.each { |mv|
        if mv && mv != ""
          moves.push(mv.to_sym)
        end
      }
      mon.store(:moves, moves) if !moves.empty?

      if !poke[7] || poke[7] == "" # Ability
        # next
      else
        abillist = $cache.pkmn[poke[0]].Abilities
        abillist += [$cache.pkmn[poke[0]].flags[:HiddenAbilities]] if $cache.pkmn[poke[0]].checkFlag?(:HiddenAbilities)
        mon.store(:ability, abillist[poke[7].to_i])
      end
      if !poke[8] || poke[8] == "" # Gender
        # poke[8]=nil
      else
        mon.store(:gender, ["M", "F"][poke[8].to_i])
      end
      if !poke[9] || poke[9] == "" # Form
        # poke[9]=0
      else
        mon.store(:form, poke[9].to_i)
      end
      if !poke[10] || poke[10] == ""
      else
        mon.store(:shiny, true) if csvBoolean!(poke[10].clone) == true # Shiny
      end
      if !poke[11] || poke[11] == ""
      else
        mon.store(:nature, poke[11].to_sym)
      end
      mon.store(:iv, 31) # IVS
      if !poke[13] || poke[13] == "" # Happiness
        # poke[13]=70
      else
        mon.store(:happiness, poke[13].to_i)
      end
      if !poke[14] || poke[14] == "" # Nickname
        # poke[14]=nil
      else
        mon.store(:name, poke[14].to_s)
        #       raise _INTL("Bad nickname: {1} (must be 1-10 characters)\n{2}",poke[14],FileLineData.linereport) if (poke[14].to_s).length>10
      end
      mon.store(:ev, [[85, mon[:level] * 3 / 2].min] * 6)
      poke.flatten! # catch any nils
      pkmn.push(mon)
    end
    i += 3 + numpoke
    trainers.push([trainername, name, realitems, pkmn, partyid])
    nameoffset += name.length
  end

  exporttext = "TEAMARRAY = ["
  for trainer in trainers
    next if trainer.empty?

    exporttext += "{\n"
    exporttext += ":teamid => [\"#{trainer[1]}\",:#{trainer[0]},#{trainer[4]}],\n"
    if !trainer[2].empty?
      exporttext += ":items => ["
      check = 1
      for item in trainer[2]
        exporttext += ":#{item}"
        exporttext += "," if check != trainer[2].length
        check += 1
      end
      exporttext += "],\n"
    end
    exporttext += ":mons => ["
    check = 1
    for mon in trainer[3]
      exporttext += "{\n"
      exporttext += "  :species => :#{mon[:species]},\n"
      exporttext += "  :name => \"#{mon[:name]}\",\n" if mon[:name]
      exporttext += "  :level => #{mon[:level]},\n"
      exporttext += "  :item => :#{mon[:item]},\n" if mon[:item]
      exporttext += "  :moves => #{mon[:moves].inspect},\n" if mon[:moves]
      exporttext += "  :ability => :#{mon[:ability]},\n" if mon[:ability]
      exporttext += "  :gender => #{mon[:gender].inspect},\n" if mon[:gender]
      exporttext += "  :form => #{mon[:form]},\n" if mon[:form]
      exporttext += "  :shiny => true,\n" if mon[:shiny]
      exporttext += "  :nature => :#{mon[:nature]},\n" if mon[:nature]
      exporttext += "  :iv => #{mon[:iv]},\n" if mon[:iv]
      exporttext += "  :ev => #{mon[:ev].inspect},\n" if mon[:ev]
      exporttext += "  :happiness => #{mon[:happiness]},\n" if mon[:happiness]
      if check != trainer[3].length
        exporttext += "},\n"
      else
        exporttext += "}"
      end
      check += 1
    end
    exporttext += "]},\n"
  end
  exporttext += "]"
  File.open(definition_file_path("trainertext.rb"), "w") { |f|
    f.write(exporttext)
  }
end

def connectionsConvert
  exporttext = "MAPCONNECTIONSHASH = {\n"
  mapdata = load_data("Data/connections.dat")
  mapdata.each { |connection|
    case connection[1]
      when "N"
        connection[1] = "North"
      when "E"
        connection[1] = "East"
      when "S"
        connection[1] = "South"
      when "W"
        connection[1] = "West"
    end
    case connection[4]
      when "N"
        connection[4] = "North"
      when "E"
        connection[4] = "East"
      when "S"
        connection[4] = "South"
      when "W"
        connection[4] = "West"
    end
    exporttext += "#{connection[0]} => { \##{$cache.mapinfos[connection[0]].name}\n"
    exporttext += "  :connections => [#{connection}"
    $cache.map_conns.each { |connection2|
      case connection2[1]
        when "N"
          connection2[1] = "North"
        when "E"
          connection2[1] = "East"
        when "S"
          connection2[1] = "South"
        when "W"
          connection2[1] = "West"
      end
      case connection2[4]
        when "N"
          connection2[4] = "North"
        when "E"
          connection2[4] = "East"
        when "S"
          connection2[4] = "South"
        when "W"
          connection2[4] = "West"
      end
      exporttext += ",  #{connection2}" if (connection2[0] == connection[0]) && (connection[3] != connection2[3])
    }
    exporttext += "],\n"
    exporttext += "},\n"
  }
  exporttext += "}\n"
  File.open(definition_file_path("mapconnections.rb"), "w") { |f|
    f.write(exporttext)
  }
end

def connectionsDumpFromData(mapdata)
  exporttext = "MAPCONNECTIONSHASH = {\n"
  connections = {}
  mapdata.each { |value|
    connections[value[0]] = {:connections => []} if connections[value[0]].nil?
    connections[value[0]][:connections].push(value)
  }
  connections.each_pair { |key, value|
    exporttext += "  #{key} => { \# #{$cache.mapinfos[key].name}\n"
    exporttext += "    :connections => [\n"
    for i in 0...value[:connections].length
      conn = value[:connections][i]
      exporttext += "      #{conn}, \# to #{$cache.mapinfos[conn[3]].name}\n"
    end
    exporttext += "    ],\n"
    exporttext += "  },\n"
  }
  exporttext += "}\n"
  File.open(definition_file_path("mapconnections.rb"), "w") { |f|
    f.write(exporttext)
  }
end

def connectionsDump
  connectionsDumpFromData(load_data("Data/connections.dat"))
end

def bttDump
  File.open(definition_file_path("PBSpecies.rb")) { |f|
    eval(f.read)
  }
  File.open(definition_file_path("PBTrainers.rb")) { |f|
    eval(f.read)
  }
  exporttext = "BTTARRAY = [\n"
  for trainer in load_data("Data/trainerlists.dat")[0][0]
    exporttext += "{\n"
    exporttext += "  :type => :#{getConstantName(PBTrainers, trainer[0])},\n"
    exporttext += "  :name => \"#{trainer[1]}\",\n"
    exporttext += "  :quote => \"#{trainer[2]}\",\n"
    exporttext += "  :win => \"#{trainer[3]}\",\n"
    exporttext += "  :loss => \"#{trainer[4]}\",\n"
    exporttext += "  :mons => [\n"
    check = 1
    for mon in trainer[5]
      exporttext += ":#{getConstantName(PBSpecies, mon)}"
      exporttext += "," if check != trainer[5].length
      check += 1
    end
    exporttext += "],\n"
    exporttext += "},\n"
  end
  exporttext += "]\n"
  File.open(definition_file_path("btttext.rb"), "w") { |f|
    f.write(exporttext)
  }
end

def dumpDefeatAceLines
  globaltext = ""
  for n in 1..999
    map_name = sprintf("Data/Map%03d.rxdata", n)
    next if !(File.open(map_name, "rb") { true } rescue false)
    next if $cache.mapinfos[n].name.start_with?("REMOVED")

    map = load_data(map_name)
    for i in map.events.keys.sort
      event = map.events[i]
      for j in 0...event.pages.length
        page = event.pages[j]
        list = page.list
        index = 0
        while index < list.length - 1
          params = list[index].parameters
          for l in 0..params.length
            text = params[l].to_s
            if (text.include? "pbTrainerBattle") || (text.include? "pbDoubleTrainerBattle")
              globaltext << text + "\n"
            end
          end
          index += 1
        end
      end
    end
  end
  file = File.open("output.txt", "w+")
  file.puts(globaltext)
  file.rewind
  file_data = file.read
  lossLines = {}
  file_data.each_line { |line|
    if line.strip.start_with?("pbTrainerBattle") && !line.include?("pbGet(602)")
      line = line.split(":")[1]
      numbattle = 0
      if !line.split(")")[1][/\d+/].nil?
        numbattle = line.split(")")[1][/\d+/]
      end
      line = line.split(")")[0]
      line = line.gsub! "_I(", (numbattle.to_s + ",")
      string = line.split(",")[1] + ",:" + line.split(",")[0] + "," + line.split(",")[2]
      lossLines[string] = line.partition(/(?:[^,]*,){3}/).last.delete("\n")
    elsif line.start_with?("pbDoubleTrainerBattle") && !line.include?("pbGet(602)")
      line1 = line.split("(:")[1].split("),")[0]
      line2 = line.split(",:")[1].split(")")[0]
      line1.gsub!("_I(", "")
      line2.gsub!("_I(", "")
      string = line1.split(",")[1] + ",:" + line1.split(",")[0] + "," + line1.split(",")[2]
      lossLines[string] = line1.partition(/(?:[^,]*,){3}/).last.delete("\n")
      string = line2.split(",")[1] + ",:" + line2.split(",")[0] + "," + line2.split(",")[2]
      lossLines[string] = line2.partition(/(?:[^,]*,){3}/).last.delete("\n")
    end
  }
  file.close

  aceLines = {}
  if File.exist?(definition_file_path("toconvert.txt"))
    file = File.open(definition_file_path("toconvert.txt"), "r")
    file_data = file.read
    key = ""
    text = ""
    num = 0
    file_data.each_line { |line|
      if line.strip.start_with?("when :")
        key = ""
        text = ""
        key = line.split("when ")[1].strip
      elsif line.strip.start_with?("when")
        key = key + "," + line.strip.split(" then ace_text")[0].split("when ")[1]
        text = line.strip.split("= _INTL(")[1][0...-1]
        aceLines[key] = text
      elsif line.strip.include?("if isConst?(trainertext")
        key = ""
        num = ""
        text = ""
        key = line.split("PBTrainers,")[1].strip.delete("\n")[0...-1]
      elsif line.strip.start_with?("if $game_variables[192]") || line.strip.start_with?("if $game_variables[226]")
        num = line.split("==")[1].strip.delete("\n")
      elsif line.strip.start_with?("pbDisplayPaused")
        key = key + "," + num
        text = line.strip.split("_INTL(")[1][0...-2]
        aceLines[key] = text
      end
    }
    file.close
  end

  if File.exist?(definition_file_path("trainertext.rb"))
    file = File.open(definition_file_path("trainertext.rb"), "r+")
    file_data = file.read
    file2 = File.open(definition_file_path("trainertext - Backup.rb"), "w")
    file2.write(file_data)
    file2.close
    file_data.each_line { |line|
      if line.include?(":teamid =>")
        id = line.split(":teamid => [")[1][0...-3]
        if lossLines.key?(id)
          string = "  :defeat => " + lossLines[id].to_s
          file_data[line] = line + string + ",\n"
        end
        idace = id.partition(/(?:[^,]*,){1}/).last
        if aceLines.key?(idace)
          string = "  :ace => " + aceLines[idace].to_s
          file_data[line] = line + string + ",\n"
        end
      end
    }
    file.truncate(0)
    file.rewind
    file.write(file_data)
    file.close
  else
    puts "uuuh why is there no trainertext.rb file found"
  end
  File.delete("output.txt") if File.exist?("output.txt")
end

def evLineFixer
  if File.exist?(definition_file_path("trainertext.rb"))
    file = File.open(definition_file_path("trainertext.rb"), "r")
    file_data = file.read
    file_data.each_line { |line|
      if line.strip.start_with?(":ev =>")
        key = line.split(":ev =>")[1].strip
        front = key.split("}")[0]
        back = line.split(/\d+[\]]/)[1].strip
        evarray = eval(front)
        speed = evarray.delete_at(3)
        evarray.push(speed)
        evline = ""
        evline += "  :ev => #{evarray}#{back}\n"
        file_data[line] = evline
      end
    }
    File.open(definition_file_path("trainertext.rb"), "w") { |f|
      f.write(file_data)
    }
    file.close
  else
    puts "uuuh why is there no trainertext.rb file found"
  end
end

# Mass Fixes event constants
def removeDefeatText
  for n in 0...999
    savemap = false
    map_name = sprintf("Data/Map%03d.rxdata", n)
    next if !(File.open(map_name, "rb") { true } rescue false)

    map = load_data(map_name)
    for i in map.events.keys.sort
      event = map.events[i]
      for j in 0...event.pages.length
        page = event.pages[j]
        list = page.list
        index = 0
        while index < list.length - 1
          case list[index].code # checks for event codes. here those are scripts(355), additional lines of scripts(655) and conditional branches(111)
            when 355, 655
              text = list[index].parameters[0]
              if text.include?("pbTrainerBattle")
                savemap = true
                map.events[i].pages[j].list[index].parameters[0].gsub!(/_I\((.*)\),/, "")
              elsif text.include?("pbDoubleTrainerBattle")
                front = text.split(/\),:/)[0].strip + ")"
                back = ":" + text.split(/\),:/)[1].strip
                newfront = front.gsub!(/_I\((.*)\)/, "")
                newback = back.gsub!(/_I\((.*)\),/, "")
                newtext = newfront + newback
                savemap = true
                map.events[i].pages[j].list[index].parameters[0] = newtext
              end
            when 111
              if list[index].parameters[0] == 12 # if conditional branch holds scripts in it
                text = list[index].parameters[1] # for conditional branches, the script text is stored in index 1 as opposed to index 0
                if text.include?("pbTrainerBattle")
                  savemap = true
                  map.events[i].pages[j].list[index].parameters[1].gsub!(/_I\((.*)\),/, "")
                elsif text.include?("pbDoubleTrainerBattle")
                  front = text.split(/\),:/)[0].strip + ")"
                  back = ":" + text.split(/\),:/)[1].strip
                  newfront = front.gsub!(/_I\((.*)\)/, "")
                  newback = back.gsub!(/_I\((.*)\),/, "")
                  newtext = newfront + newback
                  savemap = true
                  map.events[i].pages[j].list[index].parameters[1] = newtext
                end
              end
          end
          index += 1
        end
      end
    end
    if savemap
      save_data(map, sprintf("Data/Map%03d.rxdata", n))
    end
  end
end

# Mass Fixes event constants
def pbEventConstantFixer
  for n in 0...999
    savemap = false
    map_name = sprintf("Data/Map%03d.rxdata", n)
    next if !(File.open(map_name, "rb") { true } rescue false)

    map = load_data(map_name)
    for i in map.events.keys.sort
      event = map.events[i]
      for j in 0...event.pages.length
        page = event.pages[j]
        list = page.list
        index = 0
        trainerlinestring = "_I(".*")"
        constantlinks = ["PBTrainers::", "PBSpecies::", "PBItems::", "PBMoves::"] # list of constants that need to be changed
        while index < list.length - 1
          case list[index].code # checks for event codes. here those are scripts(355), additional lines of scripts(655) and conditional branches(111)
            when 355, 655
              text = list[index].parameters[0]
              constantlinks.each do |constant|
                if text.include?(constant)
                  savemap = true
                  map.events[i].pages[j].list[index].parameters[0].gsub! constant, ':'
                end
              end
            when 111
              if list[index].parameters[0] == 12 # if conditional branch holds scripts in it
                text = list[index].parameters[1] # for conditional branches, the script text is stored in index 1 as opposed to index 0
                constantlinks.each do |constant|
                  if text.include?(constant)
                    savemap = true
                    map.events[i].pages[j].list[index].parameters[1].gsub! constant, ':'
                  end
                end
              end
          end
          index += 1
        end
      end
    end
    if savemap
      save_data(map, sprintf("Data/Map%03d.rxdata", n))
    end
  end
end

def fieldrewrite # rewrite the rewrite at some point
  output = "FIELDEFFECTS = {\n"
  FIELDEFFECTS.each { |key, data|
    name = data[:FIELDGRAPHICS]
    output += ":#{name.strip.upcase.gsub(/\d/, '')} => {\n"

    output += "  :name => \"#{data.dig(:FIELDNAME)}\",\n"
    messagetext = ""
    if data.dig(:INTROMESSAGE).is_a?(Array)
      messagetext = "[\n"
      data.dig(:INTROMESSAGE).each { |msg|
        messagetext += "    \"#{msg}\",\n"
      }
      messagetext += "  ]"
    else
      messagetext = "[\n    \"#{data.dig(:INTROMESSAGE)}\"\n  ]"
    end
    output += "  :fieldMessage => #{messagetext},\n"
    output += "  :graphic => \"#{data.dig(:FIELDGRAPHICS)}\",\n"
    output += "  :secretPower => \"#{data.dig(:SECRETPOWERANIM)}\",\n"
    output += "  :naturePower => \"#{data.dig(:NATUREMOVES)}\",\n"
    output += "  :mimicry => \"#{data.dig(:MIMICRY)}\",\n"

    output += "  :damageMods => "
    if data.dig(:MOVEDAMAGEBOOST)
      output += "{\n"
      data.dig(:MOVEDAMAGEBOOST).each { |mult, moves|
        output += "    #{mult} => #{moves},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :accuracyMods => "
    if data.dig(:MOVEACCURACYBOOST)
      output += "{\n"
      data.dig(:MOVEACCURACYBOOST).each { |acc, moves|
        output += "    #{acc} => #{moves},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :moveMessages => "
    if data.dig(:MOVEMESSAGES)
      output += "{\n"
      data.dig(:MOVEMESSAGES).each { |msg, moves|
        output += "    \"#{msg}\" => #{moves},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :typeMods => "
    if data.dig(:MOVETYPEMOD)
      output += "{\n"
      data.dig(:MOVETYPEMOD).each { |type, moves|
        output += "    :#{type} => #{moves},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :typeAddOns => "
    if data.dig(:TYPETYPEMOD)
      output += "{\n"
      data.dig(:TYPETYPEMOD).each { |type, type2|
        output += "    :#{type} => #{type2},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :typeBoosts => "
    if data.dig(:TYPEDAMAGEBOOST)
      output += "{\n"
      data.dig(:TYPEDAMAGEBOOST).each { |boost, types|
        output += "    #{boost} => #{types},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :typeMessages => "
    if data.dig(:TYPEMESSAGES)
      output += "{\n"
      data.dig(:TYPEMESSAGES).each { |msg, type|
        output += "    \"#{msg}\" => #{type},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :typeCondition => "
    if data.dig(:TYPECONDITION)
      output += "{\n"
      data.dig(:TYPECONDITION).each { |type, condition|
        output += "    :#{type} => \"#{condition}\",\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :changeCondition => "
    if data.dig(:CHANGECONDITION)
      output += "{\n"
      data.dig(:CHANGECONDITION).each { |fieldid, condition|
        fieldsym = FIELDEFFECTS[fieldid][:FIELDGRAPHICS].strip.upcase
        output += "    :#{fieldsym} => \"#{condition}\",\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :fieldChange => "
    if data.dig(:FIELDCHANGE)
      output += "{\n"
      data.dig(:FIELDCHANGE).each { |fieldid, condition|
        fieldsym = FIELDEFFECTS[fieldid][:FIELDGRAPHICS].strip.upcase
        output += "    :#{fieldsym} => #{condition},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :dontChangeBackup => #{data.dig(:DONTCHANGEBACKUP) ? data.dig(:DONTCHANGEBACKUP) : "[]"},\n"

    output += "  :changeMessage => "
    if data.dig(:CHANGEMESSAGE)
      output += "{\n"
      data.dig(:CHANGEMESSAGE).each { |msg, moves|
        output += "     \"#{msg}\" => #{moves},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :statusBuffs => #{data.dig(:STATUSMOVEBOOST) ? data.dig(:STATUSMOVEBOOST) : "[]"},\n"
    output += "  :changeEffects => {},\n"
    output += "  :seed => {\n"

    seedtext = ""
    if data.dig(:SEED).is_a?(Hash) || data.dig(:SEED).nil?
      seedtext = "nil"
    else
      seedtext = ":#{data.dig(:SEED)}"
    end

    output += "    :seedtype => #{seedtext},\n"

    effecttext = ""
    if data.dig(:SEEDEFFECT)
      if data.dig(:SEEDEFFECT).is_a?(Symbol)
        effecttext = ":"
      end
      effecttext += data.dig(:SEEDEFFECT).to_s
    else
      effecttext = "nil"
    end
    output += "    :effect => #{effecttext},\n"

    durtext = ""
    if data.dig(:SEEDEFFECTVAL)
      if data.dig(:SEEDEFFECTVAL).is_a?(Symbol)
        durtext = ":"
      end
      durtext += data.dig(:SEEDEFFECTVAL).to_s
    else
      durtext = "nil"
    end
    output += "    :duration => #{durtext},\n"

    output += "    :message => #{data.dig(:SEEDEFFECTSTR) ? "\"" + data.dig(:SEEDEFFECTSTR).to_s + "\"" : "nil"},\n"

    anitext = ""
    if data.dig(:SEEDANIM)
      if data.dig(:SEEDANIM).is_a?(Symbol)
        anitext = ":"
      end
      anitext += data.dig(:SEEDANIM).to_s
    else
      anitext = "nil"
    end
    output += "    :animation => #{anitext},\n"

    output += "    :stats => "

    if data.dig(:SEEDSTATS)
      output += "{\n"
      hash = {
        :HP => 0,
        :ATTACK => 1,
        :DEFENSE => 2,
        :SPATK => 3,
        :SPDEF => 4,
        :SPEED => 5,
        :ACCURACY => 6,
        :EVASION => 7
      }
      data.dig(:SEEDSTATS).each { |stat, val|
        output += "      PBStats::#{hash.keys[stat]} => #{val},\n"
      }
      output += "    },\n"
    else
      output += "{}\n"
    end

    output += "  },\n},\n"
  }
  output += "}"

  File.open(definition_file_path("fieldtext.rb"), "w") { |f|
    f.write(output)
  }
  compileFields
end

def dumpNatures(game: nil)
  dumpstupidstats = [
    ["PBStats::ATTACK", ":spicy"],
    ["PBStats::DEFENSE", ":sour"],
    ["PBStats::SPEED", ":sweet"],
    ["PBStats::SPATK", ":dry"],
    ["PBStats::SPDEF", ":bitter"]
  ]
  output = "NATUREHASH = {\n"
  $cache.natures.keys.each_with_index do |nature, i|
    incStat = (i / 5).floor
    decStat = (i % 5).floor
    output += "  :#{nature} => {\n"
    output += "    :name => \"#{getNatureName(nature)}\",\n"
    unless incStat == decStat
      output += "    :incStat => #{dumpstupidstats[incStat][0]},\n"
      output += "    :decStat => #{dumpstupidstats[decStat][0]},\n"
      output += "    :like => #{dumpstupidstats[incStat][1]},\n"
      output += "    :dislike => #{dumpstupidstats[decStat][1]},\n"
    end
    output += "  },\n"
  end
  output += "}\n"
  File.open(definition_file_path("naturetext.rb", game: game), "w") { |f|
    f.write(output)
  }
end

def convertBTMons
  # Only works if all sets of the same mon are contiguous in the PBS. -Orsan
  File.open("Scripts/ConversionClasses.rb") { |f| eval(f.read) }
  output = "BTMONS = {\n"
  lastmon = nil
  pbCompilerEachCommentedLine("PBS/btpokemon.txt") { |line, lineno|
    currentmon = PBPokemon.fromInspected(line)
    if lineno <= 1
      output += currentmon.speciesinspect + " => [\n"
    elsif currentmon.species != lastmon.species
      output += "],\n" + currentmon.speciesinspect + " => [\n"
    end
    output += "  " + currentmon.to_s_no_species
    lastmon = currentmon
  }
  output += "]\n}"
  File.open(definition_file_path("btpokemon.rb"), "w") { |f|
    f.write(output)
  }
end

def dumpBTMons
  output = "BTMONS = [\n"
  pbCompilerEachCommentedLine("PBS/btpokemon.txt") { |line, lineno|
    output += BTPokemon.fromInspected(line).to_s
  }
  output += "]"
  File.open(definition_file_path("btpokemon.rb"), "w") { |f|
    f.write(output)
  }
end

def convertBTTrainers
  output = "BTTRAINERS = [\n"
  btTrainersRequiredTypes = {
    "Type" => [0, "s"],
    "Name" => [1, "s"],
    "BeginSpeech" => [2, "s"],
    "EndSpeechWin" => [3, "s"],
    "EndSpeechLose" => [4, "s"],
    "PokemonNos" => [5, "*u"]
  }
  requiredtypes = btTrainersRequiredTypes
  if safeExists?("PBS/bttrainers.txt")
    File.open("PBS/bttrainers.txt", "rb") { |f|
      FileLineData.file = "PBS/bttrainers.txt"
      pbEachFileSectionEx(f) { |section, name|
        rsection = []
        for key in section.keys
          FileLineData.setSection(name, key, section[key])
          schema = requiredtypes[key]
          next if !schema

          record = pbGetCsvRecord(section[key], 0, schema)
          rsection[schema[0]] = record
        end
        output += "{\n"
        output += "  :tclass => :#{rsection[0]},\n"
        output += "  :name => #{rsection[1].inspect},\n"
        output += "  :introSpeech => #{rsection[2].inspect},\n"
        output += "  :winSpeech => #{rsection[3].inspect},\n"
        output += "  :loseSpeech => #{rsection[4].inspect},\n"
        mons = rsection[5].inspect[1..-2].split(",")
        output += "  :monIndexes => ["
        for mon in mons
          if mon.to_i != 0
            output += ":"
            output += $cache.pkmn.keys[mon.to_i - 1].to_s
            if mon != mons[mons.size - 1]
              output += ","
            end
          end
        end
        output += "],\n"
        output += "},\n"
      }
    }
  end
  output += "]"
  File.open(definition_file_path("bttrainers.rb"), "w") { |f|
    f.write(output)
  }
end

def dumpPokedexes(game: nil)
  output = "POKEDEXHASH = {\n"
  $cache.pokedexes.each { |sym, dex|
    output += "  #{sym.inspect} => {\n"
    output += "    :name => #{dex.name.inspect},\n"
    output += "    :default => true,\n" if dex.default
    dex.flags.each { |key, value|
      output += "    #{key.inspect} => #{value.inspect},\n"
    }
    output += "  },\n"
  }
  output += "}\n"
  File.open(definition_file_path("dextext.rb", game: game), "w") { |f|
    f.write(output)
  }
end

def formatNumeric(num)
  return num.to_s + "r" if num.is_a?(Rational)
  return num.to_s
end

def better_inspect(obj)
  return obj.inspect unless obj.is_a?(Hash)
  if obj.keys.all? { |k| k.is_a?(Symbol) }
    return "{ " + obj.map{ |k, v| "#{k}: #{v.inspect}" }.join(", ") + " }"
  else
    return "{ " + obj.map{ |k, v| "#{k.inspect} => #{v.inspect}" }.join(", ") + " }"
  end
end

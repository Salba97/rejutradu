require 'discord'

# Graphics module override to pass updates to Discord
module Graphics
  class << self
    alias __discord_update update unless method_defined?(:__discord_update)
  end

  def self.update
    Discord.update
    __discord_update
  end
end

module DiscordRPC
  # Hash containing relevant Discord attributes for rich presence
  # :large_image should be a game-specific, recognizable image (logo, art, etc)
  # Image should be uploaded to the application art assets here https://discord.com/developers/applications
  # Use the asset key you define when uploading the image.
  @@discordRPCInfo = {
    :details => "",
    :state => "",
    :start_timestamp => Time.now.to_i,
    :end_timestamp => nil,
    :large_image => "game-icon",
    :large_image_text => GAME_TITLE,
    :small_image => "",
    :small_image_text => ""
  }

  # Method to connect to Discord & begin displaying info.
  def self.start
    return if Discord.connected? || DiscordAppID.nil?

    Discord.connect(DiscordAppID)

    @@discordRPCInfo[:start_timestamp] = Time.now.to_i
    @@discordRPCInfo[:end_timestamp] = nil
    exploration if inGame?

    update
  end

  # Method to disconnect from Discord & remove info.
  def self.end
    if Discord.connected?
      Discord.disconnect
    end
  end

  # Method to immediately spoiler-ize Discord info.
  def self.spoilerDiscordRPC
    @@discordRPCInfo[:details] = "???"
    @@discordRPCInfo[:state] = "???"
    @@discordRPCInfo[:small_image] = ""
    @@discordRPCInfo[:small_image_text] = "???"

    Discord.update_activity(@@discordRPCInfo)
  end

  def self.onTrainerPartyLoad(sender, event)
    return if event[0].nil?
    trainer = event[0][0]
    if $game_switches[:Discord_Spoilers]
      if $PokemonGlobal.partner && $PokemonGlobal.partner[0] != trainer.trainertype
        @@discordRPCInfo[:details] = "Partner: ???"
      else
        @@discordRPCInfo[:details] = "Battling: ???"
      end
      @@discordRPCInfo[:state] = "???"
    else
      if $PokemonGlobal.partner && $PokemonGlobal.partner[0] != trainer.trainertype
        @@discordRPCInfo[:details] = "Partner: #{trainer.fullname}"
      else
        @@discordRPCInfo[:details] = "Battling: #{trainer.fullname}"
      end
      @@discordRPCInfo[:state] = "Exploring #{$game_map.name}"
    end
  end

  def self.onWildPokemonCreate(sender, event)
    if $game_switches[:Discord_Spoilers]
      @@discordRPCInfo[:details] = "Battling: wild ???"
      @@discordRPCInfo[:state] = "???"
    else
      pokemon = event[0]
      @@discordRPCInfo[:details] = "Battling: wild #{pokemon.name}"
      @@discordRPCInfo[:state] = "Exploring #{$game_map.name}"
    end
  end

  def self.onDoubleBattleLoad(sender, event)
    if $game_switches[:Discord_Spoilers]
      @@discordRPCInfo[:details] = "Battling: ??? & ???"
      @@discordRPCInfo[:state] = "???"
    else
      if sender == "trainer"
        opp1 = event[0][0]
        opp2 = event[1][0]
        @@discordRPCInfo[:details] = "Battling: #{opp1.fullname} & #{opp2.fullname}"
      elsif sender == "pokemon"
        opp1 = event[0]
        opp2 = event[1]
        @@discordRPCInfo[:details] = "Battling: wild #{opp1.name} & #{opp2.name}"
      end
      @@discordRPCInfo[:state] = "Exploring #{$game_map.name}"
    end
  end

  def self.onBossCreate(sender, event)
    if $game_switches[:Discord_Spoilers]
      @@discordRPCInfo[:details] = "Battling boss: ???"
      @@discordRPCInfo[:state] = "???"
    else
      pkmn = event[0]
      name = $cache.bosses[pkmn.bossID].name
      @@discordRPCInfo[:details] = "Battling boss: #{name}"
      @@discordRPCInfo[:state] = "Exploring #{$game_map.name}"
    end
  end

  def self.onBattleFacilityChallenge(sender, event)
    trainer = event[0]
    if $game_switches[:Discord_Spoilers]
      if $PokemonGlobal.partner && $PokemonGlobal.partner[0] != trainer.trainertype
        @@discordRPCInfo[:details] = "Partner: ???"
      else
        @@discordRPCInfo[:details] = "Battling: ???"
      end
      @@discordRPCInfo[:state] = "???"
    else
      if $PokemonGlobal.partner && $PokemonGlobal.partner[0] != trainer.trainertype
        @@discordRPCInfo[:details] = "Partner: #{trainer.fullname}"
      else
        @@discordRPCInfo[:details] = "Battling: #{trainer.fullname}"
      end
      @@discordRPCInfo[:state] = "Exploring #{$game_map.name}"
    end
  end

  def self.onEndBattle(sender, event)
    exploration
  end

  def self.onMapChange(sender, event)
    if !Discord.connected? && !DiscordAppID.nil?
      Discord.connect(DiscordAppID)
    end

    exploration
  end

  def self.exploration
    if $game_switches[:Discord_Spoilers]
      if $PokemonGlobal.partner
        @@discordRPCInfo[:details] = "Partner: ???"
      else
        @@discordRPCInfo[:details] = ""
      end
      @@discordRPCInfo[:state] = "???"
    else
      if $PokemonGlobal.partner && $cache.trainertypes[$PokemonGlobal.partner[0]]
        @@discordRPCInfo[:details] = "Partner: #{trainerFullName($PokemonGlobal.partner[0], $PokemonGlobal.partner[1])}"
      else
        @@discordRPCInfo[:details] = ""
      end
      @@discordRPCInfo[:state] = "Exploring #{$game_map.name}"
    end
  end

  # Handles player displaying player info
  # :small_image = image key from application art assets in Discord Dev Portal
  # (recommend using player map icons upscaled by 2000% to 640x640, can add more elsif statements as needed)
  # NOTE: if no small_image is defined, no small_image_text can be displayed
  def self.playerIdentity
    if $game_switches[:Discord_Spoilers]
      @@discordRPCInfo[:small_image] = ""
      @@discordRPCInfo[:small_image_text] = "???"
    elsif $Trainer
      # Discord simply won't show any player graphic if the passed file name is not present among the uploaded files. This is the desired result for us when playing as a different character
      if Reborn
        player = $cache.metadata[:Players].find { |value| value[:tclass] == $Trainer.trainertype }
        fileName = player ? player[:name] : ""
      else
        typeid = $cache.trainertypes[$Trainer.trainertype]&.checkFlag?(:ID)
        outfit = $Trainer.outfit > 0 ? sprintf("_%d", $Trainer.outfit) : ""
        fileName = typeid ? sprintf("mapPlayer%03d", typeid) + outfit : ""
      end
      # Discord expects lower case input to match the graphic used.
      @@discordRPCInfo[:small_image] = fileName.downcase
      @@discordRPCInfo[:small_image_text] = $Trainer.name
    else
      @@discordRPCInfo[:small_image] = ""
      @@discordRPCInfo[:small_image_text] = ""
    end
  end

  def self.inGame?
    return $game_switches && $game_variables && $game_map && $Trainer
  end

  def self.update
    playerIdentity if inGame?
    Discord.update_activity(@@discordRPCInfo)
  end
end

# Processes to update Discord status.
# Shows info on single battle opponent or partner.
Events.onTrainerPartyLoad += proc { |sender, e|
  next unless $Settings.discordRPC == 1

  DiscordRPC.onTrainerPartyLoad(sender, e)
  DiscordRPC.update
}

# Shows info when battling wild Pokemon.
Events.onWildPokemonCreate += proc { |sender, e|
  next unless $Settings.discordRPC == 1

  DiscordRPC.onWildPokemonCreate(sender, e)
  DiscordRPC.update
}

# Shows info on double battle opponent.
Events.onDoubleBattleLoad += proc { |sender, e|
  next unless $Settings.discordRPC == 1

  DiscordRPC.onDoubleBattleLoad(sender, e)
  DiscordRPC.update
}

# Shows info when battling a boss Pokemon.
Events.onBossCreate += proc { |sender, e|
  next unless $Settings.discordRPC == 1

  DiscordRPC.onBossCreate(sender, e)
  DiscordRPC.update
}

# Shows info when battling in a facility.
Events.onBattleFacilityChallenge += proc { |sender, e|
  next unless $Settings.discordRPC == 1

  DiscordRPC.onBattleFacilityChallenge(sender, e)
  DiscordRPC.update
}

# Refreshes status after battle is over.
Events.onEndBattle += proc { |sender, e|
  next unless $Settings.discordRPC == 1

  DiscordRPC.onEndBattle(sender, e)
  DiscordRPC.update
}

# Shows info when changing maps, also establishes initial connection to Discord if settings allow it & it isn't already connected.
Events.onMapChange += proc { |sender, e|
  next unless $Settings.discordRPC == 1

  DiscordRPC.onMapChange(sender, e)
  DiscordRPC.update
}

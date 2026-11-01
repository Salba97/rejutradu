# MenuHandlers Registry for modular menu generation
module MenuHandlers
  @@registry = {}

  # Registers a new option to a specific menu.
  #
  # MODDING GUIDELINES:
  # - ALWAYS use a unique option_id (e.g., :your_mod_name_option) to avoid
  #   overwriting other mods.
  # - To add an option to the END of the menu, simply omit the order key.
  # - Only use order if you explicitly need your option inserted between
  #   vanilla options (e.g., between Pokemon (20) and Bag (30)).
  #
  # OPTION KEYS:
  # - name      : (Proc) The label displayed in the visual menu. Needs to be a
  #               proc even for static labels so as to work with translations
  #               (makes the _INTL call happen at runtime instead of on load).
  # - helptext  : (Proc) Optional. The text displayed in the help window.
  # - effect    : (Proc) The code executed when the player selects this option.
  #               Use `next :break` if the menu should completely close after.
  # - order     : (Integer) Determines list position.
  # - color     : (Symbol) Optional. The color of the text in the menu.
  # - condition : (Proc) Optional. Determines whether the option should be shown.
  #               Should evaluate to true/false.
  def self.add(menu_id, option_id, name:, helptext: nil, order:, color: nil, condition: nil, effect:)
    @@registry[menu_id] ||= {}
    @@registry[menu_id][option_id] = {
      name:      name,
      helptext:  helptext,
      order:     order,
      color:     color,
      condition: condition,
      effect:    effect,
    }
  end

  # Helper to build the final commands and actions for any menu.
  # Eliminates code repetition in PauseMenu, Party, and Storage.
  def self.build(menu_id, *args)
    return [], [], [] unless @@registry[menu_id]

    commands = []
    helptexts = []
    actions = []

    # Sort by the order key (nil for options like "Cancel" that should always be at the end)
    sorted_options = @@registry[menu_id].sort_by { |_, v| v[:order] || 99999 }

    colortags = isCurrentWindowskinDark ? ColorTags : LightColorTags
    sorted_options.each do |_, option|
      # Evaluate condition if it exists
      if option[:condition].nil? || option[:condition].call(*args)
        colortag = option[:color] ? colortags[option[:color]] : ""
        label = option[:name].call(*args)
        help = option[:helptext] ? option[:helptext].call(*args) : ""
        commands.push(colortag + label)
        helptexts.push(help)
        actions.push(option[:effect])
      end
    end

    return commands, helptexts, actions
  end
end

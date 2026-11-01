TYPEHASH = {
  :NORMAL => {
    :name => "Normal",
    :weaknesses => [:FIGHTING],
    :immunities => [:GHOST],
  },

  :FIGHTING => {
    :name => "Fighting",
    :weaknesses => [:FLYING, :PSYCHIC, :FAIRY],
    :resistances => [:ROCK, :BUG, :DARK],
  },

  :FLYING => {
    :name => "Flying",
    :weaknesses => [:ROCK, :ELECTRIC, :ICE],
    :resistances => [:FIGHTING, :BUG, :GRASS],
    :immunities => [:GROUND],
  },

  :POISON => {
    :name => "Poison",
    :weaknesses => [:GROUND, :PSYCHIC],
    :resistances => [:FIGHTING, :POISON, :BUG, :GRASS, :FAIRY],
  },

  :GROUND => {
    :name => "Ground",
    :weaknesses => [:WATER, :GRASS, :ICE],
    :resistances => [:POISON, :ROCK],
    :immunities => [:ELECTRIC],
  },

  :ROCK => {
    :name => "Rock",
    :weaknesses => [:FIGHTING, :GROUND, :STEEL, :WATER, :GRASS],
    :resistances => [:NORMAL, :FLYING, :POISON, :FIRE],
  },

  :BUG => {
    :name => "Bug",
    :weaknesses => [:FLYING, :ROCK, :FIRE],
    :resistances => [:FIGHTING, :GROUND, :GRASS],
  },

  :GHOST => {
    :name => "Ghost",
    :weaknesses => [:GHOST, :DARK],
    :resistances => [:POISON, :BUG],
    :immunities => [:NORMAL, :FIGHTING],
  },

  :STEEL => {
    :name => "Steel",
    :weaknesses => [:FIGHTING, :GROUND, :FIRE],
    :resistances => [:NORMAL, :FLYING, :ROCK, :BUG, :FAIRY, :STEEL, :GRASS, :PSYCHIC, :ICE, :DRAGON],
    :immunities => [:POISON],
  },

  :QMARKS => {
    :name => "???",
  },

  :FIRE => {
    :name => "Fire",
    :weaknesses => [:GROUND, :ROCK, :WATER],
    :resistances => [:BUG, :STEEL, :FIRE, :GRASS, :ICE, :FAIRY],
    :specialtype => true,
  },

  :WATER => {
    :name => "Water",
    :weaknesses => [:GRASS, :ELECTRIC],
    :resistances => [:STEEL, :FIRE, :WATER, :ICE],
    :specialtype => true,
  },

  :GRASS => {
    :name => "Grass",
    :weaknesses => [:FLYING, :POISON, :BUG, :FIRE, :ICE],
    :resistances => [:GROUND, :WATER, :GRASS, :ELECTRIC],
    :specialtype => true,
  },

  :ELECTRIC => {
    :name => "Electric",
    :weaknesses => [:GROUND],
    :resistances => [:FLYING, :STEEL, :ELECTRIC],
    :specialtype => true,
  },

  :PSYCHIC => {
    :name => "Psychic",
    :weaknesses => [:BUG, :GHOST, :DARK],
    :resistances => [:FIGHTING, :PSYCHIC],
    :specialtype => true,
  },

  :ICE => {
    :name => "Ice",
    :weaknesses => [:FIGHTING, :ROCK, :STEEL, :FIRE],
    :resistances => [:ICE],
    :specialtype => true,
  },

  :DRAGON => {
    :name => "Dragon",
    :weaknesses => [:ICE, :DRAGON, :FAIRY],
    :resistances => [:FIRE, :WATER, :GRASS, :ELECTRIC],
    :specialtype => true,
  },

  :DARK => {
    :name => "Dark",
    :weaknesses => [:FIGHTING, :BUG, :FAIRY],
    :resistances => [:GHOST, :DARK],
    :immunities => [:PSYCHIC],
    :specialtype => true,
  },


  :FAIRY => {
    :name => "Fairy",
    :weaknesses => [:POISON, :STEEL],
    :resistances => [:FIGHTING, :DARK, :BUG, :SHADOW],
    :immunities => [:DRAGON],
    :specialtype => true,
  },

  :SHADOW => {
    :name => "Shadow",
    :weaknesses => [:FAIRY],
    :resistances => [:SHADOW],
    :specialtype => true,
  },

  :STELLAR => {
    :name => "Stellar",
    :specialtype => true,
  }
}

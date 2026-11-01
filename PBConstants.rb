class PBStats
  HP       = 0
  ATTACK   = 1
  DEFENSE  = 2
  SPATK    = 3
  SPDEF    = 4
  SPEED    = 5
  ACCURACY = 6
  EVASION  = 7

  Omni = [ATTACK, DEFENSE, SPATK, SPDEF, SPEED]
  All = [ATTACK, DEFENSE, SPATK, SPDEF, SPEED, ACCURACY, EVASION]
  Offensive = [ATTACK, SPATK]
  Defensive = [DEFENSE, SPDEF]
  Physical = [ATTACK, DEFENSE]
  Special = [SPATK, SPDEF]

  StageMul = [
    2.0 / 8,
    2.0 / 7,
    2.0 / 6,
    2.0 / 5,
    2.0 / 4,
    2.0 / 3,
    2.0 / 2,
    3.0 / 2,
    4.0 / 2,
    5.0 / 2,
    6.0 / 2,
    7.0 / 2,
    8.0 / 2,
  ]
end

class PBMults
  TenPercentItem = 4505.0 / 4096 # approx. 1.1x
  RootOrb        = 5324.0 / 4096 # approx. 1.3x
  ScreenDoubles  = 2732.0 / 4096 # approx. 0.67x
  ParadoxLeads   = 5461.0 / 4096 # approx. 1.33x

  Metronome      = [
    1.0,
    1.2,
    1.4,
    6553.0 / 4096, # approx. 1.6x
    7372.0 / 4096, # approx. 1.8x
    2.0,
  ]

  STAB = [
    1.0,
    1.5,
    2.0,
    2.25,
    2.25, # for safety, index 4 should never be called, but if all conditions were true it would be (this should never be the case however)
  ]
end

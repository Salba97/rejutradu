#==============================================================================

# * Scene_Credits
#------------------------------------------------------------------------------
# Scrolls the credits you make below. Original Author unknown.
#
## Edited by MiDas Mike so it doesn't play over the Title, but runs by calling
# the following:
#    $scene = Scene_Credits.new
#
## New Edit 3/6/2007 11:14 PM by AvatarMonkeyKirby.
# Ok, what I've done is changed the part of the script that was supposed to make
# the credits automatically end so that way they actually end! Yes, they will
# actually end when the credits are finished! So, that will make the people you
# should give credit to now is: Unknown, MiDas Mike, and AvatarMonkeyKirby.
#                                             -sincerly yours,
#                                               Your Beloved
# Oh yea, and I also added a line of code that fades out the BGM so it fades
# sooner and smoother.
#
## New Edit 24/1/2012 by Maruno.
# Added the ability to split a line into two halves with <s>, with each half
# aligned towards the centre.  Please also credit me if used.
#
## New Edit 22/2/2012 by Maruno.
# Credits now scroll properly when played with a zoom factor of 0.5.  Music can
# now be defined.  Credits can't be skipped during their first play.
#==============================================================================

class Scene_Credits
  CreditsBackgroundList = ["creditsbg"]
  #CreditsMusic          = "Credits - Up in Flames"
  CreditsScrollSpeed    = 1             # At least 1; keep below 5 for legibility.
  CreditsFrequency      = 8             # Number of seconds per credits slide.
  CREDITS_OUTLINE       = [Color.new(32, 32, 32, 255), Color.new(16, 40, 36, 255), Color.new(29, 26, 55, 255), Color.new(66, 25, 16, 255), Color.new(41, 10, 35, 255)]
  CREDITS_SHADOW        = Color.new(0, 0, 0, 100)
  CREDITS_FILL          = [Color.new(255, 255, 255, 255), Color.new(123, 142, 132, 255), Color.new(130, 93, 177, 255), Color.new(248, 95, 84, 255), Color.new(102, 26, 48, 255)]

  # This next piece of code is the credits.

  # <A> for Anna
  # <H> for Shade
  # <L> for Lin
  # <T> for Terra
  # <left>
  # <right>
  # <s> for space

  # Start Editing
  CREDIT = <<~_END_
    *  |  Main Cast  |  *
    The Interceptor   - ???
    The Glitched One  - M#l#a
    The Vengeful One   - Erin
    The Reincarnation - Aelita
    The Changed One   - Ren
    The Abandoned     - Venam
    The Ex-Servant    - Kanon
    The Imaginary     - Alice
    The Strong Hero   - Allen
    The Lonely Moon   - Crescent
    The Pacifist      - Alexandra
    The Wrathful      - Damien

     -  - Garufan Employees -  -
     Donec scelerisque, libero vitae fringilla vehicula,
     condimentum eros. Integer tempus eu nulla a posuere.
     Sed mattis neque justo, ut dignissim nunc varius.
     Donec tempor rhoncus mauris, a lobortis,
     Donec scelerisque, libero vitae fringilla vehicula,
     condimentum eros. Integer tempus eu nulla a posuere.
     Sed mattis neque justo, ut dignissim nunc varius.
     Donec tempor rhoncus mauris, a lobortis,

    Donec scelerisque, libero vitae fringilla vehicula,
     condimentum eros. Integer tempus eu nulla a posuere.
     Sed mattis neque justo, ut dignissim nunc varius.
     Donec tempor rhoncus mauris, a lobortis,
     Donec scelerisque, libero vitae fringilla vehicula,
     condimentum eros. Integer tempus eu nulla a posuere.
     Sed mattis neque justo, ut dignissim nunc varius.
     Donec tempor rhoncus mauris, a lobortis,

     Sed mattis neque justo, ut dignissim nunc varius.
     Sed mattis neque justo, ut dignissim nunc varius.
     Sed mattis neque justo, ut dignissim nunc varius.
     Sed mattis neque justo, ut dignissim nunc varius.
     Sed mattis neque justo, ut dignissim nunc varius.
     Sed mattis neque justo, ut dignissim nunc varius.
     Sed mattis neque justo, ut dignissim nunc varius.

    thats all until beta im lazy


  _END_

    CREDIT1 = <<~_END_
      *  |  Supporting Cast  |  *
      The Bug Man        - Crawli
      The Other Servant  - Cera
      The Ice Heiress    - Angie
      The Biologist      - Valarie
      The Engineer       - Saki
      The Stone Faced    - Adam
      The Experiment     - Delpha
      The Fever Pitch'd  - Amber
      The Sailor         - Augustus
      The Princess       - Odessa
      The Mother to all  - Tesla

      -  - Garufan Employees -  -
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,

      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,

      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.

      thats all until beta im lazy


  _END_

    CREDIT2 = <<~_END_
      *  |  Supporting Cast  |  *
      The Rambunctious   - Mosely
      The Broadway Diva  - Narcissa
      The Stolen         - Gregory... I mean, Geara!
      The Stupid         - Sariah <L>I don't approve...
      The Slayer         - Cairo
      The Other Engineer - Erick
      The Cow Girl       - Beth
      The Cow Boy        - Ben

      -  - Garufan Employees -  -
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,

      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,

      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.

      thats all until beta im lazy


  _END_

    CREDIT3 = <<~_END_
      *  |  Supporting Cast  |  *
      The Detective      - Lavender
      The Unknown        - Huey
      The History Buff   - Reina
      The Community      - Rhodea
      The Botanist       - Florin
      The Extremist      - Flora
      The Cartographer   - Talon
      The Healer         - Souta

      -  - Garufan Employees -  -
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,

      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,

      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.

      thats all until beta im lazy


  _END_

      CREDIT4 = <<~_END_
      *  |  Supporting Cast  |  *
      The Facade         - Thomas Jr.
      The Depressed      - Hazuki
      The Business man   - Thomas Sr.
      The Gang Leader    - Karrina
      The Sad Dad        - Irvin
      The Envoy          - Vivian
      The Hero           - Goomink
      The Princess, too  - Goomelda

      -  - Garufan Employees -  -
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,

      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,
      Donec scelerisque, libero vitae fringilla vehicula,
      condimentum eros. Integer tempus eu nulla a posuere.
      Sed mattis neque justo, ut dignissim nunc varius.
      Donec tempor rhoncus mauris, a lobortis,

      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.
      Sed mattis neque justo, ut dignissim nunc varius.

      thats all until beta im lazy


  _END_

  # Cuttoff
      CREDIT6 = <<~_END_
      *  |  Supporting Cast  |  *
      The Driver         - Truck Guy
      The Musician       - Piano Lady
      The Gambler        - Dylan
      The Queen          - Particia
      The Working Woman  - Patty
      The Oracle         - Peony
      The Sad Dad        - Irvin
      The Envoy          - Vivian
      The Hero           - Goomink
      The Princess, too  - Goomelda
      The Soul Tuner     - Spector
      The Unmotivated    - Texen
      The Ex-Champion    - Celine
      The Diva           - Madelis
      The Better Diva    - Cassandra <A>...What?
      The Experiment     - Zetta
      The Tool           - Jenner
      The Captain        - Neved
      The Analyst        - Anastasia
      The Jagged         - Katsu
      The Unmerciful     - Percival
      The Taken          - Horace
      The Victim         - Sabine
      The Unwanted       - Comet
      The Unwarranted    - Cosmia
      The Griever        - Xara
      The Technician     - Jean
      The Popstar        - Risa
      The Torutured      - Kenneth
      The Forgotten      - Taelia
      The News Anchor    - Volta
      The Personality    - Jolene
      The Dancer         - Santiago (Rorim B)
      The Surrogate      - Holly
      The Evil Princess  - Melanie
      The Con Artist     - Mr. Luck
      The Deity of Time  - Tiempa
      The Deity of Space - Spacea


      The Illegal Player   - Adrest
      The Queen of Beasts  - Storm-Nym
      The King of Kingdoms - Vitus











      <T>EIZEN: Why wasn't I included?




  _END_







  # Stop Editing


  def main
    #-------------------------------
    # Animated Background Setup
    #-------------------------------
    @sprite = IconSprite.new(0, 0)
    @backgroundList = CreditsBackgroundList
    @backgroundGameFrameCount = 0
    # Number of game frames per background frame.
    @backgroundG_BFrameCount = CreditsFrequency * Graphics.frame_rate
    @sprite.setBitmap("Graphics/Titles/" + @backgroundList[0])
    #------------------
    # Credits text Setup
    #------------------
    creditArray = [CREDIT, CREDIT1, CREDIT2, CREDIT3, CREDIT4, CREDIT5]
    active_credit = creditArray[$game_variables[22]]
    credit_lines = active_credit.split(/\n/)
    credit_lines.delete_if { |line| line.match(/^<L>/) || line.match(/^<T>/) }  if $game_switches[:Anna_Smiles]
    credit_lines.delete_if { |line| line.match(/^<A>/) || line.match(/^<H>/) }  if !($game_switches[:Anna_Smiles] || $game_switches[1941])
    credit_bitmap = Bitmap.new(Graphics.width, 32 * credit_lines.size)
    credit_lines.each_index do |i|
      line = credit_lines[i]
      speaker = 0
      if line.include?("<L>")
        speaker = 1
        line["<L>"] = ""
      elsif line.include?("<A>")
        speaker = 2
        line["<A>"] = ""
      elsif line.include?("<T>")
        speaker = 3
        line["<T>"] = ""
      elsif line.include?("<H>")
        speaker = 4
        line["<H>"] = ""
      end
      align = 1 # Centre align
      if line.include?("<left>")
        align = 0
        line["<left>"] = ""
      elsif line.include?("<right>")
        align = 2
        line["<right>"] = ""
      end
      line = line.split("<s>")
      # LINE ADDED: If you use in your own game, you should remove this line
      pbSetSystemFont(credit_bitmap) # <--- This line was added # ame: ok look it says remove this line but the font is fuggles without it
      x = 0
      xpos = 0
      linewidth = Graphics.width
      for j in 0...line.length
        if line.length > 1
          xpos = (j == 0) ? 0 : 20 + Graphics.width / 2
          align = (j == 0) ? 2 : 0 # Right align : left align
          linewidth = Graphics.width / 2 - 20
        end
        credit_bitmap.font.color = CREDITS_SHADOW
        credit_bitmap.draw_text(xpos, i * 32 + 8, linewidth, 32, line[j], align)
        credit_bitmap.font.color = CREDITS_OUTLINE[speaker]
        credit_bitmap.draw_text(xpos + 2, i * 32 - 2, linewidth, 32, line[j], align)
        credit_bitmap.draw_text(xpos, i * 32 - 2, linewidth, 32, line[j], align)
        credit_bitmap.draw_text(xpos - 2, i * 32 - 2, linewidth, 32, line[j], align)
        credit_bitmap.draw_text(xpos + 2, i * 32, linewidth, 32, line[j], align)
        credit_bitmap.draw_text(xpos - 2, i * 32, linewidth, 32, line[j], align)
        credit_bitmap.draw_text(xpos + 2, i * 32 + 2, linewidth, 32, line[j], align)
        credit_bitmap.draw_text(xpos, i * 32 + 2, linewidth, 32, line[j], align)
        credit_bitmap.draw_text(xpos - 2, i * 32 + 2, linewidth, 32, line[j], align)
        credit_bitmap.font.color = CREDITS_FILL[speaker]
        credit_bitmap.draw_text(xpos, i * 32, linewidth, 32, line[j], align)
      end
    end
    @trim = Graphics.height / 18
    @credit_sprite = Sprite.new(Viewport.new(0, @trim, Graphics.width, Graphics.height - (@trim * 2)))
    @credit_sprite.bitmap = credit_bitmap
    @credit_sprite.z = 9998
    @credit_sprite.oy = -(Graphics.height - @trim) # -430
    @frame_index = 0
    @bg_index = 0
    @pixels_banked = 0
    @zoom_adjustment = 1 / $ResizeFactor
    @last_flag = false
    #--------
    # Setup
    #--------
    # Stops all audio but background music.
    @PreviousBGM = $game_system.getPlayingBGM
    pbMEStop()
    pbBGSStop()
    pbSEStop()
    #  pbBGMFade(2.0)
    #  pbBGMPlay(CreditsMusic)
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @sprite.dispose
    @credit_sprite.dispose
    $PokemonGlobal.creditsPlayed = true
    # pbBGMPlay(@PreviousBGM)
  end

  # #Checks if credits bitmap has reached it's ending point
  def last?
    if @frame_index > (@credit_sprite.bitmap.height + Graphics.height + (@trim / 2))
      $scene = $game_map ? Scene_Map.new : nil
      # pbBGMFade(2.0)
      return true
    end
    return false
  end

  # Check if the credits should be cancelled
  def cancel?
    if Input.trigger?(Input::B) # && $PokemonGlobal.creditsPlayed
      $scene = Scene_Map.new
      #  pbBGMFade(1.0)
      return true
    end
    return false
  end

  def update
    @backgroundGameFrameCount += 1
    if @backgroundGameFrameCount >= @backgroundG_BFrameCount # Next slide
      @backgroundGameFrameCount = 0
      @bg_index += 1
      @bg_index = 0 if @bg_index >= @backgroundList.length
      @sprite.setBitmap("Graphics/Titles/" + @backgroundList[@bg_index])
    end
    return if cancel?
    return if last?

    @pixels_banked += CreditsScrollSpeed
    if @pixels_banked >= @zoom_adjustment
      @credit_sprite.oy += (@pixels_banked - @pixels_banked % @zoom_adjustment)
      @pixels_banked = @pixels_banked % @zoom_adjustment
    end
    @frame_index += CreditsScrollSpeed # This should fix the non-self-ending credits
  end
end

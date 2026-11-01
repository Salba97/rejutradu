# Rift Dex class. Based on xLed's Jukebox Scene class.
class Scene_RiftDex
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
    @riftNotes = riftNotes
  end

  #-----------------------------------------------------------------------------
  # * Main Processing
  #-----------------------------------------------------------------------------
  def main
    # Makes the text window
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["background"] = IconSprite.new(0, 0)
    @sprites["background"].setBitmap("Graphics/Pictures/navbg")
    @sprites["background"].z = 255
    @choices = riftNotesObtained
    @sprites["command_window"] = Window_CommandPokemonWhiteArrow.newWithSize(@choices, 94, 63, 324, 288, colors: ColorArrays[:Default])
    @sprites["command_window"].windowskin = nil
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].z = 256
    render_header
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepares for transition
    Graphics.freeze
    # Disposes the windows
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def render_header
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(_INTL("Rift Dex"), 2, -18, 128, 64, @viewport)
    @sprites["header"].baseColor = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.new(0, 0, 0)
    @sprites["header"].windowskin = nil
  end

  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    pbUpdateSpriteHash(@sprites)

    # update command window and the info if it's active
    if @sprites["command_window"].active
      update_command
      return
    end
  end

  #-----------------------------------------------------------------------------
  # * Command controls
  #-----------------------------------------------------------------------------
  def update_command
    index = @sprites["command_window"].index
    # If B button was pressed
    if Input.trigger?(Input::B) || (Input.trigger?(Input::C) && index == @choices.length - 1)
      # Switch to map screen
      pbPlayCancelSE()
      $scene = Scene_Pokegear.new(:rift)
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      rift = @riftNotes[index]
      if $game_switches[rift]
        pbPlayDecisionSE()
        $scene = Scene_RiftDex_Info.new(rift, index, @riftNotes)
      end
      return
    end
  end

  #-----------------------------------------------------------------------------
  # * Determines which Rifts the trainer has data for
  #-----------------------------------------------------------------------------
  def riftNotesObtained
    riftNotes = []
    for rift in @riftNotes
      riftNotes.push($game_switches[rift] ? RIFTDATA[rift][:name] : ColorTags[:Gray2] + "???")
    end
    riftNotes.push(ColorTags[:Gray2] + _INTL("Volver"))
    return riftNotes
  end

  #-----------------------------------------------------------------------------
  # * Determines which Rift notes should be in the menu
  #-----------------------------------------------------------------------------
  def riftNotes
    rifts = []
    for rift in RIFTDATA.keys
      next if [:RIFTWEAVILE, :RIFTNIHILEGO].include?(rift)
      rifts.push(rift)
    end
    return rifts
  end
end

# :x and :y control the positioning of the sprite in Rift Dex
# :x and :y are handled as negative number offsets.
# :spriteSwitch gets turned on when the respective rift is first seen in battle
# :seen indicates having beaten the first battle against the respective rift, needed for legacy save files
RIFTDATA = {
  :RIFTFERROTHORN => {
    :name => _INTL("Code: Drifio"),
    :desc => _INTL("En su Forma Suspendida, le gusta moverse de manera similar a lo que se conoce como un «yoyó».\nEn esta forma no es muy poderoso, pero, cuando se enfurece, adopta su verdadera forma. Rueda sin parar por las paredes y arrolla todo lo que encuentra a su paso.\nLos espacios cerrados son el entorno ideal para combatir."),
    :notes => _INTL("Ferrothorn se ofreció voluntariamente para convertirse en un Rift. Aunque probablemente no sabía en qué se estaba metiendo.\nLa transformación fue dolorosa, pero parece gustarle bastante su nueva forma. Utiliza su cuerpo como una rueda y se desplaza alegremente por todo tipo de terrenos.\nFlora lo abandonó cuando dejó de obedecer sus órdenes y prefirió jugar. Parece que le molestó bastante que lo encontraras y lo derrotaras."),
    :species => :FERROTHORN,
    :form => "Unleashed Rift Form",
    :dexForms => ["Suspended Rift Form"],
    :x => 4,
    :y => 36,
  },
  :RIFTCHANDELURE => {
    :name => _INTL("Code: Feris"),
    :desc => _INTL("Un ser compuesto por completo de fuego y energía espectral. Sus orígenes son un misterio, pero hay algo que sí se sabe.\nSiente un profundo arrepentimiento por no haber podido proteger a su Entrenador.\nNo puede mantener un solo Tipo. Quizá por eso tampoco fue capaz de hacer algo tan básico como proteger a su Entrenador."),
    :notes => _INTL("El caso de Chandelure es especial, ya que se convirtió en un Rift sin haber estado nunca en contacto con la Materia Rift... Quizá aferrarse a tantos remordimientos después de morir puede tener consecuencias. Existen leyendas sobre personas que se convierten en monstruos si mueren con una enorme cantidad de ira o arrepentimiento acumulados. Tal vez ocurra lo mismo con los Pokémon. Si Narcissa encontrara a Chandelure en este estado, ¿crees que seguiría así?\nCuriosamente, la esfera que contiene la llama en el centro permanece completamente inmóvil mientras el resto de su cuerpo gira a su alrededor."),
    :species => :CHANDELURE,
    :form => "Rift Form",
    :x => 6,
    :y => 18,
  },
  :RIFTGYARADOS => {
    :name => _INTL("Code: Evo"),
    :desc => _INTL("Este ser fue creado por Zetta, ejecutivo del Equipo Xen.\n\nUn conjunto de Magikarp fusionados para crear esta caótica bestia.\n\nCarece de pensamiento individual. Gyarados cambia constantemente de dimensión sin motivo ni rumbo."),
    :notes => _INTL("Los Magikarp utilizados para crear esta criatura no tenían ningún sueño ni aspiración en la vida. Eran simples Magikarp... Eso es lo que pensarías a primera vista, pero nada podría estar más lejos de la realidad. Todos y cada uno de ellos soñaban con convertirse algún día en Gyarados. Dicen que tengas cuidado con lo que deseas, y este es un buen ejemplo. Ahora todos estos Magikarp luchan por conservar su individualidad, pero jamás lo conseguirán. Si nadie lo detuviera, saltaría sin parar entre dimensiones, sin razón ni propósito. Una triste pérdida de espacio."),
    :species => :GYARADOS,
    :form => "Rift Form",
    :x => 6,
    :y => 48,
    :hideShadow => true
  },
  :RIFTGALVANTULA => {
    :name => _INTL("Code: Materna"),
    :desc => _INTL("El corazón de Galvantula está completamente cerrado debido a su prematura muerte.\nSu espíritu permanece unido a este mundo únicamente por su instinto maternal y su necesidad de cuidar de sus crías.\nAtacar a sus hijos la enfurecerá enormemente."),
    :notes => _INTL("Otra madre más... Empiezo a detectar un patrón. Se desconoce cuál era el hogar original de esta Galvantula, pero sus crías ahora infestan la Cueva Amatista. No hay suficientes como para causar problemas inmediatos de población, aunque durante los próximos años podría producirse un cambio importante en el ecosistema. En cualquier caso, esta Galvantula no llegará a ver crecer a sus hijos... Si es que siquiera tienen esa oportunidad."),
    :species => :GALVANTULA,
    :form => "Rift Form",
    :dexForms => ["Rift Egg"],
    :x => 6,
    :y => 18,
  },
  :RIFTVOLCANION => {
    :name => _INTL("Code: Statia"),
    :desc => _INTL("Este Volcanion no es más que una cría. Fue separado de su madre en las profundidades del Monte Valor.\n\nVive sumido en la desesperación por no poder volver a ver a su madre.\n\nPermanece completamente inmóvil, de una forma bastante patética."),
    :notes => _INTL("Volcanion nació en el mismísimo núcleo del Monte Valor. Se dice que la entrada a ese núcleo está oculta. Entonces, ¿cómo consiguió encontrarlo el Equipo Xen? En cualquier caso, lo encontraron y se lo llevó Madelis, ejecutiva de Xen. Sin embargo, elegir a este Volcanion fue un error por su parte, ya que el destino que le esperaba era para su madre. Aunque eso ya no importa. Al fin y al cabo, cumplió la tarea que debía realizar su madre. Me pregunto qué estará pensando ella ahora. Seguro que sigue allí, en el núcleo del Monte Valor, lamentando la pérdida de su hijo."),
    :species => :VOLCANION,
    :form => "Rift Form",
    :x => 6,
    :y => 44,
  },
  :RIFTCARNIVINE => {
    :name => _INTL("Code: Sarpa"),
    :desc => _INTL("Este Rift fue creado hace mucho tiempo mediante el poder de la Raíz Maldita.\nExisten textos que describen su afinidad por la música y el baile.\nAunque carece de ojos, es capaz de utilizar la ecolocalización.\n\nAl parecer, también sabe crear buenos ritmos."),
    :notes => _INTL("Este Carnivine perteneció en el pasado a un niño de una aldea cercana. Un día, ambos se adentraron en el templo sin permiso y encontraron una tumba sagrada. En ella descansaba la Raíz Maldita. Por entrar en aquella cámara, Enamorus los castigó a ambos. El niño debía compartir el dolor que sentía la Raíz Maldita. Cada vez que los humanos cometieran atrocidades contra la naturaleza, él sufriría por sus pecados. A cambio, Carnivine permanecería para siempre en el templo, protegiendo la Raíz Maldita durante toda la eternidad. Quienes profanen a Gaia aprenderán a suplicar por su misericordia."),
    :species => :CARNIVINE,
    :form => "Rift Form",
    :x => 14,
    :y => 66,
  },
  :RIFTGARBODOR => {
    :name => _INTL("Code: Corroso"),
    :desc => _INTL("Zetta convirtió a Garbodor en un Rift cuando este empezó a dominarlo durante el combate.\nBusca incansablemente a Melia.\nSolo quiere recibir reconocimiento y elogios por proteger a su madre.\nAunque...\nNo es más que basura, y lo sabe."),
    :notes => _INTL("Garbodor había seguido luchando por su cuenta contra Zetta y Code: Evo y, afortunadamente, gracias a su combinación de Tipos, estuvo a punto de ganar.\nComo último recurso, Zetta transformó a Garbodor en un monstruo.\nGarbodor ya había nacido en circunstancias misteriosas. Su experiencia vital no pudo ayudarlo a resistir esta maldición, y esa carencia no hizo más que aumentar su propia corrupción.\nSe lanzó al mar con la esperanza de nadar hasta East Gearen y encontrar a Melia, pero acabó en las solitarias profundidades de las alcantarillas de West Gearen. Un lugar apropiado para algo tan repugnante."),
    :species => :GARBODOR,
    :form => "Rift Form",
    :shiny => true,
    :x => 8,
    :y => 38,
  },
  :RIFTAELITA => {
    :name => _INTL("Code: Bella"),
    :desc => _INTL("La maldición de Aelita hecha realidad. Heredada tanto de Vivian como de Taelia, esta maldición está harta de vivir encadenada.\n\nQuiere crear su mundo perfecto, y tú te interpones en su camino.\nSu True Shot aumenta un 30 % la potencia de los movimientos de tipo Bola y Bomba.\nEso va a doler.\nPuede que mueras aquí."),
    :notes => _INTL("El pasado de Aelita se ha mantenido oculto deliberadamente. Ahora esa verdad ya no puede seguir escondiéndose. Pero ¿por qué se manifiesta de esta manera? ¿Para luchar desde lejos y esconderse en un mundo inmenso que solo un niño podría amar?\n¿Es consecuencia de su naturaleza testaruda o realmente vive para aislarse del mundo?\nAunque la maldición parece haber sido «destruida», siempre formará parte de ella.\nEsa es su marca. Es su castigo por intervenir en fuerzas con las que los humanos no deberían entrometerse.\nLa culpa no es suya, sino de Vivian.\nQue su alma sea condenada."),
    :species => :REGIROCK,
    :form => "Rift Form",
    :x => 6,
    :y => 46,
  },
  :ANGELOFDEATH => {
    :name => _INTL("Code: Angelus"),
    :desc => _INTL("La corrupción llegó hasta ella cuando aún era muy joven, pero el «Maestro Indriad» consiguió liberarla.\nSu ADN contiene rastros de Gallade, lo que dio origen a la guja de su brazo derecho.\n\nSu habilidad, Execution, acabará con los Pokémon que tengan pocos PS.\nContempla al Ángel de la Muerte."),
    :species => :GARDEVOIR,
    :form => "Angel of Death",
    :x => 8,
    :y => 20,
    :hideShadow => true,
    :hideNotes => true
  },
  :RIFTHIPPOWDON => {
    :name => _INTL("Code: Garna"),
    :desc => _INTL("Se creía que había desaparecido durante la calamidad, pero esperó pacientemente en las profundidades de la Zona Cero.\n\nFlora utilizó su poder, «muy a su pesar», para mantener a la gente alejada de la Zona Cero.\n\nGracias a su habilidad, seguirá acumulando reservas en cada turno. Procura que no te devore..."),
    :notes => _INTL("Gloria era una Hippopotas que sobrevivió a la Calamidad. Se enterró bajo tierra cuando el terreno se desgarró. Se desconoce cómo llegó a corromperse. ¿Quizá cayó en uno de los numerosos cráteres que conducen al abismo? Es imposible saberlo, pero hay algo seguro: sobrevivió para poder encontrar de nuevo a su Entrenadora algún día. No morirá hasta conseguirlo. A menos, claro está, que la maten.\n...\nDice que está buscando otra vez a aquella chica de pelo rosa. ¿La que tocaba el piano de forma tan «hermosa»?\n¿Sabes de quién está hablando?"),
    :species => :HIPPOWDON,
    :form => "Rift Form",
    :gender => :F,
    :x => 4,
    :y => 14,
  },
  :DUFAUX => {
    :name => _INTL("Code: Rembrence"),
    :desc => _INTL("Su verdadero cuerpo se esconde dentro del deteriorado recipiente que es el muñeco de Clefairy de Celesia.\n\nNo debes subestimar sus engaños.\nGracias a sus corrientes eléctricas, puede alterar el flujo del tiempo.\nEste da un poco de miedo, ¿verdad? Reducir sus estadísticas no sirve de nada."),
    :notes => _INTL("Este caso es bastante interesante. Se ha corrompido sin utilizar Materia Rift y, además, parece haber desarrollado cierta consciencia. Me pregunto si se debe al intelecto del propio Pokémon o a la niña que murió junto a él. ¿Quizá a ambos? En cualquier caso, Dufaux, como se hace llamar, puede mantener una posición algo más elevada gracias a su capacidad para comunicarse. Su poder para viajar en el tiempo también despierta mi interés... ¿Su electricidad puede atravesar el mundo? ¿O quizá se comunica con el Núcleo y le da órdenes? Creo que estudiaré este caso para utilizarlo en el futuro."),
    :species => :FROSLASS,
    :form => "Rift Form",
    :x => 0,
    :y => 0,
    :spriteOverride => "Graphics/Pictures/RiftDex/DUFAUXSprite"
  },
  :EARTHSHATTERER => {
    :name => _INTL("Code: Firma"),
    :desc => _INTL("En su forma inicial, su verdadero poder permanece dormido, pero no debes subestimarlo. Hará temblar tu mundo hasta sus cimientos.\nY sin tu núcleo...\nNo eres nada.\nComo siempre.\nTodos aquellos que amenacen la Tierra arderán."),
    :notes => _INTL("Torterra, cuando todavía era un Turtwig, estuvo presente durante el ataque a Alamissa. Uno de los supervivientes del ataque lo rescató; más tarde, esa persona acabaría convirtiéndose en un Admin. La amargura de Torterra por el ataque a Alamissa ha influido en su forma actual. Los fuegos que antes lo aterrorizaban ya no lo hacen. Ahora, cuando libera su poder, es él quien controla las llamas. Si Torterra nunca hubiera sido destruido, podríamos imaginar que habría abandonado su torre para perseguir a quienes destruyeron su hogar. Por desgracia para él, eso nunca ocurrirá."),
    :species => :TORTERRA,
    :form => "Rift Form",
    :altForm => "Rift Form 2",
    :x => -2,
    :y => 36,
    :formOverride => "Rift Form 2"
  },
  :CHITWO => {
    :name => _INTL("Code: Dos"),
    :desc => _INTL("¡Este Finneon perteneció a un Entrenador ya fallecido de la Isla Artrica!\n¡No quiere otra cosa que luchar!\n¡Aliado!\n¡Enemigo!\n¡Cuando empieza el combate, esas palabras no significan nada para él! ¡Más te vale prepararte para pelear!"),
    :notes => _INTL("A este pez no le importa el Equipo Xen. Lo único que quiere es luchar constantemente contra rivales poderosos. Los oponentes a los que se enfrentó en The Underground no eran nada del otro mundo. Antes de que apareciera el Interceptor, planeaba abandonar su torre para enfrentarse a su rival más poderoso hasta la fecha: el Xenpurgis. Se desconoce si podría derrotarlo, pero no le importa. Para él, luchar contra un rival digno y morir en el intento es una forma noble de morir. De los puños a la furia, y de la furia a la muerte."),
    :species => :FINNEON,
    :form => "Xenpurgis Guardian 2",
    :x => -2,
    :y => 12,
  },
  :TWINDANCERS => {
    :name => _INTL("Code: Sapphie"),
    :desc => _INTL("Ambas bailaban bajo el gran cerezo de la Ruta 2.\nCuando se llevaron a una, la otra la siguió.\nNunca se separaron.\nBailan eternamente, juntas,\nbajo la pálida sombra de la luna.\nQuienes se atrevan a separarlas conocerán la verdadera ira."),
    :notes => _INTL("Ambas Petilil son originarias de la Ruta 2. Cuando salía la luna, practicaban juntas sus bailes. Esto es un secreto, así que no se lo cuentes a nadie. Estas dos amantes murieron y renacieron como Pokémon. Fueron asesinadas durante una representación en la antigua guerra en la que participaron los siete reinos.\nSe dice que sus bailes podían aliviar el corazón de todos aquellos que las contemplaban. Más tarde se demostró que aquello no era cierto, ya que la Reina de Ghovora consideró su actuación un simple intento barato de ganarse su favor."),
    :species => :LILLIGANT,
    :form => "Rift Form",
    :altForm => "Rift Form 2",
    :x => 0,
    :y => 0,
    :spriteOverride => "Graphics/Pictures/RiftDex/TWINDANCERSSprite",
  },
  :KINGSOFAPPLES => {
    :name => _INTL("Code: Vinra"),
    :desc => _INTL("Se rumorea que esta manzana fue recogida durante la invasión del Equipo Xen a la Isla Terajuma.\n\nEste árbol solo quiere extender sus enredaderas y alimentar a sus crías.\nOye.\nTú pareces bastante apetitoso. ¿Quieres ser su primera comida?\nHe oído que morir a manos de un Dragón es todo un honor."),
    :notes => _INTL("Este Applin procede de la Caverna Jirukala, en la Isla Terajuma. Un Recluta corriente lo capturó y lo llevó de vuelta al cuartel general de Xen. El ejemplar anterior, que debía ocupar su puesto en el Xenpurgis, no alcanzó el potencial deseado. Debido a su vínculo con Hydrapple, Applin fue elegido como sustituto. Por desgracia, Hydrapple se encontró en la peor situación posible. Como pacifista, se niega a luchar. Cuando los científicos del Laboratorio Xen se dieron cuenta, aumentaron su Materia Rift para obligarlo a obedecer y combatir."),
    :species => :HYDRAPPLE,
    :form => "Rift Form",
    :x => 0,
    :y => 26,
  },
  :QUEENNIHILEGO => {
    :name => _INTL("Code: Regalia"),
    :desc => _INTL("La Reina de todos los Pokémon Rift. De ella nacen todas las formas de corrupción. Además, tiene todas esas formas de corrupción a su disposición. Conecta sus apéndices con todos los rincones del mundo para liberar a sus crías. Estas, a su vez, recopilan datos de todos los seres vivos."),
    :notes => _INTL("El poder de la Reina se ha amplificado utilizando el aura de Anju y la envoltura física de Vitus. Su propósito es recopilar tantos datos como sea posible de todos los rincones del mundo para su propia Reina, Storm-Nym. Sus apéndices tienen las mismas propiedades que Rift Gyarados: pueden extenderse, cambiar a otras dimensiones y mundos, y liberar a sus crías. Debido a este poder, la Reina permanece completamente inmóvil. Aunque eso no importa. Sus defensas son impenetrables. Ningún Pokémon es lo bastante fuerte como para romper esta gema. Tengo que reconocerle el mérito a Lorna... sabía lo que hacía con este ejemplar. En cualquier caso, lo mejor de ella es lo peor para mí. Ha desplegado a su Reina. Espera a que aparezca mi Rey."),
    :species => :NIHILEGO,
    :form => "Queen Form",
    :x => 70,
    :y => 80,
    :hideShadow => true,
  },
  :RIFTWEAVILE => {
    :name => _INTL("Code: ???"),
    :desc => _INTL(""),
    :species => :WEAVILE,
    :form => "Rift Form",
    :x => 10,
    :y => 35,
    :hideShadow => true,
    :hideNotes => true
  },
  :RIFTNIHILEGO => {
    :name => _INTL("Code: Scypo"),
    :desc => _INTL("Estas formas de Nihilego carecen de individualidad. Todas trabajan juntas mediante una mente colmena para recopilar datos y enviárselos a la Reina. Su caparazón es duro y difícil de arañar. Para una persona corriente, la única opción es huir."),
    :species => :NIHILEGO,
    :form => "Rift Form",
    :x => -30,
    :y => -35,
    :hideShadow => true,
    :hideNotes => true
  },
}

def getRiftSpriteSwitch(sym)
  return (sym.to_s + "Sprite").to_sym
end

def getRiftDefeatedSwitch(sym)
  return (sym.to_s + "Defeated").to_sym
end

class Pokedex
  alias _riftDex_setSeen setSeen unless method_defined?(:_riftDex_setSeen)
  def setSeen(pokemon)
    _riftDex_setSeen(pokemon)
    if pokemon.isRift?
      formname = $cache.pkmn[pokemon.species].forms[pokemon.form]
      RIFTDATA.each do |rift, riftData|
        if riftData[:species] == pokemon.species && (riftData[:form] == formname || riftData[:altForm] == formname)
          $game_switches[getRiftSpriteSwitch(rift)] = true
        end
      end
    end
  end
end

# Class for information screen

class Scene_RiftDex_Base

  PATH = "Graphics/Pictures/RiftDex/"

  def prepareRiftDexInfo(page = 0)
    @riftData = RIFTDATA[@rift].clone

    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    if page == 2
      graphic = PATH + "#{@rift}Notes"
      graphic = PATH + "notes" if !pbResolveBitmap(graphic)
    else
      graphic = PATH + "#{@rift}"
      graphic = PATH + "Rift" if !pbResolveBitmap(graphic)
    end
    @sprites["background"].setBitmap(graphic)
    @sprites["background"].z = 255
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 256

    mon = $cache.pkmn[@riftData[:species], @riftData[:form]]
    if page == 2
      drawNotes(mon)
    else
      drawSprite
      drawAbilities(mon) if page == 0
      drawText(mon) if page == 1
    end

    prepareRiftDexHeader(page)
  end

  def prepareRiftDexHeader(page = 0)
    return if @riftData[:hideNotes] && page == 2
    @sprites["heading"] = IconSprite.new(0, 0, @viewport)
    @sprites["heading"].setBitmap(PATH + "pageHeading#{$game_switches[:RiftNotes] ? "Notes" : ""}Blank")
    @sprites["heading"].z = 255
    @sprites["curpage"] = IconSprite.new(0, 0, @viewport)
    @sprites["curpage"].setBitmap(PATH + "pageHeading#{page}")
    @sprites["curpage"].z = 255
  end

  def drawAbilities(mon)
    bitmap = @sprites["overlay"].bitmap
    pbSetSystemFont(bitmap)

    x = 230
    y = 68
    width = 250
    lineheight = 32
    bossspecies = @rift
    bossspecies = (@rift.to_s + "1").intern if @rift == :RIFTGYARADOS
    bossdata = $cache.bosses[bossspecies]
    @shieldCount = (bossdata&.shieldCount || 0).to_s
    text = "<c=" + colorToRgb16(Color.new(200, 125, 55)) + ">" + _INTL("Resistencia del escudo: ") + "</c>" + "<c=" + colorToRgb16(Color.new(252, 226, 131)) + ">" + @shieldCount + "</c>"
    chars = getFormattedText(bitmap, x, y, width, -1, text, lineheight)
    drawFormattedChars(bitmap, chars)
    y = chars[-1][2] + lineheight
    @abilityText = []

    abilities = [mon.Abilities[0]]
    abilities.push($cache.pkmn[@riftData[:species], @riftData[:altForm]].Abilities[0]) if @riftData[:altForm]
    abilities.each { |ability|
      next if @abilityText.any? { |m| m[0] == ability }
      name = getAbilityName(ability)
      desc = getAbilityDesc(ability)

      pbSetSystemFont(bitmap)
      lineheight = 32
      text = "<c=" + colorToRgb16(Color.new(200, 125, 55)) + ">" + name + "</c>"
      chars = getFormattedText(bitmap, x, y, width, -1, text, lineheight)
      drawFormattedChars(bitmap, chars)
      y = chars[-1][2] + lineheight

      pbSetSmallFont(bitmap)
      lineheight = 24
      text = "<c=" + colorToRgb16(Color.new(252, 226, 131)) + ">" + desc + "</c>"
      chars = getFormattedText(bitmap, x, y, width, -1, text, lineheight)
      drawFormattedChars(bitmap, chars)
      y = chars[-1][2] + lineheight

      @abilityText.push([name, desc])
    }
  end

def drawText(mon)
  bitmap = @sprites["overlay"].bitmap
  pbSetSmallFont(bitmap)
  bitmap.font.size = 18

  @curtext = $game_switches[getRiftDefeatedSwitch(@rift)] ? @riftData[:desc] : _INTL("[No se pudo interpretar el archivo de texto adjunto. Vuelve a comprobarlo más adelante.]")
  drawFormattedTextEx(bitmap, 230, 72, 250, @curtext, Color.new(252, 226, 131), Color.new(0, 0, 0, 0), 20)
end

  def drawTypes(mon)
    bitmap = @sprites["overlay"].bitmap
    rect = Rect.new(0, 0, 64, 28)
    type1image = Bitmap.new(sprintf(PATH + "type%s", mon.Type1))
    if mon.Type2.nil?
      if mon.species == :ARCEUS
        type1image = Bitmap.new(PATH + "normal")
        bitmap.blt(260, 132, type1image, rect)
      else
        bitmap.blt(240, 136, type1image, rect)
      end
    else
      type2image = Bitmap.new(sprintf(PATH + "type%s", mon.Type2))
      bitmap.blt(240, 126, type1image, rect)
      bitmap.blt(240, 146, type2image, rect)
    end
  end

  def drawStats(mon)
    bitmap = @sprites["overlay"].bitmap
    stats = mon.BaseStats
    for i in 0..5
      colors = [Color.new(84, 179, 36), Color.new(46, 115, 24)]
      colors = [Color.new(179, 143, 36), Color.new(127, 93, 26)] if stats[i] < 192
      colors = [Color.new(179, 95, 36), Color.new(127, 60, 26)] if stats[i] < 128
      colors = [Color.new(179, 54, 54), Color.new(127, 38, 38)] if stats[i] < 64 || mon.species == :ARCEUS
      width = (stats[i] * 90 / 255).to_grid
      statbitmap = BitmapWrapper.new(90, 8)
      statbitmap.fill_rect(Rect.new(0, 2, width, 6), colors[0])
      statbitmap.fill_rect(Rect.new(0, 0, width, 2), colors[1])
      x = 262 + 120 * (i / 3)
      y = 176 + 18 * (i % 3)
      if mon.species == :ARCEUS
        x -= 6 if i % 2 == 0
        y += 4 if i % 2 == 1
        y += 2 if i % 3 == 0
        x -= 2 if i % 3 == 1
      end
      bitmap.blt(x, y, statbitmap, statbitmap.rect)
    end
  end

  def drawSprite
    bitmap = @sprites["overlay"].bitmap
    species = @riftData[:species]
    form = @riftData[:formOverride] || @riftData[:form]
    shiny = @riftData[:shiny]
    gender = @riftData[:gender]
    if !$game_switches[getRiftSpriteSwitch(@rift)]
      sprite = Bitmap.new(PATH + "nodata")
      bitmap.blt(24, 68, sprite, sprite.rect)
    else
      if !@riftData[:hideShadow]
        shadowbitmap = PokemonShadowSprite.new(@viewport)
        shadowbitmap = shadowbitmap.drawEllipse(36, Color.new(33, 33, 33))
        bitmap.blt(48, 194, shadowbitmap, Rect.new(0, 0, shadowbitmap.width, shadowbitmap.height - 2))
      end
      if @riftData[:spriteOverride]
        sprite = Bitmap.new(@riftData[:spriteOverride])
        bitmap.blt(24, 68, sprite, sprite.rect)
      else
        riftbitmap = pbPokemonBitmap(species, shiny, false, gender, form)
        bitmap.blt(24, 68, riftbitmap, Rect.new(@riftData[:x], @riftData[:y], 188, 150))
      end
    end
  end

def drawNotes(mon)
  return if @riftData[:hideNotes]
  bitmap = @sprites["overlay"].bitmap
  pbSetSmallFont(bitmap)
  bitmap.font.size = 18

  @curtext = $game_switches[getRiftDefeatedSwitch(@rift)] ? @riftData.fetch(:notes, _INTL("[No se ha encontrado texto adicional.]")) : _INTL("[No se pudo interpretar el archivo de texto adjunto. Vuelve a comprobarlo más adelante.]")
  drawFormattedTextEx(bitmap, 18, 50, 480, @curtext, Color.new(252, 226, 131), Color.new(13, 13, 28, 0), 20)
end

  def ttsRift(ttsIndex, interrupt = false)
    text = ""
    if ttsIndex != 2
      species = @riftData[:species]
      form = @riftData[:form]
      name = getMonName(species)
      mon = $cache.pkmn[species, form]
      type1 = mon.Type1
      type2 = mon.Type2
      type2 = :QMARKS if @rift == :RIFTCHANDELURE
      basestats = mon.BaseStats.clone
      for i in 0...basestats.length
        basestats[i] = (basestats[i] / 255.0 * 100).round(0)
        basestats[i] = 1 if basestats[i] == 0
      end
      text = _INTL("Rift {1}. {5}. Resistencia del escudo: {6}. Tipo {2}{3}. {4} habilidades. ", name, type1, type2 ? _INTL(" y {1}", type2) : "", @abilityText.length, @riftData[:name], @shieldCount) if ttsIndex == 0
      text = _INTL("PS: {1} %, Ataque: {2} %, Defensa: {3} %, Ataque Especial: {4} %, Defensa Especial: {5} %, Velocidad: {6} %", basestats[0], basestats[1], basestats[2], basestats[3], basestats[4], basestats[5]) if ttsIndex == 1
    else
      if @page == 0
        text = ""
        abil = 1
        @abilityText.each { |a|
          name, desc = a
          text += _INTL("Habilidad {1}: {2}. Descripción: {3} ", abil, name, desc)
          abil += 1
        }
      else
        text = @curtext
      end
    end
    tts(text, interrupt)
  end
end

class Scene_RiftDex_Info < Scene_RiftDex_Base
  attr_accessor :background
  attr_accessor :index

  def initialize(rift, index, riftNotes)
    @rift = rift
    @index = index
    @riftNotes = riftNotes
    @page = 0
    @ttsIndex = -1
  end

  def main
    prepareRiftDexInfo(@page)
    tts(_INTL("Pantalla de Rift Dex: Usa las teclas Arriba y Abajo para cambiar de entrada. Usa las teclas Izquierda y Derecha para cambiar de página. Usa Ctrl + Arriba o Abajo para desplazarte entre las líneas."))
    Graphics.transition
    tts(_INTL("Rift {1} de {2}: {3}.", @index + 1, @riftNotes.length, RIFTDATA[@rift][:name])) if @riftNotes.length > 1
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def update
    pbUpdateSpriteHash(@sprites)
    if Input.press?(Input::CTRL) && Input.trigger?(Input::DOWN) # Next TTS line
      changeTTS(1)
    elsif Input.press?(Input::CTRL) && Input.trigger?(Input::UP) # Prev TTS line
      changeTTS(-1)
    elsif Input.trigger?(Input::DOWN)
      changeRift(1)
    elsif Input.trigger?(Input::UP)
      changeRift(-1)
    elsif Input.trigger?(Input::RIGHT)
      changePage(1)
    elsif Input.trigger?(Input::LEFT)
      changePage(-1)
    end
    if Input.trigger?(Input::B)
      # Switch to map screen
      pbPlayCancelSE()
      $scene = Scene_RiftDex.new(@index)
      return
    end
  end

  def redrawPage
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @rift = @riftNotes[@index]
    prepareRiftDexInfo(@page)
    $tts&.clear
  end

  def changeRift(increment)
    oldindex = @index
    loop do
      @index += increment
      if @index >= @riftNotes.length
        @index = 0
      elsif @index < 0
        @index = @riftNotes.length - 1
      end
      break unless !$game_switches[@riftNotes[@index]]
    end
    return if @index == oldindex

    pbPlayDecisionSE()
    redrawPage
    @ttsIndex = -1
    tts(_INTL("Rift {1} de {2}: {3}.", @index + 1, @riftNotes.length, RIFTDATA[@rift][:name])) if @riftNotes.length > 1
  end

  def changePage(increment)
    @page += increment
    maxPage = $game_switches[:RiftNotes] ? 2 : 1
    if @page > maxPage
      @page = 0
    end
    if @page < 0
      @page = maxPage
    end
    @ttsIndex = -1

    pbPlayDecisionSE
    redrawPage
    if @page != 0
      ttsRift(2, true)
    end
  end

  def changeTTS(increment)
    oldindex = @ttsIndex
    @ttsIndex += increment
    if @ttsIndex > 2
      @ttsIndex = 0
    end
    if @ttsIndex < 0
      @ttsIndex = 2
    end
    @ttsIndex = 0 if @page == 2 || oldindex == -1
    return if @ttsIndex == oldindex

    ttsRift(@ttsIndex, true)
  end
end

class Scene_BossDex_Battle < Scene_RiftDex_Base
  def pbStartScene(rifts)
    @index = 0
    @page = 0
    @rifts = rifts
    @ttsIndex = -1
    pbDrawPage
    tts(_INTL("Pantalla de Rift Dex: Usa las teclas Arriba y Abajo para cambiar de entrada. Usa las teclas Izquierda y Derecha para cambiar de página. Usa Ctrl + Arriba o Abajo para desplazarte entre las líneas."))
    pbFadeInAndShow(@sprites)
    tts(_INTL("Rift {1} de {2}: {3}.", @index + 1, @rifts.length, RIFTDATA[@rift][:name])) if @rifts.length > 1
    loop do
      Graphics.update
      Input.update
      update
      break if @close
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbSwitchRiftNotes
    pbPlayDecisionSE()
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbDrawPage
    $tts&.clear
  end

  def pbDrawPage
    @rift = @rifts[@index]
    prepareRiftDexInfo(@page)
    pbAddArrows
  end

  def pbAddArrows
    if @index != 0
      @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
      @sprites["uparrow"].x = Graphics.width / 2 - @sprites["uparrow"].framewidth / 2
      @sprites["uparrow"].y = 32
      @sprites["uparrow"].z = 256
      @sprites["uparrow"].play
    end
    if @index != @rifts.length - 1
      @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
      @sprites["downarrow"].x = Graphics.width / 2 - @sprites["downarrow"].framewidth / 2
      @sprites["downarrow"].y = Graphics.height - @sprites["downarrow"].frameheight
      @sprites["downarrow"].z = 256
      @sprites["downarrow"].play
    end
  end

  def update
    pbUpdateSpriteHash(@sprites)
    if Input.press?(Input::CTRL) && Input.trigger?(Input::DOWN) # Next TTS line
      changeTTS(1)
    elsif Input.press?(Input::CTRL) && Input.trigger?(Input::UP) # Prev TTS line
      changeTTS(-1)
    elsif Input.trigger?(Input::UP)
      changeRift(-1)
    elsif Input.trigger?(Input::DOWN)
      changeRift(1)
    elsif Input.trigger?(Input::LEFT)
      changePage(-1)
    elsif Input.trigger?(Input::RIGHT)
      changePage(1)
    elsif Input.trigger?(Input::B) || Input.trigger?(Input::Z)
      pbPlayCancelSE()
      @close = true
    end
  end

  def changeRift(increment)
    oldindex = @index
    loop do
      @index += increment
      if @index >= @rifts.length
        @index = 0
      elsif @index < 0
        @index = @rifts.length - 1
      end
      break unless !$game_switches[@rifts[@index]]
    end
    return if @index == oldindex

    pbSwitchRiftNotes
    @ttsIndex = -1
    tts(_INTL("Rift {1} de {2}: {3}.", @index + 1, @rifts.length, RIFTDATA[@rift][:name])) if @rifts.length > 1
  end

  def changePage(increment)
    @page += increment
    maxPage = $game_switches[:RiftNotes] ? 2 : 1
    if @page > maxPage
      @page = 0
    end
    if @page < 0
      @page = maxPage
    end
    @ttsIndex = -1

    pbSwitchRiftNotes
    if @page != 0
      ttsRift(2, true)
    end
  end

  def changeTTS(increment)
    oldindex = @ttsIndex
    @ttsIndex += increment
    if @ttsIndex > 2
      @ttsIndex = 0
    end
    if @ttsIndex < 0
      @ttsIndex = 2
    end
    @ttsIndex = 0 if @page == 2
    return if @ttsIndex == oldindex || oldindex == -1

    ttsRift(@ttsIndex, true)
  end
end

def receiveRiftReadout(sym)
  if !$game_switches[:RiftDex]
    pbFlash(Color.new(255, 255, 255, 255), 10)
    pbSEPlay("PRSFX- Aura Sphere1")
    Kernel.pbMessage(_INTL("El CyberNav ya puede recibir datos sobre los Pokémon de la Grieta Dimensional."))
    $game_switches[:RiftDex] = true
  end

  data = RIFTDATA.find { |key, value| key == sym }[1]
  if !data
    dp("Could not find Rift Dex data for entry #{sym.inspect}. please report thx <3")
    return
  end

  3.times { Kernel.pbMessage(_INTL("Descargando...")) }
  pbSEPlay("PRSFX- Foresight2")
  Kernel.pbMessage(_INTL("Este archivo de datos contiene información sobre {1}.", data[:name]))
  Kernel.pbMessage(_INTL("Puedes encontrar más información sobre {1} en el Rift Dex.", data[:name]))

  if !$game_switches[$cache.FEData[:DIMENSIONAL].fieldAppSwitch]
    Kernel.pbMessage(_INTL("Se han encontrado datos adicionales."))
    pbReceiveFieldReadout(:DIMENSIONAL)
  end
  pbSetSwitch(Switches[sym], true)
end
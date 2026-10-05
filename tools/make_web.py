#!/usr/bin/env python3
"""Generates the website's front page, in both languages.

The design is the one shared by the series (tools/web_style.py) and the page
comes out self-contained, with the images embedded as data URIs.

The images are NOT illustrations or captures: they are drawn from the ROM's
own bytes by tools/graphics.py, running in Python the same run-length
decompressor, the same character loader and the same column builder that the
Z80 runs. None of them has been retouched.

Usage: make_web.py <docs/images> <output.html> <language>
"""
import base64
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from web_style import STYLE                                   # noqa: E402

# The numbers are not written by eye: tools/figures.py (`make figures`)
# counts them over the sources and the build and writes them here. ROUTINES
# are the code labels with a proper name; DENSITY is the share of
# instructions that carry a line comment.
CODE_BYTES = 25474
DATA_BYTES = 105598
ROUTINES = 914
STAGES = 12
DENSITY = "23,0"


def thousands(n, lang):
    return f"{n:,}".replace(",", "." if lang == "es" else ",")


TXT = {
    "es": dict(
        title="Nemesis / Gradius — desensamblado comentado",
        notice="<b>Aquí no hay ninguna ilustración ni captura.</b> Las pantallas "
               "y los doce mapas están <b>dibujados desde los bytes de la "
               "ROM</b>, ejecutando en Python el mismo descompresor de rachas, "
               "el mismo cargador de caracteres y el mismo montador de columnas "
               "que corre el Z80. El listado y las cifras salen del binario y se "
               "reproducen con <code>make</code>.",
        claim="El Gradius de Konami metido en un MegaROM de 128 KB para MSX1: "
              "doce fases, treinta y un tipos de bicho y un medidor de mejoras, "
              "con los mapas montados columna a columna en la RAM.",
        facts=["Konami · <b>© Konami 1986</b>",
               "MegaROM <b>RC-742</b>, 128 KB, mapper Konami4",
               "MSX1 · <b>16 bancos de 8 KB</b>",
               "Solo <b>6 bancos</b> llevan código"],
        nav=[("#numbers", "Las cifras"), ("#findings", "Hallazgos"),
             ("#screens", "Lo que dibuja")],
        docnav=[("EMPEZAR.html", "Empezar"), ("EL-JUEGO.html", "El juego"),
                ("EL-CARTUCHO.html", "El cartucho"),
                ("EL-CODIGO.html", "El código"),
                ("HALLAZGOS.html", "Hallazgos"),
                ("EN-EL-EMULADOR.html", "En el emulador"),
                ("PREGUNTAS-ABIERTAS.html", "Preguntas abiertas")],
        other=("../", "In English"),
        h_num="El cartucho en cifras", h_find="Lo que apareció al desmontarlo",
        h_scr="Lo que el cartucho dibuja",
        stats=[("100 %", "del binario explicado"),
               (str(ROUTINES), "rutinas bautizadas"),
               (str(STAGES), "fases dibujadas"),
               (thousands(CODE_BYTES, "es"), "bytes de código"),
               (thousands(DATA_BYTES, "es"), "bytes de datos"),
               (DENSITY + " %", "de líneas comentadas")],
        note_scr="Debajo de la imagen está de dónde sale y qué se está viendo. "
                 "Los mapas son la fase entera, de punta a punta.",
        legal="Esto es trabajo de documentación y preservación: el código y "
              "los gráficos siguen siendo de sus autores y de Konami, y la "
              "imagen del cartucho no se distribuye.",
    ),
    "en": dict(
        title="Nemesis / Gradius — a commented disassembly",
        notice="<b>There is not one illustration or capture here.</b> The "
               "screens and the twelve maps are <b>drawn from the bytes of the "
               "ROM</b>, by running in Python the same run-length decompressor, "
               "the same character loader and the same column builder the Z80 "
               "runs. The listing and the numbers come from the binary and are "
               "reproducible with <code>make</code>.",
        claim="Konami's Gradius squeezed into a 128 KB MegaROM for the MSX1: "
              "twelve stages, thirty-one kinds of enemy and a power-up meter, "
              "with the maps built one column at a time in RAM.",
        facts=["Konami · <b>© Konami 1986</b>",
               "An <b>RC-742</b> 128 KB MegaROM, Konami4 mapper",
               "MSX1 · <b>16 banks of 8 KB</b>",
               "Only <b>6 banks</b> carry code"],
        nav=[("#numbers", "The numbers"), ("#findings", "What turned up"),
             ("#screens", "What it draws")],
        docnav=[("GETTING-STARTED.html", "Getting started"),
                ("THE-GAME.html", "The game"),
                ("THE-CARTRIDGE.html", "The cartridge"),
                ("THE-CODE.html", "The code"),
                ("FINDINGS.html", "Findings"),
                ("IN-THE-EMULATOR.html", "In the emulator"),
                ("OPEN-QUESTIONS.html", "Open questions")],
        other=("es/", "En castellano"),
        h_num="The cartridge in numbers",
        h_find="What turned up when we took it apart",
        h_scr="What the cartridge draws",
        stats=[("100%", "of the binary explained"),
               (str(ROUTINES), "routines named"),
               (str(STAGES), "stages drawn"),
               (thousands(CODE_BYTES, "en"), "bytes of code"),
               (thousands(DATA_BYTES, "en"), "bytes of data"),
               (DENSITY.replace(",", ".") + "%", "of lines commented")],
        note_scr="Under each picture is where it comes from and what is on it. "
                 "The maps are the whole stage, end to end.",
        legal="This is documentation and preservation work: the code and "
              "artwork still belong to their authors and to Konami, and the "
              "cartridge image is not distributed.",
    ),
}

FINDINGS = {
    "es": [
        ("Las fases no van en orden, y cuatro de ellas son de bonus",
         "<p>De una fase se sale por dos sitios: <code>end_stage</code> le "
         "suma uno al numero de fase, y <code>jump_to_stage</code> le mete uno "
         "escrito a mano. A este segundo saltan OCHO sitios, cada uno con el "
         "suyo, y de ahi sale el recorrido de verdad: "
         "<b>1 - 2 - 9 - 3 - 10 - 4 - 11 - 5 - 6 - 7 - 12 - 8</b>. Las fases 9 a "
         "12 son <b>de bonus</b>: no llevan jefe y su final devuelve la fase a la "
         "3, la 4, la 5 y la 8. Y lo que las abre es el <b>blanco</b> del final "
         "de la fase: 0xB130, la unica instruccion de los 128 KB que para la "
         "pantalla, es la que miran los finales de la 2, la 3, la 4 y la 7.</p>"),
        ("La VRAM de este cartucho va del revés que la de la BIOS",
         "<p>Los ocho bytes de 0x575A programan los registros del VDP y no "
         "dejan nada donde lo deja la BIOS: los <b>patrones viven en 0x2000</b> "
         "y los <b>colores en 0x0000</b>, la tabla de nombres en 0x3800 y los "
         "atributos de sprite en 0x3B00, pegados detrás de ella. Quien lea las "
         "direcciones de este listado esperando el reparto de siempre se "
         "equivocará en todas.</p>"),
        ("El mapa no está en la pantalla: está en la RAM, y se corre a mano",
         "<p>Las veintidós filas de treinta y dos casillas viven en 0xED00. "
         "Cada paso de scroll, 0x469D las <b>corre una columna a la izquierda "
         "con veintidós <code>ldir</code></b>, 0x46AE mete por la derecha la "
         "columna nueva y 0x47FE sube los 704 bytes enteros a la VRAM con "
         "<code>outi</code>. La columna que entra sale del guión de la fase: "
         "cada cuatro columnas, seis números de pieza, y cada pieza son cuatro "
         "por cuatro caracteres. Con eso están dibujados los doce mapas de "
         "abajo, sin tocar el emulador.</p>"),
        ("Todo el azar del cartucho es el registro R del Z80",
         "<p>No hay ni una semilla ni un generador. Lo que hace de azar es "
         "<code>ld a,r</code>, el registro de refresco, que va contando solo "
         "con cada instrucción: de ahí salen <b>cuál de los dos dibujos de "
         "estrella</b> se pone en cada columna de cielo (0x4750), por qué "
         "puerta cae cada piedra de la lluvia (0xABC2), cuántos cuadros dura "
         "cada dibujo del bicho que parpadea a destiempo (0xB016 y 0xBC59) y "
         "cuántos anda el que camina por el suelo (0xAAE6).</p>"),
        ("Cada bicho es un número y dos rutinas",
         "<p>Un objeto se resume en su tipo, del 1 al 0x1F. Ese número manda en "
         "dos tablas gemelas: la de p00:0x5DFD dice <b>quién lo mueve</b> cada "
         "cuadro y la de p01:0x6B46 <b>quién acaba de montarlo</b> al nacer. De "
         "los treinta y un tipos, veinte tienen en el banco 3 al menos una de "
         "las dos, y dieciseis las dos, "
         "y por eso 0xA7B9..0xB537 es el trozo de código más largo del "
         "cartucho.</p>"),
        ("La espiral se hace sin senos: un octavo y una multiplicación",
         "<p>El tipo 0x1D se cierra en espiral alrededor de un centro, y para "
         "eso no hay tabla de senos: se toma la diferencia hasta el centro en "
         "una dirección, se parte por ocho con tres <code>sra a</code> y se le "
         "suma a la otra, y con la otra al revés. Eso es un giro de unos siete "
         "grados por paso. <b>El radio se encoge aparte</b>, multiplicando las "
         "dos coordenadas por un byte que empieza en 0xFF y baja de uno en uno "
         "cada 0x3C cuadros.</p>"),
        ("La demo no la juega ninguna máquina lista: es una grabación",
         "<p>En el banco 12 hay, por fase, una lista de parejas "
         "[cuántos cuadros][qué vale el mando]. 0x5CDA la va leyendo y mete el "
         "valor grabado en 0xE009, <b>la misma casilla donde 0x5767 deja lo que "
         "lee del joystick de verdad</b>, encendiéndole además el bit del "
         "disparo. Y arranca con todo puesto: 0x5CB8 llama a la misma rutina "
         "que da la clave <code>HYPER</code>.</p>"),
        ("Las claves de teclado solo se leen con el juego en pausa",
         "<p>0x44E7 mira la tecla GRAPH y, con la pantalla parada, 0x50C9 va "
         "guardando letras en 0xE1E8 hasta que se pulsa RETURN; entonces se "
         "compara lo escrito contra las palabras de 0x51BF. Si se escriben "
         "jugando no pasa nada: <b>el teclado de las claves solo existe "
         "mientras el juego está parado</b>.</p>"),
        ("La tabla de puntos de control se queda corta: la fase 12 lee código",
         "<p>La tabla de 0x4214 dice a qué distancia vuelve a arrancar cada fase "
         "si ya habías llegado hasta ahí, y se lee con <code>HL = 0x4212</code> "
         "y DOS VECES el número de fase. Tiene <b>once entradas</b>: la fase 1 "
         "coge la de 0x4214 y la 11 la de 0x4228. La fase 12 lee en 0x422A, que "
         "ya es código -los dos primeros bytes de un <code>call</code>-, y le "
         "sale 0xBACD, o sea 47.821. Como el scroll no llega ni de lejos a esa "
         "distancia, la fase 12 arranca siempre en 0x20: <b>el fallo es real y "
         "su efecto es ninguno</b>.</p>"),
        ("La marca escondida de Konami: RC-742 y グラディウス",
         "<p>Al final del banco 3, en el offset 0x07FFF del volcado, están el "
         "código de cartucho <b>RC-742</b> y ocho caracteres en katakana que se "
         "leen <b>グラディウス</b>, o sea <i>Gradius</i>. Es la firma que "
         "Konami escondía en sus cartuchos, y quien la descubrió y la documentó "
         "fue <b>Manuel Pazos</b>.</p>"),
    ],
    "en": [
        ("The stages are not played in order, and four of them are bonus",
         "<p>There are two ways out of a stage: <code>end_stage</code> adds "
         "one to the stage number, and <code>jump_to_stage</code> writes one "
         "straight in. EIGHT places jump to the second, each with its own "
         "number, and that gives the real running order: "
         "<b>1 - 2 - 9 - 3 - 10 - 4 - 11 - 5 - 6 - 7 - 12 - 8</b>. Stages 9 to "
         "12 are <b>bonus stages</b>: no boss, and their ending puts the stage "
         "back to 3, 4, 5 and 8. What opens them is the <b>target</b> at the end "
         "of the stage: 0xB130, the only instruction in the whole 128 KB that "
         "stops the screen, is the one the finals of stages 2, 3, 4 and 7 "
         "test.</p>"),
        ("This cartridge turns the VRAM map upside down",
         "<p>The eight bytes at 0x575A program the VDP registers and put "
         "nothing where the BIOS puts it: <b>patterns live at 0x2000</b> and "
         "<b>colours at 0x0000</b>, the name table sits at 0x3800 and the "
         "sprite attributes at 0x3B00, right behind it. Anyone reading the "
         "addresses in this listing expecting the usual layout will get every "
         "one of them wrong.</p>"),
        ("The map is not on screen: it is in RAM, and it is scrolled by hand",
         "<p>The twenty-two rows of thirty-two cells live at 0xED00. On every "
         "scroll step 0x469D <b>shifts them one column left with twenty-two "
         "<code>ldir</code>s</b>, 0x46AE feeds the new column in on the right, "
         "and 0x47FE pushes all 704 bytes to VRAM with <code>outi</code>. The "
         "incoming column comes from the stage script: six piece numbers every "
         "four columns, each piece four by four characters. That is how the "
         "twelve maps below are drawn, without touching an emulator.</p>"),
        ("All the randomness in the cartridge is the Z80's R register",
         "<p>There is no seed and no generator. What stands in for chance is "
         "<code>ld a,r</code>, the refresh register, which counts on its own "
         "with every instruction: it decides <b>which of the two star "
         "drawings</b> goes into each sky column (0x4750), which of the sixteen "
         "doors each falling rock comes through (0xABC2), how many frames each "
         "drawing of the out-of-step blinking enemy lasts (0xB016 and 0xBC59) "
         "and how far the one that walks on the ground gets (0xAAE6).</p>"),
        ("Every enemy is one number and two routines",
         "<p>An object boils down to its type, 1 to 0x1F. That number drives "
         "two twin tables: the one at p00:0x5DFD says <b>who moves it</b> every "
         "frame and the one at p01:0x6B46 <b>who finishes building it</b> when "
         "it is born. Of the thirty-one types, twenty have at least one of the "
         "two in bank 3 and sixteen have both, which is why 0xA7B9..0xB537 is "
         "the longest stretch of code in the cartridge.</p>"),
        ("The spiral is done without sines: an eighth and a multiplication",
         "<p>Type 0x1D closes in a spiral around a centre, and there is no sine "
         "table for it: take the difference to the centre along one axis, "
         "divide it by eight with three <code>sra a</code> and add it to the "
         "other, then the same the other way round. That is a turn of about "
         "seven degrees per step. <b>The radius shrinks separately</b>, "
         "multiplying both coordinates by a byte that starts at 0xFF and drops "
         "by one every 0x3C frames.</p>"),
        ("The demo is not played by a clever machine: it is a recording",
         "<p>Bank 12 holds, per stage, a list of pairs [how many frames][what "
         "the joystick reads]. 0x5CDA walks it and drops the recorded value "
         "into 0xE009, <b>the very byte where 0x5767 leaves what it reads from "
         "the real joystick</b>, with the fire bit forced on. And it starts "
         "fully powered: 0x5CB8 calls the same routine the <code>HYPER</code> "
         "cheat calls.</p>"),
        ("The keyboard cheats are only read while the game is paused",
         "<p>0x44E7 watches the GRAPH key and, with the screen stopped, 0x50C9 "
         "collects letters into 0xE1E8 until RETURN is pressed; then what was "
         "typed is compared against the words at 0x51BF. Typing them while "
         "playing does nothing: <b>the cheat keyboard only exists while the "
         "game is paused</b>.</p>"),
        ("The checkpoint table falls one short: stage 12 reads code",
         "<p>The table at 0x4214 says which distance each stage restarts at if "
         "you had already got that far, and it is read with "
         "<code>HL = 0x4212</code> and TWICE the stage number. It holds "
         "<b>eleven entries</b>: stage 1 takes the one at 0x4214 and stage 11 "
         "the one at 0x4228. Stage 12 reads at 0x422A, which is already code — "
         "the first two bytes of a <code>call</code> — and gets 0xBACD, that is "
         "47,821. Since the scroll never gets anywhere near that distance, "
         "stage 12 always restarts at 0x20: <b>the bug is real and its effect "
         "is nothing</b>.</p>"),
        ("Konami's hidden mark: RC-742 and グラディウス",
         "<p>At the end of bank 3, at offset 0x07FFF of the dump, sit the "
         "cartridge code <b>RC-742</b> and eight katakana characters that read "
         "<b>グラディウス</b>, that is <i>Gradius</i>. It is the signature "
         "Konami hid in its cartridges, and the person who found and documented "
         "it is <b>Manuel Pazos</b>.</p>"),
    ],
}

GALLERY = [
    ("intro.png",
     "La pantalla de presentación, montada como la monta el cartucho: seis "
     "bloques comprimidos del banco 9 a los tres tercios de patrones y de "
     "colores, los caracteres del marco desde el banco 10 y la tabla de "
     "nombres, 768 bytes sin comprimir, del principio del banco 9",
     "The attract screen, built the way the cartridge builds it: six compressed "
     "blocks from bank 9 into the three thirds of patterns and colours, the "
     "frame characters from bank 10, and the name table, 768 uncompressed "
     "bytes, from the start of bank 9"),
    ("title.png",
     "La pantalla del título, la otra: build_title_screen (0x5B31) "
     "descomprime sus patrones de 0x9C57 y sus colores de 0x9EAB en los tres "
     "tercios, y encima write_title_panel (0x5B77) pone el panel del "
     "logotipo, cinco filas de 28 caracteres desde la casilla 0x3882",
     "The title screen proper, which is a different one: monta_la_pantalla_del_"
     "titulo (0x5B31) decompresses its patterns from 0x9C57 and its colours "
     "from 0x9EAB into the three thirds, and on top of that escribe_el_panel_"
     "del_titulo (0x5B77) writes the logo panel, five rows of 28 characters "
     "from cell 0x3882"),
    ("logo_gradius.png",
     "EL MISMO BINARIO LLEVA LOS DOS NOMBRES. Este es el otro panel, el de "
     "0x9BCB, dibujado igual que el de la cabecera. El cartucho lee el juego de "
     "caracteres de la máquina en 0x002B de la BIOS y, con el nibble bajo a "
     "cero -máquina japonesa-, escribe éste; con cualquier otra cosa, el de "
     "0x9B3F, que pone NEMESIS. No son dos versiones del cartucho: los dos "
     "paneles están pegados el uno al otro en el banco 9",
     "THE SAME BINARY CARRIES BOTH NAMES. This is the other panel, the one at "
     "0x9BCB, drawn just like the one in the header. The cartridge reads the "
     "machine's character set from 0x002B of the BIOS and, with the low nibble "
     "at zero -a Japanese machine-, writes this one; with anything else, the "
     "one at 0x9B3F, which reads NEMESIS. These are not two versions of the "
     "cartridge: the two panels sit right next to each other in bank 9"),
    ("stage01_map.png",
     "Fase 1 entera. Los primeros 0x80 pasos son cielo -una estrella por "
     "columna, en la fila que diga la tabla de 0x478E- y a partir de ahí manda "
     "el guión: el suelo con volcanos y vegetación, y el techo",
     "The whole of stage 1. The first 0x80 steps are sky -one star per column, "
     "on the row the table at 0x478E gives- and from there the script takes "
     "over: the ground with volcanoes and vegetation, and the ceiling"),
    ("stage02_map.png",
     "Fase 2: estalactitas y estalagmitas, y al final las construcciones de "
     "piedra. Todo sale del mismo juego de piezas de 0x8000 del banco 11",
     "Stage 2: stalactites and stalagmites, and the stone structures at the "
     "end. All of it comes from the same set of pieces at 0x8000 of bank 11"),
    ("stage03_map.png",
     "Fase 3. Aquí no hay terreno ninguno: su tramo de guión es 0xFFFF, o sea "
     "que 0x46AE manda SIEMPRE a la rutina de estrellas y la fase entera es "
     "cielo. Lo mismo pasa con la sexta",
     "Stage 3. There is no terrain at all here: its script range is 0xFFFF, so "
     "0x46AE always goes to the star routine and the whole stage is sky. The "
     "same happens with the sixth"),
    ("stage04_map.png",
     "Fase 4, la de los cristales",
     "Stage 4, the crystal one"),
    ("stage05_map.png",
     "Fase 5. Es la única con motor de fondo propio -0xB2AA, en el banco 3- y "
     "usa el otro juego de piezas, el de 0x8FF0. Casi todo lo que se mueve en "
     "ella no está en el mapa: son rectángulos de caracteres que se borran y se "
     "vuelven a pintar cada cuadro",
     "Stage 5. It is the only one with its own background engine -0xB2AA, in "
     "bank 3- and it uses the other set of pieces, the one at 0x8FF0. Most of "
     "what moves in it is not in the map at all: they are rectangles of "
     "characters erased and repainted every frame"),
    ("stage06_map.png",
     "Fase 6. La otra fase de puro cielo, como la tercera",
     "Stage 6. The other pure-sky stage, like the third one"),
    ("stage07_map.png",
     "Fase 7, la única que lleva las apariciones escritas una a una: cuarenta y "
     "tres palabras en 0xAF3F, cada una con nueve bits de distancia, cinco de "
     "fila y dos de variante",
     "Stage 7, the only one with its spawns written out one by one: forty-three "
     "words at 0xAF3F, each with nine bits of distance, five of row and two of "
     "variant"),
    ("stage08_map.png",
     "Fase 8, la del laberinto de celdas",
     "Stage 8, the cell maze one"),
    ("stage09_map.png",
     "Fase 9, la primera de las cuatro de BONUS: se entra tocando el blanco al final de la segunda, y al acabar se sale a la tercera",
     "Stage 9, the first of the four BONUS stages: you get in by touching the target at the end of stage 2, and it drops you into stage 3"),
    ("stage10_map.png",
     "Fase 10, de BONUS: se entra desde la tercera y se sale a la cuarta",
     "Stage 10, a BONUS stage: entered from stage 3 and leaving into stage 4"),
    ("stage11_map.png",
     "Fase 11, de BONUS: se entra desde la cuarta y se sale a la quinta",
     "Stage 11, a BONUS stage: entered from stage 4 and leaving into stage 5"),
    ("stage12_map.png",
     "Fase 12, de BONUS: se entra desde la septima y se sale a la octava, que es la ultima",
     "Stage 12, a BONUS stage: entered from stage 7 and leaving into stage 8, the last one"),
    ("stage01_characters.png",
     "Los 256 caracteres de cada uno de los tres tercios con los que se dibuja "
     "la primera fase, tal como los deja el cargador de 0x42FC. En el tercero "
     "se leen los rótulos del medidor de mejoras: <code>SPEED UP</code>, "
     "<code>MISSILE</code>, <code>DOUBLE</code>, <code>LASER</code> y "
     "<code>OPTION</code>",
     "The 256 characters of each of the three thirds stage one is drawn with, "
     "just as the loader at 0x42FC leaves them. In the third one you can read "
     "the power-up meter labels: <code>SPEED UP</code>, <code>MISSILE</code>, "
     "<code>DOUBLE</code>, <code>LASER</code> and <code>OPTION</code>"),
    ("ending_characters.png",
     "Y los del final de la partida, que salen del banco 10. La tabla de nombres "
     "de esa pantalla casi no se usa: lo unico que se escribe encima es el "
     "dibujo de cuatro por cuatro del flujo de 0x4FB2",
     "And the ones for the end of the game, which come from bank 10. The name "
     "table of that screen is almost unused: the only thing written over it is "
     "the four-by-four drawing from the stream at 0x4FB2"),
    ("sprites.png",
     "Los patrones de sprite de 16x16 descomprimidos en la VRAM 0x1800. Los "
     "tres primeros son la nave con sus tres inclinaciones; detrás van las "
     "opciones, los disparos, las explosiones y los bichos",
     "The 16x16 sprite patterns decompressed into VRAM 0x1800. The first three "
     "are the ship with its three tilts; behind them come the options, the "
     "shots, the explosions and the enemies"),
]


def img64(path):
    with open(path, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()


def main(argv):
    if len(argv) < 4:
        print(__doc__)
        return 2
    imgdir, output, lang = argv[1:4]
    t = TXT[lang]

    # The header "logo" is not a montage or a capture: it is the 28x5 panel
    # that the cartridge itself writes on row 4 of its title screen (0x9B3F,
    # bank 9), drawn from the ROM by graphics.py. If the PNG is not there, it
    # falls back to text.
    logo_path = os.path.join(imgdir, "logo.png")
    header = (f'<img src="{img64(logo_path)}" alt="Nemesis">'
              if os.path.exists(logo_path)
              else "<h1>Nemesis <span style='opacity:.55'>/ Gradius</span></h1>")

    nav = "".join(f'<a href="{h}">{x}</a>' for h, x in t["nav"])
    nav += "".join(f'<a href="{h}">{x}</a>' for h, x in t["docnav"])
    nav += (f'<a href="{t["other"][0]}" style="margin-left:auto;color:var(--gold)">'
            f'{t["other"][1]}</a>')

    stats = "".join(f'<div class="stat"><b>{v}</b><span>{e}</span></div>'
                    for v, e in t["stats"])
    findings = "".join(f'<div class="finding"><h3>{title}</h3>{body}</div>'
                       for title, body in FINDINGS[lang])
    imgs = ""
    missing = []
    for fname, es, en in GALLERY:
        path = os.path.join(imgdir, fname)
        if not os.path.exists(path):
            missing.append(fname)
            continue
        caption = es if lang == "es" else en
        imgs += (f'<figure><img src="{img64(path)}" alt="{caption}">'
                 f'<figcaption>{caption}</figcaption></figure>')
    if missing:
        print("  (%d images missing: %s)" % (len(missing), " ".join(missing)))

    html = f"""<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{t['title']}</title>
<style>{STYLE}</style>
<header class="top">
  {header}
  <p class="claim">{t['claim']}</p>
  <p class="facts">{' · '.join(t['facts'])}</p>
</header>
<p class="facts" style="border:1px solid var(--gold);padding:.8em 1em;margin:1.5em 0">
{t['notice']}</p>
<nav>{nav}</nav>
<section id="numbers">
  <h2>{t['h_num']}</h2>
  <div class="stats">{stats}</div>
</section>
<section id="findings"><h2>{t['h_find']}</h2>{findings}</section>
<section id="screens">
  <h2>{t['h_scr']}</h2>
  <p class="n">{t['note_scr']}</p>
  <div class="gallery">{imgs}</div>
</section>
<footer><p>{t['legal']}</p></footer>
"""
    with open(output, "w", encoding="utf-8") as f:
        f.write(html)
    print("  %s: %d KB (%s)" % (output, len(html) // 1024, lang))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

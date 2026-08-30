# En el emulador

Algunas de las cosas escritas en este listado no se pueden zanjar leyendo. Esta
página es lo que se comprobó con el cartucho corriendo de verdad, y cómo.

## Qué se midió, y qué salió

**Las claves de teclado.** `tools/omsx_claves.tcl` arranca el cartucho, empieza
una partida, pulsa GRAPH para pausar, escribe la palabra letra a letra, pulsa
RETURN y apunta los bytes de la ficha de la nave antes y después. Con `OPTION`,
0xE1E8 se llena con `4F 50 54 49 4F 4E` y 0xE20B pasa de 00 a 02. Con `BAKA`,
las naves de 0xE060 pasan de 02 a 00 y el aviso de 0xE05F se apaga.

El primer intento falló, y el fallo fue el hallazgo: escribir la palabra
jugando no hace absolutamente nada. El código solo lee el teclado **con el juego
en pausa**, así que el script tuvo que pulsar GRAPH primero.

**Los mapas.** Los doce mapas de la portada están dibujados desde la ROM, no
capturados, pero se comprobaron contra lo real. Un script deja correr la demo,
vuelca los 704 bytes del mapa de 0xED00 junto con la distancia de 0xE063, y las
mismas columnas se generan en Python. De 704 casillas, **6 se salían a distancia
138 y 9 a distancia 201**. Son las estrellas, que el cartucho elige con el
registro R, y los caracteres que el disparo escribe encima del mapa.

**La pantalla de presentación.** Se volcó la VRAM entera del emulador y se
comparó, byte a byte, con la que fabrica la herramienta desde los bloques
comprimidos. Coinciden en toda la zona del dibujo; los únicos bytes que se salen
son los de los caracteres 0xC0 a 0xFF, que el juego reescribe, y la tabla de
atributos de sprite.

Esa comparación es la que cazó un fallo: una máscara de 0x17FF donde tenía que
ser 0x1FFF, que borraba sin hacer ruido el bit 0x800 y dibujaba el **tercio de
en medio** de cada pantalla con los caracteres del primero.

## Las trampas, ya pagadas

* Con `-script`, openMSX arranca con el renderer en *uninitialized* y
  `screenshot` escribe un PNG negro devolviendo éxito. Hay que encenderlo a
  mano: `set renderer SDLGL-PP`.
* Las capturas se piden con el acelerador **puesto** y después de `after
  realtime`, o salen de un cuadro que no se llegó a dibujar.
* `type` va demasiado rápido. El cartucho solo se entera de una tecla cuando
  **cambia**, así que las claves se escriben letra a letra por la matriz.
* Las rutas de salida son rutas de Windows. openMSX escribe donde se le dice, no
  donde cree la shell.

## Cómo lanzar uno

    NEM_OUT=<directorio> NEM_CLAVE=option openmsx -machine Philips_VG_8020 \\
        -carta nemesis.rom -script tools/omsx_claves.tcl

El script escribe su propio registro al lado de las capturas, con el tiempo
emulado en cada línea, para que una tirada que salga mal se pueda leer después
en vez de adivinarla.

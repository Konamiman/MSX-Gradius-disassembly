# Nemesis / Gradius (Konami, 1986, MSX1) — desensamblado

Desensamblado reproducible, byte a byte, del cartucho MegaROM de 128 KB
**Nemesis / Gradius**, Konami RC-742 (1986), para MSX1.

Los fuentes están partidos en módulos lógicos que se ensamblan uno a uno con
[Nestor80](https://github.com/Konamiman/Nestor80) y se enlazan cada uno en su
sitio, y **construirlos devuelve la ROM original byte a byte**: los dieciséis
bancos de 8 KB y la imagen entera de 131.072 bytes. Esa es la prueba que decide
si un desensamblado es fiable; todo lo demás que hay en este repositorio está
para que además los fuentes no *mientan* sobre lo que ensamblan.

*(In English: [README.md](README.md).)*

## Por dónde va

| | |
|---|---|
| ROM | 131.072 bytes, sha256 `3210f8a0f2309dd4b9a89fc2b24d0f178ce4393a0a1f2854fbce545c361261bc` |
| reensambla byte a byte | sí, los 16 bancos y la imagen entera |
| bytes explicados | **131.072 de 131.072 (100,00 %)** |
| código trazado | 25.474 bytes |
| datos identificados | 105.598 bytes |
| sin explicar | 0 bytes |
| módulos | 72 |
| líneas de fuente | 23.203 |
| rutinas con nombre | 910 |
| comentarios de línea | 2.984 |
| rangos de datos con explicación | 232 |

**El 23,0 % de las instrucciones lleva comentario de línea** — 2.983 de 12.959
en las tres imágenes con código — y sólo **4 de las 1.535 rutinas están por
debajo del 10 %**, todas ellas bucles cortos alrededor de una llamada a la BIOS.
`make density` lo imprime imagen a imagen, y `tests/test_sources.py` guarda,
banco a banco, cuántas rutinas llamadas siguen sin nombre, de modo que la cifra
sólo puede bajar.

La web de [docs/](docs/) sale de la ROM que construyen los fuentes, y sus doce
mapas de fase están dibujados desde ella por `tools/graphics.py`: aquí no hay ni
una captura de emulador.

## El cartucho

128 KB con el **mapper de Konami SIN SCC** (Konami4): dieciséis bancos de 8 KB.
Para 0x4000-0x5FFF no hay registro —el banco 0 está fijo ahí— y las otras tres
ventanas se eligen escribiendo el número de banco en 0x6000, 0x8000 y 0xA000.
`tools/recon.py` lo mide sobre los bytes: ni una escritura a 0x5000,
0x7000, 0x9000 ni 0xB000 (los registros del mapper con SCC), y las 68
escrituras a los registros del Konami4 llevan todas un banco que cumple la
regla.

| banco | se ejecuta en | qué lleva |
|---|---|---|
| 0 | 0x4000 (fijo) | cabecera, INIT, interrupción, despachador, mapper, máquina de estados |
| 1, 2, 3 | 0x6000 / 0x8000 / 0xA000 | el código del juego |
| 4, 5 | 0x6000 / 0x8000 | gráficos de fase comprimidos, y las fichas de seis bytes que los cargan |
| 6, 13, 14, 15 | — | 8.192 bytes de 0xFF cada uno |
| 7, 8 | 0x8000 / 0xA000 | reproductor de sonido y sus datos |
| 9, 10 | 0x8000 / 0xA000 | pantallas fijas y más gráficos |
| 11, 12 | 0x8000 / 0xA000 | el mapa: piezas de 4x4 caracteres y los guiones de cada fase |

## Tres cosas que dice el binario

**Hay una instrucción partida entre dos bancos.** En 0x7FFE (banco 1) hay dos
bytes, `21 41`, y el tercero —el `80`— es el *primer byte del banco 2*. Entre
los tres forman `ld hl,0x8041`, y la ejecución sigue en 0x8001. Es el único
sitio del cartucho donde pasa, y suelda el banco 1 al 2. Además el código sigue
de largo por las fronteras 0x5FFF→0x6000 y 0x9FFF→0xA000.

**El formato de los gráficos.** La rutina 0x49B9 descomprime directamente a la
VRAM, y está escrita al revés de lo que uno esperaría: el bit 7 marca la copia
*literal*, no la repetición. `0x00` acaba el bloque, `0x01`-`0x7F` repite N
veces el byte siguiente, `0x80` dice que los dos bytes siguientes son una nueva
dirección de VRAM, y `0x81`-`0xFF` copia N-0x80 bytes tal cual. Está en
`tools/rle.py`, y la prueba de que está bien leído es que los bloques cubren
los bancos de datos sin dejar ni un byte de holgura.

**Nemesis busca otro cartucho de Konami.** La rutina 0x508D lee con RDSLT seis
bytes desde 0xBFFF hacia abajo en las demás ranuras y los compara con
`AA 40 06 91 81 AC`. Eso es la marca oculta de Konami de otro cartucho:
RC-7**40**, un título de seis caracteres, y sus tres primeros caracteres
(guardados al revés) son `ツ イ ン`. Si cuadra, 0xF0F4 pasa a 1 y se cargan
gráficos de más.

## La marca oculta de Konami

Al final del banco 3 (offset 0x07FF5 del fichero) hay once bytes: el título al
revés, cuántos son, las dos últimas cifras del RC en BCD, y 0xAA. Aquí sale
RC-742 y グラディウス, o sea *Gradius*. **El hallazgo no es nuestro: lo destapó
Manuel Pazos (@ManuelPazosMSX), y `tools/konami_mark.py` sólo lee lo que él
enseñó que estaba ahí.** Ojo: en un MegaROM la marca *no* está al final del
fichero, sino que detrás quedan 96 KB de datos.

## Cómo se construye

Los fuentes construyen el cartucho por sí solos: la ROM original no hace falta,
y aquí no se distribuye. Hacen falta `make`, `python3` y Nestor80 (N80 y LK80)
en el PATH:

```sh
make verify      # ensambla y enlaza todo, y comprueba el sha256 del resultado
make             # verify -> sanidad -> tests
```

El resultado queda en `build/nemesis.rom`.

## Cómo están organizados los fuentes

La unidad de construcción es la **imagen**, no el banco de la ROM: los bancos
que el juego pone siempre juntos, que para la CPU son un solo tramo de memoria.
Cada imagen se enlaza en una sola pasada de LK80, así que un módulo puede pasar
de un banco al siguiente: la instrucción partida entre los bancos 1 y 2 se
escribe como la instrucción que es, y los sonidos siguen del banco 7 al 8.

| imagen | bancos | dirección | módulos |
|---|---|---|---|
| `main` | 0-3 | 0x4000-0xBFFF | 57, uno por cada parte del juego |
| `scenery` | 4-6 | 0x6000-0xBFFF | 2 |
| `sound` | 7-8 | 0x8000-0xBFFF | 8 |
| `screens` | 9-10 | 0x8000-0xBFFF | 3 |
| `map` | 11-12 | 0x8000-0xBFFF | 2 |

Los bancos 13, 14 y 15 son 0xFF y no tienen fuente; todo el relleno 0xFF del
cartucho lo pone el enlazador. La imagen principal llama al reproductor de
sonido y al motor de las pantallas fijas: esas imágenes se enlazan antes, y
exportan los símbolos que la principal necesita.

## Para qué es cada comprobación

`make verify` demuestra que los bytes vuelven. Lo demás caza lo que eso no
puede cazar:

- `tools/check_code.py` (`make sanity`) — el reensamblado no distingue código
  de datos: un módulo que escribe gráficos como instrucciones ensambla los
  mismos bytes; lo único que miente es la *lectura*. El trazador de cartucho
  entero (`tools/bank_tracer.py`) sigue el código desde los dos puntos de
  entrada que garantiza el hardware, llevando la cuenta de qué banco hay en cada
  ranura, y las instrucciones de los fuentes tienen que ser **exactamente** las
  que él alcanza. Además comprueba que cada línea de datos está bajo una
  cabecera `; DATA` que la nombra y la explica. **0 bytes sin explicar.**
- `tools/recon.py` — todas las escrituras al mapper cumplen la regla banco →
  org.
- `tests/` — las cifras que se publican, y lo que la web afirma sobre los bytes.

## Cómo está repartido

```
src/<imagen>/*.asm  los módulos, un directorio por imagen
src/inc/            los puntos de entrada de la BIOS y la RAM del reproductor de sonido
src/seeds.txt       los puntos de entrada que el trazador no encuentra solo
tools/              el trazador, las comprobaciones y los generadores de la web
build/              todo lo que produce make (no está en el repositorio)
```

## Legal

Esto es un estudio de un programa publicado en 1986. Ver
[AVISO-LEGAL.md](AVISO-LEGAL.md). Nemesis / Gradius y el nombre de Konami son
de Konami. La ROM no se distribuye aquí.

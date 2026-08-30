# Nemesis / Gradius (Konami, 1986, MSX1) — desensamblado

Desensamblado reproducible, byte a byte, del cartucho MegaROM de 128 KB
**Nemesis / Gradius**, Konami RC-742 (1986), para MSX1.

El listado se genera trazando el flujo de verdad, banco a banco, y
**reensamblarlo devuelve la ROM original byte a byte**: los dieciséis bancos de
8 KB y la imagen entera de 131.072 bytes. Esa es la prueba que decide si un
desensamblado es fiable; todo lo demás que hay en este repositorio está para
que además el listado no *mienta* sobre lo que reensambla.

*(In English: [README.md](README.md).)*

## Por dónde va

| | |
|---|---|
| ROM | 131.072 bytes, sha256 `3210f8a0f2309dd4b9a89fc2b24d0f178ce4393a0a1f2854fbce545c361261bc` |
| reensambla byte a byte | sí, los 16 bancos y la imagen entera |
| bytes explicados | **131.072 de 131.072 (100,00 %)** |
| código trazado | 25.471 bytes |
| datos identificados | 105.601 bytes |
| sin explicar | 0 bytes |
| listado | 26.373 líneas |
| puntos de entrada, cada uno con su justificación | 277 |
| etiquetas con nombre | 916 |
| comentarios anclados | 2.982 |
| rangos de datos con explicación | 242 |

Los comentarios están acabados al listón de la serie: **el 23,3 % de las
instrucciones lleva comentario de línea** — 3.022 de 12.959 en los seis bancos
con código — y **ni una de las 1.540 rutinas está por debajo del 10 %**. `make
densidad` lo imprime banco a banco, y `tests/test_listado.py` guarda, banco a
banco, cuántas rutinas llamadas siguen sin nombre, de modo que la cifra sólo
puede bajar.

La web de [docs/](docs/) sale de esas mismas notas, y sus doce mapas de fase
están dibujados desde la ROM por `tools/graficos.py`: aquí no hay ni una captura
de emulador.

## El cartucho

128 KB con el **mapper de Konami SIN SCC** (Konami4): dieciséis bancos de 8 KB.
Para 0x4000-0x5FFF no hay registro —el banco 0 está fijo ahí— y las otras tres
ventanas se eligen escribiendo el número de banco en 0x6000, 0x8000 y 0xA000.
`tools/reconocimiento.py` lo mide sobre los bytes: ni una escritura a 0x5000,
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
Manuel Pazos (@ManuelPazosMSX), y `tools/marca_konami.py` sólo lee lo que él
enseñó que estaba ahí.** Ojo: en un MegaROM la marca *no* está al final del
fichero, sino que detrás quedan 96 KB de datos.

## Cómo se construye

La ROM **no** se distribuye aquí. Pon la tuya en la raíz como `nemesis.rom`
(131.072 bytes exactos) y:

```sh
make comprueba   # comprueba el sha256
make             # trazado -> listado -> byte a byte -> sanidad -> tests
```

Hacen falta `python3`, `pasmo`, `z80dasm` y `make`.

## Para qué es cada comprobación

`make verify` demuestra que los bytes vuelven. Lo demás caza lo que eso no
puede cazar:

- `tools/check_trace.py` y `tools/check_datos_como_codigo.py` — ningún byte
  declarado como datos puede salir como código. Un listado que lee gráficos
  como instrucciones reensambla igual de bien; lo único que miente es la
  *lectura*.
- `tools/check_bancos.py` — este proyecto tiene **dos** trazadores: uno que
  recorre el cartucho entero siguiendo el mapper y otro que recorre un solo
  banco desde las entradas escritas en `src/pNN.entries`. Los dos tienen que
  marcar exactamente los mismos bytes como código. Si no coinciden, o falta una
  entrada o hay una que lleva a donde no debe.
- `tools/check_entradas.py` — ningún punto de entrada puede caer dentro de un
  rango declarado como datos. El proyecto contradiciéndose a sí mismo.
- `tools/presupuesto.py` — cada byte del cartucho es código trazado o cae en un
  rango de datos con nombre y explicación. **100 %.**

## Cómo está repartido

```
src/pNN.entries   los puntos de entrada, con la instrucción que justifica cada uno
src/pNN.nocode    las tablas del despachador, que van pegadas detrás de su `call`
src/pNN.notes     etiquetas, comentarios y rangos de datos, anclados a dirección
src/nemesis_pNN.asm   el listado generado, uno por banco
tools/            los trazadores, el generador del listado y las comprobaciones
```

## Legal

Esto es un estudio de un programa publicado en 1986. Ver
[AVISO-LEGAL.md](AVISO-LEGAL.md). Nemesis / Gradius y el nombre de Konami son
de Konami. La ROM no se distribuye aquí.

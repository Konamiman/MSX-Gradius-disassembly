# El cartucho

**RC-742**, 128 KB, dieciséis bancos de 8 KB, con el mapper de Konami **sin
SCC** (Konami4). `tools/recon.py` lo mide sobre los bytes en vez de
darlo por supuesto: no hay ni una escritura a 0x5000, 0x7000, 0x9000 ni 0xB000,
que son los registros del otro mapper de Konami, el que lleva SCC.

## Cómo se reparten los bancos

Para 0x4000-0x5FFF no hay registro: el banco 0 está clavado ahí. Las otras tres
ventanas toman el número de banco que se escriba en 0x6000, 0x8000 y 0xA000, y
el cartucho guarda una copia del reparto de ahora en 0xF0F1..0xF0F3 para que una
interrupción pueda devolverlo.

| ventana | bancos que van ahí |
|---|---|
| 0x4000 | 0 (fijo) |
| 0x6000 | 1, 4 |
| 0x8000 | 2, 5, 7, 9, 11 |
| 0xA000 | 3, 6, 8, 10, 12 |

Cada banco tiene exactamente una dirección en la que se ejecuta, y por eso el
listado se puede partir en dieciséis ficheros con dieciséis org.

## Qué hay en cada banco

| banco | código | qué lleva |
|---|---|---|
| 0 | 3.158 instr. | el bucle, el scroll, los sprites, el VDP, los modos |
| 1 | 3.231 instr. | los motores de los bichos, los choques, el jefe |
| 2 | 2.849 instr. | la nave, los jefes, las tablas de puntería |
| 3 | 3.074 instr. | el medidor, el láser, veinte de los tipos de bicho |
| 4, 5, 6 | — | los gráficos de las fases, comprimidos |
| 7 | 420 instr. | el reproductor de sonido |
| 8 | — | las músicas y los efectos |
| 9, 10 | 227 instr. | las pantallas fijas, y un motorcillo de sprites propio |
| 11, 12 | — | las piezas del mapa y los guiones de las fases |
| 13, 14, 15 | — | 0xFF de punta a punta |

Solo **seis de los dieciséis bancos llevan código**.

## Cuánto del chip está vacío

48.219 bytes — 47,1 KB, el **36,8 % del cartucho** — están declarados como
relleno de 0xFF. Cuatro bancos son relleno enteros: el 6, el 13, el 14 y el 15.
Los demás acaban en una cola: 7.202 bytes en el banco 8, 4.311 en el 10, 2.487
en el 12 y 1.052 en el 5. El raro es un hueco de **399 bytes dentro del banco
3**, entre el último dato y los once bytes de la marca escondida de Konami; los
otros 47.820 son colas.

El banco 6 es el raro: la rutina que reparte 4/5/6 para los gráficos sí lo mete
en 0xA000, o sea que se mapea de verdad; lo que pasa es que no hay nada dentro
que leer.

## El mapa de la VRAM va del revés

Los ocho bytes de 0x575A van a los registros 0 a 7 del VDP: 0x02, 0xE2, 0x0E,
0x7F, 0x07, 0x76, 0x03, 0xE4. Y no dejan nada donde lo deja la BIOS.

| tabla | dónde la pone la BIOS | dónde la pone este cartucho |
|---|---|---|
| patrones | 0x0000 | **0x2000** |
| colores | 0x2000 | **0x0000** |
| nombres | 0x1800 | **0x3800** |
| atributos de sprite | 0x1B00 | **0x3B00** |
| patrones de sprite | 0x3800 | **0x1800** |

La tabla de nombres acaba en 0x3AFF y los atributos de sprite empiezan en
0x3B00, pegados detrás.

## Cómo se guardan los gráficos

Todo lo que el cartucho dibuja pasa por un descompresor pequeño en 0x49B9, y su
formato está escrito del revés de lo que uno esperaría: el bit 7 marca la
**copia literal**, no la repetición.

| mando | qué hace |
|---|---|
| `0x00` | acaba el bloque |
| `0x01`..`0x7F` | el byte siguiente, N veces |
| `0x80` | los dos bytes siguientes son la nueva dirección de VRAM |
| `0x81`..`0xFF` | N-0x80 bytes copiados tal cual |

Con eso el tamaño de un bloque no se estima: se cuenta. Es lo que permite
declarar cada rango de gráficos con una directiva `D` sin dejarse un byte ni
comerse el siguiente. `tools/rle.py` mide cualquiera de ellos.

Los caracteres de cada fase se cargan con fichas de seis bytes: en qué tercios
va, dónde está el flujo de patrones, en qué carácter empieza y dónde está el de
colores. Y después, otras dos listas hacen **espejos** de parte de lo recién
cargado — por bits para el horizontal, por bytes para el vertical —, así que la
mitad de los caracteres del terreno están hechos con la otra mitad en vez de
guardados dos veces.

## La marca escondida

Al final del banco 3, en el offset 0x07FFF del volcado, están el código de
cartucho **RC-742** y ocho caracteres en katakana que se leen **グラディウス**,
*Gradius*. Es la firma que Konami escondía en sus cartuchos, y quien la
descubrió y la documentó fue **Manuel Pazos**. `make mark` la vuelve a leer de
la ROM.

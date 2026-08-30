# El código

## El cuadro

El trabajo lo hace el gancho de la interrupción. En cada cuadro mete los bancos
del sonido, llama al reproductor, le da sus pasos al scroll, corre los objetos y
saca el buffer de sprites. Al bucle principal solo le queda la máquina de modos:
título, demo, partida, pantalla de fase, fin de partida.

## El mapa está en la RAM

Las veintidós filas de treinta y dos casillas viven en **0xED00**, no en la
VRAM. En cada paso de scroll:

1. 0x469D lo corre entero una columna a la izquierda con veintidós `ldir` de
   0x1F bytes.
2. 0x46AE saca qué columna entra por la derecha y 0x46E1 la escribe.
3. 0x47FE sube los 704 bytes a la tabla de nombres con `outi`, sin pasar por la
   BIOS.

La columna que entra sale del guión de la fase: la distancia recorrida menos el
principio del tramo, partida por cuatro, indexa renglones de **seis números de
pieza**, y cada pieza son cuatro por cuatro caracteres. Cinco piezas dan veinte
filas y la sexta da las dos últimas. Fuera del tramo, la columna es cielo: una
estrella, en la fila que diga la tabla de 0x478E.

Hay dos juegos de piezas: el de 0x8000 del banco 11 y el de 0x8FF0. Las fases 5,
9, 10 y 12 usan el segundo.

## Los objetos

Doce ranuras de 32 bytes en 0xE300, más ocho de 0x20 contadas hacia atrás en
0xE460 para los disparos con puntería, diez en 0xE500, cinco en 0xEB00 y ocho de
8 bytes en 0xE700 para el fondo. Dentro de una ranura:

| byte | qué es |
|---|---|
| 0 | el tipo, del 1 al 0x1F; a cero, la ranura está libre |
| 1 | por qué paso de su propia máquina va |
| 3, 4 | la fila, con su parte decimal |
| 5, 6 | la columna, con su parte decimal |
| 7, 8 | la velocidad vertical |
| 9, 10 | la velocidad horizontal |
| 11 | se dibuja con caracteres en vez de con un sprite |
| 12, 13 | el dibujo y su color |
| 0x17..0x1A | las dos aceleraciones |
| 0x1B | banderas: si se le puede disparar, si se dibuja |

`saca_un_objeto` (0x6A72) es la rutina más llamada del banco 1: se le entra con
el tipo, dónde va y un byte de ajuste, y ella busca ranura libre, la rellena con
la ficha de cuatro bytes de 0x6BA3 y sube la cuenta de vivos. Tres tipos se
salen de lo normal: el 0x1E necesita **tres ranuras seguidas**, el 0x0E va a la
otra tabla, y los demás a la de 0xE300.

Y después el tipo manda en dos tablas gemelas: **p00:0x5DFD** dice quién lo
mueve y **p01:0x6B46** quién acaba de montarlo. Veinte de los treinta y un tipos
tienen en el banco 3 al menos una de las dos, y dieciséis las dos; por eso
0xA7B9..0xB537 es el trozo de código más largo del cartucho.

El byte de ajuste es la **marca** del bicho. Los dieciséis bytes de 0xA5C7 se
leen en redondo: tres de cada cuatro salen con la marca a cero, uno de cada
cuatro con un 1 y uno de cada dieciséis con un 2. Un bicho marcado se pinta del
color 8, el rojo, y deja algo distinto al morir.

## Cómo se mueven los bichos

Cada tipo es una maquinita propia, y ninguno usa trigonometría. Algunas formas:

* **El tipo 4** inclina su dibujo hacia donde vuela. Tres dibujos — 0xB0 de
  frente, 0xB4 hacia arriba y 0xB8 hacia abajo — elegidos en el mismo sitio que
  la velocidad, así que dibujo y rumbo nunca se contradicen.
* **El tipo 2** no cruza la pantalla: se da la vuelta en la columna 0x81, se
  para en la 0x9F, vuelve a tirar hasta la 0x51 y, cuando por fin se pone a la
  altura de la nave, se va de frente. Cuatro pasos contados en el byte 1.
* **El tipo 5** anda por el terreno. No lleva ningún mapa de alturas: le
  pregunta al mapa qué hay ocho puntos por debajo de sus pies y sube o baja
  ocho hasta encajar.
* **El tipo 0x0C** lleva el recorrido escrito: nueve pasos, cada uno esperando a
  que la columna llegue a un número. El bit 7 del byte 1 es un espejo, así que
  los que entran por la mitad de abajo hacen el mismo recorrido del revés.
* **El tipo 0x1D** se cierra en espiral sin tabla de senos: un octavo de la
  diferencia hasta el centro sumado a la otra coordenada, y un radio que se
  encoge multiplicando.
* **El tipo 0x1E** ocupa tres ranuras y, al acabársele la cuenta, se convierte
  en tres del tipo 0x1F que salen despedidos.

## El sonido

El banco 7 es el reproductor y el 8 los datos; la interrupción mete los dos y
llama a 0x8063. Tres canales, cada uno una ficha de 0x11 bytes en 0xE010, 0xE021
y 0xE032, cada una recorriendo su propio flujo de mandos. Todo llega al PSG por
la BIOS, con WRTPSG. La tabla de 0x8328 tiene ochenta punteros, uno por sonido;
la entrada 0 no es una dirección, así que el sonido 0 no existe, y las tres
últimas apuntan al primer byte de relleno del banco 8, o sea al silencio.

## La prioridad de sprites va rotando a propósito

El MSX dibuja cuatro sprites por línea y tira el resto, siempre los últimos de
la tabla. Por eso 0x47CE no sube el buffer de un tirón: lo sube en **treinta y
dos trozos de cuatro bytes**, empezando cada cuadro por un sitio distinto —
0xE17F sube 0x1C y da la vuelta en 0x7C — y avanzando de 0x0C en 0x0C. Así cada
objeto cae en una casilla distinta de la tabla de atributos en cada cuadro, y el
parpadeo se reparte entre todos.

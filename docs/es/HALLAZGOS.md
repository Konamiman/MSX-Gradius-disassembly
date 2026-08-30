# Hallazgos

Todo lo de esta página está medido sobre los bytes o en el emulador. Donde se
midió en openMSX, lo pone.

## El mapa de la VRAM va del revés

Los ocho bytes de 0x575A programan los registros 0 a 7 del VDP y no dejan nada
donde lo deja la BIOS: **patrones en 0x2000**, **colores en 0x0000**, nombres en
0x3800 y atributos de sprite en 0x3B00, pegados detrás de la tabla de nombres.
Los patrones de sprite acaban en 0x1800.

No es una curiosidad. Quien lea las direcciones de este listado esperando el
reparto de siempre se equivocará en todas — y se equivocó la primera versión de
la herramienta que dibuja las imágenes de esta web, que es como se cazó.

## El mapa está en la RAM, y se corre a mano

Veintidós filas de treinta y dos casillas en 0xED00. En cada paso de scroll se
corre entero una columna a la izquierda con veintidós `ldir`, se escribe la
columna nueva por la derecha, y los 704 bytes salen a la VRAM con `outi`. El
guión de la fase da seis números de pieza por cada cuatro columnas; cada pieza
son cuatro por cuatro caracteres, cinco dan veinte filas y la sexta las dos
últimas.

Con eso se puede rehacer cualquier fase sin emulador, que es lo que son los
mapas de la portada. Comprobado contra el cartucho corriendo en openMSX: de las
704 casillas del mapa en RAM, **6 se salían a distancia 138 y 9 a distancia
201**, y son las estrellas que parpadean y los caracteres que el disparo escribe
encima del mapa.

## Todo el azar es el registro R del Z80

En los 128 KB no hay ni una semilla ni un generador. Lo que hace de azar es
`ld a,r`, el registro de refresco, que va contando solo con cada instrucción que
se ejecuta:

* cuál de los dos dibujos de estrella va en cada columna de cielo (0x4750),
* por cuál de las dieciséis puertas cae cada piedra de la lluvia (0xABC2),
* cuántos cuadros dura cada dibujo del bicho que parpadea, 0x0F o 3 (0xB016), y
  0x0A o 3 en otro (0xBDBE), de modo que dos en pantalla nunca van a la vez,
* cuánto anda el bicho que camina por el suelo antes de plantarse, entre 0x2D y
  0x4C cuadros (0xAAE6),
* y cuál de la pareja de bichos sale marcado (0xA453).

## Cada bicho es un número y dos rutinas

Un objeto se resume en su tipo, del 1 al 0x1F. Ese número manda en dos tablas
gemelas — p00:0x5DFD para quién lo mueve y p01:0x6B46 para quién acaba de
montarlo — y veinte de los treinta y un tipos tienen en el banco 3 al menos una
de las dos, dieciséis de ellos las dos.

## La espiral se hace sin senos

El tipo 0x1D se cierra en espiral alrededor de un centro, y para eso no hay
tabla de senos: se toma la diferencia hasta el centro en una dirección, se parte
por ocho con tres `sra a` y se le suma a la otra; y con la otra, al revés. Eso
es un giro de unos siete grados por paso. El radio se encoge aparte,
multiplicando las dos coordenadas por un byte que empieza en 0xFF y baja de uno
en uno cada 0x3C cuadros, así que la vuelta se cierra sola.

El bit 0 del byte 30 elige el sentido, y los dos trozos de la rutina son el
mismo código con los signos cambiados.

## Un bicho de tres ranuras, montado con un LDIR que se pisa a sí mismo

El tipo 0x1E no cabe en una ranura: ocupa **tres seguidas**, y por eso el
buscador de ranuras tiene un camino aparte que busca tres en fila. Las otras dos
se montan con un solo `ldir` de 0x40 bytes de la ranura sobre sí misma corrida
0x20 — copiando la primera sobre la segunda y la segunda sobre la tercera en una
instrucción — y luego se colocan en triángulo. Solo la primera se mueve; las
otras dos van detrás. Al acabársele la cuenta, las tres pasan a ser del tipo
0x1F y salen despedidas.

## El abanico de tres disparos con puntería

Un bicho no dispara uno: dispara tres. Se mide el ángulo hasta la nave, se coge
su nibble alto — dieciséis direcciones — y salen tres disparos con ese número,
con el de al lado y con el de antes. Las dos velocidades de cada dirección están
hechas de antemano en la tabla de 0xB26A, cuatro bytes por dirección.

## La fase 7 lleva sus apariciones escritas una a una, en palabras apretadas

Las demás fases sueltan bichos por rachas. La séptima los tiene escritos:
cuarenta y tres apariciones en ochenta y seis bytes, en 0xAF3F. Cada una es una
sola palabra: el byte bajo y el bit 0 del alto son una distancia de nueve bits,
los bits 1 y 2 son la variante, y los cinco de arriba, la fila.

## Las fases no van en orden, y cuatro de ellas son de bonus

De una fase se sale por dos sitios. `acaba_la_fase` (0x6D53) le suma uno a
0xE061; `salta_a_la_fase` (0x6FB9) le mete un número escrito a mano, y **a ese
saltan ocho sitios, cada uno con el suyo**. Juntándolos sale el recorrido de
verdad:

    1 - 2 - 9 - 3 - 10 - 4 - 11 - 5 - 6 - 7 - 12 - 8 - final - 1

Las fases 9 a 12 son **de bonus**, metidas entre las otras: no llevan jefe, y su
final son seis instrucciones que devuelven la fase a la 3, la 4, la 5 y la 8,
que son justo los cuatro bytes de la tabla de 0x418F.

Lo que las abre es el **blanco**. Los finales de las fases 2, 3, 4 y 7 miran
0xE1C0, y la única instrucción de los 128 KB que pone ese byte distinto de cero
es 0xB130, dentro de `cierra_el_tramo`, que corre cuando la nave toca el blanco
del final de la fase. Tocarlo te lleva a la de bonus; no tocarlo sigue el guion
normal. La fase 1 también tiene blanco, y no lleva a ninguna.

## Las fases 3 y 6 no tienen terreno

Su tramo de guión es 0xFFFF, así que la comprobación que decide si el guión
manda falla siempre y el montador de columnas cae en la rutina de estrellas. La
fase entera es cielo.

## La tabla de puntos de control tiene once entradas, y la fase 12 se sale

La tabla de 0x4214 guarda la distancia a la que cada fase vuelve a arrancar si
ya habías llegado hasta ahí. Se lee con `HL = 0x4212` y dos veces el número de
fase, así que la fase 1 coge la palabra de 0x4214 y la 11 la de 0x4228 — y **la
fase 12 lee en 0x422A, que ya es código**: los dos primeros bytes del
`call 0x58BA` con el que empieza la rutina siguiente.

Lo que sale es 0xBACD, o sea 47.821, una distancia a la que el scroll no llega
ni de lejos, así que la comparación falla siempre y la fase 12 arranca en 0x20 y
ya está. El fallo es real y su efecto es ninguno.

## Las claves de teclado solo existen con el juego en pausa

0x44E7 mira la tecla GRAPH y, con la pantalla parada, 0x50C9 va guardando letras
en 0xE1E8 hasta RETURN. Escribirlas jugando no hace nada. Medido en openMSX con
`tools/omsx_claves.tcl`: en pausa, 0xE1E8 se llena con `4F 50 54 49 4F 4E` y al
pulsar RETURN 0xE20B pasa de 00 a 02.

Además de las siete palabras de siempre hay doce más, una por fase, todas
nombres de mujer, y `BAKA` y `AHO` — *tonto* e *idiota* —, que ponen las naves a
cero.

## La demo es una grabación del mando

En el banco 12 hay, por fase, una lista de parejas [cuántos cuadros][qué vale el
mando]. El valor grabado se mete en la misma casilla donde se lee el joystick de
verdad, con el bit del disparo forzado, y la partida arranca con todo puesto
llamando a la misma rutina que la clave `HYPER`.

## La prioridad de sprites va rotando para repartir el parpadeo

El MSX tira los últimos sprites de la tabla cuando caen más de cuatro en una
línea. Por eso el buffer se sube en treinta y dos trozos de cuatro bytes,
empezando cada cuadro por un sitio distinto, y así ningún objeto es siempre el
que desaparece.

## Al morir el jefe, la pantalla se come, no se borra

Bajan trozos de 0x200 bytes de la VRAM, se les hace un AND con una máscara y
vuelven a subir. Primero una pasada por la tabla de colores con 0xF0, y después
ocho pasadas por la de patrones con 0xFE, 0xFC, 0xF8... hasta 0x00, girando
además la máscara tres bits por byte para que el negro entre desmigado y no por
filas.

## En la fase 5 el fondo son caracteres, no sprites

La quinta fase es la única con motor de fondo propio. Sus objetos no llevan
ficha de sprite: son rectángulos de caracteres escritos en el mapa. Dos rutinas
gemelas se llaman con un cuadro de por medio — primero se borran, y después, ya
movidos, se vuelven a pintar — y la torreta que asoma se dibuja a medias
mientras sale, con solo tantas filas como lleve fuera.

## La marca escondida de Konami

Al final del banco 3, en el offset 0x07FFF del volcado: **RC-742** y ocho
katakana que se leen **グラディウス**, *Gradius*. La firma que Konami escondía
en sus cartuchos, descubierta y documentada por **Manuel Pazos**.

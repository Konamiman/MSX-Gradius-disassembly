# El juego

El Gradius de Konami, publicado para MSX1 en 1986 y llamado **Nemesis** fuera de
Japón. Un matamarcianos de scroll horizontal: doce fases, un medidor de mejoras
que se llena recogiendo cápsulas, y opciones que van detrás de la nave copiando
su recorrido.

## Qué nombre enseña

Los dos. El logotipo se elige al arrancar: el cartucho le pregunta a la BIOS de
qué país es la máquina y pone el título japonés o el occidental. El cartucho en
sí solo sabe un nombre: la marca escondida al final del banco 3 pone
グラディウス, *Gradius*.

## Las doce fases, y las cuatro que son de bonus

El número de fase vive en 0xE061, y **no** se sube sin más. De una fase se sale
por dos sitios: `acaba_la_fase` (0x6D53), que suma uno, y `salta_a_la_fase`
(0x6FB9), que le mete un número escrito a mano. A este segundo saltan ocho
sitios, cada uno con el suyo, y de ahí sale el recorrido de verdad:

    1 - 2 - 9 - 3 - 10 - 4 - 11 - 5 - 6 - 7 - 12 - 8 - final - 1

**Las fases 9, 10, 11 y 12 son de bonus**, metidas entre las otras. No llevan
jefe: su final son seis instrucciones que devuelven la fase a la 3, la 4, la 5 y
la 8, que son los cuatro bytes de la tabla de 0x418F.

Y lo que las abre es el blanco. Los finales de las fases 2, 3, 4 y 7 miran
0xE1C0, y lo único en los 128 KB que pone ese byte distinto de cero es 0xB130,
que corre cuando la nave toca el blanco del final de la fase. O sea que
**tocarlo te manda a la fase de bonus, y no tocarlo sigue el guion normal**. La
fase 1 también tiene blanco, y no lleva a ninguna.

La fase 3 y la 6 **no tienen terreno ninguno**. Su tramo de guión es 0xFFFF, así
que el montador de columnas siempre acaba en la rutina de estrellas y la fase
entera es cielo. Las otras diez llevan su terreno escrito como un guión de
números de pieza; los mapas de la portada son esos guiones dibujados de punta a
punta.

Cada fase tiene además su **punto de control**, en la tabla de 0x4212. Al montar
la fase, 0x41E1 compara la distancia ya recorrida con ese número: si la habías
pasado, la fase vuelve a arrancar justo ahí, y si no, en 0x20.

## El medidor de mejoras

Las seis casillas — SPEED UP, MISSILE, DOUBLE, LASER, OPTION y el escudo — se
pintan encendidas o apagadas según lo que la nave ya lleve. 0xA022 recorre la
ficha de la nave y deja un uno en 0xE131..0xE136 por cada mejora ya puesta;
0xA068 mira 0xE130, la casilla hasta la que han llegado las cápsulas, y con el
segundo botón da esa mejora si no la tiene. Al cogerla, el medidor vuelve a
cero.

Las cápsulas seguidas pagan más: 0xE128 las cuenta y la tabla en BCD de 0x7563
paga 1, 2, 5, 10, 20, 50 y 100, y ahí se queda.

## Las claves que se escriben

El cartucho lee el teclado **solo con el juego en pausa**. Se pausa con GRAPH;
desde ahí, cada tecla nueva va a 0xE1E8, hasta ocho, y al pulsar RETURN se
compara lo escrito contra las palabras de 0x51BF:

| palabra | qué da |
|---|---|
| `HYPER` | las cinco de golpe, pero solo la primera vez |
| `SHIELD` | el escudo |
| `LASER` | el láser |
| `MISSILE` | el misil |
| `DOUBLE` | el disparo doble |
| `OPTION` | una opción más |
| `DOWN` | deja la velocidad a cero |
| `BAKA`, `AHO` | nada bueno: ponen las naves a cero |

Y cada fase tiene **su propio nombre de mujer** — MOMOKO, CHIE, AKEMI, SYUKO,
CHIAKI, NORIKO, SATOE, YASUKO, KINUYO, HISAE, MIYUKI, YOHKO — que reparte la
tabla de 0x5163. Acertar el de la fase en la que estás da todo, como `HYPER`.

`BAKA` y `AHO` son *tonto* e *idiota* en japonés, y caen en 0x5127, que pone a
cero las naves, el aviso de la demo y las dos banderas del mando.

Todo esto está medido en openMSX con `tools/omsx_claves.tcl`, no deducido: en
pausa, 0xE1E8 se llena con `4F 50 54 49 4F 4E` — OPTION — y al pulsar RETURN
0xE20B pasa de 00 a 02, las dos opciones.

## La demo se juega sola leyendo una grabación

Si se le deja, el cartucho juega una fase por su cuenta. No es un piloto
automático: en el banco 12 hay, por fase, una lista de parejas [cuántos
cuadros][qué vale el mando], y 0x5CDA mete el valor grabado en la misma casilla
donde se deja lo que se lee del joystick de verdad. El bit del disparo va
forzado, así que la nave de la demo dispara sin parar, y arranca con todo
puesto: 0x5CB8 llama a la misma rutina que la clave `HYPER`.

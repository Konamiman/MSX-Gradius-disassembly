# Empezar

Un desensamblado comentado de **Nemesis / Gradius**, el RC-742 de Konami para
MSX: un MegaROM de 128 KB con el mapper de Konami sin SCC. Reensambla en la ROM
exacta, byte a byte, los dieciséis bancos, y cada uno de sus 131.072 bytes está
explicado.

## El cartucho no está aquí

Ningún repositorio distribuye el juego. Lo construyen los fuentes: hacen falta
`make`, `python3` y Nestor80 (N80 y LK80), y `make verify` ensambla cada
módulo, los enlaza y comprueba que el resultado, `build/nemesis.rom`, es el
cartucho original — 131072 bytes, sha256

    3210f8a0f2309dd4b9a89fc2b24d0f178ce4393a0a1f2854fbce545c361261bc

## Qué hace cada orden

    make            construye la ROM, la comprueba, pasa la sanidad y los tests
    make verify     la prueba que decide: los fuentes tienen que devolver la ROM
    make sanity     que el código de los fuentes sea exactamente el que ejecuta el juego
    make density    cuánto está comentado, rutina a rutina e imagen a imagen
    make recon      mide el mapper sobre los bytes: Konami4, sin SCC
    make mark       la marca escondida de Konami al final del banco 3
    make web        rehace esta web desde la ROM

## Dieciséis bancos, cinco imágenes

Un cartucho de 16 KB es un solo programa. Este no. El banco 0 está clavado en
0x4000-0x5FFF y las otras tres ventanas se eligen escribiendo el número de banco
en 0x6000, 0x8000 y 0xA000, así que **la misma dirección significa código
distinto según lo que esté puesto**. `tools/banks.py` fija el único org en el
que cada banco se ejecuta de verdad.

Lo que se enlaza junto no es el banco sino la **imagen**: los bancos que el
juego pone siempre a la vez, que para la CPU son un solo tramo de memoria. Hay
cinco — `main` (bancos 0-3, el juego), `scenery` (4-6), `sound` (7-8),
`screens` (9-10) y `map` (11-12) — y cada una tiene su directorio en `src/`,
con un fichero fuente por cada parte del programa. LK80 enlaza cada imagen de
una sola pasada, así que el código y los datos pueden pasar de un banco al
siguiente igual que en el cartucho. Los bancos 13, 14 y 15 están vacíos y no
tienen fuente.

Todo lo que se sabe de un byte está en su fichero fuente: la instrucción o el
dato, el nombre de la rutina o de la tabla, y el comentario. Una cabecera
`; DATA nombre: ...` explica cada bloque de datos.

## Qué significan las cifras

`make sanity` comprueba el código e imprime el presupuesto: **25.474 bytes de
código trazado** y **105.598 bytes de datos**, 0 sin explicar, 131.072 en
total. `make density` imprime la densidad de comentario por imagen: 12.959
instrucciones, 2.980 comentarios de línea, **23,0 %**, y 5 rutinas por debajo
del 10 % de 1.539.

Todas las cifras de esta web salen de esas dos órdenes, no de una estimación.

## Las imágenes están dibujadas, no capturadas

En esta web no hay ni una captura de emulador. `tools/graphics.py` ejecuta en
Python las propias rutinas del cartucho — el descompresor de rachas de 0x49B9,
el cargador de caracteres de 0x42FC, las listas de espejos y el montador de
columnas de 0x46AE — y dibuja los doce mapas y la pantalla de presentación
directamente desde los bytes. `make web` los rehace.

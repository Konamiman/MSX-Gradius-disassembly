# Empezar

Un desensamblado comentado de **Nemesis / Gradius**, el RC-742 de Konami para
MSX: un MegaROM de 128 KB con el mapper de Konami sin SCC. Reensambla en la ROM
exacta, byte a byte, los dieciséis bancos, y cada uno de sus 131.072 bytes está
explicado.

## El cartucho no está aquí

Ningún repositorio distribuye el juego. Pon tu propio volcado en la raíz como
`nemesis.rom`, 131072 bytes, sha256

    3210f8a0f2309dd4b9a89fc2b24d0f178ce4393a0a1f2854fbce545c361261bc

`make check` lo verifica.

## Qué hace cada orden

    make            traza el flujo, monta el listado, lo reensambla y pasa los tests
    make verify     la prueba que decide: reensamblar tiene que devolver la ROM
    make sanity     que no quede ni un byte sin explicar, y que ningún dato se lea como código
    make density   cuánto está comentado, rutina a rutina y banco a banco
    make recon   mide el mapper sobre los bytes: Konami4, sin SCC
    make mark      la marca escondida de Konami al final del banco 3
    make web        rehace esta web desde la ROM y las notas

## Dieciséis bancos, dieciséis listados

Un cartucho de 16 KB es un listado. Este no. El banco 0 está clavado en
0x4000-0x5FFF y las otras tres ventanas se eligen escribiendo el número de banco
en 0x6000, 0x8000 y 0xA000, así que **la misma dirección significa código
distinto según lo que esté puesto**. `tools/banks.py` fija el único org en el
que cada banco se ejecuta de verdad, y lo demás va banco a banco:

* `src/pNN.entries` — los puntos de entrada que el trazador no puede deducir: el
  gancho de la interrupción, las tablas de reparto pegadas al `call` y las
  direcciones de vuelta que este cartucho mete en la pila en vez de llamar. Cada
  una con su razón escrita al lado.
* `src/pNN.nocode` — las tablas de palabras pegadas justo detrás de su `call`.
  Un trazador que las atraviese se las come como instrucciones.
* `src/pNN.notes` — una línea por anotación: `L` bautiza una rutina, `C`
  comenta una instrucción, `B` un bloque, `D` un rango de datos y `F` la anchura
  de una ficha.

Un rango `D` solo vale para el banco en cuyas notas está: 0x6000 es el principio
del banco 1, del 4 y del 7.

## Qué significan las cifras

`make sanity` imprime el presupuesto: **25.471 bytes de código trazado** y
**105.601 bytes de datos en rangos con nombre**, 0 sin explicar, 131.072 en
total. `make density` imprime la densidad de comentario por banco: 12.959
instrucciones, 3.027 comentarios de línea, **23,4 %**, y ni una rutina por
debajo del 10 % de 1.540.

Todas las cifras de esta web salen de esas dos órdenes, no de una estimación.

## Las imágenes están dibujadas, no capturadas

En esta web no hay ni una captura de emulador. `tools/graphics.py` ejecuta en
Python las propias rutinas del cartucho — el descompresor de rachas de 0x49B9,
el cargador de caracteres de 0x42FC, las listas de espejos y el montador de
columnas de 0x46AE — y dibuja los doce mapas y la pantalla de presentación
directamente desde los bytes. `make web` los rehace.

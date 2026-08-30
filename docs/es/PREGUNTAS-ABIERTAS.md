# Preguntas abiertas

Lo que sigue sin estar zanjado. Todo esto está escrito como pregunta a
propósito: nada de ello se da por supuesto en el listado.

## Qué decide el límite de scroll a partir del tercer blanco

Cinco fases llevan escrito un blanco a una distancia fija: la 1, la 2, la 3, la
4 y la 7. Tocarlo revienta todo lo que hay en pantalla, para la pantalla y fija
el límite del scroll. Las fases 2, 3 y 6 tienen su límite propio; las demás
pasan por un contador en 0xE06C que solo avanza cuando el blanco es de un tipo
**distinto** del anterior, y al tercero distinto el límite pasa a ser 0x01C0.

Para qué sirve ese contador jugando — si es la ruta escondida, o la dificultad
de la vuelta, o alguna otra cosa — no está zanjado.

## Los 399 bytes de delante de la marca

El banco 3 acaba con un hueco de 399 bytes entre el último dato y los once bytes
de la marca de Konami. Están declarados como rango, pero no se sabe qué fueron:
pueden ser relleno para que la marca caiga justo al final, o la cola de algo que
se cortó.

## Qué fases de la ronda se alcanzan de verdad

La tabla de 0x418F dice con qué fase se sigue pasada la novena, y el listado la
lee bien. Lo que no está medido es cuáles de las doce se alcanzan en una partida
normal y cuáles solo en la segunda vuelta.

## Para qué sirve el segundo valor de la marca del bicho

Uno de cada cuatro bichos sale marcado, y uno de cada dieciséis sale con un 2 en
vez de un 1. El 1 se entiende: pinta el bicho de rojo y le cambia lo que deja al
morir. Qué cambia el 2, más allá de irse por otra rama, no se ha acotado
jugando.

## Si la fase 5 tiene más clases de fondo que las ocho vistas

El motor de fondo de la fase 5 reparte por ocho tipos de ficha, pero el guión
que las rellena solo escribe algunas. Si las demás no se usan o simplemente son
raras no se ha comprobado cuadro a cuadro.

#!/usr/bin/env python3
"""El formato comprimido con el que Nemesis mete sus graficos en la VRAM.

La rutina que lo lee es 0x49B9 del banco 0, y esta escrita del reves de lo que
uno esperaria: el bit 7 marca la copia literal, no la repeticion.

    49B9  call 0x494A        pone la direccion de escritura de la VRAM (HL)
    49BC  ld a,(de)          byte de mando
          and a / ret z      0x00 -> se acabo
          ld b,a / and 0x7F / cp b
          jr z, repetir      bit 7 A CERO -> repetir
          and a / jr z, saltar   0x80 -> cambiar de sitio en la VRAM
    literal (bit 7 a uno): copia (mando AND 0x7F) bytes tal cual
    repetir (bit 7 a cero): saca (mando) veces el byte que viene detras
    saltar  (mando 0x80):   los dos bytes siguientes son la nueva direccion
                            de VRAM, y se sigue leyendo

O sea, y en orden de como aparecen los mandos:

    0x00        fin del bloque
    0x01..0x7F  N veces el byte siguiente        (2 bytes de flujo)
    0x80        nueva direccion de VRAM          (3 bytes de flujo)
    0x81..0xFF  N-0x80 bytes literales           (1+N-0x80 bytes de flujo)

Con esto el tamano de cada bloque no se estima: se cuenta. Es lo que permite
declarar los rangos de graficos con la directiva D sin dejarse un byte ni
comerse el siguiente.

Uso:
    rle.py <rom> mide <banco> <direccion>      tamano y a donde va
    rle.py <rom> vuelca <banco> <direccion>    ademas, los bytes que escribe
"""
import sys

from paginas import ORG, TAM_PAGINA, nombre

FIN, REPETIR, SALTAR, LITERAL = "fin", "repetir", "saltar", "literal"


def descomprime(rom, banco, direccion, tope=None):
    """Devuelve (bytes_de_flujo, escrituras, mandos).

    escrituras: lista de (direccion_vram, bytes) en el orden en que salen.
    mandos: lista de (offset_relativo, clase, n) para poder mirarlo.
    """
    base = banco * TAM_PAGINA
    org = ORG[banco]
    if not org <= direccion < org + TAM_PAGINA:
        raise SystemExit("0x%04X no cae en el banco %d (org %#06x)"
                         % (direccion, banco, org))
    tope = tope if tope is not None else TAM_PAGINA
    i = direccion - org
    vram = None
    escrituras, mandos = [], []
    ini = i
    while i < tope:
        mando = rom[base + i]
        rel = i - ini
        i += 1
        if mando == 0x00:
            mandos.append((rel, FIN, 0))
            break
        if mando == 0x80:
            if i + 1 >= tope:
                break
            vram = rom[base + i] | (rom[base + i + 1] << 8)
            i += 2
            mandos.append((rel, SALTAR, vram))
            continue
        if mando & 0x80:
            n = mando & 0x7F
            trozo = rom[base + i:base + i + n]
            i += n
            mandos.append((rel, LITERAL, n))
            escrituras.append((vram, bytes(trozo)))
        else:
            n = mando
            if i >= tope:
                break
            trozo = bytes([rom[base + i]]) * n
            i += 1
            mandos.append((rel, REPETIR, n))
            escrituras.append((vram, trozo))
    return i - ini, escrituras, mandos


def cadena(rom, banco, ini, fin):
    """Bloques pegados uno detras de otro, de ini hasta fin.

    Que la cadena encaje sin holgura es la prueba de que el formato se ha
    leido bien: un solo byte de mas o de menos y el bloque siguiente empieza
    donde no debe y se desmonta todo lo que viene detras.
    """
    fuera = []
    a = ini
    tope = fin - ORG[banco]
    while a < fin:
        n, esc, man = descomprime(rom, banco, a, tope)
        if n <= 0:
            break
        salida = sum(len(t) for _v, t in esc)
        destino = next((v for v, _t in esc if v is not None), None)
        fuera.append((a, n, salida, destino))
        a += n
    return fuera, a


def main():
    rom = open(sys.argv[1], "rb").read()
    modo = sys.argv[2]
    if modo == "cadena":
        banco = int(sys.argv[3], 0)
        bloques, fin = cadena(rom, banco, int(sys.argv[4], 0),
                              int(sys.argv[5], 0))
        for a, n, salida, destino in bloques:
            print("  D 0x%04X 0x%04X   %d bytes de flujo -> %d en la VRAM%s"
                  % (a, a + n, n, salida,
                     ("  (primer destino %#06x)" % destino) if destino else ""))
        print("  la cadena acaba en 0x%04X (%d bloques)" % (fin, len(bloques)))
        return 0
    banco = int(sys.argv[3], 0)
    direccion = int(sys.argv[4], 0)
    n, escrituras, mandos = descomprime(rom, banco, direccion)
    salida = sum(len(t) for _v, t in escrituras)
    print("%s 0x%04X..0x%04X  %d bytes de flujo -> %d bytes en la VRAM  "
          "(%d mandos)" % (nombre(banco), direccion, direccion + n - 1, n,
                           salida, len(mandos)))
    destinos = [v for v, _t in escrituras if v is not None]
    if destinos:
        print("   primera direccion de VRAM: %#06x" % destinos[0])
    for rel, clase, k in mandos:
        if clase == SALTAR:
            print("   +%04X  cambia la direccion de VRAM a %#06x" % (rel, k))
    if modo == "vuelca":
        for v, t in escrituras:
            print("   VRAM %s: %s" % (
                "%#06x" % v if v is not None else "  ?   ",
                " ".join("%02x" % c for c in t[:24])))
    return 0


if __name__ == "__main__":
    sys.exit(main())

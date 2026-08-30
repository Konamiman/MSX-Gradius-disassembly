#!/usr/bin/env python3
"""La regla banco -> direccion del MegaROM, compartida por todas las herramientas.

Nemesis / Gradius es un cartucho de 128 KB con el mapper Konami SIN SCC
(Konami4): 16 bancos de 8 KB. El banco de 0x4000-0x5FFF es FIJO -no hay
registro para el- y los otros tres se eligen escribiendo el numero de banco en
0x6000 (para 0x6000-0x7FFF), 0x8000 (para 0x8000-0x9FFF) y 0xA000 (para
0xA000-0xBFFF).

Lo que dice la ROM (tools/reconocimiento.py lo vuelve a medir cada vez):
  - NO hay ni una escritura a 0x5000, 0x7000, 0x9000 ni 0xB000, que son los
    registros del OTRO mapper de Konami, el que lleva SCC. Por eso este es
    Konami4 y no Konami5.
  - Las tres escrituras que arrancan en INIT (0x4071) reparten 1/2/3 y las
    apuntan en el trio de RAM 0xF0F1..0xF0F3; la misma rutina, con A=4,
    reparte 4/5/6. Las escrituras sueltas a 0x8000 solo llevan 2, 5, 7, 9 y 11;
    las sueltas a 0xA000 solo llevan 3, 6, 8, 10 y 12.

  De ahi sale la tabla de abajo: cada banco tiene UNA sola direccion donde se
  ejecuta.

        banco 0                -> 0x4000  (fijo, sin registro)
        bancos 1, 4            -> 0x6000
        bancos 2, 5, 7, 9, 11  -> 0x8000
        bancos 3, 6, 8, 10, 12 -> 0xA000

  Los bancos 6, 13, 14 y 15 son 8192 bytes de 0xFF: relleno hasta los 128 KB.
  El 6 se mapea de verdad -la rutina de 4/5/6 lo mete en 0xA000-, aunque lo
  que quede ahi no se lea nunca; los 13, 14 y 15 no los selecciona nadie, y su
  org es una CONVENCION nuestra (0x8000) para poder listarlos igual.

  Si alguna vez aparece un banco mapeado en otra ranura, esta regla deja de
  valer para ESE banco y habra que partirlo en dos modulos.

Uso como programa:
    paginas.py org <n>               imprime el org del banco n
    paginas.py lista                 imprime "n org" para los 16
    paginas.py corta <rom> <dir>     escribe <dir>/pNN.bin con cada banco
"""
import os
import sys

TAM_PAGINA = 0x2000
N_PAGINAS = 16

# banco -> direccion de ejecucion. Medido, no supuesto: ver reconocimiento.py.
ORG = {
    0: 0x4000,
    1: 0x6000, 4: 0x6000,
    2: 0x8000, 5: 0x8000, 7: 0x8000, 9: 0x8000, 11: 0x8000,
    3: 0xA000, 6: 0xA000, 8: 0xA000, 10: 0xA000, 12: 0xA000,
    # Nunca los selecciona nadie (son 0xFF de punta a punta). Org convencional.
    13: 0x8000, 14: 0x8000, 15: 0x8000,
}

# Los bancos que no toca ningun registro del mapper y ademas son todo 0xFF.
NUNCA_MAPEADOS = (13, 14, 15)


def org(p):
    """Direccion en la que se ejecuta el banco p."""
    return ORG[p]


def nombre(p):
    """Nombre del modulo del banco p: p00..p15."""
    return "p%02d" % p


def main(argv):
    if len(argv) < 2:
        sys.exit(__doc__)
    if argv[1] == "org":
        print("%#06x" % org(int(argv[2], 10)))
    elif argv[1] == "lista":
        for p in range(N_PAGINAS):
            print("%d %#06x" % (p, org(p)))
    elif argv[1] == "corta":
        rom, dst = argv[2], argv[3]
        d = open(rom, "rb").read()
        if len(d) != TAM_PAGINA * N_PAGINAS:
            sys.exit("la ROM mide %d bytes y no %d" % (len(d), TAM_PAGINA * N_PAGINAS))
        os.makedirs(dst, exist_ok=True)
        for p in range(N_PAGINAS):
            with open(os.path.join(dst, nombre(p) + ".bin"), "wb") as f:
                f.write(d[p * TAM_PAGINA:(p + 1) * TAM_PAGINA])
        print("16 bancos de %d bytes en %s/" % (TAM_PAGINA, dst))
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv)

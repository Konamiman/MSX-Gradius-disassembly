#!/usr/bin/env python3
"""Dibuja las pantallas y los mapas de Nemesis leyendo SOLO la ROM.

Aqui no hay ni una captura de emulador: todo lo que sale de esta herramienta
se saca ejecutando en Python las mismas rutinas que ejecuta el cartucho.

  - El descompresor de 0x49B9, que es el que llena la VRAM de patrones y
    colores (tools/rle.py explica el formato).
  - carga_los_caracteres_de_la_fase (0x42FC): las fichas de seis bytes de
    0x932D y las de la tabla de 0x92E3, que dicen que trozo comprimido va a
    que caracter y en que tercios.
  - Los dos juegos de espejos, 0x92FB y 0x9313, que fabrican la mitad de los
    caracteres del terreno dandole la vuelta a la otra mitad.
  - lee_la_columna_nueva (0x46AE) y mete_la_columna_nueva (0x46E1), que son
    las que montan el mapa: el guion de la fase suelta seis numeros de pieza
    por cada cuatro columnas, y cada pieza son cuatro por cuatro caracteres.

OJO CON LA VRAM: este cartucho no usa el reparto de la BIOS. Los patrones
viven en 0x2000, los colores en 0x0000, la tabla de nombres en 0x3800 y los
patrones de sprite en 0x1800 (ver el bloque de p00:0x5749).

Uso:
    graficos.py            dibuja todo en docs/imagenes
    graficos.py mapas      solo los mapas de las doce fases
    graficos.py pantallas  solo las pantallas fijas
    graficos.py sprites    solo la hoja de sprites
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image

from paginas import ORG, TAM_PAGINA

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROM = os.path.join(RAIZ, "nemesis.rom")
SALIDA = os.path.join(RAIZ, "docs", "imagenes")

# La paleta del TMS9918, tal cual la da el estandar.
PALETA = [
    (0, 0, 0), (0, 0, 0), (33, 200, 66), (94, 220, 120),
    (84, 85, 237), (125, 118, 252), (212, 82, 77), (66, 235, 245),
    (252, 85, 84), (255, 121, 120), (212, 193, 84), (230, 206, 128),
    (33, 176, 59), (201, 91, 186), (204, 204, 204), (255, 255, 255),
]

PATRONES = 0x2000   # donde el cartucho pone la tabla de patrones
COLORES = 0x0000    # y donde pone la de colores
SPRITES = 0x1800    # los patrones de sprite

# El reparto de bancos con el que corre cada trozo del cartucho.
GRAFICOS = {0x6000: 4, 0x8000: 5, 0xA000: 6}   # p00:0x422A
MAPA = {0x8000: 11, 0xA000: 12}                # p00:0x460C


def carga_rom():
    with open(ROM, "rb") as f:
        return f.read()


def lee(rom, banco, direccion):
    """El byte que hay en esa direccion con ese banco puesto."""
    org = ORG[banco]
    return rom[banco * TAM_PAGINA + (direccion - org)]


def lee_palabra(rom, banco, direccion):
    return lee(rom, banco, direccion) | (lee(rom, banco, direccion + 1) << 8)


def banco_de(direccion, reparto):
    """Que banco esta puesto en la ventana donde cae esa direccion."""
    if direccion < 0x6000:
        return 0
    return reparto[direccion & 0xE000]


# ---------------------------------------------------------------- el RLE

def descomprime(rom, vram, banco, origen, destino):
    """La rutina de 0x49B9, escrita en Python. Devuelve donde se quedo."""
    p = origen
    vp = destino
    while True:
        mando = lee(rom, banco, p)
        p += 1
        if mando == 0x00:
            return p
        if mando == 0x80:
            vp = lee(rom, banco, p) | (lee(rom, banco, p + 1) << 8)
            p += 2
            continue
        if mando & 0x80:
            for _ in range(mando & 0x7F):
                vram[vp & 0x3FFF] = lee(rom, banco, p)
                p += 1
                vp += 1
        else:
            valor = lee(rom, banco, p)
            p += 1
            for _ in range(mando):
                vram[vp & 0x3FFF] = valor
                vp += 1


# ------------------------------------------------- los caracteres de la fase

def carga_fichas(rom, vram, ix, reparto):
    """carga_fichas (0x4371): fichas de seis bytes hasta el primer cero."""
    banco_tabla = banco_de(ix, reparto)
    while True:
        flags = lee(rom, banco_tabla, ix)
        if flags == 0:
            return
        patrones = lee_palabra(rom, banco_tabla, ix + 1)
        caracter = lee(rom, banco_tabla, ix + 3)
        colores = lee_palabra(rom, banco_tabla, ix + 4)
        for bit, tercio in ((0, 0x1000), (1, 0x0800), (2, 0x0000)):
            if flags & (1 << bit):
                sitio = (caracter * 8 + tercio) & 0xFFFF
                descomprime(rom, vram, banco_de(patrones, reparto),
                            patrones, sitio + PATRONES)
                descomprime(rom, vram, banco_de(colores, reparto),
                            colores, sitio + COLORES)
        ix += 6


def enciende_las_estrellas(vram):
    """Las estrellas no vienen en ningun bloque comprimido: son UN pixel de la
    primera fila de los caracteres 0xF6, 0xF7 y 0xF8, y quien lo enciende es
    parpadea_dos_caracteres (0x475B) con el bit que va rotando en 0xE062.
    Aqui se fija uno para que la foto salga quieta."""
    for caracter in (0xF6, 0xF7, 0xF8):
        for tercio in range(3):
            vram[PATRONES + tercio * 0x800 + caracter * 8] = 0x10


def voltea_bits(ocho):
    """voltea_los_bits (0x43E6): espejo horizontal, bit a bit."""
    return [int("{:08b}".format(b)[::-1], 2) for b in ocho]


def voltea_bytes(ocho):
    """voltea_los_bytes (0x43C6): espejo vertical, byte a byte."""
    return list(reversed(ocho))


def recorre_las_fichas(rom, vram, tabla, fase, vertical, reparto):
    """recorre_las_fichas (0x433F): la lista de espejos que le toca a la fase."""
    banco = banco_de(tabla, reparto)
    ix = lee_palabra(rom, banco, tabla + 2 * fase)
    banco_ix = banco_de(ix, reparto)
    while True:
        cuantos = lee(rom, banco_ix, ix)
        if cuantos == 0:
            return
        origen = lee(rom, banco_ix, ix + 1) | (lee(rom, banco_ix, ix + 2) << 8)
        caracter = lee(rom, banco_ix, ix + 3)
        for n in range(cuantos):
            de = (origen + n) * 8
            a = (caracter + n) * 8
            for tabla_v in (PATRONES, COLORES):
                ocho = [vram[(tabla_v + de + i) & 0x3FFF] for i in range(8)]
                ocho = voltea_bytes(ocho) if vertical else voltea_bits(ocho)
                for i, b in enumerate(ocho):
                    vram[(tabla_v + a + i) & 0x3FFF] = b
        ix += 4


def caracteres_de_la_fase(rom, fase):
    """La VRAM tal como queda despues de carga_los_caracteres_de_la_fase."""
    vram = bytearray(0x4000)
    carga_fichas(rom, vram, 0x932D, GRAFICOS)                 # las de todas
    tabla = lee_palabra(rom, 5, 0x92E3 + 2 * fase)            # y las suyas
    carga_fichas(rom, vram, tabla, GRAFICOS)
    recorre_las_fichas(rom, vram, 0x92FB, fase, False, GRAFICOS)
    recorre_las_fichas(rom, vram, 0x9313, fase, True, GRAFICOS)
    # Los patrones de sprite, que van aparte (p00:0x4249).
    descomprime(rom, vram, banco_de(0x86BB, GRAFICOS), 0x86BB, SPRITES)
    enciende_las_estrellas(vram)
    return vram


# ------------------------------------------------------------- el mapa

def tramo_de_la_fase(rom, fase):
    """0xE101 y 0xE103: entre que distancias manda el guion (tabla de 0x4499)."""
    base = 0x4499 + 6 * fase
    ini = lee(rom, 0, base) | (lee(rom, 0, base + 1) << 8)
    fin = lee(rom, 0, base + 2) | (lee(rom, 0, base + 3) << 8)
    return ini, fin


def columna_de_estrellas(rom, d):
    """pinta_la_columna_de_estrellas (0x4738): la columna de cielo."""
    fila = lee(rom, 0, 0x478E + (d & 0x1F))
    columna = [0] * 22
    if 1 <= fila <= 22:
        columna[fila - 1] = 0xF6      # 0xF6 o 0xF7; el R del Z80 decide cual
    return columna


def columna_del_guion(rom, fase, d):
    """lee_la_columna_nueva + mete_la_columna_nueva: los seis numeros de pieza."""
    guion = lee_palabra(rom, 11, 0x97DE + 2 * fase)
    piezas = 0x8FF0 if fase in (5, 9, 10, 12) else 0x8000
    ini, _ = tramo_de_la_fase(rom, fase)
    renglon = ((d - ini) >> 2) * 6
    columna = []
    for n in range(6):
        pieza = lee(rom, banco_de(guion, MAPA), guion + renglon + n)
        base = piezas + pieza * 16 + ((d - ini) & 3)
        for k in range(2 if n == 5 else 4):
            columna.append(lee(rom, 11, base + 4 * k))
    return columna


def mapa_de_la_fase(rom, fase):
    """Las 22 filas del mapa entero, columna a columna, como las monta 0x46E1."""
    ini, fin = tramo_de_la_fase(rom, fase)
    if ini == 0xFFFF:                 # las fases 3 y 6 son cielo de punta a punta
        ancho, ini, fin = 0x100, 1, 0
    else:
        ancho = fin + 0x28
    filas = [[0] * ancho for _ in range(22)]
    for d in range(ancho):
        col = (columna_del_guion(rom, fase, d) if ini <= d <= fin
               else columna_de_estrellas(rom, d))
        for f in range(22):
            filas[f][d] = col[f]
    return filas


# ------------------------------------------------------------- el dibujo

def dibuja_caracter(px, vram, caracter, x, y, tercio):
    """Un caracter de 8x8 en la imagen, con sus dos colores por fila."""
    base = (tercio * 0x800 + caracter * 8) & 0x1FFF
    for fila in range(8):
        patron = vram[(PATRONES + base + fila) & 0x3FFF]
        color = vram[(COLORES + base + fila) & 0x3FFF]
        tinta = PALETA[color >> 4]
        fondo = PALETA[color & 0x0F]
        for bit in range(8):
            px[x + bit, y + fila] = tinta if patron & (0x80 >> bit) else fondo


def dibuja_mapa(vram, filas):
    """El mapa entero: 22 filas de caracteres por lo ancho que sea."""
    alto = len(filas)
    ancho = len(filas[0])
    img = Image.new("RGB", (ancho * 8, alto * 8))
    px = img.load()
    for f in range(alto):
        for c in range(ancho):
            # El tercio sale de la fila del mapa, como en la pantalla real.
            dibuja_caracter(px, vram, filas[f][c], c * 8, f * 8, f // 8)
    return img


def dibuja_pantalla(vram):
    """Los 768 caracteres de la tabla de nombres, en 32x24."""
    img = Image.new("RGB", (256, 192))
    px = img.load()
    for f in range(24):
        for c in range(32):
            caracter = vram[(0x3800 + f * 32 + c) & 0x3FFF]
            dibuja_caracter(px, vram, caracter, c * 8, f * 8, f // 8)
    return img


def dibuja_juego_de_caracteres(vram, escala=2):
    """Los 256 caracteres de cada tercio, en tres rejillas de 16 por 16."""
    img = Image.new("RGB", (3 * (16 * 9 + 1) + 16, 16 * 9 + 1), (24, 24, 32))
    px = img.load()
    for tercio in range(3):
        ox = tercio * (16 * 9 + 8) + 1
        for n in range(256):
            dibuja_caracter(px, vram, n, ox + (n % 16) * 9,
                            1 + (n // 16) * 9, tercio)
    return img.resize((img.width * escala, img.height * escala), Image.NEAREST)


def dibuja_hoja_de_sprites(vram, ancho=16):
    """Los patrones de sprite de 0x1800, de 16x16, en una hoja."""
    total = 0x800 // 32
    alto = (total + ancho - 1) // ancho
    img = Image.new("RGB", (ancho * 17 + 1, alto * 17 + 1), (24, 24, 32))
    escala = 3
    px = img.load()
    for n in range(total):
        ox = 1 + (n % ancho) * 17
        oy = 1 + (n // ancho) * 17
        base = SPRITES + n * 32
        for mitad in range(2):
            for fila in range(16):
                b = vram[(base + mitad * 16 + fila) & 0x3FFF]
                for bit in range(8):
                    if b & (0x80 >> bit):
                        px[ox + mitad * 8 + bit, oy + fila] = (255, 255, 255)
    return img.resize((img.width * escala, img.height * escala), Image.NEAREST)


# ------------------------------------------------------------- pantallas fijas

def escribe_caracteres(rom, vram, banco, flujo, borrar=False):
    """escribe_caracteres (0x4998): rotulos sueltos en la tabla de nombres."""
    p = flujo
    while True:
        vp = lee(rom, banco, p) | (lee(rom, banco, p + 1) << 8)
        p += 2
        while True:
            b = lee(rom, banco, p)
            p += 1
            if b == 0xFF:
                return
            if b == 0xFE:
                break
            vram[vp & 0x3FFF] = 0 if borrar else b
            vp += 1


def pantalla_de_records(rom):
    """monta_la_pantalla_de_records (0x5BF8), con los bancos 9 y 10."""
    vram = bytearray(0x4000)
    reparto = {0x6000: 1, 0x8000: 9, 0xA000: 10}
    for destino, origen in ((0x2008, 0x8300), (0x2808, 0x87FA), (0x3008, 0x8CB2),
                            (0x0008, 0x917E), (0x0808, 0x9515), (0x1008, 0x989F)):
        descomprime(rom, vram, 9, origen, destino)
    for destino, origen in ((0x2780, 0xA758), (0x0780, 0xA783)):
        for tercio in range(3):
            descomprime(rom, vram, 10, origen, destino + tercio * 0x800)
    descomprime(rom, vram, 10, 0xA7A4, SPRITES)
    # La tabla de nombres va SIN comprimir: 768 caracteres del banco 9 (0x5C63).
    for n in range(0x300):
        vram[0x3800 + n] = lee(rom, 9, 0x8000 + n)
    enciende_las_estrellas(vram)
    return vram, reparto


def pantalla_del_marcador(rom):
    """La otra tanda de graficos del banco 10 (p00:0x4B0A)."""
    vram = bytearray(0x4000)
    for destino, origen in ((0x2418, 0xA0DB), (0x0418, 0xA3F4)):
        for tercio in range(3):
            descomprime(rom, vram, 10, origen, destino + tercio * 0x800)
    descomprime(rom, vram, 10, 0xA683, SPRITES)
    # Los rotulos: el flujo de 0x4FB2, que 0x4B39 le pasa a escribe_caracteres.
    escribe_caracteres(rom, vram, 0, 0x4FB2)
    enciende_las_estrellas(vram)
    return vram


def pantalla_del_titulo(rom, japones=False):
    """monta_la_pantalla_del_titulo (0x5B31) y escribe_el_panel_del_titulo
    (0x5B77), con los bancos 9 y 10 puestos.

    Aqui esta el logotipo, y el cartucho lleva LOS DOS: lee el juego de
    caracteres de la maquina en 0x002B de la BIOS y, con el nibble bajo a
    cero -maquina japonesa-, escribe el panel de 0x9BCB, que pone GRADIUS;
    con cualquier otra cosa el de 0x9B3F, que pone NEMESIS. Mismo binario.
    """
    vram = bytearray(0x4000)
    for destino, origen in ((0x2468, 0x9C57), (0x0468, 0x9EAB)):
        for tercio in range(3):
            descomprime(rom, vram, 9, origen, destino + tercio * 0x800)
    # El panel: cinco filas de 28 caracteres desde 0x3882, o sea fila 4,
    # columna 2. Cruza la frontera del primer tercio, y por eso los patrones
    # se descomprimen en los tres.
    panel = 0x9BCB if japones else 0x9B3F
    for fila in range(5):
        for col in range(28):
            vram[0x3882 + fila * 32 + col] = lee(rom, 9, panel + fila * 28 + col)
    return vram


def dibuja_rotulo(vram, escala=3):
    """Solo el panel del logotipo: 28 x 5 caracteres desde la fila 4."""
    img = dibuja_pantalla(vram).crop((2 * 8, 4 * 8, 30 * 8, 9 * 8))
    return img.resize((img.width * escala, img.height * escala), Image.NEAREST)


# ------------------------------------------------------------------ main

def guarda(img, nombre):
    os.makedirs(SALIDA, exist_ok=True)
    ruta = os.path.join(SALIDA, nombre)
    img.save(ruta)
    print("  %-28s %d x %d" % (nombre, img.width, img.height))


def haz_los_mapas(rom):
    print("Mapas de las fases (dibujados columna a columna desde el guion):")
    for fase in range(1, 13):
        vram = caracteres_de_la_fase(rom, fase)
        filas = mapa_de_la_fase(rom, fase)
        guarda(dibuja_mapa(vram, filas), "mapa_fase%02d.png" % fase)


def haz_las_pantallas(rom):
    print("Pantallas fijas:")
    vram, _ = pantalla_de_records(rom)
    guarda(dibuja_pantalla(vram), "presentacion.png")
    guarda(dibuja_pantalla(pantalla_del_titulo(rom)), "titulo.png")
    guarda(dibuja_rotulo(pantalla_del_titulo(rom)), "rotulo.png")
    guarda(dibuja_rotulo(pantalla_del_titulo(rom, japones=True)),
           "rotulo_gradius.png")
    vram2 = pantalla_del_marcador(rom)
    guarda(dibuja_juego_de_caracteres(vram2), "caracteres_del_final.png")
    guarda(dibuja_juego_de_caracteres(caracteres_de_la_fase(rom, 1)),
           "caracteres_fase01.png")


def haz_los_sprites(rom):
    print("Hoja de sprites:")
    vram = caracteres_de_la_fase(rom, 1)
    guarda(dibuja_hoja_de_sprites(vram), "sprites.png")


def main():
    rom = carga_rom()
    que = sys.argv[1] if len(sys.argv) > 1 else "todo"
    if que in ("todo", "mapas"):
        haz_los_mapas(rom)
    if que in ("todo", "pantallas"):
        haz_las_pantallas(rom)
    if que in ("todo", "sprites"):
        haz_los_sprites(rom)
    return 0


if __name__ == "__main__":
    sys.exit(main())

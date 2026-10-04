#!/usr/bin/env python3
"""Draws the screens and maps of Nemesis reading ONLY the ROM.

There is not a single emulator capture here: everything that comes out of
this tool is obtained by running in Python the same routines the cartridge
runs.

  - The decompressor at 0x49B9, which is the one that fills the VRAM with
    patterns and colours (tools/rle.py explains the format).
  - load_stage_characters (0x42FC): the six-byte records at
    0x932D and those of the table at 0x92E3, which say which compressed
    chunk goes to which character and in which thirds.
  - The two sets of mirrors, 0x92FB and 0x9313, which build half of the
    terrain characters by flipping the other half.
  - read_new_column (0x46AE) and insert_new_column (0x46E1), which
    are the ones that build the map: the stage script emits six piece
    numbers for every four columns, and each piece is four by four
    characters.

CAREFUL WITH THE VRAM: this cartridge does not use the BIOS layout. The
patterns live at 0x2000, the colours at 0x0000, the name table at 0x3800 and
the sprite patterns at 0x1800 (see the block at p00:0x5749).

Usage:
    graphics.py            draws everything in docs/images
    graphics.py maps       only the maps of the twelve stages
    graphics.py screens    only the fixed screens
    graphics.py sprites    only the sprite sheet
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image

from banks import ORG, BANK_SIZE

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROM = os.path.join(ROOT, "build", "nemesis.rom")   # built by `make rom`
OUT_DIR = os.path.join(ROOT, "docs", "images")

# The TMS9918 palette, as the standard gives it.
PALETTE = [
    (0, 0, 0), (0, 0, 0), (33, 200, 66), (94, 220, 120),
    (84, 85, 237), (125, 118, 252), (212, 82, 77), (66, 235, 245),
    (252, 85, 84), (255, 121, 120), (212, 193, 84), (230, 206, 128),
    (33, 176, 59), (201, 91, 186), (204, 204, 204), (255, 255, 255),
]

PATTERNS = 0x2000   # where the cartridge puts the pattern table
COLOURS = 0x0000    # and where it puts the colour table
SPRITES = 0x1800    # the sprite patterns

# The bank layout each part of the cartridge runs with.
GRAPHICS = {0x6000: 4, 0x8000: 5, 0xA000: 6}   # p00:0x422A
MAP = {0x8000: 11, 0xA000: 12}                # p00:0x460C


def load_rom():
    with open(ROM, "rb") as f:
        return f.read()


def read(rom, bank, address):
    """The byte at that address with that bank in place."""
    org = ORG[bank]
    return rom[bank * BANK_SIZE + (address - org)]


def read_word(rom, bank, address):
    return read(rom, bank, address) | (read(rom, bank, address + 1) << 8)


def bank_of(address, layout):
    """Which bank is in the window where that address falls."""
    if address < 0x6000:
        return 0
    return layout[address & 0xE000]


# ---------------------------------------------------------------- the RLE

def decompress(rom, vram, bank, source, dest):
    """The routine at 0x49B9, written in Python. Returns where it stopped."""
    p = source
    vp = dest
    while True:
        command = read(rom, bank, p)
        p += 1
        if command == 0x00:
            return p
        if command == 0x80:
            vp = read(rom, bank, p) | (read(rom, bank, p + 1) << 8)
            p += 2
            continue
        if command & 0x80:
            for _ in range(command & 0x7F):
                vram[vp & 0x3FFF] = read(rom, bank, p)
                p += 1
                vp += 1
        else:
            value = read(rom, bank, p)
            p += 1
            for _ in range(command):
                vram[vp & 0x3FFF] = value
                vp += 1


# ------------------------------------------------- the stage characters

def load_records(rom, vram, ix, layout):
    """load_entries (0x4371): six-byte records up to the first zero."""
    table_bank = bank_of(ix, layout)
    while True:
        flags = read(rom, table_bank, ix)
        if flags == 0:
            return
        patterns = read_word(rom, table_bank, ix + 1)
        character = read(rom, table_bank, ix + 3)
        colours = read_word(rom, table_bank, ix + 4)
        for bit, third in ((0, 0x1000), (1, 0x0800), (2, 0x0000)):
            if flags & (1 << bit):
                place = (character * 8 + third) & 0xFFFF
                decompress(rom, vram, bank_of(patterns, layout),
                           patterns, place + PATTERNS)
                decompress(rom, vram, bank_of(colours, layout),
                           colours, place + COLOURS)
        ix += 6


def light_the_stars(vram):
    """The stars are not in any compressed block: they are ONE pixel of the
    first row of characters 0xF6, 0xF7 and 0xF8, and the one that lights it
    is blink_two_characters (0x475B) with the bit that keeps rotating in
    0xE062. Here one is fixed so that the picture comes out still."""
    for character in (0xF6, 0xF7, 0xF8):
        for third in range(3):
            vram[PATTERNS + third * 0x800 + character * 8] = 0x10


def flip_bits(eight):
    """flip_bits (0x43E6): horizontal mirror, bit by bit."""
    return [int("{:08b}".format(b)[::-1], 2) for b in eight]


def flip_bytes(eight):
    """flip_bytes (0x43C6): vertical mirror, byte by byte."""
    return list(reversed(eight))


def walk_records(rom, vram, table, stage, vertical, layout):
    """walk_entries (0x433F): the mirror list that belongs to the stage."""
    bank = bank_of(table, layout)
    ix = read_word(rom, bank, table + 2 * stage)
    ix_bank = bank_of(ix, layout)
    while True:
        count = read(rom, ix_bank, ix)
        if count == 0:
            return
        source = read(rom, ix_bank, ix + 1) | (read(rom, ix_bank, ix + 2) << 8)
        character = read(rom, ix_bank, ix + 3)
        for n in range(count):
            src_off = (source + n) * 8
            dst_off = (character + n) * 8
            for vtable in (PATTERNS, COLOURS):
                eight = [vram[(vtable + src_off + i) & 0x3FFF] for i in range(8)]
                eight = flip_bytes(eight) if vertical else flip_bits(eight)
                for i, b in enumerate(eight):
                    vram[(vtable + dst_off + i) & 0x3FFF] = b
        ix += 4


def stage_characters(rom, stage):
    """The VRAM as it is left after load_stage_characters."""
    vram = bytearray(0x4000)
    load_records(rom, vram, 0x932D, GRAPHICS)                # the common ones
    table = read_word(rom, 5, 0x92E3 + 2 * stage)            # and its own
    load_records(rom, vram, table, GRAPHICS)
    walk_records(rom, vram, 0x92FB, stage, False, GRAPHICS)
    walk_records(rom, vram, 0x9313, stage, True, GRAPHICS)
    # The sprite patterns, which go separately (p00:0x4249).
    decompress(rom, vram, bank_of(0x86BB, GRAPHICS), 0x86BB, SPRITES)
    light_the_stars(vram)
    return vram


# ------------------------------------------------------------- the map

def stage_range(rom, stage):
    """0xE101 and 0xE103: between which distances the script rules (table
    at 0x4499)."""
    base = 0x4499 + 6 * stage
    start = read(rom, 0, base) | (read(rom, 0, base + 1) << 8)
    end = read(rom, 0, base + 2) | (read(rom, 0, base + 3) << 8)
    return start, end


def star_column(rom, d):
    """draw_star_column (0x4738): the sky column."""
    row = read(rom, 0, 0x478E + (d & 0x1F))
    column = [0] * 22
    if 1 <= row <= 22:
        column[row - 1] = 0xF6      # 0xF6 or 0xF7; the Z80's R decides which
    return column


def script_column(rom, stage, d):
    """read_new_column + insert_new_column: the six piece numbers."""
    script = read_word(rom, 11, 0x97DE + 2 * stage)
    pieces = 0x8FF0 if stage in (5, 9, 10, 12) else 0x8000
    start, _ = stage_range(rom, stage)
    record = ((d - start) >> 2) * 6
    column = []
    for n in range(6):
        piece = read(rom, bank_of(script, MAP), script + record + n)
        base = pieces + piece * 16 + ((d - start) & 3)
        for k in range(2 if n == 5 else 4):
            column.append(read(rom, 11, base + 4 * k))
    return column


def stage_map(rom, stage):
    """The 22 rows of the whole map, column by column, as 0x46E1 builds them."""
    start, end = stage_range(rom, stage)
    if start == 0xFFFF:               # stages 3 and 6 are sky from end to end
        width, start, end = 0x100, 1, 0
    else:
        width = end + 0x28
    rows = [[0] * width for _ in range(22)]
    for d in range(width):
        col = (script_column(rom, stage, d) if start <= d <= end
               else star_column(rom, d))
        for f in range(22):
            rows[f][d] = col[f]
    return rows


# ------------------------------------------------------------- the drawing

def draw_character(px, vram, character, x, y, third):
    """One 8x8 character in the image, with its two colours per row."""
    base = (third * 0x800 + character * 8) & 0x1FFF
    for row in range(8):
        pattern = vram[(PATTERNS + base + row) & 0x3FFF]
        color = vram[(COLOURS + base + row) & 0x3FFF]
        ink = PALETTE[color >> 4]
        background = PALETTE[color & 0x0F]
        for bit in range(8):
            px[x + bit, y + row] = ink if pattern & (0x80 >> bit) else background


def draw_map(vram, rows):
    """The whole map: 22 rows of characters by however wide it is."""
    height = len(rows)
    width = len(rows[0])
    img = Image.new("RGB", (width * 8, height * 8))
    px = img.load()
    for f in range(height):
        for c in range(width):
            # The third comes from the map row, as on the real screen.
            draw_character(px, vram, rows[f][c], c * 8, f * 8, f // 8)
    return img


def draw_screen(vram):
    """The 768 characters of the name table, in 32x24."""
    img = Image.new("RGB", (256, 192))
    px = img.load()
    for f in range(24):
        for c in range(32):
            character = vram[(0x3800 + f * 32 + c) & 0x3FFF]
            draw_character(px, vram, character, c * 8, f * 8, f // 8)
    return img


def draw_character_set(vram, scale=2):
    """The 256 characters of each third, in three 16 by 16 grids."""
    img = Image.new("RGB", (3 * (16 * 9 + 1) + 16, 16 * 9 + 1), (24, 24, 32))
    px = img.load()
    for third in range(3):
        ox = third * (16 * 9 + 8) + 1
        for n in range(256):
            draw_character(px, vram, n, ox + (n % 16) * 9,
                           1 + (n // 16) * 9, third)
    return img.resize((img.width * scale, img.height * scale), Image.NEAREST)


def draw_sprite_sheet(vram, width=16):
    """The 16x16 sprite patterns at 0x1800, on one sheet."""
    total = 0x800 // 32
    height = (total + width - 1) // width
    img = Image.new("RGB", (width * 17 + 1, height * 17 + 1), (24, 24, 32))
    scale = 3
    px = img.load()
    for n in range(total):
        ox = 1 + (n % width) * 17
        oy = 1 + (n // width) * 17
        base = SPRITES + n * 32
        for half in range(2):
            for row in range(16):
                b = vram[(base + half * 16 + row) & 0x3FFF]
                for bit in range(8):
                    if b & (0x80 >> bit):
                        px[ox + half * 8 + bit, oy + row] = (255, 255, 255)
    return img.resize((img.width * scale, img.height * scale), Image.NEAREST)


# ------------------------------------------------------------- fixed screens

def write_characters(rom, vram, bank, stream, erase=False):
    """write_characters (0x4998): loose captions in the name table."""
    p = stream
    while True:
        vp = read(rom, bank, p) | (read(rom, bank, p + 1) << 8)
        p += 2
        while True:
            b = read(rom, bank, p)
            p += 1
            if b == 0xFF:
                return
            if b == 0xFE:
                break
            vram[vp & 0x3FFF] = 0 if erase else b
            vp += 1


def high_score_screen(rom):
    """build_high_score_screen (0x5BF8), with banks 9 and 10."""
    vram = bytearray(0x4000)
    layout = {0x6000: 1, 0x8000: 9, 0xA000: 10}
    for dest, source in ((0x2008, 0x8300), (0x2808, 0x87FA), (0x3008, 0x8CB2),
                         (0x0008, 0x917E), (0x0808, 0x9515), (0x1008, 0x989F)):
        decompress(rom, vram, 9, source, dest)
    for dest, source in ((0x2780, 0xA758), (0x0780, 0xA783)):
        for third in range(3):
            decompress(rom, vram, 10, source, dest + third * 0x800)
    decompress(rom, vram, 10, 0xA7A4, SPRITES)
    # The name table is NOT compressed: 768 characters from bank 9 (0x5C63).
    for n in range(0x300):
        vram[0x3800 + n] = read(rom, 9, 0x8000 + n)
    light_the_stars(vram)
    return vram, layout


def scoreboard_screen(rom):
    """The other batch of graphics from bank 10 (p00:0x4B0A)."""
    vram = bytearray(0x4000)
    for dest, source in ((0x2418, 0xA0DB), (0x0418, 0xA3F4)):
        for third in range(3):
            decompress(rom, vram, 10, source, dest + third * 0x800)
    decompress(rom, vram, 10, 0xA683, SPRITES)
    # The captions: the stream at 0x4FB2, which 0x4B39 hands to
    # write_characters.
    write_characters(rom, vram, 0, 0x4FB2)
    light_the_stars(vram)
    return vram


def title_screen(rom, japanese=False):
    """build_title_screen (0x5B31) and write_title_panel
    (0x5B77), with banks 9 and 10 in place.

    The logo is here, and the cartridge carries BOTH: it reads the machine's
    character set at 0x002B of the BIOS and, with the low nibble at zero
    (Japanese machine), writes the panel at 0x9BCB, which says GRADIUS;
    with anything else the one at 0x9B3F, which says NEMESIS. Same binary.
    """
    vram = bytearray(0x4000)
    for dest, source in ((0x2468, 0x9C57), (0x0468, 0x9EAB)):
        for third in range(3):
            decompress(rom, vram, 9, source, dest + third * 0x800)
    # The panel: five rows of 28 characters from 0x3882, that is row 4,
    # column 2. It crosses the boundary of the first third, and that is why
    # the patterns are decompressed into all three.
    panel = 0x9BCB if japanese else 0x9B3F
    for row in range(5):
        for col in range(28):
            vram[0x3882 + row * 32 + col] = read(rom, 9, panel + row * 28 + col)
    return vram


def draw_logo(vram, scale=3):
    """Only the logo panel: 28 x 5 characters from row 4."""
    img = draw_screen(vram).crop((2 * 8, 4 * 8, 30 * 8, 9 * 8))
    return img.resize((img.width * scale, img.height * scale), Image.NEAREST)


# ------------------------------------------------------------------ main

def save(img, name):
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, name)
    img.save(path)
    print("  %-28s %d x %d" % (name, img.width, img.height))


def make_maps(rom):
    print("Stage maps (drawn column by column from the script):")
    for stage in range(1, 13):
        vram = stage_characters(rom, stage)
        rows = stage_map(rom, stage)
        save(draw_map(vram, rows), "stage%02d_map.png" % stage)


def make_screens(rom):
    print("Fixed screens:")
    vram, _ = high_score_screen(rom)
    save(draw_screen(vram), "intro.png")
    save(draw_screen(title_screen(rom)), "title.png")
    save(draw_logo(title_screen(rom)), "logo.png")
    save(draw_logo(title_screen(rom, japanese=True)),
         "logo_gradius.png")
    vram2 = scoreboard_screen(rom)
    save(draw_character_set(vram2), "ending_characters.png")
    save(draw_character_set(stage_characters(rom, 1)),
         "stage01_characters.png")


def make_sprites(rom):
    print("Sprite sheet:")
    vram = stage_characters(rom, 1)
    save(draw_sprite_sheet(vram), "sprites.png")


def main():
    rom = load_rom()
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    if what in ("all", "maps"):
        make_maps(rom)
    if what in ("all", "screens"):
        make_screens(rom)
    if what in ("all", "sprites"):
        make_sprites(rom)
    return 0


if __name__ == "__main__":
    sys.exit(main())

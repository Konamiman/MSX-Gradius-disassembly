#!/usr/bin/env python3
"""Extracts the mark Konami hid at the end of some MSX cartridges.

The discovery is not ours: it was uncovered by Manuel Pazos (@ManuelPazosMSX)
in September 2021. Thanks to him we know we have to look there.

Behind the 0xFF filler, reading towards the end of the file:

    [title, N bytes, IN REVERSE ORDER]  [N]  [the last two digits of the RC
    number in BCD]  [0xAA]

The title is in katakana with the house encoding: index = byte - 0x80, and
indices 0 to 44 are the gojuon in plain order, without ヲ. 0x00 is a space.
DIGITS, on the other hand, are in plain ASCII: this happens in cartridges
RC-733, RC-737 and RC-735, whose titles end in a number.

IN A MEGAROM IT IS NOT AT THE END OF THE FILE. In a 16 or 32 KB cartridge the
mark falls in the last bytes of the image, and skipping the 0xFF filler from
the end is enough. In a MegaROM it can be at the end of ANY bank (with tens
of KB more data behind it), so searching from the end of the file does not
find it. That is why here we try the end of the file AND the end of every
8 KB and 16 KB chunk.

Usage: konami_mark.py <rom> [<rom> ...]
Exits with 1 if none of the ROMs carries a mark.
"""
import os
import sys

# The gojuon in plain order, which is the order in which Konami numbered the
# characters.
KANA = ("A I U E O KA KI KU KE KO SA SI SU SE SO TA TI TU TE TO "
        "NA NI NU NE NO HA HI HU HE HO MA MI MU ME MO YA YU YO "
        "RA RI RU RE RO WA N").split()
# The small kana and the signs come after the 45 basic ones, from 49 onwards.
# Each one has been WORKED OUT from an already known mark in the series, not
# assumed from the order of the syllabary (which they do not follow). The
# cartridges are cited by catalogue number, which is how they appear inside
# the mark itself:
#
#   49 ya   RC-728  MO HI o RE N SI " [49] [58]        -> モピレンジャー
#   50 yu   RC-724  YA KI [50] U                       -> ヤキュウ
#   52 i    RC-742  KU " RA TE " [52] U SU             -> グラディウス
#   54 a    RC-730  RO [58] TO " _ HU [54] I TA [58]   -> ロードファイター
#   57 .    RC-725  I [58] [57] A RU [57] KA N HU [58] -> イー・アル・カンフー
#   58 -    the three above at once (long vowel mark)
#
# The other four were already known: 51 yo, 53 tsu, 55 dakuten, 56 handakuten.
EXTRA = {49: "ya", 50: "yu", 51: "yo", 52: "i", 53: "tsu", 54: "a",
         55: '"', 56: "o", 57: ".", 58: "-"}


def character(v):
    if v == 0:
        return " "
    if 0x30 <= v <= 0x39:       # digits are in ASCII, not in the house encoding
        return chr(v)
    i = v - 0x80
    if 0 <= i < len(KANA):
        return KANA[i]
    if i in EXTRA:
        return EXTRA[i]
    return "<%02X>" % v


def mark(rom, end=None):
    """(rc, how many, title already the right way round) or None if absent.

    `end` is where looking backwards starts: by default, the end of the file.
    In a MegaROM the end of each bank has to be tried as well.
    """
    i = (len(rom) if end is None else end) - 1
    while i > 0 and rom[i] == 0xFF:
        i -= 1
    if i < 3 or rom[i] != 0xAA:
        return None
    rc, n = rom[i - 1], rom[i - 2]
    if n == 0 or n > i - 2:
        return None
    return rc, n, bytes(reversed(rom[i - 2 - n:i - 2]))


def find(rom):
    """Every place where the mark appears: (where it ends, rc, n, title)."""
    out = []
    ends = [len(rom)]
    for size in (0x2000, 0x4000):
        ends += list(range(size, len(rom) + 1, size))
    for end in sorted(set(ends)):
        m = mark(rom, end)
        if m and all(m != (r, n, t) for _f, r, n, t in out):
            out.append((end, m[0], m[1], m[2]))
    return out


def main():
    any_found = False
    for fn in sys.argv[1:]:
        rom = open(fn, "rb").read()
        name = os.path.basename(fn)
        found = find(rom)
        if not found:
            print("  %-48s no mark" % name[:48])
            continue
        any_found = True
        for end, rc, n, title in found:
            print("  %-48s RC-7%02X  %d characters  (ends at offset %#07x, "
                  "bank %d)" % (name[:48], rc, n, end - 1, (end - 1) // 0x2000))
            print("  %-48s %s" % ("", " ".join(character(v) for v in title)))
    sys.exit(0 if any_found else 1)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""The compressed format Nemesis uses to put its graphics into VRAM.

The routine that reads it is 0x49B9 in bank 0, and it is written the opposite
way to what one would expect: bit 7 marks the literal copy, not the repeat.

    49B9  call 0x494A        sets the VRAM write address (HL)
    49BC  ld a,(de)          command byte
          and a / ret z      0x00 -> done
          ld b,a / and 0x7F / cp b
          jr z, repeat       bit 7 at ZERO -> repeat
          and a / jr z, jump     0x80 -> move to another place in VRAM
    literal (bit 7 at one): copies (command AND 0x7F) bytes as they are
    repeat  (bit 7 at zero): outputs the byte that follows (command) times
    jump    (command 0x80): the next two bytes are the new VRAM address, and
                            reading continues

That is, in the order the commands appear:

    0x00        end of block
    0x01..0x7F  N times the next byte            (2 stream bytes)
    0x80        new VRAM address                 (3 stream bytes)
    0x81..0xFF  N-0x80 literal bytes             (1+N-0x80 stream bytes)

With this the size of each block is not estimated: it is counted. That is
what allows declaring the graphics ranges with the D directive without
leaving out a byte or eating into the next one.

Usage:
    rle.py <rom> measure <bank> <address>    size and where it goes
    rle.py <rom> dump <bank> <address>       also, the bytes it writes
"""
import sys

from banks import ORG, BANK_SIZE, bank_name

END, REPEAT, JUMP, LITERAL = "end", "repeat", "jump", "literal"


def decompress(rom, bank, address, limit=None):
    """Returns (stream_bytes, writes, commands).

    writes: list of (vram_address, bytes) in the order they come out.
    commands: list of (relative_offset, kind, n) so they can be inspected.
    """
    base = bank * BANK_SIZE
    org = ORG[bank]
    if not org <= address < org + BANK_SIZE:
        raise SystemExit("0x%04X does not fall in bank %d (org %#06x)"
                         % (address, bank, org))
    limit = limit if limit is not None else BANK_SIZE
    i = address - org
    vram = None
    writes, commands = [], []
    start = i
    while i < limit:
        command = rom[base + i]
        rel = i - start
        i += 1
        if command == 0x00:
            commands.append((rel, END, 0))
            break
        if command == 0x80:
            if i + 1 >= limit:
                break
            vram = rom[base + i] | (rom[base + i + 1] << 8)
            i += 2
            commands.append((rel, JUMP, vram))
            continue
        if command & 0x80:
            n = command & 0x7F
            chunk = rom[base + i:base + i + n]
            i += n
            commands.append((rel, LITERAL, n))
            writes.append((vram, bytes(chunk)))
        else:
            n = command
            if i >= limit:
                break
            chunk = bytes([rom[base + i]]) * n
            i += 1
            commands.append((rel, REPEAT, n))
            writes.append((vram, chunk))
    return i - start, writes, commands


def chain(rom, bank, start, end):
    """Blocks placed one right after another, from start to end.

    The chain fitting with no slack is the proof that the format has been
    read correctly: a single byte too many or too few and the next block
    starts where it should not, and everything after it falls apart.
    """
    out = []
    a = start
    limit = end - ORG[bank]
    while a < end:
        n, wr, cmds = decompress(rom, bank, a, limit)
        if n <= 0:
            break
        output = sum(len(t) for _v, t in wr)
        dest = next((v for v, _t in wr if v is not None), None)
        out.append((a, n, output, dest))
        a += n
    return out, a


def main():
    rom = open(sys.argv[1], "rb").read()
    mode = sys.argv[2]
    if mode == "chain":
        bank = int(sys.argv[3], 0)
        blocks, end = chain(rom, bank, int(sys.argv[4], 0),
                            int(sys.argv[5], 0))
        for a, n, output, dest in blocks:
            print("  D 0x%04X 0x%04X   %d stream bytes -> %d in VRAM%s"
                  % (a, a + n, n, output,
                     ("  (first destination %#06x)" % dest) if dest else ""))
        print("  the chain ends at 0x%04X (%d blocks)" % (end, len(blocks)))
        return 0
    bank = int(sys.argv[3], 0)
    address = int(sys.argv[4], 0)
    n, writes, commands = decompress(rom, bank, address)
    output = sum(len(t) for _v, t in writes)
    print("%s 0x%04X..0x%04X  %d stream bytes -> %d bytes in VRAM  "
          "(%d commands)" % (bank_name(bank), address, address + n - 1, n,
                             output, len(commands)))
    dests = [v for v, _t in writes if v is not None]
    if dests:
        print("   first VRAM address: %#06x" % dests[0])
    for rel, kind, k in commands:
        if kind == JUMP:
            print("   +%04X  changes the VRAM address to %#06x" % (rel, k))
    if mode == "dump":
        for v, t in writes:
            print("   VRAM %s: %s" % (
                "%#06x" % v if v is not None else "  ?   ",
                " ".join("%02x" % c for c in t[:24])))
    return 0


if __name__ == "__main__":
    sys.exit(main())

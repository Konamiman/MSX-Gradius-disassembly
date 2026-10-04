#!/usr/bin/env python3
"""ROM survey: header, mapper, and the bank -> org rule.

What it measures, on the bytes of the ROM and without executing anything:

  1. The "AB" header and the INIT of bank 0 (and whether any other bank has
     one).
  2. All the `ld (nn),a` writes to the mapper registers. The SEVEN candidates
     are checked: the four of the Konami WITH SCC (0x5000, 0x7000, 0x9000,
     0xB000) and the three of the Konami WITHOUT SCC (0x6000, 0x8000,
     0xA000). The first ones coming out at zero is what decides that this
     cartridge is Konami4.
  3. The value each write carries (the immediate `ld a,N` just before, or the
     chained `inc a` of the three-way assignment) and whether that bank can
     go in that slot according to tools/banks.py. This is where the rule is
     checked, not assumed.
  4. The banks no register touches, and the ones that are 0xFF from end to
     end.

Exit code 1 if any write contradicts the rule, if a write to an SCC register
appears, or if the header is not the expected one.

Usage: recon.py <rom>
"""
import sys

from bank_tracer import BASE_LEN, ED_LEN4, IDX_DISP, KEEPS_A, ED_CHANGES_A
from banks import ORG, BANK_SIZE, N_BANKS, bank_name

SCC = (0x5000, 0x7000, 0x9000, 0xB000)
K4 = (0x6000, 0x8000, 0xA000)


def address(i):
    """(bank, execution address) of offset i of the ROM."""
    p = i // BANK_SIZE
    return p, ORG[p] + (i % BANK_SIZE)


def writes(d, reg):
    """Offsets of every `ld (reg),a` (32 lo hi) in the cartridge."""
    lo, hi = reg & 0xFF, reg >> 8
    return [i for i in range(len(d) - 2)
            if d[i] == 0x32 and d[i + 1] == lo and d[i + 2] == hi]


def touches_a(d, pc):
    """Whether the instruction at pc writes to the accumulator."""
    op = d[pc]
    if op == 0xCB:
        o2 = d[pc + 1]
        return False if 0x40 <= o2 < 0x80 else (o2 & 7) == 7
    if op == 0xED:
        return d[pc + 1] in ED_CHANGES_A
    if op in (0xDD, 0xFD):
        o2 = d[pc + 1]
        return False if o2 == 0xCB else o2 not in KEEPS_A
    return op not in KEEPS_A


def value(d, i):
    """Which bank the write at offset i carries, if it can be known by reading.

    Two forms, both seen in this cartridge:
      - `ld a,N` right before;
      - the three-way assignment, which chains `inc a` between writes:
        `ld a,N / ld (0x6000),a / ld (hl),a / inc a / ld (0x8000),a /
        inc hl / ld (hl),a / inc a / ld (0xA000),a`.

    It looks for the NEAREST `ld a,N` behind from which DECODING FORWARDS
    lands exactly on the write, and counts the `inc a` along the way. Going
    backwards byte by byte does not work: the 0x3E of an `ld a,N` also shows
    up as an operand of other instructions.

    Returns (bank, how) or (None, reason).
    """
    for start in range(i - 1, max(-1, i - 21), -1):
        if d[start] != 0x3E:
            continue
        pc, incs, broken = start, 0, False
        while pc < i:
            op = d[pc]
            if pc > start and op == 0x3C:
                incs += 1
            elif pc > start and touches_a(d, pc):
                broken = True                # something overwrites A on the way
                break
            n = BASE_LEN[op]
            if op == 0xCB:
                n = 2
            elif op == 0xED:
                n = 4 if d[pc + 1] in ED_LEN4 else 2
            elif op in (0xDD, 0xFD):
                o2 = d[pc + 1]
                n = 1 if o2 in (0xDD, 0xFD, 0xED) else (
                    4 if o2 == 0xCB else
                    1 + BASE_LEN[o2] + (1 if o2 in IDX_DISP else 0))
            pc += n
        if not broken and pc == i:
            return (d[start + 1] + incs) & 0xFF, (
                "ld a,%d" % d[start + 1] if not incs
                else "ld a,%d and %d inc a" % (d[start + 1], incs))
    if i >= 3 and d[i - 3] == 0x3A:
        return None, "ld a,(%#06x): reads back the RAM copy" % (
            d[i - 2] | (d[i - 1] << 8))
    return None, "A computed (%s)" % d[max(0, i - 5):i].hex(" ")


def main(rom):
    d = open(rom, "rb").read()
    failures = 0
    print("ROM: %d bytes, %d banks of %d" % (len(d), len(d) // BANK_SIZE,
                                              BANK_SIZE))

    init = d[2] | (d[3] << 8)
    print("header: %s INIT=%#06x STATEMENT=%#06x DEVICE=%#06x TEXT=%#06x" % (
        d[0:2], init, d[4] | (d[5] << 8), d[6] | (d[7] << 8), d[8] | (d[9] << 8)))
    if d[0:2] != b"AB":
        print("  FAIL: bank 0 does not start with AB")
        failures += 1
    for p in range(1, N_BANKS):
        if d[p * BANK_SIZE:p * BANK_SIZE + 2] == b"AB":
            print("  (bank %d also carries AB)" % p)

    print("\nmapper registers WITH SCC (Konami5): they must be at zero")
    for reg in SCC:
        n = len(writes(d, reg))
        print("  %#06x: %d writes" % (reg, n))
        if n:
            print("  FAIL: something writes to %#06x; this is not a Konami4"
                  % reg)
            failures += 1

    print("\nmapper registers WITHOUT SCC (Konami4)")
    used = set()
    for reg in K4:
        sites = writes(d, reg)
        print("  %#06x: %d writes" % (reg, len(sites)))
        for i in sites:
            p, a = address(i)
            bank, how = value(d, i)
            if bank is None:
                print("      %s:%04X  bank ?  (%s)" % (bank_name(p), a, how))
                continue
            used.add(bank)
            ok = bank < N_BANKS and ORG[bank] == reg
            print("      %s:%04X  bank %-2d (%s)  %s" % (
                bank_name(p), a, bank, how,
                "ok" if ok else "CONTRADICTS the rule: %s goes to %#06x"
                % (bank_name(bank), ORG.get(bank, 0))))
            if not ok:
                failures += 1

    print("\nbanks that NO write selects: %s"
          % " ".join(bank_name(p) for p in range(1, N_BANKS) if p not in used))
    empty = [p for p in range(N_BANKS)
              if set(d[p * BANK_SIZE:(p + 1) * BANK_SIZE]) == {0xFF}]
    print("banks that are 0xFF from end to end: %s"
          % " ".join(bank_name(p) for p in empty))

    print()
    if failures:
        print("FAIL: %d contradictions with the bank -> org rule" % failures)
        return 1
    print("OK: every write follows the bank -> org rule of "
          "tools/banks.py")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))

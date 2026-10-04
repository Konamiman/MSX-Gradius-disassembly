#!/usr/bin/env python3
"""The bank -> address rule of the MegaROM, shared by all the tools.

Nemesis / Gradius is a 128 KB cartridge with the Konami mapper WITHOUT SCC
(Konami4): 16 banks of 8 KB. The bank at 0x4000-0x5FFF is FIXED (there is no
register for it) and the other three are selected by writing the bank number
to 0x6000 (for 0x6000-0x7FFF), 0x8000 (for 0x8000-0x9FFF) and 0xA000 (for
0xA000-0xBFFF).

What the ROM says (tools/recon.py measures it again every time):
  - There is NOT a single write to 0x5000, 0x7000, 0x9000 or 0xB000, which
    are the registers of Konami's OTHER mapper, the one with SCC. That is why
    this is Konami4 and not Konami5.
  - The three writes that start at INIT (0x4071) hand out 1/2/3 and record
    them in the RAM trio 0xF0F1..0xF0F3; the same routine, with A=4, hands out
    4/5/6. The standalone writes to 0x8000 only carry 2, 5, 7, 9 and 11; the
    standalone writes to 0xA000 only carry 3, 6, 8, 10 and 12.

  That gives the table below: each bank has ONE single address where it
  executes.

        bank 0                -> 0x4000  (fixed, no register)
        banks 1, 4            -> 0x6000
        banks 2, 5, 7, 9, 11  -> 0x8000
        banks 3, 6, 8, 10, 12 -> 0xA000

  Banks 6, 13, 14 and 15 are 8192 bytes of 0xFF: filler up to the 128 KB.
  Bank 6 is really mapped (the 4/5/6 routine puts it at 0xA000), although
  whatever ends up there is never read; nobody selects 13, 14 and 15, and
  their org is a CONVENTION of ours (0x8000) so they can be listed the same
  way.

  If a bank ever shows up mapped in another slot, this rule stops being valid
  for THAT bank and it will have to be split into two modules.

Usage as a program:
    banks.py org <n>               prints the org of bank n
    banks.py list                  prints "n org" for all 16
    banks.py split <rom> <dir>     writes <dir>/pNN.bin with each bank
"""
import os
import sys

BANK_SIZE = 0x2000
N_BANKS = 16

# bank -> execution address. Measured, not assumed: see recon.py.
ORG = {
    0: 0x4000,
    1: 0x6000, 4: 0x6000,
    2: 0x8000, 5: 0x8000, 7: 0x8000, 9: 0x8000, 11: 0x8000,
    3: 0xA000, 6: 0xA000, 8: 0xA000, 10: 0xA000, 12: 0xA000,
    # Nobody ever selects these (they are 0xFF end to end). Conventional org.
    13: 0x8000, 14: 0x8000, 15: 0x8000,
}

# The banks no mapper register touches and that are also all 0xFF.
NEVER_MAPPED = (13, 14, 15)


def org(p):
    """Address at which bank p executes."""
    return ORG[p]


def bank_name(p):
    """Name of the module of bank p: p00..p15."""
    return "p%02d" % p


def main(argv):
    if len(argv) < 2:
        sys.exit(__doc__)
    if argv[1] == "org":
        print("%#06x" % org(int(argv[2], 10)))
    elif argv[1] == "list":
        for p in range(N_BANKS):
            print("%d %#06x" % (p, org(p)))
    elif argv[1] == "split":
        rom, dst = argv[2], argv[3]
        d = open(rom, "rb").read()
        if len(d) != BANK_SIZE * N_BANKS:
            sys.exit("the ROM is %d bytes long, not %d" % (len(d), BANK_SIZE * N_BANKS))
        os.makedirs(dst, exist_ok=True)
        for p in range(N_BANKS):
            with open(os.path.join(dst, bank_name(p) + ".bin"), "wb") as f:
                f.write(d[p * BANK_SIZE:(p + 1) * BANK_SIZE])
        print("16 banks of %d bytes in %s/" % (BANK_SIZE, dst))
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv)

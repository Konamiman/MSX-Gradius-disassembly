#!/usr/bin/env python3
"""WHOLE-CARTRIDGE tracer: follows the flow jumping from bank to bank.

Why it is needed, and why tracing each bank separately is not enough: in a
MegaROM the address 0x8123 means nothing on its own. Depending on the last
thing written to the 0x8000 register, bank 2, 5, 7, 9 or 11 may be there. A
tracer that looks at one bank in isolation stops as soon as the code leaves
its 8 KB, and every destination has to be given to it by hand.

This tracer keeps track of which bank is in each slot. Nemesis ALWAYS
switches banks inline (`di / ld a,N / ld (0x8000),a / ld (0xF0F2),a / ei`,
never through a routine), so following the accumulator is enough. What is
propagated along each path is:

    (pc, bank at 0x6000/0x8000/0xA000, RAM copy at 0xF0F1..3, A, HL)

The RAM copy is needed because the interrupt (0x4028) puts in banks 7 and 8
WITHOUT touching it and then restores them by reading it: without keeping
track of it, the tracer stays with bank 7 in place and keeps reading the
cartridge in the wrong place.

THE DISPATCHER TABLES. Konami places the destination table RIGHT AFTER the
`call 0x4067`, so the flow does not continue at the next instruction and the
number of words has to be guessed. The "up to the lowest destination"
criterion alone overshoots: at p01:607B it would give 72 words when there are
4. Here the size comes from TWO limits at once (the lowest destination, and
the first byte that is ALREADY known to be code by another path) and is
recalculated over several passes until it stops moving. Each pass can only
SHORTEN tables, never lengthen them, so contamination does not feed back on
itself. Whatever remains wrong is set by hand in src/tables.txt.

This is NOT the tracer that generates the listing (that is done by
tools/z80trace.py bank by bank, with the entries already written and
justified in src/pNN.entries). This is the one that FINDS OUT those entries.

Usage:
    bank_tracer.py <rom> report [src_dir]     coverage, blind spots, unresolved
    bank_tracer.py <rom> entries [src_dir]    the seeds per bank, with their reason
    bank_tracer.py <rom> tables [src_dir]     the tables of the 0x4067 dispatcher
    bank_tracer.py <rom> nocode [src_dir]     the tables in .nocode format
    bank_tracer.py <rom> write [src_dir]      writes src_dir/pNN.entries and .nocode
"""
import os
import sys
from collections import defaultdict

from banks import ORG, BANK_SIZE, N_BANKS, bank_name

# ---------------------------------------------------------------- Z80 tables
BASE_LEN = [1] * 256
for _op, _n in {
    0x01: 3, 0x11: 3, 0x21: 3, 0x31: 3,
    0x22: 3, 0x2A: 3, 0x32: 3, 0x3A: 3,
    0x06: 2, 0x0E: 2, 0x16: 2, 0x1E: 2,
    0x26: 2, 0x2E: 2, 0x36: 2, 0x3E: 2,
    0x10: 2, 0x18: 2, 0x20: 2, 0x28: 2, 0x30: 2, 0x38: 2,
    0xC6: 2, 0xCE: 2, 0xD6: 2, 0xDE: 2,
    0xE6: 2, 0xEE: 2, 0xF6: 2, 0xFE: 2,
    0xD3: 2, 0xDB: 2,
    0xC2: 3, 0xC3: 3, 0xC4: 3, 0xCA: 3, 0xCC: 3, 0xCD: 3,
    0xD2: 3, 0xD4: 3, 0xDA: 3, 0xDC: 3,
    0xE2: 3, 0xE4: 3, 0xEA: 3, 0xEC: 3,
    0xF2: 3, 0xF4: 3, 0xFA: 3, 0xFC: 3,
}.items():
    BASE_LEN[_op] = _n

ED_LEN4 = {0x43, 0x53, 0x63, 0x73, 0x4B, 0x5B, 0x6B, 0x7B}
IDX_DISP = ({0x34, 0x35, 0x36}
            | {0x46, 0x4E, 0x56, 0x5E, 0x66, 0x6E, 0x7E}
            | {0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77}
            | {0x86, 0x8E, 0x96, 0x9E, 0xA6, 0xAE, 0xB6, 0xBE})
JP_CC = {0xC2, 0xCA, 0xD2, 0xDA, 0xE2, 0xEA, 0xF2, 0xFA}
CALL_CC = {0xC4, 0xCC, 0xD4, 0xDC, 0xE4, 0xEC, 0xF4, 0xFC}
JR_CC = {0x20, 0x28, 0x30, 0x38}
RST = {0xC7, 0xCF, 0xD7, 0xDF, 0xE7, 0xEF, 0xF7, 0xFF}

# One-byte opcodes that do NOT touch the accumulator. Anything not here is
# given up for lost (A becomes "unknown"): getting it wrong on that side only
# leaves a bank switch unresolved, and that shows up in the report; getting it
# wrong on the other side would invent a bank, which is exactly what must not
# happen.
KEEPS_A = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x09, 0x0B, 0x0C, 0x0D,
             0x0E, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x18, 0x19, 0x1B,
             0x1C, 0x1D, 0x1E, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x28,
             0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x30, 0x31, 0x32, 0x33, 0x34,
             0x35, 0x36, 0x37, 0x38, 0x39, 0x3B, 0x3F}
KEEPS_A |= set(range(0x40, 0x78))          # ld r,r' with a destination other than A
KEEPS_A |= set(range(0xB8, 0xC0))          # cp r
KEEPS_A |= {0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC7, 0xC8, 0xC9, 0xCA,
              0xCC, 0xCD, 0xCF,
              0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD7, 0xD8, 0xD9, 0xDA,
              0xDC, 0xDF,
              0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE7, 0xE8, 0xE9, 0xEA,
              0xEB, 0xEC, 0xEF,
              0xF0, 0xF2, 0xF3, 0xF4, 0xF5, 0xF7, 0xF8, 0xF9, 0xFA, 0xFB,
              0xFC, 0xFE, 0xFF}
ED_CHANGES_A = {0x44, 0x4C, 0x54, 0x5C, 0x64, 0x6C, 0x74, 0x7C,   # neg and its aliases
             0x57, 0x5F, 0x67, 0x6F, 0x78}

# The same for HL, which is needed to see the `ld (hl),a` with which INIT
# notes down in RAM which bank it has put in each slot.
TOUCHES_HL = {0x09, 0x19, 0x21, 0x23, 0x24, 0x25, 0x26, 0x29, 0x2A, 0x2B, 0x2C,
           0x2D, 0x2E, 0x39, 0xD9, 0xE1, 0xE3, 0xEB}
TOUCHES_DE = {0x11, 0x13, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x14, 0x15, 0x16, 0xD1,
           0xD9, 0xEB}
TOUCHES_DE |= set(range(0x50, 0x60))            # ld d,r / ld e,r
ED_TOUCHES_DE = {0x5B}
ED_TOUCHES_DE |= set(range(0xA0, 0xC0))         # ldir and friends move DE
TOUCHES_HL |= set(range(0x60, 0x70))            # ld h,r / ld l,r
ED_TOUCHES_HL = {0x42, 0x52, 0x62, 0x72, 0x4A, 0x5A, 0x6A, 0x7A, 0x6B}
ED_TOUCHES_HL |= set(range(0xA0, 0xC0))         # ldir, cpir, ...

# Konami's dispatcher: `pop hl / add a,a / hl+=a / ld e,(hl) / inc hl /
# ld d,(hl) / ex de,hl / jp (hl)`.
DISPATCHER = 0x4067
# The RAM copy of the three mapper registers.
SHADOW = {0xF0F1: 0, 0xF0F2: 1, 0xF0F3: 2}
SLOT_REG = {0x6000: 0, 0x8000: 1, 0xA000: 2}


class Cartridge:
    """The 128 KB with the mapper set: reading a byte requires the slots."""

    def __init__(self, rom):
        self.rom = rom

    @staticmethod
    def bank(addr, s):
        if 0x4000 <= addr < 0x6000:
            return 0
        if 0x6000 <= addr < 0x8000:
            return s[0]
        if 0x8000 <= addr < 0xA000:
            return s[1]
        if 0xA000 <= addr < 0xC000:
            return s[2]
        return None

    def read(self, addr, s):
        b = self.bank(addr, s)
        if b is None or b >= N_BANKS:
            return None
        return self.rom[b * BANK_SIZE + (addr & 0x1FFF)]


class BankTracer:
    def __init__(self, rom, table_sizes=None, no_tables=False):
        self.c = Cartridge(rom)
        self.rom = rom
        self.marked = [bytearray(BANK_SIZE) for _ in range(N_BANKS)]
        self.starts = set()                 # (bank, addr) instruction start
        self.entries = defaultdict(set)       # bank -> {addr}
        self.why = {}                       # (bank, addr) -> justification
        self.blind = set()                    # (bank, addr, kind)
        self.external = defaultdict(set)       # destination -> {(bank, addr)}
        self.unresolved = set()              # (bank, addr, register)
        self.switches = set()                   # (bank, addr, register, value)
        self.tables = {}                       # (bank, call) -> (tab, n, destinations)
        self.table_sizes = dict(table_sizes or {})
        self.no_tables = no_tables
        self.configs = set()                   # bank layouts seen
        self.split = set()                  # instructions straddling two banks
        self.calls = []                     # (destination, bank, pc, slots, HL, DE)
        self.layouts_of = defaultdict(set)      # (bank, pc) -> layouts it runs with
        self.seen = set()

    # ---------------------------------------------------------------- reading
    def byte(self, addr, s):
        return self.c.read(addr, s)

    def word(self, addr, s):
        lo, hi = self.byte(addr, s), self.byte(addr + 1, s)
        if lo is None or hi is None:
            return None
        return lo | (hi << 8)

    def ilen(self, addr, s):
        op = self.byte(addr, s)
        if op is None:
            return 0
        if op == 0xCB:
            return 2
        if op == 0xED:
            return 4 if self.byte(addr + 1, s) in ED_LEN4 else 2
        if op in (0xDD, 0xFD):
            o2 = self.byte(addr + 1, s)
            if o2 is None:
                return 0
            if o2 == 0xCB:
                return 4
            if o2 in (0xDD, 0xFD, 0xED):
                return 1
            return 1 + BASE_LEN[o2] + (1 if o2 in IDX_DISP else 0)
        return BASE_LEN[op]

    def touches_a(self, addr, s):
        op = self.byte(addr, s)
        if op == 0xCB:
            o2 = self.byte(addr + 1, s)
            if o2 is None or 0x40 <= o2 < 0x80:
                return o2 is None
            return (o2 & 7) == 7
        if op == 0xED:
            return self.byte(addr + 1, s) in ED_CHANGES_A
        if op in (0xDD, 0xFD):
            o2 = self.byte(addr + 1, s)
            if o2 is None:
                return True
            return False if o2 == 0xCB else o2 not in KEEPS_A
        return op not in KEEPS_A

    def touches_hl(self, addr, s):
        op = self.byte(addr, s)
        if op == 0xCB:
            o2 = self.byte(addr + 1, s)
            if o2 is None:
                return True
            if 0x40 <= o2 < 0x80:
                return False
            return (o2 & 7) in (4, 5)
        if op == 0xED:
            return self.byte(addr + 1, s) in ED_TOUCHES_HL
        if op in (0xDD, 0xFD):
            return self.byte(addr + 1, s) in (0x66, 0x6E)
        return op in TOUCHES_HL

    def touches_de(self, addr, s):
        op = self.byte(addr, s)
        if op == 0xCB:
            o2 = self.byte(addr + 1, s)
            if o2 is None:
                return True
            if 0x40 <= o2 < 0x80:
                return False
            return (o2 & 7) in (2, 3)
        if op == 0xED:
            return self.byte(addr + 1, s) in ED_TOUCHES_DE
        if op in (0xDD, 0xFD):
            return self.byte(addr + 1, s) in (0x56, 0x5E)
        return op in TOUCHES_DE

    # ---------------------------------------------------------------- tracing
    def trace(self, seeds):
        """semillas: list of (addr, (b6000, b8000, bA000), justification)."""
        stack = []
        for addr, s, just in seeds:
            s = tuple(s)
            b = self.c.bank(addr, s)
            if b is not None:
                self.entries[b].add(addr)
                self.why.setdefault((b, addr), just)
            stack.append((addr, s, s, None, None, None))
        while stack:
            pc, s, shadow, a, hl, de = stack.pop()
            while True:
                b = self.c.bank(pc, s)
                if b is None or b >= N_BANKS:
                    break
                key = (pc, s, shadow)
                if key in self.seen:
                    break
                self.seen.add(key)
                self.configs.add(s)
                n = self.ilen(pc, s)
                if n == 0 or (pc & 0x1FFF) + n > BANK_SIZE:
                    if n:
                        self.split.add((b, pc, n))
                    break                      # instruction split across banks
                off = pc & 0x1FFF
                for i in range(n):
                    self.marked[b][off + i] = 1
                self.starts.add((b, pc))
                self.layouts_of[(b, pc)].add(s)
                op = self.byte(pc, s)
                nxt = pc + n
                stop = False

                # --- what happens to A
                if op == 0x3E:                                  # ld a,n
                    new_a = self.byte(pc + 1, s)
                elif op == 0x3C and a is not None:               # inc a
                    new_a = (a + 1) & 0xFF
                elif op == 0x3D and a is not None:               # dec a
                    new_a = (a - 1) & 0xFF
                elif op == 0xAF:                                 # xor a
                    new_a = 0
                elif op == 0x3A and self.word(pc + 1, s) in SHADOW:
                    new_a = shadow[SHADOW[self.word(pc + 1, s)]]
                elif not self.touches_a(pc, s):
                    new_a = a
                else:
                    new_a = None

                # --- what happens to HL
                if op == 0x21:                                   # ld hl,nn
                    new_hl = self.word(pc + 1, s)
                elif op == 0x23 and hl is not None:               # inc hl
                    new_hl = (hl + 1) & 0xFFFF
                elif op == 0x2B and hl is not None:               # dec hl
                    new_hl = (hl - 1) & 0xFFFF
                elif op == 0xEB:                                  # ex de,hl
                    new_hl = de
                elif not self.touches_hl(pc, s):
                    new_hl = hl
                else:
                    new_hl = None

                # --- what happens to DE
                if op == 0x11:                                   # ld de,nn
                    new_de = self.word(pc + 1, s)
                elif op == 0x13 and de is not None:               # inc de
                    new_de = (de + 1) & 0xFFFF
                elif op == 0x1B and de is not None:               # dec de
                    new_de = (de - 1) & 0xFFFF
                elif op == 0xEB:                                  # ex de,hl
                    new_de = hl
                elif not self.touches_de(pc, s):
                    new_de = de
                else:
                    new_de = None

                # --- writes to the mapper registers and to their RAM copy
                ld_target = None
                if op == 0x32:                                   # ld (nn),a
                    ld_target = self.word(pc + 1, s)
                elif op == 0x77 and hl is not None:               # ld (hl),a
                    ld_target = hl
                if ld_target in SLOT_REG:
                    k = SLOT_REG[ld_target]
                    if a is None:
                        self.unresolved.add((b, pc, ld_target))
                    else:
                        self.switches.add((b, pc, ld_target, a))
                        if a < N_BANKS:
                            s = tuple(a if j == k else s[j] for j in range(3))
                elif ld_target in SHADOW and a is not None:
                    k = SHADOW[ld_target]
                    shadow = tuple(a if j == k else shadow[j] for j in range(3))

                # --- flow
                if op == 0xC3:                                   # jp nn
                    self._go(self.word(pc + 1, s), s, shadow, stack, b, pc, "jp")
                    stop = True
                elif op in JP_CC:
                    self._go(self.word(pc + 1, s), s, shadow, stack, b, pc, "jp cc")
                elif op == 0xCD:                                 # call nn
                    t = self.word(pc + 1, s)
                    self.calls.append((t, b, pc, s, hl, de))
                    self._go(t, s, shadow, stack, b, pc, "call")
                    if t == DISPATCHER:
                        self._dispatch(b, pc, nxt, s, shadow, stack)
                        stop = True
                elif op in CALL_CC:
                    self._go(self.word(pc + 1, s), s, shadow, stack, b, pc, "call cc")
                elif op == 0x18:                                 # jr e
                    self._go(nxt + self._s8(self.byte(pc + 1, s)), s, shadow,
                             stack, b, pc, "jr")
                    stop = True
                elif op in JR_CC or op == 0x10:
                    self._go(nxt + self._s8(self.byte(pc + 1, s)), s, shadow,
                             stack, b, pc, "jr cc")
                elif op == 0xC9:
                    stop = True
                elif op == 0xE9:
                    self.blind.add((b, pc, "JP (HL)"))
                    stop = True
                elif op in (0xDD, 0xFD) and self.byte(pc + 1, s) == 0xE9:
                    self.blind.add((b, pc, "JP (IX/IY)"))
                    stop = True
                elif op == 0xED and self.byte(pc + 1, s) in (0x45, 0x4D):
                    stop = True

                if stop:
                    break
                # Code can FALL THROUGH from one bank into the next one:
                # 0x5FFF (bank 0) leads to 0x6000, and 0x9FFF to 0xA000. It
                # really happens in this cartridge (there is a loop split
                # between bank 0 and bank 1) and for the single-bank tracer
                # that is an entry point it cannot deduce.
                if (nxt & 0xE000) != (pc & 0xE000):
                    d = self.c.bank(nxt, s)
                    if d is not None and d < N_BANKS and nxt not in self.entries[d]:
                        self.entries[d].add(nxt)
                        self.why[(d, nxt)] = (
                            "%s:%04X falls through (the code crosses the "
                            "bank boundary)" % (bank_name(b), pc))
                pc, a, hl, de = nxt, new_a, new_hl, new_de

    def _dispatch(self, b, pc_call, tab, s, shadow, stack):
        """The word table placed right after a `call 0x4067`."""
        n = self.table_sizes.get((b, pc_call), 0)
        targets = []
        for k in range(n):
            w = self.word(tab + 2 * k, s)
            if w is None:
                break
            targets.append(w)
        self.tables[(b, pc_call)] = (tab, len(targets), targets, s)
        if self.no_tables:
            return
        for i, w in enumerate(targets):
            self._go(w, s, shadow, stack, b, pc_call,
                     "entry %d of the table at 0x%04X (call 0x4067 at 0x%04X)"
                     % (i, tab, pc_call))

    def _go(self, target, s, shadow, stack, b, pc, kind):
        if target is None:
            return
        d = self.c.bank(target, s)
        if d is None or d >= N_BANKS:
            self.external[target].add((b, pc))
            return
        if target not in self.entries[d]:
            self.entries[d].add(target)
            self.why[(d, target)] = "%s:%04X %s" % (bank_name(b), pc, kind)
        stack.append((target, s, shadow, None, None, None))

    @staticmethod
    def _s8(x):
        return x - 256 if x > 127 else x

    def coverage(self):
        return {p: sum(self.marked[p]) for p in range(N_BANKS)}


def dispatcher_sites(rom):
    """Every `call 0x4067` in the cartridge: (bank, execution address)."""
    out = []
    for i in range(len(rom) - 2):
        if rom[i] == 0xCD and rom[i + 1] == 0x67 and rom[i + 2] == 0x40:
            b = i // BANK_SIZE
            out.append((b, ORG[b] + (i % BANK_SIZE)))
    return out


def compute_sizes(rom, starts, sites, forced):
    """How many words the table of each `call 0x4067` has.

    Words are read ONE BY ONE as long as each one is a cartridge address
    (0x4000-0xBFFF), and the table is cut at the lowest destination seen so
    far AMONG THOSE THAT FALL IN THE SAME SLOT. The "same slot" part matters:
    there are tables that dispatch to another bank (the one at p00:5DFA sends
    almost all of its 31 entries to 0x8000 and 0xA000) and requiring the
    destination to be in the bank itself left them at zero. Taking the minimum
    of all the words up to the end of the slot in one go does not work: words
    read from code much further down slip in and the minimum comes out absurd
    (at p00:4AC7 it gave a single word out of the ten there are).

    It is also cut at the first byte that is ALREADY known to be code by
    another path, which is where the table must have ended.
    """
    sizes = {}
    for b, pc in sites:
        if (b, pc) in forced:
            sizes[(b, pc)] = forced[(b, pc)]
            continue
        tab = pc + 3
        base = tab & 0xE000
        bank_end = base + BANK_SIZE
        limit = bank_end
        for x in range(tab, bank_end):
            if (b, x) in starts:
                limit = x
                break
        n = 0
        while tab + 2 * n + 1 < limit:
            o = b * BANK_SIZE + ((tab + 2 * n) & 0x1FFF)
            w = rom[o] | (rom[o + 1] << 8)
            if not 0x4000 <= w < 0xC000:
                break                       # not even a cartridge address
            if tab < w < bank_end:
                limit = min(limit, w)     # only what falls in the slot shortens it
            n += 1
        sizes[(b, pc)] = n
    return sizes


def initial_seeds(rom):
    """The only two entry points that the hardware guarantees.

    - INIT from the "AB" header (0x4071): the BIOS calls it at boot. The
      first thing it does is lay out banks 1/2/3, so tracing it with that
      layout assumes nothing: the instruction itself sets it.
    - 0x4028: what INIT installs in the H.KEYI interrupt hook, with
      `ld a,0xC3 / ld (0xFD9A),a / ld hl,0x4028 / ld (0xFD9B),hl` (0x4095).
      The Z80 does not get there through any jump: the interrupt calls it.
    """
    init = rom[2] | (rom[3] << 8)
    return [(init, (1, 2, 3), "AB header: INIT"),
            (0x4028, (1, 2, 3),
             "H.KEYI interrupt hook: INIT writes 0xC3 to 0xFD9A and this"
             " address to 0xFD9B (p00:4095-p00:409D)")]


def load_tables(path):
    """Table sizes set by hand: 'pNN 0xCALL n  # why'."""
    out = {}
    if not path or not os.path.exists(path):
        return out
    for ln in open(path, encoding="utf-8"):
        p = ln.split("#")[0].split()
        if len(p) >= 3:
            out[(int(p[0][1:], 10), int(p[1], 0))] = int(p[2], 0)
    return out


def load_extra(path):
    """Seeds by hand: 'pNN 0xADDR b6000 b8000 bA000  # why'."""
    out = []
    if not path or not os.path.exists(path):
        return out
    for ln in open(path, encoding="utf-8"):
        raw, _, comment = ln.partition("#")
        p = raw.split()
        if len(p) >= 5:
            out.append((int(p[1], 0),
                          (int(p[2], 0), int(p[3], 0), int(p[4], 0)),
                          comment.strip() or "by hand"))
    return out


def full_trace(rom, src, passes=8):
    """Traces, recalculates the table sizes and repeats until they settle."""
    forced = load_tables(os.path.join(src, "tables.txt"))
    extra = load_extra(os.path.join(src, "seeds.txt"))
    sites = dispatcher_sites(rom)

    # Pass 0: without following any table. Gives a clean code map.
    t = BankTracer(rom, table_sizes={}, no_tables=True)
    t.trace(initial_seeds(rom) + extra)
    sizes = compute_sizes(rom, t.starts, sites, forced)

    for _ in range(passes):
        t = BankTracer(rom, table_sizes=sizes)
        t.trace(initial_seeds(rom) + extra)
        n2 = compute_sizes(rom, t.starts, sites, forced)
        if n2 == sizes:
            break
        sizes = n2
    return t, sizes


ENTRIES_HEADER = """# Entry points of bank %d (runs at %#06x).
#
# Each one carries the instruction that justifies it. The ones that say
# "pNN:XXXX" come from ANOTHER bank: the single-page tracer cannot follow them,
# because at that address -depending on what is in the mapper register- there
# can be any of five banks. The ones that say "table" come from a table of the
# dispatcher 0x4067, which sits right after its `call` and is declared as data
# in the .nocode: the tracer cannot follow it either.
#
# Jumps and calls WITHIN the bank itself are not listed here:
# tools/z80trace.py finds them on its own, following the flow.
#
# This file is regenerated by `make seeds` (tools/bank_tracer.py write).
"""

NOCODE_HEADER = """# Areas that the tracer must NOT go into and disassemble as code.
#
# The target table of Konami's dispatcher (0x4067) sits RIGHT AFTER its
# `call`: without declaring it, the tracer runs straight on, eats it as
# instructions, and carries on from there. It is the easiest contamination
# in this cartridge.
#
# This file is regenerated by `make seeds` (tools/bank_tracer.py write).
"""


def write_files(t, src):
    """Writes src/pNN.entries and src/pNN.nocode with what has been found."""
    own = {}
    for p in range(N_BANKS):
        out = []
        for a in sorted(t.entries[p]):
            just = t.why.get((p, a), "?")
            from_other = just.startswith("p") and just[:3] != bank_name(p)
            from_table = "table" in just
            root = not just.startswith("p")
            if from_other or from_table or root:
                out.append((a, just))
        own[p] = out

    for p in range(N_BANKS):
        path = os.path.join(src, bank_name(p) + ".entries")
        with open(path, "w", encoding="utf-8") as f:
            f.write(ENTRIES_HEADER % (p, ORG[p]))
            if not own[p]:
                f.write("#\n# This bank does not hold a single byte of code that\n"
                        "# can be reached: it is all data (or 0xFF filler).\n")
            for a, just in own[p]:
                f.write("0x%04X   # %s\n" % (a, just))
        print("%s: %d entries" % (path, len(own[p])))

    by_bank = defaultdict(list)
    for (b, pc), (tab, n, dest, ss) in sorted(t.tables.items()):
        if n:
            by_bank[b].append((tab, tab + 2 * n, pc, n))
    for p in range(N_BANKS):
        path = os.path.join(src, bank_name(p) + ".nocode")
        with open(path, "w", encoding="utf-8") as f:
            f.write(NOCODE_HEADER)
            for tab, end, pc, n in sorted(by_bank.get(p, [])):
                f.write("0x%04X 0x%04X   dispatcher table of %d words "
                        "(call 0x4067 at 0x%04X)\n" % (tab, end, n, pc))
        print("%s: %d tables" % (path, len(by_bank.get(p, []))))



def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    rom = open(sys.argv[1], "rb").read()
    mode = sys.argv[2]
    here = os.path.dirname(os.path.abspath(__file__))
    src = sys.argv[3] if len(sys.argv) > 3 else os.path.join(here, "..", "src")
    t, sizes = full_trace(rom, src)

    if mode == "report":
        cov = t.coverage()
        total = sum(cov.values())
        print("coverage of the whole-cartridge trace")
        for p in range(N_BANKS):
            print("  %s org %#06x  %5d / %d bytes  %5.1f %%  %3d entries" % (
                bank_name(p), ORG[p], cov[p], BANK_SIZE,
                100.0 * cov[p] / BANK_SIZE, len(t.entries[p])))
        print("  TOTAL %d / %d bytes  %.1f %%" % (total, len(rom),
                                                  100.0 * total / len(rom)))
        print("\nbank layouts seen: %d" % len(t.configs))
        for s in sorted(t.configs):
            print("    0x6000=%-2d 0x8000=%-2d 0xA000=%d" % s)
        print("\nresolved bank switches: %d" % len(t.switches))
        print("UNRESOLVED bank switches (A unknown): %d"
              % len(t.unresolved))
        for b, pc, dst in sorted(t.unresolved):
            print("    %s:%04X -> ld (%#06x),a" % (bank_name(b), pc, dst))
        print("\ninstructions straddling two banks: %d" % len(t.split))
        for b, pc, n in sorted(t.split):
            print("    %s:%04X  %d bytes" % (bank_name(b), pc, n))
        print("\nindirect jumps (blind spots): %d" % len(t.blind))
        for b, pc, k in sorted(t.blind):
            print("    %s:%04X  %s" % (bank_name(b), pc, k))
        print("\ntargets outside the cartridge: %d" % len(t.external))
        for d in sorted(t.external):
            origins = sorted(t.external[d])[:4]
            print("    %04X  <- %s" % (d, " ".join("%s:%04X" % (bank_name(b), a)
                                                   for b, a in origins)))
    elif mode == "tables":
        for (b, pc), (tab, n, dest, s) in sorted(t.tables.items()):
            print("%s call 0x4067 at %04X: table %04X..%04X, %d words "
                  "(banks %s)" % (bank_name(b), pc, tab, tab + 2 * n - 1, n, s))
            for i, w in enumerate(dest):
                print("        [%2d] %04X" % (i, w))
    elif mode == "entries":
        for p in range(N_BANKS):
            if not t.entries[p]:
                continue
            print("# ---- %s (org %#06x) ----" % (bank_name(p), ORG[p]))
            for a in sorted(t.entries[p]):
                print("0x%04X   # %s" % (a, t.why.get((p, a), "?")))
    elif mode == "nocode":
        by_bank = defaultdict(list)
        for (b, pc), (tab, n, dest, s) in sorted(t.tables.items()):
            if n:
                by_bank[b].append((tab, tab + 2 * n, pc, n))
        for p in sorted(by_bank):
            print("# ---- %s ----" % bank_name(p))
            for tab, end, pc, n in sorted(by_bank[p]):
                print("0x%04X 0x%04X   dispatcher table of %d words "
                      "(call 0x4067 at 0x%04X)" % (tab, end, n, pc))
    elif mode == "gaps":
        rom_b = rom
        for p in range(N_BANKS):
            m = t.marked[p]
            o = ORG[p]
            start = None
            rows = []
            for i in range(BANK_SIZE + 1):
                v = m[i] if i < BANK_SIZE else 1
                if not v and start is None:
                    start = i
                elif v and start is not None:
                    rows.append((start, i))
                    start = None
            if not rows:
                continue
            print("# ---- %s (org %#06x): %d gaps, %d bytes ----" % (
                bank_name(p), o, len(rows), sum(b - a for a, b in rows)))
            for a, b in rows:
                chunk = rom_b[p * BANK_SIZE + a:p * BANK_SIZE + b]
                ff = sum(1 for c in chunk if c == 0xFF)
                zeros = sum(1 for c in chunk if c == 0)
                print("   %04X..%04X  %5d B   FF=%d 00=%d   %s" % (
                    o + a, o + b - 1, b - a, ff, zeros,
                    " ".join("%02x" % c for c in chunk[:12])))
    elif mode == "write":
        write_files(t, src)
    elif mode == "reads":
        # Who reads a data bank: instructions with an immediate that falls in
        # that bank's window AND that run with that bank in place. Without
        # the second condition the list is useless: at 0x8000 there are five
        # different banks depending on the moment.
        target_bank = int(sys.argv[4], 0)
        window = ORG[target_bank]
        slot = {0x4000: 0, 0x6000: 0, 0x8000: 1, 0xA000: 2}[window]
        print("who reads bank %d (window %#06x..%#06x)"
              % (target_bank, window, window + BANK_SIZE - 1))
        found = []
        for b, pc in sorted(t.starts):
            o = b * BANK_SIZE + (pc & 0x1FFF)
            op = rom[o]
            length, w = 0, None
            if op in (0x01, 0x11, 0x21, 0x31, 0x22, 0x2A, 0x32, 0x3A)                     and (pc & 0x1FFF) + 3 <= BANK_SIZE:
                length, w = 3, rom[o + 1] | (rom[o + 2] << 8)
            elif op in (0xDD, 0xFD) and (pc & 0x1FFF) + 4 <= BANK_SIZE                     and rom[o + 1] in (0x21, 0x22, 0x2A):
                length, w = 4, rom[o + 2] | (rom[o + 3] << 8)
            if not length or not (window <= w < window + BANK_SIZE):
                continue
            cfgs = {c[slot] for c in t.layouts_of[(b, pc)]}
            if target_bank in cfgs:
                found.append((w, b, pc, op))
        for w, b, pc, op in sorted(found):
            print("    %04X  <- %s:%04X  (opcode %02X)" % (w, bank_name(b), pc, op))
        print("  %d instructions" % len(found))
    elif mode == "points":
        targets = [int(x, 0) for x in sys.argv[4:]] or [0]
        start, end = targets[0], (targets[1] if len(targets) > 1
                                  else targets[0] + 1)
        print("who points at %04X..%04X" % (start, end - 1))
        print("  from instructions ALREADY traced (16-bit immediate):")
        for b, pc in sorted(t.starts):
            s_ = (1, 2, 3)
            o = b * BANK_SIZE + (pc & 0x1FFF)
            op = rom[o]
            if op in (0x01, 0x11, 0x21, 0x31, 0x22, 0x2A, 0x32, 0x3A,
                      0xC3, 0xCD) or op in JP_CC or op in CALL_CC:
                if (pc & 0x1FFF) + 3 > BANK_SIZE:
                    continue
                w = rom[o + 1] | (rom[o + 2] << 8)
                if start <= w < end:
                    print("    %s:%04X  op %02X -> %04X" % (bank_name(b), pc, op, w))
            if op in (0xDD, 0xFD) and (pc & 0x1FFF) + 4 <= BANK_SIZE:
                if rom[o + 1] in (0x21, 0x22, 0x2A):
                    w = rom[o + 2] | (rom[o + 3] << 8)
                    if start <= w < end:
                        print("    %s:%04X  op %02X%02X -> %04X"
                              % (bank_name(b), pc, op, rom[o + 1], w))
        print("  raw words in areas NOT traced (possible tables):")
        for b in range(N_BANKS):
            for i in range(BANK_SIZE - 1):
                if t.marked[b][i] or t.marked[b][i + 1]:
                    continue
                w = rom[b * BANK_SIZE + i] | (rom[b * BANK_SIZE + i + 1] << 8)
                if start <= w < end:
                    print("    %s:%04X (offset %05X) -> %04X"
                          % (bank_name(b), ORG[b] + i, b * BANK_SIZE + i, w))
    else:
        sys.exit(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main())

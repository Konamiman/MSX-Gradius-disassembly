#!/usr/bin/env python3
"""Recursive Z80 tracer: separates code from data by following control flow.

Disassembling 40 KB of a game linearly does not work: the graphics and the
tables get decoded as instructions and from then on everything is
misaligned. This tracer starts from some known entry points, follows jumps
and calls, and marks which bytes are reachable as code. Whatever is not
reached is treated as data.

Output: a blocks file for z80dasm (-b) and a coverage report.

Known and deliberate limitation: indirect jumps (JP (HL), jump tables,
addresses pushed on the stack) cannot be followed statically. The tracer
marks them as a BLIND SPOT and those destinations have to be given to it by
hand through the entries file. That is why the report lists every blind spot
with its address.
"""
import json
import os
import sys

# ---------------------------------------------------------------- Z80 tables

# Length in bytes of each unprefixed opcode.
BASE_LEN = [1] * 256
for _op, _n in {
    0x01: 3, 0x11: 3, 0x21: 3, 0x31: 3,          # LD rr,nn
    0x22: 3, 0x2A: 3, 0x32: 3, 0x3A: 3,          # LD (nn),HL / A ...
    0x06: 2, 0x0E: 2, 0x16: 2, 0x1E: 2,          # LD r,n
    0x26: 2, 0x2E: 2, 0x36: 2, 0x3E: 2,
    0x10: 2, 0x18: 2, 0x20: 2, 0x28: 2,          # DJNZ / JR
    0x30: 2, 0x38: 2,
    0xC6: 2, 0xCE: 2, 0xD6: 2, 0xDE: 2,          # ALU A,n
    0xE6: 2, 0xEE: 2, 0xF6: 2, 0xFE: 2,
    0xD3: 2, 0xDB: 2,                            # OUT (n),A / IN A,(n)
    0xC2: 3, 0xC3: 3, 0xC4: 3, 0xCA: 3, 0xCC: 3, 0xCD: 3,
    0xD2: 3, 0xD4: 3, 0xDA: 3, 0xDC: 3,
    0xE2: 3, 0xE4: 3, 0xEA: 3, 0xEC: 3,
    0xF2: 3, 0xF4: 3, 0xFA: 3, 0xFC: 3,
}.items():
    BASE_LEN[_op] = _n

# ED xx: 2 bytes except LD (nn),rr / LD rr,(nn), which are 4.
ED_LEN4 = {0x43, 0x53, 0x63, 0x73, 0x4B, 0x5B, 0x6B, 0x7B}

# Opcodes that reference (HL) and that with a DD/FD prefix become
# (IX+d)/(IY+d), gaining a displacement byte.
IDX_DISP = ({0x34, 0x35, 0x36}
            | {0x46, 0x4E, 0x56, 0x5E, 0x66, 0x6E, 0x7E}
            | {0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77}
            | {0x86, 0x8E, 0x96, 0x9E, 0xA6, 0xAE, 0xB6, 0xBE})

JP_CC = {0xC2, 0xCA, 0xD2, 0xDA, 0xE2, 0xEA, 0xF2, 0xFA}
CALL_CC = {0xC4, 0xCC, 0xD4, 0xDC, 0xE4, 0xEC, 0xF4, 0xFC}
JR_CC = {0x20, 0x28, 0x30, 0x38}
RET_CC = {0xC0, 0xC8, 0xD0, 0xD8, 0xE0, 0xE8, 0xF0, 0xF8}
RST = {0xC7: 0x00, 0xCF: 0x08, 0xD7: 0x10, 0xDF: 0x18,
       0xE7: 0x20, 0xEF: 0x28, 0xF7: 0x30, 0xFF: 0x38}

CODE, DATA = 1, 0


class Tracer:
    def __init__(self, data, org, rst_follow=True, nocode=(), skips=None):
        # skips: {call_address: n} -> after a CALL to that address, the next
        # n bytes are INLINE PARAMETERS (the routine does `pop hl` and reads
        # them), not code: they are marked as data and the flow continues
        # after them. Konami uses this in several of its cartridges; a tracer
        # that falls through swallows them as instructions. It does not appear
        # in Nemesis: here the one that has to be declared is the 0x4067
        # dispatcher, which carries the table (not some parameters) right
        # after the call, and that is solved with the .nocode file.
        self.skips = dict(skips or {})
        self.params = []                       # (start, end) of inline parameters
        self.data = data
        self.org = org
        self.end = org + len(data)
        self.mark = bytearray(len(data))       # 1 = code byte
        self.starts = set()                    # instruction starts
        self.entries = set()                   # call/jp destinations (labels)
        self.blind = []                        # indirect jumps that can't be followed
        # Jumps and calls to addresses OUTSIDE the binary. In a 16 KB
        # cartridge they are calls to the BIOS; in a MegaROM traced bank by
        # bank they are the calls to ANOTHER bank, and you need to know which
        # one was mapped in order to seed it by hand: that is why they are
        # kept as (source, destination).
        self.externals = []
        self.rst_follow = rst_follow
        self.rejected = []                     # seeds that fell in data

        # Zones that we know for certain are data (graphics, texts, tables).
        # The tracer does not go into them.
        #
        # It is needed because a single wrongly deduced destination (from a
        # pointer table, for example) puts the tracer in a graphics zone, and
        # from there it keeps "decoding" pixels as instructions without end.
        # Without this barrier the trace went from 13% to 80%, but marking
        # 100% of the colour table and of the texts as code: fake coverage.
        self.nocode = bytearray(len(data))
        for a, b in nocode:
            for i in range(max(0, a - org), min(len(data), b - org)):
                self.nocode[i] = 1

    def inside(self, a):
        return self.org <= a < self.end

    def is_data(self, a):
        return self.inside(a) and self.nocode[a - self.org]

    def byte(self, a):
        return self.data[a - self.org]

    def word(self, a):
        return self.byte(a) | (self.byte(a + 1) << 8)

    def ilen(self, a):
        """Length of the instruction at a. Returns 0 if it does not fit whole.

        Returning 0 when the instruction runs past the end of the binary
        matters: if it returned its nominal length, whoever uses it to advance
        would read bytes that do not exist. The internal callers already
        checked this separately, but the function has to be correct on its own.
        """
        n = self._raw_ilen(a)
        return n if n and self.inside(a + n - 1) else 0

    def _raw_ilen(self, a):
        """Length according to the opcode, without checking whether it fits."""
        if not self.inside(a):
            return 0
        op = self.byte(a)
        if op == 0xCB:
            return 2
        if op == 0xED:
            if not self.inside(a + 1):
                return 0
            return 4 if self.byte(a + 1) in ED_LEN4 else 2
        if op in (0xDD, 0xFD):
            if not self.inside(a + 1):
                return 0
            op2 = self.byte(a + 1)
            if op2 == 0xCB:
                return 4
            if op2 in (0xDD, 0xFD, 0xED):     # redundant prefix: 1 byte
                return 1
            return 1 + BASE_LEN[op2] + (1 if op2 in IDX_DISP else 0)
        return BASE_LEN[op]

    def trace(self, entry_list):
        good = [a for a in entry_list if not self.is_data(a)]
        self.rejected = [a for a in entry_list if self.is_data(a)]
        work = list(good)
        self.entries.update(a for a in good if self.inside(a))
        while work:
            pc = work.pop()
            while True:
                if not self.inside(pc) or self.is_data(pc):
                    break
                off = pc - self.org
                if self.mark[off] and pc in self.starts:
                    break                      # already traced from here
                n = self.ilen(pc)
                if n == 0 or pc + n > self.end:
                    break
                self.starts.add(pc)
                for i in range(n):
                    self.mark[off + i] = CODE
                op = self.byte(pc)
                nxt = pc + n
                stop = False

                if op == 0xC3:                             # JP nn
                    t = self.word(pc + 1); self._add(t, work, pc); stop = True
                elif op in JP_CC:
                    self._add(self.word(pc + 1), work, pc)
                elif op == 0xCD:                           # CALL nn
                    t = self.word(pc + 1)
                    self._add(t, work, pc)
                    if t in self.skips:
                        k = self.skips[t]
                        self.params.append((nxt, nxt + k))
                        nxt = nxt + k
                elif op in CALL_CC:
                    self._add(self.word(pc + 1), work, pc)
                elif op == 0x18:                           # JR e
                    self._add(nxt + self._s8(self.byte(pc + 1)), work); stop = True
                elif op in JR_CC or op == 0x10:            # JR cc,e / DJNZ
                    self._add(nxt + self._s8(self.byte(pc + 1)), work)
                elif op == 0xC9:                           # RET
                    stop = True
                elif op == 0xE9:                           # JP (HL)
                    self.blind.append((pc, "JP (HL)")); stop = True
                elif op in (0xDD, 0xFD) and self.inside(pc + 1) and self.byte(pc + 1) == 0xE9:
                    self.blind.append((pc, "JP (IX/IY)")); stop = True
                elif op == 0xED and self.inside(pc + 1) and self.byte(pc + 1) in (0x45, 0x4D):
                    stop = True                            # RETN / RETI
                # NOTE: HALT (0x76) does NOT cut the flow. It waits for the
                # next interrupt and continues at the following instruction;
                # games use it to sync with the screen scan. Treating it as
                # the end of a routine left the trace at 2% coverage.
                elif op in RST:
                    if self.rst_follow and self.inside(RST[op]):
                        self._add(RST[op], work)
                # RET cc and the conditional CALL/JP continue at nxt

                if stop:
                    break
                pc = nxt

    def _add(self, target, work, pc=None):
        if not self.inside(target):
            if pc is not None:
                self.externals.append((pc, target))
            return
        if not self.is_data(target):
            self.entries.add(target)
            if not (self.mark[target - self.org] and target in self.starts):
                work.append(target)

    @staticmethod
    def _s8(b):
        return b - 256 if b > 127 else b

    def blocks(self):
        """Contiguous regions [(kind, start, end)] with kind 'c' or 'd'."""
        out = []
        cur = self.mark[0]
        start = self.org
        for i in range(1, len(self.mark)):
            if self.mark[i] != cur:
                out.append(("c" if cur else "d", start, self.org + i))
                cur = self.mark[i]
                start = self.org + i
        out.append(("c" if cur else "d", start, self.end))
        return out

    def report(self):
        n = sum(self.mark)
        return dict(code_bytes=n, data_bytes=len(self.mark) - n,
                    coverage=n / len(self.mark),
                    instructions=len(self.starts),
                    labels=len(self.entries),
                    blind_jumps=len(self.blind))


def write_z80dasm_blocks(blocks, path):
    """z80dasm -b file. Format: '<start> <kind> <end>' per line."""
    with open(path, "w") as f:
        for kind, a, b in blocks:
            f.write(f"{a:#06x} {'code' if kind=='c' else 'defb'} {b-1:#06x}\n")


def main():
    binpath, org, entries_path, outprefix = sys.argv[1:5]
    org = int(org, 0)
    data = open(binpath, "rb").read()
    entries = []
    skips = {}
    for ln in open(entries_path):
        ln = ln.split("#")[0].strip()
        if not ln:
            continue
        if ln.lower().startswith("!skip"):
            # !skip 0x5F65 6  -> after every CALL 0x5F65, 6 bytes of parameters
            _, a, n = ln.split()[:3]
            skips[int(a, 0)] = int(n, 0)
            continue
        entries.append(int(ln.split()[0], 0))

    nocode = []
    ncpath = outprefix.replace("work/", "src/") + ".nocode"
    if len(sys.argv) > 5:
        ncpath = sys.argv[5]
    if os.path.exists(ncpath):
        for ln in open(ncpath):
            ln = ln.split("#")[0].strip()
            if ln:
                a, b = ln.split()[:2]
                nocode.append((int(a, 0), int(b, 0)))
        print(f"zones declared as data: {len(nocode)} (from {ncpath})")

    t = Tracer(data, org, nocode=nocode, skips=skips)
    t.trace(entries)
    blocks = t.blocks()
    if t.params:
        print(f"inline parameters skipped after CALL: {len(t.params)} sites, "
              f"{sum(b - a for a, b in t.params)} bytes")
    write_z80dasm_blocks(blocks, outprefix + ".blocks")

    r = t.report()
    with open(outprefix + ".trace.json", "w") as f:
        json.dump(dict(report=r,
                       entries=sorted(t.entries),
                       blind=[[hex(a), k] for a, k in t.blind],
                       params=[[a, b] for a, b in t.params],
                       externals=[[a, b] for a, b in t.externals],
                       blocks=[[k, a, b] for k, a, b in blocks]), f, indent=1)

    print(f"binary {binpath}  org={org:#06x}  {len(data)} bytes")
    print(f"  code      : {r['code_bytes']} bytes ({r['coverage']*100:.1f}%)")
    print(f"  data      : {r['data_bytes']} bytes")
    print(f"  instrs.   : {r['instructions']}")
    print(f"  labels    : {r['labels']}")
    print(f"  regions   : {len(blocks)}")
    if t.rejected:
        print(f"  seeds REJECTED for falling in a data zone: {len(t.rejected)}")
        for a in t.rejected[:10]:
            print(f"      {a:#06x}")
    print(f"  calls/jumps outside the binary: {len(t.externals)} "
          f"({len(set(b for _, b in t.externals))} distinct targets)")
    print(f"  BLIND SPOTS (indirect jumps, they have to be resolved by hand): "
          f"{r['blind_jumps']}")
    for a, k in t.blind[:20]:
        print(f"      {a:#06x}  {k}")
    if len(t.blind) > 20:
        print(f"      ... and {len(t.blind)-20} more (see {outprefix}.trace.json)")


if __name__ == "__main__":
    main()

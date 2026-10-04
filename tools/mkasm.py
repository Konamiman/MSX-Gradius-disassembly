#!/usr/bin/env python3
"""Generates the commented assembler listing from:
  - the binary
  - the tracer's code/data map (.trace.json)
  - a hand-written annotations file (.notes)

Why not use z80dasm with its symbols file (-S): z80dasm replaces ANY value
that numerically matches a symbol, immediates included. It produced lines like
`ld bc,CHRGTR` where the real code says `ld bc,0x0010` (a length, not an
address). Here z80dasm is used only for the mnemonics, and the BIOS labels are
added as a COMMENT, and only when the instruction is a real call/jp.

Format of the .notes file (all optional, one directive per line):
    L 0xD041 set_melody        Plays melody DE on channel A
        -> defines a label and its comment
    C 0xDA31 Reads the trigger (space or joystick button)
        -> comment at the end of that line
    B 0xDA00 =====  Main menu  =====
        -> header block before that address (can be repeated)
    D 0x4000 0x4800 font    Font pattern table (256 glyphs x 8)
        -> marks a data range with a name and a description
    F 0x47c3 w10        Row width of the data block that starts there:
    F 0x4787 2          a number = bytes per line, wN = N words (defw), and
    F 0x4000 2,w4,6     several runs separated by commas (the last one repeats)
                        -> the dump comes out in rows the size of its structure
"""
import json
import os
import re
import subprocess
import sys
import textwrap

# Where to write the temporary chunk passed to z80dasm. It is set in main()
# to the project's work directory: the environment's TEMP cannot be trusted
# (under make it can end up being C:\WINDOWS\Temp, where z80dasm's unchecked
# stat() returns garbage and every chunk "goes beyond the 16-bit space").
TMPCHUNK = "_mkasm_chunk.bin"

BIOS = {}


def load_bios(path):
    for ln in open(path, encoding="utf-8"):
        m = re.match(r"^(\w+):\s*equ\s+(0x[0-9a-fA-F]+)\s*(?:;\s*(.*))?$", ln.strip())
        if m:
            BIOS.setdefault(int(m.group(2), 16), (m.group(1), (m.group(3) or "").strip()))


def parse_fmt(spec):
    """Row width of a data block, as declared by the F directive.

    "8" -> rows of eight bytes; "w4" -> rows of four words (defw);
    "2,w4,6" -> one row of two bytes, another of four words and the rest six
    at a time. The last run repeats until the block ends.
    """
    runs = []
    for it in spec.lower().split(","):
        it = it.strip()
        words = it.startswith("w")
        n = it[1:] if words else it
        runs.append((int(n) if n else 8, words))
    return runs or [(16, False)]


class Notes:
    def __init__(self):
        self.labels, self.line, self.blocks, self.data = {}, {}, {}, []
        self.fmt = {}

    @classmethod
    def load(cls, path):
        n = cls()
        if not path or not os.path.exists(path):
            return n
        for raw in open(path, encoding="utf-8"):
            ln = raw.rstrip("\n")
            if not ln.strip() or ln.lstrip().startswith("#"):
                continue
            k, rest = ln.split(None, 1)
            if k == "L":
                p = rest.split(None, 2)
                n.labels[int(p[0], 0)] = (p[1], p[2].strip() if len(p) > 2 else "")
            elif k == "C":
                p = rest.split(None, 1)
                n.line[int(p[0], 0)] = p[1].strip() if len(p) > 1 else ""
            elif k == "B":
                p = rest.split(None, 1)
                n.blocks.setdefault(int(p[0], 0), []).append(p[1] if len(p) > 1 else "")
            elif k == "D":
                p = rest.split(None, 3)
                n.data.append((int(p[0], 0), int(p[1], 0), p[2],
                               p[3].strip() if len(p) > 3 else ""))
            elif k == "F":
                p = rest.split()
                n.fmt[int(p[0], 0)] = parse_fmt(p[1])
        return n


LBL_RE = re.compile(r"\b(?:sub_|l)([0-9a-f]{4})h\b")


_BANNERED = set()
# Labels actually defined in the listing. Keeping track is needed because a
# label can be referenced from the code and fall in a data zone (or at the
# start of a region, where z80dasm does not emit it): without this the listing
# does not reassemble, which is exactly the criterion that validates the
# disassembly.
_EMITTED = set()
# DATA_ label of each declared data block.
_DATANAMES = {}


def banner(lines, addr):
    """A single frame with all the B lines of the same address.

    The addresses already emitted are recorded because an address is often
    both a label and a first instruction, and without this the header came out
    duplicated.
    """
    if not lines or addr in _BANNERED:
        return []
    _BANNERED.add(addr)
    out = ["", "; " + "-" * 70]
    out += [("; " + l).rstrip() for l in lines]
    out.append("; " + "-" * 70)
    return out


def main():
    global TMPCHUNK
    binpath, org, tracepath, notespath, symspath, outpath, title = sys.argv[1:8]
    org = int(org, 0)
    TMPCHUNK = os.path.join(os.path.dirname(os.path.abspath(tracepath)),
                            "_mkasm_chunk.bin")
    data = open(binpath, "rb").read()
    tr = json.load(open(tracepath))
    notes = Notes.load(notespath)
    load_bios(symspath)

    # Label for every jump destination the tracer found.
    auto = {a for a in tr["entries"]}
    names = {}
    for a in sorted(auto):
        names[a] = notes.labels[a][0] if a in notes.labels else f"L_{a:04X}"
    for a, (nm, _) in notes.labels.items():
        names[a] = nm

    dataranges = {a: (b, nm, desc) for a, b, nm, desc in notes.data}
    # Label of each data block: DATA_ plus the name of its range in the notes,
    # which is what says WHAT IT IS FOR. The prefix sets it apart from a code
    # label, and with the name inside, the pointers to the block read by
    # themselves. If the name is not valid as a label (or is repeated, or
    # another one already uses it) it falls back to the address.
    repeats = {}
    for a_, _b, nm_, _d in notes.data:
        repeats[nm_] = repeats.get(nm_, 0) + 1
    used_labels = set(names.values())
    for a_, _b, nm_, _d in notes.data:
        label = "DATA_" + nm_ if re.fullmatch(r"[A-Za-z_]\w*", nm_ or "") else ""
        if not label or repeats[nm_] > 1 or label in used_labels:
            label = f"DATA_{a_:04X}"
        if a_ not in names:
            _DATANAMES[a_] = label
            used_labels.add(label)

    out = []
    out.append(f"; {'='*74}")
    out.append(f"; {title}")
    out.append(f"; {'='*74}")
    out.append("; Generated by tools/mkasm.py from the actual control-flow trace.")
    out.append("; The comments come from tools/../src/*.notes and are anchored to an")
    out.append("; address, so they survive a re-trace.")
    out.append(f"; {'='*74}\n")
    out.append(f"\torg {org:#07x}\n")
    HDR = len(out)

    for kind, a, b in tr["blocks"]:
        if kind == "d":
            out += emit_data(data, org, a, b, dataranges, notes, names)
        else:
            out += emit_code(data, org, a, b, names, notes)

    # z80dasm invents labels (lXXXXh / sub_XXXXh) for the jumps it sees. If
    # the destination falls outside the chunk we pass it (or in a zone the
    # tracer marked as data) it emits the reference but not the definition.
    # They are resolved here with an equ, and a warning is given: each one
    # points at an address that is probably code the tracer did not reach.
    # CAREFUL ABOUT CALLING THEM "JUMP DESTINATIONS": most of them are not.
    # z80dasm replaces ANY value that matches an address with a label,
    # immediates included (it is the same problem guarded against above with
    # the BIOS symbols, and here it slipped in with our own labels). In this
    # game the seven that came out were, all of them, values:
    #
    #   ld ix,lcc32h   the address of the `ld bc,` that is patched to give each
    #                  object table its speed (and its twin ladc4h)
    #   ld hl,lcb9dh   a RETURN address pushed by hand before a `jp (hl)`,
    #                  which is an indirect call done the hard way
    #   ld hl,ld959h   a `ret` installed as an object's behaviour, that is
    #                  "this one does nothing"
    #   ld de,lef00h   not even an address: it is the number 0xEF00 that is
    #                  added with `add hl,de`, that is, subtracting 0x1100
    #
    # That is why they are separated: only what appears as the destination of
    # a real jump or call raises the alarm. The rest is declared all the same
    # (it is needed for the listing to reassemble) but without saying there is
    # code to trace, which was false and had been in every build from the
    # start.
    JUMP = re.compile(r"\b(?:jp|jr|call|djnz|rst)\b[^;]*?\b(?:sub_|l)"
                       r"([0-9a-f]{4})h\b")
    body = "\n".join(out)
    used = {int(m, 16) for m in re.findall(r"\b(?:sub_|l)([0-9a-f]{4})h\b", body)}
    defined = {int(m, 16) for m in
               re.findall(r"(?m)^(?:sub_|l)([0-9a-f]{4})h:", body)}
    jumped = {int(m, 16) for m in JUMP.findall(body)}
    orphans = sorted(used - defined)
    untraced = [a for a in orphans if a in jumped]
    values = [a for a in orphans if a not in jumped]
    if orphans:
        hf = ["", "; " + "-" * 70]
        if untraced:
            hf += ["; Jump targets that z80dasm references and the tracer did not",
                   "; mark as code. Each one is a place to look at."]
        if values:
            hf += ["; Addresses that only appear as a VALUE -in an `ld`, not in",
                   "; a jump-: pointers the code passes around, or numbers that",
                   "; happen to match an address. There is nothing to trace",
                   "; there; the equ exists so that the listing assembles."]
        hf += ["; " + "-" * 70]
        hf += [f"l{a:04x}h:\tequ {a:#07x}" for a in orphans]
        out = out[:HDR] + hf + out[HDR:]
        if untraced:
            print(f"  warning: {len(untraced)} untraced jump targets: "
                  + " ".join(f"{a:#06x}" for a in untraced[:12]))
        if values:
            print(f"  {len(values)} addresses used only as a value: "
                  + " ".join(f"{a:#06x}" for a in values[:12]))

    # Safety net: any referenced label that has not ended up defined (e.g. it
    # points outside the binary) is declared with an equ, so that the listing
    # still reassembles.
    missing = sorted(a for a in names if a not in _EMITTED)
    if missing:
        eq = ["", "; " + "-" * 70,
              "; Labels that do not fall on any position emitted in the listing",
              "; (targets outside the binary or inside an instruction).",
              "; " + "-" * 70]
        eq += [f"{names[a]}:\tequ {a:#07x}" for a in missing]
        out = out[:HDR] + eq + out[HDR:]
    text = "\n".join(out) + "\n"
    open(outpath, "w", encoding="utf-8").write(text)
    ncode = sum(b - a for k, a, b in tr["blocks"] if k == "c")
    # The lines are counted on the written file, not on `out`: some entries of
    # `out` are multi-line frames, and counting entries gave two fewer than the
    # site publishes (it counts them with splitlines, like the test does).
    print(f"{outpath}: {len(text.splitlines())} lines, {ncode} code bytes, "
          f"{len(names)} labels, {len(notes.line)} line comments")


def emit_data(data, org, a, b, dataranges, notes, names):
    """Dumps a stretch of data SPLIT by the ranges declared in the notes.

    It used to dump the tracer's whole stretch 16 bytes at a time with the
    headers of all its ranges piled up in front: the rows crossed the
    boundaries between one table and the next and there was no way to see
    where each one ended.

    It splits the bytes at BOUNDARIES: each piece is ruled by the smallest
    range that covers it, so a table declared INSIDE another, wider zone
    comes out with its header and its label in place, and the zone that
    contains it comes out split in two. No declared range is left unpublished
    (nested ones used to get lost with just a console warning) and no header
    states a size other than that of the piece below it.
    """
    out = []
    hit = [(s, e, nm, d) for s, (e, nm, d) in dataranges.items()
           if s < b and e > a]
    cuts = {a, b}
    for s, e, _nm, _d in hit:
        if a < s < b:
            cuts.add(s)
        if a < e < b:
            cuts.add(e)
    points = sorted(cuts)
    pieces = []
    for p, q in zip(points, points[1:]):
        # The owner of the piece is the smallest range that covers it whole:
        # that way a table placed inside a larger zone wins over the zone.
        owners = [(e - s, s, e, nm, d) for s, e, nm, d in hit if s <= p and e >= q]
        if owners:
            _t, s, e, nm, d = min(owners)
            pieces.append([p, q, nm, d, (s, e)])
        else:
            pieces.append([p, q, None, "", None])
    # Consecutive pieces of the same range: just one (no reason to split it).
    merged = []
    for t in pieces:
        if merged and merged[-1][4] == t[4] and merged[-1][1] == t[0]:
            merged[-1][1] = t[1]
        else:
            merged.append(t)
    for p, q, nm, d, span in merged:
        out += emit_data_range(data, org, p, q, nm, d, notes, names, span)
    return out


def emit_data_range(data, org, a, b, nm, desc, notes, names, span=None):
    """A single data block: header, label and dump with its width.

    `span` is the bounds declared in the notes. If what is dumped here is
    only a part of them (because another table is declared inside, or because
    the tracer cuts the zone), the header says so: the size announced is
    always that of the bytes below it.
    """
    partial = span is not None and (span[0] != a or span[1] != b)
    out = ["", "; " + "-" * 70]
    if nm:
        head = f"; DATA {nm}: {desc}" if desc else f"; DATA {nm}"
        if partial:
            head = (f"; DATA {nm} (part): {desc}" if desc
                    else f"; DATA {nm} (part)")
        out += textwrap.wrap(head, 78, subsequent_indent=";   ",
                             break_long_words=False, break_on_hyphens=False)
        line = f";   {a:#06x}..{b:#06x}  ({b - a} bytes)"
        if partial:
            line += (f"  of {span[0]:#06x}..{span[1]:#06x} "
                     f"({span[1] - span[0]} bytes)")
        out.append(line)
    else:
        out.append(f"; UNIDENTIFIED DATA  {a:#06x}..{b:#06x}  ({b - a} bytes)")
    out += banner(notes.blocks.get(a), a)
    # Label of the block: the one from the notes if there is one at its first
    # byte; otherwise, the DATA_ one carrying the name of its use. Stretches
    # that do not start where the range starts get the address appended, so
    # as not to give the same name to two different places.
    if a in names and a not in _EMITTED:
        cmt = notes.labels.get(a, (None, ""))[1]
        out.append(f"{names[a]}:" + (f"\t\t; {cmt}" if cmt else ""))
        _EMITTED.add(a)
    elif a not in _EMITTED and a not in names:
        label = _DATANAMES.get(span[0]) if span else None
        if label and span[0] != a:
            label = f"{label}_{a:04X}"
        out.append((label or f"DATA_{a:04X}") + ":")
    runs = notes.fmt.get(a) or (notes.fmt.get(span[0]) if span else None) \
        or [(16, False)]
    # A label (or a B header) can fall inside a row: the row has to be split
    # so that it lands exactly at its address.
    i, k = a, 0
    while i < b:
        width, words = runs[min(k, len(runs) - 1)]
        k += 1
        end = min(i + width * (2 if words else 1), b)
        cut = next((x for x in range(i + 1, end)
                    if (x in names and x not in _EMITTED)
                    or x in notes.blocks), None)
        if cut:
            end = cut
        out += data_row(data, org, i, end, words, names, notes)
        i = end
        if i < b:
            out += banner(notes.blocks.get(i), i)
            if i in names and i not in _EMITTED:
                cmt = notes.labels.get(i, (None, ""))[1]
                out.append(f"{names[i]}:" + (f"\t\t; {cmt}" if cmt else ""))
                _EMITTED.add(i)
    return out


def data_row(data, org, i, end, words, names, notes=None):
    """One row of the dump. For defw, where it points is noted, if known.

    A row can also carry its own comment, with the C directive anchored to
    its first byte: it is the only way to annotate a data table entry by entry
    (for example, putting next to each text pointer what that text says) and
    have the annotation survive a retrace.
    """
    own = notes.line.get(i, "") if notes else ""
    row = data[i - org:end - org]
    if words and len(row) >= 2:
        vals = [row[2 * k] | (row[2 * k + 1] << 8) for k in range(len(row) // 2)]
        cmt = f"; {i:04x}"
        dest = [names.get(v) or _DATANAMES.get(v) for v in vals]
        if len(vals) <= 4 and any(dest):
            cmt += "  -> " + " ".join(d or f"{v:#06x}"
                                     for v, d in zip(vals, dest))
        if own:
            cmt = cmt.rstrip() + "\t" + own
        out = [f"\tdefw {','.join(f'0{v:04x}h' for v in vals)}\t{cmt}".rstrip()]
        if len(row) % 2:                 # stray byte at the end of the range
            out.append(f"\tdefb 0{row[-1]:02x}h\t; {i + len(vals) * 2:04x}")
        return out
    txt = "".join(chr(c) if 32 <= c < 127 else "." for c in row)
    cmt = f"; {i:04x}" + (f"  {txt}" if len(row) >= 8 else "")
    if own:
        cmt = cmt.rstrip() + "\t" + own
    return [f"\tdefb {','.join(f'0{c:02x}h' for c in row)}\t{cmt}".rstrip()]


def emit_code(data, org, a, b, names, notes):
    tmp = TMPCHUNK
    open(tmp, "wb").write(data[a - org:b - org])
    # TMP/TEMP sanitised for z80dasm: under msys make they arrive as '/tmp',
    # which the native Windows CRT cannot use, and z80dasm's internal
    # tmpfile() ends up trying to create at the root of the drive (Permission
    # denied).
    dtmp = os.path.dirname(tmp) or "."
    r = subprocess.run(["z80dasm", "-a", "-l", "-g", hex(a), tmp],
                       capture_output=True, text=True,
                       env=dict(os.environ, TMP=dtmp, TEMP=dtmp))
    os.unlink(tmp)
    if r.returncode != 0:
        return [f"; !! z80dasm failed at {a:#06x}: {r.stderr}"]

    out = ["", f"; {'='*70}", f"; CODE {a:#06x}..{b:#06x}  ({b-a} bytes)",
           f"; {'='*70}"]
    for ln in r.stdout.splitlines():
        if ln.startswith("; z80dasm") or ln.startswith("; command") or ln.startswith("\torg"):
            continue
        # Address of the instruction, from the comment z80dasm adds with -a
        m = re.search(r";([0-9a-f]{4})\b", ln)
        cur = int(m.group(1), 16) if m else None

        # Our own label instead of z80dasm's synthetic one
        m2 = re.match(r"^(sub_|l)([0-9a-f]{4})h:", ln)
        if m2:
            addr = int(m2.group(2), 16)
            nm = names.get(addr, f"L_{addr:04X}")
            out += banner(notes.blocks.get(addr), addr)
            cmt = notes.labels.get(addr, (None, ""))[1]
            out.append(f"{nm}:" + (f"\t\t; {cmt}" if cmt else ""))
            _EMITTED.add(addr)
            continue

        if cur is not None and cur in notes.blocks:
            out += banner(notes.blocks[cur], cur)

        # z80dasm only puts a label where it jumps itself; if the address has
        # a proper name and it has not been defined yet, it is emitted here.
        if cur is not None and cur in names and cur not in _EMITTED:
            cmt = notes.labels.get(cur, (None, ""))[1]
            out.append(f"{names[cur]}:" + (f"\t\t; {cmt}" if cmt else ""))
            _EMITTED.add(cur)

        # Rename z80dasm's synthetic labels to ours
        def repl(mm):
            return names.get(int(mm.group(1), 16), mm.group(0))
        ln = LBL_RE.sub(repl, ln)

        # z80dasm only invents labels for jumps INSIDE the chunk we give it;
        # calls to other routines come out as literals (e.g.
        # 'call 0d041h'). Here they are replaced by their name, but ONLY in
        # jump instructions, never in an immediate.
        def repl_abs(mm):
            tgt = int(mm.group(2), 16)
            return f"{mm.group(1)}{names[tgt]}" if tgt in names else mm.group(0)
        ln = re.sub(r"\b((?:call|jp|jr)\s+(?:\w{1,2},)?)0([0-9a-f]{4})h\b",
                    repl_abs, ln)

        # Annotate BIOS only on real call/jp (never on immediates)
        extra = []
        mb = re.search(r"\b(call|jp)\s+(?:\w+,)?0([0-9a-f]{4})h\b", ln)
        if mb:
            tgt = int(mb.group(2), 16)
            if tgt in BIOS:
                nm, desc = BIOS[tgt]
                extra.append(f"BIOS {nm}" + (f" - {desc}" if desc else ""))
        if cur is not None and cur in notes.line:
            extra.append(notes.line[cur])
        if extra:
            ln = ln.rstrip() + "   ; " + " | ".join(extra)
        out.append(ln)
    return out


if __name__ == "__main__":
    main()

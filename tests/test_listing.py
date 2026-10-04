#!/usr/bin/env python3
"""Checks on the generated listing.

None of them needs the cartridge: they run on src/nemesis_pNN.asm and
src/pNN.notes. They make sure the disassembly does not degrade without anyone
noticing: that no comments disappear, that no unidentified data blocks show up
again, that the published figures are the ones in the tree, and that the
bank -> org rule is not contradicted between the Makefile and
tools/banks.py.
"""
import json
import os
import re
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))

from banks import ORG, BANK_SIZE, N_BANKS, bank_name     # noqa: E402

SRC = os.path.join(ROOT, "src")
WORK = os.path.join(ROOT, "work")

# The other games in the series. Another one's name showing up in a page of
# this one is almost always a copy-and-paste, and five licences have already
# been published naming the wrong game.
OTHER_GAMES = ("Pitfall", "Temptations", "Stardust", "Ale Hop", "Colt 36",
               "Middle Earth", "Monkey", "F-1 Spirit", "Athletic",
               "Antarctic", "Pippols", "Frogger", "Time Pilot",
               "Super Cobra", "Billiards", "Mahjong", "Hyper Olympic",
               "Hyper Sports", "Hyper Rally", "Demonia", "Cabbage")


def asm(p):
    with open(os.path.join(SRC, "nemesis_%s.asm" % bank_name(p)), encoding="utf-8") as f:
        return f.read()


def notes(p):
    with open(os.path.join(SRC, "%s.notes" % bank_name(p)), encoding="utf-8") as f:
        return f.read().splitlines()


def directives(p, key):
    return [l for l in notes(p) if l.startswith(key + " ")]


def all_directives(key):
    out = []
    for p in range(N_BANKS):
        out += directives(p, key)
    return out


class TestBanks(unittest.TestCase):
    """The bank -> org rule, which everything else hangs from."""

    def test_all_sixteen_banks_have_an_org(self):
        self.assertEqual(sorted(ORG), list(range(N_BANKS)))

    def test_orgs_are_the_mapper_ones(self):
        for p, o in ORG.items():
            self.assertIn(o, (0x4000, 0x6000, 0x8000, 0xA000),
                          "%s has an org the mapper cannot give" % bank_name(p))
        self.assertEqual(ORG[0], 0x4000, "bank 0 is the fixed one")

    def test_makefile_repeats_the_same_table(self):
        with open(os.path.join(ROOT, "Makefile"), encoding="utf-8") as f:
            text = f.read()
        for p in range(N_BANKS):
            row = re.search(r"(?m)^ORG_%02d\s*=\s*(0x[0-9a-fA-F]+)" % p, text)
            self.assertIsNotNone(row, "the Makefile does not declare ORG_%02d" % p)
            self.assertEqual(int(row.group(1), 16), ORG[p],
                             "the Makefile and tools/banks.py disagree "
                             "about bank %d" % p)


class TestListing(unittest.TestCase):

    def test_no_unidentified_data_blocks(self):
        for p in range(N_BANKS):
            n = asm(p).count("UNIDENTIFIED DATA")
            self.assertEqual(n, 0, "%s has %d unidentified data "
                                   "blocks" % (bank_name(p), n))

    # How many routines are called with `call` and are still unnamed, bank by
    # bank. IT IS NOT A TARGET: it is the DEBT left to comment, and the test
    # is there so that it can only go down. When a routine gets named, the
    # figure here has to be lowered too, and that way nobody can undo work
    # without the test calling it out.
    UNNAMED_CEILING = {0: 92, 1: 68, 2: 87, 3: 76, 7: 6, 10: 7}

    def test_routine_naming_debt_does_not_grow(self):
        for p in range(N_BANKS):
            loose = sorted(set(re.findall(
                r"\bcall (?:n?[zc],|p[oe],|[mp],)?(L_[0-9A-F]{4})", asm(p))))
            ceiling = self.UNNAMED_CEILING.get(p, 0)
            self.assertLessEqual(
                len(loose), ceiling,
                "%s: %d routines called and unnamed, and the ceiling is %d. "
                "If you have named one, lower the ceiling; if you have removed "
                "a name, put it back. The first ones: %s"
                % (bank_name(p), len(loose), ceiling, " ".join(loose[:12])))

    def test_no_label_declared_twice(self):
        for p in range(N_BANKS):
            names = re.findall(r"^([A-Za-z_][\w]*):", asm(p), re.M)
            repeated = sorted({n for n in names if names.count(n) > 1})
            self.assertEqual(repeated, [], "%s: repeated labels: %s"
                             % (bank_name(p), " ".join(repeated)))

    def test_no_line_comment_repeated(self):
        for p in range(N_BANKS):
            addrs = [l.split()[1].upper() for l in directives(p, "C")]
            repeated = sorted({d for d in addrs if addrs.count(d) > 1})
            self.assertEqual(repeated, [], "%s: repeated comments at %s"
                             % (bank_name(p), " ".join(repeated)))

    def test_no_address_named_twice(self):
        for p in range(N_BANKS):
            addrs = [l.split()[1] for l in directives(p, "L")]
            repeated = sorted({d for d in addrs if addrs.count(d) > 1})
            self.assertEqual(repeated, [], "%s: addresses with two names: %s"
                             % (bank_name(p), " ".join(repeated)))

    def test_all_comments_reach_the_listing(self):
        for p in range(N_BANKS):
            present = set(re.findall(r";([0-9a-f]{4})(?:\s|$)", asm(p), re.M))
            lost = [l.split()[1] for l in directives(p, "C")
                    if l.split()[1][2:].lower() not in present]
            self.assertEqual(lost, [], "%s: comments that do not make it: %s"
                             % (bank_name(p), " ".join(lost[:12])))

    def test_all_labels_reach_the_listing(self):
        for p in range(N_BANKS):
            text = asm(p)
            lost = [l.split()[2] for l in directives(p, "L")
                    if not re.search(r"(?m)^%s:" % re.escape(l.split()[2]),
                                     text)]
            self.assertEqual(lost, [], "%s: labels that do not make it: %s"
                             % (bank_name(p), " ".join(lost[:12])))

    def test_ranges_do_not_overlap(self):
        for p in range(N_BANKS):
            ranges = sorted((int(l.split()[1], 16), int(l.split()[2], 16),
                             l.split()[3]) for l in directives(p, "D"))
            for (a1, b1, n1), (a2, b2, n2) in zip(ranges, ranges[1:]):
                self.assertLessEqual(b1, a2, "%s: %s (%04X-%04X) overlaps %s "
                                     "(%04X-%04X)"
                                     % (bank_name(p), n1, a1, b1, n2, a2, b2))

    def test_all_ranges_are_forward_and_inside(self):
        for p in range(N_BANKS):
            for l in directives(p, "D"):
                a, b, name = int(l.split()[1], 16), int(l.split()[2], 16), l.split()[3]
                self.assertLess(a, b, "%s: %s is backwards" % (bank_name(p), name))
                self.assertGreaterEqual(a, ORG[p], "%s: %s starts outside"
                                        % (bank_name(p), name))
                self.assertLessEqual(b, ORG[p] + BANK_SIZE,
                                     "%s: %s ends outside" % (bank_name(p), name))

    def test_all_ranges_are_explained(self):
        for p in range(N_BANKS):
            bare = [l.split()[3] for l in directives(p, "D")
                    if len(l.split()) < 5]
            self.assertEqual(bare, [], "%s: ranges without an explanation: %s"
                             % (bank_name(p), " ".join(bare)))

    def test_every_width_falls_in_a_range(self):
        for p in range(N_BANKS):
            starts = {l.split()[1].lower() for l in directives(p, "D")}
            loose = [l.split()[1] for l in directives(p, "F")
                     if l.split()[1].lower() not in starts]
            self.assertEqual(loose, [], "%s: widths without a range: %s"
                             % (bank_name(p), " ".join(loose[:12])))

    def test_every_range_declares_its_width(self):
        """The house rule: every table with its name and its row width."""
        for p in range(N_BANKS):
            widths = {l.split()[1].lower() for l in directives(p, "F")}
            missing = [l.split()[3] for l in directives(p, "D")
                       if l.split()[1].lower() not in widths]
            self.assertEqual(missing, [], "%s: ranges without an F directive: %s"
                             % (bank_name(p), " ".join(missing[:12])))

    def test_listing_is_generated_by_the_tool(self):
        for p in range(N_BANKS):
            self.assertIn("Generated by tools/mkasm.py", asm(p))

    def test_every_listing_states_its_org(self):
        for p in range(N_BANKS):
            self.assertIn("org %#07x" % ORG[p], asm(p),
                          "%s does not carry its org" % bank_name(p))

    def test_listing_does_not_mention_another_game(self):
        for p in range(N_BANKS):
            for game in OTHER_GAMES:
                self.assertNotIn(game, asm(p), "%s mentions %s"
                                 % (bank_name(p), game))

    def test_root_does_not_mention_another_game(self):
        for fname in ("README.md", "README.es.md", "AVISO-LEGAL.md",
                      "LEGAL-NOTICE.md", "LICENSE", "Makefile"):
            path = os.path.join(ROOT, fname)
            if not os.path.exists(path):
                continue
            with open(path, encoding="utf-8") as f:
                text = f.read()
            for game in OTHER_GAMES:
                self.assertNotIn(game, text, "%s mentions %s" % (fname, game))

    def test_tools_do_not_mention_another_game(self):
        for fn in sorted(os.listdir(os.path.join(ROOT, "tools"))):
            if not fn.endswith(".py"):
                continue
            with open(os.path.join(ROOT, "tools", fn), encoding="utf-8") as f:
                text = f.read()
            for game in OTHER_GAMES:
                self.assertNotIn(game, text, "tools/%s mentions %s" % (fn, game))


class TestEntries(unittest.TestCase):
    """Every entry point, with its justification and inside its bank."""

    def entries(self, p):
        path = os.path.join(SRC, "%s.entries" % bank_name(p))
        out = []
        with open(path, encoding="utf-8") as f:
            for i, ln in enumerate(f, 1):
                if ln.lstrip().startswith("#") or not ln.strip():
                    continue
                out.append((i, ln.rstrip()))
        return out

    def test_every_entry_falls_inside_its_bank(self):
        for p in range(N_BANKS):
            for i, ln in self.entries(p):
                a = int(ln.split()[0], 16)
                self.assertTrue(ORG[p] <= a < ORG[p] + BANK_SIZE,
                                "%s line %d: 0x%04X is outside the bank"
                                % (bank_name(p), i, a))

    def test_every_entry_has_its_justification(self):
        for p in range(N_BANKS):
            for i, ln in self.entries(p):
                self.assertIn("#", ln, "%s line %d: entry without a justification: %s"
                              % (bank_name(p), i, ln))
                self.assertGreater(len(ln.split("#", 1)[1].strip()), 8,
                                   "%s line %d: the justification says nothing: "
                                   "%s" % (bank_name(p), i, ln))


class TestFigures(unittest.TestCase):
    """The published figures have to be the ones in the tree."""

    def counts(self):
        code = 0
        for p in range(N_BANKS):
            path = os.path.join(WORK, "%s.trace.json" % bank_name(p))
            if not os.path.exists(path):
                self.skipTest("the traces are missing; run `make trace`")
            with open(path, encoding="utf-8") as f:
                code += json.load(f)["report"]["code_bytes"]
        return code

    def test_readmes_publish_the_notes_counts(self):
        counts = {key: len(all_directives(key)) for key in "LCD"}
        for fname, rows in (
                ("README.md", (("named labels", "L"),
                               ("anchored comments", "C"),
                               ("explained data ranges", "D"))),
                ("README.es.md", (("etiquetas con nombre", "L"),
                                  ("comentarios anclados", "C"),
                                  ("rangos de datos con explicación", "D")))):
            path = os.path.join(ROOT, fname)
            if not os.path.exists(path):
                continue
            with open(path, encoding="utf-8") as f:
                text = f.read()
            for label, key in rows:
                row = re.search(r"\|\s*%s\s*\|\s*([0-9.,]+)\s*\|"
                                % re.escape(label), text)
                self.assertIsNotNone(row, "%s does not publish '%s'"
                                     % (fname, label))
                says = int(row.group(1).replace(".", "").replace(",", ""))
                self.assertEqual(says, counts[key],
                                 "%s says %d %s and the notes have %d"
                                 % (fname, says, label, counts[key]))

    def test_readmes_publish_the_code_bytes(self):
        code = self.counts()
        for fname, label in (("README.md", "traced code"),
                             ("README.es.md", "código trazado")):
            path = os.path.join(ROOT, fname)
            if not os.path.exists(path):
                continue
            with open(path, encoding="utf-8") as f:
                text = f.read()
            row = re.search(r"\|\s*%s\s*\|\s*([0-9.,]+)" % re.escape(label),
                            text)
            self.assertIsNotNone(row, "%s does not publish '%s'" % (fname, label))
            says = int(row.group(1).replace(".", "").replace(",", ""))
            self.assertEqual(says, code, "%s says %d bytes of code and the "
                             "trace gives %d" % (fname, says, code))


# --------------------------------------------------------------------------
# The claims published on the website and in the listing blocks, tied to the
# bytes. The cartridge is not needed: the bytes are read from the listing
# itself, which is what gets published and what `make verify` proves
# reassembles into the exact ROM. If any of them stops being true, the test
# fails before the website lies.
# --------------------------------------------------------------------------

_DEF = re.compile(r"^\s+def(b|w)\s+([^;]+);\s*([0-9a-f]{4})")


def listing_bytes(p):
    """address -> byte, taken from the defb/defw lines of the listing."""
    out = {}
    for line in asm(p).splitlines():
        m = _DEF.match(line)
        if not m:
            continue
        width = 1 if m.group(1) == "b" else 2
        pos = int(m.group(3), 16)
        for chunk in m.group(2).split(","):
            chunk = chunk.strip()
            if not chunk.endswith("h"):
                continue
            v = int(chunk[:-1], 16)
            for i in range(width):
                out[pos] = (v >> (8 * i)) & 0xFF
                pos += 1
    return out


def word_at(data, addr):
    return data[addr] | (data[addr + 1] << 8)


class TestTheCartridge(unittest.TestCase):
    """What the website claims, measured on the data in the listing."""

    @classmethod
    def setUpClass(cls):
        cls.p00 = listing_bytes(0)
        cls.p01 = listing_bytes(1)

    def test_vdp_lays_out_vram_backwards(self):
        """Patterns at 0x2000 and colours at 0x0000, the reverse of the BIOS."""
        regs = [self.p00[0x575A + i] for i in range(8)]
        self.assertEqual(regs, [0x02, 0xE2, 0x0E, 0x7F, 0x07, 0x76, 0x03, 0xE4])
        self.assertEqual((regs[4] & 0x04) << 11, 0x2000, "patterns")
        self.assertEqual((regs[3] & 0x80) << 6, 0x0000, "colours")
        self.assertEqual(regs[2] * 0x400, 0x3800, "name table")
        self.assertEqual(regs[5] * 0x80, 0x3B00, "sprite attributes")
        self.assertEqual(regs[6] * 0x800, 0x1800, "sprite patterns")

    def test_konamis_hidden_mark(self):
        """RC-742 and the eight katakana, at the end of bank 3."""
        data = listing_bytes(3)
        mark = [data[0xBFF5 + i] for i in range(11)]
        # The first eight are the title in katakana written backwards, the
        # 0x08 says how many there are, and 0x42 0xAA is the RC-742.
        self.assertEqual(mark, [0x8C, 0x82, 0xB4, 0xB7, 0x92, 0xA6, 0xB7, 0x87,
                                0x08, 0x42, 0xAA])

    def test_checkpoints_are_eleven_and_stage_12_overruns(self):
        """The table at 0x4214 only goes up to stage 11."""
        values = [word_at(self.p00, 0x4212 + 2 * f) for f in range(1, 12)]
        self.assertEqual(values, [0xF8, 0x100, 0xF2, 0x100, 0x100, 0x100,
                                  0xF8, 0x100, 0x100, 0x100, 0x100])
        # Stage 12 would read at 0x422A, which is no longer data: code starts
        # there, and that is why 0x422A does not appear in the defb/defw of
        # the listing.
        self.assertNotIn(0x422A, self.p00,
                         "0x422A is no longer code: stage 12 no longer overruns")
        self.assertIn("call load_stage_font", asm(0))

    def test_stages_3_and_6_have_no_terrain(self):
        """Their script range is 0xFFFF: the incoming column is always sky."""
        for stage in range(1, 13):
            start = word_at(self.p00, 0x4499 + 6 * stage)
            no_script = start == 0xFFFF
            self.assertEqual(no_script, stage in (3, 6),
                             "stage %d %s script range"
                             % (stage, "has no" if no_script else "has a"))

    def test_the_two_type_tables_pair_up(self):
        """Thirty-one types, each with its mover and its finishing routine."""
        movers = [word_at(self.p00, 0x5DFD + 2 * i) for i in range(31)]
        finishers = [word_at(self.p01, 0x6B46 + 2 * i) for i in range(31)]
        # Type 7, the enemy that comes out of the hatch, is the only one with
        # its mover routine in bank 0 and its finishing routine in bank 1: if
        # this changes, the type map published on the website is no longer
        # valid.
        self.assertEqual(movers[6], 0x5EE7)
        self.assertEqual(finishers[6], 0x6C3F)

        # Twenty of the thirty-one have at least one of the two routines in
        # bank 3, and sixteen have both. That is the figure the website
        # publishes.
        def in_bank_3(d):
            return 0xA000 <= d < 0xC000
        either = sum(1 for m, r in zip(movers, finishers) if in_bank_3(m) or in_bank_3(r))
        both = sum(1 for m, r in zip(movers, finishers) if in_bank_3(m) and in_bank_3(r))
        self.assertEqual((either, both), (20, 16))

    def test_star_row_always_falls_inside(self):
        """The 32 rows at 0x478E go from 1 to 0x14: they never go past 22."""
        rows = [self.p00[0x478E + i] for i in range(32)]
        self.assertTrue(all(1 <= f <= 22 for f in rows), rows)

    def test_the_six_intro_blocks_chain(self):
        """Each compressed block ends exactly where the next one starts."""
        data = listing_bytes(9)

        def length(start):
            p = start
            while True:
                m = data[p]
                p += 1
                if m == 0x00:
                    return p - start
                if m == 0x80:
                    p += 2
                elif m & 0x80:
                    p += m & 0x7F
                else:
                    p += 1
        sites = [0x8300, 0x87FA, 0x8CB2, 0x917E, 0x9515, 0x989F]
        for cur, nxt in zip(sites, sites[1:]):
            self.assertEqual(cur + length(cur), nxt,
                             "the block at 0x%04X does not end at 0x%04X"
                             % (cur, nxt))

    def test_chip_filler(self):
        """48,219 bytes declared as filler, four banks empty from end to end.

        Of those 48,219, 47,820 are tails at the end of a bank and 399 are the
        gap left inside bank 3 between the last data and the Konami mark.
        """
        tail = empty = 0
        for p in range(N_BANKS):
            for line in directives(p, "D"):
                parts = line.split()
                if len(parts) < 4 or parts[3] != "filler":
                    continue
                length = int(parts[2], 16) - int(parts[1], 16)
                tail += length
                if length == BANK_SIZE:
                    empty += 1
        self.assertEqual(tail, 48219)
        self.assertEqual(empty, 4)
        # The gap inside bank 3, in front of the mark.
        self.assertEqual(tail - 47820, 399)

    def test_stage_order_and_the_four_bonus_stages(self):
        """1-2-9-3-10-4-11-5-6-7-12-8: the eight jumps that build it."""
        listing = asm(1)
        # The four that ENTER the bonus stages, from stages 2, 3, 4 and 7.
        for stage, site in ((0x09, "6d71"), (0x0A, "6db2"),
                            (0x0B, "6e20"), (0x0C, "6f24")):
            self.assertIn("ld a,0%02xh		;%s" % (stage, site), listing,
                          "stage 0x%02X is no longer jumped to from 0x%s"
                          % (stage, site))
        # And the four that LEAVE them, to stages 3, 4, 5 and 8.
        for stage, site in ((0x03, "6f9c"), (0x04, "6fa5"),
                            (0x05, "6fae"), (0x08, "6fb7")):
            self.assertIn("ld a,0%02xh		;%s" % (stage, site), listing,
                          "the bonus stage at 0x%s no longer returns to 0x%02X"
                          % (site, stage))
        # The four return stages are exactly stages_per_round.
        self.assertEqual([self.p00[0x418F + i] for i in range(4)],
                         [0x03, 0x04, 0x05, 0x08])
        # And the only thing that stops the screen (what opens the bonus) is
        # 0xB130.
        stops = [l for l in asm(3).splitlines()
                 if "ld (0e1c0h),a" in l]
        self.assertEqual(len(stops), 2, stops)   # 0xB054 sets 2, 0xB130 sets 1

    def test_the_two_sets_of_map_pieces(self):
        """Stages 5, 9, 10 and 12 read the pieces from 0x8FF0, the rest from 0x8000."""
        # The comparison that decides it is at 0x46F5, and it can be read in
        # the listing.
        listing = asm(0)
        for stage in ("005h", "009h", "00ah", "00ch"):
            self.assertIn("cp %s" % stage, listing)
        self.assertIn("ld de,08ff0h", listing)
        self.assertIn("ld de,08000h", listing)


if __name__ == "__main__":
    unittest.main()

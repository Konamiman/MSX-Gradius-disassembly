#!/usr/bin/env python3
"""Checks on the sources and on what they build.

They make sure the disassembly does not degrade without anyone noticing:
that the sources and the Makefile agree, that no data is left without its
explanation, that the published figures are the ones in the tree, and that
what the website claims is still true of the bytes.

The ones about bytes and figures need the ROM that the sources build
(`make rom`; `make verify` proves it is the original cartridge, byte for
byte). The original cartridge itself is not needed. Without a build, those
tests are skipped.
"""
import os
import re
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))

from banks import ORG, BANK_SIZE, N_BANKS, bank_name     # noqa: E402
import check_code                                         # noqa: E402

SRC = os.path.join(ROOT, "src")
BUILD = os.path.join(ROOT, "build")
ROM = os.path.join(BUILD, "nemesis.rom")

# image -> its banks. The same as the Makefile and tools/check_code.py.
IMAGES = {"main": [0, 1, 2, 3], "scenery": [4, 5, 6], "sound": [7, 8],
          "screens": [9, 10], "map": [11, 12]}

# The other games in the series. Another one's name showing up in a page of
# this one is almost always a copy-and-paste, and five licences have already
# been published naming the wrong game.
OTHER_GAMES = ("Pitfall", "Temptations", "Stardust", "Ale Hop", "Colt 36",
               "Middle Earth", "Monkey", "F-1 Spirit", "Athletic",
               "Antarctic", "Pippols", "Frogger", "Time Pilot",
               "Super Cobra", "Billiards", "Mahjong", "Hyper Olympic",
               "Hyper Sports", "Hyper Rally", "Demonia", "Cabbage")


def module_files(image=None):
    out = []
    for img in IMAGES if image is None else [image]:
        d = os.path.join(SRC, img)
        out += [os.path.join(d, f) for f in sorted(os.listdir(d)) if f.endswith(".asm")]
    return out


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def image_text(image):
    return "\n".join(read(p) for p in module_files(image))


def makefile():
    return read(os.path.join(ROOT, "Makefile")).replace("\\\n", " ")


def makefile_modules(image):
    m = re.search(r"(?m)^%s\s*=\s*(.*)$" % image.upper(), makefile())
    return [w for w in m.group(1).split() if not w.startswith("@")]


def need_build(test):
    if not os.path.exists(ROM):
        test.skipTest("the ROM has not been built; run `make rom`")


class TestBanks(unittest.TestCase):
    """The bank -> org rule, which everything else hangs from."""

    def test_all_sixteen_banks_have_an_org(self):
        self.assertEqual(sorted(ORG), list(range(N_BANKS)))

    def test_orgs_are_the_mapper_ones(self):
        for p, o in ORG.items():
            self.assertIn(o, (0x4000, 0x6000, 0x8000, 0xA000),
                          "%s has an org the mapper cannot give" % bank_name(p))
        self.assertEqual(ORG[0], 0x4000, "bank 0 is the fixed one")

    def test_each_image_is_consecutive_banks_at_consecutive_addresses(self):
        for image, banks in IMAGES.items():
            for a, b in zip(banks, banks[1:]):
                self.assertEqual(b, a + 1, "%s: banks are not consecutive" % image)
                self.assertEqual(ORG[b], ORG[a] + BANK_SIZE,
                                 "%s: bank %d does not follow bank %d" % (image, b, a))
            self.assertEqual(ORG[banks[-1]] + BANK_SIZE, 0xC000,
                             "%s does not end at 0xBFFF" % image)

    def test_makefile_links_each_image_at_its_first_bank(self):
        text = makefile()
        for image, banks in IMAGES.items():
            row = re.search(r"(?m)^ORG_%s\s*=\s*([0-9A-Fa-f]+)h" % image, text)
            self.assertIsNotNone(row, "the Makefile does not declare ORG_%s" % image)
            self.assertEqual(int(row.group(1), 16), ORG[banks[0]],
                             "the Makefile and tools/banks.py disagree about %s" % image)

    def test_the_images_and_the_empty_banks_cover_the_cartridge(self):
        banks = sorted(b for bs in IMAGES.values() for b in bs)
        self.assertEqual(banks + [13, 14, 15], list(range(N_BANKS)))


class TestSources(unittest.TestCase):

    def test_makefile_and_src_list_the_same_modules(self):
        for image in IMAGES:
            listed = sorted(makefile_modules(image))
            present = sorted(os.path.basename(p)[:-4] for p in module_files(image))
            self.assertEqual(listed, present, "%s: Makefile and src/%s disagree"
                             % (image, image))

    def test_every_module_ends_with_end(self):
        for path in module_files():
            lines = [l for l in read(path).splitlines() if l.strip()]
            self.assertEqual(lines[-1].strip().lower(), "end", path)

    def test_no_address_columns(self):
        """Addresses go stale as soon as anything moves: N80's listing has them."""
        for path in module_files():
            for i, line in enumerate(read(path).splitlines(), 1):
                code, sep, comment = line.partition(";")
                if code.startswith("\t") and sep:
                    self.assertIsNone(re.match(r"[0-9a-f]{4}(\s|$)", comment),
                                      "%s:%d still has an address column" % (path, i))

    def test_no_unexplained_data(self):
        """Every data line is under a `; DATA name: ...` header."""
        self.assertEqual(check_code.unexplained_data(SRC), {})

    def test_every_data_header_is_followed_by_its_label(self):
        for path in module_files():
            lines = read(path).splitlines()
            for i, line in enumerate(lines):
                m = re.match(r"^; DATA (\S+?)(?: \(part\))?(?::|$)", line)
                if not m:
                    continue
                rest = lines[i + 1:]
                first_code = next(k for k, l in enumerate(rest) if l.startswith("\t"))
                labels = [l for l in rest[:first_code] if re.match(r"^[A-Za-z_]\w*:", l)]
                self.assertTrue(labels, "%s: the DATA header of %s has no label"
                                % (path, m.group(1)))

    # How many routines are called with `call` and are still unnamed, by the
    # bank that holds them. IT IS NOT A TARGET: it is the DEBT left to
    # comment, and the test is there so that it can only go down. When a
    # routine gets named, the figure here has to be lowered too, and that way
    # nobody can undo work without the test calling it out.
    UNNAMED_CEILING = {0: 4, 1: 2, 2: 13, 3: 1, 7: 0, 10: 0}

    def test_routine_naming_debt_does_not_grow(self):
        found = {}
        for image, banks in IMAGES.items():
            for name in set(re.findall(r"\bcall (?:n?[zc],|p[oe],|[mp],)?(L_[0-9A-F]{4})",
                                       image_text(image))):
                a = int(name[2:], 16)
                bank = banks[(a - ORG[banks[0]]) // BANK_SIZE]
                found.setdefault(bank, []).append(name)
        for bank, names in sorted(found.items()):
            ceiling = self.UNNAMED_CEILING.get(bank, 0)
            self.assertLessEqual(
                len(names), ceiling,
                "bank %d: %d routines called and unnamed, and the ceiling is %d. "
                "If you have named one, lower the ceiling; if you have removed "
                "a name, put it back. The first ones: %s"
                % (bank, len(names), ceiling, " ".join(sorted(names)[:12])))

    def test_sources_do_not_mention_another_game(self):
        for path in module_files():
            text = read(path)
            for game in OTHER_GAMES:
                self.assertNotIn(game, text, "%s mentions %s" % (path, game))

    def test_root_does_not_mention_another_game(self):
        for fname in ("README.md", "README.es.md", "AVISO-LEGAL.md",
                      "LEGAL-NOTICE.md", "LICENSE", "Makefile"):
            path = os.path.join(ROOT, fname)
            if not os.path.exists(path):
                continue
            for game in OTHER_GAMES:
                self.assertNotIn(game, read(path), "%s mentions %s" % (fname, game))

    def test_tools_do_not_mention_another_game(self):
        for fn in sorted(os.listdir(os.path.join(ROOT, "tools"))):
            if not fn.endswith(".py"):
                continue
            text = read(os.path.join(ROOT, "tools", fn))
            for game in OTHER_GAMES:
                self.assertNotIn(game, text, "tools/%s mentions %s" % (fn, game))


class TestFigures(unittest.TestCase):
    """The published figures have to be the ones in the tree."""

    def test_readmes_and_website_publish_the_real_figures(self):
        need_build(self)
        import figures
        counts = figures.count()
        for fname, (_sep, rows) in figures.ROWS.items():
            text = read(os.path.join(ROOT, fname))
            for label, key in rows:
                row = re.search(r"\|\s*%s\s*\|\s*([0-9.,]+)" % re.escape(label), text)
                self.assertIsNotNone(row, "%s does not publish '%s'" % (fname, label))
                says = int(row.group(1).replace(".", "").replace(",", ""))
                self.assertEqual(says, counts[key], "%s says %d %s and the tree has %d;"
                                 " run `make figures`" % (fname, says, label, counts[key]))
        web = read(os.path.join(ROOT, "tools", "make_web.py"))
        for name, key in (("CODE_BYTES", "code"), ("DATA_BYTES", "data"),
                          ("ROUTINES", "routines")):
            m = re.search(r"(?m)^%s = (\d+)$" % name, web)
            self.assertEqual(int(m.group(1)), counts[key],
                             "tools/make_web.py: %s; run `make figures`" % name)


# --------------------------------------------------------------------------
# The claims published on the website and in the comments, tied to the
# bytes. They are read from the ROM that the sources build, which is what
# `make verify` proves is the original. If any of them stops being true, the
# test fails before the website lies.
# --------------------------------------------------------------------------

class TestTheCartridge(unittest.TestCase):
    """What the website claims, measured on the built ROM."""

    @classmethod
    def setUpClass(cls):
        cls.rom = None
        if os.path.exists(ROM):
            with open(ROM, "rb") as f:
                cls.rom = f.read()

    def setUp(self):
        need_build(self)

    def byte(self, bank, addr):
        return self.rom[bank * BANK_SIZE + addr - ORG[bank]]

    def word(self, bank, addr):
        return self.byte(bank, addr) | (self.byte(bank, addr + 1) << 8)

    def test_vdp_lays_out_vram_backwards(self):
        """Patterns at 0x2000 and colours at 0x0000, the reverse of the BIOS."""
        regs = [self.byte(0, 0x575A + i) for i in range(8)]
        self.assertEqual(regs, [0x02, 0xE2, 0x0E, 0x7F, 0x07, 0x76, 0x03, 0xE4])
        self.assertEqual((regs[4] & 0x04) << 11, 0x2000, "patterns")
        self.assertEqual((regs[3] & 0x80) << 6, 0x0000, "colours")
        self.assertEqual(regs[2] * 0x400, 0x3800, "name table")
        self.assertEqual(regs[5] * 0x80, 0x3B00, "sprite attributes")
        self.assertEqual(regs[6] * 0x800, 0x1800, "sprite patterns")

    def test_konamis_hidden_mark(self):
        """RC-742 and the eight katakana, at the end of bank 3."""
        mark = [self.byte(3, 0xBFF5 + i) for i in range(11)]
        # The first eight are the title in katakana written backwards, the
        # 0x08 says how many there are, and 0x42 0xAA is the RC-742.
        self.assertEqual(mark, [0x8C, 0x82, 0xB4, 0xB7, 0x92, 0xA6, 0xB7, 0x87,
                                0x08, 0x42, 0xAA])

    def test_checkpoints_are_eleven_and_stage_12_overruns(self):
        """The table at 0x4214 only goes up to stage 11."""
        values = [self.word(0, 0x4212 + 2 * f) for f in range(1, 12)]
        self.assertEqual(values, [0xF8, 0x100, 0xF2, 0x100, 0x100, 0x100,
                                  0xF8, 0x100, 0x100, 0x100, 0x100])
        # Stage 12 would read at 0x422A, which is no longer data: code starts
        # there. It is the first instruction of stage_graphics.asm.
        bases = check_code.link_map(os.path.join(BUILD, "main.map"))
        self.assertEqual(bases["stage_graphics"], 0x422A)
        first = check_code.source_items(os.path.join(BUILD, "main", "stage_graphics.lst"))[0]
        self.assertEqual(first[:2], (0, "code"),
                         "0x422A is no longer code: stage 12 no longer overruns")
        self.assertIn("call load_stage_font", image_text("main"))

    def test_stages_3_and_6_have_no_terrain(self):
        """Their script range is 0xFFFF: the incoming column is always sky."""
        for stage in range(1, 13):
            no_script = self.word(0, 0x4499 + 6 * stage) == 0xFFFF
            self.assertEqual(no_script, stage in (3, 6),
                             "stage %d %s script range"
                             % (stage, "has no" if no_script else "has a"))

    def test_the_two_type_tables_pair_up(self):
        """Thirty-one types, each with its mover and its finishing routine."""
        movers = [self.word(0, 0x5DFD + 2 * i) for i in range(31)]
        finishers = [self.word(1, 0x6B46 + 2 * i) for i in range(31)]
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
        rows = [self.byte(0, 0x478E + i) for i in range(32)]
        self.assertTrue(all(1 <= f <= 22 for f in rows), rows)

    def test_the_six_intro_blocks_chain(self):
        """Each compressed block ends exactly where the next one starts."""
        def length(start):
            p = start
            while True:
                m = self.byte(9, p)
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
                             "the block at 0x%04X does not end at 0x%04X" % (cur, nxt))

    def test_chip_filler(self):
        """48,219 bytes of 0xFF filler, four banks empty from end to end.

        Of those 48,219, 47,820 are tails at the end of a bank and 399 are the
        gap left inside bank 3 between the last data and the Konami mark. The
        filler is what the link puts where no module is: it is measured on the
        link maps.
        """
        gaps = {}
        for image, banks in IMAGES.items():
            org = ORG[banks[0]]
            used = sorted(re.findall(r"Code segment: ([0-9A-F]+)h to ([0-9A-F]+)h",
                                     read(os.path.join(BUILD, image + ".map"))))
            pos = org
            for a, b in ((int(a, 16), int(b, 16)) for a, b in used):
                if a > pos:
                    gaps[(image, pos)] = a - pos
                pos = b + 1
            if pos < 0xC000:
                gaps[(image, pos)] = 0xC000 - pos
        filler = sum(gaps.values()) + 3 * BANK_SIZE     # banks 13, 14 and 15
        self.assertEqual(filler, 48219)
        self.assertTrue(all(self.rom[i] == 0xFF for i in range(6 * BANK_SIZE, 7 * BANK_SIZE)),
                        "bank 6 is not empty")
        # The gap inside bank 3, in front of the mark.
        self.assertEqual(gaps[("main", 0xBFF5 - 399)], 399)

    def test_stage_order_and_the_four_bonus_stages(self):
        """1-2-9-3-10-4-11-5-6-7-12-8: the eight jumps that build it."""
        # The four that ENTER the bonus stages, from stages 2, 3, 4 and 7, and
        # the four that LEAVE them, to stages 3, 4, 5 and 8: each an
        # `ld a,stage` (3E nn) at a known place of bank 1.
        for stage, site in ((0x09, 0x6D71), (0x0A, 0x6DB2), (0x0B, 0x6E20), (0x0C, 0x6F24),
                            (0x03, 0x6F9C), (0x04, 0x6FA5), (0x05, 0x6FAE), (0x08, 0x6FB7)):
            self.assertEqual((self.byte(1, site), self.byte(1, site + 1)), (0x3E, stage),
                             "no `ld a,0%02xh` at 0x%04X any more" % (stage, site))
        # The four return stages are exactly stages_per_round.
        self.assertEqual([self.byte(0, 0x418F + i) for i in range(4)],
                         [0x03, 0x04, 0x05, 0x08])
        # And the only thing that stops the screen (what opens the bonus) is
        # 0xB130: the two writes to 0xE1C0 in bank 3 are at 0xB054 (sets 2)
        # and 0xB130 (sets 1).
        stores = []
        for mod, base in check_code.link_map(os.path.join(BUILD, "main.map")).items():
            for rel, kind, size in check_code.source_items(
                    os.path.join(BUILD, "main", mod + ".lst")):
                a = base + rel
                if kind == "code" and 0xA000 <= a < 0xC000 and \
                        [self.byte(3, a + i) for i in range(3)] == [0x32, 0xC0, 0xE1]:
                    stores.append(a)
        self.assertEqual(stores, [0xB054, 0xB130])

    def test_the_two_sets_of_map_pieces(self):
        """Stages 5, 9, 10 and 12 read the pieces from 0x8FF0, the rest from 0x8000."""
        # The comparison that decides it is at 0x46F5, and it can be read in
        # the sources.
        text = image_text("main")
        for stage in ("005h", "009h", "00ah", "00ch"):
            self.assertIn("cp %s" % stage, text)
        self.assertIn("ld de,08ff0h", text)
        self.assertIn("ld de,08000h", text)


if __name__ == "__main__":
    unittest.main()

"""No block header may appear duplicated in the listing.

`mkasm.py` gathers into ONE frame all the `B` lines of the same address, so a
multi-line header is legitimate and normal. What is not: the SAME line (same
address and same text) twice. That only happens in one way, which is that the
comment applier is run several times per project and until now did not filter
the B lines. In Mopi Ranger there were 1,731 B lines for 142 headers: the same
sentence up to twenty times in a row inside the same frame, and 232 KB of
listing that said nothing.

It breaks nothing (the listing assembles the same and the density does not
change, because headers do not count as line comments), and that is why no
test saw it. It only shows when reading the .asm.

Decorative lines are left out of the count: a framed header repeats the same
rule above and below on purpose.

This file is the same in all the repositories of the series: if it is fixed
here, the fix has to be carried over to the others.
"""

import collections
import glob
import os
import re
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

HEADER = re.compile(r"^B\s+(0x[0-9a-fA-F]{4})\s+(.*)$")
DECORATIVE = re.compile(r"^[-=#*_~+.:\s]*$")


class TestBlockHeaders(unittest.TestCase):

    def test_no_header_line_is_repeated(self):
        bad = []
        notes = sorted(glob.glob(os.path.join(ROOT, "src", "*.notes")))
        self.assertTrue(notes, "there is no .notes file in src/")
        for path in notes:
            count = collections.Counter()
            with open(path, encoding="utf-8") as f:
                for ln in f:
                    m = HEADER.match(ln.rstrip())
                    if m and not DECORATIVE.match(m.group(2)):
                        count[(m.group(1), m.group(2).rstrip())] += 1
            extra = sum(v - 1 for v in count.values() if v > 1)
            if extra:
                bad.append("%s: %d surplus B lines in %d headers"
                           % (os.path.basename(path), extra,
                              sum(1 for v in count.values() if v > 1)))
        self.assertEqual(bad, [], "; ".join(bad))


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Checks that the website has no broken links or images.

It is a dumb check but a necessary one: the website is bilingual, with
cross-linked documents, and moving a single file is enough to leave half a
dozen links dangling without anything warning about it.

Usage: check_links.py <website directory>
"""
import os
import re
import sys


def main(web_root):
    broken, total = [], 0
    for root, _, files in os.walk(web_root):
        for fn in files:
            if not fn.endswith(".html"):
                continue
            p = os.path.join(root, fn)
            text = open(p, encoding="utf-8").read()
            for m in re.finditer(r'(?:href|src)="([^"]+)"', text):
                dest = m.group(1)
                if dest.startswith(("http", "#", "data:", "mailto:")):
                    continue
                total += 1
                target = os.path.normpath(
                    os.path.join(root, dest.split("#")[0]))
                if not os.path.exists(target):
                    broken.append((p, dest))
    for p, d in broken:
        print(f"  BROKEN  {p}  ->  {d}")
    print(f"{total} local links checked, {len(broken)} broken")
    return 1 if broken else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "docs"))

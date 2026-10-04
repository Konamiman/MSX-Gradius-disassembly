#!/usr/bin/env python3
"""Trace sanity check: detects false coverage.

Why it exists: when the tracer was seeded with targets taken from pointer
tables, the coverage jumped from 13% to 80%. It looked like a success, but it
was false: four of the seeds were false positives pointing at graphics areas,
and from there the tracer kept "decoding" pixels as instructions until it had
marked as code 100% of the colour table and of the ending texts.

A disassembly with that trace still reassembles fine (the bytes do not change,
only their interpretation), so `make verify` does NOT detect it. This separate
check is needed: if an area we know is data shows up as code, the trace is
contaminated and the listing lies.

Usage: check_trace.py <trace.json> <nocode> [threshold_pct]
"""
import json
import sys


def main(tracepath, nocodepath, threshold=5):
    tr = json.load(open(tracepath))
    zones = []
    for ln in open(nocodepath):
        txt = ln.split("#")
        fields = txt[0].split()
        if len(fields) >= 2:
            zones.append((int(fields[0], 0), int(fields[1], 0),
                          txt[1].strip() if len(txt) > 1 else ""))
    if not zones:
        print("no zones declared as data; nothing to check")
        return 0

    # Map of which bytes the tracer has marked as code
    lo = min(a for _, a, b in tr["blocks"] for a in (a,))
    hi = max(b for _, a, b in tr["blocks"])
    code = bytearray(hi - lo)
    for kind, a, b in tr["blocks"]:
        if kind == "c":
            for i in range(a - lo, b - lo):
                code[i] = 1

    print(f"Trace sanity check ({len(zones)} known data zones)")
    bad = 0
    for a, b, desc in zones:
        start, end = max(a, lo), min(b, hi)
        if end <= start:
            continue
        n = sum(code[start - lo:end - lo])
        pct = n * 100 // (end - start)
        status = "ok" if pct <= threshold else "CONTAMINATED"
        if pct > threshold:
            bad += 1
        print(f"  {a:#06x}..{b:#06x}  code={pct:3d}%  {status:12s} {desc}")

    if bad:
        print(f"\nFAIL: {bad} data zones show up as code. The trace is")
        print("contaminated: check the seeds in src/*.entries, one of them points at data.")
        return 1
    print("\nOK: no known data zone has been marked as code")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1], sys.argv[2],
                  int(sys.argv[3]) if len(sys.argv) > 3 else 5))

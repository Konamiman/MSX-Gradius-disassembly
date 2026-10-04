#!/bin/sh
# The 16 reassembled banks, concatenated in order, have to give the whole ROM
# byte for byte. It is the final test: verify_build.sh already checked each
# bank separately, but what is published is a 128 KB disassembly and it has to
# add up as such.
#
# Usage: verify_rom.sh <work_dir> <original_rom> <expected_sha256>

set -e
WORK="$1"
ROM="$2"
SHA="$3"
OUT="$WORK/nemesis_reassembled.rom"

rm -f "$OUT"
for p in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15; do
    if [ ! -f "$WORK/p$p.out.bin" ]; then
        echo "FAILED: $WORK/p$p.out.bin is missing (assemble the 16 banks first)"
        exit 1
    fi
    cat "$WORK/p$p.out.bin" >> "$OUT"
done

SZ_A=$(wc -c < "$OUT" | tr -d ' ')
SZ_B=$(wc -c < "$ROM" | tr -d ' ')
H_A=$(shasum -a 256 "$OUT" | cut -d' ' -f1)
H_B=$(shasum -a 256 "$ROM" | cut -d' ' -f1)
echo "== the 16 banks concatenated =="
echo "  reassembled  : $SZ_A bytes  $H_A"
echo "  original     : $SZ_B bytes  $H_B"
echo "  expected     :              $SHA"
if [ "$H_A" = "$H_B" ] && [ "$H_A" = "$SHA" ]; then
    echo "OK: the whole ROM reproducible byte for byte"
    exit 0
fi
echo "DIFFERS"
exit 1

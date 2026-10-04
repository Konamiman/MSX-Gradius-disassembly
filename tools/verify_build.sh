#!/bin/sh
# Reproducibility check of ONE bank: assembles its listing and checks that
# EXACTLY its 8192 bytes come out, byte for byte.
#
# It is the criterion that decides whether the disassembly is reliable. Until
# this is green, any modification of the game is done blindly: there would be
# no way of knowing whether a change in behaviour comes from what we touched or
# from an error in the disassembly itself.
#
# The assembled binary is left in work/ (not in /tmp, which is not reliable
# under the msys make on Windows) so that verify_rom.sh can concatenate the 16
# banks.
#
# Usage: verify_build.sh <listing.asm> <original_bank.bin> <org> <output.bin>

set -e
ASM="$1"
ORIG="$2"
ORG="$3"
OUT="$4"
ERR="$(dirname "$OUT")/pasmo.err"

echo "== assembling $ASM (org $ORG) =="
if ! pasmo --bin "$ASM" "$OUT" 2>"$ERR"; then
    echo "FAILED: pasmo could not assemble. First errors:"
    head -20 "$ERR"
    exit 1
fi

SZ_A=$(wc -c < "$OUT" | tr -d ' ')
SZ_B=$(wc -c < "$ORIG" | tr -d ' ')
H_A=$(shasum -a 256 "$OUT"  | cut -d' ' -f1)
H_B=$(shasum -a 256 "$ORIG" | cut -d' ' -f1)

echo "  assembled  : $SZ_A bytes  $H_A"
echo "  original   : $SZ_B bytes  $H_B"

if [ "$H_A" = "$H_B" ]; then
    echo "OK: reproducible byte for byte"
    exit 0
fi

echo "DIFFERS. First mismatches:"
cmp -l "$OUT" "$ORIG" 2>/dev/null | head -20 || true
echo "(total differing bytes: $(cmp -l "$OUT" "$ORIG" 2>/dev/null | wc -l | tr -d ' '))"
exit 1

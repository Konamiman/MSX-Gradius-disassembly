# Nemesis / Gradius (Konami, 1986, MSX1) — disassembly

A byte-exact, reproducible disassembly of the 128 KB MegaROM cartridge
**Nemesis / Gradius**, Konami RC-742 (1986), for MSX1.

The sources are split into logical modules that are assembled one by one with
[Nestor80](https://github.com/Konamiman/Nestor80) and linked into place, and
**building them gives back the original ROM byte for byte** — all sixteen 8 KB
banks and the whole 131,072-byte image. That is the test that decides whether
a disassembly can be trusted; everything else in this repository exists to make
sure the sources do not *lie* about what they assemble.

*(Léeme en castellano: [README.es.md](README.es.md).)*

## Where it stands

| | |
|---|---|
| ROM | 131,072 bytes, sha256 `3210f8a0f2309dd4b9a89fc2b24d0f178ce4393a0a1f2854fbce545c361261bc` |
| reassembles byte for byte | yes, all 16 banks and the full image |
| bytes accounted for | **131,072 of 131,072 (100.00 %)** |
| traced code | 25,474 bytes |
| identified data | 105,598 bytes |
| unexplained | 0 bytes |
| modules | 72 |
| source lines | 23,372 |
| named routines | 914 |
| line comments | 2,981 |
| explained data ranges | 232 |

**23.0% of the instructions carry a line comment** — 2,980 of 12,959 across
the three images that hold code — and only **5 routines of the 1,539 are below
10%**, four of them short loops around a BIOS call. `make density` prints it
image by image, and `tests/test_sources.py` keeps a per-bank ceiling of how many
called routines still lack a name, so the number can only go down.

The website under [docs/](docs/) is built from the ROM that the sources
produce, and its twelve stage maps are drawn from it by `tools/graphics.py` — no
emulator captures anywhere.

## The cartridge

128 KB with the **Konami mapper WITHOUT SCC** (Konami4): sixteen 8 KB banks.
There is no register for 0x4000-0x5FFF — bank 0 is fixed there — and the other
three windows are selected by writing the bank number to 0x6000, 0x8000 and
0xA000. `tools/recon.py` measures this on the bytes: not one write to
0x5000, 0x7000, 0x9000 or 0xB000 (the SCC mapper's registers), and every one of
the 68 writes to the Konami4 registers carries a bank that matches the rule.

| bank | runs at | what it holds |
|---|---|---|
| 0 | 0x4000 (fixed) | header, INIT, interrupt, dispatcher, bank switching, game state machine |
| 1, 2, 3 | 0x6000 / 0x8000 / 0xA000 | the game code |
| 4, 5 | 0x6000 / 0x8000 | compressed stage graphics, and the six-byte records that load them |
| 6, 13, 14, 15 | — | 8,192 bytes of 0xFF each |
| 7, 8 | 0x8000 / 0xA000 | sound driver and sound data |
| 9, 10 | 0x8000 / 0xA000 | fixed screens, more graphics |
| 11, 12 | 0x8000 / 0xA000 | the map: 4x4-character pieces and the per-stage scripts |

## Three things the binary says

**One instruction is split across two banks.** At 0x7FFE (bank 1) there are
two bytes, `21 41`, and the third — the `80` — is the *first byte of bank 2*.
Together they are `ld hl,0x8041`, and execution carries on at 0x8001. It is
the only place in the cartridge where this happens, and it welds bank 1 to
bank 2. Code also runs straight across the 0x5FFF→0x6000 and 0x9FFF→0xA000
boundaries.

**The graphics format.** Routine 0x49B9 unpacks straight into VRAM, and it is
written back to front: bit 7 marks a *literal* run, not a repeat. `0x00` ends
the block, `0x01`-`0x7F` repeats the next byte N times, `0x80` means the next
two bytes are a new VRAM address, and `0x81`-`0xFF` copies N-0x80 literal
bytes. `tools/rle.py` implements it; the proof it is right is that the blocks
tile the data banks with not one byte of slack.

**Nemesis looks for another Konami cartridge.** Routine 0x508D reads six bytes
down from 0xBFFF in every other slot with RDSLT and compares them with
`AA 40 06 91 81 AC`. That is another cartridge's hidden Konami mark: RC-7**40**,
a six-character title, and its first three characters (stored reversed) are
`ツ イ ン`. If it matches, 0xF0F4 becomes 1 and extra graphics are loaded.

## The hidden Konami mark

At the end of bank 3 (file offset 0x07FF5) there are eleven bytes: the title
backwards, its length, the last two digits of the RC number in BCD, and 0xAA.
Here that reads RC-742 and グラディウス — *Gradius*. **This is not our
finding: Manuel Pazos (@ManuelPazosMSX) discovered it, and `tools/konami_mark.py`
only reads what he showed was there.** Note that in a MegaROM the mark is *not*
at the end of the file: 96 KB of data follow it.

## Building it

The sources build the cartridge by themselves: the original ROM is not needed,
and it is not distributed here. You need `make`, `python3` and Nestor80 (N80 and
LK80) in the PATH:

```sh
make verify      # assemble and link everything; check the sha256 of the result
make             # verify -> sanity -> tests
```

The result is `build/nemesis.rom`.

## How the sources are organised

The unit of the build is the **image**, not the ROM bank: the banks that the
game always maps together, which for the CPU are one stretch of memory. Each
image is linked in one LK80 run, so a module can cross from one bank into the
next: the instruction split between banks 1 and 2 is written as the single
instruction it is, and the sounds run on from bank 7 into bank 8.

| image | banks | address | modules |
|---|---|---|---|
| `main` | 0-3 | 0x4000-0xBFFF | 57, one per part of the game |
| `scenery` | 4-6 | 0x6000-0xBFFF | 2 |
| `sound` | 7-8 | 0x8000-0xBFFF | 8 |
| `screens` | 9-10 | 0x8000-0xBFFF | 3 |
| `map` | 11-12 | 0x8000-0xBFFF | 2 |

Banks 13, 14 and 15 are 0xFF and have no source; all the 0xFF filler of the
cartridge is put in by the linker. The main image calls the sound player and
the fixed-screen engine: those images are linked first, and they export the
symbols that main needs.

## What each check is for

`make verify` proves the bytes come back. The rest catch what it cannot:

- `tools/check_code.py` (`make sanity`) — the reassembly cannot tell code from
  data: a module that writes graphics as instructions still assembles to the
  right bytes; only the *reading* is a lie. The whole-cartridge tracer
  (`tools/bank_tracer.py`) follows the code from the two entry points the
  hardware guarantees, keeping track of which bank is in each slot, and the
  instructions in the sources have to be **exactly** the ones it reaches. It
  also checks that every data line is under a `; DATA` header that names and
  explains it. **0 bytes unexplained.**
- `tools/recon.py` — every write to the mapper obeys the bank → org rule.
- `tests/` — the published figures, and what the website claims about the
  bytes.

## Layout

```
src/<image>/*.asm   the modules, one directory per image
src/inc/            the BIOS entry points and the game's RAM variables
src/seeds.txt       the entry points the tracer cannot find on its own
tools/              the tracer, the checks and the website generators
build/              everything make produces (not in the repository); `make listing`
                    writes build/listing/<image>.lst, the sources with every address
```

## Legal

This is a study of a program published in 1986. See
[LEGAL-NOTICE.md](LEGAL-NOTICE.md). Nemesis / Gradius and the Konami name
belong to Konami. The ROM is not distributed here.

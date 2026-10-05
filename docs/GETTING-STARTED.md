# Getting started

A commented disassembly of **Nemesis / Gradius**, Konami's RC-742 for the MSX:
a 128 KB MegaROM with the Konami mapper without SCC. It reassembles into the
exact ROM, byte for byte, all sixteen banks, and every one of its 131,072 bytes
is accounted for.

## The cartridge is not here

No repository ships the game. The sources build it: you need `make`, `python3`
and Nestor80 (N80 and LK80), and `make verify` assembles every module, links
them and checks that the result, `build/nemesis.rom`, is the original
cartridge — 131072 bytes, sha256

    3210f8a0f2309dd4b9a89fc2b24d0f178ce4393a0a1f2854fbce545c361261bc

## What each command does

    make            build the ROM, check it, run the sanity checks and the tests
    make verify     the test that decides: the sources have to give the ROM back
    make sanity     that the code in the sources is exactly the code the game runs
    make density    how much is commented, routine by routine, image by image
    make recon      measures the mapper on the bytes: Konami4, no SCC
    make mark       the hidden Konami mark at the end of bank 3
    make web        rebuild this website from the ROM

## Sixteen banks, five images

A 16 KB cartridge is one program. This one is not. Bank 0 is fixed at
0x4000-0x5FFF and the other three windows are chosen by writing the bank number
to 0x6000, 0x8000 and 0xA000, so **the same address means different code
depending on what is mapped**. `tools/banks.py` fixes the one org each bank
actually executes at.

What the build links together is not the bank but the **image**: the banks
the game always maps at the same time, which for the CPU are one stretch of
memory. There are five — `main` (banks 0-3, the game), `scenery` (4-6),
`sound` (7-8), `screens` (9-10) and `map` (11-12) — and each one has its own
directory under `src/`, with one source file per part of the program. LK80
links each image in one run, so code and data can cross from one bank into the
next as they do in the cartridge. Banks 13, 14 and 15 are empty and have no
source.

Everything about a byte is in its source file: the instruction or the data,
the name of the routine or the table, and the comment. A `; DATA name: ...`
header explains every block of data.

## What the numbers mean

`make sanity` checks the code and prints the budget: **25,474 bytes of traced
code** and **105,598 bytes of data**, 0 unexplained, 131,072 in total. `make
density` prints the comment density per image: 12,959 instructions, 2,980 line
comments, **23.0%**, and 5 routines below 10% out of 1,539.

Every figure on this site comes from those two commands, not from an estimate.

## The pictures are drawn, not captured

There is no emulator capture on this site. `tools/graphics.py` runs the
cartridge's own routines in Python — the run-length decompressor at 0x49B9, the
character loader at 0x42FC, the mirror lists, and the column builder at
0x46AE — and draws the twelve stage maps and the title screen straight from the
bytes. `make web` regenerates them.

# Getting started

A commented disassembly of **Nemesis / Gradius**, Konami's RC-742 for the MSX:
a 128 KB MegaROM with the Konami mapper without SCC. It reassembles into the
exact ROM, byte for byte, all sixteen banks, and every one of its 131,072 bytes
is accounted for.

## The cartridge is not here

No repository ships the game. Put your own dump in the root as `nemesis.rom`,
131072 bytes, sha256

    3210f8a0f2309dd4b9a89fc2b24d0f178ce4393a0a1f2854fbce545c361261bc

`make comprueba` checks it.

## What each command does

    make            trace the flow, build the listing, reassemble it, run the tests
    make verify     the test that decides: reassembling has to give the ROM back
    make sanity     that not one byte is left unexplained, and no data reads as code
    make densidad   how much is commented, routine by routine, bank by bank
    make reconoce   measures the mapper on the bytes: Konami4, no SCC
    make marca      the hidden Konami mark at the end of bank 3
    make web        rebuild this website from the ROM and the notes

## Sixteen banks, sixteen listings

A 16 KB cartridge is one listing. This one is not. Bank 0 is fixed at
0x4000-0x5FFF and the other three windows are chosen by writing the bank number
to 0x6000, 0x8000 and 0xA000, so **the same address means different code
depending on what is mapped**. `tools/paginas.py` fixes the one org each bank
actually executes at, and everything else is done bank by bank:

* `src/pNN.entries` — the entry points the tracer cannot deduce: the interrupt
  hook, the inline dispatch tables and the return addresses this cartridge
  pushes on the stack instead of calling. Each one has its reason next to it.
* `src/pNN.nocode` — the word tables glued right behind their `call`. A tracer
  that walks straight through them eats them as instructions.
* `src/pNN.notes` — one line per annotation: `L` names a routine, `C` comments
  an instruction, `B` a block, `D` a data range and `F` the width of a record.

A `D` range only counts for the bank whose notes it is in: 0x6000 is the start
of bank 1, of bank 4 and of bank 7.

## What the numbers mean

`make sanity` prints the budget: **25,471 bytes of traced code** and **105,601
bytes of data in named ranges**, 0 unexplained, 131,072 in total. `make
densidad` prints the comment density per bank: 12,959 instructions, 3,022 line
comments, **23.3%**, and not one routine below 10% out of 1,540.

Every figure on this site comes from those two commands, not from an estimate.

## The pictures are drawn, not captured

There is no emulator capture on this site. `tools/graficos.py` runs the
cartridge's own routines in Python — the run-length decompressor at 0x49B9, the
character loader at 0x42FC, the mirror lists, and the column builder at
0x46AE — and draws the twelve stage maps and the title screen straight from the
bytes. `make web` regenerates them.

# The cartridge

**RC-742**, 128 KB, sixteen banks of 8 KB, with the Konami mapper **without
SCC** (Konami4). `tools/reconocimiento.py` measures that on the bytes rather
than assuming it: there is not one write to 0x5000, 0x7000, 0x9000 or 0xB000,
which are the registers of the other Konami mapper, the one with the SCC.

## How the banks are mapped

There is no register for 0x4000-0x5FFF: bank 0 is nailed there. The other three
windows take the bank number written to 0x6000, 0x8000 and 0xA000, and the
cartridge keeps a copy of the current split in 0xF0F1..0xF0F3 so an interrupt
can put it back.

| window | banks that go there |
|---|---|
| 0x4000 | 0 (fixed) |
| 0x6000 | 1, 4 |
| 0x8000 | 2, 5, 7, 9, 11 |
| 0xA000 | 3, 6, 8, 10, 12 |

Each bank has exactly one address it executes at, which is why the listing can
be split into sixteen files with sixteen orgs.

## What is in each bank

| bank | code | what it holds |
|---|---|---|
| 0 | 3,158 instr. | the loop, the scroll, the sprites, the VDP, the modes |
| 1 | 3,231 instr. | the enemy engines, the collisions, the boss |
| 2 | 2,849 instr. | the ship, the bosses, the aiming tables |
| 3 | 3,074 instr. | the power-up meter, the laser, twenty of the enemy types |
| 4, 5, 6 | — | the stage graphics, compressed |
| 7 | 420 instr. | the sound player |
| 8 | — | the music and the effects |
| 9, 10 | 227 instr. | the fixed screens, and a small sprite engine of their own |
| 11, 12 | — | the map pieces and the stage scripts |
| 13, 14, 15 | — | 0xFF, end to end |

Only **six of the sixteen banks carry code**.

## How much of the chip is empty

48,219 bytes — 47.1 KB, **36.8% of the cartridge** — are declared as 0xFF
filler. Four banks are filler end to end: 6, 13, 14 and 15. The others end with
a tail: 7,202 bytes in bank 8, 4,311 in bank 10, 2,487 in bank 12 and 1,052 in
bank 5. The odd one out is a hole of **399 bytes inside bank 3**, between the
last data and the eleven bytes of the hidden Konami mark; the other 47,820 are
tails.

Bank 6 is the odd one: the routine that maps 4/5/6 for graphics does put it in
0xA000, so it is mapped for real — there is simply nothing in it to read.

## The VRAM map is upside down

The eight bytes at 0x575A go to VDP registers 0 to 7: 0x02, 0xE2, 0x0E, 0x7F,
0x07, 0x76, 0x03, 0xE4. They do not leave anything where the BIOS leaves it.

| table | where the BIOS puts it | where this cartridge puts it |
|---|---|---|
| patterns | 0x0000 | **0x2000** |
| colours | 0x2000 | **0x0000** |
| names | 0x1800 | **0x3800** |
| sprite attributes | 0x1B00 | **0x3B00** |
| sprite patterns | 0x3800 | **0x1800** |

The name table ends at 0x3AFF and the sprite attributes start at 0x3B00, right
behind it.

## How the graphics are stored

Everything the cartridge draws goes through one small decompressor at 0x49B9,
and its format is written the other way round from what you would expect: bit 7
marks the **literal copy**, not the repeat.

| command | what it does |
|---|---|
| `0x00` | ends the block |
| `0x01`..`0x7F` | the next byte, N times |
| `0x80` | the next two bytes are a new VRAM address |
| `0x81`..`0xFF` | N-0x80 bytes copied as they come |

With that, the size of a block is not estimated: it is counted. That is what
lets every graphics range be declared with a `D` directive without missing a
byte or eating the next one. `tools/rle.py` measures any of them.

The stage characters are loaded by records of six bytes: which thirds to fill,
where the pattern stream is, at which character to start, and where the colour
stream is. Then two more lists **mirror** part of what was just loaded — by bits
for a horizontal flip, by bytes for a vertical one — so half the terrain
characters are made out of the other half instead of being stored twice.

## The hidden mark

At the end of bank 3, at offset 0x07FFF of the dump, sit the cartridge code
**RC-742** and eight katakana characters that read **グラディウス**, *Gradius*.
It is the signature Konami hid in its cartridges; the person who found it and
documented it is **Manuel Pazos**. `make marca` reads it back out of the ROM.

# Findings

Everything on this page is measured on the bytes or in the emulator. Where it
was measured in openMSX, it says so.

## The VRAM map is upside down

The eight bytes at 0x575A program VDP registers 0 to 7 and put nothing where the
BIOS puts it: **patterns at 0x2000**, **colours at 0x0000**, names at 0x3800 and
sprite attributes at 0x3B00, right behind the name table. Sprite patterns end up
at 0x1800.

This is not a curiosity. Anyone reading the addresses in this listing expecting
the usual layout will get every one of them wrong — and so did the first version
of the tool that draws the pictures on this site, which is how it was caught.

## The map is in RAM, and it is scrolled by hand

Twenty-two rows of thirty-two cells at 0xED00. On every scroll step the whole
thing moves one column left with twenty-two `ldir`s, the new column is written
on the right, and all 704 bytes go out to VRAM with `outi`. The stage script
gives six piece numbers every four columns; each piece is four by four
characters, five of them give twenty rows and the sixth gives the last two.

That is enough to rebuild any stage without an emulator, which is what the maps
on the front page are. Checked against the cartridge running in openMSX: of the
704 cells of the map buffer, **6 differed at distance 138 and 9 at distance
201**, and those are the twinkling stars and the characters the shot writes over
the map.

## All the randomness is the Z80's R register

There is no seed and no generator anywhere in the 128 KB. What stands in for
chance is `ld a,r`, the refresh register, which counts on its own with every
instruction executed:

* which of the two star drawings goes in each sky column (0x4750),
* which of the sixteen doors each falling rock comes through (0xABC2),
* how many frames each drawing of the blinking enemy lasts, 0x0F or 3 (0xB016),
  and 0x0A or 3 for another (0xBDBE), so two of them on screen at once are never
  in step,
* how far the enemy that walks the ground gets before stopping, between 0x2D and
  0x4C frames (0xAAE6),
* and which of the pair of shots a two-shot enemy sends where (0xA453).

## Every enemy is one number and two routines

An object boils down to its type, 1 to 0x1F. That number drives two twin tables
— p00:0x5DFD for who moves it and p01:0x6B46 for who finishes building it — and
twenty of the thirty-one types have at least one of the two in bank 3, sixteen
of them both.

## The spiral is done without sines

Type 0x1D closes in a spiral around a centre, and there is no sine table for it:
take the difference to the centre along one axis, divide it by eight with three
`sra a` and add it to the other; then the same the other way round. That is a
turn of about seven degrees per step. The radius shrinks separately, multiplying
both coordinates by a byte that starts at 0xFF and drops by one every 0x3C
frames, so the spiral closes on its own.

Bit 0 of byte 30 picks the direction, and the two halves of the routine are the
same code with the signs swapped.

## A three-slot enemy, built with one self-overlapping LDIR

Type 0x1E does not fit in one slot: it takes **three consecutive ones**, which
is why the allocator has a separate path that looks for three in a row. The
other two are built with a single `ldir` of 0x40 bytes from the slot onto itself
shifted by 0x20 — copying the first over the second and the second over the
third in one instruction — and then placed in a triangle. Only the first one
moves; the other two follow. When its time runs out, all three become type 0x1F
and fly apart.

## The three-way fan of aimed shots

One enemy does not fire one shot: it fires three. The angle to the ship is
measured, its top nibble is taken — sixteen directions — and three shots go out
with that number, the one beside it and the one before it. The two speeds for
each direction are worked out in advance in the table at 0xB26A, four bytes per
direction.

## Stage 7 writes its spawns one by one, packed into single words

The other stages release enemies in bursts. The seventh has them written out:
forty-three appearances in eighty-six bytes at 0xAF3F. Each one is a single
word — the low byte and bit 0 of the high byte are a nine-bit distance, bits 1
and 2 are the variant, and the top five are the row.

## The stages are not played in order, and four of them are bonus

There are two ways out of a stage. `end_stage` (0x6D53) adds one to 0xE061;
`jump_to_stage` (0x6FB9) writes a number straight into it, and **eight places
jump there, each with its own number**. Put them together and the running order
is:

    1 - 2 - 9 - 3 - 10 - 4 - 11 - 5 - 6 - 7 - 12 - 8 - ending - 1

Stages 9 to 12 are **bonus stages** slipped in between the others: no boss, and
an end-of-stage routine six instructions long that puts the stage back to 3, 4,
5 and 8 — exactly the four bytes of the table at 0x418F.

What opens them is the **target**. The finals of stages 2, 3, 4 and 7 test
0xE1C0, and the only instruction in the whole 128 KB that makes that byte
non-zero is 0xB130, inside `close_stretch`, which runs when the ship touches
the target at the end of the stage. Touch it and you go to the bonus stage; miss
it and the normal script carries on. Stage 1 has a target as well, and it leads
to no bonus.

## Stages 3 and 6 have no terrain at all

Their script range is 0xFFFF, so the test that decides whether the script
applies always fails and the column builder falls through to the star routine.
The whole stage is sky.

## The checkpoints table has eleven entries, and stage 12 reads past the end

The table at 0x4214 holds the distance each stage restarts at if you had already
got that far. It is read with `HL = 0x4212` and twice the stage number, so stage
1 takes the word at 0x4214 and stage 11 the one at 0x4228 — and **stage 12 reads
at 0x422A, which is already code**: the first two bytes of the `call 0x58BA`
that starts the next routine.

What comes out is 0xBACD, that is 47,821, a distance the scroll never gets
anywhere near, so the comparison always fails and stage 12 simply restarts at
0x20. The bug is real and its effect is nothing.

## The keyboard cheats only exist while the game is paused

0x44E7 watches the GRAPH key and, with the screen stopped, 0x50C9 collects
letters into 0xE1E8 until RETURN. Typing them while playing does nothing.
Measured in openMSX with `tools/omsx_cheats.tcl`: paused, 0xE1E8 fills with
`4F 50 54 49 4F 4E` and on RETURN 0xE20B goes from 00 to 02.

Besides the seven usual words there are twelve more, one per stage, all women's
names, and `BAKA` and `AHO` — *idiot* and *fool* — which zero the lives.

## The demo is a recording of the joystick

Bank 12 holds, per stage, a list of pairs [how many frames][what the joystick
reads]. The recorded value is dropped into the very byte where the real joystick
is read, with the fire bit forced on, and the run starts fully powered by
calling the same routine the `HYPER` cheat calls.

## Sprite priority is rotated so the flicker is shared

The MSX drops the last sprites of the table when more than four land on a line.
The buffer is therefore uploaded in thirty-two pieces of four bytes, starting at
a different place every frame, so no object is always the one that disappears.

## When a boss dies, the screen is eaten, not cleared

Blocks of 0x200 bytes come down from VRAM, get an AND with a mask and go back
up. First one pass over the colour table with 0xF0, then eight passes over the
pattern table with 0xFE, 0xFC, 0xF8... down to 0x00, and the mask is rotated
three bits per byte so the black comes in crumbled instead of in rows.

## In stage 5 the background is characters, not sprites

The fifth stage is the only one with its own background engine. Its objects have
no sprite card: they are rectangles of characters written into the map. Two twin
routines run one frame apart — first they are erased, then, once moved, painted
again — and the turret that slides out is drawn half way while it emerges, with
only as many rows as it has come out.

## The hidden Konami mark

At the end of bank 3, at offset 0x07FFF of the dump: **RC-742** and eight
katakana that read **グラディウス**, *Gradius*. The signature Konami hid in its
cartridges, found and documented by **Manuel Pazos**.

## The cartridge carries a second header, and it is not for the MSX

Right behind the standard `AB` header there are 21 bytes that no instruction in
the whole 128 KB ever reads. They are not for this cartridge to read: they are
for the one plugged into the **next slot**. Konami's Game Master is a cheat
cartridge that gives you infinite lives and stage select, and to do that it has
to know where *this* game keeps its things. So the game tells it, in a header of
its own:

    4010  43 44        "CD", the format mark
    4012  07 42        the catalogue number in BCD, high byte first: RC-742
    4014  80           which fields follow
    4015  00 E0 04     game state at 0xE000; there is a game running from 4 on
    4018  61 E0 08     stage at 0xE061, and there are 8 of them
    401B  60 E0        lives at 0xE060
    401D  53 E0        hi-score at 0xE053
    401F  5B E0        one player's score at 0xE05B
    4021  57 E0        the other player's at 0xE057
    4023  02 E0        game flags at 0xE002

The 0x80 is a bit mask read from bit 0 upwards, and a **clear** bit means the
field is present. Seven are, and the eighth —a callback the Game Master would
call into the game— is not. Sixteen bytes of fields, and the block ends exactly
at 0x4025, which is where the 19 bytes the Game Master copies run out. Not one
byte over.

And the addresses check out against this cartridge on its own, which is what
settles it rather than the format alone. 0xE060 is where 0x54C0 puts the three
ships back, in BCD. 0xE061 is the stage 0x4129 bumps. 0x53B1 —state 4— is where
a stage actually starts. And the prettiest one: 0x5558 wipes everything from
0xE057 up to 0xEFFF when a game begins, and the four bytes at 0xE053 are exactly
what it leaves standing, which is what a hi-score has to do.

The identification is **Néstor Sancho**'s ([@theNestruo](https://github.com/theNestruo)),
and the format is documented in **Ricardo Bittencourt**'s
[disassembly of the Game Master](https://github.com/ricbit/game-master).

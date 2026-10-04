# The code

## The frame

The interrupt hook does the work. Every frame it puts the sound banks in place,
calls the player, gives the scroll its steps, runs the objects and pushes the
sprite buffer out. What is left for the main loop is the mode machine: title,
demo, play, stage screen, game over.

## The map is in RAM

The twenty-two rows of thirty-two cells live at **0xED00**, not in VRAM. Every
scroll step:

1. 0x469D shifts the whole thing one column to the left with twenty-two
   `ldir`s of 0x1F bytes.
2. 0x46AE works out which column comes in on the right and 0x46E1 writes it.
3. 0x47FE pushes all 704 bytes to the name table with `outi`, without going
   through the BIOS.

The incoming column comes from the stage's script: the distance travelled minus
the start of the script range, divided by four, indexes rows of **six piece
numbers**, and each piece is four by four characters. Five pieces give twenty
rows and the sixth gives the last two. Outside the script range the column is
sky: one star, on the row the table at 0x478E gives.

Two sets of pieces: the one at 0x8000 of bank 11 and the one at 0x8FF0. Stages
5, 9, 10 and 12 use the second.

## The objects

Twelve slots of 32 bytes at 0xE300, plus eight of 0x20 counted backwards at
0xE460 for the aimed shots, ten at 0xE500, five at 0xEB00, and eight of 8 bytes
at 0xE700 for the background. Inside a slot:

| byte | what it is |
|---|---|
| 0 | the type, 1 to 0x1F; zero means the slot is free |
| 1 | which step of its own machine it is on |
| 3, 4 | the row, with its fraction |
| 5, 6 | the column, with its fraction |
| 7, 8 | the vertical speed |
| 9, 10 | the horizontal speed |
| 11 | drawn with characters instead of a sprite |
| 12, 13 | the drawing and its colour |
| 0x17..0x1A | the two accelerations |
| 0x1B | flags: whether it can be shot, whether it is drawn |

`spawn_object` (0x6A72) is the most called routine in bank 1: give it the
type, where it goes and one adjustment byte, and it finds a free slot, fills it
from the four-byte record at 0x6BA3 and bumps the live count. Three types break
the rule: 0x1E needs **three consecutive slots**, 0x0E goes to the other table,
and the rest go to 0xE300.

Then the type drives two twin tables: **p00:0x5DFD** says who moves it and
**p01:0x6B46** says who finishes building it. Twenty of the thirty-one types
have at least one of the two in bank 3, and sixteen have both, which is why
0xA7B9..0xB537 is the longest stretch of code in the cartridge.

The adjustment byte is the enemy's **mark**. The sixteen bytes at 0xA5C7 are
read round and round: three out of four come out with the mark at zero, one in
four comes out with a 1 and one in sixteen with a 2. A marked enemy is painted
colour 8, the red one, and leaves something different behind when it dies.

## How the enemies move

Every type is a tiny machine of its own, and none of them uses trigonometry.
Some of the shapes:

* **Type 4** tilts its drawing to match its course. Three drawings — 0xB0 level,
  0xB4 tilted up, 0xB8 tilted down — chosen at the same place as the speed, so
  drawing and heading can never contradict each other.
* **Type 2** does not cross the screen: it turns back at column 0x81, stops at
  0x9F, comes forward again to 0x51 and then flies straight once it is level
  with the ship. Four steps counted in byte 1.
* **Type 5** walks on the terrain. It carries no height map: it asks the map
  what is eight points below its feet and steps up or down eight until it fits.
* **Type 0x0C** has its whole route written down: nine steps, each waiting for
  the column to reach a number. Bit 7 of byte 1 is a mirror, so the ones that
  come in through the bottom half do the same route upside down.
* **Type 0x1D** closes in a spiral without a sine table: an eighth of the
  distance to the centre added to the other axis, and a radius that shrinks by
  multiplication.
* **Type 0x1E** takes three slots and, when its time runs out, becomes three
  type 0x1F that fly apart.

## The sound

Bank 7 is the player and bank 8 the data; the interrupt maps both and calls
0x8063. Three channels, each a card of 0x11 bytes at 0xE010, 0xE021 and 0xE032,
each walking its own stream of commands. Everything reaches the PSG through the
BIOS, WRTPSG. The table at 0x8328 holds eighty pointers, one per sound; entry 0
is not an address at all, so sound 0 does not exist, and the last three point at
the first filler byte of bank 8, that is, at silence.

## Sprite priority is rotated on purpose

The MSX draws four sprites per line and drops the rest, always the last ones in
the table. So 0x47CE does not upload the buffer in one go: it uploads it in
**thirty-two pieces of four bytes**, starting each frame at a different place —
0xE17F goes up by 0x1C and wraps at 0x7C — and stepping 0x0C at a time. Each
object lands in a different slot of the attribute table every frame, and the
flicker is shared out.

# In the emulator

Some of what is written in this listing cannot be settled by reading. This page
is what was checked with the cartridge actually running, and how.

## What was measured, and what came out

**The keyboard cheats.** `tools/omsx_claves.tcl` boots the cartridge, starts a
game, presses GRAPH to pause, types the word letter by letter, presses RETURN
and writes down the bytes of the ship's card before and after. With `OPTION`,
0xE1E8 fills with `4F 50 54 49 4F 4E` and 0xE20B goes from 00 to 02. With
`BAKA`, the lives at 0xE060 go from 02 to 00 and the demo flag at 0xE05F goes
out.

The first attempt failed, and the failure was the finding: typing the word while
playing does nothing at all. The code only reads the keyboard **with the game
paused**, so the script had to press GRAPH first.

**The maps.** The twelve maps on the front page are drawn from the ROM, not
captured — but they were checked against the real thing. A script lets the demo
play, dumps the 704 bytes of the map buffer at 0xED00 together with the distance
in 0xE063, and the same columns are generated in Python. Of 704 cells, **6
differed at distance 138 and 9 at distance 201**. Those are the twinkling stars,
which the cartridge picks with the R register, and the characters the shot
writes over the map.

**The title screen.** The whole VRAM was dumped from the emulator and compared,
byte for byte, against the one the tool builds from the compressed blocks. They
match everywhere the artwork lives; the only bytes that differ are characters
0xC0 to 0xFF, which the game keeps rewriting, and the sprite attribute table.

That comparison is what caught a bug — a mask of 0x17FF where it should have
been 0x1FFF, which quietly dropped the 0x800 bit and drew the **middle third**
of every screen with the first third's characters.

## The traps, already paid for

* With `-script`, openMSX starts with the renderer *uninitialized* and
  `screenshot` writes a black PNG and returns success. It has to be turned on by
  hand: `set renderer SDLGL-PP`.
* Screenshots are taken with the throttle **on** and after `after realtime`, or
  they come out of a frame that was never drawn.
* `type` is too fast. The cartridge only notices a key when it **changes**, so
  the cheat words go in one letter at a time through the key matrix.
* Output paths are Windows paths. openMSX writes where it is told, not where the
  shell thinks it is.

## Running one yourself

    NEM_OUT=<directory> NEM_CLAVE=option openmsx -machine Philips_VG_8020 \\
        -carta nemesis.rom -script tools/omsx_claves.tcl

The script writes its own log next to the screenshots, with the emulated time on
every line, so a run that goes wrong can be read afterwards instead of guessed
at.

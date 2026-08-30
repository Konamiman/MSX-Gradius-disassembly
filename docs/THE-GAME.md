# The game

Konami's Gradius, released for the MSX1 in 1986 as **Nemesis** outside Japan.
A horizontally scrolling shooter: twelve stages, a power-up meter you fill by
collecting capsules, and options that trail the ship copying its path.

## Which name it shows

Both. The logo is chosen at boot: the cartridge asks the BIOS which country the
machine is and picks the Japanese title or the western one. The cartridge itself
only knows one name — the hidden mark at the end of bank 3 reads グラディウス,
*Gradius*.

## The twelve stages, and the four that are bonus

The stage number lives in 0xE061, and it is **not** simply counted up. There are
two ways out of a stage: `acaba_la_fase` (0x6D53) adds one, and
`salta_a_la_fase` (0x6FB9) writes a number straight in. Eight places jump to the
second one, each with its own number, and that is where the real running order
comes from:

    1 - 2 - 9 - 3 - 10 - 4 - 11 - 5 - 6 - 7 - 12 - 8 - ending - 1

**Stages 9, 10, 11 and 12 are bonus stages** slipped in between the others. They
have no boss: their end-of-stage routine is six instructions that put the stage
back to 3, 4, 5 and 8 — the four bytes of the table at 0x418F.

And what opens them is the target. The finals of stages 2, 3, 4 and 7 look at
0xE1C0, and the only thing in the whole 128 KB that makes that byte non-zero is
0xB130, which runs when the ship touches the target at the end of the stage. So
**touching the target sends you to the bonus stage; missing it carries on with
the normal script**. Stage 1 has a target too, and it leads to no bonus.

Stage 3 and stage 6 have **no terrain at all**. Their script range is 0xFFFF, so
the column builder always falls through to the star routine and the whole stage
is sky. The other ten have their terrain written as a script of piece numbers;
the maps on the front page are those scripts drawn out end to end.

Each stage also has a **checkpoint**, in the table at 0x4212. When the stage is
set up, 0x41E1 compares the distance already travelled with that number: if you
had got past it, the stage restarts right there, and if not, at 0x20.

## The power-up meter

The six slots — SPEED UP, MISSILE, DOUBLE, LASER, OPTION and the shield — are
painted lit or unlit according to what the ship already carries. 0xA022 walks
the ship's card and leaves a one in 0xE131..0xE136 for each upgrade already
taken; 0xA068 reads 0xE130, the slot the capsules have advanced to, and on the
second button gives that upgrade if it is not already there. Taking it puts the
meter back to zero.

Consecutive capsules pay more: 0xE128 counts them and the BCD table at 0x7563
pays 1, 2, 5, 10, 20, 50 and 100, topping out at seven.

## The cheats you type

The cartridge reads the keyboard **only while the game is paused**. GRAPH
pauses; from then on every new key goes into 0xE1E8, up to eight, and RETURN
compares what was typed against the words at 0x51BF:

| word | what it gives |
|---|---|
| `HYPER` | all five at once, but only the first time |
| `SHIELD` | the shield |
| `LASER` | the laser |
| `MISSILE` | the missile |
| `DOUBLE` | the double shot |
| `OPTION` | one more option |
| `DOWN` | takes the speed back to zero |
| `BAKA`, `AHO` | nothing good: they zero the lives |

And each stage has **its own woman's name** — MOMOKO, CHIE, AKEMI, SYUKO,
CHIAKI, NORIKO, SATOE, YASUKO, KINUYO, HISAE, MIYUKI, YOHKO — handed out by the
table at 0x5163. Typing the right one for the stage you are on gives everything,
like `HYPER`.

`BAKA` and `AHO` are *idiot* and *fool* in Japanese, and they fall into 0x5127,
which zeroes the lives, the demo flag and both joystick flags.

All of this was measured in openMSX with `tools/omsx_claves.tcl`, not deduced:
paused, 0xE1E8 fills with `4F 50 54 49 4F 4E` — OPTION — and on RETURN 0xE20B
goes from 00 to 02, the two options.

## The demo plays itself from a recording

Left alone, the cartridge plays a stage on its own. It is not an autopilot: bank
12 holds, per stage, a list of pairs [how many frames][what the joystick reads],
and 0x5CDA feeds the recorded value into the very byte where the real joystick
is read. The fire bit is forced on, so the demo ship shoots without stopping,
and it starts fully powered: 0x5CB8 calls the same routine the `HYPER` cheat
calls.

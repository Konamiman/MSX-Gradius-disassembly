# Open questions

What is still not settled. Everything here is written as a question on purpose:
none of it is guessed at in the listing.

## What decides the scroll limit after the third gate

Five stages have a target written into them at a fixed distance — 1, 2, 3, 4 and
7. Touching it blows up everything on screen, stops the screen and sets the
scroll limit. Stages 2, 3 and 6 have their own limit; the rest go through a
counter at 0xE06C that only advances when the target is of a **different kind**
from the last one, and at the third different one the limit becomes 0x01C0.

What that counter is for in play — whether it is the hidden route, or the
difficulty of the loop, or something else — is not settled.

## The 399 bytes before the hidden mark

Bank 3 ends with a hole of 399 bytes between the last data and the eleven bytes
of the Konami mark. They are declared as a range, but what they were is unknown:
they could be filler for the mark to sit at the very end, or the tail of
something that was cut.

## Which stages of the round are actually reachable

The table at 0x418F says which stage follows which once the ninth is past, and
the listing reads it correctly. What is not measured is which of the twelve are
reachable in a normal game and which only in the second loop.

## What the second bit of the enemy mark is for

One enemy in four comes out marked and one in sixteen comes out with a 2 instead
of a 1. The 1 is understood: it paints the enemy red and changes what it leaves
when it dies. What the 2 changes, beyond going through a different branch, has
not been pinned down in play.

## Whether the fifth stage has more background kinds than the eight seen

The stage 5 background engine dispatches on eight types of card, but the script
that fills them only ever writes some of them. Whether the rest are unused or
just rare has not been checked frame by frame.

; RAM used by the sound player (0xE010..0xE04C).
;
; Names taken from the comments in the listing; the addresses are the ones the
; code uses.

; ---- The three channel cards
;
; A channel is a card of 0x11 bytes and a stream of commands. The player keeps
; three identical cards, at 0xE010, 0xE021 and 0xE032: byte 0 is the countdown
; of the note that is sounding, 1 its length, 2 the mode, 3 and 4 where its
; command stream has got to, 5 the switches (tone, noise and envelope), 6 the
; octave shift, 7 to 9 the volume and its decay, 0x0B the time unit, 0x0C the
; sharp, 0x0D and 0x0E the envelope times, and 0x0F and 0x10 the last period
; written. Everything that sounds comes from reading those streams byte by
; byte.

SND_CARD_A	equ	0E010h
SND_CARD_B	equ	0E021h
SND_CARD_C	equ	0E032h
CARD_SIZE	equ	11h

; Fields of a card (offsets for IX)

CARD_COUNTDOWN	equ	00h	; Frames left of the note that is sounding
CARD_LENGTH	equ	01h	; Length of the note
CARD_MODE	equ	02h	; Mode; zero = the channel does not sound, bit 7 = melody mode
CARD_STREAM	equ	03h	; (word) Where the command stream has got to
CARD_SWITCHES	equ	05h	; Bit 0 tone, bit 1 noise, bit 3 envelope
CARD_OCTAVE	equ	06h	; Octave shift
CARD_START_VOLUME equ	07h	; Starting volume (melody mode)
CARD_VOLUME	equ	08h	; Current volume
CARD_DECAY	equ	09h	; When the note starts to decay
CARD_LAPS	equ	0Ah	; Laps done by the 0xFE repeat command
CARD_TIME_UNIT	equ	0Bh	; How long one beat lasts
CARD_SHARP	equ	0Ch	; Non-zero: one semitone up
CARD_ENV_TIME	equ	0Dh	; Envelope time (high nibble of the 0xFx parameter)
CARD_DECAY_FLOOR equ	0Eh	; Floor of the decay (low nibble of the 0xFx parameter)
CARD_PERIOD	equ	0Fh	; (word) Last period written to the PSG

; ---- Mix and mute

SND_MIX		equ	0E043h	; Current value of PSG register 7
SND_MUTE	equ	0E044h	; Mute countdown; while non-zero the channels fade out
SND_MUTE_STEP	equ	0E046h	; Mute step, subtracted from the volume

; ---- The noise effect (takes over channels A and B while it runs)

NOISE_FX_ON	equ	0E047h	; Non-zero while the effect is running
NOISE_FX_NEW	equ	0E048h	; First frame of the effect; then its four counters
NOISE_FX_OUTER	equ	0E04Ah	; Outer counter: steps left
NOISE_FX_VOLUME	equ	0E04Bh	; Current volume of the effect
NOISE_FX_DIRTY	equ	0E04Ch	; Non-zero if the effect overwrote the PSG registers

; ============================================================================
; Sound player - The entry point and the noise effect
; ============================================================================
;
; `play` is what the interrupt calls every frame (p00:4035), with bank 7 at
; 0x8000 and bank 8 at 0xA000. It is the only code entry point of the image,
; and the main image (banks 0-3) gets its address from the symbols file that
; the link produces (build/sound_symbols.inc).
;
; The noise effect takes over channels A and B while it runs: four steps of
; period from noise_registers, the volume going down one step every other
; frame.

	include "bios.inc"
	include "variables.inc"

	public play
	extrn restore_registers,set_volume,silence_channels

play:		; What the interrupt calls every frame (p00:4035), with banks 7 and 8 in place.
	ld a,(NOISE_FX_ON)	; While the noise effect is running, it is in charge
	or a
	jp z,restore_registers
	ld a,001h		; 0xE04C to one: when it ends the registers must be restored
	ld (NOISE_FX_DIRTY),a
	ld e,0b8h		; Mix 0xB8: the three tones silenced and noise on C
	ld a,007h
	call WRTPSG		; WRTPSG with A=7: the mixer register, the one that decides which channels sound and which put out noise.
	ld hl,NOISE_FX_NEW	; The first frame of the effect
	ld a,(hl)
	or a
	jr z,run_noise_effect
	ld (hl),000h		; The four bytes of the count: 0, 7, 5 and 0x10
	inc hl
	ld (hl),007h
	inc hl
	ld (hl),005h
	inc hl
	ld (hl),010h
	call silence_channels	; The three channels silenced...
	ld e,0d6h		; ...and period 0xD6 in A and B
set_tone_a_and_b:		; Writes PSG registers 0, 2, 1 and 3: the periods of channels A and B.
	xor a
	call WRTPSG		; Register 0: the low byte of A's period
	inc e
	ld a,002h		; And 2: B's
	call WRTPSG
	ld e,000h		; Registers 1 and 3, the high bytes, to zero
	ld a,001h
	call WRTPSG
	ld a,003h
	jp WRTPSG
run_noise_effect:		; Counts down the effect's two counters: the inner one keeps taking volume away and the outer one changes the noise register
	ld a,(NOISE_FX_OUTER)	; Only with the effect on
	or a
	ret z
	inc hl
	dec (hl)		; The inner counter
	jr z,next_noise_step
	ld a,(hl)
	and 001h		; One frame in two
	ret nz
	ld a,(NOISE_FX_VOLUME)	; One volume step less
	dec a
	ld (NOISE_FX_VOLUME),a
	ld e,a
	jp set_volume
next_noise_step:		; Once the outer counter runs out, the effect moves on to the next register value from 0x80D9; when they run out, the channels go silent
	inc hl
	dec (hl)		; The outer counter
	jp z,silence_channels	; And when it runs out, the effect is over
	ld a,(hl)
	dec hl
	ld (hl),006h		; Six frames until the next step
	dec a
	ld e,a
	ld d,000h
	ld hl,noise_registers	; The table at 0x80D9: the period for each step
	add hl,de
	ld e,(hl)
	call set_tone_a_and_b
	ld a,00fh		; And the volume goes back to 0x0F
	ld (NOISE_FX_VOLUME),a
	ld e,a
	jp set_volume

; ----------------------------------------------------------------------
; DATA noise_registers: Four bytes that 0x80C8 indexes with `ld hl,0x80D9 /
;   add hl,de / ld e,(hl)`: the value handed to the PSG at each step of the
;   effect.
noise_registers:
	defb 06bh,08eh,0aah,08eh

	end

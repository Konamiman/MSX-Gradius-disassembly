; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - interrupt.asm
; ============================================================================

	include "bios.inc"
	include "sound_symbols.inc"

	public add_a_to_de,add_a_to_hl,interrupt,L_405A
	extrn read_controller,state_machine

; ----------------------------------------------------------------------
; THE INTERRUPT
; ----------------------------------------------------------------------
interrupt:		; What INIT installs in the H.KEYI hook (0xFD9A). THE WHOLE GAME RUNS HERE.
	call RDVDP		; Reading the VDP status is what acknowledges the interrupt.
	di
	ld a,007h		; Bank 7 at 0x8000 and bank 8 at 0xA000: the sound player and its data.
	ld (08000h),a		; NOTE: the RAM copy at 0xF0F2 is NOT touched here, and that is why it can be undone afterwards.
	inc a
	ld (0a000h),a
	call play		; The sound runs entirely inside the interrupt.
	di
	ld a,(0f0f2h)		; Whatever bank layout was there before is restored, reading it from the RAM copy.
	ld (08000h),a
	ld a,(0f0f3h)
	ld (0a000h),a
	ld hl,0e005h		; Lock: if the game loop is already inside, this interrupt does not enter again.
	bit 0,(hl)
	jr nz,L_4058
	inc (hl)
	ei			; The `ei` goes BEFORE the long work: the next interrupt can catch it halfway.
	call read_controller
	call state_machine	; And here the real game starts.
	xor a
	ld (0e005h),a		; The lock is released.
L_4058:
	ei
	ret
L_405A:
	jp WRTVDP
add_a_to_hl:		; HL += A, with the carry done right. Called from 48 places.
	add a,l			; HL = HL + A, fixing H if there is a carry.
	ld l,a
	ret nc
	inc h
	ret
add_a_to_de:		; DE += A. Called from 26 places.
	add a,e			; DE = DE + A, the same.
	ld e,a
	ret nc
	inc d
	ret

	end

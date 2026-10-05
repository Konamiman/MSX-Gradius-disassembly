; ============================================================================
; Sound player - The mixer (PSG register 7)
; ============================================================================
;
; set_mix builds register 7 for one channel: whether its tone sounds, whether
; its noise sounds, or neither. write_mix writes A as the new mix; channels.mac
; uses it to put back the mix after the noise effect.

	include "bios.inc"
	include "variables.inc"

	public set_mix,write_mix

set_mix:		; Builds PSG register 7: for each channel, whether tone sounds, whether noise sounds, or neither
	ld a,(SND_MIX)		; The current mix
	ld e,a
	ld a,(ix+CARD_SWITCHES)	; The two low bits of byte 5: tone and noise
	and 003h
	ld d,a
	ld a,c			; The channel number
	cp 001h
	jr z,L_803A
	dec a
L_803A:
	ld b,a
	bit 1,d			; Bit 1: this channel's noise
	call z,set_that_bit
	bit 1,d
	call nz,clear_that_bit
	ld a,b
	rlca			; The noise bits are three bits higher up
	rlca
	rlca
	bit 0,d			; And bit 0: its tone
	call z,set_that_bit
	bit 0,d
	call nz,clear_that_bit
write_mix:
	ld (SND_MIX),a		; The new mix, noted down
	ld e,a
	ld a,007h		; PSG register 7
	jp WRTPSG
clear_that_bit:		; The bit set to zero: that channel sounds
	cpl
	and e
	ld e,a
	ret
set_that_bit:		; The bit set to one: that channel is silent
	or e
	ld e,a
	ret

	end

; ============================================================================
; Sound player - Volumes, restoring the PSG, and the three channels
; ============================================================================
;
; silence_channels and set_volume write the volume registers. restore_registers
; puts back what the channels had once the noise effect ends. run_three_channels
; walks the three cards (SND_CARD_A, B and C) and runs each channel's stream.

	include "bios.inc"
	include "variables.inc"

	public restore_registers,set_volume,silence_channels
	extrn write_mix,run_channel,silence_this_channel

silence_channels:		; Sets E to zero and falls into 0x80E4, that is, sets the volume of the three channels to zero.
	ld e,000h		; Volume zero
	ld a,00ah		; Register 10: C's volume
	call WRTPSG
set_volume:		; Writes E to PSG registers 9 and 8: the volume of channels B and A.
	ld a,009h		; Register 9: B's
	call WRTPSG
	dec a			; And 8: A's
	jp WRTPSG
restore_registers:		; When the noise effect ends, the four periods and the three volumes go back to what the channels had
	ld a,(NOISE_FX_DIRTY)	; Only if the effect had overwritten the registers
	or a
	jp z,L_812E
	xor a			; And then there is nothing left to restore
	ld (NOISE_FX_DIRTY),a
	ld hl,SND_CARD_A+CARD_PERIOD	; The periods saved in the cards
	ld e,(hl)
	call WRTPSG
	inc hl
	inc a
	ld e,(hl)
	call WRTPSG
	ld hl,SND_CARD_B+CARD_PERIOD
	inc a
	ld e,(hl)
	call WRTPSG
	inc hl
	inc a
	ld e,(hl)
	call WRTPSG
	ld a,(SND_CARD_A+CARD_VOLUME)	; Channel A's volume...
	ld e,a
	ld a,008h
	call WRTPSG
	ld a,(SND_CARD_B+CARD_VOLUME)	; ...B's...
	ld e,a
	ld a,009h
	call WRTPSG
	ld a,(SND_CARD_C+CARD_VOLUME)	; ...and C's
	ld e,a
	ld a,00ah
	call WRTPSG
L_812E:
	ld a,(SND_MIX)		; And whatever mix there was
	call write_mix
run_three_channels:		; The three 0x11-byte cards at 0xE010, one after another
	ld c,001h		; Channel A: register 1
	ld ix,SND_CARD_A	; The first card
	ld hl,SND_MUTE		; The mute countdown
	ld a,(hl)
	or a
	jr z,L_8164
	inc hl
	dec (hl)
	jr nz,L_8164
	ld (hl),060h		; 0x60 frames per step
	inc hl
	inc (hl)
	ld a,006h		; Six steps and it goes completely silent
	cp (hl)
	jr nz,L_8164
	ld a,(ix+CARD_MODE)
	cp 0a9h			; The channel that carries 0xA9 has a card of its own
	jr nz,L_8159
	ld (ix+2*CARD_SIZE+CARD_MODE),000h
L_8159:
	xor a
	ld (hl),a
	ld (SND_MUTE),a
	ld (ix+CARD_MODE),a
	ld (ix+CARD_SIZE+CARD_MODE),a
L_8164:
	exx
	ld b,003h
	ld de,CARD_SIZE		; 0x11 bytes: the next card
L_816A:
	exx
	ld a,(ix+CARD_MODE)	; Byte 2 at zero: this channel does not sound
	or a
	jr nz,L_8176
	call silence_this_channel
	jr L_8179
L_8176:
	call run_channel
L_8179:
	inc c			; Two PSG registers per channel
	inc c
	exx
	add ix,de
	djnz L_816A
	ret

	end

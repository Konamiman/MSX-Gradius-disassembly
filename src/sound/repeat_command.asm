; ============================================================================
; Sound player - The 0xFE "repeat" command
; ============================================================================
;
; Command 0xFE in a channel's stream: FE, number of laps, address. The
; channel goes back to the address until it has done the laps, and then
; carries on after the command. Reached from run_channel (interpreter.mac).

	include "bios.inc"
	include "variables.inc"

	public repeat_stream
	extrn run_channel,save_pointer

repeat_stream:		; Command 0xFE: the word after it says where to go back to, and byte 10 counts the laps done
	inc hl			; Byte 10: the laps done so far
	ld a,(ix+CARD_LAPS)
	inc a
	cp (hl)			; Against the ones the command asks for
	jr z,laps_done
	jp m,L_800C
	dec a
L_800C:
	ld (ix+CARD_LAPS),a	; One more lap
	inc hl
	ld a,(hl)		; And the stream goes back to wherever the word says
	ld (ix+CARD_STREAM),a
	inc hl
	ld a,(hl)
	ld (ix+CARD_STREAM+1),a
	jr L_8024
laps_done:		; The counter to zero and the stream carries on after the command
	inc hl
	inc hl
	xor a
	ld (ix+CARD_LAPS),a	; The laps, to zero
	call save_pointer
L_8024:
	inc (ix+CARD_COUNTDOWN)	; Byte 0 goes up by one: the current note ends right now
	jp run_channel

	end

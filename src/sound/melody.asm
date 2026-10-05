; ============================================================================
; Sound player - Melody mode
; ============================================================================
;
; With bit 7 of CARD_MODE set, a channel reads melody commands: 0xDx the time
; unit, 0xFx the volume and the envelope times, 0xEx sharp or octave, and the
; last nibble the note. write_period applies the sharp and writes the
; channel's period. save_pointer stores where the stream has got to.

	include "bios.inc"
	include "variables.inc"

	public read_melody_command,save_pointer,write_period
	extrn write_volume_and_mix

read_melody_command:		; Commands 0xDx, 0xFx and 0xEx set time, volume, envelope and octave; the last nibble is the note
	ld a,(hl)		; Command 0xDx: the time unit
	and 0f0h
	cp 0d0h
	ld a,(hl)
	jr nz,L_8264
	and 00fh
	ld (ix+CARD_TIME_UNIT),a	; Byte 11: how long one beat lasts
	inc hl
	ld a,(hl)
L_8264:
	cp 0f0h			; Command 0xFx: the volume
	jr c,L_8282
	and 00fh
	inc a
	inc a
	ld (ix+CARD_START_VOLUME),a	; Byte 7: the starting volume
	inc hl
	ld a,(hl)
	and 0f0h		; And the byte after it brings the two times
	rrca
	rrca
	rrca
	rrca
	ld (ix+CARD_ENV_TIME),a	; The high nibble, to byte 13...
	ld a,(hl)
	and 00fh		; ...and the low one, to 14
	ld (ix+CARD_DECAY_FLOOR),a
	inc hl
	ld a,(hl)
L_8282:
	cp 0e0h			; Command 0xEx: sharp or octave
	jr c,L_8297
	and 00fh
	bit 3,a			; Bit 3: sharp
	jr z,L_8292
	ld (ix+CARD_SHARP),a	; Byte 12: one semitone up
	inc hl
	jr read_melody_command
L_8292:
	ld (ix+CARD_OCTAVE),a	; And if not, byte 6: the octave shift
	inc hl
	ld a,(hl)
L_8297:
	and 00fh		; The low nibble: how many beats it lasts
	ld b,a
	ld a,(ix+CARD_TIME_UNIT)
	jr z,L_82A4
L_829F:
	add a,(ix+CARD_TIME_UNIT)	; The time unit, added that many times
	djnz L_829F
L_82A4:
	ld (ix+CARD_LENGTH),a	; Byte 1: how long the note lasts
	ld a,(hl)
	call save_pointer
	and 0f0h		; The high nibble: the note
	rrca
	rrca
	rrca
	rrca
	ld b,a
	sub 00ch		; Note 0x0C is the rest
	jr z,L_82C9
	ld e,(ix+CARD_START_VOLUME)
	ld a,(SND_MUTE)		; While muting, the volume drops at once
	or a
	ld a,e
	jr z,L_82C9
	ld a,(SND_MUTE_STEP)
	ld d,a
	ld a,e
	sub d
	jr nc,L_82C9
	xor a
L_82C9:
	ld (ix+CARD_VOLUME),a	; Byte 8: the current volume
	ld d,a
	ld e,(ix+CARD_LENGTH)
	ld (ix+CARD_COUNTDOWN),e	; Byte 0: the note's countdown
	ld a,(ix+CARD_ENV_TIME)	; And byte 9: when it starts to decay
	add a,e
	ld (ix+CARD_DECAY),a
	ld a,b
	ld hl,descending_table	; The table at descending_table: the period of the twelve notes
	add a,l
	ld l,a
	jr nc,L_82E3
	inc h
L_82E3:
	ld l,(hl)
	ld h,000h
	ld a,(ix+CARD_OCTAVE)	; Byte 6: for each octave, the period times two
	or a
	jr z,write_period
	ld b,a
L_82ED:
	add hl,hl
	djnz L_82ED
write_period:
	ld a,(ix+CARD_SHARP)	; Byte 12: the sharp raises the period by one
	or a
	jr z,L_82F7
	inc hl
L_82F7:
	ld a,c			; The channel's high register...
	ld e,h
	ld (ix+CARD_PERIOD+1),e
	call WRTPSG
	ld a,c
	dec a
	ld e,l
	ld (ix+CARD_PERIOD),e	; ...and the low one, both saved in the card
	call WRTPSG
	ld a,(ix+CARD_MODE)	; Bit 7 of the mode: in melody mode, it carries on along another path
	bit 7,a
	ret z
	ld h,d
	ld (ix+CARD_SWITCHES),002h	; Byte 5 to two: tone only
	jp write_volume_and_mix
save_pointer:		; Leaves in (IX+3, IX+4) where the channel's stream has got to.
	inc hl
	ld (ix+CARD_STREAM),l
	ld (ix+CARD_STREAM+1),h
	ret

; ----------------------------------------------------------------------
; DATA descending_table: Ten bytes going downhill (0x6B, 0x65, 0x5F, 0x5A,
;   0x55, 0x50, 0x4C, 0x47, 0x43, 0x40), read by 0x82DB.
descending_table:
	defb 06bh,065h,05fh,05ah,055h,050h,04ch,047h,043h,040h

	end

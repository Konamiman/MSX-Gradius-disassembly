; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - three_shot_fan.asm
; ============================================================================

	include "variables.inc"

	public release_fan
	extrn add_a_to_de,measure_distance_to_ship

; ----------------------------------------------------------------------
; THE FAN OF THREE SHOTS
; This enemy does not fire one shot: it fires three, spread in a fan around
; the ship. The angle to the ship is measured (SHIP_ANGLE) and only its high
; nibble is kept, which gives sixteen directions all the way round, and
; three shots are released with that number, with the next one and with
; the one before. The two speeds of each direction are worked out in
; advance in the table at fan_shot_speeds: four bytes per direction, two words.
; ----------------------------------------------------------------------
release_fan:		; Measures the angle to the ship and releases three shots: the one at that angle, the next one and the one before
	ld a,(ix+002h)		; Its row and its column, plus 0x10: from the centre of the enemy
	add a,010h
	ld e,a
	ld a,(ix+003h)
	add a,010h
	ld d,a
	call measure_distance_to_ship	; From that comes the angle to the ship, in SHIP_ANGLE
	ld c,000h		; The middle one...
	call insert_shot
	ld c,001h		; ...the next one...
	call insert_shot
	ld c,0ffh		; ...and the one before
insert_shot:		; Looks for a free slot among the ten at ENEMY_SHOTS and fills it with the position and with the speed for that direction
	ld a,(SHIP_ANGLE)	; The high nibble of the angle: sixteen directions
	rra
	rra
	rra
	rra
	add a,c			; Plus the fan offset
	and 00fh
	ld (FAN_DIRECTION),a
	ld hl,ENEMY_SHOTS	; The ten slots, 0x20 apart
	ld de,00020h
	ld b,00ah
	xor a
L_B22D:
	cp (hl)			; The first one with its first byte at zero
	jr z,L_B234
	add hl,de
	djnz L_B22D
	ret
L_B234:
	ld (hl),001h		; Taken
	inc l
	inc l
	inc l
	inc l
	ld a,(ix+002h)		; The enemy's row plus 0x10
	add a,010h
	ld (hl),a
	inc l
	inc l
	ld a,(ix+003h)		; And its column
	add a,010h
	ld (hl),a
	ld de,fan_shot_speeds	; The table at fan_shot_speeds: four bytes per direction
	ld a,(FAN_DIRECTION)
	add a,a
	add a,a
	call add_a_to_de
	inc l
	ex de,hl
	ld bc,00004h
	ldir			; The two speeds, in one go
	ex de,hl
	ld (hl),000h
	inc l
	ld (hl),088h		; Drawing 0x88 in colour 9
	inc l
	ld (hl),009h
	ld de,0000eh
	add hl,de
	ld (hl),001h		; And byte 0x12 to one
	ret

; ----------------------------------------------------------------------
; DATA fan_shot_speeds: Sixty-four bytes read by 0xB248 with `ld de,0xB26A`, as
;   words.
fan_shot_speeds:
	defw 0000h,0280h
	defw 00F5h,024Fh
	defw 01C5h,01C5h
	defw 024Fh,00F5h
	defw 0280h,0000h
	defw 024Fh,0FF0Bh
	defw 01C5h,0FE3Bh
	defw 00F5h,0FDB1h
	defw 0000h,0FD80h
	defw 0FF0Bh,0FDB1h
	defw 0FE3Bh,0FE3Bh
	defw 0FDB1h,0FF0Bh
	defw 0FD80h,0000h
	defw 0FDB1h,00F5h
	defw 0FE3Bh,01C5h
	defw 0FF0Bh,024Fh

	end

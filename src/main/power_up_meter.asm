; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - power_up_meter.asm
; ============================================================================

	public note_upgrades_held,take_upgrade
	extrn raise_difficulty

; ----------------------------------------------------------------------
; THE POWER-UP METER
; The six slots of the meter (SPEED UP, MISSILE, DOUBLE, LASER, OPTION and
; the shield) are painted lit or unlit according to what the ship already
; carries. 0xA022 walks the ship's card and leaves in 0xE131..0xE136 a one
; for each upgrade already taken; 0xA068 looks at 0xE130 (the selected
; slot) and, when the button is pressed, gives that upgrade if it is not
; there yet.
; ----------------------------------------------------------------------
note_upgrades_held:		; Leaves in 0xE131 to 0xE136 which upgrades the ship already has, to paint the meter
	ld hl,0e200h
	xor a
	ld b,a
	ld c,a
	ld d,a
	ld a,(hl)
	or a
	ret z
	dec a
	ld (0e136h),a		; 0xE136: the shield
	inc l
	inc l
	ld a,(hl)
	cp 008h			; Byte 2 above 8: it already has speed
	jr c,L_A038
	inc b
L_A038:
	ld a,b
	ld (0e131h),a		; 0xE131: the speed
	ld a,009h
	add a,l
	ld l,a
	ld a,(hl)
	cp 002h			; Byte 11 at two or more: it already has the missile
	jr c,L_A046
	inc c
L_A046:
	ld a,c
	ld (0e135h),a		; 0xE135: the missile
	inc l
	inc l
	ld a,(hl)
	ld (0e133h),a		; 0xE133: the double shot
	inc l
	ld a,(hl)
	cp 002h			; Byte 13 at two or more: it already has the laser
	jr c,L_A057
	inc d
L_A057:
	ld a,d
	ld (0e134h),a		; 0xE134: the laser
	inc l
	ld a,(hl)
	cp 002h			; And byte 14: the options
	ld a,000h
	jr c,L_A064
	inc a
L_A064:
	ld (0e132h),a
	ret
take_upgrade:		; With the button, if the selected slot of the meter is not already taken, the ship gets it and sound 0x14 plays
	ld a,(0e200h)
	dec a
	ret m
	ld a,(0e008h)		; Bit 5 of what was just pressed: the other button
	and 020h
	ret z
	ld a,(0e130h)		; 0xE130: the selected slot
	or a
	ret z
	ld c,a
	ld b,000h
	ld hl,0e130h
	add hl,bc
	ld a,(hl)		; If that upgrade is already there, nothing is done
	and a
	ret nz
	xor a
	ld (0e130h),a		; The meter goes back to zero
	ld hl,0a153h
	push hl
	ld a,014h		; Sound 0x14
	call 049deh
	ld a,c
	dec a
	call 04067h

; ----------------------------------------------------------------------
; DATA dispatcher_table_A091: Six words stuck right after the `call 0x4067` at
;   0xA091 (0xA0A0, 0xA0A5, 0xA0AC, 0xA0B7, 0xA0C1, 0xA0CB).
dispatcher_table_A091:
	defw upgrade_speed	; 0
	defw upgrade_missile	; 1
	defw upgrade_double	; 2
	defw upgrade_laser	; 3
	defw upgrade_option	; 4
	defw upgrade_shield	; 5
upgrade_speed:		; One more notch of speed
	ld hl,0e202h
	inc (hl)
	ret
upgrade_missile:		; Raises the missile and raises the difficulty
	ld hl,0e20fh
	inc (hl)
	jp 070cah
upgrade_double:		; Sets the double shot and removes the laser
	xor a			; 0xE20E to zero: no more laser
	ld hl,0e20eh
	ld (hl),a
	inc a
	dec l
	ld (hl),a		; And 0xE20C and 0xE20D to one: the double is on
	dec l
	ld (hl),a
	ret
upgrade_laser:		; Sets the laser and removes the double
	xor a			; 0xE20C and 0xE20D to zero: no more double
	ld hl,0e20ch
	ld (hl),a
	inc l
	ld (hl),a
	inc l
	inc (hl)		; And 0xE20E up: the laser is on
	ret
upgrade_option:		; One more option and the difficulty goes up
	ld hl,0e20bh
	inc (hl)
	call 09bfbh
	jp 070cah
upgrade_shield:		; 0xE200 to 3 and 0xE201 to 0x0A: the shield is on
	ld hl,0e200h		; 0xE200 to three and 0xE201 to 0x0A
	ld (hl),003h
	inc l
	ld (hl),00ah
	ld c,002h		; And 0x70CA raises the difficulty
	jp raise_difficulty

	end

; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - power_up_meter.asm
; ============================================================================

	include "variables.inc"

	public note_upgrades_held,take_upgrade
	extrn check_if_sound,dispatcher,raise_difficulty,refresh_meter,set_up_one_option

; ----------------------------------------------------------------------
; THE POWER-UP METER
; The six slots of the meter (SPEED UP, MISSILE, DOUBLE, LASER, OPTION and
; the shield) are painted lit or unlit according to what the ship already
; carries. note_upgrades_held walks the ship's card and leaves in METER_HELD..0xE136 a one
; for each upgrade already taken; take_upgrade looks at METER_SLOT (the selected
; slot) and, when the button is pressed, gives that upgrade if it is not
; there yet.
; ----------------------------------------------------------------------
note_upgrades_held:		; Leaves in METER_HELD to 0xE136 which upgrades the ship already has, to paint the meter
	ld hl,SHIP
	xor a
	ld b,a
	ld c,a
	ld d,a
	ld a,(hl)
	or a
	ret z
	dec a
	ld (METER_HELD+5),a	; The shield
	inc l
	inc l
	ld a,(hl)
	cp 008h			; Byte 2 above 8: it already has speed
	jr c,L_A038
	inc b
L_A038:
	ld a,b
	ld (METER_HELD),a	; The speed
	ld a,009h
	add a,l
	ld l,a
	ld a,(hl)
	cp 002h			; Byte 11 at two or more: it already has the missile
	jr c,L_A046
	inc c
L_A046:
	ld a,c
	ld (METER_HELD+4),a	; The missile
	inc l
	inc l
	ld a,(hl)
	ld (METER_HELD+2),a	; The double shot
	inc l
	ld a,(hl)
	cp 002h			; Byte 13 at two or more: it already has the laser
	jr c,L_A057
	inc d
L_A057:
	ld a,d
	ld (METER_HELD+3),a	; The laser
	inc l
	ld a,(hl)
	cp 002h			; And byte 14: the options
	ld a,000h
	jr c,L_A064
	inc a
L_A064:
	ld (METER_HELD+1),a
	ret
take_upgrade:		; With the button, if the selected slot of the meter is not already taken, the ship gets it and sound 0x14 plays
	ld a,(SHIP)
	dec a
	ret m
	ld a,(CONTROLLER_NEW)	; Bit 5 of what was just pressed: the other button
	and 020h
	ret z
	ld a,(METER_SLOT)	; The selected slot
	or a
	ret z
	ld c,a
	ld b,000h
	ld hl,METER_SLOT
	add hl,bc
	ld a,(hl)		; If that upgrade is already there, nothing is done
	and a
	ret nz
	xor a
	ld (METER_SLOT),a	; The meter goes back to zero
	ld hl,refresh_meter
	push hl
	ld a,014h		; Sound 0x14
	call check_if_sound
	ld a,c
	dec a
	call dispatcher

; ----------------------------------------------------------------------
; DATA power_up_upgrades: Six words stuck right after the `call dispatcher` at
;   0xA091 (upgrade_speed, upgrade_missile, upgrade_double, upgrade_laser, upgrade_option, upgrade_shield).
power_up_upgrades:
	defw upgrade_speed	; 0
	defw upgrade_missile	; 1
	defw upgrade_double	; 2
	defw upgrade_laser	; 3
	defw upgrade_option	; 4
	defw upgrade_shield	; 5
upgrade_speed:		; One more notch of speed
	ld hl,SHIP_SPEED
	inc (hl)
	ret
upgrade_missile:		; Raises the missile and raises the difficulty
	ld hl,SHIP_MISSILE
	inc (hl)
	jp raise_difficulty
upgrade_double:		; Sets the double shot and removes the laser
	xor a			; SHIP_LASER to zero: no more laser
	ld hl,SHIP_LASER
	ld (hl),a
	inc a
	dec l
	ld (hl),a		; And SHIP_SHOT and 0xE20D to one: the double is on
	dec l
	ld (hl),a
	ret
upgrade_laser:		; Sets the laser and removes the double
	xor a			; SHIP_SHOT and 0xE20D to zero: no more double
	ld hl,SHIP_SHOT
	ld (hl),a
	inc l
	ld (hl),a
	inc l
	inc (hl)		; And SHIP_LASER up: the laser is on
	ret
upgrade_option:		; One more option and the difficulty goes up
	ld hl,OPTION_COUNT
	inc (hl)
	call set_up_one_option
	jp raise_difficulty
upgrade_shield:		; SHIP to 3 and SHIP_TIMER to 0x0A: the shield is on
	ld hl,SHIP		; To three and SHIP_TIMER to 0x0A
	ld (hl),003h
	inc l
	ld (hl),00ah
	ld c,002h		; And raise_difficulty raises the difficulty
	jp raise_difficulty

	end

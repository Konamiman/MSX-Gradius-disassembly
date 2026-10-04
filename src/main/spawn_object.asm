; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - spawn_object.asm
; ============================================================================

	include "variables.inc"

	public spawn_object
	extrn finish_type_0A,finish_type_0B,finish_type_0C,finish_type_0D,finish_type_0F,finish_type_1
	extrn finish_type_11,finish_type_16,finish_type_17,finish_type_18,finish_type_19,finish_type_1B
	extrn finish_type_1D,finish_type_1E,finish_type_2,finish_type_3,finish_type_4,finish_type_5
	extrn finish_type_6,finish_type_7,finish_type_8,finish_type_9,finish_with_aim,finish_with_slow_aim
	extrn L_6B96,set_both_speeds,shot_speed

; ----------------------------------------------------------------------
; PUTTING A NEW OBJECT ON THE SCREEN
; This is the most called routine in the bank: all the enemy movers use it
; to release a shot, an explosion or a new enemy. It is entered with A =
; the type, DE = where it goes and C = an adjustment, and it looks for a
; free slot in the object table, fills it with the record that belongs to
; the type (four bytes from the table at 0x6BA3) and bumps the live count.
; Three types break the rule: 0x1E needs THREE consecutive slots (which
; is why 0x6AA1 looks for three consecutive free slots and adds two to the
; count), 0x0E goes to another table (the one at 0xE460, eight slots of
; 0x20 bytes counted backwards) and the rest to the one at 0xE300, twelve
; slots.
; ----------------------------------------------------------------------
spawn_object:		; Looks for a free slot and sets up there an object of type A, at position DE
	ld (SPAWN_POS),de	; Where it goes is noted
	ld (SPAWN_TYPE),a	; And the type
	xor a
	ld (SPAWNED_TYPE),a
	ld a,c
	ld (SPAWN_ADJUST),a
	ld a,(SPAWN_TYPE)
	cp 01eh			; Type 0x1E takes three slots
	jp z,find_three_consecutive_slots
	sub 00eh		; And 0x0E goes to the other table
	jr z,search_other_table
	ld hl,OBJECTS		; The twelve slots, 0x20 apart
	ld b,00ch
	ld de,00020h
	xor a
	jr find_free_slot
find_three_consecutive_slots:		; The big object needs three consecutive free slots; if there are none, it does not come out
	ld hl,OBJECTS
	ld c,00ch
	ld de,00020h
	xor a
L_6AA1:
	ld b,003h		; Three in a row
L_6AA3:
	cp (hl)			; Three free slots in a row
	add hl,de		; Compared with zero: free slot
	jr nz,L_6AAE		; Thirty-two bytes: the next slot
	dec b
	jr z,L_6AB2
	dec c
	jr nz,L_6AA3
	ret
L_6AAE:
	dec c
	jr nz,L_6AA1
	ret
L_6AB2:
	ld de,0ffa0h		; Go back to the first of the three
	add hl,de
	exx
	ld hl,LIVE_OBJECTS	; And two more in the live count: it is three slots
	inc (hl)
	inc (hl)
	exx
	jr set_up_object
search_other_table:		; Type 0x0E lives at 0xE460, eight slots counted backwards
	ld de,0ffe0h		; Type 0x0E goes to the table at 0xE460
	ld b,008h
	ld hl,OBJECTS+(OBJECT_COUNT-1)*OBJECT_SIZE	; Eight slots counting backwards
find_free_slot:		; The first one with its first byte at zero
	cp (hl)
	jr z,set_up_object
	add hl,de
	djnz find_free_slot
	ret
set_up_object:		; Fills the slot: type, counters to zero, the position, and the four bytes from the table at 0x6BA3
	ld de,(SPAWN_POS)	; The position, which was parked
	exx
	ld hl,LIVE_OBJECTS	; One more in the count of live objects
	inc (hl)
	exx
	push hl
	pop ix
	ld a,(SPAWN_TYPE)
	ld (SPAWNED_TYPE),a
	ld (ix+01bh),003h	; Byte 27 to three
	ld (hl),a
	inc l
	xor a
	ld (hl),a
	inc l
	ld (hl),a
	inc l
	inc l
	ld (hl),e		; The Y goes to byte 4...
	inc l
	inc l
	ld (hl),d		; ...and the X to byte 6
	ld de,00005h
	add hl,de
	ld de,06ba3h		; The table at 0x6BA3: four bytes per type
	ld a,(SPAWN_TYPE)
	add a,a			; Times four
	add a,a
	add a,e
	ld e,a
	jr nc,L_6B02
	inc d
L_6B02:
	ex de,hl		; Three bytes of the type's record
	ldi
	ldi
	ldi
	ld a,(SPAWN_ADJUST)	; With the adjustment set, byte 13 carries 8; type 0x0D, 6
	ld (de),a		; Byte 13: eight, or six if it is type 0x0D
	and a			; Type 0x0D carries six
	jr z,L_6B1E
	ld b,008h
	ld a,(SPAWN_TYPE)
	cp 00dh
	jr nz,L_6B1B
	ld b,006h
L_6B1B:
	ld (ix+00dh),b
L_6B1E:
	inc e
	ldi
	call shot_speed		; The speed, which comes from the difficulty and the R register
	ld (de),a
	inc de
	xor a
	ld (de),a
	ld a,(SPAWN_TYPE)	; Types 2, 0x0A and 0x0C carry two more bytes
	cp 002h			; The type, again
	jr z,L_6B37
	cp 00ah
	jr z,L_6B37
	cp 00ch
	jr nz,L_6B3F
L_6B37:
	ld a,001h
	ld (de),a
	inc de
	ld a,(FILE_WAVE_NUMBER)
	ld (de),a
L_6B3F:
	ld a,(SPAWN_TYPE)	; And each type finishes its record on its own: thirty-one exits
	dec a
	call 04067h

; ----------------------------------------------------------------------
; DATA dispatcher_table_6B43: Thirty-one words stuck right after the `call
;   0x4067` at 0x6B43. Almost all the destinations fall in bank 3
;   (0xA000-0xBFFF).
dispatcher_table_6B43:
	defw finish_type_1	; 0
	defw finish_type_2	; 1
	defw finish_type_3	; 2
	defw finish_type_4	; 3
	defw finish_type_5	; 4
	defw finish_type_6	; 5
	defw finish_type_7	; 6
	defw finish_type_8	; 7
	defw finish_type_9	; 8
	defw finish_type_0A	; 9
	defw finish_type_0B	; 10
	defw finish_type_0C	; 11
	defw finish_type_0D	; 12
	defw finish_with_aim	; 13
	defw finish_type_0F	; 14
	defw set_both_speeds	; 15
	defw finish_type_11	; 16
	defw L_6B96		; 17
	defw L_6B96		; 18
	defw L_6B96		; 19
	defw L_6B96		; 20
	defw finish_type_16	; 21
	defw finish_type_17	; 22
	defw finish_type_18	; 23
	defw finish_type_19	; 24
	defw L_6B96		; 25
	defw finish_type_1B	; 26
	defw finish_with_slow_aim	; 27
	defw finish_type_1D	; 28
	defw finish_type_1E	; 29
	defw L_6B96		; 30

	end

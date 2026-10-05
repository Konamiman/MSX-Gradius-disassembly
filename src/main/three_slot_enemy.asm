; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - three_slot_enemy.asm
; ============================================================================

	include "variables.inc"

	public finish_type_1E,move_type_1E,move_type_1F,type_1E_splits_in_three
	extrn add_horizontal_acceleration,add_speed,add_vertical_acceleration,aim_acceleration,blow_up_enemy,collides_with_map
	extrn L_9239,negate_horizontal_speed,set_horizontal_speed,set_vertical_speed,zero_speed

; ----------------------------------------------------------------------
; THE THREE-SLOT ENEMY
; Type 0x1E is the only one that does not fit in one slot: it takes THREE
; in a row, and that is why p01:find_three_consecutive_slots looks for them three at a time.
; Here the other two are set up with a single 0x40-byte `ldir` that
; overlaps itself (copying the first onto the second and the second onto
; the third), and then they are given their position: one 0x10 below and
; eight to the left, and the other 0x10 below and eight to the right. Only
; the first one moves; the other two follow it. When its count runs out,
; all three turn into type 0x1F and fly off, each in its own direction.
; ----------------------------------------------------------------------
finish_type_1E:		; Sets up the three slots, places them in a triangle and gives them the speed of their door
	ld a,(BIGFLOCK_DOOR)	; Which door it came in through
	or a
	jr nz,L_BC05
	ld a,(SHIP_ROW)		; With the ship below row 0x50 it comes in at the top, and otherwise at the bottom
	cp 050h
	ld a,018h
	jr nc,L_BC02
	ld a,078h
L_BC02:
	ld (ix+004h),a
L_BC05:
	call zero_speed
	ld (ix+01dh),000h
	call copy_other_two_slots	; The other two slots, copied
	call place_three_in_triangle	; And placed in a triangle
	xor a
	call set_drawing_trio
	ld (ix+014h),001h	; Byte 20: the frames until the drawing changes
	ld (ix+002h),05ah	; 0x5A frames of life
	ld (ix+013h),000h	; Byte 19 says which of the three each one is
	ld (ix+033h),001h
	ld (ix+053h),002h
	ld a,(BIGFLOCK_DOOR)	; The table at type_1E_door_speeds: two speeds per door
	add a,a
	add a,a
	ld e,a
	ld d,000h
	ld hl,type_1E_door_speeds
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	call set_vertical_speed
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	jp set_horizontal_speed

; ----------------------------------------------------------------------
; DATA type_1E_door_speeds: Sixteen bytes read by 0xBC32, as words.
type_1E_door_speeds:
	defw 0000h,0040h
	defw 0000h,0FF40h
	defw 0000h,0FFC0h
	defw 0000h,0FF80h
blink_type_1E:		; Changes its trio of drawings every 0x0F or every 5 frames, drawn by lot with the R register
	dec (ix+014h)
	ret nz
	ld b,00fh
	ld a,r			; The R register: 0x0F frames or only 5
	and 001h
	jr nz,L_BC61
	ld b,005h
L_BC61:
	ld (ix+014h),b
	ld a,(ix+01dh)		; Byte 29: one trio or the other
	xor 001h
	ld (ix+01dh),a
set_drawing_trio:		; One character for each of the three slots
	ld hl,type_1E_drawing_trios
	jr z,L_BC74
	ld hl,type_1E_drawing_trios+3
L_BC74:
	ld a,(hl)		; The first slot's...
	ld (ix+00ch),a
	inc hl
	ld a,(hl)		; ...the second's, 0x20 bytes further on...
	ld (ix+02ch),a
	inc hl
	ld a,(hl)		; ...and the third's
	ld (ix+04ch),a
	ret

; ----------------------------------------------------------------------
; DATA type_1E_drawing_trios: Six bytes read by set_drawing_trio (0xBC83) and 0xBC71 (0xBC86).
type_1E_drawing_trios:
	defb 0D0h,0D4h,0D8h
	defb 0DCh,0E0h,0E4h
set_colour_of_three:		; Colour 7 or 5, the same in all three slots
	bit 2,a
	ld a,007h
	jr z,L_BC91
	ld a,005h
L_BC91:
	ld (ix+00dh),a
	ld (ix+02dh),a
	ld (ix+04dh),a
	ret
copy_other_two_slots:		; A 0x40-byte `ldir` that overlaps itself: a single copy does both
	push ix
	pop hl
	ld d,h
	ld e,l
	ld a,020h		; The destination, 0x20 bytes ahead of the source
	add a,e
	ld e,a
	jr nc,L_BCA7
	inc d
L_BCA7:
	ld bc,00040h		; 0x40 bytes: the two slots behind
	ldir
	ret
place_three_in_triangle:		; The second 0x10 lower and eight to the left; the third, eight to the right
	ld a,(ix+004h)
	add a,010h		; 0x10 below the first
	ld d,a
	ld (ix+024h),d
	ld a,(ix+006h)
	sub 008h		; And eight to the left
	ld e,a
	ld (ix+026h),e
	ld (ix+044h),d
	ld a,e
	add a,010h		; The third, eight to the right
	ld (ix+046h),a
	ret
type_1E_fires:		; From the second loop onwards and with the shield on, every 0x20 frames
	ld a,(LOOP_NUMBER)	; On the first loop it does not fire
	or a
	ret z
	ld a,(OPTION_COUNT)	; Nor without the shield
	cp 002h
	ret c
	ld a,(FRAME_COUNT)	; One frame in every 0x20
	and 01fh
	ret nz
	ld a,(CONTROLLER_NEW)
	and 010h
	ret z
	jp L_9239
move_type_1E:		; Only the first slot moves: it closes in on the ship's row between 0x10 and 0x70, and drags the other two along
	ld a,(ix+013h)		; The second and third slots do not move on their own
	or a
	ret nz
	dec (ix+002h)		; Byte 2: the frames of life
	jr z,type_1E_splits_in_three
	ld a,(ix+002h)
	cp 01eh			; With 0x1E to go, it starts blinking its colour
	call c,set_colour_of_three
	call blink_type_1E	; The drawing, which goes its own way
	call type_1E_fires
	ld a,(SHIP_ROW)		; The ship's row minus its own
	sub (ix+004h)
	ld de,00020h		; A third of a point towards it
	jr nc,L_BD09
	ld de,0ffe0h
L_BD09:
	call set_vertical_speed
	call add_speed
	ld a,070h		; Not past row 0x70...
	cp (ix+004h)
	jr nc,L_BD1B
	ld (ix+004h),a
	jr L_BD25
L_BD1B:
	ld a,010h		; ...nor above 0x10
	cp (ix+004h)
	jr c,L_BD25
	ld (ix+004h),a
L_BD25:
	call place_three_in_triangle	; And the other two, behind
	ld a,(ix+006h)
	sub 010h
	cp 0d0h			; Past column 0xD0, it is turned round
	ret c
	jp negate_horizontal_speed
type_1E_splits_in_three:		; Once the count is over, the three slots become type 0x1F and fly off, each in its own direction
	ld hl,type_1E_split_speeds	; The table at type_1E_split_speeds: two speeds per piece
	exx
	ld b,003h		; The three slots
L_BD39:
	exx
	ld (ix+000h),01fh	; Type 0x1F and character 0xE8
	ld (ix+00ch),0e8h
	xor a
	ld (ix+002h),a
	ld (ix+01dh),a
	inc a
	ld (ix+00fh),a
	inc a
	inc a
	ld (ix+01bh),a
	ld (ix+014h),a
	ld e,(hl)
	inc hl
	ld d,(hl)
	call set_vertical_speed
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	call set_horizontal_speed
	ld bc,00020h		; 0x20 bytes: the next slot
	add ix,bc
	exx
	djnz L_BD39
	ld bc,0ffa0h		; And back to the first
	add ix,bc
	ret

; ----------------------------------------------------------------------
; DATA type_1E_split_speeds: Twelve bytes read by type_1E_splits_in_three, as signed words.
type_1E_split_speeds:
	defw 0FF80h,0000h
	defw 0080h,0FF80h
	defw 0080h,0080h
move_type_1F:		; Blows up when it touches the map, blinks, and chases the ship or heads for row 0x58 depending on the big ones' flock
	call type_1F_touches_map
	jp c,blow_up_enemy	; Touching the map, it blows up
	call blink_type_1F	; The blinking
	ld a,(BIGFLOCK_ON)	; With the big ones' flock under way, it chases
	or a
	jr z,L_BD95
	call aim_acceleration	; The acceleration towards the ship, and the two sums
	call add_vertical_acceleration
	jp add_horizontal_acceleration
L_BD95:
	ld a,(ix+004h)		; And otherwise, it heads for row 0x58
	cp 058h
	ld de,00200h		; Two points downwards...
	jr nc,L_BDA2
	ld de,0fe00h		; ...or two upwards
L_BDA2:
	jp set_vertical_speed
type_1F_touches_map:		; Checks the cell where it is and, if it is descending, the one 0x10 lower
	ld l,(ix+004h)		; Its row and its column
	ld h,(ix+006h)
	bit 7,(ix+008h)		; Byte 8: when descending, it looks lower
	jr nz,L_BDB5
	ld a,l
	add a,010h
	ld l,a
L_BDB5:
	jp collides_with_map
blink_type_1F:		; Flips bit 2 of its character every 10 or every 3 frames, drawn by lot with the R register
	dec (ix+014h)
	ret nz
	ld b,00ah
	ld a,r			; The R register: 10 frames or only 3
	and 001h
	jr nz,L_BDC6
	ld b,003h
L_BDC6:
	ld (ix+014h),b
	ld a,(ix+00ch)
	xor 004h		; Bit 2 of the character: two drawings
	ld (ix+00ch),a
	ret

	end

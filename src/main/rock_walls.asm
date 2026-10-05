; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - rock_walls.asm
; ============================================================================

	include "variables.inc"

	public check_for_wall,finish_type_0A,finish_type_0B,finish_type_8,finish_type_9,move_type_0A
	public move_type_0B,move_type_8,move_type_9
	extrn add_vertical_acceleration,aim_from_where_it_is,animate_round_and_round,compare_speed_and_acceleration,fire_without_aiming,get_word
	extrn L_9239,L_ABCC,move_with_scroll_eight,negate_horizontal_speed,set_horizontal_acceleration,set_horizontal_speed
	extrn set_negated_acceleration,set_vertical_acceleration,set_vertical_speed,zero_speed

; ----------------------------------------------------------------------
; THE ROCK WALLS OF STAGES 2 AND 8
; There is no time script here: there is a list of DISTANCES. On every step
; with a new column the stage's list is walked (stage_2_wall_distances for the second and
; stage_8_wall_distances for the eighth) and each distance is compared with the one
; travelled; on an exact match, a wall of five rocks (three in the eighth)
; is released through one column or the other, one per frame. Bit 7 of the
; distance, which is set aside before comparing, is what says which side
; they come in from.
; ----------------------------------------------------------------------
check_for_wall:		; Compares the distance travelled with the stage's list and, on a match, sets up a wall of rocks
	ld a,(WALL_ON)		; With a wall under way, go and release it
	or a
	jp nz,release_wall
	ld a,(NEW_COLUMN)	; Only on steps with a new column
	or a
	ret z
	ld a,(STAGE)		; The second stage has its list...
	cp 002h
	jp z,L_AC13
	cp 008h			; ...and the eighth its own; the others have none
	ret nz
	ld hl,stage_8_wall_distances	; Seventeen distances, and walls of three
	ld bc,01101h
	jp L_AC19
L_AC13:
	ld hl,stage_2_wall_distances	; Six distances, and walls of five
	ld bc,00600h
L_AC19:
	ld (WALL_LIST),hl	; The list and the count are parked
	ld (WALL_OF_THREE),bc
walk_distances:		; One by one, against the distance travelled
	push bc
	ld a,(WALL_LIST_LEN)	; From the count comes the index
	sub b
	ld hl,(WALL_LIST)
	call get_word		; The word that is due from the list
	ld a,d
	exx			; The high byte is saved whole...
	ld d,a
	exx
	and 07fh		; ...and compared without its bit 7
	ld d,a
	ld hl,(DISTANCE)	; DCOMPR against the distance travelled
	rst 20h
	pop bc
	jp z,set_up_wall	; Exactly this one: wall
	djnz walk_distances
	ret
set_up_wall:		; Bit 7 of the distance picks the column, and the stage how many rocks it brings
	exx
	rl d			; Bit 7, set aside earlier: which side they come in from
	ld a,0c0h		; Column 0xC0...
	jp nc,L_AC47
	ld a,040h		; ...or 0x40
L_AC47:
	ld (WALL_COLUMN),a	; They all fall through there
	ld hl,00501h		; Five rocks, one per frame...
	ld a,(WALL_OF_THREE)
	or a
	jp z,L_AC57
	ld hl,00302h		; ...or three, one every two frames
L_AC57:
	ld (WALL_ON),hl
	ret
release_wall:		; One rock per frame, each one on its row, until the count runs out
	ld hl,wall_rock_rows-1	; The table base lands on the `ret` right next to it: it is never read, because the index is never zero
	dec a
	jp z,L_AC63
	inc hl
L_AC63:
	ld a,(WALL_ROCK)	; Which one is due
	add a,l
	ld l,a
	jr nc,L_AC6B
	inc h
L_AC6B:
	ld e,(hl)
	ld a,(WALL_COLUMN)	; All through the same column
	ld d,a
	call L_ABCC		; Type 8: the rock
	ld hl,WALL_ROCK
	dec (hl)		; One fewer
	ret nz
	dec l
	ld (hl),000h		; And with the last one, the wall is over
L_AC7B:
	ret

; ----------------------------------------------------------------------
; DATA wall_rock_rows (part): Six bytes read by release_wall with base 0xAC7B.
wall_rock_rows:
	defb 8Ch,6Ch,4Ch,2Ch,0Ch

; ----------------------------------------------------------------------
; DATA stage_2_wall_distances: Twelve bytes read by L_AC13.
stage_2_wall_distances:
	defb 44h,01h
	defb 4Ch,01h
	defb 70h,01h
	defb 78h,01h
	defb 80h,01h
	defb 88h,01h

; ----------------------------------------------------------------------
; DATA stage_8_wall_distances: Thirty-four bytes read by 0xAC0A, in pairs.
stage_8_wall_distances:
	defb 88h,00h
	defb 90h,00h
	defb 0C8h,00h
	defb 0D0h,00h
	defb 04h,01h
	defb 1Ch,01h
	defb 24h,01h
	defb 50h,01h
	defb 58h,01h
	defb 60h,01h
	defb 62h,81h
	defb 68h,01h
	defb 6Ah,81h
	defb 70h,01h
	defb 72h,81h
	defb 78h,01h
	defb 7Ah,81h
finish_type_8:		; Counters to zero, ten frames in byte 2, and still
	xor a
	ld (ix+01bh),a
	ld (ix+01dh),a
	ld (ix+002h),00ah	; Ten frames
	jp zero_speed
move_type_8:		; The rock grows in three steps of ten frames and, once grown, stays still and fires
	ld a,(ix+001h)		; Byte 1: whether it has already grown
	or a
	jr nz,rock_fires
	call move_with_scroll_eight	; While it grows it moves with the scroll
	dec (ix+002h)		; Ten frames per step
	ret nz
	inc (ix+01dh)		; One more step of the three
	ld a,(ix+01dh)
	cp 003h
	jr nc,L_ACDA
	ld (ix+002h),00ah	; Another ten frames
	jr rock_drawing
L_ACDA:
	ld (ix+01bh),003h	; Byte 27 to three: fully grown
	inc (ix+001h)
	call rock_drawing	; The big drawing
	call its_shot_speed	; And the speed of its shots
	jp aim_from_where_it_is
rock_fires:		; Once grown, it releases a shot every eight frames
	ld a,(LOOP_NUMBER)	; On the first loop it does not fire
	dec a
	ret m
	jr nz,L_ACFC
	ld a,(SHIP)		; With the ship halfway through exploding, not either
	cp 003h
	ret c
	ld a,(SHIP_LASER)
	or a
	ret z
L_ACFC:
	ld a,(CONTROLLER_NEW)	; Bit 4
	and 010h
	ret z
	ld a,(FRAME_COUNT)	; One frame in every eight
	and 007h
	ret nz
	jp L_9239
rock_drawing:		; From the pair at 0xAD16 come the character and the colour: 0xC0 in 5, 0xC4 in 7 and 0xC8 in 0x0F
	ld hl,rock_growth_drawings-2	; The table at 0xAD16, in pairs
	call get_word
	ld (ix+00ch),d		; The character to byte 12 and the colour to 13
	ld (ix+00dh),e
	ret

; ----------------------------------------------------------------------
; DATA rock_growth_drawings (part): Eight bytes read by rock_drawing with base 0xAD16, in
;   pairs.
rock_growth_drawings:
	defb 05h,0C0h
	defb 07h,0C4h
	defb 0Fh,0C8h
its_shot_speed:		; 0x40 plus the difficulty
	ld a,(DIFFICULTY)
	add a,040h
	ld (ENEMY_SHOT_SPEED),a
	ret
finish_type_9:		; No vertical speed and three points to the left
	ld de,00000h
	call set_vertical_speed
	ld de,0fd00h
	jp set_horizontal_speed
move_type_9:		; Crosses in a straight line and, past the middle of the screen, gets level with the ship
	call fire_without_aiming	; Fires without aiming
	ld bc,00306h		; Six drawings, one every four frames
	ld hl,type_9_drawings
	call animate_round_and_round
	ld a,(ix+006h)		; Up to column 0x80 it goes straight
	cp 080h
	ret nc
	ld a,(SHIP_ROW)		; The ship's row minus its own
	sub (ix+004h)
	push af
	add a,003h
	cp 007h			; Within seven it is already on its row
	jr c,on_ship_row
	pop af
	jr c,climb_towards_ship
	ld de,00100h		; Ship below: one point per frame downwards
	jp set_vertical_speed
climb_towards_ship:		; One point per frame upwards
	ld de,0ff00h		; Above: one upwards
	jp set_vertical_speed
on_ship_row:		; Stays at that height
	pop af
	ld de,00000h		; And on its row, neither up nor down
	jp set_vertical_speed

; ----------------------------------------------------------------------
; DATA type_9_drawings: Six bytes read by 0xAD39: there and back (0xEC, 0xF0, 0xF4,
;   0xF8, 0xF4, 0xF0).
type_9_drawings:
	defb 0ECh,0F0h,0F4h,0F8h,0F4h,0F0h
finish_type_0A:		; The ones in the wave curve alternately: one upwards and the next one downwards
	ld de,00080h
	ld bc,0fc00h
	ld a,(FILE_WAVE_LEFT)	; How many are left of the wave
	bit 0,a			; Its bit 0 decides which way this one curves
	jr nz,L_AD81
	ld de,0ff80h
	ld bc,00400h
L_AD81:
	call set_vertical_acceleration
	ld d,b
	ld e,c
	call set_vertical_speed
	call set_horizontal_acceleration
	ld de,0fd00h		; Three points to the left
	jp set_horizontal_speed
move_type_0A:		; Keeps curving and, on reaching column 0x30, turns round and goes back the way it came
	call fire_without_aiming	; Fires without aiming
	call animate_type_0A	; Six drawings, one every four frames
	call add_vertical_acceleration	; The curve: the acceleration is added to the speed
	call compare_speed_and_acceleration
	call z,set_negated_acceleration
	ld a,(ix+006h)		; Past column 0x30...
	cp 030h
	call c,negate_horizontal_speed	; ...it is turned round and goes back
	ret
animate_type_0A:		; Six drawings there and back, one every four frames
	ld bc,00306h
	ld hl,type_0A_drawings
	jp animate_round_and_round

; ----------------------------------------------------------------------
; DATA type_0A_drawings: Six bytes read by 0xADAD: another there and back (0xBC,
;   0xC0, 0xC4, 0xC8, 0xC4, 0xC0).
type_0A_drawings:
	defb 0BCh,0C0h,0C4h,0C8h,0C4h,0C0h
finish_type_0B:		; The speeds come from a table indexed by SHOT_BURST, and on the second loop they are faster
	ld a,(LOOP_NUMBER)	; From the second loop onwards, another table
	or a
	ld bc,0fe00h		; Two points to the left...
	ld hl,type_0B_vertical_speeds-2
	jr z,L_ADCB
	ld bc,0fd00h		; ...or three on the second loop
	ld hl,type_0B_vertical_speeds_loop2
L_ADCB:
	ld a,(SHOT_BURST)	; Says which of the pairs it gets
	call get_word
	call set_vertical_speed
	ld d,b
	ld e,c
	jp set_horizontal_speed

; ----------------------------------------------------------------------
; DATA type_0B_vertical_speeds (part): Six bytes read by 0xADC0.
type_0B_vertical_speeds:
	defb 00h,0FFh,00h,00h

; ----------------------------------------------------------------------
; DATA type_0B_vertical_speeds_loop2: Eight bytes read by 0xADC8.
type_0B_vertical_speeds_loop2:
	defb 00h,01h
	defb 80h,0FEh
	defb 00h,00h
	defb 80h,01h
move_type_0B:		; Four drawings, and from the third loop onwards it fires every 0x20 frames
	ld bc,00304h		; Four drawings, one every four frames
	ld hl,type_0B_drawings
	call animate_round_and_round
	ld a,(LOOP_NUMBER)	; It does not fire until the third loop
	cp 002h
	ret c
	ld a,(FRAME_COUNT)	; One frame in every 0x20
	and 01fh
	ret nz
	ld a,(CONTROLLER_NEW)	; Bit 4
	and 010h
	ret z
	jp L_9239

; ----------------------------------------------------------------------
; DATA type_0B_drawings: Four bytes (0xDC, 0xE0, 0xE4, 0xE8) read by 0xADE8.
type_0B_drawings:
	defb 0DCh,0E0h,0E4h,0E8h

	end

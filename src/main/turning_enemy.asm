; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - turning_enemy.asm
; ============================================================================

	include "variables.inc"

	public finish_type_5,finish_type_6,move_type_2,move_type_6
	extrn add_vertical_acceleration,animate_round_and_round,collides_with_map_3,finish_type_2,fire_without_aiming,how_far_it_walks
	extrn L_9535,set_horiz_speed_from_acceleration,set_horizontal_speed,set_vertical_acceleration,set_vertical_speed,time_to_move

; ----------------------------------------------------------------------
; THE ENEMY THAT TURNS BACK
; Type 2 does not just cross the screen: it comes in from the right, and on
; reaching column 0x81 (0x7F if it is in the bottom half) it curves towards
; the centre and goes back; at 0x9F it stops and heads left again, this
; time as far as 0x51; and when it finally gets level with the ship, it
; stops climbing and descending and flies straight on.
; These are four steps counted in byte 1.
; ----------------------------------------------------------------------
move_type_2:		; The four steps of the turn: to 0x81, back to 0x9F, to 0x51, and straight on once level with the ship
	ld a,(DIFFICULTY)	; From difficulty 8 onwards, it also fires
	cp 008h
	call nc,fire_without_aiming
	call animate_type_2	; Four drawings, one every four frames
	ld a,(ix+001h)		; Byte 1: which step it is on
	dec a
	jr z,back_to_column_9F
	dec a
	jr z,again_to_51
	dec a
	jr z,level_with_ship
	dec a
	ret z
	ld bc,0817fh		; The limit of step 0: 0x81 at the top and 0x7F at the bottom
L_A8CE:
	ld a,(ix+004h)		; Above row 0x50...
	cp 050h
	jr c,L_A8D6
	ld b,c			; ...and below it, the other limit
L_A8D6:
	ld a,(ix+006h)		; Until it reaches the limit, straight on
	cp b
	ret nc
	inc (ix+001h)
	ld de,00400h		; Four downwards if it is at the top...
	ld a,(ix+004h)
	cp 050h
	jr c,L_A8EB
	ld de,0fc00h		; ...or four upwards if it is at the bottom
L_A8EB:
	call set_vertical_speed
	ld de,00400h		; And four to the right: it turns back
	jp set_horizontal_speed
back_to_column_9F:		; On reaching 0x9F it aligns the row to eight and heads left again
	ld a,(ix+006h)
	cp 09fh
	ret c
	ld a,(ix+004h)		; The row, aligned to eight
	and 0f8h
	ld (ix+004h),a
	inc (ix+001h)
	jp finish_type_2
again_to_51:		; The same step, with the limit at 0x51
	ld bc,0514fh
	jp L_A8CE
level_with_ship:		; Within nine of its row it stops climbing and descending and carries straight on
	ld a,(SHIP_ROW)		; The ship's row minus its own
	sub (ix+004h)
	add a,004h
	cp 009h
	ret nc
	inc (ix+001h)
	ld a,(ix+004h)
	and 0f8h
	ld (ix+004h),a
	xor a			; No vertical speed
	ld d,a
	ld e,a
	jp set_vertical_speed
animate_type_2:		; Four drawings, one every four frames
	ld bc,00304h
	ld hl,type_2_drawings
	jp animate_round_and_round

; ----------------------------------------------------------------------
; DATA type_2_drawings: Four bytes (0, 1, 2, 3) read by 0xA92D.
type_2_drawings:
	defb 00h,01h,02h,03h
finish_type_6:		; Shoots off upwards and towards the centre of the screen, wound up for 0x78 frames
	ld (ix+01ch),078h	; Byte 28: 0x78 frames of wind-up
	ld de,00060h		; 0x60 of vertical acceleration...
	call set_vertical_acceleration
	ld de,0fa00h		; ...against six points per frame upwards
	call set_vertical_speed
	call L_9535
	ld de,0fe00h
	bit 7,(ix+006h)		; In the right half, two points to the left...
	jp nz,set_horizontal_speed
	ld de,00200h		; ...and in the left half, two to the right
	jp set_horizontal_speed
move_type_6:		; Climbs until its wind-up runs out or it finds ground, and then launches itself towards the ship's column
	call fire_without_aiming	; Fires without aiming
	call animate_type_6	; Four drawings, one every four frames
	ld a,(ix+001h)		; Byte 1: which step it is on
	dec a
	jr z,type_6_step_1
	jp p,type_6_step_2
	dec (ix+01ch)		; Its wind-up runs out...
	jr z,move_to_next_step
	call time_to_move	; ...or it is its turn to move
	jr c,move_to_next_step
L_A973:
	call has_ground_below
	jp nc,add_vertical_acceleration
	ld de,00200h		; Two points towards the ship's column
	ld a,(SHIP_COLUMN)	; The ship's column
	sub (ix+006h)
	jr nc,L_A987
	ld de,0fe00h
L_A987:
	call set_horizontal_speed
	jp set_horiz_speed_from_acceleration
move_to_next_step:		; One more step and carry on
	inc (ix+001h)
	jp L_A973
type_6_step_1:		; On hitting ground, two points to the left and it plants itself
	call has_ground_below	; With ground below, it plants itself
	jp nc,add_vertical_acceleration
	inc (ix+001h)
	ld de,0fe00h		; Two points to the left
	call set_horizontal_speed
	jp set_horiz_speed_from_acceleration
type_6_step_2:		; Now it just lets the acceleration carry it
	call has_ground_below	; Now it just lets itself be carried
	jp nc,add_vertical_acceleration
	jp set_horiz_speed_from_acceleration
has_ground_below:		; Climbing, no; descending, and between rows 0x58 and 0x9F, checks whether the map has wall 0x10 lower down
	ld a,(ix+008h)		; Byte 8: climbing, there is nothing to check
	or a
	ret m
	ld a,(ix+004h)		; Above row 0x58, nothing either...
	cp 058h
	ccf
	ret nc
	cp 09fh			; ...nor below 0x9F
	ccf
	ret c
	add a,010h		; 0x10 lower: that is where the map is checked
	ld l,a
	ld h,(ix+006h)
	jp collides_with_map_3
animate_type_6:		; Four drawings, one every four frames
	ld bc,00304h
	ld hl,type_6_drawings
	jp animate_round_and_round

; ----------------------------------------------------------------------
; DATA type_6_drawings: Four bytes (0xA0, 0xA4, 0xA8, 0xAC) read by 0xA9CA.
type_6_drawings:
	defb 0A0h,0A4h,0A8h,0ACh
finish_type_5:		; Depending on whether it drops in at the top or the bottom, one drawing or the other, and two points to the right
	ld a,(ix+004h)		; Bit 7 of the row: which half it comes in through
	or a
	ld b,000h		; At the top, drawing 0xF8...
	ld c,0f8h
	jp p,L_A9E2
	inc b			; ...and at the bottom, 0xE8
	ld c,0e8h
L_A9E2:
	ld (ix+013h),b		; Byte 19 notes where it came in
	ld (ix+00ch),c
	ld (ix+01ch),00ah	; Ten frames of wind-up
	call how_far_it_walks
	ld de,00000h		; No vertical speed
	call set_vertical_speed
	ld de,00200h		; And two points to the right
	jp set_horizontal_speed

	end

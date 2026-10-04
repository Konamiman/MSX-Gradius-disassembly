; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - piece_route.asm
; ============================================================================

	public add_horizontal_acceleration,add_vertical_acceleration,aim_cannon,animate_round_and_round,compare_speed_and_acceleration,draw_the_five
	public erase_the_five,fire_without_aiming,L_9239,L_9535,move_with_scroll_eight,negate_horizontal_speed
	public negate_vertical_speed,note_cells_of_the_five,release_enemies,release_enemies_on_column,run_five_pieces,script_entry
	public set_horiz_speed_from_acceleration,set_horizontal_acceleration,set_negated_acceleration,set_up_five_pieces,set_vertical_acceleration,step_0_two_left
	public step_10_towards_ship,step_11_leaves,step_1_diagonal,step_2_two_left,step_3_diagonal_up,step_4_two_left
	public step_5_diagonal,step_6_two_left,step_7_diagonal_up,step_8_two_down,step_9_two_right,time_to_move
	public wait_until_next_shot,walk_the_eight,zero_speed
	extrn card_position,mark_boss_dead

; ----------------------------------------------------------------------
; THE PIECE'S ROUTE, WRITTEN OUT STEP BY STEP
; This piece does not chase anybody: it follows a fixed route, written as
; twelve steps. Each one adds a constant speed (two signed bytes) and
; waits for it to reach an exact coordinate; when it gets there, it moves
; on to the next step. The only one that looks at the ship is 0x0A, which
; chooses which way to go before carrying on.
; ----------------------------------------------------------------------
step_0_two_left:		; Two to the left until X 0xE6
	ld de,000feh
	call add_to_fields_3_and_5
	cp 0e6h
	ret nz
	jr next_route_step
step_1_diagonal:		; Two to the left and two down until Y 0x30
	ld de,002feh		; Two to the left and two down
	call add_to_fields_3_and_5	; Two to the left and two down
	ld a,d			; Y 0x30
	cp 030h
	ret nz
	jr next_route_step
step_2_two_left:		; Until X 0x98
	ld de,000feh
	call add_to_fields_3_and_5
	cp 098h
	ret nz
	jr next_route_step
step_3_diagonal_up:		; Two to the left and two up until Y 0x18
	ld de,0fefeh		; Two to the left and two up
	call add_to_fields_3_and_5	; Two to the left and two up
	ld a,d			; Y 0x18
	cp 018h
	ret nz
	jr next_route_step
step_4_two_left:		; Until X 0x66
	ld de,000feh
	call add_to_fields_3_and_5
	cp 066h
	ret nz
	jr next_route_step
step_5_diagonal:		; Until Y 0x30
	ld de,002feh		; Two to the left and two down
	call add_to_fields_3_and_5	; Two to the left and two down
	ld a,d			; Y 0x30
	cp 030h
	ret nz
	jr next_route_step
step_6_two_left:		; Until X 0x18
	ld de,000feh
	call add_to_fields_3_and_5
	cp 018h
	ret nz
	jr next_route_step
step_7_diagonal_up:		; Until X 0x08
	ld de,0fefeh
	call add_to_fields_3_and_5
	cp 008h
	ret nz
next_route_step:		; Byte 1 goes up
	inc (ix+001h)
	ret
step_8_two_down:		; Until Y 0x78
	ld de,00200h		; Two down
	call add_to_fields_3_and_5	; Two down
	ld a,d			; Y 0x78
	cp 078h
	ret nz
	jr next_route_step
step_9_two_right:		; Until X 0xE0
	ld de,00002h
	call add_to_fields_3_and_5
	cp 0e0h
	ret nz
	jr next_route_step
step_10_towards_ship:		; Closes in on the ship's row; within 0x11, or outside the range 0x30-0x88, moves on to the next one
	ld a,(0e204h)		; 0xE204: the ship's row
	sub (ix+003h)
	push af
	add a,008h
	cp 011h			; Within 0x11 it is already on top of it
	jr c,L_8E11
	pop af
	ld de,0fe00h		; Two to the left...
	jr c,L_8E06
	ld de,00200h		; ...or two to the right
L_8E06:
	call add_to_fields_3_and_5	; Two to one side or the other
	ld a,d
	sub 030h
	cp 058h
	ret c
	jr next_route_step
L_8E11:
	pop af
	jr next_route_step
step_11_leaves:		; Two to the left until it passes X 0xF0, and the slot is freed
	ld de,000feh		; Two to the left
	call add_to_fields_3_and_5
	cp 0f0h
	ret c
	ld (ix+000h),000h
	ret
add_to_fields_3_and_5:		; Adds D to byte (IX+3) and E to (IX+5), and returns in D what was left in the first one.
	push ix			; Bytes 3 and 5: the X and the Y
	pop hl			; Three bytes further on: the X
	inc l			; D is added to it
	inc l
	inc l
	ld a,(hl)
	add a,d
	ld (hl),a
	ld d,a
	inc l
	inc l
	ld a,(hl)
	add a,e
	ld (hl),a
	ret
walk_the_eight:		; The eight cards of sixteen bytes from 0xE780
	ld hl,0e780h
	ld b,008h		; Eight cards
L_8E37:
	push bc
	push hl
	call draw_piece_blinking
	pop hl
	ld de,00010h		; Sixteen bytes: the next one
	add hl,de		; 0x10: the row below
	pop bc
	djnz L_8E37
	ret
draw_piece_blinking:		; Four by three characters, alternating every four frames between the two drawings
	ld a,(hl)
	or a
	ret z
	call card_position
	ld a,(0e003h)		; A bit of the counter: the two drawings alternate
	and 004h
	ld hl,08e5fh
	jr z,L_8E58
	ld hl,08e6bh
L_8E58:
	ex de,hl
	ld bc,00403h		; Four wide by three high
	jp 0490ch

; ----------------------------------------------------------------------
; DATA characters_8E5F: Twelve bytes read by 0x8E50.
characters_8E5F:
	defb 00h,0BAh,0BBh,00h
	defb 0BCh,0BDh,0BEh,0BFh
	defb 00h,0C0h,0C1h,00h

; ----------------------------------------------------------------------
; DATA characters_8E6B: Twelve bytes read by 0x8E55.
characters_8E6B:
	defb 00h,0BAh,0BBh,00h
	defb 0C2h,0C3h,0C4h,0C5h
	defb 00h,0C0h,0C1h,00h
set_up_five_pieces:		; Switches on 0xE1B0 and sets up the five slots at 0xEB00 with the positions at 0x8EBA; the pace comes from the difficulty
	ld hl,0e1b0h
	ld (hl),001h
	inc l
	inc l
	ld (hl),0f8h		; 0xF8 into 0xE1B2
	ld a,(0e111h)		; 0x5C minus four times the difficulty: the frames between steps
	add a,a			; The table at 0x8A93
	add a,a			; The table at 0x8A93
	sub 05ch
	neg
	inc l
	inc l
	ld (hl),a
	inc l
	ld (hl),a
	ld hl,08ebah
	ld de,0eb00h
	exx
	ld b,005h		; Five pieces
L_8E97:
	exx
	ld a,001h
	ld (de),a
	ld a,004h
	add a,e
	ld e,a
	ldi			; The X and the Y from the table
	inc e
	ldi
	ld a,008h
	add a,e
	ld e,a
	ld a,00ah		; Ten
	ld (de),a
	ld a,00ch
	add a,e
	ld e,a
	ld a,003h		; And three
	ld (de),a
	ld a,005h		; 0x20 bytes in total: the next slot
	add a,e
	ld e,a
	exx
	djnz L_8E97
	ret

; ----------------------------------------------------------------------
; DATA positions_of_the_five: Five (X, Y) pairs with which the five pieces at
;   0xEB00 start. Read by 0x8E8E.
positions_of_the_five:
	defb 4Ch,0F0h
	defb 54h,0F0h
	defb 5Eh,0E8h
	defb 68h,0F0h
	defb 70h,0F0h
run_five_pieces:		; Moves them with the scroll, gives each one a step and animates them
	ld a,(0e1b0h)		; Without 0xE1B0 there is nothing
	or a
	ret z
	call shift_group
	jp c,mark_boss_dead
	call walk_the_five
	call animate_the_five
	ret
shift_group:		; On the steps with a column, eight points to the left
	ld a,(0e100h)		; Only on the steps with a column
	or a
	ret z
	ld hl,0e1b2h
	ld a,(hl)
	sub 008h		; Eight points to the left
	ld (hl),a
	ret
walk_the_five:		; The five slots at 0xEB00, 0x20 bytes apart
	ld hl,0eb00h
	ld a,005h		; Five
	ld (0e1b6h),a
L_8EEB:
	push hl
	call step_of_one_of_five
	ld hl,0e1b6h
	dec (hl)
	pop hl
	ld de,00020h		; Thirty-two bytes: the next one
	add hl,de		; Five pieces
	jr nz,L_8EEB		; Five pieces
	ret
step_of_one_of_five:		; Moves it with the scroll and, if it is type 0x15, changes its drawing every four frames
	ld a,(hl)
	or a
	ret z
	ld a,(0e100h)
	or a
	call nz,shift_this_piece
	ld a,(hl)
	or a
	ret z
	cp 015h			; Only type 0x15 is animated
	ret nz
	inc l
	inc l
	inc (hl)
	ld a,(hl)
	cp 004h			; Four frames per drawing
	ret c
	ld (hl),000h
	ld a,00ah
	add a,l
	ld l,a
	inc (hl)
	ld a,(hl)
	cp 07ch			; Past drawing 0x7C, it starts again
	ret c
	ld a,l
	sub 00ch
	ld l,a
	ld (hl),000h
	ret
shift_this_piece:		; Eight points to the left; when it goes off the edge, the slot is freed
	ld a,006h		; Six bytes further on: the column
	add a,l
	ld l,a
	ld a,(hl)
	sub 008h
	ld (hl),a
	push af
	ld a,l			; And back to the start of the card
	sub 006h
	ld l,a
	pop af
	jr nc,L_8F36
	ld (hl),000h
L_8F36:
	ret
animate_the_five:		; Every so many frames (as many as 0xE1B5 says) gives a step to each of the five
	ld a,(0e1c0h)		; Not with the screen stopped
	and a
	ret nz
	ld hl,0e1b4h		; 0xE1B4: the frames remaining
	dec (hl)
	ret nz
	inc l
	ld a,(hl)
	dec l
	ld (hl),a
	ld hl,0eb00h
	ld a,005h		; Five pieces
	ld (0e1b6h),a
L_8F4D:
	push hl
	call drop_from_piece
	ld hl,0e1b6h
	dec (hl)
	pop hl
	ld de,00020h		; Thirty-two bytes: the next one
	add hl,de
	jr nz,L_8F4D
	ret
drop_from_piece:		; If the slot is on step 1 and below Y 0x30, looks for a free slot in 0xE500 and sets up a falling object there
	ld a,(hl)		; Only the ones on step 1
	dec a
	ret nz
	ld a,004h
	add a,l
	ld l,a
	ld e,(hl)		; Its X and its Y
	inc l
	inc l
	ld d,(hl)
	ld a,d
	cp 030h			; Not above Y 0x30
	ret c
	call free_slot_in_e500
	ret c
	ld (hl),001h		; The slot moves to step 1
	ld a,004h
	add a,l
	ld l,a
	ld (hl),e
	inc l
	inc l
	ld a,d
	sub 018h		; 0x18 above
	ld d,a			; 0x18 above
	ld (hl),d		; That is where it falls
	inc l
	ld (hl),000h
	inc l
	ld (hl),000h
	inc l
	ld (hl),000h
	inc l
	ld (hl),0fch		; Speed 0xFC
	inc l
	ld a,(0e1b6h)		; The last two have drawing 5, and the rest drawing 4
	cp 003h
	ld a,004h
	jr nc,L_8F95
	inc a
L_8F95:
	ld (hl),a
	ld a,010h		; Sixteen bytes further on, the alive mark
	add a,l
	ld l,a
	ld (hl),001h
	ret
free_slot_in_e500:		; Returns in HL the first of the ten slots at 0xE500 that is free; with carry, there is none
	ld hl,0e500h
	ld b,00ah		; Ten slots
L_8FA2:
	ld a,(hl)
	or a
	ret z
	ld a,020h		; Thirty-two bytes: the next one
	add a,l			; Thirty-two bytes: the next one
	ld l,a			; Thirty-two bytes
	jr nc,L_8FAC
	inc h
L_8FAC:
	djnz L_8FA2
	scf
	ret
note_cells_of_the_five:		; For each of the five, works out the map cell where it lands
	ld a,(0e1b0h)
	or a
	ret z
	ld hl,0eb00h
	ld a,005h		; Five
	ld (0e1b6h),a
L_8FBD:
	push hl
	call cell_of_one_of_five
	ld hl,0e1b6h
	dec (hl)
	pop hl
	ld de,00020h		; Thirty-two bytes: the next one
	add hl,de		; Thirty-two bytes: the next one
	jr nz,L_8FBD		; Thirty-two bytes
	ret
cell_of_one_of_five:		; The position becomes a map cell, and the third piece also stores the row below
	ld a,(hl)
	or a
	ret z
	ld a,004h
	add a,l
	ld l,a
	ld e,(hl)		; Its X and its Y
	inc l
	inc l
	ld d,(hl)
	push hl
	ex de,hl
	call 0571bh		; Bank 0 converts position into cell
	ex de,hl
	pop hl
	ld a,018h		; It is stored 0x18 bytes further on
	add a,l			; 0x18 bytes further on
	ld l,a			; The cell is stored there
	ld (hl),e
L_8FE4:
	inc l
	ld (hl),d
	ld a,l
	sub 00ch
	ld l,a
	ex de,hl
	ldi
	ldi
	ld a,(0e1b6h)		; The third one also carries the row below
	cp 003h
	ret nz
	ld bc,0001eh		; 0x1E: the row below in the map
	add hl,bc		; 0x1E: the row below
	ldi
	ldi
	ret
draw_the_five:		; Writes the characters of each of the five into the map
	ld a,(0e1b0h)
	or a
	ret z
	ld hl,0eb00h
	ld a,005h		; Five
	ld (0e1b6h),a
L_900B:
	push hl
	call draw_one_of_five
	ld hl,0e1b6h
	dec (hl)
	pop hl
	ld de,00020h		; Thirty-two bytes: the next one
	add hl,de
	jr nz,L_900B
	ret
draw_one_of_five:		; The ones on step 1 get a pair of characters from the table at 0x905C; the others, just one
	ld a,(hl)
	or a
	ret z
	ld b,a
	ld a,01eh		; The cell, 0x1E bytes further on
	add a,l
	ld l,a
	ld e,(hl)
	inc l
	ld d,(hl)
	dec b			; Only step 1 has two characters
	jr nz,draw_just_one
	ld a,(0e1b6h)
	add a,a			; Times four: two pairs per piece
	add a,a			; Times four: two pairs
	ld hl,0905ch
	add a,l
	ld l,a
	jr nc,L_9036
	inc h
L_9036:
	ldi
	ldi
	ld a,(0e1b6h)		; The third one also paints the row below
	cp 003h			; The third one carries the row below
	ret nz			; 0x1E: the row below
	ld a,01eh
	add a,e
	ld e,a
	jr nc,L_9047
	inc d
L_9047:
	ldi
	ldi
	ret
draw_just_one:		; One character, taken from the table that starts at 0x8FE4
	ld a,l			; 0x13 bytes back: the drawing
	sub 013h
	ld l,a
	ld a,(hl)
	ld hl,08FE4h		; The table that starts at 0x8FE4
	add a,l
	ld l,a
	jr nc,L_9059
	inc h
L_9059:
	ldi
	ret

; ----------------------------------------------------------------------
; DATA characters_905C: Twenty-four bytes read by 0x902E, in pairs.
characters_905C:
	defb 68h,69h,68h,69h
	defb 62h,63h,00h,00h
	defb 64h,65h,00h,00h
	defb 5Eh,5Fh,66h,67h
	defb 5Ch,5Dh,00h,00h
	defb 5Ah,5Bh,00h,00h
erase_the_five:		; Puts back into the map what was under each of the five pieces
	ld a,(0e1b0h)
	or a
	ret z
	ld hl,0eb00h
	ld a,005h		; Five
	ld (0e1b6h),a
L_9081:
	push hl
	call erase_one_of_five
	ld hl,0e1b6h
	dec (hl)
	pop hl
	ld de,00020h		; Thirty-two bytes: the next one
	add hl,de
	jr nz,L_9081
	ret
erase_one_of_five:		; Copies back the two saved characters, and the third one also those of the row below
	ld a,(hl)
	or a
	ret z
	ld a,01eh		; The cell, 0x1E bytes further on
	add a,l			; 0x1E bytes further on: the cell
	ld l,a			; Twelve bytes back
	ld e,(hl)
	inc l
	ld d,(hl)
	ld a,l
	sub 00ch
	ld l,a
	ldi
	ldi
	ld a,(0e1b6h)		; The third one also carries the row below
	cp 003h
	ret nz
	ld a,01eh		; 0x1E: the row below in the map
	add a,e			; 0x1E: the row below
	ld e,a			; 0x1E: the row below
	jr nc,L_90B0
	inc d
L_90B0:
	ldi
	ldi
	ret
release_enemies:		; Keeps releasing enemies while the script has entries for this distance
	call check_enemy_script
	jr z,release_enemies
	ret c
	ld hl,0e108h
	inc (hl)		; 0xE108: which script entry it is on
	jr release_enemies
release_enemies_on_column:		; The same, but only on the steps that bring in a new column
	ld a,(0e100h)		; Only on the steps with a column
	and a
	ret z
	ld a,0f8h		; 0xF8 into 0xEC04
	ld (0ec04h),a
L_90CB:
	call check_enemy_script
	jr z,L_90CB
	ret
check_enemy_script:		; Checks the script at 0x9262 and, when it is time, releases a type 1 enemy in the row and with the variant it says
	ld a,(0e108h)
	ld hl,09262h		; The script at 0x9262
	call script_entry
	ret nz
	ld hl,0e108h
	inc (hl)		; Move on to the next entry
	ld a,c
	ld (0e122h),a		; The whole byte is stored in 0xE122
	and 01fh		; The low five bits times eight: the column
	add a,a
	add a,a
	add a,a
	ld e,a
	ld a,(0ec04h)		; And the row, from 0xEC04
	ld d,a
	xor a
	bit 6,c			; Bits 6 and 7: the variant
	jr z,L_90F8
	inc a
	bit 7,c
	jr z,L_90F8
	inc a
L_90F8:
	ld c,a
	ld a,001h		; Type 1
	call 06a72h
	xor a
	ret
script_entry:		; Takes the stage's list from the table at HL and compares the distance travelled with the current entry
	push af
	ld a,(0e061h)		; The list for this stage
	call 047aeh
	pop af
	ld c,a
	add a,a			; Times three: three bytes per entry
	add a,c
	call 04062h
	ex de,hl
	ld e,(hl)		; The entry's distance...
	inc hl
	ld d,(hl)
	inc hl
	ld c,(hl)		; ...and the data byte
	ld hl,(0e063h)
	rst 20h			; DCOMPR: against the distance travelled
	ret
aim_cannon:		; Measures the angle to the ship and uses it to choose the cannon's drawing, taken from the table at 0x9205 according to the stage
	call move_with_scroll_eight
	ret c
	ld e,(ix+004h)		; The enemy's position
	ld d,(ix+006h)
	call 066d5h		; Bank 1 measures the angle
	ld a,(0ec18h)
	cp 080h			; Above 0x80, the angle is mirrored
	jr c,L_912F
	neg
L_912F:
	ld bc,00505h
L_9132:
	sub 015h		; Five ranges of 0x15
	jr c,L_9139		; Five ranges of 0x15
	dec c			; Five ranges
	djnz L_9132
L_9139:
	ld a,(ix+017h)
	add a,a
	add a,a
	ld e,a
	add a,a
	add a,e
	ld hl,09205h		; The table at 0x9205
	call 0405dh
	ld a,(0e061h)		; And within it, the stage's row
	dec a			; And within, the stage's row
	call 0405dh
	ld a,(hl)
	add a,c
	ld (ix+00ch),a
	ld a,(0ec18h)
	bit 1,(ix+017h)
	jr nz,L_9163
	sub 010h		; Bit 1 of byte 23 chooses the firing arc
	cp 060h
	ret c
	jr this_enemy_fires
L_9163:
	sub 090h
	cp 060h
	ret c
this_enemy_fires:		; With the ship inside its arc and no other shot under way, fires one and recalculates the wait
	dec (ix+010h)		; 0xE110: the frames left before firing
	ret nz
	ld hl,0e112h		; 0xE112: if a shot is already coming out, it waits a frame
	ld a,(hl)
	and a
	jr z,L_9178
	ld (ix+010h),001h
	ret
L_9178:
	ld e,(ix+004h)		; The enemy's position, and bank 1 sets up the shot
	ld d,(ix+006h)
	call 06613h
wait_until_next_shot:		; The wait comes from the ramp at 0x91C5, plus the difficulty and the loop, with a floor of 0x0C frames
	ld hl,091c5h
	ld a,(0e066h)		; On the first loop the difficulty is capped at 2
	dec a
	ld a,(0e111h)
	jr nz,L_9193
	cp 002h
	jr c,L_9193
	ld a,002h
L_9193:
	add a,a			; Times four: four values per step
	add a,a
	call 0405dh
	ld a,(ix+018h)		; Byte 24 rotates among the four
	inc (ix+018h)
	and 003h
	call 0405dh
	ld a,(0e200h)		; With the shield at 3, four frames fewer
	cp 003h
	ld a,(hl)
	jr nz,L_91AD
	sub 004h
L_91AD:
	ld c,a
	ld a,(0e066h)		; The loop divided by four also subtracts
	srl a
	srl a
	ld b,a
	ld a,c
	sub b
	jr nc,L_91BB
	xor a
L_91BB:
	cp 00ch			; Never fewer than twelve frames
	jr nc,L_91C1
	ld a,00ch
L_91C1:
	ld (ix+010h),a
	ret

; ----------------------------------------------------------------------
; DATA wait_between_shots: Three steps of four values: the frames an enemy
;   waits between one shot and the next, according to the difficulty and where
;   on the wheel it is. Read by 0x9181, which also subtracts the loop from
;   them and gives them a floor of twelve.
wait_between_shots:
	defb 60h,60h,60h,0C0h
	defb 50h,50h,50h,0A0h
	defb 40h,40h,40h,80h

; ----------------------------------------------------------------------
; DATA table_91D1: Fifty-two bytes that p00:48CB loads into BC with `ld
;   bc,0x91D1`. Note: with the default layout bank 2 is at 0x8000, but 0x48CB
;   runs with the 4/5/6 layout, so what it really reads is bank 5. It stays
;   here as data of this bank because nothing else points to it.
table_91D1:
	defb 30h,30h,30h,60h
	defb 28h,28h,28h,50h
	defb 26h,26h,26h,4Ch
	defb 24h,24h,24h,48h
	defb 22h,22h,22h,44h
	defb 20h,20h,20h,40h
	defb 1Eh,1Eh,1Eh,3Ch
	defb 1Ch,1Ch,1Ch,38h
	defb 1Ah,1Ah,1Ah,34h
	defb 18h,18h,18h,30h
	defb 16h,16h,16h,2Ch
	defb 14h,14h,14h,28h
	defb 12h,12h,12h,24h

; ----------------------------------------------------------------------
; DATA cannon_drawings: Four rows (one per stage) of twelve drawings: the one
;   the cannon shows depending on the angle range the ship is in. Read by
;   0x9141.
cannon_drawings:
	defb 09h,23h,0Fh,00h,3Fh,00h,09h,09h,23h,23h,23h,23h
	defb 0Fh,09h,00h,0Fh,3Fh,00h,0Fh,0Fh,09h,09h,09h,09h
	defb 00h,15h,15h,00h,39h,00h,1Bh,2Dh,15h,15h,15h,15h
	defb 1Bh,1Bh,1Bh,1Bh,39h,00h,1Bh,1Bh,1Bh,1Bh,1Bh,1Bh
fire_without_aiming:		; When the count reaches zero fires the shot and works out the speed with the bank 1 routine
	dec (ix+010h)		; 0xE110: the frames remaining
	ret nz
L_9239:
	ld hl,0e112h		; 0xE112: if one is already coming out, it waits
	ld a,(hl)
	and a
	jr z,L_9245
	ld (ix+010h),001h
	ret
L_9245:
	ld e,(ix+004h)		; The position, and bank 1 sets it up
	ld d,(ix+006h)
	call 06613h
	jp 06b84h
move_with_scroll_eight:		; On the steps with a new column it moves eight points to the left; when it goes off the edge, the slot is freed and it returns with carry
	ld a,(0e100h)		; Only on the steps with a column
	and a
	ret z
	ld a,(ix+006h)
	sub 008h		; Eight points
	ld (ix+006h),a
	ret nc
	call 05fa5h		; And when it goes past, the slot is switched off
	scf
	ret

; ----------------------------------------------------------------------
; DATA table_9264: Words that 0x90D4 indexes with 0x47AE (0x927C, 0x92B4,
;   0x933A, 0x9366, ...) and, after them, what they point to.
table_9264:
	defw 927Ch,92B4h
	defw 933Ah,9366h
	defw 9389h,93B5h
	defw 93B7h,93E6h
	defw 9445h,9492h
	defw 94D9h,94F9h
	defw 008Eh,9021h
	defw 2100h,0092h
	defw 0AE21h,1200h
	defw 00B0h,0C012h
	defw 2100h,00C2h
	defw 0D221h,1200h
	defw 00D4h,0412h
	defw 5201h,0106h
	defw 0A52h,2101h
	defw 010Ch,2221h
	defw 1201h,0124h
	defw 3A12h,2101h
	defw 013Ch,5821h
	defw 5201h,0FFFFh
	defw 0084h,8506h
	defw 2A00h,0086h
	defw 8602h,2F00h
	defw 0089h,8C01h
	defw 0200h,008Ch
	defw 8D2Fh,2A00h	; -> DATA_piece_card_3 0x2a00
	defw 008Eh,0A106h
	defw 1300h,00A3h
	defw 0A413h,2300h
	defw 00ACh,0AE2Eh
	defw 4A00h,00AFh
	defw 0B105h,0100h
	defw 00B3h,0B605h
	defw 4A00h,00C0h
	defw 0C227h,4300h
	defw 00C8h,0C903h
	defw 1100h,00D2h
	defw 0D205h,1100h
	defw 00D4h,0EC05h
	defw 0C600h,00F2h
	defw 0F243h,2D00h
	defw 00FCh,0FE6Eh
	defw 0300h,0104h
	defw 0506h,2A01h
	defw 0106h,0602h
	defw 2F01h,010Eh
	defw 1A06h,1301h
	defw 011Eh,2123h
	defw 1301h,0124h
	defw 2C23h,6E01h
	defw 012Eh,2F4Ah
	defw 4501h,0131h
	defw 3341h,4501h
	defw 0FFFFh,0084h
	defw 946Ah,6E00h
	defw 00A0h,0A24Bh
	defw 4B00h,00C6h
	defw 0E253h,5300h
	defw 00E6h,0FE45h
	defw 6900h,0114h
	defw 1445h,6801h
	defw 0142h,4653h
	defw 4501h,015Ch
	defw 7245h,4A01h
	defw 0FFFFh,0096h
	defw 9812h,1200h
	defw 009Ah,0A212h
	defw 2100h,00A4h
	defw 0B621h,1200h
	defw 00B8h,0D612h
	defw 2100h,00D8h
	defw 0FA21h,1200h
	defw 00FEh,0FF12h
	defw 0A8FFh,5200h
	defw 00AEh,0CE61h
	defw 6100h,00D4h
	defw 0E452h,6100h
	defw 00E6h,0EA61h
	defw 5200h,00F4h
	defw 0F652h,6100h
	defw 00FCh,0A52h
	defw 5201h,011Ch
	defw 5261h,5201h
	defw 0154h,0FF52h
	defw 0FFFFh,96FFh
	defw 1000h,0098h
	defw 0A010h,2400h
	defw 00B6h,0B810h
	defw 1000h,00F7h
	defw 0F924h,2400h
	defw 014Dh,4E24h
	defw 5001h,014Fh
	defw 5024h,5001h
	defw 015Ch,5C68h
	defw 4C01h,015Eh
	defw 5E68h,4C01h
	defw 0FFFFh,0041h
	defw 4323h,2300h
	defw 0047h,490Fh
	defw 0F00h,0054h
	defw 5665h,2500h
	defw 005Bh,5F11h
	defw 1100h,0075h
	defw 770Fh,0F00h
	defw 007Ch,7E23h
	defw 2300h,009Fh
	defw 9F23h,5100h
	defw 00B5h,0B70Fh
	defw 0F00h,00BCh
	defw 0BE23h,2300h
	defw 00DBh,0DD4Dh
	defw 0E300h,00F5h
	defw 0F70Fh,0F00h
	defw 00FDh,0FF23h
	defw 6300h,010Eh
	defw 0E6Bh,4D01h
	defw 0110h,106Bh
	defw 4D01h,0141h
	defw 5023h,6301h
	defw 0158h,0FF23h
	defw 23FFh,1300h
	defw 0024h,2662h
	defw 6200h,0029h
	defw 2C6Ah,6200h
	defw 002Dh,2F4Dh
	defw 4600h,002Fh
	defw 314Dh,6900h
	defw 0038h,396Eh
	defw 4500h,003Bh
	defw 5D45h,3000h
	defw 0085h,8D31h
	defw 3100h,008Fh
	defw 9631h,1300h
	defw 00AFh,0D811h
	defw 4E00h,00DDh
	defw 0E245h,4500h
	defw 00F9h,0FB13h
	defw 2100h,00FBh
	defw 0FD13h,2100h
	defw 0FFFFh,0024h
	defw 2562h,0F00h
	defw 0025h,2632h
	defw 6200h,002Ah
	defw 2F10h,6100h
	defw 0031h,3561h
	defw 1000h,0039h
	defw 390Fh,3200h
	defw 003Bh,4362h
	defw 3000h,0050h
	defw 5365h,4D00h
	defw 0059h,7130h
	defw 3100h,0073h
	defw 7531h,1300h
	defw 0085h,854Dh
	defw 1300h,008Fh
	defw 944Dh,1200h
	defw 00A7h,0FF31h
	defw 2AFFh,2600h
	defw 0066h,682Eh
	defw 2E00h,0088h
	defw 9413h,2E00h
	defw 0098h,0AB26h
	defw 2D00h,00AFh
	defw 0B105h,3100h
	defw 00BAh,0FF06h
	defw 09FFh,4301h
	defw 010Bh,0D6Eh
	defw 4201h,0111h
	defw 1342h,6E01h
	defw 0115h,7D43h
	defw 1301h,0FFFFh
zero_speed:		; The object's two speeds, zeroed
	xor a
	ld d,a
	ld e,a
	call 06cc6h		; Both speeds to zero
	jp 06cbfh
set_negated_acceleration:		; Two's complement of the vertical acceleration, and store it
	ld e,(ix+017h)
	ld d,(ix+018h)
	call 06729h
set_vertical_acceleration:		; Bytes 23 and 24
	ld (ix+017h),e
	ld (ix+018h),d
	ret

; ----------------------------------------------------------------------
; DATA dead_fragment: Seven bytes that are `ld (ix+0x19),e / ld (ix+0x1A),d /
;   ret`. Nothing reaches them: neither a jump nor a table points to 0x9529.
dead_fragment:
	defb 0DDh,73h,19h,0DDh,72h,1Ah,0C9h
set_horizontal_acceleration:		; Bytes 25 and 26; if it comes in negative, it is flipped
	ld a,d
	or a
	call m,06729h
L_9535:
	ld (ix+019h),e
	ld (ix+01ah),d
	ret
add_vertical_acceleration:		; Bytes 23 and 24 are added to the speed in bytes 7 and 8
	ld l,(ix+007h)		; The vertical speed...
	ld h,(ix+008h)
	ld e,(ix+017h)		; ...plus its acceleration
	ld d,(ix+018h)
	add hl,de
	ld (ix+007h),l
	ld (ix+008h),h
	ret
add_horizontal_acceleration:		; And the same with bytes 25 and 26 on 9 and 10
	ld l,(ix+009h)		; The horizontal speed...
	ld h,(ix+00ah)
	ld e,(ix+019h)		; ...plus its acceleration
	ld d,(ix+01ah)
	add hl,de
	ld (ix+009h),l
	ld (ix+00ah),h
	ret
compare_speed_and_acceleration:		; The vertical speed, in absolute value, against the horizontal acceleration
	ld e,(ix+007h)		; The vertical speed, in absolute value
	ld d,(ix+008h)
	ld a,d
	or a
	call m,06729h
	ld l,(ix+019h)		; Against the horizontal acceleration
	ld h,(ix+01ah)
	rst 20h
	ret
set_horiz_speed_from_acceleration:
	ld e,(ix+019h)
	ld d,(ix+01ah)
	jp 06cbfh
negate_horizontal_speed:
	ld e,(ix+009h)		; Bytes 9 and 10, with the sign flipped
	ld d,(ix+00ah)
	call 06729h
	ld (ix+009h),e
	ld (ix+00ah),d
	ret
negate_vertical_speed:
	ld e,(ix+007h)		; Bytes 7 and 8, with the sign flipped
	ld d,(ix+008h)		; DCOMPR: against the distance travelled
	call 06729h
	ld (ix+007h),e
	ld (ix+008h),d
	ret
one_in_thirty_two:		; The low five bits of the frame counter
	ld a,(0e003h)
	and 01fh
	ret
time_to_move:		; Every 0x20 frames decrements byte 28; on reaching zero, returns with carry
	call one_in_thirty_two	; One in every 0x20 frames
	jr nz,reached_the_end
	dec (ix+01ch)		; Byte 28 goes down
	jr nz,reached_the_end
	scf
	ret
reached_the_end:		; Compares the distance travelled with the end of the range; on stage 1 with a margin of 0x10
	ld a,(0e061h)
	dec a			; Stage 1 has a margin of 0x10
	jr nz,L_95C7
	ld hl,(0e103h)
	ld de,00010h
	or a
	sbc hl,de
	ld de,(0e063h)
	rst 20h			; DCOMPR: against the distance travelled
	ret
L_95C7:
	ld hl,(0e103h)
	dec hl
	ld de,(0e063h)
	rst 20h
	ret
animate_round_and_round:		; Every so many frames (mask in B) advances the drawing round and round up to C and takes it from the table at HL
	ld a,(0e003h)		; The mask in B: every how many frames
	and b
	ret nz
	ld a,(ix+01dh)		; Byte 29: which drawing it is on
	inc a
	cp c			; On reaching C, start again
	jr c,L_95DE		; On reaching C, start again
	xor a			; The drawing is noted down
L_95DE:
	ld (ix+01dh),a
	add a,l
	ld l,a
	jr nc,L_95E6
	inc h
L_95E6:
	ld a,(hl)
	ld (ix+00ch),a
	ret

	end

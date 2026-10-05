; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - options.asm
; ============================================================================

	include "variables.inc"

	public animate_options,check_fire,draw_shots,erase_shots,run_nine_shots,run_options
	public set_up_one_option
	extrn add_a_to_hl,cell_to_ram_address,check_if_sound,collides_at_this_cell,collides_with_map,collides_with_map_2
	extrn dispatcher,is_special_cell

; ----------------------------------------------------------------------
; THE OPTION'S QUEUE IS FILLED USING THE STACK
; The options follow the ship with a delay: its last sixteen positions
; have to be kept. When they are created, that queue is filled in one go
; with the current position, and to do that the cartridge does something
; you do not see every day: it points the STACK POINTER at the queue
; (`ld sp,hl`), does eight `push bc` in a row (sixteen bytes in sixteen
; instructions) and restores SP, all with interrupts disabled so that
; nobody uses the stack in the meantime.
; ----------------------------------------------------------------------
set_up_one_option:		; Copies the ship's position into the option's card and fills its position queue with `push`
	ld a,(OPTION_COUNT)	; How many options there are
	dec a
	ld hl,SHIP_ROW		; With one, the position comes from the ship; with two, from the first option
	ld de,OPTIONS
	jr z,L_9C0D
	ld hl,OPTIONS+4
	ld de,OPTIONS+OPTION_SIZE
L_9C0D:
	ld a,001h
	ld (de),a
	ld c,(hl)		; The X and the Y
	inc l			; The X and the Y
	inc l			; The Y
	ld b,(hl)
	ld a,004h
	add a,e
	ld e,a
	ld a,c
	ld (de),a
	inc e
	inc e
	ld a,b
	ld (de),a
	ld a,005h
	add a,e
	ld e,a
	ex de,hl
	ld (hl),000h		; Pattern 0x44 and colour 0x0A
	inc l			; Pattern 0x44
	ld (hl),044h
	inc l
	ld (hl),00ah
	ld a,013h
	add a,l
	ld l,a
	ld iy,00000h		; The stack pointer is saved...
	add iy,sp
	di
	ld sp,hl		; ...pointed at the queue...
	ld a,008h
L_9C39:
	push bc			; ...eight `push`: sixteen bytes in one go...
	dec a
	jr nz,L_9C39
	ld sp,iy		; ...and restored
	ei
	ret
run_options:		; Every two frames pushes the ship's position into the queue, and the options come out at the other end
	ld a,(SCROLL_MODE)	; Not with the screen stopped
	and a
	ret nz
	ld a,(SHIP)
	dec a
	ret m
	ld a,(OPTION_COUNT)	; Nor without options
	or a			; Not without options
	ret z
	exx
	ld b,a
	exx
	call animate_options
	exx
	ld a,(CONTROLLER)	; With the joystick still or on an exact diagonal, the queue does not advance
	and 00fh		; The four direction bits
	ret z			; With the joystick still, the queue does not advance
	cp 003h
	ret z
	cp 00ch
	ret z
	cp 00fh
	ret z
	dec b			; With two options, both
	jr z,shift_one_queue	; Nor on an exact diagonal
	call shift_one_queue
	ld hl,OPTIONS+OPTION_SIZE+10h
	ld de,OPTIONS+OPTION_SIZE+4
	jr L_9C7A
shift_one_queue:		; Pushes the new position in at the front and shifts the sixteen bytes of the queue
	ld hl,OPTIONS+10h
	ld de,OPTIONS+4
L_9C7A:
	push hl			; The new position, at the front
	ldi
	inc e
	ldi
	pop de
	ld bc,0000eh		; Fourteen bytes: the rest of the queue
	ldir
	ld a,l			; And the one from sixteen frames ago, at the end
	sub 03ch		; 0x3C bytes back
	ld l,a
	ldi
	inc l
	ldi
	ret
animate_options:		; Every two frames advances the options' drawing, four round and round, from the table at option_drawings
	ld b,a
	ld hl,OPTION_ANIM_DELAY	; One in every two frames
	inc (hl)
	ld a,(hl)
	cp 002h
	ret c
	ld (hl),000h
	inc l
	inc (hl)		; OPTION_FRAME: which drawing they are on
	dec b			; With two options, both
	jr z,L_9CA6
	ld de,OPTIONS+OPTION_SIZE+0Ch
	call L_9CA9
L_9CA6:
	ld de,OPTIONS+0Ch
L_9CA9:
	ld hl,option_drawings
	ld a,(OPTION_FRAME)
	and 003h		; Four drawings round and round
	add a,a
	call add_a_to_hl
	ldi
	ldi
	ret

; ----------------------------------------------------------------------
; DATA option_drawings: Four (pattern, colour) pairs the option blinks with.
;   Read by L_9CA9.
option_drawings:
	defb 44h,0Ah
	defb 44h,09h
	defb 48h,08h
	defb 48h,06h
release_fire_button:		; FIRE_HELD to zero: the button has been released
	ld (hl),000h
	ret
check_fire:		; With the button just pressed, or held for fifteen frames, the ship and its two options fire
	ld a,(SCROLL_MODE)	; Not with the screen stopped
	and a
	ret nz
	ld a,(SHIP)		; Nor with the ship dead
	dec a
	ret m
	ld hl,FIRE_HELD
	ld a,(CONTROLLER_NEW)	; Bit 4 of what was just pressed: fire
	and 010h
	jr nz,all_three_fire
	ld a,(CONTROLLER)	; And bit 4 of the joystick: held
	and 010h
	jr z,release_fire_button
	inc (hl)
	ld a,(hl)
	cp 00fh			; Fifteen frames in a row and it fires by itself
	ret c
all_three_fire:		; The ship and its two options, 0x20 bytes apart
	call release_fire_button
	ld iy,SHIP		; The ship
	ld de,00300h		; Three cards
L_9CEF:
	exx			; The card in turn
	ld a,(iy+000h)
	or a
	call nz,fire_this_card
	ld bc,00020h		; Thirty-two bytes: the next one
	add iy,bc
	exx
	ld a,e			; Thirty-two bytes: the next one
	add a,020h
	ld e,a
	dec d
	jr nz,L_9CEF
	ret
fire_this_card:		; Four weapons, one per byte: the usual shot, the double, the laser and the missile
	ld ix,SHIP
	ld a,(ix+00ch)		; Byte 12: the normal shot
	or a
	call nz,L_9D26
	ld a,(ix+00dh)		; 13: the double
	or a
	call nz,fire_double
	ld a,(ix+00eh)		; 14: the laser
	or a
	call nz,fire_laser
	ld a,(ix+00fh)		; And 15: the missile
	or a
	call nz,fire_missile
	ret
L_9D26:
	dec a
	jr z,fire_normal
	ld hl,SHOTS		; The nine shot slots
	call free_slot_in_this_table	; The nine slots
	jr z,L_9D59		; Not without a free slot
	ld hl,SHOTS+SHOT_SIZE
	call free_slot_in_this_table
	jr z,L_9D59
	ret
flag_no_room:		; DOUBLE_NO_ROOM to one: there is no free slot left for the double shot
	ld a,001h
	jr L_9D40
flag_room:		; DOUBLE_NO_ROOM to zero
	ld a,000h
L_9D40:
	ld (DOUBLE_NO_ROOM),a
	ret
fire_normal:		; Looks for a free slot among the nine and sets up the usual shot, eight to the right and 0x10 below
	ld hl,SHOTS		; The nine slots
	call free_slot_in_this_table
	jr nz,flag_no_room
	push hl
	ld bc,00010h		; Sixteen bytes: the one next to it
	add hl,bc		; Sixteen bytes: the one next to it
	ld a,(hl)		; And the one next to it free as well
	or a
	pop hl
	jr nz,flag_no_room
	call flag_room
L_9D59:
	ld (hl),001h
	inc l
	ld de,00810h		; Eight to the right and 0x10 further down
	call set_shot_position
	and 0f8h		; The Y, aligned to eight
	ld (hl),a
	ld d,0f8h		; Speed 0xF8: upwards
	call set_aligned_x
	ld a,001h		; Sound 1
	jp check_if_sound
fire_double:		; The double shot, which goes upwards with speed 0x18
	ld a,(DOUBLE_NO_ROOM)	; Not without a free slot for it
	or a			; With no free slot, there is no shot
	ret nz			; Not without a free slot
	ld hl,SHOTS+SHOT_SIZE
	call free_slot_in_this_table
	ret nz
	ld (hl),002h
	inc l
	ld de,00008h
	call set_shot_position
	inc l
	ld (hl),018h		; Speed 0x18 and colour 0x0F
	inc l
	ld (hl),00fh
	ld a,002h		; Sound 2
	jp check_if_sound
fire_laser:		; Sets up the laser, which stays attached to the ship: stores in its card the pointer to whoever fires it
	ld hl,SHOTS
	call free_slot_in_this_table
	ret nz
	ld (hl),003h		; Type 3: the laser
	inc l
	ld (hl),000h
	ld de,00810h		; Eight to the right and 0x10 further down
	call set_shot_position
	and 0f8h
	ld (hl),a
	ld d,0fch		; Speed 0xFC
	call set_aligned_x
	inc l
	inc l
	push iy			; Whose laser it is gets stored
	pop bc			; Whose it is gets stored
	ld (hl),c		; The pointer is stored
	inc l
	ld (hl),b
	inc l
	inc l
	inc l
	ld (hl),000h
	inc l
	exx
	ld c,(ix+00eh)
	ld b,000h
	ld hl,laser_max_lengths-1
	add hl,bc
	ld a,(hl)
	exx
	ld (hl),a
	inc l
	inc l
	inc l
	ld (hl),000h
	ld a,003h		; Sound 3
	jp check_if_sound

; ----------------------------------------------------------------------
; DATA laser_max_lengths (part): Three bytes read by 0x9DBD with `ld hl,0x9DCD`.
laser_max_lengths:
	defb 08h,0Fh
fire_missile:		; The missile goes to the table at 0x2C0, with one slot for every two cards
	ld hl,MISSILES		; The missile table
	exx
	ld a,e
	exx
	sra a			; One slot for every two cards
	add a,l			; With the first byte at zero, there is a free slot
	ld l,a
	jr nc,L_9DDD
	inc h
L_9DDD:
	ld a,(hl)
	or a
	ret nz
	ld (hl),004h		; Type 4: the missile
	inc l
	ld de,00808h
	call set_shot_position
	inc l
	ld (hl),020h		; Pattern 0x20 and colour 0x0A
	inc l
	ld (hl),00ah
	ret
free_slot_in_this_table:		; Returns the first free slot of the table HL brings, jumping by whatever stride the card needs
	exx			; The stride that applies
	ld a,e
	exx
	add a,l
	ld l,a
	jr nc,L_9DF8
	inc h
L_9DF8:
	ld a,(hl)		; With the first byte at zero, the slot is free
	or a
	ret
set_shot_position:		; Gives the shot the position of whoever fires it plus the offset in DE
	ld a,(iy+004h)		; The shooter's X
	add a,d
	inc l
	inc l
	ld (hl),a
	ld a,(iy+006h)		; And its Y
	add a,e
	inc l
	inc l
	ld (hl),a
	ret
set_aligned_x:		; The shooter's X, aligned to four, plus D
	ld a,(iy+004h)		; The shooter's X
	rra
	and 003h		; Aligned to four
	add a,d
	inc l
	ld (hl),a
	ret
run_nine_shots:		; The nine slots at SHOTS, each through its type: four exits
	ld ix,SHOTS
	exx
	ld b,009h		; Nine slots
L_9E1B:
	exx
	ld a,(ix+000h)
	dec a
	jp m,next_shot
	ld de,next_shot		; next_shot is pushed: on return, execution carries on there
	push de
	push ix
	call dispatcher

; ----------------------------------------------------------------------
; DATA shot_runners_per_type: Four words glued right behind the `call dispatcher`
;   at 0x9E29.
shot_runners_per_type:
	defw run_normal_shot	; 0
	defw run_double_shot	; 1
	defw run_laser		; 2
	defw run_missile	; 3
next_shot:		; Sixteen bytes and back to the loop over the nine slots
	ld de,00010h		; Sixteen bytes: the next slot
	add ix,de		; The next slot
	exx
	djnz L_9E1B
	ret
run_normal_shot:		; Twelve points to the right per frame; when it goes off the screen, it switches off
	pop hl
	ld a,004h
	add a,l
	ld l,a
	ld de,00c00h		; 0x0C00: twelve points per frame
L_9E45:
	ld a,(hl)		; Twelve points to the right
	add a,e
	ld (hl),a
	inc l
	ld a,(hl)
	adc a,d
	jr c,switch_off_shot	; When it goes off, it switches off
	ld (hl),a
	ret
run_double_shot:		; Six points up and twelve to the right
	pop hl			; The return address is popped: the shot does not come back through here
	inc l
	inc l
	ld de,00600h		; 0x0600 upwards
	ld a,(hl)		; Y minus six
	sub e			; Y minus six
	ld (hl),a		; And it advances twelve
	inc l
	ld a,(hl)
	sbc a,d
	jr c,switch_off_shot
	ld (hl),a
	inc l
	jr L_9E45
switch_off_shot:		; The slot is left free
	ld (ix+000h),000h
	ret
run_laser:		; Sticks to whoever fires it, keeps growing and is cut off on reaching the map
	pop hl
	inc l
	ld a,(hl)
	dec a
	jr z,laser_advances
	jp p,laser_shrinks
	ld c,(ix+008h)		; Bytes 8 and 9: whose laser it is
	ld b,(ix+009h)
	push bc
	pop iy
	ld de,00810h		; Eight to the right and 0x10 further down
	call set_shot_position
	and 0f8h
	ld (hl),a
	ld d,0fch		; Speed 0xFC
	call set_aligned_x
	ld a,006h
	add a,l
	ld l,a
	ld b,004h		; Four growth steps
L_9E8C:
	inc (hl)		; The length goes up...
	inc l
	dec (hl)		; ...and the count goes down
	jr z,laser_full_length
	dec l
	djnz L_9E8C
	jr trim_laser
laser_full_length:		; Byte 1 goes up: it moves on to the next phase
	inc (ix+001h)
	jr trim_laser
laser_advances:		; Moves 0x20 points and, if the length reaches zero, switches off
	call move_laser_0x20	; 0x20 points to the right
	jr c,switch_off_shot
	call trim_laser
	ld a,(ix+00ch)		; And if the length reaches zero, it is over
	or a
	ret nz
	jr switch_off_shot
laser_shrinks:		; Moves and takes five off the length; when it runs out, it goes away
	call move_laser_0x20	; 0x20 points to the right
	jr c,switch_off_shot
	ld a,(ix+00ch)		; Five less length
	sub 005h
	jr c,switch_off_shot
	inc a
	ld (ix+00ch),a
	ret
move_laser_0x20:		; 0x20 points to the right
	ld a,004h		; Four bytes further on: the X
	add a,l
	ld l,a
	ld a,020h		; 0x20 points
	add a,(hl)
	ld (hl),a
	ret
trim_laser:		; If the laser goes off the top of the screen, its length is shortened by exactly the excess
	ld a,(ix+00ch)		; The length times eight
	add a,a			; The length times eight
	add a,a
	add a,a
	neg
	sub (ix+005h)
	ret nc
	neg
	rra			; What sticks out, in cells
	rra			; What sticks out, in cells
	rra			; In absolute value
	and 01fh
	sub (ix+00ch)
	neg
	ld (ix+00ch),a
	ret
run_missile:		; Hugs the ground: looks at the map ahead and below, and goes up or down depending on what it finds
	call blink_missile
	pop hl
	call missile_position
	ld a,l
	add a,008h		; Eight to the right: what is ahead of it
	ld l,a
	call collides_with_map
	jr nc,lower_missile
	call missile_position
	ld a,h			; And eight below
	add a,008h		; Eight below
	ld h,a			; Eight to the right
	ld a,l
	add a,008h
	ld l,a
	call collides_with_map
	jr nc,raise_missile
	call missile_position
	ld a,h
	add a,008h
	ld h,a
	call collides_with_map	; If it also collides there, the missile crashes
	jp c,switch_off_shot
	jr walk_missile
raise_missile:		; The ground rises: the missile climbs the step
	call L_9F24
	jr walk_missile
lower_missile:		; There is no ground ahead: the missile falls, faster if it has the double upgrade
	ld a,(SHIP_MISSILE)	; At two: the upgraded missile falls faster
	cp 002h
	ld de,00100h
	jr c,L_9F21
	ld de,00180h
L_9F21:
	call advance_missile
L_9F24:
	ld (ix+006h),020h	; Drawing 0x20: the missile falling
	ld a,(SHIP_MISSILE)
	cp 002h
	ld de,00400h
	jr c,L_9F35
	ld de,00600h
L_9F35:
	ld a,(ix+002h)		; And it advances at the same time
	add a,e			; And it advances at the same time
	ld (ix+002h),a		; X goes up
	ld a,(ix+003h)
	adc a,d
	cp 0a0h
	jp nc,switch_off_shot
	ld (ix+003h),a
	ret
walk_missile:		; Hugs the ground, with drawing 0x1C
	ld (ix+006h),01ch	; Drawing 0x1C: the missile rolling
	ld a,(SHIP_MISSILE)
	cp 002h
	ld de,00400h
	jr c,advance_missile
	ld de,00600h
advance_missile:		; Adds DE to its X; if it goes off the screen, it switches off
	ld a,(ix+004h)		; Adds DE to the X
	add a,e
	ld (ix+004h),a
	ld a,(ix+005h)
	adc a,d
	jp c,switch_off_shot	; When it goes off, it switches off
	ld (ix+005h),a
	ret
missile_position:		; The missile's X and Y, in HL
	ld h,(ix+005h)
	ld l,(ix+003h)
	ret
blink_missile:		; The colour alternates between 0x0A and 0x0B every two frames
	ld hl,FRAME_COUNT	; A bit of the counter
	ld a,00ah		; 0x0A or 0x0B depending on the frame
	bit 1,(hl)		; A bit of the counter
	jr z,L_9F7D
	inc a
L_9F7D:
	ld (ix+007h),a
	ret
draw_shots:		; SHOTS_PAINT_PASS to one: the shots are painted
	ld a,001h
	jr L_9F86
erase_shots:		; SHOTS_PAINT_PASS to zero: they are erased
	xor a
L_9F86:
	ld (SHOTS_PAINT_PASS),a
	ld ix,SHOTS
	ld b,009h		; Nine slots
	push bc
	ld bc,table_9FA4	; table_9FA4 is pushed: on return, execution carries on there
	push bc
	ld a,(ix+000h)
	call dispatcher

; ----------------------------------------------------------------------
; DATA shot_map_checks_per_type: Five words glued right behind the `call dispatcher`
;   at 0x9F97.
shot_map_checks_per_type:
	defw missile_skips_collision	; 0
	defw check_shot_collision	; 1
	defw check_shot_collision	; 2
	defw check_laser_against_map	; 3
	defw check_shot_collision	; 4

; ----------------------------------------------------------------------
; DATA table_9FA4: Eight bytes that 0x9F90 loads into BC with `ld bc,0x9FA4`.
table_9FA4:
	defb 01h,10h,00h,0DDh,09h,0C1h,10h,0E3h
missile_skips_collision:		; The missile is not checked against the map: it is already stuck to it
	ret
check_shot_collision:		; Only when erasing: if the shot has hit the map, it switches off; and if the cell was one of the special ones, it breaks
	ld a,(SHOTS_PAINT_PASS)	; This is only done in the erase pass
	and a
	ret nz
	ld h,(ix+005h)
	ld l,(ix+003h)
	call collides_with_map_2
	ret nc
	ld a,(ix+000h)		; The missile skips the special cell
	cp 004h
	jr z,L_9FC8
	call is_special_cell
	jr c,break_cell
L_9FC8:
	ld hl,(BOSS_STATE)	; With the boss on screen, the shot is swallowed without a sound
	ld a,l
	and a
	jp z,switch_off_shot
	ld a,h
	and a
	jp nz,switch_off_shot
	ld a,006h		; Sound 6: the shot has collided
	call check_if_sound	; Sound 6
	jp switch_off_shot
break_cell:		; The special cell is erased from the map and plays whatever sound its group says
	xor a
	ld (de),a
	ld a,c
	call check_if_sound
	jp switch_off_shot
check_laser_against_map:		; Only when painting: walks the cells the laser occupies and cuts it off where it finds a wall
	ld a,(SHOTS_PAINT_PASS)	; Only in the paint pass
	and a
	ret z
	ld h,(ix+005h)
	ld l,(ix+003h)
	call cell_to_ram_address	; The map cell where it starts
	ex de,hl
	ld a,(ix+00ch)		; Byte 12: how many cells long it is
	or a
	ret z
	ld b,a
L_9FFB:
	call collides_at_this_cell
	jr nc,L_A00B

; Bank 3 (runs at 0xA000).
;
; The code of bank 2 falls through from 0x9FFF to 0xA000 and comes in here
; without any jump: the two banks are always mapped together.
;
; AND AT THE END OF THE BANK IS KONAMI'S HIDDEN MARK (konami_mark-0xBFFF). It is
; not our find: Manuel Pazos (@ManuelPazosMSX) uncovered it in 2021.
; Behind the 0xFF filler, and reading towards the end, there is [title
; backwards] [how many characters] [last two digits of the RC in BCD] [0xAA].
; Here it gives 8 characters and RC-742, and the title in katakana is
; グラディウス, that is, GRADIUS. tools/konami_mark.py extracts it.

; ----------------------------------------------------------------------
; THE BANK STARTS WHERE BANK 2 ENDS, WITHOUT ANY JUMP
; ----------------------------------------------------------------------
continued_from_bank_2:		; The code coming from 0x9FFF carries on here with no instruction in between
	call is_special_cell	; The code coming from 0x9FFF comes in here
	jr nc,laser_cut_short
	xor a
	ld (de),a		; The cell, erased
	ld a,c
	call check_if_sound
L_A00B:
	inc de			; And whatever is left of the strip
	djnz L_9FFB
	ret
laser_cut_short:		; The laser hits the map: its length is cut and, if nothing is left, it goes out
	ld (ix+001h),002h	; Step 2: the laser no longer grows
	ld a,(ix+00ch)		; Byte 12: how many cells long it is
	inc b
	sub b
	jp c,switch_off_shot	; With no cells left, the laser goes out
	jp z,switch_off_shot
	ld (ix+00ch),a
	ret

	end

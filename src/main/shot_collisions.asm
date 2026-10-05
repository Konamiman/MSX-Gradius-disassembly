; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - shot_collisions.asm
; ============================================================================

	include "variables.inc"

	public blow_up_enemy,blow_up_everything,check_background_collisions,check_boss_collisions,check_collisions,check_option_collision
	public check_ship_enemy_collision,check_ship_enemy_collision_2,check_ship_map_collision,check_ship_shot_collision,check_stage_5_collisions,dispatch_boss_drawing
	public dispatch_boss_step,dispatch_boss_step_2,L_721C,set_up_background_explosion
	extrn add_a_to_de,add_a_to_hl,add_to_score,award_ship,blow_up_core,cell_to_ram_address
	extrn check_if_sound,core_enters,core_waits,dispatch_boss_step_3,dispatch_boss_step_4,dispatcher
	extrn draw_boss,draw_eight_pieces,draw_single_piece,end_boss,erase_background_objects,erase_boss
	extrn erase_one_piece,erase_two_pieces,get_word,kill_ship,paint_boss,paint_two_pieces
	extrn refresh_meter,run_and_draw_boss,run_and_draw_boss_2,run_and_draw_boss_3,save_under_e780,save_under_the_eight
	extrn ship_collides,shot_origin,stage_5_boss_step,start_erasing_boss,turn_off_object,type_1E_splits_in_three
	extrn wait_until_nobody_left,walk_the_eight

; ----------------------------------------------------------------------
; THE COLLISIONS BETWEEN THE SHIP'S SHOTS AND THE ENEMIES
; Every frame the two lists are crossed: for each live enemy whose bit 1
; of byte 27 is set, the ship's NINE shots are walked (SHOTS, records of
; 0x10 bytes) to see whether any of them falls inside its box. The box is
; not square: 0x12 wide by 0x20 high, and the type 3 shot (the laser) is
; measured another way, with the height taken from its own record times
; eight.
; ----------------------------------------------------------------------
check_collisions:		; The twelve enemies at OBJECTS against the ship's nine shots
	ld b,00ch		; Twelve enemies
	ld ix,OBJECTS
L_721C:
	push bc
	ld a,(ix+000h)
	and a
	jr z,L_7241
	bit 1,(ix+01bh)		; Bit 1 of byte 27: this one can be hit
	jr z,L_7241
	ld hl,SHOTS		; The ship's nine shots, 0x10 bytes apart
	ld b,009h
L_722E:
	ld (SHOT_PTR),hl	; The shot's slot is parked
	ld a,(hl)
	and a
	call nz,check_one_shot
	jr c,L_7241
	ld hl,(SHOT_PTR)
	ld a,010h		; Sixteen bytes: the next shot
	add a,l
	ld l,a
	djnz L_722E
L_7241:
	pop bc
	ld de,00020h		; Thirty-two bytes: the next enemy
	add ix,de
	djnz L_721C
	ret
check_one_shot:		; Checks whether the shot falls in the enemy's box: 0x12 wide by 0x20 high
	cp 003h			; Type 3 (the laser) is measured separately
	jr z,check_laser
	inc l
	inc l
	inc l
	ld a,(ix+004h)
	sub (hl)
	add a,010h		; 0x12 wide
	cp 012h
	ret nc
	inc l
	inc l
	ld a,(hl)
	cp 0f0h			; Past Y 0xF0, the shot is gone
	ret nc
	sub (ix+006h)
	add a,010h
	cp 020h			; And 0x20 high
	ret nc
	ld hl,(SHOT_PTR)	; The shot is used up
	ld (hl),000h
	ld a,(ix+000h)
	cp 00bh			; Types 0x0B, 0x1B and 0x1E withstand it
	jp z,just_play_sound
	cp 01bh
	jp z,just_play_sound
	cp 01eh
	jp z,just_play_sound
	cp 019h
	jp z,start_exploding
	dec (ix+00fh)		; And the rest lose one point of life in byte 15
	ret nz
	jp score_enemy
check_laser:		; The laser measures differently: the height comes from its own record, multiplied by eight
	inc l
	inc l
	inc l
	ld a,(ix+004h)
	sub (hl)
	add a,010h		; 0x12 wide, the same
	cp 012h			; 0x12 wide
	ret nc
	inc l
	inc l
	ld a,(ix+006h)
	sub (hl)
	cp 0f0h
	jr nc,L_72AE
	ex af,af'
	ld a,007h		; Seven bytes further on: the length of the laser
	add a,l
	ld l,a
	ld a,(hl)
	add a,a			; Times eight
	add a,a
	add a,a
	ld c,a
	ex af,af'
	cp c
	ret nc
L_72AE:
	ld a,(ix+000h)		; Types 0x0B, 0x1B and 0x1E withstand it
	cp 00bh			; Types 0x0B, 0x1B and 0x1E withstand it
	jr z,just_play_sound	; The types that withstand it
	cp 01bh
	jr z,just_play_sound
	cp 01eh
	jr z,just_play_sound
	cp 019h
	jp z,start_exploding
score_enemy:		; One point, or five if it is type 0x1F
	ld de,00001h
	ld a,(ix+000h)
	cp 01fh			; Type 0x1F pays five
	jr nz,L_72CF
	ld de,00005h
L_72CF:
	call add_to_score
blow_up_enemy:		; Plays whatever the table at 0x730F says for that type, and the object becomes a type 0x15 explosion
	ld d,000h
	ld e,(ix+000h)
	ld hl,blow_up_sound_per_type-1	; The table at 0x730F: which sound each type carries
	add hl,de
	ld a,(hl)
	call check_if_sound
	ld bc,01578h		; Type 0x15, drawing 0x78
	ld a,(ix+000h)
	cp 00dh			; Type 0x0D carries another drawing
	jr nz,L_72EC
	ld bc,014f0h
L_72EC:
	ld (ix+000h),b
	ld (ix+00ch),c
	ld a,(ix+00bh)		; If it was drawn with characters, fifteen frames of explosion
	ld (ix+00bh),000h
	and a
	jr z,L_7300
	ld (ix+00dh),00fh
L_7300:
	xor a
	ld (ix+002h),a
	ld (ix+01bh),a
	scf			; Exits with carry: it has been blown up
	ret
just_play_sound:		; The ones that withstand the hit only play sound 6
	ld a,006h
	call check_if_sound
	scf
L_730F:
	ret

; ----------------------------------------------------------------------
; DATA blow_up_sound_per_type (part): Thirty-two bytes read by 0x72D7 with the base
;   0x730F.
blow_up_sound_per_type:
	defb 0Ah,08h,08h,08h,0Ah,0Ah,08h,08h,08h,08h,08h,08h,09h,0Dh,0Dh,0Dh
	defb 0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Bh,0Dh,0Dh,0Dh
check_ship_map_collision:		; Asks bank 2; if it collides, the ship dies
	ld a,(SHIP)		; At 0xFF there is no ship
	inc a
	ret z
	call ship_collides
	ret nc
	jp ship_has_died
check_ship_shot_collision:		; The ten at ENEMY_SHOTS against the ship, with a two by two box
	ld a,(SHIP)
	inc a
	ret z
	ld ix,ENEMY_SHOTS	; The ten enemy shots
	ld l,00ah
	ld bc,00202h		; Two wide by two high
	call any_on_top
	ret nc
	xor a
	ld (ix+000h),a
	ld (ix+01bh),a
	jp ship_has_died
any_on_top:		; Walks the slots looking for one whose box catches the point (SHIP_ROW+4, SHIP_COLUMN+1)
	ld a,(SHIP_ROW)		; The ship's row plus four
	add a,004h
	ld e,a
	ld a,(SHIP_COLUMN)	; And its column plus one
	inc a
	ld d,a
	exx
	ld de,00020h		; Thirty-two bytes per slot
	ld bc,00c08h		; The box: 0x0C high by 8 wide
	exx
L_736A:
	ld a,(ix+000h)		; A slot at zero is free
	or a
	jr z,L_738C
	bit 0,(ix+01bh)		; Bit 0 of byte 27: this one can hit the ship
	jr z,L_738C		; Thirty-two bytes per slot
	ld a,(ix+004h)
	sub e
	exx
	cp c
	exx
	jr c,L_7382
	add a,c
	jr nc,L_738C
L_7382:
	ld a,(ix+006h)		; And the Y
	sub d
	exx
	cp b
	exx
	ret c
	add a,b
	ret c
L_738C:
	exx			; Thirty-two bytes: the next slot
	add ix,de
	exx
	dec l
	jr nz,L_736A
	xor a
	ret
check_ship_enemy_collision:		; With the shield below 2, the ten at ENEMY_SHOTS can kill it
	ld a,(SHIP)		; Below two: no shield
	cp 002h
	ret m
	ld ix,ENEMY_SHOTS
	ld b,00ah		; Ten shots
	ld a,(SHIP_ROW)		; The ship's row and its column plus twelve
	ld l,a
	ld a,(SHIP_COLUMN)
	add a,00ch
	ld h,a
	ld de,00020h		; Thirty-two bytes per slot
L_73AE:
	ld a,(ix+000h)
	and a
	jp z,L_73D2
	ld c,00bh		; The box is 0x0B high, or 0x19 if the shot is drawn with characters
	ld a,(ix+00bh)
	and a
	jr z,L_73BF
	ld c,019h
L_73BF:
	ld a,l
	sub (ix+004h)
	add a,010h		; 0x13 wide
	cp 013h
	jr nc,L_73D2
	ld a,h			; 0x13 wide
	sub (ix+006h)
	add a,00ch		; Outside the box, the shot does not hit
	cp c
	jr c,ship_hits_something
L_73D2:
	add ix,de
	djnz L_73AE
	ret
ship_hits_something:		; If what it hit is drawn with characters, the ship blows up; if not, it only loses shield
	ld a,(ix+00bh)		; Byte 11: whether it is drawn with characters
	and a
	jr nz,ship_dies
	call lower_shield
switch_off_slot:		; Leaves the slot free
	xor a
	ld (ix+000h),a		; The slot is left free
	ld (ix+01bh),a
	ret
ship_dies:		; SHIP to one and SHIP_TIMER to zero: the ship is done for
	ld hl,00001h
	ld (SHIP),hl		; And the ship is done for
	call switch_off_slot
	jp refresh_meter
remove_shield_and_score:		; Lowers the shield and, depending on the type, blows up the enemy or collects its points
	call lower_shield
	ld a,(ix+000h)
	cp 01eh			; Type 0x1E: the big one
	call z,score_big_object
	cp 019h
	jp z,start_exploding
	sub 012h		; Types 0x12 to 0x1A are explosions: they do not pay
	cp 009h
	ret c
	jp score_enemy
lower_shield:		; SHIP_TIMER goes down; below two the shield is left weak, and on reaching zero it switches off
	ld b,001h
	ld hl,SHIP_TIMER
	dec (hl)		; One point less of shield
	jr z,L_741B
	ld a,(hl)
	cp 002h			; Below two, the shield is barely holding
	jr c,L_741A
	inc b
L_741A:
	inc b
L_741B:
	dec l
	ld (hl),b
	jp refresh_meter
check_ship_enemy_collision_2:		; The twelve at OBJECTS, with a box of 0x21 by 0x15
	ld a,(SHIP)		; Below two: no shield
	cp 002h
	ret m
	ld ix,OBJECTS
	ld b,00ch		; Twelve enemies
	ld a,(SHIP_ROW)		; The ship's row and its column plus twelve
	ld l,a
	ld a,(SHIP_COLUMN)
	add a,00ch
	ld h,a
	ld de,00020h
L_7439:
	ld a,(ix+000h)
	and a
	jr z,L_7459
	bit 1,(ix+01bh)		; Bit 1 of byte 27: this one can be hit
	jr z,L_7459
	ld a,l
	sub (ix+004h)
	add a,010h
	cp 021h			; 0x21 wide...
	jr nc,L_7459
	ld a,h
	sub (ix+006h)
	add a,00ch
	cp 015h			; ...and 0x15 high
	jr c,remove_shield_and_score	; 0x15 high
L_7459:
	add ix,de
	djnz L_7439
	ret
check_option_collision:		; The same calculation but for the options, with a box of 0x0C by 0x0C
	ld a,(SHIP)
	inc a
	ret z
	ld ix,OBJECTS
	ld l,00ch
	ld bc,00c0ch		; Twelve wide by twelve high
	call any_over_ship
	ret nc
	ld a,(ix+000h)
	sub 012h		; Types 0x12 to 0x1A are explosions
	jp c,score_and_die
	cp 009h
	jp c,dispatch_by_touched_type
	cp 00ch
	call z,score_big_object
score_and_die:		; Collects the enemy and the ship goes
	call score_enemy
	jp ship_has_died
score_big_object:		; The three-slot object: goes back to the first one, tells bank 3 and collects 0x10 points
	push ix
	ld a,(ix+013h)		; Byte 19 says which of the three slots it is
	or a
	jr z,L_749A
	ld de,0ffe0h		; 0x20 or 0x40 bytes back: the first one
	dec a
	jr z,L_7498
	ld e,0c0h
L_7498:
	add ix,de
L_749A:
	call type_1E_splits_in_three
	ld de,00010h		; Ten points in BCD
	call add_to_score
	pop ix
	ret
dispatch_by_touched_type:		; Depending on the type, the option gets an upgrade, a ship or a prize
	or a			; Type 0 is the meter upgrade
	jp z,pick_up_meter_upgrade
	dec a			; 1, the bomb
	jp z,pick_up_bomb	; Type 4 is the gift ship
	sub 003h
	jr z,pick_up_ship
	dec a			; Types 5 and 6, the capsule
	jr z,pick_up_capsule
	dec a
	jr z,pick_up_capsule
	dec a			; And 7, the explosion
	jr z,start_exploding
	ret
pick_up_ship:		; Turns the object into 0x1A, gives it drawing 0xE0, plays sound 0x11 and gives away a ship
	call turn_into_prize
	ld (ix+00dh),002h
	ld (ix+00ch),0e0h
	ld a,011h		; Sound 0x11
	call check_if_sound
	jp award_ship		; And one more ship
pick_up_capsule:		; The same, with the drawing taken from CAPSULE_STREAK and sound 0x10
	call turn_into_prize
	ld (ix+00dh),008h
	call score_capsule
	ld a,(CAPSULE_STREAK)	; How many capsules in a row so far
	add a,a
	add a,a
	add a,0e0h
	ld (ix+00ch),a
	ld a,010h		; Sound 0x10
	jp check_if_sound
start_exploding:		; The object becomes an explosion: type (byte 14) plus 0x13, it can no longer be hit and its drawing is erased from the screen
	ld a,(ix+00eh)		; Byte 14 says what type it was
	ld b,a
	add a,013h		; Plus 0x13: the explosion types
	ld (ix+000h),a		; The explosion type that belongs to it
	ld a,b
	sub 003h
	ld b,037h		; Drawing 0x37, or 0x38 with its colour
	jr z,L_7503
	inc b
	ld c,001h
	dec a
	jr z,L_7500
	ld c,008h
L_7500:
	ld (ix+017h),c
L_7503:
	ld (ix+00ch),b
	res 1,(ix+01bh)		; Bit 1 is cleared: it no longer collides with anything
	xor a
	ld (ix+013h),a		; The object's four characters, to zero
	ld (ix+014h),a
	ld (ix+015h),a
	ld (ix+016h),a
	ld l,(ix+004h)		; The cell where it was
	ld h,(ix+006h)		; Byte 15 keeps the type
	call cell_to_ram_address
	xor a
	ld (hl),a		; The two characters on top...
	inc hl
	ld (hl),a
	ld bc,0001fh		; ...and the two below
	add hl,bc
	ld (hl),a
	inc hl
	ld (hl),a
	scf
	ret
turn_into_prize:		; The object keeps its type in byte 24 and becomes 0x1A, the one that floats up
	ld a,(ix+000h)		; Byte 24 keeps the previous type
	ld (ix+018h),a		; The object's four characters, to zero
	ld (ix+000h),01ah
	ld (ix+002h),00ah
	ld a,(ix+004h)
	ld (ix+019h),a		; Byte 25 keeps the X
	ld (ix+00bh),000h	; And it stops being drawn and colliding
	ld (ix+01bh),000h	; And the alive mark, to zero
	ret
score_capsule:		; Raises the capsule count and pays whatever the table at 0x7561 says
	call raise_capsule_count
	ld hl,L_7561
	call get_word
	jp add_to_score
raise_capsule_count:		; CAPSULE_STREAK goes up to seven and stays there
	ld hl,CAPSULE_STREAK
	ld a,(hl)
	inc a
	cp 008h			; Seven is the cap
	jr c,L_7561
	ld a,007h
L_7561:
	ld (hl),a
	ret

; ----------------------------------------------------------------------
; DATA capsule_points (part): Eight words in BCD, each one double or five
;   times the previous: what capsule number N pays, with N counted in CAPSULE_STREAK
;   and capped at seven. Read by 0x754D.
DATA_7563:
	defw 0001h
	defw 0002h
	defw 0005h
	defw 0010h
	defw 0020h
	defw 0050h
	defw 0100h
pick_up_meter_upgrade:		; Advances the upgrade meter's slot (from one to six, round and round), collects five points and plays sound 0x11
	ld hl,METER_SLOT
	ld a,(hl)
	inc a
	cp 007h			; Six slots, and from the sixth it goes back to the first
	jr c,L_757C
	ld a,001h
L_757C:
	ld (hl),a
	call turn_off_object
	ld de,00005h		; Five points
	call add_to_score
	ld a,011h		; Sound 0x11
	call check_if_sound
	jp refresh_meter
pick_up_bomb:		; Plays sound 0x12 and blows up everything in the two tables at once
	call turn_off_object
	ld a,012h		; Sound 0x12
	call check_if_sound
blow_up_everything:		; The twelve at 0xE460 and the five at 0xEB80, counted backwards
	ld ix,OBJECTS+(OBJECT_COUNT-1)*OBJECT_SIZE
	ld b,00ch		; Twelve slots
	call L_75A5
	ld ix,MID_BOSS_PIECES+4*MID_BOSS_PIECE_SIZE
	ld b,005h		; And five more
L_75A5:
	push bc
	ld a,(ix+000h)
	dec a
	cp 00fh			; Types 1 to 0x0F: the ones that pay
	call c,score_enemy
	pop bc
	ld de,0ffe0h		; Thirty-two bytes back
	add ix,de
	djnz L_75A5
	ret
any_over_ship:		; Like any_on_top, but with IX already set: walks L slots looking for the one that catches the ship's point
	ld a,(SHIP_ROW)		; The ship's row plus four and its column plus one
	add a,004h
	ld e,a
	ld a,(SHIP_COLUMN)
	inc a
	ld d,a
	exx
	ld de,00020h		; Thirty-two bytes per slot
	ld bc,00c08h		; The box: 0x0C high by 8 wide
	exx
L_75CB:
	bit 0,(ix+01bh)		; Bit 0 of byte 27: this one can hit the ship
	jr z,L_75E7		; Bit 0 of byte 27
	ld a,(ix+004h)
	sub e
	exx
	cp c
	exx
	jr c,L_75DD
	add a,c
	jr nc,L_75E7
L_75DD:
	ld a,(ix+006h)		; And the Y
	sub d
	exx
	cp b
	exx
	ret c
	add a,b
	ret c
L_75E7:
	exx			; Thirty-two bytes: the next slot
	add ix,de		; Thirty-two bytes: the next slot
	exx
	dec l
	jr nz,L_75CB
	xor a
	ret
ship_has_died:		; Clears the joystick, plays sound 0x47 and hands over to bank 2
	nop
	xor a
	ld (SND_MUTE),a
	ld a,047h		; Sound 0x47
	call check_if_sound
	jp kill_ship
falls_inside_box:		; Checks whether the point in HL falls inside the box BC around DE
	ld a,l			; The X against the box
	sub e
	exx
	cp c
	exx
	jr c,L_7606
	add a,c
	ret nc
L_7606:
	ld a,h			; And the Y
	sub d
	exx
	cp b
	exx
	ret c
	add a,b
	ret
check_boss_collisions:		; The ship's nine shots against the boss's pieces, while CORE_DEAD is zero
	ld a,(BOSS_STATE)	; Without a boss there is nothing to check
	and a
	ret z
	ld a,(CORE_DEAD)
	and a
	ret nz
	ld hl,SHOTS		; The nine shots, 0x10 apart
	ld b,009h
L_761D:
	ld (SHOT_PTR),hl	; Each one is parked
	push bc			; Each shot is parked in SHOT_PTR
	call check_one_shot_against_boss
	pop bc
	ld hl,(SHOT_PTR)
	ld de,00010h		; Sixteen bytes: the next one
	add hl,de
	djnz L_761D
	ret
check_one_shot_against_boss:		; Walks the boss's pieces at BOSS_PIECES; how many there are is given by the table at boss_piece_counts, indexed by the step BOSS_KIND
	ld a,(hl)
	and a
	ret z
	exx
	ld de,00010h		; Sixteen bytes per piece
	ld bc,01002h		; The box: 0x10 high by 2 wide
	exx			; Sixteen bytes per piece
	inc l
	inc l
	inc l
	ld e,(hl)
	inc l
	inc l
	ld d,(hl)
	ld ix,BOSS_PIECES
	cp 003h			; Shot 3 (the laser) is measured separately
	call z,laser_height
	ld a,(BOSS_KIND)
	ld hl,boss_piece_counts	; The table at boss_piece_counts: how many pieces the boss has at each step
	add a,l
	ld l,a
	jr nc,L_7655
	inc h
L_7655:
	ld b,(hl)
L_7656:
	ld a,(ix+000h)		; A slot at zero is free
	and a			; The piece's position
	jr z,L_766D
	ld l,(ix+003h)
	ld h,(ix+005h)
	push bc
	call piece_box
	call falls_inside_box
	pop bc
	jp c,hit_boss
L_766D:
	exx			; Sixteen bytes: the next piece
	add ix,de
	exx
	djnz L_7656
	ret

; ----------------------------------------------------------------------
; DATA boss_piece_counts: Seven bytes read by 0x764D.
boss_piece_counts:
	defb 01h,08h,07h,01h,02h,08h,01h
laser_height:		; The laser measures whatever its record says, plus one and times eight
	ld a,007h		; Seven bytes further on: the length
	add a,l
	ld l,a
	ld a,(hl)
	inc a
	add a,a			; Plus one and times eight
	add a,a
	add a,a
	exx
	ld b,a
	exx
	ret
piece_box:		; Each boss piece has its own box, and those of types 4 and 7 come from the table at table_76EF
	ld a,(ix+000h)		; The piece type rules
	dec a
	jr z,L_76A0
	dec a			; Type 1
	jr z,L_76D5
	dec a			; Type 2
	jr z,L_76A4
	dec a			; Type 3
	jr z,L_76B8
	dec a			; Type 4
	jr z,L_76B4
	dec a			; And type 5
	jr z,L_76EB
	dec a
	jr z,L_76D9
L_76A0:
	ld bc,05840h		; 0x58 high by 0x40 wide
	ret
L_76A4:
	ld bc,02020h		; 0x20 by 0x20, or smaller depending on the step
	ld a,(ix+001h)
	dec a
	ret m
	ld bc,01010h
	ret z
	ld bc,00810h
	ret
L_76B4:
	ld bc,01010h		; 0x10 by 0x10
	ret
L_76B8:
	push de
	ld de,table_76EF	; The table at table_76EF, indexed by the Y
	ld a,(ix+006h)
	call shift_centre
	pop de
	ld bc,01008h		; 8 wide by 0x10 high
	ret
shift_centre:		; Adds to HL the pair from the table, plus six in X
	add a,a			; Times two: two bytes per entry
	call add_a_to_de
	ld a,(de)
	add a,l
	add a,006h		; And six more in X
	ld l,a
	inc de
	ld a,(de)
	add a,h
	ld h,a
	ret
L_76D5:
	ld bc,02020h		; 0x20 by 0x20
	ret
L_76D9:
	ld bc,00808h		; 8 by 8, and the centre comes from another table in bank 2
	push de
	ld de,table_76EF
	ld de,shot_origin
	ld a,(ix+00ah)
	call shift_centre
	pop de
	ret
L_76EB:
	ld bc,02018h		; 0x18 wide by 0x20 high
	ret

; ----------------------------------------------------------------------
; DATA table_76EF: Eighty bytes read by 0x76B9 and 0x76DD.
table_76EF:
	defb 13h,09h,14h,04h,14h,0Ah,14h,00h,0Ch,04h,04h,0Eh,00h,11h,0FCh,10h
	defb 0FEh,19h,02h,19h,14h,08h,13h,05h,14h,0Ah,13h,00h,13h,04h,14h,0Eh
	defb 0Fh,10h,0Bh,10h,09h,18h,06h,18h,14h,08h,14h,0Ch,14h,06h,14h,10h
	defb 13h,14h,13h,1Bh,1Fh,18h,0Bh,18h,0Ah,18h,05h,18h,14h,08h,14h,0Ch
	defb 15h,07h,14h,11h,0Ch,14h,04h,1Ah,0FFh,1Ah,0FCh,18h,0FEh,18h,02h,19h
hit_boss:		; Uses up the shot (one if it is the laser, four if not), takes life off the piece and checks whether it is finished
	ld a,(ix+000h)
	dec a
	jp z,hit_core
	ld hl,(SHOT_PTR)	; The shot that hit
	ld c,001h
	ld a,(hl)
	cp 003h			; Type 3 (the laser) is not used up: it only takes one
	jr z,L_7754
	ld c,004h		; The rest take four and disappear
	ld (hl),000h
L_7754:
	ld b,(ix+000h)
	ld a,(ix+009h)		; Byte 9 is the piece's life
	sub c
	ld (ix+009h),a
	dec b
	dec b
	jr z,hit_piece_1	; Each piece type finishes its hit in its own way
	dec b
	jp z,hit_piece_2
	dec b
	jr z,L_77DD		; Type 4
	dec b
	jr z,blow_up_without_explosion	; Type 5
	dec b
	jr z,hit_piece_5	; Type 6
	dec b
	jr z,blow_up_big_piece	; And type 7
	ret
hit_piece_5:		; With life to spare it plays sound 6; if not, collects 0x10 points
	ld de,00010h
	dec a
	jp m,L_7794
	ld a,006h		; Sound 6: the hit it withstands
	jp check_if_sound
hit_piece_1:		; The same, and when it runs out it lowers the piece count in HEIGHT_PIECES
	dec a
	jp m,L_7788
	ld a,006h
	jp check_if_sound
L_7788:
	ld a,(ix+00eh)		; Byte 14 says which group it belongs to
	ld hl,HEIGHT_PIECES	; How many pieces of that group are left
	add a,l
	ld l,a
	dec (hl)
	ld de,00030h		; 0x30 points
L_7794:
	jp blow_up_and_score
blow_up_big_piece:		; When it runs out it sets the submode to 1, plays sound 0x0E, collects 0x10 and sets up the explosion
	dec a
	ld a,006h
	jp p,check_if_sound
	ld (ix+00ch),001h
	ld a,001h		; BIG_PIECE_BLOWN to one
	ld (BIG_PIECE_BLOWN),a
	ld a,00eh		; Sound 0x0E
	call check_if_sound
	ld de,00010h		; Ten points
	call add_to_score
	ld e,(ix+003h)
	ld d,(ix+005h)
	jp set_up_background_explosion
blow_up_without_explosion:		; Frees the slot, collects 0x30 and plays sound 0x0E
	dec a			; The slot is left free
	ret p
	ld (ix+000h),000h
	ld de,00030h
	ld a,00eh
	jp check_if_sound
blow_up_and_score:		; Plays sound 0x0E, collects whatever DE brings, frees the slot and sets up the explosion
	ld a,00eh		; Sound 0x0E
	call check_if_sound
L_77CD:
	call add_to_score	; Collects whatever DE brings
	ld (ix+000h),000h
	ld d,(ix+005h)
	ld e,(ix+003h)
	jp set_up_background_explosion
L_77DD:
	dec a
	jp p,L_7806
	ld a,00eh
	call check_if_sound
blow_up_this_piece:		; Tells bank 2 and collects 0x10
	ld a,(ix+000h)		; A slot at zero is already free
	and a
	ret z
	call erase_one_piece
	ld de,00010h
	jr L_77CD
hit_piece_2:		; Depending on the life it has left, changes the drawing (three states) and plays sound 0x0D
	dec a
	jp m,blow_up_three_pieces
	ld c,002h
	cp 010h			; Below 0x10, the last drawing
	jr c,L_7803
	dec c
	cp 020h			; And below 0x20, the middle one
	jr c,L_7803
	dec c
L_7803:
	ld (ix+001h),c
L_7806:
	ld a,00dh		; Sound 0x0D
	jp check_if_sound
blow_up_three_pieces:		; Collects 0x50 for this one and also blows up the next two slots
	call erase_one_piece
	ld de,00050h		; Fifty points
	call blow_up_and_score
	ld de,00010h		; Sixteen bytes: the next piece
	add ix,de		; Sixteen bytes: the next piece
	push ix
	call blow_up_this_piece
	pop ix
	ld de,00010h
	add ix,de
	jr blow_up_this_piece
hit_core:		; Only the odd shots count, and only from the front: sets up the explosion at OBJECTS and takes life off the core
	ld hl,(SHOT_PTR)
	ld a,(hl)
	rra			; Bit 0 of the type: only half of the shots count
	ret nc
	ld a,(ix+006h)
	and a
	jr nz,just_play_sound_6
	ld a,(CORE_DEAD)	; With the core already blown up, no
	and a
	jr nz,just_play_sound_6
	inc l
	inc l
	inc l
	ld a,(ix+003h)
	add a,01ch		; 0x1C in front and eight of margin
	sub (hl)
	add a,008h
	jr nc,just_play_sound_6
	ld a,015h		; Type 0x15: the explosion
	ld (OBJECTS),a
	ld a,(ix+003h)		; 0x18 lower and 0x0C to the right
	add a,018h		; 0x18 lower and 0x0C to the right
	ld (OBJECTS+4),a	; 0x18 lower
	ld a,(ix+005h)
	add a,00ch
	ld (OBJECTS+6),a
	xor a
	ld (OBJECTS+2),a
	ld (OBJECTS+1Bh),a
	ld hl,(SHOT_PTR)
	ld a,(hl)
	ld a,(hl)
	cp 003h			; The laser is not used up
	jr z,L_786D
	ld (hl),000h
L_786D:
	dec (ix+009h)		; Byte 9 is the core's life
	jr nz,L_7879
	ld a,001h		; CORE_DEAD to one: the core is dead
	ld (CORE_DEAD),a
	jr L_7806
L_7879:
	ld a,(ix+009h)		; And every three hits, five points
	and 003h
	cp 003h
	jp nz,L_7806
	ld de,00005h
	call add_to_score
	jp L_7806
just_play_sound_6:		; Nothing happens to the core from behind
	ld hl,(SHOT_PTR)	; Only the laser makes a sound
	ld a,(hl)
	cp 003h
	ret nz
	ld a,006h
	jp check_if_sound
check_background_collisions:		; The ship's nine shots against the background objects at BG_OBJECTS; stages 3 and 5 go their own way
	ld hl,SHOTS
	ld b,009h		; Nine shots
	ld a,(STAGE)
	cp 003h			; Stage 3 has its own calculation
	jp z,background_collisions_stage_3
	cp 005h			; And so does stage 5
	jp z,background_collisions_stage_5
L_78AA:
	ld (SHOT_PTR),hl
	push bc
	call check_one_shot_against_background
	pop bc
	ld hl,(SHOT_PTR)
	ld de,00010h		; Sixteen bytes: the next shot
	add hl,de
	djnz L_78AA
	ret
check_one_shot_against_background:		; Walks the two background objects and checks whether the shot falls inside
	ld a,(hl)
	and a
	ret z
	ld c,a
	exx
	ld de,00008h		; Eight bytes per object
	exx
	inc l			; The shot's position
	inc l			; The shot's type
	inc l
	ld e,(hl)
	inc l
	inc l
	ld d,(hl)
	ld ix,BG_OBJECTS
	ld a,c
	ld c,008h
	cp 003h			; The laser is measured separately
	call z,laser_height_times_eight
	ld b,002h		; Two objects
L_78DA:
	ld a,(ix+000h)
	and a
	jr z,L_78FB
	ld a,e
	sub (ix+002h)
	add a,002h
	cp 022h			; 0x22 wide
	jr nc,L_78FB
	ld a,(ix+003h)
	cp 0e8h			; Past Y 0xE8, the object is gone
	jr nc,L_78FB
	sub d
	cp c
	jp c,hit_background_object
	add a,020h		; And 0x20 high
	jp c,hit_background_object
L_78FB:
	exx
	add ix,de		; Eight bytes: the next object
	exx
	djnz L_78DA
	ret
background_collisions_stage_3:		; Stage 3 has eight background objects and its own table of positions
	xor a
	ld (STAGE3_BG_HIT),a	; To zero
	ld (SHOT_PTR),hl
	push bc
	call one_shot_against_background_3
	pop bc
	ld hl,(SHOT_PTR)
	ld de,00010h		; Sixteen bytes: the next shot
	add hl,de
	djnz background_collisions_stage_3
	ret
one_shot_against_background_3:		; Eight objects, each with its offset taken from the table at 0x7B38
	ld a,(hl)
	and a
	ret z
	ld c,a
	exx
	ld de,00008h		; Eight bytes per object
	exx			; The shot's position
	inc l			; The shot's type
	inc l
	inc l
	ld e,(hl)
	inc l
	inc l
	ld d,(hl)
	ld ix,BG_OBJECTS
	ld a,c
	ld c,008h
	cp 003h			; The laser is measured separately
	call z,laser_height_times_eight
	ld b,008h		; Eight objects
L_7936:
	ld a,(ix+001h)		; Only the ones on step 1
	dec a
	jr nz,L_7969
	ld a,(ix+000h)
	and a
	jr z,L_7969
	ld hl,table_7B38-6	; The table at 0x7B38: the centre of each type
	add a,a
	add a,l
	ld l,a
	jr nc,L_794B
	inc h
L_794B:
	ld a,(hl)
	add a,(ix+002h)
	sub e
	add a,010h		; 0x10 wide
	jr nc,L_7969
	inc hl
	ld a,(hl)
	add a,(ix+003h)
	jr c,L_7969
	cp 0f0h			; Past Y 0xF0, it is gone
	jr nc,L_7969
	sub d
	cp c
	jp c,hit_stage_3_object
	add a,010h		; And 0x10 high
	jp c,hit_stage_3_object	; 0x10 high
L_7969:
	exx			; 0x10 high
	add ix,de
	exx
	djnz L_7936
	ret
background_collisions_stage_5:		; The same for stage 5
	ld (SHOT_PTR),hl
	push bc
	call one_shot_against_background_5
	pop bc
	ld hl,(SHOT_PTR)
	ld de,00010h		; Sixteen bytes: the next shot
	add hl,de
	djnz background_collisions_stage_5
	ret
one_shot_against_background_5:		; Eight objects, and only the types below 5 that are on step 2
	ld a,(hl)
	and a
	ret z
	ld c,a
	exx
	ld de,00008h		; Eight bytes per object
	exx
	inc l
	inc l
	inc l
	ld e,(hl)		; The shot's position
	inc l
	inc l
	ld d,(hl)
	ld ix,BG_OBJECTS
	ld a,c
	ld c,008h
	cp 003h			; The laser is measured separately
	call z,laser_height_times_eight
	ld b,008h
L_79A0:
	ld a,(ix+000h)
	and a
	jr z,L_79D2
	cp 005h			; From type 5 upwards the count ends
	jr nc,one_shot_against_walls
	ld a,(ix+001h)
	cp 002h			; Only the ones on step 2
	jr nz,L_79D2
	ld a,010h
	add a,(ix+002h)
	sub e
	add a,010h		; 0x10 wide
	jr nc,L_79D2
	ld a,0f8h
	bit 0,(ix+000h)		; Bit 0 of the type says whether it faces up or down
	jr nz,L_79C5
	ld a,020h
L_79C5:
	add a,(ix+003h)
	sub d
	cp c
	jp c,hit_stage_5_wall
	add a,010h		; And 0x10 high
	jp c,hit_stage_5_wall	; And 0x10 high
L_79D2:
	exx			; Eight bytes: the next object
	add ix,de
	exx
	djnz L_79A0
	ret
one_shot_against_walls:		; The types below 9 of stage 5 are measured with three different boxes depending on the type
	ld hl,(SHOT_PTR)
	ld a,(hl)
	jr c,L_79D2
	ld a,(ix+000h)
	cp 009h			; From type 9 upwards, nothing
	jr nc,L_79D2
	cp 007h			; Types 7 and 8 carry another box
	jr nc,types_7_and_8_box
	cp 006h			; And 6, another one
	jr z,type_6_box
	ld a,e
	sub (ix+002h)
	add a,008h
	cp 010h			; 0x10 wide
	jr nc,L_79D2
	ld a,(ix+003h)
	cp 0c8h			; Past Y 0xC8, it is gone
	jr nc,L_79D2
	sub d
	cp c
	jp c,hit_wall
	add a,020h		; 0x20 high
	jp c,hit_wall
	jr L_79D2
type_6_box:		; Eight wide, shifted 0x12
	ld a,e			; Eight wide
	sub (ix+002h)
	sub 012h
	cp 008h
	jr nc,L_79D2
	ld a,(ix+003h)		; Past Y 0xC8, it is gone
	cp 0c8h
	jr nc,L_79D2
	sub d
	cp c
	jp c,hit_wall
	add a,020h
	jp c,hit_wall
	jr L_79D2
types_7_and_8_box:		; 0x10 wide and with the Y cap at 0xE8
	ld a,e			; 0x10 wide
	sub (ix+002h)
	add a,008h
	cp 010h
	jr nc,L_79D2
	ld a,(ix+003h)		; Past Y 0xE8, it is gone
	cp 0e8h
	jr nc,L_79D2
	sub d
	cp c
	jp c,hit_wall
	add a,020h
	jp c,hit_wall
	jr L_79D2
laser_height_times_eight:		; The length of the laser, taken from its record and multiplied by eight
	ld a,007h		; Seven bytes further on: the length
	add a,l			; Seven bytes further on: the length of the laser
	ld l,a			; Times eight
	ld a,(hl)
	add a,a
	add a,a
	add a,a
	ld c,a
	ret
hit_wall:		; Takes three life off if it is the laser and five if not; when it runs out it collects 0x10 and sets up the explosion
	ld hl,(SHOT_PTR)
	ld c,003h
	ld a,(hl)
	cp 003h			; The laser takes three and is not used up
	jr z,L_7A5D
	ld c,005h		; The rest take five and disappear
	ld (hl),000h
L_7A5D:
	ld a,(ix+005h)		; Byte 5 is the wall's life
	sub c
	ld (ix+005h),a
	dec a
	jp m,L_7A6D
	ld a,006h		; Sound 6: it still holds
	jp check_if_sound
L_7A6D:
	ld de,00010h		; Ten points
	call add_to_score
	ld a,00eh		; Sound 0x0E
	call check_if_sound
	ld a,(ix+000h)
	add a,004h		; The type goes up four: the broken wall
	ld (ix+000h),a
	cp 00bh
	ld a,(ix+002h)
	jr nz,L_7A89
	sub 018h		; Type 0x0B shifts by 0x18
L_7A89:
	ld e,a
	ld d,(ix+003h)
	jp set_up_background_explosion
hit_stage_5_wall:		; The same calculation with drawing 0x0F
	ld hl,(SHOT_PTR)	; The laser takes three and is not used up
	ld c,003h
	ld a,(hl)
	cp 003h
	jr z,L_7A9E
	ld c,005h
	ld (hl),000h
L_7A9E:
	ld a,(ix+005h)		; Byte 5 is the life
	sub c
	ld (ix+005h),a
	dec a
	ld a,00fh
	jp m,erase_and_score
	ld a,006h
	jp check_if_sound
hit_background_object:		; Gives it the drawing times two minus one, takes life off it and, when it runs out, plays sound 0x0E and erases it
	ld a,(ix+000h)
	add a,a			; The type times two minus one: the hit drawing
	dec a
	ld (ix+006h),a
	ld hl,(SHOT_PTR)
	ld c,003h
	ld a,(hl)
	cp 003h			; The laser takes three and is not used up
	jr z,L_7AC6
	ld c,005h
	ld (hl),000h
L_7AC6:
	ld a,(ix+005h)		; Byte 5 is the life
	sub c
	ld (ix+005h),a
	dec a
	jp m,L_7AD6
	ld a,006h		; Sound 6: it still holds
	jp check_if_sound
L_7AD6:
	ld a,00eh
erase_and_score:		; Plays a sound, erases the object from the screen, collects 0x10 and sets up the explosion
	call check_if_sound
	call erase_background_objects
	ld de,00010h		; Ten points
	call add_to_score
	ld e,(ix+002h)
	ld d,(ix+003h)
	ld (ix+000h),000h
	jr set_up_background_explosion
hit_stage_3_object:		; The same, but switches on STAGE3_BG_HIT, leaves it on step 2 and moves the explosion with the table at background_explosion_offsets
	ld a,001h		; STAGE3_BG_HIT to one
	ld (STAGE3_BG_HIT),a	; To one
	ld hl,(SHOT_PTR)
	ld c,003h
	ld a,(hl)
	cp 003h
	jr z,L_7B03
	ld c,005h
	ld (hl),000h
L_7B03:
	ld a,(ix+005h)		; Byte 5 is the life
	sub c
	ld (ix+005h),a
	dec a
	jp m,L_7B13
	ld a,006h		; Sound 6
	jp check_if_sound
L_7B13:
	call erase_background_objects
	ld de,00010h		; Ten points
	call add_to_score
	ld a,00fh		; Sound 0x0F
	call check_if_sound
	ld e,(ix+002h)
	ld d,(ix+003h)
	ld (ix+001h),002h	; The object moves to step 2
	ld a,(ix+000h)
	add a,a
	ld hl,background_explosion_offsets	; The table at background_explosion_offsets: where each type's explosion lands
	call add_a_to_hl	; The table at background_explosion_offsets: where the explosion lands
	ld a,(hl)		; And the Y
	add a,e
	ld e,a
L_7B38:
	inc hl
	ld a,(hl)
	add a,d
	ld d,a
	jr set_up_background_explosion

; ----------------------------------------------------------------------
; DATA table_7B38: The last two bytes of the eight-byte table that 0x7942
;   declares with the base 0x7B38: the first six fall on top of the code,
;   which means only the high indexes are used.
table_7B38:
	defb 18h,18h

; ----------------------------------------------------------------------
; DATA background_explosion_offsets: Fourteen bytes read by 0x7B2F.
background_explosion_offsets:
	defb 18h,28h
	defb 08h,38h
	defb 08h,38h
	defb 08h,20h
	defb 08h,10h
	defb 10h,28h
	defb 0F0h,28h
set_up_background_explosion:		; Looks for room in the four slots at EXPLOSIONS and sets up the explosion there, with its mirror at BLAST_MIRROR cleared to zero
	ld hl,EXPLOSIONS
	ld b,004h		; Four slots
L_7B53:
	ld a,(hl)
	and a
	jr z,L_7B60
	ld a,008h		; Eight bytes per slot
	add a,l
	ld l,a
	djnz L_7B53
	and 00fh
	ret
L_7B60:
	ld (BLAST_SLOT_PTR),hl
	ld (hl),020h		; Type 0x20 and counter 4
	inc l			; Type 0x20 and counter 4: the explosion
	ld (hl),004h
	inc l
	ld (hl),e		; Where it lands
	inc l
	ld (hl),d
	inc l
	inc l
	inc l
	ld (hl),002h
	ld a,(STAGE)
	cp 006h			; Stage 6 has no mirror
	ret z
	ld a,b			; Four minus the slot, times sixteen: its place in BLAST_MIRROR
	sub 004h		; BLAST_MIRROR_PTR keeps the mirror's place
	neg			; Times sixteen: its place in the mirror
	add a,a
	add a,a
	add a,a
	add a,a
	ld hl,BLAST_MIRROR
	add a,l
	ld l,a
	ld (BLAST_MIRROR_PTR),hl
	ld b,010h		; Sixteen bytes to zero
L_7B8A:
	ld (hl),000h
	inc l
	djnz L_7B8A
	xor a
	ret
check_stage_5_collisions:		; Only in stage 5: the nine shots against the four pieces at TURRETS
	ld a,(STAGE)		; Only stage 5
	cp 005h
	ret nz
	ld hl,SHOTS
	ld b,009h		; Nine shots
L_7B9C:
	ld (SHOT_PTR),hl
	push bc
	call one_shot_against_pieces
	pop bc
	ld hl,(SHOT_PTR)
	ld de,00010h		; Sixteen bytes: the next shot
	add hl,de		; Sixteen bytes: the next shot
	djnz L_7B9C
	ret
one_shot_against_pieces:		; Four pieces of eight bytes, with a box of 0x22 by 0x20
	ld a,(hl)
	and a
	ret z
	ld c,a
	exx
	ld de,00008h		; Eight bytes per piece
	exx
	inc l			; The shot's position
	inc l			; The shot's type
	inc l
	ld e,(hl)
	inc l
	inc l
	ld d,(hl)
	ld ix,TURRETS
	ld a,c
	ld c,008h
	cp 003h			; The laser is measured separately
	call z,laser_height_times_eight
	ld b,004h		; Four pieces
L_7BCC:
	ld a,(ix+000h)
	and a
	jr z,L_7BEF
	ld a,(ix+006h)		; Byte 6 at zero: this piece does not count
	and a
	jr z,L_7BEF
	ld a,e
	sub (ix+002h)
	add a,002h
	cp 022h			; 0x22 wide
	jr nc,L_7BEF
	ld a,(ix+003h)
	sub d
	cp c
	jp c,hit_stage_5_piece
	add a,020h		; And 0x20 high
	jp c,hit_stage_5_piece
L_7BEF:
	exx
	add ix,de
	exx
	djnz L_7BCC
	ret
hit_stage_5_piece:		; Gives it the hit drawing, takes life off it and, when it runs out, collects 0x10 and sets up the explosion
	ld a,(ix+000h)
	add a,a			; The type times two minus one
	dec a
	ld (ix+006h),a
	ld hl,(SHOT_PTR)
	ld c,003h
	ld a,(hl)
	cp 003h			; The laser takes three
	jr z,L_7C0C
	ld c,005h
	ld (hl),000h
L_7C0C:
	ld a,(ix+005h)		; Byte 5 is the life
	sub c
	ld (ix+005h),a
	dec a
	jp m,L_7C1C
	ld a,006h		; Sound 6
	jp check_if_sound
L_7C1C:
	ld de,00010h		; Ten points
	call add_to_score
	ld a,00fh		; Sound 0x0F
	call check_if_sound
	ld e,(ix+002h)
	ld d,(ix+003h)
	ld (ix+000h),000h
	jp set_up_background_explosion
dispatch_boss_step:		; BOSS_STATE says whether there is a boss and BOSS_KIND which step it is on: seven exits
	ld hl,BOSS_STATE	; At zero there is no boss
	ld a,(hl)
	dec a
	ret m
	jr z,start_boss
	inc hl
	ld a,(hl)
	call dispatcher

; ----------------------------------------------------------------------
; DATA boss_runners_per_kind: Seven words stuck right after the `call dispatcher`
;   at 0x7C3E.
boss_runners_per_kind:
	defw dispatch_core_step	; 0
	defw run_and_draw_boss	; 1
	defw stage_5_boss_step	; 2
	defw dispatch_boss_step_3	; 3
	defw dispatch_boss_step_4	; 4
	defw run_and_draw_boss_3	; 5
	defw run_and_draw_boss_2	; 6
start_boss:		; Advances the step, sets BOSS_PHASE to zero and leaves 0x1E frames in BOSS_TIMER
	inc (hl)
	xor a
	ld (BOSS_PHASE),a
	ld a,01eh		; 0x1E frames
	ld (BOSS_TIMER),a
	ret
dispatch_boss_step_2:		; Another table of seven, indexed by the same BOSS_KIND
	ld hl,BOSS_STATE	; At zero there is no boss
	ld a,(hl)
	and a
	ret z
	inc hl
	ld a,(hl)
	call dispatcher

; ----------------------------------------------------------------------
; DATA boss_drawers_per_kind: Seven words stuck right after the `call dispatcher`
;   at 0x7C62.
boss_drawers_per_kind:
	defw draw_boss		; 0
	defw draw_eight_pieces	; 1
	defw paint_boss		; 2
	defw do_nothing		; 3
	defw paint_two_pieces	; 4
	defw walk_the_eight	; 5
	defw draw_single_piece	; 6
do_nothing:		; A lone `ret`: the filler entry for tables that have nothing to do at that step
	ret
dispatch_boss_drawing:		; The third table of seven: who saves what is under the boss
	ld hl,BOSS_STATE	; At zero there is no boss
	ld a,(hl)
	and a
	ret z
	inc hl
	ld a,(hl)
	call dispatcher

; ----------------------------------------------------------------------
; DATA dispatcher_table_7C7C: Seven words stuck right after the `call dispatcher`
;   at 0x7C7C.
dispatcher_table_7C7C:
	defw erase_boss		; 0
	defw save_under_the_eight	; 1
	defw start_erasing_boss	; 2
	defw do_nothing		; 3
	defw erase_two_pieces	; 4
	defw save_under_the_eight	; 5
	defw save_under_e780	; 6
dispatch_core_step:		; Five steps, counted in BOSS_PHASE
	ld a,(BOSS_PHASE)
	call dispatcher

; ----------------------------------------------------------------------
; DATA core_boss_steps: Five words stuck right after the `call dispatcher`
;   at 0x7C90.
core_boss_steps:
	defw wait_until_nobody_left	; 0
	defw core_enters	; 1
	defw core_waits		; 2
	defw blow_up_core	; 3
	defw end_boss		; 4

	end

; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - demo.asm
; ============================================================================

	public add_speed,release_what_is_due,run_background_objects,run_demo,run_twelve_objects,start_demo
	public turn_off_object
	extrn add_a_to_hl,aim_cannon,check_map_collision_2,check_pause_key,dispatcher,get_word
	extrn L_71B0,move_type_0A,move_type_0B,move_type_0C,move_type_0D,move_type_1A
	extrn move_type_1B,move_type_1D,move_type_1E,move_type_1F,move_type_2,move_type_3
	extrn move_type_4,move_type_5,move_type_6,move_type_8,move_type_9,move_types_17_and_18
	extrn move_with_scroll_eight,run_object,run_stage_5_background,set_up_due_stage,write_captions

; ----------------------------------------------------------------------
; THE DEMO PLAYS ITSELF BY READING A RECORDING OF THE JOYSTICK
; The demo is not played by any clever machine: it is a RECORDING. In bank
; 12 there is, per stage, a list of pairs [how many frames][what the
; joystick reads], and 0x5CDA reads through it: 0xE00B counts the frames
; left and 0xE00C holds the joystick value, which 0x5CCF puts in 0xE009
; (the same byte where 0x5767 leaves what it reads from the real
; joystick), as well as turning on bit 4, which is fire. So the demo ship
; ALWAYS fires and moves the way the tape says.
; And it starts fully powered: 0x5CB8 calls 0xA0D8, which is the same
; thing the HYPER cheat gives.
; ----------------------------------------------------------------------
start_demo:		; Picks the stage that is due (0xE006 wraps at eight), sets it up with all the power-ups and leaves it ready to play itself
	xor a
	ld (0e009h),a
	ld (0e007h),a
	inc a
	ld (0e05fh),a		; 0xE05F to one: the flag that says a demo is running
	ld hl,0e006h		; 0xE006 holds which stage the demo is on
	ld a,(hl)
	ld (0e061h),a
	inc a
	cp 009h			; Eight stages and back to the first
	jr c,L_5CA1
	ld a,001h
L_5CA1:
	ld (hl),a
	ld hl,00020h		; 0x20 of distance covered
	ld (0e063h),hl
	ld hl,00001h		; 0xE00B to one: the first step of the recording goes in straight away
	ld (0e00bh),hl
	xor a
	ld (0e00dh),a
	ld (0e06ah),a
	call set_up_due_stage
	call 0a0d8h		; And all the power-ups at once, like the HYPER cheat
	jp write_captions
run_demo:		; While it lasts, takes the joystick value from the recording and passes it to the game as if someone had pressed it
	ld a,(0e064h)		; With 0xE064 set, the demo is cut short
	and a
	jr z,L_5CC9
	xor a
	ld (0e05fh),a
	ret
L_5CC9:
	ld hl,0e00bh		; 0xE00B: the frames left in this step
	dec (hl)
	jr z,next_recording_step
feed_recorded_controller:		; The recorded value goes to 0xE009, with bit 4 (fire) always set
	ld a,(0e00ch)
	or 010h			; Bit 4: in the demo it fires non-stop
	ld (0e009h),a
	jp check_pause_key
next_recording_step:		; Maps banks 11 and 12, takes the next pair from the stage's list and leaves it in 0xE00B and 0xE00C
	inc hl
	inc hl
	ld c,(hl)		; 0xE00D says which pair it is on
	inc (hl)
	di			; Banks 11 and 12: the recordings are there
	ld a,00bh
	ld (08000h),a
	ld (0f0f2h),a
	ei
	di
	ld a,00ch
	ld (0a000h),a
	ld (0f0f3h),a
	ei
	ld a,(0e061h)
	ld hl,05D1Dh		; The table at 0x5D1D, indexed by the stage
	call get_word
	ld l,c
	ld h,000h
	add hl,hl		; Times two: each step is two bytes
	add hl,de
	ld a,(hl)		; The first, the frames it lasts
	ld (0e00bh),a
	inc hl
	ld a,(hl)		; And the second, what the joystick reads
	ld (0e00ch),a
	di			; 2 and 3 restored
	ld a,002h
	ld (08000h),a
	ld (0f0f2h),a
	ei
	di
	ld a,003h
	ld (0a000h),a
	ld (0f0f3h),a
	ei
L_5D1D:
	jr feed_recorded_controller

; ----------------------------------------------------------------------
; DATA ends_per_stage (part): Words that 0x5CF5 indexes with the stage
;   (0x47AE), with the base 0x5D1D: 0xA878, 0xA942, 0xAA92, 0xAC34, 0xAD94,
;   0xAF54, 0xB078 and 0xB13A, all of them in bank 3.
ends_per_stage_5D1F:
	defw 0A878h,0A942h
	defw 0AA92h,0AC34h
	defw 0AD94h,0AF54h
	defw 0B078h,0B13Ah
	defw 613Ah,0FEE0h
	defw 0D809h,57CDh
	defw 285Dh,0D8F5h
	defw 2721h,34E1h
	defw 0EE18h
release_what_is_due:		; From the ninth stage onwards, and only on the steps with a new column, releases whatever the script says until it runs out
	ld a,(0e061h)
	cp 009h			; Below the ninth, no
	ret c
	ld a,(0e100h)		; And only on the steps that bring in a column
	and a
	ret z
	ld a,0f8h		; 0xF8 in 0xEC04
	ld (0ec04h),a
L_5D51:
	call release_one
	jr z,L_5D51
	ret
release_one:		; Checks whether something is due to be released here; if so, takes the position and the type from the script and calls the engine in bank 1
	call check_stage_script
	ret nz
	ld hl,0e127h		; 0xE127 moves on to the next row of the script
	inc (hl)
	ld a,c
	and 0f8h		; The five high bits: the Y
	ld e,a
	ld a,(0ec04h)
	ld d,a
	ld a,c
	and 003h
	bit 2,c			; Bit 2 chooses between two types
	jp z,L_5D79
	add a,003h
	ld c,a
	add a,013h
L_5D74:
	call 06a72h
	xor a
	ret
L_5D79:
	add a,003h
	ld c,a
	ld a,019h
	jp L_5D74
check_stage_script:		; With banks 11 and 12, looks in the stage script for the row that matches the distance covered and compares it
	di
	ld a,00bh		; Banks 11 and 12: the scripts are there
	ld (08000h),a
	ld (0f0f2h),a
	ei
	di
	ld a,00ch
	ld (0a000h),a
	ld (0f0f3h),a
	ei
	ld hl,0b2d2h		; The table at 0xB2D2, indexed by the stage
	ld a,(0e061h)
	call get_word
	push de
	ld a,(0e127h)		; 0xE127: which row of the script it is on
	ld h,a
	ld e,003h		; Three bytes per row
	call 06743h
	pop de
	add hl,de
	ld c,(hl)		; The first, the type; the other two, the distance
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	di			; 2 and 3 restored
	ld a,002h
	ld (08000h),a
	ld (0f0f2h),a
	ei
	di
	ld a,003h
	ld (0a000h),a
	ld (0f0f3h),a
	ei
	ld hl,(0e063h)		; DCOMPR: the distance covered against the row's
	rst 20h
	ret
run_twelve_objects:		; The twelve objects at 0xE300, 0x20 bytes apart: each one gets its mover routine and then 0x5F66
	ld ix,0e300h
	ld b,00ch		; Twelve objects
L_5DCE:
	push bc
	call dispatch_object_mover
	call check_object_gone
	pop bc
	ld de,00020h		; Thirty-two bytes per object
	add ix,de
	djnz L_5DCE
	ret
dispatch_object_mover:		; The first byte says what the object is; with the screen stopped (0xE1C0) there are three cases, and otherwise the table of thirty-one
	ld c,(ix+000h)
	ld a,(0e1c0h)		; 0xE1C0 non-zero: the screen is stopped
	and a
	jp z,L_5DF6
	ld a,c
	cp 001h
	jp z,aim_cannon
	cp 015h
	jp z,animate_four_drawings
	jp move_with_scroll_eight
L_5DF6:
	ld a,c
	and a
	ret z			; Type 0 is the empty slot
	dec a
	call dispatcher

; ----------------------------------------------------------------------
; DATA dispatcher_table_5DFA: Thirty-one words right behind the `call 0x4067`
;   at 0x5DFA. It is the largest table in the cartridge, and almost all of its
;   destinations are in ANOTHER bank: it sends to 0x8000 and 0xA000, that is,
;   to banks 2 and 3.
dispatcher_table_5DFA:
	defw aim_cannon		; 0
	defw move_type_2	; 1
	defw move_type_3	; 2
	defw move_type_4	; 3
	defw move_type_5	; 4
	defw move_type_6	; 5
	defw move_hatch_enemy	; 6
	defw move_type_8	; 7
	defw move_type_9	; 8
	defw move_type_0A	; 9
	defw move_type_0B	; 10
	defw move_type_0C	; 11
	defw move_type_0D	; 12
	defw check_map_collision	; 13
	defw check_map_collision_2	; 14
	defw L_71B0		; 15
	defw L_5E3B		; 16
	defw L_5E3B		; 17
	defw L_5E3B		; 18
	defw animate_four_characters	; 19
	defw animate_four_drawings	; 20
	defw L_5E3B		; 21
	defw move_types_17_and_18	; 22
	defw move_types_17_and_18	; 23
	defw L_5E3B		; 24
	defw move_type_1A	; 25
	defw move_type_1B	; 26
	defw check_map_collision	; 27
	defw move_type_1D	; 28
	defw move_type_1E	; 29
	defw move_type_1F	; 30
L_5E3B:
	jp 09251h
animate_four_drawings:		; The object's first sixteen frames cycle through the four character-and-colour pairs at 0x5E5D
	ld a,(ix+002h)
	inc (ix+002h)		; One more frame for this object
	cp 010h			; Past sixteen, the animation is over
	jr nc,object_to_explosion
	rra			; Skipping one bit: each drawing lasts two frames
	and 006h
	ld hl,05e5dh
	call add_a_to_hl
	ld a,(hl)
	ld (ix+00ch),a		; The character in byte 12 and the colour in 13
	inc hl
	ld a,(hl)
	ld (ix+00dh),a
	jp 09251h

; ----------------------------------------------------------------------
; DATA characters_of_5E4B: Eight bytes that 0x5E4B indexes with (A AND 6) and
;   puts in (IX+0x0C).
characters_of_5E4B:
	defb 78h,0Fh,7Ch,09h,80h,06h,84h,0Dh
object_to_explosion:		; Turns the object into an explosion: gives it type 0x12 or 0x13 and its character, and snaps its X and Y to the grid
	ld a,(ix+011h)		; Byte 17 says whether the object belongs to a group
	and a
	jr z,L_5E88
	ld a,(ix+012h)
	call find_group		; The group is looked up in the table at 0xE900
	jp c,turn_off_object
	ld a,(hl)
	inc l
	inc l
	dec (hl)		; The group's count goes down; until it reaches zero, it does not blow up
	jp nz,turn_off_object
	dec l
	dec l
	ld (hl),000h
	and 007h
	ld a,012h
	jr nz,L_5E95
	inc a
	jr L_5E95
L_5E88:
	ld a,(ix+00eh)		; Without a group, byte 14 decides
	and a
	jp z,turn_off_object
	dec a
	ld a,012h
	jr z,L_5E95
	inc a
L_5E95:
	ld (ix+000h),a		; Type 0x12 or 0x13: the two explosion sizes
	add a,00fh
	ld (ix+00ch),a
	ld (ix+00bh),001h	; Byte 11 to one: it is drawn with characters
	ld (ix+01bh),001h
	ld a,(ix+004h)		; The Y, snapped to eight, plus four
	and 0f8h
	add a,004h
	ld (ix+004h),a
	ld a,(ix+006h)		; And the X, snapped to eight
	and 0f8h
	ld (ix+006h),a
	jp 09251h
find_group:		; Walks the four three-byte entries at 0xE900 looking for group A; exits with carry if it is not there
	ld hl,0e900h
	ld b,004h		; Four groups
L_5EBF:
	cp (hl)
	ret z
	inc l			; Three bytes per group
	inc l
	inc l
	djnz L_5EBF
	scf
	ret
animate_four_characters:		; The first sixteen frames, a character from 0x5EE3 every four; after that, the object blows up
	ld a,(ix+002h)
	inc (ix+002h)
	cp 010h			; Past sixteen, on to exploding
	jr nc,object_to_explosion
	rra			; Skipping two bits: each drawing lasts four frames
	rra
	and 003h
	ld hl,05ee3h
	call add_a_to_hl
	ld a,(hl)
	ld (ix+00ch),a
	jp 09251h

; ----------------------------------------------------------------------
; DATA characters_of_5ED6: Four bytes (0xF0, 0xF4, 0xF8, 0xFC) that 0x5ED6
;   indexes with (A AND 3).
characters_of_5ED6:
	defb 0F0h,0F4h,0F8h,0FCh
move_hatch_enemy:		; Every four frames changes drawing, moves with the screen and, when the ship crosses its row, turns
	ld a,(0e003h)
	and 003h		; One frame in four
	jr nz,L_5F00
	inc (ix+002h)
	ld a,(ix+002h)
	and 007h		; Eight drawings, round and round
	ld hl,05f47h
	call add_a_to_hl
	ld a,(hl)
	ld (ix+00ch),a
L_5F00:
	ld a,(ix+001h)
	and a
	ret nz
	ld a,(0e100h)		; On the steps with a new column, it moves eight points to the left
	and a
	jr z,L_5F13
	ld a,(ix+006h)
	sub 008h
	ld (ix+006h),a
L_5F13:
	ld a,(0e204h)		; 0xE204 is the ship's row, and bit 7 of byte 8 the sign of its vertical speed
	bit 7,(ix+008h)
	jr nz,L_5F22
	cp (ix+004h)
	ret nc
	jr enemy_turns
L_5F22:
	cp (ix+004h)
	ret c
enemy_turns:		; Stops going up or down (the speed in bytes 7 and 8 to zero) and takes 0xFC00 horizontally: it launches itself at the ship
	inc (ix+001h)
	xor a
	ld (ix+007h),a
	ld (ix+008h),a
	ld hl,0fc00h		; 0xFC00 in bytes 9 and 10: four points per frame to the left
	ld (ix+009h),l
	ld (ix+00ah),h
	ld a,(0e066h)		; 0xE066 is the stages played: from the second loop onwards, it fires when it turns
	and a
	ret z
	ld e,(ix+004h)
	ld d,(ix+006h)
	jp 06613h

; ----------------------------------------------------------------------
; DATA animation_of_5EF6: Eight bytes (4,5,6,7,8,7,6,5) that 0x5EF6 indexes
;   with the counter (IX+2) AND 7: the back-and-forth of an animation.
animation_of_5EF6:
	defb 04h,05h,06h,07h,08h,07h,06h,05h
check_map_collision:		; Passes the object's X and Y to bank 2, with a correction of eight depending on bit 0 of byte 8
	ld l,(ix+004h)
	ld h,(ix+006h)
	bit 0,(ix+008h)		; Bit 0 of byte 8 says whether the Y has to be shifted
	jr nz,L_5F5F
	ld a,008h
	add a,l
	ld l,a
L_5F5F:
	call 09857h
	ret nc
	jp turn_off_object
check_object_gone:		; Types 2 to 0x10 and 0x1B to 0x1D add their speed and, if they go off the screen, are turned off
	ld a,(ix+000h)
	cp 002h			; Types 0 and 1 do not move this way
	ret c
	cp 01eh			; And neither does 0x1E
	ret z
	cp 011h			; Nor do 0x11 to 0x1A
	jr c,L_5F76
	cp 01bh
	ret c
L_5F76:
	call add_speed
	jr nc,turn_off_object
	ret
add_speed:		; Adds the object's two 16-bit speeds to it and returns whether it is still inside the screen
	push ix
	pop hl
	inc l			; Bytes 3 and 4: the 16-bit Y
	inc l
	inc l
	ld d,h
	ld e,l
	inc e			; And 7 and 8: its speed
	inc e
	inc e
	inc e
	call add_word
	call add_word
	ld a,(ix+004h)		; Past Y 0xB0 or X 0xF9, the object is gone
	cp 0b0h
	ret nc
	ld a,(ix+006h)
	cp 0f9h
	ret
add_word:		; Adds two bytes from DE onto the two at HL, with carry
	ld a,(de)		; The low byte...
	add a,(hl)
	ld (hl),a
	inc l
	inc e
	ld a,(de)		; ...and the high one with the carry
	adc a,(hl)
	ld (hl),a
	inc l
	inc e
	ret
turn_off_object:		; Frees the slot and lowers the count of live objects; if it was in a group, lowers the group's count too
	ld a,(ix+000h)
	cp 01eh			; Type 0x1E takes up three slots
	jr z,turn_off_three_slots
	ld hl,0e126h		; 0xE126 keeps the count of live objects
	dec (hl)
	xor a
	ld (ix+000h),a
	ld (ix+01bh),a
	bit 0,(ix+011h)		; Bit 0 of byte 17: it belongs to a group
	ret z			; Bit 0 of byte 17: the object was in a group
	ld a,(ix+012h)
	call find_group		; Its group is looked up in the table at 0xE900
	ret c
	inc l			; The group's count goes down
	dec (hl)
	ret nz
	dec l
	ld (hl),000h		; And on reaching zero, the group is closed
	ret
turn_off_three_slots:		; The big type 0x1E object takes up three consecutive slots: all three are turned off and the count drops by three
	ld hl,0e126h
	dec (hl)
	dec (hl)
	dec (hl)
	push ix
	pop iy
	ld de,00020h		; Thirty-two bytes: the next slot
	ld b,003h		; Three slots
	xor a
L_5FDA:
	ld (iy+000h),a
	ld (iy+01bh),a
	add iy,de
	djnz L_5FDA
run_background_objects:		; Stage 5 has its own engine in bank 3; the others walk eight or two objects at 0xE700
	ld a,(0e061h)
	cp 005h			; Stage 5 goes another way
	jp z,run_stage_5_background
	ld ix,0e700h
	ld a,(0e061h)
	cp 003h			; Stage 3 has eight; the others, two
	ld b,008h
	jr z,L_5FFB
	ld b,002h
L_5FFB:
	push bc
	call run_object
	pop bc

; Bank 1 (runs at 0x6000).
;
; This bank is WELDED to its neighbours on both sides, and that is not a
; figure of speech:
;
;   - above, the code of bank 0 falls through from 0x5FFF to 0x6000. The loop
;     that starts at p00:5FFB (`push bc / call 0x6008 / pop bc`) ends right
;     here, at 0x6000-0x6007, with the `ld de,0x0008 / add ix,de / djnz /
;     ret`.
;   - below, the LAST INSTRUCTION OF THE BANK IS SPLIT. At 0x7FFE there is
;     `21 41` and the third byte, the 0x80, is the first byte of bank 2:
;     together they make `ld hl,0x8041`, and execution carries on at 0x8001.
;     It is the only place in the cartridge where this happens (see the
;     end of boss.asm).

; ----------------------------------------------------------------------
; THE BANK STARTS IN THE MIDDLE OF A LOOP
; ----------------------------------------------------------------------
end_of_bank_0_loop:		; The loop that starts at p00:5FFB ends here. The code crosses the bank boundary.
	ld de,00008h
	add ix,de
	djnz L_5FFB
	ret

	end

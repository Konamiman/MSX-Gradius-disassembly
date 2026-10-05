; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - bosses.asm
; ============================================================================

	include "variables.inc"

	include "screens_symbols.inc"
	public aim_both_turrets,card_position,dispatch_boss_step_3,dispatch_boss_step_4,draw_eight_pieces,draw_piece_at_e9a0
	public draw_single_piece,erase_one_piece,erase_two_pieces,paint_boss,paint_two_pieces,run_and_draw_boss
	public run_and_draw_boss_2,run_and_draw_boss_3,run_five_at_e7a0,run_piece_at_e9a0,run_six_pieces,shot_origin
	public start_erasing_boss,table_8041
	extrn add_a_to_de,add_a_to_hl,add_to_score,change_sign,clear_rectangle,copy_rectangle
	extrn dispatcher,enemy_shoots,get_word,mark_boss_dead,measure_distance_to_ship,multiply_h_by_e
	extrn next_core_step,set_up_background_explosion,spawn_object,step_0_two_left,step_10_towards_ship,step_11_leaves
	extrn step_1_diagonal,step_2_two_left,step_3_diagonal_up,step_4_two_left,step_5_diagonal,step_6_two_left
	extrn step_7_diagonal_up,step_8_two_down,step_9_two_right,switch_off_screen

; (The last instruction of boss.asm falls through into here.)

; ----------------------------------------------------------------------
; THE BANK OF THE BOSSES AND OF COLLISIONS WITH THE MAP
; This bank holds the mover routines of the stage bosses, the routine that
; says whether a point collides with the map, and a good part of the
; drawing. It starts in an odd way: the first instruction is NOT entirely
; here; its first two bytes are the last ones of bank 1.
; ----------------------------------------------------------------------
continued_from_bank_1:		; This is where the split instruction that starts at p01:7FFE continues.
	add hl,bc		; HL arrives here from bank 1
	ld a,(hl)
	exx
	ld c,a			; The byte is kept in the alternate C
	exx
	ld de,BOSS_PIECES+BOSS_PIECE_SIZE	; This and 0xE7C0: if the boss is already set up, it is not set up again
	ld a,(de)
	and a
	jr z,L_8013
	ld de,BOSS_PIECES+4*BOSS_PIECE_SIZE
	ld a,(de)
	and a
	ret nz
L_8013:
	ld hl,table_8041+10h	; Ten bytes from 0x8051 to the card
	ld bc,0000ah
	ldir
	ld a,006h
	call add_a_to_de
	exx
	bit 0,c			; Bit 0 of C: the first piece
	exx
	push de
	call nz,L_8038
	pop de
	ld a,010h
	call add_a_to_de
	exx
	bit 1,c			; And bit 1: the second
	exx
	ret z
	ld hl,table_8041+26h
	jr L_803B
L_8038:
	ld hl,table_8041+1Ah
L_803B:
	ld bc,0000ch		; Twelve bytes of card
	ldir
	ret

; ----------------------------------------------------------------------
; DATA table_8041: Fifty bytes pointed to by the `ld hl,0x8041` of the split
;   instruction: it is the first thing the code loads on entering this bank.
table_8041:
	defb 02h,01h,01h,02h,03h,02h,01h,03h,03h,03h,03h,03h,03h,03h,03h,03h
	defb 03h,00h,00h,40h,00h,0F0h,00h,00h,0Ah,7Fh,04h,00h,00h,00h,00h,00h
	defb 21h,18h,06h,10h,06h,06h,04h,00h,00h,00h,00h,00h,16h,14h,06h,10h
	defb 20h,20h
run_five_at_e7a0:		; The five slots at 0xE7A0; only the type 4 ones do anything
	ld ix,BOSS_PIECES+2*BOSS_PIECE_SIZE
	ld b,005h		; Five slots
L_8079:
	push bc
	ld a,(ix+000h)
	cp 004h			; Type 4
	call z,fire_piece_shot
	pop bc
	ld de,00010h		; Sixteen bytes: the next slot
	add ix,de
	djnz L_8079
	ret
fire_piece_shot:		; Every so many frames (fewer the harder it is) fires a shot from wherever the table at piece_shot_origins says
	dec (ix+007h)
	ret nz
	ld a,01bh		; 0x1B minus the difficulty, divided by two: the frames between shots
	ld hl,DIFFICULTY
	sub (hl)
	sra a
	ld (ix+007h),a
	ld a,(ix+006h)
	ld hl,piece_shot_origins	; The table at piece_shot_origins: where each drawing's shot comes out from
	call get_word
	ld a,(ix+003h)
	add a,e
	ld e,a
	ld a,(ix+005h)
	add a,d
	ld d,a
	jp enemy_shoots		; And bank 1 sets it up

; ----------------------------------------------------------------------
; DATA piece_shot_origins: Eighty bytes read by 0x809D.
piece_shot_origins:
	defb 0F8h,04h,0F8h,0Eh,0F8h,0Eh,0FCh,10h,0FAh,18h,02h,28h,03h,28h,00h,28h
	defb 00h,30h,08h,30h,29h,06h,29h,0Dh,29h,0Dh,24h,0Fh,1Eh,18h,0Eh,28h
	defb 06h,28h,00h,28h,00h,30h,0F8h,30h,29h,09h,29h,02h,29h,02h,24h,00h
	defb 1Eh,00h,0Eh,00h,06h,00h,00h,00h,00h,00h,0F8h,00h,0F8h,0Ah,0F8h,02h
	defb 0F8h,02h,0FCh,00h,0FCh,00h,02h,00h,02h,00h,0Ch,00h,00h,00h,08h,00h
run_six_pieces:		; The six slots at 0xE790: each with its mover routine according to its type
	ld ix,BOSS_PIECES+BOSS_PIECE_SIZE
	ld b,006h		; Six slots
L_8106:
	push bc
	call piece_step
	pop bc
	ld de,00010h		; Sixteen bytes: the next slot
	add ix,de
	djnz L_8106
	ret
piece_step:		; Types 3 and up: 3 withdraws, and the others turn towards the drawing that is due to them
	ld a,(ix+000h)
	sub 003h		; Below type 3 it does nothing
	ret m
	jr z,withdraw_piece	; Type 3 withdraws
	dec (ix+008h)
	ret nz
	ld a,r			; The R register: five to eight frames per step
	and 003h
	add a,005h
	ld (ix+008h),a
	ld c,001h
	ld a,(ix+00ah)		; Byte 10 is the current drawing and 11 the one it wants to reach
	cp (ix+00bh)
	ret z
	jr c,L_8135
	ld c,0ffh
L_8135:
	add a,c			; One step towards it, up or down
	ld (ix+00ah),a
	ld hl,ramp_81AD		; The ramp at ramp_81AD: the real drawing
	call add_a_to_hl
	ld a,(hl)
	ld (ix+006h),a
	ret
withdraw_piece:		; It keeps rising and moving away from the ship, changing drawing, until it leaves through the top
	dec (ix+00ah)
	bit 4,(ix+00ah)		; Bit 4 of the counter: alternates the drawing
	ld c,001h
	jr nz,L_8150
	dec c
L_8150:
	ld a,(ix+001h)
	cp 002h			; From step 2 onwards, without alternating
	jr c,L_8159
	ld c,000h
L_8159:
	add a,a
	add a,c
	ld (ix+006h),a
	dec (ix+008h)
	ret nz
	ld (ix+008h),00ah	; Ten frames per step
	ld a,(ix+005h)
	sub 008h		; Eight points higher
	cp 010h			; Above Y 0x10 it is over
	jr c,switch_off_piece
	ld (ix+005h),a
	ld a,(ix+003h)
	ld c,a
	add a,010h
	ld hl,SHIP_ROW		; Towards where the ship is
	cp (hl)
	jr nc,L_8191
	ld a,(ix+020h)		; Byte 32 says how far it can go
	and a
	ld b,090h
	jr z,L_8188
	ld b,04eh
L_8188:
	ld a,008h		; Eight to the right
	add a,c			; Eight to the right
	cp b			; With a limit on the right
	ret nc
	ld (ix+003h),a
	ret
L_8191:
	ld a,(ix+010h)
	and a
	jr z,L_8199
	ld b,038h
L_8199:
	ld a,0f8h		; Or eight to the left
	add a,c			; Byte 16: how far it gets
	cp b			; With a limit
	ret c
	ld (ix+003h),a
	ret
switch_off_piece:		; The slot and its two marks, zeroed
	xor a
	ld (ix+000h),a
	ld (ix+010h),a
	ld (ix+020h),a
	ret

; ----------------------------------------------------------------------
; DATA ramp_81AD: Forty bytes read by 0x8139: a downward slope (0x27, 0x26,
;   0x25, ...) followed by an upward slope.
ramp_81AD:
	defb 27h,26h,25h,24h,23h,22h,21h,20h,1Fh,1Eh,00h,01h,02h,03h,04h,05h
	defb 06h,07h,08h,09h,13h,12h,11h,10h,0Fh,0Eh,0Dh,0Ch,0Bh,0Ah,14h,15h
	defb 16h,17h,18h,19h,1Ah,1Bh,1Ch,1Dh
aim_both_turrets:		; The two pieces at 0xE790 and 0xE7C0 look towards the ship: the angle chooses the turret's drawing
	ld ix,BOSS_PIECES+BOSS_PIECE_SIZE
	call aim_one_turret
	ld ix,BOSS_PIECES+4*BOSS_PIECE_SIZE
aim_one_turret:		; Measures where the ship is and, with the angle, takes from the table the drawing due to each turret
	ld a,(ix+000h)
	and a
	ret z
	ld e,(ix+003h)		; The position of the piece
	ld d,(ix+005h)
	call measure_distance_to_ship	; Bank 1 measures the angle to the ship
	call aim_the_other
	ld a,(ix+020h)		; Byte 32: the second turret
	and a
	ret z
	bit 6,(ix+00ah)		; Bit 6 of the drawing: if it is turned, it does not aim
	jr z,L_8209
	ld hl,turret_drawings_A	; The table at turret_drawings_A
	call angle_drawing	; The turret's drawing
	ld (ix+02bh),c		; The drawing is stored
	call is_in_angle
	ret nc
L_8209:
	ld (ix+02bh),01dh
	ret
aim_the_other:		; The same for the turret of byte 16, with the table at turret_drawings_B
	ld a,(ix+010h)
	and a
	ret z
	bit 6,(ix+00ah)
	jr nz,L_8226
	ld hl,turret_drawings_B	; The table at turret_drawings_B
	call angle_drawing
	ld (ix+01bh),c
	call is_in_angle
	ret nc
L_8226:
	ld (ix+01bh),00ah
	ret
is_in_angle:		; Above Y 0x40, and with the drawing between 0x0A and 0x1E, the turret can aim
	ld a,(ix+005h)
	cp 040h			; Above Y 0x40, no
	ret nc
	ld a,c
	sub 00ah		; And the drawing has to fall between 0x0A and 0x1E
	cp 014h
	ccf
	ret
angle_drawing:		; The angle at SHIP_ANGLE divided by eight indexes the table, and the R register adds a nudge of minus one to one
	ld a,(SHIP_ANGLE)	; The angle to the ship
	rra			; Divided by eight: thirty-two steps
	rra
	rra
	and 01fh
	call add_a_to_hl
	ld a,r			; The R register again: minus one, zero or one of jitter
	and 003h		; The table, indexed by the angle
	dec a
	cp 002h
	jr nz,L_824D
	xor a
L_824D:
	add a,(hl)
	ld c,a
	ret

; ----------------------------------------------------------------------
; DATA turret_drawings_A: Thirty-two drawings, one per eighth of angle: the
;   ones the turret at 0xE7C0 shows depending on where it points. Read by
;   0x81FC.
turret_drawings_A:
	defb 15h,16h,18h,19h,1Ah,1Bh,1Ch,1Ch,1Fh,1Fh,20h,21h,22h,23h,25h,26h
	defb 26h,26h,26h,26h,24h,25h,24h,23h,18h,17h,16h,17h,15h,15h,15h,15h

; ----------------------------------------------------------------------
; DATA turret_drawings_B: The other thirty-two, those of the turret of byte
;   16. Read by 0x8219.
turret_drawings_B:
	defb 12h,12h,12h,12h,10h,11h,12h,11h,03h,02h,04h,02h,01h,01h,01h,01h
	defb 01h,02h,04h,05h,06h,07h,08h,08h,0Bh,0Bh,0Ch,0Dh,0Eh,0Fh,11h,12h
start_erasing_boss:		; PAINT_FLAG to zero: what follows erases instead of painting
	xor a
	jr draw_six_pieces
paint_boss:		; PAINT_FLAG to one: what follows paints
	ld a,001h
draw_six_pieces:		; With bank 10 in place, positions the turrets and then draws the six slots at 0xE790
	ld (PAINT_FLAG),a
	di
	ld a,00ah		; Bank 10 at 0xA000: the drawings are there
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	call place_turrets
	di
	ld a,003h		; Bank 3 put back
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	ld ix,BOSS_PIECES+BOSS_PIECE_SIZE
	ld b,006h		; Six slots
L_82B5:
	push bc
	call draw_one_piece
	ld de,00010h		; Sixteen bytes: the next one
	add ix,de
	pop bc
	djnz L_82B5
	ret
erase_one_piece:		; PAINT_FLAG to zero, and erase
	xor a
	ld (PAINT_FLAG),a
draw_one_piece:		; Takes from bank 10 the width, the height and the characters of the drawing, and paints or erases it
	ld a,(ix+000h)
	sub 003h		; Below type 3 there is nothing
	ret m
	ld hl,type_3_piece_drawings	; Type 3 uses the table at type_3_piece_drawings; the others, the one at 0xAAB0
	jr z,L_82D4
	ld hl,data_AAB0
L_82D4:
	di
	ld a,00ah		; Bank 10 at 0xA000
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	ld a,(ix+006h)
	call get_word
	ex de,hl
	ld b,(hl)		; The width and the height
	inc hl
	ld c,(hl)
	inc hl
	inc hl
	ex de,hl
	ld l,(ix+003h)		; Where it lands
	ld h,(ix+005h)
	ld a,(PAINT_FLAG)	; Decides: erase or paint
	and a
	push af
	call z,clear_rectangle
	pop af
	call nz,copy_rectangle
	di
	ld a,003h		; Bank 3 put back
	ld (0a000h),a		; Bank 3 put back
	ld (BANK_A000),a	; Bank 3 put back
	ei
	ret
place_turrets:		; For the two pieces at 0xE790 and 0xE7C0, works out where their two turrets go
	ld ix,BOSS_PIECES+BOSS_PIECE_SIZE
	call place_both_turrets_of_one
	ld ix,BOSS_PIECES+4*BOSS_PIECE_SIZE
place_both_turrets_of_one:		; The drawing's width times eight gives the X offset, and the table at turret_offset the Y one
	ld a,(ix+000h)
	and a
	ret z
	ld a,(ix+006h)
	ld hl,type_3_piece_drawings	; The table at type_3_piece_drawings: the size of each drawing
	call get_word
	ex de,hl
	inc hl
	ld a,(hl)
	add a,a			; The width times eight
	add a,a
	add a,a
	ld b,a
	inc hl
	ld c,(hl)
	ld a,(ix+010h)		; Byte 16: the first turret
	and a
	call nz,place_first_turret
	ld a,(ix+020h)		; And byte 32: the second
	and a
	ret z
	ld a,(ix+026h)
	ld hl,turret_offset	; The table at turret_offset: how far it shifts in Y
	call add_a_to_hl	; The table at turret_offset
	ld a,(hl)		; The offset in Y
	add a,(ix+005h)
	add a,c
	ld (ix+025h),a
	ld a,(ix+003h)
	add a,b
	ld (ix+023h),a
	ret
place_first_turret:		; The same, but subtracting: this one goes on the other side
	ld hl,data_AAB0		; The table at data_AAB0
	ld a,(ix+016h)
	call get_word
	inc de
	ld a,(de)
	add a,a			; The width times eight
	add a,a
	add a,a
	neg			; Negative: the turret goes on the other side
	add a,(ix+003h)
	ld (ix+013h),a
	ld hl,turret_offset	; The table at turret_offset
	ld a,(ix+016h)
	call add_a_to_hl
	ld a,(hl)
	add a,(ix+005h)
	add a,c
	ld (ix+015h),a
	ret

; ----------------------------------------------------------------------
; DATA turret_offset: Forty bytes, one per drawing: how far the turret shifts
;   in Y relative to the centre of the piece. Read by 0x8339 and 0x8365.
turret_offset:
	defb 0F8h,0F8h,0F8h,00h,00h,00h,00h,00h,00h,00h
	defb 0F8h,0F8h,0F8h,00h,00h,00h,00h,00h,00h,00h
	defb 0F8h,0F8h,0F8h,0F0h,0E8h,0D8h,0D8h,0D8h,0D0h,0D0h
	defb 0F8h,0F8h,0F8h,0F0h,0E8h,0D8h,0D8h,0D8h,0D0h,0D0h
run_and_draw_boss:		; One step of the boss and its drawing
	call boss_step		; One step and its drawing
	jp run_eight_pieces
run_and_draw_boss_2:		; The same with the other pair of routines
	call start_or_end_boss
	jp run_one_piece
start_or_end_boss:		; On step 0 sets up the first piece, and from then on waits for BOSS_PIECES to switch off
	ld a,(BOSS_PHASE)
	or a
	jr nz,L_83C8
	ld hl,BOSS_PIECES
	call set_up_piece_card	; Sets up the piece's card
	ld a,004h		; Type 4
	ld (de),a
	ld a,e
	sub 004h
	ld e,a
	ld a,0f0h		; 0xF0 in Y
	ld (de),a
	dec e
	ld a,03ch		; And 0x3C frames
	ld (de),a
	jp next_core_step
L_83C8:
	ld hl,BOSS_PIECES
	ld a,(hl)		; With BOSS_PIECES at zero, the boss is over
	or a
	ret nz
	jp mark_boss_dead
boss_step:		; On step 0 works out how long it lasts and how often it releases a piece, all from the difficulty
	ld a,(BOSS_PHASE)
	dec a
	jr z,release_a_piece
	jp p,check_boss_over
	ld a,(DIFFICULTY)	; The difficulty plus 0x14...
	add a,014h
	ld h,a
	ld e,01eh		; ...times 0x1E: the frames the boss lasts
	call multiply_h_by_e
	ld (BOSS_TIMER),hl
	ld a,(DIFFICULTY)	; And 0x3C minus twice the difficulty: the frames between one piece and the next
	add a,a			; The frames between one piece and the next
	sub 03ch
	neg
	ld hl,PIECE_TIMER
	ld (hl),a
	inc l
	ld (hl),a
	inc l
	ld (hl),000h		; PIECE_PREV_HEIGHT to zero
	ld hl,00000h		; HEIGHT_PIECES, 0xE15C, 0xE15D and 0xE15E to zero
	ld (HEIGHT_PIECES),hl
	ld (HEIGHT_PIECES+2),hl
	jp next_core_step
release_a_piece:		; Decrements the long count and, every so many frames, looks for a free slot among the eight and sets up a piece
	ld hl,(BOSS_TIMER)	; The frames the boss has left
	dec hl
	ld a,h
	or l
	jp z,next_core_step
	ld (BOSS_TIMER),hl
	ld hl,PIECE_TIMER	; The frames until the next piece
	dec (hl)
	ret nz
	inc l
	ld a,(hl)
	dec l
	ld (hl),a
	ld b,008h		; Eight slots
	call any_free
	ret nz
	push hl
	call choose_piece_height
	pop hl
	ret c
set_up_piece_card:		; Copies the eleven bytes of piece_card and gives it the Y that the table at piece_heights says
	ld de,piece_card	; The eleven bytes of piece_card
	ex de,hl
	ldi
	ldi
	ldi
	ld a,(PIECE_HEIGHT)	; Which of the four heights
	exx
	ld b,a
	ld hl,piece_heights	; The table at piece_heights: the four heights
	add a,l
	ld l,a
	jr nc,L_843D
	inc h
L_843D:
	ld a,(hl)		; Eight more bytes of card
	exx
	ld (de),a
	inc e
	ld bc,00008h		; Eight more bytes of card
	ldir			; Eight more bytes
	inc e
	inc e
	exx
	ld a,b
	exx
	ld (de),a
	ret

; ----------------------------------------------------------------------
; DATA piece_card: The eleven starting bytes of a boss piece, which set_up_piece_card
;   copies as is to the free slot.
piece_card:
	defb 02h,00h,00h,00h,0F8h,00h,00h,01h,28h,1Eh,00h

; ----------------------------------------------------------------------
; DATA piece_heights: The four heights at which a boss piece can come out:
;   0x08, 0x34, 0x60 and 0x8C. Read by 0x8435 with (PIECE_HEIGHT).
piece_heights:
	defb 08h,34h,60h,8Ch
check_boss_over:		; When no piece is left alive and no explosion either, the boss is considered dead
	ld b,008h		; Eight piece slots
	call any_alive
	ret nz
	call any_explosion
	ret nz
	jp mark_boss_dead
choose_piece_height:		; The R register chooses one of the four heights, skipping the one from the previous time and those that already have two pieces
	ld a,(PIECE_PREV_HEIGHT)	; The height from the previous time
	ld c,a
	ld d,004h		; Four attempts
	ld a,r			; The R register: one of the four heights
L_8471:
	and 003h
	ld b,a
	cp c			; Not the same as the previous one
	jr z,L_8481
	ld hl,HEIGHT_PIECES	; How many pieces there already are at that height
	add a,l
	ld l,a
	ld a,(hl)
	cp 002h			; Two per height at most
	jr c,L_8488
L_8481:
	scf			; The chosen height is noted down
	dec d
	ret z
	ld a,b
	inc a
	jr L_8471
L_8488:
	inc (hl)		; The chosen height is noted down
	ld a,b
	ld (PIECE_HEIGHT),a
	ld (PIECE_PREV_HEIGHT),a
	xor a
	ret
any_free:		; Returns in HL the first piece slot that is free
	ld hl,BOSS_PIECES
	ld de,00010h
L_8498:
	ld a,(hl)		; With the first byte at zero, the slot is free
	or a
	ret z
	add hl,de
	djnz L_8498
	ret
any_alive:		; Returns NZ if any piece is still alive
	ld hl,BOSS_PIECES
	ld de,00010h
L_84A5:
	ld a,(hl)		; With the first byte non-zero, one is still alive
	or a
	ret nz
	add hl,de
	djnz L_84A5
	ret
any_explosion:		; And the same with the four explosion slots at EXPLOSIONS
	ld hl,EXPLOSIONS
	ld de,00008h
	ld b,004h		; Four
L_84B4:
	ld a,(hl)		; With the first byte non-zero, an explosion is still left
	or a
	ret nz
	add hl,de
	djnz L_84B4
	ret
run_one_piece:		; Just one
	ld a,001h
	jp L_84C2
run_eight_pieces:		; The eight slots at BOSS_PIECES
	ld a,008h		; Eight slots
L_84C2:
	ld (PIECE_HEIGHT),a
	ld ix,BOSS_PIECES
L_84C9:
	call one_piece_step
	ld de,00010h		; Sixteen bytes: the next one
	add ix,de		; Sixteen bytes: the next one
	ld hl,PIECE_HEIGHT	; Counts the slots
	dec (hl)
	jp nz,L_84C9
	ret
one_piece_step:		; According to byte 1: entering, moving, or already inside; byte 14 at 4 sends it another way
	ld a,(ix+000h)
	or a
	ret z
	ld a,(ix+001h)
	dec a			; Step 1 is the moving one
	jp z,walk_piece
	jp p,L_8515
	call shift_piece_one_point	; And 0: entering from the edge
	cp 0e1h			; Until it passes X 0xE1, it keeps entering
	ret nc
next_piece_step:		; Byte 1 goes up
	inc (ix+001h)
	ret
walk_piece:		; Decrements the counter in byte 10; when it runs out, turns off the drawing and moves on to the next step
	dec (ix+00ah)
	jp nz,L_84FF
	ld (ix+006h),000h
	jp next_piece_step
L_84FF:
	call piece_fires	; It moves, closes in and fires
	ld a,(ix+00eh)
	cp 004h			; Byte 14 at 4 has another mover routine
	jr z,L_850F		; Byte 14 at 4 has another mover routine
	call chase_ship_row	; It moves and fires
	jp chase_ship_column
L_850F:
	call chase_row_fast
	jp chase_column_fast
L_8515:
	ld a,(ix+00eh)
	cp 004h
	jp z,L_8629
	call shift_piece_one_point
	ret nc
free_height:		; The piece switches off and its height is free again in HEIGHT_PIECES
	ld a,(ix+00eh)		; Byte 14 says which height it was at
	ld hl,HEIGHT_PIECES
	add a,l
	ld l,a
	dec (hl)
	ld (ix+000h),000h
	ret
chase_ship_row:		; Every eight frames it closes in on the ship's ROW, without leaving the band its height gives it; within 0x11 it stays still
	ld a,(ix+00ah)		; One in every eight frames
	and 007h
	ret nz
	ld a,(SHIP_ROW)		; The ship's row, minus its own
	sub (ix+003h)
	push af
	add a,008h
	cp 011h			; Within 0x11 it is already at its height
	jp c,L_8579
	pop af
	jp c,L_8560
	ld de,00200h		; Two points down
	call add_de_to_row
	ld b,a
	ld a,(ix+00eh)
	ld hl,band_floor	; The table at band_floor: the floor of its band
	add a,l			; Byte 14 says which band it is in
	ld l,a			; With a limit
	jr nc,L_8559
	inc h
L_8559:
	ld a,(hl)
	cp b
	ret nc
	ld (ix+003h),a
	ret
L_8560:
	ld de,0fe00h		; Or two points up
	call add_de_to_row
	ld b,a
	ld a,(ix+00eh)
	ld hl,band_ceiling	; And the one at band_ceiling: the ceiling of its band
	add a,l			; The ceiling of its band
	ld l,a			; With a limit
	jr nc,L_8572
	inc h
L_8572:
	ld a,(hl)
	cp b
	ret c
	ld (ix+003h),a
	ret
L_8579:
	pop af
	ret

; ----------------------------------------------------------------------
; DATA band_floor: How far down (to which row) the piece can go, one per band:
;   0x0B, 0x37, 0x63 and 0x8F. Read by 0x8551. With the four ceilings at
;   band_ceiling they make four lanes of eleven points, 0x2C apart.
band_floor:
	defb 0Bh,37h,63h,8Fh

; ----------------------------------------------------------------------
; DATA band_ceiling: The four ceilings: 0x00, 0x2C, 0x58 and 0x84. Read by
;   0x856A.
band_ceiling:
	defb 00h,2Ch,58h,84h
chase_ship_column:		; Every four frames it closes in on the ship's COLUMN; the margin comes from the difficulty, and when it goes off on the left the piece leaves
	ld a,(ix+00ah)		; One in every four frames
	and 003h
	dec a
	ret nz
	ld a,(DIFFICULTY)	; The difficulty times four, subtracted from 0x60: how far ahead it stays
	add a,a			; The piece's column, minus that margin
	add a,a			; SHIP_COLUMN is the ship's column
	sub 060h
	neg
	ld b,a
	ld a,(ix+005h)
	sub b
	jp nc,L_859D
	neg
L_859D:
	ld c,a
	ld a,(SHIP_COLUMN)
	sub c
	push af
	add a,008h
	cp 011h			; Within 0x11 it is already at its column
	jp c,L_8579
	pop af
	jp c,L_85BC
	ld de,0fe00h		; Two points to the right
	call sub_de_from_column
	cp 0f0h			; With a limit at column 0xF0
	ret c
	ld (ix+005h),0f0h
	ret
L_85BC:
	ld de,00200h		; Or two to the left, and when it goes off that edge the piece leaves
	call sub_de_from_column
	ret nc
	jp free_height
chase_row_fast:		; The same but every two frames and four points at a time, between rows 0x00 and 0x90
	bit 0,(ix+00ah)		; One in every two frames
	ret nz			; The ship's row
	ld a,(SHIP_ROW)		; The ship's row
	sub (ix+003h)
	push af
	add a,008h
	cp 011h
	jp c,L_8579
	pop af
	jp c,L_85EC
	ld de,00400h		; Four points down
	call add_de_to_row
	ld b,a
	ld a,090h		; With a limit at row 0x90
	cp b
	ret nc
	ld (ix+003h),a
	ret
L_85EC:
	ld de,0fc00h		; Or four up, with a limit at row 0
	call add_de_to_row
	ld b,a
	ld a,000h
	cp b
	ret c
	ld (ix+003h),a
	ret
chase_column_fast:		; Every two frames it closes in on the ship's column four points at a time, staying 0x40 ahead
	bit 0,(ix+00ah)		; One in every two frames
	ret z
	ld a,(ix+005h)
	sub 040h		; 0x40 ahead of the ship
	jp nc,L_860A
	neg
L_860A:
	ld c,a
	ld a,(SHIP_COLUMN)
	sub c
	push af
	add a,008h
	cp 011h			; Within 0x11 it is already at its column
	jp c,L_8579
	pop af
	jp c,L_8629
	ld de,0fc00h		; Four points to the right
	call sub_de_from_column
	cp 0f0h
	ret c
	ld (ix+005h),0f0h
	ret
L_8629:
	ld de,00400h		; Or four to the left, and when it goes off it leaves
	call sub_de_from_column
	ret nc
	jp free_height
add_de_to_row:		; Adds DE to the 16-bit word at (IX+2, IX+3): the piece's row, with its fractional part.
	ld a,(ix+002h)		; The low byte...
	add a,e
	ld (ix+002h),a
	ld a,(ix+003h)		; ...and the high one with the carry
	adc a,d
	ld (ix+003h),a
	ret
shift_piece_one_point:		; Enters sub_de_from_column with DE = 0x0100: one point to the left.
	ld de,00100h
sub_de_from_column:		; Subtracts DE from the 16-bit word at (IX+4, IX+5): the piece's column, with its fractional part.
	ld a,(ix+004h)		; The low byte...
	sub e
	ld (ix+004h),a
	ld a,(ix+005h)		; ...and the high one with the carry
	sbc a,d
	ld (ix+005h),a
	ret
piece_fires:		; Every so many frames (fewer the harder it is) fires three type 0x0B shots, if they fit on the screen
	ld a,(ix+007h)
	dec a			; Byte 7 is the shot's step
	jr z,L_8674
	jp p,L_8681
	dec (ix+008h)
	ret nz
	ld a,(LIVE_OBJECTS)	; With ten or more objects on screen it does not fire
	cp 00ah
	jr nc,L_868C
	ld (ix+00bh),00ah	; Ten frames of warning
	ld (ix+006h),001h
next_shot_step:		; Byte 7 goes up
	inc (ix+007h)
	ret
L_8674:
	dec (ix+00bh)		; The ten frames, and then it fires
	ret nz
	ld (ix+00bh),00ah
	call release_three_shots
	jr next_shot_step
L_8681:
	dec (ix+00bh)		; And another ten to go back to the usual drawing
	ret nz
	xor a
	ld (ix+006h),a
	ld (ix+007h),a
L_868C:
	ld a,(DIFFICULTY)	; 0x22 minus twice the difficulty: the frames until the next batch
	add a,a
	sub 022h
	neg
	ld (ix+008h),a
	ret
release_three_shots:		; Three of type 0x0B, one after another
	ld a,003h		; Three
	ld (SHOT_BURST),a
L_869D:
	call release_from_piece
	ld hl,SHOT_BURST
	dec (hl)
	jr nz,L_869D
	ret
release_from_piece:		; It comes out eight to the right of the piece and eight above it
	ld a,(ix+003h)		; Eight to the right
	add a,008h
	ld e,a
	ld a,(ix+005h)		; And eight above
	sub 008h
	ret c
	ld d,a
	ld c,000h
	ld a,00bh		; Type 0x0B
	push ix
	call spawn_object
	pop ix
	ret
draw_single_piece:
	ld hl,BOSS_PIECES
	jp draw_piece
draw_eight_pieces:		; The eight slots at BOSS_PIECES
	ld b,008h		; Eight slots
	ld hl,BOSS_PIECES
L_86CB:
	push bc
	push hl
	call draw_piece
	pop hl
	ld de,00010h		; Sixteen bytes: the next one
	add hl,de		; Bit 0 of byte 1
	pop bc			; With the first byte at zero, there is no piece
	djnz L_86CB
	ret
draw_piece:		; Four by four characters, with one of the two drawings at characters_86F1 and characters_8701 according to byte 1
	ld a,(hl)
	or a
	ret z
	call card_position
	inc l
	ld a,(hl)
	or a
	ld hl,characters_86F1	; Byte 1 chooses between the two drawings
	jr z,L_86EA
	ld hl,characters_8701
L_86EA:
	ex de,hl
	ld bc,00404h		; Four by four characters
	jp copy_rectangle

; ----------------------------------------------------------------------
; DATA characters_86F1: Sixteen characters read by 0x86E2.
characters_86F1:
	defb 0A6h,0A7h,0A8h,0A9h
	defb 0AAh,0ABh,0ACh,0ADh
	defb 0B6h,0B7h,0B8h,0B9h
	defb 0B2h,0B3h,0B4h,0B5h

; ----------------------------------------------------------------------
; DATA characters_8701: Sixteen characters read by 0x86E7.
characters_8701:
	defb 0AEh,0A7h,0A8h,0A9h
	defb 0AFh,0ABh,0ACh,0ADh
	defb 0BBh,0B7h,0B8h,0B9h
	defb 0BAh,0B3h,0B4h,0B5h
card_position:		; Takes the X and the Y from the card
	inc l			; Bytes 3 and 5
	inc l
	inc l
	ld e,(hl)
	inc l
	inc l
	ld d,(hl)
	ret
dispatch_boss_step_3:		; Four steps, counted in BOSS_PHASE
	ld a,(SCROLL_MODE)	; Not with the screen stopped
	and a
	ret nz
	ld a,(BOSS_PHASE)
	call dispatcher

; ----------------------------------------------------------------------
; DATA spitting_boss_steps: Four words glued right behind the `call dispatcher`
;   at 0x8721.
spitting_boss_steps:
	defw set_up_this_boss	; 0
	defw this_boss_fires	; 1
	defw wait_until_gone	; 2
	defw wait_for_bank_10	; 3
set_up_this_boss:		; 0x258 frames, the ten bytes of spitting_boss_start_card into the slot and two characters on the screen
	ld hl,00258h		; 0x258 frames
	ld (BOSS_TIMER),hl
	ld hl,spitting_boss_start_card	; The ten starting bytes
	ld de,BOSS_PIECES	; The ten starting bytes
	ld bc,0000ah
	ldir
	ld de,03e3fh
	call write_two_characters
next_step_of_this_boss:		; BOSS_PHASE + 1
	ld hl,BOSS_PHASE
	inc (hl)
	ret

; ----------------------------------------------------------------------
; DATA spitting_boss_start_card: Ten bytes read by 0x8732.
spitting_boss_start_card:
	defb 05h,00h,00h,50h,00h,0B7h,00h,00h,00h,40h

; ----------------------------------------------------------------------
; THE BOSS THAT SPITS SHOTS: THE R REGISTER AGAIN
; This boss fires a shot every two frames for as long as its count lasts,
; and the direction is NOT calculated: it is taken from the table at
; fan_speeds, sixteen speed pairs, with the index set by five bits of the R
; register. On top of that, a bit of the frame counter flips the sign, so
; the fan comes out on both sides.
; ----------------------------------------------------------------------
this_boss_fires:		; Every two frames fires a type 0x10 shot with one of the sixteen speeds at fan_speeds
	ld a,(BOSS_PIECES+9)	; Until it is set up, it does not fire
	and a
	jr z,score_boss
	ld hl,(BOSS_TIMER)	; The frames it has left
	dec hl
	ld (BOSS_TIMER),hl
	ld a,l
	or h
	jr z,count_runs_out
	ld a,(FRAME_COUNT)
	ld c,a
	rra			; One in every two frames
	ret c
	ld a,r			; The R register: one of the sixteen pairs
	and 01eh
	ld hl,fan_speeds
	call add_a_to_hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld hl,0a440h
	bit 1,c			; And a bit of the counter flips it
	jr z,L_8782
	ld l,06fh
	call change_sign
L_8782:
	ex de,hl
	ld (AIM_VSPEED),hl	; The vertical speed
	ld hl,0f900h		; And 0xF900 in Y
	ld (AIM_HSPEED),hl
	ld a,010h		; Type 0x10
	ld c,000h
	jp spawn_object
score_boss:		; A hundred points, and the two characters change
	ld de,00100h		; A hundred points
	call add_to_score
	ld de,05f60h
	jr L_87A1
count_runs_out:		; Changes the characters and leaves 0x5A frames
	ld de,04041h
L_87A1:
	call write_two_characters
	ld a,05ah
	ld (BOSS_TIMER),a	; 0x5A frames
	xor a
	ld (TARGET),a
	jr next_step_of_this_boss

; ----------------------------------------------------------------------
; DATA fan_speeds: Sixteen pairs of 16-bit speeds that 0x876D indexes with
;   five bits of the R register: the directions in which this boss spits
;   shots.
fan_speeds:
	defw 0100h,0280h
	defw 0200h,0500h
	defw 0340h,0400h
	defw 0380h,01A0h
	defw 0580h,0240h
	defw 0300h,0480h
	defw 0600h,0180h
	defw 0160h,01A0h
write_two_characters:		; Puts D and E into two map cells, one above the other
	ld hl,MAP+10*MAP_WIDTH+1Bh	; Two map cells, one above the other
	ld (hl),d
	ld bc,00020h		; 0x20: the row below
	add hl,bc
	ld (hl),e
	ret
wait_until_gone:		; When the count runs out, clears FADE_STEP and moves on to the next step
	ld hl,BOSS_TIMER	; The frames remaining
	dec (hl)
	ret nz
	xor a
	ld (FADE_STEP),a	; To zero
	jp z,next_step_of_this_boss
wait_for_bank_10:		; Calls bank 3 and, when FADE_DONE gets set, considers the boss dead
	call switch_off_screen	; Bank 3 sets up the ending
	ld a,(FADE_DONE)	; Not until it is set
	and a
	ret z
	ld a,001h
	ld (BOSS_DONE),a
	ret
dispatch_boss_step_4:		; Six steps, counted in BOSS_PHASE
	ld a,(BOSS_PHASE)
	call dispatcher

; ----------------------------------------------------------------------
; DATA dispatcher_table_87F6: Six words glued right behind the `call dispatcher`
;   at 0x87F6.
dispatcher_table_87F6:
	defw set_up_two_pieces	; 0
	defw wait_for_distance_178	; 1
	defw wait_for_ship_to_rise	; 2
	defw start_long_count	; 3
	defw release_from_script	; 4
	defw wait_for_bank_3	; 5
set_up_two_pieces:		; The 0x1D bytes of table_8812 to BOSS_PIECES: the starting cards of two pieces in a row
	ld de,BOSS_PIECES
	ld hl,table_8812
	ld bc,0001dh
	ldir
	jr next_boss_step

; ----------------------------------------------------------------------
; DATA table_8812: Twenty-nine bytes read by 0x8808.
table_8812:
	defb 07h,00h,00h,78h,00h,0F8h,00h,10h,10h,20h,00h,00h,00h,00h,00h,00h
	defb 07h,01h,00h,20h,00h,0F8h,00h,10h,18h,20h,07h,07h,00h
wait_for_distance_178:		; Once past distance 0x178, leaves 0x1E0 frames and sets up the card at table_884D in BOSS4_PIECE
	call run_two_pieces
	ld hl,(DISTANCE)
	ld de,00178h		; Distance 0x178
	rst 20h
	ret c
	ld hl,001e0h		; 0x1E0 frames
	ld (BOSS_TIMER),hl
	ld hl,table_884D	; The five starting bytes
	ld de,BOSS4_PIECE
	ld bc,00005h
	ldir
	jr next_boss_step

; ----------------------------------------------------------------------
; DATA table_884D: Five bytes read by 0x8840.
table_884D:
	defb 01h,38h,0F8h,20h,00h
wait_for_ship_to_rise:		; Carries on until the count runs out, or until the ship passes Y 0xC8, and then releases the limit
	call run_two_pieces
	ld hl,(BOSS_TIMER)	; The frames remaining
	dec hl
	ld (BOSS_TIMER),hl
	ld a,l
	or h
	jr z,L_886C
	ld a,(SHIP_COLUMN)	; Or until the ship passes column 0xC8
	cp 0c8h
	jr nc,L_886C
	ld a,(BIG_PIECE_BLOWN)	; Or until the submode gets set
	and a
	ret z
L_886C:
	ld hl,BOSS4_PIECE	; Moves to step 2
	ld a,(hl)
	cp 002h
	jr nc,L_8876
	ld (hl),002h
L_8876:
	ld hl,0019fh		; The offset goes up to 0x19F
	ld (SCROLL_LIMIT),hl	; The offset up to 0x19F
	jr next_boss_step	; To the next step
start_long_count:		; TYPE11_DRAWING to zero and another 0x1E0 frames
	xor a
	ld (TYPE11_DRAWING),a
	ld hl,001e0h
	ld (BOSS_TIMER),hl
next_boss_step:		; BOSS_PHASE + 1
	ld hl,BOSS_PHASE
	inc (hl)
	ret
release_from_script:		; On the steps with a new column it checks the script at type_11_object_script and, when everything is used up, clears the flag
	call run_two_pieces
	ld a,(NEW_COLUMN)	; Only on the steps with a column
	and a
	call nz,check_boss_script
	ld a,(SCROLL_AT_LIMIT)	; And only on the steps with a new column
	and a
	ret z
	ld a,(LIVE_OBJECTS)	; If no object is left alive, it ends right away
	and a			; With no live objects, it ends right away
	jr z,end_this_boss
	ld hl,(BOSS_TIMER)
	dec hl
	ld (BOSS_TIMER),hl
	ld a,h
	or l
	ret nz
end_this_boss:		; FADE_STEP to zero and MUSIC_HOLD to one
	ld a,03bh		; FADE_STEP to zero and MUSIC_HOLD to one
	xor a
	ld (FADE_STEP),a
	inc a
	ld (MUSIC_HOLD),a
	jr next_boss_step
wait_for_bank_3:		; When FADE_DONE gets set, clears the 0x180 bytes of objects and considers the boss dead
	call switch_off_screen	; Bank 3 sets up the ending
	ld a,(FADE_DONE)
	and a
	ret z
	ld hl,OBJECTS		; The 0x180 bytes of objects, zeroed
	ld de,OBJECTS+1
	ld bc,0017fh
	ld (hl),000h
	ldir
	ld a,001h		; BOSS_DONE to one: the boss is over
	ld (BOSS_DONE),a
	ret
check_boss_script:		; Walks the table three bytes at a time looking for the exact distance; when it matches, releases a type 0x11 object
	ld hl,type_11_object_script
	ld a,(DISTANCE)		; The distance travelled
L_88D9:
	cp (hl)
	call z,L_88E3
	ret c
	inc hl			; Three bytes per entry
	inc hl
	inc hl
	jr L_88D9
L_88E3:
	push af
	push hl
	inc hl
	ld e,(hl)		; The X and the drawing
	inc hl
	ld a,(hl)
	ld (TYPE11_DRAWING),a
	ld d,0f8h		; It comes out at Y 0xF8
	ld c,000h
	ld a,011h		; Type 0x11
	call spawn_object
	pop hl
	pop af
	ret

; ----------------------------------------------------------------------
; DATA type_11_object_script: Nineteen bytes read by check_boss_script, in groups of three and with
;   0xFF at the end.
type_11_object_script:
	defb 8Ah,10h,33h
	defb 8Bh,90h,34h
	defb 8Fh,10h,33h
	defb 8Fh,90h,34h
	defb 93h,90h,36h
	defb 95h,10h,35h
	defb 0FFh
run_piece_at_e9a0:		; Raises it eight points per scroll step and, on step 2, changes its drawing every 0x20 frames
	ld a,(BOSS4_PIECE)
	ld c,a
	and a
	ret z
	ld hl,BOSS4_PIECE+2
	ld a,(NEW_COLUMN)	; Only on the steps with a column
	and a
	jr z,L_8920
	ld a,(hl)
	sub 008h		; Eight points higher
	ld (hl),a
	jr c,end_piece_at_e9a0
L_8920:
	ld a,c
	cp 002h			; Only step 2 animates
	ret nz
	inc hl
	dec (hl)
	ret nz
	ld (hl),020h		; 0x20 frames per drawing
	inc l
	inc (hl)
	ld a,(hl)
	cp 006h			; Six drawings and it is over
	ret c
end_piece_at_e9a0:		; BOSS4_PIECE to step 3
	ld a,003h
	ld (BOSS4_PIECE),a
	ret
draw_piece_at_e9a0:		; On step 2, a rectangle of four by six characters, taken from the table at piece_drawings with the drawing
	ld a,(BOSS4_PIECE)
	cp 002h			; Only on step 2
	ret nz
	ld hl,(BOSS4_PIECE+1)
	ld a,(BOSS4_PIECE+4)
	add a,a			; Times twenty-four: four by six characters
	add a,a
	add a,a
	ld c,a
	add a,a
	add a,c
	ld bc,00406h		; Four wide by six high
	ld de,piece_drawings
	call add_a_to_de
	jp copy_rectangle

; ----------------------------------------------------------------------
; DATA piece_drawings: Six drawings of four by six characters, one per
;   animation step. Read by 0x894A with (0xE9A4).
piece_drawings:
	defb 5Dh,5Dh,5Dh,5Dh
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 5Bh,5Bh,5Bh,5Bh
	defb 5Ch,5Ch,5Ch,5Ch
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 5Ah,5Ah,5Ah,5Ah
	defb 5Ch,5Ch,5Ch,5Ch
	defb 5Dh,5Dh,5Dh,5Dh
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 5Bh,5Bh,5Bh,5Bh
	defb 5Ah,5Ah,5Ah,5Ah
	defb 5Ch,5Ch,5Ch,5Ch
	defb 5Ch,5Ch,5Ch,5Ch
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 5Ch,5Ch,5Ch,5Ch
	defb 5Ch,5Ch,5Ch,5Ch
	defb 5Ch,5Ch,5Ch,5Ch
	defb 5Ch,5Ch,5Ch,5Ch
	defb 5Dh,5Dh,5Dh,5Dh
	defb 5Bh,5Bh,5Bh,5Bh
	defb 5Ah,5Ah,5Ah,5Ah
	defb 5Ah,5Ah,5Ah,5Ah
	defb 5Ch,5Ch,5Ch,5Ch
	defb 5Ch,5Ch,5Ch,5Ch
	defb 5Ch,5Ch,5Ch,5Ch
	defb 5Ah,5Ah,5Ah,5Ah
	defb 5Ah,5Ah,5Ah,5Ah
	defb 5Ah,5Ah,5Ah,5Ah
erase_two_pieces:		; Erases from the screen the two slots at BOSS_PIECES and 0xE790
	xor a
	ld (PAINT_FLAG),a	; To zero: erase
	ld ix,BOSS_PIECES
	call L_89F2
	ld ix,BOSS_PIECES+BOSS_PIECE_SIZE
L_89F2:
	ld a,(ix+000h)
	and a
	ret z
	ld a,(ix+00ch)		; Byte 12 set: the piece is blown up
	and a
	jr z,paint_or_erase_piece
blow_up_this_piece_2:		; Erases the piece and sets up the explosion on one side or the other according to bit 0 of byte 1
	ld (ix+000h),000h
	dec a
	ret nz
	call paint_or_erase_piece
	ld (ix+000h),000h
	bit 0,(ix+001h)		; Bit 0 of byte 1: to the left or to the right
	ld a,0f0h
	jr z,L_8A14
	ld a,010h
L_8A14:
	add a,(ix+003h)
	ld e,a
	ld a,(ix+005h)
	add a,010h		; And 0x10 further down
	ld d,a			; And bank 1 sets it up
	jp set_up_background_explosion	; Ten further down
paint_two_pieces:		; PAINT_FLAG to one, and paint the two slots
	ld a,001h
	ld (PAINT_FLAG),a
	ld ix,BOSS_PIECES
	call L_8A31
	ld ix,BOSS_PIECES+BOSS_PIECE_SIZE
L_8A31:
	ld a,(ix+000h)
	and a
	ret z
paint_or_erase_piece:		; The table at turning_piece_drawings gives the offset and the size of the rectangle; PAINT_FLAG decides whether it is painted or erased
	ld a,(ix+00ah)
	ld hl,turning_piece_drawings	; The table at turning_piece_drawings, indexed by the drawing
	call get_word
	ex de,hl
	ld a,(hl)		; The offset in X...
	add a,(ix+003h)
	ld e,a
	inc hl
	ld a,(hl)		; ...and in Y
	add a,(ix+005h)
	ret c
	ld d,a
	inc hl
	ld c,(hl)		; And the width and the height
	inc hl
	ld b,(hl)
	inc hl
	ex de,hl
	ld a,(PAINT_FLAG)	; Decides: erase or paint
	and a			; The position of the piece
	jp z,clear_rectangle	; The position of the piece
	jp copy_rectangle
run_two_pieces:		; One step for each of the two slots
	ld ix,BOSS_PIECES
	call this_piece_step
	ld ix,BOSS_PIECES+BOSS_PIECE_SIZE
this_piece_step:		; Moves, fires, and every 0x10 frames changes drawing using the table at shot_origin
	ld a,(ix+000h)
	and a
	ret z
	call raise_piece
	call where_it_faces
	call turn_piece
	dec (ix+008h)		; 0x10 frames per drawing
	ret nz
	ld (ix+008h),010h
	ld a,(ix+00ah)
	ld hl,shot_origin	; The table at shot_origin: where each drawing lands
	call get_word		; The table at shot_origin
	ld a,(ix+003h)
	add a,e
	ld e,a
	ld a,(ix+005h)
	add a,d
	ld d,a
	jp enemy_shoots

; ----------------------------------------------------------------------
; DATA shot_origin: Fourteen signed (dx, dy) pairs, one per drawing: where the
;   piece's shot comes out depending on which way it is facing. Read by 0x8A80
;   in this bank and 0x769F in bank 1.
shot_origin:
	defb 0FCh,0FEh
	defb 0F4h,0FEh
	defb 0F4h,0FEh
	defb 0E8h,04h
	defb 0E0h,08h
	defb 0D0h,1Ah
	defb 0D0h,20h
	defb 0F8h,0FEh
	defb 00h,0FEh
	defb 00h,0FEh
	defb 08h,04h
	defb 12h,0Ah
	defb 20h,1Ah
	defb 22h,22h
turn_piece:		; Every six frames takes a step towards the drawing it wants to reach, one up or one down
	dec (ix+007h)
	ret nz
	ld (ix+007h),006h	; Six frames per step
	ld a,(ix+00ah)		; Byte 10 is the current drawing and 11 the one it is chasing
	cp (ix+00bh)
	ret z
	ld c,001h		; One step towards it
	jr c,L_8AC4
	ld c,0ffh
L_8AC4:
	add a,c
	ld (ix+00ah),a
	ret
raise_piece:		; On the steps with a new column it rises eight points; on reaching zero it counts as blown up
	ld a,(NEW_COLUMN)	; Only on the steps with a column
	and a
	ret z
	ld a,(ix+005h)
	sub 008h		; Eight points higher
	ld (ix+005h),a
	ret nz
	ld (ix+00ch),002h	; On reaching zero, byte 12 to two
	ret
where_it_faces:		; Measures the angle to the ship and from it gets the drawing it has to turn to, plus a jitter from the R register
	ld e,(ix+003h)
	ld a,(ix+005h)		; 0x38 below the piece
	add a,038h
	ld d,a
	call measure_distance_to_ship	; Bank 1 measures the angle
	ld a,(SHIP_ANGLE)
	bit 0,(ix+001h)		; Bit 0 of byte 1: one of the two tables
	jr z,where_the_other_faces
	ld c,008h
	sub 040h		; Outside the quarter turn it can reach, it stays as it is
	jr c,L_8B06
	cp 040h
	jr nc,L_8B06
	ld hl,piece_facing_drawings_B	; The table at piece_facing_drawings_B
	rra
	rra
	and 00fh
	call add_a_to_hl
	ld c,(hl)
L_8B06:
	ld a,r			; The R register: minus one, zero or one of jitter
	and 003h		; Four bits of the angle
	dec a
	cp 002h
	jr nz,L_8B10
	xor a
L_8B10:
	add a,c
	ld (ix+00bh),a
	ret
where_the_other_faces:		; The same with the table at piece_facing_drawings_A and the other quadrant
	ld c,001h		; The other quadrant
	sub 080h		; Half a turn
	jr c,L_8B06
	cp 040h
	jr nc,L_8B06
	ld hl,piece_facing_drawings_A	; The table at piece_facing_drawings_A
	rra
	rra
	and 00fh
	call add_a_to_hl
	ld c,(hl)
	jr L_8B06

; ----------------------------------------------------------------------
; DATA piece_facing_drawings_A: Sixteen bytes read by 0x8B1F.
piece_facing_drawings_A:
	defb 01h,02h,03h,04h,04h,04h,05h,05h,05h,05h,05h,05h,05h,05h,05h,05h

; ----------------------------------------------------------------------
; DATA piece_facing_drawings_B: Sixteen bytes read by 0x8AFB.
piece_facing_drawings_B:
	defb 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Bh,0Ch,0Ah,0Ah,09h,08h

; ----------------------------------------------------------------------
; DATA turning_piece_drawings: What 0x8A39 reads with `ld hl,0x8B4C`, running on up to the
;   code next to it.
turning_piece_drawings:
	defb 68h,8Bh,81h,8Bh,9Ah,8Bh,0B3h,8Bh,0CCh,8Bh,0E8h,8Bh,0Ah,8Ch,26h,8Ch
	defb 3Fh,8Ch,58h,8Ch,71h,8Ch,8Ah,8Ch,0A6h,8Ch,0C8h,8Ch,0F8h,00h,03h,07h
	defb 00h,00h,00h,00h,70h,70h,00h,6Eh,68h,6Eh,64h,6Fh,6Fh,64h,6Dh,67h
	defb 6Dh,00h,00h,00h,00h,0F8h,00h,03h,07h,6Eh,70h,00h,00h,00h,00h,00h
	defb 6Dh,6Fh,6Eh,68h,68h,6Eh,64h,00h,00h,6Dh,67h,67h,6Dh,00h,0F8h,00h
	defb 03h,07h,6Eh,6Eh,68h,70h,00h,00h,00h,6Dh,6Dh,67h,6Fh,6Eh,68h,64h
	defb 00h,00h,00h,00h,6Dh,67h,00h,0F0h,00h,03h,07h,65h,66h,00h,00h,00h
	defb 00h,00h,00h,64h,68h,00h,00h,00h,00h,00h,00h,67h,64h,64h,64h,64h
	defb 0E8h,08h,04h,06h,69h,6Ah,00h,00h,00h,00h,65h,66h,00h,00h,00h,00h
	defb 00h,64h,68h,70h,00h,00h,00h,00h,67h,6Fh,64h,64h,0D8h,10h,06h,05h
	defb 00h,69h,6Ah,00h,00h,6Bh,6Ch,00h,00h,00h,6Bh,6Ch,00h,00h,00h,00h
	defb 6Eh,00h,00h,00h,00h,6Dh,64h,68h,00h,00h,00h,00h,67h,64h,0D8h,18h
	defb 06h,04h,00h,69h,6Ah,00h,6Bh,6Ch,00h,00h,69h,6Ah,00h,00h,65h,66h
	defb 00h,00h,00h,64h,70h,00h,00h,00h,6Fh,64h,0F8h,00h,03h,07h,30h,28h
	defb 30h,00h,00h,00h,00h,2Fh,27h,2Fh,24h,2Eh,2Eh,24h,00h,00h,00h,00h
	defb 2Dh,2Dh,00h,0F8h,00h,03h,07h,00h,00h,30h,28h,28h,30h,00h,30h,2Eh
	defb 2Fh,27h,27h,2Fh,24h,2Fh,2Dh,00h,00h,00h,00h,00h,0F8h,00h,03h,07h
	defb 00h,00h,00h,00h,30h,28h,00h,30h,30h,28h,2Eh,2Fh,27h,24h,2Fh,2Fh
	defb 27h,2Dh,00h,00h,00h,00h,00h,03h,07h,00h,00h,28h,24h,24h,24h,24h
	defb 00h,24h,27h,00h,00h,00h,00h,25h,26h,00h,00h,00h,00h,00h,00h,08h
	defb 04h,06h,00h,00h,28h,2Eh,24h,24h,00h,24h,27h,2Dh,00h,00h,25h,26h
	defb 00h,00h,00h,00h,29h,2Ah,00h,00h,00h,00h,00h,10h,06h,05h,00h,00h
	defb 00h,28h,24h,00h,30h,24h,27h,00h,00h,2Fh,00h,00h,00h,2Bh,2Ch,00h
	defb 00h,00h,6Bh,6Ch,00h,00h,00h,00h,69h,6Ah,00h,00h,00h,18h,06h,04h
	defb 00h,00h,2Eh,24h,00h,24h,2Dh,00h,25h,26h,00h,00h,29h,2Ah,00h,00h
	defb 6Bh,6Ch,00h,00h,00h,69h,6Ah,00h
run_and_draw_boss_3:		; One step of this boss and its drawing
	call boss_step_3
	jp run_eight_pieces_3
boss_step_3:		; On step 0 works out how long it lasts and how often it releases a piece, and then releases them
	ld a,(BOSS_PHASE)
	dec a
	jr z,release_a_piece_3
	jp p,check_boss_over_3
	ld hl,00258h		; 0x258 frames
	ld (BOSS_TIMER),hl
	ld a,(DIFFICULTY)	; 0x48 minus twice the difficulty: the frames between one piece and the next
	add a,a			; 0x48 minus twice the difficulty
	sub 048h
	neg
	ld hl,PIECE_TIMER
	ld (hl),a
	inc l
	ld (hl),a
	jp next_core_step
release_a_piece_3:		; Every so many frames looks for a free slot among the eight and copies the ten bytes of piece_card_3 there
	ld hl,(BOSS_TIMER)	; The frames the boss has left
	dec hl
	ld a,h
	or l
	jp z,next_core_step
	ld (BOSS_TIMER),hl
	ld hl,PIECE_TIMER	; The frames until the next piece
	dec (hl)
	ret nz
	inc l
	ld a,(hl)
	dec l
	ld (hl),a
	ld b,008h		; Eight slots
	call any_free
	ret nz
	ld de,piece_card_3	; The ten starting bytes
	ex de,hl
	ld bc,0000ah
	ldir
	ret

; ----------------------------------------------------------------------
; DATA piece_card_3: The ten starting bytes of a piece of this boss, which
;   0x8D25 copies as is to the free slot.
piece_card_3:
	defb 06h,00h,00h,18h,00h,0F8h,00h,00h,00h,28h
check_boss_over_3:		; When no piece and no explosion are left, the boss is considered dead
	ld b,008h		; Eight piece slots
	call any_alive
	ret nz
	call any_explosion
	ret nz
	jp mark_boss_dead
run_eight_pieces_3:		; The eight slots at BOSS_PIECES, each through its own step
	ld ix,BOSS_PIECES
	ld b,008h		; Eight slots
L_8D4C:
	push bc
	call piece_step_3
	ld de,00010h		; Sixteen bytes: the next one
	add ix,de		; Sixteen bytes: the next one
	pop bc			; Sixteen bytes
	djnz L_8D4C
	ret
piece_step_3:		; Twelve exits, one per step, in the table at piece_route_steps
	ld a,(ix+000h)
	or a
	ret z
	ld a,(ix+001h)
	call dispatcher

; ----------------------------------------------------------------------
; DATA piece_route_steps: Twelve words glued right behind the `call
;   dispatcher` at 0x8D61.
piece_route_steps:
	defw step_0_two_left	; 0
	defw step_1_diagonal	; 1
	defw step_2_two_left	; 2
	defw step_3_diagonal_up	; 3
	defw step_4_two_left	; 4
	defw step_5_diagonal	; 5
	defw step_6_two_left	; 6
	defw step_7_diagonal_up	; 7
	defw step_8_two_down	; 8
	defw step_9_two_right	; 9
	defw step_10_towards_ship	; 10
	defw step_11_leaves	; 11

	end

; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - enemy_aim.asm
; ============================================================================

	include "variables.inc"

	public aim_at_ship,change_sign,measure_distance_to_ship,multiply_h_by_e,note_all_cells,paint_whole_frame
	public run_e780_and_ea00,run_four_at_e800_and_ea80,save_under_e780,save_under_the_eight
	extrn add_a_to_hl,cell_to_ram_address,dispatch_boss_drawing,erase_e800_objects,erase_the_five,erase_turrets
	extrn paint_background_objects,restore_underneath,save_under_laser

; ----------------------------------------------------------------------
; THE ENEMY'S AIM GETS WORSE ON PURPOSE... WITH THE R REGISTER
; From difficulty 7 upwards, the enemy's shot does NOT go straight at the
; ship: it gets an error taken from the Z80's R register, four bits, which
; is sometimes added and sometimes subtracted depending on bit 6 of that
; same read. Below difficulty 7 the shot is clean. It is the fourth time
; the cartridge uses the refresh register as a number generator.
; ----------------------------------------------------------------------
aim_at_ship:		; Works out which way the shot goes; from difficulty 7 upwards it adds an error from the R register
	call measure_distance_to_ship
	ld a,(AIM_BASE_ANGLE)
	ld e,a
	ld a,(DIFFICULTY)	; Below difficulty 7, no error
	cp 007h
	jr c,get_both_speeds
	ld a,r			; The R register: four bits of error
	ld b,a
	and 00fh
	bit 6,b			; And its bit 6 decides whether it is added or subtracted
	jr z,L_6697		; Bit 6 decides the sign of the error
	ld b,a
	ld a,c
	sub b
	jr nc,L_6694
	xor a
L_6694:
	ld e,a
	jr get_both_speeds
L_6697:
	add a,e
	cp 03fh			; Capped at 0x3F
	jr c,L_669E
	ld a,03fh
L_669E:
	ld e,a

; ----------------------------------------------------------------------
; THE SINE AND THE COSINE COME FROM THE SAME TABLE
; To know which way the shot goes it needs the sine and the cosine of the
; angle, and the cartridge does not keep two tables: it keeps ONE, the one
; at quarter_sine, and reads it twice. Once with the index as it is and once
; with 0x3F minus the index, which is exactly the complementary angle.
; With that it gets the two components, multiplies them by the speed
; (times_speed, with the hand-made eight by eight multiplication at multiply_h_by_e)
; and gives them the right sign with the two's complement at change_sign.
; ----------------------------------------------------------------------
get_both_speeds:		; Reads the table at quarter_sine from both sides (the index and its complement to 0x3F) and from that come the two speeds, the vertical and the horizontal
	ld d,000h
	ld a,e
	sub 03fh		; 0x3F minus the index: the complementary angle
	neg
	ld hl,quarter_sine	; The table at quarter_sine, read from both ends
	push hl			; The table, from both ends
	add hl,de
	ld c,(hl)
	pop hl
	ld e,a
	add hl,de
	ld a,(hl)
	ld (AIM_COMPONENT),a
	ld e,c
	call times_speed	; Times the speed
	ld a,(AIM_ROW_SIGN)	; Says whether X goes the other way
	and a
	call nz,change_sign
	ld (AIM_VSPEED),de	; The vertical speed, the one from the difference in rows
	ld a,(AIM_COMPONENT)
	ld e,a
	call times_speed
	ld a,(AIM_COL_SIGN)
	and a
	call nz,change_sign
	ld (AIM_HSPEED),de	; And the horizontal one
	ret
measure_distance_to_ship:		; Gets the two differences as absolute values, notes their signs in AIM_ROW_SIGN and AIM_COL_SIGN, and from the pair gets the angle
	ld hl,AIM_ROW_SIGN
	ld (hl),000h
	ld a,(SHIP_ROW)		; The ship's row
	sub e
	jr nc,L_66E3
	neg			; When negative, the sign is noted
	inc (hl)
L_66E3:
	inc hl
	ld (hl),000h
	and 0f0h
	ld e,a
	ld a,(SHIP_COLUMN)	; Its column
	sub d
	jr nc,L_66F2
	neg
	inc (hl)
L_66F2:
	ld d,a
	ld hl,AIM_TOO_CLOSE
	ld (hl),000h
	add a,e			; With the sum of the two below 0x30, the ship is right on top
	jr c,L_6700
	cp 030h
	jr nc,L_6700
	inc (hl)
L_6700:
	ld a,d
	rra			; The high nibble of one and of the other: the index into the table at angles
	rra
	rra
	rra
	and 00fh
	add a,e
	ld hl,angles
	call add_a_to_hl
	ld a,(hl)
	ld (AIM_BASE_ANGLE),a	; Keeps the angle
	ld c,a
	ld hl,(AIM_ROW_SIGN)
	ld a,h
	ld b,000h
	and a
	jr z,L_671E
	ld b,080h
L_671E:
	cp l			; And SHIP_ANGLE the quadrant, which comes from the two signs
	ld a,c
	jr z,L_6724
	neg
L_6724:
	add a,b
	ld (SHIP_ANGLE),a
	ret
change_sign:		; Two's complement of DE
	ld a,d			; Two's complement: the other direction
	cpl
	ld d,a
	ld a,e
	cpl
	ld e,a
	inc de
	ret
times_speed:		; Multiplies the component by the speed in ENEMY_SHOT_SPEED and keeps the high part, shifted three bits
	ld a,(ENEMY_SHOT_SPEED)	; The shot's speed
	ld h,a
	call multiply_h_by_e
	xor a
	add hl,hl		; Doubled three times, keeping the carry
	adc a,a			; And times two once more
	add hl,hl
	adc a,a
	add hl,hl
	adc a,a
	ld l,h
	ld h,a
	ex de,hl
	ret
multiply_h_by_e:		; Hand-made 8 by 8 multiplication: eight `add hl,hl` adding DE when there is a carry. Returns the product in HL.
	ld b,008h		; Eight rounds of shift and add: the classic
	ld l,000h
	ld d,l
L_6748:
	add hl,hl
	jr nc,L_674C
	add hl,de
L_674C:
	djnz L_6748
	ret

; ----------------------------------------------------------------------
; DATA table_674F: Four bytes ahead of the base angles.
table_674F:
	defb 40h,00h,80h,0C0h

; ----------------------------------------------------------------------
; DATA angles: Two hundred and fifty-six bytes that 0x6708 indexes with the
;   high nibble of one difference and that of the other: from the pair (dx,
;   dy) comes the angle with which the quarter sine at quarter_sine is then read.
angles:
	defb 20h,0Dh,08h,06h,04h,04h,03h,03h,02h,02h,02h,02h,01h,01h,01h,01h
	defb 33h,20h,16h,10h,0Dh,0Bh,09h,08h,07h,06h,06h,05h,05h,04h,04h,04h
	defb 38h,2Ah,20h,19h,15h,11h,0Fh,0Dh,0Ch,0Ah,09h,09h,08h,07h,07h,06h
	defb 3Ah,2Fh,27h,20h,1Bh,17h,14h,12h,10h,0Eh,0Dh,0Ch,0Bh,0Ah,0Ah,09h
	defb 3Bh,33h,2Bh,25h,20h,1Ch,19h,16h,14h,12h,10h,0Fh,0Eh,0Dh,0Ch,0Bh
	defb 3Ch,35h,2Eh,29h,24h,20h,1Ch,1Ah,17h,15h,14h,12h,11h,10h,0Fh,0Eh
	defb 3Dh,37h,31h,2Ch,27h,23h,20h,1Dh,1Ah,18h,16h,15h,13h,12h,11h,10h
	defb 3Dh,38h,33h,2Eh,2Ah,26h,23h,20h,1Dh,1Bh,19h,17h,16h,15h,13h,12h
	defb 3Dh,39h,34h,30h,2Ch,28h,25h,22h,20h,1Eh,1Ch,1Ah,18h,17h,15h,14h
	defb 3Eh,39h,35h,31h,2Eh,2Ah,27h,25h,22h,20h,1Eh,1Ch,1Ah,19h,17h,16h
	defb 3Eh,3Ah,36h,33h,2Fh,2Ch,29h,27h,24h,22h,20h,1Eh,1Ch,1Bh,19h,18h
	defb 3Eh,3Bh,37h,34h,31h,2Eh,2Bh,28h,26h,24h,22h,20h,1Eh,1Dh,1Bh,1Ah
	defb 3Eh,3Bh,38h,35h,32h,2Fh,2Ch,2Ah,28h,25h,23h,22h,20h,1Eh,1Dh,1Ch
	defb 3Eh,3Bh,38h,36h,33h,30h,2Eh,2Bh,29h,27h,25h,23h,21h,20h,1Eh,1Dh
	defb 3Eh,3Ch,39h,36h,34h,31h,2Fh,2Ch,2Ah,28h,26h,25h,23h,21h,20h,1Eh
	defb 3Fh,3Ch,39h,37h,34h,32h,30h,2Dh,2Bh,29h,28h,26h,24h,23h,21h,20h

; ----------------------------------------------------------------------
; DATA quarter_sine: Sixty-four bytes that are A QUARTER OF A SINE, from 0 to
;   255: compared with 255*sin(k/63*90) the maximum error is 1.9. 0x66A6 reads
;   them TWICE, once with the index and once with 0x3F minus the index, and
;   that way gets the sine and the cosine of the same angle from a single
;   table; the Pythagorean check (t[k]^2 plus t[63-k]^2) gives between 0.98
;   and 1.00 times 255 squared.
quarter_sine:
	defb 00h,06h,0Ch,12h,19h,1Fh,26h,2Ch,32h,38h,3Eh,44h,4Ah,50h,56h,5Ch
	defb 62h,68h,6Dh,73h,79h,7Eh,84h,89h,8Eh,93h,99h,9Eh,0A2h,0A7h,0ACh,0B1h
	defb 0B5h,0B9h,0BEh,0C2h,0C6h,0CAh,0CEh,0D1h,0D5h,0D8h,0DCh,0DFh,0E2h,0E5h,0E7h,0EAh
	defb 0EDh,0EFh,0F1h,0F3h,0F5h,0F7h,0F8h,0FAh,0FBh,0FCh,0FDh,0FEh,0FEh,0FFh,0FFh,0FFh
note_all_cells:		; Works out for each object the screen cell it lands on, for the twelve at OBJECTS and the ten at ENEMY_SHOTS
	call twelve_at_e300
	call save_under_laser	; And a bank 3 routine
	call e500_objects_if_due
	call anything_in_e151	; And the ten at ENEMY_SHOTS
	ret c
ten_at_e500:		; The ten objects at ENEMY_SHOTS
	ld ix,ENEMY_SHOTS
	ld b,00ah
	jr L_68B5
e500_objects_if_due:		; Only with FIVE_PIECES_ON set
	ld a,(FIVE_PIECES_ON)
	or a
	ret z
	jr ten_at_e500
twelve_at_e300:		; The twelve objects at OBJECTS
	ld ix,OBJECTS		; The twelve slots
	ld b,00ch
L_68B5:
	push bc			; Twelve
	call object_cell
	pop bc
	ld de,00020h		; Thirty-two bytes: the next object
	add ix,de
	djnz L_68B5
	ret
object_cell:		; From the object's X and Y gets the map cell and stores it in bytes 30 and 31, and copies two more bytes
	ld a,(ix+000h)
	and a
	ret z
	ld a,(ix+00bh)		; Byte 11 at zero: not drawn with characters
	and a
	ret z
	ld l,(ix+004h)		; The Y and the X
	ld h,(ix+006h)
	call cell_to_ram_address	; The bank 0 routine that turns a cell into a RAM address
	ld (ix+01eh),l		; Bytes 30 and 31: where it lands
	ld (ix+01fh),h
	push ix
	pop de
	ld a,013h		; Thirteen bytes further on
	add a,e			; Thirteen bytes further on, the pair of characters
	ld e,a
	ldi
	ldi
	ld bc,0001eh
	add hl,bc
	ldi
	ldi
	ret
anything_in_e151:		; Returns carry if BOSS_STATE is zero or if BOSS_KIND is not
	ld hl,(BOSS_STATE)	; At zero there is no boss
	ld a,l			; BOSS_KIND at zero: no boss
	and a
	scf
	ret z
	ld a,h
	and a
	ret z
	scf
	ret
run_four_at_e800_and_ea80:		; With BOSS_STATE set and BOSS_KIND at 1 or at 4-5, walks the four pairs of slots
	ld hl,BOSS_STATE	; Without a boss there is nothing to save
	ld a,(hl)
	or a
	ret z
	inc l			; BOSS_KIND: the boss's step
	ld a,(hl)
	dec a
	jp z,L_690C
	sub 004h
	cp 002h
	ret nc
L_690C:
	ld ix,EXPLOSIONS	; This and its partner at BLAST_MIRROR
	ld iy,BLAST_MIRROR
	ld b,004h		; Four
L_6916:
	push bc
	call L_6928
	ld de,00008h		; Eight bytes in one table and sixteen in the other
	add ix,de
	ld de,00010h
	add iy,de
	pop bc
	djnz L_6916
	ret
L_6928:
	ld a,(ix+000h)		; A slot at zero is free
	or a			; The object's position
	ret z
	ld l,(ix+002h)
	ld h,(ix+003h)
	jp L_696F
run_e780_and_ea00:		; Eight pairs, or just one if BOSS_KIND is 6
	ld hl,BOSS_STATE
	ld a,(hl)
	or a
	ret z
	ld b,008h		; Eight pairs
	inc l
	ld a,(hl)
	dec a
	jp z,L_694D
	sub 004h		; With BOSS_KIND at 5 as well
	jp z,L_694D
	dec a
	ret nz
	ld b,001h		; And at 6, just one
L_694D:
	ld ix,BOSS_PIECES
	ld iy,PIECE_MIRROR
L_6955:
	push bc
	call save_what_was_there
	ld de,00010h		; Sixteen bytes each
	add ix,de		; Sixteen bytes each
	add iy,de		; Sixteen bytes each
	pop bc
	djnz L_6955
	ret
save_what_was_there:		; The 4x4 rectangle of characters under the object is saved in the mirror table, so it can be put back
	ld a,(ix+000h)
	or a
	ret z
	ld l,(ix+003h)
	ld h,(ix+005h)
L_696F:
	call cell_to_ram_address	; The map cell where it lands
	push iy
	pop de
	ld a,004h		; Four rows
L_6977:
	ld bc,00004h		; Four characters per row
	ldir
	ld c,01ch		; 0x1C: what is left to reach the row below
	add hl,bc		; Four characters per row
	dec a			; 0x1C: what is left to reach the row below
	jr nz,L_6977
	ret
paint_whole_frame:		; The drawing chain: the objects, the background, the ones at EXPLOSIONS and the ones at BOSS_PIECES, each with its own routine
	call restore_underneath
	call draw_e300_objects
	call erase_the_five
	call draw_e500_objects
	call paint_background_objects
	call erase_turrets
	call dispatch_boss_drawing
	call draw_e500_objects_if_due
	ld hl,BOSS_STATE	; Says whether there is a boss on screen
	ld a,(hl)
	or a
	jp z,erase_e800_objects
	inc l
	ld a,(hl)
	dec a			; And BOSS_KIND which step it is on
	jp z,save_under_the_four
	inc a
	cp 005h			; Without a boss, the four at EXPLOSIONS are erased
	jp nc,save_under_the_four
	jp erase_e800_objects
draw_e500_objects_if_due:		; Only if there is something in BOSS_STATE
	call anything_in_e151
	ret c
L_69B6:
	ld ix,ENEMY_SHOTS	; The ten slots
	ld b,00ah
	jr draw_two_by_two
draw_e500_objects:		; Only with FIVE_PIECES_ON set
	ld a,(FIVE_PIECES_ON)
	or a
	ret z
	jr L_69B6
draw_e300_objects:		; The twelve objects
	ld ix,OBJECTS		; And the twelve
	ld b,00ch
draw_two_by_two:		; Writes the object's four characters into the map: two on top and two on the row below
	ld a,(ix+000h)
	and a
	jr z,L_69FB
	ld a,(ix+00bh)		; Byte 11 at zero: this one is not drawn this way
	and a
	jr z,L_69FB
	ld a,(ix+006h)		; Past X 0xF8, not either
	cp 0f8h
	jr nc,L_69FB
	ld l,(ix+01eh)		; The cell, from bytes 30 and 31
	ld h,(ix+01fh)
	ld a,(ix+013h)		; Bytes 19 and 20: the two characters on top
	ld (hl),a
	inc hl
	ld a,(ix+014h)
	ld (hl),a
	ld a,01fh		; 0x1F: the row below
	call add_a_to_hl
	ld a,(ix+015h)		; And bytes 21 and 22: the two below
	ld (hl),a
	inc hl
	ld a,(ix+016h)
	ld (hl),a
L_69FB:
	ld de,00020h		; Thirty-two bytes: the next object
	add ix,de
	djnz draw_two_by_two
	ret
save_under_the_four:		; The four at EXPLOSIONS, with their mirror table at BLAST_MIRROR
	ld ix,EXPLOSIONS
	ld iy,BLAST_MIRROR
	ld b,004h
L_6A0D:
	push bc			; Four objects
	call save_under_one
	ld de,00008h		; Eight bytes in one table and sixteen in the other
	add ix,de
	ld de,00010h
	add iy,de
	pop bc
	djnz L_6A0D
	ret
save_under_one:		; That object's cell, and copy
	ld a,(ix+000h)		; A slot at zero is free
	or a			; A slot at zero is free
	ret z			; The object's position
	ld l,(ix+002h)
	ld h,(ix+003h)
	jr copy_four_by_four
save_under_e780:		; A single object at BOSS_PIECES
	ld ix,BOSS_PIECES
	ld iy,PIECE_MIRROR
	jp save_one_at_e780
save_under_the_eight:		; The eight at BOSS_PIECES, with their mirror at PIECE_MIRROR
	ld b,008h
	ld ix,BOSS_PIECES
	ld iy,PIECE_MIRROR
L_6A41:
	push bc			; Sixteen bytes each
	call save_one_at_e780
	ld de,00010h		; Sixteen bytes: the next piece
	add ix,de
	add iy,de
	pop bc
	djnz L_6A41
	ret
save_one_at_e780:		; The same, but with the position in bytes 3 and 5
	ld a,(ix+000h)
	or a
	ret z
	ld l,(ix+003h)		; The piece's position
	ld h,(ix+005h)
copy_four_by_four:		; Copies the four by four rectangle of characters from the screen to the mirror table
	call cell_to_ram_address	; The map cell where it lands
	push iy
	pop de
	ex de,hl
	ld a,004h		; Four rows
L_6A64:
	ld bc,00004h		; Four characters per row
	ldir
	ld c,01ch		; And 0x1C to the next row
	ex de,hl
	add hl,bc
	ex de,hl
	dec a
	jr nz,L_6A64
	ret

	end

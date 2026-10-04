; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - shot_speed.asm
; ============================================================================

	public aim_from_where_it_is,dispatch_by_stage,finish_type_0F,finish_type_1,finish_type_11,finish_type_7
	public finish_with_aim,finish_with_slow_aim,L_6B96,set_both_speeds,set_horizontal_speed,set_vertical_speed
	public shot_speed
	extrn aim_at_ship,check_which_music_plays,end_of_stage_1,end_of_stage_10,end_of_stage_11,end_of_stage_12
	extrn end_of_stage_2,end_of_stage_3,end_of_stage_4,end_of_stage_5,end_of_stage_6,end_of_stage_7
	extrn end_of_stage_8,end_of_stage_9,wait_until_next_shot

; ----------------------------------------------------------------------
; THE SPEED OF THE SHOTS: DIFFICULTY PLUS R REGISTER
; The speed a shot comes out with is neither fixed nor truly random: it
; takes from the table at 0x6B97 the value that belongs to the difficulty
; (0xE111, twelve steps from 0x80 to 0x1C, that is, the harder the faster)
; and ADDS to it whatever three bits of the Z80's R register say, the
; memory refresh one. It is the third time this cartridge uses R as a
; number generator: the other two are the background stars and the
; shrapnel of the explosion, both in bank 0.
; ----------------------------------------------------------------------
shot_speed:		; The speed step the difficulty says, plus zero to seven from the R register
	push hl
	ld a,(0e111h)		; 0xE111 is the difficulty
	ld hl,06b97h
	add a,l
	ld l,a
	jr nc,L_6B90
	inc h
L_6B90:
	ld a,r			; The R register: three bits of unevenness
	and 007h
	add a,(hl)
	pop hl
L_6B96:
	ret

; ----------------------------------------------------------------------
; DATA speeds_by_difficulty: Twelve speed steps, one per difficulty level
;   (0xE111), going downhill: 0x80, 0x70, 0x68, 0x60, 0x48, 0x40, 0x38, 0x30,
;   0x28, 0x24, 0x20 and 0x1C. The lower the number, the faster the shot goes.
;   Read by 0x6B88, which also adds three bits of the R register to them.
speeds_by_difficulty:
	defb 80h,70h,68h,60h,48h,40h,38h,30h,28h,24h,20h,1Ch

; ----------------------------------------------------------------------
; DATA records_by_type: Four bytes per object type, which 0x6AF5 copies as
;   they are to the freshly set-up slot: it is each enemy's starting record.
;   Thirty-two types.
records_by_type:
	defb 1Ah,18h,14h,10h
	defb 01h,00h,00h,01h
	defb 01h,00h,00h,01h
	defb 00h,8Ch,0Eh,01h
	defb 00h,0B0h,02h,01h
	defb 00h,0E8h,0Ah,01h
	defb 00h,0A4h,05h,01h
	defb 01h,04h,00h,01h
	defb 00h,0BCh,04h,01h
	defb 00h,0DCh,0Ah,01h
	defb 00h,0BCh,02h,01h
	defb 00h,0ECh,02h,0FFh
	defb 01h,29h,00h,01h
	defb 00h,0E0h,04h,05h
	defb 00h,0FCh,08h,01h
	defb 00h,0CCh,00h,01h
	defb 00h,88h,08h,01h
	defb 01h,00h,00h,05h
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 01h,37h,00h,01h
	defb 01h,38h,00h,01h
	defb 01h,38h,00h,01h
	defb 01h,00h,00h,01h
	defb 01h,00h,00h,01h
	defb 00h,0F0h,0Fh,0Ah
	defb 00h,0CCh,09h,01h
	defb 00h,0A0h,06h,01h
	defb 00h,0D0h,07h,05h
	defb 00h,0E8h,07h,01h
finish_type_1:		; Gives it the speed halved and the drawing that bits 5 and 6 of 0xE122 say
	call wait_until_next_shot
	sra a			; Halved, keeping the sign
	ld (ix+010h),a
	ld a,(0e122h)
	ld c,a
	xor a
	bit 5,c			; Bit 5 of 0xE122...
	jr z,L_6C36
	ld a,002h
L_6C36:
	bit 6,c			; ...and bit 6: between the two they choose one of four drawings
	jr nz,L_6C3B
	inc a
L_6C3B:
	ld (ix+017h),a
	ret
finish_type_7:		; The hatch enemy: it goes out to one side or the other, depending on bit 0 of the type of whoever releases it, and with no vertical speed
	ld a,(0e123h)
	ld de,00400h		; 0x0400 to the right...
	rra
	jr nc,L_6C4B
	ld de,0fc00h		; ...or 0xFC00 to the left
L_6C4B:
	call set_vertical_speed
	ld de,00000h
	jr set_horizontal_speed
finish_with_slow_aim:		; Base speed 0x50 plus twice the difficulty
	ld c,050h
	jr L_6C59
finish_with_aim:		; The same but with base 0x60
	ld c,060h
L_6C59:
	ld a,(0e111h)		; The difficulty times two, added to the base
	add a,a
	add a,c
	ld (0e110h),a
aim_from_where_it_is:		; With the object's position, works out the two speeds towards the ship and stores them
	ld e,(ix+004h)
	ld d,(ix+006h)
	call aim_at_ship
	ld de,(0ec12h)		; The vertical speed...
	call set_vertical_speed
	ld de,(0ec14h)		; ...and the horizontal one
	jr set_horizontal_speed
finish_type_0F:		; Copies the speeds from 0xE142 and 0xE144, and gives it six to eight of counter with the R register
	ld hl,(0e142h)		; The speed the background carries
	ld (ix+007h),l
	ld (ix+008h),h
	ld hl,(0e144h)
	ld (ix+009h),l
	ld (ix+00ah),h
	ld a,(0e061h)		; In stage 4 the scroll goes the other way
	cp 004h
	ld hl,00088h
	jr nz,L_6C96
	ld hl,0ff78h
L_6C96:
	ld (ix+017h),l
	ld (ix+018h),h
	ld a,r			; The R register again: six or eight
	and 002h
	add a,006h
	ld (ix+00dh),a
	ret
finish_type_11:		; The drawing comes from 0xEC1B and it carries no speed
	ld a,(0ec1bh)
	ld (ix+00ch),a		; The drawing, from byte 12
	ld de,00000h
	call set_vertical_speed	; No speed
	jr set_horizontal_speed
set_both_speeds:		; The two speeds, crossed: first the Y one and then the X one
	ld de,(0ec14h)
	call set_horizontal_speed	; First the Y one...
	ld de,(0ec12h)		; ...and then the X one
set_vertical_speed:		; The object's vertical speed, in bytes 7 and 8
	ld (ix+007h),e
	ld (ix+008h),d
	ret
set_horizontal_speed:		; And the horizontal one, in bytes 9 and 10
	ld (ix+009h),e		; Bytes 9 and 10
	ld (ix+00ah),d
	ret
dispatch_by_stage:		; Twelve exits, one per stage
	call check_which_music_plays
	ld a,(0e061h)
	dec a
	call 04067h

; ----------------------------------------------------------------------
; DATA dispatcher_table_6CD4: Twelve words stuck right after the `call 0x4067`
;   at 0x6CD4.
dispatcher_table_6CD4:
	defw end_of_stage_1	; 0
	defw end_of_stage_2	; 1
	defw end_of_stage_3	; 2
	defw end_of_stage_4	; 3
	defw end_of_stage_5	; 4
	defw end_of_stage_6	; 5
	defw end_of_stage_7	; 6
	defw end_of_stage_8	; 7
	defw end_of_stage_9	; 8
	defw end_of_stage_10	; 9
	defw end_of_stage_11	; 10
	defw end_of_stage_12	; 11

	end

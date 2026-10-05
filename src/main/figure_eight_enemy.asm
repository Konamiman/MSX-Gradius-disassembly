; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - figure_eight_enemy.asm
; ============================================================================

	public finish_type_0C,move_type_0C
	extrn animate_round_and_round,dispatcher,fire_without_aiming,set_horizontal_speed,set_vertical_speed,zero_speed

; ----------------------------------------------------------------------
; THE ENEMY THAT FLIES A FIGURE EIGHT
; Type 0x0C chases nobody: it carries a written route, nine steps that are
; dispatched through byte 1. Each step waits for the column to reach a
; number (0x41, 9, 0x40, 0xAE, 0xE8, 0xB1) and then changes course. Bit 7
; of byte 1 does not count for the dispatch: it is a mirror, and it makes
; the ones that come in through the bottom half trace the same route upside
; down.
; ----------------------------------------------------------------------
finish_type_0C:		; Coming in through the bottom half, bit 7 of byte 1 flips the route over
	ld a,(ix+004h)		; Bit 7 of the row: which half it comes in through
	or a
	jp p,L_AE12
	ld (ix+001h),080h	; Bit 7 of byte 1: the route, mirrored
L_AE12:
	call zero_speed
	ld de,0fe00h		; Two points to the left
	jp set_horizontal_speed
move_type_0C:		; Nine route steps, dispatched through byte 1 without its bit 7
	call animate_type_0C	; Six drawings, one every eight frames
	call fire_without_aiming	; Fires without aiming
	ld a,(ix+001h)
	and 07fh		; Byte 1 without its bit 7: the step
	call dispatcher

; ----------------------------------------------------------------------
; DATA figure_eight_steps: Nine words stuck right after the `call dispatcher`
;   at 0xAE26.
figure_eight_steps:
	defw figure_eight_step_0	; 0
	defw figure_eight_step_1	; 1
	defw figure_eight_step_2	; 2
	defw figure_eight_step_3	; 3
	defw figure_eight_step_4	; 4
	defw figure_eight_step_5	; 5
	defw figure_eight_step_6	; 6
	defw figure_eight_step_7	; 7
	defw figure_eight_step_8	; 8
figure_eight_step_0:		; At column 0x41 it starts climbing (or descending, if mirrored) while still moving left
	ld a,(ix+006h)		; Up to column 0x41, straight on
	cp 041h
	ret nc
	inc (ix+001h)
	ld de,00200h
	bit 7,(ix+001h)		; The mirror: downwards or upwards
	jr z,L_AE50
	ld de,0fe00h
L_AE50:
	call set_vertical_speed
	ld de,0fe00h
	jp set_horizontal_speed
figure_eight_step_1:		; At column 9 it stops moving horizontally and holds for 0x11 frames
	ld a,(ix+006h)
	cp 009h			; Up to column 9
	ret nc
	inc (ix+001h)
	ld (ix+002h),011h	; 0x11 frames
	ld de,00000h
	jp set_horizontal_speed
figure_eight_step_2:		; Once the frames are used up, two points to the right
	dec (ix+002h)
	ret nz
	inc (ix+001h)
	ld de,00200h
	jp set_horizontal_speed
figure_eight_step_3:		; Past column 0x40, stops climbing and descending
	ld a,(ix+006h)		; Up to column 0x40, carrying on as it was
	cp 040h
	ret c
	inc (ix+001h)
	ld de,00000h		; And there it stops climbing and descending
	jp set_vertical_speed
figure_eight_step_4:		; At column 0xAE it curves the other way
	ld a,(ix+006h)		; Up to column 0xAE, carrying on as it was
	cp 0aeh
	ret c
	inc (ix+001h)
	ld de,0fe00h		; And there it curves the other way
	bit 7,(ix+001h)
	jr z,L_AE9D
	ld de,00200h
L_AE9D:
	jp set_vertical_speed
figure_eight_step_5:		; At column 0xE8 it stops and holds for 0x0F frames
	ld a,(ix+006h)
	cp 0e8h
	ret c
	inc (ix+001h)
	ld (ix+002h),00fh	; 0x0F frames
	ld de,00000h
	jp set_horizontal_speed
figure_eight_step_6:		; And then two points to the left again
	dec (ix+002h)
	ret nz
	inc (ix+001h)
	ld de,0fe00h
	jp set_horizontal_speed
figure_eight_step_7:		; Past column 0xB1, stops climbing and descending
	ld a,(ix+006h)		; Up to column 0xB1, carrying on as it was
	cp 0b1h
	ret nc
	inc (ix+001h)
	ld de,00000h		; And there it stops climbing and descending
	jp set_vertical_speed
figure_eight_step_8:		; The last step does nothing: the enemy carries on as it was
	ret
animate_type_0C:		; Six drawings, one every eight frames
	ld bc,00706h
	ld hl,type_0C_drawings
	jp animate_round_and_round

; ----------------------------------------------------------------------
; DATA type_0C_drawings: Six bytes read by 0xAED3.
type_0C_drawings:
	defb 29h,2Ah,2Bh,2Ch,2Bh,2Ah

	end

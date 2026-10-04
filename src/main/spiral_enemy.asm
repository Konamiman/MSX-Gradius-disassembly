; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - spiral_enemy.asm
; ============================================================================

	include "variables.inc"

	public release_big_ones_flock,start_big_ones_flock,turn_one_way

; ----------------------------------------------------------------------
; THE SPIRAL USES NO SINES: IT IS DONE WITH AN EIGHTH AND A MULTIPLICATION
; Turning around a centre comes here from a three-line rule: take the
; difference to the centre along one direction, divide it by eight (three
; `sra a`) and add it to the other; and with the other, the other way
; round. That gives a turn of about seven degrees per step, without
; touching any sine table. The radius shrinks separately: both coordinates
; are multiplied by byte 20, which starts at 0xFF and drops by one every
; 0x3C frames, so the loop closes on its own. Bit 0 of byte 30 picks the
; direction: the two pieces are the same with the signs swapped.
; ----------------------------------------------------------------------
turn_one_way:		; About seven degrees per step around the centre, with the radius shrinking
	bit 0,(ix+01eh)		; Bit 0 of byte 30: which way it turns
	jr z,turn_other_way
	ld a,(ix+004h)		; The row difference to the centre...
	sub (ix+015h)
	sra a			; ...divided by eight...
	sra a
	sra a
	add a,(ix+006h)		; ...is added to the column
	ld h,a
	ld e,(ix+014h)		; And byte 20 shrinks the radius
	call 06743h
	exx
	ld a,(ix+006h)		; The same with the column difference
	sub (ix+016h)
	sra a
	sra a
	sra a
	neg
	add a,(ix+004h)
	ld h,a
	ld e,(ix+014h)
	call 06743h
	ld (ix+004h),h
	exx
	ld (ix+006h),h
	dec (ix+002h)		; Byte 2: every 0x3C frames...
	ret nz
	ld (ix+002h),03ch
	ld a,(ix+014h)		; ...the radius loses a notch
	sub 001h
	ld (ix+014h),a
	ret
turn_other_way:		; The same dance with the signs swapped
	ld a,(ix+004h)		; The row difference to the centre...
	sub (ix+015h)
	sra a			; ...divided by eight and with its sign swapped...
	sra a
	sra a
	neg
	add a,(ix+006h)		; ...is added to the column
	ld h,a
	ld e,(ix+014h)		; And byte 20 shrinks the radius
	call 06743h
	exx
	ld a,(ix+006h)		; The same with the column difference
	sub (ix+016h)
	sra a
	sra a
	sra a
	add a,(ix+004h)
	ld h,a
	ld e,(ix+014h)
	call 06743h
	ld (ix+004h),h
	exx
	ld (ix+006h),h
	dec (ix+002h)		; Byte 2: every 0x3C frames...
	ret nz
	ld (ix+002h),03ch
	ld a,(ix+014h)		; ...the radius loses a notch
	sub 001h
	ld (ix+014h),a
	ret

; ----------------------------------------------------------------------
; DATA table_BB31: One hundred bytes read by 0xBA0A (0xBB31), 0xB991 (0xBB35),
;   0xB9C9 (0xBB45) and 0xBA52 (0xBB6D).
table_BB31:
	defb 0A0h,0A4h,0A8h,0ACh,68h,0C8h,44h,20h,30h,58h,78h,80h,28h,0B0h,70h,90h
	defb 6Ch,18h,40h,0D0h,60h,0B0h,0C0h,00h,4Ch,30h,0C0h,00h,38h,50h,0D4h,01h
	defb 58h,90h,0A6h,01h,30h,0A0h,0B8h,01h,60h,70h,0B2h,00h,64h,20h,90h,00h
	defb 30h,0C8h,9Ch,01h,1Ch,0Ch,0FFh,00h,8Ah,04h,0FFh,00h,00h,02h,00h,02h
	defb 00h,00h,00h,0FCh,00h,00h,00h,0FCh,00h,0FEh,00h,03h,80h,01h,80h,04h
	defb 00h,0FDh,00h,03h,0C0h,00h,00h,0FBh,00h,0FBh,0C0h,0FFh,00h,0FCh,0C0h,0FFh
	defb 00h,04h,0C0h,0FFh
start_big_ones_flock:		; Another timer like the one at 0xB946, with the cadence at 0x28 minus twice the difficulty
	ld a,001h		; 0xE990 to one: the flock is under way
	ld (BIGFLOCK_ON),a
	ld a,(DIFFICULTY)	; Plus 0x14, times 0x1E: how long it lasts
	add a,014h
	ld h,a
	ld e,01eh
	call 06743h
	ld (BIGFLOCK_TIMER),hl
	ld a,(DIFFICULTY)	; And 0x28 minus twice the difficulty, between one and the next
	add a,a
	sub 028h
	neg
	ld h,a
	ld l,a
	ld (BIGFLOCK_RELOAD),hl
	ret
release_big_ones_flock:		; While the timer lasts, a type 0x1E every few frames, taking turns among the four doors at 0xBBE9
	ld a,(SCROLL_MODE)	; With the screen stopped, no
	and a
	ret nz
	ld a,(BIGFLOCK_ON)	; Only with the flock under way
	or a
	ret z
	ld hl,(BIGFLOCK_TIMER)	; One frame less
	dec hl
	ld (BIGFLOCK_TIMER),hl
	ld a,l
	or h
	jp z,07d64h		; Once the timer has run out, the stage carries on
	ld hl,BIGFLOCK_COUNTDOWN	; The frames until the next one
	dec (hl)
	ret nz
	dec l
	ld a,(hl)
	inc l
	ld (hl),a
	inc l
	inc (hl)		; 0xE996: the door, four of them round and round
	ld a,(hl)
	and 003h
	inc l
	ld (hl),a
	ld hl,0bbe9h		; The table at 0xBBE9: four doors
	call 047aeh
	ld c,000h
	ld a,01eh		; Type 0x1E
	jp 06a72h

; ----------------------------------------------------------------------
; DATA table_BBE9: Eight bytes read by 0xBBDC, in pairs.
table_BBE9:
	defb 48h,12h
	defb 18h,0DEh
	defb 48h,0DEh
	defb 70h,0DEh

	end

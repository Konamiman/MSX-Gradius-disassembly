; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - bonus_target.asm
; ============================================================================

	include "variables.inc"

	public check_stretch_target,run_four_at_e880
	extrn blow_up_everything,check_if_sound,release_fan

; ----------------------------------------------------------------------
; THE TARGET THAT CLOSES THE STRETCH AND OPENS THE BONUS STAGE
; Five stages (1, 2, 3, 4 and 7) have a distance written into them at which
; a target appears: it is not one of the usual objects, but three loose
; bytes at TARGET..0xE1C3 (type, row and column) that move with the
; scroll. If the ship passes over it, with a margin of 0x10 in both
; directions, everything on screen blows up, the scroll stops at a limit of
; the stage's own, the script line is erased and sound 0xCD plays.
; AND IT IS ALSO THE DOOR TO THE BONUS STAGES. 0xB130 is the ONLY thing in
; the 128 KB that makes SCROLL_MODE non-zero, and p01:end_of_stage_2, end_of_stage_3, end_of_stage_4 and
; end_of_stage_7 (the finals of stages 2, 3, 4 and 7) look at exactly that byte:
; with the screen stopped they jump to stages 9, 10, 11 and 12, and
; otherwise they carry on with their normal script. So touching the target
; at the end of those four stages is what opens the interlude. The target
; of stage 1 leads to none.
; ----------------------------------------------------------------------
check_stretch_target:		; With the screen stopped, counts up to 0x40 and releases it; otherwise, checks whether the target is due and whether the ship has touched it
	ld a,(SHIP)		; No ship, nothing to check
	dec a
	ret m
	ld a,(SCROLL_MODE)	; The screen is stopped
	and a
	jr z,L_B05C
	ld hl,STOP_TIMER	; The frames left
	dec (hl)
	ret nz
	ld a,002h		; SCROLL_MODE to two and sound 0x41
	ld (SCROLL_MODE),a
	ld a,041h
	jp check_if_sound
L_B05C:
	call spawn_target_if_due
	ld a,(TARGET)		; Only if the target is in place
	and a
	ret z
	call check_ship_touches_it
	jp run_target
spawn_target_if_due:		; Each stage has its distance and its row; those not in the list have no target
	ld a,(NEW_COLUMN)	; Only on steps with a new column
	and a
	ret z
	ld a,(STAGE)		; The stage and the distance travelled
	ld hl,(DISTANCE)
	dec a
	jr z,stage_1_target
	dec a
	jr z,stage_2_target
	dec a
	jr z,stage_3_target
	dec a
	jr z,stage_4_target
	cp 003h			; And the seventh, with four subtractions already done
	jr z,stage_7_target
	ret
stage_1_target:		; At distance 0xFC, along row 0x88
	ld de,000fch		; At distance 0xFC...
	rst 20h
	ret nz
	ld e,088h		; ...along row 0x88
	ld c,002h
	jr L_B0C1
stage_2_target:		; At 0x190, along the same row 0x88
	ld de,00190h
	rst 20h
	ret nz
	ld e,088h
	jr set_target
stage_3_target:		; At 0x12A, along row 0x30
	ld de,0012ah
	rst 20h
	ret nz
	ld e,030h
	jr set_target
stage_4_target:		; Two distances, 0xC0 and 0x104, both along row 0x10
	ld de,000c0h		; At distance 0xC0, along row 0x10...
	rst 20h
	ld e,010h
	ld c,003h
	jr z,L_B0C1
	ld de,00104h		; ...and again at 0x104
	rst 20h
	ret nz
	ld e,010h
	ld c,004h
	jr L_B0C1
stage_7_target:		; At 0x177, along row 0x38
	ld de,00177h
	rst 20h
	ret nz
	ld e,038h
set_target:		; Type, row and column in TARGET, 0xE1C2 and 0xE1C3
	ld c,001h
L_B0C1:
	ld hl,TARGET
	ld (hl),c
	inc l
	ld (hl),e
	inc l
	ld (hl),0f0h		; It always comes in through column 0xF0
	ret
run_target:		; Eight points to the left for each new column; when it goes off screen, it is removed
	ld a,(NEW_COLUMN)
	and a
	ret z
	ld hl,TARGET+2
	ld a,(hl)
	sub 008h		; Eight points to the left
	ld (hl),a
	ret nc
	dec l
	dec l
	ld (hl),000h		; Off screen, the target is removed
	ret
check_ship_touches_it:		; With the ship less than 0x10 away in row and in column, the stretch ends
	ld hl,TARGET+1
	ld a,(SHIP_ROW)		; The ship's row against the target's
	sub (hl)
	add a,008h
	cp 010h			; A margin of 0x10
	ret nc
	inc l
	ld a,(SHIP_COLUMN)	; And the same with the column
	sub (hl)
	cp 010h
	ret nc
	ld a,(STAGE)		; Stages 2, 3 and 6 have their own limit
	sub 002h
	jr z,stage_2_limit
	dec a
	jr z,stage_3_limit
	cp 004h
	jr z,stage_6_limit
	ld hl,TARGET_KIND	; And in the others the count is kept here
	ld a,(TARGET)
	cp (hl)			; If it is of the same type as the last one, it does not count
	ret z
	ld (hl),a
	xor a
	ld (TARGET),a
	inc hl
	inc (hl)		; One more time, and on the third different one...
	ld a,(hl)
	cp 003h
	ret nz
	ld (hl),000h
	ld hl,001c0h		; ...the limit is 0x1C0
	jr close_stretch
stage_6_limit:		; The scroll stops at 0x1A0
	ld hl,001a0h
	jr close_stretch
stage_2_limit:		; At 0x1CF
	ld hl,001cfh
	jr close_stretch
stage_3_limit:		; At 0x19F
	ld hl,0019fh
close_stretch:		; Stops the scroll at its limit, erases the script line, blows everything up and plays 0xCD
	ld (SCROLL_LIMIT),hl	; How far the scroll goes
	ld a,040h		; 0x40 frames stopped
	ld (STOP_TIMER),a
	ld a,001h		; SCROLL_MODE to one: the screen stops, and the bonus stage hangs off this
	ld (SCROLL_MODE),a
	ld hl,00000h		; The script line, to zero
	ld (STAGE_SCRIPT_ROW),hl
	xor a
	ld (TARGET),a
	call blow_up_everything	; And everything on screen, blown up
	ld a,0cdh		; Sound 0xCD
	jp check_if_sound
run_four_at_e880:		; The four eight-byte cards at TURRETS, one by one
	ld ix,TURRETS
	ld b,004h		; Four cards
L_B14B:
	push bc
	ld a,(ix+000h)
	and a
	call nz,step_one_at_e880
	pop bc
	ld de,00008h		; Eight bytes per card
	add ix,de
	djnz L_B14B
	ret
step_one_at_e880:		; Moves with the scroll and, when it goes off screen, is switched off; otherwise, it takes its step
	ld a,(NEW_COLUMN)	; Only on steps with a new column
	and a
	jr z,L_B171
	ld a,(ix+003h)
	sub 008h		; Eight points to the left
	ld (ix+003h),a
	jr nc,L_B171
	ld (ix+000h),000h	; Off screen, the card is switched off
	ret
L_B171:
	ld a,(ix+001h)		; Byte 1: which step it is on
	dec a
	jr z,e880_step_1
	dec a
	jr z,e880_step_2
	dec a
	jr z,e880_step_3
	dec (ix+004h)		; Byte 4: the frames left
	ret nz
	bit 0,(ix+000h)		; Bit 0 of the type: some move and others do not
	jr z,L_B18F
	ld a,(ix+002h)
	sub 008h
	ld (ix+002h),a
L_B18F:
	ld (ix+004h),005h	; Five frames until the next one
	inc (ix+005h)		; Byte 5: three steps and it changes
	ld a,(ix+005h)
	cp 003h
	ret c
	inc (ix+001h)
	ret
e880_step_1:		; Every five frames takes a step of eight points, up or down according to bit 0 of the type, and when byte 7 runs out it stops for 0x18 frames
	dec (ix+004h)		; Byte 4: the frames until the next step
	ret nz
	ld (ix+004h),005h	; Five frames per step
	dec (ix+007h)		; Byte 7: the steps it has left
	jr nz,step_of_eight
	inc (ix+001h)
	ld (ix+004h),018h	; 0x18 frames stopped, and byte 5 to 0x30
	ld (ix+005h),030h
	ret
step_of_eight:		; Bit 0 of the type says whether it goes up or down
	bit 0,(ix+000h)		; Bit 0 of the type
	jr z,L_B1C8
	ld a,(ix+002h)		; Eight points upwards...
	sub 008h
	ld (ix+002h),a
	ret
L_B1C8:
	ld a,(ix+002h)		; ...or eight downwards
	add a,008h
	ld (ix+002h),a
	ret
e880_step_2:		; Byte 6 to zero and 0x20 frames of waiting
	ld (ix+006h),000h	; Byte 6 to zero: the turret goes in
	dec (ix+004h)		; 0x20 frames inside
	ret nz
	inc (ix+001h)
	ld (ix+004h),020h
	ret
e880_step_3:		; Byte 6 to one, and when the wait runs out it releases the fan and goes back to step 2
	ld (ix+006h),001h	; Byte 6 to one: the turret peeks out
	dec (ix+004h)
	ret nz
	call release_fan	; And releases the fan
	dec (ix+001h)
	ld a,(DIFFICULTY)	; The difficulty halved, subtracted from 0x18: how long until it fires again
	sra a
	ld c,a
	ld a,018h
	sub c
	ld (ix+004h),a
	ret

	end

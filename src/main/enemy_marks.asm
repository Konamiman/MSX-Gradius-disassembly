; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - enemy_marks.asm
; ============================================================================

	include "variables.inc"

	public mark_next_or_not,release_bottom_four,release_flock,release_left_ones,release_mixed_eight

; ----------------------------------------------------------------------
; ONE IN FOUR COMES OUT MARKED
; The adjustment passed to spawn_object is the enemy's mark: with it at
; zero the enemy comes out like the rest, and when it is non-zero
; p01:0x6B0D gives it colour 8 (the red one) and p00:0x5E88 changes what
; it leaves behind when it dies. The table at 0xA5C7 hands it out round and
; round: three at zero and one marked, and once in every sixteen the mark
; is 2 instead of 1.
; ----------------------------------------------------------------------
mark_next_or_not:		; A counter going round the table at 0xA5C7: three enemies out of four come out unmarked
	ld hl,MARK_COUNTER	; How many enemies have been requested
	ld a,(hl)
	and 00fh		; The four low bits: sixteen entries
	inc (hl)		; And one more for the next one
	ld hl,0a5c7h
	call 0405dh
	ld c,(hl)
	ret

; ----------------------------------------------------------------------
; DATA table_A5C7: Sixteen bytes read by 0xA5BF, in groups of four.
table_A5C7:
	defb 00h,00h,00h,01h
	defb 00h,00h,00h,01h
	defb 00h,00h,00h,02h
	defb 00h,00h,00h,01h
release_flock:		; Eight type 9 enemies, one every seven frames: the first four along the bottom and the last four along the top
	ld hl,FLOCK_COUNT	; How many are left of the flock
	ld a,(hl)
	and a
	jp z,wait_for_flock
	inc l			; 0xE963: the frames until the next one
	dec (hl)
	ret nz
	ld (hl),007h		; Seven frames between one enemy and the next
	dec l
	dec (hl)		; One fewer of the eight
	jp nz,L_A5ED
	inc l
	ld (hl),03ch		; With the flock out, 0x3C frames until the next one
	dec l
L_A5ED:
	ld a,(hl)		; From four onwards...
	cp 004h
	ld e,088h		; ...row 0x88, along the bottom
	jp nc,L_A5F7
	ld e,018h		; And the last four along 0x18
L_A5F7:
	ld d,0f0h		; All eight come in from the right
	ld c,000h
	ld a,009h
	jp 06a72h
wait_for_flock:		; When the countdown runs out, the next flock is set up with eight
	inc l			; 0xE963: the frames until the next flock
	ld a,(hl)
	or a
	jp z,L_A608
	dec (hl)
	ret nz
L_A608:
	inc (hl)
	dec l
	ld (hl),008h		; Eight per flock
	ret
release_left_ones:		; Eight type 5 enemies that come in through the LEFT edge, taking turns between row 8 and 0x90
	ld hl,LEFT_ONES_COUNT	; How many are left
	ld a,(hl)
	and a
	jp z,set_up_left_ones
	inc l			; 0xE967: the frames until the next one
	dec (hl)
	ret nz
	ld a,(DIFFICULTY)	; The difficulty times four, subtracted from 0x70: the wait
	add a,a
	add a,a
	sub 070h
	neg
	ld (hl),a
	dec l
	dec (hl)		; One fewer
	ld a,(hl)
	and 007h		; The three low bits: the row goes by turns
	ld hl,0a640h
	add a,l
	ld l,a
	jr nc,L_A62F
	inc h
L_A62F:
	ld e,(hl)
	ld d,000h		; X at zero: these come in from the LEFT
	call mark_next_or_not	; With its mark, if it gets one
	ld a,005h
	jp 06a72h
set_up_left_ones:		; Another eight, and the first one on the next frame
	ld (hl),008h
	inc l
	ld (hl),001h
	ret

; ----------------------------------------------------------------------
; DATA table_A640: Eight bytes read by 0xA627.
table_A640:
	defb 08h,90h,08h,08h,90h,08h,90h,90h
release_bottom_four:		; Four type 6 enemies along row 0x8F: the first three from the right and the last one from the left
	ld hl,BOTTOM_FOUR_COUNT	; How many are left of the four
	ld a,(hl)
	and a
	jp z,set_up_bottom_four
	inc l			; 0xE96B: the frames until the next one
	dec (hl)
	ret nz
	ld a,(DIFFICULTY)	; The difficulty times four, subtracted from 0x60: the wait
	add a,a
	add a,a
	sub 060h
	neg
	ld (hl),a
	dec l
	dec (hl)		; One fewer
	ld a,(hl)
	and 003h
	ld e,08fh		; All along row 0x8F
	ld d,0f0h		; From the right...
	jp nz,L_A66B
	ld d,000h		; ...except the last one, which comes in from the left
L_A66B:
	call mark_next_or_not	; With its mark, if it gets one
	ld a,006h
	jp 06a72h
set_up_bottom_four:		; Another four, and the first one on the next frame
	ld (hl),004h
	inc l
	ld (hl),001h
	ret
release_mixed_eight:		; Eight enemies: the first four of type 5 on the side opposite the ship, and the last four of type 6 alternating sides
	ld hl,BOTTOM_FOUR_COUNT	; The same count as 0xA648
	ld a,(hl)
	and a
	jp z,set_up_mixed_eight
	inc l
	dec (hl)
	ret nz
	ld a,(DIFFICULTY)	; The difficulty times four, subtracted from 0x50
	add a,a
	add a,a
	sub 050h
	neg
	ld (hl),a
	dec l
	dec (hl)
	ld a,(hl)
	cp 004h			; The first four go elsewhere
	jr nc,enter_opposite_side
	bit 0,a			; Bit 0 of the count: one side and then the other
	ld d,0f0h
	jr nz,L_A69D
	ld d,000h
L_A69D:
	ld e,090h		; The type 6 ones, along row 0x90
	ld c,000h
	ld a,006h
	jp 06a72h
enter_opposite_side:		; Looks at which half the ship is in and releases the enemy through the other one
	ld a,(SHIP_ROW)		; The ship's row
	cp 058h			; Above the middle of the screen...
	ld e,090h
	jr c,L_A6B1
	ld e,008h		; ...the enemy comes in at the top, and otherwise at the bottom
L_A6B1:
	ld d,000h		; The type 5 ones, always from the left
	ld c,000h
	ld a,005h
	jp 06a72h
set_up_mixed_eight:		; Another eight, and the first one on the next frame
	ld (hl),008h
	inc l
	ld (hl),001h
	ret

	end

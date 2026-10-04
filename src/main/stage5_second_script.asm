; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - stage5_second_script.asm
; ============================================================================

	include "variables.inc"

	public advance_1B_script,check_1B_script,finish_type_1B,finish_type_1D,move_type_1B,move_type_1D
	public release_long_flock,start_long_flock
	extrn animate_round_and_round,fire_without_aiming,negate_vertical_speed,turn_one_way

; ----------------------------------------------------------------------
; THE SECOND SCRIPT OF STAGE 5
; The fifth stage has two lists of distances: the one at 0xB7BF, which sets
; up the background pieces, and this one at 0xB8B4, which releases type
; 0x1B enemies. Here the word is packed even tighter than in stage 7: bits
; 0 and 1 of the high byte are the high bits of the distance (ten in all)
; and the top five are saved in 0xE97E, from where the band the enemy
; bounces in and its speed are taken later. The list ends at 0xFFFF.
; ----------------------------------------------------------------------
advance_1B_script:		; Skips the lines that are already behind
	ld a,(STAGE)		; Only stage 5
	cp 005h
	ret nz
	call release_this_1B
	jp z,advance_1B_script
	ret c
	ld hl,STAGE5_SCRIPT_POS	; Which line it is on
	inc (hl)
	jp advance_1B_script
check_1B_script:		; On every step with a new column, releases the enemies that fall at this distance
	ld a,(STAGE)		; Only stage 5
	cp 005h
	ret nz
	ld a,(NEW_COLUMN)	; And only on steps with a new column
	and a
	ret z
	ld a,0f8h		; 0xEC04 to 0xF8: they come in from the right
	ld (ENTRY_X),a
release_due_1Bs:		; One after another as long as they match
	call release_this_1B
	jp z,release_due_1Bs
	ret
release_this_1B:		; Unpacks the line: the top five bits to 0xE97E, and from there comes the row
	call is_this_the_1B_distance
	ret nz
	ld hl,STAGE5_SCRIPT_POS	; One line fewer
	inc (hl)
	ld a,c			; The top five bits, to 0xE97E
	rra
	rra
	and 01fh
	ld (STAGE5_LINE_BITS),a
	rra			; Its bit 0: along row 8...
	ld e,008h
	jr nc,L_B891
	rra			; ...or along one of the three at 0xB89E
	rra
	and 003h
	ld c,a
	ld b,000h
	ld hl,0b89eh
	add hl,bc
	ld e,(hl)
L_B891:
	ld a,(ENTRY_X)
	ld d,a
	ld c,000h
	ld a,01bh		; Type 0x1B
	call 06a72h
	xor a
	ret

; ----------------------------------------------------------------------
; DATA table_B89E: Three bytes (0x90, 0x58, 0x20) read by 0xB88C and 0xB925.
table_B89E:
	defb 90h,58h,20h
is_this_the_1B_distance:		; Compares the line's ten bits of distance with the distance travelled
	ld hl,0b8b4h		; The word that is due from the list
	ld a,(STAGE5_SCRIPT_POS)
	call 047aeh
	ld c,d
	ld a,d			; The high byte is saved whole...
	and 003h		; ...and of it only two bits are distance
	ld d,a
	ld hl,(DISTANCE)	; DCOMPR against the distance travelled
	rst 20h
	ret

; ----------------------------------------------------------------------
; DATA table_B8B4: Thirty-eight bytes read by 0xB8A1, in pairs.
table_B8B4:
	defb 42h,01h
	defb 48h,11h
	defb 4Eh,09h
	defb 53h,15h
	defb 58h,05h
	defb 5Dh,0Dh
	defb 61h,01h
	defb 65h,11h
	defb 69h,09h
	defb 6Ch,1Dh
	defb 70h,01h
	defb 73h,0Dh
	defb 76h,11h
	defb 79h,1Dh
	defb 8Ah,35h
	defb 8Dh,35h
	defb 0AEh,55h
	defb 0B4h,4Dh
	defb 0FFh,0FFh
finish_type_1B:		; From 0xE97E come the band it bounces in and which of the six speeds it has
	ld a,(STAGE5_LINE_BITS)	; What its line brought packed
	ld b,a
	rra
	rra
	rra
	and 003h		; Two bits: the band, to byte 19
	ld (ix+013h),a
	ld a,b
	and 007h		; And three: which of the speeds
	srl a
	push af
	ld b,a
	ld a,(LOOP_NUMBER)	; From the second loop onwards, two notches faster
	or a
	jr z,L_B8F5
	inc b
	inc b
L_B8F5:
	ld a,b
	ld hl,0b909h		; The table at 0xB909: six speeds
	call 047aeh
	pop af
	call c,06729h		; And the leftover bit gives it its sign
	call 06cbfh
	ld de,0ff00h		; One point to the left
	jp 06cc6h

; ----------------------------------------------------------------------
; DATA table_B909: Twelve bytes read by 0xB8F6, as words.
table_B909:
	defw 0080h,0100h
	defw 0180h,0200h
	defw 0300h,0400h
move_type_1B:		; Bounces between row 8 and the bottom of its band, reversing the speed when it gets there
	ld bc,00308h		; Eight drawings, one every four frames
	ld hl,0b93eh
	call 095d1h
	ld c,008h		; The ceiling, row 8
	ld e,(ix+013h)		; And the floor, that of its band
	ld d,000h
	ld hl,0b89eh
	add hl,de
	ld b,(hl)
	ld a,(ix+008h)		; Byte 8: climbing or descending
	or a
	ld a,(ix+004h)
	jp m,L_B939
	cp b			; On reaching the floor, it is turned round
	ret c
	jp negate_vertical_speed
L_B939:
	cp c			; And on reaching the ceiling, too
	ret nc
	jp 09590h

; ----------------------------------------------------------------------
; DATA table_B93E: Eight bytes read by 0xB918: another there and back (0xF0,
;   0xF4, 0xF8, 0xFC, 0xFC, 0xF8, 0xF4, 0xF0).
table_B93E:
	defb 0F0h,0F4h,0F8h,0FCh,0FCh,0F8h,0F4h,0F0h
start_long_flock:		; A timer of 0x1E frames for each notch of difficulty plus 0x14, and a cadence of 0x1F minus the difficulty
	ld a,001h		; 0xE988 to one: the flock is under way
	ld (LFLOCK_ON),a
	ld a,(DIFFICULTY)	; Plus 0x14, times 0x1E: the frames it lasts
	add a,014h
	ld h,a
	ld e,01eh
	call 06743h
	ld (LFLOCK_TIMER),hl
	ld a,(DIFFICULTY)	; And 0x1F minus the difficulty: the frames between one enemy and the next
	sub 01fh
	neg
	ld h,a
	ld l,a
	ld (LFLOCK_RELOAD),hl
	ret
release_long_flock:		; While the timer lasts, a type 0x1D every few frames; one in eight comes out wherever the ship is
	ld a,(SCROLL_MODE)	; With the screen stopped, no
	and a
	ret nz
	ld a,(LFLOCK_ON)	; Only with the flock under way
	or a
	ret z
	ld hl,(LFLOCK_TIMER)	; One frame less of flock
	dec hl
	ld (LFLOCK_TIMER),hl
	ld a,l
	or h
	jp z,07d64h		; Once the timer has run out, the stage carries on
	ld hl,LFLOCK_COUNTDOWN	; The frames until the next one
	dec (hl)
	ret nz
	dec l
	ld a,(hl)		; Reloaded from 0xE98B
	inc l
	ld (hl),a
	inc l
	ld a,(hl)		; 0xE98D: how many so far
	inc (hl)
	and 007h		; One in eight goes its own way
	call z,this_one_goes_at_ship
	inc l
	ld (hl),a
	jr c,L_B997
	ld hl,0bb35h		; And the rest follow the list at 0xBB35
	call 047aeh
L_B997:
	ld c,000h
	ld a,01dh		; Type 0x1D
	jp 06a72h
this_one_goes_at_ship:		; With the ship hugging an edge, the enemy comes in through that same edge and at the ship's column
	ld b,a
	ld a,(SHIP_ROW)		; The ship's row
	cp 008h			; Hugging the top...
	jr c,enter_from_top
	cp 090h			; ...or hugging the bottom
	jr nc,enter_from_bottom
	xor a			; And in the middle, the one from the list
	ld a,b
	ret
enter_from_top:		; At the ship's column and row 0x0C
	ld a,(SHIP_COLUMN)	; The ship's column
	ld d,a
	ld e,00ch		; And row 0x0C: at the very top
	ld a,008h
	scf
	ret
enter_from_bottom:		; At the ship's column and row 0x8E
	ld a,(SHIP_COLUMN)	; The ship's column
	ld d,a
	ld e,08eh		; And row 0x8E: at the very bottom
	ld a,009h
	scf
	ret
finish_type_1D:		; From the table at 0xBB45 come the centre of its spiral, its count and its direction of turn
	ld a,(LFLOCK_VARIANT)	; The variant, to byte 19
	ld (ix+013h),a
	add a,a
	add a,a
	ld hl,0bb45h		; The table at 0xBB45: four bytes per variant
	ld e,a
	ld d,000h
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld a,(LFLOCK_VARIANT)	; From variant 8 onwards, the centre is set four away from where it is
	cp 008h
	jr c,L_B9E0
	ld a,(ix+006h)
	sub 004h
	ld d,a
L_B9E0:
	ld (ix+015h),e		; Bytes 21 and 22: the centre of the spiral
	ld (ix+016h),d
	inc hl
	ld a,(hl)
	ld (ix+01ch),a		; Byte 28: the frames of the first turn
	inc hl
	ld a,(hl)
	ld (ix+01eh),a		; And byte 30: which way it turns
	ld (ix+014h),0ffh	; Byte 20 to 0xFF: the radius, whole
	ld (ix+002h),032h	; 0x32 frames
	ld (ix+01bh),000h
	jp 09510h
move_type_1D:		; Fires, crashes if it touches the map and, once its count is over, starts turning in a spiral
	ld bc,00304h		; Four drawings, one every four frames
	ld a,(ix+001h)
	or a
	jr nz,L_BA0A
	ld b,001h
L_BA0A:
	ld hl,0bb31h
	call animate_round_and_round
	ld l,(ix+004h)		; Its row and its column...
	ld h,(ix+006h)
	call 09857h		; ...against the map: if it hits, it blows up
	jp c,072d2h
	ld a,(ix+001h)		; Byte 1: which step it is on
	dec a
	jp z,type_1D_starts_spiral
	ret p
	dec (ix+002h)		; Byte 2: the frames left
	jr z,type_1D_holds
	ld a,(ix+002h)
	cp 01eh			; With 0x1E to go, it starts blinking
	ret nc
	ld b,008h		; Colour 8, and 9 in the last ten
	cp 00ah
	jr nc,L_BA36
	inc b
L_BA36:
	ld (ix+00dh),b
	ret
type_1D_holds:		; Another 0x3C frames, and byte 27 to three
	ld (ix+002h),03ch
	ld (ix+01bh),003h
	inc (ix+001h)
	ret
type_1D_starts_spiral:		; When byte 28 runs out it takes the two speeds for its variant
	call type_1D_fires
	dec (ix+01ch)		; Byte 28: how much straight flight it has left
	jp nz,turn_one_way
	inc (ix+001h)
	ld hl,0bb6dh		; The table at 0xBB6D: two speeds per variant
	ld a,(ix+013h)
	add a,a
	add a,a
	ld e,a
	ld d,000h
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	call 06cbfh
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	jp 06cc6h
type_1D_fires:		; With the ship's shield on it fires every 0x40 or every 0x20 frames; otherwise, without a count
	ld a,(OPTION_COUNT)	; The ship's shield
	dec a
	ld b,03fh
	jr z,type_1D_fires_at_times
	ld b,01fh
	jp p,type_1D_fires_at_times
	ld a,(LOOP_NUMBER)	; From the second loop onwards, always
	or a
	jp nz,fire_without_aiming
	ld a,(SHIP)		; And also with the ship halfway through coming out or exploding
	cp 003h
	jp z,09235h
	ld a,(SHIP_LASER)
	or a
	jp nz,09235h
	ret
type_1D_fires_at_times:		; Every 0x40 or every 0x20 frames, depending on the shield
	ld a,(FRAME_COUNT)
	and b
	ret nz
	ld a,(CONTROLLER_NEW)	; Bit 4
	and 010h
	ret z
	jp 09239h

	end

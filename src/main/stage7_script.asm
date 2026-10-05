; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - stage7_script.asm
; ============================================================================

	include "variables.inc"

	public advance_script,check_script,finish_type_0D,move_type_0D
	extrn aim_from_where_it_is,animate_type_0D,get_word,set_horizontal_speed,spawn_object,zero_speed

; ----------------------------------------------------------------------
; STAGE 7 RUNS ON A SCRIPT, AND EACH APPEARANCE FITS IN ONE WORD
; The other stages release enemies in bursts; the seventh has them WRITTEN
; one by one in the list at stage_7_script, forty-three appearances in eighty-six
; bytes. Each one is a single, tightly packed word: the low byte and bit 0
; of the high byte are the distance (nine bits) at which it appears, bits 1
; and 2 of the high byte are the variant, and the top five, the row. The
; list is walked with a cursor at STAGE7_SCRIPT_POS and ends at 0xFFFF.
; ----------------------------------------------------------------------
advance_script:		; Skips in one go all the appearances that are already behind the distance travelled
	ld a,(STAGE)		; Only stage 7 has a script
	cp 007h
	ret nz
	call spawn_this_appearance
	jp z,advance_script	; As long as they keep falling due, they keep being taken out
	ret c			; Once past the distance of the one that is due, it stops
	ld hl,STAGE7_SCRIPT_POS
	inc (hl)		; And the ones left behind are skipped
	jp advance_script
check_script:		; On every step with a new column, releases all the appearances that fall at this distance
	ld a,(STAGE)		; Only stage 7
	cp 007h
	ret nz
	ld a,(NEW_COLUMN)	; And only on steps with a new column
	and a
	ret z
	ld a,0f8h		; ENTRY_X to 0xF8: they all come in from the right
	ld (ENTRY_X),a
spawn_due_ones:		; One after another as long as they match
	call spawn_this_appearance
	jp z,spawn_due_ones
	ret
spawn_this_appearance:		; If the list's distance is the current one, moves the cursor on and releases the enemy
	call is_this_the_distance	; Without a match, there is nothing to do
	ret nz
	ld hl,STAGE7_SCRIPT_POS
	inc (hl)		; One appearance fewer in the list
	ld a,c			; The top five bits: the row
	and 0f8h
	ld e,a
	ld a,(ENTRY_X)		; With the column below 0x80 nothing is released
	cp 080h
	jr nc,spawn_type_0D
	xor a
	ret
spawn_type_0D:		; The column, the row and the variant already unpacked
	ld d,a
	ld a,c			; Bits 1 and 2: the variant
	rra
	and 003h
	ld c,a
	ld a,00dh		; Type 0x0D
	call spawn_object
	xor a
	ret
is_this_the_distance:		; Unpacks the script word and compares its nine bits of distance with the distance travelled
	ld hl,stage_7_script	; The word that is due from the list
	ld a,(STAGE7_SCRIPT_POS)
	call get_word
	ld c,d			; The high byte is saved whole...
	ld a,d
	and 001h		; ...and of it only bit 0 is distance
	ld d,a
	ld hl,(DISTANCE)	; DCOMPR against the distance travelled
	rst 20h
	ret

; ----------------------------------------------------------------------
; DATA stage_7_script: Eighty-six bytes read by is_this_the_distance, in pairs.
stage_7_script:
	defb 94h,28h
	defb 0ACh,68h
	defb 0B3h,18h
	defb 0B5h,28h
	defb 0B7h,18h
	defb 0B9h,3Ah
	defb 0C1h,18h
	defb 0C8h,32h
	defb 0C9h,70h
	defb 0CDh,38h
	defb 0CDh,72h
	defb 0D5h,3Ah
	defb 0D6h,50h
	defb 0D6h,64h
	defb 0D8h,50h
	defb 0D8h,60h
	defb 0DBh,68h
	defb 0DDh,38h
	defb 0E9h,1Ah
	defb 0EAh,30h
	defb 0EAh,40h
	defb 0ECh,30h
	defb 0ECh,40h
	defb 0EEh,62h
	defb 0F1h,38h
	defb 0F3h,68h
	defb 01h,09h
	defb 06h,55h
	defb 06h,61h
	defb 08h,51h
	defb 08h,63h
	defb 09h,19h
	defb 13h,69h
	defb 15h,79h
	defb 25h,19h
	defb 26h,33h
	defb 26h,41h
	defb 28h,31h
	defb 28h,41h
	defb 29h,7Bh
	defb 3Dh,39h
	defb 5Ch,89h
	defb 0FFh,0FFh
finish_type_0D:		; Byte 20 to one, ten frames in byte 2, byte 28 to 0xFF, and still
	xor a
	ld (ix+01dh),a
	inc a
	ld (ix+014h),a
	ld (ix+002h),00ah	; Ten frames
	ld (ix+01ch),0ffh
	jp zero_speed
type_0D_leaves:		; Step 2, drawing 0xDC in colour 0x0D and one point to the left
	ld (ix+001h),002h	; Step 2: it is already leaving
	ld (ix+00ch),0dch	; Drawing 0xDC in colour 0x0D
	ld (ix+00dh),00dh
	call zero_speed
	ld de,0ff00h		; One point to the left
	jp set_horizontal_speed
move_type_0D:		; Stays in place firing every ten frames until its 0xFF of life run out, and then leaves
	ld a,(ix+001h)		; From step 2 onwards it is already leaving
	cp 002h
	ret nc
	dec (ix+01ch)		; Byte 28: 0xFF frames of life
	jr z,type_0D_leaves
	call animate_type_0D	; The drawing, which changes out of step
	ld a,(ix+001h)		; Byte 1: still or firing
	dec a
	jr z,type_0D_rests
	dec (ix+002h)		; Ten frames per step
	ret nz
	inc (ix+001h)
	ld (ix+002h),00ah
	call speed_by_difficulty	; The speed of the shot, from the difficulty
	jp aim_from_where_it_is
type_0D_rests:		; Another ten frames still and then back to firing
	dec (ix+002h)
	ret nz
	dec (ix+001h)
	ld (ix+002h),00ah
	jp zero_speed
speed_by_difficulty:		; From the ramp at ramp_B000: 0x1A and two more for each notch of difficulty
	ld a,(DIFFICULTY)	; The difficulty indexes the ramp at ramp_B000
	ld hl,ramp_B000
	add a,l
	ld l,a
	jr nc,L_AFFB
	inc h
L_AFFB:
	ld a,(hl)
	ld (ENEMY_SHOT_SPEED),a	; The speed of the shots
	ret

; ----------------------------------------------------------------------
; DATA ramp_B000: Sixteen bytes going up in twos (0x1A, 0x1C, 0x1E, ...) read
;   by 0xAFF3.
ramp_B000:
	defb 1Ah,1Ch,1Eh,20h,22h,24h,26h,28h,2Ah,2Ch,2Eh,30h,32h,34h,36h,38h

	end

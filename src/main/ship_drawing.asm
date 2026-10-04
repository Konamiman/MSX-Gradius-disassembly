; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - ship_drawing.asm
; ============================================================================

	include "variables.inc"

	public L_998C,place_ship
	extrn controller_speed,get_word,next_ship_state,times_speed_steps

; ----------------------------------------------------------------------
; THE SHIP'S DRAWING COMES FROM WHAT IS BEING PRESSED
; The ship has no animation: its drawing is a function of the two low bits
; of the joystick (up and down), which index a table of four-byte cards.
; And there are three different tables depending on what you are playing
; with: the normal one, and two others that are only used if 0xF0F4 is
; set, that is, if at start-up the other Konami cartridge was found in the
; machine.
; ----------------------------------------------------------------------
place_ship:		; Sets the ship's sprite card: the position, and the drawing that goes with whatever is being pressed
	ld a,(SCROLL_MODE)	; Not with the screen stopped
	and a
	ret nz
	ld a,(SHIP)		; At zero or negative: there is no ship
	or a
	ret z
	jp m,next_ship_state
	ld a,(ENDING)		; With an explosion under way, the position comes from 0xE1D3
	and a
	jr z,L_9974
	ld de,(ENDING_SHIP_Y)
	ld hl,SHIP+5
	call add_de_to_word
	jr L_998C
L_9974:
	call controller_speed	; The joystick speed, the steps and the new position
	call times_speed_steps
	ld hl,SHIP+3		; The screen limits
	call add_de_to_word	; The new position
	call clamp_ship_y
	inc l
	ld d,b
	ld e,c
	call add_de_to_word
	call clamp_ship_x
L_998C:
	ld a,(TWINBEE_FOUND)	; With the other cartridge inserted, other tables
	or a
	ld hl,099e3h
	jr z,L_99A1
	ld a,(GAME_FLAGS)	; And bit 7 chooses between the two
	add a,a
	ld hl,09a25h
	jr nc,L_99A1
	ld hl,09a67h
L_99A1:
	ld a,(SHIP)		; The ship's state
	call get_word
	ex de,hl
	ld de,SHIP+7
	ld bc,CONTROLLER	; The joystick; when paused, 0xE10D
	ld a,(PAUSE_COUNT)
	rra
	jr nc,L_99B7
	ld bc,PAUSE_JOYSTICK
L_99B7:
	ld a,(bc)
	and 003h		; The two low bits: up and down
	cp 003h
	jp nz,L_99C0
	xor a
L_99C0:
	add a,a			; Times four: four bytes per card
	add a,a
	ex af,af'
	ld a,(SHIP)
	dec a
	jp z,L_99D6
	ld a,(FRAME_COUNT)	; With the ship just out, it blinks every four frames
	and 004h		; A bit of the counter: it blinks
	jp z,L_99D6		; One in every four frames
	ex af,af'
	add a,00ch
	ex af,af'
L_99D6:
	ex af,af'
	add a,l
	ld l,a
	jr nc,L_99DC
	inc h
L_99DC:
	ldi			; The four bytes of the sprite card
	ldi
	ldi
	ldi
	ret

; ----------------------------------------------------------------------
; DATA table_99E3 (part): Sixty-six bytes read by 0x9990.
table_99E3_99E5:
	defb 0EBh,99h,0F7h,99h,0Fh,9Ah,00h,0Fh,04h,08h,10h,0Fh,14h,05h,08h,0Fh
	defb 0Ch,08h,00h,0Fh,3Ch,06h,00h,0Fh,3Ch,06h,08h,0Fh,34h,06h,00h,0Fh
	defb 40h,09h,00h,0Fh,40h,09h,08h,0Fh,38h,09h,00h,0Fh,2Ch,0Fh,00h,0Fh
	defb 2Ch,0Fh,08h,0Fh,24h,0Fh,00h,0Fh,30h,07h,00h,0Fh,30h,07h,08h,0Fh

; ----------------------------------------------------------------------
; DATA table_9A25: Sixty-six bytes read by 0x9999.
table_9A25:
	defb 28h,07h,2Dh,9Ah,39h,9Ah,51h,9Ah,00h,07h,04h,0Bh,00h,07h,04h,0Bh
	defb 00h,07h,04h,0Bh,08h,07h,3Ch,0Bh,08h,07h,3Ch,0Bh,08h,07h,34h,0Bh
	defb 08h,07h,40h,0Fh,08h,07h,40h,0Fh,08h,07h,38h,0Fh,08h,07h,2Ch,0Bh
	defb 08h,07h,2Ch,0Bh,08h,07h,24h,0Bh,08h,07h,30h,0Fh,08h,07h,30h,0Fh
	defb 08h,07h

; ----------------------------------------------------------------------
; DATA table_9A67: Sixty-eight bytes read by 0x999E.
table_9A67:
	defb 28h,0Fh,6Fh,9Ah,7Bh,9Ah,93h,9Ah,00h,0Dh,04h,0Bh,00h,0Dh,04h,0Bh
	defb 00h,0Dh,04h,0Bh,08h,0Dh,3Ch,0Bh,08h,0Dh,3Ch,0Bh,08h,0Dh,34h,0Bh
	defb 08h,0Dh,40h,0Fh,08h,0Dh,40h,0Fh,08h,0Dh,38h,0Fh,08h,0Dh,2Ch,0Bh
	defb 08h,0Dh,2Ch,0Bh,08h,0Dh,24h,0Bh,08h,0Dh,30h,0Fh,08h,0Dh,30h,0Fh
	defb 08h,0Dh,28h,0Fh
clamp_ship_x:		; X stays between 0x08 and 0xD8
	cp 008h			; On the left, 0x08
	jp nc,L_9AB2
	ld a,008h
L_9AB2:
	cp 0d9h			; And on the right, 0xD8
	jp c,L_9AB9
	ld a,0d8h
L_9AB9:
	ld (hl),a
	ret
clamp_ship_y:		; Y stays between 0x13 and 0xB5, except on stages 2, 6 and from 9 onwards, which start at 0x10
	add a,010h
	ex af,af'
	ld a,(STAGE)		; Stages 2, 6 and from 9 onwards have another ceiling
	cp 002h			; Stages 2, 6 and from 9 onwards
	jp z,L_9AE3
	cp 006h
	jp z,L_9AE3
	cp 009h
	jp nc,L_9AE3
	ex af,af'
	cp 013h			; At the top, 0x13
	jp nc,L_9AD8
	ld a,013h
L_9AD8:
	cp 0b6h			; And at the bottom, 0xB5
	jp c,L_9ADF
	ld a,0b5h
L_9ADF:
	sub 010h
	ld (hl),a
	ret
L_9AE3:
	ex af,af'
	cp 010h			; On the other stages, the ceiling is 0x10
	jp nc,L_9AEB
	ld a,010h
L_9AEB:
	jp L_9AD8
add_de_to_word:		; Adds DE to the 16-bit word at HL
	ld a,(hl)		; The low byte...
	add a,e
	ld (hl),a
	inc l
	ld a,(hl)		; ...and the high one with the carry
	adc a,d
	ld (hl),a
	ret

	end

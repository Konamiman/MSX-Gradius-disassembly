; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - cheat_effects.asm
; ============================================================================

	public cheat_double,cheat_down,cheat_everything,cheat_laser,cheat_missile,cheat_option
	public cheat_shield,upload_ship_cards
	extrn note_upgrades_held,set_up_one_option

; ----------------------------------------------------------------------
; WHAT EACH CHEAT GIVES
; This is where the cheats typed on the keyboard land, dispatched by 0x50C9
; in bank 0. Each one sets one field of the ship and returns:
; 0xA0D8  HYPER and the stage's woman's name: all FIVE at once
; 0xA0E9  SHIELD    0xA101  LASER     0xA106  MISSILE
; 0xA10B  DOUBLE    0xA110  OPTION    0xA0FA  DOWN, which takes away
; ----------------------------------------------------------------------
cheat_everything:		; HYPER and the stage's name: shield, speed, laser, missile and option, all five in a row
	call set_shield		; All five at once: shield...
	call raise_speed	; ...speed, laser, missile...
	call set_laser
	call set_missile
	call add_option		; ...and one option
	jr refresh_meter
cheat_shield:		; Only the shield
	call set_shield
	jr refresh_meter

; ----------------------------------------------------------------------
; DATA dead_code_A0EE: Twelve bytes that disassemble as code (`ld hl,0xE202 /
;   ld a,(hl) / cp 7 / ret nc / call 0xA11E / jr`), but that no path reaches:
;   the instruction before them is a `jr` and no table points here.
dead_code_A0EE:		; Code that nothing reaches.
	defb 21h,02h,0E2h,7Eh,0FEh,07h,0D0h,0CDh,1Eh,0A1h,18h,59h
cheat_down:		; 0xE202 to zero: takes away from the ship what 0xA123 raises
	ld hl,0e202h
	ld (hl),000h
	jr refresh_meter
cheat_laser:		; Only the laser
	call set_laser
	jr refresh_meter
cheat_missile:		; Only the missile
	call set_missile
	jr refresh_meter
cheat_double:		; Only the double shot
	call set_double_shot
	jr refresh_meter
cheat_option:		; Only the options, up to the two that fit
	call add_option
	jr refresh_meter
set_shield:		; 0xE200 to 3 and 0xE201 to 0x0A: the shield is on
	ld hl,0e200h
	ld (hl),003h
	inc l
	ld (hl),00ah
	ret

; ----------------------------------------------------------------------
; DATA dead_code_A11E: Five bytes that are `ld hl,0xE202 / inc (hl) / ret`.
;   The only caller is the dead piece at 0xA0EE, so they never run either.
dead_code_A11E:
	defb 21h,02h,0E2h,34h,0C9h
raise_speed:		; 0xE202 to one
	ld hl,0e202h
	ld (hl),001h
	ret
set_laser:		; 0xE20C and 0xE20D to zero and 0xE20E to two: the shot becomes the laser
	ld hl,0e20ch		; 0xE20C and 0xE20D to zero...
	xor a
	ld (hl),a
	inc l
	ld (hl),a
	inc l
	ld (hl),002h		; ...and 0xE20E to two: the laser
	ret
set_missile:		; 0xE20F to two
	ld hl,0e20fh
	ld (hl),002h
	ret
set_double_shot:		; 0xE20C and 0xE20D to one, and 0xE20E to zero
	ld hl,0e20ch		; 0xE20C and 0xE20D to one...
	ld a,001h
	ld (hl),a
	inc l
	ld (hl),a
	dec a
	inc l
	ld (hl),a		; ...and 0xE20E to zero: the double
	ret
add_option:		; Raises 0xE20B up to two and, for each one, calls 0x9BFB
	ld hl,0e20bh
	ld a,(hl)
	cp 002h			; Two options at most
	ret nc
	inc (hl)
	call set_up_one_option
	jr add_option
refresh_meter:		; Notes again what the ship carries and repaints the meter
	call note_upgrades_held
	jp 0569dh
upload_four_empty_cards:		; Four switched-off cards: the ship is not there
	ld b,004h
L_A15B:
	call card_off
	djnz L_A15B
	jr L_A1C3
upload_explosion_card:		; With the ship dead, the cards come from somewhere else
	inc l			; With the ship blown up, the card comes from four bytes further on
	inc l
	inc l
	inc l
	ldi			; The row and the column of the explosion...
	inc l
	ldi
	ldi
	ldi
	ld hl,0e204h		; ...and the rest of the card, from the ship
	ldi
	inc l
	ldi
	inc l
	inc l
	ldi			; The drawings and the colours
	ldi
	jr L_A1B7
upload_ship_cards:		; Copies to the sprite buffer the cards of the ship, its two options and its shots
	ld de,0ec80h		; 0xEC80: the sprite attribute buffer
	ld hl,0e200h
	ld a,(hl)		; With 0xE200 at zero there is no ship, and with bit 7 it is blown up
	or a
	jr z,upload_four_empty_cards
	jp m,upload_explosion_card
	ld hl,0e204h
	ldi
	inc l
	ldi
	ldi
	ldi
	ld hl,0e204h
	ld a,(0e200h)
	dec a			; With the ship in state 1, the card goes as it is
	jr z,L_A1AC
	ldi
	inc l
	ld a,(hl)
	add a,008h		; And otherwise, eight points lower
	ld (de),a
	inc e
	inc l
	jr L_A1B1
L_A1AC:
	ldi
	inc l
	ldi
L_A1B1:
	inc l
	inc l
	ldi
	ldi
L_A1B7:
	ld hl,0e220h		; The two options, 0xE220 and 0xE240
	call upload_option_card
	ld hl,0e240h
	call upload_option_card
L_A1C3:
	ld hl,0e270h		; And the shot tables: 0xE270, 0xE290, 0xE2B0...
	call upload_shot_card
	ld hl,0e290h
	call upload_shot_card
	ld hl,0e2b0h
	call upload_shot_card
	ld hl,0e2c0h
	ld b,003h		; Three missiles
upload_three_missiles:		; The three missiles at 0xE2C0; an empty slot is switched off
	ld a,(hl)		; Three missiles, eight bytes apart
	or a
	jr z,missile_off
	inc l
	inc l
	inc l			; No missile, card switched off
	ldi
	inc l
	ldi
	ldi
	ldi
	ld a,008h		; Eight bytes: the next one
	call 0405dh
	djnz upload_three_missiles
	ret
missile_off:		; Empty card and on to the next one
	call card_off
	ld a,010h		; Sixteen bytes: the next one
	call 0405dh
	djnz upload_three_missiles
	ret
upload_option_card:		; If the option is there, its position, pattern and colour to the buffer
	ld a,(hl)		; With the option on, its row, its column, its drawing and its colour
	or a
	jr z,card_off
	ld a,004h
	add a,l
	ld l,a
	ldi
	inc l			; Four bytes of card
	ldi
	ld a,005h
	add a,l
	ld l,a
	ldi
	ldi
	ret
upload_shot_card:		; Only those of type 2 (the double) upload a sprite card
	ld a,(hl)		; Those of type 2 (the double) are the only ones that upload a card
	cp 002h
	jr nz,card_off
	inc l
	inc l
	inc l
	ldi			; Its row and its column
	inc l
	ldi
	ldi
	ldi
	ret
card_off:		; 0xE0 in Y: the VDP does not draw it
	ld a,0e0h		; 0xE0 in the row: the VDP does not draw the sprite
	ld (de),a
	inc de
	inc de			; And the other three bytes, to zero
	inc de
	inc de
	ret

	end

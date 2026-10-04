; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - joystick_directions.asm
; ============================================================================

	public controller_speed

; ----------------------------------------------------------------------
; THE SIXTEEN JOYSTICK DIRECTIONS, IN A TABLE
; The four direction bits of the joystick are not read one by one: the
; sixteen possible values index the table at 0x9B0D, four bytes each, and
; out of it come the two speeds of the ship, ready-made. That way the
; diagonals do not cost a single instruction more than the straight lines.
; ----------------------------------------------------------------------
controller_speed:		; The four direction bits index the table at 0x9B0D: the ship's two speeds come from there
	ld a,(0e009h)		; The four direction bits
	and 00fh
	add a,a			; Times four: four bytes per direction
	add a,a
	ld hl,09b0dh
	add a,l
	ld l,a
	jr nc,L_9B05
	inc h
L_9B05:
	ld e,(hl)		; The vertical speed...
	inc hl
	ld d,(hl)
	inc hl
	ld c,(hl)		; ...and the horizontal one
	inc hl
	ld b,(hl)
	ret

; ----------------------------------------------------------------------
; DATA controller_speeds: Sixteen four-byte cards, one for each combination of
;   the four direction bits of the joystick: the two 16-bit speeds the ship
;   moves with. Read by 0x9AFD.
controller_speeds:
	defb 00h,00h,00h,00h
	defb 80h,0FFh,00h,00h
	defb 80h,00h,00h,00h
	defb 00h,00h,00h,00h
	defb 00h,00h,80h,0FFh
	defb 80h,0FFh,80h,0FFh
	defb 80h,00h,80h,0FFh
	defb 00h,00h,80h,0FFh
	defb 00h,00h,80h,00h
	defb 80h,0FFh,80h,00h
	defb 80h,00h,80h,00h
	defb 00h,00h,80h,00h
	defb 00h,00h,00h,00h
	defb 80h,0FFh,00h,00h
	defb 80h,00h,00h,00h
	defb 00h,00h,00h,00h

	end

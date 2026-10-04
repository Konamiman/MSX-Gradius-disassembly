; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - ship_speed.asm
; ============================================================================

	include "variables.inc"

	public kill_ship,next_ship_state,times_speed_steps

; ----------------------------------------------------------------------
; THE SHIP'S SPEED IS A REPEATED SUM
; The speed upgrade does not multiply: it takes the speed of one unit and
; ADDS it to itself as many times as the steps it has (0xE202, capped at
; seven) plus three. Eight speed steps, and not a single multiplication.
; ----------------------------------------------------------------------
times_speed_steps:		; Adds the two speeds to themselves 3 + (0xE202) times: that is the speed upgrade
	ld a,(SHIP_SPEED)	; The speed steps
	cp 008h			; Seven at most
	jp c,L_9B57
	ld a,007h
L_9B57:
	add a,003h		; Plus three: the starting speed
	ld h,a
	ex af,af'
	ld a,h
	ld l,c
	ld h,b
L_9B5E:
	add hl,bc		; The horizontal speed, added to itself
	dec a			; The steps plus three
	jp nz,L_9B5E
	ld c,l
	ld b,h
	ld l,e
	ld h,d
	ex af,af'
L_9B68:
	add hl,de		; And the Y one
	dec a			; And the vertical one
	jp nz,L_9B68		; The vertical one, already multiplied
	ld e,l
	ld d,h
	ret
end_game:		; Copies 0xE130 to 0xE06B and clears the flag at 0xE05F
	ld a,(METER_SLOT)
	ld (METER_AT_DEATH),a
	xor a
	ld (IN_PLAY),a
	ret
kill_ship:		; Leaves 0xFF in the ship and in its two options and sets the speed steps to zero
	ld hl,SHIP
	ld a,(hl)
	or a
	ret m
	ld de,00020h		; Thirty-two bytes: the next card
	ld b,003h		; The ship and its two options
L_9B86:
	ld (hl),0ffh
	add hl,de
	djnz L_9B86
	xor a
	ld (SHIP_SPEED),a	; To zero: the speed is lost
	jr set_up_ship_card
next_ship_state:		; Decrements the counter and, when it runs out, increments the state; past 4 the game is over
	ld hl,SHIP_TIMER
	dec (hl)		; 0xE201: the frames left in this state
	ret nz
	inc l
	inc (hl)
	ld a,(hl)
	cp 004h			; Four states
	jr nc,end_game
set_up_ship_card:		; Takes from the table at 0x9BD2 the frames the state lasts and the sprite card of the ship and of its two options
	ld hl,09bd2h		; The table at 0x9BD2, indexed by the state
	call 047aeh
	ex de,hl
	ld a,(hl)
	ld (SHIP_TIMER),a	; The frames it lasts
	inc hl
	ld de,SHIP+7
	ldi			; The four bytes of the card
	ldi
	ldi
	ldi
	ld de,OPTIONS+4		; And the two options, this one and 0xE244
	call set_up_the_option
	ld de,OPTIONS+OPTION_SIZE+4
set_up_the_option:		; The option goes on the ship's row and at its column plus the offset from the table
	ld a,(SHIP_ROW)		; The ship's row
	ld (de),a
	inc e
	inc e
	ld a,(SHIP_COLUMN)	; And its column plus the offset
	add a,(hl)
	ld (de),a
	ld a,006h		; Six bytes further on, the pattern and the colour
	add a,e
	ld e,a
	inc hl
	ldi
	ldi
	ret

; ----------------------------------------------------------------------
; DATA table_9BD2: Forty-one bytes read by 0x9B9D.
table_9BD2:
	defb 0F0h,9Bh,0DAh,9Bh,0E5h,9Bh,0F0h,9Bh,14h,5Ch,09h,60h,0Fh,0F8h,58h,06h
	defb 08h,74h,06h,0Ah,50h,09h,54h,0Fh,0F8h,4Ch,06h,08h,70h,06h,0Ah,64h
	defb 06h,68h,09h,00h,6Ch,0Fh,00h,6Ch,0Fh

	end

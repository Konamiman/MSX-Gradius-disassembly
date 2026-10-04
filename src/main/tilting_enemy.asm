; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - tilting_enemy.asm
; ============================================================================

	public finish_type_2,move_type_4

; ----------------------------------------------------------------------
; THE ENEMY TILTS TOWARDS WHERE IT FLIES
; Type 4 has three drawings (0xB0 level, 0xB4 tilted up and 0xB8 tilted
; down) and the right one is picked here at the same time as the speed: if
; the ship is above it, it takes 0xB4 and climbs; if the ship is below it,
; 0xB8 and it descends; and once it is on the ship's row, 0xB0 and it just
; moves forward. Drawing and heading come from the same place, so they
; never contradict each other.
; ----------------------------------------------------------------------
move_type_4:		; Gets level with the ship and tilts towards where it is going
	call 09235h
	ld a,(0e204h)		; The ship's row minus its own
	sub (ix+004h)
	push af
	add a,003h
	cp 007h			; Within seven it is already on its row
	jr c,L_A88A
	pop af
	jr c,L_A880
	ld a,0b8h		; Ship below: drawing 0xB8 and one and a half points downwards
	ld de,0fe80h
	ld bc,00180h
	jr L_A89E
L_A880:
	ld a,0b4h		; Above: drawing 0xB4 and one and a half points upwards
	ld de,0fe80h
	ld bc,0fe80h
	jr L_A89E
L_A88A:
	pop af
	ld a,(0e206h)		; Already on its row: the column is checked
	sub (ix+006h)
	ld de,0fd00h		; With the ship ahead, three points to the left
	jr c,L_A899
	ld de,0fe80h		; And otherwise, one and a half
L_A899:
	ld bc,00000h		; No vertical speed: drawing 0xB0
	ld a,0b0h
L_A89E:
	ld (ix+00ch),a		; The chosen drawing, to byte 12
	call 06cc6h
	ld d,b
	ld e,c
	jp 06cbfh
finish_type_2:		; Still, and four points to the left
	call 09510h
	ld de,0fc00h
	jp 06cc6h

	end

; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - map_collisions.asm
; ============================================================================

	public collides_at_this_cell,collides_with_map,collides_with_map_2,collides_with_map_3,is_special_cell,object_collides_with_map
	public ship_collides

; ----------------------------------------------------------------------
; COLLIDING WITH THE MAP MEANS LOOKING AT WHICH CHARACTER IS UNDERNEATH
; There is no list of walls: to know whether something collides with the
; terrain, the code looks at the CHARACTER the map has in that cell. Below
; 0x77 it is background and does not collide; from there up, each stage
; decides which range of characters it collides with (0x9912, 0x991D,
; 0x9923 and 0x9929).
; ----------------------------------------------------------------------
collides_with_map:		; Looks at the character in the cell and the one next to it; returns carry if either of them is wall
	call 0571bh		; The map cell comes from the position
	ex de,hl
	call L_9864
	ret c
	inc de			; And the cell next to it, if that does not go off the row
	ld a,e
	and 01fh
	ret z
L_9864:
	ld a,(de)
	and a
	ret z
	cp 077h			; Below 0x77 it is background
	ret c
	ld c,a
	ld a,(0e061h)		; On stage 1 only two characters collide
	dec a
	jp z,stage_1_wall
	sub 002h		; And on stage 3, a whole range
	jp z,stage_3_wall
	xor a
	ret
collides_with_map_2:		; The same, but only stage 4 has walls
	call 0571bh		; The cell comes from the position
	ex de,hl
	call L_9886
	ret c
	inc de
	ld a,e
	and 01fh
	ret z
L_9886:
	ld a,(de)		; The character in the cell
	and a
	ret z
	cp 077h			; Below 0x77 it is background
	ret c
	ld c,a
	ld a,(0e061h)
	sub 003h
	jp z,stage_3_wall
	xor a
	ret
collides_with_map_3:		; The same, but no stage has walls: it only checks that it is not background
	call 0571bh		; The cell comes from the position
	ex de,hl
	call L_98A4
	ret c
	inc de
	ld a,e
	and 01fh
	ret z
L_98A4:
	ld a,(de)		; The character in the cell
	and a
	ret z
	cp 077h			; Below 0x77 it is background
	ret c
	xor a
	ret
object_collides_with_map:		; The same, taking the position of the object IX points to
	ld l,(ix+004h)		; The object's position
	ld h,(ix+006h)
	call 0571bh		; The map cell comes from there
	ex de,hl		; The character in the cell
	ld a,(de)		; The character in the cell
	and a
	ret z
	cp 077h
	ret c
	ld c,a
	ld a,(0e061h)
	dec a
	jr z,stage_1_wall
	sub 002h
	jr z,stage_3_wall
	xor a
	ret
collides_at_this_cell:		; The cell already comes in DE
	ld a,(de)		; The character in the cell
	and a
	ret z
	cp 077h			; Below 0x77 it is background
	ret c
	ld c,a
	ld a,(0e061h)
	sub 003h
	jp z,stage_3_wall
	xor a
	ret
ship_collides:		; Looks at the two cells the ship passes through: the one of its point and the one next to it
	ld ix,0e200h		; 0xE200: the ship's card
	ld a,(ix+004h)		; Eight to the right of its X
	add a,008h
	ld l,a
	ld a,(ix+006h)
	ld h,a
	and 007h		; The low three bits of Y: whether it straddles two rows
	cp 004h			; The low three bits of Y
	push af			; Straddling two rows
	call 0571bh
	ex de,hl
	pop af
	jr nc,L_98F8
	call L_98FF
	ret c
L_98F8:
	inc de
	call L_98FF
	ret c
	xor a
	ret
L_98FF:
	ld a,(de)		; The map cell
	and a
	ret z
	cp 077h
	ret c
	ld c,a			; The character is kept in C
	ld a,(0e061h)
	sub 003h
	jr z,stage_4_wall
	dec a
	jr z,stage_5_wall
	xor a
	ret
stage_1_wall:		; Only characters 0xA2 and 0xA5
	ld a,c			; Character 0xA2...
	cp 0a2h
	scf
	ret z
	cp 0a5h			; ...and 0xA5
	scf			; Character 0xA5
	ret z			; No others
	xor a
	ret
stage_4_wall:		; From 0xA1 to 0xBB
	ld a,c
	sub 0a1h
	cp 01bh
	ret
stage_3_wall:		; From 0xA1 to 0xA5
	ld a,c
	sub 0a1h
	cp 005h
	ret
stage_5_wall:		; From 0xBA to 0xC5
	ld a,c
	sub 0bah
	cp 00ch
	ret
is_special_cell:		; On stages 2, 7 and from 9 onwards there are characters that are not walls but count: returns which one in C
	ld a,(0e061h)		; 0xE061: the stage
	cp 002h			; Stage 2 has one group
	jr z,L_9940
	cp 007h
	jr z,L_994D
	cp 009h
	jr nc,L_9940
	xor a
	ret
L_9940:
	ld a,(0e151h)		; Not with the boss on screen
	and a
	ret nz
	ld c,005h		; Group 5: characters 0x44 and 0x45
	ld a,(de)
	sub 044h
	cp 001h
	ret
L_994D:
	ld c,004h		; And group 4: from 0x61 to 0x63
	ld a,(de)
	sub 061h
	cp 002h
	ret

	end

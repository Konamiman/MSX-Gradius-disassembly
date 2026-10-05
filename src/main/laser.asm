; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - laser.asm
; ============================================================================

	include "variables.inc"

	public restore_underneath,save_under_laser,write_laser
	extrn add_a_to_hl,cell_to_ram_address

; ----------------------------------------------------------------------
; THE LASER IS PAINTED IN THE NAME TABLE, NOT WITH SPRITES
; The normal shot is a sprite, but the laser is not: it is a STRIP OF
; CHARACTERS written into the map. save_under_laser saves what lies underneath (its
; cell and its length) and then writes the strip; write_laser erases it by
; putting the characters back. That is why the laser can cover the terrain
; as it goes by.
; ----------------------------------------------------------------------
save_under_laser:		; Walks the six slots and, for the laser, notes where it starts and how many cells it covers
	ld hl,SHOTS
	exx
	ld b,006h		; Six slots
L_A233:
	exx
	push hl
	ld a,(hl)
	dec a			; Type 1: the normal shot
	jr z,save_shot_cell
	sub 002h		; And 3: the laser
	jr z,save_laser_strip
L_A23D:
	pop hl
	ld a,010h		; Sixteen bytes: the next one
	call add_a_to_hl
	exx
	djnz L_A233
	ret
save_shot_cell:		; The cell it lands on, and the character that was there
	call shot_cell		; The cell where the shot lands...
	inc l
	inc l
	inc l
	ld a,(de)		; ...and the character that was there
	ld (hl),a
	jr L_A23D
save_laser_strip:		; Notes the cell in bytes 14 and 15 and copies the strip of characters it is about to cover
	push hl
	pop ix
	ld a,(ix+00ch)		; Byte 12: how many cells long it is
	or a
	jr z,L_A270
	call shot_cell
	ld (ix+00eh),e
	ld (ix+00fh),d
	ld a,00ch
	add a,l
	ld l,a
	ld c,(ix+00ch)
	ld b,000h
	ex de,hl
	ldir			; What was underneath is copied
	ex de,hl
L_A270:
	jr L_A23D
shot_cell:		; From the shot's position comes its cell in the map
	inc l			; From the row and the column comes the map cell
	inc l
	inc l
	ld e,(hl)
	inc l
	inc l
	ld d,(hl)
	ex de,hl		; cell_to_ram_address: the cell that belongs to it
	call cell_to_ram_address
	ex de,hl
	ret
write_laser:		; Writes the shot's character into the map, and for the laser its whole strip
	ld hl,SHOTS
	exx
	ld b,006h		; Six slots
L_A285:
	exx			; Byte 1 says what each slot holds
	push hl
	ld a,(hl)
	dec a
	jr z,write_shot
	sub 002h
	jr z,write_laser_strip
L_A28F:
	pop hl
	ld a,010h		; Sixteen bytes: the next one
	call add_a_to_hl
	exx
	djnz L_A285
	ret
write_shot:		; A single character in its cell
	inc l			; The shot's row and column
	inc l
	inc l
	ld e,(hl)
	inc l
	inc l
	ld d,(hl)
	ex de,hl
	call cell_to_ram_address	; From that comes its cell in the map
	ex de,hl
	inc l
	ld a,(hl)		; And there its character is written
	ld (de),a
	jr L_A28F
write_laser_strip:		; Repeats the laser character over as many cells as it is long
	push hl
	pop ix
	ld a,(ix+00ch)		; Byte 12: how many cells
	or a
	jr z,L_A2C5
	ld a,006h		; Six bytes further on: the character
	add a,l
	ld l,a
	ld a,(hl)
	ld b,(ix+00ch)
	ld e,(ix+00eh)		; Bytes 14 and 15: where the strip starts
	ld d,(ix+00fh)
L_A2C1:
	ld (de),a		; The same character, that many times
	inc de
	djnz L_A2C1
L_A2C5:
	jr L_A28F
restore_underneath:		; Erases the shot from the map by putting back the character it had saved, and for the laser its whole strip
	ld hl,SHOTS
	exx
	ld b,006h		; Six slots
L_A2CD:
	exx
	push hl
	ld a,(hl)
	dec a			; Type 1: the normal shot
	jr z,restore_shot_cell
	sub 002h		; And 3: the laser
	jr z,restore_laser_strip
L_A2D7:
	pop hl
	ld a,010h		; Sixteen bytes: the next one
	call add_a_to_hl
	exx
	djnz L_A2CD
	ret
restore_shot_cell:		; The saved character goes back to its cell
	inc l			; The cell that had been noted...
	inc l
	inc l
	ld e,(hl)
	inc l
	inc l
	ld d,(hl)
	ex de,hl
	call cell_to_ram_address	; ...and the character that was underneath
	ex de,hl
	inc l
	inc l
	inc l
	ld a,(hl)		; Back in its place
	ld (de),a
	jr L_A2D7
restore_laser_strip:		; Copies back the whole strip the laser was covering
	push hl
	pop ix
	ld a,(ix+00ch)		; Byte 12: how many cells
	or a
	jr z,L_A30E
	ld e,(ix+00eh)		; Bytes 14 and 15: where it started
	ld d,(ix+00fh)
	ld a,011h
	add a,l
	ld l,a
	ld c,(ix+00ch)
	ld b,000h
	ldir
L_A30E:
	jr L_A2D7

	end

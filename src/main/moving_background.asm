; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - moving_background.asm
; ============================================================================

	include "variables.inc"

	public animate_three_characters
	extrn add_a_to_de,animate_seven_cells,fill_three_thirds

; ----------------------------------------------------------------------
; THE BACKGROUND THAT MOVES WITHOUT SPENDING A SINGLE SPRITE
; No object moves here: what changes is the DRAWING of three characters
; (0xF6, 0xF7 and 0xF8), by rewriting their eight bytes in VRAM. The table
; at moving_character_drawings holds six drawings for each of them, and each one goes its own
; way: how long its drawing lasts is drawn by lot by the R register,
; between 8 and 0x17 frames. Since the background is made with those three
; characters, all the cells that use them move at once at no cost.
; ----------------------------------------------------------------------
animate_three_characters:		; Rewrites in VRAM the eight bytes of characters 0xF6, 0xF7 and 0xF8
	call animate_seven_cells
	ld hl,CHAR_ANIM+1	; Character 0xF6, with its count
	ld de,moving_character_drawings
	ld c,0f6h
	call animate_character
	ld hl,CHAR_ANIM+3	; 0xF7, with its own
	ld de,moving_character_drawings+6
	ld c,0f7h
	call animate_character
	ld hl,CHAR_ANIM+5	; And 0xF8
	ld de,moving_character_drawings+0Ch
	ld c,0f8h
animate_character:		; When the count runs out, moves on to the next of the six drawings and uploads it to VRAM
	dec (hl)		; The frames this drawing has left
	ret nz
	ld a,r			; The R register: between 8 and 0x17 frames
	and 00fh
	add a,008h
	ld (hl),a
	dec hl
	ld a,(hl)		; The next drawing...
	inc a
	cp 006h			; ...of the six, round and round
	jr c,L_BE04
	xor a
L_BE04:
	ld (hl),a
	call add_a_to_de
	ld a,(de)
	ld l,c			; The character number times eight: where it lives in VRAM
	ld h,000h
	add hl,hl
	add hl,hl
	add hl,hl
	ld de,00000h
	add hl,de
	ld bc,00008h		; Eight bytes: one row of characters
	jp fill_three_thirds

; ----------------------------------------------------------------------
; DATA moving_character_drawings: Eighteen bytes read by 0xBDD8 (0xBE19), 0xBDE3 (0xBE1F) and
;   0xBDEE (0xBE25), in groups of six.
moving_character_drawings:
	defb 70h,50h,40h,00h,40h,50h
	defb 0F0h,0B0h,0A0h,00h,0A0h,0B0h
	defb 90h,80h,60h,00h,60h,80h

	end

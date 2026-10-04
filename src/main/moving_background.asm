; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - moving_background.asm
; ============================================================================

	public animate_three_characters
	extrn animate_seven_cells

; ----------------------------------------------------------------------
; THE BACKGROUND THAT MOVES WITHOUT SPENDING A SINGLE SPRITE
; No object moves here: what changes is the DRAWING of three characters
; (0xF6, 0xF7 and 0xF8), by rewriting their eight bytes in VRAM. The table
; at 0xBE19 holds six drawings for each of them, and each one goes its own
; way: how long its drawing lasts is drawn by lot by the R register,
; between 8 and 0x17 frames. Since the background is made with those three
; characters, all the cells that use them move at once at no cost.
; ----------------------------------------------------------------------
animate_three_characters:		; Rewrites in VRAM the eight bytes of characters 0xF6, 0xF7 and 0xF8
	call animate_seven_cells
	ld hl,0e700h		; Character 0xF6, with its count at 0xE700
	ld de,0be19h
	ld c,0f6h
	call animate_character
	ld hl,0e702h		; 0xF7, with its own at 0xE702
	ld de,0be1fh
	ld c,0f7h
	call animate_character
	ld hl,0e704h		; And 0xF8, at 0xE704
	ld de,0be25h
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
	call 04062h
	ld a,(de)
	ld l,c			; The character number times eight: where it lives in VRAM
	ld h,000h
	add hl,hl
	add hl,hl
	add hl,hl
	ld de,00000h
	add hl,de
	ld bc,00008h		; Eight bytes: one row of characters
	jp 04977h

; ----------------------------------------------------------------------
; DATA table_BE19: Eighteen bytes read by 0xBDD8 (0xBE19), 0xBDE3 (0xBE1F) and
;   0xBDEE (0xBE25), in groups of six.
table_BE19:
	defb 70h,50h,40h,00h,40h,50h
	defb 0F0h,0B0h,0A0h,00h,0A0h,0B0h
	defb 90h,80h,60h,00h,60h,80h

	end

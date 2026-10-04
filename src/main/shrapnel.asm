; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - shrapnel.asm
; ============================================================================

	include "bios.inc"
	include "variables.inc"

	public animate_shrapnel,move_shrapnel,pick_border_colour,release_shrapnel,start_slow_message,upload_shrapnel_to_buffer
	public write_one_letter
	extrn add_a_to_de,add_a_to_hl,set_border_colour

; ----------------------------------------------------------------------
; THE EXPLOSION SHRAPNEL, AND THE R REGISTER AGAIN
; When the ship blows up, a piece of shrapnel comes out every three frames,
; and all the chance in it comes from the Z80's R REGISTER, the memory
; refresh one, read four times in a row: one of its bits picks between the
; two drawings, another four pick one of the sixteen directions in the
; table at 0x4D3E, and the last two reads add a pinch to the X and to the
; Y so that two pieces with the same direction do not travel stuck
; together.
; In this mode, 0xE300 is NOT the usual object table: it is thirty-two
; slots of sixteen bytes.
; ----------------------------------------------------------------------
release_shrapnel:		; Every three frames releases a piece of shrapnel in the first free slot, with drawing, direction and push taken from the R register
	ld hl,SHRAPNEL_DELAY	; One piece every three frames
	dec (hl)
	ret nz
	ld (hl),003h
	ld hl,(SHRAPNEL_LEFT)	; What is left of the explosion
	ld a,l
	or h
	ret z
	dec hl
	ld (SHRAPNEL_LEFT),hl
	ld a,r			; The R register: one bit to pick between the two drawings
	rra
	ld c,001h
	jr nc,L_4CE2
	inc c
L_4CE2:
	ld hl,SHRAPNEL		; The thirty-two shrapnel slots
	ld b,020h
	xor a
	ld de,00010h		; Sixteen bytes per slot
L_4CEB:
	cp (hl)			; The first one that is at zero
	jr z,build_shrapnel_piece
	add hl,de
	djnz L_4CEB
	ret
build_shrapnel_piece:		; Fills the slot: drawing, Y 0x38, X 0x80, and the direction it gets from the R register
	ld (hl),c
	inc l
	ld (hl),000h
	inc l
	inc l
	ld (hl),038h		; The starting Y, 0x38
	inc l
	inc l
	ld (hl),080h		; And the X, 0x80: the centre
	inc l
	ld a,r			; The R register again: four bits, one of the sixteen directions
	and 00fh
	add a,a			; Times four: two words per direction
	add a,a
	push hl
	ld hl,04d3eh
	call add_a_to_hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,(hl)
	inc hl
	ld b,(hl)
	pop hl
	dec c			; With the other drawing, the speed is halved
	ld c,a
	jr z,L_4D20
	sra d			; Shifting with the sign: it works for the negative directions
	rr e
	sra b
	rr c
L_4D20:
	ld a,r			; And the R register once more, to scatter the X...
	call add_a_to_de
	ld (hl),e
	inc l
	ld (hl),d
	ld a,r			; ...and once more for the Y
	ld e,c
	ld d,b
	call add_a_to_de
	inc l
	ld (hl),e
	inc l
	ld (hl),d
	inc l
	ld (hl),02ch		; 0x2C and 0x07: the pattern and the colour
	inc l
	ld (hl),007h
	ld hl,SHRAPNEL_LIVE	; Keeps count of the live pieces
	inc (hl)
	ret

; ----------------------------------------------------------------------
; DATA shrapnel_directions: Sixteen directions, two words each: the X step and
;   the Y step, in 8.8 fixed point (0x0200 is two points per frame). They are
;   indexed by 0x4D06 with four bits of the R register times four. They are
;   the sixteen directions of the compass rose, with their signs.
shrapnel_directions:
	defw 0000h,0200h
	defw 00C4h,01D9h
	defw 016Ah,016Ah
	defw 01D9h,00C4h
	defw 0200h,0000h
	defw 01D9h,0FF3Ch
	defw 016Ah,0FE96h
	defw 00C4h,0FE27h
	defw 0000h,0FE00h
	defw 0FF3Ch,0FE27h
	defw 0FE96h,0FE96h
	defw 0FE27h,0FF3Ch
	defw 0FE00h,0000h
	defw 0FE27h,00C4h
	defw 0FE96h,016Ah
	defw 0FF3Ch,01D9h
move_shrapnel:		; Walks the thirty-two sixteen-byte slots and adds its speed to each piece; any that goes off the screen is turned off
	ld ix,SHRAPNEL
	ld b,020h
L_4D84:
	ld a,(ix+000h)		; The slot at zero is free
	and a
	jr z,L_4DBE
	ld a,(ix+002h)		; The 16-bit X plus its speed
	add a,(ix+006h)
	ld (ix+002h),a
	ld a,(ix+003h)
	adc a,(ix+007h)
	cp 0c0h			; Past X 0xC0, the piece is gone
	jr nc,L_4DB6
	ld (ix+003h),a
	ld a,(ix+004h)		; And the same with the Y
	add a,(ix+008h)
	ld (ix+004h),a
	ld a,(ix+005h)
	adc a,(ix+009h)
	ld (ix+005h),a
	cp 0f8h			; And the bottom limit, 0xF8
	jr c,L_4DBE
L_4DB6:
	ld (ix+000h),000h	; The slot is freed...
	ld hl,SHRAPNEL_LIVE	; ...and the count of live pieces goes down
	dec (hl)
L_4DBE:
	ld de,00010h		; Sixteen bytes: the next slot
	add ix,de
	djnz L_4D84
	ret
upload_shrapnel_to_buffer:		; The thirty-two slots to the attribute buffer: the Y, the X, the pattern and the colour; a free slot goes to 0xE0
	ld ix,SHRAPNEL
	ld hl,SPRITE_BUFFER
	ld b,020h
L_4DCF:
	ld c,(ix+003h)		; Byte 3 is the Y
	ld a,(ix+000h)
	and a
	jr nz,L_4DDA
	ld c,0e0h		; With the slot free, 0xE0: off the screen
L_4DDA:
	ld (hl),c
	inc hl
	ld a,(ix+005h)		; Byte 5 is the X
	ld (hl),a
	inc hl
	ld a,(ix+00ah)		; And bytes 10 and 11, the pattern and the colour
	ld (hl),a
	inc hl
	ld a,(ix+00bh)
	ld (hl),a
	inc hl
	ld de,00010h		; Sixteen bytes: the next slot
	add ix,de
	djnz L_4DCF
	ret
animate_shrapnel:		; Raises each piece's counter and changes its pattern depending on how many frames it has been in the air
	ld b,020h
	ld ix,SHRAPNEL
L_4DF9:
	ld a,(ix+000h)
	and a
	jr z,L_4E0B
	inc (ix+001h)		; One more frame for that piece
	dec a			; The first drawing has four phases; the other, two
	push af
	call z,four_phases
	pop af
	call nz,two_phases
L_4E0B:
	ld de,00010h
	add ix,de
	djnz L_4DF9
	ret
four_phases:		; Changes pattern at 0x0C, 0x18 and 0x24 frames: 0x2C, 0x30, 0x34 and 0x38
	ld a,(ix+001h)		; The frames the piece has been in the air
	ld c,02ch		; Below 0x0C, the first pattern
	cp 00ch
	jr c,L_4E2A
	ld c,030h
	cp 018h			; And then 0x30, 0x34 and 0x38
	jr c,L_4E2A
	ld c,034h
	cp 024h
	jr c,L_4E2A
	ld c,038h
L_4E2A:
	ld (ix+00ah),c
	ret
two_phases:		; The other drawing only changes once, at 0x60 frames
	ld a,(ix+001h)		; The frames the piece has been in the air
	ld c,02ch
	cp 060h
	jr c,L_4E2A
	ld c,030h
	jr L_4E2A

; ----------------------------------------------------------------------
; DATA unreachable_code: Eighty-three bytes that disassemble as code (they
;   start with `ld a,(0xE1D2) / dec a / ld hl,0x4E82`) but that no path
;   reaches: the instruction before ends in `ret` and no instruction or table
;   in the cartridge points to 0x4E3B. They are listed as bytes so as not to
;   claim they are live code.
unreachable_code:
	defb 3Ah,0D2h,0E1h,3Dh,21h,82h,4Eh,28h,11h,21h,76h,4Eh,0FEh,09h,38h,0Ah
	defb 21h,6Ah,4Eh,0FEh,13h,38h,03h,21h,5Eh,4Eh,11h,80h,0ECh,01h,0Ch,00h
	defb 0EDh,0B0h,0C9h,40h,60h,00h,04h,40h,70h,04h,05h,40h,80h,24h,06h,40h
	defb 60h,0Ch,04h,40h,70h,10h,04h,40h,80h,28h,06h,40h,70h,18h,06h,40h
	defb 70h,1Ch,05h,0E0h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h
pick_border_colour:		; A bit of 0xE1D2 picks between colour 3 and colour 9 for the border
	ld a,(ENDING_TIMER)	; One of its bits
	rra
	rra
	ld b,003h
	jr c,L_4E99
	ld b,009h
L_4E99:
	jp set_border_colour
start_slow_message:		; Stores the VRAM cell in 0xE1DB and the text in 0xE1DD: the message is going to be written letter by letter
	ld e,(hl)		; The first two bytes are the cell
	inc hl
	ld d,(hl)
	inc hl
	ld (SLOW_MSG_VRAM),de	; The cell, and the text in 0xE1DD
	ld (SLOW_MSG_TEXT),hl
	ld a,001h		; 0xE1DA to one: the first letter goes in straight away
	ld (SLOW_MSG_DELAY),a
	ret
write_one_letter:		; Every six frames writes ONE letter of the message; 0xFF ends it and 0xFE continues it at another cell
	ld hl,SLOW_MSG_DELAY	; One letter every six frames
	dec (hl)
	ret nz
	ld (hl),006h
	ld hl,(SLOW_MSG_VRAM)	; How far the cell has got and how far the text has got
	ld de,(SLOW_MSG_TEXT)
	ld a,(de)
	cp 0ffh			; 0xFF: the message is complete
	ret z
	cp 0feh			; And 0xFE: it carries on at another cell
	jr nz,L_4ECB
	inc de
	ex de,hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	inc de
	ld a,(de)
L_4ECB:
	inc de
	ld (SLOW_MSG_TEXT),de
	call WRTVRM		; The letter, to VRAM
	inc hl
	ld (SLOW_MSG_VRAM),hl
	or 0ffh			; Exits with 0xFF: there is still message left
	ret

; ----------------------------------------------------------------------
; DATA meter_table: Six words (0x4EE6, 0x4EEB, 0x4EF4, 0x4F08, 0x4F2B, 0x4F63)
;   that 0x4BFD indexes with 0xE1D9, the lit cell of the power-up meter. They
;   are NOT routines: they are the six drawings of the meter, and 0x4BFD ends
;   in `jp 0x4998`, which is the one that writes characters.
meter_table:
	defw 4EE6h,4EEBh	; -> DATA_meter_drawings 0x4eeb
	defw 4EF4h,4F08h
	defw 4F2Bh,4F63h

; ----------------------------------------------------------------------
; DATA meter_drawings: The six drawings the table above points to, in the
;   0x4998 format: two bytes of VRAM address, followed by the characters (0xFE
;   = another address follows, 0xFF = end). They are counted, not estimated:
;   the six measure 5, 9, 20, 35, 56 and 79 bytes and fit exactly from 0x4EE6
;   to 0x4FB1. They write to the name table around 0x38EA-0x390E, which is the
;   meter's row.
meter_drawings:
	defb 0EFh,38h,0A1h,0A2h,0FFh,0CFh,38h,0A3h,0FEh,0EFh,38h,0A4h,0A5h,0FFh,0CEh,38h
	defb 00h,0A6h,0A7h,00h,0FEh,0EEh,38h,0A8h,0A9h,0AAh,0ABh,0FEh,0Eh,39h,00h,0ACh
	defb 0ADh,0FFh,0CCh,38h,00h,00h,00h,0AEh,0FEh,0ECh,38h,00h,00h,00h,0AFh,0B0h
	defb 00h,00h,0FEh,0Ch,39h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0FEh,2Ch,39h,00h
	defb 00h,00h,0B8h,0B9h,0FFh,0CBh,38h,00h,00h,00h,00h,0BAh,00h,00h,00h,0FEh
	defb 0EBh,38h,00h,00h,00h,00h,0BBh,0BCh,00h,00h,00h,0FEh,0Bh,39h,0BDh,0BEh
	defb 0BFh,0C0h,0C1h,0C2h,0C3h,0BFh,0C4h,0FEh,2Bh,39h,00h,0C5h,0C6h,0C7h,0C8h,0C9h
	defb 0CAh,0CBh,0CCh,0FEh,4Bh,39h,00h,00h,00h,00h,0CDh,0CEh,0FFh,0CAh,38h,00h
	defb 00h,00h,00h,00h,0CFh,00h,00h,00h,0FEh,0EAh,38h,00h,00h,00h,00h,00h
	defb 0D0h,00h,00h,00h,00h,0FEh,0Ah,39h,00h,00h,00h,00h,00h,0D1h,0D2h,00h
	defb 00h,00h,00h,0FEh,2Ah,39h,0D3h,0D4h,00h,0D5h,0D6h,0D7h,0D8h,0D9h,0DAh,00h
	defb 0DBh,0DCh,0FEh,4Ah,39h,00h,0DDh,0DEh,0DFh,0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,0E6h
	defb 0FEh,6Ah,39h,00h,00h,00h,00h,0E7h,0E8h,0E9h,0EAh,0FFh

; ----------------------------------------------------------------------
; DATA four_by_four_drawing: Four rows of four characters (0xEB to 0xF8) at
;   row 5 and column 14, in the 0x4998 format: a drawing made of characters in
;   the middle of the screen. Requested by 0x4B39.
four_by_four_drawing:
	defb 0AEh,38h,00h,0EBh,0ECh,00h,0FEh
	defb 0CEh,38h,0EDh,0EEh,0EFh,0F0h,0FEh
	defb 0EEh,38h,0F1h,0F2h,0F3h,0F4h,0FEh
	defb 0Eh,39h,0F5h,0F6h,0F7h,0F8h,0FFh

; ----------------------------------------------------------------------
; DATA erase_drawing: The same drawing but with zeros, that is, the erasing.
;   Requested by 0x4BC1.
erase_drawing:
	defb 0AEh,38h,00h,00h,00h,00h,0FEh
	defb 0CEh,38h,00h,00h,00h,00h,0FEh
	defb 0EEh,38h,00h,00h,00h,00h,0FEh
	defb 0Eh,39h,00h,00h,00h,00h,0FFh

; ----------------------------------------------------------------------
; DATA tables_of_4C4B: What 0x4C50 (0x4FEA), 0x4C4B (0x502E), 0x4C70 (0x5040)
;   and 0x4C93 (0x504A) read.
tables_of_4C4B:
	defb 0F4h,4Fh,0FBh,4Fh,02h,50h,09h,50h,11h,50h,0Eh,39h,27h,2Fh,2Fh,24h
	defb 0FFh,0Eh,39h,2Eh,29h,23h,25h,0FFh,0Eh,39h,26h,29h,2Eh,25h,0FFh,0Dh
	defb 39h,27h,32h,25h,21h,34h,0FFh,02h,39h,39h,2Fh,32h,2Fh,2Bh,2Fh,2Eh
	defb 24h,25h,00h,29h,34h,21h,24h,21h,2Bh,25h,2Dh,21h,33h,28h,29h,34h
	defb 21h,2Bh,21h,0FFh,08h,39h,23h,2Fh,2Eh,27h,32h,21h,34h,35h,2Ch,21h
	defb 34h,29h,2Fh,2Eh,33h,0FFh,62h,39h,00h,00h,00h,00h,00h,22h,2Fh,2Eh
	defb 35h,33h,00h,15h,10h,10h,10h,10h,00h,30h,2Fh,29h,2Eh,34h,33h,0FFh

	end

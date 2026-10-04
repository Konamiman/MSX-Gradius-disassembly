; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - changing_cells.asm
; ============================================================================

	include "bios.inc"
	include "variables.inc"

	public animate_seven_cells

; ----------------------------------------------------------------------
; AND SEVEN CELLS THAT CHANGE CHARACTER
; The other background trick: seven eight-byte cards at 0xE710, each one
; with the VRAM address of a map cell. Every so many frames another
; character from the list 0xF0, 0xF2, 0xF4, 0xF2 is written over it, and
; the next one over the cell below (0x20 bytes further on). Two cells per
; card, and not a single object involved.
; ----------------------------------------------------------------------
animate_seven_cells:		; Seven eight-byte cards at 0xE710, each one with its map cell
	ld b,007h		; Seven cards
	ld hl,CHANGING_CELLS
L_BE30:
	push bc
	push hl
	call animate_cell
	pop hl
	pop bc
	ld de,00008h		; Eight bytes per card
	add hl,de
	djnz L_BE30
	ret
animate_cell:		; Writes into its cell the character that is due, and the next one into the cell below
	dec (hl)		; The frames it has left
	ret nz
	inc hl
	ld a,(hl)		; Reloaded from the byte next to it
	dec hl
	ld (hl),a
	inc hl
	inc hl
	ld a,(hl)		; The next drawing, four of them round and round
	inc a
	and 003h
	ld (hl),a
	ld de,0be62h		; The list at 0xBE62
	call 04062h
	ld a,(de)
	inc hl
	ld e,(hl)		; The VRAM address of its cell
	inc hl
	ld d,(hl)
	ex de,hl
	call WRTVRM
	ld de,00020h		; And 0x20 further on, the one below
	add hl,de
	inc a
	jp WRTVRM

; ----------------------------------------------------------------------
; DATA table_BE62: Four bytes (0xF0, 0xF2, 0xF4, 0xF2) read by 0xBE4B with `ld
;   de,0xBE62`.
table_BE62:
	defb 0F0h,0F2h,0F4h,0F2h

	end

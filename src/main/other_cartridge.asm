; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - other_cartridge.asm
; ============================================================================

	include "bios.inc"

	public clear_typing_state,find_other_cartridge

; ----------------------------------------------------------------------
; NEMESIS LOOKS FOR ANOTHER KONAMI CARTRIDGE IN THE OTHER SLOTS
; At boot, INIT calls here and the cartridge starts looking at the
; machine's other slots and subslots with RDSLT, reading SIX bytes
; backwards from 0xBFFF and comparing them with the ones at 0x50AE.
; Those six bytes (AC 81 91 06 40 AA read in memory order) are not just
; any number: they are the END OF THE HIDDEN KONAMI MARK of another
; cartridge, the same one Nemesis carries at the end of its bank 3.
; Decoded with the house code: 0xAA closes it, 0x40 is the catalogue
; number (RC-740), 0x06 says the title has six characters, and the three
; being compared are, read the right way round, TU I N: ツイン, the
; start of ツインビー. In other words, Nemesis is looking for TwinBee
; (Konami, RC-740).
; If it finds it, 0xF0F4 stays at one, and with that the game loads extra
; graphics: the block at 0x9963 in 0x428A and the entries at 0x938E and
; 0x939B in 0x4326.
; ----------------------------------------------------------------------
find_other_cartridge:		; Walks slots 0, 0x80, 0x84, 0x88 and 0x8C looking for Konami's RC-740 mark
	xor a
	ld (0f0f4h),a		; 0xF0F4 to zero: no companion for now
	ld c,000h		; Slot 0 and the four subslots of slot 3
	call try_four_subslots
	ld c,080h
	call try_four_subslots
	ld c,084h
	call try_four_subslots
	ld c,088h
	call try_four_subslots
	ld c,08ch
	call try_four_subslots
	ret
try_four_subslots:		; Tries that slot and the next three; as soon as one matches, the search stops
	ld a,(0f0f4h)		; If it was already found, the search does not go on
	and a
	ret nz
	ld b,004h		; Four subslots
try_one_subslot:		; Tries that subslot and moves on to the next one
	push bc			; Four subslots
	call compare_mark
	pop bc
	ret z
	inc c			; The next one
	djnz try_one_subslot
	xor a
	ld (0f0f4h),a
	ret
compare_mark:		; Reads six bytes backwards from 0xBFFF in that slot and compares them with the ones at 0x50AE
	ld hl,0bfffh		; Six bytes are read from the end of page 2 of ANOTHER slot, backwards.
	ld de,050aeh		; And they are compared with the six at 0x50AE, which are the hidden Konami mark of another cartridge.
	ld b,006h		; Six bytes
L_5095:
	push bc
	push hl
	push de
	ld a,c
	call RDSLT		; RDSLT: read an address from the slot A says, without switching slots.
	pop de
	pop hl
	pop bc
	ex de,hl
	cp (hl)
	ex de,hl
	ret nz			; As soon as one does not match, it gives up.
	inc de			; One goes up and the other goes down: the mark is written backwards
	dec hl
	djnz L_5095
	ld a,001h		; If all six match, 0xF0F4 = 1, and that switches on extra graphics.
	ld (0f0f4h),a
	xor a
	ret

; ----------------------------------------------------------------------
; DATA rc740_mark: The six bytes 0x508D looks for in the other slots: AC 81 91
;   06 40 AA. They are the end of a hidden Konami mark: 0xAA closes it, 0x40
;   is the RC-740, 0x06 the length of the title, and AC 81 91 are, read the
;   right way round, TU I N (ツイン), that is, TwinBee.
rc740_mark:
	defb 0AAh,40h,06h,91h,81h,0ACh
clear_typing_state:		; 0xE1E0 to zero and the eight bytes at 0xE1E8 behind it
	push hl
	push bc
	ld hl,00000h
	ld (0e1e0h),hl
	ld hl,0e1e8h
	ld b,008h		; Eight bytes
L_50C1:
	ld (hl),000h		; Eight bytes to zero
	inc hl
	djnz L_50C1
	pop bc
	pop hl
	ret

	end

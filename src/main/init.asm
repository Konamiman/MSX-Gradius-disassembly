; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - init.asm
; ============================================================================

	include "bios.inc"
	include "variables.inc"

	extrn find_other_cartridge,interrupt,start_machine

; ----------------------------------------------------------------------
; INIT: THE BOOT
; ----------------------------------------------------------------------
INIT:		; What the BIOS calls at boot (the AB header says so at 0x4002).
	di
	im 1			; Interrupt mode 1: the BIOS hook at 0x0038 ends up leading to 0xFD9A.
	di
	push hl
	ld hl,BANK_6000		; This, 0xF0F2 and 0xF0F3 are the RAM copy of the three mapper registers.
	ld a,001h
	ld (06000h),a		; Bank 1 at 0x6000...
	ld (hl),a
	inc a
	ld (08000h),a		; ...bank 2 at 0x8000...
	inc hl
	ld (hl),a
	inc a
	ld (0a000h),a		; ...and bank 3 at 0xA000. It is the default layout for the whole game.
	inc hl
	ld (hl),a
	pop hl
	ei
	call find_my_slot
	ld h,080h		; H = 0x80: this cartridge is enabled in page 2, which is where 0x8000 and 0xA000 fall.
	call ENASLT
	ld a,0c3h		; `jp interrupt` is installed in the H.KEYI hook.
	ld (H_KEYI),a
	ld hl,interrupt
	ld (H_KEYI+1),hl
	ld sp,STACK_TOP		; The stack, right below the mapper copy.
	ld hl,GAME_RAM		; The 4 KB up to 0xEFFF are cleared, which is all of the game's memory.
	ld de,GAME_RAM+1
	ld bc,00fffh
	ld (hl),000h
	ldir
	ld a,001h
	ld (INTERRUPT_LOCK),a	; This and 0xE006 to 1: the lock is set while booting.
	ld (DEMO_STAGE),a
	call start_machine
	call find_other_cartridge
	xor a
	ld (INTERRUPT_LOCK),a
	call RDVDP
	di			; And once again the usual layout, now with the RAM clean
	push hl
	ld hl,BANK_6000
	ld a,001h
	ld (06000h),a
	ld (hl),a
	inc a
	ld (08000h),a
	inc hl
	ld (hl),a
	inc a
	ld (0a000h),a
	inc hl
	ld (hl),a
	pop hl
	ei
	ei			; INIT ends here, and stays here: the `jr $` next to it never exits.
L_40DF:
	jr L_40DF		; And this is the end of INIT. There is no way out of here: the rest happens in the interrupt.
find_my_slot:		; Builds for ENASLT the slot number of this cartridge, reading RSLREG and SLTTBL.
	call RSLREG		; RSLREG: the primary slot register
	rrca			; Two rotations: the slot of page 1, which is where this cartridge sits
	rrca
	and 003h
	ld c,a
	ld b,000h
	ld hl,EXPTBL		; The BIOS table that says whether that slot has subslots
	add hl,bc
	ld a,(hl)
	and 080h		; Bit 7 marks that it has them
	or c
	ld c,a
	inc hl			; Four more: the subslot of page 1
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	and 00ch
	or c
	ret

; ----------------------------------------------------------------------
; DATA dead_jump: Three bytes that are `jp 0x49E9`, that is, a shortcut to
;   request a sound. No instruction or table in the cartridge points to
;   0x40FD, and the one before ends in `ret`: it is dead code, and that is why
;   it is listed as bytes.
jump_to_request_sound:		; `jp 0x49E9`. Nobody jumps here: it is dead code.
	defb 0C3h,0E9h,49h

	end

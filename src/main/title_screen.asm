; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - title_screen.asm
; ============================================================================

	include "screens_symbols.inc"

	public blink_selection,build_high_score_screen,L_5BDD
	extrn add_a_to_hl,clear_screen,decompress,decompress_three_thirds,dump_to_vram,L_49A0
	extrn request_sound,set_vram_write,write_characters

; (The last instruction of vdp_setup.asm falls through into here.)

; ----------------------------------------------------------------------
; THE SAME CARTRIDGE IS CALLED GRADIUS OR NEMESIS DEPENDING ON THE MACHINE
; Here is the reason this game has two names. The cartridge reads 0x002B
; of the BIOS and keeps the low nibble, which is the machine's character
; set: at zero, Japanese. And with that it picks which of the TWO logos
; it writes on row 4: the one at 0x9BCB or the one at 0x9B3F, five rows
; of 28 characters each, both in bank 9 and right next to each other.
; Drawn from the ROM (decompressing their patterns from 0x9C57 and their
; colours from 0x9EAB and painting the panel) you can read what they
; say: the Japanese machine's one says GRADIUS and the other NEMESIS.
; They are not two versions of the cartridge: it is the SAME binary, with
; both titles inside.
; It is the same split by country that 0x4C42 uses for the ending message.
; ----------------------------------------------------------------------
	ld a,(0002bh)		; The low nibble of 0x002B: the character set. At zero, Japanese
	and 00fh
	ld de,09bcbh		; The Japanese panel...
	jr z,L_5B9B
	ld de,09b3fh		; ...and the one for the other machines
L_5B9B:
	ld hl,03882h		; Row 4, column 2
	ld b,005h		; Five rows
L_5BA0:
	push bc
	call set_vram_write
	ld b,01ch		; Twenty-eight characters per row
L_5BA6:
	ld a,(de)		; Twenty-eight characters, through the data port
	inc de
	exx
	out (c),a
	exx
	djnz L_5BA6
	ld a,020h		; 0x20: the row below
	call add_a_to_hl	; 0x20: the row below
	pop bc
	djnz L_5BA0
	di
	ld a,002h
	ld (08000h),a
	ld (0f0f2h),a
	ei
	di
	ld a,003h
	ld (0a000h),a
	ld (0f0f3h),a
	ei
	ld de,057ebh		; And on top, the two messages at 0x57EB
	call write_characters
	jp write_characters
blink_selection:		; A bit of 0xE004 turns off and on the message of the option selected in the intro
	ld hl,0e004h
	bit 3,(hl)		; Bit 3 of the counter: on and off
	ld c,0ffh
	jr nz,L_5BDD
	inc c
L_5BDD:
	ld hl,03a2ah		; Row 17, column 10, and the one 0x40 further down
	ld de,03a6ah
	ld a,(0e052h)		; 0xE052 says which of the two is selected
	or a
	jr z,L_5BEA
	ex de,hl
L_5BEA:
	push de
	call L_5BF1
	pop hl
	ld c,000h
L_5BF1:
	ld de,0581dh
	jp L_49A0

; ----------------------------------------------------------------------
; DATA stray_byte: A 0x00 between two routines. GUESS: alignment filler; no
;   instruction reads it.
stray_byte:
	defb 00h
build_high_score_screen:		; With banks 9 and 10, decompresses the six blocks of the high score table and copies the 768 characters at 0x8000 to it as they are
	call clear_screen
	di
	ld a,009h
	ld (08000h),a
	ld (0f0f2h),a
	ei
	di
	ld a,00ah
	ld (0a000h),a
	ld (0f0f3h),a
	ei
	ld hl,02008h		; Three pattern blocks, at 0x2008, 0x2808 and 0x3008
	ld de,08300h
	call decompress
	ld hl,02808h
	ld de,087fah
	call decompress
	ld hl,03008h
	ld de,08cb2h
	call decompress
	ld hl,00008h		; And their three colour ones, at 0x0008, 0x0808 and 0x1008
	ld de,0917eh
	call decompress
	ld hl,00808h
	ld de,09515h
	call decompress
	ld hl,01008h
	ld de,0989fh
	call decompress
	ld hl,02780h		; The characters of the frame around it, in the three thirds
	ld de,0a758h
	call decompress_three_thirds
	ld hl,00780h
	ld de,0a783h
	call decompress_three_thirds
	ld hl,01800h		; And the sprite patterns
	ld de,0a7a4h
	call decompress
	call set_up_screen
	ld hl,03800h
	ld de,08000h		; 0x8000: 768 UNCOMPRESSED characters, the whole screen in one go
	ld bc,00300h
	call dump_to_vram
	di
	ld a,002h
	ld (08000h),a
	ld (0f0f2h),a
	ei
	di
	ld a,003h
	ld (0a000h),a
	ld (0f0f3h),a
	ei
	ld a,0a6h		; Sound 0xA6
	jp request_sound

	end

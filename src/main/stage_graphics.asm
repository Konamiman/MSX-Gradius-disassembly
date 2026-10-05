; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - stage_graphics.asm
; ============================================================================

	include "bios.inc"
	include "variables.inc"

	include "scenery_symbols.inc"
	public build_mirror,load_entries,load_stage_graphics,stage_positions
	extrn add_a_to_de,add_a_to_hl,decompress,dump_to_vram,get_word,load_stage_font

; ----------------------------------------------------------------------
; THE GRAPHICS OF EACH STAGE
; The cartridge does not store the screens already drawn: it stores
; compressed blocks in banks 4, 5 and 6, and when a stage starts it
; decompresses them into VRAM. With the graphics in place, build_mirror ALSO
; makes the flipped characters: flip_bits reverses the bits of each byte
; (horizontal mirror) and flip_bytes reverses the order of the eight bytes
; (vertical mirror). That way a drawing and its reflection take up a
; single block in the ROM.
; ----------------------------------------------------------------------
load_stage_graphics:		; Maps banks 4, 5 and 6, decompresses what is due for the stage and restores the usual layout
	call load_stage_font
	di			; Banks 4, 5 and 6, which are the graphics ones
	push hl			; Banks 4, 5 and 6, which are the graphics ones
	ld hl,BANK_6000
	ld a,004h
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
	call load_stage_characters
	ld hl,01800h		; The block at 0x86BB to VRAM 0x1800: the sprite patterns
	ld de,stage_graphics_blocks
	call decompress
	ld a,(STAGE)		; The stage times six: two groups of three bytes in the table at 0x42AD
	add a,a
	ld b,a
	add a,a
	add a,b
	ld hl,graphics_per_stage-6
	call add_a_to_hl
	ld b,002h		; Two blocks per stage
decompress_both_blocks:		; For each group: the source in DE and, in C, the character where it starts; the VRAM address comes from C times eight plus 0x1800
	push bc
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld c,(hl)		; The third byte is the character where it starts
	inc hl
	push hl
	ld l,c			; Times eight: each character is eight bytes
	ld h,000h
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,01800h		; And from VRAM 0x1800
	add hl,bc
	call decompress
	pop hl
	pop bc
	djnz decompress_both_blocks
	ld a,(STAGE)
	cp 005h			; Stage 5 also gets the block at 0x8FCB at VRAM 0x1D00
	jr nz,L_428A
	ld hl,01d00h
	ld de,graphics_1D00
	call decompress
L_428A:
	ld a,(TWINBEE_FOUND)	; And with it set, one more at 0x1800
	or a
	jr z,restore_usual_layout
	ld hl,01800h
	ld de,graphics_names_1800
	call decompress
restore_usual_layout:		; Banks 1, 2 and 3 in their three slots, and the RAM copy up to date
	di			; The usual layout is restored: banks 1, 2 and 3
	push hl
	ld hl,BANK_6000
	ld a,001h
	ld (06000h),a		; Bank 1 at 0x6000...
	ld (hl),a
	inc a
	ld (08000h),a		; ...bank 2 at 0x8000...
	inc hl
	ld (hl),a
	inc a
	ld (0a000h),a		; ...and bank 3 at 0xA000
	inc hl
	ld (hl),a
	pop hl
	ei
	ret

; ----------------------------------------------------------------------
; DATA graphics_per_stage: Six bytes per stage: two groups of (source of the
;   compressed block, index of the character where it starts). The declared
;   base is 0x42AD (0x4259), which falls INSIDE the code: stage 0 does not
;   exist and the table really starts at stage 1. The sources point into bank
;   5.
graphics_per_stage:
	defb 4Bh,8Eh,0BCh,8Ch,8Ah,0CCh
	defb 4Bh,8Eh,0BCh,8Ch,8Ah,0CCh
	defb 1Eh,8Ch,0DCh,0CAh,8Eh,0BCh
	defb 0CAh,8Eh,0BCh,8Ch,8Ah,0CCh
	defb 0CAh,8Eh,0BCh,38h,90h,0CCh
	defb 0CAh,8Eh,0BCh,8Ch,8Ah,0CCh
	defb 27h,8Dh,0DCh,4Bh,8Eh,0BCh
	defb 4Bh,8Eh,0BCh,8Ch,8Ah,0CCh
	defb 3Eh,8Fh,0E0h,0FBh,42h,0FFh
	defb 3Eh,8Fh,0E0h,0FBh,42h,0FFh
	defb 3Eh,8Fh,0E0h,0FBh,42h,0FFh
	defb 3Eh,8Fh,0E0h,0FBh,42h,0FFh

; ----------------------------------------------------------------------
; DATA empty_block: A single 0x00. It is a compressed stream that ends at its
;   first byte, and stages 9 to 12 use it as "there is no second block here".
empty_block:
	defb 00h
load_stage_characters:		; The entries at 0x932D and the ones due for the stage, plus the two batches of mirrors
	ld ix,common_records	; The entries at common_records: the ones every stage gets
	call load_entries
	ld a,(STAGE)
	ld hl,record_lists_A	; And the table at record_lists_A, indexed by the stage
	call get_word
	push de
	pop ix
	call load_entries
	xor a
	ld (MIRROR_KIND),a	; To zero: the batch that is flipped by bits
	ld hl,record_lists_B
	call walk_entries
	ld hl,MIRROR_KIND
	inc (hl)		; And to one: the one that is flipped by bytes
	ld hl,record_lists_C
	call walk_entries
	ld a,(TWINBEE_FOUND)	; That part is only loaded if this is set
	or a
	ret z
	ld ix,extra_records_1
	call load_entries
	ld a,(STAGE)
	cp 009h			; From the ninth stage onwards, one more set
	ld ix,extra_records_2
	call nc,load_entries
	ret
walk_entries:		; Takes from the table in HL the list due for the stage and walks it
	ld a,(STAGE)
	call get_word
	push de
	pop ix
build_mirror:		; For each four-byte entry: unpacks it, flips it and uploads it to the thirds its bits say
	ld a,(ix+000h)		; A zero first byte ends the list
	and a
	ret z
	ld l,(ix+003h)		; The fourth byte is the character; times eight, the bytes it takes up
	ld h,000h
	add hl,hl
	add hl,hl
	add hl,hl
	ld (MIRROR_BYTES),hl
	call download_character_to_ram
	ld a,(MIRROR_KIND)	; Says which mirror it is
	and a
	push af
	call z,flip_bits	; At zero, the bit mirror: horizontal
	pop af
	call nz,flip_bytes	; And at one, the byte mirror: vertical
	call upload_mirror
	ld de,00004h		; Four bytes per entry
	add ix,de
	jr build_mirror
load_entries:		; Walks six-byte entries and passes the patterns and colours of each one to decompress.
	ld a,(ix+000h)
	and a
	ret z
	rra			; Bit 0: the third third, at VRAM 0x1000
	ld de,01000h
	call c,decompress_patterns_and_colours
	bit 1,(ix+000h)		; Bit 1: the middle one, at 0x0800
	ld de,00800h
	call nz,decompress_patterns_and_colours
	bit 2,(ix+000h)		; And bit 2: the first one, at 0x0000
	ld de,00000h
	call nz,decompress_patterns_and_colours
	ld de,00006h		; Six bytes per entry
	add ix,de
	jr load_entries
decompress_patterns_and_colours:		; The character times eight plus the third: the patterns go 0x2000 higher and the colours as they are
	ld l,(ix+003h)		; The character times eight, plus the third that is due
	ld h,000h
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,de
	push hl
	ld de,02000h		; The patterns live 0x2000 above the colours
	add hl,de
	ld e,(ix+001h)		; The pointer to the patterns, in the entry
	ld d,(ix+002h)
	push ix
	call decompress
	pop ix
	pop hl
	ld de,00000h
	add hl,de
	ld e,(ix+004h)		; And the one to the colours, three bytes further on
	ld d,(ix+005h)
	push ix
	call decompress
	pop ix
	ret
flip_bytes:		; VERTICAL mirror: reverses the order of the character's eight bytes, in the two buffers at MIRROR_PATTERNS and MIRROR_COLOURS
	ld hl,MIRROR_PATTERNS	; The pattern buffer...
	ld de,MIRROR_PATTERNS+7
	call L_43D5
	ld hl,MIRROR_COLOURS	; ...and the colour one
	ld de,MIRROR_COLOURS+7
L_43D5:
	exx
	ld b,(ix+003h)		; As many characters as the entry says
L_43D9:
	exx
	ld b,004h		; Four swaps: the eight bytes reversed
swap_eight_bytes:		; The character's eight bytes, swapped in pairs working inwards: that is the vertical mirror
	ld c,(hl)		; One goes up and the other goes down
	ld a,(de)
	ld (hl),a
	ld a,c
	ld (de),a
	inc hl
	dec de
	djnz swap_eight_bytes
	inc hl			; Four more: the next character
	inc hl
	inc hl
	inc hl
	ld a,00ch		; 0x0C: the next character, counting backwards
	call add_a_to_de
	exx
	djnz L_43D9
	ret
flip_bits:		; HORIZONTAL mirror: reverses the eight bits of each byte with `rr (hl)` and `adc a,a`
	ld hl,MIRROR_PATTERNS
	ld de,(MIRROR_BYTES)
L_43F9:
	ld b,008h		; Eight bits per byte
L_43FB:
	rr (hl)			; Out at the bottom and in at the top: the byte reversed
	adc a,a
	djnz L_43FB
	ld (hl),a
	inc hl
	dec de			; As many bytes as MIRROR_BYTES says
	ld a,d
	or e
	jr nz,L_43F9
	ret
upload_mirror:		; Bits 3, 4 and 5 of the second byte say which thirds the flipped character is uploaded to
	bit 3,(ix+002h)		; Bit 3: the third third
	ld de,01000h
	call nz,upload_mirror_to_vram
	bit 4,(ix+002h)		; Bit 4: the middle one
	ld de,00800h
	call nz,upload_mirror_to_vram
	bit 5,(ix+002h)		; And bit 5: the first one
	ld de,00000h
	ret z
upload_mirror_to_vram:		; The flipped character goes back to VRAM: the patterns from MIRROR_PATTERNS and the colours from MIRROR_COLOURS
	push ix
	ld l,(ix+001h)		; The second byte of the entry is the destination character
	ld h,000h
	add hl,hl		; Times eight, plus the third that DE brings
	add hl,hl
	add hl,hl
	add hl,de
	push hl
	ld de,02000h		; The patterns, 0x2000 higher
	add hl,de
	ld de,MIRROR_PATTERNS
	ld bc,(MIRROR_BYTES)	; And as many bytes as it says
	call dump_to_vram
	pop hl
	ld de,00000h		; The colours go as they are, without the 0x2000
	add hl,de
	ld de,MIRROR_COLOURS
	ld bc,(MIRROR_BYTES)
	call dump_to_vram
	pop ix
	ret
download_character_to_ram:		; The character to be flipped is brought from VRAM to 0xE300 and MIRROR_COLOURS: to make the mirror you have to read what was already uploaded
	ld bc,(MIRROR_BYTES)
	ld l,(ix+000h)		; The first byte of the entry: the source character
	ld h,000h
	add hl,hl
	add hl,hl
	add hl,hl
	push hl
	ld de,02000h
	bit 2,(ix+002h)		; Bit 2: the first third, at 0x2000
	jr nz,L_4470
	ld d,028h		; Bit 1: the middle one, at 0x2800
	bit 1,(ix+002h)
	jr nz,L_4470
	ld d,030h		; And if not, the third one, at 0x3000
L_4470:
	add hl,de
	ld de,MIRROR_PATTERNS
	push ix
	call LDIRMV		; LDIRMV: from VRAM to RAM, the reverse of LDIRVM
	pop ix
	pop hl
	ld de,00000h
	bit 2,(ix+002h)		; The same three thirds for the colours: 0x0000, 0x0800 and 0x1000
	jr nz,L_448F
	ld d,008h
	bit 1,(ix+002h)
	jr nz,L_448F
	ld d,010h
L_448F:
	add hl,de
	ld de,MIRROR_COLOURS
	ld bc,(MIRROR_BYTES)
	push ix
	call LDIRMV
	pop ix
	ret

; ----------------------------------------------------------------------
; DATA stage_positions: Rows of six bytes that 0x41CA copies to MIRROR_BYTES with
;   the base 0x4499, again six bytes ahead of where the range starts.
stage_positions:
	defb 80h,00h,0A0h,01h,9Fh,01h
	defb 80h,00h,0A0h,01h,0CFh,01h
	defb 0FFh,0FFh,0FFh,0FFh,9Fh,01h
	defb 80h,00h,0A0h,01h,9Fh,01h
	defb 80h,00h,0E0h,01h,0DFh,01h
	defb 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
	defb 80h,00h,80h,01h,7Fh,01h
	defb 40h,00h,0C0h,01h,81h,01h
	defb 20h,00h,00h,01h,1Fh,01h
	defb 20h,00h,00h,01h,1Fh,01h
	defb 20h,00h,0C0h,00h,0DFh,00h
	defb 20h,00h,80h,01h,9Fh,01h

	end

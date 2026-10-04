; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - boss_death_fade.asm
; ============================================================================

	include "bios.inc"
	include "variables.inc"

	public switch_off_screen

; ----------------------------------------------------------------------
; WHEN THE BOSS DIES, THE SCREEN GOES DARK BY EATING THE VRAM
; The cartridge does not clear the screen to end the stage: it eats it. It
; brings blocks of 0x200 bytes down from VRAM to 0xEA00, ANDs them with a
; mask and sends them back up. First it makes one pass over the COLOUR
; table (which in this cartridge lives at VRAM 0x0000) with mask 0xF0, and
; then repeats the pass EIGHT times over the PATTERN table (0x2000) with
; 0xFE, 0xFC, 0xF8... down to 0x00, also rotating the mask three bits per
; byte, so that the black comes in crumbled and not in rows.
; Bank 2 calls it from two different bosses, and when it is done it sets
; 0xE1A3.
; ----------------------------------------------------------------------
switch_off_screen:		; The four steps of the fade: eat the colours, eat the patterns, clear 0xED00 and report back
	ld hl,FADE_STEP		; Which step the fade is on
	ld a,(hl)
	dec a
	jr z,eat_patterns
	dec a
	jr z,clear_buffer
	dec a
	jp z,report_done
	ld a,(ENDING)		; If nothing else is already playing, sound 0x3E
	and a
	ld a,03eh
	call z,049deh
	xor a			; 0xE1A3 to zero: not finished yet
	ld (FADE_DONE),a
	inc l			; 0xE1A1 to zero: starting from the first row
	ld (hl),a
	inc l
	ld (hl),0f0h		; 0xE1A2: the mask starts at 0xF0
eat_background_colours:		; A whole pass over the colour table, 0x40 rows at a time
	ld a,(FADE_ROW)		; Which row it is on
	cp 040h			; The first third does not reach 0x1000
	jr c,L_A6F3
	cp 080h
	jr nc,L_A6ED
	ld a,044h
L_A6ED:
	ld de,01000h		; The third third of colours
	call eat_chunk
L_A6F3:
	ld de,00800h		; The second...
	call chunk_with_current_mask
	ld de,00000h		; ...and the first
	call chunk_with_current_mask
	ld hl,FADE_ROW
	ld a,(hl)
	add a,040h		; 0x40 more rows
	ld (hl),a
	jr nz,eat_background_colours
	dec l
	inc (hl)		; Once all the way round, step 1
	inc l
	inc l
	ld (hl),0feh		; And the pattern mask starts at 0xFE
	ret
eat_patterns:		; The same pass, but over the pattern table and removing one more bit each round
	ld a,(FADE_ROW)
	cp 040h			; Below row 0x40, only two thirds
	jr c,L_A722
	cp 080h			; And row 0x44 takes fewer bytes
	jr nc,L_A71C
	ld a,044h
L_A71C:
	ld de,03000h		; The third third of patterns
	call eat_chunk
L_A722:
	ld de,02800h		; The second...
	call chunk_with_current_mask
	ld de,02000h		; ...and the first
	call chunk_with_current_mask
	ld hl,FADE_ROW
	ld a,(hl)
	add a,040h
	ld (hl),a
	ret nz			; Until it has gone all the way round, nothing
	inc l
	ld a,(hl)
	and a
	jr z,L_A73E
	sla (hl)		; One bit fewer in the mask
	ret
L_A73E:
	ld a,002h		; With the mask at zero everything is black: step 2
	ld (FADE_STEP),a
	ret
clear_buffer:		; The 0x2C0 bytes of 0xED00 to zero, and on to step 3
	ld hl,MAP		; From here onwards...
	ld de,MAP+1
	ld bc,002bfh		; ...0x2C0 bytes to zero
	ld (hl),000h
	ldir
	ld a,003h		; And step 3
	ld (FADE_STEP),a
	ret
report_done:		; When the sound stops, 0xE1A3 is set and bank 2 takes the boss as dead
	ld a,(SND_CARD_A+CARD_MODE)	; Not until the sound stops
	and a
	ret nz
	ld a,001h		; 0xE1A3 to one: bank 2 can now carry on
	ld (FADE_DONE),a
	ret
chunk_with_current_mask:		; Comes in with the current row in 0xE1A1
	ld a,(FADE_ROW)
eat_chunk:		; Brings 0x200 bytes down from VRAM to 0xEA00, applies the mask to them and sends them back up
	ld bc,00200h		; Half a kilobyte at a time
	cp 044h			; Two rows take fewer: 0x44...
	jr nz,L_A76F
	ld bc,001e0h
L_A76F:
	cp 0c0h			; ...and 0xC0
	jr nz,L_A776
	ld bc,001b0h
L_A776:
	ld l,a			; The row times eight: the byte where it starts
	ld h,000h
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,de
	push hl
	ld de,FADE_BUFFER	; The block comes down here
	push bc
	call LDIRMV
	pop bc
	push bc
	ld hl,FADE_BUFFER
	ld a,(FADE_MASK)	; This round's mask
	ld e,a
	call apply_mask
	pop bc
	pop hl
	ld de,FADE_BUFFER
	jp 04960h		; And the block, bitten, goes back to VRAM
apply_mask:		; In the first step the mask is the same for every byte; in the rest it rotates three bits per byte
	ld a,(FADE_STEP)
	and a
	jr nz,rotating_mask
fixed_mask:		; AND with the same mask byte by byte
	ld a,(hl)		; AND with the mask, byte by byte
	and e
	ld (hl),a
	inc hl
	dec bc			; Half a kilobyte
	ld a,b
	or c
	jr nz,fixed_mask
	ret
rotating_mask:		; Three bits of rotation per byte: the black comes in crumbled
	ld a,(hl)		; The same mask, rotated three bits...
	and e
	ld (hl),a
	inc hl
	rrc e
	rrc e
	rrc e
	dec bc			; ...on every byte of the block
	ld a,b
	or c
	jr nz,rotating_mask
	ret

	end

; ============================================================================
; Nemesis / Gradius - screens image (banks 9-10) - screen_engine.asm
; ============================================================================

	include "variables.inc"

	public data_AAB0,run_screen,set_up_screen,type_3_piece_drawings

; ----------------------------------------------------------------------
; A FOUR-SPRITES-PER-CRITTER ENGINE, ONLY FOR THE FIXED SCREEN
; This bank carries its own little engine, separate from the game's:
; eight slots of eight bytes at SCREEN_CRITTERS, three spawners at SCREEN_SPAWNERS and,
; for each slot, up to FOUR consecutive sprite entries in the buffer at
; SPRITE_BUFFER. Each critter comes into view one sprite at a time (byte 5
; counts how many it has) and moves with a pair of fixed displacements
; that its type gives it.
; ----------------------------------------------------------------------
set_up_screen:		; Clears the work RAM, sets up the three spawners and copies a routine for itself to CHANGING_CELLS
	ld hl,SCREEN_CRITTERS	; 0x800 bytes, to zero
	ld de,SCREEN_CRITTERS+1
	ld bc,00800h
	ld (hl),000h
	ldir
	ld hl,initial_values	; The three spawners, from initial_values to 0xE500
	ld de,SCREEN_SPAWNERS
	ld b,003h		; Three slots
L_A81E:
	push bc
	ldi			; Four useful bytes of each one
	inc de
	ldi
	ldi
	ldi
	inc de
	inc de
	inc de
	pop bc
	djnz L_A81E
	ld a,010h		; BG_OBJECTS, 0xE702 and 0xE704: where each one starts
	ld (CHAR_ANIM+1),a
	ld a,018h
	ld (CHAR_ANIM+3),a
	ld a,020h
	ld (CHAR_ANIM+5),a
	ld bc,00038h		; And 0x38 bytes of routine, copied to CHANGING_CELLS to run them from RAM
	ld hl,routine_for_RAM
	ld de,CHANGING_CELLS
	ldir
	ret

; ----------------------------------------------------------------------
; DATA routine_for_RAM: 56 bytes that 0xA840 copies with LDIR to CHANGING_CELLS. They
;   run from RAM, not from here.
routine_for_RAM:
	defb 01h,20h,00h,0C1h,38h,00h,00h,00h,01h,28h,01h,63h,39h,00h,00h,00h
	defb 01h,14h,02h,0C7h,3Ah,00h,00h,00h,01h,1Ch,03h,2Dh,38h,00h,00h,00h
	defb 01h,24h,00h,95h,39h,00h,00h,00h,01h,10h,01h,19h,3Ah,00h,00h,00h
	defb 01h,20h,02h,0DDh,38h,00h,00h,00h

; ----------------------------------------------------------------------
; DATA initial_values: Three groups of four bytes that 0xA816 spreads over
;   SCREEN_SPAWNERS, leaving four empty bytes between one group and the next.
initial_values:
	defb 00h,40h,45h,16h
	defb 01h,10h,38h,80h
	defb 02h,40h,45h,0EAh
run_screen:		; A whole frame: moves the critters, lets the spawners release more, and builds the sprite entries
	call move_the_eight
	call run_spawners
	call build_sprite_entries
	ret
move_the_eight:		; The eight eight-byte slots at SCREEN_CRITTERS, one by one
	ld ix,SCREEN_CRITTERS
	ld b,008h		; Eight slots
L_A89D:
	push bc
	ld a,(ix+000h)		; An empty slot is left alone
	and a
	call nz,critter_step
	pop bc
	ld de,00008h		; Eight bytes: the next slot
	add ix,de
	djnz L_A89D
	ret
critter_step:		; While it is coming into view it keeps getting more sprites, and once whole it moves until it goes off screen
	ld a,(ix+001h)		; Byte 1: whether it has finished coming into view
	and a
	jr nz,critter_moves
	dec (ix+002h)		; Byte 2: the frames until the next sprite
	ret nz
	ld (ix+002h),002h	; Two frames per sprite
	inc (ix+005h)		; Byte 5: one more sprite
	ld a,(ix+005h)
	cp 004h			; Four sprites and it is whole
	ret c
	inc (ix+001h)
	ret
critter_moves:		; The two displacements its type gives it; when it leaves through the bottom or the right, the slot is switched off
	ld a,(ix+000h)
	add a,a
	ld e,a
	ld d,000h
	ld hl,displacements	; The table at displacements: two bytes per type
	add hl,de
	ld a,(ix+003h)		; Byte 3, the row, plus its own
	add a,(hl)
	inc hl
	ld (ix+003h),a
	cp 0c0h			; Past row 0xC0, out
	jr c,L_A8E4
	ld (ix+000h),000h
L_A8E4:
	ld a,(ix+004h)		; And byte 4, the column
	add a,(hl)
	ld (ix+004h),a
	cp 0f0h			; Past column 0xF0, out too
	ret c
	ld (ix+000h),000h
	ret

; ----------------------------------------------------------------------
; DATA displacements: Twenty-four bytes read by 0xA8D0.
displacements:
	defb 0F8h,0FCh,0F8h,0F8h,0FCh,0F8h,04h,0F8h,08h,0F8h,08h,0FCh,08h,04h,08h,08h,04h,08h,0FCh,08h,0F8h,08h,0F8h,04h
run_spawners:		; The three spawners at SCREEN_SPAWNERS release a critter every eight frames
	ld ix,SCREEN_SPAWNERS
	ld b,003h		; Three spawners
L_A911:
	push bc
	dec (ix+002h)		; Byte 2: the frames still to go
	jr nz,L_A91E
	ld (ix+002h),008h	; Eight frames between one critter and the next
	call release_critter
L_A91E:
	pop bc
	ld de,00008h		; Eight bytes: the next spawner
	add ix,de
	djnz L_A911
	ret
release_critter:		; Picks the type from the table at spawner_critter_types, looks for a free slot among the eight and fills it with its position, its drawing and its colour
	ld a,(ix+000h)		; The spawner's type, times four
	add a,a
	add a,a
	ld c,a
	ld a,(ix+005h)		; Byte 5: which of the four is next
	and 003h
	cp 003h			; Every four critters, 0x60 frames of rest
	jr nz,L_A93A
	ld (ix+002h),060h
L_A93A:
	inc (ix+005h)		; One more for next time
	add a,c
	ld hl,spawner_critter_types	; The table at spawner_critter_types: four types per spawner
	ld e,a
	ld d,000h
	add hl,de
	ld c,(hl)
	ld hl,SCREEN_CRITTERS	; The eight slots
	ld b,008h
	xor a
L_A94C:
	cp (hl)			; The first one with its first byte at zero
	jr z,L_A956
	ld de,00008h
	add hl,de
	djnz L_A94C
	ret
L_A956:
	ld (hl),c		; The type, in the first byte
	inc hl
	ld (hl),000h		; No sprites yet, and two frames until the first one
	inc hl
	ld (hl),002h
	inc hl
	ld a,c			; The type times three: the table at critter_offsets_and_drawings
	add a,a
	add a,c
	ld de,critter_offsets_and_drawings
	add a,e
	ld e,a
	jr nc,L_A969
	inc d
L_A969:
	ld a,(de)
	inc de
	add a,(ix+003h)		; The spawner's row plus its offset...
	ld (hl),a
	inc hl
	ld a,(de)		; ...and its column
	inc de
	add a,(ix+004h)
	ld (hl),a
	inc hl
	ld (hl),001h		; Byte 5 to one: one sprite already
	inc hl
	ex de,hl
	ldi
	ld hl,critter_colours	; And its colour comes from critter_colours
	ld c,(ix+000h)
	ld b,000h
	add hl,bc
	ld a,(hl)
	ld (de),a
	ret

; ----------------------------------------------------------------------
; DATA spawner_critter_types: Twelve bytes read by 0xA93E.
spawner_critter_types:
	defb 06h,07h,08h,07h,04h,05h,06h,07h,03h,04h,05h,04h

; ----------------------------------------------------------------------
; DATA critter_offsets_and_drawings: Thirty-six bytes read by 0xA961.
critter_offsets_and_drawings:
	defb 10h,0F8h,00h,10h,0F0h,04h,08h,0F0h,08h,00h,0F0h,0Ch
	defb 00h,0F0h,10h,00h,0F0h,14h,00h,00h,00h,00h,00h,04h
	defb 00h,00h,08h,08h,00h,0Ch,10h,00h,10h,10h,0F8h,14h

; ----------------------------------------------------------------------
; DATA critter_colours: Nine bytes read by 0xA97D.
critter_colours:
	defb 07h,0Bh,07h,07h,07h,0Fh,0Bh,0Fh,0Fh
build_sprite_entries:		; For each of the eight critters, four sprite entries in the buffer at SPRITE_BUFFER
	ld b,008h		; Eight critters
	ld ix,SCREEN_CRITTERS
	ld hl,SPRITE_BUFFER	; The sprite attribute buffer
L_A9CB:
	push bc
	ld a,(ix+000h)		; Empty or full, each critter takes up its four entries
	and a
	push af
	call z,four_entries_off
	pop af
	call nz,this_critter_entries
	ld de,00008h		; Eight bytes: the next critter
	add ix,de
	pop bc
	djnz L_A9CB
	ret
four_entries_off:		; 0x10 bytes set to 0xE0: this critter's four sprites, off screen
	ld b,010h
L_A9E3:
	ld (hl),0e0h
	inc hl
	djnz L_A9E3
	ret
this_critter_entries:		; One entry per sprite in view, with the offset its type gets from the table at critter_sprite_offsets
	ld a,(ix+000h)		; The type times eight: the table at critter_sprite_offsets
	add a,a
	add a,a
	add a,a
	ld de,critter_sprite_offsets
	add a,e
	ld e,a
	jr nc,L_A9F7
	inc d
L_A9F7:
	ld b,(ix+005h)		; Byte 5: how many sprites it has
	ld a,b
	and a
	jr z,switch_off_leftovers
L_A9FE:
	ld a,(de)		; The critter's row plus the offset...
	add a,(ix+003h)
	cp 0c0h			; ...and below 0xC0 it is not drawn
	jr c,L_AA08
	ld a,0e0h
L_AA08:
	ld (hl),a
	inc hl
	inc de
	ld a,(de)		; ...and its column
	add a,(ix+004h)
	ld (hl),a
	xor (ix+004h)		; If the column wraps around, the sprite is switched off
	and 080h
	jr z,L_AA24
	ld a,(ix+004h)
	sub 040h
	cp 080h
	jr c,L_AA24
	dec hl
	ld (hl),0e0h
	inc hl
L_AA24:
	inc hl
	inc de
	ld a,(ix+006h)		; Byte 6: the drawing
	ld (hl),a
	inc hl
	ld a,(ix+007h)		; And byte 7: the colour
	ld (hl),a
	inc hl
	djnz L_A9FE
switch_off_leftovers:		; The sprites that have not come into view yet, with 0xE0 in all four bytes
	ld a,004h		; Four minus the ones it has
	sub (ix+005h)
	ret z
	ld b,a
	ld a,0e0h		; 0xE0: the VDP does not draw them
L_AA3B:
	ld (hl),a		; The four bytes of the entry
	inc hl
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl			; And on to the next one
	djnz L_AA3B
	ret

; ----------------------------------------------------------------------
; DATA critter_sprite_offsets: Ninety-six bytes read by 0xA9EF.
critter_sprite_offsets:
	defb 00h,00h,0F0h,0F8h,0E0h,0F0h,0D0h,0E8h,00h,00h,0F0h,0F0h,0E0h,0E0h,0D0h,0D0h
	defb 00h,00h,0F8h,0F0h,0F0h,0E0h,0E8h,0D0h,00h,00h,08h,0F0h,10h,0E0h,18h,0D0h
	defb 00h,00h,10h,0F0h,20h,0E0h,30h,0D0h,00h,00h,10h,0F8h,20h,0F0h,30h,0E8h
	defb 00h,00h,10h,08h,20h,10h,30h,18h,00h,00h,10h,10h,20h,20h,30h,30h
	defb 00h,00h,08h,10h,10h,20h,18h,30h,00h,00h,0F8h,10h,0F0h,20h,0E8h,30h
	defb 00h,00h,0F0h,10h,0E0h,20h,0D0h,30h,00h,00h,0F0h,08h,0E0h,10h,0D0h,18h

; ----------------------------------------------------------------------
; DATA type_3_piece_drawings: Five words read by 0x831B in bank 2 with get_word, indexing
;   with (IX+6).
type_3_piece_drawings:
	defw data_AAB0+50h,data_AAB0+63h
	defw data_AAB0+76h,data_AAB0+7Dh
	defw data_AAB0+84h

; ----------------------------------------------------------------------
; DATA data_AAB0: What the table above points to, and what place_first_turret in bank 2
;   reads. 1145 bytes up to where the filler starts.
data_AAB0:
	defb 39h,0ABh,51h,0ABh,69h,0ABh,81h,0ABh,99h,0ABh,0B4h,0ABh,0D5h,0ABh,0F0h,0ABh
	defb 05h,0ACh,1Dh,0ACh,35h,0ACh,4Dh,0ACh,65h,0ACh,7Dh,0ACh,95h,0ACh,0B0h,0ACh
	defb 0D1h,0ACh,0ECh,0ACh,01h,0ADh,19h,0ADh,31h,0ADh,49h,0ADh,61h,0ADh,79h,0ADh
	defb 91h,0ADh,0ACh,0ADh,0CDh,0ADh,0E8h,0ADh,0FDh,0ADh,15h,0AEh,2Dh,0AEh,45h,0AEh
	defb 5Dh,0AEh,75h,0AEh,8Dh,0AEh,0A8h,0AEh,0C9h,0AEh,0E4h,0AEh,0F9h,0AEh,11h,0AFh
	defb 04h,04h,08h,00h,0A2h,0A8h,00h,0A3h,5Eh,5Fh,0A4h,0A5h,60h,61h,0A6h,00h
	defb 0A1h,0A7h,00h,04h,04h,08h,00h,0AAh,0ACh,00h,0ADh,62h,63h,0AEh,0AFh,64h
	defb 65h,0B0h,00h,0A9h,0ABh,00h,02h,02h,00h,66h,67h,68h,69h,02h,02h,00h
	defb 6Ah,0B1h,6Bh,0B2h,01h,02h,00h,0B3h,0B4h,03h,07h,15h,4Dh,4Eh,00h,47h
	defb 48h,00h,4Dh,4Eh,00h,00h,51h,00h,00h,4Fh,50h,00h,4Fh,50h,00h,44h
	defb 00h,03h,07h,15h,00h,4Dh,4Eh,00h,4Fh,50h,4Dh,4Eh,00h,54h,55h,00h
	defb 47h,48h,00h,4Dh,4Eh,00h,00h,44h,00h,03h,07h,15h,00h,4Dh,4Eh,00h
	defb 4Dh,4Eh,00h,47h,48h,00h,5Ch,5Dh,4Dh,4Eh,00h,47h,48h,00h,00h,44h
	defb 00h,03h,07h,15h,00h,00h,45h,00h,44h,46h,47h,48h,00h,51h,00h,00h
	defb 44h,00h,00h,44h,00h,00h,44h,00h,00h,04h,06h,18h,00h,00h,45h,49h
	defb 00h,44h,46h,4Ah,54h,55h,00h,00h,4Fh,50h,00h,00h,44h,00h,00h,00h
	defb 44h,00h,00h,00h,06h,05h,1Eh,00h,00h,00h,4Bh,4Bh,00h,00h,5Ah,5Bh
	defb 4Ch,4Ch,49h,00h,44h,00h,00h,00h,4Ah,47h,48h,00h,00h,00h,00h,44h
	defb 00h,00h,00h,00h,00h,06h,04h,18h,00h,00h,52h,49h,4Bh,00h,00h,44h
	defb 53h,4Ah,4Ch,49h,4Fh,50h,00h,00h,00h,4Ah,44h,00h,00h,00h,00h,00h
	defb 06h,03h,12h,00h,49h,51h,44h,49h,00h,44h,4Ah,00h,00h,4Ah,44h,44h
	defb 00h,00h,00h,00h,00h,07h,03h,15h,00h,00h,45h,56h,49h,4Bh,00h,4Dh
	defb 4Eh,46h,57h,4Ah,4Ch,44h,4Fh,50h,00h,00h,00h,00h,00h,07h,03h,15h
	defb 00h,00h,4Bh,58h,00h,00h,00h,00h,44h,4Ch,59h,44h,45h,00h,4Fh,50h
	defb 00h,00h,00h,46h,44h,03h,07h,15h,00h,44h,00h,00h,4Fh,50h,00h,4Fh
	defb 50h,00h,51h,00h,4Dh,4Eh,00h,47h,48h,00h,4Dh,4Eh,00h,03h,07h,15h
	defb 00h,44h,00h,4Dh,4Eh,00h,47h,48h,00h,54h,55h,00h,4Dh,4Eh,00h,00h
	defb 4Fh,50h,00h,4Dh,4Eh,03h,07h,15h,00h,44h,00h,47h,48h,00h,4Dh,4Eh
	defb 00h,00h,5Ch,50h,00h,47h,48h,00h,4Dh,4Eh,00h,4Dh,4Eh,03h,07h,15h
	defb 44h,00h,00h,44h,00h,00h,44h,00h,00h,51h,00h,00h,47h,48h,00h,00h
	defb 44h,45h,00h,00h,46h,04h,06h,18h,44h,00h,00h,00h,44h,00h,00h,00h
	defb 4Fh,50h,00h,00h,54h,55h,00h,00h,00h,44h,45h,4Bh,00h,00h,46h,4Ch
	defb 06h,05h,1Eh,44h,00h,00h,00h,00h,00h,47h,48h,00h,00h,00h,00h,00h
	defb 44h,00h,00h,00h,4Bh,00h,5Ah,5Bh,49h,49h,4Ch,00h,00h,00h,4Ah,4Ah
	defb 00h,06h,04h,18h,44h,00h,00h,00h,00h,00h,4Fh,50h,00h,00h,00h,4Bh
	defb 00h,44h,52h,4Bh,49h,4Ch,00h,00h,53h,4Ch,4Ah,00h,06h,03h,12h,44h
	defb 00h,00h,00h,00h,00h,44h,4Bh,00h,00h,4Bh,44h,00h,4Ch,51h,44h,4Ch
	defb 00h,07h,03h,15h,4Fh,50h,00h,00h,00h,00h,00h,4Dh,4Eh,45h,58h,4Bh
	defb 49h,44h,00h,00h,46h,59h,4Ch,4Ah,00h,07h,03h,15h,4Fh,50h,00h,00h
	defb 00h,45h,44h,00h,44h,49h,56h,44h,46h,00h,00h,00h,4Ah,57h,00h,00h
	defb 00h,03h,07h,15h,00h,44h,00h,4Dh,4Eh,00h,4Dh,4Eh,00h,00h,51h,00h
	defb 00h,4Fh,50h,00h,47h,48h,00h,4Fh,50h,03h,07h,15h,00h,44h,00h,00h
	defb 4Fh,50h,00h,47h,48h,00h,54h,55h,00h,4Fh,50h,4Dh,4Eh,00h,4Fh,50h	; "OP.GH.TU.OPMN.OP"
	defb 00h,03h,07h,15h,00h,44h,00h,00h,47h,48h,00h,4Fh,50h,5Ah,5Bh,00h
	defb 47h,48h,00h,4Fh,50h,00h,4Fh,50h,00h,03h,07h,15h,00h,00h,44h,00h
	defb 00h,44h,00h,00h,44h,00h,00h,51h,00h,47h,48h,45h,44h,00h,46h,00h
	defb 00h,04h,06h,18h,00h,00h,00h,44h,00h,00h,00h,44h,00h,00h,4Dh,4Eh
	defb 00h,00h,54h,55h,4Bh,45h,44h,00h,4Ch,46h,00h,00h,06h,05h,1Eh,00h
	defb 00h,00h,00h,00h,44h,00h,00h,00h,00h,47h,48h,4Bh,00h,00h,00h,44h
	defb 00h,4Ch,49h,49h,5Ch,5Dh,00h,00h,4Ah,4Ah,00h,00h,00h,06h,04h,18h
	defb 00h,00h,00h,00h,00h,44h,4Bh,00h,00h,00h,4Dh,4Eh,4Ch,49h,4Bh,52h
	defb 44h,00h,00h,4Ah,4Ch,53h,00h,00h,06h,03h,12h,00h,00h,00h,00h,00h
	defb 44h,44h,4Bh,00h,00h,4Bh,44h,00h,4Ch,44h,51h,4Ch,00h,07h,03h,15h
	defb 00h,00h,00h,00h,00h,4Dh,4Eh,44h,49h,4Bh,58h,45h,4Fh,50h,00h,4Ah
	defb 4Ch,59h,46h,00h,00h,07h,03h,15h,44h,45h,00h,00h,00h,4Dh,4Eh,00h
	defb 46h,44h,56h,49h,44h,00h,00h,00h,00h,57h,4Ah,00h,00h,03h,07h,15h
	defb 00h,4Fh,50h,00h,47h,48h,00h,4Fh,50h,00h,51h,00h,4Dh,4Eh,00h,4Dh
	defb 4Eh,00h,00h,44h,00h,03h,07h,15h,4Fh,50h,00h,4Dh,4Eh,00h,00h,4Fh
	defb 50h,00h,54h,55h,00h,47h,48h,00h,4Fh,50h,00h,44h,00h,03h,07h,15h
	defb 4Fh,50h,00h,4Fh,50h,00h,47h,48h,00h,5Ah,5Bh,00h,00h,4Fh,50h,00h
	defb 47h,48h,00h,44h,00h,03h,07h,15h,45h,00h,00h,46h,44h,00h,00h,47h
	defb 48h,00h,00h,51h,00h,00h,44h,00h,00h,44h,00h,00h,44h,04h,06h,18h
	defb 49h,45h,00h,00h,4Ah,46h,44h,00h,00h,00h,54h,55h,00h,00h,4Dh,4Eh
	defb 00h,00h,00h,44h,00h,00h,00h,44h,06h,05h,1Eh,00h,4Bh,4Bh,00h,00h
	defb 00h,49h,4Ch,4Ch,5Ch,5Dh,00h,4Ah,00h,00h,00h,44h,00h,00h,00h,00h
	defb 00h,47h,48h,00h,00h,00h,00h,00h,44h,06h,04h,18h,00h,4Bh,49h,52h
	defb 00h,00h,49h,4Ch,4Ah,53h,44h,00h,4Ah,00h,00h,00h,4Dh,4Eh,00h,00h
	defb 00h,00h,00h,44h,06h,03h,12h,00h,49h,44h,51h,49h,00h,44h,4Ah,00h
	defb 00h,4Ah,44h,00h,00h,00h,00h,00h,44h,07h,03h,15h,00h,4Bh,49h,56h
	defb 45h,00h,00h,44h,4Ch,4Ah,57h,46h,4Fh,50h,00h,00h,00h,00h,00h,4Dh
	defb 4Eh,07h,03h,15h,00h,00h,00h,58h,4Bh,00h,00h,00h,45h,44h,59h,4Ch
	defb 44h,00h,44h,46h,00h,00h,00h,4Dh,4Eh

	end

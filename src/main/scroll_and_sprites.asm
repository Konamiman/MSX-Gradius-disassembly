; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - scroll_and_sprites.asm
; ============================================================================

	include "bios.inc"
	include "variables.inc"

	include "map_symbols.inc"
	include "scenery_symbols.inc"
	include "screens_symbols.inc"
	include "sound_symbols.inc"
	public blink_two_characters,check_if_sound,clear_rectangle,clear_screen,copy_rectangle,decompress
	public decompress_three_thirds,decompress_with_destination,dispatch_ship_end,dump_three_thirds,dump_to_vram,erase_characters
	public fill_three_thirds,get_word,L_49A0,load_explosion_graphics,next_submode,request_sound
	public run_sprites,scroll_map_one_column,set_vram_write,upload_screen,upload_sprites_rotating,write_characters
	extrn add_a_to_de,add_a_to_hl,advance_1B_script,advance_script,animate_shrapnel,build_mirror
	extrn cell_to_ram_address,dispatcher,erase_drawing,explosion_step_6,explosion_step_7,explosion_step_8
	extrn explosion_step_9,formations,four_by_four_drawing,load_entries,load_scoreboard,meter_table
	extrn move_shrapnel,paint_e800_objects,pick_border_colour,release_background_objects,release_enemies,release_shrapnel
	extrn remove_sprites_from_screen,set_border_colour,upload_shrapnel_to_buffer,write_laser

; (The last instruction of pause_and_frame.asm falls through into here.)

; ----------------------------------------------------------------------
; THE SCROLL
; The stage map is not read from VRAM: it lives in RAM, at MAP, and it
; is twenty-two rows of thirty-two cells. On each scroll step, L_469D
; SHIFTS IT ONE COLUMN TO THE LEFT with twenty-two `ldir`s of 0x1F bytes,
; and read_new_column puts the new column in on the right, which comes from the
; stage script and from the 4x4-character pieces of bank 11.
; ----------------------------------------------------------------------
take_scroll_steps:		; B scroll steps; on each one it maps banks 11 and 12 to read the script, and then four more routines
	push bc
	di
	ld a,00bh		; Banks 11 and 12: the pieces and the scripts
	ld (08000h),a
	ld (BANK_8000),a
	ei
	di
	ld a,00ch
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	call read_new_column	; With them in place the new column is read
	di
	ld a,002h		; And 2 and 3 are restored
	ld (08000h),a
	ld (BANK_8000),a
	ei
	di
	ld a,003h
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	call release_enemies
	call release_background_objects
	call advance_script
	call advance_1B_script
	ld hl,(MAP_COLUMN_PTR)	; Moves forward one cell
	inc hl
	ld (MAP_COLUMN_PTR),hl
	ld hl,ENTRY_X		; Eight points per step
	ld a,(hl)
	add a,008h
	ld (hl),a
	ld hl,(DISTANCE)	; And the distance covered, one unit
	inc hl
	ld (DISTANCE),hl
	pop bc
	djnz take_scroll_steps
	ld hl,(DISTANCE)	; On the way out the last step is given back: the loop overshoots by one
	dec hl
	ld (DISTANCE),hl
	ret
flag_not_due:		; SCROLL_AT_LIMIT to one: no new column comes in on this step
	ld a,001h
	ld (SCROLL_AT_LIMIT),a
	ret
scroll_map_one_column:		; If it is time to scroll, raises the distance and shifts the twenty-two rows at MAP one cell to the left
	xor a
	ld (NEW_COLUMN),a
	ld (SCROLL_AT_LIMIT),a
	ld de,(SCROLL_LIMIT)	; How far the stage's scroll goes
	ld hl,(DISTANCE)
	rst 20h			; DCOMPR: compares the distance with the limit
	jr nc,flag_not_due
	ld a,(SCROLL_MODE)	; Sets the speed: at one, standing still
	dec a
	ret z
	dec a			; At two, it shifts on every step
	jr z,L_468C
	ld de,SCROLL_BIT	; And otherwise, every other step, with the bit that rotates
	ld a,(de)
	rlca
	ld (de),a
	and 001h
	ret z
L_468C:
	inc hl			; The distance goes up
	ld (DISTANCE),hl
	ld a,001h		; NEW_COLUMN to one: there is a new column on this step
	ld (NEW_COLUMN),a
	ld hl,MAP+1		; To MAP: the whole map, one cell to the left
	ld de,MAP
	ld b,016h		; Twenty-two rows
L_469D:
	push bc
	ld bc,0001fh		; Thirty-one cells per row
	ldir
	pop bc
	inc hl			; And the leftover cell when jumping to the next row
	inc de
	djnz L_469D
	ld hl,MAP+MAP_WIDTH-1	; MAP_COLUMN_PTR points to the right-hand column, the one to be filled
	ld (MAP_COLUMN_PTR),hl
read_new_column:		; With the distance inside the range, takes from the stage script the piece that is due and leaves its address in PIECE_PTR
	ld hl,(DISTANCE)	; The distance covered...
	ld de,(MAP_RANGE_END)	; ...against the end of the range
	rst 20h
	ccf
	jr c,draw_star_column
	ld de,(MAP_RANGE_START)	; And against where it starts
	and a
	sbc hl,de
	jr c,draw_star_column
	push hl
	ld hl,script_table	; The script table at script_table, indexed by the stage
	ld a,(STAGE)
	call get_word
	pop hl
	ld a,l
	srl h			; The distance divided by two: each piece is four cells wide
	rra
	and 0feh
	ld l,a
	ld c,l
	ld b,h
	add hl,hl		; Times three and added: times six, which is what a row of the script takes up
	add hl,bc
	add hl,de
	ld (PIECE_PTR),hl	; Keeps where the piece is
	ld hl,(MAP_COLUMN_PTR)
	ld b,006h
insert_new_column:		; Copies into the right-hand column of the map the four cells due from the piece, jumping from row to row
	push bc
	push hl
	ld hl,(PIECE_PTR)	; The script hands out piece numbers
	ld a,(hl)
	inc hl
	ld (PIECE_PTR),hl
	ld l,a
	ld h,000h
	add hl,hl		; Times sixteen: each piece is four by four characters
	add hl,hl
	add hl,hl
	add hl,hl
	ld de,pieces_B		; Stages 5, 9, 10 and 12 use the other set of pieces, the one at pieces_B
	ld a,(STAGE)
	cp 005h
	jr z,L_470B
	cp 009h
	jr z,L_470B
	cp 00ah
	jr z,L_470B
	cp 00ch
	jr z,L_470B
	ld de,pieces_A
L_470B:
	add hl,de
	ex de,hl
	ld a,(DISTANCE)		; The two low bits of the distance: which of the four columns of the piece is due
	and 003h
	call add_a_to_de
	pop hl
	dec b
	ld bc,00020h		; 0x20: from one map row to the one below
	jr z,half_piece
	ld a,(de)
	ld (hl),a
	add hl,bc
	inc de			; And four bytes: the same column, one row further down the piece
	inc de
	inc de
	inc de
	ld a,(de)
	ld (hl),a
	add hl,bc
	inc de
	inc de
	inc de
	inc de
half_piece:		; The other two cells of the piece, when the column coming in is the second half
	ld a,(de)		; The third byte of the piece
	ld (hl),a
	add hl,bc		; Four bytes: the next row down in the piece
	inc de
	inc de
	inc de
	inc de
	ld a,(de)
	ld (hl),a
	add hl,bc		; And 0x20: the next row down in the map
	pop bc
	djnz insert_new_column
	ret

; ----------------------------------------------------------------------
; THE STARS COME FROM THE R REGISTER
; When the stage has no script to read, the column coming in is sky: a
; single character lit on the row the table at star_row says, and the rest
; at zero. Which of the two star drawings goes in is decided by `ld a,r`,
; the Z80's refresh register, which counts on its own with every
; instruction. It is the closest thing to chance in the cartridge, and it
; is only used so that the stars do not all twinkle the same.
; ----------------------------------------------------------------------
draw_star_column:		; Fills the incoming column with zeros, except for one cell: the star, on the row the table at star_row says
	ld a,(DISTANCE)		; The five low bits of the distance index the table
	and 01fh
	ld hl,star_row
	call add_a_to_hl
	ld c,(hl)		; C says which row the star falls on
	ld b,016h		; Twenty-two rows
	ld de,00020h
	ld hl,(MAP_COLUMN_PTR)
L_474C:
	xor a
	dec c
	jr nz,L_4756
	ld a,r			; The Z80's R register: the only thing that stands in for chance here
	and 001h
	add a,0f6h		; 0xF6 or 0xF7: the two star drawings
L_4756:
	ld (hl),a
	add hl,de
	djnz L_474C
	ret
blink_two_characters:		; Every two frames turns the patterns at 0x27B0 and 0x27B8 off or on, in the three thirds
	ld a,(FRAME_COUNT)	; Two bits of the frame counter: four steps
	and 006h
	ld hl,blink		; The mask table at blink
	ld e,a
	ld d,000h
	add hl,de
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld hl,027b0h		; The character at VRAM 0x27B0...
	call L_4774
	ld c,b
	ld hl,027b8h		; ...and the one at 0x27B8
L_4774:
	ld a,(SCROLL_BIT)	; The bit that rotates
	and c
	call WRTVRM
	ld de,00800h		; The three thirds, 0x800 apart
	add hl,de
	call WRTVRM
	add hl,de
	jp WRTVRM

; ----------------------------------------------------------------------
; DATA blink: Four words that 0x4760 indexes with (FRAME_COUNT AND 6).
blink:
	defw 00FFh,0FFFFh
	defw 0FF00h,0FFFFh

; ----------------------------------------------------------------------
; DATA star_row: Thirty-two bytes that 0x473D indexes with (DISTANCE AND 0x1F):
;   which of the twenty-two rows the star of the incoming column falls on. The
;   values go from 1 to 0x14, so it always falls inside.
star_row:
	defb 02h,0Fh,05h,13h,0Ah,01h,0Dh,06h,11h,08h,0Bh,02h,10h,07h,0Dh,05h,12h,0Ch,02h,12h,09h,0Eh,14h,11h,02h,05h,0Dh,0Ah,13h,06h,0Fh,09h
get_word:		; DE = the word at HL + 2*A. Called from 36 places.
	add a,a			; Times two: the table is made of words
	ld e,a
	ld d,000h
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	ret
run_sprites:		; Four passes: two routines from banks 1 and 3, the second group of objects and the sprite engine
	call paint_e800_objects
	call write_laser
	call build_second_group
	jp build_sprites
upload_sprites:		; Sends the 128 bytes at SPRITE_BUFFER out of the VDP data port with `outi`: 32 sprites of four bytes, in one go.
	ld hl,SPRITE_BUFFER
	ld b,080h
L_47C8:
	outi			; `outi` with B=0x80: the 128 bytes of the attribute table without going through the BIOS.
	jp nz,L_47C8
	ret

; ----------------------------------------------------------------------
; SPRITE PRIORITY, WHICH KEEPS ROTATING
; The MSX only draws four sprites per line, and the ones that drop out
; are always the last ones in the table. So that the one that disappears
; is not always the same, this routine does not upload the buffer in one
; go: it uploads it in THIRTY-TWO pieces of four bytes, starting each
; frame at a different place (SPRITE_ROTATION goes up by 0x1C and wraps at 0x7C)
; and stepping 0x0C at a time. That way each object lands in a different
; slot of the attribute table every frame, and the flicker is shared out
; among all of them.
; ----------------------------------------------------------------------
upload_sprites_rotating:		; Uploads the buffer to the attribute table starting each frame at a different place: that way the flicker is shared out
	ld hl,03b00h		; The sprite attribute table, at VRAM 0x3B00
	call set_vram_write
	exx
	ld a,(SHIP)		; At 0xFF it is uploaded as it is, without rotating
	inc a
	jr z,upload_sprites
	ld hl,SPRITE_ROTATION
	ld a,(hl)
	add a,01ch		; 0x1C more each frame, wrapping at 0x7C
	and 07ch
	ld (hl),a
	ld e,a
	ld d,020h		; Thirty-two entries of four bytes
L_47E7:
	ld a,e
	ld hl,SPRITE_BUFFER
	add a,l
	ld l,a
	ld b,004h
L_47EF:
	outi			; The four bytes of an entry, through the data port
	jp nz,L_47EF
	ld a,e
	add a,00ch		; And on to the entry 0x0C further on, wrapping around
	and 07ch
	ld e,a
	dec d
	jr nz,L_47E7
	ret
upload_screen:		; The 704 bytes of the map at MAP to the name table, with `outi` and without going through the BIOS
	ld hl,03800h		; The name table, at VRAM 0x3800
	call set_vram_write
	exx
	ld hl,MAP
	ld b,000h		; B at zero: 256 bytes in one go
L_480A:
	outi
	jp nz,L_480A
L_480F:
	outi
	jp nz,L_480F
	ld b,0c0h		; And the last 192: twenty-two rows of thirty-two
L_4816:
	outi
	jp nz,L_4816
	ret
build_second_group:		; The other ten objects, the ones at ENEMY_SHOTS, to the buffer at 0xECD8
	ld ix,ENEMY_SHOTS	; The second group of objects
	ld de,SPRITE_BUFFER+22*4
	ld b,00ah		; Ten objects
	jr walk_objects

; ----------------------------------------------------------------------
; THE SPRITE ENGINE: FROM THE OBJECTS AT 0xE300 TO THE ATTRIBUTE TABLE
; ----------------------------------------------------------------------
build_sprites:		; With banks 4/5/6 in place, walks twelve objects at OBJECTS (32 bytes each) and builds their sprite attribute in 0xECA8.
	di
	push hl
	ld hl,BANK_6000
	ld a,004h		; Banks 4/5/6: the sprite engine needs to read the shapes in bank 5.
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
	ld ix,OBJECTS		; The object table, and 0xECA8 the attribute buffer
	ld de,SPRITE_BUFFER+10*4
	ld b,00ch
walk_objects:		; For each live slot, sets its attribute entry; and if it is hidden, takes it off the screen
	push bc
	ld a,(ix+000h)		; With the first byte at zero, the slot is empty
	and a
	jr z,empty_slot
	cp 019h			; And 0x19 also counts as empty
	jr z,empty_slot
	ld a,(ix+00bh)		; Byte 11 says whether the object is hidden
	and a
	push af
	call z,set_attribute
	pop af
	call nz,hide_sprite
next_object:		; Moves on to the next object and, once the twelve are done, restores the usual layout
	exx
	ld de,00020h		; Thirty-two bytes per object
	add ix,de
	exx
	pop bc
	djnz walk_objects	; The twelve
	di			; Banks 1, 2 and 3 again
	push hl			; The usual layout: banks 1, 2 and 3
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
	ret
empty_slot:		; 0xE0 in the Y: the VDP draws nothing below that height
	ld a,0e0h		; 0xE0 in the Y and the other three fields untouched
	ld (de),a
	inc e
	inc e
	inc e
	inc e
	jr next_object
set_attribute:		; Copies to the buffer the object's Y, X, pattern number and colour (IX+4, IX+6, IX+0C, IX+0D).
	ld a,(ix+004h)		; Byte 4 of the object is the Y...
	ld (de),a
	inc e
	ld a,(ix+006h)		; ...6 the X...
	ld (de),a
	inc e
	ld a,(ix+00ch)		; ...12 the pattern number...
	ld (de),a
	inc e
	ld a,(ix+00dh)		; ...and 13 the colour
	ld (de),a
	inc e
	ret
hide_sprite:		; Puts 0xE0 in the Y, which is the height at which the VDP does not draw it, and drops the object if it goes off the bottom or the right.
	ld a,0e0h
	ld (de),a
	inc e
	inc e
	inc e
	inc e
	ld a,(ix+004h)		; Below Y 0xB8 and X 0xF8 it carries on; otherwise, it is not drawn with characters
	cp 0b8h
	ret nc
	ld a,(ix+006h)
	cp 0f8h
	ret nc
	exx
	ld l,(ix+01eh)		; Bytes 30 and 31 say which screen cell it falls on
	ld h,(ix+01fh)
	ld a,(ix+00bh)		; Byte 11: if it is one it is four characters, and if not, two
	dec a
	jr nz,two_characters
	ex de,hl
two_by_two:		; Takes the object's four characters from the table at 0x91D1 and writes them to the name table in two rows, 0x1E apart.
	ld a,(ix+00ch)		; The pattern number times four: four characters per drawing
	add a,a
	ld l,a
	ld h,000h
	add hl,hl
	ld bc,091d1h
	add hl,bc
	ldi			; The top two...
	ldi
	ld a,01eh		; ...and 0x1E further on, the bottom two, which is the next row
	add a,e
	ld e,a
	jr nc,L_48DA
	inc d
L_48DA:
	ldi
	ldi
	exx
	ret
two_characters:		; Objects that are not four characters are painted with two in a row, and byte 11 says which one they start at
	ld c,0a1h		; Byte 11 at two: characters 0xA1 and 0xA2
	dec a
	jr z,L_48F1
	ld c,0bfh		; At three: 0xBF and 0xC0
	dec a
	jr z,L_48F1
	ld c,058h		; At four: 0x58 and 0x59
	dec a
	jr z,L_48F1
	ld c,060h		; And otherwise, 0x60 and 0x61
L_48F1:
	ld (hl),c		; The second character goes right after the first
	inc hl
	inc c
	ld (hl),c
	exx
	ret
clear_rectangle:		; B cells wide by C high, to zero, clipping whatever goes off the right
	call clip_right
	ld e,b
L_48FB:
	push hl
	ld b,e
	xor a			; Zero: the empty cell
L_48FE:
	ld (hl),a
	inc hl
	djnz L_48FE
	pop hl
	ld a,020h		; 0x20: the row below
	call add_a_to_hl
	dec c
	jr nz,L_48FB
	ret
copy_rectangle:		; The same but copying from DE: B wide by C high, skipping in the source whatever was clipped
	push bc
	call clip_right
	pop af
	sub b			; What was clipped, to skip it in the source too
	exx
	ld c,a
	exx
L_4915:
	push hl
	push bc
copy_row:		; B bytes from DE to HL: one row of the rectangle
	ld a,(de)		; Byte by byte
	ld (hl),a
	inc hl
	inc de
	djnz copy_row
	pop bc
	pop hl
	ld a,020h		; 0x20: the map row below
	call add_a_to_hl
	exx
	ld a,c
	exx
	call add_a_to_de
	dec c
	jr nz,L_4915
	ret
clip_right:		; If the rectangle goes off the row, takes the leftover cells off B
	call cell_to_ram_address
	ld a,l
	and 01fh		; Which column it falls on
	add a,b
	sub 020h		; And how far past thirty-two it goes
	ret c
	neg			; B keeps what fits
	add a,b
	ld b,a
	ret
clear_screen:		; Calls remove_sprites_from_screen and fills the 768 bytes of the name table (VRAM 0x3800) with zeros using FILVRM.
	call remove_sprites_from_screen
	ld hl,03800h		; The 768 cells of the name table
	ld bc,00300h
	xor a
	jp FILVRM
set_vram_write:		; SETWRT, and the VDP data port is saved in C'.
	ex af,af'
	call SETWRT
	exx
	ld a,(00007h)		; 0x0007 holds this machine's VDP data port
	ld c,a
	exx
	ex af,af'
	ret

; ----------------------------------------------------------------------
; DATA dead_vram_read: Ten bytes that are `call SETRD / exx / ld a,(0x0006) /
;   ld c,a / exx / ret`: the twin of set_vram_write for READING from VRAM. Nobody
;   calls it.
set_vram_read:		; SETRD, and the read port is saved in C'. Nobody calls it: it is the dead twin of set_vram_write.
	defb 0CDh,50h,00h,0D9h,3Ah,06h,00h,4Fh,0D9h,0C9h
dump_to_vram:		; LDIRVM with DE and HL swapped.
	ex de,hl
	jp LDIRVM
dump_three_thirds:		; Three LDIRVMs in a row, adding 0x800 each time: the three thirds of the screen.
	exx
	ld b,003h		; Three thirds
L_4967:
	exx			; One third at a time
	push bc
	push de
	call dump_to_vram
	ld de,00800h		; 0x800: the next third
	add hl,de
	pop de
	pop bc
	exx
	djnz L_4967
	ret
fill_three_thirds:		; Three FILVRMs, one per third.
	ld d,003h		; Three thirds
L_4979:
	push bc
	push de
	call FILVRM
	ld de,00800h
	add hl,de
	pop de
	pop bc
	dec d
	jr nz,L_4979
	ret
decompress_three_thirds:		; decompress three times, once per third.
	ld b,003h		; Three thirds
next_third:		; 0x800 more: the third below
	push bc			; One third at a time
	push de
	call decompress
	ld de,00800h		; 0x800: the next third
	add hl,de
	pop de
	pop bc
	djnz next_third
	ret
write_characters:		; Reads the VRAM address from the stream and writes characters with WRTVRM: 0xFE = another address follows, 0xFF = end. It is the simple, uncompressed sibling of decompress.
	ld c,0ffh		; C to 0xFF: the `and c` below leaves the character as it is
L_499A:
	ex de,hl
	ld e,(hl)		; The first two bytes are the VRAM cell
	inc hl
	ld d,(hl)
	ex de,hl
	inc de
L_49A0:
	ld a,(de)
	inc de
	ld b,a
	inc b			; 0xFF ends the message
	ret z
	inc b			; And 0xFE continues it at another cell
	jr z,L_499A
	and c			; This is where C decides between writing the character or a zero
	call WRTVRM
	inc hl
	jr L_49A0
erase_characters:		; The same as write_characters but with C=0, so the `and c` leaves every character at zero: it is used to erase the text write_characters wrote.
	ld c,000h
	jr L_499A
decompress_with_destination:		; Enters the decompressor after first reading the VRAM address from the stream itself.
	ex de,hl		; The first two bytes of the stream are the destination in VRAM
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	inc de
decompress:		; The graphics decompressor. See tools/rle.py.
	call set_vram_write	; HL brings the VRAM address and DE the compressed stream.
L_49BC:
	ld a,(de)		; Command byte.
	and a
	ret z			; The 0x00 ends the block.
	inc de
	ld b,a
	and 07fh		; Bit 7 is split off, which is the one that says whether a literal or a repeat follows.
	cp b
	jr z,L_49D4		; Bit 7 at zero: repeat the next byte.
	and a
	jr z,decompress_with_destination	; The 0x80 command (bit 7 and nothing else) changes the VRAM address.
	ld b,a
L_49CA:
	ld a,(de)		; Literal copy: B bytes as they are, sending them out of the VDP port.
	inc de
	exx
	out (c),a
	exx
	djnz L_49CA
	jr L_49BC
L_49D4:
	ld a,(de)		; Repeat: the same byte B times.
	inc de
L_49D6:
	exx
	out (c),a
	exx
	djnz L_49D6
	jr L_49BC
check_if_sound:		; Checks bit 6 of GAME_FLAGS before falling into the sound trigger.
	di			; Bit 6 of GAME_FLAGS: with no game, nothing sounds
	push hl
	ld hl,GAME_FLAGS
	bit 6,(hl)
	jr z,L_4A1F
	jr build_sound_request
request_sound:		; Maps banks 7 and 8, writes sound A down in the queue, and restores the previous layout.
	di
	push hl
build_sound_request:		; Maps banks 7 and 8, which are the player's, leaves the request in the queue and restores the previous layout
	push de			; Everything is saved: this is called from anywhere
	push bc
	push af
	di
	ld a,007h		; Bank 7 at 0x8000 and bank 8 at 0xA000
	ld (08000h),a
	ld (BANK_8000),a
	ei
	di
	ld a,008h
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	di
	pop af
	push af
	call queue_sound	; With them in place the request is queued
	di
	ld a,002h		; And 2 and 3 restored
	ld (08000h),a
	ld (BANK_8000),a
	ei
	di
	ld a,003h
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	pop af
	pop bc
	pop de
L_4A1F:
	pop hl
	ei
	ret
queue_sound:		; Writes the request into the queue at 0xE012/0xE034 using the table at sound_table in bank 7.
	ld c,a
	and 07fh		; The seven low bits are the sound number; bit 7 is separate
	ld b,002h		; Two queue channels
	ld hl,SND_CARD_A+CARD_MODE
	cp 016h			; Below 0x16, the sound goes to the 0xE034 queue
	jr c,L_4A3C
	xor a
	ld (SND_MUTE),a
	ld a,c
	and 07fh
	cp 026h			; From 0x26 onwards, one more channel
	jr c,L_4A3F
	inc b
	jr L_4A3F
L_4A3C:
	ld l,034h
	dec b
L_4A3F:
	ld a,(hl)		; What is already queued
	and 07fh
	ld e,a
	ld a,c
	and 07fh
	cp e			; If what is already playing weighs more, the request is thrown away
	ret c
	add a,a
	ld de,sound_table	; The table at sound_table in bank 7, indexed by two
	call add_a_to_de
	dec hl
	dec hl
write_request:		; Leaves in the channel's card the marker, the sound number and the two words that come out of the table
	ld (hl),001h		; The new-request marker
	inc hl
	inc hl
	ld (hl),c
	inc hl
	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	ld a,(de)
	ld (hl),a
	ld a,006h		; Six more bytes: the other part of the card
	call add_a_to_hl
	xor a
	ld (hl),a
	ld a,007h		; And seven: the next channel's card
	call add_a_to_hl
	inc de
	djnz write_request
	ret
load_explosion_graphics:		; With banks 4/5/6 in place, the entries at trigger_records and the mirror at list_for_0x4348; then clears the 0x800 bytes of objects
	di			; Banks 4, 5 and 6, which are the graphics ones
	push hl			; The three graphics banks
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
	ld ix,trigger_records	; The entries at trigger_records
	call load_entries
	ld a,001h
	ld (MIRROR_KIND),a	; To one: the byte mirror
	ld ix,list_for_0x4348	; And the mirror at list_for_0x4348
	call build_mirror
	di			; 1, 2 and 3 restored
	push hl			; And 1, 2 and 3 restored
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
	ld hl,OBJECTS		; And the 0x800 bytes of objects, to zero
	ld de,OBJECTS+1
	ld bc,007ffh		; 0x800 bytes
	ld (hl),000h
	ldir
	ret
dispatch_ship_end:		; ENDING holds the explosion step and ENDING_STEP the submode: ten destinations in the table at ending_steps
	ld hl,(ENDING)		; The step, and ENDING_STEP the submode
	ld a,l
	and a
	ret z			; With the step at zero there is no explosion
	ld a,h
	call dispatcher

; ----------------------------------------------------------------------
; DATA ending_steps: Ten words right behind the `call dispatcher` at
;   0x4AC7.
ending_steps:
	defw explosion_step_0	; 0
	defw explosion_step_1	; 1
	defw explosion_step_2	; 2
	defw explosion_step_3	; 3
	defw explosion_step_4	; 4
	defw explosion_step_5	; 5
	defw explosion_step_6	; 6
	defw explosion_step_7	; 7
	defw explosion_step_8	; 8
	defw explosion_step_9	; 9
explosion_step_0:		; Raises the counter at ENDING_SHIP_Y by 0x40 and, past Y 0xF0, clears the screen and turns the sprites off
	ld hl,(ENDING_SHIP_Y)
	ld de,00040h		; 0x40 more each frame
	add hl,de
	ld (ENDING_SHIP_Y),hl
	ld hl,00800h		; 0x0800 in CONTROLLER_NEW
	ld (CONTROLLER_NEW),hl
	ld a,(SHIP_COLUMN)	; And until it goes past 0xF0, nothing is cleared
	cp 0f0h
	ret c
	call clear_screen
	call turn_off_sprites
next_submode:		; ENDING_STEP + 1: the next step of the explosion
	ld hl,ENDING_STEP
	inc (hl)
	ret
explosion_step_1:		; Waits for the channel to go quiet, loads the ending graphics from bank 10, turns the sprites off and puts up the 4x4 drawing
	ld a,(SND_CARD_A+CARD_MODE)	; Until the 0xE012 channel goes quiet, it does not go on
	and a
	ret nz
	call load_scoreboard
	di			; Bank 10 at 0xA000: the ending graphics
	ld a,00ah
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	ld hl,02418h		; Three thirds of patterns at VRAM 0x2418...
	ld de,graphics_patterns_2418
	call decompress_three_thirds
	ld hl,00418h		; ...and three of colours at 0x0418
	ld de,graphics_colours_0418
	call decompress_three_thirds
	ld hl,01800h		; And the sprite patterns, at 0x1800
	ld de,graphics_sprites_1800
	call decompress
	di			; Bank 3 restored
	ld a,003h
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	call turn_off_sprites
	ld de,four_by_four_drawing	; The four-by-four drawing at four_by_four_drawing
	call write_characters
	xor a
	ld (ENDING_TIMER),a
	ld hl,000c0h		; 0x00C0 in SHRAPNEL_LEFT: the long count
	ld (SHRAPNEL_LEFT),hl
	ld a,003h
	ld (SHRAPNEL_DELAY),a
	ld a,038h		; Sound 0x38
	call check_if_sound
	jr next_submode
turn_off_sprites:		; Sets the 128 bytes at SPRITE_BUFFER to 0xE0, which is the Y at which a sprite cannot be seen.
	ld hl,SPRITE_BUFFER
	ld b,080h		; The 128 bytes of the attribute table
L_4B5A:
	ld (hl),0e0h
	inc hl
	djnz L_4B5A
	ret
explosion_step_2:		; Moves the objects until 0xE1D5 reaches zero, and then starts the drawing blinking
	call release_shrapnel
	call move_shrapnel
	call animate_shrapnel
	call upload_shrapnel_to_buffer
	ld a,(SHRAPNEL_LEFT)	; Goes down elsewhere; until it reaches zero, it does not go on
	or a
	ret nz
	ld a,010h		; 0x10 frames per step of the drawing
	ld (ENDING_TIMER),a
	xor a
	ld (ENDING_DRAWING),a
	ld a,03bh		; Sound 0x3B
	call check_if_sound
	jp next_submode
explosion_step_3:		; Every 0x10 frames swaps the 4x4 drawing for the next one at formations; at the third, erases it and waits 0x40 frames
	call move_shrapnel
	call animate_shrapnel
	call upload_shrapnel_to_buffer
	ld hl,ENDING_TIMER	; Counts the frames of each drawing
	dec (hl)
	jr nz,L_4B9C
	ld (hl),010h
	ld hl,ENDING_DRAWING	; Says which drawing it is on
	inc (hl)
	ld a,(hl)
	cp 003h			; Three drawings and it is over
	jr z,L_4BC1
L_4B9C:
	ld a,(ENDING_DRAWING)
	ld de,formations	; The strip at formations, in bank 1
	add a,a			; Times sixteen: four by four characters
	add a,a
	add a,a
	add a,a
	call add_a_to_de
	ld c,004h
	ld hl,038aeh		; Row 5, column 14
L_4BAE:
	ld b,004h
L_4BB0:
	ld a,(de)
	call WRTVRM
	inc de
	inc hl
	djnz L_4BB0
	ld a,01ch		; 0x1C: the row below, minus what has already been walked
	call add_a_to_hl
	dec c
	jr nz,L_4BAE
	ret
L_4BC1:
	ld de,erase_drawing	; And the erasing
	call write_characters
	xor a
	ld (ENDING_DRAWING),a
	ld a,040h		; 0x40 frames of waiting
	ld (ENDING_TIMER),a
	ld a,044h		; Sound 0x44
	call check_if_sound
	jp next_submode
explosion_step_4:		; Lights up the six cells of the power-up meter one by one, each faster than the one before
	call move_shrapnel
	call animate_shrapnel
	call upload_shrapnel_to_buffer
	ld hl,ENDING_TIMER	; Counts the frames of this cell
	dec (hl)
	jr nz,L_4BFA
	ld hl,ENDING_DRAWING	; Says which cell it is on
	inc (hl)
	ld a,(hl)
	cp 006h			; Six cells and it is over
	jr z,finish_meter
	ld de,speeds_4C11-1	; 0x4C10 is the speed table, and its first byte falls on top of the code.
	call add_a_to_de
	ld a,(de)		; Each cell lasts less: 0x28, 0x28, 0x10, 0x0C, 0x08 and 0x04 frames
	ld (ENDING_TIMER),a
L_4BFA:
	ld a,(ENDING_DRAWING)
draw_meter:		; Takes from ENDING_DRAWING the lit cell of the power-up meter and writes its drawing with write_characters.
	ld hl,meter_table	; ENDING_DRAWING says which cell of the meter is lit.
	call get_word
	jp write_characters	; And it is drawn: write_characters writes characters, it does not execute anything.
finish_meter:		; Turns the sprites off and leaves 0x20 frames for the next step
	call turn_off_sprites
	ld a,020h
	ld (ENDING_TIMER),a
	jp next_submode

; ----------------------------------------------------------------------
; DATA speeds (part): Six bytes that 0x4BF0 indexes with add_a_to_de and stores in
;   ENDING_TIMER: 0x28, 0x28, 0x10, 0x0C, 0x08, 0x04.
speeds_4C11:
	defb 28h,10h,0Ch,08h,04h
explosion_step_5:		; Waits the frames in ENDING_TIMER and then requests screen piece 0
	call pick_border_colour
	ld hl,ENDING_TIMER
	dec (hl)
	ret nz
	ld b,000h		; Black border
	call set_border_colour
	ld a,028h		; And another 0x28 frames
	ld (ENDING_TIMER),a
	jp next_submode

	end

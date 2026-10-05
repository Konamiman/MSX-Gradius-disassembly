; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - vdp_setup.asm
; ============================================================================

	include "bios.inc"
	include "variables.inc"

	include "scenery_symbols.inc"
	include "screens_symbols.inc"
	public intro,just_pressed,load_scoreboard,load_scoreboard_two_thirds,load_stage_font,messages
	public program_vdp,raise_logo,read_controller,read_controller_no_save,set_border_colour,start_logo_curtain
	public write_title_panel
	extrn add_a_to_de,clear_screen,decompress_three_thirds,dump_three_thirds,dump_to_vram,fill_three_thirds
	extrn jump_to_intro,L_405A,set_vram_write

; (The last instruction of cheats.asm falls through into here.)

; ----------------------------------------------------------------------
; THE CARTRIDGE TURNS THE VRAM MAP UPSIDE DOWN
; The eight bytes at vdp_registers are 0x02, 0xE2, 0x0E, 0x7F, 0x07, 0x76, 0x03
; and 0xE4, and they do not leave VRAM where the BIOS leaves it. Register 4
; is 0x07, so the PATTERNS live at 0x2000; register 3 is 0x7F, so the
; COLOURS live at 0x0000 (exactly the reverse of normal); register 2 is
; 0x0E, which puts the name table at 0x3800; register 5 is 0x76, which
; puts the sprite attributes at 0x3B00, right behind the names; and
; register 6 is 0x03, which puts the sprite patterns at 0x1800. Anyone
; who reads the addresses in this source expecting the BIOS layout will
; get every one of them wrong.
; ----------------------------------------------------------------------
program_vdp:		; The eight values at vdp_registers to registers 0 to 7, with WRTVDP
	ld hl,vdp_registers
	ld d,008h		; Eight registers
	ld c,000h
L_5750:
	ld b,(hl)
	call WRTVDP
	inc hl
	inc c
	dec d
	jr nz,L_5750
	ret

; ----------------------------------------------------------------------
; DATA vdp_registers: The eight values with which program_vdp programs VDP
;   registers 0 to 7, one after the other, calling WRTVDP (0x0047) with B =
;   the value and C = the register number. From them follow: patterns at
;   0x2000, colours at 0x0000, names at 0x3800, sprite attributes at 0x3B00
;   and sprite patterns at 0x1800.
vdp_registers:
	defb 02h,0E2h,0Eh,7Fh,07h,76h,03h,0E4h
set_border_colour:		; Writes B to VDP register 7: the border and background colour
	ld c,007h
	jp L_405A
read_controller:		; Combines joystick and keyboard into CONTROLLER and leaves in CONTROLLER_NEW what has just been pressed
	call merge_joystick_and_keyboard
	ld hl,CONTROLLER
just_pressed:		; Saves the current state and, with an xor and an and, leaves in the next byte only what has just gone down
	ld c,(hl)		; What has changed and is set: what was just pressed
	ld (hl),a
	xor c
	and (hl)
	dec hl
	ld (hl),a
	ret
read_controller_no_save:		; The same but without recording it: used from the states' return point
	ld e,08fh
	call read_joystick
	and 03fh		; The six low bits: four arrows and two fire buttons
	jr L_5784
merge_joystick_and_keyboard:		; Reads the joystick on port 1 through the PSG and adds the keys of rows 4 and 8, shifted to the same bits
	ld e,08fh
	call read_joystick
	and 03fh
L_5784:
	push af
	ld a,004h
	call SNSMAT		; SNSMAT of row 4
	cpl
	and 00ch		; Its bits 2 and 3
	ld e,a
	jr z,merge_row_eight
	ld e,020h
merge_row_eight:		; Takes the arrows and the space bar from keyboard row 8 and shifts them to the joystick's bits
	ld a,008h		; SNSMAT of row 8
	call SNSMAT		; And row 8, the one with the arrows and the space bar
	cpl
	rrca			; Shifted twice: the bits land where the joystick's do
	rrca
	ld b,a
	and 004h		; The space bar bit
	or e
	ld c,a
	ld a,b
	rrca
	rrca
	ld b,a
	and 018h		; The two middle arrows
	or c
	ld c,a
	ld a,b
	rrca
	and 003h		; And the other two
	or c
	pop bc
	or b
	ret
read_joystick:		; PSG register 15 selects the port and 14 reads it; it arrives inverted, hence the cpl
	ld a,00fh
	call WRTPSG		; Register 15 selects the port
	ld a,00eh
	di
	call RDPSG		; And 14 brings the arrows and the fire buttons
	ei
	cpl			; A cpl: in the PSG a pressed button is a zero
	ret

; ----------------------------------------------------------------------
; DATA messages: The screen texts, with THEIR OWN CHARACTER CODES: 0x00 is the
;   space, 0x10 to 0x19 are the digits 0 to 9 and 0x21 to 0x3A the letters
;   (that is, ASCII minus 0x20). They are read with two different routines,
;   and both start by taking the VRAM address from the stream itself: write_characters
;   writes character by character (0xFE = another address follows, 0xFF = end)
;   and decompress_with_destination decompresses them with the decompress format. That is where
;   "software", "konami", "1986", "play select", "1 player", "2 players",
;   "player 1", "player 2", "game over" and "continue" come from. Each message
;   starts where its caller asks for it: 0x57BD (0x52E2, compressed), 0x57CE
;   (write_captions), 0x57E1 (0x563B), 0x57E6 (0x5641), 0x57EB (0x5BCA), 0x5808
;   (0x538A), 0x5812 (0x538F), 0x581D (L_5BF1), 0x5820 (0x53B8 and 0x554B),
;   0x582B (0x5552) and 0x5836 (0x54E0).
messages:
	defb 4Ah,39h,0Ch,5Ah,80h,6Ch,39h,88h,33h,2Fh,26h,34h,37h,21h,32h,25h
	defb 00h,0F3h,3Ah,0Eh,0Fh,0FEh,0E2h,3Ah,0Bh,0FEh,0F0h,3Ah,01h,01h,0FEh,0FCh
	defb 3Ah,01h,01h,0FFh,0E7h,3Ah,02h,12h,0FFh,0E7h,3Ah,03h,12h,0FFh,4Ah,39h
	defb 1Ah,2Bh,2Fh,2Eh,21h,2Dh,29h,00h,11h,19h,18h,16h,0FEh,0CBh,39h,30h
	defb 2Ch,21h,39h,00h,33h,25h,2Ch,25h,23h,34h,0FEh,2Dh,3Ah,11h,30h,2Ch
	defb 21h,39h,25h,32h,0FFh,6Dh,3Ah,12h,30h,2Ch,21h,39h,25h,32h,33h,0FFh
	defb 1Bh,1Ch,0FFh,0Ch,39h,30h,2Ch,21h,39h,25h,32h,00h,11h,0FFh,0Ch,39h
	defb 30h,2Ch,21h,39h,25h,32h,00h,12h,0FFh,4Bh,39h,27h,21h,2Dh,25h,00h
	defb 00h,2Fh,36h,25h,32h,0FEh,8Bh,39h,23h,2Fh,2Eh,34h,29h,2Eh,35h,25h
	defb 00h,26h,15h,0FFh
load_scoreboard:		; Dumps into VRAM 0x2080 and 0x2100 the patterns at patterns_2080 and patterns_2100, across the three thirds.
	ld de,patterns_2080	; The 104 bytes at patterns_2080: the digits and letters of the score
	ld hl,02080h
	ld bc,00068h
	call dump_three_thirds
	ld de,patterns_2100	; And the 216 at patterns_2100, which are the rest of the font
	ld hl,02100h
	ld bc,000d8h
	call dump_three_thirds
	ld a,0f0h		; 0xF0 in 0x158 colour cells: white on transparent
	ld hl,00080h
	ld bc,00158h
	jp fill_three_thirds
load_scoreboard_two_thirds:		; The same as load_scoreboard but only in the first and second thirds, and this time one at a time
	ld de,patterns_2080
	ld hl,02080h
	ld bc,00068h
	call dump_to_vram
	ld de,patterns_2100
	ld hl,02100h
	ld bc,000d8h
	call dump_to_vram
	ld a,0f0h
	ld hl,00080h
	ld bc,00158h
	call FILVRM
	ld de,patterns_2080	; And again in the second third, at 0x2880
	ld hl,02880h
	ld bc,00068h
	call dump_to_vram
	ld de,patterns_2100
	ld hl,02900h
	ld bc,000d8h
	call dump_to_vram
	ld a,0f0h
	ld hl,00880h
	ld bc,00158h
	jp FILVRM
load_stage_font:		; Sets 0x90 colour cells of the third third to white and uploads there the digits and the nine characters at drawing_order
	ld hl,01008h		; 0x50 colour cells to white...
	ld bc,00050h
	ld a,0f0h
	call FILVRM
	ld hl,01068h		; ...and 0x40 more
	ld bc,00040h
	ld a,0f0h
	call FILVRM
	ld de,patterns_2080	; The digits, at VRAM 0x3008
	ld hl,03008h
	ld bc,00050h
	call dump_to_vram
	ld hl,03068h		; And from here down, the loose characters in the list at drawing_order
	call set_vram_write
	exx
	ld hl,drawing_order
upload_loose_characters:		; For each number in the list, its eight bytes from patterns_2100; 0x00 ends it
	ld a,(hl)
	inc hl
	and a			; The 0x00 ends the list
	ret z
	add a,a			; Times eight: eight bytes per character
	add a,a
	add a,a
	ld de,patterns_2100
	call add_a_to_de
	ld b,008h		; Eight bytes through the data port
L_58F5:
	ld a,(de)
	inc de
	out (c),a
	djnz L_58F5
	jr upload_loose_characters

; ----------------------------------------------------------------------
; DATA drawing_order: Nine bytes that 0x58E3 walks after setting VRAM to
;   0x3068.
drawing_order:
	defb 07h,08h,09h,0Dh,0Fh,10h,12h,16h,00h

; ----------------------------------------------------------------------
; DATA patterns_2080: One hundred and four raw bytes that 0x585A passes to
;   dump_three_thirds with HL=0x2080: they are copied to the three thirds.
patterns_2080:
	defb 00h,1Ch,22h,63h,63h,63h,22h,1Ch
	defb 00h,18h,38h,18h,18h,18h,18h,7Eh
	defb 00h,3Eh,63h,03h,0Eh,3Ch,70h,7Fh
	defb 00h,3Eh,63h,03h,0Eh,03h,63h,3Eh
	defb 00h,0Eh,1Eh,36h,66h,66h,7Fh,06h
	defb 00h,7Fh,60h,7Eh,63h,03h,63h,3Eh
	defb 00h,3Eh,63h,60h,7Eh,63h,63h,3Eh
	defb 00h,7Fh,63h,06h,0Ch,18h,18h,18h
	defb 00h,3Eh,63h,63h,3Eh,63h,63h,3Eh	; ".>cc>cc>"
	defb 00h,3Eh,63h,63h,3Fh,03h,63h,3Eh
	defb 3Ch,42h,99h,0A1h,0A1h,99h,42h,3Ch
	defb 0C0h,60h,78h,7Eh,0BFh,0BFh,7Fh,0F0h
	defb 00h,00h,00h,00h,0E0h,0FEh,80h,00h

; ----------------------------------------------------------------------
; DATA patterns_2100: Two hundred and seventeen raw bytes that 0x5866 passes
;   to dump_three_thirds with HL=0x2100.
patterns_2100:
	defb 00h,00h,00h,00h,7Eh,00h,00h,00h
	defb 00h,1Ch,36h,63h,63h,7Fh,63h,63h
	defb 00h,7Eh,63h,63h,7Eh,63h,63h,7Eh	; ".~cc~cc~"
	defb 00h,3Eh,63h,60h,60h,60h,63h,3Eh
	defb 00h,7Ch,66h,63h,63h,63h,66h,7Ch	; ".|fcccf|"
	defb 00h,7Fh,60h,60h,7Eh,60h,60h,7Fh
	defb 00h,7Fh,60h,60h,7Eh,60h,60h,60h
	defb 00h,3Eh,63h,60h,67h,63h,63h,3Fh	; ".>c`gcc?"
	defb 00h,63h,63h,63h,7Fh,63h,63h,63h	; ".ccc.ccc"
	defb 00h,3Ch,18h,18h,18h,18h,18h,3Ch
	defb 00h,1Fh,06h,06h,06h,06h,66h,3Ch
	defb 00h,63h,66h,6Ch,78h,7Ch,6Eh,67h	; ".cflx|ng"
	defb 00h,60h,60h,60h,60h,60h,60h,7Fh
	defb 00h,63h,77h,7Fh,7Fh,6Bh,63h,63h
	defb 00h,63h,73h,7Bh,7Fh,6Fh,67h,63h	; ".cs{.ogc"
	defb 00h,3Eh,63h,63h,63h,63h,63h,3Eh	; ".>ccccc>"
	defb 00h,7Eh,63h,63h,63h,7Eh,60h,60h
	defb 00h,3Eh,63h,63h,63h,6Fh,66h,3Dh	; ".>cccof="
	defb 00h,7Eh,63h,63h,62h,7Ch,66h,63h	; ".~ccb|fc"
	defb 00h,3Eh,63h,60h,3Eh,03h,63h,3Eh
	defb 00h,7Eh,18h,18h,18h,18h,18h,18h
	defb 00h,63h,63h,63h,63h,63h,63h,3Eh	; ".cccccc>"
	defb 00h,63h,63h,63h,63h,36h,1Ch,08h
	defb 00h,63h,63h,6Bh,6Bh,7Fh,77h,22h	; ".cckk.w""
	defb 00h,63h,76h,3Ch,1Ch,1Eh,37h,63h
	defb 00h,66h,66h,7Eh,3Ch,18h,18h,18h
	defb 00h,7Fh,07h,0Eh,1Ch,38h,70h,7Fh
start_logo_curtain:		; 0x0E steps in LOGO_ROWS and the cursor at row 21, column 10: that is where the logo starts rising from
	ld a,00eh
	ld (LOGO_ROWS),a	; Fourteen rows
	ld hl,03aaah		; Row 21, column 10
	ld (LOGO_CURSOR),hl
	jp jump_to_intro
intro:		; Decompresses the logo at stream_6200 into the three thirds of VRAM 0x6200 and sets its 0xD8 colours to white
	ld de,stream_6200
	ld hl,graphics_chain_6000+200h
	call decompress_three_thirds
	ld hl,00200h
	ld bc,000d8h
	ld a,0f0h		; 0xF0: white on transparent
	jp fill_three_thirds
raise_logo:		; One row higher per call: paints the logo's three strips of characters and erases the one below
	ld hl,(LOGO_CURSOR)
	ld de,0ffe0h		; The cursor goes up 0x20 cells: one row
	add hl,de
	ld (LOGO_CURSOR),hl
	ld a,040h		; Three characters at the top, twelve in the middle and twelve at the bottom
	ld b,003h
	call character_strip
	ld bc,00b0ch
	call character_strip
	ld b,c
	call character_strip
	xor a
	call FILVRM		; And zeros underneath, which erase what the previous pass left
	ld hl,LOGO_ROWS		; Counts the fourteen rows
	dec (hl)
	ret
character_strip:		; B consecutive characters starting at A, and then down one row
	push hl
L_5A8D:
	call WRTVRM
	inc hl
	inc a			; The character code goes up with the column
	djnz L_5A8D
	pop de
	ld hl,00020h		; 0x20: the row below, for the next call
	add hl,de
	ret

; ----------------------------------------------------------------------
; DATA stream_6200: Compressed stream that intro (the intro) passes to decompress_three_thirds
;   with HL=0x6200.
stream_6200:
	defb 0Fh,00h,01h,01h,06h,00h,82h,0FFh,0FEh,08h,0Fh,84h,0C3h,0C7h,0CFh,0DFh
	defb 03h,0FFh,89h,0FEh,0FCh,0F8h,0F0h,0E0h,0C0h,80h,07h,07h,05h,00h,83h,03h
	defb 0CFh,0DFh,05h,00h,83h,0E1h,0F9h,7Dh,05h,00h,83h,0EFh,0FFh,0F7h,05h,00h
	defb 83h,07h,8Fh,9Eh,05h,00h,83h,0F0h,0F8h,78h,05h,00h,83h,0F7h,0FFh,0FBh
	defb 05h,00h,8Bh,8Fh,0DFh,0F7h,0Ch,1Eh,1Eh,0Ch,00h,1Eh,9Eh,9Eh,08h,0Fh
	defb 90h,0FFh,0FFh,0DFh,0CFh,0C7h,0C3h,0C1h,0C0h,07h,87h,0C7h,0EFh,0FFh,0FFh,0FFh
	defb 0FCh,04h,0DEh,84h,9Eh,9Fh,0Fh,03h,05h,3Dh,83h,7Dh,0F9h,0E1h,08h,0E3h
	defb 90h,0DCh,0C0h,0C7h,0DEh,0DCh,0DEh,0CFh,0C3h,3Ch,7Ch,0FCh,3Ch,3Ch,7Ch,0FCh
	defb 0DEh,08h,0F1h,08h,0E3h,08h,0DEh,88h,38h,44h,0BAh,0AAh,0B2h,0AAh,44h,38h
	defb 03h,00h,01h,0FFh,04h,00h,00h
build_title_screen:		; With banks 9 and 10 in place, black border, clean screen, the font and the two blocks of the title drawing
	di			; Banks 9 and 10: the intro ones
	ld a,009h
	ld (08000h),a
	ld (BANK_8000),a
	ei
	di
	ld a,00ah
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	ld b,0e0h		; 0xE0 in register 7: black border
	call set_border_colour
	call clear_screen
	call load_scoreboard
	ld de,graphics_2468	; The title patterns, at VRAM 0x2468...
	ld hl,02468h
	call decompress_three_thirds
	ld de,graphics_0468	; ...and its colours, at 0x0468
	ld hl,00468h
	call decompress_three_thirds
	di			; 2 and 3 restored
	ld a,002h		; 2 and 3 restored
	ld (08000h),a
	ld (BANK_8000),a
	ei
	di
	ld a,003h
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	ret
write_title_panel:		; Builds the screen and writes on top of it the 28x5 panel that matches the machine's country
	call build_title_screen
	di
	ld a,009h
	ld (08000h),a
	ld (BANK_8000),a
	ei
	di
	ld a,00ah
	ld (0a000h),a
	ld (BANK_A000),a
	ei

; (Falls through into title_screen.asm, which the link places right after.)

	end

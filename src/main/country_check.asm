; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - country_check.asm
; ============================================================================

	include "variables.inc"

	public explosion_step_6,explosion_step_7,explosion_step_8,explosion_step_9
	extrn add_to_score,check_if_sound,clear_screen,get_word,load_scoreboard,next_submode
	extrn start_slow_message,tables_of_4C4B,write_one_letter

; ----------------------------------------------------------------------
; THE CARTRIDGE CHECKS WHICH COUNTRY THE MACHINE IS FROM
; At the end of a whole loop a message is written, and which one comes out
; depends on which loop it is: GOOD, NICE, FINE and GREAT for the first
; four. On the fifth, the cartridge reads 0x002B of the BIOS (the low
; nibble gives the machine's character set, and at zero it is Japanese)
; and splits: on a Japanese machine YOROKONDE ITADAKEMASHITAKA comes out,
; and on any other, CONGRATULATIONS. Both messages are in the ROM, one
; next to the other.
; ----------------------------------------------------------------------
explosion_step_6:		; Clears the screen, raises the loop number in ENDING_INDEX wrapping at five, and writes the message that is due
	call clear_screen
	call load_scoreboard
	ld hl,ENDING_INDEX	; The loop: five and back to zero
	ld c,(hl)
	ld a,c
	inc a
	cp 005h
	jr c,L_4C3C
	xor a
L_4C3C:
	ld (hl),a
	ld a,c
	cp 004h			; Only on the fifth loop is the machine checked
	jr nz,L_4C50
	ld a,(0002bh)		; The low nibble of 0x002B: the character set. At zero, Japanese
	and 00fh
	ld a,004h
	jr z,L_4C50
	ld hl,tables_of_4C4B+44h	; On any other machine, CONGRATULATIONS
	jr L_4C57
L_4C50:
	ld hl,tables_of_4C4B	; And otherwise, the message for the loop: GOOD, NICE, FINE, GREAT or the Japanese one
	call get_word
	ex de,hl
L_4C57:
	call start_slow_message
	ld a,0a9h		; Sound 0xA9
	call check_if_sound
	jp next_submode
explosion_step_7:		; When the message is done, leaves 0x6001 in SND_MUTE and writes the one at 0x5040
	call write_one_letter
	ret nz
	ld hl,06001h		; 0x6001 in SND_MUTE and 0xE045
	ld (SND_MUTE),hl
	xor a
	ld (SND_MUTE_STEP),a	; To zero
	ld hl,tables_of_4C4B+56h	; And the message at 0x5040
	call start_slow_message
	jp next_submode
explosion_step_8:		; When it is done, gives away 500 points
	call write_one_letter
	ret nz
	ld de,00500h		; 0x0500 in BCD; the message at 0x5040 announces it as BONUS 50000 POINTS
	call add_to_score
	jp next_submode
explosion_step_9:		; Waits for the channel to go quiet, clears the screen and leaves both scripts pointing to 0x504A
	ld a,(SND_CARD_A+CARD_MODE)	; Until 0xE012 goes quiet, it does not go on
	and a
	ret nz
	call clear_screen
	ld a,001h
	ld (BOSS_DONE),a	; To one
	ld de,tables_of_4C4B+60h	; 0x504A: the script both lists start with
	ld a,e
	ld (SHIP_ROW),a
	ld a,d
	ld (SHIP_COLUMN),a
	ld hl,OPTIONS+4		; The two pointer tables, the first one...
	call point_all_slots
	ld hl,OPTIONS+OPTION_SIZE+4	; ...and the second
	call point_all_slots
	ld hl,OBJECTS		; And the 0x180 bytes of objects, to zero
	ld de,OBJECTS+1
	ld bc,0017fh
	ld (hl),000h
	ldir
	ret
point_all_slots:		; Leaves the same pointer in the first slot and in the eight behind it
	ld (hl),e
	inc l
	inc l
	ld (hl),d
	ld bc,0000ah		; Ten bytes: the next slot
	add hl,bc
	ld b,008h		; Eight more slots, now two bytes apart
L_4CC2:
	ld (hl),e		; The eight two-byte slots
	inc l
	ld (hl),d
	inc l
	djnz L_4CC2
	ret

	end

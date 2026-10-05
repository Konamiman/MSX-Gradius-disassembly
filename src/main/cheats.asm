; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - cheats.asm
; ============================================================================

	include "bios.inc"
	include "variables.inc"

	include "scenery_symbols.inc"
	include "screens_symbols.inc"
	public add_to_score,award_ship,cell_to_ram_address,check_typed_keys,draw_power_up_meter,draw_scores
	public remove_sprites_from_screen,start_machine,state_machine,write_captions
	extrn add_a_to_de,add_a_to_hl,animate_three_characters,blink_selection,build_high_score_screen,cheat_double
	extrn cheat_down,cheat_everything,cheat_laser,cheat_missile,cheat_option,cheat_shield
	extrn check_if_sound,check_pause_key,clear_screen,clear_typing_state,decompress,decompress_with_destination
	extrn dispatcher,erase_characters,flag_if_two_players,get_word,just_pressed,L_5BDD
	extrn load_scoreboard,load_scoreboard_two_thirds,load_stage_font,messages,program_vdp,raise_logo
	extrn read_controller_no_save,request_sound,run_demo,set_up_due_stage,set_vram_write,start_demo
	extrn start_logo_curtain,upload_sprites_rotating,write_characters,write_title_panel

; ----------------------------------------------------------------------
; THE CHEATS TYPED ON THE KEYBOARD, WHILE PAUSED
; This is NOT read while playing: L_4518 only calls here when bit 0 of
; PAUSE_COUNT is set, that is, with the game PAUSED. You pause with the GRAPH
; key (row 6, bit 5, at 0x44F6), type, and on unpausing the game carries
; on. On entering pause, clear_typing_state erases whatever was typed before.
; Each new key is stored in TYPED_KEYS, up to eight, and on pressing RETURN
; what was typed is compared against the words at texts. What is in ROM:
; HYPER    only the first time (HYPER_USED), and jumps to cheat_everything:
; EVERYTHING at once
; LASER    -> cheat_laser      MISSILE -> cheat_missile
; SHIELD   -> cheat_shield      DOUBLE  -> cheat_double
; OPTION   -> cheat_option      DOWN    -> cheat_down, which takes away
; BAKA and AHO (fool and idiot in Japanese) give NOTHING: they fall
; into punish_insult, which zeroes the lives, the flag and the two joystick
; flags.
; And on top of that each stage has ITS own woman's name (MOMOKO, CHIE,
; AKEMI, SYUKO, CHIAKI, NORIKO, SATOE, YASUKO, KINUYO, HISAE, MIYUKI,
; YOHKO), which the table at texts_per_stage hands out by stage: getting right
; the one for the stage you are on sets CHEAT_PRIZE_TAKEN to one and jumps to cheat_everything.
; The six prizes are only given if CHEAT_PRIZE_TAKEN is still at zero, so the name
; and the words get in each other's way.
; MEASURED IN openMSX with tools/omsx_cheats.tcl, not deduced: paused,
; TYPED_KEYS fills with 4F 50 54 49 4F 4E (OPTION) and on pressing RETURN
; OPTION_COUNT goes from 00 to 02, the two options. With BAKA, the lives at
; LIVES go from 02 to 00 and the IN_PLAY flag goes off.
; ----------------------------------------------------------------------
check_typed_keys:		; Reads the keyboard and, on RETURN, compares what was typed against the cheats; each one jumps to its own routine in bank 3
	ld a,(SHIP)		; Negative: there is no ship, and no cheats
	and a
	ret m
	call which_key_is_pressed	; Which key is being pressed
	and a
	ret z
	ld hl,TYPED_LAST_KEY	; Keeps the previous one: only a new key counts
	cp (hl)
	ret z
	ld (hl),a
	ld c,a
	cp 00dh			; 0x0D is RETURN: until it is pressed, keys are just written down
	jp nz,record_key
	ld hl,clear_typing_state	; clear_typing_state is pushed: whatever happens, what was typed is erased on the way out
	push hl
	call compare_hyper	; HYPER
	jr nc,cheat_hyper
	call compare_baka	; BAKA...
	jr nc,punish_insult
	call compare_aho	; ...and AHO: both of them punish
	jr nc,punish_insult
	ld a,(CHEAT_PRIZE_TAKEN)	; Already set: no other prize is accepted
	and a
	ret nz
	call compare_stage_name	; The woman's name that belongs to this stage
	jp nc,cheat_stage_name
	ld a,(SHIP)
	and a
	ret m
	call compare_missile	; MISSILE
	jp nc,cheat_missile
	call compare_laser	; LASER
	jp nc,cheat_laser
	call compare_shield	; SHIELD
	jp nc,cheat_shield
	call compare_double	; DOUBLE
	jp nc,cheat_double
	call compare_down	; DOWN
	jp nc,cheat_down
	call compare_option	; OPTION
	jp nc,cheat_option
	ret
punish_insult:		; BAKA and AHO end up here: lives, flag and joystick flags to zero
	xor a			; Lives, flag and the two joystick flags
	ld (LIVES),a
	ld (IN_PLAY),a
	ld (SND_MUTE),a
	ld (NOISE_FX_ON),a
	ret
cheat_hyper:		; HYPER only works once per game, and HYPER_USED keeps track of it
	ld hl,HYPER_USED	; HYPER only works once per game
	ld a,(hl)
	and a
	ret nz
	inc (hl)
	jp cheat_everything
cheat_stage_name:		; The stage's name guessed right: CHEAT_PRIZE_TAKEN to one and off to bank 3
	ld a,001h
	ld (CHEAT_PRIZE_TAKEN),a
	jp cheat_everything
record_key:		; Stores the new keys in TYPED_KEYS, up to eight
	ld hl,TYPED_COUNT
	ld a,(hl)
	cp 008h			; Eight letters at most
	ret nc
	inc (hl)
	ld hl,TYPED_KEYS
	call add_a_to_hl
	ld (hl),c
	ret
compare_stage_name:		; Takes from the table at texts_per_stage the name that belongs to this stage and compares it
	ld hl,texts_per_stage
	ld a,(STAGE)
	dec a
	call get_word
	jr compare_word

; ----------------------------------------------------------------------
; DATA texts_per_stage: Fourteen words that compare_stage_name indexes with the stage
;   minus one: where the name typed on each stage starts (0x51F6, 0x51FD,
;   0x5202, ...).
texts_per_stage:
	defw texts+37h,texts+3Eh
	defw texts+43h,texts+49h
	defw texts+4Fh,texts+56h
	defw texts+5Dh,texts+63h
	defw texts+6Ah,texts+71h
	defw texts+77h,texts+7Eh
	defw texts+7Eh,texts+7Eh
compare_baka:
	ld de,texts+6		; BAKA
	jr compare_word
compare_aho:
	ld de,texts+0Bh		; AHO
	jr compare_word
compare_laser:
	ld de,texts+0Fh		; LASER
	jr prize_hit
compare_shield:
	ld de,texts+1Dh		; SHIELD
	jr prize_hit
compare_down:
	ld de,texts+32h		; DOWN
	jr prize_hit
compare_option:
	ld de,texts+24h		; OPTION
	jr prize_hit
compare_double:
	ld de,texts+2Bh		; DOUBLE
	jr prize_hit
compare_missile:
	ld de,texts+15h		; MISSILE
prize_hit:		; If the word matches, raises CHEAT_PRIZE_TAKEN so that another prize cannot be chained
	call compare_word
	ret c
	ld hl,CHEAT_PRIZE_TAKEN	; Goes up: no other prize is accepted on this stage
	inc (hl)
	ret
compare_hyper:
	ld de,texts		; HYPER
compare_word:		; Compares what was typed in TYPED_KEYS with the word at DE; 0x0D ends it, and it exits without carry if it matches
	ld hl,TYPED_KEYS
L_51B4:
	ld a,(de)
	cp 00dh			; The 0x0D separates one word from the next
	ret z
	cp (hl)
	inc de
	inc hl
	jr z,L_51B4
	scf			; Carry set: no match
	ret

; ----------------------------------------------------------------------
; DATA texts: Strings separated by 0x0D: HYPER, BAKA, AHO, LASER, MISSILE,
;   SHIELD, OPTION, DOUBLE, DOWN, and then the names that come by default in
;   the high score table: MOMOKO, CHIE, AKEMI, SYUKO, CHIAKI, NORIKO, SATOE,
;   YASUKO, KINUYO, HISAE, MIYUKI, YOHKO.
texts:
	defb 48h,59h,50h,45h,52h,0Dh,42h,41h,4Bh,41h,0Dh,41h,48h,4Fh,0Dh,4Ch	; "HYPER.BAKA.AHO.L"
	defb 41h,53h,45h,52h,0Dh,4Dh,49h,53h,53h,49h,4Ch,45h,0Dh,53h,48h,49h	; "ASER.MISSILE.SHI"
	defb 45h,4Ch,44h,0Dh,4Fh,50h,54h,49h,4Fh,4Eh,0Dh,44h,4Fh,55h,42h,4Ch	; "ELD.OPTION.DOUBL"
	defb 45h,0Dh,44h,4Fh,57h,4Eh,0Dh,4Dh,4Fh,4Dh,4Fh,4Bh,4Fh,0Dh,43h,48h	; "E.DOWN.MOMOKO.CH"
	defb 49h,45h,0Dh,41h,4Bh,45h,4Dh,49h,0Dh,53h,59h,55h,4Bh,4Fh,0Dh,43h	; "IE.AKEMI.SYUKO.C"
	defb 48h,49h,41h,4Bh,49h,0Dh,4Eh,4Fh,52h,49h,4Bh,4Fh,0Dh,53h,41h,54h	; "HIAKI.NORIKO.SAT"
	defb 4Fh,45h,0Dh,59h,41h,53h,55h,4Bh,4Fh,0Dh,4Bh,49h,4Eh,55h,59h,4Fh	; "OE.YASUKO.KINUYO"
	defb 0Dh,48h,49h,53h,41h,45h,0Dh,4Dh,49h,59h,55h,4Bh,49h,0Dh,59h,4Fh	; ".HISAE.MIYUKI.YO"
	defb 48h,4Bh,4Fh,0Dh
which_key_is_pressed:		; Walks the eight keyboard rows with SNSMAT and returns the character of the first key pressed
	ld b,008h
	ld e,000h
L_5247:
	ld a,e
	call SNSMAT		; SNSMAT: keyboard row E
	cpl			; A cpl: on the keyboard a pressed key is a zero
	and a
	jr nz,L_5257
	inc e
	djnz L_5247		; Eight rows
	xor a
	ld (TYPED_LAST_KEY),a	; With nothing pressed, to zero
	ret
L_5257:
	ld b,a
	ld a,e
	add a,a			; The row times eight: eight keys per row
	add a,a
	add a,a
	ld hl,alphabet
	call add_a_to_hl
	ld a,b
L_5263:
	rra			; It looks for the set bit, which is the key
	jr c,L_5269
	inc hl
	jr L_5263
L_5269:
	ld a,(hl)
	ret

; ----------------------------------------------------------------------
; DATA alphabet: The characters that can be chosen when entering the name, in
;   the order of the grid: 0123456789-^ and then @[;:],./_ and the 26 letters.
;   Indexed by 0x525C.
alphabet:
	defb 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,2Dh,5Eh
	defb 09h,40h,5Bh,3Bh,3Ah,5Dh,2Ch,2Eh,2Fh,5Fh,41h,42h
	defb 43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh	; "CDEFGHIJKLMN"
	defb 4Fh,50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah	; "OPQRSTUVWXYZ"
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,0Dh,00h,00h,00h,00h,00h,00h,00h,00h
state_machine:		; Eight states, dispatched by the table at state_table.
	ld hl,FRAME_COUNT	; Counts the runs of the interrupt.
	inc (hl)
	ld hl,states_return	; This is the address the state is going to return to...
	ld bc,(GAME_STATE)
	ld a,c
	cp 003h
	jr nc,L_52C4
	push hl			; ...and it is pushed onto the stack ONLY if GAME_STATE is less than 3.
L_52C4:
	call dispatcher		; Eight states, and the table goes right here behind.

; ----------------------------------------------------------------------
; DATA state_table: Eight words right behind the `call dispatcher` at L_52C4: the
;   game's eight states (state_0, state_1, state_2, state_3, state_4, state_5,
;   state_6, state_7).
state_table:
	defw state_0		; 0
	defw state_1		; 1
	defw state_2		; 2
	defw state_3		; 3
	defw state_4		; 4
	defw state_5		; 5
	defw state_6		; 6
	defw state_7		; 7
state_0:		; Three substates: the message at messages, the STATE_TIMER wait and building the title screen
	djnz L_52EC		; To substate 1 if it is not 0
	ld a,(FRAME_COUNT)
	rra
	ret nc
	call raise_logo
	ret nz
	ld de,messages
	call decompress_with_destination
	xor a
	jp L_5375
L_52EC:
	djnz L_52FA		; To substate 2 if it is not 1
	ld hl,STATE_TIMER	; The frames of waiting left
	dec (hl)
	ret nz
	call write_title_panel	; And the title screen is built
	xor a
	jp L_53A1
L_52FA:
	call program_vdp	; The wipe, the clean screen and the score
	call clear_screen
	call load_scoreboard
	call start_logo_curtain
	jr next_substate
state_1:		; Runs STATE_TIMER down and goes to the intro
	ld hl,STATE_TIMER
	dec (hl)
	jp nz,blink_selection
	jp wait_thirty_two_then_state
state_2:		; Maps banks 9 and 10 for one call, and splits into four substates
	djnz state_2_sub1
	di			; Banks 9 and 10, which are the intro ones
	ld a,009h
	ld (08000h),a
	ld (BANK_8000),a
	ei
	di
	ld a,00ah
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	call run_screen
	di			; And 2 and 3 restored
	ld a,002h
	ld (08000h),a
	ld (BANK_8000),a
	ei
	di
	ld a,003h
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	call upload_sprites_rotating
	call animate_three_characters
	ld a,(SND_CARD_A+CARD_MODE)	; While the 0xE012 channel is sounding, it waits
	and a
	ret nz
	jr wait_thirty_two
state_2_sub1:		; Waits for the joystick and starts the thing at start_demo
	djnz state_2_sub2
	call lower_curtain	; With the joystick untouched, it exits through p
	ret p			; With the joystick untouched it exits through p
	call start_demo
	jr next_substate
state_2_sub2:		; Waits for the joystick and, if there is no flag in IN_PLAY, goes back to state 0
	djnz state_2_sub3
	call run_demo		; One step of the demo
	ld a,(IN_PLAY)
	or a
	ret nz
back_to_state_0:		; State 0, substate 0 and 0x20 frames of waiting
	xor a
L_5362:
	ld (GAME_STATE),a
	ld a,020h
	ld (STATE_TIMER),a
	jr L_53A8
state_2_sub3:		; Waits for the joystick and starts the thing at build_high_score_screen
	call lower_curtain	; The joystick again
	ret p
	call build_high_score_screen
wait_thirty_two:		; 0x20 frames in STATE_TIMER and on to the next substate
	ld a,020h
L_5375:
	ld (STATE_TIMER),a	; The frames of waiting that A brings
next_substate:		; GAME_SUBSTATE + 1
	ld hl,GAME_SUBSTATE
	inc (hl)
	ret
state_3:		; Makes the message at 0x5808 or the one at 0x5812 blink (depending on bit 5 of GAME_FLAGS) by writing it and erasing it
	djnz state_3_sub1
	ld hl,STATE_TIMER
	dec (hl)
	jr z,next_substate
	ld a,(GAME_FLAGS)	; Bit 5 picks between the two messages
	bit 5,a
	ld de,messages+4Bh
	jr z,L_5392
	ld de,messages+55h
L_5392:
	bit 2,(hl)		; A bit of the counter: it is written and erased, and that is the blinking
	jp z,write_characters
	jp erase_characters
state_3_sub1:		; Calls start_whole_game and goes to the next state
	djnz state_3_sub2
	call start_whole_game
wait_thirty_two_then_state:		; 0x20 frames and on to the next state
	ld a,020h
L_53A1:
	ld (STATE_TIMER),a
next_state:		; GAME_STATE + 1 and the substate to zero
	ld hl,GAME_STATE
	inc (hl)
L_53A8:
	xor a
	ld (GAME_SUBSTATE),a
	ret
state_3_sub2:		; 0x50 frames of waiting
	ld a,050h
	jr L_5375
state_4:		; Erases the message at 0x5820, moves on to the next stage and turns on the IN_PLAY flag
	djnz state_4_sub1	; To substate 1 if it is not 0
	ld hl,STATE_TIMER
	dec (hl)
	ret nz
	ld de,messages+63h
	call erase_characters
	call set_up_due_stage
	ld a,001h
	ld (IN_PLAY),a
	jr next_state
state_4_sub1:		; Takes away a life in BCD, maps banks 4/5/6 and decompresses the six blocks of the stage screen
	call lower_curtain
	ret p
	ld hl,LIVES		; The lives, in BCD
	ld a,(hl)
	sub 001h
	daa
	ld (hl),a
	call load_stage_font
	di			; Banks 4, 5 and 6
	push hl			; Banks 4, 5 and 6 to read the stage graphics
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
	ld hl,03058h		; Three pattern blocks: 0x3058, 0x30A8 and 0x3160
	ld de,graphics_chain_6379
	call decompress
	ld hl,030a8h
	ld de,graphics_colours_30A8
	call decompress
	ld hl,03160h
	ld de,graphics_colours_30A8
	call decompress
	ld hl,01058h		; And their three colour ones: 0x1058, 0x10A8 and 0x1160
	ld de,graphics_chain_7793
	call decompress
	ld hl,010a8h
	ld de,graphics_patterns_10A8
	call decompress
	ld hl,01160h
	ld de,graphics_patterns_1160
	call decompress
	di			; 1, 2 and 3 restored
	push hl			; The usual layout again
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
	ld b,006h		; Six bytes at METER_HELD, to zero
	ld hl,METER_HELD
L_5444:
	ld (hl),000h
	inc hl
	djnz L_5444
	call flag_if_two_players
	call write_captions
	call load_scoreboard_two_thirds
	ld a,(GAME_FLAGS)	; Bit 5 says whether there are two players
	and 020h
	ld a,010h		; With one player, 0x10 frames
	jp z,L_5375
	call write_turn
	ld a,078h		; And with two, 0x78: there is time to read whose turn it is
	jp L_5375
state_5:		; The game frame with the pause; while the IN_PLAY flag is set, it does not leave
	call check_pause_key
	ld a,(IN_PLAY)
	or a
	ret nz
	jp wait_thirty_two_then_state
state_6:		; With no lives left sound 0xCA is requested; if the other player still has some, the turn changes
	ld a,(LIVES)		; The lives of the one playing
	or a
	jr z,L_5492
	ld a,(OTHER_PLAYER)	; And the other one's
	or a
	jr z,L_548D
switch_player:		; Swaps the 0x30 bytes at LIVES with those at OTHER_PLAYER and flips the turn bit
	ld hl,LIVES		; The 0x30 state bytes of the two players are swapped
	ld de,OTHER_PLAYER
	ld b,030h
	call swap_b_bytes
	ld hl,GAME_FLAGS
	ld a,(hl)
	xor 080h		; And bit 7 of GAME_FLAGS is inverted: the turn changes
	ld (hl),a
L_548D:
	ld a,004h		; State 4: on to setting up the stage
	jp L_5362
L_5492:
	ld a,0cah		; Sound 0xCA: the end of the game
	call request_sound
	jp wait_thirty_two_then_state
state_7:		; The end: waits for the sound and, if continue has been requested, gives three lives back and carries on
	djnz state_7_sub1
	call check_continue_request
	ld a,(SND_CARD_A+CARD_MODE)	; Until 0xE012 goes quiet, it does not go on
	or a
	ret nz
	ld a,(CONTINUE_ASKED)	; Continue has been requested
	and a
	jr z,L_54C3
	ld hl,SCORE_P1
	ld a,(GAME_FLAGS)	; Bit 7 says which player the score belongs to
	and 080h
	jr z,L_54B6
	ld l,057h
L_54B6:
	xor a			; The four bytes of the score, to zero
	ld (hl),a
	inc l
	ld (hl),a
	inc l
	ld (hl),a
	inc l
	ld (hl),a
	ld a,003h		; And three lives again
	ld (LIVES),a
L_54C3:
	ld a,(OTHER_PLAYER)	; If the other player has some left, the turn changes
	or a
	jr nz,switch_player
	ld a,(CONTINUE_ASKED)
	and a
	jr nz,L_548D
	ld hl,GAME_FLAGS	; And if not, bit 6 is turned off and on to the intro
	ld a,(hl)
	and 0bfh
	ld (hl),a
	jp back_to_state_0
state_7_sub1:		; Writes the message at 0x5836 and waits for continue to be requested
	call lower_curtain	; With the joystick untouched, it exits through p
	ret p
	call load_scoreboard_two_thirds
	ld de,messages+79h
	call write_characters
	call write_turn
	call write_captions
	xor a
	ld (CONTINUE_ASKED),a
	jp L_5375
check_continue_request:		; Bit 1 of keyboard row 7: when it is pressed, CONTINUE_ASKED to one and the message at 0x5843 is erased
	ld a,007h
	call SNSMAT		; SNSMAT of row 7
	bit 1,a			; Not pressed, the bit is at one
	ret nz
	ld a,001h
	ld (CONTINUE_ASKED),a
	ld de,messages+86h
	jp erase_characters
states_return:		; The states return here: 0x52B7 pushes this address onto the stack before dispatching.
	call read_controller_no_save
	ld hl,INTRO_CONTROLLER	; This and INTRO_CHOICE: what was pressed in the intro
	call just_pressed
	or a
	ret z
	ld hl,STATE_TIMER
	ld (hl),000h
	ld l,(hl)
	ld de,INTRO_CHOICE
	ld b,(hl)
	djnz L_5536
	and 030h		; Bits 4 and 5: one or two players
	jr z,L_5540
	ld a,(de)		; With one player, 0x40 in GAME_FLAGS; with two, 0x60
	or a
	ld a,040h
	jr z,L_5529
	ld a,060h
L_5529:
	ld (GAME_FLAGS),a
	ld (hl),003h		; State 3
	inc hl
	ld c,000h
	ld (hl),c
	dec c
	jp L_5BDD
L_5536:
	ld (hl),001h		; With no choice made, sound 0xCD
	ld a,0cdh
	call request_sound
	jp write_title_panel
L_5540:
	ld a,(de)		; And the bit of INTRO_CHOICE is inverted: the choice changes
	xor 001h
	ld (de),a
	ret
write_turn:		; With two players, the message at 0x5820 or the one at 0x582B depending on whose turn it is
	ld a,(GAME_FLAGS)
	bit 5,a			; Bit 5 of GAME_FLAGS: only with two players
	ret z
	ld de,messages+63h
	and 080h		; And bit 7 says which of the two
	jr z,L_5555
	ld de,messages+6Eh
L_5555:
	jp write_characters
start_whole_game:		; Clears the 0xFA9 bytes at SCORE_P2, leaves three lives and a flag, the prize at 0x0010, and with two players copies everything to the second one
	ld hl,SCORE_P2		; The 0xFA9 bytes from here, to zero
	ld bc,00fa9h
	ld d,h
	ld e,l
	inc e
	ld (hl),000h
	ldir
	ld hl,two_bytes_to_e060	; Three lives and the flag, from two_bytes_to_e060
	ld de,LIVES
	ld bc,00002h
	ldir
	ld hl,00010h		; 0x0010 in NEXT_EXTRA_LIFE: the first extra-life prize
	ld (NEXT_EXTRA_LIFE),hl
	ld a,(GAME_FLAGS)	; With two players...
	and 020h
	ret z
	ld hl,LIVES		; ...the 0x30 state bytes are also copied to the second one
	ld de,OTHER_PLAYER
	ld bc,00030h
	ldir
	ret

; ----------------------------------------------------------------------
; DATA two_bytes_to_e060: Two bytes (0x03, 0x01) that 0x5565 copies to LIVES
;   with LDIR.
two_bytes_to_e060:
	defb 03h,01h
lower_curtain:		; Lowers STATE_TIMER and, each frame, clears one row of the screen from bottom to top; exits with the sign set when it is over
	ld hl,STATE_TIMER
	dec (hl)		; On going below zero, the wipe is over
	ret m
	ld a,(hl)
	ld h,038h		; The row comes from STATE_TIMER reversed: 0x1F minus the count
	xor 01fh
	ld l,a
	ld b,016h		; Twenty-two rows high
	ld a,(GAME_STATE)	; In state 2 it is twenty-four
	cp 002h
	jr nz,L_55A0
	ld b,018h
L_55A0:
	xor a
	ld de,00020h		; 0x20: the next row
L_55A4:
	call WRTVRM
	add hl,de
	djnz L_55A4
remove_sprites_from_screen:		; Writes 0xD0 at VRAM 0x3B00: the attribute that tells the VDP that the sprites end there.
	ld hl,03b00h
	ld a,0d0h
	call WRTVRM
	xor a
	ret
add_to_score:		; Adds in BCD (it uses `daa`) onto the score of the player GAME_FLAGS says.
	ld a,(GAME_FLAGS)	; Bit 6 says whether there is a game
	add a,a
	ret p
	ld hl,SCORE_P1+1	; Player 1's score, and 0xE058 player 2's
	jr nc,L_55C0
	ld l,058h
L_55C0:
	ld a,(hl)
	add a,e
	daa			; The `daa`: the score is in BCD, three bytes
	ld (hl),a
	inc l
	ld a,(hl)
	adc a,d
	daa
	ld (hl),a
	inc hl
	ld a,(hl)
	adc a,000h
	daa
	ld (hl),a
	jr nc,L_55DB
	ld hl,09999h		; Past six nines, it sticks at 999999
	ld (HISCORE+1),hl
	ld (HISCORE+2),hl
	ret
L_55DB:
	ld d,(hl)
	dec l
	ld e,(hl)
	ld hl,(NEXT_EXTRA_LIFE)	; The next extra-life prize
	ex de,hl
	rst 20h			; DCOMPR: compares the score with the prize
	jr c,L_55F8
	ld a,010h		; 0x1000 more in BCD: the next prize
	add a,e
	daa
	ld e,a
	ld a,d
	adc a,000h
	daa
	ld d,a
	jr c,$+5		; Into the last byte of the next instruction: E0h is `ret po`
	ld (NEXT_EXTRA_LIFE),de
	call award_ship
L_55F8:
	ld a,(GAME_FLAGS)	; And from here down, the high score
	add a,a
	ld hl,SCORE_P1+3
	jr nc,L_5603
	ld l,05ah
L_5603:
	ld b,003h		; Three bytes, from highest to lowest
	ld de,HISCORE+3
	ld c,l
L_5609:
	ld a,(de)		; If the score goes past the high score...
	sub (hl)
	jr c,L_5613
	ret nz
	dec l
	dec e
	djnz L_5609
	ret
L_5613:
	ld l,c			; ...the high score is copied whole
	ld bc,00003h
	ld e,056h
	lddr
	ret
award_ship:		; Adds a life in BCD, and if there is no explosion in progress the alert sounds
	ld hl,LIVES
	ld a,(hl)		; One more, in BCD
	add a,001h
	daa
	ret c			; Past ninety-nine nothing is given away
	ld (hl),a
	ld a,(ENDING)		; With an explosion in progress, it does not sound
	and a
	ret nz
	ld a,015h		; Sound 0x15
	call check_if_sound
	jp draw_ships
write_captions:		; Writes with write_characters the messages at 0x57CE, 0x57E1 and 0x57E6.
	ld de,messages+11h
	call write_characters
	ld a,(GAME_FLAGS)	; Bit 7 picks between the 1P and the 2P label
	ld de,messages+24h
	add a,a
	jr nc,L_5644
	ld de,messages+29h
L_5644:
	call write_characters
	call draw_ships
	call draw_power_up_meter
draw_scores:		; The high score on row 23 and the score of the player that is due, three BCD bytes each
	ld de,HISCORE+3		; The high score
	ld hl,03af6h		; Row 23, column 22
	call L_5664
	ld a,(GAME_FLAGS)	; And the score of the player whose turn it is
	ld hl,03aeah
	ld de,SCORE_P1+3
	add a,a
	jr nc,L_5664
	ld e,05ah		; 0xE05A if it is the second one
L_5664:
	ld b,003h
	jr write_digits
draw_ships:		; The lives digit; with fewer than ten the tens digit is turned off
	ld hl,03ae3h		; Row 23, column 3
	ld de,LIVES
	ld a,(de)
	ld b,001h
	and 0f0h		; With the high nibble at zero only one digit is painted
	jr nz,write_digits	; Row 23, column 3: the lives digit
	call set_vram_write
	exx
	ld a,c			; The data port, which set_vram_write left in the alternate C
	exx
	ld c,a
	xor a
	out (c),a
	inc hl
	jr L_5693
write_digits:		; Sends the BCD digits out of the data port, from lowest to highest and two per byte
	call set_vram_write
	exx
	ld a,c
	exx			; And the same count for the digits of the score
	ld c,a
L_5689:
	ld a,(de)		; The high nibble...
	rra
	rra
	rra
	rra
	and 00fh
	inc a
	out (c),a
L_5693:
	ld a,(de)		; ...and the low one
	and 00fh
	inc a			; Plus one: the zero character is not 0
	out (c),a
	dec de
	djnz L_5689
	ret
draw_power_up_meter:		; The six cells of the meter on row 22, each with its four characters
	ld hl,03ac4h		; Row 22, column 4
	call set_vram_write
	ld hl,METER_HELD	; Six cells
	ld bc,00601h
L_56A9:
	push bc			; Six meter cells
	call draw_meter_cell
	pop bc
	inc c
	djnz L_56A9
	ret
draw_meter_cell:		; The four characters of that cell, off or on, and from another set if it is the selected one
	ld a,c
	add a,a			; Times eight: eight bytes per cell
	add a,a
	add a,a
	ld de,pairs_of_5709_56D9-8
	call add_a_to_de
	ld a,(hl)
	inc hl
	and a			; With the byte at zero, the cell is off
	jr z,L_56C4
	ld de,alternative_row
L_56C4:
	ld a,(METER_SLOT)	; And this says which one is selected: that one gets the other four
	cp c
	jr nz,L_56CE
	inc de
	inc de
	inc de
	inc de
L_56CE:
	ld b,004h		; Four characters per cell
L_56D0:
	ld a,(de)
L_56D1:
	exx			; The character, through the data port
	out (c),a
	exx
	inc de
	djnz L_56D0
	ret

; ----------------------------------------------------------------------
; DATA pairs_of_5709 (part): Rows of eight bytes that 0x56B6 indexes with the
;   value times eight.
pairs_of_5709_56D9:
	defb 15h,16h,17h,18h,2Ch,2Dh,2Eh,2Fh
	defb 19h,1Ah,1Bh,1Ch,30h,31h,32h,33h
	defb 1Dh,1Eh,1Fh,20h,34h,35h,36h,37h
	defb 21h,22h,23h,24h,38h,39h,3Ah,3Bh
	defb 25h,26h,27h,28h,3Ch,3Dh,3Eh,3Fh
	defb 2Bh,29h,2Ah,2Bh,42h,40h,41h,42h

; ----------------------------------------------------------------------
; DATA alternative_row: The row of eight bytes that 0x56C1 switches to when
;   the previous byte is not zero.
alternative_row:
	defb 2Bh,2Bh,2Bh,0Ch,42h,42h,42h,42h	; "+++.BBBB"
swap_b_bytes:		; Swaps B bytes between HL and DE, one by one
	ld c,(hl)		; B bytes, one by one
	ld a,(de)
	ld (hl),a
	ld a,c
	ld (de),a
	inc hl
	inc de
	djnz swap_b_bytes
	ret
cell_to_ram_address:		; From the screen cell in HL works out the address in the RAM map: row times 0x20 plus column, on top of MAP
	ld a,l
	rra
	rra
	rra
	rra
	rr h			; Four shifts of the whole of HL: divided by sixteen
	rra
	rr h
	rra
	rr h
	ld l,h
	and 003h		; The two bits that are left...
	add a,0edh		; ...plus 0xED: the map lives from MAP to 0xEFFF
	ld h,a
	ret
start_machine:		; Silences the PSG, requests sound 0xCD, clears the 16 KB of VRAM and programs the eight registers
	ld a,0b8h		; 0xB8 in PSG register 7: the three channels silenced
	ld (SND_MIX),a
	ld e,a
	ld a,007h
	call WRTPSG
	ld a,0cdh		; Sound 0xCD
	call request_sound
	ld hl,00000h		; The 0x4000 bytes of VRAM, to zero
	ld bc,04000h
	xor a
	call FILVRM

; (Falls through into vdp_setup.asm, which the link places right after.)

	end

; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - stage_ends.asm
; ============================================================================

	include "variables.inc"

	public end_of_stage_1,end_of_stage_10,end_of_stage_11,end_of_stage_12,end_of_stage_2,end_of_stage_3
	public end_of_stage_4,end_of_stage_5,end_of_stage_6,end_of_stage_7,end_of_stage_8,end_of_stage_9
	extrn check_if_sound,raise_difficulty,set_up_five_pieces,start_big_ones_flock,start_game,start_long_flock
	extrn start_rain

; ----------------------------------------------------------------------
; THE END OF EACH STAGE, ONE PER STAGE
; The table at end_of_stage_routines dispatches by stage: each one has its own little
; state machine here, with the step in STAGE_END_STEP, and they all follow the
; same script: wait for the distance travelled to reach a point, switch on
; the boss (BOSS_STATE), wait for it to be killed (BOSS_DONE) and let the game
; move on to the next stage. What changes from one to another is the
; distances and which bank 2 or 3 routine is called.
; ----------------------------------------------------------------------
end_of_stage_1:		; Waits for distance 0x165, switches on the warning in ENEMY_WAVE and leaves the limit at 0x1C2
	ld a,(STAGE_END_STEP)	; The end-of-stage step
	dec a			; STAGE_END_STEP: the end-of-stage step
	jr z,wait_until_dead
	dec a
	jr z,switch_on_boss
	dec a
	jr z,end_stage
	ld a,(FIVE_PIECES_ON)
	and a
	jr nz,switch_off_boss
	ld hl,(DISTANCE)	; The distance travelled...
	ld de,00165h		; ...against 0x165
	rst 20h
	jp z,set_up_five_pieces
	ld a,(SCROLL_AT_LIMIT)	; Only on the steps with a new column
	and a
	ret z
	ld a,001h
	ld (ENEMY_WAVE),a
	ld hl,001c2h		; And the scroll stops at 0x1C2
	ld (ENEMY_WAVE_LEFT),hl
advance_end_step:		; STAGE_END_STEP + 1
	ld hl,STAGE_END_STEP
	inc (hl)
	ret
switch_off_boss:		; With BOSS_DONE set, switches off the flag and the warning in FIVE_PIECES_ON
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (FIVE_PIECES_ON),a
	ret
wait_until_dead:		; Until BOSS_DONE is set, it does not go on; then it lets the scroll run up to 0x1C0
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)		; BOSS_DONE: not until it dies
	and a
	ret z
	xor a
	ld (ENEMY_WAVE),a
	ld hl,001c0h		; The scroll goes up to 0x1C0
	ld (SCROLL_LIMIT),hl
	jr advance_end_step
switch_on_boss:		; BOSS_STATE to one: the boss comes on screen
	ld a,(SCROLL_AT_LIMIT)
	and a
	ret z
L_6D43:
	xor a			; BOSS_DONE to zero and MUSIC_HOLD to one
	ld (BOSS_DONE),a
	inc a
	ld (MUSIC_HOLD),a	; To one
	ld hl,00001h		; And BOSS_STATE and BOSS_KIND: the boss on its first step
	ld (BOSS_STATE),hl
	jr advance_end_step

; ----------------------------------------------------------------------
; THE ORDER OF THE STAGES IS NOT 1, 2, 3...
; There are two different ways out of a stage, and that is where the
; cartridge's real route comes from:
; - end_stage calls go_to_next_stage, which adds
; one to STAGE and wraps around after the eighth.
; - jump_to_stage puts a number written by hand into STAGE,
; and EIGHT places jump to it, each with its own number.
; Stages 2, 3, 4 and 7 look at SCROLL_MODE (the screen stopped) and, if it is,
; jump to 9, 10, 11 and 12; and those four, when they end, jump to 3, 4,
; 5 and 8, which are the four bytes of stages_per_round.
; So the twelve stages are played like this:
; 1 - 2 - 9 - 3 - 10 - 4 - 11 - 5 - 6 - 7 - 12 - 8 - ending - 1
; The four two-digit ones are interludes slipped in between the others,
; not a second loop nor a loose stretch.
; ----------------------------------------------------------------------
end_stage:		; Switches off the boss and, if the ship is still alive, adds one to the stage
	ld a,(BOSS_DONE)
	and a
	ret z
	ld hl,00000h
	ld (BOSS_STATE),hl
	ld a,(SHIP)		; Negative: the ship is dead
	and a
	ret m
	jp go_to_next_stage
end_of_stage_2:		; With the screen stopped it JUMPS TO STAGE 9; if not, it follows the four-step script and ends in stage 3
	ld a,(SCROLL_MODE)	; The screen is stopped
	and a
	jr z,L_6D76
	ld a,(SCROLL_AT_LIMIT)
	and a
	ret z
	ld a,009h		; Stage 9
	jp jump_to_stage
L_6D76:
	ld a,(STAGE_END_STEP)	; The end-of-stage step
	dec a
	jr z,wait_until_dead_and_clear
	dec a
	jr z,switch_on_boss_2
	dec a
	jr z,end_stage
	ld a,(SCROLL_AT_LIMIT)	; Only on the steps with a column
	and a
	ret z
	call start_rain
	jr advance_end_step
wait_until_dead_and_clear:		; The same, and it also clears RAIN_ON
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (RAIN_ON),a
	ld hl,001dfh		; The scroll goes up to 0x1DF
	ld (SCROLL_LIMIT),hl
	jp advance_end_step
switch_on_boss_2:		; The same as switch_on_boss
	ld a,(SCROLL_AT_LIMIT)
	and a
	ret z
	jr L_6D43
end_of_stage_3:		; Like the previous one, but the stage it jumps to is 10
	ld a,(SCROLL_MODE)	; The screen is stopped
	and a			; Only on the steps with a column
	jr z,L_6DB7
	ld a,(SCROLL_AT_LIMIT)
	and a
	ret z
	ld a,00ah		; Stage 10
	jp jump_to_stage
L_6DB7:
	ld a,(STAGE_END_STEP)	; The end-of-stage step
	dec a
	jr z,wait_and_release_scroll
	dec a
	jr z,switch_on_boss_3
	dec a
	jp z,end_stage
	ld a,(BOSS_STATE)	; Whether there is already a boss on screen
	or a
	jr nz,wait_and_switch_off
	ld hl,(DISTANCE)	; The distance travelled...
	ld de,00060h		; ...against 0x60
	rst 20h
	jr z,other_boss
	ld a,(SCROLL_AT_LIMIT)
	and a
	ret z
	ld hl,00101h		; 0x0101 in BOSS_STATE: the boss, on its first step
	ld (BOSS_STATE),hl
	jp advance_end_step
other_boss:		; With LOOP_NUMBER set, boss 6 comes out instead of boss 1
	ld a,(LOOP_NUMBER)	; Which loop it is on
	or a
	ret z
	ld hl,00601h
	ld (BOSS_STATE),hl
	ret
wait_and_switch_off:		; When the boss dies, switches off both flags
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (BOSS_STATE),a
	ret
wait_and_release_scroll:		; When the boss dies, switches off the flags and lets the scroll run up to 0x1AF
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)		; BOSS_DONE to zero
	and a
	ret z
	xor a
	ld (hl),a
	ld (BOSS_STATE),a
	ld hl,001afh		; The scroll goes up to 0x1AF
	ld (SCROLL_LIMIT),hl
	jp advance_end_step
switch_on_boss_3:
	ld a,(SCROLL_AT_LIMIT)
	and a
	ret z
	jp L_6D43
end_of_stage_4:		; With the screen stopped it JUMPS TO STAGE 11; if not, five steps with two bosses
	ld a,(SCROLL_MODE)	; The screen is stopped
	and a
	jr z,L_6E25
	ld a,(SCROLL_AT_LIMIT)	; Only on the steps with a column
	and a
	ret z
	ld a,00bh		; Stage 11
	jp jump_to_stage
L_6E25:
	ld a,(STAGE_END_STEP)
	dec a			; STAGE_END_STEP: the end-of-stage step
	jr z,middle_boss
	dec a
	jr z,wait_and_release_to_1C0
	dec a
	jr z,switch_on_boss_4
	dec a
	jp z,end_stage
	ld a,(ENEMY_WAVE)	; The warning that something is waiting
	and a
	jr nz,wait_for_first
	ld hl,(DISTANCE)	; The distance...
	ld de,00128h		; ...against 0x128
	rst 20h
	ret nz
	ld a,002h		; ENEMY_WAVE to two, the limit at 0xB4 and 0xD0 in ENEMY_WAVE_X
	ld (ENEMY_WAVE),a
	ld hl,000b4h
	ld (ENEMY_WAVE_LEFT),hl
	ld a,0d0h
	ld (ENEMY_WAVE_X),a
	ret
wait_for_first:		; When the first one dies, switches off the warning and moves to the next step
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)		; BOSS_DONE: not until it dies
	and a			; BOSS_DONE: not until it dies
	ret z
	xor a
	ld (hl),a
	ld (ENEMY_WAVE),a
	jp advance_end_step
middle_boss:		; At distance 0x171 calls bank 2; if not, brings out boss 5
	ld a,(FIVE_PIECES_ON)
	and a
	jr nz,wait_for_middle_boss
	ld hl,(DISTANCE)
	ld de,00171h		; Distance 0x171
	rst 20h
	jp z,set_up_five_pieces
	ld a,(SCROLL_AT_LIMIT)
	and a
	ret z
	ld hl,00501h		; 0x0501 in BOSS_STATE: boss 5
	ld (BOSS_STATE),hl
	jp advance_end_step
wait_for_middle_boss:		; When it dies, switches off FIVE_PIECES_ON
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (FIVE_PIECES_ON),a
	ret
wait_and_release_to_1C0:		; When the boss dies, the scroll goes up to 0x1C0
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (BOSS_STATE),a
	ld hl,001c0h		; The scroll goes up to 0x1C0
	ld (SCROLL_LIMIT),hl
	jp advance_end_step
switch_on_boss_4:
	ld a,(SCROLL_AT_LIMIT)	; Only on the steps with a column
	and a
	ret z
	jp L_6D43
end_of_stage_5:		; Four steps, with two calls to bank 3 and the scroll let run up to 0x1FF
	ld a,(STAGE_END_STEP)
	dec a			; STAGE_END_STEP: the end-of-stage step
	jr z,wait_and_call_bank3
	dec a
	jr z,wait_and_release_to_1FF
	dec a			; To step 4, which ends the stage
	jr z,switch_on_boss_5
	dec a
	jp z,end_stage
	ld a,(SCROLL_AT_LIMIT)	; Only on the steps with a column
	and a
	ret z
	call start_long_flock	; A bank 3 routine sets up whatever is due
	jp advance_end_step
wait_and_call_bank3:		; When it dies, clears LFLOCK_ON and calls bank 3 again
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (LFLOCK_ON),a
	call start_big_ones_flock
	jp advance_end_step
wait_and_release_to_1FF:		; When it dies, clears BIGFLOCK_ON and the scroll goes up to 0x1FF
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a		; When it dies, the scroll goes up to 0x1FF
	ld (BIGFLOCK_ON),a
	ld hl,001ffh
	ld (SCROLL_LIMIT),hl
	jp advance_end_step
switch_on_boss_5:
	ld a,(SCROLL_AT_LIMIT)	; Only on the steps with a column
	and a
	ret z
	jp L_6D43
end_of_stage_6:		; Past distance 0xA0 brings out boss 2, and when it dies leaves the limit wherever it is
	ld a,(STAGE_END_STEP)	; The end-of-stage step
	dec a
	jr z,wait_and_stop_where_it_is
	dec a
	jp z,end_stage
	ld hl,(DISTANCE)
	ld de,000a0h		; Distance 0xA0
	rst 20h
	ret c
	ld hl,00201h		; 0x0201 in BOSS_STATE: boss 2
	ld (BOSS_STATE),hl
	jp advance_end_step
wait_and_stop_where_it_is:		; When the boss dies, the limit stays at the current distance
	ld a,(BOSS_DONE)	; Not until it dies
	and a
	ret z
	ld hl,(DISTANCE)
	ld (SCROLL_LIMIT),hl
	jp L_6D43
end_of_stage_7:		; With the screen stopped it JUMPS TO STAGE 12; if not, brings out boss 3
	ld a,(SCROLL_MODE)	; The screen is stopped
	and a
	jr z,L_6F29
	ld a,(SCROLL_AT_LIMIT)	; Only on the steps with a column
	and a
	ret z
	ld a,00ch		; Stage 12
	jp jump_to_stage
L_6F29:
	ld a,(STAGE_END_STEP)
	dec a			; STAGE_END_STEP: the end-of-stage step
	jp z,end_stage
	ld a,(SCROLL_AT_LIMIT)
	and a
	ret z
	ld a,001h		; MUSIC_HOLD to one
	ld (MUSIC_HOLD),a
	ld hl,00301h		; 0x0301 in BOSS_STATE: boss 3
	ld (BOSS_STATE),hl
	jp advance_end_step
end_of_stage_8:		; At distance 0x16E brings out boss 4 and, when it is killed, starts the final explosion
	ld a,(STAGE_END_STEP)
	dec a
	jr z,start_game_ending
	dec a
	jp z,finish_ending
	ld hl,(DISTANCE)
	ld de,0016eh		; Distance 0x16E
	rst 20h
	ret nz
	ld hl,00401h		; 0x0401 in BOSS_STATE: boss 4
	ld (BOSS_STATE),hl	; 0x0401: boss 4
	jp advance_end_step
start_game_ending:		; With the last boss dead, and the ship alive, switches on ENDING: the ending sequence
	ld a,(BOSS_DONE)
	and a
	ret z
	ld hl,00000h
	ld (BOSS_STATE),hl
	xor a
	ld (BOSS_DONE),a
	ld a,(SHIP)		; Negative: the ship was already dead
	and a
	ret m
	ld hl,00001h		; ENDING to one: the final explosion starts
	ld (ENDING),hl
	ld hl,00300h		; 0x0300 in ENDING_SHIP_Y
	ld (ENDING_SHIP_Y),hl
	ld a,041h		; Sound 0x41
	call check_if_sound
	jp advance_end_step
finish_ending:		; Switches off ENDING and moves on a stage
	ld hl,BOSS_DONE		; Not until it dies
	ld a,(hl)		; BOSS_DONE: not until it dies
	and a			; BOSS_DONE: not until it dies
	ret z
	ld (hl),000h
	ld hl,00000h
	ld (ENDING),hl
	jp go_to_next_stage
end_of_stage_9:		; Once the interlude is over, back to stage 3
	ld a,(SCROLL_AT_LIMIT)
	and a
	ret z
	ld a,003h		; Stage 3, not an object
	jr jump_to_stage
end_of_stage_10:		; Back to stage 4
	ld a,(SCROLL_AT_LIMIT)	; Only on the steps with a column
	and a
	ret z
	ld a,004h		; Stage 4
	jr jump_to_stage
end_of_stage_11:		; Back to stage 5
	ld a,(SCROLL_AT_LIMIT)	; Only on the steps with a column
	and a
	ret z
	ld a,005h		; Stage 5
	jr jump_to_stage
end_of_stage_12:		; Back to stage 8, the last one
	ld a,(SCROLL_AT_LIMIT)	; Only on the steps with a column
	and a
	ret z
	ld a,008h		; Stage 8
jump_to_stage:		; Puts into STAGE the stage that A brings, clears the counters and starts through start_game; it swallows the return address with a `pop hl`
	ld (STAGE),a
	xor a
	ld (SCROLL_AT_LIMIT),a	; This, STAGE_END_STEP and SCROLL_MODE to zero
	ld (STAGE_END_STEP),a
	ld (SCROLL_MODE),a
	call start_game
	ld a,01fh		; 0x1F of distance travelled
	ld (DISTANCE),a
	pop hl			; The return is thrown away: there is no coming back from here
	ret
go_to_next_stage:		; Adds one to the stage; past the eighth it goes back to the first, lowers the difficulty four steps and adds one to the loop
	call raise_difficulty
	xor a
	ld (STAGE_END_STEP),a
	ld hl,STAGES_PLAYED	; Counts the stages played
	inc (hl)
	ld hl,STAGE
	ld a,(hl)
	inc a
	ld (hl),a
	cp 009h			; Past the eighth, back to the first
	jp c,start_game
	ld (hl),001h
	ld hl,DIFFICULTY	; And the difficulty goes down four steps
	ld a,(hl)
	sub 004h
	jr nc,L_6FF1
	xor a
L_6FF1:
	ld (hl),a
	ld hl,00000h		; TARGET_KIND and 0xE06D to zero
	ld (TARGET_KIND),hl
	ld hl,LOOP_NUMBER	; Which loop it is on
	inc (hl)
	jp nz,start_game
	dec (hl)
	jp start_game

	end

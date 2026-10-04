; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - stage_ends.asm
; ============================================================================

	public end_of_stage_1,end_of_stage_10,end_of_stage_11,end_of_stage_12,end_of_stage_2,end_of_stage_3
	public end_of_stage_4,end_of_stage_5,end_of_stage_6,end_of_stage_7,end_of_stage_8,end_of_stage_9
	extrn raise_difficulty,set_up_five_pieces,start_big_ones_flock,start_game,start_long_flock,start_rain

; ----------------------------------------------------------------------
; THE END OF EACH STAGE, ONE PER STAGE
; The table at 0x6CD7 dispatches by stage: each one has its own little
; state machine here, with the step in 0xE065, and they all follow the
; same script: wait for the distance travelled to reach a point, switch on
; the boss (0xE151), wait for it to be killed (0xE150) and let the game
; move on to the next stage. What changes from one to another is the
; distances and which bank 2 or 3 routine is called.
; ----------------------------------------------------------------------
end_of_stage_1:		; Waits for distance 0x165, switches on the warning in 0xE140 and leaves the limit at 0x1C2
	ld a,(0e065h)		; 0xE065: the end-of-stage step
	dec a			; 0xE065: the end-of-stage step
	jr z,wait_until_dead
	dec a
	jr z,switch_on_boss
	dec a
	jr z,end_stage
	ld a,(0e1b0h)
	and a
	jr nz,switch_off_boss
	ld hl,(0e063h)		; The distance travelled...
	ld de,00165h		; ...against 0x165
	rst 20h
	jp z,08e77h
	ld a,(0e107h)		; Only on the steps with a new column
	and a
	ret z
	ld a,001h
	ld (0e140h),a
	ld hl,001c2h		; And the scroll stops at 0x1C2
	ld (0e148h),hl
advance_end_step:		; 0xE065 + 1
	ld hl,0e065h
	inc (hl)
	ret
switch_off_boss:		; With 0xE150 set, switches off the flag and the warning in 0xE1B0
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (0e1b0h),a
	ret
wait_until_dead:		; Until 0xE150 is set, it does not go on; then it lets the scroll run up to 0x1C0
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)		; 0xE150: not until it dies
	and a
	ret z
	xor a
	ld (0e140h),a
	ld hl,001c0h		; The scroll goes up to 0x1C0
	ld (0e105h),hl
	jr advance_end_step
switch_on_boss:		; 0xE151 to one: the boss comes on screen
	ld a,(0e107h)
	and a
	ret z
L_6D43:
	xor a			; 0xE150 to zero and 0xE114 to one
	ld (0e150h),a
	inc a
	ld (0e114h),a		; 0xE114 to one
	ld hl,00001h		; And 0xE151 and 0xE152: the boss on its first step
	ld (0e151h),hl
	jr advance_end_step

; ----------------------------------------------------------------------
; THE ORDER OF THE STAGES IS NOT 1, 2, 3...
; There are two different ways out of a stage, and that is where the
; cartridge's real route comes from:
; - end_stage (0x6D53) calls go_to_next_stage, which adds
; one to 0xE061 and wraps around after the eighth.
; - jump_to_stage (0x6FB9) puts a number written by hand into 0xE061,
; and EIGHT places jump to it, each with its own number.
; Stages 2, 3, 4 and 7 look at 0xE1C0 (the screen stopped) and, if it is,
; jump to 9, 10, 11 and 12; and those four, when they end, jump to 3, 4,
; 5 and 8, which are the four bytes of stages_per_round.
; So the twelve stages are played like this:
; 1 - 2 - 9 - 3 - 10 - 4 - 11 - 5 - 6 - 7 - 12 - 8 - ending - 1
; The four two-digit ones are interludes slipped in between the others,
; not a second loop nor a loose stretch.
; ----------------------------------------------------------------------
end_stage:		; Switches off the boss and, if the ship is still alive, adds one to the stage
	ld a,(0e150h)
	and a
	ret z
	ld hl,00000h
	ld (0e151h),hl
	ld a,(0e200h)		; With 0xE200 negative the ship is dead
	and a
	ret m
	jp go_to_next_stage
end_of_stage_2:		; With the screen stopped it JUMPS TO STAGE 9; if not, it follows the four-step script and ends in stage 3
	ld a,(0e1c0h)		; 0xE1C0: the screen is stopped
	and a
	jr z,L_6D76
	ld a,(0e107h)
	and a
	ret z
	ld a,009h		; Stage 9
	jp jump_to_stage
L_6D76:
	ld a,(0e065h)		; 0xE065: the end-of-stage step
	dec a
	jr z,wait_until_dead_and_clear
	dec a
	jr z,switch_on_boss_2
	dec a
	jr z,end_stage
	ld a,(0e107h)		; Only on the steps with a column
	and a
	ret z
	call start_rain
	jr advance_end_step
wait_until_dead_and_clear:		; The same, and it also clears 0xE972
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (0e972h),a
	ld hl,001dfh		; The scroll goes up to 0x1DF
	ld (0e105h),hl
	jp advance_end_step
switch_on_boss_2:		; The same as 0x6D3E
	ld a,(0e107h)
	and a
	ret z
	jr L_6D43
end_of_stage_3:		; Like the previous one, but the stage it jumps to is 10
	ld a,(0e1c0h)		; 0xE1C0: the screen is stopped
	and a			; Only on the steps with a column
	jr z,L_6DB7
	ld a,(0e107h)
	and a
	ret z
	ld a,00ah		; Stage 10
	jp jump_to_stage
L_6DB7:
	ld a,(0e065h)		; 0xE065: the end-of-stage step
	dec a
	jr z,wait_and_release_scroll
	dec a
	jr z,switch_on_boss_3
	dec a
	jp z,end_stage
	ld a,(0e151h)		; 0xE151: whether there is already a boss on screen
	or a
	jr nz,wait_and_switch_off
	ld hl,(0e063h)		; The distance travelled...
	ld de,00060h		; ...against 0x60
	rst 20h
	jr z,other_boss
	ld a,(0e107h)
	and a
	ret z
	ld hl,00101h		; 0x0101 in 0xE151: the boss, on its first step
	ld (0e151h),hl
	jp advance_end_step
other_boss:		; With 0xE06A set, boss 6 comes out instead of boss 1
	ld a,(0e06ah)		; 0xE06A: which loop it is on
	or a
	ret z
	ld hl,00601h
	ld (0e151h),hl
	ret
wait_and_switch_off:		; When the boss dies, switches off both flags
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (0e151h),a
	ret
wait_and_release_scroll:		; When the boss dies, switches off the flags and lets the scroll run up to 0x1AF
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)		; 0xE150 to zero
	and a
	ret z
	xor a
	ld (hl),a
	ld (0e151h),a
	ld hl,001afh		; The scroll goes up to 0x1AF
	ld (0e105h),hl
	jp advance_end_step
switch_on_boss_3:
	ld a,(0e107h)
	and a
	ret z
	jp L_6D43
end_of_stage_4:		; With the screen stopped it JUMPS TO STAGE 11; if not, five steps with two bosses
	ld a,(0e1c0h)		; 0xE1C0: the screen is stopped
	and a
	jr z,L_6E25
	ld a,(0e107h)		; Only on the steps with a column
	and a
	ret z
	ld a,00bh		; Stage 11
	jp jump_to_stage
L_6E25:
	ld a,(0e065h)
	dec a			; 0xE065: the end-of-stage step
	jr z,middle_boss
	dec a
	jr z,wait_and_release_to_1C0
	dec a
	jr z,switch_on_boss_4
	dec a
	jp z,end_stage
	ld a,(0e140h)		; 0xE140: the warning that something is waiting
	and a
	jr nz,wait_for_first
	ld hl,(0e063h)		; The distance...
	ld de,00128h		; ...against 0x128
	rst 20h
	ret nz
	ld a,002h		; 0xE140 to two, the limit at 0xB4 and 0xD0 in 0xE141
	ld (0e140h),a
	ld hl,000b4h
	ld (0e148h),hl
	ld a,0d0h
	ld (0e141h),a
	ret
wait_for_first:		; When the first one dies, switches off the warning and moves to the next step
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)		; 0xE150: not until it dies
	and a			; 0xE150: not until it dies
	ret z
	xor a
	ld (hl),a
	ld (0e140h),a
	jp advance_end_step
middle_boss:		; At distance 0x171 calls bank 2; if not, brings out boss 5
	ld a,(0e1b0h)
	and a
	jr nz,wait_for_middle_boss
	ld hl,(0e063h)
	ld de,00171h		; Distance 0x171
	rst 20h
	jp z,set_up_five_pieces
	ld a,(0e107h)
	and a
	ret z
	ld hl,00501h		; 0x0501 in 0xE151: boss 5
	ld (0e151h),hl
	jp advance_end_step
wait_for_middle_boss:		; When it dies, switches off 0xE1B0
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (0e1b0h),a
	ret
wait_and_release_to_1C0:		; When the boss dies, the scroll goes up to 0x1C0
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (0e151h),a
	ld hl,001c0h		; The scroll goes up to 0x1C0
	ld (0e105h),hl
	jp advance_end_step
switch_on_boss_4:
	ld a,(0e107h)		; Only on the steps with a column
	and a
	ret z
	jp L_6D43
end_of_stage_5:		; Four steps, with two calls to bank 3 and the scroll let run up to 0x1FF
	ld a,(0e065h)
	dec a			; 0xE065: the end-of-stage step
	jr z,wait_and_call_bank3
	dec a
	jr z,wait_and_release_to_1FF
	dec a			; To step 4, which ends the stage
	jr z,switch_on_boss_5
	dec a
	jp z,end_stage
	ld a,(0e107h)		; Only on the steps with a column
	and a
	ret z
	call start_long_flock	; A bank 3 routine sets up whatever is due
	jp advance_end_step
wait_and_call_bank3:		; When it dies, clears 0xE988 and calls bank 3 again
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a
	ld (0e988h),a
	call start_big_ones_flock
	jp advance_end_step
wait_and_release_to_1FF:		; When it dies, clears 0xE990 and the scroll goes up to 0x1FF
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)
	and a
	ret z
	xor a
	ld (hl),a		; When it dies, the scroll goes up to 0x1FF
	ld (0e990h),a
	ld hl,001ffh
	ld (0e105h),hl
	jp advance_end_step
switch_on_boss_5:
	ld a,(0e107h)		; Only on the steps with a column
	and a
	ret z
	jp L_6D43
end_of_stage_6:		; Past distance 0xA0 brings out boss 2, and when it dies leaves the limit wherever it is
	ld a,(0e065h)		; 0xE065: the end-of-stage step
	dec a
	jr z,wait_and_stop_where_it_is
	dec a
	jp z,end_stage
	ld hl,(0e063h)
	ld de,000a0h		; Distance 0xA0
	rst 20h
	ret c
	ld hl,00201h		; 0x0201 in 0xE151: boss 2
	ld (0e151h),hl
	jp advance_end_step
wait_and_stop_where_it_is:		; When the boss dies, the limit stays at the current distance
	ld a,(0e150h)		; 0xE150: not until it dies
	and a
	ret z
	ld hl,(0e063h)
	ld (0e105h),hl
	jp L_6D43
end_of_stage_7:		; With the screen stopped it JUMPS TO STAGE 12; if not, brings out boss 3
	ld a,(0e1c0h)		; 0xE1C0: the screen is stopped
	and a
	jr z,L_6F29
	ld a,(0e107h)		; Only on the steps with a column
	and a
	ret z
	ld a,00ch		; Stage 12
	jp jump_to_stage
L_6F29:
	ld a,(0e065h)
	dec a			; 0xE065: the end-of-stage step
	jp z,end_stage
	ld a,(0e107h)
	and a
	ret z
	ld a,001h		; 0xE114 to one
	ld (0e114h),a
	ld hl,00301h		; 0x0301 in 0xE151: boss 3
	ld (0e151h),hl
	jp advance_end_step
end_of_stage_8:		; At distance 0x16E brings out boss 4 and, when it is killed, starts the final explosion
	ld a,(0e065h)
	dec a
	jr z,start_game_ending
	dec a
	jp z,finish_ending
	ld hl,(0e063h)
	ld de,0016eh		; Distance 0x16E
	rst 20h
	ret nz
	ld hl,00401h		; 0x0401 in 0xE151: boss 4
	ld (0e151h),hl		; 0x0401 in 0xE151: boss 4
	jp advance_end_step
start_game_ending:		; With the last boss dead, and the ship alive, switches on 0xE1D0: the ending sequence
	ld a,(0e150h)
	and a
	ret z
	ld hl,00000h
	ld (0e151h),hl
	xor a
	ld (0e150h),a
	ld a,(0e200h)		; With 0xE200 negative, the ship was already dead
	and a
	ret m
	ld hl,00001h		; 0xE1D0 to one: the final explosion starts
	ld (0e1d0h),hl
	ld hl,00300h		; 0x0300 in 0xE1D3
	ld (0e1d3h),hl
	ld a,041h		; Sound 0x41
	call 049deh
	jp advance_end_step
finish_ending:		; Switches off 0xE1D0 and moves on a stage
	ld hl,0e150h		; 0xE150: not until it dies
	ld a,(hl)		; 0xE150: not until it dies
	and a			; 0xE150: not until it dies
	ret z
	ld (hl),000h
	ld hl,00000h
	ld (0e1d0h),hl
	jp go_to_next_stage
end_of_stage_9:		; Once the interlude is over, back to stage 3
	ld a,(0e107h)
	and a
	ret z
	ld a,003h		; Stage 3, not an object
	jr jump_to_stage
end_of_stage_10:		; Back to stage 4
	ld a,(0e107h)		; Only on the steps with a column
	and a
	ret z
	ld a,004h		; Stage 4
	jr jump_to_stage
end_of_stage_11:		; Back to stage 5
	ld a,(0e107h)		; Only on the steps with a column
	and a
	ret z
	ld a,005h		; Stage 5
	jr jump_to_stage
end_of_stage_12:		; Back to stage 8, the last one
	ld a,(0e107h)		; Only on the steps with a column
	and a
	ret z
	ld a,008h		; Stage 8
jump_to_stage:		; Puts into 0xE061 the stage that A brings, clears the counters and starts through 0x4100; it swallows the return address with a `pop hl`
	ld (0e061h),a
	xor a
	ld (0e107h),a		; 0xE107, 0xE065 and 0xE1C0 to zero
	ld (0e065h),a
	ld (0e1c0h),a
	call start_game
	ld a,01fh		; 0x1F of distance travelled
	ld (0e063h),a
	pop hl			; The return is thrown away: there is no coming back from here
	ret
go_to_next_stage:		; Adds one to the stage; past the eighth it goes back to the first, lowers the difficulty four steps and adds one to the loop
	call raise_difficulty
	xor a
	ld (0e065h),a
	ld hl,0e066h		; 0xE066 counts the stages played
	inc (hl)
	ld hl,0e061h
	ld a,(hl)
	inc a
	ld (hl),a
	cp 009h			; Past the eighth, back to the first
	jp c,04100h
	ld (hl),001h
	ld hl,0e111h		; And the difficulty goes down four steps
	ld a,(hl)
	sub 004h
	jr nc,L_6FF1
	xor a
L_6FF1:
	ld (hl),a
	ld hl,00000h		; 0xE06C and 0xE06D to zero
	ld (0e06ch),hl
	ld hl,0e06ah		; 0xE06A: which loop it is on
	inc (hl)
	jp nz,04100h
	dec (hl)
	jp 04100h

	end

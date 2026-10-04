; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - game_start.asm
; ============================================================================

	public flag_if_two_players,set_up_due_stage,start_game
	extrn add_a_to_de,add_a_to_hl,get_word,load_stage_graphics,start_scroll,write_captions

; ----------------------------------------------------------------------
; STARTING A GAME AND STARTING A STAGE
; ----------------------------------------------------------------------
start_game:		; Sets the score to zero, clears the 0x900 bytes of objects at 0xE300 and loads the stage data
	call load_stage_graphics	; The score labels
	call write_captions
	xor a
	ld (0e071h),a		; 0xE071 to zero: the power-up count
	ld hl,00000h		; 0xE108, 0xE063 and 0xE127 to zero, two bytes at a time
	ld (0e108h),hl
	ld (0e063h),hl
	ld (0e127h),hl
	ld hl,0e300h		; The 0x900 bytes of the object table, to zero
	ld de,0e301h
	ld bc,008ffh
	ld (hl),000h
	ldir
	call load_stage_data	; And the data of whichever stage is due
	jp start_scroll
set_up_due_stage:		; Does NOT advance the stage: with 0xE061 at zero it sets it to one, and from the ninth onwards it replaces it with the one the table at 0x418F says; then it sets it up
	ld hl,0e061h
	ld a,(hl)		; With the stage at zero, start with the first one
	and a
	jr nz,L_4132
	ld (hl),001h
L_4132:
	ld a,(hl)
	sub 009h		; Below nine the stage is set up as it is
	jr c,start_stage
	ld de,0418fh		; The table at 0x418F, indexed by the stage minus nine: it only has four entries
	call add_a_to_de
	ld a,(de)
	ld (0e061h),a
	xor a			; And the power-up count and the stage counter, to zero
	ld (0e071h),a
	ld hl,00000h
	ld (0e063h),hl
start_stage:		; Clears the 0xE00 bytes at 0xE100, turns off the 128 sprites, loads the stage data and waits 0x3C frames
	call load_stage_graphics
	ld hl,0e100h		; The 0xE00 bytes from 0xE100 onwards, to zero
	ld de,0e101h
	ld bc,00dffh
	ld (hl),000h
	ldir
	ld hl,0ec80h		; 0xE0 in the 128 Ys of the sprite buffer: none is drawn
	ld de,0ec81h
	ld (hl),0e0h
	ld c,07fh
	ldir
	call load_stage_data
	call stage_difficulty
	ld bc,00010h		; Sixteen bytes from 0x4193 to 0xE200
	ld de,0e200h
	ld hl,04193h
	ldir
	call flag_if_two_players
	ld a,03ch		; 0x3C frames of waiting before starting
	ld (0e10fh),a
	jp start_scroll
flag_if_two_players:		; 0xE130 to one if 0xE06B is not zero
	ld a,(0e06bh)
	or a
	jr z,L_418B
	ld a,001h
L_418B:
	ld (0e130h),a
	ret

; ----------------------------------------------------------------------
; DATA stages_per_round: Only FOUR useful bytes, from 0x418F to 0x4192: 0x03,
;   0x04, 0x05 and 0x08. They are indexed by 0x4137 with `ld de,0x418F` +
;   0x4062 and the index is (0xE061 minus 9), so they say which stage comes
;   after 9, 10, 11 and 12. There is NO fifth entry: the byte at 0x4193 is
;   already the first of the SIXTEEN that 0x416D copies to 0xE200 (the record
;   the ship starts with).
stages_per_round:
	defb 03h,04h,05h,08h
	defb 01h,00h,00h,00h
	defb 4Ah,00h,50h,00h
	defb 08h,00h,08h,00h
	defb 02h,00h,00h,00h
stage_difficulty:		; 0xE111 comes from the round times four plus the stage, capped at 0x0F; past the ninth, from 0xE066
	ld a,(0e061h)
	cp 009h			; From the ninth onwards, the difficulty is set by 0xE066
	jr nc,L_41BC
	dec a
	ld b,a
	ld a,(0e06ah)		; The round times four
	add a,a
	add a,a
	add a,b
	cp 00fh			; Capped at 0x0F
	jr c,L_41B8
	ld a,00fh
L_41B8:
	ld (0e111h),a
	ret
L_41BC:
	ld a,(0e066h)
	ld (0e111h),a
	ret
load_stage_data:		; Six bytes from the table at 0x4499 to 0xE101 (where the map script starts and ends), and from the one at 0x4212 the checkpoint the counter is compared with
	ld a,(0e061h)
	add a,a			; Times six: six bytes per stage
	ld c,a
	add a,a
	add a,c
	ld hl,04499h
	call add_a_to_hl
	ld de,0e101h		; To 0xE101
	ld bc,00006h
	ldir
	ld a,(0e061h)
	ld hl,04212h		; The other table, the checkpoints one
	call get_word
	ld hl,(0e063h)
	rst 20h			; DCOMPR: if you had already passed the checkpoint, it starts there; and if not, at 0x20
	jr nc,set_stage_counters
	ld de,00020h
set_stage_counters:		; Sets the stage's dozen counters to zero, 0xE062 to one and 0xE129 to 0x40
	ld (0e063h),de		; The distance the stage starts with
	xor a
	ld (0e150h),a
	ld (0e151h),a
	ld (0e065h),a
	ld (0e155h),a
	ld (0e113h),a
	ld (0e10ah),a
	ld (0e044h),a
	ld (0e114h),a
	ld (0e126h),a
	inc a			; 0xE062 to one
	ld (0e062h),a
	ld a,040h		; 0xE129 starts at 0x40
	ld (0e129h),a
	ret

; ----------------------------------------------------------------------
; DATA checkpoints (part): ELEVEN words, from 0x4214 to 0x422A: the CHECKPOINT
;   of each stage. It is read by 0x41DB with `ld hl,0x4212` and 0x47AE, which
;   adds the stage TWICE, so stage 1 reads the one at 0x4214 and stage 11 the
;   one at 0x4228. When setting up the stage, 0x41E1 compares the distance
;   already covered with this number; if you had passed it, the stage restarts
;   right there, and if not, at 0x20. They are 0xF8, 0x100, 0xF2, 0x100,
;   0x100, 0x100, 0xF8, 0x100, 0x100, 0x100 and 0x100. NOTE: STAGE 12 RUNS OFF
;   THE TABLE. Its read lands at 0x422A, which are the first two bytes of the
;   `call 0x58BA` at 0x422A, and gives it 0xBACD = 47821; since the distance
;   never gets anywhere near that, stage 12 always starts at 0x20.
checkpoints_4214:
	defw 00F8h,0100h
	defw 00F2h,0100h
	defw 0100h,0100h
	defw 00F8h,0100h
	defw 0100h,0100h
	defw 0100h

	end

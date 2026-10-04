; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - boss.asm
; ============================================================================

	include "variables.inc"

	public blow_up_core,core_enters,core_waits,draw_boss,end_boss,erase_boss
	public mark_boss_dead,next_core_step,stage_5_boss_step,wait_until_nobody_left
	extrn aim_at_ship,aim_both_turrets,load_explosion_graphics,run_five_at_e7a0,run_six_pieces,set_up_background_explosion
	extrn set_up_shot

; ----------------------------------------------------------------------
; THE END-OF-STAGE BOSS, STEP BY STEP
; 0xE151 says there is a boss and 0xE152 which step it is on; within the
; step, 0xE190 keeps the core's count and 0xE153 the frames left. There
; are five steps: wait for the screen to be empty, bring the core down,
; wait for it to be killed, and the two exits.
; ----------------------------------------------------------------------
wait_until_nobody_left:		; Until the twenty-two slots are empty, the boss does not come in; then it loads its graphics and sets up the first piece
	ld hl,BOSS_TIMER
	dec (hl)
	ret nz
	ld hl,OBJECTS		; The twelve slots...
	ld de,00020h
	ld b,00ch
L_7CAA:
	ld a,(hl)
	and a
	jr nz,wait_one_more_frame
	add hl,de
	djnz L_7CAA
	ld hl,ENEMY_SHOTS	; ...and the ten
	ld b,00ah
L_7CB6:
	ld a,(hl)
	and a
	jr nz,wait_one_more_frame
	add hl,de
	djnz L_7CB6
	call load_explosion_graphics	; The explosion graphics
	xor a
	ld (CORE_DEAD),a	; To zero: the core is still alive
	ld de,BOSS_PIECES	; The thirteen bytes from 0x7ED9: the first piece
	ld hl,07ed9h
	ld bc,0000dh
	ldir
	ld a,03ch		; 0x3C frames
	ld (BOSS_TIMER),a
next_core_step:		; 0xE190 + 1
	ld hl,BOSS_PHASE
	inc (hl)
	ret
wait_one_more_frame:		; Something is still alive: look again on the next frame
	ld a,001h
	ld (BOSS_TIMER),a
	ret
core_enters:		; Every eight frames moves it eight points to the left until column 0x98, and there it stays 0x2D0 frames
	ld a,(FRAME_COUNT)	; One frame in eight
	and 007h
	ret nz
	ld hl,BOSS_PIECES+5
	ld a,(hl)
	sub 008h		; Eight points to the left
	ld (hl),a
	cp 098h			; Until column 0x98
	ret nz
	ld hl,002d0h		; 0x2D0 frames standing still
	ld (BOSS_TIMER),hl
	ld a,001h
	ld (BOSS_PIECES+6),a
	jr next_core_step
core_waits:		; While it lives, it shoots and changes face according to the frames it has left: at 0x258 one, at 0x78 another
	ld a,(CORE_DEAD)	; Set: the core is already dead
	and a
	jr nz,core_leaves
	call move_boss
	call core_shoots
	ld hl,(BOSS_TIMER)
	dec hl
	ld (BOSS_TIMER),hl
	ld de,00258h		; With 0x258 frames to go, the first face
	rst 20h
	jr nz,L_7D1A
	xor a
	ld (BOSS_PIECES+6),a
	ret
L_7D1A:
	ld de,00078h		; And with 0x78 to go, the second
	rst 20h
	jr nz,L_7D26
	ld a,001h
	ld (BOSS_PIECES+6),a
	ret
L_7D26:
	ld a,l			; With the count used up, the core leaves
	or h
	ret nz
core_leaves:		; Face 2, 0x28 frames and on to the next step
	ld a,002h
	ld (BOSS_PIECES+6),a
	ld a,028h		; 0x28 frames
	ld (BOSS_TIMER),a
	jr next_core_step
blow_up_core:		; Erases it, sets up the explosion, plays sound 0x3B and, if it was alive, collects 0x100
	ld hl,BOSS_TIMER
	dec (hl)		; 0xE153: the frames left
	ret nz
	xor a
	ld (BOSS_PIECES),a	; To zero: the piece goes
	ld de,01808h
	call boss_cell
	ex de,hl
	call set_up_background_explosion
	ld a,03bh		; Sound 0x3B
	call 049deh
	ld de,00100h		; A hundred points, and only if the core was still alive
	ld a,(CORE_DEAD)
	and a
	call nz,055b4h
	ld a,078h		; 0x78 frames
	ld (BOSS_TIMER),a	; 0x78 frames
	jp next_core_step
end_boss:		; When the count runs out, 0xE150 to one: the stage can go on
	ld hl,BOSS_TIMER
	dec (hl)
	ret nz
mark_boss_dead:		; 0xE150 to one
	ld a,001h
	ld (BOSS_DONE),a
	ret
core_shoots:		; From the second loop onwards: every six of the player's shots it releases an aimed one, with speed 0x60
	ld a,(LOOP_NUMBER)	; Only from the second loop onwards
	and a
	ret z
	ld hl,BOSS_PIECES+0Ch	; The ones it still has to release
	ld a,(hl)
	and a
	jr nz,L_7D7F
	ld a,(CONTROLLER_NEW)	; Bit 4 of what was just pressed: the player's fire
	and 010h
	ret z
	ld (hl),006h		; Six in one go
	ret
L_7D7F:
	dec (hl)
	ld a,(BOSS_PIECES+3)	; Comes out 0x1C below the core and eight to its right
	add a,01ch
	ld e,a
	ld a,(BOSS_PIECES+5)
	add a,008h
	ld d,a
	ld a,060h		; Speed 0x60
	ld (ENEMY_SHOT_SPEED),a
	push de
	call aim_at_ship
	pop de
	ld hl,ENEMY_SHOTS+4*OBJECT_SIZE	; The six slots
	ld b,006h
L_7D9B:
	ld a,(hl)
	and a
	jp z,set_up_shot
	ld a,020h		; Thirty-two bytes: the next one
	call 0405dh		; Thirty-two bytes: the next slot
	djnz L_7D9B
	ret
release_four_shots:		; Sets up the four slots at 0xE500 with the four shots, each with its offset from the table at 0x7E03
	ld a,(BOSS_PIECES+3)
	ld e,a
	ld a,(BOSS_PIECES+5)
	ld d,a
	exx
	ld hl,07e03h		; The table at 0x7E03: where each one comes out
	exx
	ld hl,ENEMY_SHOTS
	ld b,004h		; Four shots
set_up_one_of_four:		; Fills the slot and gives it the speed, which comes from the difficulty: the higher, the faster
	push de
	ld (hl),001h		; The slot is taken
	inc l			; Four bytes further on
	inc l
	inc l
	inc l
	exx
	ld a,(hl)
	inc hl
	exx
	add a,e			; The starting X...
	ld (hl),a		; The X, and the byte next to it to zero
	inc l
	ld (hl),000h
	inc l
	exx
	ld a,(hl)
	inc hl
	exx
	add a,d			; ...and the Y
	ld (hl),a
	inc l
	xor a			; The counters, to zero
	ld (hl),a
	inc l
	ld (hl),a
	inc l
	push hl
	ld a,(DIFFICULTY)	; The difficulty, negated
	inc a
	neg
	ld l,a
	ld h,0ffh
	add hl,hl		; Times 0x20
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld de,0fa00h		; Added to 0xFA00: the speed
	add hl,de
	ex de,hl
	pop hl
	ld (hl),e
	inc l
	ld (hl),d
	inc l
	ld a,b			; Bit 0 of the counter: one of two drawings
	and 001h
	add a,002h
	ld (hl),a
	ld de,00010h		; Sixteen bytes further on, the mark
	add hl,de
	ld (hl),001h		; And the alive mark
	ld e,005h		; Five more bytes: the next slot
	add hl,de
	pop de
	djnz set_up_one_of_four
	ret

; ----------------------------------------------------------------------
; DATA table_7E03: Eight bytes read by 0x7DB1.
table_7E03:
	defb 00h,10h
	defb 10h,0F0h
	defb 28h,0F0h
	defb 38h,10h
move_boss:		; Chooses a drawing with the R register, decides which way to go depending on where the ship is, and keeps taking steps
	ld hl,BOSS_PIECES+1	; Whether it is already moving
	ld a,(hl)
	and a
	jr nz,boss_takes_step
	inc (hl)
	ld a,r			; The R register: one of four drawings
	and 003h
	ld (BOSS_PIECES+0Bh),a
	ld a,(BOSS_PIECES+3)	; 0x18 to the right of the boss
	add a,018h
	ld c,a
	ld a,(SHIP_ROW)		; The ship's row: that is the way it goes
	cp c
	ld a,000h
	jr c,L_7E29
	inc a
L_7E29:
	ld (BOSS_PIECES+7),a
	jp release_four_shots
boss_takes_step:		; Every so many frames (fewer the harder it is) it moves eight points, and after eleven steps it stops
	ld hl,BOSS_PIECES+0Ah	; The frames left until the next step
	dec (hl)
	ret nz
	ld a,(DIFFICULTY)	; The difficulty: five, four or three frames per step
	ld c,005h		; The difficulty sets the frames per step
	cp 004h
	jr c,L_7E43
	dec c
	cp 00ah
	jr c,L_7E43
	dec c
L_7E43:
	ld (hl),c		; And it is noted for the next step
	inc l
	inc (hl)
	ld a,(hl)
	cp 00bh			; Eleven steps and it stops
	jr nz,L_7E50
	xor a
	ld (BOSS_PIECES+1),a
	ret
L_7E50:
	ld a,(BOSS_PIECES+7)	; 0xE787 says which way
	ld b,a
	ld c,0f8h		; Eight to the left or to the right
	and a			; Eight to one side or the other
	jr z,L_7E5B
	ld c,008h
L_7E5B:
	ld hl,BOSS_PIECES+3
	ld a,(hl)
	add a,c
	ld (hl),a
	ld c,001h
	cp 010h			; Below X 0x10 it turns around
	jr c,L_7E6B
	dec c
	cp 078h			; And above 0x78, too
	ret c			; It notes which way it is going
L_7E6B:
	ld a,c			; And the side is saved
	ld (BOSS_PIECES+7),a
	ret
draw_boss:		; Paints the three parts: the body of 0x0B by 8 characters, the eye and the mouth, each with its own table
	ld a,(BOSS_PIECES)
	dec a
	ret nz
	ld de,00000h
	call boss_cell
	jr c,L_7E86
	ld bc,00b08h		; 0x0B wide by 8 high: the body
	ld de,07ee6h
	call 0490ch
L_7E86:
	ld de,00818h		; The eye, eight to the right and 0x18 lower
	call boss_cell
	jr c,L_7EA3
	ld de,07f3eh
	ld a,(BOSS_PIECES+9)	; 0xE789 chooses one of the eye drawings
	rra
	and 00eh
	ld c,a
	add a,a
	add a,c			; Times three: three characters per drawing
	call 04062h
	ld bc,00302h		; Three wide by two high
	call 0490ch
L_7EA3:
	ld de,02018h		; And the mouth, 0x20 to the right
	call boss_cell
	ret c
	ld de,07f62h
	ld a,(BOSS_PIECES+6)	; The face that is due
	add a,a
	ld c,a
	add a,a
	add a,c
	call 04062h
	ld bc,00302h
	jp 0490ch
boss_cell:		; The boss's position plus the offset that DE brings
	ld a,(BOSS_PIECES+3)	; The boss's row (0xE783) and its column (0xE785), plus whatever DE brings
	add a,e
	ld l,a
	ld a,(BOSS_PIECES+5)
	add a,d
	ld h,a
	ret
erase_boss:		; Erases the 0x0B by 8 rectangle of the body
	ld a,(BOSS_PIECES)	; Only at one
	dec a
	ret nz
	ld de,00000h
	call boss_cell
	ld bc,00b08h
	jp 048f7h

; ----------------------------------------------------------------------
; DATA boss_first_piece: The thirteen bytes that 0x7CC7 copies to 0xE780 when
;   the boss comes in: the starting record of its first piece.
boss_first_piece:
	defb 01h,00h,00h,40h,00h,0F8h,01h,00h,10h,16h,01h,00h,00h

; ----------------------------------------------------------------------
; DATA body_drawing: The 88 characters of the boss's body, 0x0B wide by 8
;   high, which 0x7E80 copies to the map with 0x490C.
body_drawing:
	defb 00h,00h,00h,00h,0A3h,44h,45h,46h,47h,48h,00h
	defb 00h,00h,0A4h,49h,4Ah,4Bh,0A7h,0A8h,0A9h,4Ch,4Dh
	defb 0A5h,4Eh,4Fh,50h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh,51h
	defb 0A6h,00h,00h,00h,00h,00h,00h,0B4h,0B5h,0B6h,52h
	defb 0C4h,00h,00h,00h,00h,00h,00h,0D2h,0D3h,0D4h,64h
	defb 0C3h,60h,61h,62h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,63h
	defb 00h,00h,0C2h,5Bh,5Ch,5Dh,0C5h,0C6h,0C7h,5Eh,5Fh
	defb 00h,00h,00h,00h,0C1h,56h,57h,58h,59h,5Ah,00h

; ----------------------------------------------------------------------
; DATA table_7F3E: Thirty-six bytes read by 0x7E8E.
table_7F3E:
	defb 55h,55h,0BAh,67h,67h,0D8h,55h,55h	; "UU.gg.UU"
	defb 0B0h,67h,67h,0CEh,55h,54h,0B0h,67h
	defb 66h,0CEh,55h,53h,0B0h,67h,65h,0CEh
	defb 54h,53h,0B0h,66h,65h,0CEh,53h,53h	; "TS.fe.SS"
	defb 0B0h,65h,65h,0CEh

; ----------------------------------------------------------------------
; DATA table_7F62: Eighteen bytes read by 0x7EAA.
table_7F62:
	defb 0B7h,0B8h,0B9h,0D5h,0D6h,0D7h,0B1h,0B2h
	defb 0B3h,0CFh,0D0h,0D1h,0BBh,0BCh,0BDh,0D9h
	defb 0DAh,0DBh
stage_5_boss_step:		; Waits for the twelve slots to be empty, leaves 0x40 frames and starts that stage's boss
	ld a,(BOSS_PHASE)
	dec a
	jr z,run_stage_5_boss
	dec a
	jr z,end_stage_5_boss
	ld hl,OBJECTS		; The twelve slots
	ld de,00020h
	ld b,00ch
L_7F85:
	ld a,(hl)
	and a
	ret nz
	add hl,de
	djnz L_7F85
	ld a,040h		; 0x40 frames
	ld (BOSS_TIMER),a
	ld hl,00000h
	ld (BOSS5_SCRIPT),hl
	ld hl,(DISTANCE)	; Past distance 0xFF, it starts at step 2
	ld de,000ffh		; Distance 0xFF
	rst 20h
	jr c,L_7FA4
	ld a,002h
	ld (BOSS5_SCRIPT),a
L_7FA4:
	ld hl,BOSS_PHASE
	inc (hl)
	ret
run_stage_5_boss:		; With bank 10 in place, four of its routines; when 0xE790 and 0xE7C0 switch off, it is over
	di			; Bank 10 at 0xA000
	ld a,00ah		; Bank 10 at 0xA000
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	call start_or_advance
	call aim_both_turrets
	call run_six_pieces
	call run_five_at_e7a0
	di			; Bank 3 put back
	ld a,003h
	ld (0a000h),a
	ld (BANK_A000),a
	ei
	ld a,(BOSS5_MOVING)	; The boss is already moving
	and a
	ret z
	ld a,(BOSS_PIECES+BOSS_PIECE_SIZE)	; Until both cells are zero, it carries on
	ld hl,BOSS_PIECES+4*BOSS_PIECE_SIZE	; And the other
	or (hl)
	ret nz
	jr L_7FA4
end_stage_5_boss:		; 0xE150 to one
	ld a,001h
	ld (BOSS_DONE),a
	ret
start_or_advance:		; Past distance 0x1A0 it switches on 0xE117; if not, every 0xC0 frames it advances the script in 0xE116
	ld hl,(DISTANCE)
	ld de,001a0h		; Distance 0x1A0
	rst 20h
	jr c,L_7FED
	ld a,001h
	ld (BOSS5_MOVING),a
	ret
L_7FED:
	ld hl,BOSS_TIMER	; The frames left
	dec (hl)
	ret nz
	ld (hl),0c0h		; Another 0xC0
	ld hl,BOSS5_SCRIPT
	ld a,(hl)
	inc (hl)
	and 00fh		; Sixteen steps round and round
	ld c,a
	ld b,000h

; ----------------------------------------------------------------------
; THE LAST INSTRUCTION IS SPLIT BETWEEN BANK 1 AND BANK 2
; Its first two bytes, 21h 41h, are the last two of bank 1 (0x7FFE) and the
; third one, 80h, is the first byte of bank 2 (0x8000): together they are
; `ld hl,0x8041`, and execution carries on at 0x8001 without any jump. It is
; the only place in the cartridge where an instruction is split between two
; banks, and it welds bank 1 to bank 2: it only works with the bank layout
; that INIT sets up. Banks 0 to 3 are linked as one image, so here it can be
; written as the instruction it is.
; ----------------------------------------------------------------------
	ld hl,08041h

; Bank 2 (runs at 0x8000) starts at the third byte of the instruction above.
; Something similar but milder happens at its bottom end: the code falls
; through from 0x9FFF into 0xA000, that is, into bank 3.

; (Falls through into bosses.asm, which the link places right after.)

	end

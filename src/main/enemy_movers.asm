; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - enemy_movers.asm
; ============================================================================

	public enemy_shoots,erase_background_objects,erase_e800_objects,paint_background_objects,paint_background_or_bank3,paint_e800_objects
	public release_background_objects,release_background_objects_on_column,run_four_at_e800,run_object,run_ten_at_e500,set_up_shot
	extrn add_speed,advance_background_script,aim_at_ship,check_falling_pieces_script,clear_rectangle,copy_rectangle
	extrn erase_stage_5_background,object_collides_with_map,paint_stage_5_background,script_entry,spawn_object

; ----------------------------------------------------------------------
; THE ENEMY MOVERS
; This is the bank that moves the enemies. p00:5FFC calls 0x6008 once per
; object, with IX pointing at its slot, and from there it is dispatched by
; type (IX+0) and by the step it is on (IX+1): every enemy is a tiny state
; machine with its frame counter in (IX+4).
; ----------------------------------------------------------------------
run_object:		; Called by p00:5FFC once per object: if the slot is alive, it gives its mover one step
	ld a,(ix+000h)		; First byte at zero: the slot is free
	and a
	ret z
	push ix
	call mover_step
	pop ix
shift_with_scroll:		; On steps with a new column, the object moves eight points to the left; when it goes off the edge, the slot is freed
	ld a,(0e100h)		; Only on the steps that bring in a column
	and a
	ret z
	ld a,(ix+003h)
	sub 008h		; Eight points to the left per step
	jr c,L_6024
	ld (ix+003h),a
	ret
L_6024:
	ld (ix+000h),000h	; And when it goes off, the slot is freed
	ret
mover_step:		; With the screen stopped nothing moves; types 1 and 2 shoot, and from 3 upwards it dispatches by (IX+1)
	ld a,(0e1c0h)		; 0xE1C0 non-zero: the screen is stopped
	and a
	ret nz
	ld a,(ix+000h)		; The type is noted in 0xE123
	ld (0e123h),a
	cp 003h			; From type 3 upwards, the other dispatch
	jr nc,L_6061
	ld a,(ix+007h)
	and a
	ret z
	dec (ix+004h)		; One frame less until the next shot
	ret nz
	ld (ix+004h),008h	; Eight frames between one enemy and the next
	dec (ix+007h)
	ld a,(ix+002h)
	ld c,0f8h		; Bit 0 of the type: 1 releases them from the top and 2 from the bottom
	bit 0,(ix+000h)
	jr nz,L_6055
	ld c,018h
L_6055:
	add a,c
	ld e,a
	ld d,(ix+003h)
	ld c,000h
	ld a,007h		; Type 7: the enemy that comes out of the hatch
	jp spawn_object
L_6061:
	ld a,(ix+001h)
	dec a
	jr z,waiting_mover
	dec a
	jr z,next_step
	dec a
	jp z,die_when_exhausted
	ld a,(0e206h)		; The ship's X and Y, which the movers need
	ld b,a
	ld a,(0e204h)
	ld c,a
	ld a,(ix+000h)
	sub 003h		; Minus three: types 3, 4, 5 and 6
	call 04067h

; ----------------------------------------------------------------------
; DATA dispatcher_table_607B: Four words stuck right after the `call 0x4067`
;   at 0x607B (0x610E, 0x6131, 0x614A, 0x615B). The index is (IX+0) minus
;   three.
dispatcher_table_607B:
	defw check_if_passing_in_front	; 0
	defw check_if_passing_below	; 1
	defw check_if_in_front	; 2
	defw check_if_already_passed	; 3
waiting_mover:		; Counts down and, every four frames, releases a type 0x0E shot from the enemy's position
	ld a,(ix+003h)
	cp 018h			; Less than 0x18 from the left edge it no longer shoots
	jp c,L_6102
	dec (ix+004h)
	jr nz,set_drawing
	ld (ix+004h),004h	; Four frames between one shot and the next
	dec (ix+007h)
	jr z,end_burst
	ld a,(ix+000h)
	ld hl,060c1h		; The table at 0x60C1: where the shot comes out for each type
	call 047aeh		; The table at 0x60C1
	ld a,(ix+002h)
	add a,e
	ld e,a
	ld a,(ix+003h)
	add a,d
	ret c
	ld d,a
	ld c,000h
	ld a,00eh		; Type 0x0E: the aimed shot
	jp spawn_object
end_burst:		; The shots have run out: the wait until the next burst comes from the difficulty
	dec (ix+001h)
	ld a,(0e111h)		; 0xE111 times two, subtracted from 0x40: the higher the difficulty, the shorter the wait
	add a,a
	neg
	add a,040h
	ld (ix+004h),a
	jr L_6102

; ----------------------------------------------------------------------
; DATA offsets_60C1: Eight bytes that 0x609F indexes with the base 0x60C1,
;   which falls inside the code.
offsets_60C1:
	defb 10h,14h,10h,34h,18h,34h,0F8h,30h
next_step:		; Moves the object by what the table at 0x60E7 says and leaves it 0x0D frames
	inc (ix+001h)
	ld a,(ix+000h)
	add a,a			; Times two: two bytes per type
	ld hl,060e7h
	call 0405dh
	ld a,(hl)
	add a,(ix+002h)
	ld (ix+002h),a
	inc hl
	ld a,(hl)
	ld (ix+006h),a
	ld (ix+004h),00dh	; Thirteen frames
	ret

; ----------------------------------------------------------------------
; DATA offsets_60E7: Eight bytes that 0x60D6 indexes with the base 0x60E7.
offsets_60E7:
	defb 18h,0Ch,18h,0Ch,00h,0Dh,00h,0Ch
die_when_exhausted:		; When the counter reaches zero, the slot is freed
	dec (ix+004h)
	ret nz
	ld (ix+000h),000h
	ret
set_drawing:		; The drawing comes from the type times two, plus one if the variant is asked for
	ld c,001h
	jr L_6104
L_6102:
	ld c,000h
L_6104:
	ld a,(ix+000h)		; The type minus one, times two
	dec a
	add a,a
	add a,c
	ld (ix+006h),a
	ret
check_if_passing_in_front:		; Waits until the ship is less than 0x40 away in X and 0x14 in Y, and then starts
	dec (ix+004h)
	ret nz
	ld (ix+004h),001h
	ld a,(ix+002h)		; 0x40 of margin in X
	add a,040h
	cp c
	ret c
	ld a,(ix+003h)		; And 0x14 in Y
	add a,014h
	cp b
	ret c
start_burst:		; 0x10 frames and 0x10 shots, and on to the next step
	ld (ix+004h),010h
	ld (ix+007h),010h
	inc (ix+001h)
	jr set_drawing
check_if_passing_below:		; The same but looking 0x34 below
	dec (ix+004h)		; One frame less
	ret nz
	ld (ix+004h),001h
	ld a,(ix+002h)
	add a,040h		; 0x40 of margin in X
	cp c
	ret c
	ld a,(ix+003h)
	sub 034h		; And 0x34 below
	ret c
	cp b
	ret nc
	jr start_burst
check_if_in_front:		; Only looks at X, with 0x18 of margin
	dec (ix+004h)		; One frame less
	ret nz
	ld (ix+004h),001h
	ld a,(ix+002h)
	add a,018h		; 0x18 of margin in X
	cp c
	ret nc
	jr start_burst
check_if_already_passed:		; Starts as soon as the ship is left behind
	dec (ix+004h)		; One frame less
	ret nz
	ld (ix+004h),001h
	ld a,(ix+002h)
	cp c
	ret c
	jr start_burst
run_four_at_e800:		; The four objects at 0xE800, eight bytes each
	ld ix,0e800h
	ld b,004h		; Four objects
L_6170:
	ld a,(ix+000h)
	and a
	call nz,e800_object_step
	ld de,00008h		; Eight bytes per object
	add ix,de
	djnz L_6170
	ret

; ----------------------------------------------------------------------
; DATA dead_call: Three bytes that are `call 0x6014`. Nobody reaches 0x617F:
;   the instruction before it ends in `ret` and no table points here.
dead_call:		; `call 0x6014`. Nobody gets here.
	defb 0CDh,14h,60h
e800_object_step:		; Moves with the scroll and, every four frames, uses up one unit of (IX+6); when it runs out, it switches off
	call shift_with_scroll
	dec (ix+001h)
	ret nz
	ld (ix+001h),004h	; Four frames per unit
	dec (ix+006h)		; Byte 6 is used up one at a time
	ret p			; Four frames per unit
	ld (ix+000h),000h
	ret
erase_e800_objects:		; Walks the four objects at 0xE800 erasing their drawing from the screen
	xor a
	jr L_619B
paint_e800_objects:		; The same, painting them
	ld a,0ffh
L_619B:
	ld ix,0e800h
	ld b,004h
	jr walk_e700_objects
paint_background_objects:		; In stages 3 and 5 it does nothing; in the rest, it paints the objects at 0xE700
	ld a,(0e061h)		; Stages 3 and 5 have their own mover
	cp 003h
	ret z
	cp 005h
	ret z
	xor a
	jr L_61B9
paint_background_or_bank3:		; Stage 5 is handled by bank 3; the rest paint eight objects if it is stage 3, and two if not
	ld a,(0e061h)
	cp 005h
	jp z,paint_stage_5_background	; Stage 5, to bank 3
	ld a,0ffh
L_61B9:
	ex af,af'
	ld ix,0e700h
	ld a,(0e061h)
	cp 003h			; Stage 3 carries eight objects; the rest, two
	ld b,008h
	jr z,L_61C9
	ld b,002h
L_61C9:
	ex af,af'
walk_e700_objects:		; 0xEC00 says whether to paint or erase, and then it goes through the B objects
	ld (0ec00h),a		; 0xEC00 at zero erases, and at 0xFF paints
L_61CD:
	push bc
	call draw_background_object
	pop bc
	ld de,00008h		; Eight bytes per object
	add ix,de
	djnz L_61CD
	ret
erase_background_objects:		; The same but erasing; stage 5 is also handled by bank 3
	ld a,(0e061h)		; Stage 5 is handled by bank 3
	cp 005h			; Stage 5 is handled by bank 3
	jp z,erase_stage_5_background
	xor a
	ld (0ec00h),a
	jr paint_rectangle
draw_background_object:		; Takes the object's rectangle of characters from whichever table applies and paints or erases it
	ld a,(ix+000h)
	and a
	ret z
	ld c,(ix+006h)
	cp 020h			; Type 0x20 uses the table at 0x633A
	ld hl,0633ah
	jr z,L_6209
	ld hl,06370h		; The rest, the one at 0x6370
	ld a,(0e061h)
	cp 002h			; And in stage 2, from drawing 2 upwards it skips twelve
	jr nz,L_6209
	ld a,c
	cp 002h
	jr c,L_6209
	add a,00ch
	ld c,a
L_6209:
	ld a,c
	call 047aeh
paint_rectangle:		; Four by four characters at the object's cell: 0x48F7 erases them and 0x490C copies them
	ld bc,00404h		; Four wide by four high
	ld l,(ix+002h)		; The cell where it lands
	ld h,(ix+003h)
	ld a,(ix+000h)
	sub 003h		; Types 3, 4, 5 and 6 carry chunks of several sizes
	cp 004h
	jr c,paint_in_chunks
	ld a,(0ec00h)		; 0xEC00 decides: erase or copy
	and a
	jp z,clear_rectangle
	jp copy_rectangle
paint_in_chunks:		; The big types are painted in chunks: the table at 0x6283 gives the width, the height and the offset of each one
	ld a,(ix+006h)
	ld c,a
	add a,a			; Times three: three bytes per chunk
	add a,c
	push hl
	ld hl,06283h
	call 0405dh
	ld c,(hl)		; The width, the height and where it lands
	inc hl
	ld b,(hl)
	inc hl
	ld a,(hl)
	pop hl
	and a			; Bit 7 of the third byte shifts the chunk by half a cell
	jp p,L_6246
	ex af,af'
	ld a,008h
	add a,l
	ld l,a
	ex af,af'
L_6246:
	and 07fh		; Bit 7 of the third byte shifts the chunk by half a cell
	add a,h
	ld h,a
	jr c,paint_wide_chunk
	ld a,(0ec00h)
	and a
	jp z,048f7h
	call 0490ch
paint_wide_chunk:		; A ten by one rectangle, with the origin taken from the two tables at 0x6273 and 0x64D4
	ld a,(ix+006h)
	add a,a			; Times two: two bytes per drawing
	ld de,06273h		; The table at 0x6273
	call 04062h
	ld a,(de)
	add a,(ix+002h)
	ld l,a
	ld h,(ix+003h)
	inc de
	ld a,(de)
	ld de,064d4h
	add a,a			; Times ten: ten characters per row
	ld c,a
	add a,a
	add a,a
	add a,c
	call 04062h
	ld bc,00a01h		; Ten wide by one high
	jp 0490ch

; ----------------------------------------------------------------------
; DATA table_6273: Eight bytes that 0x625A indexes with the base 0x6273.
table_6273:
	defb 28h,00h,28h,00h,28h,00h,28h,00h

; ----------------------------------------------------------------------
; DATA table_6283: Forty-two bytes read by 0x6230.
table_6283:
	defb 00h,01h,00h,01h,10h,02h,10h,02h
	defb 10h,00h,00h,03h,05h,07h,10h,05h
	defb 07h,10h,05h,07h,08h,05h,07h,08h
	defb 02h,08h,90h,02h,08h,90h,02h,08h
	defb 10h,02h,08h,10h,02h,06h,10h,02h
	defb 06h,90h
release_background_objects:		; Keeps taking out background objects while the script has rows for this distance
	ld a,(0e061h)
	cp 005h			; Stage 5 is handled by bank 3
	jp z,advance_background_script
	call check_background_script
	jr z,release_background_objects
	ret c
	ld hl,0e109h
	inc (hl)		; 0xE109 moves on to the next row
	jr release_background_objects
release_background_objects_on_column:		; The same, but only on the steps that bring in a new column
	ld a,(0e100h)		; Only on the steps with a column
	and a
	ret z
	ld a,(0e061h)
	cp 005h
	jp z,check_falling_pieces_script
	ld a,0f8h		; 0xF8 in 0xEC04
	ld (0ec04h),a
L_62D3:
	call check_background_script
	jr z,L_62D3
	ret
check_background_script:		; Checks the script at 0x64FA with the bank 2 routine and, when due, sets up the object in the first free slot at 0xE700
	ld a,(0e109h)
	ld hl,064fah
	call script_entry	; The bank 2 routine that compares the distance
	ret nz
	ld hl,0e109h
	inc (hl)
	ld hl,0e700h		; The eight slots at 0xE700
	ld b,008h
	ld de,00008h		; Eight bytes per slot
	xor a
L_62F0:
	cp (hl)			; The first free slot
	jr z,set_up_background_object	; Eight bytes per slot
	add hl,de		; Eight bytes: the next slot
	djnz L_62F0
	xor a
	ret
set_up_background_object:		; Fills the slot: type, counter, X times eight, Y, and the two bytes that depend on whether it comes from the top or the bottom
	call background_object_type
	ld (hl),a
	push af
	inc l
	ld (hl),000h
	inc l
	ld a,c
	and 01fh		; The low five bits times eight: the column
	add a,a
	add a,a
	add a,a
	ld (hl),a
	inc l
	ld a,(0ec04h)		; The row, from 0xEC04
	ld (hl),a
	inc l
	cp 0f8h			; With row 0xF8 it sets 0x18, and otherwise 0xFF
	ld a,018h
	jr z,L_6316
	ld a,0ffh
L_6316:
	ld (hl),a		; 0xF8 or 0xFF depending on where it comes from
	inc l
	ld (hl),00fh		; Fifteen
	inc l			; 0xE1FF to zero
	pop af			; 0xE109: which script row it is on
	dec a
	add a,a
	ld (hl),a
	inc l
	ld (hl),006h
	xor a
	ret
background_object_type:		; In stage 3 the type comes from another calculation; in the rest, bit 7 chooses between 1 and 2
	ld a,(0e061h)
	cp 003h			; Stage 3 goes another way
	jr z,L_6332
	ld a,001h
	bit 7,c			; Bit 7: one of the two types
	ret z
	inc a
	ret
L_6332:
	ld a,c			; Two bits of C: one of four types
	rlca
	rlca
	and 003h
	add a,003h
	ret

; ----------------------------------------------------------------------
; DATA table_633A: Three words (0x6340, 0x6350, 0x6360) read by 0x61F2.
table_633A:
	defw 6340h,6350h	; -> DATA_formations 0x6350
	defw 6360h

; ----------------------------------------------------------------------
; DATA formations: Forty-eight bytes the table above points to, and which
;   p00:4B9F also asks for with `ld de,0x6340`.
formations:
	defb 00h,00h,00h,00h,00h,9Dh,9Eh,00h,00h,9Fh,0A0h,00h,00h,00h,00h,00h
	defb 00h,00h,93h,94h,00h,95h,96h,97h,00h,98h,99h,9Ah,00h,9Bh,9Ch,00h
	defb 83h,84h,85h,86h,87h,88h,89h,8Ah,8Bh,8Ch,8Dh,8Eh,8Fh,90h,91h,92h

; ----------------------------------------------------------------------
; DATA trajectories: What 0x61F7 reads with `ld hl,0x6370`, in one run.
trajectories:
	defb 0B0h,63h,0C0h,63h,90h,63h,0A0h,63h,13h,64h,0F0h,63h,59h,64h,36h,64h
	defb 8Ch,64h,7Ch,64h,0ACh,64h,9Ch,64h,0BCh,64h,0C8h,64h,0D0h,63h,0E0h,63h
	defb 66h,67h,6Ch,6Bh,64h,65h,6Ah,69h,63h,00h,00h,68h,7Fh,00h,00h,80h
	defb 70h,71h,76h,75h,6Eh,6Fh,74h,73h,6Dh,00h,00h,72h,81h,00h,00h,82h
	defb 7Fh,00h,00h,80h,63h,00h,00h,68h,64h,65h,6Ah,69h,66h,67h,6Ch,6Bh
	defb 81h,00h,00h,82h,6Dh,00h,00h,72h,6Eh,6Fh,74h,73h,70h,71h,76h,75h
	defb 53h,54h,59h,58h,51h,52h,57h,56h,50h,00h,00h,55h,0A6h,00h,00h,0A7h
	defb 5Dh,5Eh,33h,62h,5Bh,5Ch,61h,60h,5Ah,00h,00h,5Fh,0A8h,00h,00h,0A9h
	defb 00h,00h,00h,00h,0D2h,44h,0D3h,00h,00h,0D4h,45h,0D6h,46h,0D5h,00h,00h
	defb 47h,0D7h,0D8h,48h,00h,00h,00h,4Ah,0D9h,49h,00h,00h,4Bh,4Ch,0DAh,4Dh
	defb 00h,00h,00h,00h,00h,00h,00h,0D2h,44h,0D3h,00h,00h,0D4h,45h,0D6h,46h
	defb 0D5h,00h,00h,47h,0D7h,0D8h,48h,00h,00h,4Eh,0DBh,0D9h,49h,00h,00h,50h
	defb 4Fh,0DAh,4Dh,00h,00h,00h,0BDh,51h,0BCh,00h,00h,00h,00h,0BFh,53h,0C0h
	defb 52h,0BEh,00h,00h,00h,55h,0C2h,0C1h,54h,00h,00h,00h,00h,56h,0C3h,57h
	defb 00h,00h,00h,00h,00h,5Ah,0C4h,59h,58h,0BDh,51h,0BCh,00h,00h,00h,00h
	defb 0BFh,53h,0C0h,52h,0BEh,00h,00h,00h,55h,0C2h,0C1h,54h,00h,00h,00h,00h
	defb 56h,0C3h,0C5h,5Bh,00h,00h,00h,00h,5Ah,0C4h,5Ch,5Dh,32h,33h,34h,22h
	defb 23h,35h,36h,21h,00h,1Dh,1Eh,2Fh,30h,1Fh,31h,20h,32h,33h,34h,22h
	defb 23h,35h,36h,21h,00h,1Dh,1Eh,2Fh,30h,37h,38h,20h,00h,0DFh,0E0h,67h
	defb 68h,0E1h,69h,0E2h,6Ah,6Bh,6Ch,0E4h,0E5h,6Dh,6Eh,0E3h,00h,0DFh,0E0h,67h
	defb 68h,6Fh,70h,0E2h,6Ah,6Bh,6Ch,0E4h,0E5h,6Dh,6Eh,0E3h,00h,00h,0DCh,0DDh
	defb 00h,00h,5Eh,5Fh,60h,61h,62h,0DEh,26h,27h,28h,29h,2Ah,1Ch,00h,00h
	defb 1Ah,1Bh,00h,00h

; ----------------------------------------------------------------------
; DATA table_64D4: Thirty-eight bytes read by 0x626A.
table_64D4:
	defb 72h,73h,74h,75h,76h,0A1h,0A2h,0A3h
	defb 0A4h,0A5h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
	defb 39h,41h,42h,43h,72h,73h,74h,75h	; "9ABCrstu"
	defb 76h,0A1h,71h,0A3h,0A4h,0A5h,3Ah,3Bh
	defb 3Ch,3Dh,3Eh,3Fh,2Bh,2Ch

; ----------------------------------------------------------------------
; DATA table_64FA: What 0x62DC reads with `ld hl,0x64FA`.
table_64FA:
	defb 2Dh,2Eh,12h,65h,26h,65h,34h,65h,0BAh,65h,0C6h,65h,0C8h,65h,0CAh,65h
	defb 0D2h,65h,0DAh,65h,0DAh,65h,0DAh,65h,0B4h,00h,10h,0D8h,00h,10h,10h,01h
	defb 81h,28h,01h,10h,40h,01h,81h,5Ch,01h,10h,0FFh,0FFh,0B8h,00h,8Eh,0E4h
	defb 00h,0Bh,1Ch,01h,0Ch,38h,01h,8Eh,0FFh,0FFh,80h,00h,04h,80h,00h,10h
	defb 90h,00h,08h,9Eh,00h,8Dh,0A4h,00h,07h,0A6h,00h,80h,0A8h,00h,8Dh,0B0h
	defb 00h,80h,0B4h,00h,10h,0BEh,00h,89h,0C0h,00h,03h,0C6h,00h,50h,0CAh,00h
	defb 43h,0CAh,00h,89h,0E2h,00h,88h,0E2h,00h,50h,0E6h,00h,42h,0EEh,00h,88h
	defb 0F0h,00h,10h,0F4h,00h,02h,0FEh,00h,0C5h,0FEh,00h,88h,06h,01h,0D3h,0Ah
	defb 01h,88h,0Ch,01h,02h,10h,01h,0D3h,1Eh,01h,89h,20h,01h,03h,26h,01h
	defb 50h,2Ah,01h,43h,2Ah,01h,89h,42h,01h,88h,42h,01h,50h,46h,01h,42h
	defb 4Eh,01h,88h,50h,01h,10h,54h,01h,02h,60h,01h,47h,60h,01h,8Dh,62h
	defb 01h,80h,6Ah,01h,07h,6Ah,01h,8Dh,74h,01h,10h,76h,01h,80h,0FFh,0FFh
	defb 0A8h,00h,81h,0BCh,00h,10h,02h,01h,10h,90h,01h,81h,0FFh,0FFh,0FFh,0FFh
	defb 86h,00h,0Eh,1Eh,01h,0Eh,0FFh,0FFh,29h,01h,83h,33h,01h,83h,0FFh,0FFh
	defb 0FFh,0FFh
run_ten_at_e500:		; The ten objects at 0xE500: adds their speed to them, checks whether they collide and switches off the ones that go off screen
	ld ix,0e500h
	ld b,00ah		; Ten objects
L_65E2:
	ld a,(ix+000h)
	and a
	jr z,L_660B
	call add_speed		; Adds their speed to them, and returns whether they are still inside
	jr c,L_65F1
	ld (ix+000h),000h
L_65F1:
	call object_collides_with_map	; And bank 2 checks whether they have collided with anything
	jr c,L_6604
	ld a,(ix+004h)		; Past Y 0xB0 or X 0xF0, they are gone
	cp 0b0h
	jr nc,L_6604
	ld a,(ix+006h)
	cp 0f0h
	jr c,L_660B
L_6604:
	xor a
	ld (ix+000h),a
	ld (ix+01bh),a
L_660B:
	ld de,00020h		; Thirty-two bytes: the next object
	add ix,de
	djnz L_65E2
	ret
enemy_shoots:		; Sets up a shot towards the ship: the speed comes from the difficulty, capped at 0x60
	ld a,(0e1c0h)		; With the screen stopped there is no shooting
	and a
	ret nz
	ld a,e
	add a,008h
	ld e,a
	ld a,(0e111h)		; The difficulty times two plus 0x50...
	add a,a
	add a,050h
	cp 060h			; ...capped at 0x60
	jr c,L_6628		; Capped at 0x60
	ld a,060h
L_6628:
	ld (0e110h),a
	push de
	call aim_at_ship
	pop de
	ld a,(0e115h)
	and a
	ret nz
	ld hl,0e500h		; The ten slots at 0xE500
	ld b,00ah
L_663A:
	ld a,(hl)
	and a
	jr z,set_up_shot
	ld a,020h
	call 0405dh		; Thirty-two bytes: the next one
	djnz L_663A
	ret
set_up_shot:		; Fills the shot's slot with its position and the two speeds that 0x6677 left in 0xEC12 and 0xEC14
	ld a,001h		; 0xE112 to one: there is a new shot
	ld (0e112h),a		; 0xE112 to one: there is a new shot
	ld (hl),a
	inc l
	inc l
	inc l
	xor a			; The counters, to zero
	ld (hl),a
	inc l
	ld (hl),e
	inc l
	ld (hl),a
	inc l
	ld (hl),d
	inc l
	ld de,(0ec12h)		; The vertical speed...
	ld (hl),e
	inc l
	ld (hl),d
	ld de,(0ec14h)		; ...and the horizontal one
	inc l
	ld (hl),e
	inc l
	ld (hl),d
	inc l
	ld (hl),000h		; The pattern and the colour
	inc l
	ld (hl),088h		; Pattern 0x88 and colour 9
	inc l
	ld (hl),009h
	ld de,0000eh		; Fourteen bytes further on, the alive mark
	add hl,de
	ld (hl),001h
	ret

	end

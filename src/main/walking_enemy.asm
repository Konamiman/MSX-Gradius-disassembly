; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - walking_enemy.asm
; ============================================================================

	include "variables.inc"

	public how_far_it_walks,move_type_5

; ----------------------------------------------------------------------
; THE ENEMY THAT WALKS STUCK TO THE TERRAIN
; Type 5 does not fly: it walks on the ground (or on the ceiling,
; depending on where it came in) and for that it carries no height map at
; all. On every step it asks the map what is eight points below its feet:
; if there is wall, it goes up eight; if there is nothing, it goes down
; eight; and it repeats until it fits. With 0xE969 at one it fits in one go
; (when planting itself) and at zero it takes one step per frame, which is
; what gives it its hopping walk.
; ----------------------------------------------------------------------
move_type_5:		; Walks stuck to the terrain until its count runs out; then it plants itself, fires and leaves
	ld a,(ix+001h)		; Byte 1: which step it is on
	dec a
	jr z,type_5_planted
	jp p,type_5_leaving
	call 095a6h		; If it is its turn to move, it leaves
	jr c,type_5_leaves
	dec (ix+002h)		; Byte 2: the frames it has left walking
	jr z,type_5_plants_itself
	call one_step_per_frame	; One terrain step per frame
	jp animate_type_5
type_5_plants_itself:		; Fits itself fully into the terrain, stays 0x5A frames and stops moving forward
	inc (ix+001h)
	ld (ix+002h),05ah	; 0x5A frames planted
	call face_ship
	call fit_fully
	call when_to_fire_again
	ld de,00000h		; No horizontal speed: still
	jp 06cc6h
type_5_leaves:		; Step 2 and two points to the left
	ld (ix+001h),002h
	ld de,0fe00h
	jp 06cc6h
type_5_planted:		; Holds out for the 0x5A frames and then sets off walking towards the ship's column
	call 095a6h
	jr c,type_5_leaves
	dec (ix+002h)		; The frames it has left planted
	jr z,L_AA44
	call fire_if_ship_in_arc
	jp 09251h
L_AA44:
	dec (ix+001h)		; Back to the walking step
	call how_far_it_walks
	ld a,(SHIP_COLUMN)	; The ship's column
	cp (ix+006h)
	ld de,00200h		; Two points towards that side
	jr nc,L_AA58
	ld de,0fe00h
L_AA58:
	jp 06cc6h
type_5_leaving:		; Stays stuck to the terrain while it moves away
	call animate_type_5
	jr one_step_per_frame
fit_fully:		; 0xE969 to one: the terrain is searched until it fits within the same frame
	ld a,001h
	jr L_AA65
one_step_per_frame:		; 0xE969 to zero: only one step of eight points per frame
	xor a
L_AA65:
	ld (WALKER_FIT_FULLY),a
	bit 0,(ix+013h)		; Bit 0 of byte 19: if it came in at the top it walks on the ground, and otherwise on the ceiling
	jr z,find_ceiling
find_floor:		; Checks the map 0x10 below: with no wall it goes down eight, and with wall it goes up until it fits
	ld h,(ix+006h)		; 0x10 below its feet
	ld a,(ix+004h)
	add a,010h
	ld l,a
	call 09897h		; That is where the map is asked
	jr nc,descend_to_floor
climb_until_fit:		; With wall eight points lower, it goes up eight
	ld h,(ix+006h)
	ld a,(ix+004h)
	add a,008h		; Eight below
	ld l,a
	call 09897h
	ret nc
	ld a,(ix+004h)
	sub 008h		; Eight points higher
	ld (ix+004h),a
	ld a,(WALKER_FIT_FULLY)	; At zero, only one step per frame
	or a
	ret z
	jr climb_until_fit
descend_to_floor:		; With nothing below, goes down eight at a time as far as row 0x90
	ld a,(ix+004h)
	cp 090h			; Not below row 0x90
	ret nc
	add a,008h
	ld (ix+004h),a
	ld a,(WALKER_FIT_FULLY)
	or a
	ret z
	jr find_floor
find_ceiling:		; The same dance, but the other way round: it sticks to the top
	ld h,(ix+006h)
	ld l,(ix+004h)
	call 09897h		; That is where the map is asked
	jr nc,climb_to_ceiling
	ld a,(ix+004h)
	add a,008h		; With no ceiling where it is, it goes down eight
	ld (ix+004h),a
	ld a,(WALKER_FIT_FULLY)
	or a
	ret z
	jr find_ceiling
climb_to_ceiling:		; As long as there is room eight higher, it goes up, and never past row 9
	ld h,(ix+006h)		; Eight points above
	ld a,(ix+004h)
	sub 008h
	ld l,a
	call 09897h		; That is where the map is asked
	ret c
	ld a,(ix+004h)
	cp 009h			; Not above row 9
	ret c
	ld a,(ix+004h)
	sub 008h		; Eight points higher
	ld (ix+004h),a
	ld a,(WALKER_FIT_FULLY)
	or a
	ret z
	jr climb_to_ceiling
how_far_it_walks:		; Between 0x2D and 0x4C frames walking, drawn by lot with the R register
	ld a,r			; The R register, the cartridge's coin toss
	and 01fh
	add a,02dh
	ld (ix+002h),a
	ret
when_to_fire_again:		; 0x3C frames minus twice the difficulty
	ld a,(DIFFICULTY)	; The difficulty times two...
	add a,a
	sub 03ch		; ...subtracted from 0x3C
	neg
	ld (ix+010h),a
	ret
fire_if_ship_in_arc:		; When the wait runs out it measures the angle to the ship and only fires if it has the ship in front of it
	dec (ix+010h)		; Byte 16: the frames until the shot
	ret nz
	call when_to_fire_again	; The wait, reloaded
	call face_ship		; And the drawing, towards wherever the ship is
	bit 0,(ix+013h)		; Bit 0 of byte 19: if it walks on the ground...
	jr z,L_AB15
	ld a,(SHIP_ROW)		; ...the ship has to be above it
	cp (ix+004h)
	ret nc
	jr L_AB1C
L_AB15:
	ld a,(SHIP_ROW)		; And if it walks on the ceiling, below it
	cp (ix+004h)
	ret c
L_AB1C:
	ld e,(ix+004h)
	ld d,(ix+006h)
	call 066d5h		; From that comes the angle to the ship, in 0xEC18
	ld a,(SHIP_ANGLE)
	cp 080h			; Folded to half a turn...
	jr c,L_AB2E
	neg
L_AB2E:
	cp 040h			; ...and to a quarter
	jr c,L_AB34
	sub 040h
L_AB34:
	sub 008h		; It only fires if the ship falls within 0x30
	cp 030h
	ret nc
	jp 09239h
animate_type_5:		; Two drawings, one every four frames; the pair depends on whether it is climbing or descending and whether it walks on the ground or on the ceiling
	ld a,(ix+00ah)		; Byte 10: climbing or descending
	or a
	ld hl,0ab58h
	jp p,L_AB48
	inc hl
	inc hl
L_AB48:
	bit 0,(ix+013h)		; And on the ground or on the ceiling: four pairs in all
	jr z,L_AB52
	ld bc,00004h
	add hl,bc
L_AB52:
	ld bc,00302h		; Two drawings, one every four frames
	jp 095d1h

; ----------------------------------------------------------------------
; DATA table_AB58: Eight bytes read by 0xAB40.
table_AB58:
	defb 0F4h,0F8h,0D0h,0D4h,0E8h,0ECh,0DCh,0E0h
face_ship:		; The drawing changes depending on which side of it the ship is
	bit 0,(ix+013h)		; Bit 0 of byte 19: ground or ceiling
	jr z,L_AB76
	ld b,0f0h		; Walking on the ground, 0xF0...
	ld a,(SHIP_COLUMN)
	cp (ix+006h)
	jr nc,L_AB72
	ld b,0e4h		; ...or 0xE4 if the ship is ahead
L_AB72:
	ld (ix+00ch),b
	ret
L_AB76:
	ld b,0fch		; And on the ceiling, 0xFC...
	ld a,(SHIP_COLUMN)
	cp (ix+006h)
	jr nc,L_AB82
	ld b,0d8h		; ...or 0xD8
L_AB82:
	ld (ix+00ch),b
	ret

	end

; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - stage5_background.asm
; ============================================================================

	include "variables.inc"

	public run_stage_5_background
	extrn add_a_to_de,add_a_to_hl,spawn_object

; ----------------------------------------------------------------------
; STAGE 5 HAS ITS OWN BACKGROUND MOVER
; The other eleven stages move the background objects with the mover at
; p01:run_object; the fifth does not: p00:run_background_objects diverts it here. They are the
; same eight eight-byte cards at BG_OBJECTS, but with two rules of their own:
; types 1 to 4 release type 0x1C objects when the ship comes within range,
; and types 5 to 8 set up the sliding turrets at TURRETS.
; ----------------------------------------------------------------------
run_stage_5_background:		; The eight eight-byte cards at BG_OBJECTS, one by one
	ld ix,BG_OBJECTS
	ld b,008h		; Eight cards
L_B2B0:
	push bc
	call stage_5_background_step
	pop bc
	ld de,00008h		; Eight bytes per card
	add ix,de
	djnz L_B2B0
	ret
stage_5_background_step:		; Gives it its step and then moves it with the scroll
	ld a,(ix+000h)		; An empty card is not touched
	and a
	ret z
	call dispatch_by_background_type
	ld a,(NEW_COLUMN)	; Only on steps with a new column
	and a
	ret z
	ld a,(ix+003h)		; Eight points to the left
	sub 008h
	jr nc,L_B2D6
	ld (ix+000h),000h	; Off screen, the card is switched off
	ret
L_B2D6:
	ld (ix+003h),a
	ret
dispatch_by_background_type:		; 1 to 4 release enemies; 5 to 8 set up turrets
	ld a,(ix+000h)
	cp 005h			; From type 5 onwards, elsewhere
	jp nc,set_up_turret
	ld a,(ix+001h)		; Byte 1: which step it is on
	dec a
	jr z,wait_for_ship
	dec a
	jr z,release_while_in_range
	dec (ix+004h)		; Byte 4: the frames left
	ret nz
	ld (ix+004h),008h	; Eight frames per step
	inc (ix+006h)
	inc (ix+007h)		; Byte 7: four steps and on to the next
	ld a,(ix+007h)
	cp 004h
	ret c
background_next_step:		; One more step
	inc (ix+001h)
	ret
wait_for_ship:		; As soon as the ship comes within range, one more step and start releasing
	call ship_in_range
	ret c
	inc (ix+006h)
	ld (ix+004h),008h
	jr background_next_step
release_while_in_range:		; Every eight frames releases a type 0x1C, and as soon as the ship leaves the range, goes back to the previous step
	call ship_in_range
	jr c,ship_left_range
	dec (ix+004h)
	ret nz
	ld (ix+004h),008h	; Eight frames between one and the next
	push ix
	call release_type_1C
	pop ix
	ret
ship_left_range:		; Goes back one step
	dec (ix+006h)
	dec (ix+001h)
	ret
ship_in_range:		; Compares the ship's column with its own, with a different margin depending on the type
	ld d,(ix+003h)		; Its column
	ld a,(SHIP_COLUMN)	; The ship's column
	ld h,a
	ld a,(ix+000h)		; Types 1 and 3 measure on one side...
	dec a
	jr z,L_B346
	dec a
	jr z,L_B33F
	dec a
	jr z,L_B346
L_B33F:
	ld a,d			; ...and 2 on the other: 0x30 ahead
	add a,030h
	ret c
	sub h
	ccf
	ret
L_B346:
	ld a,d			; 0x20 behind
	sub 020h
	ret c
	sub h
	ret
release_type_1C:		; The position comes from its own plus the offset for its type
	ld a,(ix+000h)
	add a,a
	ld hl,type_1C_release_offsets-2	; The table at 0xB366: two bytes per type
	call add_a_to_hl
	ld a,(ix+002h)		; Its row plus the offset...
	add a,(hl)
	ld e,a
	inc hl
	ld a,(ix+003h)		; ...and its column
	add a,(hl)
	ld d,a
	ld c,000h
	ld a,01ch		; Type 0x1C
	jp spawn_object

; ----------------------------------------------------------------------
; DATA type_1C_release_offsets (part): Ten bytes read by 0xB350 with base 0xB366.
type_1C_release_offsets:
	defb 10h,0F0h
	defb 10h,28h
	defb 10h,0F0h
	defb 10h,28h
set_up_turret:		; Types 5 to 8 look for a free card at TURRETS and set up a sliding turret there
	ld a,(ix+000h)
	cp 009h			; From type 9 onwards, nothing
	ret nc
	ld a,(ix+004h)		; Byte 4: the frames left
	and a
	ret z
	dec (ix+004h)
	ret nz
	ld hl,TURRETS		; The four cards, eight bytes apart
	ld b,004h
	ld de,00008h
	xor a
L_B388:
	cp (hl)			; The first one with its first byte at zero
	jr z,L_B392
	add hl,de
	djnz L_B388
	inc (ix+004h)		; With no free card, it tries again on the next frame
	ret
L_B392:
	bit 0,(ix+000h)		; Bit 0 of the type: the turret goes up or down
	ld a,001h
	jr nz,L_B39B
	inc a
L_B39B:
	ld (hl),a
	inc l
	ld (hl),000h
	inc l
	ld a,(ix+000h)		; The table at sliding_turret_offsets: two bytes per type
	sub 005h
	ld de,sliding_turret_offsets
	add a,a
	call add_a_to_de
	ld a,(de)
	inc de
	add a,(ix+002h)		; Its row plus the offset...
	ld (hl),a
	inc l
	ld a,(de)		; ...and its column
	add a,(ix+003h)
	ld (hl),a
	inc l
	ld (hl),005h		; Five frames for the first step
	inc l
	ld (hl),000h
	inc l
	ld (hl),000h
	inc l
	ld a,(ix+007h)
	ld (hl),a
	ret

; ----------------------------------------------------------------------
; DATA sliding_turret_offsets: Eleven bytes read by 0xB3A5 with `ld de,0xB3C7`.
sliding_turret_offsets:
	defb 00h,08h,18h,08h,0F8h,00h,08h,00h,0AFh,18h,02h

	end

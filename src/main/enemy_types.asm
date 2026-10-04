; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - enemy_types.asm
; ============================================================================

	public finish_type_16,finish_type_17,finish_type_18,finish_type_19,finish_type_3,finish_type_4
	public move_type_1A,move_type_3,move_types_17_and_18

; ----------------------------------------------------------------------
; EACH ENEMY TYPE HAS TWO ROUTINES, AND ALMOST ALL OF THEM ARE HERE
; An object boils down to one number, its type, from 1 to 0x1F. That
; number drives two tables: the one at p00:0x5DFD, which says who moves it
; every frame, and the one at p01:0x6B46, which says who finishes building
; it when it is born. Of the thirty-one types, TWENTY have at least one of
; their two routines here, and SIXTEEN have both; that is why
; 0xA7B9..0xB537 is the longest stretch of code in the cartridge.
; ----------------------------------------------------------------------
finish_type_16:		; No speed and bit 1 of byte 27 cleared
	res 1,(ix+01bh)
	jp 09510h
finish_type_17:		; The same, and byte 23 to one
	res 1,(ix+01bh)
	ld (ix+017h),001h
	jp 09510h
finish_type_18:		; The same, and byte 23 to eight
	res 1,(ix+01bh)
	ld (ix+017h),008h
	jp 09510h
finish_type_19:		; Only the speeds to zero
	jp 09510h
move_types_17_and_18:		; They move with the scroll and, when they go off screen, break the capsule chain
	call 09251h
	ret nc
	jr L_A81C
move_type_1A:		; Moves with the scroll and, when its count runs out, turns into the type noted in byte 24
	call 09251h		; Moves with the scroll
	jp c,left_unclaimed	; Going off the edge is handled elsewhere
	ld a,(ix+004h)
	or a
	jp z,L_A7EF
	dec (ix+004h)
L_A7EF:
	dec (ix+002h)		; Byte 2: the frames it has left like this
	ret nz
	ld a,(ix+018h)		; Byte 24 says what it turns into
	cp 016h			; With 0x16 it does not turn into anything: it switches off
	jp z,05fa5h
	dec (ix+017h)		; And byte 23 counts how many times it can
	jp z,05fa5h
	ld (ix+000h),a		; The new type, in its place
	ld (ix+00bh),001h	; Byte 11 to one: drawn with characters
	ld (ix+00ch),038h	; And character 0x38
	set 0,(ix+01bh)
	ld a,(ix+019h)		; Byte 25 reloads the count
	ld (ix+004h),a
	ret
left_unclaimed:		; When it leaves through the edge, the capsule chain starts over
	ld a,(ix+017h)
	dec a
	ret z
L_A81C:
	xor a
	ld (0e128h),a		; 0xE128 to zero: the next capsule pays one point again
	ret
finish_type_3:		; Down four, two to the left, and its path curves
	ld de,00400h		; Four points per frame downwards
	call 06cbfh
	call 09530h		; And that same figure as horizontal acceleration
	ld de,0fe00h		; Two to the left
	call 06cc6h
	ld de,0ff80h		; With half a point of vertical acceleration
	jp 09522h
move_type_3:		; Fires, changes drawing and keeps curving until the speed equals the acceleration
	call 09235h		; Fires without aiming
	call animate_type_3	; Changes drawing
	call 0953ch		; And the curve: acceleration plus speed
	call 09564h
	call z,09519h
	ret
animate_type_3:		; Eight drawings, one every eight frames, there and back
	ld bc,00708h
	ld hl,0a84fh
	jp 095d1h

; ----------------------------------------------------------------------
; DATA table_A84F: Eight bytes read by 0xA849: there and back (0x8C, 0x90,
;   0x94, 0x98, 0x9C, 0x98, 0x94, 0x90).
table_A84F:
	defb 8Ch,90h,94h,98h,9Ch,98h,94h,90h
finish_type_4:		; No vertical speed and one and a half points to the left
	ld de,00000h
	call 06cbfh
	ld de,0fe80h
	jp 06cc6h

	end

; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - homing_table.asm
; ============================================================================

	include "variables.inc"

	public aim_acceleration

; ----------------------------------------------------------------------
; THE ACCELERATION TOWARDS THE SHIP COMES FROM A TABLE OF 256 WORDS
; For an object to curve towards the ship it needs a vertical and a
; horizontal acceleration, and here they are not calculated: they are looked
; up. The two differences are taken in absolute value, the high nibble of
; one is joined with the high nibble of the other in a single byte, and that
; byte (times two) indexes the table at 0x9657, which is 256 words. It is
; read twice, crossing the nibbles, and that gives the two components; the
; sign is set by the two's complement.
; ----------------------------------------------------------------------
aim_acceleration:		; The two differences to the ship, in absolute value, give the index into the table at 0x9657: the two accelerations come from there
	ld b,000h
	ld a,(SHIP_COLUMN)	; The ship's column
	ld d,a
	ld a,(ix+006h)
	sub d
	jr nc,L_95FA
	neg			; If negative, the sign is noted down
	inc b
L_95FA:
	ld h,a
	ld c,000h
	ld a,(SHIP_ROW)		; And its row
	ld d,a
	ld a,(ix+004h)
	sub d
	jr nc,L_960A
	neg
	inc c
L_960A:
	ld l,a
	rra			; The high nibble of one and the high nibble of the other
	rra			; The high nibble of the distance in X
	rra			; The four high bits
	rra
	and 00fh
	ld e,a
	ld a,h
	and 0f0h
	or e
	ld e,a
	ld d,000h
	sla e
	rl d
	push hl
	ld hl,09657h		; The table at 0x9657, times two
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	bit 0,b			; And the sign, with the two's complement
	call z,06729h
	ld (ix+019h),e		; Bytes 25 and 26: the horizontal acceleration
	ld (ix+01ah),d
	pop hl
	ld a,h			; Now the other way round: the nibbles crossed
	rra			; The nibbles crossed
	rra			; The high nibble of one and the low nibble of the other
	rra
	rra
	and 00fh
	ld e,a
	ld a,l
	and 0f0h
	or e
	ld e,a
	ld d,000h
	sla e
	rl d
	ld hl,09657h
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	bit 0,c
	call z,06729h
	ld (ix+017h),e		; And bytes 23 and 24: the vertical one
	ld (ix+018h),d
	ret

; ----------------------------------------------------------------------
; DATA acceleration_towards_ship: Two hundred and fifty-six words that 0x961E
;   and 0x9644 index with the high nibbles of the two distances to the ship:
;   the acceleration with which an object curves towards it. A single table
;   gives both components, by reading it twice with the nibbles crossed.
acceleration_towards_ship:
	defw 00C0h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 00C0h,0060h
	defw 0026h,0013h
	defw 000Bh,0007h
	defw 0005h,0003h
	defw 0002h,0002h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0000h,0000h
	defw 0030h,0026h
	defw 0018h,000Eh
	defw 0009h,0006h
	defw 0004h,0003h
	defw 0002h,0002h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0000h,0000h
	defw 0015h,0013h
	defw 000Eh,000Ah
	defw 0007h,0005h
	defw 0004h,0003h
	defw 0002h,0002h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0000h,0000h
	defw 000Ch,000Bh
	defw 0009h,0007h
	defw 0006h,0004h
	defw 0003h,0002h
	defw 0002h,0001h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0000h,0000h
	defw 0007h,0007h
	defw 0006h,0005h
	defw 0004h,0003h
	defw 0003h,0002h
	defw 0002h,0001h
	defw 0001h,0001h
	defw 0001h,0000h
	defw 0000h,0000h
	defw 0005h,0005h
	defw 0004h,0004h
	defw 0003h,0003h
	defw 0002h,0002h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0000h
	defw 0000h,0000h
	defw 0003h,0003h
	defw 0003h,0003h
	defw 0002h,0002h
	defw 0002h,0001h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0003h,0002h
	defw 0002h,0002h
	defw 0002h,0002h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0002h,0002h
	defw 0002h,0002h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0001h,0001h
	defw 0001h,0001h
	defw 0001h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h

	end

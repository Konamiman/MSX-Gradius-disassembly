; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - blinking.asm
; ============================================================================

	public animate_type_0D

; ----------------------------------------------------------------------
; THE OUT-OF-STEP BLINKING COMES FROM THE R REGISTER
; The six drawings of this enemy do not take turns at a fixed pace: every
; time it changes, bit 0 of the R register decides whether the next one
; lasts 0x0F frames or only 3. With the same table of six drawings, two
; enemies that come out at the same time are never in step.
; ----------------------------------------------------------------------
animate_type_0D:		; Changes drawing every 0x0F or every 3 frames, drawn by lot with the R register
	dec (ix+014h)		; Byte 20: the frames this drawing has left
	ret nz
	ld b,00fh
	ld a,r			; The R register: 0x0F frames or only 3
	and 001h
	jr nz,L_B01E
	ld b,003h
L_B01E:
	ld (ix+014h),b
	inc (ix+01dh)		; Byte 29: which drawing it is on
	ld a,(ix+01dh)
	cp 006h			; Six drawings, round and round
	jr c,L_B02F
	xor a
	ld (ix+01dh),a
L_B02F:
	ld hl,type_0D_drawings
	add a,l
	ld l,a
	jr nc,L_B037
	inc h
L_B037:
	ld a,(hl)
	ld (ix+00ch),a
	ret

; ----------------------------------------------------------------------
; DATA type_0D_drawings: Six bytes read by L_B02F.
type_0D_drawings:
	defb 0E0h,0E4h,0E8h,0ECh,0E8h,0E4h

	end

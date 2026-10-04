; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - dispatcher.asm
; ============================================================================

	public dispatcher
	extrn add_a_to_hl

; ----------------------------------------------------------------------
; THE KONAMI DISPATCHER
; ----------------------------------------------------------------------
dispatcher:		; Konami's dispatcher: the destination table goes RIGHT BEHIND the `call`.
	pop hl			; `pop hl` takes the RETURN address, which is where the table starts.
	add a,a			; Each entry is two bytes, so the index is doubled.
	call add_a_to_hl
	ld e,(hl)		; The word in the table is the destination...
	inc hl
	ld d,(hl)
	ex de,hl
	jp (hl)			; ...and here is the jump. The caller does NOT return: the table eats the return address.

	end

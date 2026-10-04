; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - konami_mark.asm
; ============================================================================

; ----------------------------------------------------------------------
; THE MARK KONAMI HID AT THE END OF THE BANK
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; DATA konami_mark: The mark Konami hid at the end of the bank. Eleven bytes:
;   the eight of the title BACKWARDS (8C 82 B4 B7 92 A6 B7 87), the 0x08 that
;   says how many there are, the 0x42 that is the last two digits of the RC in
;   BCD (that is, RC-742) and the 0xAA that closes it. Read forwards and with
;   the house katakana table (index = byte minus 0x80, gojuon in order) they
;   give グラディウス: GRADIUS. The find is Manuel Pazos's (@ManuelPazosMSX).
konami_mark:
	defb 8Ch,82h,0B4h,0B7h,92h,0A6h,0B7h,87h
	defb 08h
	defb 42h
	defb 0AAh

	end

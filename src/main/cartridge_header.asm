; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - cartridge_header.asm
; ============================================================================

	public jump_to_intro
	extrn INIT,intro

; Bank 0 (runs at 0x4000).
;
; It is the only FIXED bank in the cartridge: there is no register that changes
; it, so it is always at 0x4000-0x5FFF. That is why it holds everything that
; has to be available no matter what: the header, the boot, the interrupt hook,
; the dispatcher, the mapper routines and the game's state machine.

; ----------------------------------------------------------------------
; CARTRIDGE HEADER
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; DATA header: MSX cartridge header: "AB", INIT = 0x4071, and the other three
;   entries (STATEMENT, DEVICE, TEXT) at zero, plus six reserved bytes.
header:
	defb 41h,42h
	defw INIT
	defw 0000h
	defw 0000h
	defw 0000h
	defb 00h,00h,00h,00h,00h,00h

; --- The second header, the Game Master's. No instruction in the cartridge
; reads it: it is read by the OTHER cartridge, Konami's Game Master, which
; plugs into the slot next door and needs to know where this one keeps its
; things so it can tamper with them. "CD" format: mark, catalogue number, a
; flags byte and only the fields that byte announces. The 19 bytes the Game
; Master copies start at gm_catalogue, and the count closes exactly at 0x4025.

; ----------------------------------------------------------------------
; DATA gm_mark: The format mark: "CD" in ASCII (43 44). It is what the Game
;   Master looks for to know that this cartridge carries the long header; the
;   ones that carry the short one have "AB".
gm_mark:
	defb 43h,44h

; ----------------------------------------------------------------------
; DATA gm_catalogue: The catalogue number in BCD, high byte first: 07 42, that
;   is RC-742, which is this cartridge's.
gm_catalogue:
	defb 07h,42h

; ----------------------------------------------------------------------
; DATA gm_flags: 0x80: says which fields follow. They are read from bit 0 to 7
;   and a CLEAR bit means "this field is in the stream". Here the first seven
;   are present and the last one is missing, which is a callback through
;   CALSLT.
gm_flags:
	defb 80h

; ----------------------------------------------------------------------
; DATA gm_fields: The seven fields the flags byte announces, in bit order:
;   GAME_STATE with the 0x04 that says when there is a live game (state_4
;   is where the stage starts); STAGE the stage with its modulo 8 (set_up_due_stage);
;   LIVES the lives (0x53CC, in BCD); HISCORE the high score; SCORE_P1 one
;   player's score and SCORE_P2 the other's (0x54AA picks between the two by bit
;   7 of GAME_FLAGS and clears four bytes); and GAME_FLAGS, the game flags. That
;   HISCORE is the high score is something the cartridge itself tells us:
;   start_whole_game clears from SCORE_P2 up to 0xEFFF when a game starts and those four
;   bytes are exactly the ones it leaves standing.
gm_fields:
	defb 00h,0E0h,04h
	defb 61h,0E0h,08h
	defw 0E060h
	defw 0E053h
	defw 0E05Bh
	defw 0E057h
	defw 0E002h
jump_to_intro:		; `jp intro`. It is the only place that enters the intro.
	jp intro

	end

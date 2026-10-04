; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - rock_rain.asm
; ============================================================================

	include "variables.inc"

	public drop_rock,L_ABCC,start_rain

; ----------------------------------------------------------------------
; THE RAIN OF ROCKS
; A timer of 0x384 frames (fifteen seconds) during which a type 8 rock
; falls every few frames. Where each one comes from is drawn by lot by the
; R register among the sixteen positions at 0xABD3, and how often one falls
; is set by the difficulty: 0x14 frames minus 0xE111. When the timer runs
; out, p01:0x7D64 is called and the stage carries on.
; ----------------------------------------------------------------------
start_rain:		; The timer to 0x384 frames and the cadence to 0x14 minus the difficulty
	ld hl,RAIN_TIMER	; The timer, 0x384 frames
	ld bc,00384h
	ld (hl),c
	inc l
	ld (hl),b
	ld a,001h		; 0xE972 to one: the rain is under way
	inc l
	ld (hl),a
	inc l
	ld a,(DIFFICULTY)	; 0x14 minus the difficulty: the frames between one rock and the next
	sub 014h
	neg
	inc l
	ld hl,RAIN_COUNTDOWN
	ld (hl),a
	inc l
	ld (hl),a
	ret
drop_rock:		; Counts the timer down and, every few frames, drops a rock through one of the sixteen doors at 0xABD3
	ld a,(SCROLL_MODE)	; With the screen stopped, no
	and a
	ret nz
	ld a,(RAIN_ON)		; Only if the rain is under way
	or a
	ret z
	ld hl,(RAIN_TIMER)	; One frame less of rain
	dec hl
	ld (RAIN_TIMER),hl
	ld a,l
	or h
	jp z,07d64h		; Once the timer has run out, the stage carries on
	ld hl,RAIN_COUNTDOWN	; The frames until the next rock
	dec (hl)
	ret nz
	inc l
	ld a,(hl)		; Reloaded from 0xE975
	dec l
	ld (hl),a
	ld a,r			; The R register picks one of the sixteen doors
	and 00fh
	ld hl,0abd3h
	call 047aeh
L_ABCC:
	ld c,000h
	ld a,008h		; Type 8: the rock
	jp 06a72h

; ----------------------------------------------------------------------
; DATA table_ABD3: Thirty-two bytes read by 0xABC6, in pairs.
table_ABD3:
	defb 08h,10h
	defb 98h,10h
	defb 20h,30h
	defb 48h,30h
	defb 70h,48h
	defb 48h,60h
	defb 30h,80h
	defb 98h,80h
	defb 08h,90h
	defb 28h,0A8h
	defb 80h,0A8h
	defb 18h,0C0h
	defb 60h,0C0h
	defb 08h,0D8h
	defb 08h,0F0h
	defb 98h,0F0h

	end

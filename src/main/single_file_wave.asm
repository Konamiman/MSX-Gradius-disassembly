; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - single_file_wave.asm
; ============================================================================

	include "variables.inc"

	public run_wave
	extrn find_group,spawn_object

; ----------------------------------------------------------------------
; THE WAVE THAT COMES IN SINGLE FILE
; Six enemies of the same type coming in single file from the right. The
; wave is noted in one of the four group cards at GROUPS with its count,
; and p00:object_to_explosion brings it down as they fall; when the last one falls, the
; group closes and that last one blows up with a different drawing. The
; stage decides which type comes out: the byte at 0xA5AF carries TWO
; types, one in each half, and they alternate from wave to wave.
; ----------------------------------------------------------------------
run_wave:		; The three steps of the wave: not started, waiting for room, and releasing an enemy every few frames
	ld hl,FILE_WAVE_STEP	; Which step the wave is on
	ld a,(hl)
	and a
	jr z,set_up_wave
	dec a			; Step 1: waiting for there to be room
	jr z,wait_for_room
	inc l			; 0xE161: the frames until the next one
	dec (hl)
	ret nz
	ld a,(FILE_WAVE_TYPE)	; The type says how often they come out
	ld b,004h
	cp 002h			; Type 2 goes every four
	jr z,L_A4E1
	ld b,010h
	cp 00ch			; And 0x0C, every sixteen
	jr z,L_A4E1
	ld b,004h
	ld a,(FILE_WAVE_LEFT)	; The rest go in pairs: four and one, four and one
	bit 0,a
	jr nz,L_A4E1
	ld b,001h
L_A4E1:
	ld (hl),b		; The wait, reloaded
	inc l
	dec (hl)		; One fewer of the six
	jr nz,L_A4EA
	dec l
	dec l
	ld (hl),000h		; And with the last one out, the wave is over
L_A4EA:
	ld a,(FILE_WAVE_HEIGHT)	; The height at which the whole wave comes in
	ld e,a
	ld d,0f0h		; X 0xF0: through the right edge
	ld a,(FILE_WAVE_TYPE)
	ld c,000h
	call spawn_object
	ld a,(SPAWNED_TYPE)	; Stays at zero if there was no free slot
	and a
	ret nz
	ld hl,FILE_WAVE_LEFT	; No room: the enemy goes back into the count...
	inc (hl)
	dec l
	dec l
	ld (hl),001h		; ...and the wave goes back to step 1
	ret
wait_for_room:		; With seven live objects or fewer, the wave starts
	ld a,(LIVE_OBJECTS)
	cp 007h
	ret nc
	inc (hl)
	ret
set_up_wave:		; Every eight steps of the stage sets up a new wave, with its type, its height and its group card
	ld a,(NEW_COLUMN)	; Only on the steps that put in a column
	and a
	ret z
	ld hl,(DISTANCE)	; The distance travelled
	ld de,00080h		; Waves only come out before step 0x80...
	ld a,(STAGE)
	cp 008h
	jr nz,L_A522
	ld e,040h		; ...and in the eighth stage, before 0x40
L_A522:
	rst 20h
	ret nc
	ld a,l			; One wave every eight steps
	and 007h
	ret nz
	ld hl,00101h		; FILE_WAVE_STEP to one and 0xE161 to one: the wave starts
	ld (FILE_WAVE_STEP),hl
	ld a,(STAGE)		; The stage indexes the list at 0xA5AF
	ld hl,file_wave_types_per_stage-1
	add a,l
	ld l,a
	jr nc,L_A539
	inc h
L_A539:
	ld c,(hl)
	ld hl,FILE_WAVE_NUMBER	; Goes up by one per wave, skipping zero
	ld a,(hl)
	inc a
	jr nz,L_A542
	inc a
L_A542:
	ld (hl),a
	rra			; Its bit 0 picks the half: one wave of each type
	ld a,c
	ld b,c
	jr nc,L_A54C
	rrca
	rrca
	rrca
	rrca
L_A54C:
	and 00fh		; The type of this wave, to FILE_WAVE_TYPE
	ld (FILE_WAVE_TYPE),a
	ld c,a
	ld a,(hl)		; The two low bits: FILE_WAVE_ALT to zero or to one
	and 003h
	jr z,L_A559
	ld a,001h
L_A559:
	ld (FILE_WAVE_ALT),a
	call wave_height	; The height at which they come in
	ld (FILE_WAVE_HEIGHT),a
	ld a,006h		; Six enemies per wave
	ld (FILE_WAVE_LEFT),a
	xor a			; A free group card is looked for at GROUPS
	call find_group
	jr nc,note_group
	xor a			; No free card, no wave
	ld (FILE_WAVE_STEP),a
	ret
note_group:		; The card at GROUPS keeps the wave number and, twice, the six it brings
	ld a,(FILE_WAVE_NUMBER)	; The wave number, in the group card
	ld (hl),a
	inc l
	ld a,(FILE_WAVE_LEFT)	; And the six it brings, twice
	ld (hl),a
	inc l
	ld (hl),a
	ret
wave_height:		; Where it comes in: top or bottom for almost all, and types 0x0A and 0x0C have their own
	ld a,c
	cp 00ah			; Type 0x0A comes in at 0x40 or at 0x80
	jr z,L_A5A0
	cp 00ch			; And 0x0C, at 6 or at 0x98
	jr z,L_A5A8
	ld a,b			; The two halves of the stage's byte...
	and 00fh
	ld c,a
	ld a,b
	rra
	rra
	rra
	rra
	and 00fh
	cp c			; ...and if they are equal, another bit is checked
	ld c,(hl)
	jr z,L_A598
	rr c
L_A598:
	ld a,008h		; Row 8: at the top
	bit 0,c
	ret z
	ld a,098h		; Or 0x98: at the bottom
	ret
L_A5A0:
	ld a,040h
	bit 1,(hl)
	ret z
	ld a,080h
	ret
L_A5A8:
	ld a,006h
	bit 1,(hl)
	ret z
	ld a,098h
L_A5AF:
	ret

; ----------------------------------------------------------------------
; DATA file_wave_types_per_stage (part): Nine bytes read by 0xA531 with base 0xA5AF.
file_wave_types_per_stage:
	defb 22h,22h,2Ah,2Ah,2Ah,0CAh,22h,22h

	end

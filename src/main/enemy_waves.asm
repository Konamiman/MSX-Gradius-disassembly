; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - enemy_waves.asm
; ============================================================================

	include "variables.inc"

	public release_stretch_enemies
	extrn add_a_to_de,add_a_to_hl,check_1B_script,check_for_wall,check_script,get_word
	extrn mark_next_or_not,release_big_ones_flock,release_bottom_four,release_flock,release_left_ones,release_long_flock
	extrn release_mixed_eight,run_wave,spawn_object

; ----------------------------------------------------------------------
; WHICH ENEMIES COME OUT: ONE BYTE OF BITS PER STRETCH OF SCREEN
; The distance travelled, divided by 0x20, indexes a list per stage
; (0xA3A6): out comes ONE BYTE whose six low bits say which groups of
; enemies are active in that stretch. L_A359 rotates it bit by bit and
; calls the routine of every group that is switched on. That way each piece
; of the stage has its own mix of enemies without needing a long script.
; ----------------------------------------------------------------------
release_stretch_enemies:		; With the stretch's byte of bits, calls the routine of every enemy group that is switched on
	ld hl,WAVE_TIMER	; The frames left until the next wave
	ld a,(hl)
	and a
	jr z,L_A319
	dec (hl)
	ret
L_A319:
	ld a,(SCROLL_MODE)	; With the screen stopped, no
	and a
	ret nz
	ld a,(STAGE)		; From the ninth stage onwards, not either
	cp 009h
	ret nc
	ld a,(ENEMY_WAVE)	; Nor with a wave already under way
	and a
	ret nz
	ld a,(DISTANCE+1)	; Nor with 0xE064 at two or more
	cp 002h
	ret nc
	ld hl,(BOSS_STATE)	; With the boss on screen they only come out on some steps
	ld a,l
	and a
	jr z,L_A345
	ld a,h
	sub 005h
	cp 002h
	jr c,L_A345
	ld a,(FILE_WAVE_STEP)
	and a
	jp nz,run_wave
	ret
L_A345:
	call run_wave
	ld a,(SPAWNED_TYPE)	; Whether one has just come out
	and a
	jr z,L_A359
	ld hl,LIVE_OBJECTS
	ld a,00bh		; With eleven objects minus the live ones below FILE_WAVE_LEFT, it waits
	sub (hl)
	ld hl,FILE_WAVE_LEFT
	cp (hl)
	ret c
L_A359:
	call stretch_bits	; The stretch's byte of bits
	rra			; Bit 0: the first group
	push af
	call c,release_pair
	pop af
	rra			; Bit 1
	push af
	call c,release_trail
	pop af
	rra			; Bit 2
	push af
	call c,release_left_ones
	pop af
	rra			; Bit 3
	push af
	call c,release_bottom_four
	pop af
	rra			; Bit 4
	push af
	call c,release_flock
	pop af
	rra			; And bit 5
	call c,release_mixed_eight
	call check_for_wall	; And after them, the five mover routines that always run
	call check_script
	call check_1B_script
	call release_long_flock
	jp release_big_ones_flock
stretch_bits:		; The distance divided by 0x20 indexes the stage's list and returns the byte of bits
	ld a,(STAGE)
	ld hl,wave_stretch_lists-2	; The table at 0xA3A6: one list per stage
	call get_word
	ld hl,(DISTANCE)	; The distance travelled
	ld a,l
	rr h			; Divided by 0x20: the stretch
	rra
	rra
	rra
	rra
	rra
	and 00fh
	call add_a_to_de
L_A3A6:
	ld a,(de)
	ret

; ----------------------------------------------------------------------
; DATA wave_stretch_lists (part): Words read by 0xA390 with base 0xA3A6 (0xA3B8,
;   0xA3C8, 0xA3D8, ...) and, after them, what they point to.
wave_stretch_lists:
	defw wave_stretch_lists+10h,wave_stretch_lists+20h
	defw wave_stretch_lists+30h,wave_stretch_lists+40h
	defw wave_stretch_lists+50h,wave_stretch_lists+60h
	defw wave_stretch_lists+70h,wave_stretch_lists+80h
	defw 0000h,0200h
	defw 0401h,0A06h
	defw 0A03h,0E05h
	defw 0000h,0000h
	defw 0100h,0101h
	defw 0200h,0002h
	defw 0200h,0000h
	defw 0000h,0000h
	defw 1000h,1010h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0101h,0202h
	defw 0501h,0E06h
	defw 0503h,060Fh
	defw 0020h,0000h
	defw 0100h,0303h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0100h,0101h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0301h,0002h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0301h,0402h
	defw 0404h,0404h
	defw 0404h,0206h
	defw 0000h,0000h
release_pair:		; Every 0x70 frames minus twice the difficulty, releases two type 3 enemies, one along row 0x30 and the other along 0x60
	ld hl,PAIR_TIMER	; The frames left
	ld a,(hl)
	and a
	jr z,L_A441
	dec (hl)
	ret nz
L_A441:
	ld a,(LIVE_OBJECTS)	; With eleven or more live objects, it is left for later
	cp 00bh
	ret nc
	call wait_by_difficulty	; The wait for the next pair is reloaded
	call mark_next_or_not
	ld a,c
	ld b,c
	cp 002h			; With the adjustment at two, each one gets its own
	jr nz,L_A45C
	ld a,r			; The R register: the cartridge's only coin toss
	and 001h
	inc a
	ld c,a
	xor 003h		; One gets 1 and the other 2, or the other way round
	ld b,a
L_A45C:
	ld a,003h
	ld de,0f030h		; X 0xF0 and Y 0x30: comes in from the right, at the top
	push bc
	call spawn_object
	pop bc
	ld c,b
	ld de,0f060h		; And the second along 0x60, lower down
	ld a,003h
	jp spawn_object
release_trail:		; A line of type 4 enemies, one every eight frames, coming in at four heights that take turns
	ld hl,TRAIL_COUNT	; How many are still to come out
	ld a,(hl)
	and a
	jr z,start_another_trail
	inc l			; 0xE961: the frames until the next one
	dec (hl)
	ret nz
	ld (hl),008h		; Eight frames between one enemy and the next
	dec l
	dec (hl)		; One fewer to come out
	ld a,(hl)
	and 003h		; The two low bits of the count: the height goes by turns
	ld hl,trail_heights
	call add_a_to_hl
	ld e,(hl)
	ld d,0f0h		; Always from the right
	ld c,000h
	ld a,004h
	jp spawn_object
start_another_trail:		; The line is over: the difficulty says how many the next one brings
	ld a,(DIFFICULTY)	; The difficulty indexes the ramp at ramp_A4AA
	ld de,ramp_A4AA
	call add_a_to_de
	ld a,(de)
	ld (hl),a
	inc l
wait_by_difficulty:		; 0x70 minus twice the difficulty: the harder the stage, the shorter the wait
	ld a,(DIFFICULTY)
	add a,a			; The difficulty times two, subtracted from 0x70
	sub 070h
	neg
	ld (hl),a
	ret

; ----------------------------------------------------------------------
; DATA trail_heights: Four bytes (0x20, 0x80, 0x40, 0x70) read by 0xA480.
trail_heights:
	defb 20h,80h,40h,70h

; ----------------------------------------------------------------------
; DATA ramp_A4AA: Sixteen bytes in a ramp, read by 0xA493 with `ld de,0xA4AA`.
ramp_A4AA:
	defb 03h,03h,03h,04h,04h,05h,05h,06h,06h,06h,07h,07h,07h,08h,08h,08h

	end

; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - music_by_distance.asm
; ============================================================================

	include "variables.inc"

	public check_map_collision_2,check_which_music_plays,L_71B0,raise_difficulty,run_enemy_wave,run_ship
	extrn add_vertical_acceleration,blow_up_enemy,change_sign,check_background_collisions,check_collisions,check_if_sound
	extrn check_option_collision,check_ship_enemy_collision,check_ship_enemy_collision_2,check_ship_map_collision,check_ship_shot_collision,check_stage_5_collisions
	extrn collides_with_map,get_word,L_721C,spawn_object

; ----------------------------------------------------------------------
; THE MUSIC CHANGES WITH THE DISTANCE TRAVELLED
; The music of each stage is not launched once: there is a list per stage
; (the table at 0x7056 says which one) with pairs [distance][what plays],
; and every frame it looks in it for the range the distance travelled falls
; in. If what comes out is different from what is already playing
; (0xE012), the change is noted.
; ----------------------------------------------------------------------
check_which_music_plays:		; Looks in the stage's list for the distance range it is in and, if the music is a different one, notes it
	ld a,(SHIP)		; With the ship dead, no
	and a
	ret m
	ld a,(SCROLL_MODE)	; Nor with the screen stopped
	and a
	ret nz
	ld a,(MUSIC_HOLD)	; Nor with it set
	and a
	ret nz
	ld hl,PENDING_MUSIC	; There is already a music change pending
	ld a,(hl)
	and a
	jr nz,start_noted_music
	ld a,(STAGE)
	ld hl,music_by_distance_lists-2	; The table at 0x7056: one list per stage
	call get_word
	ld c,e
	ld b,d
	ld hl,(DISTANCE)	; The distance travelled
L_7027:
	ld a,(bc)		; Each row: two bytes of distance and one of music
	ld e,a
	inc bc
	ld a,(bc)
	ld d,a
	inc bc
	rst 20h			; DCOMPR: the range is looked for
	jr c,L_7033
	inc bc
	jr L_7027
L_7033:
	ld a,(bc)
	ld hl,SND_CARD_A+CARD_MODE	; If it is the one already playing, nothing is touched
	cp (hl)
	ret z
	ld (PENDING_MUSIC),a	; And if not, it is noted
	ld a,(hl)
	and a
	ret z
	ld hl,06001h
	ld (SND_MUTE),hl
	xor a
	ld (SND_MUTE_STEP),a
	ret
start_noted_music:		; When the channel goes quiet, launches the music that was parked in PENDING_MUSIC; 0xFF only clears it
	ld a,(SND_CARD_A+CARD_MODE)	; Until the channel goes quiet, nothing changes
	and a
	ret nz
	ld a,(hl)
	cp 0ffh			; 0xFF means silence
	ld (hl),000h
	ret z
	jp check_if_sound

; ----------------------------------------------------------------------
; DATA music_by_distance_lists (part): Words that 0x701C indexes with the base 0x7056:
;   0x7070, 0x7079, 0x7082, 0x708B, ... all in this same bank.
music_by_distance_lists:
	defw music_by_distance_lists+18h,music_by_distance_lists+21h
	defw music_by_distance_lists+2Ah,music_by_distance_lists+33h
	defw music_by_distance_lists+3Ch,music_by_distance_lists+45h
	defw music_by_distance_lists+4Eh,music_by_distance_lists+57h
	defw music_by_distance_lists+60h,music_by_distance_lists+60h
	defw music_by_distance_lists+66h,music_by_distance_lists+6Ch
	defw 0064h,80ACh
	defw 0AF01h,0FFFFh
	defw 64B5h,0AC00h
	defw 01A7h,0FF96h
	defw 0B5FFh,0060h
	defw 7CACh,9801h
	defw 0FFFFh,64B5h
	defw 0AC00h,017Fh
	defw 0FF9Ah,0B5FFh
	defw 0064h,0B7ACh
	defw 0A201h,0FFFFh
	defw 80B5h,0AC00h
	defw 0158h,0FF9Ch
	defw 0B5FFh,0064h
	defw 59ACh,9E01h
	defw 0FFFFh,38B5h
	defw 0AC00h,017Ah
	defw 0FFA0h,0B5FFh
	defw 00F7h,0FFA4h
	defw 0FFFFh,00B7h
	defw 0FFA4h,0FFFFh
	defw 0177h,0FFA4h
	defw 0FFFFh
raise_difficulty:		; One more step in DIFFICULTY, up to 0x0F
	ld c,001h
	ld hl,DIFFICULTY
	ld a,(hl)
	add a,c
	cp 010h			; Sixteen steps at most
	ret nc
	ld (hl),a
	ret
run_enemy_wave:		; With ENEMY_WAVE set, keeps releasing type 0x0F enemies every two frames until the count in ENEMY_WAVE_LEFT runs out
	ld a,(SCROLL_MODE)	; With the screen stopped, no
	and a
	ret nz
	ld a,(ENEMY_WAVE)	; The wave under way
	dec a
	ret m
	jr z,L_70F1
	ld hl,ENEMY_WAVE_X
	ld a,(NEW_COLUMN)	; On the steps with a column, the wave moves eight points to the left
	and a
	ld a,(hl)
	jr z,L_70F1
	sub 008h
	ld (hl),a
	jr c,end_enemy_wave
L_70F1:
	ld a,(FRAME_COUNT)	; One frame in two
	and 001h
	ret nz
	ld hl,(ENEMY_WAVE_LEFT)	; The ones still to come out
	dec hl
	ld (ENEMY_WAVE_LEFT),hl
	ld a,l
	or h
	jr z,end_enemy_wave
	call sound_on_arrival
	call set_spawn_position
	call wave_speed
	ld de,(ENEMY_WAVE_POS)	; And out comes a type 0x0F enemy
	ld a,00fh		; Object 0x0F: the wave enemy
	ld c,000h		; No adjustment
	jp spawn_object
end_enemy_wave:		; BOSS_DONE to one: the wave is used up
	ld a,001h
	ld (BOSS_DONE),a
	ret
set_spawn_position:		; With ENEMY_WAVE at one, alternates between the two positions at enemy_wave_spawn_positions according to bit 0 of the count
	ld a,(ENEMY_WAVE)
	dec a
	jr nz,set_spawn_position_by_height
	ld hl,enemy_wave_spawn_positions
	ld a,(ENEMY_WAVE_LEFT)	; Bit 0 of the count: once at the top and once at the bottom
	and 001h		; Bit 0: once at the top and once at the bottom
	call get_word
	ld (ENEMY_WAVE_POS),de
	ret
set_spawn_position_by_height:		; With ENEMY_WAVE at two, the position comes from the height in ENEMY_WAVE_X and column 0x20
	ld a,(ENEMY_WAVE_X)
	ld h,a
	ld l,020h
	ld (ENEMY_WAVE_POS),hl
	ret
wave_speed:		; The R register chooses one of the eight speed pairs at enemy_wave_speeds; in stage 1 it is turned around, and halfway through the wave it is halved
	ld a,r			; The R register: one of eight pairs
	and 007h
	add a,a			; Times two: two words per pair
	ld hl,enemy_wave_speeds
	call get_word
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld a,(STAGE)
	dec a			; In stage 1, the other way round
	call z,change_sign
	ld hl,(ENEMY_WAVE_LEFT)
	push de
	ld de,001a4h		; Past the middle of the wave...
	ld a,(ENEMY_WAVE)
	dec a
	jr z,L_7162
	ld de,000a5h
L_7162:
	rst 20h
	pop de
	jr c,L_716E
	sra d			; ...the speed is halved
	rr e
	sra b
	rr c
L_716E:
	ld (ENEMY_WAVE_VSPEED),de	; The vertical speed of the background
	ld e,c
	ld d,b
	ld a,(ENEMY_WAVE)
	dec a
	ld c,002h
	jr z,L_717D
	dec c
L_717D:
	ld a,(ENEMY_WAVE_LEFT)	; And a bit of the count turns the horizontal one around: the enemies come out alternating
	and c
	call nz,change_sign
	ld (ENEMY_WAVE_HSPEED),de	; And the horizontal one
	ret

; ----------------------------------------------------------------------
; DATA enemy_wave_spawn_positions: Four bytes read by 0x7122.
enemy_wave_spawn_positions:
	defb 7Fh,0BCh,7Fh,3Ch

; ----------------------------------------------------------------------
; DATA enemy_wave_speeds: Thirty-two bytes read by 0x7141.
enemy_wave_speeds:
	defb 00h,0Bh,80h,01h
	defb 80h,0Ah,00h,02h
	defb 80h,0Bh,00h,04h
	defb 00h,0Ah,90h,01h
	defb 80h,0Ah,0B0h,01h
	defb 40h,0Bh,00h,03h
	defb 70h,0Ah,80h,02h
	defb 60h,0Ah,40h,02h
check_map_collision_2:		; Passes the object's position to bank 2, with a correction of 0x10 if bit 7 of byte 8 is zero
	call add_vertical_acceleration
L_71B0:
	ld l,(ix+004h)		; The object's position
	ld h,(ix+006h)		; The object's position
	bit 7,(ix+008h)		; Bit 7 of byte 8 says whether it shifts by 0x10
	jr nz,L_71C0
	ld a,l
	add a,010h
	ld l,a
L_71C0:
	call collides_with_map	; And bank 2 answers
	ret nc
	jp blow_up_enemy
sound_on_arrival:		; In stage 1, at count 0x1C1 sound 0x32 plays; in the rest, at 0xB3 sound 0x13 plays
	ld hl,(ENEMY_WAVE_LEFT)
	ld a,(STAGE)
	dec a
	jr nz,L_71DE
	ld de,001c1h		; In stage 1, at count 0x1C1
	rst 20h
	ret nz
	xor a
	ld (SND_MUTE),a
	ld a,032h		; Sound 0x32
	jp check_if_sound
L_71DE:
	ld de,000b3h		; And in the rest, at 0xB3
	rst 20h
	ret nz
	ld a,013h		; Sound 0x13
	jp check_if_sound
run_ship:		; The chain of routines that move the ship, its shots and its options
	ld a,(SCROLL_MODE)	; With the screen stopped, the ship does not move
	and a
	ret nz
	call check_collisions	; First, the ship's shots against everything there is
	call check_eb00_collisions
	call check_background_collisions
	call check_stage_5_collisions
	call check_ship_map_collision	; And the collisions with the map and with the enemies
	call check_ship_enemy_collision_2
	call check_ship_enemy_collision
	call check_option_collision
	jp check_ship_shot_collision
check_eb00_collisions:		; The five objects at MID_BOSS_PIECES, only if FIVE_PIECES_ON is set
	ld a,(FIVE_PIECES_ON)	; Without it there is nothing to check
	or a
	ret z
	ld ix,MID_BOSS_PIECES
	ld b,005h
	jp L_721C

	end

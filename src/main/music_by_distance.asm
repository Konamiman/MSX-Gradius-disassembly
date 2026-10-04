; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - music_by_distance.asm
; ============================================================================

	public check_map_collision_2,check_which_music_plays,L_71B0,raise_difficulty,run_enemy_wave,run_ship
	extrn blow_up_enemy,change_sign,check_background_collisions,check_collisions,check_option_collision,check_ship_enemy_collision
	extrn check_ship_enemy_collision_2,check_ship_map_collision,check_ship_shot_collision,check_stage_5_collisions,L_721C,spawn_object

; ----------------------------------------------------------------------
; THE MUSIC CHANGES WITH THE DISTANCE TRAVELLED
; The music of each stage is not launched once: there is a list per stage
; (the table at 0x7056 says which one) with pairs [distance][what plays],
; and every frame it looks in it for the range the distance travelled falls
; in. If what comes out is different from what is already playing
; (0xE012), the change is noted.
; ----------------------------------------------------------------------
check_which_music_plays:		; Looks in the stage's list for the distance range it is in and, if the music is a different one, notes it
	ld a,(0e200h)		; With the ship dead, no
	and a
	ret m
	ld a,(0e1c0h)		; Nor with the screen stopped
	and a
	ret nz
	ld a,(0e114h)		; Nor with 0xE114 set
	and a
	ret nz
	ld hl,0e113h		; 0xE113: there is already a music change pending
	ld a,(hl)
	and a
	jr nz,start_noted_music
	ld a,(0e061h)
	ld hl,07056h		; The table at 0x7056: one list per stage
	call 047aeh
	ld c,e
	ld b,d
	ld hl,(0e063h)		; The distance travelled
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
	ld hl,0e012h		; If it is the one already playing, nothing is touched
	cp (hl)
	ret z
	ld (0e113h),a		; And if not, it is noted in 0xE113
	ld a,(hl)
	and a
	ret z
	ld hl,06001h
	ld (0e044h),hl
	xor a
	ld (0e046h),a
	ret
start_noted_music:		; When the channel goes quiet, launches the music that was parked in 0xE113; 0xFF only clears it
	ld a,(0e012h)		; Until the channel goes quiet, nothing changes
	and a
	ret nz
	ld a,(hl)
	cp 0ffh			; 0xFF means silence
	ld (hl),000h
	ret z
	jp 049deh

; ----------------------------------------------------------------------
; DATA table_7056 (part): Words that 0x701C indexes with the base 0x7056:
;   0x7070, 0x7079, 0x7082, 0x708B, ... all in this same bank.
table_7056_7058:
	defw 7070h,7079h
	defw 7082h,708Bh
	defw 7094h,709Dh
	defw 70A6h,70AFh
	defw 70B8h,70B8h
	defw 70BEh,70C4h
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
raise_difficulty:		; One more step in 0xE111, up to 0x0F
	ld c,001h
	ld hl,0e111h
	ld a,(hl)
	add a,c
	cp 010h			; Sixteen steps at most
	ret nc
	ld (hl),a
	ret
run_enemy_wave:		; With 0xE140 set, keeps releasing type 0x0F enemies every two frames until the count in 0xE148 runs out
	ld a,(0e1c0h)		; With the screen stopped, no
	and a
	ret nz
	ld a,(0e140h)		; 0xE140: the wave under way
	dec a
	ret m
	jr z,L_70F1
	ld hl,0e141h
	ld a,(0e100h)		; On the steps with a column, the wave moves eight points to the left
	and a
	ld a,(hl)
	jr z,L_70F1
	sub 008h
	ld (hl),a
	jr c,end_enemy_wave
L_70F1:
	ld a,(0e003h)		; One frame in two
	and 001h
	ret nz
	ld hl,(0e148h)		; 0xE148: the ones still to come out
	dec hl
	ld (0e148h),hl
	ld a,l
	or h
	jr z,end_enemy_wave
	call sound_on_arrival
	call set_spawn_position
	call wave_speed
	ld de,(0e146h)		; And out comes a type 0x0F enemy
	ld a,00fh		; Object 0x0F: the wave enemy
	ld c,000h		; No adjustment
	jp spawn_object
end_enemy_wave:		; 0xE150 to one: the wave is used up
	ld a,001h
	ld (0e150h),a
	ret
set_spawn_position:		; With 0xE140 at one, alternates between the two positions at 0x7189 according to bit 0 of the count
	ld a,(0e140h)
	dec a
	jr nz,set_spawn_position_by_height
	ld hl,07189h
	ld a,(0e148h)		; Bit 0 of the count: once at the top and once at the bottom
	and 001h		; Bit 0: once at the top and once at the bottom
	call 047aeh
	ld (0e146h),de
	ret
set_spawn_position_by_height:		; With 0xE140 at two, the position comes from the height in 0xE141 and column 0x20
	ld a,(0e141h)
	ld h,a
	ld l,020h
	ld (0e146h),hl
	ret
wave_speed:		; The R register chooses one of the eight speed pairs at 0x718D; in stage 1 it is turned around, and halfway through the wave it is halved
	ld a,r			; The R register: one of eight pairs
	and 007h
	add a,a			; Times two: two words per pair
	ld hl,0718dh
	call 047aeh
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld a,(0e061h)
	dec a			; In stage 1, the other way round
	call z,change_sign
	ld hl,(0e148h)
	push de
	ld de,001a4h		; Past the middle of the wave...
	ld a,(0e140h)
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
	ld (0e142h),de		; 0xE142: the vertical speed of the background
	ld e,c
	ld d,b
	ld a,(0e140h)
	dec a
	ld c,002h
	jr z,L_717D
	dec c
L_717D:
	ld a,(0e148h)		; And a bit of the count turns the horizontal one around: the enemies come out alternating
	and c
	call nz,change_sign
	ld (0e144h),de		; And 0xE144: the horizontal one
	ret

; ----------------------------------------------------------------------
; DATA table_7189: Four bytes read by 0x7122.
table_7189:
	defb 7Fh,0BCh,7Fh,3Ch

; ----------------------------------------------------------------------
; DATA table_718D: Thirty-two bytes read by 0x7141.
table_718D:
	defb 00h,0Bh,80h,01h
	defb 80h,0Ah,00h,02h
	defb 80h,0Bh,00h,04h
	defb 00h,0Ah,90h,01h
	defb 80h,0Ah,0B0h,01h
	defb 40h,0Bh,00h,03h
	defb 70h,0Ah,80h,02h
	defb 60h,0Ah,40h,02h
check_map_collision_2:		; Passes the object's position to bank 2, with a correction of 0x10 if bit 7 of byte 8 is zero
	call 0953ch
L_71B0:
	ld l,(ix+004h)		; The object's position
	ld h,(ix+006h)		; The object's position
	bit 7,(ix+008h)		; Bit 7 of byte 8 says whether it shifts by 0x10
	jr nz,L_71C0
	ld a,l
	add a,010h
	ld l,a
L_71C0:
	call 09857h		; And bank 2 answers
	ret nc
	jp blow_up_enemy
sound_on_arrival:		; In stage 1, at count 0x1C1 sound 0x32 plays; in the rest, at 0xB3 sound 0x13 plays
	ld hl,(0e148h)
	ld a,(0e061h)
	dec a
	jr nz,L_71DE
	ld de,001c1h		; In stage 1, at count 0x1C1
	rst 20h
	ret nz
	xor a
	ld (0e044h),a
	ld a,032h		; Sound 0x32
	jp 049deh
L_71DE:
	ld de,000b3h		; And in the rest, at 0xB3
	rst 20h
	ret nz
	ld a,013h		; Sound 0x13
	jp 049deh
run_ship:		; The chain of routines that move the ship, its shots and its options
	ld a,(0e1c0h)		; With the screen stopped, the ship does not move
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
check_eb00_collisions:		; The five objects at 0xEB00, only if 0xE1B0 is set
	ld a,(0e1b0h)		; Without 0xE1B0 there is nothing to check
	or a
	ret z
	ld ix,0eb00h
	ld b,005h
	jp L_721C

	end

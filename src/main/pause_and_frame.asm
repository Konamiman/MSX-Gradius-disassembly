; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - pause_and_frame.asm
; ============================================================================

	include "bios.inc"

	public check_pause_key,start_scroll
	extrn animate_options,blink_two_characters,check_boss_collisions,check_fire,check_stretch_target,check_typed_keys
	extrn clear_typing_state,dispatch_boss_step,dispatch_boss_step_2,dispatch_by_stage,dispatch_ship_end,draw_piece_at_e9a0
	extrn draw_scores,draw_shots,draw_the_five,drop_rock,erase_shots,L_998C
	extrn note_all_cells,note_cells_of_the_five,paint_background_or_bank3,paint_turrets,paint_whole_frame,place_ship
	extrn release_background_objects_on_column,release_enemies_on_column,release_stretch_enemies,release_what_is_due,run_background_objects,run_e780_and_ea00
	extrn run_enemy_wave,run_five_pieces,run_four_at_e800,run_four_at_e800_and_ea80,run_four_at_e880,run_nine_shots
	extrn run_options,run_piece_at_e9a0,run_ship,run_sprites,run_ten_at_e500,run_twelve_objects
	extrn scroll_map_one_column,take_upgrade,upload_screen,upload_ship_cards,upload_sprites_rotating

; ----------------------------------------------------------------------
; THE PAUSE
; ----------------------------------------------------------------------
check_pause_key:		; With the game running, looks at bit 5 of keyboard row 6 and, when it is pressed, toggles between pause and play
	ld a,(0e002h)		; Bit 6 of 0xE002: only with the game running
	and 040h
	jr z,game_frame
	ld a,(0e1d0h)		; And with 0xE1D0 at zero
	and a
	jr nz,game_frame
	ld a,006h
	call SNSMAT		; SNSMAT of row 6; bit 5 is the GRAPH key
	cpl			; A cpl: on the keyboard a pressed key is a zero
	and 020h
	ld hl,0e10ch		; 0xE10C keeps the previous state, to catch the new press
	ld c,(hl)
	ld (hl),a
	xor c			; What has changed and is set: it has just gone down
	and (hl)
	dec hl
	jr z,L_4518
	inc (hl)		; 0xE10B counts the presses: even is play, odd is pause
	bit 0,(hl)
	ld de,00000h		; In play, 0xE047 to zero
	jr z,L_4514
	ld de,00101h		; And in pause, 0x0101
	call clear_typing_state
L_4514:
	ld (0e047h),de
L_4518:
	bit 0,(hl)		; Only with the game paused are the keyboard cheats read
	jr z,game_frame
	call check_typed_keys
	ld a,(0e200h)		; 0xE200 negative: the pause is handled elsewhere
	and a
	jp m,upload_sprites_rotating
	call L_998C		; Three routines from banks 2 and 3, with the game stopped
	call animate_options
	call upload_ship_cards
	jp upload_sprites_rotating

; ----------------------------------------------------------------------
; ONE FRAME OF PLAY
; This is the game's shopping list: thirty-odd calls in a row, nearly all
; of them to banks 1, 2 and 3, and everything that happens in a frame is
; done in that order. There is no loop and no table: it is a strip of
; `call`s. Banks 11 and 12 (the pieces and the stage scripts) are slipped
; in the middle on purpose for a single call, and then 2 and 3 are
; restored.
; ----------------------------------------------------------------------
game_frame:		; The strip of calls that makes a whole frame: the scroll, the enemies, the shots, the collisions and the score
	ld a,(0e009h)		; 0xE009 is copied to 0xE10D: the joystick, as it was left
	ld (0e10dh),a
	call upload_sprites_rotating
	call dispatch_by_stage
	ld a,(0e1d0h)		; With 0xE1D0 set there is an explosion in progress
	and a
	call nz,dispatch_ship_end
	ld a,(0e1d1h)		; And with 0xE1D1 set, the frame is cut short here
	and a
	ret nz
	call check_stretch_target
	xor a
	ld (0e112h),a		; 0xE112 to zero
	di			; Banks 11 and 12: the pieces and the stage scripts
	ld a,00bh
	ld (08000h),a
	ld (0f0f2h),a		; The RAM copy of the mapper is updated at the same time
	ei
	di
	ld a,00ch
	ld (0a000h),a
	ld (0f0f3h),a
	ei
	call scroll_map_one_column	; And with them in place, the piece of screen that is due is built
	di			; 2 and 3 restored, which are the usual ones
	ld a,002h
	ld (08000h),a
	ld (0f0f2h),a
	ei
	di
	ld a,003h
	ld (0a000h),a
	ld (0f0f3h),a
	ei
	call run_piece_at_e9a0
	call draw_piece_at_e9a0
	call place_ship
	call take_upgrade
	call run_options
	call run_nine_shots
	call check_fire
	call 0a17fh
	call run_twelve_objects
	call release_stretch_enemies
	call drop_rock
	call run_ten_at_e500
	call release_what_is_due
	call release_enemies_on_column
	call run_background_objects
	call run_four_at_e880
	call release_background_objects_on_column
	call run_four_at_e800
	call dispatch_boss_step
	call run_enemy_wave
	call run_five_pieces
	call check_boss_collisions
	call draw_shots
	call run_four_at_e800_and_ea80
	call run_e780_and_ea00
	call note_cells_of_the_five
	call dispatch_boss_step_2
	call paint_background_or_bank3
	call draw_the_five
	call paint_turrets
	call run_ship
	call erase_shots
	call note_all_cells
	call run_sprites
	call blink_two_characters
	call upload_screen
	call paint_whole_frame
	ld a,(0e003h)		; One frame in eight
	and 007h
	dec a
	ret nz
	jp draw_scores		; ...it is time to refresh the score
start_scroll:		; Moves the distance counter back 0x20 and leaves the screen pointer at 0xED00, with 0x20 steps to take
	xor a
	ld (0ec04h),a		; 0xEC04 to zero
	ld hl,(0e063h)		; 0x20 less on the distance covered
	ld de,00020h
	sbc hl,de
	ld (0e063h),hl
	ld hl,0ed00h		; 0xED00: where it starts reading the screen
	ld (0ec00h),hl
	ld b,020h		; Thirty-two steps

; (Falls through into scroll_and_sprites.asm, which the link places right after.)

	end

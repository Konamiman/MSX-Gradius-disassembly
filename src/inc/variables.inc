; The game's RAM, from 0xE000 up, and the two MSX system variables it
; touches, in address order.
;
; Names given from what the code does with each address; the comments
; next to the code say more. A table is defined by its base (and, where the
; code uses them, its element size and count), and an address inside it is
; written as an expression on the base. A few addresses have two names:
; the game reuses that RAM for something else at another time.

; ==========================================================================
; 0xE000-0xE0FF
; ==========================================================================

GAME_RAM                 equ 0E000h  ; Start of the game's 4 KB of RAM (0xE000-0xEFFF) that INIT clears; shares the address with GAME_STATE (4096 bytes)
GAME_STATE               equ 0E000h  ; State of the state machine at 0x52B7, 0 to 7; a game is running from 4 on
GAME_SUBSTATE            equ 0E001h  ; Substate within the current state (read together with GAME_STATE as BC)
GAME_FLAGS               equ 0E002h  ; Game flags: bit 5 two players, bit 6 a game is running, bit 7 whose turn (0 = player 1)
FRAME_COUNT              equ 0E003h  ; Counts the runs of the interrupt; its low bits pace blinking and periodic actions
STATE_TIMER              equ 0E004h  ; Frames of waiting left in the current state; also the row count of the curtain wipe
INTERRUPT_LOCK           equ 0E005h  ; Bit 0 set while the game loop runs inside the interrupt, so it is not entered again
DEMO_STAGE               equ 0E006h  ; Stage the next demo plays, 1 to 8 and back to 1
VAR_E007                 equ 0E007h  ; Only cleared by start_demo, together with CONTROLLER
CONTROLLER_NEW           equ 0E008h  ; Controller bits that have just been pressed this frame (bit 4 fire, bit 5 the other button)
CONTROLLER               equ 0E009h  ; Joystick and keyboard merged: bits 0-3 directions, bit 4 fire, bit 5 the other button
LOGO_ROWS                equ 0E00Ah  ; Rows left for the logo to rise (starts at 0x0E)
DEMO_FRAMES              equ 0E00Bh  ; Frames left in the current step of the demo recording
DEMO_INPUT               equ 0E00Ch  ; Joystick value of the current step of the demo recording
DEMO_STEP                equ 0E00Dh  ; Index of the step (byte pair) of the demo recording being played
LOGO_CURSOR              equ 0E00Eh  ; VRAM address where the rising logo is painted; goes up one row (0x20) per step

; ---- The sound player (0xE010..0xE04C)

; ---- The three channel cards
;
; A channel is a card of 0x11 bytes and a stream of commands. The player keeps
; three identical cards, at 0xE010, 0xE021 and 0xE032: byte 0 is the countdown
; of the note that is sounding, 1 its length, 2 the mode, 3 and 4 where its
; command stream has got to, 5 the switches (tone, noise and envelope), 6 the
; octave shift, 7 to 9 the volume and its decay, 0x0B the time unit, 0x0C the
; sharp, 0x0D and 0x0E the envelope times, and 0x0F and 0x10 the last period
; written. Everything that sounds comes from reading those streams byte by
; byte.

SND_CARD_A	equ	0E010h
SND_CARD_B	equ	0E021h
SND_CARD_C	equ	0E032h
CARD_SIZE	equ	11h

; Fields of a card (offsets for IX)

CARD_COUNTDOWN	equ	00h	; Frames left of the note that is sounding
CARD_LENGTH	equ	01h	; Length of the note
CARD_MODE	equ	02h	; Mode; zero = the channel does not sound, bit 7 = melody mode
CARD_STREAM	equ	03h	; (word) Where the command stream has got to
CARD_SWITCHES	equ	05h	; Bit 0 tone, bit 1 noise, bit 3 envelope
CARD_OCTAVE	equ	06h	; Octave shift
CARD_START_VOLUME equ	07h	; Starting volume (melody mode)
CARD_VOLUME	equ	08h	; Current volume
CARD_DECAY	equ	09h	; When the note starts to decay
CARD_LAPS	equ	0Ah	; Laps done by the 0xFE repeat command
CARD_TIME_UNIT	equ	0Bh	; How long one beat lasts
CARD_SHARP	equ	0Ch	; Non-zero: one semitone up
CARD_ENV_TIME	equ	0Dh	; Envelope time (high nibble of the 0xFx parameter)
CARD_DECAY_FLOOR equ	0Eh	; Floor of the decay (low nibble of the 0xFx parameter)
CARD_PERIOD	equ	0Fh	; (word) Last period written to the PSG

; ---- Mix and mute

SND_MIX		equ	0E043h	; Current value of PSG register 7
SND_MUTE	equ	0E044h	; Mute countdown; while non-zero the channels fade out
SND_MUTE_STEP	equ	0E046h	; Mute step, subtracted from the volume

; ---- The noise effect (takes over channels A and B while it runs)

NOISE_FX_ON	equ	0E047h	; Non-zero while the effect is running
NOISE_FX_NEW	equ	0E048h	; First frame of the effect; then its four counters
NOISE_FX_OUTER	equ	0E04Ah	; Outer counter: steps left
NOISE_FX_VOLUME	equ	0E04Bh	; Current volume of the effect
NOISE_FX_DIRTY	equ	0E04Ch	; Non-zero if the effect overwrote the PSG registers

; ==========================================================================
; 0xE000-0xE0FF (continued)
; ==========================================================================

INTRO_CONTROLLER         equ 0E051h  ; Controller state in the intro, for just_pressed (which leaves the new presses in 0xE050)
INTRO_CHOICE             equ 0E052h  ; Option selected in the intro: 0 one player, 1 two players
HISCORE                  equ 0E053h  ; High score, BCD; the three bytes from HISCORE+1 hold the digits, lowest first (4 bytes)
SCORE_P2                 equ 0E057h  ; Player 2's score, same layout as HISCORE (4 bytes)
SCORE_P1                 equ 0E05Bh  ; Player 1's score, same layout as HISCORE (4 bytes)
IN_PLAY                  equ 0E05Fh  ; Non-zero while a life is being played (or the demo runs); cleared when the ship's death ends
LIVES                    equ 0E060h  ; Lives of the player whose turn it is, BCD; first of the 0x30 bytes swapped with OTHER_PLAYER
STAGE                    equ 0E061h  ; Current stage, 1 to 12
SCROLL_BIT               equ 0E062h  ; Bit rotated left on every scroll step; paces the half-speed scroll and the star blinking
DISTANCE                 equ 0E063h  ; Distance travelled in the stage, in scroll steps
STAGE_END_STEP           equ 0E065h  ; Step of the end-of-stage sequence
STAGES_PLAYED            equ 0E066h  ; Stages played; sets the difficulty from the ninth stage onwards
NEXT_EXTRA_LIFE          equ 0E067h  ; Score for the next extra life, as the two top BCD bytes of the score (starts at 0x0010)
LOOP_NUMBER              equ 0E06Ah  ; Which loop of the game it is on: 0 the first
METER_AT_DEATH           equ 0E06Bh  ; Power-up meter slot saved when the ship's death ends; non-zero puts the meter on 1 at the restart
TARGET_KIND              equ 0E06Ch  ; Kind of the last bonus target touched; 0xE06D counts the different kinds
HYPER_USED               equ 0E06Eh  ; Non-zero once the HYPER cheat has been used (only once per game)
CONTINUE_ASKED           equ 0E06Fh  ; Non-zero when continue has been requested at the game over
ENDING_INDEX             equ 0E070h  ; Loops completed modulo 5: picks the end-of-loop message
CHEAT_PRIZE_TAKEN        equ 0E071h  ; Non-zero once a typed cheat prize was given on this stage; no other is accepted
OTHER_PLAYER             equ 0E090h  ; The other player's copy of the 0x30 bytes from LIVES (48 bytes)

; ==========================================================================
; 0xE100-0xE1FF
; ==========================================================================

MIRROR_KIND              equ 0E100h  ; While the stage characters load, which mirror is built: 0 bits (horizontal), 1 bytes (vertical). Shares the RAM with NEW_COLUMN
NEW_COLUMN               equ 0E100h  ; One on the scroll steps that bring in a new map column. First byte of the 0xE00 bytes cleared per stage. Shares the RAM with MIRROR_KIND
MAP_RANGE_START          equ 0E101h  ; Distance where the stage's map script starts (from the table at 0x4499). Shares the RAM with MIRROR_BYTES
MIRROR_BYTES             equ 0E101h  ; While the stage characters load, bytes of the character being mirrored (its count times eight). Shares the RAM with MAP_RANGE_START
MAP_RANGE_END            equ 0E103h  ; Distance where the stage's map script ends (from the table at 0x4499)
SCROLL_LIMIT             equ 0E105h  ; Distance up to which the stage scrolls
SCROLL_AT_LIMIT          equ 0E107h  ; One when the distance has reached SCROLL_LIMIT: no new column on this step
ENEMY_SCRIPT_ROW         equ 0E108h  ; Which entry of the enemy script it is on
BG_SCRIPT_ROW            equ 0E109h  ; Which row of the background objects script it is on
BIG_PIECE_BLOWN          equ 0E10Ah  ; Set to one when a type 7 boss piece is blown up; ends the wait for the ship to rise
PAUSE_COUNT              equ 0E10Bh  ; Presses of the pause key: even is play, odd is pause
PAUSE_KEY_PREV           equ 0E10Ch  ; Previous state of the pause key, to catch a new press
PAUSE_JOYSTICK           equ 0E10Dh  ; Copy of the joystick (0xE009) as it was when paused
START_DELAY              equ 0E10Fh  ; Frames to wait before the stage starts (0x3C)
ENEMY_SHOT_SPEED         equ 0E110h  ; Speed of the enemy shot being aimed
DIFFICULTY               equ 0E111h  ; The difficulty, 0 to 0x0F: round times four plus the stage, capped
NEW_SHOT                 equ 0E112h  ; One when a shot is already coming out this frame; cleared every frame
PENDING_MUSIC            equ 0E113h  ; Music change noted by the music-by-distance check, launched when the channel goes quiet
MUSIC_HOLD               equ 0E114h  ; Set when a boss comes on: the music-by-distance check does nothing
AIM_TOO_CLOSE            equ 0E115h  ; Set by the aiming when the ship is right on top of the shooter: no shot
BOSS5_SCRIPT             equ 0E116h  ; Step of the stage 5 boss script, sixteen round and round
BOSS5_MOVING             equ 0E117h  ; Set past distance 0x1A0: the stage 5 boss is moving
SPAWN_TYPE               equ 0E120h  ; Type of the object spawn_object is setting up
SPAWN_ADJUST             equ 0E121h  ; The adjustment byte (C) passed to spawn_object
ENEMY_SCRIPT_BYTE        equ 0E122h  ; The whole byte of the current enemy script entry (bits 5-6 pick the drawing)
MOVER_TYPE               equ 0E123h  ; Type of the object whose mover is running
SPAWNED_TYPE             equ 0E124h  ; Type of the object just spawned; zero if there was no free slot
MARK_COUNTER             equ 0E125h  ; Enemies requested so far; its low nibble walks the mark table at 0xA5C7
LIVE_OBJECTS             equ 0E126h  ; Count of live objects in the object tables
STAGE_SCRIPT_ROW         equ 0E127h  ; Which row of the stage script it is on
CAPSULE_STREAK           equ 0E128h  ; Capsules picked up in a row, up to seven; sets how much the next one pays
WAVE_TIMER               equ 0E129h  ; Frames left until the next stretch enemy wave (starts at 0x40)
METER_SLOT               equ 0E130h  ; Selected slot of the power-up meter (0: none, 1 to 6); METER_SLOT+n is that slot's flag
METER_HELD               equ 0E131h  ; One flag per meter slot: one if the ship already has that upgrade (6 bytes)
ENEMY_WAVE               equ 0E140h  ; Type 0x0F enemy wave under way: 0 none, 1 alternating top and bottom, 2 from ENEMY_WAVE_X
ENEMY_WAVE_X             equ 0E141h  ; High byte of the mode 2 spawn position; starts at 0xD0 and moves 8 left with each new column
ENEMY_WAVE_VSPEED        equ 0E142h  ; First speed word given to each wave enemy (fields 7-8)
ENEMY_WAVE_HSPEED        equ 0E144h  ; Second speed word given to each wave enemy (fields 9-10)
ENEMY_WAVE_POS           equ 0E146h  ; Position the next wave enemy comes out at
ENEMY_WAVE_LEFT          equ 0E148h  ; Wave enemies still to come out
BOSS_DONE                equ 0E150h  ; Set to one when the boss (or the end-of-stage wave) is over; the end-of-stage steps wait for it
BOSS_STATE               equ 0E151h  ; 0: no boss; 1: starting; 2 or more: running
BOSS_KIND                equ 0E152h  ; Which boss: indexes the seven-entry boss dispatch tables
BOSS_TIMER               equ 0E153h  ; Frames left in the current boss step
CORE_DEAD                equ 0E155h  ; Set to one when the boss core has been blown up
PIECE_TIMER              equ 0E156h  ; Frames until the boss releases the next piece
PIECE_PREV_HEIGHT        equ 0E158h  ; Height chosen for the previous boss piece
PIECE_HEIGHT             equ 0E159h  ; Which of the four heights the boss piece gets; also a loop counter over the piece slots
SHOT_BURST               equ 0E15Ah  ; Shots left in a burst of three from a boss piece; rock_walls reads it as a pair index
HEIGHT_PIECES            equ 0E15Bh  ; How many boss pieces there are at each of the four heights (4 bytes)
FILE_WAVE_STEP           equ 0E160h  ; Which step the single file wave is on (0: not started)
FILE_WAVE_LEFT           equ 0E162h  ; Enemies of the wave still to come out (six per wave)
FILE_WAVE_TYPE           equ 0E163h  ; Enemy type of this wave
FILE_WAVE_ALT            equ 0E164h  ; Zero when the wave number's two low bits are zero, one otherwise
FILE_WAVE_HEIGHT         equ 0E165h  ; Height at which the whole wave comes in
FILE_WAVE_NUMBER         equ 0E166h  ; Wave number, up by one per wave, skipping zero
SPRITE_ROTATION          equ 0E17Fh  ; Offset of the rotating sprite upload: up 0x1C per frame, wrapping at 0x7C
FIRE_HELD                equ 0E180h  ; Frames the fire button has been held (zero when released)
OPTION_ANIM_DELAY        equ 0E182h  ; Frame counter: the options' drawing advances every two frames
OPTION_FRAME             equ 0E183h  ; Which of the four drawings the options are on
DOUBLE_NO_ROOM           equ 0E184h  ; Set to one when there is no free slot for the double shot
BOSS_PHASE               equ 0E190h  ; Step of the current boss or core (index of its step dispatcher)
FADE_STEP                equ 0E1A0h  ; Which step the boss death fade is on
FADE_ROW                 equ 0E1A1h  ; Which row the fade is on
FADE_MASK                equ 0E1A2h  ; This round's mask (starts at 0xF0)
FADE_DONE                equ 0E1A3h  ; Set to one when the fade is finished: bank 2 takes the boss as dead
FIVE_PIECES_ON           equ 0E1B0h  ; Set while the five pieces at 0xEB00 are active
FIVE_PIECES_X            equ 0E1B2h  ; Horizontal position of the group; starts at 0xF8, 8 left with each new column
FIVE_PIECES_TIMER        equ 0E1B4h  ; Frames until the next step of the five pieces (reloaded from the next byte)
FIVE_PIECES_LOOP         equ 0E1B6h  ; Loop counter over the five pieces
SCROLL_MODE              equ 0E1C0h  ; 0: scroll every other step; 1: screen stopped (target touched); 2: scroll on every step
TARGET                   equ 0E1C1h  ; The target at the end of the stage: type (zero if none), row and column (3 bytes)
STOP_TIMER               equ 0E1C5h  ; Frames the screen stays stopped after the target is touched (0x40)
ENDING                   equ 0E1D0h  ; Non-zero while the ending sequence (the final explosion) runs
ENDING_STEP              equ 0E1D1h  ; Which of the ten steps of the ending sequence it is on
ENDING_TIMER             equ 0E1D2h  ; Frames left of the current ending drawing or cell
ENDING_SHIP_Y            equ 0E1D3h  ; Offset added to the ship's position in the ending; up 0x40 per frame
SHRAPNEL_LEFT            equ 0E1D5h  ; What is left of the final explosion (starts at 0xC0)
SHRAPNEL_DELAY           equ 0E1D7h  ; Frames until the next piece of shrapnel: one every three
SHRAPNEL_LIVE            equ 0E1D8h  ; Count of live shrapnel pieces
ENDING_DRAWING           equ 0E1D9h  ; Which drawing, or which lit cell of the power-up meter, the ending is on
SLOW_MSG_DELAY           equ 0E1DAh  ; Frames until the next letter of the slow message: one every six
SLOW_MSG_VRAM            equ 0E1DBh  ; VRAM cell where the next letter of the slow message goes
SLOW_MSG_TEXT            equ 0E1DDh  ; Pointer to the next letter of the slow message
TYPED_COUNT              equ 0E1E0h  ; Keys typed so far while paused, up to eight
TYPED_LAST_KEY           equ 0E1E1h  ; Previous key read: only a new key counts
TYPED_KEYS               equ 0E1E8h  ; The keys typed while paused, compared with the cheat words on RETURN (8 bytes)
STAGE3_BG_HIT            equ 0E1FFh  ; Set to one when a shot hits a stage 3 background object

; ==========================================================================
; 0xE200-0xE2FF
; ==========================================================================

SHIP                     equ 0E200h  ; The ship's 32-byte card; byte 0 is its state (zero: no ship, bit 7: blown up, 3: shield on) (32 bytes)
SHIP_TIMER               equ 0E201h  ; Frames left in the ship's current state; with the shield on, what is left of it (starts at 0x0A)
SHIP_SPEED               equ 0E202h  ; Speed upgrade steps taken (the speeds are added to themselves 3 + this many times)
SHIP_ROW                 equ 0E204h  ; The ship's row (its fraction is the byte before, SHIP+3)
SHIP_COLUMN              equ 0E206h  ; The ship's column (its fraction is the byte before, SHIP+5)
OPTION_COUNT             equ 0E20Bh  ; How many options the ship has, 0 to 2
SHIP_SHOT                equ 0E20Ch  ; Weapon byte 12 of the ship's card: the normal shot (0xE20D, byte 13, is the double)
SHIP_LASER               equ 0E20Eh  ; Weapon byte 14: the laser (zero: none)
SHIP_MISSILE             equ 0E20Fh  ; Weapon byte 15: the missile (two: the upgraded one, which falls faster)
OPTIONS                  equ 0E220h  ; The two options' cards, 0x20 bytes each (+4 row, +6 column, +0x0C/0x0D drawing and colour, +0x10 the 16-byte queue of past positions) (64 bytes)
OPTION_SIZE              equ 20h     ; Bytes per option card
SHOTS                    equ 0E260h  ; Nine shot slots of 0x10 bytes: the ship's and each option's shot and double, then the three missiles (144 bytes)
SHOT_SIZE                equ 10h     ; Bytes per shot slot
MISSILES                 equ 0E2C0h  ; The last three shot slots: one missile for the ship and each option (48 bytes)

; ==========================================================================
; 0xE300-0xE3FF
; ==========================================================================

SHRAPNEL                 equ 0E300h  ; Same RAM as OBJECTS, used at that time for thirty-two shrapnel slots of 16 bytes (512 bytes)
OBJECTS                  equ 0E300h  ; Twelve object slots of 32 bytes (type 0x0E is placed counting backwards from the last one) (384 bytes)
OBJECT_SIZE              equ 20h     ; Bytes per object slot (also the ten at ENEMY_SHOTS)
OBJECT_COUNT             equ 0Ch     ; Object slots at OBJECTS
SCREEN_CRITTERS          equ 0E300h  ; Same RAM as OBJECTS, used by the screens image for its eight critter slots of 8 bytes (64 bytes)
MIRROR_PATTERNS          equ 0E300h  ; Same RAM as OBJECTS, used while the stage graphics load as the pattern buffer of the characters being mirrored

; ==========================================================================
; 0xE500-0xE5FF
; ==========================================================================

ENEMY_SHOTS              equ 0E500h  ; Ten more object slots of 32 bytes, used for the enemy and boss shots (320 bytes)
SCREEN_SPAWNERS          equ 0E500h  ; Same RAM as ENEMY_SHOTS, used by the screens image for its three spawners of 8 bytes (24 bytes)

; ==========================================================================
; 0xE600-0xE6FF
; ==========================================================================

CHAR_ANIM                equ 0E6FFh  ; Three (drawing, frames left) pairs for the animated characters 0xF6, 0xF7 and 0xF8; overlaps BG_OBJECTS, used for this at another time (6 bytes)

; ==========================================================================
; 0xE700-0xE7FF
; ==========================================================================

BG_OBJECTS               equ 0E700h  ; Eight background object cards of 8 bytes (64 bytes)
MIRROR_COLOURS           equ 0E700h  ; Same RAM as BG_OBJECTS, used while the stage graphics load as the colour buffer of the characters being mirrored
CHANGING_CELLS           equ 0E710h  ; Seven 8-byte cards of map cells that change character (56 bytes)
BOSS_PIECES              equ 0E780h  ; Eight boss piece slots of 0x10 bytes; the first is the core boss (+1 moving, +3 row, +5 column, +6 face, +7 direction, +9 eye drawing, +0x0A frames to next step, +0x0B step count, +0x0C shots left) (128 bytes)
BOSS_PIECE_SIZE          equ 10h     ; Bytes per boss piece slot

; ==========================================================================
; 0xE800-0xE8FF
; ==========================================================================

EXPLOSIONS               equ 0E800h  ; Four explosion slots of 8 bytes, with their mirror at 0xEA80 (32 bytes)
TURRETS                  equ 0E880h  ; Four 8-byte cards: the sliding turrets of stage 5 (32 bytes)

; ==========================================================================
; 0xE900-0xE9FF
; ==========================================================================

GROUPS                   equ 0E900h  ; Four group cards of three bytes: wave number and, twice, how many enemies of the group are left (12 bytes)
TRAIL_COUNT              equ 0E960h  ; Trail of type 4 enemies: how many are still to come out, then the frames until the next one
FLOCK_COUNT              equ 0E962h  ; Flock of eight type 9 enemies: how many are left, then the frames until the next one (or the next flock)
LEFT_ONES_COUNT          equ 0E966h  ; Eight type 5 enemies from the left edge: how many are left, then the frames until the next one
STAGE7_SCRIPT_POS        equ 0E968h  ; Cursor in the stage 7 script at 0xAF3F: which appearance is due
WALKER_FIT_FULLY         equ 0E969h  ; Type 5 walker: at 1 it searches the terrain until it fits in the same frame; at 0, one step of eight points per frame
BOTTOM_FOUR_COUNT        equ 0E96Ah  ; Bottom four (and mixed eight) enemies: how many are left, then the frames until the next one
PAIR_TIMER               equ 0E96Ch  ; Frames until the next pair of type 3 enemies
RAIN_TIMER               equ 0E970h  ; Rock rain: frames of rain left (starts at 0x384)
RAIN_ON                  equ 0E972h  ; Rock rain under way (1) or not (0)
RAIN_COUNTDOWN           equ 0E974h  ; Rock rain: frames until the next rock, then the value it is reloaded from
WALL_ON                  equ 0E978h  ; Rock wall under way: 1 for five rocks one per frame, 2 for three rocks; 0 for none
WALL_ROCK                equ 0E979h  ; Rock wall: which rock is due (counts down)
WALL_COLUMN              equ 0E97Ah  ; Rock wall: the column the rocks fall through (0x40 or 0xC0)
STAGE5_SCRIPT_POS        equ 0E97Dh  ; Cursor in the stage 5 type 0x1B script at 0xB8B4: which line it is on
STAGE5_LINE_BITS         equ 0E97Eh  ; Top five bits of the current type 0x1B script line: band and speed of the enemy
LFLOCK_ON                equ 0E988h  ; Long flock of type 0x1D under way (1) or not (0)
LFLOCK_TIMER             equ 0E989h  ; Long flock: frames left
LFLOCK_RELOAD            equ 0E98Bh  ; Long flock: frames between enemies, reload value for LFLOCK_COUNTDOWN
LFLOCK_COUNTDOWN         equ 0E98Ch  ; Long flock: frames until the next enemy (followed by how many so far)
LFLOCK_VARIANT           equ 0E98Eh  ; Long flock: variant of the next type 0x1D, goes to its byte 19
BIGFLOCK_ON              equ 0E990h  ; Big ones' flock of type 0x1E under way (1) or not (0)
BIGFLOCK_TIMER           equ 0E991h  ; Big ones' flock: frames left
BIGFLOCK_RELOAD          equ 0E993h  ; Big ones' flock: frames between enemies, reload value for BIGFLOCK_COUNTDOWN
BIGFLOCK_COUNTDOWN       equ 0E994h  ; Big ones' flock: frames until the next enemy (followed by how many so far)
BIGFLOCK_DOOR            equ 0E996h  ; Big ones' flock: which of the four doors the next one comes in through
BOSS4_PIECE              equ 0E9A0h  ; Boss 4's extra piece: step, position (two bytes), frame timer, drawing (5 bytes)

; ==========================================================================
; 0xEA00-0xEAFF
; ==========================================================================

FADE_BUFFER              equ 0EA00h  ; Boss death fade: the VRAM block (up to 0x200 bytes) is brought down here, masked and sent back. Shares the RAM with PIECE_MIRROR (512 bytes)
PIECE_MIRROR             equ 0EA00h  ; Map characters saved under the eight pieces at 0xE780, 16 bytes each. The RAM is shared with FADE_BUFFER (128 bytes)
BLAST_MIRROR             equ 0EA80h  ; Map characters saved under the four background explosions at 0xE800, 16 bytes each (64 bytes)

; ==========================================================================
; 0xEB00-0xEBFF
; ==========================================================================

MID_BOSS_PIECES          equ 0EB00h  ; The middle boss's five pieces, slots of 0x20 bytes (160 bytes)
MID_BOSS_PIECE_SIZE      equ 20h     ; Bytes per middle boss piece slot

; ==========================================================================
; 0xEC00-0xECFF
; ==========================================================================

MAP_COLUMN_PTR           equ 0EC00h  ; Pointer into MAP: the column being filled while scrolling. The RAM is shared with PAINT_FLAG, SHOT_PTR, WALL_LIST and FAN_DIRECTION
SHOT_PTR                 equ 0EC00h  ; The ship shot being checked by the collision routines. Shares the RAM with MAP_COLUMN_PTR
WALL_LIST                equ 0EC00h  ; The stage's list of rock wall distances while it is walked. Shares the RAM with MAP_COLUMN_PTR
FAN_DIRECTION            equ 0EC00h  ; Direction (0-15) of the shot of the three-shot fan being inserted. Shares the RAM with MAP_COLUMN_PTR
PAINT_FLAG               equ 0EC00h  ; Non-zero: paint the pieces/background objects; zero: erase them. Shares the RAM with MAP_COLUMN_PTR
PIECE_PTR                equ 0EC02h  ; Pointer into the stage script: the next piece number of the incoming column. The RAM is shared with WALL_OF_THREE and WALL_LIST_LEN
WALL_OF_THREE            equ 0EC02h  ; Rock walls: non-zero for walls of three (stage 8), zero for five (stage 2). Shares the RAM with PIECE_PTR
WALL_LIST_LEN            equ 0EC03h  ; Rock walls: how many distances the list has. Shares the RAM with PIECE_PTR+1
ENTRY_X                  equ 0EC04h  ; Column at which released enemies come in: 0xF8 (right edge), or eight more per step during the start scroll
AIM_ROW_SIGN             equ 0EC10h  ; Aiming: non-zero when the row difference to the ship is negative
AIM_COL_SIGN             equ 0EC11h  ; Aiming: non-zero when the column difference to the ship is negative
AIM_VSPEED               equ 0EC12h  ; Aiming: the vertical speed worked out for the shot
AIM_HSPEED               equ 0EC14h  ; Aiming: the horizontal speed worked out for the shot
AIM_COMPONENT            equ 0EC16h  ; Aiming: the second value read from the table at 0x6853 (complementary angle)
AIM_BASE_ANGLE           equ 0EC17h  ; Aiming: the angle within the quadrant, from the table at 0x6753
SHIP_ANGLE               equ 0EC18h  ; The angle to the ship, with the quadrant from the two signs
SPAWN_POS                equ 0EC19h  ; Position of the object being spawned, parked by spawn_object
SHOTS_PAINT_PASS         equ 0EC1Ah  ; Ship shots pass: 1 when painting, 0 when erasing
TYPE11_DRAWING           equ 0EC1Bh  ; Drawing for the next type 0x11 object
BLAST_SLOT_PTR           equ 0EC1Ch  ; Slot at 0xE800 taken by the last background explosion
BLAST_MIRROR_PTR         equ 0EC1Eh  ; Its place in BLAST_MIRROR
SPRITE_BUFFER            equ 0EC80h  ; Sprite attribute buffer: 32 sprites of four bytes, sent to VRAM every frame (128 bytes)

; ==========================================================================
; 0xED00-0xEDFF
; ==========================================================================

MAP                      equ 0ED00h  ; The stage map: twenty-two rows of thirty-two cells, sent to the name table on every scroll step (704 bytes)
MAP_WIDTH                equ 20h     ; Cells per map row

; ==========================================================================
; 0xF000 and up
; ==========================================================================

STACK_TOP                equ 0F0F0h  ; Initial stack pointer, right below the mapper copy
BANK_6000                equ 0F0F1h  ; RAM copy of the bank mapped at 0x6000
BANK_8000                equ 0F0F2h  ; RAM copy of the bank mapped at 0x8000
BANK_A000                equ 0F0F3h  ; RAM copy of the bank mapped at 0xA000
TWINBEE_FOUND            equ 0F0F4h  ; Non-zero if TwinBee (RC-740) was found in another slot; enables extra graphics
EXPTBL                   equ 0FCC1h  ; Bit 7 of each byte: whether that primary slot is expanded (4 bytes)
H_KEYI                   equ 0FD9Ah  ; Interrupt hook; INIT installs `jp interrupt` here (5 bytes)

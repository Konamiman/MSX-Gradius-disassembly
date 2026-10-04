; ============================================================================
; Sound player - The command interpreter of a channel
; ============================================================================
;
; run_channel fetches the next command from the stream the card points to
; (CARD_STREAM): 0xFE repeats, above 0xFE the channel goes silent, 0x2x sets
; the switches and the length, 0x1x the noise period, and anything else is a
; note. Also the routines that set the note, lower the volume and write the
; volume and the mix.

	include "bios.inc"
	include "variables.inc"

	public run_channel,silence_this_channel,write_volume_and_mix
	extrn write_period,read_melody_command,repeat_stream,save_pointer,set_mix

run_channel:		; A channel's interpreter: fetches the next command from the stream it points to (IX+3, IX+4). 0xFE and the codes above it are control commands; those below, note and length.
	ld a,(ix+CARD_MODE)	; Byte 2: the mode
	bit 7,a			; With bit 7 set, the channel takes another path
	jp nz,run_melody_channel
	dec (ix+CARD_COUNTDOWN)	; Byte 0: the frames the note has left
	ret nz
L_818D:
	ld l,(ix+CARD_STREAM)	; Bytes 3 and 4: where the stream has got to
	ld h,(ix+CARD_STREAM+1)
	ld a,(hl)		; The channel's command byte.
	cp 0feh			; 0xFE is the command that jumps to the start of the bank.
	jp z,repeat_stream
	jp nc,silence_this_channel	; And above 0xFE, the channel goes silent
	ld a,(ix+CARD_MODE)
	bit 7,a			; Bit 7 of the mode
	ld a,(hl)
	jp nz,read_melody_command
	and 0f0h		; Commands 0x2x are the switches
	cp 020h
	jr nz,L_81D7
	ld a,(hl)
	ld (ix+CARD_SWITCHES),a	; Byte 5: tone, noise and envelope
	inc hl
	ld a,(hl)
	ld (ix+CARD_LENGTH),a	; And byte 1: the length
	inc hl
	ld a,(ix+CARD_SWITCHES)
	cp 020h			; A bare 0x20 has nothing after it
	jr nz,L_81C1
	dec hl
	ld b,000h
	jr set_note
L_81C1:
	bit 3,(ix+CARD_SWITCHES)	; Bit 3 of byte 5: it uses the envelope
	jr z,L_81D7
	ld a,(hl)
	ld e,a
	ld a,00ch
	call WRTPSG		; PSG registers 12 and 11: the envelope period.
	inc hl
	ld a,(hl)		; And 11, the low byte
	ld e,a
	ld a,00bh
	call WRTPSG
	inc hl
L_81D7:
	ld a,(hl)		; Command 0x1x: the noise period
	and 0f0h
	cp 010h
	jr nz,L_81E9
	ld a,(hl)
	and 00fh		; Its low nibble, times two
	add a,a
	ld e,a
	ld a,006h
	call WRTPSG		; Register 6: the noise period.
	inc hl
L_81E9:
	ld a,(hl)		; The high nibble: the note
	and 0f0h
	ld b,a
	xor (hl)		; And the low one, with the byte after it: the period
	ld d,a
	inc hl
	ld e,(hl)
set_note:		; Writes the period to the channel's two registers and starts the note's countdown
	call save_pointer
	ex de,hl
	call write_period
	ld a,b
	rrca			; The high nibble, moved down: the volume
	rrca
	rrca
	rrca
	ld h,a
	ld a,(ix+CARD_LENGTH)
	ld (ix+CARD_COUNTDOWN),a	; (IX+1) is the length, and it is reloaded into (IX+0), which is the countdown.
	jr write_volume_and_mix
silence_this_channel:		; Byte 2 to zero, with no drawing and no switches
	xor a			; Byte 2 to zero: the channel does not sound
	ld (ix+CARD_MODE),a
	ld (ix+CARD_SHARP),a
	ld h,a
	ld (ix+CARD_SWITCHES),a
	jr write_volume_and_mix
lower_one_more_step:		; One extra step in the decay
	dec (ix+CARD_DECAY)
lower_volume:		; Byte 8 goes down one at a time to zero
	ld a,(ix+CARD_VOLUME)	; Byte 8: the current volume
	dec a
	ret m			; Not below zero
	ld (ix+CARD_VOLUME),a
	ld h,a
write_volume_and_mix:		; The mix, and the channel's volume (or the envelope, if it uses one)
	call set_mix		; The mix, in case it has changed
	ld a,c			; This channel's volume register: 8, 9 or 10
	rrca
	add a,088h
	ld d,a
	bit 3,(ix+CARD_SWITCHES)	; Bit 3 of byte 5: it uses the envelope
	jr z,L_8236
	ld e,h
	ld a,00dh		; Register 13: the envelope shape
	call WRTPSG
	ld a,010h		; And the volume with bit 4: the envelope is in charge
	ld h,a
L_8236:
	ld a,d
	ld e,h
	jp WRTPSG
run_melody_channel:		; With bit 7 of the mode set, the note also fades out on its own: byte 9 says when it starts to decay
	dec (ix+CARD_COUNTDOWN)	; The frames the note has left
	jp z,L_818D		; Run out: on to the next command
	dec (ix+CARD_DECAY)	; Byte 9: when it starts to decay
	ld a,(ix+CARD_DECAY)
	cp (ix+CARD_COUNTDOWN)
	jr nz,lower_one_more_step
	ld e,a
	ld a,(ix+CARD_DECAY_FLOOR)	; Byte 14: the floor of the decay
	cp e
	ld a,e
	jr nc,lower_volume
	ret

	end

; ============================================================================
; Nemesis / Gradius - main image (banks 0-3) - stage5_characters.asm
; ============================================================================

	public advance_background_script,check_falling_pieces_script,erase_stage_5_background,erase_turrets,paint_stage_5_background,paint_turrets

; ----------------------------------------------------------------------
; IN STAGE 5 THE BACKGROUND IS PAINTED WITH CHARACTERS, NOT SPRITES
; The background objects of the fifth stage have no sprite card: they are
; rectangles of characters written into the map. That is why there are two
; twin routines called one frame apart: first they are erased (0xEC00 to
; zero, which sends them to clear_rectangle) and then, once moved, they
; are painted again (0xEC00 to 0xFF, which sends them to
; copy_rectangle). The turret is also painted half way while it peeks
; out: only as many of its rows are drawn as it has out.
; ----------------------------------------------------------------------
paint_stage_5_background:		; The eight cards at 0xE700, painted as rectangles of characters
	ld a,0ffh		; 0xEC00 to 0xFF: paint
	ld ix,0e700h
	ld b,008h		; Eight cards
	ld (0ec00h),a
L_B3DD:
	push bc
	call paint_background_piece
	pop bc
	ld de,00008h		; Eight bytes per card
	add ix,de
	djnz L_B3DD
	ret
paint_background_piece:		; Types 1 to 4, a five by five block; from 5 onwards, whatever its table says
	ld a,(ix+000h)		; An empty card is not painted
	and a
	ret z
	cp 005h			; From type 5 onwards, elsewhere
	jp nc,paint_big_piece
	ld a,(ix+006h)		; Byte 6 picks the drawing in the table at 0xB537
	ld hl,0b537h
	call 047aeh
five_by_five:		; Types 1 to 4 measure five cells by five
	ld bc,00505h
paint_or_erase:		; With 0xEC00 at zero it erases, and otherwise it copies
	ld l,(ix+002h)		; Its row and its column
	ld h,(ix+003h)
	ld a,(0ec00h)		; 0xEC00 says whether to paint or to erase
	and a
	jp z,048f7h
	jp 0490ch
erase_stage_5_background:		; 0xEC00 to zero and walk the same eight cards
	xor a
	ld (0ec00h),a
	jr five_by_five
paint_big_piece:		; Types 5 to 8 carry their size in front of the characters
	ld a,(0ec00h)		; These are not erased, only painted
	and a
	ret z
	ld a,(ix+000h)
	sub 005h
	ld hl,0b749h		; The table at 0xB749: one pointer per type
	call 047aeh
	ex de,hl
	ld c,(hl)		; The first two bytes are the width and the height
	inc hl
	ld b,(hl)
	inc hl
	ex de,hl
	jr paint_or_erase
erase_turrets:		; 0xEC00 to zero
	xor a
	jr L_B439
paint_turrets:		; Only in stage 5, and with 0xEC00 at 0xFF
	ld a,(0e061h)		; Only stage 5 has turrets
	cp 005h
	ret nz
	ld a,0ffh
L_B439:
	ld (0ec00h),a
	ld ix,0e880h
	ld b,004h		; Four cards
L_B442:
	push bc
	ld a,(ix+000h)
	and a
	call nz,paint_turret
	pop bc
	ld de,00008h		; Eight bytes per card
	add ix,de
	djnz L_B442
	ret
paint_turret:		; Once fully out, four by four; while peeking out, only the rows it has out
	ld a,(ix+001h)		; Byte 1: whether it has finished coming out
	and a
	jr z,turret_peeks_out
	ld a,(ix+006h)		; Byte 6 picks between the two drawings
	ld de,0b729h
	and a
	jr z,L_B465
	ld de,0b739h
L_B465:
	ld bc,00404h		; Four cells by four
paint_or_erase_turret:		; Same as the background: 0xEC00 decides
	ld l,(ix+002h)		; Its row and its column
	ld h,(ix+003h)
	ld a,(0ec00h)		; 0xEC00 says whether to paint or to erase
	and a
	jp z,048f7h
	jp 0490ch
turret_peeks_out:		; Only what it has out is drawn: byte 5 says how many rows
	ld a,(ix+000h)
	dec a
	jr nz,L_B489
	ld de,0b729h
	ld b,004h
	ld c,(ix+005h)		; Byte 5: the rows it has out
	inc c
	jr paint_or_erase_turret
L_B489:
	ld de,0b729h		; The table at 0xB729, read from the end
	ld a,(ix+005h)
	ld c,a
	sub 003h		; Three minus the rows it has out, times four
	neg
	add a,a
	add a,a
	call 04062h
	ld b,004h
	inc c
	jr paint_or_erase_turret
advance_background_script:		; Skips in one go the lines that are already behind the distance travelled
	call set_up_this_background_piece
	jr z,advance_background_script
	ret c
	ld hl,0e109h		; 0xE109: which line the background script is on
	inc (hl)
	jr advance_background_script
check_falling_pieces_script:		; On every step with a new column, sets up the background pieces that fall at this distance
	ld a,(0e100h)		; Only on steps with a new column
	and a
	ret z
	ld a,0f8h		; 0xEC04 to 0xF8: they come in from the right
	ld (0ec04h),a
set_up_due_ones:		; One after another as long as they match
	call set_up_this_background_piece
	jr z,set_up_due_ones
	ret
set_up_this_background_piece:		; Four bytes per line: the distance, the row and the type; on a match, a card at 0xE700 is taken
	ld a,(0e109h)		; The table at 0xB7BF: four bytes per line
	add a,a
	add a,a
	ld hl,0b7bfh
	call 0405dh
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld hl,(0e063h)		; DCOMPR against the distance travelled
	rst 20h
	ret nz
	ld hl,0e109h
	inc (hl)		; One line fewer
	ld hl,0e700h		; The eight cards at 0xE700
	ld e,008h
	xor a
L_B4DB:
	ld a,(hl)		; The first one with its first byte at zero
	and a
	jr z,L_B4E8
	ld a,008h
	add a,l
	ld l,a
	dec e
	jr nz,L_B4DB
	xor a			; With no free card, nothing is set up
	ret
L_B4E8:
	ld a,b			; The type, in the first byte
	inc a
	and 00fh
	ld (hl),a
	cp 005h			; From type 5 onwards, another card
	jr nc,set_up_big_one
	ld a,(0ec04h)		; The small ones only come in from the right
	cp 0f8h
	jr z,set_up_small_one
	ld (hl),000h
	ret
set_up_small_one:		; Row from the table, column 0xC0, and sound 0x0C
	inc l
	ld (hl),000h
	inc l
	ld (hl),c
	inc l
	ld (hl),0c0h		; Column 0xC0
	inc l
	ld (hl),008h
	inc l
	ld (hl),00fh
	inc l
	ld a,b			; Byte 6 comes from the type times six
	add a,a
	ld e,a
	add a,a
	add a,e
	ld (hl),a
	inc l
	ld (hl),000h
	ld a,00ch		; Sound 0x0C
	call 049deh
	xor a
	ret
set_up_big_one:		; Row from the table and column 0xEC04, with the type's high nibble in byte 7
	inc l			; Byte 1 to zero
	ld (hl),000h
	inc l
	ld (hl),c		; The row the line brought
	inc l
	ld a,(0ec04h)		; The column they all come in at
	ld (hl),a
	inc l
	ld (hl),030h		; 0x30 frames and byte 5 to 0x0C
	inc l
	ld (hl),00ch
	inc l
	ld (hl),a
	inc l
	ld a,b			; The high nibble: the variant
	rra
	rra
	rra
	rra
	and 00fh
	ld (hl),a
	xor a
	ret

; ----------------------------------------------------------------------
; DATA table_B537: Words read by 0xB3F7 with `ld hl,0xB537` (0xB567, 0xB580,
;   0xB599, ...) and, after them, what they point to.
table_B537:
	defw 0B567h,0B580h
	defw 0B599h,0B5B2h
	defw 0B5CBh,0B5E4h
	defw 0B5FDh,0B5FDh
	defw 0B5FDh,0B5FDh
	defw 0B5FDh,0B5FDh
	defw 0B5FDh,0B616h
	defw 0B62Fh,0B648h
	defw 0B661h,0B67Ah
	defw 0B693h,0B6ACh
	defw 0B6C5h,0B6DEh
	defw 0B6F7h,0B710h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 44A1h,0A9A8h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 44A1h,0A9A8h
	defw 4500h,49AEh
	defw 004Ah,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 44A1h,0A9A8h
	defw 4500h,49AEh
	defw 004Ah,0A3A2h
	defw 4BABh,00AFh
	defw 0000h,0000h
	defw 44A1h,0A9A8h
	defw 4500h,49AEh
	defw 004Ah,0A3A2h
	defw 4BABh,0A5AFh	; -> 0x4bab DATA_table_A5AF
	defw 0AC47h,4CAAh	; -> L_AC47 0x4caa
	defw 44A1h,0A9A8h
	defw 4500h,49AEh
	defw 004Ah,0A3A2h
	defw 4BABh,0A5AFh	; -> 0x4bab DATA_table_A5AF
	defw 0AC47h,4CAAh	; -> L_AC47 0x4caa
	defw 0A7A6h,0AD48h
	defw 0A14Dh,0A844h
	defw 00A9h,0AE45h
	defw 4A49h,4600h
	defw 0ABA4h,0AF4Bh
	defw 47A5h,0AAACh
	defw 0A64Ch,48A7h
	defw 4DADh,24C1h
	defw 0C9C8h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,2500h
	defw 29CEh,002Ah
	defw 24C1h,0C9C8h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0C3C2h,2BCBh
	defw 25CFh,29CEh
	defw 002Ah,24C1h
	defw 0C9C8h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0C500h,0CC27h
	defw 2CCAh,0C3C2h
	defw 2BCBh,25CFh
	defw 29CEh,002Ah
	defw 24C1h,0C9C8h
	defw 0000h,0000h
	defw 0000h,0C7C6h
	defw 0CD28h,0C52Dh
	defw 0CC27h,2CCAh
	defw 0C3C2h,2BCBh
	defw 25CFh,29CEh
	defw 002Ah,24C1h
	defw 0C9C8h,0C600h
	defw 28C7h,2DCDh
	defw 27C5h,0CACCh
	defw 262Ch,0CBC4h
	defw 0CF2Bh,0CE25h
	defw 2A29h,0C100h
	defw 0C824h,00C9h
	defw 0DA00h,69D9h
	defw 00D2h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,6E6Fh
	defw 6ADFh,0DA00h
	defw 69D9h,00D2h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,0000h
	defw 0000h,70E0h
	defw 0D4DCh,00D3h
	defw 6E6Fh,6ADFh
	defw 0DA00h,69D9h
	defw 00D2h,0000h
	defw 0000h,0000h
	defw 0000h,7100h
	defw 0DDDBh,0D66Ch
	defw 70E0h,0D4DCh
	defw 00D3h,6E6Fh
	defw 6ADFh,0DA00h
	defw 69D9h,00D2h
	defw 0000h,0000h
	defw 0DE72h,0D86Dh
	defw 71D7h,0DDDBh
	defw 0D66Ch,70E0h
	defw 0D4DCh,00D3h
	defw 6E6Fh,6ADFh
	defw 0DA00h,69D9h
	defw 72D2h,6DDEh
	defw 0D7D8h,0DB71h
	defw 6CDDh,0E0D6h
	defw 0DC70h,6BD5h
	defw 6F00h,0DF6Eh
	defw 006Ah,0D9DAh
	defw 0D269h

; ----------------------------------------------------------------------
; DATA table_B729: Sixteen bytes read by 0xB45C, 0xB47E and 0xB489.
table_B729:
	defb 0B2h,4Eh,52h,0B5h,0B3h,4Fh,53h,0B6h,0B4h,50h,54h,0B7h,00h,51h,55h,00h

; ----------------------------------------------------------------------
; DATA table_B739: Sixteen bytes read by 0xB462.
table_B739:
	defb 0B2h,4Eh,52h,0B5h,0B3h,4Fh,53h,0B6h,0B4h,56h,57h,0B7h,00h,58h,59h,00h

; ----------------------------------------------------------------------
; DATA table_B749: One hundred and eighteen bytes read by 0xB420.
table_B749:
	defb 59h,0B7h,73h,0B7h,8Dh,0B7h,93h,0B7h,99h,0B7h,99h,0B7h,0B3h,0B7h,0B9h,0B7h
	defb 04h,06h,5Ah,00h,00h,00h,00h,5Fh,5Bh,5Ch,5Dh,62h,61h,60h,5Eh,05h
	defb 02h,07h,0Ah,63h,00h,06h,04h,09h,0Bh,00h,04h,06h,00h,3Ch,3Ah,3Fh
	defb 41h,00h,68h,3Bh,38h,3Dh,40h,11h,65h,66h,67h,10h,0Fh,0Eh,64h,00h
	defb 00h,00h,00h,0Dh,01h,04h,5Ch,5Dh,62h,61h,01h,04h,66h,67h,10h,0Fh
	defb 04h,06h,0BCh,00h,00h,00h,00h,00h,05h,02h,07h,0Ah,07h,0BFh,06h,04h
	defb 09h,0Bh,09h,08h,00h,00h,00h,00h,00h,00h,01h,04h,64h,65h,66h,67h
	defb 01h,04h,12h,13h,14h,15h

; ----------------------------------------------------------------------
; DATA table_B7BF: One hundred and thirty-four bytes read by 0xB4BF.
table_B7BF:
	defb 8Dh,00h,78h,00h,96h,00h,08h,02h,99h,00h,58h,02h,0A2h,00h,78h,00h
	defb 0A6h,00h,08h,02h,0ACh,00h,58h,02h,0B6h,00h,78h,00h,0BEh,00h,08h,02h
	defb 0C2h,00h,40h,00h,0C5h,00h,78h,03h,0C9h,00h,08h,03h,0D2h,00h,58h,02h
	defb 0DEh,00h,78h,00h,0E1h,00h,08h,02h,0E6h,00h,28h,45h,02h,01h,60h,44h
	defb 10h,01h,00h,77h,1Ah,01h,40h,25h,22h,01h,40h,24h,2Ch,01h,0A0h,36h
	defb 36h,01h,48h,15h,38h,01h,00h,27h,87h,01h,78h,00h,8Bh,01h,08h,02h
	defb 93h,01h,78h,00h,95h,01h,08h,03h,0A1h,01h,78h,03h,0A3h,01h,08h,02h
	defb 0ABh,01h,78h,00h,0B6h,01h,78h,00h,0B9h,01h,40h,03h,0C2h,01h,78h,00h
	defb 0BCh,01h,00h,47h,0FFh,0FFh

	end

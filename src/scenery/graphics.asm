; ============================================================================
; Nemesis / Gradius - scenery image (banks 4-6) - graphics.asm
; ============================================================================

	public graphics_chain_6000,graphics_chain_6379,graphics_chain_7793,graphics_colours_30A8,graphics_patterns_10A8,graphics_patterns_1160

; Bank 4 (runs at 0x6000).
;
; THIS BANK HOLDS NO CODE. Its 8192 bytes are graphics compressed in the
; decompress format (see tools/rle.py): patterns and colours of each stage's
; scenery. The one that asks for them is routine load_entries in bank 0, which walks
; some six-byte records (flag, colour source, character index, pattern
; source) kept in bank 5, and hands each source to decompress. That is why almost
; no block is pointed at by an `ld de,nnnn`: the address comes from the
; record, not from an instruction.
;
; That the blocks fit one against the other without leaving a single stray
; byte is no accident: it is the proof that the format has been read
; correctly. One byte too many or too few in any of them and the next one
; would start where it should not.

; ----------------------------------------------------------------------
; SCENERY GRAPHICS (bank 4, 8192 bytes)
; The whole bank is a compressed stream for decompress. The splits below are
; the exact places that bank 0 code asks for with an `ld de,nnnn`;
; between one split and the next there are chains of blocks that are
; requested from the six-byte records of bank 5.
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; DATA graphics_chain_6000: Chain of 19 compressed blocks, from 0x6000 to
;   0x62C6, that fit with no slack. They are requested by the records of bank
;   5 (load_entries), not by an instruction with the address written in it.
graphics_chain_6000:
	defb 0A0h,3Dh,0C6h,0BBh,7Dh,7Eh,9Eh,6Fh,0D7h,61h,73h,3Fh,1Eh,00h,00h,00h
	defb 00h,0A7h,0C7h,87h,0Eh,0Ch,18h,30h,40h,0F0h,70h,39h,0Dh,05h,82h,0E1h
	defb 0FEh,88h,01h,07h,1Fh,0FEh,00h,00h,00h,00h,00h,0A0h,04h,18h,10h,31h
	defb 32h,32h,36h,0BAh,0BDh,0BEh,5Fh,5Ch,2Bh,77h,0FBh,0F1h,00h,4Fh,78h,80h
	defb 0BFh,0C0h,0DCh,0E3h,7Fh,0C0h,1Fh,0F0h,00h,0F0h,0Fh,0C0h,88h,0C6h,8Fh,8Eh
	defb 8Eh,0Fh,07h,03h,00h,00h,0A0h,0Eh,3Fh,00h,61h,80h,80h,00h,0BFh,23h
	defb 37h,7Fh,5Bh,0BDh,7Eh,00h,0FCh,0AFh,54h,00h,01h,2Ah,1Fh,00h,00h,03h
	defb 06h,26h,36h,0B7h,0BBh,0DCh,4Eh,0A0h,7Ah,7Ch,79h,0B1h,0C1h,0E6h,0CFh,3Eh
	defb 0E8h,0D0h,0A8h,50h,0A0h,0C0h,20h,0C2h,10h,18h,18h,18h,18h,18h,18h,38h
	defb 38h,72h,72h,0F2h,0E2h,0E6h,0C4h,8Dh,90h,02h,03h,03h,43h,47h,0C7h,8Eh
	defb 8Eh,96h,38h,7Ch,0F4h,0EDh,59h,0B3h,06h,00h,0A0h,1Fh,78h,0FCh,0BFh,1Fh
	defb 1Fh,1Fh,3Bh,7Ch,0FEh,00h,0C3h,81h,81h,83h,0C7h,0FFh,0FEh,7Eh,3Ch,1Ch
	defb 9Eh,0DFh,67h,37h,2Ah,35h,1Fh,0Fh,07h,00h,00h,0A0h,0F8h,1Eh,3Fh,0FDh
	defb 0F8h,0F8h,0F8h,0DCh,3Eh,7Fh,00h,0C3h,81h,81h,0C1h,0E3h,0FFh,7Fh,7Eh,3Ch
	defb 38h,79h,0FBh,0E6h,0ECh,0A4h,5Ch,0F8h,0F0h,0E0h,00h,00h,0A0h,0FFh,0FEh,7Eh
	defb 3Ch,1Ch,9Eh,0DFh,07h,0FFh,7Fh,7Eh,3Ch,38h,79h,0FBh,0E0h,75h,30h,20h
	defb 30h,19h,1Fh,0Fh,03h,0AEh,0Ch,04h,0Ch,98h,0F8h,0F0h,0C0h,00h,0A0h,1Fh
	defb 0BFh,7Fh,7Eh,79h,66h,38h,81h,17h,0BCh,7Eh,7Eh,7Eh,5Eh,26h,9Dh,10h
	defb 79h,0FBh,0F7h,0B7h,4Bh,1Dh,0BEh,0Eh,0DFh,0EEh,0A0h,0CFh,0D7h,9Ah,66h,88h
	defb 1Ch,7Fh,0FEh,0F9h,0B7h,4Fh,0DEh,0DCh,00h,0A0h,20h,22h,22h,23h,0B1h,99h
	defb 0DEh,48h,03h,03h,07h,0Eh,1Ch,0B8h,71h,0EAh,49h,89h,09h,1Bh,33h,0Fh
	defb 0E6h,0B8h,90h,98h,98h,98h,30h,70h,0E0h,0C0h,00h,98h,00h,00h,00h,00h
	defb 00h,00h,01h,01h,00h,00h,18h,0Ch,06h,0C2h,0E3h,0A9h,00h,00h,00h,00h
	defb 40h,60h,20h,30h,00h,0A0h,0E5h,0DBh,0B3h,0F1h,0A5h,0AEh,4Fh,87h,0E3h,0F7h
	defb 0ACh,28h,0DBh,17h,2Eh,0Dh,7Eh,7Ah,0FAh,0F4h,75h,69h,0B5h,8Eh,71h,5Bh
	defb 0EBh,0EDh,0F5h,74h,6Dh,0BBh,88h,0B9h,0BBh,0B7h,37h,0B7h,0D3h,0DBh,0E9h,00h
	defb 90h,00h,00h,00h,00h,00h,07h,1Ch,70h,00h,00h,01h,01h,11h,22h,61h
	defb 62h,00h,88h,01h,01h,01h,00h,00h,00h,00h,00h,00h,0A0h,00h,00h,00h
	defb 03h,0Fh,13h,11h,31h,0AFh,55h,6Ah,3Fh,00h,00h,00h,00h,51h,0E6h,83h
	defb 00h,00h,00h,00h,00h,51h,0B6h,63h,0A0h,0C0h,80h,00h,00h,0A0h,00h,00h
	defb 00h,01h,09h,0Dh,2Eh,76h,7Ah,0E0h,0C0h,80h,80h,00h,00h,00h,00h,00h
	defb 00h,00h,01h,03h,8Fh,7Ch,00h,00h,80h,40h,0A0h,0D0h,0E8h,0D0h,0A0h,00h
	defb 00h,00h,00h,00h,20h,20h,30h,19h,3Bh,73h,0F6h,0E6h,0CEh,9Ch,39h,0E2h
	defb 0E6h,5Ah,0BCh,5Dh,2Bh,17h,9Fh,7Fh,0FEh,0FCh,0F0h,21h,0C3h,17h,37h,98h
	defb 79h,0B3h,0C7h,0EAh,0DCh,1Ch,2Bh,0E7h,7Fh,7Fh,7Fh,80h,0C0h,0FAh,0F5h,0FEh
	defb 00h,00h,00h,00h,10h,08h,04h,06h,00h,98h,00h,00h,00h,01h,01h,03h
	defb 02h,02h,03h,03h,0Fh,1Bh,11h,11h,12h,1Bh,0Fh,07h,02h,01h,01h,01h
	defb 00h,00h,00h,88h,0FFh,0FFh,0FFh,0FFh,00h,00h,00h,00h,00h,90h,0FFh,0C0h
	defb 15h,42h,00h,00h,00h,00h,00h,00h,00h,00h,00h,4Ah,92h,0E2h,00h,90h
	defb 02h,80h,28h,5Ch,0D2h,58h,30h,04h,00h,08h,40h,14h,30h,08h,40h,00h
	defb 00h,88h,00h,0FEh,0FEh,0FEh,0FEh,0FEh,0FEh,0FEh,00h,88h,0F7h,0EFh,6Fh,79h
	defb 1Ah,3Fh,00h,00h,00h,85h,0C0h,80h,0FCh,0E0h,80h,03h,00h,81h,0C0h,0Ah
	defb 00h,05h,0FFh,88h,0CDh,9Fh,0BBh,72h,74h,69h,63h,42h,00h,98h,0CDh,07h
	defb 0B3h,0C3h,0B2h,0DFh,0CFh,0CBh,0C5h,0F3h,0BBh,78h,0F9h,0E1h,0E3h,0EAh,0F6h,0B3h
	defb 0B9h,0Dh,0CCh,84h,0FFh,0FFh,00h

; ----------------------------------------------------------------------
; DATA graphics_colours_30A8: Compressed block that 0x53FF and 0x5408 dump
;   into VRAM 0x30A8 and 0x3160: scoreboard colours.
graphics_colours_30A8:
	defb 87h,00h,0FFh,0C4h,0DDh,0C4h,0F5h,0C5h,03h,00h,85h,44h,5Dh,44h,0DDh,0C4h
	defb 03h,00h,95h,4Eh,0D6h,56h,0D6h,4Fh,00h,00h,0FEh,0A2h,0AAh,0A2h,0AEh,6Eh
	defb 0FEh,00h,00h,0EEh,0E0h,0EAh,0EEh,0EEh,03h,00h,85h,0A2h,0AEh,0A2h,0BBh,0A2h
	defb 03h,00h,91h,2Bh,0EBh,2Bh,0ABh,28h,00h,00h,0FEh,8Eh,0BEh,8Eh,0BEh,8Eh
	defb 0FEh,00h,00h,0F3h,03h,0F5h,81h,0F3h,03h,00h,81h,15h,03h,55h,81h,11h
	defb 03h,00h,90h,37h,57h,37h,57h,31h,00h,00h,0FEh,1Eh,7Eh,1Eh,7Eh,1Eh
	defb 0FEh,00h,00h,04h,0F7h,81h,0F1h,03h,00h,85h,0DCh,0ADh,8Ch,0AFh,0ACh,03h
	defb 00h,91h,63h,0EFh,63h,6Fh,63h,00h,00h,0FEh,1Eh,6Eh,1Eh,6Eh,6Eh,0FEh
	defb 00h,00h,0E3h,03h,0EBh,81h,0E3h,03h,00h,85h,11h,5Bh,1Bh,7Bh,7Bh,03h
	defb 00h,81h,63h,03h,6Bh,91h,63h,00h,00h,0FEh,6Eh,2Eh,0Eh,4Eh,6Eh,0FEh
	defb 00h,00h,0FCh,0F9h,0FEh,00h,0FEh,03h,00h,85h,3Fh,9Fh,3Fh,00h,7Fh,09h
	defb 00h,00h

; ----------------------------------------------------------------------
; DATA graphics_chain_6379: Chain of 75 compressed blocks. The first one
;   (0x6379) is requested by 0x53F6 for VRAM 0x3058; the rest come from the
;   records of bank 5.
graphics_chain_6379:
	defb 02h,08h,02h,1Ch,02h,36h,82h,7Fh,49h,00h,93h,3Fh,7Fh,0E6h,0ECh,0C0h
	defb 80h,60h,0C8h,88h,06h,0C2h,83h,0A9h,0CDh,85h,0C6h,1Fh,3Fh,3Fh,03h,7Fh
	defb 0B1h,21h,62h,98h,90h,30h,20h,68h,60h,0E0h,0C0h,60h,30h,10h,18h,0Ch
	defb 0Dh,0Eh,0Eh,0FCh,80h,46h,73h,39h,1Ch,1Eh,03h,40h,0C1h,91h,91h,31h
	defb 21h,63h,0C3h,0C0h,81h,81h,21h,11h,01h,80h,80h,0CCh,86h,83h,81h,0C0h
	defb 0F0h,0F0h,03h,0F8h,03h,0FCh,83h,0FEh,18h,0Ch,00h,02h,1Fh,0FFh,3Fh,7Fh
	defb 05h,11h,00h,02h,0C7h,0C7h,87h,8Fh,1Fh,1Fh,3Fh,7Fh,80h,80h,0C0h,0A0h
	defb 0E4h,0E6h,90h,88h,0F8h,0F8h,74h,79h,39h,0Fh,01h,00h,02h,01h,10h,0B0h
	defb 0A0h,0E0h,0E0h,70h,2Fh,83h,91h,48h,04h,86h,0E3h,58h,07h,0Fh,1Fh,3Fh
	defb 7Fh,7Fh,00h,00h,02h,00h,04h,0Bh,1Dh,19h,3Bh,77h,0F7h,6Eh,0BEh,0F7h
	defb 0EEh,0CCh,0D8h,94h,0C0h,60h,20h,30h,55h,0E4h,60h,30h,80h,0C0h,0E0h,70h
	defb 3Ch,1Eh,0Fh,03h,00h,00h,01h,02h,0Fh,19h,7Bh,73h,0F6h,6Eh,6Ch,0E8h
	defb 0D8h,0C0h,80h,80h,00h,00h,19h,00h,0F7h,0E7h,0A0h,81h,10h,90h,0D0h,0E0h
	defb 0C0h,0E0h,0F0h,58h,01h,0Eh,43h,60h,10h,3Ch,0Fh,0Bh,88h,87h,0C7h,61h
	defb 0FEh,5Fh,0Dh,86h,0C0h,00h,90h,00h,00h,00h,00h,3Fh,0FFh,0FFh,3Fh,00h
	defb 00h,00h,00h,0F3h,0F3h,0F3h,0F3h,00h,0A0h,00h,00h,00h,0Ah,0Ah,0Ah,0Ah
	defb 0Ah,00h,00h,01h,03h,07h,0F8h,0Fh,1Fh,00h,00h,00h,0AFh,0AFh,0AFh,0AFh
	defb 0AFh,1Fh,3Fh,3Fh,7Fh,7Fh,80h,21h,62h,90h,00h,00h,00h,00h,00h,0Ah
	defb 0Ah,0Ah,01h,01h,03h,03h,07h,07h,0Fh,0F0h,00h,0A0h,42h,63h,69h,74h
	defb 72h,0BBh,9Fh,0CDh,30h,0FCh,84h,0CCh,0Dh,0B9h,0B3h,0F6h,7Dh,30h,18h,0CEh
	defb 0CEh,0E7h,77h,00h,0FCh,30h,5Ch,6Fh,67h,0FBh,0F3h,0E7h,00h,03h,0Fh,02h
	defb 2Fh,87h,4Fh,6Fh,2Fh,00h,7Fh,00h,1Fh,04h,9Bh,84h,00h,3Fh,00h,3Fh
	defb 04h,3Bh,02h,9Bh,8Eh,00h,17h,17h,00h,00h,94h,3Bh,3Bh,00h,0Fh,0Fh
	defb 00h,00h,0E7h,00h,0A0h,00h,80h,60h,77h,38h,10h,23h,0A7h,00h,01h,06h
	defb 0EEh,1Ch,08h,0C4h,0E5h,0A7h,23h,10h,38h,77h,60h,80h,00h,0E5h,0C4h,08h
	defb 1Ch,0EEh,06h,01h,00h,00h,05h,00h,02h,0Fh,81h,00h,00h,9Ah,80h,40h
	defb 00h,00h,13h,0Bh,0C3h,0C1h,40h,30h,30h,00h,0Ch,8Eh,0CFh,0E3h,60h,0F0h
	defb 0F0h,60h,00h,00h,0E3h,0F7h,03h,03h,03h,70h,02h,00h,03h,07h,02h,0Fh
	defb 98h,07h,03h,07h,0Fh,8Bh,0D3h,0D3h,56h,63h,0C1h,3Ch,9Dh,0E9h,0E3h,0C0h
	defb 0C9h,01h,70h,0F8h,0F8h,0Fh,0Fh,0C7h,0E0h,03h,0F0h,0C0h,0E0h,1Fh,1Fh,3Fh
	defb 3Fh,1Fh,1Fh,0Dh,01h,1Dh,3Fh,3Fh,0Eh,3Eh,40h,3Ah,1Eh,3Fh,3Bh,0FCh
	defb 7Ch,79h,0C3h,07h,83h,08h,0DDh,0E9h,0C6h,86h,0CFh,0EFh,0C6h,07h,07h,03h
	defb 11h,38h,10h,00h,00h,0BFh,7Eh,7Fh,7Fh,7Eh,1Ch,3Eh,1Ch,71h,0F8h,70h
	defb 0F8h,70h,00h,03h,01h,0C6h,80h,00h,10h,38h,10h,80h,06h,00h,83h,60h
	defb 0F0h,0FEh,06h,00h,02h,60h,83h,10h,3Bh,17h,03h,07h,0ABh,33h,78h,6Fh
	defb 9Fh,0EEh,0CEh,0D1h,1Dh,1Fh,7Eh,00h,03h,63h,0F0h,0D0h,0C0h,0F0h,0F8h,79h
	defb 33h,03h,03h,01h,00h,00h,01h,10h,76h,7Fh,7Eh,0F6h,7Fh,39h,3Eh,0CEh
	defb 0C4h,0C0h,0CCh,9Eh,1Eh,0Ch,00h,01h,03h,03h,81h,01h,03h,00h,9Ah,3Eh
	defb 7Eh,0FCh,0F4h,0EEh,0C4h,00h,00h,03h,07h,07h,0BFh,7Fh,19h,3Ch,3Bh,80h
	defb 0C0h,0C0h,0C4h,80h,0E0h,0F0h,0FAh,1Fh,3Fh,03h,7Eh,8Bh,3Eh,0Ch,3Ch,0F8h
	defb 0F0h,0F6h,0EFh,0CFh,06h,80h,80h,00h,0Ah,00h,8Eh,01h,03h,07h,07h,0Fh
	defb 1Fh,01h,01h,03h,03h,07h,07h,0Fh,0Fh,05h,00h,9Bh,01h,03h,07h,00h
	defb 00h,0C0h,0F0h,0FCh,0FEh,0C0h,0D0h,80h,0C0h,0C0h,0E0h,0E0h,0F0h,0F0h,0F8h,00h
	defb 00h,80h,0C0h,0E0h,0F0h,0F0h,0F8h,07h,00h,02h,80h,02h,0C0h,85h,0E0h,0F0h
	defb 0F0h,0F8h,0FEh,00h,8Ah,00h,80h,80h,0C0h,0C0h,0F0h,0F8h,0FEh,0CCh,0F0h,06h
	defb 00h,82h,0C0h,07h,06h,00h,82h,0F0h,0C0h,0Ch,00h,81h,0Fh,06h,00h,83h
	defb 3Eh,0E3h,58h,06h,00h,82h,0C0h,70h,06h,00h,82h,0E0h,0FEh,00h,8Dh,00h
	defb 10h,18h,38h,3Ch,3Dh,7Dh,7Fh,00h,00h,02h,46h,0C7h,03h,0EFh,03h,00h
	defb 85h,24h,2Ch,6Eh,0FEh,0FEh,03h,00h,0A5h,28h,3Ch,3Ch,7Eh,5Fh,7Fh,0Ch
	defb 3Ch,18h,79h,0F7h,77h,33h,00h,0DFh,83h,0DFh,0C7h,0E7h,0EFh,1Eh,23h,03h
	defb 06h,83h,87h,0CBh,0CFh,3Fh,7Fh,7Fh,0C3h,0C7h,0E7h,7Eh,3Eh,1Ch,00h,05h
	defb 00h,83h,03h,7Bh,7Bh,05h,00h,91h,0E0h,0C8h,9Ch,00h,00h,30h,30h,0Ch
	defb 0Dh,03h,03h,00h,06h,06h,03h,03h,00h,03h,03h,8Fh,00h,0Fh,1Fh,03h
	defb 3Fh,7Fh,59h,3Ch,7Ch,0FCh,0F8h,0E0h,0FCh,0FEh,9Ah,00h,0BFh,07h,1Fh,0Ch
	defb 07h,0Bh,0Ch,29h,0ABh,0E0h,0F8h,30h,0E0h,0D0h,30h,94h,0D5h,0ABh,29h,0Ch
	defb 03h,07h,0Ch,1Fh,0Fh,0D5h,94h,30h,0C0h,0E0h,30h,0F8h,0F0h,00h,1Ch,0Fh
	defb 07h,08h,0Dh,2Bh,0ABh,00h,38h,0F0h,0E0h,10h,0B0h,0D4h,0D5h,09h,08h,0Fh
	defb 0Ch,1Fh,3Fh,0Fh,00h,90h,10h,0F0h,30h,0F8h,0FCh,0F0h,03h,00h,9Dh,03h
	defb 07h,09h,11h,2Ah,0AFh,00h,00h,0C0h,0E0h,90h,88h,54h,0F5h,0AFh,2Fh,1Ch
	defb 3Fh,1Fh,0Fh,07h,00h,0F5h,0F4h,38h,0FCh,0F8h,0F0h,0E0h,04h,00h,85h,03h
	defb 05h,0Bh,2Fh,0A8h,03h,00h,0B5h,0C0h,0A0h,0D0h,0F4h,15h,0A7h,2Fh,1Fh,3Fh
	defb 1Fh,0Fh,06h,03h,0E5h,0F4h,0F8h,0FCh,0F8h,0F0h,60h,0C0h,01h,03h,04h,0Bh
	defb 17h,1Fh,2Fh,9Fh,80h,0C0h,20h,0D0h,0E8h,0F8h,0F4h,0F9h,0BFh,3Fh,1Fh,0Fh
	defb 0Fh,04h,07h,03h,0FDh,0FCh,0F8h,0F0h,0F0h,20h,0E0h,0C0h,00h,03h,00h,85h
	defb 0Fh,1Ch,38h,38h,3Dh,04h,00h,89h,70h,0F8h,7Ch,9Ch,1Dh,00h,10h,0Fh
	defb 03h,03h,00h,85h,8Ch,48h,0E0h,0E0h,0C0h,06h,00h,85h,03h,07h,13h,30h
	defb 31h,03h,00h,8Ah,0C0h,0E0h,0B0h,10h,80h,39h,3Ch,1Eh,0Ch,01h,03h,00h
	defb 85h,90h,38h,38h,70h,0C0h,06h,00h,85h,07h,0Fh,1Eh,0Ch,21h,03h,00h
	defb 8Ah,0C0h,0A0h,00h,00h,98h,31h,30h,38h,1Fh,0Eh,03h,00h,85h,9Ch,1Ch
	defb 18h,30h,40h,06h,00h,85h,0Fh,1Eh,3Ch,3Ch,19h,03h,00h,8Ah,80h,00h
	defb 70h,78h,9Ch,01h,30h,1Bh,0Fh,03h,03h,00h,85h,9Ch,0Ch,88h,0C0h,80h
	defb 03h,00h,00h,10h,00h,00h,02h,0E7h,08h,00h,02h,0E7h,08h,00h,02h,0E7h
	defb 08h,00h,02h,0E7h,00h,02h,0FFh,08h,00h,02h,0FFh,08h,00h,02h,0FFh,08h
	defb 00h,02h,0FFh,00h,85h,3Ch,7Ah,76h,7Eh,3Ch,03h,00h,0D8h,1Fh,3Fh,7Fh
	defb 7Fh,3Fh,1Fh,00h,00h,0F0h,0F8h,0FCh,0ECh,98h,0E0h,00h,00h,0Fh,3Dh,7Bh
	defb 7Fh,3Fh,0Fh,00h,00h,0Eh,0FCh,0F0h,0FEh,0F8h,0C0h,00h,00h,0C0h,0F8h,0FCh
	defb 0DCh,38h,0E0h,00h,00h,3Fh,1Fh,00h,7Fh,19h,7Fh,00h,00h,0FCh,0F8h,00h
	defb 0FEh,0F0h,0FCh,00h,00h,0D7h,0EBh,0F4h,0E9h,0F5h,0E8h,0D7h,0EFh,0DCh,0BEh,7Fh
	defb 7Dh,7Fh,5Eh,0ADh,0DAh,0Fh,1Fh,0DFh,0D7h,0EBh,0A7h,0DBh,3Ch,0A0h,0EBh,0D3h
	defb 0F8h,0F6h,0EFh,0DDh,3Dh,00h,03h,00h,03h,01h,02h,00h,82h,3Dh,1Bh,03h
	defb 07h,89h,03h,00h,00h,0BBh,0DEh,0E0h,0A0h,60h,0C0h,03h,00h,81h,03h,03h
	defb 07h,83h,05h,02h,01h,03h,00h,85h,80h,00h,80h,00h,00h,00h,84h,00h
	defb 3Eh,1Ch,0FEh,03h,0FFh,0ACh,0FEh,00h,01h,0Fh,3Fh,0FCh,0F9h,0E3h,8Fh,0FCh
	defb 0F9h,71h,62h,8Eh,9Ch,3Ch,78h,7Fh,3Fh,1Fh,1Fh,3Fh,3Fh,7Fh,7Fh,0E0h
	defb 0C0h,0FEh,0FCh,0F8h,0F0h,0E0h,0C0h,0E0h,0C0h,0FEh,0FCh,0F8h,0F0h,0F0h,0E0h,7Fh
	defb 3Fh,3Fh,03h,1Fh,9Bh,3Fh,7Fh,03h,07h,07h,03h,06h,1Fh,3Fh,1Fh,80h
	defb 0C1h,7Fh,1Fh,7Fh,1Fh,0B1h,7Dh,0F5h,0EAh,0D5h,0AAh,0D4h,0EEh,0AFh,0Eh,07h
	defb 04h,0Fh,82h,1Fh,7Fh,03h,0FFh,86h,7Fh,0Fh,7Fh,1Fh,0B1h,7Dh,03h,01h
	defb 85h,00h,06h,1Fh,3Fh,1Fh,00h,0A0h,00h,01h,03h,03h,17h,3Bh,77h,3Bh
	defb 0F8h,0FCh,0FEh,84h,82h,0FEh,3Ch,0FEh,1Fh,3Eh,03h,3Ch,0FEh,0C7h,83h,01h
	defb 0B8h,0D0h,0D0h,0C0h,1Ch,3Eh,0BEh,0BEh,03h,00h,0A5h,1Ch,7Fh,63h,0C1h,80h
	defb 75h,4Eh,0BCh,80h,0C0h,0CFh,0DFh,0BBh,0BEh,3Eh,0DEh,0ECh,0F3h,0F7h,0CDh,0F3h
	defb 01h,0C7h,3Bh,0FBh,0F7h,0E6h,0F6h,0E7h,0C0h,0E0h,0E0h,0C0h,4Eh,0F6h,0FCh,78h
	defb 00h,8Fh,01h,07h,0Fh,3Fh,0F8h,0C0h,03h,00h,80h,0E0h,0D0h,0C8h,0C3h,0C3h
	defb 0E7h,04h,00h,9Bh,0Ch,0Eh,1Eh,3Fh,0FAh,01h,07h,0Fh,1Bh,17h,2Bh,37h
	defb 2Bh,0FCh,0FCh,0FEh,8Ch,02h,00h,3Ch,0FDh,7Fh,3Fh,7Fh,00h,04h,0Fh,04h
	defb 00h,8Eh,0FDh,0EAh,55h,3Fh,9Fh,8Fh,0F5h,0AAh,54h,0A0h,00h,0FEh,0FDh,0FBh
	defb 04h,00h,84h,19h,0FDh,0FFh,0FFh,03h,00h,8Dh,0C0h,0E0h,0F2h,0FDh,00h,0Fh
	defb 00h,0F6h,0C5h,0EDh,0EEh,0C6h,00h,00h,03h,00h,0A5h,1Ch,7Eh,0FFh,0FEh,79h
	defb 00h,3Eh,7Fh,0FFh,0FEh,7Eh,0BEh,0CFh,02h,1Ch,3Eh,7Eh,0FFh,0FEh,0FEh,7Ch
	defb 0FEh,0FEh,0FCh,78h,03h,7Bh,0F9h,70h,0BDh,7Eh,0FEh,0FEh,7Ch,39h,9Bh,00h
	defb 00h,0A8h,0ECh,0F0h,0F7h,0EFh,0EFh,0DFh,0DFh,8Fh,0F0h,78h,0BCh,0C5h,0E9h,0EEh
	defb 0C6h,00h,01h,07h,0CFh,0EFh,0F7h,0F7h,0F0h,60h,0D8h,0DCh,0EDh,0D0h,0BEh,3Fh
	defb 1Fh,0Fh,00h,0F8h,0FCh,0FCh,0F8h,40h,80h,00h,00h,02h,00h,0CEh,01h,02h
	defb 05h,0Bh,17h,0Eh,07h,30h,63h,0A7h,0CFh,0FEh,7Fh,0C1h,38h,0C1h,0EFh,0B9h
	defb 1Eh,3Fh,6Fh,0DBh,00h,00h,0A0h,50h,0E8h,0F4h,0BAh,0DCh,37h,7Bh,79h,70h
	defb 6Eh,5Eh,3Eh,70h,99h,87h,0C0h,8Fh,04h,35h,76h,75h,0B0h,0E0h,0C0h,36h
	defb 0D2h,22h,0D2h,0EAh,0F8h,0F0h,0E7h,47h,10h,0BDh,9Dh,0A0h,2Fh,6Eh,6Dh,6Bh
	defb 67h,60h,1Eh,03h,00h,01h,03h,0Fh,04h,35h,76h,75h,00h,03h,00h,85h
	defb 03h,0Fh,1Fh,07h,23h,03h,00h,85h,80h,0C0h,0E0h,0E0h,0F0h,04h,00h,84h
	defb 03h,1Fh,3Fh,0Fh,04h,0F8h,8Eh,0F0h,0E0h,0C0h,80h,71h,0F0h,0E0h,0FBh,1Fh
	defb 00h,00h,0FEh,3Fh,7Fh,04h,00h,9Dh,0FEh,0FCh,0FCh,0F8h,0F1h,0E3h,0C6h,8Ch
	defb 18h,70h,0F9h,0F3h,0E3h,0C7h,0C6h,86h,02h,01h,0FCh,0F8h,0E0h,00h,00h,0EFh
	defb 0F7h,0DAh,00h,0BFh,3Fh,03h,00h,82h,0FEh,0FCh,00h,05h,00h,83h,01h,02h
	defb 0Fh,04h,00h,84h,38h,0FCh,7Ch,78h,05h,00h,83h,80h,0C0h,0DCh,00h,05h
	defb 00h,83h,02h,19h,78h,04h,00h,84h,01h,0Fh,1Eh,70h,05h,00h,02h,80h
	defb 81h,0C0h,05h,00h,81h,0C0h,03h,0E0h,02h,0C0h,85h,80h,60h,0F8h,0FEh,0FEh
	defb 07h,00h,81h,02h,05h,00h,83h,0F0h,00h,00h,00h,02h,00h,0DEh,07h,18h
	defb 27h,5Fh,0Fh,33h,00h,00h,0E0h,18h,0E4h,0FAh,0FBh,0CCh,00h,07h,0Fh,1Dh
	defb 3Bh,77h,7Ch,30h,33h,07h,0B7h,0D7h,97h,07h,77h,2Bh,0CCh,0E0h,0EDh,0EBh
	defb 0E9h,0E0h,0EEh,0D4h,00h,0E0h,0F0h,0B8h,0DCh,0EEh,3Eh,0Ch,07h,23h,1Dh,0Bh
	defb 13h,21h,03h,01h,0E0h,0C4h,0B8h,0D0h,0C8h,84h,0C0h,80h,00h,00h,01h,02h
	defb 05h,0Bh,13h,01h,77h,7Ch,7Ah,0FBh,0F2h,0F5h,0EFh,0CBh,0EEh,3Eh,5Eh,0DFh
	defb 4Fh,0AFh,0F7h,0D3h,00h,00h,80h,40h,0A0h,0D0h,0C8h,80h,00h,88h,3Ch,7Eh
	defb 0FFh,0FDh,0FDh,0FBh,66h,3Ch,04h,00h,88h,3Ch,7Eh,0FFh,0FDh,0FDh,0FBh,66h
	defb 3Ch,04h,00h,82h,03h,07h,04h,0Fh,94h,06h,03h,0C0h,0E0h,0F0h,0D0h,0D0h
	defb 0B0h,60h,0C0h,00h,00h,3Ch,7Eh,0FFh,0FDh,0FDh,0FBh,66h,3Ch,0Ch,00h,88h
	defb 3Ch,7Eh,0FFh,0FDh,0FDh,0FBh,66h,3Ch,03h,00h,81h,01h,04h,03h,8Ch,01h
	defb 00h,0F0h,0F8h,0FCh,0F4h,0F4h,0ECh,98h,0F0h,0Fh,1Fh,03h,3Fh,8Bh,3Eh,19h
	defb 0Fh,00h,80h,0C0h,40h,40h,0C0h,80h,00h,00h,82h,38h,0FEh,04h,0FFh,9Ch
	defb 0FEh,7Ch,0BCh,1Ch,3Eh,3Eh,1Ch,01h,03h,07h,7Bh,01h,63h,0F3h,0F3h,0F1h
	defb 60h,0F7h,0F7h,0FBh,0F8h,0FBh,0FBh,0F0h,06h,0Fh,81h,9Ch,03h,3Eh,0C8h,9Ch
	defb 80h,07h,0CEh,0Eh,04h,19h,3Dh,3Ch,18h,9Fh,67h,62h,0E7h,6Fh,6Fh,06h
	defb 70h,73h,0FDh,70h,0F9h,0F9h,70h,0BEh,18h,3Ch,06h,0Fh,6Eh,77h,31h,73h
	defb 71h,7Fh,0C0h,0ECh,0DEh,1Ch,9Ch,0C0h,0DEh,9Eh,0E3h,38h,3Ch,1Ch,7Dh,3Fh
	defb 0Fh,07h,0Eh,0EEh,0E6h,6Eh,0Ch,0BEh,0E8h,0C0h,00h,00h,3Eh,84h,0Eh,24h
	defb 72h,67h,07h,33h,99h,3Dh,1Fh,03h,00h,00h,85h,03h,0C7h,0EFh,6Fh,07h
	defb 05h,00h,0ABh,07h,0Fh,6Fh,71h,70h,00h,03h,0Fh,0Dh,0Dh,1Dh,1Fh,0Ch
	defb 1Eh,0E0h,0F0h,0F0h,0E0h,0F8h,0BCh,0DCh,0FCh,1Eh,1Ch,0Fh,1Fh,0Dh,1Fh,0Eh
	defb 06h,0FCh,0D8h,0B0h,0D8h,0BCh,7Ch,0B8h,0C0h,8Fh,0C6h,0CCh,9Eh,9Ch,05h,00h
	defb 8Ah,0C0h,0ECh,0EEh,00h,0EEh,0DFh,27h,0EFh,07h,03h,08h,00h,88h,01h,3Bh
	defb 18h,39h,9Ch,0FEh,0DCh,80h,08h,00h,89h,0C0h,0EEh,0CCh,0E4h,01h,03h,03h
	defb 01h,07h,03h,0Fh,02h,80h,06h,0E0h,82h,06h,05h,03h,0Fh,86h,05h,01h
	defb 01h,0E0h,0B0h,0F0h,03h,0E0h,81h,40h,04h,00h,89h,0C0h,0A0h,60h,0F0h,0D0h
	defb 0A0h,0A0h,60h,40h,08h,00h,87h,3Ch,7Eh,0DBh,9Ah,0C0h,76h,1Ch,05h,00h
	defb 00h,02h,00h,8Eh,0Eh,0E0h,1Fh,0E0h,0Eh,00h,0E0h,0FCh,00h,00h,0F1h,0E0h
	defb 1Fh,0E0h,03h,00h,87h,0C0h,0E0h,0F0h,0FCh,00h,07h,01h,04h,00h,8Eh,01h
	defb 83h,0FEh,00h,1Ch,0C1h,3Eh,0C1h,1Ch,0FEh,0Eh,1Fh,07h,01h,04h,00h,8Fh
	defb 1Ch,0C1h,3Eh,0C1h,1Ch,7Fh,1Fh,07h,00h,1Ch,0C1h,3Eh,0C1h,1Ch,00h,03h
	defb 0FEh,96h,0FCh,0F8h,0F0h,0C0h,80h,00h,0FEh,00h,0Eh,0E0h,1Fh,0E0h,0Eh,00h
	defb 00h,80h,0E0h,0F0h,0F8h,0F8h,0FCh,0FEh,00h,90h,80h,40h,28h,14h,28h,14h
	defb 02h,01h,01h,02h,14h,28h,14h,28h,40h,80h,00h,0A0h,80h,0C0h,0D8h,70h
	defb 0F8h,0E9h,8Dh,85h,00h,00h,20h,0E0h,30h,78h,2Ch,64h,0Fh,30h,0C3h,0Eh
	defb 19h,27h,2Ch,0C0h,86h,0B3h,9Dh,0B7h,01h,00h,00h,00h,00h,0A0h,00h,00h
	defb 04h,07h,0Ch,1Eh,34h,26h,00h,07h,9Dh,0F3h,0C3h,66h,36h,16h,00h,0E0h
	defb 0B9h,0CFh,0C3h,66h,6Ch,68h,00h,00h,20h,0E0h,30h,78h,2Ch,64h,00h,05h
	defb 00h,8Bh,1Fh,0E0h,00h,00h,78h,06h,01h,00h,0E1h,18h,04h,04h,00h,9Ch
	defb 84h,44h,0E2h,56h,02h,42h,31h,08h,04h,02h,01h,00h,23h,11h,08h,8Ch
	defb 46h,33h,0CCh,33h,88h,64h,96h,5Bh,69h,0A3h,3Ch,0C9h,05h,00h,83h,0C0h
	defb 0F0h,18h,00h,96h,00h,01h,03h,0Fh,1Dh,27h,0Eh,0Bh,37h,0Fh,3Dh,0F2h
	defb 0D2h,62h,6Fh,26h,0C5h,0ACh,78h,60h,60h,0C0h,03h,00h,02h,01h,90h,03h
	defb 06h,06h,0Dh,1Bh,08h,7Eh,3Fh,3Dh,0BBh,76h,0E6h,0E4h,60h,0C0h,80h,05h
	defb 00h,00h,07h,00h,89h,03h,00h,01h,03h,07h,0Fh,3Fh,0FEh,0F8h,03h,00h
	defb 8Dh,3Eh,0E3h,81h,0C3h,00h,0E0h,0F8h,0AEh,0C3h,0F1h,0F9h,0C0h,0F0h,04h,00h
	defb 84h,80h,0E0h,0F8h,0DCh,06h,00h,82h,01h,0Fh,03h,00h,8Eh,01h,03h,07h
	defb 0EFh,3Fh,0Fh,3Fh,0Fh,7Fh,0E1h,0C0h,0C0h,81h,0F0h,03h,0E0h,81h,0F0h,03h
	defb 0FFh,0DCh,00h,01h,03h,0Fh,3Fh,00h,0FCh,0F8h,0FEh,00h,0F3h,0C1h,81h,01h
	defb 03h,03h,8Eh,0C7h,0C3h,0E3h,0E1h,0F3h,0C0h,0E0h,00h,00h,80h,0C0h,0E0h,0F0h
	defb 0F8h,9Ch,80h,0E0h,7Ch,1Fh,83h,0C0h,7Eh,03h,00h,00h,1Ah,6Ch,0B6h,0DBh
	defb 0EDh,66h,38h,61h,0C7h,0CFh,6Fh,16h,0ACh,0DCh,7Fh,0F3h,0C1h,80h,00h,01h
	defb 07h,0Fh,83h,87h,0C7h,0CEh,0FDh,0FCh,0FAh,0F8h,0F8h,0FCh,3Fh,5Fh,9Fh,2Fh
	defb 47h,13h,07h,0Fh,3Fh,0FCh,0E0h,0C0h,0C0h,0E0h,0F8h,0FEh,8Fh,07h,03h,03h
	defb 0C3h,07h,0Ch,06h,06h,87h,0C3h,0E3h,0E3h,0F3h,03h,7Eh,0C0h,83h,1Fh,7Ch
	defb 0E0h,80h,66h,0EDh,0DBh,0B6h,6Dh,1Ah,01h,01h,0DEh,0BFh,7Fh,0E3h,8Ch,26h
	defb 33h,99h,3Fh,0F8h,0F0h,0F0h,0F8h,7Ch,3Fh,1Fh,0F8h,0FAh,7Ch,3Dh,1Eh,0Fh
	defb 8Fh,00h,23h,59h,25h,59h,0A5h,93h,4Fh,4Fh,0E0h,0F0h,00h,00h,0E7h,81h
	defb 0F3h,0C1h,0Fh,3Eh,04h,0FCh,8Ch,78h,38h,0F7h,7Fh,3Eh,1Eh,1Eh,1Ch,1Ch
	defb 3Ch,0EEh,33h,06h,00h,99h,0Eh,8Eh,0F7h,7Fh,1Fh,03h,00h,00h,3Fh,0Fh
	defb 1Fh,80h,0C0h,0F0h,7Fh,1Fh,0F8h,00h,00h,3Fh,1Fh,3Fh,0FEh,0F8h,3Fh,04h
	defb 00h,83h,83h,8Fh,01h,03h,80h,97h,0E0h,0F0h,0FCh,7Fh,3Fh,38h,18h,18h
	defb 1Dh,1Fh,3Fh,0FCh,0E0h,38h,70h,0E0h,0E0h,0C0h,0C0h,80h,00h,07h,01h,06h
	defb 00h,02h,0F0h,85h,78h,3Eh,1Fh,07h,01h,03h,00h,92h,01h,03h,0Fh,7Ch
	defb 00h,00h,1Fh,1Fh,3Fh,0F8h,0C0h,0FCh,0F8h,0F0h,0FCh,0F8h,0E0h,0C0h,04h,00h
	defb 00h,90h,00h,0C0h,15h,42h,3Ch,7Eh,1Ch,3Eh,3Eh,1Ch,7Eh,3Ch,00h,4Ah
	defb 92h,0E2h,00h,90h,63h,1Eh,73h,0C3h,0D0h,60h,60h,68h,00h,00h,0Fh,78h
	defb 0CCh,0Eh,13h,11h,00h,0C4h,21h,0C4h,9Dh,0B1h,0C3h,9Eh,0E0h,80h,00h,00h
	defb 0Fh,78h,0CCh,0Eh,13h,11h,68h,6Ch,66h,0C3h,0CFh,0B9h,0E0h,00h,83h,0DDh
	defb 0E1h,38h,8Eh,0C3h,46h,66h,9Bh,0F1h,37h,3Dh,0F0h,61h,61h,43h,68h,60h
	defb 60h,0D0h,0C3h,73h,1Eh,63h,88h,0C8h,70h,33h,1Eh,0F0h,00h,00h,01h,07h
	defb 79h,0C3h,8Dh,0B9h,23h,84h,0Bh,0Eh,27h,1Dh,04h,00h,0AEh,80h,0E0h,9Eh
	defb 0C3h,0B1h,9Dh,0C4h,21h,84h,23h,0B9h,8Dh,0C3h,79h,07h,01h,00h,00h,0F0h
	defb 1Eh,33h,70h,0C8h,88h,11h,13h,0Eh,0CCh,78h,0Fh,00h,00h,0Ah,0Ch,1Ch
	defb 74h,0C4h,06h,83h,83h,61h,32h,9Ah,9Ch,0D7h,61h,03h,00h,0A7h,0E0h,3Ch
	defb 82h,0EDh,0B9h,0CDh,61h,0C1h,0BBh,87h,1Ch,71h,0C3h,62h,66h,0D9h,8Fh,0ECh
	defb 0BCh,0Fh,86h,86h,0C2h,86h,4Ch,59h,39h,0EBh,86h,00h,00h,43h,61h,61h
	defb 0F0h,3Dh,37h,0F1h,9Bh,00h,0C8h,63h,1Eh,73h,0C3h,0D0h,60h,60h,68h,68h
	defb 60h,60h,0D0h,0C3h,73h,1Eh,63h,0CCh,66h,32h,9Bh,0D9h,6Dh,0B7h,17h,0Fh
	defb 13h,1Eh,2Ch,2Dh,4Eh,46h,43h,9Bh,0F1h,37h,3Dh,0F0h,61h,61h,43h,43h
	defb 46h,4Eh,2Dh,2Ch,1Eh,13h,01h,00h,80h,0D8h,70h,0F8h,0E9h,8Dh,85h,63h
	defb 1Eh,73h,0C3h,0D0h,60h,60h,68h,00h,00h,13h,7Fh,70h,0D1h,93h,7Ah,00h
	defb 97h,64h,2Ch,78h,30h,0E0h,20h,00h,00h,01h,13h,1Eh,2Ch,2Dh,4Eh,46h
	defb 43h,85h,8Dh,0E9h,0F8h,70h,0D8h,80h,05h,00h,9Bh,1Dh,27h,0Eh,0Bh,26h
	defb 34h,1Eh,0Ch,07h,04h,00h,00h,80h,0C8h,78h,34h,0B4h,72h,62h,0C2h,0A1h
	defb 0B1h,97h,1Fh,0Eh,1Bh,01h,05h,00h,84h,0B8h,0E4h,70h,0D0h,00h,04h,00h
	defb 8Ch,0C0h,0E0h,38h,0Ch,06h,02h,81h,0E0h,78h,3Fh,19h,08h,03h,00h,02h
	defb 80h,86h,60h,0DEh,0E3h,0Ch,06h,03h,03h,07h,0ACh,1Fh,7Fh,00h,00h,01h
	defb 03h,06h,1Ch,1Ch,38h,24h,78h,0F0h,20h,60h,40h,80h,80h,00h,00h,07h
	defb 3Ch,0E0h,0F8h,0C1h,1Fh,68h,50h,91h,13h,12h,0E6h,8Ch,08h,38h,0E0h,0F0h
	defb 0F0h,0FCh,0FEh,0E0h,0EAh,04h,07h,03h,03h,02h,02h,0A1h,04h,0C0h,0C0h,20h
	defb 10h,90h,0D0h,0F0h,0C8h,04h,08h,08h,04h,07h,3Fh,7Fh,0Ch,44h,42h,62h
	defb 21h,18h,3Ch,0FCh,0E3h,46h,83h,0F8h,0E0h,70h,1Eh,03h,00h,08h,0FFh,0ACh
	defb 20h,0A0h,90h,0DCh,46h,32h,0BFh,61h,01h,01h,02h,03h,03h,02h,03h,01h
	defb 1Ch,0Eh,30h,0C0h,0Fh,03h,03h,06h,10h,30h,0FEh,0F8h,0E0h,80h,0C0h,60h
	defb 03h,02h,02h,07h,0Fh,0Ch,1Ah,64h,08h,30h,0E0h,80h,04h,00h,98h,1Fh
	defb 03h,01h,03h,02h,03h,01h,01h,3Eh,1Eh,11h,13h,32h,22h,44h,5Ch,0FFh
	defb 0FFh,7Eh,06h,19h,0C0h,0FFh,7Fh,08h,00h,0FFh,91h,07h,1Fh,3Eh,39h,0C3h
	defb 0E7h,76h,27h,6Ch,01h,0BDh,0CEh,0F7h,95h,1Ch,9Fh,3Fh,0FFh,0FEh,7Ch,0BAh
	defb 0C4h,0F9h,0F6h,0CFh,27h,7Bh,0DCh,0EFh,0CEh,0FFh,0C6h,0E7h,0EFh,0DFh,0DEh,80h
	defb 39h,7Dh,00h,3Ah,7Dh,0ECh,85h,3Bh,7Dh,3Eh,00h,49h,0DBh,3Bh,0BBh,0DBh
	defb 0CDh,2Dh,9Eh,0CFh,0CFh,0EFh,6Fh,0C7h,83h,0B8h,7Bh,3Bh,3Dh,7Dh,79h,0F3h
	defb 7Fh,3Fh,0FFh,0FDh,0C3h,0EFh,0EFh,0FFh,0DFh,3Fh,0FBh,7Dh,0FCh,0C6h,9Dh,0ADh
	defb 0B2h,0BBh,0FBh,0FDh,0DCh,39h,3Bh,0F7h,79h,7Eh,0FFh,0DCh,0F0h,0E2h,0CFh,9Ch
	defb 3Ch,70h,5Fh,0C7h,0B9h,7Eh,0FFh,0F3h,0FCh,0FEh,0EDh,0F5h,0F5h,78h,33h,0CFh
	defb 0DFh,3Eh,0CCh,0E3h,0CFh,9Fh,0DFh,0EFh,0FBh,82h,30h,00h,03h,0FFh,0AEh,0F0h
	defb 0C7h,1Fh,78h,7Fh,7Eh,0BCh,0B2h,66h,0Dh,0F9h,0E3h,25h,3Eh,9Fh,0DFh,0D9h
	defb 0DEh,0BFh,0BFh,0Fh,91h,0DEh,0DFh,67h,0FFh,0E3h,0FDh,7Eh,3Fh,9Fh,0EFh,0E7h
	defb 0F6h,0F9h,0FBh,0DFh,0DFh,6Fh,56h,96h,94h,9Ch,1Ch,0F9h,0F7h,03h,0EFh,8Ah
	defb 77h,37h,02h,7Ch,39h,45h,7Ch,3Ah,7Fh,1Fh,04h,07h,03h,03h,02h,07h
	defb 02h,0E0h,03h,0F0h,86h,0E0h,0C0h,0E0h,03h,03h,01h,05h,00h,05h,0E0h,82h
	defb 0C0h,80h,03h,00h,83h,01h,03h,03h,03h,07h,83h,80h,0C0h,0C0h,04h,0E0h
	defb 81h,0C0h,00h,88h,00h,7Fh,7Fh,60h,6Fh,68h,6Bh,6Bh,04h,00h,81h,08h
	defb 07h,00h,8Ah,81h,00h,7Fh,00h,00h,0FEh,0FEh,06h,0F6h,16h,03h,0D6h,02h
	defb 0D7h,8Dh,0D0h,0DFh,0C0h,7Fh,0FFh,6Bh,0EBh,0EBh,0Bh,0FBh,03h,0FEh,0FFh,00h
	defb 83h,00h,0E7h,24h,03h,0A5h,8Ch,24h,0E7h,00h,0EBh,0E3h,0EBh,0EBh,0E3h,0EBh
	defb 00h,00h,0FFh,04h,00h,81h,0FFh,03h,00h,86h,0FFh,00h,00h,0FFh,00h,00h
	defb 08h,5Ah,03h,34h,86h,3Ch,34h,3Ch,34h,34h,0C6h,06h,0D6h,82h,0C6h,63h
	defb 06h,6Bh,98h,63h,5Ah,42h,7Eh,42h,7Eh,42h,5Ah,5Ah,3Ch,7Eh,3Ch,42h	; ".k.cZB~B~BZZ<~<B"
	defb 42h,3Ch,7Eh,3Ch,00h,0C3h,0C3h,00h,00h,0C3h,0C3h,05h,00h,90h,0FFh,0C3h
	defb 0C3h,00h,00h,0C3h,0C3h,00h,00h,0C3h,0C3h,00h,00h,0C3h,0C3h,0FFh,06h,00h
	defb 81h,81h,04h,00h,83h,81h,00h,22h,05h,00h,81h,22h,00h,04h,00h,02h
	defb 01h,92h,02h,07h,0C6h,0C2h,46h,0CCh,90h,0A0h,0E0h,0C0h,03h,02h,02h,07h
	defb 0Fh,0Ch,1Ah,64h,00h,82h,20h,0E0h,03h,0C0h,03h,00h,02h,03h,8Fh,04h
	defb 08h,09h,0Bh,0Fh,13h,0B0h,0B8h,0A8h,0E8h,0C8h,0D8h,0D0h,0B0h,03h,03h,01h
	defb 02h,00h,02h,01h,03h,0A0h,81h,0E0h,03h,0C0h,81h,0A0h,00h,0A2h,12h,32h
	defb 34h,34h,3Ch,7Eh,18h,3Ch,00h,00h,01h,01h,02h,03h,05h,0Bh,0A8h,0B8h
	defb 20h,60h,0C0h,80h,00h,00h,07h,0Dh,1Bh,32h,6Ah,5Eh,0D4h,0A4h,80h,80h
	defb 06h,00h,00h,05h,00h,83h,03h,07h,0Fh,05h,00h,83h,0C0h,0E0h,0F0h,00h
	defb 8Ah,1Bh,36h,3Ch,3Ch,38h,30h,10h,38h,00h,0Eh,04h,07h,9Ah,2Ah,52h
	defb 0Bh,0Bh,3Fh,03h,07h,7Fh,1Fh,03h,60h,0Eh,1Fh,1Bh,0Eh,00h,0D7h,0D7h
	defb 09h,1Ch,01h,03h,01h,00h,2Ah,2Ah,00h,86h,03h,1Fh,3Fh,3Fh,1Fh,1Fh
	defb 04h,15h,02h,1Fh,0A2h,0E0h,3Fh,1Fh,0F8h,40h,70h,78h,7Ch,01h,7Bh,03h
	defb 84h,84h,03h,7Bh,01h,7Ch,78h,70h,40h,00h,00h,70h,78h,7Ch,03h,7Bh
	defb 87h,84h,03h,7Bh,7Ch,78h,70h,05h,00h,8Bh,78h,7Ch,7Dh,7Fh,84h,84h
	defb 03h,79h,04h,7Ch,78h,07h,00h,86h,79h,7Dh,82h,82h,7Dh,79h,05h,00h
	defb 00h,9Ch,00h,38h,7Ch,0EEh,0C6h,0EEh,7Ch,38h,00h,03h,07h,0Eh,0Ch,0Eh
	defb 07h,03h,00h,80h,0C0h,0E0h,60h,0E0h,0C0h,80h,0C6h,0EEh,7Ch,38h,09h,00h
	defb 8Bh,38h,7Ch,0EEh,00h,0Eh,1Fh,3Bh,31h,3Bh,1Fh,0Eh,03h,00h,03h,80h
	defb 04h,00h,81h,01h,03h,03h,8Ch,01h,00h,00h,0E0h,0F0h,0B8h,18h,0B8h,0F0h
	defb 0E0h,7Ch,38h,09h,00h,8Bh,38h,7Ch,0EEh,0C6h,0EEh,7Ch,0EEh,0C6h,0EEh,7Ch
	defb 38h,09h,00h,81h,38h,05h,00h,86h,07h,1Dh,37h,00h,0Eh,0Eh,03h,6Eh
	defb 8Ah,0Eh,6Eh,67h,4Ch,0F0h,38h,38h,0F0h,4Ch,67h,08h,6Eh,83h,37h,1Dh
	defb 07h,05h,00h,82h,6Eh,0Eh,03h,6Eh,02h,0Eh,81h,00h,00h,0A0h,0F0h,0E0h
	defb 0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,88h,0E0h
	defb 0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,00h,0A0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h
	defb 0F0h,0E0h,0E0h,50h,54h,44h,0F4h,0F0h,0E0h,88h,0E0h,0E0h,0E0h,0E0h,0F0h,0F0h
	defb 0F0h,0F0h,00h,0A0h,0F0h,0F0h,0FFh,0FEh,0FEh,0FEh,0EEh,0E0h,0F0h,0F0h,0F0h,0FEh
	defb 0FEh,0F0h,0FFh,0FEh,0E0h,0F0h,0F0h,0F0h,0F0h,0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0E0h,0F0h,0E0h,0A0h,0F0h,0F0h,0E0h,0E0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0E0h
	defb 0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,90h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0F0h
	defb 0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,00h,0A0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0FEh,0FFh,0F0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0F0h,0F0h,0F0h
	defb 0E0h,0E0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0A0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0FEh,0FFh,0F0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0F0h,0F0h
	defb 0F0h,0E0h,0E0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0A0h,0F0h,0F0h,0F0h,0E0h,0E0h,0F0h
	defb 0F0h,0FEh,0F0h,0F0h,0F0h,0E0h,0E0h,0F0h,0F0h,0FEh,0E0h,0E0h,0F0h,0F0h,0E0h,0E0h
	defb 0F0h,0F0h,0E0h,0E0h,0F0h,0F0h,0E0h,0E0h,0F0h,0F0h,00h,0A0h,0E0h,0F0h,0F0h,0F0h
	defb 0E0h,0E0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h
	defb 0F0h,0E0h,0E0h,0F0h,0E0h,0F0h,0F0h,0E0h,0F0h,0F0h,0E0h,0E0h,88h,0F0h,0F0h,0F0h
	defb 0E0h,0E0h,0F0h,0F0h,0F0h,00h,0A0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,00h,98h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,00h,0A0h,0F0h,0F0h,0F0h,0E0h,0E0h,0F0h,0F0h,0E0h,0F0h,0F0h,0E0h,0E0h,0E0h
	defb 0E0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h
	defb 0E0h,0E0h,0E0h,88h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,00h,90h,0E0h,0E0h
	defb 0E0h,0E0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0F0h,00h,88h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,00h,0A0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0E0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h
	defb 0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0A0h,0E0h,0E0h,0E0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0E0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0A0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0E0h,98h,0F0h,0E0h,0F0h
	defb 0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0FEh,0FEh,0F0h,0E0h,0E0h,0E0h,0E0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,00h,98h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h
	defb 0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,00h
	defb 88h,60h,60h,60h,60h,60h,60h,60h,60h,00h,90h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,00h,90h,70h,70h,70h
	defb 70h,0F7h,70h,70h,70h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,00h,88h,0F0h
	defb 0F0h,40h,40h,40h,40h,40h,0F0h,00h,05h,86h,83h,60h,70h,70h,00h,02h
	defb 86h,16h,60h,08h,86h,00h,0Eh,86h,02h,60h,00h

; ----------------------------------------------------------------------
; DATA graphics_patterns_10A8: Compressed block that 0x541A dumps into VRAM
;   0x10A8: scoreboard patterns.
graphics_patterns_10A8:
	defb 02h,0F0h,05h,40h,83h,0FFh,00h,0FFh,05h,40h,83h,0FFh,00h,0FFh,05h,40h
	defb 83h,0FFh,00h,0F0h,05h,40h,83h,0F0h,00h,0FFh,05h,40h,83h,0FFh,00h,0FFh
	defb 05h,40h,83h,0FFh,00h,0FFh,05h,40h,83h,0FFh,00h,0F0h,05h,40h,83h,0F0h
	defb 00h,0FFh,05h,40h,83h,0FFh,00h,0FFh,05h,40h,83h,0FFh,00h,0FFh,05h,40h
	defb 83h,0FFh,00h,0F0h,05h,40h,83h,0F0h,00h,0FFh,05h,40h,83h,0FFh,00h,0FFh
	defb 05h,40h,83h,0FFh,00h,0FFh,05h,40h,83h,0FFh,00h,0F0h,05h,40h,83h,0F0h
	defb 00h,0FFh,05h,40h,83h,0FFh,00h,0FFh,05h,40h,83h,0FFh,00h,0FFh,05h,40h
	defb 83h,0FFh,00h,0F0h,05h,40h,83h,0F0h,00h,0FFh,03h,40h,85h,44h,40h,0FFh
	defb 00h,0FFh,03h,40h,85h,44h,40h,0FFh,00h,0FFh,05h,44h,81h,0FFh,00h

; ----------------------------------------------------------------------
; DATA graphics_patterns_1160: Compressed block that 0x5423 dumps into VRAM
;   0x1160.
graphics_patterns_1160:
	defb 82h,00h,0FFh,05h,0A0h,83h,0FFh,00h,0FFh,05h,0A0h,83h,0FFh,00h,0FFh,05h
	defb 0A0h,83h,0FFh,00h,0F0h,05h,0A0h,83h,0F0h,00h,0FFh,05h,0A0h,83h,0FFh,00h
	defb 0FFh,05h,0A0h,83h,0FFh,00h,0FFh,05h,0A0h,83h,0FFh,00h,0F0h,05h,0A0h,83h
	defb 0F0h,00h,0FFh,05h,0A0h,83h,0FFh,00h,0FFh,05h,0A0h,83h,0FFh,00h,0FFh,05h
	defb 0A0h,83h,0FFh,00h,0F0h,05h,0A0h,83h,0F0h,00h,0FFh,05h,0A0h,83h,0FFh,00h
	defb 0FFh,05h,0A0h,83h,0FFh,00h,0FFh,05h,0A0h,83h,0FFh,00h,0F0h,05h,0A0h,83h
	defb 0F0h,00h,0FFh,05h,0A0h,83h,0FFh,00h,0FFh,05h,0A0h,83h,0FFh,00h,0FFh,05h
	defb 0A0h,83h,0FFh,00h,0F0h,05h,0A0h,83h,0F0h,00h,0FFh,03h,0A0h,85h,0AAh,0A0h
	defb 0FFh,00h,0FFh,03h,0A0h,85h,0AAh,0A0h,0FFh,00h,0FFh,05h,0AAh,81h,0FFh,00h

; ----------------------------------------------------------------------
; DATA graphics_chain_7793: Chain of 49 compressed blocks up to the end of the
;   bank. The first one (0x7793) is requested by 0x5411 for VRAM 0x1058.
graphics_chain_7793:
	defb 08h,40h,00h,90h,40h,40h,40h,40h,40h,70h,0F0h,40h,40h,40h,40h,40h
	defb 40h,70h,0F0h,40h,00h,0A0h,40h,40h,40h,40h,70h,0F0h,70h,40h,80h,80h
	defb 80h,84h,87h,0F8h,87h,84h,40h,40h,40h,40h,70h,0F0h,70h,40h,80h,80h
	defb 80h,84h,87h,0F8h,98h,98h,90h,40h,40h,40h,40h,40h,40h,70h,0F0h,80h
	defb 80h,80h,80h,80h,84h,87h,0F8h,00h,02h,80h,04h,86h,02h,96h,08h,86h
	defb 06h,80h,02h,98h,08h,96h,08h,86h,81h,60h,07h,86h,08h,98h,81h,96h
	defb 05h,86h,81h,96h,09h,86h,06h,60h,02h,86h,00h,04h,80h,02h,98h,81h
	defb 88h,09h,98h,02h,96h,04h,86h,02h,98h,07h,86h,81h,66h,10h,86h,06h
	defb 80h,02h,88h,82h,98h,88h,12h,98h,0Ch,86h,02h,88h,0Eh,98h,02h,88h
	defb 82h,98h,88h,1Ch,86h,00h,08h,86h,02h,60h,06h,86h,81h,60h,06h,86h
	defb 82h,88h,60h,07h,86h,00h,04h,70h,84h,0F0h,70h,0F0h,0F0h,09h,40h,87h
	defb 0F5h,00h,0F5h,50h,50h,70h,50h,06h,40h,8Ah,0EEh,0F4h,70h,70h,00h,0F5h
	defb 0F5h,00h,0FFh,0F4h,00h,04h,90h,84h,0A0h,90h,0A0h,0A0h,09h,60h,87h,0A8h
	defb 00h,0A8h,80h,80h,90h,80h,06h,60h,82h,0EEh,0A6h,03h,90h,02h,0A8h,83h
	defb 00h,0AAh,0A6h,00h,0A0h,0F0h,0F0h,0E0h,0F0h,0E0h,40h,50h,70h,0F0h,0F0h,0E0h
	defb 0F0h,0E0h,40h,50h,70h,70h,50h,40h,0E0h,0F0h,0E0h,0F0h,00h,70h,50h,40h
	defb 0E0h,0F0h,0E0h,0F0h,0F0h,00h,0A0h,0F0h,0F0h,0E0h,0F0h,0E0h,60h,80h,90h,0F0h
	defb 0F0h,0E0h,0F0h,0E0h,60h,80h,90h,90h,80h,60h,0E0h,0F0h,0E0h,0F0h,00h,90h
	defb 80h,60h,0E0h,0F0h,0E0h,0F0h,70h,00h,06h,70h,02h,50h,00h,06h,90h,02h
	defb 80h,00h,81h,0F0h,04h,40h,96h,0F0h,70h,40h,70h,70h,40h,00h,70h,40h
	defb 40h,0F0h,70h,0F0h,70h,40h,00h,00h,70h,0F0h,70h,40h,40h,05h,70h,83h
	defb 40h,0F0h,0F0h,03h,70h,02h,40h,02h,0F4h,81h,0F7h,04h,74h,03h,0F7h,93h
	defb 0F4h,74h,74h,0F7h,0F4h,0F4h,0F0h,40h,40h,0F0h,0F0h,70h,70h,40h,70h,0F0h
	defb 0F0h,70h,70h,03h,40h,04h,0F7h,85h,74h,0F4h,0F7h,0F7h,74h,05h,0F7h,02h
	defb 0F4h,84h,0F0h,70h,40h,40h,04h,0F0h,81h,70h,03h,40h,84h,70h,40h,00h
	defb 00h,04h,0F4h,02h,74h,02h,40h,87h,74h,0F4h,0F4h,40h,40h,00h,70h,03h
	defb 40h,84h,00h,40h,70h,40h,09h,0F0h,04h,70h,04h,0F0h,03h,70h,05h,40h
	defb 03h,70h,02h,0F4h,04h,74h,82h,00h,0F0h,03h,70h,03h,40h,81h,70h,07h
	defb 40h,04h,0F7h,8Ah,74h,40h,74h,0F7h,0F0h,70h,40h,0F0h,70h,70h,0Ah,40h
	defb 02h,0F4h,03h,70h,05h,40h,02h,0F0h,81h,70h,03h,0F4h,04h,40h,84h,70h
	defb 40h,70h,0F0h,05h,0F4h,02h,74h,81h,40h,03h,0F0h,81h,70h,03h,40h,81h
	defb 0F0h,00h,04h,66h,1Ch,80h,06h,60h,02h,86h,20h,60h,00h,08h,60h,81h
	defb 86h,07h,60h,81h,96h,0Fh,60h,07h,80h,81h,66h,06h,80h,02h,86h,07h
	defb 80h,81h,86h,08h,60h,00h,21h,20h,04h,0C2h,03h,0C0h,88h,22h,20h,0C2h
	defb 20h,0C2h,0C2h,0C2h,0C0h,07h,0C2h,81h,0C0h,02h,20h,03h,0C2h,03h,0C0h,00h
	defb 07h,0F0h,81h,90h,06h,0F0h,82h,0E0h,90h,03h,0F0h,82h,90h,0F0h,04h,90h
	defb 87h,0F0h,90h,0F0h,90h,00h,0F0h,90h,04h,60h,8Ch,90h,80h,60h,60h,80h
	defb 80h,60h,60h,90h,80h,60h,60h,00h,02h,60h,05h,0F0h,81h,90h,06h,0F0h
	defb 82h,0E0h,70h,03h,0F0h,8Dh,90h,0F0h,90h,90h,70h,00h,0F0h,90h,0F0h,90h
	defb 00h,0F0h,70h,04h,40h,82h,90h,50h,02h,40h,02h,50h,02h,40h,84h,90h
	defb 50h,40h,40h,00h,03h,0F0h,03h,40h,81h,90h,04h,0F0h,03h,40h,85h,90h
	defb 0F0h,90h,90h,40h,03h,0F0h,02h,40h,02h,90h,81h,40h,03h,0F0h,02h,40h
	defb 87h,00h,0F0h,0F0h,40h,40h,90h,90h,04h,0F0h,02h,40h,02h,90h,85h,0F0h
	defb 90h,40h,0F0h,0F0h,04h,40h,84h,90h,40h,0F0h,0F0h,04h,40h,04h,0F0h,02h
	defb 90h,81h,40h,05h,0F0h,02h,90h,85h,40h,0F0h,40h,0F0h,0F0h,06h,40h,02h
	defb 0F0h,09h,40h,81h,90h,06h,0F0h,82h,40h,90h,03h,0F0h,10h,40h,84h,0F0h
	defb 90h,0F0h,0F0h,04h,40h,84h,0F0h,90h,0F0h,0F0h,14h,40h,00h,05h,0E0h,0Ah
	defb 0F0h,86h,0E0h,0F0h,0F0h,0E0h,0E0h,0F0h,05h,0E0h,0Bh,0F0h,04h,0E0h,05h,0F0h
	defb 02h,0E0h,04h,0F0h,81h,0E0h,06h,0F0h,02h,0E0h,02h,0F0h,81h,0E0h,07h,0F0h
	defb 08h,0E0h,82h,0F0h,0E0h,0Ah,0F0h,09h,0E0h,03h,0F0h,05h,0E0h,04h,0F0h,03h
	defb 0E0h,07h,0F0h,81h,0E0h,05h,0F0h,00h,08h,0A0h,08h,70h,00h,20h,0F0h,00h
	defb 20h,70h,00h,84h,60h,90h,90h,80h,04h,60h,85h,0E0h,0F0h,0F0h,0E0h,0E0h
	defb 03h,50h,81h,0E0h,03h,0F0h,82h,0E0h,50h,06h,0F0h,81h,0E0h,03h,50h,86h
	defb 0F5h,0FEh,0FEh,0E5h,0E4h,54h,06h,50h,04h,40h,85h,0F0h,50h,00h,0E0h,0F5h
	defb 03h,40h,86h,0F0h,40h,00h,0E0h,0F4h,40h,05h,0F0h,03h,0E0h,0Eh,0F0h,04h
	defb 0E0h,03h,0F0h,04h,0E0h,81h,0F0h,00h,0A0h,0C0h,30h,30h,20h,0C0h,0C0h,0C0h
	defb 0C0h,0E0h,0F0h,0F0h,0E0h,0E0h,50h,50h,50h,0E0h,0F0h,0F0h,0F0h,0E0h,50h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,50h,50h,50h,0A0h,0F5h,0FEh,0FEh,0E5h,0E4h,54h
	defb 50h,50h,50h,50h,50h,50h,40h,40h,40h,40h,0F0h,50h,00h,0E0h,0F5h,40h	; "PPPPPP@@@@.P...@"
	defb 40h,40h,0F0h,40h,00h,0E0h,0F4h,40h,0F0h,0F0h,0A0h,0F0h,0F0h,0F0h,0E0h,0E0h
	defb 0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h
	defb 0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0F0h,00h,0A0h,0A0h,0B0h,0B0h
	defb 0B0h,0A0h,0A0h,0A0h,0A0h,0E0h,0F0h,0F0h,0E0h,0E0h,50h,50h,50h,0E0h,0F0h,0F0h
	defb 0F0h,0E0h,50h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,50h,50h,50h,0A0h,0F5h,0FEh
	defb 0FEh,0E5h,0E4h,54h,50h,50h,50h,50h,50h,50h,40h,40h,40h,40h,0F0h,50h	; "...TPPPPPP@@@@.P"
	defb 00h,0E0h,0F5h,40h,40h,40h,0F0h,40h,00h,0E0h,0F4h,40h,0F0h,0F0h,0A0h,0F0h
	defb 0F0h,0F0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0F0h,00h
	defb 0A0h,40h,70h,70h,50h,40h,40h,40h,40h,0E0h,0F0h,0F0h,0E0h,0E0h,50h,50h
	defb 50h,0E0h,0F0h,0F0h,0F0h,0E0h,50h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,50h,50h
	defb 50h,0A0h,0F5h,0FEh,0FEh,0E5h,0E4h,54h,50h,50h,50h,50h,50h,50h,40h,40h
	defb 40h,40h,0F0h,50h,00h,0E0h,0F5h,40h,40h,40h,0F0h,40h,00h,0E0h,0F4h,40h
	defb 0F0h,0F0h,0A0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h,0E0h,0E0h
	defb 0E0h,0E0h,0F0h,00h,0A0h,0D0h,90h,90h,80h,0D0h,0D0h,60h,60h,0E0h,0F0h,0F0h
	defb 0E0h,0E0h,50h,50h,50h,0E0h,0F0h,0F0h,0F0h,0E0h,50h,0F0h,0F0h,0F0h,0F0h,0F0h
	defb 0F0h,0E0h,50h,50h,50h,0A0h,0F5h,0FEh,0FEh,0E5h,0E4h,54h,50h,50h,50h,50h
	defb 50h,50h,40h,40h,40h,40h,0F0h,50h,00h,0E0h,0F5h,40h,40h,40h,0F0h,40h
	defb 00h,0E0h,0F4h,40h,0F0h,0F0h,0A0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0F0h,0F0h,0F0h
	defb 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0F0h
	defb 0F0h,0F0h,0E0h,0E0h,0E0h,0E0h,0F0h,00h,12h,0F0h,06h,0E0h,10h,0F0h,00h,02h
	defb 00h,02h,60h,8Dh,90h,80h,86h,0F5h,00h,00h,60h,60h,80h,90h,60h,0F5h
	defb 00h,05h,0E0h,02h,0F0h,81h,0FEh,03h,0E0h,04h,0F0h,81h,0FEh,03h,0E0h,04h
	defb 0F0h,81h,00h,05h,0E0h,02h,0F0h,92h,60h,90h,0E0h,90h,60h,60h,0F0h,0E0h
	defb 60h,90h,0E0h,90h,60h,60h,0F0h,0E0h,00h,00h,06h,0F0h,81h,0FEh,04h,0E0h
	defb 03h,0F0h,81h,0FEh,04h,0E0h,03h,0F0h,02h,00h,06h,0F0h,00h,04h,50h,06h
	defb 40h,06h,50h,08h,40h,04h,50h,04h,40h,04h,50h,04h,40h,06h,50h,0Ah
	defb 40h,08h,50h,82h,55h,50h,06h,40h,04h,50h,04h,40h,04h,50h,04h,40h
	defb 04h,50h,04h,40h,04h,50h,04h,40h,00h,04h,80h,04h,60h,08h,80h,08h
	defb 60h,04h,80h,04h,60h,04h,80h,04h,60h,06h,80h,0Ah,60h,0Ah,80h,06h
	defb 60h,04h,80h,04h,60h,04h,80h,04h,60h,04h,80h,04h,60h,04h,80h,04h
	defb 60h,00h,81h,96h,07h,98h,81h,60h,07h,98h,81h,80h,06h,98h,81h,60h
	defb 07h,98h,05h,96h,04h,98h,03h,96h,04h,98h,86h,80h,98h,98h,80h,98h
	defb 98h,03h,96h,81h,80h,04h,98h,83h,60h,96h,96h,03h,90h,81h,60h,03h
	defb 96h,04h,60h,05h,96h,81h,60h,03h,96h,02h,60h,84h,90h,60h,96h,60h
	defb 03h,96h,06h,60h,08h,96h,05h,60h,00h,04h,96h,04h,90h,05h,60h,02h
	defb 96h,87h,66h,60h,60h,90h,90h,60h,60h,05h,90h,03h,60h,04h,90h,02h
	defb 60h,06h,90h,81h,60h,04h,90h,81h,60h,04h,96h,08h,60h,85h,90h,99h
	defb 90h,60h,96h,0Dh,60h,03h,96h,0Dh,60h,02h,96h,03h,90h,81h,60h,04h
	defb 90h,02h,60h,03h,90h,81h,60h,03h,90h,81h,60h,04h,90h,06h,60h,0Ah
	defb 90h,02h,60h,02h,90h,0Ch,60h,03h,96h,07h,60h,00h,82h,90h,40h,06h
	defb 54h,04h,50h,0Ch,54h,03h,40h,04h,50h,03h,54h,06h,40h,02h,54h,06h
	defb 40h,09h,50h,03h,40h,04h,90h,88h,40h,50h,54h,54h,40h,40h,90h,90h
	defb 05h,40h,03h,90h,02h,50h,02h,40h,06h,50h,02h,54h,02h,40h,02h,90h
	defb 04h,40h,04h,90h,00h,06h,50h,02h,40h,03h,50h,02h,54h,83h,40h,90h
	defb 90h,05h,50h,03h,54h,04h,40h,02h,50h,02h,40h,05h,50h,03h,54h,03h
	defb 40h,02h,94h,03h,90h,03h,50h,03h,40h,02h,90h,81h,40h,03h,50h,02h
	defb 40h,02h,90h,81h,50h,03h,40h,04h,90h,00h,04h,50h,03h,54h,82h,55h
	defb 50h,04h,40h,02h,50h,81h,55h,07h,50h,81h,54h,04h,50h,04h,40h,03h
	defb 50h,02h,54h,8Dh,44h,94h,90h,50h,50h,40h,44h,54h,54h,44h,44h,55h	; "P.T.D..PP@DTTDDU"
	defb 55h,03h,54h,03h,40h,04h,54h,81h,44h,03h,40h,0Dh,50h,02h,54h,84h
	defb 55h,54h,44h,40h,05h,90h,00h,28h,90h,00h,08h,40h,82h,0E0h,80h,06h
	defb 40h,81h,0E0h,03h,40h,82h,70h,0E0h,05h,70h,03h,40h,84h,70h,0E0h,40h
	defb 20h,03h,40h,9Dh,0E0h,70h,0F0h,20h,0E5h,50h,60h,0F0h,70h,0F0h,50h,70h
	defb 50h,50h,40h,0E0h,40h,50h,0E0h,70h,40h,40h,90h,60h,40h,70h,0F0h,0C0h
	defb 50h,03h,40h,04h,70h,87h,0A0h,90h,60h,0F0h,90h,0F0h,0A0h,00h,04h,40h
	defb 04h,50h,08h,40h,06h,50h,02h,54h,08h,40h,03h,50h,84h,40h,54h,55h
	defb 55h,03h,54h,04h,55h,15h,54h,02h,44h,86h,40h,90h,90h,55h,54h,54h
	defb 03h,55h,02h,54h,00h,03h,0A0h,15h,50h,00h,08h,50h,05h,40h,83h,50h
	defb 54h,54h,08h,50h,10h,40h,03h,55h,02h,44h,83h,55h,55h,54h,04h,55h
	defb 84h,44h,54h,55h,55h,00h,90h,44h,55h,0C4h,52h,74h,52h,0C4h,55h,50h
	defb 40h,55h,44h,52h,43h,75h,43h,04h,40h,85h,50h,40h,50h,44h,50h,05h	; "@UDRCuC.@.P@PDP."
	defb 40h,8Dh,50h,40h,50h,44h,0C5h,42h,75h,42h,0C5h,40h,0C5h,40h,50h,05h
	defb 40h,96h,0C5h,42h,75h,42h,0C5h,40h,50h,40h,55h,0C4h,52h,74h,52h,0C4h
	defb 55h,40h,50h,40h,50h,40h,50h,40h,03h,50h,8Fh,44h,0C5h,42h,75h,42h	; "U@P@P@P@.P.D.BuB"
	defb 0C5h,44h,40h,40h,50h,40h,50h,40h,50h,40h,00h,90h,40h,50h,50h,70h	; ".D@@P@P@P@..@PPp"
	defb 70h,50h,50h,40h,40h,50h,50h,70h,70h,50h,50h,40h,00h,88h,40h,40h	; "pPP@@PPppPP@..@@"
	defb 0E0h,0E0h,0E0h,0E4h,0E4h,0F4h,07h,70h,8Dh,0F4h,70h,0E0h,0E0h,70h,0E0h,0E0h
	defb 0F4h,0E4h,74h,0F4h,0F4h,0E4h,04h,0E0h,00h,04h,70h,84h,0E0h,0E0h,70h,0F0h
	defb 03h,70h,03h,0E4h,02h,0F4h,03h,70h,03h,0E4h,02h,0F4h,04h,70h,84h,0E0h
	defb 0E0h,70h,0F0h,00h,03h,0F0h,04h,0E0h,08h,0F0h,04h,0E0h,05h,0F0h,08h,0E0h
	defb 02h,0E4h,02h,0F4h,84h,0E0h,0F0h,0E0h,0E0h,03h,70h,81h,74h,03h,0F4h,81h
	defb 0E4h,08h,70h,00h,03h,0E0h,83h,40h,70h,0F0h,03h,0F4h,81h,0FEh,03h,0F4h
	defb 02h,0E4h,86h,74h,0F4h,0E0h,0E0h,70h,70h,04h,0E0h,04h,70h,03h,0E0h,81h
	defb 0FEh,06h,0E4h,81h,0F4h,08h,0E0h,00h,0Eh,0E0h,02h,0E5h,03h

	end

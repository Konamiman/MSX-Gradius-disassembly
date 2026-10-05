; ============================================================================
; Nemesis / Gradius - screens image (banks 9-10) - fixed_screens.asm
; ============================================================================

	public graphics_0468,graphics_2468,graphics_9B3F,graphics_9BCB,graphics_colours_2008,graphics_colours_2808
	public graphics_colours_3008,graphics_patterns_0008,graphics_patterns_0808,graphics_patterns_1008,name_table_screen

; Bank 9 (runs at 0x8000).
;
; THIS BANK HOLDS NO CODE. These are the fixed screens: the title, the ship
; map and the text screens. It is mapped together with bank 10 (0xA000) from
; p00:5315-p00:5321, p00:5B34-p00:5B3E, p00:5B7D-p00:5B87 and
; p00:5BFE-p00:5C08.
;
; Almost all of it is compressed blocks for decompress (tools/rle.py). The proof
; that they are correctly delimited is that the chains fit with no slack:
; from graphics_colours_2008 to 0x9B3F there are exactly six blocks, and from graphics_2468 to the
; end of the bank, two.

; ----------------------------------------------------------------------
; FIXED SCREENS (bank 9)
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; DATA name_table_screen: 768 raw bytes (not compressed) that 0x5C66 copies
;   with LDIRVM to VRAM 0x3800: a whole name table, 24 rows of 32 characters.
name_table_screen:
	defb 00h,01h,00h,00h,02h,00h,03h,0F7h,00h,05h,06h,00h,00h,00h,07h,08h,09h,09h,0Ah,0Ch,0Dh,0Eh,0Fh,10h,11h,12h,13h,14h,15h,16h,17h,18h
	defb 19h,00h,0F6h,1Bh,00h,00h,00h,00h,1Ch,1Dh,1Eh,1Fh,00h,00h,00h,00h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh,30h
	defb 31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,00h,3Fh,40h,0F6h,00h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh	; "123456789:;<=.?@..BCDEFGHIJKLMNO"
	defb 00h,00h,00h,00h,50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,00h,00h,5Ah,00h,00h,00h,5Bh,00h,5Ch,5Dh,5Eh,5Fh,60h,61h,62h,63h,64h,65h
	defb 66h,67h,00h,00h,0F8h,00h,00h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,00h,6Fh,70h,00h,00h,71h,0F8h,73h,74h,75h,76h,00h,77h,78h,79h,7Ah,7Bh,7Ch
	defb 00h,00h,7Dh,00h,00h,00h,00h,0F6h,7Eh,7Fh,80h,81h,0F8h,82h,83h,84h,85h,86h,87h,00h,00h,88h,89h,8Ah,8Bh,8Ch,8Dh,00h,00h,8Eh,8Fh,90h
	defb 91h,00h,00h,00h,00h,00h,00h,00h,00h,93h,94h,95h,96h,97h,98h,99h,9Ah,9Bh,9Ch,9Dh,9Eh,9Fh,0A0h,00h,00h,00h,0F7h,00h,00h,00h,00h,00h
	defb 00h,00h,0A4h,00h,0A5h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh,0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,00h,00h,0BEh,0BFh
	defb 00h,00h,01h,02h,03h,04h,05h,06h,07h,08h,09h,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh,10h,11h,12h,13h,14h,15h,16h,17h,18h,19h,1Ah,1Bh,1Ch,0F8h,1Eh
	defb 00h,00h,00h,1Fh,20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh,30h,31h,32h,33h,34h,35h,36h,37h,38h,00h,00h,00h
	defb 00h,00h,00h,00h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh,40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh,50h,00h,00h,51h,00h	; "....9:;<=>?@ABCDEFGHIJKLMNOP..Q."
	defb 0F7h,00h,00h,00h,00h,00h,00h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh,60h,61h,62h,63h,64h,00h,00h,00h,0F7h,00h,00h,00h,00h
	defb 00h,66h,00h,00h,68h,69h,00h,6Ah,6Bh,00h,0F7h,00h,00h,6Ch,6Dh,6Eh,6Fh,70h,71h,00h,00h,00h,00h,00h,73h,00h,00h,00h,00h,00h,0F6h,00h
	defb 75h,00h,76h,77h,00h,78h,79h,00h,7Ah,7Bh,00h,00h,00h,7Ch,7Dh,7Eh,7Fh,80h,81h,00h,00h,00h,83h,00h,84h,00h,00h,00h,00h,00h,00h,00h
	defb 0F6h,00h,00h,00h,0F8h,00h,87h,88h,89h,8Ah,8Bh,00h,8Ch,8Dh,8Eh,8Fh,90h,91h,92h,93h,94h,95h,96h,00h,97h,98h,99h,9Ah,00h,00h,00h,00h
	defb 9Bh,00h,9Ch,9Dh,9Eh,9Fh,0A0h,0A1h,0A2h,0A3h,0A4h,0A5h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh,0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0F8h,0B8h,00h
	defb 00h,00h,00h,01h,02h,03h,04h,05h,06h,07h,08h,09h,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh,10h,11h,12h,13h,14h,15h,16h,00h,00h,00h,18h,00h,00h,00h
	defb 00h,19h,1Ah,1Bh,1Ch,1Dh,1Eh,1Fh,00h,20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh,00h,31h,32h,33h,34h,35h,36h
	defb 00h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh,40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,0F7h,4Dh,4Eh,4Fh,50h,51h,52h,53h,54h,55h	; ".789:;<=>?@ABCDEFGHIJK.MNOPQRSTU"
	defb 56h,57h,58h,59h,5Ah,5Bh,00h,5Ch,5Dh,5Eh,5Fh,60h,61h,00h,62h,63h,64h,65h,66h,67h,68h,69h,00h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh,70h,00h,71h	; "VWXYZ[.\]^_`a.bcdefghi.jklmnop.q"
	defb 72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,00h,7Ch,7Dh,00h,0F7h,7Fh,80h,81h,82h,83h,84h,85h,86h,87h,88h,89h,8Ah,8Bh,00h,8Ch,0F6h,00h
	defb 8Eh,8Fh,90h,91h,92h,93h,94h,00h,00h,0F6h,96h,97h,00h,00h,00h,0F8h,99h,9Ah,9Bh,00h,9Ch,9Dh,9Eh,9Fh,0A0h,0A1h,0A2h,0A3h,00h,0A4h,00h,00h
	defb 0A5h,0A6h,0A7h,0F7h,0A9h,0AAh,0ABh,0ACh,00h,00h,0ADh,00h,0F8h,00h,0AFh,00h,00h,0B0h,0B1h,00h,0B2h,0B3h,0B4h,0B5h,0F8h,00h,0B7h,00h,0B8h,0B9h,0BAh,0BBh
	defb 0BCh,0BDh,00h,0BEh,0BFh,00h,0C0h,0C1h,0C2h,00h,00h,00h,0C3h,00h,0C4h,0C5h,0F6h,0C7h,0C8h,0C9h,00h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh,0D0h,0D1h,0D2h,0D3h,0D4h

; ----------------------------------------------------------------------
; DATA graphics_colours_2008: Compressed block that 0x5C15 dumps into VRAM
;   0x2008 (colours, first third).
graphics_colours_2008:
	defb 03h,00h,81h,80h,08h,00h,81h,10h,09h,00h,81h,80h,05h,00h,81h,20h
	defb 07h,00h,02h,01h,86h,03h,07h,20h,60h,60h,0E0h,03h,0F0h,81h,0F8h,18h
	defb 00h,88h,3Ch,42h,99h,0A1h,0A1h,99h,42h,3Ch,09h,00h,89h,63h,66h,6Ch
	defb 78h,7Ch,6Eh,67h,00h,3Eh,05h,63h,9Bh,3Eh,00h,63h,73h,7Bh,7Fh,6Fh
	defb 67h,63h,00h,1Ch,36h,63h,63h,7Fh,63h,63h,00h,63h,77h,7Fh,7Fh,6Bh
	defb 63h,63h,00h,3Ch,05h,18h,81h,3Ch,09h,00h,82h,18h,38h,04h,18h,99h
	defb 7Eh,00h,3Eh,63h,63h,3Fh,03h,63h,3Eh,00h,3Eh,63h,63h,3Eh,63h,63h	; "~.>cc?.c>.>cc>cc"
	defb 3Eh,00h,3Eh,63h,60h,7Eh,63h,63h,3Eh,13h,00h,81h,04h,07h,00h,81h
	defb 01h,0Ah,00h,81h,08h,04h,00h,95h,01h,03h,0Fh,3Fh,07h,1Fh,3Fh,04h
	defb 1Fh,7Eh,3Ch,00h,00h,0F8h,0FCh,0FCh,0FEh,0F0h,0F8h,0FCh,80h,05h,00h,83h
	defb 80h,0C0h,0E0h,04h,00h,04h,04h,83h,1Fh,07h,02h,05h,00h,83h,37h,0D0h
	defb 0E0h,05h,00h,0D0h,3Eh,0BFh,0DFh,0EFh,1Fh,0Fh,07h,03h,7Fh,1Fh,00h,00h
	defb 0C0h,75h,1Bh,0F0h,87h,0FCh,66h,09h,02h,7Fh,87h,00h,0C0h,76h,35h,1Bh
	defb 06h,01h,80h,0F0h,3Eh,83h,0B0h,28h,6Eh,0DBh,7Ah,1Ah,7Bh,6Bh,3Fh,00h
	defb 11h,0DFh,41h,7Fh,00h,0C0h,80h,0E0h,00h,0Fh,0E6h,0A0h,00h,0F2h,0C4h,1Fh
	defb 7Eh,7Fh,03h,0ECh,00h,3Fh,7Fh,0Fh,00h,0C0h,7Fh,3Eh,80h,00h,98h,0DCh
	defb 0BCh,0F0h,0C0h,81h,03h,00h,0A3h,0E0h,0Fh,27h,0Fh,00h,7Fh,01h,00h,0F0h
	defb 38h,00h,00h,7Dh,00h,80h,78h,1Fh,26h,0FEh,80h,01h,54h,0FEh,0FCh,0C1h
	defb 3Fh,1Fh,7Fh,0E0h,00h,00h,0FEh,0FEh,01h,01h,05h,00h,83h,0FFh,00h,0FFh
	defb 05h,00h,02h,0E0h,82h,00h,0FFh,05h,00h,84h,3Fh,0FEh,1Fh,3Fh,05h,00h
	defb 03h,0FFh,05h,00h,82h,0E0h,0F8h,04h,00h,0A9h,0Fh,03h,07h,00h,00h,03h
	defb 0Fh,07h,3Fh,01h,02h,05h,2Bh,0Fh,1Fh,3Fh,7Fh,00h,03h,07h,07h,30h
	defb 0F8h,0FCh,70h,0F8h,0FCh,0FCh,0FEh,0C0h,0E0h,0F0h,0F0h,0F8h,0F4h,0F8h,0FCh,0F0h
	defb 0F8h,0FEh,80h,03h,0C0h,8Ah,0E0h,00h,0Ch,00h,00h,80h,80h,0C0h,0F0h,0Eh
	defb 04h,04h,03h,00h,81h,80h,0Eh,00h,82h,20h,10h,07h,00h,81h,01h,06h
	defb 00h,83h,40h,0C0h,03h,06h,00h,84h,0F0h,3Ch,81h,07h,04h,00h,0D9h,98h
	defb 0Fh,00h,0AFh,7Eh,39h,0Eh,03h,44h,97h,03h,07h,7Bh,3Fh,0EFh,0F7h,33h
	defb 00h,80h,0C2h,35h,02h,0E0h,81h,7Fh,0Eh,1Ch,38h,00h,8Ch,00h,0E4h,00h
	defb 7Fh,07h,00h,80h,0F8h,0F0h,7Fh,0D0h,0F9h,00h,00h,1Fh,01h,00h,80h,57h
	defb 07h,0CAh,0D5h,0EBh,0B5h,1Fh,00h,0C0h,80h,00h,80h,0E0h,0F8h,0EAh,0D5h,85h
	defb 6Ah,80h,0C3h,3Fh,7Fh,0Fh,77h,0E0h,5Fh,0F8h,80h,00h,0Fh,7Fh,0D0h,80h
	defb 03h,3Fh,1Fh,00h,0D8h,70h,61h,0FFh,07h,00h,83h,3Fh,0FFh,1Fh,05h,00h
	defb 0BEh,05h,3Fh,03h,1Fh,1Fh,07h,01h,00h,55h,0ABh,15h,03h,3Fh,0Fh,07h
	defb 03h,07h,07h,03h,01h,00h,0BFh,5Fh,2Fh,0FEh,0FCh,0F8h,0F0h,0FEh,0FCh,0FCh
	defb 70h,0FDh,0FEh,0FDh,0FEh,0FDh,0FAh,0F4h,0A8h,0F0h,0FCh,40h,0A8h,50h,80h,0FCh
	defb 0E0h,0FCh,0FEh,00h,0E0h,0FEh,0F8h,00h,0FCh,40h,00h,80h,0F8h,0FFh,0E0h,07h
	defb 00h,03h,80h,03h,00h,81h,04h,03h,00h,83h,20h,1Fh,03h,06h,00h,83h
	defb 0E0h,3Fh,0Fh,05h,00h,0C0h,0Fh,00h,80h,7Fh,1Fh,01h,00h,00h,80h,00h
	defb 18h,06h,0C0h,0F8h,17h,01h,0E0h,18h,04h,03h,4Fh,1Eh,0B8h,0E5h,0ECh,7Fh
	defb 3Eh,0DCh,0FEh,3Fh,0F8h,00h,3Eh,7Eh,7Fh,0E0h,80h,34h,70h,7Bh,7Fh,3Fh
	defb 00h,7Bh,0Fh,40h,0F8h,83h,00h,2Ch,00h,80h,0E8h,1Eh,03h,0C0h,21h,00h
	defb 60h,0Eh,03h,46h,0E0h,1Ch,04h,00h,84h,02h,00h,00h,10h,04h,00h,81h
	defb 06h,03h,00h,84h,3Fh,1Fh,07h,03h,04h,00h,0A2h,17h,05h,7Fh,1Fh,07h
	defb 7Fh,1Fh,0Fh,00h,0FDh,0AAh,50h,0FEh,0FCh,00h,00h,50h,80h,00h,0FCh,0FCh
	defb 0F0h,0E0h,0FEh,0C0h,80h,00h,0FCh,0F0h,0C0h,00h,00h,0F8h,0C0h,0Ch,00h,92h
	defb 10h,00h,01h,07h,0Fh,03h,05h,0Fh,1Bh,3Fh,80h,0E0h,0F0h,0C0h,0A0h,0F0h
	defb 0D8h,0FCh,05h,00h,81h,10h,07h,00h,81h,04h,04h,00h,02h,02h,9Eh,07h
	defb 05h,07h,02h,20h,00h,01h,03h,07h,49h,0FCh,0E0h,80h,80h,0E0h,0F0h,0E8h
	defb 42h,7Fh,03h,00h,00h,20h,20h,0F0h,0D0h,0F0h,20h,7Fh,1Fh,03h,00h,87h
	defb 80h,00h,00h,0C0h,00h,0F8h,07h,05h,00h,0A2h,30h,40h,0FCh,80h,1Fh,00h
	defb 00h,08h,4Ch,36h,1Fh,7Fh,00h,7Fh,07h,47h,00h,2Ch,0C3h,85h,0EBh,7Ch
	defb 0C5h,83h,0Eh,0E0h,0F0h,0C0h,80h,0F8h,0Fh,00h,00h,01h,05h,00h,85h,07h
	defb 03h,03h,01h,01h,03h,00h,8Ch,0FDh,0FAh,74h,0A8h,50h,0FEh,0FCh,78h,0F8h
	defb 0F0h,0C0h,80h,06h,00h,81h,08h,04h,00h,84h,03h,00h,00h,08h,06h,00h
	defb 03h,02h,95h,03h,07h,0Fh,0Fh,03h,3Fh,0DEh,0AFh,0CDh,0Ch,03h,0Fh,0C0h
	defb 0FCh,7Bh,0F5h,0B3h,0CFh,0C0h,0F0h,00h,03h,40h,87h,0C0h,0E0h,0F0h,0F0h,00h
	defb 00h,10h,06h,00h,81h,0Fh,06h,00h,8Dh,03h,3Fh,03h,0Fh,03h,01h,01h
	defb 00h,0C0h,0F8h,0C0h,0F8h,80h,03h,00h,03h,0E0h,08h,00h,85h,08h,1Ch,17h
	defb 1Ch,08h,03h,00h,88h,42h,47h,0E0h,47h,42h,00h,00h,80h,05h,00h,82h
	defb 3Ch,03h,06h,00h,83h,0FCh,3Bh,0E7h,06h,00h,81h,08h,0Ah,00h,04h,04h
	defb 88h,70h,60h,60h,40h,00h,00h,7Eh,07h,04h,00h,84h,01h,03h,7Dh,0Dh
	defb 04h,00h,0C4h,0C1h,82h,86h,04h,08h,98h,98h,5Dh,8Ch,0F4h,0F8h,0C4h,03h
	defb 0Dh,3Bh,47h,3Fh,1Fh,0E0h,3Fh,0F0h,0E5h,0CFh,0BEh,7Bh,7Dh,06h,0FEh,03h
	defb 30h,2Bh,99h,0E0h,0Fh,02h,3Fh,0C0h,0Ch,0D4h,99h,07h,0F0h,40h,0FCh,0Fh
	defb 0A7h,0F3h,7Dh,0DEh,0BEh,60h,7Fh,0C0h,0B0h,0DCh,0E6h,0FCh,0F8h,07h,0FCh,10h
	defb 19h,19h,0BAh,31h,2Fh,1Fh,23h,04h,00h,84h,83h,41h,61h,20h,04h,00h
	defb 84h,80h,0C0h,0BEh,0B0h,06h,00h,82h,7Eh,0E0h,06h,00h,81h,02h,05h,00h
	defb 04h,04h,81h,0Eh,04h,04h,03h,00h,81h,80h,0Ah,00h,85h,01h,07h,0Fh
	defb 1Eh,1Dh,03h,00h,85h,0E0h,0F0h,0D8h,0E8h,0E8h,07h,00h,81h,0F0h,05h,00h
	defb 83h,0Fh,0F0h,03h,04h,00h,88h,0C0h,7Ch,3Fh,0F3h,01h,28h,2Eh,5Fh,03h
	defb 00h,83h,0FDh,0E0h,0F8h,03h,7Fh,0D5h,7Eh,80h,0F8h,0F0h,0F6h,80h,0F0h,80h
	defb 01h,00h,80h,7Ch,80h,07h,0F8h,21h,0C3h,0Fh,3Fh,0Ch,0F7h,0FCh,7Fh,00h
	defb 11h,0E6h,0F0h,0Fh,03h,01h,00h,0Ch,9Ch,4Fh,0Fh,00h,1Bh,0Ah,1Ah,3Ch
	defb 0FEh,0Fh,0C0h,00h,0D8h,50h,58h,3Ch,7Fh,0F0h,03h,0F0h,0C0h,80h,0F7h,0FBh
	defb 0FDh,0Fh,7Ch,30h,0EBh,3Dh,0FEh,00h,07h,00h,7Ch,3Eh,01h,0E0h,1Fh,80h
	defb 0C0h,0F0h,0FCh,0Fh,6Fh,01h,0Fh,01h,00h,00h,0FEh,07h,1Fh,03h,0FEh,87h
	defb 7Eh,01h,1Fh,80h,14h,74h,0FAh,03h,00h,81h,0BFh,04h,00h,84h,03h,3Eh
	defb 0FCh,0CFh,05h,00h,83h,0F0h,0Fh,0C0h,07h,00h,81h,0Fh,03h,00h,85h,07h
	defb 0Fh,1Bh,17h,17h,03h,00h,86h,80h,0E0h,0F0h,78h,0B8h,0Eh,04h,04h,03h
	defb 00h,81h,80h,07h,00h,81h,10h,07h,00h,00h

; ----------------------------------------------------------------------
; DATA graphics_colours_2808: Compressed block that 0x5C1E dumps into VRAM
;   0x2808 (colours, second third).
graphics_colours_2808:
	defb 06h,00h,02h,03h,02h,00h,94h,03h,1Fh,3Fh,1Fh,0Fh,0F8h,3Fh,3Fh,0D0h
	defb 33h,0Fh,00h,0C0h,3Fh,93h,12h,34h,38h,08h,61h,03h,00h,94h,07h,80h
	defb 0FCh,49h,0E0h,00h,00h,04h,0C0h,3Eh,0FEh,1Dh,3Bh,78h,00h,0EEh,0E6h,00h
	defb 0F0h,0Fh,03h,00h,0F5h,7Bh,0FCh,0FCh,30h,0C1h,03h,00h,00h,0E0h,3Fh,1Fh
	defb 01h,0C2h,84h,08h,10h,80h,7Eh,0C0h,00h,0FCh,08h,10h,20h,03h,80h,01h
	defb 06h,04h,08h,10h,21h,0Bh,37h,0Fh,0DBh,07h,45h,73h,85h,0ECh,0F0h,0FCh
	defb 0E0h,70h,0FAh,0F4h,0A0h,0C7h,3Ah,1Ah,06h,01h,80h,01h,02h,0E3h,5Ch,0BFh
	defb 7Ch,3Eh,5Fh,0BFh,1Fh,03h,00h,0FCh,0Eh,67h,33h,0B9h,7Eh,0D7h,0FEh,7Dh
	defb 3Fh,1Dh,1Fh,0Eh,0Eh,0C0h,01h,80h,60h,0A3h,90h,48h,84h,0FEh,7Eh,03h
	defb 00h,0C0h,00h,00h,0F8h,07h,0FCh,0F8h,80h,41h,21h,10h,08h,0DEh,3Fh,3Fh
	defb 0Ch,83h,80h,00h,00h,77h,67h,00h,0Fh,0F0h,03h,00h,86h,20h,03h,7Ch
	defb 80h,0F8h,0FCh,03h,00h,9Fh,0E0h,01h,3Fh,92h,07h,00h,00h,0C9h,48h,2Ch
	defb 1Ch,10h,86h,00h,00h,0FCh,0FCh,0Bh,0CCh,0F0h,00h,03h,0FCh,00h,00h,0C0h
	defb 0F8h,0FCh,0F8h,0F0h,1Fh,06h,00h,02h,0C0h,02h,00h,81h,40h,09h,00h,81h
	defb 40h,03h,00h,0CBh,7Fh,3Fh,00h,1Fh,1Fh,0Fh,07h,01h,0C0h,00h,0BFh,7Fh
	defb 0C0h,01h,0E0h,0F8h,00h,00h,0FEh,7Fh,07h,0E0h,1Fh,00h,0C0h,7Fh,00h,3Eh
	defb 3Eh,3Fh,0C0h,3Fh,00h,80h,7Fh,40h,7Fh,3Fh,3Fh,1Fh,07h,0Eh,1Ch,00h
	defb 01h,98h,97h,0CBh,1Fh,3Eh,7Ch,01h,0F9h,06h,0C3h,0FBh,20h,7Fh,3Fh,80h
	defb 0FEh,01h,0F8h,0F8h,4Eh,92h,24h,78h,01h,03h,03h,01h,23h,41h,0C0h,03h
	defb 80h,0FFh,00h,1Fh,70h,70h,30h,3Ch,18h,0Dh,07h,03h,0F0h,28h,04h,02h
	defb 7Fh,0F8h,0DFh,01h,05h,0Fh,0E0h,7Fh,15h,00h,02h,0FDh,57h,80h,07h,0FEh
	defb 0A8h,00h,40h,0BFh,00h,5Fh,0AAh,55h,2Ah,1Fh,0FBh,80h,0Eh,0Ch,0Ch,38h
	defb 1Bh,0B1h,0E0h,0C0h,04h,02h,0F3h,49h,25h,9Ch,00h,3Fh,44h,22h,11h,0Fh
	defb 80h,0C0h,0C0h,00h,04h,06h,03h,01h,7Fh,80h,1Fh,1Fh,0F8h,7Ch,3Eh,80h
	defb 9Fh,60h,03h,9Fh,0E0h,70h,38h,00h,80h,19h,0E9h,0D3h,00h,01h,0FEh,02h
	defb 0FEh,0FCh,0FCh,0F8h,03h,0FEh,00h,7Ch,7Ch,0FCh,03h,0FCh,00h,00h,7Fh,0FEh
	defb 0E0h,07h,0F8h,00h,03h,00h,0FDh,0FEh,03h,80h,01h,1Fh,0FEh,0FCh,00h,0F0h
	defb 0F8h,85h,0F0h,0E0h,80h,1Fh,01h,06h,00h,83h,0F0h,00h,0Fh,06h,00h,84h
	defb 80h,0F8h,0FEh,0Fh,03h,00h,0A3h,0FCh,03h,7Fh,87h,0F8h,00h,1Fh,00h,3Ch
	defb 0E0h,1Fh,00h,80h,0C0h,0FCh,00h,78h,01h,04h,06h,0F0h,3Fh,00h,0FEh,07h
	defb 0FCh,03h,00h,00h,0AAh,1Fh,00h,0FDh,02h,0FEh,03h,00h,0C5h,0Bh,0F0h,1Ch
	defb 3Dh,71h,62h,0E2h,0C4h,0C4h,0E0h,80h,0C0h,0C3h,06h,18h,30h,03h,07h,3Fh
	defb 0F8h,80h,0Fh,7Fh,00h,01h,0FBh,17h,07h,8Ch,4Ch,40h,23h,7Ch,0F0h,0E3h
	defb 7Fh,3Fh,1Fh,3Fh,2Fh,7Fh,7Fh,0FCh,1Fh,0EEh,0F0h,0FEh,1Fh,0FCh,80h,00h
	defb 03h,0C0h,38h,0Ch,0F0h,00h,00h,38h,0BCh,8Eh,46h,47h,23h,23h,07h,0BFh
	defb 40h,7Fh,03h,00h,0A1h,2Fh,0Fh,0E0h,3Fh,0C0h,00h,00h,55h,0F8h,00h,3Eh
	defb 80h,20h,60h,0Fh,0FCh,00h,7Fh,30h,07h,0F8h,00h,01h,03h,07h,03h,3Fh
	defb 0C0h,0FEh,0E1h,1Fh,00h,0F8h,03h,00h,8Ah,1Fh,07h,0FCh,80h,00h,00h,03h
	defb 1Fh,0FFh,0C0h,04h,00h,82h,0FFh,0F0h,08h,00h,81h,20h,06h,00h,81h,10h
	defb 0Ah,00h,04h,04h,07h,00h,82h,0Eh,07h,07h,00h,02h,0FCh,81h,1Fh,05h
	defb 00h,85h,1Fh,3Fh,0FEh,0E0h,1Fh,03h,00h,91h,03h,0FBh,7Fh,87h,0FBh,7Ch
	defb 03h,00h,0C0h,00h,0C7h,0DBh,5Bh,2Dh,0F0h,7Fh,1Fh,03h,7Fh,0ADh,3Fh,80h
	defb 0C0h,0C0h,0F6h,0E8h,0D3h,0A7h,4Fh,0Fh,0Fh,01h,0Fh,08h,08h,05h,06h,0C3h
	defb 02h,01h,7Fh,9Ch,0F9h,0FEh,5Fh,0C0h,00h,00h,0F8h,07h,07h,08h,0C8h,3Fh
	defb 1Fh,0Fh,0C6h,9Ch,27h,5Fh,0C0h,41h,40h,41h,03h,03h,00h,91h,0EEh,0FEh
	defb 00h,0FEh,80h,0DFh,0FEh,1Eh,7Dh,0FEh,0C0h,00h,0F8h,0FCh,7Fh,07h,0F8h,03h
	defb 00h,83h,3Fh,3Ch,0F8h,05h,00h,81h,0E0h,09h,00h,81h,20h,09h,00h,81h
	defb 18h,03h,00h,81h,0Eh,04h,04h,03h,00h,81h,80h,09h,00h,81h,01h,05h
	defb 00h,83h,7Fh,0F8h,0Fh,03h,00h,84h,80h,40h,00h,0C0h,06h,00h,83h,30h
	defb 0Fh,02h,06h,00h,99h,01h,1Fh,0F0h,80h,3Eh,00h,00h,19h,0E6h,00h,00h
	defb 80h,2Ah,3Fh,0E0h,98h,67h,6Ch,0D0h,40h,60h,70h,38h,0Fh,0Fh,05h,0F0h
	defb 84h,1Fh,43h,5Ch,48h,05h,40h,04h,00h,04h,04h,06h,00h,85h,01h,02h
	defb 00h,00h,20h,0Ah,00h,81h,01h,07h,00h,81h,08h,04h,00h,81h,04h,0Bh
	defb 00h,81h,08h,06h,00h,02h,18h,81h,1Fh,07h,00h,81h,03h,03h,00h,85h
	defb 08h,38h,7Ch,0CCh,88h,18h,00h,83h,3Ch,2Eh,1Fh,03h,08h,82h,04h,6Fh
	defb 03h,1Fh,02h,9Fh,02h,0DFh,81h,7Fh,08h,40h,81h,0Eh,04h,04h,03h,00h
	defb 81h,80h,0Eh,00h,83h,20h,00h,08h,0Ch,00h,86h,08h,00h,0Fh,07h,07h
	defb 01h,05h,00h,03h,81h,8Fh,0E7h,4Eh,00h,00h,07h,03h,0F8h,0D8h,1Ch,3Eh
	defb 3Ch,38h,0C0h,80h,0F0h,0Ah,00h,81h,18h,1Dh,00h,9Dh,01h,03h,03h,07h
	defb 0Fh,7Fh,0E3h,0A1h,0A7h,0ACh,0B8h,0B0h,0B3h,0BFh,0E0h,60h,0Fh,17h,17h,0FBh
	defb 0FBh,40h,60h,9Fh,5Fh,5Fh,4Fh,53h,0B0h,03h,00h,84h,0FCh,0Fh,0F3h,0FEh
	defb 05h,00h,84h,0E0h,3Fh,00h,3Fh,05h,00h,83h,80h,7Fh,03h,03h,00h,81h
	defb 02h,03h,00h,81h,0E0h,05h,00h,81h,08h,06h,00h,94h,01h,07h,1Fh,7Fh
	defb 01h,07h,1Fh,7Fh,0FCh,0FBh,0F7h,0EFh,00h,0F0h,0EEh,0DCh,38h,0F0h,0E0h,0C0h
	defb 06h,00h,88h,01h,00h,00h,08h,08h,14h,08h,08h,08h,00h,02h,01h,90h
	defb 03h,1Fh,3Fh,7Fh,0ECh,0F8h,0BCh,0FCh,0E0h,0F8h,0DEh,90h,0E8h,0F4h,0E8h,0E4h
	defb 05h,00h,03h,80h,8Bh,00h,01h,01h,00h,00h,08h,18h,1Fh,70h,0E0h,80h
	defb 04h,00h,81h,34h,03h,00h,8Ah,01h,03h,0Fh,3Eh,38h,00h,0Ch,0F8h,0E0h
	defb 0C0h,1Fh,00h,90h,01h,03h,0Fh,1Fh,0Fh,3Eh,5Dh,0C0h,0C0h,81h,03h,0F8h
	defb 67h,0ECh,90h,70h,03h,0E0h,82h,0C0h,62h,03h,1Fh,0BCh,0DFh,0EFh,0EFh,0F7h
	defb 0ACh,0A6h,0A3h,0A9h,0AFh,0A1h,0A0h,0A4h,80h,78h,3Ch,1Bh,0C1h,0EEh,37h,0Bh
	defb 0CFh,03h,78h,0BEh,0B7h,1Dh,0E7h,0FBh,0FFh,0FFh,00h,7Fh,9Fh,0E7h,79h,01h
	defb 1Fh,0FFh,0FFh,00h,0FFh,0FFh,0FEh,0F8h,00h,00h,0F3h,1Eh,0FFh,0FFh,7Fh,00h
	defb 01h,87h,03h,7Fh,83h,0DCh,0DFh,1Fh,03h,0FFh,8Eh,7Fh,8Fh,73h,8Ch,0F3h
	defb 0DFh,0DFh,0DEh,0BCh,0B8h,70h,0E0h,0C0h,80h,0Dh,00h,81h,80h,04h,00h,81h
	defb 40h,06h,00h,81h,01h,05h,00h,00h

; ----------------------------------------------------------------------
; DATA graphics_colours_3008: Compressed block that 0x5C27 dumps into VRAM
;   0x3008 (colours, third third).
graphics_colours_3008:
	defb 02h,01h,06h,00h,90h,0C6h,38h,00h,47h,38h,7Fh,1Fh,0Fh,0F0h,0CAh,74h
	defb 0C0h,0C0h,0EEh,0FCh,0F0h,03h,80h,95h,00h,03h,07h,03h,0Dh,3Fh,02h,02h
	defb 07h,3Ch,78h,0F0h,0C0h,0FCh,0F0h,0E0h,0E3h,0C4h,00h,00h,60h,1Fh,00h,0DEh
	defb 01h,00h,00h,01h,07h,0Fh,1Fh,7Fh,0FFh,3Fh,0FEh,0FCh,0F8h,0F8h,0F0h,0F0h
	defb 0E0h,0F6h,0E4h,0E8h,0F8h,0F0h,0F0h,0E0h,0E0h,1Fh,20h,40h,80h,81h,83h,86h
	defb 84h,0E7h,0Ch,0E3h,81h,0E1h,80h,0FDh,0FDh,0A3h,0A1h,71h,0F2h,0F8h,73h,88h
	defb 78h,01h,0E0h,38h,0Eh,01h,0C0h,3Fh,01h,0FCh,00h,7Fh,00h,10h,0Fh,80h
	defb 0C0h,03h,7Ch,0BBh,00h,02h,0C0h,09h,05h,0B8h,71h,0Ah,45h,23h,06h,36h
	defb 65h,00h,60h,0D5h,0BAh,51h,86h,0B8h,0C0h,20h,36h,5Ch,0E0h,80h,07h,00h
	defb 04h,04h,07h,00h,81h,3Eh,06h,00h,84h,80h,00h,00h,08h,0Bh,00h,81h
	defb 20h,06h,00h,81h,40h,05h,00h,90h,1Fh,0Fh,0Fh,00h,00h,80h,7Dh,0FCh
	defb 0E0h,0C0h,0C0h,08h,1Eh,1Ch,0C0h,0E0h,1Ch,00h,0CAh,01h,05h,03h,07h,1Fh
	defb 3Fh,0FCh,0E1h,8Fh,7Eh,0FFh,0F8h,0E3h,17h,67h,0C3h,06h,1Eh,1Fh,60h,0C0h
	defb 0C0h,80h,7Fh,7Eh,03h,0E0h,0C1h,0C7h,9Fh,0BFh,7Eh,0FCh,0F1h,0A1h,0D9h,0D7h
	defb 0CEh,0F0h,0E3h,0C7h,0DAh,7Bh,0E6h,7Ch,00h,0ECh,9Fh,00h,81h,0D8h,0ECh,0EDh
	defb 0EDh,0EAh,54h,0B3h,0DDh,3Ch,0F0h,0C0h,80h,01h,07h,1Fh,3Fh,0Ch,0C0h,0F6h
	defb 01h,0F0h,0FCh,0FEh,80h,04h,05h,8Ah,44h,05h,25h,04h,4Ch,18h,30h,60h
	defb 0C0h,80h,04h,00h,81h,80h,05h,00h,81h,04h,07h,00h,81h,0Eh,04h,04h
	defb 03h,00h,81h,80h,08h,00h,06h,01h,89h,00h,2Ch,5Ch,0BEh,5Fh,2Fh,35h
	defb 4Ch,23h,03h,80h,87h,0C0h,0F0h,0F8h,0FEh,0CCh,07h,0Ch,03h,08h,88h,0Ch
	defb 04h,06h,00h,80h,40h,20h,20h,03h,10h,07h,00h,81h,0Bh,05h,00h,83h
	defb 10h,70h,0F0h,06h,00h,9Ah,40h,0C0h,01h,07h,1Eh,18h,10h,37h,7Fh,0FFh
	defb 00h,06h,0Eh,0Fh,00h,0F3h,0E0h,80h,30h,30h,60h,0C0h,0B0h,0FCh,0E0h,80h
	defb 06h,00h,82h,1Fh,0FFh,0Eh,00h,82h,80h,0FFh,05h,00h,0B5h,01h,03h,0F7h
	defb 0Fh,1Fh,36h,0F8h,0ECh,0C4h,80h,0FDh,7Fh,0E0h,0FDh,0F3h,0CDh,2Ah,54h,00h
	defb 0F8h,0F9h,0FCh,06h,55h,0ABh,07h,0FEh,0F0h,3Fh,03h,87h,0D9h,0ECh,0B2h,38h
	defb 0C3h,1Eh,3Eh,0F1h,00h,07h,0A0h,0A0h,1Eh,3Ch,2Dh,47h,0Fh,0Fh,1Fh,1Fh
	defb 00h,7Eh,03h,00h,8Eh,38h,0FCh,7Eh,21h,11h,80h,0C1h,0C1h,0E1h,0E1h,0E0h
	defb 03h,07h,0Fh,03h,1Fh,85h,0Fh,07h,0F0h,0F8h,0F8h,04h,0FCh,85h,0FEh,80h
	defb 80h,0C0h,0C0h,03h,0E0h,84h,0F0h,00h,00h,04h,0Ch,00h,81h,01h,03h,00h
	defb 85h,07h,1Fh,78h,0E1h,0C1h,03h,00h,85h,80h,0C0h,0C0h,0C4h,80h,05h,00h
	defb 83h,01h,07h,09h,03h,00h,97h,30h,0F8h,0F8h,0FCh,0FCh,05h,02h,00h,7Fh
	defb 7Fh,3Fh,1Fh,0Fh,0FDh,0FEh,83h,5Ch,0BEh,5Fh,2Ah,0Ch,03h,01h,06h,00h
	defb 83h,0B0h,0F0h,0E0h,07h,00h,83h,03h,00h,10h,03h,00h,85h,1Fh,0E0h,0E0h
	defb 03h,07h,03h,0Fh,9Ah,0FCh,78h,60h,0C0h,0C1h,0E0h,0F3h,7Eh,01h,07h,0Fh
	defb 3Fh,06h,3Fh,0C7h,0FCh,0FEh,0FCh,60h,0FEh,0F8h,0F0h,00h,00h,0F0h,0C0h,07h
	defb 00h,84h,3Fh,09h,06h,01h,03h,00h,88h,0FFh,8Fh,73h,0FCh,0FFh,0FFh,3Fh
	defb 0Fh,04h,0FFh,8Fh,7Eh,7Dh,7Eh,0BCh,0EEh,0DDh,0BAh,77h,0EEh,0B8h,0C0h,00h
	defb 0CCh,0B0h,0C0h,0Dh,00h,83h,0Eh,07h,01h,05h,00h,8Bh,0A0h,51h,50h,51h
	defb 38h,06h,01h,00h,1Fh,3Fh,3Fh,03h,1Fh,02h,0Fh,05h,00h,02h,7Fh,81h
	defb 00h,08h,0F0h,9Ch,07h,03h,00h,7Fh,3Fh,3Fh,1Fh,0Fh,0FEh,00h,00h,3Fh
	defb 3Fh,0Fh,0Fh,03h,0F0h,0F8h,0F8h,0FCh,0FCh,0FEh,0FEh,0C0h,03h,07h,06h,0Eh
	defb 03h,0Ch,89h,0Fh,83h,03h,06h,0Ch,18h,30h,0E0h,0C0h,04h,00h,99h,01h
	defb 07h,1Fh,3Dh,10h,00h,37h,6Fh,81h,0Fh,1Fh,38h,0FCh,7Eh,0FEh,58h,0B0h
	defb 0C0h,0A4h,4Ch,07h,03h,01h,00h,10h,03h,00h,83h,0FEh,0F8h,0E0h,09h,00h
	defb 81h,80h,03h,00h,0A8h,08h,30h,01h,11h,03h,1Fh,3Fh,3Eh,1Fh,0F0h,80h
	defb 0FCh,0F8h,83h,83h,0C7h,0FCh,0F8h,0F7h,7Fh,7Fh,1Dh,00h,70h,0F8h,0F0h,0F0h
	defb 0F2h,0F8h,0E0h,0F3h,0BEh,00h,02h,0Eh,3Eh,0F8h,0F8h,0E0h,80h,05h,00h,81h
	defb 04h,12h,00h,81h,03h,07h,00h,82h,78h,0E0h,11h,00h,81h,01h,06h,00h
	defb 81h,08h,07h,00h,81h,10h,05h,00h,81h,0Fh,03h,07h,04h,03h,03h,7Fh
	defb 04h,3Fh,82h,3Eh,0F1h,07h,0F0h,83h,07h,03h,01h,05h,00h,92h,03h,01h
	defb 00h,00h,7Fh,3Fh,1Fh,0Fh,0C0h,0E0h,0E0h,0F0h,38h,18h,0Ch,04h,00h,00h
	defb 03h,80h,03h,0C0h,81h,07h,07h,00h,81h,80h,07h,00h,98h,0Fh,03h,03h
	defb 3Fh,7Fh,27h,2Fh,3Fh,85h,86h,9Dh,1Ah,15h,2Ah,0F4h,0D0h,0FEh,0FEh,0FCh
	defb 0FCh,0F8h,0F8h,0F0h,0F0h,06h,00h,81h,08h,07h,00h,8Eh,10h,00h,7Ch,0F8h
	defb 0F3h,0E7h,0E7h,0F8h,0E0h,0C0h,0E3h,0E0h,0E0h,0C0h,04h,00h,84h,0F8h,7Fh,1Fh
	defb 0Fh,03h,00h,85h,0E0h,0FCh,0B0h,0E0h,0C0h,0Ah,00h,81h,20h,14h,00h,81h
	defb 08h,17h,00h,81h,02h,04h,00h,04h,01h,04h,00h,88h,1Eh,1Fh,1Eh,1Fh
	defb 06h,0Ch,06h,06h,08h,0F0h,83h,07h,03h,01h,05h,00h,88h,06h,02h,00h
	defb 00h,7Fh,3Fh,1Fh,0Fh,03h,0E0h,02h,0F0h,03h,0F8h,04h,00h,81h,01h,05h
	defb 00h,03h,01h,03h,00h,93h,7Fh,0FFh,0FFh,81h,0FFh,1Fh,01h,00h,0E0h,80h
	defb 00h,00h,0FEh,0FCh,0F0h,00h,0E0h,0C0h,80h,0Bh,00h,95h,08h,00h,80h,00h
	defb 00h,04h,0E8h,0C0h,0C0h,0F8h,09h,0D8h,0F7h,0EEh,0C0h,1Eh,78h,60h,0F0h,0E0h
	defb 0C1h,09h,00h,81h,20h,12h,00h,81h,04h,07h,00h,81h,06h,04h,00h,04h
	defb 04h,0Dh,00h,81h,04h,03h,00h,81h,02h,06h,00h,02h,7Fh,04h,3Fh,02h
	defb 1Fh,08h,0F0h,03h,00h,81h,01h,04h,00h,83h,07h,03h,01h,05h,00h,03h
	defb 0FCh,85h,0FEh,7Eh,3Eh,1Fh,0Fh,0Ch,00h,81h,10h,05h,00h,84h,80h,00h
	defb 00h,10h,05h,00h,81h,20h,0Ah,00h,82h,1Fh,09h,05h,00h,8Dh,78h,0FFh
	defb 22h,00h,04h,00h,00h,03h,1Fh,0FFh,52h,0F0h,0E0h,06h,00h,81h,0C0h,1Ch
	defb 00h,84h,04h,00h,00h,0Eh,04h,04h,03h,00h,81h,80h,0Eh,00h,82h,04h
	defb 00h,03h,02h,81h,0Fh,03h,02h,04h,00h,81h,80h,06h,00h,81h,80h,04h
	defb 00h,02h,1Fh,02h,0Fh,03h,07h,81h,03h,08h,0F0h,07h,00h,84h,02h,00h
	defb 00h,60h,04h,00h,84h,01h,07h,03h,01h,06h,00h,02h,80h,83h,0C0h,40h
	defb 20h,08h,00h,82h,3Fh,73h,05h,00h,83h,0C0h,1Eh,80h,04h,00h,84h,03h
	defb 0E0h,1Fh,72h,03h,00h,0A5h,0Fh,08h,0F0h,0C3h,7Ch,03h,1Fh,7Fh,0Bh,36h
	defb 1Ch,5Ah,68h,0Dh,0Bh,09h,00h,55h,55h,25h,27h,55h,75h,52h,00h,72h
	defb 25h,27h,25h,62h,52h,52h,00h,52h,65h,57h,55h,00h	; "%'%bRR.ReWU."

; ----------------------------------------------------------------------
; DATA graphics_patterns_0008: Compressed block that 0x5C30 dumps into VRAM
;   0x0008 (patterns, first third).
graphics_patterns_0008:
	defb 08h,0F0h,08h,30h,08h,40h,08h,0F0h,28h,60h,78h,70h,18h,40h,05h,60h
	defb 02h,80h,89h,0A8h,60h,60h,86h,86h,98h,0A9h,0AAh,0AAh,04h,60h,03h,86h
	defb 81h,0A8h,08h,60h,05h,40h,02h,50h,81h,70h,09h,60h,82h,96h,98h,05h
	defb 60h,84h,86h,60h,60h,86h,04h,80h,89h,90h,86h,66h,66h,86h,96h,96h
	defb 86h,98h,05h,86h,8Bh,96h,66h,98h,86h,86h,98h,96h,96h,86h,96h,96h
	defb 04h,86h,02h,96h,02h,86h,02h,98h,86h,88h,86h,60h,96h,90h,66h,03h
	defb 96h,98h,66h,96h,60h,80h,66h,60h,60h,86h,96h,96h,60h,98h,66h,60h
	defb 80h,86h,66h,96h,60h,60h,86h,66h,86h,80h,04h,60h,03h,66h,8Fh,86h
	defb 60h,60h,86h,66h,96h,96h,66h,96h,96h,66h,88h,86h,66h,96h,03h,86h
	defb 81h,60h,03h,86h,02h,60h,85h,80h,96h,80h,60h,96h,03h,80h,83h,98h
	defb 96h,60h,06h,80h,81h,99h,03h,60h,04h,80h,82h,98h,99h,06h,60h,84h
	defb 86h,98h,96h,60h,06h,80h,07h,90h,83h,86h,98h,99h,04h,60h,88h,86h
	defb 98h,99h,99h,80h,80h,98h,98h,08h,0A9h,81h,0AAh,03h,0FAh,03h,0BAh,05h
	defb 0FBh,06h,0A8h,02h,0A9h,03h,60h,05h,86h,04h,50h,04h,60h,84h,0F4h,70h
	defb 50h,50h,0Ch,40h,08h,0F0h,08h,70h,04h,80h,04h,70h,81h,86h,07h,80h
	defb 03h,86h,05h,80h,02h,96h,83h,66h,98h,60h,03h,80h,91h,86h,96h,96h
	defb 86h,80h,86h,86h,80h,86h,66h,96h,96h,98h,98h,86h,86h,98h,03h,96h
	defb 97h,66h,96h,99h,96h,99h,96h,96h,66h,96h,96h,86h,86h,90h,98h,99h
	defb 99h,96h,96h,66h,86h,60h,96h,96h,03h,98h,85h,86h,66h,96h,96h,66h
	defb 03h,96h,08h,60h,02h,96h,02h,60h,02h,96h,85h,88h,86h,86h,96h,96h
	defb 03h,86h,81h,88h,03h,86h,08h,60h,81h,96h,07h,60h,84h,0A9h,98h,98h
	defb 86h,04h,80h,04h,0A9h,04h,98h,04h,0FAh,81h,0AAh,03h,0A9h,04h,0FBh,04h
	defb 0BAh,07h,0A9h,83h,0A8h,86h,96h,03h,0A9h,8Ch,0A8h,86h,86h,60h,60h,66h
	defb 86h,96h,86h,66h,60h,40h,07h,60h,06h,0B0h,02h,20h,08h,40h,08h,80h
	defb 81h,86h,07h,80h,84h,98h,66h,96h,86h,04h,80h,82h,86h,66h,04h,86h
	defb 82h,80h,90h,08h,86h,81h,60h,03h,86h,87h,60h,86h,86h,66h,86h,98h
	defb 96h,03h,86h,04h,96h,89h,99h,96h,96h,86h,96h,98h,66h,96h,66h,05h
	defb 96h,83h,86h,66h,96h,03h,86h,82h,96h,86h,10h,50h,08h,80h,02h,0A9h
	defb 03h,98h,03h,80h,81h,0AAh,03h,0A9h,02h,98h,02h,88h,02h,0A8h,81h,88h
	defb 04h,86h,84h,60h,86h,86h,66h,0Dh,60h,08h,0E0h,90h,20h,30h,20h,20h
	defb 30h,30h,20h,30h,0C0h,20h,0C0h,0C0h,20h,20h,0C0h,20h,08h,40h,06h,70h
	defb 05h,60h,87h,90h,0C0h,90h,0C0h,90h,70h,00h,03h,30h,8Bh,42h,0C5h,0C7h
	defb 30h,30h,20h,20h,0C0h,0C2h,0C5h,0C7h,03h,60h,81h,90h,03h,0C0h,82h,90h
	defb 60h,04h,80h,03h,40h,83h,96h,66h,86h,05h,90h,95h,66h,86h,86h,98h
	defb 98h,60h,00h,00h,96h,86h,96h,96h,98h,66h,60h,80h,86h,66h,86h,86h
	defb 96h,08h,86h,02h,98h,81h,86h,08h,60h,81h,80h,07h,60h,05h,86h,07h
	defb 60h,16h,50h,02h,0B0h,03h,30h,95h,32h,30h,20h,30h,20h,30h,32h,0A2h
	defb 0B3h,20h,0C0h,20h,0C0h,20h,0C2h,0A2h,0B3h,00h,50h,0B0h,0B0h,03h,30h,81h
	defb 32h,08h,40h,08h,70h,03h,0F7h,85h,70h,50h,40h,40h,00h,03h,0F7h,81h
	defb 70h,04h,50h,82h,40h,75h,06h,40h,04h,70h,83h,0C0h,20h,0C0h,05h,70h
	defb 84h,0C0h,92h,0C0h,70h,08h,0A0h,10h,80h,08h,0F0h,05h,40h,02h,50h,81h
	defb 70h,04h,60h,08h,30h,02h,0A0h,02h,0C2h,04h,00h,81h,0CAh,03h,0C3h,81h
	defb 30h,03h,20h,87h,0C0h,20h,20h,0C0h,20h,30h,30h,03h,32h,82h,0C2h,0C0h
	defb 06h,30h,92h,32h,0C3h,0C0h,94h,80h,60h,30h,0F3h,0B2h,0B2h,0C0h,94h,80h
	defb 60h,30h,0F3h,0B2h,0B2h,06h,30h,85h,32h,0C3h,20h,30h,30h,03h,32h,83h
	defb 0C2h,0C0h,30h,03h,20h,84h,0C0h,20h,20h,0C0h,04h,00h,81h,0CAh,03h,0C3h
	defb 06h,60h,02h,0C2h,08h,30h,08h,70h,05h,40h,02h,50h,85h,70h,0F4h,70h
	defb 50h,50h,0Ch,40h,08h,30h,04h,0B0h,81h,30h,0Ah,20h,81h,32h,06h,0B0h
	defb 82h,0B3h,32h,05h,0B0h,02h,0C3h,94h,30h,0B0h,0C0h,50h,20h,00h,33h,0CCh
	defb 30h,32h,32h,20h,20h,0C0h,0C3h,0C3h,30h,30h,0C0h,20h,03h,0C3h,86h,33h
	defb 14h,20h,32h,20h,30h,03h,0C3h,81h,0C0h,04h,20h,8Fh,22h,0F2h,0C8h,0C8h
	defb 0C0h,80h,20h,22h,0F2h,82h,0C8h,0C8h,00h,0C0h,0C2h,03h,32h,85h,0B3h,20h
	defb 00h,0C0h,0C2h,03h,32h,84h,0B3h,20h,0C0h,80h,04h,20h,82h,0C2h,0C0h,04h
	defb 20h,88h,22h,0C2h,0CCh,0C0h,20h,32h,20h,30h,03h,0C3h,98h,0C0h,30h,0C0h
	defb 20h,0C3h,0C3h,33h,33h,40h,32h,32h,20h,20h,0C0h,0C3h,0C3h,30h,0B0h,0C0h
	defb 50h,20h,00h,33h,0CCh,05h,30h,84h,0B0h,0C3h,0C3h,30h,06h,0B0h,82h,0B3h
	defb 32h,07h,00h,81h,32h,04h,0B0h,81h,30h,04h,20h,07h,30h,84h,0F4h,70h
	defb 50h,50h,0Ch,40h,08h,50h,00h

; ----------------------------------------------------------------------
; DATA graphics_patterns_0808: Compressed block that 0x5C39 dumps into VRAM
;   0x0808 (patterns, second third).
graphics_patterns_0808:
	defb 0Ah,90h,81h,30h,03h,20h,90h,30h,0F0h,20h,20h,32h,0C2h,0C2h,22h,32h
	defb 20h,20h,0F0h,40h,40h,50h,20h,03h,22h,94h,32h,82h,42h,40h,20h,22h
	defb 22h,0C2h,32h,32h,0C3h,20h,20h,32h,22h,30h,20h,22h,32h,32h,03h,22h
	defb 8Bh,30h,0C2h,0C0h,0B2h,0B2h,32h,22h,22h,20h,42h,40h,05h,32h,85h,14h
	defb 0B4h,32h,22h,32h,03h,0C2h,02h,80h,81h,0C3h,05h,0C2h,03h,62h,02h,92h
	defb 8Dh,62h,20h,20h,62h,62h,93h,0F9h,0F9h,92h,62h,62h,20h,52h,03h,0B3h
	defb 85h,83h,0B3h,0B3h,20h,52h,06h,32h,82h,0C2h,22h,05h,32h,81h,0C3h,08h
	defb 0C2h,02h,80h,81h,0C3h,05h,0C2h,8Bh,40h,0B4h,32h,22h,0C2h,22h,22h,0C2h
	defb 20h,42h,40h,05h,32h,8Dh,30h,0C2h,0C0h,0B2h,0B2h,32h,22h,22h,30h,20h
	defb 22h,32h,32h,03h,22h,81h,0C2h,03h,32h,02h,20h,03h,22h,97h,32h,82h
	defb 42h,40h,20h,22h,22h,20h,0F0h,40h,40h,50h,20h,22h,22h,20h,20h,32h
	defb 0C2h,0C2h,22h,32h,20h,03h,30h,03h,20h,82h,30h,0F0h,08h,80h,08h,50h
	defb 08h,40h,82h,0F0h,70h,04h,20h,02h,0C0h,89h,50h,44h,40h,43h,20h,32h
	defb 0C2h,0C2h,33h,04h,40h,85h,30h,32h,22h,32h,30h,04h,40h,85h,30h,32h
	defb 22h,32h,30h,05h,40h,03h,0C2h,82h,33h,30h,03h,40h,03h,0C2h,02h,32h
	defb 8Bh,20h,40h,40h,32h,32h,0C3h,32h,32h,30h,20h,32h,03h,0C2h,84h,0A2h
	defb 0C2h,0C3h,0C0h,07h,0C2h,82h,22h,20h,08h,0C2h,04h,83h,95h,32h,20h,0C2h
	defb 0FCh,0B3h,0B3h,30h,43h,80h,00h,0B2h,0CBh,32h,0B2h,20h,42h,80h,00h,0B2h
	defb 0CBh,33h,04h,32h,83h,20h,0C2h,0FCh,0Eh,0C2h,81h,22h,06h,0C2h,83h,0C3h
	defb 0C0h,0CCh,05h,32h,83h,30h,20h,32h,03h,0C2h,02h,32h,83h,20h,40h,40h
	defb 03h,0C2h,82h,33h,30h,03h,40h,83h,22h,32h,30h,05h,40h,82h,32h,30h
	defb 04h,40h,83h,30h,32h,33h,04h,40h,90h,30h,32h,22h,50h,44h,40h,43h
	defb 20h,32h,0C2h,0C2h,0F0h,70h,00h,20h,20h,0Bh,0C0h,82h,0C2h,0CCh,06h,0C0h
	defb 84h,22h,0C2h,0C0h,0C2h,04h,0C0h,82h,30h,32h,03h,20h,87h,0CCh,0C0h,0C0h
	defb 40h,30h,32h,22h,03h,0C2h,8Ah,0CCh,40h,20h,80h,80h,30h,32h,22h,0C2h
	defb 30h,04h,20h,85h,90h,32h,22h,30h,20h,04h,0C0h,02h,0C3h,03h,30h,02h
	defb 20h,02h,0C0h,83h,30h,50h,0A0h,04h,40h,02h,20h,02h,40h,8Fh,42h,20h
	defb 20h,22h,32h,20h,0B0h,0B3h,0B2h,0B2h,0F2h,0F3h,0F3h,0B0h,0C4h,06h,0C2h,83h
	defb 0F0h,40h,40h,03h,0C0h,85h,0FCh,0F7h,0F7h,00h,0A0h,03h,40h,83h,0C0h,0FFh
	defb 77h,03h,30h,02h,20h,02h,0C0h,02h,30h,81h,20h,04h,0C0h,83h,30h,0C3h
	defb 30h,04h,20h,8Fh,90h,32h,22h,40h,20h,80h,80h,30h,32h,22h,0C2h,40h
	defb 30h,32h,22h,04h,0C2h,82h,30h,32h,03h,20h,87h,0CCh,0C0h,00h,22h,22h
	defb 0C0h,0C2h,04h,0C0h,02h,0C2h,0Eh,0C0h,08h,50h,08h,0A0h,05h,40h,02h,50h
	defb 81h,70h,08h,40h,09h,0C0h,81h,0C2h,07h,0C0h,83h,0C2h,20h,0C2h,04h,0C0h
	defb 02h,0C2h,82h,0C0h,20h,04h,0C0h,83h,0C4h,0CCh,0C2h,05h,0C0h,04h,20h,81h
	defb 30h,03h,0C0h,05h,20h,02h,30h,02h,20h,02h,0B2h,02h,0F3h,85h,0B3h,0F0h
	defb 0F0h,70h,70h,03h,0C7h,88h,75h,00h,00h,75h,90h,90h,74h,74h,05h,40h
	defb 02h,0C4h,85h,42h,40h,40h,0C0h,0C4h,03h,0CCh,02h,0C0h,84h,0CCh,0C0h,0C2h
	defb 0C2h,07h,0C0h,83h,0C2h,20h,0C2h,05h,0C0h,81h,0C2h,0Eh,0C0h,08h,50h,08h
	defb 40h,84h,0F4h,70h,50h,50h,0Ch,40h,08h,50h,83h,40h,54h,50h,04h,40h
	defb 81h,50h,09h,40h,05h,0C0h,05h,0B0h,02h,0B2h,96h,20h,0A0h,0A0h,80h,0A9h
	defb 22h,0A3h,30h,90h,32h,0C2h,80h,0A9h,0C2h,32h,0F0h,0F0h,0FCh,0FCh,40h,40h
	defb 0A4h,04h,0C4h,81h,40h,03h,0C0h,05h,50h,05h,40h,02h,50h,81h,70h,07h
	defb 40h,09h,50h,08h,40h,08h,50h,28h,40h,05h,90h,07h,0A0h,81h,90h,0Bh
	defb 0A0h,03h,0E4h,84h,0F4h,0E4h,74h,74h,09h,40h,08h,50h,84h,0F4h,70h,50h
	defb 50h,1Ch,40h,08h,50h,83h,40h,50h,50h,07h,40h,02h,54h,05h,40h,02h
	defb 54h,82h,50h,54h,03h,40h,02h,50h,0Eh,40h,05h,90h,07h,0A0h,04h,90h
	defb 08h,0A0h,08h,50h,09h,40h,02h,0F4h,05h,40h,02h,50h,81h,74h,04h,54h
	defb 04h,40h,85h,70h,75h,50h,50h,55h,05h,70h,83h,75h,55h,50h,06h,70h
	defb 02h,75h,04h,40h,04h,70h,08h,50h,08h,0E0h,81h,0F0h,07h,0E0h,81h,0FFh
	defb 07h,0E0h,08h,40h,82h,00h,30h,03h,40h,04h,30h,08h,60h,03h,90h,04h
	defb 98h,03h,60h,05h,86h,08h,60h,21h,40h,04h,90h,03h,0A0h,81h,90h,04h
	defb 0A0h,05h,90h,0Ah,0A0h,04h,0F0h,03h,50h,85h,0F0h,0F7h,87h,87h,76h,04h
	defb 40h,85h,80h,84h,64h,64h,74h,0Fh,40h,84h,85h,80h,80h,60h,04h,40h
	defb 05h,50h,03h,40h,07h,50h,82h,85h,75h,06h,50h,83h,54h,00h,77h,05h
	defb 50h,89h,44h,0E0h,0E0h,0E7h,50h,70h,50h,50h,40h,05h,0E0h,83h,70h,50h
	defb 40h,10h,0E0h,08h,50h,08h,40h,08h,30h,00h

; ----------------------------------------------------------------------
; DATA graphics_patterns_1008: Compressed block that 0x5C42 dumps into VRAM
;   0x1008 (patterns, third third).
graphics_patterns_1008:
	defb 08h,60h,02h,98h,86h,88h,98h,98h,80h,80h,60h,03h,86h,82h,96h,86h
	defb 07h,60h,05h,40h,05h,54h,02h,50h,08h,40h,03h,90h,81h,0B0h,09h,90h
	defb 04h,0B0h,81h,90h,03h,0B0h,03h,90h,08h,0F0h,02h,0A0h,07h,0F0h,07h,0F7h
	defb 81h,70h,07h,75h,81h,50h,07h,0E5h,86h,50h,75h,70h,75h,0E4h,0E4h,07h
	defb 40h,83h,70h,50h,50h,05h,40h,02h,70h,93h,0E0h,40h,44h,40h,00h,40h
	defb 40h,70h,0E0h,65h,50h,40h,00h,70h,40h,70h,70h,40h,50h,06h,40h,82h	; "@p.eP@.p@pp@P.@."
	defb 00h,50h,07h,40h,81h,50h,0Bh,40h,02h,50h,81h,70h,08h,80h,08h,0D0h
	defb 08h,40h,08h,0B0h,0Bh,40h,81h,54h,06h,40h,02h,50h,0Ch,40h,05h,90h
	defb 04h,0B0h,81h,90h,03h,0B0h,03h,90h,18h,0F0h,81h,70h,04h,0F7h,02h,70h
	defb 81h,87h,05h,75h,03h,74h,8Fh,0E5h,50h,50h,0F0h,70h,40h,50h,70h,40h
	defb 40h,50h,00h,70h,54h,55h,07h,50h,02h,40h,04h,54h,04h,0A4h,81h,0E0h
	defb 03h,40h,03h,0A0h,81h,0FAh,04h,70h,84h,40h,70h,70h,0A0h,08h,40h,08h
	defb 50h,08h,30h,84h,0F4h,70h,50h,50h,0Ch,40h,08h,60h,04h,96h,04h,86h
	defb 83h,60h,90h,60h,04h,90h,81h,96h,1Eh,40h,02h,50h,07h,40h,81h,50h
	defb 05h,40h,04h,50h,02h,40h,82h,50h,55h,03h,54h,08h,40h,08h,0F0h,06h
	defb 0B0h,02h,0FFh,06h,0B0h,0Dh,0F0h,81h,0F5h,03h,0F4h,83h,40h,0F4h,0F4h,05h
	defb 40h,82h,44h,0F4h,07h,40h,83h,76h,54h,54h,05h,40h,81h,74h,03h,54h
	defb 86h,44h,40h,70h,70h,40h,40h,06h,0A0h,82h,00h,0A0h,03h,0AAh,03h,0FAh
	defb 02h,40h,06h,0A0h,10h,0FAh,08h,0A0h,10h,50h,10h,40h,08h,90h,04h,80h
	defb 04h,60h,02h,86h,81h,66h,05h,60h,02h,80h,81h,98h,03h,86h,02h,96h
	defb 20h,40h,81h,50h,05h,40h,02h,54h,04h,40h,84h,54h,40h,54h,40h,03h
	defb 54h,0Dh,40h,82h,0FFh,0F0h,03h,0E0h,03h,0B0h,03h,0F0h,05h,0E0h,05h,0F0h
	defb 03h,0E0h,0Bh,0F0h,0Dh,0E0h,08h,40h,05h,70h,03h,40h,08h,0A0h,05h,0FFh
	defb 02h,0FAh,81h,0FFh,08h,0A0h,02h,0FAh,81h,0AAh,05h,0A0h,83h,0FAh,0FFh,0FFh
	defb 05h,0FAh,07h,0A0h,81h,0FAh,10h,40h,08h,80h,84h,90h,00h,60h,60h,03h
	defb 86h,81h,98h,03h,60h,05h,86h,04h,60h,04h,20h,08h,60h,0Bh,40h,81h
	defb 80h,04h,40h,83h,50h,54h,54h,05h,40h,05h,54h,83h,75h,55h,75h,05h
	defb 50h,03h,54h,03h,40h,02h,50h,0Bh,40h,10h,50h,10h,0E0h,08h,0F0h,08h
	defb 50h,08h,20h,08h,40h,08h,0A0h,08h,0FAh,10h,0A0h,02h,0FAh,02h,0AAh,04h
	defb 0A0h,08h,0FAh,08h,0A0h,10h,40h,02h,80h,81h,60h,05h,80h,08h,86h,08h
	defb 60h,08h,50h,08h,30h,06h,40h,0Ah,50h,81h,54h,03h,40h,04h,50h,02h
	defb 54h,0Eh,40h,08h,0B0h,08h,50h,08h,90h,10h,0F0h,08h,20h,08h,0A0h,08h
	defb 0FAh,10h,0A0h,02h,0FAh,02h,0AAh,0Ch,0A0h,08h,30h,04h,80h,04h,60h,03h
	defb 80h,81h,86h,04h,60h,02h,86h,02h,66h,0Ch,60h,08h,0F0h,81h,50h,03h
	defb 40h,03h,54h,84h,40h,50h,54h,50h,03h,40h,02h,50h,10h,40h,0Dh,0B0h
	defb 04h,80h,07h,60h,05h,40h,02h,50h,82h,70h,60h,07h,0F0h,10h,50h,10h
	defb 0A0h,08h,40h,18h,0A0h,08h,50h,04h,20h,04h,50h,08h,30h,06h,40h,82h
	defb 60h,86h,05h,50h,02h,60h,84h,86h,50h,50h,90h,04h,60h,81h,86h,08h
	defb 40h,08h,50h,0Ah,0B0h,06h,0A0h,08h,40h,84h,0F4h,70h,50h,50h,13h,40h
	defb 04h,50h,83h,70h,50h,70h,0Ah,50h,18h,0A0h,08h,40h,04h,50h,04h,0E0h
	defb 10h,0A0h,07h,80h,81h,86h,05h,00h,83h,86h,98h,86h,05h,60h,83h,86h
	defb 98h,98h,04h,80h,03h,86h,81h,98h,03h,60h,82h,86h,96h,1Bh,86h,00h

; ----------------------------------------------------------------------
; DATA graphics_9B3F: Compressed block requested by 0x5B98.
graphics_9B3F:
	defb 8Dh,0B9h,0B5h,0BEh,0BEh,0BEh,0BEh,8Eh,0BEh,0B6h,8Fh,0BEh,0BEh,91h,0BEh,0BEh
	defb 90h,0BEh,91h,92h,0BDh,0BEh,0BEh,0BEh,0BEh,0BFh,0C0h,0C1h,0ADh,0A4h,93h,0D4h
	defb 0D4h,0C9h,0CAh,94h,95h,0C5h,96h,0C3h,97h,98h,0C9h,0D4h,99h,0D3h,9Ah,9Bh
	defb 0D2h,0D3h,0D4h,0D4h,0D4h,0D5h,0FFh,00h,00h,0ADh,0A4h,00h,00h,9Ch,9Dh,9Eh
	defb 9Fh,0A0h,0A3h,0DEh,0A1h,0A2h,0DBh,0D7h,0E2h,0E3h,0E4h,0A3h,0E2h,0E3h,0E4h,00h
	defb 0F3h,0FFh,00h,00h,00h,00h,0ADh,0A4h,00h,0EAh,0ECh,0A5h,0A6h,0A7h,0ACh,0ECh
	defb 0A8h,0F2h,0A9h,0AAh,0ABh,0F1h,0F2h,0ACh,0F0h,0F1h,0F2h,0F3h,0FFh,00h,00h,00h
	defb 00h,00h,00h,0ADh,0AEh,0F8h,0F9h,0AFh,0FDh,0F8h,0B2h,0F9h,0B0h,0FEh,0FDh,0FDh
	defb 0B1h,0FDh,0FEh,0B2h,0FCh,0FDh,0FEh,0FFh,00h,00h,00h,00h

; ----------------------------------------------------------------------
; DATA graphics_9BCB: Compressed block requested by 0x5B93.
graphics_9BCB:
	defb 0B3h,0B4h,0B5h,0BEh,0BEh,0BEh,0BEh,0B6h,0B7h,0BEh,0BBh,0BEh,0BEh,0B8h,0BEh,0BEh
	defb 0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BEh,0BEh,0BEh,0BFh,0C0h,0C1h,00h,0F4h,0C2h,0D4h
	defb 0D4h,0C3h,0C4h,0C5h,0C6h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh,0D0h,0D1h
	defb 0D2h,0D3h,0D4h,0D4h,0D4h,0D5h,0FFh,00h,00h,00h,0F4h,0E5h,00h,0DEh,0D6h,0D7h
	defb 0D8h,0D9h,0DAh,0DBh,0DCh,0DFh,0E0h,0DDh,0DEh,0DFh,0E0h,0E1h,0E2h,0E3h,0E4h,00h
	defb 0F3h,0FFh,00h,00h,00h,00h,00h,0F4h,0E5h,0ECh,0E6h,0EAh,0E7h,0E8h,0E9h,0EAh
	defb 0ECh,0EDh,0EEh,0EBh,0ECh,0EDh,0EEh,0EFh,0F0h,0F1h,0F2h,0F3h,0FFh,00h,00h,00h
	defb 00h,00h,00h,00h,0F4h,0F9h,0FDh,0F8h,0F5h,0F6h,0F7h,0F8h,0F9h,0FAh,0FDh,0FDh
	defb 0F9h,0FAh,0FDh,0FBh,0FCh,0FDh,0FEh,0FFh,00h,00h,00h,00h

; ----------------------------------------------------------------------
; DATA graphics_2468: Compressed block that 0x5B56 passes to decompress_three_thirds with
;   HL=0x2468: decompress_three_thirds dumps it three times, once per screen third, adding
;   0x800 each time.
graphics_2468:
	defb 8Ah,00h,0FFh,0C0h,60h,30h,18h,0Ch,06h,00h,0FFh,04h,00h,02h,0C7h,82h
	defb 00h,0FFh,04h,00h,02h,7Fh,82h,00h,0FFh,04h,00h,02h,9Fh,82h,00h,0FFh
	defb 04h,00h,02h,0F8h,82h,00h,0FFh,04h,00h,86h,02h,06h,0Fh,07h,03h,01h
	defb 04h,00h,04h,0C7h,03h,0C0h,81h,0C1h,04h,0FFh,84h,20h,60h,0E0h,0E0h,04h
	defb 7Fh,84h,02h,06h,0Eh,1Eh,04h,0FFh,81h,41h,03h,0C1h,08h,0F8h,04h,9Fh
	defb 84h,00h,01h,03h,07h,04h,0F8h,04h,00h,89h,0Eh,1Eh,3Eh,7Eh,02h,06h
	defb 0Eh,1Eh,7Ch,07h,0FCh,08h,0Fh,81h,0C3h,07h,0C7h,02h,0E0h,06h,0FFh,02h
	defb 00h,06h,0E0h,08h,0C1h,08h,0F8h,81h,3Eh,07h,7Eh,88h,00h,80h,0C0h,60h
	defb 30h,18h,0Ch,06h,08h,0C7h,05h,0E0h,03h,0FFh,05h,00h,03h,0FCh,08h,0C1h
	defb 05h,0FCh,03h,0FFh,05h,00h,03h,0FFh,05h,00h,03h,9Fh,08h,7Eh,82h,03h
	defb 01h,07h,00h,87h,80h,0C0h,60h,30h,18h,0Ch,07h,03h,0C7h,04h,00h,81h
	defb 0FFh,03h,0C1h,04h,00h,81h,0FFh,03h,9Fh,04h,00h,81h,0FFh,03h,7Eh,04h
	defb 00h,8Bh,0FFh,00h,7Fh,30h,18h,0Ch,06h,03h,01h,00h,0FFh,05h,00h,83h
	defb 80h,00h,0FFh,04h,00h,84h,3Fh,1Fh,00h,0FFh,04h,00h,02h,0FCh,82h,00h
	defb 0FFh,04h,00h,02h,3Fh,82h,00h,0FFh,04h,00h,02h,0C3h,82h,00h,0FFh,07h
	defb 00h,81h,0FFh,04h,00h,84h,43h,0C3h,00h,0FFh,04h,00h,02h,0F0h,82h,00h
	defb 0FFh,04h,00h,02h,7Eh,82h,00h,0FFh,04h,00h,02h,1Fh,82h,00h,0FFh,04h
	defb 00h,02h,0FFh,82h,00h,0FFh,04h,00h,84h,0FCh,0F8h,00h,0FFh,05h,00h,8Dh
	defb 01h,00h,0FEh,0Ch,18h,30h,60h,0C0h,80h,0Fh,07h,03h,01h,03h,00h,81h
	defb 80h,04h,0FFh,02h,00h,82h,01h,03h,04h,0FFh,81h,40h,03h,0C0h,04h,0FCh
	defb 04h,00h,04h,3Fh,84h,01h,03h,07h,0Fh,04h,0FFh,02h,03h,82h,07h,0Fh
	defb 07h,0F0h,81h,0E0h,04h,0FFh,84h,04h,0Ch,1Ch,3Ch,04h,0FFh,04h,0Fh,04h
	defb 0C3h,04h,0C0h,04h,0FFh,84h,10h,30h,70h,0F0h,04h,0FFh,04h,3Fh,88h,01h
	defb 03h,07h,0Fh,00h,00h,01h,03h,04h,0C3h,81h,40h,03h,0C0h,04h,0F0h,84h
	defb 10h,30h,70h,0F0h,08h,7Eh,04h,1Fh,84h,00h,01h,03h,07h,04h,0FFh,04h
	defb 80h,04h,0FFh,04h,00h,84h,0F0h,0E0h,0C0h,80h,03h,00h,83h,01h,0C0h,0C0h
	defb 06h,0C7h,02h,00h,06h,0FCh,81h,1Fh,07h,3Fh,84h,1Fh,3Fh,7Fh,0FEh,04h
	defb 03h,84h,0C0h,80h,00h,00h,04h,0F0h,82h,7Ch,0FCh,06h,0FFh,02h,0Fh,06h
	defb 0FFh,08h,3Fh,81h,07h,07h,0Fh,81h,0C1h,07h,0C3h,08h,0F0h,08h,7Eh,81h
	defb 0Fh,07h,1Fh,02h,80h,06h,0FFh,02h,00h,06h,0F8h,07h,00h,81h,80h,05h
	defb 0C0h,03h,0FFh,08h,3Fh,08h,03h,08h,0F0h,08h,0FCh,05h,3Fh,03h,0FFh,08h
	defb 0Fh,08h,0C3h,05h,0F0h,03h,0FFh,05h,7Eh,03h,0FEh,05h,00h,03h,1Fh,05h
	defb 01h,03h,0FFh,08h,0F8h,07h,00h,89h,01h,0C0h,60h,30h,18h,0Ch,06h,03h
	defb 01h,03h,3Fh,04h,00h,81h,0FFh,03h,03h,04h,00h,81h,0FFh,03h,0F0h,04h
	defb 00h,81h,0FFh,03h,0FCh,04h,00h,81h,0FFh,03h,0Fh,04h,00h,81h,0FFh,03h
	defb 0C3h,04h,00h,81h,0FFh,03h,0FEh,04h,00h,81h,0FFh,03h,1Fh,04h,00h,04h
	defb 0FFh,04h,00h,81h,0FFh,03h,0F8h,04h,00h,89h,0FFh,03h,06h,0Ch,18h,30h
	defb 60h,0C0h,80h,00h

; ----------------------------------------------------------------------
; DATA graphics_0468: Compressed block that 0x5B5F passes to decompress_three_thirds with
;   HL=0x0468, again across the three thirds.
graphics_0468:
	defb 0Bh,0F0h,04h,0E0h,04h,0F0h,04h,0E0h,04h,0F0h,04h,0E0h,04h,0F0h,04h,0E0h
	defb 04h,0F0h,04h,0E0h,83h,0F0h,70h,70h,04h,50h,04h,70h,02h,50h,04h,40h
	defb 02h,70h,02h,50h,04h,40h,02h,70h,02h,50h,04h,40h,02h,70h,02h,50h
	defb 04h,40h,02h,70h,02h,50h,04h,40h,02h,70h,02h,50h,04h,40h,02h,70h
	defb 04h,50h,04h,70h,02h,50h,04h,40h,04h,50h,02h,70h,02h,0F0h,04h,50h
	defb 02h,70h,02h,0F0h,04h,50h,02h,70h,02h,0F0h,04h,50h,02h,70h,02h,0F0h
	defb 04h,50h,02h,70h,02h,0F0h,04h,50h,02h,70h,02h,0F0h,04h,50h,02h,70h
	defb 02h,0F0h,04h,50h,02h,70h,0Bh,0F0h,02h,70h,04h,50h,84h,40h,0F0h,70h
	defb 70h,04h,50h,04h,40h,04h,50h,84h,40h,0F0h,70h,70h,04h,50h,84h,40h
	defb 0F0h,70h,70h,04h,50h,04h,40h,04h,50h,04h,40h,04h,50h,84h,40h,0F0h
	defb 70h,70h,04h,50h,81h,40h,10h,0F0h,04h,40h,04h,0F0h,04h,40h,04h,0F0h
	defb 04h,40h,04h,0F0h,07h,40h,14h,0F0h,04h,0E0h,04h,0F0h,04h,0E0h,04h,0F0h
	defb 04h,0E0h,04h,0F0h,04h,0E0h,0Ch,0F0h,04h,0E0h,04h,0F0h,04h,0E0h,04h,0F0h
	defb 04h,0E0h,04h,0F0h,04h,0E0h,04h,0F0h,04h,0E0h,04h,0F0h,04h,0E0h,11h,0F0h
	defb 02h,70h,05h,50h,85h,0F0h,70h,70h,50h,50h,04h,40h,02h,70h,02h,50h
	defb 04h,40h,02h,70h,04h,50h,04h,70h,02h,50h,04h,40h,02h,70h,02h,50h
	defb 04h,40h,02h,70h,02h,50h,04h,40h,02h,70h,02h,50h,04h,40h,02h,70h
	defb 02h,50h,04h,40h,02h,70h,02h,50h,04h,40h,02h,70h,02h,50h,04h,40h
	defb 02h,70h,02h,50h,04h,40h,02h,70h,04h,50h,02h,40h,02h,70h,02h,50h
	defb 04h,40h,02h,70h,02h,50h,04h,40h,02h,70h,02h,50h,04h,40h,02h,70h
	defb 02h,50h,04h,40h,02h,70h,02h,50h,04h,40h,02h,70h,04h,50h,04h,70h
	defb 05h,50h,81h,0F0h,04h

	end

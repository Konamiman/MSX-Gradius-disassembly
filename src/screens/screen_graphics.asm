; ============================================================================
; Nemesis / Gradius - screens image (banks 9-10) - screen_graphics.asm
; ============================================================================

	public graphics_colours_0418,graphics_colours_0780,graphics_patterns_2418,graphics_patterns_2780,graphics_sprites_1800,graphics_sprites_1800_b

; Bank 10 (runs at 0xA000).
;
; Mixed bank: 424 bytes of code and the rest data. It is mapped together with
; bank 9 (0x8000) for the fixed screens, and also together with bank 2
; (p00:4B0A) to load the scoreboard graphics.

; ----------------------------------------------------------------------
; DATA data_A000: 219 bytes that no instruction points at with the address
;   written in it: they sit right in front of the first compressed block of
;   the bank. ASSUMPTION: they are the header or the first part of that same
;   batch of graphics.
data_A000:
	defb 50h,02h,70h,02h,0F0h,04h,50h,02h,70h,02h,0F0h,04h,50h,02h,70h,02h
	defb 0F0h,04h,50h,02h,70h,02h,0F0h,04h,50h,02h,70h,02h,0F0h,04h,50h,02h
	defb 70h,02h,0F0h,04h,50h,02h,70h,02h,0F0h,04h,50h,02h,70h,02h,0F0h,04h
	defb 50h,02h,70h,02h,0F0h,04h,50h,02h,70h,02h,0F0h,04h,50h,02h,70h,02h
	defb 0F0h,04h,50h,02h,70h,02h,0F0h,04h,50h,02h,70h,02h,0F0h,04h,50h,02h
	defb 70h,02h,0F0h,04h,50h,02h,70h,0Bh,0F0h,02h,70h,04h,50h,84h,40h,0F0h
	defb 70h,70h,04h,50h,84h,40h,0F0h,70h,70h,04h,50h,84h,40h,0F0h,70h,70h
	defb 04h,50h,84h,40h,0F0h,70h,70h,04h,50h,84h,40h,0F0h,70h,70h,04h,50h
	defb 84h,40h,0F0h,70h,70h,04h,50h,84h,40h,0F0h,70h,70h,04h,50h,84h,40h
	defb 0F0h,70h,70h,04h,50h,84h,40h,0F0h,70h,70h,04h,50h,04h,40h,04h,50h
	defb 84h,40h,0F0h,70h,70h,04h,50h,84h,40h,0F0h,70h,70h,04h,50h,04h,40h
	defb 0Dh,0F0h,04h,40h,04h,0F0h,04h,40h,04h,0F0h,04h,40h,04h,0F0h,04h,40h
	defb 04h,0F0h,04h,40h,04h,0F0h,04h,40h,04h,0F0h,04h,40h,04h,0F0h,04h,40h
	defb 04h,0F0h,04h,40h,04h,0F0h,04h,40h,0Ch,0F0h,00h

; ----------------------------------------------------------------------
; DATA graphics_patterns_2418: Compressed block that 0x4B17 passes to decompress_three_thirds
;   with HL=0x2418: it is dumped three times, once per third, adding 0x800. In
;   this cartridge the patterns live at VRAM 0x2000 and the colours at 0x0000,
;   the other way round from what the BIOS sets up.
graphics_patterns_2418:
	defb 9Ah,80h,40h,00h,00h,13h,0Bh,0C3h,0C1h,40h,30h,30h,00h,0Ch,8Eh,0CFh
	defb 0E3h,60h,0F0h,0F0h,60h,00h,00h,0E3h,0F7h,03h,03h,03h,70h,02h,00h,03h
	defb 07h,02h,0Fh,98h,07h,03h,07h,0Fh,8Bh,0D3h,0D3h,56h,63h,0C1h,3Ch,9Dh
	defb 0E9h,0E3h,0C0h,0C9h,01h,70h,0F8h,0F8h,0Fh,0Fh,0C7h,0E0h,03h,0F0h,0C0h,0E0h
	defb 1Fh,1Fh,3Fh,3Fh,1Fh,1Fh,0Dh,01h,1Dh,3Fh,3Fh,0Eh,3Eh,40h,3Ah,1Eh
	defb 3Fh,3Bh,0FCh,7Ch,79h,0C3h,07h,83h,08h,0DDh,0E9h,0C6h,86h,0CFh,0EFh,0C6h
	defb 07h,07h,03h,11h,38h,10h,00h,00h,0BFh,7Eh,7Fh,7Fh,7Eh,1Ch,3Eh,1Ch
	defb 71h,0F8h,70h,0F8h,70h,00h,03h,01h,0C6h,80h,00h,10h,38h,10h,80h,06h
	defb 00h,83h,60h,0F0h,0FEh,06h,00h,02h,60h,83h,10h,3Bh,17h,03h,07h,0ABh
	defb 33h,78h,6Fh,9Fh,0EEh,0CEh,0D1h,1Dh,1Fh,7Eh,00h,03h,63h,0F0h,0D0h,0C0h
	defb 0F0h,0F8h,79h,33h,03h,03h,01h,00h,00h,01h,10h,76h,7Fh,7Eh,0F6h,7Fh
	defb 39h,3Eh,0CEh,0C4h,0C0h,0CCh,9Eh,1Eh,0Ch,00h,01h,03h,03h,81h,01h,03h
	defb 00h,9Ah,3Eh,7Eh,0FCh,0F4h,0EEh,0C4h,00h,00h,03h,07h,07h,0BFh,7Fh,19h
	defb 3Ch,3Bh,80h,0C0h,0C0h,0C4h,80h,0E0h,0F0h,0FAh,1Fh,3Fh,03h,7Eh,90h,3Eh
	defb 0Ch,3Ch,0F8h,0F0h,0F6h,0EFh,0CFh,06h,80h,80h,01h,01h,0Bh,07h,01h,05h
	defb 00h,82h,0A0h,0C0h,09h,00h,05h,01h,85h,03h,8Fh,7Fh,17h,01h,03h,00h
	defb 84h,80h,0E2h,0FCh,0D0h,04h,00h,05h,01h,81h,03h,07h,00h,0A2h,80h,00h
	defb 00h,60h,3Ch,0Fh,07h,01h,00h,03h,03h,07h,1Fh,6Fh,0B7h,03h,0Fh,80h
	defb 80h,0C0h,0F0h,0F6h,0EDh,80h,0E0h,00h,00h,0Ch,78h,0E0h,0C0h,00h,00h,03h
	defb 07h,00h,81h,80h,0Ah,00h,07h,01h,03h,03h,02h,07h,83h,0Fh,00h,00h
	defb 03h,80h,02h,0C0h,82h,0E0h,01h,07h,00h,85h,0C0h,0F8h,3Fh,07h,01h,03h
	defb 00h,0A4h,01h,0Fh,7Fh,0BFh,80h,1Fh,01h,00h,0FCh,7Fh,0BFh,0DFh,6Fh,07h
	defb 00h,1Fh,7Eh,0FDh,0FBh,0F7h,0ECh,0C0h,00h,0F0h,00h,0E0h,0FDh,0FBh,03h,0F0h
	defb 00h,00h,07h,3Eh,0F8h,0C0h,04h,00h,81h,07h,07h,00h,81h,0C0h,0Bh,00h
	defb 09h,01h,03h,03h,05h,00h,03h,80h,05h,00h,81h,01h,07h,00h,83h,0E0h
	defb 0FEh,7Fh,07h,00h,81h,0EFh,05h,00h,93h,07h,0FBh,0FDh,03h,07h,0Fh,0Fh
	defb 1Fh,0F8h,0FFh,0FFh,80h,0C0h,0E0h,0E0h,0F0h,3Fh,0FFh,0FFh,05h,00h,83h,0C0h
	defb 0BEh,7Fh,05h,00h,86h,0Fh,0FEh,0FCh,1Fh,07h,01h,05h,00h,85h,0EFh,0F3h
	defb 0F8h,70h,01h,03h,00h,86h,0FEh,00h,03h,01h,0F0h,0Fh,03h,00h,9Bh,7Fh
	defb 0BFh,0DFh,0Fh,00h,0C0h,3Fh,0FEh,0FDh,0FBh,0F7h,0E0h,00h,0FEh,0F8h,0C0h,00h
	defb 80h,00h,0Fh,0E0h,00h,00h,0EFh,1Fh,3Fh,1Ch,04h,00h,82h,0F0h,0E0h,06h
	defb 00h,81h,0Fh,07h,00h,81h,0E0h,0Ch,00h,0Bh,01h,02h,03h,05h,07h,83h
	defb 0Fh,80h,80h,05h,0C0h,81h,0F0h,05h,00h,82h,07h,03h,06h,00h,8Bh,80h
	defb 0F0h,0FCh,00h,00h,02h,01h,01h,00h,06h,3Fh,04h,00h,94h,80h,7Fh,0BFh
	defb 5Fh,0Fh,0Fh,1Fh,3Fh,38h,0B8h,40h,20h,0F0h,0F0h,0F8h,0FCh,3Eh,33h,0F7h
	defb 0EFh,04h,00h,87h,01h,0FDh,0FAh,0F5h,00h,00h,40h,03h,80h,82h,0E0h,0FCh
	defb 05h,00h,83h,07h,1Fh,0Fh,05h,00h,86h,0C0h,80h,00h,7Fh,1Fh,07h,05h
	defb 00h,85h,0EFh,0F7h,0F9h,0FCh,3Fh,04h,00h,0B4h,0Fh,00h,01h,00h,7Fh,1Fh
	defb 00h,0AFh,0D7h,0EBh,0F5h,0FAh,0F3h,0FDh,0FEh,0DFh,0EFh,0EFh,0F0h,0EFh,0Fh,1Fh
	defb 07h,0EFh,0DFh,0DFh,3Fh,0DEh,0C1h,0E0h,80h,0EBh,0D7h,0AFh,5Fh,0BCh,9Fh,7Fh
	defb 0FCh,00h,0F0h,0FEh,0FCh,00h,0F8h,0E0h,00h,0DFh,0BFh,7Fh,0FEh,0F0h,03h,00h
	defb 83h,0FCh,0F0h,0C0h,05h,00h,82h,3Fh,01h,06h,00h,84h,0DFh,0E7h,78h,1Fh
	defb 04h,00h,84h,0EFh,9Eh,78h,0E0h,04h,00h,81h,0F0h,08h,00h,03h,04h,86h
	defb 06h,04h,04h,14h,80h,00h,03h,80h,83h,0D0h,50h,44h,05h,00h,93h,01h
	defb 09h,09h,0Ah,4Ah,52h,6Ah,2Eh,5Ah,22h,0AAh,50h,0D2h,8Ah,74h,0A4h,15h
	defb 2Ah,0CBh,05h,00h,0C3h,80h,90h,90h,19h,11h,2Ah,38h,28h,19h,29h,0F8h
	defb 0B2h,0E5h,00h,0BBh,00h,6Dh,6Dh,00h,0Dh,0E5h,00h,0DDh,00h,0B6h,0B6h,00h
	defb 98h,88h,54h,1Ch,14h,98h,94h,1Fh,3Eh,08h,0Bh,09h,01h,01h,00h,00h
	defb 0BBh,00h,7Dh,51h,2Ah,0Dh,05h,05h,0DDh,00h,0EEh,04h,0D8h,50h,40h,80h
	defb 7Ch,10h,0D0h,90h,80h,80h,00h,00h,00h

; ----------------------------------------------------------------------
; DATA graphics_colours_0418: Compressed block that 0x4B20 passes to decompress_three_thirds
;   with HL=0x0418.
graphics_colours_0418:
	defb 81h,0F0h,04h,40h,96h,0F0h,70h,40h,70h,70h,40h,00h,70h,40h,40h,0F0h
	defb 70h,0F0h,70h,40h,00h,00h,70h,0F0h,70h,40h,40h,05h,70h,83h,40h,0F0h
	defb 0F0h,03h,70h,02h,40h,02h,0F4h,81h,0F7h,04h,74h,03h,0F7h,93h,0F4h,74h
	defb 74h,0F7h,0F4h,0F4h,0F0h,40h,40h,0F0h,0F0h,70h,70h,40h,70h,0F0h,0F0h,70h
	defb 70h,03h,40h,04h,0F7h,85h,74h,0F4h,0F7h,0F7h,74h,05h,0F7h,02h,0F4h,84h
	defb 0F0h,70h,40h,40h,04h,0F0h,81h,70h,03h,40h,84h,70h,40h,00h,00h,04h
	defb 0F4h,02h,74h,02h,40h,87h,74h,0F4h,0F4h,40h,40h,00h,70h,03h,40h,84h
	defb 00h,40h,70h,40h,09h,0F0h,04h,70h,04h,0F0h,03h,70h,05h,40h,03h,70h
	defb 02h,0F4h,04h,74h,82h,00h,0F0h,03h,70h,03h,40h,81h,70h,07h,40h,04h
	defb 0F7h,8Ah,74h,40h,74h,0F7h,0F0h,70h,40h,0F0h,70h,70h,0Ah,40h,02h,0F4h
	defb 03h,70h,05h,40h,02h,0F0h,81h,70h,03h,0F4h,04h,40h,84h,70h,40h,70h
	defb 0F0h,05h,0F4h,02h,74h,81h,40h,03h,0F0h,81h,70h,03h,40h,04h,0F0h,04h
	defb 50h,04h,0F0h,05h,50h,08h,0F0h,85h,0E0h,50h,70h,0F0h,0F0h,05h,50h,83h
	defb 70h,0F0h,0F0h,05h,50h,04h,0F0h,04h,0E0h,0Bh,0F0h,93h,0E0h,50h,50h,0F0h
	defb 50h,70h,0E0h,0F5h,0F5h,85h,50h,0E0h,40h,50h,0E0h,0F5h,0F5h,85h,50h,05h
	defb 0F0h,03h,0E0h,10h,70h,04h,0A0h,81h,0E0h,05h,0F0h,84h,0E0h,0F0h,0F0h,50h
	defb 04h,70h,03h,0E0h,83h,40h,50h,50h,09h,0A0h,04h,0F0h,04h,50h,84h,0E0h
	defb 0E5h,0F5h,0F5h,03h,50h,82h,0E7h,0E5h,03h,0F5h,85h,95h,55h,50h,0E5h,0E5h
	defb 03h,0F5h,88h,95h,55h,50h,00h,0E0h,0E5h,0F5h,0F5h,03h,50h,81h,0A0h,07h
	defb 0F0h,10h,70h,05h,0B0h,81h,0E0h,07h,0F0h,81h,0E0h,04h,0F0h,06h,0E0h,0Eh
	defb 0B0h,09h,0F0h,81h,0F5h,06h,0E0h,02h,0E5h,82h,0F0h,50h,03h,70h,81h,0E7h
	defb 03h,0E0h,02h,40h,02h,50h,81h,0E5h,08h,0E0h,02h,0E5h,06h,0B0h,0Ah,0F0h
	defb 02h,0F5h,02h,0F4h,04h,50h,85h,0E5h,0FFh,0F4h,0F4h,54h,03h,50h,81h,0FFh
	defb 03h,0F5h,84h,94h,44h,54h,50h,04h,0F5h,90h,94h,44h,40h,50h,0FEh,0FFh
	defb 0F4h,44h,54h,40h,00h,00h,0F5h,0F5h,0F4h,0F4h,0Ch,0F0h,10h,70h,06h,0B0h
	defb 83h,60h,0E0h,0E0h,09h,0F0h,02h,0E0h,03h,0F0h,84h,50h,0F0h,0F0h,50h,04h
	defb 0E0h,81h,40h,06h,0B0h,04h,0F0h,04h,0B0h,87h,0E0h,0F0h,00h,00h,80h,60h
	defb 60h,04h,0E0h,04h,60h,03h,0E5h,81h,50h,03h,70h,85h,75h,0E7h,0FEh,0FEh
	defb 40h,03h,50h,81h,54h,03h,0E5h,05h,60h,03h,0E5h,05h,60h,81h,50h,04h
	defb 0E0h,04h,0B0h,82h,0E0h,0FEh,06h,0B0h,04h,0F0h,06h,0E0h,84h,0E5h,0F5h,0F5h
	defb 0E4h,04h,50h,88h,0EEh,0FEh,0FFh,0FEh,55h,50h,40h,00h,04h,0F5h,84h,0E5h
	defb 52h,50h,40h,03h,0FEh,02h,0F4h,83h,84h,95h,60h,03h,0FEh,02h,0F4h,83h
	defb 84h,95h,60h,04h,0F5h,8Fh,0E5h,52h,50h,40h,0EEh,0FEh,0F5h,0E5h,55h,50h
	defb 40h,00h,0E5h,0F5h,0F5h,05h,0E0h,02h,0F0h,06h,0E0h,0Ah,40h,81h,50h,05h
	defb 70h,02h,40h,81h,50h,05h,70h,06h,40h,04h,50h,8Ah,0E0h,50h,50h,0E0h
	defb 50h,80h,0A0h,00h,50h,90h,03h,50h,81h,0A0h,07h,0F0h,90h,0E0h,50h,0A0h
	defb 40h,40h,50h,60h,0F4h,70h,50h,40h,50h,50h,40h,54h,0E0h,04h,40h,04h	; "@@P`.pP@PP@T..@."
	defb 0F0h,0A4h,0E0h,50h,70h,70h,50h,50h,70h,50h,70h,40h,50h,00h,0F0h,00h
	defb 70h,50h,00h,70h,40h,00h,0E0h,00h,70h,50h,00h,50h,70h,70h,50h,50h
	defb 70h,50h,70h,50h,50h,70h,03h,50h,04h,0F0h,91h,50h,60h,40h,40h,50h	; "pPpPPp.P...P`@@P"
	defb 40h,0E0h,00h,50h,60h,40h,40h,50h,70h,50h,50h,70h,05h,50h,00h

; ----------------------------------------------------------------------
; DATA graphics_sprites_1800: Compressed block that 0x4B29 dumps into VRAM
;   0x1800, which in this cartridge is the sprite pattern table.
graphics_sprites_1800:
	defb 06h,00h,83h,01h,1Fh,01h,0Bh,00h,87h,01h,0Eh,0F0h,00h,0F0h,0Eh,01h
	defb 0Ah,00h,85h,01h,0Ch,0C0h,0Ch,01h,0Bh,00h,85h,80h,30h,03h,30h,80h
	defb 0Ch,00h,83h,03h,3Fh,03h,0Dh,00h,83h,0C0h,0FCh,0C0h,0Dh,00h,83h,07h
	defb 3Fh,07h,09h,00h,8Bh,03h,1Ch,30h,0E0h,80h,00h,80h,0E0h,30h,1Ch,03h
	defb 06h,00h,89h,03h,0Eh,18h,70h,0E0h,70h,18h,0Eh,03h,07h,00h,89h,0C0h
	defb 70h,18h,0Eh,07h,0Eh,18h,70h,0C0h,08h,00h,87h,01h,07h,0Fh,1Fh,0Fh
	defb 07h,01h,09h,00h,87h,80h,0E0h,0F0h,0F8h,0F0h,0E0h,80h,0Ah,00h,85h,01h
	defb 02h,78h,02h,01h,09h,00h,02h,80h,87h,40h,20h,0Fh,20h,40h,80h,80h
	defb 0Ah,00h,83h,01h,06h,01h,0Ch,00h,85h,80h,40h,30h,40h,80h,0Dh,00h
	defb 81h,01h,0Eh,00h,83h,80h,0C0h,80h,0Bh,00h,87h,80h,70h,0Fh,00h,0Fh
	defb 70h,80h,0Bh,00h,83h,80h,0F8h,80h,09h,00h,8Bh,0C0h,38h,0Ch,07h,01h
	defb 00h,01h,07h,0Ch,38h,0C0h,09h,00h,83h,0E0h,0FCh,0E0h,07h,00h,81h,80h
	defb 1Fh,00h,83h,40h,0E0h,40h,1Dh,00h,02h,0C0h,1Eh,00h,85h,20h,70h,0F8h
	defb 70h,20h,1Bh,00h,00h

; ----------------------------------------------------------------------
; DATA graphics_patterns_2780: Compressed block that 0x5C4B passes to decompress_three_thirds
;   with HL=0x2780.
graphics_patterns_2780:
	defb 05h,00h,02h,04h,85h,0Eh,1Fh,0Eh,04h,04h,08h,00h,04h,04h,81h,0Eh
	defb 04h,04h,06h,00h,04h,04h,83h,0Eh,1Fh,0Eh,05h,04h,03h,00h,81h,20h
	defb 07h,00h,81h,20h,07h,00h,81h,20h,05h,00h,00h

; ----------------------------------------------------------------------
; DATA graphics_colours_0780: Compressed block that 0x5C54 passes to decompress_three_thirds
;   with HL=0x0780.
graphics_colours_0780:
	defb 06h,40h,04h,50h,0Bh,40h,02h,50h,85h,70h,74h,70h,50h,50h,04h,40h
	defb 06h,0B0h,02h,0F0h,81h,0FBh,03h,0F0h,04h,0B0h,08h,70h,08h,0F0h,08h,90h
	defb 00h

; ----------------------------------------------------------------------
; DATA graphics_sprites_1800_b: Compressed block that 0x5C5D dumps into VRAM
;   0x1800, the sprite pattern one.
graphics_sprites_1800_b:
	defb 02h,80h,02h,40h,02h,20h,02h,10h,02h,08h,02h,04h,02h,02h,02h,01h
	defb 10h,00h,88h,80h,40h,20h,10h,08h,04h,02h,01h,10h,00h,8Ch,80h,40h
	defb 20h,10h,08h,04h,02h,01h,0C0h,30h,0Ch,03h,10h,00h,84h,0C0h,30h,0Ch
	defb 03h,0Ch,00h,84h,03h,0Ch,30h,0C0h,08h,00h,84h,03h,0Ch,30h,0C0h,14h
	defb 00h,90h,01h,02h,04h,08h,10h,20h,40h,80h,01h,02h,04h,08h,10h,20h
	defb 40h,80h,18h,00h,02h,01h,02h,02h,02h,04h,02h,08h,02h,10h,02h,20h
	defb 02h,40h,02h,80h,00h

	end

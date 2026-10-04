; ============================================================================
; Nemesis / Gradius - scenery image (banks 4-6) - records.asm
; ============================================================================

; Bank 5 (runs at 0x8000).
;
; THIS BANK HOLDS NO CODE. It holds two things:
;
;   - the six-byte RECORDS with which routine 0x4371 in bank 0 loads the
;     scenery: a flag saying which third of the screen, the colour source,
;     the index of the character where it starts, the pattern source. A zero
;     flag ends the list.
;   - graphics compressed in the 0x49B9 format (tools/rle.py), just like the
;     whole of bank 4.
;
; The sources in the records point into this bank AND into bank 4, because
; both are mapped at the same time (the 4/5/6 split at p00:4234 and its
; copies). Walking the records gives 198 distinct sources, and all of them
; fall within 0x6000-0x9FFF.

; ----------------------------------------------------------------------
; GRAPHICS AND LOADING RECORDS (bank 5)
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; DATA graphics_chain_8000: Chain of 20 compressed blocks that fit with no
;   slack, from 0x8000 to 0x86BA. They are requested by the records of this
;   same bank.
graphics_chain_8000:
	defb 0EEh,84h,0FEh,0F5h,0F5h,50h,05h,0E0h,02h,0E5h,02h,0FEh,16h,0E0h,88h,0F0h
	defb 0F5h,0E0h,0E0h,0FEh,0FEh,0F5h,0F5h,06h,0F0h,81h,0F5h,06h,0F0h,02h,0F5h,87h
	defb 0FFh,0F5h,0F5h,0FEh,0FFh,0F5h,0F5h,04h,0F0h,04h,0E0h,02h,0E5h,02h,0FEh,08h
	defb 0E0h,03h,70h,02h,50h,02h,70h,81h,0E0h,03h,50h,87h,40h,50h,70h,0F0h
	defb 0F0h,0E0h,0E0h,05h,0F0h,04h,0F5h,07h,0F0h,02h,0F5h,04h,0F0h,02h,0F5h,07h
	defb 0F0h,03h,0F5h,04h,0F0h,02h,0FEh,81h,0F5h,05h,0F0h,06h,0E0h,02h,0E5h,85h
	defb 0E0h,70h,70h,50h,50h,03h,70h,02h,0F0h,8Eh,70h,50h,40h,50h,0E0h,0F0h
	defb 0F5h,0F0h,0F0h,0F5h,0E5h,0E0h,0F0h,0F0h,03h,0F5h,02h,0F0h,03h,0F5h,02h,0F0h
	defb 02h,0F5h,03h,0F0h,81h,0FFh,09h,0F0h,87h,0F5h,0FFh,0FFh,0F5h,0F5h,50h,50h
	defb 08h,0F5h,02h,0E5h,06h,0E0h,81h,0F5h,07h,0E0h,83h,0F5h,0E5h,0E5h,05h,0E0h
	defb 02h,0F5h,81h,50h,05h,0E0h,83h,0F0h,0FFh,0FFh,03h,0F0h,02h,0F5h,81h,0F0h
	defb 04h,0FFh,81h,0F5h,04h,50h,02h,0F0h,0Ah,0F5h,02h,0FEh,18h,0E0h,04h,50h
	defb 84h,0F5h,0FEh,0EEh,0EEh,03h,0F5h,02h,0FEh,0Bh,0E0h,00h,90h,0FFh,0F0h,0F0h
	defb 0F0h,60h,60h,0F6h,98h,98h,96h,60h,60h,00h,0F0h,0F0h,0F0h,00h,90h,0FFh
	defb 0F0h,0F0h,0F0h,40h,40h,0F4h,75h,75h,74h,40h,40h,00h,0F0h,0F0h,0F0h,00h
	defb 88h,0E0h,0E0h,0E4h,74h,0E4h,0E4h,0F4h,0F4h,03h,0E0h,02h,74h,03h,0F4h,00h
	defb 81h,0F4h,03h,74h,02h,0E4h,81h,0F0h,04h,0E0h,02h,74h,05h,0F4h,03h,0E4h
	defb 86h,74h,70h,00h,0F4h,0E4h,74h,06h,0F4h,07h,74h,02h,0F4h,02h,0E4h,84h
	defb 74h,0E4h,0E0h,0E0h,03h,0F4h,02h,74h,04h,0E0h,83h,0F0h,0E4h,0E4h,03h,74h
	defb 02h,0F4h,81h,0F0h,04h,0E0h,04h,0F0h,02h,0E4h,03h,74h,02h,0F4h,03h,74h
	defb 02h,0E4h,81h,0F0h,04h,0E0h,02h,74h,06h,0F4h,02h,74h,03h,0E0h,03h,0F4h
	defb 85h,74h,0F4h,0E4h,0E7h,0E0h,04h,74h,02h,0E4h,04h,0E0h,89h,74h,0E4h,0E4h
	defb 0F4h,0F4h,74h,0F4h,0E4h,74h,06h,0F4h,0Bh,74h,81h,0E4h,03h,0E0h,07h,74h
	defb 81h,0F4h,00h,02h,0E0h,84h,0E4h,74h,0E4h,0E4h,04h,0F4h,02h,0E4h,81h,74h
	defb 03h,0E4h,81h,74h,03h,0F4h,02h,0E4h,02h,74h,8Ch,40h,0E4h,0E4h,0F4h,74h
	defb 0E4h,0E4h,0F4h,0F4h,0E4h,74h,0E4h,03h,74h,88h,0E4h,0F4h,0E4h,0E4h,74h,0F4h
	defb 0E0h,0E0h,03h,40h,03h,0E0h,02h,0E4h,81h,0F4h,03h,0E4h,85h,74h,0E4h,0E4h
	defb 0F4h,0F4h,04h,0E0h,03h,0E4h,81h,74h,00h,84h,0F0h,70h,0E0h,0E0h,04h,70h
	defb 8Bh,40h,0E0h,0E0h,0F0h,70h,0E4h,0E4h,0F4h,0F4h,0E4h,0E4h,03h,0E0h,02h,40h
	defb 06h,0E0h,86h,0F0h,0F4h,0F0h,70h,0E0h,0E0h,04h,70h,8Bh,40h,0E0h,0E0h,0F0h
	defb 70h,0E4h,0E4h,0F4h,0F4h,0E4h,0E4h,03h,0E0h,02h,40h,06h,0E0h,82h,0F0h,0F4h
	defb 00h,17h,0B0h,83h,0A6h,0B0h,0B0h,06h,60h,15h,0B0h,83h,60h,0A6h,0A9h,0Ah
	defb 0B0h,04h,60h,02h,96h,14h,0B0h,03h,60h,81h,96h,03h,0B0h,02h,0A6h,03h
	defb 96h,02h,0A6h,02h,60h,1Ch,0B0h,02h,96h,02h,0A6h,02h,60h,02h,0B0h,02h
	defb 96h,03h,60h,13h,0B0h,02h,60h,06h,0B0h,02h,96h,03h,0A6h,03h,0B0h,05h
	defb 96h,83h,0A6h,60h,60h,08h,96h,81h,0A6h,7Fh,96h,3Dh,96h,33h,60h,00h
	defb 82h,00h,70h,07h,40h,91h,77h,44h,00h,74h,00h,55h,44h,00h,77h,44h
	defb 00h,74h,00h,50h,44h,00h,70h,0Ch,40h,81h,54h,07h,40h,82h,54h,40h
	defb 00h,86h,40h,70h,40h,0E0h,0F0h,0E0h,04h,40h,84h,70h,0F0h,70h,50h,04h
	defb 40h,84h,77h,0FFh,77h,55h,05h,40h,82h,77h,55h,0Bh,40h,81h,50h,06h
	defb 40h,81h,50h,11h,40h,84h,0F0h,70h,50h,70h,05h,40h,02h,0F4h,02h,74h
	defb 02h,40h,87h,77h,74h,74h,00h,77h,74h,74h,06h,70h,02h,74h,02h,00h
	defb 02h,74h,88h,77h,00h,74h,74h,77h,00h,74h,74h,05h,70h,08h,40h,08h
	defb 80h,00h,18h,0B0h,00h,28h,0B0h,00h,04h,0B0h,84h,60h,60h,96h,98h,20h
	defb 0B0h,00h,06h,50h,04h,70h,04h,50h,02h,70h,00h,02h,70h,04h,80h,04h
	defb 90h,04h,80h,02h,90h,00h,04h,70h,03h,50h,0A1h,70h,00h,50h,50h,40h
	defb 40h,40h,50h,50h,74h,74h,80h,0B9h,0B9h,84h,84h,64h,75h,85h,94h,90h
	defb 80h,00h,40h,40h,65h,0F5h,95h,94h,94h,00h,0F4h,0F4h,00h,04h,90h,03h
	defb 80h,0A1h,90h,00h,80h,80h,60h,60h,60h,80h,80h,96h,96h,0D0h,0BAh,0BAh
	defb 0D6h,0D6h,86h,98h,0D8h,0A6h,0A0h,0D0h,00h,60h,60h,88h,0F8h,0A8h,0A6h,0A6h
	defb 00h,0F6h,0F6h,00h,88h,0F4h,0E0h,0F0h,0F7h,50h,0F0h,50h,50h,03h,40h,93h
	defb 70h,75h,40h,40h,74h,70h,0E0h,0F0h,0F0h,70h,0F0h,70h,0F7h,0E5h,50h,40h
	defb 40h,70h,50h,06h,40h,88h,0F0h,40h,0F0h,0F7h,0E4h,40h,50h,70h,08h,40h
	defb 87h,70h,0F0h,70h,0F7h,0E4h,40h,70h,05h,40h,06h,70h,83h,0F0h,0F7h,0E5h
	defb 07h,40h,00h,0A0h,00h,0F0h,0E0h,0F0h,0E0h,0A0h,0A0h,0B0h,00h,0F0h,0E0h,0F0h
	defb 0E0h,0A0h,0A0h,0B0h,0B0h,0A0h,0A0h,0E0h,0F0h,0E0h,0F0h,00h,0B0h,0A0h,0A0h,0E0h
	defb 0F0h,0E0h,0F0h,00h,00h,0A0h,00h,0F0h,0E0h,0F0h,0E0h,0C0h,20h,30h,00h,0F0h
	defb 0E0h,0F0h,0E0h,0C0h,20h,30h,30h,20h,0C0h,0E0h,0F0h,0E0h,0F0h,00h,30h,20h
	defb 0C0h,0E0h,0F0h,0E0h,0F0h,00h,00h,9Ch,00h,70h,30h,0B0h,0F0h,0B0h,30h,70h
	defb 00h,70h,30h,0B0h,0F0h,0B0h,30h,70h,00h,70h,30h,0B0h,0F0h,0B0h,30h,70h
	defb 0F0h,0B0h,30h,70h,09h,00h,8Bh,70h,30h,0B0h,00h,70h,30h,0B0h,0F0h,0B0h
	defb 30h,70h,03h,00h,83h,0B0h,0F0h,0B0h,04h,00h,90h,30h,0B0h,0F0h,0B0h,30h
	defb 00h,00h,70h,30h,0B0h,0F0h,0B0h,30h,70h,30h,70h,09h,00h,8Bh,70h,30h
	defb 0B0h,0F0h,0B0h,30h,0B0h,0F0h,0B0h,30h,70h,09h,00h,81h,70h,05h,00h,03h
	defb 0E0h,86h,00h,0E0h,50h,70h,0F0h,0E0h,04h,0F0h,84h,0F4h,0F5h,0F5h,0F4h,0Ah
	defb 0F0h,03h,0E0h,05h,00h,02h,0F0h,86h,0E0h,0F0h,70h,50h,0E0h,00h,00h,90h
	defb 00h,38h,67h,68h,71h,73h,67h,67h,00h,1Ch,0E6h,16h,8Eh,0CEh,0E6h,0E6h
	defb 03h,00h,8Dh,0FCh,0AAh,0F0h,00h,00h,02h,04h,08h,30h,60h,1Dh,5Dh,5Dh
	defb 03h,00h,81h,0EDh,04h,6Dh,9Fh,0Ah,0ABh,0Bh,00h,00h,38h,84h,0C1h,00h
	defb 7Fh,0BEh,1Dh,0Bh,47h,8Eh,1Ch,63h,71h,68h,7Eh,00h,7Fh,00h,7Fh,6Dh
	defb 6Dh,0EDh,6Dh,00h,0D0h,0D0h,06h,00h,0AFh,03h,0Ch,30h,00h,07h,1Fh,07h
	defb 3Fh,0C0h,01h,0C2h,0BFh,0DEh,0EFh,0F7h,0F6h,0F7h,80h,4Fh,0A2h,70h,0FCh,06h
	defb 18h,0E0h,00h,0FEh,0C0h,00h,80h,0C0h,60h,30h,98h,0CCh,0FCh,0D0h,08h,0FCh
	defb 0FCh,42h,0BEh,69h,80h,36h,6Ch,00h,04h,66h,84h,80h,36h,6Ch,00h,04h
	defb 06h,83h,80h,36h,6Ch,05h,00h,00h,84h,3Fh,0FFh,0FFh,3Fh,04h,00h,04h
	defb 0F3h,08h,00h,84h,03h,0Fh,3Eh,0FDh,06h,00h,82h,03h,0Fh,05h,00h,0B6h
	defb 07h,80h,38h,00h,01h,02h,04h,00h,10h,00h,00h,0C6h,8Eh,16h,7Eh,00h
	defb 0FEh,00h,5Dh,00h,0FCh,78h,7Dh,7Eh,7Ch,00h,3Bh,5Dh,1Ch,5Eh,0AFh,0D3h
	defb 69h,34h,1Ah,3Ch,7Ah,0F7h,0EEh,0DCh,81h,7Fh,00h,3Fh,7Fh,00h,57h,0D7h
	defb 0D7h,80h,00h,5Dh,5Dh,00h,03h,0F7h,0EFh,03h,01h,00h,7Fh,3Eh,81h,9Ch
	defb 0CEh,0E7h,0F0h,00h,3Fh,80h,0CFh,0E0h,73h,38h,00h,80h,0F0h,81h,0FCh,86h
	defb 0F3h,99h,0Ch,7Dh,0A0h,63h,7Dh,38h,71h,0C3h,0A2h,0F0h,07h,5Ch,58h,01h
	defb 43h,83h,85h,00h,00h,3Ch,00h,7Eh,3Ch,18h,3Ch,0F8h,0Ch,06h,02h,83h
	defb 0C1h,0C1h,0A1h,0E0h,7Fh,00h,00h,75h,15h,15h,0D5h,7Fh,7Fh,00h,0BEh,80h
	defb 0BEh,80h,0BEh,00h,0C0h,3Ch,01h,3Fh,70h,1Fh,3Fh,0F0h,07h,5Ch,58h,01h
	defb 43h,83h,85h,00h,00h,3Ch,00h,7Eh,3Ch,18h,3Ch,0F8h,0Ch,06h,02h,83h
	defb 0C1h,0C1h,0A1h,7Dh,0A0h,63h,7Dh,38h,03h,00h,89h,0F0h,07h,5Ch,58h,00h
	defb 40h,80h,00h,0FFh,07h,00h,85h,0F8h,0Ch,06h,02h,03h,03h,01h,00h,02h
	defb 40h,8Eh,50h,40h,40h,50h,70h,0F0h,40h,40h,50h,40h,40h,50h,70h,0F0h	; "@.P@@Pp.@@P@@Pp."
	defb 04h,40h,85h,80h,0C5h,44h,55h,80h,05h,40h,82h,70h,0E0h,04h,40h,87h
	defb 50h,70h,0E0h,0F0h,60h,90h,60h,03h,40h,81h,70h,04h,40h,02h,50h,03h
	defb 40h,8Eh,0E0h,50h,40h,0E5h,55h,70h,40h,0D0h,0E0h,70h,50h,40h,10h,70h
	defb 04h,50h,04h,20h,05h,40h,87h,54h,50h,40h,50h,54h,40h,40h,03h,50h
	defb 81h,70h,03h,40h,02h,50h,85h,75h,74h,74h,50h,50h,08h,40h,9Ah,0E0h
	defb 50h,70h,40h,70h,40h,40h,0E6h,40h,50h,40h,40h,50h,70h,0E0h,0F0h,40h	; "Pp@p@@.@P@@Pp..@"
	defb 50h,40h,40h,50h,70h,0E0h,0F0h,40h,50h,06h,40h,00h,83h,40h,0F0h,70h
	defb 06h,40h,82h,0F0h,70h,0Dh,40h,07h,70h,81h,40h,06h,20h,03h,70h,81h
	defb 50h,03h,40h,03h,50h,8Dh,0E0h,50h,40h,0E5h,55h,70h,10h,0D0h,77h,40h
	defb 70h,40h,50h,03h,40h,83h,0F0h,70h,50h,03h,40h,82h,50h,70h,07h,40h
	defb 86h,44h,0A9h,60h,10h,70h,50h,03h,40h,85h,0A0h,60h,10h,70h,50h,05h
	defb 40h,82h,50h,60h,05h,40h,0A7h,90h,40h,80h,40h,60h,40h,40h,50h,94h
	defb 50h,80h,50h,60h,50h,40h,0E0h,50h,55h,0E0h,70h,40h,40h,0E5h,0E0h,50h
	defb 40h,50h,60h,60h,80h,90h,0EEh,00h,60h,66h,86h,98h,0F9h,0F9h,04h,0E0h
	defb 02h,60h,0AAh,80h,90h,75h,70h,00h,00h,40h,50h,70h,0F0h,40h,70h,00h
	defb 40h,40h,50h,70h,0B0h,0EEh,0A5h,40h,40h,50h,70h,85h,94h,0E0h,50h,40h
	defb 50h,40h,40h,50h,70h,0EEh,10h,40h,44h,54h,75h,0F7h,0F7h,04h,0E0h,02h
	defb 40h,87h,50h,70h,0E0h,50h,55h,0E0h,70h,04h,0E0h,87h,50h,40h,50h,40h
	defb 40h,50h,70h,0Ch,0E0h,02h,40h,82h,50h,70h,00h

; ----------------------------------------------------------------------
; DATA graphics_per_stage: Seven compressed blocks in a row (0x86BB, 0x8A8C,
;   0x8C1E, 0x8D27, 0x8E4B, 0x8ECA, 0x8F3E). They are handed out by table
;   0x42B3 of bank 0: two blocks per stage, each with the index of the
;   character where it starts.
graphics_per_stage:
	defb 86h,00h,80h,0E0h,70h,7Fh,7Fh,03h,0BFh,82h,78h,0E0h,0Ah,00h,83h,88h
	defb 0FFh,0F8h,1Ch,00h,82h,0C0h,70h,0Dh,00h,84h,0B0h,0FCh,7Fh,7Fh,03h,0BFh
	defb 83h,7Fh,78h,0E0h,08h,00h,85h,80h,18h,8Fh,0FCh,0E0h,1Ch,00h,82h,0E0h
	defb 70h,09h,00h,86h,80h,0E0h,70h,0FFh,1Fh,01h,0Dh,00h,83h,80h,0F0h,0FFh
	defb 0Eh,00h,86h,0E0h,0FEh,7Fh,3Fh,1Eh,18h,0Ch,00h,82h,0FCh,0F0h,07h,00h
	defb 87h,03h,07h,02h,00h,30h,70h,20h,19h,00h,83h,0BEh,0BFh,0BEh,1Dh,00h
	defb 87h,20h,60h,0D8h,3Ch,1Eh,0Eh,02h,1Fh,00h,82h,0E0h,70h,08h,00h,90h
	defb 66h,99h,81h,5Ah,5Ah,81h,99h,66h,66h,99h,81h,5Ah,5Ah,81h,99h,66h
	defb 06h,00h,82h,0E0h,70h,08h,00h,90h,18h,66h,42h,99h,99h,42h,66h,18h
	defb 18h,66h,42h,99h,99h,42h,66h,18h,04h,00h,82h,0C0h,70h,0Ah,00h,90h
	defb 66h,99h,81h,5Ah,5Ah,81h,99h,66h,66h,99h,81h,5Ah,5Ah,81h,99h,66h
	defb 04h,00h,82h,0C0h,70h,0Ah,00h,90h,18h,66h,42h,99h,99h,42h,66h,18h
	defb 18h,66h,42h,99h,99h,42h,66h,18h,06h,00h,82h,0E0h,70h,09h,00h,8Eh
	defb 18h,24h,5Ah,5Ah,24h,18h,00h,00h,18h,24h,5Ah,5Ah,24h,18h,07h,00h
	defb 82h,0E0h,70h,09h,00h,8Eh,24h,5Ah,24h,24h,5Ah,24h,00h,00h,24h,5Ah
	defb 24h,24h,5Ah,24h,05h,00h,82h,0C0h,70h,0Bh,00h,8Eh,18h,24h,5Ah,5Ah
	defb 24h,18h,00h,00h,18h,24h,5Ah,5Ah,24h,18h,05h,00h,82h,0C0h,70h,0Bh
	defb 00h,8Eh,24h,5Ah,24h,24h,5Ah,24h,00h,00h,24h,5Ah,24h,24h,5Ah,24h	; "..$Z$$Z$..$Z$$Z$"
	defb 04h,00h,83h,03h,1Fh,7Fh,04h,0FFh,83h,7Fh,1Fh,03h,06h,00h,83h,0C0h
	defb 0F8h,0FEh,04h,0FFh,83h,0FEh,0F8h,0C0h,08h,00h,86h,07h,1Fh,3Fh,3Fh,1Fh
	defb 07h,0Ah,00h,86h,0E0h,0F8h,0FCh,0FCh,0F8h,0E0h,0Bh,00h,83h,01h,1Fh,01h
	defb 0Bh,00h,87h,01h,0Eh,0F0h,00h,0F0h,0Eh,01h,0Ah,00h,85h,01h,0Ch,0C0h
	defb 0Ch,01h,0Bh,00h,85h,80h,30h,03h,30h,80h,0Ch,00h,83h,03h,3Fh,03h
	defb 0Dh,00h,83h,0C0h,0FCh,0C0h,0Dh,00h,83h,07h,3Fh,07h,09h,00h,8Bh,03h
	defb 1Ch,30h,0E0h,80h,00h,80h,0E0h,30h,1Ch,03h,06h,00h,89h,03h,0Eh,18h
	defb 70h,0E0h,70h,18h,0Eh,03h,07h,00h,89h,0C0h,70h,18h,0Eh,07h,0Eh,18h
	defb 70h,0C0h,08h,00h,87h,01h,07h,0Fh,1Fh,0Fh,07h,01h,09h,00h,87h,80h
	defb 0E0h,0F0h,0F8h,0F0h,0E0h,80h,0Ah,00h,85h,01h,02h,78h,02h,01h,09h,00h
	defb 02h,80h,87h,40h,20h,0Fh,20h,40h,80h,80h,0Ah,00h,83h,01h,06h,01h
	defb 0Ch,00h,85h,80h,40h,30h,40h,80h,0Dh,00h,81h,01h,0Eh,00h,83h,80h
	defb 0C0h,80h,0Bh,00h,87h,80h,70h,0Fh,00h,0Fh,70h,80h,0Bh,00h,83h,80h
	defb 0F8h,80h,09h,00h,8Bh,0C0h,38h,0Ch,07h,01h,00h,01h,07h,0Ch,38h,0C0h
	defb 09h,00h,83h,0E0h,0FCh,0E0h,07h,00h,0ADh,80h,09h,00h,05h,35h,0A1h,1Ah
	defb 07h,0ABh,35h,0Bh,35h,14h,63h,00h,10h,10h,80h,02h,00h,30h,52h,0E0h
	defb 0C0h,0C0h,0E0h,0D0h,8Ch,28h,26h,00h,40h,00h,04h,04h,00h,18h,19h,01h
	defb 01h,0Eh,1Fh,2Fh,1Fh,2Eh,05h,00h,8Ch,80h,58h,0FCh,0F4h,0F0h,0F0h,0F6h
	defb 26h,70h,70h,20h,80h,06h,00h,88h,01h,00h,01h,04h,00h,03h,07h,02h
	defb 0Ah,00h,86h,50h,0E0h,40h,10h,40h,40h,0Ah,00h,84h,02h,04h,02h,02h
	defb 0Bh,00h,84h,0C0h,20h,80h,20h,07h,00h,84h,60h,0F0h,0F0h,60h,1Ch,00h
	defb 0A0h,07h,7Fh,0Fh,3Fh,7Fh,0FFh,7Fh,72h,72h,7Fh,0FFh,7Fh,3Fh,1Fh,77h
	defb 07h,80h,0F0h,0F8h,0FCh,80h,00h,54h,55h,55h,54h,00h,80h,0F8h,0F0h,0E0h
	defb 80h,03h,00h,8Bh,03h,1Fh,0F0h,7Fh,0FFh,7Fh,7Fh,3Fh,1Fh,0Fh,78h,05h
	defb 00h,8Ah,0C0h,0F0h,00h,55h,0D5h,0FCh,0FCh,0F8h,0F0h,0E0h,07h,00h,87h,1Fh
	defb 7Fh,0FFh,7Fh,1Fh,00h,0F8h,09h,00h,85h,80h,0C0h,0FDh,0FDh,0F0h,0Ah,00h
	defb 8Bh,07h,0FFh,3Fh,7Fh,0FFh,70h,77h,0FFh,7Fh,1Fh,0FCh,05h,00h,8Ah,0C0h
	defb 0F0h,0F8h,0FCh,80h,55h,55h,0FCh,0F8h,0F0h,03h,00h,0ACh,03h,7Fh,00h,1Fh
	defb 7Fh,0FFh,7Fh,66h,66h,7Fh,0FFh,7Fh,1Fh,00h,7Fh,03h,0C0h,0B0h,78h,0FCh
	defb 84h,00h,54h,55h,55h,54h,00h,84h,0FCh,78h,0B0h,0C0h,03h,07h,0Fh,1Fh
	defb 00h,2Fh,2Fh,0Fh,0Fh,2Fh,2Fh,00h,04h,33h,8Ch,0C0h,0E0h,0F0h,0F8h,00h
	defb 74h,68h,1Ch,1Ch,68h,74h,0C0h,04h,0CCh,8Ch,03h,07h,0Fh,1Fh,00h,2Eh
	defb 16h,38h,38h,16h,2Eh,03h,04h,33h,8Ch,0C0h,0E0h,0F0h,0F8h,00h,0F4h,0F4h
	defb 0F0h,0F0h,0F4h,0F4h,00h,04h,0CCh,8Ch,03h,07h,0Fh,1Fh,00h,17h,57h,0E7h
	defb 0E7h,57h,17h,00h,04h,1Bh,8Ch,0C0h,0E0h,0F0h,0F8h,00h,0E8h,0EAh,0E7h,0E7h
	defb 0EAh,0E8h,00h,04h,0D8h,0B2h,03h,07h,0Fh,1Fh,00h,6Eh,0EDh,0EBh,0EBh,6Dh
	defb 0Eh,03h,63h,73h,73h,63h,0C0h,0E0h,0F0h,0F8h,00h,76h,0B7h,0D7h,0D7h,0B6h
	defb 70h,0C0h,0C6h,0CEh,0CEh,0C6h,00h,0Fh,1Fh,1Fh,7Fh,1Bh,26h,7Eh,7Eh,26h
	defb 1Bh,7Fh,1Fh,0Fh,07h,00h,0F0h,60h,03h,80h,81h,00h,04h,0D0h,0A1h,00h
	defb 80h,80h,00h,60h,0F0h,04h,0Fh,37h,39h,5Fh,0EFh,6Eh,7Dh,79h,3Ch,3Eh
	defb 1Ch,00h,0Eh,07h,00h,00h,80h,0E0h,0F0h,0F4h,76h,26h,82h,0B0h,60h,0C0h
	defb 06h,00h,8Fh,07h,0Eh,00h,1Ch,3Eh,3Ch,79h,7Dh,6Eh,0EFh,5Fh,39h,37h
	defb 0Fh,04h,05h,00h,8Bh,0C0h,60h,0B0h,82h,26h,76h,0F4h,0F0h,0E0h,80h,00h
	defb 00h,05h,00h,82h,0Fh,1Fh,03h,3Fh,82h,1Fh,07h,09h,00h,87h,80h,0E0h
	defb 0B0h,0D8h,0F8h,0F0h,0C0h,06h,00h,0A1h,01h,07h,1Fh,7Fh,00h,01h,03h,07h
	defb 1Fh,0FBh,0FBh,03h,3Fh,00h,7Fh,3Eh,9Eh,8Eh,87h,0C3h,7Fh,83h,3Fh,7Fh
	defb 7Dh,3Ah,84h,0F8h,0FFh,00h,3Fh,0Fh,03h,04h,00h,0B7h,01h,03h,07h,1Fh
	defb 0FBh,0FBh,03h,3Fh,00h,0FFh,0FEh,8Ch,0E4h,32h,1Fh,0FFh,0B3h,39h,7Dh,7Dh
	defb 3Bh,86h,0F8h,0FFh,00h,0FFh,7Fh,1Fh,07h,06h,0Dh,19h,19h,18h,14h,1Fh
	defb 1Fh,39h,71h,0E0h,0C0h,0FCh,0E0h,0F0h,0F8h,18h,0FDh,0EFh,0EEh,0DCh,38h,0F0h
	defb 0E0h,0C0h,80h,03h,00h,8Dh,3Fh,03h,0FBh,0FBh,1Fh,07h,03h,01h,00h,7Fh
	defb 1Fh,07h,01h,03h,00h,98h,0FFh,0F8h,84h,3Ah,7Dh,7Fh,3Fh,83h,7Fh,0C3h
	defb 87h,8Eh,9Eh,3Eh,7Fh,00h,3Fh,03h,0FBh,0FBh,1Fh,07h,03h,01h,04h,00h
	defb 0D1h,03h,0Fh,3Fh,00h,0FFh,0F8h,86h,3Bh,7Dh,7Dh,39h,0B3h,0FFh,1Fh,32h
	defb 0E4h,8Ch,0FEh,0FFh,0C0h,0E0h,71h,39h,1Fh,1Fh,14h,18h,19h,19h,0Dh,06h
	defb 07h,1Fh,7Fh,0FFh,00h,00h,80h,0C0h,0E0h,0F0h,38h,0DCh,0EEh,0EFh,0FDh,18h
	defb 0F8h,0F0h,0E0h,0FCh,00h,0FFh,1Fh,21h,5Ch,0BEh,0FEh,0FCh,0C1h,0FEh,0C3h,0E1h
	defb 71h,79h,7Ch,0FEh,00h,0FCh,0C0h,0DFh,0DFh,0F8h,0E0h,0C0h,80h,00h,0FEh,0F8h
	defb 0E0h,80h,03h,00h,98h,0FFh,1Fh,61h,0DCh,0BEh,0BEh,9Ch,0CDh,0FFh,0F8h,4Ch
	defb 27h,31h,7Fh,0FFh,00h,0FCh,0C0h,0DFh,0DFh,0F8h,0E0h,0C0h,80h,04h,00h,0B2h
	defb 0C0h,0F0h,0FCh,00h,00h,01h,03h,07h,0Fh,1Ch,3Bh,77h,0F7h,0BFh,18h,1Fh
	defb 0Fh,07h,3Fh,03h,07h,8Eh,9Ch,0F8h,0F8h,28h,18h,98h,98h,0B0h,60h,0E0h
	defb 0F8h,0FEh,0FFh,0FEh,7Ch,79h,71h,0E1h,0C3h,0FEh,0C1h,0FCh,0FEh,0BEh,5Ch,21h
	defb 1Fh,0FFh,03h,00h,0A1h,80h,0E0h,0F8h,0FEh,00h,80h,0C0h,0E0h,0F8h,0DFh,0DFh
	defb 0C0h,0FCh,00h,0FFh,7Fh,31h,27h,4Ch,0F8h,0FFh,0CDh,9Ch,0BEh,0BEh,0DCh,61h
	defb 1Fh,0FFh,00h,0FCh,0F0h,0C0h,04h,00h,0A9h,80h,0C0h,0E0h,0F8h,0DFh,0DFh,0C0h
	defb 0FCh,00h,3Fh,07h,0Fh,1Fh,18h,0BFh,0F7h,77h,3Bh,1Ch,0Fh,07h,03h,01h
	defb 00h,00h,0FFh,0FEh,0F8h,0E0h,60h,0B0h,98h,98h,18h,28h,0F8h,0F8h,9Ch,8Eh
	defb 07h,03h,00h,0FFh,00h,01h,0Dh,1Ch,37h,64h,49h,7Bh,7Bh,49h,64h,37h
	defb 1Ch,0Dh,01h,00h,00h,0C0h,0F0h,38h,0C0h,0Ch,9Eh,0DEh,0DEh,9Eh,0Ch,0C0h
	defb 38h,0F0h,0C0h,00h,00h,03h,07h,17h,33h,30h,69h,6Bh,6Bh,09h,3Ch,33h
	defb 19h,0Dh,07h,00h,00h,0C0h,0E0h,0E8h,0CCh,0Ch,96h,0D6h,0D6h,90h,3Ch,0CCh
	defb 98h,0B0h,0E0h,00h,00h,03h,0Fh,1Ch,03h,30h,79h,7Bh,7Bh,79h,30h,03h
	defb 1Ch,0Fh,03h,00h,00h,80h,0B0h,38h,0ECh,26h,92h,0DEh,0DEh,92h,26h,0ECh
	defb 38h,0B0h,80h,00h,00h,07h,0Dh,19h,33h,3Ch,09h,6Bh,6Bh,69h,30h,33h
	defb 17h,07h,03h,00h,00h,0E0h,0B0h,98h,0CCh,3Ch,90h,0D6h,0D6h,96h,0Ch,0CCh
	defb 0E8h,0E0h,0C0h,04h,00h,8Bh,03h,1Fh,0F0h,7Fh,0FFh,7Fh,7Fh,3Fh,1Fh,0Fh
	defb 78h,05h,00h,8Ah,0C0h,0F0h,00h,55h,0D5h,0FCh,0FCh,0F8h,0F0h,0E0h,07h,00h
	defb 87h,1Fh,7Fh,0FFh,7Fh,1Fh,00h,0F8h,09h,00h,85h,80h,0C0h,0FDh,0FDh,0F0h
	defb 0Ah,00h,8Bh,07h,0FFh,3Fh,7Fh,0FFh,70h,77h,0FFh,7Fh,1Fh,0FCh,05h,00h
	defb 8Ah,0C0h,0F0h,0F8h,0FCh,80h,55h,55h,0FCh,0F8h,0F0h,03h,00h,0AEh,03h,7Fh
	defb 00h,1Fh,7Fh,0FFh,7Fh,66h,66h,7Fh,0FFh,7Fh,1Fh,00h,7Fh,03h,0C0h,0B0h
	defb 78h,0FCh,84h,00h,54h,55h,55h,54h,00h,84h,0FCh,78h,0B0h,0C0h,00h,00h
	defb 0Fh,3Fh,79h,60h,0E0h,0C0h,0C0h,0E0h,60h,79h,3Fh,0Fh,05h,00h,8Ah,0C0h
	defb 0E0h,60h,70h,30h,30h,70h,60h,0E0h,0C0h,03h,00h,00h,0FFh,00h,03h,06h
	defb 1Eh,33h,21h,71h,51h,5Bh,4Ah,7Eh,27h,34h,1Dh,07h,00h,00h,80h,0E0h
	defb 3Ch,74h,0CEh,1Ah,92h,93h,0D9h,4Bh,0EEh,0BCh,88h,98h,0F0h,00h,03h,06h
	defb 06h,1Eh,29h,32h,35h,35h,1Ah,19h,18h,17h,1Fh,0Ch,00h,00h,80h,0F8h
	defb 7Ch,26h,0C2h,26h,0D6h,0D3h,21h,0C7h,0Fh,0CEh,0ECh,0F8h,70h,00h,01h,03h
	defb 03h,06h,1Dh,3Ah,35h,35h,1Ah,19h,1Eh,1Fh,1Fh,0Fh,00h,00h,80h,0C8h
	defb 7Ch,2Eh,0C6h,26h,0D3h,0D1h,27h,0DFh,3Eh,0BCh,0B8h,0F8h,0F0h,00h,03h,07h
	defb 04h,0Ch,3Dh,72h,65h,35h,32h,31h,30h,61h,67h,7Fh,38h,00h,18h,0ACh
	defb 0CCh,0Ch,0CCh,2Ch,0D4h,0D6h,22h,0DEh,3Ch,78h,70h,0B0h,0FFh,0E0h,03h,06h
	defb 66h,0D6h,0DEh,0EDh,72h,35h,15h,1Ah,11h,36h,6Fh,0DFh,0FCh,70h,0Eh,97h
	defb 0A7h,0EEh,9Ch,0D8h,28h,0D8h,0D6h,21h,0CDh,3Fh,3Eh,0D0h,0F0h,60h,03h,1Bh
	defb 3Bh,71h,64h,6Ch,10h,69h,0E5h,0C4h,0C9h,0D2h,64h,0Ch,0Fh,07h,0E0h,0F0h
	defb 30h,26h,63h,9Bh,23h,0A7h,96h,28h,0B6h,66h,5Eh,0DCh,0D8h,0C0h,00h,39h
	defb 7Ch,4Ch,39h,41h,10h,09h,61h,0C4h,0C8h,0F1h,62h,04h,06h,07h,0E0h,60h
	defb 28h,66h,4Fh,83h,13h,96h,0A0h,08h,42h,3Ch,32h,0BEh,9Ch,00h,01h,02h
	defb 31h,40h,50h,00h,08h,01h,41h,0A0h,0C4h,60h,00h,05h,06h,07h,0E0h,60h
	defb 0A0h,00h,06h,03h,25h,82h,80h,00h,00h,4Ah,02h,8Ch,0A2h,40h,80h,01h
	defb 00h,00h,60h,40h,00h,00h,21h,01h,00h,40h,60h,01h,00h,02h,03h,0C0h
	defb 40h,00h,80h,06h,02h,00h,80h,88h,00h,00h,02h,06h,00h,00h,80h,00h
	defb 02h,00h,8Ch,01h,05h,0Dh,1Ch,00h,38h,38h,00h,1Ch,0Dh,05h,01h,04h
	defb 00h,8Ch,80h,0A0h,0B0h,38h,00h,1Ch,1Ch,00h,38h,0B0h,0A0h,80h,04h,00h
	defb 8Ch,01h,05h,0Dh,1Dh,01h,3Fh,3Fh,01h,1Dh,0Dh,05h,01h,04h,00h,8Ch
	defb 80h,0A0h,0B0h,0B8h,80h,0FCh,0FCh,80h,0B8h,0B0h,0A0h,80h,03h,00h,0BFh,02h
	defb 1Ah,3Bh,3Ah,03h,7Fh,17h,17h,7Fh,03h,3Ah,3Bh,1Ah,02h,00h,00h,40h
	defb 58h,0DCh,5Ch,0C0h,0FEh,0E8h,0E8h,0FEh,0C0h,5Ch,0DCh,58h,40h,00h,04h,35h
	defb 74h,77h,04h,0FDh,13h,57h,57h,13h,0FDh,04h,77h,74h,35h,04h,20h,0ACh
	defb 2Eh,0EEh,20h,0BFh,0C8h,0EAh,0EAh,0C8h,0BFh,20h,0EEh,2Eh,0ACh,20h,00h,02h
	defb 00h,84h,18h,34h,28h,16h,04h,6Ah,84h,16h,28h,34h,18h,04h,00h,8Ch
	defb 18h,34h,28h,16h,6Ah,68h,6Ah,6Ah,16h,28h,34h,18h,04h,00h,84h,0Ch
	defb 1Eh,1Ch,07h,04h,1Dh,84h,07h,1Ch,1Eh,0Ch,04h,00h,84h,30h,78h,38h
	defb 0D0h,04h,0A8h,84h,0D0h,38h,78h,30h,04h,00h,84h,0Eh,1Eh,1Eh,13h,04h
	defb 0Dh,84h,13h,1Eh,1Eh,0Eh,04h,00h,84h,60h,0F0h,30h,0D0h,04h,0A0h,84h
	defb 0D0h,30h,0F0h,60h,04h,00h,84h,01h,03h,03h,06h,04h,05h,84h,06h,03h
	defb 03h,01h,04h,00h,84h,80h,0C0h,0C0h,60h,04h,0A0h,86h,60h,0C0h,0C0h,80h
	defb 00h,00h,00h,83h,00h,4Ah,0CAh,03h,4Ah,81h,44h,0Ah,00h,86h,0C0h,0A0h
	defb 0A0h,0C0h,80h,80h,09h,00h,82h,02h,06h,05h,02h,0Ah,00h,81h,6Ch,04h
	defb 92h,81h,6Ch,09h,00h,87h,0Ch,12h,02h,04h,08h,10h,1Eh,0Ah,00h,81h
	defb 6Ch,04h,92h,81h,6Ch,09h,00h,87h,1Eh,10h,1Ch,02h,02h,12h,0Ch,0Ah
	defb 00h,81h,6Ch,04h,92h,81h,6Ch,09h,00h,82h,10h,33h,04h,14h,81h,13h
	defb 0Ah,00h,81h,6Ch,04h,92h,81h,6Ch,09h,00h,87h,30h,49h,0Ah,12h,22h
	defb 42h,79h,0Ah,00h,81h,0B6h,04h,49h,81h,0B6h,09h,00h,87h,78h,41h,72h
	defb 4Ah,0Ah,4Ah,31h,0Ah,00h,81h,0B6h,04h,49h,81h,0B6h,09h,00h,82h,40h
	defb 0CDh,04h,52h,81h,4Dh,0Ah,00h,81h,0B6h,04h,49h,81h,0B6h,09h,00h,00h

; ----------------------------------------------------------------------
; DATA graphics_1D00: Two blocks: 0x8FCB, which 0x4287 dumps into VRAM 0x1D00,
;   and 0x9038, which table 0x42B3 asks for for stage 5.
graphics_1D00:
	defb 87h,0Ch,3Bh,76h,85h,05h,02h,01h,08h,00h,90h,01h,0F0h,18h,0ECh,0F4h
	defb 0F8h,78h,0BCh,5Ch,1Ch,1Ch,18h,38h,30h,60h,0C0h,08h,00h,97h,80h,40h
	defb 60h,38h,1Fh,0Fh,03h,00h,00h,08h,04h,06h,06h,03h,1Dh,26h,5Ah,5Dh
	defb 0BDh,7Dh,0FBh,0F6h,0CCh,03h,00h,90h,03h,06h,0Ch,1Ch,18h,38h,38h,3Ah
	defb 3Dh,1Eh,1Fh,2Fh,37h,18h,0Fh,80h,08h,00h,9Fh,80h,40h,0A0h,0A1h,6Eh
	defb 0DCh,30h,00h,00h,33h,6Fh,0DFh,0BEh,0BDh,0BAh,5Ah,64h,0B8h,0C0h,60h,60h
	defb 20h,10h,00h,00h,0C0h,0F0h,0F8h,1Ch,06h,02h,08h,00h,00h,03h,00h,89h
	defb 05h,0Bh,06h,0Ch,31h,0Ch,06h,0Bh,05h,05h,00h,02h,80h,8Bh,50h,68h
	defb 30h,98h,0C6h,98h,30h,68h,50h,80h,80h,03h,00h,0FFh,07h,1Fh,3Ah,3Fh
	defb 6Ch,79h,6Bh,7Ah,59h,7Ch,3Fh,58h,64h,33h,88h,00h,0E0h,0F8h,0BCh,0ECh
	defb 3Eh,96h,5Eh,0D6h,9Eh,3Ah,0FCh,1Ah,26h,0CCh,11h,00h,01h,0Eh,3Dh,77h
	defb 7Fh,0D8h,0F3h,0D6h,0F5h,0D3h,0F8h,6Fh,7Ah,3Fh,0Fh,60h,90h,60h,80h,0F0h
	defb 88h,44h,24h,0B4h,0BCh,3Dh,79h,0F5h,0ADh,0E8h,0C0h,06h,09h,06h,01h,0Fh
	defb 11h,22h,24h,2Dh,3Dh,5Ch,4Eh,57h,5Ah,0Bh,03h,00h,80h,70h,0FCh,0DEh
	defb 0F6h,1Fh,0CBh,0AFh,6Bh,0CFh,1Bh,0F6h,0AEh,0FCh,0F0h,00h,00h,07h,1Fh,3Ah
	defb 3Fh,6Ch,79h,6Ah,7Bh,59h,7Ch,3Fh,58h,64h,33h,00h,00h,0E0h,0F8h,0BCh
	defb 0ECh,3Eh,96h,0DEh,56h,9Eh,3Ah,0FCh,1Ah,26h,0CCh,0FFh,00h,07h,1Eh,3Bh
	defb 3Fh,6Ch,79h,6Ah,7Bh,69h,7Ch,37h,3Dh,1Fh,07h,00h,0C8h,30h,0C0h,0F8h
	defb 0C4h,22h,92h,0DAh,5Eh,9Eh,3Ch,0FAh,56h,0F4h,0E0h,00h,13h,0Ch,03h,1Fh
	defb 23h,44h,49h,5Ah,7Bh,0B9h,9Ch,0AFh,0B5h,17h,07h,00h,00h,0E0h,0F8h,0BCh
	defb 0ECh,3Eh,96h,0DEh,56h,9Eh,36h,0ECh,5Ch,0F8h,0E0h,00h,00h,07h,1Fh,3Ah
	defb 3Fh,6Ch,79h,6Ah,7Bh,69h,7Ch,37h,3Dh,1Fh,07h,00h,00h,0E0h,0F8h,0BCh
	defb 0ECh,3Eh,96h,0DEh,56h,9Eh,36h,0ECh,5Ch,0F8h,0E0h,00h,07h,1Fh,24h,4Bh
	defb 57h,0ECh,0D9h,0DBh,0DAh,0D9h,0ECh,57h,4Bh,24h,1Fh,07h,0E0h,0F8h,24h,0D2h
	defb 0EAh,37h,9Bh,5Bh,0DBh,9Bh,37h,0EAh,0D2h,24h,0F8h,9Bh,0E0h,00h,00h,03h
	defb 07h,0Fh,1Ch,38h,70h,61h,0C3h,83h,86h,84h,04h,00h,00h,0E0h,70h,0B0h
	defb 0AEh,07h,3Bh,7Ah,0F0h,0C0h,80h,06h,00h,0CAh,01h,03h,02h,01h,03h,07h
	defb 07h,0Eh,0Ch,1Ch,18h,30h,30h,21h,21h,01h,80h,0D8h,0BCh,0Ch,94h,0B8h
	defb 78h,70h,70h,0E0h,0E0h,0C0h,0C0h,80h,80h,00h,01h,1Bh,3Dh,30h,29h,1Dh
	defb 1Eh,0Eh,0Eh,07h,07h,03h,03h,01h,01h,00h,80h,0C0h,40h,80h,0C0h,0E0h
	defb 0E0h,70h,30h,38h,18h,0Ch,0Ch,84h,84h,80h,07h,0Eh,0Dh,75h,0E0h,0DCh
	defb 5Eh,0Fh,03h,01h,08h,00h,8Eh,0C0h,0E0h,0F0h,38h,1Ch,0Eh,86h,0C3h,0C1h
	defb 61h,21h,20h,00h,00h,00h

; ----------------------------------------------------------------------
; DATA object_shapes: Four bytes per shape: the object's two top characters
;   and its two bottom ones. 0x48CB reads them indexing with (IX+0x0C)*4, and
;   writes them to the name table 0x1E apart.
object_shapes:
	defb 0E6h,0E7h,0E8h,0E9h
	defb 0EAh,0EBh,0ECh,0EDh
	defb 0EEh,0EFh,0F0h,0F1h
	defb 0F2h,0F3h,0F4h,0F5h
	defb 0D2h,0D3h,0D4h,0D5h
	defb 0D6h,0D7h,0D8h,0D9h
	defb 0DAh,0DBh,0DCh,0DDh
	defb 0DEh,0DFh,0E0h,0E1h
	defb 0E2h,0E3h,0E4h,0E5h
	defb 0BAh,0BBh,0BEh,0BFh
	defb 0BCh,0BBh,0BEh,0BFh
	defb 0BDh,0BBh,0BEh,0BFh
	defb 0C1h,0C2h,0C5h,0C4h
	defb 0C1h,0C2h,0C5h,0C4h
	defb 0C1h,0C0h,0C5h,0C4h
	defb 0C6h,0C7h,0CAh,0CBh
	defb 0C8h,0C7h,0CAh,0CBh
	defb 0C9h,0C7h,0CAh,0CBh
	defb 0CDh,0CFh,0D1h,0D0h
	defb 0CDh,0CEh,0D1h,0D0h
	defb 0CDh,0CCh,0D1h,0D0h
	defb 12h,13h,0Eh,0Fh
	defb 12h,13h,10h,0Fh
	defb 12h,13h,11h,0Fh
	defb 19h,18h,15h,17h
	defb 19h,18h,15h,16h
	defb 19h,18h,15h,14h
	defb 0CAh,0CBh,0C6h,0C7h
	defb 0CAh,0CBh,0C8h,0C7h
	defb 0CAh,0CBh,0C9h,0C7h
	defb 0D1h,0D0h,0CDh,0CFh
	defb 0D1h,0D0h,0CDh,0CEh
	defb 0D1h,0D0h,0CDh,0CCh
	defb 7Bh,7Ch,7Dh,7Eh
	defb 77h,78h,79h,7Ah
	defb 02h,03h,06h,07h
	defb 04h,03h,06h,07h
	defb 05h,03h,06h,07h
	defb 09h,0Bh,0Dh,0Ch
	defb 09h,0Ah,0Dh,0Ch
	defb 09h,08h,0Dh,0Ch
	defb 0ECh,0EEh,0EDh,0EFh
	defb 0ECh,0F0h,0EDh,0F1h
	defb 0ECh,0F2h,0EDh,0F3h
	defb 0ECh,0F4h,0EDh,0F5h
	defb 3Ch,3Dh,38h,39h
	defb 3Ch,3Dh,3Ah,39h
	defb 3Ch,3Dh,3Bh,39h
	defb 43h,42h,3Fh,41h
	defb 43h,42h,3Fh,40h
	defb 43h,42h,3Fh,3Eh
	defb 4Bh,4Ch,0ABh,00h
	defb 0A6h,00h,46h,45h
	defb 4Bh,4Ch,0B0h,00h
	defb 00h,0ABh,46h,45h
	defb 80h,81h,82h,83h
	defb 84h,85h,86h,87h
	defb 1Bh,1Ch,17h,18h
	defb 1Bh,1Ch,19h,18h
	defb 1Bh,1Ch,1Ah,18h
	defb 22h,21h,1Eh,20h
	defb 22h,21h,1Eh,1Fh
	defb 22h,21h,1Eh,1Dh
	defb 0C6h,0C7h,0CAh,0CBh
	defb 0C8h,0C7h,0CAh,0CBh
	defb 0C9h,0C7h,0CAh,0CBh
	defb 0CDh,0CFh,0D1h,0D0h
	defb 0CDh,0CEh,0D1h,0D0h
	defb 0CDh,0CCh

; ----------------------------------------------------------------------
; DATA record_lists_A: Twelve words, one per stage: where that stage's list of
;   0x4371 records starts. Read by 0x4306 with 0x47AE (DE = word at HL+2*A).
record_lists_A:
	defw 0D0D1h,93A8h	; -> 0xd0d1 DATA_records_per_stage
	defw 9403h,9434h
	defw 9477h,94D8h
	defw 9527h,9546h
	defw 95BFh,961Ah
	defw 963Fh,9664h

; ----------------------------------------------------------------------
; DATA record_lists_B: Twelve words, one per stage. Read by 0x4316.
record_lists_B:
	defw 9689h,96AEh
	defw 96C7h,96ECh
	defw 96F9h,9712h
	defw 972Fh,9733h
	defw 9750h,9779h
	defw 9779h,9779h

; ----------------------------------------------------------------------
; DATA record_lists_C: Thirteen words, one per stage. Read by 0x4320.
record_lists_C:
	defw 9779h,9782h
	defw 979Fh,97B4h
	defw 97C9h,97FEh
	defw 9837h,9838h
	defw 9865h,988Eh
	defw 988Eh,988Eh
	defw 988Eh

; ----------------------------------------------------------------------
; DATA common_records: Sixteen six-byte records and the 0x00 that ends them.
;   Loaded by 0x42FC in every stage.
common_records:
	defb 07h,76h,67h,0E6h,80h,7Ah
	defb 07h,0D5h,66h,0D2h,17h,7Ah
	defb 01h,0C6h,64h,63h,39h,78h
	defb 01h,0C6h,64h,6Dh,58h,78h
	defb 01h,0Fh,65h,7Fh,0BBh,78h
	defb 01h,0Fh,65h,81h,0C0h,78h
	defb 07h,0ECh,67h,0F6h,0BBh,7Ah
	defb 07h,0EFh,67h,0F8h,0C0h,7Ah
	defb 07h,0FEh,67h,0FCh,0C3h,7Ah
	defb 07h,0EDh,64h,77h,77h,78h
	defb 07h,0EDh,64h,7Bh,99h,78h
	defb 01h,79h,63h,0Bh,93h,77h
	defb 01h,0C7h,62h,15h,74h,76h
	defb 01h,0C7h,62h,2Ch,03h,77h
	defb 07h,16h,65h,83h,0C5h,78h
	defb 01h,81h,62h,0Ch,57h,76h
	defb 00h

; ----------------------------------------------------------------------
; DATA extra_records_1: Two six-byte records and their 0x00. Loaded by 0x432B,
;   and only when 0xF0F4 is not zero.
extra_records_1:
	defb 07h,0B9h,98h,77h,0FDh,98h
	defb 07h,0B9h,98h,7Bh,0DBh,98h
	defb 00h

; ----------------------------------------------------------------------
; DATA extra_records_2: Two six-byte records and their 0x00. Loaded by 0x4337,
;   and only from stage 9 onwards.
extra_records_2:
	defb 07h,0B9h,98h,80h,1Fh,99h
	defb 07h,0B9h,98h,84h,41h,99h
	defb 00h

; ----------------------------------------------------------------------
; DATA records_per_stage: The record lists that the three tables above point
;   to, one after another: 0x93A8, 0x9403, 0x9434, 0x9477, 0x94D8, 0x9527,
;   0x9546, 0x95BF, 0x961A, 0x963F, 0x9664, 0x9689, 0x96AE, 0x96C7, 0x96EC,
;   0x96F9, 0x9712, 0x972F, 0x9733, 0x9750, 0x9779, 0x9782, 0x979F, 0x97B4,
;   0x97C9, 0x97FE, 0x9837, 0x9838, 0x9865 and 0x988E.
records_per_stage:
	defb 04h,8Bh,62h,62h,61h,76h
	defb 04h,95h,62h,0A1h,68h,76h
	defb 04h,0ADh,62h,0A9h,6Fh,76h
	defb 01h,53h,62h,43h,29h,76h
	defb 03h,83h,63h,44h,0DBh,77h
	defb 03h,01h,66h,0A1h,85h,79h
	defb 01h,0D4h,63h,4Eh,0FEh,77h
	defb 01h,0A4h,64h,5Fh,29h,78h
	defb 01h,0A8h,66h,0BAh,0C3h,79h
	defb 01h,0A8h,66h,0C6h,0EBh,79h
	defb 01h,67h,66h,0B2h,0A9h,79h
	defb 01h,3Dh,66h,0AAh,90h,79h
	defb 02h,71h,64h,5Ah,0A8h,77h
	defb 02h,5Fh,64h,58h,96h,77h
	defb 02h,6Fh,62h,68h,45h,76h
	defb 00h,07h,0Dh,68h,44h,0C6h
	defb 7Ah,07h,6Fh,68h,0A1h,9Bh
	defb 7Ch,07h,0A8h,66h,0BAh,0EBh
	defb 79h,06h,0A8h,66h,02h,0C3h
	defb 79h,07h,0C6h,64h,63h,39h
	defb 78h,07h,0C6h,64h,6Dh,58h
	defb 78h,07h,0Fh,65h,7Fh,0BBh
	defb 78h,07h,0Fh,65h,81h,0C0h
	defb 78h,00h,07h,97h,68h,44h
	defb 0DFh,7Dh,07h,00h,69h,5Eh
	defb 18h,7Eh,07h,4Ah,69h,67h
	defb 4Dh,7Eh,07h,0A1h,69h,72h
	defb 8Ah,7Eh,07h,0CAh,69h,0A1h
	defb 8Ah,7Eh,07h,0F4h,69h,0A6h
	defb 8Dh,7Eh,07h,46h,6Ah,0D2h
	defb 0D1h,7Eh,07h,0A8h,66h,0C6h
	defb 0C3h,79h,07h,76h,67h,0E6h
	defb 80h,7Ah,07h,94h,6Ah,0DCh
	defb 0F8h,7Eh,07h,0A8h,6Ah,0DFh
	defb 0FDh,7Eh,00h,07h,76h,67h
	defb 0E6h,80h,7Ah,07h,0D5h,66h
	defb 0D2h,17h,7Ah,01h,8Bh,62h
	defb 62h,61h,76h,01h,95h,62h
	defb 0A1h,68h,76h,01h,0ADh,62h
	defb 0A9h,6Fh,76h,06h,83h,63h
	defb 44h,0DBh,77h,06h,01h,66h
	defb 0A1h,85h,79h,04h,0D4h,63h
	defb 4Eh,0FEh,77h,04h,0A4h,64h
	defb 5Fh,29h,78h,01h,0A8h,66h
	defb 0C6h,0EBh,79h,04h,67h,66h
	defb 0B2h,0A9h,79h,04h,3Dh,66h
	defb 0AAh,90h,79h,07h,0D4h,6Ah
	defb 0BAh,0A2h,7Ch,02h,71h,64h
	defb 5Ah,0A8h,77h,02h,5Fh,64h
	defb 58h,96h,77h,02h,6Fh,62h
	defb 68h,45h,76h,00h,06h,00h
	defb 60h,02h,0D6h,73h,01h,0A8h
	defb 66h,0C6h,0C3h,79h,07h,56h
	defb 60h,44h,2Ch,74h,07h,2Bh
	defb 60h,5Ah,01h,74h,01h,39h
	defb 61h,73h,0Fh,75h,01h,0Eh
	defb 61h,64h,0E4h,74h,01h,5Bh
	defb 61h,80h,31h,75h,07h,0BCh
	defb 61h,0A1h,92h,75h,07h,0AAh
	defb 60h,4Eh,80h,74h,07h,39h
	defb 62h,0B2h,0Fh,76h,07h,0B2h
	defb 61h,0B8h,88h,75h,06h,0A0h
	defb 61h,0BCh,76h,75h,01h,75h
	defb 61h,0BEh,4Bh,75h,00h,07h
	defb 36h,6Bh,44h,0F0h,7Ch,07h
	defb 36h,6Bh,51h,1Ch,7Dh,07h
	defb 93h,6Bh,5Eh,45h,7Dh,07h
	defb 03h,6Ch,0A1h,8Ch,7Dh,07h
	defb 12h,73h,0ECh,24h,83h,00h
	defb 01h,0Eh,6Fh,44h,00h,81h
	defb 01h,0AFh,6Fh,58h,73h,81h
	defb 07h,0E2h,6Ch,61h,6Eh,7Fh
	defb 03h,0E9h,72h,63h,0D6h,82h
	defb 03h,0DCh,72h,7Fh,0C2h,82h
	defb 03h,0E9h,72h,6Dh,0FDh,82h
	defb 03h,0DCh,72h,81h,0CBh,82h
	defb 01h,0F9h,6Fh,0A1h,0B9h,81h
	defb 04h,0F4h,6Ch,0A9h,80h,7Fh
	defb 03h,0A8h,66h,0BAh,0C3h,79h
	defb 01h,0A8h,66h,0C6h,0EBh,79h
	defb 02h,0FCh,6Eh,57h,0F0h,80h
	defb 02h,16h,6Dh,01h,9Ch,7Fh
	defb 02h,38h,6Dh,05h,0B7h,7Fh
	defb 02h,6Ch,6Dh,0Ch,0D7h,7Fh
	defb 02h,9Bh,6Dh,12h,0FBh,7Fh
	defb 02h,0EAh,6Eh,3Eh,0DEh,80h
	defb 02h,0EAh,6Eh,40h,0CCh,80h
	defb 02h,5Dh,62h,5Fh,33h,76h
	defb 04h,8Ah,6Ch,12h,19h,7Fh
	defb 00h,07h,0DCh,71h,44h,40h
	defb 82h,07h,09h,72h,50h,61h
	defb 82h,01h,8Eh,72h,0A1h,0B5h
	defb 82h,01h,0B6h,72h,0A6h,0B8h
	defb 82h,02h,0B6h,72h,0ACh,0B8h
	defb 82h,03h,0A8h,66h,0BAh,0C3h
	defb 79h,03h,0A8h,66h,0C6h,0EBh
	defb 79h,06h,37h,70h,01h,0F1h
	defb 81h,02h,76h,72h,0A6h,0B2h
	defb 82h,03h,5Ah,73h,64h,0A7h
	defb 83h,04h,5Ah,73h,24h,0A7h
	defb 83h,04h,0C6h,64h,63h,39h
	defb 78h,04h,0C6h,64h,6Dh,58h
	defb 78h,04h,0Fh,65h,7Fh,0BBh
	defb 78h,04h,0Fh,65h,81h,0C0h
	defb 78h,00h,07h,0Dh,68h,44h
	defb 0Bh,7Bh,07h,6Fh,68h,0A1h
	defb 9Bh,7Ch,07h,0A8h,66h,0BAh
	defb 0EBh,79h,06h,0A8h,66h,02h
	defb 0C3h,79h,07h,0EDh,64h,80h
	defb 85h,83h,07h,0EDh,64h,84h
	defb 63h,83h,00h,07h,0Dh,68h
	defb 44h,6Fh,7Bh,07h,6Fh,68h
	defb 0A1h,9Bh,7Ch,07h,0A8h,66h
	defb 0BAh,0EBh,79h,06h,0A8h,66h
	defb 02h,0C3h,79h,07h,0EDh,64h
	defb 80h,85h,83h,07h,0EDh,64h
	defb 84h,63h,83h,00h,07h,0Dh
	defb 68h,44h,0D3h,7Bh,07h,6Fh
	defb 68h,0A1h,9Bh,7Ch,07h,0A8h
	defb 66h,0BAh,0EBh,79h,06h,0A8h
	defb 66h,02h,0C3h,79h,07h,0EDh
	defb 64h,80h,85h,83h,07h,0EDh
	defb 64h,84h,63h,83h,00h,07h
	defb 0Dh,68h,44h,37h,7Ch,07h
	defb 6Fh,68h,0A1h,9Bh,7Ch,07h
	defb 0A8h,66h,0BAh,0EBh,79h,06h
	defb 0A8h,66h,02h,0C3h,79h,07h
	defb 0EDh,64h,80h,85h,83h,07h
	defb 0EDh,64h,84h,63h,83h,00h
	defb 63h,68h,29h,05h,6Dh,72h
	defb 39h,05h,0BAh,0C0h,39h,06h
	defb 0C6h,0CCh,39h,06h,7Fh,80h
	defb 39h,01h,81h,82h,39h,01h
	defb 00h,63h,68h,39h,05h,68h
	defb 63h,36h,05h,6Dh,72h,39h
	defb 05h,72h,6Dh,36h,05h,7Fh
	defb 80h,39h,01h,81h,82h,39h
	defb 01h,0BAh,0C0h,3Fh,06h,02h
	defb 08h,36h,06h,80h,7Fh,26h
	defb 01h,00h,44h,51h,3Fh,0Dh
	defb 0D2h,0BCh,3Fh,0Ah,0C6h,0CCh
	defb 3Fh,06h,00h,63h,68h,29h
	defb 05h,6Dh,72h,39h,05h,0C6h
	defb 0CCh,39h,06h,7Fh,80h,39h
	defb 01h,81h,82h,39h,01h,0A3h
	defb 43h,09h,01h,00h,44h,2Eh
	defb 37h,0Ah,5Ah,5Fh,3Fh,05h
	defb 02h,07h,36h,05h,0A1h,0D2h
	defb 3Fh,0Fh,0BCh,0BEh,36h,02h
	defb 0C6h,0CCh,09h,06h,0B2h,0B5h
	defb 3Fh,03h,00h,00h,00h,00h
	defb 00h,63h,68h,3Bh,05h,6Dh
	defb 72h,3Bh,05h,0BAh,0C0h,39h
	defb 06h,0C6h,0CCh,39h,06h,7Fh
	defb 80h,39h,01h,81h,82h,39h
	defb 01h,13h,1Dh,24h,0Ah,00h
	defb 63h,68h,24h,05h,6Dh,72h
	defb 24h,05h,7Fh,80h,24h,01h
	defb 81h,82h,24h,01h,0A6h,0ABh
	defb 09h,05h,0ACh,0B1h,12h,05h
	defb 0A1h,0A1h,21h,05h,0A6h,0A9h
	defb 12h,03h,0BAh,0C0h,19h,06h
	defb 0C6h,0CCh,19h,06h,00h,0BAh
	defb 0C0h,3Fh,06h,02h,08h,36h
	defb 06h,00h,44h,4Eh,12h,0Ah
	defb 0A1h,0ABh,32h,0Ah,5Fh,0A5h
	defb 21h,04h,63h,63h,21h,14h
	defb 0C6h,0C6h,21h,0Ch,7Fh,7Fh
	defb 21h,04h,58h,60h,12h,08h
	defb 00h,63h,50h,39h,13h,63h
	defb 20h,31h,14h,7Fh,0A6h,39h
	defb 04h,0BAh,0C6h,39h,0Ch,02h
	defb 0Eh,36h,0Ch,00h,0A6h,0B2h
	defb 3Fh,0Ah,0C6h,0Eh,36h,0Ch
	defb 0DCh,1Ah,36h,0Ah,5Eh,26h
	defb 36h,19h,0A1h,3Fh,36h,05h
	defb 00h,44h,4Eh,12h,0Ah,0A2h
	defb 0ACh,12h,08h,63h,63h,21h
	defb 14h,0C6h,0C6h,21h,0Ch,7Fh
	defb 7Fh,21h,04h,0A1h,0A1h,09h
	defb 0Bh,44h,44h,24h,1Fh,0A1h
	defb 0A1h,24h,19h,5Fh,5Fh,0Ch
	defb 04h,0A2h,0ABh,0Ch,01h,0A4h
	defb 44h,09h,01h,43h,43h,09h
	defb 01h,58h,60h,12h,08h,00h
	defb 5Fh,0Dh,37h,05h,5Ah,64h
	defb 36h,05h,44h,24h,36h,0Ah
	defb 2Eh,69h,3Eh,0Ah,02h,38h
	defb 36h,0Ah,73h,73h,21h,04h
	defb 80h,80h,21h,03h,0A1h,0C1h
	defb 31h,0Fh,0D2h,0D2h,3Fh,0Fh
	defb 0B8h,0BAh,3Fh,02h,64h,12h
	defb 31h,05h,0Dh,5Fh,0Ch,01h
	defb 0C6h,17h,21h,0Ch,17h,17h
	defb 14h,0Ch,00h,00h,12h,42h
	defb 14h,15h,0BAh,0C6h,12h,0Ch
	defb 0C6h,0C6h,21h,0Ch,01h,01h
	defb 22h,11h,44h,44h,21h,1Dh
	defb 0A1h,0A1h,21h,08h,0A9h,0A9h
	defb 0Ch,04h,48h,59h,12h,03h
	defb 52h,5Ch,12h,03h,17h,0A1h
	defb 14h,0Bh,0A1h,0ACh,12h,0Bh
	defb 00h,63h,63h,24h,14h,7Fh
	defb 7Fh,24h,04h,44h,4Ah,3Fh
	defb 06h,0BAh,0BAh,21h,18h,0BAh
	defb 38h,31h,0Ch,0A1h,0A1h,11h
	defb 05h,0A6h,0BAh,22h,06h,0A1h
	defb 0A6h,24h,05h,0ACh,0ABh,22h
	defb 0Ah,5Eh,0B5h,3Fh,02h,00h
	defb 0BAh,0C6h,39h,0Ch,02h,0Eh
	defb 36h,0Ch,0Eh,0AAh,3Ch,0Ch
	defb 45h,0AEh,3Fh,02h,0AEh,0AEh
	defb 3Fh,02h,00h

; ----------------------------------------------------------------------
; DATA trigger_records: Two six-byte records and their 0x00, loaded by 0x4A86.
trigger_records:
	defb 07h,1Fh,84h,44h,7Fh,85h
	defb 07h,0A8h,84h,0A1h,0FCh,85h
	defb 00h

; ----------------------------------------------------------------------
; DATA list_for_0x4348: Nine bytes that 0x4A92 passes to 0x4348 in IX. A
;   different format from the 0x4371 records.
list_for_0x4348:
	defb 44h,56h,3Fh,12h,0A1h,0BFh,3Fh,1Dh,00h

; ----------------------------------------------------------------------
; DATA extra_records_graphics: Five compressed blocks of 34 bytes (0x98B9,
;   0x98DB, 0x98FD, 0x991F, 0x9941): the patterns and colours requested by the
;   records at 0x938E and 0x939B.
extra_records_graphics:
	defb 0A0h,00h,00h,01h,0Fh,3Fh,7Fh,5Fh,4Fh,0Eh,7Bh,0FDh,0E0h,0FEh,0FEh,0FEh
	defb 0FCh,27h,1Bh,1Dh,0Ch,02h,01h,00h,00h,0FCh,0F8h,0F8h,0F0h,70h,60h,0E0h
	defb 00h,00h,0A0h,90h,90h,90h,90h,90h,80h,80h,80h,90h,90h,90h,98h,80h
	defb 80h,80h,80h,80h,80h,80h,60h,60h,60h,60h,60h,80h,80h,80h,80h,80h
	defb 80h,60h,70h,00h,0A0h,70h,70h,70h,70h,70h,50h,50h,50h,70h,70h,70h	; ".`p..pppppPPPppp"
	defb 75h,50h,50h,50h,50h,50h,50h,50h,40h,40h,40h,40h,40h,50h,50h,50h	; "uPPPPPPP@@@@@PPP"
	defb 50h,50h,50h,40h,40h,00h,0A0h,40h,40h,30h,30h,30h,20h,20h,20h,30h
	defb 30h,30h,32h,20h,20h,20h,20h,20h,20h,20h,0C0h,0C0h,0C0h,0C0h,0C0h,20h
	defb 20h,20h,20h,20h,20h,0C0h,0B0h,00h,0A0h,0B0h,0B0h,0B0h,0B0h,0B0h,0A0h,0A0h
	defb 0A0h,0B0h,0B0h,0B0h,0BAh,0A0h,0A0h,0A0h,0A0h,0A0h,0A0h,0A0h,0A0h,0A0h,0A0h,0A0h
	defb 0A0h,0A0h,0A0h,0A0h,0A0h,0A0h,0A0h,0A0h,0A0h,00h

; ----------------------------------------------------------------------
; DATA graphics_names_1800: Compressed block that 0x4296 dumps into VRAM
;   0x1800 (the name table) when 0xF0F4 is not zero.
graphics_names_1800:
	defb 8Ch,0C0h,0F0h,0EFh,1Fh,7Fh,0FFh,0FFh,7Fh,06h,0FAh,0FBh,07h,08h,00h,02h
	defb 80h,87h,0C0h,60h,39h,2Fh,07h,8Eh,0F8h,0Bh,00h,02h,01h,08h,00h,8Ah
	defb 60h,78h,3Ch,3Eh,0Eh,80h,0C0h,0D0h,0F8h,70h,04h,00h,8Ch,0C0h,0F0h,0EFh
	defb 1Fh,7Fh,0FFh,0FFh,7Fh,07h,0FBh,0FBh,07h,08h,00h,02h,80h,87h,0C0h,0E0h
	defb 39h,1Fh,07h,0CEh,0F8h,0Bh,00h,02h,01h,08h,00h,8Ah,60h,78h,3Ch,3Eh
	defb 0Eh,80h,0C0h,0D0h,0F8h,70h,04h,00h,8Ch,0C0h,0F0h,0EFh,1Fh,7Fh,0FFh,0FFh
	defb 7Fh,07h,0FBh,0FBh,07h,08h,00h,02h,80h,87h,0C0h,0E0h,0F9h,0FFh,0FFh,0FEh
	defb 0F8h,0Bh,00h,02h,01h,08h,00h,8Ah,60h,78h,3Ch,3Eh,0Eh,80h,0C0h,0D0h
	defb 0F8h,70h,04h,00h,87h,03h,07h,02h,00h,30h,70h,20h,19h,00h,83h,0BEh
	defb 0BFh,0BEh,1Dh,00h,87h,20h,60h,0D8h,3Ch,1Eh,0Eh,02h,1Bh,00h,8Ah,60h
	defb 78h,3Ch,3Eh,0Eh,00h,0C0h,0E0h,0F8h,30h,04h,00h,9Ch,60h,90h,90h,60h
	defb 30h,48h,48h,30h,30h,48h,48h,30h,60h,90h,90h,60h,00h,00h,60h,78h	; "0HH00HH0`..`..`x"
	defb 3Ch,3Eh,0Eh,00h,0C0h,0E0h,0F8h,30h,04h,00h,9Ch,90h,60h,30h,48h,48h
	defb 30h,30h,48h,48h,30h,30h,48h,48h,30h,60h,90h,00h,00h,60h,78h,3Ch	; "00HH00HH0`...`x<"
	defb 3Eh,0Eh,00h,0C0h,0E0h,0F8h,30h,04h,00h,9Ch,60h,90h,90h,60h,30h,48h
	defb 48h,30h,30h,48h,48h,30h,60h,90h,90h,60h,00h,00h,60h,78h,3Ch,3Eh	; "H00HH0`..`..`x<>"
	defb 0Eh,00h,0C0h,0E0h,0F8h,30h,04h,00h,9Ch,90h,60h,30h,48h,48h,30h,30h
	defb 48h,48h,30h,30h,48h,48h,30h,60h,90h,00h,00h,60h,78h,3Ch,3Eh,0Eh	; "HH00HH0`...`x<>."
	defb 00h,0C0h,0E0h,0F8h,30h,06h,00h,8Ch,30h,48h,48h,30h,30h,48h,48h,30h
	defb 30h,48h,48h,30h,04h,00h,8Ah,60h,78h,3Ch,3Eh,0Eh,00h,0C0h,0E0h,0F8h
	defb 30h,08h,00h,88h,30h,48h,48h,30h,30h,48h,48h,30h,06h,00h,8Ah,60h
	defb 78h,3Ch,3Eh,0Eh,00h,0C0h,0E0h,0F8h,30h,06h,00h,8Ch,30h,48h,48h,30h
	defb 30h,48h,48h,30h,30h,48h,48h,30h,04h,00h,8Ah,60h,78h,3Ch,3Eh,0Eh	; "0HH00HH0...`x<>."
	defb 00h,0C0h,0E0h,0F8h,30h,08h,00h,88h,30h,48h,48h,30h,30h,48h,48h,30h
	defb 04h,00h,8Fh,0E0h,0B8h,8Fh,90h,0E0h,0C0h,80h,80h,0C1h,0FAh,86h,8Dh,0F8h
	defb 0Fh,01h,03h,00h,9Dh,0F0h,9Ch,86h,43h,41h,0B1h,59h,77h,29h,09h,0F3h
	defb 06h,0FCh,00h,0E0h,0B8h,8Fh,90h,0E0h,0C0h,80h,80h,0C1h,0FBh,87h,8Dh,0F8h
	defb 0Fh,01h,03h,00h,8Dh,0F0h,9Ch,86h,43h,41h,0B1h,19h,0C7h,21h,19h,8Bh
	defb 76h,0FCh,07h,00h,83h,01h,1Fh,01h,0Bh,00h,87h,01h,0Eh,0F0h,00h,0F0h
	defb 0Eh,01h,0Ah,00h,85h,01h,0Ch,0C0h,0Ch,01h,0Bh,00h,85h,80h,30h,03h
	defb 30h,80h,0Ch,00h,83h,03h,3Fh,03h,0Dh,00h,83h,0C0h,0FCh,0C0h,0Dh,00h
	defb 83h,07h,3Fh,07h,09h,00h,8Bh,03h,1Ch,30h,0E0h,80h,00h,80h,0E0h,30h
	defb 1Ch,03h,06h,00h,89h,03h,0Eh,18h,70h,0E0h,70h,18h,0Eh,03h,07h,00h
	defb 89h,0C0h,70h,18h,0Eh,07h,0Eh,18h,70h,0C0h,08h,00h,87h,01h,07h,0Fh
	defb 1Fh,0Fh,07h,01h,09h,00h,87h,80h,0E0h,0F0h,0F8h,0F0h,0E0h,80h,0Ah,00h
	defb 85h,01h,02h,78h,02h,01h,09h,00h,02h,80h,87h,40h,20h,0Fh,20h,40h
	defb 80h,80h,0Ah,00h,83h,01h,06h,01h,0Ch,00h,85h,80h,40h,30h,40h,80h
	defb 0Dh,00h,81h,01h,0Eh,00h,83h,80h,0C0h,80h,0Bh,00h,87h,80h,70h,0Fh
	defb 00h,0Fh,70h,80h,0Bh,00h,83h,80h,0F8h,80h,09h,00h,8Bh,0C0h,38h,0Ch
	defb 07h,01h,00h,01h,07h,0Ch,38h,0C0h,09h,00h,83h,0E0h,0FCh,0E0h,07h,00h
	defb 00h

	end

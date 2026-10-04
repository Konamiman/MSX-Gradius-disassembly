; ============================================================================
; Nemesis / Gradius - map image (banks 11-12) - pieces.asm
; ============================================================================

; Bank 11 (runs at 0x8000).
;
; THIS BANK HOLDS NO CODE. It is the first half of the MAP: it is always
; mapped together with bank 12 (0xA000) (p00:4552-p00:455C,
; p00:460E-p00:4618, p00:5CE1-p00:5CEB and p00:5D84-p00:5D8E), so for the
; scroll code they are 16 KB in a row from 0x8000 to 0xBFFF.
;
; HOW THE BACKGROUND IS DRAWN. Routine 0x46DF in bank 0 takes a byte from the
; stage's script, multiplies it by 16 and adds it to 0x8000 (or to 0x8FF0 in
; stages 5, 9, 10 and 12, p00:46F2-p00:4708). What is there is sixteen bytes:
; a column of four characters taken four at a time. In other words, each byte
; of the script is a PIECE of 4x4 characters, and the whole map is written
; with those pieces.

; ----------------------------------------------------------------------
; BACKGROUND PIECES AND STAGE SCRIPTS (bank 11)
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; DATA pieces_A: 255 pieces of 16 bytes each (4x4 characters). The index comes
;   from the stage's script; 0x470B adds 16*index to 0x8000.
pieces_A:
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0F7h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,0F7h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0F6h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,0F7h,00h,00h,00h,00h,00h,00h
	defb 0A4h,0A5h,0A6h,0A7h,00h,00h,00h,00h,0F7h,00h,00h,00h,00h,00h,00h,00h
	defb 0A4h,0A5h,0A6h,0A7h,00h,00h,00h,00h,00h,00h,0F7h,00h,00h,00h,00h,00h
	defb 0A4h,0A8h,0A6h,0A7h,00h,00h,00h,00h,00h,00h,00h,0F6h,00h,00h,00h,00h
	defb 0A4h,0A9h,0A4h,0A8h,0AEh,62h,0A1h,0A2h,00h,00h,00h,00h,00h,00h,0F6h,00h
	defb 0F6h,00h,00h,00h,00h,00h,00h,00h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h
	defb 5Fh,60h,61h,62h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h	; "_`abCCCCCCCCCCCC"
	defb 60h,4Eh,4Fh,50h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h	; "`NOPCCCCCCCCCCCC"
	defb 51h,52h,53h,62h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h	; "QRSbCCCCCCCCCCCC"
	defb 59h,5Ah,5Bh,5Ch,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h	; "YZ[\CCCCCCCCCCCC"
	defb 53h,51h,52h,5Dh,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h	; "SQR]CCCCCCCCCCCC"
	defb 5Eh,60h,61h,62h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h	; "^`abCCCCCCCCCCCC"
	defb 00h,00h,00h,0A2h,00h,00h,0A2h,44h,0B5h,00h,46h,47h,0B9h,0A3h,4Ah,4Bh
	defb 0A5h,00h,00h,0F7h,45h,0A6h,00h,00h,48h,49h,0A7h,0B5h,4Ch,48h,4Dh,0B9h
	defb 0F6h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0A2h,00h,00h,0A2h,44h
	defb 00h,00h,00h,00h,0F6h,00h,00h,00h,0A5h,00h,00h,00h,45h,0A6h,0F6h,00h
	defb 00h,00h,46h,47h,00h,0A3h,4Ah,4Bh,0A4h,4Eh,4Fh,50h,54h,55h,56h,57h
	defb 48h,49h,0A7h,0F6h,4Ch,48h,4Dh,0A8h,51h,52h,53h,0A9h,48h,4Ch,48h,58h	; "HI..LHM.QRS.HLHX"
	defb 00h,00h,0F7h,00h,00h,00h,00h,0F6h,00h,0B5h,0B4h,0B5h,0AAh,0B9h,0B8h,0B9h
	defb 00h,00h,46h,47h,00h,00h,0ABh,0ACh,00h,0AEh,0AFh,0B0h,54h,55h,56h,57h
	defb 48h,49h,0A7h,00h,0ABh,0ACh,0ADh,00h,0AEh,0B0h,0AFh,0B1h,48h,4Ch,48h,58h
	defb 00h,00h,0A2h,0A5h,00h,0A2h,44h,45h,00h,46h,47h,48h,0A3h,4Ah,4Bh,4Ch
	defb 00h,00h,0F6h,00h,0A6h,00h,00h,00h,49h,0A7h,00h,00h,48h,4Dh,00h,00h
	defb 0ADh,54h,55h,56h,00h,50h,51h,52h,00h,0ACh,4Eh,4Fh,00h,00h,0ACh,0AFh
	defb 52h,57h,00h,00h,53h,0B1h,00h,00h,0B0h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,45h,46h,45h,46h
	defb 00h,00h,47h,48h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 49h,45h,46h,47h,44h,44h,44h,44h,00h,44h,44h,00h,44h,44h,44h,44h	; "IEFGDDDD.DD.DDDD"
	defb 48h,49h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,45h,00h,00h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 46h,45h,46h,45h,45h,46h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 46h,4Ah,4Bh,45h,45h,46h,45h,46h,44h,44h,44h,44h,00h,44h,44h,00h	; "FJKEEFEFDDDD.DD."
	defb 46h,00h,00h,00h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 44h,44h,44h,44h,46h,4Ah,4Bh,45h,49h,45h,46h,47h,0A4h,4Ch,4Dh,0A5h	; "DDDDFJKEIEFG.LM."
	defb 00h,00h,00h,00h,00h,00h,00h,45h,00h,00h,47h,48h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,46h,00h,00h,00h,48h,49h,00h,00h,00h,00h,00h,00h
	defb 0A1h,4Eh,4Fh,00h,00h,0A2h,0A3h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,45h,46h,45h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,44h,44h,00h,00h,44h,44h,00h,00h,44h,44h,00h,46h,4Ah,4Bh,45h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,45h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,46h,00h,00h,00h
	defb 00h,00h,47h,48h,47h,48h,49h,45h,00h,00h,45h,46h,00h,00h,00h,45h
	defb 49h,4Ah,4Bh,47h,46h,45h,46h,45h,45h,46h,45h,46h,46h,45h,46h,45h	; "IJKGFEFEEFEFFEFE"
	defb 48h,49h,45h,46h,46h,45h,46h,45h,45h,46h,00h,00h,46h,00h,00h,00h
	defb 00h,00h,00h,00h,46h,47h,48h,49h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 44h,44h,44h,44h,44h,44h,44h,00h,00h,44h,44h,00h,00h,00h,00h,00h
	defb 45h,46h,45h,46h,46h,45h,46h,45h,00h,44h,44h,00h,00h,44h,44h,00h	; "EFEFFEFE.DD..DD."
	defb 00h,00h,00h,00h,46h,45h,46h,47h,48h,49h,45h,46h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,48h,49h,00h,00h,45h,46h,45h,46h,00h,00h,00h,47h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,48h,49h,45h,46h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,47h,48h,49h,45h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,46h,45h,46h,45h
	defb 45h,46h,47h,48h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,44h,44h,00h,00h,44h,44h,00h,45h,46h,45h,46h,46h,45h,46h,45h	; ".DD..DD.EFEFFEFE"
	defb 45h,46h,45h,46h,46h,4Ah,4Bh,45h,49h,45h,46h,47h,0A4h,4Ch,4Dh,0A5h	; "EFEFFJKEIEFG.LM."
	defb 58h,52h,54h,52h,51h,53h,53h,59h,4Bh,4Ch,4Ch,4Bh,00h,00h,00h,00h	; "XRTRQSSYKLLK...."
	defb 58h,52h,54h,52h,51h,53h,53h,59h,4Bh,4Ch,4Ch,4Bh,00h,00h,00h,00h	; "XRTRQSSYKLLK...."
	defb 00h,33h,34h,57h,00h,35h,36h,57h,00h,00h,00h,4Ah,00h,00h,00h,00h
	defb 52h,52h,59h,51h,53h,50h,58h,50h,4Bh,4Fh,53h,53h,00h,57h,58h,52h	; "RRYQSPXPKOSS.WXR"
	defb 52h,52h,52h,59h,53h,53h,58h,53h,53h,53h,4Eh,4Bh,52h,58h,56h,00h	; "RRRYSSXSSSNKRXV."
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,45h,46h,00h,45h,46h,45h,46h
	defb 44h,44h,44h,44h,00h,44h,44h,00h,44h,44h,44h,44h,46h,4Ah,4Bh,47h	; "DDDD.DD.DDDDFJKG"
	defb 00h,00h,00h,00h,00h,45h,46h,45h,45h,46h,47h,48h,00h,00h,00h,00h
	defb 49h,45h,46h,47h,44h,44h,44h,44h,44h,44h,44h,00h,00h,44h,44h,00h	; "IEFGDDDDDDD..DD."
	defb 00h,00h,00h,00h,47h,48h,49h,45h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,46h,47h,48h,49h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,45h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 49h,4Ah,4Bh,47h,0A4h,4Ch,4Dh,0A5h,0A1h,4Eh,4Fh,00h,00h,0A2h,0A3h,00h
	defb 45h,46h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 49h,45h,46h,45h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,45h,46h,45h,00h,00h,00h,44h,00h,00h,44h,44h,00h,44h,44h,44h
	defb 46h,45h,46h,45h,45h,46h,45h,46h,44h,44h,44h,44h,44h,44h,44h,44h	; "FEFEEFEFDDDDDDDD"
	defb 44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h	; "DDDDDDDDDDDDDDDD"
	defb 44h,44h,44h,00h,44h,44h,00h,00h,44h,44h,00h,00h,44h,44h,44h,00h
	defb 46h,45h,46h,44h,45h,46h,45h,46h,47h,48h,49h,45h,44h,00h,45h,46h	; "FEFDEFEFGHIED.EF"
	defb 44h,44h,00h,00h,44h,00h,00h,00h,46h,47h,48h,49h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,44h,44h,00h,00h,44h,45h,46h,00h,45h,46h,45h,46h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,45h,46h,00h,00h
	defb 00h,00h,44h,44h,45h,46h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 44h,44h,47h,48h,45h,46h,45h,46h,47h,48h,49h,45h,44h,44h,44h,44h	; "DDGHEFEFGHIEDDDD"
	defb 49h,45h,46h,45h,45h,46h,45h,46h,46h,45h,46h,45h,44h,47h,48h,49h	; "IEFEEFEFFEFEDGHI"
	defb 46h,45h,46h,00h,00h,00h,00h,00h,46h,45h,46h,45h,45h,46h,45h,46h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,46h,47h,48h,49h,47h,48h,49h,00h
	defb 00h,44h,44h,44h,00h,00h,44h,44h,00h,00h,00h,44h,00h,00h,00h,00h
	defb 44h,44h,47h,48h,44h,45h,46h,44h,44h,44h,44h,44h,44h,44h,44h,44h	; "DDGHDEFDDDDDDDDD"
	defb 49h,45h,46h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h	; "IEFDDDDDDDDDDDDD"
	defb 44h,44h,44h,44h,45h,46h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 44h,45h,46h,00h,45h,46h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 5Fh,60h,61h,62h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 5Fh,60h,61h,62h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0F7h
	defb 5Fh,60h,61h,62h,0B6h,0B7h,0B8h,0B9h,0B2h,0B3h,0B4h,0B5h,00h,00h,00h,00h
	defb 60h,4Eh,4Fh,50h,0B9h,0A3h,4Ah,4Bh,0B5h,00h,46h,47h,00h,00h,0A2h,44h
	defb 51h,52h,53h,62h,4Ch,48h,4Dh,0B9h,48h,49h,0A7h,0B5h,45h,0A6h,00h,00h
	defb 00h,00h,00h,0A2h,00h,00h,00h,00h,00h,0F6h,00h,00h,00h,00h,00h,00h
	defb 0A5h,00h,00h,0F7h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 60h,60h,61h,62h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h	; "``abCCCCCCCCCCCC"
	defb 59h,5Ah,5Bh,5Ch,54h,55h,56h,57h,00h,0AEh,0AFh,0B0h,00h,00h,0ABh,0ACh
	defb 00h,00h,46h,47h,00h,00h,0A2h,44h,00h,00h,00h,0A2h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,0F6h,00h,00h,00h,00h,00h,0ABh,62h,0A1h,0A2h
	defb 5Fh,44h,44h,5Fh,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h,43h	; "_DD_CCCCCCCCCCCC"
	defb 53h,51h,52h,5Dh,48h,4Ch,48h,58h,0AEh,0B0h,0AFh,0B1h,0ABh,0ACh,0ADh,00h
	defb 48h,49h,0A7h,00h,45h,0A6h,00h,00h,0A5h,00h,00h,00h,00h,00h,00h,00h
	defb 5Eh,60h,61h,62h,0AAh,0B9h,0B6h,0B9h,00h,0B5h,0B2h,0B5h,00h,00h,00h,00h
	defb 5Fh,60h,61h,62h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,45h,46h,00h,00h,00h,47h,00h,00h,00h,00h,00h,0F6h,00h,00h
	defb 52h,52h,50h,52h,51h,51h,54h,53h,4Ch,4Bh,4Bh,4Fh,00h,31h,32h,57h	; "RRPRQQTSLKKO.12W"
	defb 00h,00h,00h,00h,00h,00h,00h,44h,00h,71h,72h,57h,00h,73h,74h,57h
	defb 00h,75h,76h,57h,00h,00h,00h,57h,00h,00h,00h,57h,46h,45h,46h,49h
	defb 52h,46h,0A1h,00h,53h,58h,47h,0A3h,00h,00h,0A2h,48h,00h,00h,00h,0A4h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,44h,4Ah,52h,4Ah,45h,4Bh,53h,4Bh
	defb 00h,00h,00h,00h,00h,00h,00h,00h,52h,4Ah,52h,4Eh,53h,4Bh,53h,4Fh
	defb 00h,0A5h,52h,46h,0A7h,54h,53h,58h,55h,0A6h,00h,00h,0A8h,00h,00h,00h
	defb 52h,4Ah,52h,4Ah,53h,4Bh,53h,4Bh,00h,00h,62h,61h,00h,00h,61h,62h	; "RJRJSKSK..ba..ab"
	defb 52h,4Ah,52h,46h,53h,4Bh,53h,58h,62h,61h,00h,00h,61h,62h,00h,00h	; "RJRFSKSXba..ab.."
	defb 00h,00h,00h,00h,00h,00h,00h,00h,52h,4Ah,52h,46h,53h,4Bh,53h,58h
	defb 00h,00h,00h,0A5h,00h,00h,0A7h,54h,52h,4Eh,55h,0A6h,53h,4Fh,0A8h,00h
	defb 52h,4Ah,52h,46h,53h,4Bh,53h,58h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 0A1h,00h,00h,00h,47h,0A3h,00h,00h,0A2h,48h,44h,4Ah,00h,0A4h,45h,4Bh
	defb 00h,00h,00h,0A5h,00h,00h,0A7h,54h,52h,4Eh,55h,0A6h,53h,4Fh,0A8h,00h
	defb 52h,4Ah,52h,46h,53h,4Bh,53h,58h,00h,00h,00h,62h,00h,00h,62h,00h
	defb 52h,4Ah,52h,46h,53h,4Bh,53h,58h,61h,00h,00h,62h,00h,61h,62h,00h	; "RJRFSKSXa..b.ab."
	defb 52h,4Ah,52h,46h,53h,4Bh,53h,58h,61h,00h,00h,00h,00h,61h,62h,61h	; "RJRFSKSXa....aba"
	defb 52h,4Ah,52h,46h,53h,4Bh,53h,58h,00h,62h,61h,00h,62h,00h,00h,61h	; "RJRFSKSX.ba.b..a"
	defb 52h,4Ah,52h,4Ah,53h,4Bh,53h,4Bh,61h,62h,61h,00h,62h,61h,62h,61h	; "RJRJSKSKaba.baba"
	defb 52h,46h,0A1h,00h,53h,58h,47h,0A3h,00h,00h,0A2h,48h,00h,00h,00h,0A2h
	defb 61h,62h,61h,62h,62h,61h,62h,61h,12h,12h,1Bh,1Ch,13h,14h,15h,16h
	defb 0ACh,59h,5Ah,5Bh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,42h,42h,42h,42h,42h,42h,42h,42h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0A3h,00h,00h,00h,47h,0A3h,00h,00h
	defb 0A2h,55h,0A3h,00h,00h,0A2h,48h,46h,00h,00h,01h,02h,00h,00h,00h,00h
	defb 00h,00h,00h,5Dh,51h,46h,49h,5Fh,45h,58h,03h,04h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,4Ch,5Dh,56h,51h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,46h,0A1h,00h,00h
	defb 57h,4Dh,0ACh,60h,5Eh,00h,00h,0ABh,00h,08h,09h,0Ah,05h,06h,07h,00h
	defb 5Fh,47h,0A9h,00h,5Ah,5Bh,5Ch,0AAh,0Bh,00h,0Ch,0Dh,00h,00h,00h,0Fh
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0Eh,00h,00h,00h,10h,11h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,1Fh,20h,00h,00h,28h,29h
	defb 00h,00h,12h,13h,17h,18h,19h,1Ah,21h,22h,23h,40h,2Ah,2Bh,2Ch,41h
	defb 14h,15h,16h,00h,1Bh,1Ch,1Dh,1Eh,24h,25h,26h,27h,2Dh,2Eh,2Fh,30h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,02h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,57h,58h,03h,04h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,05h,06h,07h,00h,00h,08h,09h,07h
	defb 31h,32h,33h,34h,00h,00h,39h,3Ah,00h,00h,00h,0Fh,0Bh,00h,0Ch,0Dh
	defb 35h,36h,37h,38h,3Bh,3Ch,3Dh,00h,10h,11h,00h,00h,0Eh,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0A2h,00h,00h,0A2h,48h
	defb 00h,0A2h,48h,46h,0A2h,55h,0A3h,00h,47h,0A3h,00h,00h,0A3h,00h,00h,00h
	defb 51h,46h,49h,5Fh,00h,00h,00h,5Dh,00h,00h,00h,00h,00h,00h,00h,00h
	defb 5Eh,00h,00h,0ABh,57h,4Dh,0ACh,60h,4Ch,50h,56h,51h,00h,00h,00h,00h
	defb 5Ah,5Bh,5Ch,0AAh,5Fh,47h,0A9h,00h,46h,0A1h,00h,00h,00h,00h,00h,00h
	defb 53h,58h,47h,0A3h,52h,46h,0A1h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 53h,4Bh,53h,58h,52h,4Ah,52h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 53h,4Bh,53h,4Bh,52h,4Ah,52h,4Ah,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0A4h,00h,00h,0A2h,48h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,45h,4Bh,53h,4Bh,44h,4Ah,52h,4Ah
	defb 00h,00h,00h,00h,00h,00h,00h,00h,53h,4Bh,53h,4Fh,52h,4Ah,52h,4Eh
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0A8h,00h,00h,00h,55h,0A6h,00h,00h
	defb 62h,61h,62h,61h,61h,62h,61h,62h,53h,4Bh,53h,4Fh,52h,4Ah,52h,4Eh	; "babaababSKSORJRN"
	defb 62h,61h,62h,61h,61h,62h,61h,62h,0A8h,00h,00h,00h,55h,0A6h,00h,00h
	defb 62h,61h,62h,61h,61h,62h,61h,62h,45h,4Bh,53h,4Bh,44h,4Ah,52h,4Ah	; "babaababEKSKDJRJ"
	defb 61h,62h,61h,62h,00h,61h,62h,00h,53h,4Bh,53h,4Fh,52h,4Ah,52h,4Eh	; "abab.ab.SKSORJRN"
	defb 00h,00h,00h,00h,0A1h,48h,49h,4Ah,43h,44h,45h,46h,42h,42h,4Bh,4Ch
	defb 0A7h,54h,53h,58h,00h,0A5h,52h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 62h,61h,62h,61h,61h,62h,61h,62h,62h,61h,62h,61h,61h,62h,61h,62h	; "babaababbabaabab"
	defb 62h,61h,62h,61h,00h,00h,61h,62h,00h,00h,62h,61h,61h,62h,61h,62h	; "baba..ab..baabab"
	defb 61h,62h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,61h,00h,00h,00h,00h,61h,00h,62h,61h,62h,00h,61h,62h,61h
	defb 00h,62h,61h,00h,62h,61h,00h,61h,61h,62h,61h,62h,62h,61h,62h,61h	; ".ba.ba.aababbaba"
	defb 00h,62h,61h,62h,62h,61h,62h,61h,61h,62h,61h,00h,62h,00h,00h,61h	; ".babbabaaba.b..a"
	defb 00h,00h,00h,00h,00h,00h,00h,00h,61h,62h,61h,00h,62h,61h,62h,61h
	defb 61h,62h,61h,62h,62h,61h,62h,61h,61h,62h,61h,62h,62h,61h,62h,00h	; "ababbabaababbab."
	defb 61h,00h,00h,62h,62h,61h,62h,61h,61h,62h,61h,62h,62h,61h,62h,00h	; "a..bbabaababbab."
	defb 00h,00h,62h,61h,61h,62h,61h,62h,62h,00h,00h,61h,61h,00h,00h,62h
	defb 61h,62h,61h,00h,00h,61h,62h,61h,00h,62h,61h,62h,62h,61h,62h,00h	; "aba..aba.babbab."
	defb 61h,00h,00h,62h,62h,61h,62h,00h,61h,62h,00h,00h,62h,00h,00h,00h
	defb 61h,00h,61h,62h,00h,61h,62h,61h,00h,00h,61h,62h,00h,00h,00h,61h
	defb 61h,00h,00h,00h,00h,61h,00h,00h,00h,00h,61h,00h,00h,00h,00h,61h
	defb 00h,00h,00h,62h,00h,00h,62h,00h,00h,62h,61h,00h,62h,00h,62h,61h
	defb 00h,62h,00h,00h,00h,61h,00h,00h,00h,00h,61h,62h,00h,00h,00h,00h
	defb 61h,62h,61h,62h,62h,61h,62h,61h,26h,25h,12h,12h,20h,1Fh,1Eh,1Dh
	defb 61h,62h,61h,62h,62h,61h,62h,61h,12h,12h,12h,12h,12h,12h,12h,12h
	defb 00h,00h,00h,00h,54h,53h,52h,0ABh,50h,4Fh,4Eh,4Dh,56h,55h,42h,42h
	defb 5Eh,5Dh,5Ch,0B6h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0F6h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 0B5h,00h,0B5h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0B5h,00h,0B5h
	defb 0B6h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0B6h,00h,00h,00h
	defb 0B5h,00h,0B5h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0B5h,00h,0B5h,00h
	defb 00h,0B6h,00h,00h,00h,00h,00h,00h,00h,0B6h,00h,00h,00h,00h,00h,00h
	defb 00h,57h,51h,52h,00h,57h,58h,53h,00h,4Ah,4Ch,4Bh,00h,00h,00h,00h
	defb 52h,51h,52h,52h,53h,50h,53h,58h,4Ch,4Bh,4Bh,4Bh,00h,00h,00h,00h	; "RQRRSPSXLKKK...."
	defb 58h,52h,54h,52h,51h,53h,53h,59h,4Bh,4Ch,4Ch,4Bh,00h,00h,00h,00h	; "XRTRQSSYKLLK...."
	defb 52h,52h,51h,52h,53h,59h,53h,53h,4Bh,4Bh,4Bh,4Ch,00h,00h,00h,00h	; "RRQRSYSSKKKL...."
	defb 52h,52h,50h,52h,51h,51h,54h,53h,4Ch,4Bh,4Bh,4Fh,00h,00h,00h,57h	; "RRPRQQTSLKKO...W"
	defb 50h,58h,58h,52h,58h,53h,53h,58h,4Eh,4Bh,4Ch,4Ch,56h,00h,00h,00h	; "PXXRXSSXNKLLV..."
	defb 00h,00h,00h,4Ah,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 4Bh,4Ch,4Bh,4Bh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 4Dh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,44h,46h,45h,45h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,45h,46h,45h,45h
	defb 00h,00h,00h,00h,00h,00h,00h,44h,00h,00h,00h,57h,46h,45h,46h,49h
	defb 00h,00h,00h,00h,45h,46h,45h,45h,51h,53h,53h,59h,58h,53h,54h,53h	; "....EFEEQSSYXSTS"
	defb 00h,00h,00h,00h,46h,45h,46h,46h,53h,58h,52h,52h,53h,53h,53h,53h	; "....FEFFSXRRSSSS"
	defb 57h,52h,51h,52h,57h,53h,58h,53h,51h,52h,52h,51h,54h,53h,53h,58h	; "WRQRWSXSQRRQTSSX"
	defb 52h,51h,52h,52h,53h,54h,53h,58h,53h,59h,53h,54h,53h,54h,58h,54h	; "RQRRSTSXSYSTSTXT"
	defb 52h,52h,51h,52h,53h,53h,54h,53h,53h,53h,59h,52h,53h,53h,54h,53h	; "RRQRSSTSSSYRSSTS"
	defb 59h,53h,59h,52h,53h,53h,58h,53h,51h,52h,52h,51h,54h,53h,53h,58h	; "YSYRSSXSQRRQTSSX"
	defb 00h,00h,00h,00h,47h,00h,00h,00h,56h,00h,00h,00h,48h,46h,45h,46h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,44h
	defb 00h,00h,00h,57h,45h,46h,45h,49h,52h,51h,52h,59h,53h,53h,58h,53h	; "...WEFEIRQRYSSXS"
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,47h,00h,00h,00h
	defb 56h,00h,00h,00h,48h,46h,45h,46h,52h,52h,52h,50h,53h,53h,59h,53h	; "V...HFEFRRRPSSYS"
	defb 00h,00h,00h,00h,00h,00h,00h,44h,00h,00h,00h,57h,00h,00h,00h,57h
	defb 00h,00h,00h,57h,00h,00h,00h,57h,00h,00h,00h,57h,46h,45h,46h,49h
	defb 56h,00h,00h,00h,56h,00h,00h,00h,56h,00h,00h,00h,48h,46h,45h,46h
	defb 4Ch,4Bh,4Bh,4Fh,00h,00h,00h,57h,00h,00h,00h,4Ah,00h,00h,00h,00h
	defb 4Eh,4Bh,4Ch,4Ch,56h,00h,00h,00h,4Dh,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,57h,00h,00h,00h,57h,00h,00h,00h,57h,00h,00h,00h,57h
	defb 56h,00h,00h,00h,56h,00h,00h,00h,4Dh,00h,00h,00h,00h,00h,00h,00h
	defb 4Eh,4Bh,4Ch,4Ch,56h,00h,00h,00h,56h,00h,00h,00h,56h,00h,00h,00h
	defb 4Ch,4Bh,4Bh,4Fh,00h,00h,00h,57h,00h,00h,00h,57h,00h,00h,00h,57h
	defb 56h,00h,00h,00h,56h,00h,00h,00h,56h,00h,00h,00h,56h,00h,00h,00h
	defb 00h,57h,54h,51h,00h,57h,54h,58h,00h,57h,54h,50h,00h,57h,59h,52h	; ".WTQ.WTX.WTP.WYR"
	defb 00h,4Ah,4Bh,4Ch,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 52h,52h,56h,00h,52h,52h,56h,00h,53h,53h,56h,00h,51h,59h,56h,00h	; "RRV.RRV.SSV.QYV."
	defb 4Bh,4Bh,4Dh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,44h,45h,46h,00h,57h,58h,54h,46h,49h,58h,54h
	defb 00h,00h,00h,00h,45h,45h,47h,00h,51h,58h,56h,00h,52h,58h,48h,46h
	defb 00h,00h,00h,00h,47h,00h,00h,00h,56h,00h,00h,00h,56h,00h,00h,00h
	defb 00h,00h,0ACh,0ADh,00h,00h,00h,0AEh,00h,00h,00h,0BAh,00h,00h,00h,00h
	defb 00h,00h,00h,0A3h,0AFh,00h,00h,0A8h,0BBh,00h,00h,0A5h,0BCh,01h,00h,0Ah
	defb 00h,00h,00h,00h,0A9h,00h,00h,0B4h,0A4h,00h,00h,0BEh,0Bh,00h,05h,0BFh
	defb 0B2h,0B1h,00h,00h,0B3h,00h,00h,00h,0BDh,00h,00h,00h,00h,00h,00h,00h
	defb 00h,02h,03h,0Ch,00h,04h,1Ah,1Bh,36h,1Fh,20h,21h,32h,27h,28h,29h
	defb 0Dh,07h,08h,00h,1Ch,1Dh,09h,00h,22h,23h,24h,37h,2Ah,2Bh,2Ch,33h
	defb 34h,31h,30h,1Eh,00h,11h,12h,18h,00h,14h,15h,16h,0A6h,0A7h,00h,0A4h
	defb 2Eh,2Dh,2Fh,35h,25h,26h,13h,00h,17h,0Eh,10h,00h,0A5h,00h,0AAh,0A9h
	defb 00h,00h,00h,00h,00h,00h,00h,0A7h,00h,00h,00h,00h,46h,46h,46h,45h
	defb 0A9h,0AAh,00h,0A4h,0A8h,00h,00h,0A2h,00h,00h,00h,00h,46h,45h,46h,45h
	defb 0A3h,00h,0AFh,0AEh,0A1h,00h,00h,0ADh,00h,00h,00h,00h,45h,46h,46h,45h
	defb 00h,00h,00h,00h,0ACh,00h,00h,00h,00h,00h,00h,00h,45h,45h,46h,46h
	defb 5Fh,60h,61h,62h,00h,00h,00h,00h,00h,0F6h,00h,00h,00h,00h,00h,00h
	defb 49h,44h,44h,44h,47h,48h,49h,44h,46h,44h,44h,44h,44h,44h,44h,44h	; "IDDDGHIDFDDDDDDD"
	defb 46h,44h,44h,00h,45h,46h,00h,00h,46h,00h,00h,00h,44h,44h,00h,00h
	defb 48h,49h,45h,46h,45h,46h,45h,46h,00h,45h,46h,45h,00h,00h,45h,46h	; "HIEFEFEF.EFE..EF"
	defb 44h,44h,47h,48h,44h,45h,46h,00h,45h,46h,00h,00h,44h,47h,48h,49h	; "DDGHDEF.EF..DGHI"
	defb 49h,45h,46h,47h,00h,00h,00h,00h,00h,00h,00h,00h,45h,46h,00h,00h
	defb 46h,47h,48h,49h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h	; "FGHIDDDDDDDDDDDD"
	defb 00h,00h,00h,00h,00h,00h,00h,00h,46h,00h,00h,00h,45h,46h,00h,00h
	defb 44h,44h,44h,44h,44h,45h,46h,44h,45h,46h,45h,46h,44h,47h,48h,49h	; "DDDDDEFDEFEFDGHI"
	defb 44h,44h,44h,44h,44h,45h,46h,44h,45h,46h,45h,46h,0AEh,0AFh,0AEh,0AFh	; "DDDDDEFDEFEF...."
	defb 46h,00h,00h,00h,00h,00h,00h,00h,46h,00h,00h,0F7h,00h,00h,00h,00h

; ----------------------------------------------------------------------
; DATA pieces_B: The other set of pieces, based at 0x8FF0. Used by stages 5,
;   9, 10 and 12 (0x46F5-0x4706 compares 0xE061 with 5, 9, 10 and 12).
pieces_B:
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0F7h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,0F7h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0F6h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,0F7h,00h,00h,00h,00h,00h,00h
	defb 12h,13h,14h,15h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 12h,13h,16h,15h,00h,00h,00h,00h,00h,0F7h,00h,00h,00h,00h,00h,00h
	defb 12h,13h,14h,15h,73h,74h,75h,76h,00h,80h,81h,82h,00h,00h,00h,00h
	defb 12h,13h,14h,15h,00h,00h,00h,64h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 12h,13h,14h,15h,0Dh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 12h,13h,14h,15h,00h,00h,64h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 12h,13h,14h,15h,00h,0Dh,64h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 12h,13h,14h,15h,00h,0Dh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 64h,65h,66h,67h,4Dh,0BFh,0C0h,0C1h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 64h,65h,68h,67h,0BEh,0BFh,0C2h,0C1h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,80h,81h,82h,73h,74h,75h,76h
	defb 00h,00h,00h,00h,00h,0F6h,00h,00h,00h,00h,00h,00h,00h,00h,00h,5Ah
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,5Fh,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,5Ah,00h,00h,5Fh
	defb 00h,00h,0BCh,00h,0BDh,02h,05h,02h,03h,04h,06h,04h,00h,00h,00h,00h
	defb 00h,0BEh,00h,00h,07h,0Ah,07h,0BFh,09h,0Bh,09h,08h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,0BCh,00h,0BDh,02h,05h,02h,03h,04h,06h,04h
	defb 00h,00h,00h,00h,00h,0BEh,00h,00h,07h,0Ah,07h,0BFh,09h,0Bh,09h,08h
	defb 45h,46h,45h,46h,00h,00h,00h,45h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 45h,46h,45h,46h,46h,45h,46h,45h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 45h,46h,45h,46h,46h,45h,46h,45h,45h,46h,45h,46h,00h,45h,46h,00h	; "EFEFFEFEEFEF.EF."
	defb 45h,46h,45h,46h,46h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,45h,46h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,47h,48h,49h,47h,44h,44h,44h,44h
	defb 00h,00h,45h,46h,47h,48h,49h,45h,48h,49h,00h,00h,44h,44h,00h,00h
	defb 45h,46h,00h,00h,46h,47h,48h,49h,00h,00h,47h,48h,00h,00h,44h,44h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,49h,47h,48h,49h,44h,44h,44h,44h
	defb 44h,44h,44h,44h,45h,46h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 44h,44h,00h,00h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,44h,44h,00h,00h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,0AEh,00h,00h,0AEh,0AFh,00h,00h,00h,45h,00h,00h,45h,46h
	defb 00h,00h,47h,48h,00h,00h,45h,46h,00h,00h,00h,45h,00h,00h,00h,00h
	defb 00h,00h,00h,45h,00h,00h,00h,47h,00h,00h,00h,45h,00h,00h,45h,46h
	defb 0AFh,0AEh,0AFh,00h,0AEh,0AFh,0AEh,0AFh,46h,45h,46h,45h,45h,46h,45h,46h
	defb 49h,45h,46h,45h,45h,46h,45h,46h,46h,45h,46h,45h,00h,47h,48h,49h	; "IEFEEFEFFEFE.GHI"
	defb 46h,45h,46h,00h,48h,49h,45h,46h,46h,45h,46h,45h,45h,46h,45h,46h	; "FEF.HIEFFEFEEFEF"
	defb 00h,00h,00h,00h,00h,00h,00h,00h,46h,00h,00h,00h,45h,46h,45h,46h
	defb 46h,45h,46h,47h,45h,46h,00h,00h,46h,00h,00h,00h,00h,00h,00h,00h
	defb 48h,49h,47h,48h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 49h,47h,48h,49h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,45h,46h,45h,46h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,44h,44h,44h,44h
	defb 47h,48h,49h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 47h,48h,49h,45h,00h,47h,48h,49h,00h,45h,46h,45h,00h,00h,45h,46h	; "GHIE.GHI.EFE..EF"
	defb 44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h	; "DDDDDDDDDDDDDDDD"
	defb 46h,47h,48h,49h,47h,48h,49h,00h,46h,45h,46h,00h,45h,46h,00h,00h	; "FGHIGHI.FEF.EF.."
	defb 00h,45h,46h,45h,00h,00h,45h,46h,00h,45h,46h,45h,45h,46h,45h,46h	; ".EFE..EF.EFEEFEF"
	defb 46h,45h,46h,00h,45h,46h,00h,00h,46h,45h,46h,00h,45h,46h,45h,46h	; "FEF.EF..FEF.EFEF"
	defb 48h,49h,47h,48h,00h,44h,44h,44h,00h,44h,44h,44h,00h,44h,44h,44h	; "HIGH.DDD.DDD.DDD"
	defb 49h,47h,48h,49h,44h,44h,44h,00h,44h,44h,44h,00h,44h,44h,44h,00h	; "IGHIDDD.DDD.DDD."
	defb 00h,00h,45h,46h,00h,45h,46h,45h,00h,47h,48h,49h,47h,48h,49h,45h	; "..EF.EFE.GHIGHIE"
	defb 45h,46h,00h,00h,46h,45h,46h,00h,47h,48h,49h,00h,46h,47h,48h,49h	; "EF..FEF.GHI.FGHI"
	defb 44h,44h,44h,44h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 45h,46h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 46h,45h,46h,45h,45h,46h,45h,46h,46h,45h,46h,45h,45h,46h,45h,46h	; "FEFEEFEFFEFEEFEF"
	defb 47h,48h,49h,00h,45h,46h,45h,46h,47h,48h,49h,00h,45h,46h,45h,46h	; "GHI.EFEFGHI.EFEF"
	defb 00h,00h,00h,00h,44h,44h,44h,44h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 47h,48h,49h,00h,45h,46h,45h,46h,44h,44h,44h,44h,44h,44h,44h,44h	; "GHI.EFEFDDDDDDDD"
	defb 46h,45h,46h,00h,45h,46h,00h,00h,46h,00h,00h,00h,00h,00h,00h,00h
	defb 47h,48h,49h,45h,00h,47h,48h,49h,00h,45h,46h,45h,00h,00h,0AEh,0AFh
	defb 46h,47h,48h,49h,47h,48h,49h,00h,46h,45h,46h,00h,0AEh,0AFh,00h,00h
	defb 00h,47h,48h,49h,45h,46h,45h,46h,00h,47h,48h,49h,45h,46h,45h,46h	; ".GHIEFEF.GHIEFEF"
	defb 00h,00h,45h,46h,00h,45h,46h,45h,45h,46h,45h,46h,47h,48h,49h,00h	; "..EF.EFEEFEFGHI."
	defb 45h,46h,45h,46h,46h,47h,48h,49h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 45h,46h,45h,46h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h	; "EFEFDDDDDDDDDDDD"
	defb 44h,44h,44h,44h,44h,44h,45h,46h,44h,45h,46h,45h,45h,46h,45h,46h	; "DDDDDDEFDEFEEFEF"
	defb 45h,46h,45h,46h,45h,46h,00h,00h,46h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,46h,00h,00h,00h,47h,48h,49h,00h,00h,47h,48h,49h
	defb 00h,00h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,00h,00h,00h,00h,00h,45h,46h,45h,46h,44h,44h,44h,44h
	defb 44h,44h,44h,44h,44h,44h,44h,44h,45h,46h,45h,46h,44h,44h,44h,44h	; "DDDDDDDDEFEFDDDD"
	defb 46h,47h,48h,49h,45h,46h,45h,46h,46h,47h,48h,49h,45h,46h,45h,46h	; "FGHIEFEFFGHIEFEF"
	defb 00h,47h,48h,49h,00h,00h,45h,46h,00h,00h,47h,48h,00h,00h,00h,45h
	defb 45h,46h,45h,46h,45h,46h,45h,46h,49h,47h,48h,49h,46h,47h,48h,49h	; "EFEFEFEFIGHIFGHI"
	defb 00h,00h,00h,45h,0AEh,0AFh,0AEh,0AFh,00h,00h,00h,00h,00h,00h,00h,00h
	defb 46h,45h,46h,45h,0AEh,0AFh,0AEh,0AFh,00h,00h,00h,00h,00h,00h,00h,00h
	defb 46h,44h,44h,44h,44h,44h,44h,44h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 0AFh,44h,44h,44h,45h,46h,44h,44h,46h,45h,46h,44h,45h,46h,44h,44h	; ".DDDEFDDFEFDEFDD"
	defb 46h,45h,46h,44h,45h,46h,44h,44h,46h,44h,44h,44h,44h,44h,44h,44h	; "FEFDEFDDFDDDDDDD"
	defb 44h,44h,00h,00h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h	; "DD..DDDDDDDDDDDD"
	defb 00h,00h,00h,00h,00h,00h,00h,00h,44h,44h,00h,00h,44h,44h,44h,44h
	defb 44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,00h,00h	; "DDDDDDDDDDDDDD.."
	defb 44h,44h,44h,44h,44h,44h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h	; "..DDDDDDDDDDDDDD"
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,44h,44h,44h,44h,44h,44h
	defb 45h,46h,45h,46h,45h,46h,44h,44h,46h,44h,44h,44h,44h,44h,44h,44h	; "EFEFEFDDFDDDDDDD"
	defb 44h,44h,44h,44h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 44h,44h,44h,44h,44h,44h,44h,44h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,0AEh,00h,00h,0AEh,0AFh,00h,00h,00h,00h,00h,00h,00h,00h
	defb 0AFh,0AEh,0AFh,00h,0AEh,0AFh,0AEh,0AFh,00h,00h,00h,00h,00h,00h,00h,00h
	defb 44h,44h,44h,45h,44h,44h,45h,46h,44h,45h,46h,45h,44h,44h,45h,46h	; "DDDEDDEFDEFEDDEF"
	defb 44h,44h,44h,44h,45h,46h,45h,46h,46h,45h,46h,00h,45h,46h,00h,00h	; "DDDDEFEFFEF.EF.."
	defb 0AFh,00h,00h,00h,45h,46h,00h,00h,46h,45h,46h,00h,45h,46h,00h,00h
	defb 45h,46h,45h,46h,00h,00h,00h,00h,00h,45h,46h,45h,45h,46h,45h,46h
	defb 45h,46h,45h,46h,00h,47h,48h,49h,47h,48h,49h,44h,45h,46h,44h,44h	; "EFEF.GHIGHIDEFDD"
	defb 45h,46h,45h,46h,44h,44h,44h,44h,44h,44h,44h,44h,45h,46h,45h,46h	; "EFEFDDDDDDDDEFEF"
	defb 00h,00h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 44h,44h,44h,44h,00h,00h,00h,00h,46h,47h,48h,49h,00h,00h,00h,00h
	defb 00h,00h,44h,44h,00h,00h,47h,48h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 00h,00h,00h,45h,00h,00h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 44h,44h,44h,00h,49h,45h,46h,00h,47h,48h,49h,00h,45h,46h,45h,46h	; "DDD.IEF.GHI.EFEF"
	defb 44h,44h,44h,44h,44h,44h,44h,44h,0AEh,0AFh,0AEh,0AFh,0AEh,0AFh,0AEh,0AFh
	defb 0AEh,0AFh,0AEh,0AFh,00h,45h,46h,45h,00h,00h,45h,46h,00h,00h,00h,45h
	defb 45h,46h,45h,46h,46h,45h,46h,47h,45h,46h,00h,00h,46h,00h,00h,00h
	defb 45h,46h,45h,46h,48h,49h,00h,00h,00h,00h,00h,00h,00h,45h,46h,45h
	defb 45h,46h,45h,46h,00h,00h,00h,00h,00h,45h,46h,00h,46h,45h,46h,45h
	defb 45h,46h,45h,46h,00h,00h,47h,48h,00h,00h,00h,00h,46h,45h,46h,00h
	defb 45h,46h,45h,46h,49h,45h,46h,45h,00h,00h,45h,46h,00h,00h,00h,45h
	defb 45h,46h,45h,46h,46h,45h,46h,00h,45h,46h,00h,00h,46h,00h,00h,00h
	defb 47h,48h,49h,00h,00h,47h,48h,49h,00h,47h,48h,49h,47h,48h,49h,00h	; "GHI..GHI.GHIGHI."
	defb 00h,47h,48h,49h,45h,46h,45h,46h,44h,44h,44h,44h,45h,46h,45h,46h	; ".GHIEFEFDDDDEFEF"
	defb 45h,46h,45h,46h,46h,47h,48h,49h,44h,44h,44h,44h,44h,44h,44h,44h	; "EFEFFGHIDDDDDDDD"
	defb 44h,44h,44h,44h,45h,46h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	defb 47h,48h,49h,44h,45h,46h,44h,44h,46h,44h,44h,44h,44h,44h,44h,44h	; "GHIDEFDDFDDDDDDD"
	defb 45h,46h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h,44h	; "EFDDDDDDDDDDDDDD"
	defb 45h,46h,45h,46h,47h,48h,49h,00h,45h,46h,00h,00h,47h,48h,49h,00h	; "EFEFGHI.EF..GHI."
	defb 44h,44h,44h,44h,46h,44h,44h,44h,00h,00h,44h,44h,00h,00h,00h,44h
	defb 44h,44h,45h,46h,44h,47h,48h,49h,44h,45h,46h,44h,45h,46h,44h,44h	; "DDEFDGHIDEFDEFDD"
	defb 0AEh,0AFh,0AEh,0AFh,0AEh,0AFh,44h,44h,0AFh,44h,44h,44h,44h,44h,44h,44h
	defb 00h,00h,45h,46h,00h,45h,46h,45h,0AEh,0AFh,0AEh,0AFh,0AEh,0AFh,0AEh,0AFh
	defb 45h,46h,45h,46h,44h,44h,0AEh,0AFh,47h,48h,49h,44h,45h,46h,44h,44h	; "EFEFDD..GHIDEFDD"
	defb 44h,44h,44h,45h,44h,44h,0AEh,0AFh,44h,45h,46h,45h,44h,44h,45h,46h	; "DDDEDD..DEFEDDEF"
	defb 46h,00h,00h,00h,0AEh,0AFh,00h,00h,46h,45h,46h,00h,45h,46h

	end

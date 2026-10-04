; MSX BIOS entry points called by the cartridge.

ENASLT   equ	0024h	; Switches to specified slot and page definitively
FILVRM   equ	0056h	; Fills VRAM with value
LDIRMV   equ	0059h	; Block transfers to memory from VRAM
LDIRVM   equ	005Ch	; Block transfers to VRAM from memory
RDPSG    equ	0096h	; Reads value from PSG-register
RDSLT    equ	000Ch	; Reads the value of an address in another slot
RDVDP    equ	013Eh	; Reads VDP status register
RSLREG   equ	0138h	; Reads the primary slot register
SETWRT   equ	0053h	; Enables VDP to write
SNSMAT   equ	0141h	; Returns the value of the specified line from the keyboard matrix
WRTPSG   equ	0093h	; Writes data to PSG-register
WRTVDP   equ	0047h	; Writes data in the VDP-register
WRTVRM   equ	004Dh	; Writes data in VRAM

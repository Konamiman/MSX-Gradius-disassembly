; ==========================================================================
; NEMESIS / GRADIUS - Konami (1986) - MSX1 - MegaROM RC-742 de 128 KB (Konami4) - banco 05 (se ejecuta en 0x8000)
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x08000


; ----------------------------------------------------------------------
; DATOS graficos_cadena_8000: Cadena de 20 bloques comprimidos que encajan sin
;   holgura, del 0x8000 al 0x86BA. Los piden las fichas de este mismo banco.
;   0x8000..0x86bb  (1723 bytes)

; ----------------------------------------------------------------------
; GRAFICOS Y FICHAS DE CARGA (banco 5)
; ----------------------------------------------------------------------
DATA_graficos_cadena_8000:
	defb 0eeh,084h,0feh,0f5h,0f5h,050h,005h,0e0h,002h,0e5h,002h,0feh,016h,0e0h,088h,0f0h	; 8000  .....P..........
	defb 0f5h,0e0h,0e0h,0feh,0feh,0f5h,0f5h,006h,0f0h,081h,0f5h,006h,0f0h,002h,0f5h,087h	; 8010  ................
	defb 0ffh,0f5h,0f5h,0feh,0ffh,0f5h,0f5h,004h,0f0h,004h,0e0h,002h,0e5h,002h,0feh,008h	; 8020  ................
	defb 0e0h,003h,070h,002h,050h,002h,070h,081h,0e0h,003h,050h,087h,040h,050h,070h,0f0h	; 8030  ..p.P.p...P.@Pp.
	defb 0f0h,0e0h,0e0h,005h,0f0h,004h,0f5h,007h,0f0h,002h,0f5h,004h,0f0h,002h,0f5h,007h	; 8040  ................
	defb 0f0h,003h,0f5h,004h,0f0h,002h,0feh,081h,0f5h,005h,0f0h,006h,0e0h,002h,0e5h,085h	; 8050  ................
	defb 0e0h,070h,070h,050h,050h,003h,070h,002h,0f0h,08eh,070h,050h,040h,050h,0e0h,0f0h	; 8060  .ppPP.p...pP@P..
	defb 0f5h,0f0h,0f0h,0f5h,0e5h,0e0h,0f0h,0f0h,003h,0f5h,002h,0f0h,003h,0f5h,002h,0f0h	; 8070  ................
	defb 002h,0f5h,003h,0f0h,081h,0ffh,009h,0f0h,087h,0f5h,0ffh,0ffh,0f5h,0f5h,050h,050h	; 8080  ..............PP
	defb 008h,0f5h,002h,0e5h,006h,0e0h,081h,0f5h,007h,0e0h,083h,0f5h,0e5h,0e5h,005h,0e0h	; 8090  ................
	defb 002h,0f5h,081h,050h,005h,0e0h,083h,0f0h,0ffh,0ffh,003h,0f0h,002h,0f5h,081h,0f0h	; 80a0  ...P............
	defb 004h,0ffh,081h,0f5h,004h,050h,002h,0f0h,00ah,0f5h,002h,0feh,018h,0e0h,004h,050h	; 80b0  .....P.........P
	defb 084h,0f5h,0feh,0eeh,0eeh,003h,0f5h,002h,0feh,00bh,0e0h,000h,090h,0ffh,0f0h,0f0h	; 80c0  ................
	defb 0f0h,060h,060h,0f6h,098h,098h,096h,060h,060h,000h,0f0h,0f0h,0f0h,000h,090h,0ffh	; 80d0  .``....``.......
	defb 0f0h,0f0h,0f0h,040h,040h,0f4h,075h,075h,074h,040h,040h,000h,0f0h,0f0h,0f0h,000h	; 80e0  ...@@.uut@@.....
	defb 088h,0e0h,0e0h,0e4h,074h,0e4h,0e4h,0f4h,0f4h,003h,0e0h,002h,074h,003h,0f4h,000h	; 80f0  ....t.......t...
	defb 081h,0f4h,003h,074h,002h,0e4h,081h,0f0h,004h,0e0h,002h,074h,005h,0f4h,003h,0e4h	; 8100  ...t.......t....
	defb 086h,074h,070h,000h,0f4h,0e4h,074h,006h,0f4h,007h,074h,002h,0f4h,002h,0e4h,084h	; 8110  .tp...t...t.....
	defb 074h,0e4h,0e0h,0e0h,003h,0f4h,002h,074h,004h,0e0h,083h,0f0h,0e4h,0e4h,003h,074h	; 8120  t......t.......t
	defb 002h,0f4h,081h,0f0h,004h,0e0h,004h,0f0h,002h,0e4h,003h,074h,002h,0f4h,003h,074h	; 8130  ...........t...t
	defb 002h,0e4h,081h,0f0h,004h,0e0h,002h,074h,006h,0f4h,002h,074h,003h,0e0h,003h,0f4h	; 8140  .......t...t....
	defb 085h,074h,0f4h,0e4h,0e7h,0e0h,004h,074h,002h,0e4h,004h,0e0h,089h,074h,0e4h,0e4h	; 8150  .t.....t.....t..
	defb 0f4h,0f4h,074h,0f4h,0e4h,074h,006h,0f4h,00bh,074h,081h,0e4h,003h,0e0h,007h,074h	; 8160  ..t..t...t.....t
	defb 081h,0f4h,000h,002h,0e0h,084h,0e4h,074h,0e4h,0e4h,004h,0f4h,002h,0e4h,081h,074h	; 8170  .......t.......t
	defb 003h,0e4h,081h,074h,003h,0f4h,002h,0e4h,002h,074h,08ch,040h,0e4h,0e4h,0f4h,074h	; 8180  ...t.....t.@...t
	defb 0e4h,0e4h,0f4h,0f4h,0e4h,074h,0e4h,003h,074h,088h,0e4h,0f4h,0e4h,0e4h,074h,0f4h	; 8190  .....t..t.....t.
	defb 0e0h,0e0h,003h,040h,003h,0e0h,002h,0e4h,081h,0f4h,003h,0e4h,085h,074h,0e4h,0e4h	; 81a0  ...@.........t..
	defb 0f4h,0f4h,004h,0e0h,003h,0e4h,081h,074h,000h,084h,0f0h,070h,0e0h,0e0h,004h,070h	; 81b0  .......t...p...p
	defb 08bh,040h,0e0h,0e0h,0f0h,070h,0e4h,0e4h,0f4h,0f4h,0e4h,0e4h,003h,0e0h,002h,040h	; 81c0  .@...p.........@
	defb 006h,0e0h,086h,0f0h,0f4h,0f0h,070h,0e0h,0e0h,004h,070h,08bh,040h,0e0h,0e0h,0f0h	; 81d0  ......p...p.@...
	defb 070h,0e4h,0e4h,0f4h,0f4h,0e4h,0e4h,003h,0e0h,002h,040h,006h,0e0h,082h,0f0h,0f4h	; 81e0  p.........@.....
	defb 000h,017h,0b0h,083h,0a6h,0b0h,0b0h,006h,060h,015h,0b0h,083h,060h,0a6h,0a9h,00ah	; 81f0  ........`...`...
	defb 0b0h,004h,060h,002h,096h,014h,0b0h,003h,060h,081h,096h,003h,0b0h,002h,0a6h,003h	; 8200  ..`.....`.......
	defb 096h,002h,0a6h,002h,060h,01ch,0b0h,002h,096h,002h,0a6h,002h,060h,002h,0b0h,002h	; 8210  ....`.......`...
	defb 096h,003h,060h,013h,0b0h,002h,060h,006h,0b0h,002h,096h,003h,0a6h,003h,0b0h,005h	; 8220  ..`...`.........
	defb 096h,083h,0a6h,060h,060h,008h,096h,081h,0a6h,07fh,096h,03dh,096h,033h,060h,000h	; 8230  ...``......=.3`.
	defb 082h,000h,070h,007h,040h,091h,077h,044h,000h,074h,000h,055h,044h,000h,077h,044h	; 8240  ..p.@.wD.t.UD.wD
	defb 000h,074h,000h,050h,044h,000h,070h,00ch,040h,081h,054h,007h,040h,082h,054h,040h	; 8250  .t.PD.p.@.T.@.T@
	defb 000h,086h,040h,070h,040h,0e0h,0f0h,0e0h,004h,040h,084h,070h,0f0h,070h,050h,004h	; 8260  ..@p@....@.p.pP.
	defb 040h,084h,077h,0ffh,077h,055h,005h,040h,082h,077h,055h,00bh,040h,081h,050h,006h	; 8270  @.w.wU.@.wU.@.P.
	defb 040h,081h,050h,011h,040h,084h,0f0h,070h,050h,070h,005h,040h,002h,0f4h,002h,074h	; 8280  @.P.@..pPp.@...t
	defb 002h,040h,087h,077h,074h,074h,000h,077h,074h,074h,006h,070h,002h,074h,002h,000h	; 8290  .@.wtt.wtt.p.t..
	defb 002h,074h,088h,077h,000h,074h,074h,077h,000h,074h,074h,005h,070h,008h,040h,008h	; 82a0  .t.w.ttw.tt.p.@.
	defb 080h,000h,018h,0b0h,000h,028h,0b0h,000h,004h,0b0h,084h,060h,060h,096h,098h,020h	; 82b0  .....(.....``..
	defb 0b0h,000h,006h,050h,004h,070h,004h,050h,002h,070h,000h,002h,070h,004h,080h,004h	; 82c0  ...P.p.P.p..p...
	defb 090h,004h,080h,002h,090h,000h,004h,070h,003h,050h,0a1h,070h,000h,050h,050h,040h	; 82d0  .......p.P.p.PP@
	defb 040h,040h,050h,050h,074h,074h,080h,0b9h,0b9h,084h,084h,064h,075h,085h,094h,090h	; 82e0  @@PPtt.....du...
	defb 080h,000h,040h,040h,065h,0f5h,095h,094h,094h,000h,0f4h,0f4h,000h,004h,090h,003h	; 82f0  ..@@e...........
	defb 080h,0a1h,090h,000h,080h,080h,060h,060h,060h,080h,080h,096h,096h,0d0h,0bah,0bah	; 8300  ......```.......
	defb 0d6h,0d6h,086h,098h,0d8h,0a6h,0a0h,0d0h,000h,060h,060h,088h,0f8h,0a8h,0a6h,0a6h	; 8310  .........``.....
	defb 000h,0f6h,0f6h,000h,088h,0f4h,0e0h,0f0h,0f7h,050h,0f0h,050h,050h,003h,040h,093h	; 8320  .........P.PP.@.
	defb 070h,075h,040h,040h,074h,070h,0e0h,0f0h,0f0h,070h,0f0h,070h,0f7h,0e5h,050h,040h	; 8330  pu@@tp...p.p..P@
	defb 040h,070h,050h,006h,040h,088h,0f0h,040h,0f0h,0f7h,0e4h,040h,050h,070h,008h,040h	; 8340  @pP.@..@...@Pp.@
	defb 087h,070h,0f0h,070h,0f7h,0e4h,040h,070h,005h,040h,006h,070h,083h,0f0h,0f7h,0e5h	; 8350  .p.p..@p.@.p....
	defb 007h,040h,000h,0a0h,000h,0f0h,0e0h,0f0h,0e0h,0a0h,0a0h,0b0h,000h,0f0h,0e0h,0f0h	; 8360  .@..............
	defb 0e0h,0a0h,0a0h,0b0h,0b0h,0a0h,0a0h,0e0h,0f0h,0e0h,0f0h,000h,0b0h,0a0h,0a0h,0e0h	; 8370  ................
	defb 0f0h,0e0h,0f0h,000h,000h,0a0h,000h,0f0h,0e0h,0f0h,0e0h,0c0h,020h,030h,000h,0f0h	; 8380  ............ 0..
	defb 0e0h,0f0h,0e0h,0c0h,020h,030h,030h,020h,0c0h,0e0h,0f0h,0e0h,0f0h,000h,030h,020h	; 8390  .... 00 ......0
	defb 0c0h,0e0h,0f0h,0e0h,0f0h,000h,000h,09ch,000h,070h,030h,0b0h,0f0h,0b0h,030h,070h	; 83a0  .........p0...0p
	defb 000h,070h,030h,0b0h,0f0h,0b0h,030h,070h,000h,070h,030h,0b0h,0f0h,0b0h,030h,070h	; 83b0  .p0...0p.p0...0p
	defb 0f0h,0b0h,030h,070h,009h,000h,08bh,070h,030h,0b0h,000h,070h,030h,0b0h,0f0h,0b0h	; 83c0  ..0p...p0..p0...
	defb 030h,070h,003h,000h,083h,0b0h,0f0h,0b0h,004h,000h,090h,030h,0b0h,0f0h,0b0h,030h	; 83d0  0p.........0...0
	defb 000h,000h,070h,030h,0b0h,0f0h,0b0h,030h,070h,030h,070h,009h,000h,08bh,070h,030h	; 83e0  ..p0...0p0p...p0
	defb 0b0h,0f0h,0b0h,030h,0b0h,0f0h,0b0h,030h,070h,009h,000h,081h,070h,005h,000h,003h	; 83f0  ...0...0p...p...
	defb 0e0h,086h,000h,0e0h,050h,070h,0f0h,0e0h,004h,0f0h,084h,0f4h,0f5h,0f5h,0f4h,00ah	; 8400  ....Pp..........
	defb 0f0h,003h,0e0h,005h,000h,002h,0f0h,086h,0e0h,0f0h,070h,050h,0e0h,000h,000h,090h	; 8410  ..........pP....
	defb 000h,038h,067h,068h,071h,073h,067h,067h,000h,01ch,0e6h,016h,08eh,0ceh,0e6h,0e6h	; 8420  .8ghqsgg........
	defb 003h,000h,08dh,0fch,0aah,0f0h,000h,000h,002h,004h,008h,030h,060h,01dh,05dh,05dh	; 8430  ...........0`.]]
	defb 003h,000h,081h,0edh,004h,06dh,09fh,00ah,0abh,00bh,000h,000h,038h,084h,0c1h,000h	; 8440  .....m......8...
	defb 07fh,0beh,01dh,00bh,047h,08eh,01ch,063h,071h,068h,07eh,000h,07fh,000h,07fh,06dh	; 8450  ....G..cqh~....m
	defb 06dh,0edh,06dh,000h,0d0h,0d0h,006h,000h,0afh,003h,00ch,030h,000h,007h,01fh,007h	; 8460  m.m........0....
	defb 03fh,0c0h,001h,0c2h,0bfh,0deh,0efh,0f7h,0f6h,0f7h,080h,04fh,0a2h,070h,0fch,006h	; 8470  ?..........O.p..
	defb 018h,0e0h,000h,0feh,0c0h,000h,080h,0c0h,060h,030h,098h,0cch,0fch,0d0h,008h,0fch	; 8480  ........`0......
	defb 0fch,042h,0beh,069h,080h,036h,06ch,000h,004h,066h,084h,080h,036h,06ch,000h,004h	; 8490  .B.i.6l..f..6l..
	defb 006h,083h,080h,036h,06ch,005h,000h,000h,084h,03fh,0ffh,0ffh,03fh,004h,000h,004h	; 84a0  ...6l....?..?...
	defb 0f3h,008h,000h,084h,003h,00fh,03eh,0fdh,006h,000h,082h,003h,00fh,005h,000h,0b6h	; 84b0  ......>.........
	defb 007h,080h,038h,000h,001h,002h,004h,000h,010h,000h,000h,0c6h,08eh,016h,07eh,000h	; 84c0  ..8...........~.
	defb 0feh,000h,05dh,000h,0fch,078h,07dh,07eh,07ch,000h,03bh,05dh,01ch,05eh,0afh,0d3h	; 84d0  ..]..x}~|.;].^..
	defb 069h,034h,01ah,03ch,07ah,0f7h,0eeh,0dch,081h,07fh,000h,03fh,07fh,000h,057h,0d7h	; 84e0  i4.<z......?..W.
	defb 0d7h,080h,000h,05dh,05dh,000h,003h,0f7h,0efh,003h,001h,000h,07fh,03eh,081h,09ch	; 84f0  ...]]........>..
	defb 0ceh,0e7h,0f0h,000h,03fh,080h,0cfh,0e0h,073h,038h,000h,080h,0f0h,081h,0fch,086h	; 8500  ....?...s8......
	defb 0f3h,099h,00ch,07dh,0a0h,063h,07dh,038h,071h,0c3h,0a2h,0f0h,007h,05ch,058h,001h	; 8510  ...}.c}8q....\X.
	defb 043h,083h,085h,000h,000h,03ch,000h,07eh,03ch,018h,03ch,0f8h,00ch,006h,002h,083h	; 8520  C....<.~<.<.....
	defb 0c1h,0c1h,0a1h,0e0h,07fh,000h,000h,075h,015h,015h,0d5h,07fh,07fh,000h,0beh,080h	; 8530  .......u........
	defb 0beh,080h,0beh,000h,0c0h,03ch,001h,03fh,070h,01fh,03fh,0f0h,007h,05ch,058h,001h	; 8540  .....<.?p.?..\X.
	defb 043h,083h,085h,000h,000h,03ch,000h,07eh,03ch,018h,03ch,0f8h,00ch,006h,002h,083h	; 8550  C....<.~<.<.....
	defb 0c1h,0c1h,0a1h,07dh,0a0h,063h,07dh,038h,003h,000h,089h,0f0h,007h,05ch,058h,000h	; 8560  ...}.c}8.....\X.
	defb 040h,080h,000h,0ffh,007h,000h,085h,0f8h,00ch,006h,002h,003h,003h,001h,000h,002h	; 8570  @...............
	defb 040h,08eh,050h,040h,040h,050h,070h,0f0h,040h,040h,050h,040h,040h,050h,070h,0f0h	; 8580  @.P@@Pp.@@P@@Pp.
	defb 004h,040h,085h,080h,0c5h,044h,055h,080h,005h,040h,082h,070h,0e0h,004h,040h,087h	; 8590  .@...DU..@.p..@.
	defb 050h,070h,0e0h,0f0h,060h,090h,060h,003h,040h,081h,070h,004h,040h,002h,050h,003h	; 85a0  Pp..`.`.@.p.@.P.
	defb 040h,08eh,0e0h,050h,040h,0e5h,055h,070h,040h,0d0h,0e0h,070h,050h,040h,010h,070h	; 85b0  @..P@.Up@..pP@.p
	defb 004h,050h,004h,020h,005h,040h,087h,054h,050h,040h,050h,054h,040h,040h,003h,050h	; 85c0  .P. .@.TP@PT@@.P
	defb 081h,070h,003h,040h,002h,050h,085h,075h,074h,074h,050h,050h,008h,040h,09ah,0e0h	; 85d0  .p.@.P.uttPP.@..
	defb 050h,070h,040h,070h,040h,040h,0e6h,040h,050h,040h,040h,050h,070h,0e0h,0f0h,040h	; 85e0  Pp@p@@.@P@@Pp..@
	defb 050h,040h,040h,050h,070h,0e0h,0f0h,040h,050h,006h,040h,000h,083h,040h,0f0h,070h	; 85f0  P@@Pp..@P.@..@.p
	defb 006h,040h,082h,0f0h,070h,00dh,040h,007h,070h,081h,040h,006h,020h,003h,070h,081h	; 8600  .@..p.@.p.@. .p.
	defb 050h,003h,040h,003h,050h,08dh,0e0h,050h,040h,0e5h,055h,070h,010h,0d0h,077h,040h	; 8610  P.@.P..P@.Up..w@
	defb 070h,040h,050h,003h,040h,083h,0f0h,070h,050h,003h,040h,082h,050h,070h,007h,040h	; 8620  p@P.@..pP.@.Pp.@
	defb 086h,044h,0a9h,060h,010h,070h,050h,003h,040h,085h,0a0h,060h,010h,070h,050h,005h	; 8630  .D.`.pP.@..`.pP.
	defb 040h,082h,050h,060h,005h,040h,0a7h,090h,040h,080h,040h,060h,040h,040h,050h,094h	; 8640  @.P`.@..@.@`@@P.
	defb 050h,080h,050h,060h,050h,040h,0e0h,050h,055h,0e0h,070h,040h,040h,0e5h,0e0h,050h	; 8650  P.P`P@.PU.p@@..P
	defb 040h,050h,060h,060h,080h,090h,0eeh,000h,060h,066h,086h,098h,0f9h,0f9h,004h,0e0h	; 8660  @P``....`f......
	defb 002h,060h,0aah,080h,090h,075h,070h,000h,000h,040h,050h,070h,0f0h,040h,070h,000h	; 8670  .`...up..@Pp.@p.
	defb 040h,040h,050h,070h,0b0h,0eeh,0a5h,040h,040h,050h,070h,085h,094h,0e0h,050h,040h	; 8680  @@Pp...@@Pp...P@
	defb 050h,040h,040h,050h,070h,0eeh,010h,040h,044h,054h,075h,0f7h,0f7h,004h,0e0h,002h	; 8690  P@@Pp..@DTu.....
	defb 040h,087h,050h,070h,0e0h,050h,055h,0e0h,070h,004h,0e0h,087h,050h,040h,050h,040h	; 86a0  @.Pp.PU.p...P@P@
	defb 040h,050h,070h,00ch,0e0h,002h,040h,082h,050h,070h,000h	; 86b0  @Pp...@.Pp.

; ----------------------------------------------------------------------
; DATOS graficos_por_fase: Siete bloques comprimidos seguidos (0x86BB, 0x8A8C,
;   0x8C1E, 0x8D27, 0x8E4B, 0x8ECA, 0x8F3E). Los reparte la tabla 0x42B3 del
;   banco 0: dos bloques por fase, cada uno con el indice de caracter donde
;   empieza.
;   0x86bb..0x8fcb  (2320 bytes)
DATA_graficos_por_fase:
	defb 086h,000h,080h,0e0h,070h,07fh,07fh,003h,0bfh,082h,078h,0e0h,00ah,000h,083h,088h	; 86bb  ....p.....x.....
	defb 0ffh,0f8h,01ch,000h,082h,0c0h,070h,00dh,000h,084h,0b0h,0fch,07fh,07fh,003h,0bfh	; 86cb  ......p.........
	defb 083h,07fh,078h,0e0h,008h,000h,085h,080h,018h,08fh,0fch,0e0h,01ch,000h,082h,0e0h	; 86db  ..x.............
	defb 070h,009h,000h,086h,080h,0e0h,070h,0ffh,01fh,001h,00dh,000h,083h,080h,0f0h,0ffh	; 86eb  p.....p.........
	defb 00eh,000h,086h,0e0h,0feh,07fh,03fh,01eh,018h,00ch,000h,082h,0fch,0f0h,007h,000h	; 86fb  ......?.........
	defb 087h,003h,007h,002h,000h,030h,070h,020h,019h,000h,083h,0beh,0bfh,0beh,01dh,000h	; 870b  .....0p ........
	defb 087h,020h,060h,0d8h,03ch,01eh,00eh,002h,01fh,000h,082h,0e0h,070h,008h,000h,090h	; 871b  . `.<.......p...
	defb 066h,099h,081h,05ah,05ah,081h,099h,066h,066h,099h,081h,05ah,05ah,081h,099h,066h	; 872b  f..ZZ..ff..ZZ..f
	defb 006h,000h,082h,0e0h,070h,008h,000h,090h,018h,066h,042h,099h,099h,042h,066h,018h	; 873b  ....p....fB..Bf.
	defb 018h,066h,042h,099h,099h,042h,066h,018h,004h,000h,082h,0c0h,070h,00ah,000h,090h	; 874b  .fB..Bf.....p...
	defb 066h,099h,081h,05ah,05ah,081h,099h,066h,066h,099h,081h,05ah,05ah,081h,099h,066h	; 875b  f..ZZ..ff..ZZ..f
	defb 004h,000h,082h,0c0h,070h,00ah,000h,090h,018h,066h,042h,099h,099h,042h,066h,018h	; 876b  ....p....fB..Bf.
	defb 018h,066h,042h,099h,099h,042h,066h,018h,006h,000h,082h,0e0h,070h,009h,000h,08eh	; 877b  .fB..Bf.....p...
	defb 018h,024h,05ah,05ah,024h,018h,000h,000h,018h,024h,05ah,05ah,024h,018h,007h,000h	; 878b  .$ZZ$....$ZZ$...
	defb 082h,0e0h,070h,009h,000h,08eh,024h,05ah,024h,024h,05ah,024h,000h,000h,024h,05ah	; 879b  ..p...$Z$$Z$..$Z
	defb 024h,024h,05ah,024h,005h,000h,082h,0c0h,070h,00bh,000h,08eh,018h,024h,05ah,05ah	; 87ab  $$Z$....p....$ZZ
	defb 024h,018h,000h,000h,018h,024h,05ah,05ah,024h,018h,005h,000h,082h,0c0h,070h,00bh	; 87bb  $....$ZZ$.....p.
	defb 000h,08eh,024h,05ah,024h,024h,05ah,024h,000h,000h,024h,05ah,024h,024h,05ah,024h	; 87cb  ..$Z$$Z$..$Z$$Z$
	defb 004h,000h,083h,003h,01fh,07fh,004h,0ffh,083h,07fh,01fh,003h,006h,000h,083h,0c0h	; 87db  ................
	defb 0f8h,0feh,004h,0ffh,083h,0feh,0f8h,0c0h,008h,000h,086h,007h,01fh,03fh,03fh,01fh	; 87eb  .............??.
	defb 007h,00ah,000h,086h,0e0h,0f8h,0fch,0fch,0f8h,0e0h,00bh,000h,083h,001h,01fh,001h	; 87fb  ................
	defb 00bh,000h,087h,001h,00eh,0f0h,000h,0f0h,00eh,001h,00ah,000h,085h,001h,00ch,0c0h	; 880b  ................
	defb 00ch,001h,00bh,000h,085h,080h,030h,003h,030h,080h,00ch,000h,083h,003h,03fh,003h	; 881b  ......0.0.....?.
	defb 00dh,000h,083h,0c0h,0fch,0c0h,00dh,000h,083h,007h,03fh,007h,009h,000h,08bh,003h	; 882b  ..........?.....
	defb 01ch,030h,0e0h,080h,000h,080h,0e0h,030h,01ch,003h,006h,000h,089h,003h,00eh,018h	; 883b  .0.....0........
	defb 070h,0e0h,070h,018h,00eh,003h,007h,000h,089h,0c0h,070h,018h,00eh,007h,00eh,018h	; 884b  p.p.......p.....
	defb 070h,0c0h,008h,000h,087h,001h,007h,00fh,01fh,00fh,007h,001h,009h,000h,087h,080h	; 885b  p...............
	defb 0e0h,0f0h,0f8h,0f0h,0e0h,080h,00ah,000h,085h,001h,002h,078h,002h,001h,009h,000h	; 886b  ...........x....
	defb 002h,080h,087h,040h,020h,00fh,020h,040h,080h,080h,00ah,000h,083h,001h,006h,001h	; 887b  ...@ . @........
	defb 00ch,000h,085h,080h,040h,030h,040h,080h,00dh,000h,081h,001h,00eh,000h,083h,080h	; 888b  ....@0@.........
	defb 0c0h,080h,00bh,000h,087h,080h,070h,00fh,000h,00fh,070h,080h,00bh,000h,083h,080h	; 889b  ......p...p.....
	defb 0f8h,080h,009h,000h,08bh,0c0h,038h,00ch,007h,001h,000h,001h,007h,00ch,038h,0c0h	; 88ab  ......8.......8.
	defb 009h,000h,083h,0e0h,0fch,0e0h,007h,000h,0adh,080h,009h,000h,005h,035h,0a1h,01ah	; 88bb  .............5..
	defb 007h,0abh,035h,00bh,035h,014h,063h,000h,010h,010h,080h,002h,000h,030h,052h,0e0h	; 88cb  ..5.5.c......0R.
	defb 0c0h,0c0h,0e0h,0d0h,08ch,028h,026h,000h,040h,000h,004h,004h,000h,018h,019h,001h	; 88db  .....(&.@.......
	defb 001h,00eh,01fh,02fh,01fh,02eh,005h,000h,08ch,080h,058h,0fch,0f4h,0f0h,0f0h,0f6h	; 88eb  .../......X.....
	defb 026h,070h,070h,020h,080h,006h,000h,088h,001h,000h,001h,004h,000h,003h,007h,002h	; 88fb  &pp ............
	defb 00ah,000h,086h,050h,0e0h,040h,010h,040h,040h,00ah,000h,084h,002h,004h,002h,002h	; 890b  ...P.@.@@.......
	defb 00bh,000h,084h,0c0h,020h,080h,020h,007h,000h,084h,060h,0f0h,0f0h,060h,01ch,000h	; 891b  .... . ...`..`..
	defb 0a0h,007h,07fh,00fh,03fh,07fh,0ffh,07fh,072h,072h,07fh,0ffh,07fh,03fh,01fh,077h	; 892b  ....?...rr...?.w
	defb 007h,080h,0f0h,0f8h,0fch,080h,000h,054h,055h,055h,054h,000h,080h,0f8h,0f0h,0e0h	; 893b  .......TUUT.....
	defb 080h,003h,000h,08bh,003h,01fh,0f0h,07fh,0ffh,07fh,07fh,03fh,01fh,00fh,078h,005h	; 894b  ...........?..x.
	defb 000h,08ah,0c0h,0f0h,000h,055h,0d5h,0fch,0fch,0f8h,0f0h,0e0h,007h,000h,087h,01fh	; 895b  .....U..........
	defb 07fh,0ffh,07fh,01fh,000h,0f8h,009h,000h,085h,080h,0c0h,0fdh,0fdh,0f0h,00ah,000h	; 896b  ................
	defb 08bh,007h,0ffh,03fh,07fh,0ffh,070h,077h,0ffh,07fh,01fh,0fch,005h,000h,08ah,0c0h	; 897b  ...?..pw........
	defb 0f0h,0f8h,0fch,080h,055h,055h,0fch,0f8h,0f0h,003h,000h,0ach,003h,07fh,000h,01fh	; 898b  ....UU..........
	defb 07fh,0ffh,07fh,066h,066h,07fh,0ffh,07fh,01fh,000h,07fh,003h,0c0h,0b0h,078h,0fch	; 899b  ...ff.........x.
	defb 084h,000h,054h,055h,055h,054h,000h,084h,0fch,078h,0b0h,0c0h,003h,007h,00fh,01fh	; 89ab  ..TUUT...x......
	defb 000h,02fh,02fh,00fh,00fh,02fh,02fh,000h,004h,033h,08ch,0c0h,0e0h,0f0h,0f8h,000h	; 89bb  .//..//..3......
	defb 074h,068h,01ch,01ch,068h,074h,0c0h,004h,0cch,08ch,003h,007h,00fh,01fh,000h,02eh	; 89cb  th..ht..........
	defb 016h,038h,038h,016h,02eh,003h,004h,033h,08ch,0c0h,0e0h,0f0h,0f8h,000h,0f4h,0f4h	; 89db  .88....3........
	defb 0f0h,0f0h,0f4h,0f4h,000h,004h,0cch,08ch,003h,007h,00fh,01fh,000h,017h,057h,0e7h	; 89eb  ..............W.
	defb 0e7h,057h,017h,000h,004h,01bh,08ch,0c0h,0e0h,0f0h,0f8h,000h,0e8h,0eah,0e7h,0e7h	; 89fb  .W..............
	defb 0eah,0e8h,000h,004h,0d8h,0b2h,003h,007h,00fh,01fh,000h,06eh,0edh,0ebh,0ebh,06dh	; 8a0b  ...........n...m
	defb 00eh,003h,063h,073h,073h,063h,0c0h,0e0h,0f0h,0f8h,000h,076h,0b7h,0d7h,0d7h,0b6h	; 8a1b  ..cssc.....v....
	defb 070h,0c0h,0c6h,0ceh,0ceh,0c6h,000h,00fh,01fh,01fh,07fh,01bh,026h,07eh,07eh,026h	; 8a2b  p...........&~~&
	defb 01bh,07fh,01fh,00fh,007h,000h,0f0h,060h,003h,080h,081h,000h,004h,0d0h,0a1h,000h	; 8a3b  .......`........
	defb 080h,080h,000h,060h,0f0h,004h,00fh,037h,039h,05fh,0efh,06eh,07dh,079h,03ch,03eh	; 8a4b  ...`...79_.n}y<>
	defb 01ch,000h,00eh,007h,000h,000h,080h,0e0h,0f0h,0f4h,076h,026h,082h,0b0h,060h,0c0h	; 8a5b  ..........v&..`.
	defb 006h,000h,08fh,007h,00eh,000h,01ch,03eh,03ch,079h,07dh,06eh,0efh,05fh,039h,037h	; 8a6b  .......><y}n._97
	defb 00fh,004h,005h,000h,08bh,0c0h,060h,0b0h,082h,026h,076h,0f4h,0f0h,0e0h,080h,000h	; 8a7b  ......`..&v.....
	defb 000h,005h,000h,082h,00fh,01fh,003h,03fh,082h,01fh,007h,009h,000h,087h,080h,0e0h	; 8a8b  .......?........
	defb 0b0h,0d8h,0f8h,0f0h,0c0h,006h,000h,0a1h,001h,007h,01fh,07fh,000h,001h,003h,007h	; 8a9b  ................
	defb 01fh,0fbh,0fbh,003h,03fh,000h,07fh,03eh,09eh,08eh,087h,0c3h,07fh,083h,03fh,07fh	; 8aab  ....?..>......?.
	defb 07dh,03ah,084h,0f8h,0ffh,000h,03fh,00fh,003h,004h,000h,0b7h,001h,003h,007h,01fh	; 8abb  }:....?.........
	defb 0fbh,0fbh,003h,03fh,000h,0ffh,0feh,08ch,0e4h,032h,01fh,0ffh,0b3h,039h,07dh,07dh	; 8acb  ...?.....2...9}}
	defb 03bh,086h,0f8h,0ffh,000h,0ffh,07fh,01fh,007h,006h,00dh,019h,019h,018h,014h,01fh	; 8adb  ;...............
	defb 01fh,039h,071h,0e0h,0c0h,0fch,0e0h,0f0h,0f8h,018h,0fdh,0efh,0eeh,0dch,038h,0f0h	; 8aeb  .9q...........8.
	defb 0e0h,0c0h,080h,003h,000h,08dh,03fh,003h,0fbh,0fbh,01fh,007h,003h,001h,000h,07fh	; 8afb  ......?.........
	defb 01fh,007h,001h,003h,000h,098h,0ffh,0f8h,084h,03ah,07dh,07fh,03fh,083h,07fh,0c3h	; 8b0b  .........:}.?...
	defb 087h,08eh,09eh,03eh,07fh,000h,03fh,003h,0fbh,0fbh,01fh,007h,003h,001h,004h,000h	; 8b1b  ...>..?.........
	defb 0d1h,003h,00fh,03fh,000h,0ffh,0f8h,086h,03bh,07dh,07dh,039h,0b3h,0ffh,01fh,032h	; 8b2b  ...?....;}}9...2
	defb 0e4h,08ch,0feh,0ffh,0c0h,0e0h,071h,039h,01fh,01fh,014h,018h,019h,019h,00dh,006h	; 8b3b  ......q9........
	defb 007h,01fh,07fh,0ffh,000h,000h,080h,0c0h,0e0h,0f0h,038h,0dch,0eeh,0efh,0fdh,018h	; 8b4b  ..........8.....
	defb 0f8h,0f0h,0e0h,0fch,000h,0ffh,01fh,021h,05ch,0beh,0feh,0fch,0c1h,0feh,0c3h,0e1h	; 8b5b  .......!\.......
	defb 071h,079h,07ch,0feh,000h,0fch,0c0h,0dfh,0dfh,0f8h,0e0h,0c0h,080h,000h,0feh,0f8h	; 8b6b  qy|.............
	defb 0e0h,080h,003h,000h,098h,0ffh,01fh,061h,0dch,0beh,0beh,09ch,0cdh,0ffh,0f8h,04ch	; 8b7b  .......a.......L
	defb 027h,031h,07fh,0ffh,000h,0fch,0c0h,0dfh,0dfh,0f8h,0e0h,0c0h,080h,004h,000h,0b2h	; 8b8b  '1..............
	defb 0c0h,0f0h,0fch,000h,000h,001h,003h,007h,00fh,01ch,03bh,077h,0f7h,0bfh,018h,01fh	; 8b9b  ..........;w....
	defb 00fh,007h,03fh,003h,007h,08eh,09ch,0f8h,0f8h,028h,018h,098h,098h,0b0h,060h,0e0h	; 8bab  ..?......(....`.
	defb 0f8h,0feh,0ffh,0feh,07ch,079h,071h,0e1h,0c3h,0feh,0c1h,0fch,0feh,0beh,05ch,021h	; 8bbb  ....|yq.......\!
	defb 01fh,0ffh,003h,000h,0a1h,080h,0e0h,0f8h,0feh,000h,080h,0c0h,0e0h,0f8h,0dfh,0dfh	; 8bcb  ................
	defb 0c0h,0fch,000h,0ffh,07fh,031h,027h,04ch,0f8h,0ffh,0cdh,09ch,0beh,0beh,0dch,061h	; 8bdb  .....1'L.......a
	defb 01fh,0ffh,000h,0fch,0f0h,0c0h,004h,000h,0a9h,080h,0c0h,0e0h,0f8h,0dfh,0dfh,0c0h	; 8beb  ................
	defb 0fch,000h,03fh,007h,00fh,01fh,018h,0bfh,0f7h,077h,03bh,01ch,00fh,007h,003h,001h	; 8bfb  ..?......w;.....
	defb 000h,000h,0ffh,0feh,0f8h,0e0h,060h,0b0h,098h,098h,018h,028h,0f8h,0f8h,09ch,08eh	; 8c0b  ......`....(....
	defb 007h,003h,000h,0ffh,000h,001h,00dh,01ch,037h,064h,049h,07bh,07bh,049h,064h,037h	; 8c1b  ........7dI{{Id7
	defb 01ch,00dh,001h,000h,000h,0c0h,0f0h,038h,0c0h,00ch,09eh,0deh,0deh,09eh,00ch,0c0h	; 8c2b  .......8........
	defb 038h,0f0h,0c0h,000h,000h,003h,007h,017h,033h,030h,069h,06bh,06bh,009h,03ch,033h	; 8c3b  8.......30ikk.<3
	defb 019h,00dh,007h,000h,000h,0c0h,0e0h,0e8h,0cch,00ch,096h,0d6h,0d6h,090h,03ch,0cch	; 8c4b  ..............<.
	defb 098h,0b0h,0e0h,000h,000h,003h,00fh,01ch,003h,030h,079h,07bh,07bh,079h,030h,003h	; 8c5b  .........0y{{y0.
	defb 01ch,00fh,003h,000h,000h,080h,0b0h,038h,0ech,026h,092h,0deh,0deh,092h,026h,0ech	; 8c6b  .......8.&....&.
	defb 038h,0b0h,080h,000h,000h,007h,00dh,019h,033h,03ch,009h,06bh,06bh,069h,030h,033h	; 8c7b  8.......3<.kki03
	defb 017h,007h,003h,000h,000h,0e0h,0b0h,098h,0cch,03ch,090h,0d6h,0d6h,096h,00ch,0cch	; 8c8b  .........<......
	defb 0e8h,0e0h,0c0h,004h,000h,08bh,003h,01fh,0f0h,07fh,0ffh,07fh,07fh,03fh,01fh,00fh	; 8c9b  .............?..
	defb 078h,005h,000h,08ah,0c0h,0f0h,000h,055h,0d5h,0fch,0fch,0f8h,0f0h,0e0h,007h,000h	; 8cab  x......U........
	defb 087h,01fh,07fh,0ffh,07fh,01fh,000h,0f8h,009h,000h,085h,080h,0c0h,0fdh,0fdh,0f0h	; 8cbb  ................
	defb 00ah,000h,08bh,007h,0ffh,03fh,07fh,0ffh,070h,077h,0ffh,07fh,01fh,0fch,005h,000h	; 8ccb  .....?..pw......
	defb 08ah,0c0h,0f0h,0f8h,0fch,080h,055h,055h,0fch,0f8h,0f0h,003h,000h,0aeh,003h,07fh	; 8cdb  ......UU........
	defb 000h,01fh,07fh,0ffh,07fh,066h,066h,07fh,0ffh,07fh,01fh,000h,07fh,003h,0c0h,0b0h	; 8ceb  .....ff.........
	defb 078h,0fch,084h,000h,054h,055h,055h,054h,000h,084h,0fch,078h,0b0h,0c0h,000h,000h	; 8cfb  x...TUUT...x....
	defb 00fh,03fh,079h,060h,0e0h,0c0h,0c0h,0e0h,060h,079h,03fh,00fh,005h,000h,08ah,0c0h	; 8d0b  .?y`....`y?.....
	defb 0e0h,060h,070h,030h,030h,070h,060h,0e0h,0c0h,003h,000h,000h,0ffh,000h,003h,006h	; 8d1b  .`p00p`.........
	defb 01eh,033h,021h,071h,051h,05bh,04ah,07eh,027h,034h,01dh,007h,000h,000h,080h,0e0h	; 8d2b  .3!qQ[J~'4......
	defb 03ch,074h,0ceh,01ah,092h,093h,0d9h,04bh,0eeh,0bch,088h,098h,0f0h,000h,003h,006h	; 8d3b  <t.....K........
	defb 006h,01eh,029h,032h,035h,035h,01ah,019h,018h,017h,01fh,00ch,000h,000h,080h,0f8h	; 8d4b  ..)255..........
	defb 07ch,026h,0c2h,026h,0d6h,0d3h,021h,0c7h,00fh,0ceh,0ech,0f8h,070h,000h,001h,003h	; 8d5b  |&.&..!.....p...
	defb 003h,006h,01dh,03ah,035h,035h,01ah,019h,01eh,01fh,01fh,00fh,000h,000h,080h,0c8h	; 8d6b  ...:55..........
	defb 07ch,02eh,0c6h,026h,0d3h,0d1h,027h,0dfh,03eh,0bch,0b8h,0f8h,0f0h,000h,003h,007h	; 8d7b  |..&..'.>.......
	defb 004h,00ch,03dh,072h,065h,035h,032h,031h,030h,061h,067h,07fh,038h,000h,018h,0ach	; 8d8b  ..=re5210ag.8...
	defb 0cch,00ch,0cch,02ch,0d4h,0d6h,022h,0deh,03ch,078h,070h,0b0h,0ffh,0e0h,003h,006h	; 8d9b  ...,..".<xp.....
	defb 066h,0d6h,0deh,0edh,072h,035h,015h,01ah,011h,036h,06fh,0dfh,0fch,070h,00eh,097h	; 8dab  f...r5...6o..p..
	defb 0a7h,0eeh,09ch,0d8h,028h,0d8h,0d6h,021h,0cdh,03fh,03eh,0d0h,0f0h,060h,003h,01bh	; 8dbb  ....(..!.?>..`..
	defb 03bh,071h,064h,06ch,010h,069h,0e5h,0c4h,0c9h,0d2h,064h,00ch,00fh,007h,0e0h,0f0h	; 8dcb  ;qdl.i....d.....
	defb 030h,026h,063h,09bh,023h,0a7h,096h,028h,0b6h,066h,05eh,0dch,0d8h,0c0h,000h,039h	; 8ddb  0&c.#..(.f^....9
	defb 07ch,04ch,039h,041h,010h,009h,061h,0c4h,0c8h,0f1h,062h,004h,006h,007h,0e0h,060h	; 8deb  |L9A..a...b....`
	defb 028h,066h,04fh,083h,013h,096h,0a0h,008h,042h,03ch,032h,0beh,09ch,000h,001h,002h	; 8dfb  (fO.....B<2.....
	defb 031h,040h,050h,000h,008h,001h,041h,0a0h,0c4h,060h,000h,005h,006h,007h,0e0h,060h	; 8e0b  1@P...A..`.....`
	defb 0a0h,000h,006h,003h,025h,082h,080h,000h,000h,04ah,002h,08ch,0a2h,040h,080h,001h	; 8e1b  ....%....J...@..
	defb 000h,000h,060h,040h,000h,000h,021h,001h,000h,040h,060h,001h,000h,002h,003h,0c0h	; 8e2b  ..`@..!..@`.....
	defb 040h,000h,080h,006h,002h,000h,080h,088h,000h,000h,002h,006h,000h,000h,080h,000h	; 8e3b  @...............
	defb 002h,000h,08ch,001h,005h,00dh,01ch,000h,038h,038h,000h,01ch,00dh,005h,001h,004h	; 8e4b  ........88......
	defb 000h,08ch,080h,0a0h,0b0h,038h,000h,01ch,01ch,000h,038h,0b0h,0a0h,080h,004h,000h	; 8e5b  .....8....8.....
	defb 08ch,001h,005h,00dh,01dh,001h,03fh,03fh,001h,01dh,00dh,005h,001h,004h,000h,08ch	; 8e6b  ......??........
	defb 080h,0a0h,0b0h,0b8h,080h,0fch,0fch,080h,0b8h,0b0h,0a0h,080h,003h,000h,0bfh,002h	; 8e7b  ................
	defb 01ah,03bh,03ah,003h,07fh,017h,017h,07fh,003h,03ah,03bh,01ah,002h,000h,000h,040h	; 8e8b  .;:......:;....@
	defb 058h,0dch,05ch,0c0h,0feh,0e8h,0e8h,0feh,0c0h,05ch,0dch,058h,040h,000h,004h,035h	; 8e9b  X.\......\.X@..5
	defb 074h,077h,004h,0fdh,013h,057h,057h,013h,0fdh,004h,077h,074h,035h,004h,020h,0ach	; 8eab  tw...WW...wt5. .
	defb 02eh,0eeh,020h,0bfh,0c8h,0eah,0eah,0c8h,0bfh,020h,0eeh,02eh,0ach,020h,000h,002h	; 8ebb  .. ...... ... ..
	defb 000h,084h,018h,034h,028h,016h,004h,06ah,084h,016h,028h,034h,018h,004h,000h,08ch	; 8ecb  ...4(..j..(4....
	defb 018h,034h,028h,016h,06ah,068h,06ah,06ah,016h,028h,034h,018h,004h,000h,084h,00ch	; 8edb  .4(.jhjj.(4.....
	defb 01eh,01ch,007h,004h,01dh,084h,007h,01ch,01eh,00ch,004h,000h,084h,030h,078h,038h	; 8eeb  .............0x8
	defb 0d0h,004h,0a8h,084h,0d0h,038h,078h,030h,004h,000h,084h,00eh,01eh,01eh,013h,004h	; 8efb  .....8x0........
	defb 00dh,084h,013h,01eh,01eh,00eh,004h,000h,084h,060h,0f0h,030h,0d0h,004h,0a0h,084h	; 8f0b  .........`.0....
	defb 0d0h,030h,0f0h,060h,004h,000h,084h,001h,003h,003h,006h,004h,005h,084h,006h,003h	; 8f1b  .0.`............
	defb 003h,001h,004h,000h,084h,080h,0c0h,0c0h,060h,004h,0a0h,086h,060h,0c0h,0c0h,080h	; 8f2b  ........`...`...
	defb 000h,000h,000h,083h,000h,04ah,0cah,003h,04ah,081h,044h,00ah,000h,086h,0c0h,0a0h	; 8f3b  .....J..J.D.....
	defb 0a0h,0c0h,080h,080h,009h,000h,082h,002h,006h,005h,002h,00ah,000h,081h,06ch,004h	; 8f4b  ..............l.
	defb 092h,081h,06ch,009h,000h,087h,00ch,012h,002h,004h,008h,010h,01eh,00ah,000h,081h	; 8f5b  ..l.............
	defb 06ch,004h,092h,081h,06ch,009h,000h,087h,01eh,010h,01ch,002h,002h,012h,00ch,00ah	; 8f6b  l...l...........
	defb 000h,081h,06ch,004h,092h,081h,06ch,009h,000h,082h,010h,033h,004h,014h,081h,013h	; 8f7b  ..l...l....3....
	defb 00ah,000h,081h,06ch,004h,092h,081h,06ch,009h,000h,087h,030h,049h,00ah,012h,022h	; 8f8b  ...l...l...0I.."
	defb 042h,079h,00ah,000h,081h,0b6h,004h,049h,081h,0b6h,009h,000h,087h,078h,041h,072h	; 8f9b  By.....I.....xAr
	defb 04ah,00ah,04ah,031h,00ah,000h,081h,0b6h,004h,049h,081h,0b6h,009h,000h,082h,040h	; 8fab  J.J1.....I.....@
	defb 0cdh,004h,052h,081h,04dh,00ah,000h,081h,0b6h,004h,049h,081h,0b6h,009h,000h,000h	; 8fbb  ..R.M.....I.....

; ----------------------------------------------------------------------
; DATOS graficos_1D00: Dos bloques: 0x8FCB, que 0x4287 vuelca en la VRAM
;   0x1D00, y 0x9038, que pide la tabla 0x42B3 para la fase 5.
;   0x8fcb..0x91d1  (518 bytes)
DATA_graficos_1D00:
	defb 087h,00ch,03bh,076h,085h,005h,002h,001h,008h,000h,090h,001h,0f0h,018h,0ech,0f4h	; 8fcb  ..;v............
	defb 0f8h,078h,0bch,05ch,01ch,01ch,018h,038h,030h,060h,0c0h,008h,000h,097h,080h,040h	; 8fdb  .x.\...80`.....@
	defb 060h,038h,01fh,00fh,003h,000h,000h,008h,004h,006h,006h,003h,01dh,026h,05ah,05dh	; 8feb  `8...........&Z]
	defb 0bdh,07dh,0fbh,0f6h,0cch,003h,000h,090h,003h,006h,00ch,01ch,018h,038h,038h,03ah	; 8ffb  .}...........88:
	defb 03dh,01eh,01fh,02fh,037h,018h,00fh,080h,008h,000h,09fh,080h,040h,0a0h,0a1h,06eh	; 900b  =../7.......@..n
	defb 0dch,030h,000h,000h,033h,06fh,0dfh,0beh,0bdh,0bah,05ah,064h,0b8h,0c0h,060h,060h	; 901b  .0..3o....Zd..``
	defb 020h,010h,000h,000h,0c0h,0f0h,0f8h,01ch,006h,002h,008h,000h,000h,003h,000h,089h	; 902b   ...............
	defb 005h,00bh,006h,00ch,031h,00ch,006h,00bh,005h,005h,000h,002h,080h,08bh,050h,068h	; 903b  ....1.........Ph
	defb 030h,098h,0c6h,098h,030h,068h,050h,080h,080h,003h,000h,0ffh,007h,01fh,03ah,03fh	; 904b  0...0hP.......:?
	defb 06ch,079h,06bh,07ah,059h,07ch,03fh,058h,064h,033h,088h,000h,0e0h,0f8h,0bch,0ech	; 905b  lykzY|?Xd3......
	defb 03eh,096h,05eh,0d6h,09eh,03ah,0fch,01ah,026h,0cch,011h,000h,001h,00eh,03dh,077h	; 906b  >.^..:..&.....=w
	defb 07fh,0d8h,0f3h,0d6h,0f5h,0d3h,0f8h,06fh,07ah,03fh,00fh,060h,090h,060h,080h,0f0h	; 907b  .......oz?.`.`..
	defb 088h,044h,024h,0b4h,0bch,03dh,079h,0f5h,0adh,0e8h,0c0h,006h,009h,006h,001h,00fh	; 908b  .D$..=y.........
	defb 011h,022h,024h,02dh,03dh,05ch,04eh,057h,05ah,00bh,003h,000h,080h,070h,0fch,0deh	; 909b  ."$-=\NWZ....p..
	defb 0f6h,01fh,0cbh,0afh,06bh,0cfh,01bh,0f6h,0aeh,0fch,0f0h,000h,000h,007h,01fh,03ah	; 90ab  ....k..........:
	defb 03fh,06ch,079h,06ah,07bh,059h,07ch,03fh,058h,064h,033h,000h,000h,0e0h,0f8h,0bch	; 90bb  ?lyj{Y|?Xd3.....
	defb 0ech,03eh,096h,0deh,056h,09eh,03ah,0fch,01ah,026h,0cch,0ffh,000h,007h,01eh,03bh	; 90cb  .>..V.:..&.....;
	defb 03fh,06ch,079h,06ah,07bh,069h,07ch,037h,03dh,01fh,007h,000h,0c8h,030h,0c0h,0f8h	; 90db  ?lyj{i|7=....0..
	defb 0c4h,022h,092h,0dah,05eh,09eh,03ch,0fah,056h,0f4h,0e0h,000h,013h,00ch,003h,01fh	; 90eb  ."..^.<.V.......
	defb 023h,044h,049h,05ah,07bh,0b9h,09ch,0afh,0b5h,017h,007h,000h,000h,0e0h,0f8h,0bch	; 90fb  #DIZ{...........
	defb 0ech,03eh,096h,0deh,056h,09eh,036h,0ech,05ch,0f8h,0e0h,000h,000h,007h,01fh,03ah	; 910b  .>..V.6.\......:
	defb 03fh,06ch,079h,06ah,07bh,069h,07ch,037h,03dh,01fh,007h,000h,000h,0e0h,0f8h,0bch	; 911b  ?lyj{i|7=.......
	defb 0ech,03eh,096h,0deh,056h,09eh,036h,0ech,05ch,0f8h,0e0h,000h,007h,01fh,024h,04bh	; 912b  .>..V.6.\.....$K
	defb 057h,0ech,0d9h,0dbh,0dah,0d9h,0ech,057h,04bh,024h,01fh,007h,0e0h,0f8h,024h,0d2h	; 913b  W......WK$....$.
	defb 0eah,037h,09bh,05bh,0dbh,09bh,037h,0eah,0d2h,024h,0f8h,09bh,0e0h,000h,000h,003h	; 914b  .7.[..7..$......
	defb 007h,00fh,01ch,038h,070h,061h,0c3h,083h,086h,084h,004h,000h,000h,0e0h,070h,0b0h	; 915b  ...8pa........p.
	defb 0aeh,007h,03bh,07ah,0f0h,0c0h,080h,006h,000h,0cah,001h,003h,002h,001h,003h,007h	; 916b  ..;z............
	defb 007h,00eh,00ch,01ch,018h,030h,030h,021h,021h,001h,080h,0d8h,0bch,00ch,094h,0b8h	; 917b  .....00!!.......
	defb 078h,070h,070h,0e0h,0e0h,0c0h,0c0h,080h,080h,000h,001h,01bh,03dh,030h,029h,01dh	; 918b  xpp.........=0).
	defb 01eh,00eh,00eh,007h,007h,003h,003h,001h,001h,000h,080h,0c0h,040h,080h,0c0h,0e0h	; 919b  ............@...
	defb 0e0h,070h,030h,038h,018h,00ch,00ch,084h,084h,080h,007h,00eh,00dh,075h,0e0h,0dch	; 91ab  .p08.........u..
	defb 05eh,00fh,003h,001h,008h,000h,08eh,0c0h,0e0h,0f0h,038h,01ch,00eh,086h,0c3h,0c1h	; 91bb  ^.........8.....
	defb 061h,021h,020h,000h,000h,000h	; 91cb

; ----------------------------------------------------------------------
; DATOS formas_de_objeto: Cuatro bytes por forma: los dos caracteres de arriba
;   y los dos de abajo del objeto. Los lee 0x48CB indexando con (IX+0x0C)*4, y
;   los escribe en la tabla de nombres separados por 0x1E.
;   0x91d1..0x92e3  (274 bytes)
DATA_formas_de_objeto:
	defb 0e6h,0e7h,0e8h,0e9h	; 91d1
	defb 0eah,0ebh,0ech,0edh	; 91d5
	defb 0eeh,0efh,0f0h,0f1h	; 91d9
	defb 0f2h,0f3h,0f4h,0f5h	; 91dd
	defb 0d2h,0d3h,0d4h,0d5h	; 91e1
	defb 0d6h,0d7h,0d8h,0d9h	; 91e5
	defb 0dah,0dbh,0dch,0ddh	; 91e9
	defb 0deh,0dfh,0e0h,0e1h	; 91ed
	defb 0e2h,0e3h,0e4h,0e5h	; 91f1
	defb 0bah,0bbh,0beh,0bfh	; 91f5
	defb 0bch,0bbh,0beh,0bfh	; 91f9
	defb 0bdh,0bbh,0beh,0bfh	; 91fd
	defb 0c1h,0c2h,0c5h,0c4h	; 9201
	defb 0c1h,0c2h,0c5h,0c4h	; 9205
	defb 0c1h,0c0h,0c5h,0c4h	; 9209
	defb 0c6h,0c7h,0cah,0cbh	; 920d
	defb 0c8h,0c7h,0cah,0cbh	; 9211
	defb 0c9h,0c7h,0cah,0cbh	; 9215
	defb 0cdh,0cfh,0d1h,0d0h	; 9219
	defb 0cdh,0ceh,0d1h,0d0h	; 921d
	defb 0cdh,0cch,0d1h,0d0h	; 9221
	defb 012h,013h,00eh,00fh	; 9225
	defb 012h,013h,010h,00fh	; 9229
	defb 012h,013h,011h,00fh	; 922d
	defb 019h,018h,015h,017h	; 9231
	defb 019h,018h,015h,016h	; 9235
	defb 019h,018h,015h,014h	; 9239
	defb 0cah,0cbh,0c6h,0c7h	; 923d
	defb 0cah,0cbh,0c8h,0c7h	; 9241
	defb 0cah,0cbh,0c9h,0c7h	; 9245
	defb 0d1h,0d0h,0cdh,0cfh	; 9249
	defb 0d1h,0d0h,0cdh,0ceh	; 924d
	defb 0d1h,0d0h,0cdh,0cch	; 9251
	defb 07bh,07ch,07dh,07eh	; 9255
	defb 077h,078h,079h,07ah	; 9259
	defb 002h,003h,006h,007h	; 925d
	defb 004h,003h,006h,007h	; 9261
	defb 005h,003h,006h,007h	; 9265
	defb 009h,00bh,00dh,00ch	; 9269
	defb 009h,00ah,00dh,00ch	; 926d
	defb 009h,008h,00dh,00ch	; 9271
	defb 0ech,0eeh,0edh,0efh	; 9275
	defb 0ech,0f0h,0edh,0f1h	; 9279
	defb 0ech,0f2h,0edh,0f3h	; 927d
	defb 0ech,0f4h,0edh,0f5h	; 9281
	defb 03ch,03dh,038h,039h	; 9285
	defb 03ch,03dh,03ah,039h	; 9289
	defb 03ch,03dh,03bh,039h	; 928d
	defb 043h,042h,03fh,041h	; 9291
	defb 043h,042h,03fh,040h	; 9295
	defb 043h,042h,03fh,03eh	; 9299
	defb 04bh,04ch,0abh,000h	; 929d
	defb 0a6h,000h,046h,045h	; 92a1
	defb 04bh,04ch,0b0h,000h	; 92a5
	defb 000h,0abh,046h,045h	; 92a9
	defb 080h,081h,082h,083h	; 92ad
	defb 084h,085h,086h,087h	; 92b1
	defb 01bh,01ch,017h,018h	; 92b5
	defb 01bh,01ch,019h,018h	; 92b9
	defb 01bh,01ch,01ah,018h	; 92bd
	defb 022h,021h,01eh,020h	; 92c1
	defb 022h,021h,01eh,01fh	; 92c5
	defb 022h,021h,01eh,01dh	; 92c9
	defb 0c6h,0c7h,0cah,0cbh	; 92cd
	defb 0c8h,0c7h,0cah,0cbh	; 92d1
	defb 0c9h,0c7h,0cah,0cbh	; 92d5
	defb 0cdh,0cfh,0d1h,0d0h	; 92d9
	defb 0cdh,0ceh,0d1h,0d0h	; 92dd
	defb 0cdh,0cch	; 92e1

; ----------------------------------------------------------------------
; DATOS listas_de_fichas_A: Doce palabras, una por fase: donde empieza la
;   lista de fichas de 0x4371 de esa fase. La lee 0x4306 con 0x47AE (DE =
;   palabra en HL+2*A).
;   0x92e3..0x92fb  (24 bytes)
DATA_listas_de_fichas_A:
	defw 0d0d1h,093a8h	; 92e3  -> 0xd0d1 DATA_fichas_por_fase
	defw 09403h,09434h	; 92e7
	defw 09477h,094d8h	; 92eb
	defw 09527h,09546h	; 92ef
	defw 095bfh,0961ah	; 92f3
	defw 0963fh,09664h	; 92f7

; ----------------------------------------------------------------------
; DATOS listas_de_fichas_B: Doce palabras, una por fase. La lee 0x4316.
;   0x92fb..0x9313  (24 bytes)
DATA_listas_de_fichas_B:
	defw 09689h,096aeh	; 92fb
	defw 096c7h,096ech	; 92ff
	defw 096f9h,09712h	; 9303
	defw 0972fh,09733h	; 9307
	defw 09750h,09779h	; 930b
	defw 09779h,09779h	; 930f

; ----------------------------------------------------------------------
; DATOS listas_de_fichas_C: Trece palabras, una por fase. La lee 0x4320.
;   0x9313..0x932d  (26 bytes)
DATA_listas_de_fichas_C:
	defw 09779h,09782h	; 9313
	defw 0979fh,097b4h	; 9317
	defw 097c9h,097feh	; 931b
	defw 09837h,09838h	; 931f
	defw 09865h,0988eh	; 9323
	defw 0988eh,0988eh	; 9327
	defw 0988eh	; 932b

; ----------------------------------------------------------------------
; DATOS fichas_comunes: Dieciseis fichas de seis bytes y el 0x00 que las
;   acaba. Las carga 0x42FC en cualquier fase.
;   0x932d..0x938e  (97 bytes)
DATA_fichas_comunes:
	defb 007h,076h,067h,0e6h,080h,07ah	; 932d
	defb 007h,0d5h,066h,0d2h,017h,07ah	; 9333
	defb 001h,0c6h,064h,063h,039h,078h	; 9339
	defb 001h,0c6h,064h,06dh,058h,078h	; 933f
	defb 001h,00fh,065h,07fh,0bbh,078h	; 9345
	defb 001h,00fh,065h,081h,0c0h,078h	; 934b
	defb 007h,0ech,067h,0f6h,0bbh,07ah	; 9351
	defb 007h,0efh,067h,0f8h,0c0h,07ah	; 9357
	defb 007h,0feh,067h,0fch,0c3h,07ah	; 935d
	defb 007h,0edh,064h,077h,077h,078h	; 9363
	defb 007h,0edh,064h,07bh,099h,078h	; 9369
	defb 001h,079h,063h,00bh,093h,077h	; 936f
	defb 001h,0c7h,062h,015h,074h,076h	; 9375
	defb 001h,0c7h,062h,02ch,003h,077h	; 937b
	defb 007h,016h,065h,083h,0c5h,078h	; 9381
	defb 001h,081h,062h,00ch,057h,076h	; 9387
	defb 000h	; 938d

; ----------------------------------------------------------------------
; DATOS fichas_extra_1: Dos fichas de seis bytes y su 0x00. Las carga 0x432B,
;   y solo cuando 0xF0F4 no vale cero.
;   0x938e..0x939b  (13 bytes)
DATA_fichas_extra_1:
	defb 007h,0b9h,098h,077h,0fdh,098h	; 938e
	defb 007h,0b9h,098h,07bh,0dbh,098h	; 9394
	defb 000h	; 939a

; ----------------------------------------------------------------------
; DATOS fichas_extra_2: Dos fichas de seis bytes y su 0x00. Las carga 0x4337,
;   y solo de la fase 9 en adelante.
;   0x939b..0x93a8  (13 bytes)
DATA_fichas_extra_2:
	defb 007h,0b9h,098h,080h,01fh,099h	; 939b
	defb 007h,0b9h,098h,084h,041h,099h	; 93a1
	defb 000h	; 93a7

; ----------------------------------------------------------------------
; DATOS fichas_por_fase: Las listas de fichas a las que apuntan las tres
;   tablas de arriba, una detras de otra: 0x93A8, 0x9403, 0x9434, 0x9477,
;   0x94D8, 0x9527, 0x9546, 0x95BF, 0x961A, 0x963F, 0x9664, 0x9689, 0x96AE,
;   0x96C7, 0x96EC, 0x96F9, 0x9712, 0x972F, 0x9733, 0x9750, 0x9779, 0x9782,
;   0x979F, 0x97B4, 0x97C9, 0x97FE, 0x9837, 0x9838, 0x9865 y 0x988E.
;   0x93a8..0x98a3  (1275 bytes)
DATA_fichas_por_fase:
	defb 004h,08bh,062h,062h,061h,076h	; 93a8
	defb 004h,095h,062h,0a1h,068h,076h	; 93ae
	defb 004h,0adh,062h,0a9h,06fh,076h	; 93b4
	defb 001h,053h,062h,043h,029h,076h	; 93ba
	defb 003h,083h,063h,044h,0dbh,077h	; 93c0
	defb 003h,001h,066h,0a1h,085h,079h	; 93c6
	defb 001h,0d4h,063h,04eh,0feh,077h	; 93cc
	defb 001h,0a4h,064h,05fh,029h,078h	; 93d2
	defb 001h,0a8h,066h,0bah,0c3h,079h	; 93d8
	defb 001h,0a8h,066h,0c6h,0ebh,079h	; 93de
	defb 001h,067h,066h,0b2h,0a9h,079h	; 93e4
	defb 001h,03dh,066h,0aah,090h,079h	; 93ea
	defb 002h,071h,064h,05ah,0a8h,077h	; 93f0
	defb 002h,05fh,064h,058h,096h,077h	; 93f6
	defb 002h,06fh,062h,068h,045h,076h	; 93fc
	defb 000h,007h,00dh,068h,044h,0c6h	; 9402
	defb 07ah,007h,06fh,068h,0a1h,09bh	; 9408
	defb 07ch,007h,0a8h,066h,0bah,0ebh	; 940e
	defb 079h,006h,0a8h,066h,002h,0c3h	; 9414
	defb 079h,007h,0c6h,064h,063h,039h	; 941a
	defb 078h,007h,0c6h,064h,06dh,058h	; 9420
	defb 078h,007h,00fh,065h,07fh,0bbh	; 9426
	defb 078h,007h,00fh,065h,081h,0c0h	; 942c
	defb 078h,000h,007h,097h,068h,044h	; 9432
	defb 0dfh,07dh,007h,000h,069h,05eh	; 9438
	defb 018h,07eh,007h,04ah,069h,067h	; 943e
	defb 04dh,07eh,007h,0a1h,069h,072h	; 9444
	defb 08ah,07eh,007h,0cah,069h,0a1h	; 944a
	defb 08ah,07eh,007h,0f4h,069h,0a6h	; 9450
	defb 08dh,07eh,007h,046h,06ah,0d2h	; 9456
	defb 0d1h,07eh,007h,0a8h,066h,0c6h	; 945c
	defb 0c3h,079h,007h,076h,067h,0e6h	; 9462
	defb 080h,07ah,007h,094h,06ah,0dch	; 9468
	defb 0f8h,07eh,007h,0a8h,06ah,0dfh	; 946e
	defb 0fdh,07eh,000h,007h,076h,067h	; 9474
	defb 0e6h,080h,07ah,007h,0d5h,066h	; 947a
	defb 0d2h,017h,07ah,001h,08bh,062h	; 9480
	defb 062h,061h,076h,001h,095h,062h	; 9486
	defb 0a1h,068h,076h,001h,0adh,062h	; 948c
	defb 0a9h,06fh,076h,006h,083h,063h	; 9492
	defb 044h,0dbh,077h,006h,001h,066h	; 9498
	defb 0a1h,085h,079h,004h,0d4h,063h	; 949e
	defb 04eh,0feh,077h,004h,0a4h,064h	; 94a4
	defb 05fh,029h,078h,001h,0a8h,066h	; 94aa
	defb 0c6h,0ebh,079h,004h,067h,066h	; 94b0
	defb 0b2h,0a9h,079h,004h,03dh,066h	; 94b6
	defb 0aah,090h,079h,007h,0d4h,06ah	; 94bc
	defb 0bah,0a2h,07ch,002h,071h,064h	; 94c2
	defb 05ah,0a8h,077h,002h,05fh,064h	; 94c8
	defb 058h,096h,077h,002h,06fh,062h	; 94ce
	defb 068h,045h,076h,000h,006h,000h	; 94d4
	defb 060h,002h,0d6h,073h,001h,0a8h	; 94da
	defb 066h,0c6h,0c3h,079h,007h,056h	; 94e0
	defb 060h,044h,02ch,074h,007h,02bh	; 94e6
	defb 060h,05ah,001h,074h,001h,039h	; 94ec
	defb 061h,073h,00fh,075h,001h,00eh	; 94f2
	defb 061h,064h,0e4h,074h,001h,05bh	; 94f8
	defb 061h,080h,031h,075h,007h,0bch	; 94fe
	defb 061h,0a1h,092h,075h,007h,0aah	; 9504
	defb 060h,04eh,080h,074h,007h,039h	; 950a
	defb 062h,0b2h,00fh,076h,007h,0b2h	; 9510
	defb 061h,0b8h,088h,075h,006h,0a0h	; 9516
	defb 061h,0bch,076h,075h,001h,075h	; 951c
	defb 061h,0beh,04bh,075h,000h,007h	; 9522
	defb 036h,06bh,044h,0f0h,07ch,007h	; 9528
	defb 036h,06bh,051h,01ch,07dh,007h	; 952e
	defb 093h,06bh,05eh,045h,07dh,007h	; 9534
	defb 003h,06ch,0a1h,08ch,07dh,007h	; 953a
	defb 012h,073h,0ech,024h,083h,000h	; 9540
	defb 001h,00eh,06fh,044h,000h,081h	; 9546
	defb 001h,0afh,06fh,058h,073h,081h	; 954c
	defb 007h,0e2h,06ch,061h,06eh,07fh	; 9552
	defb 003h,0e9h,072h,063h,0d6h,082h	; 9558
	defb 003h,0dch,072h,07fh,0c2h,082h	; 955e
	defb 003h,0e9h,072h,06dh,0fdh,082h	; 9564
	defb 003h,0dch,072h,081h,0cbh,082h	; 956a
	defb 001h,0f9h,06fh,0a1h,0b9h,081h	; 9570
	defb 004h,0f4h,06ch,0a9h,080h,07fh	; 9576
	defb 003h,0a8h,066h,0bah,0c3h,079h	; 957c
	defb 001h,0a8h,066h,0c6h,0ebh,079h	; 9582
	defb 002h,0fch,06eh,057h,0f0h,080h	; 9588
	defb 002h,016h,06dh,001h,09ch,07fh	; 958e
	defb 002h,038h,06dh,005h,0b7h,07fh	; 9594
	defb 002h,06ch,06dh,00ch,0d7h,07fh	; 959a
	defb 002h,09bh,06dh,012h,0fbh,07fh	; 95a0
	defb 002h,0eah,06eh,03eh,0deh,080h	; 95a6
	defb 002h,0eah,06eh,040h,0cch,080h	; 95ac
	defb 002h,05dh,062h,05fh,033h,076h	; 95b2
	defb 004h,08ah,06ch,012h,019h,07fh	; 95b8
	defb 000h,007h,0dch,071h,044h,040h	; 95be
	defb 082h,007h,009h,072h,050h,061h	; 95c4
	defb 082h,001h,08eh,072h,0a1h,0b5h	; 95ca
	defb 082h,001h,0b6h,072h,0a6h,0b8h	; 95d0
	defb 082h,002h,0b6h,072h,0ach,0b8h	; 95d6
	defb 082h,003h,0a8h,066h,0bah,0c3h	; 95dc
	defb 079h,003h,0a8h,066h,0c6h,0ebh	; 95e2
	defb 079h,006h,037h,070h,001h,0f1h	; 95e8
	defb 081h,002h,076h,072h,0a6h,0b2h	; 95ee
	defb 082h,003h,05ah,073h,064h,0a7h	; 95f4
	defb 083h,004h,05ah,073h,024h,0a7h	; 95fa
	defb 083h,004h,0c6h,064h,063h,039h	; 9600
	defb 078h,004h,0c6h,064h,06dh,058h	; 9606
	defb 078h,004h,00fh,065h,07fh,0bbh	; 960c
	defb 078h,004h,00fh,065h,081h,0c0h	; 9612
	defb 078h,000h,007h,00dh,068h,044h	; 9618
	defb 00bh,07bh,007h,06fh,068h,0a1h	; 961e
	defb 09bh,07ch,007h,0a8h,066h,0bah	; 9624
	defb 0ebh,079h,006h,0a8h,066h,002h	; 962a
	defb 0c3h,079h,007h,0edh,064h,080h	; 9630
	defb 085h,083h,007h,0edh,064h,084h	; 9636
	defb 063h,083h,000h,007h,00dh,068h	; 963c
	defb 044h,06fh,07bh,007h,06fh,068h	; 9642
	defb 0a1h,09bh,07ch,007h,0a8h,066h	; 9648
	defb 0bah,0ebh,079h,006h,0a8h,066h	; 964e
	defb 002h,0c3h,079h,007h,0edh,064h	; 9654
	defb 080h,085h,083h,007h,0edh,064h	; 965a
	defb 084h,063h,083h,000h,007h,00dh	; 9660
	defb 068h,044h,0d3h,07bh,007h,06fh	; 9666
	defb 068h,0a1h,09bh,07ch,007h,0a8h	; 966c
	defb 066h,0bah,0ebh,079h,006h,0a8h	; 9672
	defb 066h,002h,0c3h,079h,007h,0edh	; 9678
	defb 064h,080h,085h,083h,007h,0edh	; 967e
	defb 064h,084h,063h,083h,000h,007h	; 9684
	defb 00dh,068h,044h,037h,07ch,007h	; 968a
	defb 06fh,068h,0a1h,09bh,07ch,007h	; 9690
	defb 0a8h,066h,0bah,0ebh,079h,006h	; 9696
	defb 0a8h,066h,002h,0c3h,079h,007h	; 969c
	defb 0edh,064h,080h,085h,083h,007h	; 96a2
	defb 0edh,064h,084h,063h,083h,000h	; 96a8
	defb 063h,068h,029h,005h,06dh,072h	; 96ae
	defb 039h,005h,0bah,0c0h,039h,006h	; 96b4
	defb 0c6h,0cch,039h,006h,07fh,080h	; 96ba
	defb 039h,001h,081h,082h,039h,001h	; 96c0
	defb 000h,063h,068h,039h,005h,068h	; 96c6
	defb 063h,036h,005h,06dh,072h,039h	; 96cc
	defb 005h,072h,06dh,036h,005h,07fh	; 96d2
	defb 080h,039h,001h,081h,082h,039h	; 96d8
	defb 001h,0bah,0c0h,03fh,006h,002h	; 96de
	defb 008h,036h,006h,080h,07fh,026h	; 96e4
	defb 001h,000h,044h,051h,03fh,00dh	; 96ea
	defb 0d2h,0bch,03fh,00ah,0c6h,0cch	; 96f0
	defb 03fh,006h,000h,063h,068h,029h	; 96f6
	defb 005h,06dh,072h,039h,005h,0c6h	; 96fc
	defb 0cch,039h,006h,07fh,080h,039h	; 9702
	defb 001h,081h,082h,039h,001h,0a3h	; 9708
	defb 043h,009h,001h,000h,044h,02eh	; 970e
	defb 037h,00ah,05ah,05fh,03fh,005h	; 9714
	defb 002h,007h,036h,005h,0a1h,0d2h	; 971a
	defb 03fh,00fh,0bch,0beh,036h,002h	; 9720
	defb 0c6h,0cch,009h,006h,0b2h,0b5h	; 9726
	defb 03fh,003h,000h,000h,000h,000h	; 972c
	defb 000h,063h,068h,03bh,005h,06dh	; 9732
	defb 072h,03bh,005h,0bah,0c0h,039h	; 9738
	defb 006h,0c6h,0cch,039h,006h,07fh	; 973e
	defb 080h,039h,001h,081h,082h,039h	; 9744
	defb 001h,013h,01dh,024h,00ah,000h	; 974a
	defb 063h,068h,024h,005h,06dh,072h	; 9750
	defb 024h,005h,07fh,080h,024h,001h	; 9756
	defb 081h,082h,024h,001h,0a6h,0abh	; 975c
	defb 009h,005h,0ach,0b1h,012h,005h	; 9762
	defb 0a1h,0a1h,021h,005h,0a6h,0a9h	; 9768
	defb 012h,003h,0bah,0c0h,019h,006h	; 976e
	defb 0c6h,0cch,019h,006h,000h,0bah	; 9774
	defb 0c0h,03fh,006h,002h,008h,036h	; 977a
	defb 006h,000h,044h,04eh,012h,00ah	; 9780
	defb 0a1h,0abh,032h,00ah,05fh,0a5h	; 9786
	defb 021h,004h,063h,063h,021h,014h	; 978c
	defb 0c6h,0c6h,021h,00ch,07fh,07fh	; 9792
	defb 021h,004h,058h,060h,012h,008h	; 9798
	defb 000h,063h,050h,039h,013h,063h	; 979e
	defb 020h,031h,014h,07fh,0a6h,039h	; 97a4
	defb 004h,0bah,0c6h,039h,00ch,002h	; 97aa
	defb 00eh,036h,00ch,000h,0a6h,0b2h	; 97b0
	defb 03fh,00ah,0c6h,00eh,036h,00ch	; 97b6
	defb 0dch,01ah,036h,00ah,05eh,026h	; 97bc
	defb 036h,019h,0a1h,03fh,036h,005h	; 97c2
	defb 000h,044h,04eh,012h,00ah,0a2h	; 97c8
	defb 0ach,012h,008h,063h,063h,021h	; 97ce
	defb 014h,0c6h,0c6h,021h,00ch,07fh	; 97d4
	defb 07fh,021h,004h,0a1h,0a1h,009h	; 97da
	defb 00bh,044h,044h,024h,01fh,0a1h	; 97e0
	defb 0a1h,024h,019h,05fh,05fh,00ch	; 97e6
	defb 004h,0a2h,0abh,00ch,001h,0a4h	; 97ec
	defb 044h,009h,001h,043h,043h,009h	; 97f2
	defb 001h,058h,060h,012h,008h,000h	; 97f8
	defb 05fh,00dh,037h,005h,05ah,064h	; 97fe
	defb 036h,005h,044h,024h,036h,00ah	; 9804
	defb 02eh,069h,03eh,00ah,002h,038h	; 980a
	defb 036h,00ah,073h,073h,021h,004h	; 9810
	defb 080h,080h,021h,003h,0a1h,0c1h	; 9816
	defb 031h,00fh,0d2h,0d2h,03fh,00fh	; 981c
	defb 0b8h,0bah,03fh,002h,064h,012h	; 9822
	defb 031h,005h,00dh,05fh,00ch,001h	; 9828
	defb 0c6h,017h,021h,00ch,017h,017h	; 982e
	defb 014h,00ch,000h,000h,012h,042h	; 9834
	defb 014h,015h,0bah,0c6h,012h,00ch	; 983a
	defb 0c6h,0c6h,021h,00ch,001h,001h	; 9840
	defb 022h,011h,044h,044h,021h,01dh	; 9846
	defb 0a1h,0a1h,021h,008h,0a9h,0a9h	; 984c
	defb 00ch,004h,048h,059h,012h,003h	; 9852
	defb 052h,05ch,012h,003h,017h,0a1h	; 9858
	defb 014h,00bh,0a1h,0ach,012h,00bh	; 985e
	defb 000h,063h,063h,024h,014h,07fh	; 9864
	defb 07fh,024h,004h,044h,04ah,03fh	; 986a
	defb 006h,0bah,0bah,021h,018h,0bah	; 9870
	defb 038h,031h,00ch,0a1h,0a1h,011h	; 9876
	defb 005h,0a6h,0bah,022h,006h,0a1h	; 987c
	defb 0a6h,024h,005h,0ach,0abh,022h	; 9882
	defb 00ah,05eh,0b5h,03fh,002h,000h	; 9888
	defb 0bah,0c6h,039h,00ch,002h,00eh	; 988e
	defb 036h,00ch,00eh,0aah,03ch,00ch	; 9894
	defb 045h,0aeh,03fh,002h,0aeh,0aeh	; 989a
	defb 03fh,002h,000h	; 98a0

; ----------------------------------------------------------------------
; DATOS fichas_del_disparador: Dos fichas de seis bytes y su 0x00, que carga
;   0x4A86.
;   0x98a3..0x98b0  (13 bytes)
DATA_fichas_del_disparador:
	defb 007h,01fh,084h,044h,07fh,085h	; 98a3
	defb 007h,0a8h,084h,0a1h,0fch,085h	; 98a9
	defb 000h	; 98af

; ----------------------------------------------------------------------
; DATOS lista_de_0x4348: Nueve bytes que 0x4A92 le pasa a 0x4348 en IX.
;   Formato distinto del de las fichas de 0x4371.
;   0x98b0..0x98b9  (9 bytes)
DATA_lista_de_0x4348:
	defb 044h,056h,03fh,012h,0a1h,0bfh,03fh,01dh,000h	; 98b0  DV?...?..

; ----------------------------------------------------------------------
; DATOS graficos_de_las_fichas_extra: Cinco bloques comprimidos de 34 bytes
;   (0x98B9, 0x98DB, 0x98FD, 0x991F, 0x9941): los patrones y colores que piden
;   las fichas de 0x938E y 0x939B.
;   0x98b9..0x9963  (170 bytes)
DATA_graficos_de_las_fichas_extra:
	defb 0a0h,000h,000h,001h,00fh,03fh,07fh,05fh,04fh,00eh,07bh,0fdh,0e0h,0feh,0feh,0feh	; 98b9  .....?._O.{.....
	defb 0fch,027h,01bh,01dh,00ch,002h,001h,000h,000h,0fch,0f8h,0f8h,0f0h,070h,060h,0e0h	; 98c9  .'...........p`.
	defb 000h,000h,0a0h,090h,090h,090h,090h,090h,080h,080h,080h,090h,090h,090h,098h,080h	; 98d9  ................
	defb 080h,080h,080h,080h,080h,080h,060h,060h,060h,060h,060h,080h,080h,080h,080h,080h	; 98e9  ......`````.....
	defb 080h,060h,070h,000h,0a0h,070h,070h,070h,070h,070h,050h,050h,050h,070h,070h,070h	; 98f9  .`p..pppppPPPppp
	defb 075h,050h,050h,050h,050h,050h,050h,050h,040h,040h,040h,040h,040h,050h,050h,050h	; 9909  uPPPPPPP@@@@@PPP
	defb 050h,050h,050h,040h,040h,000h,0a0h,040h,040h,030h,030h,030h,020h,020h,020h,030h	; 9919  PPP@@..@@000   0
	defb 030h,030h,032h,020h,020h,020h,020h,020h,020h,020h,0c0h,0c0h,0c0h,0c0h,0c0h,020h	; 9929  002       .....
	defb 020h,020h,020h,020h,020h,0c0h,0b0h,000h,0a0h,0b0h,0b0h,0b0h,0b0h,0b0h,0a0h,0a0h	; 9939       ...........
	defb 0a0h,0b0h,0b0h,0b0h,0bah,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h	; 9949  ................
	defb 0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,000h	; 9959  ..........

; ----------------------------------------------------------------------
; DATOS graficos_nombres_1800: Bloque comprimido que 0x4296 vuelca en la VRAM
;   0x1800 (la tabla de nombres) cuando 0xF0F4 no vale cero.
;   0x9963..0x9be4  (641 bytes)
DATA_graficos_nombres_1800:
	defb 08ch,0c0h,0f0h,0efh,01fh,07fh,0ffh,0ffh,07fh,006h,0fah,0fbh,007h,008h,000h,002h	; 9963  ................
	defb 080h,087h,0c0h,060h,039h,02fh,007h,08eh,0f8h,00bh,000h,002h,001h,008h,000h,08ah	; 9973  ...`9/..........
	defb 060h,078h,03ch,03eh,00eh,080h,0c0h,0d0h,0f8h,070h,004h,000h,08ch,0c0h,0f0h,0efh	; 9983  `x<>.....p......
	defb 01fh,07fh,0ffh,0ffh,07fh,007h,0fbh,0fbh,007h,008h,000h,002h,080h,087h,0c0h,0e0h	; 9993  ................
	defb 039h,01fh,007h,0ceh,0f8h,00bh,000h,002h,001h,008h,000h,08ah,060h,078h,03ch,03eh	; 99a3  9...........`x<>
	defb 00eh,080h,0c0h,0d0h,0f8h,070h,004h,000h,08ch,0c0h,0f0h,0efh,01fh,07fh,0ffh,0ffh	; 99b3  .....p..........
	defb 07fh,007h,0fbh,0fbh,007h,008h,000h,002h,080h,087h,0c0h,0e0h,0f9h,0ffh,0ffh,0feh	; 99c3  ................
	defb 0f8h,00bh,000h,002h,001h,008h,000h,08ah,060h,078h,03ch,03eh,00eh,080h,0c0h,0d0h	; 99d3  ........`x<>....
	defb 0f8h,070h,004h,000h,087h,003h,007h,002h,000h,030h,070h,020h,019h,000h,083h,0beh	; 99e3  .p.......0p ....
	defb 0bfh,0beh,01dh,000h,087h,020h,060h,0d8h,03ch,01eh,00eh,002h,01bh,000h,08ah,060h	; 99f3  ..... `.<......`
	defb 078h,03ch,03eh,00eh,000h,0c0h,0e0h,0f8h,030h,004h,000h,09ch,060h,090h,090h,060h	; 9a03  x<>.....0...`..`
	defb 030h,048h,048h,030h,030h,048h,048h,030h,060h,090h,090h,060h,000h,000h,060h,078h	; 9a13  0HH00HH0`..`..`x
	defb 03ch,03eh,00eh,000h,0c0h,0e0h,0f8h,030h,004h,000h,09ch,090h,060h,030h,048h,048h	; 9a23  <>.....0....`0HH
	defb 030h,030h,048h,048h,030h,030h,048h,048h,030h,060h,090h,000h,000h,060h,078h,03ch	; 9a33  00HH00HH0`...`x<
	defb 03eh,00eh,000h,0c0h,0e0h,0f8h,030h,004h,000h,09ch,060h,090h,090h,060h,030h,048h	; 9a43  >.....0...`..`0H
	defb 048h,030h,030h,048h,048h,030h,060h,090h,090h,060h,000h,000h,060h,078h,03ch,03eh	; 9a53  H00HH0`..`..`x<>
	defb 00eh,000h,0c0h,0e0h,0f8h,030h,004h,000h,09ch,090h,060h,030h,048h,048h,030h,030h	; 9a63  .....0....`0HH00
	defb 048h,048h,030h,030h,048h,048h,030h,060h,090h,000h,000h,060h,078h,03ch,03eh,00eh	; 9a73  HH00HH0`...`x<>.
	defb 000h,0c0h,0e0h,0f8h,030h,006h,000h,08ch,030h,048h,048h,030h,030h,048h,048h,030h	; 9a83  ....0...0HH00HH0
	defb 030h,048h,048h,030h,004h,000h,08ah,060h,078h,03ch,03eh,00eh,000h,0c0h,0e0h,0f8h	; 9a93  0HH0...`x<>.....
	defb 030h,008h,000h,088h,030h,048h,048h,030h,030h,048h,048h,030h,006h,000h,08ah,060h	; 9aa3  0...0HH00HH0...`
	defb 078h,03ch,03eh,00eh,000h,0c0h,0e0h,0f8h,030h,006h,000h,08ch,030h,048h,048h,030h	; 9ab3  x<>.....0...0HH0
	defb 030h,048h,048h,030h,030h,048h,048h,030h,004h,000h,08ah,060h,078h,03ch,03eh,00eh	; 9ac3  0HH00HH0...`x<>.
	defb 000h,0c0h,0e0h,0f8h,030h,008h,000h,088h,030h,048h,048h,030h,030h,048h,048h,030h	; 9ad3  ....0...0HH00HH0
	defb 004h,000h,08fh,0e0h,0b8h,08fh,090h,0e0h,0c0h,080h,080h,0c1h,0fah,086h,08dh,0f8h	; 9ae3  ................
	defb 00fh,001h,003h,000h,09dh,0f0h,09ch,086h,043h,041h,0b1h,059h,077h,029h,009h,0f3h	; 9af3  ........CA.Yw)..
	defb 006h,0fch,000h,0e0h,0b8h,08fh,090h,0e0h,0c0h,080h,080h,0c1h,0fbh,087h,08dh,0f8h	; 9b03  ................
	defb 00fh,001h,003h,000h,08dh,0f0h,09ch,086h,043h,041h,0b1h,019h,0c7h,021h,019h,08bh	; 9b13  ........CA...!..
	defb 076h,0fch,007h,000h,083h,001h,01fh,001h,00bh,000h,087h,001h,00eh,0f0h,000h,0f0h	; 9b23  v...............
	defb 00eh,001h,00ah,000h,085h,001h,00ch,0c0h,00ch,001h,00bh,000h,085h,080h,030h,003h	; 9b33  ..............0.
	defb 030h,080h,00ch,000h,083h,003h,03fh,003h,00dh,000h,083h,0c0h,0fch,0c0h,00dh,000h	; 9b43  0.....?.........
	defb 083h,007h,03fh,007h,009h,000h,08bh,003h,01ch,030h,0e0h,080h,000h,080h,0e0h,030h	; 9b53  ..?......0.....0
	defb 01ch,003h,006h,000h,089h,003h,00eh,018h,070h,0e0h,070h,018h,00eh,003h,007h,000h	; 9b63  ........p.p.....
	defb 089h,0c0h,070h,018h,00eh,007h,00eh,018h,070h,0c0h,008h,000h,087h,001h,007h,00fh	; 9b73  ..p.....p.......
	defb 01fh,00fh,007h,001h,009h,000h,087h,080h,0e0h,0f0h,0f8h,0f0h,0e0h,080h,00ah,000h	; 9b83  ................
	defb 085h,001h,002h,078h,002h,001h,009h,000h,002h,080h,087h,040h,020h,00fh,020h,040h	; 9b93  ...x.......@ . @
	defb 080h,080h,00ah,000h,083h,001h,006h,001h,00ch,000h,085h,080h,040h,030h,040h,080h	; 9ba3  ............@0@.
	defb 00dh,000h,081h,001h,00eh,000h,083h,080h,0c0h,080h,00bh,000h,087h,080h,070h,00fh	; 9bb3  ..............p.
	defb 000h,00fh,070h,080h,00bh,000h,083h,080h,0f8h,080h,009h,000h,08bh,0c0h,038h,00ch	; 9bc3  ..p...........8.
	defb 007h,001h,000h,001h,007h,00ch,038h,0c0h,009h,000h,083h,0e0h,0fch,0e0h,007h,000h	; 9bd3  ......8.........
	defb 000h	; 9be3

; ----------------------------------------------------------------------
; DATOS relleno: Relleno 0xFF hasta los 8192 bytes del banco.
;   0x9be4..0xa000  (1052 bytes)
DATA_relleno:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9be4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9bf4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c04  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c14  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c24  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c34  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c44  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c54  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c64  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c74  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c84  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c94  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9ca4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9cb4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9cc4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9cd4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9ce4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9cf4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d04  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d14  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d24  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d34  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d44  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d54  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d64  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d74  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d84  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d94  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9da4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9db4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9dc4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9dd4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9de4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9df4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9e04  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9e14  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9e24  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9e34  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9e44  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9e54  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9e64  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9e74  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9e84  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9e94  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9ea4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9eb4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9ec4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9ed4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9ee4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9ef4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9f04  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9f14  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9f24  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9f34  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9f44  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9f54  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9f64  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9f74  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9f84  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9f94  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9fa4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9fb4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9fc4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9fd4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9fe4  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9ff4  ............

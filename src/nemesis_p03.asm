; ==========================================================================
; NEMESIS / GRADIUS - Konami (1986) - MSX1 - MegaROM RC-742 de 128 KB (Konami4) - banco 03 (se ejecuta en 0xa000)
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0a000


; ----------------------------------------------------------------------
; Direcciones que solo aparecen como VALOR -en un `ld`, no en
; un salto-: son punteros que el codigo se pasa o numeros que
; casualmente coinciden con una direccion. No hay nada que
; trazar en ellas; el equ existe para que el listado ensamble.
; ----------------------------------------------------------------------
la3a6h:	equ 0x0a3a6
la5afh:	equ 0x0a5af
lac7bh:	equ 0x0ac7b

; ======================================================================
; CODIGO 0xa000..0xa094  (148 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL BANCO EMPIEZA DONDE ACABA EL 2, SIN SALTO NINGUNO
; ----------------------------------------------------------------------
sigue_del_banco_2:		; Aqui continua el codigo que viene de 0x9FFF sin ninguna instruccion de por medio
	call 0992fh		;a000   ; Aqui entra el codigo que viene de 0x9FFF
	jr nc,el_laser_se_corta		;a003
	xor a			;a005
	ld (de),a			;a006   ; La casilla, borrada
	ld a,c			;a007
	call 049deh		;a008
L_A00B:
	inc de			;a00b   ; Y las que queden de la tira
	djnz $-17		;a00c
	ret			;a00e
el_laser_se_corta:		; El laser choca con el mapa: se le recorta el largo y, si se queda en nada, se apaga
	ld (ix+001h),002h		;a00f   ; El paso 2: el laser ya no crece
	ld a,(ix+00ch)		;a013   ; El byte 12: las casillas que mide
	inc b			;a016
	sub b			;a017
	jp c,09e61h		;a018   ; Sin casillas, el laser se apaga
	jp z,09e61h		;a01b
	ld (ix+00ch),a		;a01e
	ret			;a021

; ----------------------------------------------------------------------
; EL MEDIDOR DE MEJORAS
; Las seis casillas del medidor -SPEED UP, MISSILE, DOUBLE, LASER, OPTION y
; el escudo- se pintan encendidas o apagadas segun lo que la nave ya lleve.
; 0xA022 recorre la ficha de la nave y deja en 0xE131..0xE136 un uno por
; cada mejora que ya este puesta; 0xA068 mira 0xE130 -la casilla elegida- y,
; al pulsar el boton, si esa mejora aun no esta, la da.
; ----------------------------------------------------------------------
apunta_lo_que_ya_lleva:		; Deja en 0xE131 a 0xE136 que mejoras tiene ya la nave, para pintar el medidor
	ld hl,0e200h		;a022
	xor a			;a025
	ld b,a			;a026
	ld c,a			;a027
	ld d,a			;a028
	ld a,(hl)			;a029
	or a			;a02a
	ret z			;a02b
	dec a			;a02c
	ld (0e136h),a		;a02d   ; 0xE136: el escudo
	inc l			;a030
	inc l			;a031
	ld a,(hl)			;a032
	cp 008h		;a033   ; El byte 2 por encima de 8: ya lleva velocidad
	jr c,L_A038		;a035
	inc b			;a037
L_A038:
	ld a,b			;a038
	ld (0e131h),a		;a039   ; 0xE131: la velocidad
	ld a,009h		;a03c
	add a,l			;a03e
	ld l,a			;a03f
	ld a,(hl)			;a040
	cp 002h		;a041   ; El byte 11 en dos o mas: ya lleva misil
	jr c,L_A046		;a043
	inc c			;a045
L_A046:
	ld a,c			;a046
	ld (0e135h),a		;a047   ; 0xE135: el misil
	inc l			;a04a
	inc l			;a04b
	ld a,(hl)			;a04c
	ld (0e133h),a		;a04d   ; 0xE133: el disparo doble
	inc l			;a050
	ld a,(hl)			;a051
	cp 002h		;a052   ; El byte 13 en dos o mas: ya lleva laser
	jr c,L_A057		;a054
	inc d			;a056
L_A057:
	ld a,d			;a057
	ld (0e134h),a		;a058   ; 0xE134: el laser
	inc l			;a05b
	ld a,(hl)			;a05c
	cp 002h		;a05d   ; Y el byte 14: las opciones
	ld a,000h		;a05f
	jr c,L_A064		;a061
	inc a			;a063
L_A064:
	ld (0e132h),a		;a064
	ret			;a067
coge_la_mejora:		; Con el boton, si la casilla elegida del medidor no esta ya puesta, se la lleva y suena el 0x14
	ld a,(0e200h)		;a068
	dec a			;a06b
	ret m			;a06c
	ld a,(0e008h)		;a06d   ; El bit 5 de lo recien pulsado: el otro boton
	and 020h		;a070
	ret z			;a072
	ld a,(0e130h)		;a073   ; 0xE130: la casilla elegida
	or a			;a076
	ret z			;a077
	ld c,a			;a078
	ld b,000h		;a079
	ld hl,0e130h		;a07b
	add hl,bc			;a07e
	ld a,(hl)			;a07f   ; Si esa mejora ya esta, no se hace nada
	and a			;a080
	ret nz			;a081
	xor a			;a082
	ld (0e130h),a		;a083   ; El medidor vuelve a cero
	ld hl,0a153h		;a086
	push hl			;a089
	ld a,014h		;a08a   ; El sonido 0x14
	call 049deh		;a08c
	ld a,c			;a08f
	dec a			;a090
	call 04067h		;a091

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_A091: Seis palabras pegadas detras del `call
;   0x4067` de 0xA091 (0xA0A0, 0xA0A5, 0xA0AC, 0xA0B7, 0xA0C1, 0xA0CB).
;   0xa094..0xa0a0  (12 bytes)
DATA_tabla_del_despachador_A091:
	defw 0a0a0h,0a0a5h	; a094  -> mejora_velocidad mejora_misil
	defw 0a0ach,0a0b7h	; a098  -> mejora_doble mejora_laser
	defw 0a0c1h,0a0cbh	; a09c  -> mejora_opcion mejora_escudo

; ======================================================================
; CODIGO 0xa0a0..0xa0ee  (78 bytes)
; ======================================================================


mejora_velocidad:		; Un escalon mas de velocidad
	ld hl,0e202h		;a0a0
	inc (hl)			;a0a3
	ret			;a0a4
mejora_misil:		; Sube el misil y sube la dificultad
	ld hl,0e20fh		;a0a5
	inc (hl)			;a0a8
	jp 070cah		;a0a9
mejora_doble:		; Deja el disparo doble y quita el laser
	xor a			;a0ac   ; 0xE20E a cero: se queda sin laser
	ld hl,0e20eh		;a0ad
	ld (hl),a			;a0b0
	inc a			;a0b1
	dec l			;a0b2
	ld (hl),a			;a0b3   ; Y 0xE20C y 0xE20D a uno: el doble puesto
	dec l			;a0b4
	ld (hl),a			;a0b5
	ret			;a0b6
mejora_laser:		; Deja el laser y quita el doble
	xor a			;a0b7   ; 0xE20C y 0xE20D a cero: se queda sin doble
	ld hl,0e20ch		;a0b8
	ld (hl),a			;a0bb
	inc l			;a0bc
	ld (hl),a			;a0bd
	inc l			;a0be
	inc (hl)			;a0bf   ; Y 0xE20E arriba: el laser puesto
	ret			;a0c0
mejora_opcion:		; Una opcion mas y sube la dificultad
	ld hl,0e20bh		;a0c1
	inc (hl)			;a0c4
	call 09bfbh		;a0c5
	jp 070cah		;a0c8
mejora_escudo:		; 0xE200 a 3 y 0xE201 a 0x0A: el escudo puesto
	ld hl,0e200h		;a0cb   ; 0xE200 a tres y 0xE201 a 0x0A
	ld (hl),003h		;a0ce
	inc l			;a0d0
	ld (hl),00ah		;a0d1
	ld c,002h		;a0d3   ; Y 0x70CA sube la dificultad
	jp 070cah		;a0d5

; ----------------------------------------------------------------------
; LO QUE DA CADA CLAVE
; Aqui caen las claves que se escriben con el teclado y que reparte 0x50C9
; en el banco 0. Cada una toca una casilla de la nave y se va:
; 0xA0D8  HYPER y el nombre de mujer de la fase: las CINCO de golpe
; 0xA0E9  SHIELD    0xA101  LASER     0xA106  MISSILE
; 0xA10B  DOUBLE    0xA110  OPTION    0xA0FA  DOWN, que quita
; ----------------------------------------------------------------------
clave_de_todo:		; HYPER y el nombre de la fase: escudo, velocidad, laser, misil y opcion, las cinco seguidas
	call pon_el_escudo		;a0d8   ; Las cinco de golpe: escudo...
	call sube_la_velocidad		;a0db   ; ...velocidad, laser, misil...
	call pon_el_laser		;a0de
	call pon_el_misil		;a0e1
	call anade_una_opcion		;a0e4   ; ...y una opcion
	jr $+108		;a0e7
clave_shield:		; Solo el escudo
	call pon_el_escudo		;a0e9
	jr $+103		;a0ec

; ----------------------------------------------------------------------
; DATOS trozo_muerto_A0EE: Doce bytes que desensamblan como codigo (`ld
;   hl,0xE202 / ld a,(hl) / cp 7 / ret nc / call 0xA11E / jr`), pero a los que
;   no llega ningun camino: la instruccion de delante es un `jr` y ninguna
;   tabla apunta aqui.
;   0xa0ee..0xa0fa  (12 bytes)
trozo_muerto_A0EE:		; Codigo al que no llega nadie.
	defb 021h,002h,0e2h,07eh,0feh,007h,0d0h,0cdh,01eh,0a1h,018h,059h	; a0ee  !..~.......Y

; ======================================================================
; CODIGO 0xa0fa..0xa11e  (36 bytes)
; ======================================================================


clave_down:		; 0xE202 a cero: le quita a la nave lo que 0xA123 le sube
	ld hl,0e202h		;a0fa
	ld (hl),000h		;a0fd
	jr $+84		;a0ff
clave_laser:		; Solo el laser
	call pon_el_laser		;a101
	jr $+79		;a104
clave_missile:		; Solo el misil
	call pon_el_misil		;a106
	jr $+74		;a109
clave_double:		; Solo el disparo doble
	call pon_el_disparo_doble		;a10b
	jr $+69		;a10e
clave_option:		; Solo las opciones, hasta las dos que caben
	call anade_una_opcion		;a110
	jr $+64		;a113
pon_el_escudo:		; 0xE200 a 3 y 0xE201 a 0x0A: el escudo puesto
	ld hl,0e200h		;a115
	ld (hl),003h		;a118
	inc l			;a11a
	ld (hl),00ah		;a11b
	ret			;a11d

; ----------------------------------------------------------------------
; DATOS trozo_muerto_A11E: Cinco bytes que son `ld hl,0xE202 / inc (hl) /
;   ret`. El unico que los llama es el trozo muerto de 0xA0EE, asi que tampoco
;   se ejecutan nunca.
;   0xa11e..0xa123  (5 bytes)
DATA_trozo_muerto_A11E:
	defb 021h,002h,0e2h,034h,0c9h	; a11e

; ======================================================================
; CODIGO 0xa123..0xa3a8  (645 bytes)
; ======================================================================


sube_la_velocidad:		; 0xE202 a uno
	ld hl,0e202h		;a123
	ld (hl),001h		;a126
	ret			;a128
pon_el_laser:		; 0xE20C y 0xE20D a cero y 0xE20E a dos: el disparo pasa a laser
	ld hl,0e20ch		;a129   ; 0xE20C y 0xE20D a cero...
	xor a			;a12c
	ld (hl),a			;a12d
	inc l			;a12e
	ld (hl),a			;a12f
	inc l			;a130
	ld (hl),002h		;a131   ; ...y 0xE20E a dos: el laser
	ret			;a133
pon_el_misil:		; 0xE20F a dos
	ld hl,0e20fh		;a134
	ld (hl),002h		;a137
	ret			;a139
pon_el_disparo_doble:		; 0xE20C y 0xE20D a uno, y 0xE20E a cero
	ld hl,0e20ch		;a13a   ; 0xE20C y 0xE20D a uno...
	ld a,001h		;a13d
	ld (hl),a			;a13f
	inc l			;a140
	ld (hl),a			;a141
	dec a			;a142
	inc l			;a143
	ld (hl),a			;a144   ; ...y 0xE20E a cero: el doble
	ret			;a145
anade_una_opcion:		; Sube 0xE20B hasta dos y, por cada una, llama a 0x9BFB
	ld hl,0e20bh		;a146
	ld a,(hl)			;a149
	cp 002h		;a14a   ; Dos opciones como mucho
	ret nc			;a14c
	inc (hl)			;a14d
	call 09bfbh		;a14e
	jr anade_una_opcion		;a151
refresca_el_medidor:		; Vuelve a apuntar lo que lleva la nave y repinta el medidor
	call apunta_lo_que_ya_lleva		;a153
	jp 0569dh		;a156
sube_cuatro_fichas_vacias:		; Cuatro fichas apagadas: la nave no esta
	ld b,004h		;a159
L_A15B:
	call ficha_apagada		;a15b
	djnz L_A15B		;a15e
	jr L_A1C3		;a160
sube_la_ficha_de_la_explosion:		; Con la nave muerta, las fichas salen de otro sitio
	inc l			;a162   ; Con la nave reventada, la ficha sale cuatro bytes mas alla
	inc l			;a163
	inc l			;a164
	inc l			;a165
	ldi		;a166   ; La fila y la columna de la explosion...
	inc l			;a168
	ldi		;a169
	ldi		;a16b
	ldi		;a16d
	ld hl,0e204h		;a16f   ; ...y el resto de la ficha, de la nave
	ldi		;a172
	inc l			;a174
	ldi		;a175
	inc l			;a177
	inc l			;a178
	ldi		;a179   ; Los dibujos y los colores
	ldi		;a17b
	jr L_A1B7		;a17d
sube_las_fichas_de_la_nave:		; Copia al buffer de sprites las fichas de la nave, sus dos opciones y sus disparos
	ld de,0ec80h		;a17f   ; 0xEC80: el buffer de atributos de sprite
	ld hl,0e200h		;a182
	ld a,(hl)			;a185   ; Con 0xE200 a cero no hay nave, y con el bit 7 esta reventada
	or a			;a186
	jr z,sube_cuatro_fichas_vacias		;a187
	jp m,sube_la_ficha_de_la_explosion		;a189
	ld hl,0e204h		;a18c
	ldi		;a18f
	inc l			;a191
	ldi		;a192
	ldi		;a194
	ldi		;a196
	ld hl,0e204h		;a198
	ld a,(0e200h)		;a19b
	dec a			;a19e   ; Con la nave en el estado 1, la ficha va tal cual
	jr z,L_A1AC		;a19f
	ldi		;a1a1
	inc l			;a1a3
	ld a,(hl)			;a1a4
	add a,008h		;a1a5   ; Y si no, ocho puntos mas abajo
	ld (de),a			;a1a7
	inc e			;a1a8
	inc l			;a1a9
	jr L_A1B1		;a1aa
L_A1AC:
	ldi		;a1ac
	inc l			;a1ae
	ldi		;a1af
L_A1B1:
	inc l			;a1b1
	inc l			;a1b2
	ldi		;a1b3
	ldi		;a1b5
L_A1B7:
	ld hl,0e220h		;a1b7   ; Las dos opciones, 0xE220 y 0xE240
	call sube_la_ficha_de_la_opcion		;a1ba
	ld hl,0e240h		;a1bd
	call sube_la_ficha_de_la_opcion		;a1c0
L_A1C3:
	ld hl,0e270h		;a1c3   ; Y las tablas de disparos: 0xE270, 0xE290, 0xE2B0...
	call sube_la_ficha_del_disparo		;a1c6
	ld hl,0e290h		;a1c9
	call sube_la_ficha_del_disparo		;a1cc
	ld hl,0e2b0h		;a1cf
	call sube_la_ficha_del_disparo		;a1d2
	ld hl,0e2c0h		;a1d5
	ld b,003h		;a1d8   ; Tres misiles
sube_los_tres_misiles:		; Los tres misiles de 0xE2C0; el hueco vacio se apaga
	ld a,(hl)			;a1da   ; Tres misiles, de ocho en ocho bytes
	or a			;a1db
	jr z,misil_apagado		;a1dc
	inc l			;a1de
	inc l			;a1df
	inc l			;a1e0   ; Sin misil, ficha apagada
	ldi		;a1e1
	inc l			;a1e3
	ldi		;a1e4
	ldi		;a1e6
	ldi		;a1e8
	ld a,008h		;a1ea   ; Ocho bytes: el siguiente
	call 0405dh		;a1ec
	djnz sube_los_tres_misiles		;a1ef
	ret			;a1f1
misil_apagado:		; Ficha vacia y a por el siguiente
	call ficha_apagada		;a1f2
	ld a,010h		;a1f5   ; Dieciseis bytes: el siguiente
	call 0405dh		;a1f7
	djnz sube_los_tres_misiles		;a1fa
	ret			;a1fc
sube_la_ficha_de_la_opcion:		; Si la opcion esta, su posicion, patron y color al buffer
	ld a,(hl)			;a1fd   ; Con la opcion puesta, su fila, su columna, su dibujo y su color
	or a			;a1fe
	jr z,ficha_apagada		;a1ff
	ld a,004h		;a201
	add a,l			;a203
	ld l,a			;a204
	ldi		;a205
	inc l			;a207   ; Cuatro bytes de ficha
	ldi		;a208
	ld a,005h		;a20a
	add a,l			;a20c
	ld l,a			;a20d
	ldi		;a20e
	ldi		;a210
	ret			;a212
sube_la_ficha_del_disparo:		; Solo los del tipo 2 -el doble- suben ficha de sprite
	ld a,(hl)			;a213   ; Los del tipo 2 -el doble- son los unicos que suben ficha
	cp 002h		;a214
	jr nz,ficha_apagada		;a216
	inc l			;a218
	inc l			;a219
	inc l			;a21a
	ldi		;a21b   ; Su fila y su columna
	inc l			;a21d
	ldi		;a21e
	ldi		;a220
	ldi		;a222
	ret			;a224
ficha_apagada:		; 0xE0 en la Y: el VDP no la dibuja
	ld a,0e0h		;a225   ; 0xE0 en la fila: el VDP no dibuja el sprite
	ld (de),a			;a227
	inc de			;a228
	inc de			;a229   ; Y los otros tres bytes, a cero
	inc de			;a22a
	inc de			;a22b
	ret			;a22c

; ----------------------------------------------------------------------
; EL LASER SE PINTA EN LA TABLA DE NOMBRES, NO CON SPRITES
; El disparo normal es un sprite, pero el laser no: es una TIRA DE
; CARACTERES escrita en el mapa. 0xA22D guarda lo que hay debajo -su
; casilla y su largo- y luego escribe la tira; 0xA27F la borra devolviendo
; los caracteres. Por eso el laser puede tapar el terreno mientras pasa.
; ----------------------------------------------------------------------
guarda_lo_de_debajo_del_laser:		; Recorre las seis ranuras y, para el laser, se guarda donde empieza y cuantas casillas ocupa
	ld hl,0e260h		;a22d
	exx			;a230
	ld b,006h		;a231   ; Seis ranuras
L_A233:
	exx			;a233
	push hl			;a234
	ld a,(hl)			;a235
	dec a			;a236   ; El tipo 1: el disparo normal
	jr z,guarda_lo_del_disparo		;a237
	sub 002h		;a239   ; Y el 3: el laser
	jr z,guarda_lo_del_laser		;a23b
L_A23D:
	pop hl			;a23d
	ld a,010h		;a23e   ; Dieciseis bytes: la siguiente
	call 0405dh		;a240
	exx			;a243
	djnz L_A233		;a244
	ret			;a246
guarda_lo_del_disparo:		; La casilla donde cae, y el caracter que habia
	call casilla_del_disparo		;a247   ; La casilla donde cae el disparo...
	inc l			;a24a
	inc l			;a24b
	inc l			;a24c
	ld a,(de)			;a24d   ; ...y el caracter que habia alli
	ld (hl),a			;a24e
	jr L_A23D		;a24f
guarda_lo_del_laser:		; Se apunta la casilla en los bytes 14 y 15 y copia la tira de caracteres que va a tapar
	push hl			;a251
	pop ix		;a252
	ld a,(ix+00ch)		;a254   ; El byte 12: cuantas casillas mide
	or a			;a257
	jr z,L_A270		;a258
	call casilla_del_disparo		;a25a
	ld (ix+00eh),e		;a25d
	ld (ix+00fh),d		;a260
	ld a,00ch		;a263
	add a,l			;a265
	ld l,a			;a266
	ld c,(ix+00ch)		;a267
	ld b,000h		;a26a
	ex de,hl			;a26c
	ldir		;a26d   ; Se copia lo que habia debajo
	ex de,hl			;a26f
L_A270:
	jr L_A23D		;a270
casilla_del_disparo:		; De la posicion del disparo sale su casilla en el mapa
	inc l			;a272   ; De la fila y la columna sale la casilla del mapa
	inc l			;a273
	inc l			;a274
	ld e,(hl)			;a275
	inc l			;a276
	inc l			;a277
	ld d,(hl)			;a278
	ex de,hl			;a279   ; 0x571B: la casilla que le toca
	call 0571bh		;a27a
	ex de,hl			;a27d
	ret			;a27e
escribe_el_laser:		; Escribe en el mapa el caracter del disparo, y para el laser toda su tira
	ld hl,0e260h		;a27f
	exx			;a282
	ld b,006h		;a283   ; Seis ranuras
L_A285:
	exx			;a285   ; El byte 1 dice de que es cada ranura
	push hl			;a286
	ld a,(hl)			;a287
	dec a			;a288
	jr z,escribe_el_disparo		;a289
	sub 002h		;a28b
	jr z,escribe_la_tira_del_laser		;a28d
L_A28F:
	pop hl			;a28f
	ld a,010h		;a290   ; Dieciseis bytes: la siguiente
	call 0405dh		;a292
	exx			;a295
	djnz L_A285		;a296
	ret			;a298
escribe_el_disparo:		; Un solo caracter en su casilla
	inc l			;a299   ; La fila y la columna del disparo
	inc l			;a29a
	inc l			;a29b
	ld e,(hl)			;a29c
	inc l			;a29d
	inc l			;a29e
	ld d,(hl)			;a29f
	ex de,hl			;a2a0
	call 0571bh		;a2a1   ; De ahi sale su casilla en el mapa
	ex de,hl			;a2a4
	inc l			;a2a5
	ld a,(hl)			;a2a6   ; Y ahi se escribe su caracter
	ld (de),a			;a2a7
	jr L_A28F		;a2a8
escribe_la_tira_del_laser:		; Repite el caracter del laser tantas casillas como mida
	push hl			;a2aa
	pop ix		;a2ab
	ld a,(ix+00ch)		;a2ad   ; El byte 12: cuantas casillas
	or a			;a2b0
	jr z,L_A2C5		;a2b1
	ld a,006h		;a2b3   ; Seis bytes mas alla: el caracter
	add a,l			;a2b5
	ld l,a			;a2b6
	ld a,(hl)			;a2b7
	ld b,(ix+00ch)		;a2b8
	ld e,(ix+00eh)		;a2bb   ; Los bytes 14 y 15: donde empieza la tira
	ld d,(ix+00fh)		;a2be
L_A2C1:
	ld (de),a			;a2c1   ; El mismo caracter, tantas veces
	inc de			;a2c2
	djnz L_A2C1		;a2c3
L_A2C5:
	jr L_A28F		;a2c5
devuelve_lo_de_debajo:		; Borra el disparo del mapa devolviendo el caracter que habia guardado, y el laser toda su tira
	ld hl,0e260h		;a2c7
	exx			;a2ca
	ld b,006h		;a2cb   ; Seis ranuras
L_A2CD:
	exx			;a2cd
	push hl			;a2ce
	ld a,(hl)			;a2cf
	dec a			;a2d0   ; El tipo 1: el disparo normal
	jr z,devuelve_lo_del_disparo		;a2d1
	sub 002h		;a2d3   ; Y el 3: el laser
	jr z,devuelve_lo_del_laser		;a2d5
L_A2D7:
	pop hl			;a2d7
	ld a,010h		;a2d8   ; Dieciseis bytes: la siguiente
	call 0405dh		;a2da
	exx			;a2dd
	djnz L_A2CD		;a2de
	ret			;a2e0
devuelve_lo_del_disparo:		; El caracter guardado vuelve a su casilla
	inc l			;a2e1   ; La casilla que se habia apuntado...
	inc l			;a2e2
	inc l			;a2e3
	ld e,(hl)			;a2e4
	inc l			;a2e5
	inc l			;a2e6
	ld d,(hl)			;a2e7
	ex de,hl			;a2e8
	call 0571bh		;a2e9   ; ...y el caracter que habia debajo
	ex de,hl			;a2ec
	inc l			;a2ed
	inc l			;a2ee
	inc l			;a2ef
	ld a,(hl)			;a2f0   ; Vuelto a su sitio
	ld (de),a			;a2f1
	jr L_A2D7		;a2f2
devuelve_lo_del_laser:		; Copia de vuelta la tira entera que el laser tapaba
	push hl			;a2f4
	pop ix		;a2f5
	ld a,(ix+00ch)		;a2f7   ; El byte 12: cuantas casillas
	or a			;a2fa
	jr z,L_A30E		;a2fb
	ld e,(ix+00eh)		;a2fd   ; Los bytes 14 y 15: donde empezaba
	ld d,(ix+00fh)		;a300
	ld a,011h		;a303
	add a,l			;a305
	ld l,a			;a306
	ld c,(ix+00ch)		;a307
	ld b,000h		;a30a
	ldir		;a30c
L_A30E:
	jr L_A2D7		;a30e

; ----------------------------------------------------------------------
; QUE ENEMIGOS SALEN: UN BYTE DE BITS POR TRAMO DE PANTALLA
; La distancia recorrida, partida por 0x20, indexa una lista por fase
; (0xA3A6): sale UN BYTE cuyos seis bits bajos dicen que grupos de
; enemigos estan activos en ese tramo. 0xA359 lo va rotando bit a bit y
; llama a la rutina de cada grupo que este encendido. Asi cada trozo de
; fase tiene su mezcla de bichos sin necesidad de un guion largo.
; ----------------------------------------------------------------------
suelta_los_enemigos_del_tramo:		; Con el byte de bits del tramo, llama a la rutina de cada grupo de enemigos que este encendido
	ld hl,0e129h		;a310   ; 0xE129: los cuadros que faltan para la tanda siguiente
	ld a,(hl)			;a313
	and a			;a314
	jr z,L_A319		;a315
	dec (hl)			;a317
	ret			;a318
L_A319:
	ld a,(0e1c0h)		;a319   ; Con la pantalla parada, no
	and a			;a31c
	ret nz			;a31d
	ld a,(0e061h)		;a31e   ; De la fase novena en adelante, tampoco
	cp 009h		;a321
	ret nc			;a323
	ld a,(0e140h)		;a324   ; Ni con una tanda ya en marcha
	and a			;a327
	ret nz			;a328
	ld a,(0e064h)		;a329   ; Ni con 0xE064 en dos o mas
	cp 002h		;a32c
	ret nc			;a32e
	ld hl,(0e151h)		;a32f   ; Con el jefe en pantalla solo salen en algunos pasos
	ld a,l			;a332
	and a			;a333
	jr z,L_A345		;a334
	ld a,h			;a336
	sub 005h		;a337
	cp 002h		;a339
	jr c,L_A345		;a33b
	ld a,(0e160h)		;a33d
	and a			;a340
	jp nz,corre_la_tanda		;a341
	ret			;a344
L_A345:
	call corre_la_tanda		;a345
	ld a,(0e124h)		;a348   ; 0xE124: si acaba de salir uno
	and a			;a34b
	jr z,L_A359		;a34c
	ld hl,0e126h		;a34e
	ld a,00bh		;a351   ; Con once objetos menos los vivos por debajo de 0xE162, se espera
	sub (hl)			;a353
	ld hl,0e162h		;a354
	cp (hl)			;a357
	ret c			;a358
L_A359:
	call bits_del_tramo		;a359   ; El byte de bits del tramo
	rra			;a35c   ; Bit 0: el primer grupo
	push af			;a35d
	call c,suelta_la_pareja		;a35e
	pop af			;a361
	rra			;a362   ; Bit 1
	push af			;a363
	call c,suelta_el_reguero		;a364
	pop af			;a367
	rra			;a368   ; Bit 2
	push af			;a369
	call c,suelta_los_de_la_izquierda		;a36a
	pop af			;a36d
	rra			;a36e   ; Bit 3
	push af			;a36f
	call c,suelta_los_cuatro_de_abajo		;a370
	pop af			;a373
	rra			;a374   ; Bit 4
	push af			;a375
	call c,suelta_la_bandada		;a376
	pop af			;a379
	rra			;a37a   ; Y bit 5
	call c,suelta_los_ocho_mezclados		;a37b
	call mira_si_toca_pared		;a37e   ; Y detras, los cinco motores que corren siempre
	call mira_el_guion		;a381
	call mira_el_guion_de_los_1B		;a384
	call suelta_la_bandada_larga		;a387
	jp suelta_la_bandada_de_los_grandes		;a38a
bits_del_tramo:		; La distancia partida por 0x20 indexa la lista de la fase y devuelve el byte de bits
	ld a,(0e061h)		;a38d
	ld hl,la3a6h		;a390   ; La tabla de 0xA3A6: una lista por fase
	call 047aeh		;a393
	ld hl,(0e063h)		;a396   ; La distancia recorrida
	ld a,l			;a399
	rr h		;a39a   ; Partida por 0x20: el tramo
	rra			;a39c
	rra			;a39d
	rra			;a39e
	rra			;a39f
	rra			;a3a0
	and 00fh		;a3a1
	call 04062h		;a3a3
L_A3A6:
	ld a,(de)			;a3a6
	ret			;a3a7

; ----------------------------------------------------------------------
; DATOS tabla_A3A6 (tramo): Palabras que lee 0xA390 con la base 0xA3A6
;   (0xA3B8, 0xA3C8, 0xA3D8, ...) y, detras, lo que apuntan.
;   0xa3a8..0xa438  (144 bytes)  de 0xa3a6..0xa438 (146 bytes)
DATA_tabla_A3A6_A3A8:
	defw 0a3b8h,0a3c8h	; a3a8
	defw 0a3d8h,0a3e8h	; a3ac
	defw 0a3f8h,0a408h	; a3b0
	defw 0a418h,0a428h	; a3b4
	defw 00000h,00200h	; a3b8
	defw 00401h,00a06h	; a3bc
	defw 00a03h,00e05h	; a3c0
	defw 00000h,00000h	; a3c4
	defw 00100h,00101h	; a3c8
	defw 00200h,00002h	; a3cc
	defw 00200h,00000h	; a3d0
	defw 00000h,00000h	; a3d4
	defw 01000h,01010h	; a3d8
	defw 00000h,00000h	; a3dc
	defw 00000h,00000h	; a3e0
	defw 00000h,00000h	; a3e4
	defw 00101h,00202h	; a3e8
	defw 00501h,00e06h	; a3ec
	defw 00503h,0060fh	; a3f0
	defw 00020h,00000h	; a3f4
	defw 00100h,00303h	; a3f8
	defw 00000h,00000h	; a3fc
	defw 00000h,00000h	; a400
	defw 00000h,00000h	; a404
	defw 00100h,00101h	; a408
	defw 00000h,00000h	; a40c
	defw 00000h,00000h	; a410
	defw 00000h,00000h	; a414
	defw 00301h,00002h	; a418
	defw 00000h,00000h	; a41c
	defw 00000h,00000h	; a420
	defw 00000h,00000h	; a424
	defw 00301h,00402h	; a428
	defw 00404h,00404h	; a42c
	defw 00404h,00206h	; a430
	defw 00000h,00000h	; a434

; ======================================================================
; CODIGO 0xa438..0xa4a6  (110 bytes)
; ======================================================================


suelta_la_pareja:		; Cada 0x70 cuadros menos el doble de la dificultad saca dos bichos del tipo 3, uno por la fila 0x30 y otro por la 0x60
	ld hl,0e96ch		;a438   ; 0xE96C: los cuadros que faltan
	ld a,(hl)			;a43b
	and a			;a43c
	jr z,L_A441		;a43d
	dec (hl)			;a43f
	ret nz			;a440
L_A441:
	ld a,(0e126h)		;a441   ; Con once objetos vivos o mas, se deja para luego
	cp 00bh		;a444
	ret nc			;a446
	call espera_por_la_dificultad		;a447   ; Se recarga la espera para la pareja siguiente
	call marca_o_no_al_siguiente		;a44a
	ld a,c			;a44d
	ld b,c			;a44e
	cp 002h		;a44f   ; Con el ajuste a dos, cada uno se lleva el suyo
	jr nz,L_A45C		;a451
	ld a,r		;a453   ; El registro R: la unica moneda al aire del cartucho
	and 001h		;a455
	inc a			;a457
	ld c,a			;a458
	xor 003h		;a459   ; Uno saca 1 y el otro 2, o al reves
	ld b,a			;a45b
L_A45C:
	ld a,003h		;a45c
	ld de,0f030h		;a45e   ; La X 0xF0 y la Y 0x30: entra por la derecha, arriba
	push bc			;a461
	call 06a72h		;a462
	pop bc			;a465
	ld c,b			;a466
	ld de,0f060h		;a467   ; Y el segundo por la 0x60, mas abajo
	ld a,003h		;a46a
	jp 06a72h		;a46c
suelta_el_reguero:		; Una fila de bichos del tipo 4, uno cada ocho cuadros, entrando por cuatro alturas que se van turnando
	ld hl,0e960h		;a46f   ; 0xE960: cuantos quedan por salir
	ld a,(hl)			;a472
	and a			;a473
	jr z,arranca_otro_reguero		;a474
	inc l			;a476   ; 0xE961: los cuadros hasta el siguiente
	dec (hl)			;a477
	ret nz			;a478
	ld (hl),008h		;a479   ; Ocho cuadros entre bicho y bicho
	dec l			;a47b
	dec (hl)			;a47c   ; Uno menos por salir
	ld a,(hl)			;a47d
	and 003h		;a47e   ; Los dos bits bajos de la cuenta: la altura le toca por turno
	ld hl,0a4a6h		;a480
	call 0405dh		;a483
	ld e,(hl)			;a486
	ld d,0f0h		;a487   ; Siempre por la derecha
	ld c,000h		;a489
	ld a,004h		;a48b
	jp 06a72h		;a48d
arranca_otro_reguero:		; Se acabo la fila: la dificultad dice cuantos trae la siguiente
	ld a,(0e111h)		;a490   ; 0xE111, la dificultad, indexa la cuesta de 0xA4AA
	ld de,0a4aah		;a493
	call 04062h		;a496
	ld a,(de)			;a499
	ld (hl),a			;a49a
	inc l			;a49b
espera_por_la_dificultad:		; 0x70 menos el doble de la dificultad: cuanto mas dura la fase, menos se espera
	ld a,(0e111h)		;a49c
	add a,a			;a49f   ; La dificultad por dos, restada de 0x70
	sub 070h		;a4a0
	neg		;a4a2
	ld (hl),a			;a4a4
	ret			;a4a5

; ----------------------------------------------------------------------
; DATOS tabla_A4A6: Cuatro bytes (0x20, 0x80, 0x40, 0x70) que lee 0xA480.
;   0xa4a6..0xa4aa  (4 bytes)
DATA_tabla_A4A6:
	defb 020h,080h,040h,070h	; a4a6

; ----------------------------------------------------------------------
; DATOS rampa_A4AA: Dieciseis bytes en cuesta que lee 0xA493 con `ld
;   de,0xA4AA`.
;   0xa4aa..0xa4ba  (16 bytes)
DATA_rampa_A4AA:
	defb 003h,003h,003h,004h,004h,005h,005h,006h,006h,006h,007h,007h,007h,008h,008h,008h	; a4aa  ................

; ======================================================================
; CODIGO 0xa4ba..0xa5b0  (246 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LA TANDA QUE ENTRA EN FILA
; Seis bichos del mismo tipo entrando en fila por la derecha. La tanda se
; apunta en una de las cuatro fichas de grupo de 0xE900 con su cuenta, y
; p00:0x5E65 la va bajando segun caen; al caer el ultimo, el grupo se cierra
; y ese ultimo revienta con otro dibujo. La fase manda que tipo sale: el byte
; de 0xA5AF trae DOS tipos, uno en cada mitad, y se alternan tanda a tanda.
; ----------------------------------------------------------------------
corre_la_tanda:		; Los tres pasos de la tanda: sin empezar, esperando sitio, y soltando un bicho cada pocos cuadros
	ld hl,0e160h		;a4ba   ; 0xE160: por que paso va la tanda
	ld a,(hl)			;a4bd
	and a			;a4be
	jr z,monta_la_tanda		;a4bf
	dec a			;a4c1   ; El paso 1: esperando a que haya sitio
	jr z,espera_a_que_haya_sitio		;a4c2
	inc l			;a4c4   ; 0xE161: los cuadros hasta el siguiente
	dec (hl)			;a4c5
	ret nz			;a4c6
	ld a,(0e163h)		;a4c7   ; 0xE163, el tipo, dice cada cuanto salen
	ld b,004h		;a4ca
	cp 002h		;a4cc   ; El tipo 2 va de cuatro en cuatro
	jr z,L_A4E1		;a4ce
	ld b,010h		;a4d0
	cp 00ch		;a4d2   ; Y el 0x0C, de dieciseis en dieciseis
	jr z,L_A4E1		;a4d4
	ld b,004h		;a4d6
	ld a,(0e162h)		;a4d8   ; Los demas se emparejan: cuatro y uno, cuatro y uno
	bit 0,a		;a4db
	jr nz,L_A4E1		;a4dd
	ld b,001h		;a4df
L_A4E1:
	ld (hl),b			;a4e1   ; La espera, recargada
	inc l			;a4e2
	dec (hl)			;a4e3   ; Uno menos de los seis
	jr nz,L_A4EA		;a4e4
	dec l			;a4e6
	dec l			;a4e7
	ld (hl),000h		;a4e8   ; Y con el ultimo fuera, la tanda se acaba
L_A4EA:
	ld a,(0e165h)		;a4ea   ; 0xE165: la altura por la que entra toda la tanda
	ld e,a			;a4ed
	ld d,0f0h		;a4ee   ; La X 0xF0: por el borde derecho
	ld a,(0e163h)		;a4f0
	ld c,000h		;a4f3
	call 06a72h		;a4f5
	ld a,(0e124h)		;a4f8   ; 0xE124 se queda a cero si no habia ranura libre
	and a			;a4fb
	ret nz			;a4fc
	ld hl,0e162h		;a4fd   ; Sin sitio, el bicho se devuelve a la cuenta...
	inc (hl)			;a500
	dec l			;a501
	dec l			;a502
	ld (hl),001h		;a503   ; ...y la tanda vuelve al paso 1
	ret			;a505
espera_a_que_haya_sitio:		; Con siete objetos vivos o menos, la tanda arranca
	ld a,(0e126h)		;a506
	cp 007h		;a509
	ret nc			;a50b
	inc (hl)			;a50c
	ret			;a50d
monta_la_tanda:		; Cada ocho pasos de la fase monta una tanda nueva, con su tipo, su altura y su ficha de grupo
	ld a,(0e100h)		;a50e   ; Solo en los pasos que meten columna
	and a			;a511
	ret z			;a512
	ld hl,(0e063h)		;a513   ; La distancia recorrida
	ld de,00080h		;a516   ; Las tandas solo salen antes del paso 0x80...
	ld a,(0e061h)		;a519
	cp 008h		;a51c
	jr nz,L_A522		;a51e
	ld e,040h		;a520   ; ...y en la octava fase, antes del 0x40
L_A522:
	rst 20h			;a522
	ret nc			;a523
	ld a,l			;a524   ; Una tanda cada ocho pasos
	and 007h		;a525
	ret nz			;a527
	ld hl,00101h		;a528   ; 0xE160 a uno y 0xE161 a uno: la tanda empieza
	ld (0e160h),hl		;a52b
	ld a,(0e061h)		;a52e   ; La fase indexa la lista de 0xA5AF
	ld hl,la5afh		;a531
	add a,l			;a534
	ld l,a			;a535
	jr nc,L_A539		;a536
	inc h			;a538
L_A539:
	ld c,(hl)			;a539
	ld hl,0e166h		;a53a   ; 0xE166 sube uno por tanda, saltandose el cero
	ld a,(hl)			;a53d
	inc a			;a53e
	jr nz,L_A542		;a53f
	inc a			;a541
L_A542:
	ld (hl),a			;a542
	rra			;a543   ; Su bit 0 elige mitad: una tanda cada tipo
	ld a,c			;a544
	ld b,c			;a545
	jr nc,L_A54C		;a546
	rrca			;a548
	rrca			;a549
	rrca			;a54a
	rrca			;a54b
L_A54C:
	and 00fh		;a54c   ; El tipo de esta tanda, a 0xE163
	ld (0e163h),a		;a54e
	ld c,a			;a551
	ld a,(hl)			;a552   ; Los dos bits bajos: 0xE164 a cero o a uno
	and 003h		;a553
	jr z,L_A559		;a555
	ld a,001h		;a557
L_A559:
	ld (0e164h),a		;a559
	call altura_de_la_tanda		;a55c   ; La altura por la que entran
	ld (0e165h),a		;a55f
	ld a,006h		;a562   ; Seis bichos por tanda
	ld (0e162h),a		;a564
	xor a			;a567   ; Se busca una ficha de grupo libre en 0xE900
	call 05ebah		;a568
	jr nc,apunta_el_grupo		;a56b
	xor a			;a56d   ; Sin ficha libre no hay tanda
	ld (0e160h),a		;a56e
	ret			;a571
apunta_el_grupo:		; La ficha de 0xE900 se queda con el numero de tanda y, dos veces, con los seis que trae
	ld a,(0e166h)		;a572   ; El numero de tanda, en la ficha de grupo
	ld (hl),a			;a575
	inc l			;a576
	ld a,(0e162h)		;a577   ; Y los seis que trae, dos veces
	ld (hl),a			;a57a
	inc l			;a57b
	ld (hl),a			;a57c
	ret			;a57d
altura_de_la_tanda:		; Por donde entra: arriba o abajo para casi todos, y los tipos 0x0A y 0x0C tienen la suya
	ld a,c			;a57e
	cp 00ah		;a57f   ; El tipo 0x0A entra por 0x40 o por 0x80
	jr z,L_A5A0		;a581
	cp 00ch		;a583   ; Y el 0x0C, por 6 o por 0x98
	jr z,L_A5A8		;a585
	ld a,b			;a587   ; Las dos mitades del byte de la fase...
	and 00fh		;a588
	ld c,a			;a58a
	ld a,b			;a58b
	rra			;a58c
	rra			;a58d
	rra			;a58e
	rra			;a58f
	and 00fh		;a590
	cp c			;a592   ; ...y si son iguales, se mira otro bit
	ld c,(hl)			;a593
	jr z,L_A598		;a594
	rr c		;a596
L_A598:
	ld a,008h		;a598   ; La fila 8: por arriba
	bit 0,c		;a59a
	ret z			;a59c
	ld a,098h		;a59d   ; O la 0x98: por abajo
	ret			;a59f
L_A5A0:
	ld a,040h		;a5a0
	bit 1,(hl)		;a5a2
	ret z			;a5a4
	ld a,080h		;a5a5
	ret			;a5a7
L_A5A8:
	ld a,006h		;a5a8
	bit 1,(hl)		;a5aa
	ret z			;a5ac
	ld a,098h		;a5ad
L_A5AF:
	ret			;a5af

; ----------------------------------------------------------------------
; DATOS tabla_A5AF (tramo): Nueve bytes que lee 0xA531 con la base 0xA5AF.
;   0xa5b0..0xa5b8  (8 bytes)  de 0xa5af..0xa5b8 (9 bytes)
DATA_tabla_A5AF_A5B0:
	defb 022h,022h,02ah,02ah,02ah,0cah,022h,022h	; a5b0  ""***.""

; ======================================================================
; CODIGO 0xa5b8..0xa5c7  (15 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; UNO DE CADA CUATRO SALE MARCADO
; El ajuste que se le pasa a saca_un_objeto es la marca del bicho: con el
; a cero sale como los demas, y distinto de cero p01:0x6B0D le pone el
; color 8 -el rojo- y p00:0x5E88 le cambia lo que deja al morir. La tabla
; de 0xA5C7 la reparte en redondo: tres a cero y uno marcado, y una vez de
; cada dieciseis la marca es 2 en vez de 1.
; ----------------------------------------------------------------------
marca_o_no_al_siguiente:		; Un contador en redondo por la tabla de 0xA5C7: tres bichos de cada cuatro salen sin marca
	ld hl,0e125h		;a5b8   ; 0xE125: cuantos bichos van pedidos
	ld a,(hl)			;a5bb
	and 00fh		;a5bc   ; Los cuatro bits bajos: dieciseis casillas
	inc (hl)			;a5be   ; Y uno mas para el siguiente
	ld hl,0a5c7h		;a5bf
	call 0405dh		;a5c2
	ld c,(hl)			;a5c5
	ret			;a5c6

; ----------------------------------------------------------------------
; DATOS tabla_A5C7: Dieciseis bytes que lee 0xA5BF, en grupos de cuatro.
;   0xa5c7..0xa5d7  (16 bytes)
DATA_tabla_A5C7:
	defb 000h,000h,000h,001h	; a5c7
	defb 000h,000h,000h,001h	; a5cb
	defb 000h,000h,000h,002h	; a5cf
	defb 000h,000h,000h,001h	; a5d3

; ======================================================================
; CODIGO 0xa5d7..0xa640  (105 bytes)
; ======================================================================


suelta_la_bandada:		; Ocho bichos del tipo 9, uno cada siete cuadros: los cuatro primeros por abajo y los cuatro ultimos por arriba
	ld hl,0e962h		;a5d7   ; 0xE962: cuantos quedan de la bandada
	ld a,(hl)			;a5da
	and a			;a5db
	jp z,espera_a_la_bandada		;a5dc
	inc l			;a5df   ; 0xE963: los cuadros hasta el siguiente
	dec (hl)			;a5e0
	ret nz			;a5e1
	ld (hl),007h		;a5e2   ; Siete cuadros entre bicho y bicho
	dec l			;a5e4
	dec (hl)			;a5e5   ; Uno menos de los ocho
	jp nz,L_A5ED		;a5e6
	inc l			;a5e9
	ld (hl),03ch		;a5ea   ; Con la bandada fuera, 0x3C cuadros hasta la siguiente
	dec l			;a5ec
L_A5ED:
	ld a,(hl)			;a5ed   ; De cuatro en adelante...
	cp 004h		;a5ee
	ld e,088h		;a5f0   ; ...la fila 0x88, por abajo
	jp nc,L_A5F7		;a5f2
	ld e,018h		;a5f5   ; Y los cuatro ultimos por la 0x18
L_A5F7:
	ld d,0f0h		;a5f7   ; Los ocho entran por la derecha
	ld c,000h		;a5f9
	ld a,009h		;a5fb
	jp 06a72h		;a5fd
espera_a_la_bandada:		; Cuando se agota la cuenta atras, la bandada siguiente se monta con ocho
	inc l			;a600   ; 0xE963: los cuadros hasta la bandada siguiente
	ld a,(hl)			;a601
	or a			;a602
	jp z,L_A608		;a603
	dec (hl)			;a606
	ret nz			;a607
L_A608:
	inc (hl)			;a608
	dec l			;a609
	ld (hl),008h		;a60a   ; Ocho por bandada
	ret			;a60c
suelta_los_de_la_izquierda:		; Ocho bichos del tipo 5 que entran por el borde IZQUIERDO, turnandose entre la fila 8 y la 0x90
	ld hl,0e966h		;a60d   ; 0xE966: cuantos quedan
	ld a,(hl)			;a610
	and a			;a611
	jp z,monta_los_de_la_izquierda		;a612
	inc l			;a615   ; 0xE967: los cuadros hasta el siguiente
	dec (hl)			;a616
	ret nz			;a617
	ld a,(0e111h)		;a618   ; La dificultad por cuatro, restada de 0x70: la espera
	add a,a			;a61b
	add a,a			;a61c
	sub 070h		;a61d
	neg		;a61f
	ld (hl),a			;a621
	dec l			;a622
	dec (hl)			;a623   ; Uno menos
	ld a,(hl)			;a624
	and 007h		;a625   ; Los tres bits bajos: la fila le toca por turno
	ld hl,0a640h		;a627
	add a,l			;a62a
	ld l,a			;a62b
	jr nc,L_A62F		;a62c
	inc h			;a62e
L_A62F:
	ld e,(hl)			;a62f
	ld d,000h		;a630   ; La X a cero: estos entran por la IZQUIERDA
	call marca_o_no_al_siguiente		;a632   ; Con su marca, si le toca
	ld a,005h		;a635
	jp 06a72h		;a637
monta_los_de_la_izquierda:		; Otros ocho, y el primero al cuadro siguiente
	ld (hl),008h		;a63a
	inc l			;a63c
	ld (hl),001h		;a63d
	ret			;a63f

; ----------------------------------------------------------------------
; DATOS tabla_A640: Ocho bytes que lee 0xA627.
;   0xa640..0xa648  (8 bytes)
DATA_tabla_A640:
	defb 008h,090h,008h,008h,090h,008h,090h,090h	; a640  ........

; ======================================================================
; CODIGO 0xa648..0xa84f  (519 bytes)
; ======================================================================


suelta_los_cuatro_de_abajo:		; Cuatro bichos del tipo 6 por la fila 0x8F: los tres primeros por la derecha y el ultimo por la izquierda
	ld hl,0e96ah		;a648   ; 0xE96A: cuantos quedan de los cuatro
	ld a,(hl)			;a64b
	and a			;a64c
	jp z,monta_los_cuatro_de_abajo		;a64d
	inc l			;a650   ; 0xE96B: los cuadros hasta el siguiente
	dec (hl)			;a651
	ret nz			;a652
	ld a,(0e111h)		;a653   ; La dificultad por cuatro, restada de 0x60: la espera
	add a,a			;a656
	add a,a			;a657
	sub 060h		;a658
	neg		;a65a
	ld (hl),a			;a65c
	dec l			;a65d
	dec (hl)			;a65e   ; Uno menos
	ld a,(hl)			;a65f
	and 003h		;a660
	ld e,08fh		;a662   ; Todos por la fila 0x8F
	ld d,0f0h		;a664   ; Por la derecha...
	jp nz,L_A66B		;a666
	ld d,000h		;a669   ; ...menos el ultimo, que entra por la izquierda
L_A66B:
	call marca_o_no_al_siguiente		;a66b   ; Con su marca, si le toca
	ld a,006h		;a66e
	jp 06a72h		;a670
monta_los_cuatro_de_abajo:		; Otros cuatro, y el primero al cuadro siguiente
	ld (hl),004h		;a673
	inc l			;a675
	ld (hl),001h		;a676
	ret			;a678
suelta_los_ocho_mezclados:		; Ocho bichos: los cuatro primeros del tipo 5 por el lado contrario a la nave, y los cuatro ultimos del tipo 6 turnandose de lado
	ld hl,0e96ah		;a679   ; 0xE96A: la misma cuenta que 0xA648
	ld a,(hl)			;a67c
	and a			;a67d
	jp z,monta_los_ocho_mezclados		;a67e
	inc l			;a681
	dec (hl)			;a682
	ret nz			;a683
	ld a,(0e111h)		;a684   ; La dificultad por cuatro, restada de 0x50
	add a,a			;a687
	add a,a			;a688
	sub 050h		;a689
	neg		;a68b
	ld (hl),a			;a68d
	dec l			;a68e
	dec (hl)			;a68f
	ld a,(hl)			;a690
	cp 004h		;a691   ; Los cuatro primeros van por otro sitio
	jr nc,entra_por_el_lado_contrario		;a693
	bit 0,a		;a695   ; El bit 0 de la cuenta: un lado y el otro
	ld d,0f0h		;a697
	jr nz,L_A69D		;a699
	ld d,000h		;a69b
L_A69D:
	ld e,090h		;a69d   ; Los del tipo 6, por la fila 0x90
	ld c,000h		;a69f
	ld a,006h		;a6a1
	jp 06a72h		;a6a3
entra_por_el_lado_contrario:		; Mira por que mitad va la nave y suelta el bicho por la otra
	ld a,(0e204h)		;a6a6   ; 0xE204: la fila de la nave
	cp 058h		;a6a9   ; Por encima de la mitad de la pantalla...
	ld e,090h		;a6ab
	jr c,L_A6B1		;a6ad
	ld e,008h		;a6af   ; ...el bicho entra por arriba, y si no por abajo
L_A6B1:
	ld d,000h		;a6b1   ; Los del tipo 5, siempre por la izquierda
	ld c,000h		;a6b3
	ld a,005h		;a6b5
	jp 06a72h		;a6b7
monta_los_ocho_mezclados:		; Otros ocho, y el primero al cuadro siguiente
	ld (hl),008h		;a6ba
	inc l			;a6bc
	ld (hl),001h		;a6bd
	ret			;a6bf

; ----------------------------------------------------------------------
; AL MORIR EL JEFE, LA PANTALLA SE APAGA COMIENDOSE LA VRAM
; El cartucho no borra la pantalla para acabar la fase: se la come. Baja de
; la VRAM trozos de 0x200 bytes a 0xEA00, les hace un AND con una mascara
; y los vuelve a subir. Primero pasa una vez por la tabla de COLORES -que
; en este cartucho vive en la VRAM 0x0000- con la mascara 0xF0, y despues
; repite la pasada OCHO veces por la de PATRONES -la 0x2000- con 0xFE,
; 0xFC, 0xF8... hasta 0x00, y ademas girando la mascara
; tres bits por byte, de modo que el negro entra desmigado y no por filas.
; Lo llama el banco 2 desde dos jefes distintos, y cuando acaba pone 0xE1A3.
; ----------------------------------------------------------------------
apaga_la_pantalla:		; Los cuatro pasos del apagado: comerse los colores, comerse los patrones, limpiar 0xED00 y avisar
	ld hl,0e1a0h		;a6c0   ; 0xE1A0: por que paso va el apagado
	ld a,(hl)			;a6c3
	dec a			;a6c4
	jr z,come_los_patrones		;a6c5
	dec a			;a6c7
	jr z,limpia_el_buffer		;a6c8
	dec a			;a6ca
	jp z,avisa_de_que_ya_esta		;a6cb
	ld a,(0e1d0h)		;a6ce   ; Si no suena ya otra cosa, el sonido 0x3E
	and a			;a6d1
	ld a,03eh		;a6d2
	call z,049deh		;a6d4
	xor a			;a6d7   ; 0xE1A3 a cero: aun no ha acabado
	ld (0e1a3h),a		;a6d8
	inc l			;a6db   ; 0xE1A1 a cero: por la primera fila
	ld (hl),a			;a6dc
	inc l			;a6dd
	ld (hl),0f0h		;a6de   ; 0xE1A2: la mascara empieza en 0xF0
come_los_colores_de_fondo:		; Una pasada entera por la tabla de colores, de 0x40 en 0x40 filas
	ld a,(0e1a1h)		;a6e0   ; 0xE1A1: por que fila va
	cp 040h		;a6e3   ; El primer tercio no llega al 0x1000
	jr c,L_A6F3		;a6e5
	cp 080h		;a6e7
	jr nc,L_A6ED		;a6e9
	ld a,044h		;a6eb
L_A6ED:
	ld de,01000h		;a6ed   ; El tercer tercio de colores
	call come_un_trozo		;a6f0
L_A6F3:
	ld de,00800h		;a6f3   ; El segundo...
	call trozo_con_la_mascara_de_ahora		;a6f6
	ld de,00000h		;a6f9   ; ...y el primero
	call trozo_con_la_mascara_de_ahora		;a6fc
	ld hl,0e1a1h		;a6ff
	ld a,(hl)			;a702
	add a,040h		;a703   ; 0x40 filas mas
	ld (hl),a			;a705
	jr nz,come_los_colores_de_fondo		;a706
	dec l			;a708
	inc (hl)			;a709   ; Dada la vuelta, el paso 1
	inc l			;a70a
	inc l			;a70b
	ld (hl),0feh		;a70c   ; Y la mascara de patrones empieza en 0xFE
	ret			;a70e
come_los_patrones:		; La misma pasada, pero por la tabla de patrones y quitando un bit mas cada vuelta
	ld a,(0e1a1h)		;a70f
	cp 040h		;a712   ; Por debajo de la fila 0x40, solo dos tercios
	jr c,L_A722		;a714
	cp 080h		;a716   ; Y la fila 0x44 se lleva menos bytes
	jr nc,L_A71C		;a718
	ld a,044h		;a71a
L_A71C:
	ld de,03000h		;a71c   ; El tercer tercio de patrones
	call come_un_trozo		;a71f
L_A722:
	ld de,02800h		;a722   ; El segundo...
	call trozo_con_la_mascara_de_ahora		;a725
	ld de,02000h		;a728   ; ...y el primero
	call trozo_con_la_mascara_de_ahora		;a72b
	ld hl,0e1a1h		;a72e
	ld a,(hl)			;a731
	add a,040h		;a732
	ld (hl),a			;a734
	ret nz			;a735   ; Hasta dar la vuelta entera, nada
	inc l			;a736
	ld a,(hl)			;a737
	and a			;a738
	jr z,L_A73E		;a739
	sla (hl)		;a73b   ; Un bit menos en la mascara
	ret			;a73d
L_A73E:
	ld a,002h		;a73e   ; Con la mascara a cero ya esta todo negro: el paso 2
	ld (0e1a0h),a		;a740
	ret			;a743
limpia_el_buffer:		; Los 0x2C0 bytes de 0xED00 a cero, y al paso 3
	ld hl,0ed00h		;a744   ; 0xED00 en adelante...
	ld de,0ed01h		;a747
	ld bc,002bfh		;a74a   ; ...0x2C0 bytes a cero
	ld (hl),000h		;a74d
	ldir		;a74f
	ld a,003h		;a751   ; Y el paso 3
	ld (0e1a0h),a		;a753
	ret			;a756
avisa_de_que_ya_esta:		; Cuando calla el sonido, 0xE1A3 se pone y el banco 2 da al jefe por muerto
	ld a,(0e012h)		;a757   ; 0xE012: hasta que no calla el sonido, no
	and a			;a75a
	ret nz			;a75b
	ld a,001h		;a75c   ; 0xE1A3 a uno: el banco 2 ya puede seguir
	ld (0e1a3h),a		;a75e
	ret			;a761
trozo_con_la_mascara_de_ahora:		; Entra con la fila que toca en 0xE1A1
	ld a,(0e1a1h)		;a762
come_un_trozo:		; Baja 0x200 bytes de la VRAM a 0xEA00, les pasa la mascara y los vuelve a subir
	ld bc,00200h		;a765   ; Medio kilobyte de una vez
	cp 044h		;a768   ; Dos filas se llevan menos: la 0x44...
	jr nz,L_A76F		;a76a
	ld bc,001e0h		;a76c
L_A76F:
	cp 0c0h		;a76f   ; ...y la 0xC0
	jr nz,L_A776		;a771
	ld bc,001b0h		;a773
L_A776:
	ld l,a			;a776   ; La fila por ocho: el byte donde empieza
	ld h,000h		;a777
	add hl,hl			;a779
	add hl,hl			;a77a
	add hl,hl			;a77b
	add hl,de			;a77c
	push hl			;a77d
	ld de,0ea00h		;a77e   ; 0xEA00: el trozo se baja aqui
	push bc			;a781
	call 00059h		;a782   ; BIOS LDIRMV - Block transfers to memory from VRAM
	pop bc			;a785
	push bc			;a786
	ld hl,0ea00h		;a787
	ld a,(0e1a2h)		;a78a   ; 0xE1A2: la mascara de esta vuelta
	ld e,a			;a78d
	call pasa_la_mascara		;a78e
	pop bc			;a791
	pop hl			;a792
	ld de,0ea00h		;a793
	jp 04960h		;a796   ; Y el trozo, mordido, vuelve a la VRAM
pasa_la_mascara:		; En el primer paso la mascara es la misma para todos los bytes; en los demas gira tres bits por byte
	ld a,(0e1a0h)		;a799
	and a			;a79c
	jr nz,mascara_que_gira		;a79d
mascara_quieta:		; AND con la misma mascara byte a byte
	ld a,(hl)			;a79f   ; AND con la mascara, byte a byte
	and e			;a7a0
	ld (hl),a			;a7a1
	inc hl			;a7a2
	dec bc			;a7a3   ; Medio kilobyte
	ld a,b			;a7a4
	or c			;a7a5
	jr nz,mascara_quieta		;a7a6
	ret			;a7a8
mascara_que_gira:		; Tres bits de giro por byte: el negro entra desmigado
	ld a,(hl)			;a7a9   ; La misma mascara, girada tres bits...
	and e			;a7aa
	ld (hl),a			;a7ab
	inc hl			;a7ac
	rrc e		;a7ad
	rrc e		;a7af
	rrc e		;a7b1
	dec bc			;a7b3   ; ...en cada byte del trozo
	ld a,b			;a7b4
	or c			;a7b5
	jr nz,mascara_que_gira		;a7b6
	ret			;a7b8

; ----------------------------------------------------------------------
; CADA TIPO DE BICHO TIENE DOS RUTINAS, Y CASI TODAS ESTAN AQUI
; Un objeto se resume en un numero, su tipo, del 1 al 0x1F. Ese numero
; manda en dos tablas: la de p00:0x5DFD, que dice quien lo mueve cada
; cuadro, y la de p01:0x6B46, que dice quien acaba de montarlo al nacer.
; De los treinta y un tipos, VEINTE tienen aqui al menos una de sus dos
; rutinas, y DIECISEIS las dos; por eso 0xA7B9..0xB537 es el trozo de codigo
; mas largo del cartucho.
; ----------------------------------------------------------------------
remata_el_tipo_16:		; Sin velocidad y sin el bit 1 del byte 27
	res 1,(ix+01bh)		;a7b9
	jp 09510h		;a7bd
remata_el_tipo_17:		; Igual, y el byte 23 a uno
	res 1,(ix+01bh)		;a7c0
	ld (ix+017h),001h		;a7c4
	jp 09510h		;a7c8
remata_el_tipo_18:		; Igual, y el byte 23 a ocho
	res 1,(ix+01bh)		;a7cb
	ld (ix+017h),008h		;a7cf
	jp 09510h		;a7d3
remata_el_tipo_19:		; Solo las velocidades a cero
	jp 09510h		;a7d6
mueve_los_tipos_17_y_18:		; Se corren con el scroll y, al salirse, cortan la cadena de capsulas
	call 09251h		;a7d9
	ret nc			;a7dc
	jr L_A81C		;a7dd
mueve_el_tipo_1A:		; Se corre con el scroll y, al agotarse su cuenta, se convierte en el tipo que lleva apuntado en el byte 24
	call 09251h		;a7df   ; Se corre con el scroll
	jp c,se_fue_sin_cobrarse		;a7e2   ; Al salirse por el borde, por otro lado
	ld a,(ix+004h)		;a7e5
	or a			;a7e8
	jp z,L_A7EF		;a7e9
	dec (ix+004h)		;a7ec
L_A7EF:
	dec (ix+002h)		;a7ef   ; El byte 2: los cuadros que le quedan asi
	ret nz			;a7f2
	ld a,(ix+018h)		;a7f3   ; El byte 24 dice en que se convierte
	cp 016h		;a7f6   ; Con el 0x16 no se convierte: se apaga
	jp z,05fa5h		;a7f8
	dec (ix+017h)		;a7fb   ; Y el byte 23 cuenta las veces que puede
	jp z,05fa5h		;a7fe
	ld (ix+000h),a		;a801   ; El tipo nuevo, en su sitio
	ld (ix+00bh),001h		;a804   ; El byte 11 a uno: se dibuja con caracteres
	ld (ix+00ch),038h		;a808   ; Y el caracter 0x38
	set 0,(ix+01bh)		;a80c
	ld a,(ix+019h)		;a810   ; El byte 25 recarga la cuenta
	ld (ix+004h),a		;a813
	ret			;a816
se_fue_sin_cobrarse:		; Al irse por el borde, la cadena de capsulas vuelve a empezar
	ld a,(ix+017h)		;a817
	dec a			;a81a
	ret z			;a81b
L_A81C:
	xor a			;a81c
	ld (0e128h),a		;a81d   ; 0xE128 a cero: la capsula siguiente vuelve a pagar un punto
	ret			;a820
remata_el_tipo_3:		; Baja cuatro, va dos a la izquierda y se le curva la trayectoria
	ld de,00400h		;a821   ; Cuatro puntos por cuadro hacia abajo
	call 06cbfh		;a824
	call 09530h		;a827   ; Y esa misma cifra, de aceleracion horizontal
	ld de,0fe00h		;a82a   ; Dos a la izquierda
	call 06cc6h		;a82d
	ld de,0ff80h		;a830   ; Con medio punto de aceleracion vertical
	jp 09522h		;a833
mueve_el_tipo_3:		; Dispara, cambia de dibujo y se va curvando hasta que la velocidad iguala a la aceleracion
	call 09235h		;a836   ; Dispara sin apuntar
	call anima_el_tipo_3		;a839   ; Cambia de dibujo
	call 0953ch		;a83c   ; Y la curva: aceleracion mas velocidad
	call 09564h		;a83f
	call z,09519h		;a842
	ret			;a845
anima_el_tipo_3:		; Ocho dibujos, uno cada ocho cuadros, en ida y vuelta
	ld bc,00708h		;a846
	ld hl,0a84fh		;a849
	jp 095d1h		;a84c

; ----------------------------------------------------------------------
; DATOS tabla_A84F: Ocho bytes que lee 0xA849: una ida y vuelta (0x8C, 0x90,
;   0x94, 0x98, 0x9C, 0x98, 0x94, 0x90).
;   0xa84f..0xa857  (8 bytes)
DATA_tabla_A84F:
	defb 08ch,090h,094h,098h,09ch,098h,094h,090h	; a84f  ........

; ======================================================================
; CODIGO 0xa857..0xa933  (220 bytes)
; ======================================================================


remata_el_tipo_4:		; Sin velocidad vertical y punto y medio a la izquierda
	ld de,00000h		;a857
	call 06cbfh		;a85a
	ld de,0fe80h		;a85d
	jp 06cc6h		;a860

; ----------------------------------------------------------------------
; EL BICHO SE INCLINA HACIA DONDE VUELA
; El tipo 4 tiene tres dibujos -0xB0 de frente, 0xB4 inclinado hacia
; arriba y 0xB8 hacia abajo- y aqui se elige el que toca a la vez que la
; velocidad: si la nave le queda por encima toma el 0xB4 y sube, si le
; queda por debajo el 0xB8 y baja, y cuando ya esta en su fila el 0xB0 y
; solo avanza. Dibujo y rumbo salen del mismo sitio, asi que nunca se
; contradicen.
; ----------------------------------------------------------------------
mueve_el_tipo_4:		; Se pone a la altura de la nave y se inclina hacia donde va
	call 09235h		;a863
	ld a,(0e204h)		;a866   ; La fila de la nave menos la suya
	sub (ix+004h)		;a869
	push af			;a86c
	add a,003h		;a86d
	cp 007h		;a86f   ; A menos de siete ya esta en su fila
	jr c,L_A88A		;a871
	pop af			;a873
	jr c,L_A880		;a874
	ld a,0b8h		;a876   ; La nave por debajo: dibujo 0xB8 y punto y medio hacia abajo
	ld de,0fe80h		;a878
	ld bc,00180h		;a87b
	jr L_A89E		;a87e
L_A880:
	ld a,0b4h		;a880   ; Por encima: dibujo 0xB4 y punto y medio hacia arriba
	ld de,0fe80h		;a882
	ld bc,0fe80h		;a885
	jr L_A89E		;a888
L_A88A:
	pop af			;a88a
	ld a,(0e206h)		;a88b   ; En su fila ya: se mira la columna
	sub (ix+006h)		;a88e
	ld de,0fd00h		;a891   ; Con la nave por delante, tres puntos a la izquierda
	jr c,L_A899		;a894
	ld de,0fe80h		;a896   ; Y si no, punto y medio
L_A899:
	ld bc,00000h		;a899   ; Sin velocidad vertical: dibujo 0xB0
	ld a,0b0h		;a89c
L_A89E:
	ld (ix+00ch),a		;a89e   ; El dibujo elegido, al byte 12
	call 06cc6h		;a8a1
	ld d,b			;a8a4
	ld e,c			;a8a5
	jp 06cbfh		;a8a6
remata_el_tipo_2:		; Quieto y cuatro puntos a la izquierda
	call 09510h		;a8a9
	ld de,0fc00h		;a8ac
	jp 06cc6h		;a8af

; ----------------------------------------------------------------------
; EL BICHO QUE DA LA VUELTA
; El tipo 2 no cruza la pantalla de largo: entra por la derecha, y al
; llegar a la columna 0x81 -0x7F si va por la mitad de abajo- se curva
; hacia el centro y vuelve hacia atras; en la 0x9F se para y vuelve a
; tirar hacia la izquierda, esta vez hasta la 0x51; y cuando por fin se
; pone a la altura de la nave, deja de subir y bajar y se va de frente.
; Son cuatro pasos contados en el byte 1.
; ----------------------------------------------------------------------
mueve_el_tipo_2:		; Los cuatro pasos de la vuelta: hasta 0x81, atras hasta 0x9F, hasta 0x51, y de frente al ponerse a la altura de la nave
	ld a,(0e111h)		;a8b2   ; De la dificultad 8 en adelante, ademas dispara
	cp 008h		;a8b5
	call nc,09235h		;a8b7
	call anima_el_tipo_2		;a8ba   ; Cuatro dibujos, uno cada cuatro cuadros
	ld a,(ix+001h)		;a8bd   ; El byte 1: por que paso va
	dec a			;a8c0
	jr z,vuelve_hasta_la_columna_9F		;a8c1
	dec a			;a8c3
	jr z,otra_vez_hasta_la_51		;a8c4
	dec a			;a8c6
	jr z,ya_esta_a_la_altura_de_la_nave		;a8c7
	dec a			;a8c9
	ret z			;a8ca
	ld bc,0817fh		;a8cb   ; El tope del paso 0: 0x81 arriba y 0x7F abajo
L_A8CE:
	ld a,(ix+004h)		;a8ce   ; Por encima de la fila 0x50...
	cp 050h		;a8d1
	jr c,L_A8D6		;a8d3
	ld b,c			;a8d5   ; ...y por debajo, el otro tope
L_A8D6:
	ld a,(ix+006h)		;a8d6   ; Hasta llegar al tope, de frente
	cp b			;a8d9
	ret nc			;a8da
	inc (ix+001h)		;a8db
	ld de,00400h		;a8de   ; Cuatro hacia abajo si va por arriba...
	ld a,(ix+004h)		;a8e1
	cp 050h		;a8e4
	jr c,L_A8EB		;a8e6
	ld de,0fc00h		;a8e8   ; ...o cuatro hacia arriba si va por abajo
L_A8EB:
	call 06cbfh		;a8eb
	ld de,00400h		;a8ee   ; Y cuatro a la derecha: se vuelve
	jp 06cc6h		;a8f1
vuelve_hasta_la_columna_9F:		; Al llegar a la 0x9F cuadra la fila a ocho y vuelve a tirar hacia la izquierda
	ld a,(ix+006h)		;a8f4
	cp 09fh		;a8f7
	ret c			;a8f9
	ld a,(ix+004h)		;a8fa   ; La fila, cuadrada a ocho
	and 0f8h		;a8fd
	ld (ix+004h),a		;a8ff
	inc (ix+001h)		;a902
	jp remata_el_tipo_2		;a905
otra_vez_hasta_la_51:		; El mismo paso, con el tope en 0x51
	ld bc,0514fh		;a908
	jp L_A8CE		;a90b
ya_esta_a_la_altura_de_la_nave:		; A menos de nueve de su fila deja de subir y bajar y sigue de frente
	ld a,(0e204h)		;a90e   ; La fila de la nave menos la suya
	sub (ix+004h)		;a911
	add a,004h		;a914
	cp 009h		;a916
	ret nc			;a918
	inc (ix+001h)		;a919
	ld a,(ix+004h)		;a91c
	and 0f8h		;a91f
	ld (ix+004h),a		;a921
	xor a			;a924   ; Sin velocidad vertical
	ld d,a			;a925
	ld e,a			;a926
	jp 06cbfh		;a927
anima_el_tipo_2:		; Cuatro dibujos, uno cada cuatro cuadros
	ld bc,00304h		;a92a
	ld hl,0a933h		;a92d
	jp 095d1h		;a930

; ----------------------------------------------------------------------
; DATOS tabla_A933: Cuatro bytes (0, 1, 2, 3) que lee 0xA92D.
;   0xa933..0xa937  (4 bytes)
DATA_tabla_A933:
	defb 000h,001h,002h,003h	; a933

; ======================================================================
; CODIGO 0xa937..0xa9d0  (153 bytes)
; ======================================================================


remata_el_tipo_6:		; Sale disparado hacia arriba y hacia el centro de la pantalla, con 0x78 cuadros de cuerda
	ld (ix+01ch),078h		;a937   ; El byte 28: 0x78 cuadros de cuerda
	ld de,00060h		;a93b   ; 0x60 de aceleracion vertical...
	call 09522h		;a93e
	ld de,0fa00h		;a941   ; ...contra seis puntos por cuadro hacia arriba
	call 06cbfh		;a944
	call 09535h		;a947
	ld de,0fe00h		;a94a
	bit 7,(ix+006h)		;a94d   ; Por la mitad derecha, dos puntos a la izquierda...
	jp nz,06cc6h		;a951
	ld de,00200h		;a954   ; ...y por la izquierda, dos a la derecha
	jp 06cc6h		;a957
mueve_el_tipo_6:		; Sube hasta que se le acaba la cuerda o encuentra suelo, y entonces se lanza hacia la columna de la nave
	call 09235h		;a95a   ; Dispara sin apuntar
	call anima_el_tipo_6		;a95d   ; Cuatro dibujos, uno cada cuatro cuadros
	ld a,(ix+001h)		;a960   ; El byte 1: por que paso va
	dec a			;a963
	jr z,paso_1_del_tipo_6		;a964
	jp p,paso_2_del_tipo_6		;a966
	dec (ix+01ch)		;a969   ; Se le acaba la cuerda...
	jr z,pasa_de_paso		;a96c
	call 095a6h		;a96e   ; ...o le toca moverse
	jr c,pasa_de_paso		;a971
L_A973:
	call tiene_suelo_debajo		;a973
	jp nc,0953ch		;a976
	ld de,00200h		;a979   ; Dos puntos hacia la columna de la nave
	ld a,(0e206h)		;a97c   ; 0xE206: la columna de la nave
	sub (ix+006h)		;a97f
	jr nc,L_A987		;a982
	ld de,0fe00h		;a984
L_A987:
	call 06cc6h		;a987
	jp 09577h		;a98a
pasa_de_paso:		; Un paso mas y a seguir
	inc (ix+001h)		;a98d
	jp L_A973		;a990
paso_1_del_tipo_6:		; Al pillar suelo, dos puntos a la izquierda y a plantarse
	call tiene_suelo_debajo		;a993   ; Con suelo debajo, se planta
	jp nc,0953ch		;a996
	inc (ix+001h)		;a999
	ld de,0fe00h		;a99c   ; Dos puntos a la izquierda
	call 06cc6h		;a99f
	jp 09577h		;a9a2
paso_2_del_tipo_6:		; Ya solo se deja llevar por la aceleracion
	call tiene_suelo_debajo		;a9a5   ; Ya solo se deja llevar
	jp nc,0953ch		;a9a8
	jp 09577h		;a9ab
tiene_suelo_debajo:		; Subiendo no; bajando, y entre las filas 0x58 y 0x9F, mira si el mapa tiene pared 0x10 mas abajo
	ld a,(ix+008h)		;a9ae   ; El byte 8: subiendo, no hay nada que mirar
	or a			;a9b1
	ret m			;a9b2
	ld a,(ix+004h)		;a9b3   ; Por encima de la fila 0x58 tampoco...
	cp 058h		;a9b6
	ccf			;a9b8
	ret nc			;a9b9
	cp 09fh		;a9ba   ; ...ni por debajo de la 0x9F
	ccf			;a9bc
	ret c			;a9bd
	add a,010h		;a9be   ; 0x10 mas abajo: ahi se mira el mapa
	ld l,a			;a9c0
	ld h,(ix+006h)		;a9c1
	jp 09897h		;a9c4
anima_el_tipo_6:		; Cuatro dibujos, uno cada cuatro cuadros
	ld bc,00304h		;a9c7
	ld hl,0a9d0h		;a9ca
	jp 095d1h		;a9cd

; ----------------------------------------------------------------------
; DATOS tabla_A9D0: Cuatro bytes (0xA0, 0xA4, 0xA8, 0xAC) que lee 0xA9CA.
;   0xa9d0..0xa9d4  (4 bytes)
DATA_tabla_A9D0:
	defb 0a0h,0a4h,0a8h,0ach	; a9d0

; ======================================================================
; CODIGO 0xa9d4..0xab58  (388 bytes)
; ======================================================================


remata_el_tipo_5:		; Segun caiga por arriba o por abajo, un dibujo u otro, y dos puntos a la derecha
	ld a,(ix+004h)		;a9d4   ; El bit 7 de la fila: por que mitad entra
	or a			;a9d7
	ld b,000h		;a9d8   ; Por arriba, el dibujo 0xF8...
	ld c,0f8h		;a9da
	jp p,L_A9E2		;a9dc
	inc b			;a9df   ; ...y por abajo, el 0xE8
	ld c,0e8h		;a9e0
L_A9E2:
	ld (ix+013h),b		;a9e2   ; El byte 19 se apunta por donde entro
	ld (ix+00ch),c		;a9e5
	ld (ix+01ch),00ah		;a9e8   ; Diez cuadros de cuerda
	call cuanto_anda_este		;a9ec
	ld de,00000h		;a9ef   ; Sin velocidad vertical
	call 06cbfh		;a9f2
	ld de,00200h		;a9f5   ; Y dos puntos a la derecha
	jp 06cc6h		;a9f8

; ----------------------------------------------------------------------
; EL BICHO QUE ANDA PEGADO AL TERRENO
; El tipo 5 no vuela: camina por el suelo -o por el techo, segun por donde
; haya entrado- y para eso no lleva ningun mapa de alturas. En cada paso
; le pregunta al mapa que hay ocho puntos por debajo de sus pies: si hay
; pared, sube ocho; si no hay nada, baja ocho; y repite hasta encajar. Con
; 0xE969 a uno encaja de golpe -al plantarse- y a cero da un escalon por
; cuadro, que es lo que le da el andar a saltitos.
; ----------------------------------------------------------------------
mueve_el_tipo_5:		; Anda pegado al terreno hasta que se le acaba la cuenta; entonces se planta, dispara y se va
	ld a,(ix+001h)		;a9fb   ; El byte 1: por que paso va
	dec a			;a9fe
	jr z,el_tipo_5_esta_plantado		;a9ff
	jp p,el_tipo_5_ya_se_va		;aa01
	call 095a6h		;aa04   ; Si le toca moverse, se larga
	jr c,el_tipo_5_se_larga		;aa07
	dec (ix+002h)		;aa09   ; El byte 2: los cuadros que le quedan andando
	jr z,el_tipo_5_se_planta		;aa0c
	call un_escalon_por_cuadro		;aa0e   ; Un escalon de terreno por cuadro
	jp anima_el_tipo_5		;aa11
el_tipo_5_se_planta:		; Se encaja del todo en el terreno, se queda 0x5A cuadros y deja de avanzar
	inc (ix+001h)		;aa14
	ld (ix+002h),05ah		;aa17   ; 0x5A cuadros plantado
	call mira_hacia_la_nave		;aa1b
	call encajate_del_todo		;aa1e
	call cuando_vuelve_a_disparar		;aa21
	ld de,00000h		;aa24   ; Sin velocidad horizontal: quieto
	jp 06cc6h		;aa27
el_tipo_5_se_larga:		; Paso 2 y dos puntos a la izquierda
	ld (ix+001h),002h		;aa2a
	ld de,0fe00h		;aa2e
	jp 06cc6h		;aa31
el_tipo_5_esta_plantado:		; Aguanta los 0x5A cuadros y luego echa a andar hacia la columna de la nave
	call 095a6h		;aa34
	jr c,el_tipo_5_se_larga		;aa37
	dec (ix+002h)		;aa39   ; Los cuadros que le quedan plantado
	jr z,L_AA44		;aa3c
	call dispara_si_la_nave_le_cae_en_el_arco		;aa3e
	jp 09251h		;aa41
L_AA44:
	dec (ix+001h)		;aa44   ; Se vuelve al paso de andar
	call cuanto_anda_este		;aa47
	ld a,(0e206h)		;aa4a   ; 0xE206: la columna de la nave
	cp (ix+006h)		;aa4d
	ld de,00200h		;aa50   ; Dos puntos hacia ese lado
	jr nc,L_AA58		;aa53
	ld de,0fe00h		;aa55
L_AA58:
	jp 06cc6h		;aa58
el_tipo_5_ya_se_va:		; Sigue pegado al terreno mientras se aleja
	call anima_el_tipo_5		;aa5b
	jr un_escalon_por_cuadro		;aa5e
encajate_del_todo:		; 0xE969 a uno: se busca el terreno hasta encajar en el mismo cuadro
	ld a,001h		;aa60
	jr L_AA65		;aa62
un_escalon_por_cuadro:		; 0xE969 a cero: solo un escalon de ocho puntos por cuadro
	xor a			;aa64
L_AA65:
	ld (0e969h),a		;aa65
	bit 0,(ix+013h)		;aa68   ; El bit 0 del byte 19: si entro por arriba anda por el suelo, y si no, por el techo
	jr z,busca_el_techo		;aa6c
busca_el_suelo:		; Mira el mapa 0x10 por debajo: sin pared baja ocho, y con pared sube hasta encajar
	ld h,(ix+006h)		;aa6e   ; 0x10 por debajo de sus pies
	ld a,(ix+004h)		;aa71
	add a,010h		;aa74
	ld l,a			;aa76
	call 09897h		;aa77   ; Ahi se le pregunta al mapa
	jr nc,baja_hasta_el_suelo		;aa7a
sube_hasta_encajar:		; Con pared ocho puntos mas abajo, se sube ocho
	ld h,(ix+006h)		;aa7c
	ld a,(ix+004h)		;aa7f
	add a,008h		;aa82   ; Ocho por debajo
	ld l,a			;aa84
	call 09897h		;aa85
	ret nc			;aa88
	ld a,(ix+004h)		;aa89
	sub 008h		;aa8c   ; Ocho puntos mas arriba
	ld (ix+004h),a		;aa8e
	ld a,(0e969h)		;aa91   ; Con 0xE969 a cero, solo un escalon por cuadro
	or a			;aa94
	ret z			;aa95
	jr sube_hasta_encajar		;aa96
baja_hasta_el_suelo:		; Sin nada debajo, baja de ocho en ocho hasta la fila 0x90
	ld a,(ix+004h)		;aa98
	cp 090h		;aa9b   ; Por debajo de la fila 0x90 ya no
	ret nc			;aa9d
	add a,008h		;aa9e
	ld (ix+004h),a		;aaa0
	ld a,(0e969h)		;aaa3
	or a			;aaa6
	ret z			;aaa7
	jr busca_el_suelo		;aaa8
busca_el_techo:		; El mismo baile, pero al reves: se pega por arriba
	ld h,(ix+006h)		;aaaa
	ld l,(ix+004h)		;aaad
	call 09897h		;aab0   ; Ahi se le pregunta al mapa
	jr nc,sube_hasta_el_techo		;aab3
	ld a,(ix+004h)		;aab5
	add a,008h		;aab8   ; Sin techo donde esta, baja ocho
	ld (ix+004h),a		;aaba
	ld a,(0e969h)		;aabd
	or a			;aac0
	ret z			;aac1
	jr busca_el_techo		;aac2
sube_hasta_el_techo:		; Mientras haya sitio ocho mas arriba, sube, y no pasa de la fila 9
	ld h,(ix+006h)		;aac4   ; Ocho puntos por encima
	ld a,(ix+004h)		;aac7
	sub 008h		;aaca
	ld l,a			;aacc
	call 09897h		;aacd   ; Ahi se le pregunta al mapa
	ret c			;aad0
	ld a,(ix+004h)		;aad1
	cp 009h		;aad4   ; Por encima de la fila 9 ya no
	ret c			;aad6
	ld a,(ix+004h)		;aad7
	sub 008h		;aada   ; Ocho puntos mas arriba
	ld (ix+004h),a		;aadc
	ld a,(0e969h)		;aadf
	or a			;aae2
	ret z			;aae3
	jr sube_hasta_el_techo		;aae4
cuanto_anda_este:		; Entre 0x2D y 0x4C cuadros andando, echados a suertes con el registro R
	ld a,r		;aae6   ; El registro R, la moneda al aire del cartucho
	and 01fh		;aae8
	add a,02dh		;aaea
	ld (ix+002h),a		;aaec
	ret			;aaef
cuando_vuelve_a_disparar:		; 0x3C cuadros menos el doble de la dificultad
	ld a,(0e111h)		;aaf0   ; La dificultad por dos...
	add a,a			;aaf3
	sub 03ch		;aaf4   ; ...restada de 0x3C
	neg		;aaf6
	ld (ix+010h),a		;aaf8
	ret			;aafb
dispara_si_la_nave_le_cae_en_el_arco:		; Al agotarse la espera mide el angulo hasta la nave y solo dispara si la tiene delante
	dec (ix+010h)		;aafc   ; El byte 16: los cuadros hasta el disparo
	ret nz			;aaff
	call cuando_vuelve_a_disparar		;ab00   ; Recargada la espera
	call mira_hacia_la_nave		;ab03   ; Y el dibujo, hacia donde este la nave
	bit 0,(ix+013h)		;ab06   ; El bit 0 del byte 19: si anda por el suelo...
	jr z,L_AB15		;ab0a
	ld a,(0e204h)		;ab0c   ; ...la nave tiene que quedarle por encima
	cp (ix+004h)		;ab0f
	ret nc			;ab12
	jr L_AB1C		;ab13
L_AB15:
	ld a,(0e204h)		;ab15   ; Y si anda por el techo, por debajo
	cp (ix+004h)		;ab18
	ret c			;ab1b
L_AB1C:
	ld e,(ix+004h)		;ab1c
	ld d,(ix+006h)		;ab1f
	call 066d5h		;ab22   ; De ahi sale el angulo hasta la nave, en 0xEC18
	ld a,(0ec18h)		;ab25
	cp 080h		;ab28   ; Doblado a media vuelta...
	jr c,L_AB2E		;ab2a
	neg		;ab2c
L_AB2E:
	cp 040h		;ab2e   ; ...y a un cuarto
	jr c,L_AB34		;ab30
	sub 040h		;ab32
L_AB34:
	sub 008h		;ab34   ; Solo dispara si le cae dentro de 0x30
	cp 030h		;ab36
	ret nc			;ab38
	jp 09239h		;ab39
anima_el_tipo_5:		; Dos dibujos, uno cada cuatro cuadros; el par sale de si sube o baja y de si anda por el suelo o por el techo
	ld a,(ix+00ah)		;ab3c   ; El byte 10: subiendo o bajando
	or a			;ab3f
	ld hl,0ab58h		;ab40
	jp p,L_AB48		;ab43
	inc hl			;ab46
	inc hl			;ab47
L_AB48:
	bit 0,(ix+013h)		;ab48   ; Y por el suelo o por el techo: cuatro pares en total
	jr z,L_AB52		;ab4c
	ld bc,00004h		;ab4e
	add hl,bc			;ab51
L_AB52:
	ld bc,00302h		;ab52   ; Dos dibujos, uno cada cuatro cuadros
	jp 095d1h		;ab55

; ----------------------------------------------------------------------
; DATOS tabla_AB58: Ocho bytes que lee 0xAB40.
;   0xab58..0xab60  (8 bytes)
DATA_tabla_AB58:
	defb 0f4h,0f8h,0d0h,0d4h,0e8h,0ech,0dch,0e0h	; ab58  ........

; ======================================================================
; CODIGO 0xab60..0xabd3  (115 bytes)
; ======================================================================


mira_hacia_la_nave:		; El dibujo cambia segun la nave le quede a un lado o al otro
	bit 0,(ix+013h)		;ab60   ; El bit 0 del byte 19: suelo o techo
	jr z,L_AB76		;ab64
	ld b,0f0h		;ab66   ; Andando por el suelo, el 0xF0...
	ld a,(0e206h)		;ab68
	cp (ix+006h)		;ab6b
	jr nc,L_AB72		;ab6e
	ld b,0e4h		;ab70   ; ...o el 0xE4 si la nave va por delante
L_AB72:
	ld (ix+00ch),b		;ab72
	ret			;ab75
L_AB76:
	ld b,0fch		;ab76   ; Y por el techo, el 0xFC...
	ld a,(0e206h)		;ab78
	cp (ix+006h)		;ab7b
	jr nc,L_AB82		;ab7e
	ld b,0d8h		;ab80   ; ...o el 0xD8
L_AB82:
	ld (ix+00ch),b		;ab82
	ret			;ab85

; ----------------------------------------------------------------------
; LA LLUVIA DE PIEDRAS
; Un cronometro de 0x384 cuadros -quince segundos- durante el cual cada
; pocos cuadros cae una piedra del tipo 8. De donde sale cada una lo echa
; a suertes el registro R entre las dieciseis posiciones de 0xABD3, y cada
; cuanto cae lo manda la dificultad: 0x14 cuadros menos 0xE111. Al agotarse
; el cronometro se llama a p01:0x7D64 y la fase sigue.
; ----------------------------------------------------------------------
arranca_la_lluvia:		; El cronometro a 0x384 cuadros y la cadencia a 0x14 menos la dificultad
	ld hl,0e970h		;ab86   ; 0xE970: el cronometro, 0x384 cuadros
	ld bc,00384h		;ab89
	ld (hl),c			;ab8c
	inc l			;ab8d
	ld (hl),b			;ab8e
	ld a,001h		;ab8f   ; 0xE972 a uno: la lluvia esta en marcha
	inc l			;ab91
	ld (hl),a			;ab92
	inc l			;ab93
	ld a,(0e111h)		;ab94   ; 0x14 menos la dificultad: los cuadros entre piedra y piedra
	sub 014h		;ab97
	neg		;ab99
	inc l			;ab9b
	ld hl,0e974h		;ab9c
	ld (hl),a			;ab9f
	inc l			;aba0
	ld (hl),a			;aba1
	ret			;aba2
cae_una_piedra:		; Baja el cronometro y, cada pocos cuadros, suelta una piedra por una de las dieciseis puertas de 0xABD3
	ld a,(0e1c0h)		;aba3   ; Con la pantalla parada, no
	and a			;aba6
	ret nz			;aba7
	ld a,(0e972h)		;aba8   ; 0xE972: solo si la lluvia esta en marcha
	or a			;abab
	ret z			;abac
	ld hl,(0e970h)		;abad   ; Un cuadro menos de lluvia
	dec hl			;abb0
	ld (0e970h),hl		;abb1
	ld a,l			;abb4
	or h			;abb5
	jp z,07d64h		;abb6   ; Agotado el cronometro, la fase sigue
	ld hl,0e974h		;abb9   ; 0xE974: los cuadros hasta la piedra siguiente
	dec (hl)			;abbc
	ret nz			;abbd
	inc l			;abbe
	ld a,(hl)			;abbf   ; Recargados desde 0xE975
	dec l			;abc0
	ld (hl),a			;abc1
	ld a,r		;abc2   ; El registro R elige una de las dieciseis puertas
	and 00fh		;abc4
	ld hl,0abd3h		;abc6
	call 047aeh		;abc9
L_ABCC:
	ld c,000h		;abcc
	ld a,008h		;abce   ; El tipo 8: la piedra
	jp 06a72h		;abd0

; ----------------------------------------------------------------------
; DATOS tabla_ABD3: Treinta y dos bytes que lee 0xABC6, en parejas.
;   0xabd3..0xabf3  (32 bytes)
DATA_tabla_ABD3:
	defb 008h,010h	; abd3
	defb 098h,010h	; abd5
	defb 020h,030h	; abd7
	defb 048h,030h	; abd9
	defb 070h,048h	; abdb
	defb 048h,060h	; abdd
	defb 030h,080h	; abdf
	defb 098h,080h	; abe1
	defb 008h,090h	; abe3
	defb 028h,0a8h	; abe5
	defb 080h,0a8h	; abe7
	defb 018h,0c0h	; abe9
	defb 060h,0c0h	; abeb
	defb 008h,0d8h	; abed
	defb 008h,0f0h	; abef
	defb 098h,0f0h	; abf1

; ======================================================================
; CODIGO 0xabf3..0xac7c  (137 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LAS PAREDES DE PIEDRAS DE LAS FASES 2 Y 8
; Aqui no hay guion de tiempo: hay una lista de DISTANCIAS. Cada paso con
; columna nueva se recorre la lista de la fase -0xAC81 para la segunda y
; 0xAC8D para la octava- y se compara cada distancia con la recorrida; al
; caer justo, se suelta una pared de cinco piedras (tres en la octava) por
; una columna o por la otra, una por cuadro. El bit 7 de la distancia, que
; se aparta antes de comparar, es el que dice por que lado entran.
; ----------------------------------------------------------------------
mira_si_toca_pared:		; Compara la distancia recorrida con la lista de la fase y, al coincidir, monta una pared de piedras
	ld a,(0e978h)		;abf3   ; 0xE978: con una pared en marcha, a soltarla
	or a			;abf6
	jp nz,suelta_la_pared		;abf7
	ld a,(0e100h)		;abfa   ; Solo en los pasos con columna nueva
	or a			;abfd
	ret z			;abfe
	ld a,(0e061h)		;abff   ; La fase segunda tiene su lista...
	cp 002h		;ac02
	jp z,L_AC13		;ac04
	cp 008h		;ac07   ; ...y la octava la suya; las demas no llevan
	ret nz			;ac09
	ld hl,0ac8dh		;ac0a   ; Diecisiete distancias, y las paredes de tres
	ld bc,01101h		;ac0d
	jp L_AC19		;ac10
L_AC13:
	ld hl,0ac81h		;ac13   ; Seis distancias, y las paredes de cinco
	ld bc,00600h		;ac16
L_AC19:
	ld (0ec00h),hl		;ac19   ; La lista y la cuenta, aparcadas en 0xEC00
	ld (0ec02h),bc		;ac1c
recorre_las_distancias:		; Una por una, contra la distancia recorrida
	push bc			;ac20
	ld a,(0ec03h)		;ac21   ; De la cuenta sale el indice
	sub b			;ac24
	ld hl,(0ec00h)		;ac25
	call 047aeh		;ac28   ; La palabra que toca de la lista
	ld a,d			;ac2b
	exx			;ac2c   ; El byte alto se guarda entero...
	ld d,a			;ac2d
	exx			;ac2e
	and 07fh		;ac2f   ; ...y se compara sin su bit 7
	ld d,a			;ac31
	ld hl,(0e063h)		;ac32   ; DCOMPR contra la distancia recorrida
	rst 20h			;ac35
	pop bc			;ac36
	jp z,monta_la_pared		;ac37   ; Justo esta: pared
	djnz recorre_las_distancias		;ac3a
	ret			;ac3c
monta_la_pared:		; El bit 7 de la distancia elige la columna, y la fase cuantas piedras trae
	exx			;ac3d
	rl d		;ac3e   ; El bit 7 apartado antes: por que lado entran
	ld a,0c0h		;ac40   ; La columna 0xC0...
	jp nc,L_AC47		;ac42
	ld a,040h		;ac45   ; ...o la 0x40
L_AC47:
	ld (0e97ah),a		;ac47   ; 0xE97A: por ahi caen todas
	ld hl,00501h		;ac4a   ; Cinco piedras, una por cuadro...
	ld a,(0ec02h)		;ac4d
	or a			;ac50
	jp z,L_AC57		;ac51
	ld hl,00302h		;ac54   ; ...o tres de dos en dos cuadros
L_AC57:
	ld (0e978h),hl		;ac57
	ret			;ac5a
suelta_la_pared:		; Una piedra por cuadro, cada una en su fila, hasta agotar la cuenta
	ld hl,lac7bh		;ac5b   ; La base de la tabla cae sobre el `ret` de aqui al lado: nunca se lee, porque el indice nunca vale cero
	dec a			;ac5e
	jp z,L_AC63		;ac5f
	inc hl			;ac62
L_AC63:
	ld a,(0e979h)		;ac63   ; 0xE979: cual toca
	add a,l			;ac66
	ld l,a			;ac67
	jr nc,L_AC6B		;ac68
	inc h			;ac6a
L_AC6B:
	ld e,(hl)			;ac6b
	ld a,(0e97ah)		;ac6c   ; Todas por la misma columna
	ld d,a			;ac6f
	call L_ABCC		;ac70   ; El tipo 8: la piedra
	ld hl,0e979h		;ac73
	dec (hl)			;ac76   ; Una menos
	ret nz			;ac77
	dec l			;ac78
	ld (hl),000h		;ac79   ; Y con la ultima, la pared se acaba
L_AC7B:
	ret			;ac7b

; ----------------------------------------------------------------------
; DATOS tabla_AC7B (tramo): Seis bytes que lee 0xAC5B con la base 0xAC7B.
;   0xac7c..0xac81  (5 bytes)  de 0xac7b..0xac81 (6 bytes)
DATA_tabla_AC7B_AC7C:
	defb 08ch,06ch,04ch,02ch,00ch	; ac7c

; ----------------------------------------------------------------------
; DATOS tabla_AC81: Doce bytes que lee 0xAC13.
;   0xac81..0xac8d  (12 bytes)
DATA_tabla_AC81:
	defb 044h,001h	; ac81
	defb 04ch,001h	; ac83
	defb 070h,001h	; ac85
	defb 078h,001h	; ac87
	defb 080h,001h	; ac89
	defb 088h,001h	; ac8b

; ----------------------------------------------------------------------
; DATOS tabla_AC8D: Treinta y cuatro bytes que lee 0xAC0A, en parejas.
;   0xac8d..0xacaf  (34 bytes)
DATA_tabla_AC8D:
	defb 088h,000h	; ac8d
	defb 090h,000h	; ac8f
	defb 0c8h,000h	; ac91
	defb 0d0h,000h	; ac93
	defb 004h,001h	; ac95
	defb 01ch,001h	; ac97
	defb 024h,001h	; ac99
	defb 050h,001h	; ac9b
	defb 058h,001h	; ac9d
	defb 060h,001h	; ac9f
	defb 062h,081h	; aca1
	defb 068h,001h	; aca3
	defb 06ah,081h	; aca5
	defb 070h,001h	; aca7
	defb 072h,081h	; aca9
	defb 078h,001h	; acab
	defb 07ah,081h	; acad

; ======================================================================
; CODIGO 0xacaf..0xad18  (105 bytes)
; ======================================================================


remata_el_tipo_8:		; Contadores a cero, diez cuadros en el byte 2 y quieta
	xor a			;acaf
	ld (ix+01bh),a		;acb0
	ld (ix+01dh),a		;acb3
	ld (ix+002h),00ah		;acb6   ; Diez cuadros
	jp 09510h		;acba
mueve_el_tipo_8:		; La piedra crece en tres pasos de diez cuadros y, ya crecida, se queda quieta disparando
	ld a,(ix+001h)		;acbd   ; El byte 1: si ya ha crecido
	or a			;acc0
	jr nz,la_piedra_dispara		;acc1
	call 09251h		;acc3   ; Mientras crece se corre con el scroll
	dec (ix+002h)		;acc6   ; Diez cuadros por paso
	ret nz			;acc9
	inc (ix+01dh)		;acca   ; Un paso mas de los tres
	ld a,(ix+01dh)		;accd
	cp 003h		;acd0
	jr nc,L_ACDA		;acd2
	ld (ix+002h),00ah		;acd4   ; Otros diez cuadros
	jr dibujo_de_la_piedra		;acd8
L_ACDA:
	ld (ix+01bh),003h		;acda   ; El byte 27 a tres: ya esta crecida
	inc (ix+001h)		;acde
	call dibujo_de_la_piedra		;ace1   ; El dibujo grande
	call velocidad_de_sus_disparos		;ace4   ; Y la velocidad de sus disparos
	jp 06c61h		;ace7
la_piedra_dispara:		; Ya crecida, cada ocho cuadros suelta un disparo
	ld a,(0e06ah)		;acea   ; 0xE06A: en la primera vuelta no dispara
	dec a			;aced
	ret m			;acee
	jr nz,L_ACFC		;acef
	ld a,(0e200h)		;acf1   ; Con la nave a medio explotar, tampoco
	cp 003h		;acf4
	ret c			;acf6
	ld a,(0e20eh)		;acf7
	or a			;acfa
	ret z			;acfb
L_ACFC:
	ld a,(0e008h)		;acfc   ; El bit 4 de 0xE008
	and 010h		;acff
	ret z			;ad01
	ld a,(0e003h)		;ad02   ; Uno de cada ocho cuadros
	and 007h		;ad05
	ret nz			;ad07
	jp 09239h		;ad08
dibujo_de_la_piedra:		; Del par de 0xAD16 salen el caracter y el color: 0xC0 en 5, 0xC4 en 7 y 0xC8 en 0x0F
	ld hl,0ad16h		;ad0b   ; La tabla de 0xAD16, en parejas
	call 047aeh		;ad0e
	ld (ix+00ch),d		;ad11   ; El caracter al byte 12 y el color al 13
	ld (ix+00dh),e		;ad14
	ret			;ad17

; ----------------------------------------------------------------------
; DATOS tabla_AD16 (tramo): Ocho bytes que lee 0xAD0B con la base 0xAD16, en
;   parejas.
;   0xad18..0xad1e  (6 bytes)  de 0xad16..0xad1e (8 bytes)
DATA_tabla_AD16_AD18:
	defb 005h,0c0h	; ad18
	defb 007h,0c4h	; ad1a
	defb 00fh,0c8h	; ad1c

; ======================================================================
; CODIGO 0xad1e..0xad68  (74 bytes)
; ======================================================================


velocidad_de_sus_disparos:		; 0x40 mas la dificultad
	ld a,(0e111h)		;ad1e
	add a,040h		;ad21
	ld (0e110h),a		;ad23
	ret			;ad26
remata_el_tipo_9:		; Sin velocidad vertical y tres puntos a la izquierda
	ld de,00000h		;ad27
	call 06cbfh		;ad2a
	ld de,0fd00h		;ad2d
	jp 06cc6h		;ad30
mueve_el_tipo_9:		; Cruza recto y, pasada la mitad de la pantalla, se pone a la altura de la nave
	call 09235h		;ad33   ; Dispara sin apuntar
	ld bc,00306h		;ad36   ; Seis dibujos, uno cada cuatro cuadros
	ld hl,0ad68h		;ad39
	call 095d1h		;ad3c
	ld a,(ix+006h)		;ad3f   ; Hasta la columna 0x80 va recto
	cp 080h		;ad42
	ret nc			;ad44
	ld a,(0e204h)		;ad45   ; La fila de la nave menos la suya
	sub (ix+004h)		;ad48
	push af			;ad4b
	add a,003h		;ad4c
	cp 007h		;ad4e   ; A menos de siete ya esta en su fila
	jr c,ya_esta_en_la_fila_de_la_nave		;ad50
	pop af			;ad52
	jr c,sube_hacia_la_nave		;ad53
	ld de,00100h		;ad55   ; La nave por debajo: un punto por cuadro hacia abajo
	jp 06cbfh		;ad58
sube_hacia_la_nave:		; Un punto por cuadro hacia arriba
	ld de,0ff00h		;ad5b   ; Por encima: uno hacia arriba
	jp 06cbfh		;ad5e
ya_esta_en_la_fila_de_la_nave:		; Se queda a esa altura
	pop af			;ad61
	ld de,00000h		;ad62   ; Y en su fila, ni sube ni baja
	jp 06cbfh		;ad65

; ----------------------------------------------------------------------
; DATOS tabla_AD68: Seis bytes que lee 0xAD39: una ida y vuelta (0xEC, 0xF0,
;   0xF4, 0xF8, 0xF4, 0xF0).
;   0xad68..0xad6e  (6 bytes)
DATA_tabla_AD68:
	defb 0ech,0f0h,0f4h,0f8h,0f4h,0f0h	; ad68

; ======================================================================
; CODIGO 0xad6e..0xadb3  (69 bytes)
; ======================================================================


remata_el_tipo_0A:		; Los de la tanda se curvan alternandose: uno hacia arriba y el siguiente hacia abajo
	ld de,00080h		;ad6e
	ld bc,0fc00h		;ad71
	ld a,(0e162h)		;ad74   ; 0xE162: cuantos quedan de la tanda
	bit 0,a		;ad77   ; Su bit 0 decide hacia donde se curva este
	jr nz,L_AD81		;ad79
	ld de,0ff80h		;ad7b
	ld bc,00400h		;ad7e
L_AD81:
	call 09522h		;ad81
	ld d,b			;ad84
	ld e,c			;ad85
	call 06cbfh		;ad86
	call 09530h		;ad89
	ld de,0fd00h		;ad8c   ; Tres puntos a la izquierda
	jp 06cc6h		;ad8f
mueve_el_tipo_0A:		; Se va curvando y, al llegar a la columna 0x30, da la vuelta y se vuelve por donde vino
	call 09235h		;ad92   ; Dispara sin apuntar
	call anima_el_tipo_0A		;ad95   ; Seis dibujos, uno cada cuatro cuadros
	call 0953ch		;ad98   ; La curva: la aceleracion se suma a la velocidad
	call 09564h		;ad9b
	call z,09519h		;ad9e
	ld a,(ix+006h)		;ada1   ; Pasada la columna 0x30...
	cp 030h		;ada4
	call c,09580h		;ada6   ; ...se le da la vuelta y se vuelve
	ret			;ada9
anima_el_tipo_0A:		; Seis dibujos en ida y vuelta, uno cada cuatro cuadros
	ld bc,00306h		;adaa
	ld hl,0adb3h		;adad
	jp 095d1h		;adb0

; ----------------------------------------------------------------------
; DATOS tabla_ADB3: Seis bytes que lee 0xADAD: otra ida y vuelta (0xBC, 0xC0,
;   0xC4, 0xC8, 0xC4, 0xC0).
;   0xadb3..0xadb9  (6 bytes)
DATA_tabla_ADB3:
	defb 0bch,0c0h,0c4h,0c8h,0c4h,0c0h	; adb3

; ======================================================================
; CODIGO 0xadb9..0xadd9  (32 bytes)
; ======================================================================


remata_el_tipo_0B:		; Las velocidades salen de una tabla indexada por 0xE15A, y en la segunda vuelta van mas rapidas
	ld a,(0e06ah)		;adb9   ; 0xE06A: de la segunda vuelta en adelante, otra tabla
	or a			;adbc
	ld bc,0fe00h		;adbd   ; Dos puntos a la izquierda...
	ld hl,0add7h		;adc0
	jr z,L_ADCB		;adc3
	ld bc,0fd00h		;adc5   ; ...o tres en la segunda vuelta
	ld hl,0adddh		;adc8
L_ADCB:
	ld a,(0e15ah)		;adcb   ; 0xE15A dice cual de las parejas le toca
	call 047aeh		;adce
	call 06cbfh		;add1
	ld d,b			;add4
	ld e,c			;add5
	jp 06cc6h		;add6

; ----------------------------------------------------------------------
; DATOS tabla_ADD7 (tramo): Seis bytes que lee 0xADC0.
;   0xadd9..0xaddd  (4 bytes)  de 0xadd7..0xaddd (6 bytes)
DATA_tabla_ADD7_ADD9:
	defb 000h,0ffh,000h,000h	; add9

; ----------------------------------------------------------------------
; DATOS tabla_ADDD: Ocho bytes que lee 0xADC8.
;   0xaddd..0xade5  (8 bytes)
DATA_tabla_ADDD:
	defb 000h,001h	; addd
	defb 080h,0feh	; addf
	defb 000h,000h	; ade1
	defb 080h,001h	; ade3

; ======================================================================
; CODIGO 0xade5..0xae03  (30 bytes)
; ======================================================================


mueve_el_tipo_0B:		; Cuatro dibujos, y de la tercera vuelta en adelante dispara cada 0x20 cuadros
	ld bc,00304h		;ade5   ; Cuatro dibujos, uno cada cuatro cuadros
	ld hl,0ae03h		;ade8
	call 095d1h		;adeb
	ld a,(0e06ah)		;adee   ; 0xE06A: hasta la tercera vuelta no dispara
	cp 002h		;adf1
	ret c			;adf3
	ld a,(0e003h)		;adf4   ; Uno de cada 0x20 cuadros
	and 01fh		;adf7
	ret nz			;adf9
	ld a,(0e008h)		;adfa   ; El bit 4 de 0xE008
	and 010h		;adfd
	ret z			;adff
	jp 09239h		;ae00

; ----------------------------------------------------------------------
; DATOS tabla_AE03: Cuatro bytes (0xDC, 0xE0, 0xE4, 0xE8) que lee 0xADE8.
;   0xae03..0xae07  (4 bytes)
DATA_tabla_AE03:
	defb 0dch,0e0h,0e4h,0e8h	; ae03

; ======================================================================
; CODIGO 0xae07..0xae29  (34 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL BICHO QUE HACE EL OCHO
; El tipo 0x0C no persigue a nadie: lleva un recorrido escrito, nueve
; pasos que se van despachando por el byte 1. Cada paso espera a que la
; columna llegue a un numero -0x41, 9, 0x40, 0xAE, 0xE8, 0xB1- y entonces
; cambia de rumbo. El bit 7 del byte 1 no cuenta para el despacho: es un
; espejo, y hace que los que entran por la mitad de abajo describan el
; mismo recorrido del reves.
; ----------------------------------------------------------------------
remata_el_tipo_0C:		; Entrando por la mitad de abajo, el bit 7 del byte 1 le da la vuelta al recorrido
	ld a,(ix+004h)		;ae07   ; El bit 7 de la fila: por que mitad entra
	or a			;ae0a
	jp p,L_AE12		;ae0b
	ld (ix+001h),080h		;ae0e   ; El bit 7 del byte 1: el recorrido, en espejo
L_AE12:
	call 09510h		;ae12
	ld de,0fe00h		;ae15   ; Dos puntos a la izquierda
	jp 06cc6h		;ae18
mueve_el_tipo_0C:		; Nueve pasos de recorrido, despachados por el byte 1 sin su bit 7
	call anima_el_tipo_0C		;ae1b   ; Seis dibujos, uno cada ocho cuadros
	call 09235h		;ae1e   ; Dispara sin apuntar
	ld a,(ix+001h)		;ae21
	and 07fh		;ae24   ; El byte 1 sin su bit 7: el paso
	call 04067h		;ae26

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_AE26: Nueve palabras pegadas detras del `call
;   0x4067` de 0xAE26.
;   0xae29..0xae3b  (18 bytes)
DATA_tabla_del_despachador_AE26:
	defw 0ae3bh,0ae59h	; ae29  -> paso_0_del_ocho paso_1_del_ocho
	defw 0ae6ch,0ae79h	; ae2d  -> paso_2_del_ocho paso_3_del_ocho
	defw 0ae88h,0aea0h	; ae31  -> paso_4_del_ocho paso_5_del_ocho
	defw 0aeb3h,0aec0h	; ae35  -> paso_6_del_ocho paso_7_del_ocho
	defw 0aecfh	; ae39  -> paso_8_del_ocho

; ======================================================================
; CODIGO 0xae3b..0xaed9  (158 bytes)
; ======================================================================


paso_0_del_ocho:		; En la columna 0x41 empieza a subir -o a bajar, si va en espejo- sin dejar de ir a la izquierda
	ld a,(ix+006h)		;ae3b   ; Hasta la columna 0x41, de frente
	cp 041h		;ae3e
	ret nc			;ae40
	inc (ix+001h)		;ae41
	ld de,00200h		;ae44
	bit 7,(ix+001h)		;ae47   ; El espejo: hacia abajo o hacia arriba
	jr z,L_AE50		;ae4b
	ld de,0fe00h		;ae4d
L_AE50:
	call 06cbfh		;ae50
	ld de,0fe00h		;ae53
	jp 06cc6h		;ae56
paso_1_del_ocho:		; En la columna 9 se para en horizontal y aguanta 0x11 cuadros
	ld a,(ix+006h)		;ae59
	cp 009h		;ae5c   ; Hasta la columna 9
	ret nc			;ae5e
	inc (ix+001h)		;ae5f
	ld (ix+002h),011h		;ae62   ; 0x11 cuadros
	ld de,00000h		;ae66
	jp 06cc6h		;ae69
paso_2_del_ocho:		; Agotados los cuadros, dos puntos a la derecha
	dec (ix+002h)		;ae6c
	ret nz			;ae6f
	inc (ix+001h)		;ae70
	ld de,00200h		;ae73
	jp 06cc6h		;ae76
paso_3_del_ocho:		; Pasada la columna 0x40, deja de subir y baja
	ld a,(ix+006h)		;ae79   ; Hasta la columna 0x40, como iba
	cp 040h		;ae7c
	ret c			;ae7e
	inc (ix+001h)		;ae7f
	ld de,00000h		;ae82   ; Y ahi deja de subir y bajar
	jp 06cbfh		;ae85
paso_4_del_ocho:		; En la columna 0xAE se curva al otro lado
	ld a,(ix+006h)		;ae88   ; Hasta la columna 0xAE, como iba
	cp 0aeh		;ae8b
	ret c			;ae8d
	inc (ix+001h)		;ae8e
	ld de,0fe00h		;ae91   ; Y ahi se curva al otro lado
	bit 7,(ix+001h)		;ae94
	jr z,L_AE9D		;ae98
	ld de,00200h		;ae9a
L_AE9D:
	jp 06cbfh		;ae9d
paso_5_del_ocho:		; En la columna 0xE8 se para y aguanta 0x0F cuadros
	ld a,(ix+006h)		;aea0
	cp 0e8h		;aea3
	ret c			;aea5
	inc (ix+001h)		;aea6
	ld (ix+002h),00fh		;aea9   ; 0x0F cuadros
	ld de,00000h		;aead
	jp 06cc6h		;aeb0
paso_6_del_ocho:		; Y entonces dos puntos a la izquierda otra vez
	dec (ix+002h)		;aeb3
	ret nz			;aeb6
	inc (ix+001h)		;aeb7
	ld de,0fe00h		;aeba
	jp 06cc6h		;aebd
paso_7_del_ocho:		; Pasada la columna 0xB1, deja de subir y bajar
	ld a,(ix+006h)		;aec0   ; Hasta la columna 0xB1, como iba
	cp 0b1h		;aec3
	ret nc			;aec5
	inc (ix+001h)		;aec6
	ld de,00000h		;aec9   ; Y ahi deja de subir y bajar
	jp 06cbfh		;aecc
paso_8_del_ocho:		; El ultimo paso no hace nada: el bicho sigue como iba
	ret			;aecf
anima_el_tipo_0C:		; Seis dibujos, uno cada ocho cuadros
	ld bc,00706h		;aed0
	ld hl,0aed9h		;aed3
	jp 095d1h		;aed6

; ----------------------------------------------------------------------
; DATOS tabla_AED9: Seis bytes que lee 0xAED3.
;   0xaed9..0xaedf  (6 bytes)
DATA_tabla_AED9:
	defb 029h,02ah,02bh,02ch,02bh,02ah	; aed9

; ======================================================================
; CODIGO 0xaedf..0xaf3f  (96 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LA FASE 7 VA POR GUION, Y CADA APARICION CABE EN UNA PALABRA
; Las demas fases sueltan bichos por rachas; la septima los tiene
; ESCRITOS uno a uno en la lista de 0xAF3F, cuarenta y tres apariciones en
; ochenta y seis bytes. Cada una es una sola palabra bien apretada: el byte
; bajo y el bit 0 del alto son la distancia -nueve bits- a la que sale, los
; bits 1 y 2 del alto son la variante, y los cinco de arriba, la fila. La
; lista se recorre con un cursor en 0xE968 y acaba en 0xFFFF.
; ----------------------------------------------------------------------
adelanta_el_guion:		; Se salta de golpe todas las apariciones que ya quedan por detras de la distancia recorrida
	ld a,(0e061h)		;aedf   ; Solo la fase 7 lleva guion
	cp 007h		;aee2
	ret nz			;aee4
	call saca_esta_aparicion		;aee5
	jp z,adelanta_el_guion		;aee8   ; Mientras vayan cayendo, se siguen sacando
	ret c			;aeeb   ; Pasada la distancia de la que toca, se para
	ld hl,0e968h		;aeec
	inc (hl)			;aeef   ; Y las que quedan detras, se saltan
	jp adelanta_el_guion		;aef0
mira_el_guion:		; Cada paso con columna nueva saca todas las apariciones que caigan en esta distancia
	ld a,(0e061h)		;aef3   ; Solo la fase 7
	cp 007h		;aef6
	ret nz			;aef8
	ld a,(0e100h)		;aef9   ; Y solo en los pasos con columna nueva
	and a			;aefc
	ret z			;aefd
	ld a,0f8h		;aefe   ; 0xEC04 a 0xF8: todas entran por la derecha
	ld (0ec04h),a		;af00
saca_las_que_toquen:		; Una detras de otra mientras coincidan
	call saca_esta_aparicion		;af03
	jp z,saca_las_que_toquen		;af06
	ret			;af09
saca_esta_aparicion:		; Si la distancia de la lista es la de ahora, adelanta el cursor y suelta el bicho
	call esta_es_la_distancia		;af0a   ; Sin coincidir, no hay nada que hacer
	ret nz			;af0d
	ld hl,0e968h		;af0e
	inc (hl)			;af11   ; Una aparicion menos en la lista
	ld a,c			;af12   ; Los cinco bits de arriba: la fila
	and 0f8h		;af13
	ld e,a			;af15
	ld a,(0ec04h)		;af16   ; Con la columna por debajo de 0x80 no se saca nada
	cp 080h		;af19
	jr nc,saca_el_tipo_0D		;af1b
	xor a			;af1d
	ret			;af1e
saca_el_tipo_0D:		; La columna, la fila y la variante ya desempaquetadas
	ld d,a			;af1f
	ld a,c			;af20   ; Los bits 1 y 2: la variante
	rra			;af21
	and 003h		;af22
	ld c,a			;af24
	ld a,00dh		;af25   ; El tipo 0x0D
	call 06a72h		;af27
	xor a			;af2a
	ret			;af2b
esta_es_la_distancia:		; Desempaqueta la palabra del guion y compara sus nueve bits de distancia con la recorrida
	ld hl,0af3fh		;af2c   ; La palabra que toca de la lista
	ld a,(0e968h)		;af2f
	call 047aeh		;af32
	ld c,d			;af35   ; El byte alto se guarda entero...
	ld a,d			;af36
	and 001h		;af37   ; ...y de el solo el bit 0 es distancia
	ld d,a			;af39
	ld hl,(0e063h)		;af3a   ; DCOMPR contra la distancia recorrida
	rst 20h			;af3d
	ret			;af3e

; ----------------------------------------------------------------------
; DATOS tabla_AF3F: Ochenta y seis bytes que lee 0xAF2C, en parejas.
;   0xaf3f..0xaf95  (86 bytes)
DATA_tabla_AF3F:
	defb 094h,028h	; af3f
	defb 0ach,068h	; af41
	defb 0b3h,018h	; af43
	defb 0b5h,028h	; af45
	defb 0b7h,018h	; af47
	defb 0b9h,03ah	; af49
	defb 0c1h,018h	; af4b
	defb 0c8h,032h	; af4d
	defb 0c9h,070h	; af4f
	defb 0cdh,038h	; af51
	defb 0cdh,072h	; af53
	defb 0d5h,03ah	; af55
	defb 0d6h,050h	; af57
	defb 0d6h,064h	; af59
	defb 0d8h,050h	; af5b
	defb 0d8h,060h	; af5d
	defb 0dbh,068h	; af5f
	defb 0ddh,038h	; af61
	defb 0e9h,01ah	; af63
	defb 0eah,030h	; af65
	defb 0eah,040h	; af67
	defb 0ech,030h	; af69
	defb 0ech,040h	; af6b
	defb 0eeh,062h	; af6d
	defb 0f1h,038h	; af6f
	defb 0f3h,068h	; af71
	defb 001h,009h	; af73
	defb 006h,055h	; af75
	defb 006h,061h	; af77
	defb 008h,051h	; af79
	defb 008h,063h	; af7b
	defb 009h,019h	; af7d
	defb 013h,069h	; af7f
	defb 015h,079h	; af81
	defb 025h,019h	; af83
	defb 026h,033h	; af85
	defb 026h,041h	; af87
	defb 028h,031h	; af89
	defb 028h,041h	; af8b
	defb 029h,07bh	; af8d
	defb 03dh,039h	; af8f
	defb 05ch,089h	; af91
	defb 0ffh,0ffh	; af93

; ======================================================================
; CODIGO 0xaf95..0xb000  (107 bytes)
; ======================================================================


remata_el_tipo_0D:		; Byte 20 a uno, diez cuadros en el byte 2, el 28 a 0xFF y quieto
	xor a			;af95
	ld (ix+01dh),a		;af96
	inc a			;af99
	ld (ix+014h),a		;af9a
	ld (ix+002h),00ah		;af9d   ; Diez cuadros
	ld (ix+01ch),0ffh		;afa1
	jp 09510h		;afa5
el_tipo_0D_se_va:		; Paso 2, dibujo 0xDC en color 0x0D y un punto a la izquierda
	ld (ix+001h),002h		;afa8   ; El paso 2: ya se esta yendo
	ld (ix+00ch),0dch		;afac   ; El dibujo 0xDC en color 0x0D
	ld (ix+00dh),00dh		;afb0
	call 09510h		;afb4
	ld de,0ff00h		;afb7   ; Un punto a la izquierda
	jp 06cc6h		;afba
mueve_el_tipo_0D:		; Se queda en el sitio disparando cada diez cuadros hasta que se le acaban los 0xFF de vida, y entonces se va
	ld a,(ix+001h)		;afbd   ; Del paso 2 en adelante ya se esta yendo
	cp 002h		;afc0
	ret nc			;afc2
	dec (ix+01ch)		;afc3   ; El byte 28: 0xFF cuadros de vida
	jr z,el_tipo_0D_se_va		;afc6
	call anima_el_tipo_0D		;afc8   ; El dibujo, que cambia a destiempo
	ld a,(ix+001h)		;afcb   ; El byte 1: quieto o disparando
	dec a			;afce
	jr z,el_tipo_0D_descansa		;afcf
	dec (ix+002h)		;afd1   ; Diez cuadros por paso
	ret nz			;afd4
	inc (ix+001h)		;afd5
	ld (ix+002h),00ah		;afd8
	call velocidad_por_la_dificultad		;afdc   ; La velocidad del disparo, por la dificultad
	jp 06c61h		;afdf
el_tipo_0D_descansa:		; Otros diez cuadros quieto y a volver a disparar
	dec (ix+002h)		;afe2
	ret nz			;afe5
	dec (ix+001h)		;afe6
	ld (ix+002h),00ah		;afe9
	jp 09510h		;afed
velocidad_por_la_dificultad:		; De la cuesta de 0xB000: 0x1A y dos mas por cada escalon de dificultad
	ld a,(0e111h)		;aff0   ; 0xE111, la dificultad, indexa la cuesta de 0xB000
	ld hl,0b000h		;aff3
	add a,l			;aff6
	ld l,a			;aff7
	jr nc,L_AFFB		;aff8
	inc h			;affa
L_AFFB:
	ld a,(hl)			;affb
	ld (0e110h),a		;affc   ; 0xE110: la velocidad de los disparos
	ret			;afff

; ----------------------------------------------------------------------
; DATOS rampa_B000: Dieciseis bytes de dos en dos (0x1A, 0x1C, 0x1E, ...) que
;   lee 0xAFF3.
;   0xb000..0xb010  (16 bytes)
DATA_rampa_B000:
	defb 01ah,01ch,01eh,020h,022h,024h,026h,028h,02ah,02ch,02eh,030h,032h,034h,036h,038h	; b000  ... "$&(*,.02468

; ======================================================================
; CODIGO 0xb010..0xb03c  (44 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL PARPADEO A DESTIEMPO SALE DEL REGISTRO R
; Los seis dibujos de este bicho no se turnan a paso fijo: cada vez que
; cambia, el bit 0 del registro R decide si el siguiente dura 0x0F cuadros
; o solo 3. Con la misma tabla de seis dibujos, dos bichos que salgan a la
; vez nunca van sincronizados.
; ----------------------------------------------------------------------
anima_el_tipo_0D:		; Cambia de dibujo cada 0x0F o cada 3 cuadros, a suertes con el registro R
	dec (ix+014h)		;b010   ; El byte 20: los cuadros que le quedan a este dibujo
	ret nz			;b013
	ld b,00fh		;b014
	ld a,r		;b016   ; El registro R: 0x0F cuadros o solo 3
	and 001h		;b018
	jr nz,L_B01E		;b01a
	ld b,003h		;b01c
L_B01E:
	ld (ix+014h),b		;b01e
	inc (ix+01dh)		;b021   ; El byte 29: por que dibujo va
	ld a,(ix+01dh)		;b024
	cp 006h		;b027   ; Seis dibujos en redondo
	jr c,L_B02F		;b029
	xor a			;b02b
	ld (ix+01dh),a		;b02c
L_B02F:
	ld hl,0b03ch		;b02f
	add a,l			;b032
	ld l,a			;b033
	jr nc,L_B037		;b034
	inc h			;b036
L_B037:
	ld a,(hl)			;b037
	ld (ix+00ch),a		;b038
	ret			;b03b

; ----------------------------------------------------------------------
; DATOS tabla_B03C: Seis bytes que lee 0xB02F.
;   0xb03c..0xb042  (6 bytes)
DATA_tabla_B03C:
	defb 0e0h,0e4h,0e8h,0ech,0e8h,0e4h	; b03c

; ======================================================================
; CODIGO 0xb042..0xb26a  (552 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL BLANCO QUE CIERRA EL TRAMO
; Cinco fases -la 1, la 2, la 3, la 4 y la 7- llevan escrita una distancia
; a la que aparece un blanco: no es un objeto de los de siempre, sino tres
; bytes sueltos en 0xE1C1..0xE1C3 -tipo, fila y columna- que se corren con
; el scroll. Si la nave le pasa por encima, con margen de 0x10 en las dos
; direcciones, revienta todo lo que hay en pantalla, para el scroll en un
; limite propio de la fase, borra el renglon del guion y suena el 0xCD.
; ----------------------------------------------------------------------
mira_el_blanco_del_tramo:		; Con la pantalla parada cuenta hasta 0x40 y la suelta; y si no, mira si toca sacar el blanco y si la nave lo ha tocado
	ld a,(0e200h)		;b042   ; Sin nave no hay nada que mirar
	dec a			;b045
	ret m			;b046
	ld a,(0e1c0h)		;b047   ; 0xE1C0: la pantalla esta parada
	and a			;b04a
	jr z,L_B05C		;b04b
	ld hl,0e1c5h		;b04d   ; 0xE1C5: los cuadros que faltan
	dec (hl)			;b050
	ret nz			;b051
	ld a,002h		;b052   ; 0xE1C0 a dos y el sonido 0x41
	ld (0e1c0h),a		;b054
	ld a,041h		;b057
	jp 049deh		;b059
L_B05C:
	call saca_el_blanco_si_toca		;b05c
	ld a,(0e1c1h)		;b05f   ; 0xE1C1: solo si el blanco esta puesto
	and a			;b062
	ret z			;b063
	call mira_si_la_nave_lo_toca		;b064
	jp corre_el_blanco		;b067
saca_el_blanco_si_toca:		; Cada fase tiene su distancia y su fila; las que no estan en la lista no llevan blanco
	ld a,(0e100h)		;b06a   ; Solo en los pasos con columna nueva
	and a			;b06d
	ret z			;b06e
	ld a,(0e061h)		;b06f   ; La fase y la distancia recorrida
	ld hl,(0e063h)		;b072
	dec a			;b075
	jr z,blanco_de_la_fase_1		;b076
	dec a			;b078
	jr z,blanco_de_la_fase_2		;b079
	dec a			;b07b
	jr z,blanco_de_la_fase_3		;b07c
	dec a			;b07e
	jr z,blanco_de_la_fase_4		;b07f
	cp 003h		;b081   ; Y la septima, con cuatro restas ya hechas
	jr z,blanco_de_la_fase_7		;b083
	ret			;b085
blanco_de_la_fase_1:		; A la distancia 0xFC, por la fila 0x88
	ld de,000fch		;b086   ; A la distancia 0xFC...
	rst 20h			;b089
	ret nz			;b08a
	ld e,088h		;b08b   ; ...por la fila 0x88
	ld c,002h		;b08d
	jr L_B0C1		;b08f
blanco_de_la_fase_2:		; A la 0x190, por la misma fila 0x88
	ld de,00190h		;b091
	rst 20h			;b094
	ret nz			;b095
	ld e,088h		;b096
	jr pon_el_blanco		;b098
blanco_de_la_fase_3:		; A la 0x12A, por la fila 0x30
	ld de,0012ah		;b09a
	rst 20h			;b09d
	ret nz			;b09e
	ld e,030h		;b09f
	jr pon_el_blanco		;b0a1
blanco_de_la_fase_4:		; Dos distancias, la 0xC0 y la 0x104, las dos por la fila 0x10
	ld de,000c0h		;b0a3   ; A la distancia 0xC0, por la fila 0x10...
	rst 20h			;b0a6
	ld e,010h		;b0a7
	ld c,003h		;b0a9
	jr z,L_B0C1		;b0ab
	ld de,00104h		;b0ad   ; ...y otra vez a la 0x104
	rst 20h			;b0b0
	ret nz			;b0b1
	ld e,010h		;b0b2
	ld c,004h		;b0b4
	jr L_B0C1		;b0b6
blanco_de_la_fase_7:		; A la 0x177, por la fila 0x38
	ld de,00177h		;b0b8
	rst 20h			;b0bb
	ret nz			;b0bc
	ld e,038h		;b0bd
pon_el_blanco:		; Tipo, fila y columna en 0xE1C1, 0xE1C2 y 0xE1C3
	ld c,001h		;b0bf
L_B0C1:
	ld hl,0e1c1h		;b0c1
	ld (hl),c			;b0c4
	inc l			;b0c5
	ld (hl),e			;b0c6
	inc l			;b0c7
	ld (hl),0f0h		;b0c8   ; Siempre entra por la columna 0xF0
	ret			;b0ca
corre_el_blanco:		; Ocho puntos a la izquierda por cada columna nueva; al salirse, se quita
	ld a,(0e100h)		;b0cb
	and a			;b0ce
	ret z			;b0cf
	ld hl,0e1c3h		;b0d0
	ld a,(hl)			;b0d3
	sub 008h		;b0d4   ; Ocho puntos a la izquierda
	ld (hl),a			;b0d6
	ret nc			;b0d7
	dec l			;b0d8
	dec l			;b0d9
	ld (hl),000h		;b0da   ; Fuera de pantalla, el blanco se quita
	ret			;b0dc
mira_si_la_nave_lo_toca:		; Con la nave a menos de 0x10 en fila y en columna, se acaba el tramo
	ld hl,0e1c2h		;b0dd
	ld a,(0e204h)		;b0e0   ; La fila de la nave contra la del blanco
	sub (hl)			;b0e3
	add a,008h		;b0e4
	cp 010h		;b0e6   ; Margen de 0x10
	ret nc			;b0e8
	inc l			;b0e9
	ld a,(0e206h)		;b0ea   ; Y lo mismo con la columna
	sub (hl)			;b0ed
	cp 010h		;b0ee
	ret nc			;b0f0
	ld a,(0e061h)		;b0f1   ; Las fases 2, 3 y 6 tienen su limite propio
	sub 002h		;b0f4
	jr z,limite_de_la_fase_2		;b0f6
	dec a			;b0f8
	jr z,limite_de_la_fase_3		;b0f9
	cp 004h		;b0fb
	jr z,limite_de_la_fase_6		;b0fd
	ld hl,0e06ch		;b0ff   ; Y en las demas se lleva la cuenta en 0xE06C
	ld a,(0e1c1h)		;b102
	cp (hl)			;b105   ; Si es del mismo tipo que el ultimo, no cuenta
	ret z			;b106
	ld (hl),a			;b107
	xor a			;b108
	ld (0e1c1h),a		;b109
	inc hl			;b10c
	inc (hl)			;b10d   ; Una vez mas, y a la tercera distinta...
	ld a,(hl)			;b10e
	cp 003h		;b10f
	ret nz			;b111
	ld (hl),000h		;b112
	ld hl,001c0h		;b114   ; ...el limite es el 0x1C0
	jr cierra_el_tramo		;b117
limite_de_la_fase_6:		; El scroll se topa en 0x1A0
	ld hl,001a0h		;b119
	jr cierra_el_tramo		;b11c
limite_de_la_fase_2:		; En 0x1CF
	ld hl,001cfh		;b11e
	jr cierra_el_tramo		;b121
limite_de_la_fase_3:		; En 0x19F
	ld hl,0019fh		;b123
cierra_el_tramo:		; Para el scroll en su limite, borra el renglon del guion, revienta todo y suena el 0xCD
	ld (0e105h),hl		;b126   ; 0xE105: hasta donde llega el scroll
	ld a,040h		;b129   ; 0x40 cuadros parada
	ld (0e1c5h),a		;b12b
	ld a,001h		;b12e   ; 0xE1C0 a uno: la pantalla se para
	ld (0e1c0h),a		;b130
	ld hl,00000h		;b133   ; El renglon del guion, a cero
	ld (0e127h),hl		;b136
	xor a			;b139
	ld (0e1c1h),a		;b13a
	call 07596h		;b13d   ; Y todo lo que hay en pantalla, reventado
	ld a,0cdh		;b140   ; El sonido 0xCD
	jp 049deh		;b142
corre_los_cuatro_de_e880:		; Las cuatro fichas de ocho bytes de 0xE880, una por una
	ld ix,0e880h		;b145
	ld b,004h		;b149   ; Cuatro fichas
L_B14B:
	push bc			;b14b
	ld a,(ix+000h)		;b14c
	and a			;b14f
	call nz,paso_de_uno_de_e880		;b150
	pop bc			;b153
	ld de,00008h		;b154   ; Ocho bytes por ficha
	add ix,de		;b157
	djnz L_B14B		;b159
	ret			;b15b
paso_de_uno_de_e880:		; Se corre con el scroll y, al salirse, se apaga; si no, le toca su paso
	ld a,(0e100h)		;b15c   ; Solo en los pasos con columna nueva
	and a			;b15f
	jr z,L_B171		;b160
	ld a,(ix+003h)		;b162
	sub 008h		;b165   ; Ocho puntos a la izquierda
	ld (ix+003h),a		;b167
	jr nc,L_B171		;b16a
	ld (ix+000h),000h		;b16c   ; Fuera de pantalla, la ficha se apaga
	ret			;b170
L_B171:
	ld a,(ix+001h)		;b171   ; El byte 1: por que paso va
	dec a			;b174
	jr z,paso_1_de_e880		;b175
	dec a			;b177
	jr z,paso_2_de_e880		;b178
	dec a			;b17a
	jr z,paso_3_de_e880		;b17b
	dec (ix+004h)		;b17d   ; El byte 4: los cuadros que faltan
	ret nz			;b180
	bit 0,(ix+000h)		;b181   ; El bit 0 del tipo: unos se corren y otros no
	jr z,L_B18F		;b185
	ld a,(ix+002h)		;b187
	sub 008h		;b18a
	ld (ix+002h),a		;b18c
L_B18F:
	ld (ix+004h),005h		;b18f   ; Cinco cuadros hasta el siguiente
	inc (ix+005h)		;b193   ; El byte 5: tres pasos y cambia
	ld a,(ix+005h)		;b196
	cp 003h		;b199
	ret c			;b19b
	inc (ix+001h)		;b19c
	ret			;b19f
paso_1_de_e880:		; Cada cinco cuadros da un paso de ocho puntos, arriba o abajo segun el bit 0 del tipo, y al agotar el byte 7 se para 0x18 cuadros
	dec (ix+004h)		;b1a0   ; El byte 4: los cuadros hasta el paso siguiente
	ret nz			;b1a3
	ld (ix+004h),005h		;b1a4   ; Cinco cuadros por paso
	dec (ix+007h)		;b1a8   ; El byte 7: los pasos que le quedan
	jr nz,un_paso_de_ocho		;b1ab
	inc (ix+001h)		;b1ad
	ld (ix+004h),018h		;b1b0   ; 0x18 cuadros parado, y el byte 5 a 0x30
	ld (ix+005h),030h		;b1b4
	ret			;b1b8
un_paso_de_ocho:		; El bit 0 del tipo dice si sube o si baja
	bit 0,(ix+000h)		;b1b9   ; El bit 0 del tipo
	jr z,L_B1C8		;b1bd
	ld a,(ix+002h)		;b1bf   ; Ocho puntos hacia arriba...
	sub 008h		;b1c2
	ld (ix+002h),a		;b1c4
	ret			;b1c7
L_B1C8:
	ld a,(ix+002h)		;b1c8   ; ...u ocho hacia abajo
	add a,008h		;b1cb
	ld (ix+002h),a		;b1cd
	ret			;b1d0
paso_2_de_e880:		; El byte 6 a cero y 0x20 cuadros de espera
	ld (ix+006h),000h		;b1d1   ; El byte 6 a cero: la torreta se mete
	dec (ix+004h)		;b1d5   ; 0x20 cuadros dentro
	ret nz			;b1d8
	inc (ix+001h)		;b1d9
	ld (ix+004h),020h		;b1dc
	ret			;b1e0
paso_3_de_e880:		; El byte 6 a uno, y al agotarse la espera suelta el abanico y vuelve al paso 2
	ld (ix+006h),001h		;b1e1   ; El byte 6 a uno: la torreta asoma
	dec (ix+004h)		;b1e5
	ret nz			;b1e8
	call suelta_el_abanico		;b1e9   ; Y suelta el abanico
	dec (ix+001h)		;b1ec
	ld a,(0e111h)		;b1ef   ; La dificultad partida por dos, restada de 0x18: lo que tarda en volver a disparar
	sra a		;b1f2
	ld c,a			;b1f4
	ld a,018h		;b1f5
	sub c			;b1f7
	ld (ix+004h),a		;b1f8
	ret			;b1fb

; ----------------------------------------------------------------------
; EL ABANICO DE TRES DISPAROS
; Este bicho no dispara uno: dispara tres, abiertos en abanico alrededor
; de la nave. Se mide el angulo hasta ella -0xEC18-, se queda con su
; nibble alto, que son dieciseis direcciones en redondo, y se sueltan tres
; disparos con ese numero, con el de al lado y con el de antes. Las dos
; velocidades de cada direccion estan hechas de antemano en la tabla de
; 0xB26A: cuatro bytes por direccion, dos palabras.
; ----------------------------------------------------------------------
suelta_el_abanico:		; Mide el angulo hasta la nave y suelta tres disparos: el de ese angulo, el de al lado y el de antes
	ld a,(ix+002h)		;b1fc   ; Su fila y su columna, mas 0x10: del centro del bicho
	add a,010h		;b1ff
	ld e,a			;b201
	ld a,(ix+003h)		;b202
	add a,010h		;b205
	ld d,a			;b207
	call 066d5h		;b208   ; De ahi sale el angulo hasta la nave, en 0xEC18
	ld c,000h		;b20b   ; El de en medio...
	call mete_un_disparo		;b20d
	ld c,001h		;b210   ; ...el de al lado...
	call mete_un_disparo		;b212
	ld c,0ffh		;b215   ; ...y el de antes
mete_un_disparo:		; Busca ranura libre en las diez de 0xE500 y la rellena con la posicion y con la velocidad que le toca a esa direccion
	ld a,(0ec18h)		;b217   ; El nibble alto del angulo: dieciseis direcciones
	rra			;b21a
	rra			;b21b
	rra			;b21c
	rra			;b21d
	add a,c			;b21e   ; Mas el desvio del abanico
	and 00fh		;b21f
	ld (0ec00h),a		;b221
	ld hl,0e500h		;b224   ; Las diez ranuras de 0xE500, de 0x20 en 0x20
	ld de,00020h		;b227
	ld b,00ah		;b22a
	xor a			;b22c
L_B22D:
	cp (hl)			;b22d   ; La primera con el primer byte a cero
	jr z,L_B234		;b22e
	add hl,de			;b230
	djnz L_B22D		;b231
	ret			;b233
L_B234:
	ld (hl),001h		;b234   ; Ocupada
	inc l			;b236
	inc l			;b237
	inc l			;b238
	inc l			;b239
	ld a,(ix+002h)		;b23a   ; La fila del bicho mas 0x10
	add a,010h		;b23d
	ld (hl),a			;b23f
	inc l			;b240
	inc l			;b241
	ld a,(ix+003h)		;b242   ; Y su columna
	add a,010h		;b245
	ld (hl),a			;b247
	ld de,0b26ah		;b248   ; La tabla de 0xB26A: cuatro bytes por direccion
	ld a,(0ec00h)		;b24b
	add a,a			;b24e
	add a,a			;b24f
	call 04062h		;b250
	inc l			;b253
	ex de,hl			;b254
	ld bc,00004h		;b255
	ldir		;b258   ; Las dos velocidades, de un tiron
	ex de,hl			;b25a
	ld (hl),000h		;b25b
	inc l			;b25d
	ld (hl),088h		;b25e   ; El dibujo 0x88 en color 9
	inc l			;b260
	ld (hl),009h		;b261
	ld de,0000eh		;b263
	add hl,de			;b266
	ld (hl),001h		;b267   ; Y el byte 0x12 a uno
	ret			;b269

; ----------------------------------------------------------------------
; DATOS tabla_B26A: Sesenta y cuatro bytes que lee 0xB248 con `ld de,0xB26A`,
;   en palabras.
;   0xb26a..0xb2aa  (64 bytes)
DATA_tabla_B26A:
	defw 00000h,00280h	; b26a
	defw 000f5h,0024fh	; b26e
	defw 001c5h,001c5h	; b272
	defw 0024fh,000f5h	; b276
	defw 00280h,00000h	; b27a
	defw 0024fh,0ff0bh	; b27e
	defw 001c5h,0fe3bh	; b282
	defw 000f5h,0fdb1h	; b286
	defw 00000h,0fd80h	; b28a
	defw 0ff0bh,0fdb1h	; b28e
	defw 0fe3bh,0fe3bh	; b292
	defw 0fdb1h,0ff0bh	; b296
	defw 0fd80h,00000h	; b29a
	defw 0fdb1h,000f5h	; b29e
	defw 0fe3bh,001c5h	; b2a2
	defw 0ff0bh,0024fh	; b2a6

; ======================================================================
; CODIGO 0xb2aa..0xb368  (190 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LA FASE 5 TIENE SU PROPIO MOTOR DE FONDO
; Las otras once fases mueven los objetos de fondo con el motor de
; p01:0x6008; la quinta no: p00:0x5FE4 la desvia aqui. Son las mismas ocho
; fichas de ocho bytes de 0xE700, pero con dos reglas propias: los tipos
; del 1 al 4 sueltan objetos del tipo 0x1C cuando la nave les entra en
; rango, y los del 5 al 8 montan las torretas deslizantes de 0xE880.
; ----------------------------------------------------------------------
corre_el_fondo_de_la_fase_5:		; Las ocho fichas de ocho bytes de 0xE700, una por una
	ld ix,0e700h		;b2aa
	ld b,008h		;b2ae   ; Ocho fichas
L_B2B0:
	push bc			;b2b0
	call paso_del_fondo_de_la_fase_5		;b2b1
	pop bc			;b2b4
	ld de,00008h		;b2b5   ; Ocho bytes por ficha
	add ix,de		;b2b8
	djnz L_B2B0		;b2ba
	ret			;b2bc
paso_del_fondo_de_la_fase_5:		; Le da su paso y luego lo corre con el scroll
	ld a,(ix+000h)		;b2bd   ; La ficha vacia no se toca
	and a			;b2c0
	ret z			;b2c1
	call reparte_por_el_tipo_del_fondo		;b2c2
	ld a,(0e100h)		;b2c5   ; Solo en los pasos con columna nueva
	and a			;b2c8
	ret z			;b2c9
	ld a,(ix+003h)		;b2ca   ; Ocho puntos a la izquierda
	sub 008h		;b2cd
	jr nc,L_B2D6		;b2cf
	ld (ix+000h),000h		;b2d1   ; Fuera de pantalla, la ficha se apaga
	ret			;b2d5
L_B2D6:
	ld (ix+003h),a		;b2d6
	ret			;b2d9
reparte_por_el_tipo_del_fondo:		; Del 1 al 4 sueltan bichos; del 5 al 8 montan torretas
	ld a,(ix+000h)		;b2da
	cp 005h		;b2dd   ; Del tipo 5 en adelante, por otro lado
	jp nc,monta_una_torreta		;b2df
	ld a,(ix+001h)		;b2e2   ; El byte 1: por que paso va
	dec a			;b2e5
	jr z,espera_a_la_nave		;b2e6
	dec a			;b2e8
	jr z,suelta_mientras_este_en_rango		;b2e9
	dec (ix+004h)		;b2eb   ; El byte 4: los cuadros que faltan
	ret nz			;b2ee
	ld (ix+004h),008h		;b2ef   ; Ocho cuadros por paso
	inc (ix+006h)		;b2f3
	inc (ix+007h)		;b2f6   ; El byte 7: cuatro pasos y al siguiente
	ld a,(ix+007h)		;b2f9
	cp 004h		;b2fc
	ret c			;b2fe
pasa_de_paso_el_fondo:		; Un paso mas
	inc (ix+001h)		;b2ff
	ret			;b302
espera_a_la_nave:		; En cuanto la nave entra en rango, un paso mas y a soltar
	call la_nave_esta_en_rango		;b303
	ret c			;b306
	inc (ix+006h)		;b307
	ld (ix+004h),008h		;b30a
	jr pasa_de_paso_el_fondo		;b30e
suelta_mientras_este_en_rango:		; Cada ocho cuadros suelta un tipo 0x1C, y en cuanto la nave se sale, se vuelve al paso de antes
	call la_nave_esta_en_rango		;b310
	jr c,la_nave_se_salio		;b313
	dec (ix+004h)		;b315
	ret nz			;b318
	ld (ix+004h),008h		;b319   ; Ocho cuadros entre uno y otro
	push ix		;b31d
	call suelta_un_tipo_1C		;b31f
	pop ix		;b322
	ret			;b324
la_nave_se_salio:		; Se vuelve un paso atras
	dec (ix+006h)		;b325
	dec (ix+001h)		;b328
	ret			;b32b
la_nave_esta_en_rango:		; Compara la columna de la nave con la suya, con un margen distinto segun el tipo
	ld d,(ix+003h)		;b32c   ; Su columna
	ld a,(0e206h)		;b32f   ; 0xE206: la columna de la nave
	ld h,a			;b332
	ld a,(ix+000h)		;b333   ; Los tipos 1 y 3 miden por un lado...
	dec a			;b336
	jr z,L_B346		;b337
	dec a			;b339
	jr z,L_B33F		;b33a
	dec a			;b33c
	jr z,L_B346		;b33d
L_B33F:
	ld a,d			;b33f   ; ...y el 2 por el otro: 0x30 por delante
	add a,030h		;b340
	ret c			;b342
	sub h			;b343
	ccf			;b344
	ret			;b345
L_B346:
	ld a,d			;b346   ; 0x20 por detras
	sub 020h		;b347
	ret c			;b349
	sub h			;b34a
	ret			;b34b
suelta_un_tipo_1C:		; La posicion sale de la suya mas el desvio que le toca a su tipo
	ld a,(ix+000h)		;b34c
	add a,a			;b34f
	ld hl,0b366h		;b350   ; La tabla de 0xB366: dos bytes por tipo
	call 0405dh		;b353
	ld a,(ix+002h)		;b356   ; Su fila mas el desvio...
	add a,(hl)			;b359
	ld e,a			;b35a
	inc hl			;b35b
	ld a,(ix+003h)		;b35c   ; ...y su columna
	add a,(hl)			;b35f
	ld d,a			;b360
	ld c,000h		;b361
	ld a,01ch		;b363   ; El tipo 0x1C
	jp 06a72h		;b365

; ----------------------------------------------------------------------
; DATOS tabla_B366 (tramo): Diez bytes que lee 0xB350 con la base 0xB366.
;   0xb368..0xb370  (8 bytes)  de 0xb366..0xb370 (10 bytes)
DATA_tabla_B366_B368:
	defb 010h,0f0h	; b368
	defb 010h,028h	; b36a
	defb 010h,0f0h	; b36c
	defb 010h,028h	; b36e

; ======================================================================
; CODIGO 0xb370..0xb3c7  (87 bytes)
; ======================================================================


monta_una_torreta:		; Los tipos del 5 al 8 buscan ficha libre en 0xE880 y montan alli una torreta deslizante
	ld a,(ix+000h)		;b370
	cp 009h		;b373   ; Del tipo 9 en adelante, nada
	ret nc			;b375
	ld a,(ix+004h)		;b376   ; El byte 4: los cuadros que faltan
	and a			;b379
	ret z			;b37a
	dec (ix+004h)		;b37b
	ret nz			;b37e
	ld hl,0e880h		;b37f   ; Las cuatro fichas de 0xE880, de ocho en ocho bytes
	ld b,004h		;b382
	ld de,00008h		;b384
	xor a			;b387
L_B388:
	cp (hl)			;b388   ; La primera con el primer byte a cero
	jr z,L_B392		;b389
	add hl,de			;b38b
	djnz L_B388		;b38c
	inc (ix+004h)		;b38e   ; Sin ficha libre, se vuelve a intentar al cuadro siguiente
	ret			;b391
L_B392:
	bit 0,(ix+000h)		;b392   ; El bit 0 del tipo: la torreta sube o baja
	ld a,001h		;b396
	jr nz,L_B39B		;b398
	inc a			;b39a
L_B39B:
	ld (hl),a			;b39b
	inc l			;b39c
	ld (hl),000h		;b39d
	inc l			;b39f
	ld a,(ix+000h)		;b3a0   ; La tabla de 0xB3C7: dos bytes por tipo
	sub 005h		;b3a3
	ld de,0b3c7h		;b3a5
	add a,a			;b3a8
	call 04062h		;b3a9
	ld a,(de)			;b3ac
	inc de			;b3ad
	add a,(ix+002h)		;b3ae   ; Su fila mas el desvio...
	ld (hl),a			;b3b1
	inc l			;b3b2
	ld a,(de)			;b3b3   ; ...y su columna
	add a,(ix+003h)		;b3b4
	ld (hl),a			;b3b7
	inc l			;b3b8
	ld (hl),005h		;b3b9   ; Cinco cuadros para el primer paso
	inc l			;b3bb
	ld (hl),000h		;b3bc
	inc l			;b3be
	ld (hl),000h		;b3bf
	inc l			;b3c1
	ld a,(ix+007h)		;b3c2
	ld (hl),a			;b3c5
	ret			;b3c6

; ----------------------------------------------------------------------
; DATOS tabla_B3C7: Once bytes que lee 0xB3A5 con `ld de,0xB3C7`.
;   0xb3c7..0xb3d2  (11 bytes)
DATA_tabla_B3C7:
	defb 000h,008h,018h,008h,0f8h,000h,008h,000h,0afh,018h,002h	; b3c7  ...........

; ======================================================================
; CODIGO 0xb3d2..0xb537  (357 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EN LA FASE 5 EL FONDO SE PINTA CON CARACTERES, NO CON SPRITES
; Los objetos del fondo de la quinta fase no llevan ficha de sprite: son
; rectangulos de caracteres escritos en el mapa. Por eso hay dos rutinas
; gemelas que se llaman con un cuadro de por medio: primero se borran
; -0xEC00 a cero, que manda a borra_un_rectangulo- y despues, ya movidos,
; se vuelven a pintar -0xEC00 a 0xFF, que manda a copia_un_rectangulo-.
; La torreta ademas se pinta a medias mientras asoma: se le dibujan solo
; tantas filas como lleve fuera.
; ----------------------------------------------------------------------
pinta_el_fondo_de_la_fase_5:		; Las ocho fichas de 0xE700, pintadas como rectangulos de caracteres
	ld a,0ffh		;b3d2   ; 0xEC00 a 0xFF: se pinta
	ld ix,0e700h		;b3d4
	ld b,008h		;b3d8   ; Ocho fichas
	ld (0ec00h),a		;b3da
L_B3DD:
	push bc			;b3dd
	call pinta_una_del_fondo		;b3de
	pop bc			;b3e1
	ld de,00008h		;b3e2   ; Ocho bytes por ficha
	add ix,de		;b3e5
	djnz L_B3DD		;b3e7
	ret			;b3e9
pinta_una_del_fondo:		; Del tipo 1 al 4, un cuadro de cinco por cinco; del 5 en adelante, lo que diga su tabla
	ld a,(ix+000h)		;b3ea   ; La ficha vacia no se pinta
	and a			;b3ed
	ret z			;b3ee
	cp 005h		;b3ef   ; Del tipo 5 en adelante, por otro lado
	jp nc,pinta_una_de_las_grandes		;b3f1
	ld a,(ix+006h)		;b3f4   ; El byte 6 elige el dibujo en la tabla de 0xB537
	ld hl,0b537h		;b3f7
	call 047aeh		;b3fa
cinco_por_cinco:		; Los tipos del 1 al 4 miden cinco casillas por cinco
	ld bc,00505h		;b3fd
pinta_o_borra:		; Con 0xEC00 a cero se borra, y si no se copia
	ld l,(ix+002h)		;b400   ; Su fila y su columna
	ld h,(ix+003h)		;b403
	ld a,(0ec00h)		;b406   ; 0xEC00 dice si toca pintar o borrar
	and a			;b409
	jp z,048f7h		;b40a
	jp 0490ch		;b40d
borra_el_fondo_de_la_fase_5:		; 0xEC00 a cero y a recorrer las mismas ocho fichas
	xor a			;b410
	ld (0ec00h),a		;b411
	jr cinco_por_cinco		;b414
pinta_una_de_las_grandes:		; Los tipos del 5 al 8 traen su medida delante de los caracteres
	ld a,(0ec00h)		;b416   ; Estos no se borran, solo se pintan
	and a			;b419
	ret z			;b41a
	ld a,(ix+000h)		;b41b
	sub 005h		;b41e
	ld hl,0b749h		;b420   ; La tabla de 0xB749: un puntero por tipo
	call 047aeh		;b423
	ex de,hl			;b426
	ld c,(hl)			;b427   ; Los dos primeros bytes son el ancho y el alto
	inc hl			;b428
	ld b,(hl)			;b429
	inc hl			;b42a
	ex de,hl			;b42b
	jr pinta_o_borra		;b42c
borra_las_torretas:		; 0xEC00 a cero
	xor a			;b42e
	jr L_B439		;b42f
pinta_las_torretas:		; Solo en la fase 5, y con 0xEC00 a 0xFF
	ld a,(0e061h)		;b431   ; Solo la fase 5 lleva torretas
	cp 005h		;b434
	ret nz			;b436
	ld a,0ffh		;b437
L_B439:
	ld (0ec00h),a		;b439
	ld ix,0e880h		;b43c
	ld b,004h		;b440   ; Cuatro fichas
L_B442:
	push bc			;b442
	ld a,(ix+000h)		;b443
	and a			;b446
	call nz,pinta_una_torreta		;b447
	pop bc			;b44a
	ld de,00008h		;b44b   ; Ocho bytes por ficha
	add ix,de		;b44e
	djnz L_B442		;b450
	ret			;b452
pinta_una_torreta:		; Ya fuera del todo, cuatro por cuatro; asomando, solo las filas que lleve
	ld a,(ix+001h)		;b453   ; El byte 1: si ya ha acabado de asomar
	and a			;b456
	jr z,la_torreta_asoma		;b457
	ld a,(ix+006h)		;b459   ; El byte 6 elige entre los dos dibujos
	ld de,0b729h		;b45c
	and a			;b45f
	jr z,L_B465		;b460
	ld de,0b739h		;b462
L_B465:
	ld bc,00404h		;b465   ; Cuatro casillas por cuatro
pinta_o_borra_la_torreta:		; Igual que el fondo: 0xEC00 manda
	ld l,(ix+002h)		;b468   ; Su fila y su columna
	ld h,(ix+003h)		;b46b
	ld a,(0ec00h)		;b46e   ; 0xEC00 dice si toca pintar o borrar
	and a			;b471
	jp z,048f7h		;b472
	jp 0490ch		;b475
la_torreta_asoma:		; Se dibuja solo lo que lleva fuera: el byte 5 dice cuantas filas
	ld a,(ix+000h)		;b478
	dec a			;b47b
	jr nz,L_B489		;b47c
	ld de,0b729h		;b47e
	ld b,004h		;b481
	ld c,(ix+005h)		;b483   ; El byte 5: las filas que lleva fuera
	inc c			;b486
	jr pinta_o_borra_la_torreta		;b487
L_B489:
	ld de,0b729h		;b489   ; La tabla de 0xB729, leida por el final
	ld a,(ix+005h)		;b48c
	ld c,a			;b48f
	sub 003h		;b490   ; Tres menos las filas que lleva fuera, por cuatro
	neg		;b492
	add a,a			;b494
	add a,a			;b495
	call 04062h		;b496
	ld b,004h		;b499
	inc c			;b49b
	jr pinta_o_borra_la_torreta		;b49c
adelanta_el_guion_del_fondo:		; Se salta de golpe los renglones que ya quedan detras de la distancia recorrida
	call monta_esta_pieza_de_fondo		;b49e
	jr z,adelanta_el_guion_del_fondo		;b4a1
	ret c			;b4a3
	ld hl,0e109h		;b4a4   ; 0xE109: por que renglon va el guion del fondo
	inc (hl)			;b4a7
	jr adelanta_el_guion_del_fondo		;b4a8
mira_el_guion_del_fondo:		; Cada paso con columna nueva monta las piezas de fondo que caigan en esta distancia
	ld a,(0e100h)		;b4aa   ; Solo en los pasos con columna nueva
	and a			;b4ad
	ret z			;b4ae
	ld a,0f8h		;b4af   ; 0xEC04 a 0xF8: entran por la derecha
	ld (0ec04h),a		;b4b1
monta_las_que_toquen:		; Una detras de otra mientras coincidan
	call monta_esta_pieza_de_fondo		;b4b4
	jr z,monta_las_que_toquen		;b4b7
	ret			;b4b9
monta_esta_pieza_de_fondo:		; Cuatro bytes por renglon: la distancia, la fila y el tipo; al coincidir, se ocupa una ficha de 0xE700
	ld a,(0e109h)		;b4ba   ; La tabla de 0xB7BF: cuatro bytes por renglon
	add a,a			;b4bd
	add a,a			;b4be
	ld hl,0b7bfh		;b4bf
	call 0405dh		;b4c2
	ld e,(hl)			;b4c5
	inc hl			;b4c6
	ld d,(hl)			;b4c7
	inc hl			;b4c8
	ld c,(hl)			;b4c9
	inc hl			;b4ca
	ld b,(hl)			;b4cb
	ld hl,(0e063h)		;b4cc   ; DCOMPR contra la distancia recorrida
	rst 20h			;b4cf
	ret nz			;b4d0
	ld hl,0e109h		;b4d1
	inc (hl)			;b4d4   ; Un renglon menos
	ld hl,0e700h		;b4d5   ; Las ocho fichas de 0xE700
	ld e,008h		;b4d8
	xor a			;b4da
L_B4DB:
	ld a,(hl)			;b4db   ; La primera con el primer byte a cero
	and a			;b4dc
	jr z,L_B4E8		;b4dd
	ld a,008h		;b4df
	add a,l			;b4e1
	ld l,a			;b4e2
	dec e			;b4e3
	jr nz,L_B4DB		;b4e4
	xor a			;b4e6   ; Sin ficha libre no se monta
	ret			;b4e7
L_B4E8:
	ld a,b			;b4e8   ; El tipo, en el primer byte
	inc a			;b4e9
	and 00fh		;b4ea
	ld (hl),a			;b4ec
	cp 005h		;b4ed   ; Del tipo 5 en adelante, otra ficha
	jr nc,monta_una_grande		;b4ef
	ld a,(0ec04h)		;b4f1   ; Las pequenas solo entran por la derecha
	cp 0f8h		;b4f4
	jr z,monta_una_pequena		;b4f6
	ld (hl),000h		;b4f8
	ret			;b4fa
monta_una_pequena:		; Fila de la tabla, columna 0xC0, y el sonido 0x0C
	inc l			;b4fb
	ld (hl),000h		;b4fc
	inc l			;b4fe
	ld (hl),c			;b4ff
	inc l			;b500
	ld (hl),0c0h		;b501   ; La columna 0xC0
	inc l			;b503
	ld (hl),008h		;b504
	inc l			;b506
	ld (hl),00fh		;b507
	inc l			;b509
	ld a,b			;b50a   ; El byte 6 sale del tipo por seis
	add a,a			;b50b
	ld e,a			;b50c
	add a,a			;b50d
	add a,e			;b50e
	ld (hl),a			;b50f
	inc l			;b510
	ld (hl),000h		;b511
	ld a,00ch		;b513   ; El sonido 0x0C
	call 049deh		;b515
	xor a			;b518
	ret			;b519
monta_una_grande:		; Fila de la tabla y columna 0xEC04, con el nibble alto del tipo en el byte 7
	inc l			;b51a   ; El byte 1 a cero
	ld (hl),000h		;b51b
	inc l			;b51d
	ld (hl),c			;b51e   ; La fila que traia el renglon
	inc l			;b51f
	ld a,(0ec04h)		;b520   ; La columna en la que entran todas
	ld (hl),a			;b523
	inc l			;b524
	ld (hl),030h		;b525   ; 0x30 cuadros y el byte 5 a 0x0C
	inc l			;b527
	ld (hl),00ch		;b528
	inc l			;b52a
	ld (hl),a			;b52b
	inc l			;b52c
	ld a,b			;b52d   ; El nibble alto: la variante
	rra			;b52e
	rra			;b52f
	rra			;b530
	rra			;b531
	and 00fh		;b532
	ld (hl),a			;b534
	xor a			;b535
	ret			;b536

; ----------------------------------------------------------------------
; DATOS tabla_B537: Palabras que lee 0xB3F7 con `ld hl,0xB537` (0xB567,
;   0xB580, 0xB599, ...) y, detras, lo que apuntan.
;   0xb537..0xb729  (498 bytes)
DATA_tabla_B537:
	defw 0b567h,0b580h	; b537
	defw 0b599h,0b5b2h	; b53b
	defw 0b5cbh,0b5e4h	; b53f
	defw 0b5fdh,0b5fdh	; b543
	defw 0b5fdh,0b5fdh	; b547
	defw 0b5fdh,0b5fdh	; b54b
	defw 0b5fdh,0b616h	; b54f
	defw 0b62fh,0b648h	; b553
	defw 0b661h,0b67ah	; b557
	defw 0b693h,0b6ach	; b55b
	defw 0b6c5h,0b6deh	; b55f
	defw 0b6f7h,0b710h	; b563
	defw 00000h,00000h	; b567
	defw 00000h,00000h	; b56b
	defw 00000h,00000h	; b56f
	defw 00000h,00000h	; b573
	defw 00000h,00000h	; b577
	defw 044a1h,0a9a8h	; b57b
	defw 00000h,00000h	; b57f
	defw 00000h,00000h	; b583
	defw 00000h,00000h	; b587
	defw 00000h,00000h	; b58b
	defw 044a1h,0a9a8h	; b58f
	defw 04500h,049aeh	; b593
	defw 0004ah,00000h	; b597
	defw 00000h,00000h	; b59b
	defw 00000h,00000h	; b59f
	defw 044a1h,0a9a8h	; b5a3
	defw 04500h,049aeh	; b5a7
	defw 0004ah,0a3a2h	; b5ab
	defw 04babh,000afh	; b5af
	defw 00000h,00000h	; b5b3
	defw 044a1h,0a9a8h	; b5b7
	defw 04500h,049aeh	; b5bb
	defw 0004ah,0a3a2h	; b5bf
	defw 04babh,0a5afh	; b5c3  -> 0x4bab DATA_tabla_A5AF
	defw 0ac47h,04caah	; b5c7  -> L_AC47 0x4caa
	defw 044a1h,0a9a8h	; b5cb
	defw 04500h,049aeh	; b5cf
	defw 0004ah,0a3a2h	; b5d3
	defw 04babh,0a5afh	; b5d7  -> 0x4bab DATA_tabla_A5AF
	defw 0ac47h,04caah	; b5db  -> L_AC47 0x4caa
	defw 0a7a6h,0ad48h	; b5df
	defw 0a14dh,0a844h	; b5e3
	defw 000a9h,0ae45h	; b5e7
	defw 04a49h,04600h	; b5eb
	defw 0aba4h,0af4bh	; b5ef
	defw 047a5h,0aaach	; b5f3
	defw 0a64ch,048a7h	; b5f7
	defw 04dadh,024c1h	; b5fb
	defw 0c9c8h,00000h	; b5ff
	defw 00000h,00000h	; b603
	defw 00000h,00000h	; b607
	defw 00000h,00000h	; b60b
	defw 00000h,00000h	; b60f
	defw 00000h,02500h	; b613
	defw 029ceh,0002ah	; b617
	defw 024c1h,0c9c8h	; b61b
	defw 00000h,00000h	; b61f
	defw 00000h,00000h	; b623
	defw 00000h,00000h	; b627
	defw 00000h,00000h	; b62b
	defw 0c3c2h,02bcbh	; b62f
	defw 025cfh,029ceh	; b633
	defw 0002ah,024c1h	; b637
	defw 0c9c8h,00000h	; b63b
	defw 00000h,00000h	; b63f
	defw 00000h,00000h	; b643
	defw 0c500h,0cc27h	; b647
	defw 02ccah,0c3c2h	; b64b
	defw 02bcbh,025cfh	; b64f
	defw 029ceh,0002ah	; b653
	defw 024c1h,0c9c8h	; b657
	defw 00000h,00000h	; b65b
	defw 00000h,0c7c6h	; b65f
	defw 0cd28h,0c52dh	; b663
	defw 0cc27h,02ccah	; b667
	defw 0c3c2h,02bcbh	; b66b
	defw 025cfh,029ceh	; b66f
	defw 0002ah,024c1h	; b673
	defw 0c9c8h,0c600h	; b677
	defw 028c7h,02dcdh	; b67b
	defw 027c5h,0cacch	; b67f
	defw 0262ch,0cbc4h	; b683
	defw 0cf2bh,0ce25h	; b687
	defw 02a29h,0c100h	; b68b
	defw 0c824h,000c9h	; b68f
	defw 0da00h,069d9h	; b693
	defw 000d2h,00000h	; b697
	defw 00000h,00000h	; b69b
	defw 00000h,00000h	; b69f
	defw 00000h,00000h	; b6a3
	defw 00000h,00000h	; b6a7
	defw 00000h,06e6fh	; b6ab
	defw 06adfh,0da00h	; b6af
	defw 069d9h,000d2h	; b6b3
	defw 00000h,00000h	; b6b7
	defw 00000h,00000h	; b6bb
	defw 00000h,00000h	; b6bf
	defw 00000h,070e0h	; b6c3
	defw 0d4dch,000d3h	; b6c7
	defw 06e6fh,06adfh	; b6cb
	defw 0da00h,069d9h	; b6cf
	defw 000d2h,00000h	; b6d3
	defw 00000h,00000h	; b6d7
	defw 00000h,07100h	; b6db
	defw 0dddbh,0d66ch	; b6df
	defw 070e0h,0d4dch	; b6e3
	defw 000d3h,06e6fh	; b6e7
	defw 06adfh,0da00h	; b6eb
	defw 069d9h,000d2h	; b6ef
	defw 00000h,00000h	; b6f3
	defw 0de72h,0d86dh	; b6f7
	defw 071d7h,0dddbh	; b6fb
	defw 0d66ch,070e0h	; b6ff
	defw 0d4dch,000d3h	; b703
	defw 06e6fh,06adfh	; b707
	defw 0da00h,069d9h	; b70b
	defw 072d2h,06ddeh	; b70f
	defw 0d7d8h,0db71h	; b713
	defw 06cddh,0e0d6h	; b717
	defw 0dc70h,06bd5h	; b71b
	defw 06f00h,0df6eh	; b71f
	defw 0006ah,0d9dah	; b723
	defw 0d269h	; b727

; ----------------------------------------------------------------------
; DATOS tabla_B729: Dieciseis bytes que leen 0xB45C, 0xB47E y 0xB489.
;   0xb729..0xb739  (16 bytes)
DATA_tabla_B729:
	defb 0b2h,04eh,052h,0b5h,0b3h,04fh,053h,0b6h,0b4h,050h,054h,0b7h,000h,051h,055h,000h	; b729  .NR..OS..PT..QU.

; ----------------------------------------------------------------------
; DATOS tabla_B739: Dieciseis bytes que lee 0xB462.
;   0xb739..0xb749  (16 bytes)
DATA_tabla_B739:
	defb 0b2h,04eh,052h,0b5h,0b3h,04fh,053h,0b6h,0b4h,056h,057h,0b7h,000h,058h,059h,000h	; b739  .NR..OS..VW..XY.

; ----------------------------------------------------------------------
; DATOS tabla_B749: Ciento dieciocho bytes que lee 0xB420.
;   0xb749..0xb7bf  (118 bytes)
DATA_tabla_B749:
	defb 059h,0b7h,073h,0b7h,08dh,0b7h,093h,0b7h,099h,0b7h,099h,0b7h,0b3h,0b7h,0b9h,0b7h	; b749  Y.s.............
	defb 004h,006h,05ah,000h,000h,000h,000h,05fh,05bh,05ch,05dh,062h,061h,060h,05eh,005h	; b759  ..Z...._[\]ba`^.
	defb 002h,007h,00ah,063h,000h,006h,004h,009h,00bh,000h,004h,006h,000h,03ch,03ah,03fh	; b769  ...c.........<:?
	defb 041h,000h,068h,03bh,038h,03dh,040h,011h,065h,066h,067h,010h,00fh,00eh,064h,000h	; b779  A.h;8=@.efg...d.
	defb 000h,000h,000h,00dh,001h,004h,05ch,05dh,062h,061h,001h,004h,066h,067h,010h,00fh	; b789  ......\]ba..fg..
	defb 004h,006h,0bch,000h,000h,000h,000h,000h,005h,002h,007h,00ah,007h,0bfh,006h,004h	; b799  ................
	defb 009h,00bh,009h,008h,000h,000h,000h,000h,000h,000h,001h,004h,064h,065h,066h,067h	; b7a9  ............defg
	defb 001h,004h,012h,013h,014h,015h	; b7b9

; ----------------------------------------------------------------------
; DATOS tabla_B7BF: Ciento treinta y cuatro bytes que lee 0xB4BF.
;   0xb7bf..0xb845  (134 bytes)
DATA_tabla_B7BF:
	defb 08dh,000h,078h,000h,096h,000h,008h,002h,099h,000h,058h,002h,0a2h,000h,078h,000h	; b7bf  ..x.......X...x.
	defb 0a6h,000h,008h,002h,0ach,000h,058h,002h,0b6h,000h,078h,000h,0beh,000h,008h,002h	; b7cf  ......X...x.....
	defb 0c2h,000h,040h,000h,0c5h,000h,078h,003h,0c9h,000h,008h,003h,0d2h,000h,058h,002h	; b7df  ..@...x.......X.
	defb 0deh,000h,078h,000h,0e1h,000h,008h,002h,0e6h,000h,028h,045h,002h,001h,060h,044h	; b7ef  ..x.......(E..`D
	defb 010h,001h,000h,077h,01ah,001h,040h,025h,022h,001h,040h,024h,02ch,001h,0a0h,036h	; b7ff  ...w..@%".@$,..6
	defb 036h,001h,048h,015h,038h,001h,000h,027h,087h,001h,078h,000h,08bh,001h,008h,002h	; b80f  6.H.8..'..x.....
	defb 093h,001h,078h,000h,095h,001h,008h,003h,0a1h,001h,078h,003h,0a3h,001h,008h,002h	; b81f  ..x.......x.....
	defb 0abh,001h,078h,000h,0b6h,001h,078h,000h,0b9h,001h,040h,003h,0c2h,001h,078h,000h	; b82f  ..x...x...@...x.
	defb 0bch,001h,000h,047h,0ffh,0ffh	; b83f

; ======================================================================
; CODIGO 0xb845..0xb89e  (89 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL SEGUNDO GUION DE LA FASE 5
; La quinta fase lleva dos listas de distancias: la de 0xB7BF, que monta
; las piezas de fondo, y esta de 0xB8B4, que suelta bichos del tipo 0x1B.
; Aqui la palabra va todavia mas apretada que en la fase 7: los bits 0 y 1
; del byte alto son los bits altos de la distancia -diez en total- y los
; cinco de arriba se guardan en 0xE97E, de donde salen luego la banda por
; la que rebota el bicho y su velocidad. La lista acaba en 0xFFFF.
; ----------------------------------------------------------------------
adelanta_el_guion_de_los_1B:		; Se salta los renglones que ya quedan detras
	ld a,(0e061h)		;b845   ; Solo la fase 5
	cp 005h		;b848
	ret nz			;b84a
	call suelta_este_1B		;b84b
	jp z,adelanta_el_guion_de_los_1B		;b84e
	ret c			;b851
	ld hl,0e97dh		;b852   ; 0xE97D: por que renglon va
	inc (hl)			;b855
	jp adelanta_el_guion_de_los_1B		;b856
mira_el_guion_de_los_1B:		; Cada paso con columna nueva suelta los bichos que caigan en esta distancia
	ld a,(0e061h)		;b859   ; Solo la fase 5
	cp 005h		;b85c
	ret nz			;b85e
	ld a,(0e100h)		;b85f   ; Y solo en los pasos con columna nueva
	and a			;b862
	ret z			;b863
	ld a,0f8h		;b864   ; 0xEC04 a 0xF8: entran por la derecha
	ld (0ec04h),a		;b866
suelta_los_1B_que_toquen:		; Uno detras de otro mientras coincidan
	call suelta_este_1B		;b869
	jp z,suelta_los_1B_que_toquen		;b86c
	ret			;b86f
suelta_este_1B:		; Desempaqueta el renglon: los cinco bits de arriba a 0xE97E y de ahi sale la fila
	call esta_es_la_distancia_del_1B		;b870
	ret nz			;b873
	ld hl,0e97dh		;b874   ; Un renglon menos
	inc (hl)			;b877
	ld a,c			;b878   ; Los cinco bits de arriba, a 0xE97E
	rra			;b879
	rra			;b87a
	and 01fh		;b87b
	ld (0e97eh),a		;b87d
	rra			;b880   ; Su bit 0: por la fila 8...
	ld e,008h		;b881
	jr nc,L_B891		;b883
	rra			;b885   ; ...o por una de las tres de 0xB89E
	rra			;b886
	and 003h		;b887
	ld c,a			;b889
	ld b,000h		;b88a
	ld hl,0b89eh		;b88c
	add hl,bc			;b88f
	ld e,(hl)			;b890
L_B891:
	ld a,(0ec04h)		;b891
	ld d,a			;b894
	ld c,000h		;b895
	ld a,01bh		;b897   ; El tipo 0x1B
	call 06a72h		;b899
	xor a			;b89c
	ret			;b89d

; ----------------------------------------------------------------------
; DATOS tabla_B89E: Tres bytes (0x90, 0x58, 0x20) que leen 0xB88C y 0xB925.
;   0xb89e..0xb8a1  (3 bytes)
DATA_tabla_B89E:
	defb 090h,058h,020h	; b89e

; ======================================================================
; CODIGO 0xb8a1..0xb8b4  (19 bytes)
; ======================================================================


esta_es_la_distancia_del_1B:		; Compara los diez bits de distancia del renglon con la recorrida
	ld hl,0b8b4h		;b8a1   ; La palabra que toca de la lista
	ld a,(0e97dh)		;b8a4
	call 047aeh		;b8a7
	ld c,d			;b8aa
	ld a,d			;b8ab   ; El byte alto se guarda entero...
	and 003h		;b8ac   ; ...y de el solo dos bits son distancia
	ld d,a			;b8ae
	ld hl,(0e063h)		;b8af   ; DCOMPR contra la distancia recorrida
	rst 20h			;b8b2
	ret			;b8b3

; ----------------------------------------------------------------------
; DATOS tabla_B8B4: Treinta y ocho bytes que lee 0xB8A1, en parejas.
;   0xb8b4..0xb8da  (38 bytes)
DATA_tabla_B8B4:
	defb 042h,001h	; b8b4
	defb 048h,011h	; b8b6
	defb 04eh,009h	; b8b8
	defb 053h,015h	; b8ba
	defb 058h,005h	; b8bc
	defb 05dh,00dh	; b8be
	defb 061h,001h	; b8c0
	defb 065h,011h	; b8c2
	defb 069h,009h	; b8c4
	defb 06ch,01dh	; b8c6
	defb 070h,001h	; b8c8
	defb 073h,00dh	; b8ca
	defb 076h,011h	; b8cc
	defb 079h,01dh	; b8ce
	defb 08ah,035h	; b8d0
	defb 08dh,035h	; b8d2
	defb 0aeh,055h	; b8d4
	defb 0b4h,04dh	; b8d6
	defb 0ffh,0ffh	; b8d8

; ======================================================================
; CODIGO 0xb8da..0xb909  (47 bytes)
; ======================================================================


remata_el_tipo_1B:		; De 0xE97E salen la banda por la que rebota y cual de las seis velocidades lleva
	ld a,(0e97eh)		;b8da   ; 0xE97E: lo que traia empaquetado su renglon
	ld b,a			;b8dd
	rra			;b8de
	rra			;b8df
	rra			;b8e0
	and 003h		;b8e1   ; Dos bits: la banda, al byte 19
	ld (ix+013h),a		;b8e3
	ld a,b			;b8e6
	and 007h		;b8e7   ; Y tres: cual de las velocidades
	srl a		;b8e9
	push af			;b8eb
	ld b,a			;b8ec
	ld a,(0e06ah)		;b8ed   ; De la segunda vuelta en adelante, dos escalones mas rapido
	or a			;b8f0
	jr z,L_B8F5		;b8f1
	inc b			;b8f3
	inc b			;b8f4
L_B8F5:
	ld a,b			;b8f5
	ld hl,0b909h		;b8f6   ; La tabla de 0xB909: seis velocidades
	call 047aeh		;b8f9
	pop af			;b8fc
	call c,06729h		;b8fd   ; Y el bit que sobraba le pone el signo
	call 06cbfh		;b900
	ld de,0ff00h		;b903   ; Un punto a la izquierda
	jp 06cc6h		;b906

; ----------------------------------------------------------------------
; DATOS tabla_B909: Doce bytes que lee 0xB8F6, en palabras.
;   0xb909..0xb915  (12 bytes)
DATA_tabla_B909:
	defw 00080h,00100h	; b909
	defw 00180h,00200h	; b90d
	defw 00300h,00400h	; b911

; ======================================================================
; CODIGO 0xb915..0xb93e  (41 bytes)
; ======================================================================


mueve_el_tipo_1B:		; Rebota entre la fila 8 y el fondo de su banda, dandole la vuelta a la velocidad al llegar
	ld bc,00308h		;b915   ; Ocho dibujos, uno cada cuatro cuadros
	ld hl,0b93eh		;b918
	call 095d1h		;b91b
	ld c,008h		;b91e   ; El techo, la fila 8
	ld e,(ix+013h)		;b920   ; Y el suelo, el de su banda
	ld d,000h		;b923
	ld hl,0b89eh		;b925
	add hl,de			;b928
	ld b,(hl)			;b929
	ld a,(ix+008h)		;b92a   ; El byte 8: subiendo o bajando
	or a			;b92d
	ld a,(ix+004h)		;b92e
	jp m,L_B939		;b931
	cp b			;b934   ; Llegado al suelo, se le da la vuelta
	ret c			;b935
	jp 09590h		;b936
L_B939:
	cp c			;b939   ; Y llegado al techo, tambien
	ret nc			;b93a
	jp 09590h		;b93b

; ----------------------------------------------------------------------
; DATOS tabla_B93E: Ocho bytes que lee 0xB918: otra ida y vuelta (0xF0, 0xF4,
;   0xF8, 0xFC, 0xFC, 0xF8, 0xF4, 0xF0).
;   0xb93e..0xb946  (8 bytes)
DATA_tabla_B93E:
	defb 0f0h,0f4h,0f8h,0fch,0fch,0f8h,0f4h,0f0h	; b93e  ........

; ======================================================================
; CODIGO 0xb946..0xbb31  (491 bytes)
; ======================================================================


arranca_la_bandada_larga:		; Cronometro de 0x1E cuadros por cada escalon de dificultad mas 0x14, y una cadencia de 0x1F menos la dificultad
	ld a,001h		;b946   ; 0xE988 a uno: la bandada esta en marcha
	ld (0e988h),a		;b948
	ld a,(0e111h)		;b94b   ; 0xE111 mas 0x14, por 0x1E: los cuadros que dura
	add a,014h		;b94e
	ld h,a			;b950
	ld e,01eh		;b951
	call 06743h		;b953
	ld (0e989h),hl		;b956
	ld a,(0e111h)		;b959   ; Y 0x1F menos la dificultad: los que hay entre bicho y bicho
	sub 01fh		;b95c
	neg		;b95e
	ld h,a			;b960
	ld l,a			;b961
	ld (0e98bh),hl		;b962
	ret			;b965
suelta_la_bandada_larga:		; Mientras dure el cronometro, un tipo 0x1D cada pocos cuadros; uno de cada ocho sale por donde este la nave
	ld a,(0e1c0h)		;b966   ; Con la pantalla parada, no
	and a			;b969
	ret nz			;b96a
	ld a,(0e988h)		;b96b   ; 0xE988: solo con la bandada en marcha
	or a			;b96e
	ret z			;b96f
	ld hl,(0e989h)		;b970   ; Un cuadro menos de bandada
	dec hl			;b973
	ld (0e989h),hl		;b974
	ld a,l			;b977
	or h			;b978
	jp z,07d64h		;b979   ; Agotado el cronometro, la fase sigue
	ld hl,0e98ch		;b97c   ; 0xE98C: los cuadros hasta el siguiente
	dec (hl)			;b97f
	ret nz			;b980
	dec l			;b981
	ld a,(hl)			;b982   ; Recargados desde 0xE98B
	inc l			;b983
	ld (hl),a			;b984
	inc l			;b985
	ld a,(hl)			;b986   ; 0xE98D: cuantos van
	inc (hl)			;b987
	and 007h		;b988   ; Uno de cada ocho va por libre
	call z,este_va_por_donde_la_nave		;b98a
	inc l			;b98d
	ld (hl),a			;b98e
	jr c,L_B997		;b98f
	ld hl,0bb35h		;b991   ; Y los demas, por la lista de 0xBB35
	call 047aeh		;b994
L_B997:
	ld c,000h		;b997
	ld a,01dh		;b999   ; El tipo 0x1D
	jp 06a72h		;b99b
este_va_por_donde_la_nave:		; Con la nave pegada a un borde, el bicho entra por ese mismo borde y por su columna
	ld b,a			;b99e
	ld a,(0e204h)		;b99f   ; La fila de la nave
	cp 008h		;b9a2   ; Pegada arriba...
	jr c,entra_por_arriba		;b9a4
	cp 090h		;b9a6   ; ...o pegada abajo
	jr nc,entra_por_abajo		;b9a8
	xor a			;b9aa   ; Y por el medio, el de la lista
	ld a,b			;b9ab
	ret			;b9ac
entra_por_arriba:		; Por la columna de la nave y la fila 0x0C
	ld a,(0e206h)		;b9ad   ; 0xE206: la columna de la nave
	ld d,a			;b9b0
	ld e,00ch		;b9b1   ; Y la fila 0x0C: por arriba del todo
	ld a,008h		;b9b3
	scf			;b9b5
	ret			;b9b6
entra_por_abajo:		; Por la columna de la nave y la fila 0x8E
	ld a,(0e206h)		;b9b7   ; 0xE206: la columna de la nave
	ld d,a			;b9ba
	ld e,08eh		;b9bb   ; Y la fila 0x8E: por abajo del todo
	ld a,009h		;b9bd
	scf			;b9bf
	ret			;b9c0
remata_el_tipo_1D:		; De la tabla de 0xBB45 salen el centro de su espiral, su cuenta y su sentido de giro
	ld a,(0e98eh)		;b9c1   ; 0xE98E: la variante, al byte 19
	ld (ix+013h),a		;b9c4
	add a,a			;b9c7
	add a,a			;b9c8
	ld hl,0bb45h		;b9c9   ; La tabla de 0xBB45: cuatro bytes por variante
	ld e,a			;b9cc
	ld d,000h		;b9cd
	add hl,de			;b9cf
	ld e,(hl)			;b9d0
	inc hl			;b9d1
	ld d,(hl)			;b9d2
	ld a,(0e98eh)		;b9d3   ; De la variante 8 en adelante, el centro se le pone a cuatro de donde este
	cp 008h		;b9d6
	jr c,L_B9E0		;b9d8
	ld a,(ix+006h)		;b9da
	sub 004h		;b9dd
	ld d,a			;b9df
L_B9E0:
	ld (ix+015h),e		;b9e0   ; Los bytes 21 y 22: el centro de la espiral
	ld (ix+016h),d		;b9e3
	inc hl			;b9e6
	ld a,(hl)			;b9e7
	ld (ix+01ch),a		;b9e8   ; El byte 28: los cuadros de la primera vuelta
	inc hl			;b9eb
	ld a,(hl)			;b9ec
	ld (ix+01eh),a		;b9ed   ; Y el byte 30: hacia que lado gira
	ld (ix+014h),0ffh		;b9f0   ; El byte 20 a 0xFF: el radio, entero
	ld (ix+002h),032h		;b9f4   ; 0x32 cuadros
	ld (ix+01bh),000h		;b9f8
	jp 09510h		;b9fc
mueve_el_tipo_1D:		; Dispara, se estrella si toca el mapa y, pasada su cuenta, se pone a girar en espiral
	ld bc,00304h		;b9ff   ; Cuatro dibujos, uno cada cuatro cuadros
	ld a,(ix+001h)		;ba02
	or a			;ba05
	jr nz,L_BA0A		;ba06
	ld b,001h		;ba08
L_BA0A:
	ld hl,0bb31h		;ba0a
	call 095d1h		;ba0d
	ld l,(ix+004h)		;ba10   ; Su fila y su columna...
	ld h,(ix+006h)		;ba13
	call 09857h		;ba16   ; ...contra el mapa: si choca, revienta
	jp c,072d2h		;ba19
	ld a,(ix+001h)		;ba1c   ; El byte 1: por que paso va
	dec a			;ba1f
	jp z,el_1D_empieza_la_espiral		;ba20
	ret p			;ba23
	dec (ix+002h)		;ba24   ; El byte 2: los cuadros que faltan
	jr z,el_1D_aguanta		;ba27
	ld a,(ix+002h)		;ba29
	cp 01eh		;ba2c   ; A falta de 0x1E, empieza a parpadear
	ret nc			;ba2e
	ld b,008h		;ba2f   ; Color 8, y 9 en los diez ultimos
	cp 00ah		;ba31
	jr nc,L_BA36		;ba33
	inc b			;ba35
L_BA36:
	ld (ix+00dh),b		;ba36
	ret			;ba39
el_1D_aguanta:		; Otros 0x3C cuadros, y el byte 27 a tres
	ld (ix+002h),03ch		;ba3a
	ld (ix+01bh),003h		;ba3e
	inc (ix+001h)		;ba42
	ret			;ba45
el_1D_empieza_la_espiral:		; Al agotar el byte 28 toma las dos velocidades que le tocan a su variante
	call el_1D_dispara		;ba46
	dec (ix+01ch)		;ba49   ; El byte 28: lo que le queda de recto
	jp nz,gira_a_un_lado		;ba4c
	inc (ix+001h)		;ba4f
	ld hl,0bb6dh		;ba52   ; La tabla de 0xBB6D: dos velocidades por variante
	ld a,(ix+013h)		;ba55
	add a,a			;ba58
	add a,a			;ba59
	ld e,a			;ba5a
	ld d,000h		;ba5b
	add hl,de			;ba5d
	ld e,(hl)			;ba5e
	inc hl			;ba5f
	ld d,(hl)			;ba60
	call 06cbfh		;ba61
	inc hl			;ba64
	ld e,(hl)			;ba65
	inc hl			;ba66
	ld d,(hl)			;ba67
	jp 06cc6h		;ba68
el_1D_dispara:		; Con el escudo de la nave puesto dispara cada 0x40 o cada 0x20 cuadros; y si no, sin cuenta
	ld a,(0e20bh)		;ba6b   ; 0xE20B: el escudo de la nave
	dec a			;ba6e
	ld b,03fh		;ba6f
	jr z,el_1D_dispara_a_ratos		;ba71
	ld b,01fh		;ba73
	jp p,el_1D_dispara_a_ratos		;ba75
	ld a,(0e06ah)		;ba78   ; 0xE06A: de la segunda vuelta en adelante, siempre
	or a			;ba7b
	jp nz,09235h		;ba7c
	ld a,(0e200h)		;ba7f   ; Y tambien con la nave a medio salir o a medio explotar
	cp 003h		;ba82
	jp z,09235h		;ba84
	ld a,(0e20eh)		;ba87
	or a			;ba8a
	jp nz,09235h		;ba8b
	ret			;ba8e
el_1D_dispara_a_ratos:		; Cada 0x40 o cada 0x20 cuadros, segun el escudo
	ld a,(0e003h)		;ba8f
	and b			;ba92
	ret nz			;ba93
	ld a,(0e008h)		;ba94   ; El bit 4 de 0xE008
	and 010h		;ba97
	ret z			;ba99
	jp 09239h		;ba9a

; ----------------------------------------------------------------------
; LA ESPIRAL NO USA SENOS: SE HACE CON UN OCTAVO Y UNA MULTIPLICACION
; Girar alrededor de un centro sale aqui de una regla de tres lineas: se
; toma la diferencia hasta el centro en una direccion, se parte por ocho
; -tres `sra a`- y se le suma a la otra; y con la otra, al reves. Eso da
; un giro de unos siete grados por paso, sin tocar ninguna tabla de
; senos. El radio se encoge aparte: las dos coordenadas se multiplican por
; el byte 20, que empieza en 0xFF y baja de uno en uno cada 0x3C cuadros,
; asi que la vuelta se va cerrando sola. El bit 0 del byte 30 elige el
; sentido: los dos trozos son el mismo con los signos cambiados.
; ----------------------------------------------------------------------
gira_a_un_lado:		; Unos siete grados por paso alrededor del centro, y el radio encogiendose
	bit 0,(ix+01eh)		;ba9d   ; El bit 0 del byte 30: hacia que lado gira
	jr z,gira_al_otro_lado		;baa1
	ld a,(ix+004h)		;baa3   ; La diferencia en fila hasta el centro...
	sub (ix+015h)		;baa6
	sra a		;baa9   ; ...partida por ocho...
	sra a		;baab
	sra a		;baad
	add a,(ix+006h)		;baaf   ; ...se le suma a la columna
	ld h,a			;bab2
	ld e,(ix+014h)		;bab3   ; Y el byte 20 encoge el radio
	call 06743h		;bab6
	exx			;bab9
	ld a,(ix+006h)		;baba   ; Lo mismo con la diferencia en columna
	sub (ix+016h)		;babd
	sra a		;bac0
	sra a		;bac2
	sra a		;bac4
	neg		;bac6
	add a,(ix+004h)		;bac8
	ld h,a			;bacb
	ld e,(ix+014h)		;bacc
	call 06743h		;bacf
	ld (ix+004h),h		;bad2
	exx			;bad5
	ld (ix+006h),h		;bad6
	dec (ix+002h)		;bad9   ; El byte 2: cada 0x3C cuadros...
	ret nz			;badc
	ld (ix+002h),03ch		;badd
	ld a,(ix+014h)		;bae1   ; ...el radio pierde un escalon
	sub 001h		;bae4
	ld (ix+014h),a		;bae6
	ret			;bae9
gira_al_otro_lado:		; El mismo baile con los signos cambiados
	ld a,(ix+004h)		;baea   ; La diferencia en fila hasta el centro...
	sub (ix+015h)		;baed
	sra a		;baf0   ; ...partida por ocho y con el signo cambiado...
	sra a		;baf2
	sra a		;baf4
	neg		;baf6
	add a,(ix+006h)		;baf8   ; ...se le suma a la columna
	ld h,a			;bafb
	ld e,(ix+014h)		;bafc   ; Y el byte 20 encoge el radio
	call 06743h		;baff
	exx			;bb02
	ld a,(ix+006h)		;bb03   ; Lo mismo con la diferencia en columna
	sub (ix+016h)		;bb06
	sra a		;bb09
	sra a		;bb0b
	sra a		;bb0d
	add a,(ix+004h)		;bb0f
	ld h,a			;bb12
	ld e,(ix+014h)		;bb13
	call 06743h		;bb16
	ld (ix+004h),h		;bb19
	exx			;bb1c
	ld (ix+006h),h		;bb1d
	dec (ix+002h)		;bb20   ; El byte 2: cada 0x3C cuadros...
	ret nz			;bb23
	ld (ix+002h),03ch		;bb24
	ld a,(ix+014h)		;bb28   ; ...el radio pierde un escalon
	sub 001h		;bb2b
	ld (ix+014h),a		;bb2d
	ret			;bb30

; ----------------------------------------------------------------------
; DATOS tabla_BB31: Cien bytes que leen 0xBA0A (0xBB31), 0xB991 (0xBB35),
;   0xB9C9 (0xBB45) y 0xBA52 (0xBB6D).
;   0xbb31..0xbb95  (100 bytes)
DATA_tabla_BB31:
	defb 0a0h,0a4h,0a8h,0ach,068h,0c8h,044h,020h,030h,058h,078h,080h,028h,0b0h,070h,090h	; bb31  ....h.D 0Xx.(.p.
	defb 06ch,018h,040h,0d0h,060h,0b0h,0c0h,000h,04ch,030h,0c0h,000h,038h,050h,0d4h,001h	; bb41  l.@.`...L0..8P..
	defb 058h,090h,0a6h,001h,030h,0a0h,0b8h,001h,060h,070h,0b2h,000h,064h,020h,090h,000h	; bb51  X...0...`p..d ..
	defb 030h,0c8h,09ch,001h,01ch,00ch,0ffh,000h,08ah,004h,0ffh,000h,000h,002h,000h,002h	; bb61  0...............
	defb 000h,000h,000h,0fch,000h,000h,000h,0fch,000h,0feh,000h,003h,080h,001h,080h,004h	; bb71  ................
	defb 000h,0fdh,000h,003h,0c0h,000h,000h,0fbh,000h,0fbh,0c0h,0ffh,000h,0fch,0c0h,0ffh	; bb81  ................
	defb 000h,004h,0c0h,0ffh	; bb91

; ======================================================================
; CODIGO 0xbb95..0xbbe9  (84 bytes)
; ======================================================================


arranca_la_bandada_de_los_grandes:		; Otro cronometro como el de 0xB946, con la cadencia en 0x28 menos el doble de la dificultad
	ld a,001h		;bb95   ; 0xE990 a uno: la bandada esta en marcha
	ld (0e990h),a		;bb97
	ld a,(0e111h)		;bb9a   ; 0xE111 mas 0x14, por 0x1E: lo que dura
	add a,014h		;bb9d
	ld h,a			;bb9f
	ld e,01eh		;bba0
	call 06743h		;bba2
	ld (0e991h),hl		;bba5
	ld a,(0e111h)		;bba8   ; Y 0x28 menos el doble de la dificultad, entre uno y otro
	add a,a			;bbab
	sub 028h		;bbac
	neg		;bbae
	ld h,a			;bbb0
	ld l,a			;bbb1
	ld (0e993h),hl		;bbb2
	ret			;bbb5
suelta_la_bandada_de_los_grandes:		; Mientras dure el cronometro, un tipo 0x1E cada pocos cuadros, turnandose las cuatro puertas de 0xBBE9
	ld a,(0e1c0h)		;bbb6   ; Con la pantalla parada, no
	and a			;bbb9
	ret nz			;bbba
	ld a,(0e990h)		;bbbb   ; 0xE990: solo con la bandada en marcha
	or a			;bbbe
	ret z			;bbbf
	ld hl,(0e991h)		;bbc0   ; Un cuadro menos
	dec hl			;bbc3
	ld (0e991h),hl		;bbc4
	ld a,l			;bbc7
	or h			;bbc8
	jp z,07d64h		;bbc9   ; Agotado el cronometro, la fase sigue
	ld hl,0e994h		;bbcc   ; 0xE994: los cuadros hasta el siguiente
	dec (hl)			;bbcf
	ret nz			;bbd0
	dec l			;bbd1
	ld a,(hl)			;bbd2
	inc l			;bbd3
	ld (hl),a			;bbd4
	inc l			;bbd5
	inc (hl)			;bbd6   ; 0xE996: la puerta, de cuatro en redondo
	ld a,(hl)			;bbd7
	and 003h		;bbd8
	inc l			;bbda
	ld (hl),a			;bbdb
	ld hl,0bbe9h		;bbdc   ; La tabla de 0xBBE9: cuatro puertas
	call 047aeh		;bbdf
	ld c,000h		;bbe2
	ld a,01eh		;bbe4   ; El tipo 0x1E
	jp 06a72h		;bbe6

; ----------------------------------------------------------------------
; DATOS tabla_BBE9: Ocho bytes que lee 0xBBDC, en parejas.
;   0xbbe9..0xbbf1  (8 bytes)
DATA_tabla_BBE9:
	defb 048h,012h	; bbe9
	defb 018h,0deh	; bbeb
	defb 048h,0deh	; bbed
	defb 070h,0deh	; bbef

; ======================================================================
; CODIGO 0xbbf1..0xbc43  (82 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL BICHO DE TRES RANURAS
; El tipo 0x1E es el unico que no cabe en una ranura: ocupa TRES seguidas,
; y por eso p01:0x6A98 las busca de tres en tres. Aqui se montan las otras
; dos de un solo `ldir` de 0x40 bytes que se pisa a si mismo -copiando la
; primera sobre la segunda y la segunda sobre la tercera-, y luego se les
; pone la posicion: una 0x10 por debajo y ocho a la izquierda, y la otra
; 0x10 por debajo y ocho a la derecha. Solo la primera se mueve; las otras
; dos la siguen. Al acabarse su cuenta, las tres se convierten en el tipo
; 0x1F y salen despedidas cada una por su lado.
; ----------------------------------------------------------------------
remata_el_tipo_1E:		; Monta las tres ranuras, las coloca en triangulo y les da la velocidad de su puerta
	ld a,(0e996h)		;bbf1   ; 0xE996: por que puerta ha entrado
	or a			;bbf4
	jr nz,L_BC05		;bbf5
	ld a,(0e204h)		;bbf7   ; Con la nave por debajo de la fila 0x50 entra por arriba, y si no por abajo
	cp 050h		;bbfa
	ld a,018h		;bbfc
	jr nc,L_BC02		;bbfe
	ld a,078h		;bc00
L_BC02:
	ld (ix+004h),a		;bc02
L_BC05:
	call 09510h		;bc05
	ld (ix+01dh),000h		;bc08
	call copia_las_otras_dos_ranuras		;bc0c   ; Las otras dos ranuras, copiadas
	call coloca_las_tres_en_triangulo		;bc0f   ; Y colocadas en triangulo
	xor a			;bc12
	call pon_la_terna_de_dibujos		;bc13
	ld (ix+014h),001h		;bc16   ; El byte 20: los cuadros hasta el cambio de dibujo
	ld (ix+002h),05ah		;bc1a   ; 0x5A cuadros de vida
	ld (ix+013h),000h		;bc1e   ; El byte 19 dice cual de las tres es cada una
	ld (ix+033h),001h		;bc22
	ld (ix+053h),002h		;bc26
	ld a,(0e996h)		;bc2a   ; La tabla de 0xBC43: dos velocidades por puerta
	add a,a			;bc2d
	add a,a			;bc2e
	ld e,a			;bc2f
	ld d,000h		;bc30
	ld hl,0bc43h		;bc32
	add hl,de			;bc35
	ld e,(hl)			;bc36
	inc hl			;bc37
	ld d,(hl)			;bc38
	call 06cbfh		;bc39
	inc hl			;bc3c
	ld e,(hl)			;bc3d
	inc hl			;bc3e
	ld d,(hl)			;bc3f
	jp 06cc6h		;bc40

; ----------------------------------------------------------------------
; DATOS tabla_BC43: Dieciseis bytes que lee 0xBC32, en palabras.
;   0xbc43..0xbc53  (16 bytes)
DATA_tabla_BC43:
	defw 00000h,00040h	; bc43
	defw 00000h,0ff40h	; bc47
	defw 00000h,0ffc0h	; bc4b
	defw 00000h,0ff80h	; bc4f

; ======================================================================
; CODIGO 0xbc53..0xbc83  (48 bytes)
; ======================================================================


parpadea_el_tipo_1E:		; Cambia de terna de dibujos cada 0x0F o cada 5 cuadros, a suertes con el registro R
	dec (ix+014h)		;bc53
	ret nz			;bc56
	ld b,00fh		;bc57
	ld a,r		;bc59   ; El registro R: 0x0F cuadros o solo 5
	and 001h		;bc5b
	jr nz,L_BC61		;bc5d
	ld b,005h		;bc5f
L_BC61:
	ld (ix+014h),b		;bc61
	ld a,(ix+01dh)		;bc64   ; El byte 29: una terna o la otra
	xor 001h		;bc67
	ld (ix+01dh),a		;bc69
pon_la_terna_de_dibujos:		; Un caracter para cada una de las tres ranuras
	ld hl,0bc83h		;bc6c
	jr z,L_BC74		;bc6f
	ld hl,0bc86h		;bc71
L_BC74:
	ld a,(hl)			;bc74   ; El de la primera ranura...
	ld (ix+00ch),a		;bc75
	inc hl			;bc78
	ld a,(hl)			;bc79   ; ...el de la segunda, 0x20 bytes mas alla...
	ld (ix+02ch),a		;bc7a
	inc hl			;bc7d
	ld a,(hl)			;bc7e   ; ...y el de la tercera
	ld (ix+04ch),a		;bc7f
	ret			;bc82

; ----------------------------------------------------------------------
; DATOS tabla_BC83: Seis bytes que leen 0xBC6C (0xBC83) y 0xBC71 (0xBC86).
;   0xbc83..0xbc89  (6 bytes)
DATA_tabla_BC83:
	defb 0d0h,0d4h,0d8h	; bc83
	defb 0dch,0e0h,0e4h	; bc86

; ======================================================================
; CODIGO 0xbc89..0xbd71  (232 bytes)
; ======================================================================


pon_el_color_de_las_tres:		; Color 7 o 5, el mismo en las tres ranuras
	bit 2,a		;bc89
	ld a,007h		;bc8b
	jr z,L_BC91		;bc8d
	ld a,005h		;bc8f
L_BC91:
	ld (ix+00dh),a		;bc91
	ld (ix+02dh),a		;bc94
	ld (ix+04dh),a		;bc97
	ret			;bc9a
copia_las_otras_dos_ranuras:		; Un `ldir` de 0x40 bytes que se pisa a si mismo: con una sola copia quedan hechas las dos
	push ix		;bc9b
	pop hl			;bc9d
	ld d,h			;bc9e
	ld e,l			;bc9f
	ld a,020h		;bca0   ; El destino, 0x20 bytes por delante del origen
	add a,e			;bca2
	ld e,a			;bca3
	jr nc,L_BCA7		;bca4
	inc d			;bca6
L_BCA7:
	ld bc,00040h		;bca7   ; 0x40 bytes: las dos ranuras de detras
	ldir		;bcaa
	ret			;bcac
coloca_las_tres_en_triangulo:		; La segunda 0x10 mas abajo y ocho a la izquierda; la tercera, ocho a la derecha
	ld a,(ix+004h)		;bcad
	add a,010h		;bcb0   ; 0x10 por debajo de la primera
	ld d,a			;bcb2
	ld (ix+024h),d		;bcb3
	ld a,(ix+006h)		;bcb6
	sub 008h		;bcb9   ; Y ocho a la izquierda
	ld e,a			;bcbb
	ld (ix+026h),e		;bcbc
	ld (ix+044h),d		;bcbf
	ld a,e			;bcc2
	add a,010h		;bcc3   ; La tercera, ocho a la derecha
	ld (ix+046h),a		;bcc5
	ret			;bcc8
el_1E_dispara:		; De la segunda vuelta en adelante y con el escudo puesto, cada 0x20 cuadros
	ld a,(0e06ah)		;bcc9   ; 0xE06A: en la primera vuelta no dispara
	or a			;bccc
	ret z			;bccd
	ld a,(0e20bh)		;bcce   ; 0xE20B: ni sin escudo
	cp 002h		;bcd1
	ret c			;bcd3
	ld a,(0e003h)		;bcd4   ; Uno de cada 0x20 cuadros
	and 01fh		;bcd7
	ret nz			;bcd9
	ld a,(0e008h)		;bcda
	and 010h		;bcdd
	ret z			;bcdf
	jp 09239h		;bce0
mueve_el_tipo_1E:		; Solo la primera ranura se mueve: se acerca a la fila de la nave entre la 0x10 y la 0x70, y arrastra a las otras dos
	ld a,(ix+013h)		;bce3   ; Las ranuras segunda y tercera no se mueven solas
	or a			;bce6
	ret nz			;bce7
	dec (ix+002h)		;bce8   ; El byte 2: los cuadros de vida
	jr z,el_1E_se_parte_en_tres		;bceb
	ld a,(ix+002h)		;bced
	cp 01eh		;bcf0   ; A falta de 0x1E, empieza a parpadear de color
	call c,pon_el_color_de_las_tres		;bcf2
	call parpadea_el_tipo_1E		;bcf5   ; El dibujo, que va a su aire
	call el_1E_dispara		;bcf8
	ld a,(0e204h)		;bcfb   ; La fila de la nave menos la suya
	sub (ix+004h)		;bcfe
	ld de,00020h		;bd01   ; Un tercio de punto hacia ella
	jr nc,L_BD09		;bd04
	ld de,0ffe0h		;bd06
L_BD09:
	call 06cbfh		;bd09
	call 05f7ch		;bd0c
	ld a,070h		;bd0f   ; Sin pasar de la fila 0x70...
	cp (ix+004h)		;bd11
	jr nc,L_BD1B		;bd14
	ld (ix+004h),a		;bd16
	jr L_BD25		;bd19
L_BD1B:
	ld a,010h		;bd1b   ; ...ni subir de la 0x10
	cp (ix+004h)		;bd1d
	jr c,L_BD25		;bd20
	ld (ix+004h),a		;bd22
L_BD25:
	call coloca_las_tres_en_triangulo		;bd25   ; Y las otras dos, detras
	ld a,(ix+006h)		;bd28
	sub 010h		;bd2b
	cp 0d0h		;bd2d   ; Pasada la columna 0xD0, se le da la vuelta
	ret c			;bd2f
	jp 09580h		;bd30
el_1E_se_parte_en_tres:		; Agotada la cuenta, las tres ranuras pasan a ser del tipo 0x1F y salen despedidas cada una por su lado
	ld hl,0bd71h		;bd33   ; La tabla de 0xBD71: dos velocidades por trozo
	exx			;bd36
	ld b,003h		;bd37   ; Las tres ranuras
L_BD39:
	exx			;bd39
	ld (ix+000h),01fh		;bd3a   ; El tipo 0x1F y el caracter 0xE8
	ld (ix+00ch),0e8h		;bd3e
	xor a			;bd42
	ld (ix+002h),a		;bd43
	ld (ix+01dh),a		;bd46
	inc a			;bd49
	ld (ix+00fh),a		;bd4a
	inc a			;bd4d
	inc a			;bd4e
	ld (ix+01bh),a		;bd4f
	ld (ix+014h),a		;bd52
	ld e,(hl)			;bd55
	inc hl			;bd56
	ld d,(hl)			;bd57
	call 06cbfh		;bd58
	inc hl			;bd5b
	ld e,(hl)			;bd5c
	inc hl			;bd5d
	ld d,(hl)			;bd5e
	inc hl			;bd5f
	call 06cc6h		;bd60
	ld bc,00020h		;bd63   ; 0x20 bytes: la ranura siguiente
	add ix,bc		;bd66
	exx			;bd68
	djnz L_BD39		;bd69
	ld bc,0ffa0h		;bd6b   ; Y de vuelta a la primera
	add ix,bc		;bd6e
	ret			;bd70

; ----------------------------------------------------------------------
; DATOS tabla_BD71: Doce bytes que lee 0xBD33, en palabras con signo.
;   0xbd71..0xbd7d  (12 bytes)
DATA_tabla_BD71:
	defw 0ff80h,00000h	; bd71
	defw 00080h,0ff80h	; bd75
	defw 00080h,00080h	; bd79

; ======================================================================
; CODIGO 0xbd7d..0xbe19  (156 bytes)
; ======================================================================


mueve_el_tipo_1F:		; Revienta al tocar el mapa, parpadea, y persigue a la nave o busca la fila 0x58 segun este la bandada de los grandes
	call el_1F_toca_el_mapa		;bd7d
	jp c,072d2h		;bd80   ; Tocando el mapa, revienta
	call parpadea_el_tipo_1F		;bd83   ; El parpadeo
	ld a,(0e990h)		;bd86   ; 0xE990: con la bandada de los grandes en marcha, persigue
	or a			;bd89
	jr z,L_BD95		;bd8a
	call 095ebh		;bd8c   ; La aceleracion hacia la nave, y las dos sumas
	call 0953ch		;bd8f
	jp 09550h		;bd92
L_BD95:
	ld a,(ix+004h)		;bd95   ; Y si no, se va a la fila 0x58
	cp 058h		;bd98
	ld de,00200h		;bd9a   ; Dos puntos hacia abajo...
	jr nc,L_BDA2		;bd9d
	ld de,0fe00h		;bd9f   ; ...o dos hacia arriba
L_BDA2:
	jp 06cbfh		;bda2
el_1F_toca_el_mapa:		; Mira la casilla donde esta y, si va bajando, la de 0x10 mas abajo
	ld l,(ix+004h)		;bda5   ; Su fila y su columna
	ld h,(ix+006h)		;bda8
	bit 7,(ix+008h)		;bdab   ; El byte 8: bajando, se mira mas abajo
	jr nz,L_BDB5		;bdaf
	ld a,l			;bdb1
	add a,010h		;bdb2
	ld l,a			;bdb4
L_BDB5:
	jp 09857h		;bdb5
parpadea_el_tipo_1F:		; Le cambia el bit 2 del caracter cada 10 o cada 3 cuadros, a suertes con el registro R
	dec (ix+014h)		;bdb8
	ret nz			;bdbb
	ld b,00ah		;bdbc
	ld a,r		;bdbe   ; El registro R: 10 cuadros o solo 3
	and 001h		;bdc0
	jr nz,L_BDC6		;bdc2
	ld b,003h		;bdc4
L_BDC6:
	ld (ix+014h),b		;bdc6
	ld a,(ix+00ch)		;bdc9
	xor 004h		;bdcc   ; El bit 2 del caracter: dos dibujos
	ld (ix+00ch),a		;bdce
	ret			;bdd1

; ----------------------------------------------------------------------
; EL FONDO QUE SE MUEVE SIN GASTAR NI UN SPRITE
; Aqui no se mueve ningun objeto: se le cambia el DIBUJO a tres caracteres
; -el 0xF6, el 0xF7 y el 0xF8- reescribiendo sus ocho bytes en la VRAM. La
; tabla de 0xBE19 trae seis dibujos para cada uno, y cada uno va por libre:
; cuanto dura su dibujo lo echa a suertes el registro R, entre 8 y 0x17
; cuadros. Como el fondo esta hecho con esos tres caracteres, todas las
; casillas que los usen se mueven a la vez sin costar nada.
; ----------------------------------------------------------------------
anima_los_tres_caracteres:		; Reescribe en la VRAM los ocho bytes de los caracteres 0xF6, 0xF7 y 0xF8
	call anima_las_siete_casillas		;bdd2
	ld hl,0e700h		;bdd5   ; El caracter 0xF6, con su cuenta en 0xE700
	ld de,0be19h		;bdd8
	ld c,0f6h		;bddb
	call anima_un_caracter		;bddd
	ld hl,0e702h		;bde0   ; El 0xF7, con la suya en 0xE702
	ld de,0be1fh		;bde3
	ld c,0f7h		;bde6
	call anima_un_caracter		;bde8
	ld hl,0e704h		;bdeb   ; Y el 0xF8, en 0xE704
	ld de,0be25h		;bdee
	ld c,0f8h		;bdf1
anima_un_caracter:		; Al agotarse la cuenta pasa al dibujo siguiente de los seis y lo sube a la VRAM
	dec (hl)			;bdf3   ; Los cuadros que le quedan a este dibujo
	ret nz			;bdf4
	ld a,r		;bdf5   ; El registro R: entre 8 y 0x17 cuadros
	and 00fh		;bdf7
	add a,008h		;bdf9
	ld (hl),a			;bdfb
	dec hl			;bdfc
	ld a,(hl)			;bdfd   ; El dibujo siguiente...
	inc a			;bdfe
	cp 006h		;bdff   ; ...de los seis, en redondo
	jr c,L_BE04		;be01
	xor a			;be03
L_BE04:
	ld (hl),a			;be04
	call 04062h		;be05
	ld a,(de)			;be08
	ld l,c			;be09   ; El numero de caracter por ocho: donde vive en la VRAM
	ld h,000h		;be0a
	add hl,hl			;be0c
	add hl,hl			;be0d
	add hl,hl			;be0e
	ld de,00000h		;be0f
	add hl,de			;be12
	ld bc,00008h		;be13   ; Ocho bytes: una fila de caracteres
	jp 04977h		;be16

; ----------------------------------------------------------------------
; DATOS tabla_BE19: Dieciocho bytes que leen 0xBDD8 (0xBE19), 0xBDE3 (0xBE1F)
;   y 0xBDEE (0xBE25), en grupos de seis.
;   0xbe19..0xbe2b  (18 bytes)
DATA_tabla_BE19:
	defb 070h,050h,040h,000h,040h,050h	; be19
	defb 0f0h,0b0h,0a0h,000h,0a0h,0b0h	; be1f
	defb 090h,080h,060h,000h,060h,080h	; be25

; ======================================================================
; CODIGO 0xbe2b..0xbe62  (55 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Y SIETE CASILLAS QUE CAMBIAN DE CARACTER
; El otro truco del fondo: siete fichas de ocho bytes en 0xE710, cada una
; con la direccion de VRAM de una casilla del mapa. Cada tantos cuadros se
; le escribe encima otro caracter de la lista 0xF0, 0xF2, 0xF4, 0xF2, y el
; de debajo -0x20 bytes mas alla- el siguiente. Dos casillas por ficha, y
; ni un objeto de por medio.
; ----------------------------------------------------------------------
anima_las_siete_casillas:		; Siete fichas de ocho bytes en 0xE710, cada una con su casilla del mapa
	ld b,007h		;be2b   ; Siete fichas
	ld hl,0e710h		;be2d
L_BE30:
	push bc			;be30
	push hl			;be31
	call anima_una_casilla		;be32
	pop hl			;be35
	pop bc			;be36
	ld de,00008h		;be37   ; Ocho bytes por ficha
	add hl,de			;be3a
	djnz L_BE30		;be3b
	ret			;be3d
anima_una_casilla:		; Escribe en su casilla el caracter que toque, y en la de debajo el siguiente
	dec (hl)			;be3e   ; Los cuadros que le quedan
	ret nz			;be3f
	inc hl			;be40
	ld a,(hl)			;be41   ; Recargados desde el byte de al lado
	dec hl			;be42
	ld (hl),a			;be43
	inc hl			;be44
	inc hl			;be45
	ld a,(hl)			;be46   ; El dibujo siguiente, de cuatro en redondo
	inc a			;be47
	and 003h		;be48
	ld (hl),a			;be4a
	ld de,0be62h		;be4b   ; La lista de 0xBE62
	call 04062h		;be4e
	ld a,(de)			;be51
	inc hl			;be52
	ld e,(hl)			;be53   ; La direccion de VRAM de su casilla
	inc hl			;be54
	ld d,(hl)			;be55
	ex de,hl			;be56
	call 0004dh		;be57   ; BIOS WRTVRM - Writes data in VRAM
	ld de,00020h		;be5a   ; Y 0x20 mas alla, la de debajo
	add hl,de			;be5d
	inc a			;be5e
	jp 0004dh		;be5f   ; BIOS WRTVRM - Writes data in VRAM

; ----------------------------------------------------------------------
; DATOS tabla_BE62: Cuatro bytes (0xF0, 0xF2, 0xF4, 0xF2) que lee 0xBE4B con
;   `ld de,0xBE62`.
;   0xbe62..0xbe66  (4 bytes)
DATA_tabla_BE62:
	defb 0f0h,0f2h,0f4h,0f2h	; be62

; ----------------------------------------------------------------------
; DATOS relleno: Relleno 0xFF: el hueco que queda entre el ultimo dato del
;   banco y la marca de Konami.
;   0xbe66..0xbff5  (399 bytes)
DATA_relleno:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; be66  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; be76  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; be86  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; be96  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bea6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; beb6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bec6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bed6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bee6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bef6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bf06  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bf16  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bf26  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bf36  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bf46  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bf56  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bf66  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bf76  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bf86  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bf96  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bfa6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bfb6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bfc6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bfd6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bfe6  ...............

; ----------------------------------------------------------------------
; DATOS marca_de_konami: La marca que Konami escondio al final del banco. Once
;   bytes: los ocho del titulo AL REVES (8C 82 B4 B7 92 A6 B7 87), el 0x08 que
;   dice cuantos son, el 0x42 que son las dos ultimas cifras del RC en BCD -o
;   sea RC-742- y el 0xAA que la cierra. Leidos del derecho y con la tabla de
;   katakana de la casa (indice = byte menos 0x80, gojuon corrido) dan グラディウス:
;   GRADIUS. El hallazgo es de Manuel Pazos (@ManuelPazosMSX).
;   0xbff5..0xc000  (11 bytes)

; ----------------------------------------------------------------------
; LA MARCA QUE KONAMI ESCONDIO AL FINAL DEL BANCO
; ----------------------------------------------------------------------
DATA_marca_de_konami:
	defb 08ch,082h,0b4h,0b7h,092h,0a6h,0b7h,087h	; bff5  ........
	defb 008h	; bffd
	defb 042h	; bffe
	defb 0aah	; bfff

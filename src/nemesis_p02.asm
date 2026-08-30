; ==========================================================================
; NEMESIS / GRADIUS - Konami (1986) - MSX1 - MegaROM RC-742 de 128 KB (Konami4) - banco 02 (se ejecuta en 0x8000)
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x08000


; ----------------------------------------------------------------------
; Direcciones que solo aparecen como VALOR -en un `ld`, no en
; un salto-: son punteros que el codigo se pasa o numeros que
; casualmente coinciden con una direccion. No hay nada que
; trazar en ellas; el equ existe para que el listado ensamble.
; ----------------------------------------------------------------------
l8fe4h:	equ 0x08fe4

; ----------------------------------------------------------------------
; DATOS tercer_byte_de_la_instruccion_partida: El 0x80 que completa el `ld
;   hl,0x8041` de p01:7FFE. Se lista aparte porque en este banco no hay
;   instruccion que lo contenga.
;   0x8000..0x8001  (1 bytes)

; ----------------------------------------------------------------------
; EL PRIMER BYTE ES EL TERCERO DE UNA INSTRUCCION DEL BANCO 1
; ----------------------------------------------------------------------
DATA_tercer_byte_de_la_instruccion_partida:
	defb 080h	; 8000

; ======================================================================
; CODIGO 0x8001..0x8041  (64 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL BANCO DE LOS JEFES Y DE LOS CHOQUES CON EL MAPA
; En este banco viven los motores de los jefes de fase, la rutina que dice
; si un punto choca con el mapa, y buena parte del dibujado. Empieza de una
; forma rara: la primera instruccion NO esta entera aqui, sino que sus dos
; primeros bytes son los ultimos del banco 1.
; ----------------------------------------------------------------------
sigue_del_banco_1:		; Aqui continua la instruccion partida que empieza en p01:7FFE.
	add hl,bc			;8001   ; Aqui llega HL desde el banco 1
	ld a,(hl)			;8002
	exx			;8003
	ld c,a			;8004   ; El byte se guarda en el C alternativo
	exx			;8005
	ld de,0e790h		;8006   ; 0xE790 y 0xE7C0: si el jefe ya esta montado, no se vuelve a montar
	ld a,(de)			;8009
	and a			;800a
	jr z,L_8013		;800b
	ld de,0e7c0h		;800d
	ld a,(de)			;8010
	and a			;8011
	ret nz			;8012
L_8013:
	ld hl,08051h		;8013   ; Diez bytes de 0x8051 a la ficha
	ld bc,0000ah		;8016
	ldir		;8019
	ld a,006h		;801b
	call 04062h		;801d
	exx			;8020
	bit 0,c		;8021   ; El bit 0 de C: la primera pieza
	exx			;8023
	push de			;8024
	call nz,L_8038		;8025
	pop de			;8028
	ld a,010h		;8029
	call 04062h		;802b
	exx			;802e
	bit 1,c		;802f   ; Y el bit 1: la segunda
	exx			;8031
	ret z			;8032
	ld hl,08067h		;8033
	jr L_803B		;8036
L_8038:
	ld hl,0805bh		;8038
L_803B:
	ld bc,0000ch		;803b   ; Doce bytes de ficha
	ldir		;803e
	ret			;8040

; ----------------------------------------------------------------------
; DATOS tabla_8041: Cincuenta bytes a los que apunta el `ld hl,0x8041` de la
;   instruccion partida: es lo primero que el codigo carga al entrar en este
;   banco.
;   0x8041..0x8073  (50 bytes)
DATA_tabla_8041:
	defb 002h,001h,001h,002h,003h,002h,001h,003h,003h,003h,003h,003h,003h,003h,003h,003h	; 8041  ................
	defb 003h,000h,000h,040h,000h,0f0h,000h,000h,00ah,07fh,004h,000h,000h,000h,000h,000h	; 8051  ...@............
	defb 021h,018h,006h,010h,006h,006h,004h,000h,000h,000h,000h,000h,016h,014h,006h,010h	; 8061  !...............
	defb 020h,020h	; 8071

; ======================================================================
; CODIGO 0x8073..0x80b0  (61 bytes)
; ======================================================================


corre_los_cinco_de_e7a0:		; Las cinco ranuras de 0xE7A0; solo las del tipo 4 hacen algo
	ld ix,0e7a0h		;8073
	ld b,005h		;8077   ; Cinco ranuras
L_8079:
	push bc			;8079
	ld a,(ix+000h)		;807a
	cp 004h		;807d   ; El tipo 4
	call z,dispara_la_pieza		;807f
	pop bc			;8082
	ld de,00010h		;8083   ; Dieciseis bytes: la ranura siguiente
	add ix,de		;8086
	djnz L_8079		;8088
	ret			;808a
dispara_la_pieza:		; Cada tantos cuadros -menos cuantos mas dificil- suelta un disparo desde donde diga la tabla de 0x80B0
	dec (ix+007h)		;808b
	ret nz			;808e
	ld a,01bh		;808f   ; 0x1B menos la dificultad, partido por dos: los cuadros entre disparos
	ld hl,0e111h		;8091
	sub (hl)			;8094
	sra a		;8095
	ld (ix+007h),a		;8097
	ld a,(ix+006h)		;809a
	ld hl,080b0h		;809d   ; La tabla de 0x80B0: de donde le sale el disparo a cada dibujo
	call 047aeh		;80a0
	ld a,(ix+003h)		;80a3
	add a,e			;80a6
	ld e,a			;80a7
	ld a,(ix+005h)		;80a8
	add a,d			;80ab
	ld d,a			;80ac
	jp 06613h		;80ad   ; Y el banco 1 lo monta

; ----------------------------------------------------------------------
; DATOS tabla_80B0: Ochenta bytes que lee 0x809D.
;   0x80b0..0x8100  (80 bytes)
DATA_tabla_80B0:
	defb 0f8h,004h,0f8h,00eh,0f8h,00eh,0fch,010h,0fah,018h,002h,028h,003h,028h,000h,028h	; 80b0  ...........(.(.(
	defb 000h,030h,008h,030h,029h,006h,029h,00dh,029h,00dh,024h,00fh,01eh,018h,00eh,028h	; 80c0  .0.0).).).$....(
	defb 006h,028h,000h,028h,000h,030h,0f8h,030h,029h,009h,029h,002h,029h,002h,024h,000h	; 80d0  .(.(.0.0).).).$.
	defb 01eh,000h,00eh,000h,006h,000h,000h,000h,000h,000h,0f8h,000h,0f8h,00ah,0f8h,002h	; 80e0  ................
	defb 0f8h,002h,0fch,000h,0fch,000h,002h,000h,002h,000h,00ch,000h,000h,000h,008h,000h	; 80f0  ................

; ======================================================================
; CODIGO 0x8100..0x81ad  (173 bytes)
; ======================================================================


corre_las_seis_piezas:		; Las seis ranuras de 0xE790: cada una con su motor segun el tipo
	ld ix,0e790h		;8100
	ld b,006h		;8104   ; Seis ranuras
L_8106:
	push bc			;8106
	call paso_de_la_pieza		;8107
	pop bc			;810a
	ld de,00010h		;810b   ; Dieciseis bytes: la ranura siguiente
	add ix,de		;810e
	djnz L_8106		;8110
	ret			;8112
paso_de_la_pieza:		; Los tipos 3 y mas: el 3 se retira, y los demas giran hacia el dibujo que les toca
	ld a,(ix+000h)		;8113
	sub 003h		;8116   ; Por debajo del tipo 3 no hace nada
	ret m			;8118
	jr z,retira_la_pieza		;8119   ; El tipo 3 se retira
	dec (ix+008h)		;811b
	ret nz			;811e
	ld a,r		;811f   ; El registro R: de cinco a ocho cuadros por paso
	and 003h		;8121
	add a,005h		;8123
	ld (ix+008h),a		;8125
	ld c,001h		;8128
	ld a,(ix+00ah)		;812a   ; El byte 10 es el dibujo de ahora y el 11 el que quiere alcanzar
	cp (ix+00bh)		;812d
	ret z			;8130
	jr c,L_8135		;8131
	ld c,0ffh		;8133
L_8135:
	add a,c			;8135   ; Un paso hacia el, arriba o abajo
	ld (ix+00ah),a		;8136
	ld hl,081adh		;8139   ; La rampa de 0x81AD: el dibujo de verdad
	call 0405dh		;813c
	ld a,(hl)			;813f
	ld (ix+006h),a		;8140
	ret			;8143
retira_la_pieza:		; Se va subiendo y apartandose de la nave, cambiando de dibujo, hasta salir por arriba
	dec (ix+00ah)		;8144
	bit 4,(ix+00ah)		;8147   ; El bit 4 del contador: alterna el dibujo
	ld c,001h		;814b
	jr nz,L_8150		;814d
	dec c			;814f
L_8150:
	ld a,(ix+001h)		;8150
	cp 002h		;8153   ; Del paso 2 en adelante, sin alternar
	jr c,L_8159		;8155
	ld c,000h		;8157
L_8159:
	add a,a			;8159
	add a,c			;815a
	ld (ix+006h),a		;815b
	dec (ix+008h)		;815e
	ret nz			;8161
	ld (ix+008h),00ah		;8162   ; Diez cuadros por paso
	ld a,(ix+005h)		;8166
	sub 008h		;8169   ; Ocho puntos mas arriba
	cp 010h		;816b   ; Por encima de la Y 0x10 se acaba
	jr c,apaga_la_pieza		;816d
	ld (ix+005h),a		;816f
	ld a,(ix+003h)		;8172
	ld c,a			;8175
	add a,010h		;8176
	ld hl,0e204h		;8178   ; 0xE204: hacia donde esta la nave
	cp (hl)			;817b
	jr nc,L_8191		;817c
	ld a,(ix+020h)		;817e   ; El byte 32 dice hasta donde puede irse
	and a			;8181
	ld b,090h		;8182
	jr z,L_8188		;8184
	ld b,04eh		;8186
L_8188:
	ld a,008h		;8188   ; Ocho a la derecha
	add a,c			;818a   ; Ocho a la derecha
	cp b			;818b   ; Con tope por la derecha
	ret nc			;818c
	ld (ix+003h),a		;818d
	ret			;8190
L_8191:
	ld a,(ix+010h)		;8191
	and a			;8194
	jr z,L_8199		;8195
	ld b,038h		;8197
L_8199:
	ld a,0f8h		;8199   ; U ocho a la izquierda
	add a,c			;819b   ; El byte 16: hasta donde llega
	cp b			;819c   ; Con tope
	ret c			;819d
	ld (ix+003h),a		;819e
	ret			;81a1
apaga_la_pieza:		; La ranura y sus dos marcas, a cero
	xor a			;81a2
	ld (ix+000h),a		;81a3
	ld (ix+010h),a		;81a6
	ld (ix+020h),a		;81a9
	ret			;81ac

; ----------------------------------------------------------------------
; DATOS rampa_81AD: Cuarenta bytes que lee 0x8139: una cuesta abajo (0x27,
;   0x26, 0x25, ...) y detras una cuesta arriba.
;   0x81ad..0x81d5  (40 bytes)
DATA_rampa_81AD:
	defb 027h,026h,025h,024h,023h,022h,021h,020h,01fh,01eh,000h,001h,002h,003h,004h,005h	; 81ad  '&%$#"! ........
	defb 006h,007h,008h,009h,013h,012h,011h,010h,00fh,00eh,00dh,00ch,00bh,00ah,014h,015h	; 81bd  ................
	defb 016h,017h,018h,019h,01ah,01bh,01ch,01dh	; 81cd  ........

; ======================================================================
; CODIGO 0x81d5..0x8250  (123 bytes)
; ======================================================================


apunta_las_dos_torretas:		; Las dos piezas de 0xE790 y 0xE7C0 miran hacia la nave: el angulo elige el dibujo de la torreta
	ld ix,0e790h		;81d5
	call apunta_una_torreta		;81d9
	ld ix,0e7c0h		;81dc
apunta_una_torreta:		; Mide hacia donde esta la nave y, con el angulo, saca de la tabla el dibujo que le toca a cada torreta
	ld a,(ix+000h)		;81e0
	and a			;81e3
	ret z			;81e4
	ld e,(ix+003h)		;81e5   ; La posicion de la pieza
	ld d,(ix+005h)		;81e8
	call 066d5h		;81eb   ; El banco 1 mide el angulo hasta la nave
	call apunta_la_otra		;81ee
	ld a,(ix+020h)		;81f1   ; El byte 32: la segunda torreta
	and a			;81f4
	ret z			;81f5
	bit 6,(ix+00ah)		;81f6   ; El bit 6 del dibujo: si esta girada, no apunta
	jr z,L_8209		;81fa
	ld hl,08250h		;81fc   ; La tabla de 0x8250
	call dibujo_del_angulo		;81ff   ; El dibujo de la torreta
	ld (ix+02bh),c		;8202   ; Se guarda el dibujo
	call esta_en_angulo		;8205
	ret nc			;8208
L_8209:
	ld (ix+02bh),01dh		;8209
	ret			;820d
apunta_la_otra:		; Lo mismo para la torreta del byte 16, con la tabla de 0x8270
	ld a,(ix+010h)		;820e
	and a			;8211
	ret z			;8212
	bit 6,(ix+00ah)		;8213
	jr nz,L_8226		;8217
	ld hl,08270h		;8219   ; La tabla de 0x8270
	call dibujo_del_angulo		;821c
	ld (ix+01bh),c		;821f
	call esta_en_angulo		;8222
	ret nc			;8225
L_8226:
	ld (ix+01bh),00ah		;8226
	ret			;822a
esta_en_angulo:		; Por encima de la Y 0x40, y con el dibujo entre 0x0A y 0x1E, la torreta puede apuntar
	ld a,(ix+005h)		;822b
	cp 040h		;822e   ; Por encima de la Y 0x40 no
	ret nc			;8230
	ld a,c			;8231
	sub 00ah		;8232   ; Y el dibujo tiene que caer entre 0x0A y 0x1E
	cp 014h		;8234
	ccf			;8236
	ret			;8237
dibujo_del_angulo:		; El angulo de 0xEC18 partido por ocho indexa la tabla, y el registro R le suma un pellizco de menos uno a uno
	ld a,(0ec18h)		;8238   ; 0xEC18: el angulo hasta la nave
	rra			;823b   ; Partido por ocho: treinta y dos pasos
	rra			;823c
	rra			;823d
	and 01fh		;823e
	call 0405dh		;8240
	ld a,r		;8243   ; El registro R otra vez: menos uno, cero o uno de temblor
	and 003h		;8245   ; La tabla, indexada por el angulo
	dec a			;8247
	cp 002h		;8248
	jr nz,L_824D		;824a
	xor a			;824c
L_824D:
	add a,(hl)			;824d
	ld c,a			;824e
	ret			;824f

; ----------------------------------------------------------------------
; DATOS dibujos_de_la_torreta_A: Treinta y dos dibujos, uno por cada octavo de
;   angulo: los que ensena la torreta de 0xE7C0 segun hacia donde apunte. Los
;   lee 0x81FC.
;   0x8250..0x8270  (32 bytes)
DATA_dibujos_de_la_torreta_A:
	defb 015h,016h,018h,019h,01ah,01bh,01ch,01ch,01fh,01fh,020h,021h,022h,023h,025h,026h	; 8250  .......... !"#%&
	defb 026h,026h,026h,026h,024h,025h,024h,023h,018h,017h,016h,017h,015h,015h,015h,015h	; 8260  &&&&$%$#........

; ----------------------------------------------------------------------
; DATOS dibujos_de_la_torreta_B: Los otros treinta y dos, los de la torreta
;   del byte 16. Los lee 0x8219.
;   0x8270..0x8290  (32 bytes)
DATA_dibujos_de_la_torreta_B:
	defb 012h,012h,012h,012h,010h,011h,012h,011h,003h,002h,004h,002h,001h,001h,001h,001h	; 8270  ................
	defb 001h,002h,004h,005h,006h,007h,008h,008h,00bh,00bh,00ch,00dh,00eh,00fh,011h,012h	; 8280  ................

; ======================================================================
; CODIGO 0x8290..0x8377  (231 bytes)
; ======================================================================


borra_al_jefe:		; 0xEC00 a cero: lo que sigue borra en vez de pintar
	xor a			;8290
	jr dibuja_las_seis_piezas		;8291
pinta_al_jefe:		; 0xEC00 a uno: lo que sigue pinta
	ld a,001h		;8293
dibuja_las_seis_piezas:		; Con el banco 10 puesto, coloca las torretas y luego dibuja las seis ranuras de 0xE790
	ld (0ec00h),a		;8295
	di			;8298
	ld a,00ah		;8299   ; Banco 10 en 0xA000: ahi estan los dibujos
	ld (0a000h),a		;829b
	ld (0f0f3h),a		;829e
	ei			;82a1
	call coloca_las_torretas		;82a2
	di			;82a5
	ld a,003h		;82a6   ; Devuelto el 3
	ld (0a000h),a		;82a8
	ld (0f0f3h),a		;82ab
	ei			;82ae
	ld ix,0e790h		;82af
	ld b,006h		;82b3   ; Seis ranuras
L_82B5:
	push bc			;82b5
	call dibuja_una_pieza		;82b6
	ld de,00010h		;82b9   ; Dieciseis bytes: la siguiente
	add ix,de		;82bc
	pop bc			;82be
	djnz L_82B5		;82bf
	ret			;82c1
borra_una_pieza:		; 0xEC00 a cero y a borrar
	xor a			;82c2
	ld (0ec00h),a		;82c3
dibuja_una_pieza:		; Saca del banco 10 el ancho, el alto y los caracteres del dibujo, y lo pinta o lo borra
	ld a,(ix+000h)		;82c6
	sub 003h		;82c9   ; Por debajo del tipo 3 no hay nada
	ret m			;82cb
	ld hl,0aaa6h		;82cc   ; El tipo 3 usa la tabla de 0xAAA6; los demas, la de 0xAAB0
	jr z,L_82D4		;82cf
	ld hl,0aab0h		;82d1
L_82D4:
	di			;82d4
	ld a,00ah		;82d5   ; Banco 10 en 0xA000
	ld (0a000h),a		;82d7
	ld (0f0f3h),a		;82da
	ei			;82dd
	ld a,(ix+006h)		;82de
	call 047aeh		;82e1
	ex de,hl			;82e4
	ld b,(hl)			;82e5   ; El ancho y el alto
	inc hl			;82e6
	ld c,(hl)			;82e7
	inc hl			;82e8
	inc hl			;82e9
	ex de,hl			;82ea
	ld l,(ix+003h)		;82eb   ; Donde cae
	ld h,(ix+005h)		;82ee
	ld a,(0ec00h)		;82f1   ; 0xEC00 decide: borrar o pintar
	and a			;82f4
	push af			;82f5
	call z,048f7h		;82f6
	pop af			;82f9
	call nz,0490ch		;82fa
	di			;82fd
	ld a,003h		;82fe   ; Devuelto el 3
	ld (0a000h),a		;8300   ; Devuelto el banco 3
	ld (0f0f3h),a		;8303   ; Devuelto el 3
	ei			;8306
	ret			;8307
coloca_las_torretas:		; A las dos piezas de 0xE790 y 0xE7C0 les calcula donde caen sus dos torretas
	ld ix,0e790h		;8308
	call coloca_las_dos_torretas_de_una		;830c
	ld ix,0e7c0h		;830f
coloca_las_dos_torretas_de_una:		; El ancho del dibujo por ocho da el desplazamiento en X, y la tabla de 0x8377 el de Y
	ld a,(ix+000h)		;8313
	and a			;8316
	ret z			;8317
	ld a,(ix+006h)		;8318
	ld hl,0aaa6h		;831b   ; La tabla de 0xAAA6: el tamano de cada dibujo
	call 047aeh		;831e
	ex de,hl			;8321
	inc hl			;8322
	ld a,(hl)			;8323
	add a,a			;8324   ; El ancho por ocho
	add a,a			;8325
	add a,a			;8326
	ld b,a			;8327
	inc hl			;8328
	ld c,(hl)			;8329
	ld a,(ix+010h)		;832a   ; El byte 16: la primera torreta
	and a			;832d
	call nz,coloca_la_primera_torreta		;832e
	ld a,(ix+020h)		;8331   ; Y el byte 32: la segunda
	and a			;8334
	ret z			;8335
	ld a,(ix+026h)		;8336
	ld hl,08377h		;8339   ; La tabla de 0x8377: cuanto se corre en Y
	call 0405dh		;833c   ; La tabla de 0x8377
	ld a,(hl)			;833f   ; El desplazamiento en Y
	add a,(ix+005h)		;8340
	add a,c			;8343
	ld (ix+025h),a		;8344
	ld a,(ix+003h)		;8347
	add a,b			;834a
	ld (ix+023h),a		;834b
	ret			;834e
coloca_la_primera_torreta:		; Igual, pero restando: esta va al otro lado
	ld hl,0aab0h		;834f   ; La tabla de 0xAAB0
	ld a,(ix+016h)		;8352
	call 047aeh		;8355
	inc de			;8358
	ld a,(de)			;8359
	add a,a			;835a   ; El ancho por ocho
	add a,a			;835b
	add a,a			;835c
	neg		;835d   ; En negativo: la torreta va al otro lado
	add a,(ix+003h)		;835f
	ld (ix+013h),a		;8362
	ld hl,08377h		;8365   ; La tabla de 0x8377
	ld a,(ix+016h)		;8368
	call 0405dh		;836b
	ld a,(hl)			;836e
	add a,(ix+005h)		;836f
	add a,c			;8372
	ld (ix+015h),a		;8373
	ret			;8376

; ----------------------------------------------------------------------
; DATOS desplazamiento_de_la_torreta: Cuarenta bytes, uno por dibujo: cuanto
;   se corre en Y la torreta respecto al centro de la pieza. Los leen 0x8339 y
;   0x8365.
;   0x8377..0x839f  (40 bytes)
DATA_desplazamiento_de_la_torreta:
	defb 0f8h,0f8h,0f8h,000h,000h,000h,000h,000h,000h,000h	; 8377  ..........
	defb 0f8h,0f8h,0f8h,000h,000h,000h,000h,000h,000h,000h	; 8381  ..........
	defb 0f8h,0f8h,0f8h,0f0h,0e8h,0d8h,0d8h,0d8h,0d0h,0d0h	; 838b  ..........
	defb 0f8h,0f8h,0f8h,0f0h,0e8h,0d8h,0d8h,0d8h,0d0h,0d0h	; 8395  ..........

; ======================================================================
; CODIGO 0x839f..0x844d  (174 bytes)
; ======================================================================


corre_y_dibuja_el_jefe:		; Un paso del jefe y su dibujo
	call paso_del_jefe		;839f   ; Un paso y su dibujo
	jp corre_las_ocho_piezas		;83a2
corre_y_dibuja_el_jefe_2:		; Lo mismo con la otra pareja de rutinas
	call arranca_o_acaba_el_jefe		;83a5
	jp corre_una_pieza		;83a8
arranca_o_acaba_el_jefe:		; En el paso 0 monta la primera pieza, y a partir de ahi espera a que 0xE780 se apague
	ld a,(0e190h)		;83ab
	or a			;83ae
	jr nz,L_83C8		;83af
	ld hl,0e780h		;83b1
	call monta_la_ficha_de_la_pieza		;83b4   ; Monta la ficha de la pieza
	ld a,004h		;83b7   ; Tipo 4
	ld (de),a			;83b9
	ld a,e			;83ba
	sub 004h		;83bb
	ld e,a			;83bd
	ld a,0f0h		;83be   ; 0xF0 en la Y
	ld (de),a			;83c0
	dec e			;83c1
	ld a,03ch		;83c2   ; Y 0x3C cuadros
	ld (de),a			;83c4
	jp 07cd4h		;83c5
L_83C8:
	ld hl,0e780h		;83c8
	ld a,(hl)			;83cb   ; Con 0xE780 a cero, el jefe se acabo
	or a			;83cc
	ret nz			;83cd
	jp 07d64h		;83ce
paso_del_jefe:		; En el paso 0 calcula cuanto dura y cada cuantos cuadros suelta pieza, todo desde la dificultad
	ld a,(0e190h)		;83d1
	dec a			;83d4
	jr z,suelta_una_pieza		;83d5
	jp p,mira_si_se_acabo_el_jefe		;83d7
	ld a,(0e111h)		;83da   ; La dificultad mas 0x14...
	add a,014h		;83dd
	ld h,a			;83df
	ld e,01eh		;83e0   ; ...por 0x1E: los cuadros que dura el jefe
	call 06743h		;83e2
	ld (0e153h),hl		;83e5
	ld a,(0e111h)		;83e8   ; Y 0x3C menos dos veces la dificultad: los cuadros entre pieza y pieza
	add a,a			;83eb   ; Los cuadros entre pieza y pieza
	sub 03ch		;83ec
	neg		;83ee
	ld hl,0e156h		;83f0
	ld (hl),a			;83f3
	inc l			;83f4
	ld (hl),a			;83f5
	inc l			;83f6
	ld (hl),000h		;83f7   ; 0xE158 a cero
	ld hl,00000h		;83f9   ; 0xE15B, 0xE15C, 0xE15D y 0xE15E a cero
	ld (0e15bh),hl		;83fc
	ld (0e15dh),hl		;83ff
	jp 07cd4h		;8402
suelta_una_pieza:		; Baja la cuenta larga y, cada tantos cuadros, busca hueco entre las ocho ranuras y monta una pieza
	ld hl,(0e153h)		;8405   ; 0xE153: los cuadros que le quedan al jefe
	dec hl			;8408
	ld a,h			;8409
	or l			;840a
	jp z,07cd4h		;840b
	ld (0e153h),hl		;840e
	ld hl,0e156h		;8411   ; 0xE156: los cuadros hasta la pieza siguiente
	dec (hl)			;8414
	ret nz			;8415
	inc l			;8416
	ld a,(hl)			;8417
	dec l			;8418
	ld (hl),a			;8419
	ld b,008h		;841a   ; Ocho ranuras
	call hay_alguna_libre		;841c
	ret nz			;841f
	push hl			;8420
	call elige_altura_de_la_pieza		;8421
	pop hl			;8424
	ret c			;8425
monta_la_ficha_de_la_pieza:		; Copia los once bytes de 0x844D y le pone la Y que diga la tabla de 0x8458
	ld de,0844dh		;8426   ; Los once bytes de 0x844D
	ex de,hl			;8429
	ldi		;842a
	ldi		;842c
	ldi		;842e
	ld a,(0e159h)		;8430   ; 0xE159: cual de las cuatro alturas
	exx			;8433
	ld b,a			;8434
	ld hl,08458h		;8435   ; La tabla de 0x8458: las cuatro alturas
	add a,l			;8438
	ld l,a			;8439
	jr nc,L_843D		;843a
	inc h			;843c
L_843D:
	ld a,(hl)			;843d   ; Ocho bytes mas de ficha
	exx			;843e
	ld (de),a			;843f
	inc e			;8440
	ld bc,00008h		;8441   ; Ocho bytes mas de ficha
	ldir		;8444   ; Ocho bytes mas
	inc e			;8446
	inc e			;8447
	exx			;8448
	ld a,b			;8449
	exx			;844a
	ld (de),a			;844b
	ret			;844c

; ----------------------------------------------------------------------
; DATOS ficha_de_la_pieza: Los once bytes de arranque de una pieza del jefe,
;   que 0x8426 copia tal cual a la ranura libre.
;   0x844d..0x8458  (11 bytes)
DATA_ficha_de_la_pieza:
	defb 002h,000h,000h,000h,0f8h,000h,000h,001h,028h,01eh,000h	; 844d  ........(..

; ----------------------------------------------------------------------
; DATOS alturas_de_la_pieza: Las cuatro alturas por las que puede salir una
;   pieza del jefe: 0x08, 0x34, 0x60 y 0x8C. Las lee 0x8435 con (0xE159).
;   0x8458..0x845c  (4 bytes)
DATA_alturas_de_la_pieza:
	defb 008h,034h,060h,08ch	; 8458

; ======================================================================
; CODIGO 0x845c..0x857b  (287 bytes)
; ======================================================================


mira_si_se_acabo_el_jefe:		; Cuando no queda ninguna pieza viva ni ninguna explosion, el jefe se da por muerto
	ld b,008h		;845c   ; Ocho ranuras de pieza
	call hay_alguna_viva		;845e
	ret nz			;8461
	call hay_alguna_explosion		;8462
	ret nz			;8465
	jp 07d64h		;8466
elige_altura_de_la_pieza:		; El registro R elige una de las cuatro alturas, saltandose la de la vez anterior y las que ya tengan dos piezas
	ld a,(0e158h)		;8469   ; 0xE158: la altura de la vez anterior
	ld c,a			;846c
	ld d,004h		;846d   ; Cuatro intentos
	ld a,r		;846f   ; El registro R: una de las cuatro alturas
L_8471:
	and 003h		;8471
	ld b,a			;8473
	cp c			;8474   ; La misma que la anterior, no
	jr z,L_8481		;8475
	ld hl,0e15bh		;8477   ; 0xE15B: cuantas piezas hay ya en esa altura
	add a,l			;847a
	ld l,a			;847b
	ld a,(hl)			;847c
	cp 002h		;847d   ; Dos por altura como mucho
	jr c,L_8488		;847f
L_8481:
	scf			;8481   ; Se apunta la altura elegida
	dec d			;8482
	ret z			;8483
	ld a,b			;8484
	inc a			;8485
	jr L_8471		;8486
L_8488:
	inc (hl)			;8488   ; Se apunta la altura elegida
	ld a,b			;8489
	ld (0e159h),a		;848a
	ld (0e158h),a		;848d
	xor a			;8490
	ret			;8491
hay_alguna_libre:		; Devuelve en HL la primera ranura de pieza que este libre
	ld hl,0e780h		;8492
	ld de,00010h		;8495
L_8498:
	ld a,(hl)			;8498   ; Con el primer byte a cero, la ranura esta libre
	or a			;8499
	ret z			;849a
	add hl,de			;849b
	djnz L_8498		;849c
	ret			;849e
hay_alguna_viva:		; Sale con NZ si queda alguna pieza viva
	ld hl,0e780h		;849f
	ld de,00010h		;84a2
L_84A5:
	ld a,(hl)			;84a5   ; Con el primer byte distinto de cero, queda alguna viva
	or a			;84a6
	ret nz			;84a7
	add hl,de			;84a8
	djnz L_84A5		;84a9
	ret			;84ab
hay_alguna_explosion:		; Y lo mismo con las cuatro ranuras de explosion de 0xE800
	ld hl,0e800h		;84ac
	ld de,00008h		;84af
	ld b,004h		;84b2   ; Cuatro
L_84B4:
	ld a,(hl)			;84b4   ; Con el primer byte distinto de cero, queda alguna explosion
	or a			;84b5
	ret nz			;84b6
	add hl,de			;84b7
	djnz L_84B4		;84b8
	ret			;84ba
corre_una_pieza:		; Una sola
	ld a,001h		;84bb
	jp L_84C2		;84bd
corre_las_ocho_piezas:		; Las ocho ranuras de 0xE780
	ld a,008h		;84c0   ; Ocho ranuras
L_84C2:
	ld (0e159h),a		;84c2
	ld ix,0e780h		;84c5
L_84C9:
	call paso_de_una_pieza		;84c9
	ld de,00010h		;84cc   ; Dieciseis bytes: la siguiente
	add ix,de		;84cf   ; Dieciseis bytes: la siguiente
	ld hl,0e159h		;84d1   ; 0xE159 cuenta las ranuras
	dec (hl)			;84d4
	jp nz,L_84C9		;84d5
	ret			;84d8
paso_de_una_pieza:		; Segun el byte 1: entrando, andando, o ya dentro; el byte 14 en 4 la manda por otro camino
	ld a,(ix+000h)		;84d9
	or a			;84dc
	ret z			;84dd
	ld a,(ix+001h)		;84de
	dec a			;84e1   ; El paso 1 es el de andar
	jp z,anda_la_pieza		;84e2
	jp p,L_8515		;84e5
	call corre_la_pieza_un_punto		;84e8   ; Y el 0: entrando por el borde
	cp 0e1h		;84eb   ; Hasta pasar la X 0xE1, sigue entrando
	ret nc			;84ed
paso_siguiente_de_la_pieza:		; El byte 1 sube
	inc (ix+001h)		;84ee
	ret			;84f1
anda_la_pieza:		; Baja el contador del byte 10; al agotarse, apaga el dibujo y pasa al paso siguiente
	dec (ix+00ah)		;84f2
	jp nz,L_84FF		;84f5
	ld (ix+006h),000h		;84f8
	jp paso_siguiente_de_la_pieza		;84fc
L_84FF:
	call la_pieza_dispara		;84ff   ; Se mueve, se acerca y dispara
	ld a,(ix+00eh)		;8502
	cp 004h		;8505   ; El byte 14 en 4 lleva otro motor
	jr z,L_850F		;8507   ; El byte 14 en 4 lleva otro motor
	call persigue_la_fila_de_la_nave		;8509   ; Se mueve y dispara
	jp persigue_la_columna_de_la_nave		;850c
L_850F:
	call persigue_deprisa_la_fila		;850f
	jp persigue_deprisa_la_columna		;8512
L_8515:
	ld a,(ix+00eh)		;8515
	cp 004h		;8518
	jp z,L_8629		;851a
	call corre_la_pieza_un_punto		;851d
	ret nc			;8520
libera_la_altura:		; La pieza se apaga y su altura vuelve a quedar libre en 0xE15B
	ld a,(ix+00eh)		;8521   ; El byte 14 dice de que altura era
	ld hl,0e15bh		;8524
	add a,l			;8527
	ld l,a			;8528
	dec (hl)			;8529
	ld (ix+000h),000h		;852a
	ret			;852e
persigue_la_fila_de_la_nave:		; Cada ocho cuadros se acerca a la FILA de la nave, sin salirse de la banda que le toca por altura; a menos de 0x11 se queda quieta
	ld a,(ix+00ah)		;852f   ; Uno de cada ocho cuadros
	and 007h		;8532
	ret nz			;8534
	ld a,(0e204h)		;8535   ; 0xE204, la fila de la nave, menos la suya
	sub (ix+003h)		;8538
	push af			;853b
	add a,008h		;853c
	cp 011h		;853e   ; A menos de 0x11 ya esta a su altura
	jp c,L_8579		;8540
	pop af			;8543
	jp c,L_8560		;8544
	ld de,00200h		;8547   ; Dos puntos hacia abajo
	call suma_de_a_la_fila		;854a
	ld b,a			;854d
	ld a,(ix+00eh)		;854e
	ld hl,0857bh		;8551   ; La tabla de 0x857B: el suelo de su banda
	add a,l			;8554   ; El byte 14 dice en que banda va
	ld l,a			;8555   ; Con tope
	jr nc,L_8559		;8556
	inc h			;8558
L_8559:
	ld a,(hl)			;8559
	cp b			;855a
	ret nc			;855b
	ld (ix+003h),a		;855c
	ret			;855f
L_8560:
	ld de,0fe00h		;8560   ; O dos puntos hacia arriba
	call suma_de_a_la_fila		;8563
	ld b,a			;8566
	ld a,(ix+00eh)		;8567
	ld hl,0857fh		;856a   ; Y la de 0x857F: el techo de su banda
	add a,l			;856d   ; El techo de su banda
	ld l,a			;856e   ; Con tope
	jr nc,L_8572		;856f
	inc h			;8571
L_8572:
	ld a,(hl)			;8572
	cp b			;8573
	ret c			;8574
	ld (ix+003h),a		;8575
	ret			;8578
L_8579:
	pop af			;8579
	ret			;857a

; ----------------------------------------------------------------------
; DATOS suelo_de_la_banda: Hasta que fila puede bajar la pieza, una por banda:
;   0x0B, 0x37, 0x63 y 0x8F. Los lee 0x8551. Con los cuatro techos de 0x857F
;   salen cuatro carriles de once puntos separados 0x2C.
;   0x857b..0x857f  (4 bytes)
DATA_suelo_de_la_banda:
	defb 00bh,037h,063h,08fh	; 857b

; ----------------------------------------------------------------------
; DATOS techo_de_la_banda: Los cuatro techos: 0x00, 0x2C, 0x58 y 0x84. Los lee
;   0x856A.
;   0x857f..0x8583  (4 bytes)
DATA_techo_de_la_banda:
	defb 000h,02ch,058h,084h	; 857f

; ======================================================================
; CODIGO 0x8583..0x86f1  (366 bytes)
; ======================================================================


persigue_la_columna_de_la_nave:		; Cada cuatro cuadros se acerca a la COLUMNA de la nave; el margen sale de la dificultad, y al salirse por la izquierda la pieza se va
	ld a,(ix+00ah)		;8583   ; Uno de cada cuatro cuadros
	and 003h		;8586
	dec a			;8588
	ret nz			;8589
	ld a,(0e111h)		;858a   ; La dificultad por cuatro, restada de 0x60: cuanto se queda por delante
	add a,a			;858d   ; La columna de la pieza, menos ese margen
	add a,a			;858e   ; 0xE206 es la columna de la nave
	sub 060h		;858f
	neg		;8591
	ld b,a			;8593
	ld a,(ix+005h)		;8594
	sub b			;8597
	jp nc,L_859D		;8598
	neg		;859b
L_859D:
	ld c,a			;859d
	ld a,(0e206h)		;859e
	sub c			;85a1
	push af			;85a2
	add a,008h		;85a3
	cp 011h		;85a5   ; A menos de 0x11 ya esta en su columna
	jp c,L_8579		;85a7
	pop af			;85aa
	jp c,L_85BC		;85ab
	ld de,0fe00h		;85ae   ; Dos puntos a la derecha
	call resta_de_a_la_columna		;85b1
	cp 0f0h		;85b4   ; Con tope en la columna 0xF0
	ret c			;85b6
	ld (ix+005h),0f0h		;85b7
	ret			;85bb
L_85BC:
	ld de,00200h		;85bc   ; O dos a la izquierda, y al salirse por ese borde la pieza se va
	call resta_de_a_la_columna		;85bf
	ret nc			;85c2
	jp libera_la_altura		;85c3
persigue_deprisa_la_fila:		; Igual pero cada dos cuadros y de cuatro en cuatro puntos, entre las filas 0x00 y 0x90
	bit 0,(ix+00ah)		;85c6   ; Uno de cada dos cuadros
	ret nz			;85ca   ; La fila de la nave
	ld a,(0e204h)		;85cb   ; 0xE204: la fila de la nave
	sub (ix+003h)		;85ce
	push af			;85d1
	add a,008h		;85d2
	cp 011h		;85d4
	jp c,L_8579		;85d6
	pop af			;85d9
	jp c,L_85EC		;85da
	ld de,00400h		;85dd   ; Cuatro puntos hacia abajo
	call suma_de_a_la_fila		;85e0
	ld b,a			;85e3
	ld a,090h		;85e4   ; Con tope en la fila 0x90
	cp b			;85e6
	ret nc			;85e7
	ld (ix+003h),a		;85e8
	ret			;85eb
L_85EC:
	ld de,0fc00h		;85ec   ; O cuatro hacia arriba, con tope en la fila 0
	call suma_de_a_la_fila		;85ef
	ld b,a			;85f2
	ld a,000h		;85f3
	cp b			;85f5
	ret c			;85f6
	ld (ix+003h),a		;85f7
	ret			;85fa
persigue_deprisa_la_columna:		; Cada dos cuadros se acerca a la columna de la nave de cuatro en cuatro, quedandose 0x40 por delante
	bit 0,(ix+00ah)		;85fb   ; Uno de cada dos cuadros
	ret z			;85ff
	ld a,(ix+005h)		;8600
	sub 040h		;8603   ; 0x40 por delante de la nave
	jp nc,L_860A		;8605
	neg		;8608
L_860A:
	ld c,a			;860a
	ld a,(0e206h)		;860b
	sub c			;860e
	push af			;860f
	add a,008h		;8610
	cp 011h		;8612   ; A menos de 0x11 ya esta en su columna
	jp c,L_8579		;8614
	pop af			;8617
	jp c,L_8629		;8618
	ld de,0fc00h		;861b   ; Cuatro puntos a la derecha
	call resta_de_a_la_columna		;861e
	cp 0f0h		;8621
	ret c			;8623
	ld (ix+005h),0f0h		;8624
	ret			;8628
L_8629:
	ld de,00400h		;8629   ; O cuatro a la izquierda, y al salirse se va
	call resta_de_a_la_columna		;862c
	ret nc			;862f
	jp libera_la_altura		;8630
suma_de_a_la_fila:		; Suma DE a la palabra de 16 bits de (IX+2, IX+3): la fila de la pieza, con su parte decimal.
	ld a,(ix+002h)		;8633   ; El byte bajo...
	add a,e			;8636
	ld (ix+002h),a		;8637
	ld a,(ix+003h)		;863a   ; ...y el alto con el acarreo
	adc a,d			;863d
	ld (ix+003h),a		;863e
	ret			;8641
corre_la_pieza_un_punto:		; Entra a 0x8645 con DE = 0x0100: un punto a la izquierda.
	ld de,00100h		;8642
resta_de_a_la_columna:		; Resta DE a la palabra de 16 bits de (IX+4, IX+5): la columna de la pieza, con su parte decimal.
	ld a,(ix+004h)		;8645   ; El byte bajo...
	sub e			;8648
	ld (ix+004h),a		;8649
	ld a,(ix+005h)		;864c   ; ...y el alto con el acarreo
	sbc a,d			;864f
	ld (ix+005h),a		;8650
	ret			;8653
la_pieza_dispara:		; Cada tantos cuadros -menos cuantos mas dificil- suelta tres disparos del tipo 0x0B, si caben en la pantalla
	ld a,(ix+007h)		;8654
	dec a			;8657   ; El byte 7 es el paso del disparo
	jr z,L_8674		;8658
	jp p,L_8681		;865a
	dec (ix+008h)		;865d
	ret nz			;8660
	ld a,(0e126h)		;8661   ; Con diez objetos o mas en pantalla no dispara
	cp 00ah		;8664
	jr nc,L_868C		;8666
	ld (ix+00bh),00ah		;8668   ; Diez cuadros de aviso
	ld (ix+006h),001h		;866c
paso_siguiente_del_disparo:		; El byte 7 sube
	inc (ix+007h)		;8670
	ret			;8673
L_8674:
	dec (ix+00bh)		;8674   ; Los diez cuadros, y entonces dispara
	ret nz			;8677
	ld (ix+00bh),00ah		;8678
	call suelta_tres_disparos		;867c
	jr paso_siguiente_del_disparo		;867f
L_8681:
	dec (ix+00bh)		;8681   ; Y otros diez para volver al dibujo de siempre
	ret nz			;8684
	xor a			;8685
	ld (ix+006h),a		;8686
	ld (ix+007h),a		;8689
L_868C:
	ld a,(0e111h)		;868c   ; 0x22 menos dos veces la dificultad: los cuadros hasta la tanda siguiente
	add a,a			;868f
	sub 022h		;8690
	neg		;8692
	ld (ix+008h),a		;8694
	ret			;8697
suelta_tres_disparos:		; Tres del tipo 0x0B, uno detras de otro
	ld a,003h		;8698   ; Tres
	ld (0e15ah),a		;869a
L_869D:
	call suelta_uno		;869d
	ld hl,0e15ah		;86a0
	dec (hl)			;86a3
	jr nz,L_869D		;86a4
	ret			;86a6
suelta_uno:		; Sale ocho a la derecha y ocho por encima de la pieza
	ld a,(ix+003h)		;86a7   ; Ocho a la derecha
	add a,008h		;86aa
	ld e,a			;86ac
	ld a,(ix+005h)		;86ad   ; Y ocho por encima
	sub 008h		;86b0
	ret c			;86b2
	ld d,a			;86b3
	ld c,000h		;86b4
	ld a,00bh		;86b6   ; Tipo 0x0B
	push ix		;86b8
	call 06a72h		;86ba
	pop ix		;86bd
	ret			;86bf
dibuja_una_pieza_sola:
	ld hl,0e780h		;86c0
	jp dibuja_la_pieza		;86c3
dibuja_las_ocho_piezas:		; Las ocho ranuras de 0xE780
	ld b,008h		;86c6   ; Ocho ranuras
	ld hl,0e780h		;86c8
L_86CB:
	push bc			;86cb
	push hl			;86cc
	call dibuja_la_pieza		;86cd
	pop hl			;86d0
	ld de,00010h		;86d1   ; Dieciseis bytes: la siguiente
	add hl,de			;86d4   ; El bit 0 del byte 1
	pop bc			;86d5   ; Con el primer byte a cero, no hay pieza
	djnz L_86CB		;86d6
	ret			;86d8
dibuja_la_pieza:		; Cuatro por cuatro caracteres, con uno de los dos dibujos de 0x86F1 y 0x8701 segun el byte 1
	ld a,(hl)			;86d9
	or a			;86da
	ret z			;86db
	call posicion_de_la_ficha		;86dc
	inc l			;86df
	ld a,(hl)			;86e0
	or a			;86e1
	ld hl,086f1h		;86e2   ; El byte 1 elige entre los dos dibujos
	jr z,L_86EA		;86e5
	ld hl,08701h		;86e7
L_86EA:
	ex de,hl			;86ea
	ld bc,00404h		;86eb   ; Cuatro por cuatro caracteres
	jp 0490ch		;86ee

; ----------------------------------------------------------------------
; DATOS caracteres_86F1: Dieciseis caracteres que lee 0x86E2.
;   0x86f1..0x8701  (16 bytes)
DATA_caracteres_86F1:
	defb 0a6h,0a7h,0a8h,0a9h	; 86f1
	defb 0aah,0abh,0ach,0adh	; 86f5
	defb 0b6h,0b7h,0b8h,0b9h	; 86f9
	defb 0b2h,0b3h,0b4h,0b5h	; 86fd

; ----------------------------------------------------------------------
; DATOS caracteres_8701: Dieciseis caracteres que lee 0x86E7.
;   0x8701..0x8711  (16 bytes)
DATA_caracteres_8701:
	defb 0aeh,0a7h,0a8h,0a9h	; 8701
	defb 0afh,0abh,0ach,0adh	; 8705
	defb 0bbh,0b7h,0b8h,0b9h	; 8709
	defb 0bah,0b3h,0b4h,0b5h	; 870d

; ======================================================================
; CODIGO 0x8711..0x8724  (19 bytes)
; ======================================================================


posicion_de_la_ficha:		; Saca de la ficha la X y la Y
	inc l			;8711   ; Los bytes 3 y 5
	inc l			;8712
	inc l			;8713
	ld e,(hl)			;8714
	inc l			;8715
	inc l			;8716
	ld d,(hl)			;8717
	ret			;8718
despacha_el_paso_del_jefe_3:		; Cuatro pasos, contados en 0xE190
	ld a,(0e1c0h)		;8719   ; Con la pantalla parada, no
	and a			;871c
	ret nz			;871d
	ld a,(0e190h)		;871e
	call 04067h		;8721

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_8721: Cuatro palabras pegadas detras del `call
;   0x4067` de 0x8721.
;   0x8724..0x872c  (8 bytes)
DATA_tabla_del_despachador_8721:
	defw 0872ch,08752h	; 8724  -> monta_este_jefe este_jefe_dispara
	defw 087d9h,087e5h	; 8728  -> espera_a_que_se_vaya espera_al_banco_10

; ======================================================================
; CODIGO 0x872c..0x8748  (28 bytes)
; ======================================================================


monta_este_jefe:		; 0x258 cuadros, los diez bytes de 0x8748 a la ranura y dos caracteres en la pantalla
	ld hl,00258h		;872c   ; 0x258 cuadros
	ld (0e153h),hl		;872f
	ld hl,08748h		;8732   ; Los diez bytes de arranque
	ld de,0e780h		;8735   ; Los diez bytes de arranque
	ld bc,0000ah		;8738
	ldir		;873b
	ld de,03e3fh		;873d
	call escribe_dos_caracteres		;8740
paso_siguiente_de_este_jefe:		; 0xE190 + 1
	ld hl,0e190h		;8743
	inc (hl)			;8746
	ret			;8747

; ----------------------------------------------------------------------
; DATOS tabla_8748: Diez bytes que lee 0x8732.
;   0x8748..0x8752  (10 bytes)
DATA_tabla_8748:
	defb 005h,000h,000h,050h,000h,0b7h,000h,000h,000h,040h	; 8748  ...P.....@

; ======================================================================
; CODIGO 0x8752..0x87af  (93 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL JEFE QUE ESCUPE DISPAROS: OTRA VEZ EL REGISTRO R
; Este jefe suelta un disparo cada dos cuadros mientras le dura la cuenta,
; y la direccion NO se calcula: se saca de la tabla de 0x87AF, dieciseis
; parejas de velocidad, con el indice puesto por cinco bits del registro R.
; Ademas, un bit del contador de cuadros le da la vuelta al signo, asi que
; el abanico sale a los dos lados.
; ----------------------------------------------------------------------
este_jefe_dispara:		; Cada dos cuadros suelta un disparo del tipo 0x10 con una de las dieciseis velocidades de 0x87AF
	ld a,(0e789h)		;8752   ; 0xE789: hasta que no este montado, no dispara
	and a			;8755
	jr z,cobra_el_jefe		;8756
	ld hl,(0e153h)		;8758   ; 0xE153: los cuadros que le quedan
	dec hl			;875b
	ld (0e153h),hl		;875c
	ld a,l			;875f
	or h			;8760
	jr z,se_acaba_la_cuenta		;8761
	ld a,(0e003h)		;8763
	ld c,a			;8766
	rra			;8767   ; Uno de cada dos cuadros
	ret c			;8768
	ld a,r		;8769   ; El registro R: una de las dieciseis parejas
	and 01eh		;876b
	ld hl,087afh		;876d
	call 0405dh		;8770
	ld e,(hl)			;8773
	inc hl			;8774
	ld d,(hl)			;8775
	ld hl,0a440h		;8776
	bit 1,c		;8779   ; Y un bit del contador le da la vuelta
	jr z,L_8782		;877b
	ld l,06fh		;877d
	call 06729h		;877f
L_8782:
	ex de,hl			;8782
	ld (0ec12h),hl		;8783   ; 0xEC12: la velocidad vertical
	ld hl,0f900h		;8786   ; Y 0xF900 en Y
	ld (0ec14h),hl		;8789
	ld a,010h		;878c   ; Tipo 0x10
	ld c,000h		;878e
	jp 06a72h		;8790
cobra_el_jefe:		; Cien puntos y cambia los dos caracteres
	ld de,00100h		;8793   ; Cien puntos
	call 055b4h		;8796
	ld de,05f60h		;8799
	jr L_87A1		;879c
se_acaba_la_cuenta:		; Cambia los caracteres y deja 0x5A cuadros
	ld de,04041h		;879e
L_87A1:
	call escribe_dos_caracteres		;87a1
	ld a,05ah		;87a4
	ld (0e153h),a		;87a6   ; 0x5A cuadros
	xor a			;87a9
	ld (0e1c1h),a		;87aa
	jr $-106		;87ad

; ----------------------------------------------------------------------
; DATOS velocidades_del_abanico: Dieciseis parejas de velocidad de 16 bits que
;   0x876D indexa con cinco bits del registro R: las direcciones con las que
;   este jefe escupe disparos.
;   0x87af..0x87cf  (32 bytes)
DATA_velocidades_del_abanico:
	defw 00100h,00280h	; 87af
	defw 00200h,00500h	; 87b3
	defw 00340h,00400h	; 87b7
	defw 00380h,001a0h	; 87bb
	defw 00580h,00240h	; 87bf
	defw 00300h,00480h	; 87c3
	defw 00600h,00180h	; 87c7
	defw 00160h,001a0h	; 87cb

; ======================================================================
; CODIGO 0x87cf..0x87f9  (42 bytes)
; ======================================================================


escribe_dos_caracteres:		; Deja D y E en dos casillas del mapa, una encima de la otra
	ld hl,0ee5bh		;87cf   ; Dos casillas del mapa, una encima de la otra
	ld (hl),d			;87d2
	ld bc,00020h		;87d3   ; 0x20: la fila de abajo
	add hl,bc			;87d6
	ld (hl),e			;87d7
	ret			;87d8
espera_a_que_se_vaya:		; Al agotarse la cuenta, apaga 0xE1A0 y pasa al paso siguiente
	ld hl,0e153h		;87d9   ; 0xE153: los cuadros que faltan
	dec (hl)			;87dc
	ret nz			;87dd
	xor a			;87de
	ld (0e1a0h),a		;87df   ; 0xE1A0 a cero
	jp z,paso_siguiente_de_este_jefe		;87e2
espera_al_banco_10:		; Llama al banco 3 y, cuando 0xE1A3 se pone, da el jefe por muerto
	call 0a6c0h		;87e5   ; El banco 3 monta el final
	ld a,(0e1a3h)		;87e8   ; 0xE1A3: hasta que no se ponga, no
	and a			;87eb
	ret z			;87ec
	ld a,001h		;87ed
	ld (0e150h),a		;87ef
	ret			;87f2
despacha_el_paso_del_jefe_4:		; Seis pasos, contados en 0xE190
	ld a,(0e190h)		;87f3
	call 04067h		;87f6

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_87F6: Seis palabras pegadas detras del `call
;   0x4067` de 0x87F6.
;   0x87f9..0x8805  (12 bytes)
DATA_tabla_del_despachador_87F6:
	defw 08805h,0882fh	; 87f9  -> monta_las_dos_piezas espera_a_la_distancia_178
	defw 08852h,0887eh	; 87fd  -> espera_a_que_la_nave_suba arranca_la_cuenta_larga
	defw 0888dh,088b8h	; 8801  -> suelta_lo_del_guion espera_al_banco_3

; ======================================================================
; CODIGO 0x8805..0x8812  (13 bytes)
; ======================================================================


monta_las_dos_piezas:		; Los 0x1D bytes de 0x8812 a 0xE780: las fichas de arranque de dos piezas seguidas
	ld de,0e780h		;8805
	ld hl,08812h		;8808
	ld bc,0001dh		;880b
	ldir		;880e
	jr $+120		;8810

; ----------------------------------------------------------------------
; DATOS tabla_8812: Veintinueve bytes que lee 0x8808.
;   0x8812..0x882f  (29 bytes)
DATA_tabla_8812:
	defb 007h,000h,000h,078h,000h,0f8h,000h,010h,010h,020h,000h,000h,000h,000h,000h,000h	; 8812  ...x..... ......
	defb 007h,001h,000h,020h,000h,0f8h,000h,010h,018h,020h,007h,007h,000h	; 8822  ... ..... ...

; ======================================================================
; CODIGO 0x882f..0x884d  (30 bytes)
; ======================================================================


espera_a_la_distancia_178:		; Pasada la distancia 0x178, deja 0x1E0 cuadros y monta la ficha de 0x884D en 0xE9A0
	call corre_las_dos_piezas		;882f
	ld hl,(0e063h)		;8832
	ld de,00178h		;8835   ; La distancia 0x178
	rst 20h			;8838
	ret c			;8839
	ld hl,001e0h		;883a   ; 0x1E0 cuadros
	ld (0e153h),hl		;883d
	ld hl,0884dh		;8840   ; Los cinco bytes de arranque
	ld de,0e9a0h		;8843
	ld bc,00005h		;8846
	ldir		;8849
	jr $+61		;884b

; ----------------------------------------------------------------------
; DATOS tabla_884D: Cinco bytes que lee 0x8840.
;   0x884d..0x8852  (5 bytes)
DATA_tabla_884D:
	defb 001h,038h,0f8h,020h,000h	; 884d

; ======================================================================
; CODIGO 0x8852..0x88f8  (166 bytes)
; ======================================================================


espera_a_que_la_nave_suba:		; Sigue hasta que se acaba la cuenta, o hasta que la nave pasa de la Y 0xC8, y entonces suelta el limite
	call corre_las_dos_piezas		;8852
	ld hl,(0e153h)		;8855   ; 0xE153: los cuadros que quedan
	dec hl			;8858
	ld (0e153h),hl		;8859
	ld a,l			;885c
	or h			;885d
	jr z,L_886C		;885e
	ld a,(0e206h)		;8860   ; O que la nave pase de la columna 0xC8
	cp 0c8h		;8863
	jr nc,L_886C		;8865
	ld a,(0e10ah)		;8867   ; O que el submodo se ponga
	and a			;886a
	ret z			;886b
L_886C:
	ld hl,0e9a0h		;886c   ; 0xE9A0 pasa al paso 2
	ld a,(hl)			;886f
	cp 002h		;8870
	jr nc,L_8876		;8872
	ld (hl),002h		;8874
L_8876:
	ld hl,0019fh		;8876   ; El desplazamiento llega hasta 0x19F
	ld (0e105h),hl		;8879   ; El desplazamiento hasta 0x19F
	jr paso_siguiente_del_jefe		;887c   ; Al paso siguiente
arranca_la_cuenta_larga:		; 0xEC1B a cero y otros 0x1E0 cuadros
	xor a			;887e
	ld (0ec1bh),a		;887f
	ld hl,001e0h		;8882
	ld (0e153h),hl		;8885
paso_siguiente_del_jefe:		; 0xE190 + 1
	ld hl,0e190h		;8888
	inc (hl)			;888b
	ret			;888c
suelta_lo_del_guion:		; En los pasos con columna nueva mira el guion de 0x88F8 y, al agotarse todo, apaga el aviso
	call corre_las_dos_piezas		;888d
	ld a,(0e100h)		;8890   ; Solo en los pasos con columna
	and a			;8893
	call nz,mira_el_guion_del_jefe		;8894
	ld a,(0e107h)		;8897   ; Y solo en los pasos con columna nueva
	and a			;889a
	ret z			;889b
	ld a,(0e126h)		;889c   ; 0xE126: si no queda ningun objeto vivo, se acaba ya
	and a			;889f   ; Sin objetos vivos, se acaba ya
	jr z,acaba_este_jefe		;88a0
	ld hl,(0e153h)		;88a2
	dec hl			;88a5
	ld (0e153h),hl		;88a6
	ld a,h			;88a9
	or l			;88aa
	ret nz			;88ab
acaba_este_jefe:		; 0xE1A0 a cero y 0xE114 a uno
	ld a,03bh		;88ac   ; 0xE1A0 a cero y 0xE114 a uno
	xor a			;88ae
	ld (0e1a0h),a		;88af
	inc a			;88b2
	ld (0e114h),a		;88b3
	jr paso_siguiente_del_jefe		;88b6
espera_al_banco_3:		; Cuando 0xE1A3 se pone, borra los 0x180 bytes de objetos y da el jefe por muerto
	call 0a6c0h		;88b8   ; El banco 3 monta el final
	ld a,(0e1a3h)		;88bb
	and a			;88be
	ret z			;88bf
	ld hl,0e300h		;88c0   ; Los 0x180 bytes de objetos, a cero
	ld de,0e301h		;88c3
	ld bc,0017fh		;88c6
	ld (hl),000h		;88c9
	ldir		;88cb
	ld a,001h		;88cd   ; 0xE150 a uno: el jefe se acabo
	ld (0e150h),a		;88cf
	ret			;88d2
mira_el_guion_del_jefe:		; Recorre la tabla de tres en tres buscando la distancia exacta; cuando cuadra, suelta un objeto del tipo 0x11
	ld hl,088f8h		;88d3
	ld a,(0e063h)		;88d6   ; La distancia recorrida
L_88D9:
	cp (hl)			;88d9
	call z,L_88E3		;88da
	ret c			;88dd
	inc hl			;88de   ; Tres bytes por renglon
	inc hl			;88df
	inc hl			;88e0
	jr L_88D9		;88e1
L_88E3:
	push af			;88e3
	push hl			;88e4
	inc hl			;88e5
	ld e,(hl)			;88e6   ; La X y el dibujo
	inc hl			;88e7
	ld a,(hl)			;88e8
	ld (0ec1bh),a		;88e9
	ld d,0f8h		;88ec   ; Sale por la Y 0xF8
	ld c,000h		;88ee
	ld a,011h		;88f0   ; Tipo 0x11
	call 06a72h		;88f2
	pop hl			;88f5
	pop af			;88f6
	ret			;88f7

; ----------------------------------------------------------------------
; DATOS tabla_88F8: Diecinueve bytes que lee 0x88D3, en grupos de tres y con
;   0xFF al final.
;   0x88f8..0x890b  (19 bytes)
DATA_tabla_88F8:
	defb 08ah,010h,033h	; 88f8
	defb 08bh,090h,034h	; 88fb
	defb 08fh,010h,033h	; 88fe
	defb 08fh,090h,034h	; 8901
	defb 093h,090h,036h	; 8904
	defb 095h,010h,035h	; 8907
	defb 0ffh	; 890a

; ======================================================================
; CODIGO 0x890b..0x8953  (72 bytes)
; ======================================================================


corre_la_pieza_de_e9a0:		; La sube ocho puntos por paso de scroll y, en el paso 2, le va cambiando el dibujo cada 0x20 cuadros
	ld a,(0e9a0h)		;890b
	ld c,a			;890e
	and a			;890f
	ret z			;8910
	ld hl,0e9a2h		;8911
	ld a,(0e100h)		;8914   ; Solo en los pasos con columna
	and a			;8917
	jr z,L_8920		;8918
	ld a,(hl)			;891a
	sub 008h		;891b   ; Ocho puntos mas arriba
	ld (hl),a			;891d
	jr c,acaba_la_pieza_de_e9a0		;891e
L_8920:
	ld a,c			;8920
	cp 002h		;8921   ; Solo el paso 2 anima
	ret nz			;8923
	inc hl			;8924
	dec (hl)			;8925
	ret nz			;8926
	ld (hl),020h		;8927   ; 0x20 cuadros por dibujo
	inc l			;8929
	inc (hl)			;892a
	ld a,(hl)			;892b
	cp 006h		;892c   ; Seis dibujos y se acaba
	ret c			;892e
acaba_la_pieza_de_e9a0:		; 0xE9A0 al paso 3
	ld a,003h		;892f
	ld (0e9a0h),a		;8931
	ret			;8934
dibuja_la_pieza_de_e9a0:		; En el paso 2, un rectangulo de cuatro por seis caracteres, sacado de la tabla de 0x8953 con el dibujo
	ld a,(0e9a0h)		;8935
	cp 002h		;8938   ; Solo en el paso 2
	ret nz			;893a
	ld hl,(0e9a1h)		;893b
	ld a,(0e9a4h)		;893e
	add a,a			;8941   ; Por veinticuatro: cuatro por seis caracteres
	add a,a			;8942
	add a,a			;8943
	ld c,a			;8944
	add a,a			;8945
	add a,c			;8946
	ld bc,00406h		;8947   ; Cuatro de ancho por seis de alto
	ld de,08953h		;894a
	call 04062h		;894d
	jp 0490ch		;8950

; ----------------------------------------------------------------------
; DATOS dibujos_de_la_pieza: Seis dibujos de cuatro por seis caracteres, uno
;   por paso de la animacion. Los lee 0x894A con (0xE9A4).
;   0x8953..0x89e3  (144 bytes)
DATA_dibujos_de_la_pieza:
	defb 05dh,05dh,05dh,05dh	; 8953
	defb 000h,000h,000h,000h	; 8957
	defb 000h,000h,000h,000h	; 895b
	defb 000h,000h,000h,000h	; 895f
	defb 000h,000h,000h,000h	; 8963
	defb 05bh,05bh,05bh,05bh	; 8967
	defb 05ch,05ch,05ch,05ch	; 896b
	defb 000h,000h,000h,000h	; 896f
	defb 000h,000h,000h,000h	; 8973
	defb 000h,000h,000h,000h	; 8977
	defb 000h,000h,000h,000h	; 897b
	defb 05ah,05ah,05ah,05ah	; 897f
	defb 05ch,05ch,05ch,05ch	; 8983
	defb 05dh,05dh,05dh,05dh	; 8987
	defb 000h,000h,000h,000h	; 898b
	defb 000h,000h,000h,000h	; 898f
	defb 05bh,05bh,05bh,05bh	; 8993
	defb 05ah,05ah,05ah,05ah	; 8997
	defb 05ch,05ch,05ch,05ch	; 899b
	defb 05ch,05ch,05ch,05ch	; 899f
	defb 000h,000h,000h,000h	; 89a3
	defb 000h,000h,000h,000h	; 89a7
	defb 05ch,05ch,05ch,05ch	; 89ab
	defb 05ch,05ch,05ch,05ch	; 89af
	defb 05ch,05ch,05ch,05ch	; 89b3
	defb 05ch,05ch,05ch,05ch	; 89b7
	defb 05dh,05dh,05dh,05dh	; 89bb
	defb 05bh,05bh,05bh,05bh	; 89bf
	defb 05ah,05ah,05ah,05ah	; 89c3
	defb 05ah,05ah,05ah,05ah	; 89c7
	defb 05ch,05ch,05ch,05ch	; 89cb
	defb 05ch,05ch,05ch,05ch	; 89cf
	defb 05ch,05ch,05ch,05ch	; 89d3
	defb 05ah,05ah,05ah,05ah	; 89d7
	defb 05ah,05ah,05ah,05ah	; 89db
	defb 05ah,05ah,05ah,05ah	; 89df

; ======================================================================
; CODIGO 0x89e3..0x8a93  (176 bytes)
; ======================================================================


borra_las_dos_piezas:		; Borra de la pantalla las dos ranuras de 0xE780 y 0xE790
	xor a			;89e3
	ld (0ec00h),a		;89e4   ; 0xEC00 a cero: se borra
	ld ix,0e780h		;89e7
	call L_89F2		;89eb
	ld ix,0e790h		;89ee
L_89F2:
	ld a,(ix+000h)		;89f2
	and a			;89f5
	ret z			;89f6
	ld a,(ix+00ch)		;89f7   ; El byte 12 puesto: la pieza esta reventada
	and a			;89fa
	jr z,pinta_o_borra_la_pieza		;89fb
revienta_esta_pieza_2:		; Borra la pieza y monta la explosion a un lado o a otro segun el bit 0 del byte 1
	ld (ix+000h),000h		;89fd
	dec a			;8a01
	ret nz			;8a02
	call pinta_o_borra_la_pieza		;8a03
	ld (ix+000h),000h		;8a06
	bit 0,(ix+001h)		;8a0a   ; El bit 0 del byte 1: a la izquierda o a la derecha
	ld a,0f0h		;8a0e
	jr z,L_8A14		;8a10
	ld a,010h		;8a12
L_8A14:
	add a,(ix+003h)		;8a14
	ld e,a			;8a17
	ld a,(ix+005h)		;8a18
	add a,010h		;8a1b   ; Y 0x10 mas abajo
	ld d,a			;8a1d   ; Y el banco 1 la monta
	jp 07b4eh		;8a1e   ; Diez mas abajo
pinta_las_dos_piezas:		; 0xEC00 a uno y a pintar las dos ranuras
	ld a,001h		;8a21
	ld (0ec00h),a		;8a23
	ld ix,0e780h		;8a26
	call L_8A31		;8a2a
	ld ix,0e790h		;8a2d
L_8A31:
	ld a,(ix+000h)		;8a31
	and a			;8a34
	ret z			;8a35
pinta_o_borra_la_pieza:		; La tabla de 0x8B4C da el desplazamiento y el tamano del rectangulo; 0xEC00 decide si se pinta o se borra
	ld a,(ix+00ah)		;8a36
	ld hl,08b4ch		;8a39   ; La tabla de 0x8B4C, indexada por el dibujo
	call 047aeh		;8a3c
	ex de,hl			;8a3f
	ld a,(hl)			;8a40   ; El desplazamiento en X...
	add a,(ix+003h)		;8a41
	ld e,a			;8a44
	inc hl			;8a45
	ld a,(hl)			;8a46   ; ...y en Y
	add a,(ix+005h)		;8a47
	ret c			;8a4a
	ld d,a			;8a4b
	inc hl			;8a4c
	ld c,(hl)			;8a4d   ; Y el ancho y el alto
	inc hl			;8a4e
	ld b,(hl)			;8a4f
	inc hl			;8a50
	ex de,hl			;8a51
	ld a,(0ec00h)		;8a52   ; 0xEC00 decide: borrar o pintar
	and a			;8a55   ; La posicion de la pieza
	jp z,048f7h		;8a56   ; La posicion de la pieza
	jp 0490ch		;8a59
corre_las_dos_piezas:		; Un paso para cada una de las dos ranuras
	ld ix,0e780h		;8a5c
	call paso_de_esta_pieza		;8a60
	ld ix,0e790h		;8a63
paso_de_esta_pieza:		; Se mueve, dispara, y cada 0x10 cuadros cambia de dibujo con la tabla de 0x8A93
	ld a,(ix+000h)		;8a67
	and a			;8a6a
	ret z			;8a6b
	call sube_la_pieza		;8a6c
	call hacia_donde_mira		;8a6f
	call gira_la_pieza		;8a72
	dec (ix+008h)		;8a75   ; 0x10 cuadros por dibujo
	ret nz			;8a78
	ld (ix+008h),010h		;8a79
	ld a,(ix+00ah)		;8a7d
	ld hl,08a93h		;8a80   ; La tabla de 0x8A93: donde cae cada dibujo
	call 047aeh		;8a83   ; La tabla de 0x8A93
	ld a,(ix+003h)		;8a86
	add a,e			;8a89
	ld e,a			;8a8a
	ld a,(ix+005h)		;8a8b
	add a,d			;8a8e
	ld d,a			;8a8f
	jp 06613h		;8a90

; ----------------------------------------------------------------------
; DATOS salida_del_disparo: Catorce parejas (dx, dy) con signo, una por
;   dibujo: por donde le sale el disparo a la pieza segun hacia donde este
;   mirando. Las leen 0x8A80 de este banco y 0x769F del banco 1.
;   0x8a93..0x8aaf  (28 bytes)
DATA_salida_del_disparo:
	defb 0fch,0feh	; 8a93
	defb 0f4h,0feh	; 8a95
	defb 0f4h,0feh	; 8a97
	defb 0e8h,004h	; 8a99
	defb 0e0h,008h	; 8a9b
	defb 0d0h,01ah	; 8a9d
	defb 0d0h,020h	; 8a9f
	defb 0f8h,0feh	; 8aa1
	defb 000h,0feh	; 8aa3
	defb 000h,0feh	; 8aa5
	defb 008h,004h	; 8aa7
	defb 012h,00ah	; 8aa9
	defb 020h,01ah	; 8aab
	defb 022h,022h	; 8aad

; ======================================================================
; CODIGO 0x8aaf..0x8b2c  (125 bytes)
; ======================================================================


gira_la_pieza:		; Cada seis cuadros da un paso hacia el dibujo que quiere alcanzar, uno arriba o uno abajo
	dec (ix+007h)		;8aaf
	ret nz			;8ab2
	ld (ix+007h),006h		;8ab3   ; Seis cuadros por paso
	ld a,(ix+00ah)		;8ab7   ; El byte 10 es el dibujo de ahora y el 11 el que persigue
	cp (ix+00bh)		;8aba
	ret z			;8abd
	ld c,001h		;8abe   ; Un paso hacia el
	jr c,L_8AC4		;8ac0
	ld c,0ffh		;8ac2
L_8AC4:
	add a,c			;8ac4
	ld (ix+00ah),a		;8ac5
	ret			;8ac8
sube_la_pieza:		; En los pasos con columna nueva sube ocho puntos; al llegar a cero se da por reventada
	ld a,(0e100h)		;8ac9   ; Solo en los pasos con columna
	and a			;8acc
	ret z			;8acd
	ld a,(ix+005h)		;8ace
	sub 008h		;8ad1   ; Ocho puntos mas arriba
	ld (ix+005h),a		;8ad3
	ret nz			;8ad6
	ld (ix+00ch),002h		;8ad7   ; Al llegar a cero, el byte 12 a dos
	ret			;8adb
hacia_donde_mira:		; Mide el angulo hasta la nave y de ahi saca el dibujo al que tiene que girar, mas un temblor del registro R
	ld e,(ix+003h)		;8adc
	ld a,(ix+005h)		;8adf   ; 0x38 por debajo de la pieza
	add a,038h		;8ae2
	ld d,a			;8ae4
	call 066d5h		;8ae5   ; El banco 1 mide el angulo
	ld a,(0ec18h)		;8ae8
	bit 0,(ix+001h)		;8aeb   ; El bit 0 del byte 1: una de las dos tablas
	jr z,hacia_donde_mira_la_otra		;8aef
	ld c,008h		;8af1
	sub 040h		;8af3   ; Fuera del cuarto de vuelta que alcanza, se queda como esta
	jr c,L_8B06		;8af5
	cp 040h		;8af7
	jr nc,L_8B06		;8af9
	ld hl,08b3ch		;8afb   ; La tabla de 0x8B3C
	rra			;8afe
	rra			;8aff
	and 00fh		;8b00
	call 0405dh		;8b02
	ld c,(hl)			;8b05
L_8B06:
	ld a,r		;8b06   ; El registro R: menos uno, cero o uno de temblor
	and 003h		;8b08   ; Cuatro bits del angulo
	dec a			;8b0a
	cp 002h		;8b0b
	jr nz,L_8B10		;8b0d
	xor a			;8b0f
L_8B10:
	add a,c			;8b10
	ld (ix+00bh),a		;8b11
	ret			;8b14
hacia_donde_mira_la_otra:		; Lo mismo con la tabla de 0x8B2C y el otro cuadrante
	ld c,001h		;8b15   ; El otro cuadrante
	sub 080h		;8b17   ; Medio giro
	jr c,L_8B06		;8b19
	cp 040h		;8b1b
	jr nc,L_8B06		;8b1d
	ld hl,08b2ch		;8b1f   ; La tabla de 0x8B2C
	rra			;8b22
	rra			;8b23
	and 00fh		;8b24
	call 0405dh		;8b26
	ld c,(hl)			;8b29
	jr L_8B06		;8b2a

; ----------------------------------------------------------------------
; DATOS tabla_8B2C: Dieciseis bytes que lee 0x8B1F.
;   0x8b2c..0x8b3c  (16 bytes)
DATA_tabla_8B2C:
	defb 001h,002h,003h,004h,004h,004h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h	; 8b2c  ................

; ----------------------------------------------------------------------
; DATOS tabla_8B3C: Dieciseis bytes que lee 0x8AFB.
;   0x8b3c..0x8b4c  (16 bytes)
DATA_tabla_8B3C:
	defb 00ch,00ch,00ch,00ch,00ch,00ch,00ch,00ch,00ch,00ch,00bh,00ch,00ah,00ah,009h,008h	; 8b3c  ................

; ----------------------------------------------------------------------
; DATOS tabla_8B4C: Lo que lee 0x8A39 con `ld hl,0x8B4C`, seguido hasta el
;   codigo de al lado.
;   0x8b4c..0x8ce4  (408 bytes)
DATA_tabla_8B4C:
	defb 068h,08bh,081h,08bh,09ah,08bh,0b3h,08bh,0cch,08bh,0e8h,08bh,00ah,08ch,026h,08ch	; 8b4c  h.............&.
	defb 03fh,08ch,058h,08ch,071h,08ch,08ah,08ch,0a6h,08ch,0c8h,08ch,0f8h,000h,003h,007h	; 8b5c  ?.X.q...........
	defb 000h,000h,000h,000h,070h,070h,000h,06eh,068h,06eh,064h,06fh,06fh,064h,06dh,067h	; 8b6c  ....pp.nhndoodmg
	defb 06dh,000h,000h,000h,000h,0f8h,000h,003h,007h,06eh,070h,000h,000h,000h,000h,000h	; 8b7c  m........np.....
	defb 06dh,06fh,06eh,068h,068h,06eh,064h,000h,000h,06dh,067h,067h,06dh,000h,0f8h,000h	; 8b8c  monhhnd..mggm...
	defb 003h,007h,06eh,06eh,068h,070h,000h,000h,000h,06dh,06dh,067h,06fh,06eh,068h,064h	; 8b9c  ..nnhp...mmgonhd
	defb 000h,000h,000h,000h,06dh,067h,000h,0f0h,000h,003h,007h,065h,066h,000h,000h,000h	; 8bac  ....mg.....ef...
	defb 000h,000h,000h,064h,068h,000h,000h,000h,000h,000h,000h,067h,064h,064h,064h,064h	; 8bbc  ...dh......gdddd
	defb 0e8h,008h,004h,006h,069h,06ah,000h,000h,000h,000h,065h,066h,000h,000h,000h,000h	; 8bcc  ....ij....ef....
	defb 000h,064h,068h,070h,000h,000h,000h,000h,067h,06fh,064h,064h,0d8h,010h,006h,005h	; 8bdc  .dhp....godd....
	defb 000h,069h,06ah,000h,000h,06bh,06ch,000h,000h,000h,06bh,06ch,000h,000h,000h,000h	; 8bec  .ij..kl...kl....
	defb 06eh,000h,000h,000h,000h,06dh,064h,068h,000h,000h,000h,000h,067h,064h,0d8h,018h	; 8bfc  n....mdh....gd..
	defb 006h,004h,000h,069h,06ah,000h,06bh,06ch,000h,000h,069h,06ah,000h,000h,065h,066h	; 8c0c  ...ij.kl..ij..ef
	defb 000h,000h,000h,064h,070h,000h,000h,000h,06fh,064h,0f8h,000h,003h,007h,030h,028h	; 8c1c  ...dp...od....0(
	defb 030h,000h,000h,000h,000h,02fh,027h,02fh,024h,02eh,02eh,024h,000h,000h,000h,000h	; 8c2c  0..../'/$..$....
	defb 02dh,02dh,000h,0f8h,000h,003h,007h,000h,000h,030h,028h,028h,030h,000h,030h,02eh	; 8c3c  --.......0((0.0.
	defb 02fh,027h,027h,02fh,024h,02fh,02dh,000h,000h,000h,000h,000h,0f8h,000h,003h,007h	; 8c4c  /''/$/-.........
	defb 000h,000h,000h,000h,030h,028h,000h,030h,030h,028h,02eh,02fh,027h,024h,02fh,02fh	; 8c5c  ....0(.00(./'$//
	defb 027h,02dh,000h,000h,000h,000h,000h,003h,007h,000h,000h,028h,024h,024h,024h,024h	; 8c6c  '-.........($$$$
	defb 000h,024h,027h,000h,000h,000h,000h,025h,026h,000h,000h,000h,000h,000h,000h,008h	; 8c7c  .$'....%&.......
	defb 004h,006h,000h,000h,028h,02eh,024h,024h,000h,024h,027h,02dh,000h,000h,025h,026h	; 8c8c  ....(.$$.$'-..%&
	defb 000h,000h,000h,000h,029h,02ah,000h,000h,000h,000h,000h,010h,006h,005h,000h,000h	; 8c9c  ....)*..........
	defb 000h,028h,024h,000h,030h,024h,027h,000h,000h,02fh,000h,000h,000h,02bh,02ch,000h	; 8cac  .($.0$'../...+,.
	defb 000h,000h,06bh,06ch,000h,000h,000h,000h,069h,06ah,000h,000h,000h,018h,006h,004h	; 8cbc  ..kl....ij......
	defb 000h,000h,02eh,024h,000h,024h,02dh,000h,025h,026h,000h,000h,029h,02ah,000h,000h	; 8ccc  ...$.$-.%&..)*..
	defb 06bh,06ch,000h,000h,000h,069h,06ah,000h	; 8cdc  kl...ij.

; ======================================================================
; CODIGO 0x8ce4..0x8d2f  (75 bytes)
; ======================================================================


corre_y_dibuja_el_jefe_3:		; Un paso de este jefe y su dibujo
	call paso_del_jefe_3		;8ce4
	jp corre_las_ocho_piezas_3		;8ce7
paso_del_jefe_3:		; En el paso 0 calcula lo que dura y cada cuantos cuadros suelta pieza, y luego las va soltando
	ld a,(0e190h)		;8cea
	dec a			;8ced
	jr z,suelta_una_pieza_3		;8cee
	jp p,mira_si_se_acabo_el_jefe_3		;8cf0
	ld hl,00258h		;8cf3   ; 0x258 cuadros
	ld (0e153h),hl		;8cf6
	ld a,(0e111h)		;8cf9   ; 0x48 menos dos veces la dificultad: los cuadros entre pieza y pieza
	add a,a			;8cfc   ; 0x48 menos dos veces la dificultad
	sub 048h		;8cfd
	neg		;8cff
	ld hl,0e156h		;8d01
	ld (hl),a			;8d04
	inc l			;8d05
	ld (hl),a			;8d06
	jp 07cd4h		;8d07
suelta_una_pieza_3:		; Cada tantos cuadros busca hueco entre las ocho ranuras y copia ahi los diez bytes de 0x8D2F
	ld hl,(0e153h)		;8d0a   ; 0xE153: los cuadros que le quedan al jefe
	dec hl			;8d0d
	ld a,h			;8d0e
	or l			;8d0f
	jp z,07cd4h		;8d10
	ld (0e153h),hl		;8d13
	ld hl,0e156h		;8d16   ; 0xE156: los cuadros hasta la pieza siguiente
	dec (hl)			;8d19
	ret nz			;8d1a
	inc l			;8d1b
	ld a,(hl)			;8d1c
	dec l			;8d1d
	ld (hl),a			;8d1e
	ld b,008h		;8d1f   ; Ocho ranuras
	call hay_alguna_libre		;8d21
	ret nz			;8d24
	ld de,08d2fh		;8d25   ; Los diez bytes de arranque
	ex de,hl			;8d28
	ld bc,0000ah		;8d29
	ldir		;8d2c
	ret			;8d2e

; ----------------------------------------------------------------------
; DATOS ficha_de_la_pieza_3: Los diez bytes de arranque de una pieza de este
;   jefe, que 0x8D25 copia tal cual a la ranura libre.
;   0x8d2f..0x8d39  (10 bytes)
DATA_ficha_de_la_pieza_3:
	defb 006h,000h,000h,018h,000h,0f8h,000h,000h,000h,028h	; 8d2f  .........(

; ======================================================================
; CODIGO 0x8d39..0x8d64  (43 bytes)
; ======================================================================


mira_si_se_acabo_el_jefe_3:		; Cuando no queda ninguna pieza ni ninguna explosion, el jefe se da por muerto
	ld b,008h		;8d39   ; Ocho ranuras de pieza
	call hay_alguna_viva		;8d3b
	ret nz			;8d3e
	call hay_alguna_explosion		;8d3f
	ret nz			;8d42
	jp 07d64h		;8d43
corre_las_ocho_piezas_3:		; Las ocho ranuras de 0xE780, cada una por su paso
	ld ix,0e780h		;8d46
	ld b,008h		;8d4a   ; Ocho ranuras
L_8D4C:
	push bc			;8d4c
	call paso_de_la_pieza_3		;8d4d
	ld de,00010h		;8d50   ; Dieciseis bytes: la siguiente
	add ix,de		;8d53   ; Dieciseis bytes: la siguiente
	pop bc			;8d55   ; Dieciseis bytes
	djnz L_8D4C		;8d56
	ret			;8d58
paso_de_la_pieza_3:		; Doce salidas, una por paso, en la tabla de 0x8D64
	ld a,(ix+000h)		;8d59
	or a			;8d5c
	ret z			;8d5d
	ld a,(ix+001h)		;8d5e
	call 04067h		;8d61

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_8D61: Doce palabras pegadas detras del `call
;   0x4067` de 0x8D61.
;   0x8d64..0x8d7c  (24 bytes)
DATA_tabla_del_despachador_8D61:
	defw 08d7ch,08d87h	; 8d64  -> paso_0_dos_a_la_izquierda paso_1_en_diagonal
	defw 08d93h,08d9eh	; 8d68  -> paso_2_dos_a_la_izquierda paso_3_en_diagonal_arriba
	defw 08daah,08db5h	; 8d6c  -> paso_4_dos_a_la_izquierda paso_5_en_diagonal
	defw 08dc1h,08dcch	; 8d70  -> paso_6_dos_a_la_izquierda paso_7_en_diagonal_arriba
	defw 08dd9h,08de5h	; 8d74  -> paso_8_dos_abajo paso_9_dos_a_la_derecha
	defw 08df0h,08e14h	; 8d78  -> paso_10_hacia_la_nave paso_11_se_va

; ======================================================================
; CODIGO 0x8d7c..0x8e5f  (227 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL RECORRIDO DE LA PIEZA, ESCRITO PASO A PASO
; Esta pieza no persigue a nadie: hace un recorrido fijo, escrito como doce
; pasos. Cada uno le suma una velocidad constante -dos bytes con signo- y
; espera a que llegue a una coordenada exacta; cuando llega, pasa al paso
; siguiente. El unico que mira a la nave es el 0x0A, que elige hacia que
; lado va antes de seguir.
; ----------------------------------------------------------------------
paso_0_dos_a_la_izquierda:		; Dos a la izquierda hasta la X 0xE6
	ld de,000feh		;8d7c
	call suma_a_los_campos_3_y_5		;8d7f
	cp 0e6h		;8d82
	ret nz			;8d84
	jr paso_siguiente_del_recorrido		;8d85
paso_1_en_diagonal:		; Dos a la izquierda y dos abajo hasta la Y 0x30
	ld de,002feh		;8d87   ; Dos a la izquierda y dos abajo
	call suma_a_los_campos_3_y_5		;8d8a   ; Dos a la izquierda y dos abajo
	ld a,d			;8d8d   ; La Y 0x30
	cp 030h		;8d8e
	ret nz			;8d90
	jr paso_siguiente_del_recorrido		;8d91
paso_2_dos_a_la_izquierda:		; Hasta la X 0x98
	ld de,000feh		;8d93
	call suma_a_los_campos_3_y_5		;8d96
	cp 098h		;8d99
	ret nz			;8d9b
	jr paso_siguiente_del_recorrido		;8d9c
paso_3_en_diagonal_arriba:		; Dos a la izquierda y dos arriba hasta la Y 0x18
	ld de,0fefeh		;8d9e   ; Dos a la izquierda y dos arriba
	call suma_a_los_campos_3_y_5		;8da1   ; Dos a la izquierda y dos arriba
	ld a,d			;8da4   ; La Y 0x18
	cp 018h		;8da5
	ret nz			;8da7
	jr paso_siguiente_del_recorrido		;8da8
paso_4_dos_a_la_izquierda:		; Hasta la X 0x66
	ld de,000feh		;8daa
	call suma_a_los_campos_3_y_5		;8dad
	cp 066h		;8db0
	ret nz			;8db2
	jr paso_siguiente_del_recorrido		;8db3
paso_5_en_diagonal:		; Hasta la Y 0x30
	ld de,002feh		;8db5   ; Dos a la izquierda y dos abajo
	call suma_a_los_campos_3_y_5		;8db8   ; Dos a la izquierda y dos abajo
	ld a,d			;8dbb   ; La Y 0x30
	cp 030h		;8dbc
	ret nz			;8dbe
	jr paso_siguiente_del_recorrido		;8dbf
paso_6_dos_a_la_izquierda:		; Hasta la X 0x18
	ld de,000feh		;8dc1
	call suma_a_los_campos_3_y_5		;8dc4
	cp 018h		;8dc7
	ret nz			;8dc9
	jr paso_siguiente_del_recorrido		;8dca
paso_7_en_diagonal_arriba:		; Hasta la X 0x08
	ld de,0fefeh		;8dcc
	call suma_a_los_campos_3_y_5		;8dcf
	cp 008h		;8dd2
	ret nz			;8dd4
paso_siguiente_del_recorrido:		; El byte 1 sube
	inc (ix+001h)		;8dd5
	ret			;8dd8
paso_8_dos_abajo:		; Hasta la Y 0x78
	ld de,00200h		;8dd9   ; Dos abajo
	call suma_a_los_campos_3_y_5		;8ddc   ; Dos abajo
	ld a,d			;8ddf   ; La Y 0x78
	cp 078h		;8de0
	ret nz			;8de2
	jr paso_siguiente_del_recorrido		;8de3
paso_9_dos_a_la_derecha:		; Hasta la X 0xE0
	ld de,00002h		;8de5
	call suma_a_los_campos_3_y_5		;8de8
	cp 0e0h		;8deb
	ret nz			;8ded
	jr paso_siguiente_del_recorrido		;8dee
paso_10_hacia_la_nave:		; Se acerca a la fila de la nave; a menos de 0x11 o fuera del tramo 0x30-0x88, pasa al siguiente
	ld a,(0e204h)		;8df0   ; 0xE204: la fila de la nave
	sub (ix+003h)		;8df3
	push af			;8df6
	add a,008h		;8df7
	cp 011h		;8df9   ; A menos de 0x11 ya esta encima
	jr c,L_8E11		;8dfb
	pop af			;8dfd
	ld de,0fe00h		;8dfe   ; Dos a la izquierda...
	jr c,L_8E06		;8e01
	ld de,00200h		;8e03   ; ...o dos a la derecha
L_8E06:
	call suma_a_los_campos_3_y_5		;8e06   ; Dos a un lado o al otro
	ld a,d			;8e09
	sub 030h		;8e0a
	cp 058h		;8e0c
	ret c			;8e0e
	jr paso_siguiente_del_recorrido		;8e0f
L_8E11:
	pop af			;8e11
	jr paso_siguiente_del_recorrido		;8e12
paso_11_se_va:		; Dos a la izquierda hasta pasar la X 0xF0, y la ranura se libera
	ld de,000feh		;8e14   ; Dos a la izquierda
	call suma_a_los_campos_3_y_5		;8e17
	cp 0f0h		;8e1a
	ret c			;8e1c
	ld (ix+000h),000h		;8e1d
	ret			;8e21
suma_a_los_campos_3_y_5:		; Suma D al byte (IX+3) y E al (IX+5), y devuelve en D lo que quedo en el primero.
	push ix		;8e22   ; Los bytes 3 y 5: la X y la Y
	pop hl			;8e24   ; Tres bytes mas alla: la X
	inc l			;8e25   ; Se le suma D
	inc l			;8e26
	inc l			;8e27
	ld a,(hl)			;8e28
	add a,d			;8e29
	ld (hl),a			;8e2a
	ld d,a			;8e2b
	inc l			;8e2c
	inc l			;8e2d
	ld a,(hl)			;8e2e
	add a,e			;8e2f
	ld (hl),a			;8e30
	ret			;8e31
recorre_los_ocho:		; Las ocho fichas de dieciseis bytes desde 0xE780
	ld hl,0e780h		;8e32
	ld b,008h		;8e35   ; Ocho fichas
L_8E37:
	push bc			;8e37
	push hl			;8e38
	call dibuja_la_pieza_parpadeando		;8e39
	pop hl			;8e3c
	ld de,00010h		;8e3d   ; Dieciseis bytes: la siguiente
	add hl,de			;8e40   ; 0x10: la fila de abajo
	pop bc			;8e41
	djnz L_8E37		;8e42
	ret			;8e44
dibuja_la_pieza_parpadeando:		; Cuatro por tres caracteres, alternando cada cuatro cuadros entre los dos dibujos
	ld a,(hl)			;8e45
	or a			;8e46
	ret z			;8e47
	call posicion_de_la_ficha		;8e48
	ld a,(0e003h)		;8e4b   ; Un bit del contador: los dos dibujos se alternan
	and 004h		;8e4e
	ld hl,08e5fh		;8e50
	jr z,L_8E58		;8e53
	ld hl,08e6bh		;8e55
L_8E58:
	ex de,hl			;8e58
	ld bc,00403h		;8e59   ; Cuatro de ancho por tres de alto
	jp 0490ch		;8e5c

; ----------------------------------------------------------------------
; DATOS caracteres_8E5F: Doce bytes que lee 0x8E50.
;   0x8e5f..0x8e6b  (12 bytes)
DATA_caracteres_8E5F:
	defb 000h,0bah,0bbh,000h	; 8e5f
	defb 0bch,0bdh,0beh,0bfh	; 8e63
	defb 000h,0c0h,0c1h,000h	; 8e67

; ----------------------------------------------------------------------
; DATOS caracteres_8E6B: Doce bytes que lee 0x8E55.
;   0x8e6b..0x8e77  (12 bytes)
DATA_caracteres_8E6B:
	defb 000h,0bah,0bbh,000h	; 8e6b
	defb 0c2h,0c3h,0c4h,0c5h	; 8e6f
	defb 000h,0c0h,0c1h,000h	; 8e73

; ======================================================================
; CODIGO 0x8e77..0x8eba  (67 bytes)
; ======================================================================


monta_las_cinco_piezas:		; Enciende 0xE1B0 y monta las cinco ranuras de 0xEB00 con las posiciones de 0x8EBA; el ritmo sale de la dificultad
	ld hl,0e1b0h		;8e77
	ld (hl),001h		;8e7a
	inc l			;8e7c
	inc l			;8e7d
	ld (hl),0f8h		;8e7e   ; 0xF8 en 0xE1B2
	ld a,(0e111h)		;8e80   ; 0x5C menos cuatro veces la dificultad: los cuadros entre pasos
	add a,a			;8e83   ; La tabla de 0x8A93
	add a,a			;8e84   ; La tabla de 0x8A93
	sub 05ch		;8e85
	neg		;8e87
	inc l			;8e89
	inc l			;8e8a
	ld (hl),a			;8e8b
	inc l			;8e8c
	ld (hl),a			;8e8d
	ld hl,08ebah		;8e8e
	ld de,0eb00h		;8e91
	exx			;8e94
	ld b,005h		;8e95   ; Cinco piezas
L_8E97:
	exx			;8e97
	ld a,001h		;8e98
	ld (de),a			;8e9a
	ld a,004h		;8e9b
	add a,e			;8e9d
	ld e,a			;8e9e
	ldi		;8e9f   ; La X y la Y de la tabla
	inc e			;8ea1
	ldi		;8ea2
	ld a,008h		;8ea4
	add a,e			;8ea6
	ld e,a			;8ea7
	ld a,00ah		;8ea8   ; Diez
	ld (de),a			;8eaa
	ld a,00ch		;8eab
	add a,e			;8ead
	ld e,a			;8eae
	ld a,003h		;8eaf   ; Y tres
	ld (de),a			;8eb1
	ld a,005h		;8eb2   ; 0x20 bytes en total: la ranura siguiente
	add a,e			;8eb4
	ld e,a			;8eb5
	exx			;8eb6
	djnz L_8E97		;8eb7
	ret			;8eb9

; ----------------------------------------------------------------------
; DATOS posiciones_de_las_cinco: Cinco parejas (X, Y) con las que arrancan las
;   cinco piezas de 0xEB00. Las lee 0x8E8E.
;   0x8eba..0x8ec4  (10 bytes)
DATA_posiciones_de_las_cinco:
	defb 04ch,0f0h	; 8eba
	defb 054h,0f0h	; 8ebc
	defb 05eh,0e8h	; 8ebe
	defb 068h,0f0h	; 8ec0
	defb 070h,0f0h	; 8ec2

; ======================================================================
; CODIGO 0x8ec4..0x905c  (408 bytes)
; ======================================================================


corre_las_cinco_piezas:		; Las corre con el scroll, les da un paso a cada una y las anima
	ld a,(0e1b0h)		;8ec4   ; Sin 0xE1B0 no hay nada
	or a			;8ec7
	ret z			;8ec8
	call corre_el_grupo		;8ec9
	jp c,07d64h		;8ecc
	call recorre_las_cinco		;8ecf
	call anima_las_cinco		;8ed2
	ret			;8ed5
corre_el_grupo:		; En los pasos con columna, ocho puntos a la izquierda
	ld a,(0e100h)		;8ed6   ; Solo en los pasos con columna
	or a			;8ed9
	ret z			;8eda
	ld hl,0e1b2h		;8edb
	ld a,(hl)			;8ede
	sub 008h		;8edf   ; Ocho puntos a la izquierda
	ld (hl),a			;8ee1
	ret			;8ee2
recorre_las_cinco:		; Las cinco ranuras de 0xEB00, de 0x20 en 0x20 bytes
	ld hl,0eb00h		;8ee3
	ld a,005h		;8ee6   ; Cinco
	ld (0e1b6h),a		;8ee8
L_8EEB:
	push hl			;8eeb
	call paso_de_una_de_las_cinco		;8eec
	ld hl,0e1b6h		;8eef
	dec (hl)			;8ef2
	pop hl			;8ef3
	ld de,00020h		;8ef4   ; Treinta y dos bytes: la siguiente
	add hl,de			;8ef7   ; Cinco piezas
	jr nz,L_8EEB		;8ef8   ; Cinco piezas
	ret			;8efa
paso_de_una_de_las_cinco:		; La corre con el scroll y, si es del tipo 0x15, le cambia el dibujo cada cuatro cuadros
	ld a,(hl)			;8efb
	or a			;8efc
	ret z			;8efd
	ld a,(0e100h)		;8efe
	or a			;8f01
	call nz,corre_esta_pieza		;8f02
	ld a,(hl)			;8f05
	or a			;8f06
	ret z			;8f07
	cp 015h		;8f08   ; Solo el tipo 0x15 se anima
	ret nz			;8f0a
	inc l			;8f0b
	inc l			;8f0c
	inc (hl)			;8f0d
	ld a,(hl)			;8f0e
	cp 004h		;8f0f   ; Cuatro cuadros por dibujo
	ret c			;8f11
	ld (hl),000h		;8f12
	ld a,00ah		;8f14
	add a,l			;8f16
	ld l,a			;8f17
	inc (hl)			;8f18
	ld a,(hl)			;8f19
	cp 07ch		;8f1a   ; Pasado el dibujo 0x7C, vuelve a empezar
	ret c			;8f1c
	ld a,l			;8f1d
	sub 00ch		;8f1e
	ld l,a			;8f20
	ld (hl),000h		;8f21
	ret			;8f23
corre_esta_pieza:		; Ocho puntos a la izquierda; al salirse por el borde, la ranura se libera
	ld a,006h		;8f24   ; Seis bytes mas alla: la columna
	add a,l			;8f26
	ld l,a			;8f27
	ld a,(hl)			;8f28
	sub 008h		;8f29
	ld (hl),a			;8f2b
	push af			;8f2c
	ld a,l			;8f2d   ; Y de vuelta al principio de la ficha
	sub 006h		;8f2e
	ld l,a			;8f30
	pop af			;8f31
	jr nc,L_8F36		;8f32
	ld (hl),000h		;8f34
L_8F36:
	ret			;8f36
anima_las_cinco:		; Cada tantos cuadros -los que diga 0xE1B5- le da un paso a cada una de las cinco
	ld a,(0e1c0h)		;8f37   ; Con la pantalla parada, no
	and a			;8f3a
	ret nz			;8f3b
	ld hl,0e1b4h		;8f3c   ; 0xE1B4: los cuadros que faltan
	dec (hl)			;8f3f
	ret nz			;8f40
	inc l			;8f41
	ld a,(hl)			;8f42
	dec l			;8f43
	ld (hl),a			;8f44
	ld hl,0eb00h		;8f45
	ld a,005h		;8f48   ; Cinco piezas
	ld (0e1b6h),a		;8f4a
L_8F4D:
	push hl			;8f4d
	call suelta_la_pieza		;8f4e
	ld hl,0e1b6h		;8f51
	dec (hl)			;8f54
	pop hl			;8f55
	ld de,00020h		;8f56   ; Treinta y dos bytes: la siguiente
	add hl,de			;8f59
	jr nz,L_8F4D		;8f5a
	ret			;8f5c
suelta_la_pieza:		; Si la ranura esta en el paso 1 y por debajo de la Y 0x30, busca hueco en 0xE500 y monta ahi un objeto que cae
	ld a,(hl)			;8f5d   ; Solo las que van por el paso 1
	dec a			;8f5e
	ret nz			;8f5f
	ld a,004h		;8f60
	add a,l			;8f62
	ld l,a			;8f63
	ld e,(hl)			;8f64   ; Su X y su Y
	inc l			;8f65
	inc l			;8f66
	ld d,(hl)			;8f67
	ld a,d			;8f68
	cp 030h		;8f69   ; Por encima de la Y 0x30, no
	ret c			;8f6b
	call hay_hueco_en_e500		;8f6c
	ret c			;8f6f
	ld (hl),001h		;8f70   ; La ranura pasa al paso 1
	ld a,004h		;8f72
	add a,l			;8f74
	ld l,a			;8f75
	ld (hl),e			;8f76
	inc l			;8f77
	inc l			;8f78
	ld a,d			;8f79
	sub 018h		;8f7a   ; 0x18 por encima
	ld d,a			;8f7c   ; 0x18 por encima
	ld (hl),d			;8f7d   ; Ahi cae
	inc l			;8f7e
	ld (hl),000h		;8f7f
	inc l			;8f81
	ld (hl),000h		;8f82
	inc l			;8f84
	ld (hl),000h		;8f85
	inc l			;8f87
	ld (hl),0fch		;8f88   ; Velocidad 0xFC
	inc l			;8f8a
	ld a,(0e1b6h)		;8f8b   ; Las dos ultimas llevan el dibujo 5, y las demas el 4
	cp 003h		;8f8e
	ld a,004h		;8f90
	jr nc,L_8F95		;8f92
	inc a			;8f94
L_8F95:
	ld (hl),a			;8f95
	ld a,010h		;8f96   ; Dieciseis bytes mas alla, la marca de vivo
	add a,l			;8f98
	ld l,a			;8f99
	ld (hl),001h		;8f9a
	ret			;8f9c
hay_hueco_en_e500:		; Devuelve en HL la primera de las diez ranuras de 0xE500 que este libre; con acarreo, no hay
	ld hl,0e500h		;8f9d
	ld b,00ah		;8fa0   ; Diez ranuras
L_8FA2:
	ld a,(hl)			;8fa2
	or a			;8fa3
	ret z			;8fa4
	ld a,020h		;8fa5   ; Treinta y dos bytes: la siguiente
	add a,l			;8fa7   ; Treinta y dos bytes: la siguiente
	ld l,a			;8fa8   ; Treinta y dos bytes
	jr nc,L_8FAC		;8fa9
	inc h			;8fab
L_8FAC:
	djnz L_8FA2		;8fac
	scf			;8fae
	ret			;8faf
apunta_las_casillas_de_las_cinco:		; A cada una de las cinco le calcula la casilla del mapa donde cae
	ld a,(0e1b0h)		;8fb0
	or a			;8fb3
	ret z			;8fb4
	ld hl,0eb00h		;8fb5
	ld a,005h		;8fb8   ; Cinco
	ld (0e1b6h),a		;8fba
L_8FBD:
	push hl			;8fbd
	call casilla_de_una_de_las_cinco		;8fbe
	ld hl,0e1b6h		;8fc1
	dec (hl)			;8fc4
	pop hl			;8fc5
	ld de,00020h		;8fc6   ; Treinta y dos bytes: la siguiente
	add hl,de			;8fc9   ; Treinta y dos bytes: la siguiente
	jr nz,L_8FBD		;8fca   ; Treinta y dos bytes
	ret			;8fcc
casilla_de_una_de_las_cinco:		; La posicion pasa a casilla de mapa, y la tercera pieza guarda ademas la fila de abajo
	ld a,(hl)			;8fcd
	or a			;8fce
	ret z			;8fcf
	ld a,004h		;8fd0
	add a,l			;8fd2
	ld l,a			;8fd3
	ld e,(hl)			;8fd4   ; Su X y su Y
	inc l			;8fd5
	inc l			;8fd6
	ld d,(hl)			;8fd7
	push hl			;8fd8
	ex de,hl			;8fd9
	call 0571bh		;8fda   ; El banco 0 convierte posicion en casilla
	ex de,hl			;8fdd
	pop hl			;8fde
	ld a,018h		;8fdf   ; Se guarda 0x18 bytes mas alla
	add a,l			;8fe1   ; 0x18 bytes mas alla
	ld l,a			;8fe2   ; Ahi se guarda la casilla
	ld (hl),e			;8fe3
L_8FE4:
	inc l			;8fe4
	ld (hl),d			;8fe5
	ld a,l			;8fe6
	sub 00ch		;8fe7
	ld l,a			;8fe9
	ex de,hl			;8fea
	ldi		;8feb
	ldi		;8fed
	ld a,(0e1b6h)		;8fef   ; La tercera lleva ademas la fila de abajo
	cp 003h		;8ff2
	ret nz			;8ff4
	ld bc,0001eh		;8ff5   ; 0x1E: la fila de abajo del mapa
	add hl,bc			;8ff8   ; 0x1E: la fila de abajo
	ldi		;8ff9
	ldi		;8ffb
	ret			;8ffd
dibuja_las_cinco:		; Escribe en el mapa los caracteres de cada una de las cinco
	ld a,(0e1b0h)		;8ffe
	or a			;9001
	ret z			;9002
	ld hl,0eb00h		;9003
	ld a,005h		;9006   ; Cinco
	ld (0e1b6h),a		;9008
L_900B:
	push hl			;900b
	call dibuja_una_de_las_cinco		;900c
	ld hl,0e1b6h		;900f
	dec (hl)			;9012
	pop hl			;9013
	ld de,00020h		;9014   ; Treinta y dos bytes: la siguiente
	add hl,de			;9017
	jr nz,L_900B		;9018
	ret			;901a
dibuja_una_de_las_cinco:		; Las que van por el paso 1 llevan pareja de caracteres de la tabla de 0x905C; las demas, uno solo
	ld a,(hl)			;901b
	or a			;901c
	ret z			;901d
	ld b,a			;901e
	ld a,01eh		;901f   ; La casilla, 0x1E bytes mas alla
	add a,l			;9021
	ld l,a			;9022
	ld e,(hl)			;9023
	inc l			;9024
	ld d,(hl)			;9025
	dec b			;9026   ; Solo el paso 1 lleva dos caracteres
	jr nz,dibuja_uno_solo		;9027
	ld a,(0e1b6h)		;9029
	add a,a			;902c   ; Por cuatro: dos parejas por pieza
	add a,a			;902d   ; Por cuatro: dos parejas
	ld hl,0905ch		;902e
	add a,l			;9031
	ld l,a			;9032
	jr nc,L_9036		;9033
	inc h			;9035
L_9036:
	ldi		;9036
	ldi		;9038
	ld a,(0e1b6h)		;903a   ; La tercera pinta ademas la fila de abajo
	cp 003h		;903d   ; La tercera lleva la fila de abajo
	ret nz			;903f   ; 0x1E: la fila de abajo
	ld a,01eh		;9040
	add a,e			;9042
	ld e,a			;9043
	jr nc,L_9047		;9044
	inc d			;9046
L_9047:
	ldi		;9047
	ldi		;9049
	ret			;904b
dibuja_uno_solo:		; Un caracter, sacado de la tabla que empieza en 0x8FE4
	ld a,l			;904c   ; 0x13 bytes atras: el dibujo
	sub 013h		;904d
	ld l,a			;904f
	ld a,(hl)			;9050
	ld hl,l8fe4h		;9051   ; La tabla que empieza en 0x8FE4
	add a,l			;9054
	ld l,a			;9055
	jr nc,L_9059		;9056
	inc h			;9058
L_9059:
	ldi		;9059
	ret			;905b

; ----------------------------------------------------------------------
; DATOS caracteres_905C: Veinticuatro bytes que lee 0x902E, en parejas.
;   0x905c..0x9074  (24 bytes)
DATA_caracteres_905C:
	defb 068h,069h,068h,069h	; 905c
	defb 062h,063h,000h,000h	; 9060
	defb 064h,065h,000h,000h	; 9064
	defb 05eh,05fh,066h,067h	; 9068
	defb 05ch,05dh,000h,000h	; 906c
	defb 05ah,05bh,000h,000h	; 9070

; ======================================================================
; CODIGO 0x9074..0x91c5  (337 bytes)
; ======================================================================


borra_las_cinco:		; Devuelve al mapa lo que habia debajo de cada una de las cinco piezas
	ld a,(0e1b0h)		;9074
	or a			;9077
	ret z			;9078
	ld hl,0eb00h		;9079
	ld a,005h		;907c   ; Cinco
	ld (0e1b6h),a		;907e
L_9081:
	push hl			;9081
	call borra_una_de_las_cinco		;9082
	ld hl,0e1b6h		;9085
	dec (hl)			;9088
	pop hl			;9089
	ld de,00020h		;908a   ; Treinta y dos bytes: la siguiente
	add hl,de			;908d
	jr nz,L_9081		;908e
	ret			;9090
borra_una_de_las_cinco:		; Copia de vuelta los dos caracteres guardados, y la tercera ademas los de la fila de abajo
	ld a,(hl)			;9091
	or a			;9092
	ret z			;9093
	ld a,01eh		;9094   ; La casilla, 0x1E bytes mas alla
	add a,l			;9096   ; 0x1E bytes mas alla: la casilla
	ld l,a			;9097   ; Doce bytes atras
	ld e,(hl)			;9098
	inc l			;9099
	ld d,(hl)			;909a
	ld a,l			;909b
	sub 00ch		;909c
	ld l,a			;909e
	ldi		;909f
	ldi		;90a1
	ld a,(0e1b6h)		;90a3   ; La tercera lleva ademas la fila de abajo
	cp 003h		;90a6
	ret nz			;90a8
	ld a,01eh		;90a9   ; 0x1E: la fila de abajo del mapa
	add a,e			;90ab   ; 0x1E: la fila de abajo
	ld e,a			;90ac   ; 0x1E: la fila de abajo
	jr nc,L_90B0		;90ad
	inc d			;90af
L_90B0:
	ldi		;90b0
	ldi		;90b2
	ret			;90b4
suelta_los_enemigos:		; Va sacando enemigos mientras el guion tenga renglones para esta distancia
	call mira_el_guion_de_enemigos		;90b5
	jr z,suelta_los_enemigos		;90b8
	ret c			;90ba
	ld hl,0e108h		;90bb
	inc (hl)			;90be   ; 0xE108: por que renglon del guion va
	jr suelta_los_enemigos		;90bf
suelta_los_enemigos_con_columna:		; Lo mismo, pero solo en los pasos que meten columna nueva
	ld a,(0e100h)		;90c1   ; Solo en los pasos con columna
	and a			;90c4
	ret z			;90c5
	ld a,0f8h		;90c6   ; 0xF8 en 0xEC04
	ld (0ec04h),a		;90c8
L_90CB:
	call mira_el_guion_de_enemigos		;90cb
	jr z,L_90CB		;90ce
	ret			;90d0
mira_el_guion_de_enemigos:		; Consulta el guion de 0x9262 y, si toca, saca un enemigo del tipo 1 en la fila y con la variante que diga
	ld a,(0e108h)		;90d1
	ld hl,09262h		;90d4   ; El guion de 0x9262
	call renglon_del_guion		;90d7
	ret nz			;90da
	ld hl,0e108h		;90db
	inc (hl)			;90de   ; Se avanza al renglon siguiente
	ld a,c			;90df
	ld (0e122h),a		;90e0   ; El byte se guarda entero en 0xE122
	and 01fh		;90e3   ; Los cinco bits bajos por ocho: la columna
	add a,a			;90e5
	add a,a			;90e6
	add a,a			;90e7
	ld e,a			;90e8
	ld a,(0ec04h)		;90e9   ; Y la fila, de 0xEC04
	ld d,a			;90ec
	xor a			;90ed
	bit 6,c		;90ee   ; Los bits 6 y 7: la variante
	jr z,L_90F8		;90f0
	inc a			;90f2
	bit 7,c		;90f3
	jr z,L_90F8		;90f5
	inc a			;90f7
L_90F8:
	ld c,a			;90f8
	ld a,001h		;90f9   ; Tipo 1
	call 06a72h		;90fb
	xor a			;90fe
	ret			;90ff
renglon_del_guion:		; Saca de la tabla de HL la lista de la fase y compara la distancia recorrida con el renglon que toca
	push af			;9100
	ld a,(0e061h)		;9101   ; La lista que le toca a la fase
	call 047aeh		;9104
	pop af			;9107
	ld c,a			;9108
	add a,a			;9109   ; Por tres: tres bytes por renglon
	add a,c			;910a
	call 04062h		;910b
	ex de,hl			;910e
	ld e,(hl)			;910f   ; La distancia del renglon...
	inc hl			;9110
	ld d,(hl)			;9111
	inc hl			;9112
	ld c,(hl)			;9113   ; ...y el byte de datos
	ld hl,(0e063h)		;9114
	rst 20h			;9117   ; DCOMPR: contra la distancia recorrida
	ret			;9118
apunta_el_canon:		; Mide el angulo hasta la nave y con el elige el dibujo del canon, sacado de la tabla de 0x9205 segun la fase
	call se_corre_con_el_scroll_ocho		;9119
	ret c			;911c
	ld e,(ix+004h)		;911d   ; La posicion del enemigo
	ld d,(ix+006h)		;9120
	call 066d5h		;9123   ; El banco 1 mide el angulo
	ld a,(0ec18h)		;9126
	cp 080h		;9129   ; Por encima de 0x80, el angulo se refleja
	jr c,L_912F		;912b
	neg		;912d
L_912F:
	ld bc,00505h		;912f
L_9132:
	sub 015h		;9132   ; Cinco tramos de 0x15
	jr c,L_9139		;9134   ; Cinco tramos de 0x15
	dec c			;9136   ; Cinco tramos
	djnz L_9132		;9137
L_9139:
	ld a,(ix+017h)		;9139
	add a,a			;913c
	add a,a			;913d
	ld e,a			;913e
	add a,a			;913f
	add a,e			;9140
	ld hl,09205h		;9141   ; La tabla de 0x9205
	call 0405dh		;9144
	ld a,(0e061h)		;9147   ; Y dentro de ella, la fila de la fase
	dec a			;914a   ; Y dentro, la fila de la fase
	call 0405dh		;914b
	ld a,(hl)			;914e
	add a,c			;914f
	ld (ix+00ch),a		;9150
	ld a,(0ec18h)		;9153
	bit 1,(ix+017h)		;9156
	jr nz,L_9163		;915a
	sub 010h		;915c   ; El bit 1 del byte 23 elige el arco de tiro
	cp 060h		;915e
	ret c			;9160
	jr este_enemigo_dispara		;9161
L_9163:
	sub 090h		;9163
	cp 060h		;9165
	ret c			;9167
este_enemigo_dispara:		; Con la nave dentro de su arco y sin otro disparo en marcha, suelta uno y recalcula la espera
	dec (ix+010h)		;9168   ; 0xE110: los cuadros que faltan para disparar
	ret nz			;916b
	ld hl,0e112h		;916c   ; 0xE112: si ya hay un disparo saliendo, se espera un cuadro
	ld a,(hl)			;916f
	and a			;9170
	jr z,L_9178		;9171
	ld (ix+010h),001h		;9173
	ret			;9177
L_9178:
	ld e,(ix+004h)		;9178   ; La posicion del enemigo, y el banco 1 monta el disparo
	ld d,(ix+006h)		;917b
	call 06613h		;917e
espera_hasta_el_disparo_siguiente:		; La espera sale de la rampa de 0x91C5, mas la dificultad y la vuelta, con suelo en 0x0C cuadros
	ld hl,091c5h		;9181
	ld a,(0e066h)		;9184   ; En la primera vuelta la dificultad se topa en 2
	dec a			;9187
	ld a,(0e111h)		;9188
	jr nz,L_9193		;918b
	cp 002h		;918d
	jr c,L_9193		;918f
	ld a,002h		;9191
L_9193:
	add a,a			;9193   ; Por cuatro: cuatro valores por escalon
	add a,a			;9194
	call 0405dh		;9195
	ld a,(ix+018h)		;9198   ; El byte 24 va rotando entre los cuatro
	inc (ix+018h)		;919b
	and 003h		;919e
	call 0405dh		;91a0
	ld a,(0e200h)		;91a3   ; Con el escudo en 3, cuatro cuadros menos
	cp 003h		;91a6
	ld a,(hl)			;91a8
	jr nz,L_91AD		;91a9
	sub 004h		;91ab
L_91AD:
	ld c,a			;91ad
	ld a,(0e066h)		;91ae   ; La vuelta partida por cuatro tambien resta
	srl a		;91b1
	srl a		;91b3
	ld b,a			;91b5
	ld a,c			;91b6
	sub b			;91b7
	jr nc,L_91BB		;91b8
	xor a			;91ba
L_91BB:
	cp 00ch		;91bb   ; Nunca menos de doce cuadros
	jr nc,L_91C1		;91bd
	ld a,00ch		;91bf
L_91C1:
	ld (ix+010h),a		;91c1
	ret			;91c4

; ----------------------------------------------------------------------
; DATOS espera_entre_disparos: Tres escalones de cuatro valores: los cuadros
;   que un enemigo espera entre disparo y disparo, segun la dificultad y por
;   que sitio de la rueda vaya. Los lee 0x9181, que ademas les resta la vuelta
;   y les pone un suelo de doce.
;   0x91c5..0x91d1  (12 bytes)
DATA_espera_entre_disparos:
	defb 060h,060h,060h,0c0h	; 91c5
	defb 050h,050h,050h,0a0h	; 91c9
	defb 040h,040h,040h,080h	; 91cd

; ----------------------------------------------------------------------
; DATOS tabla_91D1: Cincuenta y dos bytes que p00:48CB mete en BC con `ld
;   bc,0x91D1`. Ojo: con el reparto por defecto en 0x8000 esta el banco 2,
;   pero 0x48CB corre con el reparto 4/5/6, o sea que lo que lee de verdad es
;   el banco 5. Aqui queda como dato de este banco porque nadie mas lo apunta.
;   0x91d1..0x9205  (52 bytes)
DATA_tabla_91D1:
	defb 030h,030h,030h,060h	; 91d1
	defb 028h,028h,028h,050h	; 91d5
	defb 026h,026h,026h,04ch	; 91d9
	defb 024h,024h,024h,048h	; 91dd
	defb 022h,022h,022h,044h	; 91e1
	defb 020h,020h,020h,040h	; 91e5
	defb 01eh,01eh,01eh,03ch	; 91e9
	defb 01ch,01ch,01ch,038h	; 91ed
	defb 01ah,01ah,01ah,034h	; 91f1
	defb 018h,018h,018h,030h	; 91f5
	defb 016h,016h,016h,02ch	; 91f9
	defb 014h,014h,014h,028h	; 91fd
	defb 012h,012h,012h,024h	; 9201

; ----------------------------------------------------------------------
; DATOS dibujos_del_canon: Cuatro filas -una por fase- de doce dibujos: el que
;   ensena el canon segun el tramo de angulo en el que este la nave. Los lee
;   0x9141.
;   0x9205..0x9235  (48 bytes)
DATA_dibujos_del_canon:
	defb 009h,023h,00fh,000h,03fh,000h,009h,009h,023h,023h,023h,023h	; 9205  .#..?...####
	defb 00fh,009h,000h,00fh,03fh,000h,00fh,00fh,009h,009h,009h,009h	; 9211  ....?.......
	defb 000h,015h,015h,000h,039h,000h,01bh,02dh,015h,015h,015h,015h	; 921d  ....9..-....
	defb 01bh,01bh,01bh,01bh,039h,000h,01bh,01bh,01bh,01bh,01bh,01bh	; 9229  ....9.......

; ======================================================================
; CODIGO 0x9235..0x9264  (47 bytes)
; ======================================================================


dispara_sin_apuntar:		; Cuando la cuenta llega a cero suelta el disparo y calcula la velocidad con la rutina del banco 1
	dec (ix+010h)		;9235   ; 0xE110: los cuadros que faltan
	ret nz			;9238
L_9239:
	ld hl,0e112h		;9239   ; 0xE112: si ya hay uno saliendo, se espera
	ld a,(hl)			;923c
	and a			;923d
	jr z,L_9245		;923e
	ld (ix+010h),001h		;9240
	ret			;9244
L_9245:
	ld e,(ix+004h)		;9245   ; La posicion, y el banco 1 lo monta
	ld d,(ix+006h)		;9248
	call 06613h		;924b
	jp 06b84h		;924e
se_corre_con_el_scroll_ocho:		; En los pasos con columna nueva se corre ocho puntos a la izquierda; al salirse por el borde, la ranura se libera y sale con acarreo
	ld a,(0e100h)		;9251   ; Solo en los pasos con columna
	and a			;9254
	ret z			;9255
	ld a,(ix+006h)		;9256
	sub 008h		;9259   ; Ocho puntos
	ld (ix+006h),a		;925b
	ret nc			;925e
	call 05fa5h		;925f   ; Y al pasarse, la ranura se apaga
	scf			;9262
	ret			;9263

; ----------------------------------------------------------------------
; DATOS tabla_9264: Palabras que 0x90D4 indexa con 0x47AE (0x927C, 0x92B4,
;   0x933A, 0x9366, ...) y, detras, lo que apuntan.
;   0x9264..0x9510  (684 bytes)
DATA_tabla_9264:
	defw 0927ch,092b4h	; 9264
	defw 0933ah,09366h	; 9268
	defw 09389h,093b5h	; 926c
	defw 093b7h,093e6h	; 9270
	defw 09445h,09492h	; 9274
	defw 094d9h,094f9h	; 9278
	defw 0008eh,09021h	; 927c
	defw 02100h,00092h	; 9280
	defw 0ae21h,01200h	; 9284
	defw 000b0h,0c012h	; 9288
	defw 02100h,000c2h	; 928c
	defw 0d221h,01200h	; 9290
	defw 000d4h,00412h	; 9294
	defw 05201h,00106h	; 9298
	defw 00a52h,02101h	; 929c
	defw 0010ch,02221h	; 92a0
	defw 01201h,00124h	; 92a4
	defw 03a12h,02101h	; 92a8
	defw 0013ch,05821h	; 92ac
	defw 05201h,0ffffh	; 92b0
	defw 00084h,08506h	; 92b4
	defw 02a00h,00086h	; 92b8
	defw 08602h,02f00h	; 92bc
	defw 00089h,08c01h	; 92c0
	defw 00200h,0008ch	; 92c4
	defw 08d2fh,02a00h	; 92c8  -> DATA_ficha_de_la_pieza_3 0x2a00
	defw 0008eh,0a106h	; 92cc
	defw 01300h,000a3h	; 92d0
	defw 0a413h,02300h	; 92d4
	defw 000ach,0ae2eh	; 92d8
	defw 04a00h,000afh	; 92dc
	defw 0b105h,00100h	; 92e0
	defw 000b3h,0b605h	; 92e4
	defw 04a00h,000c0h	; 92e8
	defw 0c227h,04300h	; 92ec
	defw 000c8h,0c903h	; 92f0
	defw 01100h,000d2h	; 92f4
	defw 0d205h,01100h	; 92f8
	defw 000d4h,0ec05h	; 92fc
	defw 0c600h,000f2h	; 9300
	defw 0f243h,02d00h	; 9304
	defw 000fch,0fe6eh	; 9308
	defw 00300h,00104h	; 930c
	defw 00506h,02a01h	; 9310
	defw 00106h,00602h	; 9314
	defw 02f01h,0010eh	; 9318
	defw 01a06h,01301h	; 931c
	defw 0011eh,02123h	; 9320
	defw 01301h,00124h	; 9324
	defw 02c23h,06e01h	; 9328
	defw 0012eh,02f4ah	; 932c
	defw 04501h,00131h	; 9330
	defw 03341h,04501h	; 9334
	defw 0ffffh,00084h	; 9338
	defw 0946ah,06e00h	; 933c
	defw 000a0h,0a24bh	; 9340
	defw 04b00h,000c6h	; 9344
	defw 0e253h,05300h	; 9348
	defw 000e6h,0fe45h	; 934c
	defw 06900h,00114h	; 9350
	defw 01445h,06801h	; 9354
	defw 00142h,04653h	; 9358
	defw 04501h,0015ch	; 935c
	defw 07245h,04a01h	; 9360
	defw 0ffffh,00096h	; 9364
	defw 09812h,01200h	; 9368
	defw 0009ah,0a212h	; 936c
	defw 02100h,000a4h	; 9370
	defw 0b621h,01200h	; 9374
	defw 000b8h,0d612h	; 9378
	defw 02100h,000d8h	; 937c
	defw 0fa21h,01200h	; 9380
	defw 000feh,0ff12h	; 9384
	defw 0a8ffh,05200h	; 9388
	defw 000aeh,0ce61h	; 938c
	defw 06100h,000d4h	; 9390
	defw 0e452h,06100h	; 9394
	defw 000e6h,0ea61h	; 9398
	defw 05200h,000f4h	; 939c
	defw 0f652h,06100h	; 93a0
	defw 000fch,00a52h	; 93a4
	defw 05201h,0011ch	; 93a8
	defw 05261h,05201h	; 93ac
	defw 00154h,0ff52h	; 93b0
	defw 0ffffh,096ffh	; 93b4
	defw 01000h,00098h	; 93b8
	defw 0a010h,02400h	; 93bc
	defw 000b6h,0b810h	; 93c0
	defw 01000h,000f7h	; 93c4
	defw 0f924h,02400h	; 93c8
	defw 0014dh,04e24h	; 93cc
	defw 05001h,0014fh	; 93d0
	defw 05024h,05001h	; 93d4
	defw 0015ch,05c68h	; 93d8
	defw 04c01h,0015eh	; 93dc
	defw 05e68h,04c01h	; 93e0
	defw 0ffffh,00041h	; 93e4
	defw 04323h,02300h	; 93e8
	defw 00047h,0490fh	; 93ec
	defw 00f00h,00054h	; 93f0
	defw 05665h,02500h	; 93f4
	defw 0005bh,05f11h	; 93f8
	defw 01100h,00075h	; 93fc
	defw 0770fh,00f00h	; 9400
	defw 0007ch,07e23h	; 9404
	defw 02300h,0009fh	; 9408
	defw 09f23h,05100h	; 940c
	defw 000b5h,0b70fh	; 9410
	defw 00f00h,000bch	; 9414
	defw 0be23h,02300h	; 9418
	defw 000dbh,0dd4dh	; 941c
	defw 0e300h,000f5h	; 9420
	defw 0f70fh,00f00h	; 9424
	defw 000fdh,0ff23h	; 9428
	defw 06300h,0010eh	; 942c
	defw 00e6bh,04d01h	; 9430
	defw 00110h,0106bh	; 9434
	defw 04d01h,00141h	; 9438
	defw 05023h,06301h	; 943c
	defw 00158h,0ff23h	; 9440
	defw 023ffh,01300h	; 9444
	defw 00024h,02662h	; 9448
	defw 06200h,00029h	; 944c
	defw 02c6ah,06200h	; 9450
	defw 0002dh,02f4dh	; 9454
	defw 04600h,0002fh	; 9458
	defw 0314dh,06900h	; 945c
	defw 00038h,0396eh	; 9460
	defw 04500h,0003bh	; 9464
	defw 05d45h,03000h	; 9468
	defw 00085h,08d31h	; 946c
	defw 03100h,0008fh	; 9470
	defw 09631h,01300h	; 9474
	defw 000afh,0d811h	; 9478
	defw 04e00h,000ddh	; 947c
	defw 0e245h,04500h	; 9480
	defw 000f9h,0fb13h	; 9484
	defw 02100h,000fbh	; 9488
	defw 0fd13h,02100h	; 948c
	defw 0ffffh,00024h	; 9490
	defw 02562h,00f00h	; 9494
	defw 00025h,02632h	; 9498
	defw 06200h,0002ah	; 949c
	defw 02f10h,06100h	; 94a0
	defw 00031h,03561h	; 94a4
	defw 01000h,00039h	; 94a8
	defw 0390fh,03200h	; 94ac
	defw 0003bh,04362h	; 94b0
	defw 03000h,00050h	; 94b4
	defw 05365h,04d00h	; 94b8
	defw 00059h,07130h	; 94bc
	defw 03100h,00073h	; 94c0
	defw 07531h,01300h	; 94c4
	defw 00085h,0854dh	; 94c8
	defw 01300h,0008fh	; 94cc
	defw 0944dh,01200h	; 94d0
	defw 000a7h,0ff31h	; 94d4
	defw 02affh,02600h	; 94d8
	defw 00066h,0682eh	; 94dc
	defw 02e00h,00088h	; 94e0
	defw 09413h,02e00h	; 94e4
	defw 00098h,0ab26h	; 94e8
	defw 02d00h,000afh	; 94ec
	defw 0b105h,03100h	; 94f0
	defw 000bah,0ff06h	; 94f4
	defw 009ffh,04301h	; 94f8
	defw 0010bh,00d6eh	; 94fc
	defw 04201h,00111h	; 9500
	defw 01342h,06e01h	; 9504
	defw 00115h,07d43h	; 9508
	defw 01301h,0ffffh	; 950c

; ======================================================================
; CODIGO 0x9510..0x9529  (25 bytes)
; ======================================================================


pon_la_velocidad_a_cero:		; Las dos velocidades del objeto, a cero
	xor a			;9510
	ld d,a			;9511
	ld e,a			;9512
	call 06cc6h		;9513   ; Las dos velocidades a cero
	jp 06cbfh		;9516
pon_la_aceleracion_al_reves:		; Complemento a dos de la aceleracion vertical y a guardarla
	ld e,(ix+017h)		;9519
	ld d,(ix+018h)		;951c
	call 06729h		;951f
pon_la_aceleracion_vertical:		; Los bytes 23 y 24
	ld (ix+017h),e		;9522
	ld (ix+018h),d		;9525
	ret			;9528

; ----------------------------------------------------------------------
; DATOS fragmento_muerto: Siete bytes que son `ld (ix+0x19),e / ld (ix+0x1A),d
;   / ret`. Nadie llega: ni un salto ni una tabla apuntan a 0x9529.
;   0x9529..0x9530  (7 bytes)
DATA_fragmento_muerto:
	defb 0ddh,073h,019h,0ddh,072h,01ah,0c9h	; 9529

; ======================================================================
; CODIGO 0x9530..0x9657  (295 bytes)
; ======================================================================


pon_la_aceleracion_horizontal:		; Los bytes 25 y 26; si viene en negativo, se le da la vuelta
	ld a,d			;9530
	or a			;9531
	call m,06729h		;9532
L_9535:
	ld (ix+019h),e		;9535
	ld (ix+01ah),d		;9538
	ret			;953b
suma_la_aceleracion_vertical:		; Los bytes 23 y 24 se le suman a la velocidad de los bytes 7 y 8
	ld l,(ix+007h)		;953c   ; La velocidad vertical...
	ld h,(ix+008h)		;953f
	ld e,(ix+017h)		;9542   ; ...mas su aceleracion
	ld d,(ix+018h)		;9545
	add hl,de			;9548
	ld (ix+007h),l		;9549
	ld (ix+008h),h		;954c
	ret			;954f
suma_la_aceleracion_horizontal:		; Y lo mismo con los bytes 25 y 26 sobre los 9 y 10
	ld l,(ix+009h)		;9550   ; La velocidad horizontal...
	ld h,(ix+00ah)		;9553
	ld e,(ix+019h)		;9556   ; ...mas su aceleracion
	ld d,(ix+01ah)		;9559
	add hl,de			;955c
	ld (ix+009h),l		;955d
	ld (ix+00ah),h		;9560
	ret			;9563
compara_velocidad_y_aceleracion:		; La velocidad vertical, en valor absoluto, contra la aceleracion horizontal
	ld e,(ix+007h)		;9564   ; La velocidad vertical, en valor absoluto
	ld d,(ix+008h)		;9567
	ld a,d			;956a
	or a			;956b
	call m,06729h		;956c
	ld l,(ix+019h)		;956f   ; Contra la aceleracion horizontal
	ld h,(ix+01ah)		;9572
	rst 20h			;9575
	ret			;9576
pon_la_velocidad_horizontal_desde_la_aceleracion:
	ld e,(ix+019h)		;9577
	ld d,(ix+01ah)		;957a
	jp 06cbfh		;957d
cambia_el_signo_de_la_velocidad_horizontal:
	ld e,(ix+009h)		;9580   ; Los bytes 9 y 10, del reves
	ld d,(ix+00ah)		;9583
	call 06729h		;9586
	ld (ix+009h),e		;9589
	ld (ix+00ah),d		;958c
	ret			;958f
cambia_el_signo_de_la_velocidad_vertical:
	ld e,(ix+007h)		;9590   ; Los bytes 7 y 8, del reves
	ld d,(ix+008h)		;9593   ; DCOMPR: contra la distancia recorrida
	call 06729h		;9596
	ld (ix+007h),e		;9599
	ld (ix+008h),d		;959c
	ret			;959f
uno_de_cada_treinta_y_dos:		; Los cinco bits bajos del contador de cuadros
	ld a,(0e003h)		;95a0
	and 01fh		;95a3
	ret			;95a5
le_toca_moverse:		; Cada 0x20 cuadros baja el byte 28; al llegar a cero, sale con acarreo
	call uno_de_cada_treinta_y_dos		;95a6   ; Uno de cada 0x20 cuadros
	jr nz,ha_llegado_al_final		;95a9
	dec (ix+01ch)		;95ab   ; El byte 28 baja
	jr nz,ha_llegado_al_final		;95ae
	scf			;95b0
	ret			;95b1
ha_llegado_al_final:		; Compara la distancia recorrida con el final del tramo; en la fase 1 con 0x10 de margen
	ld a,(0e061h)		;95b2
	dec a			;95b5   ; La fase 1 lleva 0x10 de margen
	jr nz,L_95C7		;95b6
	ld hl,(0e103h)		;95b8
	ld de,00010h		;95bb
	or a			;95be
	sbc hl,de		;95bf
	ld de,(0e063h)		;95c1
	rst 20h			;95c5   ; DCOMPR: contra la distancia recorrida
	ret			;95c6
L_95C7:
	ld hl,(0e103h)		;95c7
	dec hl			;95ca
	ld de,(0e063h)		;95cb
	rst 20h			;95cf
	ret			;95d0
anima_en_redondo:		; Cada tantos cuadros -mascara en B- avanza el dibujo en redondo hasta C y lo saca de la tabla de HL
	ld a,(0e003h)		;95d1   ; La mascara de B: cada cuantos cuadros
	and b			;95d4
	ret nz			;95d5
	ld a,(ix+01dh)		;95d6   ; El byte 29: por que dibujo va
	inc a			;95d9
	cp c			;95da   ; Al llegar a C, vuelta a empezar
	jr c,L_95DE		;95db   ; Al llegar a C, vuelta a empezar
	xor a			;95dd   ; Se apunta el dibujo
L_95DE:
	ld (ix+01dh),a		;95de
	add a,l			;95e1
	ld l,a			;95e2
	jr nc,L_95E6		;95e3
	inc h			;95e5
L_95E6:
	ld a,(hl)			;95e6
	ld (ix+00ch),a		;95e7
	ret			;95ea

; ----------------------------------------------------------------------
; LA ACELERACION HACIA LA NAVE SALE DE UNA TABLA DE 256 PALABRAS
; Para que un objeto se vaya curvando hacia la nave hace falta la
; aceleracion vertical y la horizontal, y aqui no se calculan: se miran. Se cogen las dos
; diferencias en valor absoluto, se junta el nibble alto de una con el alto
; de la otra en un solo byte, y ese byte -por dos- indexa la tabla de
; 0x9657, que son 256 palabras. Se lee dos veces, cruzando los nibbles, y
; con eso salen las dos componentes; el signo lo pone el complemento a dos.
; ----------------------------------------------------------------------
apunta_la_aceleracion:		; Las dos diferencias hasta la nave, en valor absoluto, dan el indice de la tabla de 0x9657: de ahi salen las dos aceleraciones
	ld b,000h		;95eb
	ld a,(0e206h)		;95ed   ; 0xE206: la columna de la nave
	ld d,a			;95f0
	ld a,(ix+006h)		;95f1
	sub d			;95f4
	jr nc,L_95FA		;95f5
	neg		;95f7   ; En negativo, se apunta el signo
	inc b			;95f9
L_95FA:
	ld h,a			;95fa
	ld c,000h		;95fb
	ld a,(0e204h)		;95fd   ; Y 0xE204: su fila
	ld d,a			;9600
	ld a,(ix+004h)		;9601
	sub d			;9604
	jr nc,L_960A		;9605
	neg		;9607
	inc c			;9609
L_960A:
	ld l,a			;960a
	rra			;960b   ; El nibble alto de una y el alto de la otra
	rra			;960c   ; El nibble alto de la distancia en X
	rra			;960d   ; Los cuatro bits altos
	rra			;960e
	and 00fh		;960f
	ld e,a			;9611
	ld a,h			;9612
	and 0f0h		;9613
	or e			;9615
	ld e,a			;9616
	ld d,000h		;9617
	sla e		;9619
	rl d		;961b
	push hl			;961d
	ld hl,09657h		;961e   ; La tabla de 0x9657, por dos
	add hl,de			;9621
	ld e,(hl)			;9622
	inc hl			;9623
	ld d,(hl)			;9624
	bit 0,b		;9625   ; Y el signo, con el complemento a dos
	call z,06729h		;9627
	ld (ix+019h),e		;962a   ; Los bytes 25 y 26: la aceleracion horizontal
	ld (ix+01ah),d		;962d
	pop hl			;9630
	ld a,h			;9631   ; Ahora al reves: los nibbles cruzados
	rra			;9632   ; Los nibbles cruzados
	rra			;9633   ; El nibble alto de una y el bajo de la otra
	rra			;9634
	rra			;9635
	and 00fh		;9636
	ld e,a			;9638
	ld a,l			;9639
	and 0f0h		;963a
	or e			;963c
	ld e,a			;963d
	ld d,000h		;963e
	sla e		;9640
	rl d		;9642
	ld hl,09657h		;9644
	add hl,de			;9647
	ld e,(hl)			;9648
	inc hl			;9649
	ld d,(hl)			;964a
	bit 0,c		;964b
	call z,06729h		;964d
	ld (ix+017h),e		;9650   ; Y los bytes 23 y 24: la vertical
	ld (ix+018h),d		;9653
	ret			;9656

; ----------------------------------------------------------------------
; DATOS aceleracion_hacia_la_nave: Doscientas cincuenta y seis palabras que
;   0x961E y 0x9644 indexan con los nibbles altos de las dos distancias a la
;   nave: la aceleracion con la que un objeto se curva hacia ella. Con una
;   sola tabla se sacan las dos componentes, leyendola dos veces con los
;   nibbles cruzados.
;   0x9657..0x9857  (512 bytes)
DATA_aceleracion_hacia_la_nave:
	defw 000c0h,00000h	; 9657
	defw 00000h,00000h	; 965b
	defw 00000h,00000h	; 965f
	defw 00000h,00000h	; 9663
	defw 00000h,00000h	; 9667
	defw 00000h,00000h	; 966b
	defw 00000h,00000h	; 966f
	defw 00000h,00000h	; 9673
	defw 000c0h,00060h	; 9677
	defw 00026h,00013h	; 967b
	defw 0000bh,00007h	; 967f
	defw 00005h,00003h	; 9683
	defw 00002h,00002h	; 9687
	defw 00001h,00001h	; 968b
	defw 00001h,00001h	; 968f
	defw 00000h,00000h	; 9693
	defw 00030h,00026h	; 9697
	defw 00018h,0000eh	; 969b
	defw 00009h,00006h	; 969f
	defw 00004h,00003h	; 96a3
	defw 00002h,00002h	; 96a7
	defw 00001h,00001h	; 96ab
	defw 00001h,00001h	; 96af
	defw 00000h,00000h	; 96b3
	defw 00015h,00013h	; 96b7
	defw 0000eh,0000ah	; 96bb
	defw 00007h,00005h	; 96bf
	defw 00004h,00003h	; 96c3
	defw 00002h,00002h	; 96c7
	defw 00001h,00001h	; 96cb
	defw 00001h,00001h	; 96cf
	defw 00000h,00000h	; 96d3
	defw 0000ch,0000bh	; 96d7
	defw 00009h,00007h	; 96db
	defw 00006h,00004h	; 96df
	defw 00003h,00002h	; 96e3
	defw 00002h,00001h	; 96e7
	defw 00001h,00001h	; 96eb
	defw 00001h,00001h	; 96ef
	defw 00000h,00000h	; 96f3
	defw 00007h,00007h	; 96f7
	defw 00006h,00005h	; 96fb
	defw 00004h,00003h	; 96ff
	defw 00003h,00002h	; 9703
	defw 00002h,00001h	; 9707
	defw 00001h,00001h	; 970b
	defw 00001h,00000h	; 970f
	defw 00000h,00000h	; 9713
	defw 00005h,00005h	; 9717
	defw 00004h,00004h	; 971b
	defw 00003h,00003h	; 971f
	defw 00002h,00002h	; 9723
	defw 00001h,00001h	; 9727
	defw 00001h,00001h	; 972b
	defw 00001h,00000h	; 972f
	defw 00000h,00000h	; 9733
	defw 00003h,00003h	; 9737
	defw 00003h,00003h	; 973b
	defw 00002h,00002h	; 973f
	defw 00002h,00001h	; 9743
	defw 00001h,00001h	; 9747
	defw 00001h,00001h	; 974b
	defw 00000h,00000h	; 974f
	defw 00000h,00000h	; 9753
	defw 00003h,00002h	; 9757
	defw 00002h,00002h	; 975b
	defw 00002h,00002h	; 975f
	defw 00001h,00001h	; 9763
	defw 00001h,00001h	; 9767
	defw 00001h,00001h	; 976b
	defw 00000h,00000h	; 976f
	defw 00000h,00000h	; 9773
	defw 00002h,00002h	; 9777
	defw 00002h,00002h	; 977b
	defw 00001h,00001h	; 977f
	defw 00001h,00001h	; 9783
	defw 00001h,00001h	; 9787
	defw 00001h,00000h	; 978b
	defw 00000h,00000h	; 978f
	defw 00000h,00000h	; 9793
	defw 00001h,00001h	; 9797
	defw 00001h,00001h	; 979b
	defw 00001h,00001h	; 979f
	defw 00001h,00001h	; 97a3
	defw 00001h,00001h	; 97a7
	defw 00000h,00000h	; 97ab
	defw 00000h,00000h	; 97af
	defw 00000h,00000h	; 97b3
	defw 00001h,00001h	; 97b7
	defw 00001h,00001h	; 97bb
	defw 00001h,00001h	; 97bf
	defw 00001h,00001h	; 97c3
	defw 00001h,00000h	; 97c7
	defw 00000h,00000h	; 97cb
	defw 00000h,00000h	; 97cf
	defw 00000h,00000h	; 97d3
	defw 00001h,00001h	; 97d7
	defw 00001h,00001h	; 97db
	defw 00001h,00001h	; 97df
	defw 00001h,00000h	; 97e3
	defw 00000h,00000h	; 97e7
	defw 00000h,00000h	; 97eb
	defw 00000h,00000h	; 97ef
	defw 00000h,00000h	; 97f3
	defw 00001h,00001h	; 97f7
	defw 00001h,00001h	; 97fb
	defw 00001h,00000h	; 97ff
	defw 00000h,00000h	; 9803
	defw 00000h,00000h	; 9807
	defw 00000h,00000h	; 980b
	defw 00000h,00000h	; 980f
	defw 00000h,00000h	; 9813
	defw 00000h,00000h	; 9817
	defw 00000h,00000h	; 981b
	defw 00000h,00000h	; 981f
	defw 00000h,00000h	; 9823
	defw 00000h,00000h	; 9827
	defw 00000h,00000h	; 982b
	defw 00000h,00000h	; 982f
	defw 00000h,00000h	; 9833
	defw 00000h,00000h	; 9837
	defw 00000h,00000h	; 983b
	defw 00000h,00000h	; 983f
	defw 00000h,00000h	; 9843
	defw 00000h,00000h	; 9847
	defw 00000h,00000h	; 984b
	defw 00000h,00000h	; 984f
	defw 00000h,00000h	; 9853

; ======================================================================
; CODIGO 0x9857..0x99e5  (398 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; CHOCAR CON EL MAPA ES MIRAR QUE CARACTER HAY DEBAJO
; No hay ninguna lista de paredes: para saber si algo choca con el terreno
; se mira el CARACTER que el mapa tiene en esa casilla. Por debajo del 0x77
; es fondo y no choca; de ahi para arriba, cada fase decide con que tramo
; de caracteres se choca (0x9912, 0x991D, 0x9923 y 0x9929).
; ----------------------------------------------------------------------
choca_con_el_mapa:		; Mira el caracter de la casilla y el de al lado; devuelve acarreo si alguno es pared
	call 0571bh		;9857   ; De la posicion sale la casilla del mapa
	ex de,hl			;985a
	call L_9864		;985b
	ret c			;985e
	inc de			;985f   ; Y la casilla de al lado, si no se sale de la fila
	ld a,e			;9860
	and 01fh		;9861
	ret z			;9863
L_9864:
	ld a,(de)			;9864
	and a			;9865
	ret z			;9866
	cp 077h		;9867   ; Por debajo del 0x77 es fondo
	ret c			;9869
	ld c,a			;986a
	ld a,(0e061h)		;986b   ; En la fase 1 chocan solo dos caracteres
	dec a			;986e
	jp z,pared_de_la_fase_1		;986f
	sub 002h		;9872   ; Y en la 3, un tramo entero
	jp z,pared_de_la_fase_3		;9874
	xor a			;9877
	ret			;9878
choca_con_el_mapa_2:		; Igual, pero solo la fase 4 tiene pared
	call 0571bh		;9879   ; De la posicion sale la casilla
	ex de,hl			;987c
	call L_9886		;987d
	ret c			;9880
	inc de			;9881
	ld a,e			;9882
	and 01fh		;9883
	ret z			;9885
L_9886:
	ld a,(de)			;9886   ; El caracter de la casilla
	and a			;9887
	ret z			;9888
	cp 077h		;9889   ; Por debajo del 0x77 es fondo
	ret c			;988b
	ld c,a			;988c
	ld a,(0e061h)		;988d
	sub 003h		;9890
	jp z,pared_de_la_fase_3		;9892
	xor a			;9895
	ret			;9896
choca_con_el_mapa_3:		; Igual, pero ninguna fase tiene pared: solo mira que no sea fondo
	call 0571bh		;9897   ; De la posicion sale la casilla
	ex de,hl			;989a
	call L_98A4		;989b
	ret c			;989e
	inc de			;989f
	ld a,e			;98a0
	and 01fh		;98a1
	ret z			;98a3
L_98A4:
	ld a,(de)			;98a4   ; El caracter de la casilla
	and a			;98a5
	ret z			;98a6
	cp 077h		;98a7   ; Por debajo del 0x77 es fondo
	ret c			;98a9
	xor a			;98aa
	ret			;98ab
choca_con_el_mapa_del_objeto:		; Lo mismo tomando la posicion del objeto que apunte IX
	ld l,(ix+004h)		;98ac   ; La posicion del objeto
	ld h,(ix+006h)		;98af
	call 0571bh		;98b2   ; De ahi sale la casilla del mapa
	ex de,hl			;98b5   ; El caracter de la casilla
	ld a,(de)			;98b6   ; El caracter de la casilla
	and a			;98b7
	ret z			;98b8
	cp 077h		;98b9
	ret c			;98bb
	ld c,a			;98bc
	ld a,(0e061h)		;98bd
	dec a			;98c0
	jr z,pared_de_la_fase_1		;98c1
	sub 002h		;98c3
	jr z,pared_de_la_fase_3		;98c5
	xor a			;98c7
	ret			;98c8
choca_en_esta_casilla:		; La casilla ya viene en DE
	ld a,(de)			;98c9   ; El caracter de la casilla
	and a			;98ca
	ret z			;98cb
	cp 077h		;98cc   ; Por debajo del 0x77 es fondo
	ret c			;98ce
	ld c,a			;98cf
	ld a,(0e061h)		;98d0
	sub 003h		;98d3
	jp z,pared_de_la_fase_3		;98d5
	xor a			;98d8
	ret			;98d9
choca_la_nave:		; Mira las dos casillas por las que pasa la nave: la de su punto y la de al lado
	ld ix,0e200h		;98da   ; 0xE200: la ficha de la nave
	ld a,(ix+004h)		;98de   ; Ocho a la derecha de su X
	add a,008h		;98e1
	ld l,a			;98e3
	ld a,(ix+006h)		;98e4
	ld h,a			;98e7
	and 007h		;98e8   ; Los tres bits bajos de la Y: si esta a caballo de dos filas
	cp 004h		;98ea   ; Los tres bits bajos de la Y
	push af			;98ec   ; A caballo de dos filas
	call 0571bh		;98ed
	ex de,hl			;98f0
	pop af			;98f1
	jr nc,L_98F8		;98f2
	call L_98FF		;98f4
	ret c			;98f7
L_98F8:
	inc de			;98f8
	call L_98FF		;98f9
	ret c			;98fc
	xor a			;98fd
	ret			;98fe
L_98FF:
	ld a,(de)			;98ff   ; La casilla del mapa
	and a			;9900
	ret z			;9901
	cp 077h		;9902
	ret c			;9904
	ld c,a			;9905   ; El caracter se guarda en C
	ld a,(0e061h)		;9906
	sub 003h		;9909
	jr z,pared_de_la_fase_4		;990b
	dec a			;990d
	jr z,pared_de_la_fase_5		;990e
	xor a			;9910
	ret			;9911
pared_de_la_fase_1:		; Solo los caracteres 0xA2 y 0xA5
	ld a,c			;9912   ; El caracter 0xA2...
	cp 0a2h		;9913
	scf			;9915
	ret z			;9916
	cp 0a5h		;9917   ; ...y el 0xA5
	scf			;9919   ; El caracter 0xA5
	ret z			;991a   ; Ninguno mas
	xor a			;991b
	ret			;991c
pared_de_la_fase_4:		; Del 0xA1 al 0xBB
	ld a,c			;991d
	sub 0a1h		;991e
	cp 01bh		;9920
	ret			;9922
pared_de_la_fase_3:		; Del 0xA1 al 0xA5
	ld a,c			;9923
	sub 0a1h		;9924
	cp 005h		;9926
	ret			;9928
pared_de_la_fase_5:		; Del 0xBA al 0xC5
	ld a,c			;9929
	sub 0bah		;992a
	cp 00ch		;992c
	ret			;992e
es_casilla_especial:		; En las fases 2, 7 y de la 9 en adelante hay caracteres que no son pared pero cuentan: devuelve cual en C
	ld a,(0e061h)		;992f   ; 0xE061: la fase
	cp 002h		;9932   ; La fase 2 lleva un grupo
	jr z,L_9940		;9934
	cp 007h		;9936
	jr z,L_994D		;9938
	cp 009h		;993a
	jr nc,L_9940		;993c
	xor a			;993e
	ret			;993f
L_9940:
	ld a,(0e151h)		;9940   ; Con el jefe en pantalla, no
	and a			;9943
	ret nz			;9944
	ld c,005h		;9945   ; El grupo 5: los caracteres 0x44 y 0x45
	ld a,(de)			;9947
	sub 044h		;9948
	cp 001h		;994a
	ret			;994c
L_994D:
	ld c,004h		;994d   ; Y el grupo 4: del 0x61 al 0x63
	ld a,(de)			;994f
	sub 061h		;9950
	cp 002h		;9952
	ret			;9954

; ----------------------------------------------------------------------
; EL DIBUJO DE LA NAVE SALE DE LO QUE SE ESTA PULSANDO
; La nave no tiene animacion: su dibujo es una funcion de los dos bits
; bajos del mando -arriba y abajo-, que indexan una tabla de fichas de
; cuatro bytes. Y hay tres tablas distintas segun con quien se juegue: la
; normal, y otras dos que solo se usan si 0xF0F4 esta puesto, o sea si al
; arrancar se encontro el otro cartucho de Konami en la maquina.
; ----------------------------------------------------------------------
coloca_la_nave:		; Pone la ficha de sprite de la nave: la posicion, y el dibujo que le toque a lo que se este pulsando
	ld a,(0e1c0h)		;9955   ; Con la pantalla parada, no
	and a			;9958
	ret nz			;9959
	ld a,(0e200h)		;995a   ; 0xE200 a cero o en negativo: no hay nave
	or a			;995d
	ret z			;995e
	jp m,pasa_al_estado_siguiente_de_la_nave		;995f
	ld a,(0e1d0h)		;9962   ; Con explosion en marcha, la posicion sale de 0xE1D3
	and a			;9965
	jr z,L_9974		;9966
	ld de,(0e1d3h)		;9968
	ld hl,0e205h		;996c
	call suma_de_a_la_palabra		;996f
	jr L_998C		;9972
L_9974:
	call velocidad_del_mando		;9974   ; La velocidad del mando, los escalones y la posicion nueva
	call por_los_escalones_de_velocidad		;9977
	ld hl,0e203h		;997a   ; Los topes de la pantalla
	call suma_de_a_la_palabra		;997d   ; La posicion nueva
	call topa_la_y_de_la_nave		;9980
	inc l			;9983
	ld d,b			;9984
	ld e,c			;9985
	call suma_de_a_la_palabra		;9986
	call topa_la_x_de_la_nave		;9989
L_998C:
	ld a,(0f0f4h)		;998c   ; 0xF0F4: con el otro cartucho puesto, otras tablas
	or a			;998f
	ld hl,099e3h		;9990
	jr z,L_99A1		;9993
	ld a,(0e002h)		;9995   ; Y el bit 7 de 0xE002 elige entre las dos
	add a,a			;9998
	ld hl,09a25h		;9999
	jr nc,L_99A1		;999c
	ld hl,09a67h		;999e
L_99A1:
	ld a,(0e200h)		;99a1   ; 0xE200: el estado de la nave
	call 047aeh		;99a4
	ex de,hl			;99a7
	ld de,0e207h		;99a8
	ld bc,0e009h		;99ab   ; 0xE009 es el mando; en pausa, 0xE10D
	ld a,(0e10bh)		;99ae
	rra			;99b1
	jr nc,L_99B7		;99b2
	ld bc,0e10dh		;99b4
L_99B7:
	ld a,(bc)			;99b7
	and 003h		;99b8   ; Los dos bits bajos: arriba y abajo
	cp 003h		;99ba
	jp nz,L_99C0		;99bc
	xor a			;99bf
L_99C0:
	add a,a			;99c0   ; Por cuatro: cuatro bytes por ficha
	add a,a			;99c1
	ex af,af'			;99c2
	ld a,(0e200h)		;99c3
	dec a			;99c6
	jp z,L_99D6		;99c7
	ld a,(0e003h)		;99ca   ; Con la nave recien salida, parpadea cada cuatro cuadros
	and 004h		;99cd   ; Un bit del contador: parpadea
	jp z,L_99D6		;99cf   ; Uno de cada cuatro cuadros
	ex af,af'			;99d2
	add a,00ch		;99d3
	ex af,af'			;99d5
L_99D6:
	ex af,af'			;99d6
	add a,l			;99d7
	ld l,a			;99d8
	jr nc,L_99DC		;99d9
	inc h			;99db
L_99DC:
	ldi		;99dc   ; Los cuatro bytes de la ficha de sprite
	ldi		;99de
	ldi		;99e0
	ldi		;99e2
	ret			;99e4

; ----------------------------------------------------------------------
; DATOS tabla_99E3 (tramo): Sesenta y seis bytes que lee 0x9990.
;   0x99e5..0x9a25  (64 bytes)  de 0x99e3..0x9a25 (66 bytes)
DATA_tabla_99E3_99E5:
	defb 0ebh,099h,0f7h,099h,00fh,09ah,000h,00fh,004h,008h,010h,00fh,014h,005h,008h,00fh	; 99e5  ................
	defb 00ch,008h,000h,00fh,03ch,006h,000h,00fh,03ch,006h,008h,00fh,034h,006h,000h,00fh	; 99f5  ....<...<...4...
	defb 040h,009h,000h,00fh,040h,009h,008h,00fh,038h,009h,000h,00fh,02ch,00fh,000h,00fh	; 9a05  @...@...8...,...
	defb 02ch,00fh,008h,00fh,024h,00fh,000h,00fh,030h,007h,000h,00fh,030h,007h,008h,00fh	; 9a15  ,...$...0...0...

; ----------------------------------------------------------------------
; DATOS tabla_9A25: Sesenta y seis bytes que lee 0x9999.
;   0x9a25..0x9a67  (66 bytes)
DATA_tabla_9A25:
	defb 028h,007h,02dh,09ah,039h,09ah,051h,09ah,000h,007h,004h,00bh,000h,007h,004h,00bh	; 9a25  (.-.9.Q.........
	defb 000h,007h,004h,00bh,008h,007h,03ch,00bh,008h,007h,03ch,00bh,008h,007h,034h,00bh	; 9a35  ......<...<...4.
	defb 008h,007h,040h,00fh,008h,007h,040h,00fh,008h,007h,038h,00fh,008h,007h,02ch,00bh	; 9a45  ..@...@...8...,.
	defb 008h,007h,02ch,00bh,008h,007h,024h,00bh,008h,007h,030h,00fh,008h,007h,030h,00fh	; 9a55  ..,...$...0...0.
	defb 008h,007h	; 9a65

; ----------------------------------------------------------------------
; DATOS tabla_9A67: Sesenta y ocho bytes que lee 0x999E.
;   0x9a67..0x9aab  (68 bytes)
DATA_tabla_9A67:
	defb 028h,00fh,06fh,09ah,07bh,09ah,093h,09ah,000h,00dh,004h,00bh,000h,00dh,004h,00bh	; 9a67  (.o.{...........
	defb 000h,00dh,004h,00bh,008h,00dh,03ch,00bh,008h,00dh,03ch,00bh,008h,00dh,034h,00bh	; 9a77  ......<...<...4.
	defb 008h,00dh,040h,00fh,008h,00dh,040h,00fh,008h,00dh,038h,00fh,008h,00dh,02ch,00bh	; 9a87  ..@...@...8...,.
	defb 008h,00dh,02ch,00bh,008h,00dh,024h,00bh,008h,00dh,030h,00fh,008h,00dh,030h,00fh	; 9a97  ..,...$...0...0.
	defb 008h,00dh,028h,00fh	; 9aa7

; ======================================================================
; CODIGO 0x9aab..0x9b0d  (98 bytes)
; ======================================================================


topa_la_x_de_la_nave:		; La X se queda entre 0x08 y 0xD8
	cp 008h		;9aab   ; Por la izquierda, 0x08
	jp nc,L_9AB2		;9aad
	ld a,008h		;9ab0
L_9AB2:
	cp 0d9h		;9ab2   ; Y por la derecha, 0xD8
	jp c,L_9AB9		;9ab4
	ld a,0d8h		;9ab7
L_9AB9:
	ld (hl),a			;9ab9
	ret			;9aba
topa_la_y_de_la_nave:		; La Y se queda entre 0x13 y 0xB5, salvo en las fases 2, 6 y de la 9 en adelante, que empiezan en 0x10
	add a,010h		;9abb
	ex af,af'			;9abd
	ld a,(0e061h)		;9abe   ; Las fases 2, 6 y de la 9 en adelante llevan otro techo
	cp 002h		;9ac1   ; Las fases 2, 6 y de la 9 en adelante
	jp z,L_9AE3		;9ac3
	cp 006h		;9ac6
	jp z,L_9AE3		;9ac8
	cp 009h		;9acb
	jp nc,L_9AE3		;9acd
	ex af,af'			;9ad0
	cp 013h		;9ad1   ; Por arriba, 0x13
	jp nc,L_9AD8		;9ad3
	ld a,013h		;9ad6
L_9AD8:
	cp 0b6h		;9ad8   ; Y por abajo, 0xB5
	jp c,L_9ADF		;9ada
	ld a,0b5h		;9add
L_9ADF:
	sub 010h		;9adf
	ld (hl),a			;9ae1
	ret			;9ae2
L_9AE3:
	ex af,af'			;9ae3
	cp 010h		;9ae4   ; En las otras fases, el techo es 0x10
	jp nc,L_9AEB		;9ae6
	ld a,010h		;9ae9
L_9AEB:
	jp L_9AD8		;9aeb
suma_de_a_la_palabra:		; Suma DE a la palabra de 16 bits que hay en HL
	ld a,(hl)			;9aee   ; El byte bajo...
	add a,e			;9aef
	ld (hl),a			;9af0
	inc l			;9af1
	ld a,(hl)			;9af2   ; ...y el alto con el acarreo
	adc a,d			;9af3
	ld (hl),a			;9af4
	ret			;9af5

; ----------------------------------------------------------------------
; LAS DIECISEIS DIRECCIONES DEL MANDO, EN UNA TABLA
; Los cuatro bits de direccion del mando no se leen uno a uno: los dieciseis
; valores posibles indexan la tabla de 0x9B0D, cuatro bytes cada uno, y de
; ahi salen las dos velocidades de la nave ya hechas. Asi las diagonales no
; cuestan ni una instruccion mas que las rectas.
; ----------------------------------------------------------------------
velocidad_del_mando:		; Los cuatro bits de direccion indexan la tabla de 0x9B0D: de ahi salen las dos velocidades de la nave
	ld a,(0e009h)		;9af6   ; Los cuatro bits de direccion
	and 00fh		;9af9
	add a,a			;9afb   ; Por cuatro: cuatro bytes por direccion
	add a,a			;9afc
	ld hl,09b0dh		;9afd
	add a,l			;9b00
	ld l,a			;9b01
	jr nc,L_9B05		;9b02
	inc h			;9b04
L_9B05:
	ld e,(hl)			;9b05   ; La velocidad vertical...
	inc hl			;9b06
	ld d,(hl)			;9b07
	inc hl			;9b08
	ld c,(hl)			;9b09   ; ...y la horizontal
	inc hl			;9b0a
	ld b,(hl)			;9b0b
	ret			;9b0c

; ----------------------------------------------------------------------
; DATOS velocidades_del_mando: Dieciseis fichas de cuatro bytes, una por cada
;   combinacion de los cuatro bits de direccion del mando: las dos velocidades
;   de 16 bits con las que se mueve la nave. Las lee 0x9AFD.
;   0x9b0d..0x9b4d  (64 bytes)
DATA_velocidades_del_mando:
	defb 000h,000h,000h,000h	; 9b0d
	defb 080h,0ffh,000h,000h	; 9b11
	defb 080h,000h,000h,000h	; 9b15
	defb 000h,000h,000h,000h	; 9b19
	defb 000h,000h,080h,0ffh	; 9b1d
	defb 080h,0ffh,080h,0ffh	; 9b21
	defb 080h,000h,080h,0ffh	; 9b25
	defb 000h,000h,080h,0ffh	; 9b29
	defb 000h,000h,080h,000h	; 9b2d
	defb 080h,0ffh,080h,000h	; 9b31
	defb 080h,000h,080h,000h	; 9b35
	defb 000h,000h,080h,000h	; 9b39
	defb 000h,000h,000h,000h	; 9b3d
	defb 080h,0ffh,000h,000h	; 9b41
	defb 080h,000h,000h,000h	; 9b45
	defb 000h,000h,000h,000h	; 9b49

; ======================================================================
; CODIGO 0x9b4d..0x9bd2  (133 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LA VELOCIDAD DE LA NAVE ES UNA SUMA REPETIDA
; La mejora de velocidad no multiplica: coge la velocidad de una unidad y
; la SUMA a si misma tantas veces como escalones lleve (0xE202, topado en
; siete) mas tres. Ocho escalones de velocidad, y ni una multiplicacion.
; ----------------------------------------------------------------------
por_los_escalones_de_velocidad:		; Suma las dos velocidades a si mismas 3 + (0xE202) veces: eso es la mejora de velocidad
	ld a,(0e202h)		;9b4d   ; 0xE202: los escalones de velocidad
	cp 008h		;9b50   ; Siete como mucho
	jp c,L_9B57		;9b52
	ld a,007h		;9b55
L_9B57:
	add a,003h		;9b57   ; Mas tres: la velocidad de partida
	ld h,a			;9b59
	ex af,af'			;9b5a
	ld a,h			;9b5b
	ld l,c			;9b5c
	ld h,b			;9b5d
L_9B5E:
	add hl,bc			;9b5e   ; La velocidad horizontal, sumada a si misma
	dec a			;9b5f   ; Los escalones mas tres
	jp nz,L_9B5E		;9b60
	ld c,l			;9b63
	ld b,h			;9b64
	ld l,e			;9b65
	ld h,d			;9b66
	ex af,af'			;9b67
L_9B68:
	add hl,de			;9b68   ; Y la de Y
	dec a			;9b69   ; Y la vertical
	jp nz,L_9B68		;9b6a   ; La vertical, ya multiplicada
	ld e,l			;9b6d
	ld d,h			;9b6e
	ret			;9b6f
acaba_la_partida:		; Copia 0xE130 a 0xE06B y apaga el aviso de 0xE05F
	ld a,(0e130h)		;9b70
	ld (0e06bh),a		;9b73
	xor a			;9b76
	ld (0e05fh),a		;9b77
	ret			;9b7a
mata_la_nave:		; Deja 0xFF en la nave y en sus dos opciones y pone los escalones de velocidad a cero
	ld hl,0e200h		;9b7b
	ld a,(hl)			;9b7e
	or a			;9b7f
	ret m			;9b80
	ld de,00020h		;9b81   ; Treinta y dos bytes: la ficha siguiente
	ld b,003h		;9b84   ; La nave y sus dos opciones
L_9B86:
	ld (hl),0ffh		;9b86
	add hl,de			;9b88
	djnz L_9B86		;9b89
	xor a			;9b8b
	ld (0e202h),a		;9b8c   ; 0xE202 a cero: se pierde la velocidad
	jr monta_la_ficha_de_la_nave		;9b8f
pasa_al_estado_siguiente_de_la_nave:		; Baja el contador y, al agotarse, sube el estado; pasado el 4 se acaba la partida
	ld hl,0e201h		;9b91
	dec (hl)			;9b94   ; 0xE201: los cuadros que quedan en este estado
	ret nz			;9b95
	inc l			;9b96
	inc (hl)			;9b97
	ld a,(hl)			;9b98
	cp 004h		;9b99   ; Cuatro estados
	jr nc,acaba_la_partida		;9b9b
monta_la_ficha_de_la_nave:		; Saca de la tabla de 0x9BD2 los cuadros que dura el estado y la ficha de sprite de la nave y de sus dos opciones
	ld hl,09bd2h		;9b9d   ; La tabla de 0x9BD2, indexada por el estado
	call 047aeh		;9ba0
	ex de,hl			;9ba3
	ld a,(hl)			;9ba4
	ld (0e201h),a		;9ba5   ; Los cuadros que dura
	inc hl			;9ba8
	ld de,0e207h		;9ba9
	ldi		;9bac   ; Los cuatro bytes de la ficha
	ldi		;9bae
	ldi		;9bb0
	ldi		;9bb2
	ld de,0e224h		;9bb4   ; Y las dos opciones, 0xE224 y 0xE244
	call monta_la_opcion		;9bb7
	ld de,0e244h		;9bba
monta_la_opcion:		; La opcion va en la fila de la nave y en su columna mas el desplazamiento de la tabla
	ld a,(0e204h)		;9bbd   ; La fila de la nave
	ld (de),a			;9bc0
	inc e			;9bc1
	inc e			;9bc2
	ld a,(0e206h)		;9bc3   ; Y su columna mas el desplazamiento
	add a,(hl)			;9bc6
	ld (de),a			;9bc7
	ld a,006h		;9bc8   ; Seis bytes mas alla, el patron y el color
	add a,e			;9bca
	ld e,a			;9bcb
	inc hl			;9bcc
	ldi		;9bcd
	ldi		;9bcf
	ret			;9bd1

; ----------------------------------------------------------------------
; DATOS tabla_9BD2: Cuarenta y un bytes que lee 0x9B9D.
;   0x9bd2..0x9bfb  (41 bytes)
DATA_tabla_9BD2:
	defb 0f0h,09bh,0dah,09bh,0e5h,09bh,0f0h,09bh,014h,05ch,009h,060h,00fh,0f8h,058h,006h	; 9bd2  .........\.`..X.
	defb 008h,074h,006h,00ah,050h,009h,054h,00fh,0f8h,04ch,006h,008h,070h,006h,00ah,064h	; 9be2  .t..P.T..L..p..d
	defb 006h,068h,009h,000h,06ch,00fh,000h,06ch,00fh	; 9bf2  .h..l..l.

; ======================================================================
; CODIGO 0x9bfb..0x9cba  (191 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LA COLA DE LA OPCION SE RELLENA CON LA PILA
; Las opciones siguen a la nave con retraso: hay que guardar sus dieciseis
; ultimas posiciones. Al crearlas, esa cola se rellena de golpe con la
; posicion actual, y para eso el cartucho hace algo que no se ve todos los
; dias: apunta el PUNTERO DE PILA a la cola (`ld sp,hl`), da ocho `push bc`
; seguidos -dieciseis bytes en dieciseis instrucciones- y devuelve el SP,
; todo con las interrupciones cerradas para que nadie use la pila mientras.
; ----------------------------------------------------------------------
monta_una_opcion:		; Copia a la ficha de la opcion la posicion de la nave y rellena su cola de posiciones con `push`
	ld a,(0e20bh)		;9bfb   ; 0xE20B: cuantas opciones hay
	dec a			;9bfe
	ld hl,0e204h		;9bff   ; Con una, la posicion sale de la nave; con dos, de la primera opcion
	ld de,0e220h		;9c02
	jr z,L_9C0D		;9c05
	ld hl,0e224h		;9c07
	ld de,0e240h		;9c0a
L_9C0D:
	ld a,001h		;9c0d
	ld (de),a			;9c0f
	ld c,(hl)			;9c10   ; La X y la Y
	inc l			;9c11   ; La X y la Y
	inc l			;9c12   ; La Y
	ld b,(hl)			;9c13
	ld a,004h		;9c14
	add a,e			;9c16
	ld e,a			;9c17
	ld a,c			;9c18
	ld (de),a			;9c19
	inc e			;9c1a
	inc e			;9c1b
	ld a,b			;9c1c
	ld (de),a			;9c1d
	ld a,005h		;9c1e
	add a,e			;9c20
	ld e,a			;9c21
	ex de,hl			;9c22
	ld (hl),000h		;9c23   ; El patron 0x44 y el color 0x0A
	inc l			;9c25   ; El patron 0x44
	ld (hl),044h		;9c26
	inc l			;9c28
	ld (hl),00ah		;9c29
	ld a,013h		;9c2b
	add a,l			;9c2d
	ld l,a			;9c2e
	ld iy,00000h		;9c2f   ; Se guarda el puntero de pila...
	add iy,sp		;9c33
	di			;9c35
	ld sp,hl			;9c36   ; ...se apunta a la cola...
	ld a,008h		;9c37
L_9C39:
	push bc			;9c39   ; ...ocho `push`: dieciseis bytes de una tacada...
	dec a			;9c3a
	jr nz,L_9C39		;9c3b
	ld sp,iy		;9c3d   ; ...y se devuelve
	ei			;9c3f
	ret			;9c40
corre_las_opciones:		; Cada dos cuadros mete la posicion de la nave en la cola y las opciones van saliendo por el otro extremo
	ld a,(0e1c0h)		;9c41   ; Con la pantalla parada, no
	and a			;9c44
	ret nz			;9c45
	ld a,(0e200h)		;9c46
	dec a			;9c49
	ret m			;9c4a
	ld a,(0e20bh)		;9c4b   ; Sin opciones, tampoco
	or a			;9c4e   ; Sin opciones, no
	ret z			;9c4f
	exx			;9c50
	ld b,a			;9c51
	exx			;9c52
	call anima_las_opciones		;9c53
	exx			;9c56
	ld a,(0e009h)		;9c57   ; Con el mando quieto o en diagonal justa, la cola no avanza
	and 00fh		;9c5a   ; Los cuatro bits de direccion
	ret z			;9c5c   ; Con el mando quieto, la cola no avanza
	cp 003h		;9c5d
	ret z			;9c5f
	cp 00ch		;9c60
	ret z			;9c62
	cp 00fh		;9c63
	ret z			;9c65
	dec b			;9c66   ; Con dos opciones, las dos
	jr z,corre_una_cola		;9c67   ; Ni en diagonal justa
	call corre_una_cola		;9c69
	ld hl,0e250h		;9c6c
	ld de,0e244h		;9c6f
	jr L_9C7A		;9c72
corre_una_cola:		; Empuja la posicion nueva por delante y corre los dieciseis bytes de la cola
	ld hl,0e230h		;9c74
	ld de,0e224h		;9c77
L_9C7A:
	push hl			;9c7a   ; La posicion nueva, por delante
	ldi		;9c7b
	inc e			;9c7d
	ldi		;9c7e
	pop de			;9c80
	ld bc,0000eh		;9c81   ; Catorce bytes: el resto de la cola
	ldir		;9c84
	ld a,l			;9c86   ; Y la de hace dieciseis cuadros, al final
	sub 03ch		;9c87   ; 0x3C bytes atras
	ld l,a			;9c89
	ldi		;9c8a
	inc l			;9c8c
	ldi		;9c8d
	ret			;9c8f
anima_las_opciones:		; Cada dos cuadros avanza el dibujo de las opciones, cuatro en redondo, de la tabla de 0x9CBA
	ld b,a			;9c90
	ld hl,0e182h		;9c91   ; 0xE182: uno de cada dos cuadros
	inc (hl)			;9c94
	ld a,(hl)			;9c95
	cp 002h		;9c96
	ret c			;9c98
	ld (hl),000h		;9c99
	inc l			;9c9b
	inc (hl)			;9c9c   ; 0xE183: por que dibujo van
	dec b			;9c9d   ; Con dos opciones, las dos
	jr z,L_9CA6		;9c9e
	ld de,0e24ch		;9ca0
	call L_9CA9		;9ca3
L_9CA6:
	ld de,0e22ch		;9ca6
L_9CA9:
	ld hl,09cbah		;9ca9
	ld a,(0e183h)		;9cac
	and 003h		;9caf   ; Cuatro dibujos en redondo
	add a,a			;9cb1
	call 0405dh		;9cb2
	ldi		;9cb5
	ldi		;9cb7
	ret			;9cb9

; ----------------------------------------------------------------------
; DATOS dibujos_de_la_opcion: Cuatro parejas (patron, color) con las que
;   parpadea la opcion. Las lee 0x9CA9.
;   0x9cba..0x9cc2  (8 bytes)
DATA_dibujos_de_la_opcion:
	defb 044h,00ah	; 9cba
	defb 044h,009h	; 9cbc
	defb 048h,008h	; 9cbe
	defb 048h,006h	; 9cc0

; ======================================================================
; CODIGO 0x9cc2..0x9dce  (268 bytes)
; ======================================================================


suelta_el_disparo:		; 0xE180 a cero: el boton se ha soltado
	ld (hl),000h		;9cc2
	ret			;9cc4
mira_si_se_dispara:		; Con el boton recien pulsado, o mantenido quince cuadros, dispara la nave y sus dos opciones
	ld a,(0e1c0h)		;9cc5   ; Con la pantalla parada, no
	and a			;9cc8
	ret nz			;9cc9
	ld a,(0e200h)		;9cca   ; Ni con la nave muerta
	dec a			;9ccd
	ret m			;9cce
	ld hl,0e180h		;9ccf
	ld a,(0e008h)		;9cd2   ; El bit 4 de lo recien pulsado: el disparo
	and 010h		;9cd5
	jr nz,disparan_los_tres		;9cd7
	ld a,(0e009h)		;9cd9   ; Y el bit 4 del mando: mantenido
	and 010h		;9cdc
	jr z,suelta_el_disparo		;9cde
	inc (hl)			;9ce0
	ld a,(hl)			;9ce1
	cp 00fh		;9ce2   ; Quince cuadros seguidos y se dispara solo
	ret c			;9ce4
disparan_los_tres:		; La nave y sus dos opciones, de 0x20 en 0x20 bytes
	call suelta_el_disparo		;9ce5
	ld iy,0e200h		;9ce8   ; 0xE200: la nave
	ld de,00300h		;9cec   ; Tres fichas
L_9CEF:
	exx			;9cef   ; La ficha que toque
	ld a,(iy+000h)		;9cf0
	or a			;9cf3
	call nz,dispara_esta_ficha		;9cf4
	ld bc,00020h		;9cf7   ; Treinta y dos bytes: la siguiente
	add iy,bc		;9cfa
	exx			;9cfc
	ld a,e			;9cfd   ; Treinta y dos bytes: la siguiente
	add a,020h		;9cfe
	ld e,a			;9d00
	dec d			;9d01
	jr nz,L_9CEF		;9d02
	ret			;9d04
dispara_esta_ficha:		; Cuatro armas, una por byte: el disparo de siempre, el doble, el laser y el misil
	ld ix,0e200h		;9d05
	ld a,(ix+00ch)		;9d09   ; El byte 12: el disparo normal
	or a			;9d0c
	call nz,L_9D26		;9d0d
	ld a,(ix+00dh)		;9d10   ; El 13: el doble
	or a			;9d13
	call nz,dispara_el_doble		;9d14
	ld a,(ix+00eh)		;9d17   ; El 14: el laser
	or a			;9d1a
	call nz,dispara_el_laser		;9d1b
	ld a,(ix+00fh)		;9d1e   ; Y el 15: el misil
	or a			;9d21
	call nz,dispara_el_misil		;9d22
	ret			;9d25
L_9D26:
	dec a			;9d26
	jr z,dispara_el_normal		;9d27
	ld hl,0e260h		;9d29   ; Las nueve ranuras de disparo de 0xE260
	call hay_hueco_en_esta_tabla		;9d2c   ; Las nueve ranuras
	jr z,L_9D59		;9d2f   ; Sin hueco, no
	ld hl,0e270h		;9d31
	call hay_hueco_en_esta_tabla		;9d34
	jr z,L_9D59		;9d37
	ret			;9d39
marca_que_no_cabe:		; 0xE184 a uno: no queda hueco para el disparo doble
	ld a,001h		;9d3a
	jr L_9D40		;9d3c
marca_que_si_cabe:		; 0xE184 a cero
	ld a,000h		;9d3e
L_9D40:
	ld (0e184h),a		;9d40
	ret			;9d43
dispara_el_normal:		; Busca hueco entre las nueve ranuras y monta el disparo de siempre, ocho a la derecha y 0x10 por debajo
	ld hl,0e260h		;9d44   ; Las nueve ranuras
	call hay_hueco_en_esta_tabla		;9d47
	jr nz,marca_que_no_cabe		;9d4a
	push hl			;9d4c
	ld bc,00010h		;9d4d   ; Dieciseis bytes: la de al lado
	add hl,bc			;9d50   ; Dieciseis bytes: la de al lado
	ld a,(hl)			;9d51   ; Y la de al lado tambien libre
	or a			;9d52
	pop hl			;9d53
	jr nz,marca_que_no_cabe		;9d54
	call marca_que_si_cabe		;9d56
L_9D59:
	ld (hl),001h		;9d59
	inc l			;9d5b
	ld de,00810h		;9d5c   ; Ocho a la derecha y 0x10 mas abajo
	call pon_la_posicion_del_disparo		;9d5f
	and 0f8h		;9d62   ; La Y, cuadrada a ocho
	ld (hl),a			;9d64
	ld d,0f8h		;9d65   ; Velocidad 0xF8: hacia arriba
	call pon_la_x_cuadrada		;9d67
	ld a,001h		;9d6a   ; El sonido 1
	jp 049deh		;9d6c
dispara_el_doble:		; El disparo doble, que sale hacia arriba con velocidad 0x18
	ld a,(0e184h)		;9d6f   ; Sin hueco para el, no
	or a			;9d72   ; Sin hueco, no se dispara
	ret nz			;9d73   ; Sin hueco, no
	ld hl,0e270h		;9d74
	call hay_hueco_en_esta_tabla		;9d77
	ret nz			;9d7a
	ld (hl),002h		;9d7b
	inc l			;9d7d
	ld de,00008h		;9d7e
	call pon_la_posicion_del_disparo		;9d81
	inc l			;9d84
	ld (hl),018h		;9d85   ; Velocidad 0x18 y color 0x0F
	inc l			;9d87
	ld (hl),00fh		;9d88
	ld a,002h		;9d8a   ; El sonido 2
	jp 049deh		;9d8c
dispara_el_laser:		; Monta el laser, que se queda pegado a la nave: guarda en su ficha el puntero a quien lo dispara
	ld hl,0e260h		;9d8f
	call hay_hueco_en_esta_tabla		;9d92
	ret nz			;9d95
	ld (hl),003h		;9d96   ; Tipo 3: el laser
	inc l			;9d98
	ld (hl),000h		;9d99
	ld de,00810h		;9d9b   ; Ocho a la derecha y 0x10 mas abajo
	call pon_la_posicion_del_disparo		;9d9e
	and 0f8h		;9da1
	ld (hl),a			;9da3
	ld d,0fch		;9da4   ; Velocidad 0xFC
	call pon_la_x_cuadrada		;9da6
	inc l			;9da9
	inc l			;9daa
	push iy		;9dab   ; Se guarda de quien es el laser
	pop bc			;9dad   ; Se guarda de quien es
	ld (hl),c			;9dae   ; Se guarda el puntero
	inc l			;9daf
	ld (hl),b			;9db0
	inc l			;9db1
	inc l			;9db2
	inc l			;9db3
	ld (hl),000h		;9db4
	inc l			;9db6
	exx			;9db7
	ld c,(ix+00eh)		;9db8
	ld b,000h		;9dbb
	ld hl,09dcdh		;9dbd
	add hl,bc			;9dc0
	ld a,(hl)			;9dc1
	exx			;9dc2
	ld (hl),a			;9dc3
	inc l			;9dc4
	inc l			;9dc5
	inc l			;9dc6
	ld (hl),000h		;9dc7
	ld a,003h		;9dc9   ; El sonido 3
	jp 049deh		;9dcb

; ----------------------------------------------------------------------
; DATOS tabla_9DCD (tramo): Tres bytes que lee 0x9DBD con `ld hl,0x9DCD`.
;   0x9dce..0x9dd0  (2 bytes)  de 0x9dcd..0x9dd0 (3 bytes)
DATA_tabla_9DCD_9DCE:
	defb 008h,00fh	; 9dce

; ======================================================================
; CODIGO 0x9dd0..0x9e2c  (92 bytes)
; ======================================================================


dispara_el_misil:		; El misil va a la tabla de 0x2C0, con una ranura por cada dos fichas
	ld hl,0e2c0h		;9dd0   ; La tabla de misiles de 0xE2C0
	exx			;9dd3
	ld a,e			;9dd4
	exx			;9dd5
	sra a		;9dd6   ; Una ranura por cada dos fichas
	add a,l			;9dd8   ; Con el primer byte a cero, hay hueco
	ld l,a			;9dd9
	jr nc,L_9DDD		;9dda
	inc h			;9ddc
L_9DDD:
	ld a,(hl)			;9ddd
	or a			;9dde
	ret nz			;9ddf
	ld (hl),004h		;9de0   ; Tipo 4: el misil
	inc l			;9de2
	ld de,00808h		;9de3
	call pon_la_posicion_del_disparo		;9de6
	inc l			;9de9
	ld (hl),020h		;9dea   ; Patron 0x20 y color 0x0A
	inc l			;9dec
	ld (hl),00ah		;9ded
	ret			;9def
hay_hueco_en_esta_tabla:		; Devuelve el primer hueco de la tabla que traiga HL, saltando por la ficha que toque
	exx			;9df0   ; El salto que toque
	ld a,e			;9df1
	exx			;9df2
	add a,l			;9df3
	ld l,a			;9df4
	jr nc,L_9DF8		;9df5
	inc h			;9df7
L_9DF8:
	ld a,(hl)			;9df8   ; Con el primer byte a cero, la ranura esta libre
	or a			;9df9
	ret			;9dfa
pon_la_posicion_del_disparo:		; Le pone al disparo la posicion de quien lo dispara mas el desplazamiento de DE
	ld a,(iy+004h)		;9dfb   ; La X del que dispara
	add a,d			;9dfe
	inc l			;9dff
	inc l			;9e00
	ld (hl),a			;9e01
	ld a,(iy+006h)		;9e02   ; Y su Y
	add a,e			;9e05
	inc l			;9e06
	inc l			;9e07
	ld (hl),a			;9e08
	ret			;9e09
pon_la_x_cuadrada:		; La X del que dispara, cuadrada a cuatro y mas D
	ld a,(iy+004h)		;9e0a   ; La X del que dispara
	rra			;9e0d
	and 003h		;9e0e   ; Cuadrada a cuatro
	add a,d			;9e10
	inc l			;9e11
	ld (hl),a			;9e12
	ret			;9e13
corre_los_nueve_disparos:		; Las nueve ranuras de 0xE260, cada una por su tipo: cuatro salidas
	ld ix,0e260h		;9e14
	exx			;9e18
	ld b,009h		;9e19   ; Nueve ranuras
L_9E1B:
	exx			;9e1b
	ld a,(ix+000h)		;9e1c
	dec a			;9e1f
	jp m,disparo_siguiente		;9e20
	ld de,09e34h		;9e23   ; Se empuja 0x9E34: al volver, sigue por ahi
	push de			;9e26
	push ix		;9e27
	call 04067h		;9e29

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_9E29: Cuatro palabras pegadas detras del `call
;   0x4067` de 0x9E29.
;   0x9e2c..0x9e34  (8 bytes)
DATA_tabla_del_despachador_9E29:
	defw 09e3dh,09e4fh	; 9e2c  -> corre_el_disparo_normal corre_el_disparo_doble
	defw 09e66h,09ee0h	; 9e30  -> corre_el_laser corre_el_misil

; ======================================================================
; CODIGO 0x9e34..0x9f9a  (358 bytes)
; ======================================================================


disparo_siguiente:		; Dieciseis bytes y vuelta al bucle de las nueve ranuras
	ld de,00010h		;9e34   ; Dieciseis bytes: la ranura siguiente
	add ix,de		;9e37   ; La ranura siguiente
	exx			;9e39
	djnz $-31		;9e3a
	ret			;9e3c
corre_el_disparo_normal:		; Doce puntos a la derecha por cuadro; al salirse de la pantalla, se apaga
	pop hl			;9e3d
	ld a,004h		;9e3e
	add a,l			;9e40
	ld l,a			;9e41
	ld de,00c00h		;9e42   ; 0x0C00: doce puntos por cuadro
L_9E45:
	ld a,(hl)			;9e45   ; Doce puntos a la derecha
	add a,e			;9e46
	ld (hl),a			;9e47
	inc l			;9e48
	ld a,(hl)			;9e49
	adc a,d			;9e4a
	jr c,apaga_el_disparo		;9e4b   ; Al salirse, se apaga
	ld (hl),a			;9e4d
	ret			;9e4e
corre_el_disparo_doble:		; Seis puntos hacia arriba y doce a la derecha
	pop hl			;9e4f   ; Se saca el retorno: el disparo no vuelve por aqui
	inc l			;9e50
	inc l			;9e51
	ld de,00600h		;9e52   ; 0x0600 hacia arriba
	ld a,(hl)			;9e55   ; La Y menos seis
	sub e			;9e56   ; La Y menos seis
	ld (hl),a			;9e57   ; Y avanza doce
	inc l			;9e58
	ld a,(hl)			;9e59
	sbc a,d			;9e5a
	jr c,apaga_el_disparo		;9e5b
	ld (hl),a			;9e5d
	inc l			;9e5e
	jr L_9E45		;9e5f
apaga_el_disparo:		; La ranura queda libre
	ld (ix+000h),000h		;9e61
	ret			;9e65
corre_el_laser:		; Se pega a quien lo dispara, va creciendo y se corta al llegar al mapa
	pop hl			;9e66
	inc l			;9e67
	ld a,(hl)			;9e68
	dec a			;9e69
	jr z,el_laser_avanza		;9e6a
	jp p,el_laser_se_encoge		;9e6c
	ld c,(ix+008h)		;9e6f   ; Los bytes 8 y 9: de quien es el laser
	ld b,(ix+009h)		;9e72
	push bc			;9e75
	pop iy		;9e76
	ld de,00810h		;9e78   ; Ocho a la derecha y 0x10 mas abajo
	call pon_la_posicion_del_disparo		;9e7b
	and 0f8h		;9e7e
	ld (hl),a			;9e80
	ld d,0fch		;9e81   ; Velocidad 0xFC
	call pon_la_x_cuadrada		;9e83
	ld a,006h		;9e86
	add a,l			;9e88
	ld l,a			;9e89
	ld b,004h		;9e8a   ; Cuatro pasos de crecimiento
L_9E8C:
	inc (hl)			;9e8c   ; El largo sube...
	inc l			;9e8d
	dec (hl)			;9e8e   ; ...y la cuenta baja
	jr z,el_laser_ya_esta_largo		;9e8f
	dec l			;9e91
	djnz L_9E8C		;9e92
	jr recorta_el_laser		;9e94
el_laser_ya_esta_largo:		; El byte 1 sube: pasa a la fase siguiente
	inc (ix+001h)		;9e96
	jr recorta_el_laser		;9e99
el_laser_avanza:		; Corre 0x20 puntos y, si el largo llega a cero, se apaga
	call corre_el_laser_veinte		;9e9b   ; 0x20 puntos a la derecha
	jr c,apaga_el_disparo		;9e9e
	call recorta_el_laser		;9ea0
	ld a,(ix+00ch)		;9ea3   ; Y si el largo llega a cero, se acabo
	or a			;9ea6
	ret nz			;9ea7
	jr apaga_el_disparo		;9ea8
el_laser_se_encoge:		; Corre y le quita cinco al largo; al agotarse, se va
	call corre_el_laser_veinte		;9eaa   ; 0x20 puntos a la derecha
	jr c,apaga_el_disparo		;9ead
	ld a,(ix+00ch)		;9eaf   ; Cinco de largo menos
	sub 005h		;9eb2
	jr c,apaga_el_disparo		;9eb4
	inc a			;9eb6
	ld (ix+00ch),a		;9eb7
	ret			;9eba
corre_el_laser_veinte:		; 0x20 puntos a la derecha
	ld a,004h		;9ebb   ; Cuatro bytes mas alla: la X
	add a,l			;9ebd
	ld l,a			;9ebe
	ld a,020h		;9ebf   ; 0x20 puntos
	add a,(hl)			;9ec1
	ld (hl),a			;9ec2
	ret			;9ec3
recorta_el_laser:		; Si el laser se sale de la pantalla por arriba, se le acorta el largo justo lo que sobra
	ld a,(ix+00ch)		;9ec4   ; El largo por ocho
	add a,a			;9ec7   ; El largo por ocho
	add a,a			;9ec8
	add a,a			;9ec9
	neg		;9eca
	sub (ix+005h)		;9ecc
	ret nc			;9ecf
	neg		;9ed0
	rra			;9ed2   ; Lo que se sale, en casillas
	rra			;9ed3   ; Lo que se sale, en casillas
	rra			;9ed4   ; En valor absoluto
	and 01fh		;9ed5
	sub (ix+00ch)		;9ed7
	neg		;9eda
	ld (ix+00ch),a		;9edc
	ret			;9edf
corre_el_misil:		; Va pegado al suelo: mira el mapa delante y debajo, y sube o baja segun lo que encuentre
	call parpadea_el_misil		;9ee0
	pop hl			;9ee3
	call posicion_del_misil		;9ee4
	ld a,l			;9ee7
	add a,008h		;9ee8   ; Ocho a la derecha: lo que tiene delante
	ld l,a			;9eea
	call choca_con_el_mapa		;9eeb
	jr nc,baja_el_misil		;9eee
	call posicion_del_misil		;9ef0
	ld a,h			;9ef3   ; Y ocho por debajo
	add a,008h		;9ef4   ; Ocho por debajo
	ld h,a			;9ef6   ; Ocho a la derecha
	ld a,l			;9ef7
	add a,008h		;9ef8
	ld l,a			;9efa
	call choca_con_el_mapa		;9efb
	jr nc,sube_el_misil		;9efe
	call posicion_del_misil		;9f00
	ld a,h			;9f03
	add a,008h		;9f04
	ld h,a			;9f06
	call choca_con_el_mapa		;9f07   ; Si tambien choca ahi, el misil se estrella
	jp c,apaga_el_disparo		;9f0a
	jr anda_el_misil		;9f0d
sube_el_misil:		; El suelo sube: el misil trepa el escalon
	call L_9F24		;9f0f
	jr anda_el_misil		;9f12
baja_el_misil:		; No hay suelo delante: el misil cae, mas deprisa si lleva la mejora doble
	ld a,(0e20fh)		;9f14   ; 0xE20F en dos: el misil mejorado cae mas rapido
	cp 002h		;9f17
	ld de,00100h		;9f19
	jr c,L_9F21		;9f1c
	ld de,00180h		;9f1e
L_9F21:
	call avanza_el_misil		;9f21
L_9F24:
	ld (ix+006h),020h		;9f24   ; Dibujo 0x20: el misil cayendo
	ld a,(0e20fh)		;9f28
	cp 002h		;9f2b
	ld de,00400h		;9f2d
	jr c,L_9F35		;9f30
	ld de,00600h		;9f32
L_9F35:
	ld a,(ix+002h)		;9f35   ; Y avanza a la vez
	add a,e			;9f38   ; Y avanza a la vez
	ld (ix+002h),a		;9f39   ; La X sube
	ld a,(ix+003h)		;9f3c
	adc a,d			;9f3f
	cp 0a0h		;9f40
	jp nc,apaga_el_disparo		;9f42
	ld (ix+003h),a		;9f45
	ret			;9f48
anda_el_misil:		; Va pegado al suelo, con dibujo 0x1C
	ld (ix+006h),01ch		;9f49   ; Dibujo 0x1C: el misil rodando
	ld a,(0e20fh)		;9f4d
	cp 002h		;9f50
	ld de,00400h		;9f52
	jr c,avanza_el_misil		;9f55
	ld de,00600h		;9f57
avanza_el_misil:		; Le suma DE a la X; si se sale de la pantalla, se apaga
	ld a,(ix+004h)		;9f5a   ; Le suma DE a la X
	add a,e			;9f5d
	ld (ix+004h),a		;9f5e
	ld a,(ix+005h)		;9f61
	adc a,d			;9f64
	jp c,apaga_el_disparo		;9f65   ; Al salirse, se apaga
	ld (ix+005h),a		;9f68
	ret			;9f6b
posicion_del_misil:		; La X y la Y del misil, en HL
	ld h,(ix+005h)		;9f6c
	ld l,(ix+003h)		;9f6f
	ret			;9f72
parpadea_el_misil:		; El color alterna entre 0x0A y 0x0B cada dos cuadros
	ld hl,0e003h		;9f73   ; Un bit del contador
	ld a,00ah		;9f76   ; 0x0A o 0x0B segun el cuadro
	bit 1,(hl)		;9f78   ; Un bit del contador
	jr z,L_9F7D		;9f7a
	inc a			;9f7c
L_9F7D:
	ld (ix+007h),a		;9f7d
	ret			;9f80
dibuja_los_disparos:		; 0xEC1A a uno: los disparos se pintan
	ld a,001h		;9f81
	jr L_9F86		;9f83
borra_los_disparos:		; 0xEC1A a cero: se borran
	xor a			;9f85
L_9F86:
	ld (0ec1ah),a		;9f86
	ld ix,0e260h		;9f89
	ld b,009h		;9f8d   ; Nueve ranuras
	push bc			;9f8f
	ld bc,09fa4h		;9f90   ; Se empuja 0x9FA4: al volver, sigue por ahi
	push bc			;9f93
	ld a,(ix+000h)		;9f94
	call 04067h		;9f97

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_9F97: Cinco palabras pegadas detras del `call
;   0x4067` de 0x9F97.
;   0x9f9a..0x9fa4  (10 bytes)
DATA_tabla_del_despachador_9F97:
	defw 09fach,09fadh	; 9f9a  -> el_misil_no_choca mira_si_el_disparo_choca
	defw 09fadh,09fe6h	; 9f9e  -> mira_si_el_disparo_choca mira_el_laser_contra_el_mapa
	defw 09fadh	; 9fa2  -> mira_si_el_disparo_choca

; ----------------------------------------------------------------------
; DATOS tabla_9FA4: Ocho bytes que 0x9F90 mete en BC con `ld bc,0x9FA4`.
;   0x9fa4..0x9fac  (8 bytes)
DATA_tabla_9FA4:
	defb 001h,010h,000h,0ddh,009h,0c1h,010h,0e3h	; 9fa4  ........

; ======================================================================
; CODIGO 0x9fac..0xa000  (84 bytes)
; ======================================================================


el_misil_no_choca:		; El misil no se mira contra el mapa: ya va pegado a el
	ret			;9fac
mira_si_el_disparo_choca:		; Solo al borrar: si el disparo ha dado en el mapa, se apaga; y si la casilla era de las especiales, se rompe
	ld a,(0ec1ah)		;9fad   ; 0xEC1A: esto solo se hace en el paso de borrado
	and a			;9fb0
	ret nz			;9fb1
	ld h,(ix+005h)		;9fb2
	ld l,(ix+003h)		;9fb5
	call choca_con_el_mapa_2		;9fb8
	ret nc			;9fbb
	ld a,(ix+000h)		;9fbc   ; El misil se salta la casilla especial
	cp 004h		;9fbf
	jr z,L_9FC8		;9fc1
	call es_casilla_especial		;9fc3
	jr c,rompe_la_casilla		;9fc6
L_9FC8:
	ld hl,(0e151h)		;9fc8   ; Con el jefe en pantalla, el disparo se traga sin sonar
	ld a,l			;9fcb
	and a			;9fcc
	jp z,apaga_el_disparo		;9fcd
	ld a,h			;9fd0
	and a			;9fd1
	jp nz,apaga_el_disparo		;9fd2
	ld a,006h		;9fd5   ; El sonido 6: el disparo ha chocado
	call 049deh		;9fd7   ; El sonido 6
	jp apaga_el_disparo		;9fda
rompe_la_casilla:		; La casilla especial se borra del mapa y suena lo que diga su grupo
	xor a			;9fdd
	ld (de),a			;9fde
	ld a,c			;9fdf
	call 049deh		;9fe0
	jp apaga_el_disparo		;9fe3
mira_el_laser_contra_el_mapa:		; Solo al pintar: recorre las casillas que ocupa el laser y lo corta donde encuentre pared
	ld a,(0ec1ah)		;9fe6   ; Solo en el paso de pintado
	and a			;9fe9
	ret z			;9fea
	ld h,(ix+005h)		;9feb
	ld l,(ix+003h)		;9fee
	call 0571bh		;9ff1   ; La casilla del mapa donde empieza
	ex de,hl			;9ff4
	ld a,(ix+00ch)		;9ff5   ; El byte 12: cuantas casillas mide
	or a			;9ff8
	ret z			;9ff9
	ld b,a			;9ffa
L_9FFB:
	call choca_en_esta_casilla		;9ffb
	jr nc,$+13		;9ffe

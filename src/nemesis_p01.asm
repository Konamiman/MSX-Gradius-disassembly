; ==========================================================================
; NEMESIS / GRADIUS - Konami (1986) - MSX1 - MegaROM RC-742 de 128 KB (Konami4) - banco 01 (se ejecuta en 0x6000)
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x06000


; ----------------------------------------------------------------------
; Direcciones que solo aparecen como VALOR -en un `ld`, no en
; un salto-: son punteros que el codigo se pasa o numeros que
; casualmente coinciden con una direccion. No hay nada que
; trazar en ellas; el equ existe para que el listado ensamble.
; ----------------------------------------------------------------------
l730fh:	equ 0x0730f
l7b38h:	equ 0x07b38

; ======================================================================
; CODIGO 0x6000..0x607e  (126 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL BANCO EMPIEZA A MEDIO BUCLE
; ----------------------------------------------------------------------
fin_del_bucle_del_banco_0:		; Aqui acaba el bucle que empieza en p00:5FFB. El codigo cruza la frontera del banco.
	ld de,00008h		;6000
	add ix,de		;6003
	djnz $-10		;6005
	ret			;6007

; ----------------------------------------------------------------------
; LOS MOTORES DE LOS ENEMIGOS
; Este banco es el que mueve a los bichos. p00:5FFC llama a 0x6008 una vez
; por objeto, con IX apuntando a su ranura, y de ahi sale un reparto por
; el tipo (IX+0) y por el paso en el que va (IX+1): cada enemigo es una
; maquinita de estados diminuta con su contador de cuadros en (IX+4).
; ----------------------------------------------------------------------
anda_objeto:		; La llama p00:5FFC una vez por objeto: si la ranura esta viva, le da un paso a su motor
	ld a,(ix+000h)		;6008   ; El primer byte a cero: la ranura esta libre
	and a			;600b
	ret z			;600c
	push ix		;600d
	call paso_del_motor		;600f
	pop ix		;6012
se_corre_con_el_scroll:		; En los pasos con columna nueva, el objeto se corre ocho puntos a la izquierda; al salirse por el borde, la ranura se libera
	ld a,(0e100h)		;6014   ; Solo en los pasos que meten columna
	and a			;6017
	ret z			;6018
	ld a,(ix+003h)		;6019
	sub 008h		;601c   ; Ocho puntos a la izquierda por paso
	jr c,L_6024		;601e
	ld (ix+003h),a		;6020
	ret			;6023
L_6024:
	ld (ix+000h),000h		;6024   ; Y al salirse, la ranura se libera
	ret			;6028
paso_del_motor:		; Con la pantalla parada no se mueve nada; los tipos 1 y 2 disparan, y del 3 en adelante reparte por (IX+1)
	ld a,(0e1c0h)		;6029   ; 0xE1C0 distinto de cero: la pantalla esta parada
	and a			;602c
	ret nz			;602d
	ld a,(ix+000h)		;602e   ; El tipo se apunta en 0xE123
	ld (0e123h),a		;6031
	cp 003h		;6034   ; Del tipo 3 en adelante, el otro reparto
	jr nc,L_6061		;6036
	ld a,(ix+007h)		;6038
	and a			;603b
	ret z			;603c
	dec (ix+004h)		;603d   ; Un cuadro menos para el disparo siguiente
	ret nz			;6040
	ld (ix+004h),008h		;6041   ; Ocho cuadros entre bicho y bicho
	dec (ix+007h)		;6045
	ld a,(ix+002h)		;6048
	ld c,0f8h		;604b   ; El bit 0 del tipo: el 1 los suelta por arriba y el 2 por abajo
	bit 0,(ix+000h)		;604d
	jr nz,L_6055		;6051
	ld c,018h		;6053
L_6055:
	add a,c			;6055
	ld e,a			;6056
	ld d,(ix+003h)		;6057
	ld c,000h		;605a
	ld a,007h		;605c   ; El tipo 7: el bicho que sale de la escotilla
	jp saca_un_objeto		;605e
L_6061:
	ld a,(ix+001h)		;6061
	dec a			;6064
	jr z,$+33		;6065
	dec a			;6067
	jr z,$+103		;6068
	dec a			;606a
	jp z,muere_al_agotarse		;606b
	ld a,(0e206h)		;606e   ; La X y la Y de la nave, que los motores necesitan
	ld b,a			;6071
	ld a,(0e204h)		;6072
	ld c,a			;6075
	ld a,(ix+000h)		;6076
	sub 003h		;6079   ; Menos tres: los tipos 3, 4, 5 y 6
	call 04067h		;607b

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_607B: Cuatro palabras pegadas detras del `call
;   0x4067` de 0x607B (0x610E, 0x6131, 0x614A, 0x615B). El indice es (IX+0)
;   menos tres.
;   0x607e..0x6086  (8 bytes)
DATA_tabla_del_despachador_607B:
	defw 0610eh,06131h	; 607e  -> mira_si_pasa_por_delante mira_si_pasa_por_debajo
	defw 0614ah,0615bh	; 6082  -> mira_si_esta_delante mira_si_ya_paso

; ======================================================================
; CODIGO 0x6086..0x60c7  (65 bytes)
; ======================================================================


motor_de_espera:		; Baja el contador y, cada cuatro cuadros, suelta un disparo del tipo 0x0E desde la posicion del bicho
	ld a,(ix+003h)		;6086
	cp 018h		;6089   ; A menos de 0x18 del borde izquierdo ya no dispara
	jp c,L_6102		;608b
	dec (ix+004h)		;608e
	jr nz,$+109		;6091
	ld (ix+004h),004h		;6093   ; Cuatro cuadros entre disparo y disparo
	dec (ix+007h)		;6097
	jr z,acaba_la_tanda		;609a
	ld a,(ix+000h)		;609c
	ld hl,060c1h		;609f   ; La tabla de 0x60C1: donde le sale el disparo a cada tipo
	call 047aeh		;60a2   ; La tabla de 0x60C1
	ld a,(ix+002h)		;60a5
	add a,e			;60a8
	ld e,a			;60a9
	ld a,(ix+003h)		;60aa
	add a,d			;60ad
	ret c			;60ae
	ld d,a			;60af
	ld c,000h		;60b0
	ld a,00eh		;60b2   ; El tipo 0x0E: el disparo con puntera
	jp saca_un_objeto		;60b4
acaba_la_tanda:		; Se agotaron los disparos: la espera hasta la tanda siguiente sale de la dificultad
	dec (ix+001h)		;60b7
	ld a,(0e111h)		;60ba   ; 0xE111 por dos, restado de 0x40: a mas dificultad, menos espera
	add a,a			;60bd
	neg		;60be
	add a,040h		;60c0
	ld (ix+004h),a		;60c2
	jr $+61		;60c5

; ----------------------------------------------------------------------
; DATOS desplazamientos_60C1: Ocho bytes que 0x609F indexa con la base 0x60C1,
;   que cae dentro del codigo.
;   0x60c7..0x60cf  (8 bytes)
DATA_desplazamientos_60C1:
	defb 010h,014h,010h,034h,018h,034h,0f8h,030h	; 60c7  ...4.4.0

; ======================================================================
; CODIGO 0x60cf..0x60ed  (30 bytes)
; ======================================================================


siguiente_paso:		; Corre el objeto lo que diga la tabla de 0x60E7 y le deja 0x0D cuadros
	inc (ix+001h)		;60cf
	ld a,(ix+000h)		;60d2
	add a,a			;60d5   ; Por dos: dos bytes por tipo
	ld hl,060e7h		;60d6
	call 0405dh		;60d9
	ld a,(hl)			;60dc
	add a,(ix+002h)		;60dd
	ld (ix+002h),a		;60e0
	inc hl			;60e3
	ld a,(hl)			;60e4
	ld (ix+006h),a		;60e5
	ld (ix+004h),00dh		;60e8   ; Trece cuadros
	ret			;60ec

; ----------------------------------------------------------------------
; DATOS desplazamientos_60E7: Ocho bytes que 0x60D6 indexa con la base 0x60E7.
;   0x60ed..0x60f5  (8 bytes)
DATA_desplazamientos_60E7:
	defb 018h,00ch,018h,00ch,000h,00dh,000h,00ch	; 60ed  ........

; ======================================================================
; CODIGO 0x60f5..0x617f  (138 bytes)
; ======================================================================


muere_al_agotarse:		; Cuando el contador llega a cero, la ranura se libera
	dec (ix+004h)		;60f5
	ret nz			;60f8
	ld (ix+000h),000h		;60f9
	ret			;60fd
pon_el_dibujo:		; El dibujo sale del tipo por dos, mas uno si se pide la variante
	ld c,001h		;60fe
	jr L_6104		;6100
L_6102:
	ld c,000h		;6102
L_6104:
	ld a,(ix+000h)		;6104   ; El tipo menos uno, por dos
	dec a			;6107
	add a,a			;6108
	add a,c			;6109
	ld (ix+006h),a		;610a
	ret			;610d
mira_si_pasa_por_delante:		; Espera a que la nave este a menos de 0x40 en X y 0x14 en Y, y entonces arranca
	dec (ix+004h)		;610e
	ret nz			;6111
	ld (ix+004h),001h		;6112
	ld a,(ix+002h)		;6116   ; 0x40 de margen en X
	add a,040h		;6119
	cp c			;611b
	ret c			;611c
	ld a,(ix+003h)		;611d   ; Y 0x14 en Y
	add a,014h		;6120
	cp b			;6122
	ret c			;6123
arranca_la_tanda:		; 0x10 cuadros y 0x10 disparos, y al paso siguiente
	ld (ix+004h),010h		;6124
	ld (ix+007h),010h		;6128
	inc (ix+001h)		;612c
	jr pon_el_dibujo		;612f
mira_si_pasa_por_debajo:		; Lo mismo pero mirando 0x34 por debajo
	dec (ix+004h)		;6131   ; Un cuadro menos
	ret nz			;6134
	ld (ix+004h),001h		;6135
	ld a,(ix+002h)		;6139
	add a,040h		;613c   ; 0x40 de margen en X
	cp c			;613e
	ret c			;613f
	ld a,(ix+003h)		;6140
	sub 034h		;6143   ; Y 0x34 por debajo
	ret c			;6145
	cp b			;6146
	ret nc			;6147
	jr arranca_la_tanda		;6148
mira_si_esta_delante:		; Solo mira la X, con 0x18 de margen
	dec (ix+004h)		;614a   ; Un cuadro menos
	ret nz			;614d
	ld (ix+004h),001h		;614e
	ld a,(ix+002h)		;6152
	add a,018h		;6155   ; 0x18 de margen en X
	cp c			;6157
	ret nc			;6158
	jr arranca_la_tanda		;6159
mira_si_ya_paso:		; Arranca en cuanto la nave se queda detras
	dec (ix+004h)		;615b   ; Un cuadro menos
	ret nz			;615e
	ld (ix+004h),001h		;615f
	ld a,(ix+002h)		;6163
	cp c			;6166
	ret c			;6167
	jr arranca_la_tanda		;6168
corre_los_cuatro_de_e800:		; Los cuatro objetos de 0xE800, de ocho bytes cada uno
	ld ix,0e800h		;616a
	ld b,004h		;616e   ; Cuatro objetos
L_6170:
	ld a,(ix+000h)		;6170
	and a			;6173
	call nz,paso_del_objeto_de_e800		;6174
	ld de,00008h		;6177   ; Ocho bytes por objeto
	add ix,de		;617a
	djnz L_6170		;617c
	ret			;617e

; ----------------------------------------------------------------------
; DATOS llamada_muerta: Tres bytes que son `call 0x6014`. Nadie llega a
;   0x617F: la instruccion de delante acaba en `ret` y ninguna tabla apunta
;   aqui.
;   0x617f..0x6182  (3 bytes)
llamada_muerta:		; `call 0x6014`. Nadie llega aqui.
	defb 0cdh,014h,060h	; 617f

; ======================================================================
; CODIGO 0x6182..0x627b  (249 bytes)
; ======================================================================


paso_del_objeto_de_e800:		; Se corre con el scroll y, cada cuatro cuadros, gasta una unidad de (IX+6); al agotarse, se apaga
	call se_corre_con_el_scroll		;6182
	dec (ix+001h)		;6185
	ret nz			;6188
	ld (ix+001h),004h		;6189   ; Cuatro cuadros por unidad
	dec (ix+006h)		;618d   ; El byte 6 se gasta de uno en uno
	ret p			;6190   ; Cuatro cuadros por unidad
	ld (ix+000h),000h		;6191
	ret			;6195
borra_los_de_e800:		; Recorre los cuatro objetos de 0xE800 borrando su dibujo de la pantalla
	xor a			;6196
	jr L_619B		;6197
pinta_los_de_e800:		; Lo mismo, pintandolos
	ld a,0ffh		;6199
L_619B:
	ld ix,0e800h		;619b
	ld b,004h		;619f
	jr recorre_los_de_e700		;61a1
pinta_los_del_fondo:		; En las fases 3 y 5 no toca; en las demas, pinta los objetos de 0xE700
	ld a,(0e061h)		;61a3   ; Las fases 3 y 5 tienen su propio motor
	cp 003h		;61a6
	ret z			;61a8
	cp 005h		;61a9
	ret z			;61ab
	xor a			;61ac
	jr L_61B9		;61ad
pinta_los_del_fondo_o_el_banco3:		; La fase 5 se la lleva el banco 3; las demas pintan ocho objetos si es la 3, y dos si no
	ld a,(0e061h)		;61af
	cp 005h		;61b2
	jp z,0b3d2h		;61b4   ; La fase 5, al banco 3
	ld a,0ffh		;61b7
L_61B9:
	ex af,af'			;61b9
	ld ix,0e700h		;61ba
	ld a,(0e061h)		;61be
	cp 003h		;61c1   ; La fase 3 lleva ocho objetos; las demas, dos
	ld b,008h		;61c3
	jr z,L_61C9		;61c5
	ld b,002h		;61c7
L_61C9:
	ex af,af'			;61c9
recorre_los_de_e700:		; 0xEC00 dice si se pinta o se borra, y luego pasa por los B objetos
	ld (0ec00h),a		;61ca   ; 0xEC00 a cero borra, y a 0xFF pinta
L_61CD:
	push bc			;61cd
	call dibuja_un_objeto_del_fondo		;61ce
	pop bc			;61d1
	ld de,00008h		;61d2   ; Ocho bytes por objeto
	add ix,de		;61d5
	djnz L_61CD		;61d7
	ret			;61d9
borra_los_del_fondo:		; Lo mismo pero borrando; la fase 5 tambien se la lleva el banco 3
	ld a,(0e061h)		;61da   ; La fase 5 se la lleva el banco 3
	cp 005h		;61dd   ; La fase 5 se la lleva el banco 3
	jp z,0b410h		;61df
	xor a			;61e2
	ld (0ec00h),a		;61e3
	jr pinta_el_rectangulo		;61e6
dibuja_un_objeto_del_fondo:		; Saca de la tabla que le toque el rectangulo de caracteres del objeto y lo pinta o lo borra
	ld a,(ix+000h)		;61e8
	and a			;61eb
	ret z			;61ec
	ld c,(ix+006h)		;61ed
	cp 020h		;61f0   ; El tipo 0x20 usa la tabla de 0x633A
	ld hl,0633ah		;61f2
	jr z,L_6209		;61f5
	ld hl,06370h		;61f7   ; Los demas, la de 0x6370
	ld a,(0e061h)		;61fa
	cp 002h		;61fd   ; Y en la fase 2, del dibujo 2 en adelante se salta doce
	jr nz,L_6209		;61ff
	ld a,c			;6201
	cp 002h		;6202
	jr c,L_6209		;6204
	add a,00ch		;6206
	ld c,a			;6208
L_6209:
	ld a,c			;6209
	call 047aeh		;620a
pinta_el_rectangulo:		; Cuatro por cuatro caracteres en la casilla del objeto: 0x48F7 los borra y 0x490C los copia
	ld bc,00404h		;620d   ; Cuatro de ancho por cuatro de alto
	ld l,(ix+002h)		;6210   ; La casilla donde cae
	ld h,(ix+003h)		;6213
	ld a,(ix+000h)		;6216
	sub 003h		;6219   ; Los tipos 3, 4, 5 y 6 llevan trozos de varios tamanos
	cp 004h		;621b
	jr c,pinta_por_trozos		;621d
	ld a,(0ec00h)		;621f   ; 0xEC00 decide: borrar o copiar
	and a			;6222
	jp z,048f7h		;6223
	jp 0490ch		;6226
pinta_por_trozos:		; Los tipos grandes se pintan por trozos: la tabla de 0x6283 da el ancho, el alto y el desplazamiento de cada uno
	ld a,(ix+006h)		;6229
	ld c,a			;622c
	add a,a			;622d   ; Por tres: tres bytes por trozo
	add a,c			;622e
	push hl			;622f
	ld hl,06283h		;6230
	call 0405dh		;6233
	ld c,(hl)			;6236   ; El ancho, el alto y donde cae
	inc hl			;6237
	ld b,(hl)			;6238
	inc hl			;6239
	ld a,(hl)			;623a
	pop hl			;623b
	and a			;623c   ; El bit 7 del tercer byte corre el trozo media casilla
	jp p,L_6246		;623d
	ex af,af'			;6240
	ld a,008h		;6241
	add a,l			;6243
	ld l,a			;6244
	ex af,af'			;6245
L_6246:
	and 07fh		;6246   ; El bit 7 del tercer byte corre el trozo media casilla
	add a,h			;6248
	ld h,a			;6249
	jr c,pinta_el_trozo_ancho		;624a
	ld a,(0ec00h)		;624c
	and a			;624f
	jp z,048f7h		;6250
	call 0490ch		;6253
pinta_el_trozo_ancho:		; Un rectangulo de diez por uno, con el origen sacado de las dos tablas de 0x6273 y 0x64D4
	ld a,(ix+006h)		;6256
	add a,a			;6259   ; Por dos: dos bytes por dibujo
	ld de,06273h		;625a   ; La tabla de 0x6273
	call 04062h		;625d
	ld a,(de)			;6260
	add a,(ix+002h)		;6261
	ld l,a			;6264
	ld h,(ix+003h)		;6265
	inc de			;6268
	ld a,(de)			;6269
	ld de,064d4h		;626a
	add a,a			;626d   ; Por diez: diez caracteres por fila
	ld c,a			;626e
	add a,a			;626f
	add a,a			;6270
	add a,c			;6271
	call 04062h		;6272
	ld bc,00a01h		;6275   ; Diez de ancho por uno de alto
	jp 0490ch		;6278

; ----------------------------------------------------------------------
; DATOS tabla_6273: Ocho bytes que 0x625A indexa con la base 0x6273.
;   0x627b..0x6283  (8 bytes)
DATA_tabla_6273:
	defb 028h,000h,028h,000h,028h,000h,028h,000h	; 627b  (.(.(.(.

; ----------------------------------------------------------------------
; DATOS tabla_6283: Cuarenta y dos bytes que lee 0x6230.
;   0x6283..0x62ad  (42 bytes)
DATA_tabla_6283:
	defb 000h,001h,000h,001h,010h,002h,010h,002h	; 6283  ........
	defb 010h,000h,000h,003h,005h,007h,010h,005h	; 628b  ........
	defb 007h,010h,005h,007h,008h,005h,007h,008h	; 6293  ........
	defb 002h,008h,090h,002h,008h,090h,002h,008h	; 629b  ........
	defb 010h,002h,008h,010h,002h,006h,010h,002h	; 62a3  ........
	defb 006h,090h	; 62ab

; ======================================================================
; CODIGO 0x62ad..0x633a  (141 bytes)
; ======================================================================


suelta_los_del_fondo:		; Va sacando objetos de fondo mientras el guion tenga renglones para esta distancia
	ld a,(0e061h)		;62ad
	cp 005h		;62b0   ; La fase 5 se la lleva el banco 3
	jp z,0b49eh		;62b2
	call mira_el_guion_del_fondo		;62b5
	jr z,suelta_los_del_fondo		;62b8
	ret c			;62ba
	ld hl,0e109h		;62bb
	inc (hl)			;62be   ; 0xE109 avanza al renglon siguiente
	jr suelta_los_del_fondo		;62bf
suelta_los_del_fondo_con_columna:		; Lo mismo, pero solo en los pasos que meten columna nueva
	ld a,(0e100h)		;62c1   ; Solo en los pasos con columna
	and a			;62c4
	ret z			;62c5
	ld a,(0e061h)		;62c6
	cp 005h		;62c9
	jp z,0b4aah		;62cb
	ld a,0f8h		;62ce   ; 0xF8 en 0xEC04
	ld (0ec04h),a		;62d0
L_62D3:
	call mira_el_guion_del_fondo		;62d3
	jr z,L_62D3		;62d6
	ret			;62d8
mira_el_guion_del_fondo:		; Consulta el guion de 0x64FA con la rutina del banco 2 y, si toca, monta el objeto en la primera ranura libre de 0xE700
	ld a,(0e109h)		;62d9
	ld hl,064fah		;62dc
	call 09100h		;62df   ; La rutina del banco 2 que compara la distancia
	ret nz			;62e2
	ld hl,0e109h		;62e3
	inc (hl)			;62e6
	ld hl,0e700h		;62e7   ; Las ocho ranuras de 0xE700
	ld b,008h		;62ea
	ld de,00008h		;62ec   ; Ocho bytes por ranura
	xor a			;62ef
L_62F0:
	cp (hl)			;62f0   ; La primera ranura libre
	jr z,monta_el_objeto_del_fondo		;62f1   ; Ocho bytes por ranura
	add hl,de			;62f3   ; Ocho bytes: la ranura siguiente
	djnz L_62F0		;62f4
	xor a			;62f6
	ret			;62f7
monta_el_objeto_del_fondo:		; Rellena la ranura: tipo, contador, la X por ocho, la Y, y los dos bytes que dependen de si viene de arriba o de abajo
	call tipo_del_objeto_del_fondo		;62f8
	ld (hl),a			;62fb
	push af			;62fc
	inc l			;62fd
	ld (hl),000h		;62fe
	inc l			;6300
	ld a,c			;6301
	and 01fh		;6302   ; Los cinco bits bajos por ocho: la columna
	add a,a			;6304
	add a,a			;6305
	add a,a			;6306
	ld (hl),a			;6307
	inc l			;6308
	ld a,(0ec04h)		;6309   ; La fila, de 0xEC04
	ld (hl),a			;630c
	inc l			;630d
	cp 0f8h		;630e   ; Con la fila 0xF8 se pone 0x18, y si no 0xFF
	ld a,018h		;6310
	jr z,L_6316		;6312
	ld a,0ffh		;6314
L_6316:
	ld (hl),a			;6316   ; 0xF8 o 0xFF segun de donde venga
	inc l			;6317
	ld (hl),00fh		;6318   ; Quince
	inc l			;631a   ; 0xE1FF a cero
	pop af			;631b   ; 0xE109: por que renglon del guion va
	dec a			;631c
	add a,a			;631d
	ld (hl),a			;631e
	inc l			;631f
	ld (hl),006h		;6320
	xor a			;6322
	ret			;6323
tipo_del_objeto_del_fondo:		; En la fase 3 el tipo sale de otra cuenta; en las demas, el bit 7 elige entre el 1 y el 2
	ld a,(0e061h)		;6324
	cp 003h		;6327   ; La fase 3 va por otro lado
	jr z,L_6332		;6329
	ld a,001h		;632b
	bit 7,c		;632d   ; El bit 7: uno de los dos tipos
	ret z			;632f
	inc a			;6330
	ret			;6331
L_6332:
	ld a,c			;6332   ; Dos bits de C: uno de cuatro tipos
	rlca			;6333
	rlca			;6334
	and 003h		;6335
	add a,003h		;6337
	ret			;6339

; ----------------------------------------------------------------------
; DATOS tabla_633A: Tres palabras (0x6340, 0x6350, 0x6360) que lee 0x61F2.
;   0x633a..0x6340  (6 bytes)
DATA_tabla_633A:
	defw 06340h,06350h	; 633a  -> DATA_formaciones 0x6350
	defw 06360h	; 633e

; ----------------------------------------------------------------------
; DATOS formaciones: Cuarenta y ocho bytes a los que apunta la tabla de
;   arriba, y que ademas pide p00:4B9F con `ld de,0x6340`.
;   0x6340..0x6370  (48 bytes)
DATA_formaciones:
	defb 000h,000h,000h,000h,000h,09dh,09eh,000h,000h,09fh,0a0h,000h,000h,000h,000h,000h	; 6340  ................
	defb 000h,000h,093h,094h,000h,095h,096h,097h,000h,098h,099h,09ah,000h,09bh,09ch,000h	; 6350  ................
	defb 083h,084h,085h,086h,087h,088h,089h,08ah,08bh,08ch,08dh,08eh,08fh,090h,091h,092h	; 6360  ................

; ----------------------------------------------------------------------
; DATOS trayectorias: Lo que lee 0x61F7 con `ld hl,0x6370`, seguido.
;   0x6370..0x64d4  (356 bytes)
DATA_trayectorias:
	defb 0b0h,063h,0c0h,063h,090h,063h,0a0h,063h,013h,064h,0f0h,063h,059h,064h,036h,064h	; 6370  .c.c.c.c.d.cYd6d
	defb 08ch,064h,07ch,064h,0ach,064h,09ch,064h,0bch,064h,0c8h,064h,0d0h,063h,0e0h,063h	; 6380  .d|d.d.d.d.d.c.c
	defb 066h,067h,06ch,06bh,064h,065h,06ah,069h,063h,000h,000h,068h,07fh,000h,000h,080h	; 6390  fglkdejic..h....
	defb 070h,071h,076h,075h,06eh,06fh,074h,073h,06dh,000h,000h,072h,081h,000h,000h,082h	; 63a0  pqvunotsm..r....
	defb 07fh,000h,000h,080h,063h,000h,000h,068h,064h,065h,06ah,069h,066h,067h,06ch,06bh	; 63b0  ....c..hdejifglk
	defb 081h,000h,000h,082h,06dh,000h,000h,072h,06eh,06fh,074h,073h,070h,071h,076h,075h	; 63c0  ....m..rnotspqvu
	defb 053h,054h,059h,058h,051h,052h,057h,056h,050h,000h,000h,055h,0a6h,000h,000h,0a7h	; 63d0  STYXQRWVP..U....
	defb 05dh,05eh,033h,062h,05bh,05ch,061h,060h,05ah,000h,000h,05fh,0a8h,000h,000h,0a9h	; 63e0  ]^3b[\a`Z.._....
	defb 000h,000h,000h,000h,0d2h,044h,0d3h,000h,000h,0d4h,045h,0d6h,046h,0d5h,000h,000h	; 63f0  .....D....E.F...
	defb 047h,0d7h,0d8h,048h,000h,000h,000h,04ah,0d9h,049h,000h,000h,04bh,04ch,0dah,04dh	; 6400  G..H...J.I..KL.M
	defb 000h,000h,000h,000h,000h,000h,000h,0d2h,044h,0d3h,000h,000h,0d4h,045h,0d6h,046h	; 6410  ........D....E.F
	defb 0d5h,000h,000h,047h,0d7h,0d8h,048h,000h,000h,04eh,0dbh,0d9h,049h,000h,000h,050h	; 6420  ...G..H..N..I..P
	defb 04fh,0dah,04dh,000h,000h,000h,0bdh,051h,0bch,000h,000h,000h,000h,0bfh,053h,0c0h	; 6430  O.M....Q......S.
	defb 052h,0beh,000h,000h,000h,055h,0c2h,0c1h,054h,000h,000h,000h,000h,056h,0c3h,057h	; 6440  R....U..T....V.W
	defb 000h,000h,000h,000h,000h,05ah,0c4h,059h,058h,0bdh,051h,0bch,000h,000h,000h,000h	; 6450  .....Z.YX.Q.....
	defb 0bfh,053h,0c0h,052h,0beh,000h,000h,000h,055h,0c2h,0c1h,054h,000h,000h,000h,000h	; 6460  .S.R....U..T....
	defb 056h,0c3h,0c5h,05bh,000h,000h,000h,000h,05ah,0c4h,05ch,05dh,032h,033h,034h,022h	; 6470  V..[....Z.\]234"
	defb 023h,035h,036h,021h,000h,01dh,01eh,02fh,030h,01fh,031h,020h,032h,033h,034h,022h	; 6480  #56!.../0.1 234"
	defb 023h,035h,036h,021h,000h,01dh,01eh,02fh,030h,037h,038h,020h,000h,0dfh,0e0h,067h	; 6490  #56!.../078 ...g
	defb 068h,0e1h,069h,0e2h,06ah,06bh,06ch,0e4h,0e5h,06dh,06eh,0e3h,000h,0dfh,0e0h,067h	; 64a0  h.i.jkl..mn....g
	defb 068h,06fh,070h,0e2h,06ah,06bh,06ch,0e4h,0e5h,06dh,06eh,0e3h,000h,000h,0dch,0ddh	; 64b0  hop.jkl..mn.....
	defb 000h,000h,05eh,05fh,060h,061h,062h,0deh,026h,027h,028h,029h,02ah,01ch,000h,000h	; 64c0  ..^_`ab.&'()*...
	defb 01ah,01bh,000h,000h	; 64d0

; ----------------------------------------------------------------------
; DATOS tabla_64D4: Treinta y ocho bytes que lee 0x626A.
;   0x64d4..0x64fa  (38 bytes)
DATA_tabla_64D4:
	defb 072h,073h,074h,075h,076h,0a1h,0a2h,0a3h	; 64d4  rstuv...
	defb 0a4h,0a5h,03ah,03bh,03ch,03dh,03eh,03fh	; 64dc  ..:;<=>?
	defb 039h,041h,042h,043h,072h,073h,074h,075h	; 64e4  9ABCrstu
	defb 076h,0a1h,071h,0a3h,0a4h,0a5h,03ah,03bh	; 64ec  v.q...:;
	defb 03ch,03dh,03eh,03fh,02bh,02ch	; 64f4

; ----------------------------------------------------------------------
; DATOS tabla_64FA: Lo que lee 0x62DC con `ld hl,0x64FA`.
;   0x64fa..0x65dc  (226 bytes)
DATA_tabla_64FA:
	defb 02dh,02eh,012h,065h,026h,065h,034h,065h,0bah,065h,0c6h,065h,0c8h,065h,0cah,065h	; 64fa  -..e&e4e.e.e.e.e
	defb 0d2h,065h,0dah,065h,0dah,065h,0dah,065h,0b4h,000h,010h,0d8h,000h,010h,010h,001h	; 650a  .e.e.e.e........
	defb 081h,028h,001h,010h,040h,001h,081h,05ch,001h,010h,0ffh,0ffh,0b8h,000h,08eh,0e4h	; 651a  .(..@..\........
	defb 000h,00bh,01ch,001h,00ch,038h,001h,08eh,0ffh,0ffh,080h,000h,004h,080h,000h,010h	; 652a  .....8..........
	defb 090h,000h,008h,09eh,000h,08dh,0a4h,000h,007h,0a6h,000h,080h,0a8h,000h,08dh,0b0h	; 653a  ................
	defb 000h,080h,0b4h,000h,010h,0beh,000h,089h,0c0h,000h,003h,0c6h,000h,050h,0cah,000h	; 654a  .............P..
	defb 043h,0cah,000h,089h,0e2h,000h,088h,0e2h,000h,050h,0e6h,000h,042h,0eeh,000h,088h	; 655a  C........P..B...
	defb 0f0h,000h,010h,0f4h,000h,002h,0feh,000h,0c5h,0feh,000h,088h,006h,001h,0d3h,00ah	; 656a  ................
	defb 001h,088h,00ch,001h,002h,010h,001h,0d3h,01eh,001h,089h,020h,001h,003h,026h,001h	; 657a  ........... ..&.
	defb 050h,02ah,001h,043h,02ah,001h,089h,042h,001h,088h,042h,001h,050h,046h,001h,042h	; 658a  P*.C*..B..B.PF.B
	defb 04eh,001h,088h,050h,001h,010h,054h,001h,002h,060h,001h,047h,060h,001h,08dh,062h	; 659a  N..P..T..`.G`..b
	defb 001h,080h,06ah,001h,007h,06ah,001h,08dh,074h,001h,010h,076h,001h,080h,0ffh,0ffh	; 65aa  ..j..j..t..v....
	defb 0a8h,000h,081h,0bch,000h,010h,002h,001h,010h,090h,001h,081h,0ffh,0ffh,0ffh,0ffh	; 65ba  ................
	defb 086h,000h,00eh,01eh,001h,00eh,0ffh,0ffh,029h,001h,083h,033h,001h,083h,0ffh,0ffh	; 65ca  ........)..3....
	defb 0ffh,0ffh	; 65da

; ======================================================================
; CODIGO 0x65dc..0x674f  (371 bytes)
; ======================================================================


corre_los_diez_de_e500:		; Los diez objetos de 0xE500: les suma la velocidad, mira si chocan y apaga a los que se salen
	ld ix,0e500h		;65dc
	ld b,00ah		;65e0   ; Diez objetos
L_65E2:
	ld a,(ix+000h)		;65e2
	and a			;65e5
	jr z,L_660B		;65e6
	call 05f7ch		;65e8   ; Les suma su velocidad, y devuelve si siguen dentro
	jr c,L_65F1		;65eb
	ld (ix+000h),000h		;65ed
L_65F1:
	call 098ach		;65f1   ; Y el banco 2 mira si han chocado con algo
	jr c,L_6604		;65f4
	ld a,(ix+004h)		;65f6   ; Pasada la Y 0xB0 o la X 0xF0, se van
	cp 0b0h		;65f9
	jr nc,L_6604		;65fb
	ld a,(ix+006h)		;65fd
	cp 0f0h		;6600
	jr c,L_660B		;6602
L_6604:
	xor a			;6604
	ld (ix+000h),a		;6605
	ld (ix+01bh),a		;6608
L_660B:
	ld de,00020h		;660b   ; Treinta y dos bytes: el objeto siguiente
	add ix,de		;660e
	djnz L_65E2		;6610
	ret			;6612
dispara_el_enemigo:		; Monta un disparo hacia la nave: la velocidad sale de la dificultad, topada en 0x60
	ld a,(0e1c0h)		;6613   ; Con la pantalla parada no se dispara
	and a			;6616
	ret nz			;6617
	ld a,e			;6618
	add a,008h		;6619
	ld e,a			;661b
	ld a,(0e111h)		;661c   ; La dificultad por dos mas 0x50...
	add a,a			;661f
	add a,050h		;6620
	cp 060h		;6622   ; ...topada en 0x60
	jr c,L_6628		;6624   ; Topada en 0x60
	ld a,060h		;6626
L_6628:
	ld (0e110h),a		;6628
	push de			;662b
	call apunta_a_la_nave		;662c
	pop de			;662f
	ld a,(0e115h)		;6630
	and a			;6633
	ret nz			;6634
	ld hl,0e500h		;6635   ; Las diez ranuras de 0xE500
	ld b,00ah		;6638
L_663A:
	ld a,(hl)			;663a
	and a			;663b
	jr z,monta_el_disparo		;663c
	ld a,020h		;663e
	call 0405dh		;6640   ; Treinta y dos bytes: la siguiente
	djnz L_663A		;6643
	ret			;6645
monta_el_disparo:		; Rellena la ranura del disparo con su posicion y las dos velocidades que dejo 0x6677 en 0xEC12 y 0xEC14
	ld a,001h		;6646   ; 0xE112 a uno: hay disparo nuevo
	ld (0e112h),a		;6648   ; 0xE112 a uno: hay disparo nuevo
	ld (hl),a			;664b
	inc l			;664c
	inc l			;664d
	inc l			;664e
	xor a			;664f   ; Los contadores, a cero
	ld (hl),a			;6650
	inc l			;6651
	ld (hl),e			;6652
	inc l			;6653
	ld (hl),a			;6654
	inc l			;6655
	ld (hl),d			;6656
	inc l			;6657
	ld de,(0ec12h)		;6658   ; La velocidad vertical...
	ld (hl),e			;665c
	inc l			;665d
	ld (hl),d			;665e
	ld de,(0ec14h)		;665f   ; ...y la horizontal
	inc l			;6663
	ld (hl),e			;6664
	inc l			;6665
	ld (hl),d			;6666
	inc l			;6667
	ld (hl),000h		;6668   ; El patron y el color
	inc l			;666a
	ld (hl),088h		;666b   ; El patron 0x88 y el color 9
	inc l			;666d
	ld (hl),009h		;666e
	ld de,0000eh		;6670   ; Catorce bytes mas alla, la marca de vivo
	add hl,de			;6673
	ld (hl),001h		;6674
	ret			;6676

; ----------------------------------------------------------------------
; LA PUNTERIA DEL ENEMIGO EMPEORA A PROPOSITO... CON EL REGISTRO R
; De la dificultad 7 en adelante, el disparo del enemigo NO va derecho a la
; nave: se le mete un error sacado del registro R del Z80, cuatro bits, que
; unas veces se suma y otras se resta segun el bit 6 de esa misma lectura.
; Por debajo de la dificultad 7 el tiro va limpio. Es la cuarta vez que el
; cartucho usa el registro de refresco como generador de numeros.
; ----------------------------------------------------------------------
apunta_a_la_nave:		; Calcula hacia donde sale el disparo; de la dificultad 7 en adelante le mete un error del registro R
	call mide_la_distancia_a_la_nave		;6677
	ld a,(0ec17h)		;667a
	ld e,a			;667d
	ld a,(0e111h)		;667e   ; Por debajo de la dificultad 7, sin error
	cp 007h		;6681
	jr c,saca_las_dos_velocidades		;6683
	ld a,r		;6685   ; El registro R: cuatro bits de error
	ld b,a			;6687
	and 00fh		;6688
	bit 6,b		;668a   ; Y su bit 6 decide si se suma o se resta
	jr z,L_6697		;668c   ; El bit 6 decide el signo del error
	ld b,a			;668e
	ld a,c			;668f
	sub b			;6690
	jr nc,L_6694		;6691
	xor a			;6693
L_6694:
	ld e,a			;6694
	jr saca_las_dos_velocidades		;6695
L_6697:
	add a,e			;6697
	cp 03fh		;6698   ; Topado en 0x3F
	jr c,L_669E		;669a
	ld a,03fh		;669c
L_669E:
	ld e,a			;669e

; ----------------------------------------------------------------------
; EL SENO Y EL COSENO SALEN DE LA MISMA TABLA
; Para saber hacia donde sale el disparo hace falta el seno y el coseno del
; angulo, y el cartucho no guarda dos tablas: guarda UNA, la de 0x6853, y
; la lee dos veces. Una con el indice tal cual y otra con 0x3F menos el
; indice, que es justo el angulo complementario. Con eso saca las dos
; componentes, las multiplica por la velocidad (0x6731, con la
; multiplicacion de ocho por ocho hecha a mano de 0x6743) y les pone el
; signo que toque con el complemento a dos de 0x6729.
; ----------------------------------------------------------------------
saca_las_dos_velocidades:		; Lee la tabla de 0x6853 por los dos lados -el indice y su complemento a 0x3F- y de ahi salen las dos velocidades, la vertical y la horizontal
	ld d,000h		;669f
	ld a,e			;66a1
	sub 03fh		;66a2   ; 0x3F menos el indice: el angulo complementario
	neg		;66a4
	ld hl,06853h		;66a6   ; La tabla de 0x6853, leida por los dos extremos
	push hl			;66a9   ; La tabla, por los dos extremos
	add hl,de			;66aa
	ld c,(hl)			;66ab
	pop hl			;66ac
	ld e,a			;66ad
	add hl,de			;66ae
	ld a,(hl)			;66af
	ld (0ec16h),a		;66b0
	ld e,c			;66b3
	call por_la_velocidad		;66b4   ; Por la velocidad
	ld a,(0ec10h)		;66b7   ; 0xEC10 dice si la X va hacia el otro lado
	and a			;66ba
	call nz,cambia_el_signo		;66bb
	ld (0ec12h),de		;66be   ; 0xEC12: la velocidad vertical, la de la diferencia de filas
	ld a,(0ec16h)		;66c2
	ld e,a			;66c5
	call por_la_velocidad		;66c6
	ld a,(0ec11h)		;66c9
	and a			;66cc
	call nz,cambia_el_signo		;66cd
	ld (0ec14h),de		;66d0   ; Y 0xEC14: la horizontal
	ret			;66d4
mide_la_distancia_a_la_nave:		; Saca las dos diferencias en valor absoluto, apunta sus signos en 0xEC10 y 0xEC11, y de la pareja saca el angulo
	ld hl,0ec10h		;66d5
	ld (hl),000h		;66d8
	ld a,(0e204h)		;66da   ; 0xE204: la fila de la nave
	sub e			;66dd
	jr nc,L_66E3		;66de
	neg		;66e0   ; En negativo, se apunta el signo
	inc (hl)			;66e2
L_66E3:
	inc hl			;66e3
	ld (hl),000h		;66e4
	and 0f0h		;66e6
	ld e,a			;66e8
	ld a,(0e206h)		;66e9   ; 0xE206: su columna
	sub d			;66ec
	jr nc,L_66F2		;66ed
	neg		;66ef
	inc (hl)			;66f1
L_66F2:
	ld d,a			;66f2
	ld hl,0e115h		;66f3
	ld (hl),000h		;66f6
	add a,e			;66f8   ; Con la suma de las dos por debajo de 0x30, la nave esta pegada
	jr c,L_6700		;66f9
	cp 030h		;66fb
	jr nc,L_6700		;66fd
	inc (hl)			;66ff
L_6700:
	ld a,d			;6700
	rra			;6701   ; El nibble alto de una y la otra: el indice de la tabla de 0x6753
	rra			;6702
	rra			;6703
	rra			;6704
	and 00fh		;6705
	add a,e			;6707
	ld hl,06753h		;6708
	call 0405dh		;670b
	ld a,(hl)			;670e
	ld (0ec17h),a		;670f   ; 0xEC17 se queda con el angulo
	ld c,a			;6712
	ld hl,(0ec10h)		;6713
	ld a,h			;6716
	ld b,000h		;6717
	and a			;6719
	jr z,L_671E		;671a
	ld b,080h		;671c
L_671E:
	cp l			;671e   ; Y 0xEC18 con el cuadrante, que sale de los dos signos
	ld a,c			;671f
	jr z,L_6724		;6720
	neg		;6722
L_6724:
	add a,b			;6724
	ld (0ec18h),a		;6725
	ret			;6728
cambia_el_signo:		; Complemento a dos de DE
	ld a,d			;6729   ; Complemento a dos: el otro sentido
	cpl			;672a
	ld d,a			;672b
	ld a,e			;672c
	cpl			;672d
	ld e,a			;672e
	inc de			;672f
	ret			;6730
por_la_velocidad:		; Multiplica la componente por la velocidad de 0xE110 y se queda con la parte alta, corrida tres bits
	ld a,(0e110h)		;6731   ; 0xE110: la velocidad del disparo
	ld h,a			;6734
	call multiplica_h_por_e		;6735
	xor a			;6738
	add hl,hl			;6739   ; Tres veces por dos, quedandose con el acarreo
	adc a,a			;673a   ; Y otra vez por dos
	add hl,hl			;673b
	adc a,a			;673c
	add hl,hl			;673d
	adc a,a			;673e
	ld l,h			;673f
	ld h,a			;6740
	ex de,hl			;6741
	ret			;6742
multiplica_h_por_e:		; Multiplicacion de 8 por 8 hecha a mano: ocho `add hl,hl` sumando DE cuando sale acarreo. Devuelve el producto en HL.
	ld b,008h		;6743   ; Ocho vueltas de desplazar y sumar: el clasico
	ld l,000h		;6745
	ld d,l			;6747
L_6748:
	add hl,hl			;6748
	jr nc,L_674C		;6749
	add hl,de			;674b
L_674C:
	djnz L_6748		;674c
	ret			;674e

; ----------------------------------------------------------------------
; DATOS tabla_674F: Cuatro bytes por delante de la base 0x6753.
;   0x674f..0x6753  (4 bytes)
DATA_tabla_674F:
	defb 040h,000h,080h,0c0h	; 674f

; ----------------------------------------------------------------------
; DATOS angulos: Doscientos cincuenta y seis bytes que 0x6708 indexa con el
;   nibble alto de una diferencia y el de la otra: de la pareja (dx, dy) sale
;   el angulo con el que luego se lee el cuarto de seno de 0x6853.
;   0x6753..0x6853  (256 bytes)
DATA_angulos:
	defb 020h,00dh,008h,006h,004h,004h,003h,003h,002h,002h,002h,002h,001h,001h,001h,001h	; 6753   ...............
	defb 033h,020h,016h,010h,00dh,00bh,009h,008h,007h,006h,006h,005h,005h,004h,004h,004h	; 6763  3 ..............
	defb 038h,02ah,020h,019h,015h,011h,00fh,00dh,00ch,00ah,009h,009h,008h,007h,007h,006h	; 6773  8* .............
	defb 03ah,02fh,027h,020h,01bh,017h,014h,012h,010h,00eh,00dh,00ch,00bh,00ah,00ah,009h	; 6783  :/' ............
	defb 03bh,033h,02bh,025h,020h,01ch,019h,016h,014h,012h,010h,00fh,00eh,00dh,00ch,00bh	; 6793  ;3+% ...........
	defb 03ch,035h,02eh,029h,024h,020h,01ch,01ah,017h,015h,014h,012h,011h,010h,00fh,00eh	; 67a3  <5.)$ ..........
	defb 03dh,037h,031h,02ch,027h,023h,020h,01dh,01ah,018h,016h,015h,013h,012h,011h,010h	; 67b3  =71,'# .........
	defb 03dh,038h,033h,02eh,02ah,026h,023h,020h,01dh,01bh,019h,017h,016h,015h,013h,012h	; 67c3  =83.*&# ........
	defb 03dh,039h,034h,030h,02ch,028h,025h,022h,020h,01eh,01ch,01ah,018h,017h,015h,014h	; 67d3  =940,(%" .......
	defb 03eh,039h,035h,031h,02eh,02ah,027h,025h,022h,020h,01eh,01ch,01ah,019h,017h,016h	; 67e3  >951.*'%" ......
	defb 03eh,03ah,036h,033h,02fh,02ch,029h,027h,024h,022h,020h,01eh,01ch,01bh,019h,018h	; 67f3  >:63/,)'$" .....
	defb 03eh,03bh,037h,034h,031h,02eh,02bh,028h,026h,024h,022h,020h,01eh,01dh,01bh,01ah	; 6803  >;741.+(&$" ....
	defb 03eh,03bh,038h,035h,032h,02fh,02ch,02ah,028h,025h,023h,022h,020h,01eh,01dh,01ch	; 6813  >;852/,*(%#" ...
	defb 03eh,03bh,038h,036h,033h,030h,02eh,02bh,029h,027h,025h,023h,021h,020h,01eh,01dh	; 6823  >;8630.+)'%#! ..
	defb 03eh,03ch,039h,036h,034h,031h,02fh,02ch,02ah,028h,026h,025h,023h,021h,020h,01eh	; 6833  ><9641/,*(&%#! .
	defb 03fh,03ch,039h,037h,034h,032h,030h,02dh,02bh,029h,028h,026h,024h,023h,021h,020h	; 6843  ?<97420-+)(&$#!

; ----------------------------------------------------------------------
; DATOS cuarto_de_seno: Sesenta y cuatro bytes que son UN CUARTO DE SENO, de 0
;   a 255: comparados con 255*sen(k/63*90) el error maximo es de 1,9. 0x66A6
;   los lee DOS veces, una con el indice y otra con 0x3F menos el indice, y
;   asi saca el seno y el coseno del mismo angulo de una sola tabla; la
;   comprobacion pitagorica -t[k]^2 mas t[63-k]^2- da entre 0,98 y 1,00 veces
;   255 al cuadrado.
;   0x6853..0x6893  (64 bytes)
DATA_cuarto_de_seno:
	defb 000h,006h,00ch,012h,019h,01fh,026h,02ch,032h,038h,03eh,044h,04ah,050h,056h,05ch	; 6853  ......&,28>DJPV\
	defb 062h,068h,06dh,073h,079h,07eh,084h,089h,08eh,093h,099h,09eh,0a2h,0a7h,0ach,0b1h	; 6863  bhmsy~..........
	defb 0b5h,0b9h,0beh,0c2h,0c6h,0cah,0ceh,0d1h,0d5h,0d8h,0dch,0dfh,0e2h,0e5h,0e7h,0eah	; 6873  ................
	defb 0edh,0efh,0f1h,0f3h,0f5h,0f7h,0f8h,0fah,0fbh,0fch,0fdh,0feh,0feh,0ffh,0ffh,0ffh	; 6883  ................

; ======================================================================
; CODIGO 0x6893..0x6b46  (691 bytes)
; ======================================================================


apunta_las_casillas_de_todos:		; Le calcula a cada objeto la casilla de pantalla en la que cae, para los doce de 0xE300 y los diez de 0xE500
	call los_doce_de_e300		;6893
	call 0a22dh		;6896   ; Y una rutina del banco 3
	call los_de_e500_si_toca		;6899
	call hay_algo_en_e151		;689c   ; Y los diez de 0xE500
	ret c			;689f
los_diez_de_e500:		; Los diez objetos de 0xE500
	ld ix,0e500h		;68a0
	ld b,00ah		;68a4
	jr L_68B5		;68a6
los_de_e500_si_toca:		; Solo con 0xE1B0 puesto
	ld a,(0e1b0h)		;68a8
	or a			;68ab
	ret z			;68ac
	jr los_diez_de_e500		;68ad
los_doce_de_e300:		; Los doce objetos de 0xE300
	ld ix,0e300h		;68af   ; Las doce ranuras de 0xE300
	ld b,00ch		;68b3
L_68B5:
	push bc			;68b5   ; Doce
	call casilla_del_objeto		;68b6
	pop bc			;68b9
	ld de,00020h		;68ba   ; Treinta y dos bytes: el objeto siguiente
	add ix,de		;68bd
	djnz L_68B5		;68bf
	ret			;68c1
casilla_del_objeto:		; De la X y la Y del objeto saca la casilla del mapa y la guarda en los bytes 30 y 31, y copia dos bytes mas
	ld a,(ix+000h)		;68c2
	and a			;68c5
	ret z			;68c6
	ld a,(ix+00bh)		;68c7   ; El byte 11 a cero: no se dibuja con caracteres
	and a			;68ca
	ret z			;68cb
	ld l,(ix+004h)		;68cc   ; La Y y la X
	ld h,(ix+006h)		;68cf
	call 0571bh		;68d2   ; La rutina del banco 0 que convierte casilla en direccion de RAM
	ld (ix+01eh),l		;68d5   ; Los bytes 30 y 31: donde cae
	ld (ix+01fh),h		;68d8
	push ix		;68db
	pop de			;68dd
	ld a,013h		;68de   ; Trece bytes mas alla
	add a,e			;68e0   ; Trece bytes mas alla, la pareja de caracteres
	ld e,a			;68e1
	ldi		;68e2
	ldi		;68e4
	ld bc,0001eh		;68e6
	add hl,bc			;68e9
	ldi		;68ea
	ldi		;68ec
	ret			;68ee
hay_algo_en_e151:		; Devuelve acarreo si 0xE151 esta a cero o si 0xE152 no lo esta
	ld hl,(0e151h)		;68ef   ; Con 0xE151 a cero no hay jefe
	ld a,l			;68f2   ; 0xE152 a cero: no hay jefe
	and a			;68f3
	scf			;68f4
	ret z			;68f5
	ld a,h			;68f6
	and a			;68f7
	ret z			;68f8
	scf			;68f9
	ret			;68fa
corre_los_cuatro_de_e800_y_ea80:		; Con 0xE151 puesto y 0xE152 en 1 o en 4-5, recorre los cuatro pares de ranuras
	ld hl,0e151h		;68fb   ; Sin jefe no hay nada que guardar
	ld a,(hl)			;68fe
	or a			;68ff
	ret z			;6900
	inc l			;6901   ; 0xE152: el paso del jefe
	ld a,(hl)			;6902
	dec a			;6903
	jp z,L_690C		;6904
	sub 004h		;6907
	cp 002h		;6909
	ret nc			;690b
L_690C:
	ld ix,0e800h		;690c   ; 0xE800 y su pareja en 0xEA80
	ld iy,0ea80h		;6910
	ld b,004h		;6914   ; Cuatro
L_6916:
	push bc			;6916
	call L_6928		;6917
	ld de,00008h		;691a   ; Ocho bytes en una tabla y dieciseis en la otra
	add ix,de		;691d
	ld de,00010h		;691f
	add iy,de		;6922
	pop bc			;6924
	djnz L_6916		;6925
	ret			;6927
L_6928:
	ld a,(ix+000h)		;6928   ; La ranura a cero esta libre
	or a			;692b   ; La posicion del objeto
	ret z			;692c
	ld l,(ix+002h)		;692d
	ld h,(ix+003h)		;6930
	jp L_696F		;6933
corre_los_de_e780_y_ea00:		; Ocho pares, o uno solo si 0xE152 vale 6
	ld hl,0e151h		;6936
	ld a,(hl)			;6939
	or a			;693a
	ret z			;693b
	ld b,008h		;693c   ; Ocho pares
	inc l			;693e
	ld a,(hl)			;693f
	dec a			;6940
	jp z,L_694D		;6941
	sub 004h		;6944   ; Con 0xE152 en 5 tambien
	jp z,L_694D		;6946
	dec a			;6949
	ret nz			;694a
	ld b,001h		;694b   ; Y en el 6, uno solo
L_694D:
	ld ix,0e780h		;694d
	ld iy,0ea00h		;6951
L_6955:
	push bc			;6955
	call guarda_lo_que_habia		;6956
	ld de,00010h		;6959   ; Dieciseis bytes cada una
	add ix,de		;695c   ; Dieciseis bytes cada una
	add iy,de		;695e   ; Dieciseis bytes cada una
	pop bc			;6960
	djnz L_6955		;6961
	ret			;6963
guarda_lo_que_habia:		; Se guarda en la tabla espejo el rectangulo de 4x4 caracteres que hay debajo del objeto, para poder devolverlo
	ld a,(ix+000h)		;6964
	or a			;6967
	ret z			;6968
	ld l,(ix+003h)		;6969
	ld h,(ix+005h)		;696c
L_696F:
	call 0571bh		;696f   ; La casilla del mapa donde cae
	push iy		;6972
	pop de			;6974
	ld a,004h		;6975   ; Cuatro filas
L_6977:
	ld bc,00004h		;6977   ; Cuatro caracteres por fila
	ldir		;697a
	ld c,01ch		;697c   ; 0x1C: lo que falta hasta la fila de abajo
	add hl,bc			;697e   ; Cuatro caracteres por fila
	dec a			;697f   ; 0x1C: lo que falta hasta la fila de abajo
	jr nz,L_6977		;6980
	ret			;6982
pinta_todo_lo_del_cuadro:		; La tira de dibujado: los objetos, el fondo, los de 0xE800 y los de 0xE780, cada uno con su rutina
	call 0a2c7h		;6983
	call dibuja_los_de_e300		;6986
	call 09074h		;6989
	call dibuja_los_de_e500		;698c
	call pinta_los_del_fondo		;698f
	call 0b42eh		;6992
	call despacha_el_dibujo_del_jefe		;6995
	call dibuja_los_de_e500_si_toca		;6998
	ld hl,0e151h		;699b   ; 0xE151 dice si hay jefe en pantalla
	ld a,(hl)			;699e
	or a			;699f
	jp z,borra_los_de_e800		;69a0
	inc l			;69a3
	ld a,(hl)			;69a4
	dec a			;69a5   ; Y 0xE152 en que paso va
	jp z,guarda_lo_de_los_cuatro		;69a6
	inc a			;69a9
	cp 005h		;69aa   ; Sin jefe, se borran los cuatro de 0xE800
	jp nc,guarda_lo_de_los_cuatro		;69ac
	jp borra_los_de_e800		;69af
dibuja_los_de_e500_si_toca:		; Solo si hay algo en 0xE151
	call hay_algo_en_e151		;69b2
	ret c			;69b5
L_69B6:
	ld ix,0e500h		;69b6   ; Las diez ranuras de 0xE500
	ld b,00ah		;69ba
	jr dibuja_dos_por_dos		;69bc
dibuja_los_de_e500:		; Solo con 0xE1B0 puesto
	ld a,(0e1b0h)		;69be
	or a			;69c1
	ret z			;69c2
	jr L_69B6		;69c3
dibuja_los_de_e300:		; Los doce objetos
	ld ix,0e300h		;69c5   ; Y las doce de 0xE300
	ld b,00ch		;69c9
dibuja_dos_por_dos:		; Escribe en el mapa los cuatro caracteres del objeto: dos arriba y dos en la fila de abajo
	ld a,(ix+000h)		;69cb
	and a			;69ce
	jr z,L_69FB		;69cf
	ld a,(ix+00bh)		;69d1   ; El byte 11 a cero: este no se dibuja asi
	and a			;69d4
	jr z,L_69FB		;69d5
	ld a,(ix+006h)		;69d7   ; Pasada la X 0xF8, tampoco
	cp 0f8h		;69da
	jr nc,L_69FB		;69dc
	ld l,(ix+01eh)		;69de   ; La casilla, de los bytes 30 y 31
	ld h,(ix+01fh)		;69e1
	ld a,(ix+013h)		;69e4   ; Los bytes 19 y 20: los dos caracteres de arriba
	ld (hl),a			;69e7
	inc hl			;69e8
	ld a,(ix+014h)		;69e9
	ld (hl),a			;69ec
	ld a,01fh		;69ed   ; 0x1F: la fila de abajo
	call 0405dh		;69ef
	ld a,(ix+015h)		;69f2   ; Y los bytes 21 y 22: los dos de abajo
	ld (hl),a			;69f5
	inc hl			;69f6
	ld a,(ix+016h)		;69f7
	ld (hl),a			;69fa
L_69FB:
	ld de,00020h		;69fb   ; Treinta y dos bytes: el objeto siguiente
	add ix,de		;69fe
	djnz dibuja_dos_por_dos		;6a00
	ret			;6a02
guarda_lo_de_los_cuatro:		; Los cuatro de 0xE800, con su tabla espejo en 0xEA80
	ld ix,0e800h		;6a03
	ld iy,0ea80h		;6a07
	ld b,004h		;6a0b
L_6A0D:
	push bc			;6a0d   ; Cuatro objetos
	call guarda_lo_de_uno		;6a0e
	ld de,00008h		;6a11   ; Ocho bytes en una tabla y dieciseis en la otra
	add ix,de		;6a14
	ld de,00010h		;6a16
	add iy,de		;6a19
	pop bc			;6a1b
	djnz L_6A0D		;6a1c
	ret			;6a1e
guarda_lo_de_uno:		; La casilla de ese objeto, y a copiar
	ld a,(ix+000h)		;6a1f   ; La ranura a cero esta libre
	or a			;6a22   ; La ranura a cero esta libre
	ret z			;6a23   ; La posicion del objeto
	ld l,(ix+002h)		;6a24
	ld h,(ix+003h)		;6a27
	jr copia_cuatro_por_cuatro		;6a2a
guarda_lo_de_e780:		; Un solo objeto de 0xE780
	ld ix,0e780h		;6a2c
	ld iy,0ea00h		;6a30
	jp guarda_uno_de_e780		;6a34
guarda_lo_de_los_ocho:		; Los ocho de 0xE780, con su espejo en 0xEA00
	ld b,008h		;6a37
	ld ix,0e780h		;6a39
	ld iy,0ea00h		;6a3d
L_6A41:
	push bc			;6a41   ; Dieciseis bytes cada una
	call guarda_uno_de_e780		;6a42
	ld de,00010h		;6a45   ; Dieciseis bytes: la pieza siguiente
	add ix,de		;6a48
	add iy,de		;6a4a
	pop bc			;6a4c
	djnz L_6A41		;6a4d
	ret			;6a4f
guarda_uno_de_e780:		; Igual, pero con la posicion en los bytes 3 y 5
	ld a,(ix+000h)		;6a50
	or a			;6a53
	ret z			;6a54
	ld l,(ix+003h)		;6a55   ; La posicion de la pieza
	ld h,(ix+005h)		;6a58
copia_cuatro_por_cuatro:		; Copia el rectangulo de cuatro por cuatro caracteres de la pantalla a la tabla espejo
	call 0571bh		;6a5b   ; La casilla del mapa donde cae
	push iy		;6a5e
	pop de			;6a60
	ex de,hl			;6a61
	ld a,004h		;6a62   ; Cuatro filas
L_6A64:
	ld bc,00004h		;6a64   ; Cuatro caracteres por fila
	ldir		;6a67
	ld c,01ch		;6a69   ; Y 0x1C hasta la fila siguiente
	ex de,hl			;6a6b
	add hl,bc			;6a6c
	ex de,hl			;6a6d
	dec a			;6a6e
	jr nz,L_6A64		;6a6f
	ret			;6a71

; ----------------------------------------------------------------------
; SACAR UN OBJETO NUEVO A LA PANTALLA
; Esta es la rutina mas llamada del banco: la usan todos los motores de
; enemigo para soltar un disparo, una explosion o un enemigo nuevo. Se le
; entra con A = el tipo, DE = donde va y C = un ajuste, y ella busca una
; ranura libre en la tabla de objetos, la rellena con la ficha que le toca
; al tipo -cuatro bytes de la tabla de 0x6BA3- y sube la cuenta de vivos.
; Tres tipos se salen de lo normal: el 0x1E necesita TRES ranuras seguidas
; (por eso 0x6AA1 busca tres huecos consecutivos y suma dos a la cuenta),
; el 0x0E va a otra tabla -la de 0xE460, de ocho ranuras de 0x20 bytes
; contando hacia atras- y los demas a la de 0xE300, doce ranuras.
; ----------------------------------------------------------------------
saca_un_objeto:		; Busca ranura libre y monta ahi un objeto del tipo A, en la posicion DE
	ld (0ec19h),de		;6a72   ; Donde va, apuntado en 0xEC19
	ld (0e120h),a		;6a76   ; Y el tipo, en 0xE120
	xor a			;6a79
	ld (0e124h),a		;6a7a
	ld a,c			;6a7d
	ld (0e121h),a		;6a7e
	ld a,(0e120h)		;6a81
	cp 01eh		;6a84   ; El tipo 0x1E ocupa tres ranuras
	jp z,busca_tres_ranuras_seguidas		;6a86
	sub 00eh		;6a89   ; Y el 0x0E va a la otra tabla
	jr z,busca_en_la_otra_tabla		;6a8b
	ld hl,0e300h		;6a8d   ; Las doce ranuras de 0xE300, de 0x20 en 0x20
	ld b,00ch		;6a90
	ld de,00020h		;6a92
	xor a			;6a95
	jr busca_ranura_libre		;6a96
busca_tres_ranuras_seguidas:		; El objeto grande necesita tres huecos consecutivos; si no los hay, no sale
	ld hl,0e300h		;6a98
	ld c,00ch		;6a9b
	ld de,00020h		;6a9d
	xor a			;6aa0
L_6AA1:
	ld b,003h		;6aa1   ; Tres seguidos
L_6AA3:
	cp (hl)			;6aa3   ; Tres huecos seguidos
	add hl,de			;6aa4   ; Se compara con cero: ranura libre
	jr nz,L_6AAE		;6aa5   ; Treinta y dos bytes: la ranura siguiente
	dec b			;6aa7
	jr z,L_6AB2		;6aa8
	dec c			;6aaa
	jr nz,L_6AA3		;6aab
	ret			;6aad
L_6AAE:
	dec c			;6aae
	jr nz,L_6AA1		;6aaf
	ret			;6ab1
L_6AB2:
	ld de,0ffa0h		;6ab2   ; Se retrocede a la primera de las tres
	add hl,de			;6ab5
	exx			;6ab6
	ld hl,0e126h		;6ab7   ; Y dos mas en la cuenta de vivos: son tres ranuras
	inc (hl)			;6aba
	inc (hl)			;6abb
	exx			;6abc
	jr monta_el_objeto		;6abd
busca_en_la_otra_tabla:		; El tipo 0x0E vive en 0xE460, ocho ranuras contadas hacia atras
	ld de,0ffe0h		;6abf   ; El tipo 0x0E va a la tabla de 0xE460
	ld b,008h		;6ac2
	ld hl,0e460h		;6ac4   ; Ocho ranuras contando hacia atras
busca_ranura_libre:		; La primera con el primer byte a cero
	cp (hl)			;6ac7
	jr z,monta_el_objeto		;6ac8
	add hl,de			;6aca
	djnz busca_ranura_libre		;6acb
	ret			;6acd
monta_el_objeto:		; Rellena la ranura: tipo, contadores a cero, la posicion, y los cuatro bytes de la tabla de 0x6BA3
	ld de,(0ec19h)		;6ace   ; La posicion, que se aparco en 0xEC19
	exx			;6ad2
	ld hl,0e126h		;6ad3   ; Una mas en la cuenta de objetos vivos
	inc (hl)			;6ad6
	exx			;6ad7
	push hl			;6ad8
	pop ix		;6ad9
	ld a,(0e120h)		;6adb
	ld (0e124h),a		;6ade
	ld (ix+01bh),003h		;6ae1   ; El byte 27 a tres
	ld (hl),a			;6ae5
	inc l			;6ae6
	xor a			;6ae7
	ld (hl),a			;6ae8
	inc l			;6ae9
	ld (hl),a			;6aea
	inc l			;6aeb
	inc l			;6aec
	ld (hl),e			;6aed   ; La Y va al byte 4...
	inc l			;6aee
	inc l			;6aef
	ld (hl),d			;6af0   ; ...y la X al 6
	ld de,00005h		;6af1
	add hl,de			;6af4
	ld de,06ba3h		;6af5   ; La tabla de 0x6BA3: cuatro bytes por tipo
	ld a,(0e120h)		;6af8
	add a,a			;6afb   ; Por cuatro
	add a,a			;6afc
	add a,e			;6afd
	ld e,a			;6afe
	jr nc,L_6B02		;6aff
	inc d			;6b01
L_6B02:
	ex de,hl			;6b02   ; Tres bytes de la ficha del tipo
	ldi		;6b03
	ldi		;6b05
	ldi		;6b07
	ld a,(0e121h)		;6b09   ; Con el ajuste puesto, el byte 13 lleva 8; el tipo 0x0D, 6
	ld (de),a			;6b0c   ; El byte 13: ocho, o seis si es el tipo 0x0D
	and a			;6b0d   ; El tipo 0x0D lleva seis
	jr z,L_6B1E		;6b0e
	ld b,008h		;6b10
	ld a,(0e120h)		;6b12
	cp 00dh		;6b15
	jr nz,L_6B1B		;6b17
	ld b,006h		;6b19
L_6B1B:
	ld (ix+00dh),b		;6b1b
L_6B1E:
	inc e			;6b1e
	ldi		;6b1f
	call velocidad_del_disparo		;6b21   ; La velocidad, que sale de la dificultad y del registro R
	ld (de),a			;6b24
	inc de			;6b25
	xor a			;6b26
	ld (de),a			;6b27
	ld a,(0e120h)		;6b28   ; Los tipos 2, 0x0A y 0x0C llevan dos bytes mas
	cp 002h		;6b2b   ; El tipo, otra vez
	jr z,L_6B37		;6b2d
	cp 00ah		;6b2f
	jr z,L_6B37		;6b31
	cp 00ch		;6b33
	jr nz,L_6B3F		;6b35
L_6B37:
	ld a,001h		;6b37
	ld (de),a			;6b39
	inc de			;6b3a
	ld a,(0e166h)		;6b3b   ; 0xE166
	ld (de),a			;6b3e
L_6B3F:
	ld a,(0e120h)		;6b3f   ; Y cada tipo remata su ficha por su cuenta: treinta y una salidas
	dec a			;6b42
	call 04067h		;6b43

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_6B43: Treinta y una palabras pegadas detras del
;   `call 0x4067` de 0x6B43. Casi todos los destinos caen en el banco 3
;   (0xA000-0xBFFF).
;   0x6b46..0x6b84  (62 bytes)
DATA_tabla_del_despachador_6B43:
	defw 06c23h,0a8a9h	; 6b46  -> remata_el_tipo_1 0xa8a9
	defw 0a821h,0a857h	; 6b4a
	defw 0a9d4h,0a937h	; 6b4e
	defw 06c3fh,0acafh	; 6b52  -> remata_el_tipo_7 0xacaf
	defw 0ad27h,0ad6eh	; 6b56
	defw 0adb9h,0ae07h	; 6b5a
	defw 0af95h,06c57h	; 6b5e  -> 0xaf95 remata_con_punteria
	defw 06c77h,06cb4h	; 6b62  -> remata_el_tipo_15 pon_las_dos_velocidades
	defw 06ca6h,06b96h	; 6b66  -> remata_el_tipo_16 L_6B96
	defw 06b96h,06b96h	; 6b6a  -> L_6B96 L_6B96
	defw 06b96h,0a7b9h	; 6b6e  -> L_6B96 0xa7b9
	defw 0a7c0h,0a7cbh	; 6b72
	defw 0a7d6h,06b96h	; 6b76  -> 0xa7d6 L_6B96
	defw 0b8dah,06c53h	; 6b7a  -> 0xb8da remata_con_punteria_lenta
	defw 0b9c1h,0bbf1h	; 6b7e
	defw 06b96h	; 6b82  -> L_6B96

; ======================================================================
; CODIGO 0x6b84..0x6b97  (19 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LA VELOCIDAD DE LOS DISPAROS: DIFICULTAD MAS REGISTRO R
; La velocidad con la que sale un disparo no es fija ni es un azar de
; verdad: se coge de la tabla de 0x6B97 el valor que le toca a la
; dificultad (0xE111, doce escalones de 0x80 a 0x1C, o sea cuanto mas
; dificil mas rapido) y se le SUMA lo que digan tres bits del registro R
; del Z80, el del refresco de la memoria. Es la tercera vez que este
; cartucho usa el R como generador de numeros: las otras dos son las
; estrellas del fondo y la metralla de la explosion, las dos en el banco 0.
; ----------------------------------------------------------------------
velocidad_del_disparo:		; El escalon de velocidad que diga la dificultad, mas cero a siete del registro R
	push hl			;6b84
	ld a,(0e111h)		;6b85   ; 0xE111 es la dificultad
	ld hl,06b97h		;6b88
	add a,l			;6b8b
	ld l,a			;6b8c
	jr nc,L_6B90		;6b8d
	inc h			;6b8f
L_6B90:
	ld a,r		;6b90   ; El registro R: tres bits de desigualdad
	and 007h		;6b92
	add a,(hl)			;6b94
	pop hl			;6b95
L_6B96:
	ret			;6b96

; ----------------------------------------------------------------------
; DATOS velocidades_por_dificultad: Doce escalones de velocidad, uno por nivel
;   de dificultad (0xE111), en cuesta abajo: 0x80, 0x70, 0x68, 0x60, 0x48,
;   0x40, 0x38, 0x30, 0x28, 0x24, 0x20 y 0x1C. Cuanto mas bajo el numero, mas
;   rapido va el disparo. Los lee 0x6B88, que ademas le suma tres bits del
;   registro R.
;   0x6b97..0x6ba3  (12 bytes)
DATA_velocidades_por_dificultad:
	defb 080h,070h,068h,060h,048h,040h,038h,030h,028h,024h,020h,01ch	; 6b97  .ph`H@80($ .

; ----------------------------------------------------------------------
; DATOS fichas_por_tipo: Cuatro bytes por tipo de objeto, que 0x6AF5 copia tal
;   cual a la ranura recien montada: es la ficha de arranque de cada bicho.
;   Treinta y dos tipos.
;   0x6ba3..0x6c23  (128 bytes)
DATA_fichas_por_tipo:
	defb 01ah,018h,014h,010h	; 6ba3
	defb 001h,000h,000h,001h	; 6ba7
	defb 001h,000h,000h,001h	; 6bab
	defb 000h,08ch,00eh,001h	; 6baf
	defb 000h,0b0h,002h,001h	; 6bb3
	defb 000h,0e8h,00ah,001h	; 6bb7
	defb 000h,0a4h,005h,001h	; 6bbb
	defb 001h,004h,000h,001h	; 6bbf
	defb 000h,0bch,004h,001h	; 6bc3
	defb 000h,0dch,00ah,001h	; 6bc7
	defb 000h,0bch,002h,001h	; 6bcb
	defb 000h,0ech,002h,0ffh	; 6bcf
	defb 001h,029h,000h,001h	; 6bd3
	defb 000h,0e0h,004h,005h	; 6bd7
	defb 000h,0fch,008h,001h	; 6bdb
	defb 000h,0cch,000h,001h	; 6bdf
	defb 000h,088h,008h,001h	; 6be3
	defb 001h,000h,000h,005h	; 6be7
	defb 000h,000h,000h,000h	; 6beb
	defb 000h,000h,000h,000h	; 6bef
	defb 000h,000h,000h,000h	; 6bf3
	defb 000h,000h,000h,000h	; 6bf7
	defb 001h,037h,000h,001h	; 6bfb
	defb 001h,038h,000h,001h	; 6bff
	defb 001h,038h,000h,001h	; 6c03
	defb 001h,000h,000h,001h	; 6c07
	defb 001h,000h,000h,001h	; 6c0b
	defb 000h,0f0h,00fh,00ah	; 6c0f
	defb 000h,0cch,009h,001h	; 6c13
	defb 000h,0a0h,006h,001h	; 6c17
	defb 000h,0d0h,007h,005h	; 6c1b
	defb 000h,0e8h,007h,001h	; 6c1f

; ======================================================================
; CODIGO 0x6c23..0x6cd7  (180 bytes)
; ======================================================================


remata_el_tipo_1:		; Le pone la velocidad partida por dos y el dibujo que digan los bits 5 y 6 de 0xE122
	call 09181h		;6c23
	sra a		;6c26   ; Partida por dos, con el signo
	ld (ix+010h),a		;6c28
	ld a,(0e122h)		;6c2b
	ld c,a			;6c2e
	xor a			;6c2f
	bit 5,c		;6c30   ; El bit 5 de 0xE122...
	jr z,L_6C36		;6c32
	ld a,002h		;6c34
L_6C36:
	bit 6,c		;6c36   ; ...y el bit 6: entre los dos eligen uno de cuatro dibujos
	jr nz,L_6C3B		;6c38
	inc a			;6c3a
L_6C3B:
	ld (ix+017h),a		;6c3b
	ret			;6c3e
remata_el_tipo_7:		; El bicho de la escotilla: sale hacia un lado o hacia el otro, segun el bit 0 del tipo de quien lo suelta, y sin velocidad vertical
	ld a,(0e123h)		;6c3f
	ld de,00400h		;6c42   ; 0x0400 hacia la derecha...
	rra			;6c45
	jr nc,L_6C4B		;6c46
	ld de,0fc00h		;6c48   ; ...o 0xFC00 hacia la izquierda
L_6C4B:
	call pon_la_velocidad_vertical		;6c4b
	ld de,00000h		;6c4e
	jr pon_la_velocidad_horizontal		;6c51
remata_con_punteria_lenta:		; Velocidad base 0x50 mas dos veces la dificultad
	ld c,050h		;6c53
	jr L_6C59		;6c55
remata_con_punteria:		; Lo mismo pero con base 0x60
	ld c,060h		;6c57
L_6C59:
	ld a,(0e111h)		;6c59   ; La dificultad por dos, sumada a la base
	add a,a			;6c5c
	add a,c			;6c5d
	ld (0e110h),a		;6c5e
apunta_desde_donde_esta:		; Con la posicion del objeto, calcula las dos velocidades hacia la nave y se las guarda
	ld e,(ix+004h)		;6c61
	ld d,(ix+006h)		;6c64
	call apunta_a_la_nave		;6c67
	ld de,(0ec12h)		;6c6a   ; La velocidad vertical...
	call pon_la_velocidad_vertical		;6c6e
	ld de,(0ec14h)		;6c71   ; ...y la horizontal
	jr pon_la_velocidad_horizontal		;6c75
remata_el_tipo_15:		; Copia las velocidades de 0xE142 y 0xE144, y le pone de seis a ocho de contador con el registro R
	ld hl,(0e142h)		;6c77   ; La velocidad que lleva el fondo
	ld (ix+007h),l		;6c7a
	ld (ix+008h),h		;6c7d
	ld hl,(0e144h)		;6c80
	ld (ix+009h),l		;6c83
	ld (ix+00ah),h		;6c86
	ld a,(0e061h)		;6c89   ; En la fase 4 el desplazamiento va al reves
	cp 004h		;6c8c
	ld hl,00088h		;6c8e
	jr nz,L_6C96		;6c91
	ld hl,0ff78h		;6c93
L_6C96:
	ld (ix+017h),l		;6c96
	ld (ix+018h),h		;6c99
	ld a,r		;6c9c   ; El registro R otra vez: seis u ocho
	and 002h		;6c9e
	add a,006h		;6ca0
	ld (ix+00dh),a		;6ca2
	ret			;6ca5
remata_el_tipo_16:		; El dibujo sale de 0xEC1B y no lleva velocidad
	ld a,(0ec1bh)		;6ca6
	ld (ix+00ch),a		;6ca9   ; El dibujo, del byte 12
	ld de,00000h		;6cac
	call pon_la_velocidad_vertical		;6caf   ; Sin velocidad
	jr pon_la_velocidad_horizontal		;6cb2
pon_las_dos_velocidades:		; Las dos velocidades, cruzadas: primero la de Y y luego la de X
	ld de,(0ec14h)		;6cb4
	call pon_la_velocidad_horizontal		;6cb8   ; Primero la de Y...
	ld de,(0ec12h)		;6cbb   ; ...y luego la de X
pon_la_velocidad_vertical:		; La velocidad vertical del objeto, en los bytes 7 y 8
	ld (ix+007h),e		;6cbf
	ld (ix+008h),d		;6cc2
	ret			;6cc5
pon_la_velocidad_horizontal:		; Y la horizontal, en los bytes 9 y 10
	ld (ix+009h),e		;6cc6   ; Los bytes 9 y 10
	ld (ix+00ah),d		;6cc9
	ret			;6ccc
reparte_por_la_fase:		; Doce salidas, una por fase
	call mira_que_musica_toca		;6ccd
	ld a,(0e061h)		;6cd0
	dec a			;6cd3
	call 04067h		;6cd4

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_6CD4: Doce palabras pegadas detras del `call
;   0x4067` de 0x6CD4.
;   0x6cd7..0x6cef  (24 bytes)
DATA_tabla_del_despachador_6CD4:
	defw 06cefh,06d66h	; 6cd7  -> final_de_la_fase_1 final_de_la_fase_2
	defw 06da7h,06e15h	; 6cdb  -> final_de_la_fase_3 final_de_la_fase_4
	defw 06ea8h,06ef0h	; 6cdf  -> final_de_la_fase_5 final_de_la_fase_6
	defw 06f19h,06f43h	; 6ce3  -> final_de_la_fase_7 final_de_la_fase_8
	defw 06f97h,06fa0h	; 6ce7  -> final_de_la_fase_9 final_de_la_fase_10
	defw 06fa9h,06fb2h	; 6ceb  -> final_de_la_fase_11 final_de_la_fase_12

; ======================================================================
; CODIGO 0x6cef..0x7058  (873 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL FINAL DE CADA FASE, UNO POR FASE
; La tabla de 0x6CD7 reparte por la fase: cada una tiene aqui su propia
; maquinita de estados, con el paso en 0xE065, y todas siguen el mismo
; guion: se espera a que la distancia recorrida llegue a un punto, se
; enciende el jefe (0xE151), se espera a que lo maten (0xE150) y se deja
; pasar a la fase siguiente. Lo que cambia de una a otra son las distancias
; y a que rutina del banco 2 o 3 se llama.
; ----------------------------------------------------------------------
final_de_la_fase_1:		; Espera a la distancia 0x165, enciende el aviso de 0xE140 y deja el limite en 0x1C2
	ld a,(0e065h)		;6cef   ; 0xE065: el paso del final de fase
	dec a			;6cf2   ; 0xE065: el paso del final de fase
	jr z,espera_a_que_muera		;6cf3
	dec a			;6cf5
	jr z,enciende_al_jefe		;6cf6
	dec a			;6cf8
	jr z,acaba_la_fase		;6cf9
	ld a,(0e1b0h)		;6cfb
	and a			;6cfe
	jr nz,apaga_el_jefe		;6cff
	ld hl,(0e063h)		;6d01   ; La distancia recorrida...
	ld de,00165h		;6d04   ; ...contra 0x165
	rst 20h			;6d07
	jp z,08e77h		;6d08
	ld a,(0e107h)		;6d0b   ; Solo en los pasos con columna nueva
	and a			;6d0e
	ret z			;6d0f
	ld a,001h		;6d10
	ld (0e140h),a		;6d12
	ld hl,001c2h		;6d15   ; Y el desplazamiento se para en 0x1C2
	ld (0e148h),hl		;6d18
sube_el_paso_del_final:		; 0xE065 + 1
	ld hl,0e065h		;6d1b
	inc (hl)			;6d1e
	ret			;6d1f
apaga_el_jefe:		; Con 0xE150 puesto, apaga la bandera y el aviso de 0xE1B0
	ld hl,0e150h		;6d20   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6d23
	and a			;6d24
	ret z			;6d25
	xor a			;6d26
	ld (hl),a			;6d27
	ld (0e1b0h),a		;6d28
	ret			;6d2b
espera_a_que_muera:		; Hasta que 0xE150 no se ponga, no se sigue; luego suelta el desplazamiento hasta 0x1C0
	ld hl,0e150h		;6d2c   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6d2f   ; 0xE150: hasta que no muera, no
	and a			;6d30
	ret z			;6d31
	xor a			;6d32
	ld (0e140h),a		;6d33
	ld hl,001c0h		;6d36   ; El desplazamiento llega hasta 0x1C0
	ld (0e105h),hl		;6d39
	jr sube_el_paso_del_final		;6d3c
enciende_al_jefe:		; 0xE151 a uno: el jefe entra en pantalla
	ld a,(0e107h)		;6d3e
	and a			;6d41
	ret z			;6d42
L_6D43:
	xor a			;6d43   ; 0xE150 a cero y 0xE114 a uno
	ld (0e150h),a		;6d44
	inc a			;6d47
	ld (0e114h),a		;6d48   ; 0xE114 a uno
	ld hl,00001h		;6d4b   ; Y 0xE151 y 0xE152: el jefe en su primer paso
	ld (0e151h),hl		;6d4e
	jr sube_el_paso_del_final		;6d51

; ----------------------------------------------------------------------
; EL ORDEN DE LAS FASES NO ES 1, 2, 3...
; De una fase se sale por dos sitios distintos, y de ahi sale el recorrido
; de verdad del cartucho:
; - acaba_la_fase (0x6D53) llama a pasa_a_la_fase_siguiente, que sube
; 0xE061 en uno y da la vuelta pasada la octava.
; - salta_a_la_fase (0x6FB9) le mete a 0xE061 un numero escrito a mano,
; y a el saltan OCHO sitios, cada uno con su numero.
; Las fases 2, 3, 4 y 7 miran 0xE1C0 -la pantalla parada- y, si lo esta,
; saltan a la 9, la 10, la 11 y la 12; y esas cuatro, al acabar, saltan a
; la 3, la 4, la 5 y la 8, que son los cuatro bytes de fases_por_ronda.
; O sea que las doce fases se juegan asi:
; 1 - 2 - 9 - 3 - 10 - 4 - 11 - 5 - 6 - 7 - 12 - 8 - final - 1
; Las cuatro de dos cifras son interludios metidos entre las otras, no una
; segunda vuelta ni un tramo suelto.
; ----------------------------------------------------------------------
acaba_la_fase:		; Apaga al jefe y, si la nave sigue viva, sube la fase en uno
	ld a,(0e150h)		;6d53
	and a			;6d56
	ret z			;6d57
	ld hl,00000h		;6d58
	ld (0e151h),hl		;6d5b
	ld a,(0e200h)		;6d5e   ; Con 0xE200 en negativo la nave esta muerta
	and a			;6d61
	ret m			;6d62
	jp pasa_a_la_fase_siguiente		;6d63
final_de_la_fase_2:		; Con la pantalla parada SALTA A LA FASE 9; si no, sigue el guion de cuatro pasos y acaba en la 3
	ld a,(0e1c0h)		;6d66   ; 0xE1C0: la pantalla esta parada
	and a			;6d69
	jr z,L_6D76		;6d6a
	ld a,(0e107h)		;6d6c
	and a			;6d6f
	ret z			;6d70
	ld a,009h		;6d71   ; La fase 9
	jp salta_a_la_fase		;6d73
L_6D76:
	ld a,(0e065h)		;6d76   ; 0xE065: el paso del final de fase
	dec a			;6d79
	jr z,espera_a_que_muera_y_borra		;6d7a
	dec a			;6d7c
	jr z,enciende_al_jefe_2		;6d7d
	dec a			;6d7f
	jr z,acaba_la_fase		;6d80
	ld a,(0e107h)		;6d82   ; Solo en los pasos con columna
	and a			;6d85
	ret z			;6d86
	call 0ab86h		;6d87
	jr sube_el_paso_del_final		;6d8a
espera_a_que_muera_y_borra:		; Igual, y ademas borra 0xE972
	ld hl,0e150h		;6d8c   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6d8f
	and a			;6d90
	ret z			;6d91
	xor a			;6d92
	ld (hl),a			;6d93
	ld (0e972h),a		;6d94
	ld hl,001dfh		;6d97   ; El desplazamiento llega hasta 0x1DF
	ld (0e105h),hl		;6d9a
	jp sube_el_paso_del_final		;6d9d
enciende_al_jefe_2:		; Lo mismo que 0x6D3E
	ld a,(0e107h)		;6da0
	and a			;6da3
	ret z			;6da4
	jr L_6D43		;6da5
final_de_la_fase_3:		; Como el anterior, pero la fase a la que salta es la 10
	ld a,(0e1c0h)		;6da7   ; 0xE1C0: la pantalla esta parada
	and a			;6daa   ; Solo en los pasos con columna
	jr z,L_6DB7		;6dab
	ld a,(0e107h)		;6dad
	and a			;6db0
	ret z			;6db1
	ld a,00ah		;6db2   ; La fase 10
	jp salta_a_la_fase		;6db4
L_6DB7:
	ld a,(0e065h)		;6db7   ; 0xE065: el paso del final de fase
	dec a			;6dba
	jr z,espera_y_suelta_el_scroll		;6dbb
	dec a			;6dbd
	jr z,enciende_al_jefe_3		;6dbe
	dec a			;6dc0
	jp z,acaba_la_fase		;6dc1
	ld a,(0e151h)		;6dc4   ; 0xE151: si ya hay jefe en pantalla
	or a			;6dc7
	jr nz,espera_y_apaga		;6dc8
	ld hl,(0e063h)		;6dca   ; La distancia recorrida...
	ld de,00060h		;6dcd   ; ...contra 0x60
	rst 20h			;6dd0
	jr z,el_otro_jefe		;6dd1
	ld a,(0e107h)		;6dd3
	and a			;6dd6
	ret z			;6dd7
	ld hl,00101h		;6dd8   ; 0x0101 en 0xE151: el jefe, en su primer paso
	ld (0e151h),hl		;6ddb
	jp sube_el_paso_del_final		;6dde
el_otro_jefe:		; Con 0xE06A puesto sale el jefe 6 en vez del 1
	ld a,(0e06ah)		;6de1   ; 0xE06A: la vuelta que va
	or a			;6de4
	ret z			;6de5
	ld hl,00601h		;6de6
	ld (0e151h),hl		;6de9
	ret			;6dec
espera_y_apaga:		; Al morir el jefe, apaga las dos banderas
	ld hl,0e150h		;6ded   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6df0
	and a			;6df1
	ret z			;6df2
	xor a			;6df3
	ld (hl),a			;6df4
	ld (0e151h),a		;6df5
	ret			;6df8
espera_y_suelta_el_scroll:		; Al morir el jefe, apaga las banderas y deja el desplazamiento correr hasta 0x1AF
	ld hl,0e150h		;6df9   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6dfc   ; 0xE150 a cero
	and a			;6dfd
	ret z			;6dfe
	xor a			;6dff
	ld (hl),a			;6e00
	ld (0e151h),a		;6e01
	ld hl,001afh		;6e04   ; El desplazamiento llega hasta 0x1AF
	ld (0e105h),hl		;6e07
	jp sube_el_paso_del_final		;6e0a
enciende_al_jefe_3:
	ld a,(0e107h)		;6e0d
	and a			;6e10
	ret z			;6e11
	jp L_6D43		;6e12
final_de_la_fase_4:		; Con la pantalla parada SALTA A LA FASE 11; si no, cinco pasos con dos jefes
	ld a,(0e1c0h)		;6e15   ; 0xE1C0: la pantalla esta parada
	and a			;6e18
	jr z,L_6E25		;6e19
	ld a,(0e107h)		;6e1b   ; Solo en los pasos con columna
	and a			;6e1e
	ret z			;6e1f
	ld a,00bh		;6e20   ; La fase 11
	jp salta_a_la_fase		;6e22
L_6E25:
	ld a,(0e065h)		;6e25
	dec a			;6e28   ; 0xE065: el paso del final de fase
	jr z,el_jefe_de_la_mitad		;6e29
	dec a			;6e2b
	jr z,espera_y_suelta_hasta_1C0		;6e2c
	dec a			;6e2e
	jr z,enciende_al_jefe_4		;6e2f
	dec a			;6e31
	jp z,acaba_la_fase		;6e32
	ld a,(0e140h)		;6e35   ; 0xE140: el aviso de que hay algo esperando
	and a			;6e38
	jr nz,espera_al_primero		;6e39
	ld hl,(0e063h)		;6e3b   ; La distancia...
	ld de,00128h		;6e3e   ; ...contra 0x128
	rst 20h			;6e41
	ret nz			;6e42
	ld a,002h		;6e43   ; 0xE140 a dos, el limite en 0xB4 y 0xD0 en 0xE141
	ld (0e140h),a		;6e45
	ld hl,000b4h		;6e48
	ld (0e148h),hl		;6e4b
	ld a,0d0h		;6e4e
	ld (0e141h),a		;6e50
	ret			;6e53
espera_al_primero:		; Al morir el primero, apaga el aviso y pasa al paso siguiente
	ld hl,0e150h		;6e54   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6e57   ; 0xE150: hasta que no muera, no
	and a			;6e58   ; 0xE150: hasta que no muera, no
	ret z			;6e59
	xor a			;6e5a
	ld (hl),a			;6e5b
	ld (0e140h),a		;6e5c
	jp sube_el_paso_del_final		;6e5f
el_jefe_de_la_mitad:		; A la distancia 0x171 llama al banco 2; si no, saca el jefe 5
	ld a,(0e1b0h)		;6e62
	and a			;6e65
	jr nz,espera_al_de_la_mitad		;6e66
	ld hl,(0e063h)		;6e68
	ld de,00171h		;6e6b   ; La distancia 0x171
	rst 20h			;6e6e
	jp z,08e77h		;6e6f
	ld a,(0e107h)		;6e72
	and a			;6e75
	ret z			;6e76
	ld hl,00501h		;6e77   ; 0x0501 en 0xE151: el jefe 5
	ld (0e151h),hl		;6e7a
	jp sube_el_paso_del_final		;6e7d
espera_al_de_la_mitad:		; Al morir, apaga 0xE1B0
	ld hl,0e150h		;6e80   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6e83
	and a			;6e84
	ret z			;6e85
	xor a			;6e86
	ld (hl),a			;6e87
	ld (0e1b0h),a		;6e88
	ret			;6e8b
espera_y_suelta_hasta_1C0:		; Al morir el jefe, el desplazamiento llega hasta 0x1C0
	ld hl,0e150h		;6e8c   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6e8f
	and a			;6e90
	ret z			;6e91
	xor a			;6e92
	ld (hl),a			;6e93
	ld (0e151h),a		;6e94
	ld hl,001c0h		;6e97   ; El desplazamiento llega hasta 0x1C0
	ld (0e105h),hl		;6e9a
	jp sube_el_paso_del_final		;6e9d
enciende_al_jefe_4:
	ld a,(0e107h)		;6ea0   ; Solo en los pasos con columna
	and a			;6ea3
	ret z			;6ea4
	jp L_6D43		;6ea5
final_de_la_fase_5:		; Cuatro pasos, con dos llamadas al banco 3 y el desplazamiento soltado hasta 0x1FF
	ld a,(0e065h)		;6ea8
	dec a			;6eab   ; 0xE065: el paso del final de fase
	jr z,espera_y_llama_al_banco3		;6eac
	dec a			;6eae
	jr z,espera_y_suelta_hasta_1FF		;6eaf
	dec a			;6eb1   ; Al paso 4, que acaba la fase
	jr z,enciende_al_jefe_5		;6eb2
	dec a			;6eb4
	jp z,acaba_la_fase		;6eb5
	ld a,(0e107h)		;6eb8   ; Solo en los pasos con columna
	and a			;6ebb
	ret z			;6ebc
	call 0b946h		;6ebd   ; Una rutina del banco 3 monta lo que toque
	jp sube_el_paso_del_final		;6ec0
espera_y_llama_al_banco3:		; Al morir, borra 0xE988 y llama otra vez al banco 3
	ld hl,0e150h		;6ec3   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6ec6
	and a			;6ec7
	ret z			;6ec8
	xor a			;6ec9
	ld (hl),a			;6eca
	ld (0e988h),a		;6ecb
	call 0bb95h		;6ece
	jp sube_el_paso_del_final		;6ed1
espera_y_suelta_hasta_1FF:		; Al morir, borra 0xE990 y el desplazamiento llega hasta 0x1FF
	ld hl,0e150h		;6ed4   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6ed7
	and a			;6ed8
	ret z			;6ed9
	xor a			;6eda
	ld (hl),a			;6edb   ; Al morir, el desplazamiento llega hasta 0x1FF
	ld (0e990h),a		;6edc
	ld hl,001ffh		;6edf
	ld (0e105h),hl		;6ee2
	jp sube_el_paso_del_final		;6ee5
enciende_al_jefe_5:
	ld a,(0e107h)		;6ee8   ; Solo en los pasos con columna
	and a			;6eeb
	ret z			;6eec
	jp L_6D43		;6eed
final_de_la_fase_6:		; Pasada la distancia 0xA0 saca el jefe 2, y al morir deja el limite donde este
	ld a,(0e065h)		;6ef0   ; 0xE065: el paso del final de fase
	dec a			;6ef3
	jr z,espera_y_para_donde_este		;6ef4
	dec a			;6ef6
	jp z,acaba_la_fase		;6ef7
	ld hl,(0e063h)		;6efa
	ld de,000a0h		;6efd   ; La distancia 0xA0
	rst 20h			;6f00
	ret c			;6f01
	ld hl,00201h		;6f02   ; 0x0201 en 0xE151: el jefe 2
	ld (0e151h),hl		;6f05
	jp sube_el_paso_del_final		;6f08
espera_y_para_donde_este:		; Al morir el jefe, el limite se queda en la distancia actual
	ld a,(0e150h)		;6f0b   ; 0xE150: hasta que no muera, no
	and a			;6f0e
	ret z			;6f0f
	ld hl,(0e063h)		;6f10
	ld (0e105h),hl		;6f13
	jp L_6D43		;6f16
final_de_la_fase_7:		; Con la pantalla parada SALTA A LA FASE 12; si no, saca el jefe 3
	ld a,(0e1c0h)		;6f19   ; 0xE1C0: la pantalla esta parada
	and a			;6f1c
	jr z,L_6F29		;6f1d
	ld a,(0e107h)		;6f1f   ; Solo en los pasos con columna
	and a			;6f22
	ret z			;6f23
	ld a,00ch		;6f24   ; La fase 12
	jp salta_a_la_fase		;6f26
L_6F29:
	ld a,(0e065h)		;6f29
	dec a			;6f2c   ; 0xE065: el paso del final de fase
	jp z,acaba_la_fase		;6f2d
	ld a,(0e107h)		;6f30
	and a			;6f33
	ret z			;6f34
	ld a,001h		;6f35   ; 0xE114 a uno
	ld (0e114h),a		;6f37
	ld hl,00301h		;6f3a   ; 0x0301 en 0xE151: el jefe 3
	ld (0e151h),hl		;6f3d
	jp sube_el_paso_del_final		;6f40
final_de_la_fase_8:		; A la distancia 0x16E saca el jefe 4 y, al matarlo, arranca la explosion del final
	ld a,(0e065h)		;6f43
	dec a			;6f46
	jr z,arranca_el_final_del_juego		;6f47
	dec a			;6f49
	jp z,acaba_el_final		;6f4a
	ld hl,(0e063h)		;6f4d
	ld de,0016eh		;6f50   ; La distancia 0x16E
	rst 20h			;6f53
	ret nz			;6f54
	ld hl,00401h		;6f55   ; 0x0401 en 0xE151: el jefe 4
	ld (0e151h),hl		;6f58   ; 0x0401 en 0xE151: el jefe 4
	jp sube_el_paso_del_final		;6f5b
arranca_el_final_del_juego:		; Muerto el ultimo jefe, y con la nave viva, enciende 0xE1D0: la secuencia final
	ld a,(0e150h)		;6f5e
	and a			;6f61
	ret z			;6f62
	ld hl,00000h		;6f63
	ld (0e151h),hl		;6f66
	xor a			;6f69
	ld (0e150h),a		;6f6a
	ld a,(0e200h)		;6f6d   ; Con 0xE200 en negativo, la nave ya estaba muerta
	and a			;6f70
	ret m			;6f71
	ld hl,00001h		;6f72   ; 0xE1D0 a uno: arranca la explosion del final
	ld (0e1d0h),hl		;6f75
	ld hl,00300h		;6f78   ; 0x0300 en 0xE1D3
	ld (0e1d3h),hl		;6f7b
	ld a,041h		;6f7e   ; El sonido 0x41
	call 049deh		;6f80
	jp sube_el_paso_del_final		;6f83
acaba_el_final:		; Apaga 0xE1D0 y pasa de fase
	ld hl,0e150h		;6f86   ; 0xE150: hasta que no muera, no
	ld a,(hl)			;6f89   ; 0xE150: hasta que no muera, no
	and a			;6f8a   ; 0xE150: hasta que no muera, no
	ret z			;6f8b
	ld (hl),000h		;6f8c
	ld hl,00000h		;6f8e
	ld (0e1d0h),hl		;6f91
	jp pasa_a_la_fase_siguiente		;6f94
final_de_la_fase_9:		; Acabado el interludio, se vuelve a la fase 3
	ld a,(0e107h)		;6f97
	and a			;6f9a
	ret z			;6f9b
	ld a,003h		;6f9c   ; La fase 3, no un objeto
	jr salta_a_la_fase		;6f9e
final_de_la_fase_10:		; Se vuelve a la fase 4
	ld a,(0e107h)		;6fa0   ; Solo en los pasos con columna
	and a			;6fa3
	ret z			;6fa4
	ld a,004h		;6fa5   ; La fase 4
	jr salta_a_la_fase		;6fa7
final_de_la_fase_11:		; Se vuelve a la fase 5
	ld a,(0e107h)		;6fa9   ; Solo en los pasos con columna
	and a			;6fac
	ret z			;6fad
	ld a,005h		;6fae   ; La fase 5
	jr salta_a_la_fase		;6fb0
final_de_la_fase_12:		; Se vuelve a la fase 8, la ultima
	ld a,(0e107h)		;6fb2   ; Solo en los pasos con columna
	and a			;6fb5
	ret z			;6fb6
	ld a,008h		;6fb7   ; La fase 8
salta_a_la_fase:		; Le mete a 0xE061 la fase que traiga A, borra los contadores y arranca por 0x4100; se come la direccion de retorno con un `pop hl`
	ld (0e061h),a		;6fb9
	xor a			;6fbc
	ld (0e107h),a		;6fbd   ; 0xE107, 0xE065 y 0xE1C0 a cero
	ld (0e065h),a		;6fc0
	ld (0e1c0h),a		;6fc3
	call 04100h		;6fc6
	ld a,01fh		;6fc9   ; 0x1F de distancia recorrida
	ld (0e063h),a		;6fcb
	pop hl			;6fce   ; Se tira el retorno: de aqui no se vuelve
	ret			;6fcf
pasa_a_la_fase_siguiente:		; Sube la fase; pasada la octava vuelve a la primera, baja cuatro escalones de dificultad y sube la vuelta
	call sube_la_dificultad		;6fd0
	xor a			;6fd3
	ld (0e065h),a		;6fd4
	ld hl,0e066h		;6fd7   ; 0xE066 cuenta las fases jugadas
	inc (hl)			;6fda
	ld hl,0e061h		;6fdb
	ld a,(hl)			;6fde
	inc a			;6fdf
	ld (hl),a			;6fe0
	cp 009h		;6fe1   ; Pasada la octava, se vuelve a la primera
	jp c,04100h		;6fe3
	ld (hl),001h		;6fe6
	ld hl,0e111h		;6fe8   ; Y la dificultad baja cuatro escalones
	ld a,(hl)			;6feb
	sub 004h		;6fec
	jr nc,L_6FF1		;6fee
	xor a			;6ff0
L_6FF1:
	ld (hl),a			;6ff1
	ld hl,00000h		;6ff2   ; 0xE06C y 0xE06D a cero
	ld (0e06ch),hl		;6ff5
	ld hl,0e06ah		;6ff8   ; 0xE06A: la vuelta que va
	inc (hl)			;6ffb
	jp nz,04100h		;6ffc
	dec (hl)			;6fff
	jp 04100h		;7000

; ----------------------------------------------------------------------
; LA MUSICA CAMBIA CON LA DISTANCIA RECORRIDA
; La musica de cada fase no se lanza una vez: hay una lista por fase -la
; tabla de 0x7056 dice cual- con parejas [distancia][que suena], y en cada
; cuadro se busca en ella el tramo en el que cae la distancia recorrida. Si
; lo que sale es distinto de lo que ya suena (0xE012), se apunta el cambio.
; ----------------------------------------------------------------------
mira_que_musica_toca:		; Busca en la lista de la fase el tramo de distancia en el que se esta y, si la musica es otra, la apunta
	ld a,(0e200h)		;7003   ; Con la nave muerta, no
	and a			;7006
	ret m			;7007
	ld a,(0e1c0h)		;7008   ; Ni con la pantalla parada
	and a			;700b
	ret nz			;700c
	ld a,(0e114h)		;700d   ; Ni con 0xE114 puesto
	and a			;7010
	ret nz			;7011
	ld hl,0e113h		;7012   ; 0xE113: ya hay un cambio de musica pendiente
	ld a,(hl)			;7015
	and a			;7016
	jr nz,arranca_la_musica_apuntada		;7017
	ld a,(0e061h)		;7019
	ld hl,07056h		;701c   ; La tabla de 0x7056: una lista por fase
	call 047aeh		;701f
	ld c,e			;7022
	ld b,d			;7023
	ld hl,(0e063h)		;7024   ; La distancia recorrida
L_7027:
	ld a,(bc)			;7027   ; Cada renglon: dos bytes de distancia y uno de musica
	ld e,a			;7028
	inc bc			;7029
	ld a,(bc)			;702a
	ld d,a			;702b
	inc bc			;702c
	rst 20h			;702d   ; DCOMPR: se busca el tramo
	jr c,L_7033		;702e
	inc bc			;7030
	jr L_7027		;7031
L_7033:
	ld a,(bc)			;7033
	ld hl,0e012h		;7034   ; Si es la que ya suena, no se toca nada
	cp (hl)			;7037
	ret z			;7038
	ld (0e113h),a		;7039   ; Y si no, se apunta en 0xE113
	ld a,(hl)			;703c
	and a			;703d
	ret z			;703e
	ld hl,06001h		;703f
	ld (0e044h),hl		;7042
	xor a			;7045
	ld (0e046h),a		;7046
	ret			;7049
arranca_la_musica_apuntada:		; Cuando el canal calla, lanza la musica que se aparco en 0xE113; el 0xFF solo la borra
	ld a,(0e012h)		;704a   ; Hasta que el canal no calle, no se cambia
	and a			;704d
	ret nz			;704e
	ld a,(hl)			;704f
	cp 0ffh		;7050   ; El 0xFF quiere decir silencio
	ld (hl),000h		;7052
	ret z			;7054
	jp 049deh		;7055

; ----------------------------------------------------------------------
; DATOS tabla_7056 (tramo): Palabras que 0x701C indexa con la base 0x7056:
;   0x7070, 0x7079, 0x7082, 0x708B, ... todas de este mismo banco.
;   0x7058..0x70ca  (114 bytes)  de 0x7056..0x70ca (116 bytes)
DATA_tabla_7056_7058:
	defw 07070h,07079h	; 7058
	defw 07082h,0708bh	; 705c
	defw 07094h,0709dh	; 7060
	defw 070a6h,070afh	; 7064
	defw 070b8h,070b8h	; 7068
	defw 070beh,070c4h	; 706c
	defw 00064h,080ach	; 7070
	defw 0af01h,0ffffh	; 7074
	defw 064b5h,0ac00h	; 7078
	defw 001a7h,0ff96h	; 707c
	defw 0b5ffh,00060h	; 7080
	defw 07cach,09801h	; 7084
	defw 0ffffh,064b5h	; 7088
	defw 0ac00h,0017fh	; 708c
	defw 0ff9ah,0b5ffh	; 7090
	defw 00064h,0b7ach	; 7094
	defw 0a201h,0ffffh	; 7098
	defw 080b5h,0ac00h	; 709c
	defw 00158h,0ff9ch	; 70a0
	defw 0b5ffh,00064h	; 70a4
	defw 059ach,09e01h	; 70a8
	defw 0ffffh,038b5h	; 70ac
	defw 0ac00h,0017ah	; 70b0
	defw 0ffa0h,0b5ffh	; 70b4
	defw 000f7h,0ffa4h	; 70b8
	defw 0ffffh,000b7h	; 70bc
	defw 0ffa4h,0ffffh	; 70c0
	defw 00177h,0ffa4h	; 70c4
	defw 0ffffh	; 70c8

; ======================================================================
; CODIGO 0x70ca..0x7189  (191 bytes)
; ======================================================================


sube_la_dificultad:		; Un escalon mas en 0xE111, hasta el 0x0F
	ld c,001h		;70ca
	ld hl,0e111h		;70cc
	ld a,(hl)			;70cf
	add a,c			;70d0
	cp 010h		;70d1   ; Dieciseis escalones como mucho
	ret nc			;70d3
	ld (hl),a			;70d4
	ret			;70d5
corre_la_tanda_de_enemigos:		; Con 0xE140 puesto, va soltando enemigos del tipo 0x0F cada dos cuadros hasta agotar la cuenta de 0xE148
	ld a,(0e1c0h)		;70d6   ; Con la pantalla parada, no
	and a			;70d9
	ret nz			;70da
	ld a,(0e140h)		;70db   ; 0xE140: la tanda en marcha
	dec a			;70de
	ret m			;70df
	jr z,L_70F1		;70e0
	ld hl,0e141h		;70e2
	ld a,(0e100h)		;70e5   ; En los pasos con columna, la tanda se corre ocho puntos a la izquierda
	and a			;70e8
	ld a,(hl)			;70e9
	jr z,L_70F1		;70ea
	sub 008h		;70ec
	ld (hl),a			;70ee
	jr c,acaba_la_tanda_de_enemigos		;70ef
L_70F1:
	ld a,(0e003h)		;70f1   ; Uno de cada dos cuadros
	and 001h		;70f4
	ret nz			;70f6
	ld hl,(0e148h)		;70f7   ; 0xE148: los que quedan por salir
	dec hl			;70fa
	ld (0e148h),hl		;70fb
	ld a,l			;70fe
	or h			;70ff
	jr z,acaba_la_tanda_de_enemigos		;7100
	call suena_al_llegar		;7102
	call pon_donde_sale		;7105
	call velocidad_de_la_tanda		;7108
	ld de,(0e146h)		;710b   ; Y sale un enemigo del tipo 0x0F
	ld a,00fh		;710f   ; El objeto 0x0F: el enemigo de la tanda
	ld c,000h		;7111   ; Sin ajuste
	jp saca_un_objeto		;7113
acaba_la_tanda_de_enemigos:		; 0xE150 a uno: la tanda esta agotada
	ld a,001h		;7116
	ld (0e150h),a		;7118
	ret			;711b
pon_donde_sale:		; Con 0xE140 en uno, alterna entre las dos posiciones de 0x7189 segun el bit 0 de la cuenta
	ld a,(0e140h)		;711c
	dec a			;711f
	jr nz,pon_donde_sale_por_altura		;7120
	ld hl,07189h		;7122
	ld a,(0e148h)		;7125   ; El bit 0 de la cuenta: una vez arriba y otra abajo
	and 001h		;7128   ; El bit 0: una vez arriba y otra abajo
	call 047aeh		;712a
	ld (0e146h),de		;712d
	ret			;7131
pon_donde_sale_por_altura:		; Con 0xE140 en dos, la posicion sale de la altura de 0xE141 y la columna 0x20
	ld a,(0e141h)		;7132
	ld h,a			;7135
	ld l,020h		;7136
	ld (0e146h),hl		;7138
	ret			;713b
velocidad_de_la_tanda:		; El registro R elige una de las ocho parejas de velocidad de 0x718D; en la fase 1 se le da la vuelta, y a media tanda se parte por dos
	ld a,r		;713c   ; El registro R: una de ocho parejas
	and 007h		;713e
	add a,a			;7140   ; Por dos: dos palabras por pareja
	ld hl,0718dh		;7141
	call 047aeh		;7144
	inc hl			;7147
	ld c,(hl)			;7148
	inc hl			;7149
	ld b,(hl)			;714a
	ld a,(0e061h)		;714b
	dec a			;714e   ; En la fase 1, al reves
	call z,cambia_el_signo		;714f
	ld hl,(0e148h)		;7152
	push de			;7155
	ld de,001a4h		;7156   ; Pasada la mitad de la tanda...
	ld a,(0e140h)		;7159
	dec a			;715c
	jr z,L_7162		;715d
	ld de,000a5h		;715f
L_7162:
	rst 20h			;7162
	pop de			;7163
	jr c,L_716E		;7164
	sra d		;7166   ; ...la velocidad se parte por dos
	rr e		;7168
	sra b		;716a
	rr c		;716c
L_716E:
	ld (0e142h),de		;716e   ; 0xE142: la velocidad vertical del fondo
	ld e,c			;7172
	ld d,b			;7173
	ld a,(0e140h)		;7174
	dec a			;7177
	ld c,002h		;7178
	jr z,L_717D		;717a
	dec c			;717c
L_717D:
	ld a,(0e148h)		;717d   ; Y un bit de la cuenta le da la vuelta a la horizontal: los enemigos salen alternos
	and c			;7180
	call nz,cambia_el_signo		;7181
	ld (0e144h),de		;7184   ; Y 0xE144: la horizontal
	ret			;7188

; ----------------------------------------------------------------------
; DATOS tabla_7189: Cuatro bytes que lee 0x7122.
;   0x7189..0x718d  (4 bytes)
DATA_tabla_7189:
	defb 07fh,0bch,07fh,03ch	; 7189

; ----------------------------------------------------------------------
; DATOS tabla_718D: Treinta y dos bytes que lee 0x7141.
;   0x718d..0x71ad  (32 bytes)
DATA_tabla_718D:
	defb 000h,00bh,080h,001h	; 718d
	defb 080h,00ah,000h,002h	; 7191
	defb 080h,00bh,000h,004h	; 7195
	defb 000h,00ah,090h,001h	; 7199
	defb 080h,00ah,0b0h,001h	; 719d
	defb 040h,00bh,000h,003h	; 71a1
	defb 070h,00ah,080h,002h	; 71a5
	defb 060h,00ah,040h,002h	; 71a9

; ======================================================================
; CODIGO 0x71ad..0x7310  (355 bytes)
; ======================================================================


mira_si_choca_con_el_mapa_2:		; Le pasa al banco 2 la posicion del objeto, con 0x10 de correccion si el bit 7 del byte 8 esta a cero
	call 0953ch		;71ad
L_71B0:
	ld l,(ix+004h)		;71b0   ; La posicion del objeto
	ld h,(ix+006h)		;71b3   ; La posicion del objeto
	bit 7,(ix+008h)		;71b6   ; El bit 7 del byte 8 dice si se corre 0x10
	jr nz,L_71C0		;71ba
	ld a,l			;71bc
	add a,010h		;71bd
	ld l,a			;71bf
L_71C0:
	call 09857h		;71c0   ; Y el banco 2 responde
	ret nc			;71c3
	jp revienta_el_enemigo		;71c4
suena_al_llegar:		; En la fase 1, a la cuenta 0x1C1 suena el 0x32; en las demas, a la 0xB3 suena el 0x13
	ld hl,(0e148h)		;71c7
	ld a,(0e061h)		;71ca
	dec a			;71cd
	jr nz,L_71DE		;71ce
	ld de,001c1h		;71d0   ; En la fase 1, a la cuenta 0x1C1
	rst 20h			;71d3
	ret nz			;71d4
	xor a			;71d5
	ld (0e044h),a		;71d6
	ld a,032h		;71d9   ; El sonido 0x32
	jp 049deh		;71db
L_71DE:
	ld de,000b3h		;71de   ; Y en las demas, a la 0xB3
	rst 20h			;71e1
	ret nz			;71e2
	ld a,013h		;71e3   ; El sonido 0x13
	jp 049deh		;71e5
corre_la_nave:		; La tira de rutinas que mueven a la nave, sus disparos y sus opciones
	ld a,(0e1c0h)		;71e8   ; Con la pantalla parada, la nave no se mueve
	and a			;71eb
	ret nz			;71ec
	call mira_los_choques		;71ed   ; Primero, los disparos de la nave contra todo lo que hay
	call mira_los_choques_de_eb00		;71f0
	call mira_los_choques_con_el_fondo		;71f3
	call mira_los_choques_de_la_fase_5		;71f6
	call mira_si_la_nave_choca_con_el_mapa		;71f9   ; Y los choques con el mapa y con los enemigos
	call mira_si_la_nave_choca_con_un_enemigo_2		;71fc
	call mira_si_la_nave_choca_con_un_enemigo		;71ff
	call mira_si_la_opcion_toca_algo		;7202
	jp mira_si_la_nave_choca_con_un_disparo		;7205
mira_los_choques_de_eb00:		; Los cinco objetos de 0xEB00, solo si 0xE1B0 esta puesto
	ld a,(0e1b0h)		;7208   ; Sin 0xE1B0 no hay nada que mirar
	or a			;720b
	ret z			;720c
	ld ix,0eb00h		;720d
	ld b,005h		;7211
	jp L_721C		;7213

; ----------------------------------------------------------------------
; LOS CHOQUES ENTRE LOS DISPAROS DE LA NAVE Y LOS ENEMIGOS
; Cada cuadro se cruzan las dos listas: por cada enemigo vivo cuyo bit 1
; del byte 27 este puesto, se recorren los NUEVE disparos de la nave
; (0xE260, fichas de 0x10 bytes) y se mira si alguno cae dentro de su caja.
; La caja no es cuadrada: 0x12 de ancho por 0x20 de alto, y el disparo de
; tipo 3 -el laser- se mide de otra manera, con la altura sacada de su
; propia ficha por ocho.
; ----------------------------------------------------------------------
mira_los_choques:		; Los doce enemigos de 0xE300 contra los nueve disparos de la nave
	ld b,00ch		;7216   ; Doce enemigos
	ld ix,0e300h		;7218
L_721C:
	push bc			;721c
	ld a,(ix+000h)		;721d
	and a			;7220
	jr z,L_7241		;7221
	bit 1,(ix+01bh)		;7223   ; El bit 1 del byte 27: este se puede tocar
	jr z,L_7241		;7227
	ld hl,0e260h		;7229   ; Los nueve disparos de la nave, de 0x10 en 0x10 bytes
	ld b,009h		;722c
L_722E:
	ld (0ec00h),hl		;722e   ; La ranura del disparo se aparca en 0xEC00
	ld a,(hl)			;7231
	and a			;7232
	call nz,mira_un_disparo		;7233
	jr c,L_7241		;7236
	ld hl,(0ec00h)		;7238
	ld a,010h		;723b   ; Dieciseis bytes: el disparo siguiente
	add a,l			;723d
	ld l,a			;723e
	djnz L_722E		;723f
L_7241:
	pop bc			;7241
	ld de,00020h		;7242   ; Treinta y dos bytes: el enemigo siguiente
	add ix,de		;7245
	djnz L_721C		;7247
	ret			;7249
mira_un_disparo:		; Mira si el disparo cae en la caja del enemigo: 0x12 de ancho por 0x20 de alto
	cp 003h		;724a   ; El tipo 3 -el laser- se mide aparte
	jr z,mira_el_laser		;724c
	inc l			;724e
	inc l			;724f
	inc l			;7250
	ld a,(ix+004h)		;7251
	sub (hl)			;7254
	add a,010h		;7255   ; 0x12 de ancho
	cp 012h		;7257
	ret nc			;7259
	inc l			;725a
	inc l			;725b
	ld a,(hl)			;725c
	cp 0f0h		;725d   ; Pasada la Y 0xF0, el disparo se ha ido
	ret nc			;725f
	sub (ix+006h)		;7260
	add a,010h		;7263
	cp 020h		;7265   ; Y 0x20 de alto
	ret nc			;7267
	ld hl,(0ec00h)		;7268   ; El disparo se gasta
	ld (hl),000h		;726b
	ld a,(ix+000h)		;726d
	cp 00bh		;7270   ; Los tipos 0x0B, 0x1B y 0x1E aguantan
	jp z,solo_suena		;7272
	cp 01bh		;7275
	jp z,solo_suena		;7277
	cp 01eh		;727a
	jp z,solo_suena		;727c
	cp 019h		;727f
	jp z,empieza_a_explotar		;7281
	dec (ix+00fh)		;7284   ; Y a los demas les baja un punto de vida el byte 15
	ret nz			;7287
	jp cobra_el_enemigo		;7288
mira_el_laser:		; El laser mide distinto: la altura sale de su propia ficha, multiplicada por ocho
	inc l			;728b
	inc l			;728c
	inc l			;728d
	ld a,(ix+004h)		;728e
	sub (hl)			;7291
	add a,010h		;7292   ; 0x12 de ancho, igual
	cp 012h		;7294   ; 0x12 de ancho
	ret nc			;7296
	inc l			;7297
	inc l			;7298
	ld a,(ix+006h)		;7299
	sub (hl)			;729c
	cp 0f0h		;729d
	jr nc,L_72AE		;729f
	ex af,af'			;72a1
	ld a,007h		;72a2   ; Siete bytes mas alla: el largo del laser
	add a,l			;72a4
	ld l,a			;72a5
	ld a,(hl)			;72a6
	add a,a			;72a7   ; Por ocho
	add a,a			;72a8
	add a,a			;72a9
	ld c,a			;72aa
	ex af,af'			;72ab
	cp c			;72ac
	ret nc			;72ad
L_72AE:
	ld a,(ix+000h)		;72ae   ; Los tipos 0x0B, 0x1B y 0x1E aguantan
	cp 00bh		;72b1   ; Los tipos 0x0B, 0x1B y 0x1E aguantan
	jr z,solo_suena		;72b3   ; Los tipos que aguantan
	cp 01bh		;72b5
	jr z,solo_suena		;72b7
	cp 01eh		;72b9
	jr z,solo_suena		;72bb
	cp 019h		;72bd
	jp z,empieza_a_explotar		;72bf
cobra_el_enemigo:		; Un punto, o cinco si es del tipo 0x1F
	ld de,00001h		;72c2
	ld a,(ix+000h)		;72c5
	cp 01fh		;72c8   ; El tipo 0x1F paga cinco
	jr nz,L_72CF		;72ca
	ld de,00005h		;72cc
L_72CF:
	call 055b4h		;72cf
revienta_el_enemigo:		; Suena lo que diga la tabla de 0x730F para ese tipo, y el objeto pasa a ser explosion del tipo 0x15
	ld d,000h		;72d2
	ld e,(ix+000h)		;72d4
	ld hl,l730fh		;72d7   ; La tabla de 0x730F: que sonido lleva cada tipo
	add hl,de			;72da
	ld a,(hl)			;72db
	call 049deh		;72dc
	ld bc,01578h		;72df   ; Tipo 0x15, dibujo 0x78
	ld a,(ix+000h)		;72e2
	cp 00dh		;72e5   ; El tipo 0x0D lleva otro dibujo
	jr nz,L_72EC		;72e7
	ld bc,014f0h		;72e9
L_72EC:
	ld (ix+000h),b		;72ec
	ld (ix+00ch),c		;72ef
	ld a,(ix+00bh)		;72f2   ; Si se dibujaba con caracteres, quince cuadros de explosion
	ld (ix+00bh),000h		;72f5
	and a			;72f9
	jr z,L_7300		;72fa
	ld (ix+00dh),00fh		;72fc
L_7300:
	xor a			;7300
	ld (ix+002h),a		;7301
	ld (ix+01bh),a		;7304
	scf			;7307   ; Sale con acarreo: se ha reventado
	ret			;7308
solo_suena:		; Los que aguantan el impacto solo hacen sonar el 6
	ld a,006h		;7309
	call 049deh		;730b
	scf			;730e
L_730F:
	ret			;730f

; ----------------------------------------------------------------------
; DATOS tabla_730F (tramo): Treinta y dos bytes que lee 0x72D7 con la base
;   0x730F.
;   0x7310..0x732f  (31 bytes)  de 0x730f..0x732f (32 bytes)
DATA_tabla_730F_7310:
	defb 00ah,008h,008h,008h,00ah,00ah,008h,008h,008h,008h,008h,008h,009h,00dh,00dh,00dh	; 7310  ................
	defb 00dh,00dh,00dh,00dh,00dh,00dh,00dh,00dh,00dh,00dh,00dh,00bh,00dh,00dh,00dh	; 7320  ...............

; ======================================================================
; CODIGO 0x732f..0x7563  (564 bytes)
; ======================================================================


mira_si_la_nave_choca_con_el_mapa:		; Le pregunta al banco 2; si choca, la nave muere
	ld a,(0e200h)		;732f   ; Con 0xE200 en 0xFF no hay nave
	inc a			;7332
	ret z			;7333
	call 098dah		;7334
	ret nc			;7337
	jp la_nave_ha_muerto		;7338
mira_si_la_nave_choca_con_un_disparo:		; Los diez de 0xE500 contra la nave, con caja de dos por dos
	ld a,(0e200h)		;733b
	inc a			;733e
	ret z			;733f
	ld ix,0e500h		;7340   ; Los diez disparos enemigos
	ld l,00ah		;7344
	ld bc,00202h		;7346   ; Dos de ancho por dos de alto
	call hay_alguno_encima		;7349
	ret nc			;734c
	xor a			;734d
	ld (ix+000h),a		;734e
	ld (ix+01bh),a		;7351
	jp la_nave_ha_muerto		;7354
hay_alguno_encima:		; Recorre las ranuras buscando alguno cuya caja pille el punto (0xE204+4, 0xE206+1)
	ld a,(0e204h)		;7357   ; La fila de la nave mas cuatro
	add a,004h		;735a
	ld e,a			;735c
	ld a,(0e206h)		;735d   ; Y su columna mas uno
	inc a			;7360
	ld d,a			;7361
	exx			;7362
	ld de,00020h		;7363   ; Treinta y dos bytes por ranura
	ld bc,00c08h		;7366   ; La caja: 0x0C de alto por 8 de ancho
	exx			;7369
L_736A:
	ld a,(ix+000h)		;736a   ; La ranura a cero esta libre
	or a			;736d
	jr z,L_738C		;736e
	bit 0,(ix+01bh)		;7370   ; El bit 0 del byte 27: este puede tocar a la nave
	jr z,L_738C		;7374   ; Treinta y dos bytes por ranura
	ld a,(ix+004h)		;7376
	sub e			;7379
	exx			;737a
	cp c			;737b
	exx			;737c
	jr c,L_7382		;737d
	add a,c			;737f
	jr nc,L_738C		;7380
L_7382:
	ld a,(ix+006h)		;7382   ; Y la Y
	sub d			;7385
	exx			;7386
	cp b			;7387
	exx			;7388
	ret c			;7389
	add a,b			;738a
	ret c			;738b
L_738C:
	exx			;738c   ; Treinta y dos bytes: la ranura siguiente
	add ix,de		;738d
	exx			;738f
	dec l			;7390
	jr nz,L_736A		;7391
	xor a			;7393
	ret			;7394
mira_si_la_nave_choca_con_un_enemigo:		; Con el escudo por debajo de 2, los diez de 0xE500 pueden matarla
	ld a,(0e200h)		;7395   ; 0xE200 por debajo de dos: sin escudo
	cp 002h		;7398
	ret m			;739a
	ld ix,0e500h		;739b
	ld b,00ah		;739f   ; Diez disparos
	ld a,(0e204h)		;73a1   ; La fila de la nave y su columna mas doce
	ld l,a			;73a4
	ld a,(0e206h)		;73a5
	add a,00ch		;73a8
	ld h,a			;73aa
	ld de,00020h		;73ab   ; Treinta y dos bytes por ranura
L_73AE:
	ld a,(ix+000h)		;73ae
	and a			;73b1
	jp z,L_73D2		;73b2
	ld c,00bh		;73b5   ; La caja es de 0x0B de alto, o de 0x19 si el disparo se dibuja con caracteres
	ld a,(ix+00bh)		;73b7
	and a			;73ba
	jr z,L_73BF		;73bb
	ld c,019h		;73bd
L_73BF:
	ld a,l			;73bf
	sub (ix+004h)		;73c0
	add a,010h		;73c3   ; 0x13 de ancho
	cp 013h		;73c5
	jr nc,L_73D2		;73c7
	ld a,h			;73c9   ; 0x13 de ancho
	sub (ix+006h)		;73ca
	add a,00ch		;73cd   ; Pasada la caja, el disparo no toca
	cp c			;73cf
	jr c,la_nave_toca_algo		;73d0
L_73D2:
	add ix,de		;73d2
	djnz L_73AE		;73d4
	ret			;73d6
la_nave_toca_algo:		; Si lo tocado se dibuja con caracteres, la nave revienta; si no, solo pierde escudo
	ld a,(ix+00bh)		;73d7   ; El byte 11: si se dibuja con caracteres
	and a			;73da
	jr nz,muere_la_nave		;73db
	call baja_el_escudo		;73dd
apaga_la_ranura:		; Deja la ranura libre
	xor a			;73e0
	ld (ix+000h),a		;73e1   ; La ranura queda libre
	ld (ix+01bh),a		;73e4
	ret			;73e7
muere_la_nave:		; 0xE200 a uno y 0xE201 a cero: la nave se acabo
	ld hl,00001h		;73e8
	ld (0e200h),hl		;73eb   ; Y la nave se acabo
	call apaga_la_ranura		;73ee
	jp 0a153h		;73f1
quita_escudo_y_cobra:		; Baja el escudo y, segun el tipo, revienta al enemigo o cobra sus puntos
	call baja_el_escudo		;73f4
	ld a,(ix+000h)		;73f7
	cp 01eh		;73fa   ; El tipo 0x1E: el grande
	call z,cobra_el_objeto_grande		;73fc
	cp 019h		;73ff
	jp z,empieza_a_explotar		;7401
	sub 012h		;7404   ; Los tipos del 0x12 al 0x1A son explosiones: no cobran
	cp 009h		;7406
	ret c			;7408
	jp cobra_el_enemigo		;7409
baja_el_escudo:		; 0xE201 baja; con menos de dos queda el escudo flojo, y al llegar a cero se apaga
	ld b,001h		;740c
	ld hl,0e201h		;740e
	dec (hl)			;7411   ; Un punto menos de escudo
	jr z,L_741B		;7412
	ld a,(hl)			;7414
	cp 002h		;7415   ; Por debajo de dos, el escudo va justo
	jr c,L_741A		;7417
	inc b			;7419
L_741A:
	inc b			;741a
L_741B:
	dec l			;741b
	ld (hl),b			;741c
	jp 0a153h		;741d
mira_si_la_nave_choca_con_un_enemigo_2:		; Los doce de 0xE300, con caja de 0x21 por 0x15
	ld a,(0e200h)		;7420   ; 0xE200 por debajo de dos: sin escudo
	cp 002h		;7423
	ret m			;7425
	ld ix,0e300h		;7426
	ld b,00ch		;742a   ; Doce enemigos
	ld a,(0e204h)		;742c   ; La fila de la nave y su columna mas doce
	ld l,a			;742f
	ld a,(0e206h)		;7430
	add a,00ch		;7433
	ld h,a			;7435
	ld de,00020h		;7436
L_7439:
	ld a,(ix+000h)		;7439
	and a			;743c
	jr z,L_7459		;743d
	bit 1,(ix+01bh)		;743f   ; El bit 1 del byte 27: este se puede tocar
	jr z,L_7459		;7443
	ld a,l			;7445
	sub (ix+004h)		;7446
	add a,010h		;7449
	cp 021h		;744b   ; 0x21 de ancho...
	jr nc,L_7459		;744d
	ld a,h			;744f
	sub (ix+006h)		;7450
	add a,00ch		;7453
	cp 015h		;7455   ; ...y 0x15 de alto
	jr c,quita_escudo_y_cobra		;7457   ; 0x15 de alto
L_7459:
	add ix,de		;7459
	djnz L_7439		;745b
	ret			;745d
mira_si_la_opcion_toca_algo:		; La misma cuenta pero para las opciones, con caja de 0x0C por 0x0C
	ld a,(0e200h)		;745e
	inc a			;7461
	ret z			;7462
	ld ix,0e300h		;7463
	ld l,00ch		;7467
	ld bc,00c0ch		;7469   ; Doce de ancho por doce de alto
	call hay_alguno_sobre_la_nave		;746c
	ret nc			;746f
	ld a,(ix+000h)		;7470
	sub 012h		;7473   ; Los tipos del 0x12 al 0x1A son explosiones
	jp c,cobra_y_muere		;7475
	cp 009h		;7478
	jp c,reparte_por_el_tipo_tocado		;747a
	cp 00ch		;747d
	call z,cobra_el_objeto_grande		;747f
cobra_y_muere:		; Cobra el enemigo y la nave se va
	call cobra_el_enemigo		;7482
	jp la_nave_ha_muerto		;7485
cobra_el_objeto_grande:		; El objeto de tres ranuras: se retrocede a la primera, se avisa al banco 3 y se cobran 0x10 puntos
	push ix		;7488
	ld a,(ix+013h)		;748a   ; El byte 19 dice cual de las tres ranuras es
	or a			;748d
	jr z,L_749A		;748e
	ld de,0ffe0h		;7490   ; 0x20 o 0x40 bytes hacia atras: la primera
	dec a			;7493
	jr z,L_7498		;7494
	ld e,0c0h		;7496
L_7498:
	add ix,de		;7498
L_749A:
	call 0bd33h		;749a
	ld de,00010h		;749d   ; Diez puntos en BCD
	call 055b4h		;74a0
	pop ix		;74a3
	ret			;74a5
reparte_por_el_tipo_tocado:		; Segun el tipo, la opcion se lleva una mejora, una nave o un premio
	or a			;74a6   ; El tipo 0 es la mejora del medidor
	jp z,recoge_la_mejora_del_medidor		;74a7
	dec a			;74aa   ; El 1, la bomba
	jp z,recoge_la_bomba		;74ab   ; El tipo 4 es la nave de regalo
	sub 003h		;74ae
	jr z,recoge_una_nave		;74b0
	dec a			;74b2   ; Los tipos 5 y 6, la capsula
	jr z,recoge_una_capsula		;74b3
	dec a			;74b5
	jr z,recoge_una_capsula		;74b6
	dec a			;74b8   ; Y el 7, la explosion
	jr z,empieza_a_explotar		;74b9
	ret			;74bb
recoge_una_nave:		; Convierte el objeto en el 0x1A, le pone el dibujo 0xE0, suena el 0x11 y regala una nave
	call convierte_en_premio		;74bc
	ld (ix+00dh),002h		;74bf
	ld (ix+00ch),0e0h		;74c3
	ld a,011h		;74c7   ; El sonido 0x11
	call 049deh		;74c9
	jp 0561ch		;74cc   ; Y una nave mas
recoge_una_capsula:		; Lo mismo, con el dibujo sacado de 0xE128 y el sonido 0x10
	call convierte_en_premio		;74cf
	ld (ix+00dh),008h		;74d2
	call cobra_la_capsula		;74d6
	ld a,(0e128h)		;74d9   ; 0xE128: cuantas capsulas seguidas van
	add a,a			;74dc
	add a,a			;74dd
	add a,0e0h		;74de
	ld (ix+00ch),a		;74e0
	ld a,010h		;74e3   ; El sonido 0x10
	jp 049deh		;74e5
empieza_a_explotar:		; El objeto pasa a ser explosion: tipo (byte 14) mas 0x13, deja de poder tocarse y se borra su dibujo de la pantalla
	ld a,(ix+00eh)		;74e8   ; El byte 14 dice de que tipo era
	ld b,a			;74eb
	add a,013h		;74ec   ; Mas 0x13: los tipos de explosion
	ld (ix+000h),a		;74ee   ; El tipo de explosion que le toca
	ld a,b			;74f1
	sub 003h		;74f2
	ld b,037h		;74f4   ; El dibujo 0x37, o el 0x38 con su color
	jr z,L_7503		;74f6
	inc b			;74f8
	ld c,001h		;74f9
	dec a			;74fb
	jr z,L_7500		;74fc
	ld c,008h		;74fe
L_7500:
	ld (ix+017h),c		;7500
L_7503:
	ld (ix+00ch),b		;7503
	res 1,(ix+01bh)		;7506   ; Se apaga el bit 1: ya no choca con nada
	xor a			;750a
	ld (ix+013h),a		;750b   ; Los cuatro caracteres del objeto, a cero
	ld (ix+014h),a		;750e
	ld (ix+015h),a		;7511
	ld (ix+016h),a		;7514
	ld l,(ix+004h)		;7517   ; La casilla donde estaba
	ld h,(ix+006h)		;751a   ; El byte 15 se queda con el tipo
	call 0571bh		;751d
	xor a			;7520
	ld (hl),a			;7521   ; Los dos caracteres de arriba...
	inc hl			;7522
	ld (hl),a			;7523
	ld bc,0001fh		;7524   ; ...y los dos de abajo
	add hl,bc			;7527
	ld (hl),a			;7528
	inc hl			;7529
	ld (hl),a			;752a
	scf			;752b
	ret			;752c
convierte_en_premio:		; El objeto se guarda su tipo en el byte 24 y pasa a ser el 0x1A, el que sube flotando
	ld a,(ix+000h)		;752d   ; El byte 24 se queda con el tipo de antes
	ld (ix+018h),a		;7530   ; Los cuatro caracteres del objeto, a cero
	ld (ix+000h),01ah		;7533
	ld (ix+002h),00ah		;7537
	ld a,(ix+004h)		;753b
	ld (ix+019h),a		;753e   ; El byte 25 se queda con la X
	ld (ix+00bh),000h		;7541   ; Y deja de dibujarse y de chocar
	ld (ix+01bh),000h		;7545   ; Y la marca de vivo, a cero
	ret			;7549
cobra_la_capsula:		; Sube la cuenta de capsulas y paga lo que diga la tabla de 0x7561
	call sube_la_cuenta_de_capsulas		;754a
	ld hl,L_7561		;754d
	call 047aeh		;7550
	jp 055b4h		;7553
sube_la_cuenta_de_capsulas:		; 0xE128 sube hasta siete y ahi se queda
	ld hl,0e128h		;7556
	ld a,(hl)			;7559
	inc a			;755a
	cp 008h		;755b   ; Siete es el tope
	jr c,L_7561		;755d
	ld a,007h		;755f
L_7561:
	ld (hl),a			;7561
	ret			;7562

; ----------------------------------------------------------------------
; DATOS puntos_de_la_capsula (tramo): Ocho palabras en BCD, cada una el doble
;   o el quintuplo de la anterior: lo que paga la capsula numero N, con N
;   contando en 0xE128 y topando en siete. Las lee 0x754D.
;   0x7563..0x7571  (14 bytes)  de 0x7561..0x7571 (16 bytes)
DATA_7563:
	defw 00001h	; 7563
	defw 00002h	; 7565
	defw 00005h	; 7567
	defw 00010h	; 7569
	defw 00020h	; 756b
	defw 00050h	; 756d
	defw 00100h	; 756f

; ======================================================================
; CODIGO 0x7571..0x7674  (259 bytes)
; ======================================================================


recoge_la_mejora_del_medidor:		; Avanza la casilla del medidor de mejoras -de una a seis, en redondo-, cobra cinco puntos y suena el 0x11
	ld hl,0e130h		;7571
	ld a,(hl)			;7574
	inc a			;7575
	cp 007h		;7576   ; Seis casillas, y de la sexta vuelve a la primera
	jr c,L_757C		;7578
	ld a,001h		;757a
L_757C:
	ld (hl),a			;757c
	call 05fa5h		;757d
	ld de,00005h		;7580   ; Cinco puntos
	call 055b4h		;7583
	ld a,011h		;7586   ; El sonido 0x11
	call 049deh		;7588
	jp 0a153h		;758b
recoge_la_bomba:		; Suena el 0x12 y revienta de golpe todo lo que hay en las dos tablas
	call 05fa5h		;758e
	ld a,012h		;7591   ; El sonido 0x12
	call 049deh		;7593
revienta_todo:		; Los doce de 0xE460 y los cinco de 0xEB80, contados hacia atras
	ld ix,0e460h		;7596
	ld b,00ch		;759a   ; Doce ranuras
	call L_75A5		;759c
	ld ix,0eb80h		;759f
	ld b,005h		;75a3   ; Y cinco mas
L_75A5:
	push bc			;75a5
	ld a,(ix+000h)		;75a6
	dec a			;75a9
	cp 00fh		;75aa   ; Los tipos del 1 al 0x0F: los que cobran
	call c,cobra_el_enemigo		;75ac
	pop bc			;75af
	ld de,0ffe0h		;75b0   ; Treinta y dos bytes hacia atras
	add ix,de		;75b3
	djnz L_75A5		;75b5
	ret			;75b7
hay_alguno_sobre_la_nave:		; Como 0x7357, pero con IX ya puesto: recorre L ranuras buscando la que pille el punto de la nave
	ld a,(0e204h)		;75b8   ; La fila de la nave mas cuatro y su columna mas uno
	add a,004h		;75bb
	ld e,a			;75bd
	ld a,(0e206h)		;75be
	inc a			;75c1
	ld d,a			;75c2
	exx			;75c3
	ld de,00020h		;75c4   ; Treinta y dos bytes por ranura
	ld bc,00c08h		;75c7   ; La caja: 0x0C de alto por 8 de ancho
	exx			;75ca
L_75CB:
	bit 0,(ix+01bh)		;75cb   ; El bit 0 del byte 27: este puede tocar a la nave
	jr z,L_75E7		;75cf   ; El bit 0 del byte 27
	ld a,(ix+004h)		;75d1
	sub e			;75d4
	exx			;75d5
	cp c			;75d6
	exx			;75d7
	jr c,L_75DD		;75d8
	add a,c			;75da
	jr nc,L_75E7		;75db
L_75DD:
	ld a,(ix+006h)		;75dd   ; Y la Y
	sub d			;75e0
	exx			;75e1
	cp b			;75e2
	exx			;75e3
	ret c			;75e4
	add a,b			;75e5
	ret c			;75e6
L_75E7:
	exx			;75e7   ; Treinta y dos bytes: la ranura siguiente
	add ix,de		;75e8   ; Treinta y dos bytes: la ranura siguiente
	exx			;75ea
	dec l			;75eb
	jr nz,L_75CB		;75ec
	xor a			;75ee
	ret			;75ef
la_nave_ha_muerto:		; Borra el mando, suena el 0x47 y se lo lleva el banco 2
	nop			;75f0
	xor a			;75f1
	ld (0e044h),a		;75f2
	ld a,047h		;75f5   ; El sonido 0x47
	call 049deh		;75f7
	jp 09b7bh		;75fa
cae_dentro_de_la_caja:		; Mira si el punto de HL cae dentro de la caja de BC alrededor de DE
	ld a,l			;75fd   ; La X contra la caja
	sub e			;75fe
	exx			;75ff
	cp c			;7600
	exx			;7601
	jr c,L_7606		;7602
	add a,c			;7604
	ret nc			;7605
L_7606:
	ld a,h			;7606   ; Y la Y
	sub d			;7607
	exx			;7608
	cp b			;7609
	exx			;760a
	ret c			;760b
	add a,b			;760c
	ret			;760d
mira_los_choques_con_el_jefe:		; Los nueve disparos de la nave contra las piezas del jefe, mientras 0xE155 este a cero
	ld a,(0e151h)		;760e   ; Sin jefe no hay nada que mirar
	and a			;7611
	ret z			;7612
	ld a,(0e155h)		;7613
	and a			;7616
	ret nz			;7617
	ld hl,0e260h		;7618   ; Los nueve disparos, de 0x10 en 0x10
	ld b,009h		;761b
L_761D:
	ld (0ec00h),hl		;761d   ; Cada uno se aparca en 0xEC00
	push bc			;7620   ; Cada disparo se aparca en 0xEC00
	call mira_un_disparo_contra_el_jefe		;7621
	pop bc			;7624
	ld hl,(0ec00h)		;7625
	ld de,00010h		;7628   ; Dieciseis bytes: el siguiente
	add hl,de			;762b
	djnz L_761D		;762c
	ret			;762e
mira_un_disparo_contra_el_jefe:		; Recorre las piezas del jefe de 0xE780; cuantas hay lo dice la tabla de 0x7674, indexada por el paso 0xE152
	ld a,(hl)			;762f
	and a			;7630
	ret z			;7631
	exx			;7632
	ld de,00010h		;7633   ; Dieciseis bytes por pieza
	ld bc,01002h		;7636   ; La caja: 0x10 de alto por 2 de ancho
	exx			;7639   ; Dieciseis bytes por pieza
	inc l			;763a
	inc l			;763b
	inc l			;763c
	ld e,(hl)			;763d
	inc l			;763e
	inc l			;763f
	ld d,(hl)			;7640
	ld ix,0e780h		;7641
	cp 003h		;7645   ; El disparo 3 -el laser- se mide aparte
	call z,alto_del_laser		;7647
	ld a,(0e152h)		;764a
	ld hl,07674h		;764d   ; La tabla de 0x7674: cuantas piezas tiene el jefe en cada paso
	add a,l			;7650
	ld l,a			;7651
	jr nc,L_7655		;7652
	inc h			;7654
L_7655:
	ld b,(hl)			;7655
L_7656:
	ld a,(ix+000h)		;7656   ; La ranura a cero esta libre
	and a			;7659   ; La posicion de la pieza
	jr z,L_766D		;765a
	ld l,(ix+003h)		;765c
	ld h,(ix+005h)		;765f
	push bc			;7662
	call caja_de_la_pieza		;7663
	call cae_dentro_de_la_caja		;7666
	pop bc			;7669
	jp c,le_da_al_jefe		;766a
L_766D:
	exx			;766d   ; Dieciseis bytes: la pieza siguiente
	add ix,de		;766e
	exx			;7670
	djnz L_7656		;7671
	ret			;7673

; ----------------------------------------------------------------------
; DATOS tabla_7674: Siete bytes que lee 0x764D.
;   0x7674..0x767b  (7 bytes)
DATA_tabla_7674:
	defb 001h,008h,007h,001h,002h,008h,001h	; 7674

; ======================================================================
; CODIGO 0x767b..0x76ef  (116 bytes)
; ======================================================================


alto_del_laser:		; El laser mide lo que diga su ficha, mas uno y por ocho
	ld a,007h		;767b   ; Siete bytes mas alla: el largo
	add a,l			;767d
	ld l,a			;767e
	ld a,(hl)			;767f
	inc a			;7680
	add a,a			;7681   ; Mas uno y por ocho
	add a,a			;7682
	add a,a			;7683
	exx			;7684
	ld b,a			;7685
	exx			;7686
	ret			;7687
caja_de_la_pieza:		; Cada pieza del jefe tiene su propia caja, y las de los tipos 4 y 7 salen de la tabla de 0x76EF
	ld a,(ix+000h)		;7688   ; El tipo de pieza manda
	dec a			;768b
	jr z,L_76A0		;768c
	dec a			;768e   ; El tipo 1
	jr z,L_76D5		;768f
	dec a			;7691   ; El tipo 2
	jr z,L_76A4		;7692
	dec a			;7694   ; El tipo 3
	jr z,L_76B8		;7695
	dec a			;7697   ; El tipo 4
	jr z,L_76B4		;7698
	dec a			;769a   ; Y el tipo 5
	jr z,L_76EB		;769b
	dec a			;769d
	jr z,L_76D9		;769e
L_76A0:
	ld bc,05840h		;76a0   ; 0x58 de alto por 0x40 de ancho
	ret			;76a3
L_76A4:
	ld bc,02020h		;76a4   ; 0x20 por 0x20, o mas pequena segun el paso
	ld a,(ix+001h)		;76a7
	dec a			;76aa
	ret m			;76ab
	ld bc,01010h		;76ac
	ret z			;76af
	ld bc,00810h		;76b0
	ret			;76b3
L_76B4:
	ld bc,01010h		;76b4   ; 0x10 por 0x10
	ret			;76b7
L_76B8:
	push de			;76b8
	ld de,076efh		;76b9   ; La tabla de 0x76EF, indexada por la Y
	ld a,(ix+006h)		;76bc
	call corre_el_centro		;76bf
	pop de			;76c2
	ld bc,01008h		;76c3   ; 8 de ancho por 0x10 de alto
	ret			;76c6
corre_el_centro:		; Suma a HL la pareja de la tabla, mas seis en la X
	add a,a			;76c7   ; Por dos: dos bytes por entrada
	call 04062h		;76c8
	ld a,(de)			;76cb
	add a,l			;76cc
	add a,006h		;76cd   ; Y seis mas en la X
	ld l,a			;76cf
	inc de			;76d0
	ld a,(de)			;76d1
	add a,h			;76d2
	ld h,a			;76d3
	ret			;76d4
L_76D5:
	ld bc,02020h		;76d5   ; 0x20 por 0x20
	ret			;76d8
L_76D9:
	ld bc,00808h		;76d9   ; 8 por 8, y el centro sale de otra tabla del banco 2
	push de			;76dc
	ld de,076efh		;76dd
	ld de,08a93h		;76e0
	ld a,(ix+00ah)		;76e3
	call corre_el_centro		;76e6
	pop de			;76e9
	ret			;76ea
L_76EB:
	ld bc,02018h		;76eb   ; 0x18 de ancho por 0x20 de alto
	ret			;76ee

; ----------------------------------------------------------------------
; DATOS tabla_76EF: Ochenta bytes que leen 0x76B9 y 0x76DD.
;   0x76ef..0x773f  (80 bytes)
DATA_tabla_76EF:
	defb 013h,009h,014h,004h,014h,00ah,014h,000h,00ch,004h,004h,00eh,000h,011h,0fch,010h	; 76ef  ................
	defb 0feh,019h,002h,019h,014h,008h,013h,005h,014h,00ah,013h,000h,013h,004h,014h,00eh	; 76ff  ................
	defb 00fh,010h,00bh,010h,009h,018h,006h,018h,014h,008h,014h,00ch,014h,006h,014h,010h	; 770f  ................
	defb 013h,014h,013h,01bh,01fh,018h,00bh,018h,00ah,018h,005h,018h,014h,008h,014h,00ch	; 771f  ................
	defb 015h,007h,014h,011h,00ch,014h,004h,01ah,0ffh,01ah,0fch,018h,0feh,018h,002h,019h	; 772f  ................

; ======================================================================
; CODIGO 0x773f..0x7b3e  (1023 bytes)
; ======================================================================


le_da_al_jefe:		; Gasta el disparo -uno si es laser, cuatro si no-, le quita vida a la pieza y mira si se acabo
	ld a,(ix+000h)		;773f
	dec a			;7742
	jp z,golpe_al_nucleo		;7743
	ld hl,(0ec00h)		;7746   ; El disparo que ha dado
	ld c,001h		;7749
	ld a,(hl)			;774b
	cp 003h		;774c   ; El tipo 3 -el laser- no se gasta: solo quita uno
	jr z,L_7754		;774e
	ld c,004h		;7750   ; Los demas quitan cuatro y desaparecen
	ld (hl),000h		;7752
L_7754:
	ld b,(ix+000h)		;7754
	ld a,(ix+009h)		;7757   ; El byte 9 es la vida de la pieza
	sub c			;775a
	ld (ix+009h),a		;775b
	dec b			;775e
	dec b			;775f
	jr z,golpe_a_la_pieza_1		;7760   ; Cada tipo de pieza remata su golpe por su lado
	dec b			;7762
	jp z,golpe_a_la_pieza_2		;7763
	dec b			;7766
	jr z,L_77DD		;7767   ; El tipo 4
	dec b			;7769
	jr z,revienta_sin_explosion		;776a   ; El tipo 5
	dec b			;776c
	jr z,golpe_a_la_pieza_5		;776d   ; El tipo 6
	dec b			;776f
	jr z,revienta_la_pieza_grande		;7770   ; Y el tipo 7
	ret			;7772
golpe_a_la_pieza_5:		; Con vida de sobra suena el 6; si no, cobra 0x10 puntos
	ld de,00010h		;7773
	dec a			;7776
	jp m,L_7794		;7777
	ld a,006h		;777a   ; El sonido 6: el golpe que aguanta
	jp 049deh		;777c
golpe_a_la_pieza_1:		; Igual, y al agotarse baja la cuenta de piezas de 0xE15B
	dec a			;777f
	jp m,L_7788		;7780
	ld a,006h		;7783
	jp 049deh		;7785
L_7788:
	ld a,(ix+00eh)		;7788   ; El byte 14 dice de que grupo es
	ld hl,0e15bh		;778b   ; 0xE15B: cuantas piezas de ese grupo quedan
	add a,l			;778e
	ld l,a			;778f
	dec (hl)			;7790
	ld de,00030h		;7791   ; 0x30 puntos
L_7794:
	jp revienta_y_cobra		;7794
revienta_la_pieza_grande:		; Al agotarse pone el submodo en 1, suena el 0x0E, cobra 0x10 y monta la explosion
	dec a			;7797
	ld a,006h		;7798
	jp p,049deh		;779a
	ld (ix+00ch),001h		;779d
	ld a,001h		;77a1   ; 0xE10A a uno
	ld (0e10ah),a		;77a3
	ld a,00eh		;77a6   ; El sonido 0x0E
	call 049deh		;77a8
	ld de,00010h		;77ab   ; Diez puntos
	call 055b4h		;77ae
	ld e,(ix+003h)		;77b1
	ld d,(ix+005h)		;77b4
	jp monta_la_explosion_del_fondo		;77b7
revienta_sin_explosion:		; Libera la ranura, cobra 0x30 y suena el 0x0E
	dec a			;77ba   ; La ranura queda libre
	ret p			;77bb
	ld (ix+000h),000h		;77bc
	ld de,00030h		;77c0
	ld a,00eh		;77c3
	jp 049deh		;77c5
revienta_y_cobra:		; Suena el 0x0E, cobra lo que traiga DE, libera la ranura y monta la explosion
	ld a,00eh		;77c8   ; El sonido 0x0E
	call 049deh		;77ca
L_77CD:
	call 055b4h		;77cd   ; Cobra lo que traiga DE
	ld (ix+000h),000h		;77d0
	ld d,(ix+005h)		;77d4
	ld e,(ix+003h)		;77d7
	jp monta_la_explosion_del_fondo		;77da
L_77DD:
	dec a			;77dd
	jp p,L_7806		;77de
	ld a,00eh		;77e1
	call 049deh		;77e3
revienta_esta_pieza:		; Avisa al banco 2 y cobra 0x10
	ld a,(ix+000h)		;77e6   ; La ranura a cero ya esta libre
	and a			;77e9
	ret z			;77ea
	call 082c2h		;77eb
	ld de,00010h		;77ee
	jr L_77CD		;77f1
golpe_a_la_pieza_2:		; Segun la vida que le quede, cambia el dibujo -tres estados- y suena el 0x0D
	dec a			;77f3
	jp m,revienta_las_tres_piezas		;77f4
	ld c,002h		;77f7
	cp 010h		;77f9   ; Por debajo de 0x10, el ultimo dibujo
	jr c,L_7803		;77fb
	dec c			;77fd
	cp 020h		;77fe   ; Y por debajo de 0x20, el de en medio
	jr c,L_7803		;7800
	dec c			;7802
L_7803:
	ld (ix+001h),c		;7803
L_7806:
	ld a,00dh		;7806   ; El sonido 0x0D
	jp 049deh		;7808
revienta_las_tres_piezas:		; Cobra 0x50 por esta y revienta ademas las dos ranuras siguientes
	call 082c2h		;780b
	ld de,00050h		;780e   ; Cincuenta puntos
	call revienta_y_cobra		;7811
	ld de,00010h		;7814   ; Dieciseis bytes: la pieza siguiente
	add ix,de		;7817   ; Dieciseis bytes: la pieza siguiente
	push ix		;7819
	call revienta_esta_pieza		;781b
	pop ix		;781e
	ld de,00010h		;7820
	add ix,de		;7823
	jr revienta_esta_pieza		;7825
golpe_al_nucleo:		; Solo los disparos impares cuentan, y solo por delante: monta la explosion en 0xE300 y le quita vida al nucleo
	ld hl,(0ec00h)		;7827
	ld a,(hl)			;782a
	rra			;782b   ; El bit 0 del tipo: solo la mitad de los disparos valen
	ret nc			;782c
	ld a,(ix+006h)		;782d
	and a			;7830
	jr nz,solo_suena_el_seis		;7831
	ld a,(0e155h)		;7833   ; 0xE155: con el nucleo ya reventado, no
	and a			;7836
	jr nz,solo_suena_el_seis		;7837
	inc l			;7839
	inc l			;783a
	inc l			;783b
	ld a,(ix+003h)		;783c
	add a,01ch		;783f   ; 0x1C por delante y ocho de margen
	sub (hl)			;7841
	add a,008h		;7842
	jr nc,solo_suena_el_seis		;7844
	ld a,015h		;7846   ; Tipo 0x15: la explosion
	ld (0e300h),a		;7848
	ld a,(ix+003h)		;784b   ; 0x18 mas abajo y 0x0C a la derecha
	add a,018h		;784e   ; 0x18 mas abajo y 0x0C a la derecha
	ld (0e304h),a		;7850   ; 0x18 mas abajo
	ld a,(ix+005h)		;7853
	add a,00ch		;7856
	ld (0e306h),a		;7858
	xor a			;785b
	ld (0e302h),a		;785c
	ld (0e31bh),a		;785f
	ld hl,(0ec00h)		;7862
	ld a,(hl)			;7865
	ld a,(hl)			;7866
	cp 003h		;7867   ; El laser no se gasta
	jr z,L_786D		;7869
	ld (hl),000h		;786b
L_786D:
	dec (ix+009h)		;786d   ; El byte 9 es la vida del nucleo
	jr nz,L_7879		;7870
	ld a,001h		;7872   ; 0xE155 a uno: el nucleo esta muerto
	ld (0e155h),a		;7874
	jr L_7806		;7877
L_7879:
	ld a,(ix+009h)		;7879   ; Y cada tres golpes, cinco puntos
	and 003h		;787c
	cp 003h		;787e
	jp nz,L_7806		;7880
	ld de,00005h		;7883
	call 055b4h		;7886
	jp L_7806		;7889
solo_suena_el_seis:		; Al nucleo por detras no se le hace nada
	ld hl,(0ec00h)		;788c   ; Solo el laser suena
	ld a,(hl)			;788f
	cp 003h		;7890
	ret nz			;7892
	ld a,006h		;7893
	jp 049deh		;7895
mira_los_choques_con_el_fondo:		; Los nueve disparos de la nave contra los objetos del fondo de 0xE700; las fases 3 y 5 van por su lado
	ld hl,0e260h		;7898
	ld b,009h		;789b   ; Nueve disparos
	ld a,(0e061h)		;789d
	cp 003h		;78a0   ; La fase 3 tiene su propia cuenta
	jp z,choques_del_fondo_fase_3		;78a2
	cp 005h		;78a5   ; Y la fase 5 tambien
	jp z,choques_del_fondo_fase_5		;78a7
L_78AA:
	ld (0ec00h),hl		;78aa
	push bc			;78ad
	call mira_un_disparo_contra_el_fondo		;78ae
	pop bc			;78b1
	ld hl,(0ec00h)		;78b2
	ld de,00010h		;78b5   ; Dieciseis bytes: el disparo siguiente
	add hl,de			;78b8
	djnz L_78AA		;78b9
	ret			;78bb
mira_un_disparo_contra_el_fondo:		; Recorre los dos objetos de fondo y mira si el disparo cae dentro
	ld a,(hl)			;78bc
	and a			;78bd
	ret z			;78be
	ld c,a			;78bf
	exx			;78c0
	ld de,00008h		;78c1   ; Ocho bytes por objeto
	exx			;78c4
	inc l			;78c5   ; La posicion del disparo
	inc l			;78c6   ; El tipo del disparo
	inc l			;78c7
	ld e,(hl)			;78c8
	inc l			;78c9
	inc l			;78ca
	ld d,(hl)			;78cb
	ld ix,0e700h		;78cc
	ld a,c			;78d0
	ld c,008h		;78d1
	cp 003h		;78d3   ; El laser se mide aparte
	call z,alto_del_laser_por_ocho		;78d5
	ld b,002h		;78d8   ; Dos objetos
L_78DA:
	ld a,(ix+000h)		;78da
	and a			;78dd
	jr z,L_78FB		;78de
	ld a,e			;78e0
	sub (ix+002h)		;78e1
	add a,002h		;78e4
	cp 022h		;78e6   ; 0x22 de ancho
	jr nc,L_78FB		;78e8
	ld a,(ix+003h)		;78ea
	cp 0e8h		;78ed   ; Pasada la Y 0xE8, el objeto se ha ido
	jr nc,L_78FB		;78ef
	sub d			;78f1
	cp c			;78f2
	jp c,le_da_al_objeto_del_fondo		;78f3
	add a,020h		;78f6   ; Y 0x20 de alto
	jp c,le_da_al_objeto_del_fondo		;78f8
L_78FB:
	exx			;78fb
	add ix,de		;78fc   ; Ocho bytes: el objeto siguiente
	exx			;78fe
	djnz L_78DA		;78ff
	ret			;7901
choques_del_fondo_fase_3:		; La fase 3 tiene ocho objetos de fondo y su propia tabla de posiciones
	xor a			;7902
	ld (0e1ffh),a		;7903   ; 0xE1FF a cero
	ld (0ec00h),hl		;7906
	push bc			;7909
	call un_disparo_contra_el_fondo_3		;790a
	pop bc			;790d
	ld hl,(0ec00h)		;790e
	ld de,00010h		;7911   ; Dieciseis bytes: el disparo siguiente
	add hl,de			;7914
	djnz choques_del_fondo_fase_3		;7915
	ret			;7917
un_disparo_contra_el_fondo_3:		; Ocho objetos, cada uno con su desplazamiento sacado de la tabla de 0x7B38
	ld a,(hl)			;7918
	and a			;7919
	ret z			;791a
	ld c,a			;791b
	exx			;791c
	ld de,00008h		;791d   ; Ocho bytes por objeto
	exx			;7920   ; La posicion del disparo
	inc l			;7921   ; El tipo del disparo
	inc l			;7922
	inc l			;7923
	ld e,(hl)			;7924
	inc l			;7925
	inc l			;7926
	ld d,(hl)			;7927
	ld ix,0e700h		;7928
	ld a,c			;792c
	ld c,008h		;792d
	cp 003h		;792f   ; El laser se mide aparte
	call z,alto_del_laser_por_ocho		;7931
	ld b,008h		;7934   ; Ocho objetos
L_7936:
	ld a,(ix+001h)		;7936   ; Solo los que van por el paso 1
	dec a			;7939
	jr nz,L_7969		;793a
	ld a,(ix+000h)		;793c
	and a			;793f
	jr z,L_7969		;7940
	ld hl,l7b38h		;7942   ; La tabla de 0x7B38: el centro de cada tipo
	add a,a			;7945
	add a,l			;7946
	ld l,a			;7947
	jr nc,L_794B		;7948
	inc h			;794a
L_794B:
	ld a,(hl)			;794b
	add a,(ix+002h)		;794c
	sub e			;794f
	add a,010h		;7950   ; 0x10 de ancho
	jr nc,L_7969		;7952
	inc hl			;7954
	ld a,(hl)			;7955
	add a,(ix+003h)		;7956
	jr c,L_7969		;7959
	cp 0f0h		;795b   ; Pasada la Y 0xF0, se ha ido
	jr nc,L_7969		;795d
	sub d			;795f
	cp c			;7960
	jp c,le_da_al_objeto_de_la_fase_3		;7961
	add a,010h		;7964   ; Y 0x10 de alto
	jp c,le_da_al_objeto_de_la_fase_3		;7966   ; 0x10 de alto
L_7969:
	exx			;7969   ; 0x10 de alto
	add ix,de		;796a
	exx			;796c
	djnz L_7936		;796d
	ret			;796f
choques_del_fondo_fase_5:		; Lo mismo para la fase 5
	ld (0ec00h),hl		;7970
	push bc			;7973
	call un_disparo_contra_el_fondo_5		;7974
	pop bc			;7977
	ld hl,(0ec00h)		;7978
	ld de,00010h		;797b   ; Dieciseis bytes: el disparo siguiente
	add hl,de			;797e
	djnz choques_del_fondo_fase_5		;797f
	ret			;7981
un_disparo_contra_el_fondo_5:		; Ocho objetos, y solo los tipos por debajo de 5 que vayan por el paso 2
	ld a,(hl)			;7982
	and a			;7983
	ret z			;7984
	ld c,a			;7985
	exx			;7986
	ld de,00008h		;7987   ; Ocho bytes por objeto
	exx			;798a
	inc l			;798b
	inc l			;798c
	inc l			;798d
	ld e,(hl)			;798e   ; La posicion del disparo
	inc l			;798f
	inc l			;7990
	ld d,(hl)			;7991
	ld ix,0e700h		;7992
	ld a,c			;7996
	ld c,008h		;7997
	cp 003h		;7999   ; El laser se mide aparte
	call z,alto_del_laser_por_ocho		;799b
	ld b,008h		;799e
L_79A0:
	ld a,(ix+000h)		;79a0
	and a			;79a3
	jr z,L_79D2		;79a4
	cp 005h		;79a6   ; Del tipo 5 en adelante se acaba la cuenta
	jr nc,un_disparo_contra_los_muros		;79a8
	ld a,(ix+001h)		;79aa
	cp 002h		;79ad   ; Solo los del paso 2
	jr nz,L_79D2		;79af
	ld a,010h		;79b1
	add a,(ix+002h)		;79b3
	sub e			;79b6
	add a,010h		;79b7   ; 0x10 de ancho
	jr nc,L_79D2		;79b9
	ld a,0f8h		;79bb
	bit 0,(ix+000h)		;79bd   ; El bit 0 del tipo dice si mira arriba o abajo
	jr nz,L_79C5		;79c1
	ld a,020h		;79c3
L_79C5:
	add a,(ix+003h)		;79c5
	sub d			;79c8
	cp c			;79c9
	jp c,le_da_al_muro_de_la_fase_5		;79ca
	add a,010h		;79cd   ; Y 0x10 de alto
	jp c,le_da_al_muro_de_la_fase_5		;79cf   ; Y 0x10 de alto
L_79D2:
	exx			;79d2   ; Ocho bytes: el objeto siguiente
	add ix,de		;79d3
	exx			;79d5
	djnz L_79A0		;79d6
	ret			;79d8
un_disparo_contra_los_muros:		; Los tipos por debajo de 9 de la fase 5 se miden con tres cajas distintas segun el tipo
	ld hl,(0ec00h)		;79d9
	ld a,(hl)			;79dc
	jr c,L_79D2		;79dd
	ld a,(ix+000h)		;79df
	cp 009h		;79e2   ; Del tipo 9 en adelante, nada
	jr nc,L_79D2		;79e4
	cp 007h		;79e6   ; Los tipos 7 y 8 llevan otra caja
	jr nc,caja_de_los_tipos_7_y_8		;79e8
	cp 006h		;79ea   ; Y el 6, otra
	jr z,caja_del_tipo_6		;79ec
	ld a,e			;79ee
	sub (ix+002h)		;79ef
	add a,008h		;79f2
	cp 010h		;79f4   ; 0x10 de ancho
	jr nc,L_79D2		;79f6
	ld a,(ix+003h)		;79f8
	cp 0c8h		;79fb   ; Pasada la Y 0xC8, se ha ido
	jr nc,L_79D2		;79fd
	sub d			;79ff
	cp c			;7a00
	jp c,le_da_al_muro		;7a01
	add a,020h		;7a04   ; 0x20 de alto
	jp c,le_da_al_muro		;7a06
	jr L_79D2		;7a09
caja_del_tipo_6:		; Ocho de ancho, corrida 0x12
	ld a,e			;7a0b   ; Ocho de ancho
	sub (ix+002h)		;7a0c
	sub 012h		;7a0f
	cp 008h		;7a11
	jr nc,L_79D2		;7a13
	ld a,(ix+003h)		;7a15   ; Pasada la Y 0xC8, se ha ido
	cp 0c8h		;7a18
	jr nc,L_79D2		;7a1a
	sub d			;7a1c
	cp c			;7a1d
	jp c,le_da_al_muro		;7a1e
	add a,020h		;7a21
	jp c,le_da_al_muro		;7a23
	jr L_79D2		;7a26
caja_de_los_tipos_7_y_8:		; 0x10 de ancho y con el tope de Y en 0xE8
	ld a,e			;7a28   ; 0x10 de ancho
	sub (ix+002h)		;7a29
	add a,008h		;7a2c
	cp 010h		;7a2e
	jr nc,L_79D2		;7a30
	ld a,(ix+003h)		;7a32   ; Pasada la Y 0xE8, se ha ido
	cp 0e8h		;7a35
	jr nc,L_79D2		;7a37
	sub d			;7a39
	cp c			;7a3a
	jp c,le_da_al_muro		;7a3b
	add a,020h		;7a3e
	jp c,le_da_al_muro		;7a40
	jr L_79D2		;7a43
alto_del_laser_por_ocho:		; El largo del laser, sacado de su ficha y multiplicado por ocho
	ld a,007h		;7a45   ; Siete bytes mas alla: el largo
	add a,l			;7a47   ; Siete bytes mas alla: el largo del laser
	ld l,a			;7a48   ; Por ocho
	ld a,(hl)			;7a49
	add a,a			;7a4a
	add a,a			;7a4b
	add a,a			;7a4c
	ld c,a			;7a4d
	ret			;7a4e
le_da_al_muro:		; Le quita tres de vida si es laser y cinco si no; al agotarse cobra 0x10 y monta la explosion
	ld hl,(0ec00h)		;7a4f
	ld c,003h		;7a52
	ld a,(hl)			;7a54
	cp 003h		;7a55   ; El laser quita tres y no se gasta
	jr z,L_7A5D		;7a57
	ld c,005h		;7a59   ; Los demas quitan cinco y desaparecen
	ld (hl),000h		;7a5b
L_7A5D:
	ld a,(ix+005h)		;7a5d   ; El byte 5 es la vida del muro
	sub c			;7a60
	ld (ix+005h),a		;7a61
	dec a			;7a64
	jp m,L_7A6D		;7a65
	ld a,006h		;7a68   ; El sonido 6: aun aguanta
	jp 049deh		;7a6a
L_7A6D:
	ld de,00010h		;7a6d   ; Diez puntos
	call 055b4h		;7a70
	ld a,00eh		;7a73   ; El sonido 0x0E
	call 049deh		;7a75
	ld a,(ix+000h)		;7a78
	add a,004h		;7a7b   ; El tipo sube cuatro: el muro roto
	ld (ix+000h),a		;7a7d
	cp 00bh		;7a80
	ld a,(ix+002h)		;7a82
	jr nz,L_7A89		;7a85
	sub 018h		;7a87   ; El tipo 0x0B se corre 0x18
L_7A89:
	ld e,a			;7a89
	ld d,(ix+003h)		;7a8a
	jp monta_la_explosion_del_fondo		;7a8d
le_da_al_muro_de_la_fase_5:		; La misma cuenta con el dibujo 0x0F
	ld hl,(0ec00h)		;7a90   ; El laser quita tres y no se gasta
	ld c,003h		;7a93
	ld a,(hl)			;7a95
	cp 003h		;7a96
	jr z,L_7A9E		;7a98
	ld c,005h		;7a9a
	ld (hl),000h		;7a9c
L_7A9E:
	ld a,(ix+005h)		;7a9e   ; El byte 5 es la vida
	sub c			;7aa1
	ld (ix+005h),a		;7aa2
	dec a			;7aa5
	ld a,00fh		;7aa6
	jp m,borra_y_cobra		;7aa8
	ld a,006h		;7aab
	jp 049deh		;7aad
le_da_al_objeto_del_fondo:		; Le pone el dibujo por dos menos uno, le quita vida y, al agotarse, suena el 0x0E y lo borra
	ld a,(ix+000h)		;7ab0
	add a,a			;7ab3   ; El tipo por dos menos uno: el dibujo tocado
	dec a			;7ab4
	ld (ix+006h),a		;7ab5
	ld hl,(0ec00h)		;7ab8
	ld c,003h		;7abb
	ld a,(hl)			;7abd
	cp 003h		;7abe   ; El laser quita tres y no se gasta
	jr z,L_7AC6		;7ac0
	ld c,005h		;7ac2
	ld (hl),000h		;7ac4
L_7AC6:
	ld a,(ix+005h)		;7ac6   ; El byte 5 es la vida
	sub c			;7ac9
	ld (ix+005h),a		;7aca
	dec a			;7acd
	jp m,L_7AD6		;7ace
	ld a,006h		;7ad1   ; El sonido 6: aun aguanta
	jp 049deh		;7ad3
L_7AD6:
	ld a,00eh		;7ad6
borra_y_cobra:		; Suena, borra el objeto de la pantalla, cobra 0x10 y monta la explosion
	call 049deh		;7ad8
	call borra_los_del_fondo		;7adb
	ld de,00010h		;7ade   ; Diez puntos
	call 055b4h		;7ae1
	ld e,(ix+002h)		;7ae4
	ld d,(ix+003h)		;7ae7
	ld (ix+000h),000h		;7aea
	jr $+96		;7aee
le_da_al_objeto_de_la_fase_3:		; Igual, pero enciende 0xE1FF, lo deja en el paso 2 y corre la explosion con la tabla de 0x7B40
	ld a,001h		;7af0   ; 0xE1FF a uno
	ld (0e1ffh),a		;7af2   ; 0xE1FF a uno
	ld hl,(0ec00h)		;7af5
	ld c,003h		;7af8
	ld a,(hl)			;7afa
	cp 003h		;7afb
	jr z,L_7B03		;7afd
	ld c,005h		;7aff
	ld (hl),000h		;7b01
L_7B03:
	ld a,(ix+005h)		;7b03   ; El byte 5 es la vida
	sub c			;7b06
	ld (ix+005h),a		;7b07
	dec a			;7b0a
	jp m,L_7B13		;7b0b
	ld a,006h		;7b0e   ; El sonido 6
	jp 049deh		;7b10
L_7B13:
	call borra_los_del_fondo		;7b13
	ld de,00010h		;7b16   ; Diez puntos
	call 055b4h		;7b19
	ld a,00fh		;7b1c   ; El sonido 0x0F
	call 049deh		;7b1e
	ld e,(ix+002h)		;7b21
	ld d,(ix+003h)		;7b24
	ld (ix+001h),002h		;7b27   ; El objeto pasa al paso 2
	ld a,(ix+000h)		;7b2b
	add a,a			;7b2e
	ld hl,07b40h		;7b2f   ; La tabla de 0x7B40: donde cae la explosion de cada tipo
	call 0405dh		;7b32   ; La tabla de 0x7B40: donde cae la explosion
	ld a,(hl)			;7b35   ; Y la Y
	add a,e			;7b36
	ld e,a			;7b37
L_7B38:
	inc hl			;7b38
	ld a,(hl)			;7b39
	add a,d			;7b3a
	ld d,a			;7b3b
	jr $+18		;7b3c

; ----------------------------------------------------------------------
; DATOS tabla_7B38: Los dos ultimos bytes de la tabla de ocho que 0x7942
;   declara con la base 0x7B38: los seis primeros caen encima del codigo, o
;   sea que solo se usan los indices altos.
;   0x7b3e..0x7b40  (2 bytes)
DATA_tabla_7B38:
	defb 018h,018h	; 7b3e

; ----------------------------------------------------------------------
; DATOS tabla_7B40: Catorce bytes que lee 0x7B2F.
;   0x7b40..0x7b4e  (14 bytes)
DATA_tabla_7B40:
	defb 018h,028h	; 7b40
	defb 008h,038h	; 7b42
	defb 008h,038h	; 7b44
	defb 008h,020h	; 7b46
	defb 008h,010h	; 7b48
	defb 010h,028h	; 7b4a
	defb 0f0h,028h	; 7b4c

; ======================================================================
; CODIGO 0x7b4e..0x7c41  (243 bytes)
; ======================================================================


monta_la_explosion_del_fondo:		; Busca hueco en las cuatro ranuras de 0xE800 y monta ahi la explosion, con su espejo de 0xEA80 a cero
	ld hl,0e800h		;7b4e
	ld b,004h		;7b51   ; Cuatro ranuras
L_7B53:
	ld a,(hl)			;7b53
	and a			;7b54
	jr z,L_7B60		;7b55
	ld a,008h		;7b57   ; Ocho bytes por ranura
	add a,l			;7b59
	ld l,a			;7b5a
	djnz L_7B53		;7b5b
	and 00fh		;7b5d
	ret			;7b5f
L_7B60:
	ld (0ec1ch),hl		;7b60
	ld (hl),020h		;7b63   ; Tipo 0x20 y contador 4
	inc l			;7b65   ; Tipo 0x20 y contador 4: la explosion
	ld (hl),004h		;7b66
	inc l			;7b68
	ld (hl),e			;7b69   ; Donde cae
	inc l			;7b6a
	ld (hl),d			;7b6b
	inc l			;7b6c
	inc l			;7b6d
	inc l			;7b6e
	ld (hl),002h		;7b6f
	ld a,(0e061h)		;7b71
	cp 006h		;7b74   ; La fase 6 no lleva espejo
	ret z			;7b76
	ld a,b			;7b77   ; Cuatro menos la ranura, por dieciseis: su hueco en 0xEA80
	sub 004h		;7b78   ; 0xEC1E se queda con el hueco del espejo
	neg		;7b7a   ; Por dieciseis: su hueco en el espejo
	add a,a			;7b7c
	add a,a			;7b7d
	add a,a			;7b7e
	add a,a			;7b7f
	ld hl,0ea80h		;7b80
	add a,l			;7b83
	ld l,a			;7b84
	ld (0ec1eh),hl		;7b85
	ld b,010h		;7b88   ; Dieciseis bytes a cero
L_7B8A:
	ld (hl),000h		;7b8a
	inc l			;7b8c
	djnz L_7B8A		;7b8d
	xor a			;7b8f
	ret			;7b90
mira_los_choques_de_la_fase_5:		; Solo en la fase 5: los nueve disparos contra las cuatro piezas de 0xE880
	ld a,(0e061h)		;7b91   ; Solo la fase 5
	cp 005h		;7b94
	ret nz			;7b96
	ld hl,0e260h		;7b97
	ld b,009h		;7b9a   ; Nueve disparos
L_7B9C:
	ld (0ec00h),hl		;7b9c
	push bc			;7b9f
	call un_disparo_contra_las_piezas		;7ba0
	pop bc			;7ba3
	ld hl,(0ec00h)		;7ba4
	ld de,00010h		;7ba7   ; Dieciseis bytes: el disparo siguiente
	add hl,de			;7baa   ; Dieciseis bytes: el disparo siguiente
	djnz L_7B9C		;7bab
	ret			;7bad
un_disparo_contra_las_piezas:		; Cuatro piezas de ocho bytes, con caja de 0x22 por 0x20
	ld a,(hl)			;7bae
	and a			;7baf
	ret z			;7bb0
	ld c,a			;7bb1
	exx			;7bb2
	ld de,00008h		;7bb3   ; Ocho bytes por pieza
	exx			;7bb6
	inc l			;7bb7   ; La posicion del disparo
	inc l			;7bb8   ; El tipo del disparo
	inc l			;7bb9
	ld e,(hl)			;7bba
	inc l			;7bbb
	inc l			;7bbc
	ld d,(hl)			;7bbd
	ld ix,0e880h		;7bbe
	ld a,c			;7bc2
	ld c,008h		;7bc3
	cp 003h		;7bc5   ; El laser se mide aparte
	call z,alto_del_laser_por_ocho		;7bc7
	ld b,004h		;7bca   ; Cuatro piezas
L_7BCC:
	ld a,(ix+000h)		;7bcc
	and a			;7bcf
	jr z,L_7BEF		;7bd0
	ld a,(ix+006h)		;7bd2   ; El byte 6 a cero: esta pieza no cuenta
	and a			;7bd5
	jr z,L_7BEF		;7bd6
	ld a,e			;7bd8
	sub (ix+002h)		;7bd9
	add a,002h		;7bdc
	cp 022h		;7bde   ; 0x22 de ancho
	jr nc,L_7BEF		;7be0
	ld a,(ix+003h)		;7be2
	sub d			;7be5
	cp c			;7be6
	jp c,le_da_a_la_pieza_de_la_fase_5		;7be7
	add a,020h		;7bea   ; Y 0x20 de alto
	jp c,le_da_a_la_pieza_de_la_fase_5		;7bec
L_7BEF:
	exx			;7bef
	add ix,de		;7bf0
	exx			;7bf2
	djnz L_7BCC		;7bf3
	ret			;7bf5
le_da_a_la_pieza_de_la_fase_5:		; Le pone el dibujo tocado, le quita vida y, al agotarse, cobra 0x10 y monta la explosion
	ld a,(ix+000h)		;7bf6
	add a,a			;7bf9   ; El tipo por dos menos uno
	dec a			;7bfa
	ld (ix+006h),a		;7bfb
	ld hl,(0ec00h)		;7bfe
	ld c,003h		;7c01
	ld a,(hl)			;7c03
	cp 003h		;7c04   ; El laser quita tres
	jr z,L_7C0C		;7c06
	ld c,005h		;7c08
	ld (hl),000h		;7c0a
L_7C0C:
	ld a,(ix+005h)		;7c0c   ; El byte 5 es la vida
	sub c			;7c0f
	ld (ix+005h),a		;7c10
	dec a			;7c13
	jp m,L_7C1C		;7c14
	ld a,006h		;7c17   ; El sonido 6
	jp 049deh		;7c19
L_7C1C:
	ld de,00010h		;7c1c   ; Diez puntos
	call 055b4h		;7c1f
	ld a,00fh		;7c22   ; El sonido 0x0F
	call 049deh		;7c24
	ld e,(ix+002h)		;7c27
	ld d,(ix+003h)		;7c2a
	ld (ix+000h),000h		;7c2d
	jp monta_la_explosion_del_fondo		;7c31
despacha_el_paso_del_jefe:		; 0xE151 dice si hay jefe y 0xE152 en que paso va: siete salidas
	ld hl,0e151h		;7c34   ; Con 0xE151 a cero no hay jefe
	ld a,(hl)			;7c37
	dec a			;7c38
	ret m			;7c39
	jr z,$+21		;7c3a
	inc hl			;7c3c
	ld a,(hl)			;7c3d
	call 04067h		;7c3e

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_7C3E: Siete palabras pegadas detras del `call
;   0x4067` de 0x7C3E.
;   0x7c41..0x7c4f  (14 bytes)
DATA_tabla_del_despachador_7C3E:
	defw 07c8dh,0839fh	; 7c41  -> despacha_el_paso_del_nucleo 0x839f
	defw 07f74h,08719h	; 7c45  -> paso_del_jefe_de_la_fase_5 0x8719
	defw 087f3h,08ce4h	; 7c49
	defw 083a5h	; 7c4d

; ======================================================================
; CODIGO 0x7c4f..0x7c65  (22 bytes)
; ======================================================================


arranca_el_jefe:		; Sube el paso, pone 0xE190 a cero y deja 0x1E cuadros en 0xE153
	inc (hl)			;7c4f
	xor a			;7c50
	ld (0e190h),a		;7c51
	ld a,01eh		;7c54   ; 0x1E cuadros
	ld (0e153h),a		;7c56
	ret			;7c59
despacha_el_paso_del_jefe_2:		; Otra tabla de siete, indexada por el mismo 0xE152
	ld hl,0e151h		;7c5a   ; Con 0xE151 a cero no hay jefe
	ld a,(hl)			;7c5d
	and a			;7c5e
	ret z			;7c5f
	inc hl			;7c60
	ld a,(hl)			;7c61
	call 04067h		;7c62

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_7C62: Siete palabras pegadas detras del `call
;   0x4067` de 0x7C62.
;   0x7c65..0x7c73  (14 bytes)
DATA_tabla_del_despachador_7C62:
	defw 07e70h,086c6h	; 7c65  -> dibuja_al_jefe 0x86c6
	defw 08293h,07c73h	; 7c69  -> 0x8293 no_hace_nada
	defw 08a21h,08e32h	; 7c6d
	defw 086c0h	; 7c71

; ======================================================================
; CODIGO 0x7c73..0x7c7f  (12 bytes)
; ======================================================================


no_hace_nada:		; Un `ret` suelto: el hueco de las tablas que no tienen nada que hacer en ese paso
	ret			;7c73
despacha_el_dibujo_del_jefe:		; La tercera tabla de siete: quien guarda lo que hay debajo del jefe
	ld hl,0e151h		;7c74   ; Con 0xE151 a cero no hay jefe
	ld a,(hl)			;7c77
	and a			;7c78
	ret z			;7c79
	inc hl			;7c7a
	ld a,(hl)			;7c7b
	call 04067h		;7c7c

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_7C7C: Siete palabras pegadas detras del `call
;   0x4067` de 0x7C7C.
;   0x7c7f..0x7c8d  (14 bytes)
DATA_tabla_del_despachador_7C7C:
	defw 07ec8h,06a37h	; 7c7f  -> borra_al_jefe guarda_lo_de_los_ocho
	defw 08290h,07c73h	; 7c83  -> 0x8290 no_hace_nada
	defw 089e3h,06a37h	; 7c87  -> 0x89e3 guarda_lo_de_los_ocho
	defw 06a2ch	; 7c8b  -> guarda_lo_de_e780

; ======================================================================
; CODIGO 0x7c8d..0x7c93  (6 bytes)
; ======================================================================


despacha_el_paso_del_nucleo:		; Cinco pasos, contados en 0xE190
	ld a,(0e190h)		;7c8d
	call 04067h		;7c90

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_7C90: Cinco palabras pegadas detras del `call
;   0x4067` de 0x7C90.
;   0x7c93..0x7c9d  (10 bytes)
DATA_tabla_del_despachador_7C90:
	defw 07c9dh,07cdfh	; 7c93  -> espera_a_que_no_quede_nadie entra_el_nucleo
	defw 07cfch,07d35h	; 7c97  -> el_nucleo_espera revienta_el_nucleo
	defw 07d5fh	; 7c9b  -> acaba_el_jefe

; ======================================================================
; CODIGO 0x7c9d..0x7e03  (358 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL JEFE DEL FINAL DE FASE, PASO A PASO
; 0xE151 dice que hay jefe y 0xE152 por que paso va; dentro del paso, 0xE190
; lleva la cuenta del nucleo y 0xE153 los cuadros que faltan. Son cinco
; pasos: esperar a que la pantalla se quede vacia, bajar el nucleo,
; esperar a que lo maten, y las dos salidas.
; ----------------------------------------------------------------------
espera_a_que_no_quede_nadie:		; Hasta que no se vacien las veintidos ranuras, el jefe no entra; entonces carga sus graficos y monta la primera pieza
	ld hl,0e153h		;7c9d
	dec (hl)			;7ca0
	ret nz			;7ca1
	ld hl,0e300h		;7ca2   ; Las doce ranuras de 0xE300...
	ld de,00020h		;7ca5
	ld b,00ch		;7ca8
L_7CAA:
	ld a,(hl)			;7caa
	and a			;7cab
	jr nz,espera_un_cuadro_mas		;7cac
	add hl,de			;7cae
	djnz L_7CAA		;7caf
	ld hl,0e500h		;7cb1   ; ...y las diez de 0xE500
	ld b,00ah		;7cb4
L_7CB6:
	ld a,(hl)			;7cb6
	and a			;7cb7
	jr nz,espera_un_cuadro_mas		;7cb8
	add hl,de			;7cba
	djnz L_7CB6		;7cbb
	call 04a6dh		;7cbd   ; Los graficos de la explosion
	xor a			;7cc0
	ld (0e155h),a		;7cc1   ; 0xE155 a cero: el nucleo aun vive
	ld de,0e780h		;7cc4   ; Los trece bytes de 0x7ED9 a 0xE780: la primera pieza
	ld hl,07ed9h		;7cc7
	ld bc,0000dh		;7cca
	ldir		;7ccd
	ld a,03ch		;7ccf   ; 0x3C cuadros
	ld (0e153h),a		;7cd1
paso_siguiente_del_nucleo:		; 0xE190 + 1
	ld hl,0e190h		;7cd4
	inc (hl)			;7cd7
	ret			;7cd8
espera_un_cuadro_mas:		; Aun queda algo vivo: se vuelve a mirar al cuadro siguiente
	ld a,001h		;7cd9
	ld (0e153h),a		;7cdb
	ret			;7cde
entra_el_nucleo:		; Cada ocho cuadros lo corre ocho puntos a la izquierda hasta la columna 0x98, y ahi se queda 0x2D0 cuadros
	ld a,(0e003h)		;7cdf   ; Uno de cada ocho cuadros
	and 007h		;7ce2
	ret nz			;7ce4
	ld hl,0e785h		;7ce5
	ld a,(hl)			;7ce8
	sub 008h		;7ce9   ; Ocho puntos a la izquierda
	ld (hl),a			;7ceb
	cp 098h		;7cec   ; Hasta la columna 0x98
	ret nz			;7cee
	ld hl,002d0h		;7cef   ; 0x2D0 cuadros parado
	ld (0e153h),hl		;7cf2
	ld a,001h		;7cf5
	ld (0e786h),a		;7cf7
	jr paso_siguiente_del_nucleo		;7cfa
el_nucleo_espera:		; Mientras viva, dispara y cambia de cara segun los cuadros que le queden: a los 0x258 una, a los 0x78 otra
	ld a,(0e155h)		;7cfc   ; 0xE155 puesto: el nucleo ya esta muerto
	and a			;7cff
	jr nz,el_nucleo_se_va		;7d00
	call mueve_al_jefe		;7d02
	call el_nucleo_dispara		;7d05
	ld hl,(0e153h)		;7d08
	dec hl			;7d0b
	ld (0e153h),hl		;7d0c
	ld de,00258h		;7d0f   ; A falta de 0x258 cuadros, la primera cara
	rst 20h			;7d12
	jr nz,L_7D1A		;7d13
	xor a			;7d15
	ld (0e786h),a		;7d16
	ret			;7d19
L_7D1A:
	ld de,00078h		;7d1a   ; Y a falta de 0x78, la segunda
	rst 20h			;7d1d
	jr nz,L_7D26		;7d1e
	ld a,001h		;7d20
	ld (0e786h),a		;7d22
	ret			;7d25
L_7D26:
	ld a,l			;7d26   ; Con la cuenta agotada, el nucleo se va
	or h			;7d27
	ret nz			;7d28
el_nucleo_se_va:		; Cara 2, 0x28 cuadros y al paso siguiente
	ld a,002h		;7d29
	ld (0e786h),a		;7d2b
	ld a,028h		;7d2e   ; 0x28 cuadros
	ld (0e153h),a		;7d30
	jr paso_siguiente_del_nucleo		;7d33
revienta_el_nucleo:		; Lo borra, monta la explosion, suena el 0x3B y, si estaba vivo, cobra 0x100
	ld hl,0e153h		;7d35
	dec (hl)			;7d38   ; 0xE153: los cuadros que faltan
	ret nz			;7d39
	xor a			;7d3a
	ld (0e780h),a		;7d3b   ; 0xE780 a cero: la pieza se va
	ld de,01808h		;7d3e
	call casilla_del_jefe		;7d41
	ex de,hl			;7d44
	call monta_la_explosion_del_fondo		;7d45
	ld a,03bh		;7d48   ; El sonido 0x3B
	call 049deh		;7d4a
	ld de,00100h		;7d4d   ; Cien puntos, y solo si el nucleo seguia vivo
	ld a,(0e155h)		;7d50
	and a			;7d53
	call nz,055b4h		;7d54
	ld a,078h		;7d57   ; 0x78 cuadros
	ld (0e153h),a		;7d59   ; 0x78 cuadros
	jp paso_siguiente_del_nucleo		;7d5c
acaba_el_jefe:		; Al agotarse la cuenta, 0xE150 a uno: la fase puede seguir
	ld hl,0e153h		;7d5f
	dec (hl)			;7d62
	ret nz			;7d63
marca_que_el_jefe_murio:		; 0xE150 a uno
	ld a,001h		;7d64
	ld (0e150h),a		;7d66
	ret			;7d69
el_nucleo_dispara:		; De la segunda vuelta en adelante: cada seis disparos del jugador suelta uno apuntado, con velocidad 0x60
	ld a,(0e06ah)		;7d6a   ; Solo de la segunda vuelta en adelante
	and a			;7d6d
	ret z			;7d6e
	ld hl,0e78ch		;7d6f   ; 0xE78C: los que le quedan por soltar
	ld a,(hl)			;7d72
	and a			;7d73
	jr nz,L_7D7F		;7d74
	ld a,(0e008h)		;7d76   ; El bit 4 de lo recien pulsado: el disparo del jugador
	and 010h		;7d79
	ret z			;7d7b
	ld (hl),006h		;7d7c   ; Seis de una tacada
	ret			;7d7e
L_7D7F:
	dec (hl)			;7d7f
	ld a,(0e783h)		;7d80   ; Sale 0x1C por debajo del nucleo y ocho a su derecha
	add a,01ch		;7d83
	ld e,a			;7d85
	ld a,(0e785h)		;7d86
	add a,008h		;7d89
	ld d,a			;7d8b
	ld a,060h		;7d8c   ; Velocidad 0x60
	ld (0e110h),a		;7d8e
	push de			;7d91
	call apunta_a_la_nave		;7d92
	pop de			;7d95
	ld hl,0e580h		;7d96   ; Las seis ranuras de 0xE580
	ld b,006h		;7d99
L_7D9B:
	ld a,(hl)			;7d9b
	and a			;7d9c
	jp z,monta_el_disparo		;7d9d
	ld a,020h		;7da0   ; Treinta y dos bytes: la siguiente
	call 0405dh		;7da2   ; Treinta y dos bytes: la ranura siguiente
	djnz L_7D9B		;7da5
	ret			;7da7
suelta_cuatro_disparos:		; Monta las cuatro ranuras de 0xE500 con los cuatro disparos, cada uno con su desplazamiento de la tabla de 0x7E03
	ld a,(0e783h)		;7da8
	ld e,a			;7dab
	ld a,(0e785h)		;7dac
	ld d,a			;7daf
	exx			;7db0
	ld hl,07e03h		;7db1   ; La tabla de 0x7E03: donde sale cada uno
	exx			;7db4
	ld hl,0e500h		;7db5
	ld b,004h		;7db8   ; Cuatro disparos
monta_uno_de_los_cuatro:		; Rellena la ranura y le pone la velocidad, que sale de la dificultad: cuanto mayor, mas rapido
	push de			;7dba
	ld (hl),001h		;7dbb   ; La ranura queda ocupada
	inc l			;7dbd   ; Cuatro bytes mas alla
	inc l			;7dbe
	inc l			;7dbf
	inc l			;7dc0
	exx			;7dc1
	ld a,(hl)			;7dc2
	inc hl			;7dc3
	exx			;7dc4
	add a,e			;7dc5   ; La X de partida...
	ld (hl),a			;7dc6   ; La X, y el byte de al lado a cero
	inc l			;7dc7
	ld (hl),000h		;7dc8
	inc l			;7dca
	exx			;7dcb
	ld a,(hl)			;7dcc
	inc hl			;7dcd
	exx			;7dce
	add a,d			;7dcf   ; ...y la Y
	ld (hl),a			;7dd0
	inc l			;7dd1
	xor a			;7dd2   ; Los contadores, a cero
	ld (hl),a			;7dd3
	inc l			;7dd4
	ld (hl),a			;7dd5
	inc l			;7dd6
	push hl			;7dd7
	ld a,(0e111h)		;7dd8   ; La dificultad, en negativo
	inc a			;7ddb
	neg		;7ddc
	ld l,a			;7dde
	ld h,0ffh		;7ddf
	add hl,hl			;7de1   ; Por 0x20
	add hl,hl			;7de2
	add hl,hl			;7de3
	add hl,hl			;7de4
	add hl,hl			;7de5
	ld de,0fa00h		;7de6   ; Sumada a 0xFA00: la velocidad
	add hl,de			;7de9
	ex de,hl			;7dea
	pop hl			;7deb
	ld (hl),e			;7dec
	inc l			;7ded
	ld (hl),d			;7dee
	inc l			;7def
	ld a,b			;7df0   ; El bit 0 del contador: uno de dos dibujos
	and 001h		;7df1
	add a,002h		;7df3
	ld (hl),a			;7df5
	ld de,00010h		;7df6   ; Dieciseis bytes mas alla, la marca
	add hl,de			;7df9
	ld (hl),001h		;7dfa   ; Y la marca de vivo
	ld e,005h		;7dfc   ; Cinco bytes mas: la ranura siguiente
	add hl,de			;7dfe
	pop de			;7dff
	djnz monta_uno_de_los_cuatro		;7e00
	ret			;7e02

; ----------------------------------------------------------------------
; DATOS tabla_7E03: Ocho bytes que lee 0x7DB1.
;   0x7e03..0x7e0b  (8 bytes)
DATA_tabla_7E03:
	defb 000h,010h	; 7e03
	defb 010h,0f0h	; 7e05
	defb 028h,0f0h	; 7e07
	defb 038h,010h	; 7e09

; ======================================================================
; CODIGO 0x7e0b..0x7ed9  (206 bytes)
; ======================================================================


mueve_al_jefe:		; Elige un dibujo con el registro R, decide hacia que lado va segun donde este la nave, y va dando pasos
	ld hl,0e781h		;7e0b   ; 0xE781: si ya esta en marcha
	ld a,(hl)			;7e0e
	and a			;7e0f
	jr nz,da_un_paso_el_jefe		;7e10
	inc (hl)			;7e12
	ld a,r		;7e13   ; El registro R: uno de cuatro dibujos
	and 003h		;7e15
	ld (0e78bh),a		;7e17
	ld a,(0e783h)		;7e1a   ; 0x18 a la derecha del jefe
	add a,018h		;7e1d
	ld c,a			;7e1f
	ld a,(0e204h)		;7e20   ; La fila de la nave: hacia ese lado va
	cp c			;7e23
	ld a,000h		;7e24
	jr c,L_7E29		;7e26
	inc a			;7e28
L_7E29:
	ld (0e787h),a		;7e29
	jp suelta_cuatro_disparos		;7e2c
da_un_paso_el_jefe:		; Cada tantos cuadros -menos cuantos mas difícil- se corre ocho puntos, y a los once pasos se para
	ld hl,0e78ah		;7e2f   ; 0xE78A: los cuadros que faltan para el paso siguiente
	dec (hl)			;7e32
	ret nz			;7e33
	ld a,(0e111h)		;7e34   ; La dificultad: cinco, cuatro o tres cuadros por paso
	ld c,005h		;7e37   ; La dificultad manda los cuadros por paso
	cp 004h		;7e39
	jr c,L_7E43		;7e3b
	dec c			;7e3d
	cp 00ah		;7e3e
	jr c,L_7E43		;7e40
	dec c			;7e42
L_7E43:
	ld (hl),c			;7e43   ; Y se apunta para el paso siguiente
	inc l			;7e44
	inc (hl)			;7e45
	ld a,(hl)			;7e46
	cp 00bh		;7e47   ; Once pasos y se para
	jr nz,L_7E50		;7e49
	xor a			;7e4b
	ld (0e781h),a		;7e4c
	ret			;7e4f
L_7E50:
	ld a,(0e787h)		;7e50   ; 0xE787 dice hacia que lado
	ld b,a			;7e53
	ld c,0f8h		;7e54   ; Ocho a la izquierda o a la derecha
	and a			;7e56   ; Ocho a un lado o al otro
	jr z,L_7E5B		;7e57
	ld c,008h		;7e59
L_7E5B:
	ld hl,0e783h		;7e5b
	ld a,(hl)			;7e5e
	add a,c			;7e5f
	ld (hl),a			;7e60
	ld c,001h		;7e61
	cp 010h		;7e63   ; Por debajo de la X 0x10 se da la vuelta
	jr c,L_7E6B		;7e65
	dec c			;7e67
	cp 078h		;7e68   ; Y por encima de la 0x78, tambien
	ret c			;7e6a   ; Se apunta hacia que lado va
L_7E6B:
	ld a,c			;7e6b   ; Y se guarda el lado
	ld (0e787h),a		;7e6c
	ret			;7e6f
dibuja_al_jefe:		; Pinta las tres partes: el cuerpo de 0x0B por 8 caracteres, el ojo y la boca, cada una con su tabla
	ld a,(0e780h)		;7e70
	dec a			;7e73
	ret nz			;7e74
	ld de,00000h		;7e75
	call casilla_del_jefe		;7e78
	jr c,L_7E86		;7e7b
	ld bc,00b08h		;7e7d   ; 0x0B de ancho por 8 de alto: el cuerpo
	ld de,07ee6h		;7e80
	call 0490ch		;7e83
L_7E86:
	ld de,00818h		;7e86   ; El ojo, ocho a la derecha y 0x18 mas abajo
	call casilla_del_jefe		;7e89
	jr c,L_7EA3		;7e8c
	ld de,07f3eh		;7e8e
	ld a,(0e789h)		;7e91   ; 0xE789 elige uno de los dibujos del ojo
	rra			;7e94
	and 00eh		;7e95
	ld c,a			;7e97
	add a,a			;7e98
	add a,c			;7e99   ; Por tres: tres caracteres por dibujo
	call 04062h		;7e9a
	ld bc,00302h		;7e9d   ; Tres de ancho por dos de alto
	call 0490ch		;7ea0
L_7EA3:
	ld de,02018h		;7ea3   ; Y la boca, 0x20 a la derecha
	call casilla_del_jefe		;7ea6
	ret c			;7ea9
	ld de,07f62h		;7eaa
	ld a,(0e786h)		;7ead   ; 0xE786: la cara que toca
	add a,a			;7eb0
	ld c,a			;7eb1
	add a,a			;7eb2
	add a,c			;7eb3
	call 04062h		;7eb4
	ld bc,00302h		;7eb7
	jp 0490ch		;7eba
casilla_del_jefe:		; La posicion del jefe mas el desplazamiento que traiga DE
	ld a,(0e783h)		;7ebd   ; La fila del jefe -0xE783- y su columna -0xE785-, mas lo que traiga DE
	add a,e			;7ec0
	ld l,a			;7ec1
	ld a,(0e785h)		;7ec2
	add a,d			;7ec5
	ld h,a			;7ec6
	ret			;7ec7
borra_al_jefe:		; Borra el rectangulo de 0x0B por 8 del cuerpo
	ld a,(0e780h)		;7ec8   ; Solo con 0xE780 en uno
	dec a			;7ecb
	ret nz			;7ecc
	ld de,00000h		;7ecd
	call casilla_del_jefe		;7ed0
	ld bc,00b08h		;7ed3
	jp 048f7h		;7ed6

; ----------------------------------------------------------------------
; DATOS primera_pieza_del_jefe: Los trece bytes que 0x7CC7 copia a 0xE780
;   cuando el jefe entra: la ficha de arranque de su primera pieza.
;   0x7ed9..0x7ee6  (13 bytes)
DATA_primera_pieza_del_jefe:
	defb 001h,000h,000h,040h,000h,0f8h,001h,000h,010h,016h,001h,000h,000h	; 7ed9  ...@.........

; ----------------------------------------------------------------------
; DATOS dibujo_del_cuerpo: Los 88 caracteres del cuerpo del jefe, 0x0B de
;   ancho por 8 de alto, que 0x7E80 copia al mapa con 0x490C.
;   0x7ee6..0x7f3e  (88 bytes)
DATA_dibujo_del_cuerpo:
	defb 000h,000h,000h,000h,0a3h,044h,045h,046h,047h,048h,000h	; 7ee6  .....DEFGH.
	defb 000h,000h,0a4h,049h,04ah,04bh,0a7h,0a8h,0a9h,04ch,04dh	; 7ef1  ...IJK...LM
	defb 0a5h,04eh,04fh,050h,0aah,0abh,0ach,0adh,0aeh,0afh,051h	; 7efc  .NOP......Q
	defb 0a6h,000h,000h,000h,000h,000h,000h,0b4h,0b5h,0b6h,052h	; 7f07  ..........R
	defb 0c4h,000h,000h,000h,000h,000h,000h,0d2h,0d3h,0d4h,064h	; 7f12  ..........d
	defb 0c3h,060h,061h,062h,0c8h,0c9h,0cah,0cbh,0cch,0cdh,063h	; 7f1d  .`ab......c
	defb 000h,000h,0c2h,05bh,05ch,05dh,0c5h,0c6h,0c7h,05eh,05fh	; 7f28  ...[\]...^_
	defb 000h,000h,000h,000h,0c1h,056h,057h,058h,059h,05ah,000h	; 7f33  .....VWXYZ.

; ----------------------------------------------------------------------
; DATOS tabla_7F3E: Treinta y seis bytes que lee 0x7E8E.
;   0x7f3e..0x7f62  (36 bytes)
DATA_tabla_7F3E:
	defb 055h,055h,0bah,067h,067h,0d8h,055h,055h	; 7f3e  UU.gg.UU
	defb 0b0h,067h,067h,0ceh,055h,054h,0b0h,067h	; 7f46  .gg.UT.g
	defb 066h,0ceh,055h,053h,0b0h,067h,065h,0ceh	; 7f4e  f.US.ge.
	defb 054h,053h,0b0h,066h,065h,0ceh,053h,053h	; 7f56  TS.fe.SS
	defb 0b0h,065h,065h,0ceh	; 7f5e

; ----------------------------------------------------------------------
; DATOS tabla_7F62: Dieciocho bytes que lee 0x7EAA.
;   0x7f62..0x7f74  (18 bytes)
DATA_tabla_7F62:
	defb 0b7h,0b8h,0b9h,0d5h,0d6h,0d7h,0b1h,0b2h	; 7f62  ........
	defb 0b3h,0cfh,0d0h,0d1h,0bbh,0bch,0bdh,0d9h	; 7f6a  ........
	defb 0dah,0dbh	; 7f72

; ======================================================================
; CODIGO 0x7f74..0x7ffe  (138 bytes)
; ======================================================================


paso_del_jefe_de_la_fase_5:		; Espera a que se vacien las doce ranuras, deja 0x40 cuadros y arranca el jefe de esa fase
	ld a,(0e190h)		;7f74
	dec a			;7f77
	jr z,corre_al_jefe_de_la_fase_5		;7f78
	dec a			;7f7a
	jr z,acaba_el_jefe_de_la_fase_5		;7f7b
	ld hl,0e300h		;7f7d   ; Las doce ranuras de 0xE300
	ld de,00020h		;7f80
	ld b,00ch		;7f83
L_7F85:
	ld a,(hl)			;7f85
	and a			;7f86
	ret nz			;7f87
	add hl,de			;7f88
	djnz L_7F85		;7f89
	ld a,040h		;7f8b   ; 0x40 cuadros
	ld (0e153h),a		;7f8d
	ld hl,00000h		;7f90
	ld (0e116h),hl		;7f93
	ld hl,(0e063h)		;7f96   ; Pasada la distancia 0xFF, arranca en el paso 2
	ld de,000ffh		;7f99   ; La distancia 0xFF
	rst 20h			;7f9c
	jr c,L_7FA4		;7f9d
	ld a,002h		;7f9f
	ld (0e116h),a		;7fa1
L_7FA4:
	ld hl,0e190h		;7fa4
	inc (hl)			;7fa7
	ret			;7fa8
corre_al_jefe_de_la_fase_5:		; Con el banco 10 puesto, cuatro rutinas suyas; cuando 0xE790 y 0xE7C0 se apagan, se acaba
	di			;7fa9   ; Banco 10 en 0xA000
	ld a,00ah		;7faa   ; Banco 10 en 0xA000
	ld (0a000h),a		;7fac
	ld (0f0f3h),a		;7faf
	ei			;7fb2
	call arranca_o_avanza		;7fb3
	call 081d5h		;7fb6
	call 08100h		;7fb9
	call 08073h		;7fbc
	di			;7fbf   ; Devuelto el 3
	ld a,003h		;7fc0
	ld (0a000h),a		;7fc2
	ld (0f0f3h),a		;7fc5
	ei			;7fc8
	ld a,(0e117h)		;7fc9   ; 0xE117: el jefe ya esta en marcha
	and a			;7fcc
	ret z			;7fcd
	ld a,(0e790h)		;7fce   ; Hasta que las dos casillas no esten a cero, sigue
	ld hl,0e7c0h		;7fd1   ; Y 0xE7C0
	or (hl)			;7fd4
	ret nz			;7fd5
	jr L_7FA4		;7fd6
acaba_el_jefe_de_la_fase_5:		; 0xE150 a uno
	ld a,001h		;7fd8
	ld (0e150h),a		;7fda
	ret			;7fdd
arranca_o_avanza:		; Pasada la distancia 0x1A0 se enciende 0xE117; si no, cada 0xC0 cuadros avanza el guion de 0xE116
	ld hl,(0e063h)		;7fde
	ld de,001a0h		;7fe1   ; La distancia 0x1A0
	rst 20h			;7fe4
	jr c,L_7FED		;7fe5
	ld a,001h		;7fe7
	ld (0e117h),a		;7fe9
	ret			;7fec
L_7FED:
	ld hl,0e153h		;7fed   ; 0xE153: los cuadros que faltan
	dec (hl)			;7ff0
	ret nz			;7ff1
	ld (hl),0c0h		;7ff2   ; Otros 0xC0
	ld hl,0e116h		;7ff4
	ld a,(hl)			;7ff7
	inc (hl)			;7ff8
	and 00fh		;7ff9   ; Dieciseis pasos en redondo
	ld c,a			;7ffb
	ld b,000h		;7ffc

; ----------------------------------------------------------------------
; DATOS instruccion_partida: Los dos primeros bytes de un `ld hl,0x8041` cuyo
;   tercer byte -el 0x80- es el PRIMER byte del banco 2. La instruccion existe
;   solo cuando el banco 1 esta en 0x6000 y el 2 en 0x8000, que es como los
;   mapea siempre INIT. Se listan como bytes porque este listado acaba en
;   0x7FFF.
;   0x7ffe..0x8000  (2 bytes)

; ----------------------------------------------------------------------
; LA ULTIMA INSTRUCCION SE PARTE ENTRE ESTE BANCO Y EL SIGUIENTE
; ----------------------------------------------------------------------
DATA_instruccion_partida:
	defb 021h,041h	; 7ffe

; ==========================================================================
; NEMESIS / GRADIUS - Konami (1986) - MSX1 - MegaROM RC-742 de 128 KB (Konami4) - banco 00 (se ejecuta en 0x4000)
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x04000


; ----------------------------------------------------------------------
; Etiquetas que no caen en ninguna posicion emitida del listado
; (destinos fuera del binario o dentro de una instruccion).
; ----------------------------------------------------------------------
L_55F4:	equ 0x055f4

; ----------------------------------------------------------------------
; Direcciones que solo aparecen como VALOR -en un `ld`, no en
; un salto-: son punteros que el codigo se pasa o numeros que
; casualmente coinciden con una direccion. No hay nada que
; trazar en ellas; el equ existe para que el listado ensamble.
; ----------------------------------------------------------------------
l56d1h:	equ 0x056d1
l5d1dh:	equ 0x05d1d

; ----------------------------------------------------------------------
; DATOS cabecera: Cabecera de cartucho de MSX: "AB", INIT = 0x4071, y las
;   otras tres entradas (STATEMENT, DEVICE, TEXT) a cero, mas seis bytes
;   reservados.
;   0x4000..0x4010  (16 bytes)

; ----------------------------------------------------------------------
; CABECERA DEL CARTUCHO
; ----------------------------------------------------------------------
DATA_cabecera:
	defb 041h,042h	; 4000
	defw 04071h	; 4002  -> INIT
	defw 00000h	; 4004
	defw 00000h	; 4006
	defw 00000h	; 4008
	defb 000h,000h,000h,000h,000h,000h	; 400a

; ----------------------------------------------------------------------
; DATOS bytes_sin_identificar: Once bytes pegados detras de la cabecera que
;   ninguna instruccion trazada lee: 43 44 07 42 80 00 E0 04 61 E0 08. Los dos
;   primeros son "CD" en ASCII. SUPOSICION: los cinco ultimos parecen la
;   primera parte de la lista de direcciones de RAM que sigue debajo, pero no
;   hay ni una instruccion que lo demuestre.
;   0x4010..0x401b  (11 bytes)
DATA_bytes_sin_identificar:
	defb 043h,044h,007h,042h,080h,000h,0e0h,004h,061h,0e0h,008h	; 4010  CD.B....a..

; ----------------------------------------------------------------------
; DATOS direcciones_de_ram: Cinco palabras que son direcciones de la memoria
;   del juego: 0xE060, 0xE05A, 0xE05B, 0xE057 y 0xE002. SUPOSICION: nadie las
;   lee desde el codigo trazado, asi que quien las use tiene que ser la rutina
;   que el banco 10 copia a la RAM (0xA849 -> 0xE710), que este desensamblado
;   no puede seguir.
;   0x401b..0x4025  (10 bytes)
DATA_direcciones_de_ram:
	defw 0e060h,0e053h	; 401b
	defw 0e05bh,0e057h	; 401f
	defw 0e002h	; 4023

; ======================================================================
; CODIGO 0x4025..0x40fd  (216 bytes)
; ======================================================================


salta_a_la_presentacion:		; `jp 0x5A54`. Es el unico sitio que entra en la presentacion.
	jp presentacion		;4025

; ----------------------------------------------------------------------
; LA INTERRUPCION
; ----------------------------------------------------------------------
interrupcion:		; Lo que INIT instala en el gancho H.KEYI (0xFD9A). AQUI CORRE TODO EL JUEGO.
	call 0013eh		;4028   ; BIOS RDVDP - Reads VDP status register | Leer el estado del VDP es lo que da por atendida la interrupcion.
	di			;402b
	ld a,007h		;402c   ; Banco 7 en 0x8000 y banco 8 en 0xA000: el reproductor de sonido y sus datos.
	ld (08000h),a		;402e   ; OJO: aqui NO se toca la copia en RAM de 0xF0F2, y por eso se puede deshacer luego.
	inc a			;4031
	ld (0a000h),a		;4032
	call 08063h		;4035   ; El sonido corre entero dentro de la interrupcion.
	di			;4038
	ld a,(0f0f2h)		;4039   ; Se devuelve el reparto que hubiera antes, leyendolo de la copia en RAM.
	ld (08000h),a		;403c
	ld a,(0f0f3h)		;403f
	ld (0a000h),a		;4042
	ld hl,0e005h		;4045   ; Cerrojo: si el bucle de juego ya esta dentro, esta interrupcion no vuelve a entrar.
	bit 0,(hl)		;4048
	jr nz,L_4058		;404a
	inc (hl)			;404c
	ei			;404d   ; El `ei` va ANTES del trabajo largo: la siguiente interrupcion puede pillarle a medias.
	call lee_el_mando		;404e
	call maquina_de_estados		;4051   ; Y aqui empieza el juego de verdad.
	xor a			;4054
	ld (0e005h),a		;4055   ; Se suelta el cerrojo.
L_4058:
	ei			;4058
	ret			;4059
L_405A:
	jp 00047h		;405a   ; BIOS WRTVDP - Writes data in the VDP-register
suma_a_a_hl:		; HL += A, con el acarreo bien puesto. La llaman 48 sitios.
	add a,l			;405d   ; HL = HL + A, arreglando H si hay acarreo.
	ld l,a			;405e
	ret nc			;405f
	inc h			;4060
	ret			;4061
suma_a_a_de:		; DE += A. La llaman 26 sitios.
	add a,e			;4062   ; DE = DE + A, lo mismo.
	ld e,a			;4063
	ret nc			;4064
	inc d			;4065
	ret			;4066

; ----------------------------------------------------------------------
; EL DESPACHADOR DE KONAMI
; ----------------------------------------------------------------------
despachador:		; El despachador de Konami: la tabla de destinos va PEGADA detras del `call`.
	pop hl			;4067   ; `pop hl` saca la direccion de RETORNO, que es donde empieza la tabla.
	add a,a			;4068   ; Cada entrada son dos bytes, asi que el indice se dobla.
	call suma_a_a_hl		;4069
	ld e,(hl)			;406c   ; La palabra de la tabla es el destino...
	inc hl			;406d
	ld d,(hl)			;406e
	ex de,hl			;406f
	jp (hl)			;4070   ; ...y aqui se salta. Quien llama NO vuelve: la tabla se come el retorno.

; ----------------------------------------------------------------------
; INIT: EL ARRANQUE
; ----------------------------------------------------------------------
INIT:		; Lo que llama la BIOS al arrancar (la cabecera AB lo dice en 0x4002).
	di			;4071
	im 1		;4072   ; Modo 1 de interrupcion: el gancho de la BIOS en 0x0038 acaba llevando a 0xFD9A.
	di			;4074
	push hl			;4075
	ld hl,0f0f1h		;4076   ; 0xF0F1, 0xF0F2 y 0xF0F3 son la copia en RAM de los tres registros del mapper.
	ld a,001h		;4079
	ld (06000h),a		;407b   ; Banco 1 en 0x6000...
	ld (hl),a			;407e
	inc a			;407f
	ld (08000h),a		;4080   ; ...banco 2 en 0x8000...
	inc hl			;4083
	ld (hl),a			;4084
	inc a			;4085
	ld (0a000h),a		;4086   ; ...y banco 3 en 0xA000. Es el reparto por defecto de todo el juego.
	inc hl			;4089
	ld (hl),a			;408a
	pop hl			;408b
	ei			;408c
	call busca_mi_ranura		;408d
	ld h,080h		;4090   ; H = 0x80: se habilita este cartucho en la pagina 2, que es donde caen 0x8000 y 0xA000.
	call 00024h		;4092   ; BIOS ENASLT - Switches to specified slot and page definitively
	ld a,0c3h		;4095   ; Se instala `jp interrupcion` en el gancho H.KEYI.
	ld (0fd9ah),a		;4097
	ld hl,interrupcion		;409a
	ld (0fd9bh),hl		;409d
	ld sp,0f0f0h		;40a0   ; La pila, justo debajo de la copia del mapper.
	ld hl,0e000h		;40a3   ; Se limpian los 4 KB de 0xE000 a 0xEFFF, que es toda la memoria del juego.
	ld de,0e001h		;40a6
	ld bc,00fffh		;40a9
	ld (hl),000h		;40ac
	ldir		;40ae
	ld a,001h		;40b0
	ld (0e005h),a		;40b2   ; 0xE005 y 0xE006 a 1: el cerrojo puesto mientras se arranca.
	ld (0e006h),a		;40b5
	call arranca_la_maquina		;40b8
	call busca_el_otro_cartucho		;40bb
	xor a			;40be
	ld (0e005h),a		;40bf
	call 0013eh		;40c2   ; BIOS RDVDP - Reads VDP status register
	di			;40c5   ; Y otra vez el reparto de siempre, ya con la RAM limpia
	push hl			;40c6
	ld hl,0f0f1h		;40c7
	ld a,001h		;40ca
	ld (06000h),a		;40cc
	ld (hl),a			;40cf
	inc a			;40d0
	ld (08000h),a		;40d1
	inc hl			;40d4
	ld (hl),a			;40d5
	inc a			;40d6
	ld (0a000h),a		;40d7
	inc hl			;40da
	ld (hl),a			;40db
	pop hl			;40dc
	ei			;40dd
	ei			;40de   ; Aqui se acaba INIT, y aqui se queda: el `jr $` de al lado no sale nunca.
L_40DF:
	jr L_40DF		;40df   ; Y hasta aqui INIT. De aqui no se sale: lo demas pasa en la interrupcion.
busca_mi_ranura:		; Compone para ENASLT el numero de ranura de este cartucho, leyendo RSLREG y SLTTBL.
	call 00138h		;40e1   ; BIOS RSLREG - Reads the primary slot register | RSLREG: el registro de ranuras primarias
	rrca			;40e4   ; Dos rotaciones: la ranura de la pagina 1, que es donde cae este cartucho
	rrca			;40e5
	and 003h		;40e6
	ld c,a			;40e8
	ld b,000h		;40e9
	ld hl,0fcc1h		;40eb   ; 0xFCC1: la tabla de la BIOS que dice si esa ranura tiene subranuras
	add hl,bc			;40ee
	ld a,(hl)			;40ef
	and 080h		;40f0   ; El bit 7 marca que las tiene
	or c			;40f2
	ld c,a			;40f3
	inc hl			;40f4   ; Cuatro mas: la subranura de la pagina 1
	inc hl			;40f5
	inc hl			;40f6
	inc hl			;40f7
	ld a,(hl)			;40f8
	and 00ch		;40f9
	or c			;40fb
	ret			;40fc

; ----------------------------------------------------------------------
; DATOS salto_muerto: Tres bytes que son `jp 0x49E9`, o sea un atajo para
;   pedir un sonido. Ninguna instruccion ni tabla del cartucho apunta a
;   0x40FD, y la de delante acaba en `ret`: es codigo muerto, y por eso se
;   lista como bytes.
;   0x40fd..0x4100  (3 bytes)
salta_a_pide_sonido:		; `jp 0x49E9`. Nadie salta aqui: es codigo muerto.
	defb 0c3h,0e9h,049h	; 40fd

; ======================================================================
; CODIGO 0x4100..0x418f  (143 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ARRANCAR PARTIDA Y ARRANCAR FASE
; ----------------------------------------------------------------------
arranca_la_partida:		; Deja el marcador a cero, borra los 0x900 bytes de objetos de 0xE300 y carga los datos de la fase
	call carga_los_graficos_de_la_fase		;4100   ; Los rotulos del marcador
	call escribe_los_rotulos		;4103
	xor a			;4106
	ld (0e071h),a		;4107   ; 0xE071 a cero: la cuenta de mejoras
	ld hl,00000h		;410a   ; 0xE108, 0xE063 y 0xE127 a cero de dos en dos bytes
	ld (0e108h),hl		;410d
	ld (0e063h),hl		;4110
	ld (0e127h),hl		;4113
	ld hl,0e300h		;4116   ; Los 0x900 bytes de la tabla de objetos, a cero
	ld de,0e301h		;4119
	ld bc,008ffh		;411c
	ld (hl),000h		;411f
	ldir		;4121
	call carga_los_datos_de_la_fase		;4123   ; Y los datos de la fase que toque
	jp arranca_el_desplazamiento		;4126
monta_la_fase_que_toque:		; NO sube la fase: con 0xE061 a cero la pone a uno, y de la novena en adelante la cambia por la que diga la tabla de 0x418F; luego la monta
	ld hl,0e061h		;4129
	ld a,(hl)			;412c   ; Con la fase a cero, se arranca por la primera
	and a			;412d
	jr nz,L_4132		;412e
	ld (hl),001h		;4130
L_4132:
	ld a,(hl)			;4132
	sub 009h		;4133   ; Por debajo de la nueve la fase se monta tal cual
	jr c,arranca_la_fase		;4135
	ld de,0418fh		;4137   ; La tabla de 0x418F, indexada por la fase menos nueve: solo tiene cuatro entradas
	call suma_a_a_de		;413a
	ld a,(de)			;413d
	ld (0e061h),a		;413e
	xor a			;4141   ; Y la cuenta de mejoras y el marcador de la fase, a cero
	ld (0e071h),a		;4142
	ld hl,00000h		;4145
	ld (0e063h),hl		;4148
arranca_la_fase:		; Borra los 0xE00 bytes de 0xE100, apaga los 128 sprites, carga los datos de la fase y espera 0x3C cuadros
	call carga_los_graficos_de_la_fase		;414b
	ld hl,0e100h		;414e   ; Los 0xE00 bytes de 0xE100 en adelante, a cero
	ld de,0e101h		;4151
	ld bc,00dffh		;4154
	ld (hl),000h		;4157
	ldir		;4159
	ld hl,0ec80h		;415b   ; 0xE0 en las 128 Y del buffer de sprites: ninguno se dibuja
	ld de,0ec81h		;415e
	ld (hl),0e0h		;4161
	ld c,07fh		;4163
	ldir		;4165
	call carga_los_datos_de_la_fase		;4167
	call dificultad_de_la_fase		;416a
	ld bc,00010h		;416d   ; Dieciseis bytes de 0x4193 a 0xE200
	ld de,0e200h		;4170
	ld hl,04193h		;4173
	ldir		;4176
	call marca_si_hay_dos_jugadores		;4178
	ld a,03ch		;417b   ; 0x3C cuadros de espera antes de empezar
	ld (0e10fh),a		;417d
	jp arranca_el_desplazamiento		;4180
marca_si_hay_dos_jugadores:		; 0xE130 a uno si 0xE06B no esta a cero
	ld a,(0e06bh)		;4183
	or a			;4186
	jr z,L_418B		;4187
	ld a,001h		;4189
L_418B:
	ld (0e130h),a		;418b
	ret			;418e

; ----------------------------------------------------------------------
; DATOS fases_por_ronda: Solo CUATRO bytes utiles, de 0x418F a 0x4192: 0x03,
;   0x04, 0x05 y 0x08. Los indexa 0x4137 con `ld de,0x418F` + 0x4062 y el
;   indice es (0xE061 menos 9), asi que dicen por que fase se sigue despues de
;   la 9, la 10, la 11 y la 12. NO hay una quinta entrada: el byte de 0x4193
;   ya es el primero de los DIECISEIS que 0x416D copia a 0xE200 (la ficha con
;   la que arranca la nave).
;   0x418f..0x41a3  (20 bytes)
DATA_fases_por_ronda:
	defb 003h,004h,005h,008h	; 418f
	defb 001h,000h,000h,000h	; 4193
	defb 04ah,000h,050h,000h	; 4197
	defb 008h,000h,008h,000h	; 419b
	defb 002h,000h,000h,000h	; 419f

; ======================================================================
; CODIGO 0x41a3..0x4214  (113 bytes)
; ======================================================================


dificultad_de_la_fase:		; 0xE111 sale de la ronda por cuatro mas la fase, topado en 0x0F; pasada la novena, de 0xE066
	ld a,(0e061h)		;41a3
	cp 009h		;41a6   ; De la novena en adelante, la dificultad la manda 0xE066
	jr nc,L_41BC		;41a8
	dec a			;41aa
	ld b,a			;41ab
	ld a,(0e06ah)		;41ac   ; La ronda por cuatro
	add a,a			;41af
	add a,a			;41b0
	add a,b			;41b1
	cp 00fh		;41b2   ; Topada en 0x0F
	jr c,L_41B8		;41b4
	ld a,00fh		;41b6
L_41B8:
	ld (0e111h),a		;41b8
	ret			;41bb
L_41BC:
	ld a,(0e066h)		;41bc
	ld (0e111h),a		;41bf
	ret			;41c2
carga_los_datos_de_la_fase:		; Seis bytes de la tabla de 0x4499 a 0xE101 -donde empieza y donde acaba el guion del mapa-, y de la de 0x4212 el punto de control con el que se compara el marcador
	ld a,(0e061h)		;41c3
	add a,a			;41c6   ; Por seis: seis bytes por fase
	ld c,a			;41c7
	add a,a			;41c8
	add a,c			;41c9
	ld hl,04499h		;41ca
	call suma_a_a_hl		;41cd
	ld de,0e101h		;41d0   ; A 0xE101
	ld bc,00006h		;41d3
	ldir		;41d6
	ld a,(0e061h)		;41d8
	ld hl,04212h		;41db   ; La otra tabla, la de los puntos de control
	call dame_palabra		;41de
	ld hl,(0e063h)		;41e1
	rst 20h			;41e4   ; DCOMPR: si ya habias pasado del punto de control, se arranca ahi; y si no, en 0x20
	jr nc,pon_los_contadores_de_la_fase		;41e5
	ld de,00020h		;41e7
pon_los_contadores_de_la_fase:		; Deja a cero la docena de contadores de la fase, 0xE062 a uno y 0xE129 a 0x40
	ld (0e063h),de		;41ea   ; La distancia con la que arranca la fase
	xor a			;41ee
	ld (0e150h),a		;41ef
	ld (0e151h),a		;41f2
	ld (0e065h),a		;41f5
	ld (0e155h),a		;41f8
	ld (0e113h),a		;41fb
	ld (0e10ah),a		;41fe
	ld (0e044h),a		;4201
	ld (0e114h),a		;4204
	ld (0e126h),a		;4207
	inc a			;420a   ; 0xE062 a uno
	ld (0e062h),a		;420b
	ld a,040h		;420e   ; 0xE129 arranca en 0x40
	ld (0e129h),a		;4210
	ret			;4213

; ----------------------------------------------------------------------
; DATOS puntos_de_control (tramo): ONCE palabras, de 0x4214 a 0x422A: el PUNTO
;   DE CONTROL de cada fase. La lee 0x41DB con `ld hl,0x4212` y 0x47AE, que
;   suma DOS VECES la fase, asi que la fase 1 lee la de 0x4214 y la 11 la de
;   0x4228. Al montar la fase, 0x41E1 compara la distancia ya recorrida con
;   este numero; si la habias pasado, la fase vuelve a arrancar justo ahi, y
;   si no, en 0x20. Son 0xF8, 0x100, 0xF2, 0x100, 0x100, 0x100, 0xF8, 0x100,
;   0x100, 0x100 y 0x100. OJO: LA FASE 12 SE SALE DE LA TABLA. Su lectura cae
;   en 0x422A, que son los dos primeros bytes del `call 0x58BA` de 0x422A, y
;   le da 0xBACD = 47821; como la distancia nunca llega ni de lejos, la fase
;   12 siempre arranca en 0x20.
;   0x4214..0x422a  (22 bytes)  de 0x4212..0x422a (24 bytes)
DATA_puntos_de_control_4214:
	defw 000f8h,00100h	; 4214
	defw 000f2h,00100h	; 4218
	defw 00100h,00100h	; 421c
	defw 000f8h,00100h	; 4220
	defw 00100h,00100h	; 4224
	defw 00100h	; 4228

; ======================================================================
; CODIGO 0x422a..0x42b3  (137 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LOS GRAFICOS DE CADA FASE
; El cartucho no guarda las pantallas dibujadas: guarda bloques comprimidos
; en los bancos 4, 5 y 6, y al empezar una fase los descomprime a la VRAM.
; Con los graficos ya puestos, 0x4348 fabrica ADEMAS los caracteres al
; reves: 0x43F2 le da la vuelta a los bits de cada byte -espejo
; horizontal- y 0x43C6 le da la vuelta al orden de los ocho bytes -espejo
; vertical-. Asi un dibujo y su reflejo ocupan un solo bloque en la ROM.
; ----------------------------------------------------------------------
carga_los_graficos_de_la_fase:		; Mete los bancos 4, 5 y 6, descomprime lo que le toca a la fase y devuelve el reparto de siempre
	call carga_la_fuente_de_la_fase		;422a
	di			;422d   ; Bancos 4, 5 y 6, que son los de graficos
	push hl			;422e   ; Bancos 4, 5 y 6, que son los de graficos
	ld hl,0f0f1h		;422f
	ld a,004h		;4232
	ld (06000h),a		;4234
	ld (hl),a			;4237
	inc a			;4238
	ld (08000h),a		;4239
	inc hl			;423c
	ld (hl),a			;423d
	inc a			;423e
	ld (0a000h),a		;423f
	inc hl			;4242
	ld (hl),a			;4243
	pop hl			;4244
	ei			;4245
	call carga_los_caracteres_de_la_fase		;4246
	ld hl,01800h		;4249   ; El bloque de 0x86BB a la VRAM 0x1800: los patrones de sprite
	ld de,086bbh		;424c
	call descomprime		;424f
	ld a,(0e061h)		;4252   ; La fase por seis: dos grupos de tres bytes en la tabla de 0x42AD
	add a,a			;4255
	ld b,a			;4256
	add a,a			;4257
	add a,b			;4258
	ld hl,042adh		;4259
	call suma_a_a_hl		;425c
	ld b,002h		;425f   ; Dos bloques por fase
descomprime_los_dos_bloques:		; Por cada grupo: el origen en DE y, en C, el caracter donde empieza; la VRAM sale de C por ocho mas 0x1800
	push bc			;4261
	ld e,(hl)			;4262
	inc hl			;4263
	ld d,(hl)			;4264
	inc hl			;4265
	ld c,(hl)			;4266   ; El tercer byte es el caracter donde empieza
	inc hl			;4267
	push hl			;4268
	ld l,c			;4269   ; Por ocho: cada caracter son ocho bytes
	ld h,000h		;426a
	add hl,hl			;426c
	add hl,hl			;426d
	add hl,hl			;426e
	ld bc,01800h		;426f   ; Y desde la VRAM 0x1800
	add hl,bc			;4272
	call descomprime		;4273
	pop hl			;4276
	pop bc			;4277
	djnz descomprime_los_dos_bloques		;4278
	ld a,(0e061h)		;427a
	cp 005h		;427d   ; La fase 5 lleva ademas el bloque de 0x8FCB en la VRAM 0x1D00
	jr nz,L_428A		;427f
	ld hl,01d00h		;4281
	ld de,08fcbh		;4284
	call descomprime		;4287
L_428A:
	ld a,(0f0f4h)		;428a   ; Y con 0xF0F4 puesto, otro mas en 0x1800
	or a			;428d
	jr z,devuelve_el_reparto_de_siempre		;428e
	ld hl,01800h		;4290
	ld de,09963h		;4293
	call descomprime		;4296
devuelve_el_reparto_de_siempre:		; Bancos 1, 2 y 3 en sus tres ranuras, y la copia en RAM al dia
	di			;4299   ; Se devuelve el reparto de siempre: bancos 1, 2 y 3
	push hl			;429a
	ld hl,0f0f1h		;429b
	ld a,001h		;429e
	ld (06000h),a		;42a0   ; Banco 1 en 0x6000...
	ld (hl),a			;42a3
	inc a			;42a4
	ld (08000h),a		;42a5   ; ...banco 2 en 0x8000...
	inc hl			;42a8
	ld (hl),a			;42a9
	inc a			;42aa
	ld (0a000h),a		;42ab   ; ...y banco 3 en 0xA000
	inc hl			;42ae
	ld (hl),a			;42af
	pop hl			;42b0
	ei			;42b1
	ret			;42b2

; ----------------------------------------------------------------------
; DATOS graficos_por_fase: Seis bytes por fase: dos grupos de (origen del
;   bloque comprimido, indice del caracter donde empieza). La base declarada
;   es 0x42AD (0x4259), que cae DENTRO del codigo: la fase 0 no existe y la
;   tabla empieza de verdad en la fase 1. Los origenes apuntan al banco 5.
;   0x42b3..0x42fb  (72 bytes)
DATA_graficos_por_fase:
	defb 04bh,08eh,0bch,08ch,08ah,0cch	; 42b3
	defb 04bh,08eh,0bch,08ch,08ah,0cch	; 42b9
	defb 01eh,08ch,0dch,0cah,08eh,0bch	; 42bf
	defb 0cah,08eh,0bch,08ch,08ah,0cch	; 42c5
	defb 0cah,08eh,0bch,038h,090h,0cch	; 42cb
	defb 0cah,08eh,0bch,08ch,08ah,0cch	; 42d1
	defb 027h,08dh,0dch,04bh,08eh,0bch	; 42d7
	defb 04bh,08eh,0bch,08ch,08ah,0cch	; 42dd
	defb 03eh,08fh,0e0h,0fbh,042h,0ffh	; 42e3
	defb 03eh,08fh,0e0h,0fbh,042h,0ffh	; 42e9
	defb 03eh,08fh,0e0h,0fbh,042h,0ffh	; 42ef
	defb 03eh,08fh,0e0h,0fbh,042h,0ffh	; 42f5

; ----------------------------------------------------------------------
; DATOS bloque_vacio: Un solo 0x00. Es un flujo comprimido que se acaba en el
;   primer byte, y las fases 9 a 12 lo usan como "aqui no hay segundo bloque".
;   0x42fb..0x42fc  (1 bytes)
DATA_bloque_vacio:
	defb 000h	; 42fb

; ======================================================================
; CODIGO 0x42fc..0x449f  (419 bytes)
; ======================================================================


carga_los_caracteres_de_la_fase:		; Las fichas de 0x932D y las que le tocan a la fase, y ademas las dos tandas de espejos
	ld ix,0932dh		;42fc   ; Las fichas de 0x932D: las que llevan todas las fases
	call carga_fichas		;4300
	ld a,(0e061h)		;4303
	ld hl,092e3h		;4306   ; Y la tabla de 0x92E3, indexada por la fase
	call dame_palabra		;4309
	push de			;430c
	pop ix		;430d
	call carga_fichas		;430f
	xor a			;4312
	ld (0e100h),a		;4313   ; 0xE100 a cero: la tanda que se voltea por bits
	ld hl,092fbh		;4316
	call recorre_las_fichas		;4319
	ld hl,0e100h		;431c
	inc (hl)			;431f   ; Y a uno: la que se voltea por bytes
	ld hl,09313h		;4320
	call recorre_las_fichas		;4323
	ld a,(0f0f4h)		;4326   ; Lo de 0xF0F4 solo se carga si esta puesto
	or a			;4329
	ret z			;432a
	ld ix,0938eh		;432b
	call carga_fichas		;432f
	ld a,(0e061h)		;4332
	cp 009h		;4335   ; De la fase novena en adelante, un juego mas
	ld ix,0939bh		;4337
	call nc,carga_fichas		;433b
	ret			;433e
recorre_las_fichas:		; Saca de la tabla de HL la lista que le toca a la fase y la recorre
	ld a,(0e061h)		;433f
	call dame_palabra		;4342
	push de			;4345
	pop ix		;4346
monta_un_espejo:		; Por cada ficha de cuatro bytes: la desdobla, le da la vuelta y la sube a los tercios que digan sus bits
	ld a,(ix+000h)		;4348   ; El primer byte a cero acaba la lista
	and a			;434b
	ret z			;434c
	ld l,(ix+003h)		;434d   ; El cuarto byte es el caracter; por ocho, los bytes que ocupa
	ld h,000h		;4350
	add hl,hl			;4352
	add hl,hl			;4353
	add hl,hl			;4354
	ld (0e101h),hl		;4355
	call baja_el_caracter_a_la_ram		;4358
	ld a,(0e100h)		;435b   ; 0xE100 dice de que espejo se trata
	and a			;435e
	push af			;435f
	call z,voltea_los_bits		;4360   ; A cero, el espejo por bits: horizontal
	pop af			;4363
	call nz,voltea_los_bytes		;4364   ; Y a uno, el de bytes: vertical
	call sube_el_espejo		;4367
	ld de,00004h		;436a   ; Cuatro bytes por ficha
	add ix,de		;436d
	jr monta_un_espejo		;436f
carga_fichas:		; Recorre fichas de seis bytes y le pasa a 0x49B9 los patrones y los colores de cada una.
	ld a,(ix+000h)		;4371
	and a			;4374
	ret z			;4375
	rra			;4376   ; Bit 0: el tercer tercio, en la VRAM 0x1000
	ld de,01000h		;4377
	call c,descomprime_patrones_y_colores		;437a
	bit 1,(ix+000h)		;437d   ; Bit 1: el de en medio, en la 0x0800
	ld de,00800h		;4381
	call nz,descomprime_patrones_y_colores		;4384
	bit 2,(ix+000h)		;4387   ; Y bit 2: el primero, en la 0x0000
	ld de,00000h		;438b
	call nz,descomprime_patrones_y_colores		;438e
	ld de,00006h		;4391   ; Seis bytes por ficha
	add ix,de		;4394
	jr carga_fichas		;4396
descomprime_patrones_y_colores:		; El caracter por ocho mas el tercio: los patrones van 0x2000 mas arriba y los colores a pelo
	ld l,(ix+003h)		;4398   ; El caracter por ocho, mas el tercio que toque
	ld h,000h		;439b
	add hl,hl			;439d
	add hl,hl			;439e
	add hl,hl			;439f
	add hl,de			;43a0
	push hl			;43a1
	ld de,02000h		;43a2   ; Los patrones viven 0x2000 por encima de los colores
	add hl,de			;43a5
	ld e,(ix+001h)		;43a6   ; El puntero de los patrones, en la ficha
	ld d,(ix+002h)		;43a9
	push ix		;43ac
	call descomprime		;43ae
	pop ix		;43b1
	pop hl			;43b3
	ld de,00000h		;43b4
	add hl,de			;43b7
	ld e,(ix+004h)		;43b8   ; Y el de los colores, tres bytes mas alla
	ld d,(ix+005h)		;43bb
	push ix		;43be
	call descomprime		;43c0
	pop ix		;43c3
	ret			;43c5
voltea_los_bytes:		; Espejo VERTICAL: cambia el orden de los ocho bytes del caracter, en los dos buffers de 0xE300 y 0xE700
	ld hl,0e300h		;43c6   ; El buffer de patrones...
	ld de,0e307h		;43c9
	call L_43D5		;43cc
	ld hl,0e700h		;43cf   ; ...y el de colores
	ld de,0e707h		;43d2
L_43D5:
	exx			;43d5
	ld b,(ix+003h)		;43d6   ; Tantos caracteres como diga la ficha
L_43D9:
	exx			;43d9
	ld b,004h		;43da   ; Cuatro cambios: los ocho bytes al reves
cambia_ocho_bytes:		; Los ocho bytes del caracter, cambiados de dos en dos hacia dentro: eso es el espejo vertical
	ld c,(hl)			;43dc   ; Uno sube y el otro baja
	ld a,(de)			;43dd
	ld (hl),a			;43de
	ld a,c			;43df
	ld (de),a			;43e0
	inc hl			;43e1
	dec de			;43e2
	djnz cambia_ocho_bytes		;43e3
	inc hl			;43e5   ; Cuatro mas: el caracter siguiente
	inc hl			;43e6
	inc hl			;43e7
	inc hl			;43e8
	ld a,00ch		;43e9   ; 0x0C: el caracter siguiente, contando hacia atras
	call suma_a_a_de		;43eb
	exx			;43ee
	djnz L_43D9		;43ef
	ret			;43f1
voltea_los_bits:		; Espejo HORIZONTAL: le da la vuelta a los ocho bits de cada byte con `rr (hl)` y `adc a,a`
	ld hl,0e300h		;43f2
	ld de,(0e101h)		;43f5
L_43F9:
	ld b,008h		;43f9   ; Ocho bits por byte
L_43FB:
	rr (hl)		;43fb   ; Sale por abajo y entra por arriba: el byte al reves
	adc a,a			;43fd
	djnz L_43FB		;43fe
	ld (hl),a			;4400
	inc hl			;4401
	dec de			;4402   ; Tantos bytes como diga 0xE101
	ld a,d			;4403
	or e			;4404
	jr nz,L_43F9		;4405
	ret			;4407
sube_el_espejo:		; Los bits 3, 4 y 5 del segundo byte dicen a que tercios sube el caracter volteado
	bit 3,(ix+002h)		;4408   ; Bit 3: el tercer tercio
	ld de,01000h		;440c
	call nz,sube_el_espejo_a_la_vram		;440f
	bit 4,(ix+002h)		;4412   ; Bit 4: el de en medio
	ld de,00800h		;4416
	call nz,sube_el_espejo_a_la_vram		;4419
	bit 5,(ix+002h)		;441c   ; Y bit 5: el primero
	ld de,00000h		;4420
	ret z			;4423
sube_el_espejo_a_la_vram:		; El caracter volteado vuelve a la VRAM: los patrones desde 0xE300 y los colores desde 0xE700
	push ix		;4424
	ld l,(ix+001h)		;4426   ; El segundo byte de la ficha es el caracter de destino
	ld h,000h		;4429
	add hl,hl			;442b   ; Por ocho, mas el tercio que traiga DE
	add hl,hl			;442c
	add hl,hl			;442d
	add hl,de			;442e
	push hl			;442f
	ld de,02000h		;4430   ; Los patrones, 0x2000 por encima
	add hl,de			;4433
	ld de,0e300h		;4434
	ld bc,(0e101h)		;4437   ; Y tantos bytes como diga 0xE101
	call vuelca_a_vram		;443b
	pop hl			;443e
	ld de,00000h		;443f   ; Los colores van a pelo, sin el 0x2000
	add hl,de			;4442
	ld de,0e700h		;4443
	ld bc,(0e101h)		;4446
	call vuelca_a_vram		;444a
	pop ix		;444d
	ret			;444f
baja_el_caracter_a_la_ram:		; Se trae de la VRAM a 0xE300 y 0xE700 el caracter que hay que voltear: para hacer el espejo hay que leer lo que ya se subio
	ld bc,(0e101h)		;4450
	ld l,(ix+000h)		;4454   ; El primer byte de la ficha: el caracter de origen
	ld h,000h		;4457
	add hl,hl			;4459
	add hl,hl			;445a
	add hl,hl			;445b
	push hl			;445c
	ld de,02000h		;445d
	bit 2,(ix+002h)		;4460   ; Bit 2: el primer tercio, en 0x2000
	jr nz,L_4470		;4464
	ld d,028h		;4466   ; Bit 1: el de en medio, en 0x2800
	bit 1,(ix+002h)		;4468
	jr nz,L_4470		;446c
	ld d,030h		;446e   ; Y si no, el tercero, en 0x3000
L_4470:
	add hl,de			;4470
	ld de,0e300h		;4471
	push ix		;4474
	call 00059h		;4476   ; BIOS LDIRMV - Block transfers to memory from VRAM | LDIRMV: de la VRAM a la RAM, al reves que LDIRVM
	pop ix		;4479
	pop hl			;447b
	ld de,00000h		;447c
	bit 2,(ix+002h)		;447f   ; Los mismos tres tercios para los colores: 0x0000, 0x0800 y 0x1000
	jr nz,L_448F		;4483
	ld d,008h		;4485
	bit 1,(ix+002h)		;4487
	jr nz,L_448F		;448b
	ld d,010h		;448d
L_448F:
	add hl,de			;448f
	ld de,0e700h		;4490
	ld bc,(0e101h)		;4493
	push ix		;4497
	call 00059h		;4499   ; BIOS LDIRMV - Block transfers to memory from VRAM
	pop ix		;449c
	ret			;449e

; ----------------------------------------------------------------------
; DATOS posiciones_de_fase: Filas de seis bytes que 0x41CA copia a 0xE101 con
;   la base 0x4499, otra vez seis bytes por delante de donde empieza el rango.
;   0x449f..0x44e7  (72 bytes)
DATA_posiciones_de_fase:
	defb 080h,000h,0a0h,001h,09fh,001h	; 449f
	defb 080h,000h,0a0h,001h,0cfh,001h	; 44a5
	defb 0ffh,0ffh,0ffh,0ffh,09fh,001h	; 44ab
	defb 080h,000h,0a0h,001h,09fh,001h	; 44b1
	defb 080h,000h,0e0h,001h,0dfh,001h	; 44b7
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 44bd
	defb 080h,000h,080h,001h,07fh,001h	; 44c3
	defb 040h,000h,0c0h,001h,081h,001h	; 44c9
	defb 020h,000h,000h,001h,01fh,001h	; 44cf
	defb 020h,000h,000h,001h,01fh,001h	; 44d5
	defb 020h,000h,0c0h,000h,0dfh,000h	; 44db
	defb 020h,000h,080h,001h,09fh,001h	; 44e1

; ======================================================================
; CODIGO 0x44e7..0x4786  (671 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LA PAUSA
; ----------------------------------------------------------------------
mira_la_tecla_de_pausa:		; Con la partida en marcha, mira el bit 5 de la fila 6 del teclado y, al pulsarlo, cambia entre pausa y juego
	ld a,(0e002h)		;44e7   ; Bit 6 de 0xE002: solo con la partida en marcha
	and 040h		;44ea
	jr z,un_cuadro_de_juego		;44ec
	ld a,(0e1d0h)		;44ee   ; Y con 0xE1D0 a cero
	and a			;44f1
	jr nz,un_cuadro_de_juego		;44f2
	ld a,006h		;44f4
	call 00141h		;44f6   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix | SNSMAT de la fila 6; el bit 5 es la tecla GRAPH
	cpl			;44f9   ; Un cpl: en el teclado lo pulsado es un cero
	and 020h		;44fa
	ld hl,0e10ch		;44fc   ; 0xE10C guarda lo de antes, para cazar la pulsacion nueva
	ld c,(hl)			;44ff
	ld (hl),a			;4500
	xor c			;4501   ; Lo que ha cambiado y esta puesto: acaba de bajar
	and (hl)			;4502
	dec hl			;4503
	jr z,L_4518		;4504
	inc (hl)			;4506   ; 0xE10B cuenta las pulsaciones: par juego, impar pausa
	bit 0,(hl)		;4507
	ld de,00000h		;4509   ; En juego, 0xE047 a cero
	jr z,L_4514		;450c
	ld de,00101h		;450e   ; Y en pausa, 0x0101
	call borra_el_estado_del_marcador		;4511
L_4514:
	ld (0e047h),de		;4514
L_4518:
	bit 0,(hl)		;4518   ; Solo con la partida en pausa se leen las claves del teclado
	jr z,un_cuadro_de_juego		;451a
	call mira_lo_que_se_teclea		;451c
	ld a,(0e200h)		;451f   ; 0xE200 en negativo: la pausa se despacha por otro lado
	and a			;4522
	jp m,sube_los_sprites_rotando		;4523
	call 0998ch		;4526   ; Tres rutinas de los bancos 2 y 3, con la partida parada
	call 09c90h		;4529
	call 0a17fh		;452c
	jp sube_los_sprites_rotando		;452f

; ----------------------------------------------------------------------
; UN CUADRO DE JUEGO
; Esta es la lista de la compra del juego: treinta y tantas llamadas
; seguidas, casi todas a los bancos 1, 2 y 3, y en ese orden se hace todo
; lo que pasa en un cuadro. No hay bucle ni tabla: es una tira de `call`.
; En medio se meten a proposito los bancos 11 y 12 -las piezas y los
; guiones de fase- para una sola llamada, y luego se devuelven el 2 y el 3.
; ----------------------------------------------------------------------
un_cuadro_de_juego:		; La tira de llamadas que hace un cuadro entero: el desplazamiento, los enemigos, los disparos, los choques y el marcador
	ld a,(0e009h)		;4532   ; 0xE009 se copia a 0xE10D: el mando, tal como quedo
	ld (0e10dh),a		;4535
	call sube_los_sprites_rotando		;4538
	call 06ccdh		;453b
	ld a,(0e1d0h)		;453e   ; Con 0xE1D0 puesto hay explosion en marcha
	and a			;4541
	call nz,despacha_el_final_de_la_nave		;4542
	ld a,(0e1d1h)		;4545   ; Y con 0xE1D1 puesto, el cuadro se corta aqui
	and a			;4548
	ret nz			;4549
	call 0b042h		;454a
	xor a			;454d
	ld (0e112h),a		;454e   ; 0xE112 a cero
	di			;4551   ; Bancos 11 y 12: las piezas y los guiones de fase
	ld a,00bh		;4552
	ld (08000h),a		;4554
	ld (0f0f2h),a		;4557   ; La copia en RAM del mapper se actualiza a la vez
	ei			;455a
	di			;455b
	ld a,00ch		;455c
	ld (0a000h),a		;455e
	ld (0f0f3h),a		;4561
	ei			;4564
	call corre_el_mapa_una_columna		;4565   ; Y con ellos puestos, se monta el trozo de pantalla que toca
	di			;4568   ; Devueltos el 2 y el 3, que son los de siempre
	ld a,002h		;4569
	ld (08000h),a		;456b
	ld (0f0f2h),a		;456e
	ei			;4571
	di			;4572
	ld a,003h		;4573
	ld (0a000h),a		;4575
	ld (0f0f3h),a		;4578
	ei			;457b
	call 0890bh		;457c
	call 08935h		;457f
	call 09955h		;4582
	call 0a068h		;4585
	call 09c41h		;4588
	call 09e14h		;458b
	call 09cc5h		;458e
	call 0a17fh		;4591
	call corre_los_doce_objetos		;4594
	call 0a310h		;4597
	call 0aba3h		;459a
	call 065dch		;459d
	call suelta_lo_que_toque		;45a0
	call 090c1h		;45a3
	call corre_los_objetos_del_fondo		;45a6
	call 0b145h		;45a9
	call 062c1h		;45ac
	call 0616ah		;45af
	call 07c34h		;45b2
	call 070d6h		;45b5
	call 08ec4h		;45b8
	call 0760eh		;45bb
	call 09f81h		;45be
	call 068fbh		;45c1
	call 06936h		;45c4
	call 08fb0h		;45c7
	call 07c5ah		;45ca
	call 061afh		;45cd
	call 08ffeh		;45d0
	call 0b431h		;45d3
	call 071e8h		;45d6
	call 09f85h		;45d9
	call 06893h		;45dc
	call corre_los_sprites		;45df
	call parpadea_dos_caracteres		;45e2
	call sube_la_pantalla		;45e5
	call 06983h		;45e8
	ld a,(0e003h)		;45eb   ; Uno de cada ocho cuadros
	and 007h		;45ee
	dec a			;45f0
	ret nz			;45f1
	jp pinta_los_marcadores		;45f2   ; ...toca refrescar el marcador
arranca_el_desplazamiento:		; Retrasa 0x20 el marcador de distancia y deja el puntero de pantalla en 0xED00, con 0x20 pasos por dar
	xor a			;45f5
	ld (0ec04h),a		;45f6   ; 0xEC04 a cero
	ld hl,(0e063h)		;45f9   ; 0x20 menos en la distancia recorrida
	ld de,00020h		;45fc
	sbc hl,de		;45ff
	ld (0e063h),hl		;4601
	ld hl,0ed00h		;4604   ; 0xED00: por donde empieza a leer la pantalla
	ld (0ec00h),hl		;4607
	ld b,020h		;460a   ; Treinta y dos pasos

; ----------------------------------------------------------------------
; EL DESPLAZAMIENTO
; El mapa de la fase no se lee de la VRAM: vive en la RAM, en 0xED00, y son
; veintidos filas de treinta y dos casillas. Cada paso de scroll, 0x469D lo
; CORRE UNA COLUMNA A LA IZQUIERDA con veintidos `ldir` de 0x1F bytes, y
; 0x46AE mete por la derecha la columna nueva, que sale del guion de la
; fase y de las piezas de 4x4 caracteres del banco 11.
; ----------------------------------------------------------------------
da_los_pasos_del_scroll:		; B pasos de desplazamiento; en cada uno mete los bancos 11 y 12 para leer el guion, y luego cuatro rutinas mas
	push bc			;460c
	di			;460d
	ld a,00bh		;460e   ; Bancos 11 y 12: las piezas y los guiones
	ld (08000h),a		;4610
	ld (0f0f2h),a		;4613
	ei			;4616
	di			;4617
	ld a,00ch		;4618
	ld (0a000h),a		;461a
	ld (0f0f3h),a		;461d
	ei			;4620
	call lee_la_columna_nueva		;4621   ; Con ellos puestos se lee la columna nueva
	di			;4624
	ld a,002h		;4625   ; Y se devuelven el 2 y el 3
	ld (08000h),a		;4627
	ld (0f0f2h),a		;462a
	ei			;462d
	di			;462e
	ld a,003h		;462f
	ld (0a000h),a		;4631
	ld (0f0f3h),a		;4634
	ei			;4637
	call 090b5h		;4638
	call 062adh		;463b
	call 0aedfh		;463e
	call 0b845h		;4641
	ld hl,(0ec00h)		;4644   ; 0xEC00 avanza una casilla
	inc hl			;4647
	ld (0ec00h),hl		;4648
	ld hl,0ec04h		;464b   ; 0xEC04, ocho puntos por paso
	ld a,(hl)			;464e
	add a,008h		;464f
	ld (hl),a			;4651
	ld hl,(0e063h)		;4652   ; Y la distancia recorrida, una unidad
	inc hl			;4655
	ld (0e063h),hl		;4656
	pop bc			;4659
	djnz da_los_pasos_del_scroll		;465a
	ld hl,(0e063h)		;465c   ; Al salir se devuelve el ultimo paso: el bucle se pasa por uno
	dec hl			;465f
	ld (0e063h),hl		;4660
	ret			;4663
marca_que_no_toca:		; 0xE107 a uno: en este paso no entra columna nueva
	ld a,001h		;4664
	ld (0e107h),a		;4666
	ret			;4669
corre_el_mapa_una_columna:		; Si toca desplazarse, sube la distancia y corre las veintidos filas de 0xED00 una casilla a la izquierda
	xor a			;466a
	ld (0e100h),a		;466b
	ld (0e107h),a		;466e
	ld de,(0e105h)		;4671   ; 0xE105 es hasta donde llega el desplazamiento de la fase
	ld hl,(0e063h)		;4675
	rst 20h			;4678   ; DCOMPR: compara la distancia con el limite
	jr nc,marca_que_no_toca		;4679
	ld a,(0e1c0h)		;467b   ; 0xE1C0 manda la velocidad: a uno, quieto
	dec a			;467e
	ret z			;467f
	dec a			;4680   ; A dos, se corre en todos los pasos
	jr z,L_468C		;4681
	ld de,0e062h		;4683   ; Y si no, un paso si y otro no, con el bit que va rotando en 0xE062
	ld a,(de)			;4686
	rlca			;4687
	ld (de),a			;4688
	and 001h		;4689
	ret z			;468b
L_468C:
	inc hl			;468c   ; La distancia sube
	ld (0e063h),hl		;468d
	ld a,001h		;4690   ; 0xE100 a uno: en este paso si hay columna nueva
	ld (0e100h),a		;4692
	ld hl,0ed01h		;4695   ; De 0xED01 a 0xED00: todo el mapa, una casilla a la izquierda
	ld de,0ed00h		;4698
	ld b,016h		;469b   ; Veintidos filas
L_469D:
	push bc			;469d
	ld bc,0001fh		;469e   ; Treinta y una casillas por fila
	ldir		;46a1
	pop bc			;46a3
	inc hl			;46a4   ; Y la casilla que sobra al saltar de fila
	inc de			;46a5
	djnz L_469D		;46a6
	ld hl,0ed1fh		;46a8   ; 0xEC00 apunta a la columna de la derecha, la que hay que rellenar
	ld (0ec00h),hl		;46ab
lee_la_columna_nueva:		; Con la distancia dentro del tramo, saca del guion de la fase la pieza que toca y deja su direccion en 0xEC02
	ld hl,(0e063h)		;46ae   ; La distancia recorrida...
	ld de,(0e103h)		;46b1   ; ...contra el final del tramo
	rst 20h			;46b5
	ccf			;46b6
	jr c,pinta_la_columna_de_estrellas		;46b7
	ld de,(0e101h)		;46b9   ; Y contra donde empieza
	and a			;46bd
	sbc hl,de		;46be
	jr c,pinta_la_columna_de_estrellas		;46c0
	push hl			;46c2
	ld hl,097deh		;46c3   ; La tabla de guiones de 0x97DE, indexada por la fase
	ld a,(0e061h)		;46c6
	call dame_palabra		;46c9
	pop hl			;46cc
	ld a,l			;46cd
	srl h		;46ce   ; La distancia entre dos: cada pieza son cuatro casillas de ancho
	rra			;46d0
	and 0feh		;46d1
	ld l,a			;46d3
	ld c,l			;46d4
	ld b,h			;46d5
	add hl,hl			;46d6   ; Por tres y sumada: por seis, que es lo que ocupa un renglon del guion
	add hl,bc			;46d7
	add hl,de			;46d8
	ld (0ec02h),hl		;46d9   ; 0xEC02 se queda con donde esta la pieza
	ld hl,(0ec00h)		;46dc
	ld b,006h		;46df
mete_la_columna_nueva:		; Copia en la columna de la derecha del mapa las cuatro casillas que le tocan a la pieza, saltando de fila en fila
	push bc			;46e1
	push hl			;46e2
	ld hl,(0ec02h)		;46e3   ; El guion va soltando numeros de pieza
	ld a,(hl)			;46e6
	inc hl			;46e7
	ld (0ec02h),hl		;46e8
	ld l,a			;46eb
	ld h,000h		;46ec
	add hl,hl			;46ee   ; Por dieciseis: cada pieza son cuatro por cuatro caracteres
	add hl,hl			;46ef
	add hl,hl			;46f0
	add hl,hl			;46f1
	ld de,08ff0h		;46f2   ; Las fases 5, 9, 10 y 12 usan el otro juego de piezas, el de 0x8FF0
	ld a,(0e061h)		;46f5
	cp 005h		;46f8
	jr z,L_470B		;46fa
	cp 009h		;46fc
	jr z,L_470B		;46fe
	cp 00ah		;4700
	jr z,L_470B		;4702
	cp 00ch		;4704
	jr z,L_470B		;4706
	ld de,08000h		;4708
L_470B:
	add hl,de			;470b
	ex de,hl			;470c
	ld a,(0e063h)		;470d   ; Los dos bits bajos de la distancia: cual de las cuatro columnas de la pieza toca
	and 003h		;4710
	call suma_a_a_de		;4712
	pop hl			;4715
	dec b			;4716
	ld bc,00020h		;4717   ; 0x20: de una fila del mapa a la de abajo
	jr z,media_pieza		;471a
	ld a,(de)			;471c
	ld (hl),a			;471d
	add hl,bc			;471e
	inc de			;471f   ; Y cuatro bytes: la misma columna, una fila mas abajo de la pieza
	inc de			;4720
	inc de			;4721
	inc de			;4722
	ld a,(de)			;4723
	ld (hl),a			;4724
	add hl,bc			;4725
	inc de			;4726
	inc de			;4727
	inc de			;4728
	inc de			;4729
media_pieza:		; Las otras dos casillas de la pieza, cuando la columna que entra es la segunda mitad
	ld a,(de)			;472a   ; El tercer byte de la pieza
	ld (hl),a			;472b
	add hl,bc			;472c   ; Cuatro bytes: la fila de abajo de la pieza
	inc de			;472d
	inc de			;472e
	inc de			;472f
	inc de			;4730
	ld a,(de)			;4731
	ld (hl),a			;4732
	add hl,bc			;4733   ; Y 0x20: la fila de abajo del mapa
	pop bc			;4734
	djnz mete_la_columna_nueva		;4735
	ret			;4737

; ----------------------------------------------------------------------
; LAS ESTRELLAS SALEN DEL REGISTRO R
; Cuando la fase no tiene guion que leer, la columna que entra es cielo: un
; solo caracter encendido en la fila que diga la tabla de 0x478E, y el
; resto a cero. Cual de los dos dibujos de estrella se pone lo decide
; `ld a,r`, el registro de refresco del Z80, que va contando solo con cada
; instruccion. Es lo mas parecido a un azar que hay en el cartucho, y solo
; se usa para que las estrellas no parpadeen todas igual.
; ----------------------------------------------------------------------
pinta_la_columna_de_estrellas:		; Rellena de cero la columna que entra, menos una casilla: la estrella, en la fila que diga la tabla de 0x478E
	ld a,(0e063h)		;4738   ; Los cinco bits bajos de la distancia indexan la tabla
	and 01fh		;473b
	ld hl,0478eh		;473d
	call suma_a_a_hl		;4740
	ld c,(hl)			;4743   ; C dice en que fila cae la estrella
	ld b,016h		;4744   ; Veintidos filas
	ld de,00020h		;4746
	ld hl,(0ec00h)		;4749
L_474C:
	xor a			;474c
	dec c			;474d
	jr nz,L_4756		;474e
	ld a,r		;4750   ; El registro R del Z80: lo unico que hace de azar aqui
	and 001h		;4752
	add a,0f6h		;4754   ; 0xF6 o 0xF7: los dos dibujos de estrella
L_4756:
	ld (hl),a			;4756
	add hl,de			;4757
	djnz L_474C		;4758
	ret			;475a
parpadea_dos_caracteres:		; Cada dos cuadros apaga o enciende los patrones de 0x27B0 y 0x27B8, en los tres tercios
	ld a,(0e003h)		;475b   ; Dos bits del contador de cuadros: cuatro pasos
	and 006h		;475e
	ld hl,04786h		;4760   ; La tabla de mascaras de 0x4786
	ld e,a			;4763
	ld d,000h		;4764
	add hl,de			;4766
	ld c,(hl)			;4767
	inc hl			;4768
	ld b,(hl)			;4769
	ld hl,027b0h		;476a   ; El caracter de la VRAM 0x27B0...
	call L_4774		;476d
	ld c,b			;4770
	ld hl,027b8h		;4771   ; ...y el de la 0x27B8
L_4774:
	ld a,(0e062h)		;4774   ; 0xE062, el bit que va rotando
	and c			;4777
	call 0004dh		;4778   ; BIOS WRTVRM - Writes data in VRAM
	ld de,00800h		;477b   ; Los tres tercios, de 0x800 en 0x800
	add hl,de			;477e
	call 0004dh		;477f   ; BIOS WRTVRM - Writes data in VRAM
	add hl,de			;4782
	jp 0004dh		;4783   ; BIOS WRTVRM - Writes data in VRAM

; ----------------------------------------------------------------------
; DATOS parpadeo: Cuatro palabras que 0x4760 indexa con (0xE003 AND 6).
;   0x4786..0x478e  (8 bytes)
DATA_parpadeo:
	defw 000ffh,0ffffh	; 4786
	defw 0ff00h,0ffffh	; 478a

; ----------------------------------------------------------------------
; DATOS fila_de_la_estrella: Treinta y dos bytes que 0x473D indexa con (0xE063
;   AND 0x1F): en cual de las veintidos filas cae la estrella de la columna
;   que entra. Los valores van del 1 al 0x14, asi que siempre cae dentro.
;   0x478e..0x47ae  (32 bytes)
DATA_fila_de_la_estrella:
	defb 002h,00fh,005h,013h,00ah,001h,00dh,006h,011h,008h,00bh,002h,010h,007h,00dh,005h,012h,00ch,002h,012h,009h,00eh,014h,011h,002h,005h,00dh,00ah,013h,006h,00fh,009h	; 478e  ................................

; ======================================================================
; CODIGO 0x47ae..0x4956  (424 bytes)
; ======================================================================


dame_palabra:		; DE = la palabra que hay en HL + 2*A. La llaman 36 sitios.
	add a,a			;47ae   ; Por dos: la tabla es de palabras
	ld e,a			;47af
	ld d,000h		;47b0
	add hl,de			;47b2
	ld e,(hl)			;47b3
	inc hl			;47b4
	ld d,(hl)			;47b5
	ret			;47b6
corre_los_sprites:		; Cuatro pasadas: dos rutinas de los bancos 1 y 3, el segundo grupo de objetos y el motor de sprites
	call 06199h		;47b7
	call 0a27fh		;47ba
	call monta_el_segundo_grupo		;47bd
	jp monta_los_sprites		;47c0
sube_los_sprites:		; Saca los 128 bytes de 0xEC80 por el puerto de datos del VDP con `outi`: 32 sprites de cuatro bytes, de una tacada.
	ld hl,0ec80h		;47c3
	ld b,080h		;47c6
L_47C8:
	outi		;47c8   ; `outi` con B=0x80: los 128 bytes de la tabla de atributos sin pasar por la BIOS.
	jp nz,L_47C8		;47ca
	ret			;47cd

; ----------------------------------------------------------------------
; LA PRIORIDAD DE SPRITES, QUE VA ROTANDO
; El MSX solo dibuja cuatro sprites por linea, y los que se caen son
; siempre los ultimos de la tabla. Para que no sea siempre el mismo el que
; desaparece, esta rutina no sube el buffer de un tiron: lo sube en
; TREINTA Y DOS trozos de cuatro bytes, empezando cada cuadro por un sitio
; distinto -0xE17F sube 0x1C y da la vuelta en 0x7C- y avanzando de 0x0C en
; 0x0C. Asi cada objeto cae en una casilla distinta de la tabla de
; atributos en cada cuadro, y el parpadeo se reparte entre todos.
; ----------------------------------------------------------------------
sube_los_sprites_rotando:		; Sube el buffer a la tabla de atributos empezando cada cuadro por otro sitio: asi el parpadeo se reparte
	ld hl,03b00h		;47ce   ; La tabla de atributos de sprite, en la VRAM 0x3B00
	call pon_escritura_vram		;47d1
	exx			;47d4
	ld a,(0e200h)		;47d5   ; Con 0xE200 en 0xFF se sube tal cual, sin rotar
	inc a			;47d8
	jr z,sube_los_sprites		;47d9
	ld hl,0e17fh		;47db
	ld a,(hl)			;47de
	add a,01ch		;47df   ; 0x1C mas cada cuadro, dando la vuelta en 0x7C
	and 07ch		;47e1
	ld (hl),a			;47e3
	ld e,a			;47e4
	ld d,020h		;47e5   ; Treinta y dos fichas de cuatro bytes
L_47E7:
	ld a,e			;47e7
	ld hl,0ec80h		;47e8
	add a,l			;47eb
	ld l,a			;47ec
	ld b,004h		;47ed
L_47EF:
	outi		;47ef   ; Los cuatro bytes de una ficha, por el puerto de datos
	jp nz,L_47EF		;47f1
	ld a,e			;47f4
	add a,00ch		;47f5   ; Y a la ficha 0x0C mas alla, dando la vuelta
	and 07ch		;47f7
	ld e,a			;47f9
	dec d			;47fa
	jr nz,L_47E7		;47fb
	ret			;47fd
sube_la_pantalla:		; Los 704 bytes del mapa de 0xED00 a la tabla de nombres, con `outi` y sin pasar por la BIOS
	ld hl,03800h		;47fe   ; La tabla de nombres, en la VRAM 0x3800
	call pon_escritura_vram		;4801
	exx			;4804
	ld hl,0ed00h		;4805
	ld b,000h		;4808   ; B a cero: 256 bytes de una tacada
L_480A:
	outi		;480a
	jp nz,L_480A		;480c
L_480F:
	outi		;480f
	jp nz,L_480F		;4811
	ld b,0c0h		;4814   ; Y los ultimos 192: veintidos filas de treinta y dos
L_4816:
	outi		;4816
	jp nz,L_4816		;4818
	ret			;481b
monta_el_segundo_grupo:		; Los otros diez objetos, los de 0xE500, al buffer de 0xECD8
	ld ix,0e500h		;481c   ; 0xE500: el segundo grupo de objetos
	ld de,0ecd8h		;4820
	ld b,00ah		;4823   ; Diez objetos
	jr recorre_los_objetos		;4825

; ----------------------------------------------------------------------
; EL MOTOR DE SPRITES: DE LOS OBJETOS DE 0xE300 A LA TABLA DE ATRIBUTOS
; ----------------------------------------------------------------------
monta_los_sprites:		; Con los bancos 4/5/6 puestos, recorre doce objetos de 0xE300 (32 bytes cada uno) y les arma el atributo de sprite en 0xECA8.
	di			;4827
	push hl			;4828
	ld hl,0f0f1h		;4829
	ld a,004h		;482c   ; Bancos 4/5/6: el motor de sprites necesita leer las formas del banco 5.
	ld (06000h),a		;482e
	ld (hl),a			;4831
	inc a			;4832
	ld (08000h),a		;4833
	inc hl			;4836
	ld (hl),a			;4837
	inc a			;4838
	ld (0a000h),a		;4839
	inc hl			;483c
	ld (hl),a			;483d
	pop hl			;483e
	ei			;483f
	ld ix,0e300h		;4840   ; 0xE300 es la tabla de objetos, y 0xECA8 el buffer de atributos
	ld de,0eca8h		;4844
	ld b,00ch		;4847
recorre_los_objetos:		; Por cada ranura viva, pone su ficha de atributo; y si esta escondida, la saca de la pantalla
	push bc			;4849
	ld a,(ix+000h)		;484a   ; Con el primer byte a cero, la ranura esta vacia
	and a			;484d
	jr z,ranura_vacia		;484e
	cp 019h		;4850   ; Y el 0x19 tambien la da por vacia
	jr z,ranura_vacia		;4852
	ld a,(ix+00bh)		;4854   ; El byte 11 dice si el objeto esta escondido
	and a			;4857
	push af			;4858
	call z,pon_atributo		;4859
	pop af			;485c
	call nz,esconde_el_sprite		;485d
objeto_siguiente:		; Pasa al objeto de al lado y, al acabar los doce, devuelve el reparto de siempre
	exx			;4860
	ld de,00020h		;4861   ; Treinta y dos bytes por objeto
	add ix,de		;4864
	exx			;4866
	pop bc			;4867
	djnz recorre_los_objetos		;4868   ; Los doce
	di			;486a   ; Bancos 1, 2 y 3 otra vez
	push hl			;486b   ; El reparto de siempre: bancos 1, 2 y 3
	ld hl,0f0f1h		;486c
	ld a,001h		;486f
	ld (06000h),a		;4871
	ld (hl),a			;4874
	inc a			;4875
	ld (08000h),a		;4876
	inc hl			;4879
	ld (hl),a			;487a
	inc a			;487b
	ld (0a000h),a		;487c
	inc hl			;487f
	ld (hl),a			;4880
	pop hl			;4881
	ei			;4882
	ret			;4883
ranura_vacia:		; 0xE0 en la Y: el VDP no dibuja nada por debajo de esa altura
	ld a,0e0h		;4884   ; 0xE0 en la Y y las otras tres casillas sin tocar
	ld (de),a			;4886
	inc e			;4887
	inc e			;4888
	inc e			;4889
	inc e			;488a
	jr objeto_siguiente		;488b
pon_atributo:		; Copia al buffer la Y, la X, el numero de patron y el color del objeto (IX+4, IX+6, IX+0C, IX+0D).
	ld a,(ix+004h)		;488d   ; El byte 4 del objeto es la Y...
	ld (de),a			;4890
	inc e			;4891
	ld a,(ix+006h)		;4892   ; ...el 6 la X...
	ld (de),a			;4895
	inc e			;4896
	ld a,(ix+00ch)		;4897   ; ...el 12 el numero de patron...
	ld (de),a			;489a
	inc e			;489b
	ld a,(ix+00dh)		;489c   ; ...y el 13 el color
	ld (de),a			;489f
	inc e			;48a0
	ret			;48a1
esconde_el_sprite:		; Mete 0xE0 en la Y, que es la altura con la que el VDP no lo dibuja, y descarta el objeto si se sale por abajo o por la derecha.
	ld a,0e0h		;48a2
	ld (de),a			;48a4
	inc e			;48a5
	inc e			;48a6
	inc e			;48a7
	inc e			;48a8
	ld a,(ix+004h)		;48a9   ; Por debajo de la Y 0xB8 y de la X 0xF8 se sigue; si no, no se dibuja de caracteres
	cp 0b8h		;48ac
	ret nc			;48ae
	ld a,(ix+006h)		;48af
	cp 0f8h		;48b2
	ret nc			;48b4
	exx			;48b5
	ld l,(ix+01eh)		;48b6   ; Los bytes 30 y 31 dicen en que casilla de la pantalla cae
	ld h,(ix+01fh)		;48b9
	ld a,(ix+00bh)		;48bc   ; El byte 11: si vale uno son cuatro caracteres, y si no, dos
	dec a			;48bf
	jr nz,dos_caracteres		;48c0
	ex de,hl			;48c2
dos_por_dos:		; Coge de la tabla 0x91D1 los cuatro caracteres del objeto y los escribe en la tabla de nombres en dos filas, separadas 0x1E.
	ld a,(ix+00ch)		;48c3   ; El numero de patron por cuatro: cuatro caracteres por dibujo
	add a,a			;48c6
	ld l,a			;48c7
	ld h,000h		;48c8
	add hl,hl			;48ca
	ld bc,091d1h		;48cb
	add hl,bc			;48ce
	ldi		;48cf   ; Los dos de arriba...
	ldi		;48d1
	ld a,01eh		;48d3   ; ...y 0x1E mas alla, los dos de abajo, que es la fila siguiente
	add a,e			;48d5
	ld e,a			;48d6
	jr nc,L_48DA		;48d7
	inc d			;48d9
L_48DA:
	ldi		;48da
	ldi		;48dc
	exx			;48de
	ret			;48df
dos_caracteres:		; Los objetos que no son de cuatro caracteres se pintan con dos seguidos, y cual empieza lo dice el byte 11
	ld c,0a1h		;48e0   ; Byte 11 a dos: los caracteres 0xA1 y 0xA2
	dec a			;48e2
	jr z,L_48F1		;48e3
	ld c,0bfh		;48e5   ; A tres: 0xBF y 0xC0
	dec a			;48e7
	jr z,L_48F1		;48e8
	ld c,058h		;48ea   ; A cuatro: 0x58 y 0x59
	dec a			;48ec
	jr z,L_48F1		;48ed
	ld c,060h		;48ef   ; Y si no, 0x60 y 0x61
L_48F1:
	ld (hl),c			;48f1   ; El segundo caracter va pegado al primero
	inc hl			;48f2
	inc c			;48f3
	ld (hl),c			;48f4
	exx			;48f5
	ret			;48f6
borra_un_rectangulo:		; B casillas de ancho por C de alto, a cero, recortando lo que se salga por la derecha
	call recorta_por_la_derecha		;48f7
	ld e,b			;48fa
L_48FB:
	push hl			;48fb
	ld b,e			;48fc
	xor a			;48fd   ; Cero: la casilla vacia
L_48FE:
	ld (hl),a			;48fe
	inc hl			;48ff
	djnz L_48FE		;4900
	pop hl			;4902
	ld a,020h		;4903   ; 0x20: la fila de abajo
	call suma_a_a_hl		;4905
	dec c			;4908
	jr nz,L_48FB		;4909
	ret			;490b
copia_un_rectangulo:		; Lo mismo pero copiando de DE: B de ancho por C de alto, saltando en el origen lo que se haya recortado
	push bc			;490c
	call recorta_por_la_derecha		;490d
	pop af			;4910
	sub b			;4911   ; Lo que se ha recortado, para saltarlo tambien en el origen
	exx			;4912
	ld c,a			;4913
	exx			;4914
L_4915:
	push hl			;4915
	push bc			;4916
copia_una_fila:		; B bytes de DE a HL: una fila del rectangulo
	ld a,(de)			;4917   ; Byte a byte
	ld (hl),a			;4918
	inc hl			;4919
	inc de			;491a
	djnz copia_una_fila		;491b
	pop bc			;491d
	pop hl			;491e
	ld a,020h		;491f   ; 0x20: la fila de abajo del mapa
	call suma_a_a_hl		;4921
	exx			;4924
	ld a,c			;4925
	exx			;4926
	call suma_a_a_de		;4927
	dec c			;492a
	jr nz,L_4915		;492b
	ret			;492d
recorta_por_la_derecha:		; Si el rectangulo se sale de la fila, le quita a B las casillas que sobran
	call casilla_a_direccion_de_ram		;492e
	ld a,l			;4931
	and 01fh		;4932   ; En que columna cae
	add a,b			;4934
	sub 020h		;4935   ; Y cuanto se pasa de las treinta y dos
	ret c			;4937
	neg		;4938   ; B se queda con lo que cabe
	add a,b			;493a
	ld b,a			;493b
	ret			;493c
borra_la_pantalla:		; Llama a 0x55AA y llena de ceros los 768 bytes de la tabla de nombres (VRAM 0x3800) con FILVRM.
	call quita_los_sprites_de_la_pantalla		;493d
	ld hl,03800h		;4940   ; Las 768 casillas de la tabla de nombres
	ld bc,00300h		;4943
	xor a			;4946
	jp 00056h		;4947   ; BIOS FILVRM - Fills VRAM with value
pon_escritura_vram:		; SETWRT y se guarda el puerto de datos del VDP en C'.
	ex af,af'			;494a
	call 00053h		;494b   ; BIOS SETWRT - Enables VDP to write
	exx			;494e
	ld a,(00007h)		;494f   ; 0x0007 guarda el puerto de datos del VDP de esta maquina
	ld c,a			;4952
	exx			;4953
	ex af,af'			;4954
	ret			;4955

; ----------------------------------------------------------------------
; DATOS lectura_de_vram_muerta: Diez bytes que son `call SETRD / exx / ld
;   a,(0x0006) / ld c,a / exx / ret`: la gemela de 0x494A para LEER de la
;   VRAM. Nadie la llama.
;   0x4956..0x4960  (10 bytes)
pon_lectura_vram:		; SETRD y se guarda el puerto de lectura en C'. Nadie la llama: es la gemela muerta de 0x494A.
	defb 0cdh,050h,000h,0d9h,03ah,006h,000h,04fh,0d9h,0c9h	; 4956  .P..:..O..

; ======================================================================
; CODIGO 0x4960..0x4aca  (362 bytes)
; ======================================================================


vuelca_a_vram:		; LDIRVM con DE y HL cambiados.
	ex de,hl			;4960
	jp 0005ch		;4961   ; BIOS LDIRVM - Block transfers to VRAM from memory
vuelca_tres_tercios:		; Tres LDIRVM seguidos, sumando 0x800 cada vez: los tres tercios de la pantalla.
	exx			;4964
	ld b,003h		;4965   ; Tres tercios
L_4967:
	exx			;4967   ; Un tercio cada vez
	push bc			;4968
	push de			;4969
	call vuelca_a_vram		;496a
	ld de,00800h		;496d   ; 0x800: el tercio siguiente
	add hl,de			;4970
	pop de			;4971
	pop bc			;4972
	exx			;4973
	djnz L_4967		;4974
	ret			;4976
llena_tres_tercios:		; Tres FILVRM, uno por tercio.
	ld d,003h		;4977   ; Tres tercios
L_4979:
	push bc			;4979
	push de			;497a
	call 00056h		;497b   ; BIOS FILVRM - Fills VRAM with value
	ld de,00800h		;497e
	add hl,de			;4981
	pop de			;4982
	pop bc			;4983
	dec d			;4984
	jr nz,L_4979		;4985
	ret			;4987
descomprime_tres_tercios:		; Tres veces 0x49B9, uno por tercio.
	ld b,003h		;4988   ; Tres tercios
tercio_siguiente:		; 0x800 mas: el tercio de abajo
	push bc			;498a   ; Un tercio cada vez
	push de			;498b
	call descomprime		;498c
	ld de,00800h		;498f   ; 0x800: el tercio siguiente
	add hl,de			;4992
	pop de			;4993
	pop bc			;4994
	djnz tercio_siguiente		;4995
	ret			;4997
escribe_caracteres:		; Lee del flujo la direccion de VRAM y va escribiendo caracteres con WRTVRM: 0xFE = viene otra direccion, 0xFF = fin. Es el hermano sencillo de 0x49B9, sin comprimir.
	ld c,0ffh		;4998   ; C a 0xFF: el `and c` de abajo deja el caracter tal cual
L_499A:
	ex de,hl			;499a
	ld e,(hl)			;499b   ; Los dos primeros bytes son la casilla de la VRAM
	inc hl			;499c
	ld d,(hl)			;499d
	ex de,hl			;499e
	inc de			;499f
L_49A0:
	ld a,(de)			;49a0
	inc de			;49a1
	ld b,a			;49a2
	inc b			;49a3   ; 0xFF acaba el rotulo
	ret z			;49a4
	inc b			;49a5   ; Y 0xFE lo sigue en otra casilla
	jr z,L_499A		;49a6
	and c			;49a8   ; Aqui es donde C decide entre escribir el caracter o un cero
	call 0004dh		;49a9   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;49ac
	jr L_49A0		;49ad
borra_caracteres:		; Lo mismo que 0x4998 pero con C=0, de modo que el `and c` deja todos los caracteres en cero: sirve para borrar el texto que 0x4998 escribio.
	ld c,000h		;49af
	jr L_499A		;49b1
descomprime_con_destino:		; Entra en el descompresor leyendo antes la direccion de VRAM del propio flujo.
	ex de,hl			;49b3   ; Los dos primeros bytes del flujo son la VRAM de destino
	ld e,(hl)			;49b4
	inc hl			;49b5
	ld d,(hl)			;49b6
	ex de,hl			;49b7
	inc de			;49b8
descomprime:		; El descompresor de graficos. Ver tools/rle.py.
	call pon_escritura_vram		;49b9   ; HL trae la direccion de VRAM y DE el flujo comprimido.
L_49BC:
	ld a,(de)			;49bc   ; Byte de mando.
	and a			;49bd
	ret z			;49be   ; El 0x00 acaba el bloque.
	inc de			;49bf
	ld b,a			;49c0
	and 07fh		;49c1   ; Se separa el bit 7, que es el que dice si viene literal o repeticion.
	cp b			;49c3
	jr z,L_49D4		;49c4   ; Bit 7 a cero: repetir el byte siguiente.
	and a			;49c6
	jr z,descomprime_con_destino		;49c7   ; El mando 0x80 (bit 7 y nada mas) cambia la direccion de VRAM.
	ld b,a			;49c9
L_49CA:
	ld a,(de)			;49ca   ; Copia literal: B bytes tal cual, sacandolos por el puerto del VDP.
	inc de			;49cb
	exx			;49cc
	out (c),a		;49cd
	exx			;49cf
	djnz L_49CA		;49d0
	jr L_49BC		;49d2
L_49D4:
	ld a,(de)			;49d4   ; Repeticion: el mismo byte B veces.
	inc de			;49d5
L_49D6:
	exx			;49d6
	out (c),a		;49d7
	exx			;49d9
	djnz L_49D6		;49da
	jr L_49BC		;49dc
mira_si_hay_sonido:		; Comprueba el bit 6 de 0xE002 antes de caer en el disparador de sonidos.
	di			;49de   ; El bit 6 de 0xE002: sin partida no suena nada
	push hl			;49df
	ld hl,0e002h		;49e0
	bit 6,(hl)		;49e3
	jr z,L_4A1F		;49e5
	jr monta_la_peticion_de_sonido		;49e7
pide_sonido:		; Mete los bancos 7 y 8, apunta el sonido A en la cola, y devuelve el reparto de antes.
	di			;49e9
	push hl			;49ea
monta_la_peticion_de_sonido:		; Mete los bancos 7 y 8, que son los del reproductor, deja la peticion en la cola y devuelve el reparto de antes
	push de			;49eb   ; Se guarda todo: esto se llama desde cualquier sitio
	push bc			;49ec
	push af			;49ed
	di			;49ee
	ld a,007h		;49ef   ; Banco 7 en 0x8000 y banco 8 en 0xA000
	ld (08000h),a		;49f1
	ld (0f0f2h),a		;49f4
	ei			;49f7
	di			;49f8
	ld a,008h		;49f9
	ld (0a000h),a		;49fb
	ld (0f0f3h),a		;49fe
	ei			;4a01
	di			;4a02
	pop af			;4a03
	push af			;4a04
	call encola_sonido		;4a05   ; Con ellos puestos se encola la peticion
	di			;4a08
	ld a,002h		;4a09   ; Y devueltos el 2 y el 3
	ld (08000h),a		;4a0b
	ld (0f0f2h),a		;4a0e
	ei			;4a11
	di			;4a12
	ld a,003h		;4a13
	ld (0a000h),a		;4a15
	ld (0f0f3h),a		;4a18
	ei			;4a1b
	pop af			;4a1c
	pop bc			;4a1d
	pop de			;4a1e
L_4A1F:
	pop hl			;4a1f
	ei			;4a20
	ret			;4a21
encola_sonido:		; Escribe la peticion en la cola de 0xE012/0xE034 usando la tabla 0x8328 del banco 7.
	ld c,a			;4a22
	and 07fh		;4a23   ; Los siete bits bajos son el numero del sonido; el 7 es aparte
	ld b,002h		;4a25   ; Dos canales de cola
	ld hl,0e012h		;4a27
	cp 016h		;4a2a   ; Por debajo del 0x16, el sonido va a la cola de 0xE034
	jr c,L_4A3C		;4a2c
	xor a			;4a2e
	ld (0e044h),a		;4a2f
	ld a,c			;4a32
	and 07fh		;4a33
	cp 026h		;4a35   ; Del 0x26 en adelante, un canal mas
	jr c,L_4A3F		;4a37
	inc b			;4a39
	jr L_4A3F		;4a3a
L_4A3C:
	ld l,034h		;4a3c
	dec b			;4a3e
L_4A3F:
	ld a,(hl)			;4a3f   ; Lo que ya hay encolado
	and 07fh		;4a40
	ld e,a			;4a42
	ld a,c			;4a43
	and 07fh		;4a44
	cp e			;4a46   ; Si lo que ya suena pesa mas, la peticion se tira
	ret c			;4a47
	add a,a			;4a48
	ld de,08328h		;4a49   ; La tabla de 0x8328 del banco 7, indexada por dos
	call suma_a_a_de		;4a4c
	dec hl			;4a4f
	dec hl			;4a50
escribe_la_peticion:		; Deja en la ficha del canal la marca, el numero de sonido y las dos palabras que salen de la tabla
	ld (hl),001h		;4a51   ; La marca de peticion nueva
	inc hl			;4a53
	inc hl			;4a54
	ld (hl),c			;4a55
	inc hl			;4a56
	ld a,(de)			;4a57
	ld (hl),a			;4a58
	inc hl			;4a59
	inc de			;4a5a
	ld a,(de)			;4a5b
	ld (hl),a			;4a5c
	ld a,006h		;4a5d   ; Seis bytes mas: el otro trozo de la ficha
	call suma_a_a_hl		;4a5f
	xor a			;4a62
	ld (hl),a			;4a63
	ld a,007h		;4a64   ; Y siete: la ficha del canal siguiente
	call suma_a_a_hl		;4a66
	inc de			;4a69
	djnz escribe_la_peticion		;4a6a
	ret			;4a6c
carga_los_graficos_de_la_explosion:		; Con los bancos 4/5/6 puestos, las fichas de 0x98A3 y el espejo de 0x98B0; luego borra los 0x800 bytes de objetos
	di			;4a6d   ; Bancos 4, 5 y 6, que son los de graficos
	push hl			;4a6e   ; Los tres bancos de graficos
	ld hl,0f0f1h		;4a6f
	ld a,004h		;4a72
	ld (06000h),a		;4a74
	ld (hl),a			;4a77
	inc a			;4a78
	ld (08000h),a		;4a79
	inc hl			;4a7c
	ld (hl),a			;4a7d
	inc a			;4a7e
	ld (0a000h),a		;4a7f
	inc hl			;4a82
	ld (hl),a			;4a83
	pop hl			;4a84
	ei			;4a85
	ld ix,098a3h		;4a86   ; Las fichas de 0x98A3
	call carga_fichas		;4a8a
	ld a,001h		;4a8d
	ld (0e100h),a		;4a8f   ; 0xE100 a uno: el espejo por bytes
	ld ix,098b0h		;4a92   ; Y el espejo de 0x98B0
	call monta_un_espejo		;4a96
	di			;4a99   ; Devueltos el 1, el 2 y el 3
	push hl			;4a9a   ; Y devueltos el 1, el 2 y el 3
	ld hl,0f0f1h		;4a9b
	ld a,001h		;4a9e
	ld (06000h),a		;4aa0
	ld (hl),a			;4aa3
	inc a			;4aa4
	ld (08000h),a		;4aa5
	inc hl			;4aa8
	ld (hl),a			;4aa9
	inc a			;4aaa
	ld (0a000h),a		;4aab
	inc hl			;4aae
	ld (hl),a			;4aaf
	pop hl			;4ab0
	ei			;4ab1
	ld hl,0e300h		;4ab2   ; Y los 0x800 bytes de objetos, a cero
	ld de,0e301h		;4ab5
	ld bc,007ffh		;4ab8   ; 0x800 bytes
	ld (hl),000h		;4abb
	ldir		;4abd
	ret			;4abf
despacha_el_final_de_la_nave:		; 0xE1D0 lleva el paso de la explosion y 0xE1D1 el submodo: diez destinos en la tabla de 0x4ACA
	ld hl,(0e1d0h)		;4ac0   ; 0xE1D0 el paso y 0xE1D1 el submodo
	ld a,l			;4ac3
	and a			;4ac4
	ret z			;4ac5   ; Con el paso a cero no hay explosion
	ld a,h			;4ac6
	call despachador		;4ac7

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_4AC7: Diez palabras pegadas detras del `call
;   0x4067` de 0x4AC7.
;   0x4aca..0x4ade  (20 bytes)
DATA_tabla_del_despachador_4AC7:
	defw 04adeh,04affh	; 4aca  -> explosion_paso_0 explosion_paso_1
	defw 04b60h,04b82h	; 4ace  -> explosion_paso_2 explosion_paso_3
	defw 04bd8h,04c16h	; 4ad2  -> explosion_paso_4 explosion_paso_5
	defw 04c2bh,04c62h	; 4ad6  -> explosion_paso_6 explosion_paso_7
	defw 04c79h,04c86h	; 4ada  -> explosion_paso_8 explosion_paso_9

; ======================================================================
; CODIGO 0x4ade..0x4c11  (307 bytes)
; ======================================================================


explosion_paso_0:		; Sube 0x40 el contador de 0xE1D3 y, pasada la Y 0xF0, borra la pantalla y apaga los sprites
	ld hl,(0e1d3h)		;4ade
	ld de,00040h		;4ae1   ; 0x40 mas cada cuadro
	add hl,de			;4ae4
	ld (0e1d3h),hl		;4ae5
	ld hl,00800h		;4ae8   ; 0x0800 en 0xE008
	ld (0e008h),hl		;4aeb
	ld a,(0e206h)		;4aee   ; Y hasta que 0xE206 no pase de 0xF0, no se borra nada
	cp 0f0h		;4af1
	ret c			;4af3
	call borra_la_pantalla		;4af4
	call apaga_los_sprites		;4af7
sube_el_submodo:		; 0xE1D1 + 1: el paso siguiente de la explosion
	ld hl,0e1d1h		;4afa
	inc (hl)			;4afd
	ret			;4afe
explosion_paso_1:		; Espera a que calle el canal, carga desde el banco 10 los graficos del final, apaga los sprites y pone el dibujo de 4x4
	ld a,(0e012h)		;4aff   ; Hasta que el canal de 0xE012 no calle, no se sigue
	and a			;4b02
	ret nz			;4b03
	call carga_el_marcador		;4b04
	di			;4b07   ; Banco 10 en 0xA000: los graficos del final
	ld a,00ah		;4b08
	ld (0a000h),a		;4b0a
	ld (0f0f3h),a		;4b0d
	ei			;4b10
	ld hl,02418h		;4b11   ; Tres tercios de patrones en la VRAM 0x2418...
	ld de,0a0dbh		;4b14
	call descomprime_tres_tercios		;4b17
	ld hl,00418h		;4b1a   ; ...y tres de colores en la 0x0418
	ld de,0a3f4h		;4b1d
	call descomprime_tres_tercios		;4b20
	ld hl,01800h		;4b23   ; Y los patrones de sprite, en la 0x1800
	ld de,0a683h		;4b26
	call descomprime		;4b29
	di			;4b2c   ; Devuelto el banco 3
	ld a,003h		;4b2d
	ld (0a000h),a		;4b2f
	ld (0f0f3h),a		;4b32
	ei			;4b35
	call apaga_los_sprites		;4b36
	ld de,04fb2h		;4b39   ; El dibujo de cuatro por cuatro de 0x4FB2
	call escribe_caracteres		;4b3c
	xor a			;4b3f
	ld (0e1d2h),a		;4b40
	ld hl,000c0h		;4b43   ; 0x00C0 en 0xE1D5: la cuenta larga
	ld (0e1d5h),hl		;4b46
	ld a,003h		;4b49
	ld (0e1d7h),a		;4b4b
	ld a,038h		;4b4e   ; El sonido 0x38
	call mira_si_hay_sonido		;4b50
	jr sube_el_submodo		;4b53
apaga_los_sprites:		; Deja los 128 bytes de 0xEC80 a 0xE0, que es la Y con la que un sprite no se ve.
	ld hl,0ec80h		;4b55
	ld b,080h		;4b58   ; Los 128 bytes de la tabla de atributos
L_4B5A:
	ld (hl),0e0h		;4b5a
	inc hl			;4b5c
	djnz L_4B5A		;4b5d
	ret			;4b5f
explosion_paso_2:		; Mueve los objetos hasta que 0xE1D5 llega a cero, y entonces arranca el parpadeo del dibujo
	call suelta_metralla		;4b60
	call mueve_la_metralla		;4b63
	call anima_la_metralla		;4b66
	call sube_la_metralla_al_buffer		;4b69
	ld a,(0e1d5h)		;4b6c   ; 0xE1D5 baja por otro lado; hasta que no llega a cero, no se sigue
	or a			;4b6f
	ret nz			;4b70
	ld a,010h		;4b71   ; 0x10 cuadros por paso del dibujo
	ld (0e1d2h),a		;4b73
	xor a			;4b76
	ld (0e1d9h),a		;4b77
	ld a,03bh		;4b7a   ; El sonido 0x3B
	call mira_si_hay_sonido		;4b7c
	jp sube_el_submodo		;4b7f
explosion_paso_3:		; Cada 0x10 cuadros cambia el dibujo de 4x4 por el siguiente de 0x6340; al tercero, lo borra y espera 0x40 cuadros
	call mueve_la_metralla		;4b82
	call anima_la_metralla		;4b85
	call sube_la_metralla_al_buffer		;4b88
	ld hl,0e1d2h		;4b8b   ; 0xE1D2 cuenta los cuadros de cada dibujo
	dec (hl)			;4b8e
	jr nz,L_4B9C		;4b8f
	ld (hl),010h		;4b91
	ld hl,0e1d9h		;4b93   ; 0xE1D9 dice por que dibujo va
	inc (hl)			;4b96
	ld a,(hl)			;4b97
	cp 003h		;4b98   ; Tres dibujos y se acaba
	jr z,L_4BC1		;4b9a
L_4B9C:
	ld a,(0e1d9h)		;4b9c
	ld de,06340h		;4b9f   ; La tira de 0x6340, en el banco 1
	add a,a			;4ba2   ; Por dieciseis: cuatro por cuatro caracteres
	add a,a			;4ba3
	add a,a			;4ba4
	add a,a			;4ba5
	call suma_a_a_de		;4ba6
	ld c,004h		;4ba9
	ld hl,038aeh		;4bab   ; Fila 5, columna 14
L_4BAE:
	ld b,004h		;4bae
L_4BB0:
	ld a,(de)			;4bb0
	call 0004dh		;4bb1   ; BIOS WRTVRM - Writes data in VRAM
	inc de			;4bb4
	inc hl			;4bb5
	djnz L_4BB0		;4bb6
	ld a,01ch		;4bb8   ; 0x1C: la fila de abajo, restando lo ya andado
	call suma_a_a_hl		;4bba
	dec c			;4bbd
	jr nz,L_4BAE		;4bbe
	ret			;4bc0
L_4BC1:
	ld de,04fceh		;4bc1   ; Y el borrado
	call escribe_caracteres		;4bc4
	xor a			;4bc7
	ld (0e1d9h),a		;4bc8
	ld a,040h		;4bcb   ; 0x40 cuadros de espera
	ld (0e1d2h),a		;4bcd
	ld a,044h		;4bd0   ; El sonido 0x44
	call mira_si_hay_sonido		;4bd2
	jp sube_el_submodo		;4bd5
explosion_paso_4:		; Va encendiendo las seis casillas del medidor de mejoras, cada una mas deprisa que la anterior
	call mueve_la_metralla		;4bd8
	call anima_la_metralla		;4bdb
	call sube_la_metralla_al_buffer		;4bde
	ld hl,0e1d2h		;4be1   ; 0xE1D2 cuenta los cuadros de esta casilla
	dec (hl)			;4be4
	jr nz,L_4BFA		;4be5
	ld hl,0e1d9h		;4be7   ; 0xE1D9 dice por que casilla va
	inc (hl)			;4bea
	ld a,(hl)			;4beb
	cp 006h		;4bec   ; Seis casillas y se acaba
	jr z,acaba_el_medidor		;4bee
	ld de,04c10h		;4bf0   ; 0x4C10 es la tabla de velocidades, y su primer byte cae encima del codigo.
	call suma_a_a_de		;4bf3
	ld a,(de)			;4bf6   ; Cada casilla dura menos: 0x28, 0x28, 0x10, 0x0C, 0x08 y 0x04 cuadros
	ld (0e1d2h),a		;4bf7
L_4BFA:
	ld a,(0e1d9h)		;4bfa
dibuja_el_medidor:		; Coge de 0xE1D9 la casilla encendida del medidor de mejoras y escribe su dibujo con 0x4998.
	ld hl,04edah		;4bfd   ; 0xE1D9 dice que casilla del medidor esta encendida.
	call dame_palabra		;4c00
	jp escribe_caracteres		;4c03   ; Y se dibuja: 0x4998 escribe caracteres, no ejecuta nada.
acaba_el_medidor:		; Apaga los sprites y deja 0x20 cuadros para el paso siguiente
	call apaga_los_sprites		;4c06
	ld a,020h		;4c09
	ld (0e1d2h),a		;4c0b
	jp sube_el_submodo		;4c0e

; ----------------------------------------------------------------------
; DATOS velocidades (tramo): Seis bytes que 0x4BF0 indexa con 0x4062 y guarda
;   en 0xE1D2: 0x28, 0x28, 0x10, 0x0C, 0x08, 0x04.
;   0x4c11..0x4c16  (5 bytes)  de 0x4c10..0x4c16 (6 bytes)
DATA_velocidades_4C11:
	defb 028h,010h,00ch,008h,004h	; 4c11

; ======================================================================
; CODIGO 0x4c16..0x4d3e  (296 bytes)
; ======================================================================


explosion_paso_5:		; Espera los cuadros de 0xE1D2 y luego pide el trozo de pantalla 0
	call elige_el_color_del_borde		;4c16
	ld hl,0e1d2h		;4c19
	dec (hl)			;4c1c
	ret nz			;4c1d
	ld b,000h		;4c1e   ; Borde negro
	call pon_el_color_del_borde		;4c20
	ld a,028h		;4c23   ; Y otros 0x28 cuadros
	ld (0e1d2h),a		;4c25
	jp sube_el_submodo		;4c28

; ----------------------------------------------------------------------
; EL CARTUCHO MIRA DE QUE PAIS ES LA MAQUINA
; Al acabar una vuelta entera se escribe un rotulo, y cual sale depende de
; por que vuelta se va: GOOD, NICE, FINE y GREAT las cuatro primeras. En la
; quinta, el cartucho lee 0x002B de la BIOS -el nibble bajo dice el juego de
; caracteres de la maquina, y a cero es japonesa- y reparte: en una maquina
; japonesa sale YOROKONDE ITADAKEMASHITAKA, y en cualquier otra,
; CONGRATULATIONS. Los dos rotulos estan en la ROM, uno al lado del otro.
; ----------------------------------------------------------------------
explosion_paso_6:		; Borra la pantalla, sube el numero de vuelta de 0xE070 dando la vuelta a las cinco, y escribe el rotulo que toque
	call borra_la_pantalla		;4c2b
	call carga_el_marcador		;4c2e
	ld hl,0e070h		;4c31   ; 0xE070 es la vuelta: cinco y otra vez a cero
	ld c,(hl)			;4c34
	ld a,c			;4c35
	inc a			;4c36
	cp 005h		;4c37
	jr c,L_4C3C		;4c39
	xor a			;4c3b
L_4C3C:
	ld (hl),a			;4c3c
	ld a,c			;4c3d
	cp 004h		;4c3e   ; Solo en la quinta vuelta se mira la maquina
	jr nz,L_4C50		;4c40
	ld a,(0002bh)		;4c42   ; El nibble bajo de 0x002B: el juego de caracteres. A cero, japonesa
	and 00fh		;4c45
	ld a,004h		;4c47
	jr z,L_4C50		;4c49
	ld hl,0502eh		;4c4b   ; En cualquier otra maquina, CONGRATULATIONS
	jr L_4C57		;4c4e
L_4C50:
	ld hl,04feah		;4c50   ; Y si no, el rotulo de la vuelta: GOOD, NICE, FINE, GREAT o el japones
	call dame_palabra		;4c53
	ex de,hl			;4c56
L_4C57:
	call arranca_el_rotulo_lento		;4c57
	ld a,0a9h		;4c5a   ; El sonido 0xA9
	call mira_si_hay_sonido		;4c5c
	jp sube_el_submodo		;4c5f
explosion_paso_7:		; Al acabar el rotulo, deja 0x6001 en 0xE044 y escribe el de 0x5040
	call escribe_una_letra		;4c62
	ret nz			;4c65
	ld hl,06001h		;4c66   ; 0x6001 en 0xE044 y 0xE045
	ld (0e044h),hl		;4c69
	xor a			;4c6c
	ld (0e046h),a		;4c6d   ; 0xE046 a cero
	ld hl,05040h		;4c70   ; Y el rotulo de 0x5040
	call arranca_el_rotulo_lento		;4c73
	jp sube_el_submodo		;4c76
explosion_paso_8:		; Al acabar, regala 500 puntos
	call escribe_una_letra		;4c79
	ret nz			;4c7c
	ld de,00500h		;4c7d   ; 0x0500 en BCD; el rotulo de 0x5040 lo anuncia como BONUS 50000 POINTS
	call suma_a_la_puntuacion		;4c80
	jp sube_el_submodo		;4c83
explosion_paso_9:		; Espera a que calle el canal, borra la pantalla y deja los dos guiones apuntando a 0x504A
	ld a,(0e012h)		;4c86   ; Hasta que 0xE012 no calle, no se sigue
	and a			;4c89
	ret nz			;4c8a
	call borra_la_pantalla		;4c8b
	ld a,001h		;4c8e
	ld (0e150h),a		;4c90   ; 0xE150 a uno
	ld de,0504ah		;4c93   ; 0x504A: el guion con el que arrancan las dos listas
	ld a,e			;4c96
	ld (0e204h),a		;4c97
	ld a,d			;4c9a
	ld (0e206h),a		;4c9b
	ld hl,0e224h		;4c9e   ; Las dos tablas de punteros, la de 0xE224...
	call apunta_todas_las_ranuras		;4ca1
	ld hl,0e244h		;4ca4   ; ...y la de 0xE244
	call apunta_todas_las_ranuras		;4ca7
	ld hl,0e300h		;4caa   ; Y los 0x180 bytes de objetos, a cero
	ld de,0e301h		;4cad
	ld bc,0017fh		;4cb0
	ld (hl),000h		;4cb3
	ldir		;4cb5
	ret			;4cb7
apunta_todas_las_ranuras:		; Deja el mismo puntero en la primera ranura y en las ocho de detras
	ld (hl),e			;4cb8
	inc l			;4cb9
	inc l			;4cba
	ld (hl),d			;4cbb
	ld bc,0000ah		;4cbc   ; Diez bytes: la ranura siguiente
	add hl,bc			;4cbf
	ld b,008h		;4cc0   ; Ocho ranuras mas, ya de dos en dos
L_4CC2:
	ld (hl),e			;4cc2   ; Las ocho ranuras de dos bytes
	inc l			;4cc3
	ld (hl),d			;4cc4
	inc l			;4cc5
	djnz L_4CC2		;4cc6
	ret			;4cc8

; ----------------------------------------------------------------------
; LA METRALLA DE LA EXPLOSION, Y EL REGISTRO R OTRA VEZ
; Cuando la nave revienta, cada tres cuadros sale un trozo de metralla, y
; todo lo que tiene de azar sale del REGISTRO R del Z80, el del refresco de
; la memoria, leido cuatro veces seguidas: uno de sus bits elige entre los
; dos dibujos, otros cuatro eligen una de las dieciseis direcciones de la
; tabla de 0x4D3E, y las dos ultimas lecturas le suman un pellizco a la X y
; a la Y para que dos trozos con la misma direccion no vayan pegados.
; En este modo, 0xE300 NO es la tabla de objetos de siempre: son treinta y
; dos ranuras de dieciseis bytes.
; ----------------------------------------------------------------------
suelta_metralla:		; Cada tres cuadros suelta un trozo de metralla en la primera ranura libre, con dibujo, direccion y empujon sacados del registro R
	ld hl,0e1d7h		;4cc9   ; 0xE1D7: un trozo cada tres cuadros
	dec (hl)			;4ccc
	ret nz			;4ccd
	ld (hl),003h		;4cce
	ld hl,(0e1d5h)		;4cd0   ; 0xE1D5 es lo que queda de explosion
	ld a,l			;4cd3
	or h			;4cd4
	ret z			;4cd5
	dec hl			;4cd6
	ld (0e1d5h),hl		;4cd7
	ld a,r		;4cda   ; El registro R: un bit para elegir entre los dos dibujos
	rra			;4cdc
	ld c,001h		;4cdd
	jr nc,L_4CE2		;4cdf
	inc c			;4ce1
L_4CE2:
	ld hl,0e300h		;4ce2   ; Las treinta y dos ranuras de metralla
	ld b,020h		;4ce5
	xor a			;4ce7
	ld de,00010h		;4ce8   ; Dieciseis bytes por ranura
L_4CEB:
	cp (hl)			;4ceb   ; La primera que este a cero
	jr z,monta_el_trozo_de_metralla		;4cec
	add hl,de			;4cee
	djnz L_4CEB		;4cef
	ret			;4cf1
monta_el_trozo_de_metralla:		; Rellena la ranura: dibujo, la Y 0x38, la X 0x80, y la direccion que saque del registro R
	ld (hl),c			;4cf2
	inc l			;4cf3
	ld (hl),000h		;4cf4
	inc l			;4cf6
	inc l			;4cf7
	ld (hl),038h		;4cf8   ; La Y de partida, 0x38
	inc l			;4cfa
	inc l			;4cfb
	ld (hl),080h		;4cfc   ; Y la X, 0x80: el centro
	inc l			;4cfe
	ld a,r		;4cff   ; Otra vez el registro R: cuatro bits, una de las dieciseis direcciones
	and 00fh		;4d01
	add a,a			;4d03   ; Por cuatro: dos palabras por direccion
	add a,a			;4d04
	push hl			;4d05
	ld hl,04d3eh		;4d06
	call suma_a_a_hl		;4d09
	ld e,(hl)			;4d0c
	inc hl			;4d0d
	ld d,(hl)			;4d0e
	inc hl			;4d0f
	ld a,(hl)			;4d10
	inc hl			;4d11
	ld b,(hl)			;4d12
	pop hl			;4d13
	dec c			;4d14   ; Con el otro dibujo, la velocidad se parte por dos
	ld c,a			;4d15
	jr z,L_4D20		;4d16
	sra d		;4d18   ; Desplazando con el signo: sirve para las direcciones negativas
	rr e		;4d1a
	sra b		;4d1c
	rr c		;4d1e
L_4D20:
	ld a,r		;4d20   ; Y el registro R una vez mas, para desperdigar la X...
	call suma_a_a_de		;4d22
	ld (hl),e			;4d25
	inc l			;4d26
	ld (hl),d			;4d27
	ld a,r		;4d28   ; ...y otra para la Y
	ld e,c			;4d2a
	ld d,b			;4d2b
	call suma_a_a_de		;4d2c
	inc l			;4d2f
	ld (hl),e			;4d30
	inc l			;4d31
	ld (hl),d			;4d32
	inc l			;4d33
	ld (hl),02ch		;4d34   ; 0x2C y 0x07: el patron y el color
	inc l			;4d36
	ld (hl),007h		;4d37
	ld hl,0e1d8h		;4d39   ; 0xE1D8 lleva la cuenta de trozos vivos
	inc (hl)			;4d3c
	ret			;4d3d

; ----------------------------------------------------------------------
; DATOS direcciones_de_la_metralla: Dieciseis direcciones, dos palabras cada
;   una: el paso en X y el paso en Y, en coma fija de 8.8 -el 0x0200 son dos
;   puntos por cuadro-. Las indexa 0x4D06 con cuatro bits del registro R por
;   cuatro. Son las dieciseis direcciones de la rosa, con sus signos.
;   0x4d3e..0x4d7e  (64 bytes)
DATA_direcciones_de_la_metralla:
	defw 00000h,00200h	; 4d3e
	defw 000c4h,001d9h	; 4d42
	defw 0016ah,0016ah	; 4d46
	defw 001d9h,000c4h	; 4d4a
	defw 00200h,00000h	; 4d4e
	defw 001d9h,0ff3ch	; 4d52
	defw 0016ah,0fe96h	; 4d56
	defw 000c4h,0fe27h	; 4d5a
	defw 00000h,0fe00h	; 4d5e
	defw 0ff3ch,0fe27h	; 4d62
	defw 0fe96h,0fe96h	; 4d66
	defw 0fe27h,0ff3ch	; 4d6a
	defw 0fe00h,00000h	; 4d6e
	defw 0fe27h,000c4h	; 4d72
	defw 0fe96h,0016ah	; 4d76
	defw 0ff3ch,001d9h	; 4d7a

; ======================================================================
; CODIGO 0x4d7e..0x4e3b  (189 bytes)
; ======================================================================


mueve_la_metralla:		; Recorre las treinta y dos ranuras de dieciseis bytes y le suma a cada trozo su velocidad; el que se sale de la pantalla, se apaga
	ld ix,0e300h		;4d7e
	ld b,020h		;4d82
L_4D84:
	ld a,(ix+000h)		;4d84   ; La ranura a cero esta libre
	and a			;4d87
	jr z,L_4DBE		;4d88
	ld a,(ix+002h)		;4d8a   ; La X de 16 bits mas su velocidad
	add a,(ix+006h)		;4d8d
	ld (ix+002h),a		;4d90
	ld a,(ix+003h)		;4d93
	adc a,(ix+007h)		;4d96
	cp 0c0h		;4d99   ; Pasada la X 0xC0, el trozo se ha ido
	jr nc,L_4DB6		;4d9b
	ld (ix+003h),a		;4d9d
	ld a,(ix+004h)		;4da0   ; Y lo mismo con la Y
	add a,(ix+008h)		;4da3
	ld (ix+004h),a		;4da6
	ld a,(ix+005h)		;4da9
	adc a,(ix+009h)		;4dac
	ld (ix+005h),a		;4daf
	cp 0f8h		;4db2   ; Y el tope de abajo, 0xF8
	jr c,L_4DBE		;4db4
L_4DB6:
	ld (ix+000h),000h		;4db6   ; La ranura se libera...
	ld hl,0e1d8h		;4dba   ; ...y baja la cuenta de trozos vivos
	dec (hl)			;4dbd
L_4DBE:
	ld de,00010h		;4dbe   ; Dieciseis bytes: la ranura siguiente
	add ix,de		;4dc1
	djnz L_4D84		;4dc3
	ret			;4dc5
sube_la_metralla_al_buffer:		; Las treinta y dos ranuras al buffer de atributos: la Y, la X, el patron y el color; la ranura libre va a 0xE0
	ld ix,0e300h		;4dc6
	ld hl,0ec80h		;4dca
	ld b,020h		;4dcd
L_4DCF:
	ld c,(ix+003h)		;4dcf   ; El byte 3 es la Y
	ld a,(ix+000h)		;4dd2
	and a			;4dd5
	jr nz,L_4DDA		;4dd6
	ld c,0e0h		;4dd8   ; Con la ranura libre, 0xE0: fuera de la pantalla
L_4DDA:
	ld (hl),c			;4dda
	inc hl			;4ddb
	ld a,(ix+005h)		;4ddc   ; El byte 5 es la X
	ld (hl),a			;4ddf
	inc hl			;4de0
	ld a,(ix+00ah)		;4de1   ; Y los bytes 10 y 11, el patron y el color
	ld (hl),a			;4de4
	inc hl			;4de5
	ld a,(ix+00bh)		;4de6
	ld (hl),a			;4de9
	inc hl			;4dea
	ld de,00010h		;4deb   ; Dieciseis bytes: la ranura siguiente
	add ix,de		;4dee
	djnz L_4DCF		;4df0
	ret			;4df2
anima_la_metralla:		; Sube el contador de cada trozo y le cambia el patron segun lleve mas o menos cuadros en el aire
	ld b,020h		;4df3
	ld ix,0e300h		;4df5
L_4DF9:
	ld a,(ix+000h)		;4df9
	and a			;4dfc
	jr z,L_4E0B		;4dfd
	inc (ix+001h)		;4dff   ; Un cuadro mas para ese trozo
	dec a			;4e02   ; El primer dibujo lleva cuatro fases; el otro, dos
	push af			;4e03
	call z,cuatro_fases		;4e04
	pop af			;4e07
	call nz,dos_fases		;4e08
L_4E0B:
	ld de,00010h		;4e0b
	add ix,de		;4e0e
	djnz L_4DF9		;4e10
	ret			;4e12
cuatro_fases:		; Cambia de patron a los 0x0C, 0x18 y 0x24 cuadros: 0x2C, 0x30, 0x34 y 0x38
	ld a,(ix+001h)		;4e13   ; Los cuadros que lleva el trozo en el aire
	ld c,02ch		;4e16   ; Por debajo de 0x0C, el primer patron
	cp 00ch		;4e18
	jr c,L_4E2A		;4e1a
	ld c,030h		;4e1c
	cp 018h		;4e1e   ; Y luego el 0x30, el 0x34 y el 0x38
	jr c,L_4E2A		;4e20
	ld c,034h		;4e22
	cp 024h		;4e24
	jr c,L_4E2A		;4e26
	ld c,038h		;4e28
L_4E2A:
	ld (ix+00ah),c		;4e2a
	ret			;4e2d
dos_fases:		; El otro dibujo solo cambia una vez, a los 0x60 cuadros
	ld a,(ix+001h)		;4e2e   ; Los cuadros que lleva el trozo en el aire
	ld c,02ch		;4e31
	cp 060h		;4e33
	jr c,L_4E2A		;4e35
	ld c,030h		;4e37
	jr L_4E2A		;4e39

; ----------------------------------------------------------------------
; DATOS codigo_al_que_no_llega_nadie: Ochenta y tres bytes que desensamblan
;   como codigo -empiezan con `ld a,(0xE1D2) / dec a / ld hl,0x4E82`- pero a
;   los que no llega ningun camino: la instruccion de delante acaba en `ret` y
;   ninguna instruccion ni tabla del cartucho apunta a 0x4E3B. Se listan como
;   bytes para no decir que son codigo vivo.
;   0x4e3b..0x4e8e  (83 bytes)
DATA_codigo_al_que_no_llega_nadie:
	defb 03ah,0d2h,0e1h,03dh,021h,082h,04eh,028h,011h,021h,076h,04eh,0feh,009h,038h,00ah	; 4e3b  :..=!.N(.!vN..8.
	defb 021h,06ah,04eh,0feh,013h,038h,003h,021h,05eh,04eh,011h,080h,0ech,001h,00ch,000h	; 4e4b  !jN..8.!^N......
	defb 0edh,0b0h,0c9h,040h,060h,000h,004h,040h,070h,004h,005h,040h,080h,024h,006h,040h	; 4e5b  ...@`..@p..@.$.@
	defb 060h,00ch,004h,040h,070h,010h,004h,040h,080h,028h,006h,040h,070h,018h,006h,040h	; 4e6b  `..@p..@.(.@p..@
	defb 070h,01ch,005h,0e0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 4e7b  p...............
	defb 000h,000h,000h	; 4e8b

; ======================================================================
; CODIGO 0x4e8e..0x4eda  (76 bytes)
; ======================================================================


elige_el_color_del_borde:		; Un bit de 0xE1D2 elige entre el color 3 y el 9 para el borde
	ld a,(0e1d2h)		;4e8e   ; Un bit de 0xE1D2
	rra			;4e91
	rra			;4e92
	ld b,003h		;4e93
	jr c,L_4E99		;4e95
	ld b,009h		;4e97
L_4E99:
	jp pon_el_color_del_borde		;4e99
arranca_el_rotulo_lento:		; Guarda en 0xE1DB la casilla de VRAM y en 0xE1DD el texto: el rotulo se va a escribir letra a letra
	ld e,(hl)			;4e9c   ; Los dos primeros bytes son la casilla
	inc hl			;4e9d
	ld d,(hl)			;4e9e
	inc hl			;4e9f
	ld (0e1dbh),de		;4ea0   ; La casilla en 0xE1DB y el texto en 0xE1DD
	ld (0e1ddh),hl		;4ea4
	ld a,001h		;4ea7   ; 0xE1DA a uno: la primera letra entra ya
	ld (0e1dah),a		;4ea9
	ret			;4eac
escribe_una_letra:		; Cada seis cuadros escribe UNA letra del rotulo; el 0xFF lo acaba y el 0xFE lo sigue en otra casilla
	ld hl,0e1dah		;4ead   ; 0xE1DA: una letra cada seis cuadros
	dec (hl)			;4eb0
	ret nz			;4eb1
	ld (hl),006h		;4eb2
	ld hl,(0e1dbh)		;4eb4   ; Por donde va la casilla y por donde va el texto
	ld de,(0e1ddh)		;4eb7
	ld a,(de)			;4ebb
	cp 0ffh		;4ebc   ; 0xFF: el rotulo esta entero
	ret z			;4ebe
	cp 0feh		;4ebf   ; Y 0xFE: se sigue en otra casilla
	jr nz,L_4ECB		;4ec1
	inc de			;4ec3
	ex de,hl			;4ec4
	ld e,(hl)			;4ec5
	inc hl			;4ec6
	ld d,(hl)			;4ec7
	ex de,hl			;4ec8
	inc de			;4ec9
	ld a,(de)			;4eca
L_4ECB:
	inc de			;4ecb
	ld (0e1ddh),de		;4ecc
	call 0004dh		;4ed0   ; BIOS WRTVRM - Writes data in VRAM | La letra, a la VRAM
	inc hl			;4ed3
	ld (0e1dbh),hl		;4ed4
	or 0ffh		;4ed7   ; Sale con 0xFF: aun queda rotulo
	ret			;4ed9

; ----------------------------------------------------------------------
; DATOS tabla_del_medidor: Seis palabras (0x4EE6, 0x4EEB, 0x4EF4, 0x4F08,
;   0x4F2B, 0x4F63) que 0x4BFD indexa con 0xE1D9, la casilla encendida del
;   medidor de mejoras. NO son rutinas: son los seis dibujos del medidor, y
;   0x4BFD acaba en `jp 0x4998`, que es el que escribe caracteres.
;   0x4eda..0x4ee6  (12 bytes)
DATA_tabla_del_medidor:
	defw 04ee6h,04eebh	; 4eda  -> DATA_dibujos_del_medidor 0x4eeb
	defw 04ef4h,04f08h	; 4ede
	defw 04f2bh,04f63h	; 4ee2

; ----------------------------------------------------------------------
; DATOS dibujos_del_medidor: Los seis dibujos que apunta la tabla de arriba,
;   en el formato de 0x4998: dos bytes de direccion de VRAM, y detras los
;   caracteres (0xFE = viene otra direccion, 0xFF = fin). Se cuentan, no se
;   estiman: los seis miden 5, 9, 20, 35, 56 y 79 bytes y encajan exactamente
;   de 0x4EE6 a 0x4FB1. Escriben en la tabla de nombres alrededor de
;   0x38EA-0x390E, que es la fila del medidor.
;   0x4ee6..0x4fb2  (204 bytes)
DATA_dibujos_del_medidor:
	defb 0efh,038h,0a1h,0a2h,0ffh,0cfh,038h,0a3h,0feh,0efh,038h,0a4h,0a5h,0ffh,0ceh,038h	; 4ee6  .8....8...8....8
	defb 000h,0a6h,0a7h,000h,0feh,0eeh,038h,0a8h,0a9h,0aah,0abh,0feh,00eh,039h,000h,0ach	; 4ef6  ......8......9..
	defb 0adh,0ffh,0cch,038h,000h,000h,000h,0aeh,0feh,0ech,038h,000h,000h,000h,0afh,0b0h	; 4f06  ...8......8.....
	defb 000h,000h,0feh,00ch,039h,0b1h,0b2h,0b3h,0b4h,0b5h,0b6h,0b7h,0feh,02ch,039h,000h	; 4f16  ....9........,9.
	defb 000h,000h,0b8h,0b9h,0ffh,0cbh,038h,000h,000h,000h,000h,0bah,000h,000h,000h,0feh	; 4f26  ......8.........
	defb 0ebh,038h,000h,000h,000h,000h,0bbh,0bch,000h,000h,000h,0feh,00bh,039h,0bdh,0beh	; 4f36  .8...........9..
	defb 0bfh,0c0h,0c1h,0c2h,0c3h,0bfh,0c4h,0feh,02bh,039h,000h,0c5h,0c6h,0c7h,0c8h,0c9h	; 4f46  ........+9......
	defb 0cah,0cbh,0cch,0feh,04bh,039h,000h,000h,000h,000h,0cdh,0ceh,0ffh,0cah,038h,000h	; 4f56  ....K9........8.
	defb 000h,000h,000h,000h,0cfh,000h,000h,000h,0feh,0eah,038h,000h,000h,000h,000h,000h	; 4f66  ..........8.....
	defb 0d0h,000h,000h,000h,000h,0feh,00ah,039h,000h,000h,000h,000h,000h,0d1h,0d2h,000h	; 4f76  .......9........
	defb 000h,000h,000h,0feh,02ah,039h,0d3h,0d4h,000h,0d5h,0d6h,0d7h,0d8h,0d9h,0dah,000h	; 4f86  ....*9..........
	defb 0dbh,0dch,0feh,04ah,039h,000h,0ddh,0deh,0dfh,0e0h,0e1h,0e2h,0e3h,0e4h,0e5h,0e6h	; 4f96  ...J9...........
	defb 0feh,06ah,039h,000h,000h,000h,000h,0e7h,0e8h,0e9h,0eah,0ffh	; 4fa6  .j9.........

; ----------------------------------------------------------------------
; DATOS dibujo_de_cuatro_por_cuatro: Cuatro filas de cuatro caracteres (del
;   0xEB al 0xF8) en la fila 5 y la columna 14, en el formato de 0x4998: un
;   dibujo hecho con caracteres en mitad de la pantalla. Lo pide 0x4B39.
;   0x4fb2..0x4fce  (28 bytes)
DATA_dibujo_de_cuatro_por_cuatro:
	defb 0aeh,038h,000h,0ebh,0ech,000h,0feh	; 4fb2
	defb 0ceh,038h,0edh,0eeh,0efh,0f0h,0feh	; 4fb9
	defb 0eeh,038h,0f1h,0f2h,0f3h,0f4h,0feh	; 4fc0
	defb 00eh,039h,0f5h,0f6h,0f7h,0f8h,0ffh	; 4fc7

; ----------------------------------------------------------------------
; DATOS borra_el_dibujo: El mismo dibujo pero con ceros, o sea el borrado. Lo
;   pide 0x4BC1.
;   0x4fce..0x4fea  (28 bytes)
DATA_borra_el_dibujo:
	defb 0aeh,038h,000h,000h,000h,000h,0feh	; 4fce
	defb 0ceh,038h,000h,000h,000h,000h,0feh	; 4fd5
	defb 0eeh,038h,000h,000h,000h,000h,0feh	; 4fdc
	defb 00eh,039h,000h,000h,000h,000h,0ffh	; 4fe3

; ----------------------------------------------------------------------
; DATOS tablas_de_4C4B: Lo que leen 0x4C50 (0x4FEA), 0x4C4B (0x502E), 0x4C70
;   (0x5040) y 0x4C93 (0x504A).
;   0x4fea..0x505a  (112 bytes)
DATA_tablas_de_4C4B:
	defb 0f4h,04fh,0fbh,04fh,002h,050h,009h,050h,011h,050h,00eh,039h,027h,02fh,02fh,024h	; 4fea  .O.O.P.P.P.9'//$
	defb 0ffh,00eh,039h,02eh,029h,023h,025h,0ffh,00eh,039h,026h,029h,02eh,025h,0ffh,00dh	; 4ffa  ..9.)#%..9&).%..
	defb 039h,027h,032h,025h,021h,034h,0ffh,002h,039h,039h,02fh,032h,02fh,02bh,02fh,02eh	; 500a  9'2%!4..99/2/+/.
	defb 024h,025h,000h,029h,034h,021h,024h,021h,02bh,025h,02dh,021h,033h,028h,029h,034h	; 501a  $%.)4!$!+%-!3()4
	defb 021h,02bh,021h,0ffh,008h,039h,023h,02fh,02eh,027h,032h,021h,034h,035h,02ch,021h	; 502a  !+!..9#/.'2!45,!
	defb 034h,029h,02fh,02eh,033h,0ffh,062h,039h,000h,000h,000h,000h,000h,022h,02fh,02eh	; 503a  4)/.3.b9....."/.
	defb 035h,033h,000h,015h,010h,010h,010h,010h,000h,030h,02fh,029h,02eh,034h,033h,0ffh	; 504a  53.......0/).43.

; ======================================================================
; CODIGO 0x505a..0x50ae  (84 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; NEMESIS BUSCA OTRO CARTUCHO DE KONAMI EN LAS DEMAS RANURAS
; Al arrancar, INIT llama aqui y el cartucho se pone a mirar las otras
; ranuras y subranuras de la maquina con RDSLT, leyendo SEIS bytes hacia
; atras desde 0xBFFF y comparandolos con los de 0x50AE.
; Esos seis bytes -AC 81 91 06 40 AA leidos en orden de memoria- no son un
; numero cualquiera: son el FINAL DE LA MARCA OCULTA DE KONAMI de otro
; cartucho, la misma que Nemesis lleva al final de su banco 3. Descifrada
; con el codigo de la casa: 0xAA la cierra, 0x40 es el numero de catalogo
; -RC-740-, 0x06 dice que el titulo tiene seis caracteres, y los tres que
; se comparan son, ya del derecho, TU I N: ツイン, el principio de
; ツインビー. O sea que Nemesis busca al TwinBee (Konami, RC-740).
; Si lo encuentra, 0xF0F4 se queda a uno, y con eso el juego carga graficos
; de mas: el bloque de 0x9963 en 0x428A y las fichas de 0x938E y 0x939B en
; 0x4326.
; ----------------------------------------------------------------------
busca_el_otro_cartucho:		; Recorre las ranuras 0, 0x80, 0x84, 0x88 y 0x8C buscando la marca de Konami del RC-740
	xor a			;505a
	ld (0f0f4h),a		;505b   ; 0xF0F4 a cero: de momento no hay compañero
	ld c,000h		;505e   ; La ranura 0 y las cuatro subranuras de la 3
	call prueba_cuatro_subranuras		;5060
	ld c,080h		;5063
	call prueba_cuatro_subranuras		;5065
	ld c,084h		;5068
	call prueba_cuatro_subranuras		;506a
	ld c,088h		;506d
	call prueba_cuatro_subranuras		;506f
	ld c,08ch		;5072
	call prueba_cuatro_subranuras		;5074
	ret			;5077
prueba_cuatro_subranuras:		; Prueba esa ranura y las tres siguientes; en cuanto una cuadra, se deja de buscar
	ld a,(0f0f4h)		;5078   ; Si ya se encontro, no se sigue buscando
	and a			;507b
	ret nz			;507c
	ld b,004h		;507d   ; Cuatro subranuras
prueba_una_subranura:		; Prueba esa subranura y pasa a la siguiente
	push bc			;507f   ; Cuatro subranuras
	call compara_la_marca		;5080
	pop bc			;5083
	ret z			;5084
	inc c			;5085   ; La siguiente
	djnz prueba_una_subranura		;5086
	xor a			;5088
	ld (0f0f4h),a		;5089
	ret			;508c
compara_la_marca:		; Lee seis bytes hacia atras desde 0xBFFF de esa ranura y los compara con los de 0x50AE
	ld hl,0bfffh		;508d   ; Se leen seis bytes desde el final de la pagina 2 de OTRA ranura, hacia atras.
	ld de,050aeh		;5090   ; Y se comparan con los seis de 0x50AE, que son la marca oculta de Konami de otro cartucho.
	ld b,006h		;5093   ; Seis bytes
L_5095:
	push bc			;5095
	push hl			;5096
	push de			;5097
	ld a,c			;5098
	call 0000ch		;5099   ; BIOS RDSLT - Reads the value of an address in another slot | RDSLT: leer una direccion de la ranura que dice A, sin cambiar de ranura.
	pop de			;509c
	pop hl			;509d
	pop bc			;509e
	ex de,hl			;509f
	cp (hl)			;50a0
	ex de,hl			;50a1
	ret nz			;50a2   ; En cuanto uno no cuadra, se abandona.
	inc de			;50a3   ; Uno sube y el otro baja: la marca esta escrita del reves
	dec hl			;50a4
	djnz L_5095		;50a5
	ld a,001h		;50a7   ; Si cuadran los seis, 0xF0F4 = 1, y eso enciende graficos de mas.
	ld (0f0f4h),a		;50a9
	xor a			;50ac
	ret			;50ad

; ----------------------------------------------------------------------
; DATOS marca_del_rc740: Los seis bytes que 0x508D busca en las otras ranuras:
;   AC 81 91 06 40 AA. Son el final de una marca oculta de Konami: 0xAA la
;   cierra, 0x40 es el RC-740, 0x06 la longitud del titulo, y AC 81 91 son, ya
;   del derecho, TU I N -ツイン-, o sea TwinBee.
;   0x50ae..0x50b4  (6 bytes)
DATA_marca_del_rc740:
	defb 0aah,040h,006h,091h,081h,0ach	; 50ae

; ======================================================================
; CODIGO 0x50b4..0x5163  (175 bytes)
; ======================================================================


borra_el_estado_del_marcador:		; 0xE1E0 a cero y los ocho bytes de 0xE1E8 detras
	push hl			;50b4
	push bc			;50b5
	ld hl,00000h		;50b6
	ld (0e1e0h),hl		;50b9
	ld hl,0e1e8h		;50bc
	ld b,008h		;50bf   ; Ocho bytes
L_50C1:
	ld (hl),000h		;50c1   ; Ocho bytes a cero
	inc hl			;50c3
	djnz L_50C1		;50c4
	pop bc			;50c6
	pop hl			;50c7
	ret			;50c8

; ----------------------------------------------------------------------
; LAS CLAVES QUE SE ESCRIBEN CON EL TECLADO, EN PAUSA
; Esto NO se lee mientras se juega: 0x4518 solo llama aqui cuando el bit 0
; de 0xE10B esta puesto, o sea con la partida EN PAUSA. Se pausa con la
; tecla GRAPH -fila 6, bit 5, en 0x44F6-, se escribe, y al despausar sigue
; el juego. Al entrar en pausa, 0x50B4 borra lo escrito antes.
; Cada tecla nueva se guarda en 0xE1E8, hasta ocho, y al pulsar RETURN se
; compara lo escrito contra las palabras de 0x51BF. Lo que hay en la ROM:
; HYPER    solo la primera vez (0xE06E), y salta a 0xA0D8: TODO de golpe
; LASER    -> 0xA101      MISSILE -> 0xA106
; SHIELD   -> 0xA0E9      DOUBLE  -> 0xA10B
; OPTION   -> 0xA110      DOWN    -> 0xA0FA, que quita
; BAKA y AHO -tonto e idiota en japones- NO dan nada: caen en 0x5127,
; que pone a cero las naves, el aviso y las dos banderas del mando.
; Y ademas cada fase tiene SU nombre de mujer -MOMOKO, CHIE, AKEMI,
; SYUKO, CHIAKI, NORIKO, SATOE, YASUKO, KINUYO, HISAE, MIYUKI, YOHKO-,
; que la tabla de 0x5163 reparte por fase: acertar el de la fase en la que
; se esta pone 0xE071 a uno y salta a 0xA0D8. Los seis premios solo se dan
; si 0xE071 sigue a cero, asi que el nombre y las palabras se estorban.
; MEDIDO EN openMSX con tools/omsx_claves.tcl, no deducido: en pausa,
; 0xE1E8 se llena con 4F 50 54 49 4F 4E -OPTION- y al pulsar RETURN
; 0xE20B pasa de 00 a 02, las dos opciones. Con BAKA, las naves de 0xE060
; pasan de 02 a 00 y el aviso de 0xE05F se apaga.
; ----------------------------------------------------------------------
mira_lo_que_se_teclea:		; Lee el teclado y, con RETURN, compara lo escrito contra las claves; cada una salta a lo suyo en el banco 3
	ld a,(0e200h)		;50c9   ; Con 0xE200 en negativo no hay nave, y no hay claves
	and a			;50cc
	ret m			;50cd
	call que_tecla_se_pulsa		;50ce   ; Que tecla se esta pulsando
	and a			;50d1
	ret z			;50d2
	ld hl,0e1e1h		;50d3   ; 0xE1E1 guarda la de antes: solo cuenta la tecla nueva
	cp (hl)			;50d6
	ret z			;50d7
	ld (hl),a			;50d8
	ld c,a			;50d9
	cp 00dh		;50da   ; El 0x0D es RETURN: hasta que no se pulsa, solo se va apuntando
	jp nz,apunta_la_tecla		;50dc
	ld hl,borra_el_estado_del_marcador		;50df   ; Se empuja 0x50B4: pase lo que pase, lo escrito se borra al salir
	push hl			;50e2
	call compara_hyper		;50e3   ; HYPER
	jr nc,clave_hyper		;50e6
	call compara_baka		;50e8   ; BAKA...
	jr nc,castiga_al_que_insulta		;50eb
	call compara_aho		;50ed   ; ...y AHO: las dos castigan
	jr nc,castiga_al_que_insulta		;50f0
	ld a,(0e071h)		;50f2   ; Con 0xE071 ya puesto no se admite otro premio
	and a			;50f5
	ret nz			;50f6
	call compara_el_nombre_de_la_fase		;50f7   ; El nombre de mujer que le toca a esta fase
	jp nc,clave_del_nombre		;50fa
	ld a,(0e200h)		;50fd
	and a			;5100
	ret m			;5101
	call compara_missile		;5102   ; MISSILE
	jp nc,0a106h		;5105
	call compara_laser		;5108   ; LASER
	jp nc,0a101h		;510b
	call compara_shield		;510e   ; SHIELD
	jp nc,0a0e9h		;5111
	call compara_double		;5114   ; DOUBLE
	jp nc,0a10bh		;5117
	call compara_down		;511a   ; DOWN
	jp nc,0a0fah		;511d
	call compara_option		;5120   ; OPTION
	jp nc,0a110h		;5123
	ret			;5126
castiga_al_que_insulta:		; BAKA y AHO acaban aqui: naves, aviso y banderas del mando a cero
	xor a			;5127   ; Naves, aviso y las dos banderas del mando
	ld (0e060h),a		;5128
	ld (0e05fh),a		;512b
	ld (0e044h),a		;512e
	ld (0e047h),a		;5131
	ret			;5134
clave_hyper:		; HYPER solo cuela una vez por partida, y lo lleva 0xE06E
	ld hl,0e06eh		;5135   ; 0xE06E: HYPER solo cuela una vez por partida
	ld a,(hl)			;5138
	and a			;5139
	ret nz			;513a
	inc (hl)			;513b
	jp 0a0d8h		;513c
clave_del_nombre:		; El nombre de la fase acertado: 0xE071 a uno y al banco 3
	ld a,001h		;513f
	ld (0e071h),a		;5141
	jp 0a0d8h		;5144
apunta_la_tecla:		; Va guardando en 0xE1E8 las teclas nuevas, hasta ocho
	ld hl,0e1e0h		;5147
	ld a,(hl)			;514a
	cp 008h		;514b   ; Ocho letras como mucho
	ret nc			;514d
	inc (hl)			;514e
	ld hl,0e1e8h		;514f
	call suma_a_a_hl		;5152
	ld (hl),c			;5155
	ret			;5156
compara_el_nombre_de_la_fase:		; Saca de la tabla de 0x5163 el nombre que le toca a esta fase y lo compara
	ld hl,05163h		;5157
	ld a,(0e061h)		;515a
	dec a			;515d
	call dame_palabra		;515e
	jr $+80		;5161

; ----------------------------------------------------------------------
; DATOS textos_por_fase: Catorce palabras que 0x5157 indexa con la fase menos
;   uno: donde empieza el nombre que se escribe en cada fase (0x51F6, 0x51FD,
;   0x5202, ...).
;   0x5163..0x517f  (28 bytes)
DATA_textos_por_fase:
	defw 051f6h,051fdh	; 5163
	defw 05202h,05208h	; 5167
	defw 0520eh,05215h	; 516b
	defw 0521ch,05222h	; 516f
	defw 05229h,05230h	; 5173
	defw 05236h,0523dh	; 5177
	defw 0523dh,0523dh	; 517b

; ======================================================================
; CODIGO 0x517f..0x51bf  (64 bytes)
; ======================================================================


compara_baka:
	ld de,051c5h		;517f   ; BAKA
	jr compara_la_palabra		;5182
compara_aho:
	ld de,051cah		;5184   ; AHO
	jr compara_la_palabra		;5187
compara_laser:
	ld de,051ceh		;5189   ; LASER
	jr acierto_de_premio		;518c
compara_shield:
	ld de,051dch		;518e   ; SHIELD
	jr acierto_de_premio		;5191
compara_down:
	ld de,051f1h		;5193   ; DOWN
	jr acierto_de_premio		;5196
compara_option:
	ld de,051e3h		;5198   ; OPTION
	jr acierto_de_premio		;519b
compara_double:
	ld de,051eah		;519d   ; DOUBLE
	jr acierto_de_premio		;51a0
compara_missile:
	ld de,051d4h		;51a2   ; MISSILE
acierto_de_premio:		; Si la palabra cuadra, sube 0xE071 para que no se pueda encadenar otro premio
	call compara_la_palabra		;51a5
	ret c			;51a8
	ld hl,0e071h		;51a9   ; 0xE071 sube: ya no se admite otro premio en esta fase
	inc (hl)			;51ac
	ret			;51ad
compara_hyper:
	ld de,051bfh		;51ae   ; HYPER
compara_la_palabra:		; Compara lo tecleado en 0xE1E8 con la palabra de DE; el 0x0D la acaba, y sale sin acarreo si cuadra
	ld hl,0e1e8h		;51b1
L_51B4:
	ld a,(de)			;51b4
	cp 00dh		;51b5   ; El 0x0D separa una palabra de la siguiente
	ret z			;51b7
	cp (hl)			;51b8
	inc de			;51b9
	inc hl			;51ba
	jr z,L_51B4		;51bb
	scf			;51bd   ; Acarreo puesto: no cuadra
	ret			;51be

; ----------------------------------------------------------------------
; DATOS textos: Cadenas separadas por 0x0D: HYPER, BAKA, AHO, LASER, MISSILE,
;   SHIELD, OPTION, DOUBLE, DOWN, y despues los nombres que salen de serie en
;   la tabla de records: MOMOKO, CHIE, AKEMI, SYUKO, CHIAKI, NORIKO, SATOE,
;   YASUKO, KINUYO, HISAE, MIYUKI, YOHKO.
;   0x51bf..0x5243  (132 bytes)
DATA_textos:
	defb 048h,059h,050h,045h,052h,00dh,042h,041h,04bh,041h,00dh,041h,048h,04fh,00dh,04ch	; 51bf  HYPER.BAKA.AHO.L
	defb 041h,053h,045h,052h,00dh,04dh,049h,053h,053h,049h,04ch,045h,00dh,053h,048h,049h	; 51cf  ASER.MISSILE.SHI
	defb 045h,04ch,044h,00dh,04fh,050h,054h,049h,04fh,04eh,00dh,044h,04fh,055h,042h,04ch	; 51df  ELD.OPTION.DOUBL
	defb 045h,00dh,044h,04fh,057h,04eh,00dh,04dh,04fh,04dh,04fh,04bh,04fh,00dh,043h,048h	; 51ef  E.DOWN.MOMOKO.CH
	defb 049h,045h,00dh,041h,04bh,045h,04dh,049h,00dh,053h,059h,055h,04bh,04fh,00dh,043h	; 51ff  IE.AKEMI.SYUKO.C
	defb 048h,049h,041h,04bh,049h,00dh,04eh,04fh,052h,049h,04bh,04fh,00dh,053h,041h,054h	; 520f  HIAKI.NORIKO.SAT
	defb 04fh,045h,00dh,059h,041h,053h,055h,04bh,04fh,00dh,04bh,049h,04eh,055h,059h,04fh	; 521f  OE.YASUKO.KINUYO
	defb 00dh,048h,049h,053h,041h,045h,00dh,04dh,049h,059h,055h,04bh,049h,00dh,059h,04fh	; 522f  .HISAE.MIYUKI.YO
	defb 048h,04bh,04fh,00dh	; 523f

; ======================================================================
; CODIGO 0x5243..0x526b  (40 bytes)
; ======================================================================


que_tecla_se_pulsa:		; Recorre las ocho filas del teclado con SNSMAT y devuelve el caracter de la primera tecla pulsada
	ld b,008h		;5243
	ld e,000h		;5245
L_5247:
	ld a,e			;5247
	call 00141h		;5248   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix | SNSMAT: la fila E del teclado
	cpl			;524b   ; Un cpl: en el teclado lo pulsado es un cero
	and a			;524c
	jr nz,L_5257		;524d
	inc e			;524f
	djnz L_5247		;5250   ; Ocho filas
	xor a			;5252
	ld (0e1e1h),a		;5253   ; Sin nada pulsado, 0xE1E1 a cero
	ret			;5256
L_5257:
	ld b,a			;5257
	ld a,e			;5258
	add a,a			;5259   ; La fila por ocho: ocho teclas por fila
	add a,a			;525a
	add a,a			;525b
	ld hl,0526bh		;525c
	call suma_a_a_hl		;525f
	ld a,b			;5262
L_5263:
	rra			;5263   ; Se busca el bit puesto, que es la tecla
	jr c,L_5269		;5264
	inc hl			;5266
	jr L_5263		;5267
L_5269:
	ld a,(hl)			;5269
	ret			;526a

; ----------------------------------------------------------------------
; DATOS alfabeto: Los caracteres que se pueden elegir al escribir el nombre,
;   en el orden de la rejilla: 0123456789-^ y luego @[;:],./_ y las 26 letras.
;   Lo indexa 0x525C.
;   0x526b..0x52b3  (72 bytes)
DATA_alfabeto:
	defb 030h,031h,032h,033h,034h,035h,036h,037h,038h,039h,02dh,05eh	; 526b  0123456789-^
	defb 009h,040h,05bh,03bh,03ah,05dh,02ch,02eh,02fh,05fh,041h,042h	; 5277  .@[;:],./_AB
	defb 043h,044h,045h,046h,047h,048h,049h,04ah,04bh,04ch,04dh,04eh	; 5283  CDEFGHIJKLMN
	defb 04fh,050h,051h,052h,053h,054h,055h,056h,057h,058h,059h,05ah	; 528f  OPQRSTUVWXYZ
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 529b  ............
	defb 000h,000h,000h,00dh,000h,000h,000h,000h,000h,000h,000h,000h	; 52a7  ............

; ======================================================================
; CODIGO 0x52b3..0x52c7  (20 bytes)
; ======================================================================


maquina_de_estados:		; Ocho estados, despachados por la tabla de 0x52C7.
	ld hl,0e003h		;52b3   ; 0xE003 cuenta las vueltas de la interrupcion.
	inc (hl)			;52b6
	ld hl,05506h		;52b7   ; Esta es la direccion a la que va a volver el estado...
	ld bc,(0e000h)		;52ba
	ld a,c			;52be
	cp 003h		;52bf
	jr nc,L_52C4		;52c1
	push hl			;52c3   ; ...y se mete en la pila SOLO si 0xE000 es menor que 3.
L_52C4:
	call despachador		;52c4   ; Ocho estados, y la tabla va aqui mismo detras.

; ----------------------------------------------------------------------
; DATOS tabla_de_estados: Ocho palabras pegadas detras del `call 0x4067` de
;   0x52C4: los ocho estados del juego (0x52D7, 0x5308, 0x5312, 0x537D,
;   0x53B1, 0x5464, 0x546F, 0x549A).
;   0x52c7..0x52d7  (16 bytes)
DATA_tabla_de_estados:
	defw 052d7h,05308h	; 52c7  -> estado_0 estado_1
	defw 05312h,0537dh	; 52cb  -> estado_2 estado_3
	defw 053b1h,05464h	; 52cf  -> estado_4 estado_5
	defw 0546fh,0549ah	; 52d3  -> estado_6 estado_7

; ======================================================================
; CODIGO 0x52d7..0x5588  (689 bytes)
; ======================================================================


estado_0:		; Tres subestados: el rotulo de 0x57BD, la espera de 0xE004 y el montaje de la pantalla del titulo
	djnz L_52EC		;52d7   ; Al subestado 1 si no es el 0
	ld a,(0e003h)		;52d9
	rra			;52dc
	ret nc			;52dd
	call sube_el_logotipo		;52de
	ret nz			;52e1
	ld de,057bdh		;52e2
	call descomprime_con_destino		;52e5
	xor a			;52e8
	jp L_5375		;52e9
L_52EC:
	djnz L_52FA		;52ec   ; Al subestado 2 si no es el 1
	ld hl,0e004h		;52ee   ; 0xE004: los cuadros que quedan de espera
	dec (hl)			;52f1
	ret nz			;52f2
	call escribe_el_panel_del_titulo		;52f3   ; Y se monta la pantalla del titulo
	xor a			;52f6
	jp L_53A1		;52f7
L_52FA:
	call programa_el_vdp		;52fa   ; La cortinilla, la pantalla limpia y el marcador
	call borra_la_pantalla		;52fd
	call carga_el_marcador		;5300
	call arranca_la_cortinilla_del_logo		;5303
	jr sube_el_subestado		;5306
estado_1:		; Agota 0xE004 y se va a la presentacion
	ld hl,0e004h		;5308
	dec (hl)			;530b
	jp nz,parpadea_lo_elegido		;530c
	jp espera_treinta_y_dos_y_estado		;530f
estado_2:		; Mete los bancos 9 y 10 para una llamada, y reparte en cuatro subestados
	djnz estado_2_sub1		;5312
	di			;5314   ; Bancos 9 y 10, que son los de la presentacion
	ld a,009h		;5315
	ld (08000h),a		;5317
	ld (0f0f2h),a		;531a
	ei			;531d
	di			;531e
	ld a,00ah		;531f
	ld (0a000h),a		;5321
	ld (0f0f3h),a		;5324
	ei			;5327
	call 0a88dh		;5328
	di			;532b   ; Y devueltos el 2 y el 3
	ld a,002h		;532c
	ld (08000h),a		;532e
	ld (0f0f2h),a		;5331
	ei			;5334
	di			;5335
	ld a,003h		;5336
	ld (0a000h),a		;5338
	ld (0f0f3h),a		;533b
	ei			;533e
	call sube_los_sprites_rotando		;533f
	call 0bdd2h		;5342
	ld a,(0e012h)		;5345   ; Mientras el canal de 0xE012 suene, se espera
	and a			;5348
	ret nz			;5349
	jr espera_treinta_y_dos		;534a
estado_2_sub1:		; Espera al mando y arranca lo de 0x5C88
	djnz estado_2_sub2		;534c
	call baja_la_cortinilla		;534e   ; Con el mando sin tocar, se sale por p
	ret p			;5351   ; Con el mando sin tocar se sale por p
	call arranca_la_demo		;5352
	jr sube_el_subestado		;5355
estado_2_sub2:		; Espera al mando y, si no hay aviso en 0xE05F, vuelve al estado 0
	djnz estado_2_sub3		;5357
	call corre_la_demo		;5359   ; Un paso de la demo
	ld a,(0e05fh)		;535c
	or a			;535f
	ret nz			;5360
vuelve_al_estado_0:		; Estado 0, subestado 0 y 0x20 cuadros de espera
	xor a			;5361
L_5362:
	ld (0e000h),a		;5362
	ld a,020h		;5365
	ld (0e004h),a		;5367
	jr L_53A8		;536a
estado_2_sub3:		; Espera al mando y arranca lo de 0x5BF8
	call baja_la_cortinilla		;536c   ; Otra vez el mando
	ret p			;536f
	call monta_la_pantalla_de_records		;5370
espera_treinta_y_dos:		; 0x20 cuadros en 0xE004 y al subestado siguiente
	ld a,020h		;5373
L_5375:
	ld (0e004h),a		;5375   ; Los cuadros de espera que traiga A
sube_el_subestado:		; 0xE001 + 1
	ld hl,0e001h		;5378
	inc (hl)			;537b
	ret			;537c
estado_3:		; Hace parpadear el rotulo de 0x5808 o el de 0x5812 -segun el bit 5 de 0xE002- escribiendolo y borrandolo
	djnz estado_3_sub1		;537d
	ld hl,0e004h		;537f
	dec (hl)			;5382
	jr z,sube_el_subestado		;5383
	ld a,(0e002h)		;5385   ; El bit 5 de 0xE002 elige entre los dos rotulos
	bit 5,a		;5388
	ld de,05808h		;538a
	jr z,L_5392		;538d
	ld de,05812h		;538f
L_5392:
	bit 2,(hl)		;5392   ; Un bit del contador: se escribe y se borra, y eso es el parpadeo
	jp z,escribe_caracteres		;5394
	jp borra_caracteres		;5397
estado_3_sub1:		; Llama a 0x5558 y se va al estado siguiente
	djnz estado_3_sub2		;539a
	call arranca_la_partida_entera		;539c
espera_treinta_y_dos_y_estado:		; 0x20 cuadros y al estado siguiente
	ld a,020h		;539f
L_53A1:
	ld (0e004h),a		;53a1
estado_siguiente:		; 0xE000 + 1 y el subestado a cero
	ld hl,0e000h		;53a4
	inc (hl)			;53a7
L_53A8:
	xor a			;53a8
	ld (0e001h),a		;53a9
	ret			;53ac
estado_3_sub2:		; 0x50 cuadros de espera
	ld a,050h		;53ad
	jr L_5375		;53af
estado_4:		; Borra el rotulo de 0x5820, pasa a la fase siguiente y enciende el aviso de 0xE05F
	djnz estado_4_sub1		;53b1   ; Al subestado 1 si no es el 0
	ld hl,0e004h		;53b3
	dec (hl)			;53b6
	ret nz			;53b7
	ld de,05820h		;53b8
	call borra_caracteres		;53bb
	call monta_la_fase_que_toque		;53be
	ld a,001h		;53c1
	ld (0e05fh),a		;53c3
	jr estado_siguiente		;53c6
estado_4_sub1:		; Quita una nave en BCD, mete los bancos 4/5/6 y descomprime los seis bloques de la pantalla de fase
	call baja_la_cortinilla		;53c8
	ret p			;53cb
	ld hl,0e060h		;53cc   ; 0xE060 son las naves, en BCD
	ld a,(hl)			;53cf
	sub 001h		;53d0
	daa			;53d2
	ld (hl),a			;53d3
	call carga_la_fuente_de_la_fase		;53d4
	di			;53d7   ; Bancos 4, 5 y 6
	push hl			;53d8   ; Bancos 4, 5 y 6 para leer los graficos de la fase
	ld hl,0f0f1h		;53d9
	ld a,004h		;53dc
	ld (06000h),a		;53de
	ld (hl),a			;53e1
	inc a			;53e2
	ld (08000h),a		;53e3
	inc hl			;53e6
	ld (hl),a			;53e7
	inc a			;53e8
	ld (0a000h),a		;53e9
	inc hl			;53ec
	ld (hl),a			;53ed
	pop hl			;53ee
	ei			;53ef
	ld hl,03058h		;53f0   ; Tres bloques de patrones: 0x3058, 0x30A8 y 0x3160
	ld de,06379h		;53f3
	call descomprime		;53f6
	ld hl,030a8h		;53f9
	ld de,062c7h		;53fc
	call descomprime		;53ff
	ld hl,03160h		;5402
	ld de,062c7h		;5405
	call descomprime		;5408
	ld hl,01058h		;540b   ; Y sus tres de colores: 0x1058, 0x10A8 y 0x1160
	ld de,07793h		;540e
	call descomprime		;5411
	ld hl,010a8h		;5414
	ld de,07674h		;5417
	call descomprime		;541a
	ld hl,01160h		;541d
	ld de,07703h		;5420
	call descomprime		;5423
	di			;5426   ; Devueltos el 1, el 2 y el 3
	push hl			;5427   ; El reparto de siempre otra vez
	ld hl,0f0f1h		;5428
	ld a,001h		;542b
	ld (06000h),a		;542d
	ld (hl),a			;5430
	inc a			;5431
	ld (08000h),a		;5432
	inc hl			;5435
	ld (hl),a			;5436
	inc a			;5437
	ld (0a000h),a		;5438
	inc hl			;543b
	ld (hl),a			;543c
	pop hl			;543d
	ei			;543e
	ld b,006h		;543f   ; Seis bytes de 0xE131, a cero
	ld hl,0e131h		;5441
L_5444:
	ld (hl),000h		;5444
	inc hl			;5446
	djnz L_5444		;5447
	call marca_si_hay_dos_jugadores		;5449
	call escribe_los_rotulos		;544c
	call carga_el_marcador_en_dos_tercios		;544f
	ld a,(0e002h)		;5452   ; El bit 5 de 0xE002 dice si hay dos jugadores
	and 020h		;5455
	ld a,010h		;5457   ; A uno solo, 0x10 cuadros
	jp z,L_5375		;5459
	call escribe_el_turno		;545c
	ld a,078h		;545f   ; Y a dos, 0x78: da tiempo a leer de quien es el turno
	jp L_5375		;5461
estado_5:		; El fotograma de juego con la pausa; mientras el aviso de 0xE05F este puesto, no se sale
	call mira_la_tecla_de_pausa		;5464
	ld a,(0e05fh)		;5467
	or a			;546a
	ret nz			;546b
	jp espera_treinta_y_dos_y_estado		;546c
estado_6:		; Sin naves se pide el sonido 0xCA; si el otro jugador aun tiene, se cambia el turno
	ld a,(0e060h)		;546f   ; 0xE060 son las naves del que juega
	or a			;5472
	jr z,L_5492		;5473
	ld a,(0e090h)		;5475   ; Y 0xE090 las del otro
	or a			;5478
	jr z,L_548D		;5479
cambia_de_jugador:		; Intercambia los 0x30 bytes de 0xE060 con los de 0xE090 y da la vuelta al bit del turno
	ld hl,0e060h		;547b   ; Se cambian los 0x30 bytes de estado de los dos jugadores
	ld de,0e090h		;547e
	ld b,030h		;5481
	call cambia_b_bytes		;5483
	ld hl,0e002h		;5486
	ld a,(hl)			;5489
	xor 080h		;548a   ; Y el bit 7 de 0xE002 se invierte: cambia el turno
	ld (hl),a			;548c
L_548D:
	ld a,004h		;548d   ; Estado 4: a montar la fase
	jp L_5362		;548f
L_5492:
	ld a,0cah		;5492   ; El sonido 0xCA: el final de la partida
	call pide_sonido		;5494
	jp espera_treinta_y_dos_y_estado		;5497
estado_7:		; El final: espera al sonido y, si se ha pedido continuar, devuelve tres naves y sigue
	djnz estado_7_sub1		;549a
	call mira_si_se_pide_continuar		;549c
	ld a,(0e012h)		;549f   ; Hasta que 0xE012 no calle, no se sigue
	or a			;54a2
	ret nz			;54a3
	ld a,(0e06fh)		;54a4   ; 0xE06F: se ha pedido continuar
	and a			;54a7
	jr z,L_54C3		;54a8
	ld hl,0e05bh		;54aa
	ld a,(0e002h)		;54ad   ; El bit 7 de 0xE002 dice de que jugador es el marcador
	and 080h		;54b0
	jr z,L_54B6		;54b2
	ld l,057h		;54b4
L_54B6:
	xor a			;54b6   ; Los cuatro bytes del marcador, a cero
	ld (hl),a			;54b7
	inc l			;54b8
	ld (hl),a			;54b9
	inc l			;54ba
	ld (hl),a			;54bb
	inc l			;54bc
	ld (hl),a			;54bd
	ld a,003h		;54be   ; Y tres naves otra vez
	ld (0e060h),a		;54c0
L_54C3:
	ld a,(0e090h)		;54c3   ; Si al otro jugador le quedan, se cambia el turno
	or a			;54c6
	jr nz,cambia_de_jugador		;54c7
	ld a,(0e06fh)		;54c9
	and a			;54cc
	jr nz,L_548D		;54cd
	ld hl,0e002h		;54cf   ; Y si no, se apaga el bit 6 de 0xE002 y a la presentacion
	ld a,(hl)			;54d2
	and 0bfh		;54d3
	ld (hl),a			;54d5
	jp vuelve_al_estado_0		;54d6
estado_7_sub1:		; Escribe el rotulo de 0x5836 y se queda esperando a que se pida continuar
	call baja_la_cortinilla		;54d9   ; Con el mando sin tocar, se sale por p
	ret p			;54dc
	call carga_el_marcador_en_dos_tercios		;54dd
	ld de,05836h		;54e0
	call escribe_caracteres		;54e3
	call escribe_el_turno		;54e6
	call escribe_los_rotulos		;54e9
	xor a			;54ec
	ld (0e06fh),a		;54ed
	jp L_5375		;54f0
mira_si_se_pide_continuar:		; El bit 1 de la fila 7 del teclado: al pulsarlo, 0xE06F a uno y se borra el rotulo de 0x5843
	ld a,007h		;54f3
	call 00141h		;54f5   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix | SNSMAT de la fila 7
	bit 1,a		;54f8   ; Sin pulsar, el bit esta a uno
	ret nz			;54fa
	ld a,001h		;54fb
	ld (0e06fh),a		;54fd
	ld de,05843h		;5500
	jp borra_caracteres		;5503
vuelta_de_los_estados:		; Aqui vuelven los estados: 0x52B7 mete esta direccion en la pila antes del despacho.
	call lee_el_mando_sin_guardar		;5506
	ld hl,0e051h		;5509   ; 0xE051 y 0xE052: lo que se ha pulsado en la presentacion
	call lo_recien_pulsado		;550c
	or a			;550f
	ret z			;5510
	ld hl,0e004h		;5511
	ld (hl),000h		;5514
	ld l,(hl)			;5516
	ld de,0e052h		;5517
	ld b,(hl)			;551a
	djnz L_5536		;551b
	and 030h		;551d   ; Los bits 4 y 5: uno o dos jugadores
	jr z,L_5540		;551f
	ld a,(de)			;5521   ; A un jugador, 0x40 en 0xE002; a dos, 0x60
	or a			;5522
	ld a,040h		;5523
	jr z,L_5529		;5525
	ld a,060h		;5527
L_5529:
	ld (0e002h),a		;5529
	ld (hl),003h		;552c   ; Estado 3
	inc hl			;552e
	ld c,000h		;552f
	ld (hl),c			;5531
	dec c			;5532
	jp L_5BDD		;5533
L_5536:
	ld (hl),001h		;5536   ; Sin eleccion, el sonido 0xCD
	ld a,0cdh		;5538
	call pide_sonido		;553a
	jp escribe_el_panel_del_titulo		;553d
L_5540:
	ld a,(de)			;5540   ; Y el bit de 0xE052 se invierte: cambia lo elegido
	xor 001h		;5541
	ld (de),a			;5543
	ret			;5544
escribe_el_turno:		; Con dos jugadores, el rotulo de 0x5820 o el de 0x582B segun de quien sea el turno
	ld a,(0e002h)		;5545
	bit 5,a		;5548   ; Bit 5 de 0xE002: solo con dos jugadores
	ret z			;554a
	ld de,05820h		;554b
	and 080h		;554e   ; Y el bit 7 dice cual de los dos
	jr z,L_5555		;5550
	ld de,0582bh		;5552
L_5555:
	jp escribe_caracteres		;5555
arranca_la_partida_entera:		; Borra los 0xFA9 bytes de 0xE057, deja tres naves y un aviso, el premio en 0x0010, y con dos jugadores copia todo al segundo
	ld hl,0e057h		;5558   ; Los 0xFA9 bytes desde 0xE057, a cero
	ld bc,00fa9h		;555b
	ld d,h			;555e
	ld e,l			;555f
	inc e			;5560
	ld (hl),000h		;5561
	ldir		;5563
	ld hl,05588h		;5565   ; Tres naves y el aviso, de 0x5588
	ld de,0e060h		;5568
	ld bc,00002h		;556b
	ldir		;556e
	ld hl,00010h		;5570   ; 0x0010 en 0xE067: el primer premio de nave
	ld (0e067h),hl		;5573
	ld a,(0e002h)		;5576   ; Con dos jugadores...
	and 020h		;5579
	ret z			;557b
	ld hl,0e060h		;557c   ; ...los 0x30 bytes de estado se copian tambien al segundo
	ld de,0e090h		;557f
	ld bc,00030h		;5582
	ldir		;5585
	ret			;5587

; ----------------------------------------------------------------------
; DATOS dos_bytes_a_e060: Dos bytes (0x03, 0x01) que 0x5565 copia a 0xE060 con
;   LDIR.
;   0x5588..0x558a  (2 bytes)
DATA_dos_bytes_a_e060:
	defb 003h,001h	; 5588

; ======================================================================
; CODIGO 0x558a..0x56d9  (335 bytes)
; ======================================================================


baja_la_cortinilla:		; Baja 0xE004 y, por cada cuadro, borra una fila de la pantalla de abajo arriba; sale con signo cuando se acaba
	ld hl,0e004h		;558a
	dec (hl)			;558d   ; Al llegar por debajo de cero, se acabo la cortinilla
	ret m			;558e
	ld a,(hl)			;558f
	ld h,038h		;5590   ; La fila sale de 0xE004 al reves: 0x1F menos la cuenta
	xor 01fh		;5592
	ld l,a			;5594
	ld b,016h		;5595   ; Veintidos filas de alto
	ld a,(0e000h)		;5597   ; En el estado 2 son veinticuatro
	cp 002h		;559a
	jr nz,L_55A0		;559c
	ld b,018h		;559e
L_55A0:
	xor a			;55a0
	ld de,00020h		;55a1   ; 0x20: la fila siguiente
L_55A4:
	call 0004dh		;55a4   ; BIOS WRTVRM - Writes data in VRAM
	add hl,de			;55a7
	djnz L_55A4		;55a8
quita_los_sprites_de_la_pantalla:		; Escribe 0xD0 en la VRAM 0x3B00: el atributo que le dice al VDP que ahi se acaban los sprites.
	ld hl,03b00h		;55aa
	ld a,0d0h		;55ad
	call 0004dh		;55af   ; BIOS WRTVRM - Writes data in VRAM
	xor a			;55b2
	ret			;55b3
suma_a_la_puntuacion:		; Suma en BCD (lleva `daa`) sobre el marcador del jugador que dice 0xE002.
	ld a,(0e002h)		;55b4   ; El bit 6 de 0xE002 dice si hay partida
	add a,a			;55b7
	ret p			;55b8
	ld hl,0e05ch		;55b9   ; 0xE05C es el marcador del jugador 1 y 0xE058 el del 2
	jr nc,L_55C0		;55bc
	ld l,058h		;55be
L_55C0:
	ld a,(hl)			;55c0
	add a,e			;55c1
	daa			;55c2   ; El `daa`: la puntuacion va en BCD, tres bytes
	ld (hl),a			;55c3
	inc l			;55c4
	ld a,(hl)			;55c5
	adc a,d			;55c6
	daa			;55c7
	ld (hl),a			;55c8
	inc hl			;55c9
	ld a,(hl)			;55ca
	adc a,000h		;55cb
	daa			;55cd
	ld (hl),a			;55ce
	jr nc,L_55DB		;55cf
	ld hl,09999h		;55d1   ; Pasados los seis nueves, se clava en 999999
	ld (0e054h),hl		;55d4
	ld (0e055h),hl		;55d7
	ret			;55da
L_55DB:
	ld d,(hl)			;55db
	dec l			;55dc
	ld e,(hl)			;55dd
	ld hl,(0e067h)		;55de   ; 0xE067 es el proximo premio de nave
	ex de,hl			;55e1
	rst 20h			;55e2   ; DCOMPR: compara la puntuacion con el premio
	jr c,L_55F8		;55e3
	ld a,010h		;55e5   ; 0x1000 mas en BCD: el premio siguiente
	add a,e			;55e7
	daa			;55e8
	ld e,a			;55e9
	ld a,d			;55ea
	adc a,000h		;55eb
	daa			;55ed
	ld d,a			;55ee
	jr c,$+5		;55ef
	ld (0e067h),de		;55f1
	call regala_una_nave		;55f5
L_55F8:
	ld a,(0e002h)		;55f8   ; Y de aqui abajo, el record
	add a,a			;55fb
	ld hl,0e05eh		;55fc
	jr nc,L_5603		;55ff
	ld l,05ah		;5601
L_5603:
	ld b,003h		;5603   ; Tres bytes, del mas alto al mas bajo
	ld de,0e056h		;5605
	ld c,l			;5608
L_5609:
	ld a,(de)			;5609   ; Si la puntuacion pasa al record...
	sub (hl)			;560a
	jr c,L_5613		;560b
	ret nz			;560d
	dec l			;560e
	dec e			;560f
	djnz L_5609		;5610
	ret			;5612
L_5613:
	ld l,c			;5613   ; ...el record se copia entero
	ld bc,00003h		;5614
	ld e,056h		;5617
	lddr		;5619
	ret			;561b
regala_una_nave:		; Sube una nave en BCD, y si no hay explosion en marcha suena el aviso
	ld hl,0e060h		;561c
	ld a,(hl)			;561f   ; Una mas, en BCD
	add a,001h		;5620
	daa			;5622
	ret c			;5623   ; Pasadas las noventa y nueve no se regala nada
	ld (hl),a			;5624
	ld a,(0e1d0h)		;5625   ; Con explosion en marcha, no suena
	and a			;5628
	ret nz			;5629
	ld a,015h		;562a   ; El sonido 0x15
	call mira_si_hay_sonido		;562c
	jp pinta_las_naves		;562f
escribe_los_rotulos:		; Escribe con 0x4998 los mensajes de 0x57CE, 0x57E1 y 0x57E6.
	ld de,057ceh		;5632
	call escribe_caracteres		;5635
	ld a,(0e002h)		;5638   ; El bit 7 de 0xE002 elige entre el rotulo 1P y el 2P
	ld de,057e1h		;563b
	add a,a			;563e
	jr nc,L_5644		;563f
	ld de,057e6h		;5641
L_5644:
	call escribe_caracteres		;5644
	call pinta_las_naves		;5647
	call pinta_el_medidor_de_mejoras		;564a
pinta_los_marcadores:		; El record en la fila 23 y el marcador del jugador que toque, tres bytes en BCD cada uno
	ld de,0e056h		;564d   ; 0xE056: el record
	ld hl,03af6h		;5650   ; Fila 23, columna 22
	call L_5664		;5653
	ld a,(0e002h)		;5656   ; Y el marcador del jugador de turno
	ld hl,03aeah		;5659
	ld de,0e05eh		;565c
	add a,a			;565f
	jr nc,L_5664		;5660
	ld e,05ah		;5662   ; 0xE05A si es el segundo
L_5664:
	ld b,003h		;5664
	jr escribe_las_cifras		;5666
pinta_las_naves:		; La cifra de las naves; con menos de diez se apaga la de las decenas
	ld hl,03ae3h		;5668   ; Fila 23, columna 3
	ld de,0e060h		;566b
	ld a,(de)			;566e
	ld b,001h		;566f
	and 0f0h		;5671   ; Con el nibble alto a cero solo se pinta una cifra
	jr nz,escribe_las_cifras		;5673   ; Fila 23, columna 3: la cifra de las naves
	call pon_escritura_vram		;5675
	exx			;5678
	ld a,c			;5679   ; El puerto de datos, que 0x494A dejo en el C alternativo
	exx			;567a
	ld c,a			;567b
	xor a			;567c
	out (c),a		;567d
	inc hl			;567f
	jr L_5693		;5680
escribe_las_cifras:		; Saca los digitos BCD por el puerto de datos, del mas bajo al mas alto y de dos en dos por byte
	call pon_escritura_vram		;5682
	exx			;5685
	ld a,c			;5686
	exx			;5687   ; Y la misma cuenta para las cifras del marcador
	ld c,a			;5688
L_5689:
	ld a,(de)			;5689   ; El nibble alto...
	rra			;568a
	rra			;568b
	rra			;568c
	rra			;568d
	and 00fh		;568e
	inc a			;5690
	out (c),a		;5691
L_5693:
	ld a,(de)			;5693   ; ...y el bajo
	and 00fh		;5694
	inc a			;5696   ; Mas uno: el caracter del cero no es el 0
	out (c),a		;5697
	dec de			;5699
	djnz L_5689		;569a
	ret			;569c
pinta_el_medidor_de_mejoras:		; Las seis casillas del medidor de la fila 22, cada una con sus cuatro caracteres
	ld hl,03ac4h		;569d   ; Fila 22, columna 4
	call pon_escritura_vram		;56a0
	ld hl,0e131h		;56a3   ; Seis casillas desde 0xE131
	ld bc,00601h		;56a6
L_56A9:
	push bc			;56a9   ; Seis casillas del medidor
	call pinta_una_casilla_del_medidor		;56aa
	pop bc			;56ad
	inc c			;56ae
	djnz L_56A9		;56af
	ret			;56b1
pinta_una_casilla_del_medidor:		; Los cuatro caracteres de esa casilla, apagados o encendidos, y en otro juego si es la elegida
	ld a,c			;56b2
	add a,a			;56b3   ; Por ocho: ocho bytes por casilla
	add a,a			;56b4
	add a,a			;56b5
	ld de,l56d1h		;56b6
	call suma_a_a_de		;56b9
	ld a,(hl)			;56bc
	inc hl			;56bd
	and a			;56be   ; Con el byte a cero, la casilla va apagada
	jr z,L_56C4		;56bf
	ld de,05709h		;56c1
L_56C4:
	ld a,(0e130h)		;56c4   ; Y 0xE130 dice cual esta elegida: esa lleva los otros cuatro
	cp c			;56c7
	jr nz,L_56CE		;56c8
	inc de			;56ca
	inc de			;56cb
	inc de			;56cc
	inc de			;56cd
L_56CE:
	ld b,004h		;56ce   ; Cuatro caracteres por casilla
L_56D0:
	ld a,(de)			;56d0
L_56D1:
	exx			;56d1   ; El caracter, por el puerto de datos
	out (c),a		;56d2
	exx			;56d4
	inc de			;56d5
	djnz L_56D0		;56d6
	ret			;56d8

; ----------------------------------------------------------------------
; DATOS pares_de_5709 (tramo): Filas de ocho bytes que 0x56B6 indexa con el
;   valor por ocho.
;   0x56d9..0x5709  (48 bytes)  de 0x56d1..0x5709 (56 bytes)
DATA_pares_de_5709_56D9:
	defb 015h,016h,017h,018h,02ch,02dh,02eh,02fh	; 56d9  ....,-./
	defb 019h,01ah,01bh,01ch,030h,031h,032h,033h	; 56e1  ....0123
	defb 01dh,01eh,01fh,020h,034h,035h,036h,037h	; 56e9  ... 4567
	defb 021h,022h,023h,024h,038h,039h,03ah,03bh	; 56f1  !"#$89:;
	defb 025h,026h,027h,028h,03ch,03dh,03eh,03fh	; 56f9  %&'(<=>?
	defb 02bh,029h,02ah,02bh,042h,040h,041h,042h	; 5701  +)*+B@AB

; ----------------------------------------------------------------------
; DATOS fila_alternativa: La fila de ocho bytes a la que 0x56C1 cambia cuando
;   el byte anterior no es cero.
;   0x5709..0x5711  (8 bytes)
DATA_fila_alternativa:
	defb 02bh,02bh,02bh,00ch,042h,042h,042h,042h	; 5709  +++.BBBB

; ======================================================================
; CODIGO 0x5711..0x575a  (73 bytes)
; ======================================================================


cambia_b_bytes:		; Intercambia B bytes entre HL y DE, uno a uno
	ld c,(hl)			;5711   ; B bytes, uno a uno
	ld a,(de)			;5712
	ld (hl),a			;5713
	ld a,c			;5714
	ld (de),a			;5715
	inc hl			;5716
	inc de			;5717
	djnz cambia_b_bytes		;5718
	ret			;571a
casilla_a_direccion_de_ram:		; De la casilla de pantalla que hay en HL saca la direccion del mapa en RAM: fila por 0x20 mas columna, sobre 0xED00
	ld a,l			;571b
	rra			;571c
	rra			;571d
	rra			;571e
	rra			;571f
	rr h		;5720   ; Cuatro desplazamientos de HL entero: se parte por dieciseis
	rra			;5722
	rr h		;5723
	rra			;5725
	rr h		;5726
	ld l,h			;5728
	and 003h		;5729   ; Los dos bits que quedan...
	add a,0edh		;572b   ; ...mas 0xED: el mapa vive de 0xED00 a 0xEFFF
	ld h,a			;572d
	ret			;572e
arranca_la_maquina:		; Calla el PSG, pide el sonido 0xCD, borra los 16 KB de VRAM y programa los ocho registros
	ld a,0b8h		;572f   ; 0xB8 en el registro 7 del PSG: los tres canales callados
	ld (0e043h),a		;5731
	ld e,a			;5734
	ld a,007h		;5735
	call 00093h		;5737   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,0cdh		;573a   ; El sonido 0xCD
	call pide_sonido		;573c
	ld hl,00000h		;573f   ; Los 0x4000 bytes de la VRAM, a cero
	ld bc,04000h		;5742
	xor a			;5745
	call 00056h		;5746   ; BIOS FILVRM - Fills VRAM with value

; ----------------------------------------------------------------------
; EL CARTUCHO LE DA LA VUELTA AL MAPA DE LA VRAM
; Los ocho bytes de 0x575A son 0x02, 0xE2, 0x0E, 0x7F, 0x07, 0x76, 0x03 y
; 0xE4, y no dejan la VRAM donde la deja la BIOS. El registro 4 vale 0x07,
; asi que los PATRONES viven en 0x2000; el 3 vale 0x7F, asi que los
; COLORES viven en 0x0000 -justo al reves de lo normal-; el 2 vale 0x0E,
; que pone la tabla de nombres en 0x3800; el 5 vale 0x76, que pone los
; atributos de sprite en 0x3B00, pegados detras de los nombres; y el 6
; vale 0x03, que pone los patrones de sprite en 0x1800. Quien lea las
; direcciones de este listado esperando el reparto de la BIOS se
; equivocara en todas.
; ----------------------------------------------------------------------
programa_el_vdp:		; Los ocho valores de 0x575A a los registros 0 a 7, con WRTVDP
	ld hl,0575ah		;5749
	ld d,008h		;574c   ; Ocho registros
	ld c,000h		;574e
L_5750:
	ld b,(hl)			;5750
	call 00047h		;5751   ; BIOS WRTVDP - Writes data in the VDP-register
	inc hl			;5754
	inc c			;5755
	dec d			;5756
	jr nz,L_5750		;5757
	ret			;5759

; ----------------------------------------------------------------------
; DATOS registros_del_vdp: Los ocho valores con los que 0x5749 programa los
;   registros 0 a 7 del VDP, uno detras de otro, llamando a WRTVDP (0x0047)
;   con B = el valor y C = el numero de registro. Salen de ahi: patrones en
;   0x2000, colores en 0x0000, nombres en 0x3800, atributos de sprite en
;   0x3B00 y patrones de sprite en 0x1800.
;   0x575a..0x5762  (8 bytes)
DATA_registros_del_vdp:
	defb 002h,0e2h,00eh,07fh,007h,076h,003h,0e4h	; 575a  .....v..

; ======================================================================
; CODIGO 0x5762..0x57bd  (91 bytes)
; ======================================================================


pon_el_color_del_borde:		; Escribe B en el registro 7 del VDP: el color del borde y del fondo
	ld c,007h		;5762
	jp L_405A		;5764
lee_el_mando:		; Junta joystick y teclado en 0xE009 y deja en 0xE008 lo que acaba de pulsarse
	call junta_joystick_y_teclado		;5767
	ld hl,0e009h		;576a
lo_recien_pulsado:		; Guarda lo de ahora y, con un xor y un and, deja en el byte de al lado solo lo que acaba de bajar
	ld c,(hl)			;576d   ; Lo que ha cambiado y esta puesto: lo recien pulsado
	ld (hl),a			;576e
	xor c			;576f
	and (hl)			;5770
	dec hl			;5771
	ld (hl),a			;5772
	ret			;5773
lee_el_mando_sin_guardar:		; Lo mismo pero sin apuntarlo: se usa desde la vuelta de los estados
	ld e,08fh		;5774
	call lee_el_joystick		;5776
	and 03fh		;5779   ; Los seis bits bajos: cuatro flechas y dos disparos
	jr L_5784		;577b
junta_joystick_y_teclado:		; Lee el joystick del puerto 1 por el PSG y le suma las teclas de las filas 4 y 8, corridas hasta los mismos bits
	ld e,08fh		;577d
	call lee_el_joystick		;577f
	and 03fh		;5782
L_5784:
	push af			;5784
	ld a,004h		;5785
	call 00141h		;5787   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix | SNSMAT de la fila 4
	cpl			;578a
	and 00ch		;578b   ; Sus bits 2 y 3
	ld e,a			;578d
	jr z,junta_la_fila_ocho		;578e
	ld e,020h		;5790
junta_la_fila_ocho:		; Coge de la fila 8 del teclado las flechas y el espacio y las corre hasta los bits del joystick
	ld a,008h		;5792   ; SNSMAT de la fila 8
	call 00141h		;5794   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix | Y la fila 8, la de las flechas y el espacio
	cpl			;5797
	rrca			;5798   ; Corrida dos veces: los bits caen donde el joystick
	rrca			;5799
	ld b,a			;579a
	and 004h		;579b   ; El bit del espacio
	or e			;579d
	ld c,a			;579e
	ld a,b			;579f
	rrca			;57a0
	rrca			;57a1
	ld b,a			;57a2
	and 018h		;57a3   ; Las dos flechas de en medio
	or c			;57a5
	ld c,a			;57a6
	ld a,b			;57a7
	rrca			;57a8
	and 003h		;57a9   ; Y las otras dos
	or c			;57ab
	pop bc			;57ac
	or b			;57ad
	ret			;57ae
lee_el_joystick:		; El registro 15 del PSG elige el puerto y el 14 lo lee; llega al reves, y por eso el cpl
	ld a,00fh		;57af
	call 00093h		;57b1   ; BIOS WRTPSG - Writes data to PSG-register | El 15 elige el puerto
	ld a,00eh		;57b4
	di			;57b6
	call 00096h		;57b7   ; BIOS RDPSG - Reads value from PSG-register | Y el 14 trae las flechas y los disparos
	ei			;57ba
	cpl			;57bb   ; Un cpl: en el PSG lo pulsado es un cero
	ret			;57bc

; ----------------------------------------------------------------------
; DATOS mensajes: Los textos de la pantalla, con SUS PROPIOS CODIGOS DE
;   CARACTER: 0x00 es el espacio, 0x10 a 0x19 son las cifras 0 a 9 y 0x21 a
;   0x3A las letras (o sea, ASCII menos 0x20). Se leen con dos rutinas
;   distintas, y las dos empiezan cogiendo del propio flujo la direccion de
;   VRAM: 0x4998 escribe caracter a caracter (0xFE = viene otra direccion,
;   0xFF = fin) y 0x49B3 los descomprime con el formato de 0x49B9. Por ahi
;   salen "software", "konami", "1986", "play select", "1 player", "2
;   players", "player 1", "player 2", "game over" y "continue". Cada mensaje
;   empieza donde lo pide su llamador: 0x57BD (0x52E2, comprimido), 0x57CE
;   (0x5632), 0x57E1 (0x563B), 0x57E6 (0x5641), 0x57EB (0x5BCA), 0x5808
;   (0x538A), 0x5812 (0x538F), 0x581D (0x5BF1), 0x5820 (0x53B8 y 0x554B),
;   0x582B (0x5552) y 0x5836 (0x54E0).
;   0x57bd..0x5851  (148 bytes)
DATA_mensajes:
	defb 04ah,039h,00ch,05ah,080h,06ch,039h,088h,033h,02fh,026h,034h,037h,021h,032h,025h	; 57bd  J9.Z.l9.3/&47!2%
	defb 000h,0f3h,03ah,00eh,00fh,0feh,0e2h,03ah,00bh,0feh,0f0h,03ah,001h,001h,0feh,0fch	; 57cd  ..:....:...:....
	defb 03ah,001h,001h,0ffh,0e7h,03ah,002h,012h,0ffh,0e7h,03ah,003h,012h,0ffh,04ah,039h	; 57dd  :....:....:...J9
	defb 01ah,02bh,02fh,02eh,021h,02dh,029h,000h,011h,019h,018h,016h,0feh,0cbh,039h,030h	; 57ed  .+/.!-).......90
	defb 02ch,021h,039h,000h,033h,025h,02ch,025h,023h,034h,0feh,02dh,03ah,011h,030h,02ch	; 57fd  ,!9.3%,%#4.-:.0,
	defb 021h,039h,025h,032h,0ffh,06dh,03ah,012h,030h,02ch,021h,039h,025h,032h,033h,0ffh	; 580d  !9%2.m:.0,!9%23.
	defb 01bh,01ch,0ffh,00ch,039h,030h,02ch,021h,039h,025h,032h,000h,011h,0ffh,00ch,039h	; 581d  ....90,!9%2....9
	defb 030h,02ch,021h,039h,025h,032h,000h,012h,0ffh,04bh,039h,027h,021h,02dh,025h,000h	; 582d  0,!9%2...K9'!-%.
	defb 000h,02fh,036h,025h,032h,0feh,08bh,039h,023h,02fh,02eh,034h,029h,02eh,035h,025h	; 583d  ./6%2..9#/.4).5%
	defb 000h,026h,015h,0ffh	; 584d

; ======================================================================
; CODIGO 0x5851..0x58fd  (172 bytes)
; ======================================================================


carga_el_marcador:		; Vuelca en la VRAM 0x2080 y 0x2100 los patrones de 0x5906 y 0x596E, por los tres tercios.
	ld de,05906h		;5851   ; Los 104 bytes de 0x5906: las cifras y las letras del marcador
	ld hl,02080h		;5854
	ld bc,00068h		;5857
	call vuelca_tres_tercios		;585a
	ld de,0596eh		;585d   ; Y los 216 de 0x596E, que son el resto de la fuente
	ld hl,02100h		;5860
	ld bc,000d8h		;5863
	call vuelca_tres_tercios		;5866
	ld a,0f0h		;5869   ; 0xF0 en 0x158 casillas de color: blanco sobre transparente
	ld hl,00080h		;586b
	ld bc,00158h		;586e
	jp llena_tres_tercios		;5871
carga_el_marcador_en_dos_tercios:		; Lo mismo que 0x5851 pero solo en el primero y el segundo tercio, y esta vez de uno en uno
	ld de,05906h		;5874
	ld hl,02080h		;5877
	ld bc,00068h		;587a
	call vuelca_a_vram		;587d
	ld de,0596eh		;5880
	ld hl,02100h		;5883
	ld bc,000d8h		;5886
	call vuelca_a_vram		;5889
	ld a,0f0h		;588c
	ld hl,00080h		;588e
	ld bc,00158h		;5891
	call 00056h		;5894   ; BIOS FILVRM - Fills VRAM with value
	ld de,05906h		;5897   ; Y otra vez en el segundo tercio, en 0x2880
	ld hl,02880h		;589a
	ld bc,00068h		;589d
	call vuelca_a_vram		;58a0
	ld de,0596eh		;58a3
	ld hl,02900h		;58a6
	ld bc,000d8h		;58a9
	call vuelca_a_vram		;58ac
	ld a,0f0h		;58af
	ld hl,00880h		;58b1
	ld bc,00158h		;58b4
	jp 00056h		;58b7   ; BIOS FILVRM - Fills VRAM with value
carga_la_fuente_de_la_fase:		; Deja en blanco 0x90 casillas de color del tercer tercio y sube ahi las cifras y los nueve caracteres de 0x58FD
	ld hl,01008h		;58ba   ; 0x50 casillas de color a blanco...
	ld bc,00050h		;58bd
	ld a,0f0h		;58c0
	call 00056h		;58c2   ; BIOS FILVRM - Fills VRAM with value
	ld hl,01068h		;58c5   ; ...y 0x40 mas
	ld bc,00040h		;58c8
	ld a,0f0h		;58cb
	call 00056h		;58cd   ; BIOS FILVRM - Fills VRAM with value
	ld de,05906h		;58d0   ; Las cifras, en la VRAM 0x3008
	ld hl,03008h		;58d3
	ld bc,00050h		;58d6
	call vuelca_a_vram		;58d9
	ld hl,03068h		;58dc   ; Y de aqui abajo, los caracteres sueltos de la lista de 0x58FD
	call pon_escritura_vram		;58df
	exx			;58e2
	ld hl,058fdh		;58e3
sube_los_caracteres_sueltos:		; Por cada numero de la lista, sus ocho bytes de 0x596E; el 0x00 la acaba
	ld a,(hl)			;58e6
	inc hl			;58e7
	and a			;58e8   ; El 0x00 acaba la lista
	ret z			;58e9
	add a,a			;58ea   ; Por ocho: ocho bytes por caracter
	add a,a			;58eb
	add a,a			;58ec
	ld de,0596eh		;58ed
	call suma_a_a_de		;58f0
	ld b,008h		;58f3   ; Ocho bytes por el puerto de datos
L_58F5:
	ld a,(de)			;58f5
	inc de			;58f6
	out (c),a		;58f7
	djnz L_58F5		;58f9
	jr sube_los_caracteres_sueltos		;58fb

; ----------------------------------------------------------------------
; DATOS orden_de_dibujo: Nueve bytes que 0x58E3 recorre despues de poner la
;   VRAM en 0x3068.
;   0x58fd..0x5906  (9 bytes)
DATA_orden_de_dibujo:
	defb 007h,008h,009h,00dh,00fh,010h,012h,016h,000h	; 58fd  .........

; ----------------------------------------------------------------------
; DATOS patrones_2080: Ciento cuatro bytes en crudo que 0x585A pasa a 0x4964
;   con HL=0x2080: se copian a los tres tercios.
;   0x5906..0x596e  (104 bytes)
DATA_patrones_2080:
	defb 000h,01ch,022h,063h,063h,063h,022h,01ch	; 5906  .."ccc".
	defb 000h,018h,038h,018h,018h,018h,018h,07eh	; 590e  ..8....~
	defb 000h,03eh,063h,003h,00eh,03ch,070h,07fh	; 5916  .>c..<p.
	defb 000h,03eh,063h,003h,00eh,003h,063h,03eh	; 591e  .>c...c>
	defb 000h,00eh,01eh,036h,066h,066h,07fh,006h	; 5926  ...6ff..
	defb 000h,07fh,060h,07eh,063h,003h,063h,03eh	; 592e  ..`~c.c>
	defb 000h,03eh,063h,060h,07eh,063h,063h,03eh	; 5936  .>c`~cc>
	defb 000h,07fh,063h,006h,00ch,018h,018h,018h	; 593e  ..c.....
	defb 000h,03eh,063h,063h,03eh,063h,063h,03eh	; 5946  .>cc>cc>
	defb 000h,03eh,063h,063h,03fh,003h,063h,03eh	; 594e  .>cc?.c>
	defb 03ch,042h,099h,0a1h,0a1h,099h,042h,03ch	; 5956  <B....B<
	defb 0c0h,060h,078h,07eh,0bfh,0bfh,07fh,0f0h	; 595e  .`x~....
	defb 000h,000h,000h,000h,0e0h,0feh,080h,000h	; 5966  ........

; ----------------------------------------------------------------------
; DATOS patrones_2100: Doscientos diecisiete bytes en crudo que 0x5866 pasa a
;   0x4964 con HL=0x2100.
;   0x596e..0x5a46  (216 bytes)
DATA_patrones_2100:
	defb 000h,000h,000h,000h,07eh,000h,000h,000h	; 596e  ....~...
	defb 000h,01ch,036h,063h,063h,07fh,063h,063h	; 5976  ..6cc.cc
	defb 000h,07eh,063h,063h,07eh,063h,063h,07eh	; 597e  .~cc~cc~
	defb 000h,03eh,063h,060h,060h,060h,063h,03eh	; 5986  .>c```c>
	defb 000h,07ch,066h,063h,063h,063h,066h,07ch	; 598e  .|fcccf|
	defb 000h,07fh,060h,060h,07eh,060h,060h,07fh	; 5996  ..``~``.
	defb 000h,07fh,060h,060h,07eh,060h,060h,060h	; 599e  ..``~```
	defb 000h,03eh,063h,060h,067h,063h,063h,03fh	; 59a6  .>c`gcc?
	defb 000h,063h,063h,063h,07fh,063h,063h,063h	; 59ae  .ccc.ccc
	defb 000h,03ch,018h,018h,018h,018h,018h,03ch	; 59b6  .<.....<
	defb 000h,01fh,006h,006h,006h,006h,066h,03ch	; 59be  ......f<
	defb 000h,063h,066h,06ch,078h,07ch,06eh,067h	; 59c6  .cflx|ng
	defb 000h,060h,060h,060h,060h,060h,060h,07fh	; 59ce  .``````.
	defb 000h,063h,077h,07fh,07fh,06bh,063h,063h	; 59d6  .cw..kcc
	defb 000h,063h,073h,07bh,07fh,06fh,067h,063h	; 59de  .cs{.ogc
	defb 000h,03eh,063h,063h,063h,063h,063h,03eh	; 59e6  .>ccccc>
	defb 000h,07eh,063h,063h,063h,07eh,060h,060h	; 59ee  .~ccc~``
	defb 000h,03eh,063h,063h,063h,06fh,066h,03dh	; 59f6  .>cccof=
	defb 000h,07eh,063h,063h,062h,07ch,066h,063h	; 59fe  .~ccb|fc
	defb 000h,03eh,063h,060h,03eh,003h,063h,03eh	; 5a06  .>c`>.c>
	defb 000h,07eh,018h,018h,018h,018h,018h,018h	; 5a0e  .~......
	defb 000h,063h,063h,063h,063h,063h,063h,03eh	; 5a16  .cccccc>
	defb 000h,063h,063h,063h,063h,036h,01ch,008h	; 5a1e  .cccc6..
	defb 000h,063h,063h,06bh,06bh,07fh,077h,022h	; 5a26  .cckk.w"
	defb 000h,063h,076h,03ch,01ch,01eh,037h,063h	; 5a2e  .cv<..7c
	defb 000h,066h,066h,07eh,03ch,018h,018h,018h	; 5a36  .ff~<...
	defb 000h,07fh,007h,00eh,01ch,038h,070h,07fh	; 5a3e  .....8p.

; ======================================================================
; CODIGO 0x5a46..0x5a9a  (84 bytes)
; ======================================================================


arranca_la_cortinilla_del_logo:		; 0x0E pasos en 0xE00A y el cursor en la fila 21, columna 10: por ahi empieza a subir el logotipo
	ld a,00eh		;5a46
	ld (0e00ah),a		;5a48   ; Catorce filas
	ld hl,03aaah		;5a4b   ; Fila 21, columna 10
	ld (0e00eh),hl		;5a4e
	jp salta_a_la_presentacion		;5a51
presentacion:		; Descomprime el logotipo de 0x5A9A en los tres tercios de la VRAM 0x6200 y deja sus 0xD8 colores en blanco
	ld de,05a9ah		;5a54
	ld hl,06200h		;5a57
	call descomprime_tres_tercios		;5a5a
	ld hl,00200h		;5a5d
	ld bc,000d8h		;5a60
	ld a,0f0h		;5a63   ; 0xF0: blanco sobre transparente
	jp llena_tres_tercios		;5a65
sube_el_logotipo:		; Una fila mas arriba por llamada: pinta las tres tiras de caracteres del logotipo y borra la de debajo
	ld hl,(0e00eh)		;5a68
	ld de,0ffe0h		;5a6b   ; El cursor sube 0x20 casillas: una fila
	add hl,de			;5a6e
	ld (0e00eh),hl		;5a6f
	ld a,040h		;5a72   ; Tres caracteres arriba, doce en medio y doce abajo
	ld b,003h		;5a74
	call tira_de_caracteres		;5a76
	ld bc,00b0ch		;5a79
	call tira_de_caracteres		;5a7c
	ld b,c			;5a7f
	call tira_de_caracteres		;5a80
	xor a			;5a83
	call 00056h		;5a84   ; BIOS FILVRM - Fills VRAM with value | Y ceros debajo, que borran lo que dejo la vuelta anterior
	ld hl,0e00ah		;5a87   ; 0xE00A cuenta las catorce filas
	dec (hl)			;5a8a
	ret			;5a8b
tira_de_caracteres:		; B caracteres consecutivos desde A, y luego baja una fila
	push hl			;5a8c
L_5A8D:
	call 0004dh		;5a8d   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;5a90
	inc a			;5a91   ; El codigo de caracter sube con la columna
	djnz L_5A8D		;5a92
	pop de			;5a94
	ld hl,00020h		;5a95   ; 0x20: la fila de abajo, para la llamada siguiente
	add hl,de			;5a98
	ret			;5a99

; ----------------------------------------------------------------------
; DATOS flujo_6200: Flujo comprimido que 0x5A54 -la presentacion- pasa a
;   0x4988 con HL=0x6200.
;   0x5a9a..0x5b31  (151 bytes)
DATA_flujo_6200:
	defb 00fh,000h,001h,001h,006h,000h,082h,0ffh,0feh,008h,00fh,084h,0c3h,0c7h,0cfh,0dfh	; 5a9a  ................
	defb 003h,0ffh,089h,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h,007h,007h,005h,000h,083h,003h	; 5aaa  ................
	defb 0cfh,0dfh,005h,000h,083h,0e1h,0f9h,07dh,005h,000h,083h,0efh,0ffh,0f7h,005h,000h	; 5aba  .......}........
	defb 083h,007h,08fh,09eh,005h,000h,083h,0f0h,0f8h,078h,005h,000h,083h,0f7h,0ffh,0fbh	; 5aca  .........x......
	defb 005h,000h,08bh,08fh,0dfh,0f7h,00ch,01eh,01eh,00ch,000h,01eh,09eh,09eh,008h,00fh	; 5ada  ................
	defb 090h,0ffh,0ffh,0dfh,0cfh,0c7h,0c3h,0c1h,0c0h,007h,087h,0c7h,0efh,0ffh,0ffh,0ffh	; 5aea  ................
	defb 0fch,004h,0deh,084h,09eh,09fh,00fh,003h,005h,03dh,083h,07dh,0f9h,0e1h,008h,0e3h	; 5afa  .........=.}....
	defb 090h,0dch,0c0h,0c7h,0deh,0dch,0deh,0cfh,0c3h,03ch,07ch,0fch,03ch,03ch,07ch,0fch	; 5b0a  .........<|.<<|.
	defb 0deh,008h,0f1h,008h,0e3h,008h,0deh,088h,038h,044h,0bah,0aah,0b2h,0aah,044h,038h	; 5b1a  ........8D....D8
	defb 003h,000h,001h,0ffh,004h,000h,000h	; 5b2a

; ======================================================================
; CODIGO 0x5b31..0x5bf7  (198 bytes)
; ======================================================================


monta_la_pantalla_del_titulo:		; Con los bancos 9 y 10 puestos, borde negro, pantalla limpia, la fuente y los dos bloques del dibujo del titulo
	di			;5b31   ; Bancos 9 y 10: los de la presentacion
	ld a,009h		;5b32
	ld (08000h),a		;5b34
	ld (0f0f2h),a		;5b37
	ei			;5b3a
	di			;5b3b
	ld a,00ah		;5b3c
	ld (0a000h),a		;5b3e
	ld (0f0f3h),a		;5b41
	ei			;5b44
	ld b,0e0h		;5b45   ; 0xE0 en el registro 7: borde negro
	call pon_el_color_del_borde		;5b47
	call borra_la_pantalla		;5b4a
	call carga_el_marcador		;5b4d
	ld de,09c57h		;5b50   ; Los patrones del titulo, en la VRAM 0x2468...
	ld hl,02468h		;5b53
	call descomprime_tres_tercios		;5b56
	ld de,09eabh		;5b59   ; ...y sus colores, en la 0x0468
	ld hl,00468h		;5b5c
	call descomprime_tres_tercios		;5b5f
	di			;5b62   ; Devueltos el 2 y el 3
	ld a,002h		;5b63   ; Devueltos el 2 y el 3
	ld (08000h),a		;5b65
	ld (0f0f2h),a		;5b68
	ei			;5b6b
	di			;5b6c
	ld a,003h		;5b6d
	ld (0a000h),a		;5b6f
	ld (0f0f3h),a		;5b72
	ei			;5b75
	ret			;5b76
escribe_el_panel_del_titulo:		; Monta la pantalla y escribe encima el panel de 28x5 que le toque al pais de la maquina
	call monta_la_pantalla_del_titulo		;5b77
	di			;5b7a
	ld a,009h		;5b7b
	ld (08000h),a		;5b7d
	ld (0f0f2h),a		;5b80
	ei			;5b83
	di			;5b84
	ld a,00ah		;5b85
	ld (0a000h),a		;5b87
	ld (0f0f3h),a		;5b8a
	ei			;5b8d

; ----------------------------------------------------------------------
; EL MISMO CARTUCHO SE LLAMA GRADIUS O NEMESIS SEGUN LA MAQUINA
; Aqui esta la razon de que este juego tenga dos nombres. El cartucho lee
; 0x002B de la BIOS y se queda con el nibble bajo, que es el juego de
; caracteres de la maquina: a cero, japonesa. Y con eso elige cual de los
; DOS logotipos escribe en la fila 4: el de 0x9BCB o el de 0x9B3F, cinco
; filas de 28 caracteres cada uno, los dos en el banco 9 y pegados el uno
; al otro.
; Dibujados desde la ROM -descomprimiendo sus patrones de 0x9C57 y sus
; colores de 0x9EAB y pintando el panel- se lee lo que dicen: el de la
; maquina japonesa pone GRADIUS y el otro NEMESIS. No son dos versiones
; del cartucho: es el MISMO binario, con los dos titulos dentro.
; Es el mismo reparto por pais que 0x4C42 usa para el rotulo del final.
; ----------------------------------------------------------------------
	ld a,(0002bh)		;5b8e   ; El nibble bajo de 0x002B: el juego de caracteres. A cero, japonesa
	and 00fh		;5b91
	ld de,09bcbh		;5b93   ; El panel japones...
	jr z,L_5B9B		;5b96
	ld de,09b3fh		;5b98   ; ...y el de las demas maquinas
L_5B9B:
	ld hl,03882h		;5b9b   ; Fila 4, columna 2
	ld b,005h		;5b9e   ; Cinco filas
L_5BA0:
	push bc			;5ba0
	call pon_escritura_vram		;5ba1
	ld b,01ch		;5ba4   ; Veintiocho caracteres por fila
L_5BA6:
	ld a,(de)			;5ba6   ; Veintiocho caracteres, por el puerto de datos
	inc de			;5ba7
	exx			;5ba8
	out (c),a		;5ba9
	exx			;5bab
	djnz L_5BA6		;5bac
	ld a,020h		;5bae   ; 0x20: la fila de abajo
	call suma_a_a_hl		;5bb0   ; 0x20: la fila de abajo
	pop bc			;5bb3
	djnz L_5BA0		;5bb4
	di			;5bb6
	ld a,002h		;5bb7
	ld (08000h),a		;5bb9
	ld (0f0f2h),a		;5bbc
	ei			;5bbf
	di			;5bc0
	ld a,003h		;5bc1
	ld (0a000h),a		;5bc3
	ld (0f0f3h),a		;5bc6
	ei			;5bc9
	ld de,057ebh		;5bca   ; Y encima, los dos rotulos de 0x57EB
	call escribe_caracteres		;5bcd
	jp escribe_caracteres		;5bd0
parpadea_lo_elegido:		; Un bit de 0xE004 apaga y enciende el rotulo de la opcion elegida en la presentacion
	ld hl,0e004h		;5bd3
	bit 3,(hl)		;5bd6   ; Bit 3 del contador: encendido y apagado
	ld c,0ffh		;5bd8
	jr nz,L_5BDD		;5bda
	inc c			;5bdc
L_5BDD:
	ld hl,03a2ah		;5bdd   ; Fila 17, columna 10, y la de 0x40 mas abajo
	ld de,03a6ah		;5be0
	ld a,(0e052h)		;5be3   ; 0xE052 dice cual de las dos esta elegida
	or a			;5be6
	jr z,L_5BEA		;5be7
	ex de,hl			;5be9
L_5BEA:
	push de			;5bea
	call L_5BF1		;5beb
	pop hl			;5bee
	ld c,000h		;5bef
L_5BF1:
	ld de,0581dh		;5bf1
	jp L_49A0		;5bf4

; ----------------------------------------------------------------------
; DATOS byte_suelto: Un 0x00 entre dos rutinas. SUPOSICION: relleno de
;   alineacion; ninguna instruccion lo lee.
;   0x5bf7..0x5bf8  (1 bytes)
DATA_byte_suelto:
	defb 000h	; 5bf7

; ======================================================================
; CODIGO 0x5bf8..0x5d1f  (295 bytes)
; ======================================================================


monta_la_pantalla_de_records:		; Con los bancos 9 y 10, descomprime los seis bloques de la tabla de records y le copia los 768 caracteres de 0x8000 tal cual
	call borra_la_pantalla		;5bf8
	di			;5bfb
	ld a,009h		;5bfc
	ld (08000h),a		;5bfe
	ld (0f0f2h),a		;5c01
	ei			;5c04
	di			;5c05
	ld a,00ah		;5c06
	ld (0a000h),a		;5c08
	ld (0f0f3h),a		;5c0b
	ei			;5c0e
	ld hl,02008h		;5c0f   ; Tres bloques de patrones, en 0x2008, 0x2808 y 0x3008
	ld de,08300h		;5c12
	call descomprime		;5c15
	ld hl,02808h		;5c18
	ld de,087fah		;5c1b
	call descomprime		;5c1e
	ld hl,03008h		;5c21
	ld de,08cb2h		;5c24
	call descomprime		;5c27
	ld hl,00008h		;5c2a   ; Y sus tres de colores, en 0x0008, 0x0808 y 0x1008
	ld de,0917eh		;5c2d
	call descomprime		;5c30
	ld hl,00808h		;5c33
	ld de,09515h		;5c36
	call descomprime		;5c39
	ld hl,01008h		;5c3c
	ld de,0989fh		;5c3f
	call descomprime		;5c42
	ld hl,02780h		;5c45   ; Los caracteres del marco, en los tres tercios
	ld de,0a758h		;5c48
	call descomprime_tres_tercios		;5c4b
	ld hl,00780h		;5c4e
	ld de,0a783h		;5c51
	call descomprime_tres_tercios		;5c54
	ld hl,01800h		;5c57   ; Y los patrones de sprite
	ld de,0a7a4h		;5c5a
	call descomprime		;5c5d
	call 0a809h		;5c60
	ld hl,03800h		;5c63
	ld de,08000h		;5c66   ; 0x8000: 768 caracteres SIN COMPRIMIR, la pantalla entera de una vez
	ld bc,00300h		;5c69
	call vuelca_a_vram		;5c6c
	di			;5c6f
	ld a,002h		;5c70
	ld (08000h),a		;5c72
	ld (0f0f2h),a		;5c75
	ei			;5c78
	di			;5c79
	ld a,003h		;5c7a
	ld (0a000h),a		;5c7c
	ld (0f0f3h),a		;5c7f
	ei			;5c82
	ld a,0a6h		;5c83   ; El sonido 0xA6
	jp pide_sonido		;5c85

; ----------------------------------------------------------------------
; LA DEMO SE JUEGA SOLA LEYENDO UNA GRABACION DEL MANDO
; La demo no la juega ninguna maquina lista: es una GRABACION. En el banco
; 12 hay, por fase, una lista de parejas [cuantos cuadros][que vale el
; mando], y 0x5CDA la va leyendo: 0xE00B cuenta los cuadros que quedan y
; 0xE00C guarda el valor del mando, que 0x5CCF mete en 0xE009 -la misma
; casilla donde 0x5767 deja lo que lee del joystick de verdad-, ademas de
; encenderle el bit 4, que es el disparo. O sea que la nave de la demo
; dispara SIEMPRE y se mueve como diga la cinta.
; Y arranca con todo puesto: 0x5CB8 llama a 0xA0D8, que es lo mismo que da
; la clave HYPER.
; ----------------------------------------------------------------------
arranca_la_demo:		; Elige la fase que toca -0xE006 da la vuelta a las ocho-, la monta con todas las mejoras y la deja lista para leerse sola
	xor a			;5c88
	ld (0e009h),a		;5c89
	ld (0e007h),a		;5c8c
	inc a			;5c8f
	ld (0e05fh),a		;5c90   ; 0xE05F a uno: el aviso de que hay demo en marcha
	ld hl,0e006h		;5c93   ; 0xE006 lleva por que fase va la demo
	ld a,(hl)			;5c96
	ld (0e061h),a		;5c97
	inc a			;5c9a
	cp 009h		;5c9b   ; Ocho fases y vuelta a la primera
	jr c,L_5CA1		;5c9d
	ld a,001h		;5c9f
L_5CA1:
	ld (hl),a			;5ca1
	ld hl,00020h		;5ca2   ; 0x20 de distancia recorrida
	ld (0e063h),hl		;5ca5
	ld hl,00001h		;5ca8   ; 0xE00B a uno: el primer paso de la grabacion entra ya
	ld (0e00bh),hl		;5cab
	xor a			;5cae
	ld (0e00dh),a		;5caf
	ld (0e06ah),a		;5cb2
	call monta_la_fase_que_toque		;5cb5
	call 0a0d8h		;5cb8   ; Y todas las mejoras de golpe, como la clave HYPER
	jp escribe_los_rotulos		;5cbb
corre_la_demo:		; Mientras dure, va sacando de la grabacion el valor del mando y se lo pasa al juego como si lo hubiera pulsado alguien
	ld a,(0e064h)		;5cbe   ; Con 0xE064 puesto, la demo se corta
	and a			;5cc1
	jr z,L_5CC9		;5cc2
	xor a			;5cc4
	ld (0e05fh),a		;5cc5
	ret			;5cc8
L_5CC9:
	ld hl,0e00bh		;5cc9   ; 0xE00B: los cuadros que le quedan a este paso
	dec (hl)			;5ccc
	jr z,siguiente_paso_de_la_grabacion		;5ccd
mete_el_mando_grabado:		; El valor grabado va a 0xE009, con el bit 4 -el disparo- siempre puesto
	ld a,(0e00ch)		;5ccf
	or 010h		;5cd2   ; El bit 4: en la demo se dispara sin parar
	ld (0e009h),a		;5cd4
	jp mira_la_tecla_de_pausa		;5cd7
siguiente_paso_de_la_grabacion:		; Mete los bancos 11 y 12, saca de la lista de la fase la pareja siguiente y la deja en 0xE00B y 0xE00C
	inc hl			;5cda
	inc hl			;5cdb
	ld c,(hl)			;5cdc   ; 0xE00D dice por que pareja va
	inc (hl)			;5cdd
	di			;5cde   ; Bancos 11 y 12: ahi estan las grabaciones
	ld a,00bh		;5cdf
	ld (08000h),a		;5ce1
	ld (0f0f2h),a		;5ce4
	ei			;5ce7
	di			;5ce8
	ld a,00ch		;5ce9
	ld (0a000h),a		;5ceb
	ld (0f0f3h),a		;5cee
	ei			;5cf1
	ld a,(0e061h)		;5cf2
	ld hl,l5d1dh		;5cf5   ; La tabla de 0x5D1D, indexada por la fase
	call dame_palabra		;5cf8
	ld l,c			;5cfb
	ld h,000h		;5cfc
	add hl,hl			;5cfe   ; Por dos: cada paso son dos bytes
	add hl,de			;5cff
	ld a,(hl)			;5d00   ; El primero, los cuadros que dura
	ld (0e00bh),a		;5d01
	inc hl			;5d04
	ld a,(hl)			;5d05   ; Y el segundo, lo que vale el mando
	ld (0e00ch),a		;5d06
	di			;5d09   ; Devueltos el 2 y el 3
	ld a,002h		;5d0a
	ld (08000h),a		;5d0c
	ld (0f0f2h),a		;5d0f
	ei			;5d12
	di			;5d13
	ld a,003h		;5d14
	ld (0a000h),a		;5d16
	ld (0f0f3h),a		;5d19
	ei			;5d1c
L_5D1D:
	jr mete_el_mando_grabado		;5d1d

; ----------------------------------------------------------------------
; DATOS finales_por_fase (tramo): Palabras que 0x5CF5 indexa con la fase
;   (0x47AE), con la base 0x5D1D: 0xA878, 0xA942, 0xAA92, 0xAC34, 0xAD94,
;   0xAF54, 0xB078 y 0xB13A, todas del banco 3.
;   0x5d1f..0x5d41  (34 bytes)  de 0x5d1d..0x5d41 (36 bytes)
DATA_finales_por_fase_5D1F:
	defw 0a878h,0a942h	; 5d1f
	defw 0aa92h,0ac34h	; 5d23
	defw 0ad94h,0af54h	; 5d27
	defw 0b078h,0b13ah	; 5d2b
	defw 0613ah,0fee0h	; 5d2f
	defw 0d809h,057cdh	; 5d33
	defw 0285dh,0d8f5h	; 5d37
	defw 02721h,034e1h	; 5d3b
	defw 0ee18h	; 5d3f

; ======================================================================
; CODIGO 0x5d41..0x5dfd  (188 bytes)
; ======================================================================


suelta_lo_que_toque:		; De la fase novena en adelante, y solo en los pasos con columna nueva, va soltando lo que diga el guion hasta que se acaba
	ld a,(0e061h)		;5d41
	cp 009h		;5d44   ; Por debajo de la novena, no
	ret c			;5d46
	ld a,(0e100h)		;5d47   ; Y solo en los pasos que meten columna
	and a			;5d4a
	ret z			;5d4b
	ld a,0f8h		;5d4c   ; 0xF8 en 0xEC04
	ld (0ec04h),a		;5d4e
L_5D51:
	call suelta_uno		;5d51
	jr z,L_5D51		;5d54
	ret			;5d56
suelta_uno:		; Mira si toca soltar algo aqui; si si, saca del guion la posicion y el tipo y llama al motor del banco 1
	call mira_el_guion_de_la_fase		;5d57
	ret nz			;5d5a
	ld hl,0e127h		;5d5b   ; 0xE127 avanza al renglon siguiente del guion
	inc (hl)			;5d5e
	ld a,c			;5d5f
	and 0f8h		;5d60   ; Los cinco bits altos: la Y
	ld e,a			;5d62
	ld a,(0ec04h)		;5d63
	ld d,a			;5d66
	ld a,c			;5d67
	and 003h		;5d68
	bit 2,c		;5d6a   ; El bit 2 reparte entre dos tipos
	jp z,L_5D79		;5d6c
	add a,003h		;5d6f
	ld c,a			;5d71
	add a,013h		;5d72
L_5D74:
	call 06a72h		;5d74
	xor a			;5d77
	ret			;5d78
L_5D79:
	add a,003h		;5d79
	ld c,a			;5d7b
	ld a,019h		;5d7c
	jp L_5D74		;5d7e
mira_el_guion_de_la_fase:		; Con los bancos 11 y 12, busca en el guion de la fase el renglon que le toca a la distancia recorrida y lo compara
	di			;5d81
	ld a,00bh		;5d82   ; Bancos 11 y 12: ahi estan los guiones
	ld (08000h),a		;5d84
	ld (0f0f2h),a		;5d87
	ei			;5d8a
	di			;5d8b
	ld a,00ch		;5d8c
	ld (0a000h),a		;5d8e
	ld (0f0f3h),a		;5d91
	ei			;5d94
	ld hl,0b2d2h		;5d95   ; La tabla de 0xB2D2, indexada por la fase
	ld a,(0e061h)		;5d98
	call dame_palabra		;5d9b
	push de			;5d9e
	ld a,(0e127h)		;5d9f   ; 0xE127: por que renglon del guion va
	ld h,a			;5da2
	ld e,003h		;5da3   ; Tres bytes por renglon
	call 06743h		;5da5
	pop de			;5da8
	add hl,de			;5da9
	ld c,(hl)			;5daa   ; El primero, el tipo; los otros dos, la distancia
	inc hl			;5dab
	ld e,(hl)			;5dac
	inc hl			;5dad
	ld d,(hl)			;5dae
	di			;5daf   ; Devueltos el 2 y el 3
	ld a,002h		;5db0
	ld (08000h),a		;5db2
	ld (0f0f2h),a		;5db5
	ei			;5db8
	di			;5db9
	ld a,003h		;5dba
	ld (0a000h),a		;5dbc
	ld (0f0f3h),a		;5dbf
	ei			;5dc2
	ld hl,(0e063h)		;5dc3   ; DCOMPR: la distancia recorrida contra la del renglon
	rst 20h			;5dc6
	ret			;5dc7
corre_los_doce_objetos:		; Los doce objetos de 0xE300, de 0x20 en 0x20 bytes: a cada uno su motor y luego 0x5F66
	ld ix,0e300h		;5dc8
	ld b,00ch		;5dcc   ; Doce objetos
L_5DCE:
	push bc			;5dce
	call despacha_el_motor_del_objeto		;5dcf
	call mira_si_el_objeto_se_ha_ido		;5dd2
	pop bc			;5dd5
	ld de,00020h		;5dd6   ; Treinta y dos bytes por objeto
	add ix,de		;5dd9
	djnz L_5DCE		;5ddb
	ret			;5ddd
despacha_el_motor_del_objeto:		; El primer byte dice de que es el objeto; con la pantalla parada (0xE1C0) hay tres casos, y si no, la tabla de treinta y uno
	ld c,(ix+000h)		;5dde
	ld a,(0e1c0h)		;5de1   ; 0xE1C0 distinto de cero: la pantalla esta parada
	and a			;5de4
	jp z,L_5DF6		;5de5
	ld a,c			;5de8
	cp 001h		;5de9
	jp z,09119h		;5deb
	cp 015h		;5dee
	jp z,anima_cuatro_dibujos		;5df0
	jp 09251h		;5df3
L_5DF6:
	ld a,c			;5df6
	and a			;5df7
	ret z			;5df8   ; El tipo 0 es la ranura vacia
	dec a			;5df9
	call despachador		;5dfa

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_5DFA: Treinta y una palabras pegadas detras del
;   `call 0x4067` de 0x5DFA. Es la tabla mas grande del cartucho, y casi todos
;   sus destinos estan en OTRO banco: manda a 0x8000 y a 0xA000, o sea a los
;   bancos 2 y 3.
;   0x5dfd..0x5e3b  (62 bytes)
DATA_tabla_del_despachador_5DFA:
	defw 09119h,0a8b2h	; 5dfd
	defw 0a836h,0a863h	; 5e01
	defw 0a9fbh,0a95ah	; 5e05
	defw 05ee7h,0acbdh	; 5e09  -> mueve_el_bicho_de_la_escotilla 0xacbd
	defw 0ad33h,0ad92h	; 5e0d
	defw 0ade5h,0ae1bh	; 5e11
	defw 0afbdh,05f4fh	; 5e15  -> 0xafbd mira_si_choca_con_el_mapa
	defw 071adh,071b0h	; 5e19
	defw 05e3bh,05e3bh	; 5e1d  -> L_5E3B L_5E3B
	defw 05e3bh,05ec8h	; 5e21  -> L_5E3B anima_cuatro_caracteres
	defw 05e3eh,05e3bh	; 5e25  -> anima_cuatro_dibujos L_5E3B
	defw 0a7d9h,0a7d9h	; 5e29
	defw 05e3bh,0a7dfh	; 5e2d  -> L_5E3B 0xa7df
	defw 0b915h,05f4fh	; 5e31  -> 0xb915 mira_si_choca_con_el_mapa
	defw 0b9ffh,0bce3h	; 5e35
	defw 0bd7dh	; 5e39

; ======================================================================
; CODIGO 0x5e3b..0x5e5d  (34 bytes)
; ======================================================================


L_5E3B:
	jp 09251h		;5e3b
anima_cuatro_dibujos:		; Los diecisis primeros cuadros del objeto van cambiando entre los cuatro pares de caracter y color de 0x5E5D
	ld a,(ix+002h)		;5e3e
	inc (ix+002h)		;5e41   ; Un cuadro mas para este objeto
	cp 010h		;5e44   ; Pasados dieciseis, se acaba la animacion
	jr nc,$+31		;5e46
	rra			;5e48   ; Un bit de por medio: cada dibujo dura dos cuadros
	and 006h		;5e49
	ld hl,05e5dh		;5e4b
	call suma_a_a_hl		;5e4e
	ld a,(hl)			;5e51
	ld (ix+00ch),a		;5e52   ; El caracter en el byte 12 y el color en el 13
	inc hl			;5e55
	ld a,(hl)			;5e56
	ld (ix+00dh),a		;5e57
	jp 09251h		;5e5a

; ----------------------------------------------------------------------
; DATOS caracteres_de_5E4B: Ocho bytes que 0x5E4B indexa con (A AND 6) y mete
;   en (IX+0x0C).
;   0x5e5d..0x5e65  (8 bytes)
DATA_caracteres_de_5E4B:
	defb 078h,00fh,07ch,009h,080h,006h,084h,00dh	; 5e5d  x.|.....

; ======================================================================
; CODIGO 0x5e65..0x5ee3  (126 bytes)
; ======================================================================


objeto_a_explosion:		; Convierte el objeto en explosion: le pone el tipo 0x12 o 0x13, su caracter, y le cuadra la X y la Y a la rejilla
	ld a,(ix+011h)		;5e65   ; El byte 17 dice si el objeto pertenece a un grupo
	and a			;5e68
	jr z,L_5E88		;5e69
	ld a,(ix+012h)		;5e6b
	call busca_el_grupo		;5e6e   ; Se busca el grupo en la tabla de 0xE900
	jp c,apaga_el_objeto		;5e71
	ld a,(hl)			;5e74
	inc l			;5e75
	inc l			;5e76
	dec (hl)			;5e77   ; Baja la cuenta del grupo; hasta que no llega a cero, no revienta
	jp nz,apaga_el_objeto		;5e78
	dec l			;5e7b
	dec l			;5e7c
	ld (hl),000h		;5e7d
	and 007h		;5e7f
	ld a,012h		;5e81
	jr nz,L_5E95		;5e83
	inc a			;5e85
	jr L_5E95		;5e86
L_5E88:
	ld a,(ix+00eh)		;5e88   ; Sin grupo, manda el byte 14
	and a			;5e8b
	jp z,apaga_el_objeto		;5e8c
	dec a			;5e8f
	ld a,012h		;5e90
	jr z,L_5E95		;5e92
	inc a			;5e94
L_5E95:
	ld (ix+000h),a		;5e95   ; Tipo 0x12 o 0x13: los dos tamanos de explosion
	add a,00fh		;5e98
	ld (ix+00ch),a		;5e9a
	ld (ix+00bh),001h		;5e9d   ; El byte 11 a uno: se dibuja con caracteres
	ld (ix+01bh),001h		;5ea1
	ld a,(ix+004h)		;5ea5   ; La Y, cuadrada a ocho y mas cuatro
	and 0f8h		;5ea8
	add a,004h		;5eaa
	ld (ix+004h),a		;5eac
	ld a,(ix+006h)		;5eaf   ; Y la X, cuadrada a ocho
	and 0f8h		;5eb2
	ld (ix+006h),a		;5eb4
	jp 09251h		;5eb7
busca_el_grupo:		; Recorre las cuatro fichas de tres bytes de 0xE900 buscando el grupo de A; sale con acarreo si no esta
	ld hl,0e900h		;5eba
	ld b,004h		;5ebd   ; Cuatro grupos
L_5EBF:
	cp (hl)			;5ebf
	ret z			;5ec0
	inc l			;5ec1   ; Tres bytes por grupo
	inc l			;5ec2
	inc l			;5ec3
	djnz L_5EBF		;5ec4
	scf			;5ec6
	ret			;5ec7
anima_cuatro_caracteres:		; Los dieciseis primeros cuadros, un caracter de 0x5EE3 cada cuatro; pasados, el objeto revienta
	ld a,(ix+002h)		;5ec8
	inc (ix+002h)		;5ecb
	cp 010h		;5ece   ; Pasados dieciseis, a explotar
	jr nc,objeto_a_explosion		;5ed0
	rra			;5ed2   ; Dos bits de por medio: cada dibujo dura cuatro cuadros
	rra			;5ed3
	and 003h		;5ed4
	ld hl,05ee3h		;5ed6
	call suma_a_a_hl		;5ed9
	ld a,(hl)			;5edc
	ld (ix+00ch),a		;5edd
	jp 09251h		;5ee0

; ----------------------------------------------------------------------
; DATOS caracteres_de_5ED6: Cuatro bytes (0xF0, 0xF4, 0xF8, 0xFC) que 0x5ED6
;   indexa con (A AND 3).
;   0x5ee3..0x5ee7  (4 bytes)
DATA_caracteres_de_5ED6:
	defb 0f0h,0f4h,0f8h,0fch	; 5ee3

; ======================================================================
; CODIGO 0x5ee7..0x5f47  (96 bytes)
; ======================================================================


mueve_el_bicho_de_la_escotilla:		; Cada cuatro cuadros cambia de dibujo, se corre con la pantalla y, cuando la nave le cruza la fila, se gira
	ld a,(0e003h)		;5ee7
	and 003h		;5eea   ; Uno de cada cuatro cuadros
	jr nz,L_5F00		;5eec
	inc (ix+002h)		;5eee
	ld a,(ix+002h)		;5ef1
	and 007h		;5ef4   ; Ocho dibujos en redondo
	ld hl,05f47h		;5ef6
	call suma_a_a_hl		;5ef9
	ld a,(hl)			;5efc
	ld (ix+00ch),a		;5efd
L_5F00:
	ld a,(ix+001h)		;5f00
	and a			;5f03
	ret nz			;5f04
	ld a,(0e100h)		;5f05   ; En los pasos con columna nueva, se corre ocho puntos a la izquierda
	and a			;5f08
	jr z,L_5F13		;5f09
	ld a,(ix+006h)		;5f0b
	sub 008h		;5f0e
	ld (ix+006h),a		;5f10
L_5F13:
	ld a,(0e204h)		;5f13   ; 0xE204 es la fila de la nave, y el bit 7 del byte 8 el signo de su velocidad vertical
	bit 7,(ix+008h)		;5f16
	jr nz,L_5F22		;5f1a
	cp (ix+004h)		;5f1c
	ret nc			;5f1f
	jr el_bicho_se_gira		;5f20
L_5F22:
	cp (ix+004h)		;5f22
	ret c			;5f25
el_bicho_se_gira:		; Para de subir o bajar -la velocidad de los bytes 7 y 8 a cero- y toma 0xFC00 en la horizontal: se lanza hacia la nave
	inc (ix+001h)		;5f26
	xor a			;5f29
	ld (ix+007h),a		;5f2a
	ld (ix+008h),a		;5f2d
	ld hl,0fc00h		;5f30   ; 0xFC00 en los bytes 9 y 10: cuatro puntos por cuadro hacia la izquierda
	ld (ix+009h),l		;5f33
	ld (ix+00ah),h		;5f36
	ld a,(0e066h)		;5f39   ; 0xE066 son las fases jugadas: de la segunda vuelta en adelante, al girarse dispara
	and a			;5f3c
	ret z			;5f3d
	ld e,(ix+004h)		;5f3e
	ld d,(ix+006h)		;5f41
	jp 06613h		;5f44

; ----------------------------------------------------------------------
; DATOS animacion_de_5EF6: Ocho bytes (4,5,6,7,8,7,6,5) que 0x5EF6 indexa con
;   el contador (IX+2) AND 7: la ida y vuelta de una animacion.
;   0x5f47..0x5f4f  (8 bytes)
DATA_animacion_de_5EF6:
	defb 004h,005h,006h,007h,008h,007h,006h,005h	; 5f47  ........

; ======================================================================
; CODIGO 0x5f4f..0x6000  (177 bytes)
; ======================================================================


mira_si_choca_con_el_mapa:		; Le pasa al banco 2 la X y la Y del objeto, con ocho de correccion segun el bit 0 del byte 8
	ld l,(ix+004h)		;5f4f
	ld h,(ix+006h)		;5f52
	bit 0,(ix+008h)		;5f55   ; El bit 0 del byte 8 dice si hay que correr la Y
	jr nz,L_5F5F		;5f59
	ld a,008h		;5f5b
	add a,l			;5f5d
	ld l,a			;5f5e
L_5F5F:
	call 09857h		;5f5f
	ret nc			;5f62
	jp apaga_el_objeto		;5f63
mira_si_el_objeto_se_ha_ido:		; Los tipos del 2 al 0x10 y del 0x1B al 0x1D suman su velocidad y, si se salen de la pantalla, se apagan
	ld a,(ix+000h)		;5f66
	cp 002h		;5f69   ; Los tipos 0 y 1 no se mueven asi
	ret c			;5f6b
	cp 01eh		;5f6c   ; Y el 0x1E tampoco
	ret z			;5f6e
	cp 011h		;5f6f   ; Del 0x11 al 0x1A, tampoco
	jr c,L_5F76		;5f71
	cp 01bh		;5f73
	ret c			;5f75
L_5F76:
	call suma_la_velocidad		;5f76
	jr nc,apaga_el_objeto		;5f79
	ret			;5f7b
suma_la_velocidad:		; Le suma al objeto sus dos velocidades de 16 bits y devuelve si sigue dentro de la pantalla
	push ix		;5f7c
	pop hl			;5f7e
	inc l			;5f7f   ; Los bytes 3 y 4: la Y de 16 bits
	inc l			;5f80
	inc l			;5f81
	ld d,h			;5f82
	ld e,l			;5f83
	inc e			;5f84   ; Y los 7 y 8: su velocidad
	inc e			;5f85
	inc e			;5f86
	inc e			;5f87
	call suma_una_palabra		;5f88
	call suma_una_palabra		;5f8b
	ld a,(ix+004h)		;5f8e   ; Pasada la Y 0xB0 o la X 0xF9, el objeto se ha ido
	cp 0b0h		;5f91
	ret nc			;5f93
	ld a,(ix+006h)		;5f94
	cp 0f9h		;5f97
	ret			;5f99
suma_una_palabra:		; Suma dos bytes de DE sobre los dos de HL, con acarreo
	ld a,(de)			;5f9a   ; El byte bajo...
	add a,(hl)			;5f9b
	ld (hl),a			;5f9c
	inc l			;5f9d
	inc e			;5f9e
	ld a,(de)			;5f9f   ; ...y el alto con el acarreo
	adc a,(hl)			;5fa0
	ld (hl),a			;5fa1
	inc l			;5fa2
	inc e			;5fa3
	ret			;5fa4
apaga_el_objeto:		; Libera la ranura y baja la cuenta de objetos vivos; si iba en grupo, baja tambien la del grupo
	ld a,(ix+000h)		;5fa5
	cp 01eh		;5fa8   ; El tipo 0x1E ocupa tres ranuras
	jr z,apaga_las_tres_ranuras		;5faa
	ld hl,0e126h		;5fac   ; 0xE126 lleva la cuenta de objetos vivos
	dec (hl)			;5faf
	xor a			;5fb0
	ld (ix+000h),a		;5fb1
	ld (ix+01bh),a		;5fb4
	bit 0,(ix+011h)		;5fb7   ; El bit 0 del byte 17: pertenece a un grupo
	ret z			;5fbb   ; El bit 0 del byte 17: el objeto iba en un grupo
	ld a,(ix+012h)		;5fbc
	call busca_el_grupo		;5fbf   ; Se busca su grupo en la tabla de 0xE900
	ret c			;5fc2
	inc l			;5fc3   ; Baja la cuenta del grupo
	dec (hl)			;5fc4
	ret nz			;5fc5
	dec l			;5fc6
	ld (hl),000h		;5fc7   ; Y al llegar a cero, el grupo se cierra
	ret			;5fc9
apaga_las_tres_ranuras:		; El objeto grande de tipo 0x1E ocupa tres ranuras seguidas: se apagan las tres y bajan tres de la cuenta
	ld hl,0e126h		;5fca
	dec (hl)			;5fcd
	dec (hl)			;5fce
	dec (hl)			;5fcf
	push ix		;5fd0
	pop iy		;5fd2
	ld de,00020h		;5fd4   ; Treinta y dos bytes: la ranura siguiente
	ld b,003h		;5fd7   ; Tres ranuras
	xor a			;5fd9
L_5FDA:
	ld (iy+000h),a		;5fda
	ld (iy+01bh),a		;5fdd
	add iy,de		;5fe0
	djnz L_5FDA		;5fe2
corre_los_objetos_del_fondo:		; La fase 5 tiene su propio motor en el banco 3; las demas recorren ocho o dos objetos de 0xE700
	ld a,(0e061h)		;5fe4
	cp 005h		;5fe7   ; La fase 5 va por otro lado
	jp z,0b2aah		;5fe9
	ld ix,0e700h		;5fec
	ld a,(0e061h)		;5ff0
	cp 003h		;5ff3   ; La fase 3 lleva ocho; las demas, dos
	ld b,008h		;5ff5
	jr z,L_5FFB		;5ff7
	ld b,002h		;5ff9
L_5FFB:
	push bc			;5ffb
	call 06008h		;5ffc
	pop bc			;5fff

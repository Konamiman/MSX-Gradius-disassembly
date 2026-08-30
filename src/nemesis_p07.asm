; ==========================================================================
; NEMESIS / GRADIUS - Konami (1986) - MSX1 - MegaROM RC-742 de 128 KB (Konami4) - banco 07 (se ejecuta en 0x8000)
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x08000


; ======================================================================
; CODIGO 0x8000..0x80d9  (217 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; UN CANAL ES UNA FICHA DE 0x11 BYTES Y UN FLUJO DE MANDOS
; El reproductor lleva tres fichas iguales, en 0xE010, 0xE021 y 0xE032,
; de 0x11 bytes cada una: el byte 0 es la cuenta atras de la nota que
; suena, el 1 lo que dura, el 2 el modo, los 3 y 4 por donde va su flujo
; de mandos, el 5 los interruptores -tono, ruido y envolvente-, el 6 el
; salto de octava, del 7 al 9 el volumen y su caida, el 0x0B la unidad de
; tiempo, el 0x0C el sostenido, el 0x0D y el 0x0E los tiempos de la
; envolvente, y el 0x0F y el 0x10 el ultimo periodo escrito. Todo lo que
; suena sale de leer esos flujos byte a byte.
; ----------------------------------------------------------------------
repite_el_flujo:		; La orden 0xFE: la palabra de detras dice adonde se vuelve, y el byte 10 cuenta las vueltas dadas
	inc hl			;8000   ; El byte 10: las vueltas que lleva
	ld a,(ix+00ah)		;8001
	inc a			;8004
	cp (hl)			;8005   ; Contra las que pide la orden
	jr z,ya_ha_dado_las_vueltas		;8006
	jp m,L_800C		;8008
	dec a			;800b
L_800C:
	ld (ix+00ah),a		;800c   ; Una vuelta mas
	inc hl			;800f
	ld a,(hl)			;8010   ; Y el flujo se vuelve adonde diga la palabra
	ld (ix+003h),a		;8011
	inc hl			;8014
	ld a,(hl)			;8015
	ld (ix+004h),a		;8016
	jr L_8024		;8019
ya_ha_dado_las_vueltas:		; El contador a cero y el flujo sigue por detras de la orden
	inc hl			;801b
	inc hl			;801c
	xor a			;801d
	ld (ix+00ah),a		;801e   ; Las vueltas, a cero
	call guarda_el_puntero		;8021
L_8024:
	inc (ix+000h)		;8024   ; El byte 0 sube uno: la nota de ahora se acaba ya
	jp anda_un_canal		;8027
pon_la_mezcla:		; Arma el registro 7 del PSG: por cada canal, si suena tono, si suena ruido, o ninguno
	ld a,(0e043h)		;802a   ; 0xE043: la mezcla de ahora
	ld e,a			;802d
	ld a,(ix+005h)		;802e   ; Los dos bits bajos del byte 5: tono y ruido
	and 003h		;8031
	ld d,a			;8033
	ld a,c			;8034   ; El numero de canal
	cp 001h		;8035
	jr z,L_803A		;8037
	dec a			;8039
L_803A:
	ld b,a			;803a
	bit 1,d		;803b   ; El bit 1: el ruido de este canal
	call z,enciende_ese_bit		;803d
	bit 1,d		;8040
	call nz,apaga_ese_bit		;8042
	ld a,b			;8045
	rlca			;8046   ; Tres bits mas arriba estan los del ruido
	rlca			;8047
	rlca			;8048
	bit 0,d		;8049   ; Y el bit 0: su tono
	call z,enciende_ese_bit		;804b
	bit 0,d		;804e
	call nz,apaga_ese_bit		;8050
L_8053:
	ld (0e043h),a		;8053   ; La mezcla nueva, apuntada
	ld e,a			;8056
	ld a,007h		;8057   ; El registro 7 del PSG
	jp 00093h		;8059   ; BIOS WRTPSG - Writes data to PSG-register
apaga_ese_bit:		; El bit puesto a cero: ese canal suena
	cpl			;805c
	and e			;805d
	ld e,a			;805e
	ret			;805f
enciende_ese_bit:		; El bit puesto a uno: ese canal calla
	or e			;8060
	ld e,a			;8061
	ret			;8062
suena:		; Lo que la interrupcion llama en cada cuadro (p00:4035), con los bancos 7 y 8 puestos.
	ld a,(0e047h)		;8063   ; 0xE047: con el efecto de ruido en marcha, manda el
	or a			;8066
	jp z,devuelve_los_registros		;8067
	ld a,001h		;806a   ; 0xE04C a uno: al acabar hay que devolver los registros
	ld (0e04ch),a		;806c
	ld e,0b8h		;806f   ; Mezcla 0xB8: los tres tonos callados y el ruido en C
	ld a,007h		;8071
	call 00093h		;8073   ; BIOS WRTPSG - Writes data to PSG-register | WRTPSG con A=7: el registro de mezcla, el que decide que canales suenan y cuales sacan ruido.
	ld hl,0e048h		;8076   ; 0xE048: el primer cuadro del efecto
	ld a,(hl)			;8079
	or a			;807a
	jr z,anda_el_efecto_de_ruido		;807b
	ld (hl),000h		;807d   ; Los cuatro bytes de la cuenta: 0, 7, 5 y 0x10
	inc hl			;807f
	ld (hl),007h		;8080
	inc hl			;8082
	ld (hl),005h		;8083
	inc hl			;8085
	ld (hl),010h		;8086
	call calla_los_canales		;8088   ; Los tres canales callados...
	ld e,0d6h		;808b   ; ...y el periodo 0xD6 en A y B
pon_tono_a_y_b:		; Escribe los registros 0, 2, 1 y 3 del PSG: los periodos de los canales A y B.
	xor a			;808d
	call 00093h		;808e   ; BIOS WRTPSG - Writes data to PSG-register | El registro 0: el byte bajo del periodo de A
	inc e			;8091
	ld a,002h		;8092   ; Y el 2: el de B
	call 00093h		;8094   ; BIOS WRTPSG - Writes data to PSG-register
	ld e,000h		;8097   ; Los registros 1 y 3, los bytes altos, a cero
	ld a,001h		;8099
	call 00093h		;809b   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,003h		;809e
	jp 00093h		;80a0   ; BIOS WRTPSG - Writes data to PSG-register
anda_el_efecto_de_ruido:		; Baja las dos cuentas del efecto: la de dentro le va quitando volumen y la de fuera le cambia el registro de ruido
	ld a,(0e04ah)		;80a3   ; 0xE04A: solo con el efecto puesto
	or a			;80a6
	ret z			;80a7
	inc hl			;80a8
	dec (hl)			;80a9   ; La cuenta de dentro
	jr z,pasa_de_paso_el_ruido		;80aa
	ld a,(hl)			;80ac
	and 001h		;80ad   ; Un cuadro de cada dos
	ret nz			;80af
	ld a,(0e04bh)		;80b0   ; 0xE04B: un escalon menos de volumen
	dec a			;80b3
	ld (0e04bh),a		;80b4
	ld e,a			;80b7
	jp pon_volumen		;80b8
pasa_de_paso_el_ruido:		; Agotada la cuenta de fuera, el efecto pasa al registro siguiente de 0x80D9; al acabarse, los canales callan
	inc hl			;80bb
	dec (hl)			;80bc   ; La cuenta de fuera
	jp z,calla_los_canales		;80bd   ; Y con ella agotada, se acabo el efecto
	ld a,(hl)			;80c0
	dec hl			;80c1
	ld (hl),006h		;80c2   ; Seis cuadros para el paso siguiente
	dec a			;80c4
	ld e,a			;80c5
	ld d,000h		;80c6
	ld hl,080d9h		;80c8   ; La tabla de 0x80D9: el periodo de cada paso
	add hl,de			;80cb
	ld e,(hl)			;80cc
	call pon_tono_a_y_b		;80cd
	ld a,00fh		;80d0   ; Y el volumen vuelve a 0x0F
	ld (0e04bh),a		;80d2
	ld e,a			;80d5
	jp pon_volumen		;80d6

; ----------------------------------------------------------------------
; DATOS registros_del_ruido: Cuatro bytes que 0x80C8 indexa con `ld hl,0x80D9
;   / add hl,de / ld e,(hl)`: el valor que se le pasa al PSG en cada paso del
;   efecto.
;   0x80d9..0x80dd  (4 bytes)
DATA_registros_del_ruido:
	defb 06bh,08eh,0aah,08eh	; 80d9

; ======================================================================
; CODIGO 0x80dd..0x831e  (577 bytes)
; ======================================================================


calla_los_canales:		; Pone E a cero y cae en 0x80E4, o sea deja a cero el volumen de los tres canales.
	ld e,000h		;80dd   ; Volumen cero
	ld a,00ah		;80df   ; El registro 10: el volumen de C
	call 00093h		;80e1   ; BIOS WRTPSG - Writes data to PSG-register
pon_volumen:		; Escribe E en los registros 9 y 8 del PSG: el volumen de los canales B y A.
	ld a,009h		;80e4   ; El registro 9: el de B
	call 00093h		;80e6   ; BIOS WRTPSG - Writes data to PSG-register
	dec a			;80e9   ; Y el 8: el de A
	jp 00093h		;80ea   ; BIOS WRTPSG - Writes data to PSG-register
devuelve_los_registros:		; Al acabarse el efecto de ruido, los cuatro periodos y los tres volumenes vuelven a lo que tenian los canales
	ld a,(0e04ch)		;80ed   ; 0xE04C: solo si el efecto habia pisado los registros
	or a			;80f0
	jp z,L_812E		;80f1
	xor a			;80f4   ; Y ya no hay nada que devolver
	ld (0e04ch),a		;80f5
	ld hl,0e01fh		;80f8   ; Los periodos guardados en las fichas
	ld e,(hl)			;80fb
	call 00093h		;80fc   ; BIOS WRTPSG - Writes data to PSG-register
	inc hl			;80ff
	inc a			;8100
	ld e,(hl)			;8101
	call 00093h		;8102   ; BIOS WRTPSG - Writes data to PSG-register
	ld hl,0e030h		;8105
	inc a			;8108
	ld e,(hl)			;8109
	call 00093h		;810a   ; BIOS WRTPSG - Writes data to PSG-register
	inc hl			;810d
	inc a			;810e
	ld e,(hl)			;810f
	call 00093h		;8110   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,(0e018h)		;8113   ; El volumen del canal A...
	ld e,a			;8116
	ld a,008h		;8117
	call 00093h		;8119   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,(0e029h)		;811c   ; ...el de B...
	ld e,a			;811f
	ld a,009h		;8120
	call 00093h		;8122   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,(0e03ah)		;8125   ; ...y el de C
	ld e,a			;8128
	ld a,00ah		;8129
	call 00093h		;812b   ; BIOS WRTPSG - Writes data to PSG-register
L_812E:
	ld a,(0e043h)		;812e   ; Y la mezcla que hubiera
	call L_8053		;8131
anda_los_tres_canales:		; Las tres fichas de 0x11 bytes de 0xE010, una detras de otra
	ld c,001h		;8134   ; El canal A: registro 1
	ld ix,0e010h		;8136   ; 0xE010: la primera ficha
	ld hl,0e044h		;813a   ; 0xE044: la cuenta de callar
	ld a,(hl)			;813d
	or a			;813e
	jr z,L_8164		;813f
	inc hl			;8141
	dec (hl)			;8142
	jr nz,L_8164		;8143
	ld (hl),060h		;8145   ; 0x60 cuadros por paso
	inc hl			;8147
	inc (hl)			;8148
	ld a,006h		;8149   ; Seis pasos y se calla del todo
	cp (hl)			;814b
	jr nz,L_8164		;814c
	ld a,(ix+002h)		;814e
	cp 0a9h		;8151   ; El canal que lleva el 0xA9 tiene ficha aparte
	jr nz,L_8159		;8153
	ld (ix+024h),000h		;8155
L_8159:
	xor a			;8159
	ld (hl),a			;815a
	ld (0e044h),a		;815b
	ld (ix+002h),a		;815e
	ld (ix+013h),a		;8161
L_8164:
	exx			;8164
	ld b,003h		;8165
	ld de,00011h		;8167   ; 0x11 bytes: la ficha siguiente
L_816A:
	exx			;816a
	ld a,(ix+002h)		;816b   ; El byte 2 a cero: este canal no suena
	or a			;816e
	jr nz,L_8176		;816f
	call calla_este_canal		;8171
	jr L_8179		;8174
L_8176:
	call anda_un_canal		;8176
L_8179:
	inc c			;8179   ; Dos registros de PSG por canal
	inc c			;817a
	exx			;817b
	add ix,de		;817c
	djnz L_816A		;817e
	ret			;8180
anda_un_canal:		; El interprete de un canal: saca el siguiente mando del flujo que apunta (IX+3, IX+4). 0xFE y los codigos por encima son ordenes; los de abajo, nota y duracion.
	ld a,(ix+002h)		;8181   ; El byte 2: el modo
	bit 7,a		;8184   ; Con el bit 7 puesto, el canal va por otro lado
	jp nz,anda_el_canal_de_melodia		;8186
	dec (ix+000h)		;8189   ; El byte 0: los cuadros que le quedan a la nota
	ret nz			;818c
L_818D:
	ld l,(ix+003h)		;818d   ; Los bytes 3 y 4: por donde va el flujo
	ld h,(ix+004h)		;8190
	ld a,(hl)			;8193   ; El byte de mando del canal.
	cp 0feh		;8194   ; 0xFE es la orden que salta al principio del banco.
	jp z,repite_el_flujo		;8196
	jp nc,calla_este_canal		;8199   ; Y por encima de 0xFE, el canal se calla
	ld a,(ix+002h)		;819c
	bit 7,a		;819f   ; El bit 7 del modo
	ld a,(hl)			;81a1
	jp nz,lee_el_mando_de_melodia		;81a2
	and 0f0h		;81a5   ; Los mandos 0x2x son los interruptores
	cp 020h		;81a7
	jr nz,L_81D7		;81a9
	ld a,(hl)			;81ab
	ld (ix+005h),a		;81ac   ; El byte 5: tono, ruido y envolvente
	inc hl			;81af
	ld a,(hl)			;81b0
	ld (ix+001h),a		;81b1   ; Y el byte 1: la duracion
	inc hl			;81b4
	ld a,(ix+005h)		;81b5
	cp 020h		;81b8   ; El 0x20 pelado no lleva nada detras
	jr nz,L_81C1		;81ba
	dec hl			;81bc
	ld b,000h		;81bd
	jr pon_la_nota		;81bf
L_81C1:
	bit 3,(ix+005h)		;81c1   ; El bit 3 del byte 5: lleva envolvente
	jr z,L_81D7		;81c5
	ld a,(hl)			;81c7
	ld e,a			;81c8
	ld a,00ch		;81c9
	call 00093h		;81cb   ; BIOS WRTPSG - Writes data to PSG-register | Registros 12 y 11 del PSG: el periodo de la envolvente.
	inc hl			;81ce
	ld a,(hl)			;81cf   ; Y el 11, el byte bajo
	ld e,a			;81d0
	ld a,00bh		;81d1
	call 00093h		;81d3   ; BIOS WRTPSG - Writes data to PSG-register
	inc hl			;81d6
L_81D7:
	ld a,(hl)			;81d7   ; El mando 0x1x: el periodo del ruido
	and 0f0h		;81d8
	cp 010h		;81da
	jr nz,L_81E9		;81dc
	ld a,(hl)			;81de
	and 00fh		;81df   ; Su nibble bajo, por dos
	add a,a			;81e1
	ld e,a			;81e2
	ld a,006h		;81e3
	call 00093h		;81e5   ; BIOS WRTPSG - Writes data to PSG-register | Registro 6: el periodo del ruido.
	inc hl			;81e8
L_81E9:
	ld a,(hl)			;81e9   ; El nibble alto: la nota
	and 0f0h		;81ea
	ld b,a			;81ec
	xor (hl)			;81ed   ; Y el bajo, con el byte de detras: el periodo
	ld d,a			;81ee
	inc hl			;81ef
	ld e,(hl)			;81f0
pon_la_nota:		; Escribe el periodo en los dos registros del canal y arranca la cuenta de la nota
	call guarda_el_puntero		;81f1
	ex de,hl			;81f4
	call L_82F0		;81f5
	ld a,b			;81f8
	rrca			;81f9   ; El nibble alto, abajo: el volumen
	rrca			;81fa
	rrca			;81fb
	rrca			;81fc
	ld h,a			;81fd
	ld a,(ix+001h)		;81fe
	ld (ix+000h),a		;8201   ; (IX+1) es la duracion, y se recarga en (IX+0), que es la cuenta atras.
	jr escribe_volumen_y_mezcla		;8204
calla_este_canal:		; El byte 2 a cero, sin dibujo y sin interruptores
	xor a			;8206   ; El byte 2 a cero: el canal no suena
	ld (ix+002h),a		;8207
	ld (ix+00ch),a		;820a
	ld h,a			;820d
	ld (ix+005h),a		;820e
	jr escribe_volumen_y_mezcla		;8211
baja_un_escalon_mas:		; Un escalon de mas en la caida
	dec (ix+009h)		;8213
baja_el_volumen:		; El byte 8 baja de uno en uno hasta cero
	ld a,(ix+008h)		;8216   ; El byte 8: el volumen de ahora
	dec a			;8219
	ret m			;821a   ; Por debajo de cero ya no
	ld (ix+008h),a		;821b
	ld h,a			;821e
escribe_volumen_y_mezcla:		; La mezcla, y el volumen del canal -o la envolvente, si la lleva-
	call pon_la_mezcla		;821f   ; La mezcla, por si ha cambiado
	ld a,c			;8222   ; El registro de volumen de este canal: 8, 9 o 10
	rrca			;8223
	add a,088h		;8224
	ld d,a			;8226
	bit 3,(ix+005h)		;8227   ; El bit 3 del byte 5: lleva envolvente
	jr z,L_8236		;822b
	ld e,h			;822d
	ld a,00dh		;822e   ; El registro 13: la forma de la envolvente
	call 00093h		;8230   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,010h		;8233   ; Y el volumen con el bit 4: lo manda la envolvente
	ld h,a			;8235
L_8236:
	ld a,d			;8236
	ld e,h			;8237
	jp 00093h		;8238   ; BIOS WRTPSG - Writes data to PSG-register
anda_el_canal_de_melodia:		; Con el bit 7 del modo puesto, la nota ademas se va apagando sola: el byte 9 dice cuando empieza a caer
	dec (ix+000h)		;823b   ; Los cuadros que le quedan a la nota
	jp z,L_818D		;823e   ; Agotada, al mando siguiente
	dec (ix+009h)		;8241   ; El byte 9: cuando empieza a caer
	ld a,(ix+009h)		;8244
	cp (ix+000h)		;8247
	jr nz,baja_un_escalon_mas		;824a
	ld e,a			;824c
	ld a,(ix+00eh)		;824d   ; El byte 14: el suelo de la caida
	cp e			;8250
	ld a,e			;8251
	jr nc,baja_el_volumen		;8252
	ret			;8254
lee_el_mando_de_melodia:		; Los mandos 0xDx, 0xFx y 0xEx ajustan tiempo, volumen, envolvente y octava; el ultimo nibble es la nota
	ld a,(hl)			;8255   ; El mando 0xDx: la unidad de tiempo
	and 0f0h		;8256
	cp 0d0h		;8258
	ld a,(hl)			;825a
	jr nz,L_8264		;825b
	and 00fh		;825d
	ld (ix+00bh),a		;825f   ; El byte 11: lo que dura una figura
	inc hl			;8262
	ld a,(hl)			;8263
L_8264:
	cp 0f0h		;8264   ; El mando 0xFx: el volumen
	jr c,L_8282		;8266
	and 00fh		;8268
	inc a			;826a
	inc a			;826b
	ld (ix+007h),a		;826c   ; El byte 7: el volumen de partida
	inc hl			;826f
	ld a,(hl)			;8270
	and 0f0h		;8271   ; Y el byte de detras trae los dos tiempos
	rrca			;8273
	rrca			;8274
	rrca			;8275
	rrca			;8276
	ld (ix+00dh),a		;8277   ; El nibble alto, al byte 13...
	ld a,(hl)			;827a
	and 00fh		;827b   ; ...y el bajo, al 14
	ld (ix+00eh),a		;827d
	inc hl			;8280
	ld a,(hl)			;8281
L_8282:
	cp 0e0h		;8282   ; El mando 0xEx: sostenido u octava
	jr c,L_8297		;8284
	and 00fh		;8286
	bit 3,a		;8288   ; El bit 3: sostenido
	jr z,L_8292		;828a
	ld (ix+00ch),a		;828c   ; El byte 12: medio tono mas
	inc hl			;828f
	jr lee_el_mando_de_melodia		;8290
L_8292:
	ld (ix+006h),a		;8292   ; Y si no, el byte 6: el salto de octava
	inc hl			;8295
	ld a,(hl)			;8296
L_8297:
	and 00fh		;8297   ; El nibble bajo: cuantas figuras dura
	ld b,a			;8299
	ld a,(ix+00bh)		;829a
	jr z,L_82A4		;829d
L_829F:
	add a,(ix+00bh)		;829f   ; La unidad de tiempo, sumada tantas veces
	djnz L_829F		;82a2
L_82A4:
	ld (ix+001h),a		;82a4   ; El byte 1: lo que dura la nota
	ld a,(hl)			;82a7
	call guarda_el_puntero		;82a8
	and 0f0h		;82ab   ; El nibble alto: la nota
	rrca			;82ad
	rrca			;82ae
	rrca			;82af
	rrca			;82b0
	ld b,a			;82b1
	sub 00ch		;82b2   ; La nota 0x0C es el silencio
	jr z,L_82C9		;82b4
	ld e,(ix+007h)		;82b6
	ld a,(0e044h)		;82b9   ; 0xE044: callando, el volumen baja de golpe
	or a			;82bc
	ld a,e			;82bd
	jr z,L_82C9		;82be
	ld a,(0e046h)		;82c0
	ld d,a			;82c3
	ld a,e			;82c4
	sub d			;82c5
	jr nc,L_82C9		;82c6
	xor a			;82c8
L_82C9:
	ld (ix+008h),a		;82c9   ; El byte 8: el volumen de ahora
	ld d,a			;82cc
	ld e,(ix+001h)		;82cd
	ld (ix+000h),e		;82d0   ; El byte 0: la cuenta atras de la nota
	ld a,(ix+00dh)		;82d3   ; Y el byte 9: cuando empieza a caer
	add a,e			;82d6
	ld (ix+009h),a		;82d7
	ld a,b			;82da
	ld hl,0831eh		;82db   ; La tabla de 0x831E: el periodo de las doce notas
	add a,l			;82de
	ld l,a			;82df
	jr nc,L_82E3		;82e0
	inc h			;82e2
L_82E3:
	ld l,(hl)			;82e3
	ld h,000h		;82e4
	ld a,(ix+006h)		;82e6   ; El byte 6: cada octava, el periodo por dos
	or a			;82e9
	jr z,L_82F0		;82ea
	ld b,a			;82ec
L_82ED:
	add hl,hl			;82ed
	djnz L_82ED		;82ee
L_82F0:
	ld a,(ix+00ch)		;82f0   ; El byte 12: el sostenido sube uno el periodo
	or a			;82f3
	jr z,L_82F7		;82f4
	inc hl			;82f6
L_82F7:
	ld a,c			;82f7   ; El registro alto del canal...
	ld e,h			;82f8
	ld (ix+010h),e		;82f9
	call 00093h		;82fc   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,c			;82ff
	dec a			;8300
	ld e,l			;8301
	ld (ix+00fh),e		;8302   ; ...y el bajo, guardados los dos en la ficha
	call 00093h		;8305   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,(ix+002h)		;8308   ; El bit 7 del modo: en melodia, se sigue por otro lado
	bit 7,a		;830b
	ret z			;830d
	ld h,d			;830e
	ld (ix+005h),002h		;830f   ; El byte 5 a dos: solo tono
	jp escribe_volumen_y_mezcla		;8313
guarda_el_puntero:		; Deja en (IX+3, IX+4) por donde se ha quedado el flujo del canal.
	inc hl			;8316
	ld (ix+003h),l		;8317
	ld (ix+004h),h		;831a
	ret			;831d

; ----------------------------------------------------------------------
; DATOS tabla_descendente: Diez bytes en cuesta abajo (0x6B, 0x65, 0x5F, 0x5A,
;   0x55, 0x50, 0x4C, 0x47, 0x43, 0x40) que lee 0x82DB.
;   0x831e..0x8328  (10 bytes)
DATA_tabla_descendente:
	defb 06bh,065h,05fh,05ah,055h,050h,04ch,047h,043h,040h	; 831e  ke_ZUPLGC@

; ----------------------------------------------------------------------
; DATOS tabla_de_sonidos: Ochenta palabras: la direccion de cada sonido. La
;   lee 0x4A49 del banco 0 con `ld de,0x8328` y `call 0x4062` (DE += A), con A
;   = numero de sonido por dos. La entrada 0 (0x393C) no es una direccion del
;   cartucho: el sonido 0 no existe. Las tres ultimas apuntan a 0xA3DE, el
;   primer byte de relleno del banco 8, o sea a un sonido vacio.
;   0x8328..0x83c8  (160 bytes)
DATA_tabla_de_sonidos:
	defw 0393ch,083c8h	; 8328  -> 0x393c DATA_datos_de_sonido
	defw 083c8h,083f3h	; 832c  -> DATA_datos_de_sonido 0x83f3
	defw 08400h,0841dh	; 8330
	defw 08444h,08482h	; 8334
	defw 084bbh,084d2h	; 8338
	defw 084ffh,0853ch	; 833c
	defw 08453h,0856fh	; 8340
	defw 0858ah,08627h	; 8344
	defw 08684h,086c9h	; 8348
	defw 085c4h,086feh	; 834c
	defw 08742h,08783h	; 8350
	defw 087a2h,0887fh	; 8354
	defw 0891ch,089c4h	; 8358
	defw 08a40h,08ac3h	; 835c
	defw 08b4fh,08beah	; 8360
	defw 08c57h,08cf5h	; 8364
	defw 08e1eh,08e8fh	; 8368
	defw 08f4dh,0915eh	; 836c
	defw 0929fh,094cfh	; 8370
	defw 09682h,0974bh	; 8374
	defw 09811h,0995fh	; 8378
	defw 0999ah,099a8h	; 837c
	defw 099e1h,09a7ah	; 8380
	defw 09ae0h,09b1fh	; 8384
	defw 09b99h,09c53h	; 8388
	defw 095a5h,095f0h	; 838c
	defw 09635h,09cach	; 8390
	defw 09d2ah,09d4ah	; 8394
	defw 09d5dh,09d80h	; 8398
	defw 09da3h,09db4h	; 839c
	defw 09e1fh,09e8ah	; 83a0
	defw 09ef5h,09f38h	; 83a4
	defw 09f7bh,09fbfh	; 83a8
	defw 0a034h,0a05dh	; 83ac
	defw 0a09ah,0a0fah	; 83b0
	defw 0a15ah,0a1c6h	; 83b4
	defw 0a249h,0a2cch	; 83b8
	defw 0a359h,0a38ah	; 83bc
	defw 0a3beh,0a3deh	; 83c0
	defw 0a3deh,0a3deh	; 83c4

; ----------------------------------------------------------------------
; DATOS datos_de_sonido: Las melodias y los efectos, uno detras de otro, en el
;   orden en el que los nombra la tabla de arriba: 0x83C8, 0x83F3, 0x8400, ...
;   0x9FBF. Siguen en el banco 8, que se mapea a la vez.
;   0x83c8..0xa000  (7224 bytes)
DATA_datos_de_sonido:
	defb 022h,001h,0c0h,050h,0c0h,054h,0c0h,058h,0c0h,060h,0b0h,054h,0b0h,058h,0b0h,060h	; 83c8  "..P.T.X.`.T.X.`
	defb 0c0h,050h,0c0h,054h,0c0h,058h,0c0h,060h,0b0h,054h,0b0h,058h,0b0h,060h,0a0h,058h	; 83d8  .P.T.X.`.T.X.`.X
	defb 0a0h,060h,090h,058h,090h,060h,080h,060h,070h,060h,0ffh,02ah,003h,000h,008h,0e0h	; 83e8  .`.X.`.`p`.*....
	defb 012h,0e0h,010h,0e0h,00eh,0e0h,00ch,0ffh,022h,001h,0f0h,040h,0f0h,058h,0f0h,078h	; 83f8  ........"..@.X.x
	defb 0f0h,0a0h,0f0h,008h,0a0h,018h,0a0h,038h,0a0h,060h,0a0h,008h,080h,020h,080h,048h	; 8408  .......8.`... .H
	defb 080h,020h,060h,048h,0ffh,022h,001h,0f0h,040h,0f0h,0c0h,0f1h,040h,0f1h,0c0h,0f2h	; 8418  . `H."..@...@...
	defb 040h,0f2h,0c0h,0e0h,040h,0e1h,000h,0e1h,0c0h,0e2h,080h,0e3h,040h,0d0h,040h,0d1h	; 8428  @...@.......@.@.
	defb 040h,0d2h,040h,0d3h,040h,0c0h,040h,0c1h,0c0h,0c3h,040h,0ffh,022h,001h,0f0h,020h	; 8438  @.@.@.@...@."..
	defb 080h,060h,0f0h,020h,080h,060h,0c0h,020h,040h,060h,0ffh,023h,002h,01fh,0a5h,050h	; 8448  .`. .`. @`.#...P
	defb 0b6h,050h,0c7h,050h,023h,004h,015h,0e8h,050h,000h,000h,023h,002h,01fh,0c7h,050h	; 8458  .P.P#...P..#...P
	defb 0d8h,050h,0e9h,050h,023h,004h,015h,0fah,052h,000h,000h,023h,002h,01fh,0c9h,050h	; 8468  .P.P#...R..#...P
	defb 0dah,000h,0eah,050h,023h,004h,015h,0fbh,052h,0ffh,022h,001h,0f1h,0ach,0f1h,0e1h	; 8478  ...P#...R.".....
	defb 0f2h,03ah,0f1h,03fh,0f1h,067h,0f1h,0abh,0f1h,00fh,0f0h,0efh,0f1h,01eh,0f0h,0d5h	; 8488  .:.?.g..........
	defb 0f0h,06ah,0f0h,065h,0f0h,06ah,0f0h,065h,0f0h,0a9h,0f0h,08fh,0f0h,054h,0f0h,054h	; 8498  .j.e.j.e.....T.T
	defb 0f0h,054h,0f0h,0d6h,0f0h,0cah,0f0h,0beh,0f0h,0b4h,0f0h,0aah,0e0h,06bh,0e0h,035h	; 84a8  .T...........k.5
	defb 0e0h,06bh,0ffh,022h,002h,0d0h,040h,0d0h,050h,0d0h,070h,0d0h,0a0h,0c0h,040h,0c0h	; 84b8  .k."..@.P.p...@.
	defb 050h,0c0h,070h,0b0h,030h,0b0h,040h,0a0h,030h,0ffh,022h,001h,0e0h,060h,0e0h,080h	; 84c8  P.p.0.@.0."..`..
	defb 0e0h,0c0h,0e1h,000h,0e1h,040h,0e1h,080h,0e1h,040h,0e1h,000h,0e0h,0c0h,0e0h,080h	; 84d8  .....@...@......
	defb 0e0h,060h,0c0h,080h,0c0h,0c0h,0c1h,000h,0c1h,040h,0c1h,080h,0c1h,040h,0c1h,000h	; 84e8  .`.......@...@..
	defb 0c0h,0c0h,0c0h,080h,0c0h,060h,0ffh,022h,001h,0f0h,080h,0e1h,000h,0f1h,080h,0f2h	; 84f8  .....`."........
	defb 000h,0d1h,000h,0e2h,080h,0e3h,000h,0d1h,000h,0d3h,080h,0d4h,000h,0d1h,000h,0c4h	; 8508  ................
	defb 080h,0d1h,000h,0c5h,000h,0e1h,080h,0e1h,040h,0d1h,000h,0d0h,0c0h,0c0h,080h,0c0h	; 8518  ........@.......
	defb 040h,0b0h,020h,0d1h,000h,0d0h,0c0h,0c0h,080h,0c0h,040h,0b0h,020h,0c0h,080h,0c0h	; 8528  @. .......@. ...
	defb 040h,0b0h,020h,0ffh,023h,001h,015h,0f0h,020h,0e1h,000h,0d1h,080h,0c2h,000h,023h	; 8538  @. .#... ......#
	defb 001h,01fh,0f0h,025h,0f0h,01ah,0f0h,015h,0e0h,010h,0e0h,02ah,0d0h,020h,0d0h,010h	; 8548  ...%.......*. ..
	defb 0c0h,00ah,0c0h,025h,0b0h,01ah,0b0h,015h,0a0h,010h,0a0h,02ah,0a0h,020h,090h,010h	; 8558  ...%.......*. ..
	defb 090h,00ah,090h,025h,090h,01ah,0ffh,022h,001h,0f0h,080h,0f1h,000h,0e1h,080h,0e2h	; 8568  ...%..."........
	defb 000h,0d2h,080h,0d3h,000h,0e1h,080h,0e1h,040h,0d1h,000h,080h,0c0h,080h,080h,080h	; 8578  ........@.......
	defb 060h,0ffh,022h,001h,0f0h,020h,0f0h,0a0h,0f1h,010h,0f1h,070h,0e1h,0c0h,0e2h,000h	; 8588  `.".. .....p....
	defb 0e2h,030h,0d2h,050h,0d2h,060h,023h,002h,01dh,0f2h,080h,0e3h,080h,0d4h,080h,023h	; 8598  .0.P.`#........#
	defb 001h,01fh,0f2h,080h,0d3h,080h,0b4h,080h,023h,006h,01fh,0e3h,000h,0c3h,040h,0a3h	; 85a8  ........#.....@.
	defb 080h,083h,0c0h,074h,000h,064h,040h,054h,080h,044h,0c0h,0ffh,022h,001h,0f2h,000h	; 85b8  ...t.d@T.D.."...
	defb 0f1h,0a0h,0f1h,040h,0f0h,0e0h,0f0h,080h,0f0h,060h,0f0h,040h,0f0h,020h,0e2h,000h	; 85c8  ...@.....`.@. ..
	defb 0e1h,0a0h,0e1h,040h,0e0h,0e0h,0e0h,080h,0e0h,060h,0e0h,040h,0e0h,020h,0d2h,000h	; 85d8  ...@.....`.@. ..
	defb 0d1h,0a0h,0d1h,040h,0d0h,0e0h,0d0h,080h,0d0h,060h,0d0h,040h,0d0h,020h,0c2h,000h	; 85e8  ...@.....`.@. ..
	defb 0c1h,0a0h,0c1h,040h,0c0h,0e0h,0c0h,080h,0c0h,060h,0c0h,040h,0c0h,020h,0b2h,000h	; 85f8  ...@.....`.@. ..
	defb 0b1h,0a0h,0b1h,040h,0b0h,0e0h,0b0h,080h,0b0h,060h,0b0h,040h,0b0h,020h,092h,000h	; 8608  ...@.....`.@. ..
	defb 091h,0a0h,091h,040h,090h,0e0h,090h,080h,090h,060h,090h,040h,090h,020h,0ffh,022h	; 8618  ...@.....`.@. ."
	defb 001h,0f0h,020h,0f0h,0a0h,0f1h,010h,0f1h,070h,0f1h,0c0h,0f2h,000h,0f2h,030h,0f2h	; 8628  .. .....p.....0.
	defb 050h,0f2h,060h,0e0h,060h,0e0h,0a0h,0e1h,010h,0e1h,070h,0e1h,0c0h,0e2h,000h,0e2h	; 8638  P.`.`.....p.....
	defb 030h,0e2h,050h,0e2h,060h,0c0h,060h,0c0h,0a0h,0c1h,010h,0c1h,070h,0c1h,0c0h,0c2h	; 8648  0.P.`.`.....p...
	defb 000h,0c2h,030h,0c2h,050h,0c2h,060h,0d0h,060h,0d0h,0a0h,0d1h,010h,0d1h,070h,0d1h	; 8658  ..0.P.`.`.....p.
	defb 0c0h,0d2h,000h,0d2h,030h,0d2h,050h,0d2h,060h,0c0h,060h,0c0h,0a0h,0c1h,010h,0c1h	; 8668  ....0.P.`.`.....
	defb 070h,0c1h,0c0h,0c2h,000h,0c2h,030h,0c2h,050h,0c2h,060h,0ffh,022h,001h,0d0h,0e2h	; 8678  p.....0.P.`."...
	defb 0e0h,0aah,0f0h,08fh,0f0h,086h,0f0h,08fh,0f0h,086h,0f0h,08fh,0f0h,086h,0f0h,08fh	; 8688  ................
	defb 0e0h,086h,0e0h,08fh,0d0h,086h,0d0h,08fh,0e0h,086h,0e0h,08fh,0f0h,071h,0f0h,055h	; 8698  .............q.U
	defb 0f0h,047h,0f0h,042h,0f0h,047h,0f0h,042h,0e0h,047h,0e0h,042h,0e0h,047h,0d0h,042h	; 86a8  .G.B.G.B.G.B.G.B
	defb 0d0h,047h,0d0h,042h,0c0h,047h,0c0h,042h,0c0h,047h,0c0h,042h,0b0h,047h,0b0h,042h	; 86b8  .G.B.G.B.G.B.G.B
	defb 0ffh,022h,002h,0f0h,082h,0f0h,08fh,0f0h,082h,0f0h,08fh,0f0h,082h,0f0h,08fh,022h	; 86c8  ."............."
	defb 001h,0f0h,08ch,0f0h,084h,0f0h,08ch,0e0h,080h,0e0h,088h,0e0h,080h,0e0h,078h,0e0h	; 86d8  ..............x.
	defb 088h,0d0h,078h,0d0h,070h,0d0h,078h,0c0h,070h,0c0h,068h,0c0h,070h,0a0h,068h,0a0h	; 86e8  ..x.p.x.p.h.p.h.
	defb 060h,0a0h,068h,090h,05ch,0ffh,023h,001h,018h,0f1h,000h,0f2h,000h,0f3h,000h,0e4h	; 86f8  `.h.\.#.........
	defb 000h,0e5h,000h,0e6h,000h,0d7h,000h,0c8h,000h,023h,001h,01fh,0f6h,000h,0f2h,080h	; 8708  .........#......
	defb 0f3h,000h,0e3h,080h,0e4h,000h,0e4h,080h,0d5h,000h,0d5h,080h,023h,006h,01fh,0f3h	; 8718  ............#...
	defb 000h,0f3h,040h,0e3h,080h,0e3h,0c0h,0d4h,000h,0c4h,040h,0c4h,080h,0b4h,0c0h,0a5h	; 8728  ..@.......@.....
	defb 000h,095h,040h,085h,080h,075h,0c0h,066h,000h,0ffh,022h,005h,0f0h,054h,022h,002h	; 8738  ..@..u.f.."..T".
	defb 0f0h,090h,022h,005h,0f0h,054h,022h,002h,0f0h,090h,022h,005h,0f0h,054h,022h,002h	; 8748  .."..T"..."..T".
	defb 0f0h,090h,022h,005h,0e0h,054h,022h,002h,0e0h,090h,022h,005h,0d0h,054h,022h,002h	; 8758  .."..T"..."..T".
	defb 0d0h,090h,022h,005h,0c0h,054h,022h,002h,0c0h,090h,022h,005h,0b0h,054h,022h,002h	; 8768  .."..T"..."..T".
	defb 0b0h,090h,022h,005h,0a0h,054h,022h,002h,0a0h,090h,0ffh,022h,005h,0f0h,0ddh,0f0h	; 8778  .."..T"...."....
	defb 01dh,0e0h,0ddh,0e0h,01dh,0d0h,0ddh,0d0h,01dh,0b0h,0ddh,0b0h,01dh,090h,0ddh,090h	; 8788  ................
	defb 01dh,070h,0ddh,070h,01dh,060h,0ddh,060h,01dh,0ffh,0d6h,0fch,053h,0e3h,021h,021h	; 8798  .p.p.`.`....S.!!
	defb 0e2h,021h,0e3h,020h,021h,021h,020h,0e1h,001h,001h,0e3h,021h,021h,0e2h,021h,0e3h	; 87a8  .!. !! ....!!.!.
	defb 020h,021h,021h,020h,0fdh,043h,0e1h,000h,0e2h,0b0h,0e1h,001h,000h,0e3h,001h,001h	; 87b8   !! .C..........
	defb 0fch,053h,0e3h,0c0h,020h,021h,021h,020h,0fdh,043h,0e1h,000h,0e2h,0b0h,0e1h,001h	; 87c8  .S.. !! .C......
	defb 042h,032h,022h,032h,041h,051h,0fch,053h,0e3h,041h,041h,0fch,090h,0e1h,061h,0fch	; 87d8  B2"2AQ.S.AA...a.
	defb 053h,0e3h,040h,041h,041h,040h,0fdh,053h,0e1h,060h,050h,061h,0c0h,062h,061h,0c2h	; 87e8  S.@AA@.S.`Pa.ba.
	defb 061h,060h,091h,091h,0c0h,062h,061h,0c2h,061h,060h,091h,090h,0c0h,0fch,045h,0e3h	; 87f8  a`...ba.a`....E.
	defb 080h,0e2h,030h,060h,0a0h,0e1h,000h,030h,060h,030h,000h,0e2h,070h,060h,030h,0d4h	; 8808  ..0`...0`0..p`0.
	defb 0e3h,080h,0e2h,030h,060h,0a0h,0e1h,000h,030h,0d6h,0e3h,070h,0e2h,020h,050h,090h	; 8818  ...0`...0..p. P.
	defb 0b0h,0e1h,020h,050h,020h,0e2h,0b0h,070h,050h,020h,0d4h,0e3h,040h,0e2h,020h,050h	; 8828  .. P ..pP ..@. P
	defb 090h,0b0h,0e1h,020h,0d6h,0e3h,030h,0e2h,010h,040h,080h,0a0h,0e1h,010h,040h,010h	; 8838  ... ..0..@....@.
	defb 0e2h,0a0h,050h,040h,010h,0e3h,030h,0a0h,0e2h,010h,0e3h,020h,0fch,062h,0e1h,008h	; 8848  ..P@..0.... .b..
	defb 0fch,074h,0e3h,001h,000h,031h,031h,0fch,062h,0e1h,008h,0fch,074h,0e3h,001h,000h	; 8858  .t...11.b...t...
	defb 0e2h,061h,061h,0c0h,060h,061h,061h,050h,064h,060h,050h,030h,0fch,066h,00ch,0fch	; 8868  .aa.`aaPd`P0.f..
	defb 074h,031h,031h,0feh,0ffh,0a2h,087h,0d6h,0fch,053h,0e4h,021h,021h,0e3h,021h,0e4h	; 8878  t11......S.!!.!.
	defb 020h,021h,021h,020h,0e2h,021h,021h,0e4h,021h,021h,0e3h,021h,0e4h,020h,021h,021h	; 8888   !! .!!.!!.!. !!
	defb 020h,0e2h,021h,021h,0e4h,021h,021h,0e2h,021h,0e4h,020h,021h,021h,020h,0e2h,021h	; 8898   .!!.!!.!. !! .!
	defb 021h,0fdh,043h,0e3h,021h,020h,011h,010h,001h,000h,010h,011h,020h,020h,031h,0fch	; 88a8  !.C.! ......  1.
	defb 053h,0e4h,041h,041h,0e2h,041h,0e4h,040h,041h,041h,040h,0e2h,040h,030h,041h,0fdh	; 88b8  S.AA.A.@AA@.@0A.
	defb 063h,0e4h,041h,041h,0e2h,041h,0e4h,040h,041h,041h,040h,071h,071h,041h,041h,0e2h	; 88c8  c.AA.A.@AA@qqAA.
	defb 041h,0e4h,040h,041h,041h,040h,051h,070h,0fch,028h,0e1h,0ach,0a0h,0a1h,09ch,090h	; 88d8  A.@AA@Qp.(......
	defb 091h,08ch,050h,052h,0e4h,021h,021h,0e3h,021h,0e4h,020h,021h,021h,020h,051h,051h	; 88e8  ..PR.!!.!. !! QQ
	defb 021h,021h,0e3h,021h,0e4h,020h,021h,021h,020h,0fdh,028h,081h,081h,0c0h,080h,081h	; 88f8  !!.!. !! .(.....
	defb 081h,070h,084h,080h,070h,060h,022h,080h,0e3h,001h,021h,001h,021h,000h,031h,031h	; 8908  .p..p`"...!.!.11
	defb 0feh,0ffh,07fh,088h,0d7h,0fch,037h,0e1h,0c0h,020h,021h,0c0h,010h,011h,0c0h,020h	; 8918  ......7.. !....
	defb 020h,020h,0e2h,091h,0e1h,011h,0c0h,020h,021h,0c0h,010h,011h,0c0h,020h,020h,020h	; 8928    ..... !....
	defb 0e2h,091h,0e1h,011h,0c0h,020h,021h,0c0h,010h,011h,0c0h,020h,020h,020h,0e2h,091h	; 8938  ..... !....   ..
	defb 0e1h,011h,0c0h,020h,021h,0c0h,010h,011h,0c0h,020h,020h,020h,0e2h,091h,0e1h,011h	; 8948  ... !....   ....
	defb 0c0h,0e2h,050h,051h,0a1h,080h,0a0h,0c0h,0e1h,011h,010h,031h,0c0h,0e2h,050h,051h	; 8958  ..PQ.......1..PQ
	defb 0a1h,080h,0a0h,0c0h,0e1h,011h,010h,0c0h,0e2h,050h,051h,0a1h,080h,0a0h,0c0h,0e1h	; 8968  .........PQ.....
	defb 011h,010h,031h,0c0h,0e2h,050h,051h,0a1h,080h,0a0h,0c0h,0e1h,011h,010h,0e1h,0c0h	; 8978  ..1..PQ.........
	defb 020h,021h,0c0h,010h,011h,0c0h,020h,020h,020h,0e2h,091h,0e1h,011h,0c0h,020h,021h	; 8988   !....   ..... !
	defb 0c0h,010h,011h,0c0h,020h,020h,020h,0e2h,091h,0e1h,011h,0c0h,020h,021h,0c0h,011h	; 8998  ....   ..... !..
	defb 0e2h,090h,0e1h,0c0h,020h,021h,0c0h,011h,0e2h,090h,0d5h,0fch,023h,0e1h,021h,011h	; 89a8  .... !......#.!.
	defb 021h,011h,0e2h,091h,0e1h,011h,021h,011h,0feh,0ffh,01ch,089h,0d7h,0fdh,043h,0e4h	; 89b8  !.....!.......C.
	defb 091h,0e3h,010h,020h,021h,011h,062h,010h,021h,0e4h,0b1h,091h,0e3h,010h,020h,021h	; 89c8  ... !.b.!..... !
	defb 011h,062h,010h,021h,0e4h,0b1h,091h,0e3h,010h,020h,021h,011h,062h,010h,021h,0feh	; 89d8  .b.!..... !.b.!.
	defb 002h,0dch,089h,0e4h,0b1h,0e3h,001h,050h,030h,081h,041h,051h,021h,001h,001h,050h	; 89e8  .......P0.AQ!..P
	defb 030h,081h,041h,051h,021h,001h,050h,030h,081h,041h,051h,021h,001h,001h,050h,030h	; 89f8  0.AQ!.P0.AQ!..P0
	defb 081h,041h,051h,021h,0e4h,091h,0e3h,010h,020h,021h,011h,062h,010h,021h,0e4h,0b1h	; 8a08  .AQ!.... !.b.!..
	defb 0e4h,091h,0e3h,010h,020h,021h,011h,062h,010h,021h,0e4h,0b1h,091h,0e3h,010h,020h	; 8a18  .... !.b.!.....
	defb 021h,011h,0e4h,091h,0e3h,010h,020h,021h,011h,0d5h,0e4h,091h,0e3h,011h,021h,011h	; 8a28  !..... !......!.
	defb 021h,011h,021h,011h,0feh,0ffh,0c4h,089h,0d6h,0fdh,053h,0e1h,002h,001h,000h,001h	; 8a38  !.!.......S.....
	defb 021h,021h,0e3h,071h,071h,0e1h,032h,032h,051h,051h,0e3h,071h,070h,071h,070h,0fdh	; 8a48  !!.qq.22QQ.qpqp.
	defb 039h,0e1h,077h,050h,040h,000h,0e2h,074h,050h,040h,000h,0e3h,074h,0e2h,042h,072h	; 8a58  9.wP@..tP@..t.Br
	defb 0e1h,001h,077h,050h,040h,000h,0e2h,074h,050h,040h,000h,0e3h,074h,0e2h,072h,0e1h	; 8a68  ..wP@..tP@..t.r.
	defb 002h,041h,0e1h,077h,050h,040h,000h,0e2h,052h,020h,040h,0d4h,0fdh,045h,053h,043h	; 8a78  .A.wP@..R @..ESC
	defb 053h,073h,053h,073h,0d6h,0fdh,073h,080h,0a0h,0e1h,000h,020h,030h,020h,000h,0e2h	; 8a88  SsSs..s.... 0 ..
	defb 0a0h,080h,0a0h,080h,070h,050h,070h,050h,030h,0fdh,045h,022h,052h,0a2h,0e1h,032h	; 8a98  ....pPpP0.E"R..2
	defb 083h,0fdh,039h,077h,050h,040h,000h,0e2h,071h,070h,0e1h,001h,020h,031h,034h,030h	; 8aa8  ..9wP@..qp.. 140
	defb 051h,054h,050h,071h,071h,050h,079h,0feh,0ffh,040h,08ah,0d6h,0fdh,028h,0e2h,092h	; 8ab8  QTPqqPy..@...(..
	defb 091h,090h,091h,0b1h,0b1h,0e4h,071h,071h,0e1h,002h,002h,021h,021h,0e4h,071h,070h	; 8ac8  ......qq...!!.qp
	defb 071h,070h,0fdh,042h,0e3h,001h,0e2h,001h,0e3h,001h,0e2h,001h,0feh,004h,0dch,08ah	; 8ad8  qp.B............
	defb 0e4h,0a1h,0e3h,0a1h,0e4h,0a1h,0e3h,0a1h,0feh,004h,0e8h,08ah,0e4h,091h,0e3h,091h	; 8ae8  ................
	defb 0e4h,091h,0e3h,091h,0feh,002h,0f4h,08ah,0e4h,021h,0e3h,021h,0e4h,021h,0e3h,021h	; 8af8  .........!.!.!.!
	defb 0e4h,041h,0e3h,041h,0e4h,041h,0e3h,041h,0e4h,051h,0e3h,051h,0e4h,051h,0e3h,051h	; 8b08  .A.A.A.A.Q.Q.Q.Q
	defb 0feh,002h,010h,08bh,0e4h,071h,0e3h,071h,0e4h,071h,0e3h,071h,0feh,002h,01ch,08bh	; 8b18  .....q.q.q.q....
	defb 0e4h,001h,0e3h,001h,0e4h,001h,0e3h,001h,0feh,002h,028h,08bh,0e4h,031h,0e3h,031h	; 8b28  ..........(..1.1
	defb 0e4h,031h,0e3h,030h,030h,0e4h,051h,0e3h,051h,0e4h,051h,0e3h,050h,050h,000h,001h	; 8b38  .1.00.Q.Q.Q.PP..
	defb 001h,001h,008h,0feh,0ffh,0c3h,08ah,0d5h,0fdh,055h,0e2h,031h,0a1h,031h,0a1h,0c1h	; 8b48  .........U.1.1..
	defb 031h,0fch,031h,0e1h,0a1h,0e0h,031h,0e1h,0a1h,0e0h,031h,0c1h,0e1h,0a1h,0fdh,055h	; 8b58  1.1...1...1....U
	defb 0e2h,021h,091h,021h,091h,0c1h,021h,0fch,031h,0e1h,091h,0e0h,021h,0e1h,091h,0e0h	; 8b68  .!.!..!.1...!...
	defb 021h,0c1h,0e1h,091h,0fdh,055h,0e2h,031h,0a1h,031h,0a1h,0c1h,031h,0fch,031h,0e1h	; 8b78  !....U.1.1..1.1.
	defb 0a1h,0e0h,031h,0e1h,0a1h,0e0h,031h,0c1h,0e1h,0a1h,0fdh,055h,0e2h,061h,0e1h,011h	; 8b88  ..1...1....U.a..
	defb 0e2h,061h,0e1h,053h,033h,013h,001h,011h,011h,0e2h,031h,0a1h,031h,0a1h,031h,0a1h	; 8b98  .a.S3.....1.1.1.
	defb 0fch,031h,0e0h,031h,0a1h,031h,0a1h,031h,0a1h,0fdh,055h,0e2h,021h,091h,021h,091h	; 8ba8  .1.1.1.1..U.!.!.
	defb 021h,091h,0fch,031h,0e0h,021h,091h,021h,091h,021h,091h,0fdh,055h,0e2h,011h,081h	; 8bb8  !..1.!.!.!..U...
	defb 011h,081h,0c1h,0e1h,011h,0e2h,001h,061h,001h,061h,0c1h,0e1h,001h,0c1h,0e2h,0b1h	; 8bc8  .......a.a......
	defb 0b1h,0b1h,0b1h,0c1h,0a1h,0c1h,0b1h,0c3h,0e1h,005h,0e1h,031h,073h,06dh,0feh,0ffh	; 8bd8  ...........1sm..
	defb 04fh,08bh,0d5h,0fch,033h,0e3h,001h,061h,0a1h,001h,061h,0a1h,0feh,002h,0eeh,08bh	; 8be8  O...3..a..a.....
	defb 0e4h,0b1h,0e3h,051h,091h,0e4h,0b1h,0e3h,051h,091h,0feh,002h,0f8h,08bh,001h,061h	; 8bf8  ...Q....Q......a
	defb 0a1h,001h,061h,0a1h,0feh,002h,006h,08ch,031h,0a1h,0e2h,011h,0e3h,031h,0a1h,0feh	; 8c08  ..a.....1....1..
	defb 003h,012h,08ch,0e2h,011h,0e3h,001h,061h,0a1h,001h,061h,0a1h,0feh,002h,01dh,08ch	; 8c18  .......a..a.....
	defb 0e4h,0b1h,0e3h,051h,091h,0e4h,0b1h,0e3h,051h,091h,0feh,002h,028h,08ch,0e4h,081h	; 8c28  ...Q....Q...(...
	defb 0e3h,041h,081h,0e4h,081h,0e3h,041h,081h,0e4h,071h,0e3h,031h,071h,0e4h,071h,0e3h	; 8c38  .A....A..q.1q.q.
	defb 031h,073h,021h,021h,021h,023h,013h,021h,0c3h,03bh,03dh,0feh,0ffh,0eah,08bh,0dah	; 8c48  1s!!!#.!.;=.....
	defb 0fdh,043h,0e2h,040h,090h,040h,091h,040h,041h,040h,061h,070h,077h,040h,060h,070h	; 8c58  .C.@.@.@A@apw@`p
	defb 060h,040h,090h,040h,091h,042h,090h,0b1h,0e1h,007h,0e2h,0b0h,0e1h,000h,0e2h,0b0h	; 8c68  `@.@.B..........
	defb 090h,070h,090h,0e1h,020h,0e2h,090h,0e1h,021h,0e2h,092h,0e1h,020h,000h,0e2h,0b0h	; 8c78  .p.. ...!... ...
	defb 090h,0e1h,000h,050h,000h,051h,002h,050h,040h,020h,000h,046h,020h,070h,000h,050h	; 8c88  ...P.Q.P@ .F p.P
	defb 0e2h,0b0h,0e1h,045h,0fdh,089h,0e3h,0b0h,0e2h,040h,0e3h,0b0h,0e2h,020h,0e3h,0b0h	; 8c98  ...E.....@... ..
	defb 0e2h,040h,0fdh,043h,0e1h,000h,001h,002h,0c0h,031h,031h,020h,0e2h,001h,021h,031h	; 8ca8  .@.C.....11 ..!1
	defb 021h,001h,021h,0c0h,0b1h,0b1h,0e1h,020h,011h,020h,010h,0e2h,0b0h,090h,0e3h,0b1h	; 8cb8  !.!.... . ......
	defb 0e2h,011h,021h,011h,021h,011h,0c0h,0e1h,001h,002h,070h,070h,070h,070h,060h,070h	; 8cc8  ..!.!.....pppp`p
	defb 0e2h,001h,021h,031h,021h,030h,030h,051h,0e1h,094h,090h,064h,060h,033h,020h,010h	; 8cd8  ..!1!00Q...d`3 .
	defb 0fdh,076h,001h,0e2h,0b1h,0a1h,0fch,033h,09bh,0feh,0ffh,057h,08ch,0d5h,0fdh,032h	; 8ce8  .v.....3...W...2
	defb 0e4h,091h,0e3h,041h,0e4h,091h,0e3h,041h,0e4h,091h,0e3h,041h,0feh,002h,0fch,08ch	; 8cf8  ...A...A...A....
	defb 0e4h,091h,0e3h,041h,0e3h,001h,071h,001h,071h,001h,071h,0e3h,001h,071h,001h,0e4h	; 8d08  ...A..q.q.q..q..
	defb 0b1h,0e3h,061h,0e4h,0b1h,0e4h,091h,0e3h,041h,0e4h,091h,0e3h,041h,0feh,003h,01dh	; 8d18  ..a.....A...A...
	defb 08dh,001h,071h,001h,071h,001h,071h,0feh,002h,029h,08dh,021h,091h,021h,091h,021h	; 8d28  ..q.q.q..).!.!.!
	defb 091h,0feh,002h,033h,08dh,0e3h,051h,0e2h,001h,0e3h,051h,0e2h,001h,0feh,003h,03dh	; 8d38  ...3..Q...Q....=
	defb 08dh,0e3h,041h,0b1h,041h,0b1h,041h,0b1h,0feh,002h,049h,08dh,0e4h,0b1h,0e3h,041h	; 8d48  ..A.A.A...I....A
	defb 0e4h,0b1h,0e3h,021h,0e4h,0b1h,0e3h,041h,0e4h,0b1h,0e3h,041h,0e4h,0b1h,0e3h,021h	; 8d58  ...!...A...A...!
	defb 0e4h,0b1h,0e3h,041h,0e4h,051h,0e3h,001h,0e4h,051h,0e3h,031h,0e4h,051h,0e3h,051h	; 8d68  ...A.Q...Q.1.Q.Q
	defb 0feh,002h,06ch,08dh,0e4h,051h,0e3h,001h,0e4h,071h,0e3h,021h,0e4h,081h,0e3h,031h	; 8d78  ..l..Q...q.!...1
	defb 0e4h,071h,0e3h,021h,0e4h,081h,0e3h,031h,0e4h,071h,0e3h,021h,0e4h,041h,0b1h,041h	; 8d88  .q.!...1.q.!.A.A
	defb 0e3h,021h,0e4h,041h,0e3h,041h,0feh,002h,094h,08dh,0e4h,041h,0b1h,061h,0e3h,011h	; 8d98  .!.A.A.....A.a..
	defb 0e4h,071h,0e3h,021h,0e4h,061h,0e3h,011h,0e4h,071h,0e3h,021h,0e4h,061h,0e3h,011h	; 8da8  .q.!.a...q.!.a..
	defb 0e4h,051h,0e3h,001h,0e4h,051h,0e3h,031h,0e4h,051h,0e3h,051h,0e4h,051h,0feh,002h	; 8db8  .Q...Q.1.Q.Q.Q..
	defb 0bah,08dh,0e3h,001h,0e4h,071h,0e3h,021h,0e4h,081h,0e3h,031h,0e4h,071h,0e3h,021h	; 8dc8  .....q.!...1.q.!
	defb 0e4h,081h,0e3h,031h,0e4h,0a1h,0e3h,051h,0e4h,091h,0e3h,041h,0e4h,091h,0e3h,071h	; 8dd8  ...1...Q...A...q
	defb 0e4h,091h,0e3h,091h,0e4h,061h,0e3h,011h,0e4h,061h,0e3h,041h,0e4h,061h,0e3h,061h	; 8de8  .....a...a.A.a.a
	defb 0e4h,031h,0a1h,031h,0e3h,011h,0e4h,031h,0e3h,031h,0e4h,001h,071h,001h,0a1h,001h	; 8df8  .1.1...1.1..q...
	defb 0e3h,001h,0e4h,091h,0e3h,041h,0e4h,091h,0e3h,071h,0e4h,091h,0e3h,091h,0feh,002h	; 8e08  .....A...q......
	defb 00ah,08eh,0feh,0ffh,0f5h,08ch,0d5h,0fdh,033h,0e1h,005h,0e2h,075h,0e1h,003h,0e2h	; 8e18  ........3...u...
	defb 0a5h,075h,053h,0e1h,005h,0e2h,075h,040h,070h,0e1h,000h,040h,059h,043h,021h,005h	; 8e28  .uS...u@p..@YC!.
	defb 0e2h,075h,0e1h,003h,0e2h,0a5h,075h,051h,07eh,030h,050h,07ah,020h,040h,050h,070h	; 8e38  .u....uQ~0Pz @Pp
	defb 090h,0b0h,0e1h,005h,0e2h,075h,0e1h,003h,0e2h,0a5h,075h,053h,0e1h,005h,0e2h,075h	; 8e48  .....u....uS...u
	defb 000h,040h,070h,0e1h,000h,02ch,0e2h,0a0h,0e1h,000h,020h,035h,0e2h,0a5h,0a0h,0e1h	; 8e58  .@p..,.... 5....
	defb 000h,020h,040h,055h,015h,010h,030h,051h,07bh,000h,020h,040h,050h,07bh,000h,020h	; 8e68  . @U..0Q{. @P{.
	defb 040h,050h,0d1h,0e1h,0ach,09ch,08dh,07ch,06ch,05dh,0d5h,0fdh,077h,040h,031h,020h	; 8e78  @P.....|l]..w@1
	defb 0fch,033h,017h,0feh,0ffh,01eh,08eh,0d5h,0fdh,031h,0e3h,001h,0e4h,0b1h,091h,071h	; 8e88  .3.......1.....q
	defb 0e3h,001h,0e4h,0b1h,091h,071h,0a1h,091h,071h,051h,0a1h,091h,071h,051h,0e3h,001h	; 8e98  .....q..qQ..qQ..
	defb 0e4h,0b1h,091h,071h,0e3h,001h,0e4h,0b1h,091h,071h,051h,041h,021h,001h,051h,041h	; 8ea8  ...q.....qQA!.QA
	defb 021h,001h,0e3h,001h,0e4h,0b1h,091h,071h,0e3h,001h,0e4h,0b1h,091h,071h,0a1h,091h	; 8eb8  !......q.....q..
	defb 071h,051h,0a1h,091h,071h,051h,031h,021h,001h,0e5h,0a1h,0e4h,031h,021h,001h,0e5h	; 8ec8  qQ..qQ1!....1!..
	defb 0a1h,0e4h,021h,001h,0e5h,0b1h,091h,0e4h,071h,051h,041h,021h,0e3h,001h,0e4h,0b1h	; 8ed8  ..!.....qQA!....
	defb 091h,071h,0e3h,001h,0e4h,0b1h,091h,071h,0a1h,091h,071h,051h,0a1h,091h,071h,051h	; 8ee8  .q.....q..qQ..qQ
	defb 0e3h,001h,0e4h,0b1h,091h,071h,0e3h,001h,0e4h,0b1h,091h,071h,0a1h,091h,071h,051h	; 8ef8  .....q.....q..qQ
	defb 0a1h,081h,071h,051h,0e3h,031h,021h,001h,0e4h,0a1h,0e3h,031h,021h,001h,0e4h,0a1h	; 8f08  ..qQ.1!....1!...
	defb 0e3h,011h,001h,0e4h,0a1h,081h,0e3h,011h,001h,0e4h,0a1h,081h,0e4h,071h,021h,071h	; 8f18  .............q!q
	defb 0e3h,021h,0e4h,071h,0e3h,021h,071h,021h,0e4h,071h,021h,071h,0e3h,021h,0e4h,071h	; 8f28  .!.q.!q!.q!q.!.q
	defb 0e3h,021h,071h,021h,0d2h,0fdh,023h,0e4h,079h,079h,079h,079h,0d5h,070h,071h,070h	; 8f38  .!q!..#.yyyy.pqp
	defb 077h,0feh,0ffh,08fh,08eh,0d4h,0fah,023h,0e1h,001h,031h,0e2h,0b1h,0e1h,031h,0fbh	; 8f48  w......#..1...1.
	defb 023h,0e2h,0a1h,0e1h,031h,0e2h,091h,0e1h,031h,0fch,023h,001h,031h,0e2h,0b1h,0e1h	; 8f58  #...1...1.#.1...
	defb 031h,0fdh,023h,0e2h,0a1h,0e1h,031h,0e2h,091h,0e1h,031h,0fbh,000h,070h,0fch,000h	; 8f68  1.#...1...1..p..
	defb 070h,0fdh,000h,070h,0fch,000h,070h,0fdh,023h,0e0h,021h,0e1h,071h,0e0h,021h,0e1h	; 8f78  p..p..p.#.!.q.!.
	defb 071h,0e0h,021h,0fdh,033h,0e1h,051h,061h,071h,081h,0fdh,042h,073h,0fdh,023h,0e0h	; 8f88  q.!.3.Qaq..Bs.#.
	defb 021h,0e1h,071h,0e0h,021h,0e1h,071h,0e0h,021h,0fdh,032h,0e1h,091h,091h,0fdh,023h	; 8f98  !.q.!.q.!.2....#
	defb 091h,0c1h,0fah,000h,0e1h,000h,000h,0fbh,000h,000h,000h,0fch,000h,000h,000h,0fdh	; 8fa8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0fch,000h,000h,000h,0fbh,000h,000h,000h,0fah	; 8fb8  ................
	defb 000h,000h,000h,0fdh,023h,0e2h,0a1h,071h,031h,0d8h,0fah,000h,0e2h,050h,0fbh,000h	; 8fc8  ....#..q1....P..
	defb 050h,050h,0fch,000h,050h,050h,050h,050h,0fbh,000h,050h,0f9h,000h,050h,050h,0f8h	; 8fd8  PP..PPPP..P..PP.
	defb 000h,050h,050h,0d4h,0fah,000h,0e1h,000h,000h,0fbh,000h,000h,000h,0fch,000h,000h	; 8fe8  .PP.............
	defb 000h,0fdh,000h,000h,000h,000h,000h,000h,000h,0fch,000h,000h,000h,0fbh,000h,000h	; 8ff8  ................
	defb 000h,0fah,000h,000h,000h,0fdh,023h,0e2h,0a1h,071h,0a1h,0d8h,0f9h,000h,0e1h,000h	; 9008  ......#..q......
	defb 000h,0fah,000h,000h,000h,0fbh,000h,000h,000h,000h,0fah,000h,000h,0f8h,000h,000h	; 9018  ................
	defb 000h,0f7h,000h,000h,000h,0d4h,0fbh,000h,0e1h,020h,0fch,000h,020h,0fdh,000h,020h	; 9028  ......... .. ..
	defb 0fch,000h,020h,0fdh,023h,071h,021h,071h,021h,071h,0fdh,033h,001h,001h,0fdh,023h	; 9038  .. .#q!q!q.3...#
	defb 003h,0fdh,042h,023h,0fdh,023h,071h,021h,071h,021h,071h,0fdh,022h,093h,093h,0fbh	; 9048  ..B#.#q!q!q."...
	defb 000h,070h,0fch,000h,070h,0fdh,000h,070h,0fch,000h,070h,0fdh,023h,0e0h,021h,0e1h	; 9058  .p..p..p..p.#.!.
	defb 071h,0e0h,021h,0e1h,071h,0e0h,021h,0fdh,033h,0e1h,051h,051h,0fdh,023h,053h,0fdh	; 9068  q.!.q.!.3.QQ.#S.
	defb 042h,073h,0fdh,023h,0e0h,021h,0e1h,071h,0e0h,021h,0e1h,071h,0e0h,021h,0fdh,022h	; 9078  Bs.#.!.q.!.q.!."
	defb 0e1h,093h,093h,0fah,000h,000h,000h,0fbh,000h,000h,000h,0fch,000h,000h,000h,0fdh	; 9088  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0fch,000h,000h,000h,0fbh,000h,000h,000h,0fah	; 9098  ................
	defb 000h,000h,000h,0fdh,023h,0e2h,0a1h,071h,031h,0d8h,0fah,000h,0e2h,050h,0fbh,000h	; 90a8  ....#..q1....P..
	defb 050h,050h,0fch,000h,050h,050h,050h,050h,0fbh,000h,050h,0f9h,000h,050h,050h,0f8h	; 90b8  PP..PPPP..P..PP.
	defb 000h,050h,050h,0d4h,0fah,000h,0e1h,000h,000h,0fbh,000h,000h,000h,0fch,000h,000h	; 90c8  .PP.............
	defb 000h,0fdh,000h,000h,000h,000h,000h,000h,000h,0fch,000h,000h,000h,0fbh,000h,000h	; 90d8  ................
	defb 000h,0fah,000h,000h,000h,0fdh,023h,0e2h,0a1h,071h,0a1h,0d8h,0f9h,000h,0e1h,000h	; 90e8  ......#..q......
	defb 000h,0fah,000h,000h,000h,0fbh,000h,000h,000h,000h,0fah,000h,000h,0f8h,000h,000h	; 90f8  ................
	defb 000h,0f7h,000h,000h,000h,0d4h,0fdh,033h,0e0h,023h,023h,023h,0fdh,034h,001h,001h	; 9108  .......3.###.4..
	defb 001h,0fdh,033h,023h,023h,023h,0fdh,023h,001h,001h,051h,0fdh,032h,021h,0fdh,044h	; 9118  ..3###.#..Q.2!.D
	defb 0e1h,071h,021h,0fdh,032h,0e0h,001h,0fdh,044h,0e1h,051h,001h,0fdh,032h,0e0h,021h	; 9128  .q!.2...D.Q..2.!
	defb 0fdh,044h,0e1h,071h,0fdh,032h,0e0h,001h,0fdh,044h,0e1h,051h,0fdh,032h,021h,0fdh	; 9138  .D.q.2...D.Q.2!.
	defb 044h,0e2h,071h,0fdh,032h,0e1h,001h,0fdh,044h,0e2h,051h,0fdh,032h,0e1h,021h,0fdh	; 9148  D.q.2...D.Q.2.!.
	defb 044h,071h,0feh,0ffh,0aah,08fh,0d4h,0fah,033h,0e3h,001h,001h,001h,001h,0fbh,033h	; 9158  Dq......3......3
	defb 001h,001h,001h,001h,0fch,033h,001h,001h,001h,001h,0fdh,033h,001h,001h,001h,001h	; 9168  .....3.....3....
	defb 031h,031h,0a1h,0e2h,031h,0e3h,031h,031h,0a1h,011h,011h,011h,011h,031h,031h,0a1h	; 9178  11..1.11.....11.
	defb 0e2h,031h,0e3h,031h,031h,0a1h,011h,011h,011h,0c1h,0fdh,033h,0e3h,001h,001h,031h	; 9188  .1.11......3...1
	defb 0e2h,001h,0e3h,001h,031h,001h,001h,031h,0e2h,001h,0e3h,001h,031h,011h,011h,051h	; 9198  ....1..1....1..Q
	defb 0e2h,011h,0e3h,011h,051h,011h,011h,051h,0e2h,011h,0e3h,011h,051h,001h,001h,031h	; 91a8  ....Q..Q....Q..1
	defb 0e2h,001h,0e3h,001h,031h,001h,001h,031h,0e2h,001h,0e3h,001h,031h,0e3h,011h,011h	; 91b8  ....1..1....1...
	defb 051h,0e2h,011h,0e3h,011h,051h,011h,011h,051h,0e2h,011h,0e3h,011h,051h,031h,031h	; 91c8  Q....Q..Q....Q11
	defb 0a1h,0e2h,031h,0e3h,031h,031h,0a1h,011h,011h,0fdh,032h,013h,0fdh,033h,031h,031h	; 91d8  ..1.11....2..311
	defb 0a1h,0e2h,031h,0e3h,031h,031h,0a1h,0fdh,032h,013h,013h,0fdh,033h,0e3h,031h,031h	; 91e8  ..1.11..2...3.11
	defb 0a1h,0e2h,031h,0e3h,031h,031h,0a1h,011h,011h,0fdh,032h,013h,0fdh,033h,031h,031h	; 91f8  ..1.11....2..311
	defb 0a1h,0e2h,031h,0e3h,031h,031h,0a1h,0fdh,032h,013h,013h,0fdh,033h,0e3h,001h,001h	; 9208  ..1.11..2...3...
	defb 031h,0e2h,001h,0e3h,001h,031h,001h,001h,031h,0e2h,001h,0e3h,001h,031h,011h,011h	; 9218  1....1..1....1..
	defb 051h,0e2h,011h,0e3h,011h,051h,011h,011h,051h,0e2h,011h,0e3h,011h,051h,001h,001h	; 9228  Q....Q..Q....Q..
	defb 031h,0e2h,001h,0e3h,001h,031h,001h,001h,031h,0e2h,001h,0e3h,001h,031h,0e3h,011h	; 9238  1....1..1....1..
	defb 011h,051h,0e2h,011h,0e3h,011h,051h,011h,011h,051h,0e2h,011h,0e3h,011h,051h,031h	; 9248  .Q....Q..Q....Q1
	defb 031h,0a1h,0e2h,031h,0e3h,031h,0a1h,011h,011h,081h,031h,031h,0a1h,0e2h,031h,0e3h	; 9258  1..1.1....11..1.
	defb 031h,0a1h,011h,011h,081h,031h,0fdh,044h,0a1h,0e2h,031h,0fdh,033h,0e3h,011h,0fdh	; 9268  1....1.D..1.3...
	defb 044h,081h,0e2h,011h,0fdh,033h,0e3h,031h,0fdh,044h,0a1h,0fdh,033h,011h,0fdh,044h	; 9278  D....3.1.D..3..D
	defb 081h,0fdh,033h,031h,0fdh,044h,0a1h,0fdh,033h,011h,0fdh,044h,081h,0fdh,033h,031h	; 9288  ..31.D..3..D..31
	defb 0fdh,044h,0a1h,0feh,0ffh,092h,091h,0d3h,0f6h,004h,0e2h,001h,0e1h,001h,0f7h,004h	; 9298  .D..............
	defb 0e2h,001h,001h,0f8h,004h,0e1h,001h,0e2h,001h,0f9h,004h,001h,0e1h,001h,0fah,004h	; 92a8  ................
	defb 0e2h,001h,001h,0fbh,004h,0e1h,001h,0e2h,001h,0fch,004h,0e1h,001h,0e2h,001h,0fdh	; 92b8  ................
	defb 004h,001h,0e1h,001h,0f6h,004h,0e2h,081h,0e1h,081h,0f7h,004h,0e2h,081h,081h,0f8h	; 92c8  ................
	defb 004h,0e1h,081h,0e2h,081h,0f9h,004h,081h,0e1h,081h,0fah,004h,0e2h,081h,081h,0fbh	; 92d8  ................
	defb 004h,0e1h,081h,0e2h,081h,0fch,004h,0e1h,081h,0e2h,081h,0fdh,004h,081h,0e1h,081h	; 92e8  ................
	defb 0f6h,003h,0e2h,051h,0e1h,051h,0f7h,003h,0e2h,051h,051h,0f8h,003h,0e1h,051h,0e2h	; 92f8  ...Q.Q...QQ...Q.
	defb 051h,0f9h,003h,051h,0e1h,051h,0fah,003h,0e2h,051h,051h,0fbh,003h,0e1h,051h,0e2h	; 9308  Q..Q.Q...QQ...Q.
	defb 051h,0fch,004h,0e1h,051h,0e2h,051h,0fdh,004h,051h,0e1h,051h,0f6h,003h,0e2h,071h	; 9318  Q...Q.Q..Q.Q...q
	defb 0e1h,071h,0f8h,003h,0e2h,071h,071h,0fah,003h,0e1h,071h,0e2h,071h,0fch,004h,071h	; 9328  .q...qq...q.q..q
	defb 0e1h,071h,0fbh,003h,0e1h,071h,0e2h,071h,0e3h,071h,0e1h,071h,0e2h,071h,0e1h,071h	; 9338  .q...q.q.q.q.q.q
	defb 071h,0e0h,021h,0d3h,0fbh,002h,0e1h,001h,0e0h,001h,0e1h,001h,0e0h,001h,0e1h,001h	; 9348  q.!.............
	defb 0a1h,001h,071h,0feh,002h,04bh,093h,0e2h,081h,0e0h,001h,0e2h,081h,0e0h,001h,0e2h	; 9358  ..q..K..........
	defb 081h,0e1h,0a1h,0e2h,081h,0e1h,071h,0feh,002h,05fh,093h,0e2h,051h,0e0h,001h,0e2h	; 9368  ......q.._..Q...
	defb 051h,0e0h,001h,0e2h,051h,0e1h,0a1h,0e2h,051h,0e1h,071h,0e2h,051h,0e1h,051h,0e2h	; 9378  Q...Q...Q.q.Q.Q.
	defb 051h,0e1h,031h,0e2h,051h,0e1h,021h,0e2h,051h,0e1h,031h,0e2h,071h,0e1h,021h,0e2h	; 9388  Q.1.Q.!.Q.1.q.!.
	defb 071h,0e1h,001h,0e2h,071h,0b1h,071h,0e1h,001h,0e2h,071h,0e1h,021h,0e2h,071h,0e1h	; 9398  q...q.q...q.!.q.
	defb 031h,0e2h,071h,0e1h,051h,0e2h,071h,0b1h,0fdh,030h,0e1h,003h,0e2h,071h,0e1h,023h	; 93a8  1.q.Q.q..0...q.#
	defb 0e2h,071h,0e1h,033h,0e2h,071h,0e1h,053h,0e2h,071h,0fdh,032h,0e1h,033h,002h,0c0h	; 93b8  .q.3.q.S.q.2.3..
	defb 0feh,003h,0b0h,093h,0fdh,022h,0e1h,005h,0e2h,071h,0e1h,023h,0e2h,071h,0e1h,033h	; 93c8  ....."...q.#.q.3
	defb 0e2h,071h,0e1h,053h,031h,021h,001h,021h,0fdh,031h,0e1h,001h,0c1h,0e0h,001h,0c1h	; 93d8  .q.S1!.!.1......
	defb 0e1h,001h,0a1h,001h,071h,0feh,002h,0e0h,093h,0e2h,081h,0c1h,0e0h,001h,0c1h,0e2h	; 93e8  ....q...........
	defb 081h,0e1h,0a1h,0e2h,081h,0e1h,071h,0feh,002h,0f1h,093h,0e2h,051h,0c1h,0e0h,001h	; 93f8  ......q.....Q...
	defb 0c1h,0e2h,051h,0e1h,0a1h,0e2h,051h,0e1h,071h,0e2h,051h,0c1h,0e1h,051h,031h,0e2h	; 9408  ..Q...Q.q.Q..Q1.
	defb 051h,0e1h,031h,021h,031h,0e2h,071h,0c1h,0e1h,021h,001h,0e2h,071h,0e1h,001h,0e2h	; 9418  Q.1!1.q..!..q...
	defb 0b1h,0e1h,001h,0e2h,071h,0e1h,021h,0e2h,071h,0e1h,031h,0e2h,071h,0e1h,051h,0e2h	; 9428  ....q.!.q.1.q.Q.
	defb 071h,0b1h,0fdh,00fh,0e2h,001h,0c1h,0e1h,001h,0c1h,0e2h,0a1h,0c1h,071h,051h,0c1h	; 9438  q............qQ.
	defb 031h,0c1h,021h,0c1h,001h,0c1h,021h,0feh,002h,03ah,094h,001h,0c1h,0e1h,001h,0c1h	; 9448  1.!...!..:......
	defb 0e2h,0a1h,0c1h,071h,053h,0c1h,0e1h,051h,0c1h,031h,0c1h,001h,0c1h,0fdh,021h,073h	; 9458  ...qS..Q.1....!s
	defb 0e2h,071h,0e1h,053h,0e2h,071h,0e1h,033h,0e2h,071h,0e1h,023h,0e2h,071h,0e1h,001h	; 9468  .q.S.q.3.q.#.q..
	defb 0e2h,071h,0e1h,021h,0e2h,071h,0fdh,030h,0e1h,003h,0e2h,071h,0e1h,023h,0e2h,071h	; 9478  .q.!.q.0...q.#.q
	defb 0e1h,033h,0e2h,071h,0e1h,053h,0e2h,071h,0fdh,032h,0e1h,033h,002h,0c0h,0feh,002h	; 9488  .3.q.S.q.2.3....
	defb 07eh,094h,003h,0e2h,071h,0e1h,023h,0e2h,071h,0e1h,033h,0e2h,071h,0e1h,053h,0e2h	; 9498  ~...q.#.q.3.q.S.
	defb 071h,0e1h,031h,0e2h,071h,0e1h,051h,0e2h,071h,0e1h,073h,0e2h,0b1h,0e1h,053h,0e2h	; 94a8  q.1.q.Q.q.s...S.
	defb 0b1h,0e1h,033h,0e2h,071h,0e1h,023h,0e2h,071h,0fbh,002h,091h,0e1h,091h,0e2h,0b1h	; 94b8  ..3.q.#.q.......
	defb 0e1h,0b1h,0feh,0ffh,04bh,093h,0ffh,0d3h,0fdh,014h,0e4h,001h,0fch,014h,0e3h,001h	; 94c8  ....K...........
	defb 0fdh,014h,0e4h,001h,001h,0fch,014h,0e3h,001h,0fdh,014h,0e4h,001h,001h,0fch,014h	; 94d8  ................
	defb 0e3h,001h,0fdh,014h,0e4h,001h,001h,0fch,014h,0e3h,001h,0fdh,014h,0e4h,001h,0fch	; 94e8  ................
	defb 014h,0e3h,001h,0fdh,014h,0e4h,001h,001h,0fch,014h,0e3h,001h,0fdh,014h,0e4h,081h	; 94f8  ................
	defb 0fch,00fh,0e3h,081h,0fdh,014h,0e4h,081h,081h,0fch,00fh,0e3h,081h,0fdh,014h,0e4h	; 9508  ................
	defb 081h,081h,0fch,00fh,0e3h,081h,0fdh,014h,0e4h,081h,081h,0fch,00fh,0e3h,081h,0fdh	; 9518  ................
	defb 014h,0e4h,081h,0fch,00fh,0e3h,081h,0fdh,014h,0e4h,081h,081h,0fch,00fh,0e3h,081h	; 9528  ................
	defb 0fdh,014h,0e4h,051h,0fch,016h,0e3h,051h,0fdh,014h,0e4h,051h,051h,0fch,016h,0e3h	; 9538  ...Q...Q...QQ...
	defb 051h,0fdh,014h,0e4h,051h,051h,0fch,016h,0e3h,051h,0fdh,014h,0e4h,051h,051h,0fch	; 9548  Q...QQ...Q...QQ.
	defb 016h,0e3h,051h,0fdh,014h,0e4h,051h,0fch,016h,0e3h,051h,0fdh,014h,0e4h,051h,051h	; 9558  ..Q...Q...Q...QQ
	defb 0fch,016h,0e3h,051h,0fdh,014h,0e4h,071h,0fch,00fh,0e3h,071h,0fdh,014h,0e4h,071h	; 9568  ...Q...q...q...q
	defb 071h,0fch,00fh,0e3h,071h,0fdh,014h,0e4h,071h,071h,0fch,00fh,0e3h,071h,0fdh,014h	; 9578  q...q...qq...q..
	defb 0e4h,071h,071h,0fch,00fh,0e3h,071h,0fdh,014h,0e4h,071h,0fch,00fh,0e3h,071h,0fdh	; 9588  .qq...q...q...q.
	defb 014h,0e4h,071h,071h,0fch,00fh,0e3h,071h,0feh,0ffh,0cfh,094h,0ffh,023h,001h,018h	; 9598  ..qq...q.....#..
	defb 0f1h,000h,0f2h,000h,0f3h,000h,0e4h,000h,0e5h,000h,0e6h,000h,0d7h,000h,0d8h,000h	; 95a8  ................
	defb 023h,001h,01fh,0f6h,000h,0e2h,080h,0e3h,000h,0e3h,080h,0e4h,000h,0e4h,080h,0d5h	; 95b8  #...............
	defb 000h,0d5h,080h,023h,006h,01fh,0f4h,060h,0f4h,060h,0f4h,060h,0f4h,060h,0e4h,060h	; 95c8  ...#...`.`.`.`.`
	defb 0e4h,060h,023h,008h,01eh,0d4h,080h,0c4h,0c0h,0b5h,000h,0a5h,040h,095h,080h,085h	; 95d8  .`#.........@...
	defb 0c0h,076h,000h,066h,040h,056h,080h,0ffh,022h,001h,0f2h,000h,0f3h,000h,0f4h,000h	; 95e8  .v.f@V..".......
	defb 0e5h,000h,0e6h,000h,0e7h,000h,0d8h,000h,0d9h,000h,0f7h,000h,0e3h,080h,0e4h,000h	; 95f8  ................
	defb 0e4h,080h,0e5h,000h,0e5h,080h,0d6h,000h,0d6h,080h,022h,006h,0f5h,060h,0e5h,060h	; 9608  .........."..`.`
	defb 0d5h,060h,0c5h,060h,0b5h,060h,0b5h,060h,022h,008h,0b5h,080h,0a5h,080h,095h,080h	; 9618  .`.`.`.`".......
	defb 085h,080h,075h,080h,065h,080h,065h,080h,065h,080h,055h,080h,0ffh,022h,001h,0f0h	; 9628  ..u.e.e.e.U.."..
	defb 010h,0f0h,030h,0f0h,050h,0e1h,000h,0e2h,000h,0e3h,000h,0d4h,000h,0d5h,000h,0f5h	; 9638  ..0.P...........
	defb 000h,0e0h,080h,0e1h,000h,0e1h,080h,0e2h,000h,0e2h,080h,0d3h,000h,0d3h,080h,0f0h	; 9648  ................
	defb 050h,0f0h,080h,0f0h,0c0h,022h,003h,000h,000h,022h,006h,0e3h,000h,0d3h,000h,0c3h	; 9658  P...."..."......
	defb 000h,0b3h,000h,0a3h,000h,022h,008h,0a3h,080h,0a3h,0c0h,094h,000h,084h,040h,074h	; 9668  ....."........@t
	defb 080h,064h,0c0h,065h,000h,055h,040h,045h,080h,0ffh,0d3h,0fch,024h,0e1h,019h,0fch	; 9678  .d.e.U@E....$...
	defb 037h,027h,045h,0fch,024h,029h,0fch,037h,017h,025h,0d6h,0fch,033h,09bh,0d3h,0fch	; 9688  7'E.$).7.%..3...
	defb 013h,0b3h,0fch,088h,091h,073h,0fch,035h,065h,0fch,088h,041h,0fch,066h,025h,0fch	; 9698  .....s.5e..A.f%.
	defb 024h,019h,0fch,066h,027h,0fch,033h,0b5h,0fch,088h,093h,0b1h,0e0h,013h,0fch,045h	; 96a8  $..f'.3........E
	defb 025h,0fch,088h,041h,063h,0fch,045h,075h,0fch,088h,061h,023h,0fbh,024h,0e1h,0b5h	; 96b8  %..Ac.Eu..a#.$..
	defb 0fch,088h,0e0h,021h,0fch,045h,013h,0fch,045h,027h,0fch,024h,0e1h,0b3h,0fch,045h	; 96c8  ...!.E..E'.$...E
	defb 095h,0fch,088h,071h,063h,0fch,024h,021h,019h,0fch,037h,027h,045h,0fch,024h,029h	; 96d8  ...qc.$!..7'E.$)
	defb 0fch,037h,017h,025h,0d6h,0fch,033h,09bh,0d3h,0fch,013h,0b3h,0fch,088h,091h,073h	; 96e8  .7.%..3........s
	defb 0fch,035h,065h,0fch,088h,041h,0fch,066h,025h,0fch,024h,019h,0fch,066h,027h,0fch	; 96f8  .5e..A.f%.$..f'.
	defb 033h,0b5h,0fch,088h,093h,0b1h,0e0h,013h,0fch,045h,025h,0fch,088h,041h,063h,0fch	; 9708  3........E%..Ac.
	defb 045h,075h,0fbh,088h,061h,023h,0fbh,024h,0e1h,0b5h,0fbh,088h,0e0h,021h,0fah,045h	; 9718  Eu..a#.$.....!.E
	defb 0e0h,013h,0fah,045h,0e0h,02bh,0fah,024h,0e1h,099h,0c3h,0fah,045h,0e0h,073h,0f9h	; 9728  ...E.+.$....E.s.
	defb 088h,0e0h,061h,023h,0f9h,045h,0e1h,0b5h,0f8h,088h,0e1h,091h,073h,0f7h,024h,0e1h	; 9738  ..a#.E......s.$.
	defb 06fh,0c9h,0ffh,0d3h,0fch,024h,0e2h,099h,0fch,037h,0b7h,0e1h,015h,0fch,024h,0e2h	; 9748  o....$...7....$.
	defb 0b9h,0fch,037h,097h,0b5h,0fch,024h,0e1h,019h,0fch,037h,027h,045h,0fch,024h,029h	; 9758  ..7...$...7'E.$)
	defb 0fch,037h,0e2h,0bdh,0fch,024h,099h,0fch,066h,0b7h,0fch,033h,0e1h,025h,0fch,088h	; 9768  .7...$..f..3.%..
	defb 015h,093h,0fch,045h,067h,0fch,088h,0b3h,0fch,045h,0b5h,0fch,088h,091h,0fch,045h	; 9778  ...Eg....E.....E
	defb 063h,0fch,024h,025h,0fch,088h,071h,0fch,045h,043h,0fch,024h,075h,0fch,088h,061h	; 9788  c.$%..q.EC.$u..a
	defb 0fch,024h,043h,0fch,045h,065h,0fch,088h,041h,023h,0fch,024h,0e2h,091h,099h,0fch	; 9798  .$C.Ee..A#.$....
	defb 037h,0b7h,0e1h,015h,0fch,024h,0e2h,0b9h,0fch,037h,097h,0b5h,0fch,024h,0e1h,019h	; 97a8  7....$...7...$..
	defb 0fch,037h,027h,045h,0fch,024h,029h,0fch,037h,0e2h,0bdh,0fch,024h,099h,0fch,066h	; 97b8  .7'E.$).7...$..f
	defb 0b7h,0fch,033h,0e1h,025h,0fch,088h,015h,093h,0fch,045h,067h,0fch,088h,0b3h,0fch	; 97c8  ..3.%.....Eg....
	defb 045h,0b5h,0fbh,088h,091h,0fbh,045h,063h,0fbh,024h,025h,0fbh,088h,071h,0fbh,045h	; 97d8  E.....Ec.$%..q.E
	defb 043h,0fah,024h,075h,0fah,088h,061h,0fah,045h,043h,0fah,024h,065h,0fah,088h,041h	; 97e8  C.$u..a.EC.$e..A
	defb 0f9h,045h,023h,0c1h,0f9h,024h,0b3h,0f9h,088h,091h,063h,0fbh,045h,025h,0f8h,088h	; 97f8  .E#..$....c.E%..
	defb 011h,0e2h,093h,0f7h,024h,0e1h,02fh,0c9h,0ffh,0d3h,0fch,044h,0e3h,073h,0fch,055h	; 9808  ....$./....D.s.U
	defb 021h,0fch,044h,073h,0fch,055h,021h,0fch,044h,073h,0fch,055h,021h,0fch,044h,073h	; 9818  !.Ds.U!.Ds.U!.Ds
	defb 0fch,055h,021h,0fch,044h,073h,0fch,055h,021h,0fch,044h,073h,0fch,055h,021h,0fch	; 9828  .U!.Ds.U!.Ds.U!.
	defb 044h,073h,0fch,055h,021h,0fch,044h,073h,0fch,055h,021h,0fch,044h,063h,0fch,055h	; 9838  Ds.U!.Ds.U!.Dc.U
	defb 011h,0fch,044h,063h,0fch,055h,011h,0fch,044h,063h,0fch,055h,011h,0fch,044h,063h	; 9848  ..Dc.U..Dc.U..Dc
	defb 0fch,055h,011h,0fch,044h,0e4h,0b5h,0fch,055h,0e3h,013h,0fch,044h,025h,0fch,055h	; 9858  .U..D...U...D%.U
	defb 041h,0fch,044h,065h,073h,0fch,055h,021h,0fch,044h,073h,0fch,055h,021h,0fch,044h	; 9868  A.Des.U!.Ds.U!.D
	defb 073h,0fch,055h,021h,0fch,044h,073h,0fch,055h,021h,0fch,044h,065h,0fch,055h,013h	; 9878  s.U!.Ds.U!.De.U.
	defb 0fch,044h,0e4h,0b5h,0fch,055h,0e3h,011h,023h,0fch,044h,045h,0fch,055h,061h,073h	; 9888  .D...U..#.DE.Uas
	defb 0fch,044h,095h,0fch,055h,041h,0e4h,093h,0fch,044h,0e3h,027h,073h,025h,041h,0fch	; 9898  .D..UA...D.'s%A.
	defb 055h,065h,0fch,044h,0e3h,073h,0fch,055h,021h,0fch,044h,073h,0fch,055h,021h,0fch	; 98a8  Ue.D.s.U!.Ds.U!.
	defb 044h,073h,0fch,055h,021h,0fch,044h,073h,0fch,055h,021h,0fch,044h,073h,0fch,055h	; 98b8  Ds.U!.Ds.U!.Ds.U
	defb 021h,0fch,044h,073h,0fch,055h,021h,0fch,044h,073h,0fch,055h,021h,0fch,044h,073h	; 98c8  !.Ds.U!.Ds.U!.Ds
	defb 0fch,055h,021h,0fch,044h,063h,0fch,055h,011h,0fch,044h,063h,0fch,055h,011h,0fch	; 98d8  .U!.Dc.U..Dc.U..
	defb 044h,063h,0fch,055h,011h,0fch,044h,063h,0fch,055h,011h,0fch,044h,0e4h,0b5h,0fch	; 98e8  Dc.U..Dc.U..D...
	defb 055h,0e3h,013h,0fch,044h,025h,0fch,055h,041h,0fch,044h,065h,073h,0fch,055h,021h	; 98f8  U...D%.UA.Des.U!
	defb 0fch,044h,073h,0fch,055h,021h,0fch,044h,073h,0fch,055h,021h,0fch,044h,073h,0fch	; 9908  .Ds.U!.Ds.U!.Ds.
	defb 055h,021h,0fch,044h,065h,0fch,055h,013h,0fch,044h,0e4h,0b5h,0fch,055h,0e3h,011h	; 9918  U!.De.U..D...U..
	defb 023h,0fch,044h,045h,0fbh,055h,061h,073h,0fbh,044h,095h,0fbh,055h,041h,0e4h,093h	; 9928  #.DE.Uas.D..UA..
	defb 0fah,044h,0e3h,027h,0fah,055h,073h,0fah,044h,025h,0fah,044h,041h,0f9h,044h,065h	; 9938  .D.'.Us.D%.DA.De
	defb 043h,0f9h,055h,061h,0f9h,044h,073h,0f9h,044h,095h,0f9h,055h,041h,0f9h,044h,0e4h	; 9948  C.Ua.Ds.D..UA.D.
	defb 093h,0f9h,024h,0e3h,02fh,0c9h,0ffh,0d5h,0fch,024h,0e2h,093h,0e1h,041h,023h,001h	; 9958  ..$./....$...A#.
	defb 0e2h,0b1h,0e1h,003h,0e2h,0b1h,091h,0b3h,091h,073h,091h,091h,0e1h,041h,023h,07fh	; 9968  .........s...A#.
	defb 0c5h,0e2h,041h,091h,0e1h,041h,023h,001h,0e2h,0b3h,0e1h,001h,0e2h,0b1h,091h,0b1h	; 9978  ..A..A#.........
	defb 091h,075h,093h,0e1h,041h,021h,021h,0fah,000h,07fh,0fah,00fh,074h,0c0h,0feh,0ffh	; 9988  .u..A!!.....t...
	defb 05fh,099h,0d5h,0fbh,044h,0e1h,091h,091h,0e0h,091h,0e1h,091h,0feh,0ffh,09ah,099h	; 9998  _...D...........
	defb 0d5h,0fch,034h,0e3h,093h,091h,043h,041h,043h,051h,041h,021h,073h,081h,0b3h,093h	; 99a8  ..4...CACQA!s...
	defb 091h,041h,041h,041h,053h,051h,041h,021h,073h,071h,083h,093h,091h,043h,041h,043h	; 99b8  .AAASQA!sq...CAC
	defb 051h,041h,021h,0b1h,0b1h,071h,0b3h,053h,051h,003h,001h,053h,041h,041h,041h,0e3h	; 99c8  QA!..q.SQ..SAAA.
	defb 0b3h,041h,0e3h,042h,040h,0feh,0ffh,0a8h,099h,0d1h,0fbh,033h,0e1h,0c0h,0d4h,041h	; 99d8  .A.B@......3...A
	defb 0e2h,0c1h,0e1h,041h,063h,0b3h,063h,043h,0e2h,0b1h,0e1h,041h,0e2h,0c1h,0e1h,041h	; 99e8  ...Ac.cC...A...A
	defb 061h,041h,0e2h,0b1h,0e1h,041h,063h,0b3h,063h,043h,0e2h,0b1h,0e1h,041h,0e2h,0b1h	; 99f8  aA...Ac.cC...A..
	defb 0e1h,041h,061h,0feh,003h,0f9h,099h,0d8h,0fch,033h,0e2h,080h,060h,080h,0a1h,0b1h	; 9a08  .Aa......3..`...
	defb 0a1h,081h,060h,080h,060h,080h,0c0h,080h,060h,080h,0a1h,0b1h,0a1h,081h,060h,080h	; 9a18  ..`.`...`.....`.
	defb 060h,080h,0c0h,060h,040h,060h,081h,091h,081h,061h,080h,060h,04ah,010h,030h,040h	; 9a28  `..`@`...a.`J.0@
	defb 061h,040h,030h,010h,080h,060h,080h,0a1h,0b1h,0a1h,081h,060h,080h,060h,080h,0c0h	; 9a38  a@0..`.....`.`..
	defb 0feh,002h,03ch,09ah,060h,040h,060h,081h,091h,082h,061h,080h,044h,060h,040h,024h	; 9a48  ..<.`@`...a.D`@$
	defb 040h,020h,000h,000h,040h,060h,081h,060h,080h,0a1h,0b1h,0a1h,081h,060h,080h,060h	; 9a58  @ ..@`.`.....`.`
	defb 080h,0c0h,080h,060h,080h,0a1h,0b1h,0a1h,081h,060h,080h,060h,080h,0c0h,0feh,0ffh	; 9a68  ...`.....`.`....
	defb 02bh,09ah,0d8h,0fdh,02ch,0e2h,0bdh,0b1h,09dh,091h,07dh,071h,09fh,0fch,024h,0e3h	; 9a78  +...,.....}q..$.
	defb 0b0h,0b0h,0e2h,040h,040h,0e3h,0b0h,0b0h,0e2h,040h,040h,0feh,007h,08dh,09ah,0e3h	; 9a88  ...@@....@@.....
	defb 090h,090h,0e2h,020h,020h,0feh,003h,097h,09ah,0e3h,040h,040h,090h,090h,040h,040h	; 9a98  ...  .....@@..@@
	defb 090h,090h,0feh,004h,0a6h,09ah,0e3h,0b0h,0b0h,0e2h,040h,040h,0feh,008h,0aeh,09ah	; 9aa8  ..........@@....
	defb 0e3h,090h,090h,0e2h,020h,020h,0feh,003h,0b8h,09ah,0e3h,070h,070h,0e2h,000h,000h	; 9ab8  ....  .....pp...
	defb 0e3h,070h,070h,0e2h,000h,000h,0e3h,050h,050h,0a0h,0a0h,0e3h,050h,050h,0a0h,0a0h	; 9ac8  .pp....PP...PP..
	defb 030h,030h,080h,080h,0feh,0ffh,085h,09ah,0d4h,0fch,044h,0e0h,041h,0e1h,0b1h,0e0h	; 9ad8  00........D.A...
	defb 041h,063h,0b3h,063h,043h,0e1h,0b1h,0e0h,041h,0e1h,0b1h,0e0h,041h,061h,041h,0e1h	; 9ae8  Ac.cC...A...AaA.
	defb 0b1h,0e0h,041h,063h,0b3h,063h,043h,0e1h,0b1h,0e0h,041h,0e1h,0b1h,0e0h,041h,061h	; 9af8  ..Ac.cC...A...Aa
	defb 0feh,002h,0f6h,09ah,041h,0e1h,0b1h,0e0h,041h,063h,0b3h,063h,043h,0e1h,0b1h,0e0h	; 9b08  ....A...Ac.cC...
	defb 041h,0e1h,0b1h,0e0h,041h,061h,0ffh,0d6h,0fch,025h,0e2h,013h,012h,060h,0b1h,0a3h	; 9b18  A...Aa...%...`..
	defb 061h,0e1h,012h,0e2h,040h,045h,010h,020h,040h,090h,0b0h,0e1h,010h,0e2h,062h,032h	; 9b28  a...@E. @.....b2
	defb 063h,0b1h,030h,050h,060h,080h,091h,060h,021h,091h,060h,0b1h,080h,041h,080h,0b1h	; 9b38  c.0P`..`!.`..A..
	defb 0e2h,013h,012h,060h,0b1h,0a3h,061h,0e1h,012h,0e2h,040h,045h,010h,020h,040h,090h	; 9b48  ...`..a...@E. @.
	defb 0b0h,0e1h,010h,031h,0e2h,060h,062h,0b1h,0e1h,011h,033h,0e2h,0b1h,082h,0e1h,01bh	; 9b58  ...1.`b...3.....
	defb 0c0h,0fch,024h,0e2h,092h,062h,095h,060h,080h,091h,082h,042h,019h,0fch,036h,030h	; 9b68  ..$..b.`...B..60
	defb 040h,060h,0b2h,061h,050h,060h,080h,0e1h,012h,0e2h,081h,060h,080h,090h,0e1h,022h	; 9b78  @`.aP`.....`..."
	defb 0e2h,091h,080h,090h,0b0h,0fbh,014h,0e1h,042h,0dch,0fch,014h,068h,0feh,0ffh,01fh	; 9b88  ........B...h...
	defb 09bh,0d6h,0fch,026h,0e4h,061h,0e3h,060h,060h,0e4h,061h,0e3h,060h,060h,0feh,003h	; 9b98  ...&.a.``.a.``..
	defb 0a1h,09bh,0e4h,091h,0e3h,090h,090h,0feh,004h,0aah,09bh,0e4h,0b1h,0e3h,0b0h,0b0h	; 9ba8  ................
	defb 0feh,004h,0b3h,09bh,0e3h,021h,0e2h,020h,0c0h,0e3h,021h,0e2h,020h,020h,0e3h,041h	; 9bb8  .....!. ..!.  .A
	defb 0e2h,040h,0c0h,0e3h,041h,0e2h,040h,040h,0e4h,061h,0e3h,060h,060h,0feh,004h,0d0h	; 9bc8  .@..A.@@.a.``...
	defb 09bh,0e4h,091h,0e3h,090h,090h,0feh,004h,0d9h,09bh,0e4h,0b1h,0e3h,0b0h,0b0h,0feh	; 9bd8  ................
	defb 004h,0e2h,09bh,0fbh,026h,0e3h,011h,0e2h,010h,010h,0feh,004h,0edh,09bh,0fch,023h	; 9be8  ....&..........#
	defb 0e3h,020h,0e2h,020h,0e3h,090h,0e2h,020h,0e3h,020h,0e2h,020h,0e3h,090h,0e2h,020h	; 9bf8  . . ... . . ...
	defb 0feh,003h,000h,09ch,0e4h,090h,0e3h,090h,040h,090h,0feh,004h,00ch,09ch,0e4h,0b0h	; 9c08  ........@.......
	defb 0e3h,0b0h,060h,0b0h,0e4h,0b0h,0e3h,0b0h,060h,0b0h,0e3h,010h,0e2h,010h,0e3h,080h	; 9c18  ..`.....`.......
	defb 0e2h,010h,0feh,002h,022h,09ch,0e3h,020h,0e2h,020h,0e3h,090h,0e2h,020h,0feh,002h	; 9c28  ....".. . ... ..
	defb 02eh,09ch,0e3h,040h,0e2h,040h,0e3h,0b0h,0e2h,040h,0feh,002h,03ah,09ch,0e3h,061h	; 9c38  ...@.@...@..:..a
	defb 0e2h,060h,060h,0feh,004h,046h,09ch,0feh,0ffh,099h,09bh,0d6h,0fah,011h,0e0h,060h	; 9c48  .``..F.........`
	defb 050h,030h,010h,0e1h,0b0h,0e0h,010h,030h,050h,060h,050h,030h,010h,0e1h,0b0h,0e0h	; 9c58  P0.....0P`P0....
	defb 010h,030h,050h,060h,040h,020h,010h,0e1h,0b0h,0e0h,010h,020h,040h,0feh,002h,06bh	; 9c68  .0P`@ ..... @..k
	defb 09ch,060h,050h,030h,010h,0e1h,0b0h,0e0h,010h,030h,050h,0feh,002h,079h,09ch,060h	; 9c78  .`P0.....0P..y.`
	defb 040h,020h,010h,0e1h,0b0h,0e0h,010h,020h,040h,060h,080h,090h,080h,060h,040h,020h	; 9c88  @ ..... @`...`@
	defb 040h,0f9h,011h,060h,050h,0f8h,011h,030h,010h,0f7h,011h,0e1h,0b0h,0e0h,010h,0f6h	; 9c98  @..`P..0........
	defb 011h,030h,050h,0ffh,0d6h,0fch,022h,0e3h,000h,010h,020h,030h,040h,050h,060h,070h	; 9ca8  .0P..."... 0@P`p
	defb 080h,090h,0a0h,0b0h,0e2h,000h,0fbh,012h,0e2h,030h,0e1h,030h,0e2h,0a0h,0e1h,000h	; 9cb8  .........0.0....
	defb 0feh,002h,0c0h,09ch,0e2h,070h,0e1h,030h,0e2h,0a0h,0e1h,000h,0e2h,050h,0e1h,030h	; 9cc8  .....p.0.....P.0
	defb 0e2h,0a0h,0e1h,000h,0e2h,030h,0e1h,030h,0e2h,0a0h,0e1h,000h,0e2h,050h,0e1h,030h	; 9cd8  .....0.0.....P.0
	defb 0e2h,0a0h,0e1h,000h,0e2h,070h,0e1h,030h,0e2h,0a0h,0e1h,000h,0e2h,050h,0e1h,030h	; 9ce8  .....p.0.....P.0
	defb 0e2h,0a0h,0e1h,000h,0fbh,002h,070h,070h,050h,070h,070h,070h,050h,0feh,003h,001h	; 9cf8  ......ppPpppP...
	defb 09dh,070h,0a0h,0a0h,080h,0a0h,0a0h,0a0h,080h,0a0h,0feh,002h,00ah,09dh,0e2h,030h	; 9d08  .p.............0
	defb 0e1h,030h,0e2h,0a0h,0e1h,000h,0e2h,050h,0e1h,030h,0e2h,0a0h,0e1h,000h,0feh,0ffh	; 9d18  .0.....P.0......
	defb 0cch,09ch,0d6h,0fah,000h,0e2h,000h,010h,020h,030h,040h,050h,060h,070h,080h,090h	; 9d28  ........ 0@P`p..
	defb 0a0h,0b0h,0e1h,000h,0fdh,035h,0e3h,031h,030h,030h,0feh,010h,03fh,09dh,0feh,0ffh	; 9d38  .....5.100..?...
	defb 03ch,09dh,0d6h,0fch,011h,0e1h,000h,010h,020h,030h,040h,050h,060h,070h,080h,090h	; 9d48  <....... 0@P`p..
	defb 0a0h,0b0h,0e0h,000h,0ffh,022h,004h,0d0h,020h,0d0h,010h,0d0h,024h,0d0h,012h,0d0h	; 9d58  .....".. ...$...
	defb 028h,0d0h,014h,0d0h,02ch,0d0h,016h,0d0h,030h,0d0h,018h,0d0h,034h,0d0h,01ah,0d0h	; 9d68  (...,...0...4...
	defb 038h,0d0h,01ch,0feh,00ah,05dh,09dh,0ffh,022h,004h,0d0h,010h,0d0h,008h,0d0h,012h	; 9d78  8....]..".......
	defb 0d0h,009h,0d0h,014h,0d0h,00ah,0d0h,016h,0d0h,00bh,0d0h,018h,0d0h,00ch,0d0h,01ah	; 9d88  ................
	defb 0d0h,00dh,0d0h,01ch,0d0h,00eh,0feh,00ah,080h,09dh,0ffh,022h,00eh,0d0h,060h,0c0h	; 9d98  ..........."..`.
	defb 05eh,0b0h,05ch,0a0h,05ah,090h,058h,0feh,008h,0a3h,09dh,0ffh,022h,001h,0f0h,020h	; 9da8  ^.\.Z.X....."..
	defb 0f0h,0a0h,0f1h,010h,0f1h,070h,0d1h,0c0h,0d2h,000h,0d2h,030h,0d2h,050h,0d2h,060h	; 9db8  .....p.....0.P.`
	defb 0e0h,060h,0e0h,0a0h,0e1h,010h,0e1h,070h,0e1h,0c0h,022h,002h,0f2h,000h,0f2h,030h	; 9dc8  .`.....p.."....0
	defb 0f2h,050h,0f2h,060h,0e0h,060h,0e0h,0a0h,0e1h,010h,0e1h,070h,0e1h,0c0h,0d2h,000h	; 9dd8  .P.`.`.....p....
	defb 0d2h,030h,0d2h,050h,0d0h,060h,0d0h,0a0h,0b1h,010h,0b1h,070h,0b1h,0c0h,0b2h,000h	; 9de8  .0.P.`.....p....
	defb 0b2h,030h,0a0h,060h,0a0h,0a0h,0a1h,010h,0a1h,070h,0a1h,0c0h,092h,000h,090h,060h	; 9df8  .0.`.....p.....`
	defb 090h,0a0h,091h,010h,091h,070h,081h,0c0h,080h,060h,080h,0a0h,081h,010h,081h,070h	; 9e08  .....p...`.....p
	defb 070h,060h,070h,0a0h,071h,010h,0ffh,022h,001h,0f0h,010h,0f0h,050h,0f0h,090h,0f0h	; 9e18  p`p.q.."....P...
	defb 0b8h,0f0h,0e0h,0f1h,000h,0f1h,018h,0f1h,028h,0f1h,030h,0d0h,030h,0d0h,050h,0d0h	; 9e28  ........(.0.0.P.
	defb 090h,0d0h,0b8h,0d0h,0e0h,022h,002h,0f1h,000h,0f1h,018h,0f1h,028h,0f1h,030h,0f0h	; 9e38  ....."......(.0.
	defb 030h,0e0h,050h,0e0h,090h,0e0h,0b8h,0e0h,0e0h,0e1h,000h,0d1h,018h,0d1h,028h,0d0h	; 9e48  0.P...........(.
	defb 030h,0d0h,050h,0d0h,090h,0b0h,0b8h,0b0h,0e0h,0b1h,000h,0b1h,018h,0a0h,030h,0a0h	; 9e58  0.P...........0.
	defb 050h,0a0h,090h,0a0h,0b8h,0a0h,0e0h,091h,000h,090h,030h,090h,050h,090h,090h,090h	; 9e68  P.........0.P...
	defb 0b8h,080h,0e0h,080h,030h,080h,050h,080h,090h,080h,0b8h,070h,030h,070h,050h,070h	; 9e78  ....0.P....p0pPp
	defb 090h,0ffh,022h,001h,0f0h,040h,0f1h,040h,0f2h,020h,0f2h,0e0h,0d3h,080h,0d4h,000h	; 9e88  .."..@.@. ......
	defb 0d4h,060h,0d4h,0a0h,0d4h,0c0h,0e0h,0c0h,0e1h,040h,0e2h,020h,0e2h,0e0h,0e3h,080h	; 9e98  .`.......@. ....
	defb 022h,002h,0f4h,000h,0f4h,060h,0f4h,0a0h,0f4h,0c0h,0f0h,0c0h,0e1h,040h,0e2h,020h	; 9ea8  "....`.......@.
	defb 0e2h,0e0h,0e3h,080h,0e4h,000h,0d4h,060h,0d4h,0a0h,0d0h,0c0h,0d1h,040h,0d2h,020h	; 9eb8  .......`.....@.
	defb 0b2h,0e0h,0b3h,080h,0b4h,000h,0b4h,060h,0a0h,0c0h,0a1h,040h,0a2h,020h,0a2h,0e0h	; 9ec8  .......`...@. ..
	defb 0a3h,080h,094h,000h,090h,0c0h,091h,040h,092h,020h,092h,0e0h,083h,080h,080h,0c0h	; 9ed8  .......@. ......
	defb 081h,040h,082h,020h,082h,0e0h,070h,0c0h,071h,040h,072h,020h,0ffh,022h,001h,0f1h	; 9ee8  .@. ..p.q@r ."..
	defb 000h,0f0h,080h,0feh,020h,0f7h,09eh,0e1h,000h,0e0h,080h,0feh,01ch,0ffh,09eh,0d1h	; 9ef8  .... ...........
	defb 000h,0d0h,080h,0feh,018h,007h,09fh,0c1h,000h,0c0h,080h,0feh,014h,00fh,09fh,0b1h	; 9f08  ................
	defb 000h,0b0h,080h,0feh,010h,017h,09fh,0a1h,000h,0a0h,080h,0feh,00ch,01fh,09fh,091h	; 9f18  ................
	defb 000h,090h,080h,0feh,008h,027h,09fh,081h,000h,080h,080h,0feh,004h,02fh,09fh,0ffh	; 9f28  .....'......./..
	defb 022h,001h,0f0h,080h,0f0h,040h,0feh,020h,03ah,09fh,0e0h,080h,0e0h,040h,0feh,01ch	; 9f38  "....@. :....@..
	defb 042h,09fh,0d0h,080h,0d0h,040h,0feh,018h,04ah,09fh,0c0h,080h,0c0h,040h,0feh,014h	; 9f48  B....@..J....@..
	defb 052h,09fh,0b0h,080h,0b0h,040h,0feh,010h,05ah,09fh,0a0h,080h,0a0h,040h,0feh,00ch	; 9f58  R....@..Z....@..
	defb 062h,09fh,090h,080h,090h,040h,0feh,008h,06ah,09fh,080h,080h,080h,040h,0feh,004h	; 9f68  b....@..j....@..
	defb 072h,09fh,0ffh,021h,001h,010h,0f0h,000h,0f0h,000h,0feh,020h,07eh,09fh,0e0h,000h	; 9f78  r..!....... ~...
	defb 0e0h,000h,0feh,01ch,086h,09fh,0d0h,000h,0d0h,000h,0feh,018h,08eh,09fh,0c0h,000h	; 9f88  ................
	defb 0c0h,000h,0feh,014h,096h,09fh,0b0h,000h,0b0h,000h,0feh,010h,09eh,09fh,0a0h,000h	; 9f98  ................
	defb 0a0h,000h,0feh,00ch,0a6h,09fh,090h,000h,090h,000h,0feh,008h,0aeh,09fh,080h,000h	; 9fa8  ................
	defb 080h,000h,0feh,004h,0b6h,09fh,0ffh,021h,001h,01fh,0f0h,000h,001h,01eh,0f0h,000h	; 9fb8  .......!........
	defb 01dh,0f0h,000h,01ch,0f0h,000h,01bh,0f0h,000h,01ah,0f0h,000h,019h,0f0h,000h,018h	; 9fc8  ................
	defb 0f0h,000h,021h,005h,017h,0f0h,000h,016h,0f0h,000h,021h,001h,01fh,0f0h,000h,01eh	; 9fd8  ..!.......!.....
	defb 0f0h,000h,01dh,0f0h,000h,01ch,0f0h,000h,01bh,0f0h,000h,01ah,0f0h,000h,019h,0f0h	; 9fe8  ................
	defb 000h,018h,0f0h,000h,021h,005h,017h,0e0h	; 9ff8  ....!...

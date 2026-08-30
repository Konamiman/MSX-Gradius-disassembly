#!/usr/bin/env python3
"""Comprobaciones sobre el listado generado.

Ninguna necesita el cartucho: se hacen sobre src/nemesis_pNN.asm y
src/pNN.notes. Vigilan que el desensamblado no se degrade sin que nadie se
entere: que no desaparezcan comentarios, que no vuelvan a aparecer bloques de
datos sin identificar, que las cifras publicadas sean las del arbol, y que la
regla banco -> org no se contradiga entre el Makefile y tools/paginas.py.
"""
import json
import os
import re
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))

from paginas import ORG, TAM_PAGINA, N_PAGINAS, nombre     # noqa: E402

SRC = os.path.join(RAIZ, "src")
WORK = os.path.join(RAIZ, "work")

# Los demas juegos de la serie. Que el nombre de otro aparezca en una pagina de
# este es casi siempre un copia y pega, y ya se publicaron cinco licencias
# nombrando el juego equivocado.
OTROS_JUEGOS = ("Pitfall", "Temptations", "Stardust", "Ale Hop", "Colt 36",
                "Middle Earth", "Monkey", "F-1 Spirit", "Athletic",
                "Antarctic", "Pippols", "Frogger", "Time Pilot",
                "Super Cobra", "Billiards", "Mahjong", "Hyper Olympic",
                "Hyper Sports", "Hyper Rally", "Demonia", "Cabbage")


def asm(p):
    with open(os.path.join(SRC, "nemesis_%s.asm" % nombre(p)), encoding="utf-8") as f:
        return f.read()


def notas(p):
    with open(os.path.join(SRC, "%s.notes" % nombre(p)), encoding="utf-8") as f:
        return f.read().splitlines()


def directivas(p, clave):
    return [l for l in notas(p) if l.startswith(clave + " ")]


def todas(clave):
    fuera = []
    for p in range(N_PAGINAS):
        fuera += directivas(p, clave)
    return fuera


class TestPaginas(unittest.TestCase):
    """La regla banco -> org, que es de lo que cuelga todo lo demas."""

    def test_los_dieciseis_bancos_tienen_org(self):
        self.assertEqual(sorted(ORG), list(range(N_PAGINAS)))

    def test_los_org_son_los_del_mapper(self):
        for p, o in ORG.items():
            self.assertIn(o, (0x4000, 0x6000, 0x8000, 0xA000),
                          "%s tiene un org que el mapper no puede dar" % nombre(p))
        self.assertEqual(ORG[0], 0x4000, "el banco 0 es el fijo")

    def test_el_makefile_repite_la_misma_tabla(self):
        with open(os.path.join(RAIZ, "Makefile"), encoding="utf-8") as f:
            texto = f.read()
        for p in range(N_PAGINAS):
            fila = re.search(r"(?m)^ORG_%02d\s*=\s*(0x[0-9a-fA-F]+)" % p, texto)
            self.assertIsNotNone(fila, "el Makefile no declara ORG_%02d" % p)
            self.assertEqual(int(fila.group(1), 16), ORG[p],
                             "el Makefile y tools/paginas.py no dicen lo mismo "
                             "del banco %d" % p)


class TestListado(unittest.TestCase):

    def test_ningun_bloque_de_datos_sin_identificar(self):
        for p in range(N_PAGINAS):
            n = asm(p).count("DATOS sin identificar")
            self.assertEqual(n, 0, "%s tiene %d bloques de datos sin "
                                   "identificar" % (nombre(p), n))

    # Cuantas rutinas se llaman con `call` y siguen sin bautizar, banco a
    # banco. NO ES UN OBJETIVO: es la DEUDA que queda por comentar, y el test
    # esta para que solo pueda bajar. Cuando se bautiza una rutina hay que
    # bajar tambien la cifra de aqui, y asi nadie puede deshacer trabajo sin
    # que el test lo cante.
    TECHO_SIN_NOMBRE = {0: 92, 1: 68, 2: 87, 3: 76, 7: 6, 10: 7}

    def test_la_deuda_de_bautizar_rutinas_no_crece(self):
        for p in range(N_PAGINAS):
            sueltas = sorted(set(re.findall(
                r"\bcall (?:n?[zc],|p[oe],|[mp],)?(L_[0-9A-F]{4})", asm(p))))
            techo = self.TECHO_SIN_NOMBRE.get(p, 0)
            self.assertLessEqual(
                len(sueltas), techo,
                "%s: %d rutinas llamadas y sin nombre, y el techo es %d. "
                "Si has bautizado alguna, baja el techo; si has quitado un "
                "nombre, vuelve a ponerlo. Las primeras: %s"
                % (nombre(p), len(sueltas), techo, " ".join(sueltas[:12])))

    def test_ninguna_etiqueta_declarada_dos_veces(self):
        for p in range(N_PAGINAS):
            nombres = re.findall(r"^([A-Za-z_][\w]*):", asm(p), re.M)
            repetidas = sorted({n for n in nombres if nombres.count(n) > 1})
            self.assertEqual(repetidas, [], "%s: etiquetas repetidas: %s"
                             % (nombre(p), " ".join(repetidas)))

    def test_ningun_comentario_de_linea_repetido(self):
        for p in range(N_PAGINAS):
            dirs = [l.split()[1].upper() for l in directivas(p, "C")]
            repes = sorted({d for d in dirs if dirs.count(d) > 1})
            self.assertEqual(repes, [], "%s: comentarios repetidos en %s"
                             % (nombre(p), " ".join(repes)))

    def test_ninguna_direccion_bautizada_dos_veces(self):
        for p in range(N_PAGINAS):
            dirs = [l.split()[1] for l in directivas(p, "L")]
            repes = sorted({d for d in dirs if dirs.count(d) > 1})
            self.assertEqual(repes, [], "%s: direcciones con dos nombres: %s"
                             % (nombre(p), " ".join(repes)))

    def test_todos_los_comentarios_llegan_al_listado(self):
        for p in range(N_PAGINAS):
            vivas = set(re.findall(r";([0-9a-f]{4})(?:\s|$)", asm(p), re.M))
            perdidos = [l.split()[1] for l in directivas(p, "C")
                        if l.split()[1][2:].lower() not in vivas]
            self.assertEqual(perdidos, [], "%s: comentarios que no llegan: %s"
                             % (nombre(p), " ".join(perdidos[:12])))

    def test_todas_las_etiquetas_llegan_al_listado(self):
        for p in range(N_PAGINAS):
            texto = asm(p)
            perdidas = [l.split()[2] for l in directivas(p, "L")
                        if not re.search(r"(?m)^%s:" % re.escape(l.split()[2]),
                                         texto)]
            self.assertEqual(perdidas, [], "%s: etiquetas que no llegan: %s"
                             % (nombre(p), " ".join(perdidas[:12])))

    def test_los_rangos_no_se_solapan(self):
        for p in range(N_PAGINAS):
            rangos = sorted((int(l.split()[1], 16), int(l.split()[2], 16),
                             l.split()[3]) for l in directivas(p, "D"))
            for (a1, b1, n1), (a2, b2, n2) in zip(rangos, rangos[1:]):
                self.assertLessEqual(b1, a2, "%s: %s (%04X-%04X) pisa a %s "
                                     "(%04X-%04X)"
                                     % (nombre(p), n1, a1, b1, n2, a2, b2))

    def test_todos_los_rangos_van_al_derecho_y_dentro(self):
        for p in range(N_PAGINAS):
            for l in directivas(p, "D"):
                a, b, nom = int(l.split()[1], 16), int(l.split()[2], 16), l.split()[3]
                self.assertLess(a, b, "%s: %s va del reves" % (nombre(p), nom))
                self.assertGreaterEqual(a, ORG[p], "%s: %s empieza fuera"
                                        % (nombre(p), nom))
                self.assertLessEqual(b, ORG[p] + TAM_PAGINA,
                                     "%s: %s acaba fuera" % (nombre(p), nom))

    def test_todos_los_rangos_estan_explicados(self):
        for p in range(N_PAGINAS):
            pelados = [l.split()[3] for l in directivas(p, "D")
                       if len(l.split()) < 5]
            self.assertEqual(pelados, [], "%s: rangos sin explicacion: %s"
                             % (nombre(p), " ".join(pelados)))

    def test_cada_anchura_cae_en_un_rango(self):
        for p in range(N_PAGINAS):
            inicios = {l.split()[1].lower() for l in directivas(p, "D")}
            sueltas = [l.split()[1] for l in directivas(p, "F")
                       if l.split()[1].lower() not in inicios]
            self.assertEqual(sueltas, [], "%s: anchuras sin rango: %s"
                             % (nombre(p), " ".join(sueltas[:12])))

    def test_cada_rango_declara_su_anchura(self):
        """La norma de la casa: cada tabla con su nombre y su anchura de fila."""
        for p in range(N_PAGINAS):
            anchos = {l.split()[1].lower() for l in directivas(p, "F")}
            sin = [l.split()[3] for l in directivas(p, "D")
                   if l.split()[1].lower() not in anchos]
            self.assertEqual(sin, [], "%s: rangos sin directiva F: %s"
                             % (nombre(p), " ".join(sin[:12])))

    def test_el_listado_lo_genera_la_herramienta(self):
        for p in range(N_PAGINAS):
            self.assertIn("Generado por tools/mkasm.py", asm(p))

    def test_cada_listado_dice_su_org(self):
        for p in range(N_PAGINAS):
            self.assertIn("org %#07x" % ORG[p], asm(p),
                          "%s no lleva el org que le toca" % nombre(p))

    def test_el_listado_no_habla_de_otro_juego(self):
        for p in range(N_PAGINAS):
            for juego in OTROS_JUEGOS:
                self.assertNotIn(juego, asm(p), "%s nombra %s"
                                 % (nombre(p), juego))

    def test_la_raiz_no_habla_de_otro_juego(self):
        for fichero in ("README.md", "README.es.md", "AVISO-LEGAL.md",
                        "LEGAL-NOTICE.md", "LICENSE", "Makefile"):
            ruta = os.path.join(RAIZ, fichero)
            if not os.path.exists(ruta):
                continue
            with open(ruta, encoding="utf-8") as f:
                texto = f.read()
            for juego in OTROS_JUEGOS:
                self.assertNotIn(juego, texto, "%s nombra %s" % (fichero, juego))

    def test_las_herramientas_no_hablan_de_otro_juego(self):
        for fn in sorted(os.listdir(os.path.join(RAIZ, "tools"))):
            if not fn.endswith(".py"):
                continue
            with open(os.path.join(RAIZ, "tools", fn), encoding="utf-8") as f:
                texto = f.read()
            for juego in OTROS_JUEGOS:
                self.assertNotIn(juego, texto, "tools/%s nombra %s" % (fn, juego))


class TestEntradas(unittest.TestCase):
    """Cada punto de entrada, con su justificacion y dentro de su banco."""

    def entradas(self, p):
        ruta = os.path.join(SRC, "%s.entries" % nombre(p))
        fuera = []
        with open(ruta, encoding="utf-8") as f:
            for i, ln in enumerate(f, 1):
                if ln.lstrip().startswith("#") or not ln.strip():
                    continue
                fuera.append((i, ln.rstrip()))
        return fuera

    def test_toda_entrada_cae_dentro_de_su_banco(self):
        for p in range(N_PAGINAS):
            for i, ln in self.entradas(p):
                a = int(ln.split()[0], 16)
                self.assertTrue(ORG[p] <= a < ORG[p] + TAM_PAGINA,
                                "%s linea %d: 0x%04X se sale del banco"
                                % (nombre(p), i, a))

    def test_toda_entrada_lleva_su_justificacion(self):
        for p in range(N_PAGINAS):
            for i, ln in self.entradas(p):
                self.assertIn("#", ln, "%s linea %d: entrada sin justificar: %s"
                              % (nombre(p), i, ln))
                self.assertGreater(len(ln.split("#", 1)[1].strip()), 8,
                                   "%s linea %d: la justificacion no dice nada: "
                                   "%s" % (nombre(p), i, ln))


class TestCifras(unittest.TestCase):
    """Las cifras que se publican tienen que ser las del arbol."""

    def cuentas(self):
        cod = 0
        for p in range(N_PAGINAS):
            ruta = os.path.join(WORK, "%s.trace.json" % nombre(p))
            if not os.path.exists(ruta):
                self.skipTest("faltan los trazados; corre `make trace`")
            with open(ruta, encoding="utf-8") as f:
                cod += json.load(f)["report"]["code_bytes"]
        return cod

    def test_los_readme_publican_las_cuentas_de_las_notas(self):
        cuentas = {clave: len(todas(clave)) for clave in "LCD"}
        for fichero, filas in (
                ("README.md", (("named labels", "L"),
                               ("anchored comments", "C"),
                               ("explained data ranges", "D"))),
                ("README.es.md", (("etiquetas con nombre", "L"),
                                  ("comentarios anclados", "C"),
                                  ("rangos de datos con explicación", "D")))):
            ruta = os.path.join(RAIZ, fichero)
            if not os.path.exists(ruta):
                continue
            with open(ruta, encoding="utf-8") as f:
                texto = f.read()
            for rotulo, clave in filas:
                fila = re.search(r"\|\s*%s\s*\|\s*([0-9.,]+)\s*\|"
                                 % re.escape(rotulo), texto)
                self.assertIsNotNone(fila, "%s no publica '%s'"
                                     % (fichero, rotulo))
                dice = int(fila.group(1).replace(".", "").replace(",", ""))
                self.assertEqual(dice, cuentas[clave],
                                 "%s dice %d %s y en las notas hay %d"
                                 % (fichero, dice, rotulo, cuentas[clave]))

    def test_los_readme_publican_los_bytes_de_codigo(self):
        cod = self.cuentas()
        for fichero, rotulo in (("README.md", "traced code"),
                                ("README.es.md", "código trazado")):
            ruta = os.path.join(RAIZ, fichero)
            if not os.path.exists(ruta):
                continue
            with open(ruta, encoding="utf-8") as f:
                texto = f.read()
            fila = re.search(r"\|\s*%s\s*\|\s*([0-9.,]+)" % re.escape(rotulo),
                             texto)
            self.assertIsNotNone(fila, "%s no publica '%s'" % (fichero, rotulo))
            dice = int(fila.group(1).replace(".", "").replace(",", ""))
            self.assertEqual(dice, cod, "%s dice %d bytes de codigo y el "
                             "trazado da %d" % (fichero, dice, cod))


# --------------------------------------------------------------------------
# Las afirmaciones que se publican en la web y en los bloques del listado,
# atadas a los bytes. No hace falta el cartucho: los bytes se leen del propio
# listado, que es lo que se publica y lo que `make verify` demuestra que
# reensambla en la ROM exacta. Si alguna deja de ser verdad, el test se cae
# antes de que la web mienta.
# --------------------------------------------------------------------------

_DEF = re.compile(r"^\s+def(b|w)\s+([^;]+);\s*([0-9a-f]{4})")


def bytes_del_listado(p):
    """direccion -> byte, sacado de las lineas defb/defw del listado."""
    fuera = {}
    for linea in asm(p).splitlines():
        m = _DEF.match(linea)
        if not m:
            continue
        ancho = 1 if m.group(1) == "b" else 2
        pos = int(m.group(3), 16)
        for trozo in m.group(2).split(","):
            trozo = trozo.strip()
            if not trozo.endswith("h"):
                continue
            v = int(trozo[:-1], 16)
            for i in range(ancho):
                fuera[pos] = (v >> (8 * i)) & 0xFF
                pos += 1
    return fuera


def palabra_de(datos, direccion):
    return datos[direccion] | (datos[direccion + 1] << 8)


class TestElCartucho(unittest.TestCase):
    """Lo que la web afirma, medido sobre los datos del listado."""

    @classmethod
    def setUpClass(cls):
        cls.p00 = bytes_del_listado(0)
        cls.p01 = bytes_del_listado(1)

    def test_el_vdp_deja_la_vram_del_reves(self):
        """Patrones en 0x2000 y colores en 0x0000, al reves que la BIOS."""
        regs = [self.p00[0x575A + i] for i in range(8)]
        self.assertEqual(regs, [0x02, 0xE2, 0x0E, 0x7F, 0x07, 0x76, 0x03, 0xE4])
        self.assertEqual((regs[4] & 0x04) << 11, 0x2000, "patrones")
        self.assertEqual((regs[3] & 0x80) << 6, 0x0000, "colores")
        self.assertEqual(regs[2] * 0x400, 0x3800, "tabla de nombres")
        self.assertEqual(regs[5] * 0x80, 0x3B00, "atributos de sprite")
        self.assertEqual(regs[6] * 0x800, 0x1800, "patrones de sprite")

    def test_la_marca_escondida_de_konami(self):
        """RC-742 y los ocho katakana, al final del banco 3."""
        datos = bytes_del_listado(3)
        marca = [datos[0xBFF5 + i] for i in range(11)]
        # Los ocho primeros son el titulo en katakana escrito al reves, el 0x08
        # dice cuantos son, y 0x42 0xAA es el RC-742.
        self.assertEqual(marca, [0x8C, 0x82, 0xB4, 0xB7, 0x92, 0xA6, 0xB7, 0x87,
                                 0x08, 0x42, 0xAA])

    def test_los_puntos_de_control_son_once_y_la_fase_12_se_sale(self):
        """La tabla de 0x4214 solo llega hasta la fase 11."""
        valores = [palabra_de(self.p00, 0x4212 + 2 * f) for f in range(1, 12)]
        self.assertEqual(valores, [0xF8, 0x100, 0xF2, 0x100, 0x100, 0x100,
                                   0xF8, 0x100, 0x100, 0x100, 0x100])
        # La fase 12 leeria en 0x422A, que ya no es dato: alli empieza codigo,
        # y por eso 0x422A no aparece en los defb/defw del listado.
        self.assertNotIn(0x422A, self.p00,
                         "0x422A ha dejado de ser codigo: la fase 12 ya no se sale")
        self.assertIn("call carga_la_fuente_de_la_fase", asm(0))

    def test_las_fases_3_y_6_no_tienen_terreno(self):
        """Su tramo de guion es 0xFFFF: la columna que entra es siempre cielo."""
        for fase in range(1, 13):
            ini = palabra_de(self.p00, 0x4499 + 6 * fase)
            sin_guion = ini == 0xFFFF
            self.assertEqual(sin_guion, fase in (3, 6),
                             "la fase %d %s tramo de guion"
                             % (fase, "no tiene" if sin_guion else "tiene"))

    def test_las_dos_tablas_de_tipos_se_emparejan(self):
        """Treinta y un tipos, cada uno con su motor y su remate."""
        motores = [palabra_de(self.p00, 0x5DFD + 2 * i) for i in range(31)]
        remates = [palabra_de(self.p01, 0x6B46 + 2 * i) for i in range(31)]
        # El tipo 7, el bicho que sale de la escotilla, es el unico con el motor
        # en el banco 0 y el remate en el 1: si esto cambia, el mapa de tipos
        # que publica la web deja de valer.
        self.assertEqual(motores[6], 0x5EE7)
        self.assertEqual(remates[6], 0x6C3F)

        # Veinte de los treinta y uno tienen en el banco 3 al menos una de las
        # dos rutinas, y dieciseis las dos. Es la cifra que publica la web.
        def en_3(d):
            return 0xA000 <= d < 0xC000
        alguna = sum(1 for m, r in zip(motores, remates) if en_3(m) or en_3(r))
        ambas = sum(1 for m, r in zip(motores, remates) if en_3(m) and en_3(r))
        self.assertEqual((alguna, ambas), (20, 16))

    def test_la_fila_de_la_estrella_siempre_cae_dentro(self):
        """Las 32 filas de 0x478E van del 1 al 0x14: nunca se salen de 22."""
        filas = [self.p00[0x478E + i] for i in range(32)]
        self.assertTrue(all(1 <= f <= 22 for f in filas), filas)

    def test_los_seis_bloques_de_la_presentacion_encadenan(self):
        """Cada bloque comprimido acaba justo donde empieza el siguiente."""
        datos = bytes_del_listado(9)

        def largo(ini):
            p = ini
            while True:
                m = datos[p]
                p += 1
                if m == 0x00:
                    return p - ini
                if m == 0x80:
                    p += 2
                elif m & 0x80:
                    p += m & 0x7F
                else:
                    p += 1
        sitios = [0x8300, 0x87FA, 0x8CB2, 0x917E, 0x9515, 0x989F]
        for uno, siguiente in zip(sitios, sitios[1:]):
            self.assertEqual(uno + largo(uno), siguiente,
                             "el bloque de 0x%04X no acaba en 0x%04X"
                             % (uno, siguiente))

    def test_el_relleno_del_chip(self):
        """48.219 bytes declarados relleno, cuatro bancos vacios de punta a punta.

        De esos 48.219, 47.820 son colas al final de un banco y 399 son el hueco
        que queda dentro del banco 3 entre el ultimo dato y la marca de Konami.
        """
        cola = vacios = 0
        for p in range(N_PAGINAS):
            for linea in directivas(p, "D"):
                trozos = linea.split()
                if len(trozos) < 4 or trozos[3] != "relleno":
                    continue
                largo = int(trozos[2], 16) - int(trozos[1], 16)
                cola += largo
                if largo == TAM_PAGINA:
                    vacios += 1
        self.assertEqual(cola, 48219)
        self.assertEqual(vacios, 4)
        # El hueco de dentro del banco 3, delante de la marca.
        self.assertEqual(cola - 47820, 399)

    def test_los_dos_juegos_de_piezas_del_mapa(self):
        """Las fases 5, 9, 10 y 12 leen las piezas de 0x8FF0 y el resto de 0x8000."""
        # La comparacion que lo decide esta en 0x46F5, y se lee en el listado.
        listado = asm(0)
        for fase in ("005h", "009h", "00ah", "00ch"):
            self.assertIn("cp %s" % fase, listado)
        self.assertIn("ld de,08ff0h", listado)
        self.assertIn("ld de,08000h", listado)


if __name__ == "__main__":
    unittest.main()

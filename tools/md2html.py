#!/usr/bin/env python3
"""Converts the .md documents to HTML with the project's style.

That way the GitHub Pages site is fully browsable, without depending on Jekyll
or on any gem: plain HTML is published and that is it.

It supports the Markdown we use: headings, paragraphs, lists, tables, code
blocks, quotes, links, images, bold, italics, inline code and separators.
"""
import html
import os
import re
import sys
import unicodedata

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from web_style import STYLE  # noqa: E402


# One menu per language. The site is published in English at the root of
# docs/ and in Spanish under docs/es/. They are the seven pages of the
# contract per language, plus the comparison of the two builds and the front
# page.
NAV_EN = [("index.html", "Home"), ("GETTING-STARTED.html", "Start"),
          ("THE-GAME.html", "The game"),
          ("THE-CARTRIDGE.html", "The cartridge"),
          ("THE-CODE.html", "The code"),
          ("FINDINGS.html", "Findings"),
          ("IN-THE-EMULATOR.html", "In the emulator"),
          ("OPEN-QUESTIONS.html", "Open questions")]
NAV_ES = [("index.html", "Portada"), ("EMPEZAR.html", "Empezar"),
          ("EL-JUEGO.html", "El juego"),
          ("EL-CARTUCHO.html", "El cartucho"),
          ("EL-CODIGO.html", "El código"),
          ("HALLAZGOS.html", "Hallazgos"),
          ("EN-EL-EMULADOR.html", "En el emulador"),
          ("PREGUNTAS-ABIERTAS.html", "Preguntas abiertas")]

# Each document has a different name in each language, so the language
# selector needs to know which page is each page's counterpart.
_PAIRS = [("GETTING-STARTED.html", "EMPEZAR.html"),
         ("THE-GAME.html", "EL-JUEGO.html"),
         ("THE-CARTRIDGE.html", "EL-CARTUCHO.html"),
         ("THE-CODE.html", "EL-CODIGO.html"),
         ("FINDINGS.html", "HALLAZGOS.html"),
         ("IN-THE-EMULATOR.html", "EN-EL-EMULADOR.html"),
         ("OPEN-QUESTIONS.html", "PREGUNTAS-ABIERTAS.html")]
COUNTERPART = {}
for _en, _es in _PAIRS:
    COUNTERPART[_en] = _es
    COUNTERPART[_es] = _en

# The footer is in the page's language. The catalogue number does not come
# from the catalogue: it comes from the cartridge itself, from the mark that
# Konami hid at the end of bank 3 and that Manuel Pazos discovered.
FOOTER = {
    "es": "<em>Nemesis / Gradius</em> lo publico Konami para MSX en 1986; su numero de catalogo es RC-742 y son 128 KB. Todos los derechos sobre el juego siguen siendo de sus titulares. Este trabajo es de preservacion, estudio y documentacion, y la imagen del cartucho no se distribuye.",
    "en": "<em>Nemesis / Gradius</em> was published by Konami for the MSX in 1986; its catalogue number is RC-742 and it is 128 KB. All rights in the game remain with their holders. This is preservation, study and documentation work, and the cartridge image is not distributed.",
}


def inline(t):
    """Formatting within a line: code, bold, italics, links, images.

    The code between backticks is SET ASIDE first and put back at the end.
    Splitting the line at the backticks and formatting each piece separately,
    which is the obvious approach, leaves unconverted any bold that has code
    inside it (`**behind the `call`**` was left with the asterisks showing),
    because the opening and the closing fall in different pieces.
    """
    codes = []

    def set_aside(m):
        codes.append("<code>%s</code>" % html.escape(m.group(1)))
        return "\x00%d\x01" % (len(codes) - 1)

    s = html.escape(re.sub(r"`([^`]+)`", set_aside, t))
    s = re.sub(r"!\[([^\]]*)\]\(([^)]+)\)", r'<img src="\2" alt="\1">', s)
    s = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", lambda m:
               f'<a href="{site_href(m.group(2))}">{m.group(1)}</a>', s)
    # In this series strikethrough marks a question already closed. Without
    # this the `~~` came out raw in the published page.
    s = re.sub(r"~~([^~]+)~~", r"<del>\1</del>", s)
    s = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", s)
    s = re.sub(r"(?<![\w*])\*([^*\n]+)\*(?![\w*])", r"<em>\1</em>", s)
    return re.sub("\x00([0-9]+)\x01", lambda m: codes[int(m.group(1))], s)


# The site is served from docs/, so anything outside that folder does not
# exist for the browser: those links are sent to the repository. It can be
# changed without touching the code with the environment variable.
REPO = os.environ.get("NEMESIS_REPO",
                      "https://github.com/antxiko/Nemesis-disassembly")


def site_href(href):
    """Links between documents point to .md; on the site they go to .html."""
    if href.startswith(("http", "#", "mailto:")):
        return href
    h = href.replace("docs/", "")
    # Whatever does not live under docs/ does not exist for the browser: the
    # source code, the tools, the measurements and the root files are sent to
    # the repository. This is checked BEFORE touching the "../", because that
    # is how they are cited from docs/ and stripping it leaves a link the site
    # cannot serve.
    bare = h
    while bare.startswith("../"):
        bare = bare[3:]
    if bare.startswith(("src/", "tools/", "medidas/")) or bare in (
            "README.md", "README.es.md", "LICENSE", "AVISO-LEGAL.md",
            "LEGAL-NOTICE.md", "Makefile"):
        return f"{REPO}/blob/main/{bare}"
    if h.startswith("../"):
        return h if h.endswith((".html", ".png", ".txt")) else bare
    h = bare
    if h.endswith(".md"):
        h = h[:-3] + ".html"
    return h


def anchor(title):
    """The id of a heading: lowercase, without accents and with hyphens.

    It is GitHub's convention, so a link to #el-mundo works the same on the
    published site as in the usual Markdown.
    """
    t = unicodedata.normalize("NFKD", title)
    t = "".join(c for c in t if not unicodedata.combining(c))
    t = re.sub(r"[*_`\[\]()]", "", t).lower()
    t = re.sub(r"[^a-z0-9]+", "-", t)
    return t.strip("-")


def convert(text, title, current, lang="en"):
    ln = text.split("\n")
    out, i = [], 0
    while i < len(ln):
        l = ln[i]
        if l.startswith("```"):                     # code block
            j = i + 1
            body = []
            while j < len(ln) and not ln[j].startswith("```"):
                body.append(ln[j]); j += 1
            out.append("<pre><code>" + html.escape("\n".join(body)) + "</code></pre>")
            i = j + 1; continue
        if re.match(r"^\s*\|", l) and i + 1 < len(ln) and re.match(r"^\s*\|[\s:|-]+\|?\s*$", ln[i + 1]):
            rows = []                               # table
            while i < len(ln) and re.match(r"^\s*\|", ln[i]):
                rows.append([c.strip() for c in ln[i].strip().strip("|").split("|")])
                i += 1
            head, body = rows[0], rows[2:]
            t = "<table><tr>" + "".join(f"<th>{inline(c)}</th>" for c in head) + "</tr>"
            for f in body:
                t += "<tr>" + "".join(f"<td>{inline(c)}</td>" for c in f) + "</tr>"
            out.append(t + "</table>"); continue
        m = re.match(r"^(#{1,4})\s+(.*)$", l)
        if m:
            n = len(m.group(1))
            # With an id, so a specific section can be linked from the front page.
            out.append(f'<h{n} id="{anchor(m.group(2))}">{inline(m.group(2))}</h{n}>')
            i += 1; continue
        if re.match(r"^---+\s*$", l):
            out.append("<hr>"); i += 1; continue
        if l.startswith(">"):
            quote = []
            while i < len(ln) and ln[i].startswith(">"):
                quote.append(ln[i].lstrip("> ").rstrip()); i += 1
            out.append(f"<blockquote>{inline(' '.join(quote))}</blockquote>"); continue
        if l.lstrip().startswith("<audio "):        # a player placed by hand
            out.append(l.strip()); i += 1; continue
        if re.match(r"^ {4,}\S", l):                # indented code block
            body = []
            while i < len(ln) and re.match(r"^ {4,}\S", ln[i]):
                body.append(ln[i][4:])
                i += 1
                # a blank line does not end the block if indentation follows it
                if i < len(ln) and not ln[i].strip() and \
                        i + 1 < len(ln) and re.match(r"^ {4,}\S", ln[i + 1]):
                    body.append(""); i += 1
            out.append("<pre><code>" + html.escape("\n".join(body)) + "</code></pre>")
            continue
        m = re.match(r"^\s*([-*]|\d+\.)\s+", l)
        if m:
            ordered = not m.group(1) in "-*"
            items, indented = [], []
            while i < len(ln) and (re.match(r"^\s*([-*]|\d+\.)\s+", ln[i]) or
                                   (indented and ln[i].startswith("  ") and ln[i].strip())):
                mm = re.match(r"^\s*(?:[-*]|\d+\.)\s+(.*)$", ln[i])
                if mm:
                    items.append(mm.group(1)); indented = True
                else:
                    items[-1] += " " + ln[i].strip()
                i += 1
            tag = "ol" if ordered else "ul"
            out.append(f"<{tag}>" + "".join(f"<li>{inline(x)}</li>" for x in items) + f"</{tag}>")
            continue
        if not l.strip():
            i += 1; continue
        para = []                                   # paragraph
        while i < len(ln) and ln[i].strip() and not re.match(
                r"^(#{1,4}\s|```|>|\s*([-*]|\d+\.)\s|---+\s*$|\s*\|)", ln[i]):
            para.append(ln[i].strip()); i += 1
        out.append(f"<p>{inline(' '.join(para))}</p>")

    menu = NAV_EN if lang == "en" else NAV_ES
    nav = "".join(f'<a href="{h}"{" style=color:var(--ink)" if h == current else ""}>{t}</a>'
                  for h, t in menu)
    # Language selector: it leads to the equivalent document, not the front page
    other = COUNTERPART.get(current, "index.html")
    if lang == "en":
        nav += f'<a href="es/{other}" style="margin-left:auto;color:var(--gold)">Castellano</a>'
    else:
        nav += f'<a href="../{other}" style="margin-left:auto;color:var(--gold)">English</a>'
    # The charset and the viewport are explicit: these pages carry accents,
    # Latin quotation marks and the degree sign, and without the declaration a
    # browser that does not get the charset from a header would read them as
    # if they were single-byte.
    return ('<meta charset="utf-8">\n'
            '<meta name="viewport" content="width=device-width,initial-scale=1">\n'
            f"<title>{html.escape(title)}</title>\n<style>{STYLE}</style>\n"
            f'<div class="w"><nav class="top">{nav}</nav>\n' + "\n".join(out) +
            f'\n<footer><p>{FOOTER[lang]}</p></footer></div>\n')


def main(docdir, lang="en"):
    # Only the menu pages are converted. docs/ also holds the working
    # documents with the raw measurements, which are not part of the site and
    # are left as they are.
    pages = {h[:-5] + ".md" for h, _ in (NAV_EN if lang == "en" else NAV_ES)}
    n = 0
    for fn in sorted(os.listdir(docdir)):
        if not fn.endswith(".md") or fn not in pages:
            continue
        src = os.path.join(docdir, fn)
        dst = os.path.join(docdir, fn[:-3] + ".html")
        text = open(src, encoding="utf-8").read()
        m = re.search(r"^#\s+(.*)$", text, re.M)
        title = (m.group(1) if m else fn[:-3]) + " — Nemesis / Gradius (Konami, 1986)"
        open(dst, "w", encoding="utf-8").write(
            convert(text, title, fn[:-3] + ".html", lang))
        print(f"  {fn} -> {os.path.basename(dst)}")
        n += 1
    print(f"{n} documents converted ({lang})")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else "en")

#!/usr/bin/env python3
"""The website stylesheet, shared by all the disassemblies.

It is pulled out into a separate module on purpose: the idea is that all the
disassemblies in this series look the same, so the design is touched here and
only once. It contains nothing specific to any game.
"""

STYLE = """
:root{--ink:#cfd0d4;--muted:#83868f;--bg:#000;--panel:#0c0e13;--line:#23262e;
  --red:#ff897d;--cyan:#65dbef;--green:#3eb849;--gold:#ded087}
@media (prefers-color-scheme:light){:root{--ink:#191a1e;--muted:#5a5d66;--bg:#e9e7e1;
  --panel:#f7f6f2;--line:#d0cdc5;--red:#b23f34;--cyan:#1c6b7c;--green:#2b7734;--gold:#8a7420}}
:root[data-theme="dark"]{--ink:#cfd0d4;--muted:#83868f;--bg:#000;--panel:#0c0e13;
  --line:#23262e;--red:#ff897d;--cyan:#65dbef;--green:#3eb849;--gold:#ded087}
:root[data-theme="light"]{--ink:#191a1e;--muted:#5a5d66;--bg:#e9e7e1;--panel:#f7f6f2;
  --line:#d0cdc5;--red:#b23f34;--cyan:#1c6b7c;--green:#2b7734;--gold:#8a7420}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);padding:0 1.25rem 6rem;
  font:15px/1.7 ui-monospace,"SF Mono",Menlo,Consolas,monospace}
.w{max-width:1120px;margin:0 auto}
.n{max-width:68ch}
h1,h2,h3,h4{font-weight:400;text-wrap:balance}
a{color:var(--cyan)}
img{image-rendering:pixelated;max-width:100%;height:auto;display:block}
header.top{display:flex;flex-direction:column;align-items:center;gap:1.5rem;
  padding:4rem 0 2rem;text-align:center}
header.top img{width:min(100%,642px)}
.claim{max-width:60ch;color:var(--muted);font-size:1.05rem}
.claim b{color:var(--ink);font-weight:400}
.facts{display:flex;flex-wrap:wrap;justify-content:center;gap:0 1.5rem;width:100%;
  font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);
  border-top:1px solid var(--line);border-bottom:1px solid var(--line);padding:.85rem 0}
.facts b{color:var(--red);font-weight:400}
nav{display:flex;flex-wrap:wrap;gap:1.25rem;justify-content:center;padding:1.25rem 0;
  font-size:12px;letter-spacing:.08em;text-transform:uppercase}
nav a{color:var(--muted);text-decoration:none;border-bottom:1px solid transparent}
nav a:hover,nav a:focus{color:var(--ink);border-bottom-color:var(--red)}
nav.docs{border-top:1px solid var(--line);border-bottom:1px solid var(--line);
  margin-bottom:1rem}
section{margin-top:4.5rem;scroll-margin-top:1rem}
section>h2{font-size:1rem;letter-spacing:.1em;text-transform:uppercase;
  border-left:3px solid var(--red);padding-left:.9rem;margin:0 0 1.5rem}
.stats{display:grid;gap:1px;background:var(--line);border:1px solid var(--line);
  grid-template-columns:repeat(auto-fit,minmax(160px,1fr))}
.stat{background:var(--panel);padding:1.1rem}
.stat b{display:block;font-size:1.7rem;color:var(--gold);font-weight:400;
  font-variant-numeric:tabular-nums;line-height:1.2}
.stat span{font-size:11px;letter-spacing:.07em;text-transform:uppercase;color:var(--muted)}
.finding{border-top:1px solid var(--line);padding-top:1.75rem;margin-top:2.5rem}
.finding:first-of-type{border-top:0;padding-top:0;margin-top:0}
.finding h3{margin:0 0 .75rem;font-size:1.15rem;color:var(--red)}
.finding h4{color:var(--gold);margin:1.5rem 0 .5rem;font-size:.95rem}
.finding p{margin:0 0 1rem}
pre.asm{background:var(--panel);border-left:2px solid var(--green);margin:1.25rem 0;
  padding:1rem 1.1rem;overflow-x:auto;font-size:13px;line-height:1.6;color:var(--ink)}
.pair{display:grid;gap:1.25rem;grid-template-columns:1fr}
@media(min-width:820px){.pair{grid-template-columns:1fr 1fr}}
.pair figure{margin:0}
table{border-collapse:collapse;width:100%;margin:1.25rem 0;font-size:13px;display:block;
  overflow-x:auto}
th,td{text-align:left;padding:.5rem .75rem;border-bottom:1px solid var(--line)}
th{color:var(--muted);font-weight:400;font-size:11px;letter-spacing:.07em;text-transform:uppercase}
td.num{font-variant-numeric:tabular-nums;color:var(--gold)}
.level{margin-top:2rem}
.level h3{margin:0 0 .9rem;font-size:.95rem;letter-spacing:.06em;text-transform:uppercase}
.level em{color:var(--cyan);font-style:normal}
.sep{color:var(--muted);margin:0 .6rem}
.grid{display:grid;gap:.9rem;grid-template-columns:repeat(auto-fill,minmax(250px,1fr))}
.grid figure{margin:0;background:var(--panel);box-shadow:0 0 0 1px var(--line)}
.grid figcaption{display:flex;justify-content:space-between;padding:.45rem .65rem;
  font-size:11px;color:var(--muted);border-top:1px solid var(--line)}
.addr{font-variant-numeric:tabular-nums;color:var(--green)}
footer{margin-top:5rem;padding-top:1.5rem;border-top:1px solid var(--line);
  color:var(--muted);font-size:12px}

/* Work-in-progress notice: it has to be seen before the figures, because a
   misread 100% does more harm than not showing it at all. */
.notice{background:#3a2a10;border-left:3px solid var(--gold);margin:1.5rem auto;
  padding:1rem 1.2rem;max-width:900px;border-radius:4px}
.notice p{margin:0;color:var(--ink);font-size:15px;line-height:1.65}
.gallery{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));
  gap:1.5rem;margin:1.5rem 0}
.gallery figure{margin:0}
.gallery img{width:100%;height:auto;image-rendering:pixelated;
  border:1px solid var(--line);border-radius:3px}
.gallery figcaption{color:var(--muted);font-size:13px;margin-top:.5rem}
audio{display:block;width:100%;max-width:640px;margin:.75rem 0 1.5rem}
"""
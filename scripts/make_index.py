#!/usr/bin/env python3
"""Write _site/index.html listing book.pdf and every chapter PDF with its title (from chapters/NN-*.typ)."""
import pathlib, re, sys, datetime

site = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "_site")
titles = {}
for f in sorted(pathlib.Path("chapters").glob("*.typ")):
    n = f.name[:2]
    m = re.search(r"^= (.+)$|\[(Epilogue[^\]]*)\]", f.read_text(), re.M)
    titles[n] = (m.group(1) or m.group(2)).strip() if m else f.stem
rows = "\n".join(f'<li><a href="chapters/ch{n}.pdf">{"Chapter " + str(int(n)) + ": " if int(n) <= 23 else ""}{t}</a></li>' for n, t in titles.items())
html = f"""<!doctype html><meta charset="utf-8"><title>The Ecology and Evolution of Color — drafts</title>
<style>body{{font:16px/1.5 Georgia,serif;max-width:40rem;margin:3rem auto;padding:0 1rem;color:#1b1f24}}a{{color:#2457B0}}li{{margin:.25rem 0}}</style>
<h1>The Ecology and Evolution of Color</h1><p><em>From Photons to Phylogenies</em> — Michael E. Alfaro, UCLA. Draft chapters, updated {datetime.date.today():%B %d, %Y}. Not for redistribution.</p>
<p><a href="book.pdf"><strong>Full draft (PDF)</strong></a></p><ol style="list-style:none;padding:0">{rows}</ol>"""
(site / "index.html").write_text(html)
print("wrote", site / "index.html")

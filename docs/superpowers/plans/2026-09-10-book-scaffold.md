# Book Repository Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the `ecology-evolution-color-book` repository so that a chapter can be drafted, built to a designed PDF, and published to GitHub Pages, with the bibliography and source-pack tooling that the Fall 2026 lockstep drafting needs.

**Architecture:** Native Typst book (`main.typ` + `lib.typ` template + one file per chapter) with vendored OFL fonts and two Typst Universe packages (hydra for running heads, marginalia for the outer margin column). Parts are figures of a custom kind so they land in the contents; chapters are level-1 headings numbered continuously. Python scripts (tested with pytest) harvest DOIs from the course repo into `refs.bib` and assemble per-lecture "source packs" from the course's speaker notes, scripts, and guides. R provides one ggplot2 theme and a save helper that writes SVG figures whose fonts Typst resolves from the vendored font directory. GitHub Actions compiles the book and per-chapter PDFs and deploys them to Pages.

**Tech Stack:** Typst 0.15.1 (installed via Homebrew), packages `@preview/hydra:0.6.3` and `@preview/marginalia:0.3.1`, fonts Libertinus 7.051 / Source Sans 3.052R / JetBrains Mono 2.304 (vendored), Python 3.14 with pytest in a `uv` venv, R 4.5.1 with ggplot2 + svglite + systemfonts + pavo, GitHub Actions with `typst-community/setup-typst@v5`, `gh` CLI (already authenticated as michaelalfaro).

**Spec:** `~/Dropbox/git/EEB187-ecology-evolution-color-2026/docs/specs/2026-09-10-color-textbook-design.md` (sections 4, 5, 6). Design decisions approved 2026-09-10: wide outer-margin layout, Libertinus, public drafts on GitHub Pages, new repository, working title *The Ecology and Evolution of Color: From Photons to Phylogenies*. One deviation from the spec, decided during a verified spike: the template is a home-grown `lib.typ` rather than `min-book`, because the spike showed native headings + two packages give full control with fewer moving parts.

## Global Constraints

- Typst version pinned to **0.15.1** everywhere (local, CI). Compile always with `--font-path fonts --ignore-system-fonts` so local and CI output match.
- Packages: `@preview/hydra:0.6.3`, `@preview/marginalia:0.3.1`. No other Typst packages in the scaffold.
- Fonts: body `Libertinus Serif`, math `Libertinus Math`, sans `Source Sans 3`, mono `JetBrains Mono`. All vendored under `fonts/`, OFL licensed, license files kept.
- Page: US Letter, `binding: left`, marginalia `inner: (far: 12mm, width: 0mm, sep: 0mm)`, `outer: (far: 10mm, width: 42mm, sep: 8mm)`, `top: 20mm`, `bottom: 24mm`, `book: true`. Body 11 pt, justified, old-style numerals.
- Palette: accent `#2457B0`; boxes physics `#2457B0`, casestudy `#2E7D4F`, tryit `#DF5A1C`, keyconcept `#6B3FA0`, caveat `#B3413A`; muted ink `#5B6470`.
- Numbering: chapters continuous across parts ("Chapter 5" opens Part II); sections `1.1`, `1.1.1`; figures, tables, equations reset per chapter and display as `1.2` / `(1.2)`; parts as roman numerals.
- Bibliography: BibTeX `refs.bib`, APA style (`style: "apa"`), author-date citations.
- Course repo (read-only source of material): `~/Dropbox/git/EEB187-ecology-evolution-color-2026`. Never modify it from these scripts.
- Repository path: `~/Dropbox/git/ecology-evolution-color-book`. Commit after every task. Do not push until Task 9.
- No secrets anywhere. The only email in code is the public course contact `michaelalfaro@g.ucla.edu`, used as the Crossref polite-pool `mailto`.

---

## File Structure

```
ecology-evolution-color-book/
  README.md                      # how to build, add a chapter, add a figure, weekly rhythm
  LICENSE-fonts.md               # pointers to the OFL files under fonts/
  .gitignore
  build.sh                       # full book + per-chapter PDFs + index.html into _site/
  main.typ                       # metadata, front matter, part/chapter includes, back matter; honors --input chapter=NN
  lib.typ                        # template: page, fonts, headings, parts, numbering, boxes, chapter apparatus, figure wrapper
  refs.bib                       # harvested bibliography (Task 6)
  chapters/01-what-color-is.typ … 23-how-life-became-colorful.typ, 24-epilogue.typ
  frontmatter/preface.typ
  figures/chNN/                  # generated SVG figures (R) and placed photographs
  fonts/                         # vendored OTF/TTF + OFL.txt per family
  R/theme_book.R                 # theme_book(), register_book_fonts(), save_fig()
  R/examples/blackbody.R         # example figure proving the R → SVG → Typst path
  scripts/source_pack.py         # lecture NN → drafts/source-packs/lecNN.md
  scripts/harvest_dois.py        # course repo → scripts/dois.txt
  scripts/fetch_bibtex.py        # dois.txt → refs.bib (cached under refs-cache/)
  scripts/make_index.py          # _site/index.html listing the PDFs
  drafts/source-packs/           # generated, committed (they are the writing inputs)
  tests/smoke.typ                # exercises every lib.typ function
  tests/check_smoke.sh           # compiles smoke.typ and asserts strings in pdftotext output
  tests/test_source_pack.py
  tests/test_harvest.py
  .github/workflows/build.yml
  docs/superpowers/plans/2026-09-10-book-scaffold.md   # this plan
```

Each file has one job: `lib.typ` is the only place that knows about design; `main.typ` is the only place that knows the book's order; chapter files contain prose only; scripts touch the course repo read-only.

---

### Task 1: Repository bootstrap

**Files:**
- Create: `README.md`, `.gitignore`, `pyproject.toml`, `build.sh` (stub that compiles main.typ only; extended in Task 8)

**Interfaces:**
- Produces: the git repo at `~/Dropbox/git/ecology-evolution-color-book`, a `uv` venv with pytest, `build.sh` that later tasks call.

- [ ] **Step 1: Initialize the repository and Python environment**

```bash
cd ~/Dropbox/git/ecology-evolution-color-book
git init -b main
cat > .gitignore <<'EOF'
_site/
*.pdf
!docs/**/*.pdf
.venv/
__pycache__/
.pytest_cache/
refs-cache/
.DS_Store
tests/*.pdf
EOF
cat > pyproject.toml <<'EOF'
[project]
name = "ecology-evolution-color-book"
version = "0.0.1"
description = "Tooling for The Ecology and Evolution of Color (textbook)"
requires-python = ">=3.12"
dependencies = []

[dependency-groups]
dev = ["pytest>=8"]

[tool.pytest.ini_options]
testpaths = ["tests"]
EOF
uv sync --group dev
.venv/bin/pytest --version
```
Expected: `pytest 8.x.x`.

- [ ] **Step 2: Write the minimal build script**

```bash
cat > build.sh <<'EOF'
#!/usr/bin/env bash
# Build the full book PDF. Extended in Task 8 with per-chapter PDFs and index.html.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p _site
typst compile --font-path fonts --ignore-system-fonts main.typ _site/book.pdf
echo "built _site/book.pdf"
EOF
chmod +x build.sh
```

- [ ] **Step 3: Write the README skeleton**

```bash
cat > README.md <<'EOF'
# The Ecology and Evolution of Color: From Photons to Phylogenies

Draft textbook by Michael Alfaro (UCLA EEB), built from EEB 187. Typeset in Typst.

## Build

    brew install typst          # 0.15.1 is pinned in CI; match it locally
    ./build.sh                  # full book -> _site/book.pdf
    typst watch --font-path fonts --ignore-system-fonts main.typ book.pdf   # live preview
    typst compile --font-path fonts --ignore-system-fonts --input chapter=03 main.typ ch03.pdf   # one chapter

## Layout

- `main.typ` — book order, front and back matter
- `lib.typ` — all design decisions (page, fonts, headings, boxes, figure wrapper)
- `chapters/NN-slug.typ` — one file per chapter, prose only
- `figures/chNN/` — figures for chapter NN (SVG from R, JPEG photographs)
- `refs.bib` — bibliography; cite with `@key`
- `scripts/` — DOI harvest and source-pack tooling (Python, `uv sync --group dev`; run `.venv/bin/pytest`)
- `R/` — `theme_book()` and `save_fig()` for figures

Sections on adding a chapter, adding a figure, and the weekly drafting rhythm are filled in by Task 9.
EOF
```

- [ ] **Step 4: Commit**

```bash
git add .gitignore pyproject.toml uv.lock build.sh README.md docs/
git commit -m "chore: bootstrap book repository

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01CbqBVBRvFGErUWwqAcYdEX"
```

---

### Task 2: Vendor fonts

**Files:**
- Create: `fonts/LibertinusSerif-*.otf`, `fonts/LibertinusMath-Regular.otf`, `fonts/SourceSans3-*.otf`, `fonts/JetBrainsMono-*.ttf`, `fonts/OFL-Libertinus.txt`, `fonts/OFL-SourceSans3.txt`, `fonts/OFL-JetBrainsMono.txt`, `LICENSE-fonts.md`

**Interfaces:**
- Produces: `fonts/` directory such that `typst fonts --font-path fonts --ignore-system-fonts` lists exactly the four families used by `lib.typ`.

- [ ] **Step 1: Write the check first (it fails until fonts exist)**

```bash
cat > tests/check_fonts.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
out=$(typst fonts --font-path fonts --ignore-system-fonts)
for f in "Libertinus Serif" "Libertinus Math" "Source Sans 3" "JetBrains Mono"; do
  echo "$out" | grep -qx "$f" || { echo "MISSING: $f"; exit 1; }
done
echo "fonts OK"
EOF
chmod +x tests/check_fonts.sh
mkdir -p fonts tests && tests/check_fonts.sh
```
Expected: `MISSING: Libertinus Serif`, exit 1.

- [ ] **Step 2: Download and extract only the files the book uses**

```bash
cd ~/Dropbox/git/ecology-evolution-color-book
tmp=$(mktemp -d)
curl -sL -o $tmp/lib.zip  https://github.com/alerque/libertinus/releases/download/v7.051/Libertinus-7.051.zip
curl -sL -o $tmp/ss3.zip  https://github.com/adobe-fonts/source-sans/releases/download/3.052R/OTF-source-sans-3.052R.zip
curl -sL -o $tmp/jbm.zip  https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
(cd $tmp && unzip -q lib.zip && unzip -q ss3.zip -d ss3 && unzip -q jbm.zip -d jbm)
# Libertinus: serif (regular, italic, bold, bold italic, semibold) + math
find $tmp -iname 'LibertinusSerif-*.otf' -exec cp {} fonts/ \;
find $tmp -iname 'LibertinusMath-Regular.otf' -exec cp {} fonts/ \;
find $tmp -path '*Libertinus*' -iname 'OFL.txt' -exec cp {} fonts/OFL-Libertinus.txt \;
# Source Sans 3: regular, italic, semibold, bold (skip the light/black weights)
for w in Regular It Semibold SemiboldIt Bold BoldIt; do find $tmp/ss3 -iname "SourceSans3-$w.otf" -exec cp {} fonts/ \; ; done
find $tmp/ss3 -iname 'LICENSE.md' -exec cp {} fonts/OFL-SourceSans3.txt \;
# JetBrains Mono: regular, italic, bold
for w in Regular Italic Bold; do find $tmp/jbm -path '*/fonts/ttf/*' -iname "JetBrainsMono-$w.ttf" -exec cp {} fonts/ \; ; done
find $tmp/jbm -iname 'OFL.txt' -exec cp {} fonts/OFL-JetBrainsMono.txt \;
ls fonts | wc -l; du -sh fonts
```
Expected: about 16 font files plus three license files, roughly 6–8 MB.

- [ ] **Step 3: Run the check**

Run: `tests/check_fonts.sh`
Expected: `fonts OK`

- [ ] **Step 4: Record licenses and commit**

```bash
cat > LICENSE-fonts.md <<'EOF'
# Font licenses

All fonts under `fonts/` are distributed under the SIL Open Font License 1.1 and are vendored so that local and CI builds are identical.

- Libertinus 7.051 — https://github.com/alerque/libertinus — `fonts/OFL-Libertinus.txt`
- Source Sans 3.052R — https://github.com/adobe-fonts/source-sans — `fonts/OFL-SourceSans3.txt`
- JetBrains Mono 2.304 — https://github.com/JetBrains/JetBrainsMono — `fonts/OFL-JetBrainsMono.txt`
EOF
git add fonts LICENSE-fonts.md tests/check_fonts.sh
git commit -m "chore: vendor Libertinus, Source Sans 3, JetBrains Mono (OFL)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01CbqBVBRvFGErUWwqAcYdEX"
```

---

### Task 3: The `lib.typ` template

**Files:**
- Create: `lib.typ`, `tests/smoke.typ`, `tests/smoke.bib`, `tests/check_smoke.sh`

**Interfaces:**
- Produces (all exported from `lib.typ`; `main.typ` and chapters use exactly these names):
  - `book(title:, subtitle:, author:, affiliation:, date:, draft: true, body)` — the `#show: book.with(...)` wrapper. Applies page, fonts, headings, numbering, outline styling, running heads.
  - `titlepage(title:, subtitle:, author:, affiliation:, date:, draft:)` — content.
  - `frontmatter(body)` / `mainmatter(body)` — roman vs arabic page numbers; `mainmatter` resets the page counter to 1.
  - `part(title, gloss: none)` — full-page part opener; appears in the contents.
  - `epigraph(quote, who)`
  - `in-this-chapter(..items)`, `key-ideas(..items)`, `open-questions(..items)`, `going-further(..items)` where `going-further` items are `(cite: [@key], note: [text])` dictionaries or plain content.
  - Boxes: `physics(title: [Physics of Light], body)`, `casestudy(title:, body)`, `tryit(title:, body)` (numbered per chapter), `keyconcept(body)`, `caveat(title: [Caveat], body)`.
  - `fig(path, caption, credit: none, width: 100%)` — figure with a small-caps credit line; caller attaches `<label>`.
  - `margin-fig(path, caption, credit: none)` — marginalia `notefigure` wrapper.
  - `margin-note(body)` and `measure-it(body)` — outer-margin notes; `measure-it` prefixes a sans "MEASURE IT" marker.
  - `accent`, `palette` — colors, for one-off use in chapters.

- [ ] **Step 1: Write the smoke test document and its assertion script (they fail until lib.typ exists)**

```bash
mkdir -p tests
cat > tests/smoke.bib <<'EOF'
@article{cuthill2017,
  author = {Cuthill, Innes C. and Allen, William L. and Arbuckle, Kevin},
  title = {The biology of color},
  journal = {Science},
  volume = {357}, number = {6350}, pages = {eaan0221}, year = {2017},
  doi = {10.1126/science.aan0221}
}
EOF
cat > tests/smoke.typ <<'EOF'
#import "../lib.typ": *
#show: book.with(title: [Smoke Test], subtitle: [Exercising lib.typ], author: [Test Author], affiliation: [UCLA], date: [2026], draft: true)

#frontmatter[
  #titlepage(title: [Smoke Test], subtitle: [Exercising lib.typ], author: [Test Author], affiliation: [UCLA], date: [2026], draft: true)
  #heading(level: 1, numbering: none, outlined: false)[Contents]
  #outline(title: none, depth: 2)
]

#mainmatter[
  #part([Light], gloss: [The illuminant and the object.])

  = What Color Is (and Isn't)
  #in-this-chapter([Color is a perception.], [Light is a spectrum.], [Endler's triangle.])
  #epigraph([The sky is blue because of the air, not despite it.], [A physicist])
  Body text with a citation @cuthill2017 and a margin note.#margin-note[Notes sit in the outer column.]
  #measure-it[Measure a feather at 45°.]

  == A section
  $ E = h nu $ <eq-planck>
  Equation @eq-planck, figure @fig-rect, margin figure @fig-margin, table @tbl-one.

  #fig("smoke-rect.svg", [A test figure.], credit: [Photo: Test Author, CC BY 4.0]) <fig-rect>
  #margin-fig("smoke-rect.svg", [A margin figure.]) <fig-margin>
  #figure(table(columns: 2, [a], [b]), caption: [A table.]) <tbl-one>

  #physics[Snell's law relates angles and refractive indices.]
  #casestudy(title: [The peacock])[Structural color in barbules.]
  #tryit(title: [Blue sky in a glass])[Shine a torch through milky water.]
  #tryit(title: [A second exercise])[Numbered 1.2.]
  #keyconcept[Color is made by the receiver.]
  #caveat[Human vision is not the reference.]

  #key-ideas([One], [Two], [Three])
  #open-questions([Why are some clades drab?])
  #going-further((cite: [@cuthill2017], note: [The field in twelve pages.]), [A plain item.])

  = Where Light Comes From
  == Another section
  Second chapter text.

  #part([Seeing])
  = Photoreceptors and Opsins
  Third chapter text. #tryit(title: [Restart])[Numbered 3.1.]
]

#heading(level: 1, numbering: none)[Bibliography]
#bibliography("smoke.bib", style: "apa", title: none)
EOF
# a tiny SVG asset for the figure calls
cat > tests/smoke-rect.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="120" height="60"><rect width="120" height="60" fill="#2457B0"/></svg>
EOF
cat > tests/check_smoke.sh <<'EOF'
#!/usr/bin/env bash
# Compile tests/smoke.typ and assert the design apparatus rendered.
set -euo pipefail
cd "$(dirname "$0")/.."
typst compile --font-path fonts --ignore-system-fonts tests/smoke.typ tests/smoke.pdf
txt=$(pdftotext -layout tests/smoke.pdf - 2>/dev/null)
fail=0
for s in "CHAPTER 1" "CHAPTER 3" "Part I" "Part II" "Light" "Seeing" \
         "1.1 A section" "(1.1)" "Figure 1.1" "Figure 1.2" "Table 1.1" \
         "Try it 1.1" "Try it 1.2" "Try it 3.1" \
         "Physics of Light" "The peacock" "Key concept" "Caveat" \
         "In this chapter" "Key ideas" "Open questions" "Going further" \
         "MEASURE IT" "Photo: Test Author" "Cuthill" "DRAFT"; do
  echo "$txt" | grep -qi -- "$s" || { echo "MISSING: $s"; fail=1; }
done
[ $fail -eq 0 ] && echo "smoke OK"
exit $fail
EOF
chmod +x tests/check_smoke.sh
tests/check_smoke.sh
```
Expected: compile error `file not found` for `../lib.typ`, exit 1.

- [ ] **Step 2: Write `lib.typ`**

```typst
// lib.typ — the only file that knows how the book looks.
// Verified against Typst 0.15.1, hydra 0.6.3, marginalia 0.3.1 (spike 2026-09-10).
#import "@preview/hydra:0.6.3": hydra
#import "@preview/marginalia:0.3.1" as marginalia: wideblock

// ---------- palette & fonts ----------
#let accent = rgb("#2457B0")
#let ink-muted = rgb("#5B6470")
#let palette = (
  physics: rgb("#2457B0"),
  casestudy: rgb("#2E7D4F"),
  tryit: rgb("#DF5A1C"),
  keyconcept: rgb("#6B3FA0"),
  caveat: rgb("#B3413A"),
)
#let serif = "Libertinus Serif"
#let sans = "Source Sans 3"
#let mono = "JetBrains Mono"
#let mathfont = "Libertinus Math"

// ---------- counters ----------
#let part-counter = counter("part")
#let tryit-counter = counter("tryit")

// ---------- small helpers ----------
#let label-text(body) = text(font: sans, size: 9pt, weight: "semibold", tracking: 0.06em, fill: ink-muted, upper(body))
#let chapter-number() = context counter(heading).display("1")

// ---------- margin notes ----------
#let margin-note(body) = marginalia.note(numbering: none, text(size: 9pt, body))
#let measure-it(body) = marginalia.note(numbering: none)[#label-text[Measure it] \ #text(size: 9pt, body)]
#let margin-fig(path, caption, credit: none) = marginalia.notefigure(
  image(path, width: 100%),
  caption: if credit == none { caption } else { caption + [ #text(font: sans, size: 7.5pt, fill: ink-muted, credit)] },
)

// ---------- figures ----------
#let fig(path, caption, credit: none, width: 100%) = figure(
  image(path, width: width),
  caption: if credit == none { caption } else { caption + h(0.5em) + text(font: sans, size: 8pt, fill: ink-muted, credit) },
)

// ---------- parts ----------
// A part is a figure of kind "part" so it appears in the outline with its title;
// the show rule in `book` draws the full page and hides the figure's own layout.
#let part(title, gloss: none) = {
  pagebreak(to: "odd", weak: true)
  part-counter.step()
  figure(kind: "part", supplement: [Part], numbering: "I", caption: title, outlined: true,
    if gloss == none { [] } else { gloss })
  pagebreak(to: "odd", weak: true)
}

// ---------- boxes ----------
#let _titled-box(color, title, body) = block(
  width: 100%, radius: 4pt, stroke: 0.6pt + color, breakable: true, inset: 0pt, clip: true,
  above: 1.4em, below: 1.4em,
)[
  #block(width: 100%, fill: color, inset: (x: 10pt, y: 5pt), sticky: true, below: 0pt)[
    #text(font: sans, fill: white, weight: "semibold", size: 10pt, title)
  ]
  #block(width: 100%, fill: color.lighten(92%), inset: (x: 10pt, y: 8pt), above: 0pt, body)
]
#let physics(title: [Physics of Light], body) = _titled-box(palette.physics, title, body)
#let casestudy(title: [Case study], body) = _titled-box(palette.casestudy, [Case study: #title], body)
#let caveat(title: [Caveat], body) = _titled-box(palette.caveat, title, body)
#let keyconcept(body) = block(
  width: 100%, fill: palette.keyconcept.lighten(92%), stroke: (left: 3pt + palette.keyconcept),
  inset: (x: 10pt, y: 8pt), above: 1.4em, below: 1.4em, breakable: true,
)[#label-text[Key concept] \ #body]
#let tryit(title: [], body) = {
  tryit-counter.step()
  block(
    width: 100%, fill: palette.tryit.lighten(92%), stroke: (left: 3pt + palette.tryit),
    inset: (x: 10pt, y: 8pt), above: 1.4em, below: 1.4em, breakable: true,
  )[
    #text(fill: palette.tryit, weight: "semibold")[Try it #chapter-number()\.#context tryit-counter.display()]
    #if title != [] [ — #strong(title)] \
    #body
  ]
}

// ---------- chapter apparatus ----------
#let epigraph(quote, who) = block(inset: (left: 2em, right: 2em), above: 1em, below: 2em)[
  #emph(quote) \ #align(right, text(size: 9.5pt, fill: ink-muted)[— #who])
]
#let _apparatus(title, items) = block(above: 1.6em, below: 1.2em, width: 100%)[
  #label-text(title) \
  #list(..items)
]
#let in-this-chapter(..items) = block(above: 0pt, below: 1.5em, width: 100%, inset: (left: 0pt))[
  #label-text[In this chapter] \
  #text(font: sans, size: 10pt)[#list(..items.pos())]
]
#let key-ideas(..items) = _apparatus([Key ideas], items.pos())
#let open-questions(..items) = _apparatus([Open questions], items.pos())
#let going-further(..items) = _apparatus([Going further], items.pos().map(it =>
  if type(it) == dictionary { [#it.cite #h(0.4em) #text(fill: ink-muted, it.note)] } else { it }))

// ---------- title page & matter ----------
#let titlepage(title: [], subtitle: [], author: [], affiliation: [], date: [], draft: true) = page(header: none, footer: none)[
  #v(22%)
  #text(size: 34pt, weight: "bold", title) \
  #v(0.6em)
  #text(size: 16pt, fill: ink-muted, subtitle)
  #v(2.5em)
  #text(size: 14pt, author) \ #text(size: 11pt, fill: ink-muted, affiliation)
  #v(1fr)
  #text(font: sans, size: 9pt, fill: ink-muted)[#date #if draft [ · DRAFT — not for redistribution]]
]
#let frontmatter(body) = { set page(numbering: "i"); body }
#let mainmatter(body) = { set page(numbering: "1"); counter(page).update(1); body }

// ---------- the book wrapper ----------
#let book(title: [], subtitle: [], author: [], affiliation: [], date: [], draft: true, body) = {
  set document(title: title, author: if type(author) == str { author } else { "" })
  set page(paper: "us-letter", binding: left, numbering: "1", footer: none,
    header: context {
      // no running head on a page that opens a chapter, a part, or the title
      let openers = query(heading.where(level: 1)).filter(h => h.location().page() == here().page())
      let parts = query(figure.where(kind: "part")).filter(p => p.location().page() == here().page())
      if openers.len() > 0 or parts.len() > 0 { none } else {
        set text(font: sans, size: 9pt, fill: ink-muted)
        let n = counter(page).display()
        if calc.odd(here().page()) { [#hydra(2) #h(1fr) #n] } else { [#n #h(1fr) #hydra(1)] }
      }
    })
  show: marginalia.setup.with(
    inner: (far: 12mm, width: 0mm, sep: 0mm), outer: (far: 10mm, width: 42mm, sep: 8mm),
    top: 20mm, bottom: 24mm, book: true)
  set text(font: serif, size: 11pt, number-type: "old-style")
  show math.equation: set text(font: mathfont)
  show raw: set text(font: mono, size: 9pt)
  set par(justify: true, first-line-indent: (amount: 1.2em, all: false), leading: 0.62em)
  show link: set text(fill: accent)

  // headings: level 1 = chapter, 2 = section, 3 = subsection
  set heading(numbering: "1.1.1")
  show heading.where(level: 1): it => {
    if it.numbering == none {
      pagebreak(to: "odd", weak: true)
      block(above: 3em, below: 2em, text(size: 26pt, weight: "bold", it.body))
    } else {
      pagebreak(to: "odd", weak: true)
      tryit-counter.update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(math.equation).update(0)
      block(above: 4em, below: 2.5em, width: 100%)[
        #text(font: sans, size: 11pt, weight: "semibold", tracking: 0.08em, fill: accent)[CHAPTER #counter(heading).display("1")]
        #v(0.2em) #line(length: 100%, stroke: 0.75pt + accent)
        #v(0.4em) #text(size: 26pt, weight: "bold", it.body)
        #v(0.4em) #line(length: 100%, stroke: 0.75pt + accent)
      ]
    }
  }
  show heading.where(level: 2): it => block(above: 1.8em, below: 0.9em)[
    #text(size: 15pt, weight: "bold")[#text(fill: accent, counter(heading).display("1.1")) #h(0.6em) #it.body]
  ]
  show heading.where(level: 3): it => block(above: 1.4em, below: 0.7em)[
    #text(size: 12pt, weight: "bold")[#text(fill: accent, counter(heading).display("1.1.1")) #h(0.6em) #it.body]
  ]

  // per-chapter numbering of figures, tables, equations
  set figure(numbering: n => numbering("1.1", counter(heading).get().first(), n))
  set math.equation(numbering: n => numbering("(1.1)", counter(heading).get().first(), n))
  show figure.caption: it => text(size: 9.5pt, it)

  // part pages
  show figure.where(kind: "part"): it => page(fill: accent.lighten(88%), header: none, footer: none)[
    #set align(left)
    #v(28%)
    #text(size: 120pt, weight: "bold", fill: accent)[#context part-counter.display("I")]
    #v(0.5em)
    #text(size: 32pt, weight: "bold", it.caption.body)
    #v(1em)
    #text(size: 13pt, fill: ink-muted, it.body)
  ]

  // outline: part banners, then chapters and sections
  show outline.entry: it => {
    if it.element.func() == figure {
      v(1em, weak: true)
      block(fill: accent.lighten(85%), inset: 6pt, width: 100%)[
        #text(weight: "bold")[Part #numbering("I", part-counter.at(it.element.location()).first()) #h(1em) #it.element.caption.body]
      ]
    } else if it.level == 1 {
      v(0.6em, weak: true); strong(it)
    } else { it }
  }
  set outline(target: selector.or(heading.where(outlined: true), figure.where(kind: "part")))

  body
}
```

- [ ] **Step 3: Compile and run the assertions**

Run: `tests/check_smoke.sh`
Expected: `smoke OK`. If a string is missing, open `tests/smoke.pdf` and fix `lib.typ` (not the test). Known things to look for: the part page must not carry a running head; "Try it" must restart at 3.1 in chapter 3; the outline must show `Part I  Light` banners before chapter 1 and `Part II  Seeing` before chapter 3.

- [ ] **Step 4: Look at the rendered pages once**

```bash
cd ~/Dropbox/git/ecology-evolution-color-book
pdftoppm -png -r 50 -f 3 -l 6 tests/smoke.pdf tests/smoke-page
```
Open `tests/smoke-page-05.png` (chapter 1 opener) with the Read tool. Check: chapter label and two accent rules; margin note in the outer column; boxes have a colored title bar and pale fill; credit line in small sans after the caption. Fix visual problems in `lib.typ`, rerun step 3. Delete the PNGs afterwards (`rm tests/smoke-page-*.png`).

- [ ] **Step 5: Commit**

```bash
git add lib.typ tests/smoke.typ tests/smoke.bib tests/smoke-rect.svg tests/check_smoke.sh
git commit -m "feat: lib.typ template with parts, chapter apparatus, boxes, margin column

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01CbqBVBRvFGErUWwqAcYdEX"
```

---

### Task 4: `main.typ`, chapter files, selective compile

**Files:**
- Create: `main.typ`, `frontmatter/preface.typ`, `chapters/01-what-color-is.typ` … `chapters/24-epilogue.typ`, `refs.bib` (seed with the single Cuthill entry until Task 6 replaces it), `tests/check_main.sh`

**Interfaces:**
- Consumes: everything exported by `lib.typ` (Task 3).
- Produces: `main.typ` honoring `--input chapter=NN` (two-digit); chapter files each start with a level-1 heading and an `in-this-chapter` block.

- [ ] **Step 1: Write the check script (fails until main.typ exists)**

```bash
cat > tests/check_main.sh <<'EOF'
#!/usr/bin/env bash
# Full build has all 24 chapter headings in order; a single-chapter build is small and numbered correctly.
set -euo pipefail
cd "$(dirname "$0")/.."
typst compile --font-path fonts --ignore-system-fonts main.typ tests/main.pdf
txt=$(pdftotext -layout tests/main.pdf - 2>/dev/null)
for n in $(seq 1 23); do echo "$txt" | grep -qE "CHAPTER $n( |$)" || { echo "MISSING CHAPTER $n"; exit 1; }; done
echo "$txt" | grep -q "Epilogue" || { echo "MISSING Epilogue"; exit 1; }
for p in I II III IV V VI VII; do echo "$txt" | grep -q "Part $p " || { echo "MISSING Part $p"; exit 1; }; done
typst compile --font-path fonts --ignore-system-fonts --input chapter=05 main.typ tests/ch05.pdf
t5=$(pdftotext -layout tests/ch05.pdf - 2>/dev/null)
echo "$t5" | grep -q "CHAPTER 5" || { echo "single-chapter build lost its number"; exit 1; }
[ "$(pdfinfo tests/ch05.pdf | awk '/^Pages/ {print $2}')" -lt 8 ] || { echo "single-chapter build too long"; exit 1; }
echo "main OK"
EOF
chmod +x tests/check_main.sh; tests/check_main.sh
```
Expected: compile error, exit 1.

- [ ] **Step 2: Generate the 24 chapter stubs from the approved outline**

```bash
cd ~/Dropbox/git/ecology-evolution-color-book && mkdir -p chapters frontmatter figures
python3 - <<'EOF'
import pathlib
chapters = [
 ("01","what-color-is","What Color Is (and Isn't)"),
 ("02","where-light-comes-from","Where Light Comes From, and Where It Goes"),
 ("03","scattering","Scattering"),
 ("04","interference-and-reflection","Interference and Reflection"),
 ("05","photoreceptors-and-opsins","Photoreceptors and Opsins"),
 ("06","evolution-of-eyes","The Evolution of Eyes"),
 ("07","building-a-color-percept","Building a Color Percept"),
 ("08","umwelten","Umwelten: Color Vision Across Life, and the Psychology of the Receiver"),
 ("09","measuring-color","Measuring Color"),
 ("10","modeling-the-receiver","Modeling the Receiver"),
 ("11","pigments","Pigments"),
 ("12","structural-color","Structural Color"),
 ("13","mixed-mechanisms","Mixed Mechanisms"),
 ("14","color-change","Color Change"),
 ("15","how-patterns-form","How Patterns Form"),
 ("16","genetics-of-color-and-pattern","The Genetics of Color and Pattern"),
 ("17","crypsis","Crypsis"),
 ("18","aposematism-and-mimicry","Warning and Deceit: Aposematism and Mimicry"),
 ("19","signals","Signals: Sexual Selection, Status, and Recognition"),
 ("20","color-for-the-body","Color for the Body Itself"),
 ("21","color-beyond-animals","Color Beyond Animals"),
 ("22","how-we-study-color-evolution","How We Study the Evolution of Color"),
 ("23","how-life-became-colorful","How Life Became Colorful"),
]
for n, slug, title in chapters:
    p = pathlib.Path(f"chapters/{n}-{slug}.typ")
    p.write_text(f"""#import "../lib.typ": *

= {title}
#in-this-chapter([Draft: not yet written.], [Sources: see drafts/source-packs/.], [Target: Fall 2026 lockstep drafting.])

This chapter has not been drafted yet.
""")
    pathlib.Path(f"figures/ch{n}").mkdir(exist_ok=True)
pathlib.Path("chapters/24-epilogue.typ").write_text("""#import "../lib.typ": *

#heading(level: 1, numbering: none)[Epilogue: The Human Eye on Color]

This epilogue has not been drafted yet.
""")
pathlib.Path("frontmatter/preface.typ").write_text("""#import "../lib.typ": *

#heading(level: 1, numbering: none)[Preface]

This book grew out of EEB 187, Ecology and Evolution of Color, at UCLA. It is being drafted in the open during the Fall 2026 offering: each chapter is posted the week its lecture is taught, and student reflections shape the revisions. What this book is, and is not, and how to use it, will be written here once the first part is complete.
""")
print("wrote", len(chapters)+2, "files")
EOF
```

- [ ] **Step 3: Write `main.typ`**

```typst
// main.typ — the order of the book. Design lives in lib.typ; prose lives in chapters/.
#import "lib.typ": *

#let title = [The Ecology and Evolution of Color]
#let subtitle = [From Photons to Phylogenies]
#let only = sys.inputs.at("chapter", default: none)   // e.g. --input chapter=05

// ch(n, path): include a chapter; in single-chapter mode, skip others and set the chapter number.
#let ch(n, path) = {
  if only == none { include path }
  else if only == n { counter(heading).update(int(n) - 1); include path }
}
// parts are skipped in single-chapter mode
#let pt(title, gloss: none) = if only == none { part(title, gloss: gloss) }

#show: book.with(title: title, subtitle: subtitle, author: "Michael E. Alfaro",
  affiliation: [Department of Ecology and Evolutionary Biology, UCLA], date: [Draft of #datetime.today().display("[month repr:long] [day], [year]")], draft: true)

#if only == none [
  #frontmatter[
    #titlepage(title: title, subtitle: subtitle, author: [Michael E. Alfaro],
      affiliation: [Department of Ecology and Evolutionary Biology, UCLA],
      date: [Draft of #datetime.today().display("[month repr:long] [day], [year]")], draft: true)
    #include "frontmatter/preface.typ"
    #heading(level: 1, numbering: none, outlined: false)[Contents]
    #outline(title: none, depth: 2)
  ]
]

#mainmatter[
  #pt([Light], gloss: [The illuminant and the object. Endler's triangle is the spine of the book.])
  #ch("01", "chapters/01-what-color-is.typ")
  #ch("02", "chapters/02-where-light-comes-from.typ")
  #ch("03", "chapters/03-scattering.typ")
  #ch("04", "chapters/04-interference-and-reflection.typ")

  #pt([Seeing], gloss: [The receiver, bottom-up: molecule, organ, circuit, experience.])
  #ch("05", "chapters/05-photoreceptors-and-opsins.typ")
  #ch("06", "chapters/06-evolution-of-eyes.typ")
  #ch("07", "chapters/07-building-a-color-percept.typ")
  #ch("08", "chapters/08-umwelten.typ")

  #pt([Measuring and Modeling Color], gloss: [The bridge from physics and vision to everything that follows.])
  #ch("09", "chapters/09-measuring-color.typ")
  #ch("10", "chapters/10-modeling-the-receiver.typ")

  #pt([Making Color])
  #ch("11", "chapters/11-pigments.typ")
  #ch("12", "chapters/12-structural-color.typ")
  #ch("13", "chapters/13-mixed-mechanisms.typ")
  #ch("14", "chapters/14-color-change.typ")

  #pt([Patterning])
  #ch("15", "chapters/15-how-patterns-form.typ")
  #ch("16", "chapters/16-genetics-of-color-and-pattern.typ")

  #pt([What Color Does])
  #ch("17", "chapters/17-crypsis.typ")
  #ch("18", "chapters/18-aposematism-and-mimicry.typ")
  #ch("19", "chapters/19-signals.typ")
  #ch("20", "chapters/20-color-for-the-body.typ")
  #ch("21", "chapters/21-color-beyond-animals.typ")

  #pt([Color Across the Tree of Life])
  #ch("22", "chapters/22-how-we-study-color-evolution.typ")
  #ch("23", "chapters/23-how-life-became-colorful.typ")
  #ch("24", "chapters/24-epilogue.typ")
]

#if only == none [
  #heading(level: 1, numbering: none)[Bibliography]
  #bibliography("refs.bib", style: "apa", title: none)
]
```
Seed the bibliography so the build has one: `cp tests/smoke.bib refs.bib`.

- [ ] **Step 4: Run the check**

Run: `tests/check_main.sh`
Expected: `main OK`. If the single-chapter build shows `CHAPTER 1` instead of `CHAPTER 5`, the `counter(heading).update` in `ch` is not taking effect before the include; move the update into the chapter's own show rule path by wrapping: `{ counter(heading).update(int(n) - 1); include path }` inside a `context`-free block as written above and confirm the include is not inside `#if only == none [...]` content brackets.

- [ ] **Step 5: Commit**

```bash
git add main.typ chapters frontmatter figures refs.bib tests/check_main.sh
git commit -m "feat: main.typ with 23 chapter stubs, parts, and single-chapter builds

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01CbqBVBRvFGErUWwqAcYdEX"
```

---

### Task 5: R figure theme and the SVG-to-Typst path

**Files:**
- Create: `R/theme_book.R`, `R/examples/blackbody.R`, `figures/ch02/blackbody.svg` (generated), `tests/check_figure.sh`

**Interfaces:**
- Produces: `register_book_fonts(fonts_dir = "fonts")`, `theme_book(base_size = 9)`, `save_fig(plot, name, chapter, width_mm = 134, height_mm = 80)` writing `figures/chNN/<name>.svg`.
- Downstream: chapters call `#fig("../figures/ch02/blackbody.svg", [...])`.

- [ ] **Step 1: Write the check (fails until the example figure exists)**

```bash
cat > tests/check_figure.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
Rscript R/examples/blackbody.R
test -s figures/ch02/blackbody.svg || { echo "no svg"; exit 1; }
grep -q 'Libertinus Serif' figures/ch02/blackbody.svg || { echo "svg does not use the book font"; exit 1; }
cat > tests/fig.typ <<'T'
#import "../lib.typ": *
#show: book.with(title: [fig], draft: true)
= Test
#fig("../figures/ch02/blackbody.svg", [Blackbody spectra at three temperatures.], credit: [Figure: M. Alfaro]) <fig-bb>
See @fig-bb.
T
typst compile --font-path fonts --ignore-system-fonts tests/fig.typ tests/fig.pdf 2>&1 | tee tests/fig.log
grep -q 'unknown font' tests/fig.log && { echo "Typst could not resolve the SVG font"; exit 1; }
pdftotext tests/fig.pdf - | grep -q "Figure 1.1" && echo "figure OK"
EOF
chmod +x tests/check_figure.sh; tests/check_figure.sh
```
Expected: `Rscript` error (file missing), exit 1.

- [ ] **Step 2: Write the theme and save helper**

```r
# R/theme_book.R — one look for every figure in the book.
# Fonts are registered from the vendored fonts/ directory so no system install is needed.
library(ggplot2)

register_book_fonts <- function(fonts_dir = "fonts") {
  systemfonts::register_font(
    name = "Libertinus Serif",
    plain = file.path(fonts_dir, "LibertinusSerif-Regular.otf"),
    bold = file.path(fonts_dir, "LibertinusSerif-Bold.otf"),
    italic = file.path(fonts_dir, "LibertinusSerif-Italic.otf"),
    bolditalic = file.path(fonts_dir, "LibertinusSerif-BoldItalic.otf"))
  systemfonts::register_font(
    name = "Source Sans 3",
    plain = file.path(fonts_dir, "SourceSans3-Regular.otf"),
    bold = file.path(fonts_dir, "SourceSans3-Bold.otf"),
    italic = file.path(fonts_dir, "SourceSans3-It.otf"),
    bolditalic = file.path(fonts_dir, "SourceSans3-BoldIt.otf"))
  invisible(TRUE)
}

book_accent <- "#2457B0"
book_ink <- "#1B1F24"
book_muted <- "#5B6470"

theme_book <- function(base_size = 9) {
  theme_minimal(base_size = base_size, base_family = "Libertinus Serif") +
    theme(
      text = element_text(colour = book_ink),
      axis.title = element_text(size = base_size, colour = book_muted),
      axis.text = element_text(size = base_size - 1, colour = book_muted),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "#E4E4DF", linewidth = 0.3),
      legend.position = "bottom",
      legend.title = element_blank(),
      plot.title = element_blank(),
      plot.margin = margin(4, 8, 4, 4))
}

# save_fig: write figures/chNN/<name>.svg at print width. Default width is the text block (134 mm).
save_fig <- function(plot, name, chapter, width_mm = 134, height_mm = 80) {
  dir <- file.path("figures", sprintf("ch%02d", as.integer(chapter)))
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  path <- file.path(dir, paste0(name, ".svg"))
  svglite::svglite(path, width = width_mm / 25.4, height = height_mm / 25.4)
  print(plot)
  dev.off()
  invisible(path)
}
```

- [ ] **Step 3: Write the example figure (Chapter 2, Planck curves)**

```r
# R/examples/blackbody.R — Planck spectral radiance for three temperatures; the book's first generated figure.
source("R/theme_book.R")
register_book_fonts()

planck <- function(lambda_nm, T) {
  h <- 6.62607015e-34; c <- 2.99792458e8; k <- 1.380649e-23
  l <- lambda_nm * 1e-9
  (2 * h * c^2 / l^5) / (exp(h * c / (l * k * T)) - 1)
}
lambda <- seq(200, 2000, by = 5)
d <- do.call(rbind, lapply(c(3000, 5778, 8000), function(T)
  data.frame(lambda = lambda, T = factor(paste0(T, " K")), B = planck(lambda, T))))
d$B <- d$B / max(d$B)

p <- ggplot(d, aes(lambda, B, colour = T)) +
  annotate("rect", xmin = 380, xmax = 700, ymin = -Inf, ymax = Inf, fill = "#F1F1EC", alpha = 0.8) +
  geom_line(linewidth = 0.7) +
  scale_colour_manual(values = c("#B3413A", "#DF5A1C", "#2457B0")) +
  labs(x = "Wavelength (nm)", y = "Spectral radiance (relative)") +
  theme_book()
save_fig(p, "blackbody", chapter = 2)
```

- [ ] **Step 4: Run the check**

Run: `tests/check_figure.sh`
Expected: `figure OK` and no `unknown font` warning. If svglite writes `font-family` as something other than `Libertinus Serif`, confirm `register_book_fonts()` ran before the plot was printed and that the file names in `fonts/` match the paths in `register_book_fonts`.

- [ ] **Step 5: Commit**

```bash
git add R tests/check_figure.sh figures/ch02/blackbody.svg
git commit -m "feat: theme_book() and save_fig(); Planck-curve example proves R->SVG->Typst

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01CbqBVBRvFGErUWwqAcYdEX"
```

---

### Task 6: Bibliography harvest (DOIs → refs.bib)

**Files:**
- Create: `scripts/harvest_dois.py`, `scripts/fetch_bibtex.py`, `tests/test_harvest.py`, `scripts/dois.txt` (generated, committed), `refs.bib` (generated, committed), `scripts/dois-failed.txt` (generated)

**Interfaces:**
- Produces: `harvest_dois.find_dois(text: str) -> list[str]`, `harvest_dois.normalize(doi: str) -> str`, `fetch_bibtex.make_key(entry: str) -> str`, `fetch_bibtex.rekey(entry: str, key: str) -> str`, and the two CLIs.

- [ ] **Step 1: Write the failing tests**

```python
# tests/test_harvest.py
import sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / "scripts"))
import harvest_dois as h
import fetch_bibtex as f

def test_find_dois_extracts_and_dedupes():
    text = "Cuthill (doi:10.1126/science.aan0221). See https://doi.org/10.1126/science.aan0221, and 10.1111/brv.12500."
    assert h.find_dois(text) == ["10.1126/science.aan0221", "10.1111/brv.12500"]

def test_normalize_strips_trailing_punctuation_and_lowercases():
    assert h.normalize("10.1098/RSPB.1998.0302).") == "10.1098/rspb.1998.0302"
    assert h.normalize("10.1016/j.tree.2018.03.001,") == "10.1016/j.tree.2018.03.001"

def test_find_dois_ignores_markdown_link_tail():
    assert h.find_dois("[paper](https://doi.org/10.1038/nature03312)") == ["10.1038/nature03312"]

ENTRY = """@article{Cuthill_2017, title={The biology of color}, volume={357}, DOI={10.1126/science.aan0221},
 number={6350}, journal={Science}, author={Cuthill, Innes C. and Allen, William L.}, year={2017}, pages={eaan0221} }"""

def test_make_key_is_surname_year_firstword():
    assert f.make_key(ENTRY) == "cuthill2017biology"

def test_make_key_handles_first_last_order_and_diacritics():
    e = ENTRY.replace("author={Cuthill, Innes C. and Allen, William L.}", "author={Mäthger, Lydia M. and Hanlon, Roger}")
    assert f.make_key(e) == "mathger2017biology"

def test_rekey_replaces_only_the_key():
    out = f.rekey(ENTRY, "cuthill2017biology")
    assert out.startswith("@article{cuthill2017biology,")
    assert "DOI={10.1126/science.aan0221}" in out

def test_disambiguate_appends_letters():
    assert f.disambiguate(["a2017x", "a2017x", "b2018y", "a2017x"]) == ["a2017x", "a2017xa", "b2018y", "a2017xb"]
```
Run: `.venv/bin/pytest tests/test_harvest.py -v`
Expected: FAIL with `ModuleNotFoundError: harvest_dois`.

- [ ] **Step 2: Write `scripts/harvest_dois.py`**

```python
#!/usr/bin/env python3
"""Harvest every DOI mentioned in the EEB 187 course repo into scripts/dois.txt (one per line, sorted, unique).
Read-only with respect to the course repo."""
import pathlib, re, sys

COURSE = pathlib.Path("~/Dropbox/git/EEB187-ecology-evolution-color-2026").expanduser()
EXTS = {".qmd", ".md", ".txt", ".R", ".py", ".yml", ".bib", ".html"}
SKIP = {"_site", "site_libs", ".venv", "node_modules", ".git", ".quarto", ".playwright-cli", ".playwright-mcp", "archive"}
DOI_RE = re.compile(r"10\.\d{4,9}/[^\s\"'<>)\]\}]+", re.I)
TRAIL = ".,;:)]}>"

def normalize(doi: str) -> str:
    return doi.strip().rstrip(TRAIL).lower()

def find_dois(text: str) -> list[str]:
    seen, out = set(), []
    for m in DOI_RE.finditer(text):
        d = normalize(m.group(0))
        if d not in seen:
            seen.add(d); out.append(d)
    return out

def walk(root: pathlib.Path):
    for p in root.rglob("*"):
        if any(part in SKIP for part in p.parts): continue
        if p.is_file() and p.suffix in EXTS: yield p

def main(out="scripts/dois.txt"):
    dois = set()
    for p in walk(COURSE):
        try: dois.update(find_dois(p.read_text(errors="ignore")))
        except OSError: pass
    pathlib.Path(out).write_text("\n".join(sorted(dois)) + "\n")
    print(f"{len(dois)} unique DOIs -> {out}")

if __name__ == "__main__":
    main(*sys.argv[1:])
```

- [ ] **Step 3: Write `scripts/fetch_bibtex.py`**

```python
#!/usr/bin/env python3
"""Turn scripts/dois.txt into refs.bib via DOI content negotiation (Crossref/DataCite), with a disk cache.
Keys are surname+year+firstword; duplicates get a/b/c suffixes."""
import pathlib, re, sys, time, unicodedata, urllib.request, urllib.error

CACHE = pathlib.Path("refs-cache")
CONTACT = "michaelalfaro@g.ucla.edu"   # public course contact; Crossref polite pool
UA = f"ecology-evolution-color-book/0.1 (mailto:{CONTACT})"
STOP = {"the", "a", "an", "of", "on", "in", "and", "to", "for", "how", "why", "what", "is", "are"}

def _field(entry: str, name: str) -> str:
    m = re.search(name + r"\s*=\s*[{\"](.*?)[}\"]\s*,?\s*\n?", entry, re.I | re.S)
    return m.group(1).strip() if m else ""

def _ascii(s: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFKD", s) if not unicodedata.combining(c))

def make_key(entry: str) -> str:
    author = _field(entry, "author")
    first = author.split(" and ")[0].strip()
    surname = first.split(",")[0] if "," in first else first.split()[-1]
    surname = re.sub(r"[^a-z]", "", _ascii(surname).lower()) or "anon"
    year = re.search(r"\b(1[89]\d\d|20\d\d)\b", _field(entry, "year")) or re.search(r"year\s*=\s*(\d{4})", entry)
    year = year.group(1) if year else "nd"
    words = [re.sub(r"[^a-z]", "", _ascii(w).lower()) for w in _field(entry, "title").split()]
    words = [w for w in words if w and w not in STOP]
    return f"{surname}{year}{words[0] if words else ''}"

def rekey(entry: str, key: str) -> str:
    return re.sub(r"^(@\w+\{)[^,]+,", lambda m: m.group(1) + key + ",", entry.strip(), count=1)

def disambiguate(keys: list[str]) -> list[str]:
    seen, out = {}, []
    for k in keys:
        n = seen.get(k, 0)
        out.append(k if n == 0 else f"{k}{chr(ord('a') + n - 1)}")
        seen[k] = n + 1
    return out

def fetch(doi: str) -> str | None:
    CACHE.mkdir(exist_ok=True)
    f = CACHE / (re.sub(r"[^A-Za-z0-9]", "_", doi) + ".bib")
    if f.exists(): return f.read_text()
    req = urllib.request.Request("https://doi.org/" + doi, headers={"Accept": "application/x-bibtex", "User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            text = r.read().decode("utf-8", errors="replace")
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError):
        return None
    if not text.lstrip().startswith("@"): return None
    f.write_text(text)
    time.sleep(0.3)
    return text

def main(dois_path="scripts/dois.txt", out="refs.bib", failed="scripts/dois-failed.txt"):
    dois = [d.strip() for d in pathlib.Path(dois_path).read_text().splitlines() if d.strip()]
    entries, bad = [], []
    for i, d in enumerate(dois, 1):
        e = fetch(d)
        (entries if e else bad).append(e if e else d)
        if i % 25 == 0: print(f"{i}/{len(dois)}", flush=True)
    keys = disambiguate([make_key(e) for e in entries])
    body = "\n\n".join(rekey(e, k) for e, k in zip(entries, keys))
    pathlib.Path(out).write_text("% Generated by scripts/fetch_bibtex.py from scripts/dois.txt. Edit keys here only if you also update citations.\n\n" + body + "\n")
    pathlib.Path(failed).write_text("\n".join(bad) + ("\n" if bad else ""))
    print(f"{len(entries)} entries -> {out}; {len(bad)} failed -> {failed}")

if __name__ == "__main__":
    main(*sys.argv[1:])
```

- [ ] **Step 4: Run the unit tests**

Run: `.venv/bin/pytest tests/test_harvest.py -v`
Expected: 7 passed.

- [ ] **Step 5: Harvest and fetch for real**

```bash
cd ~/Dropbox/git/ecology-evolution-color-book
.venv/bin/python scripts/harvest_dois.py            # expect roughly 400-450 unique DOIs
.venv/bin/python scripts/fetch_bibtex.py             # 3-6 minutes; cached under refs-cache/
wc -l scripts/dois-failed.txt; grep -c '^@' refs.bib
```
Expected: most DOIs resolve; a handful fail (typos from the course's reference audit). Failed DOIs stay listed for manual repair.

- [ ] **Step 6: Prove Typst reads the generated file**

```bash
k=$(grep -m1 -o '^@[a-z]*{[^,]*' refs.bib | sed 's/.*{//')
cat > tests/bib.typ <<EOF
#import "../lib.typ": *
#show: book.with(title: [bib], draft: true)
= Test
Cited: @$k
#bibliography("../refs.bib", style: "apa", title: none)
EOF
typst compile --font-path fonts --ignore-system-fonts tests/bib.typ tests/bib.pdf 2>&1 | head -20
```
Expected: compiles. If Typst rejects an entry (hayagriva is strict about malformed BibTeX), the error names the key; fix that entry in `refs.bib` by hand and note it at the top of the file, or drop it into `scripts/dois-failed.txt`.

- [ ] **Step 7: Commit**

```bash
git add scripts/harvest_dois.py scripts/fetch_bibtex.py scripts/dois.txt scripts/dois-failed.txt refs.bib tests/test_harvest.py
git commit -m "feat: harvest course DOIs into refs.bib with tested key generation

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01CbqBVBRvFGErUWwqAcYdEX"
```

---

### Task 7: Source-pack script (lecture → drafting input)

**Files:**
- Create: `scripts/source_pack.py`, `tests/test_source_pack.py`, `drafts/source-packs/lec01.md` (generated, committed)

**Interfaces:**
- Produces: `source_pack.strip_reveal(text: str) -> tuple[list[dict], list[str]]` returning `(slides, images)` where each slide is `{"title": str, "text": str, "notes": str}`; `source_pack.build(n: int) -> str` (the markdown pack); CLI `python scripts/source_pack.py 1`.

- [ ] **Step 1: Write the failing tests**

```python
# tests/test_source_pack.py
import sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / "scripts"))
import source_pack as sp

DECK = '''---
title: "Lecture 15 — Crypsis"
format:
  revealjs:
    theme: dark
---

## Announcements {background-color="#2c3e50"}

::: {style="font-size: 1.05em;"}
[**Office hours today**]{.gold} — 3:30 pm
:::

::: {.notes}
Quick housekeeping. Keep it short.
:::

---

<!-- BLOCK 1: recap -->

## Tuesday recap

:::: {.columns}
::: {.column width="50%"}
- [**Turing parameters**]{.teal} blend in hybrids
. . .
- second point
:::
::: {.column width="50%"}
![Tapir](images/lec-13/photos/tapir.jpg)
:::
::::

::: {.notes}
Plant the seed that this matters.
:::
'''

def test_strip_spans_keeps_inner_text():
    assert sp.strip_spans("[**Office hours**]{.gold} today") == "**Office hours** today"

def test_frontmatter_removed_and_two_slides_found():
    slides, images = sp.strip_reveal(DECK)
    assert [s["title"] for s in slides] == ["Announcements", "Tuesday recap"]

def test_slide_text_is_unwrapped_and_cleaned():
    slides, _ = sp.strip_reveal(DECK)
    t = slides[1]["text"]
    assert "- **Turing parameters** blend in hybrids" in t
    assert "- second point" in t
    assert ". . ." not in t and "{.columns}" not in t and ":::" not in t and "<!--" not in t
    assert "Tapir" not in t            # images are pulled out of the prose

def test_notes_are_attached_to_their_slide():
    slides, _ = sp.strip_reveal(DECK)
    assert slides[0]["notes"].strip() == "Quick housekeeping. Keep it short."
    assert slides[1]["notes"].strip() == "Plant the seed that this matters."

def test_images_collected_with_alt():
    _, images = sp.strip_reveal(DECK)
    assert images == ["images/lec-13/photos/tapir.jpg (Tapir)"]

def test_sa_mapping():
    assert sp.SA_FOR_LECTURE[1] == 1 and sp.SA_FOR_LECTURE[8] == 2 and sp.SA_FOR_LECTURE[12] == 3 and sp.SA_FOR_LECTURE[16] == 4
    assert 17 not in sp.SA_FOR_LECTURE
```
Run: `.venv/bin/pytest tests/test_source_pack.py -v`
Expected: FAIL with `ModuleNotFoundError: source_pack`.

- [ ] **Step 2: Write `scripts/source_pack.py`**

```python
#!/usr/bin/env python3
"""Assemble the drafting inputs for one lecture into drafts/source-packs/lecNN.md.
Sources (all read-only, from the EEB 187 course repo): lecture notes, lecture script (if any),
slide deck text + speaker notes with reveal.js markup stripped, the self-assessment review guide
that covers the lecture, the Further Explorations guide, and an image inventory."""
import pathlib, re, sys

COURSE = pathlib.Path("~/Dropbox/git/EEB187-ecology-evolution-color-2026").expanduser()
SA_FOR_LECTURE = {**{n: 1 for n in range(1, 5)}, **{n: 2 for n in range(5, 9)},
                  **{n: 3 for n in range(9, 13)}, **{n: 4 for n in range(13, 17)}}

SPAN = re.compile(r"\[([^\[\]]*?)\]\{[^}]*\}")
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*(\{[^}]*\})?\s*$")
FENCE = re.compile(r"^(:{3,})\s*(.*)$")
PAUSE = re.compile(r"^\s*\.\s\.\s\.\s*$")
IMAGE = re.compile(r"!\[([^\]]*)\]\(([^)\s]+)[^)]*\)")
COMMENT = re.compile(r"<!--.*?-->", re.S)
HR = re.compile(r"^-{3,}\s*$")

def strip_spans(s: str) -> str:
    prev = None
    while prev != s:
        prev, s = s, SPAN.sub(r"\1", s)
    return s

def _drop_frontmatter(text: str) -> str:
    if text.startswith("---"):
        end = text.find("\n---", 3)
        if end != -1: return text[end + 4:]
    return text

def strip_reveal(text: str):
    """Return (slides, images). Slides split at level-2 headings; notes divs are captured separately."""
    text = COMMENT.sub("", _drop_frontmatter(text))
    slides, images = [], []
    cur = None
    stack = []            # fence kinds, innermost last
    for raw in text.splitlines():
        line = raw.rstrip()
        m = FENCE.match(line.strip())
        if m:
            if m.group(2).strip():                          # opening fence
                kind = "notes" if ".notes" in m.group(2) else "div"
                stack.append(kind)
            elif stack:                                     # closing fence
                stack.pop()
            continue
        if PAUSE.match(line) or HR.match(line): continue
        for im in IMAGE.finditer(line):
            images.append(f"{im.group(2)} ({im.group(1)})" if im.group(1) else im.group(2))
        line = IMAGE.sub("", line)
        h = HEADING.match(line)
        if h and len(h.group(1)) == 2 and "notes" not in stack:
            cur = {"title": strip_spans(h.group(2)).strip(), "text": "", "notes": ""}
            slides.append(cur); continue
        if cur is None:
            if line.strip(): cur = {"title": "(before first slide)", "text": "", "notes": ""}; slides.append(cur)
            else: continue
        clean = strip_spans(line)
        if "notes" in stack: cur["notes"] += clean + "\n"
        elif clean.strip(): cur["text"] += clean + "\n"
    return slides, images

def _read(p: pathlib.Path) -> str:
    return p.read_text(errors="ignore") if p and p.exists() else ""

def _first(glob: str) -> pathlib.Path | None:
    hits = sorted(COURSE.glob(glob))
    return hits[0] if hits else None

def build(n: int) -> str:
    nn = f"{n:02d}"
    notes = next((p for p in sorted(COURSE.glob(f"lectures/lec-{nn}-*.qmd")) if "companion" not in p.name), None)
    companion = _first(f"lectures/lec-{nn}-companion.qmd")
    script = _first(f"lectures/slides/lec-{nn}-lecture-script.md")
    deck = _first(f"lectures/slides/lec-{nn}-slides-covered.qmd") or _first(f"lectures/slides/lec-{nn}-slides.qmd")
    fe = _first(f"further-explorations/fe-{nn}-*.qmd")
    sa = SA_FOR_LECTURE.get(n)
    guide = _first(f"self-assessments/sa-{sa:02d}-review-guide.qmd") if sa else None

    out = [f"# Source pack — Lecture {n}", "",
           "Generated by scripts/source_pack.py from the EEB 187 course repo. Inputs for drafting; do not edit by hand.", ""]
    def section(title, path, body):
        out.extend([f"## {title}", f"_Source: {path.relative_to(COURSE) if path else 'none found'}_", "", body.strip() or "(none)", ""])
    section("Lecture notes (learning objectives, outline, annotated bibliography)", notes, _drop_frontmatter(_read(notes)))
    if companion: section("Instructor companion", companion, _drop_frontmatter(_read(companion)))
    if script: section("Lecture script (word-for-word)", script, _read(script))
    slides, images = strip_reveal(_read(deck)) if deck else ([], [])
    body = []
    for s in slides:
        body.append(f"### {s['title']}")
        if s["text"].strip(): body.append(s["text"].rstrip())
        if s["notes"].strip(): body.append("> **Speaker notes:** " + s["notes"].strip().replace("\n", "\n> "))
        body.append("")
    section(f"Slides and speaker notes ({len(slides)} slides)", deck, "\n".join(body))
    section(f"Self-assessment review guide (SA-{sa})" if sa else "Self-assessment review guide", guide, _drop_frontmatter(_read(guide)))
    section("Further Explorations guide", fe, _drop_frontmatter(_read(fe)))
    section("Image inventory (figure candidates; check CREDITS.md before use)", deck, "\n".join(f"- {i}" for i in images))
    return "\n".join(out)

def main(n: str):
    n = int(n)
    dest = pathlib.Path("drafts/source-packs"); dest.mkdir(parents=True, exist_ok=True)
    p = dest / f"lec{n:02d}.md"
    p.write_text(build(n))
    print(f"wrote {p} ({len(p.read_text().split())} words)")

if __name__ == "__main__":
    main(sys.argv[1])
```

- [ ] **Step 3: Run the tests**

Run: `.venv/bin/pytest tests/test_source_pack.py -v`
Expected: 6 passed. If `test_slide_text_is_unwrapped_and_cleaned` fails on the `:::` assertion, a fence line had trailing spaces; the `FENCE.match(line.strip())` handles that, so check `HR` is not swallowing the `---` inside front matter before `_drop_frontmatter` runs.

- [ ] **Step 4: Generate the Lecture 1 pack and read it**

```bash
cd ~/Dropbox/git/ecology-evolution-color-book
.venv/bin/python scripts/source_pack.py 1
wc -w drafts/source-packs/lec01.md; grep -c '^### ' drafts/source-packs/lec01.md; grep -c 'Speaker notes' drafts/source-packs/lec01.md
```
Expected: roughly 15,000–25,000 words, dozens of slide headings, dozens of speaker-note blocks. Open the file and skim two slides: text should read as clean markdown with no `{.gold}`, no `:::`, no `. . .`.

- [ ] **Step 5: Commit**

```bash
git add scripts/source_pack.py tests/test_source_pack.py drafts/source-packs/lec01.md
git commit -m "feat: source_pack.py assembles per-lecture drafting inputs with reveal markup stripped

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01CbqBVBRvFGErUWwqAcYdEX"
```

---

### Task 8: Build script, per-chapter PDFs, site index, CI workflow

**Files:**
- Modify: `build.sh`
- Create: `scripts/make_index.py`, `.github/workflows/build.yml`

**Interfaces:**
- Consumes: `main.typ` single-chapter mode (`--input chapter=NN`) from Task 4.
- Produces: `_site/book.pdf`, `_site/chapters/chNN.pdf` for every chapter file, `_site/index.html`.

- [ ] **Step 1: Extend `build.sh`**

```bash
cat > build.sh <<'EOF'
#!/usr/bin/env bash
# Build the full book, one PDF per chapter, and an index page into _site/.
set -euo pipefail
cd "$(dirname "$0")"
T="typst compile --font-path fonts --ignore-system-fonts"
rm -rf _site && mkdir -p _site/chapters
$T main.typ _site/book.pdf
for f in chapters/*.typ; do
  n=$(basename "$f" | cut -c1-2)
  $T --input chapter="$n" main.typ "_site/chapters/ch$n.pdf"
done
python3 scripts/make_index.py _site
echo "built: $(ls _site/chapters | wc -l | tr -d ' ') chapters + book.pdf"
EOF
```

- [ ] **Step 2: Write the index generator**

```python
#!/usr/bin/env python3
"""Write _site/index.html listing book.pdf and every chapter PDF with its title (from chapters/NN-*.typ)."""
import pathlib, re, sys, datetime

site = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "_site")
titles = {}
for f in sorted(pathlib.Path("chapters").glob("*.typ")):
    n = f.name[:2]
    m = re.search(r"^= (.+)$|\[(Epilogue[^\]]*)\]", f.read_text(), re.M)
    titles[n] = (m.group(1) or m.group(2)).strip() if m else f.stem
rows = "\n".join(f'<li><a href="chapters/ch{n}.pdf">{"Chapter " + str(int(n)) if int(n) <= 23 else ""} {t}</a></li>' for n, t in titles.items())
html = f"""<!doctype html><meta charset="utf-8"><title>The Ecology and Evolution of Color — drafts</title>
<style>body{{font:16px/1.5 Georgia,serif;max-width:40rem;margin:3rem auto;padding:0 1rem;color:#1b1f24}}a{{color:#2457B0}}li{{margin:.25rem 0}}</style>
<h1>The Ecology and Evolution of Color</h1><p><em>From Photons to Phylogenies</em> — Michael E. Alfaro, UCLA. Draft chapters, updated {datetime.date.today():%B %d, %Y}. Not for redistribution.</p>
<p><a href="book.pdf"><strong>Full draft (PDF)</strong></a></p><ol style="list-style:none;padding:0">{rows}</ol>"""
(site / "index.html").write_text(html)
print("wrote", site / "index.html")
```

- [ ] **Step 3: Run the build locally**

Run: `./build.sh && ls _site _site/chapters | head -30 && grep -c '<li>' _site/index.html`
Expected: `book.pdf`, 24 chapter PDFs, `index.html` with 24 list items.

- [ ] **Step 4: Write the workflow**

```yaml
# .github/workflows/build.yml
name: build
on:
  push:
    branches: [main]
  workflow_dispatch:
permissions:
  contents: read
  pages: write
  id-token: write
concurrency:
  group: pages
  cancel-in-progress: true
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: typst-community/setup-typst@v5
        with:
          typst-version: "0.15.1"
      - run: sudo apt-get update && sudo apt-get install -y poppler-utils
      - run: tests/check_fonts.sh && tests/check_smoke.sh && tests/check_main.sh
      - run: ./build.sh
      - uses: actions/upload-pages-artifact@v3
        with:
          path: _site
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 5: Commit**

```bash
git add build.sh scripts/make_index.py .github/workflows/build.yml
git commit -m "feat: build.sh with per-chapter PDFs and index; GitHub Pages workflow

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01CbqBVBRvFGErUWwqAcYdEX"
```

---

### Task 9: README, GitHub repository, first deploy

**Files:**
- Modify: `README.md`

**Interfaces:**
- Produces: public repository `michaelalfaro/ecology-evolution-color-book`, Pages site serving `_site/`.

- [ ] **Step 1: Finish the README**

Append to `README.md`:

```markdown
## Adding a chapter's draft

1. `.venv/bin/python scripts/source_pack.py 7` writes `drafts/source-packs/lec07.md` (notes, script, slides + speaker notes, review guide, Further Explorations, image inventory).
2. Write prose into `chapters/07-building-a-color-percept.typ`. Every chapter uses the same skeleton: `= Title`, `#in-this-chapter(...)`, `#epigraph(...)`, sections with question titles, boxes (`#physics`, `#casestudy`, `#tryit`, `#keyconcept`, `#caveat`), then `#key-ideas(...)`, `#open-questions(...)`, `#going-further(...)`.
3. Cite with `@key`; keys are in `refs.bib`. Missing paper? Add its DOI to `scripts/dois.txt`, run `scripts/fetch_bibtex.py`.
4. `typst watch --font-path fonts --ignore-system-fonts --input chapter=07 main.typ ch07.pdf` while writing.
5. Commit and push; CI publishes `chapters/ch07.pdf` and the full book.

## Adding a figure

- Generated: write an R script under `R/`, `source("R/theme_book.R"); register_book_fonts()`, build a ggplot with `theme_book()`, `save_fig(p, "name", chapter = 7)`. Place with `#fig("../figures/ch07/name.svg", [Caption.], credit: [Figure: M. Alfaro]) <fig-name>`.
- Photograph: put a JPEG sized for print (about 1,900 px wide for full text width) in `figures/chNN/` and always pass `credit:` (photographer, license). Wikimedia credits for course images live in the course repo's `lectures/images/lec-NN/CREDITS.md`.
- Small: `#margin-fig(...)` puts it in the outer column.

## Weekly rhythm (Fall 2026)

Monday: source pack for the week's lectures. Tuesday–Thursday: draft and edit. Friday: push; the chapter PDF is live on the Pages site and linked from BruinLearn.

## Tests

    .venv/bin/pytest                      # Python tooling
    tests/check_fonts.sh && tests/check_smoke.sh && tests/check_main.sh && tests/check_figure.sh
```

- [ ] **Step 2: Create the GitHub repository and push**

```bash
cd ~/Dropbox/git/ecology-evolution-color-book
git add README.md && git commit -m "docs: README with chapter, figure, and weekly workflow

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01CbqBVBRvFGErUWwqAcYdEX"
gh repo create michaelalfaro/ecology-evolution-color-book --public --source=. --remote=origin \
  --description "The Ecology and Evolution of Color: From Photons to Phylogenies — draft textbook (Typst)" --push
gh api -X POST repos/michaelalfaro/ecology-evolution-color-book/pages -f build_type=workflow
```
Expected: repository URL printed; Pages source set to GitHub Actions.

- [ ] **Step 3: Trigger and watch a run (the push-triggered run may have started before Pages was enabled)**

```bash
gh workflow run build.yml && sleep 10
gh run watch --exit-status $(gh run list --workflow=build.yml --limit 1 --json databaseId -q '.[0].databaseId')
gh api repos/michaelalfaro/ecology-evolution-color-book/pages -q .html_url
```
Expected: run succeeds; the printed URL serves `index.html` with links to `book.pdf` and 24 chapter PDFs. If `check_smoke.sh` fails only in CI, the usual cause is a font not vendored (the `--ignore-system-fonts` flag hides a locally installed font); add the file to `fonts/`.

- [ ] **Step 4: Record the URL**

Add the Pages URL to the top of `README.md` under the title, commit, push.

---

## Self-review

**Spec coverage.** Section 5 of the spec (production stack): template and design tokens (Task 3), fonts (Task 2), page geometry (Task 3, global constraints), figure pipeline (Task 5), build and CI (Tasks 8–9), publisher hand-off is not part of the scaffold. Section 6 Phase 0: repo, skeleton, five boxes, figure/credit wrapper, chapter template, `theme_book()`, CI (Tasks 1–5, 8–9), bibliography harvest (Task 6), source-pack script (Task 7). Chapter 1 drafting is deliberately a separate plan: it is writing, not scaffolding, and needs the source pack this plan produces. Not in this plan, by decision: `glossarium`, `in-dexter`, `subpar`, `mannot`, `codly` — add the package when a chapter first needs it.

**Placeholders.** None; every code step is complete. Chapter stub files say "not yet written" as content, which is the truth of the artifact, not a plan placeholder.

**Type consistency.** `fig(path, caption, credit:, width:)` is used identically in Tasks 3, 5, 9. `part(title, gloss:)` in Tasks 3 and 4. `--input chapter=NN` two-digit strings in Tasks 4, 8, 9. `save_fig(plot, name, chapter)` in Tasks 5 and 9. `SA_FOR_LECTURE` covers lectures 1–16 in Tasks 7's code and tests.

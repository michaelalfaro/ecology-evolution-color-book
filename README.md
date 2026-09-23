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



## Adding a chapter's draft

1. `.venv/bin/python scripts/source_pack.py 7` writes `drafts/source-packs/lec07.md` (notes, script, slides + speaker notes, review guide, Further Explorations, image inventory).
2. Write prose into `chapters/07-building-a-color-percept.typ`. Every chapter uses the same skeleton: `= Title`, `#in-this-chapter(...)`, `#epigraph(...)`, sections with question titles, boxes (`#physics`, `#casestudy`, `#tryit`, `#keyconcept`, `#caveat`), then `#key-ideas(...)`, `#open-questions(...)`, `#going-further(...)`.
3. Cite with `@key`; keys are in `refs.bib`. Missing paper? Add its DOI to `scripts/dois.txt`, run `scripts/fetch_bibtex.py`.
4. `typst watch --font-path fonts --ignore-system-fonts --input chapter=07 main.typ ch07.pdf` while writing.
5. Commit and push; CI publishes `chapters/ch07.pdf` and the full book.

## Adding a figure

- Generated: write an R script under `R/`, `source("R/theme_book.R"); register_book_fonts()`, build a ggplot with `theme_book()`, `save_fig(p, "name", chapter = 7)`. Place with `#fig("figures/ch07/name.svg", [Caption.], credit: [Figure: M. Alfaro]) <fig-name>`. Image paths are relative to the repository root.
- Photograph: put a JPEG sized for print (about 1,900 px wide for full text width) in `figures/chNN/` and always pass `credit:` (photographer, license). Wikimedia credits for course images live in the course repo's `lectures/images/lec-NN/CREDITS.md`.
- Small: `#margin-fig(...)` puts it in the outer column.

## Weekly rhythm (Fall 2026)

Monday: source pack for the week's lectures. Tuesday–Thursday: draft and edit. Friday: push; the chapter PDF is live on the Pages site and linked from BruinLearn.

## Tests

    .venv/bin/pytest                      # Python tooling
    tests/check_fonts.sh && tests/check_smoke.sh && tests/check_main.sh && tests/check_figure.sh

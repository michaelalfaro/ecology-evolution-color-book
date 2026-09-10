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

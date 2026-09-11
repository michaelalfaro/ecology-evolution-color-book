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
#fig("figures/ch02/blackbody.svg", [Blackbody spectra at three temperatures.], credit: [Figure: M. Alfaro]) <fig-bb>
See @fig-bb.
T
typst compile --root . --font-path fonts --ignore-system-fonts tests/fig.typ tests/fig.pdf 2>&1 | tee tests/fig.log
grep -q 'unknown font' tests/fig.log && { echo "Typst could not resolve the SVG font"; exit 1; }
pdftotext tests/fig.pdf - 2>/dev/null | grep -q "Figure 1.1" && echo "figure OK"

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

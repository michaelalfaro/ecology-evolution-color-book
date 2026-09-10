#!/usr/bin/env bash
# Build the full book PDF. Extended in Task 8 with per-chapter PDFs and index.html.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p _site
typst compile --font-path fonts --ignore-system-fonts main.typ _site/book.pdf
echo "built _site/book.pdf"

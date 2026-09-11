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
[ "$(pdfinfo tests/ch05.pdf 2>/dev/null | awk '/^Pages/ {print $2}')" -lt 8 ] || { echo "single-chapter build too long"; exit 1; }
echo "main OK"

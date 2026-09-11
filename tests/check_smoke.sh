#!/usr/bin/env bash
# Compile tests/smoke.typ and assert the design apparatus rendered.
set -euo pipefail
cd "$(dirname "$0")/.."
typst compile --root . --font-path fonts --ignore-system-fonts tests/smoke.typ tests/smoke.pdf
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

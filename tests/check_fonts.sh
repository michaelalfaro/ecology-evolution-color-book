#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
out=$(typst fonts --font-path fonts --ignore-system-fonts)
for f in "Libertinus Serif" "Libertinus Math" "Source Sans 3" "JetBrains Mono"; do
  echo "$out" | grep -qx "$f" || { echo "MISSING: $f"; exit 1; }
done
echo "fonts OK"

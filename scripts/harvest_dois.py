#!/usr/bin/env python3
"""Harvest every DOI mentioned in the EEB 187 course repo into scripts/dois.txt (one per line, sorted, unique).
Read-only with respect to the course repo."""
import pathlib, re, sys

COURSE = pathlib.Path("~/Dropbox/git/EEB187-ecology-evolution-color-2026").expanduser()
EXTS = {".qmd", ".md", ".txt", ".R", ".py", ".yml", ".bib", ".html"}
SKIP = {"_site", "site_libs", ".venv", "node_modules", ".git", ".quarto", ".playwright-cli", ".playwright-mcp", "archive"}
DOI_RE = re.compile(r"10\.\d{4,9}/[^\s\"'<>\]\}`]+", re.I)   # parentheses allowed: old Elsevier DOIs contain them
TRAIL = ".,;:]}>`"

def normalize(doi: str) -> str:
    """Lower-case; strip trailing punctuation, backticks, literal \\n, and any unbalanced closing parens."""
    d = re.sub(r"(\\n)+$", "", doi.strip()).rstrip(TRAIL)
    while d.count(")") > d.count("(") and d.endswith(")"):
        d = d[:-1].rstrip(TRAIL)
    return d.lower()

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

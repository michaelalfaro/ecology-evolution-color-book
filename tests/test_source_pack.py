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

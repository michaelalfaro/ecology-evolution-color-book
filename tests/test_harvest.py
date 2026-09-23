import sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / "scripts"))
import harvest_dois as h
import fetch_bibtex as f

def test_find_dois_extracts_and_dedupes():
    text = "Cuthill (doi:10.1126/science.aan0221). See https://doi.org/10.1126/science.aan0221, and 10.1111/brv.12500."
    assert h.find_dois(text) == ["10.1126/science.aan0221", "10.1111/brv.12500"]

def test_normalize_strips_trailing_punctuation_and_lowercases():
    assert h.normalize("10.1098/RSPB.1998.0302).") == "10.1098/rspb.1998.0302"
    assert h.normalize("10.1016/j.tree.2018.03.001,") == "10.1016/j.tree.2018.03.001"

def test_find_dois_ignores_markdown_link_tail():
    assert h.find_dois("[paper](https://doi.org/10.1038/nature03312)") == ["10.1038/nature03312"]

ENTRY = """@article{Cuthill_2017, title={The biology of color}, volume={357}, DOI={10.1126/science.aan0221},
 number={6350}, journal={Science}, author={Cuthill, Innes C. and Allen, William L.}, year={2017}, pages={eaan0221} }"""

def test_make_key_is_surname_year_firstword():
    assert f.make_key(ENTRY) == "cuthill2017biology"

def test_make_key_handles_first_last_order_and_diacritics():
    e = ENTRY.replace("author={Cuthill, Innes C. and Allen, William L.}", "author={Mäthger, Lydia M. and Hanlon, Roger}")
    assert f.make_key(e) == "mathger2017biology"

def test_rekey_replaces_only_the_key():
    out = f.rekey(ENTRY, "cuthill2017biology")
    assert out.startswith("@article{cuthill2017biology,")
    assert "DOI={10.1126/science.aan0221}" in out

def test_disambiguate_appends_letters():
    assert f.disambiguate(["a2017x", "a2017x", "b2018y", "a2017x"]) == ["a2017x", "a2017xa", "b2018y", "a2017xb"]


def test_is_usable_rejects_unbalanced_or_metadata_free_entries():
    assert f.is_usable(ENTRY)
    assert not f.is_usable("@misc{, url={1, DOI={10.1371/journal.pbio.0050219.g001}, publisher={PLoS} }")
    assert not f.is_usable("@misc{x2020, title={Only a title}, year={2020}}")


def test_normalize_keeps_balanced_parens_and_strips_junk():
    assert h.normalize("10.1016/0022-5193(75)90190-5).") == "10.1016/0022-5193(75)90190-5"
    assert h.find_dois("see 10.1016/s0003-3472(05)80147-9)") == ["10.1016/s0003-3472(05)80147-9"]
    assert h.normalize("10.1038/nature12373`") == "10.1038/nature12373"
    assert h.normalize("10.1093/icb/icz119\\n") == "10.1093/icb/icz119"

def test_sanitize_braces_month_abbreviation():
    assert f.sanitize("@article{k, year={2023}, month=Sept }") == "@article{k, year={2023}, month={Sept} }"
    assert f.sanitize("@article{k, month={Jan} }") == "@article{k, month={Jan} }"

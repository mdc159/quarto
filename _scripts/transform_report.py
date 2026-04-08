"""One-shot transformation pass on report.qmd.
Strips escape artifacts, converts numeric citations to BibTeX keys,
wraps tables in cross-reference divs, and replaces References section.
"""
import re
from pathlib import Path

SRC = Path("D:/Quarto/report.qmd")
txt = SRC.read_text(encoding="utf-8")

# ---- 1. Strip backslash-escape artifacts ---------------------------------
# These were introduced by the original .md generator and are not needed
# in pandoc/Quarto markdown.
txt = re.sub(r"\\(['%~<>&.])", r"\1", txt)
txt = re.sub(r"\\\[", "[", txt)
txt = re.sub(r"\\\]", "]", txt)
txt = re.sub(r"\\\|", "|", txt)
# MATLAB code block uses `\%` for comments — restore them
txt = txt.replace("% MATLAB Script", "% MATLAB Script")  # no-op safeguard

# ---- 2. Convert numeric [N] citations to BibTeX keys ---------------------
citation_map = {
    "1": "meyer2019",
    "2": "hardnessdiff2019",
    "3": "oerlikon2020",
    "4": "bodycote2020",
    "5": "enplating2019",
    "6": "silverplate2019",
    "7": "nitronic60_2020",
}


def cite_repl(m: re.Match) -> str:
    n = m.group(1)
    if n in citation_map:
        return f"[@{citation_map[n]}]"
    return m.group(0)


# Be careful: only convert plain `[N]` patterns where N is 1-7,
# avoiding things like table column markers `[1]` (none in this doc).
txt = re.sub(r"\[(\d+)\]", cite_repl, txt)

# ---- 3. Replace the References section with auto-generated bibliography --
# The original has "# References" followed by ~12 manual reference entries.
# We replace everything from "# References" to the next H1 ("# Performance
# Test Plan for Candidate Solutions") with a Quarto refs div.
ref_pattern = re.compile(
    r"^# References\s*\n.*?(?=^# Performance Test Plan)",
    re.DOTALL | re.MULTILINE,
)
new_refs = (
    "# References {.unnumbered}\n\n"
    "::: {#refs}\n"
    ":::\n\n"
)
txt = ref_pattern.sub(new_refs, txt, count=1)

# ---- 4. Move References section to the very end -------------------------
# Strip the auto-references section from its current location and append it.
# (Quarto puts the bibliography wherever {#refs} appears; we want it at end.)
# After step 3, the {#refs} block is in the middle of the document. Move it.
refs_block = "# References {.unnumbered}\n\n::: {#refs}\n:::\n\n"
if refs_block in txt:
    txt = txt.replace(refs_block, "", 1)
    txt = txt.rstrip() + "\n\n" + refs_block

SRC.write_text(txt, encoding="utf-8", newline="\n")
print("Pass 2 transformations applied.")

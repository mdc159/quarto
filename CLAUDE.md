# D:\Quarto — Publishing Workspace Instructions

This is a Quarto-based publishing **workspace** for opto-mechanical
engineering research reports, test plans, trade studies, and other
technical documents. Each document set lives in its own subfolder under
`projects/`. Shared resources (bibliography, brand assets, agents,
templates, scripts, venv) live at the workspace level.

The goal is to convert AI-generated markdown drafts into reproducible,
multi-format Quarto documents (HTML + PDF) with executable Python (and
eventually MATLAB via the matlab-mcp server) cells producing real figures.

## Workspace Layout

```
D:\Quarto\
├── CLAUDE.md                     (this file — workspace instructions)
├── .gitignore
├── .git/
│
├── .claude/
│   └── agents/                   workspace-local agents (research-publisher, etc.)
│
├── _shared/                      shared across ALL projects in this workspace
│   ├── _metadata.yml             shared Quarto YAML (formats, LaTeX preamble, exec)
│   ├── refs.bib                  master BibTeX bibliography
│   ├── ieee.csl                  IEEE citation style
│   ├── _brand.yml                (future) group visual identity
│   ├── templates/                (future) document type templates
│   └── prompts/                  (future) worker brief templates
│
├── _scripts/                     transformation script library (reusable)
│   ├── transform_*.py
│   ├── clean_parts_tables.py
│   └── make_fixture_schematic.py
│
├── _state/                       orchestrator state (per-project subdirs)
│   └── <project>/
│       ├── manifest.yml
│       ├── claims.yml
│       └── briefs/
│
├── _scratch/                     throwaway: prompt files, intermediate logs
│
├── .venv/                        workspace-shared Python venv (uv-managed)
│
└── projects/
    └── galling-mitigation/       FIRST PROJECT (current)
        ├── _quarto.yml           project config (inherits ../../_shared/_metadata.yml)
        ├── report.qmd
        ├── test-plan.qmd
        ├── refs.bib              (optional) project-specific cite additions
        ├── figures/
        │   └── fixture-schematic.png
        ├── source/               original AI-generated source files (preserved)
        │   ├── report.R2.md
        │   └── test_plan.R2.md
        ├── _freeze/              Quarto cell-output cache (committed)
        └── _output/              rendered HTML + PDF (gitignored, regenerable)
```

## Adding a New Project

```bash
# From the workspace root:
mkdir -p projects/<new-project>/source
cp <wherever>/draft.md projects/<new-project>/source/

# Create projects/<new-project>/_quarto.yml mirroring the galling-mitigation one
# Then invoke the research-publisher agent (when it exists):
#   "Use research-publisher to convert projects/<new-project>/source/draft.md"
```

## Render Workflow

```bash
# From the project directory (NOT the workspace root):
cd D:/Quarto/projects/galling-mitigation
export QUARTO_PYTHON=/d/Quarto/.venv/Scripts/python.exe
quarto render                            # both formats, both documents
quarto render report.qmd --to html       # one document, one format
```

`QUARTO_PYTHON` MUST point at the project venv. Never let Quarto fall
back to system Python (see global memory for the rule). The `_freeze/`
cache means re-renders are fast unless code cells change.

## Content & Voice

Apply Mike's preferred technical writing style (active voice, impersonal
tone, present tense) — see global memory file
`~/.claude/memory/technical-writing-style.md` for the full rules.

The current report.qmd and test-plan.qmd contain prose that was inherited
from the AI-generated `.R2.md` source, which uses the OLD verbose style
("We first analyze...", "The objective of this report is to..."). When
Mike asks for content edits or new prose, apply the preferred style. A
full copy-edit pass on existing content has not been done yet.

## Quarto Skills — Use Them Proactively

Three Quarto skills are installed via the `posit-dev-skills` plugin:

- **`quarto:quarto-authoring`** — Index file with references for
  cross-refs, code-cells, citations, tables, figures, callouts, layout,
  YAML, etc. Re-invoke whenever stuck on a Quarto-specific question.
- **`quarto:quarto-alt-text`** — Use this for EVERY figure cell to
  generate rigorous accessibility alt text. Do not write `fig-alt`
  inline by hand if the skill applies.
- **`quarto:brand-yml`** — Use to set up `_brand.yml` for consistent
  visual identity (colors, fonts, logos). Not yet used in this project.

## Quarto Conventions Learned the Hard Way

These are operational rules that came out of past mistakes. Apply them
as defaults; the reasoning is documented so future me can override them
intelligently.

### Single-image figures: use plain image syntax, NOT a div wrapper

Wrong (causes nested `\begin{figure}` LaTeX error):
```markdown
::: {#fig-fixture}
![Caption inside](image.png){fig-alt="..."}

Caption text.
:::
```

Right:
```markdown
![Caption text.](image.png){#fig-fixture fig-alt="..."}
```

The div wrapper is only for multi-image (subfigure) layouts or
non-image content (iframes, raw HTML, custom widgets). For a single
image with one caption, use the inline form. See
`references/figures.md` in the quarto-authoring skill.

### Tables: always set `tbl-colwidths` for any table that may be wide

Quarto's default LaTeX longtable allocates equal-width columns, which
makes wide content overflow and look broken. ALWAYS specify column
percentages on cross-referenced tables that have any chance of being
wide:

```markdown
::: {#tbl-traceability tbl-colwidths="[8,25,22,27,18]"}

| Claim-ID | Fixture Feature | Data Collected | Method | Pass/Fail |
| ...
```

Percentages should sum to ~100. Narrow ID columns get 7-10%; wide
description / method columns get 25-35%. The widths apply to BOTH PDF
(via `xltabular`) and HTML (via CSS), so set them once and they work
everywhere. See `references/tables.md` in the quarto-authoring skill.

### LaTeX preamble for technical reports

The PDF format in `_quarto.yml` includes a curated preamble for table
handling. Key entries:

- `fontsize: 10pt` and `margin=0.85in` to give wide content room
- `xltabular` package + `\keepXColumns` for tabularx-aware longtables
- `\AtBeginEnvironment{longtable}{\footnotesize}` so all longtables
  shrink automatically
- `xurl` package for URL line-breaking inside cells
- `tbl-cap-location: top` so captions appear above tables

If table formatting still breaks after these defaults, the next moves
are: explicit `tbl-colwidths`, landscape rotation for one section, or
splitting the table into smaller pipe tables.

### Cite keys come from `refs.bib` — always check before adding new ones

The shared bibliography has the canonical keys. Common ones:

- `meyer2019` — Meyer Tool vacuum fasteners article
- `bodycote2020` — Kolsterising data sheet
- `nitronic60_2020` — AK Steel Nitronic 60 bulletin
- `astm_g98`, `astm_e595`, `astm_g133`, `astm_g99`, `astm_g195`, `astm_g196`
- `iso_14644`, `iso_16047`
- `bhushan2000`, `rabinowicz1995`, `johnson1985`, `roberts2012`
- `nasa_outgassing`, `cda_phosbronze`

Add new entries to `refs.bib` rather than introducing new keys ad-hoc.

### Section IDs (`{#sec-xxx}`) on report.qmd are partial

`test-plan.qmd` has section IDs throughout. `report.qmd` does not yet —
only the section headings I touched during conversion got IDs. Adding
the rest is a Pass 4 task whenever cross-section references are needed.

## Code Cells

### Python cells use the project venv

All `{python}` cells run via `QUARTO_PYTHON` pointing at
`.venv/Scripts/python.exe`. Available packages: `jupyter`, `numpy`,
`matplotlib`, `pandas`. Add more with
`uv pip install --python .venv/Scripts/python.exe <pkg>`.

### MATLAB cells are display-only for now

MATLAB code blocks use ``` ```{.matlab filename="..."} ``` (display only,
fenced literal). They are NOT executed at render time. The plan is to
hook these into the matlab-mcp server (at `D:\matlab-mcp`) so MATLAB
cells can execute and return figures the same way Python cells do.
Until that integration exists:

- Keep MATLAB code as a display-only `{.matlab}` block
- Add an executable `{python}` cell beside it that produces the same
  figure (numpy/matplotlib equivalent)
- This gives the user a working rendered figure NOW and preserves the
  MATLAB source for the future MCP integration

The `_scripts/transform_matlab_block.py` script demonstrates this
pattern for the friction simulation in `report.qmd`.

## Transformation Script Library

`_scripts/` contains reusable Python scripts that handle common
.R2.md → .qmd transformations. They are one-shot but well-suited as a
starter library for the eventual `research-publisher` agent:

| Script | Purpose |
|---|---|
| `transform_report.py` | Strip backslash escapes, convert numeric `[1]` citations to `[@key]`, replace References section with auto-generated `::: {#refs} :::` div |
| `transform_matlab_block.py` | Replace AI-mangled MATLAB code blocks with executable Python + display-only MATLAB reference block |
| `transform_report_pass3.py` | Wrap pipe tables in cross-reference divs, convert key paragraphs to callout blocks |
| `clean_parts_tables.py` | Strip URL clutter from Markdown links, convert URL-laden grid tables to clean pipe tables |
| `make_fixture_schematic.py` | Generate placeholder PNG diagrams via matplotlib when no real CAD/diagram exists yet |

When converting a new `.R2.md` source, run them in order:
`transform_report.py` → `transform_matlab_block.py` → `clean_parts_tables.py`
→ `transform_report_pass3.py`. Each script is idempotent and reads/writes
the same target file.

## Outstanding Work (Pass 4 ideas)

These are imperfections noted but deferred:

1. Copy-edit the prose in `report.qmd` and `test-plan.qmd` to apply the
   preferred technical writing style globally (not just on new content).
2. Add `{#sec-xxx}` IDs to all remaining section headings in
   `report.qmd`.
3. Replace the matplotlib-generated `figures/fixture-schematic.png`
   placeholder with a real CAD diagram.
4. Wire up matlab-mcp execution so the MATLAB script in
   `@sec-matlab-reference` runs at render time alongside the Python
   equivalent.
5. Set up `_brand.yml` via the `quarto:brand-yml` skill for consistent
   group visual identity.
6. Build the specialized `research-publisher` agent that orchestrates
   the transformation scripts + Quarto skills + matlab-mcp.

## Reflections on Skill Usage (lessons for the future agent)

I (Claude) used `quarto:quarto-authoring` ONCE during the initial
conversion and read several reference files directly. I never invoked
`quarto:quarto-alt-text` or `quarto:brand-yml` even though both apply.
The two biggest mistakes that the skill would have caught earlier:

1. Used a div wrapper for a single-image figure → caused nested
   `\begin{figure}` LaTeX error. The skill's `figures.md` reference
   says single images should use plain markdown image syntax.
2. Did not set `tbl-colwidths` until the user complained about column
   formatting. The skill's `tables.md` reference documents this
   prominently.

The future `research-publisher` agent should be designed to invoke
these skills at appropriate workflow points, not just be aware of them.
Specifically:

- At project init: invoke `brand-yml` first
- Per figure: invoke `quarto-alt-text` after generating each cell
- Per table: default to setting `tbl-colwidths` proactively
- At LaTeX render error: look up the relevant reference file before
  guessing

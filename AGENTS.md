# Quarto Workspace Agent Guide

`AGENTS.md` is the primary Codex-facing operations guide for this repo.
Use `CLAUDE.md` as background and historical rationale when this file does
not answer a repo-specific question.

## Purpose

This repo is a Quarto-based publishing workspace for technical documents:
engineering reports, test plans, trade studies, and companion analysis
documents. Each document set lives under `projects/`. Shared metadata,
bibliography, scripts, and state live at the workspace root.

Treat the repo as a document-production system, not a generic software
project. Most work falls into the docs-core loop:

1. preserve raw drafts in `projects/<project>/source/`
2. convert or clean the working `.qmd`
3. author figures, tables, citations, and cross-references
4. render and debug Quarto output
5. perform a technical-writing and evidence review
6. leave a structured handoff for the next session when needed

Use an exploratory notebook under `output/jupyter-notebook/` when a project
needs quick analysis, parameter sweeps, or visual sanity checks before the
results are folded back into a `.qmd`. Treat notebooks as analysis aids, not
as the final publishing surface for reports.

## Repo Layout

- `projects/` - project-specific Quarto documents and figures
- `_shared/` - shared Quarto metadata, bibliography, CSL, and future brand assets
- `_scripts/` - reusable but currently one-off transformation helpers
- `_state/` - structured project state, manifests, and handoff support
- `output/jupyter-notebook/` - exploratory notebooks and rendered notebook HTML
- `.venv/` - workspace Python environment for Quarto/Jupyter execution
- `skills/` - upstream/reference Posit skill library vendored into this repo
- `.codex/skills/` - repo-local Codex skills tailored to this workspace

Important projects currently present:

- `projects/galling-mitigation/`
- `projects/shipping/`

## Default Workflow

### Authoring and conversion

- Start from the project directory, not the workspace root.
- Preserve the original source draft in `source/`.
- Treat the root `.qmd` as the working document.
- Reuse sibling project patterns before inventing a new structure.

### Rendering

- Use `D:\Quarto\.venv\Scripts\python.exe` for Quarto execution.
- Do not allow Quarto to fall back to system Python.
- Render from the project directory with the Quarto CLI at:
  `C:\Program Files\Quarto\bin\quarto.exe`

Typical render loop:

```powershell
Set-Location D:\Quarto\projects\<project>
$env:QUARTO_PYTHON='D:\Quarto\.venv\Scripts\python.exe'
& 'C:\Program Files\Quarto\bin\quarto.exe' render
```

### Review

- Review for factual support, cross-reference correctness, render safety,
  accessibility, and technical-writing quality before finalizing.
- Use active voice, impersonal tone, and present tense unless the project
  clearly requires something else.

## Hard Rules

- Keep engineering computation in its real source of truth. If a project
  depends on `D:\matlab-mcp`, prefer generated outputs from there over
  rebuilding the analysis logic locally unless the user explicitly wants a
  local reimplementation.
- When using notebooks, prefer importing repo code or reading generated
  artifacts directly instead of duplicating the model logic inside the
  notebook.
- Preserve `source/` inputs. Do not overwrite them during conversion.
- Treat `_scripts/transform_*.py` as workflow helpers, not generic safe
  tools. Several are still hard-coded to older paths and must be inspected
  or adapted before use.
- `_output/` is regenerable and ignored. `_freeze/` is intended to remain
  committed when present.
- Add section IDs when a section may be referenced later.
- Check bibliography keys before adding new citations. Prefer
  `_shared/refs.bib` unless the project already maintains its own `refs.bib`.
- Prefer `Eq. @eq-id`, `Table @tbl-id`, and `Figure @fig-id` over the
  parenthesized `(@eq-id)` style so Quarto documents remain friendly to the
  visual editor.
- Do not leave a bare cross-reference like `@eq-id` or `@fig-id` at the
  start of an indented continuation line inside a list item or callout.
  Pandoc can misparse that as an example list, which breaks the visual editor.

## Quarto Conventions

### Figures

- Use plain image syntax for single images:
  `![Caption](image.png){#fig-id fig-alt="..."}`
- Use fenced div wrappers only for grouped figures, subfigures, or
  non-image content.
- Add `fig-alt` for substantive figures.
- If figures live outside the project tree, add a `resource-path` entry in
  the project `_quarto.yml` for rendering.
- For documents that need reliable Quarto live preview, keep referenced image
  assets under the project tree, typically in a local `generated/` folder, and
  include that folder under `project.resources` so preview serves them.

### Tables

- Add `tbl-colwidths` proactively for any table that could be wide in PDF.
- Prefer cross-referenced table divs when the table is discussed in prose.
- Split or restructure a table before accepting unreadable PDF output.

### Metadata and references

- Reuse shared metadata from `_shared/_metadata.yml` unless the project has
  a strong reason to diverge.
- Keep citations and CSL paths stable and repo-relative.

## Local Skills

Use the repo-local skills in `.codex/skills/` as the first stop for
workflow guidance. Use the vendored Posit skills in `skills/` as upstream
reference material.

Primary local skills:

- `.codex/skills/quarto-workspace-authoring/`
- `.codex/skills/quarto-source-conversion/`
- `.codex/skills/quarto-render-debug/`
- `.codex/skills/quarto-alt-text-pass/`
- `.codex/skills/technical-doc-review/`
- `.codex/skills/quarto-handoff-and-manifest/`
- `.codex/skills/quarto-brand-setup/`
- `.codex/skills/quarto-analysis-notebook/`

Use the upstream/reference tree when a local skill tells you to load
specific reference files under `skills/`.

## State and Handoffs

When work spans multiple sessions or documents:

- keep structured status in `_state/<project>/manifest.yml`
- keep narrative next-step context in `SESSION_HANDOFF.md` when useful

A good handoff records:

- mission and non-goals
- primary working file
- external computational source of truth
- current technical conclusions
- immediate next steps
- exact render or analysis commands

For multi-document efforts, keep the problem statement separate from the
design response unless the project explicitly combines them.

## External Dependencies

- Quarto CLI: `C:\Program Files\Quarto\bin\quarto.exe`
- Workspace Python: `D:\Quarto\.venv\Scripts\python.exe`
- MATLAB analysis repo when referenced by a project: `D:\matlab-mcp`

If a task depends on one of these external paths, record that dependency in
the handoff or manifest rather than assuming it will be rediscovered later.

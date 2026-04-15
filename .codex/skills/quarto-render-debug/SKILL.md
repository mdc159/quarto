---
name: quarto-render-debug
description: >
  Render and debug Quarto documents in this D:\Quarto workspace. Use when a
  user asks to render a project, diagnose Pandoc or LaTeX failures, fix
  broken figure or table output, check resource paths, or confirm that Quarto
  is using the workspace Python environment instead of system Python.
---

# Quarto Render Debug

Read `../../../AGENTS.md` first.

## Render loop

1. Change to the project directory.
2. Set `QUARTO_PYTHON` to `D:\Quarto\.venv\Scripts\python.exe`.
3. Render with `C:\Program Files\Quarto\bin\quarto.exe`.
4. Read the first real failure, fix that class of problem, and re-render.

## Check these files first

- project `_quarto.yml`
- shared metadata in `../../../_shared/_metadata.yml`
- project `.qmd` file being rendered
- any external artifact directories referenced through `resource-path`

## Common failure classes in this workspace

### Figure syntax and layout

- Nested figure environments from wrapping a single image in a fenced div
- Missing `fig-alt` or broken grouped-figure layout
- Missing external figure resources that should have been exposed through
  `resource-path`

### Tables

- Wide tables without `tbl-colwidths`
- PDF overflow from equal-width default longtable behavior
- Tables that need splitting or restructuring instead of brute-force styling

### Execution and environment

- Quarto falling back to system Python instead of the workspace `.venv`
- Missing Python packages in `.venv`
- Stale assumptions about external generated artifacts

### Citations and metadata

- Broken bibliography or CSL paths
- Missing cite keys
- Project metadata diverging from shared metadata without a reason

## Load upstream references as needed

- Figures:
  `../../../skills/quarto/quarto-authoring/references/figures.md`
- Tables:
  `../../../skills/quarto/quarto-authoring/references/tables.md`
- YAML:
  `../../../skills/quarto/quarto-authoring/references/yaml-front-matter.md`

## Guardrails

- Render from the project directory.
- Prefer fixing the document structure over adding fragile one-off hacks.
- If a project depends on `D:\matlab-mcp`, prefer its generated outputs over
  rebuilding the analysis locally during a render fix.

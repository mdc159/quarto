---
name: quarto-workspace-authoring
description: >
  Author and edit Quarto documents in this D:\Quarto workspace. Use when
  working on .qmd files under projects/, especially technical reports, test
  plans, trade studies, and analysis writeups. Covers repo-specific
  conventions for figures, tables, section IDs, citations, resource paths,
  shared metadata, and when to consult the upstream Posit Quarto references.
---

# Quarto Workspace Authoring

Read `../../../AGENTS.md` first. Use `../../../CLAUDE.md` only when you need
extra background or historical rationale.

## Workflow

1. Inspect the target project's `_quarto.yml` and any sibling `.qmd` files
   before editing.
2. Preserve raw drafts in `source/`. Edit the working `.qmd`, not the source
   copy.
3. Reuse shared metadata, bibliography, and formatting patterns from
   `../../../_shared/` unless the project clearly needs an exception.
4. Add section IDs when a section may be cross-referenced now or later.
5. Use plain image syntax for single-image figures:
   `![Caption](image.png){#fig-id fig-alt="..."}`
6. Use fenced div wrappers only for grouped figures, subfigures, or
   non-image content.
7. Add `tbl-colwidths` proactively for wide tables.
8. Add `fig-alt` for substantive figures.
9. If a project uses external artifacts, prefer `resource-path` in
   `_quarto.yml` for rendering, but keep live-preview needs in mind.
10. Prefer `Eq. @eq-id`, `Table @tbl-id`, and `Figure @fig-id` over the
    parenthesized `(@eq-id)` style so the document stays compatible with the
    visual editor.
11. Do not leave a bare cross-reference like `@eq-id` at the start of an
    indented continuation line inside a list item or callout. Pandoc can
    misparse that as an example list.
12. If a document needs reliable Quarto live preview for external figures,
    stage the referenced assets under a project-local `generated/` folder and
    include that folder under `project.resources`.

## Load these upstream references as needed

- Cross-references:
  `../../../skills/quarto/quarto-authoring/references/cross-references.md`
- Figures:
  `../../../skills/quarto/quarto-authoring/references/figures.md`
- Tables:
  `../../../skills/quarto/quarto-authoring/references/tables.md`
- Callouts:
  `../../../skills/quarto/quarto-authoring/references/callouts.md`
- YAML:
  `../../../skills/quarto/quarto-authoring/references/yaml-front-matter.md`
- Citations:
  `../../../skills/quarto/quarto-authoring/references/citations.md`

## Guardrails

- Render from the project directory, not the workspace root.
- Use `D:\Quarto\.venv\Scripts\python.exe` for Quarto execution.
- Check `_shared/refs.bib` and any project `refs.bib` before adding new cite
  keys.
- Prefer active voice, impersonal tone, and present tense for engineering
  documents in this workspace.
- Keep engineering calculations in their external source of truth when the
  project already depends on one, such as `D:\matlab-mcp`.

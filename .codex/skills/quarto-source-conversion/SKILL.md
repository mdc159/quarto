---
name: quarto-source-conversion
description: >
  Convert rough source drafts into repo-ready Quarto documents in this
  workspace. Use when turning AI-generated Markdown, copied report drafts,
  or source files under projects/*/source/ into maintainable .qmd files, and
  when deciding whether to reuse the transform_*.py helpers in _scripts/ or
  switch to manual cleanup.
---

# Quarto Source Conversion

Read `../../../AGENTS.md` first, then inspect the target project structure.

## Workflow

1. Preserve the original draft in `projects/<project>/source/`.
2. Inspect the target project's existing `.qmd`, `_quarto.yml`, and sibling
   documents before starting a conversion.
3. Decide whether the draft is close enough for manual cleanup or whether the
   one-off transform scripts are worth adapting.
4. Treat the scripts under `../../../_scripts/` as patterns, not safe generic
   tools. Several still use hard-coded source paths and must be inspected or
   patched before execution.
5. If the draft matches the old conversion workflow, adapt and run the helpers
   in this order:
   - `../../../_scripts/transform_report.py`
   - `../../../_scripts/transform_matlab_block.py`
   - `../../../_scripts/clean_parts_tables.py`
   - `../../../_scripts/transform_report_pass3.py`
6. Follow the automated pass with manual cleanup for:
   - frontmatter
   - section structure
   - citations
   - figure and table syntax
   - callouts
   - section IDs
   - refs placement
7. Hand the result to `quarto-workspace-authoring` and `quarto-render-debug`.

## Use the scripts only when they actually fit

The current helpers are strongest for:

- backslash-escaped Markdown cleanup
- numeric citation conversion to BibTeX keys
- converting broken MATLAB sections into paired Python plus display-only
  MATLAB blocks
- wrapping important pipe tables in Quarto table divs

Do not force them onto a document that already has stable Quarto structure.

## Guardrails

- Never overwrite the original file in `source/`.
- Never run a hard-coded script blindly against the wrong project.
- Prefer a smaller manual cleanup over a large automated rewrite that makes
  the document harder to reason about.

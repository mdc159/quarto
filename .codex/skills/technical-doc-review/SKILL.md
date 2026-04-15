---
name: technical-doc-review
description: >
  Review technical Quarto documents and supporting scripts in this workspace.
  Use when the user asks for a review, editorial pass, QA pass, evidence check,
  or final report scrub on .qmd files, rendered-document structure, supporting
  scripts, citations, figures, tables, and handoff notes.
---

# Technical Document Review

Read `../../../AGENTS.md` first.

## Review standard

Report findings first, ordered by severity. Keep the summary brief.

## What to check

- Unsupported or overstated conclusions
- Mismatch between prose, tables, figures, and equations
- Broken or missing cross-references, labels, or citations
- Render risks that will break HTML or PDF output
- Missing or weak `fig-alt`
- Style drift away from active voice, impersonal tone, and present tense
- Duplication of engineering logic that should remain in an external source of
  truth such as `D:\matlab-mcp`
- Handoff gaps when the document clearly depends on multi-session work

## Evidence discipline

- Prefer concrete references to the current `.qmd`, render output, and source
  artifacts.
- If a conclusion depends on external generated data, verify the document is
  aligned with those artifacts instead of assuming the prose is current.

## Guardrails

- If no findings exist, say so explicitly and note any residual risk such as
  missing tests, unrendered output, or unchecked external dependencies.
- Do not collapse a review into style-only comments if there are correctness or
  evidence issues.

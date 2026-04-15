---
name: reasoned-tech-doc-review
description: >
  Perform a deep engineering-document review for Quarto reports, Markdown
  drafts, and related artifacts when the user wants more than a style pass:
  contradiction checks, claim-to-evidence audits, thermodynamic or units
  scrutiny, logical-flow gaps, source-of-truth drift, and findings ordered by
  severity.
---

# Reasoned Technical Document Review

Read `../../../AGENTS.md` first, then use the existing local
`technical-doc-review` skill as the baseline review standard.

Use this skill when the review needs engineering rigor, not just editorial QA.
Typical triggers:

- review the logic or logical flow
- verify claims are actually supported
- look for holes, gaps, contradictions, or unsupported jumps
- audit thermodynamic equations, pressure-volume-temperature reasoning, or unit
  consistency
- compare conclusions against generated artifacts, tables, figures, or external
  sources of truth

## Review order

Follow this order unless the user asks for a narrower pass:

1. Confirm the target document, project root, and any stated external source of
   truth.
2. Check render and cross-reference safety for `.qmd` workflows.
3. Audit equations, units, and conservative-bound claims.
4. Audit claim-to-evidence traceability across prose, tables, figures, and
   generated artifacts.
5. Audit narrative consistency across sections, including contradictions between
   "investigation-only" framing and later design conclusions.
6. Close with residual risks, unchecked dependencies, or missing artifacts.

## Supporting artifacts to inspect

Prefer concrete repo evidence over guesswork. Read only the files that matter:

- target `.qmd`, `.md`, or `.docx`
- project `_quarto.yml`
- generated summaries or TSV outputs under `generated/`
- `SESSION_HANDOFF.md` and `_state/<project>/manifest.yml` when present
- prior reviews under `Reviews/`
- shared or project bibliography only when citation support is in question

If the document depends on `D:\matlab-mcp` or another external source of truth,
verify the prose is aligned with generated artifacts instead of re-deriving the
engineering model locally.

## Output contract

- Report findings first, ordered by severity.
- Use the severity and category rules in `references/review-rubric.md`.
- Use the field definitions in `references/output-schema.md` when producing a
  structured review artifact or aligning with the OpenAI-backed reviewer.
- Prefer concrete locations like section titles, equation labels, table labels,
  figure labels, or line ranges when available.

## Guardrails

- Do not invent evidence from files you did not inspect.
- Do not reduce a correctness review to tone comments if there are physics,
  logic, or evidence issues.
- Do not rewrite the document during a review unless the user explicitly asks
  for fixes after findings are delivered.
- When a claim is conservative, state why the bound is conservative and whether
  the text explains that correctly.

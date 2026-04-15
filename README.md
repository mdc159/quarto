# Quarto Workspace

This repo is a Quarto-based publishing workspace for technical engineering
documents. The current review stack supports deep correctness review for reports
that include thermodynamic reasoning, threshold tables, generated artifacts, and
evidence-heavy conclusions.

## Review Stack

Current deep-review components:

- Skill: `.codex/skills/reasoned-tech-doc-review/`
- Baseline review skill: `.codex/skills/technical-doc-review/`
- Workspace reviewer agent: `.claude/agents/technical-reviewer.md`
- Manual OpenAI-backed reviewer: `_scripts/openai_reasoned_review.py`

Use `technical-doc-review` for a normal technical QA pass. Use
`reasoned-tech-doc-review` when the job is to find contradictions, unsupported
claims, unit drift, thermodynamic mistakes, source-of-truth drift, or gaps
between prose and equations/tables/figures.

## Install Review Dependencies

From `D:\Quarto`:

```powershell
& 'D:\Quarto\.venv\Scripts\python.exe' -m pip install ".[review]"
```

This installs the current review extras:

- `openai`
- `pydantic`
- `python-docx`

## Configure the API Key

The OpenAI-backed reviewer expects `OPENAI_API_KEY` in the environment or in
`D:\Quarto\.env`.

Example `.env` entry:

```text
OPENAI_API_KEY=...
```

Optional environment variables:

- `TECH_DOC_REVIEW_MODEL`
  Default: `o3`
- `TECH_DOC_REVIEW_REASONING_EFFORT`
  Default: `high`
- `TECH_DOC_REVIEW_INCLUDE_SUPPORTING`
  Default: `true`
- `TECH_DOC_REVIEW_MAX_SECTIONS`
  Optional cap for chunked review runs

## Proper Skill Usage

### In Codex

Name the skill explicitly when you want the deep engineering review behavior.

Example prompts:

```text
Use $reasoned-tech-doc-review to review projects/shipping/failure-mechanism.qmd for logical contradictions, unsupported claims, and thermodynamic/unit issues.
```

```text
Use $reasoned-tech-doc-review to compare the prose in this report against the generated TSV summaries and prior review notes.
```

Use the baseline skill for a lighter pass:

```text
Use $technical-doc-review to do a final QA pass on this Quarto report before render.
```

### What the Skill Is Expected to Do

The `reasoned-tech-doc-review` skill should:

1. Confirm the target document and any declared external source of truth.
2. Check render and cross-reference safety for `.qmd` workflows.
3. Audit equations, units, and conservative-bound claims.
4. Audit claim-to-evidence traceability across prose, tables, figures, and
   generated artifacts.
5. Audit contradictions across sections and stale conclusions.
6. Report findings first, ordered by severity.

The review is findings-first. It should not silently switch into rewrite mode
unless the user explicitly asks for fixes after the findings are delivered.

## Manual Deep Review Command

The canonical deep-review entrypoint is:

```powershell
& 'D:\Quarto\.venv\Scripts\python.exe' _scripts\openai_reasoned_review.py <target-doc>
```

Example:

```powershell
& 'D:\Quarto\.venv\Scripts\python.exe' _scripts\openai_reasoned_review.py projects\shipping\failure-mechanism.qmd
```

Useful flags:

- `--support <path1> <path2> ...`
  Add specific supporting artifacts
- `--model o3`
  Override the default reasoning model
- `--no-supporting`
  Skip automatic support-file discovery
- `--json-only`
  Print JSON and skip the markdown artifact
- `--max-sections 2`
  Useful for smoke tests or low-cost partial runs

Supported target formats:

- `.qmd`
- `.md`
- `.docx`

## What the Script Reads Automatically

When the target is under `projects/<project>/`, the reviewer will try to use:

- the target document
- project `_quarto.yml`
- project `SESSION_HANDOFF.md`
- project or shared bibliography files when present
- generated `*.tsv`, `*.csv`, and `*.md` summaries under `generated/`
- prior reviews under `Reviews/`
- shared metadata such as `_shared/_metadata.yml`

If the document declares an external source of truth such as `D:\matlab-mcp`,
the review should align the prose to the generated artifacts from that source
instead of re-deriving the model locally.

## Review Artifacts

The script writes:

- Markdown review:
  `projects/<project>/Reviews/Review-<stem>-reasoned.md`
- JSON review:
  `_state/<project>/reviews/<stem>-reasoned.json`

The `-reasoned` suffix is intentional. It avoids overwriting an existing manual
review artifact.

## Current Agent Status

There is already a workspace-local reviewer agent definition at:

- `.claude/agents/technical-reviewer.md`

Current role of that agent:

- use the `reasoned-tech-doc-review` skill first
- prefer repo evidence over guesswork
- call `_scripts/openai_reasoned_review.py` when the user wants a deeper
  reasoning pass or a structured artifact

Example prompt:

```text
Use the technical-reviewer agent to audit projects/shipping/failure-mechanism.qmd for contradictions, unsupported claims, and source-of-truth drift.
```

This is currently a manual agent workflow, not an autonomous background system.

## Future Agent Upgrade Plan

The current implementation deliberately stays simple:

- skill for review behavior
- script for structured OpenAI-backed review
- agent definition as a prompt-level wrapper

Planned upgrade path:

1. Add a small evaluation set under `_state/` so prompt or model changes can be
   checked against known contradiction and evidence-gap cases.
2. Add a render-aware review mode that runs a Quarto render or warning check
   before the reasoning pass, so broken labels and stale resources are caught in
   the same workflow.
3. Add stronger source-of-truth adapters for projects that depend on generated
   outputs from `D:\matlab-mcp` or notebook artifacts, so the reviewer can trace
   exact tables and thresholds with less manual setup.
4. Add optional fix mode after findings, so a second pass can patch supported
   issues instead of only reporting them.
5. Consider upgrading to a fuller OpenAI agent implementation only if the repo
   needs persistent sessions, handoffs, guardrails, or tracing-heavy tool
   orchestration. Until then, the direct `Responses` API path is simpler and
   easier to debug.

## Recommended Starting Point

For a new deep review request, start with one of these:

```text
Use $reasoned-tech-doc-review on projects/shipping/failure-mechanism.qmd.
```

```powershell
& 'D:\Quarto\.venv\Scripts\python.exe' _scripts\openai_reasoned_review.py projects\shipping\failure-mechanism.qmd
```

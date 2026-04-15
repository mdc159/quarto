# Opto-Mechanical Engineering Documentation Workspace

A Quarto-based publishing workspace for engineering investigation reports,
specifications, design studies, and test documentation. Each project lives
in its own subdirectory under `projects/`. Shared resources (bibliography,
templates, brand assets, Python environment) live at the workspace level.

## Workspace Layout

```text
D:\Quarto\
|-- README.md                 this file
|-- CLAUDE.md                 AI assistant instructions (workspace conventions)
|-- .gitignore
|
|-- _shared/
|   |-- _metadata.yml         shared Quarto YAML (formats, LaTeX preamble)
|   |-- refs.bib              master BibTeX bibliography
|   |-- ieee.csl              IEEE citation style
|   `-- templates/            document type templates (see below)
|       |-- document-types.md reference: all types, ID conventions, traceability
|       `-- pir.qmd           Preliminary Investigative Report template
|
|-- _scripts/                 reusable transformation scripts (.R2.md -> .qmd)
|-- docs/                     workspace operational guides
|-- .venv/                    workspace-shared Python venv (uv-managed)
|
`-- projects/
    |-- shipping/             nitrogen shipping failure investigation
    |   |-- failure-mechanism.qmd    PIR-SH-001 (active)
    |   |-- traceability.yml         structured finding/requirement registry
    |   `-- ...
    `-- galling-mitigation/   fastener galling test plan and report
        `-- ...
```

## Document Types

Five standard engineering document types form a traceability chain from
investigation through verification. Templates are in `_shared/templates/`.

```text
PIR --findings--> EPS <--answers-- EDS
                   |
                   `--drives--> TPS <--answers-- TAR
```

| Code | Full Name                         | Produces                  | Template Status |
| ---- | --------------------------------- | ------------------------- | --------------- |
| PIR  | Preliminary Investigative Report  | Findings (FND-)           | Available       |
| EPS  | Element Performance Specification | Requirements (REQ-)       | Planned         |
| EDS  | Element Design Specification      | Design decisions (DSN-)   | Planned         |
| TPS  | Testing Protocol Specification    | Verification items (VER-) | Planned         |
| TAR  | Technical Analysis Report         | Verification results      | Planned         |

See `_shared/templates/document-types.md` for the full specification
including ID conventions and finding disposition rules.

## Traceability

Each project maintains a `traceability.yml` file that tracks the
bidirectional links between findings, requirements, design decisions,
and verification items.

### How it works

1. **PIR** produces findings tagged `FND-XX-nnn` (where `XX` is the
   two-letter project code). Each finding is anchored in the Quarto
   document with `{#fnd-xx-nnn}` and registered in `traceability.yml`.
2. **EPS** derives requirements (`REQ-XX-nnn`) from adopted findings.
   Each requirement records its source finding in `traceability.yml`,
   and the finding's `forward_links` field is updated to point back.
3. **EDS** records design decisions (`DSN-XX-nnn`) that satisfy
   specific requirements.
4. **TPS/TAR** record verification items (`VER-XX-nnn`) that prove
   requirements are met, using one of four methods: test, analysis,
   inspection, or demonstration (TAID).

### ID convention

| Prefix | Scope        | Format         | Example        |
| ------ | ------------ | -------------- | -------------- |
| FND-   | Finding      | `FND-XX-nnn` | `FND-SH-001` |
| REQ-   | Requirement  | `REQ-XX-nnn` | `REQ-SH-001` |
| DSN-   | Design       | `DSN-XX-nnn` | `DSN-SH-001` |
| VER-   | Verification | `VER-XX-nnn` | `VER-SH-001` |

IDs are sequential within each category and gap-tolerant (never
renumber when items are deleted).

### Project codes

| Code | Project            |
| ---- | ------------------ |
| SH   | Shipping           |
| GM   | Galling mitigation |

### Finding dispositions

Each PIR finding receives a disposition when the downstream EPS is written:

- **Adopt** -- becomes a requirement (forward-linked to `REQ-`)
- **Note** -- informational, no requirement generated
- **Reject** -- does not warrant action (rationale documented)

## Render Workflow

```bash
cd projects/<project-name>
export QUARTO_PYTHON=/d/Quarto/.venv/Scripts/python.exe
quarto render                          # all documents, both formats
quarto render document.qmd --to html   # one document, one format
```

Requires: Quarto CLI, the workspace `.venv` with `jupyter`, `numpy`,
`matplotlib`, `pandas`, `CoolProp`, and supporting packages. Set up with:

```bash
uv pip install -e ".[dev]"    # from workspace root, uses pyproject.toml
```

## Review Stack

The workspace includes a multi-model review pipeline for deep technical
correctness review of reports that include thermodynamic reasoning,
threshold tables, generated artifacts, and evidence-heavy conclusions.

### Components

| Component                | Location                                    | Purpose                                |
| ------------------------ | ------------------------------------------- | -------------------------------------- |
| Baseline review skill    | `.codex/skills/technical-doc-review/`     | Normal technical QA pass               |
| Reasoned review skill    | `.codex/skills/reasoned-tech-doc-review/` | Deep contradiction/evidence/unit audit |
| Gemini Reasoned Review   | `skills/gemini-technical-reviewer/`         | Gemini 3.1 Pro full-context single-pass review |
| Workspace reviewer agent | `.claude/agents/technical-reviewer.md`    | Claude-based review agent              |
| OpenAI-backed reviewer   | `_scripts/openai_reasoned_review.py`      | Structured reasoning review via o3     |

Use `technical-doc-review` for a normal technical QA pass. Use
`reasoned-tech-doc-review` when the job is to find contradictions,
unsupported claims, unit drift, thermodynamic mistakes, source-of-truth
drift, or gaps between prose and equations/tables/figures.

### Install review dependencies

```powershell
& 'D:\Quarto\.venv\Scripts\python.exe' -m pip install ".[review]"
```

This installs: `openai`, `pydantic`, `python-docx`.

### Configure the API key

The OpenAI-backed reviewer expects `OPENAI_API_KEY` in the environment or
in `D:\Quarto\.env`.

Optional environment variables:

- `TECH_DOC_REVIEW_MODEL` (default: `o3`)
- `TECH_DOC_REVIEW_REASONING_EFFORT` (default: `high`)
- `TECH_DOC_REVIEW_TIMEOUT_SECONDS` (default: `300`)
- `TECH_DOC_REVIEW_INCLUDE_SUPPORTING` (default: `true`)
- `TECH_DOC_REVIEW_MAX_SECTIONS` (optional cap for chunked runs)
- `TECH_DOC_REVIEW_BATCH_CHARS` (default: `30000`)
- `TECH_DOC_REVIEW_MAX_SECTIONS_PER_BATCH` (default: `10`)

### Running a review

**Via Codex skill:**

```text
Use $reasoned-tech-doc-review to review projects/shipping/failure-mechanism.qmd
for logical contradictions, unsupported claims, and thermodynamic/unit issues.
```

**Via Gemini Review Skill:**

```text
Run the gemini-technical-reviewer skill on projects/shipping/failure-mechanism.qmd.
(It will output a Markdown report to projects/<project>/Reviews/ and a JSON payload to _state/<project>/reviews/)
```

**Via Claude agent:**

```text
Use the technical-reviewer agent to audit projects/shipping/failure-mechanism.qmd
for contradictions, unsupported claims, and source-of-truth drift.
```

**Via script:**

```powershell
& 'D:\Quarto\.venv\Scripts\python.exe' _scripts\openai_reasoned_review.py projects\shipping\failure-mechanism.qmd
```

Useful flags: `--support <paths>`, `--model o3`, `--no-supporting`,
`--json-only`, `--max-sections 2`.

The script emits live progress logs to stdout. In a background harness, those
messages show whether the run is still making progress through bootstrap,
batched review calls, and synthesis.

The default full-document path is batched rather than one OpenAI call per
section. Large reports are grouped into a small number of review batches before
the final synthesis pass.

Supported target formats: `.qmd`, `.md`, `.docx`.

### What the script reads automatically

When the target is under `projects/<project>/`, the reviewer uses:

- the target document
- project `_quarto.yml` and `SESSION_HANDOFF.md`
- project or shared bibliography files
- generated `*.tsv`, `*.csv`, and `*.md` summaries under `generated/`
- prior reviews under `Reviews/`
- shared metadata (`_shared/_metadata.yml`)

### Review artifacts

The script writes:

- Markdown: `projects/<project>/Reviews/Review-<stem>-reasoned.md`
- JSON: `_state/<project>/reviews/<stem>-reasoned.json`

The `-reasoned` suffix is intentional. It avoids overwriting an existing manual
review artifact.

### Full reviewer documentation

For the full reviewer design and operations guide, including workflow,
harness/background-run behavior, tuning knobs, troubleshooting, and Mermaid
diagrams, see:

- [OpenAI Reasoned Reviewer](docs/openai-reasoned-reviewer.md)

### What a review is expected to do

1. Confirm the target document and any declared external source of truth.
2. Check render and cross-reference safety for `.qmd` workflows.
3. Audit equations, units, and conservative-bound claims.
4. Audit claim-to-evidence traceability across prose, tables, figures,
   and generated artifacts.
5. Audit contradictions across sections and stale conclusions.
6. Report findings first, ordered by severity.

The review is findings-first. It does not switch into rewrite mode unless
the user explicitly asks for fixes after findings are delivered.

## Review Tracking

Each project maintains a `Reviews/` directory with numbered review
files and their responses:

```
Reviews/
  001-v1-narrative-reframe.md            the review
  001-v1-narrative-reframe.response.md   what changed and why
  002-threshold-correction.md
  002-threshold-correction.response.md
```

Reviews are numbered sequentially. The response file records each
finding's disposition and the specific changes made, with a reference
to the git commit or branch where the changes landed.

## Writing Style

All technical prose follows these conventions:

- Active voice, impersonal tone, present tense
- No "we" constructions; no future-tense hedging
- Lead the reader through the analysis step by step
- Equations are numbered and cross-referenced with Quarto `@eq-` syntax

See `CLAUDE.md` for the full set of Quarto-specific conventions
(figure syntax, table column widths, LaTeX preamble, etc.).

## Git Workflow

- **`master`** -- stable baseline; commit checkpoints here
- **Feature branches** -- use `<project>/<description>` naming
  (e.g., `shipping/v2-transit-model`) for rewrites and explorations
- Merge back to master when the work stabilizes
- `source/` directories hold original input material (AI drafts, Word
  docs, MATLAB notes) -- these are inputs, not document iterations
- `git log` tracks document evolution; `source/` tracks provenance

## Roadmap

- [ ] Complete PIR-SH-001 (shipping transit model)
- [ ] Measure $V_{fixed}$ (FND-SH-003) and update findings
- [ ] Re-run notebook figures with final parameters
- [ ] Render and review Word output
- [ ] EPS template (`_shared/templates/eps.qmd`)
- [ ] EDS template (`_shared/templates/eds.qmd`)
- [ ] TPS template (`_shared/templates/tps.qmd`)
- [ ] TAR template (`_shared/templates/tar.qmd`)
- [ ] Shipping EPS (EPS-SH-001): derive requirements from PIR findings
- [ ] Brand identity (`_shared/_brand.yml`) via `quarto:brand-yml` skill
- [ ] Galling mitigation: apply traceability framework to existing documents
- [ ] MATLAB MCP integration for executable MATLAB cells in Quarto

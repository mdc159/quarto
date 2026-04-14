# Opto-Mechanical Engineering Documentation Workspace

A Quarto-based publishing workspace for engineering investigation reports,
specifications, design studies, and test documentation. Each project lives
in its own subdirectory under `projects/`. Shared resources (bibliography,
templates, brand assets, Python environment) live at the workspace level.

## Workspace Layout

```
D:\Quarto\
├── README.md                 this file
├── CLAUDE.md                 AI assistant instructions (workspace conventions)
├── .gitignore
│
├── _shared/
│   ├── _metadata.yml         shared Quarto YAML (formats, LaTeX preamble)
│   ├── refs.bib              master BibTeX bibliography
│   ├── ieee.csl              IEEE citation style
│   └── templates/            document type templates (see below)
│       ├── document-types.md reference: all types, ID conventions, traceability
│       └── pir.qmd           Preliminary Investigative Report template
│
├── _scripts/                 reusable transformation scripts (.R2.md → .qmd)
├── .venv/                    workspace-shared Python venv (uv-managed)
│
└── projects/
    ├── shipping/             nitrogen shipping failure investigation
    │   ├── failure-mechanism.qmd    PIR-SH-001 (active)
    │   ├── traceability.yml         structured finding/requirement registry
    │   └── ...
    └── galling-mitigation/   fastener galling test plan and report
        └── ...
```

## Document Types

Five standard engineering document types form a traceability chain from
investigation through verification. Templates are in `_shared/templates/`.

```
PIR ──findings──> EPS <──answers── EDS
                   │
                   └──drives──> TPS <──answers── TAR
```

| Code | Full Name                         | Produces             | Template Status |
|------|-----------------------------------|----------------------|-----------------|
| PIR  | Preliminary Investigative Report  | Findings (FND-)      | Available       |
| EPS  | Element Performance Specification | Requirements (REQ-)  | Planned         |
| EDS  | Element Design Specification      | Design decisions (DSN-) | Planned      |
| TPS  | Testing Protocol Specification    | Verification items (VER-) | Planned    |
| TAR  | Technical Analysis Report         | Verification results | Planned         |

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

| Prefix | Scope        | Format        | Example       |
|--------|-------------|---------------|---------------|
| FND-   | Finding      | `FND-XX-nnn`  | `FND-SH-001`  |
| REQ-   | Requirement  | `REQ-XX-nnn`  | `REQ-SH-001`  |
| DSN-   | Design       | `DSN-XX-nnn`  | `DSN-SH-001`  |
| VER-   | Verification | `VER-XX-nnn`  | `VER-SH-001`  |

IDs are sequential within each category and gap-tolerant (never
renumber when items are deleted).

### Project codes

| Code | Project            |
|------|--------------------|
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
  - [ ] Measure $V_{fixed}$ (INV-3) and update findings
  - [ ] Re-run notebook figures with final parameters
  - [ ] Render and review PDF output
- [ ] EPS template (`_shared/templates/eps.qmd`)
- [ ] EDS template (`_shared/templates/eds.qmd`)
- [ ] TPS template (`_shared/templates/tps.qmd`)
- [ ] TAR template (`_shared/templates/tar.qmd`)
- [ ] Shipping EPS (EPS-SH-001): derive requirements from PIR findings
- [ ] Brand identity (`_shared/_brand.yml`) via `quarto:brand-yml` skill
- [ ] Galling mitigation: apply traceability framework to existing documents
- [ ] MATLAB MCP integration for executable MATLAB cells in Quarto

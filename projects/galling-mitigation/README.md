# Galling Mitigation — Vacuum Fastener Anti-Galling Study

**Document ID:** (not yet assigned)
**Status:** Draft (converted from AI source; copy-edit and section IDs pending)

This project covers the galling mitigation strategy for stainless steel
fasteners in vacuum opto-mechanical assemblies. Three deliverables:

- **report.qmd** — Technical report: failure analysis, material selection,
  surface treatments, torque specifications
- **test-plan.qmd** — Verification test plan with traceability to report claims
- **digital-twin.qmd** — Digital twin concept for fastener lifecycle tracking

## Key Files

| File | Purpose |
|------|---------|
| `report.qmd` | Main technical report |
| `test-plan.qmd` | Test plan with claim traceability |
| `digital-twin.qmd` | Digital twin design concept |
| `_quarto.yml` | Quarto project config (inherits `_shared/_metadata.yml`) |

### Source material

| File | Purpose |
|------|---------|
| `source/report.R2.md` | Original AI-generated report draft |
| `source/test_plan.R2.md` | Original AI-generated test plan draft |

### Output

| Directory | Purpose |
|-----------|---------|
| `figures/` | Static images (fixture schematic, etc.) |
| `_output/` | Rendered deliverables — `.docx` tracked, `.html`/`.pdf` gitignored |

## How to Render

```bash
cd D:/Quarto/projects/galling-mitigation
export QUARTO_PYTHON=/d/Quarto/.venv/Scripts/python.exe
quarto render                              # all documents, all formats
quarto render report.qmd --to docx         # Word only
```

## Outstanding Work

- Copy-edit prose to match preferred technical writing style (active voice, impersonal tone)
- Add `{#sec-xxx}` IDs to all section headings in `report.qmd`
- Replace placeholder `fixture-schematic.png` with real CAD diagram
- Create `SESSION_HANDOFF.md` to track progress
- Assign document ID(s)

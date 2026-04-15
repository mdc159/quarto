# Shipping — Nitrogen Purge Failure Mechanism Analysis

**Document ID:** PIR-SH-001
**Status:** In review (reasoned + Gemini reviews complete; findings being addressed)

This project analyzes the thermodynamic failure mechanism that causes
nitrogen purge contamination in optical assemblies during air transport.
The core finding: return-leg underpressure draws ambient air through the
bag vent valve, and removing the vent eliminates this path without
exceeding the 0.5 bar PED overpressure limit.

## Key Files

| File | Purpose |
|------|---------|
| `failure-mechanism.qmd` | Primary deliverable — problem specification and mechanism analysis |
| `compliance-volume-design.qmd` | Engineering response — design trade study (stub) |
| `_quarto.yml` | Quarto project config (inherits `_shared/_metadata.yml`) |
| `_variables.yml` | Numeric shortcodes (P_cruise, thresholds, V_fixed) for single-source values |
| `nitrogen_shipping_failure_model.py` | Python simulation model used by executable code cells |
| `SESSION_HANDOFF.md` | Running project journal with to-do items and session history |

### Source material

| File | Purpose |
|------|---------|
| `source/Physics_of_the_Shipping_Failure_Mode.md` | Original AI-generated analysis draft |
| `source/nitrogen_shipping_failure_model.m` | Original MATLAB model (reference) |
| `source/Breather_Bag_Analysis_Rev3.docx` | Prior Word-based analysis |

### Analysis and output

| Directory | Purpose |
|-----------|---------|
| `matlab/` | MATLAB companion analysis — interactive script + Report Generator output |
| `generated/` | Artifacts from Python/MATLAB used by the .qmd (prefixed `PIR-SH-001_`) |
| `Reviews/` | Review reports from reasoned (o3), Gemini, and Codex reviewers |
| `_output/` | Rendered deliverables — `.docx` tracked, `.html`/`.pdf` gitignored |
| `_freeze/` | Quarto execution cache (committed) |
| `figures/` | Static images referenced in the document |

## How to Render

```bash
cd D:/Quarto/projects/shipping
export QUARTO_PYTHON=/d/Quarto/.venv/Scripts/python.exe
quarto render                                    # all documents, all formats
quarto render failure-mechanism.qmd --to docx    # Word only
quarto render failure-mechanism.qmd --to html    # quick preview
```

## How to Run MATLAB Analysis

```matlab
cd('D:/Quarto/projects/shipping/matlab');
run('run_analysis.m');        % interactive 11-section analysis
generate_report();            % PDF, Word, HTML, PowerPoint
verify_report();              % automated verification
```

Requires: Parallel Computing, Optimization, and Report Generator toolboxes.

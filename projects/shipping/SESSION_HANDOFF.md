# Session Handoff — Shipping Failure Mechanism Analysis

**Last updated:** 2026-04-13
**Status:** Quarto document renders clean (HTML). Ready for Mike's review and revision.

## What was accomplished (2026-04-13 session)

### Thermo-engineer agent built
- Merged two agents into one at `.claude/agents/thermo-engineer.md`
- Backed by deep CoolProp research — reference docs at `_shared/ai_docs/coolprop-reference.md` and `_shared/ai_docs/thermo-engineering-reference.md`
- Installed professional thermo stack into `.venv`: CoolProp 7.2, ht 1.2, fluids 1.3, thermo 0.6, chemicals 1.5, iapws 1.5, pint 0.25, pyromat 2.2, tabulate 0.10
- `pyproject.toml` at workspace root declares all dependencies — reproducible setup via `uv pip install -e ".[dev]"`

### Jupyter notebook overhauled
**File:** `output/jupyter-notebook/nitrogen-shipping-coolprop-cycle.ipynb`
- Reviewed by thermo-engineer agent with detailed critique (correctness, publication quality, analytical depth, code quality)
- Fixed worst-deltaP detection (was reporting t=0 for borderline cases)
- Converted simulate() to use CoolProp AbstractState (60-70% faster)
- Colorblind-safe palette (Okabe-Ito), segment shading on all plots, process arrows on T-s/P-v
- Renamed `T_cabin_C` → `T_cargo_C` (this is a 4000 lb crate in a cargo hold, not a cabin)
- Fixed segment 4→5 temperature discontinuity (climb now ends at T_cargo_C, not T_seal_C)
- `SCENARIOS` dict with 6 presets — change `ACTIVE_SCENARIO` string, Run All
- Active scenario: `debatable_baseline` (V_fixed=60L, T_cargo=20°C, T_tarmac=40°C, P_crack=0 psig)
- Added: assumptions section, expanded governing equations with venting derivation, parametric failure surface (contour + 3D + boundary overlay), interactive ipywidgets explorer (5 sliders)

### Key engineering finding: the bag vent is unnecessary
**The 0.5 bar circuit relief valve (PED 2014/68/EU) makes the bag vent unnecessary.**
- Analytical upper bound: max overpressure at cruise = 0.33 bar gauge (even at 40°C cargo, V_fixed → ∞)
- Would need 89.3°C cargo temperature to reach 0.5 bar — physically impossible in air freight
- CoolProp Helmholtz EOS verification confirms ideal-gas bound within 0.03%
- Parametric sweep: system safe for V_fixed 20–120 L, T_cargo 5–30°C at P_crack ≥ 7.25 psig
- At P_crack = 0 (ideal vent, current bag valve): max safe V_fixed ≈ 63 L at 20°C
- At P_crack ≥ 2 psig: safe everywhere up to 120+ L

### Quarto document updated
**File:** `projects/shipping/failure-mechanism.qmd`
- New section: "Upper Bound on Overpressure: The Bag Vent Is Unnecessary" (~420 lines)
  - Analytical derivation with LaTeX equations (#eq-pint-bound, #eq-dp-bound, #eq-t-relief)
  - CoolProp verification table (executable Python cell, code-fold)
  - Parametric failure boundary plot — 5 P_crack contours (#fig-failure-boundary)
  - Filled contour + 3D surface plot (#fig-dp-surface)
  - Max safe volume summary table (#tbl-max-safe-volume)
  - Six numbered validity conditions
- Updated: Summary, High-pressure review, and Conclusions sections with forward references and new items 6–7
- Renders clean to HTML

### Key modeling assumptions documented in notebook
- Valve stays open once cracked (conservative — field experience shows unreliable reseat)
- Venting is instantaneous (equilibrium calculation from EOS — no flow rate needed because the molar mass, T, V, and target P fully determine post-vent mass)
- Flow rate modeling explicitly not pursued: valve behavior is not reliably characterizable without extensive testing, and history shows it is not repeatable
- Bag is ideal passive compliance (zero spring force, hard stops at 0 and V_bag_max)
- Cargo hold temperature is a "debatable baseline" of 20°C

## Known issues / next steps

1. **Equation cross-references** — @eq-no-vent and @eq-return-threshold produce Quarto warnings. The `{#eq-xxx}` labels may need to be on the same line as the `$$` delimiter.
2. **PDF and Word rendering** — not yet tested. See export commands below.
3. **Abstract** — may need updating to reflect the new vent-removal conclusion (currently only describes the failure mechanism, not the solution).
4. **Old `-executed` notebook** — stale file at `output/jupyter-notebook/nitrogen-shipping-coolprop-cycle-executed.ipynb` (15°C results). Can be deleted.
5. **Prose review** — Mike will review for accuracy, tone, completeness. Some original content uses older writing style.
6. **`compliance-volume-design.qmd`** — still a 27-line stub. Design-response study goes here eventually.
7. **Simscape Gas model** — previously attempted, did not work. The simulink-block-hunter and simulink-model-builder agents are available if Mike wants to try again.

## Primary working files
| File | Purpose |
|---|---|
| `projects/shipping/failure-mechanism.qmd` | Main Quarto document (source of truth) |
| `projects/shipping/_output/failure-mechanism.html` | Rendered HTML (current) |
| `output/jupyter-notebook/nitrogen-shipping-coolprop-cycle.ipynb` | Jupyter notebook (executed, 20°C baseline, with widgets) |
| `_shared/ai_docs/coolprop-reference.md` | CoolProp API reference for thermo-engineer agent |
| `_shared/ai_docs/thermo-engineering-reference.md` | ht/fluids/thermo cheat-sheet |
| `.claude/agents/thermo-engineer.md` | Merged thermo-engineer agent definition |
| `pyproject.toml` | Workspace dependency declaration |

## Computation sources
- MATLAB analysis: `D:/matlab-mcp/docs/shipping/nitrogen_shipping_report_analysis.m`
- MATLAB derivations: `D:/matlab-mcp/docs/shipping/nitrogen_shipping_derivation.md`
- Generated MATLAB artifacts: `D:/matlab-mcp/docs/shipping/generated/` (pressure plots, sweep, threshold tables)
- Python notebook: `output/jupyter-notebook/nitrogen-shipping-coolprop-cycle.ipynb` (CoolProp-based, parametric sweep, interactive)

## Render / export commands
```bash
cd D:/Quarto/projects/shipping
export QUARTO_PYTHON=/d/Quarto/.venv/Scripts/python.exe

# HTML (tested, works)
quarto render failure-mechanism.qmd --to html

# PDF (requires LaTeX — uses preamble from _shared/_metadata.yml)
quarto render failure-mechanism.qmd --to pdf

# Microsoft Word
quarto render failure-mechanism.qmd --to docx
```

## Writing constraints (unchanged)
- Active voice, present tense, impersonal tone
- Lead the reader through the investigation step by step
- The investigation report establishes the failure mechanism AND now argues for removing the bag vent
- Design solutions (other than vent removal) belong in `compliance-volume-design.qmd`

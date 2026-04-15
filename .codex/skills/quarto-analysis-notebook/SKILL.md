---
name: quarto-analysis-notebook
description: >
  Create or edit exploratory Jupyter notebooks for Quarto work in this
  workspace. Use when a report or analysis project needs a notebook under
  output/jupyter-notebook/ for parameter sweeps, model exploration, quick
  plots, or cross-checks against generated artifacts, especially when the
  notebook should import repo code directly instead of duplicating analysis
  logic.
---

# Quarto Analysis Notebook

Start from the installed global Jupyter notebook skill at
`C:\Users\Mike\.codex\skills\jupyter-notebook\SKILL.md`, then apply the
workspace-specific rules below.

## Default use in this repo

Use notebooks as exploratory companions to Quarto projects, not as the final
publishing surface for technical reports.

Good fits:

- threshold or parameter sweeps before folding results into `.qmd`
- visual sanity checks on plots and tables
- quick comparison of modeled and generated artifacts
- importing an existing repo Python model into a notebook for exploration

## Workflow

1. Write the notebook under `output/jupyter-notebook/`.
2. Prefer importing repo code directly from `projects/<project>/` instead of
   duplicating model logic inside the notebook.
3. If a project already has an external computational source of truth such as
   `D:\matlab-mcp`, cross-check against its generated artifacts rather than
   replacing it.
4. Keep notebook sections short and runnable from top to bottom.
5. When the exploration produces durable conclusions, move those conclusions
   into the project `.qmd` or `SESSION_HANDOFF.md`.

## Existing reference notebook

Use this notebook as the reference pattern for exploratory analysis tied to
the shipping project:

- `../../../output/jupyter-notebook/nitrogen-shipping-failure-model-exploration.ipynb`

It shows the preferred pattern:

- locate the repo root dynamically
- import the project model directly
- keep a clear experiment plan
- sweep parameters without creating a second permanent model
- optionally cross-check against MATLAB-generated artifacts already on disk

## Guardrails

- Do not let the notebook become a conflicting source of truth.
- Do not duplicate major engineering logic in the notebook when that logic
  already exists in a repo module or external analysis repo.
- Treat notebook HTML outputs as disposable exploration artifacts unless the
  user explicitly wants them preserved.

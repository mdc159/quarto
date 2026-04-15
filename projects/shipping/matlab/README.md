# Nitrogen Shipping Thermodynamic Analysis (MATLAB)

MATLAB implementation of the nitrogen shipping failure analysis.
Companion to `../failure-mechanism.qmd`.

## How to Run

```matlab
% Interactive analysis (11 sections, figures to screen)
run('run_analysis.m')

% Generate reports (PDF, Word, HTML, PowerPoint)
generate_report()                          % all four formats
generate_report({'pdf'})                   % just PDF
generate_report({'pdf','pptx'}, 'my_dir')  % custom output dir

% Verify report output
verify_report()
```

## What It Produces

- **Interactive analysis** — 11-section script with scenario presets, flight profiles,
  baseline cases, 5-phase walkthrough, sweeps, parametric failure surfaces
- **PDF report** — 10-chapter engineering document following the Quarto storyline
- **Word report** — same content, editable for review markup
- **HTML report** — single-file, browser-viewable
- **PowerPoint** — 20-slide condensed deck for stakeholder briefings

## Directory Structure

This directory follows the **MATLAB Analysis Directory Convention**.

```
matlab/
├── README.md               # This file
├── run_analysis.m           # ENTRY POINT: interactive analysis
├── generate_report.m        # ENTRY POINT: report generation
├── verify_report.m          # ENTRY POINT: report verification
├── nitrogen_shipping_analysis.m  # Main analysis script
├── src/                     # Reusable functions (simulation engine, utilities)
│   ├── nitrogen_shipping_sim.m
│   ├── isa_pressure.m
│   ├── build_flight_profile.m
│   └── analytic_thresholds.m
├── report/                  # Report generation functions
│   ├── report_content.m     # PDF/DOCX/HTML document builder
│   ├── report_figures.m     # Figure generation
│   └── report_pptx.m        # PowerPoint builder
├── output/                  # Generated artifacts (gitignored)
│   ├── figures/             # High-res PNGs
│   └── reports/             # PDF, DOCX, HTML, PPTX
└── .gitignore               # Excludes output/
```

### Convention Rules

1. **Entry points at the top level.** Files you run directly (`run_*.m`,
   `generate_*.m`, `verify_*.m`) live at the root. Everything else is in
   subdirectories.

2. **`src/` for reusable functions.** The simulation engine and utilities go here.
   These are pure functions — they take inputs and return outputs, no side effects.
   Any MATLAB project can call these.

3. **`report/` for report generation.** Functions that build document/presentation
   content. Separated from `src/` because they serve a different purpose
   (presentation vs. computation).

4. **`output/` is gitignored.** Generated artifacts (reports, figures) go here.
   They can be regenerated from the source scripts at any time.

5. **Self-contained.** No file references anything outside this directory.
   All path resolution uses `fileparts(mfilename('fullpath'))`.

6. **README.md is mandatory.** Every `matlab/` directory has a README with:
   How to Run, What It Produces, Directory Structure.

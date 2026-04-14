---
name: Nitrogen Shipping CoolProp Notebook
description: Location and status of the nitrogen shipping cycle notebook - rebuilt 2026-04-13 with all P1-P4 fixes applied
type: project
---

The nitrogen shipping CoolProp cycle notebook is at:
`D:\Quarto\output\jupyter-notebook\nitrogen-shipping-coolprop-cycle.ipynb`

**Why:** This notebook models N2 gas in a rigid+compliant volume system through a flight profile. It traces P, rho, T, h, s, Z at each timestep and demonstrates how venting mass loss leads to return-leg underpressure.

**Current state (2026-04-13 rebuild + parametric extension):** All 16 priority items from the critique have been implemented, plus two new sections added:

- P1 Correctness: conditional worst-deltaP detection (no-underpressure vs underpressure), failure demo cell at V_fixed=80L showing clear -6664 Pa underpressure, abs(P_int) replaced with assertions
- P2 Publication quality: Okabe-Ito palette + rcParams, segment shading/labels on time-series plots, process arrows + key-event annotations on T-s/P-v, h/s columns in state_table(), proper kJ/(kg*K) units
- P3 Analytical depth: P_crack sensitivity sweep (0/1/2/5 psig overlay), ideal-gas vs CoolProp full-cycle comparison (60L + 80L), Z-factor deviation plot over full cycle
- P4 Code quality: AbstractState in simulate() loop, vectorized alpha computation, docstrings on all functions, "O" replaced with "CVMASS"
- Section 14 (Parametric Failure Surface): run_scenario() helper rebuilds full profile for any (V_fixed, T_cargo, T_tarmac, cruise_alt, P_crack). 2D contour map, 3D surface, and multi-P_crack failure boundary overlay ("money plot"). Summary table shows max safe V_fixed at 20 C for each P_crack.
- Section 15 (Interactive Explorer): ipywidgets sliders for all 5 parameters with 2x2 live-updating plot (deltaP, bag volume, mass, verdict box).

**How to apply:** The notebook now has 47 cells (up from 43), executes cleanly, and is self-consistent. The backup is at `.ipynb.bak`.

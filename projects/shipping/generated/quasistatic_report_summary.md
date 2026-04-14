# Quasi-Static Shipping Analysis Summary

## Scope
This summary captures the report-ready results from `nitrogen_shipping_report_analysis.m`, using the piecewise MATLAB thermodynamic model rather than the in-progress Simscape branch.

## Inputs
- `V_bag,init = 11 L`
- `V_bag,max = 22 L`
- seal-up: `1.01325 bar abs`, `20 C`
- outbound peak: `0.753 * 1.01325 = 0.7630 bar abs`, `40 C`
- return: `1.01325 bar abs`, `20 C`

Two vent assumptions were evaluated:

1. ideal venting at ambient, `P_vent,g = 0 bar`
2. outward relief at `2 psig = 0.1379 bar`

## Closed-Form Thresholds

### Ideal vent (`0 psig`)
- outbound no-vent limit: `15.28 L`
- largest rigid volume that still returns nonnegative after venting: `52.55 L`
- largest rigid volume that still returns at `+0.01 bar`: `50.85 L`
- largest rigid volume that still returns at `+0.02 bar`: `49.26 L`

### `2 psig` vent
- outbound no-vent limit: `15.28 L`
- largest rigid volume that still returns nonnegative after venting: `109.19 L`
- largest rigid volume that still returns at `+0.01 bar`: `103.12 L`
- largest rigid volume that still returns at `+0.02 bar`: `97.69 L`

## Representative Cases

### Ideal vent (`0 psig`)
- `V_fixed = 12 L`: no venting, no underpressure
- `V_fixed = 30 L`: venting begins at `5.67 hr`, total vented mass `5.06 g`, return remains nonnegative
- `V_fixed = 60 L`: venting begins at `3.58 hr`, bag collapse at `23.08 hr`, worst-case `DeltaP = -0.0371 bar`

### `2 psig` vent
- `V_fixed = 12 L`: no venting, no underpressure
- `V_fixed = 30 L`: bag reaches full volume at `5.67 hr`, but does not vent under the chosen profile
- `V_fixed = 60 L`: venting begins at `7.08 hr`, total vented mass `3.20 g`, return remains nonnegative in this simple model

## Generated Artifacts
- `quasistatic_min_dp_sweep.png`
- `quasistatic_pressure_examples_ideal_vent.png`
- `quasistatic_pressure_examples_vent_2psig.png`
- `quasistatic_bag_examples_ideal_vent.png`
- `quasistatic_bag_examples_vent_2psig.png`
- `quasistatic_threshold_summary.tsv`
- `quasistatic_case_summary.tsv`

## Interpretation
The main screening variable remains `V_fixed`. The bag concept is robust only while the bag-volume ratio remains large enough relative to the rigid manifolded volume. Under ideal venting, the return-leg contamination threshold sits near `52.6 L`. Raising the outward vent threshold to `2 psig` materially delays venting and preserves more nitrogen mass, which shifts the return-leg threshold upward in the quasi-static model.

For the report, use the quasi-static branch for threshold screening and regime plots. Treat the Simscape model as a higher-fidelity corroboration path, not as the primary source for this deadline-driven result.

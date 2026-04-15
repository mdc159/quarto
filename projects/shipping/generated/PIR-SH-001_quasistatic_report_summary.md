# Quasi-Static Shipping Analysis Summary

## Scope
This summary captures the report-ready results from the closed-form screening equations, using the corrected ISA pressure at 8000 ft cabin altitude (75,262 Pa). Original MATLAB model values used 76,300 Pa; thresholds were recalculated in session 3 (2026-04-15).

## Inputs
- `V_bag,init = 11 L`
- `V_bag,max = 22 L`
- seal-up: `1.01325 bar abs`, `20 C`
- outbound peak: `0.75262 bar abs` (ISA at 8000 ft), `40 C`
- return: `1.01325 bar abs`, `20 C`

Two vent assumptions were evaluated:

1. ideal venting at ambient, `P_vent,g = 0 bar`
2. outward relief at `2 psig = 0.1379 bar`

## Closed-Form Thresholds

### Ideal vent (`0 psig`)
- outbound no-vent limit: `14.11 L`
- largest rigid volume that still returns nonnegative after venting: `50.21 L`
- largest rigid volume that still returns at `+0.01 bar`: `48.64 L`
- largest rigid volume that still returns at `+0.02 bar`: `47.16 L`

### `2 psig` vent
- outbound no-vent limit: `14.11 L`
- largest rigid volume that still returns nonnegative after venting: `102.11 L`
- largest rigid volume that still returns at `+0.01 bar`: `96.73 L`
- largest rigid volume that still returns at `+0.02 bar`: `91.88 L`

## Representative Cases

### Ideal vent (`0 psig`)
- `V_fixed = 12 L`: no venting, no underpressure
- `V_fixed = 30 L`: venting begins at `5.67 hr`, total vented mass `5.06 g`, return remains nonnegative
- `V_fixed = 60 L`: venting begins at `3.58 hr`, bag collapse at `23.08 hr`, worst-case `DeltaP = -0.0371 bar`

### `2 psig` vent
- `V_fixed = 12 L`: no venting, no underpressure
- `V_fixed = 30 L`: bag reaches full volume at `5.67 hr`, but does not vent under the chosen profile
- `V_fixed = 60 L`: venting begins at `7.08 hr`, total vented mass `3.20 g`, return remains nonnegative in this simple model

Note: Representative case values (vented mass, timing, ΔP) are from the original MATLAB model at T_cargo = 20 °C. Only the closed-form thresholds above have been recalculated with the corrected cruise pressure.

## Generated Artifacts
- `PIR-SH-001_quasistatic_min_dp_sweep.png`
- `PIR-SH-001_quasistatic_pressure_examples_ideal_vent.png`
- `PIR-SH-001_quasistatic_pressure_examples_vent_2psig.png`
- `PIR-SH-001_quasistatic_bag_examples_ideal_vent.png`
- `PIR-SH-001_quasistatic_bag_examples_vent_2psig.png`
- `PIR-SH-001_quasistatic_threshold_summary.tsv`
- `PIR-SH-001_quasistatic_case_summary.tsv`

## Interpretation
The main screening variable remains `V_fixed`. The bag concept is robust only while the bag-volume ratio remains large enough relative to the rigid manifolded volume. Under ideal venting, the return-leg contamination threshold sits near `50.2 L`. Raising the outward vent threshold to `2 psig` materially delays venting and preserves more nitrogen mass, which shifts the return-leg threshold upward in the quasi-static model.

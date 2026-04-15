# Review: failure-mechanism.qmd

Date: 2026-04-15

Reviewer: Codex

Target: `D:\Quarto\projects\shipping\failure-mechanism.qmd`

## Scope

This review focused on correctness, evidence support, internal consistency,
source-of-truth alignment, and obvious Quarto/render risks. Findings below are
limited to issues that were validated directly against the source document and
the generated threshold summary artifacts.

## Findings

### [Major] Core failure-history and valve-capability claims are not tied to traceable evidence

- Location:
  - `failure-mechanism.qmd:13`
  - `failure-mechanism.qmd:20`
  - `failure-mechanism.qmd:88`
  - `failure-mechanism.qmd:922`
- Issue:
  - The abstract states that the outward-only valve is "structurally incapable"
    during the sub-atmospheric phase and that "confirmed field failures" are
    the observed consequence of the mechanism, but the report does not cite a
    failure report, test record, inspection memo, or other traceable source for
    those claims.
- Why it matters:
  - These are central claims in the root-cause chain. Without explicit evidence,
    the report reads as technically plausible but not fully supported.
- Suggested fix:
  - Add citations or explicit internal cross-references to the documents,
    inspections, or tests that establish the field-failure history and valve
    behavior.

### [Major] The report uses inconsistent ambient-pressure values for the same 8000 ft cabin condition

- Location:
  - `failure-mechanism.qmd:71`
  - `failure-mechanism.qmd:223`
  - `failure-mechanism.qmd:274`
  - `failure-mechanism.qmd:343`
- Issue:
  - The transport-envelope table gives the 8000 ft cabin condition as
    `~0.753 atm (76.3 kPa)`, while the overpressure section uses
    `75.26 kPa` for the same condition. The closed-form threshold calculations
    use `0.7630 bar abs`, which corresponds to `76.3 kPa`, not `75.26 kPa`.
- Why it matters:
  - The document is mixing pressure bases inside one argument chain. That
    weakens confidence in the derived thresholds and the relief-opening
    temperature.
- Suggested fix:
  - Choose one cabin-pressure basis and use it consistently across the
    transport-envelope table, threshold derivations, overpressure bound, and
    embedded code comments/tables.

### [Major] The vent-removal recommendation is justified with a narrower temperature sweep than the stated transport envelope

- Location:
  - `failure-mechanism.qmd:69`
  - `failure-mechanism.qmd:641`
  - `failure-mechanism.qmd:801`
  - `failure-mechanism.qmd:814`
  - `failure-mechanism.qmd:914`
- Issue:
  - The transport-envelope table declares a shipping temperature range of
    `20 C to 40 C`, but the parametric contour used to support the statement
    that the system is safe everywhere at PED-level cracking pressure sweeps
    `T_cargo` from `5 to 30 C` with `T_tarmac = 35 C`.
- Why it matters:
  - As written, the recommendation is broader than the parametric study that
    supports it. The document should not claim closure for the full declared
    envelope when the plotted sweep is narrower.
- Suggested fix:
  - Either rerun the sweep to cover the full stated transport envelope or
    narrow the prose so the design recommendation only claims what the current
    sweep actually demonstrates.

### [Major] Threshold values are duplicated as literals instead of being bound to the generated source-of-truth table

- Location:
  - `failure-mechanism.qmd:40`
  - `failure-mechanism.qmd:289`
  - `generated/quasistatic_threshold_summary.tsv:1`
- Issue:
  - The summary and threshold table repeat key values such as `15.28 L`,
    `52.55 L`, and `109.19 L` directly in the manuscript, but the `.qmd` does
    not import them from `generated/quasistatic_threshold_summary.tsv` at render
    time.
- Why it matters:
  - This creates silent drift risk if the MATLAB/CoolProp source-of-truth
    outputs change.
- Suggested fix:
  - Bind the report text/table to the generated TSV through a render-time read
    or include step, or explicitly record the generated artifact version/hash
    used by the document.

### [Minor] `date: today` makes the document metadata non-reproducible

- Location:
  - `failure-mechanism.qmd:5`
- Issue:
  - The document uses `date: today`.
- Why it matters:
  - This causes the output metadata to change on every render and works against
    stable freeze/caching behavior and clean document diffs.
- Suggested fix:
  - Replace it with a fixed date or a deliberate parameterized build date.

## Notes

- A quiet Quarto render completed during review, so no immediate render-blocking
  cross-reference failure was observed in this pass.
- This artifact intentionally excludes weaker hypotheses that were not confirmed
  directly from the source.

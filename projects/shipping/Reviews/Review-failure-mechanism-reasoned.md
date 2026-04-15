# Review: failure-mechanism.qmd

Target: `projects\shipping\failure-mechanism.qmd`

## Summary

The mechanism description is technically sound but several traceability and reproducibility gaps remain.  A machine-specific LaTeX path still hard-codes the build environment and will break CI rendering.  Key quantitative limits and ambient-pressure inputs diverge between the narrative (now driven by _variables.yml) and the still-stale MATLAB‐generated artifacts, creating visible contradictions.  Central field-failure and valve-reseat claims lack documentary evidence.  Finally, the showcase figure and case table use a narrower 20 °C/30 °C sweep than the 40 °C envelope adopted elsewhere, obscuring worst-case margin.

## Findings

### [BLOCKER] Python chunk prepends a personal TinyTeX path (`C:\Users\Mike\AppData\Roaming\TinyTeX\bin\windows`) to PATH.

- Category: `render-crossref`
- Location: `failure-mechanism.qmd:46 (code chunk)`
- Why it matters: Non-Windows or CI build hosts will not find LaTeX at this location, causing PDF render failures and breaking reproducibility.
- Suggested fix: Remove the hard-coded path tweak; document a portable TinyTeX installation step or rely on the system PATH.
- Evidence: First lines of the code block labelled `fig-three-regimes` set PATH to the above absolute directory.

### [MAJOR] Field-contamination history and 2 psig valve-reseat assertions are uncited.

- Category: `claim-evidence`
- Location: `failure-mechanism.qmd:1, 355`
- Why it matters: These statements anchor the root-cause narrative and the recommendation to remove the bag vent; without documentary backing the argument is persuasive but unverifiable.
- Suggested fix: Add citation keys or internal links to the shipping NCRs, inspection memos, and valve test reports that confirm (a) moisture/biological ingress on return and (b) the 2 psig reverse-differential reseat requirement.
- Evidence: Abstract and §Confirmed field failures claim “confirmed field failures” and “valve requires up to 2 psig reverse differential,” but no @cite or cross-reference follows either claim.

### [MAJOR] Baseline figure and representative-case table simulate a 20 °C cargo temperature, while the shipping envelope and screening equations use 40 °C as the worst case.

- Category: `logical-flow`
- Location: `failure-mechanism.qmd:46 (simulation call) vs §Temperature nomenclature`
- Why it matters: The illustrated “safe baseline” may not remain safe at the envelope extreme, potentially misleading readers about design margin.
- Suggested fix: Re-run the baseline and case studies at 40 °C, or insert a conspicuous note that the figure depicts nominal, not worst-case, conditions.
- Evidence: `simulate_cycle(..., T_cargo_C = 20.0, ...)`; §Temperature nomenclature states `T_hot = 40 °C` per spec.

### [MAJOR] Ambient pressure for 8 000 ft cabin altitude is inconsistent (75.26 kPa in §Transport Envelope vs 76.3 kPa in generated summary).

- Category: `source-of-truth`
- Location: `failure-mechanism.qmd:313 vs generated/PIR-SH-001_quasistatic_report_summary.md`
- Why it matters: All closed-form equations scale with ambient pressure; mismatched inputs propagate directly into design limits and case studies.
- Suggested fix: Adopt a single ISA-derived value (75 262 Pa) in both narrative and analysis code, then regenerate artifacts.
- Evidence: Transport-envelope table shows “75.26 kPa (0.743 atm)”; generated MD summary lists “0.753 × 1.01325 = 0.7630 bar abs”.

### [MAJOR] Narrative thresholds (14.11 L, 50.21 L, 102.11 L) differ from generated TSV values (15.28 L, 52.55 L, 109.19 L).

- Category: `source-of-truth`
- Location: `failure-mechanism.qmd:36 vs generated/PIR-SH-001_quasistatic_threshold_summary.tsv`
- Why it matters: Readers comparing prose to the downloadable data will see conflicting limits, undermining confidence and breaking automated regression tests that parse the TSV.
- Suggested fix: Re-run the MATLAB analysis and regenerate all TSV/MD artifacts with the 75 262 Pa input, or revert the narrative short-codes until regeneration is complete.
- Evidence: Session log lists updated thresholds; the live TSV preview still shows the pre-correction numbers.

## Residual Risks

- Python chunks depend on CoolProp and scienceplots but the build recipe does not declare these packages; future CI images may lack them.

## Sources Checked

- `_shared\_metadata.yml`
- `_shared\refs.bib`
- `projects\shipping\Reviews\Review-failure-mechanism-codex-2026-04-15.md`
- `projects\shipping\Reviews\Review-failure-mechanism-reasoned.md`
- `projects\shipping\Reviews\Review-failure-mechanism.md`
- `projects\shipping\SESSION_HANDOFF.md`
- `projects\shipping\_quarto.yml`
- `projects\shipping\failure-mechanism.qmd`
- `projects\shipping\generated\PIR-SH-001_quasistatic_case_summary.tsv`
- `projects\shipping\generated\PIR-SH-001_quasistatic_report_summary.md`
- `projects\shipping\generated\PIR-SH-001_quasistatic_threshold_summary.tsv`

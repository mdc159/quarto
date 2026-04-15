# Review: failure-mechanism.qmd

Target: `projects\shipping\failure-mechanism.qmd`

## Summary

The document renders, but several narrative and traceability gaps materially weaken its technical authority.  The largest risk is an unresolved contradiction about whether removing the bag vent already eliminates dependence on the unknown rigid volume V_fixed; the abstract and Section 12 still frame V_fixed as the "single critical unknown" while Sections 10 & 13 present vent-removal as a complete fix.  In addition, key safety and field-failure claims are uncited, hard-coded threshold numbers are not programmatically linked to the MATLAB/CoolProp outputs, and a few front-matter practices break reproducibility or cross-referencing.  No rendering blockers were found, but without the corrections below the main conclusion lacks a defensible chain of evidence.

## Findings

### [MAJOR] Statements about “confirmed field failures” and the check valve being “structurally incapable” lack citations or cross-references.

- Category: `claim-evidence`
- Location: `Abstract, middle paragraph`
- Why it matters: Safety-critical claims require verifiable evidence; without it the argument could be challenged in design reviews or audits.
- Suggested fix: Insert a citation to the failure-report memo or add a forward link to the section that summarizes field data and valve test results.
- Evidence: Abstract sentence: “Confirmed field failures are the observed consequence of this mechanism.” No [@citation] or figure/table reference follows.

### [MAJOR] Contradictory problem framing: abstract and Section 12 call V_fixed “the single critical unknown,” yet Sections 10 and 13 claim vent removal is unconditionally safe for any 20–120 L, eliminating the need to measure V_fixed.

- Category: `logical-flow`
- Location: `Abstract, Section 10 vs Section 12`
- Why it matters: Readers cannot tell whether additional measurement work is required, which drives schedule and funding decisions.
- Suggested fix: Choose one narrative: (a) keep vent-removal as the preferred fix and delete/retire Section 12 language, or (b) state clearly why V_fixed must still be measured even if vent removal is adopted.
- Evidence: Abstract: “…The single critical unknown is $V_{fixed}$ …”; Section 12: “The required next action is to measure V_fixed…”.  Review-failure-mechanism.md already flags this conflict.

### [MAJOR] Threshold values (e.g., 52.55 L non-negative limit) are hard-coded, not dynamically imported from generated/quasistatic_threshold_summary.tsv.

- Category: `source-of-truth`
- Location: `Summary – Closed-form thresholds`
- Why it matters: If the MATLAB or CoolProp model is updated, the report will silently drift out of sync, invalidating reproducibility.
- Suggested fix: Reference the TSV via quarto include or embed code that reads the file at render time, or add a version/hash note that locks the dataset.
- Evidence: Numbers in Summary match the TSV preview today, but there is no code chunk or include directive binding them.

### [MINOR] References `@eq-no-vent`, `@sec-upper-bound`, etc., may be undefined if labels changed.

- Category: `render-crossref`
- Location: `Summary – multiple inline refs`
- Why it matters: Broken links degrade navigation and may halt PDF rendering.
- Suggested fix: Run `quarto check` and add `{#label}` tags where needed.
- Evidence: Inline text contains `Eq. @eq-no-vent`, `Section @sec-upper-bound`, etc., but label definitions are not visible in provided snippets.

### [MINOR] `date: today` forces the date to refresh on every render, breaking `freeze:auto` caching.

- Category: `render-crossref`
- Location: `YAML front-matter`
- Why it matters: Unstable metadata causes unnecessary CI rebuilds and can create archival diffs that do not correspond to source changes.
- Suggested fix: Replace with an explicit ISO date or a manually set project parameter.
- Evidence: Front-matter shows `date: today`; shared _metadata.yml sets freeze:auto.

## Residual Risks

- Future model revisions could desynchronize additional hard-coded numbers beyond the closed-form thresholds.
- Other early sections may contain uncited thermodynamic assumptions not covered in this limited excerpt.

## Sources Checked

- `Reviews/Review-failure-mechanism.md`
- `SESSION_HANDOFF.md`
- `_shared/_metadata.yml`
- `_shared\_metadata.yml`
- `_shared\refs.bib`
- `failure-mechanism.qmd preamble and Summary`
- `projects/shipping/_quarto.yml`
- `projects/shipping/generated/quasistatic_threshold_summary.tsv`
- `projects\shipping\Reviews\Review-failure-mechanism.md`
- `projects\shipping\SESSION_HANDOFF.md`
- `projects\shipping\_quarto.yml`
- `projects\shipping\failure-mechanism.qmd`
- `projects\shipping\generated\quasistatic_case_summary.tsv`
- `projects\shipping\generated\quasistatic_report_summary.md`
- `projects\shipping\generated\quasistatic_threshold_summary.tsv`

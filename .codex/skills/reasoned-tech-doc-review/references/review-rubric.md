# Review rubric

## Severity

- `blocker`: The document makes a materially false, unsafe, or self-defeating
  claim; a required equation or assumption is invalid; or the render path is
  broken enough that the document cannot be trusted or published.
- `major`: The document has a meaningful contradiction, unsupported conclusion,
  units drift, or artifact mismatch that changes the engineering conclusion or
  weakens traceability.
- `minor`: The issue does not change the main conclusion but still needs
  correction for clarity, maintainability, or publication quality.

## Categories

- `claim-evidence`
  - conclusion is not supported by the cited table, figure, artifact, or text
  - evidence exists but the prose overstates it
- `equation-units`
  - wrong unit conversion, mixed pressure basis, hidden temperature basis shift,
    invalid equation regime, or conservative bound described incorrectly
- `logical-flow`
  - section-to-section contradiction, missing intermediate step, or investigation
    narrative that conflicts with later recommendations
- `render-crossref`
  - broken labels, fragile Quarto syntax, missing figure alt text, or output
    structure likely to fail HTML or PDF render
- `source-of-truth`
  - duplicated engineering logic, drift from generated artifacts, or ignoring the
    declared external computational source
- `handoff-state`
  - review-critical assumptions or dependencies are missing from handoff or
    structured state

## Domain heuristics

### Thermodynamics and units

- Pressure basis must stay explicit: absolute vs gauge, bar vs kPa vs psi.
- Temperature basis must stay explicit: K vs C when used in proportional
  relations.
- Ideal-gas claims must stay inside the stated envelope or call out the
  approximation and cross-check.
- A conservative upper bound must really be an upper bound under the stated
  assumptions.

### Narrative contradictions

- Flag when the document says it stops at root cause, but later sections prove or
  recommend a design response.
- Flag when a "single critical unknown" is declared after a later section already
  proves the outcome is insensitive to that unknown.
- Flag when a summary or conclusions section lags behind later inserted analysis.

### Evidence discipline

- Prefer the generated artifact on disk over remembered values in prose.
- If a table and an equation disagree, the discrepancy is at least `major` until
  the source of truth is explicit.
- If a claim depends on a figure trend, check that the caption and plotted values
  actually support the statement.

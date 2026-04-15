# Review: failure-mechanism.qmd

Target: `projects\shipping\failure-mechanism.qmd`

## Summary

The document cannot render or be reviewed coherently in its present form.  Un-fenced code, un-closed callout blocks and dozens of duplicate dash-only headings create immediate Quarto/Pandoc parsing failures (blockers).  Even where the file does compile, the engineering trace is broken: key pressure-volume thresholds, cabin-pressure values and temperature sweeps disagree between the prose, LaTeX equations, YAML variables and the generated TSV artefacts.  Core causal claims (field contamination history, valve cracking/re-seat capability, seal qualification) remain uncited, so the argument for vent removal is not yet evidence-traceable.  A focused clean-up of rendering structure, single-source variable wiring, and citation insertion is required before numerical or design conclusions can be trusted.

## Findings

### [BLOCKER] Pressures and temperatures mix absolute, gauge and Celsius without declaration; over-pressure bound compares absolute (ideal-gas) result to gauge relief set-point.

- Category: `equation-units`
- Location: `Eq. pint-bound / dp-bound and surrounding text`
- Why it matters: 0.5 bar(g) relief vs 0.33 bar(abs) bound comparison is meaningless; safety margin may be overstated.
- Suggested fix: State units explicitly (Kelvin, absolute pressure) and convert before comparison; update tables/captions accordingly.
- Evidence: Eq. ΔP = Pseal·T/Tseal – Pamb followed by table comparing to “0.5 bar g”.

### [BLOCKER] Call-out blocks and fenced divs opened with “:::” are not closed.

- Category: `render-crossref`
- Location: `lines 352–377 and elsewhere`
- Why it matters: Pandoc stops parsing at the first unmatched fence, so the remainder of the document renders as literal text or compilation aborts.
- Suggested fix: Ensure every “::: class” has a matching terminating “:::”.
- Evidence: `::: callout-important` opened at line 352; no closing fence before next heading.

### [BLOCKER] Python code appears outside ```{python}``` fences; several closing ``` are unmatched.

- Category: `render-crossref`
- Location: `many code regions (e.g. constants block line 95, phase colours line 214, surface plot line 1195)`
- Why it matters: Quarto treats these lines as text; later chunks that depend on the variables raise `NameError`, halting render and invalidating embedded figures/tables.
- Suggested fix: Wrap every executable region in a properly opened/closed code chunk; run `quarto check` to verify.
- Evidence: `phase_colors = [...]` is plain text; `ax2.remove()` appears without an opening fence.

### [BLOCKER] Dash-only headings are reused as level-1 section titles.

- Category: `render-crossref`
- Location: `multiple (e.g. lines 93, 95, 185, 198, 217)`
- Why it matters: Quarto generates identical anchors ("section", "section-1" …) causing TOC clutter, anchor collisions and broken cross-references; several of these headings contain no content, breaking narrative structure.
- Suggested fix: Replace each "# --------" with either a descriptive unique heading or a Markdown horizontal rule ("---").
- Evidence: Outline lists >15 sections titled "# ---------------------------------------------------------------------------".

### [BLOCKER] Numerical limits (α = 1.4381, no-vent 14.11 L, return 50.21 L) shown in prose/variables disagree with authoritative TSV (α = 1.4186, no-vent 15.28 L, return 52.55 L).

- Category: `source-of-truth`
- Location: `Threshold derivations vs generated TSV`
- Why it matters: Design acceptance criteria change by >1 L; reviewers cannot know which limit to enforce.
- Suggested fix: Regenerate the TSV/figures with the corrected ISA pressure or revert YAML edits until recalculation is complete; bind equations to the same data source.
- Evidence: `PIR-SH-001_quasistatic_threshold_summary.tsv` preview vs LaTeX numbers in §Threshold 1 and YAML `_variables.yml`.

### [MAJOR] Valve cracking (2 psig) and reseat (>2 psig) requirements are asserted but labelled “citation pending”.

- Category: `claim-evidence`
- Location: `abstract & findings FND-SH-006/007`
- Why it matters: Valve incapability drives the irreversible mass-loss mechanism; unsupported specs undermine the argument for vent removal.
- Suggested fix: Add vendor datasheet or bench-test citation; update Findings to include reference.
- Evidence: FND-SH-006 disposition: “citation pending (Mike has the document)”.

### [MAJOR] Field-failure and contamination assertions have no citation to inspection reports or test records.

- Category: `claim-evidence`
- Location: `abstract & §Field Contamination History`
- Why it matters: These events are the primary motivation for the analysis; without traceable evidence the causal chain is speculative.
- Suggested fix: Insert citations (e.g. failure report IDs, inspection memos) or attach summaries in an appendix and cross-reference.
- Evidence: Abstract: “confirmed field failures”; §Field Contamination History provides narrative only.

### [MAJOR] Text claims 0.21 bar(g) < ½ of relief, but installed valve cracks at 2 psig = 0.138 bar(g).

- Category: `claim-evidence`
- Location: `§Upper Bound on Overpressure and table 80 °C row`
- Why it matters: Over-pressure margin is mis-stated by ≈50 %; could reverse recommendation if correct limit is lower.
- Suggested fix: Clarify which device (circuit relief vs Swagelok vent) the comparison targets; adjust numeric claim or units.
- Evidence: Sea-level table row 80 °C: 0.207 bar(g); earlier sections define vent cracking 0.138 bar(g).

### [MAJOR] Equation IDs placed on a separate line (` $$ {#eq-...}`) instead of same line as closing delimiter.

- Category: `equation-units`
- Location: `math blocks throughout (e.g. eq-vtot)`
- Why it matters: Pandoc drops the ID; all `@eq-...` references resolve to ‘??’, breaking cross-links.
- Suggested fix: Move `{#eq-id}` to the same line as “$$”.
- Evidence: `$$V_{tot}=...$$` newline `{#eq-vtot}` pattern repeated in model section.

### [MAJOR] Seal-up and gas constants are defined three times with literals; one uses old 76.3 kPa cabin pressure.

- Category: `logical-flow`
- Location: `duplicate constants blocks lines 94, 904, 909`
- Why it matters: Depending on execution order, different simulations see different constants, compromising reproducibility.
- Suggested fix: Create a single authoritative constants module or import YAML variables everywhere; delete duplicates.
- Evidence: Code blocks at lines 95, 904 and 909 each assign `P_SEAL_PA`, `V_BAG_MAX_L`, etc.

### [MAJOR] Calls ideal-vent case the “worst-case valve”, which is conceptually inverted.

- Category: `logical-flow`
- Location: `§Bag Volume Sensitivity caption and bullet 1`
- Why it matters: Terminology confusion may mislead reviewers about conservative assumptions.
- Suggested fix: Rephrase as “most permissive valve (opens at 0 psig)” or similar.
- Evidence: Caption: “ideal-vent column … represents the worst-case valve”.

### [MAJOR] Several labels are referenced but not defined in the file, producing unresolved “??”.

- Category: `render-crossref`
- Location: `references to @tbl-vent-valve, @sec-upper-bound, etc.`
- Why it matters: Broken links are a PDF build stopper and obscure provenance of critical specs.
- Suggested fix: Add the missing labelled elements or update references to existing IDs; run `quarto check` to list unresolved refs.
- Evidence: Closure table row cites @tbl-vent-valve but no such table in outline.

### [MAJOR] Parametric sweep stops at 30 °C but conclusions claim coverage of the 10-40 °C transport envelope.

- Category: `source-of-truth`
- Location: `temperature sweep definition lines 1088–1092 vs spec tables`
- Why it matters: Un-analysed 30-40 °C range could shift vent/re-seat margins; recommendation to remove vent lacks bounding evidence.
- Suggested fix: Extend `T_cargo_arr` to 40 °C or qualify conclusions as provisional; regenerate figures.
- Evidence: `T_cargo_arr = np.linspace(5, 30, 40)`; Summary and Decision sections state envelope up to 40 °C.

### [MINOR] CoolProp called with Celsius temperatures.

- Category: `equation-units`
- Location: `simulate() definition (line 1000 approx.)`
- Why it matters: CoolProp expects Kelvin; pressures, densities and ∆P outputs are off by ~70 %, invalidating parametric surfaces if not converted elsewhere.
- Suggested fix: Convert all temperatures to Kelvin before `AS.update`; document expected units.
- Evidence: `build_profile` returns `T_gas` created by `T_cargo_C+273.15` *only for some segments*; simulate() later passes `T_gas[i]` directly, but inputs like `T_cargo_C` are in °C as per docstring.

### [MINOR] Shortcodes inside `fig-alt` may not expand, leaving raw template text in HTML alt attributes.

- Category: `render-crossref`
- Location: `fig-alt attributes with {{< var >}}`
- Why it matters: Breaks accessibility and signals render errors.
- Suggested fix: Move variable-derived text into caption; keep alt text literal or populate via code.
- Evidence: `fig-alt="… {{< var ideal-return-threshold-l >}} …"` in §Results figure.

## Residual Risks

- 40 °C transport-envelope data are still missing; extending the sweep could expose new failure regions.
- Even after code-fence repair, multiple constant duplicates may shadow each other, causing silent numeric drift depending on execution order.
- If valve datasheet proves a lower reseat pressure than assumed, the non-return-pressure mechanism may change, invalidating the vent-removal recommendation.
- Unbalanced gauge/absolute pressure handling may persist in auxiliary scripts and figures after headline fixes.

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

# Output schema

Use this shape for structured review artifacts and for consistency between human
reviews and the OpenAI-backed reviewer.

## Top-level fields

- `summary`: short review summary in prose
- `findings`: ordered list of findings
- `residual_risks`: flat list of risks, missing checks, or unresolved
  dependencies
- `sources_checked`: flat list of files or artifacts inspected during the review

## Finding object

- `severity`
  - one of `blocker`, `major`, `minor`
- `category`
  - one of `claim-evidence`, `equation-units`, `logical-flow`,
    `render-crossref`, `source-of-truth`, `handoff-state`
- `location`
  - section title, equation label, figure label, table label, or another precise
    locator
- `issue`
  - what is wrong
- `why_it_matters`
  - why the issue changes trust, correctness, or publication readiness
- `suggested_fix`
  - concrete next action, not just "clarify"
- `evidence`
  - the inspected fact supporting the finding

## Example shape

```json
{
  "summary": "The thermodynamic argument is mostly sound, but one section-level contradiction changes the document's stated next step.",
  "findings": [
    {
      "severity": "major",
      "category": "logical-flow",
      "location": "Section 12 vs Section 10",
      "issue": "The document says it stops at root cause, but a later section proves a design response is already sufficient.",
      "why_it_matters": "The current framing misstates what the report already established and weakens the closeout logic.",
      "suggested_fix": "Rewrite the later summary so it distinguishes root-cause closure from procedural verification.",
      "evidence": "Section 12 says no design solution is proposed, while Section 10 proves vent removal is safe across the stated volume envelope."
    }
  ],
  "residual_risks": [
    "PDF rendering was not checked in this review pass."
  ],
  "sources_checked": [
    "projects/shipping/failure-mechanism.qmd",
    "projects/shipping/generated/quasistatic_threshold_summary.tsv"
  ]
}
```

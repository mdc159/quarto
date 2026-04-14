# Next Session Action

Read the working notes section at the bottom of `failure-mechanism.qmd` (@sec-working-notes) — it captures the strategic argument structure and remaining work plan. Mike is running this through an o1 review. When he returns, he will have:

1. **Review feedback** on the working notes and argument strategy (likely dropped as a new file in `Reviews/`)
2. **V_fixed estimate** from the CAD model — module volumes + tubing estimate
3. Possibly fill port stack-up details for FND-SH-011

**What to do:**
- Read the review feedback and triage it (address / skip / defer), same pattern as the `Reviews/review-rename.md` triage from this session
- If V_fixed data is provided, plug it into the screening map: compare against the 14.1 L (bag saturation), ~68 L (venting onset), and ~102 L (return underpressure) thresholds in @tbl-thresholds. Update the document with the result.
- If fill port details are provided, update FND-SH-011 with the exact stack-up geometry
- Render HTML + Word after edits and confirm zero warnings

---

# Session State

**Last updated:** 2026-04-14
**Branch:** `shipping/v2-transit-model` (5 commits ahead of master, plus uncommitted edits from this session)
**Status:** PIR-SH-001 v2.1 — review-driven edits + cracking pressure paradox + working notes added. Renders clean (HTML + Word). Awaiting o1 review and V_fixed data from Mike.

# What was accomplished (2026-04-14, session 2)

### Handoff workflow convention established
- Created `feedback_session_handoff.md` in memory — SESSION_HANDOFF.md now starts with a "Next Session Action" block that the next Claude can execute via `/catchup` without Mike re-explaining
- Updated MEMORY.md index

### Review triage and edits from `Reviews/review-rename.md`
- **Summary** — now leads with V_fixed as the critical unknown
- **INV-1 results** — added quantitative leak rate gap note and follow-up action
- **Assumption #5** — explicitly cross-refs the helium leak check contradiction; explains why model keeps the ideal assumption
- **Assumption #6** — acknowledges transient effects as stated simplification
- **New Assumption #8** — bag stiffness acknowledged and dismissed for thin foil
- **New section: Cracking Pressure Paradox** (@sec-paradox) — low cracking pressure loses mass through valve; high cracking pressure loses mass through distributed seals; no winning operating point
- **FND-SH-010** — paradox finding (INV-2)
- **FND-SH-011** — fill port design flaw finding (INV-1, preliminary — Mike to verify stack-up)
- **traceability.yml** — updated with FND-SH-010 and FND-SH-011

### Working notes section added
- `@sec-working-notes` — internal planning section (unnumbered, callout-warning marked)
- Escape hatch table: four audience objections with how the PIR closes each
- Remaining data table: V_fixed, leak-down test, fill port details
- Closure logic: two branches depending on where V_fixed lands
- Implied requirements preview (five proto-REQs for the future EPS)

### Renders
- HTML and Word both render clean, zero warnings
- Output at `_output/failure-mechanism.{html,docx}`

# Known issues / next steps

1. **o1 review pending** — Mike is sending the working notes through OpenAI o1 for chain-of-thought review
2. **V_fixed from CAD** — Mike is working on module volume estimates
3. **Fill port stack-up** — FND-SH-011 details are preliminary (marked with HTML comment)
4. **Leak-down test** — stretch goal; would bound distributed seal leak rate
5. **Uncommitted edits** — this session's changes to `failure-mechanism.qmd` and `traceability.yml` are not yet committed
6. **Notebook execution outputs** — still uncommitted from previous session
7. **Conclusions section** — may need updating after the paradox and new findings are validated. Currently mentions only two vulnerability paths; now there are three (thermodynamic, port leakage, fill port design).
8. **Appendix A failure modes table** — should be updated to include the paradox (FND-SH-010) and fill port (FND-SH-011)

# Key conventions

- **Render priority:** Word > HTML. Word -> PDF is the delivery path.
- **Writing style:** Active voice, impersonal tone, present tense
- **Quarto cross-refs in tables:** Use plain `FND-SH-nnn` text, not `@fnd-sh-nnn` (Citeproc warnings)
- **Working section:** @sec-working-notes is marked `.unnumbered` and wrapped in a warning callout. Remove before issuing the document.
- **Review workflow:** Reviews go in `Reviews/NNN-slug.md` + `.response.md` pairs

# Primary working files

| File | Purpose |
|---|---|
| `failure-mechanism.qmd` | PIR-SH-001 (source of truth) |
| `traceability.yml` | Finding/investigation registry |
| `_output/failure-mechanism.docx` | Rendered Word output |
| `_output/failure-mechanism.html` | Rendered HTML output |
| `Reviews/review-rename.md` | External review (processed this session) |
| `Reviews/001-v1-narrative-reframe.*` | v1 review + response |
| `output/jupyter-notebook/nitrogen-shipping-coolprop-cycle.ipynb` | Notebook (2 PSIG baseline) |
| `SESSION_HANDOFF.md` | This file |

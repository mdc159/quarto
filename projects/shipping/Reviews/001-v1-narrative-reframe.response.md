# Response to Review 001: Narrative Reframe

**Review date:** 2026-04-13
**Response date:** 2026-04-13
**Branch:** `shipping/v2-transit-model`
**Baseline commit:** `a089c80` (master checkpoint before changes)

## Review findings and disposition

### 1. Section 12 contradicts Section 10 (Major)
**Reviewer:** Section 12 says "this report does not propose a design solution" but
Section 10 explicitly proposes removing the bag vent.
**Disposition:** Accepted. Section 12 was a relic from before Section 10 was added.
Both sections are removed in v2; the document is reframed as an exploratory transit
model, not a solution proposal.

### 2. Cabin altitude pressure inconsistency (Moderate)
**Reviewer:** 76.3 kPa in Table 1 vs. 75.26 kPa (true ICAO) in Section 10.
Shifts safe-volume thresholds downward.
**Disposition:** Accepted. v2 will standardize on 75.26 kPa (ICAO standard
atmosphere at 2438 m / 8000 ft).

### 3. Strengthen overpressure bound argument (Minor)
**Reviewer:** Note that the rigid-body assumption ignores bag compliance headroom,
making the analytical bound conservative.
**Disposition:** Deferred. The overpressure bound section (Section 10) is not
carried forward into v2. The v2 narrative focuses on the transit model with the
2 PSIG bag vent as-built. The EU 0.5 bar relief valve is out of scope for now.

## Additional issues identified by Mike (not in the written review)

### 4. Phantom "design review" framing
**Issue:** Summary and Section 5 reference a prior "high-pressure design review"
that never happened. This was fabricated context from the AI-generated source draft.
**Disposition:** Removed entirely in v2. The document no longer frames itself as
responding to a prior review.

### 5. Narrative direction change
**Decision:** Reframe the entire document as exploratory. Model what happens during
transit with the actual 2 PSIG bag vent (ideal valve function). The system as
designed is a one-way nitrogen ratchet -- the document demonstrates this, without
proposing solutions or discussing the EU 0.5 bar relief.

## Changes made

1. Archived `failure-mechanism.qmd` to `source/failure-mechanism-v1.qmd`
2. Notebook baseline changed from `P_crack = 0 psig` to `P_crack = 2 psig`
3. Scenario renamed from `debatable_baseline` to `nominal_baseline`
4. Fresh `failure-mechanism.qmd` written with clean narrative (system, transit,
   model, result)
5. Abstract deferred -- document is exploratory, not a final report

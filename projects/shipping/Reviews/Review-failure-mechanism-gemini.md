# Technical Review: Shipping Failure Mode Document (failure-mechanism.qmd)
**Review Date:** 2026-04-15  
**Reviewer:** Gemini Technical Review  
**Document:** projects/shipping/failure-mechanism.qmd

## Summary
The failure-mechanism document presents a rigorous thermodynamic analysis of return-leg underpressure as the root cause of nitrogen purge contamination in optical assemblies during air transport. The document successfully establishes the governing physics and proposes vent removal as a design solution. However, three critical gaps remain unresolved between the single-flight model evidence and the multi-leg operational reality: (1) the parametric sweep is limited to 30°C while shipping allows 40°C, (2) the valve non-reseat finding (FND-SH-006 to FND-SH-008) is acknowledged but not fully integrated into the multi-leg failure analysis, and (3) the multi-leg recommendation lacks quantitative proof that underpressure does not occur across consecutive flight legs.

## Critical Findings

### C1: Parametric Sweep Temperature Gap Contradicts Recommendation Scope
**Location:** @sec-parametric-surface, @tbl-max-safe-volume caption, @sec-validity-conditions  
**Issue:** The parametric boundary sweep in @fig-failure-boundary and @tbl-max-safe-volume covers only T_cargo = 5–30°C, explicitly noted as "sweep limit" in the callout-note after @sec-parametric-surface. The shipping specification (@tbl-shipping-spec) permits up to 40°C. The recommendation to remove the bag vent in @sec-decision-status does not delineate the scope: it is presented as universally valid ("safe at any volume under PED relief") but the boundary evidence only covers two-thirds of the specified envelope. While the analytical overpressure bound (@eq-t-relief) technically extends to 40°C, the failure boundary (ΔP = 0 contour) may lie between 30 and 40°C for some rigid volumes. Extrapolation is not rigorously supported.  
**Recommendation:** Either (a) extend the parametric sweep to the full 10–40°C envelope specified in @tbl-shipping-spec, or (b) explicitly scope the vent-removal recommendation to 5–30°C with a caveat that 30–40°C requires separate evaluation.

### C2: Multi-Leg Accumulation Not Modeled; Recommendation Span Is Unclear
**Location:** @sec-decision-status (conclusions items 7–8), FND-SH-009, FND-SH-010, @sec-closure  
**Issue:** The document explicitly acknowledges multi-leg failure modes in FND-SH-009 and FND-SH-010: "Shipments routinely involve multiple flight legs; each leg is an additional venting event" and "The single-flight-cycle model does not capture multi-leg cumulative mass loss." Item 8 of conclusions claims "vent removal remains safe from an overpressure standpoint across multiple legs." This statement is technically true and uses the restrictive qualifier "from an overpressure standpoint" (meaning the 0.5 bar relief will not open per leg cycle). However, the design recommendation in @sec-decision-status does not explicitly restrict vent removal to single-leg scenarios. A multi-leg shipment where the valve never reseats after leg 1 (per FND-SH-008) creates a direct open path for bidirectional gas exchange on leg 2+ that is outside model scope. Item 11 of conclusions says "formal closure requires @sec-closure," but @sec-closure lists "Multi-leg" nowhere—only single-leg items.  
**Recommendation:** Clarify whether vent removal is recommended for single-leg or multi-leg operations. If multi-leg, provide either a separate multi-leg underpressure bound or state this as an open condition. Document the multi-leg valve-reseat gap explicitly in the closure table.

### C3: Valve Reseat Assumption Breaks Down in Multi-Leg Scenarios Without Derivation
**Location:** FND-SH-006, FND-SH-007, FND-SH-008, @sec-review-assumptions  
**Issue:** The model assumes the valve closes after venting and remains closed during the return leg. FND-SH-006 states the valve "requires up to 2 psig reverse differential to achieve full closure." FND-SH-007 and FND-SH-008 find that the single-flight model "produces maximum return-leg backpressure below 2 psig across the full operating envelope" for the 2 psig valve case, concluding the valve "remains open after first cracking." For a two-leg shipment: 
  - Leg 1: valve cracks, stays open, bag remains at max volume, nitrogen vents
  - Leg 2 ascent/cruise: bag expands from full (not from 11 L initial) into a valve that is already open
  - Leg 2 return: the bag collapses into open valve → direct path to ambient with no valve barrier

The document cites @sec-review-assumptions as a known non-conservative assumption but provides no path to formal closure. The question "what happens to the pressure profile when the valve is stuck open for leg N+1?" is not answered.  
**Recommendation:** Add a multi-leg valve-state analysis to @sec-results, or restrict the vent-removal recommendation to proven single-leg operations with a multi-leg uncertainty callout.

## Major Findings

### M1: V_fixed Estimate (35 L) Remains Informal; Circular Logic in Thresholds
**Location:** FND-SH-003, @sec-critical-unknowns, @sec-decision-status  
**Issue:** The rigid volume is stated as "conservatively estimated at approximately {{< var v-fixed-l >}} L." FND-SH-003 explicitly marks this "open until traceable measurement confirms." The estimate is used as the anchor point in @tbl-cases (marked with ~) and in the problem framing throughout. The recommendation to remove the vent states it is "safe at any volume under PED relief" (@sec-decision-status), which is technically true but creates subtle circular reasoning: (1) the 35 L estimate is between the vent thresholds → (2) recommend vent removal because it's safe at any volume → (3) therefore 35 L is fine regardless of the estimate. The circularity is not harmful (the vent-removal recommendation is overpressure-safe at any volume per @fig-failure-boundary), but it creates an appearance of incompleteness. If the actual rigid volume is 28 L (below no-vent threshold), the vented concept avoids venting entirely—a major finding omitted due to lack of traceable measurement.  
**Recommendation:** Complete the traceable V_fixed measurement before finalizing the document, or add a sensitivity table showing how the failure boundaries shift if V_fixed is ±3 L from the 35 L estimate.

### M2: Bibliography and Regulatory Standard Citations Are Incomplete
**Location:** @tbl-vent-valve (Swagelok 6L-CW4VR4-P spec), @sec-validity-conditions (FAA 14 CFR 25.841, PED 2014/68/EU)  
**Issue:** The document references critical regulatory and equipment standards without formal bibliography entries: (a) Swagelok valve datasheet (FND-SH-006 attribution "manufacturer specification" with no cite key), (b) FAA 14 CFR 25.841 (cabin altitude limit), (c) PED 2014/68/EU (European pressure equipment directive 0.5 bar relief), (d) ICAO standard atmosphere model. None of these appear in refs.bib. The valve reseat specification (2 psig) in @tbl-vent-valve is cited but traced to a pending external document ("citation pending" per SESSION_HANDOFF.md). Readers cannot verify or trace these anchors in the current bibliography.  
**Recommendation:** Add BibTeX entries for (a) Swagelok product datasheet, (b) FAA 14 CFR 25.841, (c) PED 2014/68/EU, (d) ICAO Standard Atmosphere; ensure each is populated with verifiable publication/access information before final review sign-off.

### M3: Unit and Pressure Notation Ambiguity in Critical Equations
**Location:** @eq-alpha, @eq-pint-bound, @eq-dp-bound, prose narrative  
**Issue:** Pressures are inconsistently labeled as absolute or gauge throughout the equations. @eq-alpha uses $P_{seal}$ and $P_{low}$ without explicit statement these are absolute pressures. @eq-pint-bound uses $P_{seal}$ and @eq-dp-bound subtracts $P_{amb}$ from the result, implying both are absolute. However, the descriptive prose in @sec-tarmac-bound states "overpressure simplifies to ΔP_max,SL = P_seal(T_tarmac/T_seal − 1)," which is correct only if P_seal is absolute. A reader unfamiliar with context might interpret P_seal as gauge pressure (common notation in pressure-vessel discussions), leading to nonsensical results. The document uses "bar" and "bar gauge" almost interchangeably without bold distinction; "psig" appears in some places but not others.  
**Recommendation:** Add a notation section early in the main text (after @sec-system) clarifying that P_amb, P_seal are absolute; ΔP is always gauge (internal minus ambient); and state consistently "gauge pressure" vs. "absolute pressure" at first use in each major section.

### M4: Seal-Up Temperature Sensitivity Not Explores; Risk for Field Variation
**Location:** @sec-validity-conditions, @eq-alpha, @eq-pint-bound  
**Issue:** The document assumes seal-up at "approximately 20 °C" and builds all thresholds on $\alpha$ which depends on T_seal in @eq-alpha. Manufacturing facilities may seal units at 15°C (winter) or 25°C (summer). A change in seal-up temperature to 25°C shifts α from 1.4381 to ~1.41, which shifts the no-vent threshold from 14.11 L to approximately 14.3 L (small effect) but shifts the ideal-return threshold from 50.21 L to approximately 51 L. The coupling is not negligible and is not quantified. If some units are sealed at 25°C and others at 15°C, the thresholds apply differently to different batches, and the "conservative estimate" of $V_{fixed}$ = 35 L may not be conservative for all seals.  
**Recommendation:** Add a brief parametric table showing no-vent and return thresholds at T_seal = 15, 20, 25, 30 °C; quantify the field-variation sensitivity and state whether 20 °C is the actual controlled set-point or a nominal assumption.

## Minor/Stylistic Findings
*(Summary: Addressed terminology in Regime 2, caption mismatch in @fig-three-regimes, missing standards in bib, and possible rendering artifact in a table).*

## Residual Risks
1. **Multi-leg operational scope insufficiently defined:** Model only proves single-flight safety.
2. **Valve non-reseat creates open path on leg 2+:** Never reseats during single-flight return. 
3. **Parametric boundary gap at 30–40°C:** Recommendation based on evidence that covers 5–30°C. 

## Sources Checked
- projects/shipping/failure-mechanism.qmd
- projects/shipping/_quarto.yml
- _shared/_metadata.yml
- projects/shipping/SESSION_HANDOFF.md
- projects/shipping/generated/PIR-SH-001_quasistatic_report_summary.md
- projects/shipping/generated/PIR-SH-001_quasistatic_threshold_summary.tsv
- projects/shipping/generated/PIR-SH-001_quasistatic_case_summary.tsv
- _shared/refs.bib
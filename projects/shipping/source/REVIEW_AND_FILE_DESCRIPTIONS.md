# Shipping Failure Mode: Review and File Descriptions

## The Problem

A manifolded optical assembly filled with high-purity nitrogen must be shipped by air. The assembly consists of multiple sealed aluminum optical modules interconnected by PFA tubing and intake/exhaust manifolds, all forming a single connected gas volume. The nitrogen atmosphere must remain at nonnegative gauge pressure (at or above ambient) at all times; if internal pressure ever drops below ambient, the many joints and seals in the assembly become inward leakage paths, allowing atmospheric contamination into the high-purity nitrogen space. Even trace contamination is unacceptable.

The current shipping concept uses two passive elements to manage pressure excursions during transport:

1. **A foil compliance bag** -- a flexible reservoir that can expand and contract between 0 and some maximum volume (nominally 22 L), providing geometric compliance with essentially zero spring force.
2. **An outward-only check/vent valve** -- permits nitrogen to escape if internal pressure exceeds ambient, but prevents ambient air from flowing inward.

## The Failure Mechanism

The failure is **not** outbound overpressure. The failure is **return-leg underpressure** following irreversible nitrogen mass loss. The mechanism proceeds in three regimes:

### Regime 1: Bag absorbs expansion (safe)

During ascent and heating (ambient pressure drops from ~1.013 bar at sea level to ~0.763 bar at 8,000 ft cabin equivalent; temperature rises from 20C to 40C), the nitrogen expands. As long as the bag has remaining headroom, it absorbs the volume change and internal pressure tracks ambient. No harm occurs.

### Regime 2: Bag saturates, nitrogen vents (irreversible loss)

If the rigid system volume is large enough relative to the bag, the bag reaches its maximum volume before the outbound peak. At that point, continued expansion drives internal pressure above ambient. The outward-only valve opens and nitrogen escapes. This is a **one-way thermodynamic event**: the mole inventory `n` has been permanently reduced. Even if the valve closes perfectly and never leaks inward, the original gas mass is gone.

### Regime 3: Return leg, bag collapses, sub-atmospheric (failure)

On descent and cooling, ambient pressure rises and temperature drops. The bag contracts. If the bag fully collapses to zero volume, the remaining nitrogen must fill only the rigid connected volume V_fixed. If the retained nitrogen inventory is insufficient to produce at least ambient pressure in that volume at the return temperature, then:

    P_internal = n_retained * R * T_return / V_fixed < P_ambient

The system is sub-atmospheric. The outward-only valve is irrelevant at this point -- it only prevents inward flow through itself. The actual ingress path is the distributed seal and joint network of the manifolded assembly. Atmospheric contamination is now thermodynamically favored.

### Why this is non-obvious

A design review focused only on the outbound leg (peak overpressure, valve sizing, bag expansion capacity) will conclude the system is adequate. The failure only appears when you trace the **full round-trip thermodynamic cycle** and account for the irreversible nitrogen mass loss. The bag is not a source of gas; it is only a temporary volume buffer. Once it has done its job on the outbound leg and the valve has vented nitrogen, it cannot restore the lost mass on the return.

## Key Analytic Thresholds

Two closed-form expressions govern the design space:

**1. Outbound no-vent threshold** -- the largest rigid volume that avoids any venting:

    V_fixed <= (V_bag,max - alpha * V_bag,init) / (alpha - 1)

where `alpha = (P_seal / P_low) * (T_hot / T_seal)`. For the default parameters (sea-level seal-up at 20C, 8,000 ft cabin, 40C hot case, 22 L max bag, 11 L initial fill), this limit is approximately **15.2 L**.

**2. Return-leg sub-atmospheric threshold** -- the smallest rigid volume that goes sub-atmospheric after venting:

    V_fixed > V_bag,max / (gamma - 1)

where `gamma = (P_return * T_peak) / (P_peak * T_return)`. For the same parameters with ideal venting to ambient at the outbound peak, this limit is approximately **52.4 L**.

The plot in `example_volume_sweep.png` shows the relationship directly: the worst-case gauge pressure is flat at zero for small rigid volumes (the bag handles the excursion without venting), then drops steeply as rigid volume increases past the threshold where venting becomes unavoidable and the return-leg mass deficit grows.

## The Critical Unknown

The single most important parameter is **V_fixed** -- the total rigid nitrogen volume of the interconnected optical modules, tubing, and manifolds, excluding the bag. If V_fixed is below ~15 L, the current bag concept works without venting. If V_fixed exceeds ~52 L, return-leg sub-atmospheric conditions are unavoidable. Between those bounds is a grey zone depending on exact initial fill, temperature extremes, and vent threshold.

---

## File Descriptions

### 1. `Physics_of_the_Shipping_Failure_Mode.md`

**Role: Conceptual explanation of the failure mechanism**

A prose document written for engineering communication. It walks through the three-regime failure mechanism in physical terms: gas expansion and compliance absorption (Regime 1), bag saturation and irreversible nitrogen venting (Regime 2), and return-leg bag collapse with sub-atmospheric internal pressure (Regime 3). It derives the governing ideal-gas relations and the critical dependence of return pressure on the ratio of compliance volume to rigid volume. It emphasizes the key insight: the outward-only valve is not the failure point; the failure is that the bag is a volume buffer, not a mass reservoir, and once nitrogen is lost, no passive one-way device can restore it.

This document is intended for readers who need to understand *why* the failure occurs without running the model.

### 2. `Thermodynamic_Failure_Mechanism_Subsection.docx`

**Role: Formal engineering report insert**

A Word document formatted as a standalone subsection for an engineering report. It presents the same failure mechanism as the markdown file but in formal notation with numbered equations (Equations 1-16). It defines all variables explicitly, derives the two critical screening relations (Equation 10 for the outbound no-vent limit, Equation 16 for the return-leg underpressure limit), and provides a physical interpretation section. The recommended concluding sentence summarizes the entire argument in one paragraph. This is the document that would be inserted into a formal design review or failure analysis report.

The .docx and .md physics documents overlap substantially in content but serve different audiences: the .md is for working engineers and AI agents; the .docx is for formal documentation.

### 3. `nitrogen_shipping_failure_notes.md`

**Role: User guide and quick reference for the simulation scripts**

A concise set of notes explaining what the model is, what assumptions it makes, what the core logic sequence is, and how to run the Python and MATLAB scripts. It lists the two analytic thresholds with their formulas and default numerical values, identifies the most important parameters to vary (V_fixed, V_bag_init, V_bag_max, P_vent_gauge), and explains how to interpret the output: if the pressure differential `P_internal - P_ambient` ever goes negative, the system has failed regardless of valve behavior.

### 4. `nitrogen_shipping_failure_model.py`

**Role: Python implementation of the quasi-static simulation**

A self-contained Python script (numpy + matplotlib) that:

- **`build_shipping_profile()`** -- generates a piecewise-linear 36-hour shipping pressure/temperature profile: ramp from sea level/20C to altitude/40C over 8 hours, hold for 8 hours, ramp back over 8 hours, hold at sea level/20C.
- **`analytic_threshold_no_vent()`** -- computes the closed-form maximum V_fixed that avoids outbound venting.
- **`analytic_threshold_negative_return()`** -- computes the closed-form minimum V_fixed that produces sub-atmospheric return pressure after venting.
- **`simulate_case()`** -- steps through the profile quasi-statically, tracking nitrogen mole inventory, bag volume (clamped to [0, V_bag_max]), and pressure. At each timestep it determines whether the bag is tracking ambient, saturated (with or without venting), or collapsed, and updates the mole count if venting occurs.
- **Plotting functions** -- pressure differential vs. time, bag volume vs. time, and a parametric sweep of minimum gauge pressure vs. rigid system volume.
- **`__main__` block** -- runs two example cases (V_fixed = 40 L safe, V_fixed = 60 L failing) and a sweep from 5 to 100 L.

### 5. `nitrogen_shipping_failure_model.m`

**Role: MATLAB implementation of the same quasi-static simulation**

A functionally identical MATLAB script that produces the same analytic thresholds, example cases, and plots as the Python version. It uses local functions (`build_shipping_profile`, `analytic_threshold_no_vent`, `analytic_threshold_negative_return`, `simulate_case`, `print_summary`) with the same logic and default parameters. This allows the model to be run in either environment depending on what the recipient has available, and provides a cross-check between implementations.

### 6. `example_volume_sweep.png`

**Role: Pre-rendered plot of the key design-space relationship**

A plot of "Minimum Internal - Ambient Pressure (bar)" vs. "Rigid Fixed System Volume (L)" for the default shipping envelope. The curve is flat at zero for small volumes (bag absorbs all expansion, no venting occurs), then drops steeply once V_fixed exceeds the venting threshold. This is the single most important figure in the analysis: it shows at a glance what range of rigid system volumes the current bag concept can protect, and how rapidly the failure margin degrades once that range is exceeded. It serves as the visual anchor for engineering discussions about whether V_fixed in the actual hardware falls in the safe or failing region.

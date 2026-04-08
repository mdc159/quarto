---
title: "25-Cycle Validation Test Plan – ¼-80 Adjuster Galling Study"
author: "Opto-Mechanical Engineering Group"
date: 2025-05-22
bibliography: refs.bib
csl: ieee.csl
---

# Summary

This test campaign ranks five material pairings for 1/4-80 UN adjusters used in optics-grade mechanisms that must run dry in N₂ at 26°C. The study captures friction torque, galling severity, particle generation, outgassing, resolution, and drift over 1×10⁶ cycles. Results feed two deliverables: a down-selection matrix identifying the top-performing pairing for flight hardware, and a calibrated friction-torque model accurate enough (τ ≥ 0.80, NRMSE ≤ 15%) to predict performance of future candidates without re-testing. The test drives the translation adjuster of a production crossed-roller stage inside a dry-nitrogen chamber, logging torque, micro-step position, and micron-resolution displacement. A constant 46.7 N spring preload ensures each candidate screw/nut/surface combination resists galling while maintaining stable friction and positional repeatability. All data, analysis code, and calibrated fixture CAD become available in an engineering-release package at project close.

# Objective & Scope

## Objectives (what this test will do)

| OBJ-ID | Objective | Requirement(s) verified |
|--------|-----------|-------------------------|
| OBJ-01 | Measure break-away torque vs cycle for five candidate pairings | TP05, BE03 |
| OBJ-02 | Verify tip-tilt resolution ≤ 0.0025 mrad per µstep (L/R values) | TP01 |
| OBJ-03 | Quantify particle generation relative to Krytox baseline | CLN |
| OBJ-04 | Confirm pointing drift ≤ 0.030 mrad over ΔT = 4 °C | TP04 |
| OBJ-05 | Demonstrate no missed steps with 0.50 N m motor at T_ba + 20 % | TP05 |
| OBJ-06 | Correlate Simulink T_ba prediction to hardware (±25 %) | TP05 |
| OBJ-07 | Validate μ(cycle) model to ±20 % after 25 cycles | — |

  -------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Obj-ID      Objective                                                                                                                         Linked Claim(s)
  --------------- --------------------------------------------------------------------------------------------------------------------------------- -----------------
      OBJ-01      Rank each material pairing by Galling Severity Index (GSI) to identify the most wear-resistant interface.                         C-002

      OBJ-02      Quantify steady-state and breakaway torque and prove the analytical model's ability to reproduce the ordering of those torques.   C-001

      OBJ-03      Rank pairings by particle emission rate (\>0.5 µm) under ISO 14644 conditions.                                                    C-003

      OBJ-04      Rank pairings by total mass-loss/outgassing per ASTM E595 after 72 h bake-out.                                                    C-004

      OBJ-05      Rank pairings by Precision Performance Score (PPS) combining resolution and drift.                                                C-005
  -------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Design Intent (why the objectives matter)

- **Hardware down-selection** -- Only the top-ranked pairing moves to flight builds; others are discarded.

- **Model calibration** -- A validated friction-torque model prevents costly future bench testing.

- **Contamination control** -- Rankings drive optical-surface lifetime predictions in the contamination budget.

- **System reliability** -- Galling-resistant, low-particle interfaces safeguard long-term adjustability.

## In-Scope Items

- Five candidate material pairings (Table 3.1).

- Dry-nitrogen atmosphere, 26°C ± 2°C.

- Full-travel cycling (0-0.5 in) at 1 Hz for 1×10⁶ cycles.

- Post-test microscopy, ISO particle counting, ASTM E595 TML/CI measurement.

## Out-of-Scope Items

- Temperature extremes outside 20-30°C.

- Long-term radiation or UV exposure effects.

- Alternate thread sizes or pitch variants.

## Success Outputs

- Ranked list and spider-chart summary for all five-performance metrics.

- Calibrated analytical model with τ and NRMSE statistics.

- Engineering-release ZIP: raw data, processed data, scripts, calibrated fixture CAD.

# Claims to Validate

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Claim-ID   Formal Statement
  ---------- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  C-001      The analytical friction-torque model reproduces the relative ordering and magnitude (within ±15%) of measured breakaway torques across all five material pairings.

  C-002      Material pairings ranked by Galling Severity Index (GSI) show correlation coefficient r ≥ 0.85 with industry-standard ASTM G98 galling threshold stress measurements.

  C-003      Median particle count \>0.5 µm per cycle differs by statistically significant margins (p \< 0.05) between the five candidate pairings, enabling clear ranking.

  C-004      Total mass-loss/outgassing per ASTM E595 remains below 1.0% for all candidates, with Collected Volatile Condensable Material (CVCM) \< 0.1%.

  C-005      Precision Performance Score (PPS): resolution + drift metrics remain stable within ±10% over 25 cycles for at least three material combinations.
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Table 3.1: Material Pairings Under Test \| Pairing ID \| Male Component \| Female Component \| Surface Treatment \| Expected Behavior \| \|------------\|----------------\|------------------\|-------------------\|-------------------\| \| MP-01 \| 304 SS \| Aluminum Bronze (C95400) \| None \| Baseline (unlubricated) - Expected severe galling \| \| MP-02 \| 304 SS \| Aluminum Bronze (C95400) \| Krytox GPL 205 \| Baseline (lubricated) - Control case \| \| MP-03 \| 304 SS \| Phosphor Bronze (C51000) \| None \| Moderate friction, reduced galling \| \| MP-04 \| Nitronic 60 \| Phosphor Bronze (C51000) \| None \| Low friction, minimal galling \| \| MP-05 \| 304 SS (Kolsterised) \| Phosphor Bronze (C51000) \| None \| Enhanced hardness, reduced adhesion \|

# Validation Strategy

## Traceability Matrix

  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Claim-ID   Fixture Feature / Control                                                                             Data Collected                                                                                         Validation Method                                                                                                            Pass/Fail Metric
  ---------- ----------------------------------------------------------------------------------------------------- ------------------------------------------------------------------------------------------------------ ---------------------------------------------------------------------------------------------------------------------------- ---------------------------------------------------------------------------------------
  C-001      Inline torque transducer (FUTEK TFF400); Micro-step position counter; Constant 46.7 N preload         Time-series torque data; Peak breakaway torque per cycle; Running torque                               MATLAB friction model with wear-in and galling progression equations compared to measured torque curves                      Model predicts relative ordering correctly AND magnitude within ±15% for all pairings

  C-002      N₂-purged test chamber; Production-grade stage with matched preload springs; 25+ cycles per pairing   Torque vs. cycle plots; Thread surface images at 10× magnification; Material transfer quantification   Computed GSI = (ΔT/T₀)×(Nᵥᵢₛ/25)×100% where ΔT = torque increase, T₀ = initial torque, Nᵥᵢₛ = cycles before visible damage   GSI correlates with published ASTM G98 thresholds with r ≥ 0.85

  C-003      ISO Class 5 environment; Particle counter sampling port; Standardized cycle protocol                  Particle count \>0.5 µm per cycle; Size distribution histogram; Time-series data                       Statistical comparison (ANOVA) of median particle counts across material pairs with post-hoc tests                           p \< 0.05 for differences between pairings

  C-004      Specimen preparation per ASTM E595; Vacuum chamber with cold plate                                    TML (%); CVCM (%); Water Vapor Regained (WVR, %)                                                       Standard ASTM E595 protocol with 125°C sample temperature, 25°C collector                                                    TML \< 1.0% AND CVCM \< 0.1% for all candidates

  C-005      Laser displacement sensor (0.1 µm resolution); Standardized dwell periods (5 min)                     Linear position vs. commanded position; Position error after dwell; Repeatability statistics           PPS = 10×(1-RMS₁/RMS₀)+(1-Δd/d₀) where RMS terms are positional errors and Δd is drift                                       PPS stability within ±10% over 25 cycles for ≥3 pairings
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Validation Narrative

The validation strategy creates a direct chain of evidence linking each claim to measurable test outcomes:

**For Claim C-001 (Model Fidelity)**: The inline torque transducer captures real-time torque data with high precision (0.05% repeatability) while the micro-stepping controller tracks angular position. These data streams feed the friction model, which predicts torque behavior based on material properties and wear mechanisms. The model passes validation when it correctly orders the pairings by friction torque magnitude and predicts values within ±15% of measured values, demonstrating sufficient accuracy for future predictions without bench testing.

The model incorporates both static and dynamic friction coefficients for each material pairing, building on established tribological relationships for threaded interfaces. Initial friction values derive from literature (e.g., μ≈0.34 for 304 SS on phosphor bronze), but the model adapts these values based on actual test data. The model's wear-in equation accounts for surface conditioning during early cycles, while its galling progression equation captures the exponential torque increase seen in failing interfaces. This dual-mode approach ensures accurate prediction of both normal wear and incipient galling.

**For Claim C-002 (Galling Severity)**: The Galling Severity Index (GSI) calculation combines torque progression data with visual inspection to quantify galling resistance. By conducting tests in a controlled N₂ environment with identical preload conditions (46.7 N) to the flight hardware, the GSI values directly represent real-world performance. The correlation with ASTM G98 standard test results validates that the simplified GSI approach captures the same fundamental galling behavior as industry-standard methods.

The GSI formula incorporates both torque increase (indicating friction change due to surface damage) and the number of cycles before visible thread damage appears under 10× magnification. This dual approach improves upon traditional single-parameter assessments by combining functional performance with physical evidence. Previous studies show strong correlation between similar indices and standard ASTM G98 galling thresholds for various material combinations. Visual inspection utilizes standardized reference images for consistent rating of damage severity.

**For Claim C-003 (Particle Generation)**: The ISO Class 5 environment and particle counter provide a clean baseline to detect particles generated solely by thread interaction. The standardized cycle protocol ensures fair comparison across all material pairings. Statistical analysis verifies that observed differences are significant and not due to random variation, enabling a definitive ranking for contamination-sensitive applications.

Particle counting employs both time-series and cumulative methods. The optical particle counter samples chamber air through an isokinetic probe positioned near the threads, capturing particles generated during operation. Size bins (0.5, 1.0, 5.0 μm) align with ISO 14644 standards and typical optical contamination concerns. Background counts establish the detection floor, with all test measurements compensated for baseline contamination. The ANOVA analysis confirms that observed differences between material pairs represent true performance variations rather than random fluctuations or measurement error.

**For Claim C-004 (Outgassing)**: ASTM E595 testing provides standardized outgassing metrics critical for vacuum and optical applications. The TML and CVCM thresholds represent established aerospace standards for acceptable materials. Testing validates that all candidate pairings meet these requirements, ensuring optical cleanliness in the nitrogen-purged environment.

Sample preparation follows strict ASTM protocols, with test articles cleaned identically to flight hardware. The 125°C sample temperature accelerates outgassing, while the 25°C collector plate captures condensable species. This represents a worst-case scenario compared to the 26°C operational environment. Water Vapor Regained (WVR) measurement distinguishes between water vapor and true material outgassing, providing additional insight into long-term behavior. While all metal-on-metal interfaces should theoretically exhibit minimal outgassing, this verification ensures no unexpected surface contamination or treatment residues are present.

**For Claim C-005 (Precision Performance)**: The laser displacement sensor directly measures the actual position achieved versus commanded position, capturing any resolution loss or drift. The Precision Performance Score combines two key precision metrics---positional error and drift after dwell---into a single figure of merit. Stability of this score over 25 cycles proves the mechanical interface maintains precision throughout its operational life.

The PPS formula weighs both immediate positioning accuracy (RMS position error) and temporal stability (drift after dwell). These factors directly impact optical alignment capabilities. The 5-minute dwell period simulates a realistic operational scenario where the adjuster remains still between occasional adjustments. This test reveals any tendency for the interface to creep due to stress relaxation or microscopic settling. By tracking PPS across multiple cycles, the test also captures any degradation in precision due to progressive wear or surface changes.

This multi-faceted validation approach ensures that all critical performance aspects---friction, wear resistance, contamination risk, and precision---undergo rigorous evaluation, delivering comprehensive data for material selection.

# Test Fixture Design

## Overview

The test fixture integrates a production-grade crossed-roller stage with precision measurement systems inside a nitrogen-purged chamber. Figure 1 shows the key components:

\![Test fixture schematic showing the stepper motor, torque sensor, and stage assembly inside nitrogen chamber. The translation block with the 1/4-80 adjuster under test is highlighted.\]

The fixture design employs a horizontal drive arrangement with the motor shaft aligned with the adjuster's rotation axis. The translation block rides on crossed-roller bearings providing high axial stiffness with minimal friction. The rotation block remains clamped during translation testing to isolate a single degree of freedom. This configuration creates a clean, single-axis test with the adjuster thread friction as the dominant variable between test cases.

## Critical Features

The fixture incorporates several design features specifically aligned with validation requirements:

1.  **Stepper Motor Drive Train** (supports C-001, C-005): A precision 0.9° stepper motor (StepperOnline 23HM22-2804S) with 1.26 N·m holding torque connects to the adjuster via a bellows coupling and torque cell. With 32× microstepping, the theoretical angular resolution reaches 25 nrad (≈0.025 µin linear motion), allowing detection of the finest stick-slip behavior.

- The motor provides significantly more torque (1.26 N·m) than required for normal operation (typically \<0.2 N·m) to ensure adequate headroom for detecting galling-induced torque spikes. The precision step angle (0.9° versus standard 1.8°) doubles the base resolution, while the microstepping driver further subdivides each step into 32 micro-positions. This ultra-fine positioning capability enables detection of microscopic stick-slip events that would be masked by coarser motion control.

2.  **Inline Torque Transducer** (supports C-001, C-002): The FUTEK TFF400-05 torque sensor (±0.04 N·m range) measures real-time torque at 1 kS/s, capturing both breakaway peaks and running friction. The sensor's 0.05% non-repeatability enables detection of subtle changes in thread condition throughout the test.

- The through-hole design allows direct mounting between couplings without introducing alignment errors or additional friction. The sensor's metal-foil strain gauge technology ensures stable readings even under prolonged testing, with negligible drift over the test duration. The high sampling rate (1 kS/s) captures transient events during breakaway, providing detailed friction signatures for each material pairing.

3.  **Nitrogen Purge Chamber** (supports C-002, C-003, C-004): An acrylic enclosure with O-ring seals and gas ports maintains \<50 ppm O₂ to replicate the inert environment of the flight hardware. The 2 SLPM purge flow ensures consistent atmospheric conditions while allowing particle extraction for counting.

- The chamber volume (approximately 1 L) permits complete atmosphere exchange within 30 seconds at the specified flow rate. The clear acrylic construction enables visual monitoring during testing while maintaining a sealed environment. Gas inlets incorporate sintered metal diffusers to minimize turbulence and prevent direct gas impingement on the test articles, which could disperse particles or create artificial airflow patterns.

4.  **Production-Grade Stage** (supports C-002, C-005): Using the actual flight-configuration crossed-roller stage with proper spring preload (46.7 N) creates authentic boundary conditions. The stage's translation block houses the 1/4-80 female thread component, while the ball-tipped adjuster screw represents the male component under test.

- The crossed-roller bearings provide extremely high stiffness in five degrees of freedom while allowing low-friction motion in the travel direction. This kinematic design isolates thread friction effects from other mechanical variables. The stage includes 440C hardened stainless steel ball tips contacting sapphire pads---a proven low-friction, wear-resistant interface that ensures the ball-tip contact is not a limiting factor in the test.

5.  **Laser Displacement Sensor** (supports C-005): A Keyence LK-G152 laser triangulation sensor with 0.1 µm resolution monitors the actual position of the translation block, detecting any position errors or drift caused by thread friction or wear.

- The non-contact measurement eliminates any influence on the mechanical system while providing traceable position data. With 50 kHz sampling capability, the sensor captures micro-dynamic behavior, including any momentary position reversals or oscillations. The 120 µm spot size averages surface irregularities while maintaining sufficient spatial resolution for detecting the smallest relevant motions.

6.  **Particle Sampling Port** (supports C-003): A calibrated isokinetic sampling port extracts a representative air sample from the chamber to an external optical particle counter, quantifying particles generated during thread operation.

- The port design maintains equivalent velocity between chamber air and sampled stream, ensuring accurate particle concentration measurement without size bias. The sampling location sits 25 mm from the thread interface---close enough to capture generated particles before they disperse but far enough to avoid sampling only localized concentrations.

7.  **Granite Base Plate** (supports all claims): A 100 mm × 150 mm × 25 mm granite slab provides thermal stability and vibration isolation for the entire test assembly.

- The granite's high thermal mass dampens temperature fluctuations, maintaining stable dimensional relationships between components. Its flatness (±2 µm) and stability serve as a solid reference for all measurements. Stainless steel dowel pins precisely locate the stage components on the granite base, ensuring repeatable positioning between test configurations.

8.  **Motion Controller** (supports C-001, C-005): A Trinamic TMCM-1230 controller provides precise motor control with advanced current sensing capabilities that serve as a secondary measure of motor torque.

- The controller's 256× microstepping capability delivers ultra-smooth motion while its StallGuard™ feature offers real-time detection of mechanical resistance. The RS-485 interface enables high-speed communication with the data acquisition system, synchronizing motion commands with sensor measurements. The controller includes programmable acceleration profiles that minimize vibration during direction changes.

## Assumptions and Design Limits

The fixture design operates under the following constraints and assumptions:

- **Materials**: 440C hardened stainless steel ball tips on adjusters (HRC 58-60) contacting sapphire pads. These create a Hertzian contact with 3.2 GPa peak pressure that forms a stable interface after initial plastic deformation.

<!-- -->

- The high hardness of both materials ensures the ball-pad interface contributes minimal friction or wear to the system. The 440C ball undergoes limited plastic deformation during initial loading, creating a stable contact patch with the sapphire. This plastic zone extends only a few microns into the ball surface and does not progress during normal operation. Sapphire's extreme hardness (\>2000 HV) ensures it remains fully elastic under the applied load.

<!-- -->

- **Load Range**: Spring preload of 46.7 N (10.5 lbf) based on three parallel springs each with k = 17.5 lbf/in stretched 0.200 inches. Maximum torque capacity of the sensor is 0.35 N·m, sufficient for normal operation but may saturate if severe galling occurs.

<!-- -->

- The preload applies directly along the adjuster axis, creating a pure axial force with no side loading. This force maintains positive contact between the ball tip and sapphire pad throughout the test range. The spring constant creates a nearly constant force over the travel range, with less than 5% variation across the full stroke. The torque sensor includes 150% overload protection, allowing brief excursions beyond the rated range without damage.

<!-- -->

- **Measurement Resolution**:

  - Angular: 28.8 μrad per full-step (0.9 μrad with 32× microstepping)

  - Linear: 0.1 μm (displacement sensor)

  - Torque: 0.01 mN·m (24-bit acquisition of ±0.04 N·m range)

  - Cycle counting: ±0 error (absolute encoder)

<!-- -->

- These resolution values exceed the requirements for detecting relevant performance differences between material pairings. For context, a 0.1 μm linear resolution represents approximately 0.002% of the full 0.5-inch travel range. The torque resolution (0.01 mN·m) equates to approximately 0.025% of the expected operating range, enabling detection of subtle friction changes.

<!-- -->

- **Thermal Stability**: Test environment maintains 26°C ± 2°C. The granite base provides thermal mass to dampen fluctuations. Differential thermal expansion between materials over this range causes negligible dimensional changes (\<0.1 μm).

<!-- -->

- The small temperature range minimizes thermal effects on friction coefficients, which typically vary by less than 5% over this span for the materials under consideration. The similar thermal expansion coefficients of stainless steel (≈16×10⁻⁶/°C) and bronze alloys (≈17×10⁻⁶/°C) result in minimal differential expansion, preserving thread clearances throughout the test.

<!-- -->

- **Boundary Conditions**: The translation block motion is constrained by crossed-roller bearings with stiffness \>10⁷ N/m. The rotation block remains clamped during translation tests to isolate a single degree of freedom.

<!-- -->

- This high stiffness ensures that measured displacements directly correspond to adjuster motion without significant elastic deformation of the fixture. The crossed-roller bearing friction (\<0.01 N) contributes negligibly to the measured torque compared to thread friction forces (typically \>1 N). The clamping of the rotation block eliminates potential crosstalk between the two adjustment axes.

<!-- -->

- **Nitrogen Environment**: Purge gas is 99.995% pure N₂ with \<5 ppm O₂, \<3 ppm H₂O, and particulate filtration to \<0.003 μm. The chamber maintains positive pressure (\~25 Pa) relative to the laboratory.

<!-- -->

- This high-purity environment prevents oxide formation on freshly exposed metal surfaces, simulating the conditions that promote galling in space mechanisms. The positive pressure prevents laboratory air ingress, maintaining consistent atmospheric composition throughout testing. The extreme dryness (\<3 ppm H₂O) eliminates any boundary lubrication effects from adsorbed water vapor.

<!-- -->

- **Sampling Statistics**: Each test configuration runs for 25 cycles minimum, with three specimens per material pairing. This provides 75 data points per configuration for statistical analysis.

<!-- -->

- This sample size delivers 90% confidence in detecting a 15% difference between material pairings with 80% statistical power. The multiple specimens account for manufacturing variations and provide a basis for assessing repeatability. Extended life testing (up to 10⁶ cycles) runs on only the top-performing specimen from each pairing.

# Test Procedure

## Pre-test Calibration and Checks

1.  Perform zero-load calibration of the FUTEK torque transducer using the supplied calibration shunt.

2.  Verify laser displacement sensor calibration using a certified gage block.

3.  Mount a reference screw/nut pair (304 SS/Al-bronze with Krytox) for system verification.

4.  Apply 46.7 N preload using the spring pack and verify with load cell.

5.  Perform three reference cycles and confirm torque values within 5% of expected range.

6.  Clean the test chamber with isopropyl alcohol and lint-free wipes.

7.  Perform particle background count; verify ISO Class 5 or better (\<3,520 particles \>0.5 μm per m³).

8.  Verify stepper motor step accuracy using the displacement sensor over 10 complete revolutions.

9.  Check the nitrogen delivery system for proper flow rate (2 SLPM) and pressure regulation.

10. Verify data acquisition system timing and synchronization using a square wave test signal.

11. Confirm temperature stability within the test chamber (26°C ± 0.5°C) over a 30-minute period.

12. Document initial condition of all test articles with 10× digital microscopy.

## Step-by-step Execution

For each candidate material pairing:

1.  Install the male adjuster screw in the drive coupling.

2.  Insert the female threaded component in the translation block.

3.  Close the acrylic chamber.

4.  Purge with nitrogen at 2 SLPM until O₂ \< 50 ppm.

5.  Home the stepper motor to the starting position.

6.  Record start time and configuration details in the test log.

7.  Drive the adjuster +0.25 turn at 1 RPM.

8.  Hold position for 5-minute dwell period.

9.  Drive the adjuster -0.25 turn at 1 RPM to complete one cycle.

10. Repeat steps 7-9 for 25 consecutive cycles.

11. For extended life testing, continue cycling at 1 Hz for 1×10⁶ cycles or until failure.

12. Vent the chamber and remove the test components.

13. Photograph thread surfaces at 10× magnification using the digital microscope.

14. Package threads in sealed containers for subsequent ASTM E595 testing.

15. Clean fixture components before installing the next pairing.

For detailed characterization of friction behavior:

16. During the first, fifth, tenth, and twenty-fifth cycles, drive the adjuster in 0.05° increments.

17. Record torque at each position to generate high-resolution torque-angle curves.

18. After each dwell period, measure the torque required to initiate motion (breakaway torque).

19. Calculate the difference between forward and reverse torque to quantify hysteresis.

20. Monitor any stick-slip behavior by analyzing torque oscillations during constant-speed rotation.

For extended cycling tests:

21. Program the controller to execute 1 Hz reciprocating cycles covering the full 0.5-inch travel.

22. Configure automated data sampling to record complete cycles at logarithmic intervals (cycles 1, 10, 100, 1000, etc.).

23. Set torque limit thresholds to automatically halt testing if galling-induced torque spikes occur.

24. Verify nitrogen flow and temperature stability every 8 hours during extended runs.

25. Perform interim inspections at 1,000, 10,000, and 100,000 cycles for long-duration tests.

## Data Logging Requirements

- **Torque Data**: Sample at 1 kS/s with synchronous timestamps. Record both raw and filtered values. File format: {date}\_torque\_{material-ID}.csv

- **Position Data**: Sample angular position at 1 kS/s to match torque data; sample linear displacement at 5 kS/s. File format: {date}\_position\_{material-ID}.csv

- **Environmental Data**: Log N₂ purity, temperature, and relative humidity at 1 Hz. File format: {date}\_environment\_{material-ID}.csv

- **Particle Data**: Log particle counts by size bin (0.5, 1.0, 5.0 μm) at 1 Hz. File format: {date}\_particles\_{material-ID}.csv

- **Metadata**: Record all test configuration details, sample IDs, and timestamps in a structured JSON file. Format: {date}\_metadata\_{material-ID}.json

All data files require SHA-256 checksums for integrity verification.

The torque data file must include columns for: - Timestamp (μs precision) - Raw torque (N·m) - Filtered torque (N·m) - Motor phase current (A) - Derived friction coefficient (calculated in real-time)

The position data file must include columns for: - Timestamp (μs precision) - Commanded angle (degrees) - Actual angle (encoder reading, degrees) - Linear position (μm) - Position error (μm)

The environmental data file must include columns for: - Timestamp (s precision) - O₂ concentration (ppm) - N₂ flow rate (SLPM) - Temperature (°C) - Relative humidity (%) - Pressure (kPa)

Metadata must include: - Material pairing ID - Component serial numbers - Operator name and contact - Calibration certificate references - Test sequence number - Notes or anomalies - Software/firmware versions

Image data: - Pre-test microscopy: {date}\_pre\_{material-ID}\_{location}.tif (16-bit) - Post-test microscopy: {date}\_post\_{material-ID}\_{location}.tif (16-bit) - Thread profile scans (if applicable): {date}\_profile\_{material-ID}.csv

## Post-test Teardown / Safety

1.  Verify the nitrogen purge system is deactivated and chamber vented.

2.  Remove all test articles and place in labeled, sealed containers.

3.  Disconnect the torque sensor to prevent accidental damage.

4.  Clean the fixture with isopropyl alcohol and lint-free wipes.

5.  Cover all optical surfaces with protective caps.

6.  Verify all power is disconnected from the motion control system.

7.  Complete post-test inspection checklist documenting fixture condition.

8.  Transfer all collected data to the secure repository with backup.

9.  Log the total test duration and cycle count in the test record.

10. Update the master test matrix with completion status.

11. For components showing significant galling or damage, apply corrosion inhibitor before storage.

12. Prepare selected components for subsequent ASTM E595 outgassing tests.

13. Document any fixture maintenance or calibration needs discovered during testing.

14. Remove and properly dispose of any particles or debris from the test chamber.

15. Secure the testing area and return all tools to designated storage.

# Data Analysis Plan

## Raw-to-processed Data Pipeline

The analysis workflow processes the raw data files through several steps:

1.  **Signal Conditioning**: Apply a 5th-order Butterworth low-pass filter with 20 Hz cutoff to the torque data to eliminate motor and electronic noise while preserving breakaway peaks.

2.  **Breakaway Torque Extraction**: Identify the peak torque occurring within the first 5° of motion after each dwell period using a peak-detection algorithm with a slope threshold of 0.1 N·m/s.

3.  **Steady-state Torque Calculation**: Average the torque values between 10° and 90° of each rotation to determine running friction, excluding the initial breakaway region and end-of-travel effects.

4.  **Torque Progression Analysis**: Plot peak breakaway torque vs. cycle number for each material pairing and fit to the appropriate model:

    - For non-galling cases: $T(n) = T_{0} + (T_{s} - T_{0})(1 - e^{- kn})$ where $T_{s}$ is steady-state torque

    - For galling cases: $T(n) = T_{0} + ae^{bn}$ where $a,b$ are growth parameters

5.  **Position Error Analysis**: Calculate the difference between commanded and actual position at each micro-step, generating an error histogram and RMS error value per cycle.

6.  **Particle Data Processing**: Convert raw particle counts to particles/cycle and particles/mm of travel to normalize for comparison.

7.  **Friction Coefficient Derivation**: Calculate the effective friction coefficient for each material pairing using the torque and preload data via: $\mu = \frac{T}{F_{N}r_{\text{eff}}}$ where $r_{\text{eff}}$ is the effective radius for the 1/4-80 thread geometry.

8.  **Hysteresis Analysis**: Calculate the area enclosed by the torque-vs-angle curve during forward and reverse motion to quantify energy loss per cycle.

9.  **Stick-Slip Characterization**: Analyze torque time derivatives to identify and quantify stick-slip events, recording amplitude and frequency.

10. **Thread Surface Analysis**: Process microscopy images through computational methods to quantify surface roughness changes, material transfer volume, and wear track dimensions.

11. **Time-series Alignment**: Synchronize all data streams based on timestamps to create composite visualizations of torque, position, and particle generation.

12. **Data Cleaning**: Apply statistical outlier detection to identify and flag anomalous measurements for review. Employ Hampel filtering for spike removal while preserving genuine torque peaks.

## Statistical Tests and Models

1.  **ANOVA with Tukey HSD Post-hoc Tests**: Determine statistically significant differences in breakaway torque, steady-state torque, and particle generation between material pairings.

2.  **Correlation Analysis**: Calculate Pearson's r between measured GSI values and published ASTM G98 galling thresholds to validate Claim C-002.

3.  **Predictive Model Evaluation**: Calculate Kendall's τ and NRMSE between predicted and measured torque values to quantify model accuracy for Claim C-001.

4.  **Weibull Analysis**: Apply Weibull statistics to lifetime data from extended cycles to predict failure probability at various cycle counts.

5.  **Precision Performance Score Calculation**: Compute PPS = 10×(1-RMS₁/RMS₀)+(1-Δd/d₀) for each cycle and material pairing, then perform stability analysis.

6.  **Bootstrap Confidence Intervals**: Generate 95% confidence intervals for all key metrics using bootstrap resampling to account for measurement uncertainty.

7.  **Principal Component Analysis**: Apply PCA to the multi-dimensional performance data to identify key factors driving material pairing differences.

8.  **Cox Proportional Hazards Model**: For extended life testing, apply survival analysis techniques to quantify reliability differences between material pairings.

9.  **CUSUM Analysis**: Apply cumulative sum control charts to detect subtle shifts in friction behavior that might indicate incipient galling.

10. **Multiple Regression Analysis**: Develop a multi-factor model relating material properties (hardness, surface roughness) to measured performance metrics.

## Acceptance Criteria

Each claim's pass/fail metric maps to specific acceptance criteria:

**For C-001 (Model Fidelity)**: The model passes if: - The predicted rank order of breakaway torques matches the measured order exactly. - The predicted magnitudes fall within ±15% of measured values for all five pairings. - The NRMSE between predicted and measured torque progression curves is ≤15%.

This requires consistent behavior across test specimens and good agreement between model predictions and measurement. The analytical model must capture both the initial friction levels and the friction evolution trends correctly to pass validation.

**For C-002 (Galling Severity)**: Acceptance requires: - Pearson's r ≥ 0.85 between calculated GSI values and published ASTM G98 thresholds. - Clear visual differentiation in 10× microscopy images correlating with GSI ranking. - At least two material pairings show GSI \< 10 (minimal galling) after 25 cycles.

The GSI calculation must provide a quantitative measure that aligns with established galling assessment methods. The visual inspection criterion ensures that numerical results correspond to physical reality. The requirement for at least two viable pairings ensures the test identifies multiple potential solutions.

**For C-003 (Particle Generation)**: Validation requires: - ANOVA p \< 0.05 for differences in particle generation rates between pairings. - At least two pairings show particle generation rates \<100 particles (\>0.5 μm) per cycle. - Consistent particle size distribution for each material pairing across all test cycles.

Statistical significance ensures the observed particle generation differences are real, not artifacts of measurement variation. The absolute threshold (\<100 particles/cycle) represents a practical clean-room compatibility target. Consistency in size distribution confirms that the particle generation mechanism remains stable throughout testing.

**For C-004 (Outgassing)**: Acceptance criteria include: - All candidates demonstrate TML \< 1.0% per ASTM E595. - All candidates show CVCM \< 0.1% per ASTM E595. - Water Vapor Regained (WVR) is reported but has no pass/fail threshold.

These thresholds align with NASA standards for space-qualified materials. TML measures total mass loss under vacuum, while CVCM quantifies condensable materials that could contaminate optical surfaces. WVR provides context for interpreting TML results, as water vapor resorption is generally less concerning than true material outgassing.

**For C-005 (Precision Performance)**: Validation requires: - PPS stability within ±10% over 25 cycles for at least three material combinations. - At least one pairing achieves an average PPS \> 18 (out of theoretical maximum 20). - Position drift after 5-minute dwell \<0.5 μm for the top-performing pairing.

Stability in the PPS metric indicates consistent mechanical performance over repeated use. The absolute score threshold (\>18) ensures at least one solution meets high precision requirements. The drift specification (\<0.5 μm) represents a practical limit for optical alignment applications, where positional stability directly impacts system performance.

# Risk Assessment & Mitigations

  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                 Risk                Potential Impact                                 Mitigation Strategy
  ---------------------------------- ------------------------------------------------ -------------------------------------------------------------------------------------------------------------------------------------
       Premature thread seizing      Test interruption, data loss, fixture damage     Monitor torque in real-time with automatic cutoff at 1.5× baseline; keep spare components for all material pairings

        Torque sensor overload       Sensor damage, calibration loss                  Include mechanical torque limiter (slip clutch) set to 0.3 N·m; implement software limits in motor controller

     Nitrogen supply interruption    Environment change, test invalidation            Use pressure sensor with alarm; incorporate backup N₂ cylinder with automatic switchover

     Contamination between tests     Cross-sample contamination, invalid results      Establish rigorous cleaning protocol with verification; use separate tools for each material set

          Power interruption         Data loss, test restart required                 Employ UPS for all electronics; enable auto-save of data every 60 seconds; implement auto-recovery procedure

       Temperature fluctuation       Changed friction behavior, invalid comparisons   Monitor temperature continuously; flag data if excursion \>±1°C; incorporate in analysis as covariate

     Particle counter malfunction    Missing contamination data                       Perform verification count before each pairing; have backup counter available

         Ball-tip deformation        Changed contact geometry, invalid results        Inspect ball tips before testing; replace if any visible wear; perform Hertzian stress calculation to confirm safe operating regime

       Thread alignment issues       Side loading, invalid torque readings            Use precision fixtures to ensure coaxial alignment; monitor lateral displacement during tests

         DAQ sampling errors         Data gaps or artifacts                           Implement circular buffer to prevent data loss; check timestamps for continuity during post-processing

      Laser sensor misalignment      Inaccurate position data                         Mount sensor on kinematic base; verify calibration before each test series; monitor return signal strength

   Thread manufacturing variability  Inconsistent baseline performance                Source all test components from same manufacturing lot; measure and document thread profile before testing

        Inadequate sample size       Reduced statistical confidence                   Test minimum three specimens per material pairing; use power analysis to verify detection capability

          Fixture resonance          Vibration affecting measurements                 Perform modal analysis before testing; add damping if needed; filter data at identified resonant frequencies

   Controller communication faults   Command/data synchronization issues              Implement watchdog timer and handshaking; verify timing with oscilloscope before test series

     Environmental contamination     Elevated background particle counts              Purge chamber for extended period before testing; verify ISO Class 5 conditions; conduct tests in cleanroom

     Drift in sensor calibration     Measurement accuracy degradation                 Perform calibration checks at beginning and end of each test day; apply correction factors if needed

     Unexpected material behavior    Results not matching literature                  Characterize actual material properties (hardness, roughness, composition) for all test samples

    Software bugs in analysis code   Incorrect results or interpretation              Implement unit tests for analysis functions; validate with synthetic data; conduct peer code review

   Mechanical wear of test fixture   Changing boundary conditions                     Establish baseline reference runs; inspect fixture components regularly; replace critical elements preventively
  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Deliverables & Schedule

## Deliverables

1.  **Test Report Package**:

    - Comprehensive test report with executive summary and detailed results

    - Raw data files for all measurements (torque, position, particles, environment)

    - Processed data and statistical analysis outputs

    - High-resolution microscopy images of thread surfaces pre/post-test

    - ASTM E595 outgassing test certificates

2.  **Engineering Model Package**:

    - Calibrated MATLAB/Simulink model files

    - Parameter sets for all material pairings

    - Validation documentation comparing model predictions to test results

    - User guide for applying the model to new configurations

3.  **Test Fixture Package**:

    - CAD files of the calibrated test fixture

    - Bill of materials with supplier information

    - Calibration certificates for all sensors

    - Assembly and operation manual

4.  **Spider-chart Summary Tool**:

    - Interactive visualization tool for comparing material pairings

    - Export functionality for reports and presentations

    - Source code and documentation

5.  **Material Selection Guide**:

    - Detailed recommendations for optimal pairing selection based on application requirements

    - Decision tree for evaluating new material combinations

    - Case studies demonstrating selection process

6.  **Extended Life Data**:

    - Full cycle-to-failure data for top performers

    - Weibull analysis and lifetime prediction models

    - Failure mode documentation with supporting imagery

7.  **Analytical Methods Documentation**:

    - Detailed description of GSI calculation methodology

    - Friction model derivation and validation

    - Statistical analysis procedures and code examples

8.  **Physical Specimens**:

    - Archive set of tested specimens for future reference

    - Cross-sectioned samples showing wear patterns and material transfer

    - Reference samples of unworn components

## Schedule

  ----------------------------------------------------------------------------------------------------------
  Milestone                           Timeline             Dependencies
  ----------------------------------- -------------------- -------------------------------------------------
  Test fixture fabrication            Weeks 1-3            Procurement of sensors and materials

  Fixture calibration                 Week 4               Completion of fabrication

  Baseline material testing           Week 5               Calibrated fixture

  Candidate pairing tests             Weeks 6-8            Preparation of all material samples

  Extended life testing               Weeks 9-15           Completion of initial 25-cycle tests

  ASTM E595 testing                   Weeks 9-11           Completion of mechanical tests

  Data analysis                       Weeks 16-18          All test data collected

  Model calibration                   Weeks 19-20          Completed data analysis

  Final report and deliverables       Weeks 21-22          All preceding tasks

  Engineering review                  Week 23              Final report completion

  Material selection recommendation   Week 24              Engineering review approval

  Test fixture documentation          Weeks 21-22          Parallel to final report

  Code and model documentation        Weeks 19-22          During model calibration and report preparation

  Physical sample preparation         Weeks 18-20          After completion of all mechanical testing

  Archiving and transfer              Week 24              After engineering review
  ----------------------------------------------------------------------------------------------------------

# References

\[1\] ASTM G98-17, "Standard Test Method for Galling Resistance of Materials," ASTM International, West Conshohocken, PA, 2017.

\[2\] ASTM E595-15, "Standard Test Method for Total Mass Loss and Collected Volatile Condensable Materials from Outgassing in a Vacuum Environment," ASTM International, West Conshohocken, PA, 2015.

\[3\] Bhushan, B., "Modern Tribology Handbook," CRC Press, 2000.

\[4\] ISO 14644-1:2015, "Cleanrooms and associated controlled environments --- Part 1: Classification of air cleanliness by particle concentration," International Organization for Standardization, 2015.

\[5\] ASTM G196-08(2016), "Standard Test Method for Galling Resistance of Material Couples," ASTM International, West Conshohocken, PA, 2016.

\[6\] Bodycote, "Kolsterising® - Low Temperature Carburization for Stainless Steels," Technical Data Sheet, Bodycote Plc, 2020.

\[7\] Meyer Tool & Mfg., "Galling and Fasteners for Vacuum Service," Meyer Tool Technical Article, Oak Lawn, IL, 2019.

\[8\] AK Steel, "Nitronic® 60 Stainless Steel Product Data Bulletin," Cleveland-Cliffs Inc., 2020.

\[9\] Rabinowicz, E., "Friction and Wear of Materials," 2nd Edition, John Wiley & Sons, 1995.

\[10\] NASA, "Outgassing Data for Selecting Spacecraft Materials," Goddard Space Flight Center Database, 2022.

\[11\] Copper Development Association, "Properties of Wrought and Cast Copper Alloys: Phosphor Bronze," CDA Technical Publication, 2018.

\[12\] Johnson, K.L., "Contact Mechanics," Cambridge University Press, 1985.

\[13\] Roberts, E.W., "Space Tribology Handbook," 5th Edition, European Space Tribology Laboratory, 2012.

# Appendices

## Detailed Sensor Specifications

### A.1 Torque Sensor

- **Model**: FUTEK TFF400-05

- **Range**: ±0.04 N·m

- **Accuracy**: 0.5% of rated output

- **Non-repeatability**: 0.05% of rated output

- **Excitation**: 5-12 VDC

- **Output**: 2 mV/V nominal

- **Temperature compensation**: 21°C to 32°C

- **Overload capacity**: 150% of rated capacity

- **Bridge resistance**: 350 Ω nominal

- **Nonlinearity**: ±0.1% of rated output

- **Hysteresis**: ±0.1% of rated output

- **Temperature effect on zero**: 0.03% of rated output/°C

- **Temperature effect on span**: 0.03% of rated output/°C

- **Insulation resistance**: \>500 MΩ @ 50 VDC

- **Connector**: 4-pin LEMO

- **Material**: Aluminum housing, stainless steel shaft

- **Weight**: 130 g

### A.2 Displacement Sensor

- **Model**: Keyence LK-G152

- **Measuring range**: ±40 mm

- **Resolution**: 0.1 μm

- **Sampling frequency**: 50 kHz

- **Light source**: 650 nm semiconductor laser

- **Spot diameter**: 120 μm

- **Linearity**: ±0.05% of F.S.

- **Temperature drift**: 0.01% F.S./°C

- **Protection rating**: IP67

- **Output**: ±10V analog, 16-bit digital

- **Laser class**: Class 2 (IEC60825-1)

- **Environmental resistance**: IP67

- **Operating environment**: 0-50°C

- **Controller**: LK-G5000 with Ethernet/IP interface

- **Sample averaging**: 1-32768 samples (adjustable)

- **Filter functions**: Moving average, median, low-pass

### A.3 Particle Counter

- **Measurement range**: 0.5 μm to 25 μm

- **Flow rate**: 2.83 L/min (0.1 ft³/min)

- **Coincidence loss**: \<5% at 70,000 particles/ft³

- **Zero count level**: \<1 count/5 minutes

- **Sample time**: Adjustable 1 second to 99 hours

- **Light source**: Laser diode

- **Size channels**: 0.5, 1.0, 5.0, 10.0, 25.0 μm

- **Communication**: RS-485, USB, optional Ethernet

- **Data storage**: 3,000 sample records

- **Sample probe**: Isokinetic sampling probe

- **Calibration**: NIST traceable

- **Enclosure**: Stainless steel

- **Response time**: \<1 second

- **Operating environment**: 10-40°C, 20-95% RH non-condensing

### A.4 Data Acquisition System

- **Model**: NI cDAQ-9237 with cDAQ-9171 chassis

- **Resolution**: 24-bit

- **Sample rate**: 50 kS/s per channel

- **Simultaneous sampling**: Yes

- **Input range**: ±25 mV to ±10 V

- **Excitation**: Programmable 2.5, 3.3, 5, 10 V

- **Bridge completion**: Internal half/full bridge completion

- **CMRR**: 100 dB

- **Analog bandwidth**: 4.6 kHz

- **Input impedance**: \>1 GΩ

- **Noise**: 1 μVrms at 1 kS/s

- **Channels**: 4 bridge-based sensor inputs

- **Connectivity**: USB 2.0

- **Software compatibility**: LabVIEW, MATLAB, Python, C/C++

- **Temperature range**: 0-55°C operating

- **Calibration interval**: 1 year

## Calibration Certificates

\[Placeholder for actual calibration certificates that will be inserted when available\]

## Calculation Sheets

### C.1 Hertzian Contact Stress Analysis

For a 3.18 mm (1/8") 440C stainless steel ball tip against a sapphire flat with 46.7 N (10.5 lbf) preload:

**Material Properties:** - 440C Steel: $E_{1} = 210$ GPa, $\nu_{1} = 0.30$ - Sapphire: $E_{2} = 345$ GPa, $\nu_{2} = 0.23$

**Reduced (composite) modulus:**

$$\frac{1}{E^{*}} = \frac{1 - \nu_{1}^{2}}{E_{1}} + \frac{1 - \nu_{2}^{2}}{E_{2}} \Rightarrow E^{*} = 1.41 \times 10^{11}\text{ Pa}$$

**Contact-patch radius for a sphere on a flat (Hertz 1882):**

$$a = \left( \frac{3F_{N}R}{4E^{*}} \right)^{1/3} = \left( \frac{3 \cdot 46.7 \cdot 0.00159}{4 \cdot 1.41 \times 10^{11}} \right)^{1/3} = 7.3 \times 10^{- 5}\text{ m} = 73\text{ μm}$$

**Peak Hertz pressure:**

$$p_{0} = \frac{3F_{N}}{2\pi a^{2}} = \frac{3 \cdot 46.7}{2\pi \cdot (7.3 \times 10^{- 5})^{2}} = 4.1\text{ GPa}$$

**Interpretation:** A hardened 440C sphere at HRC 58 (≈ 650 HV) has a compressive yield ≈ 2.2 GPa (empirical $\sigma_{y} \approx \text{HV}/3$). With $p_{0} = 4.1\text{ GPa} > \sigma_{y}$, a microscopic plastic annulus forms upon first loading, creating a stable contact patch. Sapphire's compressive strength (\>10 GPa) ensures it remains fully elastic with a \>2× safety factor.

### C.2 Friction Model Equations

The analytical friction-torque model predicts breakaway torque as a function of cycle number using different equations for wear-in versus galling conditions:

**For non-galling cases (wear-in behavior):**

$$T(n) = T_{0} + (T_{s} - T_{0})(1 - e^{- kn})$$

Where: - $T(n)$ = Breakaway torque at cycle $n$ \[N·m\] - $T_{0}$ = Initial breakaway torque \[N·m\] - $T_{s}$ = Steady-state torque after wear-in \[N·m\] - $k$ = Wear-in rate constant \[cycles⁻¹\] - $n$ = Cycle number

**For galling cases (exponential degradation):**

$$T(n) = T_{0} + ae^{bn}$$

Where: - $a$ = Initial galling amplitude \[N·m\] - $b$ = Galling progression rate \[cycles⁻¹\]

**Torque-friction relationship:**

$$T = \mu F_{N}r_{\text{eff}}$$

Where: - $\mu$ = Friction coefficient (static or dynamic) - $F_{N}$ = Normal force on threads \[N\] - $r_{\text{eff}}$ = Effective moment arm of thread \[m\]

For a 1/4-80 UN thread with 46.7 N preload:

$$r_{\text{eff}} \approx \frac{d_{m}}{2}\left( \frac{l + \pi\mu d_{m}\sec\alpha}{\pi d_{m} - \mu l\sec\alpha} \right)$$

Where: - $d_{m}$ = Mean thread diameter \[m\] - $l$ = Lead per revolution \[m\] - $\alpha$ = Thread half-angle \[rad\]

### C.3 Differential Thermal Expansion Calculation

For the small temperature range (21-25°C) in this test:

**Linear Thermal Expansion:**

$$\Delta L = L_{0}\alpha\Delta T$$

Where: - $\Delta L$ = Change in length \[m\] - $L_{0}$ = Original length \[m\] - $\alpha$ = Coefficient of thermal expansion \[K⁻¹\] - $\Delta T$ = Temperature change \[K\]

**For 1/4-80 thread interface between stainless steel and bronze:** - Stainless steel CTE: $\alpha_{SS} \approx 16 \times 10^{- 6}$ K⁻¹ - Bronze CTE: $\alpha_{BR} \approx 17 \times 10^{- 6}$ K⁻¹ - Thread mean diameter: $d_{m} \approx 6.35$ mm - Thread engagement length: $L \approx 6$ mm - Temperature range: $\Delta T = 4$ K

**Diametral expansion (male thread):**

$$\Delta d_{SS} = d_{m}\alpha_{SS}\Delta T = 6.35 \times 16 \times 10^{- 6} \times 4 = 0.406\text{ μm}$$

**Diametral expansion (female thread):**

$$\Delta d_{BR} = d_{m}\alpha_{BR}\Delta T = 6.35 \times 17 \times 10^{- 6} \times 4 = 0.432\text{ μm}$$

**Differential expansion:**

$$\Delta d_{diff} = \Delta d_{BR} - \Delta d_{SS} = 0.026\text{ μm}$$

This 0.026 μm differential expansion is negligible compared to typical thread clearances (10-50 μm) and will not cause binding or significant change in thread fit over the test temperature range.

### C.4 Galling Severity Index (GSI) Calculation

The GSI combines torque increase with visual inspection to quantify galling resistance:

$$\text{GSI} = \left( \frac{\Delta T}{T_{0}} \right) \times \left( \frac{N_{vis}}{25} \right) \times 100\%$$

Where: - $\Delta T$ = Torque increase from first to last cycle \[N·m\] - $T_{0}$ = Initial torque \[N·m\] - $N_{vis}$ = Number of cycles before visible thread damage at 10× magnification

**Example calculation:** - For a material that shows 20% torque increase after 25 cycles with damage visible at cycle 20:

$$\text{GSI} = \left( \frac{0.2T_{0}}{T_{0}} \right) \times \left( \frac{20}{25} \right) \times 100\% = 16\%$$

- For a material that shows 50% torque increase with damage visible at cycle 10:

$$\text{GSI} = \left( \frac{0.5T_{0}}{T_{0}} \right) \times \left( \frac{10}{25} \right) \times 100\% = 20\%$$

- For a material that shows 5% torque increase with no visible damage after 25 cycles:

$$\text{GSI} = \left( \frac{0.05T_{0}}{T_{0}} \right) \times \left( \frac{25}{25} \right) \times 100\% = 5\%$$

Lower GSI values indicate superior galling resistance. A hypothetical perfect material (no torque increase, no visible damage) would have GSI = 0%.

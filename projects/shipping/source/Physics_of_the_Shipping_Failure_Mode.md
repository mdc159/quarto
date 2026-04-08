## Physics of the Shipping Failure Mode

The shipping problem is fundamentally a transient gas-inventory and compliance-volume problem in a distributed, partially rigid, manifolded enclosure. The internal nitrogen space is not a single vessel, but the aggregate of multiple closed aluminum optical modules, PFA interconnect tubing, and intake/exhaust manifold volumes. During shipment, this connected gas volume is exposed to simultaneous variations in ambient pressure and temperature. The assembly is intended to remain at slight positive gauge pressure so that any leakage is outward. The critical failure condition is therefore not merely pressure excursion in the abstract, but loss of nonnegative internal pressure relative to ambient. Once the internal pressure becomes negative with respect to ambient, the many existing seal and joint locations become potential ingress paths for atmospheric contamination. In this application, even small inward leakage is unacceptable because the internal environment is a high-purity nitrogen space and contamination accumulates over long shipping durations 

To first order, the gas can be treated as ideal nitrogen over the relevant pressure and temperature range. The governing relation is

P V = n R T

where P is absolute pressure, V is total gas volume, n is nitrogen mole inventory, R is the universal gas constant, and T is absolute temperature. The crucial point is that shipping changes not only P and T, but also, potentially, n. If nitrogen is vented during the outbound portion of the transport cycle, then the subsequent return state is not described by a fixed-mass ideal-gas process referenced to the original seal-up condition. It is instead a reduced-mass system. That distinction is the core of the failure mechanism.

Let the total internal gas space be decomposed into a fixed rigid volume V_fixed and a passive geometric compliance volume V_bag, such that

V_total = V_fixed + V_bag

with

0 ≤ V_bag ≤ V_bag,max

For the present foil-bag concept, the bag is assumed to be geometrically compliant but not elastically compliant. That is, it does not provide a meaningful restoring force over its usable range; it merely unfolds and refolds between hard geometric limits. Under that assumption, while the bag remains between its fully collapsed and fully expanded limits, the internal gas can change total occupied volume with negligible pressure penalty, and the internal pressure approximately tracks ambient pressure. In that regime, the bag functions as a zero-stiffness compliance reservoir.

The failure mechanism is therefore piecewise.

Regime 1: Bag within available compliance range. As ambient pressure decreases and temperature increases during ascent and exposure to elevated thermal conditions, the nitrogen attempts to expand according to the ideal-gas law. If the required volume increase can be accommodated by the remaining bag headroom, the internal pressure remains approximately equal to ambient, aside from any intentional small positive bias. No harmful overpressure or underpressure develops in this regime.

Regime 2: Bag reaches maximum volume. Once the bag is fully expanded, no further geometric compliance is available. Additional demand for volume increase must then appear as internal pressure rise. At that point, if an outward-only relief or check valve is present and opens, nitrogen mass is lost from the system. This is a one-way event in a thermodynamic sense: the system has reduced n. Even if the valve later re-closes perfectly and never leaks inward, the original nitrogen inventory has not been preserved.

Regime 3: Return leg with depleted gas inventory. During descent and cooling, ambient pressure increases and gas temperature decreases. The bag correspondingly collapses. If the bag fully collapses and the remaining nitrogen inventory is insufficient to fill the rigid connected system volume V_fixed at ambient pressure, then the internal absolute pressure necessarily falls below ambient. Mathematically, once V_bag = 0, the internal pressure is

P_internal = n_remaining R T / V_fixed

If this quantity is less than ambient pressure, then the connected optical-module system is sub-atmospheric with respect to its surroundings. In that state, the outward-only valve is no longer the controlling issue. The controlling issue is that the system must equilibrate through some leakage path, and because multiple seals and joints already exist in the manifolded assembly, ambient air ingress becomes thermodynamically favored. This is the critical contamination condition.

The important implication is that the outbound overpressure condition is not the principal failure risk. Overpressure is already bounded by the existing relief architecture and, in the current concept, by the ability of the bag to expand and the valve to vent. The critical risk is instead irreversible nitrogen mass loss during the outbound leg, followed by insufficient remaining gas inventory during descent and cooling. In other words, the design problem is not “can the system survive the high-pressure side,” but “can the system preserve enough nitrogen mass and enough residual compliance to avoid crossing below ambient on the low-pressure side.” This is why a design that appears acceptable when evaluated only for outward pressure relief can still fail catastrophically with respect to contamination control.

This can be stated more formally by considering the outbound high-altitude, high-temperature condition and the return sea-level, lower-temperature condition. Suppose the bag has already reached V_bag,max and the system has vented until internal pressure is approximately equal to the local ambient pressure at the high-altitude condition. The retained mole inventory is then set by

n_retained = P_high (V_fixed + V_bag,max) / (R T_high)

After return, if the bag has fully collapsed, the internal pressure becomes

P_return = n_retained R T_return / V_fixed
= P_high ((V_fixed + V_bag,max) / V_fixed) (T_return / T_high)

This expression shows the governing dependence directly. Return pressure is improved by larger compliance volume and worsened by larger rigid system volume. If P_return is less than local ambient pressure at arrival, then sub-atmospheric internal conditions are unavoidable, independent of whether the relief/check valve is ideal. Thus, for a given shipping envelope, there exists a critical ratio of compliance volume to rigid enclosed volume below which the concept is fundamentally incapable of guaranteeing nonnegative gauge pressure on the return leg.

The physical interpretation is straightforward. The compliance bag is not a source of gas; it is only a temporary volume reservoir. If the bag is undersized relative to the true connected gas volume, it will saturate on the outbound leg. Once that occurs, the system either experiences overpressure or vents nitrogen. If it vents nitrogen, then on the return leg the bag can collapse to zero volume and still fail, because the problem has become one of insufficient remaining gas mass in a fixed enclosure. At that point, any distributed leakage path becomes an inward leakage path. This is especially severe in the present architecture because the assembly contains many interconnected seals and fittings and because redesign of all such seals is not practical 

For this reason, the correct engineering requirement is not simply “add a breather bag” or “limit peak pressure.” The requirement is to maintain the total manifolded nitrogen volume at nonnegative, and preferably slightly positive, pressure relative to ambient over the full shipping state space, including the coupled pressure-temperature trajectory and any irreversible gas loss events. A passive compliance device is acceptable only if its available stroke volume, initial condition, leak integrity, and bias characteristics are sufficient to prevent the total connected system from ever entering a sub-atmospheric state. If that cannot be guaranteed, then the concept is non-robust regardless of whether the relief or check valve itself performs ideally.

Nitrogen shipping failure model notes
=====================================

What the model is trying to show
--------------------------------
This is a deliberately simple, explainable model for the shipping failure mechanism.

It treats the entire manifolded optical assembly as one fixed rigid gas volume:

- optical modules
- intake / exhaust manifolds
- PFA tubing
- all connected internal nitrogen space

The foil bag is modeled as an ideal passive compliance volume with:

- zero spring force
- a lower stop at 0 L
- an upper stop at V_bag,max

The vent / check valve is assumed to be ideal:

- it opens only outward
- it closes perfectly
- it never leaks inward

That assumption is important because it means any sub-atmospheric internal pressure is **not**
being blamed on the valve leaking inward. It is being blamed on the fact that the remaining
nitrogen mass is no longer enough to keep the fixed manifolded system at ambient pressure
once the bag has collapsed.

Core logic
----------
1. As ambient pressure falls and gas temperature rises, the nitrogen wants more volume.
2. If the bag has enough remaining headroom, the internal pressure stays near ambient.
3. If the bag runs out of expansion volume, internal pressure rises.
4. If the outward-only valve opens, nitrogen mass is lost.
5. On the return leg, the bag collapses.
6. If enough nitrogen mass was lost, then even with the bag fully collapsed there is not
   enough gas left to fill the rigid manifolded system at ambient pressure.
7. At that point P_internal < P_ambient, and ingress risk exists through the many other seals.

Two useful analytic thresholds
------------------------------
1) Outbound no-vent threshold

Let

    alpha = (P_seal / P_low) * (T_hot / T_seal)

Then venting is avoided only if

    alpha * (V_fixed + V_bag,init) <= V_fixed + V_bag,max

which gives

    V_fixed <= (V_bag,max - alpha * V_bag,init) / (alpha - 1)

For the default numbers in the scripts:

- sea-level seal-up at 20 C
- 8,000 ft cabin pressure equivalent
- hot case at 40 C
- bag max = 22 L
- initial bag fill = 11 L

the largest rigid fixed volume that avoids venting is only about 15.2 L.

2) Return-leg sub-atmospheric threshold after venting

If the system has already vented at the hot / low-pressure point while the bag is full, then
on the return leg the bag may collapse to zero and the remaining internal pressure becomes

    P_return,int = P_peak,abs * ((V_fixed + V_bag,max) / V_fixed) * (T_return / T_peak)

Return-leg sub-atmospheric pressure begins when

    P_return,int < P_return,abs

which gives

    V_fixed > V_bag,max / (gamma - 1)

where

    gamma = (P_return,abs * T_peak) / (P_peak,abs * T_return)

For the default numbers with ideal venting to ambient at the outbound peak, the threshold is
about 52.4 L.

How to use the scripts
----------------------
Python:
    python nitrogen_shipping_failure_model.py

MATLAB:
    run('nitrogen_shipping_failure_model.m')

What to vary first
------------------
- V_fixed_L:
  This is the most important unknown. It is the total rigid nitrogen volume of the connected
  modules + tubing + manifolds, excluding the current bag.

- V_bag_init_L:
  The actual bag fill at seal-up. This strongly affects how early the bag runs out of
  outbound headroom.

- V_bag_max_L:
  The actual maximum bag volume.

- P_vent_gauge_bar:
  Set this to the actual outward vent threshold if known.

Interpretation
--------------
If the model ever shows:

    P_internal - P_ambient < 0

then the bag / valve arrangement has failed to keep the manifolded system non-negative relative
to ambient. In that condition, any inward leakage path elsewhere in the assembly becomes an
ingress path for ambient contamination.

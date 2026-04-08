
"""
Nitrogen shipping failure model
--------------------------------
Purpose:
    Explain how an undersized passive compliance bag can still lead to
    sub-atmospheric internal pressure on the return leg, even if the
    outward-only check valve is assumed perfect (opens/closes correctly
    and never leaks inward).

Model assumptions:
    1) All optical modules + tubing + manifolds are lumped into one fixed
       rigid gas volume V_fixed.
    2) The foil bag is an ideal inextensible compliance volume with
       0 <= V_bag <= V_bag_max.
    3) The bag has essentially zero spring force, so while it is between
       its limits the internal pressure tracks ambient pressure.
    4) The check valve is ideal and only vents outward when internal
       pressure exceeds ambient by a set threshold.
    5) Internal gas temperature is prescribed by the user. In the default
       example it follows the same 20 C -> 40 C -> 20 C cycle used in the
       engineering note.
    6) Any time P_internal < P_ambient, ambient ingress risk exists through
       the many other seals in the module/tubing/manifold system.

This script generates:
    - a time history of ambient pressure, internal pressure, and bag volume
    - a pressure-differential plot for one or more cases
    - a sweep of minimum gauge pressure versus fixed system volume
    - printed analytic thresholds for quick discussion

Author's note:
    This is intentionally a simple quasi-static model. It is meant to make
    the failure mechanism explicit and easy to explain, not to be the final
    qualification model.
"""

import numpy as np
import matplotlib.pyplot as plt

R = 8.31446261815324  # J/mol-K
N2_MOLAR_MASS = 28.0134e-3  # kg/mol


def build_shipping_profile(dt_minutes=5,
                           t_seal_hr=0.0,
                           t_peak_hr=8.0,
                           t_hold_end_hr=16.0,
                           t_return_hr=24.0,
                           t_end_hr=36.0,
                           p_sea_level_bar=1.01325,
                           p_altitude_bar=0.753 * 1.01325,
                           t_seal_C=20.0,
                           t_peak_C=40.0,
                           t_return_C=20.0):
    """
    Piecewise shipping profile:
        seal at sea level and 20 C
        ramp to altitude + hot condition
        hold
        ramp back to sea level + 20 C
        hold
    """
    t_hr = np.arange(t_seal_hr, t_end_hr + dt_minutes / 60.0, dt_minutes / 60.0)
    p_amb_bar = np.zeros_like(t_hr)
    T_K = np.zeros_like(t_hr)

    T0 = t_seal_C + 273.15
    T1 = t_peak_C + 273.15
    T2 = t_return_C + 273.15

    for i, t in enumerate(t_hr):
        if t <= t_peak_hr:
            f = (t - t_seal_hr) / max(t_peak_hr - t_seal_hr, 1e-12)
            p_amb_bar[i] = p_sea_level_bar + f * (p_altitude_bar - p_sea_level_bar)
            T_K[i] = T0 + f * (T1 - T0)
        elif t <= t_hold_end_hr:
            p_amb_bar[i] = p_altitude_bar
            T_K[i] = T1
        elif t <= t_return_hr:
            f = (t - t_hold_end_hr) / max(t_return_hr - t_hold_end_hr, 1e-12)
            p_amb_bar[i] = p_altitude_bar + f * (p_sea_level_bar - p_altitude_bar)
            T_K[i] = T1 + f * (T2 - T1)
        else:
            p_amb_bar[i] = p_sea_level_bar
            T_K[i] = T2

    return t_hr, p_amb_bar, T_K


def analytic_threshold_no_vent(v_bag_init_L,
                               v_bag_max_L,
                               p_seal_bar_abs=1.01325,
                               p_low_bar_abs=0.753 * 1.01325,
                               T_seal_C=20.0,
                               T_hot_C=40.0):
    """
    Largest rigid fixed volume that can avoid venting on the outbound leg.

    Derived from:
        alpha = (P_seal / P_low) * (T_hot / T_seal)
        alpha * (V_fixed + V_bag_init) <= (V_fixed + V_bag_max)
    """
    T_seal_K = T_seal_C + 273.15
    T_hot_K = T_hot_C + 273.15
    alpha = (p_seal_bar_abs / p_low_bar_abs) * (T_hot_K / T_seal_K)
    if alpha <= 1.0:
        return np.inf
    v_fixed_limit_L = (v_bag_max_L - alpha * v_bag_init_L) / (alpha - 1.0)
    return v_fixed_limit_L


def analytic_threshold_negative_return(v_bag_max_L,
                                       p_peak_bar_abs=0.753 * 1.01325,
                                       p_return_bar_abs=1.01325,
                                       T_peak_C=40.0,
                                       T_return_C=20.0,
                                       min_required_gauge_bar=0.0):
    """
    Smallest rigid fixed volume that will go sub-atmospheric on the return leg
    after the system has vented at the outbound peak with the bag already full.

    Condition at return with bag collapsed to zero:
        P_return_internal = P_peak_abs * ((V_fixed + V_bag_max) / V_fixed) * (T_return / T_peak)

    Failure if:
        P_return_internal < P_return_abs + min_required_gauge
    """
    T_peak_K = T_peak_C + 273.15
    T_return_K = T_return_C + 273.15
    p_required_bar_abs = p_return_bar_abs + min_required_gauge_bar
    gamma = (p_required_bar_abs * T_peak_K) / (p_peak_bar_abs * T_return_K)
    if gamma <= 1.0:
        return 0.0
    return v_bag_max_L / (gamma - 1.0)


def simulate_case(v_fixed_L=60.0,
                  v_bag_init_L=11.0,
                  v_bag_max_L=22.0,
                  p_initial_gauge_bar=0.0,
                  p_vent_gauge_bar=0.0,
                  profile=None):
    """
    Simulate the bag / vent / collapse sequence.

    Regimes:
        1) Tracking ambient: 0 <= V_bag_required <= V_bag_max
        2) Bag full: if pressure exceeds vent threshold, vent outward only
        3) Bag collapsed: V_bag = 0, pressure set by remaining gas mass in V_fixed

    Returns:
        dict with time histories in bar, liters, and kilograms
    """
    if profile is None:
        profile = build_shipping_profile()

    t_hr, p_amb_bar, T_K = profile
    V_fixed = v_fixed_L / 1000.0
    V_bag_init = v_bag_init_L / 1000.0
    V_bag_max = v_bag_max_L / 1000.0

    # Initial nitrogen inventory at seal-up.
    n_mol = ((p_amb_bar[0] + p_initial_gauge_bar) * 1e5) * (V_fixed + V_bag_init) / (R * T_K[0])

    p_int_bar = np.zeros_like(t_hr)
    v_bag_L = np.zeros_like(t_hr)
    vented_mass_kg = np.zeros_like(t_hr)
    state = np.empty_like(t_hr, dtype=object)

    for i, (p_amb, T) in enumerate(zip(p_amb_bar, T_K)):
        # Free bag, no spring: internal pressure tracks ambient while bag has room.
        v_total_required = n_mol * R * T / (p_amb * 1e5)
        v_bag_required = 1000.0 * v_total_required - v_fixed_L  # liters

        if 0.0 <= v_bag_required <= v_bag_max_L:
            p_int_bar[i] = p_amb
            v_bag_L[i] = v_bag_required
            state[i] = "tracking ambient"

        elif v_bag_required > v_bag_max_L:
            v_bag_L[i] = v_bag_max_L
            p_trial_bar = (n_mol * R * T / ((V_fixed + V_bag_max) * 1e5))
            p_vent_abs_bar = p_amb + p_vent_gauge_bar

            if p_trial_bar > p_vent_abs_bar:
                n_after = (p_vent_abs_bar * 1e5) * (V_fixed + V_bag_max) / (R * T)
                vented_mass_kg[i] = max(0.0, (n_mol - n_after) * N2_MOLAR_MASS)
                n_mol = n_after
                p_int_bar[i] = p_vent_abs_bar
                state[i] = "venting"
            else:
                p_int_bar[i] = p_trial_bar
                state[i] = "bag full, no vent"
        else:
            v_bag_L[i] = 0.0
            p_int_bar[i] = (n_mol * R * T / (V_fixed * 1e5))
            state[i] = "bag collapsed"

    dp_bar = p_int_bar - p_amb_bar

    return {
        "t_hr": t_hr,
        "p_amb_bar": p_amb_bar,
        "T_C": T_K - 273.15,
        "p_int_bar": p_int_bar,
        "dp_bar": dp_bar,
        "v_bag_L": v_bag_L,
        "vented_mass_kg_step": vented_mass_kg,
        "state": state,
    }


def print_summary(case_name, result):
    idx_min = np.argmin(result["dp_bar"])
    print(f"\n=== {case_name} ===")
    print(f"Minimum internal-minus-ambient pressure = {result['dp_bar'][idx_min]:.4f} bar")
    print(f"Occurs at t = {result['t_hr'][idx_min]:.2f} hr")
    print(f"Bag volume at that time = {result['v_bag_L'][idx_min]:.2f} L")
    print(f"State at that time = {result['state'][idx_min]}")
    print(f"Total nitrogen vented = {np.sum(result['vented_mass_kg_step']):.6f} kg")


def plot_pressure_time(results_dict, title_suffix=""):
    plt.figure(figsize=(9, 5.5))
    for label, result in results_dict.items():
        plt.plot(result["t_hr"], result["dp_bar"], label=label)
    plt.axhline(0.0, linewidth=1.0)
    plt.xlabel("Time (hr)")
    plt.ylabel("Internal - Ambient Pressure (bar)")
    plt.title(f"Pressure differential vs time{title_suffix}")
    plt.legend()
    plt.tight_layout()


def plot_bag_volume_time(result, title="Bag volume vs time"):
    plt.figure(figsize=(9, 5.5))
    plt.plot(result["t_hr"], result["v_bag_L"])
    plt.xlabel("Time (hr)")
    plt.ylabel("Bag Volume (L)")
    plt.title(title)
    plt.tight_layout()


def plot_min_dp_sweep(v_fixed_values_L,
                      v_bag_init_L=11.0,
                      v_bag_max_L=22.0,
                      p_initial_gauge_bar=0.0,
                      p_vent_gauge_bar=0.0):
    mins = []
    for vf in v_fixed_values_L:
        r = simulate_case(v_fixed_L=vf,
                          v_bag_init_L=v_bag_init_L,
                          v_bag_max_L=v_bag_max_L,
                          p_initial_gauge_bar=p_initial_gauge_bar,
                          p_vent_gauge_bar=p_vent_gauge_bar)
        mins.append(np.min(r["dp_bar"]))

    plt.figure(figsize=(9, 5.5))
    plt.plot(v_fixed_values_L, mins)
    plt.axhline(0.0, linewidth=1.0)
    plt.xlabel("Rigid Fixed System Volume (L)")
    plt.ylabel("Minimum Internal - Ambient Pressure (bar)")
    plt.title("Worst-case gauge pressure vs rigid system volume")
    plt.tight_layout()


if __name__ == "__main__":
    # Example settings matching the engineering note envelope.
    V_BAG_MAX_L = 22.0
    V_BAG_INIT_L = 11.0
    P_INITIAL_GAUGE_BAR = 0.0
    P_VENT_GAUGE_BAR = 0.0

    # Analytic discussion points.
    no_vent_limit = analytic_threshold_no_vent(
        v_bag_init_L=V_BAG_INIT_L,
        v_bag_max_L=V_BAG_MAX_L,
        p_seal_bar_abs=1.01325 + P_INITIAL_GAUGE_BAR,
        p_low_bar_abs=0.753 * 1.01325,
        T_seal_C=20.0,
        T_hot_C=40.0,
    )

    negative_return_limit = analytic_threshold_negative_return(
        v_bag_max_L=V_BAG_MAX_L,
        p_peak_bar_abs=0.753 * 1.01325 + P_VENT_GAUGE_BAR,
        p_return_bar_abs=1.01325,
        T_peak_C=40.0,
        T_return_C=20.0,
        min_required_gauge_bar=0.0,
    )

    print("Analytic thresholds")
    print("-------------------")
    print(f"Largest rigid volume that avoids any venting on the outbound leg: {no_vent_limit:.2f} L")
    print(f"Smallest rigid volume that goes sub-atmospheric on return after venting: {negative_return_limit:.2f} L")

    # Two sample cases: one that remains non-negative, one that goes negative.
    safe_case = simulate_case(v_fixed_L=40.0,
                              v_bag_init_L=V_BAG_INIT_L,
                              v_bag_max_L=V_BAG_MAX_L,
                              p_initial_gauge_bar=P_INITIAL_GAUGE_BAR,
                              p_vent_gauge_bar=P_VENT_GAUGE_BAR)

    fail_case = simulate_case(v_fixed_L=60.0,
                              v_bag_init_L=V_BAG_INIT_L,
                              v_bag_max_L=V_BAG_MAX_L,
                              p_initial_gauge_bar=P_INITIAL_GAUGE_BAR,
                              p_vent_gauge_bar=P_VENT_GAUGE_BAR)

    print_summary("Safe-ish example: V_fixed = 40 L", safe_case)
    print_summary("Failing example: V_fixed = 60 L", fail_case)

    # Plots.
    plot_pressure_time({
        "V_fixed = 40 L": safe_case,
        "V_fixed = 60 L": fail_case,
    }, title_suffix=" (ideal bag + ideal outward-only vent)")

    plot_bag_volume_time(fail_case, title="Bag volume vs time for failing example (V_fixed = 60 L)")

    sweep_values = np.linspace(5.0, 100.0, 191)
    plot_min_dp_sweep(sweep_values,
                      v_bag_init_L=V_BAG_INIT_L,
                      v_bag_max_L=V_BAG_MAX_L,
                      p_initial_gauge_bar=P_INITIAL_GAUGE_BAR,
                      p_vent_gauge_bar=P_VENT_GAUGE_BAR)

    plt.show()

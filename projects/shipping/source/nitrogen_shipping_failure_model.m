
% Nitrogen shipping failure model
% --------------------------------
% Purpose:
%   Show how an undersized passive compliance bag can still produce
%   sub-atmospheric pressure on the return leg, even if the outward-only
%   vent valve is assumed perfect and never leaks inward.
%
% Model assumptions:
%   1) All optical modules + tubing + manifolds are lumped into one fixed
%      rigid gas volume V_fixed.
%   2) The foil bag is an ideal inextensible compliance volume with
%      0 <= V_bag <= V_bag_max.
%   3) While the bag is between its limits, internal pressure tracks ambient.
%   4) The check valve vents outward only when internal pressure exceeds
%      ambient by the chosen threshold.
%   5) Any time P_internal < P_ambient, ambient ingress risk exists through
%      the many other seals in the manifolded assembly.

clear; clc; close all;

%% User inputs
V_BAG_MAX_L = 22.0;
V_BAG_INIT_L = 11.0;
P_INITIAL_GAUGE_BAR = 0.0;
P_VENT_GAUGE_BAR = 0.0;

%% Analytic thresholds
noVentLimit = analytic_threshold_no_vent(V_BAG_INIT_L, V_BAG_MAX_L, 1.01325 + P_INITIAL_GAUGE_BAR, 0.753 * 1.01325, 20.0, 40.0);
negativeReturnLimit = analytic_threshold_negative_return(V_BAG_MAX_L, 0.753 * 1.01325 + P_VENT_GAUGE_BAR, 1.01325, 40.0, 20.0, 0.0);

fprintf('Analytic thresholds\n');
fprintf('-------------------\n');
fprintf('Largest rigid volume that avoids any venting on the outbound leg: %.2f L\n', noVentLimit);
fprintf('Smallest rigid volume that goes sub-atmospheric on return after venting: %.2f L\n', negativeReturnLimit);

%% Sample cases
safeCase = simulate_case(40.0, V_BAG_INIT_L, V_BAG_MAX_L, P_INITIAL_GAUGE_BAR, P_VENT_GAUGE_BAR);
failCase = simulate_case(60.0, V_BAG_INIT_L, V_BAG_MAX_L, P_INITIAL_GAUGE_BAR, P_VENT_GAUGE_BAR);

print_summary('Safe-ish example: V_fixed = 40 L', safeCase);
print_summary('Failing example: V_fixed = 60 L', failCase);

%% Plot 1: pressure differential vs time
figure;
plot(safeCase.t_hr, safeCase.dp_bar, 'DisplayName', 'V_{fixed} = 40 L'); hold on;
plot(failCase.t_hr, failCase.dp_bar, 'DisplayName', 'V_{fixed} = 60 L');
yline(0.0);
xlabel('Time (hr)');
ylabel('Internal - Ambient Pressure (bar)');
title('Pressure differential vs time (ideal bag + ideal outward-only vent)');
legend('Location', 'best');
grid on;

%% Plot 2: bag volume vs time for failing example
figure;
plot(failCase.t_hr, failCase.v_bag_L);
xlabel('Time (hr)');
ylabel('Bag Volume (L)');
title('Bag volume vs time for failing example (V_{fixed} = 60 L)');
grid on;

%% Plot 3: minimum gauge pressure sweep
vSweep = linspace(5.0, 100.0, 191);
mins = zeros(size(vSweep));
for i = 1:numel(vSweep)
    r = simulate_case(vSweep(i), V_BAG_INIT_L, V_BAG_MAX_L, P_INITIAL_GAUGE_BAR, P_VENT_GAUGE_BAR);
    mins(i) = min(r.dp_bar);
end

figure;
plot(vSweep, mins);
yline(0.0);
xlabel('Rigid Fixed System Volume (L)');
ylabel('Minimum Internal - Ambient Pressure (bar)');
title('Worst-case gauge pressure vs rigid system volume');
grid on;

%% Local functions
function [t_hr, p_amb_bar, T_K] = build_shipping_profile()
    dt_minutes = 5;
    t_seal_hr = 0.0;
    t_peak_hr = 8.0;
    t_hold_end_hr = 16.0;
    t_return_hr = 24.0;
    t_end_hr = 36.0;

    p_sea_level_bar = 1.01325;
    p_altitude_bar = 0.753 * 1.01325;

    T0 = 20.0 + 273.15;
    T1 = 40.0 + 273.15;
    T2 = 20.0 + 273.15;

    t_hr = t_seal_hr:(dt_minutes/60):t_end_hr;
    p_amb_bar = zeros(size(t_hr));
    T_K = zeros(size(t_hr));

    for i = 1:numel(t_hr)
        t = t_hr(i);
        if t <= t_peak_hr
            f = (t - t_seal_hr) / max(t_peak_hr - t_seal_hr, 1e-12);
            p_amb_bar(i) = p_sea_level_bar + f * (p_altitude_bar - p_sea_level_bar);
            T_K(i) = T0 + f * (T1 - T0);
        elseif t <= t_hold_end_hr
            p_amb_bar(i) = p_altitude_bar;
            T_K(i) = T1;
        elseif t <= t_return_hr
            f = (t - t_hold_end_hr) / max(t_return_hr - t_hold_end_hr, 1e-12);
            p_amb_bar(i) = p_altitude_bar + f * (p_sea_level_bar - p_altitude_bar);
            T_K(i) = T1 + f * (T2 - T1);
        else
            p_amb_bar(i) = p_sea_level_bar;
            T_K(i) = T2;
        end
    end
end

function v_fixed_limit_L = analytic_threshold_no_vent(v_bag_init_L, v_bag_max_L, p_seal_bar_abs, p_low_bar_abs, T_seal_C, T_hot_C)
    T_seal_K = T_seal_C + 273.15;
    T_hot_K = T_hot_C + 273.15;
    alpha = (p_seal_bar_abs / p_low_bar_abs) * (T_hot_K / T_seal_K);

    if alpha <= 1.0
        v_fixed_limit_L = inf;
    else
        v_fixed_limit_L = (v_bag_max_L - alpha * v_bag_init_L) / (alpha - 1.0);
    end
end

function v_fixed_limit_L = analytic_threshold_negative_return(v_bag_max_L, p_peak_bar_abs, p_return_bar_abs, T_peak_C, T_return_C, min_required_gauge_bar)
    T_peak_K = T_peak_C + 273.15;
    T_return_K = T_return_C + 273.15;
    p_required_bar_abs = p_return_bar_abs + min_required_gauge_bar;
    gamma = (p_required_bar_abs * T_peak_K) / (p_peak_bar_abs * T_return_K);

    if gamma <= 1.0
        v_fixed_limit_L = 0.0;
    else
        v_fixed_limit_L = v_bag_max_L / (gamma - 1.0);
    end
end

function result = simulate_case(v_fixed_L, v_bag_init_L, v_bag_max_L, p_initial_gauge_bar, p_vent_gauge_bar)
    R = 8.31446261815324;
    N2_MOLAR_MASS = 28.0134e-3;

    [t_hr, p_amb_bar, T_K] = build_shipping_profile();

    V_fixed = v_fixed_L / 1000.0;
    V_bag_init = v_bag_init_L / 1000.0;
    V_bag_max = v_bag_max_L / 1000.0;

    n_mol = ((p_amb_bar(1) + p_initial_gauge_bar) * 1e5) * (V_fixed + V_bag_init) / (R * T_K(1));

    p_int_bar = zeros(size(t_hr));
    v_bag_L = zeros(size(t_hr));
    vented_mass_kg = zeros(size(t_hr));
    state = strings(size(t_hr));

    for i = 1:numel(t_hr)
        p_amb = p_amb_bar(i);
        T = T_K(i);

        v_total_required = n_mol * R * T / (p_amb * 1e5);
        v_bag_required = 1000.0 * v_total_required - v_fixed_L;

        if (v_bag_required >= 0.0) && (v_bag_required <= v_bag_max_L)
            p_int_bar(i) = p_amb;
            v_bag_L(i) = v_bag_required;
            state(i) = "tracking ambient";

        elseif v_bag_required > v_bag_max_L
            v_bag_L(i) = v_bag_max_L;
            p_trial_bar = (n_mol * R * T / ((V_fixed + V_bag_max) * 1e5));
            p_vent_abs_bar = p_amb + p_vent_gauge_bar;

            if p_trial_bar > p_vent_abs_bar
                n_after = (p_vent_abs_bar * 1e5) * (V_fixed + V_bag_max) / (R * T);
                vented_mass_kg(i) = max(0.0, (n_mol - n_after) * N2_MOLAR_MASS);
                n_mol = n_after;
                p_int_bar(i) = p_vent_abs_bar;
                state(i) = "venting";
            else
                p_int_bar(i) = p_trial_bar;
                state(i) = "bag full, no vent";
            end
        else
            v_bag_L(i) = 0.0;
            p_int_bar(i) = (n_mol * R * T / (V_fixed * 1e5));
            state(i) = "bag collapsed";
        end
    end

    result.t_hr = t_hr;
    result.p_amb_bar = p_amb_bar;
    result.T_C = T_K - 273.15;
    result.p_int_bar = p_int_bar;
    result.dp_bar = p_int_bar - p_amb_bar;
    result.v_bag_L = v_bag_L;
    result.vented_mass_kg_step = vented_mass_kg;
    result.state = state;
end

function print_summary(caseName, result)
    [minVal, idx] = min(result.dp_bar);
    fprintf('\n=== %s ===\n', caseName);
    fprintf('Minimum internal-minus-ambient pressure = %.4f bar\n', minVal);
    fprintf('Occurs at t = %.2f hr\n', result.t_hr(idx));
    fprintf('Bag volume at that time = %.2f L\n', result.v_bag_L(idx));
    fprintf('State at that time = %s\n', result.state(idx));
    fprintf('Total nitrogen vented = %.6f kg\n', sum(result.vented_mass_kg_step));
end

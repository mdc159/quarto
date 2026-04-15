%% Nitrogen Shipping Thermodynamic Analysis
% Consolidated analysis of nitrogen shipping failure mechanisms.
% Traces the thermodynamic state of sealed nitrogen through the complete
% air-transport shipping cycle using ideal gas properties.
%
% Based on Python/CoolProp notebooks; validated against real-gas results
% (deviation < 300 ppm for N2 at these conditions).

%% 1. System Parameters

% Scenario presets
scenarios.baseline = struct( ...
    'V_fixed_L', 35, 'T_tarmac_peak_C', 40, 'T_cargo_C', 20, ...
    'cruise_alt_ft', 8000, 'P_crack_psig', 2.0, ...
    'label', 'Baseline (35 L, 20 C cargo, 2 psig Swagelok valve)');
scenarios.baseline_ideal_vent = struct( ...
    'V_fixed_L', 35, 'T_tarmac_peak_C', 40, 'T_cargo_C', 20, ...
    'cruise_alt_ft', 8000, 'P_crack_psig', 0.0, ...
    'label', 'Baseline volume, ideal vent (35 L, 0 psig)');
scenarios.cold_hold = struct( ...
    'V_fixed_L', 35, 'T_tarmac_peak_C', 40, 'T_cargo_C', 10, ...
    'cruise_alt_ft', 8000, 'P_crack_psig', 2.0, ...
    'label', 'Cold cargo hold (35 L, 10 C, 2 psig)');
scenarios.hot_day = struct( ...
    'V_fixed_L', 35, 'T_tarmac_peak_C', 50, 'T_cargo_C', 20, ...
    'cruise_alt_ft', 8000, 'P_crack_psig', 2.0, ...
    'label', 'Hot-day extreme (35 L, 50 C tarmac, 2 psig)');
scenarios.circuit_relief_only = struct( ...
    'V_fixed_L', 35, 'T_tarmac_peak_C', 40, 'T_cargo_C', 20, ...
    'cruise_alt_ft', 8000, 'P_crack_psig', 7.25, ...
    'label', '0.5 bar circuit relief only (no bag vent)');
scenarios.large_volume_failure = struct( ...
    'V_fixed_L', 80, 'T_tarmac_peak_C', 40, 'T_cargo_C', 20, ...
    'cruise_alt_ft', 8000, 'P_crack_psig', 0.0, ...
    'label', 'Large rigid volume failure demo (80 L, ideal vent)');
scenarios.worst_case = struct( ...
    'V_fixed_L', 80, 'T_tarmac_peak_C', 50, 'T_cargo_C', 25, ...
    'cruise_alt_ft', 8000, 'P_crack_psig', 0.0, ...
    'label', 'Worst case (80 L, 50 C tarmac, 25 C cargo)');

% ── SELECT ACTIVE SCENARIO ──
active_scenario = 'baseline';
S = scenarios.(active_scenario);
fprintf('Active scenario: %s\n  -> %s\n\n', active_scenario, S.label);

% Unit conversions
L_TO_M3    = 1e-3;
PSIG_TO_PA = 6894.76;
PSIG_TO_BAR = 0.0689475729;
ATM_TO_PA  = 101325.0;

V_fixed    = S.V_fixed_L * L_TO_M3;
V_bag_init = 11.0 * L_TO_M3;
V_bag_max  = 22.0 * L_TO_M3;
P_crack_Pa = S.P_crack_psig * PSIG_TO_PA;

% Okabe-Ito colorblind-safe palette
OI = struct( ...
    'blue',    [0.00 0.45 0.70], ...
    'orange',  [0.90 0.60 0.00], ...
    'green',   [0.00 0.62 0.45], ...
    'red',     [0.80 0.40 0.00], ...
    'purple',  [0.80 0.60 0.70], ...
    'cyan',    [0.35 0.70 0.90], ...
    'yellow',  [0.95 0.90 0.25]);

%% 2. Flight Profile

[t_hr, T_K, P_amb_Pa, seg_boundaries, seg_names] = build_flight_profile(S);

fprintf('Profile: %d timesteps over %.2f hr\n', length(t_hr), t_hr(end));

% 3-panel flight profile plot
figure('Position', [100 100 1200 700]);

subplot(3,1,1);
plot(t_hr, P_amb_Pa/1000, 'Color', OI.blue, 'LineWidth', 1.5);
yline(101.325, '--', 'Color', [0.75 0.75 0.75]);
ylabel('Ambient Pressure (kPa)');
title('Flight Profile');
grid on;

subplot(3,1,2);
plot(t_hr, T_K - 273.15, 'Color', OI.red, 'LineWidth', 1.5);
ylabel('Temperature (\circC)');
grid on;

subplot(3,1,3);
% Reconstruct altitude from pressure (inverse ISA, approximate)
alt_ft = (1 - (P_amb_Pa / 101325).^(1/5.2561)) / 6.8756e-6;
plot(t_hr, alt_ft, 'Color', OI.green, 'LineWidth', 1.5);
ylabel('Cabin Altitude (ft)');
xlabel('Time (hr)');
grid on;

%% 3. Analytic Screening

params_screen.v_bag_init_L     = 11.0;
params_screen.v_bag_max_L      = 22.0;
params_screen.p_seal_bar_abs   = 1.01325;
params_screen.p_low_bar_abs    = isa_pressure(S.cruise_alt_ft) / 1e5;
params_screen.T_seal_C         = 20.0;
params_screen.T_hot_C          = S.T_tarmac_peak_C;
params_screen.T_return_C       = 20.0;

% Ideal vent
params_screen.p_vent_gauge_bar = 0.0;
th_ideal = analytic_thresholds(params_screen);

% 2 psig
params_screen.p_vent_gauge_bar = 2.0 * PSIG_TO_BAR;
th_2psig = analytic_thresholds(params_screen);

% 5 psig
params_screen.p_vent_gauge_bar = 5.0 * PSIG_TO_BAR;
th_5psig = analytic_thresholds(params_screen);

fprintf('\n=== Analytic Screening Thresholds ===\n');
fprintf('%-45s %10s\n', 'Metric', 'Value (L)');
fprintf('%-45s %10.2f\n', 'No-vent limit (any vent config)', th_ideal.no_vent_limit_L);
fprintf('%-45s %10.2f\n', 'Return-negative limit (ideal vent)', th_ideal.return_negative_limit_L);
fprintf('%-45s %10.2f\n', 'Return-negative limit (2 psig)', th_2psig.return_negative_limit_L);
fprintf('%-45s %10.2f\n', 'Return-negative limit (5 psig)', th_5psig.return_negative_limit_L);

%% 4. Baseline Cases

% 40 L (safe) and 60 L (failure)
baseline_vols = [40, 60];
baseline_results = cell(1, 2);
baseline_labels = {'V_{fixed} = 40 L', 'V_{fixed} = 60 L'};

for k = 1:2
    Vf = baseline_vols(k) * L_TO_M3;
    baseline_results{k} = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, ...
        Vf, V_bag_init, V_bag_max, 0.0);
end

% Summary table
fprintf('\n=== Baseline Case Summary ===\n');
fprintf('%-20s %12s %12s %15s %12s\n', 'Case', 'Min dP (bar)', 'Time (hr)', 'State at min', 'Vented (kg)');
for k = 1:2
    r = baseline_results{k};
    [min_dp, idx] = min(r.delta_P_Pa);
    fprintf('%-20s %12.4f %12.2f %15s %12.6f\n', ...
        baseline_labels{k}, min_dp/1e5, r.t_hr(idx), r.state(idx), r.cum_vent_kg(end));
end

% 2-panel baseline plot
figure('Position', [100 100 1200 500]);

subplot(1,2,1);
hold on;
colors = {OI.blue, OI.red};
for k = 1:2
    plot(baseline_results{k}.t_hr, baseline_results{k}.delta_P_Pa / 1e5, ...
        'Color', colors{k}, 'LineWidth', 1.5, 'DisplayName', baseline_labels{k});
end
yline(0, 'k', 'LineWidth', 1);
xlabel('Time (hr)');
ylabel('Internal - Ambient Pressure (bar)');
title('Pressure Differential vs Time');
legend('Location', 'best');
grid on;
hold off;

subplot(1,2,2);
plot(baseline_results{2}.t_hr, baseline_results{2}.V_bag_m3 * 1000, ...
    'Color', OI.red, 'LineWidth', 1.5);
xlabel('Time (hr)');
ylabel('Bag Volume (L)');
title('Bag Volume — 60 L Case');
grid on;

%% 5. Five-Phase Walkthrough
% Detailed engineering narrative for each flight phase.
% Uses the active scenario's simulation result.

result = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, V_fixed, V_bag_init, V_bag_max, P_crack_Pa);

% Phase boundaries (mapped to segment boundaries)
phases = struct( ...
    'name', {'Phase 1: Ground Ops', 'Phase 2: Climb', 'Phase 3: Cruise', ...
             'Phase 4: Descent (CRITICAL)', 'Phase 5: Ground Return'}, ...
    'seg_start', {1, 4, 5, 6, 7}, ...
    'seg_end',   {3, 4, 5, 6, 9}, ...
    'description', { ...
        'Isobaric heating at sea level. Bag absorbs thermal expansion.', ...
        'Cabin depressurisation + cooling. Gas expands into lower ambient pressure.', ...
        'Steady state at altitude. Venting captured here if needed.', ...
        'Ambient pressure rises. Gas compresses. Bag contracts. Failure manifests here.', ...
        'Return to sea level. Cooling helps slightly but damage is done.'});

for p = 1:5
    ph = phases(p);
    i0 = seg_boundaries(ph.seg_start);
    if ph.seg_end < length(seg_boundaries)
        i1 = seg_boundaries(ph.seg_end + 1) - 1;
    else
        i1 = length(t_hr);
    end

    fprintf('\n=== %s ===\n', ph.name);
    fprintf('%s\n', ph.description);
    fprintf('Time range: %.2f - %.2f hr\n', t_hr(i0), t_hr(i1));

    % State table at phase boundaries
    fprintf('%-12s %10s %10s %10s %10s %12s\n', ...
        'Point', 'T (C)', 'P_amb(kPa)', 'P_int(kPa)', 'dP (Pa)', 'V_bag (L)');
    for idx = [i0, round((i0+i1)/2), i1]
        fprintf('%-12s %10.1f %10.2f %10.2f %10.1f %12.2f\n', ...
            sprintf('t=%.2f', t_hr(idx)), ...
            T_K(idx)-273.15, P_amb_Pa(idx)/1000, ...
            result.P_int_Pa(idx)/1000, result.delta_P_Pa(idx), ...
            result.V_bag_m3(idx)*1000);
    end

    % 4-panel phase plot
    sl = i0:i1;
    figure('Position', [100 100 1100 550]);
    sgtitle(ph.name, 'FontSize', 13, 'FontWeight', 'bold');

    subplot(2,2,1);
    plot(t_hr(sl), result.P_int_Pa(sl)/1000, 'Color', OI.blue, 'LineWidth', 1.2);
    hold on;
    plot(t_hr(sl), P_amb_Pa(sl)/1000, '--', 'Color', OI.blue + 0.4*(1-OI.blue));
    ylabel('Pressure (kPa)');
    legend('P_{int}', 'P_{amb}', 'Location', 'best', 'FontSize', 8);
    grid on; hold off;

    subplot(2,2,2);
    plot(t_hr(sl), result.V_bag_m3(sl)*1000, 'Color', OI.green, 'LineWidth', 1.2);
    yline(22, '--', 'Color', OI.red + 0.4*(1-OI.red));
    yline(0, 'k');
    ylabel('Bag Volume (L)');
    grid on;

    subplot(2,2,3);
    plot(t_hr(sl), result.mass_kg(sl)*1000, 'Color', OI.purple, 'LineWidth', 1.2);
    ylabel('N_2 Mass (g)');
    xlabel('Time (hr)');
    grid on;

    subplot(2,2,4);
    plot(t_hr(sl), result.delta_P_Pa(sl), 'Color', OI.red, 'LineWidth', 1.2);
    yline(0, 'k', 'LineWidth', 1);
    ylabel('\DeltaP (Pa)');
    xlabel('Time (hr)');
    grid on;
end

%% 6. Full Cycle Summary
% 4-panel overview with segment shading.

figure('Position', [100 100 1300 800]);
sgtitle(sprintf('Full Shipping Cycle — %s', S.label), 'FontSize', 13, 'FontWeight', 'bold');

panel_data = {
    result.P_int_Pa/1000, 'Pressure (kPa)', OI.blue, result.P_amb_Pa/1000
    result.V_bag_m3*1000, 'Bag Volume (L)', OI.green, []
    result.mass_kg*1000,  'N_2 Mass (g)',   OI.purple, []
    result.delta_P_Pa,    '\DeltaP (Pa)',   OI.red, []
};

% Alternating segment shading colors
shade_colors = [0.92 0.92 0.95; 0.98 0.98 0.98];

for row = 1:4
    subplot(4,1,row);
    hold on;

    % Segment shading
    for s = 1:length(seg_names)
        i0 = seg_boundaries(s);
        if s < length(seg_names)
            i1 = seg_boundaries(s+1) - 1;
        else
            i1 = length(t_hr);
        end
        x = [t_hr(i0) t_hr(i1) t_hr(i1) t_hr(i0)];
        y_lim = [-1e10 -1e10 1e10 1e10];
        patch(x, y_lim, shade_colors(mod(s-1,2)+1, :), ...
            'EdgeColor', 'none', 'FaceAlpha', 0.3);
    end

    % Data
    plot(t_hr, panel_data{row,1}, 'Color', panel_data{row,3}, 'LineWidth', 1.5);
    if ~isempty(panel_data{row,4})
        c = panel_data{row,3};
        plot(t_hr, panel_data{row,4}, '--', 'Color', c + 0.4*(1-c));
    end
    if row == 4
        yline(0, 'k', 'LineWidth', 1);
    end

    ylabel(panel_data{row,2});
    grid on;
    hold off;

    if row == 1
        % Add segment labels at top
        for s = 1:length(seg_names)
            i0 = seg_boundaries(s);
            if s < length(seg_names)
                i1 = seg_boundaries(s+1) - 1;
            else
                i1 = length(t_hr);
            end
            t_mid = (t_hr(i0) + t_hr(i1)) / 2;
            yl = ylim;
            text(t_mid, yl(2), sprintf('%d', s), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                'FontSize', 8, 'Color', [0.4 0.4 0.4]);
        end
    end
end
xlabel('Time (hr)');

%% 7. Failure Demonstration: V_fixed = 80 L
% Unambiguous underpressure case.

V_fail = 80e-3;
result_fail = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, V_fail, V_bag_init, V_bag_max, 0.0);

[dp_worst, i_worst] = min(result_fail.delta_P_Pa);
fprintf('\n=== Failure Demo (80 L, ideal vent) ===\n');
fprintf('Worst dP:    %.1f Pa (%.4f bar)\n', dp_worst, dp_worst/1e5);
fprintf('At time:     %.2f hr\n', t_hr(i_worst));
fprintf('State:       %s\n', result_fail.state(i_worst));
fprintf('Total vented: %.4f g\n', result_fail.cum_vent_kg(end)*1000);

figure('Position', [100 100 1100 550]);
sgtitle('Failure Demo: V_{fixed} = 80 L (ideal vent)', 'FontSize', 13, 'FontWeight', 'bold');

cyan_light = OI.cyan + 0.4*(1 - OI.cyan);

subplot(2,2,1);
plot(t_hr, result_fail.P_int_Pa/1000, 'Color', OI.blue, 'LineWidth', 1.5);
hold on;
plot(t_hr, P_amb_Pa/1000, '--', 'Color', cyan_light, 'LineWidth', 1);
ylabel('Pressure (kPa)'); legend('P_{int}', 'P_{amb}'); grid on; hold off;

subplot(2,2,2);
plot(t_hr, result_fail.V_bag_m3*1000, 'Color', OI.green, 'LineWidth', 1.5);
yline(22, '--r'); yline(0, 'k');
ylabel('Bag Volume (L)'); grid on;

subplot(2,2,3);
plot(t_hr, result_fail.mass_kg*1000, 'Color', OI.purple, 'LineWidth', 1.5);
ylabel('N_2 Mass (g)'); xlabel('Time (hr)'); grid on;

subplot(2,2,4);
plot(t_hr, result_fail.delta_P_Pa, 'Color', OI.red, 'LineWidth', 1.5);
yline(0, 'k', 'LineWidth', 1);
ylabel('\DeltaP (Pa)'); xlabel('Time (hr)'); grid on;

%% 8. V_fixed Sweep
% Worst-case gauge pressure vs rigid system volume.

sweep_vols = linspace(5, 120, 231);
sweep_min_dp = zeros(size(sweep_vols));

% Parallel Computing Toolbox: parfor for sweep
t_hr_par = t_hr; T_K_par = T_K; P_amb_par = P_amb_Pa;  % broadcast variables
parfor k = 1:length(sweep_vols)
    Vf = sweep_vols(k) * L_TO_M3;
    r = nitrogen_shipping_sim(t_hr_par, T_K_par, P_amb_par, Vf, V_bag_init, V_bag_max, 0.0);
    sweep_min_dp(k) = min(r.delta_P_Pa) / 1e5;  % bar
end

% Optimization Toolbox: fzero to find exact zero-crossing volume
dp_at_vol = @(Vf_L) min(nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, ...
    Vf_L*L_TO_M3, V_bag_init, V_bag_max, 0.0).delta_P_Pa) / 1e5;

V_zero_crossing = NaN;
if any(sweep_min_dp < 0) && any(sweep_min_dp >= 0)
    % Find a bracket: last positive and first negative
    idx_neg = find(sweep_min_dp < 0, 1, 'first');
    if idx_neg > 1
        V_zero_crossing = fzero(dp_at_vol, [sweep_vols(idx_neg-1) sweep_vols(idx_neg)]);
        fprintf('Exact zero-crossing volume (fzero): %.2f L\n', V_zero_crossing);
    end
end

% Optimization Toolbox: fminbnd to find volume with worst underpressure
[V_worst, dp_worst_bar] = fminbnd(dp_at_vol, 5, 120);
fprintf('Worst-case volume (fminbnd): %.2f L  min dP = %.4f bar\n', V_worst, dp_worst_bar);

figure('Position', [100 100 900 475]);
plot(sweep_vols, sweep_min_dp, 'Color', OI.blue, 'LineWidth', 2);
hold on;
yline(0, 'k', 'LineWidth', 1);
xline(th_ideal.no_vent_limit_L, '--', 'Color', OI.green, 'LineWidth', 1.5, ...
    'Label', 'No-vent limit', 'LabelVerticalAlignment', 'bottom');
xline(th_ideal.return_negative_limit_L, '--', 'Color', OI.red, 'LineWidth', 1.5, ...
    'Label', 'Return threshold', 'LabelVerticalAlignment', 'bottom');
if ~isnan(V_zero_crossing)
    xline(V_zero_crossing, '-.', 'Color', [0 0 0], 'LineWidth', 1.5, ...
        'Label', sprintf('Zero crossing: %.1f L', V_zero_crossing), ...
        'LabelVerticalAlignment', 'top');
end
plot(V_worst, dp_worst_bar, 'o', 'Color', OI.red, 'MarkerSize', 8, ...
    'MarkerFaceColor', OI.red, 'DisplayName', sprintf('Worst: %.1f L', V_worst));
xlabel('Rigid Fixed System Volume (L)');
ylabel('Minimum Internal - Ambient Pressure (bar)');
title('Worst-Case Gauge Pressure vs Rigid System Volume');
legend('Sweep', '', 'No-vent limit', 'Return threshold', ...
    'Zero crossing', 'Worst point', 'Location', 'best');
grid on;
hold off;

%% 9. Multi-Case Comparison
% Overlay multiple V_fixed values on a 2x2 grid.

comparison_vols = [12, 30, 45, 60, 90];
comp_colors = {OI.cyan, OI.green, OI.orange, OI.blue, OI.red};

figure('Position', [100 100 1200 700]);
sgtitle('Multi-Case Comparison', 'FontSize', 13, 'FontWeight', 'bold');

ax1 = subplot(2,2,1); hold(ax1, 'on');
ax2 = subplot(2,2,2); hold(ax2, 'on');
ax3 = subplot(2,2,3); hold(ax3, 'on');
ax4 = subplot(2,2,4); hold(ax4, 'on');

for k = 1:length(comparison_vols)
    Vf = comparison_vols(k) * L_TO_M3;
    r = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, Vf, V_bag_init, V_bag_max, 0.0);
    lbl = sprintf('%d L', comparison_vols(k));

    plot(ax1, r.t_hr, r.P_int_Pa/1000, 'Color', comp_colors{k}, 'LineWidth', 1.2, 'DisplayName', lbl);
    plot(ax2, r.t_hr, r.V_bag_m3*1000, 'Color', comp_colors{k}, 'LineWidth', 1.2, 'DisplayName', lbl);
    plot(ax3, r.t_hr, r.mass_kg*1000,  'Color', comp_colors{k}, 'LineWidth', 1.2, 'DisplayName', lbl);
    plot(ax4, r.t_hr, r.delta_P_Pa,    'Color', comp_colors{k}, 'LineWidth', 1.2, 'DisplayName', lbl);
end

ylabel(ax1, 'P_{int} (kPa)'); grid(ax1, 'on'); legend(ax1, 'Location', 'best', 'FontSize', 7);
ylabel(ax2, 'Bag Volume (L)'); grid(ax2, 'on');
ylabel(ax3, 'N_2 Mass (g)');   grid(ax3, 'on'); xlabel(ax3, 'Time (hr)');
ylabel(ax4, '\DeltaP (Pa)');   grid(ax4, 'on'); xlabel(ax4, 'Time (hr)');
yline(ax4, 0, 'k', 'LineWidth', 1);

hold(ax1, 'off'); hold(ax2, 'off'); hold(ax3, 'off'); hold(ax4, 'off');

%% 10. P_crack Sensitivity
% Sweep min dP vs V_fixed for several cracking pressures.

P_crack_values_psig = [0, 1, 2, 5];
crack_colors = {OI.blue, OI.green, OI.orange, OI.red};
sweep_vols_coarse = linspace(5, 120, 60);

figure('Position', [100 100 1000 500]);
hold on;

for c = 1:length(P_crack_values_psig)
    Pc = P_crack_values_psig(c) * PSIG_TO_PA;
    min_dp_sweep = zeros(size(sweep_vols_coarse));

    parfor k = 1:length(sweep_vols_coarse)
        Vf = sweep_vols_coarse(k) * L_TO_M3;
        r = nitrogen_shipping_sim(t_hr_par, T_K_par, P_amb_par, Vf, V_bag_init, V_bag_max, Pc);
        min_dp_sweep(k) = min(r.delta_P_Pa) / 1e5;
    end

    plot(sweep_vols_coarse, min_dp_sweep, 'Color', crack_colors{c}, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('%g psig', P_crack_values_psig(c)));
end

yline(0, 'k', 'LineWidth', 1);
xlabel('Rigid Fixed System Volume (L)');
ylabel('Minimum Internal - Ambient Pressure (bar)');
title('P_{crack} Sensitivity: Worst-Case Gauge Pressure');
legend('Location', 'best');
grid on;
hold off;

%% 11. Parametric Failure Surface
% 3D surface of min dP as a function of (V_fixed, T_tarmac).

Vf_range = linspace(5, 120, 50);
Tt_range = linspace(25, 55, 30);
[VF_grid, TT_grid] = meshgrid(Vf_range, Tt_range);
DP_grid = zeros(size(VF_grid));

fprintf('\nComputing failure surface (%d points)...\n', numel(VF_grid));

% Flatten grids for parfor (parfor requires integer indexing)
VF_flat = VF_grid(:);
TT_flat = TT_grid(:);
DP_flat = zeros(numel(VF_grid), 1);
S_par = S;  % broadcast variable

parfor i = 1:numel(VF_flat)
    s_sweep = S_par;
    s_sweep.T_tarmac_peak_C = TT_flat(i);
    [t_s, T_s, P_s] = build_flight_profile(s_sweep);
    Vf = VF_flat(i) * L_TO_M3;
    r = nitrogen_shipping_sim(t_s, T_s, P_s, Vf, V_bag_init, V_bag_max, 0.0);
    DP_flat(i) = min(r.delta_P_Pa) / 1e5;
end
DP_grid = reshape(DP_flat, size(VF_grid));

fprintf('Done.\n');

figure('Position', [100 100 1100 500]);

% Surface plot: V_fixed vs T_tarmac
subplot(1,2,1);
surf(VF_grid, TT_grid, DP_grid, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
hold on;
contour3(VF_grid, TT_grid, DP_grid, [0 0], 'k', 'LineWidth', 2);
hold off;
xlabel('V_{fixed} (L)');
ylabel('T_{tarmac} (\circC)');
zlabel('Min \DeltaP (bar)');
title('Failure Surface: V_{fixed} vs T_{tarmac}');
colormap(gca, coolwarm_diverging());
clim_abs = max(abs(DP_grid(:)));
clim([-clim_abs clim_abs]);
colorbar;
view([-35 30]);
grid on;

% Surface plot: V_fixed vs P_crack
Pc_range = linspace(0, 10, 25);
[VF_grid2, PC_grid] = meshgrid(Vf_range, Pc_range);
DP_grid2 = zeros(size(VF_grid2));

VF_flat2 = VF_grid2(:);
PC_flat = PC_grid(:);
DP_flat2 = zeros(numel(VF_grid2), 1);

parfor i = 1:numel(VF_flat2)
    Vf = VF_flat2(i) * L_TO_M3;
    Pc = PC_flat(i) * PSIG_TO_PA;
    r = nitrogen_shipping_sim(t_hr_par, T_K_par, P_amb_par, Vf, V_bag_init, V_bag_max, Pc);
    DP_flat2(i) = min(r.delta_P_Pa) / 1e5;
end
DP_grid2 = reshape(DP_flat2, size(VF_grid2));

subplot(1,2,2);
surf(VF_grid2, PC_grid, DP_grid2, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
hold on;
contour3(VF_grid2, PC_grid, DP_grid2, [0 0], 'k', 'LineWidth', 2);
hold off;
xlabel('V_{fixed} (L)');
ylabel('P_{crack} (psig)');
zlabel('Min \DeltaP (bar)');
title('Failure Surface: V_{fixed} vs P_{crack}');
colormap(gca, coolwarm_diverging());
clim_abs2 = max(abs(DP_grid2(:)));
clim([-clim_abs2 clim_abs2]);
colorbar;
view([-35 30]);
grid on;

% ── Helper: diverging colormap ──
function cmap = coolwarm_diverging()
    % Blue-white-red diverging colormap (64 steps)
    n = 64;
    half = n/2;
    blue_to_white = [linspace(0.2, 1, half)', linspace(0.4, 1, half)', linspace(0.7, 1, half)'];
    white_to_red  = [linspace(1, 0.7, half)', linspace(1, 0.2, half)', linspace(1, 0.2, half)'];
    cmap = [blue_to_white; white_to_red];
end

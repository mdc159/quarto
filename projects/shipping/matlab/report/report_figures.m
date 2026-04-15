function [fig_dir, results] = report_figures(output_dir)
%REPORT_FIGURES  Generate all figures for the nitrogen shipping report.
%   [fig_dir, results] = REPORT_FIGURES(output_dir)
%
%   Runs the shipping analysis with a two-leg flight profile, generates
%   8 high-resolution PNG figures, and returns a results struct with key
%   metrics for narrative text.
%
%   Figures saved to output_dir/figures/.

    %% Setup
    fig_dir = fullfile(output_dir, 'figures');
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir);
    end

    % Constants
    L_TO_M3    = 1e-3;
    PSIG_TO_PA = 6894.76;
    PSIG_TO_BAR = 0.0689475729;

    % Bag parameters (fixed across all cases)
    V_bag_init = 11.0 * L_TO_M3;   % 11 L initial fill
    V_bag_max  = 22.0 * L_TO_M3;   % 22 L max capacity

    % Okabe-Ito colorblind-safe palette
    OI.blue   = [0.00 0.45 0.70];
    OI.orange = [0.90 0.60 0.00];
    OI.green  = [0.00 0.62 0.45];
    OI.red    = [0.80 0.40 0.00];
    OI.purple = [0.80 0.60 0.70];
    OI.cyan   = [0.35 0.70 0.90];

    %% Build two-leg flight profile
    [t_hr, T_K, P_amb_Pa, seg_bounds, seg_names] = build_report_profile();

    %% Analytic thresholds
    P_cruise_Pa = isa_pressure(8000);

    params_screen.v_bag_init_L     = 11.0;
    params_screen.v_bag_max_L      = 22.0;
    params_screen.p_seal_bar_abs   = 1.01325;
    params_screen.p_low_bar_abs    = P_cruise_Pa / 1e5;
    params_screen.T_seal_C         = 20.0;
    params_screen.T_hot_C          = 35.0;
    params_screen.T_return_C       = 20.0;

    % Ideal vent thresholds
    params_screen.p_vent_gauge_bar = 0.0;
    th_ideal = analytic_thresholds(params_screen);

    % 2 psig thresholds
    params_screen.p_vent_gauge_bar = 2.0 * PSIG_TO_BAR;
    th_2psig = analytic_thresholds(params_screen);

    %% Run key simulations
    % Baseline: 35L, 2 psig
    r_base = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, ...
        35*L_TO_M3, V_bag_init, V_bag_max, 2.0*PSIG_TO_PA);

    % Failure: 60L, ideal vent
    r_fail = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, ...
        60*L_TO_M3, V_bag_init, V_bag_max, 0.0);

    %% Compute results struct
    results.no_vent_limit_L   = th_ideal.no_vent_limit_L;
    results.return_neg_ideal_L = th_ideal.return_negative_limit_L;
    results.return_neg_2psig_L = th_2psig.return_negative_limit_L;
    results.baseline_min_dp_Pa = min(r_base.delta_P_Pa);
    results.baseline_vented_g  = r_base.cum_vent_kg(end) * 1000;
    results.fail60_min_dp_Pa   = min(r_fail.delta_P_Pa);
    results.fail60_vented_g    = r_fail.cum_vent_kg(end) * 1000;

    % Zero-crossing volume (ideal vent) via fzero.
    % min(delta_P_Pa) is identically zero for all volumes where the bag
    % doesn't fully collapse (it's clamped at 0), so we find where
    % min(V_bag) first reaches zero. Subtract a tiny offset to create
    % a sign change for fzero.
    min_bag_at_vol = @(Vf_L) min(nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, ...
        Vf_L*L_TO_M3, V_bag_init, V_bag_max, 0.0).V_bag_m3) - 1e-6;
    results.zero_crossing_L = fzero(min_bag_at_vol, [30 100]);

    % T_relief_C: cargo temp needed for 0.5 bar relief at cruise
    P_seal = 101325.0;
    T_seal_K = 293.15;
    results.T_relief_C = (P_cruise_Pa + 0.5e5) * T_seal_K / P_seal - 273.15;

    %% Figure 1: Baseline cycle (3-panel)
    fprintf('Generating fig_baseline_cycle.png...\n');
    fh = figure('Visible', 'off', 'Position', [100 100 800 600]);

    % Cabin altitude from pressure
    alt_ft = (1 - (P_amb_Pa / 101325).^(1/5.2561)) / 6.8756e-6;

    subplot(3,1,1);
    plot(t_hr, alt_ft, 'Color', OI.blue, 'LineWidth', 1.5);
    ylabel('Cabin Altitude (ft)');
    title('Baseline: 35 L rigid, 2 psig Swagelok valve');
    grid on;
    add_phase_shading(gca, t_hr, seg_bounds, seg_names, OI);

    subplot(3,1,2);
    hold on;
    plot(t_hr, P_amb_Pa/1000, '--', 'Color', OI.blue + 0.4*(1-OI.blue), 'LineWidth', 1.2, 'DisplayName', 'P_{amb}');
    plot(t_hr, r_base.P_int_Pa/1000, 'Color', OI.blue, 'LineWidth', 1.5, 'DisplayName', 'P_{int}');
    ylabel('Pressure (kPa)');
    legend('Location', 'best', 'FontSize', 7);
    grid on; hold off;
    add_phase_shading(gca, t_hr, seg_bounds, seg_names, OI);

    subplot(3,1,3);
    hold on;
    plot(t_hr, r_base.V_bag_m3*1000, 'Color', OI.green, 'LineWidth', 1.5);
    yline(22, '--', 'Color', OI.red + 0.4*(1-OI.red), 'LineWidth', 1, 'Label', '22 L max');
    ylabel('Bag Volume (L)');
    xlabel('Time (hr)');
    grid on; hold off;
    add_phase_shading(gca, t_hr, seg_bounds, seg_names, OI);

    save_figure(fh, fullfile(fig_dir, 'fig_baseline_cycle.png'));

    %% Figure 2: Failure cycle (3-panel)
    fprintf('Generating fig_failure_cycle.png...\n');
    fh = figure('Visible', 'off', 'Position', [100 100 800 600]);

    subplot(3,1,1);
    plot(t_hr, alt_ft, 'Color', OI.blue, 'LineWidth', 1.5);
    ylabel('Cabin Altitude (ft)');
    title('Failure: 60 L rigid, ideal vent (0 psig)');
    grid on;
    add_phase_shading(gca, t_hr, seg_bounds, seg_names, OI);

    subplot(3,1,2);
    hold on;
    plot(t_hr, P_amb_Pa/1000, '--', 'Color', OI.blue + 0.4*(1-OI.blue), 'LineWidth', 1.2, 'DisplayName', 'P_{amb}');
    plot(t_hr, r_fail.P_int_Pa/1000, 'Color', OI.red, 'LineWidth', 1.5, 'DisplayName', 'P_{int}');
    ylabel('Pressure (kPa)');
    legend('Location', 'best', 'FontSize', 7);
    grid on; hold off;
    add_phase_shading(gca, t_hr, seg_bounds, seg_names, OI);

    subplot(3,1,3);
    hold on;
    plot(t_hr, r_fail.V_bag_m3*1000, 'Color', OI.red, 'LineWidth', 1.5);
    yline(22, '--', 'Color', OI.orange + 0.4*(1-OI.orange), 'LineWidth', 1, 'Label', '22 L max');
    yline(0, 'k', 'LineWidth', 0.5);
    ylabel('Bag Volume (L)');
    xlabel('Time (hr)');
    grid on; hold off;
    add_phase_shading(gca, t_hr, seg_bounds, seg_names, OI);

    save_figure(fh, fullfile(fig_dir, 'fig_failure_cycle.png'));

    %% Figure 3: Three regimes (2-panel side-by-side)
    fprintf('Generating fig_three_regimes.png...\n');
    fh = figure('Visible', 'off', 'Position', [100 100 1000 400]);

    regime_vols = [12, 60, 90];
    regime_colors = {OI.cyan, OI.green, OI.red};
    regime_labels = {'12 L', '60 L', '90 L'};

    ax1 = subplot(1,2,1); hold(ax1, 'on');
    ax2 = subplot(1,2,2); hold(ax2, 'on');

    h1 = gobjects(3,1); h2 = gobjects(3,1);
    for k = 1:3
        r = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, ...
            regime_vols(k)*L_TO_M3, V_bag_init, V_bag_max, 0.0);
        h1(k) = plot(ax1, r.t_hr, r.delta_P_Pa/1e5, 'Color', regime_colors{k}, ...
            'LineWidth', 1.5);
        h2(k) = plot(ax2, r.t_hr, r.V_bag_m3*1000, 'Color', regime_colors{k}, ...
            'LineWidth', 1.5);
    end

    yline(ax1, 0, 'k', 'LineWidth', 0.5);
    ylabel(ax1, '\DeltaP (bar)');
    xlabel(ax1, 'Time (hr)');
    title(ax1, 'Pressure Differential');
    legend(ax1, h1, regime_labels, 'Location', 'best', 'FontSize', 8);
    grid(ax1, 'on');

    yline(ax2, 22, '--', 'Color', OI.orange + 0.4*(1-OI.orange), 'LineWidth', 1);
    ylabel(ax2, 'Bag Volume (L)');
    xlabel(ax2, 'Time (hr)');
    title(ax2, 'Bag Volume');
    legend(ax2, h2, regime_labels, 'Location', 'best', 'FontSize', 8);
    grid(ax2, 'on');

    hold(ax1, 'off'); hold(ax2, 'off');
    save_figure(fh, fullfile(fig_dir, 'fig_three_regimes.png'));

    %% Figure 4: Min dP sweep (single panel)
    fprintf('Generating fig_min_dp_sweep.png...\n');
    fh = figure('Visible', 'off', 'Position', [100 100 800 450]);

    sweep_vols = linspace(5, 120, 231);
    sweep_dp_ideal = zeros(size(sweep_vols));
    sweep_dp_2psig = zeros(size(sweep_vols));

    Pc_2psig = 2.0 * PSIG_TO_PA;
    t_par = t_hr; T_par = T_K; P_par = P_amb_Pa;

    parfor k = 1:length(sweep_vols)
        Vf = sweep_vols(k) * L_TO_M3;
        r0 = nitrogen_shipping_sim(t_par, T_par, P_par, Vf, V_bag_init, V_bag_max, 0.0);
        r2 = nitrogen_shipping_sim(t_par, T_par, P_par, Vf, V_bag_init, V_bag_max, Pc_2psig);
        sweep_dp_ideal(k) = min(r0.delta_P_Pa) / 1e5;
        sweep_dp_2psig(k) = min(r2.delta_P_Pa) / 1e5;
    end

    hold on;
    h_ideal = plot(sweep_vols, sweep_dp_ideal, 'Color', OI.blue, 'LineWidth', 2);
    h_2psig = plot(sweep_vols, sweep_dp_2psig, 'Color', OI.orange, 'LineWidth', 2);
    yline(0, 'k', 'LineWidth', 1);
    xline(th_ideal.no_vent_limit_L, '--', 'Color', OI.green, 'LineWidth', 1.2, ...
        'Label', sprintf('No-vent: %.0f L', th_ideal.no_vent_limit_L), ...
        'LabelVerticalAlignment', 'bottom');
    xline(th_ideal.return_negative_limit_L, '--', 'Color', OI.red, 'LineWidth', 1.2, ...
        'Label', sprintf('Return-neg (ideal): %.0f L', th_ideal.return_negative_limit_L), ...
        'LabelVerticalAlignment', 'top');
    xline(th_2psig.return_negative_limit_L, '-.', 'Color', OI.red + 0.3*(1-OI.red), 'LineWidth', 1.2, ...
        'Label', sprintf('Return-neg (2 psig): %.0f L', th_2psig.return_negative_limit_L), ...
        'LabelVerticalAlignment', 'bottom');
    xlabel('Rigid Fixed System Volume (L)');
    ylabel('Minimum \DeltaP (bar)');
    title('Worst-Case Gauge Pressure vs Rigid Volume');
    legend([h_ideal, h_2psig], {'Ideal vent (0 psig)', '2 psig Swagelok'}, ...
        'Location', 'southwest', 'FontSize', 8);
    grid on; hold off;

    save_figure(fh, fullfile(fig_dir, 'fig_min_dp_sweep.png'));

    %% Figure 5: Case comparison (2x2 subplot)
    fprintf('Generating fig_case_comparison.png...\n');
    fh = figure('Visible', 'off', 'Position', [100 100 1000 700]);

    comp_vols = [12, 30, 45, 60, 90];
    comp_colors = {OI.cyan, OI.green, OI.orange, OI.blue, OI.red};

    ax1 = subplot(2,2,1); hold(ax1, 'on');
    ax2 = subplot(2,2,2); hold(ax2, 'on');
    ax3 = subplot(2,2,3); hold(ax3, 'on');
    ax4 = subplot(2,2,4); hold(ax4, 'on');

    n_comp = length(comp_vols);
    h_comp = gobjects(n_comp, 1);
    comp_labels = cell(n_comp, 1);
    for k = 1:n_comp
        r = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, ...
            comp_vols(k)*L_TO_M3, V_bag_init, V_bag_max, 0.0);
        comp_labels{k} = sprintf('%d L', comp_vols(k));
        h_comp(k) = plot(ax1, r.t_hr, r.P_int_Pa/1000, 'Color', comp_colors{k}, 'LineWidth', 1.2);
        plot(ax2, r.t_hr, r.V_bag_m3*1000,  'Color', comp_colors{k}, 'LineWidth', 1.2);
        plot(ax3, r.t_hr, r.mass_kg*1000,   'Color', comp_colors{k}, 'LineWidth', 1.2);
        plot(ax4, r.t_hr, r.delta_P_Pa,     'Color', comp_colors{k}, 'LineWidth', 1.2);
    end

    ylabel(ax1, 'P_{int} (kPa)');  title(ax1, 'Internal Pressure');
    ylabel(ax2, 'Bag Volume (L)'); title(ax2, 'Bag Volume');
    ylabel(ax3, 'N_2 Mass (g)');   title(ax3, 'Nitrogen Mass');
    ylabel(ax4, '\DeltaP (Pa)');   title(ax4, 'Pressure Differential');
    xlabel(ax3, 'Time (hr)'); xlabel(ax4, 'Time (hr)');
    legend(ax1, h_comp, comp_labels, 'Location', 'best', 'FontSize', 7);
    yline(ax4, 0, 'k', 'LineWidth', 0.5);
    grid(ax1,'on'); grid(ax2,'on'); grid(ax3,'on'); grid(ax4,'on');
    hold(ax1,'off'); hold(ax2,'off'); hold(ax3,'off'); hold(ax4,'off');

    sgtitle('Case Comparison: Ideal Vent, Multiple Volumes', 'FontSize', 12);
    save_figure(fh, fullfile(fig_dir, 'fig_case_comparison.png'));

    %% Figure 6: P_crack sensitivity (single panel)
    fprintf('Generating fig_pcrack_sensitivity.png...\n');
    fh = figure('Visible', 'off', 'Position', [100 100 800 450]);

    Pc_values_psig = [0, 1, 2, 5];
    crack_colors = {OI.blue, OI.green, OI.orange, OI.red};
    sweep_vols_coarse = linspace(5, 120, 60);

    hold on;
    for c = 1:length(Pc_values_psig)
        Pc = Pc_values_psig(c) * PSIG_TO_PA;
        dp_sweep = zeros(size(sweep_vols_coarse));
        parfor k = 1:length(sweep_vols_coarse)
            Vf = sweep_vols_coarse(k) * L_TO_M3;
            r = nitrogen_shipping_sim(t_par, T_par, P_par, Vf, V_bag_init, V_bag_max, Pc);
            dp_sweep(k) = min(r.delta_P_Pa) / 1e5;
        end
        plot(sweep_vols_coarse, dp_sweep, 'Color', crack_colors{c}, 'LineWidth', 1.5, ...
            'DisplayName', sprintf('%g psig', Pc_values_psig(c)));
    end
    yline(0, 'k', 'LineWidth', 1, 'HandleVisibility', 'off');
    xlabel('Rigid Fixed System Volume (L)');
    ylabel('Minimum \DeltaP (bar)');
    title('P_{crack} Sensitivity: Worst-Case Gauge Pressure');
    legend('Location', 'best', 'FontSize', 8);
    grid on; hold off;

    save_figure(fh, fullfile(fig_dir, 'fig_pcrack_sensitivity.png'));

    %% Figure 7: Failure boundary (contour on V_fixed vs T_cargo)
    fprintf('Generating fig_failure_boundary.png...\n');
    fh = figure('Visible', 'off', 'Position', [100 100 800 500]);

    Vf_range = linspace(5, 120, 80);
    Tc_range = linspace(5, 35, 60);
    [VF_g, TC_g] = meshgrid(Vf_range, Tc_range);

    Pc_boundary_psig = [0, 1, 2, 5, 7.25];
    boundary_colors = {OI.blue, OI.green, OI.orange, OI.red, OI.purple};

    hold on;
    half_bar_visible = false;
    for c = 1:length(Pc_boundary_psig)
        Pc = Pc_boundary_psig(c) * PSIG_TO_PA;
        DP_flat = zeros(numel(VF_g), 1);
        VF_flat = VF_g(:);
        TC_flat = TC_g(:);

        parfor i = 1:numel(VF_flat)
            [t_s, T_s, P_s] = build_report_profile('T_cargo_C', TC_flat(i));
            r = nitrogen_shipping_sim(t_s, T_s, P_s, ...
                VF_flat(i)*L_TO_M3, V_bag_init, V_bag_max, Pc);
            DP_flat(i) = min(r.delta_P_Pa) / 1e5;
        end
        DP_g = reshape(DP_flat, size(VF_g));

        % Draw the dP=0 contour
        C = contourc(Vf_range, Tc_range, DP_g, [0 0]);
        if ~isempty(C)
            % Parse contour matrix
            idx = 1;
            first_seg = true;
            while idx < size(C, 2)
                n_pts = C(2, idx);
                xc = C(1, idx+1:idx+n_pts);
                yc = C(2, idx+1:idx+n_pts);
                if first_seg
                    plot(xc, yc, 'Color', boundary_colors{c}, 'LineWidth', 1.8, ...
                        'DisplayName', sprintf('%g psig', Pc_boundary_psig(c)));
                    first_seg = false;
                else
                    plot(xc, yc, 'Color', boundary_colors{c}, 'LineWidth', 1.8, ...
                        'HandleVisibility', 'off');
                end
                idx = idx + n_pts + 1;
            end
            if c == 5
                half_bar_visible = true;
            end
        else
            % No zero crossing in range - plot invisible for legend
            plot(NaN, NaN, 'Color', boundary_colors{c}, 'LineWidth', 1.8, ...
                'DisplayName', sprintf('%g psig (not in range)', Pc_boundary_psig(c)));
            if c == 5
                half_bar_visible = false;
            end
        end
    end

    if ~half_bar_visible
        text(60, 30, '0.5 bar (7.25 psig) contour outside plotted range', ...
            'FontSize', 9, 'Color', OI.purple, 'FontAngle', 'italic', ...
            'HorizontalAlignment', 'center');
    end

    xlabel('Rigid Fixed System Volume (L)');
    ylabel('Cargo Temperature (\circC)');
    title('Failure Boundary (\DeltaP = 0) by Vent Setting');
    legend('Location', 'best', 'FontSize', 8);
    grid on; hold off;

    save_figure(fh, fullfile(fig_dir, 'fig_failure_boundary.png'));

    %% Figure 8: Failure surface (2-panel: filled contour + 3D)
    fprintf('Generating fig_failure_surface.png...\n');
    fh = figure('Visible', 'off', 'Position', [100 100 1100 450]);

    Vf_range_s = linspace(5, 120, 60);
    Tc_range_s = linspace(5, 35, 50);
    [VF_gs, TC_gs] = meshgrid(Vf_range_s, Tc_range_s);

    DP_flat_s = zeros(numel(VF_gs), 1);
    VF_flat_s = VF_gs(:);
    TC_flat_s = TC_gs(:);

    parfor i = 1:numel(VF_flat_s)
        [t_s, T_s, P_s] = build_report_profile('T_cargo_C', TC_flat_s(i));
        r = nitrogen_shipping_sim(t_s, T_s, P_s, ...
            VF_flat_s(i)*L_TO_M3, V_bag_init, V_bag_max, 0.0);
        DP_flat_s(i) = min(r.delta_P_Pa) / 1e5;
    end
    DP_gs = reshape(DP_flat_s, size(VF_gs));

    % Diverging colormap
    cmap = coolwarm_diverging();
    clim_abs = max(abs(DP_gs(:)));

    % Left: filled contour
    subplot(1,2,1);
    contourf(VF_gs, TC_gs, DP_gs, 20, 'LineColor', 'none');
    hold on;
    contour(VF_gs, TC_gs, DP_gs, [0 0], 'k', 'LineWidth', 2);
    hold off;
    colormap(gca, cmap);
    clim([-clim_abs clim_abs]);
    colorbar;
    xlabel('V_{fixed} (L)');
    ylabel('T_{cargo} (\circC)');
    title('Min \DeltaP (bar) — Ideal Vent');

    % Right: 3D surface
    subplot(1,2,2);
    surf(VF_gs, TC_gs, DP_gs, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
    hold on;
    contour3(VF_gs, TC_gs, DP_gs, [0 0], 'k', 'LineWidth', 2);
    hold off;
    colormap(gca, cmap);
    clim([-clim_abs clim_abs]);
    colorbar;
    xlabel('V_{fixed} (L)');
    ylabel('T_{cargo} (\circC)');
    zlabel('Min \DeltaP (bar)');
    title('Failure Surface');
    view([-35 30]);
    grid on;

    save_figure(fh, fullfile(fig_dir, 'fig_failure_surface.png'));

    fprintf('All figures saved to: %s\n', fig_dir);
end

%% ── Local Functions ──

function save_figure(fh, filepath)
%SAVE_FIGURE  Save figure as 300 dpi PNG and close.
    print(fh, filepath, '-dpng', '-r300');
    close(fh);
end

function add_phase_shading(ax, t_hr, seg_bounds, seg_names, OI)
%ADD_PHASE_SHADING  Add alternating light-colored phase bands.
%   Call AFTER plotting data so y-limits are established. Uses current
%   y-limits for patch extent and sends patches to back.
    light1 = OI.cyan + 0.7*(1 - OI.cyan);    % very light cyan
    light2 = OI.orange + 0.7*(1 - OI.orange); % very light orange

    yl = ylim(ax);
    y_lo = yl(1);
    y_hi = yl(2);

    was_held = ishold(ax);
    hold(ax, 'on');

    n_seg = length(seg_names);
    for s = 1:n_seg
        i0 = seg_bounds(s);
        if s < n_seg
            i1 = seg_bounds(s+1) - 1;
        else
            i1 = length(t_hr);
        end
        x = [t_hr(i0) t_hr(i1) t_hr(i1) t_hr(i0)];
        y = [y_lo y_lo y_hi y_hi];
        if mod(s,2) == 1
            c = light1;
        else
            c = light2;
        end
        ph = patch(ax, x, y, c, 'EdgeColor', 'none', 'FaceAlpha', 0.3, ...
            'HandleVisibility', 'off');
        uistack(ph, 'bottom');
    end
    % Lock the y-limits so they don't change
    ylim(ax, yl);
    if ~was_held
        hold(ax, 'off');
    end
end

function cmap = coolwarm_diverging()
%COOLWARM_DIVERGING  Blue-white-red diverging colormap (64 steps).
    n = 64;
    half = n/2;
    blue_to_white = [linspace(0.2, 1, half)', linspace(0.4, 1, half)', linspace(0.7, 1, half)'];
    white_to_red  = [linspace(1, 0.7, half)', linspace(1, 0.2, half)', linspace(1, 0.2, half)'];
    cmap = [blue_to_white; white_to_red];
end

function [t_hr, T_K, P_amb_Pa, seg_bounds, seg_names] = build_report_profile(varargin)
%BUILD_REPORT_PROFILE  Two-leg flight profile with ground turnaround.
%   [t_hr, T_K, P_amb_Pa, seg_bounds, seg_names] = BUILD_REPORT_PROFILE()
%   [t_hr, T_K, P_amb_Pa, seg_bounds, seg_names] = BUILD_REPORT_PROFILE('T_cargo_C', val)
%
%   Default: T_seal=20C, T_tarmac=35C, T_cargo=20C, cruise=8000ft, dt=2min.

    % Defaults
    T_seal_C    = 20.0;
    T_tarmac_C  = 35.0;
    T_cargo_C   = 20.0;
    cruise_ft   = 8000;
    dt_hr       = 2.0 / 60.0;   % 2-minute resolution

    % Parse optional name-value pairs
    for i = 1:2:length(varargin)
        switch varargin{i}
            case 'T_seal_C',   T_seal_C   = varargin{i+1};
            case 'T_tarmac_C', T_tarmac_C = varargin{i+1};
            case 'T_cargo_C',  T_cargo_C  = varargin{i+1};
            case 'cruise_ft',  cruise_ft  = varargin{i+1};
        end
    end

    T_seal_K   = T_seal_C + 273.15;
    T_tarmac_K = T_tarmac_C + 273.15;
    T_cargo_K  = T_cargo_C + 273.15;

    P_sea     = 101325.0;
    P_cruise  = isa_pressure(cruise_ft);

    % Segment definitions: {name, t_start, t_end, T_start_K, T_end_K, P_start, P_end}
    seg_defs = {
        'Seal-up hold',        0.0,  1.0,  T_seal_K,   T_seal_K,   P_sea,    P_sea
        'Tarmac warm-up',      1.0,  2.0,  T_seal_K,   T_tarmac_K, P_sea,    P_sea
        'Climb outbound',      2.0,  2.5,  T_tarmac_K, T_cargo_K,  P_sea,    P_cruise
        'Cruise outbound',     2.5,  6.0,  T_cargo_K,  T_cargo_K,  P_cruise, P_cruise
        'Descent outbound',    6.0,  6.5,  T_cargo_K,  T_tarmac_K, P_cruise, P_sea
        'Ground turnaround',   6.5,  8.0,  T_tarmac_K, T_tarmac_K, P_sea,    P_sea
        'Climb return',        8.0,  8.5,  T_tarmac_K, T_cargo_K,  P_sea,    P_cruise
        'Cruise return',       8.5,  12.0, T_cargo_K,  T_cargo_K,  P_cruise, P_cruise
        'Descent return',      12.0, 12.5, T_cargo_K,  T_seal_K,   P_cruise, P_sea
        'Post-landing hold',   12.5, 13.5, T_seal_K,   T_seal_K,   P_sea,    P_sea
    };

    n_seg = size(seg_defs, 1);
    seg_names = seg_defs(:, 1);

    t_list = [];
    T_list = [];
    P_list = [];
    seg_bounds = zeros(n_seg, 1);

    for s = 1:n_seg
        t0 = seg_defs{s, 2};
        t1 = seg_defs{s, 3};
        T0 = seg_defs{s, 4};
        T1 = seg_defs{s, 5};
        P0 = seg_defs{s, 6};
        P1 = seg_defs{s, 7};

        dur = t1 - t0;
        n_steps = max(round(dur / dt_hr), 1);
        seg_bounds(s) = length(t_list) + 1;

        for j = 0:n_steps-1
            frac = j / n_steps;
            t_list(end+1) = t0 + frac * dur;        %#ok<AGROW>
            T_list(end+1) = T0 + frac * (T1 - T0);  %#ok<AGROW>
            P_list(end+1) = P0 + frac * (P1 - P0);  %#ok<AGROW>
        end
    end

    % Final endpoint
    t_list(end+1) = seg_defs{end, 3};
    T_list(end+1) = seg_defs{end, 5};
    P_list(end+1) = seg_defs{end, 7};

    t_hr     = t_list(:);
    T_K      = T_list(:);
    P_amb_Pa = P_list(:);
end

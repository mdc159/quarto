function app = nitrogen_shipping_app()
%NITROGEN_SHIPPING_APP  Interactive nitrogen shipping cycle explorer.
%   Wraps the quasi-static simulation engine in a uifigure with:
%     - Collapsible control panel (sliders, presets, pass/fail lamp)
%     - Explorer tab: 4-panel time-series plot with segment shading
%     - Analysis tab: parametric sweep/surface views
%
%   app = nitrogen_shipping_app() returns the app struct with stored
%   function handles for programmatic testing.

    app = struct();

    % ── Constants ──
    app.L_TO_M3    = 1e-3;
    app.PSIG_TO_PA = 6894.76;
    app.PSIG_TO_BAR = 0.0689475729;

    app.V_BAG_INIT_L = 11.0;
    app.V_BAG_MAX_L  = 22.0;
    app.CRUISE_ALT_FT = 8000;

    % Okabe-Ito palette
    app.OI = struct( ...
        'blue',   [0.00 0.45 0.70], ...
        'orange', [0.90 0.60 0.00], ...
        'green',  [0.00 0.62 0.45], ...
        'red',    [0.80 0.40 0.00], ...
        'purple', [0.80 0.60 0.70], ...
        'cyan',   [0.35 0.70 0.90], ...
        'yellow', [0.95 0.90 0.25]);

    % Scenario presets: {name, V_fixed_L, T_tarmac_C, T_cargo_C, P_crack_psig}
    app.presets = {
        'baseline',             35, 40, 20, 2.0
        'baseline_ideal_vent',  35, 40, 20, 0.0
        'cold_hold',            35, 40, 10, 2.0
        'hot_day',              35, 50, 20, 2.0
        'circuit_relief_only',  35, 40, 20, 7.25
        'large_volume_failure', 80, 40, 20, 0.0
        'worst_case',           80, 50, 25, 0.0
    };

    app.panelExpanded = true;
    app.panelWidth = 260;

    % ── Figure ──
    app.fig = uifigure('Name', 'Nitrogen Shipping Explorer', ...
        'Position', [100 100 1200 800]);

    % ── Top-level grid: [toggle button | main content] ──
    app.topGrid = uigridlayout(app.fig, [1, 3], ...
        'ColumnWidth', {30, app.panelWidth, '1x'}, ...
        'Padding', [0 0 0 0], 'ColumnSpacing', 0, 'RowSpacing', 0);

    % Toggle button (column 1)
    app.toggleBtn = uibutton(app.topGrid, 'Text', char(9664), ...
        'ButtonPushedFcn', @(~,~) togglePanel(app));
    app.toggleBtn.Layout.Row = 1;
    app.toggleBtn.Layout.Column = 1;
    app.toggleBtn.FontSize = 14;
    app.toggleBtn.Tooltip = 'Toggle control panel';

    % Control panel container (column 2)
    app.panelContainer = uipanel(app.topGrid, 'Title', '');
    app.panelContainer.Layout.Row = 1;
    app.panelContainer.Layout.Column = 2;

    % Tab group (column 3)
    app.tabGroup = uitabgroup(app.topGrid);
    app.tabGroup.Layout.Row = 1;
    app.tabGroup.Layout.Column = 3;

    app.explorerTab = uitab(app.tabGroup, 'Title', 'Explorer');
    app.analysisTab = uitab(app.tabGroup, 'Title', 'Analysis');

    % ── Explorer Tab: 4-panel plot ──
    app.explorerGrid = uigridlayout(app.explorerTab, [2, 2], ...
        'Padding', [10 10 10 10], 'RowSpacing', 10, 'ColumnSpacing', 10);

    app.ax_pressure = uiaxes(app.explorerGrid);
    app.ax_pressure.Layout.Row = 1; app.ax_pressure.Layout.Column = 1;
    title(app.ax_pressure, 'Pressure'); ylabel(app.ax_pressure, 'kPa');
    grid(app.ax_pressure, 'on');

    app.ax_bag = uiaxes(app.explorerGrid);
    app.ax_bag.Layout.Row = 1; app.ax_bag.Layout.Column = 2;
    title(app.ax_bag, 'Bag Volume'); ylabel(app.ax_bag, 'L');
    grid(app.ax_bag, 'on');

    app.ax_mass = uiaxes(app.explorerGrid);
    app.ax_mass.Layout.Row = 2; app.ax_mass.Layout.Column = 1;
    title(app.ax_mass, 'N_2 Mass'); ylabel(app.ax_mass, 'g');
    xlabel(app.ax_mass, 'Time (hr)'); grid(app.ax_mass, 'on');

    app.ax_dp = uiaxes(app.explorerGrid);
    app.ax_dp.Layout.Row = 2; app.ax_dp.Layout.Column = 2;
    title(app.ax_dp, '\DeltaP'); ylabel(app.ax_dp, 'psig');
    xlabel(app.ax_dp, 'Time (hr)'); grid(app.ax_dp, 'on');

    % ── Control Panel Layout ──
    app.panelGrid = uigridlayout(app.panelContainer, [15, 2], ...
        'ColumnWidth', {'1x', '1x'}, ...
        'RowHeight', {22, 30, 22, 30, 22, 22, 30, 22, 30, 22, 30, 22, 30, 'fit', '1x'}, ...
        'Padding', [8 8 8 8], 'RowSpacing', 4);

    % Row 1-2: Scenario dropdown
    lbl = uilabel(app.panelGrid, 'Text', 'Scenario Preset', 'FontWeight', 'bold');
    lbl.Layout.Row = 1; lbl.Layout.Column = [1 2];

    presetNames = [app.presets(:,1); {'Custom'}];
    app.presetDropdown = uidropdown(app.panelGrid, ...
        'Items', presetNames, 'Value', 'baseline', ...
        'ValueChangedFcn', @(src,~) presetChanged(app, src.Value));
    app.presetDropdown.Layout.Row = 2; app.presetDropdown.Layout.Column = [1 2];

    % Row 3-4: V_fixed slider
    lbl = uilabel(app.panelGrid, 'Text', 'V_fixed (L)');
    lbl.Layout.Row = 3; lbl.Layout.Column = 1;
    app.VfixedEdit = uieditfield(app.panelGrid, 'numeric', ...
        'Value', 35, 'Limits', [5 120], 'ValueDisplayFormat', '%.1f', ...
        'ValueChangedFcn', @(src,~) sliderEditChanged(app, 'Vfixed', src.Value, 'edit'));
    app.VfixedEdit.Layout.Row = 3; app.VfixedEdit.Layout.Column = 2;
    app.VfixedSlider = uislider(app.panelGrid, 'Limits', [5 120], 'Value', 35, ...
        'ValueChangedFcn', @(src,~) sliderEditChanged(app, 'Vfixed', src.Value, 'slider'));
    app.VfixedSlider.Layout.Row = 4; app.VfixedSlider.Layout.Column = [1 2];

    % Row 5-6: T_tarmac slider
    lbl = uilabel(app.panelGrid, 'Text', 'T_tarmac (C)');
    lbl.Layout.Row = 5; lbl.Layout.Column = 1;
    app.TtarmacEdit = uieditfield(app.panelGrid, 'numeric', ...
        'Value', 40, 'Limits', [30 55], 'ValueDisplayFormat', '%.1f', ...
        'ValueChangedFcn', @(src,~) sliderEditChanged(app, 'Ttarmac', src.Value, 'edit'));
    app.TtarmacEdit.Layout.Row = 5; app.TtarmacEdit.Layout.Column = 2;
    app.TtarmacSlider = uislider(app.panelGrid, 'Limits', [30 55], 'Value', 40, ...
        'ValueChangedFcn', @(src,~) sliderEditChanged(app, 'Ttarmac', src.Value, 'slider'));
    app.TtarmacSlider.Layout.Row = 6; app.TtarmacSlider.Layout.Column = [1 2];

    % Row 7-8: T_cargo slider
    lbl = uilabel(app.panelGrid, 'Text', 'T_cargo (C)');
    lbl.Layout.Row = 7; lbl.Layout.Column = 1;
    app.TcargoEdit = uieditfield(app.panelGrid, 'numeric', ...
        'Value', 20, 'Limits', [5 30], 'ValueDisplayFormat', '%.1f', ...
        'ValueChangedFcn', @(src,~) sliderEditChanged(app, 'Tcargo', src.Value, 'edit'));
    app.TcargoEdit.Layout.Row = 7; app.TcargoEdit.Layout.Column = 2;
    app.TcargoSlider = uislider(app.panelGrid, 'Limits', [5 30], 'Value', 20, ...
        'ValueChangedFcn', @(src,~) sliderEditChanged(app, 'Tcargo', src.Value, 'slider'));
    app.TcargoSlider.Layout.Row = 8; app.TcargoSlider.Layout.Column = [1 2];

    % Row 9-10: P_crack slider
    lbl = uilabel(app.panelGrid, 'Text', 'P_crack (psig)');
    lbl.Layout.Row = 9; lbl.Layout.Column = 1;
    app.PcrackEdit = uieditfield(app.panelGrid, 'numeric', ...
        'Value', 2.0, 'Limits', [0 10], 'ValueDisplayFormat', '%.2f', ...
        'ValueChangedFcn', @(src,~) sliderEditChanged(app, 'Pcrack', src.Value, 'edit'));
    app.PcrackEdit.Layout.Row = 9; app.PcrackEdit.Layout.Column = 2;
    app.PcrackSlider = uislider(app.panelGrid, 'Limits', [0 10], 'Value', 2.0, ...
        'ValueChangedFcn', @(src,~) sliderEditChanged(app, 'Pcrack', src.Value, 'slider'));
    app.PcrackSlider.Layout.Row = 10; app.PcrackSlider.Layout.Column = [1 2];

    % Row 11: Pass/Fail lamp + min dP readout
    app.statusLamp = uilamp(app.panelGrid, 'Color', [0.5 0.5 0.5]);
    app.statusLamp.Layout.Row = 11; app.statusLamp.Layout.Column = 1;
    app.minDpLabel = uilabel(app.panelGrid, 'Text', '-- psig', ...
        'FontSize', 18, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    app.minDpLabel.Layout.Row = 11; app.minDpLabel.Layout.Column = 2;

    % Row 12: Separator label
    lbl = uilabel(app.panelGrid, 'Text', 'Summary Metrics', 'FontWeight', 'bold');
    lbl.Layout.Row = 12; lbl.Layout.Column = [1 2];

    % Row 13-14: Metrics text area (read-only)
    app.metricsArea = uitextarea(app.panelGrid, ...
        'Value', {'Min dP: --', 'Time at min: --', 'Vented: --', ...
                  'No-vent limit: --', 'Return-neg limit: --'}, ...
        'Editable', 'off', 'FontSize', 10);
    app.metricsArea.Layout.Row = [13 15]; app.metricsArea.Layout.Column = [1 2];

    % ── Analysis Tab ──
    app.analysisGrid = uigridlayout(app.analysisTab, [2, 1], ...
        'RowHeight', {30, '1x'}, 'Padding', [10 10 10 10], 'RowSpacing', 8);

    app.analysisTopGrid = uigridlayout(app.analysisGrid, [1, 3], ...
        'ColumnWidth', {200, 80, '1x'}, 'Padding', [0 0 0 0]);
    app.analysisTopGrid.Layout.Row = 1; app.analysisTopGrid.Layout.Column = 1;

    app.viewDropdown = uidropdown(app.analysisTopGrid, ...
        'Items', {'V_fixed Sweep', 'Multi-Case Overlay', ...
                  'P_crack Sensitivity', 'Failure Surface'}, ...
        'Value', 'V_fixed Sweep', ...
        'ValueChangedFcn', @(~,~) updateAnalysis(app));
    app.viewDropdown.Layout.Row = 1; app.viewDropdown.Layout.Column = 1;

    app.refreshBtn = uibutton(app.analysisTopGrid, 'Text', 'Refresh', ...
        'ButtonPushedFcn', @(~,~) updateAnalysis(app));
    app.refreshBtn.Layout.Row = 1; app.refreshBtn.Layout.Column = 2;

    app.analysisPanel = uipanel(app.analysisGrid, 'Title', '');
    app.analysisPanel.Layout.Row = 2; app.analysisPanel.Layout.Column = 1;

    app.ax_analysis = uiaxes(app.analysisPanel);
    app.ax_analysis.Position = [50 50 ...
        app.analysisPanel.Position(3)-80 app.analysisPanel.Position(4)-80];

    % ── Expose local functions for programmatic testing ──
    app.fn_presetChanged     = @presetChanged;
    app.fn_sliderEditChanged = @sliderEditChanged;
    app.fn_togglePanel       = @togglePanel;
    app.fn_updateAnalysis    = @updateAnalysis;
    app.fn_updateSimulation  = @updateSimulation;

    % ── Initial simulation ──
    guidata(app.fig, app);
    presetChanged(app, 'baseline');

    % Re-read guidata (presetChanged updates it)
    app = guidata(app.fig);
end

function togglePanel(app)
    app = guidata(app.fig);
    if app.panelExpanded
        app.topGrid.ColumnWidth{2} = 0;
        app.panelContainer.Visible = 'off';
        app.toggleBtn.Text = char(9654);  % right arrow
    else
        app.topGrid.ColumnWidth{2} = app.panelWidth;
        app.panelContainer.Visible = 'on';
        app.toggleBtn.Text = char(9664);  % left arrow
    end
    app.panelExpanded = ~app.panelExpanded;
    guidata(app.fig, app);
end

function presetChanged(app, name)
    app = guidata(app.fig);
    if strcmp(name, 'Custom')
        return;
    end
    idx = find(strcmp(app.presets(:,1), name), 1);
    if isempty(idx), return; end

    app.VfixedSlider.Value  = app.presets{idx, 2};
    app.VfixedEdit.Value    = app.presets{idx, 2};
    app.TtarmacSlider.Value = app.presets{idx, 3};
    app.TtarmacEdit.Value   = app.presets{idx, 3};
    app.TcargoSlider.Value  = app.presets{idx, 4};
    app.TcargoEdit.Value    = app.presets{idx, 4};
    app.PcrackSlider.Value  = app.presets{idx, 5};
    app.PcrackEdit.Value    = app.presets{idx, 5};

    guidata(app.fig, app);
    updateSimulation(app);
end

function sliderEditChanged(app, param, value, source)
    app = guidata(app.fig);
    switch param
        case 'Vfixed'
            if strcmp(source, 'slider')
                app.VfixedEdit.Value = value;
            else
                app.VfixedSlider.Value = value;
            end
        case 'Ttarmac'
            if strcmp(source, 'slider')
                app.TtarmacEdit.Value = value;
            else
                app.TtarmacSlider.Value = value;
            end
        case 'Tcargo'
            if strcmp(source, 'slider')
                app.TcargoEdit.Value = value;
            else
                app.TcargoSlider.Value = value;
            end
        case 'Pcrack'
            if strcmp(source, 'slider')
                app.PcrackEdit.Value = value;
            else
                app.PcrackSlider.Value = value;
            end
    end
    app.presetDropdown.Value = 'Custom';
    guidata(app.fig, app);
    updateSimulation(app);
end

function updateSimulation(app)
    app = guidata(app.fig);

    V_fixed_L  = app.VfixedSlider.Value;
    T_tarmac_C = app.TtarmacSlider.Value;
    T_cargo_C  = app.TcargoSlider.Value;
    P_crack_psig = app.PcrackSlider.Value;

    scenario = struct( ...
        'V_fixed_L',       V_fixed_L, ...
        'T_tarmac_peak_C', T_tarmac_C, ...
        'T_cargo_C',       T_cargo_C, ...
        'cruise_alt_ft',   app.CRUISE_ALT_FT, ...
        'P_crack_psig',    P_crack_psig);

    [t_hr, T_K, P_amb_Pa, seg_boundaries, seg_names] = build_flight_profile(scenario);
    V_fixed  = V_fixed_L * app.L_TO_M3;
    V_bag_init = app.V_BAG_INIT_L * app.L_TO_M3;
    V_bag_max  = app.V_BAG_MAX_L * app.L_TO_M3;
    P_crack_Pa = P_crack_psig * app.PSIG_TO_PA;

    result = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, ...
        V_fixed, V_bag_init, V_bag_max, P_crack_Pa);

    params_th = struct( ...
        'v_bag_init_L',     app.V_BAG_INIT_L, ...
        'v_bag_max_L',      app.V_BAG_MAX_L, ...
        'p_seal_bar_abs',   1.01325, ...
        'p_low_bar_abs',    isa_pressure(app.CRUISE_ALT_FT) / 1e5, ...
        'T_seal_C',         20.0, ...
        'T_hot_C',          T_tarmac_C, ...
        'T_return_C',       20.0, ...
        'p_vent_gauge_bar', P_crack_psig * app.PSIG_TO_BAR);
    thresholds = analytic_thresholds(params_th);

    app.lastResult = result;
    app.lastProfile = struct('t_hr', t_hr, 'T_K', T_K, 'P_amb_Pa', P_amb_Pa, ...
        'seg_boundaries', seg_boundaries, 'seg_names', {seg_names});
    app.lastThresholds = thresholds;
    app.lastScenario = scenario;

    plotExplorer(app, result, t_hr, P_amb_Pa, seg_boundaries, seg_names);

    [min_dp_Pa, min_idx] = min(result.delta_P_Pa);
    min_dp_psig = min_dp_Pa / app.PSIG_TO_PA;

    if min_dp_Pa >= 0
        app.statusLamp.Color = [0.0 0.8 0.0];
    else
        app.statusLamp.Color = [0.9 0.1 0.1];
    end
    app.minDpLabel.Text = sprintf('%.2f psig', min_dp_psig);

    app.metricsArea.Value = {
        sprintf('Min dP: %.2f psig', min_dp_psig)
        sprintf('Time at min: %.2f hr', t_hr(min_idx))
        sprintf('Vented: %.1f g', result.cum_vent_kg(end) * 1000)
        sprintf('No-vent limit: %.1f L', thresholds.no_vent_limit_L)
        sprintf('Return-neg limit: %.1f L', thresholds.return_negative_limit_L)
    };

    guidata(app.fig, app);
end

function plotExplorer(app, result, t_hr, P_amb_Pa, seg_boundaries, seg_names)
    shade_colors = [0.92 0.92 0.95; 0.98 0.98 0.98];
    axes_list = [app.ax_pressure, app.ax_bag, app.ax_mass, app.ax_dp];

    panel_data = {
        result.P_int_Pa/1000,   'Pressure (kPa)',  app.OI.blue,   P_amb_Pa/1000
        result.V_bag_m3*1000,   'Bag Volume (L)',   app.OI.green,  []
        result.mass_kg*1000,    'N_2 Mass (g)',     app.OI.purple, []
        result.delta_P_Pa/app.PSIG_TO_PA, '\DeltaP (psig)', app.OI.red, []
    };

    for p = 1:4
        ax = axes_list(p);
        cla(ax);
        hold(ax, 'on');

        for s = 1:length(seg_names)
            i0 = seg_boundaries(s);
            if s < length(seg_names)
                i1 = seg_boundaries(s+1) - 1;
            else
                i1 = length(t_hr);
            end
            x = [t_hr(i0) t_hr(i1) t_hr(i1) t_hr(i0)];
            yl = [-1e10 -1e10 1e10 1e10];
            patch(ax, x, yl, shade_colors(mod(s-1,2)+1, :), ...
                'EdgeColor', 'none', 'FaceAlpha', 0.3, ...
                'HandleVisibility', 'off');
        end

        plot(ax, t_hr, panel_data{p,1}, 'Color', panel_data{p,3}, 'LineWidth', 1.5);

        if ~isempty(panel_data{p,4})
            c = panel_data{p,3};
            plot(ax, t_hr, panel_data{p,4}, '--', ...
                'Color', c + 0.4*(1-c), 'LineWidth', 1);
        end

        if p == 4
            yline(ax, 0, 'k', 'LineWidth', 1);
        end

        ylabel(ax, panel_data{p,2});
        hold(ax, 'off');

        if p == 1
            for s = 1:length(seg_names)
                i0 = seg_boundaries(s);
                if s < length(seg_names)
                    i1 = seg_boundaries(s+1) - 1;
                else
                    i1 = length(t_hr);
                end
                t_mid = (t_hr(i0) + t_hr(i1)) / 2;
                yl = ylim(ax);
                text(ax, t_mid, yl(2), sprintf('%d', s), ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'bottom', ...
                    'FontSize', 8, 'Color', [0.4 0.4 0.4]);
            end
        end
    end
end

function updateAnalysis(app)
    app = guidata(app.fig);
    view = app.viewDropdown.Value;
    switch view
        case 'V_fixed Sweep'
            plotVfixedSweep(app);
        case 'Multi-Case Overlay'
            plotMultiCase(app);
        case 'P_crack Sensitivity'
            plotPcrackSensitivity(app);
        case 'Failure Surface'
            plotFailureSurface(app);
    end
end

function plotVfixedSweep(app)
    app = guidata(app.fig);

    delete(app.analysisPanel.Children);
    app.ax_analysis = uiaxes(app.analysisPanel);
    app.ax_analysis.Position = [60 50 ...
        max(app.analysisPanel.InnerPosition(3)-100, 200) ...
        max(app.analysisPanel.InnerPosition(4)-80, 200)];

    ax = app.ax_analysis;

    T_tarmac_C = app.TtarmacSlider.Value;
    T_cargo_C  = app.TcargoSlider.Value;
    P_crack_psig = app.PcrackSlider.Value;
    V_fixed_L  = app.VfixedSlider.Value;

    scenario = struct( ...
        'V_fixed_L', 0, ...
        'T_tarmac_peak_C', T_tarmac_C, ...
        'T_cargo_C', T_cargo_C, ...
        'cruise_alt_ft', app.CRUISE_ALT_FT, ...
        'P_crack_psig', P_crack_psig);

    sweep_vols = linspace(5, 120, 231);
    sweep_min_dp = zeros(size(sweep_vols));

    [t_hr, T_K, P_amb_Pa] = build_flight_profile(scenario);
    V_bag_init = app.V_BAG_INIT_L * app.L_TO_M3;
    V_bag_max  = app.V_BAG_MAX_L * app.L_TO_M3;
    P_crack_Pa = P_crack_psig * app.PSIG_TO_PA;

    for k = 1:length(sweep_vols)
        Vf = sweep_vols(k) * app.L_TO_M3;
        r = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, Vf, V_bag_init, V_bag_max, P_crack_Pa);
        sweep_min_dp(k) = min(r.delta_P_Pa) / app.PSIG_TO_PA;
    end

    params_th = struct( ...
        'v_bag_init_L', app.V_BAG_INIT_L, 'v_bag_max_L', app.V_BAG_MAX_L, ...
        'p_seal_bar_abs', 1.01325, ...
        'p_low_bar_abs', isa_pressure(app.CRUISE_ALT_FT)/1e5, ...
        'T_seal_C', 20.0, 'T_hot_C', T_tarmac_C, 'T_return_C', 20.0, ...
        'p_vent_gauge_bar', P_crack_psig * app.PSIG_TO_BAR);
    th = analytic_thresholds(params_th);

    cla(ax);
    hold(ax, 'on');
    plot(ax, sweep_vols, sweep_min_dp, 'Color', app.OI.blue, 'LineWidth', 2);
    yline(ax, 0, 'k', 'LineWidth', 1);
    xline(ax, th.no_vent_limit_L, '--', 'Color', app.OI.green, 'LineWidth', 1.5, ...
        'Label', 'No-vent limit', 'LabelVerticalAlignment', 'bottom');
    if isfinite(th.return_negative_limit_L)
        xline(ax, th.return_negative_limit_L, '--', 'Color', [0.8 0.1 0.1], ...
            'LineWidth', 1.5, 'Label', 'Return threshold', ...
            'LabelVerticalAlignment', 'bottom');
    end
    xline(ax, V_fixed_L, '-', 'Color', [0 0 0], 'LineWidth', 1.5, ...
        'Label', sprintf('Current: %.0f L', V_fixed_L), ...
        'LabelVerticalAlignment', 'top');
    hold(ax, 'off');

    xlabel(ax, 'Rigid Fixed System Volume (L)');
    ylabel(ax, 'Minimum \DeltaP (psig)');
    title(ax, 'V_{fixed} Sweep: Worst-Case Gauge Pressure');
    grid(ax, 'on');

    guidata(app.fig, app);
end

function plotMultiCase(app)
    app = guidata(app.fig);

    delete(app.analysisPanel.Children);
    multiGrid = uigridlayout(app.analysisPanel, [2, 2], ...
        'Padding', [10 10 10 10], 'RowSpacing', 10, 'ColumnSpacing', 10);

    ax1 = uiaxes(multiGrid); ax1.Layout.Row = 1; ax1.Layout.Column = 1;
    ax2 = uiaxes(multiGrid); ax2.Layout.Row = 1; ax2.Layout.Column = 2;
    ax3 = uiaxes(multiGrid); ax3.Layout.Row = 2; ax3.Layout.Column = 1;
    ax4 = uiaxes(multiGrid); ax4.Layout.Row = 2; ax4.Layout.Column = 2;
    axes_list = [ax1, ax2, ax3, ax4];

    comparison_vols = [12, 30, 45, 60, 90];
    comp_colors = {app.OI.cyan, app.OI.green, app.OI.orange, app.OI.blue, app.OI.red};

    T_tarmac_C   = app.TtarmacSlider.Value;
    T_cargo_C    = app.TcargoSlider.Value;
    P_crack_psig = app.PcrackSlider.Value;

    scenario = struct('V_fixed_L', 0, 'T_tarmac_peak_C', T_tarmac_C, ...
        'T_cargo_C', T_cargo_C, 'cruise_alt_ft', app.CRUISE_ALT_FT, ...
        'P_crack_psig', P_crack_psig);

    [t_hr, T_K, P_amb_Pa, seg_boundaries, seg_names] = build_flight_profile(scenario);
    V_bag_init = app.V_BAG_INIT_L * app.L_TO_M3;
    V_bag_max  = app.V_BAG_MAX_L * app.L_TO_M3;
    P_crack_Pa = P_crack_psig * app.PSIG_TO_PA;

    shade_colors = [0.92 0.92 0.95; 0.98 0.98 0.98];

    for a = 1:4
        hold(axes_list(a), 'on');
        for s = 1:length(seg_names)
            i0 = seg_boundaries(s);
            if s < length(seg_names)
                i1 = seg_boundaries(s+1) - 1;
            else
                i1 = length(t_hr);
            end
            x = [t_hr(i0) t_hr(i1) t_hr(i1) t_hr(i0)];
            yl = [-1e10 -1e10 1e10 1e10];
            patch(axes_list(a), x, yl, shade_colors(mod(s-1,2)+1, :), ...
                'EdgeColor', 'none', 'FaceAlpha', 0.3, 'HandleVisibility', 'off');
        end
    end

    for k = 1:length(comparison_vols)
        Vf = comparison_vols(k) * app.L_TO_M3;
        r = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, Vf, V_bag_init, V_bag_max, P_crack_Pa);
        lbl = sprintf('%d L', comparison_vols(k));

        plot(ax1, r.t_hr, r.P_int_Pa/1000, 'Color', comp_colors{k}, ...
            'LineWidth', 1.2, 'DisplayName', lbl);
        plot(ax2, r.t_hr, r.V_bag_m3*1000, 'Color', comp_colors{k}, ...
            'LineWidth', 1.2, 'DisplayName', lbl);
        plot(ax3, r.t_hr, r.mass_kg*1000, 'Color', comp_colors{k}, ...
            'LineWidth', 1.2, 'DisplayName', lbl);
        plot(ax4, r.t_hr, r.delta_P_Pa/app.PSIG_TO_PA, 'Color', comp_colors{k}, ...
            'LineWidth', 1.2, 'DisplayName', lbl);
    end

    ylabel(ax1, 'P_{int} (kPa)'); title(ax1, 'Pressure');
    grid(ax1, 'on'); legend(ax1, 'Location', 'best', 'FontSize', 7);
    ylabel(ax2, 'Bag Volume (L)'); title(ax2, 'Bag Volume');
    grid(ax2, 'on');
    ylabel(ax3, 'N_2 Mass (g)'); title(ax3, 'N_2 Mass');
    xlabel(ax3, 'Time (hr)'); grid(ax3, 'on');
    ylabel(ax4, '\DeltaP (psig)'); title(ax4, '\DeltaP');
    xlabel(ax4, 'Time (hr)'); grid(ax4, 'on');
    yline(ax4, 0, 'k', 'LineWidth', 1);

    for a = 1:4, hold(axes_list(a), 'off'); end
    guidata(app.fig, app);
end

function plotPcrackSensitivity(app)
    app = guidata(app.fig);

    delete(app.analysisPanel.Children);
    ax = uiaxes(app.analysisPanel);
    ax.Position = [60 50 ...
        max(app.analysisPanel.InnerPosition(3)-100, 200) ...
        max(app.analysisPanel.InnerPosition(4)-80, 200)];

    T_tarmac_C = app.TtarmacSlider.Value;
    T_cargo_C  = app.TcargoSlider.Value;

    scenario = struct('V_fixed_L', 0, 'T_tarmac_peak_C', T_tarmac_C, ...
        'T_cargo_C', T_cargo_C, 'cruise_alt_ft', app.CRUISE_ALT_FT, ...
        'P_crack_psig', 0);

    [t_hr, T_K, P_amb_Pa] = build_flight_profile(scenario);
    V_bag_init = app.V_BAG_INIT_L * app.L_TO_M3;
    V_bag_max  = app.V_BAG_MAX_L * app.L_TO_M3;

    P_crack_values = [0, 1, 2, 5];
    crack_colors = {app.OI.blue, app.OI.green, app.OI.orange, app.OI.red};
    sweep_vols = linspace(5, 120, 60);

    cla(ax);
    hold(ax, 'on');

    for c = 1:length(P_crack_values)
        Pc = P_crack_values(c) * app.PSIG_TO_PA;
        min_dp = zeros(size(sweep_vols));
        for k = 1:length(sweep_vols)
            Vf = sweep_vols(k) * app.L_TO_M3;
            r = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, Vf, V_bag_init, V_bag_max, Pc);
            min_dp(k) = min(r.delta_P_Pa) / app.PSIG_TO_PA;
        end
        plot(ax, sweep_vols, min_dp, 'Color', crack_colors{c}, 'LineWidth', 1.5, ...
            'DisplayName', sprintf('%g psig', P_crack_values(c)));
    end

    yline(ax, 0, 'k', 'LineWidth', 1);
    hold(ax, 'off');

    xlabel(ax, 'Rigid Fixed System Volume (L)');
    ylabel(ax, 'Minimum \DeltaP (psig)');
    title(ax, 'P_{crack} Sensitivity: Worst-Case Gauge Pressure');
    legend(ax, 'Location', 'best');
    grid(ax, 'on');

    guidata(app.fig, app);
end

function plotFailureSurface(app)
    app = guidata(app.fig);

    delete(app.analysisPanel.Children);
    ax = uiaxes(app.analysisPanel);
    ax.Position = [60 50 ...
        max(app.analysisPanel.InnerPosition(3)-100, 200) ...
        max(app.analysisPanel.InnerPosition(4)-80, 200)];

    T_cargo_C    = app.TcargoSlider.Value;
    P_crack_psig = app.PcrackSlider.Value;
    V_fixed_L    = app.VfixedSlider.Value;
    T_tarmac_C   = app.TtarmacSlider.Value;

    Vf_range = linspace(5, 120, 50);
    Tt_range = linspace(30, 55, 50);
    [VF_grid, TT_grid] = meshgrid(Vf_range, Tt_range);
    DP_grid = zeros(size(VF_grid));

    V_bag_init = app.V_BAG_INIT_L * app.L_TO_M3;
    V_bag_max  = app.V_BAG_MAX_L * app.L_TO_M3;
    P_crack_Pa = P_crack_psig * app.PSIG_TO_PA;

    for i = 1:numel(VF_grid)
        s_sweep = struct('V_fixed_L', VF_grid(i), ...
            'T_tarmac_peak_C', TT_grid(i), ...
            'T_cargo_C', T_cargo_C, ...
            'cruise_alt_ft', app.CRUISE_ALT_FT, ...
            'P_crack_psig', P_crack_psig);
        [t_s, T_s, P_s] = build_flight_profile(s_sweep);
        Vf = VF_grid(i) * app.L_TO_M3;
        r = nitrogen_shipping_sim(t_s, T_s, P_s, Vf, V_bag_init, V_bag_max, P_crack_Pa);
        DP_grid(i) = min(r.delta_P_Pa) / app.PSIG_TO_PA;
    end

    cla(ax);
    hold(ax, 'on');
    surf(ax, VF_grid, TT_grid, DP_grid, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
    contour3(ax, VF_grid, TT_grid, DP_grid, [0 0], 'k', 'LineWidth', 2);

    plot3(ax, V_fixed_L, T_tarmac_C, ...
        interp2(VF_grid, TT_grid, DP_grid, V_fixed_L, T_tarmac_C), ...
        'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    hold(ax, 'off');

    xlabel(ax, 'V_{fixed} (L)');
    ylabel(ax, 'T_{tarmac} (\circC)');
    zlabel(ax, 'Min \DeltaP (psig)');
    title(ax, 'Failure Surface: V_{fixed} vs T_{tarmac}');

    n = 64; half = n/2;
    blue_to_white = [linspace(0.2,1,half)', linspace(0.4,1,half)', linspace(0.7,1,half)'];
    white_to_red  = [linspace(1,0.7,half)', linspace(1,0.2,half)', linspace(1,0.2,half)'];
    colormap(ax, [blue_to_white; white_to_red]);
    clim_abs = max(abs(DP_grid(:)));
    if clim_abs > 0
        clim(ax, [-clim_abs clim_abs]);
    end
    colorbar(ax);
    view(ax, [-35 30]);
    grid(ax, 'on');
    rotate3d(ax, 'on');

    guidata(app.fig, app);
end

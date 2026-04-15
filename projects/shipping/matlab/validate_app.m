function validate_app()
%VALIDATE_APP  Automated end-to-end validation of nitrogen_shipping_app.
%   Programmatically triggers every callback via stored function handles,
%   asserts on lamp color, metrics values, plot contents, and tab/panel
%   state. Prints pass/fail for each test. Exits with error if any fail.

    thisDir = fileparts(mfilename('fullpath'));
    addpath(thisDir);
    addpath(fullfile(thisDir, 'src'));

    fprintf('\n=== Nitrogen Shipping App Validation ===\n\n');
    n_pass = 0;
    n_fail = 0;
    failures = {};

    % ── Test 1: App launches without error ──
    try
        app = nitrogen_shipping_app();
        drawnow;
        fig = app.fig;
        assert(isvalid(fig), 'Figure not valid');
        assert(isstruct(app), 'app not a struct');
        assert(isfield(app, 'fn_presetChanged'), 'fn_presetChanged not exposed');
        [n_pass, n_fail, failures] = report('T01 App launches without error', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T01 App launches without error', false, n_pass, n_fail, failures, e.message);
        print_summary(n_pass, n_fail, failures);
        return;
    end

    % ── Test 2: Baseline preset — lamp green, metrics populated ──
    try
        assert(strcmp(app.presetDropdown.Value, 'baseline'), 'Default preset not baseline');
        assert(app.VfixedSlider.Value == 35, 'V_fixed not 35');
        assert(app.TtarmacSlider.Value == 40, 'T_tarmac not 40');
        assert(app.TcargoSlider.Value == 20, 'T_cargo not 20');
        assert(abs(app.PcrackSlider.Value - 2.0) < 0.01, 'P_crack not 2.0');
        assert(all(app.statusLamp.Color == [0.0 0.8 0.0]), ...
            sprintf('Lamp not green, got [%.1f %.1f %.1f]', app.statusLamp.Color));
        assert(~strcmp(app.minDpLabel.Text, '-- psig'), 'Min dP not populated');
        [n_pass, n_fail, failures] = report('T02 Baseline preset -- green lamp, metrics populated', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T02 Baseline preset -- green lamp, metrics populated', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 3: Explorer axes have plotted data ──
    try
        assert(~isempty(app.ax_pressure.Children), 'Pressure axes empty');
        assert(~isempty(app.ax_bag.Children), 'Bag volume axes empty');
        assert(~isempty(app.ax_mass.Children), 'Mass axes empty');
        assert(~isempty(app.ax_dp.Children), 'Delta-P axes empty');
        [n_pass, n_fail, failures] = report('T03 Explorer 4-panel axes have data', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T03 Explorer 4-panel axes have data', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 4: Switch to worst_case — lamp turns red ──
    try
        app.fn_presetChanged(app, 'worst_case');
        drawnow;
        app = guidata(fig);
        assert(app.VfixedSlider.Value == 80, 'V_fixed not 80');
        assert(app.TtarmacSlider.Value == 50, 'T_tarmac not 50');
        assert(app.TcargoSlider.Value == 25, 'T_cargo not 25');
        assert(app.PcrackSlider.Value == 0, 'P_crack not 0');
        assert(all(app.statusLamp.Color == [0.9 0.1 0.1]), ...
            sprintf('Lamp not red, got [%.1f %.1f %.1f]', app.statusLamp.Color));
        [n_pass, n_fail, failures] = report('T04 worst_case preset -- red lamp, sliders correct', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T04 worst_case preset -- red lamp, sliders correct', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 5: Slider change -> Custom dropdown ──
    try
        % Reset to baseline first so we start from a known good state
        app.fn_presetChanged(app, 'baseline');
        drawnow;
        app = guidata(fig);
        % Now change V_fixed via slider to a non-preset value.
        % Simulate what happens when user moves the slider: the slider
        % already holds the new value when the callback fires.
        app.VfixedSlider.Value = 40;
        app.fn_sliderEditChanged(app, 'Vfixed', 40, 'slider');
        drawnow;
        app = guidata(fig);
        assert(strcmp(app.presetDropdown.Value, 'Custom'), ...
            sprintf('Dropdown not Custom, got %s', app.presetDropdown.Value));
        assert(app.VfixedSlider.Value == 40, ...
            sprintf('Slider not 40, got %.1f', app.VfixedSlider.Value));
        assert(app.VfixedEdit.Value == 40, ...
            sprintf('Edit not synced to 40, got %.1f', app.VfixedEdit.Value));
        [n_pass, n_fail, failures] = report('T05 Slider change -> Custom dropdown, edit synced', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T05 Slider change -> Custom dropdown, edit synced', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 6: Edit field syncs with slider ──
    try
        % Simulate what happens when user types in the edit field:
        % the edit field already has the new value, then the callback fires.
        app.TtarmacEdit.Value = 45;
        app.fn_sliderEditChanged(app, 'Ttarmac', 45, 'edit');
        drawnow;
        app = guidata(fig);
        assert(app.TtarmacSlider.Value == 45, ...
            sprintf('Slider not synced, got %.1f', app.TtarmacSlider.Value));
        assert(app.TtarmacEdit.Value == 45, ...
            sprintf('Edit not synced, got %.1f', app.TtarmacEdit.Value));
        [n_pass, n_fail, failures] = report('T06 Edit field syncs with slider', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T06 Edit field syncs with slider', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 7: Panel toggle collapses and expands ──
    try
        assert(app.panelExpanded == true, 'Panel should start expanded');
        app.fn_togglePanel(app);
        drawnow;
        app = guidata(fig);
        assert(app.panelExpanded == false, 'Panel should be collapsed');
        assert(strcmp(app.panelContainer.Visible, 'off'), 'Panel container should be hidden');
        app.fn_togglePanel(app);
        drawnow;
        app = guidata(fig);
        assert(app.panelExpanded == true, 'Panel should be expanded again');
        assert(strcmp(app.panelContainer.Visible, 'on'), 'Panel container should be visible');
        [n_pass, n_fail, failures] = report('T07 Panel toggle collapses and expands', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T07 Panel toggle collapses and expands', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 8: Analysis tab -- V_fixed Sweep ──
    try
        app.viewDropdown.Value = 'V_fixed Sweep';
        app.fn_updateAnalysis(app);
        drawnow;
        app = guidata(fig);
        kids = findall(app.analysisPanel, 'Type', 'axes');
        assert(~isempty(kids), 'No axes in analysis panel');
        assert(~isempty(kids(1).Children), 'V_fixed sweep axes empty');
        [n_pass, n_fail, failures] = report('T08 Analysis: V_fixed Sweep renders', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T08 Analysis: V_fixed Sweep renders', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 9: Analysis tab -- Multi-Case Overlay ──
    try
        app.viewDropdown.Value = 'Multi-Case Overlay';
        app.fn_updateAnalysis(app);
        drawnow;
        app = guidata(fig);
        kids = findall(app.analysisPanel, 'Type', 'axes');
        assert(length(kids) >= 4, sprintf('Expected >=4 axes for multi-case, got %d', length(kids)));
        [n_pass, n_fail, failures] = report('T09 Analysis: Multi-Case Overlay renders (4 axes)', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T09 Analysis: Multi-Case Overlay renders (4 axes)', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 10: Analysis tab -- P_crack Sensitivity ──
    try
        app.viewDropdown.Value = 'P_crack Sensitivity';
        app.fn_updateAnalysis(app);
        drawnow;
        app = guidata(fig);
        kids = findall(app.analysisPanel, 'Type', 'axes');
        assert(~isempty(kids), 'No axes for P_crack sensitivity');
        lines = findall(kids(1), 'Type', 'Line');
        assert(length(lines) >= 4, sprintf('Expected >=4 lines, got %d', length(lines)));
        [n_pass, n_fail, failures] = report('T10 Analysis: P_crack Sensitivity renders (4+ curves)', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T10 Analysis: P_crack Sensitivity renders (4+ curves)', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 11: Analysis tab -- Failure Surface dropdown selectable ──
    % NOTE: Full surface runs 2500 simulations -- we only verify the dropdown
    % accepts the value without running the computation.
    try
        app.viewDropdown.Value = 'Failure Surface';
        drawnow;
        assert(strcmp(app.viewDropdown.Value, 'Failure Surface'), 'Dropdown rejected value');
        [n_pass, n_fail, failures] = report('T11 Analysis: Failure Surface dropdown selectable', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T11 Analysis: Failure Surface dropdown selectable', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 12: Explorer tab still intact after Analysis views ──
    try
        app.tabGroup.SelectedTab = app.explorerTab;
        drawnow;
        assert(~isempty(app.ax_pressure.Children), 'Pressure axes lost after tab switch');
        assert(~isempty(app.ax_dp.Children), 'Delta-P axes lost after tab switch');
        [n_pass, n_fail, failures] = report('T12 Explorer tab intact after Analysis tab usage', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T12 Explorer tab intact after Analysis tab usage', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 13: All 7 presets load without error ──
    try
        preset_names = app.presets(:, 1);
        for p = 1:length(preset_names)
            app.fn_presetChanged(app, preset_names{p});
            drawnow;
            app = guidata(fig);
        end
        [n_pass, n_fail, failures] = report('T13 All 7 presets load without error', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T13 All 7 presets load without error', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 14: Metrics values are physically reasonable ──
    try
        app.fn_presetChanged(app, 'baseline');
        drawnow;
        app = guidata(fig);
        metrics_text = app.metricsArea.Value;
        tokens = regexp(metrics_text{1}, '(-?[\d.]+)', 'tokens');
        min_dp_val = str2double(tokens{1}{1});
        assert(min_dp_val >= 0, sprintf('Baseline min dP should be >= 0, got %.2f', min_dp_val));

        app.fn_presetChanged(app, 'worst_case');
        drawnow;
        app = guidata(fig);
        metrics_text = app.metricsArea.Value;
        tokens = regexp(metrics_text{1}, '(-?[\d.]+)', 'tokens');
        min_dp_val = str2double(tokens{1}{1});
        assert(min_dp_val < 0, sprintf('Worst case min dP should be < 0, got %.2f', min_dp_val));

        [n_pass, n_fail, failures] = report('T14 Metrics physically reasonable (baseline safe, worst_case fails)', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T14 Metrics physically reasonable (baseline safe, worst_case fails)', false, n_pass, n_fail, failures, e.message);
    end

    % ── Test 15: Clean close and relaunch ──
    try
        close(fig);
        drawnow;
        assert(~isvalid(fig), 'Figure should be deleted after close');
        app2 = nitrogen_shipping_app();
        drawnow;
        fig2 = app2.fig;
        assert(isvalid(fig2), 'Relaunch failed');
        assert(all(app2.statusLamp.Color == [0.0 0.8 0.0]), 'Relaunch lamp not green');
        close(fig2);
        [n_pass, n_fail, failures] = report('T15 Clean close and relaunch', true, n_pass, n_fail, failures);
    catch e
        [n_pass, n_fail, failures] = report('T15 Clean close and relaunch', false, n_pass, n_fail, failures, e.message);
    end

    print_summary(n_pass, n_fail, failures);
end

function [n_pass, n_fail, failures] = report(name, passed, n_pass, n_fail, failures, msg)
    if nargin < 6, msg = ''; end
    if passed
        fprintf('  PASS: %s\n', name);
        n_pass = n_pass + 1;
    else
        fprintf('  FAIL: %s -- %s\n', name, msg);
        n_fail = n_fail + 1;
        failures{end+1} = sprintf('%s: %s', name, msg);
    end
end

function print_summary(n_pass, n_fail, failures)
    fprintf('\n=== Summary: %d passed, %d failed ===\n', n_pass, n_fail);
    if n_fail > 0
        fprintf('\nFailures:\n');
        for i = 1:length(failures)
            fprintf('  %d. %s\n', i, failures{i});
        end
        error('validate_app:failed', '%d tests failed', n_fail);
    else
        fprintf('All tests passed.\n');
    end
end

function report_pptx(output_dir, fig_dir, results)
%REPORT_PPTX  Generate PowerPoint presentation from shipping analysis.
%   REPORT_PPTX(output_dir, fig_dir, results) creates a ~20-slide PPTX
%   summarizing the nitrogen-purged optical assembly shipping failure mode
%   analysis.
%
%   Inputs:
%     output_dir - directory for output .pptx file
%     fig_dir    - directory containing figure PNGs from report_figures()
%     results    - struct with fields:
%       no_vent_limit_L, return_neg_ideal_L, return_neg_2psig_L,
%       baseline_min_dp_Pa, baseline_vented_g, fail60_min_dp_Pa,
%       fail60_vented_g, zero_crossing_L, T_relief_C

    import mlreportgen.ppt.*

    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    pptx_path = fullfile(output_dir, 'shipping_failure_analysis.pptx');
    ppt = Presentation(pptx_path);
    open(ppt);

    %% Slide 1: Title Slide
    slide = add(ppt, 'Title Slide');
    replace(slide, 'Title', ...
        'Shipping Failure Mode of the Nitrogen-Purged Optical Assembly');
    replace(slide, 'Subtitle', ...
        'Return-Leg Underpressure Following Irreversible Mass Loss');

    %% Slide 2: Section Header — Summary
    slide = add(ppt, 'Section Header');
    replace(slide, 'Title', 'Summary');

    %% Slide 3: Key Findings
    slide = add(ppt, 'Title and Content');
    replace(slide, 'Title', 'Key Findings');
    bullets = Paragraph('The actual failure mode is return-leg underpressure, not outbound overpressure');
    append(bullets, sprintf('\n'));
    append(bullets, 'Irreversible nitrogen mass loss through the bag vent drives the mechanism');
    append(bullets, sprintf('\n'));
    append(bullets, 'The as-built 35 L / 2 psig configuration is nominally safe (single-flight)');
    append(bullets, sprintf('\n'));
    append(bullets, 'Removing the bag vent eliminates the mass-loss pathway');
    append(bullets, sprintf('\n'));
    append(bullets, 'The 0.5 bar circuit relief provides sufficient overpressure protection');
    replace(slide, 'Content', bullets);

    %% Slide 4: System Overview
    slide = add(ppt, 'Title and Content');
    replace(slide, 'Title', 'System Overview');
    bullets = Paragraph('Manifolded optical assembly with nitrogen purge');
    append(bullets, sprintf('\n'));
    append(bullets, 'Positive-pressure-energized seals (not qualified for sub-atmospheric)');
    append(bullets, sprintf('\n'));
    append(bullets, 'CALDRY 1500 foil bag: 0-22 L compliance range');
    append(bullets, sprintf('\n'));
    append(bullets, 'Swagelok 6L-CW4VR4-P check valve: 2 psig cracking pressure');
    append(bullets, sprintf('\n'));
    append(bullets, sprintf('Rigid connected volume V_fixed = 35 L (conservative estimate)'));
    replace(slide, 'Content', bullets);

    %% Slide 5: Safe Baseline figure
    add_figure_slide(ppt, ...
        'Safe Baseline: V_fixed = 35 L, P_crack = 2 psig', ...
        fullfile(fig_dir, 'fig_baseline_cycle.png'));

    %% Slide 6: Section Header — Failure Mechanism
    slide = add(ppt, 'Section Header');
    replace(slide, 'Title', 'Failure Mechanism');

    %% Slide 7: Three Regimes
    slide = add(ppt, 'Title and Content');
    replace(slide, 'Title', 'Three Operating Regimes');
    bullets = Paragraph('Regime 1: Bag absorbs expansion - P_int tracks P_amb');
    append(bullets, sprintf('\n'));
    append(bullets, 'Regime 2: Bag saturates, valve vents - irreversible mass loss');
    append(bullets, sprintf('\n'));
    append(bullets, 'Regime 3: Return-leg collapse - P_int < P_amb, contamination risk');
    replace(slide, 'Content', bullets);

    %% Slide 8: Failure Demo figure
    add_figure_slide(ppt, ...
        'Failure Sequence: Bag Saturation -> Venting -> Collapse', ...
        fullfile(fig_dir, 'fig_three_regimes.png'));

    %% Slide 9: Failure Cycle Detail figure
    add_figure_slide(ppt, ...
        '60 L / Ideal Vent - Full Failure Cycle', ...
        fullfile(fig_dir, 'fig_failure_cycle.png'));

    %% Slide 10: Section Header — Design Space Analysis
    slide = add(ppt, 'Section Header');
    replace(slide, 'Title', 'Design Space Analysis');

    %% Slide 11: Screening Thresholds table
    slide = add(ppt, 'Title and Content');
    replace(slide, 'Title', 'Screening Thresholds (Rigid Volume Limits)');
    tbl_data = {
        'Vent Assumption',  'No-Vent Limit (L)', 'Return >= 0 Limit (L)';
        'Ideal vent (0 psig)', sprintf('%.1f', results.no_vent_limit_L), ...
            sprintf('%.1f', results.return_neg_ideal_L);
        '2 psig Swagelok',  sprintf('%.1f', results.no_vent_limit_L), ...
            sprintf('%.1f', results.return_neg_2psig_L)
    };
    tbl = Table(tbl_data);
    replace(slide, 'Content', tbl);

    %% Slide 12: Volume Sweep figure
    add_figure_slide(ppt, ...
        'Worst-Case Gauge Pressure vs Rigid Volume', ...
        fullfile(fig_dir, 'fig_min_dp_sweep.png'));

    %% Slide 13: Multi-Case Comparison figure
    add_figure_slide(ppt, ...
        'Multi-Case Comparison (Ideal Vent)', ...
        fullfile(fig_dir, 'fig_case_comparison.png'));

    %% Slide 14: P_crack Sensitivity figure
    add_figure_slide(ppt, ...
        'Effect of Vent Cracking Pressure', ...
        fullfile(fig_dir, 'fig_pcrack_sensitivity.png'));

    %% Slide 15: Section Header — Overpressure & Failure Boundary
    slide = add(ppt, 'Section Header');
    replace(slide, 'Title', 'Overpressure & Failure Boundary');

    %% Slide 16: Overpressure Bound table + text
    slide = add(ppt, 'Title and Content');
    replace(slide, 'Title', 'Upper Bound: 0.5 bar Relief Cannot Open');
    tbl_data = {
        'T_cargo (C)', 'Delta-P at Cruise (bar)';
        '10',  '0.226';
        '20',  '0.261';
        '30',  '0.295';
        '40',  '0.330'
    };
    tbl = Table(tbl_data);
    p = Paragraph(' ');
    append(p, sprintf('\n'));
    append(p, sprintf('Relief requires T_cargo = %.0f C - physically unreachable', ...
        results.T_relief_C));
    contents = {tbl, p};
    replace(slide, 'Content', contents);

    %% Slide 17: Failure Boundary figure
    add_figure_slide(ppt, ...
        'Failure Boundary on (V_fixed, T_cargo) Plane', ...
        fullfile(fig_dir, 'fig_failure_boundary.png'));

    %% Slide 18: Failure Surface figure
    add_figure_slide(ppt, ...
        'Parametric Failure Surface (Ideal Vent)', ...
        fullfile(fig_dir, 'fig_failure_surface.png'));

    %% Slide 19: Section Header — Conclusions
    slide = add(ppt, 'Section Header');
    replace(slide, 'Title', 'Conclusions');

    %% Slide 20: Recommendation
    slide = add(ppt, 'Title and Content');
    replace(slide, 'Title', 'Recommendations');
    bullets = Paragraph('Remove or permanently seal the bag vent');
    append(bullets, sprintf('\n'));
    append(bullets, 'The 0.5 bar circuit relief provides sufficient overpressure protection');
    append(bullets, sprintf('\n'));
    append(bullets, 'Critical: traceable V_fixed measurement required to confirm estimate');
    append(bullets, sprintf('\n'));
    append(bullets, 'Multi-leg and handling effects not captured - represent non-conservative gaps');
    replace(slide, 'Content', bullets);

    %% Close
    close(ppt);
    fprintf('PowerPoint saved to: %s\n', pptx_path);

end

%% ── Local Functions ──

function add_figure_slide(ppt, title_text, img_path)
%ADD_FIGURE_SLIDE  Add a blank slide with a title textbox and full-width image.
    import mlreportgen.ppt.*

    slide = add(ppt, 'Blank');

    % Title as a TextBox with a Paragraph inside
    ttl = TextBox();
    ttl.X = '0.5in';
    ttl.Y = '0.2in';
    ttl.Width = '9in';
    ttl.Height = '0.8in';
    tp = Paragraph(title_text);
    tp.FontSize = '24pt';
    tp.Bold = true;
    add(ttl, tp);
    add(slide, ttl);

    % Full-width figure
    pic = Picture(img_path);
    pic.X = '0.5in';
    pic.Y = '1.2in';
    pic.Width = '9in';
    pic.Height = '5.5in';
    add(slide, pic);
end

function report_content(format, output_dir, fig_dir, results)
%REPORT_CONTENT  Generate document report (PDF, DOCX, or HTML).
%   REPORT_CONTENT(format, output_dir, fig_dir, results)
%
%   format:     'pdf', 'docx', or 'html-file'
%   output_dir: directory for output file
%   fig_dir:    directory containing figure PNGs
%   results:    struct from report_figures() with fields:
%     no_vent_limit_L, return_neg_ideal_L, return_neg_2psig_L,
%     baseline_min_dp_Pa, baseline_vented_g, fail60_min_dp_Pa,
%     fail60_vented_g, zero_crossing_L, T_relief_C

    import mlreportgen.report.*
    import mlreportgen.dom.*

    %% Create report
    rpt = Report(fullfile(output_dir, 'shipping_failure_analysis'), format);
    open(rpt);

    %% Title Page
    tp = TitlePage();
    tp.Title = 'Shipping Failure Mode of the Nitrogen-Purged Optical Assembly';
    tp.Subtitle = 'Return-Leg Underpressure Following Irreversible Mass Loss';
    tp.Author = 'Opto-Mechanical Engineering Group';
    tp.PubDate = datestr(now, 'yyyy-mm-dd'); %#ok<TNOW1,DATST>
    add(rpt, tp);

    %% Table of Contents
    add(rpt, TableOfContents());

    %% Chapter 1: Summary
    ch1 = Chapter('Summary');

    add(ch1, Paragraph(['The nitrogen-purged optical assembly fails by return-leg ' ...
        'underpressure after irreversible nitrogen mass loss during air transport, ' ...
        'not by outbound overpressure. During ascent and heating, thermal expansion ' ...
        'of the sealed nitrogen charge can exceed the capacity of the foil compliance ' ...
        'bag. Once the bag saturates, the outward-only check valve vents nitrogen to ' ...
        'ambient. This venting is irreversible: the retained mole inventory is ' ...
        'permanently reduced. On the return leg, the bag collapses and the remaining ' ...
        'nitrogen cannot sustain ambient pressure in the rigid connected volume. ' ...
        'Internal pressure falls below ambient, and the positive-pressure-energized ' ...
        'seal network admits atmospheric contamination.']));

    add(ch1, Paragraph(sprintf(['The as-built configuration (estimated 35 L rigid volume, ' ...
        '2 psig Swagelok check valve) is nominally safe under the assumed single-flight ' ...
        'transport envelope. The analytic no-vent threshold is %.1f L (ideal vent) and ' ...
        'the return-negative threshold is %.1f L (2 psig), both above the estimated ' ...
        'system volume. The baseline simulation confirms a minimum gauge pressure of ' ...
        '%.0f Pa with %.4f g of nitrogen vented.'], ...
        results.no_vent_limit_L, results.return_neg_2psig_L, ...
        results.baseline_min_dp_Pa, results.baseline_vented_g)));

    add(ch1, Paragraph(sprintf(['The 0.5 bar (7.25 psig) circuit relief valve cannot open ' ...
        'under physically realizable cargo temperatures. The sealed-system overpressure ' ...
        'reaches 0.5 bar only at %.0f C, which exceeds any credible air-transport ' ...
        'scenario. Removing the bag vent eliminates the mass-loss pathway entirely.'], ...
        results.T_relief_C)));

    add(rpt, ch1);

    %% Chapter 2: System Description
    ch2 = Chapter('System Description');

    add(ch2, Paragraph(['The optical assembly consists of a rigid manifolded housing ' ...
        'containing precision optics, purged with dry nitrogen at sea-level conditions ' ...
        '(20 C, 101.325 kPa). Positive-pressure seals maintain the nitrogen atmosphere ' ...
        'and exclude moisture and particulate contamination. A foil compliance bag ' ...
        '(22 L maximum capacity, 11 L initial fill) accommodates thermal and ' ...
        'barometric volume changes. An outward-only check valve permits nitrogen to ' ...
        'vent when internal pressure exceeds ambient by the cracking pressure.']));

    % Swagelok valve table
    add(ch2, Heading(2, 'Check Valve Specification'));
    valve_header = {'Parameter', 'Value'};
    valve_data = {
        'Part number',         '6L-CW4VR4-P'
        'Cracking pressure',   '2 psig (0.138 bar)'
        'Flow coefficient',    'Cv 0.7'
        'End connections',     '1/4 in. VCR female'
        'Seal material',       'FKM (Viton)'
        'Surface finish',      'Ra 8 \mu{}in'
        'Pressure rating',     '3000 psig'
    };
    tbl = BaseTable([valve_header; valve_data]);
    tbl.Title = 'Swagelok Check Valve Specifications';
    add(ch2, tbl);

    % Baseline cycle figure
    add_figure(ch2, fig_dir, 'fig_baseline_cycle.png', ...
        ['Two-leg shipping cycle for the estimated 35 L rigid volume with the 2 psig ' ...
         'Swagelok valve. The bag absorbs the full excursion without venting and no ' ...
         'harmful pressure differential develops.']);

    add(rpt, ch2);

    %% Chapter 3: Transport Envelope
    ch3 = Chapter('Transport Envelope');

    add(ch3, Paragraph(['The assembly ships by commercial air freight. The cargo hold ' ...
        'environment follows the cabin pressurization schedule, reaching a maximum ' ...
        'cabin altitude of 8000 ft during cruise. Temperature varies between ambient ' ...
        'tarmac conditions and the regulated cargo hold temperature.']));

    % Shipping requirements table
    add(ch3, Heading(2, 'Shipping Requirements'));
    req_header = {'Parameter', 'Value'};
    req_data = {
        'Temperature range',      '10 to 40 C'
        'Transport mode',         'Aerial (commercial freight)'
        'Maximum acceleration',   '10 g'
    };
    tbl_req = BaseTable([req_header; req_data]);
    tbl_req.Title = 'Shipping Requirements';
    add(ch3, tbl_req);

    % Transport parameters table
    add(ch3, Heading(2, 'Transport Parameters'));
    trans_header = {'Parameter', 'Value'};
    trans_data = {
        'Maximum cabin altitude',     '8000 ft'
        'Cruise ambient pressure',    '75.26 kPa'
        'Bag maximum capacity',       '22 L'
        'Bag initial fill',           '11 L'
        'Estimated rigid volume',     '~35 L'
    };
    tbl_trans = BaseTable([trans_header; trans_data]);
    tbl_trans.Title = 'Transport Parameters';
    add(ch3, tbl_trans);

    add(ch3, Paragraph(['Temperature nomenclature: T_seal is the temperature at seal-up ' ...
        '(20 C, lab conditions). T_tarmac is the peak temperature the assembly reaches ' ...
        'on the ramp before loading (35 C nominal, up to 50 C extreme). T_cargo is the ' ...
        'regulated cargo hold temperature during cruise (20 C nominal).']));

    add(rpt, ch3);

    %% Chapter 4: Failure Mechanism
    ch4 = Chapter('Failure Mechanism');

    add(ch4, Paragraph(['The failure progresses through three regimes, determined by the ' ...
        'relationship between the required gas volume and the available bag capacity. ' ...
        'Each regime represents a distinct thermodynamic state of the system.']));

    % Regime 1
    add(ch4, Heading(2, 'Regime 1: Bag Absorbs Expansion'));
    add(ch4, Paragraph(['When the gas volume requirement increases (due to heating or ' ...
        'pressure reduction), the bag unfolds to accommodate the excess. Internal ' ...
        'pressure tracks ambient pressure because the bag presents negligible ' ...
        'stiffness. The system operates as designed and no nitrogen escapes.']));

    % Regime 2
    add(ch4, Heading(2, 'Regime 2: Bag Saturates and Valve Vents'));
    add(ch4, Paragraph(['If the required gas volume exceeds V_fixed + V_bag_max, the bag ' ...
        'reaches its physical limit. Internal pressure rises above ambient until it ' ...
        'exceeds the check valve cracking pressure. Nitrogen vents to the atmosphere. ' ...
        'This step is irreversible: the check valve does not permit inflow, and the ' ...
        'vented moles are permanently lost from the system inventory.']));

    % Regime 3
    add(ch4, Heading(2, 'Regime 3: Return-Leg Collapse and Underpressure'));
    add(ch4, Paragraph(['On the return leg, the environment reverses: altitude decreases, ' ...
        'ambient pressure rises, and temperature may drop. The gas contracts. The bag ' ...
        'collapses to zero volume, but the remaining mole inventory cannot fill the ' ...
        'rigid volume at the rising ambient pressure. Internal pressure falls below ' ...
        'ambient. The positive-pressure seals, designed to hold against outward ' ...
        'pressure, now face inward pressure and admit atmospheric contamination.']));

    % Failure cycle figure
    add_figure(ch4, fig_dir, 'fig_failure_cycle.png', ...
        ['Failure cycle for the 60 L rigid volume with ideal vent (0 psig). The bag ' ...
         'saturates during the outbound climb, nitrogen vents irreversibly, and the ' ...
         sprintf('return-leg pressure drops to %.0f Pa below ambient.', ...
         abs(results.fail60_min_dp_Pa))]);

    % Three regimes figure
    add_figure(ch4, fig_dir, 'fig_three_regimes.png', ...
        ['Three-regime progression for 12 L (bag absorbs all expansion), 60 L ' ...
         '(bag saturates and vents), and 90 L (severe underpressure on return). ' ...
         'The left panel shows pressure differential; the right panel shows bag volume.']);

    add(rpt, ch4);

    %% Chapter 5: Governing Model
    ch5 = Chapter('Governing Model');

    add(ch5, Paragraph(['The thermodynamic model treats the nitrogen as an ideal gas in a ' ...
        'variable-volume enclosure consisting of the rigid manifold plus the compliant ' ...
        'bag. The model resolves pressure, volume, and mass at each time step using ' ...
        'the ideal gas law and piecewise logic for bag clamping and valve action.']));

    add(ch5, Heading(2, 'State Equations'));

    add(ch5, Paragraph('The total system volume is the sum of the rigid volume and the bag volume:'));
    eq1 = Equation();
    eq1.Content = 'V_\mathrm{tot} = V_\mathrm{fixed} + V_\mathrm{bag}';
    add(ch5, eq1);

    add(ch5, Paragraph('The ideal gas state equation governs the nitrogen charge:'));
    eq2 = Equation();
    eq2.Content = 'P_\mathrm{int} \cdot V_\mathrm{tot} = n R T';
    add(ch5, eq2);

    add(ch5, Paragraph('The required volume at ambient pressure for the current mole inventory is:'));
    eq3 = Equation();
    eq3.Content = 'V_\mathrm{req} = \frac{n R T}{P_\mathrm{amb}}, \quad V_\mathrm{bag,req} = V_\mathrm{req} - V_\mathrm{fixed}';
    add(ch5, eq3);

    add(ch5, Heading(2, 'Piecewise Resolution'));
    add(ch5, Paragraph(['At each time step, the model evaluates the required bag volume and ' ...
        'resolves the system state through four cases: (1) bag tracks ambient pressure ' ...
        'when 0 < V_bag_req < V_bag_max; (2) bag is full and internal pressure rises ' ...
        'when V_bag_req >= V_bag_max; (3) valve vents nitrogen when P_int exceeds ' ...
        'P_amb + P_crack; (4) bag is collapsed and internal pressure falls below ambient ' ...
        'when V_bag_req <= 0.']));

    add(ch5, Heading(2, 'Assumptions'));
    assumptions = {
        'Well-mixed nitrogen at uniform temperature throughout the system volume.'
        'Zero-stiffness compliance bag, clamped between 0 and V_bag_max.'
        'Perfect check valve: zero flow below cracking pressure, infinite flow above.'
        'Quasi-static process: thermal and pressure equilibrium at each time step.'
        'Ideal gas behavior (validated against real-gas CoolProp results, deviation < 300 ppm).'
    };
    ol = OrderedList();
    for i = 1:length(assumptions)
        append(ol, assumptions{i});
    end
    add(ch5, ol);

    add(rpt, ch5);

    %% Chapter 6: Screening Thresholds
    ch6 = Chapter('Screening Thresholds');

    add(ch6, Paragraph(['Closed-form screening thresholds determine the maximum rigid volume ' ...
        'that avoids venting and the minimum rigid volume that develops return-leg ' ...
        'underpressure. These thresholds depend on the seal-up conditions, the worst-case ' ...
        'temperature, the cruise altitude pressure, and the vent valve cracking pressure.']));

    add(ch6, Heading(2, 'No-Vent Threshold'));
    add(ch6, Paragraph(['The expansion ratio alpha compares the gas volume requirement at ' ...
        'worst-case conditions to the seal-up volume:']));
    eq_alpha = Equation();
    eq_alpha.Content = '\alpha = \frac{P_\mathrm{seal}}{P_\mathrm{low}} \cdot \frac{T_\mathrm{hot}}{T_\mathrm{seal}}';
    add(ch6, eq_alpha);

    add(ch6, Paragraph('The rigid volume must satisfy:'));
    eq_novent = Equation();
    eq_novent.Content = 'V_\mathrm{fixed} \leq \frac{V_\mathrm{bag,max} - \alpha \cdot V_\mathrm{bag,init}}{\alpha - 1}';
    add(ch6, eq_novent);

    add(ch6, Heading(2, 'Return-Negative Threshold'));
    add(ch6, Paragraph(['The return ratio gamma compares the volume required to sustain ' ...
        'sea-level pressure on return to the volume retained after venting:']));
    eq_gamma = Equation();
    eq_gamma.Content = '\gamma = \frac{P_\mathrm{return} \cdot T_\mathrm{hot}}{P_\mathrm{peak} \cdot T_\mathrm{return}}';
    add(ch6, eq_gamma);

    add(ch6, Paragraph('The rigid volume must satisfy:'));
    eq_retneg = Equation();
    eq_retneg.Content = 'V_\mathrm{fixed} \leq \frac{V_\mathrm{bag,max}}{\gamma - 1}';
    add(ch6, eq_retneg);

    % Threshold table
    add(ch6, Heading(2, 'Threshold Values'));

    % Compute 5 psig threshold for the table
    PSIG_TO_BAR = 0.0689475729;
    params_screen.v_bag_init_L     = 11.0;
    params_screen.v_bag_max_L      = 22.0;
    params_screen.p_seal_bar_abs   = 1.01325;
    P_cruise_Pa = 75.26e3;  % 8000 ft
    params_screen.p_low_bar_abs    = P_cruise_Pa / 1e5;
    params_screen.T_seal_C         = 20.0;
    params_screen.T_hot_C          = 35.0;
    params_screen.T_return_C       = 20.0;
    params_screen.p_vent_gauge_bar = 5.0 * PSIG_TO_BAR;
    th_5psig = analytic_thresholds(params_screen);

    thresh_header = {'Vent setting', 'No-vent limit (L)', 'Return-negative limit (L)'};
    thresh_data = {
        'Ideal (0 psig)',  sprintf('%.1f', results.no_vent_limit_L),  sprintf('%.1f', results.return_neg_ideal_L)
        '2 psig',          sprintf('%.1f', results.no_vent_limit_L),  sprintf('%.1f', results.return_neg_2psig_L)
        '5 psig',          sprintf('%.1f', results.no_vent_limit_L),  sprintf('%.1f', th_5psig.return_negative_limit_L)
    };
    tbl_thresh = BaseTable([thresh_header; thresh_data]);
    tbl_thresh.Title = 'Screening Thresholds by Vent Setting';
    add(ch6, tbl_thresh);

    add(ch6, Paragraph(['The no-vent limit is identical for all vent settings because it ' ...
        'depends only on the expansion ratio, not the cracking pressure. The ' ...
        'return-negative limit increases with cracking pressure because higher cracking ' ...
        'pressure reduces the amount of nitrogen vented.']));

    add(rpt, ch6);

    %% Chapter 7: Results
    ch7 = Chapter('Results');

    add(ch7, Paragraph(['The minimum gauge pressure sweep across rigid volume is the ' ...
        'primary design-space visualization. Each point represents a complete two-leg ' ...
        'flight simulation; the plotted value is the worst-case (most negative) pressure ' ...
        'differential experienced at any time during the cycle.']));

    add_figure(ch7, fig_dir, 'fig_min_dp_sweep.png', ...
        ['Worst-case gauge pressure versus rigid system volume for the ideal vent ' ...
         '(0 psig) and 2 psig Swagelok valve. Vertical dashed lines mark the analytic ' ...
         sprintf('no-vent threshold (%.0f L) and return-negative thresholds. ', ...
         results.no_vent_limit_L) ...
         'The 35 L baseline configuration sits safely above zero for both vent settings.']);

    % Representative cases table
    add(ch7, Heading(2, 'Representative Cases'));
    case_header = {'Volume (L)', 'Vent', 'Min dP (Pa)', 'Outcome'};
    case_data = {
        '12',   'Ideal',  '>0',                            'Bag absorbs all expansion; no venting'
        '30',   'Ideal',  '>0',                            'Vents during climb but safe return'
        '35',   '2 psig', sprintf('%.0f', results.baseline_min_dp_Pa), 'Baseline: nominally safe'
        '60',   'Ideal',  sprintf('%.0f', results.fail60_min_dp_Pa),   'Failure: seal breach on return'
    };
    tbl_cases = BaseTable([case_header; case_data]);
    tbl_cases.Title = 'Representative Simulation Cases';
    add(ch7, tbl_cases);

    add_figure(ch7, fig_dir, 'fig_case_comparison.png', ...
        ['Multi-case comparison for 12, 30, 45, 60, and 90 L rigid volumes with ideal ' ...
         'vent. Internal pressure, bag volume, nitrogen mass, and pressure differential ' ...
         'are shown. The 90 L case develops the largest underpressure because the ratio ' ...
         'of vented mass to retained mass is highest.']);

    add_figure(ch7, fig_dir, 'fig_pcrack_sensitivity.png', ...
        ['Cracking pressure sensitivity. Higher cracking pressure shifts the failure ' ...
         'boundary to larger volumes because less nitrogen escapes before the valve ' ...
         'closes. At 5 psig, the return-negative threshold exceeds 100 L.']);

    add(rpt, ch7);

    %% Chapter 8: Upper Bound on Overpressure
    ch8 = Chapter('Upper Bound on Overpressure');

    add(ch8, Paragraph(['If the bag vent is removed, the system becomes fully sealed and ' ...
        'overpressure is the only concern. The internal pressure of a sealed system ' ...
        'follows Gay-Lussac''s law at constant volume:']));

    eq_sealed = Equation();
    eq_sealed.Content = 'P_\mathrm{int} = P_\mathrm{seal} \cdot \frac{T}{T_\mathrm{seal}}';
    add(ch8, eq_sealed);

    add(ch8, Heading(2, 'Cruise Overpressure'));
    add(ch8, Paragraph(['At cruise altitude (75.26 kPa ambient), the gauge pressure depends ' ...
        'on the cargo hold temperature. The bag absorbs some expansion, but in the ' ...
        'sealed case no gas escapes.']));

    P_seal = 101325;
    T_seal_K = 293.15;
    cruise_temps = [10, 20, 30, 40];
    cruise_header = {'Cargo temp (C)', 'P_int (kPa)', 'Gauge above ambient (kPa)'};
    cruise_data = cell(length(cruise_temps), 3);
    for i = 1:length(cruise_temps)
        T = cruise_temps(i) + 273.15;
        P_int = P_seal * T / T_seal_K;
        cruise_data{i, 1} = sprintf('%d', cruise_temps(i));
        cruise_data{i, 2} = sprintf('%.1f', P_int / 1000);
        cruise_data{i, 3} = sprintf('%.1f', (P_int - 75260) / 1000);
    end
    tbl_cruise = BaseTable([cruise_header; cruise_data]);
    tbl_cruise.Title = 'Cruise Overpressure (sealed system, no bag vent)';
    add(ch8, tbl_cruise);

    add(ch8, Heading(2, 'Tarmac Overpressure'));
    tarmac_temps = [40, 50, 60, 80];
    tarmac_header = {'Tarmac temp (C)', 'P_int (kPa)', 'Gauge above sea level (kPa)'};
    tarmac_data = cell(length(tarmac_temps), 3);
    for i = 1:length(tarmac_temps)
        T = tarmac_temps(i) + 273.15;
        P_int = P_seal * T / T_seal_K;
        tarmac_data{i, 1} = sprintf('%d', tarmac_temps(i));
        tarmac_data{i, 2} = sprintf('%.1f', P_int / 1000);
        tarmac_data{i, 3} = sprintf('%.1f', (P_int - P_seal) / 1000);
    end
    tbl_tarmac = BaseTable([tarmac_header; tarmac_data]);
    tbl_tarmac.Title = 'Tarmac Overpressure (sealed system at sea level)';
    add(ch8, tbl_tarmac);

    add(ch8, Paragraph(sprintf(['The 0.5 bar circuit relief valve opens at %.0f C. This ' ...
        'temperature is physically unreachable in any credible air-transport scenario. ' ...
        'Removing the bag vent is safe: the 0.5 bar circuit relief provides sufficient ' ...
        'overpressure protection at any rigid volume.'], results.T_relief_C)));

    add(rpt, ch8);

    %% Chapter 9: Parametric Surface
    ch9 = Chapter('Parametric Surface');

    add(ch9, Paragraph(['The parametric surface maps the worst-case gauge pressure as a ' ...
        'function of rigid volume and cargo temperature. The failure boundary (dP = 0 ' ...
        'contour) separates safe configurations from those that develop return-leg ' ...
        'underpressure.']));

    add_figure(ch9, fig_dir, 'fig_failure_boundary.png', ...
        ['Failure boundary contours (dP = 0) for vent settings from 0 to 7.25 psig. ' ...
         'Configurations to the left of each contour are safe; configurations to the ' ...
         'right develop underpressure. The 0.5 bar (7.25 psig) contour lies outside ' ...
         'the physically realizable envelope, confirming that a sealed system with ' ...
         'circuit relief only does not fail.']);

    add_figure(ch9, fig_dir, 'fig_failure_surface.png', ...
        ['Left: filled contour of minimum gauge pressure versus rigid volume and cargo ' ...
         'temperature for the ideal vent case. The black contour marks dP = 0. ' ...
         'Right: 3D surface view of the same data. Blue regions are safe (positive ' ...
         'gauge); red regions fail (negative gauge). The surface quantifies how rapidly ' ...
         'underpressure grows beyond the failure boundary.']);

    add(rpt, ch9);

    %% Chapter 10: Conclusions
    ch10 = Chapter('Conclusions');

    c1 = ['The actual failure mode is return-leg underpressure following irreversible ' ...
          'nitrogen mass loss, not outbound overpressure.'];
    c2 = sprintf(['The as-built configuration (estimated 35 L rigid volume, 2 psig check ' ...
         'valve) is nominally safe under single-flight assumptions. The minimum gauge ' ...
         'pressure is %.0f Pa and %.4f g of nitrogen vents during the cycle.'], ...
         results.baseline_min_dp_Pa, results.baseline_vented_g);
    c3 = ['Removing the bag vent eliminates the irreversible mass-loss pathway entirely. ' ...
         'Without venting, no return-leg underpressure can develop regardless of rigid volume.'];
    c4 = sprintf(['The 0.5 bar circuit relief valve provides sufficient overpressure ' ...
         'protection for a sealed system. The relief temperature is %.0f C, which ' ...
         'exceeds any credible transport scenario.'], results.T_relief_C);
    c5 = sprintf(['The critical unknown is the rigid volume V_fixed. The zero-crossing ' ...
         'volume for the ideal vent case is %.1f L. A traceable measurement of the ' ...
         'actual manifolded system volume is required to confirm the safety margin.'], ...
         results.zero_crossing_L);
    conclusions = {c1; c2; c3; c4; c5};

    ol_conc = OrderedList();
    for i = 1:length(conclusions)
        append(ol_conc, conclusions{i});
    end
    add(ch10, ol_conc);

    add(rpt, ch10);

    %% Close report
    close(rpt);
    fprintf('Report saved: %s\n', rpt.OutputPath);
end

%% ── Local Functions ──

function add_figure(parent, fig_dir, filename, caption_text)
%ADD_FIGURE  Add a captioned figure image to the report.
%   Sizes the image to fill the page width (6.5 in for letter with 1 in
%   margins) and scales height to preserve the original aspect ratio.
    import mlreportgen.report.*
    import mlreportgen.dom.*

    img_path = fullfile(fig_dir, filename);
    if ~isfile(img_path)
        warning('report_content:missingFigure', 'Figure not found: %s', img_path);
        add(parent, Paragraph(sprintf('[Missing figure: %s]', filename)));
        return;
    end

    % Read actual image dimensions and compute aspect-preserving size
    info = imfinfo(img_path);
    aspect = info.Width / info.Height;
    page_width_in = 6.5;  % letter page minus 1 in margins each side
    img_height_in = page_width_in / aspect;

    fig = FormalImage(img_path);
    fig.Caption = caption_text;
    fig.Width  = sprintf('%.1fin', page_width_in);
    fig.Height = sprintf('%.1fin', img_height_in);
    add(parent, fig);
end

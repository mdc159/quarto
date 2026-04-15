function [t_hr, T_K, P_amb_Pa, seg_boundaries, seg_names] = build_flight_profile(scenario)
%BUILD_FLIGHT_PROFILE  Build 9-segment shipping flight profile.
%   [t_hr, T_K, P_amb_Pa, seg_boundaries, seg_names] = BUILD_FLIGHT_PROFILE(scenario)
%
%   scenario is a struct with fields:
%       T_tarmac_peak_C  - Peak tarmac temperature (deg C)
%       T_cargo_C        - Cargo hold temperature at cruise (deg C)
%       cruise_alt_ft    - Cruise cabin altitude (ft)
%
%   Returns:
%       t_hr           - Time vector (hr), 1-minute resolution
%       T_K            - Temperature at each timestep (K)
%       P_amb_Pa       - Ambient pressure at each timestep (Pa)
%       seg_boundaries - Indices of first timestep of each segment (1-based)
%       seg_names      - Cell array of segment names

    T_seal_C = 20.0;

    % Derived ramp temperatures (matching Python notebook logic)
    T_ramp_load_C   = T_seal_C + 8;
    T_taxi_cool_C   = scenario.T_tarmac_peak_C - 2;
    T_climb_end_C   = scenario.T_cargo_C;
    T_descent_end_C = scenario.T_cargo_C + 2;
    T_arrival_C     = T_descent_end_C + 2;
    T_warehouse_C   = T_seal_C + 2;

    % Segment definitions: {name, dur_hr, T0_C, T1_C, alt0_ft, alt1_ft}
    segs = {
        '1. Ground transport to airport',   1.00, T_seal_C,              T_ramp_load_C,            0, 0
        '2. Tarmac / ULD wait (hot)',        3.00, T_ramp_load_C,         scenario.T_tarmac_peak_C, 0, 0
        '3. Taxi & takeoff roll',            0.25, scenario.T_tarmac_peak_C, T_taxi_cool_C,         0, 0
        '4. Climb (cabin pressurisation)',    0.42, T_taxi_cool_C,         T_climb_end_C,            0, scenario.cruise_alt_ft
        '5. Cruise at altitude',            10.00, scenario.T_cargo_C,    scenario.T_cargo_C,        scenario.cruise_alt_ft, scenario.cruise_alt_ft
        '6. Descent (cabin depressurisation)', 0.50, scenario.T_cargo_C,  T_descent_end_C,           scenario.cruise_alt_ft, 0
        '7. Taxi & unload',                  0.50, T_descent_end_C,       T_arrival_C,               0, 0
        '8. Ground transport to site',       1.00, T_arrival_C,           T_warehouse_C,             0, 0
        '9. Destination hold / cool-down',   2.00, T_warehouse_C,         T_seal_C,                  0, 0
    };

    dt_hr = 1.0 / 60.0;  % 1-minute resolution

    t_list = [];
    T_list = [];
    P_list = [];
    seg_boundaries = [];
    seg_names = cell(size(segs, 1), 1);

    t_cursor = 0.0;

    for s = 1:size(segs, 1)
        seg_names{s} = segs{s, 1};
        dur_hr  = segs{s, 2};
        T0_C    = segs{s, 3};
        T1_C    = segs{s, 4};
        alt0_ft = segs{s, 5};
        alt1_ft = segs{s, 6};

        n_steps = max(round(dur_hr / dt_hr), 1);
        seg_boundaries(end+1) = length(t_list) + 1; %#ok<AGROW>

        for j = 0:n_steps-1
            frac = j / n_steps;
            T_C   = T0_C + frac * (T1_C - T0_C);
            alt_f = alt0_ft + frac * (alt1_ft - alt0_ft);

            t_list(end+1) = t_cursor + frac * dur_hr; %#ok<AGROW>
            T_list(end+1) = T_C + 273.15; %#ok<AGROW>
            P_list(end+1) = isa_pressure(alt_f); %#ok<AGROW>
        end

        t_cursor = t_cursor + dur_hr;
    end

    % Final endpoint
    t_list(end+1) = t_cursor;
    T_list(end+1) = segs{end, 4} + 273.15;  % T1_C of last segment
    P_list(end+1) = isa_pressure(segs{end, 6});  % alt1_ft of last segment

    t_hr     = t_list(:);
    T_K      = T_list(:);
    P_amb_Pa = P_list(:);
end

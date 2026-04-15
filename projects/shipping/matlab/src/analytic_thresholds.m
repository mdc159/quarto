function thresholds = analytic_thresholds(params)
%ANALYTIC_THRESHOLDS  Closed-form screening thresholds for nitrogen shipping.
%   thresholds = ANALYTIC_THRESHOLDS(params)
%
%   params struct fields:
%       v_bag_init_L       - Initial bag fill (L)
%       v_bag_max_L        - Maximum bag capacity (L)
%       p_seal_bar_abs     - Seal-up pressure (bar, absolute)
%       p_low_bar_abs      - Lowest ambient pressure during flight (bar, abs)
%       T_seal_C           - Seal-up temperature (deg C)
%       T_hot_C            - Peak temperature (deg C)
%       T_return_C         - Return temperature (deg C)
%       p_vent_gauge_bar   - Vent valve cracking pressure (bar, gauge)
%
%   Returns struct with:
%       no_vent_limit_L          - Largest V_fixed avoiding any venting
%       return_negative_limit_L  - Smallest V_fixed that goes sub-atmospheric

    T_seal_K = params.T_seal_C + 273.15;
    T_hot_K  = params.T_hot_C + 273.15;
    T_return_K = params.T_return_C + 273.15;

    % No-vent threshold
    alpha = (params.p_seal_bar_abs / params.p_low_bar_abs) * (T_hot_K / T_seal_K);
    if alpha <= 1.0
        thresholds.no_vent_limit_L = inf;
    else
        thresholds.no_vent_limit_L = ...
            (params.v_bag_max_L - alpha * params.v_bag_init_L) / (alpha - 1.0);
    end

    % Return-negative threshold
    p_peak_bar_abs = params.p_low_bar_abs + params.p_vent_gauge_bar;
    p_required = params.p_seal_bar_abs;
    gamma = (p_required * T_hot_K) / (p_peak_bar_abs * T_return_K);
    if gamma <= 1.0
        thresholds.return_negative_limit_L = 0.0;
    else
        thresholds.return_negative_limit_L = params.v_bag_max_L / (gamma - 1.0);
    end
end

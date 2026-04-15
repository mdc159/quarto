function result = nitrogen_shipping_sim(t_hr, T_K, P_amb_Pa, V_fixed, V_bag_init, V_bag_max, P_crack_Pa)
%NITROGEN_SHIPPING_SIM  Quasi-static nitrogen shipping cycle simulation.
%   result = NITROGEN_SHIPPING_SIM(t_hr, T_K, P_amb_Pa, V_fixed, V_bag_init, V_bag_max, P_crack_Pa)
%
%   Simulates the sealed nitrogen charge through a shipping cycle using
%   ideal gas thermodynamics. Handles three regimes:
%     1. Tracking ambient (bag absorbs expansion)
%     2. Bag full (pressure rises, optional venting)
%     3. Bag collapsed (underpressure risk)
%
%   All volumes in m^3, pressures in Pa, temperatures in K.
%
%   Returns a struct with fields:
%     t_hr, T_K, P_amb_Pa, P_int_Pa, V_bag_m3, mass_kg,
%     rho_int, delta_P_Pa, cum_vent_kg, state

    R = 8.31446261815324;       % J/(mol*K)
    M_N2 = 0.0280134;          % kg/mol
    R_spec = R / M_N2;         % J/(kg*K)

    n = length(t_hr);

    % Initial nitrogen inventory at seal-up
    n_mol = P_amb_Pa(1) * (V_fixed + V_bag_init) / (R * T_K(1));

    % Allocate
    P_int_Pa   = zeros(n, 1);
    V_bag_m3   = zeros(n, 1);
    mass_kg    = zeros(n, 1);
    rho_int    = zeros(n, 1);
    delta_P_Pa = zeros(n, 1);
    cum_vent   = zeros(n, 1);
    state      = strings(n, 1);

    total_vented_kg = 0.0;

    for i = 1:n
        T  = T_K(i);
        Pa = P_amb_Pa(i);

        % Volume the current mass needs at ambient pressure (ideal gas)
        V_total_req = n_mol * R * T / Pa;
        V_bag_req   = V_total_req - V_fixed;

        if V_bag_req >= 0 && V_bag_req <= V_bag_max
            % Regime 1: bag accommodates
            P_int_Pa(i) = Pa;
            V_bag_m3(i) = V_bag_req;
            rho_int(i)  = Pa / (R_spec * T);
            state(i)    = "tracking ambient";

        elseif V_bag_req > V_bag_max
            % Regime 2: bag full, pressure may rise
            V_bag_m3(i) = V_bag_max;
            V_tot = V_fixed + V_bag_max;
            P_trial = n_mol * R * T / V_tot;

            P_vent = Pa + P_crack_Pa;

            if P_trial > P_vent
                % Vent to setpoint
                n_after = P_vent * V_tot / (R * T);
                dm_kg = (n_mol - n_after) * M_N2;
                total_vented_kg = total_vented_kg + dm_kg;
                n_mol = n_after;
                P_int_Pa(i) = P_vent;
                rho_int(i)  = P_vent / (R_spec * T);
                state(i)    = "venting";
            else
                P_int_Pa(i) = P_trial;
                rho_int(i)  = P_trial / (R_spec * T);
                state(i)    = "bag full, no vent";
            end

        else
            % Regime 3: bag collapsed
            V_bag_m3(i) = 0.0;
            P_i = n_mol * R * T / V_fixed;
            P_int_Pa(i) = P_i;
            rho_int(i)  = P_i / (R_spec * T);
            state(i)    = "bag collapsed";
        end

        mass_kg(i)    = n_mol * M_N2;
        delta_P_Pa(i) = P_int_Pa(i) - Pa;
        cum_vent(i)   = total_vented_kg;
    end

    result.t_hr       = t_hr;
    result.T_K        = T_K;
    result.P_amb_Pa   = P_amb_Pa;
    result.P_int_Pa   = P_int_Pa;
    result.V_bag_m3   = V_bag_m3;
    result.mass_kg    = mass_kg;
    result.rho_int    = rho_int;
    result.delta_P_Pa = delta_P_Pa;
    result.cum_vent_kg = cum_vent;
    result.state      = state;
end

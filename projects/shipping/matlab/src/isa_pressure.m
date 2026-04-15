function P_Pa = isa_pressure(alt_ft)
%ISA_PRESSURE  ISA tropospheric pressure from altitude.
%   P_Pa = ISA_PRESSURE(alt_ft) converts altitude in feet to ambient
%   pressure in Pa using the International Standard Atmosphere barometric
%   formula. Valid for 0 to ~36,000 ft (troposphere).
%
%   Supports scalar or vector input.

    h_m = alt_ft * 0.3048;
    P0 = 101325.0;   % Pa
    T0 = 288.15;     % K
    L  = 0.0065;     % K/m  (lapse rate)
    g  = 9.80665;    % m/s^2
    M  = 0.0289644;  % kg/mol
    R  = 8.31447;    % J/(mol*K)

    P_Pa = P0 .* (1.0 - L .* h_m ./ T0) .^ (g * M / (R * L));
end

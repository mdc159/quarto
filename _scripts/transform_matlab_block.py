"""Replace the broken MATLAB code block in report.qmd with:
  1. An executable Python cell (numpy + matplotlib) that produces the figure
  2. A display-only `{.matlab}` block showing the original MATLAB script

Also clean up remaining escape artifacts.
"""
import re
from pathlib import Path

SRC = Path("D:/Quarto/report.qmd")
txt = SRC.read_text(encoding="utf-8")

# ---- 1. Clean remaining backslash-escaped operators ----------------------
txt = txt.replace(r"\*", "*")
txt = txt.replace(r"\$", "$")

# ---- 2. Replace the MATLAB script block ----------------------------------
# Match from "### MATLAB Script" through the "hold off;" line.
matlab_pattern = re.compile(
    r"### MATLAB Script\s*\n.*?hold off;\s*\n",
    re.DOTALL,
)

replacement = '''### Friction Model Simulation {#sec-friction-sim}

The simulation logic is implemented below as an executable Python cell that
runs at render time and produces @fig-torque-simulation. An equivalent MATLAB
script is preserved in @sec-matlab-reference for use with MATLAB / Simulink
toolchains. Both implementations share the same scenario parameters and
exponential friction model.

```{python}
#| label: fig-torque-simulation
#| fig-cap: "Simulated peak breakaway torque vs. cycle count for six material/surface configurations. Lubricated 304 SS / aluminum-bronze (control) shows minimal change. Dry 304 SS / aluminum-bronze rises sharply, indicating incipient galling. Kolsterised and Nitronic 60 pairings hold stable, low friction across 25 cycles. Shaded bands indicate ±10 % uncertainty."
#| fig-alt: "Line plot showing six torque-vs-cycle curves over 25 cycles. The dry 304 SS / aluminum-bronze curve rises steeply from ~45 to ~80 N·m. All other curves remain stable between 17 and 35 N·m, with lubricated control lowest."
#| code-fold: true
#| code-summary: "Show simulation code (Python)"

import numpy as np
import matplotlib.pyplot as plt

# Scenario parameters: (initial mu, asymptotic mu, trend)
scenarios = {
    "Lubricated 304 / Al-Bronze":         (0.17, 0.17, "flat"),
    "Dry 304 / Al-Bronze":                (0.45, 0.80, "rise"),
    "Dry 304 / Phos-Bronze":              (0.34, 0.30, "decay"),
    "Kolsterised 304 / Phos-Bronze":      (0.30, 0.25, "decay"),
    "Dry Nitronic 60 / Phos-Bronze":      (0.33, 0.28, "decay"),
    "Kolsterised N60 / Phos-Bronze":      (0.28, 0.22, "decay"),
}

num_cycles = 25
cycles = np.arange(1, num_cycles + 1)
decay_rate = 0.2   # exponential decay factor for wear-in
rise_rate  = 0.5   # exponential rise factor for galling
torque_factor = 100.0  # N·m per unit mu (representative scaling)

def mu_series(mu0, mu_end, trend):
    n = cycles - 1
    if trend == "flat":
        return np.full_like(cycles, mu0, dtype=float)
    if trend == "decay":
        return mu_end + (mu0 - mu_end) * np.exp(-decay_rate * n)
    if trend == "rise":
        return mu_end - (mu_end - mu0) * np.exp(-rise_rate * n)
    return np.full_like(cycles, mu0, dtype=float)

fig, ax = plt.subplots(figsize=(9, 5.5))
colors = plt.cm.tab10(np.linspace(0, 1, len(scenarios)))

for color, (name, (mu0, mu_end, trend)) in zip(colors, scenarios.items()):
    torque = mu_series(mu0, mu_end, trend) * torque_factor
    upper, lower = torque * 1.10, torque * 0.90
    ax.plot(cycles, torque, lw=1.8, color=color, label=name)
    ax.fill_between(cycles, lower, upper, color=color, alpha=0.12, linewidth=0)

ax.set_xlabel("Cycle Number")
ax.set_ylabel("Peak Breakaway Torque (N·m)")
ax.set_title("Simulated Torque vs. Cycle for Different Material/Surface Configurations")
ax.grid(True, alpha=0.3)
ax.legend(loc="best", fontsize=9, framealpha=0.9)
ax.set_xlim(1, num_cycles)
fig.tight_layout()
plt.show()
```

::: {.callout-note collapse="true"}
## Notes on the Simulation

Each scenario is defined by an initial static friction coefficient
(`mu0`), an asymptotic value (`mu_end`) reached after many cycles, and a
trend type (`flat`, `decay`, or `rise`). The wear-in cases use an
exponential decay toward the asymptote; the galling case (dry 304 SS /
aluminum-bronze) uses an exponential rise capped at a near-seizure value.

The torque scale factor of 100 N·m per unit μ is a representative
mapping that produces realistic absolute magnitudes for a 1/4-80
fastener under the modeled preload. In an actual bolt, this conversion
would come from the thread geometry and preload (e.g., a specific clamp
force giving a particular thread friction torque).

The ±10 % shaded band represents typical lot-to-lot variation in
friction from surface finish, slight temperature changes, or material
inhomogeneity.

**Interpretation:** The simulation predicts that the dry 304 SS /
aluminum-bronze pairing reaches 80 N·m by only a few cycles, consistent
with observed seizure in the baseline test. The Kolsterised and
Nitronic 60 cases stay near 22--30 N·m for the full 25 cycles. The
lubricated control remains lowest at ~17 N·m. Any divergence between
test data and simulation beyond the ±10 % band will prompt refinement
of the wear-in / galling rate constants.
:::

### MATLAB Reference Implementation {#sec-matlab-reference}

The original MATLAB script is preserved below for use in MATLAB or
Simulink toolchains. It can be run via the MATLAB MCP server, or
copied into a `.m` file and executed locally in MATLAB.

```{.matlab filename="friction_simulation.m"}
% MATLAB Script: Friction vs Cycle Simulation for Threaded Material Combos
% Define scenarios with initial and final static friction coefficients (mu)
% and trend type ('flat' = no change, 'decay' = wear-in, 'rise' = galling).

scenarios = struct;
scenarios.Lubricated_304_AlBronze     = struct('mu_s0', 0.17, 'mu_s_end', 0.17, 'trend', 'flat');
scenarios.Dry_304_AlBronze            = struct('mu_s0', 0.45, 'mu_s_end', 0.80, 'trend', 'rise');
scenarios.Dry_304_PhosBronze          = struct('mu_s0', 0.34, 'mu_s_end', 0.30, 'trend', 'decay');
scenarios.Kolsterised_304_PhosBronze  = struct('mu_s0', 0.30, 'mu_s_end', 0.25, 'trend', 'decay');
scenarios.Dry_Nitronic60_PhosBronze   = struct('mu_s0', 0.33, 'mu_s_end', 0.28, 'trend', 'decay');
scenarios.Kolsterised_N60_PhosBronze  = struct('mu_s0', 0.28, 'mu_s_end', 0.22, 'trend', 'decay');

numCycles    = 25;
cycles       = 1:numCycles;
decay_rate   = 0.2;   % exponential decay factor for wear-in
rise_rate    = 0.5;   % exponential rise factor for galling

scenarioNames = fieldnames(scenarios);
torque_static = zeros(numCycles, numel(scenarioNames));

for j = 1:numel(scenarioNames)
    name   = scenarioNames{j};
    mu0    = scenarios.(name).mu_s0;
    mu_end = scenarios.(name).mu_s_end;
    trend  = scenarios.(name).trend;

    for i = 1:numCycles
        switch trend
            case 'flat'
                mu_i = mu0;
            case 'decay'
                mu_i = mu_end + (mu0 - mu_end) * exp(-decay_rate * (i-1));
            case 'rise'
                mu_i = mu_end - (mu_end - mu0) * exp(-rise_rate  * (i-1));
            otherwise
                mu_i = mu0;
        end
        torque_static(i, j) = mu_i * 100;   % 100 N*m per unit mu
    end
end

figure; hold on; grid on;
colors = lines(numel(scenarioNames));
for j = 1:numel(scenarioNames)
    mu_series = torque_static(:, j);
    plot(cycles, mu_series, 'LineWidth', 1.5, 'Color', colors(j,:), ...
         'DisplayName', strrep(scenarioNames{j}, '_', ' '));
    upper = mu_series * 1.10;
    lower = mu_series * 0.90;
    fill([cycles, fliplr(cycles)], [upper', fliplr(lower')], ...
         colors(j,:), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
end
xlabel('Cycle Number');
ylabel('Peak Breakaway Torque (N\\cdotm)');
title('Simulated Torque vs Cycle for Different Configurations');
legend('Location','best');
hold off;
```

'''

# Replace
new_txt, n = matlab_pattern.subn(lambda m: replacement, txt, count=1)
if n == 0:
    raise SystemExit("MATLAB block pattern did not match — file not modified")

SRC.write_text(new_txt, encoding="utf-8", newline="\n")
print(f"Replaced MATLAB block (matches: {n})")

# CoolProp 7.x Comprehensive Reference

This is a loadable reference for the thermo-engineer agent. Read this file
when doing CoolProp work that goes beyond basic PropsSI calls.

## Installation and Import

```python
import CoolProp.CoolProp as CP
from CoolProp.CoolProp import PropsSI, PhaseSI
from CoolProp.HumidAirProp import HAPropsSI
import CoolProp  # for AbstractState and enum constants

# Version
print(CoolProp.__version__)  # '7.2.0' in this workspace
```

## PropsSI — High-Level Interface

```python
PropsSI(output, name1, value1, name2, value2, fluid_name) -> float
PropsSI(output, name1, array1, name2, array2, fluid_name) -> np.ndarray  # 1-D arrays
PropsSI(output, fluid_name) -> float  # trivial (state-independent) parameters only
```

### Trivial (State-Independent) Parameters

Called as `PropsSI("Tcrit", "Water")` — no state inputs needed:

| Key | Description | Unit |
|---|---|---|
| `Tcrit` | Critical temperature | K |
| `Pcrit` | Critical pressure | Pa |
| `Rhocrit` | Critical density | kg/m³ |
| `Ttriple` | Triple point temperature | K |
| `Ptriple` | Triple point pressure | Pa |
| `Tmin` / `Tmax` | Valid temperature range | K |
| `Pmax` | Maximum valid pressure | Pa |
| `MOLARMASS` / `M` | Molar mass | kg/mol |
| `ACENTRIC` | Acentric factor | — |
| `GWP100` | Global warming potential (100yr) | — |
| `ODP` | Ozone depletion potential | — |

### Output Parameters

| Short | Long | Unit | Notes |
|---|---|---|---|
| `T` | `T` | K | Temperature |
| `P` | `P` | Pa | Pressure |
| `D` | `DMASS` | kg/m³ | Mass density |
| | `DMOLAR` | mol/m³ | Molar density |
| `H` | `HMASS` | J/kg | Specific enthalpy (mass) |
| | `HMOLAR` | J/mol | Specific enthalpy (molar) |
| `S` | `SMASS` | J/kg/K | Specific entropy (mass) |
| | `SMOLAR` | J/mol/K | Specific entropy (molar) |
| `U` | `UMASS` | J/kg | Internal energy |
| `G` | `GMASS` | J/kg | Gibbs free energy |
| `C` | `CPMASS` | J/kg/K | Isobaric heat capacity |
| | `CVMASS` | J/kg/K | Isochoric heat capacity |
| | `CP0MASS` | J/kg/K | Ideal gas Cp |
| `A` | `SPEED_OF_SOUND` | m/s | Single-phase only |
| `Z` | `Z` | — | Compressibility factor |
| `Q` | `Q` | mol/mol | Vapor quality (0=liq, 1=vap; -1 outside two-phase) |
| `V` | `VISCOSITY` | Pa·s | Dynamic viscosity |
| `L` | `CONDUCTIVITY` | W/m/K | Thermal conductivity |
| `I` | `SURFACE_TENSION` | N/m | Saturation only |
| | `PRANDTL` | — | Prandtl number |
| | `ISOTHERMAL_COMPRESSIBILITY` | 1/Pa | |
| | `ISOBARIC_EXPANSION_COEFFICIENT` | 1/K | |
| | `BVIRIAL` | m³/mol | Second virial coefficient |

### Derivative Syntax

```python
# d(H)/d(T) at constant P  (= Cp)
PropsSI("d(Hmass)/d(T)|P", "T", 300, "P", 1e5, "Water")

# Clausius-Clapeyron: dP/dT along saturation curve
PropsSI("d(P)/d(T)|sigma", "T", 373.15, "Q", 0, "Water")
```

Derivatives are valid only for single-phase states via PropsSI.

## Input Pairs — Speed Ranking

| Input Pair | Speed | Notes |
|---|---|---|
| `T`, `D` (or `T`, `DMASS`) | Fastest | Native Helmholtz variables |
| `P`, `T` | Fast | Most common in practice |
| `P`, `Q` / `T`, `Q` | Fast | Saturation lookups |
| `P`, `H` / `P`, `S` | Moderate | Requires flash iteration |
| `H`, `S` | Slow | Double flash |
| `D`, `H` / `D`, `S` / `D`, `P` | Moderate | |

## Fluid Names

### Pure Fluids

```python
CP.FluidsList()  # returns complete list
```

**Common gases:** `Nitrogen` (`N2`), `Oxygen` (`O2`), `Argon` (`Ar`),
`Helium` (`He`), `Hydrogen` (`H2`), `Air`, `CarbonDioxide` (`CO2`),
`Methane` (`CH4`), `Ammonia` (`NH3`)

**Water:** `Water` (`H2O`), `HeavyWater` (`D2O`)

**Common refrigerants:** `R134a`, `R410A`, `R32`, `R125`, `R1234yf`,
`R1234ze(E)`, `R404A`, `R407C`, `R507A`, `R22`, `R123`, `R245fa`

**Siloxanes (ORC):** `MM`, `MDM`, `D4`, `D5`, `D6`

**Hydrocarbons:** `Ethane`, `Propane`, `n-Butane`, `IsoButane`,
`n-Pentane`, `Isopentane`, `n-Hexane`, `Ethanol`, `Methanol`

**Hydrogen isomers:** `OrthoHydrogen`, `ParaHydrogen`

**Case sensitivity:** CoolProp v7.x is case-insensitive, but match
documented capitalization to be safe.

### Mixtures (HEOS backend)

Mole fractions in brackets, components joined with `&`:

```python
PropsSI("D", "T", 300, "P", 1e5, "HEOS::R32[0.697615]&R125[0.302385]")
PropsSI("H", "T", 300, "P", 1e5, "Methane[0.9]&Ethane[0.06]&Propane[0.03]&Nitrogen[0.01]")
```

**Critical limitation:** For user-defined mixtures via PropsSI, only
`T,P` / `T,Q` / `P,Q` input pairs are supported. Other pairs (P,H; H,S;
etc.) raise an exception.

### Predefined Mixtures

```python
CP.get_global_param_string("predefined_mixtures")  # pipe-separated list
PropsSI("D", "T", 300, "P", 1e5, "Air.mix")
```

Includes ~150 ASHRAE refrigerant blends and natural gas compositions.

### Incompressible Fluids (INCOMP backend)

```python
# Pure incompressible
PropsSI("D", "T", 350, "P", 1e5, "INCOMP::DowQ")

# Binary solution (mass fraction)
PropsSI("D", "T", 280, "P", 1e5, "INCOMP::MEG[0.3]")   # 30% ethylene glycol
PropsSI("D", "T", 280, "P", 1e5, "INCOMP::MEG-30%")     # equivalent
```

**Key solutions:** `MEG` (ethylene glycol), `MPG` (propylene glycol),
`MEA` (ethanol), `MCA` (calcium chloride), `MNA` (sodium chloride),
`LiBr` (lithium bromide)

**Limitations:** No two-phase support. Only T,P or T,D input pairs.
Throws outside valid T and concentration ranges.

## Backends

| Backend | Syntax | Use case |
|---|---|---|
| HEOS (default) | `"Water"` or `"HEOS::Water"` | High-accuracy Helmholtz EOS |
| IF97 | `"IF97::Water"` | Fast industrial water/steam |
| REFPROP | `"REFPROP::Water"` | Gold standard (requires $325 license) |
| SRK / PR | AbstractState only | Cubic EOS, fast but less accurate |
| BICUBIC | `"BICUBIC&HEOS::R245fa"` | Tabular, ~0.27 µs/call |
| TTSE | `"TTSE&HEOS::R245fa"` | Tabular, ~0.27 µs/call |
| INCOMP | `"INCOMP::MEG"` | Brines, glycols, heat transfer fluids |

## Phase Handling

### PhaseSI

```python
phase = PhaseSI("P", 101325, "T", 300, "Water")
# Returns: 'liquid', 'gas', 'twophase', 'supercritical_liquid',
#          'supercritical_gas', 'supercritical', 'unknown'
```

### Phase Hints (performance + disambiguation)

```python
# Append |phase to input key — skips phase detection
PropsSI("H", "T|liquid", 340, "P", 5e6, "Water")
# Available: |liquid, |gas, |twophase, |supercritical_liquid, |supercritical_gas, |supercritical
```

**Warning:** If the imposed phase is wrong, you get either an exception
or *silently incorrect results*.

### Saturation Properties

```python
h_liq = PropsSI("H", "P", 1e5, "Q", 0, "Water")   # saturated liquid
h_vap = PropsSI("H", "P", 1e5, "Q", 1, "Water")   # saturated vapor
T_sat = PropsSI("T", "P", 1e5, "Q", 0, "Water")   # saturation temperature
```

### Detecting Phase

```python
Q = PropsSI("Q", "T", 300, "P", 1e5, "Water")
# Q = -1 means single-phase (subcooled or superheated)
# 0 <= Q <= 1 means two-phase
```

## AbstractState — Low-Level Interface

Use when: loops over many state points, need derivatives, fixed-composition
mixtures, or tabular backends.

### Core Pattern

```python
import CoolProp

AS = CoolProp.AbstractState("HEOS", "Water")
AS.update(CoolProp.PT_INPUTS, 101325, 400)  # (input_pair, val1, val2)

T   = AS.T()            # K
p   = AS.p()            # Pa
rho = AS.rhomass()      # kg/m³
h   = AS.hmass()        # J/kg
s   = AS.smass()        # J/kg/K
u   = AS.umass()        # J/kg
cp  = AS.cpmass()       # J/kg/K
cv  = AS.cvmass()       # J/kg/K
mu  = AS.viscosity()    # Pa·s
k   = AS.conductivity() # W/m/K
a   = AS.speed_sound()  # m/s (single-phase only)
q   = AS.Q()            # vapor quality (-1 outside two-phase)
Pr  = AS.Prandtl()      # Prandtl number
```

### Input Pair Enums

```python
CoolProp.PT_INPUTS       CoolProp.DmassT_INPUTS
CoolProp.PQ_INPUTS       CoolProp.QT_INPUTS
CoolProp.HmassP_INPUTS   CoolProp.PSmass_INPUTS
CoolProp.HmassSmass_INPUTS
CoolProp.DmassP_INPUTS   CoolProp.DmassHmass_INPUTS
```

### Phase Specification

```python
AS.specify_phase(CoolProp.iphase_liquid)      # force liquid
AS.specify_phase(CoolProp.iphase_gas)         # force gas
AS.specify_phase(CoolProp.iphase_not_imposed) # auto-detect (default)
AS.unspecify_phase()                           # same as above
```

### Derivatives

```python
# First partial: (dH/dT)_P = Cp
cp = AS.first_partial_deriv(CoolProp.iHmass, CoolProp.iT, CoolProp.iP)

# Second partial: (d²H/dT²)_P
AS.second_partial_deriv(CoolProp.iHmass, CoolProp.iT, CoolProp.iP,
                         CoolProp.iT, CoolProp.iP)

# Saturation derivative (must be at Q=0 or Q=1 state)
AS.update(CoolProp.QT_INPUTS, 0, 373.15)
dP_dT = AS.first_saturation_deriv(CoolProp.iP, CoolProp.iT)
```

### Phase Envelope (Mixtures)

```python
AS = CoolProp.AbstractState("HEOS", "Nitrogen&Oxygen")
AS.set_mole_fractions([0.79, 0.21])
AS.build_phase_envelope("dummy")  # argument required but ignored
PE = AS.get_phase_envelope_data()
# PE.T, PE.p, PE.rhomolar_vap, PE.rhomolar_liq
```

**Known issue:** Phase envelope can overshoot the critical point. Validate
that PE.p values are physically plausible.

### Mixtures via AbstractState

```python
AS = CoolProp.AbstractState("HEOS", "Methane&Ethane")
AS.set_mole_fractions([0.2, 0.8])   # must set before first update()
AS.update(CoolProp.PT_INPUTS, 1e6, 250)

# Two-phase: retrieve liquid/vapor compositions
AS.update(CoolProp.PQ_INPUTS, 1e5, 0.5)
x_liq = AS.mole_fractions_liquid()
x_vap = AS.mole_fractions_vapor()
```

## HAPropsSI — Humid Air Properties

```python
from CoolProp.HumidAirProp import HAPropsSI

# Always provide exactly 3 inputs; P must always be one of them
h = HAPropsSI("H", "T", 298.15, "P", 101325, "R", 0.5)
```

### Input/Output Parameters

| Key(s) | Unit | Description |
|---|---|---|
| `T`, `Tdb`, `T_db` | K | Dry-bulb temperature |
| `B`, `Twb`, `T_wb` | K | Wet-bulb temperature |
| `D`, `Tdp`, `T_dp` | K | Dew-point temperature |
| `P` | Pa | Total pressure (always required as input) |
| `R`, `RH`, `RelHum` | 0–1 | Relative humidity (not percent!) |
| `W`, `Omega`, `HumRat` | kg_w/kg_da | Humidity ratio |
| `H`, `Hda` | J/kg_da | Enthalpy per kg dry air |
| `Hha` | J/kg_ha | Enthalpy per kg humid air |
| `S`, `Sda` | J/kg_da/K | Entropy per kg dry air |
| `V`, `Vda` | m³/kg_da | Volume per kg dry air |
| `C`, `cp` | J/kg_da/K | Cp per kg dry air |

**Basis distinction:** `H` vs `Hha` — per-kg-dry-air vs per-kg-humid-air.
This matters significantly in mass balance calculations.

**Valid range:** T: 130–623 K, P: 10 Pa–10 MPa, W: 0–10 kg_w/kg_da

## Performance Optimization

### Speed Hierarchy

| Method | Time/call | Notes |
|---|---|---|
| BICUBIC/TTSE tabular | ~0.27 µs | After one-time table generation |
| AbstractState.update() T,D | ~0.1–3 µs | After instance creation |
| PropsSI T,D | ~3–5 µs | |
| PropsSI P,T | ~15–50 µs | |
| PropsSI P,H | ~30–100 µs | Flash required |

### Vectorized PropsSI

```python
import numpy as np
T_arr = np.linspace(280, 380, 1000)
P_arr = np.full(1000, 1e5)
H_arr = PropsSI("H", "T", T_arr, "P", P_arr, "Water")  # ~100x faster than loop
```

Both arrays must be 1-D, same length. Scalar inputs are broadcast.

### AbstractState Loop (fastest pure-Python)

```python
AS = CoolProp.AbstractState("HEOS", "R134a")
results = np.empty(N)
for i, T in enumerate(T_array):
    AS.update(CoolProp.PT_INPUTS, P, T)
    results[i] = AS.hmass()
```

### Configuration Tuning

```python
CP.set_config_bool(CP.USE_GUESSES_IN_PROPSSI, True)  # for sequential vectorized calls
CP.set_config_bool(CP.DONT_CHECK_PROPERTY_LIMITS, True)  # dangerous but faster
```

### Tabular Backends

```python
AS = CoolProp.AbstractState("BICUBIC&HEOS", "R245fa")
# One-time table gen (~20 MB stored in ~/.CoolProp/Tables)
# Create ONE instance per fluid — multiple instances re-load the table
```

## Reference States

```python
from CoolProp.CoolProp import set_reference_state

set_reference_state("R134a", "IIR")    # H=200 kJ/kg, S=1 kJ/kg/K at 0°C sat liquid
set_reference_state("R134a", "ASHRAE") # H=0, S=0 at -40°C sat liquid
set_reference_state("R134a", "NBP")    # H=0, S=0 at normal boiling point
set_reference_state("R134a", "DEF")    # Library default
```

**Critical rules:**
1. Call `set_reference_state` BEFORE creating any AbstractState instances
2. Existing instances do NOT pick up the change
3. ASHRAE reference (-40°C) is outside Water's valid range — do not use for water
4. Set once at program start; never change mid-calculation

## Known Failure Modes

| Scenario | Result | Fix |
|---|---|---|
| T,P input in two-phase region | ValueError | Use T,Q or P,Q instead |
| Speed of sound in two-phase | ValueError | Check phase first |
| Wrong imposed phase | **Silent wrong answer** | Remove specify_phase or verify |
| H,S input in two-phase | Solver divergence | Avoid H,S in two-phase |
| Mixture with P,H input pair | ValueError | Use only T,P / T,Q / P,Q |
| Near-critical (within 1e-4% of Psat) | ValueError | Use `|liquid` or `|gas` hint |
| INCOMP fluid outside T range | ValueError | Clamp T to valid range |
| Unknown binary pair (REFPROP) | **Silent wrong answer** | Enable DONT_ESTIMATE flag |
| set_reference_state after instantiation | **Silent wrong answer** | Set before all instantiations |
| AbstractState in multiprocessing | TypeError (pickle) | Create AS inside worker |
| Phase envelope overshoot | Wrong data near critical | Validate PE.p monotonicity |
| Negative absolute pressure | ValueError | CoolProp requires P > 0 always |

## Defensive Coding Pattern

```python
def safe_props(output, key1, val1, key2, val2, fluid):
    """PropsSI wrapper with diagnostic error messages."""
    try:
        return PropsSI(output, key1, val1, key2, val2, fluid)
    except ValueError as e:
        phase = PhaseSI(key1, val1, key2, val2, fluid)
        raise ValueError(
            f"PropsSI({output}) failed for {fluid} at {key1}={val1}, "
            f"{key2}={val2}. Phase: {phase}. Error: {e}"
        ) from e

def get_state(AS, input_pair, v1, v2):
    """Return dict of properties with phase-aware handling."""
    AS.update(input_pair, v1, v2)
    phase = AS.phase()
    result = {
        "T": AS.T(), "P": AS.p(), "h": AS.hmass(),
        "s": AS.smass(), "rho": AS.rhomass(), "phase": phase
    }
    if phase != CoolProp.iphase_twophase:
        result["cp"] = AS.cpmass()
        result["mu"] = AS.viscosity()
        result["k"] = AS.conductivity()
        result["a"] = AS.speed_sound()
    else:
        result["Q"] = AS.Q()
    return result
```

## Multiprocessing

AbstractState cannot be pickled. Create instances inside worker functions:

```python
def worker(args):
    import CoolProp
    AS = CoolProp.AbstractState("HEOS", "Water")
    AS.update(CoolProp.PT_INPUTS, args[0], args[1])
    return AS.hmass()
```

PropsSI is thread-safe for scalar inputs (but not for reference state changes).

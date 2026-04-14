# Thermal Engineering Reference

Loadable reference for the thermo-engineer agent. Covers the Caleb Bell
stack (ht, fluids, thermo, chemicals), water/steam libraries, ideal gas
properties, unit handling, material properties, and common engineering
calculation patterns.

## Library Stack (installed in .venv)

| Library | Version | Role |
|---|---|---|
| CoolProp | 7.2.0 | Pure/pseudo-pure fluid properties (Helmholtz EOS) |
| ht | 1.2.0 | Heat transfer correlations (convection, radiation, HX, boiling) |
| fluids | 1.3.0 | Pipe flow, friction factors, dimensionless numbers, fittings |
| thermo | 0.6.0 | EOS, flash calculations, Chemical() convenience class |
| chemicals | 1.5.1 | 20,000-chemical property database (open DIPPR substitute) |
| iapws | 1.5.5 | IAPWS-IF97/95 water/steam (higher precision edge cases) |
| pint | 0.25.3 | Unit-aware arithmetic |
| pyromat | 2.2.6 | Ideal gas properties, NASA polynomials (~1,000 species) |

## ht — Heat Transfer Correlations

### Internal Convection (`ht.conv_internal`)

All Nusselt correlations require Reynolds number, Prandtl number, and
**Darcy friction factor** (`fd`). Compute `fd` from `fluids.friction_factor()` first.

```python
import ht
import fluids

Re = 1e5; Pr = 0.71; eD = 0.0  # smooth pipe
fd = fluids.friction_factor(Re=Re, eD=eD)

# Turbulent correlations
Nu = ht.conv_internal.turbulent_Gnielinski(Re=Re, Pr=Pr, fd=fd)        # preferred modern
Nu = ht.conv_internal.turbulent_Dittus_Boelter(Re=Re, Pr=Pr, fd=fd)    # legacy/quick
Nu = ht.conv_internal.turbulent_Sieder_Tate(Re=Re, Pr=Pr, fd=fd)       # with mu correction
Nu = ht.conv_internal.turbulent_Colburn(Re=Re, Pr=Pr, fd=fd)

# Laminar correlations (no fd needed)
Nu = ht.conv_internal.laminar_T_const()       # Nu = 3.66 (constant wall T)
Nu = ht.conv_internal.laminar_Q_const()       # Nu = 4.354 (constant heat flux)
Nu = ht.conv_internal.laminar_entry_Seider_Tate(Re=Re, Pr=Pr, L=1.0, Di=0.01)
Nu = ht.conv_internal.laminar_entry_thermal_Hausen(Re=Re, Pr=Pr, L=1.0, Di=0.01)

# Auto-selector
methods = ht.conv_internal.Nu_conv_internal_methods(Re=Re, Pr=Pr, fd=fd)
Nu = ht.conv_internal.Nu_conv_internal(Re=Re, Pr=Pr, fd=fd)  # picks best
```

### External Convection (`ht.conv_external`)

```python
# Cylinder in crossflow
Nu = ht.conv_external.Nu_cylinder_Churchill_Bernstein(Re=Re, Pr=Pr)  # all Re
Nu = ht.conv_external.Nu_cylinder_Zukauskas(Re=Re, Pr=Pr)
Nu = ht.conv_external.Nu_cylinder_Sanitjai_Goldstein(Re=Re, Pr=Pr)   # recommended

# Flat plate
Nu = ht.conv_external.Nu_flat_plate_Baehr(Re=Re, Pr=Pr)  # laminar, 4 Pr ranges
```

### Natural Convection (`ht.conv_free_immersed`)

```python
# Vertical plate
Nu = ht.conv_free_immersed.Nu_free_vertical_plate_Churchill_Chu(Pr=Pr, Gr=Gr)

# Horizontal cylinder
Nu = ht.conv_free_immersed.Nu_free_horizontal_cylinder(Pr=Pr, Gr=Gr)
```

### Heat Exchangers

```python
# LMTD
dTlm = ht.LMTD(Thi=150, Tho=90, Tci=20, Tco=60)             # counterflow default
dTlm = ht.LMTD(Thi=150, Tho=90, Tci=20, Tco=60, counterflow=False)  # parallel

# LMTD correction factor (shell-and-tube)
F = ht.F_LMTD_Fakheri(Tci=20, Tco=60, Thi=150, Tho=90, shells=1)

# Effectiveness-NTU
eff = ht.effectiveness_from_NTU(NTU=2.0, Cr=0.5, subtype='counterflow')
NTU = ht.NTU_from_effectiveness(eff=0.8, Cr=0.5, subtype='counterflow')

# Subtypes: 'counterflow', 'parallel', 'crossflow' (+ mixed/unmixed variants),
#           'shell&tube' (+ pass variants), 'boiler', 'condenser'

# Min/max heat capacity rates
Cmin, Cmax, Cr = ht.calc_Cmin(mh=1.0, mc=2.0, Cph=4200, Cpc=1000)
```

### Radiation

```python
# Blackbody spectral radiance
E = ht.radiation.blackbody_spectral_radiance(T=5800, wavelength=0.5e-6)

# Net radiation between surfaces
q = ht.radiation.q_rad(emissivity=0.9, T=500, T2=300)  # W/m²

# View factor catalog — check ht.radiation module for specific geometries
```

### Boiling and Condensation

```python
# Rohsenow pool boiling
h = ht.boiling_nucleic.Rohsenow(rhol=958, rhog=0.6, mul=2.8e-4, kl=0.68,
                                  Cpl=4217, Hvap=2.26e6, sigma=0.059,
                                  dTsat=10, Csf=0.013, n=1.0)

# Nusselt film condensation on vertical plate
h = ht.condensation.Nusselt_vertical_plate(rhol=958, rhog=0.6, mul=2.8e-4,
                                             kl=0.68, Hvap=2.26e6, L=1.0, dTsat=5)
```

### Material Properties

```python
# Thermal conductivity by material name
k = ht.k_material('copper')        # W/m·K
k = ht.k_material('stainless_304')

# Density
rho = ht.rho_material('aluminum')  # kg/m³

# Cp
cp = ht.Cp_material('aluminum')    # J/kg·K

# Nearest match (fuzzy)
name = ht.nearest_material('inconel')
```

## fluids — Fluid Mechanics

### Dimensionless Numbers

```python
import fluids

Re = fluids.Reynolds(V=2.0, D=0.05, rho=1.2, mu=1.8e-5)
Pr = fluids.Prandtl(Cp=1006, mu=1.8e-5, k=0.026)
Nu = fluids.Nusselt(h=50, L=0.05, k=0.026)
Gr = fluids.Grashof(L=0.5, beta=3.4e-3, T1=350, T2=300, rho=1.1, mu=2e-5)
Ra = Gr * Pr  # Rayleigh = Grashof * Prandtl
Bi = fluids.Biot(h=50, L=0.01, k=16)   # Biot number
```

### Friction Factor

```python
# Darcy friction factor (auto-selects laminar/turbulent)
fd = fluids.friction_factor(Re=1e5, eD=0.001)       # eD = roughness/diameter
fd = fluids.friction_factor(Re=1500, eD=0)           # laminar: 64/Re

# Specific correlations
fd = fluids.friction.Colebrook(Re=1e5, eD=0.001)
fd = fluids.friction.Churchill_1977(Re=1e5, eD=0.001)
```

### Pipe Flow

```python
# Pressure drop in pipe
dP = fluids.dP_round_pipe(fd=fd, L=10, D=0.05, V=2.0, rho=1000)

# Fitting losses (K-factor method)
K = fluids.fittings.bend_rounded(Di=0.05, angle=90, rc=0.15)
K = fluids.fittings.contraction_sharp(Di1=0.1, Di2=0.05)
```

### Compressible Flow

```python
# Isentropic relations
T_ratio = fluids.compressible.T_stagnation(T=300, V=200, Cp=1005)
P_ratio = fluids.compressible.P_stagnation(P=1e5, T=300, V=200, Cp=1005, k=1.4)
```

### Atmosphere

```python
# ISA standard atmosphere
T, P, rho = fluids.atmosphere.ATMOSPHERE_1976(Z=10000)  # altitude in meters
```

## thermo — Equations of State and Chemical Properties

### Chemical() Convenience Class

```python
from thermo import Chemical

w = Chemical('water')
w = Chemical('water', T=350, P=1e5)  # at specific conditions

# Properties (auto-selects best data source)
w.Tc      # critical temperature, K
w.Pc      # critical pressure, Pa
w.omega   # acentric factor
w.MW      # molecular weight, g/mol
w.rho     # density at (T, P), kg/m³
w.mu      # viscosity, Pa·s
w.k       # thermal conductivity, W/m·K
w.Cp      # heat capacity, J/kg/K (if available at state)
w.Hf      # standard enthalpy of formation, J/mol
w.Tb      # normal boiling point, K
w.Tm      # melting point, K
w.CAS     # CAS number
w.formula # molecular formula
```

### chemicals Database

```python
from chemicals import Tc, Pc, omega, Tb, Hfg, MW

Tc('7732-18-5')     # Water critical T by CAS number
Pc('7732-18-5')     # Water critical P
omega('7732-18-5')  # Acentric factor
Tb('7732-18-5')     # Normal boiling point
MW('7732-18-5')     # Molecular weight

# Search by name
from chemicals import CAS_from_any
cas = CAS_from_any('ethanol')  # returns '64-17-5'
```

## iapws — Water/Steam (IAPWS Standard)

```python
from iapws import IAPWS97

# Create state object
st = IAPWS97(T=773.15, P=10)  # T in K, P in MPa (!)

# Properties
st.h      # kJ/kg (!)
st.s      # kJ/(kg·K) (!)
st.v      # m³/kg (specific volume)
st.cp     # kJ/(kg·K) (!)
st.rho    # kg/m³
st.mu     # Pa·s
st.k      # W/m·K
st.x      # quality (0-1 in two-phase, None outside)

# Saturation from pressure
st = IAPWS97(P=1.0, x=0)   # saturated liquid at 1 MPa
st = IAPWS97(P=1.0, x=1)   # saturated vapor at 1 MPa

# From enthalpy + pressure
st = IAPWS97(P=10, h=3375)  # P in MPa, h in kJ/kg
```

**Unit warning:** iapws uses MPa and kJ, NOT Pa and J like CoolProp.

## pyromat — Ideal Gas Properties

```python
import pyromat as pm

# Get species
air = pm.get('ig.air')
n2 = pm.get('ig.N2')
co2 = pm.get('ig.CO2')
h2o = pm.get('ig.H2O')

# Properties (T in K by default)
h = air.h(T=500)       # kJ/kg (returns array)
s = air.s(T=500, p=1)  # kJ/(kg·K), p in bar (!)
cp = air.cp(T=500)     # kJ/(kg·K)
cv = air.cv(T=500)     # kJ/(kg·K)

# Configure units
pm.config['unit_pressure'] = 'Pa'
pm.config['unit_energy'] = 'J'
pm.config['unit_matter'] = 'kg'
pm.config['unit_temperature'] = 'K'
```

**Unit warning:** pyromat defaults to kJ, bar. Configure units explicitly.

## pint — Unit-Aware Arithmetic

```python
import pint
u = pint.UnitRegistry()

# Basic usage
P = 14.696 * u.psi
P_pa = P.to(u.Pa)              # 101325.4 Pa
P_bar = P.to(u.bar)            # 1.01325 bar

T = 25 * u.degC
T_K = T.to(u.K)                # 298.15 K

# Temperature DIFFERENCES (critical gotcha)
dT = 10 * u.delta_degC         # use delta_degC for differences
dT_K = dT.to(u.K)              # 10 K (correct)
# DO NOT use u.degC for temperature differences — the offset gets applied

# Flow rate
mdot = 0.5 * u.kg / u.s
Q = mdot / (998 * u.kg / u.m**3)  # volumetric flow
```

## Quick-Reference: Material Thermal Conductivities (300 K)

| Material | k (W/m·K) |
|---|---|
| Copper (pure) | 400 |
| Aluminum 6061-T6 | 167 |
| Stainless Steel 304 | 16 |
| Stainless Steel 316 | 14 |
| Titanium 6Al-4V | 7 |
| Invar 36 | 11 |
| Borosilicate glass | 1.1 |
| UHMWPE | 0.51 |
| PTFE (Teflon) | 0.25 |
| Kapton (polyimide) | 0.12 |
| Aerogel blanket | 0.015 |
| Dry nitrogen gas | 0.026 |
| Air | 0.026 |
| Vacuum (< 1e-3 Pa) | ~0 (conduction) |

## Quick-Reference: Fluid Properties at 300 K, 1 atm

| Fluid | rho (kg/m³) | Cp (J/kg·K) | k (W/m·K) | mu (Pa·s) | Pr |
|---|---|---|---|---|---|
| Water | 997 | 4181 | 0.610 | 8.5e-4 | 5.83 |
| Air | 1.177 | 1006 | 0.0263 | 1.85e-5 | 0.707 |
| Nitrogen | 1.145 | 1040 | 0.0260 | 1.78e-5 | 0.716 |

## Unit Conversion Gotchas

1. **Temperature differences:** 1 K = 1°C = 1.8°R = 1.8°F (delta).
   Never add 273.15 to a temperature *difference*.

2. **Pressure gauge vs absolute:** CoolProp and iapws always want absolute.
   Convert: P_abs = P_gauge + P_atm. Common mistake: psig → Pa without adding 14.696 psi first.

3. **Enthalpy reference states:** IAPWS: H=0 at triple point (0.01°C).
   CoolProp: same for water. Only use enthalpy *differences*; never compare
   absolute enthalpies across libraries.

4. **iapws uses MPa and kJ.** CoolProp uses Pa and J. Mixing them silently
   produces 1000x errors.

5. **pyromat defaults to kJ and bar.** Configure units explicitly or convert.

6. **Specific heat units:** NIST gives J/mol·K; engineering correlations want
   J/kg·K. Divide by molar mass in kg/mol.

## Common Engineering Calculations — Cheat Sheet

### "What is the density of water at 50°C, 10 bar?"
```python
rho = CP.PropsSI('D', 'T', 323.15, 'P', 10e5, 'Water')  # kg/m³
```

### "Saturation temperature of R134a at 5 bar?"
```python
T_sat = CP.PropsSI('T', 'P', 5e5, 'Q', 0, 'R134a')  # K
```

### "Nusselt number for turbulent pipe flow?"
```python
fd = fluids.friction_factor(Re=Re, eD=eD)
Nu = ht.conv_internal.turbulent_Gnielinski(Re=Re, Pr=Pr, fd=fd)
h_conv = Nu * k_fluid / D_pipe  # W/m²·K
```

### "LMTD for a counterflow heat exchanger?"
```python
dTlm = ht.LMTD(Thi=150, Tho=90, Tci=20, Tco=60)  # °C or K (differences)
Q = U * A * dTlm  # W
```

### "Effectiveness of a counterflow HX with NTU=2, Cr=0.5?"
```python
eff = ht.effectiveness_from_NTU(NTU=2.0, Cr=0.5, subtype='counterflow')
```

### "Friction factor and pressure drop in a pipe?"
```python
Re = fluids.Reynolds(V=V, D=D, rho=rho, mu=mu)
fd = fluids.friction_factor(Re=Re, eD=roughness/D)
dP = fluids.dP_round_pipe(fd=fd, L=L, D=D, V=V, rho=rho)  # Pa
```

### "Properties of 30% ethylene glycol brine at -10°C?"
```python
rho = CP.PropsSI('D', 'T', 263.15, 'P', 1e5, 'INCOMP::MEG[0.3]')
cp  = CP.PropsSI('C', 'T', 263.15, 'P', 1e5, 'INCOMP::MEG[0.3]')
mu  = CP.PropsSI('V', 'T', 263.15, 'P', 1e5, 'INCOMP::MEG[0.3]')
k   = CP.PropsSI('L', 'T', 263.15, 'P', 1e5, 'INCOMP::MEG[0.3]')
```

### "Steam enthalpy at 10 MPa, 500°C?"
```python
# CoolProp (Pa, K):
h = CP.PropsSI('H', 'T', 773.15, 'P', 10e6, 'Water')  # J/kg

# iapws (MPa, K) — returns kJ/kg:
from iapws import IAPWS97
st = IAPWS97(T=773.15, P=10)
h = st.h  # kJ/kg
```

### "Humid air enthalpy at 25°C, 50% RH?"
```python
from CoolProp.HumidAirProp import HAPropsSI
h = HAPropsSI('H', 'T', 298.15, 'P', 101325, 'R', 0.5)  # J/kg_dry_air
```

### "Ideal gas Cp of CO2 at 800 K?"
```python
import pyromat as pm
pm.config['unit_energy'] = 'J'
pm.config['unit_matter'] = 'kg'
co2 = pm.get('ig.CO2')
cp = co2.cp(T=800)  # J/(kg·K)
```

### "Thermal conductivity of stainless steel?"
```python
k = ht.k_material('stainless_304')  # W/m·K
```

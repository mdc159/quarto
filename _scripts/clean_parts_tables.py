"""Clean the test rig parts tables in report.qmd:
- Strip embedded URLs from supplier links
- Remove `?utm_source=chatgpt.com` cruft and similar tracking params
- Simplify the bracketed link syntax `[Name](https://...)` -> `Name`
- Replace the worst grid tables (test rig section) with cleaner pipe tables
"""
import re
from pathlib import Path

SRC = Path("D:/Quarto/report.qmd")
txt = SRC.read_text(encoding="utf-8")

# ---- 1. Convert markdown links to plain text -----------------------------
# [Anchor text](https://...) -> Anchor text
txt = re.sub(r"\[([^\]]+)\]\(https?://[^\)]+\)", r"\1", txt)

# ---- 2. Remove any leftover bare URLs in parentheses ---------------------
txt = re.sub(r"\(https?://[^\)\s]+\)", "", txt)

# ---- 3. Replace the broken parts/component grid tables -------------------
# The "Stepper-motor drive train" section uses grid tables that were
# originally generated with embedded URL clutter. Replace with clean
# pipe tables.

stepper_table_pattern = re.compile(
    r"\*\*Stepper-motor drive train \(ultra-fine resolution\)\*\*\s*\n\n.*?"
    r"\*unit prices from current web catalogues; volume or educational discounts often available\.",
    re.DOTALL,
)

stepper_replacement = """**Stepper-motor drive train (ultra-fine resolution)**

::: {#tbl-stepper-motor}

| Function                  | Recommended part                                                | Key specs                                                                       | Cost (USD) |
|:--------------------------|:----------------------------------------------------------------|:--------------------------------------------------------------------------------|-----------:|
| Precision stepper motor   | StepperOnline 23HM22-2804S (NEMA-23, 0.9°/step)                 | 1.26 N·m holding torque, 2.8 A/phase; with 32× microstepping → ~25 nrad         |       ~45  |
| Alternative motor         | Nanotec ST5909 (NEMA-23, 0.9°/step high-torque)                 | Drop-in form factor; 0.6–1.9 N·m stack-length variants for extra headroom       |   ~75–110  |

Recommended stepper motors for the test rig drive train. Both deliver sub-microradian theoretical resolution and ample torque margin (≥2× peak breakaway).
:::"""

txt, n1 = stepper_table_pattern.subn(stepper_replacement, txt)


controller_table_pattern = re.compile(
    r"\*\*Motion controller / driver options\*\*\s*\n\n.*?"
    r"All three solutions expose the motor torque",
    re.DOTALL,
)

controller_replacement = """**Motion controller / driver options**

::: {#tbl-controllers}

| Controller                              | Microstepping & interface              | Notable features                                                                                          | Cost (USD) |
|:----------------------------------------|:---------------------------------------|:----------------------------------------------------------------------------------------------------------|-----------:|
| Trinamic TMCM-1230 (single-axis)        | 256 µsteps/full-step; RS-485 or CAN    | StallGuard™ stall detection, CoolStep™ current optimization; encoder feedback ready                       |       ~120 |
| Raspberry Pi Stepper HAT (dual DRV8825) | 1/32 µstep; I²C control                | Low-cost prototype option; runs directly from logging Pi; 2.5 A/phase                                     |        ~28 |
| Galil DMC-21×5 (Ethernet, multi-axis)   | >256 µstep via external drivers        | Industrial-grade; onboard PID, s-curves, LabVIEW drivers; easy synchronization with torque sensor         |       ~900 |

Three controller options spanning low-cost prototyping (Pi HAT) to industrial control (Galil). All expose motor torque (current sense or StallGuard) and position to the data-acquisition stack.
:::

All three solutions expose the motor torque"""

txt, n2 = controller_table_pattern.subn(controller_replacement, txt)


torque_chain_pattern = re.compile(
    r"\*\*Torque measurement chain\*\*\s*\n\n.*?"
    r"Both options provide ±10 V inputs",
    re.DOTALL,
)

torque_chain_replacement = """**Torque measurement chain**

::: {#tbl-torque-chain}

| Sensor type           | Recommended model                              | Range / resolution                                       | Notes                                                                                  |
|:----------------------|:-----------------------------------------------|:---------------------------------------------------------|:---------------------------------------------------------------------------------------|
| Inline reaction torque | FUTEK TFF400-05 (±0.04 N·m)                   | Covers 0–0.2 N·m running torque; 0.05 % RO non-repeat.   | 1 mV/V full-bridge output, 4-pin LEMO; through-hole design avoids alignment errors     |
| Higher range           | Interface T8 contactless rotary transducer    | 0.2–2 N·m; enables overload studies up to seizure        | ±5 V analog or USB digital; 10 kS/s                                                    |

Recommended torque sensors covering the nominal operating range and overload regime.
:::

**Signal conditioning & DAQ**

::: {#tbl-daq}

| Item                                                  | Specification                                              |
|:------------------------------------------------------|:-----------------------------------------------------------|
| NI cDAQ-9237 (with cDAQ-9171 USB chassis)             | 4-channel bridge module; 0.02 % FS accuracy; 50 kS/s simultaneous |
| LabJack LJTick-InAmp                                  | Low-noise instrumentation amplifier (gain ×1–×201) for Pi/U3/T7 logging |

Signal-conditioning and data-acquisition options for the bridge sensor.
:::

Both options provide ±10 V inputs"""

txt, n3 = torque_chain_pattern.subn(torque_chain_replacement, txt)


# ---- 4. Replace the procurement checklist table --------------------------
procurement_pattern = re.compile(
    r"\*\*Procurement checklist & indicative pricing\*\*\s*\n\n.*?"
    r"\*street pricing April 2025; ±10 %\.",
    re.DOTALL,
)

procurement_replacement = """**Procurement checklist & indicative pricing**

::: {#tbl-procurement}

| Qty | Component                                  | Supplier (example)         | Unit (USD) |
|----:|:-------------------------------------------|:---------------------------|-----------:|
|   1 | StepperOnline 0.9° NEMA-23 motor           | OMC-StepperOnline          |         45 |
|   1 | TMCM-1230 controller                       | Digi-Key or Mouser         |        120 |
|   1 | FUTEK TFF400-05 torque sensor              | FUTEK store                |       1100 |
|   1 | NI cDAQ-9237 + 9171 USB chassis            | NI                         |       1650 |
|   2 | Bellows coupling, 6 mm – 10 mm             | Ruland or Huco             |         40 |
|   1 | Zero-backlash rigid coupling               | Ruland                     |         30 |
|   1 | N₂ purge mini-chamber kit                  | Thorlabs (VAC-MCH-CS)      |        150 |
|  —  | Krytox GPL 205 (control lubricant, 5 g)    | TMC Industries             |         45 |

Indicative procurement list for the entire rig (April 2025 street pricing, ±10 %)."""

txt, n4 = procurement_pattern.subn(procurement_replacement, txt)


SRC.write_text(txt, encoding="utf-8", newline="\n")
print(f"Replaced grid tables: stepper={n1}, controller={n2}, torque={n3}, procurement={n4}")

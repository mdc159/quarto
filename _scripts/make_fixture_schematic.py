"""Generate a placeholder schematic of the test fixture as a PNG.
This stands in for a CAD or hand-drawn diagram until one is available.
"""
from pathlib import Path
import matplotlib.pyplot as plt
import matplotlib.patches as patches

OUT = Path("D:/Quarto/figures/fixture-schematic.png")
OUT.parent.mkdir(parents=True, exist_ok=True)

fig, ax = plt.subplots(figsize=(11, 5.5), dpi=150)
ax.set_xlim(0, 14)
ax.set_ylim(0, 7)
ax.set_aspect("equal")
ax.axis("off")

# Outer N2 chamber
chamber = patches.FancyBboxPatch(
    (0.4, 0.4), 13.2, 6.2,
    boxstyle="round,pad=0.05,rounding_size=0.25",
    linewidth=2, edgecolor="#1f77b4", facecolor="#e7f0fa", alpha=0.6,
)
ax.add_patch(chamber)
ax.text(13.4, 6.3, "N$_2$ purge chamber",
        ha="right", va="top", fontsize=10, color="#1f77b4", style="italic")

# Granite base plate
base = patches.Rectangle((1.0, 1.0), 12.0, 0.45,
                         linewidth=1, edgecolor="k", facecolor="#bdbdbd")
ax.add_patch(base)
ax.text(7.0, 1.05, "Granite base plate (100×150×25 mm)",
        ha="center", va="bottom", fontsize=8, color="k")

# Stepper motor
motor = patches.Rectangle((1.4, 1.55), 1.6, 1.6,
                          linewidth=1.5, edgecolor="k", facecolor="#ffd54f")
ax.add_patch(motor)
ax.text(2.2, 2.35, "Stepper\nmotor", ha="center", va="center", fontsize=8)
ax.text(2.2, 3.30, "NEMA 23, 0.9°", ha="center", va="bottom", fontsize=7,
        style="italic", color="0.3")

# Bellows coupling 1
ax.plot([3.0, 3.6], [2.35, 2.35], "k-", lw=2)
ax.add_patch(patches.Ellipse((3.3, 2.35), 0.6, 0.4,
                             linewidth=1, edgecolor="k", facecolor="#fff"))
ax.text(3.3, 1.85, "bellows", ha="center", fontsize=6, color="0.4")

# Torque sensor
torque = patches.Rectangle((3.6, 1.85), 1.4, 1.0,
                           linewidth=1.5, edgecolor="k", facecolor="#ef5350")
ax.add_patch(torque)
ax.text(4.3, 2.35, "Torque\nsensor", ha="center", va="center", fontsize=8, color="white")
ax.text(4.3, 1.55, "FUTEK TFF400-05", ha="center", va="top", fontsize=7,
        style="italic", color="0.3")

# Rigid coupling
ax.plot([5.0, 5.6], [2.35, 2.35], "k-", lw=2)
ax.add_patch(patches.Rectangle((5.05, 2.20), 0.5, 0.30,
                               linewidth=0.8, edgecolor="k", facecolor="#fff"))

# Adjuster screw + translation block (HIGHLIGHTED)
block = patches.Rectangle((5.6, 1.55), 3.4, 1.6,
                          linewidth=2.5, edgecolor="#d32f2f", facecolor="#ffe9e7")
ax.add_patch(block)
ax.text(7.3, 2.85, "Translation block", ha="center", fontsize=8)
ax.text(7.3, 2.35, "1/4-80 adjuster\n(unit under test)",
        ha="center", va="center", fontsize=8, color="#d32f2f", weight="bold")
ax.text(7.3, 1.65, "crossed-roller bearings", ha="center", va="bottom",
        fontsize=7, style="italic", color="0.3")

# Spring preload
for x in (9.1, 9.3, 9.5):
    ax.plot([x]*2, [1.85, 2.85], "k-", lw=0.6)
ax.text(9.3, 1.55, "preload spring\n(46.7 N)", ha="center", va="top",
        fontsize=7, color="0.3")

# Laser displacement sensor (above)
sensor = patches.Rectangle((6.3, 4.6), 2.0, 0.8,
                           linewidth=1.5, edgecolor="k", facecolor="#43a047")
ax.add_patch(sensor)
ax.text(7.3, 5.0, "Laser displacement sensor",
        ha="center", va="center", fontsize=8, color="white")
ax.text(7.3, 5.55, "Keyence LK-G152", ha="center", va="bottom", fontsize=7,
        style="italic", color="0.3")
# Beam
ax.plot([7.3, 7.3], [4.6, 3.15], color="#43a047", lw=1, ls="--")
ax.scatter([7.3], [3.15], s=20, color="#43a047")

# Particle counter port
ax.add_patch(patches.Circle((11.5, 4.0), 0.35, linewidth=1.5,
                            edgecolor="k", facecolor="#7e57c2"))
ax.text(11.5, 4.0, "PC", ha="center", va="center", fontsize=7,
        color="white", weight="bold")
ax.text(11.5, 4.55, "particle\ncounter port", ha="center", va="bottom",
        fontsize=7, color="0.3")
ax.plot([11.5, 11.5], [3.65, 3.0], "k--", lw=0.8)

# N2 inlet
ax.annotate("N$_2$ in", xy=(0.4, 5.3), xytext=(-0.4, 5.3),
            ha="right", va="center", fontsize=9, color="#1f77b4",
            arrowprops=dict(arrowstyle="->", color="#1f77b4", lw=1.5))

# DAQ box (outside chamber)
ax.text(7.0, 0.18, "Drive train: motor → bellows → torque sensor → rigid coupling → adjuster screw",
        ha="center", va="bottom", fontsize=8, style="italic", color="0.4")

ax.set_title("Test Fixture Schematic — 1/4-80 Adjuster Galling Study",
             fontsize=11, pad=8)

fig.tight_layout()
fig.savefig(OUT, dpi=150, bbox_inches="tight", facecolor="white")
print(f"Wrote {OUT}")

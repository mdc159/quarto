"""Pass 3 transformations for report.qmd:
- Wrap the 4 important pipe tables in cross-reference divs
- Convert key paragraphs to callout blocks
"""
import re
from pathlib import Path

SRC = Path("D:/Quarto/report.qmd")
txt = SRC.read_text(encoding="utf-8")


# ---- Helper to wrap a pipe table in a div ------------------------------
def wrap_pipe_table(text: str, header_pattern: str, label: str, caption: str) -> str:
    """Find a pipe table whose header line matches `header_pattern`,
    capture the entire table (header + separator + rows until blank line),
    and wrap it in a `::: {#tbl-label}` div with caption."""
    lines = text.split("\n")
    out = []
    i = 0
    wrapped = False
    while i < len(lines):
        line = lines[i]
        if (not wrapped) and re.search(header_pattern, line):
            # Look for separator on next line
            if i + 1 < len(lines) and re.match(r"^\s*\|[-: |]+\|\s*$", lines[i + 1]):
                # Found a pipe table starting here
                start = i
                end = i + 2
                # Continue until we hit a blank line or non-pipe line
                while end < len(lines) and lines[end].strip().startswith("|"):
                    end += 1
                # Build the wrapped block
                table_lines = lines[start:end]
                out.append(f"::: {{#tbl-{label}}}")
                out.append("")
                out.extend(table_lines)
                out.append("")
                out.append(caption)
                out.append(":::")
                i = end
                wrapped = True
                continue
        out.append(line)
        i += 1
    return "\n".join(out)


# ---- 1. Wrap the four main pipe tables --------------------------------
txt = wrap_pipe_table(
    txt,
    r"\| ID \| Requirement \| Spec limit",
    "requirements-baseline",
    "Requirements baseline against the lubricated reference design.",
)
txt = wrap_pipe_table(
    txt,
    r"\| Pair ID \|",
    "friction-coefficients",
    "Friction coefficients from coupon tests for the three candidate material pairs.",
)
txt = wrap_pipe_table(
    txt,
    r"\| Metric \| Baseline",
    "simulink-predictions",
    "Simulink predictive analysis: baseline vs. dry worst-case key metrics.",
)
txt = wrap_pipe_table(
    txt,
    r"\| ID \| Risk \| Probability",
    "risk-register",
    "Risk register excerpt for the dry-running adjuster design.",
)


# ---- 2. Convert "### Key predictions" subsection to a callout ---------
# Pattern: "### Key predictions\n\n" + table block we just wrapped
# We want: callout-tip wrapping the heading text + the wrapped table
# Simpler: change the heading to a callout heading
txt = txt.replace(
    "### Key predictions\n",
    "::: {.callout-tip}\n## Key Predictions\n",
    1,
)
# Then we need to close the callout after the predictions table.
# The predictions table is now wrapped with `:::` end. We add another `:::`
# to close the callout right after it. The structure is:
#   ::: {.callout-tip}
#   ## Key Predictions
#   ...prose...
#   ::: {#tbl-simulink-predictions}
#   |table|
#   table caption.
#   :::
#   ...next paragraph...
# We need a closing ::: before "Simulation output stays within"
txt = txt.replace(
    "Simulation output stays within acceptance limits;",
    ":::\n\nSimulation output stays within acceptance limits;",
    1,
)


# ---- 3. Convert "### Conclusion (Thread Manufacturing)" to callout ----
txt = re.sub(
    r"### Conclusion \(Thread Manufacturing\)\s*\n\n(.*?)(?=\n## )",
    lambda m: (
        "::: {.callout-note}\n## Conclusion (Thread Manufacturing)\n\n"
        + m.group(1).rstrip()
        + "\n:::\n\n"
    ),
    txt,
    flags=re.DOTALL,
    count=1,
)


# ---- 4. Convert "**Summary:**" paragraph in failure-mechanisms section -
# Match a paragraph that starts with "**Summary:** In summary, the 304 SS"
txt = re.sub(
    r"\*\*Summary:\*\* (In summary, the 304 SS.*?)(?=\n\n)",
    lambda m: (
        "::: {.callout-note}\n## Summary of Failure Mechanisms\n\n"
        + m.group(1).rstrip()
        + "\n:::"
    ),
    txt,
    flags=re.DOTALL,
    count=1,
)


SRC.write_text(txt, encoding="utf-8", newline="\n")
print("Pass 3 transformations applied.")

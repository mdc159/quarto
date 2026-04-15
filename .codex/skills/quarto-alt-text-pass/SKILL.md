---
name: quarto-alt-text-pass
description: >
  Generate or review figure alt text for Quarto documents in this workspace.
  Use when adding or improving fig-alt in .qmd files, reviewing accessibility
  before a render pass, or describing externally generated figures such as
  MATLAB outputs that are embedded into Quarto reports.
---

# Quarto Alt Text Pass

Start from the upstream skill at
`../../../skills/quarto/quarto-alt-text/SKILL.md`, then apply the
workspace-specific workflow below.

## Workflow

1. Find the figures in the edited section or document.
2. Read the surrounding prose, figure caption, and any code that generated the
   figure.
3. For externally generated static figures, use the surrounding prose, file
   name, supporting tables, and analysis summary to infer what the figure must
   communicate.
4. Write `fig-alt` that complements the caption instead of repeating it.
5. Re-check the edited figure in rendered output when the visual meaning is not
   obvious from code alone.

## Keep the upstream formula

Use Amy Cesal's three-part pattern:

1. chart or figure type
2. data or structure being shown
3. key insight or takeaway

## Workspace-specific guardrails

- Do not start with "Image of" or "Chart showing".
- Include the key engineering takeaway when the caption is generic.
- Mention the failure regime, threshold crossing, or comparison outcome when
  that is the reason the figure exists.
- Review every substantive figure touched in the current edit, not just the one
  that triggered the task.

---
name: quarto-brand-setup
description: >
  Set up shared branding for Quarto work in this workspace. Use when creating
  or applying _brand.yml, wiring brand assets into Quarto projects, or moving a
  project from ad hoc theming to a reusable workspace or project brand
  configuration.
---

# Quarto Brand Setup

Start from the upstream skill at `../../../skills/brand-yml/SKILL.md`, then
apply the workspace-specific rules below.

## Default placement

- Prefer `../../../_shared/_brand.yml` for workspace-wide identity shared by
  multiple projects.
- Use a project-root `_brand.yml` only when a project needs a true override or
  an isolated visual identity.

## Workflow

1. Gather the real brand inputs first: colors, fonts, logos, and any required
   links or organization metadata.
2. Keep the initial file minimal: color, typography, and only the logo/meta
   fields that are actually needed.
3. Wire the brand file into the project `_quarto.yml` or document frontmatter.
4. Test at least the formats the project already renders.

## Use these references as needed

- Upstream brand skill:
  `../../../skills/brand-yml/SKILL.md`
- Quarto-specific brand details:
  `../../../skills/brand-yml/references/quarto.md`
- Full spec:
  `../../../skills/brand-yml/references/brand-yml-spec.md`

## Guardrails

- Do not invent brand assets or colors when the user has not provided them.
- Prefer the shared brand file when multiple projects should look consistent.
- Keep branding additive. Do not break a working document format just to force
  theme parity across HTML and PDF.

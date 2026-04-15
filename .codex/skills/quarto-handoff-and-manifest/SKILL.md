---
name: quarto-handoff-and-manifest
description: >
  Capture structured state and narrative handoffs for Quarto work in this
  workspace. Use when a report spans multiple sessions, when a project needs a
  _state/<project>/manifest.yml entry or refresh, or when Codex should leave a
  clear SESSION_HANDOFF.md for the next agent.
---

# Quarto Handoff and Manifest

Read `../../../AGENTS.md` first. Use the template in
`templates/session-handoff-template.md` when starting a new narrative handoff.

## Workflow

1. Read any existing `SESSION_HANDOFF.md` and `_state/<project>/manifest.yml`
   before writing a new handoff.
2. Keep structured planning in `_state/<project>/manifest.yml`.
3. Keep session-continuation context in `SESSION_HANDOFF.md`.
4. Record exact file paths, external dependencies, current conclusions, next
   steps, and non-goals.
5. Separate problem-statement documents from design-response documents unless
   the project explicitly combines them.

## What the manifest should capture

- project and document IDs
- purpose and audience
- section list
- dependencies between sections or documents
- current status

Use `../../../_state/shipping/manifest.yml` as the reference pattern when the
new project needs a detailed section-by-section manifest.

## What the session handoff should capture

- mission
- primary working file
- computational source of truth
- current technical conclusions
- immediate next steps
- local execution commands
- explicit non-goals

## Guardrails

- Do not leave a vague handoff. Write the next session so another agent can
  start work immediately.
- Name exact files and external paths instead of saying "the report" or "the
  analysis repo".

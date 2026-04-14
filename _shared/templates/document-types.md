# Document Types and Traceability

This workspace uses five standard engineering document types. Each type
has a defined role in the traceability chain from investigation through
verification.

## Document Types

```
PIR ──findings──> EPS <──answers── EDS
                   │
                   └──drives──> TPS <──answers── TAR
```

| Code | Full Name                        | Produces        | Template        |
|------|----------------------------------|-----------------|-----------------|
| PIR  | Preliminary Investigative Report | Findings (FND-) | `pir.qmd`       |
| EPS  | Element Performance Specification| Requirements (REQ-) | (future)    |
| EDS  | Element Design Specification     | Design decisions (DSN-) | (future)|
| TPS  | Testing Protocol Specification   | Verification items (VER-) | (future)|
| TAR  | Technical Analysis Report        | Verification results | (future)  |

## Traceability ID Convention

Based on ISO/IEC/IEEE 29148:2018 and the INCOSE NRV pattern.

| Prefix | Scope       | Format           | Example      |
|--------|-------------|------------------|--------------|
| FND-   | Finding     | `FND-XX-nnn`     | `FND-SH-001` |
| REQ-   | Requirement | `REQ-XX-nnn`     | `REQ-SH-001` |
| DSN-   | Design      | `DSN-XX-nnn`     | `DSN-SH-001` |
| VER-   | Verification| `VER-XX-nnn`     | `VER-SH-001` |

`XX` = two-letter project code. Sequential numbering, gap-tolerant (do
not renumber when items are deleted).

### Project Codes

| Code | Project             |
|------|---------------------|
| SH   | Shipping            |
| GM   | Galling mitigation  |

## Finding Dispositions (PIR → EPS)

Each finding in a PIR receives a disposition:

- **Adopt** — becomes a requirement in the EPS (forward-linked)
- **Note** — informational, no requirement generated
- **Reject** — does not warrant action (rationale documented)

## Quarto Cross-Reference Integration

Findings and requirements use Quarto anchors for in-document and
cross-document traceability:

```markdown
<!-- In the PIR -->
::: {#fnd-sh-001}
**FND-SH-001:** The system loses nitrogen mass irreversibly through
the 2 PSIG outward vent during ascent and heating.
:::

<!-- In the EPS, referencing back -->
**REQ-SH-001:** The shipping configuration shall retain nitrogen
inventory across the full round-trip thermal cycle. [Source: @fnd-sh-001]
```

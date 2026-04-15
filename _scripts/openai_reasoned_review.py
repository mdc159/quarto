from __future__ import annotations

import argparse
import json
import os
import re
import sys
import textwrap
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


DEFAULT_MODEL = "o3"
DEFAULT_REASONING_EFFORT = "high"
DEFAULT_INCLUDE_SUPPORTING = True
MAX_SECTION_CHARS = 7_500
MAX_SECTION_DIGEST_CHARS = 1_200
MAX_SUPPORT_FILE_CHARS = 1_500
MAX_SUPPORT_CONTEXT_CHARS = 12_000
SEVERITY_ORDER = {"blocker": 0, "major": 1, "minor": 2}
VALID_CATEGORIES = {
    "claim-evidence",
    "equation-units",
    "logical-flow",
    "render-crossref",
    "source-of-truth",
    "handoff-state",
}


REVIEW_INSTRUCTIONS = textwrap.dedent(
    """
    You are a strict engineering document reviewer.

    Review order:
    1. Confirm source of truth and scope boundaries.
    2. Check render and cross-reference safety for Quarto or document structure.
    3. Check equations, units, thermodynamic assumptions, and conservative-vs-exact claims.
    4. Check claim-to-evidence traceability.
    5. Check narrative consistency and contradictions across the document.
    6. Report residual risks when supporting evidence is missing.

    Severity levels:
    - blocker: invalidates the main conclusion, likely unsafe, or breaks reproducibility/rendering
    - major: materially weakens the claim or leaves a meaningful contradiction unresolved
    - minor: wording, clarity, or lower-risk editorial issue

    Allowed categories:
    - claim-evidence
    - equation-units
    - logical-flow
    - render-crossref
    - source-of-truth
    - handoff-state

    Requirements:
    - Findings must be evidence-based and quote or paraphrase the local document context.
    - Do not invent equations, tables, citations, or source files that are not present.
    - If a section is clean, return an empty findings list instead of forcing issues.
    - Prefer concise, technically specific suggested fixes.
    - Treat external computational repos as the source of truth when the document says so.
    """
).strip()


@dataclass
class Section:
    title: str
    location: str
    text: str


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Run a deep engineering review over a technical document.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("target", help="Target document path (.qmd, .md, or .docx).")
    parser.add_argument(
        "--support",
        nargs="*",
        default=[],
        help="Additional supporting artifact paths to include in the review context.",
    )
    parser.add_argument(
        "--model",
        default=None,
        help="Override the OpenAI reasoning model. Defaults to TECH_DOC_REVIEW_MODEL or o3.",
    )
    parser.add_argument(
        "--no-supporting",
        action="store_true",
        help="Skip automatic discovery of nearby support artifacts.",
    )
    parser.add_argument(
        "--json-only",
        action="store_true",
        help="Skip writing the human-readable markdown artifact and print JSON to stdout.",
    )
    parser.add_argument(
        "--max-sections",
        type=int,
        default=None,
        help="Limit the number of parsed sections reviewed after chunking.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    target = Path(args.target).expanduser().resolve()
    if not target.exists():
        print(f"Target file not found: {target}", file=sys.stderr)
        return 2

    workspace_root = find_workspace_root(target)
    load_dotenv(workspace_root / ".env")

    model = args.model or os.getenv("TECH_DOC_REVIEW_MODEL", DEFAULT_MODEL)
    reasoning_effort = os.getenv(
        "TECH_DOC_REVIEW_REASONING_EFFORT", DEFAULT_REASONING_EFFORT
    )
    include_supporting = env_bool(
        "TECH_DOC_REVIEW_INCLUDE_SUPPORTING", DEFAULT_INCLUDE_SUPPORTING
    ) and not args.no_supporting
    max_sections = (
        args.max_sections
        if args.max_sections is not None
        else env_int("TECH_DOC_REVIEW_MAX_SECTIONS")
    )

    project_root = infer_project_root(target)
    project_name = project_root.name if project_root else "ad-hoc"

    requested_support_paths = [Path(p).expanduser().resolve() for p in args.support]
    missing_support = [
        f"Missing requested support file: {path}" for path in requested_support_paths if not path.exists()
    ]
    support_paths = [path for path in requested_support_paths if path.exists()]

    try:
        sections = parse_target_document(target, max_sections=max_sections)
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 2

    if not sections:
        print(f"No reviewable content found in {target}", file=sys.stderr)
        return 2

    supporting_files = discover_supporting_files(
        workspace_root=workspace_root,
        project_root=project_root,
        target=target,
        include_supporting=include_supporting,
        extra_paths=support_paths,
    )
    support_context = build_support_context(workspace_root, supporting_files)

    try:
        report = run_review(
            workspace_root=workspace_root,
            project_root=project_root,
            target=target,
            sections=sections,
            support_context=support_context,
            supporting_files=supporting_files,
            missing_support=missing_support,
            model=model,
            reasoning_effort=reasoning_effort,
        )
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    json_path, markdown_path = write_outputs(
        workspace_root=workspace_root,
        project_root=project_root,
        project_name=project_name,
        target=target,
        report=report,
        json_only=args.json_only,
    )

    if args.json_only:
        print(json.dumps(report, indent=2))
    else:
        print(f"Wrote review JSON: {json_path}")
        if markdown_path:
            print(f"Wrote review markdown: {markdown_path}")

    return 0


def find_workspace_root(start: Path) -> Path:
    for candidate in [start] + list(start.parents):
        if (candidate / "AGENTS.md").exists():
            return candidate
    raise RuntimeError(f"Could not locate workspace root from {start}")


def infer_project_root(path: Path) -> Path | None:
    for candidate in [path.parent] + list(path.parents):
        if candidate.parent.name == "projects":
            return candidate
    return None


def load_dotenv(dotenv_path: Path) -> None:
    if not dotenv_path.exists():
        return
    for raw_line in dotenv_path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip("'").strip('"')
        if key and key not in os.environ:
            os.environ[key] = value


def env_bool(name: str, default: bool) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    return raw.strip().lower() in {"1", "true", "yes", "on"}


def env_int(name: str) -> int | None:
    raw = os.getenv(name)
    if raw is None or not raw.strip():
        return None
    try:
        return int(raw)
    except ValueError:
        return None


def parse_target_document(target: Path, max_sections: int | None) -> list[Section]:
    suffix = target.suffix.lower()
    if suffix in {".qmd", ".md"}:
        sections = split_markdown_sections(target)
    elif suffix == ".docx":
        sections = split_docx_sections(target)
    else:
        raise RuntimeError(
            "Unsupported target format. Use a .qmd, .md, or .docx file."
        )

    if max_sections is not None:
        return sections[:max_sections]
    return sections


def split_markdown_sections(path: Path) -> list[Section]:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    heading_re = re.compile(r"^(#{1,6})\s+(.+?)\s*$")

    sections: list[Section] = []
    current_title = "Document preamble"
    current_start = 1
    current_lines: list[str] = []

    for line_number, line in enumerate(lines, start=1):
        match = heading_re.match(line)
        if match:
            if current_lines:
                sections.extend(
                    chunk_text_section(
                        current_title,
                        f"{path.name}:line {current_start}",
                        "\n".join(current_lines).strip(),
                    )
                )
            current_title = clean_heading_title(match.group(2))
            current_start = line_number
            current_lines = [line]
            continue

        current_lines.append(line)

    if current_lines:
        sections.extend(
            chunk_text_section(
                current_title,
                f"{path.name}:line {current_start}",
                "\n".join(current_lines).strip(),
            )
        )

    return [section for section in sections if section.text.strip()]


def split_docx_sections(path: Path) -> list[Section]:
    try:
        from docx import Document
        from docx.document import Document as DocumentObject
        from docx.oxml.table import CT_Tbl
        from docx.oxml.text.paragraph import CT_P
        from docx.table import Table
        from docx.text.paragraph import Paragraph
    except ImportError as exc:
        raise RuntimeError(
            "python-docx is required to review .docx files. "
            "Install the review dependencies first."
        ) from exc

    document = Document(path)

    def iter_block_items(parent: Any) -> Iterable[Any]:
        if isinstance(parent, DocumentObject):
            parent_elm = parent.element.body
        else:
            parent_elm = parent._tc
        for child in parent_elm.iterchildren():
            if isinstance(child, CT_P):
                yield Paragraph(child, parent)
            elif isinstance(child, CT_Tbl):
                yield Table(child, parent)

    sections: list[Section] = []
    current_title = "Document body"
    current_chunks: list[str] = []
    section_index = 1

    for block in iter_block_items(document):
        if block.__class__.__name__ == "Paragraph":
            text = block.text.strip()
            style_name = (block.style.name or "").strip()
            if style_name.lower().startswith("heading") and text:
                if current_chunks:
                    sections.extend(
                        chunk_text_section(
                            current_title,
                            f"{path.name}:section {section_index}",
                            "\n\n".join(current_chunks).strip(),
                        )
                    )
                    section_index += 1
                current_title = text
                current_chunks = [f"[HEADING] {text}"]
            elif text:
                current_chunks.append(text)
        else:
            table_rows: list[str] = []
            for row in block.rows:
                cells = [normalize_whitespace(cell.text) for cell in row.cells]
                table_rows.append(" | ".join(cells))
            if table_rows:
                current_chunks.append("[TABLE]\n" + "\n".join(table_rows))

    if current_chunks:
        sections.extend(
            chunk_text_section(
                current_title,
                f"{path.name}:section {section_index}",
                "\n\n".join(current_chunks).strip(),
            )
        )

    return [section for section in sections if section.text.strip()]


def clean_heading_title(title: str) -> str:
    title = re.sub(r"\{#.+?\}\s*$", "", title).strip()
    return title or "Untitled section"


def chunk_text_section(title: str, location: str, text: str) -> list[Section]:
    if len(text) <= MAX_SECTION_CHARS:
        return [Section(title=title, location=location, text=text)]

    paragraphs = re.split(r"\n\s*\n", text)
    chunks: list[Section] = []
    current: list[str] = []
    current_len = 0
    part = 1

    for paragraph in paragraphs:
        candidate_len = current_len + len(paragraph) + 2
        if current and candidate_len > MAX_SECTION_CHARS:
            label = f"{location} (part {part})"
            chunks.append(Section(title=title, location=label, text="\n\n".join(current)))
            current = [paragraph]
            current_len = len(paragraph)
            part += 1
            continue

        current.append(paragraph)
        current_len = candidate_len

    if current:
        suffix = f" (part {part})" if part > 1 else ""
        chunks.append(
            Section(title=title, location=f"{location}{suffix}", text="\n\n".join(current))
        )

    return chunks


def discover_supporting_files(
    workspace_root: Path,
    project_root: Path | None,
    target: Path,
    include_supporting: bool,
    extra_paths: Iterable[Path],
) -> list[Path]:
    candidates: list[Path] = []

    if include_supporting and project_root:
        for name in ["_quarto.yml", "refs.bib", "SESSION_HANDOFF.md"]:
            candidate = project_root / name
            if candidate.exists() and candidate != target:
                candidates.append(candidate)

        shared_metadata = workspace_root / "_shared" / "_metadata.yml"
        shared_refs = workspace_root / "_shared" / "refs.bib"
        for candidate in [shared_metadata, shared_refs]:
            if candidate.exists():
                candidates.append(candidate)

        for pattern in [
            "generated/*.tsv",
            "generated/*.csv",
            "generated/*.md",
            "Reviews/*.md",
        ]:
            candidates.extend(
                path for path in project_root.glob(pattern) if path.is_file() and path != target
            )

    for extra in extra_paths:
        if extra != target:
            candidates.append(extra)

    deduped: list[Path] = []
    seen: set[str] = set()
    for candidate in candidates:
        key = str(candidate.resolve()).lower()
        if key in seen or not candidate.exists():
            continue
        seen.add(key)
        deduped.append(candidate.resolve())
    return deduped


def build_support_context(workspace_root: Path, support_files: list[Path]) -> str:
    chunks: list[str] = []
    total_chars = 0
    for path in support_files:
        summary = summarize_support_file(workspace_root, path)
        if not summary:
            continue
        if total_chars + len(summary) > MAX_SUPPORT_CONTEXT_CHARS and chunks:
            break
        chunks.append(summary)
        total_chars += len(summary)
    return "\n\n".join(chunks).strip()


def summarize_support_file(workspace_root: Path, path: Path) -> str:
    suffix = path.suffix.lower()
    header = f"[Support file] {display_path(path, workspace_root)}"

    if suffix == ".bib":
        text = path.read_text(encoding="utf-8", errors="replace")
        keys = re.findall(r"@\w+\{([^,]+),", text)
        preview = "\n".join(f"- {key}" for key in keys[:40])
        return f"{header}\nBibliography keys:\n{preview}".strip()

    if suffix in {".tsv", ".csv"}:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        preview = "\n".join(lines[:20])
        return f"{header}\nPreview:\n{truncate(preview, MAX_SUPPORT_FILE_CHARS)}".strip()

    if suffix in {".md", ".qmd"}:
        text = path.read_text(encoding="utf-8", errors="replace")
        headings = re.findall(r"^#{1,6}\s+(.+)$", text, flags=re.MULTILINE)
        heading_preview = "\n".join(f"- {clean_heading_title(h)}" for h in headings[:12])
        body_preview = truncate(text, MAX_SUPPORT_FILE_CHARS)
        return (
            f"{header}\nHeadings:\n{heading_preview}\n\nContent preview:\n{body_preview}"
        ).strip()

    if suffix in {".yml", ".yaml"}:
        text = path.read_text(encoding="utf-8", errors="replace")
        return f"{header}\nYAML preview:\n{truncate(text, MAX_SUPPORT_FILE_CHARS)}".strip()

    if suffix == ".docx":
        return f"{header}\nBinary Word document present. Review the target text for claim alignment."

    text = path.read_text(encoding="utf-8", errors="replace")
    return f"{header}\nPreview:\n{truncate(text, MAX_SUPPORT_FILE_CHARS)}".strip()


def run_review(
    workspace_root: Path,
    project_root: Path | None,
    target: Path,
    sections: list[Section],
    support_context: str,
    supporting_files: list[Path],
    missing_support: list[str],
    model: str,
    reasoning_effort: str,
) -> dict[str, Any]:
    try:
        from openai import OpenAI
    except ImportError as exc:
        raise RuntimeError(
            "The openai package is not installed in the workspace venv. "
            "Install the review dependencies first."
        ) from exc

    if not os.getenv("OPENAI_API_KEY"):
        raise RuntimeError(
            "OPENAI_API_KEY is not set. Export it or place it in D:\\Quarto\\.env before "
            "running the deep review."
        )

    _, ReviewReport = build_schema_models()
    client = OpenAI()

    project_label = project_root.name if project_root else "ad-hoc"
    document_outline = build_document_outline(workspace_root, target, sections)
    section_digests = build_section_digests(sections)

    bootstrap_prompt = textwrap.dedent(
        f"""
        Prepare context for a deep engineering review.

        Workspace project: {project_label}
        Target document: {display_path(target, workspace_root)}

        Document outline:
        {document_outline}

        Supporting context:
        {support_context or "No supporting files were discovered."}

        Acknowledge the highest-risk review axes in 5 bullets or fewer. Do not produce the final review.
        """
    ).strip()

    bootstrap_response = client.responses.create(
        model=model,
        instructions=REVIEW_INSTRUCTIONS,
        input=bootstrap_prompt,
        store=True,
        reasoning={"effort": reasoning_effort},
    )

    section_reports: list[dict[str, Any]] = []
    for section in sections:
        section_prompt = textwrap.dedent(
            f"""
            Review this section of the target document.

            Target: {display_path(target, workspace_root)}
            Section title: {section.title}
            Section location: {section.location}

            Return only supported findings for this section.

            Section text:
            {section.text}

            Supporting context:
            {support_context or "No supporting files were discovered."}
            """
        ).strip()

        response = client.responses.parse(
            model=model,
            instructions=REVIEW_INSTRUCTIONS,
            input=section_prompt,
            text_format=ReviewReport,
            previous_response_id=bootstrap_response.id,
            store=True,
            reasoning={"effort": reasoning_effort},
        )
        parsed = extract_parsed_response(response)
        section_reports.append(parsed)

    aggregate_findings = []
    aggregate_residual_risks: list[str] = []
    for report in section_reports:
        aggregate_findings.extend(report.get("findings", []))
        aggregate_residual_risks.extend(report.get("residual_risks", []))

    synthesis_prompt = textwrap.dedent(
        f"""
        Deduplicate and synthesize the final engineering review for this document.

        Target: {display_path(target, workspace_root)}
        Project: {project_label}

        Document outline:
        {document_outline}

        Section digests:
        {section_digests}

        Candidate findings from per-section review:
        {json.dumps(aggregate_findings, indent=2)}

        Candidate residual risks:
        {json.dumps(sorted(set(aggregate_residual_risks)), indent=2)}

        Supporting context:
        {support_context or "No supporting files were discovered."}

        Produce the final review. Remove duplicates, preserve the strongest evidence,
        and add cross-section contradiction findings when the digests support them.
        """
    ).strip()

    synthesis_response = client.responses.parse(
        model=model,
        instructions=REVIEW_INSTRUCTIONS,
        input=synthesis_prompt,
        text_format=ReviewReport,
        previous_response_id=bootstrap_response.id,
        store=True,
        reasoning={"effort": reasoning_effort},
    )
    final_report = extract_parsed_response(synthesis_response)

    all_sources = [display_path(target, workspace_root)] + [
        display_path(path, workspace_root) for path in supporting_files
    ]
    final_report["findings"] = sort_findings(final_report.get("findings", []))
    final_report["sources_checked"] = sorted(set(all_sources))
    final_report["residual_risks"] = sorted(
        set(final_report.get("residual_risks", [])) | set(missing_support)
    )
    final_report["target"] = display_path(target, workspace_root)
    return final_report


def build_schema_models() -> tuple[Any, Any]:
    try:
        from pydantic import BaseModel, Field
    except ImportError as exc:
        raise RuntimeError(
            "The pydantic package is not installed in the workspace venv. "
            "Install the review dependencies first."
        ) from exc

    class Finding(BaseModel):
        severity: str = Field(description="One of blocker, major, minor.")
        category: str = Field(description="One of the allowed review categories.")
        location: str = Field(description="Section, line, or document location.")
        issue: str = Field(description="Short statement of the problem.")
        why_it_matters: str = Field(description="Why the problem matters technically.")
        suggested_fix: str = Field(description="Concrete corrective action.")
        evidence: str = Field(description="Quoted or paraphrased supporting evidence.")

    class ReviewReport(BaseModel):
        summary: str = Field(description="2-4 sentence synthesis of the review state.")
        findings: list[Finding] = Field(default_factory=list)
        residual_risks: list[str] = Field(default_factory=list)
        sources_checked: list[str] = Field(default_factory=list)

    return Finding, ReviewReport


def extract_parsed_response(response: Any) -> dict[str, Any]:
    refusals: list[str] = []
    parsed_objects: list[Any] = []

    for output in getattr(response, "output", []):
        if getattr(output, "type", None) != "message":
            continue
        for item in getattr(output, "content", []):
            item_type = getattr(item, "type", None)
            if item_type == "refusal":
                refusals.append(getattr(item, "refusal", ""))
                continue

            parsed = getattr(item, "parsed", None)
            if parsed is not None:
                parsed_objects.append(parsed)

    if refusals and not parsed_objects:
        raise RuntimeError(f"Model refusal: {' | '.join(refusals)}")
    if not parsed_objects:
        raise RuntimeError("Could not parse the model response into the review schema.")

    parsed = parsed_objects[0]
    if hasattr(parsed, "model_dump"):
        return parsed.model_dump()
    if isinstance(parsed, dict):
        return parsed
    raise RuntimeError("Parsed response had an unexpected type.")


def build_document_outline(workspace_root: Path, target: Path, sections: list[Section]) -> str:
    lines = [f"Target: {display_path(target, workspace_root)}"]
    for index, section in enumerate(sections, start=1):
        lines.append(f"{index}. {section.title} [{section.location}]")
    return "\n".join(lines)


def build_section_digests(sections: list[Section]) -> str:
    digests: list[str] = []
    for section in sections:
        digests.append(
            textwrap.dedent(
                f"""
                [Section]
                Title: {section.title}
                Location: {section.location}
                Digest:
                {truncate(section.text, MAX_SECTION_DIGEST_CHARS)}
                """
            ).strip()
        )
    return "\n\n".join(digests)


def sort_findings(findings: list[dict[str, Any]]) -> list[dict[str, Any]]:
    def sort_key(item: dict[str, Any]) -> tuple[int, str, str]:
        severity = str(item.get("severity", "minor")).lower()
        category = str(item.get("category", ""))
        location = str(item.get("location", ""))
        return (SEVERITY_ORDER.get(severity, 99), category, location)

    filtered = []
    for finding in findings:
        severity = str(finding.get("severity", "")).strip().lower()
        category = str(finding.get("category", "")).strip()
        if severity not in SEVERITY_ORDER:
            finding["severity"] = "minor"
        if category and category not in VALID_CATEGORIES:
            finding["category"] = "logical-flow"
        filtered.append(finding)
    return sorted(filtered, key=sort_key)


def write_outputs(
    workspace_root: Path,
    project_root: Path | None,
    project_name: str,
    target: Path,
    report: dict[str, Any],
    json_only: bool,
) -> tuple[Path, Path | None]:
    stem = target.stem

    if project_root:
        review_dir = project_root / "Reviews"
        state_dir = workspace_root / "_state" / project_name / "reviews"
    else:
        review_dir = target.parent / "Reviews"
        state_dir = workspace_root / "_state" / "ad-hoc" / "reviews"

    review_dir.mkdir(parents=True, exist_ok=True)
    state_dir.mkdir(parents=True, exist_ok=True)

    json_path = state_dir / f"{stem}-reasoned.json"
    json_path.write_text(json.dumps(report, indent=2), encoding="utf-8")

    markdown_path: Path | None = None
    if not json_only:
        markdown_path = review_dir / f"Review-{stem}-reasoned.md"
        markdown_path.write_text(render_markdown_report(report), encoding="utf-8")

    return json_path, markdown_path


def render_markdown_report(report: dict[str, Any]) -> str:
    lines = [
        f"# Review: {Path(report.get('target', 'document')).name}",
        "",
        f"Target: `{report.get('target', '')}`",
        "",
        "## Summary",
        "",
        report.get("summary", "").strip() or "No summary returned.",
        "",
        "## Findings",
        "",
    ]

    findings = report.get("findings", [])
    if findings:
        for finding in findings:
            lines.extend(
                [
                    f"### [{str(finding.get('severity', '')).upper()}] {finding.get('issue', '').strip()}",
                    "",
                    f"- Category: `{finding.get('category', '').strip()}`",
                    f"- Location: `{finding.get('location', '').strip()}`",
                    f"- Why it matters: {finding.get('why_it_matters', '').strip()}",
                    f"- Suggested fix: {finding.get('suggested_fix', '').strip()}",
                    f"- Evidence: {finding.get('evidence', '').strip()}",
                    "",
                ]
            )
    else:
        lines.extend(["No findings.", ""])

    lines.extend(["## Residual Risks", ""])
    residual_risks = report.get("residual_risks", [])
    if residual_risks:
        for risk in residual_risks:
            lines.append(f"- {risk}")
    else:
        lines.append("- None recorded.")

    lines.extend(["", "## Sources Checked", ""])
    sources_checked = report.get("sources_checked", [])
    if sources_checked:
        for source in sources_checked:
            lines.append(f"- `{source}`")
    else:
        lines.append("- No sources recorded.")

    lines.append("")
    return "\n".join(lines)


def display_path(path: Path, workspace_root: Path) -> str:
    try:
        return str(path.relative_to(workspace_root))
    except ValueError:
        return str(path)


def normalize_whitespace(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def truncate(text: str, max_chars: int) -> str:
    clean = text.strip()
    if len(clean) <= max_chars:
        return clean
    return clean[: max_chars - 3].rstrip() + "..."


if __name__ == "__main__":
    raise SystemExit(main())

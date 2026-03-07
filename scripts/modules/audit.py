"""
Publish audit phase: coverage, analyzer, docs, recursion, try/catch, quality checks.

Writes a single report to reports/yyyymmdd/yyyymmdd_HHMMSS_publish_audit.txt
and returns a dict of findings (category -> count) for the caller to display.
"""

from __future__ import annotations

import re
from collections import defaultdict
from datetime import datetime
from pathlib import Path

from . import duplicate_classes
from . import platform as platform_mod
from . import run as run_mod
from . import ui
from .colors import Color


# ANSI for report file (so opening in terminal shows colors)
def _red(s: str) -> str:
    return f"{Color.RED.value}{s}{Color.RESET.value}"


def _green(s: str) -> str:
    return f"{Color.GREEN.value}{s}{Color.RESET.value}"


def _yellow(s: str) -> str:
    return f"{Color.YELLOW.value}{s}{Color.RESET.value}"


def _cyan(s: str) -> str:
    return f"{Color.CYAN.value}{s}{Color.RESET.value}"


def _section(lines: list[str], title: str) -> list[str]:
    out = [
        "",
        "=" * 70,
        f"  {title}",
        "=" * 70,
        "",
    ]
    out.extend(lines)
    return out


# -----------------------------------------------------------------------------
# 1. Code coverage / unit test count per method
# -----------------------------------------------------------------------------

def _find_public_members(lib_path: Path) -> list[str]:
    """Extract public member names (methods, getters) from a Dart lib file."""
    text = lib_path.read_text(encoding="utf-8")
    members = []
    # Match: optional return type + name + ( or get. Skip private (leading _).
    # Lines like:   String toSlug() {   or   int get length =>   or   void foo(
    _skip = (
        "get", "set", "if", "for", "while", "switch", "return", "final", "true",
        "false", "null", "bool", "int", "void", "Function", "async", "await",
        "throw", "try", "catch", "else", "with", "class", "extension", "import",
        "part", "typedef", "enum", "abstract", "extends", "implements", "on",
        "fn", "dynamic", "var", "const", "static", "external", "operator",
    )
    for m in re.finditer(
        r"^\s*(?:[\w<>,\s?]+\s+)?([a-zA-Z]\w*)\s*(?:\([^)]*\)|get\s)\s*(?:=>|async|{)?",
        text,
        re.MULTILINE,
    ):
        name = m.group(1)
        if name in _skip:
            continue
        members.append(name)
    return members


def _lib_to_test_path(lib_path: Path, lib_root: Path, test_root: Path) -> Path | None:
    """Map lib/foo/bar.dart -> test/foo/bar_test.dart."""
    try:
        rel = lib_path.relative_to(lib_root)
    except ValueError:
        return None
    # e.g. string/string_slug_extensions.dart -> string/string_slug_extensions_test.dart
    stem = rel.stem
    if stem.endswith("_extensions") or stem.endswith("_utils"):
        test_name = f"{stem}_test.dart"
    else:
        test_name = f"{rel.stem}_test.dart"
    test_path = test_root / rel.parent / test_name
    return test_path if test_path.exists() else None


def _count_tests_per_member(
    test_path: Path, members: list[str]
) -> dict[str, int]:
    """Count how many test() blocks reference each member. Heuristic: member name in block."""
    text = test_path.read_text(encoding="utf-8")
    # Split by test(' or test(" or group(' or group(" to get blocks
    blocks = re.split(r"\b(?:test|group)\s*\(\s*['\"]", text)
    count: dict[str, int] = defaultdict(int)
    for block in blocks[1:]:  # first part is before first test/group
        for member in members:
            if member in block:
                count[member] += 1
                break  # count at most one per block per member
    return dict(count)


def audit_coverage(project_dir: Path, lib_root: Path, test_root: Path) -> tuple[list[str], dict[str, int]]:
    """
    Build histogram: how many methods have 0, 1, 2, 3, ... unit tests.
    Returns (report_lines, test_count_by_method).
    """
    lines: list[str] = []
    test_count_by_method: dict[str, int] = {}

    lib_dart = list(lib_root.rglob("*.dart"))
    for lib_path in lib_dart:
        members = _find_public_members(lib_path)
        test_path = _lib_to_test_path(lib_path, lib_root, test_root)
        if not test_path:
            for m in members:
                test_count_by_method[f"{lib_path.relative_to(project_dir)}::{m}"] = 0
            continue
        counts = _count_tests_per_member(test_path, members)
        for m in members:
            key = f"{lib_path.relative_to(project_dir)}::{m}"
            test_count_by_method[key] = counts.get(m, 0)

    # Histogram: 0 -> n0, 1 -> n1, ...
    hist: dict[int, int] = defaultdict(int)
    for c in test_count_by_method.values():
        hist[c] += 1

    max_tests = max(hist.keys()) if hist else 0
    max_count = max(hist.values()) if hist else 0
    width = 40
    lines.append("Methods by number of unit test blocks that reference them (heuristic):")
    lines.append("")
    # Use # for bar so report file is ASCII-safe on Windows
    for k in range(0, min(max_tests + 1, 15)):
        n = hist.get(k, 0)
        bar_len = int((n / max_count) * width) if max_count else 0
        bar = "#" * bar_len
        if k == 0:
            color_bar = _red(bar)
        elif k <= 2:
            color_bar = _yellow(bar)
        else:
            color_bar = _green(bar)
        lines.append(f"  {k:2} tests: {n:4} methods  {color_bar}")
    if max_tests >= 15:
        n_rest = sum(hist.get(k, 0) for k in range(15, max_tests + 1))
        lines.append(f"  15+:        {n_rest:4} methods  (grouped)")
    lines.append("")
    lines.append("Legend: red = 0 tests, yellow = 1-2, green = 3+")
    return lines, test_count_by_method


# -----------------------------------------------------------------------------
# 2. Analyzer: error, warning, info counts
# -----------------------------------------------------------------------------

def audit_analyzer(project_dir: Path) -> tuple[list[str], int, int, int]:
    """Run dart analyze --format machine and count ERROR, WARNING, INFO."""
    result = run_mod.run_capture(
        ["dart", "analyze", "--format", "machine"], project_dir
    )
    err, warn, info = 0, 0, 0
    report_lines: list[str] = []
    for line in (result.stdout or "").splitlines():
        if not line.strip():
            continue
        parts = line.split("|")
        if len(parts) >= 1:
            sev = parts[0].strip()
            if sev == "ERROR":
                err += 1
            elif sev == "WARNING":
                warn += 1
            elif sev == "INFO":
                info += 1
    report_lines.append(f"  Errors:   {err}")
    report_lines.append(f"  Warnings: {warn}")
    report_lines.append(f"  Info:     {info}")
    report_lines.append("")
    return report_lines, err, warn, info


# -----------------------------------------------------------------------------
# 3. Multiline doc header per method
# -----------------------------------------------------------------------------

def _method_ranges(content: str) -> list[tuple[int, int, str]]:
    """Return list of (decl_line_1based, end_line_1based, member_name) for members."""
    ranges: list[tuple[int, int, str]] = []
    lines = content.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        m = re.match(
            r"^\s*(?:[\w<>,\s?]+\s+)?([a-zA-Z]\w*)\s*(?:\([^)]*\)|get\s)\s*(?:=>|async|{)?",
            line,
        )
        _skip = (
            "get", "set", "if", "for", "while", "switch", "return", "final", "true",
            "false", "null", "bool", "int", "void", "Function", "async", "await",
            "throw", "try", "catch", "else", "with", "class", "extension", "import",
            "part", "typedef", "enum", "abstract", "extends", "implements", "on",
            "fn", "dynamic", "var", "const", "static", "external", "operator",
        )
        if m and m.group(1) not in _skip:
            name = m.group(1)
            decl_line_1based = i + 1
            depth = 0
            for j in range(i, len(lines)):
                for c in lines[j]:
                    if c == "{":
                        depth += 1
                    elif c == "}":
                        depth -= 1
                if depth < 0:
                    break
                if depth == 0 and j > i:
                    ranges.append((decl_line_1based, j + 1, name))
                    break
            else:
                if depth != 0:
                    ranges.append((decl_line_1based, len(lines), name))
        i += 1
    return ranges


def audit_doc_headers(lib_root: Path) -> tuple[list[str], list[str]]:
    """Check each method has a multiline doc header (at least 2 /// lines or 1 block)."""
    missing: list[str] = []

    for lib_path in lib_root.rglob("*.dart"):
        content = lib_path.read_text(encoding="utf-8")
        lines_arr = content.splitlines()
        for start_line, end_line, name in _method_ranges(content):
            doc_lines = []
            i = start_line - 2
            while i >= 0 and i < len(lines_arr):
                l = lines_arr[i].strip()
                if l.startswith("///"):
                    doc_lines.append(l)
                    i -= 1
                elif l == "" or l.startswith("//"):
                    i -= 1
                else:
                    break
            if len(doc_lines) < 2:
                missing.append(f"  {lib_path.name}:{start_line}  {name}")

    report_lines: list[str] = []
    if missing:
        report_lines.append("Methods with missing or single-line doc header:")
        report_lines.extend(missing[:50])
        if len(missing) > 50:
            report_lines.append(f"  ... and {len(missing) - 50} more")
    else:
        report_lines.append("All checked methods have multiline doc headers.")
    return report_lines, missing


# -----------------------------------------------------------------------------
# 4. Recursion and bad code practices
# -----------------------------------------------------------------------------

def audit_recursion_and_bad(lib_root: Path) -> tuple[list[str], list[str]]:
    """Check for recursion and simple bad practices (empty catch, etc.)."""
    report_lines: list[str] = []
    issues: list[str] = []

    for lib_path in lib_root.rglob("*.dart"):
        content = lib_path.read_text(encoding="utf-8")
        for start_line, end_line, name in _method_ranges(content):
            # Extract body (simplified: lines between start and end)
            lines_arr = content.splitlines()
            body_lines = lines_arr[start_line - 1 : end_line]
            body = "\n".join(body_lines)
            # Recursion: same name followed by ( or space
            if re.search(rf"\b{re.escape(name)}\s*\(", body):
                issues.append(f"  {lib_path.name}:{start_line}  possible recursion: {name}()")
            # Empty catch: catch (_) { } or catch (e) { }
            if re.search(r"catch\s*\([^)]+\)\s*\{\s*\}", body):
                issues.append(f"  {lib_path.name}:{start_line}  empty catch block: {name}")
            # Bare catch without type
            if re.search(r"catch\s*\([^)]*\)\s*\{", body) and " on " not in body:
                # Could be catch (e) or catch (_)
                pass  # already reported if empty; otherwise just note in "other"
    if issues:
        report_lines.append("Potential recursion or bad practices:")
        report_lines.extend(issues[:30])
        if len(issues) > 30:
            report_lines.append(f"  ... and {len(issues) - 30} more")
    else:
        report_lines.append("No obvious recursion or empty-catch issues found.")
    return report_lines, issues


# -----------------------------------------------------------------------------
# 5. Try/catch usage per method
# -----------------------------------------------------------------------------

def audit_try_catch(lib_root: Path) -> tuple[list[str], list[str]]:
    """Report which methods contain try/catch."""
    report_lines: list[str] = []
    with_try: list[str] = []

    for lib_path in lib_root.rglob("*.dart"):
        content = lib_path.read_text(encoding="utf-8")
        for start_line, end_line, name in _method_ranges(content):
            lines_arr = content.splitlines()
            body = "\n".join(lines_arr[start_line - 1 : end_line])
            if "try" in body and "catch" in body:
                with_try.append(f"  {lib_path.name}:{start_line}  {name}")
    report_lines.append(f"Methods containing try/catch: {len(with_try)}")
    report_lines.extend(with_try[:40])
    if len(with_try) > 40:
        report_lines.append(f"  ... and {len(with_try) - 40} more")
    return report_lines, with_try


# -----------------------------------------------------------------------------
# 6. Other quality checks
# -----------------------------------------------------------------------------

def audit_other_quality(project_dir: Path, lib_root: Path) -> list[str]:
    """Additional quality checks: file length, params, TODO, deprecated, long lines, etc."""
    lines: list[str] = []

    # File length > 200 lines
    long_files: list[tuple[str, int]] = []
    for p in lib_root.rglob("*.dart"):
        n = len(p.read_text(encoding="utf-8").splitlines())
        if n > 200:
            long_files.append((str(p.relative_to(project_dir)), n))
    if long_files:
        lines.append("Files over 200 lines (project standard):")
        for path, n in sorted(long_files, key=lambda x: -x[1])[:20]:
            lines.append(f"  {path}: {n} lines")
    else:
        lines.append("No files over 200 lines.")

    # TODO / FIXME / HACK / XXX
    todo_count = 0
    for p in lib_root.rglob("*.dart"):
        text = p.read_text(encoding="utf-8")
        for tag in ("TODO", "FIXME", "HACK", "XXX"):
            todo_count += len(re.findall(rf"\b{tag}\b", text, re.IGNORECASE))
    lines.append("")
    lines.append(f"TODO/FIXME/HACK/XXX in lib: {todo_count}")

    # @deprecated
    dep_count = 0
    for p in lib_root.rglob("*.dart"):
        dep_count += len(re.findall(r"@deprecated", p.read_text(encoding="utf-8")))
    lines.append(f"@deprecated usages: {dep_count}")

    # Long lines > 120
    long_line_count = 0
    for p in lib_root.rglob("*.dart"):
        for i, line in enumerate(p.read_text(encoding="utf-8").splitlines(), 1):
            if len(line) > 120:
                long_line_count += 1
    lines.append(f"Lines over 120 characters: {long_line_count}")

    # Parameter count > 3
    many_params: list[str] = []
    for p in lib_root.rglob("*.dart"):
        content = p.read_text(encoding="utf-8")
        for m in re.finditer(
            r"^\s*(?:[\w<>,\s?]+\s+)?(\w+)\s*\(([^)]*)\)",
            content,
            re.MULTILINE,
        ):
            params = m.group(2)
            if params.strip():
                n = len([x for x in params.split(",") if x.strip()])
                if n > 3:
                    many_params.append(f"  {p.name}: {m.group(1)}() has {n} params")
    lines.append("")
    lines.append(f"Methods with >3 parameters: {len(many_params)}")
    lines.extend(many_params[:15])

    # Exports: check main lib exports all lib/*.dart (optional check)
    main_lib = project_dir / "lib" / "saropa_dart_utils.dart"
    if main_lib.exists():
        export_content = main_lib.read_text(encoding="utf-8")
        exported = set(re.findall(r"export\s+['\"]([^'\"]+)['\"]", export_content))
        all_lib = set()
        for f in (project_dir / "lib").rglob("*.dart"):
            if f.name == "saropa_dart_utils.dart":
                continue
            rel = str(f.relative_to(project_dir / "lib")).replace("\\", "/")
            all_lib.add(rel)
        not_exported = all_lib - exported
        if not_exported:
            lines.append("")
            lines.append("Lib files not exported from saropa_dart_utils.dart:")
            for x in sorted(not_exported)[:20]:
                lines.append(f"  {x}")
            if len(not_exported) > 20:
                lines.append(f"  ... and {len(not_exported) - 20} more")

    return lines


# -----------------------------------------------------------------------------
# Run full audit and write report
# -----------------------------------------------------------------------------

def run_audit(project_dir: Path) -> tuple[dict[str, int], Path]:
    """
    Run all audit checks and write report to reports/yyyymmdd/yyyymmdd_HHMMSS_publish_audit.txt.
    Returns (findings_dict, report_path) where findings_dict maps category names to counts.
    Empty dict means no issues found.
    """
    ui.print_header("AUDIT PHASE: QUALITY CHECKS")

    lib_root = project_dir / "lib"
    test_root = project_dir / "test"
    report_dir = project_dir / "reports" / datetime.now().strftime("%Y%m%d")
    report_dir.mkdir(parents=True, exist_ok=True)
    report_name = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_publish_audit.txt"
    report_path = report_dir / report_name

    all_lines: list[str] = []

    # 1. Coverage / test count
    ui.print_info("Audit 1/8: Code coverage (test count per method)...")
    cov_lines, _ = audit_coverage(project_dir, lib_root, test_root)
    all_lines.extend(_section(cov_lines, "1. UNIT TEST COVERAGE (methods by test count)"))

    # 2. Analyzer
    ui.print_info("Audit 2/8: Dart analyzer...")
    ana_lines, ana_err, ana_warn, ana_info = audit_analyzer(project_dir)
    all_lines.extend(_section(ana_lines, "2. ANALYZER (error / warning / info)"))
    all_lines.append(f"  Total: {ana_err} errors, {ana_warn} warnings, {ana_info} info")
    all_lines.append("")

    # 3. Doc headers
    ui.print_info("Audit 3/8: Multiline doc headers...")
    doc_lines, missing_docs = audit_doc_headers(lib_root)
    all_lines.extend(_section(doc_lines, "3. MULTILINE DOC HEADERS"))
    all_lines.append("")

    # 4. Recursion / bad practices
    ui.print_info("Audit 4/8: Recursion and bad practices...")
    rec_lines, rec_issues = audit_recursion_and_bad(lib_root)
    all_lines.extend(_section(rec_lines, "4. RECURSION & BAD PRACTICES"))

    # 5. Try/catch
    ui.print_info("Audit 5/8: Try/catch usage...")
    try_lines, _ = audit_try_catch(lib_root)
    all_lines.extend(_section(try_lines, "5. TRY/CATCH ERROR HANDLING (per method)"))

    # 6. Duplicate Dart class names
    ui.print_info("Audit 6/8: Duplicate Dart class names...")
    dup_lines, dup_map = duplicate_classes.audit_duplicate_classes(project_dir)
    all_lines.extend(_section(dup_lines, "6. DUPLICATE DART CLASS NAMES"))

    # 7. Other quality
    ui.print_info("Audit 7/8: Other quality checks...")
    other_lines = audit_other_quality(project_dir, lib_root)
    all_lines.extend(_section(other_lines, "7. OTHER QUALITY CHECKS"))

    # 8. Summary and recommendations
    ui.print_info("Audit 8/8: Summary...")
    summary = [
        "Recommendations:",
        "  - Fix all analyzer errors before publishing.",
        "  - Consider fixing analyzer warnings and adding docs for methods with 0-1 tests.",
        "  - Review methods with try/catch for proper error handling.",
        "  - Address recursion/empty-catch and file length if policy requires.",
    ]
    all_lines.extend(_section(summary, "8. SUMMARY & RECOMMENDATIONS"))

    report_path.write_text("\n".join(all_lines), encoding="utf-8")
    ui.print_success(f"Audit report written to {report_path}")

    # Build per-category summary for the caller
    findings: dict[str, int] = {}
    if ana_err:
        findings["Analyzer errors"] = ana_err
    if ana_warn:
        findings["Analyzer warnings"] = ana_warn
    if ana_info:
        findings["Analyzer infos"] = ana_info
    if missing_docs:
        findings["Missing doc headers"] = len(missing_docs)
    if rec_issues:
        findings["Recursion / bad practices"] = len(rec_issues)
    if dup_map:
        findings["Duplicate class names"] = len(dup_map)

    return findings, report_path

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


# Reserved Dart keywords / built-ins that can appear in the "name" capture position
# when the regex backtracks. Skipping these prevents control-flow keywords from being
# treated as method names.
_DART_KEYWORD_SKIP = frozenset(
    [
        "get", "set", "if", "for", "while", "switch", "return", "final", "true",
        "false", "null", "bool", "int", "void", "Function", "async", "await",
        "throw", "try", "catch", "else", "with", "class", "extension", "import",
        "part", "typedef", "enum", "abstract", "extends", "implements", "on",
        "fn", "dynamic", "var", "const", "static", "external", "operator",
        "assert", "factory", "late", "covariant", "required", "this", "super",
        "new", "rethrow", "yield", "is", "as", "in", "do", "break", "continue",
        "case", "default", "deferred", "hide", "show", "library", "mixin",
        "of", "sync", "Never", "Object", "Type", "Symbol",
    ]
)


# Dart declaration parser.
#
# WHY a hand parser instead of one mega-regex: a regex cannot balance Dart's
# nested `<>` generics or `()` function-type params. The previous regex both
# MISSED real generic functions (e.g. `Future<T> raceFirst<T>(... Function() ...)`
# never matched, so it was invisible to every check) AND mis-captured type names
# from generic bounds and constructor calls (`nWayMerge<T extends Comparable<..>>(`
# reported its name as `Comparable`; `= Completer<T>()` reported `Completer`;
# `copy.sort(x)` reported `copy`). This parser finds the real declaration name —
# the identifier immediately before the parameter `(` (after an optional
# balanced `<...>` generic clause) — and rejects names preceded by an
# expression/call character, which is what distinguishes a declaration from a
# call site or a variable initializer.

# Getter: optional modifiers, a return type, then `get name` and a body opener.
_GETTER_DECL_RE = re.compile(
    r"^(?:(?:static|external|abstract|final|late|covariant)\s+)*"
    r"(?:[\w<>?,.]+\s+)+get\s+([a-zA-Z_]\w*)\s*(?:=>|\{)"
)
# Strips a leading annotation (`@override`, `@Deprecated('x')`) from a line.
_LEADING_ANNOTATION_RE = re.compile(r"^@\w+(?:\s*\([^)]*\))?\s*")
# If the character immediately before a candidate name is one of these, the name
# is part of an expression (a call `x.f(`, an init `= F(`, an argument `(F(`),
# NOT a declaration. `>` and `?` are intentionally absent — they legitimately
# close a return type, as in `List<T> name(` and `T? name(`.
_NONDECL_PRECEDING = frozenset(".=,(+-*/%&|!:;[{")


def _name_before(s: str, paren_idx: int) -> tuple[str, int] | None:
    """Given the index of a parameter-list `(`, return the declaration name that
    precedes it (skipping a balanced `<...>` generic clause and whitespace) and
    the index just before that name, or None if no plain identifier is there.
    """
    j = paren_idx - 1
    while j >= 0 and s[j] == " ":
        j -= 1
    # Skip a balanced generic clause attached to the name, e.g. `foo<T>(`.
    if j >= 0 and s[j] == ">":
        depth = 0
        while j >= 0:
            if s[j] == ">":
                depth += 1
            elif s[j] == "<":
                depth -= 1
                if depth == 0:
                    j -= 1
                    break
            j -= 1
        while j >= 0 and s[j] == " ":
            j -= 1
    end = j + 1
    while j >= 0 and (s[j].isalnum() or s[j] == "_"):
        j -= 1
    name = s[j + 1 : end]
    if not name or not (name[0].isalpha() or name[0] == "_"):
        return None
    return name, j


def _strip_line_comment(s: str) -> str:
    """Drop a trailing `//` comment. Naive (ignores `//` inside string literals),
    which is acceptable for declaration lines — they rarely embed such strings."""
    idx = s.find("//")
    return s[:idx] if idx >= 0 else s


# Matches a single- or double-quoted string literal (with escapes). Replaced with
# an empty placeholder so parens/identifiers INSIDE a string (e.g. the literal
# `'TrieUtils()'`) are not mistaken for a declaration.
_STRING_LITERAL_RE = re.compile(r"'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\"")


def _strip_strings(s: str) -> str:
    return _STRING_LITERAL_RE.sub("''", s)


def _count_top_level_params(params: str) -> int:
    """Count comma-separated params at nesting depth 0 (so `Function()` and
    `Map<K, V>` inside a single param are not miscounted as extra params)."""
    if not params.strip():
        return 0
    depth = 0
    count = 1
    for ch in params:
        if ch in "(<[{":
            depth += 1
        elif ch in ")>]}":
            depth -= 1
        elif ch == "," and depth == 0:
            count += 1
    return count


def _parse_decl(line: str) -> tuple[str, int | None] | None:
    """Parse one line as a Dart method/function/getter/constructor declaration.

    Returns `(name, param_count)` — `param_count` is `None` for getters — or
    `None` if the line is not a declaration. Declarations sit at indent ≤ 3
    (members/top-level); body statements at ≥ 4 are skipped.
    """
    if len(line) - len(line.lstrip(" ")) > 3:
        return None
    s = _strip_strings(_strip_line_comment(line)).strip()
    if not s or s[0] in "*/":
        return None
    # Drop a leading inline annotation so `@override int x(...)` is seen.
    s = _LEADING_ANNOTATION_RE.sub("", s)
    if not s:
        return None

    mg = _GETTER_DECL_RE.match(s)
    if mg:
        return (mg.group(1), None)

    # The declaration name is the identifier immediately before the parameter
    # list `(`. Try each `(` left to right: the first whose preceding identifier
    # is a real declaration name (not a call/init/argument) is the declaration.
    for idx, ch in enumerate(s):
        if ch != "(":
            continue
        found = _name_before(s, idx)
        if not found:
            continue
        name, before_idx = found
        if name in _DART_KEYWORD_SKIP:
            continue
        # Reject expression/call contexts by the character preceding the name
        # (`x.f(` -> `.`, `= F(` -> `=`, `(F(` -> `(`).
        k = before_idx
        while k >= 0 and s[k] == " ":
            k -= 1
        if k >= 0 and s[k] in _NONDECL_PRECEDING:
            continue
        # Balanced scan of the parameter list to extract its top-level contents.
        depth = 0
        chars: list[str] = []
        close_idx = -1
        for offset, c in enumerate(s[idx:]):
            if c == "(":
                depth += 1
                if depth == 1:
                    continue
            elif c == ")":
                depth -= 1
                if depth == 0:
                    close_idx = idx + offset
                    break
            chars.append(c)
        # When the param list closes on this line, the text after `)` must be a
        # declaration tail (`{`, `=>`, `;`, an `async`/`sync` marker, or a `:`
        # constructor init list). A trailing `,` or `)` means this was a call
        # used as a list element / argument (e.g. `Rule(re, repl),`), not a
        # declaration. A signature that does NOT close here is multi-line — accept
        # it so the (already-captured) name is still seen.
        if close_idx >= 0:
            tail = s[close_idx + 1 :].strip()
            if not _is_decl_tail(tail):
                continue
        return (name, _count_top_level_params("".join(chars)))
    return None


def _is_decl_tail(tail: str) -> bool:
    """Whether the text after a declaration's `)` marks a real declaration."""
    if tail == "" or tail == ";":
        return True
    return (
        tail[0] in "{:"
        or tail.startswith("=>")
        or tail.startswith("async")
        or tail.startswith("sync")
    )


def _iter_decls(text: str):
    """Yield `(name, param_count, line_1based)` for each declaration in `text`."""
    for i, line in enumerate(text.splitlines(), 1):
        parsed = _parse_decl(line)
        if parsed is not None:
            yield parsed[0], parsed[1], i


# Matches an enclosing type declaration so we can tell whether a member lives in
# a PRIVATE type (e.g. `class _Node`), whose members are not public API.
_TYPE_DECL_RE = re.compile(
    r"^\s*(?:abstract\s+|final\s+|sealed\s+|base\s+|interface\s+|mixin\s+)*"
    r"(?:class|mixin|enum|extension(?:\s+type)?)\s+(\w+)"
)
# A private named constructor, e.g. `LevenshteinUtils._();` — the name capture is
# the (public) class name, but the `._` makes the constructor itself private.
_PRIVATE_CTOR_RE = re.compile(r"\.\_\w*\s*\(")

# A `final` instance field declaration inside a class body, e.g. `final int
# lineNumber;` or `final List<CsvRowError> errors;`. The non-greedy type segment
# lets the trailing `\s(\w+);` capture the field name. Used to credit a value
# class's field reads toward its constructor's test coverage.
_FIELD_DECL_RE = re.compile(r"^\s*final\s+[\w<>,?.\s]+?\s(\w+)\s*;")


def _enclosing_type_name(lines_arr: list[str], line_1based: int) -> str | None:
    """Return the name of the type that lexically encloses the declaration at
    `line_1based`, or None if it is top-level. Used to recognize constructors
    (whose name equals the enclosing type)."""
    i = line_1based - 2
    while i >= 0:
        line = lines_arr[i]
        if line.startswith("}"):
            return None
        m = _TYPE_DECL_RE.match(line)
        if m:
            return m.group(1)
        i -= 1
    return None


def _is_nonpublic_decl(lines_arr: list[str], line_1based: int, name: str) -> bool:
    """True if a declaration is not part of the public API.

    Covers three cases the public-API doc/test contract does NOT apply to, each
    of which previously produced false positives:
      1. Private members (`_`-prefixed names).
      2. Private named constructors (`ClassName._()`), whose captured name is the
         public class but whose `._` makes the constructor private.
      3. Members of a private enclosing type (`class _Node { ... }`).
    """
    if name.startswith("_"):
        return True
    idx = line_1based - 1
    if 0 <= idx < len(lines_arr) and _PRIVATE_CTOR_RE.search(lines_arr[idx]):
        return True
    # Walk up to the nearest enclosing type declaration. A `}` in column 0 means
    # we left a sibling type without finding an opener, so this decl is top-level.
    i = idx - 1
    while i >= 0:
        line = lines_arr[i]
        if line.startswith("}"):
            return False
        m = _TYPE_DECL_RE.match(line)
        if m:
            return m.group(1).startswith("_")
        i -= 1
    return False


def _dartdoc_header_lines(lines_arr: list[str], decl_line_1based: int) -> int:
    """Count the `///` dartdoc lines immediately above a declaration (skipping
    blank lines, `//` comments, annotations, and multi-line signature
    continuations). Used to credit header documentation toward a function's
    explanation budget in the inline-comment check."""
    count = 0
    i = decl_line_1based - 2
    while i >= 0:
        stripped = lines_arr[i].strip()
        if stripped.startswith("///"):
            count += 1
            i -= 1
        elif (
            stripped == ""
            or stripped.startswith("//")
            or stripped.startswith("@")
            or stripped.endswith((")", ">", ","))
        ):
            i -= 1
        else:
            break
    return count


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
    """Extract public member names (methods, getters, constructors) from a Dart lib file."""
    text = lib_path.read_text(encoding="utf-8")
    return [name for name, _params, _line in _iter_decls(text)]


def _all_test_blocks(test_root: Path) -> list[str]:
    """Every test()/group() block body across all test files, as raw text.

    WHY global (not the mapped `<lib>_test.dart`): this repo groups several lib
    files under one combined test file, so a per-file mapping under-counts.
    Counting a member's references across all blocks fixes the histogram and the
    untested-method check alike.
    """
    blocks: list[str] = []
    if not test_root.exists():
        return blocks
    for tf in test_root.rglob("*.dart"):
        parts = re.split(r"\b(?:test|group)\s*\(\s*['\"]", tf.read_text(encoding="utf-8"))
        blocks.extend(parts[1:])
    return blocks


def audit_coverage(project_dir: Path, lib_root: Path, test_root: Path) -> tuple[list[str], dict[str, int]]:
    """
    Build histogram: how many methods have 0, 1, 2, 3, ... unit tests.
    Returns (report_lines, test_count_by_method).
    """
    lines: list[str] = []
    test_count_by_method: dict[str, int] = {}
    all_blocks = _all_test_blocks(test_root)

    lib_dart = list(lib_root.rglob("*.dart"))
    for lib_path in lib_dart:
        members = _find_public_members(lib_path)
        # Count how many test/group blocks (anywhere) reference each member.
        for m in members:
            key = f"{lib_path.relative_to(project_dir)}::{m}"
            test_count_by_method[key] = sum(1 for b in all_blocks if m in b)

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

def audit_analyzer(
    project_dir: Path,
) -> tuple[list[str], list[str], list[str], list[str]]:
    """Run dart analyze --format machine and bucket findings by severity.

    Returns (report_lines, errors, warnings, infos) where each severity list
    holds formatted "file:line  CODE  message" detail strings. WHY return the
    detail strings rather than bare counts: the caller now prints the top 10 of
    each category to the terminal, so it needs the actual messages, not just a
    tally. Counts are derivable as len() of each list.

    Machine format is pipe-delimited:
        SEVERITY|TYPE|CODE|FILE|LINE|COL|LENGTH|MESSAGE
    """
    result = run_mod.run_capture(
        ["dart", "analyze", "--format", "machine"], project_dir
    )
    errors: list[str] = []
    warnings: list[str] = []
    infos: list[str] = []
    for line in (result.stdout or "").splitlines():
        if not line.strip():
            continue
        parts = line.split("|")
        # Need all 8 machine-format fields to build a detail line; anything
        # shorter is a malformed/partial line we skip rather than misparse.
        if len(parts) < 8:
            continue
        sev = parts[0].strip()
        code = parts[2].strip()
        file_path = parts[3].strip()
        line_no = parts[4].strip()
        message = parts[7].strip()
        # Show a repo-relative path so report lines stay readable; fall back to
        # the bare filename if the analyzer emits a path outside project_dir.
        try:
            location = Path(file_path).relative_to(project_dir)
        except ValueError:
            location = Path(file_path).name
        detail = f"  {location}:{line_no}  {code}  {message}"
        if sev == "ERROR":
            errors.append(detail)
        elif sev == "WARNING":
            warnings.append(detail)
        elif sev == "INFO":
            infos.append(detail)
    report_lines = [
        f"  Errors:   {len(errors)}",
        f"  Warnings: {len(warnings)}",
        f"  Info:     {len(infos)}",
        "",
    ]
    return report_lines, errors, warnings, infos


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
        # Use the same declaration parser as `_find_public_members` so the
        # method-range list is consistent with the member list (no call-site noise).
        parsed = _parse_decl(line)
        name = parsed[0] if parsed else ""
        if name:
            decl_line_1based = i + 1
            # Find the body span. Track paren depth so that named-parameter
            # braces (`{ ... }` inside the parameter list) and multi-line
            # signatures do not prematurely close the range — only braces at
            # paren depth 0 are body braces. Expression/abstract bodies have no
            # body brace, so they end at the first top-level `;`.
            paren = 0
            brace = 0
            seen_body = False
            end_line = None
            for j in range(i, len(lines)):
                for c in _strip_strings(_strip_line_comment(lines[j])):
                    if c == "(":
                        paren += 1
                    elif c == ")":
                        paren -= 1
                    elif paren <= 0 and c == "{":
                        brace += 1
                        seen_body = True
                    elif paren <= 0 and c == "}":
                        brace -= 1
                        if seen_body and brace <= 0:
                            end_line = j + 1
                            break
                    elif paren <= 0 and c == ";" and not seen_body:
                        # Expression-bodied (`=> ...;`) or abstract (`;`) member.
                        end_line = j + 1
                        break
                if end_line is not None:
                    break
            ranges.append((decl_line_1based, end_line or len(lines), name))
        i += 1

    # Drop declarations nested inside another declaration's body — local
    # closures such as an `emitPending()` helper defined inside a function.
    # WHY: a real top-level function or class member never starts inside the
    # line span of another matched declaration; a local closure always does.
    # Without this, closures were audited as if they were public members (e.g.
    # flagged for "missing doc header", which Dart does not even allow on a
    # local function). Class/extension headers are not matched by `_DECL_RE`,
    # so sibling members never contain each other — only bodies contain
    # closures — making the containment test a clean nesting filter.
    ranges.sort(key=lambda r: r[0])
    filtered: list[tuple[int, int, str]] = []
    last_end = 0
    for start, end, nm in ranges:
        if start <= last_end:
            continue
        filtered.append((start, end, nm))
        last_end = end
    return filtered


def audit_doc_headers(lib_root: Path) -> tuple[list[str], list[str]]:
    """Check each method has at least one /// dartdoc line preceding it.

    WHY: previously this required ≥2 `///` lines, which falsely flagged valid
    one-line dartdocs like:
        /// Number of failures before the circuit opens.
        int get failureThreshold => _failureThreshold;
    The Dart effective style guide does not require multi-line dartdoc; a single
    `///` line is a complete, valid doc comment. We now flag only methods that
    have ZERO doc lines.
    """
    missing: list[str] = []

    for lib_path in lib_root.rglob("*.dart"):
        content = lib_path.read_text(encoding="utf-8")
        lines_arr = content.splitlines()
        for start_line, end_line, name in _method_ranges(content):
            # Non-public declarations are not part of the public API, so the
            # dartdoc contract (enforced repo-wide by `public_member_api_docs`)
            # does not require docs on them. This covers private members, private
            # named constructors, and members of private types — together ~half
            # the false positives in this check.
            if _is_nonpublic_decl(lines_arr, start_line, name):
                continue
            # A constructor (name == enclosing type) is documented by the type's
            # own dartdoc; `public_member_api_docs` does not require a separate
            # doc on it, so neither should this check.
            if name == _enclosing_type_name(lines_arr, start_line):
                continue
            doc_lines = []
            is_override = False
            # >0 while the walk is still unwinding a multi-line annotation or
            # parameter list opened on a lower line (e.g. a `@Deprecated( ... )`
            # whose message is split across several string-literal lines). Those
            # interior lines neither start with `@` nor end with a bracket, so
            # without depth tracking the walk hit the `else: break` below and
            # falsely reported the dartdoc above the annotation as missing —
            # which is exactly what happened to the deprecated `isNullOrEmpty` /
            # `isNotNullOrEmpty` getters (multi-line `@Deprecated` message).
            ann_paren_depth = 0
            i = start_line - 2
            while i >= 0 and i < len(lines_arr):
                raw = lines_arr[i]
                l = raw.strip()
                # Count only structural parens (string/comment contents removed)
                # so a `(` inside a doc message does not unbalance the depth.
                bare = _strip_strings(_strip_line_comment(raw))
                # Inside an unfinished annotation/arg list: skip every line until
                # its opening `@Name(` / `(` brings the depth back to zero.
                if ann_paren_depth > 0:
                    ann_paren_depth += bare.count(")") - bare.count("(")
                    if ann_paren_depth < 0:
                        ann_paren_depth = 0
                    i -= 1
                    continue
                if l.startswith("///"):
                    doc_lines.append(l)
                    i -= 1
                # Skip blank lines, `//` comments, and annotations
                # (`@override`, `@useResult`, `@Deprecated('msg')`, `@pragma(...)`)
                # that legitimately appear between dartdoc and declaration.
                # WHY: previously the walk aborted on `@useResult`, so well-documented
                # getters like `anyTrue` (with 7 lines of `///` dartdoc above the
                # `@useResult` line) were falsely reported as missing dartdoc.
                elif l == "" or l.startswith("//") or l.startswith("@"):
                    if l.startswith("@override"):
                        is_override = True
                    i -= 1
                # Skip a multi-line signature continuation OR the closing line of
                # a multi-line annotation: when a declaration's return type /
                # parameter list spans several lines, or a `@Deprecated( ... )`
                # message is split over multiple lines, the line just above ends
                # with `)`, `>`, or `,`. Track paren depth so any interior lines
                # above are skipped until the opener is reached.
                # WHY: e.g. a record-returning function whose tuple type sits on
                # its own line above the name — without this the walk stopped
                # there and falsely reported the (present) dartdoc above as missing.
                elif l.endswith((")", ">", ",")):
                    ann_paren_depth += bare.count(")") - bare.count("(")
                    i -= 1
                else:
                    break
            # Overrides (toString, operator==, hashCode, ...) inherit their
            # supertype's documentation, so a missing `///` is not a defect.
            if not doc_lines and not is_override:
                missing.append(f"  {lib_path.name}:{start_line}  {name}")

    report_lines: list[str] = []
    if missing:
        report_lines.append("Methods with no dartdoc comment:")
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
    """Flag genuine bad practices (empty catch blocks).

    WHY no recursion check: a self-call by name is NOT a defect — recursion is
    the correct, idiomatic implementation for tries, disjoint-set find, graph
    traversal, tree walks, and deep-structure transforms (all present in this
    library). Detecting recursion without base-case / termination analysis (which
    a regex cannot do) only ever produces false positives — every legitimate
    recursive helper was flagged. The check was removed; the empty-catch smell
    (a real defect — silently swallowed errors) is kept.
    """
    report_lines: list[str] = []
    issues: list[str] = []

    for lib_path in lib_root.rglob("*.dart"):
        content = lib_path.read_text(encoding="utf-8")
        lines_arr = content.splitlines()
        for start_line, end_line, name in _method_ranges(content):
            # Skip the declaration line; scan only the body.
            body = "\n".join(lines_arr[start_line:end_line])
            # Empty catch: catch (_) { } or catch (e) { } — swallows errors.
            if re.search(r"catch\s*\([^)]+\)\s*\{\s*\}", body):
                issues.append(f"  {lib_path.name}:{start_line}  empty catch block: {name}")
    if issues:
        report_lines.append("Empty catch blocks (errors silently swallowed):")
        report_lines.extend(issues[:30])
        if len(issues) > 30:
            report_lines.append(f"  ... and {len(issues) - 30} more")
    else:
        report_lines.append("No empty-catch issues found.")
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
    # WHY: previously this used a loose regex anchored only to start-of-line, which
    # matched call sites inside method bodies (e.g. body `DateTime(y, m, d, h, m, s, ms, us)`
    # was reported as "DateTime() has 8 params"). Use the strict declaration regex so
    # only actual method/function/constructor declarations are counted.
    many_params: list[str] = []
    for p in lib_root.rglob("*.dart"):
        content = p.read_text(encoding="utf-8")
        lines_arr = content.splitlines()
        for name, param_count, line_no in _iter_decls(content):
            # Getters (param_count None) and zero-arg members have no param surface.
            if not param_count:
                continue
            # Skip non-public declarations (private members/ctors, members of
            # private types): the >3-params guideline targets the public API
            # surface, and private helpers legitimately take more arguments.
            if _is_nonpublic_decl(lines_arr, line_no, name):
                continue
            if param_count > 3:
                many_params.append(f"  {p.name}: {name}() has {param_count} params")
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
# 7. Inline code-comment density per method
# -----------------------------------------------------------------------------

# Keywords that introduce a branch or a loop. Each is a decision/iteration point
# that project policy says must carry an explanatory inline comment.
_BRANCH_KEYWORDS = ("if", "else", "switch", "case", "for", "while", "do")
# Functional iteration calls count as loops for comment purposes (a `.map(...)`
# transform is an algorithm step that deserves a "why" just like a `for`).
_ITER_CALLS_RE = re.compile(
    r"\.(?:forEach|map|where|fold|reduce|expand|every|any)\s*\("
)
# A real inline comment line: starts with // but is NOT a dartdoc (///, which is
# API documentation, counted separately) and NOT a // ignore: lint directive
# (tooling instruction, not an explanation of the logic).
_COMMENT_LINE_RE = re.compile(r"^\s*//(?!/)(?!\s*ignore)")

# Below this many comment-worthy constructs a method is trivial enough to be
# self-documenting, so we don't demand inline comments.
_MIN_CONSTRUCTS_FOR_COMMENT = 3
# Target density: roughly one explanatory comment per three decision points.
# A method below this ratio is flagged as under-commented.
_MIN_COMMENT_RATIO = 0.34


def _count_constructs_and_comments(body: list[str]) -> tuple[int, int]:
    """Count comment-worthy constructs and real inline comments in a method body.

    Constructs = branch/loop keywords + functional iteration calls. Comments =
    standalone `//` lines plus trailing inline `code // note` comments. Pure
    comment lines are not also counted as code.

    WHY only branches/loops (not variable declarations): the project comment
    policy is "comment WHY on decisions, branches, loops, and invariants — well-
    named identifiers cover WHAT." Plain `final`/`var` bindings with descriptive
    names are self-documenting under that rule, so counting each one as a
    construct demanding a comment contradicts the policy and over-flagged
    variable-heavy but logic-light methods. Decision and iteration points are
    what genuinely warrant a "why".
    """
    constructs = 0
    comments = 0
    for raw in body:
        stripped = raw.strip()
        # A standalone comment line contributes a comment and no constructs.
        if _COMMENT_LINE_RE.match(raw):
            comments += 1
            continue
        # A trailing comment on a code line (`x = 1; // why`) still counts.
        if "//" in stripped and not stripped.startswith("//"):
            comments += 1
        # Each branch/loop keyword occurrence is a separate decision point;
        # `else if` legitimately counts as two (an else and a nested if).
        for keyword in _BRANCH_KEYWORDS:
            constructs += len(re.findall(rf"\b{keyword}\b", stripped))
        # Functional iteration calls are loop-equivalent algorithm steps.
        constructs += len(_ITER_CALLS_RE.findall(stripped))
    return constructs, comments


def audit_code_comments(
    project_dir: Path, lib_root: Path
) -> tuple[list[str], list[str]]:
    """Flag methods whose logic lacks inline comments.

    Requirement: comment each variable, branch, iteration and algorithm step.
    Enforcing one-comment-per-line literally would flag nearly every method, so
    we use a density heuristic (see `_count_constructs_and_comments`): a method
    is reported only when it has at least `_MIN_CONSTRUCTS_FOR_COMMENT`
    comment-worthy constructs AND its comment-to-construct ratio is below
    `_MIN_COMMENT_RATIO`. Results are ranked by comment shortfall (constructs
    minus comments) descending, so the top 10 are the most complex,
    least-explained methods.
    """
    # (shortfall, detail) so we can rank worst-first before dropping the score.
    ranked: list[tuple[int, str]] = []
    for lib_path in lib_root.rglob("*.dart"):
        content = lib_path.read_text(encoding="utf-8")
        lines_arr = content.splitlines()
        for start_line, end_line, name in _method_ranges(content):
            # Skip the declaration line itself (index start_line-1); scan only
            # the body so a signature's own keywords aren't miscounted.
            body = lines_arr[start_line:end_line]
            constructs, comments = _count_constructs_and_comments(body)
            # Trivial methods are exempt from the inline-comment requirement.
            if constructs < _MIN_CONSTRUCTS_FOR_COMMENT:
                continue
            # Credit the dartdoc header toward the WHY budget: the project policy
            # is "comment WHY", and for cohesive algorithmic utilities the why
            # often lives in a multi-line `///` header rather than inline. A
            # function whose header explains its approach is documented; this
            # check should flag only functions under-explained RELATIVE to their
            # complexity, counting header + inline together.
            comments += _dartdoc_header_lines(lines_arr, start_line)
            ratio = comments / constructs
            if ratio < _MIN_COMMENT_RATIO:
                shortfall = constructs - comments
                rel = lib_path.relative_to(project_dir)
                ranked.append(
                    (
                        shortfall,
                        f"  {rel}:{start_line}  {name}  "
                        f"{constructs} constructs, {comments} comments",
                    )
                )
    ranked.sort(key=lambda x: -x[0])
    issues = [detail for _shortfall, detail in ranked]

    report_lines: list[str] = []
    if issues:
        report_lines.append("Methods with logic but sparse inline comments:")
        report_lines.extend(issues[:50])
        if len(issues) > 50:
            report_lines.append(f"  ... and {len(issues) - 50} more")
    else:
        report_lines.append(
            "All non-trivial methods have adequate inline comments."
        )
    return report_lines, issues


# -----------------------------------------------------------------------------
# 8. Per-parameter unit test coverage
# -----------------------------------------------------------------------------

def _members_with_params(lib_path: Path) -> list[tuple[str, int, int]]:
    """Return (name, param_count, line_1based) for each declaration in a file."""
    text = lib_path.read_text(encoding="utf-8")
    lines_arr = text.splitlines()
    out: list[tuple[str, int, int]] = []
    for name, param_count, line_no in _iter_decls(text):
        # Skip non-public declarations: private members, private constructors,
        # and members of private types cannot be referenced by name from a test
        # file, so the per-parameter test floor is unsatisfiable for them — they
        # are exercised transitively through the public API that calls them.
        if _is_nonpublic_decl(lines_arr, line_no, name):
            continue
        # Getters report None params; treat as zero parameter surface.
        out.append((name, param_count or 0, line_no))
    return out


def _constructor_field_names(
    lines_arr: list[str], ctor_line_1based: int, name: str
) -> set[str] | None:
    """If the declaration at `ctor_line_1based` is a constructor (its name equals
    the enclosing type), return the set of public `final` instance field names
    declared in that type's body; otherwise return None.

    WHY: a data/result class constructor is frequently never called by name in a
    test — instances are produced by the public function under test and verified
    by reading their fields (e.g. `parseCsv(...).errors.first.lineNumber`). The
    literal `CsvRowError(` token then never appears in `test/`, so a pure
    name-match flags the constructor as untested even though its output is fully
    asserted. Crediting field reads fixes that false positive while still flagging
    the genuine gap when a field is never read (the caller requires ALL fields).
    """
    type_name = _enclosing_type_name(lines_arr, ctor_line_1based)
    if type_name is None or type_name != name:
        return None

    # Walk up to the class declaration that opens this constructor's body. A `}`
    # in column 0 means we left a sibling type, so bail (treat as no fields).
    start = None
    i = ctor_line_1based - 2
    while i >= 0:
        if _TYPE_DECL_RE.match(lines_arr[i]):
            start = i
            break
        if lines_arr[i].startswith("}"):
            break
        i -= 1
    if start is None:
        return set()

    # Brace-match from the class declaration to its closing brace, collecting
    # public `final` field names along the way.
    fields: set[str] = set()
    depth = 0
    seen_open = False
    for j in range(start, len(lines_arr)):
        line = lines_arr[j]
        m = _FIELD_DECL_RE.match(line)
        if m and not m.group(1).startswith("_"):
            fields.add(m.group(1))
        depth += line.count("{") - line.count("}")
        if "{" in line:
            seen_open = True
        if seen_open and depth <= 0:
            break
    return fields


def _tested_identifiers(test_root: Path) -> set[str]:
    """Collect every identifier referenced anywhere under `test/`.

    WHY a global set instead of one mapped test file: this repo groups several
    lib files under one combined test (e.g. `duration_format_utils.dart` is
    tested by `duration_format_parse_test.dart`, and `num_lerp_utils.dart` by
    `num_prime_factorial_modulo_lerp_test.dart`). The old per-file name mapping
    (`<lib>_test.dart`) missed those, reporting well-tested methods as having 0
    tests. Scanning all test sources for the member name avoids that.
    """
    ids: set[str] = set()
    if not test_root.exists():
        return ids
    for tf in test_root.rglob("*.dart"):
        ids.update(re.findall(r"[A-Za-z_]\w*", tf.read_text(encoding="utf-8")))
    return ids


def audit_param_test_coverage(
    project_dir: Path, lib_root: Path, test_root: Path
) -> tuple[list[str], list[str]]:
    """Flag public methods/functions with parameters that NO test references.

    WHY "untested" rather than a per-parameter floor: per-parameter-variation
    coverage cannot be measured by name matching (a test name does not reveal
    which parameter it exercises), so the old "N+1 test blocks" floor was an
    arbitrary proxy that punished thorough tests written as few cases. The
    measurable, meaningful signal is whether a method with a parameter surface
    is referenced by ANY test at all — a genuinely untested public method is
    real, actionable debt. Methods referenced anywhere in `test/` are considered
    covered.
    """
    tested = _tested_identifiers(test_root)
    issues: list[str] = []
    for lib_path in lib_root.rglob("*.dart"):
        lines_arr = lib_path.read_text(encoding="utf-8").splitlines()
        for name, param_count, line_no in _members_with_params(lib_path):
            # Only methods/functions with a parameter surface; zero-arg members
            # and getters are out of scope for this check.
            if param_count < 1:
                continue
            if name in tested:
                continue
            # A value-class constructor is exercised when its instances are built
            # by the function under test and every field is asserted, even if the
            # type name is never written in a test. Credit that before flagging.
            fields = _constructor_field_names(lines_arr, line_no, name)
            if fields and fields <= tested:
                continue
            rel = lib_path.relative_to(project_dir)
            issues.append(
                f"  {rel}:{line_no}  {name}()  "
                f"{param_count} params, untested (no test references it)"
            )

    report_lines: list[str] = []
    if issues:
        report_lines.append("Public methods with parameters not referenced by any test:")
        report_lines.extend(issues[:50])
        if len(issues) > 50:
            report_lines.append(f"  ... and {len(issues) - 50} more")
    else:
        report_lines.append("Every public method with parameters is referenced by a test.")
    return report_lines, issues


# -----------------------------------------------------------------------------
# Run full audit and write report
# -----------------------------------------------------------------------------

def run_audit(project_dir: Path) -> tuple[dict[str, list[str]], Path]:
    """
    Run all audit checks and write report to reports/yyyymmdd/yyyymmdd_HHMMSS_publish_audit.txt.

    Returns (findings, report_path) where `findings` maps each category name to
    the FULL list of its detail strings (worst-first where the check ranks them).
    The caller derives the count as len() and prints the top 10 of each to the
    terminal; the complete lists live in the on-disk report (the audit log).
    An empty dict means no quality issues were found.
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
    ui.print_info("Audit 1/10: Code coverage (test count per method)...")
    cov_lines, _ = audit_coverage(project_dir, lib_root, test_root)
    all_lines.extend(_section(cov_lines, "1. UNIT TEST COVERAGE (methods by test count)"))

    # 2. Analyzer
    ui.print_info("Audit 2/10: Dart analyzer...")
    ana_lines, ana_errors, ana_warnings, ana_infos = audit_analyzer(project_dir)
    all_lines.extend(_section(ana_lines, "2. ANALYZER (error / warning / info)"))
    all_lines.append(
        f"  Total: {len(ana_errors)} errors, "
        f"{len(ana_warnings)} warnings, {len(ana_infos)} info"
    )
    all_lines.append("")
    # Persist the individual analyzer messages so the report is a full log, not
    # just the totals (the terminal only shows the top 10 of each).
    if ana_errors:
        all_lines.append("  Errors:")
        all_lines.extend(ana_errors)
    if ana_warnings:
        all_lines.append("  Warnings:")
        all_lines.extend(ana_warnings)
    if ana_infos:
        all_lines.append("  Info:")
        all_lines.extend(ana_infos)
    all_lines.append("")

    # 3. Doc headers
    ui.print_info("Audit 3/10: Multiline doc headers...")
    doc_lines, missing_docs = audit_doc_headers(lib_root)
    all_lines.extend(_section(doc_lines, "3. MULTILINE DOC HEADERS"))
    all_lines.append("")

    # 4. Inline code-comment density
    ui.print_info("Audit 4/10: Inline code comments (branches/loops/vars)...")
    comment_lines, comment_issues = audit_code_comments(project_dir, lib_root)
    all_lines.extend(_section(comment_lines, "4. INLINE CODE COMMENTS (per method)"))

    # 5. Per-parameter unit test coverage
    ui.print_info("Audit 5/10: Per-parameter unit test coverage...")
    param_lines, param_issues = audit_param_test_coverage(
        project_dir, lib_root, test_root
    )
    all_lines.extend(
        _section(param_lines, "5. UNTESTED PUBLIC METHODS (with parameters)")
    )

    # 6. Bad practices (empty catch)
    ui.print_info("Audit 6/10: Bad practices (empty catch)...")
    rec_lines, rec_issues = audit_recursion_and_bad(lib_root)
    all_lines.extend(_section(rec_lines, "6. BAD PRACTICES (empty catch)"))

    # 7. Try/catch
    ui.print_info("Audit 7/10: Try/catch usage...")
    try_lines, _ = audit_try_catch(lib_root)
    all_lines.extend(_section(try_lines, "7. TRY/CATCH ERROR HANDLING (per method)"))

    # 8. Duplicate Dart class names
    ui.print_info("Audit 8/10: Duplicate Dart class names...")
    dup_lines, dup_map = duplicate_classes.audit_duplicate_classes(project_dir)
    all_lines.extend(_section(dup_lines, "8. DUPLICATE DART CLASS NAMES"))

    # 9. Other quality
    ui.print_info("Audit 9/10: Other quality checks...")
    other_lines = audit_other_quality(project_dir, lib_root)
    all_lines.extend(_section(other_lines, "9. OTHER QUALITY CHECKS"))

    # 10. Summary and recommendations
    ui.print_info("Audit 10/10: Summary...")
    summary = [
        "Recommendations:",
        "  - Fix all analyzer errors before publishing.",
        "  - Consider fixing analyzer warnings and adding docs for methods with 0-1 tests.",
        "  - Add inline comments to flagged branch/loop/variable-heavy methods.",
        "  - Add tests for any public method with parameters that none reference.",
        "  - Review methods with try/catch for proper error handling.",
        "  - Fix any empty-catch blocks (silently swallowed errors).",
        "  - Address file length if policy requires.",
    ]
    all_lines.extend(_section(summary, "10. SUMMARY & RECOMMENDATIONS"))

    report_path.write_text("\n".join(all_lines), encoding="utf-8")
    ui.print_success(f"Audit report written to {report_path}")

    # Duplicate class names as ranked detail strings (most occurrences first) so
    # the caller can show the worst 10 alongside the other categories.
    dup_details = [
        f"  {name}  (in: {', '.join(files)})"
        for name, files in sorted(
            dup_map.items(), key=lambda item: (-len(item[1]), item[0])
        )
    ]

    # Build per-category findings for the caller. Each value is the full detail
    # list (already worst-first where the check ranks); the caller shows top 10.
    findings: dict[str, list[str]] = {}
    if ana_errors:
        findings["Analyzer errors"] = ana_errors
    if ana_warnings:
        findings["Analyzer warnings"] = ana_warnings
    if ana_infos:
        findings["Analyzer infos"] = ana_infos
    if missing_docs:
        findings["Missing doc headers"] = missing_docs
    if comment_issues:
        findings["Sparse code comments"] = comment_issues
    if param_issues:
        findings["Untested public methods"] = param_issues
    if rec_issues:
        findings["Empty catch blocks"] = rec_issues
    if dup_details:
        findings["Duplicate class names"] = dup_details

    return findings, report_path

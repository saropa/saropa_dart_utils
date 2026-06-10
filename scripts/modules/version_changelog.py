"""Version and CHANGELOG parsing and updates."""

import re
from datetime import datetime
from pathlib import Path

from . import ui

# Base of the per-release "[log]" link required at the top of every CHANGELOG
# section. The maintenance note in CHANGELOG.md mandates each release open with
# one plain-language line and close with `[log](<base>/v<X.Y.Z>/CHANGELOG.md)`
# ([Unreleased] uses `main` in place of the tag). Centralized here so the
# validator and the auto-fixer agree on the exact URL shape.
LOG_LINK_BASE = "https://github.com/saropa/saropa_dart_utils/blob"


def parse_version(version: str) -> tuple[int, int, int]:
    """Parse a version string into (major, minor, patch) tuple."""
    parts = version.split(".")
    return int(parts[0]), int(parts[1]), int(parts[2])


def get_version_from_pubspec(pubspec_path: Path) -> str:
    """Read version string from pubspec.yaml."""
    content = pubspec_path.read_text(encoding="utf-8")
    match = re.search(r"^version:\s*(\d+\.\d+\.\d+)", content, re.MULTILINE)
    if not match:
        raise ValueError("Could not find version in pubspec.yaml")
    return match.group(1)


def update_pubspec_version(pubspec_path: Path, new_version: str) -> None:
    """Update the version in pubspec.yaml."""
    content = pubspec_path.read_text(encoding="utf-8")
    updated = re.sub(
        r"^(version:\s*)\d+\.\d+\.\d+",
        rf"\g<1>{new_version}",
        content,
        count=1,
        flags=re.MULTILINE,
    )
    pubspec_path.write_text(updated, encoding="utf-8")


def has_unreleased_section(changelog_path: Path) -> bool:
    """Check if CHANGELOG.md has an [Unreleased] section."""
    content = changelog_path.read_text(encoding="utf-8")
    return bool(re.search(r"##\s*\[Unreleased\]", content, re.IGNORECASE))


def bump_patch_version(version: str) -> str:
    """Bump the patch component of a semantic version string."""
    major, minor, patch = parse_version(version)
    return f"{major}.{minor}.{patch + 1}"


def bump_minor_version(version: str) -> str:
    """Bump the minor component (resets patch to 0)."""
    major, minor, _ = parse_version(version)
    return f"{major}.{minor + 1}.0"


def bump_major_version(version: str) -> str:
    """Bump the major component (resets minor and patch to 0)."""
    major, _, _ = parse_version(version)
    return f"{major + 1}.0.0"


def update_changelog_unreleased(changelog_path: Path, new_version: str) -> None:
    """Replace [Unreleased] header with versioned header and today's date."""
    content = changelog_path.read_text(encoding="utf-8")
    today = datetime.now().strftime("%Y-%m-%d")
    updated = re.sub(
        r"(##\s*)\[Unreleased\]",
        rf"\g<1>[{new_version}] - {today}",
        content,
        count=1,
        flags=re.IGNORECASE,
    )
    changelog_path.write_text(updated, encoding="utf-8")


def strip_unreleased_suffix(changelog_path: Path, version: str) -> bool:
    """Remove a trailing "- Unreleased" placeholder from a version's header.

    This handles a header shape distinct from `## [Unreleased]` (covered by
    `has_unreleased_section`/`update_changelog_unreleased`): the in-flight
    section is written as `## [1.1.1] - Unreleased`, where "Unreleased" is a
    placeholder sitting in the date slot. `get_latest_changelog_version` reads
    `1.1.1` straight through that suffix, so without this step the placeholder
    reaches pub.dev and labels a shipped release as unreleased.

    Targets only the header for `version`, leaving older dated entries intact,
    and drops the entire " - Unreleased" run (separator included) so the header
    reads `## [1.1.1]`. Returns True when a placeholder was removed.
    """
    content = changelog_path.read_text(encoding="utf-8")
    # Capture the bracketed-version portion so it survives verbatim; consume the
    # separator, the literal "Unreleased", and any trailing spaces/tabs, but
    # stop at the newline ([ \t]* never crosses it) so the line break is kept.
    pattern = rf"(##\s*\[?{re.escape(version)}\]?)\s*-\s*Unreleased[ \t]*"
    updated, count = re.subn(
        pattern, r"\g<1>", content, count=1, flags=re.IGNORECASE
    )
    if count == 0:
        return False
    changelog_path.write_text(updated, encoding="utf-8")
    return True


def get_package_name(pubspec_path: Path) -> str:
    """Read package name from pubspec.yaml."""
    content = pubspec_path.read_text(encoding="utf-8")
    match = re.search(r"^name:\s*(.+)$", content, re.MULTILINE)
    if not match:
        raise ValueError("Could not find name in pubspec.yaml")
    return match.group(1).strip()


def get_latest_changelog_version(changelog_path: Path) -> str | None:
    """Extract the latest version from CHANGELOG.md."""
    if not changelog_path.exists():
        return None

    content = changelog_path.read_text(encoding="utf-8")
    match = re.search(r"##\s*\[?(\d+\.\d+\.\d+)\]?", content)
    if match:
        return match.group(1)
    return None


def validate_changelog_version(project_dir: Path, version: str) -> str | None:
    """Validate version exists in CHANGELOG and extract release notes."""
    changelog_path = project_dir / "CHANGELOG.md"

    if not changelog_path.exists():
        return None

    content = changelog_path.read_text(encoding="utf-8")
    version_pattern = rf"##\s*\[?{re.escape(version)}\]?"
    if not re.search(version_pattern, content):
        return None

    pattern = rf"(?s)##\s*\[?{re.escape(version)}\]?[^\n]*\n(.*?)(?=##\s*\[?\d+\.\d+\.\d+|$)"
    match = re.search(pattern, content)

    if match:
        return match.group(1).strip()
    return ""


def _release_section_bounds(content: str, version: str) -> tuple[int, int] | None:
    """Locate a version's section body within the raw CHANGELOG text.

    Returns (start, end) offsets spanning from just after the `## [version]`
    header line up to the next `## ` header (any version) or EOF, or None when
    the header is absent. The body is what carries the intro line, the log
    link, and the `### Added` / `### Fixed` subsections.
    """
    header = re.search(
        rf"##\s*\[?{re.escape(version)}\]?[^\n]*\n", content
    )
    if not header:
        return None
    start = header.end()
    # The next top-level `## ` header ends this section; nothing below it belongs
    # to `version`. Match a leading newline so a `##` mid-line cannot false-trip.
    nxt = re.search(r"\n##\s", content[start:])
    end = start + nxt.start() if nxt else len(content)
    return start, end


def has_release_intro(changelog_path: Path, version: str) -> bool:
    """Report whether a version's section opens with a plain-language intro.

    The maintenance note requires one casual, human-facing line before the
    `### Added` / `### Changed` subsections. We scan the section head (above the
    first `###`) for a non-empty line that is neither the `[log]` link nor a
    bullet — that line is the intro. Returns False when the section is missing
    or contains only the log link / bullets.
    """
    if not changelog_path.exists():
        return False

    content = changelog_path.read_text(encoding="utf-8")
    bounds = _release_section_bounds(content, version)
    if bounds is None:
        return False

    body = content[bounds[0] : bounds[1]]
    # Only the text above the first `### ` subsection can hold the intro.
    sub = re.search(r"\n###\s", body)
    head = body[: sub.start()] if sub else body

    for line in head.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        # The log link and bullet entries are not the human intro line.
        if stripped.startswith("[log]"):
            continue
        if stripped.startswith(("-", "*")):
            continue
        return True
    return False


def update_log_link(changelog_path: Path, version: str) -> bool:
    """Pin a version's `[log]` link to its release tag, rewriting in place.

    The [Unreleased] template ships the link pointing at `main`; once the
    section is versioned the link must point at `v<version>` so the published
    pub.dev changelog deep-links to the tagged file. Rewrites any existing
    `[log](<base>/.../CHANGELOG.md)` inside the section to the correct tag and
    returns True. Returns False when no log link exists in the section (a
    wholly missing link is the caller's to flag, not silently inserted).
    """
    if not changelog_path.exists():
        return False

    content = changelog_path.read_text(encoding="utf-8")
    bounds = _release_section_bounds(content, version)
    if bounds is None:
        return False

    start, end = bounds
    body = content[start:end]
    correct = f"[log]({LOG_LINK_BASE}/v{version}/CHANGELOG.md)"
    # Match the whole existing log link (any ref: `main` or a stale `vA.B.C`)
    # and replace just the link, leaving surrounding prose untouched.
    pattern = r"\[log\]\(" + re.escape(LOG_LINK_BASE) + r"/[^)]*\)"
    new_body, count = re.subn(pattern, correct, body, count=1)
    if count == 0:
        return False

    if new_body != body:
        content = content[:start] + new_body + content[end:]
        changelog_path.write_text(content, encoding="utf-8")
    return True


def display_changelog(project_dir: Path) -> str | None:
    """Display the latest changelog entry."""
    changelog_path = project_dir / "CHANGELOG.md"

    if not changelog_path.exists():
        ui.print_warning("CHANGELOG.md not found")
        return None

    content = changelog_path.read_text(encoding="utf-8")
    match = re.search(
        r"^(## \[?\d+\.\d+\.\d+\]?.*?)(?=^## |\Z)", content, re.MULTILINE | re.DOTALL
    )

    if match:
        latest_entry = match.group(1).strip()
        print()
        ui.print_colored("  CHANGELOG (latest entry):", ui.Color.WHITE)
        ui.print_colored("  " + "-" * 50, ui.Color.CYAN)
        for line in latest_entry.split("\n"):
            ui.print_colored(f"  {line}", ui.Color.CYAN)
        ui.print_colored("  " + "-" * 50, ui.Color.CYAN)
        print()
        return latest_entry

    ui.print_warning("Could not parse CHANGELOG.md")
    return None

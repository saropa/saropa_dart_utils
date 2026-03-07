"""Version and CHANGELOG parsing and updates."""

import re
from datetime import datetime
from pathlib import Path

from . import ui


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

"""Detect duplicate Dart class names across the project.

This is a Python port of the original PowerShell script
`flutter_detect_duplicate_classes.ps1`. It scans all `.dart` files under the
project (skipping build/tooling directories) and reports class names that are
declared in more than one file.
"""

from __future__ import annotations

import re
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Tuple

from . import ui


EXCLUDE_DIRS = {".dart_tool", "dependency_overrides"}
EXCLUDE_FILE_NAMES = {".git"}
EXCLUDE_CLASS_NAMES = {
    # From original script
    "for",
    "that",
    "which",
    "in",
    "with",
    "used",
    "representing",
}


def _is_excluded(path: Path, project_dir: Path) -> bool:
    """Return True if the file should be skipped based on directory/name."""
    try:
        rel = path.relative_to(project_dir)
    except ValueError:
        rel = path

    if any(part in EXCLUDE_DIRS for part in rel.parts):
        return True
    if path.name in EXCLUDE_FILE_NAMES:
        return True
    return False


def _find_classes_in_file(path: Path) -> List[str]:
    """
    Extract class names from a single Dart file.

    Heuristic:
    - Skip lines that are obviously comments (//, ///, /*, */ or inside /* */)
    - Look for `class <Name>` patterns
    """
    try:
        text = path.read_text(encoding="utf-8")
    except Exception:
        return []

    class_names: List[str] = []
    in_block_comment = False

    for raw_line in text.splitlines():
        line = raw_line.lstrip()

        # Track simple /* ... */ block comments
        if "/*" in line:
            in_block_comment = True
        if in_block_comment:
            if "*/" in line:
                in_block_comment = False
            continue

        if line.startswith("//") or line.startswith("///"):
            continue

        match = re.search(r"\bclass\s+([A-Za-z_]\w*)", line)
        if not match:
            continue

        name = match.group(1)
        if name in EXCLUDE_CLASS_NAMES:
            continue
        class_names.append(name)

    return class_names


def audit_duplicate_classes(project_dir: Path) -> Tuple[List[str], Dict[str, List[str]]]:
    """
    Scan the project for duplicate Dart class names.

    Returns:
        (report_lines, duplicates_by_class_name)
    """
    ui.print_info("Scanning for duplicate Dart class names...")

    class_to_files: Dict[str, List[str]] = defaultdict(list)
    total_files_scanned = 0

    for path in project_dir.rglob("*.dart"):
        if _is_excluded(path, project_dir):
            continue

        total_files_scanned += 1
        class_names = _find_classes_in_file(path)
        if not class_names:
            continue

        rel = str(path.relative_to(project_dir)).replace("\\", "/")
        for name in class_names:
            class_to_files[name].append(rel)

    duplicates: Dict[str, List[str]] = {
        name: files for name, files in class_to_files.items() if len(files) > 1
    }

    lines: List[str] = []
    if not duplicates:
        lines.append("No duplicate Dart class names found across the project.")
        lines.append(f"Files scanned: {total_files_scanned}")
        return lines, duplicates

    lines.append("Duplicate Dart class names (same class defined in multiple files):")
    for name, files in sorted(duplicates.items(), key=lambda item: (-len(item[1]), item[0])):
        lines.append(f"  {name} ({len(files)} occurrences)")
        for f in files:
            lines.append(f"      - {f}")

    lines.append("")
    lines.append(f"Total duplicate class names: {len(duplicates)}")
    lines.append(f"Total files scanned: {total_files_scanned}")

    return lines, duplicates


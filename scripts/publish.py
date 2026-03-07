#!/usr/bin/env python3
"""
Publish saropa_dart_utils package to pub.dev and create GitHub release.

This script automates the complete release workflow for a Dart/Flutter package.

  On start you choose:
    1 = Audit + build (run audit then full publish workflow)
    2 = Audit only (run audit, write report, exit)
    3 = Build only (skip audit, run publish workflow only)

  Audit phase (when chosen):
    - Code coverage: methods by unit test count (color-coded bar chart)
    - Analyzer: error / warning / info counts
    - Multiline doc headers per method
    - Recursion and bad practices (empty catch, etc.)
    - Try/catch usage per method
    - Other quality checks (file length, params, TODO, exports, etc.)
    - Report written to reports/yyyymmdd/yyyymmdd_HHMMSS_publish_audit.txt
    - Shows per-category findings with counts; prompt "Continue? [y/N]"

  Pre-checks (before numbered steps):
    - Validates pubspec.yaml and CHANGELOG.md versions are in sync
    - If CHANGELOG.md has an [Unreleased] section, resolves it:
      - If current version already has notes: offers patch/minor/major bump
      - If no versioned section yet: converts [Unreleased] to version header
    - Fails if version tag already exists on remote

  Numbered steps:
    1. Checks prerequisites (flutter, git, gh auth, publish workflow)
    2. Checks working tree status
    3. Checks remote sync
    4. Formats code
    5. Runs tests
    6. Runs static analysis
    7. Validates changelog has release notes
    8. Generates documentation with dart doc
    9. Pre-publish validation (dry-run)
    10. Commits and pushes changes
    11. Creates and pushes git tag
    12. Triggers GitHub Actions publish to pub.dev
    13. Creates GitHub release with release notes

Version:   2.4
Author:    Saropa
Copyright: (c) 2025 Saropa

Usage:
    python scripts/publish.py
    Then choose 1, 2, or 3 when prompted.

Exit Codes:
    0 - Success
    1 - Prerequisites failed
    2 - Working tree check failed
    3 - Tests failed
    4 - Analysis failed
    5 - Changelog validation failed
    6 - Pre-publish validation failed
    7 - Publish failed
    8 - Git operations failed
    9 - User cancelled
    10 - Audit had errors/warnings and user chose not to continue
"""

from __future__ import annotations

import re
import subprocess
import sys
import webbrowser
from pathlib import Path

from modules import audit
from modules import constants
from modules import platform as platform_mod
from modules import ui
from modules import version_changelog as vc
from modules import workflow

SCRIPT_VERSION = constants.SCRIPT_VERSION
ExitCode = constants.ExitCode


def main() -> int:
    """Main entry point."""
    ui.enable_ansi_support()
    ui.show_saropa_logo()
    ui.print_colored(
        f"  Saropa Dart Utils publisher script v{SCRIPT_VERSION}", ui.Color.MAGENTA
    )
    print()

    script_dir = Path(__file__).parent
    project_dir = script_dir.parent

    pubspec_path = project_dir / "pubspec.yaml"
    if not pubspec_path.exists():
        ui.exit_with_error(
            f"pubspec.yaml not found at {pubspec_path}", ExitCode.PREREQUISITES_FAILED
        )

    # Mode: 1 = audit + build, 2 = audit only, 3 = build only
    ui.print_colored("  Choose mode:", ui.Color.WHITE)
    ui.print_colored("    1 = Audit + build (audit then full publish workflow)", ui.Color.CYAN)
    ui.print_colored("    2 = Audit only (run audit, write report, exit)", ui.Color.CYAN)
    ui.print_colored("    3 = Build only (skip audit, run publish workflow)", ui.Color.CYAN)
    raw = input("  Enter 1, 2, or 3 [1]: ").strip() or "1"
    if raw not in ("1", "2", "3"):
        ui.exit_with_error("Invalid choice. Enter 1, 2, or 3.", ExitCode.USER_CANCELLED)
    mode = int(raw)

    if mode == 2:
        # Audit only: run audit and exit
        audit.run_audit(project_dir)
        ui.print_success("Audit complete. Report path is shown above.")
        return ExitCode.SUCCESS.value

    changelog_path = project_dir / "CHANGELOG.md"
    if not changelog_path.exists():
        ui.exit_with_error(
            f"CHANGELOG.md not found at {changelog_path}",
            ExitCode.PREREQUISITES_FAILED,
        )

    package_name = vc.get_package_name(pubspec_path)
    version = vc.get_version_from_pubspec(pubspec_path)
    branch = workflow.get_current_branch(project_dir)
    remote_url = workflow.get_remote_url(project_dir)

    if not re.match(r"^\d+\.\d+\.\d+$", version):
        ui.exit_with_error(
            f"Invalid version format '{version}'. Use semantic versioning: MAJOR.MINOR.PATCH",
            ExitCode.VALIDATION_FAILED,
        )

    changelog_version = vc.get_latest_changelog_version(changelog_path)
    if changelog_version is None:
        ui.exit_with_error(
            "Could not extract version from CHANGELOG.md", ExitCode.CHANGELOG_FAILED
        )

    if version != changelog_version:
        pubspec_ver = vc.parse_version(version)
        changelog_ver = vc.parse_version(changelog_version)
        if changelog_ver > pubspec_ver:
            ui.print_warning(
                f"Version mismatch: pubspec.yaml has {version}, "
                f"but CHANGELOG.md latest is {changelog_version}."
            )
            ui.print_info(
                f"Updating pubspec.yaml version from {version} to {changelog_version}."
            )
            vc.update_pubspec_version(pubspec_path, changelog_version)
            version = changelog_version
            ui.print_success(f"pubspec.yaml updated to {version}")
        else:
            ui.exit_with_error(
                f"Version mismatch: pubspec.yaml has {version}, "
                f"but CHANGELOG.md latest is {changelog_version}. "
                "Add a CHANGELOG.md entry for the new version before publishing.",
                ExitCode.CHANGELOG_FAILED,
            )

    # Handle [Unreleased] section before proceeding
    if vc.has_unreleased_section(changelog_path):
        existing_notes = vc.validate_changelog_version(project_dir, version)
        if existing_notes is not None:
            # Version already has a CHANGELOG section, so [Unreleased] is for
            # a newer version — offer to bump
            patch_v = vc.bump_patch_version(version)
            minor_v = vc.bump_minor_version(version)
            major_v = vc.bump_major_version(version)
            ui.print_warning(
                f"CHANGELOG has [Unreleased] changes beyond v{version}."
            )
            ui.print_colored("  Choose version bump:", ui.Color.WHITE)
            ui.print_colored(f"    1 = patch  → {patch_v}", ui.Color.CYAN)
            ui.print_colored(f"    2 = minor  → {minor_v}", ui.Color.CYAN)
            ui.print_colored(f"    3 = major  → {major_v}", ui.Color.CYAN)
            ui.print_colored("    n = cancel", ui.Color.CYAN)
            choice = input("  Enter 1, 2, 3, or n [1]: ").strip() or "1"
            if choice == "1":
                next_version = patch_v
            elif choice == "2":
                next_version = minor_v
            elif choice == "3":
                next_version = major_v
            else:
                ui.exit_with_error(
                    "Resolve the [Unreleased] section in CHANGELOG.md "
                    "before publishing.",
                    ExitCode.CHANGELOG_FAILED,
                )
            vc.update_changelog_unreleased(changelog_path, next_version)
            ui.print_success(f"CHANGELOG.md: [Unreleased] → [{next_version}]")
            vc.update_pubspec_version(pubspec_path, next_version)
            ui.print_success(f"pubspec.yaml: {version} → {next_version}")
            version = next_version
        else:
            # No versioned section yet — [Unreleased] IS the release notes
            vc.update_changelog_unreleased(changelog_path, version)
            ui.print_success(f"CHANGELOG.md: [Unreleased] → [{version}]")

    tag_name = f"v{version}"
    res = subprocess.run(
        ["git", "ls-remote", "--tags", "origin", f"refs/tags/{tag_name}"],
        cwd=project_dir,
        capture_output=True,
        text=True,
        shell=platform_mod.get_shell_mode(),
        encoding="utf-8",
        errors="replace",
    )
    if res.returncode == 0 and res.stdout.strip():
        ui.exit_with_error(
            f"Tag {tag_name} already exists on remote. "
            "This version has already been released.\n"
            "  Tip: Add an [Unreleased] section to CHANGELOG.md "
            "to enable automatic version bumping.",
            ExitCode.VALIDATION_FAILED,
        )

    ui.print_header("SAROPA DART UTILS PUBLISHER")
    ui.print_colored("  Package Information:", ui.Color.WHITE)
    ui.print_colored(f"      Name:       {package_name}", ui.Color.CYAN)
    ui.print_colored(f"      Version:    {version}", ui.Color.CYAN)
    ui.print_colored(f"      Tag:        v{version}", ui.Color.CYAN)
    ui.print_colored(f"      Branch:     {branch}", ui.Color.CYAN)
    ui.print_colored(f"      Repository: {remote_url}", ui.Color.CYAN)
    print()

    vc.display_changelog(project_dir)

    # =========================================================================
    # AUDIT PHASE (mode 1 only: run audit, then prompt if errors/warnings)
    # =========================================================================
    if mode == 1:
        findings, report_path = audit.run_audit(project_dir)
        if findings:
            print()
            ui.print_colored("  Audit findings:", ui.Color.YELLOW)
            for category, count in findings.items():
                ui.print_colored(f"      {category}: {count}", ui.Color.YELLOW)
            print()
            ui.print_info(f"Report: {report_path}")
            response = (
                input("  Continue with publish? [y/N] ").strip().lower()
            )
            if not response.startswith("y"):
                ui.exit_with_error(
                    "User chose not to continue after audit.", ExitCode.AUDIT_FAILED
                )
            ui.print_success("Continuing with publish.")

    # =========================================================================
    # WORKFLOW STEPS (mode 1 and 3)
    # =========================================================================
    if not workflow.check_prerequisites(project_dir):
        ui.exit_with_error("Prerequisites check failed", ExitCode.PREREQUISITES_FAILED)

    ok, _ = workflow.check_working_tree(project_dir)
    if not ok:
        ui.exit_with_error(
            "Aborted by user. Commit or stash your changes first.",
            ExitCode.USER_CANCELLED,
        )

    if not workflow.check_remote_sync(project_dir, branch):
        ui.exit_with_error("Remote sync check failed", ExitCode.WORKING_TREE_FAILED)

    if not workflow.format_code(project_dir):
        ui.exit_with_error("Code formatting failed", ExitCode.VALIDATION_FAILED)

    if not workflow.run_tests(project_dir):
        ui.exit_with_error(
            "Tests failed. Fix test failures before publishing.", ExitCode.TEST_FAILED
        )

    if not workflow.run_analysis(project_dir):
        ui.exit_with_error(
            "Static analysis failed. Fix issues before publishing.",
            ExitCode.ANALYSIS_FAILED,
        )

    ok, release_notes = workflow.validate_changelog(project_dir, version)
    if not ok:
        ui.exit_with_error("CHANGELOG validation failed", ExitCode.CHANGELOG_FAILED)

    if not workflow.generate_docs(project_dir):
        ui.exit_with_error(
            "Documentation generation failed", ExitCode.VALIDATION_FAILED
        )

    if not workflow.pre_publish_validation(project_dir):
        ui.exit_with_error(
            "Pre-publish validation failed", ExitCode.VALIDATION_FAILED
        )

    if not workflow.git_commit_and_push(project_dir, version, branch):
        ui.exit_with_error("Git operations failed", ExitCode.GIT_FAILED)

    if not workflow.create_git_tag(project_dir, version):
        ui.exit_with_error("Git tag creation failed", ExitCode.GIT_FAILED)

    if not workflow.publish_to_pubdev(project_dir):
        ui.exit_with_error(
            "Failed to trigger GitHub Actions publish", ExitCode.PUBLISH_FAILED
        )

    gh_success, gh_error = workflow.create_github_release(
        project_dir, version, release_notes
    )

    ui.print_colored("=" * 70, ui.Color.GREEN)
    ui.print_colored(f"  RELEASE v{version} TRIGGERED!", ui.Color.GREEN)
    ui.print_colored("=" * 70, ui.Color.GREEN)
    print()

    repo_path = workflow.extract_repo_path(remote_url)
    ui.print_colored("  Publishing is running on GitHub Actions.", ui.Color.CYAN)
    ui.print_colored("  No personal email will be shown on pub.dev.", ui.Color.GREEN)
    print()
    ui.print_colored("  Monitor progress:", ui.Color.WHITE)
    ui.print_colored(
        f"      GitHub Actions: https://github.com/{repo_path}/actions",
        ui.Color.CYAN,
    )
    ui.print_colored(
        f"      Package:        https://pub.dev/packages/{package_name}",
        ui.Color.CYAN,
    )
    if gh_success:
        ui.print_colored(
            f"      Release:        https://github.com/{repo_path}/releases/tag/v{version}",
            ui.Color.CYAN,
        )
    else:
        print()
        ui.print_warning(f"GitHub release was not created: {gh_error}")
        ui.print_colored("      To create it manually, run:", ui.Color.YELLOW)
        ui.print_colored("          gh auth login", ui.Color.WHITE)
        ui.print_colored(
            f'          gh release create v{version} --title "Release v{version}" --notes-file CHANGELOG.md',
            ui.Color.WHITE,
        )
    print()

    try:
        webbrowser.open(f"https://github.com/{repo_path}/actions")
    except Exception:
        pass

    return ExitCode.SUCCESS.value


if __name__ == "__main__":
    sys.exit(main())

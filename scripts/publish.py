#!/usr/bin/env python3
"""
Publish saropa_dart_utils package to pub.dev and create GitHub release.

This script automates the complete release workflow for a Dart/Flutter package.

  On start you choose:
    1 = Audit + build (run audit then full publish workflow)
    2 = Audit only (run audit, write report, exit)
    3 = Build only (skip audit, run publish workflow only)

  Audit phase (when chosen) - runs BEFORE the publish steps to alert on
  quality issues. Every check's full results are written to the report (the
  log); the top 10 of each category are echoed to the terminal:
    - Code coverage: methods by unit test count (color-coded bar chart)
    - Analyzer: error / warning / info messages
    - Multiline doc headers per method
    - Inline code comments per method (branches / loops / variables)
    - Per-parameter unit test coverage (tests vs. parameter count)
    - Recursion and bad practices (empty catch, etc.)
    - Try/catch usage per method
    - Duplicate Dart class names
    - Other quality checks (file length, params, TODO, exports, etc.)
    - Report written to reports/yyyymmdd/yyyymmdd_HHMMSS_publish_audit.txt
    - If issues remain, prompts ignore / retry / abort:
        ignore = publish anyway, retry = re-run checks, abort = cancel

  Pre-checks (before numbered steps):
    - Validates pubspec.yaml and CHANGELOG.md versions are in sync
    - If CHANGELOG.md has an [Unreleased] section, resolves it:
      - If current version already has notes: offers patch/minor/major bump
      - If no versioned section yet: converts [Unreleased] to version header
    - Strips a "- Unreleased" placeholder off the current version's header
      (e.g. "## [1.1.1] - Unreleased" -> "## [1.1.1]") so the placeholder
      never reaches pub.dev
    - Requires the release section to open with a plain-language intro line and
      pins its "[log]" link to the proposed version's tag; a missing intro
      prompts retry/ignore/abort (default retry)
    - Fails if version tag already exists on remote

  Numbered steps:
    1. Checks prerequisites (flutter, git, gh auth, publish workflow)
    2. Checks working tree status
    3. Checks remote sync
    4. Regenerates CAPABILITIES.md (the per-symbol index) so it ships current;
       the release commit (step 11) stages it automatically. Non-fatal.
    5. Formats code
    6. Runs tests
    7. Runs static analysis
    8. Validates changelog has release notes
    9. Generates documentation with dart doc
    10. Pre-publish validation (dry-run)
    11. Commits and pushes changes
    12. Creates and pushes git tag
    13. Triggers GitHub Actions publish to pub.dev
    14. Creates GitHub release with release notes
    15. Verifies the version actually reached pub.dev (polls the pub.dev API,
        using the workflow run's conclusion as a fast-fail signal). The script
        only exits 0 once pub.dev serves the new version; a workflow that reports
        success while pub.dev got nothing exits PUBLISH_FAILED.

Version:   2.9
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

# How many detail lines per category to echo to the terminal. The full lists are
# always written to the on-disk audit report; the terminal shows only the worst
# few so the operator gets a signal without scrolling past hundreds of lines.
TERMINAL_FINDINGS_LIMIT = 10


def _display_findings_top10(findings: dict[str, list[str]]) -> None:
    """Print the top N detail lines of each finding category to the terminal.

    `findings` maps a category name to its full, worst-first detail list. We
    print the category total, then the first `TERMINAL_FINDINGS_LIMIT` details,
    and a pointer to the report when more were truncated.
    """
    for category, items in findings.items():
        # Header line carries the full count even though we list only the top N.
        ui.print_colored(f"    {category}: {len(items)}", ui.Color.YELLOW)
        for detail in items[:TERMINAL_FINDINGS_LIMIT]:
            ui.print_colored(f"  {detail}", ui.Color.WHITE)
        if len(items) > TERMINAL_FINDINGS_LIMIT:
            hidden = len(items) - TERMINAL_FINDINGS_LIMIT
            ui.print_colored(
                f"        ... and {hidden} more (see report)", ui.Color.CYAN
            )


def run_audit_phase(project_dir: Path) -> None:
    """Run the pre-publish quality audit and act on the operator's choice.

    Loops so "retry" can re-run every check after the operator fixes issues in
    another window. On each pass: run the audit (which also writes the full log
    to disk), and if any quality issues remain, show the top 10 of each category
    and prompt ignore / retry / abort:
      - ignore: proceed with publishing despite the findings.
      - retry:  re-run all checks (pick this after fixing issues).
      - abort:  cancel publication (the default, since it is the safe choice).
    Returns normally only when the audit is clean or the operator ignores it;
    aborting exits the process via `ui.exit_with_error`.
    """
    while True:
        findings, report_path = audit.run_audit(project_dir)
        if not findings:
            ui.print_success("Audit found no quality issues.")
            return

        print()
        ui.print_colored(
            f"  Quality issues found (top {TERMINAL_FINDINGS_LIMIT} per category):",
            ui.Color.YELLOW,
        )
        _display_findings_top10(findings)
        print()
        ui.print_info(f"Full report: {report_path}")

        ui.print_colored("  Choose an action:", ui.Color.WHITE)
        ui.print_colored("    i = ignore (publish anyway)", ui.Color.CYAN)
        ui.print_colored(
            "    r = retry  (re-run checks after you fix the issues)",
            ui.Color.CYAN,
        )
        ui.print_colored("    a = abort  (cancel publication)", ui.Color.CYAN)
        # Default to abort: an empty Enter must not silently ship a flagged build.
        action = input("  Enter i, r, or a [a]: ").strip().lower() or "a"

        if action.startswith("i"):
            ui.print_success("Ignoring audit findings; continuing with publish.")
            return
        if action.startswith("r"):
            ui.print_info("Re-running quality checks...")
            continue
        # Anything else (including the default) aborts publication.
        ui.exit_with_error(
            "User aborted publication after audit.", ExitCode.AUDIT_FAILED
        )


def validate_release_intro_phase(changelog_path: Path, version: str) -> None:
    """Ensure the release section has a human intro and a version-pinned log link.

    The CHANGELOG maintenance note requires every release to open with one
    plain-language line and close with `[log](.../v<version>/CHANGELOG.md)`.
    Two distinct treatments:
      - Log link: mechanical. `update_log_link` rewrites an existing link
        (the [Unreleased] template ships it pointing at `main`) to v{version},
        so only a wholly missing link is flagged here.
      - Intro line: hand-written prose the script cannot synthesize. A missing
        one loops on retry / ignore / abort, defaulting to retry so the operator
        can add it in an editor and re-check without restarting the run.
    Returns when both are present (or the operator ignores); abort exits via
    `ui.exit_with_error`.
    """
    while True:
        # Pin the log link first so a re-check sees the corrected URL; the call
        # also tells us whether any log link exists to pin.
        link_ok = vc.update_log_link(changelog_path, version)
        intro_ok = vc.has_release_intro(changelog_path, version)
        if intro_ok and link_ok:
            ui.print_success(
                f"Release intro and v{version} log link present in CHANGELOG.md."
            )
            return

        print()
        if not intro_ok:
            ui.print_warning(
                f"No plain-language intro line found for v{version} in CHANGELOG.md."
            )
        if not link_ok:
            ui.print_warning(
                f"No [log] link found for v{version} in CHANGELOG.md."
            )
        ui.print_info(
            "Each release opens with one casual, user-facing line, then ends with:"
        )
        ui.print_info(f"  [log]({vc.LOG_LINK_BASE}/v{version}/CHANGELOG.md)")

        ui.print_colored("  Choose an action:", ui.Color.WHITE)
        ui.print_colored(
            "    r = retry  (re-check after you add it in an editor)", ui.Color.CYAN
        )
        ui.print_colored("    i = ignore (publish anyway)", ui.Color.CYAN)
        ui.print_colored("    a = abort  (cancel publication)", ui.Color.CYAN)
        # Default to retry: the intro is hand-written, so the likely next move is
        # to add it and re-check, not to ship without it.
        action = input("  Enter r, i, or a [r]: ").strip().lower() or "r"

        if action.startswith("i"):
            ui.print_warning("Ignoring missing intro/log link; continuing with publish.")
            return
        if action.startswith("a"):
            ui.exit_with_error(
                "User aborted publication: CHANGELOG release intro/log link missing.",
                ExitCode.CHANGELOG_FAILED,
            )
        # Anything else (including the default) re-runs the check.
        ui.print_info("Re-checking CHANGELOG.md...")


def regenerate_capabilities(project_dir: Path) -> None:
    """Regenerate CAPABILITIES.md so the published index reflects the current
    public API.

    Run unconditionally (no staleness gate): any change is picked up by the
    release commit (`git add -A`), so the index can never ship stale. Failure is
    non-fatal — a hiccup in a docs-index regen must not block a release; it is
    surfaced as a warning instead.

    Uses the AST-based `tool/gen_capabilities.dart` (run via `dart run`): the
    Dart analyzer enumerates EVERY public declaration, not just doc-commented
    ones, so the catalog is complete and correctly labeled.
    """
    script = project_dir / "tool" / "gen_capabilities.dart"
    if not script.exists():
        ui.print_warning("tool/gen_capabilities.dart not found; skipping index regen.")
        return
    ui.print_info("Regenerating CAPABILITIES.md index...")
    res = subprocess.run(
        ["dart", "run", "tool/gen_capabilities.dart"],
        cwd=project_dir,
        capture_output=True,
        text=True,
        shell=platform_mod.get_shell_mode(),
        encoding="utf-8",
        errors="replace",
    )
    if res.returncode != 0:
        ui.print_warning(f"Index regeneration failed (continuing): {res.stderr.strip()}")
        return
    ui.print_success(res.stdout.strip() or "CAPABILITIES.md regenerated.")


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

    # Resolve the other unreleased shape: a versioned header that still carries
    # a "- Unreleased" placeholder (e.g. `## [1.1.1] - Unreleased`). This slips
    # past has_unreleased_section (which only matches a bare `[Unreleased]`), so
    # without this strip the placeholder would publish to pub.dev labelling the
    # release as unreleased. Strip it to leave `## [1.1.1]`.
    if vc.strip_unreleased_suffix(changelog_path, version):
        ui.print_success(f"CHANGELOG.md: stripped '- Unreleased' from [{version}]")

    # With the header now pinned to a concrete version, require the release
    # section's human intro line and pin its [log] link to v{version} (the
    # [Unreleased] template ships the link pointing at `main`). A missing intro
    # loops on retry/ignore/abort; the log link is rewritten automatically.
    validate_release_intro_phase(changelog_path, version)

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
    # AUDIT PHASE (mode 1 only: run quality checks, then ignore/retry/abort)
    # =========================================================================
    if mode == 1:
        run_audit_phase(project_dir)

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

    # Regenerate the per-symbol index now (tree is already clean past the
    # working-tree check); the release commit below stages it via `git add -A`.
    regenerate_capabilities(project_dir)

    if not workflow.format_code(project_dir):
        ui.exit_with_error("Code formatting failed", ExitCode.VALIDATION_FAILED)

    if not workflow.run_tests(project_dir):
        ui.exit_with_error(
            "Tests failed. Fix test failures before publishing.", ExitCode.TEST_FAILED
        )

    # run_analysis now fails on WARNING-severity findings, not just errors:
    # `dart pub publish` runs `dart analyze` internally and exits 65 on a single
    # warning, so a warning that passed here previously still blocked the
    # tag-triggered publish (the v1.6.0 whack-a-mole). Matching the semantics
    # locally catches it before the irreversible tag.
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

    # Block until pub.dev actually serves the new version. Pushing the tag only
    # triggers publishing; a green workflow does NOT prove the package landed
    # (the masked exit-65 bug reported success while pub.dev stayed at 1.0.6).
    # This is the gate that makes the script's exit code reflect reality.
    published = workflow.verify_published(project_dir, package_name, version)

    repo_path = workflow.extract_repo_path(remote_url)

    if not published:
        ui.print_colored("=" * 70, ui.Color.RED)
        ui.print_colored(f"  RELEASE v{version} DID NOT REACH PUB.DEV", ui.Color.RED)
        ui.print_colored("=" * 70, ui.Color.RED)
        print()
        ui.print_warning(
            "The git tag and GitHub release exist, but pub.dev does not serve "
            f"{version}. This version is NOT consumed on pub.dev, so it can be "
            "retried once the cause is fixed."
        )
        ui.print_colored("  Next steps:", ui.Color.WHITE)
        ui.print_colored(
            "    1. Open the publish workflow log and fix the reported error.",
            ui.Color.CYAN,
        )
        ui.print_colored(
            f"    2. Re-run it: gh run rerun --failed (or push tag v{version} again).",
            ui.Color.CYAN,
        )
        ui.print_colored(
            f"      Actions: https://github.com/{repo_path}/actions", ui.Color.YELLOW
        )
        ui.print_colored(
            f"      Package: https://pub.dev/packages/{package_name}", ui.Color.YELLOW
        )
        print()
        try:
            webbrowser.open(f"https://github.com/{repo_path}/actions")
        except Exception:
            pass
        return ExitCode.PUBLISH_FAILED.value

    ui.print_colored("=" * 70, ui.Color.GREEN)
    ui.print_colored(f"  RELEASE v{version} PUBLISHED!", ui.Color.GREEN)
    ui.print_colored("=" * 70, ui.Color.GREEN)
    print()

    ui.print_colored("  Confirmed live on pub.dev.", ui.Color.GREEN)
    ui.print_colored("  No personal email is shown on pub.dev.", ui.Color.GREEN)
    print()
    ui.print_colored("  Links:", ui.Color.WHITE)
    ui.print_colored(
        f"      Package:        https://pub.dev/packages/{package_name}/versions/{version}",
        ui.Color.CYAN,
    )
    ui.print_colored(
        f"      GitHub Actions: https://github.com/{repo_path}/actions",
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

    return ExitCode.SUCCESS.value


if __name__ == "__main__":
    sys.exit(main())

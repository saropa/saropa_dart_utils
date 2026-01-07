#!/usr/bin/env python3
"""
Publishes a Dart/Flutter package to pub.dev and creates a corresponding GitHub release.

This script automates the complete release workflow for a Dart/Flutter package:
  1. Runs all tests to ensure code quality
  2. Prompts for the semantic version number
  3. Updates pubspec.yaml with the new version
  4. Extracts release notes from CHANGELOG.md
  5. Publishes the package to pub.dev
  6. Commits and pushes changes to the repository
  7. Creates a Git tag and pushes it
  8. Creates a GitHub release with the extracted notes

The script exits immediately on any error to prevent partial releases.

Prerequisites:
  - Flutter SDK installed and in PATH
  - Git installed and configured
  - GitHub CLI (gh) installed and authenticated
  - Working directory must be a Git repository

Usage:
  python publish_pub_dev.py
  python publish_pub_dev.py --dry-run
  python publish_pub_dev.py --version "1.2.3" --branch "main"

Version:   1.5
Author:    Saropa
Website:   https://saropa.com
Email:     dev.tools@saropa.com
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# ANSI color codes
ESC = "\033"
RESET = f"{ESC}[0m"
CYAN = f"{ESC}[36m"
GREEN = f"{ESC}[32m"
YELLOW = f"{ESC}[33m"
RED = f"{ESC}[31m"


# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================


def show_saropa_logo() -> None:
    """Displays the Saropa 'S' logo in ASCII art with gradient colors."""
    logo = f"""
{ESC}[38;5;208m                               ....{RESET}
{ESC}[38;5;208m                       `-+shdmNMMMMNmdhs+-{RESET}
{ESC}[38;5;209m                    -odMMMNyo/-..````.++:+o+/-{RESET}
{ESC}[38;5;215m                 `/dMMMMMM/`               ``````````{RESET}
{ESC}[38;5;220m                `dMMMMMMMMNdhhhdddmmmNmmddhs+-{RESET}
{ESC}[38;5;226m                /MMMMMMMMMMMMMMMMMMMMMMMMMMMMMNh/{RESET}
{ESC}[38;5;190m              . :sdmNNNNMMMMMNNNMMMMMMMMMMMMMMMMm+{RESET}
{ESC}[38;5;154m              o     `..~~~::~+==+~:/+sdNMMMMMMMMMMMo{RESET}
{ESC}[38;5;118m              m                        .+NMMMMMMMMMN{RESET}
{ESC}[38;5;123m              m+                         :MMMMMMMMMm{RESET}
{ESC}[38;5;87m              /N:                        :MMMMMMMMM/{RESET}
{ESC}[38;5;51m               oNs.                    `+NMMMMMMMMo{RESET}
{ESC}[38;5;45m                :dNy/.              ./smMMMMMMMMm:{RESET}
{ESC}[38;5;39m                 `/dMNmhyso+++oosydNNMMMMMMMMMd/{RESET}
{ESC}[38;5;33m                    .odMMMMMMMMMMMMMMMMMMMMdo-{RESET}
{ESC}[38;5;57m                       `-+shdNNMMMMNNdhs+-{RESET}
{ESC}[38;5;57m                               ````{RESET}
"""
    print(logo)

    # Copyright notice with dynamic year
    current_year = datetime.now().year
    copyright_year = f"2024-{current_year}" if current_year > 2024 else "2024"

    print(f"    {ESC}[38;5;195m© {copyright_year} Saropa. All rights reserved.{RESET}")
    print(f"    {ESC}[38;5;117mhttps://saropa.com{RESET}")

    # Clickable email address for compatible terminals
    email = "dev.tools@saropa.com"
    print(f"\n    {ESC}]8;;mailto:{email}{ESC}\\{email}{ESC}]8;;{ESC}\\\n")


def write_error(message: str) -> None:
    """Writes an error message to stderr."""
    print(f"{RED}ERROR: {message}{RESET}", file=sys.stderr)


def write_warning(message: str) -> None:
    """Writes a warning message."""
    print(f"{YELLOW}WARNING: {message}{RESET}")


def write_success(message: str) -> None:
    """Writes a success message."""
    print(f"{GREEN}{message}{RESET}")


def write_section(title: str) -> None:
    """Writes a section header to the console for visual clarity."""
    print()
    print(f"{CYAN}=== {title} ==={RESET}")


def run_command(
    args: list[str],
    capture_output: bool = False,
    check: bool = True,
    suppress_stderr: bool = False,
) -> subprocess.CompletedProcess:
    """Runs a command and returns the result."""
    stderr = subprocess.DEVNULL if suppress_stderr else None
    return subprocess.run(
        args,
        capture_output=capture_output,
        text=True,
        check=check,
        stderr=stderr if not capture_output else None,
    )


def exit_on_error(result: subprocess.CompletedProcess, message: str) -> None:
    """Exits the script with an error message if a command failed."""
    if result.returncode != 0:
        write_error(f"FAILED: {message} (exit code: {result.returncode})")
        sys.exit(result.returncode)


def assert_command_exists(command: str, install_hint: str = "") -> None:
    """Checks that a required command-line tool is available."""
    if shutil.which(command) is None:
        hint = f" {install_hint}" if install_hint else ""
        write_error(f"Required command '{command}' not found.{hint}")
        sys.exit(1)


def read_file(path: Path) -> str:
    """Reads and returns the contents of a file."""
    return path.read_text(encoding="utf-8")


def prompt_yes_no(message: str) -> bool:
    """Prompts the user for a yes/no response."""
    response = input(f"{message} (y/n): ").strip().lower()
    return response == "y"


# ==============================================================================
# MAIN SCRIPT EXECUTION
# ==============================================================================


def main() -> None:
    """Main entry point for the publish script."""
    # Parse command-line arguments
    parser = argparse.ArgumentParser(
        description="Publish a Dart/Flutter package to pub.dev and create a GitHub release."
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Perform all validation steps but skip actual publishing, commits, and releases.",
    )
    parser.add_argument(
        "--version",
        type=str,
        default="",
        help="Version number to publish. If not specified, reads from pubspec.yaml.",
    )
    parser.add_argument(
        "--branch",
        type=str,
        default="",
        help="Branch name to push to. If not specified, uses the current branch.",
    )
    args = parser.parse_args()

    dry_run = args.dry_run
    version = args.version
    branch = args.branch

    # Display ASCII art logo
    show_saropa_logo()

    # Show dry-run mode warning if applicable
    if dry_run:
        print()
        print(f"{YELLOW}[DRY RUN MODE] No changes will be made.{RESET}")
        print()

    # --------------------------------------------------------------------------
    # Step 1: Prerequisite Checks
    # --------------------------------------------------------------------------
    write_section("Checking Prerequisites")

    assert_command_exists("flutter", "Install from https://flutter.dev")
    assert_command_exists("git", "Install from https://git-scm.com")
    assert_command_exists("gh", "Install from https://cli.github.com")

    write_success("All required tools are available.")

    # --------------------------------------------------------------------------
    # Step 2: Set Working Directory
    # --------------------------------------------------------------------------
    write_section("Setting Up Environment")

    script_dir = Path(__file__).resolve().parent
    working_dir = script_dir.parent

    if not working_dir.exists():
        write_error(f"Working directory not found: {working_dir}")
        sys.exit(1)

    os.chdir(working_dir)
    print(f"Working directory: {working_dir}")

    # Verify required files exist
    if not Path("pubspec.yaml").exists():
        write_error(f"pubspec.yaml not found in {working_dir}")
        sys.exit(1)
    if not Path("CHANGELOG.md").exists():
        write_error(f"CHANGELOG.md not found in {working_dir}")
        sys.exit(1)

    # Verify we're in a git repository
    if not Path(".git").exists():
        write_error("Not a git repository. Initialize with 'git init' first.")
        sys.exit(1)

    # Determine branch to use
    if not branch:
        result = run_command(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True
        )
        exit_on_error(result, "Failed to determine current branch")
        branch = result.stdout.strip()
    print(f"Target branch: {branch}")

    # Extract package name from pubspec.yaml
    pubspec_content = read_file(Path("pubspec.yaml"))
    name_match = re.search(r"^name:\s*(.+)$", pubspec_content, re.MULTILINE)
    if not name_match:
        write_error("Could not extract package name from pubspec.yaml")
        sys.exit(1)
    package_name = name_match.group(1).strip()
    print(f"Package name: {package_name}")

    # --------------------------------------------------------------------------
    # Step 3: Check Working Tree Status
    # --------------------------------------------------------------------------
    write_section("Checking Working Tree")

    result = run_command(["git", "status", "--porcelain"], capture_output=True)
    uncommitted_changes = result.stdout.strip()

    if uncommitted_changes:
        write_warning("You have uncommitted changes:")
        print(f"{YELLOW}{uncommitted_changes}{RESET}")
        print()
        if not prompt_yes_no(
            "These changes will be included in the release commit. Continue?"
        ):
            print(f"{YELLOW}Aborted by user. Commit or stash your changes first.{RESET}")
            sys.exit(0)
    else:
        write_success("Working tree is clean.")

    # --------------------------------------------------------------------------
    # Step 4: Check Remote Sync Status
    # --------------------------------------------------------------------------
    write_section("Checking Remote Sync")

    # Fetch latest from remote
    fetch_result = run_command(
        ["git", "fetch", "origin", branch],
        capture_output=True,
        check=False,
        suppress_stderr=True,
    )

    if fetch_result.returncode == 0:
        behind_result = run_command(
            ["git", "rev-list", "--count", f"HEAD..origin/{branch}"],
            capture_output=True,
            check=False,
        )
        if behind_result.returncode == 0:
            behind = behind_result.stdout.strip()
            if behind and int(behind) > 0:
                write_error(
                    f"Local branch is behind remote by {behind} commit(s). "
                    f"Pull changes first with: git pull origin {branch}"
                )
                sys.exit(1)
        write_success("Local branch is up-to-date with remote.")
    else:
        write_warning(
            "Could not fetch from remote. Proceeding anyway (remote branch may not exist yet)."
        )

    # --------------------------------------------------------------------------
    # Step 5: Run Tests
    # --------------------------------------------------------------------------
    write_section("Running Tests")

    result = run_command(["flutter", "test"], check=False)
    exit_on_error(result, "Tests failed. Fix test failures before publishing.")

    write_success("All tests passed.")

    # --------------------------------------------------------------------------
    # Step 6: Run Static Analysis
    # --------------------------------------------------------------------------
    write_section("Running Static Analysis")

    result = run_command(["flutter", "analyze"], check=False)
    exit_on_error(result, "Static analysis found issues. Fix them before publishing.")

    write_success("Static analysis passed.")

    # --------------------------------------------------------------------------
    # Step 7: Determine Release Version
    # --------------------------------------------------------------------------
    write_section("Release Version")

    # Use provided version or read from pubspec.yaml
    if version:
        release_number = version
        print(f"Using provided version: {release_number}")
    else:
        # Read version from pubspec.yaml
        version_match = re.search(r"^version:\s*(.+)$", pubspec_content, re.MULTILINE)
        if not version_match:
            write_error("Could not extract version from pubspec.yaml")
            sys.exit(1)
        release_number = version_match.group(1).strip()
        print(f"Read version from pubspec.yaml: {release_number}")

    # Validate semantic version format
    if not re.match(r"^\d+\.\d+\.\d+$", release_number):
        write_error(
            f"Invalid version format '{release_number}'. "
            "Use semantic versioning: MAJOR.MINOR.PATCH (e.g., 0.4.0)"
        )
        sys.exit(1)

    write_success(f"Version to publish: {release_number}")

    # --------------------------------------------------------------------------
    # Step 8: Validate and Extract Release Notes from CHANGELOG
    # --------------------------------------------------------------------------
    write_section("Validating CHANGELOG")

    changelog_content = read_file(Path("CHANGELOG.md"))

    # Check if the version exists in CHANGELOG at all (early validation)
    version_header_pattern = rf"##\s*\[?{re.escape(release_number)}\]?"
    if not re.search(version_header_pattern, changelog_content):
        write_error(
            f"Version {release_number} not found in CHANGELOG.md. "
            "Add release notes before publishing."
        )
        sys.exit(1)

    write_success(f"Found version {release_number} in CHANGELOG.md")

    # Extract notes for this specific version
    # Pattern matches content between this version's header and the next version header
    pattern = rf"(?s)##\s*\[?{re.escape(release_number)}\]?[^\n]*\n(.*?)(?=##\s*\[?\d+\.\d+\.\d+|$)"
    match = re.search(pattern, changelog_content)

    release_notes = match.group(1).strip() if match else ""

    if not release_notes:
        write_warning(
            f"Version header found but no release notes content for version {release_number}."
        )
        if not prompt_yes_no(f"Use generic message 'Release {release_number}'?"):
            write_error(
                "Aborting. Please add release notes content to CHANGELOG.md first."
            )
            sys.exit(1)
        release_notes = f"Release {release_number}"
    else:
        print(f"{CYAN}Release notes preview:{RESET}")
        print(release_notes)

    # --------------------------------------------------------------------------
    # Step 9: Generate Documentation
    # --------------------------------------------------------------------------
    write_section("Generating Documentation")

    if dry_run:
        print(f"{YELLOW}[DRY RUN] Would run: dart doc{RESET}")
    else:
        result = run_command(["dart", "doc"], check=False)
        exit_on_error(result, "Documentation generation failed")
        write_success("Documentation generated successfully.")

    # --------------------------------------------------------------------------
    # Step 10: Pre-publish Validation
    # --------------------------------------------------------------------------
    write_section("Pre-publish Validation")

    if dry_run:
        print(f"{YELLOW}[DRY RUN] Would run: flutter pub publish --dry-run{RESET}")
    else:
        print("Running pre-publish validation...")
        result = run_command(["flutter", "pub", "publish", "--dry-run"], check=False)
        exit_on_error(
            result, "Pre-publish validation failed. Fix issues before publishing."
        )
        write_success("Pre-publish validation passed.")

    # --------------------------------------------------------------------------
    # Step 11: Confirm and Publish
    # --------------------------------------------------------------------------
    write_section("Publish Confirmation")

    # Get repository URL
    repo_url_result = run_command(
        ["git", "remote", "get-url", "origin"], capture_output=True, check=False
    )
    repo_url = repo_url_result.stdout.strip() if repo_url_result.returncode == 0 else ""

    print()
    print(f"{CYAN}Ready to publish:{RESET}")
    print(f"  Package:    {package_name}")
    print(f"  Version:    {release_number}")
    print(f"  Tag:        v{release_number}")
    print(f"  Branch:     {branch}")
    print(f"  Repository: {repo_url}")
    print()

    if not prompt_yes_no("Publish to pub.dev and create GitHub release?"):
        print(f"{YELLOW}Publish cancelled by user.{RESET}")
        sys.exit(0)

    # --------------------------------------------------------------------------
    # Step 12: Clean and Publish to pub.dev
    # --------------------------------------------------------------------------
    write_section("Publishing to pub.dev")

    tag_name = f"v{release_number}"

    if dry_run:
        print(f"{YELLOW}[DRY RUN] Would run: flutter clean{RESET}")
        print(f"{YELLOW}[DRY RUN] Would run: flutter pub publish --force{RESET}")
    else:
        result = run_command(["flutter", "clean"], check=False)
        exit_on_error(result, "flutter clean failed")

        print(f"Publishing version {release_number} to pub.dev...")
        result = run_command(["flutter", "pub", "publish", "--force"], check=False)
        exit_on_error(result, "Failed to publish package to pub.dev")

        write_success("Package published to pub.dev successfully.")

    # --------------------------------------------------------------------------
    # Step 13: Git Commit and Push
    # --------------------------------------------------------------------------
    write_section("Committing Changes")

    if dry_run:
        print(f"{YELLOW}[DRY RUN] Would run: git add -A{RESET}")
        print(f"{YELLOW}[DRY RUN] Would run: git commit -m 'Release {tag_name}'{RESET}")
        print(f"{YELLOW}[DRY RUN] Would run: git push origin {branch}{RESET}")
    else:
        result = run_command(["git", "add", "-A"], check=False)
        exit_on_error(result, "git add failed")

        # Check if there are changes to commit
        status_result = run_command(
            ["git", "status", "--porcelain"], capture_output=True
        )
        git_status = status_result.stdout.strip()

        if git_status:
            result = run_command(
                ["git", "commit", "-m", f"Release {tag_name}"], check=False
            )
            exit_on_error(result, "git commit failed")

            result = run_command(["git", "push", "origin", branch], check=False)
            exit_on_error(result, "git push failed")

            write_success(f"Changes committed and pushed to {branch}.")
        else:
            print(f"{YELLOW}No changes to commit. Skipping commit step.{RESET}")

    # --------------------------------------------------------------------------
    # Step 14: Create and Push Git Tag
    # --------------------------------------------------------------------------
    write_section("Creating Git Tag")

    if dry_run:
        print(
            f"{YELLOW}[DRY RUN] Would run: git tag -a {tag_name} -m 'Release {tag_name}'{RESET}"
        )
        print(f"{YELLOW}[DRY RUN] Would run: git push origin {tag_name}{RESET}")
    else:
        # Check if tag already exists locally
        tag_exists_result = run_command(
            ["git", "tag", "-l", tag_name], capture_output=True
        )
        tag_exists = tag_exists_result.stdout.strip()

        if tag_exists:
            print(
                f"{YELLOW}Tag {tag_name} already exists locally. Skipping tag creation.{RESET}"
            )
        else:
            result = run_command(
                ["git", "tag", "-a", tag_name, "-m", f"Release {tag_name}"], check=False
            )
            exit_on_error(result, "git tag creation failed")
            write_success(f"Tag {tag_name} created.")

        # Check if tag exists on remote, push if not
        remote_tag_result = run_command(
            ["git", "ls-remote", "--tags", "origin", tag_name],
            capture_output=True,
            check=False,
        )
        remote_tag_exists = remote_tag_result.stdout.strip()

        if remote_tag_exists:
            print(
                f"{YELLOW}Tag {tag_name} already exists on remote. Skipping push.{RESET}"
            )
        else:
            result = run_command(["git", "push", "origin", tag_name], check=False)
            exit_on_error(result, "git push tag failed")
            write_success(f"Tag {tag_name} pushed to remote.")

    # --------------------------------------------------------------------------
    # Step 15: Create GitHub Release
    # --------------------------------------------------------------------------
    write_section("Creating GitHub Release")

    if dry_run:
        print(f"{YELLOW}[DRY RUN] Would run: gh release create {tag_name}{RESET}")
    else:
        # Check if release already exists
        release_exists = False
        check_result = run_command(
            ["gh", "release", "view", tag_name],
            capture_output=True,
            check=False,
        )
        if check_result.returncode == 0:
            release_exists = True

        if release_exists:
            print(
                f"{YELLOW}GitHub release {tag_name} already exists. Skipping release creation.{RESET}"
            )
        else:
            result = run_command(
                [
                    "gh",
                    "release",
                    "create",
                    tag_name,
                    "--title",
                    f"Release {tag_name}",
                    "--notes",
                    release_notes,
                ],
                check=False,
            )
            exit_on_error(result, "Failed to create GitHub release")
            write_success("GitHub release created successfully.")

    # --------------------------------------------------------------------------
    # Complete
    # --------------------------------------------------------------------------
    print()
    print(f"{GREEN}========================================{RESET}")
    if dry_run:
        print(f"{YELLOW} DRY RUN COMPLETE - No changes made{RESET}")
    else:
        print(f"{GREEN} RELEASE {release_number} COMPLETE!{RESET}")
    print(f"{GREEN}========================================{RESET}")
    print()

    if not dry_run:
        # Extract repo info from git remote
        repo_path = "owner/repo"
        if repo_url:
            repo_match = re.search(r"github\.com[:/](.+?)(?:\.git)?$", repo_url)
            if repo_match:
                repo_path = repo_match.group(1)

        print("Next steps:")
        print(f"  - Verify package at: https://pub.dev/packages/{package_name}")
        print(f"  - Check release at:  https://github.com/{repo_path}/releases/tag/{tag_name}")


if __name__ == "__main__":
    main()

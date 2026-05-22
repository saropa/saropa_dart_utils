"""Publish workflow steps: prerequisites, git, format, test, analyze, release."""

import re
import shutil
import subprocess
import time
from pathlib import Path

from . import platform as platform_mod
from . import run as run_mod
from . import ui
from . import version_changelog as vc


def check_prerequisites(project_dir: Path) -> bool:
    """Check that required tools are available and authenticated."""
    ui.print_header("STEP 1: CHECKING PREREQUISITES")

    tools = [
        ("flutter", "Install from https://flutter.dev"),
        ("git", "Install from https://git-scm.com"),
        ("gh", "Install from https://cli.github.com"),
    ]

    all_found = True
    for tool, hint in tools:
        if run_mod.command_exists(tool):
            ui.print_success(f"{tool} found")
        else:
            ui.print_error(f"{tool} not found. {hint}")
            all_found = False

    if not all_found:
        return False

    result = run_mod.run_capture(["gh", "auth", "status"], project_dir)
    if result.returncode != 0:
        ui.print_error("GitHub CLI is not authenticated.")
        ui.print_info("Run 'gh auth login' to authenticate.")
        error_output = (result.stderr or "") + (result.stdout or "")
        if "GITHUB_TOKEN" in error_output:
            ui.print_info(
                "If GITHUB_TOKEN env var is set but invalid, clear it first:\n"
                '      PowerShell: $env:GITHUB_TOKEN = ""\n'
                "      Bash: unset GITHUB_TOKEN"
            )
        return False
    ui.print_success("gh authenticated")

    workflow_path = project_dir / ".github" / "workflows" / "publish.yml"
    if not workflow_path.exists():
        workflow_path = project_dir / ".github" / "workflows" / "publish.yaml"
    if workflow_path.exists():
        ui.print_success(f"Publish workflow found ({workflow_path.name})")
    else:
        ui.print_error("No publish workflow found at .github/workflows/publish.yml")
        ui.print_info(
            "Publishing relies on GitHub Actions. Add a publish workflow before releasing."
        )
        return False

    return True


def check_working_tree(project_dir: Path) -> tuple[bool, bool]:
    """Check working tree status. Returns (ok, has_uncommitted_changes)."""
    ui.print_header("STEP 2: CHECKING WORKING TREE")

    result = run_mod.run_capture(["git", "status", "--porcelain"], project_dir)

    if result.stdout.strip():
        ui.print_warning("You have uncommitted changes:")
        ui.print_colored(result.stdout, ui.Color.YELLOW)
        print()
        response = (
            input(
                "  These changes will be included in the release commit. Continue? [y/N] "
            )
            .strip()
            .lower()
        )
        if not response.startswith("y"):
            return False, True
        return True, True

    ui.print_success("Working tree is clean")
    return True, False


def check_remote_sync(project_dir: Path, branch: str) -> bool:
    """Check if local branch is in sync with remote."""
    ui.print_header("STEP 3: CHECKING REMOTE SYNC")

    result = run_mod.run_capture(["git", "fetch", "origin", branch], project_dir)
    if result.returncode != 0:
        ui.print_warning(
            "Could not fetch from remote. Proceeding anyway (remote branch may not exist yet)."
        )
        return True

    result = run_mod.run_capture(
        ["git", "rev-list", "--count", f"HEAD..origin/{branch}"], project_dir
    )
    if result.returncode == 0 and result.stdout.strip():
        behind_count = int(result.stdout.strip())
        if behind_count > 0:
            ui.print_error(f"Local branch is behind remote by {behind_count} commit(s).")
            ui.print_info(f"Pull changes first with: git pull origin {branch}")
            return False

    result = run_mod.run_capture(
        ["git", "rev-list", "--count", f"origin/{branch}..HEAD"], project_dir
    )
    if result.returncode == 0 and result.stdout.strip():
        ahead_count = int(result.stdout.strip())
        if ahead_count > 0:
            ui.print_warning(f"You have {ahead_count} unpushed commit(s) that will be included.")
            ui.print_success("Local branch is ahead of remote (will push with release)")
            return True

    ui.print_success("Local branch is in sync with remote")
    return True


def format_code(project_dir: Path) -> bool:
    """Format code with dart format."""
    ui.print_header("STEP 4: FORMATTING CODE")

    result = run_mod.run_command(
        ["dart", "format", "."], project_dir, "Formatting code", capture_output=True
    )

    if result.returncode != 0:
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
        return False

    status = run_mod.run_capture(["git", "status", "--porcelain"], project_dir)
    if status.stdout.strip():
        ui.print_info("Files were formatted - will be included in commit")
    else:
        ui.print_success("All files already formatted")

    return True


def run_tests(project_dir: Path) -> bool:
    """Run flutter test. Retries once on Flutter cache lock (file in use)."""
    ui.print_header("STEP 5: RUNNING TESTS")

    test_dir = project_dir / "test"
    if not test_dir.exists():
        ui.print_warning("No test directory found, skipping unit tests")
        return True

    max_attempts = 2
    lock_hint = (
        "Another process is using Flutter's cache (e.g. flutter_tester.exe). "
        "Close other Flutter/Dart processes or IDE test runs and retry."
    )

    for attempt in range(1, max_attempts + 1):
        result = run_mod.run_command(
            ["flutter", "test"], project_dir, "Running unit tests", capture_output=True
        )
        if result.returncode == 0:
            return True

        out = (result.stdout or "") + (result.stderr or "")
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)

        is_lock = "being used by another process" in out or "PathAccessException" in out
        if is_lock and attempt < max_attempts:
            ui.print_warning(lock_hint)
            ui.print_info(f"Retrying in 5 seconds (attempt {attempt + 1}/{max_attempts})...")
            time.sleep(5)
            continue

        if is_lock:
            ui.print_error(lock_hint)
        return False

    return False


def run_analysis(project_dir: Path) -> bool:
    """Run flutter analyze. Fails only on errors, warns on warnings/infos."""
    ui.print_header("STEP 6: RUNNING STATIC ANALYSIS")

    result = run_mod.run_command(
        ["flutter", "analyze"],
        project_dir,
        "Analyzing code",
        capture_output=True,
        allow_failure=True,
    )

    output = (result.stdout or "") + (result.stderr or "")

    if result.returncode == 0:
        ui.print_success("No analysis issues found")
        return True

    # Count severity levels from analyzer output lines
    error_count = 0
    warning_count = 0
    info_count = 0
    for line in output.splitlines():
        stripped = line.strip().lower()
        if stripped.startswith("error"):
            error_count += 1
        elif stripped.startswith("warning"):
            warning_count += 1
        elif stripped.startswith("info"):
            info_count += 1

    if error_count > 0:
        print(output)
        ui.print_error(
            f"Analysis found {error_count} error(s), "
            f"{warning_count} warning(s), {info_count} info(s)"
        )
        return False

    # Non-zero exit but no issues parsed — flutter itself errored
    if warning_count == 0 and info_count == 0:
        print(output)
        ui.print_error("Analyzer exited with an error (not a lint issue)")
        return False

    ui.print_warning(
        f"Analysis found {warning_count} warning(s) and "
        f"{info_count} info(s) (no errors)"
    )
    ui.print_success("No errors found — warnings/infos will not block publish")
    return True


def validate_changelog(project_dir: Path, version: str) -> tuple[bool, str]:
    """Validate version exists in CHANGELOG and get release notes."""
    ui.print_header("STEP 7: VALIDATING CHANGELOG")

    release_notes = vc.validate_changelog_version(project_dir, version)

    if release_notes is None:
        ui.print_error(f"Version {version} not found in CHANGELOG.md")
        ui.print_info("Add release notes before publishing.")
        return False, ""

    ui.print_success(f"Found version {version} in CHANGELOG.md")

    if not release_notes:
        ui.print_warning("Version header found but no release notes content.")
        response = (
            input(f"  Use generic message 'Release {version}'? [y/N] ").strip().lower()
        )
        if not response.startswith("y"):
            return False, ""
        release_notes = f"Release {version}"
    else:
        ui.print_colored("  Release notes preview:", ui.Color.CYAN)
        for line in release_notes.split("\n")[:10]:
            ui.print_colored(f"    {line}", ui.Color.WHITE)
        if release_notes.count("\n") > 10:
            ui.print_colored("    ...", ui.Color.WHITE)

    return True, release_notes


# dartdoc (through at least 9.0.4) crashes with a `RangeError` inside
# `_stripDocImports` when a doc comment contains an `@docImport` directive AND the
# source file uses CRLF (\r\n) line endings. dartdoc strips the `\r` from the
# comment text but computes the directive's slice index from the analyzer's source
# offsets, which still count the `\r` — so the index overshoots the stripped
# string (the reported "Invalid value ... 0..9089: 9202" is exactly that overshoot,
# the gap being the number of CRLF newlines in the comment). The Flutter framework
# now uses `@docImport` in 500+ files; if the Flutter SDK was cloned with git
# `core.autocrlf=true`, every Flutter `.dart` file is CRLF on disk and `dart doc`
# dies while precaching Flutter's docs — long before it ever reaches this package's
# own comments. It is therefore a LOCAL environment fault, not a package defect:
# pub.dev rebuilds docs on Linux (LF), so the published package is unaffected.
_DARTDOC_CRLF_FRAME = "_stripDocImports"


def _is_dartdoc_crlf_crash(output: str) -> bool:
    """True when `dart doc` output is the known CRLF/@docImport RangeError crash."""
    if not output:
        return False
    # The frame name is the precise signature; fall back to the RangeError-in-
    # comment-processing combo in case a dartdoc version shifts the frame label.
    if _DARTDOC_CRLF_FRAME in output:
        return True
    return "RangeError" in output and "documentation_comment.dart" in output


def _flutter_sdk_root() -> Path | None:
    """Locate the Flutter SDK root from the `flutter` launcher on PATH.

    `flutter` resolves to `<sdk>/bin/flutter(.bat)`, so the SDK root is two levels
    up. Returns None when Flutter is not on PATH (the diagnostic just omits the
    SDK-specific remediation in that case).
    """
    launcher = shutil.which("flutter")
    if not launcher:
        return None
    return Path(launcher).resolve().parent.parent


def _flutter_sdk_has_crlf(sdk_root: Path) -> bool:
    """True when a representative Flutter framework `.dart` file is CRLF on disk.

    We probe one well-known framework file rather than scanning the whole SDK: if
    the checkout was line-ending-polluted at clone time, every tracked file shares
    the same conversion, so one probe is a reliable signal.
    """
    probe = (
        sdk_root / "packages" / "flutter" / "lib" / "src" / "widgets" / "framework.dart"
    )
    try:
        return b"\r\n" in probe.read_bytes()
    except OSError:
        return False


def _report_dartdoc_crlf_bug() -> None:
    """Explain the known dartdoc CRLF/@docImport crash and the one-time SDK fix.

    Called only after `dart doc` failed with the `_stripDocImports` RangeError. We
    let the publish continue (the package is fine) but tell the operator exactly
    why local docs failed and how to clear it permanently.
    """
    ui.print_warning("dart doc hit the known dartdoc RangeError in _stripDocImports.")
    ui.print_info(
        "Cause: CRLF line endings in the Flutter SDK source + @docImport directives "
        "trip a dartdoc offset bug while precaching Flutter's own docs."
    )
    ui.print_info(
        "This is a LOCAL environment issue, not a package defect: pub.dev rebuilds "
        "docs on Linux (LF), so publishing is unaffected."
    )

    sdk_root = _flutter_sdk_root()
    if sdk_root and _flutter_sdk_has_crlf(sdk_root):
        sdk = sdk_root.as_posix()
        ui.print_warning(f"Flutter SDK has CRLF .dart files: {sdk}")
        ui.print_colored(
            "  One-time fix (renormalizes the SDK checkout to LF):", ui.Color.WHITE
        )
        # Use `input`, NOT `false`: on Windows `core.autocrlf=false` falls back to
        # `core.eol=native` (CRLF), so it would re-introduce CRLF on the reset below.
        # `input` normalizes commits to LF and never converts on checkout.
        ui.print_colored("      git config --global core.autocrlf input", ui.Color.CYAN)
        ui.print_colored(f'      git -C "{sdk}" rm --cached -rq .', ui.Color.CYAN)
        ui.print_colored(f'      git -C "{sdk}" reset --hard', ui.Color.CYAN)
        ui.print_colored(
            "  (reset --hard discards uncommitted SDK edits; check `git status` first.)",
            ui.Color.WHITE,
        )
    # Local doc validation is skipped until the SDK is renormalized; flag it so the
    # operator knows this step gave no signal about THIS package's own dartdoc.
    ui.print_warning("Local doc validation skipped (SDK crash precedes this package).")
    ui.print_success("Continuing with publish.")


def generate_docs(project_dir: Path) -> bool:
    """Generate documentation with dart doc.

    Returns True on success, and also True (with a clear diagnostic) when the only
    failure is the known dartdoc CRLF/@docImport `RangeError` originating in the
    Flutter SDK source — that crash is a local-environment fault and must not abort
    a publish, since pub.dev rebuilds the docs server-side on LF. Any OTHER
    `dart doc` failure is a real problem and returns False so the caller aborts.
    """
    ui.print_header("STEP 8: GENERATING DOCUMENTATION")

    # Use run_capture (not run_command) so we own the messaging: on the CRLF crash
    # we suppress dartdoc's alarming stack trace and the misleading "failed" line,
    # and explain the real, harmless cause instead.
    ui.print_info("Generating documentation...")
    ui.print_colored("      $ dart doc", ui.Color.WHITE)
    result = run_mod.run_capture(["dart", "doc"], project_dir)
    if result.returncode == 0:
        ui.print_success("Documentation generated")
        return True

    combined = f"{result.stdout or ''}\n{result.stderr or ''}"
    if not _is_dartdoc_crlf_crash(combined):
        # An unrecognized doc failure: surface dartdoc's output and fail hard so a
        # genuine documentation problem still blocks the release.
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
        ui.print_error(
            f"Documentation generation failed (exit code {result.returncode})"
        )
        return False

    _report_dartdoc_crlf_bug()
    return True


def pre_publish_validation(project_dir: Path) -> bool:
    """Run flutter pub publish --dry-run silently."""
    ui.print_header("STEP 9: PRE-PUBLISH VALIDATION")

    if platform_mod.is_windows():
        ui.print_warning(
            "Skipping dry-run validation on Windows (known Flutter SDK bug)."
        )
        ui.print_info("Validation will occur during actual publish.")
        return True

    ui.print_info("Running pre-publish validation...")
    result = run_mod.run_capture(
        ["flutter", "pub", "publish", "--dry-run"], project_dir
    )

    if result.returncode in (0, 65):
        ui.print_success("Package validated successfully")
        return True

    ui.print_error("Pre-publish validation failed:")
    if result.stdout:
        print(result.stdout)
    if result.stderr:
        print(result.stderr)
    return False


def git_commit_and_push(project_dir: Path, version: str, branch: str) -> bool:
    """Commit changes and push to remote."""
    ui.print_header("STEP 10: COMMITTING AND PUSHING CHANGES")

    tag_name = f"v{version}"

    result = run_mod.run_command(["git", "add", "-A"], project_dir, "Staging changes")
    if result.returncode != 0:
        return False

    status = run_mod.run_capture(["git", "status", "--porcelain"], project_dir)
    if status.stdout.strip():
        result = run_mod.run_command(
            ["git", "commit", "-m", f"Release {tag_name}"],
            project_dir,
            f"Committing: Release {tag_name}",
        )
        if result.returncode != 0:
            return False
        result = run_mod.run_command(
            ["git", "push", "origin", branch], project_dir, f"Pushing to {branch}"
        )
        if result.returncode != 0:
            return False
    else:
        ui.print_warning("No changes to commit. Skipping commit step.")

    return True


def create_git_tag(project_dir: Path, version: str) -> bool:
    """Create and push git tag."""
    ui.print_header("STEP 11: CREATING GIT TAG")

    tag_name = f"v{version}"

    result = run_mod.run_capture(["git", "tag", "-l", tag_name], project_dir)
    if result.stdout.strip():
        ui.print_warning(f"Tag {tag_name} already exists locally. Skipping tag creation.")
    else:
        result = run_mod.run_command(
            ["git", "tag", "-a", tag_name, "-m", f"Release {tag_name}"],
            project_dir,
            f"Creating tag {tag_name}",
        )
        if result.returncode != 0:
            return False

    result = run_mod.run_capture(
        ["git", "ls-remote", "--tags", "origin", tag_name], project_dir
    )
    if result.stdout.strip():
        ui.print_warning(f"Tag {tag_name} already exists on remote. Skipping push.")
    else:
        result = run_mod.run_command(
            ["git", "push", "origin", tag_name],
            project_dir,
            f"Pushing tag {tag_name}",
        )
        if result.returncode != 0:
            return False

    return True


def publish_to_pubdev(project_dir: Path) -> bool:
    """Notify that publishing happens via GitHub Actions."""
    ui.print_header("STEP 12: PUBLISHING TO PUB.DEV VIA GITHUB ACTIONS")

    ui.print_success("Tag push triggered GitHub Actions publish workflow!")
    print()
    ui.print_colored(
        "  Publishing is now running automatically on GitHub Actions.", ui.Color.CYAN
    )
    ui.print_colored("  No personal email will be shown on pub.dev.", ui.Color.GREEN)
    print()

    remote_url = get_remote_url(project_dir)
    repo_path = extract_repo_path(remote_url)
    ui.print_colored(
        f"  Monitor progress at: https://github.com/{repo_path}/actions", ui.Color.CYAN
    )
    print()

    return True


def create_github_release(
    project_dir: Path, version: str, release_notes: str
) -> tuple[bool, str | None]:
    """Create GitHub release using gh CLI. Returns (success, error_message)."""
    ui.print_header("STEP 13: CREATING GITHUB RELEASE")

    tag_name = f"v{version}"

    result = run_mod.run_capture(["gh", "release", "view", tag_name], project_dir)
    if result.returncode == 0:
        ui.print_warning(
            f"GitHub release {tag_name} already exists. Skipping release creation."
        )
        return True, None

    result = run_mod.run_capture(
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
        project_dir,
    )

    if result.returncode == 0:
        ui.print_success(f"Created GitHub release {tag_name}")
        return True, None

    error_output = (result.stderr or "") + (result.stdout or "")
    if (
        "401" in error_output
        or "Bad credentials" in error_output
        or "authentication" in error_output.lower()
    ):
        return False, (
            "GitHub CLI auth failed. If GITHUB_TOKEN env var is set, clear it first:\n"
            '      PowerShell: $env:GITHUB_TOKEN = ""\n'
            "      Bash: unset GITHUB_TOKEN\n"
            "      Then run: gh auth status"
        )

    return False, f"GitHub release failed (exit code {result.returncode})"


def get_current_branch(project_dir: Path) -> str:
    """Get the current git branch name."""
    result = run_mod.run_capture(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"], project_dir
    )
    if result.returncode == 0:
        return result.stdout.strip()
    return "main"


def get_remote_url(project_dir: Path) -> str:
    """Get the git remote URL."""
    result = run_mod.run_capture(["git", "remote", "get-url", "origin"], project_dir)
    if result.returncode == 0:
        return result.stdout.strip()
    return ""


def extract_repo_path(remote_url: str) -> str:
    """Extract owner/repo from git remote URL."""
    match = re.search(r"github\.com[:/](.+?)(?:\.git)?$", remote_url)
    if match:
        return match.group(1)
    return "owner/repo"

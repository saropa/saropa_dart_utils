"""Command execution and PATH checks."""

import shutil
import subprocess
from pathlib import Path

from . import platform as platform_mod
from . import ui


def run_command(
    cmd: list[str],
    cwd: Path,
    description: str,
    capture_output: bool = False,
    allow_failure: bool = False,
) -> subprocess.CompletedProcess:
    """Run a command and handle errors."""
    ui.print_info(f"{description}...")
    ui.print_colored(f"      $ {' '.join(cmd)}", ui.Color.WHITE)

    use_shell = platform_mod.get_shell_mode()

    result = subprocess.run(
        cmd,
        cwd=cwd,
        capture_output=capture_output,
        text=True,
        shell=use_shell,
        encoding="utf-8",
        errors="replace",
    )

    if result.returncode != 0 and not allow_failure:
        if capture_output:
            if result.stdout:
                print(result.stdout)
            if result.stderr:
                print(result.stderr)
        ui.print_error(f"{description} failed (exit code {result.returncode})")
        return result

    ui.print_success(f"{description} completed")
    return result


def command_exists(cmd: str) -> bool:
    """Check if a command exists in PATH."""
    return shutil.which(cmd) is not None


def run_capture(
    cmd: list[str],
    cwd: Path,
) -> subprocess.CompletedProcess:
    """Run a command and capture stdout/stderr (no UI)."""
    return subprocess.run(
        cmd,
        cwd=cwd,
        capture_output=True,
        text=True,
        shell=platform_mod.get_shell_mode(),
        encoding="utf-8",
        errors="replace",
    )

"""Platform detection and shell mode."""

import sys


def is_windows() -> bool:
    """Check if running on Windows."""
    return sys.platform == "win32"


def get_shell_mode() -> bool:
    """
    Get the appropriate shell mode for subprocess calls.

    On Windows, we need shell=True to find .bat/.cmd executables (like flutter.bat)
    that are in PATH. On macOS/Linux, executables are found directly without shell.
    """
    return is_windows()

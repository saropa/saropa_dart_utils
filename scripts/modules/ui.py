"""Terminal UI: ANSI support, logo, colored printing, exit."""

from __future__ import annotations

import sys
from typing import NoReturn

from .colors import Color
from .constants import ExitCode


def enable_ansi_support() -> None:
    """Enable ANSI escape sequence support on Windows."""
    if sys.platform == "win32":
        try:
            import ctypes
            from ctypes import wintypes

            kernel32 = ctypes.windll.kernel32
            STD_OUTPUT_HANDLE = -11
            ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004
            handle = kernel32.GetStdHandle(STD_OUTPUT_HANDLE)
            mode = wintypes.DWORD()
            kernel32.GetConsoleMode(handle, ctypes.byref(mode))
            new_mode = mode.value | ENABLE_VIRTUAL_TERMINAL_PROCESSING
            kernel32.SetConsoleMode(handle, new_mode)
        except Exception:
            pass
        # Prefer UTF-8 stdout so changelog and report content print without UnicodeError
        try:
            sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass


# cspell: disable
def show_saropa_logo() -> None:
    """Display the Saropa 'S' logo in ASCII art."""
    from datetime import datetime

    logo = """
\033[38;5;208m                               ....\033[0m
\033[38;5;208m                       `-+shdmNMMMMNmdhs+-\033[0m
\033[38;5;209m                    -odMMMNyo/-..````.++:+o+/-\033[0m
\033[38;5;215m                 `/dMMMMMM/`           ``````````\033[0m
\033[38;5;220m                `dMMMMMMMMNdhhhdddmmmNmmddhs+-\033[0m
\033[38;5;226m                /MMMMMMMMMMMMMMMMMMMMMMMMMMMMMNh\\\033[0m
\033[38;5;190m              . :sdmNNNNMMMMMNNNMMMMMMMMMMMMMMMMm+\033[0m
\033[38;5;154m              o     `..~~~::~+==+~:/+sdNMMMMMMMMMMMo\033[0m
\033[38;5;118m              m                        .+NMMMMMMMMMN\033[0m
\033[38;5;123m              m+                         :MMMMMMMMMm\033[0m
\033[38;5;87m              /N:                        :MMMMMMMMM/\033[0m
\033[38;5;51m               oNs.                    `+NMMMMMMMMo\033[0m
\033[38;5;45m                :dNy/.              ./smMMMMMMMMm:\033[0m
\033[38;5;39m                 `/dMNmhyso+++oosydNNMMMMMMMMMd/\033[0m
\033[38;5;33m                    .odMMMMMMMMMMMMMMMMMMMMdo-\033[0m
\033[38;5;57m                       `-+shdNNMMMMNNdhs+-\033[0m
\033[38;5;57m                               ````\033[0m
"""
    print(logo)
    current_year = datetime.now().year
    copyright_year = f"2024-{current_year}" if current_year > 2024 else "2024"
    print(f"\033[38;5;195m(c) {copyright_year} Saropa. All rights reserved.\033[0m")
    print("\033[38;5;117mhttps://saropa.com\033[0m")
    print()


# cspell: enable


def print_colored(message: str, color: Color) -> None:
    """Print a message with ANSI color codes."""
    print(f"{color.value}{message}{Color.RESET.value}")


def print_header(text: str) -> None:
    """Print a section header."""
    print()
    print_colored("=" * 70, Color.CYAN)
    print_colored(f"  {text}", Color.CYAN)
    print_colored("=" * 70, Color.CYAN)
    print()


def print_success(text: str) -> None:
    """Print success message."""
    print_colored(f"  [OK] {text}", Color.GREEN)


def print_warning(text: str) -> None:
    """Print warning message."""
    print_colored(f"  [!] {text}", Color.YELLOW)


def print_error(text: str) -> None:
    """Print error message."""
    print_colored(f"  [X] {text}", Color.RED)


def print_info(text: str) -> None:
    """Print info message."""
    print_colored(f"  [>] {text}", Color.MAGENTA)


def exit_with_error(message: str, code: ExitCode) -> NoReturn:
    """Print error and exit."""
    print_error(message)
    sys.exit(code.value)

"""Exit codes and script version."""

from enum import Enum


SCRIPT_VERSION = "2.3"


class ExitCode(Enum):
    """Standard exit codes."""

    SUCCESS = 0
    PREREQUISITES_FAILED = 1
    WORKING_TREE_FAILED = 2
    TEST_FAILED = 3
    ANALYSIS_FAILED = 4
    CHANGELOG_FAILED = 5
    VALIDATION_FAILED = 6
    PUBLISH_FAILED = 7
    GIT_FAILED = 8
    USER_CANCELLED = 9
    AUDIT_FAILED = 10

#!/usr/bin/env bash

# ============================================================
# TITLE: BURC Launchpad Pytest Launcher
# DESCRIPTION: Execute centrally managed pytest using the
#              project Python interpreter.
# AUTHOR: Cole H. Shaigec
# DATE: November 2026
# MAINTAINERS: Boston University Robotics Club
# ============================================================

set -euo pipefail

PROJECT_PYTHON="/opt/venv/bin/python"
PYTEST_PYTHON="/opt/burc/tools/pytest/bin/python"

if [[ ! -x "$PROJECT_PYTHON" ]]; then
    printf '[FAIL] Project Python environment unavailable.\n' >&2
    exit 1
fi

if [[ ! -x "$PYTEST_PYTHON" ]]; then
    printf '[FAIL] Launchpad pytest environment unavailable.\n' >&2
    exit 1
fi

# Determine the centrally managed pytest package location
# without hardcoding the Python minor version.
PYTEST_SITE_PACKAGES="$(
    "$PYTEST_PYTHON" -c \
        'import sysconfig; print(sysconfig.get_path("purelib"))'
)"

# Expose centrally managed pytest to the project interpreter
# while preserving the ROS underlay and workspace overlay.
export PYTHONPATH="${PYTEST_SITE_PACKAGES}${PYTHONPATH:+:$PYTHONPATH}"

exec "$PROJECT_PYTHON" -m pytest "$@"
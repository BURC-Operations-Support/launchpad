#!/usr/bin/env bash
set -euo pipefail

# Launchpad platform verification
# Fails immediately if the environment violates BURC standards.

readonly GREEN=$'\033[0;32m'
readonly RED=$'\033[0;31m'
readonly ORANGE=$'\033[38;5;208m'
readonly NC=$'\033[0m'

pass() {
    printf '%b[PASS]%b %s\n' "$GREEN" "$NC" "$1"
}

fail() {
    printf '%b[FAIL]%b %s\n' "$RED" "$NC" "$1" >&2
    exit 1
}

check_command() {
    local command_name="$1"

    if command -v "$command_name" >/dev/null 2>&1; then
        pass "$command_name available"
    else
        fail "$command_name not found"
    fi
}

check_version() {
    local name="$1"
    local expected="$2"
    local actual="$3"

    if [[ "$actual" == "$expected" ]]; then
        pass "$name $expected"
    else
        fail "$name: expected '$expected', got '$actual'"
    fi
}

echo "=== Launchpad Platform Verification ==="

# ------------------------------------------------------------
# Operating system and ROS
# ------------------------------------------------------------

source /etc/os-release

check_version "Ubuntu" "26.04" "$VERSION_ID"
check_version "ROS 2 distribution" "lyrical" "${ROS_DISTRO:-unset}"

check_command ros2

# ------------------------------------------------------------
# Python and ROS Python bindings
# ------------------------------------------------------------

check_command python3

actual_python="$(
    python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")'
)"

check_version "Python" "3.14" "$actual_python"

if /usr/bin/python3 -c "import rclpy" >/dev/null 2>&1; then
    pass "ROS Python bindings (rclpy)"
else
    fail "Cannot import rclpy using /usr/bin/python3"
fi

# ------------------------------------------------------------
# C++ build and development tools
# ------------------------------------------------------------

# Verify the standardized executable names exposed to
# downstream projects, rather than version-specific names.
#
# LLVM version selection is an internal responsibility
# of the Launchpad platform.
for dependency in \
    gcc \
    g++ \
    git \
    cmake \
    make \
    colcon \
    rosdep \
    gdb \
    clang-format \
    clang-tidy
do
    check_command "$dependency"
done

actual_gcc="$(gcc -dumpfullversion -dumpversion)"
check_version "GCC major" "15" "${actual_gcc%%.*}"

# Verify that the standardized LLVM executables resolve to
# working installations of the mandated LLVM major version.
actual_clang_format="$(clang-format --version)" \
    || fail "clang-format failed to execute"

actual_clang_tidy="$(clang-tidy --version)" \
    || fail "clang-tidy failed to execute"

if [[ "$actual_clang_format" =~ version[[:space:]]+([0-9]+) ]]; then
    check_version "clang-format major" "18" "${BASH_REMATCH[1]}"
else
    fail "Cannot determine clang-format version: $actual_clang_format"
fi

if [[ "$actual_clang_tidy" =~ version[[:space:]]+([0-9]+) ]]; then
    check_version "clang-tidy major" "18" "${BASH_REMATCH[1]}"
else
    fail "Cannot determine clang-tidy version: $actual_clang_tidy"
fi

# Verify GoogleTest and GoogleMock development files.
[[ -f /usr/include/gtest/gtest.h ]] \
    || fail "GoogleTest headers missing"

pass "GoogleTest headers"

[[ -f /usr/include/gmock/gmock.h ]] \
    || fail "GoogleMock headers missing"

pass "GoogleMock headers"

# ------------------------------------------------------------
# Python development tools
# ------------------------------------------------------------

check_command uv
check_command ruff
check_command pyright
check_command pytest

check_version "uv" \
    "0.12.19" \
    "$(uv self version --short)"

check_version "Ruff" \
    "ruff 0.16.9" \
    "$(ruff --version)"

check_version "Pyright" \
    "pyright 1.1.414" \
    "$(pyright --version)"

actual_pytest="$(pytest --version)"
check_version "pytest" "pytest 9.1.1" "$actual_pytest"

# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

printf '\n'
printf '%b[SUCCESS] Launchpad verification complete. Ready for liftoff!%b\n' \
    "$ORANGE" "$NC"
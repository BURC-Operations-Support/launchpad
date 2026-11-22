# syntax=docker/dockerfile:1
#
# TITLE: BURC Launchpad
# DESCRIPTION: Base Docker image for BURC Launchpad
# AUTHOR: Cole H. Shaigec
# DATE: Fall 2026
# MAINTAINERS: Boston University Robotics Club
#
# USAGE:
#   make <command>
#
# NOTES:
#   The project Makefile provides a predefined Docker interface for this project.
#   Where possible, use the Makefile interface instead of direct Docker invocations.

FROM ros:lyrical-ros-base-resolute

SHELL ["/bin/bash", "-c"]

WORKDIR /workspace

# Copy uv from its pinned upstream image
COPY --from=ghcr.io/astral-sh/uv:0.12.19 \
    /uv /uvx /usr/local/bin/

# Centrally managed Python development tools
# Use the ROS-compatible system Python; do not download another interpreter.
ENV UV_TOOL_DIR="/opt/burc/tools" \
    UV_TOOL_BIN_DIR="/usr/local/bin" \
    UV_PYTHON_DOWNLOADS="never"

# System Node.js replaces the much larger bundled nodejs_wheel.
# Include C++ development and debugging tools in the same APT layer.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs \
        libgtest-dev \
        libgmock-dev \
        clang-format-18 \
        clang-tidy-18 \
        gdb \
    && rm -rf /var/lib/apt/lists/*

# Install pinned development tools.
# Pyright uses system Node.js rather than the bundled Node.js wheel.
RUN uv tool install --python /usr/bin/python3 pyright==1.1.414 \
    && uv tool install --python /usr/bin/python3 ruff==0.16.9 \
    && uv tool install --python /usr/bin/python3 pytest==9.1.1

# Verify the standardized environment
COPY --chmod=755 \
    ./scripts/verify-platform.sh \
    /usr/local/bin/verify-platform.sh

RUN source "/opt/ros/${ROS_DISTRO}/setup.bash" \
    && /usr/local/bin/verify-platform.sh

CMD ["bash"]

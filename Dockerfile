# syntax=docker/dockerfile:1
#
# TITLE: 
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
# Prevent uv from quietly installing its own Python to preserve ROS2 compatibility 
ENV UV_TOOL_DIR="/opt/burc/tools" \
    UV_TOOL_BIN_DIR="/usr/local/bin" \
    UV_PYTHON_DOWNLOADS="never"

RUN uv tool install --python /usr/bin/python3 ruff==0.16.9 \
    && uv tool install --python /usr/bin/python3 'pyright[nodejs]==1.1.414' \
    && uv tool install --python /usr/bin/python3 pytest==9.1.1

# C++ development and debugging tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgtest-dev \
        libgmock-dev \
        clang-format-18 \
        clang-tidy-18 \
        gdb \
    && rm -rf /var/lib/apt/lists/*

# Verify the standardized environment
COPY --chmod=755 \
    ./scripts/verify-platform.sh \
    /usr/local/bin/verify-platform.sh

RUN source "/opt/ros/${ROS_DISTRO}/setup.bash" \
    && /usr/local/bin/verify-platform.sh

CMD ["bash"]


.DEFAULT_GOAL := help

IMAGE ?= launchpad:dev
DOCKER ?= docker

.PHONY: help build shell verify check clean

help:
	@echo "Launchpad development commands:"
	@echo "  make build   Build Launchpad image"
	@echo "  make shell   Open an interactive Launchpad shell"
	@echo "  make verify  Verify the installed toolchain"
	@echo "  make check   Build and verify the image"
	@echo "  make clean   Remove the local Launchpad image"

build:
	$(DOCKER) build \
		--tag $(IMAGE) \
		.

shell:
	$(DOCKER) run --rm -it \
		--mount type=bind,source="$(CURDIR)",target=/workspace \
		--workdir /workspace \
		$(IMAGE) \
		bash

verify:
	$(DOCKER) run --rm \
		$(IMAGE) \
		bash /usr/local/bin/verify-platform.sh

check: build verify

clean:
	$(DOCKER) image rm $(IMAGE)

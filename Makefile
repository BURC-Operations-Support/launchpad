
.DEFAULT_GOAL := help

IMAGE ?= cmbe:dev
DOCKER ?= docker

.PHONY: help build shell verify check clean

help:
	@echo "CMBE development commands:"
	@echo "  make build   Build the CMBE image"
	@echo "  make shell   Open an interactive CMBE shell"
	@echo "  make verify  Verify the installed toolchain"
	@echo "  make check   Build and verify the image"
	@echo "  make clean   Remove the local CMBE image"

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

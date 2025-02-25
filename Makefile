#!/usr/bin/env bash

#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# If you update this file, please follow
# https://suva.sh/posts/well-documented-makefiles

## --------------------------------------
## General
## --------------------------------------

SHELL:=/usr/bin/env bash
.DEFAULT_GOAL:=help

# Use GOPROXY environment variable if set
GOPROXY := $(shell go env GOPROXY)
ifeq ($(GOPROXY),)
GOPROXY := https://proxy.golang.org
endif
export GOPROXY

# Active module mode, as we use go modules to manage dependencies
export GO111MODULE=on

# The help will print out all targets with their descriptions organized below
# their categories. The categories are represented by `##@` and the target
# descriptions by `##`.
#
# The awk commands is responsible to read the entire set of makefiles included
# in this invocation, looking for lines of the file as xyz: ## something, and
# then pretty-format the target and help. Then, if there's a line with ##@
# something, that gets pretty-printed as a category.
# 
# More info over the usage of ANSI control characters for terminal
# formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
#
# More info over awk command: http://linuxcommand.org/lc3_adv_awk.php
.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

## --------------------------------------
## Images
## --------------------------------------
IMAGE_NAME ?= go-generics-the-hard-way
IMAGE_TAG  ?= latest
IMAGE      ?= $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: image-build
image-build: ## Build the docker image
	docker build -t $(IMAGE) .

# Please note the image is run in privileged mode in
# order for the debuggers to attach to processes.
.PHONY: image-run
image-run: ## Launch the docker image
	docker run -it --rm --privileged $(IMAGE)


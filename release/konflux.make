SHELL := /bin/bash

AUTH_FILE?=$(shell echo ${XDG_RUNTIME_DIR}/containers/auth.json)

.PHONY: rpm-lock
rpm-lock: rhsm-keys
	@echo $(AUTH_FILE)
	podman run --rm -it \
	-v $(shell pwd):/source:z \
	-v $(AUTH_FILE):/.dockerconfig.json:z \
	--env 'REGISTRY_AUTH_FILE=/.dockerconfig.json' \
	--env 'RHSM_ACTIVATION_KEY=$(RHSM_ACTIVATION_KEY)' \
	--env 'RHSM_ORG=$(RHSM_ORG)' \
	--workdir /source \
	registry.redhat.io/rhel9-4-els/rhel:9.4 ./release/hack/generate-rpm-lock.sh

.PHONY: rhsm-keys
rhsm-keys:
ifndef RHSM_ACTIVATION_KEY
	$(error environment variable RHSM_ACTIVATION_KEY is required)
endif
ifndef RHSM_ORG
	$(error environment variable RHSM_ORG is required)
endif
.ONESHELL:
#.SHELLFLAGS = -e
-include *.makeenv

.DEFAULT_GOAL := build

NS ?= berlin4apk
VERSION ?= latest

# openssl-CMS-test-in-Docker
IMAGE_NAME ?= openssl-cms
CONTAINER_NAME ?= openssl-cms
CONTAINER_INSTANCE ?= default
#BUILDX ?= buildx build --progress plain
#BUILDX_CREATE ?= "$(docker buildx create --name BUILDKIT_STEP_LOG --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10000000 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=10000000)"
###BUILDX_CREATE_NAME ?= BUILDKIT_STEP_LOG
BUILDX_CREATE_NAME ?= default
###BUILDX_CREATE_NAME_prep:	docker buildx create --name $(BUILDX_CREATE_NAME) --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10000000 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=10000000
#BUILDX ?= buildx build --progress plain --builder \"$$(docker buildx create --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10000000 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=10000000)\"
BUILDX ?= buildx build --progress plain --builder $(BUILDX_CREATE_NAME)
#BUILDX ?= buildx build --builder $(BUILDX_CREATE_NAME)
#BUILDX ?= buildx build --no-cache --progress plain

.PHONY: build build-arm push push-arm shell shell-arm run run-arm start start-arm stop stop-arm rm rm-arm release release-arm

builx_install:
	docker run --privileged --rm tonistiigi/binfmt --install all


build: Dockerfile
	echo = $(shell ( docker $(BUILDX) -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile . ))

IMAGE_NAME := ccache-dev
CONTAINER_NAME := ccache-dev
VERSION := ccache-4.4.2

buildtest:
	$(shell ( docker $(BUILDX) -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)

buildtest1:
	$(shell ( docker $(BUILDX) --platform linux/amd64 -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)

buildtest2:
	$(shell ( docker $(BUILDX) --platform linux/386 -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)


buildtest3:
	$(shell ( docker $(BUILDX) --platform linux/386,linux/amd64,linux/arm/v5,linux/arm/v7,linux/arm64,linux/ppc64le,linux/s390x,linux/riscv64 -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)


#@$(run-dummy4cp)@
#call run-dummy4cp



BASE_IMAGE=alpine:3.14
# BASE_IMAGE=alpine:edge
##CMAKE_BUILD_PARALLEL_LEVEL=3
CMAKE_BUILD_PARALLEL_LEVEL=1
#ninjaARG="-l2" # load
ninjaARG="-j1" # cpus
buildtest-all:
	echo = $(shell ( docker $(BUILDX) --platform linux/amd64 -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar BASE_IMAGE=$(IMAGE_NAME) CMAKE_BUILD_PARALLEL_LEVEL=$(CMAKE_BUILD_PARALLEL_LEVEL) ninjaARG=$(ninjaARG) -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)
#	@echo $(call dummy4cp_fn, go, tigers)
#	@$(run-dummy4cp)
	echo = $(shell ( docker $(BUILDX) --platform linux/386 -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar BASE_IMAGE=$(IMAGE_NAME) -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)
#	@$(run-dummy4cp)
	echo = $(shell ( docker $(BUILDX) --platform linux/arm/v5 -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar BASE_IMAGE=$(IMAGE_NAME) -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)
#	@$(run-dummy4cp)
	echo = $(shell ( docker $(BUILDX) --platform linux/arm/v6 -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar BASE_IMAGE=$(IMAGE_NAME) -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)
#	@$(run-dummy4cp)
	echo = $(shell ( docker $(BUILDX) --platform linux/arm/v7 -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar BASE_IMAGE=$(IMAGE_NAME) -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)
#	@$(run-dummy4cp)
	echo = $(shell ( docker $(BUILDX) --platform linux/arm64 -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar BASE_IMAGE=$(IMAGE_NAME) -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)
#	@$(run-dummy4cp)
	echo = $(shell ( docker $(BUILDX) --platform linux/ppc64le -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar BASE_IMAGE=$(IMAGE_NAME) -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)
#	@$(run-dummy4cp)
	echo = $(shell ( docker $(BUILDX) --platform linux/s390x -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar BASE_IMAGE=$(IMAGE_NAME) -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)
#	@$(run-dummy4cp)
	echo = $(shell ( docker $(BUILDX) --platform linux/riscv64 -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg fooenvATbuild=foovar BASE_IMAGE=$(IMAGE_NAME) -f Dockerfile.test . ) )
	$(call dummy4cp_fn, go, tigers)
#	@$(run-dummy4cp)

.PHONY: run-dummy4cp
define run-dummy4cp ?=
###@echo "run-dummy4cp target $@"
	# https://stackoverflow.com/a/51186557/16596104
	# https://github.com/moby/buildkit#local-directory
	# https://docs-stage.docker.com/engine/reference/commandline/create/#extended-description
	# docker create -ti --name dummy-for-cp berlin4apk/ccache-dev bash
	# work also, but the 2.ed command is simpler
#	containernamefoo = $(shell docker container inspect --format='{{.Config.Image}}' dummy4cp 2> /dev/null && docker rm -f dummy4cp )
	echo = $(shell ( docker container inspect --format='{{.Config.Image}}' dummy4cp 2> /dev/null && docker rm -f dummy4cp ) )
	echo = $(shell docker create --name dummy4cp $(NS)/$(IMAGE_NAME):$(VERSION) )
	# docker cp dummy4cp:/usr/local/src/ccache-git/build_package_dir_test/ccache-4.4.2-Linux-x86_64.tar.xz .
	# docker container export dummy4cp | tar tvf - usr/local/src/ccache-git/ | grep tar
	# docker container export dummy4cp | tar tf - usr/local/src/ccache-git/ | grep tar
	docker container export dummy4cp | tar --keep-old-files xvf - opt
	docker rm -f dummy4cp
	mkdir outputDIR
	#mv --backup=existing --verbose opt/ccache opt/ccache_$(elf-arch opt/ccache)
###	$(shell mv --backup=existing --verbose 'opt/*' ./outputDIR/ )
	echo = $(shell mv --backup=existing --verbose 'opt/*' ./outputDIR/ )
##BIN_DIRS := ./opt
##BINFILES := $(shell find $(BIN_DIRS) -name '*.tar' -or -name '*.tar.*' -or -name '*')
##	$(shell mv --backup=existing --verbose $(BINFILES) ./outputDIR/ )
endef


buildtestenv: Dockerfile.test
	echo "docker create --name dummy4cp $(NS)/$(IMAGE_NAME):$(VERSION)"

build-arm: Dockerfile
	docker $(BUILDX) --platform linux/arm/v6 -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

build-386: Dockerfile
	docker $(BUILDX) --platform linux/386 -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

build-all: Dockerfile
	docker $(BUILDX) --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/ppc64le,linux/s390x,linux/riscv64 -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

# from     https://github.com/OSGeo/gdal/blob/793101437b6209e460d0980ce1d689a3a42e36e3/.github/workflows/ubuntu_20.04.yml#L26
#           key: ${{ runner.os }}-cache-ubuntu-20.04-${{ hashFiles('.github/workflows/ubuntu_20.04/build-deps.sh') }}-${{ github.run_id }}
# key: ${{ runner.os }}-cache-ubuntu-20.04-${{ hashFiles('.github/workflows/ubuntu_20.04/build-deps.sh') }}-${{ github.run_id }}${{ matrix.platform-args }}

inspect: # Inspect current builder instance
	docker buildx inspect

push:
	docker push $(NS)/$(IMAGE_NAME):$(VERSION)

push-arm:
	docker push $(NS)/rpi-$(IMAGE_NAME):$(VERSION)

shell:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/bash

IMAGE_NAME ?= ccache-dev
CONTAINER_NAME ?= ccache-dev
shelltest:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)  --env fooenvATrun=foovar -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/bash

shell-arm:
	docker run --rm --name rpi-$(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/rpi-$(IMAGE_NAME):$(VERSION) /bin/bash

run:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

run-arm:
	docker run --rm --name rpi-$(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/rpi-$(IMAGE_NAME):$(VERSION)

start:
	docker run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

start-arm:
	docker run -d --name rpi-$(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/rpi-$(IMAGE_NAME):$(VERSION)

stop-docker:
	docker stop --foo $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

stop-arm:
	docker stop rpi-$(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

rm:
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

rm-arm:
	docker rm rpi-$(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

release-arm: build-arm
	make push-arm -e VERSION=$(VERSION)

#default: build



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
#BUILDX ?= buildx build --no-cache --progress plain

.PHONY: build build-arm push push-arm shell shell-arm run run-arm start start-arm stop stop-arm rm rm-arm release release-arm

builx_install:
	docker run --privileged --rm tonistiigi/binfmt --install all

build: Dockerfile
	docker $(BUILDX) -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

build-arm: Dockerfile.arm
	docker $(BUILDX) -t $(NS)/rpi-$(IMAGE_NAME):$(VERSION) -f Dockerfile.arm .

push:
	docker push $(NS)/$(IMAGE_NAME):$(VERSION)

push-arm:
	docker push $(NS)/rpi-$(IMAGE_NAME):$(VERSION)

shell:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/bash

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



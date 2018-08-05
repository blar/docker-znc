BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_URL := $(shell git config --get remote.origin.url)
VCS_REF := $(shell git rev-parse --short HEAD)

ALPINE_VERSION := 3.8
ZNC_VERSION := 1.7
IMAGE_TAG := $(ZNC_VERSION)
IMAGE_NAME ?= foobox/znc:$(IMAGE_TAG)

all: build

build: amd64-build arm32v6-build

push: amd64-push arm32v6-push

amd64-build:
	docker build \
		--force-rm \
	    --build-arg BUILD_DATE=$(BUILD_DATE) \
	    --build-arg VCS_URL=$(VCS_URL) \
	    --build-arg VCS_REF=$(VCS_REF) \
	    --build-arg ARCH=amd64 \
	    --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	    --build-arg ZNC_VERSION=$(ZNC_VERSION) \
	    --tag $(IMAGE_NAME)-amd64 .

amd64-push: amd64-build
	docker push $(IMAGE_NAME)-amd64

arm32v6-build:
	docker build \
		--force-rm \
	    --build-arg BUILD_DATE=$(BUILD_DATE) \
	    --build-arg VCS_URL=$(VCS_URL) \
	    --build-arg VCS_REF=$(VCS_REF) \
	    --build-arg ARCH=arm32v6 \
	    --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	    --build-arg ZNC_VERSION=$(ZNC_VERSION) \
	    --tag $(IMAGE_NAME)-arm32v6 .

arm32v6-push: arm32v6-build
	docker push $(IMAGE_NAME)-arm32v6

manifest: amd64-push arm32v6-push
	docker manifest create $(IMAGE_NAME) $(IMAGE_NAME)-amd64 $(IMAGE_NAME)-arm32v6
	docker manifest annotate $(IMAGE_NAME) $(IMAGE_NAME)-amd64 --os linux --arch amd64
	docker manifest annotate $(IMAGE_NAME) $(IMAGE_NAME)-arm32v6 --os linux --arch arm --variant v6
	docker manifest push --purge $(IMAGE_NAME)

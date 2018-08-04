ALPINE_VERSION := 3.8
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF := $(shell git rev-parse --short HEAD)
ZNC_VERSION := 1.7.1
IMAGE_TAG := $(ZNC_VERSION)

all: znc-amd64-build znc-arm32v6-build

znc-amd64-build:
	docker build \
	    --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	    --build-arg ARCH=amd64 \
	    --build-arg BUILD_DATE=$(BUILD_DATE) \
	    --build-arg VCS_REF=$(VCS_REF) \
	    --build-arg ZNC_VERSION=$(ZNC_VERSION) \
	    --tag foobox/znc:$(IMAGE_TAG)-amd64 .

znc-amd64-push: znc-amd64-build
	docker push foobox/znc:$(IMAGE_TAG)-amd64

znc-arm32v6-build:
	docker build \
	    --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	    --build-arg ARCH=arm32v6 \
	    --build-arg BUILD_DATE=$(BUILD_DATE) \
	    --build-arg VCS_REF=$(VCS_REF) \
	    --build-arg ZNC_VERSION=$(ZNC_VERSION) \
	    --tag foobox/znc:$(IMAGE_TAG)-arm32v6 .

znc-arm32v6-push: znc-arm32v6-build
	docker push foobox/znc:$(IMAGE_TAG)-arm32v6

manifest: znc-amd64-push znc-arm32v6-push
	docker manifest create foobox/znc:$(IMAGE_TAG) foobox/znc:$(IMAGE_TAG)-amd64 foobox/znc:$(IMAGE_TAG)-arm32v6
	docker manifest annotate foobox/znc:$(IMAGE_TAG) foobox/znc:$(IMAGE_TAG)-amd64 --os linux --arch amd64
	docker manifest annotate foobox/znc:$(IMAGE_TAG) foobox/znc:$(IMAGE_TAG)-arm32v6 --os linux --arch arm --variant v6
	docker manifest push --purge foobox/znc:$(IMAGE_TAG)

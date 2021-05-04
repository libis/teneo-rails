.SILENT:

REGISTRY := registry.docker.libis.be
TAG_BASE := teneo/rails
BUILDER_TAG := $(REGISTRY)/$(TAG_BASE)-builder:latest
FINAL_TAG := $(REGISTRY)/$(TAG_BASE)-final:latest

build: build-builder build-final

build-builder:
	echo "Building Builder image ..."
	docker build -t $(BUILDER_TAG) builder

build-final:
	echo "Building Final image ..."
	docker build -t $(FINAL_TAG) final

push: push-builder push-final

push-builder:
	echo "Pushing Builder image ..."
	docker push $(BUILDER_TAG)

push-final:
	echo "Pushing Final image ..."
	docker push $(FINAL_TAG)
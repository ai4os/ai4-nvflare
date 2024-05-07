#!/usr/bin/env bash

SOURCE=${1:-"default.env"}

source ${SOURCE}

#
# server image
#

docker build \
	--build-arg NVF_BASE_IMAGE_SERVER=${NVF_BASE_IMAGE_SERVER} \
	--build-arg NVF_REPO=${NVF_REPO} \
	--build-arg NVF_VERSION=${NVF_VERSION} \
	-t sht3v0/ai4-nvflare-server:$NVF_VERSION \
	-f Dockerfile-server \
	.

docker push sht3v0/ai4-nvflare-server:$NVF_VERSION

#
# client image
#

docker build \
	--build-arg NVF_BASE_IMAGE_CLIENT=${NVF_BASE_IMAGE_CLIENT} \
	--build-arg NVF_REPO=${NVF_REPO} \
	--build-arg NVF_VERSION=${NVF_VERSION} \
	-t sht3v0/ai4-nvflare-client:$NVF_VERSION \
	-f Dockerfile-client \
	.

docker push sht3v0/ai4-nvflare-client:$NVF_VERSION

#
# dashboard image
#

docker build \
	--build-arg NVF_BASE_IMAGE_DASHBOARD=${NVF_BASE_IMAGE_DASHBOARD} \
	--build-arg NVF_VERSION=${NVF_VERSION} \
	-t sht3v0/ai4-nvflare-dashboard:$NVF_VERSION \
	-f Dockerfile-dashboard \
	.

docker push sht3v0/ai4-nvflare-dashboard:$NVF_VERSION

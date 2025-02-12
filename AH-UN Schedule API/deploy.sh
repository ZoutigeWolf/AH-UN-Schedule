#!/bin/bash

IMAGE_NAME="ah-un-schedule-api"
TAG="latest"
DOCKER_REGISTRY="registry.zoutigewolf.dev"
POST_URL="https://portainer.zoutigewolf.dev/api/webhooks/733f57ed-5335-4a99-8adc-41d14fffc5fc"

docker buildx build --platform linux/amd64 -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG} --push .

curl -X POST ${POST_URL}

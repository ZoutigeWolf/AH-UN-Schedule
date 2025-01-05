#!/bin/bash

# Variables
IMAGE_NAME="ah-un-schedule-api"
TAG="latest"
DOCKER_REGISTRY="registry.zoutigewolf.dev"
POST_URL="https://portainer.zoutigewolf.dev/api/webhooks/698202a8-6946-49e0-811a-0e9ebc52c597"

# Build Docker image for amd64
docker buildx build --platform linux/amd64 -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG} .

# Push Docker image to registry
docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG}

# Make POST request
curl -X POST ${POST_URL}

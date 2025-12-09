#!/usr/bin/env bash
# Publish the deepgeosense image to Docker Hub

set -euo pipefail

IMAGE_NAME="${1:-deepgeosense}"
TAG="${2:-latest}"
DOCKER_USERNAME="${DOCKER_USERNAME:-}"

# Detect docker or podman
if command -v docker >/dev/null 2>&1; then
    CONTAINER_CMD="docker"
elif command -v podman >/dev/null 2>&1; then
    CONTAINER_CMD="podman"
else
    echo "Error: Neither docker nor podman found. Please install one of them."
    exit 1
fi

if [[ -z "$DOCKER_USERNAME" ]]; then
    echo "Error: DOCKER_USERNAME environment variable not set"
    echo "Usage: DOCKER_USERNAME=yourusername ./publish.sh [image-name] [tag]"
    exit 1
fi

LOCAL_TAG="${IMAGE_NAME}:${TAG}"
REMOTE_TAG="${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}"

# Check if image exists locally
if ! ${CONTAINER_CMD} image inspect "${LOCAL_TAG}" >/dev/null 2>&1; then
    echo "Error: Image ${LOCAL_TAG} not found locally"
    echo "Build it first with: ./build.sh"
    exit 1
fi

echo "Using ${CONTAINER_CMD} to publish ${REMOTE_TAG}..."

# Tag for Docker Hub
echo "Tagging ${LOCAL_TAG} as ${REMOTE_TAG}..."
${CONTAINER_CMD} tag "${LOCAL_TAG}" "${REMOTE_TAG}"

# Login to Docker Hub (if not already logged in)
echo "Logging in to Docker Hub..."
${CONTAINER_CMD} login docker.io

# Push to Docker Hub
echo "Pushing ${REMOTE_TAG}..."
${CONTAINER_CMD} push "${REMOTE_TAG}"

# Also push latest tag if this is a version tag
if [[ "$TAG" != "latest" ]]; then
    REMOTE_LATEST="${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
    echo "Tagging ${LOCAL_TAG} as ${REMOTE_LATEST}..."
    ${CONTAINER_CMD} tag "${LOCAL_TAG}" "${REMOTE_LATEST}"
    echo "Pushing ${REMOTE_LATEST}..."
    ${CONTAINER_CMD} push "${REMOTE_LATEST}"
fi

echo "✓ Successfully published to Docker Hub"
echo ""
echo "Pull with:"
echo "  ${CONTAINER_CMD} pull ${REMOTE_TAG}"

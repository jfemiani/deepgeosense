#!/usr/bin/env bash
# Build the deepgeosense base image

set -euo pipefail

IMAGE_NAME="${1:-deepgeosense}"
TAG="${2:-latest}"
FULL_TAG="${IMAGE_NAME}:${TAG}"

# Detect docker or podman
if command -v docker >/dev/null 2>&1; then
    CONTAINER_CMD="docker"
elif command -v podman >/dev/null 2>&1; then
    CONTAINER_CMD="podman"
else
    echo "Error: Neither docker nor podman found. Please install one of them."
    exit 1
fi

echo "Using ${CONTAINER_CMD} to build ${FULL_TAG}..."

${CONTAINER_CMD} build -t "${FULL_TAG}" .

echo "✓ Successfully built ${FULL_TAG}"
echo ""
echo "To push to Docker Hub:"
echo "  ./publish.sh ${IMAGE_NAME} ${TAG}"
echo ""
echo "To test locally:"
echo "  ${CONTAINER_CMD} run -it --rm ${FULL_TAG}"

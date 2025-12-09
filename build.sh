#!/usr/bin/env bash
# Build the deepgeosense base image

set -euo pipefail

IMAGE_NAME="${1:-deepgeosense}"
TAG="${2:-latest}"
FULL_TAG="${IMAGE_NAME}:${TAG}"

echo "Building ${FULL_TAG}..."

docker build -t "${FULL_TAG}" .

echo "✓ Successfully built ${FULL_TAG}"
echo ""
echo "To push to Docker Hub:"
echo "  ./publish.sh ${IMAGE_NAME} ${TAG}"
echo ""
echo "To test locally:"
echo "  docker run -it --rm ${FULL_TAG}"

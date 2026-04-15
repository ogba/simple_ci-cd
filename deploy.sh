#!/usr/bin/env bash
set -e

IMAGE_NAME="${IMAGE_NAME:-ai-arcade-snake}"
CONTAINER_NAME="${CONTAINER_NAME:-ai-arcade-snake-service}"
PORT="8099"

echo "Building Docker image ${IMAGE_NAME}:latest..."
docker build -t "${IMAGE_NAME}:latest" .

echo "Stopping existing container if it exists..."
docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Starting service on port ${PORT}..."
docker run -d --name "${CONTAINER_NAME}" -p "${PORT}:8099" "${IMAGE_NAME}:latest"

echo "Service running at http://localhost:${PORT}"


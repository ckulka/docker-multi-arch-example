# Docker multi-arch example

This repository demonstrates how to create a multi-arch Docker image supporting multiple platforms. It primarily for personal use for reference on how to build manifests and how they work.

It's a TL;DR version of the references linked at the bottom.

## Prerequisites

Also, as long as the `docker manifest` commands as experimental, enable the experimental mode for the Docker Cli in `~/.docker/config.json:

```json
{
    "experimental": "enabled"
}
```

## Steps

To create a multi-arch image, follow the next 4 steps

1. Build and push the image for the `amd64` platform
1. Build and push the image for the `arm32v7` platform
1. Create the manifest for the multi-arch image
1. Push the maniest for the multi-arch image

```bash
# Build the images on their respective platforms
docker build -t ckulka/multiarch-example:amd64 -f Dockerfile.amd64 .
docker push ckulka/multiarch-example:amd64

docker build -t ckulka/multiarch-example:arm32v7 -f Dockerfile.arm32v7 .
docker push ckulka/multiarch-example:arm32v7

# Create and push the manifest
docker manifest create ckulka/multiarch-example:latest ckulka/multiarch-example:amd64 ckulka/multiarch-example:arm32v7
docker manifest push ckulka/multiarch-example:latest
```

The created manifest acts as a reference for the linked images. The Docker client, when pulling `ckulka/multiarch-example:latest`, looks up a "fitting" image and then uses that one.

## References

- Image Manifest V 2, Schema 2, <https://docs.docker.com/registry/spec/manifest-v2-2/>
- Docker Manifest CLI reference, <https://docs.docker.com/edge/engine/reference/commandline/manifest/>
- <https://github.com/estesp/manifest-tool>
- <https://medium.com/@mauridb/docker-multi-architecture-images-365a44c26be6>

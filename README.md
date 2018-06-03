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
docker build -t ckulka/multi-arch-example:amd64 -f Dockerfile.amd64 .
docker push ckulka/multi-arch-example:amd64

docker build -t ckulka/multi-arch-example:arm32v7 -f Dockerfile.arm32v7 .
docker push ckulka/multi-arch-example:arm32v7

# Create and push the manifest
docker manifest create ckulka/multi-arch-example:latest ckulka/multi-arch-example:amd64 ckulka/multi-arch-example:arm32v7
docker manifest push ckulka/multi-arch-example:latest
```

The created manifest acts as a reference for the linked images. The Docker client, when pulling `ckulka/multi-arch-example:latest`, looks up a "fitting" image and then uses that one.

The `--amend` parameters allows adding additional platforms:

```bash
docker manifest create --amend ckulka/multi-arch-example:latest ckulka/multi-arch-example:arm32v8
```

## Inspecting the result

The `docker manifest inspect` command shows the image manifest details - for the multi-arch image, it's the list of images it references and their respective platforms:

```bash
docker manifest inspect ckulka/multi-arch-example:latest
```

```json
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
   "manifests": [
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 1728,
         "digest": "sha256:3a859e0c2bdfb60f52b2c805e2cb55260998b3c343d9e2ea04a742d946be1b1e",
         "platform": {
            "architecture": "amd64",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 1728,
         "digest": "sha256:3ef9264d6e5ad96ad7bac675d40edf265ae838ae6ca60865abed159c8c5124c8",
         "platform": {
            "architecture": "arm",
            "os": "linux"
         }
      }
   ]
}
```

## References

- Image Manifest V 2, Schema 2, <https://docs.docker.com/registry/spec/manifest-v2-2/>
- Docker Manifest CLI reference, <https://docs.docker.com/edge/engine/reference/commandline/manifest/>
- <https://github.com/estesp/manifest-tool>
- <https://medium.com/@mauridb/docker-multi-architecture-images-365a44c26be6>

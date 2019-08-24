# Docker multi-arch example

This repository demonstrates how to create a multi-arch Docker image supporting multiple platforms, e.g. both `x86_64` and ARM, but building all images on an `x86_64` platform. It is primarily for personal use for reference on how to build manifests and how they work.

This example also only relies on Docker Hub to build all images, including the ARM variants, and does not rely on separate build servers or environments to build non-amd64 images.

It's a TL;DR version of the references linked in the README.

## Steps

To create a multi-arch image, follow the next 4 steps

1. Build and push the image for the `amd64` platform
2. Build and push the image for the `arm*` platforms
3. Create the manifest for the multi-arch image
4. Push the maniest for the multi-arch image

### Automated builds via Docker Hub

The Docker Hub [Custom build phase hooks](https://docs.docker.com/docker-hub/builds/advanced/#custom-build-phase-hooks) allow in combination with [QEMU](https://www.qemu.org) an entirely automated build of the Docker images via Docker Hub for all major platforms - as it is used in this repository.

To see how it's done in this repository, see

- Prepare QEMU in a custom build phase hook, [hooks/pre_build](./hooks/pre_build)
- Dockerfile to build an `arm32v7` image on `x86_64` (Docker Hub), [arm32v7.dockerfile](./arm32v7.dockerfile)
- Dockerfile to build an `arm64v8` image on `x86_64` (Docker Hub), [arm64v8.dockerfile](./arm64v8.dockerfile)

### Push multi-arch manifest automatically (Docker Hub)

Once Docker Hub has published the `amd64` and `arm*` images, Docker Hub executes the `hooks/post_push` script.

The script downloads the [manifest-tool](https://github.com/estesp/manifest-tool) and pushes the multi-arch manifest `multi-arch-manifest.yaml`, which - simply put - makes `ckulka/multi-arch-example:latest` a list containing references to the various platform variants.

To see how it's done in this repository, see

- Multi-arch manifest file, [multi-arch-manifest.yaml](./multi-arch-manifest.yaml)
- Push the multi-arch manifest file in a custom build phase hook, [hooks/post_push](./hooks/post_push)

### Push the multi-arch manifest manually (manifest-tool)

If you want to push the multi-arch manifest yourself using the manifest-tool, here are the steps:

1. Create the mulit-arch manifest file, e.g. [multi-arch-manifest.yaml](./multi-arch-manifest.yaml)
2. Download the manifest-tool
3. Push the manifest using manifest-tool

```bash
# Download the manifest-tool
curl -Lo manifest-tool https://github.com/estesp/manifest-tool/releases/download/v0.9.0/manifest-tool-linux-amd64
chmod +x manifest-tool

# Push the multi-arch manifest
./manifest-tool push from-spec multi-arch-manifest.yaml

# On Docker for Mac, see https://github.com/estesp/manifest-tool#sample-usage
./manifest-tool --username ada --password lovelace push from-spec multi-arch-manifest.yaml
```

For more details, see [manifest-tool: Create/Push](https://github.com/estesp/manifest-tool#createpush).

### Push the multi-arch manifest manually (Docker CLI)

If you want to push the multi-arch manifest yourself using the Docker CLI, here's how.

As long as the `docker manifest` commands are experimental, enable the experimental mode for the Docker CLI in `~/.docker/config.json` first:

```json
{
    "experimental": "enabled"
}
```

Next up, create and publish multi-arch the manifest.

```bash
# Create and push the manifest
docker manifest create ckulka/multi-arch-example:latest ckulka/multi-arch-example:amd64 ckulka/multi-arch-example:arm32v7
docker manifest push --purge ckulka/multi-arch-example:latest
```

The created manifest acts as a reference for the linked images. The Docker client, when pulling `ckulka/multi-arch-example:latest`, looks up a "fitting" image and then uses that one.

The `--amend` parameters allows adding additional platforms:

```bash
docker manifest create --amend ckulka/multi-arch-example:latest ckulka/multi-arch-example:arm64v7
```

The `--purge` parameter deletes the local manifest, which allows recreating and subsequently replacing the list:

```bash
# Release version 1.0 as latest image variant
docker manifest create ckulka/multi-arch-example:latest ckulka/multi-arch-example:1.0-amd64 ckulka/multi-arch-example:1.0-arm32v7
docker manifest push --purge ckulka/multi-arch-example:latest

# Release version 2.0 as latest image variant
docker manifest create ckulka/multi-arch-example:latest ckulka/multi-arch-example:2.0-amd64 ckulka/multi-arch-example:2.0-arm32v7
docker manifest push --purge ckulka/multi-arch-example:latest
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

## Known limitations

Building non-x86_64 images on Docker Hub results in images with incorrectly labelled architectures.

For example, the `arm32v7` image runs on `arm32v7`, but will labelled as `amd64`, because Docker Hub builds the images on `x86_64`. There is a [workaround for it](https://github.com/moby/moby/issues/36552#issuecomment-459927487), but I've not added it here to keep things simple.

This issue is currently tracked in [moby/moby#36552](https://github.com/moby/moby/issues/36552).

## References

- [Image Manifest V 2, Schema 2](https://docs.docker.com/registry/spec/manifest-v2-2/)
- [Docker Manifest CLI reference](https://docs.docker.com/edge/engine/reference/commandline/manifest/)
- [estesp/manifest-tool](https://github.com/estesp/manifest-tool)
- [Docker Multi-Architecture Images by Davide Mauri](https://medium.com/@mauridb/docker-multi-architecture-images-365a44c26be6)
- [Support automated ARM builds](https://github.com/docker/hub-feedback/issues/1261)
- [Custom build phase hooks](https://docs.docker.com/docker-hub/builds/advanced/#custom-build-phase-hooks)
- [QEMU.org](https://www.qemu.org)

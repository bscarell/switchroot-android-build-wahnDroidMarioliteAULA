# Scripts and environment to build Switchroot Android image

This repo provides a set of scripts and a Dockerfile (`build-scripts/Dockerfile`) to create the basic environment for building Lineage and Switchroot Android.

**To use the prebuilt docker images, check out the [latest release](https://github.com/PabloZaiden/switchroot-android-build/releases/latest) in this GitHub repository.**

## Read this before doing anything else, or Voldemort will come for you and summon his dragons:
This build environment is meant to automate the steps from the following guide: [Q Tips Guide](https://gitlab.com/ZachyCatGames/q-tips-guide)

Read and understand that guide before continuing.

Also, if you have built Switchroot *Pie* before, delete the whole `./android` directory before starting with *Q*

After doing that, you can use this to generate the content of your SD card for flashing and installing via Hekate and TWRP.

## Build using the image in Dockerhub:
- Boot Linux (natively or a VM. Don't use *WSL* or *WSL2* with the Dockerized build unless you *really* know what you are doing, since it has severe performance issues with this particular scenario)
- Install `docker` (**proper docker installation**: `apt install docker.io` if on Ubuntu. It *might* work if installed via Snap with the latest changes, but it wasn't tested. It now requires `--privileged` mode) 
- Go to a directory on a drive where there are at least 250GB of free space.
- Run the following commands:
```bash
mkdir -p ./android/lineage
sudo chown -R 1000:1000 ./android

# Don't use the "latest" tag unless you know what you're doing. 
# Use a versioned tag from https://hub.docker.com/r/pablozaiden/switchroot-android-build/tags
sudo docker run --privileged --rm -ti -e ROM_NAME=icosa -v "$PWD"/android:/build/android pablozaiden/switchroot-android-build:latest
```
- Copy the content of `./android/output` to the root of your SD card (partitioned as a single FAT32-formatted volume; format with Hekate as it ensures proper cluster size for performance)
- Create the remaining partitions from within Hekate, flash TWRP and install after that. (It is expected to see some errors about mounting some partitions in TWRP the first time flashing)

## Detailed usage information

### Requirements
- Docker
- At least 16GB of RAM
- At least 250GB of free storage

### Build everything locally

- Clone/Download this repo.
- If you *don't want* to use `docker`:
    - Avoid having the docker service enabled *or* set any value to the `DISABLE_DOCKER` environment variable.
    - Set the `BUILDBASE` environment variable to the path of the base directory where the process will be executed. If `BUILDBASE` is not defined, it will use `$(pwd)/build`. 
    - Make sure to install all the prerequisites before starting (the convenience script `install-prerequisites-ubuntu.sh` is provided with this repo)
    - If a previous build was created using docker, it will create a symbolic link to it instead of starting from scratch. This behavior can be disabled with the `DISABLE_SYMLINK_TO_DOCKER_BUILD` environment variable
    - If you're using *WSL2*, make sure the drive you're using is either NTFS or ext4, and mounted correctly in *WSL2*. For more information on mounting drives in *WSL2*, see https://docs.microsoft.com/en-us/windows/wsl/wsl2-mount-disk (at this time, the `--mount` feature is only available on developer insider builds of Windows 10). Also, make sure to configure *WSL2* to have, at least 16GB of available RAM or 12GB and enough swap: https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig)
- If you're using `docker` Either prepend `sudo` to the script execution, or allow the current user to run `docker` without `sudo`
- Run `./build-android.sh --rom <icosa | foster | foster_tab> --rom-type <zip | images> --flags <nobuild | noupdate | nooutput>`  
All parameters are optional. Default for --rom is `icosa`, default for --rom-type is `zip`, default for --flags is empty
- When building the `zip`, the required output for installing via Hekate will be copied to `./android/output` or `$BUILDBASE/android/output`, unless the `nooutput` flag is present
- Any subsequent build execution will detect that the `./android/lineage` or `$BUILDBASE/android/lineage` directoy contains files and will work under the assumption that the source code was already downloaded at least once. Then it will re-sync the repos, re-apply patches and re-build

*Important*: The docker image builds everything in the `/build/android` directory, inside the container. The `./build-android.sh` script mounts the host directory `./android` as a volume to that directory in the container, so the sources and build output can live after the container is destroyed.

If that directory is not properly mounted, the build may fail.

### Custom repopics and patches

To apply custom patches to your build, create the `extra-content/patches.txt`  file and add lines with the `<patch_base_dir>:<patch_path>` format or add the `extra-content/repopics.txt` with one patch per line. The same format is being used for default patches and repopics in `build-scripts/default-patches.txt` and `build-scripts/default-repopics.txt`
The files **must** end with an empty line.

By default, the script will try to download the latest repopics and patches from the main repository `master` branch. To avoid doing this and always use the local copy, add a non-empty `LOCAL_REPOPICS_PATCHES` environment variable

When building with docker, make sure to also mount the `extra-content` directory to `${BUILDBASE}/extra-content` (as it is done in `build-in-docker.sh`)

### Convenience scripts

There are several `.sh` scripts in the repo root, for convenience. You can find usage documentation inside each script.

#!/bin/bash

## This script creates the build image locally and builds Android.
##
## Possible parameters:
##  --rom: rom to build. Possible values: icosa_sr | icosa_tv_sr
##  --rom-type: build output. Possible values: zip | images
##  --flags: flags to pass to the build script. Possible values: string that contains:
##      - nobuild: avoids running the build process.
##      - noupdate: avoids running the sources update process.
##      - nooutput: avoids copying the build to the output directory.
##
## If the ENV variable DUMMY_BUILD has some non-empty value, the actual execution of scripts 
## will be replaced with dummy messages. Used to quickly test the other parameters.

while (($# > 0))
    do
    declare Option="$1"
    declare Value="$2"

    case $Option in
    --rom)
        if [[ "$Value" != "icosa_sr" && "$Value" != "icosa_tv_sr" ]]; then
            echo "Invalid rom name. Expecting icosa_sr | icosa_tv_sr"
            exit 1
        fi
        declare ROM_NAME="$Value"
        shift
        shift
        ;;

    --rom-type)
        if [[ "$Value" != "zip" && "$Value" != "images" ]]; then
            echo "Invalid rom type. Expecting images | zip"
            exit 1
        fi
        declare ROM_TYPE="$Value"
        shift
        shift
        ;;

    --custom-build)
        if [[ -z ${Value} ]]; then
            echo "Custom build must indicate a command to run"
            exit 1
        fi
        declare CUSTOM_BUILD="$Value"
        shift
        shift
        ;;

    --flags)
        if [[ -z ${Value##*--*} ]]; then
            echo "Flags must come last and the arguments must not be empty."
            exit 1
        fi
        declare FLAGS="$Value"
        shift
        shift
        ;;

    *)
        echo "Unknown option. Ignoring $Option."
        shift
        ;;

    esac
done

DUMMY_BUILD=${DUMMY_BUILD:-""}
CUSTOM_BUILD="${CUSTOM_BUILD:-""}" 
ROM_NAME=${ROM_NAME:-icosa_sr} 
ROM_TYPE=${ROM_TYPE:-zip} 
FLAGS=${FLAGS:-""}

export DUMMY_BUILD
export CUSTOM_BUILD
export ROM_NAME
export ROM_TYPE
export FLAGS


if [[ -z $ROM_NAME ]]; then
    echo "Missing ROM_NAME env variable. Expected icosa_sr | icosa_tv_sr"
    exit 1
else
    echo "ROM name: $ROM_NAME"
fi

if [[ -z $ROM_TYPE ]]; then
    echo "Missing ROM_TYPE env variable. Expected zip | images"
    exit 1
else
    echo "ROM type: $ROM_TYPE"
fi

if [[ ! -z "$CUSTOM_BUILD" ]]; then
    echo "Custom build: $CUSTOM_BUILD"
fi

if [[ -n $FLAGS ]]; then
    echo "Flags: $FLAGS"
fi

if [[ "$(systemctl is-active docker)" = "active" && -z $DISABLE_DOCKER ]]; then
    echo "Creating docker image"
    ./create-image.sh
    echo "Building in docker container"
    ./build-in-docker.sh
else
    echo "Building in Linux"
    ./build-in-linux.sh
fi

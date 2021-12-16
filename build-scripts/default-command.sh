#!/bin/bash

cd ${BUILDBASE}

if [[ "$(ls -A ./android/lineage)" ]]; then
    echo "Sources found. Skipping..."
else
    if [[ -d ./Android ]] && [[ "$(cat /proc/version)" == *"microsoft"* ]];
    then  
        echo "WSL2 distro found with no case sensitivity, enabling NTFS case-sensitivity..."
        powershell.exe -File "./wsl_cs.ps1" -Buildbase "${BUILDBASE}"
    fi
    if [[ -z $DUMMY_BUILD ]]; then
        echo "Getting sources..."
        ./get-sources.sh
    else
        echo Dummy executed get-sources.sh
    fi
fi

if [[ -z $FLAGS || ! -z ${FLAGS##*noupdate*} ]]; then
    if [[ -z $DUMMY_BUILD ]]; then
        cd ${BUILDBASE}/android/lineage
        ./.repo/local_manifests/snack/snack.sh -y
    else
        echo Dummy executed snack and updated
    fi
else
    if [[ -z $DUMMY_BUILD ]]; then
        cd ${BUILDBASE}/android/lineage
        ./.repo/local_manifests/snack/snack.sh -n -w
    else
        echo Dummy executed snack without updating
    fi
fi

if [[ -z $FLAGS || ! -z ${FLAGS##*eng*} ]]; then
    if [[ -z $DUMMY_BUILD ]]; then
        export BUILD_TYPE=userdebug
    else
        echo Dummy set userdebug
    fi
else
    if [[ -z $DUMMY_BUILD ]]; then
        export BUILD_TYPE=eng
    else
        echo Dummy set eng
    fi
fi

if [[ -z $FLAGS || ! -z ${FLAGS##*nobuild*} ]]; then
    if [[ -z $DUMMY_BUILD ]]; then
        cd ${BUILDBASE}
        ./build.sh
        RESULT=$?
        if [[ $RESULT -ne 0 ]]; then
            exit -1
        fi
    else
        echo Dummy executed build.sh
    fi
fi

if [[ "$ROM_TYPE" == "zip" ]]; then
    if [[ -z $FLAGS || ! -z ${FLAGS##*nooutput*} ]]; then
        if [[ -z $DUMMY_BUILD ]]; then
            echo "Copying output to ./android/output..."
            cd ${BUILDBASE}
            ./copy-to-output.sh
        else
            echo Dummy executed copy-to-output.sh
        fi
    fi
fi

# Ending message after built
echo \#\# ANDROID BUILD COMPLETE. Please move contents of the android/output directory to the root of your SD card. 
echo \#\# For more detailed instructions, check the repository readme: https://github.com/PabloZaiden/switchroot-android-build

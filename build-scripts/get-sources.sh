#!/bin/bash

JOBS=$(($(nproc) - 1)) # Google guidelines for `repo`

cd ${BUILDBASE}/android/lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-19.0

git clone https://gitlab.com/switchroot/android/manifest.git -b lineage-19.0 .repo/local_manifests --recursive
repo sync -j${JOBS} --force-sync

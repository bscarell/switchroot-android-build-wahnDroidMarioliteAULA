#!/bin/bash

cd ${BUILDBASE}/android/lineage/
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py -t nvidia-enhancements-q
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py -t nvidia-nvgpu-q
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py -t icosa-bt-lineage-17.1
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py 287339
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py 284553

# Temporary patch to use current coreboot

cd ${BUILDBASE}/android/lineage/bionic
patch -p1 < ${BUILDBASE}/android/lineage/.repo/local_manifests/patches/bionic_intrinsics.patch
cd ${BUILDBASE}/android/lineage/frameworks/base
patch -p1 < ${BUILDBASE}/android/lineage/.repo/local_manifests/patches/frameworks_base_nvcpl.patch
cd ${BUILDBASE}/android/lineage/kernel/nvidia/linux-4.9/kernel/kernel-4.9
patch -p1 < ${BUILDBASE}/android/lineage/.repo/local_manifests/patches/oc-android10.patch
cd ${BUILDBASE}/android/lineage/hardware/nvidia/platform/t210/icosa
patch -p1 < ${BUILDBASE}/android/lineage/.repo/local_manifests/patches/wdt.patch
cd ${BUILDBASE}/android/lineage/hardware/nintendo/joycond
patch -p1 < ${BUILDBASE}/android/lineage/.repo/local_manifests/patches/joycond10.patch

#!/bin/bash

JOBS=$(($(nproc) + 1))

echo lineage_$ROM_NAME-$BUILD_TYPE

cd ${BUILDBASE}/android/lineage
source build/envsetup.sh

if [[ -z $FLAGS || ! -z ${FLAGS##*noccache*} ]]; then
  echo CCACHE of 50G will be used
  export USE_CCACHE=1
  export CCACHE_EXEC=$(which ccache)
  export WITHOUT_CHECK_API=true
  ccache -M 50G
else
  echo CCACHE will be disabled
  export USE_CCACHE=0
fi
lunch lineage_$ROM_NAME-$BUILD_TYPE

if [[ ! -z "$CUSTOM_BUILD" ]]; then
  nice $CUSTOM_BUILD
elif [[ "$ROM_TYPE" == "zip" ]]; then
  nice make -j${JOBS} bacon
else
  nice make -j${JOBS} bootimage && nice make -j${JOBS} vendorimage && nice make -j${JOBS} systemimage
fi

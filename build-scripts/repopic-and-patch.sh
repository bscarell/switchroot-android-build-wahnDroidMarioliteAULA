#!/bin/bash

cd ${BUILDBASE}/android/lineage/
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py -t icosa-bt-lineage-17.1
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py -t nvidia-shieldtech-q
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py -t nvidia-beyonder-q
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py 300860
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py 287339
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py 302339
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py 302554
${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py 284553

function applyPatches {
    PATCHES_FILE=$1

    while read -r line; do
        IFS=':' read -r -a parts <<< "$line"

        if [[ "${parts[2]}" == "git" ]]; then
            echo "Applying patch ${parts[1]} with git am"
            eval "cd ${parts[0]}"
            eval "git am ${parts[1]}"
            cd ${BUILDBASE}/android/lineage/
        else
            echo "Applying patch ${parts[1]} with patch"
            eval "patch -p1 -d ${parts[0]} -i ${parts[1]}"
        fi
    done < $PATCHES_FILE
} 

applyPatches "${BUILDBASE}/default-patches.txt"

if [[ -f "$EXTRA_CONTENT/patches.txt" ]]; then
    applyPatches "$EXTRA_CONTENT/patches.txt"
fi

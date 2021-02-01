#!/bin/bash

function applyRepopics {
    REPOPICS_FILE=$1

    cd ${BUILDBASE}/android/lineage/
    while IFS= read -r line; do
        echo "Applying repopic: $line"
        eval "${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py $line"

    done < $REPOPICS_FILE
}
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
applyRepopics "${BUILDBASE}/default-repopics.txt"

if [[ -f "$EXTRA_CONTENT/patches.txt" ]]; then
    applyPatches "$EXTRA_CONTENT/patches.txt"
fi

if [[ -f "$EXTRA_CONTENT/repopics.txt" ]]; then
    applyRepopics "$EXTRA_CONTENT/repopics.txt"
fi

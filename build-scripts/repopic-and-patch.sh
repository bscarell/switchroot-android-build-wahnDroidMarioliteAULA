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

if [[ -z $LOCAL_REPOPICS_PATCHES ]]; then
    curl -L -o /tmp/default-repopics.txt https://raw.githubusercontent.com/PabloZaiden/switchroot-android-build/master/build-scripts/default-repopics.txt
    curl -L -o /tmp/default-patches.txt https://raw.githubusercontent.com/PabloZaiden/switchroot-android-build/master/build-scripts/default-patches.txt
else
    cp "${BUILDBASE}/default-repopics.txt" /tmp/default-repopics.txt
    cp "${BUILDBASE}/default-patches.txt" /tmp/default-patches.txt
fi

applyPatches /tmp/default-repopics.txt
applyRepopics /tmp/default-patches.txt

if [[ -f "$EXTRA_CONTENT/repopics.txt" ]]; then
    applyRepopics "$EXTRA_CONTENT/repopics.txt"
fi

if [[ -f "$EXTRA_CONTENT/patches.txt" ]]; then
    applyPatches "$EXTRA_CONTENT/patches.txt"
fi
#!/bin/bash

function applyRepopics {
    REPOPICS_FILE=$1
    echo "Applying repopics from $REPOPICS_FILE"

    cd ${BUILDBASE}/android/lineage/
    while IFS= read -r line; do
        echo "Applying repopic: $line"
        eval "${BUILDBASE}/android/lineage/vendor/lineage/build/tools/repopick.py $line"

    done < $REPOPICS_FILE
}
function applyPatches {
    PATCHES_FILE=$1
    echo "Applying patches from $PATCHES_FILE"

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

rm /tmp/default-repopics.txt
rm /tmp/default-patches.txt

if [[ -z $LOCAL_REPOPICS_PATCHES ]]; then
    echo "Downloading repopics file..."
    curl -L -o /tmp/default-repopics.txt https://raw.githubusercontent.com/PabloZaiden/switchroot-android-build/master/build-scripts/default-repopics.txt
    
    echo "Downloading patches file..."
    curl -L -o /tmp/default-patches.txt https://raw.githubusercontent.com/PabloZaiden/switchroot-android-build/master/build-scripts/default-patches.txt
else
    echo "Copying local repopics file..."
    cp "${BUILDBASE}/default-repopics.txt" /tmp/default-repopics.txt
    
    echo "Copying local patches file..."
    cp "${BUILDBASE}/default-patches.txt" /tmp/default-patches.txt
fi

applyRepopics /tmp/default-repopics.txt
applyPatches /tmp/default-patches.txt

if [[ -f "$EXTRA_CONTENT/repopics.txt" ]]; then
    applyRepopics "$EXTRA_CONTENT/repopics.txt"
fi

if [[ -f "$EXTRA_CONTENT/patches.txt" ]]; then
    applyPatches "$EXTRA_CONTENT/patches.txt"
fi
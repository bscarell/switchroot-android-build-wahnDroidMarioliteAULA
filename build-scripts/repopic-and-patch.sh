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

function generatePatchesFile {
    PATCHES_FILE=$1
    PATCHES_DIR=${BUILDBASE}/android/lineage/.repo/local_manifests/patches
    CODE_DIR=${BUILDBASE}/android/lineage
    FOSTER_TAB_NAME=foster_tab
    FOSTER_TAB_TEMP_NAME=999fostertab999

    for PATCH_FILE in $PATCHES_DIR/*.patch
    do
        FILE_NAME=$(basename $PATCH_FILE)
        
        IFS='-' read -r PATCH_DIR PATCH_NAME <<< "$FILE_NAME"

        PATCH_DIR="${PATCH_DIR/$FOSTER_TAB_NAME/$FOSTER_TAB_TEMP_NAME}" 
        PATCH_DIR="${PATCH_DIR//\_//}" 
        PATCH_DIR="${PATCH_DIR/$FOSTER_TAB_TEMP_NAME/$FOSTER_TAB_NAME}" 

        echo $CODE_DIR/$PATCH_DIR:$PATCH_FILE >> $PATCHES_FILE
    done
    echo "" >> $PATCHES_FILE
}

rm /tmp/default-repopics.txt
rm /tmp/default-patches.txt

if [[ -z $LOCAL_REPOPICS_PATCHES ]]; then
    echo "Downloading repopics file..."
    curl -L -o /tmp/default-repopics.txt https://raw.githubusercontent.com/PabloZaiden/switchroot-android-build/master/build-scripts/default-repopics.txt
    
    echo "Generating patches file..."
    generatePatchesFile /tmp/default-patches.txt
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
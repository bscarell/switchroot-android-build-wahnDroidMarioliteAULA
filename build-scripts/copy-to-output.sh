#!/bin/bash

## This script copies the build output to the output dir
## so it can be used by hekate

cd ${BUILDBASE}

# set gapps default to pico
GAPPS="pico"

ZIP_FILE=$(ls ./android/lineage/out/target/product/$ROM_NAME/lineage-18.1-*-UNOFFICIAL-$ROM_NAME.zip | tail -1)

## Copy to output
echo "Creating switchroot install dir..."
mkdir -p ./android/output/switchroot/install
echo "Creating switchroot android dir..."
mkdir -p ./android/output/switchroot/android
echo "Downloading hekate..."
LATEST_HEKATE=$(curl -sL https://github.com/CTCaer/hekate/releases/latest | grep -o '/CTCaer/hekate/releases/download/.*/hekate_ctcaer.*zip')
curl -L -o ./hekate.zip https://github.com/$LATEST_HEKATE
unzip -u ./hekate.zip -d ./android/output/
echo "Creating bootloader config dir..."
mkdir -p ./android/output/bootloader/ini
echo "Copying build zip to SD Card..."
cp $ZIP_FILE ./android/output/
echo "Copying build combined kernel and ramdisk..."
cp ./android/lineage/out/target/product/$ROM_NAME/boot.img ./android/output/switchroot/install/
echo "Copying build dtb..."
cp ./android/lineage/out/target/product/$ROM_NAME/obj/KERNEL_OBJ/arch/arm64/boot/dts/tegra210-icosa.dtb ./android/output/switchroot/install/
echo "Downloading twrp..."
curl -L -o ./android/output/switchroot/install/twrp.img https://github.com/PabloZaiden/switchroot-android-build/raw/master/external/twrp.img
echo "Downloading coreboot.rom..."
curl -L -o ./android/output/switchroot/android/coreboot.rom https://github.com/PabloZaiden/switchroot-android-build/raw/master/external/coreboot.rom
echo "Downloading 00-android.ini..."
curl -L -o ./android/output/bootloader/ini/00-android.ini https://gitlab.com/ZachyCatGames/shitty-pie-guide/-/raw/master/res/00-android.ini?inline=false
echo "Downloading boot scripts..."
curl -L -o ./android/output/switchroot/android/common.scr https://gitlab.com/switchroot/bootstack/switch-uboot-scripts/-/jobs/artifacts/master/raw/common.scr?job=build
curl -L -o ./android/output/switchroot/android/boot.scr https://gitlab.com/switchroot/bootstack/switch-uboot-scripts/-/jobs/artifacts/master/raw/sd.scr?job=build

# swap gapps type to tvmini for atv
if [[ $ROM_NAME = "icosa_tv_sr" ]]; then
	GAPPS="tvmini"
fi

echo "Downloading $GAPPS Open GApps..."

# get base URL for gapps
BASE_GAPPS_URL=$(curl -L https://sourceforge.net/projects/opengapps/rss?path=/arm64 \
	| grep -Po "https:\/\/.*11\.0-$GAPPS.*zip\/download" \
	| head -n 1 \
	| sed "s/\/download//" \
	| sed "s/files\///" \
	| sed "s/projects/project/" \
	| sed "s/sourceforge/downloads\.sourceforge/")

TIMESTAMP=$(echo $(( $(date '+%s%N') / 1000000000)))
FULL_GAPPS_URL=$(echo $BASE_GAPPS_URL"?use_mirror=autoselect&ts="$TIMESTAMP)
curl -L -o ./android/output/opengapps_$GAPPS.zip $FULL_GAPPS_URL

## Patch zip file to accept any bootloader version
OUTPUT_ZIP_FILE=$(ls ./android/output/lineage-18.1-*-UNOFFICIAL-$ROM_NAME.zip | tail -1)

mkdir -p ./META-INF/com/google/android/
unzip -p $OUTPUT_ZIP_FILE META-INF/com/google/android/updater-script > ./META-INF/com/google/android/updater-script.original
sed -E 's/getprop\(\"ro\.bootloader\"\)/true || getprop\(\"ro\.bootloader\"\)/g' < ./META-INF/com/google/android/updater-script.original > ./META-INF/com/google/android/updater-script
rm ./META-INF/com/google/android/updater-script.original
zip -u $OUTPUT_ZIP_FILE META-INF/com/google/android/updater-script
rm -rf ./META-INF/com/google/android/

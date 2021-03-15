#!/bin/bash

MANIFEST=git://github.com/crdroidandroid/android.git
BRANCH=11.0

mkdir -p /tmp/rom
cd /tmp/rom

# Repo init command, that -device,-mips,-darwin,-notdefault part will save you more time and storage to sync, add more according to your rom and choice. Optimization is welcomed! Let's make it quit, and with depth=1 so that no unnecessary things.
repo init --no-repo-verify --depth=1 -u "$MANIFEST" -b "$BRANCH" -g default,-device,-mips,-darwin,-notdefault

# Sync source with -q, no need unnecessary messages, you can remove -q if want! try with -j30 first, if fails, it will try again with -j8
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j30 || repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
rm -rf .repo

# Sync device tree and stuffs
git clone -b lineage-18.1 --depth=1 https://github.com/LineageOS/android_device_motorola_channel/ device/motorola/channel
git clone -b lineage-18.1 --depth=1 https://github.com/LineageOS/android_device_motorola_sdm632-common/ device/motorola/sdm632-common
git clone -b lineage-18.1 --depth=1 https://github.com/LineageOS/android_kernel_motorola_sdm632/ kernel/motorola/sdm632
git clone -b lineage-18.1 --depth=1 https://github.com/TheMuppets/proprietary_vendor_motorola vendor/motorola
git clone -b lineage-18.1 --depth=1 https://github.com/LineageOS/android_hardware_motorola/ hardware/motorola
git clone -b lineage-18.1 --depth=1 https://github.com/LineageOS/android_system_qcom/ system/qcom
git clone -b lineage-18.1 --depth=1 https://github.com/LineageOS/android_external_bson/ external/bson

# Normal build steps
. build/envsetup.sh
lunch lineage_channel-userdebug

# upload function for uploading rom zip file! I don't want unwanted builds in my google drive haha!
up(){
	curl --upload-file $1 https://oshi.at/$(basename $1); echo
	# 14 days, 10 GB limit
}

make bacon -j12
up out/target/product/channel/*zip
up out/target/product/channel/*json

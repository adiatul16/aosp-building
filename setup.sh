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
rm -rf hardware/qcom-caf/msm8998/display hardware/qcom-caf/msm8998/audio hardware/qcom-caf/msm8998/media &&  git clone https://github.com/LineageOS/android_hardware_qcom_display --single-branch -b lineage-18.1-caf-msm8998 hardware/qcom-caf/msm8998/display && git clone https://github.com/LineageOS/android_hardware_qcom_audio --single-branch -b lineage-18.1-caf-msm8998 hardware/qcom-caf/msm8998/audio && git clone https://github.com/LineageOS/android_hardware_qcom_media --single-branch -b lineage-18.1-caf-msm8998 hardware/qcom-caf/msm8998/media
rm -rf device/xiaomi vendor/xiaomi kernel/xiaomi && git clone https://github.com/ItsVixano/android_device_xiaomi_whyred --single-branch -b eleven device/xiaomi/whyred && git clone https://github.com/ItsVixano/android_vendor_xiaomi_whyred --single-branch -b eleven vendor/xiaomi/whyred --depth=1 && git clone https://github.com/SreekanthPalakurthi/kranul --single-branch --depth=1 kernel/xiaomi/whyred
rm -rf system/sepolicy && git clone https://github.com/Bauh-Yeoj/android_system_sepolicy system/sepolicy

# Normal build steps
. build/envsetup.sh
lunch lineage_whyred-user
export SELINUX_IGNORE_NEVERALLOWS=true

# upload function for uploading rom zip file! I don't want unwanted builds in my google drive haha!
up(){
	curl --upload-file $1 https://transfer.sh/$(basename $1); echo
	# 14 days, 10 GB limit
}

make bacon -j12
up out/target/product/whyred/*zip

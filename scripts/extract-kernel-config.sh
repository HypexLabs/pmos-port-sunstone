#!/bin/sh
# Extract the running kernel config from the device
# Requires: adb, root access on device
set -e

echo "Extracting kernel config from device via adb..."
adb shell "zcat /proc/config.gz 2>/dev/null || cat /proc/config 2>/dev/null" > extracted_config

if [ ! -s extracted_config ]; then
	echo "Trying alternative method..."
	adb shell "su -c 'cat /proc/config.gz'" 2>/dev/null | zcat > extracted_config 2>/dev/null || {
		adb shell "su -c 'cat /proc/config'" > extracted_config 2>/dev/null
	}
fi

if [ -s extracted_config ]; then
	mkdir -p ../kernel/linux-xiaomi-sunstone/config/vendor
	cp extracted_config ../kernel/linux-xiaomi-sunstone/config/vendor/holi_defconfig
	echo "Config saved to kernel/linux-xiaomi-sunstone/config/vendor/holi_defconfig"
else
	echo "Failed to extract kernel config."
	echo "Make sure your device is rooted and connected via adb."
	exit 1
fi

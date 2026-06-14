#!/bin/sh
# Extract firmware blobs from Xiaomi stock ROM (sunstone)
# Usage: ./extract-firmware.sh <path-to-fastboot-rom.tgz>

set -e

if [ $# -ne 1 ]; then
	echo "Usage: $0 <path-to-fastboot-rom.tgz>"
	echo ""
	echo "Download the stock ROM from:"
	echo "  https://mifirm.net/model/sunstone.ttt"
	echo "  Version: OS2.0.6.0.UMQCNXM (China)"
	exit 1
fi

ROM="$1"
OUTDIR="$(dirname "$0")/output"

if [ ! -f "$ROM" ]; then
	echo "Error: $ROM not found"
	exit 1
fi

echo "Extracting stock ROM..."
mkdir -p "$OUTDIR"
tar -xzf "$ROM" -C "$OUTDIR"

IMGDIR="$OUTDIR/images"
FW_OUT="$OUTDIR/firmware"
mkdir -p "$FW_OUT"

echo "Extracting vendor.img..."
if [ -f "$IMGDIR/vendor.img" ]; then
	# Extract vendor.img using simg2img or directly mount
	if command -v simg2img >/dev/null 2>&1; then
		simg2img "$IMGDIR/vendor.img" "$OUTDIR/vendor_raw.img"
		mkdir -p "$OUTDIR/vendor_mnt"
		mount -o loop "$OUTDIR/vendor_raw.img" "$OUTDIR/vendor_mnt" 2>/dev/null || {
			echo "Mount failed, trying to extract with debugfs..."
		}
	else
		echo "simg2img not found, installing..."
		pkg install android-tools 2>/dev/null || apt install simg2img 2>/dev/null
		if command -v simg2img >/dev/null 2>&1; then
			simg2img "$IMGDIR/vendor.img" "$OUTDIR/vendor_raw.img"
		else
			echo "Cannot extract vendor.img without simg2img"
			echo "Install it: pkg install android-tools  # Termux"
			echo "            apt install simg2img       # Debian/Ubuntu"
			exit 1
		fi
	fi
fi

# Copy firmware blobs
echo "Copying firmware blobs..."
FW_TARGET="../device/device-xiaomi-sunstone/firmware"
mkdir -p "$FW_TARGET"

# Modem firmware
if [ -d "$OUTDIR/vendor_mnt/firmware" ]; then
	cp -r "$OUTDIR/vendor_mnt/firmware/"* "$FW_TARGET/" 2>/dev/null || true
fi

# WiFi firmware
if [ -d "$OUTDIR/vendor_mnt/firmware/wlan" ]; then
	cp -r "$OUTDIR/vendor_mnt/firmware/wlan/"* "$FW_TARGET/" 2>/dev/null || true
fi

# Adreno (GPU) firmware
if [ -d "$OUTDIR/vendor_mnt/firmware/a*" ]; then
	cp -r "$OUTDIR/vendor_mnt/firmware/a"* "$FW_TARGET/" 2>/dev/null || true
fi

# DSP firmware
if [ -d "$OUTDIR/vendor_mnt/dsp" ]; then
	mkdir -p "$FW_TARGET/dsp"
	cp -r "$OUTDIR/vendor_mnt/dsp/"* "$FW_TARGET/dsp/" 2>/dev/null || true
fi

echo "Firmware blobs extracted to: $FW_TARGET"
echo ""
echo "Next step: Update the device-xiaomi-sunstone APKBUILD"
echo "to include these firmware files."

# Cleanup
umount "$OUTDIR/vendor_mnt" 2>/dev/null || true
rm -rf "$OUTDIR/vendor_mnt" "$OUTDIR/vendor_raw.img" 2>/dev/null || true
echo "Done."

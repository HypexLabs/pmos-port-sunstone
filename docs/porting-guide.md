# Porting Guide: Redmi Note 12 5G (sunstone)

## Prerequisites

1. A Linux x86_64 PC (or VM)
2. Unlocked bootloader (Mi Unlock - 7 day wait)
3. USB cable
4. ~10 GB internet data
5. Basic knowledge of Linux CLI and kernel building

## Step 1: Unlock Bootloader

1. Apply via [Mi Unlock](https://en.miui.com/unlock/)
2. Wait 7 days (required by Xiaomi)
3. Unlock using Mi Unlock tool on Windows (or via `fastboot oem unlock`)

## Step 2: Set Up Build Environment

```bash
# Install pmbootstrap
git clone https://gitlab.com/postmarketOS/pmbootstrap
cd pmbootstrap
pip install .

# Clone this port repo
git clone https://github.com/HypexLabs/pmos-port-sunstone
cd pmos-port-sunstone

# Initialize pmbootstrap
pmbootstrap init
```

During `pmbootstrap init`:
- Work path: default is fine
- Channel: `edge`
- Vendor: `xiaomi`
- Device codename: `sunstone` (if not listed, select "Tester device")

## Step 3: Extract Firmware

```bash
# Download stock ROM OS2.0.6.0.UMQCNXM from:
# https://mifirm.net/model/sunstone.ttt
cd firmware
./extract-firmware.sh ~/Downloads/sunstone_global_images_OS2.0.6.0.UMQCNXM.tgz
```

## Step 4: Configure Kernel

The default defconfig should be at `kernel/linux-xiaomi-sunstone/config/vendor/holi_defconfig`.

To fine-tune it for postmarketOS:

```bash
cd kernel/linux-xiaomi-sunstone
pmbootstrap kconfig edit linux-xiaomi-sunstone
```

Key kernel options needed:
- `CONFIG_DEVTMPFS=y`
- `CONFIG_EXT4_FS=y`
- `CONFIG_F2FS_FS=y` (optional)
- `CONFIG_OVERLAY_FS=y` (for final)
- Disable Android-specific configs not needed for Linux

## Step 5: Build

```bash
pmbootstrap build linux-xiaomi-sunstone --arch=aarch64
pmbootstrap build device-xiaomi-sunstone --arch=aarch64
pmbootstrap install
```

## Step 6: Flash

```bash
# Boot device into fastboot mode (Vol Down + Power)
pmbootstrap flasher flash_kernel
pmbootstrap flasher flash_system
```

## Step 7: First Boot

- Device should boot to postmarketOS initramfs
- You'll be prompted for disk encryption password (set during `pmbootstrap install`)
- After boot, connect via SSH:
  ```bash
  sudo dhclient usb0
  ssh user@172.16.42.1
  ```

## Troubleshooting

### Device doesn't boot
- Connect USB serial adapter to UART test points (if available)
- Check kernel log: `adb shell dmesg` (if Android still boots)

### Kernel build fails
- Ensure clang version matches what Xiaomi used
- Try `make CC=clang LLVM=1` instead of gcc

### No display output
- Verify DTB name in deviceinfo matches actual compiled DT
- Check cmdline parameters for display panel ID

## References

- [postmarketOS Wiki: Porting to a new device](https://wiki.postmarketos.org/wiki/Porting_to_a_new_device)
- [postmarketOS Wiki: deviceinfo reference](https://wiki.postmarketos.org/wiki/Deviceinfo_reference)
- [Xiaomi Kernel OpenSource](https://github.com/MiCode/Xiaomi_Kernel_OpenSource)
- [pmbootstrap usage](https://wiki.postmarketos.org/wiki/Installing_pmbootstrap)

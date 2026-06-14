# postmarketOS port for Xiaomi Redmi Note 12 5G (sunstone)

**Codename**: `sunstone` (model 22111317G)  
**SoC**: Qualcomm Snapdragon 4 Gen 1 (SM4375 / holi)  
**Status**: ⚠️ Downstream (initial porting in progress)

## Resources

| Resource | Link |
|---|---|
| Kernel source | [anth-unv-gm/android_kernel_xiaomi_stone](https://github.com/anth-unv-gm/android_kernel_xiaomi_stone) (branch `meme`) |
| Stock firmware (China) | OS2.0.6.0.UMQCNXM from [mifirm.net](https://mifirm.net/model/sunstone.ttt) |
| pmaports | [postmarketOS/pmaports](https://gitlab.com/postmarketOS/pmaports) |
| pmbootstrap | [postmarketOS/pmbootstrap](https://gitlab.com/postmarketOS/pmbootstrap) |

## Porting Progress

- [ ] Kernel builds standalone
- [ ] device-xiaomi-sunstone package created
- [ ] Kernel boots to shell
- [ ] Display working
- [ ] Touch working
- [ ] USB networking (SSH)
- [ ] WiFi working
- [ ] Modem / calls / SMS

## Quick Start

```bash
# On an x86_64 Linux PC:
git clone https://github.com/HypexLabs/pmos-port-sunstone
cd pmos-port-sunstone

# Install pmbootstrap
pip install pmbootstrap

# Initialize (choose your own work path)
pmbootstrap init

# Build the kernel
pmbootstrap build linux-xiaomi-sunstone --arch=aarch64

# Build device package
pmbootstrap build device-xiaomi-sunstone --arch=aarch64

# Install (creates flashable images)
pmbootstrap install

# Flash (device must be in fastboot mode)
pmbootstrap flasher flash_kernel
pmbootstrap flasher flash_system
```

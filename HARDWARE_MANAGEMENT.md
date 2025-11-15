# Hardware Interface Management Guide

This guide explains how to manage Raspberry Pi hardware interfaces (I2C, SPI, GPIO, PWM) and custom applications in your Yocto build.

## 📁 Custom Layer Structure

```
meta-raspi-custom/
├── conf/
│   └── layer.conf                          # Layer configuration
├── recipes-kernel/
│   └── linux/
│       ├── linux-raspberrypi_%.bbappend    # Kernel configuration
│       └── linux-raspberrypi/
│           ├── custom-hardware.cfg          # Hardware interface kernel config
│           └── device-tree-overlays/        # Device tree overlays
│               ├── i2c-enable.dts          # I2C enablement
│               └── spi-enable.dts          # SPI enablement
├── recipes-core/
│   ├── base-files/
│   │   ├── base-files_%.bbappend           # Boot configuration
│   │   └── files/
│   │       └── config-custom.txt           # Custom boot config
│   └── images/
│       └── custom-raspi-image.bb           # Custom image recipe
└── recipes-apps/
    └── my-custom-app/
        ├── my-custom-app_1.0.bb            # Custom app recipe
        └── files/
            ├── raspi-hw-test.c              # Example C application
            └── Makefile                     # Build configuration
```

## 🔧 Hardware Interface Configuration

### I2C Configuration
**Location**: `meta-raspi-custom/recipes-kernel/linux/linux-raspberrypi/custom-hardware.cfg`

```bash
# Enable I2C in kernel
CONFIG_I2C=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_BCM2835=y
```

**Boot Configuration**: `meta-raspi-custom/recipes-core/base-files/files/config-custom.txt`
```bash
# Enable I2C interface
dtparam=i2c_arm=on
dtparam=i2c1=on
```

**Device Tree Overlay**: `meta-raspi-custom/recipes-kernel/linux/linux-raspberrypi/device-tree-overlays/i2c-enable.dts`

### SPI Configuration
**Kernel Config**:
```bash
CONFIG_SPI=y
CONFIG_SPI_BCM2835=y
CONFIG_SPI_SPIDEV=y
```

**Boot Config**:
```bash
dtparam=spi=on
```

**Device Tree Overlay**: `spi-enable.dts`

### GPIO Configuration
**Kernel Config**:
```bash
CONFIG_GPIOLIB=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_BCM_VIRT=y
```

**Boot Config**:
```bash
dtparam=gpio=on
```

### PWM Configuration
**Kernel Config**:
```bash
CONFIG_PWM=y
CONFIG_PWM_BCM2835=y
CONFIG_PWM_SYSFS=y
```

**Boot Config**:
```bash
dtparam=pwm=on
```

## 📱 Adding Custom Applications

### 1. Create Recipe Directory
```bash
mkdir -p meta-raspi-custom/recipes-apps/your-app-name/files
```

### 2. Add Source Code
Place your application source code in the `files/` directory:
- C/C++ source files
- Makefiles
- Configuration files
- Scripts

### 3. Create Recipe File
Create `your-app-name_1.0.bb`:

```bash
SUMMARY = "Your custom application"
DESCRIPTION = "Description of what your app does"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://your-source.c file://Makefile"
S = "${WORKDIR}"

do_compile() {
    oe_runmake
}

do_install() {
    oe_runmake install DESTDIR=${D}
}

FILES:${PN} += "/usr/bin/your-app"
DEPENDS = "dependency1 dependency2"
RDEPENDS:${PN} = "runtime-dep1 runtime-dep2"
```

### 4. Add to Image
Edit `meta-raspi-custom/recipes-core/images/custom-raspi-image.bb`:

```bash
IMAGE_INSTALL += "your-app-name"
```

## 🚀 Building Custom Images

### Build with Hardware Support
```bash
# Source environment
source yocto-env.sh

# Build custom image with all hardware interfaces enabled
./build-yocto.sh raspberrypi4-64 custom-raspi-image
```

### Available Images
- `core-image-minimal` - Basic image
- `core-image-base` - Base image with utilities
- `custom-raspi-image` - **Your custom image with hardware support**

## 🔧 Modifying Hardware Configuration

### Enable Additional Interfaces

1. **UART/Serial**:
   ```bash
   # In config-custom.txt
   enable_uart=1
   ```

2. **Camera**:
   ```bash
   # In config-custom.txt
   dtparam=camera=on
   start_x=1
   gpu_mem=128
   ```

3. **1-Wire**:
   ```bash
   # In config-custom.txt
   dtoverlay=w1-gpio
   ```

### Disable Interfaces
Comment out or remove the corresponding lines in:
- `custom-hardware.cfg` (kernel config)
- `config-custom.txt` (boot config)
- Device tree overlay files

## 🛠 Testing Hardware Interfaces

After building and flashing your image:

### Test I2C
```bash
# Scan for I2C devices
i2cdetect -y 1

# Test with custom app
raspi-hw-test
```

### Test SPI
```bash
# List SPI devices
ls /dev/spi*

# Test with custom app
raspi-hw-test
```

### Test GPIO
```bash
# Export GPIO pin
echo 18 > /sys/class/gpio/export

# Set as output
echo out > /sys/class/gpio/gpio18/direction

# Set high
echo 1 > /sys/class/gpio/gpio18/value

# Test with custom app
raspi-hw-test
```

## 📦 Package Management

### Adding Python Packages
```bash
# In custom-raspi-image.bb
IMAGE_INSTALL += " \
    python3-pip \
    python3-smbus \
    python3-spidev \
    python3-rpi-gpio \
"
```

### Adding Development Tools
```bash
IMAGE_INSTALL += " \
    gcc \
    make \
    cmake \
    git \
    gdb \
"
```

## 🔍 Debugging

### Check Kernel Modules
```bash
lsmod | grep -E "i2c|spi|gpio"
```

### Check Device Tree
```bash
dtc -I fs -O dts /sys/firmware/devicetree/base
```

### Check Boot Configuration
```bash
cat /boot/config.txt
```

### View Kernel Messages
```bash
dmesg | grep -E "i2c|spi|gpio"
```

## 🎯 Common Use Cases

### IoT Sensor Projects
- Enable I2C for temperature/humidity sensors
- Enable SPI for accelerometers/gyroscopes
- Add Python support for rapid prototyping

### Industrial Control
- Enable all interfaces (I2C, SPI, GPIO, PWM)
- Add real-time kernel patches
- Include CAN bus support

### Camera Projects
- Enable camera interface
- Increase GPU memory
- Add video processing libraries

## 📋 Best Practices

1. **Version Control**: Always commit changes to `meta-raspi-custom/`
2. **Documentation**: Document any custom configuration changes
3. **Testing**: Test on actual hardware before deployment
4. **Security**: Remove debug features for production builds
5. **Optimization**: Adjust `IMAGE_ROOTFS_SIZE` based on your needs

## 🔗 Related Files

- `${WORKSPACE}/Yocto_PI/meta-raspi-custom/` - Your custom layer
- `${WORKSPACE}/Yocto_PI/build-yocto.sh` - Build script
- `${WORKSPACE}/Yocto_PI/.gitignore` - Git ignore rules
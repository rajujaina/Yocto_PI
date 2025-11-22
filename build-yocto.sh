#!/bin/bash

# Yocto Build Script
# Usage: ./build-yocto.sh [MACHINE] [IMAGE]

set -e

# Default values
MACHINE=${1:-raspberrypi4-64}
IMAGE=${2:-core-image-minimal}
BUILD_DIR="build-${MACHINE}-${IMAGE}"

echo "Building Yocto image..."
echo "Machine: $MACHINE"  
echo "Image: $IMAGE"
echo "Build Directory: $BUILD_DIR"

# Source environment variables
if [ -f "./yocto-env.sh" ]; then
    source ./yocto-env.sh
fi

# Initialize build environment
source poky/oe-init-build-env $BUILD_DIR

# Configure local.conf if this is first run
if [ ! -f conf/local.conf.orig ]; then
    cp conf/local.conf conf/local.conf.orig
    
    # Set machine
    sed -i "s/^MACHINE ??= .*/MACHINE ??= \"$MACHINE\"/" conf/local.conf
    
    # Add shared directories
    cat >> conf/local.conf << EOL

# Shared download and sstate directories
DL_DIR = "${DL_DIR}"
SSTATE_DIR = "${SSTATE_DIR}"

# Optimize build
BB_NUMBER_THREADS = "${BB_NUMBER_THREADS}"
PARALLEL_MAKE = "${PARALLEL_MAKE}"

# Enable disk monitoring
BB_DISKMON_DIRS = "${BB_DISKMON_DIRS}"

# Enable custom hardware features
ENABLE_I2C = "1"
ENABLE_SPI = "1"
ENABLE_UART = "1"

# Network connectivity fix for WSL2/restricted networks
# Disable connectivity check since we have sources cached
BB_NO_NETWORK = "0"
CONNECTIVITY_CHECK_URIS = ""

# Skip network check if all sources are cached
SANITY_TESTED_DISTROS = ""

EOL
fi

# Add meta-raspberrypi layer to bblayers.conf if not already added
if ! grep -q "meta-raspberrypi" conf/bblayers.conf; then
    bitbake-layers add-layer ../meta-raspberrypi
fi

# Add custom layer to bblayers.conf if not already added
if ! grep -q "meta-raspi-custom" conf/bblayers.conf; then
    bitbake-layers add-layer ../meta-raspi-custom
fi

# Start the build
echo "Starting build for $IMAGE..."
time bitbake $IMAGE

echo "Build completed successfully!"
echo "Image location: ${BUILD_DIR}/tmp/deploy/images/${MACHINE}/"
echo ""
echo "Key files generated:"
echo "  - SD card image: ${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.wic.bz2"
echo "  - Root filesystem: ${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.ext3"
echo "  - Kernel: ${BUILD_DIR}/tmp/deploy/images/${MACHINE}/Image-${MACHINE}.bin"
echo ""
echo "To flash to SD card:"
echo "  bunzip2 -k ${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.wic.bz2"
echo "  sudo dd if=${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.wic of=/dev/sdX bs=4M status=progress"

# Minimal test image to verify our layer works
SUMMARY = "Minimal test image for Raspberry Pi"
DESCRIPTION = "A minimal test image to validate our custom layer"

LICENSE = "MIT"

inherit core-image

# Base image to extend from  
require recipes-core/images/core-image-minimal.bb

# Basic packages only
IMAGE_INSTALL += " \
    i2c-tools \
    openssh \
    kernel-modules \
"

# Enable features
IMAGE_FEATURES += "ssh-server-openssh"

# Set smaller root filesystem size for testing (1GB)
IMAGE_ROOTFS_SIZE = "1048576"
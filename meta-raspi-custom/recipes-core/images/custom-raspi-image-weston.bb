# Custom Raspberry Pi image with Weston GUI and hardware interface support
SUMMARY = "Custom Raspberry Pi image with Weston/Wayland, I2C, SPI, GPIO support"
DESCRIPTION = "A custom Yocto image for Raspberry Pi with Weston GUI and enabled hardware interfaces"

# Inherit from core-image to build on top of it
require recipes-core/images/core-image-base.bb

LICENSE = "MIT"

# Image features - add GUI support
IMAGE_FEATURES += " \
    ssh-server-openssh \
    debug-tweaks \
    dev-pkgs \
    tools-sdk \
    package-management \
    splash \
    hwcodecs \
    weston \
"

# DISTRO_FEATURES for Wayland
DISTRO_FEATURES:append = " wayland"

# Install Weston and its dependencies
IMAGE_INSTALL += " \
    weston \
    weston-init \
    weston-examples \
"

# Additional packages for hardware interface support
IMAGE_INSTALL += " \
    i2c-tools \
    python3 \
    kernel-modules \
"

# Development tools
IMAGE_INSTALL += " \
    make \
    git \
    vim \
"

# Network tools
IMAGE_INSTALL += " \
    openssh \
"

# Set root filesystem size (in KB) - larger for GUI (4GB)
IMAGE_ROOTFS_SIZE = "4194304"

# Create pi user with password: 1234
# Root is also enabled with same password
inherit extrausers
EXTRA_USERS_PARAMS = " \
    usermod -p '\$1\$obm0/KCQ\$aohbe.LhE4Q8aKI963Pso/' root; \
    useradd -p '\$1\$obm0/KCQ\$aohbe.LhE4Q8aKI963Pso/' -G sudo,i2c,spi,gpio -m pi; \
"

# Post-installation scripts for hardware setup
ROOTFS_POSTPROCESS_COMMAND += "setup_hardware_interfaces; "

setup_hardware_interfaces() {
    # Create udev rules for hardware access
    install -d ${IMAGE_ROOTFS}/etc/udev/rules.d
    
    # Allow users to access I2C without sudo
    echo 'SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0664"' > ${IMAGE_ROOTFS}/etc/udev/rules.d/99-i2c.rules
    
    # Allow users to access SPI without sudo  
    echo 'SUBSYSTEM=="spidev", GROUP="spi", MODE="0664"' > ${IMAGE_ROOTFS}/etc/udev/rules.d/99-spi.rules
    
    # Allow users to access GPIO without sudo
    echo 'SUBSYSTEM=="gpio", GROUP="gpio", MODE="0664"' > ${IMAGE_ROOTFS}/etc/udev/rules.d/99-gpio.rules
    
    # Create groups for hardware access
    install -d ${IMAGE_ROOTFS}/etc
    echo "i2c:x:997:" >> ${IMAGE_ROOTFS}/etc/group
    echo "spi:x:996:" >> ${IMAGE_ROOTFS}/etc/group  
    echo "gpio:x:995:" >> ${IMAGE_ROOTFS}/etc/group
}

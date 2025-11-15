# Custom Raspberry Pi image with hardware interface support
SUMMARY = "Custom Raspberry Pi image with I2C, SPI, GPIO, and custom applications"
DESCRIPTION = "A custom Yocto image for Raspberry Pi with enabled hardware interfaces and custom applications"

# Base image to extend
require recipes-core/images/core-image-base.bb

# Image features
IMAGE_FEATURES += " \
    ssh-server-openssh \
    debug-tweaks \
    dev-pkgs \
    tools-sdk \
    package-management \
"

# Additional packages for hardware interface support
IMAGE_INSTALL += " \
    i2c-tools \
    spitools \
    gpio-utils \
    python3 \
    python3-pip \
    python3-smbus \
    python3-spidev \
    python3-rpi-gpio \
    my-custom-app \
    kernel-modules \
    kernel-module-i2c-dev \
    kernel-module-spi-bcm2835 \
    kernel-module-spidev \
    dtc \
"

# Development tools
IMAGE_INSTALL += " \
    gcc \
    g++ \
    make \
    cmake \
    git \
    vim \
    nano \
    htop \
    strace \
    gdb \
    valgrind \
"

# Network tools
IMAGE_INSTALL += " \
    curl \
    wget \
    openssh \
    dropbear \
    wpa-supplicant \
    iw \
    wireless-regdb \
    wireless-tools \
"

# Multimedia and camera support
IMAGE_INSTALL += " \
    v4l-utils \
    media-ctl \
    ffmpeg \
"

# Set root filesystem size (in KB) - adjust as needed
IMAGE_ROOTFS_SIZE = "2097152"  # 2GB

# Set root password for debug builds (remove in production)
inherit extrausers
EXTRA_USERS_PARAMS = "usermod -p '\$6\$rounds=4096\$salt\$raspi123' root;"

# Post-installation scripts
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
    echo 'SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="/bin/chgrp gpio /sys/class/gpio/export /sys/class/gpio/unexport", RUN+="/bin/chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport"' >> ${IMAGE_ROOTFS}/etc/udev/rules.d/99-gpio.rules
    
    # Create groups for hardware access
    install -d ${IMAGE_ROOTFS}/etc
    echo "i2c:x:997:" >> ${IMAGE_ROOTFS}/etc/group
    echo "spi:x:996:" >> ${IMAGE_ROOTFS}/etc/group  
    echo "gpio:x:995:" >> ${IMAGE_ROOTFS}/etc/group
    
    # Create a startup script for hardware initialization
    install -d ${IMAGE_ROOTFS}/etc/init.d
    cat > ${IMAGE_ROOTFS}/etc/init.d/hardware-init << 'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides: hardware-init
# Required-Start: $local_fs
# Required-Stop: $local_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Initialize Raspberry Pi hardware interfaces
### END INIT INFO

case "$1" in
    start)
        echo "Initializing Raspberry Pi hardware interfaces..."
        
        # Ensure I2C devices are available
        if [ ! -e /dev/i2c-1 ]; then
            modprobe i2c-dev
        fi
        
        # Ensure SPI devices are available  
        if [ ! -e /dev/spidev0.0 ]; then
            modprobe spi-bcm2835
            modprobe spidev
        fi
        
        # Set permissions for hardware devices
        if [ -e /dev/i2c-1 ]; then
            chgrp i2c /dev/i2c-1
            chmod 664 /dev/i2c-1
        fi
        
        if [ -e /dev/spidev0.0 ]; then
            chgrp spi /dev/spidev0.0
            chmod 664 /dev/spidev0.0
        fi
        
        if [ -e /dev/spidev0.1 ]; then
            chgrp spi /dev/spidev0.1  
            chmod 664 /dev/spidev0.1
        fi
        
        echo "Hardware interfaces initialized."
        ;;
    stop)
        echo "Stopping hardware initialization service..."
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac

exit 0
EOF
    
    chmod +x ${IMAGE_ROOTFS}/etc/init.d/hardware-init
    
    # Enable the service
    install -d ${IMAGE_ROOTFS}/etc/rc2.d
    install -d ${IMAGE_ROOTFS}/etc/rc3.d  
    install -d ${IMAGE_ROOTFS}/etc/rc4.d
    install -d ${IMAGE_ROOTFS}/etc/rc5.d
    ln -sf ../init.d/hardware-init ${IMAGE_ROOTFS}/etc/rc2.d/S99hardware-init
    ln -sf ../init.d/hardware-init ${IMAGE_ROOTFS}/etc/rc3.d/S99hardware-init
    ln -sf ../init.d/hardware-init ${IMAGE_ROOTFS}/etc/rc4.d/S99hardware-init
    ln -sf ../init.d/hardware-init ${IMAGE_ROOTFS}/etc/rc5.d/S99hardware-init
}
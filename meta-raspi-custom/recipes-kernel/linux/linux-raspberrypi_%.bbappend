# Kernel recipe append for custom hardware configuration
# This file extends the default linux-raspberrypi recipe

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Add our custom kernel configuration
SRC_URI += "file://custom-hardware.cfg"

# Add device tree overlays for hardware interface enablement
SRC_URI += " \
    file://device-tree-overlays/i2c-enable.dts \
    file://device-tree-overlays/spi-enable.dts \
"

# Enable device tree overlays compilation
KERNEL_DEVICETREE:append = " \
    overlays/i2c-enable.dtbo \
    overlays/spi-enable.dtbo \
"

# Description of what this configuration adds
SUMMARY = "Custom Raspberry Pi kernel configuration for I2C, SPI, GPIO, PWM support"
DESCRIPTION = "Extends the default Raspberry Pi kernel with additional hardware interface support including I2C, SPI, GPIO, PWM, Camera, Audio, Bluetooth, and WiFi with device tree overlays."

do_compile:append() {
    # Compile device tree overlays
    if [ -d "${WORKDIR}/device-tree-overlays" ]; then
        for dts in ${WORKDIR}/device-tree-overlays/*.dts; do
            if [ -f "$dts" ]; then
                dtc -I dts -O dtb -o ${WORKDIR}/$(basename $dts .dts).dtbo $dts
            fi
        done
    fi
}

do_deploy:append() {
    # Deploy device tree overlays
    if [ -d "${WORKDIR}" ]; then
        for dtbo in ${WORKDIR}/*.dtbo; do
            if [ -f "$dtbo" ]; then
                install -m 0644 $dtbo ${DEPLOYDIR}/
            fi
        done
    fi
}
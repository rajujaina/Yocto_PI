# Kernel recipe append for custom hardware configuration
# This file extends the default linux-raspberrypi recipe

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Add our custom kernel configuration
SRC_URI += "file://custom-hardware.cfg"

# Description of what this configuration adds
SUMMARY = "Custom Raspberry Pi kernel configuration for I2C, SPI, GPIO, PWM support"
DESCRIPTION = "Extends the default Raspberry Pi kernel with additional hardware interface support including I2C, SPI, GPIO, PWM, Camera, Audio, Bluetooth, and WiFi."
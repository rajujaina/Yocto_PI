# Recipe for custom Raspberry Pi hardware test application
SUMMARY = "Custom Raspberry Pi hardware interface test application"
DESCRIPTION = "A sample application demonstrating I2C, SPI, and GPIO usage on Raspberry Pi"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Inherit autotools for proper cross-compilation
inherit autotools-brokensep

# Source files
SRC_URI = " \
    file://raspi-hw-test.c \
    file://Makefile \
"

# Set source directory
S = "${WORKDIR}"

# Use oe_runmake which sets up proper cross-compilation environment
do_compile() {
    oe_runmake CC="${CC}" CFLAGS="${CFLAGS}"
}

# Install the application
do_install() {
    oe_runmake install DESTDIR=${D} CC="${CC}"
}

# Package the application
FILES:${PN} = "/usr/bin/raspi-hw-test"

# Dependencies
DEPENDS = "virtual/kernel"
# Base files recipe append for custom boot configuration
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add our custom boot configuration
SRC_URI += "file://config-custom.txt"

# Install custom configuration
do_install:append() {
    # Append custom config to config.txt in boot partition
    if [ -f "${WORKDIR}/config-custom.txt" ]; then
        install -d ${D}/boot
        cat ${WORKDIR}/config-custom.txt >> ${D}/boot/config.txt
    fi
}
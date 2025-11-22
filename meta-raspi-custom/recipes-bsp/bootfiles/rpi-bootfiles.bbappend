# Fix bootfiles checksum for properly converted tar.xz file
SRC_URI[sha256sum] = "ac2d34b9bee8968d18acf0e00cdbbdeb019ca74668593185b72a82126ab1dd69"

# Fix license file path for GitHub source structure
SRC_URI[sha256sum] = "ac2d34b9bee8968d18acf0e00cdbbdeb019ca74668593185b72a82126ab1dd69"

# Override source directory to match GitHub download structure
S = "${WORKDIR}/firmware-1.${RPIFW_DATE}/boot"

# Override license file checksum with correct path from the source root
LIC_FILES_CHKSUM = "file://LICENCE.broadcom;md5=c403841ff2837657b2ed8e5bb474ac8d"
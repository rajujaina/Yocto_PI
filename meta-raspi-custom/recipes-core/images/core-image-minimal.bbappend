# Append to core-image-minimal to enable easy login for development

# Enable empty root password for development (INSECURE - for testing only!)
IMAGE_FEATURES += "debug-tweaks"

# Create pi user with password: 1234
inherit extrausers
EXTRA_USERS_PARAMS = " \
    usermod -p '\$1\$obm0/KCQ\$aohbe.LhE4Q8aKI963Pso/' root; \
    useradd -p '\$1\$obm0/KCQ\$aohbe.LhE4Q8aKI963Pso/' -G sudo -m pi; \
"

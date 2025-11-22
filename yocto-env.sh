#!/bin/bash
# Yocto Environment Variables

# Optimize build performance
export BB_NUMBER_THREADS=$(nproc)
export PARALLEL_MAKE="-j $(nproc)"

# Set up shared directories
export DL_DIR="$(pwd)/downloads"
export SSTATE_DIR="$(pwd)/sstate-cache"

# Set locale (using C.UTF-8 for universal compatibility)
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Network configuration for WSL2/restricted networks
export CONNECTIVITY_CHECK_URIS=""

# Optimize disk usage
export BB_GENERATE_MIRROR_TARBALLS="1"
export BB_DISKMON_DIRS="STOPTASKS,${TMPDIR},1G,100K STOPTASKS,${DL_DIR},1G,100K STOPTASKS,${SSTATE_DIR},1G,100K ABORT,${TMPDIR},100M,1K ABORT,${DL_DIR},100M,1K ABORT,${SSTATE_DIR},100M,1K"

echo "Yocto environment variables set"

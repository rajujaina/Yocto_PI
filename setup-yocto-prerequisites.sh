#!/bin/bash

# Yocto Prerequisites Setup Script
# This script sets up all necessary prerequisites for building Yocto images
# Author: Auto-generated for Yocto_PI project
# Date: November 15, 2025

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        error "This script should not be run as root. Please run as a regular user."
    fi
}

# Check Linux distribution
check_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
        log "Detected OS: $PRETTY_NAME"
    else
        error "Cannot detect Linux distribution"
    fi
}

# Check system requirements
check_system_requirements() {
    log "Checking system requirements..."
    
    # Check available disk space (Yocto needs at least 50GB)
    AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
    if [ "$AVAILABLE_SPACE" -lt 50 ]; then
        warn "Available disk space is ${AVAILABLE_SPACE}GB. Yocto build requires at least 50GB."
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check available RAM (recommended 8GB+)
    AVAILABLE_RAM=$(free -g | grep '^Mem:' | awk '{print $2}')
    if [ "$AVAILABLE_RAM" -lt 8 ]; then
        warn "Available RAM is ${AVAILABLE_RAM}GB. 8GB+ is recommended for Yocto builds."
    fi
    
    log "System requirements check completed"
}

# Install system dependencies
install_dependencies() {
    log "Installing system dependencies..."
    
    case $DISTRO in
        ubuntu|debian)
            # Update package list
            sudo apt-get update
            
            # Install required packages
            sudo apt-get install -y \
                build-essential \
                chrpath \
                cpio \
                debianutils \
                diffstat \
                file \
                gawk \
                gcc \
                git \
                iputils-ping \
                libacl1 \
                liblz4-tool \
                locales \
                python3 \
                python3-git \
                python3-jinja2 \
                python3-pexpect \
                python3-pip \
                python3-subunit \
                socat \
                texinfo \
                unzip \
                wget \
                xz-utils \
                zstd \
                libegl1-mesa-dev \
                libsdl2-dev \
                xterm \
                curl \
                lz4 \
                mesa-common-dev
            
            # Additional useful packages
            sudo apt-get install -y \
                git-lfs \
                tree \
                htop \
                vim \
                tmux
            ;;
            
        fedora|centos|rhel)
            # Install required packages for Red Hat based systems
            sudo dnf install -y \
                @development-tools \
                chrpath \
                cpio \
                diffstat \
                file \
                gawk \
                gcc \
                git \
                iputils \
                lz4 \
                python3 \
                python3-pip \
                python3-pexpect \
                socat \
                texinfo \
                unzip \
                wget \
                xz \
                zstd \
                mesa-libEGL-devel \
                SDL-devel \
                xterm
            ;;
            
        *)
            error "Unsupported distribution: $DISTRO"
            ;;
    esac
    
    log "System dependencies installed successfully"
}

# Configure Git if not already configured
configure_git() {
    log "Checking Git configuration..."
    
    if ! git config --global user.name > /dev/null 2>&1; then
        read -p "Enter your Git username: " git_username
        git config --global user.name "$git_username"
    fi
    
    if ! git config --global user.email > /dev/null 2>&1; then
        read -p "Enter your Git email: " git_email
        git config --global user.email "$git_email"
    fi
    
    # Configure Git for large repositories
    git config --global core.preloadindex true
    git config --global core.fscache true
    git config --global gc.auto 256
    
    log "Git configuration completed"
}

# Set up locale
setup_locale() {
    log "Setting up locale..."
    
    # Ensure en_US.UTF-8 locale is available
    if ! locale -a | grep -q "en_US.utf8\|en_US.UTF-8"; then
        case $DISTRO in
            ubuntu|debian)
                sudo locale-gen en_US.UTF-8
                ;;
            fedora|centos|rhel)
                sudo localedef -c -i en_US -f UTF-8 en_US.UTF-8
                ;;
        esac
    fi
    
    log "Locale setup completed"
}

# Create build directory structure
create_build_structure() {
    log "Creating build directory structure..."
    
    # Create downloads and sstate-cache directories for sharing between builds
    mkdir -p downloads
    mkdir -p sstate-cache
    mkdir -p build-logs
    
    log "Build directory structure created"
}

# Set up environment variables
setup_environment() {
    log "Setting up environment variables..."
    
    # Create environment setup file
    cat > yocto-env.sh << 'EOF'
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

# Optimize disk usage
export BB_GENERATE_MIRROR_TARBALLS="1"
export BB_DISKMON_DIRS="STOPTASKS,${TMPDIR},1G,100K STOPTASKS,${DL_DIR},1G,100K STOPTASKS,${SSTATE_DIR},1G,100K ABORT,${TMPDIR},100M,1K ABORT,${DL_DIR},100M,1K ABORT,${SSTATE_DIR},100M,1K"

echo "Yocto environment variables set"
EOF
    
    chmod +x yocto-env.sh
    
    log "Environment setup completed"
}

# Clone Poky if not exists
setup_poky() {
    log "Setting up Poky repository..."
    
    if [ ! -d "poky" ]; then
        info "Cloning Poky repository..."
        git clone git://git.yoctoproject.org/poky
        cd poky
        
        # Checkout latest LTS release (adjust as needed)
        git checkout -b local-kirkstone origin/kirkstone
        cd ..
        log "Poky repository cloned and checked out to kirkstone branch"
    else
        info "Poky repository already exists"
        cd poky
        git fetch origin
        git checkout kirkstone
        git pull origin kirkstone
        cd ..
        log "Poky repository updated"
    fi
}

# Clone meta-raspberrypi layer
setup_meta_raspberrypi() {
    log "Setting up meta-raspberrypi layer..."
    
    if [ ! -d "meta-raspberrypi" ]; then
        info "Cloning meta-raspberrypi repository..."
        git clone git://git.yoctoproject.org/meta-raspberrypi
        cd meta-raspberrypi
        git checkout -b local-kirkstone origin/kirkstone
        cd ..
        log "meta-raspberrypi layer cloned"
    else
        info "meta-raspberrypi layer already exists"
        cd meta-raspberrypi
        git fetch origin
        git checkout kirkstone
        git pull origin kirkstone
        cd ..
        log "meta-raspberrypi layer updated"
    fi
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    # Check if essential tools are available
    local tools=("git" "python3" "gcc" "make" "wget" "tar" "gzip")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            error "$tool is not available in PATH"
        fi
    done
    
    # Check Python version
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d'.' -f1)
    PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d'.' -f2)
    
    if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 6 ]); then
        error "Python 3.6+ is required, found $PYTHON_VERSION"
    fi
    
    log "Installation verification completed successfully"
}

# Create build script
create_build_script() {
    log "Creating build script..."
    
    cat > build-yocto.sh << 'EOF'
#!/bin/bash

# Yocto Build Script
# Usage: ./build-yocto.sh [MACHINE] [IMAGE]

set -e

# Default values
MACHINE=${1:-raspberrypi4-64}
IMAGE=${2:-core-image-minimal}
BUILD_DIR="build-${MACHINE}-${IMAGE}"

echo "Building Yocto image..."
echo "Machine: $MACHINE"
echo "Image: $IMAGE"
echo "Build Directory: $BUILD_DIR"

# Source environment variables
if [ -f "./yocto-env.sh" ]; then
    source ./yocto-env.sh
fi

# Initialize build environment
source poky/oe-init-build-env $BUILD_DIR

# Configure local.conf if this is first run
if [ ! -f conf/local.conf.orig ]; then
    cp conf/local.conf conf/local.conf.orig
    
    # Set machine
    sed -i "s/^MACHINE ??= .*/MACHINE ??= \"$MACHINE\"/" conf/local.conf
    
    # Add shared directories
    cat >> conf/local.conf << EOL

# Shared download and sstate directories
DL_DIR = "${DL_DIR}"
SSTATE_DIR = "${SSTATE_DIR}"

# Optimize build
BB_NUMBER_THREADS = "${BB_NUMBER_THREADS}"
PARALLEL_MAKE = "${PARALLEL_MAKE}"

# Enable disk monitoring
BB_DISKMON_DIRS = "${BB_DISKMON_DIRS}"

EOL
fi

# Add meta-raspberrypi layer to bblayers.conf if not already added
if ! grep -q "meta-raspberrypi" conf/bblayers.conf; then
    bitbake-layers add-layer ../meta-raspberrypi
fi

# Start the build
echo "Starting build for $IMAGE..."
time bitbake $IMAGE

echo "Build completed successfully!"
echo "Image location: ${BUILD_DIR}/tmp/deploy/images/${MACHINE}/"
echo ""
echo "Key files generated:"
echo "  - SD card image: ${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.wic.bz2"
echo "  - Root filesystem: ${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.ext3"
echo "  - Kernel: ${BUILD_DIR}/tmp/deploy/images/${MACHINE}/Image-${MACHINE}.bin"
echo ""
echo "To flash to SD card:"
echo "  bunzip2 -k ${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.wic.bz2"
echo "  sudo dd if=${BUILD_DIR}/tmp/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.wic of=/dev/sdX bs=4M status=progress"
EOF
    
    chmod +x build-yocto.sh
    
    log "Build script created"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "    Yocto Prerequisites Setup Script"
    echo "=================================================="
    echo -e "${NC}"
    
    check_root
    check_distro
    check_system_requirements
    
    # Ask for confirmation
    read -p "Do you want to proceed with the installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Installation cancelled by user"
        exit 0
    fi
    
    install_dependencies
    configure_git
    setup_locale
    create_build_structure
    setup_environment
    setup_poky
    setup_meta_raspberrypi
    create_build_script
    verify_installation
    
    echo -e "${GREEN}"
    echo "=================================================="
    echo "    Setup completed successfully!"
    echo "=================================================="
    echo -e "${NC}"
    
    info "Next steps:"
    echo "1. Source the environment: source yocto-env.sh"
    echo "2. Run the build script: ./build-yocto.sh [machine] [image]"
    echo "3. Example: ./build-yocto.sh raspberrypi4-64 core-image-base"
    echo ""
    echo "Available machines: raspberrypi, raspberrypi0, raspberrypi2, raspberrypi3, raspberrypi4, raspberrypi4-64"
    echo "Available images: core-image-minimal, core-image-base, core-image-full-cmdline"
}

# Run main function
main "$@"
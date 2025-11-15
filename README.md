# Yocto Project for Raspberry Pi

A comprehensive Yocto Project setup for building custom Linux images for Raspberry Pi devices. This repository provides automated scripts and configurations to streamline the Yocto build process.

## 🚀 Quick Start

### Prerequisites
- **Operating System**: Ubuntu 24.04 LTS (tested) or compatible Debian-based system
- **Hardware Requirements**:
  - 50GB+ free disk space
  - 8GB+ RAM (16GB+ recommended)
  - Multi-core CPU (for parallel builds)

### One-Command Setup
```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/Yocto_PI.git
cd Yocto_PI

# Make the setup script executable
chmod +x setup-yocto-prerequisites.sh

# Run the automated setup
./setup-yocto-prerequisites.sh

# Source the environment
source yocto-env.sh

# Start building your first image
./build-yocto.sh raspberrypi4-64 core-image-base
```

## 📁 Project Structure

```
Yocto_PI/
├── setup-yocto-prerequisites.sh    # Automated prerequisites setup script
├── build-yocto.sh                  # Simplified build script
├── yocto-env.sh                    # Environment variables setup
├── poky/                           # Yocto Project core (auto-generated)
├── meta-raspberrypi/              # Raspberry Pi BSP layer (auto-generated)
├── downloads/                     # Shared download cache
├── sstate-cache/                  # Shared state cache for faster builds
├── build-logs/                    # Build logs directory
└── README.md                      # This file
```

## 🛠 Setup Script Features

The `setup-yocto-prerequisites.sh` script automatically handles:

### ✅ System Validation
- Linux distribution detection (Ubuntu/Debian/Fedora/RHEL)
- Disk space verification (50GB+ required)
- Memory check (8GB+ recommended)
- User permission validation (prevents root execution)

### ✅ Package Installation
- Build-essential tools (gcc, g++, make, etc.)
- Yocto-specific dependencies
- Python 3.6+ with required modules
- Development libraries and headers
- Utility tools (git, wget, curl, etc.)

### ✅ Repository Management
- Clones Yocto Project Poky (Kirkstone LTS branch)
- Sets up meta-raspberrypi BSP layer
- Configures shared download and sstate directories

### ✅ Environment Optimization
- Multi-core build configuration
- Shared cache setup for faster subsequent builds
- Proper locale configuration
- Git configuration assistance

## 🎯 Supported Targets

### Raspberry Pi Models
| Machine Name | Description |
|-------------|-------------|
| `raspberrypi` | Raspberry Pi 1 (original) |
| `raspberrypi0` | Raspberry Pi Zero |
| `raspberrypi2` | Raspberry Pi 2 |
| `raspberrypi3` | Raspberry Pi 3 |
| `raspberrypi4` | Raspberry Pi 4 (32-bit) |
| `raspberrypi4-64` | Raspberry Pi 4 (64-bit) - **Recommended** |

### Available Images
| Image Name | Description | Use Case |
|------------|-------------|----------|
| `core-image-minimal` | Minimal bootable image | Embedded systems, IoT |
| `core-image-base` | Base image with basic utilities | Development, prototyping |
| `core-image-full-cmdline` | Full-featured command line | Server applications |

## 🔧 Usage Examples

### Basic Build Commands
```bash
# Source environment (required for each new terminal session)
source yocto-env.sh

# Build minimal image for Pi 4 (64-bit)
./build-yocto.sh raspberrypi4-64 core-image-minimal

# Build base image for Pi 3
./build-yocto.sh raspberrypi3 core-image-base

# Build full cmdline image for Pi 4
./build-yocto.sh raspberrypi4 core-image-full-cmdline
```

### Manual Build Process
If you prefer manual control:
```bash
# Initialize build environment
source poky/oe-init-build-env rpi-build

# Add meta-raspberrypi layer (first time only)
bitbake-layers add-layer ../meta-raspberrypi

# Configure machine in local.conf
echo 'MACHINE = "raspberrypi4-64"' >> conf/local.conf

# Start the build
bitbake core-image-base
```

## ⚙️ Configuration

### Build Optimization
The setup automatically configures:
- **Parallel builds**: Uses all available CPU cores
- **Shared downloads**: Reuses downloaded sources across builds
- **Shared sstate**: Speeds up rebuilds significantly
- **Disk monitoring**: Prevents builds from filling up disk

### Custom Configuration
Edit `conf/local.conf` in your build directory to customize:
```bash
# Enable additional features
EXTRA_IMAGE_FEATURES += "debug-tweaks ssh-server-openssh"

# Add custom packages
IMAGE_INSTALL_append = " nano htop git"

# Set custom image size (in MB)
IMAGE_ROOTFS_SIZE = "4096"
```

## 📦 Build Output

After successful build, find your images in:
```
rpi-build/tmp/deploy/images/[MACHINE]/
├── [image-name]-[machine].wic.bz2     # SD card image (compressed)
├── [image-name]-[machine].wic.bmap    # Block map for fast flashing
├── [image-name]-[machine].tar.bz2     # Root filesystem archive
└── bootfiles/                        # Boot partition files
```

## 💾 Flashing to SD Card

### Using bmaptool (Recommended)
```bash
# Install bmaptool
sudo apt install bmap-tools

# Flash to SD card (replace /dev/sdX with your SD card device)
sudo bmaptool copy --bmap image.wic.bmap image.wic.bz2 /dev/sdX
```

### Using dd
```bash
# Extract and flash
bunzip2 -c image.wic.bz2 | sudo dd of=/dev/sdX bs=4M status=progress
```

## 🐛 Troubleshooting

### Common Issues

**Disk space errors:**
```bash
# Check available space
df -h .
# Clean shared state cache if needed
rm -rf sstate-cache/*
```

**Permission errors:**
```bash
# Ensure not running as root
whoami
# Fix ownership if needed
sudo chown -R $USER:$USER .
```

**Package fetch failures:**
```bash
# Clean downloads and retry
rm -rf downloads/[package-name]*
bitbake [package-name] -c cleanall
bitbake [image-name]
```

**Build environment issues:**
```bash
# Re-source environment
source yocto-env.sh
# Or reinitialize
source poky/oe-init-build-env rpi-build
```

## 📋 System Requirements Details

### Minimum Requirements
- **CPU**: Dual-core processor
- **RAM**: 8GB
- **Storage**: 50GB free space
- **Network**: Broadband internet connection

### Recommended Requirements
- **CPU**: Quad-core+ processor (Intel i5/i7, AMD Ryzen)
- **RAM**: 16GB+
- **Storage**: 100GB+ SSD storage
- **Network**: Fast internet for initial downloads

### Build Times (Approximate)
| System | Initial Build | Incremental |
|---------|---------------|-------------|
| 4-core, 8GB RAM | 3-4 hours | 15-30 min |
| 8-core, 16GB RAM | 1-2 hours | 10-15 min |
| 16-core, 32GB RAM | 30-60 min | 5-10 min |

## 🔗 Useful Resources

- **Yocto Project**: https://www.yoctoproject.org/
- **Meta-Raspberrypi Documentation**: https://meta-raspberrypi.readthedocs.io/
- **Yocto Project Quick Build**: https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html
- **BitBake User Manual**: https://docs.yoctoproject.org/bitbake/

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and commit: `git commit -m "Description"`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
- Create an issue in this repository
- Check the troubleshooting section above
- Refer to the official Yocto Project documentation

---

**Happy Building! 🎉**


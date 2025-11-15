# Path Standardization Documentation

This document describes the path conventions used throughout the Yocto_PI project documentation to ensure portability and universal applicability.

## 📋 Path Convention Standards

### Generic Path Variables Used

| Variable | Description | Example Values |
|----------|-------------|----------------|
| `${WORKSPACE}` | User's workspace directory | `/home/username/workspace/`, `/opt/yocto/`, `~/projects/` |
| `${USER}` | Current username | `john`, `developer`, `pi` |
| `YOUR_USERNAME` | GitHub username placeholder | `your-github-username` |
| `[MACHINE]` | Target hardware placeholder | `raspberrypi4-64`, `raspberrypi3` |
| `[IMAGE]` | Image type placeholder | `core-image-base`, `custom-raspi-image` |

### Standardized Paths

#### ✅ **Documentation Paths** (Generic)
```bash
# Repository structure
${WORKSPACE}/Yocto_PI/
├── meta-raspi-custom/
├── setup-yocto-prerequisites.sh
├── build-yocto.sh
└── README.md

# Layer paths
${WORKSPACE}/Yocto_PI/meta-raspi-custom/
├── recipes-kernel/linux/linux-raspberrypi/custom-hardware.cfg
├── recipes-core/base-files/files/config-custom.txt
└── recipes-apps/my-custom-app/files/
```

#### ✅ **Build Output Paths** (Generic)
```bash
# Build directory structure
rpi-build/tmp/deploy/images/[MACHINE]/
├── [image-name]-[machine].wic.bz2
├── [image-name]-[machine].wic.bmap
└── [image-name]-[machine].tar.bz2

# Device paths
/dev/sdX                    # SD card device (user replaces X)
/dev/i2c-1                  # I2C device
/dev/spidev0.0              # SPI device
```

#### ✅ **Script Paths** (Relative)
```bash
# All scripts use relative paths
./setup-yocto-prerequisites.sh
./build-yocto.sh
source yocto-env.sh
source poky/oe-init-build-env

# Environment variables use pwd
export DL_DIR="$(pwd)/downloads"
export SSTATE_DIR="$(pwd)/sstate-cache"
```

### Files Updated for Generic Paths

#### 1. **README.md**
**Before:**
```bash
git clone https://github.com/rajujaina/Yocto_PI.git
```
**After:**
```bash
git clone https://github.com/YOUR_USERNAME/Yocto_PI.git
```

#### 2. **HARDWARE_MANAGEMENT.md**
**Before:**
```markdown
- /home/raju/Working/Yocto_PI/meta-raspi-custom/
- /home/raju/Working/Yocto_PI/build-yocto.sh
- /home/raju/Working/Yocto_PI/.gitignore
```
**After:**
```markdown
- ${WORKSPACE}/Yocto_PI/meta-raspi-custom/
- ${WORKSPACE}/Yocto_PI/build-yocto.sh
- ${WORKSPACE}/Yocto_PI/.gitignore
```

### Already Generic Files

#### ✅ **build-yocto.sh**
- Uses relative paths: `./yocto-env.sh`, `poky/oe-init-build-env`
- Uses variables: `$MACHINE`, `$IMAGE`, `$BUILD_DIR`
- Output paths use variables: `tmp/deploy/images/$MACHINE/`

#### ✅ **yocto-env.sh**
- Uses `$(pwd)` for current directory
- All paths relative to working directory
- No hardcoded user paths

#### ✅ **setup-yocto-prerequisites.sh**
- Uses relative paths for all operations
- Creates directories relative to current location
- No hardcoded user or system paths

#### ✅ **meta-raspi-custom/ layer**
- All recipe paths use BitBake variables
- Device tree paths use standard Linux conventions
- No absolute paths in any recipe files

## 🎯 Benefits of Generic Paths

### 1. **Portability**
- Documentation works on any Linux distribution
- Compatible with different user directory structures
- Works in containers and virtual machines

### 2. **Collaboration**
- Multiple users can use same documentation
- Easy to share between team members
- No need to modify paths for different setups

### 3. **Professional Standards**
- Follows industry best practices
- Makes project appear more professional
- Easier to maintain and update

### 4. **Automation Friendly**
- Scripts work in CI/CD environments
- Compatible with automated testing
- No environment-specific dependencies

## 📝 Usage Guidelines

### For Users
1. **Replace placeholders** with your actual values:
   - `YOUR_USERNAME` → your GitHub username
   - `${WORKSPACE}` → your actual workspace path
   - `[MACHINE]` → your target Raspberry Pi model

2. **Follow relative paths** when working within the project directory

3. **Use tab completion** to avoid typing full paths

### For Contributors
1. **Always use generic paths** in documentation
2. **Use variables** instead of hardcoded values
3. **Test documentation** on different systems
4. **Update this document** when adding new path conventions

## 🔧 Path Validation Checklist

Before committing documentation changes:

- [ ] No hardcoded usernames (`/home/raju/`, `/home/john/`)
- [ ] No hardcoded workspace paths (`/Working/`, `/projects/`)
- [ ] Use placeholder variables (`${WORKSPACE}`, `YOUR_USERNAME`)
- [ ] Use generic device paths (`/dev/sdX` not `/dev/sdb`)
- [ ] Use relative paths in scripts (`./script.sh` not `/full/path/script.sh`)
- [ ] Use BitBake variables in recipes (`${WORKDIR}`, `${D}`)

## 🔗 Related Documents

- `README.md` - Main project documentation
- `HARDWARE_MANAGEMENT.md` - Hardware interface guide
- `meta-raspi-custom/` - Custom layer documentation
- `.gitignore` - File exclusion rules

---
**Note**: This standardization ensures the Yocto_PI project documentation is universally applicable and professional.
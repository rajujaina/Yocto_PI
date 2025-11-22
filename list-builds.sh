#!/bin/bash

# List Build Images Script
# Shows all built images and their locations

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================================="
echo "    Yocto Build Images Summary"
echo -e "==================================================${NC}"
echo

# Find all build directories
BUILD_DIRS=($(find . -maxdepth 1 -type d -name "build-*" | sort))

if [ ${#BUILD_DIRS[@]} -eq 0 ]; then
    echo "No build directories found."
    echo "Run './build-yocto.sh [machine] [image]' to create builds."
    exit 0
fi

for BUILD_DIR in "${BUILD_DIRS[@]}"; do
    BUILD_DIR=${BUILD_DIR#./}  # Remove leading ./
    
    # Extract machine and image from directory name
    MACHINE_IMAGE=${BUILD_DIR#build-}
    MACHINE=$(echo "$MACHINE_IMAGE" | cut -d'-' -f1-2)  # Handle raspberrypi4-64
    IMAGE=$(echo "$MACHINE_IMAGE" | cut -d'-' -f3-)
    
    echo -e "${GREEN}Build: ${BUILD_DIR}${NC}"
    echo "  Machine: $MACHINE"
    echo "  Image: $IMAGE"
    
    # Check if images exist
    IMAGE_DIR="${BUILD_DIR}/tmp/deploy/images/${MACHINE}"
    if [ -d "$IMAGE_DIR" ]; then
        echo -e "  ${YELLOW}Generated files:${NC}"
        
        # List key files
        for pattern in "*.wic.bz2" "*.ext3" "Image-*.bin"; do
            files=$(find "$IMAGE_DIR" -name "$pattern" 2>/dev/null | head -5)
            if [ -n "$files" ]; then
                echo "$files" | sed 's/^/    /'
            fi
        done
        
        # Show total size
        TOTAL_SIZE=$(du -sh "$IMAGE_DIR" 2>/dev/null | cut -f1)
        echo "  Total size: $TOTAL_SIZE"
    else
        echo "  Status: Build incomplete or failed"
    fi
    
    echo
done

echo -e "${BLUE}Usage Examples:${NC}"
echo "  ./build-yocto.sh raspberrypi4-64 core-image-minimal"
echo "  ./build-yocto.sh raspberrypi4-64 custom-raspi-image"
echo "  ./build-yocto.sh raspberrypi4-64 core-image-base"
echo
echo "To clean a specific build:"
echo "  rm -rf build-[machine]-[image]"
echo
echo "To clean all builds:"
echo "  rm -rf build-*"
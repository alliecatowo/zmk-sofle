#!/bin/bash

# Build ZMK Dongle Firmware with zmk-dongle-display
# Uses existing keymap configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔨 ZMK Dongle Firmware Builder"
echo "=============================="

cd "$PROJECT_ROOT"

# Check if we're in a west workspace
if [ ! -d ".west" ]; then
    echo "❌ Error: Not in a west workspace"
    echo "Run 'west init -l config' first"
    exit 1
fi

# Check if zmk-dongle-display is available
if [ ! -d "zmk-dongle-display" ]; then
    echo "❌ Error: zmk-dongle-display module not found"
    echo "Run 'west update' to fetch all modules"
    exit 1
fi

# Activate Python virtual environment if it exists
if [ -d ".venv" ]; then
    echo "🐍 Activating Python virtual environment..."
    source .venv/bin/activate
fi

# Set up Zephyr environment
echo "⚙️  Setting up Zephyr environment..."
export ZEPHYR_SDK_INSTALL_DIR=~/zephyr-sdk-0.17.0
export ZEPHYR_BASE="$PROJECT_ROOT/zephyr"

if [ ! -d "$ZEPHYR_SDK_INSTALL_DIR" ]; then
    echo "❌ Error: Zephyr SDK not found at $ZEPHYR_SDK_INSTALL_DIR"
    echo "Please install Zephyr SDK first"
    exit 1
fi

# Source Zephyr environment
source zephyr/zephyr-env.sh

# Check if dongle config exists
if [ ! -f "config/dongle.conf" ]; then
    echo "❌ Error: config/dongle.conf not found"
    echo "Please create dongle configuration first"
    exit 1
fi

# Build the dongle firmware
echo "🔨 Building dongle firmware..."
echo "   Board: nice_nano_v2"
echo "   Shield: dongle_display"
echo "   Config: $PROJECT_ROOT/config"

west build -p -b nice_nano_v2 -s zmk/app -- \
    -DSHIELD=dongle_display \
    -DZMK_CONFIG="$PROJECT_ROOT/config" \
    -DCONFIG_FILE="$PROJECT_ROOT/config/dongle.conf"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Dongle firmware build successful!"
    echo "📁 Firmware location: build/zephyr/zmk.uf2"
    echo ""
    echo "🔧 Next steps:"
    echo "   1. Put your dongle (nice_nano_v2) in bootloader mode"
    echo "   2. Copy build/zephyr/zmk.uf2 to the dongle"
    echo "   3. The dongle will reboot with new firmware"
    echo "   4. Pair your keyboard halves with the dongle"
    echo ""
    echo "💡 The dongle will show:"
    echo "   - Connected keyboard halves"
    echo "   - Battery levels"
    echo "   - Active layer"
    echo "   - Modifier keys"
else
    echo ""
    echo "❌ Build failed!"
    echo "Check the error messages above"
    exit 1
fi

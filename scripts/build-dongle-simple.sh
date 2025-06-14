#!/bin/bash

# Simple ZMK Dongle Builder
# Clean and straightforward approach

set -e

echo "🔨 Building AllieCatKeeb Dongle Firmware"
echo "========================================"

# Check if we have the required files
if [ ! -f "config/west.yml" ]; then
    echo "❌ west.yml not found. Please run from project root."
    exit 1
fi

# Initialize west workspace if needed
if [ ! -d ".west" ]; then
    echo "🔧 Initializing west workspace..."
    west init -l config
fi

# Update modules
echo "📦 Updating modules..."
west update

# Set up environment
echo "🐍 Setting up build environment..."
if [ -d ".venv" ]; then
    source .venv/bin/activate
fi

# Build the dongle firmware
echo "🏗️  Building dongle firmware..."
west build -p -b nice_nano_v2 -s zmk/app -- \
    -DSHIELD=dongle_display \
    -DZMK_CONFIG="$(pwd)/config"

# Check if build succeeded
if [ -f "build/zephyr/zmk.uf2" ]; then
    mkdir -p firmware
    cp build/zephyr/zmk.uf2 firmware/alliecatkeeb_dongle.uf2
    echo "✅ Dongle firmware built successfully!"
    echo "📁 Firmware saved to: firmware/alliecatkeeb_dongle.uf2"
    echo ""
    echo "🔌 Hardware Setup:"
    echo "1. Connect 128x64 OLED to Nice!Nano v2 I2C pins"
    echo "2. Flash this firmware to the dongle"
    echo "3. Use GitHub Actions to build peripheral firmware"
    echo ""
    echo "🌐 GitHub Actions will build the complete set:"
    echo "- alliecatkeeb_dongle_central.uf2"
    echo "- alliecatkeeb_left_peripheral.uf2"
    echo "- alliecatkeeb_right_peripheral.uf2"
    echo "- settings_reset files"
else
    echo "❌ Build failed!"
    exit 1
fi

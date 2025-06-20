#!/bin/bash
# Setup local ZMK build environment

set -e

echo "🚀 Setting up local ZMK build environment..."

# Check if we're in the right directory
if [ ! -f "build.yaml" ]; then
    echo "❌ Error: Please run this script from the root of your zmk-sofle repository"
    exit 1
fi

# Clean up any existing west workspace to start fresh
if [ -d ".west" ]; then
    echo "🧹 Cleaning up existing west workspace..."
    rm -rf .west/ zephyr/ modules/ zmk/
fi

# Initialize west workspace
echo "📦 Initializing west workspace..."
west init -l config/

# Update west dependencies
echo "🔄 Updating west dependencies..."
west update

# Install Python dependencies if requirements exist
if [ -f "requirements.txt" ]; then
    echo "🐍 Installing Python dependencies..."
    pip install -r requirements.txt
fi

echo "✅ Local build environment setup complete!"
echo ""
echo "🛠️  Build commands:"
echo ""
echo "Standard mode (left master, right peripheral):"
echo "  Left:  west build -d build/left -s zmk/app -b eyelash_sofle_left -- -DZMK_CONFIG=\$(pwd)/config -DCONFIG_ZMK_STUDIO=y"
echo "  Right: west build -d build/right -s zmk/app -b eyelash_sofle_right -- -DZMK_CONFIG=\$(pwd)/config -DCONFIG_ZMK_STUDIO=y"
echo ""
echo "Dongle mode (central + 2 peripherals):"
echo "  Dongle: west build -d build/dongle -s zmk/app -b eyelash_sofle_dongle -- -DZMK_CONFIG=\$(pwd)/config -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_SPLIT_BLE_CENTRAL_PERIPHERALS=2"
echo "  Left:   west build -d build/left_periph -s zmk/app -b eyelash_sofle_left -- -DZMK_CONFIG=\$(pwd)/config -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n"
echo "  Right:  west build -d build/right_periph -s zmk/app -b eyelash_sofle_right -- -DZMK_CONFIG=\$(pwd)/config -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n"
echo ""
echo "Settings reset:"
echo "  west build -d build/reset -s zmk/app -b eyelash_sofle_left -- -DZMK_CONFIG=\$(pwd)/config -DSHIELD=settings_reset"
echo ""
echo "🎯 Firmware will be in build/*/zephyr/zmk.uf2"
echo ""
echo "🔥 Quick build script for testing:"
echo "  ./scripts/quick-build.sh left    # Build left half"
echo "  ./scripts/quick-build.sh right   # Build right half"
echo "  ./scripts/quick-build.sh dongle  # Build dongle mode"
echo "  ./scripts/quick-build.sh reset   # Build settings reset" 
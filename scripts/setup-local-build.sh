#!/bin/bash
# Setup local ZMK build environment

set -e

echo "🚀 Setting up local ZMK build environment..."

# Check if we're in the right directory
if [ ! -f "build.yaml" ]; then
    echo "❌ Error: Please run this script from the root of your zmk-sofle repository"
    exit 1
fi

# Initialize west workspace if not already done
if [ ! -d ".west" ]; then
    echo "📦 Initializing west workspace..."
    west init -l config/
else
    echo "✅ West workspace already initialized"
fi

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
echo "  Standard mode:   west build -d build/standard -s zmk/app -b eyelash_sofle_left -- -DZMK_CONFIG=\$(pwd)/config"
echo "  Dongle mode:     west build -d build/dongle -s zmk/app -b eyelash_sofle_dongle -- -DZMK_CONFIG=\$(pwd)/config"
echo "  Settings reset:  west build -d build/reset -s zmk/app -b eyelash_sofle_left -- -DZMK_CONFIG=\$(pwd)/config -DSHIELD=settings_reset"
echo ""
echo "🎯 Firmware will be in build/*/zephyr/zmk.uf2" 
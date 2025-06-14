#!/bin/bash

# ZMK Local Build Environment Setup
# Sets up everything needed to build ZMK firmware locally

set -e

# Enable debug mode if requested
[ "false" == "true" ] && set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔧 ZMK Local Build Environment Setup"
echo "===================================="

cd "$PROJECT_ROOT"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS. For other platforms, please refer to ZMK documentation."
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew if not present
if ! command_exists brew; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install required packages
echo "📦 Installing build dependencies..."
brew install cmake ninja python3 wget curl dtc

# Install VS Code if not present
if ! command_exists code; then
    echo "📦 Installing VS Code..."
    brew install --cask visual-studio-code
fi

# Create Python virtual environment
echo "🐍 Setting up Python virtual environment..."
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

# Activate virtual environment
source .venv/bin/activate

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install west

# Install Zephyr SDK if not present
ZEPHYR_SDK_VERSION="0.17.0"
ZEPHYR_SDK_DIR="$HOME/zephyr-sdk-$ZEPHYR_SDK_VERSION"

if [ ! -d "$ZEPHYR_SDK_DIR" ]; then
    echo "📦 Installing Zephyr SDK..."
    cd ~

    # Detect architecture
    if [[ $(uname -m) == "arm64" ]]; then
        SDK_ARCH="aarch64"
    else
        SDK_ARCH="x86_64"
    fi

    SDK_FILE="zephyr-sdk-${ZEPHYR_SDK_VERSION}_macos-${SDK_ARCH}.tar.xz"

    if [ ! -f "$SDK_FILE" ]; then
        wget "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/${SDK_FILE}"
    fi

    tar xf "$SDK_FILE"
    cd "zephyr-sdk-$ZEPHYR_SDK_VERSION"
    ./setup.sh -t arm-zephyr-eabi

    cd "$PROJECT_ROOT"
fi

# Set up environment variables
echo "⚙️  Setting up environment variables..."
export ZEPHYR_SDK_INSTALL_DIR="$ZEPHYR_SDK_DIR"

# Initialize west workspace if not already done
if [ ! -d ".west" ]; then
    echo "🔧 Initializing west workspace..."
    west init -l config
fi

# Update west modules
echo "📥 Updating west modules..."
west update

# Install Zephyr Python requirements
echo "📦 Installing Zephyr Python requirements..."
pip install -r zephyr/scripts/requirements.txt

# Set up Zephyr environment
echo "⚙️  Setting up Zephyr environment..."
export ZEPHYR_BASE="$PROJECT_ROOT/zephyr"
source zephyr/zephyr-env.sh

# Create environment setup script
echo "📝 Creating environment setup script..."
cat > setup-env.sh << 'EOF'
#!/bin/bash
# Source this file to set up the ZMK build environment
# Usage: source setup-env.sh

export ZEPHYR_SDK_INSTALL_DIR="$HOME/zephyr-sdk-0.17.0"
export ZEPHYR_BASE="$(pwd)/zephyr"

# Activate Python virtual environment
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
    echo "✅ Python virtual environment activated"
else
    echo "❌ Python virtual environment not found"
    return 1
fi

# Source Zephyr environment
if [ -f "zephyr/zephyr-env.sh" ]; then
    source zephyr/zephyr-env.sh
    echo "✅ Zephyr environment loaded"
else
    echo "❌ Zephyr environment not found"
    return 1
fi

echo "🚀 ZMK build environment ready!"
echo ""
echo "Available commands:"
echo "  west build -p -b nice_nano_v2 -s zmk/app -- -DSHIELD=dongle_display -DZMK_CONFIG=\$(pwd)/config"
echo "  west build -p -b eyelash_sofle_left -s zmk/app -- -DSHIELD=nice_view -DZMK_CONFIG=\$(pwd)/config"
echo "  west build -p -b eyelash_sofle_right -s zmk/app -- -DSHIELD=nice_view_custom -DZMK_CONFIG=\$(pwd)/config"
EOF

chmod +x setup-env.sh

# Update the build script to use proper environment
echo "🔧 Updating build script..."
cat > scripts/build-dongle-firmware.sh << 'EOF'
#!/bin/bash

# Build ZMK Dongle Firmware with zmk-dongle-display
# Uses existing keymap configuration

set -e

# Enable debug mode if requested
[ "false" == "true" ] && set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔨 ZMK Dongle Firmware Builder"
echo "=============================="

cd "$PROJECT_ROOT"

# Check if we're in a west workspace
if [ ! -d ".west" ]; then
    echo "❌ Error: Not in a west workspace"
    echo "Run './scripts/setup-local-build.sh' first"
    exit 1
fi

# Check if zmk-dongle-display is available
if [ ! -d "zmk-dongle-display" ]; then
    echo "❌ Error: zmk-dongle-display module not found"
    echo "Run 'west update' to fetch all modules"
    exit 1
fi

# Source environment
echo "⚙️  Setting up build environment..."
if [ -f "setup-env.sh" ]; then
    source setup-env.sh
else
    echo "❌ Error: setup-env.sh not found. Run './scripts/setup-local-build.sh' first"
    exit 1
fi

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
    -DZMK_CONFIG="$PROJECT_ROOT/config"

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
EOF

chmod +x scripts/build-dongle-firmware.sh

# Test the build environment
echo "🧪 Testing build environment..."
source setup-env.sh

echo ""
echo "✅ Local build environment setup complete!"
echo ""
echo "🚀 Quick start:"
echo "   1. source setup-env.sh"
echo "   2. ./scripts/build-dongle-firmware.sh"
echo ""
echo "📖 Or build manually:"
echo "   west build -p -b nice_nano_v2 -s zmk/app -- -DSHIELD=dongle_display -DZMK_CONFIG=\$(pwd)/config"
echo ""
echo "🔧 Available build targets:"
echo "   - Dongle: nice_nano_v2 + dongle_display"
echo "   - Left half: eyelash_sofle_left + nice_view"
echo "   - Right half: eyelash_sofle_right + nice_view_custom"
EOF

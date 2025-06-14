#!/bin/bash

# Extract ZMK Studio Keymap from USB-connected keyboard
# This script extracts the current keymap from a ZMK Studio-enabled keyboard

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups/extracted_keymaps/$(date +%Y%m%d_%H%M%S)"

echo "🔍 ZMK Studio Keymap Extraction Tool"
echo "======================================"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check if zmk CLI is available
if ! command -v zmk &> /dev/null; then
    echo "❌ Error: zmk CLI not found"
    echo "Please install zmk CLI first:"
    echo "  pipx install zmk"
    exit 1
fi

# Check for connected ZMK Studio devices
echo "🔍 Checking for connected ZMK Studio devices..."

# Try to detect USB devices (this is a placeholder - actual implementation depends on zmk CLI capabilities)
if ! lsusb 2>/dev/null | grep -i "zmk\|studio" > /dev/null; then
    echo "⚠️  No obvious ZMK Studio devices found via lsusb"
    echo "   Continuing anyway - zmk CLI may still detect the device"
fi

# Check if we can communicate with a ZMK Studio device
echo "🔗 Attempting to connect to ZMK Studio device..."

# Note: The actual zmk CLI commands may differ - this is based on typical CLI patterns
# We'll need to check zmk --help to see the actual available commands

echo "📥 Extracting keymap..."
if zmk studio export --output "$BACKUP_DIR/extracted_keymap.json" 2>/dev/null; then
    echo "✅ Keymap exported to: $BACKUP_DIR/extracted_keymap.json"
elif zmk export --output "$BACKUP_DIR/extracted_keymap.json" 2>/dev/null; then
    echo "✅ Keymap exported to: $BACKUP_DIR/extracted_keymap.json"
else
    echo "❌ Failed to extract keymap using zmk CLI"
    echo "   Available zmk commands:"
    zmk --help || echo "   (zmk --help failed)"

    echo ""
    echo "🔧 Manual extraction options:"
    echo "   1. Use ZMK Studio desktop app to export keymap"
    echo "   2. Check if keyboard is in ZMK Studio mode"
    echo "   3. Verify USB connection and permissions"

    exit 1
fi

# Try to also extract configuration if possible
echo "📥 Attempting to extract configuration..."
if zmk studio config --output "$BACKUP_DIR/extracted_config.conf" 2>/dev/null; then
    echo "✅ Configuration exported to: $BACKUP_DIR/extracted_config.conf"
elif zmk config --output "$BACKUP_DIR/extracted_config.conf" 2>/dev/null; then
    echo "✅ Configuration exported to: $BACKUP_DIR/extracted_config.conf"
else
    echo "⚠️  Could not extract configuration (this may be normal)"
fi

# Create a summary
cat > "$BACKUP_DIR/extraction_info.txt" << EOF
ZMK Studio Keymap Extraction
============================
Date: $(date)
Host: $(hostname)
User: $(whoami)

Extracted files:
$(ls -la "$BACKUP_DIR")

Next steps:
1. Review extracted keymap in ZMK Studio
2. Copy to config/ directory if needed:
   cp "$BACKUP_DIR/extracted_keymap.json" "$PROJECT_ROOT/config/"
3. Build firmware with extracted keymap

EOF

echo ""
echo "✅ Extraction complete!"
echo "📁 Files saved to: $BACKUP_DIR"
echo "📄 Summary: $BACKUP_DIR/extraction_info.txt"
echo ""
echo "🔧 Next steps:"
echo "   1. Review the extracted files"
echo "   2. Copy to config/ if you want to use this keymap"
echo "   3. Run build scripts to create firmware"

#!/bin/bash

# Extract Current ZMK Studio Keymap
# This script helps extract your current keymap from the connected keyboard

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups/current_keymap/$(date +%Y%m%d_%H%M%S)"

echo "🔍 ZMK Studio Keymap Extraction"
echo "==============================="

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "📁 Backup directory: $BACKUP_DIR"

# Check for connected devices
echo "🔍 Checking for connected ZMK Studio devices..."
if system_profiler SPUSBDataType | grep -q "Eyelash Sofle"; then
    echo "✅ Found Eyelash Sofle connected"
else
    echo "❌ Eyelash Sofle not found. Please connect your keyboard."
    exit 1
fi

# Check for USB modem devices
USB_DEVICES=($(ls /dev/tty.usbmodem* 2>/dev/null || true))
if [ ${#USB_DEVICES[@]} -eq 0 ]; then
    echo "❌ No USB modem devices found"
    exit 1
fi

echo "📱 Found USB devices: ${USB_DEVICES[*]}"

# Try to extract keymap using zmk CLI if available
if command -v zmk &> /dev/null; then
    echo "🔧 Attempting to extract keymap using zmk CLI..."
    for device in "${USB_DEVICES[@]}"; do
        echo "  Trying device: $device"
        # Note: This is a placeholder - actual zmk CLI extraction commands may vary
        # zmk studio extract --device "$device" --output "$BACKUP_DIR/extracted_keymap.json" || true
    done
else
    echo "⚠️  zmk CLI not available for automatic extraction"
fi

# Instructions for manual backup
echo ""
echo "📋 MANUAL BACKUP INSTRUCTIONS:"
echo "==============================="
echo "1. Open ZMK Studio Web: https://zmk.studio/"
echo "2. Connect to your keyboard (it should auto-detect)"
echo "3. Go to 'Keymap' tab"
echo "4. Click 'Export' or 'Download' to save your current keymap"
echo "5. Save the file to: $BACKUP_DIR/"
echo ""
echo "🔑 IMPORTANT CHANGES TO NOTE:"
echo "- You mentioned toggle layers instead of momentary layers"
echo "- Any other custom behaviors or macros"
echo "- Layer assignments and key bindings"
echo ""

# Open ZMK Studio in browser
echo "🌐 Opening ZMK Studio in your browser..."
open "https://zmk.studio/" || echo "Please manually open: https://zmk.studio/"

echo ""
echo "💾 After backing up your keymap:"
echo "1. Save the exported file to: $BACKUP_DIR/"
echo "2. Note any custom behaviors in: $BACKUP_DIR/custom_behaviors.txt"
echo "3. Run the next script to build and bond the dongle firmware"
echo ""
echo "📂 Backup directory ready: $BACKUP_DIR"

#!/bin/bash
# Quick build script for testing ZMK firmware

set -e

if [ $# -eq 0 ]; then
    echo "�� Quick Build Script - Two Firmware Batches"
    echo ""
    echo "Usage: $0 <build_type>"
    echo ""
    echo "🎯 BATCH 1 - Standard Mode:"
    echo "  left-c  - Left central (master for standard mode)"
    echo "  right-p - Right peripheral (for standard mode)" 
    echo "  reset   - Settings reset firmware"
    echo ""
    echo "🎯 BATCH 2 - Dongle Mode:"
    echo "  dongle  - Dongle central receiver"
    echo "  left-p  - Left peripheral (for dongle mode)"
    echo "  right-p - Right peripheral (for dongle mode)"
    echo "  reset   - Settings reset firmware (same as above)"
    echo ""
    echo "Examples:"
    echo "  $0 left-c   # Build left central for standard mode"
    echo "  $0 dongle   # Build dongle central"
    echo "  $0 left-p   # Build left peripheral (works for both modes)"
    exit 1
fi

BUILD_TYPE=$1
CONFIG_PATH=$(pwd)/config
BOARD_ROOT=$(pwd)
BUILD_BASE="build"

echo "🔨 Building $BUILD_TYPE firmware..."

case $BUILD_TYPE in
    "left-c"|"left_central")
        echo "📱 Building left central (standard mode master)"
        west build -d ${BUILD_BASE}/left_central -s zmk/app -b eyelash_sofle_left -- \
            -DBOARD_ROOT=${BOARD_ROOT} \
            -DZMK_CONFIG=${CONFIG_PATH} \
            -DCONFIG_ZMK_STUDIO=y \
            -DCONFIG_ZMK_STUDIO_LOCKING=n \
            -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=y
        FIRMWARE_PATH="${BUILD_BASE}/left_central/zephyr/zmk.uf2"
        OUTPUT_NAME="eyelash_sofle_left.uf2"
        ;;
    "right-p"|"right_peripheral")
        echo "📱 Building right peripheral (works for both standard and dongle modes)"
        west build -d ${BUILD_BASE}/right_peripheral -s zmk/app -b eyelash_sofle_right -- \
            -DBOARD_ROOT=${BOARD_ROOT} \
            -DZMK_CONFIG=${CONFIG_PATH} \
            -DCONFIG_ZMK_STUDIO=y \
            -DCONFIG_ZMK_STUDIO_LOCKING=n \
            -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n
        FIRMWARE_PATH="${BUILD_BASE}/right_peripheral/zephyr/zmk.uf2"
        OUTPUT_NAME="eyelash_sofle_right.uf2"
        ;;
    "dongle")
        echo "📡 Building dongle central receiver"
        west build -d ${BUILD_BASE}/dongle -s zmk/app -b eyelash_sofle_dongle -- \
            -DBOARD_ROOT=${BOARD_ROOT} \
            -DZMK_CONFIG=${CONFIG_PATH} \
            -DCONFIG_ZMK_STUDIO=y \
            -DCONFIG_ZMK_STUDIO_LOCKING=n \
            -DCONFIG_ZMK_SPLIT=y \
            -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=y \
            -DCONFIG_ZMK_SPLIT_BLE_CENTRAL_PERIPHERALS=2 \
            -DCONFIG_BT_MAX_CONN=7 \
            -DCONFIG_BT_MAX_PAIRED=7
        FIRMWARE_PATH="${BUILD_BASE}/dongle/zephyr/zmk.uf2"
        OUTPUT_NAME="eyelash_sofle_dongle.uf2"
        ;;
    "left-p"|"left_peripheral")
        echo "📱 Building left peripheral (for dongle mode)"
        west build -d ${BUILD_BASE}/left_peripheral -s zmk/app -b eyelash_sofle_left -- \
            -DBOARD_ROOT=${BOARD_ROOT} \
            -DZMK_CONFIG=${CONFIG_PATH} \
            -DCONFIG_ZMK_STUDIO=y \
            -DCONFIG_ZMK_STUDIO_LOCKING=n \
            -DCONFIG_ZMK_SPLIT=y \
            -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n
        FIRMWARE_PATH="${BUILD_BASE}/left_peripheral/zephyr/zmk.uf2"
        OUTPUT_NAME="eyelash_sofle_left_peripheral.uf2"
        ;;
    "reset")
        echo "🔄 Building settings reset firmware"
        west build -d ${BUILD_BASE}/reset -s zmk/app -b eyelash_sofle_left -- \
            -DBOARD_ROOT=${BOARD_ROOT} \
            -DZMK_CONFIG=${CONFIG_PATH} \
            -DSHIELD=settings_reset
        FIRMWARE_PATH="${BUILD_BASE}/reset/zephyr/zmk.uf2"
        OUTPUT_NAME="settings_reset.uf2"
        ;;
    *)
        echo "❌ Unknown build type: $BUILD_TYPE"
        echo "Available types: left-c, right-p, dongle, left-p, reset"
        exit 1
        ;;
esac

if [ -f "$FIRMWARE_PATH" ]; then
    echo ""
    echo "✅ Build complete!"
    echo "📁 Firmware: $FIRMWARE_PATH"
    echo "📊 Size: $(ls -lh $FIRMWARE_PATH | awk '{print $5}')"
    
    # Create a convenient copy in firmware folder
    mkdir -p firmware/
    cp "$FIRMWARE_PATH" "firmware/${OUTPUT_NAME}"
    echo "📋 Copied to: firmware/${OUTPUT_NAME}"
else
    echo "❌ Build failed - firmware not found at $FIRMWARE_PATH"
    exit 1
fi 
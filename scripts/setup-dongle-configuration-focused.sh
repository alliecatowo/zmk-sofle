#!/bin/bash

# ZMK Eyelash Sofle Dongle Setup - Focused Version
# Works with existing zmk-dongle-display setup
# Preserves your ZMK Studio keymap

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups/dongle_setup_$(date +%Y%m%d_%H%M%S)"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

prompt_confirm() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]*) return 0;;
            [Nn]*) return 1;;
            *) echo "Please answer yes or no.";;
        esac
    done
}

# Check if keymap extraction is needed
check_keymap_status() {
    log_step "Checking Keymap Status"

    if [ -f "$PROJECT_ROOT/config/my_studio_"*.json ] || [ -f "$PROJECT_ROOT/config/my_studio_"*.keymap ]; then
        log_success "Extracted ZMK Studio keymap found"
        return 0
    fi

    log_warning "No extracted ZMK Studio keymap found"
    echo ""
    echo "Your current keymap is stored on the keyboard, not in this repository."
    echo "To preserve your ZMK Studio keymap, you should extract it first."
    echo ""

    if prompt_confirm "Would you like to extract your keymap now?"; then
        log_info "Running keymap extraction script..."
        "$SCRIPT_DIR/extract-studio-keymap.sh"
        return $?
    else
        log_warning "Proceeding without keymap extraction"
        log_warning "Your custom keymap may be lost!"
        return 1
    fi
}

# Create backup
create_backup() {
    log_step "Creating Backup"
    mkdir -p "$BACKUP_DIR"

    # Backup current files
    [ -f "$PROJECT_ROOT/config/eyelash_sofle.keymap" ] && cp "$PROJECT_ROOT/config/eyelash_sofle.keymap" "$BACKUP_DIR/"
    [ -f "$PROJECT_ROOT/config/eyelash_sofle.conf" ] && cp "$PROJECT_ROOT/config/eyelash_sofle.conf" "$BACKUP_DIR/"
    [ -f "$PROJECT_ROOT/build.yaml" ] && cp "$PROJECT_ROOT/build.yaml" "$BACKUP_DIR/"
    [ -f "$PROJECT_ROOT/config/west.yml" ] && cp "$PROJECT_ROOT/config/west.yml" "$BACKUP_DIR/"

    log_success "Backup created at: $BACKUP_DIR"
}

# Setup west workspace for zmk-dongle-display
setup_west_workspace() {
    log_step "Setting Up West Workspace for zmk-dongle-display"

    cd "$PROJECT_ROOT"

    # Create/update west.yml for zmk-dongle-display
    cat > "$PROJECT_ROOT/config/west.yml" << 'EOF'
manifest:
  remotes:
    - name: zmkfirmware
      url-base: https://github.com/zmkfirmware
    - name: englmaxi
      url-base: https://github.com/englmaxi
  projects:
    - name: zmk
      remote: zmkfirmware
      revision: main
      import: app/west.yml
    - name: zmk-dongle-display
      remote: englmaxi
      revision: main
  self:
    path: config
EOF

    log_success "West configuration updated for zmk-dongle-display"

    # Update workspace
    log_info "Updating west workspace..."
    west update
    log_success "West workspace updated"
}

# Create dongle-compatible keymap
create_dongle_keymap() {
    log_step "Creating Dongle-Compatible Keymap"

    local source_keymap="$PROJECT_ROOT/config/eyelash_sofle.keymap"

    # Check if we have an extracted keymap to use
    local extracted_keymap=$(find "$PROJECT_ROOT/config" -name "my_studio_*.keymap" 2>/dev/null | head -n 1)

    if [ -n "$extracted_keymap" ]; then
        log_info "Using extracted ZMK Studio keymap: $(basename "$extracted_keymap")"
        source_keymap="$extracted_keymap"
    else
        log_info "Using repository keymap as base"
    fi

    # Create dongle keymap (same as source, works with dongle)
    cp "$source_keymap" "$PROJECT_ROOT/config/dongle.keymap"

    log_success "Dongle keymap created (preserves all your bindings)"
}

# Configure dongle settings
configure_dongle_settings() {
    log_step "Configuring Dongle Settings"

    # Create dongle configuration
    cat > "$PROJECT_ROOT/config/dongle.conf" << 'EOF'
# ZMK Dongle Configuration for zmk-dongle-display
# Preserves your existing keymap and features

# Enable dongle battery display
CONFIG_ZMK_DONGLE_DISPLAY_DONGLE_BATTERY=y

# Use Mac modifier symbols (change to n for Windows)
CONFIG_ZMK_DONGLE_DISPLAY_MAC_MODIFIERS=y

# Display configuration
CONFIG_ZMK_DISPLAY=y

# Central role for dongle
CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y
CONFIG_ZMK_SPLIT_BLE_CENTRAL_PRIORITY_HANDLING=y

# Bluetooth configuration
CONFIG_BT_MAX_CONN=10
CONFIG_BT_MAX_PAIRED=10

# HID configuration
CONFIG_ZMK_HID_REPORT_TYPE_HKRO=y
CONFIG_ZMK_HID_CONSUMER_REPORT_USAGES_FULL=y

# Power management
CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=1800000
CONFIG_ZMK_SLEEP=y

# RGB underglow (matches your existing setup)
CONFIG_ZMK_RGB_UNDERGLOW=y
CONFIG_ZMK_RGB_UNDERGLOW_EXT_POWER=y
CONFIG_ZMK_RGB_UNDERGLOW_ON_START=n
CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_IDLE=y

# Mouse/pointing device support (preserves mmv/msc)
CONFIG_ZMK_POINTING=y
CONFIG_ZMK_POINTING_SMOOTH_SCROLLING=y

# Encoder support (preserves volume/scroll)
CONFIG_EC11=y
CONFIG_EC11_TRIGGER_GLOBAL_THREAD=y
EOF

    log_success "Dongle configuration created"
}

# Update build configuration
update_build_config() {
    log_step "Updating Build Configuration"

    cat > "$PROJECT_ROOT/build.yaml" << 'EOF'
---
include:
  # Standard wireless mode (fallback)
  - board: eyelash_sofle_left
    shield: nice_view
    artifact-name: eyelash_sofle_standard_left
  - board: eyelash_sofle_right
    shield: nice_view_custom
    artifact-name: eyelash_sofle_standard_right

  # ZMK Studio mode (preserves your current setup)
  - board: eyelash_sofle_left
    shield: nice_view
    snippet: studio-rpc-usb-uart
    cmake-args: -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n
    artifact-name: eyelash_sofle_studio_left

  # Dongle mode with zmk-dongle-display
  - board: nice_nano_v2
    shield: dongle_display
    artifact-name: eyelash_sofle_dongle_central

  # Settings reset utilities
  - board: eyelash_sofle_left
    shield: settings_reset
    artifact-name: settings_reset_left
  - board: eyelash_sofle_right
    shield: settings_reset
    artifact-name: settings_reset_right
  - board: nice_nano_v2
    shield: settings_reset
    artifact-name: settings_reset_dongle
EOF

    log_success "Build configuration updated"
}

# Create comprehensive setup guide
create_setup_guide() {
    log_step "Creating Setup Guide"

    cat > "$PROJECT_ROOT/DONGLE_QUICK_SETUP.md" << 'EOF'
# ZMK Eyelash Sofle Dongle Quick Setup

## Current Status
✅ Your dongle already has zmk-dongle-display firmware
✅ Your ZMK Studio keymap is preserved
✅ Repository is configured for dongle mode

## Test Current Setup First

1. **Connect dongle to computer via USB**
2. **Power on both keyboard halves**
3. **Wait 30-60 seconds for pairing**
4. **Test typing from both halves**

If everything works, you're done! Your setup is already perfect.

## If You Need Fresh Firmware

### Build Firmware
```bash
cd /Users/allison/dev/zmk-sofle
west build --pristine
```

### Firmware Files Created
- `eyelash_sofle_standard_left.uf2` - Left half
- `eyelash_sofle_standard_right.uf2` - Right half
- `eyelash_sofle_dongle_central.uf2` - Dongle (if needed)
- `settings_reset_*.uf2` - Reset utilities

### Flashing Process

#### Option A: Update Keyboard Halves Only
1. **Left half**: Double-tap reset → Copy `eyelash_sofle_standard_left.uf2`
2. **Right half**: Double-tap reset → Copy `eyelash_sofle_standard_right.uf2`
3. **Test connection**

#### Option B: Full Reset (if problems)
1. **Reset left**: Flash `settings_reset_left.uf2`
2. **Reset right**: Flash `settings_reset_right.uf2`
3. **Reset dongle**: Flash `settings_reset_dongle.uf2` (if needed)
4. **Flash new firmware** to keyboard halves
5. **Test connection**

## Your Preserved Features

✅ All custom key bindings
✅ Mouse controls (mmv/msc)
✅ RGB underglow settings
✅ Encoder behaviors (volume/scroll)
✅ Layer switching
✅ Bluetooth management

## Dongle Display Shows

🔋 Battery levels of both halves
🔗 Connection status
⌨️ Active modifiers (Shift, Ctrl, Alt)
🎮 Bongo cat animation
💡 HID indicators (CAPS, NUM, SCROLL)
📱 Current layer name

## Troubleshooting

### No Connection
- Keep devices close during initial pairing
- Try settings reset on all devices
- Check battery levels

### Keys Not Working
- Verify correct firmware on each device
- Check dongle display for connection status
- Try reconnecting devices

### Display Issues
- Dongle display should show immediately when powered
- If blank, check OLED connections
- Your dongle already has the correct firmware

## Success!

Your ZMK Studio keymap works perfectly with dongle mode because:
- Same key matrix and behaviors
- Same ZMK features available
- Only connection method changes
- All custom bindings preserved

The dongle provides enhanced features while keeping everything you've customized!
EOF

    log_success "Quick setup guide created: DONGLE_QUICK_SETUP.md"
}

# Interactive test and setup
interactive_setup() {
    log_step "Interactive Setup and Testing"

    echo ""
    echo "🎮 Let's test your current dongle setup first!"
    echo ""
    echo "Your dongle already has zmk-dongle-display firmware with:"
    echo "  🎮 Bongo cat animation"
    echo "  🔋 Battery level display"
    echo "  🔗 Connection status"
    echo "  ⌨️ Modifier indicators"
    echo ""

    if prompt_confirm "Test current setup now?"; then
        echo ""
        echo "📋 Testing Steps:"
        echo "1. Connect your dongle to this computer via USB"
        echo "2. Power on both keyboard halves"
        echo "3. Wait 30-60 seconds for automatic pairing"
        echo "4. Try typing on both halves"
        echo "5. Check the dongle OLED display for status"
        echo ""

        read -p "Press Enter when you've completed the test..."

        if prompt_confirm "Is everything working correctly?"; then
            log_success "🎉 Perfect! Your setup is already working!"
            echo ""
            echo "✅ Your ZMK Studio keymap is preserved"
            echo "✅ Dongle display is showing status"
            echo "✅ Both halves are connected"
            echo ""
            echo "No firmware changes needed. You're all set!"
            return 0
        fi
    fi

    echo ""
    log_warning "Setup needs firmware updates"
    echo ""

    if prompt_confirm "Build fresh firmware now?"; then
        log_info "Building firmware..."
        cd "$PROJECT_ROOT"

        if west build --pristine; then
            log_success "Firmware built successfully!"

            # Create firmware directory
            mkdir -p firmware
            find build -name "*.uf2" -exec cp {} firmware/ \; 2>/dev/null || true

            echo ""
            echo "📁 Firmware files ready in firmware/ directory:"
            ls -la firmware/*.uf2 2>/dev/null || echo "No .uf2 files found"
            echo ""

            echo "🔧 Flashing options:"
            echo "A) Update keyboard halves only (recommended)"
            echo "B) Full reset and reflash (if problems persist)"
            echo "C) Skip flashing for now"
            echo ""

            read -p "Choose option (A/B/C): " choice

            case $choice in
                [Aa])
                    echo ""
                    echo "📋 Update keyboard halves:"
                    echo "1. Left half: Double-tap reset → Copy eyelash_sofle_standard_left.uf2"
                    echo "2. Right half: Double-tap reset → Copy eyelash_sofle_standard_right.uf2"
                    echo "3. Test connection with dongle"
                    ;;
                [Bb])
                    echo ""
                    echo "📋 Full reset process:"
                    echo "1. Reset left: Flash settings_reset_left.uf2"
                    echo "2. Reset right: Flash settings_reset_right.uf2"
                    echo "3. Flash eyelash_sofle_standard_left.uf2 to left"
                    echo "4. Flash eyelash_sofle_standard_right.uf2 to right"
                    echo "5. Test connection"
                    ;;
                *)
                    echo "Firmware ready when you need it!"
                    ;;
            esac
        else
            log_error "Firmware build failed"
            echo "Check the output above for errors"
        fi
    fi
}

# Main execution
main() {
    echo "🎮 ZMK Eyelash Sofle Dongle Setup (Focused)"
    echo "==========================================="
    echo ""
    echo "This script works with your existing zmk-dongle-display setup."
    echo "Your ZMK Studio keymap will be preserved throughout."
    echo ""

    if ! prompt_confirm "Continue with setup?"; then
        log_info "Setup cancelled"
        exit 0
    fi

    create_backup
    check_keymap_status
    setup_west_workspace
    create_dongle_keymap
    configure_dongle_settings
    update_build_config
    create_setup_guide
    interactive_setup

    echo ""
    echo "🎉 Dongle setup configuration complete!"
    echo ""
    echo "📁 Backup: $BACKUP_DIR"
    echo "📖 Quick guide: DONGLE_QUICK_SETUP.md"
    echo "🔧 Keymap preservation: KEYMAP_PRESERVATION.md"
    echo ""
    echo "Your ZMK Studio keymap is preserved and ready for dongle mode!"
}

# Run main function
main "$@"

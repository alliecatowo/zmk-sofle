#!/bin/bash

# ZMK Eyelash Sofle Dongle Configuration Setup
# Interactive script for setting up BLE dongle with zmk-dongle-display
# Preserves your existing ZMK Studio keymap

set -e

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups/$(date +%Y%m%d_%H%M%S)"
DONGLE_DISPLAY_REPO="https://github.com/englmaxi/zmk-dongle-display.git"

# Logging functions
log_header() {
    echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Interactive prompts
prompt_user() {
    echo -e "${YELLOW}$1${NC}"
    read -p "Press Enter to continue or Ctrl+C to cancel..."
}

prompt_confirm() {
    while true; do
        echo -e "${YELLOW}$1 (y/n):${NC}"
        read -r response
        case $response in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

# Check prerequisites
check_prerequisites() {
    log_header "Checking Prerequisites"

    # Check if in correct directory
    if [ ! -f "$PROJECT_ROOT/build.yaml" ]; then
        log_error "Please run this script from the ZMK Eyelash Sofle repository root"
        exit 1
    fi

    # Check required commands
    local commands=("git" "west" "python3" "cmake")
    local missing=()

    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing required commands: ${missing[*]}"
        log_info "Please run './scripts/setup-dev-environment.sh' first"
        exit 1
    fi

    log_success "All prerequisites met"
}

# Create backup of current configuration
backup_current_config() {
    log_header "Backing Up Current Configuration"

    mkdir -p "$BACKUP_DIR"

    # Backup current keymap and config
    if [ -f "$PROJECT_ROOT/config/eyelash_sofle.keymap" ]; then
        cp "$PROJECT_ROOT/config/eyelash_sofle.keymap" "$BACKUP_DIR/"
        log_success "Keymap backed up"
    fi

    if [ -f "$PROJECT_ROOT/config/eyelash_sofle.conf" ]; then
        cp "$PROJECT_ROOT/config/eyelash_sofle.conf" "$BACKUP_DIR/"
        log_success "Config backed up"
    fi

    # Backup build.yaml
    if [ -f "$PROJECT_ROOT/build.yaml" ]; then
        cp "$PROJECT_ROOT/build.yaml" "$BACKUP_DIR/"
        log_success "Build configuration backed up"
    fi

    # Backup existing firmware if present
    if [ -d "$PROJECT_ROOT/firmware" ]; then
        cp -r "$PROJECT_ROOT/firmware" "$BACKUP_DIR/"
        log_success "Existing firmware backed up"
    fi

    log_success "Backup created at: $BACKUP_DIR"
}

# Setup west workspace if not already done
setup_workspace() {
    log_header "Setting Up West Workspace"

    if [ ! -f "$PROJECT_ROOT/config/west.yml" ]; then
        log_info "Initializing west workspace..."
        cd "$PROJECT_ROOT"
        west init -l config
        west update
        log_success "West workspace initialized"
    else
        log_info "Updating west workspace..."
        cd "$PROJECT_ROOT"
        west update
        log_success "West workspace updated"
    fi
}

# Add dongle display module to west.yml
add_dongle_display_module() {
    log_header "Adding Dongle Display Module"

    local west_yml="$PROJECT_ROOT/config/west.yml"

    # Check if dongle display module is already added
    if grep -q "zmk-dongle-display" "$west_yml" 2>/dev/null; then
        log_info "Dongle display module already configured"
        return 0
    fi

    # Create or update west.yml
    if [ ! -f "$west_yml" ]; then
        log_info "Creating new west.yml with dongle display module..."
        cat > "$west_yml" << EOF
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
    else
        log_info "Updating existing west.yml with dongle display module..."
        # Backup original
        cp "$west_yml" "$BACKUP_DIR/west.yml.backup"

        # Simple approach - check and add if needed
        if ! grep -q "englmaxi" "$west_yml"; then
            # Add englmaxi remote
            sed -i '' '/remotes:/a\
    - name: englmaxi\
      url-base: https://github.com/englmaxi' "$west_yml"
        fi

        if ! grep -q "zmk-dongle-display" "$west_yml"; then
            # Add zmk-dongle-display project
            sed -i '' '/projects:/a\
    - name: zmk-dongle-display\
      remote: englmaxi\
      revision: main' "$west_yml"
        fi
    fi

    log_success "Dongle display module added to west.yml"
}

# Create dongle build configuration
create_dongle_build_config() {
    log_header "Creating Dongle Build Configuration"

    # Update build.yaml for dongle mode
    cat > "$PROJECT_ROOT/build.yaml" << 'EOF'
---
include:
  # Standard wireless mode (backup)
  - board: eyelash_sofle_right
    shield: nice_view_custom
    artifact-name: eyelash_sofle_standard_right
  - board: eyelash_sofle_left
    shield: nice_view
    artifact-name: eyelash_sofle_standard_left

  # ZMK Studio mode (backup)
  - board: eyelash_sofle_left
    shield: nice_view
    snippet: studio-rpc-usb-uart
    cmake-args: -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n
    artifact-name: eyelash_sofle_studio_left

  # Dongle mode - Central receiver with custom display
  - board: nice_nano_v2
    shield: dongle_display
    artifact-name: eyelash_sofle_dongle_central

  # Settings reset
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

    log_success "Build configuration updated for dongle mode"
}

# Create peripheral shield configurations
create_peripheral_shields() {
    log_header "Creating Peripheral Shield Configurations"

    local shields_dir="$PROJECT_ROOT/config/boards/shields"
    mkdir -p "$shields_dir/eyelash_sofle_peripheral"

    # Create peripheral overlay
    cat > "$shields_dir/eyelash_sofle_peripheral/eyelash_sofle_peripheral.overlay" << 'EOF'
#include <dt-bindings/zmk/matrix_transform.h>

/ {
    chosen {
        zmk,kscan = &kscan0;
        zmk,matrix_transform = &default_transform;
    };

    /* Use the same matrix configuration as the main board */
    kscan0: kscan {
        compatible = "zmk,kscan-gpio-matrix";
        label = "KSCAN";
        diode-direction = "col2row";
        wakeup-source;

        row-gpios
            = <&pro_micro 4 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)>
            , <&pro_micro 5 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)>
            , <&pro_micro 6 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)>
            , <&pro_micro 7 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)>
            , <&pro_micro 8 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)>
            ;

        col-gpios
            = <&pro_micro 15 GPIO_ACTIVE_HIGH>
            , <&pro_micro 14 GPIO_ACTIVE_HIGH>
            , <&pro_micro 16 GPIO_ACTIVE_HIGH>
            , <&pro_micro 10 GPIO_ACTIVE_HIGH>
            , <&pro_micro 1 GPIO_ACTIVE_HIGH>
            , <&pro_micro 0 GPIO_ACTIVE_HIGH>
            ;
    };

    default_transform: keymap_transform_0 {
        compatible = "zmk,matrix-transform";
        columns = <6>;
        rows = <5>;
        map = <
            RC(0,0) RC(0,1) RC(0,2) RC(0,3) RC(0,4) RC(0,5)
            RC(1,0) RC(1,1) RC(1,2) RC(1,3) RC(1,4) RC(1,5)
            RC(2,0) RC(2,1) RC(2,2) RC(2,3) RC(2,4) RC(2,5)
            RC(3,0) RC(3,1) RC(3,2) RC(3,3) RC(3,4) RC(3,5)
            RC(4,0) RC(4,1) RC(4,2) RC(4,3) RC(4,4) RC(4,5)
        >;
    };
};

/* Configure as peripheral */
&zmk_kscan_debounce_press_ms {
    status = "okay";
};

&zmk_kscan_debounce_release_ms {
    status = "okay";
};
EOF

    # Create peripheral configuration
    cat > "$shields_dir/eyelash_sofle_peripheral/eyelash_sofle_peripheral.conf" << 'EOF'
# Peripheral configuration
CONFIG_ZMK_SPLIT_ROLE_CENTRAL=n

# Bluetooth configuration for peripheral
CONFIG_BT_PERIPHERAL_ADVERT_INTERVAL=40
CONFIG_BT_PERIPHERAL_CONN_INTERVAL=7.5

# Power management
CONFIG_ZMK_SLEEP=y
CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=1800000

# RGB configuration (can be disabled to save power)
CONFIG_ZMK_RGB_UNDERGLOW=y
CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_IDLE=y
CONFIG_ZMK_RGB_UNDERGLOW_ON_START=n

# Debounce settings
CONFIG_ZMK_KSCAN_DEBOUNCE_PRESS_MS=5
CONFIG_ZMK_KSCAN_DEBOUNCE_RELEASE_MS=5
EOF

    # Create shield definition
    cat > "$shields_dir/eyelash_sofle_peripheral/eyelash_sofle_peripheral.keymap" << 'EOF'
#include <behaviors.dtsi>
#include <dt-bindings/zmk/keys.h>
#include <dt-bindings/zmk/bt.h>
#include <dt-bindings/zmk/rgb.h>

/ {
    keymap {
        compatible = "zmk,keymap";

        default_layer {
            // This keymap will be overridden by the central device
            // Only define basic functionality here
            bindings = <
                &kp Q &kp W &kp E &kp R &kp T &kp Y
                &kp A &kp S &kp D &kp F &kp G &kp H
                &kp Z &kp X &kp C &kp V &kp B &kp N
                &kp LSHFT &kp LCTRL &kp LALT &kp SPACE &kp ENTER &kp RSHFT
                &mo 1 &kp LGUI &kp DEL &kp BSPC &kp TAB &mo 2
            >;
        };

        function_layer {
            bindings = <
                &kp F1 &kp F2 &kp F3 &kp F4 &kp F5 &kp F6
                &bt BT_SEL 0 &bt BT_SEL 1 &bt BT_SEL 2 &bt BT_SEL 3 &bt BT_SEL 4 &bt BT_CLR
                &rgb_ug RGB_ON &rgb_ug RGB_OFF &rgb_ug RGB_EFF &rgb_ug RGB_BRI &rgb_ug RGB_BRD &sys_reset
                &trans &trans &trans &trans &trans &trans
                &trans &trans &trans &trans &trans &trans
            >;
        };

        system_layer {
            bindings = <
                &kp F7 &kp F8 &kp F9 &kp F10 &kp F11 &kp F12
                &trans &trans &trans &trans &trans &trans
                &trans &trans &trans &trans &trans &bootloader
                &trans &trans &trans &trans &trans &trans
                &trans &trans &trans &trans &trans &trans
            >;
        };
    };
};
EOF

    log_success "Peripheral shield configurations created"
}

# Create dongle keymap with preserved user layout
create_dongle_keymap() {
    log_header "Creating Dongle Keymap"

    local dongle_keymap="$PROJECT_ROOT/config/dongle.keymap"

    # Extract keymap from existing configuration and adapt for dongle
    if [ -f "$PROJECT_ROOT/config/eyelash_sofle.keymap" ]; then
        log_info "Adapting existing keymap for dongle mode..."

        # Create dongle keymap based on existing layout
        cat > "$dongle_keymap" << 'EOF'
/*
 * Dongle Central Keymap - Eyelash Sofle
 * Based on original keymap but configured for central operation
 */

#include <behaviors.dtsi>
#include <dt-bindings/zmk/keys.h>
#include <dt-bindings/zmk/bt.h>
#include <dt-bindings/zmk/rgb.h>
#include <dt-bindings/zmk/outputs.h>

EOF

        # Extract the keymap content (removing board-specific includes)
        grep -v "#include.*eyelash_sofle" "$PROJECT_ROOT/config/eyelash_sofle.keymap" | \
        grep -v "#include.*boards" | \
        sed '/^#include/,$!d' >> "$dongle_keymap"

        log_success "Dongle keymap created based on existing layout"
    else
        log_warning "No existing keymap found, creating default dongle keymap"

        # Create default dongle keymap
        cat > "$dongle_keymap" << 'EOF'
#include <behaviors.dtsi>
#include <dt-bindings/zmk/keys.h>
#include <dt-bindings/zmk/bt.h>
#include <dt-bindings/zmk/rgb.h>
#include <dt-bindings/zmk/outputs.h>

/ {
    keymap {
        compatible = "zmk,keymap";

        default_layer {
            bindings = <
                &kp ESC   &kp N1 &kp N2 &kp N3 &kp N4 &kp N5     &kp N6 &kp N7 &kp N8    &kp N9  &kp N0   &kp BSPC
                &kp TAB   &kp Q  &kp W  &kp E  &kp R  &kp T      &kp Y  &kp U  &kp I     &kp O   &kp P    &kp BSLH
                &kp CAPS  &kp A  &kp S  &kp D  &kp F  &kp G      &kp H  &kp J  &kp K     &kp L   &kp SEMI &kp SQT
                &kp LSHFT &kp Z  &kp X  &kp C  &kp V  &kp B      &kp N  &kp M  &kp COMMA &kp DOT &kp FSLH &kp ENTER
                &kp LCTRL &kp LGUI &kp LALT &mo 1 &kp SPACE      &kp ENTER &kp SPACE &mo 2 &kp RSHFT &kp DEL
            >;
        };

        function_layer {
            bindings = <
                &kp GRAVE &kp F1 &kp F2 &kp F3 &kp F4 &kp F5       &kp F6 &kp F7 &kp F8 &kp F9 &kp F10 &trans
                &trans &kp GRAVE &trans &trans &trans &trans        &kp PG_UP &kp END &kp UP &kp HOME &kp MINUS &kp EQUAL
                &trans &kp TILDE &trans &trans &trans &trans        &kp PG_DN &kp LEFT &kp DOWN &kp RIGHT &kp LBKT &kp RBKT
                &trans &rgb_ug RGB_OFF &rgb_ug RGB_ON &rgb_ug RGB_EFF &rgb_ug RGB_EFR &rgb_ug RGB_SPI   &rgb_ug RGB_BRI &rgb_ug RGB_BRD &kp INSERT &kp F11 &kp F12 &trans
                &trans &trans &trans &trans &trans                  &trans &trans &trans &trans &trans
            >;
        };

        system_layer {
            bindings = <
                &kp TILDE &bt BT_SEL 0 &bt BT_SEL 1 &bt BT_SEL 2 &bt BT_SEL 3 &bt BT_SEL 4   &kp F6 &kp F7 &kp F8 &kp F9 &kp F10 &trans
                &trans &bt BT_CLR &bt BT_CLR_ALL &trans &trans &trans                       &trans &trans &kp F11 &kp F12 &kp UNDER &kp PLUS
                &trans &out OUT_USB &out OUT_BLE &trans &trans &trans                      &trans &trans &trans &trans &kp LBRC &kp RBRC
                &trans &sys_reset &trans &bootloader &trans &trans                         &trans &trans &sys_reset &soft_off &bootloader &trans
                &trans &trans &trans &trans &trans                                         &trans &trans &trans &trans &trans
            >;
        };
    };
};
EOF
    fi
}

# Configure dongle display settings
configure_dongle_display() {
    log_header "Configuring Dongle Display"

    local dongle_conf="$PROJECT_ROOT/config/dongle.conf"

    cat > "$dongle_conf" << 'EOF'
# Dongle Central Configuration

# Enable dongle battery display
CONFIG_ZMK_DONGLE_DISPLAY_DONGLE_BATTERY=y

# Use Mac modifier symbols (set to n for Windows symbols)
CONFIG_ZMK_DONGLE_DISPLAY_MAC_MODIFIERS=y

# Display configuration
CONFIG_ZMK_DISPLAY=y
CONFIG_ZMK_DISPLAY_STATUS_SCREEN_BUILT_IN=n
CONFIG_ZMK_DISPLAY_STATUS_SCREEN_CUSTOM=y

# Central role
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

# RGB configuration
CONFIG_ZMK_RGB_UNDERGLOW=y
CONFIG_ZMK_RGB_UNDERGLOW_EXT_POWER=y
CONFIG_ZMK_RGB_UNDERGLOW_ON_START=n
CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_IDLE=y
EOF

    log_success "Dongle display configuration created"
}

# Build firmware
build_firmware() {
    log_header "Building Firmware"

    cd "$PROJECT_ROOT"

    # Update west workspace with new modules
    log_info "Updating west workspace..."
    west update

    # Build all targets
    log_info "Building all firmware targets..."

    if prompt_confirm "Build all firmware now? This may take several minutes"; then
        west build --pristine

        # Create firmware directory
        mkdir -p "$PROJECT_ROOT/firmware"

        # Copy built firmware files
        if [ -d "build" ]; then
            find build -name "*.uf2" -exec cp {} "$PROJECT_ROOT/firmware/" \;
            log_success "Firmware built and copied to firmware/ directory"

            # List built firmware
            log_info "Built firmware files:"
            ls -la "$PROJECT_ROOT/firmware/"*.uf2
        else
            log_error "Build failed - no build directory found"
            return 1
        fi
    else
        log_info "Skipping firmware build - you can build later with 'west build'"
    fi
}

# Create flashing instructions
create_flashing_guide() {
    log_header "Creating Flashing Guide"

    cat > "$PROJECT_ROOT/DONGLE_SETUP_GUIDE.md" << 'EOF'
# Dongle Mode Setup Guide

This guide will walk you through flashing the dongle mode firmware step by step.

## Hardware Required
- 2x Eyelash Sofle keyboard halves
- 1x Additional Nice!Nano v2 (for dongle)
- 1x 128x64 OLED display (for dongle)
- USB-C cables
- Dongle case/housing

## Flashing Order

### Step 1: Flash Settings Reset (Optional but Recommended)
If you want to start fresh:

1. **Left Half**: Flash `settings_reset_left.uf2`
2. **Right Half**: Flash `settings_reset_right.uf2`
3. **Dongle**: Flash `settings_reset_dongle.uf2`

### Step 2: Flash Peripheral Firmware to Keyboard Halves

1. **Left Half**:
   - Enter bootloader mode (double-tap reset)
   - Flash `eyelash_sofle_dongle_peripheral_left.uf2`
   - Wait for restart

2. **Right Half**:
   - Enter bootloader mode (double-tap reset)
   - Flash `eyelash_sofle_dongle_peripheral_right.uf2`
   - Wait for restart

### Step 3: Flash Central Firmware to Dongle

1. **Dongle (Nice!Nano with OLED)**:
   - Enter bootloader mode
   - Flash `eyelash_sofle_dongle_central.uf2`
   - Wait for restart

## Connection Process

1. **Power on dongle first** and connect to computer via USB
2. **Power on both keyboard halves**
3. **Wait 30-60 seconds** for automatic pairing
4. **Test keys** from both halves

## Display Information

The dongle OLED will show:
- Connection status of both halves
- Battery levels of peripherals
- Active modifiers
- HID indicators (CAPS, NUM, SCROLL)
- Bongo cat animation
- Current layer information

## Troubleshooting

- If pairing fails, flash settings reset to all devices and try again
- Keep devices close during initial pairing
- Check that the correct firmware is flashed to each device
- Verify OLED display is properly connected to dongle

## Reverting to Standard Mode

To go back to standard wireless mode, flash the standard firmware:
- Left: `eyelash_sofle_standard_left.uf2`
- Right: `eyelash_sofle_standard_right.uf2`
EOF

    log_success "Flashing guide created: DONGLE_SETUP_GUIDE.md"
}

# Interactive flashing assistant
interactive_flashing_assistant() {
    log_header "Interactive Flashing Assistant"

    if ! prompt_confirm "Would you like to use the interactive flashing assistant?"; then
        log_info "Skipping interactive flashing - see DONGLE_SETUP_GUIDE.md for manual instructions"
        return 0
    fi

    log_info "This assistant will guide you through flashing each device."
    log_warning "Make sure you have all firmware files in the firmware/ directory"

    # Check firmware files exist
    local required_files=(
        "eyelash_sofle_dongle_peripheral_left.uf2"
        "eyelash_sofle_dongle_peripheral_right.uf2"
        "eyelash_sofle_dongle_central.uf2"
    )

    for file in "${required_files[@]}"; do
        if [ ! -f "$PROJECT_ROOT/firmware/$file" ]; then
            log_error "Missing firmware file: $file"
            log_info "Please build the firmware first"
            return 1
        fi
    done

    # Optional: Settings reset
    if prompt_confirm "Do you want to reset all devices first? (Recommended for clean setup)"; then
        log_step "Resetting Left Half"
        prompt_user "1. Put LEFT half in bootloader mode (double-tap reset button)\n2. Copy settings_reset_left.uf2 to the USB drive that appears"

        log_step "Resetting Right Half"
        prompt_user "1. Put RIGHT half in bootloader mode (double-tap reset button)\n2. Copy settings_reset_right.uf2 to the USB drive that appears"

        log_step "Resetting Dongle"
        prompt_user "1. Put DONGLE in bootloader mode (double-tap reset button)\n2. Copy settings_reset_dongle.uf2 to the USB drive that appears"

        log_info "Waiting 30 seconds for devices to restart..."
        sleep 30
    fi

    # Flash peripheral firmware
    log_step "Flashing Left Half (Peripheral)"
    prompt_user "1. Put LEFT half in bootloader mode (double-tap reset button)\n2. Copy eyelash_sofle_dongle_peripheral_left.uf2 to the USB drive that appears\n3. Wait for device to restart"

    log_step "Flashing Right Half (Peripheral)"
    prompt_user "1. Put RIGHT half in bootloader mode (double-tap reset button)\n2. Copy eyelash_sofle_dongle_peripheral_right.uf2 to the USB drive that appears\n3. Wait for device to restart"

    log_step "Flashing Dongle (Central)"
    prompt_user "1. Put DONGLE in bootloader mode (double-tap reset button)\n2. Copy eyelash_sofle_dongle_central.uf2 to the USB drive that appears\n3. Wait for device to restart"

    # Test connection
    log_step "Testing Connection"
    prompt_user "1. Connect dongle to computer via USB\n2. Power on both keyboard halves\n3. Wait 30-60 seconds for pairing\n4. Test typing on both halves"

    log_success "Flashing complete! Your dongle setup should now be working."
    log_info "Check the OLED display on the dongle for connection status and battery levels."
}

# Create VS Code configuration
create_vscode_config() {
    log_header "Creating VS Code Configuration"

    mkdir -p "$PROJECT_ROOT/.vscode"

    # Create launch configuration
    cat > "$PROJECT_ROOT/.vscode/launch.json" << 'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Build Standard Firmware",
            "type": "node-terminal",
            "request": "launch",
            "command": "west build --board eyelash_sofle_left -- -DZMK_CONFIG=\"$(pwd)/config\"",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "Build Dongle Firmware",
            "type": "node-terminal",
            "request": "launch",
            "command": "west build --pristine",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "Build Studio Firmware",
            "type": "node-terminal",
            "request": "launch",
            "command": "west build --board eyelash_sofle_left --shield nice_view -- -DZMK_CONFIG=\"$(pwd)/config\" -DCONFIG_ZMK_STUDIO=y",
            "cwd": "${workspaceFolder}"
        }
    ]
}
EOF

    # Create tasks configuration
    cat > "$PROJECT_ROOT/.vscode/tasks.json" << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "West Update",
            "type": "shell",
            "command": "west",
            "args": ["update"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Build All Firmware",
            "type": "shell",
            "command": "west",
            "args": ["build", "--pristine"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Clean Build",
            "type": "shell",
            "command": "rm",
            "args": ["-rf", "build"],
            "group": "build"
        }
    ]
}
EOF

    # Create settings
    cat > "$PROJECT_ROOT/.vscode/settings.json" << 'EOF'
{
    "files.associations": {
        "*.overlay": "c",
        "*.keymap": "c",
        "*.dtsi": "c",
        "*.dts": "c"
    },
    "C_Cpp.default.includePath": [
        "${workspaceFolder}/config",
        "${workspaceFolder}/zephyr/include",
        "${workspaceFolder}/zephyr/lib/libc/minimal/include"
    ],
    "C_Cpp.default.defines": [
        "CONFIG_ZMK=1"
    ]
}
EOF

    log_success "VS Code configuration created"
}

# Setup GitHub Actions
setup_github_actions() {
    log_header "Setting Up GitHub Actions"

    mkdir -p "$PROJECT_ROOT/.github/workflows"

    cat > "$PROJECT_ROOT/.github/workflows/build.yml" << 'EOF'
name: Build ZMK Firmware

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: zmkfirmware/zmk-build-arm:stable

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Cache west modules
      uses: actions/cache@v3
      with:
        path: |
          modules/
          tools/
          zephyr/
          bootloader/
          zmk/
        key: ${{ runner.os }}-west-${{ hashFiles('**/west.yml', '**/build.yaml') }}
        restore-keys: |
          ${{ runner.os }}-west-

    - name: West Init
      run: west init -l config

    - name: West Update
      run: west update

    - name: West Zephyr Export
      run: west zephyr-export

    - name: Build Firmware
      run: west build --pristine

    - name: Archive Firmware
      uses: actions/upload-artifact@v3
      with:
        name: firmware
        path: build/**/*.uf2
        retention-days: 30

    - name: Create Release on Tag
      if: startsWith(github.ref, 'refs/tags/')
      uses: softprops/action-gh-release@v1
      with:
        files: build/**/*.uf2
        generate_release_notes: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOF

    log_success "GitHub Actions workflow created"
}

# Main execution
main() {
    echo "🎮 ZMK Eyelash Sofle Dongle Configuration Setup"
    echo "================================================"
    echo ""
    echo "This script will configure your keyboard for dongle mode with custom OLED display."
    echo "Based on the zmk-dongle-display project by englmaxi."
    echo ""

    if ! prompt_confirm "Continue with dongle setup?"; then
        log_info "Setup cancelled"
        exit 0
    fi

    check_prerequisites
    backup_current_config
    setup_workspace
    add_dongle_display_module
    create_dongle_build_config
    create_peripheral_shields
    create_dongle_keymap
    configure_dongle_display
    build_firmware
    create_flashing_guide
    interactive_flashing_assistant
    create_vscode_config
    setup_github_actions

    log_header "Setup Complete!"

    echo ""
    echo "🎉 Dongle configuration setup is complete!"
    echo ""
    echo "📁 Backup created at: $BACKUP_DIR"
    echo "📖 Flashing guide: DONGLE_SETUP_GUIDE.md"
    echo "💾 Firmware files: firmware/"
    echo ""
    echo "Next steps:"
    echo "1. Review the flashing guide"
    echo "2. Flash firmware to your devices"
    echo "3. Test the dongle setup"
    echo ""
    echo "For help: https://github.com/englmaxi/zmk-dongle-display"
    echo ""
}

# Run main function
main "$@"

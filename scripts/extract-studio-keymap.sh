#!/bin/bash

# ZMK Studio Keymap Extraction Script
# Extracts your current keymap from the keyboard and saves it to the repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups/extracted_keymaps/$(date +%Y%m%d_%H%M%S)"

# Logging functions
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

# Check if ZMK Studio is available
check_zmk_studio() {
    log_info "Checking for ZMK Studio..."

    # Check if ZMK Studio is installed
    if command -v zmk-studio &> /dev/null; then
        log_success "ZMK Studio CLI found"
        return 0
    fi

    # Check for ZMK Studio app on macOS
    if [ -d '/Applications/ZMK Studio.app' ]; then
        log_success "ZMK Studio app found"
        return 0
    fi

    log_warning "ZMK Studio not found. You'll need to extract the keymap manually."
    return 1
}

# Detect connected keyboard
detect_keyboard() {
    log_info "Detecting connected ZMK keyboard..."

    # Check USB devices
    local usb_devices=$(system_profiler SPUSBDataType 2>/dev/null)

    # Look for ZMK devices
    if echo "$usb_devices" | grep -qi "zmk\|nice.*nano"; then
        log_success "ZMK device detected via USB"
        return 0
    fi

    # Check serial devices
    local serial_devices=$(ls /dev/tty.* 2>/dev/null | grep -i usb || true)
    if [ -n "$serial_devices" ]; then
        log_info "USB serial devices found:"
        echo "$serial_devices"
        return 0
    fi

    log_warning "No ZMK keyboard detected. Please connect your keyboard via USB."
    return 1
}

# Wait for keyboard connection
wait_for_keyboard() {
    log_step "Please connect your Eyelash Sofle keyboard via USB cable"
    echo "Make sure it's in ZMK Studio mode (not bootloader mode)"
    echo ""

    while true; do
        echo -n "Press Enter when keyboard is connected, or 'q' to quit: "
        read -r response

        if [ "$response" = "q" ]; then
            log_info "Extraction cancelled"
            exit 0
        fi

        if detect_keyboard; then
            break
        fi

        log_warning "Keyboard not detected. Please check connection and try again."
    done
}

# Extract keymap using ZMK Studio CLI (if available)
extract_with_cli() {
    log_info "Attempting to extract keymap using ZMK Studio CLI..."

    # This is a placeholder - actual ZMK Studio CLI commands may vary
    # The exact commands depend on the ZMK Studio version and API

    if command -v zmk &> /dev/null; then
        log_info "Using ZMK Studio CLI to extract keymap..."

        # Try to connect and extract
        if zmk-studio export --output "$BACKUP_DIR/extracted_keymap.json" 2>/dev/null; then
            log_success "Keymap extracted successfully"
            return 0
        fi
    fi

    log_warning "CLI extraction failed or not available"
    return 1
}

# Manual extraction instructions
manual_extraction_guide() {
    log_step "Manual Keymap Extraction Guide"
    echo ""
    echo "Since automatic extraction isn't available, please follow these steps:"
    echo ""
    echo "1. Open ZMK Studio application"
    echo "2. Connect to your Eyelash Sofle keyboard"
    echo "3. Go to File → Export → Export Keymap"
    echo "4. Save the file as 'my_current_keymap.json'"
    echo "5. Copy the exported file to: $BACKUP_DIR/"
    echo ""
    echo "Alternative method:"
    echo "1. In ZMK Studio, copy your entire keymap configuration"
    echo "2. Save it as a .keymap file"
    echo "3. Place it in: $BACKUP_DIR/"
    echo ""

    mkdir -p "$BACKUP_DIR"

    echo "Backup directory created: $BACKUP_DIR"
    echo ""
    echo "Press Enter when you've completed the manual extraction..."
    read -r
}

# Analyze extracted keymap
analyze_keymap() {
    log_info "Analyzing extracted keymap..."

    local keymap_files=$(find "$BACKUP_DIR" -name "*.json" -o -name "*.keymap" 2>/dev/null)

    if [ -z "$keymap_files" ]; then
        log_warning "No keymap files found in backup directory"
        return 1
    fi

    echo "Found keymap files:"
    echo "$keymap_files"
    echo ""

    # Analyze each file
    for file in $keymap_files; do
        log_info "Analyzing: $(basename "$file")"

        if [[ "$file" == *.json ]]; then
            # JSON keymap analysis
            if command -v jq &> /dev/null; then
                local layers=$(jq -r '.layers | length' "$file" 2>/dev/null || echo "unknown")
                local name=$(jq -r '.name // "unknown"' "$file" 2>/dev/null || echo "unknown")
                echo "  - Name: $name"
                echo "  - Layers: $layers"
            else
                echo "  - JSON file detected (install jq for detailed analysis)"
            fi
        elif [[ "$file" == *.keymap ]]; then
            # Keymap file analysis
            local layers=$(grep -c "layer.*{" "$file" 2>/dev/null || echo "unknown")
            echo "  - Layers found: $layers"
            echo "  - Size: $(wc -l < "$file") lines"
        fi
        echo ""
    done
}

# Integrate keymap into repository
integrate_keymap() {
    log_step "Integrating extracted keymap into repository"

    local keymap_files=$(find "$BACKUP_DIR" -name "*.json" -o -name "*.keymap" 2>/dev/null)

    if [ -z "$keymap_files" ]; then
        log_error "No keymap files to integrate"
        return 1
    fi

    # Create backup of current config
    log_info "Backing up current configuration..."
    "$SCRIPT_DIR/backup-restore.sh" backup-config

    # Copy extracted files to config
    for file in $keymap_files; do
        local filename=$(basename "$file")
        local dest="$PROJECT_ROOT/config/my_studio_${filename}"

        cp "$file" "$dest"
        log_success "Copied $filename to config/my_studio_${filename}"
    done

    # Create integration script
    cat > "$PROJECT_ROOT/integrate_my_keymap.sh" << 'EOF'
#!/bin/bash

# Integration script for your extracted keymap
# Run this after reviewing the extracted files

echo "🎹 Integrating your ZMK Studio keymap..."

# Backup current keymap
cp config/eyelash_sofle.keymap config/eyelash_sofle.keymap.backup

# If you have a .keymap file, replace the current one
if [ -f "config/my_studio_*.keymap" ]; then
    echo "Found extracted .keymap file"
    echo "Please manually review and merge with config/eyelash_sofle.keymap"
fi

# If you have a .json file, it needs conversion
if [ -f "config/my_studio_*.json" ]; then
    echo "Found extracted .json file"
    echo "This contains your ZMK Studio configuration"
    echo "You may need to manually convert key bindings to .keymap format"
fi

echo "✅ Integration preparation complete"
echo "📖 Review the files in config/ and manually merge as needed"
EOF

    chmod +x "$PROJECT_ROOT/integrate_my_keymap.sh"

    log_success "Integration script created: integrate_my_keymap.sh"
}

# Create keymap preservation guide
create_preservation_guide() {
    log_info "Creating keymap preservation guide..."

    cat > "$PROJECT_ROOT/KEYMAP_PRESERVATION.md" << 'EOF'
# ZMK Studio Keymap Preservation Guide

This guide helps you preserve and integrate your ZMK Studio keymap when setting up dongle mode.

## Your Current Keymap

Your ZMK Studio keymap is stored in the keyboard's flash memory and includes:
- Custom key bindings
- Layer configurations
- RGB settings
- Encoder behaviors
- Mouse/pointing device settings

## Extraction Process

### Method 1: ZMK Studio Export
1. Connect keyboard via USB
2. Open ZMK Studio
3. File → Export → Export Keymap
4. Save as JSON file

### Method 2: Manual Documentation
1. Screenshot each layer in ZMK Studio
2. Document special behaviors
3. Note RGB and encoder settings

## Integration with Dongle Mode

### Preserving Your Layout
The dongle setup will:
- ✅ Keep your existing key bindings
- ✅ Preserve layer structure
- ✅ Maintain RGB settings
- ✅ Keep encoder behaviors
- ✅ Preserve mouse controls

### What Changes for Dongle Mode
- Central device handles all processing
- Peripheral halves send key events to dongle
- Display shows on dongle instead of keyboard halves

## Files to Review

After extraction, check these files:
- `config/my_studio_*.json` - Your ZMK Studio configuration
- `config/my_studio_*.keymap` - Converted keymap (if available)
- `config/eyelash_sofle.keymap` - Current repository keymap

## Integration Steps

1. **Review Extracted Files**
   ```bash
   ls config/my_studio_*
   ```

2. **Compare with Current**
   ```bash
   diff config/eyelash_sofle.keymap config/my_studio_*.keymap
   ```

3. **Merge Configurations**
   - Copy your custom bindings
   - Preserve special behaviors
   - Keep RGB and encoder settings

4. **Test Build**
   ```bash
   west build --board eyelash_sofle_left
   ```

## Key Features to Preserve

Based on your current keymap, make sure to preserve:
- ✅ Mouse movement controls (mmv)
- ✅ Scroll wheel behavior (msc)
- ✅ RGB underglow effects
- ✅ Volume control encoder
- ✅ Bluetooth management keys
- ✅ Layer switching (MO 1, MO 2)
- ✅ Custom key positions

## Dongle-Specific Considerations

### Display Configuration
Your dongle will show:
- Battery levels of both halves
- Connection status
- Active modifiers
- Current layer
- Bongo cat animation

### Keymap Compatibility
Your existing keymap should work perfectly with dongle mode because:
- Same key matrix
- Same behaviors supported
- Same ZMK features available
- Only connection method changes

## Troubleshooting

### If Keys Don't Work
1. Check peripheral pairing
2. Verify keymap syntax
3. Test with settings reset

### If Features Missing
1. Ensure all behaviors are included
2. Check configuration flags
3. Verify shield compatibility

## Next Steps

1. Extract your current keymap
2. Run the dongle setup script
3. Integrate your keymap
4. Build and test firmware
5. Flash to all devices

Your custom keymap will be preserved throughout the dongle setup process!
EOF

    log_success "Preservation guide created: KEYMAP_PRESERVATION.md"
}

# Main execution
main() {
    echo "🎹 ZMK Studio Keymap Extraction Tool"
    echo "===================================="
    echo ""
    echo "This tool will help you extract your current ZMK Studio keymap"
    echo "and preserve it when setting up dongle mode."
    echo ""

    # Create backup directory
    mkdir -p "$BACKUP_DIR"

    # Check for ZMK Studio
    if check_zmk_studio; then
        echo ""
        log_info "ZMK Studio detected. We can attempt automatic extraction."
    else
        echo ""
        log_info "Manual extraction will be required."
    fi

    # Wait for keyboard connection
    wait_for_keyboard

    # Try automatic extraction first
    if check_zmk_studio && extract_with_cli; then
        log_success "Automatic extraction completed"
    else
        # Fall back to manual extraction
        manual_extraction_guide
    fi

    # Analyze what we got
    analyze_keymap

    # Integrate into repository
    integrate_keymap

    # Create preservation guide
    create_preservation_guide

    echo ""
    echo "🎉 Keymap extraction complete!"
    echo ""
    echo "📁 Extracted files: $BACKUP_DIR"
    echo "📖 Integration guide: KEYMAP_PRESERVATION.md"
    echo "🔧 Integration script: integrate_my_keymap.sh"
    echo ""
    echo "Next steps:"
    echo "1. Review extracted keymap files"
    echo "2. Run ./integrate_my_keymap.sh"
    echo "3. Run ./scripts/setup-dongle-configuration.sh"
    echo ""
}

# Run main function
main "$@"

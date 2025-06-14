# ZMK Eyelash Sofle Dongle Workflow

Complete workflow for setting up and using your Eyelash Sofle with zmk-dongle-display.

## Current Status ✅

- **Dongle**: Already has zmk-dongle-display firmware with bongo cat, battery display, and connection status
- **Keyboard**: ZMK Studio keymap stored on device (not in repository)
- **Repository**: Configured for dongle mode development

## Quick Start (Recommended Path)

### 1. Test Current Setup First
```bash
# Your dongle should already work with your keyboard halves
# 1. Connect dongle to computer via USB
# 2. Power on both keyboard halves
# 3. Wait 30-60 seconds for pairing
# 4. Test typing from both halves
```

**If everything works**: You're done! Your setup is perfect.

**If you have issues**: Continue to firmware building below.

### 2. Extract Your ZMK Studio Keymap (Optional but Recommended)
```bash
./scripts/extract-studio-keymap.sh
```
This preserves your custom keymap in the repository for future use.

### 3. Setup Dongle Configuration
```bash
./scripts/setup-dongle-configuration-focused.sh
```
This configures the repository for dongle mode while preserving your keymap.

### 4. Build and Flash (If Needed)
```bash
# Build firmware
west build --pristine

# Flash to keyboard halves only (dongle already has correct firmware)
# Left half: Double-tap reset → Copy eyelash_sofle_standard_left.uf2
# Right half: Double-tap reset → Copy eyelash_sofle_standard_right.uf2
```

## Development Environment (Advanced)

### Full Development Setup
```bash
./scripts/setup-dev-environment.sh
```
Installs complete ZMK development environment with:
- Zephyr SDK and toolchain
- VS Code with ZMK extensions
- Python tools and dependencies
- Hardware emulation capabilities

### Emulation and Testing
```bash
./scripts/emulator-setup.sh
```
Sets up hardware emulation for testing without physical devices.

## Your Preserved Features

✅ **All ZMK Studio customizations**:
- Custom key bindings and behaviors
- Mouse movement controls (mmv/msc)
- RGB underglow settings and effects
- Encoder behaviors (volume/scroll)
- Layer switching and management
- Bluetooth device management

✅ **Enhanced dongle features**:
- Real-time battery monitoring of both halves
- Visual connection status indicators
- Active modifier display (Shift, Ctrl, Alt, etc.)
- Current layer name display
- Bongo cat typing animation
- HID lock indicators (CAPS, NUM, SCROLL)

## Dongle Display Features

Your zmk-dongle-display shows:

### Top Section
- **Battery Levels**: Percentage for left and right halves
- **Connection Status**: Connected/disconnected indicators

### Middle Section
- **Active Modifiers**: Visual symbols for pressed modifiers
- **HID Indicators**: CAPS, NUM, SCROLL lock status

### Bottom Section
- **Layer Name**: Current active layer
- **Bongo Cat**: Animated cat that reacts to typing speed

## File Structure

```
zmk-sofle/
├── scripts/
│   ├── extract-studio-keymap.sh          # Extract keymap from keyboard
│   ├── setup-dongle-configuration-focused.sh  # Configure for dongle mode
│   ├── setup-dev-environment.sh          # Full development environment
│   ├── emulator-setup.sh                 # Hardware emulation
│   └── backup-restore.sh                 # Configuration management
├── config/
│   ├── eyelash_sofle.keymap              # Base keymap
│   ├── eyelash_sofle.conf                # Base configuration
│   ├── dongle.keymap                     # Dongle-compatible keymap
│   ├── dongle.conf                       # Dongle configuration
│   └── west.yml                          # West workspace config
├── docs/                                 # Comprehensive documentation
├── backups/                              # Automatic backups
├── firmware/                             # Built firmware files
├── build.yaml                            # Build configuration
├── DONGLE_QUICK_SETUP.md                 # Quick setup guide
├── KEYMAP_PRESERVATION.md                # Keymap preservation guide
└── DONGLE_WORKFLOW.md                    # This workflow guide
```

## Firmware Files

After building, you'll have:

### Standard Mode
- `eyelash_sofle_standard_left.uf2` - Left half standard wireless
- `eyelash_sofle_standard_right.uf2` - Right half standard wireless

### ZMK Studio Mode
- `eyelash_sofle_studio_left.uf2` - Left half with ZMK Studio support

### Dongle Mode
- `eyelash_sofle_dongle_central.uf2` - Dongle central (backup)

### Utilities
- `settings_reset_left.uf2` - Reset left half
- `settings_reset_right.uf2` - Reset right half
- `settings_reset_dongle.uf2` - Reset dongle

## Troubleshooting Workflow

### Connection Issues
1. **Check dongle display** - Should show status immediately
2. **Verify power** - Both halves powered on
3. **Reset if needed** - Use settings reset firmware
4. **Reflash halves** - Update keyboard firmware only

### Keymap Issues
1. **Extract current keymap** - Use extraction script
2. **Verify preservation** - Check config files
3. **Test behaviors** - Ensure all features work
4. **Rebuild if needed** - Fresh firmware build

### Display Issues
1. **Check OLED connection** - Physical connection to dongle
2. **Verify firmware** - Dongle should have zmk-dongle-display
3. **Test features** - Bongo cat, battery levels, modifiers

## Advanced Workflows

### Keymap Development
```bash
# Extract current keymap
./scripts/extract-studio-keymap.sh

# Modify keymap files
# Edit config/dongle.keymap

# Build and test
west build --pristine

# Flash to test devices
```

### Firmware Customization
```bash
# Setup development environment
./scripts/setup-dev-environment.sh

# Modify configurations
# Edit config/dongle.conf

# Build custom firmware
west build --pristine

# Test with emulation
./scripts/emulator-setup.sh
```

### Backup and Restore
```bash
# Create backup
./scripts/backup-restore.sh backup-all

# Restore configuration
./scripts/backup-restore.sh restore-config

# Export for sharing
./scripts/backup-restore.sh export-config
```

## Success Indicators

✅ **Working Setup**:
- Dongle display shows battery levels and connection status
- Both keyboard halves respond to typing
- All your custom key bindings work
- RGB effects and encoder behaviors preserved
- Bongo cat animates when typing

✅ **Development Ready**:
- West workspace configured for zmk-dongle-display
- Build system produces all firmware variants
- VS Code configured for ZMK development
- Emulation environment available for testing

## Next Steps

1. **Test current setup** - Verify everything works as-is
2. **Extract keymap** - Preserve your ZMK Studio configuration
3. **Configure repository** - Setup for dongle development
4. **Build firmware** - Only if needed for updates
5. **Develop further** - Customize and enhance as desired

Your ZMK Studio keymap is fully preserved and compatible with dongle mode. The dongle provides enhanced visual feedback while maintaining all your custom functionality!

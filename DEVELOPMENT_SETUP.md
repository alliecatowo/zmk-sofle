# ZMK Eyelash Sofle Development Setup Guide

This guide will help you set up a complete development environment for your ZMK Eyelash Sofle keyboard, including dongle mode with custom OLED display support.

## Overview

Your keyboard supports multiple operating modes:
- **Standard Mode**: Traditional BLE split keyboard
- **Dongle Mode**: 3-piece system (left + right + USB dongle) for non-BLE devices
- **ZMK Studio Mode**: Real-time keymap editing without reflashing
- **Hardware Emulation**: Virtual testing environment

## Quick Start

### 1. Initial Setup
```bash
# Clone this repository (if not already done)
git clone <your-repo-url>
cd zmk-sofle

# Set up development environment
./scripts/setup-dev-environment.sh

# Reload shell configuration
source ~/.zprofile
```

### 2. Verify Installation
```bash
# Check that everything is working
zmk-status

# Should show:
# - ZMK Workspace: /path/to/workspace
# - West Version: 1.x.x
# - Python Version: 3.x.x
# - CMake Version: 3.x.x
```

### 3. Build Standard Firmware
```bash
# Build all firmware variants
west build --pristine

# Or build specific targets
west build --board eyelash_sofle_left --shield nice_view
```

## Dongle Mode Setup

### Prerequisites
- 1x Additional Nice!Nano v2 (for dongle)
- 1x 128x64 OLED display (SSD1306 or SH1106)
- Soldering skills for dongle assembly

### Automated Setup
```bash
# Run the interactive dongle setup
./scripts/setup-dongle-configuration.sh

# This will:
# - Backup your current configuration
# - Add the zmk-dongle-display module
# - Update build configuration
# - Guide you through flashing
```

### Manual Setup Steps

1. **Add Dongle Display Module**
   ```yaml
   # config/west.yml
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
   ```

2. **Update Dependencies**
   ```bash
   west update
   ```

3. **Build Dongle Firmware**
   ```bash
   west build --board nice_nano_v2 --shield dongle_display
   ```

4. **Flash Firmware**
   - Central: `eyelash_sofle_dongle_central.uf2`
   - Left: `eyelash_sofle_standard_left.uf2` (or peripheral firmware)
   - Right: `eyelash_sofle_standard_right.uf2` (or peripheral firmware)

## VS Code Integration

### Extensions
The setup script installs these essential extensions:
- C/C++ (Microsoft)
- CMake Tools
- Python
- YAML
- Markdown All in One
- Serial Monitor

### Key Features
- **Build Tasks**: Ctrl+Shift+P → "Tasks: Run Task"
- **Launch Configs**: F5 to run predefined configurations
- **IntelliSense**: Full code completion for ZMK/Zephyr
- **Problem Detection**: Real-time error highlighting

### Useful Commands
```bash
# In VS Code terminal
west build                 # Build current configuration
west build --pristine      # Clean build
west update                # Update dependencies
```

## Hardware Emulation

### Virtual Keyboard
```bash
# Start virtual keyboard interface
./emulator/launch-virtual-keyboard.sh

# Opens in browser at http://localhost:8080
# Features:
# - Interactive key testing
# - Battery simulation
# - Layer visualization
# - Key logging
```

### Hardware Simulator
```bash
# Start command-line simulator
./emulator/launch-hardware-sim.sh

# Commands:
# p - Press key
# e - Rotate encoder
# r - Toggle RGB
# l - Switch layer
# b - Drain battery
# a - Random activity
```

### Emulation Build
```bash
# Build firmware for native emulation
west build -b native_posix -- -DZMK_CONFIG="$(pwd)/config"

# Run emulated firmware
./build/zephyr/zmk.exe
```

## GitHub Actions

### Automated Building
- **Triggers**: Push to main/develop, PR, manual dispatch
- **Builds**: All firmware variants automatically
- **Artifacts**: UF2 files available for download
- **Releases**: Tagged releases create GitHub releases

### Manual Release
```bash
# Create a release via GitHub Actions
# Go to Actions → Build ZMK Firmware → Run workflow
# Enter release tag (e.g., "v1.0.0")
```

## Backup and Restore

### Configuration Backup
```bash
# Backup current configuration
./scripts/backup-restore.sh backup-config

# List available backups
./scripts/backup-restore.sh list-backups

# Restore from backup
./scripts/backup-restore.sh restore-config backups/config/20240101_120000
```

### Firmware Backup
```bash
# Backup built firmware
./scripts/backup-restore.sh backup-firmware

# Export configuration for sharing
./scripts/backup-restore.sh export my_config_v1

# Import shared configuration
./scripts/backup-restore.sh import exports/my_config_v1.tar.gz
```

## Troubleshooting

### Common Issues

#### Build Errors
```bash
# Clean and rebuild
west build --pristine

# Update all dependencies
west update

# Check for missing tools
zmk-status
```

#### Connection Issues
```bash
# Reset all devices
# Flash settings_reset_*.uf2 to each device
# Then flash normal firmware
```

#### VS Code Issues
```bash
# Reload VS Code workspace
# Ctrl+Shift+P → "Developer: Reload Window"

# Check C++ configuration
# Ctrl+Shift+P → "C/C++: Edit Configurations (UI)"
```

### Getting Help
1. Check the [troubleshooting guide](docs/troubleshooting.md)
2. Review the [hardware overview](docs/hardware-overview.md)
3. Consult the [ZMK documentation](https://zmk.dev)
4. Search GitHub issues in the [zmk-dongle-display repo](https://github.com/englmaxi/zmk-dongle-display)

## Development Workflow

### Daily Development
1. **Make Changes**: Edit keymap or configuration
2. **Test in Emulator**: Use virtual keyboard or simulator
3. **Build**: `west build` or use VS Code tasks
4. **Flash**: Copy UF2 files to keyboard
5. **Test**: Verify functionality
6. **Backup**: Save working configurations

### Advanced Features

#### Custom Behaviors
```c
// Add to keymap
&custom_behavior
```

#### RGB Customization
```c
// RGB underglow effects
&rgb_ug RGB_EFF
```

#### Encoder Functions
```c
// Custom encoder behavior
&enc_kp C_VOL_UP C_VOL_DN
```

## File Structure

```
zmk-sofle/
├── config/                 # ZMK configuration
│   ├── eyelash_sofle.keymap # Main keymap
│   ├── eyelash_sofle.conf   # Configuration
│   └── west.yml            # Dependencies
├── scripts/                # Automation scripts
│   ├── setup-dev-environment.sh
│   ├── setup-dongle-configuration.sh
│   └── backup-restore.sh
├── emulator/               # Hardware emulation
│   ├── virtual-keyboard/   # Web interface
│   └── simulator/          # Python simulator
├── docs/                   # Documentation
├── .vscode/                # VS Code configuration
├── .github/                # GitHub Actions
└── build.yaml             # Build configuration
```

## Next Steps

1. **Complete Environment Setup**: Run the setup scripts
2. **Build Standard Firmware**: Test basic functionality
3. **Set Up Dongle Mode**: If you want the 3-piece system
4. **Customize Keymap**: Modify for your needs
5. **Test with Emulator**: Verify before flashing
6. **Deploy to Hardware**: Flash and enjoy!

## Resources

- [ZMK Documentation](https://zmk.dev)
- [Dongle Display Project](https://github.com/englmaxi/zmk-dongle-display)
- [ZMK Studio](https://zmk.dev/docs/features/studio)
- [Nice!Nano Documentation](https://nicekeyboards.com/docs/nice-nano/)
- [Zephyr RTOS](https://docs.zephyrproject.org/)

---

🎹 **Happy Coding!** Your ZMK Eyelash Sofle development environment is ready to go!

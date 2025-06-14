# AllieCatKeeb Dongle Setup

Clean and simple setup for ZMK dongle mode with OLED display using GitHub Actions.

## Quick Start

1. **Extract your current keymap** (IMPORTANT - do this first!):
   ```bash
   ./scripts/extract-current-keymap.sh
   ```

2. **Push to GitHub and use Actions**:
   ```bash
   git add .
   git commit -m "Add dongle configuration"
   git push
   ```

3. **Download firmware from GitHub Actions**:
   - Go to your repository's Actions tab
   - Wait for build to complete (~5 minutes)
   - Download all firmware files from artifacts

## Hardware Requirements

- **Dongle**: Nice!Nano v2 + 128x64 OLED display (I2C)
- **Keyboard halves**: Your existing Eyelash Sofle boards

## Firmware Files (from GitHub Actions)

- `alliecatkeeb_dongle_central.uf2` - Flash to dongle (Nice!Nano v2)
- `alliecatkeeb_left_peripheral.uf2` - Flash to left half
- `alliecatkeeb_right_peripheral.uf2` - Flash to right half
- `settings_reset_*.uf2` - Reset Bluetooth settings if needed

## Flashing Order

1. Flash settings reset to all devices (if needed)
2. Flash dongle firmware to Nice!Nano v2
3. Flash peripheral firmware to keyboard halves
4. Power on dongle first, then keyboard halves
5. They should auto-pair

## OLED Wiring

Connect 128x64 OLED to Nice!Nano v2:
- VCC → 3.3V
- GND → GND
- SDA → Pin 2 (I2C SDA)
- SCL → Pin 3 (I2C SCL)

## Features

- ✅ Wireless dongle with OLED display
- ✅ Shows current layer, battery levels, connection status
- ✅ Preserves your existing keymap
- ✅ Works with ZMK Studio
- ✅ Fast GitHub Actions build (~5 minutes)
- ✅ No local dependencies needed

## Troubleshooting

- **No pairing**: Flash settings reset, then reflash firmware
- **Display not working**: Check I2C wiring to pins 2/3
- **Build fails**: Check GitHub Actions logs for errors

## Why GitHub Actions?

- **No local setup** - no need to install Zephyr SDK, west, etc.
- **Fast builds** - GitHub's servers are much faster
- **Clean environment** - consistent builds every time
- **Multiple variants** - builds all firmware types automatically

## Scripts

- `extract-current-keymap.sh` - Backup your current keymap

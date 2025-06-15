# ZMK Eyelash Sofle Keyboard

[![Build Firmware](https://github.com/alliecatowo/zmk-sofle/actions/workflows/build.yml/badge.svg)](https://github.com/alliecatowo/zmk-sofle/actions/workflows/build.yml)

This is Allison Coleman's personal fork and English translation of the ZMK firmware configuration for the **"Eyelash Sofle"** split keyboard sold on AliExpress. This board is a popular low-profile 58-key split keyboard with OLED/e-ink displays and RGB support.

## 📖 Documentation

- [Quick Start Guide](docs/quick-start.md) - Get up and running quickly
- [Hardware Overview](docs/hardware-overview.md) - Detailed hardware specifications
- [Building Firmware](docs/building-firmware.md) - How to customize and build your own firmware
- [Dongle Mode Setup](docs/dongle-mode.md) - Use a unified receiver for both halves
- [ZMK Studio Guide](docs/zmk-studio.md) - Graphical keymap editor
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [Changelog](docs/changelog.md) - Version history and updates

## 🚀 Quick Start

### Option 1: Use Pre-built Firmware (Easiest)

1. Go to [Actions](https://github.com/alliecatowo/zmk-sofle/actions)
2. Click the latest successful build
3. Download the firmware artifacts
4. Flash according to your setup:
   - **Standard Mode**: `eyelash_sofle_studio_left.uf2` + `eyelash_sofle_standard_right.uf2`
   - **Dongle Mode**: `alliecatkeeb_dongle_central.uf2` + both peripheral firmwares

### Option 2: Fork and Build (Customizable)

1. Fork this repository
2. Edit `config/eyelash_sofle.keymap` to customize your layout
3. Push changes to trigger automatic builds
4. Download firmware from Actions tab

### Option 3: Manual Build Triggers

Go to Actions → Build ZMK Firmware → Run workflow and choose:
- **All**: Build everything (default)
- **Standard**: Left-side master configuration only
- **Dongle**: Unified receiver configuration only
- **Reset Only**: Settings reset firmware only

## 🎯 Features

- **ZMK Studio Support** - Edit keymaps graphically without rebuilding
- **Dual Mode Operation**:
  - Standard split keyboard mode (left side master)
  - Dongle mode with unified receiver
- **Display Support**: OLED and Nice!View e-ink displays
- **RGB Underglow**: Customizable lighting effects
- **Low Power**: Optimized for battery life

## 🛠️ Hardware Requirements

### For Standard Mode
- 2x Nice!Nano v2 controllers
- 2x Nice!View displays (or 128x64 OLED)
- Eyelash Sofle PCBs

### For Dongle Mode
- 3x Nice!Nano v2 controllers (one for dongle)
- 2x Nice!View displays
- 1x 128x64 OLED for dongle
- Eyelash Sofle PCBs

## 📦 What's Included

- Complete ZMK configuration for Eyelash Sofle
- Support for both split and dongle modes
- Pre-configured display layouts
- RGB underglow configuration
- Power management optimizations
- Automated GitHub Actions builds

## 🤝 Contributing

Issues and pull requests are welcome! Please check existing issues before creating new ones.

## 📄 License

This project inherits the licenses of its components:
- ZMK firmware is MIT licensed
- Hardware designs follow their original licenses

## 🙏 Credits

- Original Eyelash Sofle design from AliExpress seller
- ZMK firmware team for the excellent keyboard firmware
- @englmaxi for the zmk-dongle-display module

---

**Need help?** Check the [documentation](docs/) or open an issue!

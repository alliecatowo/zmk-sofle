# Changelog

All notable changes to the ZMK AllieCat Sofle firmware project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Enhanced ZMK Studio integration
- Additional RGB effects
- Improved battery life optimizations
- Community keymap contributions

## [2025.03.30] - Power Management & Stability Update

### Added
- **Extended sleep timeout**: Increased idle sleep timeout to 1 hour (3600000ms)
- **Enhanced debounce timing**: Improved key debounce for better reliability
- **Optimized power consumption**: Reduced power usage in sleep mode

### Changed
- Sleep entry time increased from 30 minutes to 1 hour
- Debounce press/release timing set to 8ms for optimal responsiveness
- Power management optimizations for better battery life

### Technical Details
```c
// New sleep timeout configuration
CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=3600000  // 1 hour

// Enhanced debounce settings
CONFIG_ZMK_KSCAN_DEBOUNCE_PRESS_MS=8
CONFIG_ZMK_KSCAN_DEBOUNCE_RELEASE_MS=8
```

## [2024.12.21] - ZMK Studio Integration

### Added
- **ZMK Studio support**: Real-time keymap editing without firmware rebuilds
- **Studio-specific firmware**: Separate build target with Studio RPC support
- **Live configuration**: Change keymaps, RGB settings, and behaviors in real-time
- **USB-UART interface**: Studio communication over USB connection

### Changed
- **Left-half only Studio support**: Only left half needs Studio firmware
- **Standard firmware compatibility**: Right half continues using standard firmware
- **Build configuration**: Added Studio build target to `build.yaml`

### Technical Details
```yaml
# New Studio build target
- board: alliecat_keeb_left
  shield: nice_view
  snippet: studio-rpc-usb-uart
  cmake-args: -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n
  artifact-name: alliecat_keeb_studio_left
```

### Usage
- Flash Studio firmware to left half only
- Use ZMK Studio web interface or desktop application
- Connect via USB for real-time editing
- Changes apply immediately without reflashing

## [2024.10.24] - Power Optimization & RGB Improvements

### Added
- **Improved power supply mode**: Reduced overall power consumption
- **RGB power management**: Enhanced automatic RGB shutdown functionality
- **Power efficiency**: Better battery life through optimized power paths

### Changed
- **Power supply architecture**: Modified to reduce idle power draw
- **RGB auto-off logic**: Fixed automatic RGB power shutdown on idle/USB disconnect
- **Battery optimization**: Improved power management for longer battery life

### Fixed
- **RGB power control**: Corrected RGB automatic shutdown feature
- **Power consumption issues**: Resolved excessive power draw in idle states
- **Battery drain**: Fixed rapid battery discharge problems

### Technical Details
```c
// Enhanced power management
CONFIG_ZMK_RGB_UNDERGLOW_EXT_POWER=y
CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_IDLE=y
CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_USB=y
CONFIG_ZMK_RGB_UNDERGLOW_ON_START=n
```

### ⚠️ Important Notice
> **If your keyboard was updated before October 24, 2024, please update to the latest firmware to benefit from these power optimizations.**

## [2024.09.xx] - Initial Release Features

### Added
- **Split keyboard support**: Full ZMK implementation for Sofle layout
- **Bluetooth connectivity**: 5 profile Bluetooth Low Energy support
- **RGB underglow**: WS2812 LED support with multiple effects
- **Nice!View displays**: OLED display integration for both halves
- **Rotary encoder**: Volume control and layer-specific functions
- **Mouse support**: Built-in pointing device functionality
- **Custom board definition**: AllieCat Sofle hardware definition

### Hardware Support
- **Controllers**: Nice!Nano v2 (nRF52840)
- **Displays**: Nice!View 128x32 OLED
- **RGB**: WS2812 underglow LEDs
- **Encoder**: EC11 rotary encoder with push button
- **Battery**: Li-Po battery support with charging

### Default Features
```c
// Core features enabled by default
CONFIG_ZMK_SLEEP=y
CONFIG_ZMK_RGB_UNDERGLOW=y
CONFIG_EC11=y
CONFIG_ZMK_EXT_POWER=y
CONFIG_ZMK_POINTING=y
CONFIG_ZMK_BACKLIGHT=y
```

## [Dongle Mode Support] - Wireless Receiver Functionality

### Added
- **Dongle mode firmware**: 3-piece system with wireless receiver
- **Central dongle**: USB-connected receiver for non-Bluetooth devices
- **Peripheral firmware**: Specialized firmware for keyboard halves in dongle mode
- **OLED dongle display**: Status display on dongle receiver
- **Multi-profile support**: Profile switching through dongle

### Components
- **Left peripheral**: `eyeslash_sofle_peripheral_left nice_oled-nice_nano_v2-zmk.uf2`
- **Right peripheral**: `eyeslash_sofle_peripheral_right nice_oled-nice_nano_v2-zmk.uf2`
- **Central dongle**: `eyeslash_sofle_central_dongle_oled.uf2`
- **Settings reset**: `settings_reset-nice_nano_v2-zmk.uf2`

### Use Cases
- Gaming systems requiring low latency
- Corporate environments with Bluetooth restrictions
- Older computers without Bluetooth capability
- KVM switches and server management

## [Hardware Revisions]

### Board Definition Evolution
- **Initial design**: Basic Sofle layout adaptation
- **Enhanced I/O**: Additional GPIO assignments for features
- **Power optimization**: Improved power management circuits
- **Display integration**: Native Nice!View support

### Pin Assignments
```c
// Current GPIO configuration
row-gpios = <&gpio0 19>, <&gpio0 8>, <&gpio0 12>, <&gpio0 11>, <&gpio1 9>
encoder-a = <&gpio1 10>
encoder-b = <&gpio1 14>
rgb-data = <&gpio1 12>
backlight = <&gpio1 13>
ext-power = <&gpio0 13>
```

## [Documentation Improvements]

### Added
- **Comprehensive English documentation**: Complete translation and expansion
- **Setup guides**: Detailed installation and configuration instructions
- **Troubleshooting**: Common issues and solutions
- **Build instructions**: Local and cloud build processes
- **Feature documentation**: RGB, encoder, mouse, and Studio guides

### Structure
```
docs/
├── README.md                    # Main documentation index
├── quick-start.md               # Getting started guide
├── building-firmware.md         # Build instructions
├── dongle-mode.md              # Dongle setup guide
├── zmk-studio.md               # Studio integration
├── troubleshooting.md          # Problem solving
└── [additional guides...]
```

## Migration Notes

### From Standard ZMK
- **Board definition**: Uses custom `alliecat_keeb` board
- **Shield compatibility**: Nice!View display support included
- **Feature additions**: Mouse, RGB, encoder support enabled by default

### From Previous Versions
- **Power settings**: Update firmware for improved battery life
- **Studio support**: Flash Studio firmware for real-time editing
- **Dongle mode**: Separate firmware set for dongle functionality

## Known Issues

### Current Limitations
- **Studio firmware**: USB connection required for Studio interface
- **Dongle mode**: Requires third Nice!Nano controller
- **Battery monitoring**: Right half battery level not always accurate
- **RGB effects**: Some effects may impact battery life significantly

### Workarounds
- Use standard firmware when Studio editing not needed
- Monitor battery levels manually in dongle mode
- Adjust RGB brightness and auto-off settings for better battery life

## Future Roadmap

### Short Term (Next Release)
- [ ] Improved battery reporting accuracy
- [ ] Additional RGB effects
- [ ] Enhanced Studio integration
- [ ] Community keymap templates

### Medium Term
- [ ] Wireless dongle with display
- [ ] Advanced pointing device features
- [ ] Custom encoder behaviors
- [ ] Power profiling tools

### Long Term
- [ ] Multi-device seamless switching
- [ ] Advanced gesture support
- [ ] Haptic feedback integration
- [ ] Custom PCB revision

## Contributing

### How to Contribute
1. **Issues**: Report bugs and request features
2. **Documentation**: Improve and expand guides
3. **Keymaps**: Share custom configurations
4. **Testing**: Help validate new features

### Contribution Guidelines
- Follow ZMK coding standards
- Test changes thoroughly
- Update documentation for new features
- Provide clear commit messages

---

**For the latest updates**, check the [repository releases](https://github.com/your-repo/releases) or monitor the [ZMK Discord](https://discord.gg/8cfMkQksSB) for community announcements.

# Dongle Mode Guide

The AllieCat Sofle supports a unique **dongle mode** that allows you to use your wireless split keyboard with devices that don't have Bluetooth, or in environments where Bluetooth connections are restricted.

## 🎯 What is Dongle Mode?

Dongle mode transforms your keyboard setup into a **3-piece system**:
- **Left keyboard half**: Acts as a peripheral device
- **Right keyboard half**: Acts as a peripheral device  
- **Dongle**: A third Nice!Nano that acts as a central receiver

The dongle connects to your computer via USB and receives input from both keyboard halves wirelessly, then forwards it to your computer as if it were a regular wired keyboard.

## 🔧 Hardware Requirements

### Essential Components
- **3x Nice!Nano controllers** (one for each half + dongle)
- **1x OLED display** for the dongle (optional but recommended)
- **USB-C cable** for dongle connection
- **Dongle housing/case** (3D printed or purchased separately)

### Optional Enhancements
- **Status LEDs** on dongle for connection indication
- **Reset button** for easy dongle management
- **Power switch** for dongle (if using battery backup)

## 📦 Firmware Files

The dongle mode requires specific firmware files located in:
-`Instructions_ORIGINAL_CHINESE/zmk studio和 and new firmware/sofle-dongle-firmware接收器版固件/`

### Required Firmware Files
- `eyeslash_sofle_peripheral_left nice_oled-nice_nano_v2-zmk.uf2` - Left half
- `eyeslash_sofle_peripheral_right nice_oled-nice_nano_v2-zmk.uf2` - Right half
- `eyeslash_sofle_central_dongle_oled.uf2` - Dongle receiver
- `settings_reset-nice_nano_v2-zmk.uf2` - Reset firmware (if needed)

## 📋 Setup Instructions

### Step 1: Flash Peripheral Firmware
1. **Left Half Setup**:
   - Put left Nice!Nano in bootloader mode (double-tap reset)
   - Flash `eyeslash_sofle_peripheral_left nice_oled-nice_nano_v2-zmk.uf2`
   - Wait for restart

2. **Right Half Setup**:
   - Put right Nice!Nano in bootloader mode (double-tap reset)
   - Flash `eyeslash_sofle_peripheral_right nice_oled-nice_nano_v2-zmk.uf2`
   - Wait for restart

### Step 2: Prepare Dongle Hardware
1. **Install Nice!Nano** in dongle housing
2. **Connect OLED display** (if using)
3. **Add status LEDs** (optional)
4. **Install reset button** (recommended)

### Step 3: Flash Dongle Firmware
1. **Put dongle in bootloader mode** (double-tap reset)
2. **Flash** `eyeslash_sofle_central_dongle_oled.uf2`
3. **Wait for restart** - dongle should appear as USB device

### Step 4: Pair Devices
1. **Power on** all three devices (both halves + dongle)
2. **Connect dongle** to computer via USB
3. **Automatic pairing** should occur within 30 seconds
4. **Verify connectivity** by testing keys from both halves

## 🖥️ Dongle Display Information

The OLED display on the dongle shows:
- **Connection status** for left and right halves
- **Active profile** information
- **Battery levels** of connected peripherals
- **Current layer** indicator
- **Error messages** if connection issues occur

### Display Layout
```
┌─────────────────┐
│ EYELASH SOFLE   │
│ Dongle Mode     │
│                 │
│ L: ●●●○○ (75%)  │
│ R: ●●●●○ (85%)  │
│                 │
│ Profile: 1      │
│ Layer: 0        │
└─────────────────┘
```

## ⚙️ Configuration Options

### Dongle Behavior Settings
Located in dongle firmware configuration:

```c
// Connection timeout (ms)
CONFIG_BT_PERIPHERAL_TIMEOUT=30000

// Maximum connected peripherals
CONFIG_BT_MAX_CONN=2

// Display update interval (ms)
CONFIG_DISPLAY_UPDATE_INTERVAL=1000

// Auto-sleep timeout (ms)
CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=1800000
```

### Peripheral Settings
Both keyboard halves are configured as peripherals:

```c
// Peripheral mode enabled
CONFIG_ZMK_SPLIT_ROLE_CENTRAL=n

// Advertising interval (ms)
CONFIG_BT_PERIPHERAL_ADVERT_INTERVAL=40

// Connection interval (ms)
CONFIG_BT_PERIPHERAL_CONN_INTERVAL=7.5
```

## 🔄 Profile Management

### Switching Profiles
The dongle supports multiple profiles for different host devices:

1. **Profile 0**: Default profile
2. **Profile 1-4**: Additional profiles for different computers
3. **Profile switching**: Use keyboard shortcuts or dongle button

### Profile Selection Methods
- **Keyboard shortcut**: Layer 2 + Number keys (0-4)
- **Dongle button**: Press and hold for profile cycling
- **Auto-switching**: Based on last connected device

## 🛠️ Advanced Features

### Low Latency Mode
Enable ultra-low latency for gaming:
```c
CONFIG_BT_CTLR_TX_PWR_PLUS_8=y
CONFIG_BT_CONN_INTERVAL_MIN=6
CONFIG_BT_CONN_INTERVAL_MAX=6
```

### Battery Monitoring
Dongle monitors and reports battery levels:
- **Low battery warnings** displayed on OLED
- **Automatic power management** for peripherals
- **Battery level synchronization** with host

### Connection Recovery
Automatic reconnection features:
- **Auto-reconnect** after temporary disconnection
- **Connection prioritization** (last connected device first)
- **Fallback pairing** if primary connection fails

## 🆘 Troubleshooting

### Common Issues

#### Dongle Not Recognized
- **Check USB connection** - try different ports/cables
- **Verify firmware** - ensure correct dongle firmware flashed
- **Driver issues** - may need USB driver reinstallation

#### Peripherals Not Connecting
- **Check pairing order** - dongle must be powered first
- **Reset connections** - use settings reset firmware
- **Battery levels** - ensure adequate charge on all devices

#### High Latency/Lag
- **Interference** - move away from other wireless devices
- **Connection interval** - adjust in firmware configuration
- **USB power** - ensure stable power supply to dongle

#### Intermittent Connection
- **Range issues** - keep devices within 3 meters
- **Battery levels** - check and charge peripheral batteries
- **Firmware updates** - ensure latest firmware on all devices

### Reset Procedures

#### Complete System Reset
1. **Flash settings reset** to all three devices
2. **Power cycle** all devices
3. **Re-flash** appropriate firmware to each device
4. **Re-pair** in correct order (dongle first)

#### Partial Reset (Dongle Only)
1. **Hold reset button** on dongle for 10 seconds
2. **Re-flash dongle firmware** if needed
3. **Power cycle peripherals** to re-establish connection

## 📊 Performance Specifications

| Metric | Specification |
|--------|---------------|
| **Latency** | <10ms typical, <5ms low-latency mode |
| **Range** | Up to 10 meters line-of-sight |
| **Battery Life** | 2-6 months per peripheral |
| **Dongle Power** | USB-powered, <100mA |
| **Profiles** | 5 simultaneous profiles |
| **Reconnect Time** | <3 seconds typical |

## 🎯 Use Cases

### Ideal Scenarios
- **Gaming setups** where Bluetooth latency is unacceptable
- **Corporate environments** with Bluetooth restrictions
- **Older computers** without Bluetooth capability
- **KVM switches** and server management
- **Secure environments** requiring wired connections

### Limitations
- **Requires USB port** for dongle connection
- **Additional hardware** needed (third Nice!Nano)
- **More complex setup** than standard Bluetooth mode
- **Dongle must remain connected** to host device

## 🔄 Switching Between Modes

### From Standard to Dongle Mode
1. **Flash peripheral firmware** to both halves
2. **Set up dongle** with central firmware
3. **Pair devices** in correct order
4. **Test functionality** before regular use

### From Dongle to Standard Mode
1. **Flash standard firmware** to both halves
2. **Reset Bluetooth settings** on host devices
3. **Pair directly** to host device
4. **Dongle becomes unused** (can be repurposed)

---

**Need help?** Check the [Troubleshooting Guide](troubleshooting.md) or contact support at 380465425@qq.com for hardware-specific issues. 
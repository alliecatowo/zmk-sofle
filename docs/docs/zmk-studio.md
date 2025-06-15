# ZMK Studio Integration Guide

ZMK Studio provides real-time keymap editing capabilities for your Eyelash Sofle keyboard. This revolutionary feature allows you to modify your keymap, adjust RGB settings, and configure behaviors without rebuilding or reflashing firmware.

## 🎯 What is ZMK Studio?

ZMK Studio is a visual keymap editor that connects directly to your keyboard, allowing:
- **Real-time keymap editing** without firmware rebuilds
- **Live preview** of changes as you make them
- **Visual layer management** with intuitive interface
- **RGB lighting control** with instant feedback
- **Behavior configuration** for complex key functions
- **Cross-platform support** (Windows, macOS, Linux)

## 📦 Installation Options

### Option 1: Web Version (Recommended)
Access ZMK Studio directly in your browser:
- **URL**: [https://zmk.studio/](https://zmk.studio/)
- **No installation required**
- **Always up-to-date**
- **Works on all platforms**

### Option 2: Desktop Application
Download the desktop application for offline use:

#### Windows
- Download: `ZMK.Studio_0.3.1_x64-setup.exe` (from `Instructions_ORIGINAL_CHINESE/zmk studio和 and new firmware/`)
- Run installer and follow setup wizard
- Launch from Start Menu

#### macOS
- Download: `ZMK.Studio_0.3.1_universal.dmg`
- Mount DMG and drag to Applications folder
- Launch from Applications folder

#### Linux
```bash
# Download AppImage from releases
wget https://github.com/zmkfirmware/zmk-studio/releases/download/v0.3.1/ZMK.Studio-0.3.1.AppImage

# Make executable
chmod +x ZMK.Studio-0.3.1.AppImage

# Run
./ZMK.Studio-0.3.1.AppImage
```

## 🔧 Firmware Requirements

### Studio-Compatible Firmware
Your keyboard needs special firmware with Studio support enabled. This repository provides pre-built Studio firmware:

**Location**: `Instructions_ORIGINAL_CHINESE/zmk studio和 and new firmware/sofle-studio-firmware/`

### Key Points
- **Only left half needs Studio firmware** - right half uses standard firmware
- **Studio firmware is USB-only** for the connection interface
- **Real-time changes** are synchronized to both halves
- **Standard functionality** remains available when Studio is disconnected

## 📋 Setup Instructions

### Step 1: Flash Studio Firmware

1. **Download Studio Firmware**
   - Navigate to `Instructions_ORIGINAL_CHINESE/zmk studio和 and new firmware/sofle-studio-firmware/`
   - Find the latest `.uf2` file for left half

2. **Flash Left Half Only**
   - Put left half in bootloader mode (double-tap reset)
   - Copy `.uf2` file to the USB drive that appears
   - Wait for restart - left half is now Studio-ready

3. **Keep Standard Firmware on Right Half**
   - Right half continues to use standard firmware
   - No changes needed to right half

### Step 2: Connect to ZMK Studio

1. **Connect USB Cable**
   - Connect left half to computer via USB-C
   - Ensure both halves are powered on

2. **Open ZMK Studio**
   - Launch web version or desktop application
   - Click "Connect Device" button

3. **Device Detection**
   - ZMK Studio should automatically detect your keyboard
   - Look for "Eyelash Sofle" in device list
   - Click "Connect" to establish connection

### Step 3: Verify Connection

1. **Interface Loads**
   - Keyboard layout should appear in Studio
   - Current keymap configuration displayed
   - All layers visible in sidebar

2. **Test Live Changes**
   - Click on any key to modify
   - Changes apply immediately
   - Test modified keys to confirm functionality

## 🎨 Using ZMK Studio

### Main Interface Overview

```
┌─────────────────────────────────────────────────┐
│ File  Edit  View  Tools                    Help │
├─────────────────────────────────────────────────┤
│ [Layers]           │ [Main Editor]              │
│ ┌─── Layer 0      │                            │
│ │    Layer 1      │    ┌─┬─┬─┬─┬─┬─┐          │
│ │    Layer 2      │    │Q│W│E│R│T│Y│          │
│ │    Layer 3      │    ├─┼─┼─┼─┼─┼─┤          │
│ └─── Add Layer    │    │A│S│D│F│G│H│          │
│                   │    └─┴─┴─┴─┴─┴─┘          │
│ [Properties]      │                            │
│ ┌─ Key Properties │ [Keycodes]                 │
│ │  Keycode: Q     │ ┌─────────────────────────┐│
│ │  Behavior: kp   │ │ Letters Numbers Symbols ││
│ │  Layer: 0       │ │ Functions Media Bluetooth│
│ └─ Apply          │ └─────────────────────────┘│
└─────────────────────────────────────────────────┘
```

### Basic Key Modification

1. **Select Key**
   - Click on any key in the visual layout
   - Key properties appear in sidebar

2. **Change Keycode**
   - Browse keycode categories
   - Click desired keycode to assign
   - Change applies immediately

3. **Test Change**
   - Type on physical keyboard
   - Modified key should produce new output
   - No restart or reflash required

### Layer Management

#### Creating New Layers
1. **Add Layer**
   - Click "Add Layer" in layers panel
   - New layer created with transparent keys
   - Set layer name and description

2. **Configure Layer Access**
   - Add layer access keys (MO, LT, TG, etc.)
   - Set up layer switching behavior
   - Test layer transitions

#### Layer Types
- **Base Layer (0)**: Default active layer
- **Momentary Layers**: Active while key held
- **Toggle Layers**: Switch on/off with key press
- **Tap-Dance Layers**: Multi-tap activation

### Advanced Behaviors

#### Mod-Tap Configuration
Create keys that act as modifiers when held, regular keys when tapped:

1. **Select Target Key**
2. **Choose Behavior**: `mt` (mod-tap)
3. **Configure Properties**:
   - **Hold**: Modifier (Ctrl, Alt, Shift, etc.)
   - **Tap**: Regular keycode
   - **Timing**: Tap threshold (default 200ms)

#### Layer-Tap Setup
Keys that access layers when held, produce keycodes when tapped:

1. **Behavior**: `lt` (layer-tap)
2. **Properties**:
   - **Hold**: Target layer number
   - **Tap**: Keycode to produce
   - **Timing**: Tap threshold

#### Tap-Dance Sequences
Multi-tap behaviors for single keys:

1. **Behavior**: `td` (tap-dance)
2. **Sequence Configuration**:
   - **Single tap**: First action
   - **Double tap**: Second action
   - **Triple tap**: Third action (optional)
   - **Hold**: Hold action (optional)

### RGB Configuration

#### Basic RGB Controls
1. **Access RGB Panel**
   - Click "RGB" tab in Studio
   - Live preview of current settings

2. **Color Selection**
   - HSV color picker
   - Live preview on keyboard
   - Save favorite colors

3. **Effect Selection**
   - Choose from available effects
   - Adjust speed and intensity
   - Preview effects in real-time

#### Advanced RGB Settings
```
RGB Configuration Panel:
┌─────────────────────────┐
│ On/Off: [●]            │
│ Effect: [Solid ▼]      │
│ Hue: [━━━●━━━━━━] 160°  │
│ Saturation: [━●━━━━] 80% │
│ Brightness: [━━━●━━] 60% │
│ Speed: [━━●━━━━━] 30%    │
│                        │
│ Auto-off on idle: [●]  │
│ Auto-off on USB: [●]   │
│ Start on boot: [ ]     │
└─────────────────────────┘
```

## 🔧 Advanced Configuration

### Encoder Configuration

#### Basic Encoder Setup
1. **Encoder Properties**
   - **Clockwise**: Volume up, scroll up, etc.
   - **Counter-clockwise**: Volume down, scroll down
   - **Press**: Mute, play/pause, etc.

2. **Layer-Specific Behavior**
   - Different encoder functions per layer
   - Context-sensitive controls
   - Gaming vs productivity modes

#### Custom Encoder Behaviors
```c
// Example: Layer-dependent encoder
encoder_behavior: encoder_behavior {
    compatible = "zmk,behavior-sensor-rotate-var";
    #sensor-binding-cells = <2>;
    bindings = <&inc_dec_kp C_VOL_UP C_VOL_DN>,
               <&scroll_encoder>,
               <&inc_dec_kp PG_UP PG_DN>;
};
```

### Pointing Device Integration

#### Mouse Configuration
1. **Enable Mouse Support**
   - Toggle pointing device in Studio
   - Configure mouse sensitivity
   - Set scroll behavior

2. **Custom Mouse Layers**
   - Dedicated mouse layer
   - Mouse movement keys
   - Click and scroll functions

### Bluetooth Profile Management

#### Profile Configuration
1. **Profile Slots**
   - 5 available Bluetooth profiles
   - Name and manage each profile
   - Quick switching between devices

2. **Connection Behavior**
   - Auto-connect preferences
   - Connection timeout settings
   - Profile memory management

## 📊 Keycode Reference

### Essential Keycodes for Studio

#### Basic Input
| Category | Examples | Studio Code |
|----------|----------|-------------|
| **Letters** | A-Z | `KC_A` - `KC_Z` |
| **Numbers** | 0-9 | `KC_0` - `KC_9` |
| **Modifiers** | Ctrl, Alt, Shift | `KC_LCTRL`, `KC_LALT`, `KC_LSFT` |
| **Function** | F1-F12 | `KC_F1` - `KC_F12` |

#### Layer Controls
| Function | Code | Description |
|----------|------|-------------|
| **Momentary** | `MO(n)` | Hold for layer n |
| **Layer Tap** | `LT(n,kc)` | Tap for kc, hold for layer n |
| **Toggle** | `TG(n)` | Toggle layer n on/off |
| **One Shot** | `OSL(n)` | Activate layer n for next key |

#### RGB Controls
| Function | Code | Description |
|----------|------|-------------|
| **Toggle** | `RGB_TOG` | RGB on/off |
| **Effect** | `RGB_EFF` | Next effect |
| **Hue** | `RGB_HUI/HUD` | Hue increase/decrease |
| **Saturation** | `RGB_SAI/SAD` | Saturation increase/decrease |
| **Brightness** | `RGB_BRI/BRD` | Brightness increase/decrease |

#### Bluetooth Controls
| Function | Code | Description |
|----------|------|-------------|
| **Select Profile** | `BT_SEL 0-4` | Select BT profile 0-4 |
| **Clear Profile** | `BT_CLR` | Clear current profile |
| **Clear All** | `BT_CLR_ALL` | Clear all profiles |
| **Next Profile** | `BT_NXT` | Switch to next profile |

## 🔄 Backup and Restore

### Exporting Configuration

1. **Export Current Layout**
   - File → Export Configuration
   - Choose format (JSON recommended)
   - Save configuration file

2. **Include All Settings**
   - Keymap configuration
   - RGB settings
   - Encoder behaviors
   - Layer definitions

### Importing Configuration

1. **Import Saved Layout**
   - File → Import Configuration
   - Select configuration file
   - Review changes before applying

2. **Sharing Configurations**
   - Export configurations to share
   - Import community layouts
   - Version control for keymaps

## 🆘 Troubleshooting

### Connection Issues

#### Studio Not Detecting Keyboard
1. **Check USB Connection**
   - Try different USB ports
   - Use high-quality USB-C cable
   - Ensure stable connection

2. **Verify Studio Firmware**
   - Confirm Studio firmware flashed to left half
   - Check firmware version compatibility
   - Re-flash if necessary

3. **Browser/Application Issues**
   - Clear browser cache (web version)
   - Restart desktop application
   - Check for updates

#### Changes Not Applying
1. **Connection Status**
   - Verify green connection indicator
   - Reconnect if connection lost
   - Check USB cable integrity

2. **Firmware Compatibility**
   - Ensure latest Studio firmware
   - Check for firmware conflicts
   - Verify configuration validity

#### Performance Issues
1. **Latency Problems**
   - Use USB connection for Studio
   - Bluetooth connection for regular use
   - Check for interference

2. **Memory Issues**
   - Too many complex behaviors
   - Simplify configuration
   - Reset to defaults if needed

### Common Error Messages

#### "Device Not Compatible"
- **Cause**: Standard firmware instead of Studio firmware
- **Solution**: Flash Studio firmware to left half

#### "Configuration Too Large"
- **Cause**: Too many layers or complex behaviors
- **Solution**: Simplify configuration or use fewer layers

#### "Connection Lost"
- **Cause**: USB connection interrupted
- **Solution**: Reconnect USB cable and refresh Studio

## 📈 Performance Tips

### Optimizing Studio Experience

1. **Connection Stability**
   - Use high-quality USB-C cable
   - Avoid USB hubs when possible
   - Keep cable length reasonable

2. **Battery Management**
   - USB connection charges left half
   - Monitor right half battery level
   - Consider power-saving settings

3. **Configuration Efficiency**
   - Start with simple layouts
   - Add complexity gradually
   - Test each change thoroughly

### Best Practices

1. **Regular Backups**
   - Export configurations regularly
   - Version control for complex layouts
   - Keep backup configurations handy

2. **Incremental Changes**
   - Make one change at a time
   - Test thoroughly before proceeding
   - Document custom configurations

3. **Community Resources**
   - Share successful configurations
   - Learn from community layouts
   - Contribute improvements back

## 🔄 Firmware Updates

### Updating Studio Firmware

1. **Check for Updates**
   - Monitor repository for new releases
   - Download latest Studio firmware
   - Read changelog for improvements

2. **Update Process**
   - Flash new Studio firmware to left half
   - Keep right half firmware unchanged
   - Test Studio connection after update

3. **Compatibility**
   - Ensure Studio application compatibility
   - Update Studio app if needed
   - Verify all features work correctly

---

**Need help with Studio?** Check the [Studio Documentation](https://zmk.studio/docs) or join the [ZMK Discord](https://discord.gg/8cfMkQksSB) for community support. 
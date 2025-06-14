# Quick Start Guide

Get your ZMK Eyelash Sofle keyboard up and running in minutes! This guide covers the essential steps to start using your keyboard.

## 📦 What You Need

### Required Items
- Eyelash Sofle keyboard (left and right halves)
- 2x Nice!Nano controllers (or compatible)
- 2x Nice!View displays (optional but recommended)
- USB-C cable
- 2x batteries (recommended: 3.7V Li-Po, 301230 or similar)

### Optional Items
- Wireless dongle setup (see [Dongle Mode Guide](dongle-mode.md))
- ZMK Studio application for real-time keymap editing

## 🔋 First Time Setup

### Step 1: Power On
1. **Insert batteries** into both keyboard halves
2. **Connect USB-C cable** to the left half (master side)
3. **Power on** both halves using the power switches

### Step 2: Initial Pairing
1. **Put left half in pairing mode**: Press `Reset` button or use the reset key combination
2. **Open Bluetooth settings** on your computer/device
3. **Look for "Eyelash Sofle"** in available devices
4. **Connect** to establish the initial pairing

### Step 3: Verify Connection
1. **Test basic keys**: Try typing letters, numbers, and modifiers
2. **Test encoder**: Rotate the encoder to adjust volume
3. **Check both halves**: Ensure keys on both sides register properly

## ⌨️ Default Layout

The keyboard comes with a standard QWERTY layout across 3 main layers:

### Layer 0 (Base)
```
ESC   1   2   3   4   5   ↑     6   7   8   9   0   BKSP
TAB   Q   W   E   R   T   ↓     Y   U   I   O   P   \   
CAPS  A   S   D   F   G   ←     H   J   K   L   ;   '   
SHIFT Z   X   C   V   B   →     N   M   ,   .   /   ENTER
MUTE CTRL GUI ALT L1  SPACE    ENTER SPACE ENTER L2  SHIFT DEL
```

### Layer 1 (Function/Mouse)
- **F1-F12** function keys
- **Mouse controls** (click, move, scroll)
- **RGB controls** (on/off, effects, brightness)
- **Navigation** (arrows, home, end, page up/down)

### Layer 2 (System/Bluetooth)
- **Bluetooth controls** (connect, clear, select profiles)
- **System controls** (reset, bootloader, sleep)
- **Output selection** (USB/Bluetooth toggle)

## 🎛️ Essential Functions

### Volume Control (Encoder)
- **Rotate clockwise**: Volume up
- **Rotate counter-clockwise**: Volume down  
- **Press encoder**: Mute toggle

### Layer Switching
- **Hold MO(1)**: Access Function/Mouse layer
- **Hold MO(2)**: Access System/Bluetooth layer

### Bluetooth Profiles
- **BT 0-4**: Connect to 5 different devices
- **BT CLR**: Clear current profile
- **BT CLR ALL**: Clear all profiles

## 🔧 Quick Customization

### Change RGB Effects
1. Hold **Layer 1** key
2. Use **RGB_ON/OFF** to toggle underglow
3. Use **RGB_EFF** to cycle through effects
4. Use **RGB_BRI/BRD** to adjust brightness

### Mouse Mode
1. Hold **Layer 1** key
2. Use **mouse click keys** for left/right/middle click
3. Use **directional keys** for cursor movement
4. **Encoder becomes scroll wheel** in this layer

## 🔄 Firmware Updates

### Using Pre-built Firmware
1. Download latest firmware from `Instructions_ORIGINAL_CHINESE/zmk studio和 and new firmware/sofle-studio-firmware/`
2. Put keyboard in bootloader mode (double-tap reset or use reset key combo)
3. Drag `.uf2` file to the USB drive that appears
4. Keyboard will restart automatically

### For ZMK Studio Users
1. Flash the **studio firmware** to the left half only
2. Use ZMK Studio application for real-time keymap editing
3. Changes are applied instantly without reflashing

## 🆘 Quick Troubleshooting

### Keyboard Not Connecting
- Ensure both halves are powered on
- Clear Bluetooth profiles: Hold Layer 2 + BT CLR ALL
- Reset both halves and re-pair

### Keys Not Working
- Check battery levels
- Verify firmware is properly flashed
- Test USB connection mode

### Display Issues
- Ensure Nice!View displays are properly seated
- Check firmware includes display support
- Verify power connections

## 🎯 Next Steps

Now that your keyboard is working:

1. **Customize your layout**: Check out [ZMK Studio Guide](zmk-studio.md)
2. **Explore RGB effects**: See [RGB Configuration](rgb-configuration.md)
3. **Set up dongle mode**: Review [Dongle Mode Guide](dongle-mode.md)
4. **Build custom firmware**: Follow [Building Firmware](building-firmware.md)

## 📝 Quick Reference

| Function | Key Combination |
|----------|----------------|
| Layer 1 | Hold left thumb key (MO 1) |
| Layer 2 | Hold right thumb key (MO 2) |
| Bluetooth Clear | Layer 2 + BT CLR |
| Reset | Layer 2 + Reset key |
| Bootloader | Layer 2 + Bootloader key |
| RGB Toggle | Layer 1 + RGB ON/OFF |

---

**Having issues?** Check the [Troubleshooting Guide](troubleshooting.md) or [contact support](mailto:380465425@qq.com). 
# Troubleshooting Guide

This comprehensive troubleshooting guide covers common issues and their solutions for the ZMK AllieCat Sofle keyboard. Before contacting support, please work through these solutions systematically.

## 🔍 Quick Problem Diagnosis

### Immediate Checks
1. **Power Status**: Are both halves powered on? Check power switches and battery levels.
2. **Connections**: Is the USB cable properly connected? Are wireless connections established?
3. **Firmware**: Is the correct firmware flashed to each half?
4. **Physical**: Are all components properly seated? Any visible damage?

### Problem Categories
- [Connection Issues](#-connection-issues)
- [Key Input Problems](#-key-input-problems)
- [Display Issues](#-display-issues)
- [RGB Lighting Problems](#-rgb-lighting-problems)
- [Encoder Problems](#-encoder-problems)
- [Battery Issues](#-battery-issues)
- [Firmware Issues](#-firmware-issues)
- [ZMK Studio Problems](#-zmk-studio-problems)
- [Dongle Mode Issues](#-dongle-mode-issues)

## 📶 Connection Issues

### Bluetooth Not Connecting

#### Symptoms
- Computer doesn't detect keyboard
- Connection drops frequently
- Pairing fails repeatedly

#### Solutions

**Basic Troubleshooting**
1. **Clear Bluetooth Profiles**
   ```
   Layer 2 + BT CLR ALL (hold both keys simultaneously)
   ```

2. **Reset Bluetooth on Host Device**
   - Windows: Remove device from Bluetooth settings
   - macOS: Remove from System Preferences → Bluetooth
   - Linux: Use `bluetoothctl` to remove and re-pair

3. **Power Cycle Everything**
   - Turn off both keyboard halves
   - Disable Bluetooth on host device
   - Wait 30 seconds
   - Re-enable Bluetooth on host
   - Power on keyboard halves

**Advanced Solutions**
1. **Firmware Reset**
   ```
   Flash settings_reset firmware:
   1. Enter bootloader mode on both halves
   2. Flash settings_reset-nice_nano_v2-zmk.uf2
   3. Power cycle
   4. Re-flash standard firmware
   ```

2. **Check Interference**
   - Move away from other wireless devices
   - Avoid USB 3.0 ports (use USB 2.0)
   - Check for 2.4GHz interference sources

### USB Connection Problems

#### Symptoms
- Computer doesn't recognize keyboard via USB
- Intermittent USB connection
- Charging not working

#### Solutions
1. **Cable Testing**
   - Try different USB cables
   - Test with known-good USB-C cable
   - Avoid USB hubs - connect directly

2. **Port Testing**
   - Try different USB ports
   - Prefer USB 2.0 over USB 3.0
   - Test on different computer

3. **Driver Issues**
   ```bash
   # Windows: Check Device Manager for errors
   # Linux: Check dmesg output
   dmesg | grep usb
   ```

### Split Connection Issues

#### Symptoms
- Only one half works
- Keys from one side not registering
- Intermittent connection between halves

#### Solutions
1. **Check Both Halves Powered**
   - Verify both power switches are on
   - Check battery levels on both sides
   - Ensure both have adequate charge

2. **Re-pair Split Connection**
   ```
   1. Turn off both halves
   2. Clear Bluetooth profiles: Layer 2 + BT CLR ALL
   3. Power on left half first
   4. Wait 10 seconds
   5. Power on right half
   6. Wait for automatic pairing
   ```

3. **Range Issues**
   - Keep halves within 3 feet of each other initially
   - Avoid obstacles between halves
   - Check for interference sources

## ⌨️ Key Input Problems

### Keys Not Registering

#### Symptoms
- Certain keys don't work
- Inconsistent key response
- Multiple key presses for single input

#### Solutions

**Physical Checks**
1. **Switch Inspection**
   - Remove keycaps and check switch operation
   - Look for debris or damage
   - Test switch actuation manually

2. **Connection Verification**
   - Check hotswap socket connections
   - Verify switch is fully seated
   - Look for bent pins on switches

**Firmware Solutions**
1. **Adjust Debounce Settings**
   ```c
   // In alliecat_keeb.conf
   CONFIG_ZMK_KSCAN_DEBOUNCE_PRESS_MS=5
   CONFIG_ZMK_KSCAN_DEBOUNCE_RELEASE_MS=5
   ```

2. **Matrix Scan Testing**
   - Use ZMK Studio to test individual keys
   - Check keymap configuration
   - Verify matrix definitions

### Modifier Keys Stuck

#### Symptoms
- Shift/Ctrl/Alt seems permanently pressed
- CAPS LOCK behavior on all keys
- Modifier keys not releasing

#### Solutions
1. **Clear Stuck Modifiers**
   ```
   Press and release all modifier keys individually:
   - Left Shift, Right Shift
   - Left Ctrl, Right Ctrl
   - Left Alt, Right Alt
   - GUI keys
   ```

2. **Reset Keyboard State**
   ```
   Layer 2 + Reset (system reset key combination)
   ```

3. **Check Keymap Configuration**
   - Verify modifier key definitions
   - Check for conflicting behaviors
   - Review layer configurations

### Wrong Characters Output

#### Symptoms
- Keys produce different characters than expected
- Layout seems incorrect
- Special characters not working

#### Solutions
1. **Check Host OS Keyboard Layout**
   - Windows: Language settings
   - macOS: Keyboard preferences
   - Linux: Keyboard layout configuration

2. **Verify Keymap Configuration**
   - Use ZMK Studio to check key assignments
   - Compare with expected layout
   - Check layer activation

3. **Language/Region Settings**
   - Ensure host OS language matches keymap
   - Check for conflicting input methods
   - Disable auto-correction if applicable

## 📺 Display Issues

### Display Not Working

#### Symptoms
- OLED display completely blank
- Display shows garbled content
- Partial display output

#### Solutions

**Hardware Checks**
1. **Connection Verification**
   - Ensure Nice!View properly seated
   - Check for bent pins
   - Verify display orientation

2. **Power Supply**
   - Check battery levels
   - Test with USB power connected
   - Verify display power pin connections

**Firmware Solutions**
1. **Display Configuration**
   ```c
   // Check in board definition
   chosen {
       zephyr,display = &oled;
   };
   ```

2. **Firmware Compatibility**
   - Ensure firmware includes display support
   - Check for correct display driver
   - Verify display is enabled in config

### Display Content Issues

#### Symptoms
- Display shows wrong information
- Layer information incorrect
- Battery levels not updating

#### Solutions
1. **Configuration Check**
   - Verify display widgets configuration
   - Check status update intervals
   - Review display layout settings

2. **Data Refresh**
   - Power cycle to refresh display
   - Check for display timeout settings
   - Verify sensor data sources

## 🌈 RGB Lighting Problems

### RGB Not Working

#### Symptoms
- No RGB lighting at all
- Only some LEDs working
- RGB not responding to controls

#### Solutions

**Hardware Checks**
1. **Power and Connections**
   - Check RGB power settings
   - Verify WS2812 data line connections
   - Test with external power if needed

2. **LED Chain Integrity**
   - Look for damaged LEDs
   - Check solder connections
   - Test LED chain continuity

**Configuration Fixes**
1. **RGB Power Settings**
   ```c
   CONFIG_ZMK_RGB_UNDERGLOW=y
   CONFIG_ZMK_RGB_UNDERGLOW_EXT_POWER=y
   CONFIG_ZMK_RGB_UNDERGLOW_ON_START=y
   ```

2. **LED Count Configuration**
   ```c
   &led_strip {
       chain-length = <36>; // Adjust to actual LED count
   };
   ```

### RGB Effects Issues

#### Symptoms
- Effects not changing
- Stuck on one color/effect
- Brightness not adjusting

#### Solutions
1. **Control Key Testing**
   ```
   Layer 1 + RGB controls:
   - RGB_TOG: Toggle on/off
   - RGB_EFF: Change effects
   - RGB_BRI/BRD: Brightness control
   ```

2. **Reset RGB Settings**
   ```
   Layer 1 + RGB_OFF (turn off)
   Wait 5 seconds
   Layer 1 + RGB_ON (turn back on)
   ```

## 🎛️ Encoder Problems

### Encoder Not Responding

#### Symptoms
- Rotation doesn't change volume
- Encoder press not working
- Inconsistent encoder behavior

#### Solutions

**Hardware Checks**
1. **Physical Inspection**
   - Check encoder mounting
   - Verify shaft alignment
   - Look for debris in encoder

2. **Connection Testing**
   - Check encoder pin connections
   - Verify GPIO assignments
   - Test encoder continuity

**Configuration Solutions**
1. **Encoder Settings**
   ```c
   left_encoder: encoder_left {
       compatible = "alps,ec11";
       resolution = <4>;
       steps = <40>;
       status = "okay"; // Ensure enabled
   };
   ```

2. **Sensor Bindings**
   ```c
   sensor-bindings = <&inc_dec_kp C_VOL_UP C_VOL_DN>;
   ```

### Encoder Direction Issues

#### Symptoms
- Clockwise/counterclockwise reversed
- Encoder jumps multiple steps
- Inconsistent direction response

#### Solutions
1. **Swap Encoder Pins**
   ```c
   // In device tree
   a-gpios = <&gpio1 14 (GPIO_ACTIVE_HIGH | GPIO_PULL_UP)>;
   b-gpios = <&gpio1 10 (GPIO_ACTIVE_HIGH | GPIO_PULL_UP)>;
   ```

2. **Adjust Resolution**
   ```c
   resolution = <2>; // Try different values: 1, 2, 4
   ```

## 🔋 Battery Issues

### Battery Not Charging

#### Symptoms
- Battery level not increasing when connected
- No charging indicator
- Battery drains even when plugged in

#### Solutions
1. **Connection Verification**
   - Check USB cable quality
   - Verify charging port cleanliness
   - Test with different USB ports/chargers

2. **Battery Health**
   - Check battery connections
   - Verify battery isn't over-discharged
   - Test with known-good battery

3. **Charging Circuit**
   - Check for charging LED indicator
   - Verify charging current settings
   - Test charging circuit continuity

### Poor Battery Life

#### Symptoms
- Battery drains quickly
- Inconsistent battery reporting
- Sleep mode not working

#### Solutions
1. **Power Optimization**
   ```c
   // Aggressive power saving
   CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=300000  // 5 minutes
   CONFIG_ZMK_RGB_UNDERGLOW_ON_START=n
   CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_IDLE=y
   CONFIG_BT_CTLR_TX_PWR_0=y
   ```

2. **Feature Management**
   - Disable RGB when not needed
   - Reduce display brightness
   - Use sleep mode effectively

3. **Connection Optimization**
   - Maintain good Bluetooth connection
   - Avoid excessive re-pairing
   - Keep devices within reasonable range

## 💾 Firmware Issues

### Firmware Not Flashing

#### Symptoms
- Bootloader mode not working
- .uf2 file not copying
- Firmware update fails

#### Solutions
1. **Bootloader Mode**
   ```
   Double-tap reset button quickly
   OR
   Hold reset while plugging in USB
   ```

2. **File System Issues**
   - Check for disk errors on bootloader drive
   - Format bootloader drive if corrupted
   - Try different .uf2 file

3. **Hardware Issues**
   - Test reset button functionality
   - Check USB connection stability
   - Verify bootloader firmware integrity

### Wrong Firmware Flashed

#### Symptoms
- Keyboard behavior completely wrong
- Features not working as expected
- Connection issues after flashing

#### Solutions
1. **Identify Correct Firmware**
   - Left half: Standard or Studio firmware
   - Right half: Standard firmware only
   - Dongle mode: Peripheral firmware for halves

2. **Re-flash Correct Firmware**
   ```
   1. Enter bootloader mode
   2. Delete any existing files on bootloader drive
   3. Copy correct .uf2 file
   4. Wait for automatic restart
   ```

## 🖥️ ZMK Studio Problems

### Studio Not Connecting

#### Symptoms
- Studio can't find keyboard
- Connection established but drops
- Studio interface doesn't load

#### Solutions
1. **Firmware Verification**
   - Ensure Studio firmware on left half
   - Verify USB connection mode
   - Check firmware version compatibility

2. **Connection Method**
   - Use web version: https://zmk.studio/
   - Try different USB ports
   - Clear browser cache (web version)

3. **Application Issues**
   - Restart Studio application
   - Update to latest version
   - Check for browser compatibility

### Changes Not Applying

#### Symptoms
- Studio shows changes but keyboard doesn't respond
- Settings revert after disconnect
- Inconsistent behavior

#### Solutions
1. **Connection Stability**
   - Use high-quality USB cable
   - Avoid USB hubs
   - Keep connection stable during changes

2. **Configuration Validation**
   - Check for configuration conflicts
   - Verify keymap complexity limits
   - Test changes incrementally

## 🎮 Dongle Mode Issues

### Dongle Not Recognized

#### Symptoms
- Computer doesn't see dongle as keyboard
- Dongle display blank
- No response from peripherals

#### Solutions
1. **Firmware Verification**
   - Flash central dongle firmware
   - Verify peripheral firmware on halves
   - Check firmware compatibility

2. **Connection Sequence**
   ```
   1. Power on dongle first
   2. Connect dongle to computer
   3. Power on keyboard halves
   4. Wait for automatic pairing
   ```

### Peripheral Connection Issues

#### Symptoms
- Only one half connects to dongle
- Intermittent peripheral connections
- High latency in dongle mode

#### Solutions
1. **Pairing Process**
   - Reset all three devices
   - Clear Bluetooth profiles
   - Re-pair in correct sequence

2. **Range and Interference**
   - Keep devices close during pairing
   - Check for interference sources
   - Optimize placement of components

## 🆘 Emergency Procedures

### Complete System Reset

When all else fails, perform a complete reset:

1. **Settings Reset**
   ```
   1. Flash settings_reset firmware to all devices
   2. Power cycle all devices
   3. Wait 1 minute
   4. Re-flash appropriate firmware to each device
   ```

2. **Factory Configuration**
   ```
   1. Use default keymap files from repository
   2. Flash standard firmware (not custom builds)
   3. Test basic functionality first
   4. Add customizations incrementally
   ```

### Recovery Mode

If keyboard becomes completely unresponsive:

1. **Hardware Reset**
   - Disconnect all power sources
   - Hold reset button for 10 seconds
   - Reconnect power and try bootloader mode

2. **Firmware Recovery**
   - Flash known-good firmware
   - Test with minimal configuration
   - Build up features gradually

## 📞 Getting Help

### Before Contacting Support

1. **Gather Information**
   - Firmware versions
   - Host operating system
   - Specific error messages
   - Steps to reproduce issue

2. **Try Systematic Approach**
   - Work through troubleshooting steps
   - Document what works/doesn't work
   - Note any patterns in behavior

### Support Channels

- **Hardware Issues**: Contact 380465425@qq.com
- **Firmware/Software**: Check [ZMK Documentation](https://zmk.dev/)
- **Community Help**: Join [ZMK Discord](https://discord.gg/8cfMkQksSB)
- **Repository Issues**: Create GitHub issue with details

### What to Include in Support Requests

1. **Problem Description**
   - Clear description of issue
   - When problem started
   - What changed recently

2. **System Information**
   - Operating system and version
   - Firmware versions
   - Hardware configuration

3. **Troubleshooting Attempted**
   - Steps already tried
   - Results of troubleshooting
   - Any error messages

---

**Remember**: Most issues can be resolved with systematic troubleshooting. Take your time, work through the steps methodically, and don't hesitate to ask for help when needed.

# Dongle Mode Guide

The Eyelash Sofle supports **dongle/dock mode**: a 3-piece wireless split setup where a dedicated nice!nano dongle acts as the USB receiver, and both keyboard halves connect to it via BLE.

---

## What is Dongle Mode?

```
[Left Half]  ──BLE──┐
                    ├──▶  [Dongle nice!nano] ──USB──▶ [Computer]
[Right Half] ──BLE──┘
```

- **Dongle** — USB-powered nice!nano. Acts as BLE central. Appears to the computer as a standard USB HID keyboard.
- **Left half** — battery-powered, acts as BLE peripheral
- **Right half** — battery-powered, acts as BLE peripheral

**Why dongle mode?**
- Works on computers without Bluetooth (or where BT is locked down)
- Slightly lower end-to-end latency than direct BLE to host
- Dongle handles all BLE complexity; host sees a standard wired keyboard
- RGB runs off USB power — no battery drain concern on the dongle

---

## Firmware Files

Each piece needs its own firmware build:

| Piece | Build artifact | Board target |
|-------|----------------|-------------|
| Dongle | `eyelash_sofle_dongle-nice_view-zmk.uf2` | `eyelash_sofle_dongle` |
| Left half | `eyelash_sofle_left_peripheral-nice_view_custom-zmk.uf2` | `eyelash_sofle_left` |
| Right half | `eyelash_sofle_right_peripheral-nice_view_custom-zmk.uf2` | `eyelash_sofle_right` |
| Settings reset | `settings_reset-eyelash_sofle_left-zmk.uf2` | (any board) |

Firmware is built via GitHub Actions. Download from the **Actions** tab → latest workflow run → **Artifacts**.

---

## Flashing Procedure

### First-time setup (or after bond issues)

1. **Flash settings reset to ALL THREE devices first** — this wipes BLE bonds and prevents pairing conflicts
2. Then flash the correct firmware to each device (order doesn't matter after reset)
3. Power on all three, plug dongle into USB → they will auto-pair

### Regular firmware update

You only need to reflash the device(s) whose firmware changed. Bonds persist across firmware updates unless you explicitly flash settings_reset.

### How to enter bootloader (nice!nano)

Double-tap the reset button. The device mounts as a USB drive (`NICENANO`). Drag the `.uf2` file onto it.

If the reset button is hard to reach:
- **ZMK Studio** can trigger a bootloader reset
- Use the `&bootloader` key if bound on your keymap (SYS layer)

### Dongle

```
1. Double-tap reset on dongle
2. Drag eyelash_sofle_dongle-*.uf2 onto NICENANO drive
3. Dongle reboots, starts advertising as USB HID device
```

### Left half

```
1. Double-tap reset on left half
2. Drag eyelash_sofle_left_peripheral-*.uf2 onto NICENANO drive
3. Half reboots, starts scanning for dongle
```

### Right half

```
1. Double-tap reset on right half
2. Drag eyelash_sofle_right_peripheral-*.uf2 onto NICENANO drive
3. Half reboots, starts scanning for dongle
```

---

## Pairing After Reflashing

If you flashed settings_reset (or have new firmware that changes the split address):

1. Flash settings_reset to **all three** devices
2. Flash production firmware to all three
3. Plug dongle into USB
4. Power on both halves
5. Wait 10–30 seconds — the halves advertise, dongle scans and bonds automatically
6. Test keys from both halves

You do **not** need to do anything on the host computer — pairing is dongle ↔ halves only. The host just sees a USB keyboard.

---

## Config Differences: Dongle vs Halves

| Setting | Dongle | Left/Right halves |
|---------|--------|-------------------|
| `CONFIG_ZMK_SPLIT_ROLE_CENTRAL` | `y` | `n` (implicit) |
| `CONFIG_ZMK_SLEEP` | **`n`** (USB-powered) | `y` (battery) |
| `CONFIG_ZMK_IDLE_SLEEP_TIMEOUT` | N/A | 300,000ms (5 min) |
| `CONFIG_BT_CTLR_TX_PWR_*` | `PLUS_8` (max range) | `MINUS_20` (desk range) |
| `CONFIG_BT_PERIPHERAL_PREF_MIN_INT` | `6` (7.5ms) | `6` (7.5ms) |
| `CONFIG_BT_SUPERVISION_TIMEOUT` | `400` (4s) | default |
| `CONFIG_BT_MAX_CONN` | `7` (2 peripherals + 5 profiles) | default |
| `CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_USB` | **`n`** (always USB) | `y` (off on battery) |
| `CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_IDLE` | **`n`** (USB-powered) | `y` (save battery) |
| `CONFIG_ZMK_BACKLIGHT_AUTO_OFF_IDLE` | `n` | `y` (save battery) |

---

## Reconnection Troubleshooting

### A half dropped and won't reconnect

1. **Wait 10 seconds** — BLE supervision timeout is 4 seconds on the dongle; the half will re-advertise and reconnect automatically
2. If still not reconnecting: **power cycle the half** (flip the power switch off/on)
3. Still nothing: power cycle the dongle too (unplug/replug USB)
4. If bonds are corrupted: flash settings_reset to the affected half and the dongle, then reflash production firmware to both

### Both halves won't connect after dongle reboot

- This is normal on first plug-in: both halves need to wake from sleep
- Press any key on each half to wake them — they will reconnect within 5–10 seconds
- Halves sleep after 5 minutes idle (power switch should still show green LED if powered)

### Dongle not appearing as USB keyboard on host

1. Verify correct firmware flashed to dongle (not peripheral firmware)
2. Try a different USB port or cable
3. Check dongle display — it should show connection status for L and R halves
4. If display shows no connection, both halves may still be asleep

### ZMK Studio not connecting

ZMK Studio connects to the **dongle** via USB (not the halves). Make sure:
- Dongle is plugged in
- Browser supports WebSerial (Chrome/Edge, not Firefox)
- Navigate to [zmk.studio](https://zmk.studio) and select the dongle's serial port

### Latency feels high

The dongle firmware is configured for 7.5ms BLE connection intervals (min_int=6). If latency is still high:
- Check for 2.4GHz interference (WiFi router, other BLE devices)
- Ensure dongle is not behind a metal panel that blocks signal
- The nice!nano's BLE is 2.4GHz — USB 3 ports emit 2.4GHz interference, so use a USB 2 port or a short extension cable

---

## Battery Tips for the Halves

The halves sleep after **5 minutes idle** (configurable via `CONFIG_ZMK_IDLE_SLEEP_TIMEOUT`).

**To maximize battery life:**
- Keep the power switch **on** between uses — sleeping nice!nano draws ~3μA, far less than what the power switch wastes when off/on cycling damages the MCU state
- RGB underglow on the halves **automatically turns off** when not USB-powered (during normal wireless use) — this is the single biggest battery savings
- Backlight also auto-off when idle
- TX power is set to -20 dBm (vs default 0 dBm or +8 on dongle) — works fine at desk range, saves notable battery

**Expected battery life** with these settings:
- Light use (8hr/day typing): 3–6 months on a 110mAh battery
- Heavy use or RGB enabled: 2–4 weeks

**To enable RGB on the halves:**  
Edit `eyelash_sofle_peripheral_left.conf` / `right.conf`: set `CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_USB=n`. Note this will significantly reduce battery life.

---

## Quick Reference: Build Matrix

The `build-dongle.yaml` file defines the three firmware targets:

```yaml
# Dongle
- board: eyelash_sofle_dongle
  shield: nice_view
  snippet: studio-rpc-usb-uart

# Left half (peripheral)
- board: eyelash_sofle_left
  shield: nice_view_custom
  snippet: studio-rpc-usb-uart

# Right half (peripheral)
- board: eyelash_sofle_right
  shield: nice_view_custom
  snippet: studio-rpc-usb-uart
```

See `build-dongle.yaml` at the repo root for the full cmake-args and artifact names.

---

## Switching Back to Standard Mode (Direct BLE)

Standard mode = each half pairs directly to your computer (no dongle needed).

To switch:
1. Use the standard `build.yaml` instead of `build-dongle.yaml`
2. Flash left-standard and right-standard firmware to the halves
3. Pair each half directly to your computer via BLE profiles

The dongle can be repurposed as another half or left unused.

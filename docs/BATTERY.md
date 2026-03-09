# Battery Life Guide

## Quick wins
- Disable RGB when on battery: automatic with this config
- RGB brightness set to 30% default (was 100%)

## Expected battery life estimates (nice!nano v2)
| Mode | Est. Life |
|------|-----------|
| RGB off, BLE | ~3-6 months |
| RGB on (30% brightness) | ~2-4 weeks |
| RGB on (100% brightness) | ~3-7 days |

## Config tuning
- `CONFIG_ZMK_IDLE_TIMEOUT` — ms before idle (lower = more battery)
- `CONFIG_ZMK_IDLE_SLEEP_TIMEOUT` — ms in idle before deep sleep
- `CONFIG_ZMK_RGB_UNDERGLOW_BRT_MAX` — hard cap on brightness (0-100)

## Dongle mode
Dongle is USB-powered, RGB always available. Peripherals still sleep.

## Checking battery level
With `CONFIG_ZMK_BATTERY_REPORTING=y` (already enabled), battery % is visible
in ZMK Studio and via BLE battery service on your OS.

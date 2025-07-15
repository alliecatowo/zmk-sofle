# Quick Start Guide

This guide covers the essential steps to get your Allie Cat Sofle up and running with pre-built firmware.

## Prerequisites

-   Allie Cat Sofle keyboard (left and right halves)
-   Allie Cat Sofle dongle
-   USB-C cables

## Downloading Firmware

You can find the latest pre-built firmware files in the "Artifacts" section of the most recent [build workflow run](https://github.com/alliecatowo/zmk-sofle/actions/workflows/build.yml). You will need to download the `all-builds` artifact, which is a ZIP file containing all the necessary `.uf2` files.

## Flashing Guide

For the most reliable setup, it's best to first flash the `settings_reset` firmware to clear any old pairing data, and then flash the main firmware in a specific order.

### Step 1: Reset All Devices (Recommended)

1.  Put your **Dongle** into bootloader mode by double-tapping its reset button. It will appear as a USB drive.
2.  Copy the `settings_reset_dongle.uf2` file to the drive.
3.  Repeat for the **Left Half** with `settings_reset_left.uf2`.
4.  Repeat for the **Right Half** with `settings_reset_right.uf2`.

### Step 2: Flash Main Firmware (Order is Important)

1.  **Flash Dongle First**: Put the dongle in bootloader mode and copy `alliecat_sofle_dongle.uf2` to it. The dongle needs to be active to accept connections from the keyboard halves.
2.  **Flash Left Half**: Put the left half in bootloader mode and copy `alliecat_sofle_left_peripheral.uf2`.
3.  **Flash Right Half**: Put the right half in bootloader mode and copy `alliecat_sofle_right_peripheral.uf2`.

After the final flash, the two halves should automatically find and connect to the dongle. Congratulations, your Allie Cat Sofle is ready to use!

# Introduction

This repository contains the ZMK firmware configuration for my custom Sofle keyboard, which I've affectionately named the "AllieCatKeeb".

This setup is designed for a split keyboard with a central dongle acting as the receiver.

## Features

*   **Split Keyboard Layout**: Ergonomic design based on the Sofle keyboard.
*   **ZMK Firmware**: Fully wireless and customizable via ZMK.
*   **OLED Display**: Each half features a nice!view display for status information.

*   **Custom Dongle Display**: The receiver dongle uses a custom display module for advanced status monitoring.

## Keyboard Displays

Each half uses the [zmk-nice-oled](https://github.com/mctechnology17/zmk-nice-oled) screen library. The left half uses the `nice_view` layout while the right half uses `nice_view_custom` so both screens face the user and display layer and Bluetooth status.

## Dongle Display

The dongle firmware uses the excellent [zmk-dongle-display module](https://github.com/englmaxi/zmk-dongle-display) by `englmaxi`. This provides a rich status screen with widgets for:

*   Active HID indicators (Caps/Num/Scroll Lock)
*   Active key modifiers
*   Bongo Cat (because why not?)
*   Highest active layer name
*   Output status (USB/Bluetooth)
*   Peripheral battery levels

## Resources

*   **ZMK Documentation**: For firmware customization and feature information, refer to the [official ZMK documentation](https://zmk.dev/docs).
*   **Sofle Keyboard**: Learn more about the original keyboard design [here](https://josefadamcik.github.io/SofleKeyboard/).

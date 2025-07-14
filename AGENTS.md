# Repository Guidelines for Codex Agents

This repository contains ZMK firmware and configuration files for the Eyelash Sofle keyboard.

## Getting Started
1. **Setup the build environment**
   ```bash
   ./scripts/setup-local-build.sh
   ```
   This initializes the West workspace and installs local Python requirements.

2. **Build firmware locally** (optional)
   ```bash
   # Examples
   ./scripts/quick-build.sh left-c   # build left half (central)
   ./scripts/quick-build.sh right-p  # build right half
   ./scripts/quick-build.sh dongle   # build dongle firmware
   ./scripts/quick-build.sh reset    # build universal reset
   ```
   The resulting `.uf2` files will appear in `firmware/`.

3. **Update keymap diagram**
   ```bash
   keymap parse -z config/eyelash_sofle.keymap > keymap.yaml
   keymap draw keymap.yaml --config-file keymap_drawer.config.yaml -o keymap-drawer/sofle.svg
   ```
   This mirrors what the `draw.yml` workflow does automatically.

## Notes
- There is no automated test suite beyond building the firmware.
- Hardware manufacturing steps are unnecessary; the board is a pre-built kit.

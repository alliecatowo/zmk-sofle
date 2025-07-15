# Building Custom Firmware

This comprehensive guide will walk you through building custom firmware for your AllieCat Sofle keyboard. Whether you want to modify the keymap, add new features, or optimize performance, this guide has you covered.

## 🛠️ Prerequisites

### Required Software
- **Git** - Version control system
- **Python 3.7+** - For build tools
- **West** - Zephyr workspace tool
- **CMake** - Build system
- **Device Tree Compiler (dtc)** - For hardware definitions
- **Ninja** - Build tool (recommended)

### Development Environment Options

#### Option 1: Local Development (Recommended)
Set up ZMK development environment on your local machine.

#### Option 2: Docker Container
Use pre-configured Docker environment for consistent builds.

#### Option 3: GitHub Actions
Use GitHub Actions for cloud-based building (slower but no local setup required).

## 🐧 Local Development Setup

### Linux/macOS Setup

1. **Install System Dependencies**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install -y git cmake ninja-build python3-pip python3-venv

   # macOS with Homebrew
   brew install cmake ninja python3 git dtc
   ```

2. **Install Python Dependencies**
   ```bash
   python3 -m pip install --user -U west
   ```

3. **Initialize Workspace**
   ```bash
   # Create workspace directory
   mkdir zmk-workspace
   cd zmk-workspace

   # Initialize west workspace
   west init -l config

   # Update workspace
   west update
   ```

### Windows Setup

1. **Install Prerequisites**
   - Download and install [Git for Windows](https://git-scm.com/download/win)
   - Download and install [Python 3.7+](https://www.python.org/downloads/)
   - Download and install [CMake](https://cmake.org/download/)

2. **Install West**
   ```powershell
   pip3 install west
   ```

3. **Set up Workspace**
   ```powershell
   # Create workspace
   mkdir zmk-workspace
   cd zmk-workspace

   # Initialize
   west init -l config
   west update
   ```

## 🔧 Setting Up This Repository

### Clone the Repository
```bash
# Clone this repository
git clone https://github.com/your-username/zmk-sofle.git zmk-sofle
cd zmk-sofle

# Initialize ZMK workspace
west init -l config
west update

# Or run the helper script which performs these steps
./scripts/setup-local-build.sh
```

### Install Zephyr SDK
```bash
# Download and install Zephyr SDK
cd ~
wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.1/zephyr-sdk-0.16.1_linux-x86_64.tar.gz
tar xvf zephyr-sdk-0.16.1_linux-x86_64.tar.gz

# Install SDK
cd zephyr-sdk-0.16.1
./setup.sh
```

## 🏗️ Building Firmware

### Understanding Build Targets

The `build.yaml` file defines the build targets:

```yaml
# Standard wireless mode
- board: alliecat_keeb_right
  shield: nice_oled
- board: alliecat_keeb_left
  shield: nice_oled

# ZMK Studio mode (left half only)
- board: alliecat_keeb_left
  shield: nice_view
  snippet: studio-rpc-usb-uart
  cmake-args: -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n
  artifact-name: alliecat_keeb_studio_left

# Settings reset
- board: alliecat_keeb_left
  shield: settings_reset
```

### Building All Targets
```bash
# Build all targets defined in build.yaml
west build --board alliecat_keeb_left -- -DZMK_CONFIG="$(pwd)/config"
```

### Building Specific Targets

#### Standard Wireless Mode
```bash
# Build left half
west build --board alliecat_keeb_left --shield nice_oled -- -DZMK_CONFIG="$(pwd)/config"

# Build right half
west build --board alliecat_keeb_right --shield nice_oled -- -DZMK_CONFIG="$(pwd)/config"
```

#### ZMK Studio Mode
```bash
# Build left half with Studio support
west build --board alliecat_keeb_left --shield nice_view -- \
  -DZMK_CONFIG="$(pwd)/config" \
  -DCONFIG_ZMK_STUDIO=y \
  -DCONFIG_ZMK_STUDIO_LOCKING=n \
  -DSNIPPET=studio-rpc-usb-uart
```

#### Settings Reset
```bash
# Build settings reset firmware
west build --board alliecat_keeb_left --shield settings_reset -- -DZMK_CONFIG="$(pwd)/config"
```

### Build Output

Firmware files are generated in `build/zephyr/`:
- `zmk.uf2` - Main firmware file for flashing
- `zmk.hex` - Hex format (for advanced users)
- `zmk.bin` - Binary format (for advanced users)

## 📝 Customizing Configuration

### Keymap Customization

Edit `config/alliecat_keeb.keymap`:

```c
// Example: Adding a new key behavior
/ {
    behaviors {
        // Custom behavior for Ctrl+Alt+Delete
        cad: ctrl_alt_del {
            compatible = "zmk,behavior-mod-morph";
            #binding-cells = <0>;
            bindings = <&kp DELETE>, <&kp LC(LA(DELETE))>;
            mods = <(MOD_LSFT|MOD_RSFT)>;
        };
    };

    keymap {
        compatible = "zmk,keymap";

        default_layer {
            bindings = <
                // Replace a key with custom behavior
                &cad  &kp N1  &kp N2  // ... rest of layout
            >;
        };
    };
};
```

### Feature Configuration

Edit `config/alliecat_keeb.conf`:

```ini
# Sleep configuration
CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=1800000  # 30 minutes
CONFIG_ZMK_SLEEP=y

# RGB underglow
CONFIG_ZMK_RGB_UNDERGLOW=y
CONFIG_ZMK_RGB_UNDERGLOW_EXT_POWER=y
CONFIG_ZMK_RGB_UNDERGLOW_ON_START=n
CONFIG_ZMK_RGB_UNDERGLOW_BRT_MAX=50  # Reduce brightness for battery life

# Mouse/pointing device
CONFIG_ZMK_POINTING=y

# Bluetooth settings
CONFIG_BT_CTLR_TX_PWR_PLUS_8=y  # Increase transmission power
CONFIG_ZMK_HID_REPORT_TYPE_NKRO=n  # Disable NKRO for compatibility

# Debounce settings
CONFIG_ZMK_KSCAN_DEBOUNCE_PRESS_MS=5
CONFIG_ZMK_KSCAN_DEBOUNCE_RELEASE_MS=5
```

### Hardware Customization

Edit `boards/arm/alliecat_keeb/alliecat_keeb.dtsi`:

```c
// Example: Changing encoder resolution
left_encoder: encoder_left {
    compatible = "alps,ec11";
    label = "LEFT_ENCODER";
    resolution = <2>;  // Change from 4 to 2 for different sensitivity
    steps = <20>;      // Adjust steps accordingly
    a-gpios = <&gpio1 10 (GPIO_ACTIVE_HIGH | GPIO_PULL_UP)>;
    b-gpios = <&gpio1 14 (GPIO_ACTIVE_HIGH | GPIO_PULL_UP)>;
    status = "disabled";
};

// Example: Changing RGB LED count
&led_strip {
    chain-length = <36>;  // Adjust based on your LED count
    // ... other settings
};
```

## 🔧 Advanced Build Options

### Conditional Compilation

Create different builds for different use cases:

```yaml
# In build.yaml
include:
  # Gaming build with low latency
  - board: alliecat_keeb_left
    shield: nice_view
    cmake-args: -DCONFIG_BT_CONN_INTERVAL_MIN=6 -DCONFIG_BT_CONN_INTERVAL_MAX=6
    artifact-name: alliecat_keeb_gaming_left

  # Battery optimized build
  - board: alliecat_keeb_left
    shield: nice_view
    cmake-args: -DCONFIG_ZMK_RGB_UNDERGLOW_ON_START=n -DCONFIG_ZMK_IDLE_SLEEP_TIMEOUT=900000
    artifact-name: alliecat_keeb_battery_left
```

### Custom Shields

Create custom shield definitions for different hardware configurations:

```c
// File: config/boards/shields/my_custom_sofle/my_custom_sofle.overlay
#include <dt-bindings/zmk/matrix_transform.h>

/ {
    chosen {
        zmk,kscan = &kscan0;
        zmk,matrix_transform = &custom_transform;
    };

    custom_transform: keymap_transform_0 {
        compatible = "zmk,matrix-transform";
        columns = <14>;
        rows = <5>;
        map = <
            // Custom matrix mapping
            RC(0,0) RC(0,1) RC(0,2) // ...
        >;
    };
};
```

## 🐳 Docker Build Environment

### Using Docker for Consistent Builds

1. **Create Dockerfile**
   ```dockerfile
   FROM zmkfirmware/dev-generic:latest

   WORKDIR /workspace
   COPY . .

   RUN west build --board alliecat_keeb_left -- -DZMK_CONFIG="$(pwd)/config"
   ```

2. **Build with Docker**
   ```bash
   # Build Docker image
   docker build -t zmk-sofle-build .

   # Run build
   docker run --rm -v $(pwd):/workspace zmk-sofle-build
   ```

### Docker Compose for Development

```yaml
# docker-compose.yml
version: '3'
services:
  zmk-build:
    image: zmkfirmware/dev-generic:latest
    volumes:
      - .:/workspace
    working_dir: /workspace
    command: west build --board alliecat_keeb_left -- -DZMK_CONFIG="$(pwd)/config"
```

## 🔄 Continuous Integration

### GitHub Actions Workflow

Create `.github/workflows/build.yml`:

```yaml
name: Build ZMK Firmware

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.x'

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install west

    - name: Initialize workspace
      run: west init -l config

    - name: Update workspace
      run: west update

    - name: Build firmware
      run: west build --board alliecat_keeb_left -- -DZMK_CONFIG="$(pwd)/config"

    - name: Archive firmware
      uses: actions/upload-artifact@v3
      with:
        name: firmware
        path: build/zephyr/zmk.uf2
```

## 🧪 Testing Builds

### Basic Functionality Tests

1. **Keymap Validation**
   ```bash
   # Check keymap compilation
   west build --board alliecat_keeb_left -- -DZMK_CONFIG="$(pwd)/config" --target menuconfig
   ```

2. **Feature Testing**
   - Flash firmware to test device
   - Verify all keys register correctly
   - Test RGB underglow functionality
   - Check encoder behavior
   - Verify Bluetooth connectivity

### Automated Testing

```bash
# Create test script
#!/bin/bash
# test-build.sh

echo "Testing all build configurations..."

# Test standard build
west build --board alliecat_keeb_left -- -DZMK_CONFIG="$(pwd)/config"
if [ $? -eq 0 ]; then
    echo "✓ Standard build successful"
else
    echo "✗ Standard build failed"
    exit 1
fi

# Test studio build
west build --board alliecat_keeb_left --shield nice_view -- \
    -DZMK_CONFIG="$(pwd)/config" \
    -DCONFIG_ZMK_STUDIO=y \
    -DCONFIG_ZMK_STUDIO_LOCKING=n \
    -DSNIPPET=studio-rpc-usb-uart
if [ $? -eq 0 ]; then
    echo "✓ Studio build successful"
else
    echo "✗ Studio build failed"
    exit 1
fi

echo "All builds completed successfully!"
```

## 📊 Performance Optimization

### Optimizing for Battery Life

```ini
# config/alliecat_keeb.conf
# Aggressive power saving
CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=300000  # 5 minutes
CONFIG_ZMK_RGB_UNDERGLOW_ON_START=n
CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_IDLE=y
CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_USB=y
CONFIG_BT_CTLR_TX_PWR_0=y  # Reduce transmission power
```

### Optimizing for Responsiveness

```ini
# config/alliecat_keeb.conf
# Low latency configuration
CONFIG_BT_CONN_INTERVAL_MIN=6
CONFIG_BT_CONN_INTERVAL_MAX=6
CONFIG_BT_CTLR_TX_PWR_PLUS_8=y
CONFIG_ZMK_KSCAN_DEBOUNCE_PRESS_MS=1
CONFIG_ZMK_KSCAN_DEBOUNCE_RELEASE_MS=1
```

## 🆘 Build Troubleshooting

### Common Build Errors

#### West Command Not Found
```bash
# Fix: Add Python scripts to PATH
export PATH="$PATH:$HOME/.local/bin"
```

#### CMake Configuration Failed
```bash
# Fix: Clean build directory
rm -rf build/
west build --board alliecat_keeb_left -- -DZMK_CONFIG="$(pwd)/config"
```

#### Device Tree Compilation Errors
```bash
# Fix: Check syntax in .dtsi files
# Common issues:
# - Missing semicolons
# - Incorrect property names
# - Invalid GPIO specifications
```

#### Missing Dependencies
```bash
# Fix: Install missing packages
sudo apt install -y device-tree-compiler libfdt-dev
```

### Debug Build Issues

```bash
# Enable verbose output
west build --board alliecat_keeb_left -- -DZMK_CONFIG="$(pwd)/config" -v

# Check configuration
west build --board alliecat_keeb_left -- -DZMK_CONFIG="$(pwd)/config" --target menuconfig

# Clean rebuild
west build --board alliecat_keeb_left -- -DZMK_CONFIG="$(pwd)/config" --pristine
```

## 📚 Further Resources

- [ZMK Documentation](https://zmk.dev/docs)
- [Zephyr Project Documentation](https://docs.zephyrproject.org/)
- [Device Tree Specification](https://www.devicetree.org/)
- [CMake Documentation](https://cmake.org/documentation/)

---

**Need help with builds?** Check the [Development Setup Guide](development-setup.md) or ask for help in the ZMK Discord community.

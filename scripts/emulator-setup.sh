#!/bin/bash

# ZMK Eyelash Sofle Hardware Emulator Setup
# Creates a virtual development environment for testing without physical hardware

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EMULATOR_DIR="$PROJECT_ROOT/emulator"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if QEMU is available
check_qemu() {
    if ! command -v qemu-system-arm &> /dev/null; then
        log_info "Installing QEMU for ARM emulation..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install qemu
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y qemu-system-arm
            elif command -v yum &> /dev/null; then
                sudo yum install -y qemu-system-arm
            fi
        fi
    fi

    if command -v qemu-system-arm &> /dev/null; then
        log_success "QEMU ARM emulation available"
    else
        log_error "Failed to install QEMU"
        return 1
    fi
}

# Install Zephyr emulation dependencies
install_emulation_deps() {
    log_info "Installing emulation dependencies..."

    # Install Python dependencies for virtual hardware
    python3 -m pip install --user pygame pyserial pynput

    # Install Node.js dependencies for web interface
    if command -v npm &> /dev/null; then
        npm install -g http-server
    fi

    log_success "Emulation dependencies installed"
}

# Create virtual keyboard interface
create_virtual_keyboard() {
    log_info "Creating virtual keyboard interface..."

    mkdir -p "$EMULATOR_DIR/virtual-keyboard"

    # Create HTML interface for testing
    cat > "$EMULATOR_DIR/virtual-keyboard/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ZMK Eyelash Sofle Virtual Keyboard</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: #1a1a1a;
            color: #fff;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .keyboard {
            display: flex;
            gap: 40px;
            justify-content: center;
            margin: 20px 0;
        }

        .half {
            background: #2d2d2d;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.3);
        }

        .row {
            display: flex;
            gap: 5px;
            margin: 5px 0;
            justify-content: center;
        }

        .key {
            background: #4a4a4a;
            border: none;
            border-radius: 5px;
            color: white;
            padding: 10px;
            min-width: 40px;
            min-height: 40px;
            cursor: pointer;
            transition: all 0.1s;
            font-family: monospace;
            font-size: 12px;
        }

        .key:hover {
            background: #5a5a5a;
        }

        .key:active, .key.pressed {
            background: #00ff88;
            color: #000;
            transform: scale(0.95);
        }

        .encoder {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: #666;
            margin: 10px auto;
            position: relative;
            cursor: pointer;
        }

        .encoder::after {
            content: '';
            position: absolute;
            width: 4px;
            height: 20px;
            background: #fff;
            top: 5px;
            left: 50%;
            transform: translateX(-50%);
            border-radius: 2px;
        }

        .display {
            background: #000;
            color: #00ff00;
            padding: 10px;
            border-radius: 5px;
            font-family: monospace;
            font-size: 12px;
            margin: 10px 0;
            min-height: 80px;
            border: 2px solid #333;
        }

        .info-panel {
            background: #2a2a2a;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }

        .status {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }

        .status-item {
            background: #333;
            padding: 15px;
            border-radius: 8px;
        }

        .battery {
            width: 100%;
            height: 20px;
            background: #555;
            border-radius: 10px;
            overflow: hidden;
            margin: 10px 0;
        }

        .battery-fill {
            height: 100%;
            background: linear-gradient(90deg, #ff4444, #ffff44, #44ff44);
            transition: width 0.3s;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎹 ZMK Eyelash Sofle Virtual Keyboard</h1>

        <div class="keyboard">
            <!-- Left Half -->
            <div class="half" id="left-half">
                <h3>Left Half</h3>
                <div class="display" id="left-display">
                    ZMK Eyelash Sofle<br>
                    Layer: 0 (Base)<br>
                    Battery: 85%<br>
                    Status: Connected
                </div>

                <div class="row">
                    <button class="key" data-key="ESC">ESC</button>
                    <button class="key" data-key="1">1</button>
                    <button class="key" data-key="2">2</button>
                    <button class="key" data-key="3">3</button>
                    <button class="key" data-key="4">4</button>
                    <button class="key" data-key="5">5</button>
                </div>

                <div class="row">
                    <button class="key" data-key="TAB">TAB</button>
                    <button class="key" data-key="Q">Q</button>
                    <button class="key" data-key="W">W</button>
                    <button class="key" data-key="E">E</button>
                    <button class="key" data-key="R">R</button>
                    <button class="key" data-key="T">T</button>
                </div>

                <div class="row">
                    <button class="key" data-key="CAPS">CAPS</button>
                    <button class="key" data-key="A">A</button>
                    <button class="key" data-key="S">S</button>
                    <button class="key" data-key="D">D</button>
                    <button class="key" data-key="F">F</button>
                    <button class="key" data-key="G">G</button>
                </div>

                <div class="row">
                    <button class="key" data-key="SHIFT">SHIFT</button>
                    <button class="key" data-key="Z">Z</button>
                    <button class="key" data-key="X">X</button>
                    <button class="key" data-key="C">C</button>
                    <button class="key" data-key="V">V</button>
                    <button class="key" data-key="B">B</button>
                </div>

                <div class="row">
                    <button class="key" data-key="CTRL">CTRL</button>
                    <button class="key" data-key="GUI">GUI</button>
                    <button class="key" data-key="ALT">ALT</button>
                    <button class="key" data-key="MO1">MO(1)</button>
                    <button class="key" data-key="SPACE">SPACE</button>
                </div>

                <div class="encoder" id="left-encoder" title="Rotary Encoder - Click and drag to rotate"></div>
            </div>

            <!-- Right Half -->
            <div class="half" id="right-half">
                <h3>Right Half</h3>
                <div class="display" id="right-display">
                    ZMK Eyelash Sofle<br>
                    Layer: 0 (Base)<br>
                    Battery: 92%<br>
                    Status: Connected
                </div>

                <div class="row">
                    <button class="key" data-key="6">6</button>
                    <button class="key" data-key="7">7</button>
                    <button class="key" data-key="8">8</button>
                    <button class="key" data-key="9">9</button>
                    <button class="key" data-key="0">0</button>
                    <button class="key" data-key="BSPC">BSPC</button>
                </div>

                <div class="row">
                    <button class="key" data-key="Y">Y</button>
                    <button class="key" data-key="U">U</button>
                    <button class="key" data-key="I">I</button>
                    <button class="key" data-key="O">O</button>
                    <button class="key" data-key="P">P</button>
                    <button class="key" data-key="\">\</button>
                </div>

                <div class="row">
                    <button class="key" data-key="H">H</button>
                    <button class="key" data-key="J">J</button>
                    <button class="key" data-key="K">K</button>
                    <button class="key" data-key="L">L</button>
                    <button class="key" data-key=";">;</button>
                    <button class="key" data-key="'">'</button>
                </div>

                <div class="row">
                    <button class="key" data-key="N">N</button>
                    <button class="key" data-key="M">M</button>
                    <button class="key" data-key=",">,</button>
                    <button class="key" data-key=".">.</button>
                    <button class="key" data-key="/">/</button>
                    <button class="key" data-key="ENTER">ENTER</button>
                </div>

                <div class="row">
                    <button class="key" data-key="ENTER2">ENTER</button>
                    <button class="key" data-key="SPACE2">SPACE</button>
                    <button class="key" data-key="MO2">MO(2)</button>
                    <button class="key" data-key="RSHIFT">SHIFT</button>
                    <button class="key" data-key="DEL">DEL</button>
                </div>
            </div>
        </div>

        <div class="info-panel">
            <h3>📊 System Status</h3>
            <div class="status">
                <div class="status-item">
                    <h4>Left Half Battery</h4>
                    <div class="battery">
                        <div class="battery-fill" style="width: 85%"></div>
                    </div>
                    <span>85% - 6.2 hours remaining</span>
                </div>

                <div class="status-item">
                    <h4>Right Half Battery</h4>
                    <div class="battery">
                        <div class="battery-fill" style="width: 92%"></div>
                    </div>
                    <span>92% - 7.8 hours remaining</span>
                </div>

                <div class="status-item">
                    <h4>Connection</h4>
                    <p>🟢 Both halves connected<br>
                    📶 Signal strength: Excellent<br>
                    🔗 Split sync: 5ms latency</p>
                </div>

                <div class="status-item">
                    <h4>Current Layer</h4>
                    <p>Layer 0: Base Layer<br>
                    🎹 QWERTY Layout<br>
                    🎛️ Encoder: Volume Control</p>
                </div>
            </div>
        </div>

        <div class="info-panel">
            <h3>🔧 Testing Controls</h3>
            <button onclick="simulateKeypress('test')">Test Keypress</button>
            <button onclick="changeBattery()">Simulate Battery Drain</button>
            <button onclick="toggleConnection()">Toggle Connection</button>
            <button onclick="switchLayer()">Switch Layer</button>
        </div>

        <div class="info-panel">
            <h3>📝 Key Log</h3>
            <div id="key-log" style="background: #000; color: #0f0; padding: 10px; font-family: monospace; height: 200px; overflow-y: scroll;"></div>
        </div>
    </div>

    <script>
        let currentLayer = 0;
        let leftBattery = 85;
        let rightBattery = 92;
        let connected = true;

        // Key press simulation
        document.querySelectorAll('.key').forEach(key => {
            key.addEventListener('mousedown', () => {
                key.classList.add('pressed');
                logKeypress(key.dataset.key, 'down');
            });

            key.addEventListener('mouseup', () => {
                key.classList.remove('pressed');
                logKeypress(key.dataset.key, 'up');
            });

            key.addEventListener('mouseleave', () => {
                key.classList.remove('pressed');
            });
        });

        // Encoder simulation
        let encoderPosition = 0;
        const encoder = document.getElementById('left-encoder');
        let isRotating = false;

        encoder.addEventListener('mousedown', (e) => {
            isRotating = true;
            const startY = e.clientY;

            const onMouseMove = (e) => {
                if (!isRotating) return;
                const deltaY = e.clientY - startY;
                if (Math.abs(deltaY) > 10) {
                    const direction = deltaY > 0 ? 'clockwise' : 'counterclockwise';
                    logKeypress(`ENCODER_${direction.toUpperCase()}`, 'rotate');
                    encoderPosition += deltaY > 0 ? 1 : -1;
                    encoder.style.transform = `rotate(${encoderPosition * 30}deg)`;
                }
            };

            const onMouseUp = () => {
                isRotating = false;
                document.removeEventListener('mousemove', onMouseMove);
                document.removeEventListener('mouseup', onMouseUp);
            };

            document.addEventListener('mousemove', onMouseMove);
            document.addEventListener('mouseup', onMouseUp);
        });

        encoder.addEventListener('click', () => {
            logKeypress('ENCODER_PRESS', 'click');
        });

        // Logging function
        function logKeypress(key, action) {
            const log = document.getElementById('key-log');
            const timestamp = new Date().toLocaleTimeString();
            const entry = `[${timestamp}] Key: ${key} | Action: ${action} | Layer: ${currentLayer}\n`;
            log.textContent += entry;
            log.scrollTop = log.scrollHeight;
        }

        // Test functions
        function simulateKeypress(key) {
            logKeypress(key || 'TEST', 'simulated');
        }

        function changeBattery() {
            leftBattery = Math.max(10, leftBattery - 5);
            rightBattery = Math.max(10, rightBattery - 3);
            updateBatteryDisplay();
        }

        function toggleConnection() {
            connected = !connected;
            const status = connected ? 'Connected' : 'Disconnected';
            document.getElementById('left-display').innerHTML =
                `ZMK Eyelash Sofle<br>Layer: ${currentLayer}<br>Battery: ${leftBattery}%<br>Status: ${status}`;
            document.getElementById('right-display').innerHTML =
                `ZMK Eyelash Sofle<br>Layer: ${currentLayer}<br>Battery: ${rightBattery}%<br>Status: ${status}`;
        }

        function switchLayer() {
            currentLayer = (currentLayer + 1) % 3;
            const layerNames = ['Base', 'Function', 'System'];
            document.getElementById('left-display').innerHTML =
                `ZMK Eyelash Sofle<br>Layer: ${currentLayer} (${layerNames[currentLayer]})<br>Battery: ${leftBattery}%<br>Status: Connected`;
            document.getElementById('right-display').innerHTML =
                `ZMK Eyelash Sofle<br>Layer: ${currentLayer} (${layerNames[currentLayer]})<br>Battery: ${rightBattery}%<br>Status: Connected`;
        }

        function updateBatteryDisplay() {
            document.querySelectorAll('.battery-fill')[0].style.width = leftBattery + '%';
            document.querySelectorAll('.battery-fill')[1].style.width = rightBattery + '%';
            toggleConnection(); // Update display
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            const keyMap = {
                'Escape': 'ESC',
                'Tab': 'TAB',
                'CapsLock': 'CAPS',
                'Shift': 'SHIFT',
                'Control': 'CTRL',
                'Alt': 'ALT',
                'Meta': 'GUI',
                'Backspace': 'BSPC',
                'Enter': 'ENTER',
                'Delete': 'DEL',
                ' ': 'SPACE'
            };

            const zmkKey = keyMap[e.key] || e.key.toUpperCase();
            logKeypress(zmkKey, 'physical_keydown');
        });

        // Initialize
        logKeypress('SYSTEM', 'Virtual keyboard initialized');
    </script>
</body>
</html>
EOF

    log_success "Virtual keyboard interface created"
}

# Create Python hardware simulator
create_hardware_simulator() {
    log_info "Creating Python hardware simulator..."

    mkdir -p "$EMULATOR_DIR/simulator"

    cat > "$EMULATOR_DIR/simulator/keyboard_sim.py" << 'EOF'
#!/usr/bin/env python3
"""
ZMK Eyelash Sofle Hardware Simulator
Simulates keyboard hardware for development and testing
"""

import time
import json
import threading
import socket
from dataclasses import dataclass
from typing import Dict, List, Optional
import random

@dataclass
class KeyEvent:
    row: int
    col: int
    pressed: bool
    timestamp: float

@dataclass
class KeyboardHalf:
    name: str
    battery_level: int
    connected: bool
    keys_pressed: set
    last_activity: float

class KeyboardSimulator:
    def __init__(self):
        self.left_half = KeyboardHalf("left", 85, True, set(), time.time())
        self.right_half = KeyboardHalf("right", 92, True, set(), time.time())
        self.current_layer = 0
        self.rgb_enabled = True
        self.encoder_position = 0
        self.running = False

        # Key matrix definition
        self.key_matrix = {
            'left': [
                ['ESC', '1', '2', '3', '4', '5'],
                ['TAB', 'Q', 'W', 'E', 'R', 'T'],
                ['CAPS', 'A', 'S', 'D', 'F', 'G'],
                ['SHIFT', 'Z', 'X', 'C', 'V', 'B'],
                ['CTRL', 'GUI', 'ALT', 'MO1', 'SPACE', 'ENC']
            ],
            'right': [
                ['6', '7', '8', '9', '0', 'BSPC'],
                ['Y', 'U', 'I', 'O', 'P', '\\'],
                ['H', 'J', 'K', 'L', ';', "'"],
                ['N', 'M', ',', '.', '/', 'ENTER'],
                ['ENTER', 'SPACE', 'MO2', 'RSHIFT', 'DEL', '']
            ]
        }

    def start(self):
        """Start the simulator"""
        self.running = True
        print("🚀 ZMK Eyelash Sofle Simulator Starting...")
        print("=" * 50)

        # Start background threads
        battery_thread = threading.Thread(target=self._battery_simulation)
        battery_thread.daemon = True
        battery_thread.start()

        connection_thread = threading.Thread(target=self._connection_simulation)
        connection_thread.daemon = True
        connection_thread.start()

        # Start main loop
        self._main_loop()

    def _main_loop(self):
        """Main simulation loop"""
        try:
            while self.running:
                self._print_status()

                print("\nCommands:")
                print("1. Press key (p)")
                print("2. Rotate encoder (e)")
                print("3. Toggle RGB (r)")
                print("4. Switch layer (l)")
                print("5. Simulate battery drain (b)")
                print("6. Toggle connection (c)")
                print("7. Generate random activity (a)")
                print("8. Exit (q)")

                cmd = input("\nEnter command: ").lower().strip()

                if cmd == 'q':
                    break
                elif cmd == 'p':
                    self._simulate_keypress()
                elif cmd == 'e':
                    self._simulate_encoder()
                elif cmd == 'r':
                    self._toggle_rgb()
                elif cmd == 'l':
                    self._switch_layer()
                elif cmd == 'b':
                    self._drain_battery()
                elif cmd == 'c':
                    self._toggle_connection()
                elif cmd == 'a':
                    self._random_activity()
                else:
                    print("Invalid command")

                time.sleep(0.1)

        except KeyboardInterrupt:
            pass
        finally:
            self.running = False
            print("\n👋 Simulator stopped")

    def _print_status(self):
        """Print current keyboard status"""
        print("\n" + "=" * 60)
        print("🎹 ZMK Eyelash Sofle Status")
        print("=" * 60)

        # Left half status
        left_status = "🟢" if self.left_half.connected else "🔴"
        print(f"Left Half:  {left_status} Battery: {self.left_half.battery_level}% | Keys: {len(self.left_half.keys_pressed)}")

        # Right half status
        right_status = "🟢" if self.right_half.connected else "🔴"
        print(f"Right Half: {right_status} Battery: {self.right_half.battery_level}% | Keys: {len(self.right_half.keys_pressed)}")

        # System status
        print(f"Layer: {self.current_layer} | RGB: {'On' if self.rgb_enabled else 'Off'} | Encoder: {self.encoder_position}")

        # Active keys
        if self.left_half.keys_pressed or self.right_half.keys_pressed:
            all_pressed = list(self.left_half.keys_pressed) + list(self.right_half.keys_pressed)
            print(f"Pressed Keys: {', '.join(all_pressed)}")

    def _simulate_keypress(self):
        """Simulate a key press"""
        print("\nKey press simulation:")
        print("Format: <half>:<row>:<col> (e.g., left:1:2 for W key)")
        print("Or use key name: <half>:<key> (e.g., left:W)")

        key_input = input("Enter key: ").strip()

        try:
            parts = key_input.split(':')
            if len(parts) != 2:
                print("Invalid format")
                return

            half_name, key_spec = parts
            half = self.left_half if half_name == 'left' else self.right_half

            if key_spec.isdigit():
                # Row:Col format
                row, col = map(int, key_spec.split(':'))
                key_name = self.key_matrix[half_name][row][col]
            else:
                # Key name format
                key_name = key_spec.upper()

            # Simulate press
            if key_name in half.keys_pressed:
                half.keys_pressed.remove(key_name)
                print(f"🔓 Released: {key_name}")
            else:
                half.keys_pressed.add(key_name)
                print(f"🔒 Pressed: {key_name}")

            half.last_activity = time.time()

        except (ValueError, IndexError):
            print("Invalid key specification")

    def _simulate_encoder(self):
        """Simulate encoder rotation"""
        direction = input("Enter direction (cw/ccw) or 'press': ").lower().strip()

        if direction == 'cw':
            self.encoder_position += 1
            print(f"🔄 Encoder rotated clockwise (position: {self.encoder_position})")
        elif direction == 'ccw':
            self.encoder_position -= 1
            print(f"🔄 Encoder rotated counter-clockwise (position: {self.encoder_position})")
        elif direction == 'press':
            print("🔘 Encoder pressed")
        else:
            print("Invalid direction")

    def _toggle_rgb(self):
        """Toggle RGB lighting"""
        self.rgb_enabled = not self.rgb_enabled
        status = "enabled" if self.rgb_enabled else "disabled"
        print(f"🌈 RGB {status}")

    def _switch_layer(self):
        """Switch keyboard layer"""
        self.current_layer = (self.current_layer + 1) % 4
        layer_names = ["Base", "Function", "System", "Custom"]
        print(f"🔄 Switched to layer {self.current_layer}: {layer_names[self.current_layer]}")

    def _drain_battery(self):
        """Simulate battery drain"""
        self.left_half.battery_level = max(0, self.left_half.battery_level - random.randint(5, 15))
        self.right_half.battery_level = max(0, self.right_half.battery_level - random.randint(5, 15))
        print(f"🔋 Batteries drained - Left: {self.left_half.battery_level}%, Right: {self.right_half.battery_level}%")

    def _toggle_connection(self):
        """Toggle connection status"""
        if random.choice([True, False]):
            self.left_half.connected = not self.left_half.connected
            status = "connected" if self.left_half.connected else "disconnected"
            print(f"📶 Left half {status}")
        else:
            self.right_half.connected = not self.right_half.connected
            status = "connected" if self.right_half.connected else "disconnected"
            print(f"📶 Right half {status}")

    def _random_activity(self):
        """Generate random keyboard activity"""
        print("🎲 Generating random activity...")

        for _ in range(random.randint(5, 15)):
            # Random key press
            half = random.choice([self.left_half, self.right_half])
            half_name = "left" if half == self.left_half else "right"

            row = random.randint(0, 4)
            col = random.randint(0, 5)

            try:
                key_name = self.key_matrix[half_name][row][col]
                if key_name:  # Skip empty keys
                    half.keys_pressed.add(key_name)
                    print(f"  🔒 Random press: {key_name}")
                    time.sleep(random.uniform(0.1, 0.3))
                    half.keys_pressed.discard(key_name)
            except IndexError:
                pass

        print("🎲 Random activity complete")

    def _battery_simulation(self):
        """Background battery drain simulation"""
        while self.running:
            time.sleep(60)  # Check every minute

            # Gradual battery drain
            if random.random() < 0.1:  # 10% chance per minute
                if self.left_half.battery_level > 0:
                    self.left_half.battery_level = max(0, self.left_half.battery_level - 1)
                if self.right_half.battery_level > 0:
                    self.right_half.battery_level = max(0, self.right_half.battery_level - 1)

    def _connection_simulation(self):
        """Background connection simulation"""
        while self.running:
            time.sleep(30)  # Check every 30 seconds

            # Occasional connection issues
            if random.random() < 0.05:  # 5% chance
                half = random.choice([self.left_half, self.right_half])
                half.connected = False
                time.sleep(random.uniform(1, 5))  # Brief disconnection
                half.connected = True

if __name__ == "__main__":
    simulator = KeyboardSimulator()
    simulator.start()
EOF

    # Make it executable
    chmod +x "$EMULATOR_DIR/simulator/keyboard_sim.py"

    log_success "Python hardware simulator created"
}

# Create emulation build target
create_emulation_build() {
    log_info "Creating emulation build target..."

    # Create native_posix build for emulation
    cat >> "$PROJECT_ROOT/build.yaml" << 'EOF'

  # Emulation targets
  - board: native_posix
    artifact-name: eyelash_sofle_emulation
EOF

    # Create emulation-specific configuration
    mkdir -p "$PROJECT_ROOT/config/boards/native_posix"

    cat > "$PROJECT_ROOT/config/boards/native_posix/eyelash_sofle_emulation.conf" << 'EOF'
# Emulation configuration
CONFIG_ZMK_KEYBOARD_NAME="Eyelash Sofle Emulation"

# Enable logging for debugging
CONFIG_LOG=y
CONFIG_ZMK_LOG_LEVEL_DBG=y

# Enable USB HID for host connection
CONFIG_ZMK_USB=y
CONFIG_USB_DEVICE_STACK=y

# Disable sleep for emulation
CONFIG_ZMK_SLEEP=n

# Enable all features for testing
CONFIG_ZMK_RGB_UNDERGLOW=y
CONFIG_ZMK_DISPLAY=y
CONFIG_ZMK_POINTING=y

# Emulation-specific settings
CONFIG_NATIVE_APPLICATION=y
CONFIG_NATIVE_UART_0_ON_STDINOUT=y
EOF

    log_success "Emulation build target created"
}

# Create launch scripts
create_launch_scripts() {
    log_info "Creating launch scripts..."

    # Virtual keyboard launcher
    cat > "$EMULATOR_DIR/launch-virtual-keyboard.sh" << 'EOF'
#!/bin/bash

echo "🎹 Starting ZMK Eyelash Sofle Virtual Keyboard..."

# Check if http-server is available
if command -v http-server &> /dev/null; then
    echo "🌐 Starting web server on http://localhost:8080"
    cd "$(dirname "$0")/virtual-keyboard"
    http-server -p 8080 -o
else
    echo "📁 Open virtual-keyboard/index.html in your browser"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$(dirname "$0")/virtual-keyboard/index.html"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open "$(dirname "$0")/virtual-keyboard/index.html"
    fi
fi
EOF

    # Hardware simulator launcher
    cat > "$EMULATOR_DIR/launch-hardware-sim.sh" << 'EOF'
#!/bin/bash

echo "🔧 Starting ZMK Hardware Simulator..."
cd "$(dirname "$0")/simulator"
python3 keyboard_sim.py
EOF

    # Combined launcher
    cat > "$EMULATOR_DIR/launch-full-emulation.sh" << 'EOF'
#!/bin/bash

echo "🚀 Starting Full ZMK Emulation Environment..."
echo "This will start both the virtual keyboard and hardware simulator"

# Launch virtual keyboard in background
./launch-virtual-keyboard.sh &
VKBD_PID=$!

echo "⏱️  Waiting 3 seconds for web server to start..."
sleep 3

# Launch hardware simulator
./launch-hardware-sim.sh

# Cleanup on exit
trap "kill $VKBD_PID 2>/dev/null" EXIT
EOF

    # Make scripts executable
    chmod +x "$EMULATOR_DIR"/*.sh

    log_success "Launch scripts created"
}

# Create documentation
create_emulation_docs() {
    log_info "Creating emulation documentation..."

    cat > "$EMULATOR_DIR/README.md" << 'EOF'
# ZMK Eyelash Sofle Hardware Emulation

This directory contains tools for emulating the ZMK Eyelash Sofle keyboard hardware for development and testing purposes.

## Components

### 1. Virtual Keyboard Interface
- **File**: `virtual-keyboard/index.html`
- **Purpose**: Visual representation of the keyboard for testing layouts
- **Features**:
  - Interactive key presses
  - Encoder simulation
  - Battery level display
  - Layer switching
  - Key logging

### 2. Hardware Simulator
- **File**: `simulator/keyboard_sim.py`
- **Purpose**: Command-line hardware simulation
- **Features**:
  - Key matrix simulation
  - Battery drain simulation
  - Connection status simulation
  - Random activity generation

### 3. Emulation Build Target
- **Purpose**: Build firmware that runs on host system
- **Usage**: Test firmware logic without physical hardware

## Usage

### Quick Start
```bash
# Start full emulation environment
./launch-full-emulation.sh

# Or start components individually:
./launch-virtual-keyboard.sh
./launch-hardware-sim.sh
```

### Building Emulation Firmware
```bash
# Build emulation target
west build -b native_posix -- -DZMK_CONFIG="$(pwd)/config"

# Run emulation
./build/zephyr/zmk.exe
```

### Virtual Keyboard Controls
- **Click keys**: Simulate key presses
- **Drag encoder**: Simulate rotation
- **Click encoder**: Simulate encoder press
- **Use buttons**: Test various scenarios

### Hardware Simulator Commands
- `p`: Simulate key press
- `e`: Rotate encoder
- `r`: Toggle RGB
- `l`: Switch layer
- `b`: Drain battery
- `c`: Toggle connection
- `a`: Generate random activity
- `q`: Exit

## Development Workflow

1. **Design keymap** using virtual keyboard
2. **Test behaviors** with hardware simulator
3. **Build emulation firmware** for logic testing
4. **Deploy to physical hardware** when ready

## Debugging

### Enable Debug Logging
```c
// In emulation.conf
CONFIG_LOG=y
CONFIG_ZMK_LOG_LEVEL_DBG=y
```

### Monitor Key Events
Watch the key log in the virtual keyboard interface or simulator output.

### Test Edge Cases
- Battery low scenarios
- Connection interruptions
- Rapid key sequences
- Layer switching behaviors

## Limitations

- Physical feel cannot be emulated
- Timing may differ from real hardware
- Some hardware-specific features may not work
- RF characteristics cannot be simulated

## Contributing

Improvements to the emulation environment are welcome:
- Enhanced visual interface
- More realistic timing
- Additional hardware features
- Better debugging tools
EOF

    log_success "Emulation documentation created"
}

# Main execution
main() {
    echo "🔬 ZMK Eyelash Sofle Hardware Emulator Setup"
    echo "=============================================="
    echo ""

    log_info "This will set up a virtual development environment for testing without physical hardware"
    echo ""

    check_qemu
    install_emulation_deps
    create_virtual_keyboard
    create_hardware_simulator
    create_emulation_build
    create_launch_scripts
    create_emulation_docs

    echo ""
    echo "🎉 Hardware emulation setup complete!"
    echo ""
    echo "📁 Emulation files created in: $EMULATOR_DIR"
    echo ""
    echo "🚀 Quick start:"
    echo "   cd $EMULATOR_DIR"
    echo "   ./launch-full-emulation.sh"
    echo ""
    echo "📖 See $EMULATOR_DIR/README.md for detailed usage instructions"
    echo ""
}

# Run main function
main "$@"

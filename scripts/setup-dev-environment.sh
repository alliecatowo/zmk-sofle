#!/bin/bash

# ZMK Eyelash Sofle Development Environment Setup
# Supports macOS with Homebrew

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS. Please use the appropriate setup for your OS."
        exit 1
    fi
    log_success "Running on macOS"
}

# Install Homebrew if not present
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        log_success "Homebrew installed"
    else
        log_success "Homebrew already installed"
        brew update
    fi
}

# Install system dependencies
install_system_deps() {
    log_info "Installing system dependencies..."

    # Essential tools
    brew install git cmake ninja python3 wget curl

    # ZMK specific tools
    brew install dtc

    # Development tools
    brew install --cask visual-studio-code
    brew install --cask docker

    # Optional but useful
    brew install tree jq

    log_success "System dependencies installed"
}

# Install Python tools
install_python_tools() {
    log_info "Installing Python tools..."

    # Install pip if not present
    if ! command -v pip3 &> /dev/null; then
        log_info "Installing pip..."
        python3 -m ensurepip --upgrade
    fi

    # Install west and other Python tools
    python3 -m pip install --user --upgrade pip
    python3 -m pip install --user west
    python3 -m pip install --user pyserial

    # Ensure Python user bin is in PATH
    export PATH="$HOME/Library/Python/$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/bin:$PATH"
    echo 'export PATH="$HOME/Library/Python/$(python3 -c '"'"'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")'"'"')/bin:$PATH"' >> ~/.zprofile

    log_success "Python tools installed"
}

# Install Zephyr SDK
install_zephyr_sdk() {
    log_info "Installing Zephyr SDK..."

    SDK_VERSION="0.16.8"
    SDK_DIR="$HOME/zephyr-sdk-$SDK_VERSION"

    if [ ! -d "$SDK_DIR" ]; then
        cd "$HOME"

        # Download SDK for macOS
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="aarch64"
        else
            ARCH="x86_64"
        fi

        SDK_FILE="zephyr-sdk-${SDK_VERSION}_macos-${ARCH}.tar.xz"

        log_info "Downloading Zephyr SDK for macOS $ARCH..."
        wget "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${SDK_VERSION}/${SDK_FILE}"

        log_info "Extracting SDK..."
        tar xf "$SDK_FILE"
        rm "$SDK_FILE"

        cd "$SDK_DIR"
        ./setup.sh

        log_success "Zephyr SDK installed to $SDK_DIR"
    else
        log_success "Zephyr SDK already installed"
    fi
}

# Create workspace directory
create_workspace() {
    log_info "Creating ZMK workspace..."

    WORKSPACE_DIR="$HOME/zmk-workspace"
    mkdir -p "$WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"

    # Save workspace path for other scripts
    echo "export ZMK_WORKSPACE=\"$WORKSPACE_DIR\"" >> ~/.zprofile
    export ZMK_WORKSPACE="$WORKSPACE_DIR"

    log_success "Workspace created at $WORKSPACE_DIR"
}

# Install VS Code extensions
install_vscode_extensions() {
    log_info "Installing VS Code extensions..."

    # Essential extensions for ZMK development
    code --install-extension ms-vscode.cpptools
    code --install-extension ms-vscode.cmake-tools
    code --install-extension ms-python.python
    code --install-extension ms-vscode.vscode-json
    code --install-extension yzhang.markdown-all-in-one
    code --install-extension ms-vscode.vscode-serial-monitor
    code --install-extension platformio.platformio-ide

    log_success "VS Code extensions installed"
}

# Create useful aliases and functions
create_aliases() {
    log_info "Creating useful aliases..."

    cat >> ~/.zprofile << 'EOF'

# ZMK Development Aliases
alias zmk-workspace='cd $ZMK_WORKSPACE'
alias zmk-build='west build'
alias zmk-flash='west flash'
alias zmk-clean='rm -rf build/'
alias zmk-pristine='west build --pristine'

# ZMK Helper Functions
zmk-status() {
    echo "ZMK Workspace: $ZMK_WORKSPACE"
    echo "West Version: $(west --version 2>/dev/null || echo 'Not installed')"
    echo "Python Version: $(python3 --version)"
    echo "CMake Version: $(cmake --version | head -n1)"
}

zmk-setup-project() {
    if [ -z "$1" ]; then
        echo "Usage: zmk-setup-project <project-name>"
        return 1
    fi

    mkdir -p "$ZMK_WORKSPACE/$1"
    cd "$ZMK_WORKSPACE/$1"
}
EOF

    log_success "Aliases and functions created"
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."

    # Check commands
    local commands=("git" "cmake" "ninja" "python3" "west" "dtc")
    local missing=()

    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        log_success "All required commands are available"
    else
        log_error "Missing commands: ${missing[*]}"
        return 1
    fi

    # Check Zephyr SDK
    if [ -d "$HOME/zephyr-sdk-0.16.8" ]; then
        log_success "Zephyr SDK found"
    else
        log_warning "Zephyr SDK not found"
    fi

    # Print summary
    echo ""
    echo "🎉 Development Environment Setup Complete!"
    echo ""
    echo "Next steps:"
    echo "1. Run 'source ~/.zprofile' or restart your terminal"
    echo "2. Run 'zmk-status' to verify everything is working"
    echo "3. Use './scripts/setup-dongle-configuration.sh' to configure your keyboard"
    echo ""
}

# Main execution
main() {
    echo "🚀 Setting up ZMK Eyelash Sofle Development Environment"
    echo "=================================================="
    echo ""

    check_macos
    install_homebrew
    install_system_deps
    install_python_tools
    install_zephyr_sdk
    create_workspace
    install_vscode_extensions
    create_aliases
    verify_installation
}

# Run main function
main "$@"

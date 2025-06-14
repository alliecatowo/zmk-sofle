#!/bin/bash

# ZMK Eyelash Sofle Backup and Restore Utility
# Manages configuration backups and firmware archiving

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
BACKUP_ROOT="$PROJECT_ROOT/backups"
FIRMWARE_ROOT="$PROJECT_ROOT/firmware"

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

# Create backup directory structure
create_backup_dirs() {
    mkdir -p "$BACKUP_ROOT"
    mkdir -p "$FIRMWARE_ROOT"
    mkdir -p "$BACKUP_ROOT/keymap"
    mkdir -p "$BACKUP_ROOT/config"
    mkdir -p "$BACKUP_ROOT/firmware"
    mkdir -p "$BACKUP_ROOT/builds"
}

# Backup current configuration
backup_config() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$BACKUP_ROOT/config/$timestamp"

    log_info "Creating configuration backup..."
    mkdir -p "$backup_dir"

    # Backup configuration files
    if [ -f "$PROJECT_ROOT/config/eyelash_sofle.keymap" ]; then
        cp "$PROJECT_ROOT/config/eyelash_sofle.keymap" "$backup_dir/"
        log_success "Keymap backed up"
    fi

    if [ -f "$PROJECT_ROOT/config/eyelash_sofle.conf" ]; then
        cp "$PROJECT_ROOT/config/eyelash_sofle.conf" "$backup_dir/"
        log_success "Configuration backed up"
    fi

    if [ -f "$PROJECT_ROOT/config/west.yml" ]; then
        cp "$PROJECT_ROOT/config/west.yml" "$backup_dir/"
        log_success "West configuration backed up"
    fi

    if [ -f "$PROJECT_ROOT/build.yaml" ]; then
        cp "$PROJECT_ROOT/build.yaml" "$backup_dir/"
        log_success "Build configuration backed up"
    fi

    # Backup board definitions
    if [ -d "$PROJECT_ROOT/config/boards" ]; then
        cp -r "$PROJECT_ROOT/config/boards" "$backup_dir/"
        log_success "Board definitions backed up"
    fi

    # Create backup manifest
    cat > "$backup_dir/backup_manifest.txt" << EOF
ZMK Eyelash Sofle Configuration Backup
Created: $(date)
Hostname: $(hostname)
User: $(whoami)
Commit: $(git rev-parse HEAD 2>/dev/null || echo "Not in git repository")

Files backed up:
$(ls -la "$backup_dir" | grep -v "backup_manifest.txt")
EOF

    log_success "Configuration backup created: $backup_dir"
    echo "$backup_dir"
}

# Backup firmware
backup_firmware() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$BACKUP_ROOT/firmware/$timestamp"

    log_info "Creating firmware backup..."
    mkdir -p "$backup_dir"

    # Backup built firmware
    if [ -d "$PROJECT_ROOT/build" ]; then
        find "$PROJECT_ROOT/build" -name "*.uf2" -exec cp {} "$backup_dir/" \;
        local count=$(find "$backup_dir" -name "*.uf2" | wc -l)
        if [ $count -gt 0 ]; then
            log_success "Backed up $count firmware files"
        else
            log_warning "No firmware files found in build directory"
        fi
    fi

    # Copy from firmware directory if exists
    if [ -d "$FIRMWARE_ROOT" ]; then
        find "$FIRMWARE_ROOT" -name "*.uf2" -exec cp {} "$backup_dir/" \;
    fi

    # Create firmware manifest
    cat > "$backup_dir/firmware_manifest.txt" << EOF
ZMK Eyelash Sofle Firmware Backup
Created: $(date)
Build timestamp: $timestamp
Commit: $(git rev-parse HEAD 2>/dev/null || echo "Not in git repository")

Firmware files:
$(ls -la "$backup_dir"/*.uf2 2>/dev/null || echo "No firmware files found")
EOF

    log_success "Firmware backup created: $backup_dir"
    echo "$backup_dir"
}

# Restore configuration
restore_config() {
    local backup_dir="$1"

    if [ -z "$backup_dir" ]; then
        log_error "Backup directory not specified"
        return 1
    fi

    if [ ! -d "$backup_dir" ]; then
        log_error "Backup directory does not exist: $backup_dir"
        return 1
    fi

    log_info "Restoring configuration from: $backup_dir"

    # Create current backup before restore
    local current_backup=$(backup_config)
    log_info "Current configuration backed up to: $current_backup"

    # Restore files
    if [ -f "$backup_dir/eyelash_sofle.keymap" ]; then
        cp "$backup_dir/eyelash_sofle.keymap" "$PROJECT_ROOT/config/"
        log_success "Keymap restored"
    fi

    if [ -f "$backup_dir/eyelash_sofle.conf" ]; then
        cp "$backup_dir/eyelash_sofle.conf" "$PROJECT_ROOT/config/"
        log_success "Configuration restored"
    fi

    if [ -f "$backup_dir/west.yml" ]; then
        cp "$backup_dir/west.yml" "$PROJECT_ROOT/config/"
        log_success "West configuration restored"
    fi

    if [ -f "$backup_dir/build.yaml" ]; then
        cp "$backup_dir/build.yaml" "$PROJECT_ROOT/"
        log_success "Build configuration restored"
    fi

    if [ -d "$backup_dir/boards" ]; then
        rm -rf "$PROJECT_ROOT/config/boards"
        cp -r "$backup_dir/boards" "$PROJECT_ROOT/config/"
        log_success "Board definitions restored"
    fi

    log_success "Configuration restore completed"
}

# List available backups
list_backups() {
    log_info "Available configuration backups:"
    if [ -d "$BACKUP_ROOT/config" ]; then
        for backup in "$BACKUP_ROOT/config"/*; do
            if [ -d "$backup" ]; then
                local timestamp=$(basename "$backup")
                local readable_date=$(echo "$timestamp" | sed 's/_/ /' | sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/')
                echo "  $timestamp ($readable_date)"
                if [ -f "$backup/backup_manifest.txt" ]; then
                    echo "    $(head -n 1 "$backup/backup_manifest.txt")"
                fi
            fi
        done
    else
        echo "  No backups found"
    fi

    echo ""
    log_info "Available firmware backups:"
    if [ -d "$BACKUP_ROOT/firmware" ]; then
        for backup in "$BACKUP_ROOT/firmware"/*; do
            if [ -d "$backup" ]; then
                local timestamp=$(basename "$backup")
                local readable_date=$(echo "$timestamp" | sed 's/_/ /' | sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/')
                local count=$(find "$backup" -name "*.uf2" | wc -l)
                echo "  $timestamp ($readable_date) - $count firmware files"
            fi
        done
    else
        echo "  No firmware backups found"
    fi
}

# Compare configurations
compare_configs() {
    local backup1="$1"
    local backup2="$2"

    if [ -z "$backup1" ] || [ -z "$backup2" ]; then
        log_error "Two backup directories must be specified"
        return 1
    fi

    log_info "Comparing configurations..."

    for file in "eyelash_sofle.keymap" "eyelash_sofle.conf" "west.yml" "build.yaml"; do
        if [ -f "$backup1/$file" ] && [ -f "$backup2/$file" ]; then
            echo "=== Differences in $file ==="
            if diff -u "$backup1/$file" "$backup2/$file"; then
                echo "No differences found"
            fi
            echo ""
        elif [ -f "$backup1/$file" ]; then
            echo "=== $file exists only in first backup ==="
        elif [ -f "$backup2/$file" ]; then
            echo "=== $file exists only in second backup ==="
        fi
    done
}

# Export configuration
export_config() {
    local export_name="$1"
    local export_dir="$BACKUP_ROOT/exports"

    if [ -z "$export_name" ]; then
        export_name="zmk_eyelash_sofle_$(date +%Y%m%d_%H%M%S)"
    fi

    mkdir -p "$export_dir"
    local archive_path="$export_dir/${export_name}.tar.gz"

    log_info "Exporting configuration to: $archive_path"

    # Create temporary directory for export
    local temp_dir=$(mktemp -d)
    local export_temp="$temp_dir/$export_name"
    mkdir -p "$export_temp"

    # Copy configuration files
    cp -r "$PROJECT_ROOT/config" "$export_temp/"
    cp "$PROJECT_ROOT/build.yaml" "$export_temp/"

    # Copy documentation
    if [ -d "$PROJECT_ROOT/docs" ]; then
        cp -r "$PROJECT_ROOT/docs" "$export_temp/"
    fi

    # Copy scripts
    if [ -d "$PROJECT_ROOT/scripts" ]; then
        cp -r "$PROJECT_ROOT/scripts" "$export_temp/"
    fi

    # Copy VS Code configuration
    if [ -d "$PROJECT_ROOT/.vscode" ]; then
        cp -r "$PROJECT_ROOT/.vscode" "$export_temp/"
    fi

    # Copy GitHub Actions
    if [ -d "$PROJECT_ROOT/.github" ]; then
        cp -r "$PROJECT_ROOT/.github" "$export_temp/"
    fi

    # Create export manifest
    cat > "$export_temp/export_manifest.txt" << EOF
ZMK Eyelash Sofle Configuration Export
Created: $(date)
Export name: $export_name
Hostname: $(hostname)
User: $(whoami)
Commit: $(git rev-parse HEAD 2>/dev/null || echo "Not in git repository")

This export contains:
- Configuration files (config/)
- Build configuration (build.yaml)
- Documentation (docs/)
- Development scripts (scripts/)
- VS Code configuration (.vscode/)
- GitHub Actions (.github/)

To import this configuration:
1. Extract the archive
2. Copy files to your ZMK project
3. Run ./scripts/setup-dev-environment.sh
4. Build firmware with west build
EOF

    # Create archive
    cd "$temp_dir"
    tar -czf "$archive_path" "$export_name"

    # Cleanup
    rm -rf "$temp_dir"

    log_success "Configuration exported to: $archive_path"
    echo "$archive_path"
}

# Import configuration
import_config() {
    local archive_path="$1"

    if [ -z "$archive_path" ]; then
        log_error "Archive path not specified"
        return 1
    fi

    if [ ! -f "$archive_path" ]; then
        log_error "Archive file does not exist: $archive_path"
        return 1
    fi

    log_info "Importing configuration from: $archive_path"

    # Create backup of current configuration
    local current_backup=$(backup_config)
    log_info "Current configuration backed up to: $current_backup"

    # Extract archive
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    tar -xzf "$archive_path"

    # Find extracted directory
    local extracted_dir=$(find . -maxdepth 1 -type d -name "*" | head -n 1)

    if [ -z "$extracted_dir" ]; then
        log_error "Could not find extracted configuration"
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy files
    if [ -d "$extracted_dir/config" ]; then
        cp -r "$extracted_dir/config"/* "$PROJECT_ROOT/config/"
        log_success "Configuration files imported"
    fi

    if [ -f "$extracted_dir/build.yaml" ]; then
        cp "$extracted_dir/build.yaml" "$PROJECT_ROOT/"
        log_success "Build configuration imported"
    fi

    if [ -d "$extracted_dir/docs" ]; then
        cp -r "$extracted_dir/docs" "$PROJECT_ROOT/"
        log_success "Documentation imported"
    fi

    if [ -d "$extracted_dir/scripts" ]; then
        cp -r "$extracted_dir/scripts" "$PROJECT_ROOT/"
        chmod +x "$PROJECT_ROOT/scripts"/*.sh
        log_success "Scripts imported"
    fi

    if [ -d "$extracted_dir/.vscode" ]; then
        cp -r "$extracted_dir/.vscode" "$PROJECT_ROOT/"
        log_success "VS Code configuration imported"
    fi

    if [ -d "$extracted_dir/.github" ]; then
        cp -r "$extracted_dir/.github" "$PROJECT_ROOT/"
        log_success "GitHub Actions imported"
    fi

    # Cleanup
    rm -rf "$temp_dir"

    log_success "Configuration import completed"
    log_info "You may need to run 'west update' to fetch dependencies"
}

# Show usage
show_usage() {
    cat << EOF
ZMK Eyelash Sofle Backup and Restore Utility

Usage: $0 <command> [options]

Commands:
  backup-config          Create backup of current configuration
  backup-firmware        Create backup of built firmware
  restore-config <dir>   Restore configuration from backup directory
  list-backups          List available backups
  compare <dir1> <dir2>  Compare two configuration backups
  export [name]          Export configuration as portable archive
  import <archive>       Import configuration from archive
  help                   Show this help message

Examples:
  $0 backup-config
  $0 backup-firmware
  $0 restore-config backups/config/20240101_120000
  $0 list-backups
  $0 compare backups/config/20240101_120000 backups/config/20240102_120000
  $0 export my_custom_config
  $0 import exports/my_custom_config.tar.gz

Backup locations:
  Configuration: $BACKUP_ROOT/config/
  Firmware: $BACKUP_ROOT/firmware/
  Exports: $BACKUP_ROOT/exports/
EOF
}

# Main execution
main() {
    create_backup_dirs

    case "${1:-}" in
        "backup-config")
            backup_config
            ;;
        "backup-firmware")
            backup_firmware
            ;;
        "restore-config")
            restore_config "$2"
            ;;
        "list-backups")
            list_backups
            ;;
        "compare")
            compare_configs "$2" "$3"
            ;;
        "export")
            export_config "$2"
            ;;
        "import")
            import_config "$2"
            ;;
        "help"|"--help"|"-h"|"")
            show_usage
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

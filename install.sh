#!/bin/bash

set -e

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/shell"
CONFIG_DIR="${HOME}/.config/shell"

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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Show help message
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Install shell configuration files."
    echo ""
    echo "Options:"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "Example:"
    echo "  $0"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option: $1" >&2
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Update repository if running from a git repo
update_repository() {
    if [[ -d "$SCRIPT_DIR/.git" ]]; then
        log_info "Detected git repository, checking for updates..."
        
        # Check if there are uncommitted changes
        if ! git -C "$SCRIPT_DIR" diff-index --quiet HEAD -- 2>/dev/null; then
            log_warning "Local changes detected in repository, skipping auto-update"
            log_info "Run 'git pull' manually if you want to update"
            return
        fi
        
        # Try to pull latest changes
        if git -C "$SCRIPT_DIR" pull --quiet 2>/dev/null; then
            log_success "Repository updated to latest version"
        else
            log_warning "Could not update repository (already up to date or no internet)"
        fi
    fi
}

# Install configuration files
install_configs() {
    # Check if source directory exists
    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_error "Source directory not found: $SOURCE_DIR"
        log_error "Please run this script from the repository root directory"
        exit 1
    fi
    
    # Find all .conf files in the shell directory
    local conf_files
    conf_files=$(find "$SOURCE_DIR" -name "*.conf" -type f)
    
    if [[ -z "$conf_files" ]]; then
        log_error "No .conf files found in $SOURCE_DIR"
        exit 1
    fi
    
    log_info "Creating configuration directory: $CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
    
    log_info "Installing configuration files..."
    while IFS= read -r file; do
        local filename=$(basename "$file")
        local dest="$CONFIG_DIR/$filename"
        
        log_info "Installing $filename..."
        if cp "$file" "$dest"; then
            log_success "Installed $filename"
        else
            log_error "Failed to install $filename"
            exit 1
        fi
    done <<< "$conf_files"
}

# Setup shell integration
setup_shell_integration() {
    local shell_rc=""
    local source_line='[[ -r "${HOME}/.config/shell/root.conf" ]] && source "${HOME}/.config/shell/root.conf"'
    
    # Detect shell and set appropriate RC file
    case "$SHELL" in
        */zsh)
            shell_rc="${HOME}/.zshrc"
            ;;
        */bash)
            shell_rc="${HOME}/.bashrc"
            ;;
        *)
            log_warning "Unsupported shell: $SHELL. You'll need to manually source the config."
            log_info "Add this line to your shell's RC file:"
            echo "    $source_line"
            return
            ;;
    esac
    
    # Check if already sourced
    if [[ -f "$shell_rc" ]] && grep -q "\.config/shell/root\.conf" "$shell_rc" 2>/dev/null; then
        log_info "Configuration already sourced in $shell_rc"
        return
    fi
    
    # Add source line to shell RC
    log_info "Adding configuration source to $shell_rc"
    echo "" >> "$shell_rc"
    echo "# Eduardo's shell configuration" >> "$shell_rc"
    echo "$source_line" >> "$shell_rc"
    log_success "Shell integration added to $shell_rc"
}

# Compile zsh files for better performance (if using zsh)
compile_zsh_configs() {
    if [[ "$SHELL" == */zsh ]] && command_exists zsh; then
        log_info "Compiling zsh configuration files for better performance..."
        zsh -c "
            autoload -Uz zrecompile
            for f in \"${CONFIG_DIR}\"/*.conf \"${CONFIG_DIR}\"/**/*.conf; do
                [[ -r \"\$f\" ]] || continue
                [[ \"\$f.zwc\" -nt \"\$f\" ]] || zrecompile -pq \"\$f\"
            done
        " 2>/dev/null || true
        log_success "Zsh configuration files compiled"
    fi
}

# Main installation function
main() {
    log_info "Installing Eduardo's shell configuration..."
    echo
    
    # Update repository if possible
    update_repository
    
    # Install configuration files
    install_configs
    
    # Setup shell integration
    setup_shell_integration
    
    # Compile zsh configs if applicable
    compile_zsh_configs
    
    echo
    log_success "Installation completed successfully!"
    echo
    log_info "To start using the configuration:"
    log_info "1. Restart your terminal, or"
    log_info "2. Run: source ~/.config/shell/root.conf"
    echo
    log_info "Available features:"
    log_info "- Git aliases (gst, gci, gco, gput, gget, etc.)"
    log_info "- Modular shell configuration system"
    log_info "- Easy configuration reloading with 'reload-configs'"
    echo
    log_info "To update in the future, simply run:"
    log_info "  ${SCRIPT_DIR}/install.sh"
    echo
}

# Run main function
main "$@"

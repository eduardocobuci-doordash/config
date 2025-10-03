#!/bin/bash

set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/eduardocobuci-doordash/config/main"
CONFIG_DIR="${HOME}/.config/shell"
BACKUP_DIR="${HOME}/.config/shell.backup.$(date +%Y%m%d_%H%M%S)"

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

# Download file from GitHub
download_file() {
    local url="$1"
    local dest="$2"
    
    if command_exists curl; then
        curl -fsSL "$url" -o "$dest"
    elif command_exists wget; then
        wget -q "$url" -O "$dest"
    else
        log_error "Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
}

# Create backup if config directory exists
backup_existing_config() {
    if [[ -d "$CONFIG_DIR" ]]; then
        log_warning "Existing configuration found at $CONFIG_DIR"
        log_info "Creating backup at $BACKUP_DIR"
        mkdir -p "$(dirname "$BACKUP_DIR")"
        cp -r "$CONFIG_DIR" "$BACKUP_DIR"
        log_success "Backup created successfully"
    fi
}

# Install configuration files
install_configs() {
    log_info "Creating configuration directory: $CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
    
    # List of files to download
    local files=(
        "shell/root.conf"
        "shell/00-env.conf" 
        "shell/01-git.conf"
    )
    
    log_info "Downloading configuration files..."
    for file in "${files[@]}"; do
        local filename=$(basename "$file")
        local dest="$CONFIG_DIR/$filename"
        local url="$REPO_URL/$file"
        
        log_info "Downloading $filename..."
        if download_file "$url" "$dest"; then
            log_success "Downloaded $filename"
        else
            log_error "Failed to download $filename"
            exit 1
        fi
    done
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
    if [[ -f "$shell_rc" ]] && grep -q "\.config/shell/root\.conf" "$shell_rc"; then
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
            for f in ~/.config/shell/*.conf ~/.config/shell/**/*.conf; do
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
    
    # Create backup of existing config
    backup_existing_config
    
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
    
    if [[ -d "$BACKUP_DIR" ]]; then
        log_info "Your previous configuration was backed up to:"
        log_info "$BACKUP_DIR"
    fi
}

# Run main function
main "$@"

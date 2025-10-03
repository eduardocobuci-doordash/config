# Eduardo's Shell Configuration

A modular shell configuration system with Git aliases and customizable environment settings.

## Quick Installation

One-line installation (works for both initial install and updates):

```bash
git clone https://github.com/eduardocobuci-doordash/config.git ~/.shell-config 2>/dev/null || (cd ~/.shell-config && git pull); ~/.shell-config/install.sh
```

This will:
- Clone the repository to `~/.shell-config/` (only on first run)
- Pull updates if already installed
- Install config files to `~/.config/shell/`
- Setup shell integration automatically
- Keep you in your current directory

Or step by step:

```bash
# First time
git clone https://github.com/eduardocobuci-doordash/config.git ~/.shell-config
~/.shell-config/install.sh

# Subsequent runs (to update)
~/.shell-config/install.sh
```

### Installing from a Fork or Different Branch

```bash
# Install from your fork
git clone https://github.com/yourusername/your-config.git ~/.shell-config
~/.shell-config/install.sh

# Install from a specific branch
git clone -b develop https://github.com/eduardocobuci-doordash/config.git ~/.shell-config
~/.shell-config/install.sh
```

## What's Included

- **Modular Configuration System**: Organized config files in `~/.config/shell/`
- **Git Aliases**: Convenient shortcuts like `gst` (git status), `gci` (git commit), `gput` (git push), etc.
- **Shell Integration**: Automatically sources configuration on shell startup
- **Safe Installation**: Backs up existing configurations before installing
- **Performance Optimized**: Compiles zsh configuration files for faster loading

## Features

### Git Aliases
- `gst` → `git status`
- `gci` → `git commit`
- `gco` → `git checkout`
- `gput` → `git push origin <current-branch>`
- `gget` → `git pull origin <current-branch>`
- `gtree` → `git log --oneline --graph --color --all --decorate`
- And more...

### Configuration Management
- `reload-configs` - Reload configuration without restarting shell
- Modular system allows easy addition of new configuration files
- Supports both bash and zsh

## Configuration Structure

Repository structure (`~/.shell-config/`):
```
~/.shell-config/
├── install.sh      # Installation/update script
├── README.md       # Documentation
└── shell/          # Configuration files (installed to ~/.config/shell/)
    ├── root.conf       # Main loader (sources all other configs)
    ├── 00-env.conf     # Environment and prompt settings
    ├── 01-git.conf     # Git aliases and configurations
    └── 02-dd.conf      # DoorDash-specific configurations
```

Installed configuration (`~/.config/shell/`):
```
~/.config/shell/
├── root.conf       # Main loader
├── 00-env.conf     # Environment settings
├── 01-git.conf     # Git aliases
└── 02-dd.conf      # DoorDash configs
```

## Updating Configuration

To update to the latest version, simply run the installer again:

```bash
~/.shell-config/install.sh
```

The installer will:
- Automatically pull the latest changes from git
- Install updated configuration files to `~/.config/shell/`
- Recompile configuration files for optimal performance

Alternatively, you can manually pull changes first:

```bash
git -C ~/.shell-config pull
~/.shell-config/install.sh
```

## Uninstallation

To remove the configuration:

```bash
# Remove the installed configuration
rm -rf ~/.config/shell

# Remove the repository
rm -rf ~/.shell-config
```

Then remove the source line from your shell's RC file (`~/.zshrc` or `~/.bashrc`):
```bash
# Remove this line:
[[ -r "${HOME}/.config/shell/root.conf" ]] && source "${HOME}/.config/shell/root.conf"
```

## Customization

You can add your own configuration files to `~/.config/shell/`. Any `.conf` files will be automatically loaded by the system.

Example:
```bash
echo 'alias ll="ls -la"' > ~/.config/shell/02-custom.conf
reload-configs
```


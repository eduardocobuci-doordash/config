# Eduardo's Shell Configuration

A modular shell configuration system with Git aliases and customizable environment settings.

## Quick Installation

Install with a single command (similar to Homebrew):

```bash
curl -fsSL https://raw.githubusercontent.com/educobuci/config/main/install.sh | bash
```

Or download and inspect the script first:

```bash
curl -fsSL https://raw.githubusercontent.com/educobuci/config/main/install.sh -o install.sh
chmod +x install.sh
./install.sh
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

## Manual Installation

If you prefer to install manually:

1. Clone this repository:
   ```bash
   git clone https://github.com/educobuci/config.git
   cd config
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

3. Restart your terminal or source the configuration:
   ```bash
   source ~/.config/shell/root.conf
   ```

## Configuration Structure

```
~/.config/shell/
├── root.conf       # Main loader (sources all other configs)
├── 00-env.conf     # Environment and prompt settings
└── 01-git.conf     # Git aliases and configurations
```

## Uninstallation

To remove the configuration:

```bash
rm -rf ~/.config/shell
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


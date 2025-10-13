# mdelapenya's dotfiles

> Automated macOS development environment setup

## What's included

- **Shell configurations**: Bash and Zsh with custom prompts, aliases, and functions
- **Git configuration**: Comprehensive git aliases and settings
- **Development tools**: 150+ Homebrew packages including Go, Docker, Kubernetes, cloud tools
- **Applications**: GUI apps via Homebrew Cask (Chrome, VSCode, Docker, etc.)
- **VSCode extensions**: Automated extension installation
- **Path management**: Automated setup for NVM, GVM, SDKMAN, pyenv

## Fresh Mac Installation

For a brand new Mac, run this single command:

```bash
git clone https://github.com/mdelapenya/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./install.sh
```

This will:
1. Install Homebrew (if not present)
2. Symlink all dotfiles to your home directory
3. Install all Homebrew formulas (brew.sh)
4. Install GUI applications (cask.txt)
5. Install additional tools: GVM (Go), SDKMAN (Java/JVM) (installs.sh)
6. Optionally install VSCode extensions (vscode.sh)

## Manual Installation Steps

### 1. Bootstrap dotfiles only

Symlinks configuration files without installing software:

```bash
git clone https://github.com/mdelapenya/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && source bootstrap.sh
```

To update dotfiles without confirmation:

```bash
cd ~/.dotfiles && set -- -f; source bootstrap.sh
```

### 2. Install development tools

```bash
./scripts/brew.sh      # Installs Homebrew formulas (CLI tools)
./scripts/installs.sh  # Installs gvm, SDKMAN (Java, Gradle, Maven)
./scripts/vscode.sh    # Installs VSCode extensions
```

## Directory Structure

```
.
├── bash/           # Bash-specific configs (.bash_profile, .bashrc, .bash_prompt)
├── zsh/            # Zsh-specific configs (.zshrc, .zprofile, .ohmyzsh)
├── git/            # Git configuration (.gitconfig)
├── system/         # Shell-agnostic configs (.aliases, .functions, .exports)
├── scripts/        # Installation scripts
│   ├── brew.sh         # Homebrew formula installer
│   ├── formulas.txt    # List of CLI tools to install
│   ├── cask.txt        # List of GUI apps to install
│   ├── installs.sh     # SDKMAN installer
│   ├── vscode.sh       # VSCode extension installer
│   └── vscode-ext.txt  # List of VSCode extensions
└── bootstrap.sh    # Dotfile symlink script
```

## Customization

### Company-specific configuration
Create a `~/.company` file for work-specific settings you don't want to commit:

```bash
# Example ~/.company
export WORK_EMAIL="you@company.com"
alias vpn="connect-to-work-vpn"
```

This file is automatically sourced by shell profiles but ignored by git.

### Private configuration
Create a `~/.extra` file for private settings (API keys, tokens, etc.):

```bash
# Example ~/.extra
export GITHUB_TOKEN="ghp_xxx"
export AWS_PROFILE="personal"
```

### Custom PATH
Create a `~/.path` file to extend your PATH:

```bash
# Example ~/.path
export PATH="$HOME/custom-tools/bin:$PATH"
```

## Key Features

### Aliases
- **Navigation**: `..`, `...`, `..3`, `..4` for quick directory traversal
- **Git**: `g` (git), shortcuts for common commands
- **Docker/K8s**: `d` (docker), `k` (kubectl), `dps`, `dpsa`
- **Utilities**: `update` (system-wide updates), `cleanup` (remove .DS_Store)

See `system/.aliases` for the full list.

### Git Aliases
- `git lg`: Beautiful log graph
- `git publish`: Push current branch to origin
- `git syncup`: Fetch and pull from upstream/main
- `git delete-merged-branches`: Clean up old branches

See `git/.gitconfig` for all aliases.

## Requirements

- macOS (tested on Apple Silicon and Intel)
- Git (pre-installed on macOS)
- Internet connection

## Updating

To pull the latest dotfiles and re-symlink:

```bash
cd ~/.dotfiles && git pull && source bootstrap.sh
```

To update installed software:

```bash
cd ~/.dotfiles && ./scripts/brew.sh
```

## Troubleshooting

### Shell profile issues
If tools like `gvm`, `nvm`, or `sdkman` aren't found, ensure they're installed:

```bash
# Check if installed
ls ~/.gvm ~/.nvm ~/.sdkman

# If missing, run:
./scripts/installs.sh  # For SDKMAN
brew install nvm       # For NVM
```

### Python/pyenv conflicts
The aliases automatically detect pyenv. If you have issues:

```bash
which python  # Should show pyenv shim if installed
pyenv versions  # Check installed versions
```

### Homebrew path issues
On Apple Silicon, Homebrew installs to `/opt/homebrew`. The profiles handle this automatically.

## Credits

Originally forked from https://github.com/v1v/dotfiles.git

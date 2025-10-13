# mdelapenya's dotfiles

> Automated macOS development environment setup

## Using These Dotfiles

### Fork and Customize

This repository is designed to be forked and customized for your own use:

1. **Fork this repository** on GitHub

2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

3. **Customize the following files:**
   - **`git/.gitconfig`** - Update `[user]` section with your name, email, and GPG key
   - **`scripts/formulas.txt`** - Add/remove Homebrew CLI tools
   - **`scripts/cask.txt`** - Add/remove GUI applications
   - **`scripts/backup-mac.sh`** - Modify `BACKUP_ITEMS` array for your backup needs
   - **`system/.aliases`** - Add your own aliases and shortcuts

4. **Run the installer:**
   ```bash
   ./install.sh
   ```

5. **Set up GPG signing** (optional):
   ```bash
   ./scripts/setup-gpg.sh
   ```

### What You Don't Need to Change

The following work out-of-the-box without customization:
- All shell scripts and functions
- Bootstrap and installation logic
- Backup/restore functionality
- Directory structure

## What's included

- **Shell configurations**: Bash and Zsh with custom prompts, aliases, and functions
- **Git configuration**: Comprehensive git aliases and settings
- **Development tools**: 150+ Homebrew packages including Go, Docker, Kubernetes, cloud tools
- **Applications**: GUI apps via Homebrew Cask (Chrome, VSCode, Docker, etc.)
- **VSCode extensions**: Automated extension installation
- **Path management**: Automated setup for NVM, GVM, SDKMAN, pyenv

## Transferring to a New Mac

### Quick Transfer Process

**On your current Mac (backup):**
```bash
# Clone dotfiles first (if not already done)
git clone https://github.com/mdelapenya/dotfiles.git ~/.dotfiles && cd ~/.dotfiles

# Backup to another Mac or NAS
backup-mac user@newmac:/backups
# or
backup-mac nas:/volume1/backups/laptop
```

**On your new Mac (restore):**
```bash
# Clone dotfiles
git clone https://github.com/mdelapenya/dotfiles.git ~/.dotfiles && cd ~/.dotfiles

# Restore from backup
restore-mac user@oldmac:/backups
# or
restore-mac nas:/volume1/backups/laptop

# Install dotfiles and tools
./install.sh
```

### What Gets Backed Up

The backup script (`scripts/backup-mac.sh`) transfers all items defined in the `BACKUP_ITEMS` array:
- **SSH keys** (`~/.ssh/`)
- **GPG keys** (`~/.gnupg/`)
- **Private configs** (`~/.extra`, `~/.company`, `~/.gitconfig.local`)
- **Shell configs** (`~/.zshrc`, `~/.bash_profile`, `~/.bashrc`, `~/.oh-my-zsh`, shell history)
- **Development tools** (`~/.config`, `~/.local`, `~/.docker`, `~/.aws`, `~/.kube`)
- **Version managers** (`~/.sdkman`, `~/.nvm`, `~/.gvm`, `~/.pyenv`)
- **Personal files** (`~/Documents`, `~/Pictures`, `~/Movies`, `~/sourcecode`)

**Customizing:** To add or remove items from the backup, edit the `BACKUP_ITEMS` array at the top of `scripts/backup-mac.sh`.

### Backup/Restore Features

- **SSH setup**: Automatically tests connection and offers to copy SSH keys if needed
- **Safety**: Restore offers to skip existing files (won't overwrite by default)
- **Progress**: Shows transfer progress and size estimates
- **Exclusions**: Automatically excludes `.DS_Store`, `node_modules`, `.git`, logs, caches, `.docker/models`

### SSH Key Authentication for NAS/Remote Hosts

If passwordless SSH authentication fails after copying your key, check the following:

1. **Remote SSH server configuration**:
   - Verify public key authentication is enabled in the SSH server config
   - **NAS devices** (Synology, QNAP, etc.) often require enabling this in their web UI
   - Example: Synology DSM → Control Panel → Terminal & SNMP → Enable "SSH public key authentication"

2. **File permissions on remote host**:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

3. **SSH server config** (usually `/etc/ssh/sshd_config`):
   ```
   PubkeyAuthentication yes
   AuthorizedKeysFile .ssh/authorized_keys
   ```

The backup script will automatically verify passwordless authentication after copying your key and warn you if it's not working.

### Manual Backup/Restore

Run scripts directly:
```bash
# Backup
./scripts/backup-mac.sh user@host:/path

# Restore
./scripts/restore-mac.sh user@host:/path
```

## Fresh Mac Installation

For a brand new Mac without an existing backup, run this single command:

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

## GPG Commit Signing

This dotfiles setup includes GPG commit signing configuration. To set up GPG signing for your commits:

### Automated Setup

Run the GPG setup script:

```bash
./scripts/setup-gpg.sh
```

This script will:
1. Check for existing GPG keys
2. If keys exist, prompt you to either:
   - Use an existing key (you'll be asked to enter the key ID)
   - Create a new key
3. Generate a new 4096-bit RSA key (if creating new)
4. Configure git to use GPG signing
5. Export your public key for GitHub/GitLab
6. Update shell profiles with GPG_TTY

The script handles both new setups and existing key configurations automatically.

### Manual Setup

If you prefer to set up GPG manually:

```bash
# 1. Generate a new GPG key
gpg --full-generate-key
# Choose: RSA and RSA, 4096 bits, key doesn't expire
# Use your git email: mdelapenya@gmail.com

# 2. List keys and copy the key ID
gpg --list-secret-keys --keyid-format=long
# The key ID is after "rsa4096/" (e.g., 66E882E52DF1B461)

# 3. Configure git
git config --global user.signingkey <KEY_ID>
git config --global commit.gpgsign true
git config --global gpg.program $(which gpg)

# 4. Export public key for GitHub
gpg --armor --export <KEY_ID>
# Copy the output and add to: https://github.com/settings/keys

# 5. Test signing
git commit --allow-empty -m "Test GPG signing"
git log --show-signature -1
```

### Add GPG Key to GitHub

1. Export your public key: `gpg --armor --export <KEY_ID>`
2. Go to [GitHub GPG Keys Settings](https://github.com/settings/keys)
3. Click "New GPG key"
4. Paste your public key
5. All commits will now show as "Verified" ✅

### Troubleshooting GPG

**"gpg: signing failed: Inappropriate ioctl for device"**
```bash
export GPG_TTY=$(tty)
# Add to your shell profile permanently
echo 'export GPG_TTY=$(tty)' >> ~/.zshrc  # or ~/.bash_profile
```

**"No secret key"**
```bash
# Verify key exists
gpg --list-secret-keys --keyid-format=long

# Ensure git is configured with the correct key ID
git config --global user.signingkey
```

**Passphrase prompt issues**
```bash
# Install pinentry for GUI password prompt
brew install pinentry-mac

# Configure GPG to use it
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent
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

## Contributing

Found a bug or want to suggest an improvement? Please open an issue or pull request!

## License

Feel free to fork and modify this project for your own use.

## Credits

Originally forked from https://github.com/v1v/dotfiles.git

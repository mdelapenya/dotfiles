# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a macOS dotfiles repository for automated development environment setup. It manages shell configurations (Bash/Zsh), Git settings, Homebrew packages (~174 formulas, 14 casks), and development tools (GVM, SDKMAN, VSCode extensions). The repository includes sophisticated backup/restore scripts for migrating to new Macs.

## Key Commands

### Installation & Setup

```bash
# Full installation (new Mac setup)
./install.sh

# Bootstrap only (symlink dotfiles without installing software)
source bootstrap.sh

# Force bootstrap without confirmation
set -- -f; source bootstrap.sh

# Install Homebrew packages
./scripts/brew.sh

# Install version managers (GVM, SDKMAN)
./scripts/installs.sh

# Install VSCode extensions
./scripts/vscode.sh
```

### Backup & Restore

```bash
# Backup to remote host or NAS
./scripts/backup-mac.sh user@host:/backup/path
backup-mac nas:/volume1/backups/laptop  # via alias

# Restore from backup
./scripts/restore-mac.sh user@host:/backup/path
restore-mac nas:/volume1/backups/laptop  # via alias
```

### Updating

```bash
# Update dotfiles and re-symlink
cd ~/.dotfiles && git pull && source bootstrap.sh

# Update installed software
cd ~/.dotfiles && ./scripts/brew.sh
```

## Architecture

### Bootstrap System (`bootstrap.sh`)

The bootstrap script creates symlinks from dotfiles in this repo to the home directory. It:
- Finds all dotfiles (files starting with `.`) in the first two directory levels
- Creates symlinks using `ln -fs` to force-overwrite existing files
- Sources `scripts/common.sh` for utility functions (colored output, confirmations)
- Pulls latest changes from `origin main` before symlinking

### Installation Flow (`install.sh`)

The main installer orchestrates a complete Mac setup:
1. Installs Homebrew (handles Apple Silicon path: `/opt/homebrew`)
2. Runs `bootstrap.sh` to symlink dotfiles
3. Runs `scripts/brew.sh` to install packages from `formulas.txt` and `cask.txt`
4. Runs `scripts/installs.sh` to install GVM and SDKMAN
5. Optionally runs `scripts/vscode.sh` to install extensions from `vscode-ext.txt`

Each step uses interactive confirmations unless `--force` or `-f` flag is passed.

### Backup/Restore System

**Backup (`scripts/backup-mac.sh`):**
- Defines `BACKUP_ITEMS` array with critical paths (SSH keys, GPG keys, configs, development tools, personal files)
- Tests SSH connectivity and offers to set up passwordless authentication via `ssh-copy-id`
- Uses `rsync` with progress, compression, and timeout handling
- Excludes `.DS_Store`, `node_modules`, logs, caches, `.docker/models`
- Handles both remote hosts and NAS devices (with Synology-specific SSH auth notes)

**Restore (`scripts/restore-mac.sh`):**
- Lists backup contents before restoring
- Offers choice to overwrite or skip existing files (`--ignore-existing`)
- Uses `rsync` to restore to home directory
- Provides post-restore verification steps

**SSH Authentication Notes:** NAS devices often require enabling "SSH public key authentication" in their web UI. The scripts include detailed troubleshooting for Synology/QNAP devices.

### Directory Structure

```
bash/           Bash configs (.bash_profile, .bashrc, .bash_prompt)
zsh/            Zsh configs (.zshrc, .zprofile, .ohmyzsh)
git/            Git config (.gitconfig with extensive aliases)
system/         Shell-agnostic configs (.aliases, .functions, .exports, .company, .extra)
scripts/        Installation and management scripts
  ├── brew.sh           Homebrew installer
  ├── formulas.txt      CLI tools list (174 packages)
  ├── cask.txt          GUI apps list (14 apps)
  ├── installs.sh       GVM and SDKMAN installer
  ├── vscode.sh         VSCode extension installer
  ├── vscode-ext.txt    VSCode extensions list (21 extensions)
  ├── backup-mac.sh     Backup script
  ├── restore-mac.sh    Restore script
  ├── setup-gpg.sh      GPG setup for commit signing
  └── common.sh         Shared utility functions
```

### Configuration Layering

Shell profiles source files in this order:
1. Shell-specific config (`.bash_profile` or `.zprofile`)
2. System-wide configs (`.exports`, `.aliases`, `.functions`)
3. Private configs (`.extra` for secrets, `.company` for work settings)
4. Version manager initialization (NVM, GVM, SDKMAN, pyenv)

Private files (`.extra`, `.company`, `.gitconfig.local`) are gitignored but backed up by `backup-mac.sh`.

### Key Aliases & Functions

**Navigation:** `..`, `...`, `..3`, `..4` for directory traversal

**Tools:** `g` (git), `d` (docker), `k` (kubectl), `dps`/`dpsa` (docker ps)

**Backup:** `backup-mac` and `restore-mac` aliases point to scripts

**Python:** Automatically uses pyenv if available, falls back to system Python

**Git Aliases (in `.gitconfig`):**
- `git lg` - Beautiful graph log
- `git publish` - Push current branch to origin
- `git syncup` - Fetch and pull from upstream/main
- `git delete-merged-branches` - Clean up merged branches
- `git go <branch>` - Switch to branch, creating if needed

### Homebrew Package Management

**Installation (`scripts/brew.sh`):**
- Updates and upgrades Homebrew
- Installs GNU coreutils (modern versions of Unix tools)
- Installs modern Bash and registers it in `/etc/shells`
- Taps custom repositories (esolitos/ipa for sshpass, tinygo-org/tools)
- Reads `formulas.txt` line-by-line to install CLI tools
- Reads `cask.txt` line-by-line to install GUI apps
- Installs Vagrant plugins: `vagrant-vbguest`, `vagrant-disksize`
- Installs Yubikey tools: gnupg, yubikey-personalization, ykman, pinentry-mac
- Runs `brew cleanup` to remove outdated versions

**Customization:** To add packages, append them to `scripts/formulas.txt` (CLI) or `scripts/cask.txt` (GUI apps).

### GPG Commit Signing

The `.gitconfig` includes GPG signing configuration. Use `./scripts/setup-gpg.sh` to:
- Check for existing GPG keys or generate new 4096-bit RSA key
- Configure git to use the key for signing
- Export public key for GitHub/GitLab
- Add `GPG_TTY` to shell profiles

### Version Managers

**GVM (Go):** Installed to `/usr/local/bin/gvm`, automatically initializes Go 1.24.7

**SDKMAN (Java/JVM):** Installed to `~/.sdkman`, provides Java, Gradle, Maven, etc.

**NVM (Node):** Installed via Homebrew, configured in shell profiles

**pyenv (Python):** Backed up/restored, aliases detect and use pyenv if available

## Development Workflow

1. **Modifying dotfiles:** Edit files in repo subdirectories, then run `source bootstrap.sh` to re-symlink
2. **Adding packages:** Append to `scripts/formulas.txt` or `scripts/cask.txt`, run `./scripts/brew.sh`
3. **Testing changes:** Use `set -- -f; source bootstrap.sh` to force-update without prompts
4. **Customizing for fork:** Update `git/.gitconfig` user section, modify package lists, adjust `BACKUP_ITEMS` array

## Important Notes

- **Shell profiles:** The bootstrap script symlinks ALL dotfiles in the first two directory levels. Be careful not to add unintended files.
- **Homebrew location:** Apple Silicon uses `/opt/homebrew`, Intel uses `/usr/local/bin`. Shell profiles handle this automatically.
- **Private configs:** `.extra` and `.company` are sourced but gitignored. Create these for secrets/work settings.
- **Backup customization:** Edit `BACKUP_ITEMS` array in `scripts/backup-mac.sh` (around line 42) to change what gets backed up.
- **NAS authentication:** Synology/QNAP devices require enabling "SSH public key authentication" in web UI for passwordless access.

## Troubleshooting

### Restore Script Hangs or Fails

**Issue:** `restore-mac.sh` hangs during transfer or shows "unknown option" errors

**Cause:** macOS ships with ancient rsync 2.6.9 (from 2006) which lacks modern options used by the restore script (--info=progress2, --no-inc-recursive, etc.)

**Solution:** Install modern rsync via Homebrew:
```bash
brew install rsync
# Verify it's using the Homebrew version
which rsync  # Should show /opt/homebrew/bin/rsync
rsync --version  # Should show version >= 3.1.0
```

The Homebrew rsync will be prioritized in PATH automatically. The restore script requires rsync >= 3.1.0 for:
- `--info=progress2` - Overall progress display (%, rate, ETA)
- `--no-inc-recursive` - Upfront directory scanning to prevent apparent hangs
- Modern timeout and compression options

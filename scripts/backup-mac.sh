#!/usr/bin/env bash

################################################################################
# backup-mac.sh - Backup essential Mac files to another machine or NAS
#
# Usage:
#   ./scripts/backup-mac.sh <destination>
#   ./scripts/backup-mac.sh user@hostname:/backup/path
#   ./scripts/backup-mac.sh nas:/volume1/backups/laptop
################################################################################

set -e

cd "$(dirname "$0")/.."
DOTFILES_ROOT="$(pwd)"

# Source common functions
source "${DOTFILES_ROOT}/scripts/common.sh"

# Backup/Restore items list
BACKUP_ITEMS=(
  # SSH and GPG keys
  "$HOME/.ssh"
  "$HOME/.gnupg"

  # Shell configurations
  "$HOME/.zprofile"
  "$HOME/.zshrc"
  "$HOME/.bash_profile"
  "$HOME/.bashrc"
  "$HOME/.oh-my-zsh"
  "$HOME/.zsh_history"
  "$HOME/.bash_history"

  # Private dotfiles (not in repo)
  "$HOME/.extra"
  "$HOME/.company"
  "$HOME/.gitconfig.local"

  # Development tool configs
  "$HOME/.config"
  "$HOME/.local"
  "$HOME/.docker"
  "$HOME/.aws"
  "$HOME/.kube"

  # Version managers
  "$HOME/.sdkman"
  "$HOME/.nvm"
  "$HOME/.gvm"
  "$HOME/.pyenv"

  # Application data
  "$HOME/Documents"
  "$HOME/Pictures"
  "$HOME/Movies"
  "$HOME/sourcecode"
)

################################################################################
# Functions
################################################################################

function show_usage() {
  echo "Usage: $0 <destination>"
  echo ""
  echo "Examples:"
  echo "  $0 user@192.168.1.100:/backups"
  echo "  $0 nas:/volume1/backups/laptop"
  echo ""
  echo "The destination should be an rsync-compatible path."
  exit 1
}

function test_ssh_connection() {
  local host=$1
  info "Testing SSH connection to $host..."

  # Extract hostname from user@host format
  local ssh_host
  if [[ $host =~ @ ]]; then
    ssh_host="$host"
  else
    ssh_host="$host"
  fi

  # Try SSH connection (timeout after 5 seconds)
  if ssh -o ConnectTimeout=5 -o BatchMode=yes "$ssh_host" "echo 'Connection successful'" &>/dev/null; then
    success "SSH connection successful"
    return 0
  else
    info "SSH connection failed or requires setup"

    if confirm "Do you want to copy your SSH key to the remote host?"; then
      info "Copying SSH key to $ssh_host..."
      ssh-copy-id "$ssh_host" || fail "Failed to copy SSH key"
      success "SSH key copied successfully"
      return 0
    else
      fail "Cannot proceed without SSH access"
    fi
  fi
}

################################################################################
# Main
################################################################################

header "Mac Backup Script"

# Check arguments
if [ $# -eq 0 ]; then
  fail "Missing destination argument\n$(show_usage)"
fi

DESTINATION="$1"

# Extract hostname for SSH test
if [[ $DESTINATION =~ ^([^@]+@)?([^:]+): ]]; then
  HOST="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
  test_ssh_connection "$HOST"
fi

# Filter out items that don't exist (BACKUP_ITEMS loaded from common.sh)
EXISTING_ITEMS=()
for item in "${BACKUP_ITEMS[@]}"; do
  if [ -e "$item" ]; then
    EXISTING_ITEMS+=("$item")
  fi
done

echo ""
info "Found ${#EXISTING_ITEMS[@]} items to backup:"
for item in "${EXISTING_ITEMS[@]}"; do
  echo "  • $(basename "$item")"
done
echo ""

# Estimate size
info "Calculating backup size..."
TOTAL_SIZE=$(du -sh "${EXISTING_ITEMS[@]}" 2>/dev/null | tail -n1 | awk '{print $1}')
info "Total size: $TOTAL_SIZE"
echo ""

if ! confirm "Proceed with backup to $DESTINATION?"; then
  info "Backup cancelled"
  exit 0
fi

# Perform backup
header "Starting Backup"

info "Backing up to: $DESTINATION"
echo ""

# Use rsync with progress and archive mode
rsync -av --progress \
  --exclude='.DS_Store' \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='*.log' \
  --exclude='Cache' \
  --exclude='cache' \
  "${EXISTING_ITEMS[@]}" \
  "$DESTINATION/" || fail "Backup failed"

echo ""
success "Backup completed successfully!"
echo ""
info "Files backed up to: $DESTINATION"
info "To restore on a new Mac, run: ./scripts/restore-mac.sh $DESTINATION"

#!/usr/bin/env bash

################################################################################
# restore-mac.sh - Restore essential Mac files from backup
#
# Usage:
#   ./scripts/restore-mac.sh <source>
#   ./scripts/restore-mac.sh user@hostname:/backup/path
#   ./scripts/restore-mac.sh nas:/volume1/backups/laptop
################################################################################

set -e

cd "$(dirname "$0")/.."
DOTFILES_ROOT="$(pwd)"

# Source common functions
source "${DOTFILES_ROOT}/scripts/common.sh"

################################################################################
# Functions
################################################################################

function show_usage() {
  echo "Usage: $0 <source>"
  echo ""
  echo "Examples:"
  echo "  $0 user@192.168.1.100:/backups"
  echo "  $0 nas:/volume1/backups/laptop"
  echo ""
  echo "The source should be an rsync-compatible path where backup was stored."
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
    fail "Cannot connect to $ssh_host. Please ensure SSH access is configured."
  fi
}

################################################################################
# Main
################################################################################

header "Mac Restore Script"

# Check arguments
if [ $# -eq 0 ]; then
  show_usage
fi

SOURCE="$1"

# Extract hostname for SSH test
if [[ $SOURCE =~ ^([^@]+@)?([^:]+): ]]; then
  HOST="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
  test_ssh_connection "$HOST"
fi

# Warning about overwriting files
echo ""
info "⚠️  WARNING: This will restore files from backup to your home directory"
info "Existing files may be overwritten!"
echo ""

if ! confirm "Do you want to proceed with restore from $SOURCE?"; then
  info "Restore cancelled"
  exit 0
fi

# Show what will be restored
header "Checking Backup Contents"

info "Listing backup contents from: $SOURCE"
echo ""

# List available items in backup (without trailing slash to list directory names)
rsync --list-only "$SOURCE" 2>/dev/null | tail -n +2 || fail "Failed to list backup contents"

echo ""
if ! confirm "Proceed with restoring these files to your home directory?"; then
  info "Restore cancelled"
  exit 0
fi

# Perform restore
header "Starting Restore"

info "Restoring from: $SOURCE"
echo ""

# Use rsync to restore files
# --ignore-existing: don't overwrite existing files (safer option)
# Remove --ignore-existing if you want to overwrite
if confirm "Do you want to OVERWRITE existing files? (If no, existing files will be skipped)"; then
  RSYNC_OPTS="-av --progress"
  info "Mode: Overwrite existing files"
else
  RSYNC_OPTS="-av --progress --ignore-existing"
  info "Mode: Skip existing files"
fi

echo ""

rsync $RSYNC_OPTS \
  --partial \
  --timeout=300 \
  --compress \
  -e "ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3" \
  --exclude='.DS_Store' \
  --exclude='node_modules' \
  --exclude='*.log' \
  --exclude='Cache' \
  --exclude='cache' \
  --exclude='.docker/models' \
  "$SOURCE/" \
  "$HOME/" || fail "Restore failed"

echo ""
success "Restore completed successfully!"
echo ""
info "Important next steps:"
echo "  1. Verify SSH keys: ls -la ~/.ssh"
echo "  2. Verify GPG keys: gpg --list-secret-keys"
echo "  3. Test git signing: cd <repo> && git commit --allow-empty -m 'Test'"
echo "  4. Reload shell: exec \$SHELL -l"
echo ""
info "If you haven't already, run the dotfiles installer:"
echo "  ./install.sh"

#!/usr/bin/env bash

################################################################################
# setup-gpg.sh - Generate GPG key and configure git for commit signing
################################################################################

set -e

cd "$(dirname "$0")/.."
DOTFILES_ROOT="$(pwd)"

# Source common functions
source "${DOTFILES_ROOT}/scripts/common.sh"

function show_next_steps() {
  local KEY_ID=$1

  header "Next Steps"
  echo ""
  info "1. Your public key (copy this to GitHub/GitLab):"
  echo ""
  gpg --armor --export "$KEY_ID"
  echo ""
  info "2. Add to GitHub:"
  echo "   • Go to: https://github.com/settings/keys"
  echo "   • Click 'New GPG key'"
  echo "   • Paste the public key above"
  echo ""
  info "3. Test signing:"
  echo "   • git commit --allow-empty -m 'Test GPG signing'"
  echo "   • git log --show-signature -1"
  echo ""
  info "4. Restart your terminal or run: exec \$SHELL -l"
  echo ""
  success "GPG setup complete! 🔐"
}

function configure_git() {
  local KEY_ID=$1

  info "Configuring git to use GPG signing..."
  git config --global user.signingkey "$KEY_ID"
  git config --global commit.gpgsign true
  git config --global gpg.program "$(which gpg)"
  success "Git configured for GPG signing"
  echo ""

  # Update GPG_TTY in shell profiles if not present
  for profile in ~/.bash_profile ~/.zshrc ~/.zprofile; do
    if [ -f "$profile" ]; then
      if ! grep -q "export GPG_TTY" "$profile"; then
        echo "" >> "$profile"
        echo "# GPG signing" >> "$profile"
        echo "export GPG_TTY=\$(tty)" >> "$profile"
        success "Added GPG_TTY to $profile"
      fi
    fi
  done
}

################################################################################
# Main
################################################################################

header "GPG Setup for Git Commit Signing"

# Check if GPG is installed
if ! command_exists gpg; then
  fail "GPG is not installed. Run: brew install gnupg"
fi

# Get git user info
GIT_NAME=$(git config --global user.name || echo "")
GIT_EMAIL=$(git config --global user.email || echo "")

if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
  fail "Git user.name and user.email must be configured first"
fi

info "Using git identity: $GIT_NAME <$GIT_EMAIL>"
echo ""

# Check for existing GPG keys
EXISTING_KEYS=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -c "^sec" || echo "0")

if [ "$EXISTING_KEYS" != "0" ]; then
  echo "Found $EXISTING_KEYS existing GPG key(s):"
  gpg --list-secret-keys --keyid-format=long
  echo ""

  if ! confirm "Do you want to create a new key anyway?"; then
    echo ""
    read -p "Enter the key ID you want to use (from above): " KEY_ID

    if [ -z "$KEY_ID" ]; then
      fail "No key ID provided"
    fi

    # Verify the key exists
    if ! gpg --list-secret-keys "$KEY_ID" &> /dev/null; then
      fail "Key $KEY_ID not found"
    fi

    info "Using existing key: $KEY_ID"
    echo ""

    configure_git "$KEY_ID"
    show_next_steps "$KEY_ID"
    exit 0
  fi
fi

# Generate new GPG key
info "Generating new GPG key for $GIT_EMAIL..."
echo ""
info "You'll be prompted to set a passphrase (optional but recommended)"
echo ""

gpg --batch --passphrase '' --quick-generate-key "$GIT_NAME <$GIT_EMAIL>" rsa4096 sign 0

success "GPG key generated successfully"
echo ""

# Get the new key ID
KEY_ID=$(gpg --list-secret-keys --keyid-format=long | grep "^sec" | tail -n1 | awk '{print $2}' | cut -d'/' -f2)

if [ -z "$KEY_ID" ]; then
  fail "Could not determine key ID"
fi

info "Key ID: $KEY_ID"
echo ""

configure_git "$KEY_ID"
show_next_steps "$KEY_ID"

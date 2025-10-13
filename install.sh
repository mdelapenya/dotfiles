#!/usr/bin/env bash

################################################################################
# install.sh - Complete dotfiles installation for new Mac setup
################################################################################

set -e  # Exit on error

cd "$(dirname "${BASH_SOURCE}")";
DOTFILES_ROOT="$(pwd)"

# Source common functions
source "${DOTFILES_ROOT}/scripts/common.sh"

################################################################################
# Main Installation Flow
################################################################################

header "mdelapenya's dotfiles installer"

info "This script will set up your Mac with:"
echo "  • Dotfile symlinks (bash, zsh, git configs)"
echo "  • Homebrew and 150+ development tools"
echo "  • GUI applications (Chrome, VSCode, etc.)"
echo "  • GVM (Go Version Manager) and SDKMAN (Java/JVM tools)"
echo "  • Optional: VSCode extensions"
echo ""

if [ "$1" != "--force" ] && [ "$1" != "-f" ]; then
  if ! confirm "Continue with installation?"; then
    info "Installation cancelled"
    exit 0
  fi
fi

# Step 1: Install Homebrew
header "Step 1: Homebrew"

if ! command_exists brew ; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || fail "Homebrew installation failed"

  # Add Homebrew to PATH for Apple Silicon
  if [[ $(uname -m) == 'arm64' ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  success "Homebrew installed"
else
  success "Homebrew already installed"
fi

# Step 2: Bootstrap dotfiles
header "Step 2: Symlink dotfiles"

info "Creating symlinks for dotfiles..."
source "${DOTFILES_ROOT}/bootstrap.sh" -f || fail "Bootstrap failed"
success "Dotfiles symlinked to home directory"

# Step 3: Install Homebrew formulas and casks
header "Step 3: Install development tools"

info "This will install 150+ CLI tools and GUI applications"
info "This may take 15-30 minutes depending on your connection..."
echo ""

if confirm "Install Homebrew packages now?"; then
  "${DOTFILES_ROOT}/scripts/brew.sh" || fail "Homebrew packages installation failed"
  success "Development tools installed"
else
  info "Skipped Homebrew packages (run ./scripts/brew.sh manually later)"
fi

# Step 4: Install additional tools
header "Step 4: Install additional tools (GVM, SDKMAN)"

if confirm "Install GVM (Go) and SDKMAN (Java, Gradle, Maven)?"; then
  "${DOTFILES_ROOT}/scripts/installs.sh" || fail "Tools installation failed"
  success "Additional tools installed"
else
  info "Skipped additional tools (run ./scripts/installs.sh manually later)"
fi

# Step 5: Install VSCode extensions
header "Step 5: Install VSCode extensions"

if command_exists code ; then
  if confirm "Install VSCode extensions?"; then
    "${DOTFILES_ROOT}/scripts/vscode.sh" || fail "VSCode extensions installation failed"
    success "VSCode extensions installed"
  else
    info "Skipped VSCode extensions (run ./scripts/vscode.sh manually later)"
  fi
else
  info "VSCode not found - skipping extension installation"
  info "After installing VSCode, run: ./scripts/vscode.sh"
fi

# Final steps
header "Installation Complete!"

echo ""
success "Your Mac is now configured with mdelapenya's dotfiles"
echo ""
info "Next steps:"
echo "  1. Restart your terminal (or run: exec \$SHELL -l)"
echo "  2. If you use zsh, configure Oh My Zsh: sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
echo "  3. Create ~/.extra for private configuration (tokens, keys)"
echo "  4. Create ~/.company for work-specific settings"
echo ""
info "Useful commands:"
echo "  • Update dotfiles: cd ~/.dotfiles && git pull && source bootstrap.sh"
echo "  • Update software: cd ~/.dotfiles && ./scripts/brew.sh"
echo "  • View aliases: cat ~/.aliases"
echo ""

success "Happy coding! 🚀"

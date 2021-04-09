#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names
# Install a modern version of Bash.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install `wget` with IRI support.
brew install wget --with-iri

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi
brew install grep
brew install screen
brew install gmp

brew install jq

# Install other useful binaries.
brew install ack
brew install tree

brew cask install google-cloud-sdk
brew install maven
brew install vagrant
brew cask install virtualbox
vagrant plugin install vagrant-vbguest vagrant-disksize

brew install hub
brew install pre-commit

brew install spectacle
brew install visual-studio-code
brew install intellij-idea-ce
brew install rescuetime
brew install kubectl
brew install brave-browser
brew install docker
brew install google-cloud-sdk
brew install vault
brew install htop
brew install homebrew/cask/docker

# Yubikey
brew install gnupg yubikey-personalization hopenpgp-tools ykman pinentry-mac

# Remove outdated versions from the cellar.
brew cleanup

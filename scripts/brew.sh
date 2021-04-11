#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

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

# Install a modern version of Bash.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

brew cask install google-cloud-sdk
brew cask install virtualbox

# sshpass
brew tap esolitos/ipa

while read f; do
  brew install $f
done <${BASEDIR}/formulas.txt

vagrant plugin install vagrant-vbguest vagrant-disksize

vagrant plugin install vagrant-vbguest vagrant-disksize

# Yubikey
brew install gnupg yubikey-personalization hopenpgp-tools ykman pinentry-mac

# Remove outdated versions from the cellar.
brew cleanup

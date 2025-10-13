#!/bin/bash

# Install GVM
curl -sL -o /usr/local/bin/gvm https://github.com/andrewkroh/gvm/releases/download/v0.5.2/gvm-darwin-all
chmod +x /usr/local/bin/gvm
eval "$(gvm 1.24.7)"
go version

# Install SDKMAN
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk version

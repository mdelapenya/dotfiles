#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";
DOTFILES_ROOT="`pwd`"

# Source common functions
source "${DOTFILES_ROOT}/scripts/common.sh"

git pull origin main

function doIt() {
  for source in `find ${DOTFILES_ROOT} -maxdepth 2 -type f -name ".*"`; do
  dest="$HOME/`basename ${source}`"
	link_files $source $dest
  done
}

function link_files() {
  ln -fs $1 $2
  success "Linked $1 to $2"
}

if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
  doIt
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
	doIt;
  fi
fi
unset doIt;

if ! command -v brew &> /dev/null ; then
  echo 'Installing homebrew'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

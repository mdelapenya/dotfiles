#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";
DOTFILES_ROOT="`pwd`"

git pull origin master

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

function info() {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

function user() {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

function success() {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

function fail() {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
	doIt;
  fi
fi
unset doIt;

if ! test brew ; then
  echo 'Installing homebrew'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

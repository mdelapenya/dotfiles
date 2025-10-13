#!/usr/bin/env bash

################################################################################
# common.sh - Shared shell functions for dotfiles scripts
#
# Usage: source "$(dirname "$0")/scripts/common.sh"
################################################################################

# Color output functions
function info() {
  printf "  [ \033[00;34m..\033[0m ] $1\n"
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
  exit 1
}

function header() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  printf "  \033[1;36m$1\033[0m\n"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

# Check if a command exists
function command_exists() {
  command -v "$1" &> /dev/null
}

# Confirm action with user
function confirm() {
  local prompt="${1:-Continue?}"
  local default="${2:-n}"

  if [ "$default" = "y" ]; then
    read -p "$prompt (Y/n) " -n 1 -r
  else
    read -p "$prompt (y/n) " -n 1 -r
  fi
  echo ""

  if [ "$default" = "y" ]; then
    [[ ! $REPLY =~ ^[Nn]$ ]]
  else
    [[ $REPLY =~ ^[Yy]$ ]]
  fi
}

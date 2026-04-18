#!/bin/bash
set -e

echo "Installing Neovim config prerequisites..."

MISSING=()

check() {
  command -v "$1" &>/dev/null || MISSING+=("$1")
}

check fd
check rg
check node
check make
check git
check lazygit

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "All prerequisites already installed."
  exit 0
fi

echo "Missing: ${MISSING[*]}"

if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Install it from https://brew.sh then re-run this script."
  exit 1
fi

BREW_PACKAGES=()
for tool in "${MISSING[@]}"; do
  case "$tool" in
    fd)       BREW_PACKAGES+=(fd) ;;
    rg)       BREW_PACKAGES+=(ripgrep) ;;
    node)     BREW_PACKAGES+=(node) ;;
    make)     BREW_PACKAGES+=(make) ;;
    git)      BREW_PACKAGES+=(git) ;;
    lazygit)  BREW_PACKAGES+=(lazygit) ;;
  esac
done

if [ ${#BREW_PACKAGES[@]} -gt 0 ]; then
  brew install "${BREW_PACKAGES[@]}"
fi

echo "Done. Restart Neovim and run :Lazy sync to rebuild plugins."

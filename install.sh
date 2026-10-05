#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "================================="
echo "WSL Development Environment Setup"
echo "================================="

#
# APT
#
echo ""
echo "[APT] Installing packages..."

sudo apt update

xargs -a "$ROOT_DIR/wsl/apt.txt" sudo apt install -y

#
# Rust/Cargo
#
echo ""
echo "[Cargo] Installing packages..."

if ! command -v cargo >/dev/null 2>&1; then
    echo "cargo not found."
    echo "Install Rust first: https://rustup.rs"
    exit 1
fi

while read -r pkg
do
    [ -z "$pkg" ] && continue
    cargo install "$pkg"
done < "$ROOT_DIR/packages/cargo.txt"

#
# Python
#
if [ -f "$ROOT_DIR/packages/pip.txt" ]; then
    echo ""
    echo "[PIP] Installing packages..."

    if command -v pip3 >/dev/null 2>&1; then
        pip3 install -r "$ROOT_DIR/packages/pip.txt"
    else
        echo "pip3 not found. Skipping."
    fi
fi

#
# VSCode Extensions
#
echo ""
echo "[VSCode] Installing extensions..."

if command -v code >/dev/null 2>&1; then
    while read -r ext
    do
        [ -z "$ext" ] && continue
        code --install-extension "$ext"
    done < "$ROOT_DIR/vscode/extensions.txt"
else
    echo "VSCode command not found. Skipping."
fi

#
# Verible
#
echo ""
echo "[Verible] Installing..."

bash "$ROOT_DIR/scripts/install_verible.sh"

echo ""
echo "================================="
echo "Setup Complete"
echo "================================="
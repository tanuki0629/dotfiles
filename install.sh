#!/bin/bash

set -e
trap 'echo "ERROR: line $LINENO exit code $?"' ERR

# ログファイルの設定
LOGFILE="$HOME/install_setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "Logging output to $LOGFILE"

echo "Checking sudo..."
sudo -v

# source 実行・直接実行のどちらでもスクリプトのディレクトリを正確に取得
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
ROOT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

echo "================================="
echo "WSL Development Environment Setup"
echo "ROOT_DIR: $ROOT_DIR"
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
echo "[Cargo] Checking Rust environment..."

# Cargo が見つからない場合は自動インストール
if ! command -v cargo >/dev/null 2>&1; then
    echo "Rust/Cargo not found. Installing Rust via rustup..."
    
    # -s -- -y を指定して対話プロンプトなしで自動インストール
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # 現在のシェルセッションに Cargo の PATH を反映
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
fi

# 再度 cargo の存在を確認し、パッケージをインストール
if command -v cargo >/dev/null 2>&1; then
    echo "Installing Cargo packages..."
    if [ -f "$ROOT_DIR/packages/cargo.txt" ]; then
        grep -vE '^\s*#|^\s*$' "$ROOT_DIR/packages/cargo.txt" | tr -d '\r' | while read -r pkg <&3; do
            [ -z "$pkg" ] && continue
            cargo install "$pkg"
        done 3< "$ROOT_DIR/packages/cargo.txt"
    fi
else
    echo "Failed to set up Cargo. Skipping Cargo packages."
fi

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

echo ""
echo "Press Enter to exit"
read

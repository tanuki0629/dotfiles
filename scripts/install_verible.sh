#!/bin/bash

set -e

VERSION="v0.0-4296-g0f262651"

TOOLS_DIR="$HOME/tools"

mkdir -p "$TOOLS_DIR"

cd "$TOOLS_DIR"

ARCHIVE="verible-${VERSION}-linux-static-x86_64.tar.gz"

URL="https://github.com/chipsalliance/verible/releases/download/${VERSION}/${ARCHIVE}"

echo "[INFO] Downloading ${ARCHIVE}"

wget -O "${ARCHIVE}" "${URL}"

echo "[INFO] Extracting"

tar -xzf "${ARCHIVE}"

echo "[INFO] Verible installed"

find "$TOOLS_DIR" -name verible-verilog-format

echo "[DONE]"

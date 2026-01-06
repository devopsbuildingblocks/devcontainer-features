#!/usr/bin/env bash
#
# Common Library Feature Installation Script
# Installs shared bash utilities to a system-wide location
#

set -e

# Standard location for devcontainer feature libraries
LIB_INSTALL_DIR="/usr/local/lib/devcontainer-features"

echo "Installing devcontainer-features common library"

# Create the library directory
mkdir -p "$LIB_INSTALL_DIR"

# Get the directory where this install script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy the common.sh library to the system location
cp "$SCRIPT_DIR/common.sh" "$LIB_INSTALL_DIR/common.sh"
chmod 644 "$LIB_INSTALL_DIR/common.sh"

echo "Common library installed to $LIB_INSTALL_DIR/common.sh"
echo "Other features can source it with: source /usr/local/lib/devcontainer-features/common.sh"

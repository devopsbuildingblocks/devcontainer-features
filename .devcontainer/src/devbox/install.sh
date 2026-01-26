#!/usr/bin/env bash
#
# Devbox Feature Installation Script
# Installs devbox and configures shell integration
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-0.16.0}"
BIN_DIR="${BIN_DIR:-/usr/local/bin}"

#######################################
# Get the current operating system
# Outputs:
#   The OS name (linux, darwin, etc.)
#######################################
get_os() {
  local os
  os="$(uname | tr '[:upper:]' '[:lower:]')"
  echo "${os}"
}

#######################################
# Get the system architecture in devbox format
# Outputs:
#   The architecture (amd64, arm64)
#######################################
get_arch() {
  local arch
  arch="$(uname -m)"
  case "${arch}" in
  x86_64) arch="amd64" ;;
  aarch64) arch="arm64" ;;
  *)
    log_error "Unsupported architecture: ${arch}"
    exit 1
    ;;
  esac
  echo "${arch}"
}

#######################################
# Install devbox binary
#######################################
install_devbox() {
  log_info "Installing devbox version ${VERSION}"

  local url
  url="https://github.com/jetify-com/devbox/releases/download/${VERSION}/devbox_${VERSION}_$(get_os)_$(get_arch).tar.gz"

  # Download and extract devbox binary
  # -f: fail on HTTP errors, -s: silent, -S: show errors, -L: follow redirects
  if ! curl -fsSL "${url}" | tar xzf - -C "${BIN_DIR}" devbox; then
    log_error "Failed to download or extract devbox from ${url}"
    log_error "Please check that version ${VERSION} exists and your architecture is supported"
    exit 1
  fi

  # Make binary executable
  if ! chmod +x "${BIN_DIR}/devbox"; then
    log_error "Failed to make devbox binary executable"
    exit 1
  fi

  # Verify installation succeeded
  if ! command_exists devbox; then
    log_error "devbox installation failed - command not found after extraction"
    exit 1
  fi

  local installed_version
  installed_version=$(devbox version)
  log_success "devbox installed: ${installed_version}"
}

#######################################
# Create postCreateCommand script
# This runs after the container is created to install devbox packages
#######################################
create_postCreateCommand() {
  log_info "Creating postCreateCommand script"

  local devcontainer_postCreateCommand="/usr/local/bin/devbox-postCreateCommand.sh"
  cat << 'EOF' > "$devcontainer_postCreateCommand"
#!/bin/bash
set -e

# Source common utilities for shared functions
source /usr/local/lib/devcontainer-features/common.sh

# Fix ownership of volume mounts BEFORE running devbox/nix commands
# Volume mounts may be root-owned initially
fix_feature_volume_ownership

# Ensure devbox global directories exist with correct ownership
mkdir -p "${HOME}/.local/share/devbox/global/default"

# Run devbox commands
if [ -f "devbox.json" ]; then
    echo "Found existing devbox.json, running devbox install..."
    devbox install
else
    echo "No devbox.json found, initializing devbox..."
    devbox init
fi

# Fix ownership AFTER devbox/nix operations complete
# nix-daemon runs as root and creates files with root ownership
fix_feature_volume_ownership
EOF
  chmod +x "$devcontainer_postCreateCommand"
  log_success "Created postCreateCommand script"
}

#######################################
# Set up shell integration for devbox
#######################################
setup_shell_integration() {
  log_info "Setting up shell integration"

  # Ensure XDG_DATA_HOME and devbox global directories exist for both users
  # Root user
  mkdir -p "/root/.local/share/devbox/global/default"

  # Remote user (if different from root)
  local remote_user
  remote_user=$(get_remote_user)
  if [ "$remote_user" != "root" ]; then
    local remote_user_home
    remote_user_home=$(get_remote_user_home)
    mkdir -p "${remote_user_home}/.local/share/devbox/global/default"
    chown -R "$remote_user:$remote_user" "${remote_user_home}/.local"
  fi

  # Create shell configuration
  local shellrc_content
  shellrc_content=$(cat <<'EOF'
# Devbox shell integration
# This file is sourced by ~/.shellrc.d/main.sh

# Set XDG_DATA_HOME for devbox
export XDG_DATA_HOME="${HOME}/.local/share"

# Initialize devbox global environment
if command -v devbox >/dev/null 2>&1; then
    # Load devbox global packages into the environment
    # This is aliased to 'refresh-global'
    eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r
    # --init-hook runs initialization hooks for a proper setup
    # This also creates the 'refresh-global' alias to update the PATH after adding packages
    eval "$(devbox global shellenv --init-hook)"
fi
EOF
)

  write_shellrc_feature "devbox" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
  log_info "Starting devbox installation"

  # Install devbox binary
  install_devbox

  # Set up shell integration
  setup_shell_integration

  # Create lifecycle scripts
  create_postCreateCommand

  log_success "Devbox feature installation complete"
}

# Execute main function
main "$@"

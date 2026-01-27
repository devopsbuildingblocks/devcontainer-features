#!/usr/bin/env bash
#
# Common utilities for devcontainer feature scripts
# This library provides reusable functions for feature installation scripts
#

set -e

# Colors for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_BLUE='\033[0;34m'

#######################################
# Print an info message
# Arguments:
#   Message to print
#######################################
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

#######################################
# Print a success message
# Arguments:
#   Message to print
#######################################
log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
}

#######################################
# Print a warning message
# Arguments:
#   Message to print
#######################################
log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*"
}

#######################################
# Print an error message
# Arguments:
#   Message to print
#######################################
log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

#######################################
# Get the remote user, defaulting to root if not set
# Outputs:
#   The remote user name
#######################################
get_remote_user() {
    echo "${_REMOTE_USER:-root}"
}

#######################################
# Get the remote user's home directory
# Outputs:
#   The remote user's home directory path
#######################################
get_remote_user_home() {
    if [ -n "${_REMOTE_USER_HOME}" ]; then
        echo "${_REMOTE_USER_HOME}"
    else
        local user
        user=$(get_remote_user)
        if [ "$user" = "root" ]; then
            echo "/root"
        else
            echo "/home/$user"
        fi
    fi
}

#######################################
# Ensure the shellrc.d directory exists for a specific user
# Creates the directory if it doesn't exist
# Arguments:
#   $1 - User name (optional, defaults to remote user)
#   $2 - User home directory (optional, auto-detected from user)
# Outputs:
#   The shellrc.d directory path
#######################################
ensure_shellrc_dir_for_user() {
    local user="${1:-$(get_remote_user)}"
    local user_home="$2"

    # Auto-detect home directory if not provided
    if [ -z "$user_home" ]; then
        if [ "$user" = "root" ]; then
            user_home="/root"
        else
            user_home="/home/$user"
        fi
    fi

    local shellrc_dir="${user_home}/.shellrc.d"

    if [ ! -d "$shellrc_dir" ]; then
        log_info "Creating shellrc.d directory: $shellrc_dir"
        mkdir -p "$shellrc_dir"

        if [ "$user" != "root" ]; then
            chown -R "$user:$user" "$shellrc_dir"
        fi
    fi

    echo "$shellrc_dir"
}

#######################################
# Ensure the shellrc.d directory exists
# Creates ~/.shellrc.d if it doesn't exist
# Outputs:
#   The shellrc.d directory path
#######################################
ensure_shellrc_dir() {
    ensure_shellrc_dir_for_user "$(get_remote_user)" "$(get_remote_user_home)"
}

#######################################
# Write a feature configuration script to a specific user's ~/.shellrc.d
# Arguments:
#   $1 - Feature name (e.g., "lazygit")
#   $2 - Content to write
#   $3 - User name
#   $4 - User home directory (optional, auto-detected from user)
#######################################
write_shellrc_feature_for_user() {
    local feature_name="$1"
    local content="$2"
    local user="$3"
    local user_home="$4"

    if [ -z "$feature_name" ] || [ -z "$content" ] || [ -z "$user" ]; then
        log_error "write_shellrc_feature_for_user requires feature_name, content, and user arguments"
        return 1
    fi

    local shellrc_dir
    shellrc_dir=$(ensure_shellrc_dir_for_user "$user" "$user_home")
    local feature_file="${shellrc_dir}/${feature_name}-feature.sh"

    log_info "Writing shell configuration for $feature_name (user: $user)"
    echo "$content" > "$feature_file"
    chmod +x "$feature_file"

    if [ "$user" != "root" ]; then
        chown "$user:$user" "$feature_file"
    fi

    log_success "Created $feature_file"
}

#######################################
# Write a feature configuration script to ~/.shellrc.d for all users
# Writes to both root and the remote user (if different)
# Arguments:
#   Feature name (e.g., "lazygit")
#   Content to write
#######################################
write_shellrc_feature() {
    local feature_name="$1"
    local content="$2"

    if [ -z "$feature_name" ] || [ -z "$content" ]; then
        log_error "write_shellrc_feature requires feature_name and content arguments"
        return 1
    fi

    # Always write to root
    write_shellrc_feature_for_user "$feature_name" "$content" "root" "/root"

    # Write to remote user if different from root
    local remote_user
    remote_user=$(get_remote_user)
    if [ "$remote_user" != "root" ]; then
        local remote_user_home
        remote_user_home=$(get_remote_user_home)
        write_shellrc_feature_for_user "$feature_name" "$content" "$remote_user" "$remote_user_home"
    fi
}

#######################################
# Install a package using devbox global add
# Arguments:
#   Package specification (e.g., "lazygit@latest" or "gh@2.40.0")
#######################################
devbox_global_add() {
    local package="$1"

    if [ -z "$package" ]; then
        log_error "devbox_global_add requires a package argument"
        return 1
    fi

    # Ensure devbox is available
    if ! command -v devbox &> /dev/null; then
        log_error "devbox is not installed. Please ensure the devbox feature is installed first."
        return 1
    fi

    # Save original environment
    local orig_home="${HOME}"
    local orig_user="${USER}"
    local orig_xdg="${XDG_DATA_HOME:-}"

    log_info "Installing $package via devbox global add for root user"
    devbox global add "$package"

    # Refresh root's environment
    log_info "Refreshing devbox environment for root"
    eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r

    # Get remote user info
    local user
    user=$(get_remote_user)

    # Install and configure for remote user if different from root
    if [ "$user" != "root" ]; then
        local user_home
        user_home=$(get_remote_user_home)

        # Set up environment for remote user's devbox
        export XDG_DATA_HOME="${user_home}/.local/share"
        export USER="$user"
        export HOME="$user_home"

        # Ensure parent directories exist with correct ownership
        mkdir -p "${user_home}/.local/share"
        chown -R "$user:$user" "${user_home}/.local"

        log_info "Installing $package via devbox global add for remote user"
        devbox global add "$package"

        # Refresh remoteUser's environment
        log_info "Refreshing devbox environment for $user"
        eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r

        # Fix ownership of all devbox-related directories
        chown -R "$user:$user" "${user_home}/.local/share/devbox" 2>/dev/null || true
        chown -R "$user:$user" "${user_home}/.cache/devbox" 2>/dev/null || true

        # Restore original environment
        export HOME="${orig_home}"
        export USER="${orig_user}"
        if [ -n "${orig_xdg}" ]; then
            export XDG_DATA_HOME="${orig_xdg}"
        else
            unset XDG_DATA_HOME
        fi
    fi

    log_success "Installed $package"
}

#######################################
# Run a command as the remote user
# Arguments:
#   Command to run
#######################################
run_as_user() {
    local user
    user=$(get_remote_user)

    if [ "$user" = "root" ]; then
        bash -c "$*"
    else
        su - "$user" -c "$*"
    fi
}

#######################################
# Check if a command exists
# Arguments:
#   Command name
# Returns:
#   0 if command exists, 1 otherwise
#######################################
command_exists() {
    command -v "$1" &> /dev/null
}

#######################################
# Create a directory with proper ownership
# Arguments:
#   Directory path
#######################################
ensure_directory() {
    local dir="$1"
    local user
    user=$(get_remote_user)

    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        if [ "$user" != "root" ]; then
            chown -R "$user:$user" "$dir"
        fi
    fi
}

#######################################
# Fix ownership of all devcontainer feature volume mounts
# This should be called after any operation that might create
# files as root (e.g., nix-daemon operations)
#
# The function chowns everything under /mnt/devcontainer-features
# to the current user, ensuring proper access to volume-mounted
# directories that may have files created by root processes.
#######################################
fix_feature_volume_ownership() {
    # Use _REMOTE_USER if set (install.sh context), otherwise fall back to USER or whoami
    # Note: USER may be empty in postCreateCommand context, so whoami is the reliable fallback
    local user="${_REMOTE_USER:-${USER:-$(whoami)}}"
    if [ -d /mnt/devcontainer-features ]; then
        sudo chown -R "${user}:${user}" /mnt/devcontainer-features 2>/dev/null || true
    fi
}

#######################################
# Create a postCreateCommand script for volume-backed symlinks
# Generates a script that creates symlinks from home directory to docker volume mounts
# This allows persistent storage of configuration and data across container rebuilds
#
# Arguments:
#   $1 - Feature name (e.g., "claude", "common-utils")
#   $2+ - Paths to symlink (relative to home directory, e.g., ".cache" ".local" ".claude")
#
# The script will:
#   1. Check if volume mount exists at /mnt/devcontainer-features/{feature-name}
#   2. Create subdirectories in the mount for each path
#   3. Merge existing content from home directory to volume
#   4. Create symlinks from home directory to volume mount
#
# Example:
#   create_volume_symlink_script "common-utils" ".cache" ".local"
#   create_volume_symlink_script "claude" ".claude" ".claude.json"
#######################################
create_volume_symlink_script() {
    local feature_name="$1"
    shift
    local paths=("$@")

    if [ -z "$feature_name" ]; then
        log_error "create_volume_symlink_script requires feature_name argument"
        return 1
    fi

    if [ ${#paths[@]} -eq 0 ]; then
        log_error "create_volume_symlink_script requires at least one path argument"
        return 1
    fi

    local script_path="/usr/local/bin/${feature_name}-postCreateCommand.sh"
    log_info "Creating volume symlink script for $feature_name"

    # Start the script with header
    cat > "$script_path" <<'SCRIPT_HEADER'
#!/usr/bin/env bash
#
# Volume-backed Symlink Setup
# Creates symlinks from home directory to docker volume mounts
# This script is run as postCreateCommand to ensure persistence
#
SCRIPT_HEADER

    # Add the feature-specific mount point check and setup
    cat >> "$script_path" <<SCRIPT_BODY
# Only create symlinks if mount point exists
if [ -d /mnt/devcontainer-features/${feature_name} ]; then
  sudo chown -R \${USER}:\${USER} /mnt/devcontainer-features/${feature_name}

SCRIPT_BODY

    # Add logic for each path
    for path in "${paths[@]}"; do
        # Determine if this is a file or directory based on extension
        # Check if path ends with a known file extension (e.g., .json, .yml, .conf)
        if [[ "$path" =~ \.(json|yml|yaml|conf|txt|toml|ini)$ ]]; then
            # It's a file
            cat >> "$script_path" <<SCRIPT_FILE
  # Setup ${path} (file)
  if [ ! -f /mnt/devcontainer-features/${feature_name}/${path} ]; then
    echo "{}" > /mnt/devcontainer-features/${feature_name}/${path}
  fi
  if [ -f ~/${path} ] && [ ! -L ~/${path} ]; then
      rm ~/${path}
  fi
  ln -sf /mnt/devcontainer-features/${feature_name}/${path} ~/${path}

SCRIPT_FILE
        else
            # Treat as directory
            cat >> "$script_path" <<SCRIPT_DIR
  # Setup ${path} (directory)
  if [ ! -d /mnt/devcontainer-features/${feature_name}/${path} ]; then
    mkdir -p /mnt/devcontainer-features/${feature_name}/${path}
  fi
  # Merge existing content into volume mount
  if [ -d ~/${path} ] && [ ! -L ~/${path} ]; then
      sudo cp -r ~/${path}/* /mnt/devcontainer-features/${feature_name}/${path}/ 2>/dev/null || true
      sudo chown -R \${USER}:\${USER} /mnt/devcontainer-features/${feature_name}/${path}
      sudo rm -rf ~/${path}
  fi
  ln -sf /mnt/devcontainer-features/${feature_name}/${path} ~/${path}

SCRIPT_DIR
        fi
    done

    # Close the mount point check
    cat >> "$script_path" <<'SCRIPT_FOOTER'
fi
SCRIPT_FOOTER

    chmod +x "$script_path"
    log_success "Created volume symlink script: $script_path"
}

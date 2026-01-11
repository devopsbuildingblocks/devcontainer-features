#!/usr/bin/env bash
#
# Eza Feature Installation Script
# Installs eza via devbox global and configures themes and aliases
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"
THEME="${THEME:-db2-dark}"
ALIASASLS="${ALIASASLS:-true}"
ENABLEICONS="${ENABLEICONS:-false}"

#######################################
# Install eza via devbox global
#######################################
install_eza() {
    log_info "Installing eza (version: $VERSION)"

    local package_spec="eza"
    if [ "$VERSION" != "latest" ]; then
        package_spec="eza@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    # Verify installation
    if ! command_exists eza; then
        log_error "eza installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(eza --version | head -n1)
    log_success "eza installed: $installed_version"
}

#######################################
# Setup theme files to system location
# Copies themes from feature directory to /usr/local/share
#######################################
setup_themes() {
    local themes_src="themes"
    local themes_dest="/usr/local/share/devcontainer-features/eza/themes"

    if [ -d "$themes_src" ]; then
        log_info "Installing eza themes to $themes_dest"
        mkdir -p "$themes_dest"
        cp -r "$themes_src"/* "$themes_dest/"
        local theme_count
        theme_count=$(find "$themes_src" -maxdepth 1 -type f -name "*.yml" | wc -l)
        log_success "Installed $theme_count theme files"
    else
        log_warning "Themes directory not found, skipping theme installation"
    fi
}

#######################################
# Setup eza configuration directory for a specific user
# Creates ~/.config/eza with symlink to active theme
# Arguments:
#   $1 - User name
#   $2 - User home directory
#######################################
setup_config_for_user() {
    local user="$1"
    local user_home="$2"
    local config_dir="${user_home}/.config/eza"
    local themes_dir="/usr/local/share/devcontainer-features/eza/themes"

    log_info "Setting up eza configuration for user: $user"

    mkdir -p "$config_dir"
    if [ "$user" != "root" ]; then
        chown -R "$user:$user" "${user_home}/.config"
    fi

    # Link the selected theme if not "none"
    if [ "$THEME" != "none" ]; then
        local theme_file="${themes_dir}/${THEME}.yml"
        local target_file="${config_dir}/theme.yml"

        if [ -f "$theme_file" ]; then
            ln -sf "$theme_file" "$target_file"
            log_success "Linked theme '$THEME' to $target_file for $user"
        else
            log_warning "Theme file not found: $theme_file"
        fi
    fi
}

#######################################
# Setup eza configuration directory for all users
# Creates ~/.config/eza with symlink to active theme
#######################################
setup_config() {
    local themes_dir="/usr/local/share/devcontainer-features/eza/themes"

    # Always set up for root
    setup_config_for_user "root" "/root"

    # Set up for remote user if different from root
    local remote_user
    remote_user=$(get_remote_user)
    if [ "$remote_user" != "root" ]; then
        local remote_user_home
        remote_user_home=$(get_remote_user_home)
        setup_config_for_user "$remote_user" "$remote_user_home"
    fi
}

#######################################
# Generate shell integration content
#######################################
generate_shell_integration() {
    cat <<'EOF'
# eza shell integration
# This file is sourced by ~/.shellrc.d/main.sh
# eza is installed via devbox global, which is loaded by devbox-feature.sh

# eza configuration directory (for theme support)
# Uses $HOME to work correctly for both root and non-root users
export EZA_CONFIG_DIR="${HOME}/.config/eza"

EOF

    # Add aliases if enabled
    if [ "$ALIASASLS" = "true" ]; then
        cat <<'EOF'
# eza aliases replacing ls commands
EOF
        if [ "$ENABLEICONS" = "true" ]; then
            cat <<'EOF'
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -a --icons'
alias lt='eza --tree --icons'
alias l='eza -la --icons'
EOF
        else
            cat <<'EOF'
alias ls='eza'
alias ll='eza -l'
alias la='eza -a'
alias lt='eza --tree'
alias l='eza -la'
EOF
        fi
        cat <<'EOF'

EOF
    fi

    # Add current theme tracking
    cat <<EOF
# Track current eza theme
export CURRENT_EZA_THEME="${THEME}"
EOF

    # Add theme helper functions
    cat <<'EOF'

#######################################
# List available eza themes
#######################################
eza-themes() {
    local themes_dir="/usr/local/share/devcontainer-features/eza/themes"

    echo "Available eza themes:"
    echo "  db2-dark    - DevOpsBuildingBlocks dark theme (red/yellow/blue)"
    echo "  db2-light   - DevOpsBuildingBlocks light theme (red/yellow/blue)"
    echo "  none        - No theme (use eza defaults)"
    echo ""
    echo "Current theme: ${CURRENT_EZA_THEME:-unknown}"
    echo ""
    echo "Usage: eza-theme <theme-name>"
}

#######################################
# Switch eza theme
# Updates the symlink in ~/.config/eza/theme.yml
#######################################
eza-theme() {
    if [ -z "$1" ]; then
        echo "Error: No theme specified"
        echo ""
        eza-themes
        return 1
    fi

    local theme="$1"
    local themes_dir="/usr/local/share/devcontainer-features/eza/themes"
    local config_dir="${EZA_CONFIG_DIR:-$HOME/.config/eza}"
    local theme_file="${themes_dir}/${theme}.yml"
    local target_file="${config_dir}/theme.yml"

    # Handle "none" theme
    if [ "$theme" = "none" ]; then
        rm -f "$target_file"
        export CURRENT_EZA_THEME="none"
        echo "eza theme disabled (using defaults)"
        return 0
    fi

    # Validate theme file exists
    if [ ! -f "$theme_file" ]; then
        echo "Error: Theme '$theme' not found"
        echo "Available themes:"
        find "$themes_dir" -name "*.yml" -exec basename {} .yml \; 2>/dev/null | sort | sed 's/^/  /'
        return 1
    fi

    # Ensure config directory exists
    mkdir -p "$config_dir"

    # Create symlink to theme
    ln -sf "$theme_file" "$target_file"

    export CURRENT_EZA_THEME="$theme"
    echo "Switched eza theme to: $theme"
}
EOF
}

#######################################
# Set up shell integration for eza
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(generate_shell_integration)

    write_shellrc_feature "eza" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting eza installation"

    install_eza
    setup_themes
    setup_config
    setup_shell_integration

    log_success "eza feature installation complete"
}

# Execute main function
main "$@"

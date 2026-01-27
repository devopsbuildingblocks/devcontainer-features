#!/usr/bin/env bash
#
# K9s Feature Installation Script
# Installs k9s via devbox global and configures shell integration
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"
THEME="${THEME:-db2-dark}"

#######################################
# Install k9s via devbox global
#######################################
install_k9s() {
    log_info "Installing k9s (version: $VERSION)"

    local package_spec="k9s"
    if [ "$VERSION" != "latest" ]; then
        package_spec="k9s@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    # Verify installation
    if ! command_exists k9s; then
        log_error "k9s installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(k9s version --short 2>/dev/null | head -n1 || echo "unknown")
    log_success "k9s installed: $installed_version"
}

#######################################
# Setup theme files to system location
# Copies themes from feature directory to /usr/local/share
#######################################
setup_themes() {
    local themes_src="themes"
    local themes_dest="/usr/local/share/devcontainer-features/k9s/themes"

    if [ -d "$themes_src" ]; then
        log_info "Installing k9s themes to $themes_dest"
        mkdir -p "$themes_dest"
        cp -r "$themes_src"/* "$themes_dest/"
        local theme_count
        theme_count=$(find "$themes_src" -maxdepth 1 -type f -name "*.yaml" | wc -l)
        log_success "Installed $theme_count theme files"
    else
        log_warning "Themes directory not found, skipping theme installation"
    fi
}

#######################################
# Get the theme file name for the selected theme
# Handles aliases like 'db2' -> 'db2-dark' and 'default' -> 'db2-dark'
#######################################
get_theme_file_name() {
    local theme_name="$1"

    case "$theme_name" in
        default|db2)
            echo "db2-dark"
            ;;
        *)
            echo "$theme_name"
            ;;
    esac
}

#######################################
# Setup k9s configuration file for a specific user
# Arguments:
#   $1 - User name
#   $2 - User home directory
#######################################
setup_config_for_user() {
    local user="$1"
    local user_home="$2"
    local config_dir="${user_home}/.config/k9s"
    local themes_dir="/usr/local/share/devcontainer-features/k9s/themes"

    log_info "Setting up k9s configuration for user: $user"
    mkdir -p "$config_dir/skins"

    # Get the actual theme file name (resolve aliases)
    local theme_file_name
    theme_file_name=$(get_theme_file_name "$THEME")

    # Copy all themes to user's skins directory
    if [ -d "$themes_dir" ]; then
        cp "$themes_dir"/*.yaml "$config_dir/skins/" 2>/dev/null || true
    fi

    # Create k9s config.yaml pointing to the selected skin
    local config_file="${config_dir}/config.yaml"
    cat > "$config_file" <<EOF
# K9s configuration
# Current theme: $THEME
k9s:
  liveViewAutoRefresh: true
  refreshRate: 2
  maxConnRetry: 5
  readOnly: false
  noExitOnCtrlC: false
  ui:
    enableMouse: false
    headless: false
    logoless: false
    crumbsless: false
    reactive: false
    noIcons: false
    skin: ${theme_file_name}
  skipLatestRevCheck: true
  disablePodCounting: false
  shellPod:
    image: busybox:1.35.0
    namespace: default
    limits:
      cpu: 100m
      memory: 100Mi
  imageScans:
    enable: false
EOF

    if [ "$user" != "root" ]; then
        chown -R "$user:$user" "${user_home}/.config"
    fi

    log_success "Created k9s config at $config_file for $user"
}

#######################################
# Setup k9s configuration file for all users
#######################################
setup_config() {
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
# Set up shell integration for k9s
# Creates theme switching functions and aliases
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(cat <<'EOF'
# K9s shell integration
# This file is sourced by ~/.shellrc.d/main.sh

# Track current theme
export CURRENT_K9S_THEME="THEME_PLACEHOLDER"

# Convenient alias for k9s
alias k9='k9s'

#######################################
# List available k9s themes
# Shows all themes installed in the themes directory
#######################################
k9s-themes() {
    echo "Available k9s themes:"
    echo "  db2-dark       - DevOpsBuildingBlocks dark theme (default)"
    echo "  db2            - Alias for db2-dark"
    echo "  nord           - Nord theme"
    echo "  dracula        - Dracula theme"
    echo "  one-dark       - One Dark theme"
    echo "  gruvbox-dark   - Gruvbox Dark theme"
    echo "  solarized-dark - Solarized Dark theme"
    echo ""
    echo "Current theme: ${CURRENT_K9S_THEME:-unknown}"
    echo ""
    echo "Usage: k9s-theme <theme-name>"
}

#######################################
# Switch k9s theme
# Updates the k9s config with the selected skin
#
# Arguments:
#   $1 - Theme name to switch to
#######################################
k9s-theme() {
    if [ -z "$1" ]; then
        echo "Error: No theme specified"
        echo ""
        k9s-themes
        return 1
    fi

    local theme="$1"
    local config_file="$HOME/.config/k9s/config.yaml"
    local skins_dir="$HOME/.config/k9s/skins"
    local themes_dir="THEMES_DIR_PLACEHOLDER"

    # Validate config file exists
    if [ ! -f "$config_file" ]; then
        echo "Error: K9s config file not found at $config_file"
        return 1
    fi

    # Handle theme aliases and normalize theme name
    local theme_file_name="$theme"
    case "$theme" in
        db2|default)
            theme_file_name="db2-dark"
            ;;
    esac

    # Validate theme exists
    local theme_file="$themes_dir/${theme_file_name}.yaml"
    if [ ! -f "$theme_file" ]; then
        echo "Error: Theme file not found: $theme_file"
        echo "Available themes:"
        find "$themes_dir" -maxdepth 1 -name "*.yaml" -type f 2>/dev/null | xargs -n1 basename | sed 's/.yaml$//' | sed 's/^/  /' || echo "  (no themes found)"
        return 1
    fi

    # Copy theme to user's skins directory if not already there
    mkdir -p "$skins_dir"
    cp "$theme_file" "$skins_dir/" 2>/dev/null || true

    # Update the skin setting in config.yaml
    if grep -q "skin:" "$config_file" 2>/dev/null; then
        sed -i "s/skin: .*/skin: ${theme_file_name}/" "$config_file"
    else
        # If no skin setting exists, add it under ui section
        sed -i "/ui:/a\\    skin: ${theme_file_name}" "$config_file"
    fi

    # Update the comment at the top
    sed -i "s/# Current theme: .*/# Current theme: $theme/" "$config_file"

    # Update environment variable to track current theme
    export CURRENT_K9S_THEME="$theme"

    echo "K9s theme switched to: $theme"
    echo "Config file: $config_file"
    echo "(Restart k9s to apply the new theme)"
}
EOF
)

    # Replace placeholders with actual values
    local themes_dir="/usr/local/share/devcontainer-features/k9s/themes"
    shellrc_content="${shellrc_content//THEME_PLACEHOLDER/$THEME}"
    shellrc_content="${shellrc_content//THEMES_DIR_PLACEHOLDER/$themes_dir}"

    write_shellrc_feature "k9s" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting k9s installation"

    install_k9s
    setup_themes
    setup_config
    setup_shell_integration

    log_success "K9s feature installation complete"
}

# Execute main function
main "$@"

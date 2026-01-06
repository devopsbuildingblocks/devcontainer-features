#!/usr/bin/env bash
#
# Lazygit Feature Installation Script
# Installs lazygit via devbox global and configures shell integration
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"
THEME="${THEME:-default}"
ENABLEGITDIFFPAGER="${ENABLEGITDIFFPAGER:-false}"

#######################################
# Install lazygit via devbox global
#######################################
install_lazygit() {
    log_info "Installing lazygit (version: $VERSION)"

    local package_spec="lazygit"
    if [ "$VERSION" != "latest" ]; then
        package_spec="lazygit@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    # Verify installation
    if ! command_exists lazygit; then
        log_error "lazygit installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(lazygit --version | head -n1)
    log_success "lazygit installed: $installed_version"
}

#######################################
# Setup theme files to system location
# Copies themes from feature directory to /usr/local/share
#######################################
setup_themes() {
    local themes_src="themes"
    local themes_dest="/usr/local/share/devcontainer-features/lazygit/themes"

    if [ -d "$themes_src" ]; then
        log_info "Installing lazygit themes to $themes_dest"
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
# Setup lazygit configuration file
#######################################
setup_config() {
    local user_home
    user_home=$(get_remote_user_home)
    local config_dir="${user_home}/.config/lazygit"

    log_info "Setting up lazygit configuration"
    ensure_directory "$config_dir"

    local config_file="${config_dir}/config.yml"

    # Generate config based on theme and options
    generate_config > "$config_file"

    local user
    user=$(get_remote_user)
    if [ "$user" != "root" ]; then
        chown -R "$user:$user" "$config_dir"
    fi

    log_success "Created lazygit config at $config_file"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting lazygit installation"

    install_lazygit
    setup_themes
    setup_config
    setup_shell_integration

    log_success "Lazygit feature installation complete"
}

#######################################
# Generate lazygit configuration content
#######################################
generate_config() {
    cat <<EOF
# yaml-language-server: \$schema=https://raw.githubusercontent.com/jesseduffield/lazygit/master/schema/config.json
# Current theme: $THEME
disableStartupPopups: true
promptToReturnFromSubprocess: false
update:
  method: never
gui:
  showRandomTip: false
  showCommandLog: false
  showBottomLine: false
  showPanelJumps: true
  skipRewordInEditorWarning: true
  expandFocusedSidePanel: true
  statusPanelView: allBranchesLog
  nerdFontsVersion: "3"
$(get_theme_config)
$(get_git_config)
EOF
}

#######################################
# Get theme-specific configuration (branchColors + theme)
# Loads theme from external YAML file in themes/ directory
# Returns:
#   Complete YAML theme configuration for the selected theme
#######################################
get_theme_config() {
    local theme_name="$THEME"

    # Handle aliases and default theme
    case "$theme_name" in
        default)
            theme_name="tokyo-night-vibrant"
            ;;
        db2)
            theme_name="db2-dark"
            ;;
    esac

    # Theme files are installed to system location during feature installation
    local themes_dir="/usr/local/share/devcontainer-features/lazygit/themes"
    local theme_file="${themes_dir}/${theme_name}.yml"

    # Check if theme file exists
    if [ -f "$theme_file" ]; then
        # Add proper indentation (2 spaces) to theme content
        sed 's/^/  /' "$theme_file"
    else
        log_warning "Theme file not found: $theme_file, using tokyo-night-vibrant as fallback"
        sed 's/^/  /' "${themes_dir}/tokyo-night-vibrant.yml"
    fi
}

#######################################
# Get git-specific configuration
# Returns:
#   Git configuration including pager settings (if enabled)
#######################################
get_git_config() {
    # Only output git config if there are actual settings to configure
    if [ "$ENABLEGITDIFFPAGER" = "true" ]; then
        # Determine delta theme based on lazygit theme
        local delta_mode="--dark"
        if [[ "$THEME" == *"light"* ]]; then
            delta_mode="--light"
        fi

        cat <<EOF
git:
  paging:
    colorArg: always
    pager: delta $delta_mode --paging=never
EOF
    fi
}

#######################################
# Set up shell integration for lazygit
# Creates theme switching functions and aliases
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    # Create shell configuration that sources devbox environment
    # Note: We need to escape variables that should be evaluated at runtime (in the shell)
    # vs variables that should be evaluated now during installation
    local shellrc_content
    shellrc_content=$(cat <<'EOF'
# Lazygit shell integration
# This file is sourced by ~/.shellrc.d/main.sh

# Track current theme
export CURRENT_LAZYGIT_THEME="THEME_PLACEHOLDER"

# Convenient alias for lazygit
alias lzg='lazygit'

#######################################
# List available lazygit themes
# Shows all themes installed in the themes directory
#######################################
lzg-themes() {
    echo "Available lazygit themes:"
    echo "  catppuccin-mocha    - Catppuccin Mocha theme"
    echo "  db2                 - DevOpsBuildingBlocks dark theme (alias for db2-dark)"
    echo "  db2-dark            - DevOpsBuildingBlocks dark theme"
    echo "  db2-light           - DevOpsBuildingBlocks light theme"
    echo "  dracula             - Dracula theme"
    echo "  github-dark         - GitHub Dark theme"
    echo "  gruvbox-dark        - Gruvbox Dark theme"
    echo "  nord                - Nord theme"
    echo "  one-dark            - One Dark theme"
    echo "  solarized-dark      - Solarized Dark theme"
    echo "  tokyo-night         - Tokyo Night theme"
    echo "  tokyo-night-vibrant - Tokyo Night Vibrant theme (default)"
    echo ""
    echo "Current theme: ${CURRENT_LAZYGIT_THEME:-unknown}"
    echo ""
    echo "Usage: lzg-theme <theme-name>"
}

#######################################
# Switch lazygit theme
# Regenerates the lazygit config with the selected theme
#
# Arguments:
#   $1 - Theme name to switch to
#
# The function:
#   1. Validates the theme name
#   2. Backs up the current config
#   3. Loads the theme from the themes directory
#   4. Regenerates the config file with the new theme
#   5. Preserves git paging settings if they were enabled
#######################################
lzg-theme() {
    if [ -z "$1" ]; then
        echo "Error: No theme specified"
        echo ""
        lzg-themes
        return 1
    fi

    local theme="$1"
    local config_file="$HOME/.config/lazygit/config.yml"
    local themes_dir="THEMES_DIR_PLACEHOLDER"

    # Validate config file exists
    if [ ! -f "$config_file" ]; then
        echo "Error: Lazygit config file not found at $config_file"
        return 1
    fi

    # Handle theme aliases and normalize theme name
    local theme_file_name="$theme"
    case "$theme" in
        db2)
            theme_file_name="db2-dark"
            ;;
        default)
            theme_file_name="tokyo-night-vibrant"
            ;;
    esac

    # Validate theme exists
    local theme_file="$themes_dir/${theme_file_name}.yml"
    if [ ! -f "$theme_file" ]; then
        echo "Error: Theme file not found: $theme_file"
        echo "Available themes:"
        ls -1 "$themes_dir"/*.yml 2>/dev/null | xargs -n1 basename | sed 's/.yml$//' | sed 's/^/  /' || echo "  (no themes found)"
        return 1
    fi

    # Check if git paging is enabled in current config
    # This allows us to preserve the user's git paging preference when switching themes
    local has_git_paging="false"
    if grep -q "^git:" "$config_file" 2>/dev/null; then
        has_git_paging="true"
    fi

    # Backup original config (in case something goes wrong)
    cp "$config_file" "${config_file}.backup"

    # Generate new config with selected theme
    # Start with schema and theme comment
    cat > "$config_file" <<LZG_CONFIG_EOF
# yaml-language-server: \$schema=https://raw.githubusercontent.com/jesseduffield/lazygit/master/schema/config.json
# Current theme: $theme
disableStartupPopups: true
promptToReturnFromSubprocess: false
update:
  method: never
gui:
  showRandomTip: false
  showCommandLog: false
  showBottomLine: false
  showPanelJumps: true
  skipRewordInEditorWarning: true
  expandFocusedSidePanel: true
  statusPanelView: allBranchesLog
  nerdFontsVersion: "3"
LZG_CONFIG_EOF

    # Load and indent theme content (add 2 spaces to each line for proper YAML nesting)
    sed 's/^/  /' "$theme_file" >> "$config_file"

    # Restore git paging configuration if it was enabled
    if [ "$has_git_paging" = "true" ]; then
        # Determine delta mode based on theme name
        local delta_mode="--dark"
        if [[ "$theme" == *"light"* ]]; then
            delta_mode="--light"
        fi

        cat >> "$config_file" <<LZG_CONFIG_EOF
git:
  paging:
    colorArg: always
    pager: delta $delta_mode --paging=never
LZG_CONFIG_EOF
    fi

    # Update environment variable to track current theme
    export CURRENT_LAZYGIT_THEME="$theme"

    echo "Lazygit theme switched to: $theme"
    echo "Config file: $config_file"
    echo "(Previous config backed up to ${config_file}.backup)"
}
EOF
)

    # Replace placeholders with actual values
    # Theme files are located relative to the install script in the themes/ subdirectory
    local themes_dir="/usr/local/share/devcontainer-features/lazygit/themes"
    shellrc_content="${shellrc_content//THEME_PLACEHOLDER/$THEME}"
    shellrc_content="${shellrc_content//THEMES_DIR_PLACEHOLDER/$themes_dir}"

    write_shellrc_feature "lazygit" "$shellrc_content"
}

# Execute main function
main "$@"

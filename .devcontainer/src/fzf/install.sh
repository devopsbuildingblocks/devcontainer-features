#!/usr/bin/env bash
#
# fzf Feature Installation Script
# Installs fzf via devbox global and sets up shell integration
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"
ENABLEKEYBINDINGS="${ENABLEKEYBINDINGS:-true}"
ENABLECOMPLETION="${ENABLECOMPLETION:-true}"
THEME="${THEME:-db2-dark}"
DEFAULTOPTIONS="${DEFAULTOPTIONS:---height 40% --layout=reverse --border}"

#######################################
# Install fzf via devbox global
#######################################
install_fzf() {
    log_info "Installing fzf (version: $VERSION)"

    local package_spec="fzf"
    if [ "$VERSION" != "latest" ]; then
        package_spec="fzf@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    # Verify installation
    if ! command_exists fzf; then
        log_error "fzf installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(fzf --version | head -n1)
    log_success "fzf installed: $installed_version"
}

#######################################
# Setup theme files to system location
# Copies themes from feature directory to /usr/local/share
#######################################
setup_themes() {
    local themes_src="themes"
    local themes_dest="/usr/local/share/devcontainer-features/fzf/themes"

    if [ -d "$themes_src" ]; then
        log_info "Installing fzf themes to $themes_dest"
        mkdir -p "$themes_dest"
        cp -r "$themes_src"/* "$themes_dest/"
        local theme_count
        theme_count=$(find "$themes_src" -maxdepth 1 -type f -name "*.theme" | wc -l)
        log_success "Installed $theme_count theme files"
    else
        log_warning "Themes directory not found, skipping theme installation"
    fi
}

#######################################
# Get fzf color scheme for a theme
# Reads from theme file and returns comma-separated color string
#######################################
get_theme_colors() {
    local theme="$1"
    local themes_dir="/usr/local/share/devcontainer-features/fzf/themes"
    local theme_file="${themes_dir}/${theme}.theme"

    if [ "$theme" = "none" ]; then
        echo ""
        return
    fi

    if [ ! -f "$theme_file" ]; then
        log_warning "Theme file not found: $theme_file, using db2-dark as fallback"
        theme_file="${themes_dir}/db2-dark.theme"
    fi

    if [ -f "$theme_file" ]; then
        # Read theme file, skip comments and empty lines, join with commas
        grep -v '^#' "$theme_file" | grep -v '^$' | tr '\n' ',' | sed 's/,$//'
    else
        echo ""
    fi
}

#######################################
# Generate shell integration content
#######################################
generate_shell_integration() {
    cat <<'EOF'
# fzf shell integration
# This file is sourced by ~/.shellrc.d/main.sh
# fzf is installed via devbox global, which is loaded by devbox-feature.sh

EOF

    # Build FZF_DEFAULT_OPTS with theme and other options
    local theme_colors
    theme_colors=$(get_theme_colors "$THEME")

    local fzf_opts=""
    if [ -n "$DEFAULTOPTIONS" ]; then
        fzf_opts="$DEFAULTOPTIONS"
    fi

    if [ -n "$theme_colors" ]; then
        if [ -n "$fzf_opts" ]; then
            fzf_opts="$fzf_opts --color=$theme_colors"
        else
            fzf_opts="--color=$theme_colors"
        fi
    fi

    if [ -n "$fzf_opts" ]; then
        cat <<EOF
# Default fzf options
export FZF_DEFAULT_OPTS="$fzf_opts"

EOF
    fi

    # Add key bindings and completion based on shell
    if [ "$ENABLEKEYBINDINGS" = "true" ] || [ "$ENABLECOMPLETION" = "true" ]; then
        cat <<'EOF'
# Setup fzf shell integration (key bindings and completion)
if command -v fzf &> /dev/null; then
    # Detect shell and load appropriate integration
    if [ -n "$ZSH_VERSION" ]; then
EOF
        if [ "$ENABLEKEYBINDINGS" = "true" ] && [ "$ENABLECOMPLETION" = "true" ]; then
            cat <<'EOF'
        # Full integration for zsh
        eval "$(fzf --zsh)"
EOF
        elif [ "$ENABLEKEYBINDINGS" = "true" ]; then
            cat <<'EOF'
        # Key bindings only for zsh
        source <(fzf --zsh | grep -A 1000 "^# Key bindings")
EOF
        elif [ "$ENABLECOMPLETION" = "true" ]; then
            cat <<'EOF'
        # Completion only for zsh
        source <(fzf --zsh | grep -B 1000 "^# Key bindings" | head -n -1)
EOF
        fi
        cat <<'EOF'
    elif [ -n "$BASH_VERSION" ]; then
EOF
        if [ "$ENABLEKEYBINDINGS" = "true" ] && [ "$ENABLECOMPLETION" = "true" ]; then
            cat <<'EOF'
        # Full integration for bash
        eval "$(fzf --bash)"
EOF
        elif [ "$ENABLEKEYBINDINGS" = "true" ]; then
            cat <<'EOF'
        # Key bindings only for bash
        source <(fzf --bash | grep -A 1000 "^# Key bindings")
EOF
        elif [ "$ENABLECOMPLETION" = "true" ]; then
            cat <<'EOF'
        # Completion only for bash
        source <(fzf --bash | grep -B 1000 "^# Key bindings" | head -n -1)
EOF
        fi
        cat <<'EOF'
    fi
fi

EOF
    fi

    # Add file preview for Ctrl+T (uses bat if available, only for files)
    cat <<'EOF'
# Set up fzf Ctrl+T preview (only for files, uses bat if available)
if command -v bat &> /dev/null; then
    export FZF_CTRL_T_OPTS="--preview '[[ -f {} ]] && bat --style=numbers --color=always --line-range=:500 {} || echo \"(directory)\"'"
else
    export FZF_CTRL_T_OPTS="--preview '[[ -f {} ]] && cat {} || echo \"(directory)\"'"
fi

# Track current fzf theme
EOF

    # Add current theme tracking
    cat <<EOF
export CURRENT_FZF_THEME="${THEME}"
EOF

    # Add theme helper functions
    cat <<'EOF'

#######################################
# List available fzf themes
#######################################
fzf-themes() {
    local themes_dir="/usr/local/share/devcontainer-features/fzf/themes"

    echo "Available fzf themes:"
    echo "  db2-dark            - DevOpsBuildingBlocks dark theme (default)"
    echo "  db2-light           - DevOpsBuildingBlocks light theme"
    echo "  tokyo-night         - Tokyo Night theme"
    echo "  one-dark            - Atom One Dark theme"
    echo "  dracula             - Dracula theme"
    echo "  catppuccin          - Catppuccin Mocha theme"
    echo "  nord                - Nord theme"
    echo "  gruvbox             - Gruvbox theme"
    echo "  none                - No theme (use terminal defaults)"
    echo ""
    echo "Current theme: ${CURRENT_FZF_THEME:-unknown}"
    echo ""
    echo "Usage: fzf-theme <theme-name>"
}

#######################################
# Switch fzf theme
# Updates FZF_DEFAULT_OPTS with new theme colors
#######################################
fzf-theme() {
    if [ -z "$1" ]; then
        echo "Error: No theme specified"
        echo ""
        fzf-themes
        return 1
    fi

    local theme="$1"
    local themes_dir="/usr/local/share/devcontainer-features/fzf/themes"
    local theme_file="${themes_dir}/${theme}.theme"

    # Handle "none" theme
    if [ "$theme" = "none" ]; then
        # Remove color settings from FZF_DEFAULT_OPTS
        export FZF_DEFAULT_OPTS=$(echo "$FZF_DEFAULT_OPTS" | sed 's/--color=[^ ]*//' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
        export CURRENT_FZF_THEME="none"
        echo "fzf theme disabled (using terminal defaults)"
        return 0
    fi

    # Validate theme file exists
    if [ ! -f "$theme_file" ]; then
        echo "Error: Theme '$theme' not found"
        echo "Available themes:"
        find "$themes_dir" -name "*.theme" -exec basename {} .theme \; 2>/dev/null | sort | sed 's/^/  /'
        return 1
    fi

    # Read theme colors from file
    local theme_colors
    theme_colors=$(grep -v '^#' "$theme_file" | grep -v '^$' | tr '\n' ',' | sed 's/,$//')

    if [ -z "$theme_colors" ]; then
        echo "Error: Could not read theme colors from $theme_file"
        return 1
    fi

    # Update FZF_DEFAULT_OPTS with new colors
    # First remove any existing --color option, then add the new one
    local new_opts
    new_opts=$(echo "$FZF_DEFAULT_OPTS" | sed 's/--color=[^ ]*//' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')

    if [ -n "$new_opts" ]; then
        export FZF_DEFAULT_OPTS="$new_opts --color=$theme_colors"
    else
        export FZF_DEFAULT_OPTS="--color=$theme_colors"
    fi

    export CURRENT_FZF_THEME="$theme"
    echo "Switched fzf theme to: $theme"
}
EOF
}

#######################################
# Set up shell integration for fzf
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(generate_shell_integration)

    write_shellrc_feature "fzf" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting fzf installation"

    install_fzf
    setup_themes
    setup_shell_integration

    log_success "fzf feature installation complete"
}

# Execute main function
main "$@"

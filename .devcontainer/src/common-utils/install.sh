#!/bin/bash
set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Need to do this because of this issue https://github.com/devcontainers/cli/issues/331
if [ "$_REMOTE_USER" != "root" ]; then
  _REMOTE_USER_HOME="/home/${_REMOTE_USER}"
else
  _REMOTE_USER_HOME="/root"
fi

shellrc_dir="${_REMOTE_USER_HOME}/.shellrc.d"
shells=("zsh" "bash")

#######################################
# Setup shellrc.d directory and main loader
#######################################
setup_config() {
  # Create shellrc.d directory
  mkdir -p "$shellrc_dir"

  # Create main.sh - sources feature scripts then sets shell configuration
  local main_config="${shellrc_dir}/main.sh"
  cat << 'EOF' > "$main_config"
# =============================================================================
# Shell Configuration Main Loader
# Created by common-utils feature
# =============================================================================

# Source all feature scripts
for f in ~/.shellrc.d/*.sh; do
  [ "$f" = ~/.shellrc.d/main.sh ] && continue
  [ -r "$f" ] && source "$f"
done

# =============================================================================
# Shell Configuration (runs last to ensure final state)
# =============================================================================

export SHELL="/usr/bin/zsh"

# =============================================================================
# Shell History Configuration
# Enables cross-terminal history sharing and persistence
# History is stored in ~/.shell_history/ which is volume-mounted for persistence
# =============================================================================

# Ensure history directory exists (handles both pre and post symlink states)
if [ ! -d "${HOME}/.shell_history" ]; then
    mkdir -p "${HOME}/.shell_history"
fi

# Zsh history settings
if [ -n "$ZSH_VERSION" ]; then
    export HISTFILE="${HOME}/.shell_history/zsh_history"
    export HISTSIZE=50000
    export SAVEHIST=50000

    # Share history immediately between all terminals
    setopt SHARE_HISTORY          # Share history between all sessions
    setopt INC_APPEND_HISTORY     # Write to history immediately, not on shell exit
    setopt EXTENDED_HISTORY       # Save timestamp and duration
    setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first
    setopt HIST_IGNORE_DUPS       # Don't record duplicates
    setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
    setopt HIST_FIND_NO_DUPS      # Don't display duplicates when searching
    setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
    setopt HIST_VERIFY            # Show command before executing from history
fi

# Bash history settings
if [ -n "$BASH_VERSION" ]; then
    export HISTFILE="${HOME}/.shell_history/bash_history"
    export HISTSIZE=50000
    export HISTFILESIZE=50000
    export HISTCONTROL=ignoreboth:erasedups
    export HISTTIMEFORMAT="%F %T "

    # Append to history instead of overwriting
    shopt -s histappend

    # Sync history after each command for cross-terminal sharing
    # -a: append new history lines to the history file
    # -n: read new lines from history file into current session
    __sync_history() {
        history -a
        history -n
    }
    if [[ ! "$PROMPT_COMMAND" =~ __sync_history ]]; then
        PROMPT_COMMAND="__sync_history${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    fi
fi
EOF
  chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "$shellrc_dir"

  # Source main.sh from shell RC files
  for shell in "${shells[@]}"; do
    echo "source \"${shellrc_dir}/main.sh\"" >> "${_REMOTE_USER_HOME}/.${shell}rc"
    chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "${_REMOTE_USER_HOME}/.${shell}rc"
  done

  log_success "Created shellrc.d infrastructure"
}

setup_volume_mounts() {
  create_volume_symlink_script "common-utils" ".cache" ".local" ".shell_history"
}

#######################################
# Main installation function
#######################################
main() {
  log_info "Starting common-utils setup"

  setup_config
  setup_volume_mounts

  log_success "Common-utils feature installation complete"
}

# Execute main function
main "$@"
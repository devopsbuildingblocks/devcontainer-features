This feature installs the `claude-code` CLI for interacting with Anthropic's Claude API and the official Anthropic Claude VS Code extension.

### Installation & Configuration
*   It relies on the `devbox` feature to manage the installation.
*   The specified version of `claude-code` is installed as a global `devbox` package.
*   It installs the `anthropic.claude-code` VS Code extension.
*   To ensure Claude's configuration is persisted across container sessions, the feature creates symlinks from the user's home directory (`~/.claude` and `~/.claude.json`) to a mounted Docker volume.
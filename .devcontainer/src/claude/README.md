
# Claude Code (claude)

Installs claude-code and vscode extension

## Example Usage

```json
"features": {
    "ghcr.io/devopsbuildingblocks/devcontainer-features/claude:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of claude-code to install | string | latest |

## Customizations

### VS Code Extensions

- `anthropic.claude-code`

This feature installs the `claude-code` CLI for interacting with Anthropic's Claude API and the official Anthropic Claude VS Code extension.

### Installation & Configuration
*   It relies on the `devbox` feature to manage the installation.
*   The specified version of `claude-code` is installed as a global `devbox` package.
*   It installs the `anthropic.claude-code` VS Code extension.
*   To ensure Claude's configuration is persisted across container sessions, the feature creates symlinks from the user's home directory (`~/.claude` and `~/.claude.json`) to a mounted Docker volume.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._

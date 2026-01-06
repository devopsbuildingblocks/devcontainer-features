
# Gemini CLI (gemini)

Installs gemini-cli and vscode extension

## Example Usage

```json
"features": {
    "ghcr.io/devopsbuildingblocks/devcontainer-features/gemini:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of gemini-cli to install | string | latest |

## Customizations

### VS Code Extensions

- `google.geminicodeassist`

This feature installs the `gemini-cli` for interacting with Google's Gemini API and the official Google Gemini VS Code extension.

### Installation & Configuration
*   It relies on the `devbox` feature to manage the installation.
*   The specified version of `gemini-cli` is installed as a global `devbox` package.
*   It installs the `google.geminicodeassist` VS Code extension.
*   To ensure Gemini's configuration and history are persisted across container sessions, the feature creates a symlink from the user's home directory (`~/.gemini`) to a mounted Docker volume.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._

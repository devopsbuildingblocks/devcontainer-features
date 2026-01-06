
# Eza (eza)

Installs eza, a modern replacement for ls with Git integration and colorful output, via devbox global

## Example Usage

```json
"features": {
    "ghcr.io/devopsbuildingblocks/devcontainer-features/eza:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of eza to install | string | latest |
| theme | Color theme for eza (db2-dark, db2-light, or none for defaults) | string | db2-dark |
| aliasAsLs | Create aliases for ls commands (ls, ll, la, lt, l) to use eza | boolean | true |
| enableIcons | Enable icons in output (requires Nerd Fonts in terminal) | boolean | false |

This feature installs `eza`, a modern and feature-rich replacement for the standard `ls` command.

### Installation & Configuration
*   Relies on the `devbox` feature to install the specified version of `eza`.
*   Applies a color theme by creating a configuration directory at `~/.config/eza` and symlinking the selected theme file. This allows `eza` to automatically pick up the theme.

### Shell Integration
The feature adds the following capabilities to the user's shell environment:
*   **`ls` Aliases:** If enabled, it replaces the standard `ls` command and other common variants (`ll`, `la`, `lt`, `l`) with aliases that point to `eza`, providing more colorful and informative output by default.
*   **Icon Support:** If enabled, the `--icons` flag is added to the aliases, displaying file-type-specific icons (requires a Nerd Font to be installed in the terminal).
*   `eza-themes`: A command to list the available color themes.
*   `eza-theme <theme-name>`: A command to dynamically switch the active theme by updating the theme symlink.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._

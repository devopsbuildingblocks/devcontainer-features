
# Lazygit (lazygit)

Installs lazygit, a simple terminal UI for git commands, via devbox global

## Example Usage

```json
"features": {
    "ghcr.io/devopsbuildingblocks/devcontainer-features/lazygit:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of lazygit to install | string | latest |
| theme | Color theme for lazygit UI (includes branchColors and theme configuration) | string | db2-dark |
| enableGitDiffPager | Enable pager for git diff viewing in lazygit | boolean | false |

This feature installs `lazygit`, a popular terminal-based UI for Git, and provides significant shell integration for a rich user experience.

### Installation & Configuration
*   Relies on the `devbox` feature to install the specified version of `lazygit`.
*   Creates a configuration file at `~/.config/lazygit/config.yml` with sensible defaults.
*   Installs a collection of custom themes and applies the one selected during setup.
*   If the `enableGitDiffPager` option is set, it configures `lazygit` to use `delta` for viewing diffs, providing a side-by-side view.

### Shell Integration
The feature adds the following commands to the user's shell environment:
*   `lzg`: A convenient alias for the `lazygit` command.
*   `lzg-themes`: A command to list all available color themes for `lazygit`.
*   `lzg-theme <theme-name>`: A powerful command to dynamically switch the active `lazygit` theme. This command regenerates the configuration file to apply the new theme instantly.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._


# Delta (delta)

Installs delta, a syntax-highlighting pager for git, diff, and grep output, via devbox global

## Example Usage

```json
"features": {
    "ghcr.io/devopsbuildingblocks/devcontainer-features/delta:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of delta to install | string | latest |
| configureGit | Automatically configure git to use delta as the default pager | boolean | true |
| theme | Color theme for delta syntax highlighting (auto detects light/dark mode) | string | TwoDark |
| features | Delta feature set: default (basic), side-by-side (two-column diff), line-numbers, or decorations (commit info) | string | default |

### Dependencies

> **Required:** This feature requires the `devbox` feature (and its dependencies) to be installed first.
>
> To simplify setup, use a prebuilt base image that includes all dependencies:
> - `ghcr.io/devopsbuildingblocks/devcontainer-images/ubuntu-devbox` (includes `lib`, `common-utils`, `nix`, and `devbox`)

This feature installs `delta`, a powerful syntax-highlighting pager for `git`, `diff`, and `grep` output.

### Installation & Configuration
*   Relies on the `devbox` feature to install the specified version of `delta`.
*   If the `configureGit` option is enabled, it automatically configures Git to use `delta` as the default pager for commands like `git diff` and `git log`.
*   This configuration is applied via a `postCreateCommand` to ensure it works correctly even when custom dotfiles are mounted.
*   The selected theme and feature set (e.g., `side-by-side`) are also applied to the Git configuration.

### Shell Integration
The feature adds the following commands to the user's shell environment:
*   `diff`: An alias for the `delta` command.
*   `delta-themes`: A command to show the list of available themes.
*   `delta-theme <theme-name>`: A command to dynamically switch the active `delta` theme by updating the Git configuration.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._

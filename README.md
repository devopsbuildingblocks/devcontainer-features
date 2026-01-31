# Devcontainer Features

This repository contains a collection of
[Dev Container features](https://containers.dev/implementors/features/) used to
create modern, flexible development environments using
[Dev Containers](https://containers.dev) and
[Devbox](https://www.jetify.com/docs/devbox).

## Available Features

- [bat](.devcontainer/src/bat): A cat clone with syntax highlighting.
- [claude](.devcontainer/src/claude): An AI assistant from Anthropic (Terminal
  based AI and vscode extension).
- [common-utils](.devcontainer/src/common-utils): Common utilities for dev
  containers.
- [delta](.devcontainer/src/delta): Better git diffs.
- [devbox](.devcontainer/src/devbox): Instant, easy, and predictable development
  environments based on Nix packages.
- [eza](.devcontainer/src/eza): A modern replacement for ls.
- [fzf](.devcontainer/src/fzf): A command-line fuzzy finder (try using ctl+r and
  ctl+t).
- [gemini](.devcontainer/src/gemini): An AI assistant from Google (terminal
  based AI and vscode extension).
- [k9s](.devcontainer/src/k9s): A terminal UI for Kubernetes clusters.
- [lazygit](.devcontainer/src/lazygit): A terminal UI (TUI) for git.
- [lib](.devcontainer/src/lib): A library of common functions for dev container
  features.
- [oh-my-posh](.devcontainer/src/oh-my-posh): A prompt theme engine.
- [ripgrep](.devcontainer/src/ripgrep): A fast line-oriented search tool.

## Usage

To use a feature, add it to your `devcontainer.json` file. For example, to use
the `bat` feature, you would add the following to your `devcontainer.json`:

```json
"features": {
    "ghcr.io/devops-building-blocks/devcontainer-features/bat:0": {}
}
```

## Testing

To test the features in this repository, you can use the `test` task.

```sh
task test -- <feature you want to test>
```

See the `Taskfile.yml` for the devcontainer cli command.

## Docs

To generate docs for the features in this repository, you can use the `docs` task.

```sh
task docs
```

See the `Taskfile.yml` for the devcontainer cli command.

## References

- [Dev Containers](https://containers.dev)
- [Dev Container Features](https://containers.dev/implementors/features/)
- [Dev Container CLI](https://github.com/devcontainers/cli)

# den summary

`den` is a personal, declarative configuration for machines, user environment, software, and development tooling.

## Current model

- `home/` contains shared Home Manager modules.
- `modules/darwin/` contains reusable macOS behavior.
- `hosts/macbook.nix` is the sole current host entry point.
- `flake.nix` exposes `homeConfigurations.macbook`.
- `home-nixos` and NixOS system modules are intentionally deferred.

## Current configuration

The shared Home Manager configuration provides zsh setup with Starship, Git defaults and aliases, GitHub SSH host configuration, direnv/nix-direnv, tmux, CLI utilities, language runtimes, cloud tools, Docker CLI tooling, and `uv`.

The MacBook is actively managed by Home Manager, including public Git identity and iTerm preferences. Credentials and machine account identity remain external. VS Code uses its existing Settings Sync. The current shell remains unchanged until the user changes it outside `den`.

## Roadmap

1. Extend the active macOS configuration as real needs appear.
2. Expand user-level application, editor, terminal, font, and service modules where useful.
3. Create the eventual NixOS flake and integrate Home Manager without modifying the current NixOS configuration prematurely.

Activation is explicit through `den switch <host>`.

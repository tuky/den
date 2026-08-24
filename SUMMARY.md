# den summary

`den` is a personal, declarative configuration for machines, user environment, software, and development tooling.

## Current model

- `home/` contains shared Home Manager modules.
- `modules/linux/` and `modules/darwin/` contain reusable platform behavior.
- `hosts/wsl.nix`, `hosts/gcp.nix`, and `hosts/macbook.nix` are concrete host entry points.
- `flake.nix` exposes `homeConfigurations.wsl`, `.gcp`, and `.macbook`.
- `home-nixos` and NixOS system modules are intentionally deferred.

## Current configuration

The shared Home Manager configuration provides zsh setup with Starship, Git defaults and aliases, GitHub SSH host configuration, direnv/nix-direnv, tmux, CLI utilities, language runtimes, cloud tools, Docker CLI tooling, and `uv`.

Git identity and all credentials are external because this is a public repository. The current shell remains unchanged until the user changes it outside `den`.

## Roadmap

1. Validate the `wsl` host on the existing WSL2 Ubuntu environment.
2. Add only real host-specific differences for GCP and macOS as those machines appear.
3. Expand user-level application, editor, terminal, font, and service modules where useful.
4. Create the eventual NixOS flake and integrate Home Manager without modifying the current NixOS configuration prematurely.

No machine has been bootstrapped or activated by this repository change.

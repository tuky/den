# Architecture

`den` describes what makes these machines mine. It is a personal configuration repository, not only a development-environment repository.

## Composition

The `darwinConfigurations.macbook` system in `flake.nix` combines:

1. `modules/darwin/default.nix` for nix-darwin system configuration;
2. `hosts/macbook.nix` for hardware/platform choices;
3. integrated Home Manager with `home/` and `modules/darwin/home.nix`.

```text
den
├── home/                 shared user configuration
├── modules/darwin/       separate system and Home Manager modules
└── hosts/macbook.nix     MacBook-specific choices
```

Platforms describe reusable operating-system behavior. Hosts describe actual environments.

## Boundaries

Home Manager owns user-level files, programs, packages, shell setup, Git, SSH client configuration, direnv, and future user services/resources. nix-darwin owns declared macOS system settings and applies Home Manager in the same switch. Nix daemon management stays with the installer (`nix.enable = false`); macOS updates and unmanaged applications remain native.

The existing NixOS machine is deliberately outside the current outputs. Its eventual host will combine NixOS system modules with Home Manager as a NixOS module. The existing traditional configuration is not changed as part of this repository work.

## Design choices

- Resolve `DEN_USER` and `DEN_HOME` before privilege elevation; reject missing/root identity.
- Keep host files small; add structure only when a real host difference appears.
- Keep machine account identity and credentials outside this public repository; manage public Git attribution in `home/git.nix`.
- Configure the GitHub SSH identity path, but never create or store its private key.
- Keep zsh as the only managed interactive shell; the login shell remains an external machine setting.
- Use Nix for reproducible tools where practical, including `uv` for Python environments.
- Treat Docker's CLI and daemon as separate concerns.

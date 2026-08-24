# Architecture

`den` describes what makes these machines mine. It is a personal configuration repository, not only a development-environment repository.

## Composition

Each standalone Home Manager host in `flake.nix` combines:

1. `home/` for common user configuration;
2. one reusable platform module from `modules/`;
3. one concrete host file from `hosts/`.

```text
den
├── home/                 shared user configuration
├── modules/linux/        reusable Linux behavior
├── modules/darwin/       reusable macOS behavior
├── hosts/wsl.nix         WSL2-specific choices
├── hosts/gcp.nix         GCP-specific choices
└── hosts/macbook.nix     MacBook-specific choices
```

Platforms describe reusable operating-system behavior. Hosts describe actual environments. WSL2 and GCP therefore share Linux modules without becoming one configuration.

## Boundaries

Home Manager owns user-level files, programs, packages, shell setup, Git, SSH client configuration, direnv, and future user services/resources. Ubuntu and macOS system services remain native to those operating systems until there is a concrete reason to manage them with Nix.

The existing NixOS machine is deliberately outside the current outputs. Its eventual host will combine NixOS system modules with Home Manager as a NixOS module. The existing traditional configuration is not changed as part of this repository work.

## Design choices

- Keep host files small; add structure only when a real host difference appears.
- Keep identity and credentials outside this public repository.
- Configure the GitHub SSH identity path, but never create or store its private key.
- Keep Bash as the current shell while sharing shell behavior with zsh for a future transition.
- Use Nix for reproducible tools where practical, including `uv` for Python environments.
- Treat Docker's CLI and daemon as separate concerns.

# Bootstrap

This document describes the intended manual flow. It does not install software, change shells, provision credentials, or activate a machine automatically.

## Standalone Home Manager hosts

For WSL2 or GCP Ubuntu:

1. Install Nix on the Ubuntu machine and enable flakes.
2. Install or invoke Home Manager.
3. Clone `den` and enter the checkout.
4. Provision SSH keys and other credentials outside the repository.
5. Inspect and activate the concrete host:

   ```bash
   nix run .#home-manager -- switch -b backup --flake .#wsl
   ```

   The backup flag handles existing Home Manager target files during the first activation. Afterward, use the installed command:

   ```bash
   home-manager switch --flake ~/.config/den#wsl
   ```

   The repository CLI is then available as `den` from any directory:

   ```bash
   den status
   den check
   den switch wsl
   ```

   GCP uses the analogous `.#gcp` host output.

For macOS, install Nix with flakes enabled, clone the repository, provision credentials externally, and activate:

```bash
nix run .#home-manager -- switch -b backup --flake .#macbook
```

Activation is deliberately explicit. Restart the shell afterward if the generated shell configuration needs to be loaded. The configured Docker CLI does not install a Docker daemon; use the platform's appropriate Docker setup.

## Existing NixOS machine

The home NixOS machine currently uses traditional configuration and is not modified by `den`. The later migration plan is:

1. keep the existing system configuration working;
2. create a NixOS flake and `home-nixos` host entry;
3. integrate Home Manager as a NixOS module;
4. migrate system and user configuration incrementally;
5. activate only after testing on the machine.

The eventual system command will be:

```bash
sudo nixos-rebuild switch --flake .#home-nixos
```

That output is intentionally not present yet.

## External credentials

Never place private SSH keys, API keys, tokens, passwords, cloud credentials, or service-account files in this repository. The expected GitHub key path is `~/.ssh/id_ed25519_github`; only its path is configured by `den`.

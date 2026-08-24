# Architecture & Design Decisions

This document explains the architectural choices made in `den` and why they matter for your multi-machine setup.

## Flake Structure

### Inputs
- **nixpkgs (unstable)**: Provides access to latest tools and packages
- **home-manager**: Declarative user-level configuration
- **flake-utils**: Simplifies multi-system support

### Outputs
The flake defines two Home Manager configurations:
- `linux`: For WSL2, GCP, and generic Linux environments
- `darwin`: For macOS (currently minimal, will expand when you get a Mac)

This allows a single flake to support different platforms through conditional module loading.

## Module Organization

### home-manager/
Contains common user configuration shared across all platforms:
- **home.nix**: Core packages and Home Manager setup
- **programs/**: Individual program configurations
  - git.nix: Git with GitHub SSH support
  - direnv.nix: Development environment management
  - shell.nix: Bash and Zsh (shared aliases, platform-specific extras)

### hosts/
Platform-specific overrides that extend the common configuration:
- **linux/**: WSL2, GCP, generic Linux
- **darwin/**: macOS (future)
- **nixos/**: Reserved for your existing NixOS machine migration (later)

This separation ensures:
1. Common configuration stays DRY and maintainable
2. Platform-specific tweaks are isolated and clear
3. New machines can reuse the common base with minimal overhead

## Design Principles

### 1. **Portable Over Clever**
- No complex abstractions or meta-programming
- Clear, readable Nix that doesn't require deep framework knowledge
- Easy for you to extend or modify

### 2. **External Over Declarative (for Secrets)**
- SSH keys, credentials, machine-specific secrets are provisioned separately
- The flake never manages or stores sensitive data
- This makes the repository genuinely public-safe

### 3. **Tooling via Nix Where Practical**
- Reproducible CLI tools (go, node, python, terraform, etc.)
- But Docker, native system services, and user-specific setup stay outside
- Example: Docker CLI is in Nix, but the daemon installation is per-machine

### 4. **Shell Configured for Transition**
- Common aliases/functions work in both bash and zsh
- Both are enabled and configured equally
- You can switch shells or transition to zsh without duplicating config

### 5. **Home Manager Flakes from Day One**
- Uses modern Home Manager patterns (flakes + pinned inputs)
- Compatible with future NixOS integration
- No legacy non-flake setup that would need migration

## Platform Specifics

### Linux (WSL2, GCP)
- Treated identically in `hosts/linux/home.nix`
- Uses systemd user services where available
- SSH and Git work the same as on macOS
- direnv is fully functional

### macOS (Future)
- Currently minimal in `hosts/darwin/home.nix`
- zsh enabled by default (macOS uses zsh system shell)
- Room for Homebrew integration when you acquire a Mac
- Some tools (Docker, certain CLIs) may need external setup

### NixOS (Existing Machine, Future)
- Not included in current flake (your existing setup remains untouched)
- `hosts/nixos/` is reserved for when you create a system flake
- When ready, you'll integrate `den` into your NixOS configuration
- Suggested approach: create `/etc/nixos/flake.nix` that imports den

## Key Assumptions

1. **Nix 2.4+** with flakes support (enables `nix flake` commands)
2. **Home Manager** as the user-level configuration tool
3. **nixpkgs unstable** for latest tooling
4. **Manual credential/SSH provisioning** outside the repository
5. **Git and SSH configuration** are common across all machines
6. **Python package management via uv** (not system package managers)

## What's NOT Here (Intentionally)

### System-level Configuration
- NixOS system configuration (for your existing home machine)
- systemd services, boot configuration, etc.
- These belong in `/etc/nixos/flake.nix` when you migrate

### Build/Dev Scripts
- Project-specific flakes and `.envrc` files belong in individual projects
- `den` provides the common base, not per-project scaffolding

### Complex Language Managers
- `pyenv`, `nvm`, `asdf`, `mise` are not included
- Nix itself provides reproducible version pinning
- Projects can use their own flakes with direnv

### Personal/Company-Specific Values
- Git name/email are placeholders
- GitHub username is not hardcoded
- Machine-specific aliases or settings should be added after bootstrapping

## Future Extensions

These are safe to add later without architectural changes:

### Soon (Phase 1)
- Additional CLI tools (ripgrep, fzf, etc.)
- VS Code settings (when using Remote SSH)
- More shell functions and aliases

### Later (Phase 2-3)
- Homebrew integration on macOS
- More granular program modules (neovim, tmux config, etc.)
- Development shells for specific language toolchains

### Eventually (Phase 4)
- NixOS system configuration
- Multi-user setup if needed
- More sophisticated secret management (sops-nix, etc.)

## Common Modifications

### Adding a Package
```nix
# In home-manager/home.nix, add to home.packages:
home.packages = with pkgs; [
  existingPackage
  newPackageName    # ← Add here
];
```

### Adding a Platform-Specific Package
```nix
# In hosts/linux/home.nix or hosts/darwin/home.nix:
home.packages = with pkgs; [
  platformSpecificTool
];
```

### Adding a New Program Configuration Module
```nix
# Create home-manager/programs/mynewprogram.nix
{ config, pkgs, lib, ... }:
{
  programs.mynewprogram = {
    enable = true;
    # Configuration here
  };
}

# Then import in home-manager/home.nix:
imports = [
  ./programs/git.nix
  ./programs/direnv.nix
  ./programs/shell.nix
  ./programs/mynewprogram.nix  # ← Add here
];
```

### Switching Shells
```bash
# Change your login shell (does not require Home Manager changes)
chsh -s ~/.nix-profile/bin/zsh

# Or on NixOS later:
chsh -s /run/current-system/sw/bin/zsh
```

## Troubleshooting Design

### Why Did You Separate Platform-Specific Config?
Because WSL2 and GCP are genuinely the same (Linux + Nix + Home Manager), but macOS and NixOS have different requirements. This structure makes it clear which configs apply where.

### Why Not Use a Template or Generate Code?
Explicit is better than implicit. Every file is readable Nix, not generated output. This makes it easier to debug, modify, and understand.

### Why Pin Everything in flake.lock?
Reproducibility. Two weeks from now, bootstrapping den will give you the exact same environment, bit-for-bit (modulo system libraries). This is critical for DevOps and backend work.

### Why No NixOS Configuration Yet?
Your existing NixOS machine is stable. Migrating it requires careful planning and testing. Starting with WSL2 lets you validate `den` without risk, then migrate the home machine when you're confident.

## Next Steps After Bootstrap

1. **Set your Git identity** (edit `home-manager/programs/git.nix`)
2. **Test on WSL2** (run `home-manager switch --flake .#linux`)
3. **Add your SSH key** to `~/.ssh/id_ed25519_github`
4. **Test Git/GitHub** (`ssh -T git@github.com`, `git clone` something)
5. **Add any tools you need** to `home-manager/home.nix`
6. **Iterate and improve** as you use it

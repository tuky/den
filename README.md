# den

A personal, reproducible development environment using Nix flakes and Home Manager.

## Overview

`den` is your portable personal development environment, designed to work consistently across multiple machines and operating systems:

- **NixOS** (existing home machine, migration planned later)
- **WSL2 Ubuntu** (primary test environment)
- **GCP Compute Engine Ubuntu** (future)
- **macOS** (future)

The repository contains your declarative user-level configuration via Home Manager and Nix flakes, while system-specific setup and credential provisioning remain external.

## Architecture

```
                    den (flake)
                     │
          ┌──────────┼──────────┐
          │          │          │
        NixOS       WSL2       macOS
          │          │          │
          └──────────┼──────────┘
                     │
                Home Manager
                     │
              shared user config
                     │
          ┌──────────┴──────────┐
          │                     │
     common tools          platform-specific
                           configuration
```

## Directory Structure

```
den/
├── flake.nix                 # Main Nix flake with all inputs and outputs
├── flake.lock               # Pinned versions (auto-generated, commit this)
├── README.md                # This file
├── LICENSE                  # MIT license
│
├── home-manager/
│   ├── home.nix            # Main Home Manager config (packages, state version)
│   ├── programs/
│   │   ├── git.nix         # Git configuration with SSH for GitHub
│   │   ├── direnv.nix      # direnv setup for project-specific environments
│   │   └── shell.nix       # Bash and Zsh configuration (shared + platform-specific)
│   └── shells/             # (Reserved for future shell-specific modules)
│
└── hosts/
    ├── linux/
    │   └── home.nix        # Linux-specific overrides (WSL2, GCP, generic Linux)
    ├── darwin/
    │   └── home.nix        # macOS-specific overrides (future)
    └── nixos/              # (Reserved for future NixOS system config migration)
```

## Quick Start

### Prerequisites

You need Nix with flakes support and Home Manager. See [Setup by Platform](#setup-by-platform) below.

### Bootstrap

1. **Clone or navigate to this repository:**
   ```bash
   cd ~/path/to/den
   ```

2. **Update flake inputs** (if needed):
   ```bash
   nix flake update
   ```

3. **Build the Home Manager configuration:**
   ```bash
   nix flake show
   ```
   This displays available configurations. You should see `linux` and `darwin`.

4. **Switch to your Home Manager configuration:**
   ```bash
   # For Linux (WSL2, GCP, etc.)
   home-manager switch --flake .#linux
   
   # For macOS (future)
   home-manager switch --flake .#darwin
   ```

5. **Verify installation:**
   ```bash
   which git
   which direnv
   which go
   python3 --version
   ```

### Updating Configuration

After modifying any `.nix` file:

```bash
home-manager switch --flake .#linux   # or .#darwin
```

To update all Nix inputs to their latest versions:

```bash
nix flake update
```

## Setup by Platform

### WSL2 Ubuntu

1. **Install Nix:**
   ```bash
   curl -L https://nixos.org/nix/install | sh
   source ~/.nix-profile/etc/profile.d/nix.sh
   ```

2. **Enable flakes** (add to `~/.config/nix/nix.conf` or `~/.nix-profile/etc/nix/nix.conf`):
   ```
   experimental-features = nix-command flakes
   ```

3. **Install Home Manager:**
   ```bash
   nix run home-manager/master -- switch --flake ~/.config/den#linux
   ```
   (Adjust path if your clone is elsewhere.)

4. **SSH Setup:**
   - Ensure your GitHub SSH key exists at `~/.ssh/id_ed25519_github`
   - Test: `ssh -T git@github.com`

5. **Verify Git is configured:**
   ```bash
   git config --global user.name
   git config --global user.email
   # If blank, update in flake and re-apply: home-manager switch --flake .#linux
   ```

### GCP Compute Engine (Ubuntu)

Same as WSL2 above, but run in a GCP VM instead. The configuration is identical because both use Linux + Nix + Home Manager + den.

### macOS (Future)

When you acquire a Mac:

1. **Install Nix:**
   ```bash
   curl -L https://nixos.org/nix/install | sh
   ```

2. **Enable flakes:**
   Edit `~/.config/nix/nix.conf`:
   ```
   experimental-features = nix-command flakes
   ```

3. **Install Home Manager:**
   ```bash
   nix run home-manager/master -- switch --flake ~/.config/den#darwin
   ```

4. **macOS-specific notes:**
   - zsh will be the default shell (configured in `hosts/darwin/home.nix`)
   - Docker, Terraform, and similar tools may require additional setup outside Home Manager
   - See `hosts/darwin/home.nix` for platform-specific overrides

### Existing NixOS Machine (Later)

This repository does **not** yet include system-level NixOS configuration. To migrate your existing NixOS setup later:

1. **Validate den on WSL2 or another Linux first**
2. **Create a system flake** (e.g., `/etc/nixos/flake.nix`) that uses both:
   - Your system configuration
   - Home Manager from this repository (`den`)
3. **Incrementally migrate** user configuration from your current setup
4. **Test on the NixOS machine** before making it the primary environment

For now, keep your existing `/etc/nixos` configuration as-is.

## Included Tools

The default configuration installs:

**Languages & Runtimes:**
- Go
- Node.js 20
- Python 3.12
- uv (Python package manager)

**DevOps & Cloud:**
- Docker
- Docker Compose
- Terraform
- Google Cloud CLI (`gcloud`)
- GitHub CLI (`gh`)

**Utilities:**
- direnv (project-specific development environments)
- tmux (terminal multiplexer)
- jq (JSON processor)
- yq (YAML processor)
- git, curl, wget, openssh

**Shell:**
- Bash (current default)
- Zsh (configured, ready for gradual transition)

## Configuration

### Git

Edit `home-manager/programs/git.nix`:
- Update `userEmail` and `userName` to your actual values
- Add more aliases or settings as needed
- SSH is configured to use `~/.ssh/id_ed25519_github` (see [SSH Setup](#ssh-setup) below)

### Shell

Edit `home-manager/programs/shell.nix`:
- Modify common aliases and functions in `commonShellConfig`
- Add bash-specific settings in the `programs.bash` section
- Add zsh-specific settings in the `programs.zsh` section

### direnv

Edit `home-manager/programs/direnv.nix`:
- Configure direnv behavior (timeouts, dotenv loading, etc.)
- Add `.envrc.template` for project setup instructions

### Adding More Packages

Edit `home-manager/home.nix`:
- Add packages to the `home.packages` list
- Search nixpkgs: `nix search nixpkgs jq`

### Platform-Specific Configuration

- **Linux (WSL2, GCP, etc.):** Edit `hosts/linux/home.nix`
- **macOS:** Edit `hosts/darwin/home.nix`

## SSH Setup

Your GitHub SSH key must be provisioned separately:

1. **Generate or import your key** (outside this repository):
   ```bash
   # If you don't have one yet:
   ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_github -N ""
   
   # Add to GitHub: https://github.com/settings/keys
   ```

2. **Verify the key works:**
   ```bash
   ssh -T git@github.com
   # Expected: "Hi <username>! You've successfully authenticated..."
   ```

3. **den configures SSH to use this key**, but does **not** create or manage the private key.

## Development

To work on `den` itself:

```bash
# Enter the development shell with formatting tools
nix flake show  # View available configurations

# Format Nix files
nix fmt

# Check for syntax errors
nix flake check

# Test the configuration without applying it
nix flake show .#linux
```

## Troubleshooting

### "experimental-features not enabled"

Add to `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

### Git user name/email not set

Edit `home-manager/programs/git.nix` and update:
```nix
userEmail = "your-email@example.com";
userName = "Your Name";
```

Then:
```bash
home-manager switch --flake .#linux
```

### direnv not activating in shells

Ensure you've run:
```bash
home-manager switch --flake .#linux
```

And restart your shell.

### SSH key not working

Verify the key file exists and permissions are correct:
```bash
ls -la ~/.ssh/id_ed25519_github
ssh-keygen -y -f ~/.ssh/id_ed25519_github  # Should output public key
```

If the key is new, add it to GitHub: https://github.com/settings/keys

## Future Work

### Phase 1: Validate (Current)
- [ ] Test on WSL2 Ubuntu
- [ ] Verify all tools work as expected
- [ ] Test Git and GitHub SSH integration
- [ ] Test direnv with a simple project

### Phase 2: Expand
- [ ] Add more developer tools as needed
- [ ] Fine-tune shell configuration
- [ ] Test on GCP Compute Engine

### Phase 3: Prepare for macOS
- [ ] Test on macOS (when acquired)
- [ ] Add Homebrew integration if desired
- [ ] Update zsh configuration for macOS defaults

### Phase 4: NixOS Migration
- [ ] Create system-level flake for existing NixOS machine
- [ ] Integrate den Home Manager configuration
- [ ] Gradually migrate system configuration
- [ ] Test and validate

## Notes & Assumptions

1. **Nix version:** This assumes a recent Nix with flakes support (nix 2.4+). WSL2 and GCP require manual installation.

2. **Home Manager compatibility:** The `flake.lock` pins compatible versions of Home Manager and nixpkgs. If you encounter version mismatches, regenerate `flake.lock`:
   ```bash
   nix flake update
   ```

3. **Secrets are external:** SSH keys, credentials, and machine-specific configuration are **not** stored in this repository. Provision them separately.

4. **Bash vs. Zsh:** Bash is currently the default, but both are configured. You can switch shells without recreating the environment:
   ```bash
   chsh -s /run/current-system/sw/bin/zsh   # On NixOS
   chsh -s ~/.nix-profile/bin/zsh            # On WSL2/GCP
   ```

5. **Public repository:** This repository is intended to be public. Do not commit credentials, API keys, SSH private keys, or machine-specific secrets.

6. **Python environment management:** `uv` is included for Python package/environment management. Projects can use their own `flake.nix` with `direnv` for reproducible development environments.

7. **Docker on WSL2:** Docker Desktop or Docker-on-WSL will need to be installed and configured separately; `home-manager` provides the CLI tools but not the daemon.

8. **State version:** Home Manager's `home.stateVersion` is set to `24.05`. Changing this requires careful migration; see [Home Manager docs](https://nix-community.github.io/home-manager/index.html#sec-flakes-standalone).

## License

MIT License - See LICENSE file for details.

This repository structure is provided as a foundation for your personal development environment. You are free to modify, fork, or extend it as needed.

## Contributing to Your Own Repository

This is your personal repository. Contributions are for your own use. If you wish to share configurations or patterns, consider publishing a public reference version.

---

For questions or issues, refer to:
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [nixpkgs Manual](https://nixos.org/nixpkgs/manual/)

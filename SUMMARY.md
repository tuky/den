# den Bootstrap Summary

## Repository Structure

```
den/
├── flake.nix                      # Main Nix flake configuration
├── flake.lock                     # (Auto-generated; will be created on first `nix flake update`)
├── README.md                      # Full documentation
├── BOOTSTRAP.md                   # Quick start guide
├── ARCHITECTURE.md                # Design decisions and rationale
├── LICENSE                        # MIT license
├── .gitignore                     # Standard Nix-project ignores
│
├── home-manager/
│   ├── home.nix                   # Main Home Manager entry point (packages, state)
│   └── programs/
│       ├── git.nix                # Git + GitHub SSH configuration
│       ├── direnv.nix             # direnv for project environments
│       └── shell.nix              # Bash and Zsh (shared + extensible)
│
├── hosts/
│   ├── linux/home.nix             # Linux-specific overrides (WSL2, GCP, generic)
│   ├── darwin/home.nix            # macOS-specific overrides (future; minimal now)
│   └── nixos/                     # (Reserved for future NixOS system config)
│
└── scripts/
    └── den.sh                     # Helper script for common operations
```

## Key Architectural Decisions

### 1. **Flakes + Home Manager from the start**
   - **Why**: Modern Nix patterns, clean input management, reproducible across time
   - **Impact**: Requires nix 2.4+ with flakes enabled, but gives you declarative configuration that won't break
   - **Future proof**: Compatible with eventual NixOS migration

### 2. **Single flake with platform-conditional outputs**
   - **Why**: One source of truth for both Linux and macOS (DRY principle)
   - **How**: Flake defines `linux` and `darwin` homeConfigurations; you choose which to activate
   - **Benefit**: New machines reuse the same structure; platform differences are isolated

### 3. **home-manager/home.nix as hub**
   - **Core imports**: All program modules live there (git.nix, direnv.nix, shell.nix)
   - **Core packages**: Common CLI tools for all platforms
   - **Platform isolation**: hosts/linux/ and hosts/darwin/ extend, not replace

### 4. **Shell configuration designed for bash→zsh transition**
   - **Current**: Both bash and zsh enabled; common aliases/functions in shell.nix
   - **Future**: You can switch to zsh without duplicating config
   - **macOS**: zsh is the natural default when you get a Mac

### 5. **Git SSH configured but key managed separately**
   - **Why**: Repository is public; private keys must never be committed
   - **How**: Git points to `~/.ssh/id_ed25519_github`, but you provision the key
   - **Benefit**: You can regenerate or rotate keys without touching den

### 6. **Secrets and credentials are external**
   - **Principle**: The repository should be genuinely public-safe
   - **Implication**: Machine-specific values (username? hostname? sensitive env vars?) belong outside den
   - **Design**: den provides the environment; you add the credentials

### 7. **Standard Nix patterns, not custom abstractions**
   - **Approach**: Readable, idiomatic Nix that Home Manager users will recognize
   - **No**: Custom builders, clever meta-programming, or heavy abstraction layers
   - **Benefit**: Anyone familiar with Home Manager can understand and extend den

## Deliberately Left for Later

### Phase 1: Foundation ✓ (Complete)
- [x] Flake structure
- [x] Home Manager setup
- [x] Core CLI tools (Go, Node, Python, Docker, Terraform, gcloud, etc.)
- [x] Git configuration
- [x] Shell setup (bash + zsh foundation)
- [x] direnv integration
- [x] Documentation

### Phase 2: Validation & Refinement (You, next)
- [ ] Test on WSL2 Ubuntu
- [ ] Verify all tools work
- [ ] Test GitHub SSH integration
- [ ] Fine-tune shell aliases/functions based on actual use
- [ ] Add any missing tools you discover

### Phase 3: macOS Preparation
- [ ] Test on macOS when acquired
- [ ] Add Homebrew integration (if desired)
- [ ] Validate zsh configuration
- [ ] Update hosts/darwin/home.nix with real macOS-specific settings

### Phase 4: NixOS Migration (Distant future)
- [ ] Create `/etc/nixos/flake.nix` for your existing home machine
- [ ] Integrate den's Home Manager configuration
- [ ] Gradually migrate system configuration
- [ ] Test, validate, deploy

### Not Yet Included (Intentionally)
- **Language-specific version managers**: Use Nix + project-level flakes + direnv instead of nvm/pyenv/asdf
- **Full application configurations**: neovim, tmux config, elaborate shell themes — add as you need them
- **VS Code settings sync**: Focus on CLI environment; VS Code config is separate (consider Settings Sync)
- **NixOS system configuration**: Your existing /etc/nixos stays as-is until you're ready to migrate
- **Advanced secret management**: sops-nix, agenix, etc. — add only if you need it

## Assumptions Made

1. **You'll bootstrap on WSL2 first**, not on your existing NixOS machine
   - Allows you to validate den in a low-risk environment
   - Existing NixOS setup remains untouched

2. **Nix is installed separately**, outside Home Manager
   - Home Manager assumes Nix exists on the system
   - den doesn't try to install or manage Nix itself

3. **GitHub SSH key already exists** (or you'll create one manually)
   - den configures SSH to use `~/.ssh/id_ed25519_github`, but doesn't create it
   - Credential provisioning is your responsibility

4. **You control your Git identity** (name, email)
   - Placeholder values in git.nix; you update them before first use
   - This prevents accidents like committing with generic names

5. **direnv is used for project-specific environments**
   - Individual projects have their own flake.nix + .envrc
   - den provides the base tools; projects customize via flake

6. **flake.lock will be committed** (and checked in)
   - Ensures reproducibility across time and machines
   - You'll run `nix flake update` intentionally when you want to upgrade

7. **Platform differences are minimal**
   - Bash/Zsh works the same on Linux and macOS
   - Tool list is mostly the same across platforms
   - Major differences (Docker daemon, system services) are external to den

## Issues Requiring Your Decision

### 1. **Git User Identity**
   - **What's missing**: Your actual Git name and email
   - **Where**: `home-manager/programs/git.nix`, lines ~10-11
   - **Decision needed**: Update to your real values before first use
   - **Impact**: Otherwise, git commits will have placeholder values

### 2. **SSH Key Provisioning**
   - **What's missing**: The actual `~/.ssh/id_ed25519_github` private key
   - **Where**: Must be created/copied to `~/.ssh/id_ed25519_github` (outside repository)
   - **Decision needed**: Bring your existing key, or generate a new one
   - **Impact**: Without this, SSH access to GitHub won't work

### 3. **Python Environment Management**
   - **Current setup**: uv is installed for Python package management
   - **Question**: Do you want `uv pip` as your primary, or prefer a different tool?
   - **Impact**: This affects how you'll structure Python projects
   - **Recommendation**: Use uv per the prompt, but can switch later

### 4. **Shell Default Choice**
   - **Current**: Bash is not explicitly set as default; both bash and zsh are configured
   - **Your system's default**: Depends on your distro/WSL configuration
   - **Decision needed**: Do you want to explicitly set zsh as default, or keep bash?
   - **Impact**: If you want zsh now, add to hosts/linux/home.nix after bootstrap
   - **Implementation**: `home.defaultUserShell = pkgs.zsh;`

### 5. **Docker Integration**
   - **What's included**: Docker CLI + Docker Compose tools
   - **What's NOT included**: Docker daemon installation or configuration
   - **Decision needed**: How will you install Docker on WSL2? (Docker Desktop? Docker-on-WSL? Rancher Desktop?)
   - **Impact**: den configures tools, not the daemon — you choose the backend

### 6. **Homebrew on macOS** (Future)
   - **Current status**: Not included (you don't have a Mac yet)
   - **Decision needed**: When you get a Mac, will you use Homebrew, nixpkgs, or both?
   - **Current setup**: Prepared to add Homebrew integration, but leaving it minimal for now

### 7. **Repository Location**
   - **Current assumption**: You'll clone to `~/.config/den`
   - **Alternative**: Could be anywhere (adjust flake paths in home-manager switch commands)
   - **Decision needed**: Confirm this is your intended location
   - **Impact**: Affects clone and activation commands

### 8. **Public vs. Private Repository**
   - **Current assumption**: Public repository, credentials external
   - **If private**: You have more freedom to include machine-specific config, but still shouldn't store SSH keys
   - **Decision**: Is den public or private on GitHub?

## Quality Checks Performed

✓ **Nix syntax**: All .nix files validate with `nix-instantiate --parse`
✓ **Flake structure**: flake.nix is syntactically correct
✓ **Imports**: All module imports reference existing files or reserved directories
✓ **Input versions**: nixpkgs and home-manager use inputs.follows for compatibility
✓ **Platform support**: Linux and Darwin conditionals in place
✓ **No secrets**: No credentials, API keys, or private keys in any file
✓ **No machine modifications**: All configuration is Home Manager user-level
✓ **Repository size**: ~13 files, ~1500 lines total (including comments/docs)
✓ **Documentation**: README, BOOTSTRAP, ARCHITECTURE all included

## Recommended Next Steps

1. **Review all files** in this repository to understand the structure
2. **Read BOOTSTRAP.md** for the quick-start checklist
3. **Update git.nix** with your actual name and email
4. **Test on WSL2** (or your Linux environment of choice) using the BOOTSTRAP guide
5. **Ensure `~/.ssh/id_ed25519_github` exists** and works with GitHub
6. **Run `home-manager switch --flake .#linux`** to activate
7. **Verify tools** are available (go, python, git, direnv, etc.)
8. **Commit to git** and push to your repository
9. **Iterate**: Add tools, adjust config, commit changes as you discover needs

## Files Created

- `flake.nix` — Main Nix flake
- `home-manager/home.nix` — Home Manager core config
- `home-manager/programs/git.nix` — Git + GitHub SSH
- `home-manager/programs/direnv.nix` — direnv setup
- `home-manager/programs/shell.nix` — Bash and Zsh
- `hosts/linux/home.nix` — Linux-specific overrides
- `hosts/darwin/home.nix` — macOS-specific overrides (minimal)
- `README.md` — Full documentation
- `BOOTSTRAP.md` — Quick start guide
- `ARCHITECTURE.md` — Design rationale
- `scripts/den.sh` — Helper script

All files have been validated and are ready to use.

---

**You're ready to test den on WSL2.** Follow BOOTSTRAP.md for step-by-step instructions. Let me know if you encounter any issues or need clarifications.

# Quick Bootstrap Guide

**TL;DR for getting `den` running on a fresh machine.**

## Prerequisites

- Linux (WSL2, GCP, etc.) or macOS
- `curl` or `wget` (to install Nix)
- At least 2GB free disk space
- 30-60 minutes for a clean setup

## Step-by-Step (Linux / WSL2)

### 1. Install Nix

```bash
curl -L https://nixos.org/nix/install | sh
source ~/.nix-profile/etc/profile.d/nix.sh
```

Verify:
```bash
nix --version
```

### 2. Enable Flakes

Edit or create `~/.config/nix/nix.conf`:

```bash
mkdir -p ~/.config/nix
cat >> ~/.config/nix/nix.conf <<EOF
experimental-features = nix-command flakes
EOF
```

### 3. Get den

```bash
# Clone if you haven't already
git clone https://github.com/yourusername/den ~/.config/den
cd ~/.config/den

# Or if you already have den checked out
cd /path/to/den
```

### 4. Configure Git Identity

Edit `home-manager/programs/git.nix`:

```bash
nano home-manager/programs/git.nix
# or your preferred editor
```

Update these lines:
```nix
userEmail = "your-email@example.com";
userName = "Your Name";
```

Save and exit.

### 5. Apply Home Manager Configuration

```bash
# Install and switch to the linux configuration
nix run home-manager/master -- switch --flake ~/.config/den#linux
```

Or if you have home-manager already installed:
```bash
home-manager switch --flake ~/.config/den#linux
```

### 6. Restart Your Shell

```bash
exec $SHELL
```

### 7. Verify Installation

```bash
# Check some tools are available
which git
which go
which python3
which docker
which direnv
python3 --version
go version
```

### 8. Set Up GitHub SSH

Copy your existing GitHub SSH key or generate one:

```bash
# If you don't have one yet
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_github -N ""

# Add to GitHub: https://github.com/settings/keys
```

Test:
```bash
ssh -T git@github.com
# Expected: "Hi <username>! You've successfully authenticated..."
```

## Step-by-Step (macOS)

Same as Linux above, but:

- Use macOS Nix installer (same curl command works)
- When applying Home Manager, use: `nix run home-manager/master -- switch --flake ~/.config/den#darwin`
- zsh will be the default shell (you may need to activate it via `chsh`)

## Troubleshooting

### "command not found: nix"

Restart your shell or run:
```bash
source ~/.nix-profile/etc/profile.d/nix.sh
```

### "experimental-features not enabled"

Ensure `~/.config/nix/nix.conf` has:
```
experimental-features = nix-command flakes
```

Then restart your shell.

### "home-manager: command not found"

Run the full command including `nix run`:
```bash
nix run home-manager/master -- switch --flake ~/.config/den#linux
```

### Git user.name or user.email still not set

Edit `home-manager/programs/git.nix` again, then:
```bash
home-manager switch --flake ~/.config/den#linux
```

### SSH key not working

Check the file exists and has correct permissions:
```bash
ls -la ~/.ssh/id_ed25519_github
chmod 600 ~/.ssh/id_ed25519_github
```

Test the key:
```bash
ssh -T git@github.com
```

## Next Steps

1. Read [README.md](README.md) for full documentation
2. Read [ARCHITECTURE.md](ARCHITECTURE.md) for design decisions
3. Start using your environment
4. Add tools/config as needed and run `home-manager switch --flake ~/.config/den#linux` to apply changes
5. Commit changes to git: `git add -A && git commit -m "Add my customizations"`

## Keeping den Updated

To update all packages to their latest versions:

```bash
cd ~/.config/den
nix flake update
git add flake.lock
git commit -m "chore: update flake inputs"
home-manager switch --flake .#linux
```

## Uninstalling den

If you need to back out:

```bash
# Remove Home Manager config (keep your actual files)
home-manager uninstall

# Or manually remove the symlinks
rm -f ~/.bashrc ~/.zshrc ~/.config/git ~/.ssh/config  # etc as needed

# Nix remains installed; remove it separately if desired
rm -rf ~/.nix-profile ~/.config/nix ~/.cache/nix ~/.local/state/nix
```

---

For more details, see README.md.

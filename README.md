# den

`den` is my personal, declarative configuration for the machines I use and the software I use on them. It describes what makes those machines mine: the shell, terminal tools, Git and SSH defaults, editors, applications, development tooling, and system configuration where Nix is appropriate.

Development tools are an important part of `den`, but they are one category within a broader personal computing configuration.

## Status

| Host | Platform | Current status | Activation |
| --- | --- | --- | --- |
| `macbook` | macOS | nix-darwin with integrated Home Manager | `den switch macbook` |
| `home-nixos` | NixOS | Existing machine; migration is deferred | Not exposed yet |

The MacBook configuration includes system and user settings. Activation remains explicit; upgrading from standalone Home Manager requires the migration steps below.

## Architecture

The repository separates three kinds of configuration:

- **Common user configuration** in `home/`: shared Home Manager modules for tools, shell, Git, SSH, and direnv.
- **Platform configuration** in `modules/`: reusable behavior for macOS. A future `modules/nixos/` can contain NixOS system modules.
- **Host configuration** in `hosts/`: concrete environments such as the MacBook. Host files stay small until a machine actually needs distinct settings.

```text
den
├── common user configuration
├── platform modules
│   ├── Darwin
│   │   └── MacBook host
│   └── NixOS (future system modules)
└── host entry points
```

Current layout:

```text
den/
├── flake.nix
├── flake.lock
├── home/
│   ├── default.nix
│   ├── tools.nix
│   ├── shell.nix
│   ├── git.nix
│   ├── ssh.nix
│   └── direnv.nix
├── modules/
│   └── darwin/           system default.nix, user home.nix and iterm2/
└── hosts/
    └── macbook.nix
```

A host selects the shared `home/` modules, its platform module, and its own small host file. Platform modules remain separate from machine identity.

## Nix and Home Manager

The flake uses `nixpkgs-unstable`, nix-darwin, and integrated Home Manager for macOS.
Future Linux hosts should use a separate `nixos-unstable` input. `den switch` applies
system and user configuration together. The current system module enables zsh
integration and Touch ID for sudo, and leaves the login shell unchanged. Home Manager owns the existing
user tools and preferences; Colima belongs to the Darwin user module.

Nix itself remains managed by its installer (`nix.enable = false`), including its
daemon and experimental-feature settings. This supports existing Nix installations,
including Determinate Nix. Apple still manages macOS installation and updates.
GUI applications, cloud credentials, and the Colima runtime remain externally
managed. Add further system settings deliberately in `modules/darwin/default.nix`.

The existing home NixOS machine is intentionally not changed. Its eventual migration will combine:

- NixOS modules for system-level configuration;
- Home Manager, integrated as a NixOS module, for user-level configuration;
- a host entry for `home-nixos`.

That migration remains deferred; the MacBook is the only current host.

## Included configuration

The current shared configuration includes:

- zsh as the only managed interactive shell, with a restrained Starship prompt and startup greeting;
- the login shell remains an external machine setting and is not changed by `den`;
- Git defaults, aliases, and the public Git identity configured in `home/git.nix`;
- GitHub SSH configuration using `~/.ssh/id_ed25519_github`;
- direnv with nix-direnv integration;
- tmux, jq, yq, curl, wget, and OpenSSH;
- Go, Node.js, Python, and `uv`;
- Docker CLI tools, Terraform, `gcloud`, and `gh`.

`uv` remains the preferred Python package and environment manager. No nvm, pyenv, asdf, or mise layer is included.

Docker is treated as a platform concern: installing the CLI does not claim to install or configure a daemon. The MacBook includes Colima, whose runtime is managed separately.

## Credentials and public safety

This is a public repository. It contains only declarative, non-secret defaults. Credential provisioning stays outside `den`:

- never commit private SSH keys, API keys, tokens, passwords, cloud credentials, or service-account files;
- the GitHub private key is expected at `~/.ssh/id_ed25519_github`, but is never created or stored here;
- Git name and the GitHub noreply email are managed in `home/git.nix`; these are public attribution settings, not credentials;
- no secrets-management framework is added until there is a concrete need for one.

SSH configuration is kept modular so the authentication strategy can change later without restructuring the rest of the repository.

## First use on macOS

1. Create your macOS account and install Nix with `nix-command` and `flakes` enabled.
   The `macbook` host targets Apple Silicon.
2. Clone this repository to `~/.config/den` and provision credentials separately.
3. Back up existing shell files and iTerm preferences before taking ownership.
   Quit iTerm and use another terminal for activation.
4. As your normal user (not with `sudo`), run:

   ```bash
   bash ~/.config/den/scripts/den.sh switch macbook
   ```

   The script builds the locked `darwin-rebuild` tool, then requests sudo for
   system activation. It works before nix-darwin or the new `den` is installed.
   File collisions are intentionally not overwritten: back up and move only the
   conflicting unmanaged files reported by nix-darwin or Home Manager, then retry.
5. Open a new terminal and use `den switch macbook` for subsequent changes.

### Migrating this Mac from standalone Home Manager

Use the repository script above once; the currently installed `den` may still
invoke standalone Home Manager. Keep the old Home Manager generation for recovery.
Integrated Home Manager recognizes its existing managed symlinks. User packages
now live in the system-managed user profile; do not continue running standalone
`home-manager switch` against this repository. The standalone `homeConfigurations`
output has been replaced by `darwinConfigurations.macbook`.

The old standalone profile may continue to expose old packages. After a successful
switch and a fresh login, verify the tools and shell, then optionally remove its
`home-manager` package entry using the profile tooling appropriate to that profile.
Do not remove the entire user profile or unrelated packages. No profile cleanup is
automated by den.

## Working on den

After the first nix-darwin activation, `den` is the primary interface for this repository and can be run from any directory:

```bash
den status
den update
den check
den switch macbook
```

`den` locates the repository at `~/.config/den` instead of using the current working directory. `den update` only updates the lock file; it never switches the active configuration. The only current system host is `macbook`. On macOS, switching uses the pinned `darwin-rebuild`; on NixOS it uses the installed `nixos-rebuild`. No Linux host is configured yet.

Use local, non-destructive checks while editing:

```bash
export DEN_USER="$(id -un)" DEN_HOME="$HOME"
nix flake check --impure --no-update-lock-file
nix build --impure --no-update-lock-file --no-link .#darwinConfigurations.macbook.system
nix fmt
python3 -m unittest discover -s tests
```

The complete system can be built without activating it through `darwinConfigurations.macbook.system`. New untracked modules require `path:.` instead of `.` until added to Git. `home.stateVersion = "26.05"` is a deliberate stable schema baseline for this new configuration; it is independent of the nixpkgs and Home Manager input versions and should only change as part of a planned migration. The lock file should be committed when inputs are intentionally updated.

## GitHub Actions

The `Check den` workflow runs on pushes, pull requests, and manual dispatches.
It checks the CLI and flake, then builds the complete `macbook` nix-darwin system
including Home Manager on macOS ARM64. CI never activates a configuration or updates
`flake.lock`.

Builds use a host matrix with an explicit runner, architecture, and build target.
Darwin targets use `darwinConfigurations.<host>.system`; future NixOS targets use
`nixosConfigurations.<host>.config.system.build.toplevel`. The final `CI` job succeeds only when every matrix build
succeeds; failed, cancelled, or skipped builds do not pass the gate. The Main
ruleset requires only `CI`, so adding machines needs no branch-rule changes.

Evaluation uses the runner's local username and home directory with `--impure`,
just like local use. The check workflow references Actions by release tags or commit hashes and grants
read-only repository permissions. Human-readable release tags are acceptable. No additional repository secrets are required.

The `Copilot Setup Steps` workflow installs `uv` (including `uvx`) for Copilot's
MCP servers and verifies that `uvx` is on `PATH`. It runs for pull requests that
change the setup file and supports manual dispatch. Copilot uses it automatically
once `.github/workflows/copilot-setup-steps.yml` is on the default branch.

### Dependency updates and merging

Dependabot checks Nix flake inputs and GitHub Actions weekly, grouping updates
into one PR per ecosystem. The `Enable Dependabot auto-merge` workflow approves
Dependabot PRs and enables GitHub's native squash auto-merge. GitHub waits for
required status checks and branch rules; the workflow contains no CI job list.
It never checks out or executes PR code. Local activation remains manual.

Before enabling this workflow on the default branch, configure the repository:

- Require the `CI` check on `main` using branch protection or a ruleset. Auto-merge
  waits for **required** checks, not every workflow that happens to be running.
- Enable **Allow auto-merge** and squash merging in repository Settings → General.
- Enable **Allow GitHub Actions to create and approve pull requests** in
  Settings → Actions → General → Workflow permissions.

No personal access token is needed.

## Deferred work

The following are intentionally future work rather than claims about the current repository:

- richer editor, terminal, font, application, and user-service modules;
- additional host-specific settings as real differences appear;
- a `home-nixos` host with NixOS system modules;
- migration of the existing traditional NixOS configuration into a flake with Home Manager;
- a secrets solution only if external credential provisioning becomes insufficient.

## License

MIT. See [LICENSE](LICENSE).

## Local identity

Evaluation reads `DEN_USER` and `DEN_HOME` with `--impure`. `den show`, `den check`,
and `den switch` capture the current account with `id -un` and its local `HOME`.
Switching passes these dedicated variables through sudo explicitly; it never
uses root's `USER` or `HOME` as the target account. Run den as your normal user.
For direct Nix commands, export the variables as shown above. Missing identity,
root, and non-absolute home directories are rejected by the flake.

Usernames and home directories are not stored in Git. Generated Nix store files
and diagnostic output still contain local identity and paths; this is repository
privacy, not secret storage. CI supplies its own runner account. The prompt omits
the username and hostname, and `den status` abbreviates the home directory as `~`.

## iTerm on macOS

Home Manager manages iTerm's default profile, light/dark colors, Monaco 12 font,
keyboard and pointer behavior, and existing Claude Code profile triggers.
The reviewed settings live in `modules/darwin/iterm2/preferences.json`.
The profile's home directory is supplied locally at evaluation time.

The Darwin module generates `~/.config/iterm2/den/com.googlecode.iterm2.plist`
and enables iTerm's [custom preferences folder](https://iterm2.com/documentation-preferences-general.html).
iTerm itself remains a native application installed outside `den`.
Quit iTerm before running `den switch macbook`, then reopen it to load settings.
Use another terminal for activation if necessary; activation never quits sessions.

Edit the JSON and switch to persist changes. The generated preferences file is
read-only: if iTerm offers to save GUI changes back to the folder, decline.
Window positions, history, installation metadata, saved review prompts, workgroups,
and credentials are not captured in the repository. Existing application state
remains local. Keep a local preferences backup before the first migration.

VS Code settings and extensions remain managed through its existing Settings Sync,
not through `den`.

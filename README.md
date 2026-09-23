# den

`den` is my personal, declarative configuration for the machines I use and the software I use on them. It describes what makes those machines mine: the shell, terminal tools, Git and SSH defaults, editors, applications, development tooling, and eventually system configuration where Nix is appropriate.

Development tools are an important part of `den`, but they are one category within a broader personal computing configuration.

## Status

| Host | Platform | Current status | Activation |
| --- | --- | --- | --- |
| `macbook` | macOS | Active; Home Manager manages the user environment | `home-manager switch --impure --flake .#macbook` |
| `home-nixos` | NixOS | Existing machine; migration is deferred | Not exposed yet |

The MacBook is already managed. Activation remains explicit; the repository does not bootstrap machines automatically.

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
│   └── darwin/default.nix
└── hosts/
    └── macbook.nix
```

A host selects the shared `home/` modules, its platform module, and its own small host file. Platform modules remain separate from machine identity.

## Nix and Home Manager

The flake uses `nixpkgs-unstable` for macOS and Home Manager. Future Linux hosts should use a separate `nixos-unstable` input. Home Manager manages its own CLI through `programs.home-manager.enable`, using the same pinned Home Manager input as the configuration. The MacBook uses standalone Home Manager for user-level configuration. Its base operating system, Docker daemon, cloud login, and other machine services remain native to the platform unless later added deliberately.

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

This is documentation for a future/manual activation; it does not run anything automatically.

1. Install Nix with flakes enabled on the Mac.
2. Clone this repository and enter it.
3. Provision credentials separately, including the GitHub SSH key if needed.
4. Inspect the configuration, then activate the MacBook host:

    ```bash
    nix run .#home-manager -- switch --impure -b backup --flake .#macbook
    ```

    The backup flag is for the first activation when Home Manager takes ownership of existing files. After activation, use the installed command for later changes:

    ```bash
    home-manager switch --impure --flake ~/.config/den#macbook
    ```

5. Restart the shell if needed and verify the tools relevant to that machine.

## Working on den

After the first Home Manager activation, `den` is the primary interface for this repository and can be run from any directory:

```bash
den status
den update
den check
den switch macbook
```

`den` locates the repository at `~/.config/den` instead of using the current working directory. `den update` only updates the lock file; it never switches the active configuration. The only current Home Manager host is `macbook`.

Use local, non-destructive checks while editing:

```bash
nix flake check --impure
nix fmt
nix flake show --impure
```

Home Manager configurations can be evaluated without activating them through their `activationPackage` output. `home.stateVersion = "26.05"` is a deliberate stable schema baseline for this new configuration; it is independent of the nixpkgs and Home Manager input versions and should only change as part of a planned migration. The lock file should be committed when inputs are intentionally updated.

## GitHub Actions

The `Check den` workflow runs on pushes, pull requests, and manual dispatches.
It checks shell syntax and the flake, then builds the `macbook` Home Manager
activation package on macOS ARM64. CI never activates a configuration or updates
`flake.lock`.

Builds use a host matrix. The final `CI` job succeeds only when every matrix build
succeeds; failed, cancelled, or skipped builds do not pass the gate. The Main
ruleset requires only `CI`, so adding machines needs no branch-rule changes.

Evaluation uses the runner's local username and home directory with `--impure`,
just like local use. The check workflow references Actions by release tags or commit hashes and grants
read-only repository permissions. Human-readable release tags are acceptable. No additional repository secrets are required.

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
- Darwin-specific packaging and native integration;
- a `home-nixos` host with NixOS system modules;
- migration of the existing traditional NixOS configuration into a flake with Home Manager;
- a secrets solution only if external credential provisioning becomes insufficient.

## License

MIT. See [LICENSE](LICENSE).

## Local identity

When upgrading from a version that hard-coded local identity, activate once using the repository script so the new `den` command is installed:

```bash
bash ~/.config/den/scripts/den.sh switch macbook
```

Subsequent activations can use `den switch <host>` as usual.

Home Manager reads `USER` and `HOME` from the local environment. Evaluation requires `--impure`; `den show`, `den check`, and `den switch` supply it automatically. Run activation as your own user. Usernames and home directories are not stored in the flake. Generated Home Manager files and diagnostic output may still contain local absolute paths. The shell greeting and prompt omit the username and hostname, and `den status` abbreviates the home directory as `~`.

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

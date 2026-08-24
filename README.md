# den

`den` is my personal, declarative configuration for the machines I use and the software I use on them. It describes what makes those machines mine: the shell, terminal tools, Git and SSH defaults, editors, applications, development tooling, and eventually system configuration where Nix is appropriate.

Development tools are an important part of `den`, but they are one category within a broader personal computing configuration.

## Status

| Host | Platform | Current status | Activation |
| --- | --- | --- | --- |
| `wsl` | Ubuntu on WSL2 | First test host; Home Manager configuration is implemented | `home-manager switch --flake .#wsl` |
| `gcp` | Ubuntu on GCP Compute Engine | Planned host entry; Home Manager configuration is implemented | `home-manager switch --flake .#gcp` |
| `macbook` | macOS | Planned host entry; Darwin module is minimal | `home-manager switch --flake .#macbook` |
| `home-nixos` | NixOS | Existing machine; migration is deferred | Not exposed yet |

The commands above are the eventual activation commands. This repository does not bootstrap or modify any machine automatically.

## Architecture

The repository separates three kinds of configuration:

- **Common user configuration** in `home/`: shared Home Manager modules for tools, shell, Git, SSH, and direnv.
- **Platform configuration** in `modules/`: reusable behavior for Linux and Darwin. A future `modules/nixos/` can contain NixOS system modules.
- **Host configuration** in `hosts/`: concrete environments such as WSL2, GCP, and a MacBook. Host files stay small until a machine actually needs distinct settings.

```text
den
├── common user configuration
├── platform modules
│   ├── Linux
│   │   ├── WSL2 host
│   │   └── GCP host
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
│   ├── linux/default.nix
│   └── darwin/default.nix
└── hosts/
    ├── wsl.nix
    ├── gcp.nix
    └── macbook.nix
```

A host selects the shared `home/` modules, its platform module, and its own small host file. Linux is therefore a reusable platform, not a machine identity: WSL2 and GCP share Linux behavior while remaining independently configurable.

## Nix and Home Manager

The flake uses `nixpkgs` unstable and Home Manager. Ubuntu and macOS hosts use standalone Home Manager for user-level configuration. Their base operating system, Docker daemon, cloud login, and other machine services remain native to the platform unless later added deliberately.

The existing home NixOS machine is intentionally not changed. Its eventual migration will combine:

- NixOS modules for system-level configuration;
- Home Manager, integrated as a NixOS module, for user-level configuration;
- a host entry for `home-nixos`.

That migration will happen after the standalone Home Manager setup has been tested on WSL2.

## Included configuration

The current shared configuration includes:

- zsh as the only managed interactive shell, with a restrained Starship prompt and startup greeting;
- the login shell remains an external machine setting and is not changed by `den`;
- Git defaults and aliases, without hard-coding Git identity;
- GitHub SSH configuration using `~/.ssh/id_ed25519_github`;
- direnv with nix-direnv integration;
- tmux, jq, yq, curl, wget, and OpenSSH;
- Go, Node.js, Python, and `uv`;
- Docker CLI tools, Terraform, `gcloud`, and `gh`.

`uv` remains the preferred Python package and environment manager. No nvm, pyenv, asdf, or mise layer is included.

Docker is treated as a platform concern: installing the CLI does not claim to install or configure a daemon. For example, WSL2 may use Docker Desktop or a separately managed Docker service.

## Credentials and public safety

This is a public repository. It contains only declarative, non-secret defaults. Credential provisioning stays outside `den`:

- never commit private SSH keys, API keys, tokens, passwords, cloud credentials, or service-account files;
- the GitHub private key is expected at `~/.ssh/id_ed25519_github`, but is never created or stored here;
- Git name and email must be configured through an external or local machine-specific mechanism;
- no secrets-management framework is added until there is a concrete need for one.

SSH configuration is kept modular so the authentication strategy can change later without restructuring the rest of the repository.

## First use on WSL2

This is documentation for a future/manual activation; it does not run anything automatically.

1. Install Nix with flakes enabled on the Ubuntu/WSL2 machine.
2. Clone this repository and enter it.
3. Provision credentials separately, including the GitHub SSH key if needed.
4. Inspect the configuration, then activate the WSL host:

    ```bash
    nix run .#home-manager -- switch -b backup --flake .#wsl
    ```

    The backup flag is for the first activation when Home Manager takes ownership of existing files. After activation, use the installed command for later changes:

    ```bash
    home-manager switch --flake ~/.config/den#wsl
    ```

5. Restart the shell if needed and verify the tools relevant to that machine.

For GCP Ubuntu, use the same standalone Home Manager model with `.#gcp`. Access through VS Code Remote SSH is an operational choice, not an architectural dependency in this repository.

## Working on den

After the first Home Manager activation, `den` is the primary interface for this repository and can be run from any directory:

```bash
den status
den update
den check
den switch wsl
```

`den` locates the repository at `~/.config/den` instead of using the current working directory. `den update` only updates the lock file; it never switches the active configuration. The available host names are the flake's actual Home Manager outputs: `wsl`, `gcp`, and `macbook`.

Use local, non-destructive checks while editing:

```bash
nix flake check
nix fmt
nix flake show
```

Home Manager configurations can be evaluated without activating them through their `activationPackage` output. `home.stateVersion = "26.05"` is a deliberate stable schema baseline for this new configuration; it is independent of the nixpkgs and Home Manager input versions and should only change as part of a planned migration. The lock file should be committed when inputs are intentionally updated.

## Deferred work

The following are intentionally future work rather than claims about the current repository:

- richer editor, terminal, font, application, and user-service modules;
- additional host-specific settings as real differences appear;
- Darwin-specific packaging and native integration;
- a `home-nixos` host with NixOS system modules;
- migration of the existing traditional NixOS configuration into a flake with Home Manager;
- suitable Linux/WSL/GCP system-level configuration where it is useful;
- a secrets solution only if external credential provisioning becomes insufficient.

## License

MIT. See [LICENSE](LICENSE).

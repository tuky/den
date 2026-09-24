# Working on den

`den` is a personal, public Nix/Home Manager configuration. Read `README.md`
and `ARCHITECTURE.md` for context; inspect the actual modules before changing them.
Start with `git status --short` and preserve unrelated user changes.

## Where changes belong

- `home/`: shared user settings and tools. Import new modules in `home/default.nix`.
- `modules/darwin/default.nix`: nix-darwin system settings; `home.nix` and `iterm2/` are Home Manager modules.
- `hosts/`: small, concrete host differences.
- `flake.nix`: exposes only `darwinConfigurations.macbook` (`aarch64-darwin`); do not restore retired hosts.
  Use `nixpkgs-unstable` for macOS; add a separate `nixos-unstable` input when Linux is introduced.
- `scripts/den.sh`: the `den` CLI. It normally targets `~/.config/den`, not the current checkout.
- `.github/`: CI, Copilot environment setup, Dependabot updates, and native Dependabot auto-merge.

The Mac is actively managed, including public Git identity and iTerm settings.
VS Code uses Settings Sync; leave it outside den. The existing NixOS machine is
not managed here yet. Prefer small modules and simple solutions over new abstractions.

## Editing safely

- Never commit credentials, private keys, tokens, histories, or application state.
  Git attribution in `home/git.nix` is intentionally public.
- Derive machine username/home from local configuration; do not hard-code them.
  Flake evaluation needs `DEN_USER`, `DEN_HOME`, and `--impure`. The CLI captures identity before sudo; run it as the normal user.
- Edit source files, not generated Home Manager files or Nix-store symlinks.
  iTerm's source is `modules/darwin/iterm2/preferences.json`.
- Keep the authoritative `home.stateVersion` in `flake.nix` unchanged unless deliberately migrating its schema.
  Integrated Home Manager is activated through nix-darwin, not standalone switching.
  Keep `system.stateVersion = 6` stable too; Nix daemon ownership remains with the installer.
  Update `flake.lock` only as part of an intended dependency update.
- Building is not activation. Run `den switch <host>` only when applying changes
  is within the user's request; don't activate just to validate an edit.
  Back up existing local preferences before taking ownership of unmanaged files.

## Validation

Run from the checkout being edited, using checks appropriate to the change:

```sh
export DEN_USER="$(id -un)" DEN_HOME="$HOME"
git diff --check
nix flake check --impure --no-update-lock-file
nix build --impure --no-update-lock-file --no-link .#darwinConfigurations.macbook.system
```

A flake check alone does not build the system output. On another platform, evaluate the host's
`system.drvPath` with `nix eval --impure --no-update-lock-file --raw`
and leave the native build to CI. Do not claim evaluation proves runtime behavior.
Git-backed flakes omit untracked files: use `path:.` as the flake reference when
validating new files before they are tracked.

Use `nix fmt` for Nix formatting, `bash -n scripts/den.sh` for CLI edits, and
`actionlint` for workflow edits. Run `python3 -m unittest discover -s tests` for CLI changes. Documentation-only changes need no Nix build.
Report what passed and any checks you could not run.

## CI and maintenance

`copilot-setup-steps.yml` installs `uv`/`uvx` for MCP servers. Keep its single job
named `copilot-setup-steps`; Copilot requires that exact name.

Keep build logic in `check.yml`. Dependabot PRs are approved and marked for native
auto-merge; required checks in GitHub's branch rules control when they merge.
Do not duplicate the build matrix in the merge workflow. Never check out or run
PR code in its privileged `pull_request_target` workflow. The stable `CI` job
aggregates the build matrix and is the sole required CI check in the Main ruleset.
Add machines to the matrix with their runner, system, and full build target; no new branch rules are needed. Keep the gate's `always()`
condition and explicit success check so failed or skipped builds cannot pass it.

As you develop the project, update this file whenever architecture, commands,
ownership, or workflows change. Correct stale guidance and record useful recurring
pitfalls; keep instructions concise rather than accumulating a work log.
Update relevant user documentation alongside behavior changes.

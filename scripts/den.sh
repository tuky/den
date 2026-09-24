#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<EOF
den - Manage personal machine configuration

Usage: den <command>

Commands:
  show              Show available configurations
  status            Show repository path and working-tree state
  update            Update flake inputs (does not switch)
  switch <host>     Apply system and user configuration
  format            Format the flake
  check             Check flake for errors
  help              Show this help message

Examples:
  den status
  den show
  den update
  den check
  den switch macbook
  den format

EOF
}

FLAKE_PATH="${HOME}/.config/den"

if [[ ! -f "${FLAKE_PATH}/flake.nix" ]]; then
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
    SOURCE_FLAKE_PATH="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
    if [[ -f "${SOURCE_FLAKE_PATH}/flake.nix" ]]; then
        FLAKE_PATH="$SOURCE_FLAKE_PATH"
    fi
fi

if [[ ! -f "${FLAKE_PATH}/flake.nix" ]]; then
    printf 'den: no flake.nix found at %s\n' "~${FLAKE_PATH#"$HOME"}" >&2
    exit 1
fi

# Capture the invoking account before sudo, never root's environment.
local_identity() {
    if [[ "$(id -u)" -eq 0 ]]; then
        echo "den: run as your normal user; den elevates system activation itself." >&2
        exit 1
    fi
    export DEN_USER="$(id -un)"
    export DEN_HOME="$HOME"
}

status() {
    local branch state
    branch="$(git -C "$FLAKE_PATH" branch --show-current 2>/dev/null || true)"
    state="$(git -C "$FLAKE_PATH" status --short 2>/dev/null)"

    printf 'den\n'
    printf '  repo:   %s\n' "~${FLAKE_PATH#"$HOME"}"
    printf '  branch: %s\n' "${branch:-detached}"
    if [[ -n "$state" ]]; then
        printf '  state:  modified\n'
    else
        printf '  state:  clean\n'
    fi
}

case "${1:-help}" in
    show)
        echo "Available den configurations:"
        local_identity
        nix flake show --impure --no-update-lock-file "$FLAKE_PATH"
        ;;
    status)
        status
        ;;
    update)
        echo "Updating den flake inputs..."
        nix flake update --flake "$FLAKE_PATH"
        echo "Done. Review changes before switching."
        ;;
    switch)
        if [[ $# -ne 2 ]]; then
            echo "Usage: den switch <host>" >&2
            exit 2
        fi
        host="$2"
        echo "Switching den host: $host"
        local_identity
        if [[ ! "$host" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            echo "den: invalid host name: $host" >&2
            exit 2
        fi
        case "$(uname -s)" in
            Darwin)
                # Build the locked CLI as the user, including on a fresh Mac.
                rebuild_package="$(nix build --no-link --print-out-paths --no-update-lock-file "$FLAKE_PATH#darwin-rebuild")"
                sudo /usr/bin/env "DEN_USER=$DEN_USER" "DEN_HOME=$DEN_HOME" \
                    "$rebuild_package/bin/darwin-rebuild" switch --impure --no-update-lock-file --flake "$FLAKE_PATH#$host"
                ;;
            Linux)
                if [[ ! -e /etc/NIXOS ]]; then
                    echo "den: system switching on Linux requires NixOS." >&2
                    exit 1
                fi
                rebuild_command="$(command -v nixos-rebuild)"
                sudo /usr/bin/env "DEN_USER=$DEN_USER" "DEN_HOME=$DEN_HOME" \
                    "$rebuild_command" switch --impure --no-update-lock-file --flake "$FLAKE_PATH#$host"
                ;;
            *)
                echo "den: unsupported operating system." >&2
                exit 1
                ;;
        esac
        ;;
    format)
        echo "Formatting den..."
        nix fmt "$FLAKE_PATH"
        echo "Done."
        ;;
    check)
        echo "Checking flake for errors..."
        local_identity
        nix flake check --impure --no-update-lock-file "$FLAKE_PATH"
        echo "No errors found."
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Unknown command: $1" >&2
        echo ""
        usage
        exit 1
        ;;
esac

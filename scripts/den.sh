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
  switch <host>     Apply a Home Manager host configuration
  format            Format the flake
  check             Check flake for errors
  help              Show this help message

Examples:
  den status
  den show
  den update
  den check
  den switch wsl
  den format

EOF
}

FLAKE_PATH="__DEN_FLAKE_PATH__"

if [[ ! -f "${FLAKE_PATH}/flake.nix" ]]; then
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
    SOURCE_FLAKE_PATH="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
    if [[ -f "${SOURCE_FLAKE_PATH}/flake.nix" ]]; then
        FLAKE_PATH="$SOURCE_FLAKE_PATH"
    fi
fi

if [[ ! -f "${FLAKE_PATH}/flake.nix" ]]; then
    printf 'den: no flake.nix found at %s\n' "$FLAKE_PATH" >&2
    exit 1
fi

status() {
    local branch state
    branch="$(git -C "$FLAKE_PATH" branch --show-current 2>/dev/null || true)"
    state="$(git -C "$FLAKE_PATH" status --short 2>/dev/null)"

    printf 'den\n'
    printf '  repo:   %s\n' "$FLAKE_PATH"
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
        nix flake show "$FLAKE_PATH"
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
        home-manager switch --flake "$FLAKE_PATH#$host"
        ;;
    format)
        echo "Formatting den..."
        nix fmt "$FLAKE_PATH"
        echo "Done."
        ;;
    check)
        echo "Checking flake for errors..."
        nix flake check "$FLAKE_PATH"
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

#!/usr/bin/env bash
# Helper script for common den operations
# Optional: Use `chmod +x scripts/den.sh` to make executable

set -euo pipefail

usage() {
    cat <<EOF
den - Personal development environment helper

Usage: den <command> [options]

Commands:
  show              Show available configurations
  update            Update flake inputs to latest versions
  switch [config]   Apply Home Manager configuration (default: linux)
  format            Format all .nix files
  check             Check flake for errors
  help              Show this help message

Examples:
  den show
  den update
  den switch linux
  den switch darwin
  den format
  den check

Environment:
  Set DEN_FLAKE_PATH to override flake location (default: current directory)

EOF
}

# Default to current directory if DEN_FLAKE_PATH not set
FLAKE_PATH="${DEN_FLAKE_PATH:-.}"

case "${1:-help}" in
    show)
        echo "Available Home Manager configurations:"
        nix flake show "$FLAKE_PATH"
        ;;
    update)
        echo "Updating flake inputs..."
        nix flake update "$FLAKE_PATH"
        echo "Done. Review changes with: git diff flake.lock"
        ;;
    switch)
        config="${2:-linux}"
        echo "Switching to $config configuration..."
        home-manager switch --flake "$FLAKE_PATH#$config"
        echo "Done. Restart your shell to apply all changes."
        ;;
    format)
        echo "Formatting Nix files..."
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
        echo "Unknown command: $1"
        echo ""
        usage
        exit 1
        ;;
esac

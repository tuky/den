{ config, pkgs, lib, ... }:

{
  # macOS-specific configuration
  # Design for future Mac setup; minimal for now

  # Set up Homebrew integration if desired
  # home.homebrew.enable = true;

  # macOS-specific programs
  programs.zsh.enable = lib.mkDefault true;  # Prefer zsh on macOS

  # macOS environment variables
  home.sessionVariables = {
    # macOS-specific path or environment tweaks go here
  };

  # Optional: Nix on macOS uses different patterns for some tools
  # Defer most configuration to common sections

  # Note: Full Homebrew integration and macOS-specific packaging
  # can be added when you acquire a Mac
}

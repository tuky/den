{ config, pkgs, lib, ... }:

{
  # Linux-specific configuration
  # This covers WSL2 Ubuntu, GCP Compute Engine Ubuntu, and generic Linux environments

  # Use systemd user services if available (most modern Linux distributions)
  systemd.user.startServices = "sd-switch";

  # Additional Linux-specific packages can go here
  # Most tooling is configured in home-manager/home.nix as platform-agnostic

  # Linux-specific environment variables
  home.sessionVariables = {
    # WSL2 may need specific settings
    DISPLAY = ":0";  # For X11 forwarding if needed
  };

  # Optional: VS Code Server integration
  # Uncomment if using VS Code Remote SSH on Linux machines
  # programs.code-server = {
  #   enable = false;
  #   # Configure as needed for your setup
  # };
}

{ config, pkgs, lib, ... }:

{
  imports = [
    # Import all program configurations
    ./programs/git.nix
    ./programs/direnv.nix
    ./programs/shell.nix
  ];

  # Core home-manager configuration
  home.packages = with pkgs; [
    # Backend development languages
    go
    nodejs_20
    python312
    uv

    # DevOps and cloud tooling
    docker
    docker-compose
    terraform
    google-cloud-cli
    github-cli

    # Utilities
    direnv
    tmux
    jq
    yq
    git
    curl
    wget
    openssh
  ];

  # Home Manager session variables
  home.sessionVariables = {
    EDITOR = "code";
    PAGER = "less";
  };

  # Enable nix-direnv for flake support
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # This value determines the Home Manager release version.
  home.stateVersion = "24.05";
}

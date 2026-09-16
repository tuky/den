{ inputs, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Languages and runtimes
    go
    nodejs
    pnpm
    python314
    uv

    # Containers, infrastructure, and cloud
    colima
    docker
    docker-compose
    devbox
    terraform
    google-cloud-sdk
    github-cli
    home-manager
    livekit-cli
    bitwarden-cli
    awscli2

    # Everyday command-line tools
    tmux
    jq
    yq
    nano
    curl
    wget
    openssh
    unzip
    htop

    # AI
    inputs.codex-cli-nix.packages.${pkgs.system}.default
  ];
}

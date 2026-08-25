{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Languages and runtimes
    go
    nodejs
    pnpm
    python312
    uv

    # Containers, infrastructure, and cloud
    docker
    docker-compose
    terraform
    google-cloud-sdk
    github-cli
    home-manager

    # Everyday command-line tools
    tmux
    jq
    yq
    nano
    curl
    wget
    openssh
  ];
}
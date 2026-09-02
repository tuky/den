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
    devbox
    terraform
    google-cloud-sdk
    github-cli
    home-manager
    livekit-cli

    # Everyday command-line tools
    tmux
    jq
    yq
    nano
    curl
    wget
    openssh
    unzip
  ];
}

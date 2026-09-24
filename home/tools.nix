{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Languages and runtimes
    go
    nodejs
    pnpm
    python314
    uv

    # Containers, infrastructure, and cloud
    docker
    docker-compose
    devbox
    terraform
    google-cloud-sdk
    github-cli
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
    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

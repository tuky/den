{ config, pkgs, lib, ... }:

let
  # Shared shell functions and aliases
  commonShellConfig = ''
    # Development environment shortcuts
    alias ll="ls -lah"
    alias ..="cd .."
    alias ...="cd ../.."
    
    # Git shortcuts
    alias gst="git status"
    alias glog="git log --oneline"
    alias gco="git checkout"
    
    # Docker/Docker Compose
    alias dc="docker-compose"
    alias di="docker images"
    alias dps="docker ps"
    
    # Useful utilities
    alias json="jq ."
    alias yaml="yq ."
    
    # Python development
    alias py="python3"
    alias penv="python -m venv"
    
    # direnv integration hint
    # Note: direnv hooks are configured via programs.direnv above

    # Useful function: create and enter a new directory
    mkcd() {
      mkdir -p "$@" && cd "$_"
    }

    # Helper for managing Nix configurations
    den-home-switch() {
      home-manager switch --flake ~/.config/den
    }
  '';

in
{
  # Bash configuration
  programs.bash = {
    enable = true;
    bashrcExtra = commonShellConfig;
    
    # Additional bash-specific settings
    historySize = 10000;
    historyFileSize = 10000;
    historyControl = [ "erasedups" "ignoredups" ];
    historyIgnore = [ "ls" "cd" "pwd" "history" ];
  };

  # Zsh configuration (for future Mac setup and gradual transition)
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    
    initExtra = commonShellConfig;
    
    # zsh-specific plugins and configuration
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    # History settings
    history = {
      size = 10000;
      save = 10000;
      extended = true;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    localVariables = {
      KEYTIMEOUT = "1";
    };
  };
}

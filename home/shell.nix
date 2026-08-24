{ pkgs, ... }:

let
  commonShellConfig = ''
    alias ll="ls -lah"
    alias ..="cd .."
    alias ...="cd ../.."
    alias gst="git status"
    alias glog="git log --oneline"
    alias gco="git checkout"
    alias dc="docker compose"
    alias di="docker images"
    alias dps="docker ps"
    alias json="jq ."
    alias yaml="yq ."

    mkcd() {
      mkdir -p "$@" && cd "$_"
    }
  '';
in
{
  programs.zsh = {
    enable = true;
    initContent = commonShellConfig;
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];
    history = {
      size = 10000;
      save = 10000;
      extended = true;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };
    localVariables.KEYTIMEOUT = "1";
  };
}
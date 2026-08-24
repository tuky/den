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

    den_welcome() {
      [[ -o interactive ]] || return

      local os_name="$(uname -s)"
      case "$os_name" in
        Linux) os_name="Linux" ;;
        Darwin) os_name="macOS" ;;
      esac

      printf '╭─ den · %s\n' "$(hostname -s 2>/dev/null || hostname)"
      printf '│ %s · %s · zsh\n' "$os_name" "$(uname -m)"
      if (( $+commands[nix] && $+commands[home-manager] )); then
        printf '│ Nix · Home Manager\n'
      elif (( $+commands[nix] )); then
        printf '│ Nix · Home Manager not installed\n'
      else
        printf '│ Nix not found\n'
      fi
      printf '╰─ %s@%s:%s\n' "$USER" "$(hostname -s 2>/dev/null || hostname)" "$PWD"
    }

    den_welcome
  '';
in
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$username@$hostname $directory$git_branch$git_status$python$nodejs$golang$terraform$docker_context$fill$cmd_duration$line_break$character";
      fill.symbol = "·";
      username = {
        show_always = true;
        style_user = "cyan";
        style_root = "red";
        format = "[$user]($style)";
      };
      hostname = {
        ssh_only = false;
        style = "yellow";
        format = "[@$hostname]($style) ";
      };
      directory = {
        truncation_length = 3;
        style = "blue";
      };
      git_branch = {
        format = " [$branch]($style)";
        style = "purple";
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style))";
        style = "red";
      };
      cmd_duration = {
        min_time = 2000;
        format = " [$duration]($style)";
      };
      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };
      package.disabled = true;
    };
  };

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
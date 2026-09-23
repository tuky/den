{ ... }:

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

      printf '╭─ den\n'
      printf '│ %s · %s · zsh\n' "$os_name" "$(uname -m)"
      if (( $+commands[nix] && $+commands[home-manager] )); then
        printf '│ Nix · Home Manager\n'
      elif (( $+commands[nix] )); then
        printf '│ Nix · Home Manager not installed\n'
      else
        printf '│ Nix not found\n'
      fi
      printf '╰─ ready\n'
    }

    den_welcome
  '';
in
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$python$nodejs$golang$terraform$docker_context$fill$cmd_duration$line_break$character";
      fill.symbol = "·";
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
    syntaxHighlighting.enable = true;
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

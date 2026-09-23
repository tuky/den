{ config, ... }:

{
  home.sessionVariables = {
    EDITOR = "nano";
    VISUAL = "nano";
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  home.file.".local/bin/den" = {
    text = builtins.readFile ../scripts/den.sh;
    executable = true;
  };

  imports = [
    ./tools.nix
    ./git.nix
    ./ssh.nix
    ./shell.nix
    ./direnv.nix
    ./claude.nix
  ];

  programs.home-manager.enable = true;
}

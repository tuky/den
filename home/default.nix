{ config, ... }:

{
  home.sessionVariables = {
    EDITOR = "nano";
    VISUAL = "nano";
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  home.file.".local/bin/den" = {
    text = builtins.replaceStrings
      [ "__DEN_FLAKE_PATH__" ]
      [ "${config.home.homeDirectory}/.config/den" ]
      (builtins.readFile ../scripts/den.sh);
    executable = true;
  };

  imports = [
    ./tools.nix
    ./git.nix
    ./ssh.nix
    ./shell.nix
    ./direnv.nix
  ];

  home.stateVersion = "26.05";
}
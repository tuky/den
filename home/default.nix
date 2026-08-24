{ ... }:

{
  home.sessionVariables = {
    EDITOR = "nano";
    VISUAL = "nano";
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
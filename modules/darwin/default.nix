{ lib, ... }:

{
  imports = [ ./iterm2 ];

  programs.zsh.enable = lib.mkDefault true;
}

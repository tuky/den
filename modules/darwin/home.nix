{ pkgs, ... }:

{
  imports = [ ./iterm2 ];
  home.packages = [ pkgs.colima ];
}

{ pkgs, ... }:

{
  home.packages = [ pkgs.colima ];

  programs.ssh.settings."*" = {
    IgnoreUnknown = "UseKeychain";
    AddKeysToAgent = "yes";
    UseKeychain = "yes";
    IdentityFile = "~/.ssh/id_ed25519";
  };
}

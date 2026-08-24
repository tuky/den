{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519_github";
        IdentitiesOnly = "yes";
        AddKeysToAgent = "yes";
        ServerAliveInterval = 60;
      };
    };
  };
}
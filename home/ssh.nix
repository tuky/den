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
      "gcp" = {
        HostName = "136.92.15.242";
        IdentityFile = "~/.ssh/google_compute_engine";
        IdentitiesOnly = "yes";
        AddKeysToAgent = "yes";
        HostKeyAlias = "compute.8301497291641052697";
        CheckHostIP = "no";
      };
    };
  };
}

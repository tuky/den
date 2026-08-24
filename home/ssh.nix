{ ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks.github = {
      host = "github.com";
      user = "git";
      identityFile = "~/.ssh/id_ed25519_github";
      identitiesOnly = true;
      addKeysToAgent = "yes";
      serverAliveInterval = 60;
    };
  };
}
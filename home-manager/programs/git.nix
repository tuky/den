{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    # User identity - you'll need to set these to your actual values
    userEmail = "tobias@kroenke.de";
    userName = "tuky";

    # Core settings for development
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prune = true;
      push.autoSetupRemote = true;

      # Improved diff and merge
      diff.algorithm = "histogram";
      merge.conflictstyle = "zdiff3";

      # Safe operations
      core.safecrlf = "warn";
      core.autocrlf = false;
      core.pager = "less -F -X";
    };

    # Useful aliases for backend development workflows
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "log --graph --oneline --all";
      amend = "commit --amend --no-edit";
    };

    # SSH configuration for GitHub
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".vscode/settings.json"
      ".direnv"
      "dist"
      "build"
      "node_modules"
      ".env.local"
      ".pytest_cache"
      "__pycache__"
      "*.egg-info"
    ];
  };

  # OpenSSH client configuration
  programs.ssh = {
    enable = true;
    matchBlocks = {
      github = {
        host = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github";
        identitiesOnly = true;
        addKeysToAgent = "yes";
        serverAliveInterval = 60;
      };
    };
  };
}

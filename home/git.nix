{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user.email = "2981274+tuky@users.noreply.github.com";
      user.name = "tuky";
      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prune = true;
      push.autoSetupRemote = true;
      core.editor = "nano";
      diff.algorithm = "histogram";
      merge.conflictStyle = "zdiff3";
      core.safecrlf = "warn";
      core.autocrlf = false;
      core.pager = "less -F -X";
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "log --graph --oneline --all";
        amend = "commit --amend --no-edit";
      };
    };

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
}
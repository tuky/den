{ config, lib, ... }:

let
  preferences = builtins.fromJSON (builtins.readFile ./preferences.json);
  settings = preferences // {
    "New Bookmarks" = map (profile: profile // {
      "Working Directory" = config.home.homeDirectory;
    }) preferences."New Bookmarks";
  };
  preferencesDirectory = "${config.xdg.configHome}/iterm2/den";
in
{
  # Keep iTerm's mutable preferences and application state outside the Nix store.
  xdg.configFile."iterm2/den/com.googlecode.iterm2.plist".text =
    lib.generators.toPlist { escape = true; } settings;

  home.activation.configureIterm2 = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run /usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string ${lib.escapeShellArg preferencesDirectory}
    run /usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  '';
}

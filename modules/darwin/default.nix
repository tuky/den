{ ... }:

{
  # Keep the installer responsible for the Nix daemon and its configuration.
  # This also supports installations managed by Determinate Nix.
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;

  # Initial nix-darwin schema baseline; unrelated to home.stateVersion.
  system.stateVersion = 6;
}

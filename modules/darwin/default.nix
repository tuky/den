{ lib, ... }:

{
  # Keep the installer responsible for the Nix daemon and its configuration.
  # This also supports installations managed by Determinate Nix.
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  # Record completion after integrated Home Manager activation, not build time.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    install -d -m 0755 /var/db/den
    date +%s > /var/db/den/last-activation.tmp
    chmod 0644 /var/db/den/last-activation.tmp
    mv -f /var/db/den/last-activation.tmp /var/db/den/last-activation
  '';

  # Initial nix-darwin schema baseline; unrelated to home.stateVersion.
  system.stateVersion = 6;
}

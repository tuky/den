{ config, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  home-manager.users.${config.system.primaryUser} = { inputs, pkgs, ... }: {
    home.packages = [ inputs.linear-cli.packages.${pkgs.stdenv.hostPlatform.system}.linear ];

    programs.zsh.initContent = ''
      # Linear API access; the key is provisioned locally, outside den.
      if [[ -r "$HOME/.config/linear/api-key" ]]; then
        export LINEAR_API_KEY="$(< "$HOME/.config/linear/api-key")"
      fi
    '';
  };
}

{ config, pkgs, lib, ... }:

{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;

    config = {
      # Load direnv in a standard way
      load_dotenv = true;
      warn_timeout = "10m";
    };
  };

  # Create a direnv template for new projects
  home.file.".envrc.template" = {
    text = ''
      # Template .envrc for use with `direnv allow`
      # Copy to your project and customize as needed
      use flake
    '';
  };
}

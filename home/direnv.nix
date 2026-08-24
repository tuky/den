{ ... }:

{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      load_dotenv = true;
      warn_timeout = "10m";
    };
  };

  home.file.".envrc.template".text = ''
    use flake
  '';
}
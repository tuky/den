{ config, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  home-manager.users.${config.system.primaryUser} = { inputs, pkgs, ... }:
  let
    sentryRelease = builtins.fromJSON (builtins.readFile inputs.sentry-release);
    sentryBinary = sentryRelease.files.sentry-darwin-arm64;
    sentry = pkgs.stdenvNoCC.mkDerivation {
      pname = "sentry";
      version = sentryRelease.version;
      src = pkgs.fetchurl {
        url = sentryBinary.url;
        sha256 = sentryBinary.checksums.sha256-hex;
      };
      dontUnpack = true;
      # Preserve the upstream signed standalone executable.
      dontFixup = true;
      installPhase = ''
        runHook preInstall
        install -Dm755 "$src" "$out/bin/sentry"
        runHook postInstall
      '';
      meta = {
        description = "Sentry CLI for developers and agents";
        homepage = "https://cli.sentry.dev/";
        platforms = [ "aarch64-darwin" ];
        mainProgram = "sentry";
      };
    };
  in {
    home.packages = [
      inputs.linear-cli.packages.${pkgs.stdenv.hostPlatform.system}.linear
      sentry
    ];

    programs.zsh.initContent = ''
      # Linear API access; the key is provisioned locally, outside den.
      if [[ -r "$HOME/.config/linear/api-key" ]]; then
        export LINEAR_API_KEY="$(< "$HOME/.config/linear/api-key")"
      fi

      # Sentry API access; the token is provisioned locally, outside den.
      if [[ -r "$HOME/.config/sentry/auth-token" ]]; then
        export SENTRY_AUTH_TOKEN="$(< "$HOME/.config/sentry/auth-token")"
      fi
    '';
  };
}

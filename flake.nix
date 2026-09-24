{
  description = "den: personal declarative configuration for machines and software";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, codex-cli-nix }:
    let
      supportedSystems = [ "aarch64-darwin" ];
      forEachSystem = function:
        builtins.listToAttrs (map (system: {
          name = system;
          value = function system;
        }) supportedSystems);

      # Explicit variables survive privilege elevation without adopting root's identity.
      username = builtins.getEnv "DEN_USER";
      homeDirectory = builtins.getEnv "DEN_HOME";
      validIdentity = builtins.match "[a-zA-Z_][a-zA-Z0-9_-]*" username != null
        && username != "root"
        && builtins.match "/.+" homeDirectory != null
        && homeDirectory != "/var/root";
    in
    {
      darwinConfigurations.macbook =
        if !validIdentity then
          throw "den: set DEN_USER to a non-root account and DEN_HOME to its absolute home directory; evaluate with --impure. Use den switch macbook as your normal user."
        else nix-darwin.lib.darwinSystem {
          modules = [
            ./modules/darwin/default.nix
            ./hosts/macbook.nix
            home-manager.darwinModules.home-manager
            {
              system.primaryUser = username;
              users.users.${username}.home = homeDirectory;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.${username} = {
                  imports = [ ./home/default.nix ./modules/darwin/home.nix ];
                  home.username = username;
                  home.homeDirectory = homeDirectory;
                  # Stable Home Manager schema baseline, independent of input versions.
                  home.stateVersion = "26.05";
                };
              };
            }
          ];
        };

      devShells = forEachSystem (system: {
        default = (nixpkgs.legacyPackages.${system}).mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            nixpkgs-fmt
            nix-update
            codex-cli-nix.packages.${system}.default
          ];
        };
      });

      apps = forEachSystem (system: {
        darwin-rebuild = {
          type = "app";
          program = "${nix-darwin.packages.${system}.darwin-rebuild}/bin/darwin-rebuild";
          meta.description = "Pinned nix-darwin command for den";
        };
      });

      packages = forEachSystem (system: {
        darwin-rebuild = nix-darwin.packages.${system}.darwin-rebuild;
      });

      formatter = forEachSystem (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );
    };
}

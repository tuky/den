{
  description = "den: personal declarative configuration for machines and software";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, codex-cli-nix }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forEachSystem = function:
        builtins.listToAttrs (map (system: {
          name = system;
          value = function system;
        }) supportedSystems);

      mkHomeConfiguration = system: modules: username: homeDirectory:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs; };
          modules = modules ++ [
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
              # Stable Home Manager schema baseline, independent of input versions.
              home.stateVersion = "26.05";
            }
          ];
        };
    in
    {
      homeConfigurations = {
        wsl = mkHomeConfiguration "x86_64-linux" [
          ./home/default.nix
          ./modules/linux/default.nix
          ./hosts/wsl.nix
        ] "tobias" "/home/tobias";
        macbook = mkHomeConfiguration "aarch64-darwin" [
          ./home/default.nix
          ./modules/darwin/default.nix
          ./hosts/macbook.nix
        ] "tobiaskroenke" "/Users/tobiaskroenke";
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
        home-manager = {
          type = "app";
          program = "${home-manager.packages.${system}.default}/bin/home-manager";
          meta.description = "Pinned Home Manager command for den";
        };
      });

      formatter = forEachSystem (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );
    };
}

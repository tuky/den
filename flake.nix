{
  description = "den: personal reproducible development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      mkHomeConfiguration = system: modules: homeDirectory:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home-manager/home.nix
          ] ++ modules ++ [
            {
              home.username = "tobias";
              home.homeDirectory = homeDirectory;
              home.stateVersion = "24.05";
            }
          ];
        };
    in
    {
      # Home Manager configurations must be top-level so `.#linux` resolves.
      homeConfigurations = {
        linux = mkHomeConfiguration "x86_64-linux" [ ./hosts/linux/home.nix ] "/home/tobias";
        darwin = mkHomeConfiguration "aarch64-darwin" [ ./hosts/darwin/home.nix ] "/Users/tobias";
      };

      # Keep development tools available for each host system.
      devShells = flake-utils.lib.eachSystem supportedSystems (system: {
        default = (nixpkgs.legacyPackages.${system}).mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            nixpkgs-fmt
            nix-update
            home-manager
          ];
        };
      });

      formatter = flake-utils.lib.eachSystem supportedSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );
    };
}

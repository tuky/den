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
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Platform detection
        isDarwin = system == "aarch64-darwin" || system == "x86_64-darwin";
        isLinux = !isDarwin;

        # Common modules shared across all platforms
        commonModules = [
          ./home-manager/home.nix
        ];

        # Platform-specific modules
        platformModules =
          if isDarwin then
            [ ./hosts/darwin/home.nix ]
          else
            [ ./hosts/linux/home.nix ];

        homeModules = commonModules ++ platformModules;

      in
      {
        homeConfigurations = {
          # Generic Linux configuration (for WSL, GCP, etc.)
          linux = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = homeModules ++ [
              {
                home.username = "tobias";
                home.homeDirectory =
                  if isLinux then "/home/tobias" else "/Users/tobias";
                home.stateVersion = "24.05";
              }
            ];
          };

          # macOS configuration (for when you get a Mac)
          darwin = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = homeModules ++ [
              {
                home.username = "tobias";
                home.homeDirectory = "/Users/tobias";
                home.stateVersion = "24.05";
              }
            ];
          };
        };

        # Development shell for working on den itself
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
            nix-update
            home-manager
          ];
        };

        formatter.default = pkgs.nixpkgs-fmt;
      }
    );
}

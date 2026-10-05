{
  description = "typst thesis flake template";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    forAllPkgs = f: forAllSystems (system: let pkgs = nixpkgs.legacyPackages.${system}; in f pkgs);
  in {
    devShells = forAllPkgs (pkgs: {
      default = with pkgs;
        mkShell {
          buildInputs = [typst];
        };
    });
  };
}
